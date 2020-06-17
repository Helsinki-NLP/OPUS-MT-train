# -*-makefile-*-
#
# make distribution packages
# and upload them to cPouta ObjectStorage
#

MODELSHOME          = ${WORKHOME}/models
DIST_PACKAGE        = ${MODELSHOME}/${LANGPAIRSTR}/${DATASET}.zip
MODEL_CONTAINER     = OPUS-MT-models
DEV_MODEL_CONTAINER = OPUS-MT-dev

## minimum BLEU score for models to be accepted as distribution package
MIN_BLEU_SCORE = 20

.PHONY: dist local-dist global-dist release
dist: ${DIST_PACKAGE}

## local distribution in workhome, no restrictions about BLEU
local-dist:
	${MAKE} MODELSHOME=${WORKHOME}/models \
		MODELS_URL=https://object.pouta.csc.fi/${DEV_MODEL_CONTAINER} \
	dist

## global distribution in models-dir, restrictions on BLEU
global-dist release:
	if  [ `grep BLEU $(TEST_EVALUATION) | cut -f3 -d ' ' | cut -f1 -d '.'` -ge ${MIN_BLEU_SCORE} ]; then \
	  ${MAKE} MODELSHOME=${PWD}/models \
		  MODELS_URL=https://object.pouta.csc.fi/${MODEL_CONTAINER}
	  dist; \
	fi


.PHONY: scores
scores:
	${MAKE} FIND_EVAL_FILES=1 ${WORKHOME}/eval/scores.txt



## get the best model from all kind of alternative setups
## in the following sub directories (add prefix work-)
## scan various work directories - specify alternative dir's below

ALT_MODEL_BASE = work-
# ALT_MODEL_DIR = bpe-old bpe-memad bpe spm-noalign bpe-align spm
# ALT_MODEL_DIR = spm langid
ALT_MODEL_DIR = langid

.PHONY: best_dist_all best-dist-all
best-dist-all best_dist_all:
	for l in $(sort ${shell ls ${ALT_MODEL_BASE}* | grep -- '-' | grep -v old | grep -v work}); do \
	  if  [ `find work*/$$l -name '*.npz' | wc -l` -gt 0 ]; then \
	    d=`find work-spm/$$l -name '*.best-perplexity.npz' -exec basename {} \; | cut -f1 -d.`; \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" \
		    DATASET=$$d best_dist; \
	  fi \
	done




## find the best model according to test set scores
## and make a distribution package from that model
## (BLEU needs to be above MIN_BLEU_SCORE)
## NEW: don't trust models tested with GNOME test sets!

## new version of finding the best model
## --> look at different model variants in each work-dir
## --> take only the best one to publish

.PHONY: best_dist best-dist
best-dist best_dist:
	@m=0;\
	s=''; \
	echo "------------------------------------------------"; \
	echo "search best model for ${LANGPAIRSTR}"; \
	for d in ${ALT_MODEL_DIR}; do \
	  e=`ls work-$$d/${LANGPAIRSTR}/test/*.trg | tail -1 | xargs basename | sed 's/\.trg//'`; \
	  echo "evaldata = $$e"; \
	  if [ "$$e" != "GNOME" ]; then \
	    I=`find work-$$d/${LANGPAIRSTR}/ -maxdepth 1 -name "$$e.*.eval" -printf "%f\n"`; \
	    for i in $$I; do \
	      x=`echo $$i | cut -f3 -d. | cut -f1 -d-`; \
	      y=`echo $$i | cut -f3 -d. | cut -f2 -d- | sed 's/[0-9]$$//'`; \
	      z=`echo $$i | cut -f2 -d.`; \
	      v=`echo $$i | cut -f4 -d.`; \
	      b=`grep 'BLEU+' work-$$d/${LANGPAIRSTR}/$$e.$$z.$$x-$$y[0-9].$$v.*.eval | cut -f3 -d' '`; \
	      if (( $$(echo "$$m-$$b < 0" |bc -l) )); then \
	        echo "$$d/$$i ($$b) is better than $$s ($$m)!"; \
	        m=$$b; \
	        E=$$i; \
	        s=$$d; \
	      else \
	        echo "$$d/$$i ($$b) is  worse than $$s ($$m)!"; \
	      fi \
	    done; \
	  fi \
	done; \
	echo "--------------- best = $$m ($$s/$$E) ---------------------------------"; \
	if [ "$$s" != "" ]; then \
	  if (( $$(echo "$$m > ${MIN_BLEU_SCORE}" |bc -l) )); then \
	    x=`echo $$E | cut -f3 -d. | cut -f1 -d-`; \
	    y=`echo $$E | cut -f3 -d. | cut -f2 -d- | sed 's/[0-9]$$//'`; \
	    z=`echo $$E | cut -f2 -d.`; \
	    v=`echo $$E | cut -f4 -d.`; \
	    ${MAKE} \
		MODELSHOME=${PWD}/models \
		PRE_SRC=$$x PRE_TRG=$$y \
		DATASET=$$z \
		MODELTYPE=$$v   \
		MODELS_URL=https://object.pouta.csc.fi/${MODEL_CONTAINER} dist-$$s; \
	  fi; \
	fi




## make a package for distribution

## old: only accept models with a certain evaluation score:
# 	if  [ `grep BLEU $(TEST_EVALUATION) | cut -f3 -d ' ' | cut -f1 -d '.'` -ge ${MIN_BLEU_SCORE} ]; then \

DATE = ${shell date +%F}
MODELS_URL = https://object.pouta.csc.fi/${DEV_MODEL_CONTAINER}
SKIP_DIST_EVAL = 0


## determine pre-processing type

ifneq ("$(wildcard ${BPESRCMODEL})","")
  PREPROCESS_TYPE = bpe
  PREPROCESS_SRCMODEL = ${BPESRCMODEL}
  PREPROCESS_TRGMODEL = ${BPETRGMODEL}
  PREPROCESS_DESCRIPTION = normalization + tokenization + BPE (${PRE_SRC},${PRE_TRG})
else
  PREPROCESS_TYPE = spm
  PREPROCESS_SRCMODEL = ${SPMSRCMODEL}
  PREPROCESS_TRGMODEL = ${SPMTRGMODEL}
  PREPROCESS_DESCRIPTION = normalization + SentencePiece (${PRE_SRC},${PRE_TRG})
endif

ifneq (${words ${TRGLANGS}},1)
  PREPROCESS_SCRIPT = preprocess-${PREPROCESS_TYPE}-multi-target.sh
else
  PREPROCESS_SCRIPT = preprocess-${PREPROCESS_TYPE}.sh
endif

POSTPROCESS_SCRIPT = postprocess-${PREPROCESS_TYPE}.sh



## make the distribution package including test evaluation files and README

${DIST_PACKAGE}: ${MODEL_FINAL}
ifneq (${SKIP_DIST_EVAL},1)
	@${MAKE} $(TEST_EVALUATION)
	@${MAKE} $(TEST_COMPARISON)
endif
	@mkdir -p ${dir $@}
	@touch ${WORKDIR}/source.tcmodel
	@echo "# $(notdir ${@:.zip=})-${DATE}.zip" > ${WORKDIR}/README.md
	@echo '' >> ${WORKDIR}/README.md
	@echo "* dataset: ${DATASET}" >> ${WORKDIR}/README.md
	@echo "* model: ${MODELTYPE}" >> ${WORKDIR}/README.md
	@echo "* source language(s): ${SRCLANGS}" >> ${WORKDIR}/README.md
	@echo "* target language(s): ${TRGLANGS}" >> ${WORKDIR}/README.md
	@echo "* model: ${MODELTYPE}" >> ${WORKDIR}/README.md
	@echo "* pre-processing: ${PREPROCESS_DESCRIPTION}" >> ${WORKDIR}/README.md
	@cp ${PREPROCESS_SRCMODEL} ${WORKDIR}/source.${PREPROCESS_TYPE}
	@cp ${PREPROCESS_TRGMODEL} ${WORKDIR}/target.${PREPROCESS_TYPE}
	@cp ${PREPROCESS_SCRIPT} ${WORKDIR}/preprocess.sh
	@cp ${POSTPROCESS_SCRIPT} ${WORKDIR}/postprocess.sh
	@if [ ${words ${TRGLANGS}} -gt 1 ]; then \
	  echo '* a sentence initial language token is required in the form of `>>id<<` (id = valid target language ID)' \
		>> ${WORKDIR}/README.md; \
	fi
	@echo "* download: [$(notdir ${@:.zip=})-${DATE}.zip](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.zip)" >> ${WORKDIR}/README.md
	if [ -e $(TEST_EVALUATION) ]; then \
	  echo "* test set translations: [$(notdir ${@:.zip=})-${DATE}.test.txt](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.test.txt)" >> ${WORKDIR}/README.md; \
	  echo "* test set scores: [$(notdir ${@:.zip=})-${DATE}.eval.txt](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.eval.txt)" >> ${WORKDIR}/README.md; \
	  echo '' >> ${WORKDIR}/README.md; \
	  if [ "${SKIP_DATA_DETAILS}" != "1" ]; then \
	    if [ -e ${WORKDIR}/train/README.md ]; then \
	      echo -n "## Training data: " >> ${WORKDIR}/README.md; \
	      tr "\n" "~"  < ${WORKDIR}/train/README.md |\
	      tr "#" "\n" | grep '${DATASET}' | \
	      tail -1 | tr "~" "\n" >> ${WORKDIR}/README.md; \
	      echo '' >> ${WORKDIR}/README.md; \
	    fi; \
	    if [ -e ${WORKDIR}/val/README.md ]; then \
	      echo -n "#"                  >> ${WORKDIR}/README.md; \
	      cat ${WORKDIR}/val/README.md >> ${WORKDIR}/README.md; \
	      echo ''                      >> ${WORKDIR}/README.md; \
	    fi; \
	  fi; \
	  echo '## Benchmarks' >> ${WORKDIR}/README.md; \
	  echo '' >> ${WORKDIR}/README.md; \
	  cd ${WORKDIR}; \
	  grep -H BLEU *.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
		sed 's/^\(.*\)\.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}\.\(.*\)\.eval:.*$$/\1.\2/' > $@.1; \
	  grep BLEU *.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | cut -f3 -d ' ' > $@.2; \
	  grep chrF *.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | cut -f3 -d ' ' > $@.3; \
	  echo '| testset               | BLEU  | chr-F |' >> README.md; \
	  echo '|-----------------------|-------|-------|' >> README.md; \
	  paste $@.1 $@.2 $@.3 | sed  "s/\t/ 	| /g;s/^/| /;s/$$/ |/" | sort | uniq >> README.md; \
	  rm -f $@.1 $@.2 $@.3; \
	fi
	@cat ${WORKDIR}/README.md >> ${dir $@}README.md
	@echo '' >> ${dir $@}README.md
	@cp models/LICENSE ${WORKDIR}/
	@chmod +x ${WORKDIR}/preprocess.sh
	@sed -e 's# - .*/\([^/]*\)$$# - \1#' \
	    -e 's/beam-size: [0-9]*$$/beam-size: 6/' \
	    -e 's/mini-batch: [0-9]*$$/mini-batch: 1/' \
	    -e 's/maxi-batch: [0-9]*$$/maxi-batch: 1/' \
	    -e 's/relative-paths: false/relative-paths: true/' \
	< ${MODEL_DECODER} > ${WORKDIR}/decoder.yml
	@cd ${WORKDIR} && zip ${notdir $@} \
		README.md LICENSE \
		${notdir ${MODEL_FINAL}} \
		${notdir ${MODEL_VOCAB}} \
		${notdir ${MODEL_VALIDLOG}} \
		${notdir ${MODEL_TRAINLOG}} \
		source.* target.* decoder.yml preprocess.sh postprocess.sh
	@mkdir -p ${dir $@}
	@mv -f ${WORKDIR}/${notdir $@} ${@:.zip=}-${DATE}.zip
	if [ -e $(TEST_EVALUATION) ]; then \
	  cp $(TEST_EVALUATION) ${@:.zip=}-${DATE}.eval.txt; \
	  cp $(TEST_COMPARISON) ${@:.zip=}-${DATE}.test.txt; \
	fi
	@rm -f $@
	@cd ${dir $@} && ln -s $(notdir ${@:.zip=})-${DATE}.zip ${notdir $@}
	@rm -f ${WORKDIR}/decoder.yml ${WORKDIR}/source.* ${WORKDIR}/target.*
	@rm -f ${WORKDIR}/preprocess.sh ${WORKDIR}/postprocess.sh


#	  grep -H BLEU *.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
#		tr '.' '/' | cut -f1,5,6 -d '/' | tr '/' "." > $@.1; \



## do this only if the flag is set
## --> avoid expensive wildcard searches each time make is called

ifeq (${FIND_EVAL_FILES},1)
  EVALSCORES = ${patsubst ${WORKHOME}/%.eval,${WORKHOME}/eval/%.eval.txt,${wildcard ${WORKHOME}/*/*.eval}}
  EVALTRANSL = ${patsubst ${WORKHOME}/%.compare,${WORKHOME}/eval/%.test.txt,${wildcard ${WORKHOME}/*/*.compare}}
endif

## upload to Object Storage
## Don't forget to run this before uploading!
#	source project_2000661-openrc.sh
#
# - make upload ......... released models = all sub-dirs in models/
# - make upload-models .. trained models in current WORKHOME to OPUS-MT-dev
# - make upload-scores .. score file with benchmark results to OPUS-MT-eval
# - make upload-eval .... benchmark tests from models in WORKHOME
# - make upload-images .. images of VMs that run OPUS-MT

.PHONY: upload
upload:
	find ${MODELSHOME}/ -type l | tar -cf models-links.tar -T -
	find ${MODELSHOME}/ -type l -delete
	cd ${MODELSHOME} && swift upload ${MODEL_CONTAINER} --changed --skip-identical *
	tar -xf models-links.tar
	rm -f models-links.tar
	swift post ${MODEL_CONTAINER} --read-acl ".r:*"
	swift list ${MODEL_CONTAINER} > index.txt
	swift upload ${MODEL_CONTAINER} index.txt
	rm -f index.txt


.PHONY: upload-models
upload-models:
	find ${WORKHOME}/models -type l | tar -cf dev-models-links.tar -T -
	find ${WORKHOME}/models -type l -delete
	cd ${WORKHOME} && swift upload ${DEV_MODEL_CONTAINER} --changed --skip-identical models
	tar -xf dev-models-links.tar
	rm -f dev-models-links.tar
	swift post ${DEV_MODEL_CONTAINER} --read-acl ".r:*"
	swift list ${DEV_MODEL_CONTAINER} > index.txt
	swift upload ${DEV_MODEL_CONTAINER} index.txt
	rm -f index.txt

.PHONY: upload-scores
upload-scores: scores
	cd ${WORKHOME} && swift upload OPUS-MT-eval --changed --skip-identical eval/scores.txt
	swift post OPUS-MT-eval --read-acl ".r:*"

.PHONY: upload-eval
upload-eval: scores
	cd ${WORKHOME} && swift upload OPUS-MT-eval --changed --skip-identical eval
	swift post OPUS-MT-eval --read-acl ".r:*"

.PHONY: upload-images
upload-images:
	cd ${WORKHOME} && swift upload OPUS-MT --changed --skip-identical \
		--use-slo --segment-size 5G opusMT-images
	swift post OPUS-MT-images --read-acl ".r:*"



## this is for the multeval scores
# ${WORKHOME}/eval/scores.txt: ${EVALSCORES}
#	cd ${WORKHOME} && \
#	grep base */*eval | cut -f1,2- -d '/' | cut -f1,6- -d '.' | \
#	sed 's/-/    /' | sed 's/\//    /' | sed 's/ ([^)]*)//g' |\
#	sed 's/.eval:baseline//' | sed "s/  */\t/g" | sort  > $@


${WORKHOME}/eval/scores.txt: ${EVALSCORES} ${EVALTRANSL}
	cd ${WORKHOME} && grep BLEU */*k${NR}.*eval | cut -f1 -d '/' | tr '-' "\t" > $@.1
	cd ${WORKHOME} && grep BLEU */*k${NR}.*eval | tr '.' '/' | cut -f2,6,7 -d '/' | tr '/' "." > $@.2
	cd ${WORKHOME} && grep BLEU */*k${NR}.*eval | cut -f3 -d ' ' > $@.3
	cd ${WORKHOME} && grep chrF */*k${NR}.*eval | cut -f3 -d ' ' > $@.4
	paste $@.1 $@.2 $@.3 $@.4 > $@
	rm -f $@.1 $@.2 $@.3 $@.4


${EVALSCORES}: # ${WORKHOME}/eval/%.eval.txt: ${WORKHOME}/models/%.eval
	mkdir -p ${dir $@}
	cp ${patsubst ${WORKHOME}/eval/%.eval.txt,${WORKHOME}/%.eval,$@} $@
#	cp $< $@

${EVALTRANSL}: # ${WORKHOME}/eval/%.test.txt: ${WORKHOME}/models/%.compare
	mkdir -p ${dir $@}
	cp ${patsubst ${WORKHOME}/eval/%.test.txt,${WORKHOME}/%.compare,$@} $@
#	cp $< $@




# ## dangerous area ....
# delete-eval:
# 	swift delete OPUS-MT eval







######################################################################
## handle old models in previous work directories
## obsolete now?
######################################################################



##-----------------------------------
## make packages from trained models
## check old-models as well!

TRAINED_NEW_MODELS = ${patsubst ${WORKHOME}/%/,%,${dir ${wildcard ${WORKHOME}/*/*.best-perplexity.npz}}}
# TRAINED_OLD_MODELS = ${patsubst ${WORKHOME}/old-models/%/,%,${dir ${wildcard ${WORKHOME}/old-models/*/*.best-perplexity.npz}}}
TRAINED_OLD_MODELS = ${patsubst ${WORKHOME}/old-models/%/,%,${dir ${wildcard ${WORKHOME}/old-models/??-??/*.best-perplexity.npz}}}

TRAINED_OLD_ONLY_MODELS = ${filter-out ${TRAINED_NEW_MODELS},${TRAINED_OLD_MODELS}}
TRAINED_NEW_ONLY_MODELS = ${filter-out ${TRAINED_OLD_MODELS},${TRAINED_NEW_MODELS}}
TRAINED_DOUBLE_MODELS   = ${filter ${TRAINED_NEW_MODELS},${TRAINED_OLD_MODELS}}

## make packages of all new models
## unless there are better models in old-models
new-models-dist:
	@echo "nr of extra models: ${words ${TRAINED_NEW_ONLY_MODELS}}"
	for l in ${TRAINED_NEW_ONLY_MODELS}; do \
	  ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		  TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" dist; \
	done
	@echo "trained double ${words ${TRAINED_DOUBLE_MODELS}}"
	for l in ${TRAINED_DOUBLE_MODELS}; do \
	  n=`grep 'new best' work/$$l/*.valid1.log | tail -1 | cut -f12 -d ' '`; \
	  o=`grep 'new best' work/old-models/$$l/*.valid1.log | tail -1 | cut -f12 -d ' '`; \
	  if (( $$(echo "$$n < $$o" |bc -l) )); then \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" dist; \
	  fi \
	done


## fix decoder path in old-models (to run evaluations
fix-decoder-path:
	for l in ${wildcard ${WORKHOME}/old-models/*/*.best-perplexity.npz.decoder.yml}; do \
	  sed --in-place=.backup 's#/\(..-..\)/opus#/old-models/\1/opus#' $$l; \
	  sed --in-place=.backup2 's#/old-models/old-models/#/old-models/#' $$l; \
	  sed --in-place=.backup2 's#/old-models/old-models/#/old-models/#' $$l; \
	done

## make packages of all old models from old-models
## unless there are better models in work (new models)
old-models-dist:
	@echo "nr of extra models: ${words ${TRAINED_OLD_ONLY_MODELS}}"
	for l in ${TRAINED_OLD_ONLY_MODELS}; do \
	  ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		  TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" \
	          WORKHOME=${WORKHOME}/old-models \
	          MODELSHOME=${WORKHOME}/models dist; \
	done
	@echo "trained double ${words ${TRAINED_DOUBLE_MODELS}}"
	for l in ${TRAINED_DOUBLE_MODELS}; do \
	  n=`grep 'new best' work/$$l/*.valid1.log | tail -1 | cut -f12 -d ' '`; \
	  o=`grep 'new best' work/old-models/$$l/*.valid1.log | tail -1 | cut -f12 -d ' '`; \
	  if (( $$(echo "$$o < $$n" |bc -l) )); then \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" \
	            WORKHOME=${WORKHOME}/old-models \
	            MODELSHOME=${WORKHOME}/models dist; \
	  else \
	    echo "$$l: new better than old"; \
	  fi \
	done



## old models had slightly different naming conventions

LASTSRC = ${lastword ${SRCLANGS}}
LASTTRG = ${lastword ${TRGLANGS}}

MODEL_OLD           = ${MODEL_SUBDIR}${DATASET}${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}.${LASTSRC}${LASTTRG}
MODEL_OLD_BASENAME  = ${MODEL_OLD}.${MODELTYPE}.model${NR}
MODEL_OLD_FINAL     = ${WORKDIR}/${MODEL_OLD_BASENAME}.npz.best-perplexity.npz
MODEL_OLD_VOCAB     = ${WORKDIR}/${MODEL_OLD}.vocab.${MODEL_VOCABTYPE}
MODEL_OLD_DECODER   = ${MODEL_OLD_FINAL}.decoder.yml
MODEL_TRANSLATE     = ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}
MODEL_OLD_TRANSLATE = ${WORKDIR}/${TESTSET_NAME}.${MODEL_OLD}${NR}.${MODELTYPE}.${SRC}.${TRG}
MODEL_OLD_VALIDLOG  = ${MODEL_OLD}.${MODELTYPE}.valid${NR}.log
MODEL_OLD_TRAINLOG  = ${MODEL_OLD}.${MODELTYPE}.train${NR}.log


link-old-models:
	if [ ! -e ${MODEL_FINAL} ]; then \
	  if [ -e ${MODEL_OLD_FINAL} ]; then \
	    ln -s ${MODEL_OLD_FINAL} ${MODEL_FINAL}; \
	    ln -s ${MODEL_OLD_VOCAB} ${MODEL_VOCAB}; \
	    ln -s ${MODEL_OLD_DECODER} ${MODEL_DECODER}; \
	  fi \
	fi
	if [ ! -e ${MODEL_TRANSLATE} ]; then \
	  if [ -e ${MODEL_OLD_TRANSLATE} ]; then \
	    ln -s ${MODEL_OLD_TRANSLATE} ${MODEL_TRANSLATE}; \
	  fi \
	fi
	if [ ! -e ${WORKDIR}/${MODEL_VALIDLOG} ]; then \
	  if [ -e ${WORKDIR}/${MODEL_OLD_VALIDLOG} ]; then \
	    ln -s ${WORKDIR}/${MODEL_OLD_VALIDLOG} ${WORKDIR}/${MODEL_VALIDLOG}; \
	    ln -s ${WORKDIR}/${MODEL_OLD_TRAINLOG} ${WORKDIR}/${MODEL_TRAINLOG}; \
	  fi \
	fi
	rm -f ${MODEL_TRANSLATE}.eval
	rm -f ${MODEL_TRANSLATE}.compare


ifneq (${DATASET},${OLDDATASET})
  TRAINFILES = ${wildcard ${WORKDIR}/train/*${OLDDATASET}*.*}
  MODELFILES = ${wildcard ${WORKDIR}/*${OLDDATASET}*.*}
  DECODERFILES = ${wildcard ${WORKDIR}/*${OLDDATASET}*.decoder.yml}
endif


## fix model names from old style
## where models trained on a single corpus got the name
## of that corpus
## Now: always use 'opus' as the name of the default dataset

fix-model-names:
ifneq (${DATASET},${OLDDATASET})
	for f in ${DECODERFILES}; do \
	  perl -i.bak -pe 's/${OLDDATASET}/${DATASET}/' $$f; \
	done
	for f in ${TRAINFILES}; do \
	  mv -f $$f `echo $$f | sed 's/${OLDDATASET}/${DATASET}/'`; \
	  ln -s `echo $$f | sed 's/${OLDDATASET}/${DATASET}/'` $$f; \
	done
	for f in ${MODELFILES}; do \
	  mv -f $$f `echo $$f | sed 's/${OLDDATASET}/${DATASET}/'`; \
	done
endif
