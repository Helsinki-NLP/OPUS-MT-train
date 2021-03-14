# -*-makefile-*-
#
# make distribution packages
# and upload them to cPouta ObjectStorage
#

TODAY := ${shell date +%F}
DATE  ?= ${TODAY}

OBJECTSTORAGE       = https://object.pouta.csc.fi
MODEL_CONTAINER     = OPUS-MT-models
DEV_MODEL_CONTAINER = OPUS-MT-dev
MODELINDEX          = ${OBJECTSTORAGE}/${MODEL_CONTAINER}/index.txt
MODELSHOME          = ${WORKHOME}/models
RELEASEDIR          = ${PWD}/models


## TODO: better create a recipe for the yaml file and not the zip file
##       becaue we can keep the yaml files in the repo but not the zip files!
## --> better dependency in case we need to update and create new distributions!
DIST_PACKAGE      = ${MODELSHOME}/${LANGPAIRSTR}/${DATASET}.zip
DIST_YML          = ${MODELSHOME}/${LANGPAIRSTR}/${DATASET}.yml
RELEASE_README    = ${MODELSHOME}/${LANGPAIRSTR}/README.md
RELEASE_PACKAGE   = ${MODELSHOME}/${LANGPAIRSTR}/${DATASET}-${DATE}.zip
RELEASE_YML       = ${MODELSHOME}/${LANGPAIRSTR}/${DATASET}-${DATE}.yml

MODEL_README      = ${WORKDIR}/README.md
MODEL_YML         = ${patsubst %.npz,%.yml,${MODEL_FINAL}}



get-model-release = ${shell wget -qq -O - ${MODELINDEX} | grep '^${1}/.*-.*\.zip' | LANG=en_US.UTF-8 sort -r}
get-model-distro  = ${shell echo ${wildcard ${1}/${2}/*.zip} | tr ' ' "\n" | LANG=en_US.UTF-8 sort -r}



find-model:
	@echo ${call get-model-dist,${LANGPAIRSTR}}


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
ifeq (${wildcard $(TEST_EVALUATION)},)
	  ${MAKE} compare
endif
	if [ -e $(TEST_EVALUATION) ]; then \
	  if  [ `grep BLEU $(TEST_EVALUATION) | cut -f3 -d ' ' | cut -f1 -d '.'` -ge ${MIN_BLEU_SCORE} ]; then \
	    ${MAKE} MODELSHOME=${RELEASEDIR} \
		  MODELS_URL=https://object.pouta.csc.fi/${MODEL_CONTAINER} \
	    dist; \
	  fi \
	else \
	  echo "cannot find or create benchmark file ${TEST_EVALUATION}"; \
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
	m=0;\
	s=''; \
	echo "------------------------------------------------"; \
	echo "search best model for ${LANGPAIRSTR}"; \
	for d in work ${ALT_MODEL_DIR}; do \
	  if [ -e "work-$$d/${LANGPAIRSTR}/test/${TESTSET}.trg" ]; then \
	    e=`basename work-$$d/${LANGPAIRSTR}/test/${TESTSET}.trg | sed 's/\.trg$$//'`; \
	  else \
	    e=`ls work-$$d/${LANGPAIRSTR}/test/*.trg | tail -1 | xargs basename | sed 's/\.trg$$//'`; \
	  fi; \
	  echo "evaldata = $$e"; \
	  if [ "$$e" != "GNOME" ]; then \
	    I=`find work-$$d/${LANGPAIRSTR}/ -maxdepth 1 -name "$$e.*.eval" -printf "%f\n"`; \
	    for i in $$I; do \
	      x=`echo $$i | cut -f3 -d. | cut -f1 -d-`; \
	      y=`echo $$i | cut -f3 -d. | cut -f2 -d- | sed 's/[0-9]$$//'`; \
	      z=`echo $$i | cut -f2 -d.`; \
	      v=`echo $$i | cut -f4 -d.`; \
	      if [ `find work-$$d/${LANGPAIRSTR} -name "$$e.$$z.$$x-$$y[0-9].$$v.*.eval" | wc -l ` -gt 0 ]; then \
	        b=`grep 'BLEU+' work-$$d/${LANGPAIRSTR}/$$e.$$z.$$x-$$y[0-9].$$v.*.eval | cut -f3 -d' ' | head -1`; \
	        if (( $$(echo "$$m-$$b < 0" |bc -l) )); then \
	          echo "$$d/$$i ($$b) is better than $$s ($$m)!"; \
	          m=$$b; \
	          E=$$i; \
	          s=$$d; \
	        else \
	          echo "$$d/$$i ($$b) is  worse than $$s ($$m)!"; \
	        fi; \
	      fi; \
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

MODELS_URL = https://object.pouta.csc.fi/${DEV_MODEL_CONTAINER}
SKIP_DIST_EVAL = 0


## determine pre-processing type

ifneq ("$(wildcard ${BPESRCMODEL})","")
  PREPROCESS_TYPE     = bpe
  SUBWORD_TYPE        = bpe
  PREPROCESS_SRCMODEL = ${BPESRCMODEL}
  PREPROCESS_TRGMODEL = ${BPETRGMODEL}
  PREPROCESS_DESCRIPTION = normalization + tokenization + BPE (${PRE_SRC},${PRE_TRG})
else
  PREPROCESS_TYPE     = spm
  SUBWORD_TYPE        = spm
  PREPROCESS_SRCMODEL = ${SPMSRCMODEL}
  PREPROCESS_TRGMODEL = ${SPMTRGMODEL}
  PREPROCESS_DESCRIPTION = normalization + SentencePiece (${PRE_SRC},${PRE_TRG})
endif

ifneq (${words ${TRGLANGS}},1)
  PREPROCESS_SCRIPT = scripts/preprocess-${PREPROCESS_TYPE}-multi-target.sh
else
  PREPROCESS_SCRIPT = scripts/preprocess-${PREPROCESS_TYPE}.sh
endif

POSTPROCESS_SCRIPT  = scripts/postprocess-${PREPROCESS_TYPE}.sh


##--------------------------------------------------------------------------
## make the distribution package including test evaluation files and README
##--------------------------------------------------------------------------

## language codes without extensions
RAWSRCLANGS = ${sort ${basename ${basename ${subst _,.,${subst -,.,${SRCLANGS}}}}}}
RAWTRGLANGS = ${sort ${basename ${basename ${subst _,.,${subst -,.,${TRGLANGS}}}}}}

## language labels in multilingual models
## (NEW: take them directly from the model vocabulary
##  tto avoid listing labels that are not used)

# LANGUAGELABELS = ${patsubst %,>>%<<,${TRGLANGS}}
LANGUAGELABELS = ${shell grep '">>.*<<"' ${MODEL_SRCVOCAB} | cut -f1 -d: | sed 's/"//g'}


model-yml: ${MODEL_YML}
model-readme: ${MODEL_README}
release-yml: ${RELEASE_YML}
release-readme: ${RELEASE_README}

${RELEASE_YML}: ${MODEL_YML}
	@mkdir -p ${dir $@}
	if [ -e $@ ]; then \
	  mkdir -p models-backup/${LANGPAIRSTR}/${TODAY}; \
	  mv -f $@ models-backup/${LANGPAIRSTR}/${TODAY}/; \
	fi
	cp $< $@

${RELEASE_README}: ${MODEL_README}
	@mkdir -p ${dir $@}
	if [ -e $@ ]; then \
	   mkdir -p models-backup/${LANGPAIRSTR}/${TODAY}; \
	   mv -f $@ models-backup/${LANGPAIRSTR}/${TODAY}/; \
	   cat models-backup/${LANGPAIRSTR}/${TODAY}/${notdir $@} |\
	   sed 's/^# /§/g' | tr "\n" '~' | tr '§' "\n" | grep . |\
	   grep -v '^${notdir ${RELEASE_PACKAGE}}' | \
	   sed 's/^/# /' | tr '~' "\n" > $@; \
	fi
	cat $<  >> $@
	echo '' >> $@


##---------------------------------------
## create release description file (yml)
##---------------------------------------

${MODEL_YML}: ${MODEL_FINAL}
	@mkdir -p ${dir $@}
	@echo "release: ${LANGPAIRSTR}/$(notdir ${RELEASE_PACKAGE})"  > $@
	@echo "release-date: $(DATE)"                     >> $@
	@echo "dataset-name: $(DATASET)"                  >> $@
	@echo "modeltype: $(MODELTYPE)"                   >> $@
	@echo "pre-processing: ${PREPROCESS_DESCRIPTION}" >> $@
	@echo "subwords:"                                 >> $@
	@echo "   - source: ${PRE_SRC}"                   >> $@
	@echo "   - target: ${PRE_TRG}"                   >> $@
	@echo "subword-models:"                           >> $@
	@echo "   - source: source.${SUBWORD_TYPE}"       >> $@
	@echo "   - target: target.${SUBWORD_TYPE}"       >> $@
ifdef USE_TARGET_LABELS
	@echo "use-target-labels:"                        >> $@
	@for t in ${TRGLANGS}; do \
	  echo "   - >>$$t<<"                             >> $@; \
	done
endif
	@echo "source-languages:"                         >> $@
	@for s in ${RAWSRCLANGS}; do\
	  echo "   - $$s"                                 >> $@; \
	done
	@echo "target-languages:"                         >> $@
	@for t in ${RAWTRGLANGS}; do\
	  echo "   - $$t"                                 >> $@; \
	done
ifneq ("$(wildcard ${WORKDIR}/train/README.md)","")
	@echo "training-data:"                            >> $@
	@tr "\n" "~"  < ${WORKDIR}/train/README.md |\
	tr "#" "\n" | grep '^ ${DATASET}~' | \
	tail -1 | tr "~" "\n" | grep '^\* ' | \
	grep -v ': *$$' | grep -v ' 0$$' | \
	grep -v 'total size' | sed 's/^\* /   - /'        >> $@
endif
ifneq ("$(wildcard ${WORKDIR}/val/README.md)","")
	@echo "validation-data:"                          >> $@
	grep '^\* ' ${WORKDIR}/val/README.md | \
	grep -v ' 0$$' | \
	sed 's/^\* /   - /'                               >> $@
endif
##-----------------------------
## add benchmark results
##
## - grep and normalise test set names
## - ugly perl script that does some tansformation of language codes
##-----------------------------
ifneq ("$(wildcard ${TEST_EVALUATION})","")
	@grep -H BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	sed 's#^${WORKDIR}/\(.*\)\.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}\.\(.*\)\.eval:.*$$#\1.\2#' | \
	perl -pe 'if (/\.([^\.]+)\.([^\.\s]+)$$/){$$s=$$1;$$t=$$2;s/[\-\.]$$s?\-?$$t\.$$s\.$$t?$$/.$$s.$$t/;s/\.$$s\.$$t$$/.$$s-$$t/}' > $@.1
	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f3 -d ' ' > $@.2
	@grep chrF ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f3 -d ' ' > $@.3
	@ls ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	sed 's/\.eval//' | xargs wc -l | grep -v total | sed 's/^ *//' | cut -f1 -d' ' > $@.4
	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f16 -d ' ' | sed 's/)//' > $@.5
	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f7 -d ' ' > $@.6
	@paste -d '/' $@.4 $@.5                                      > $@.7
	@echo "test-data:"                                          >> $@
	@paste -d' ' $@.1 $@.7 | sed 's/ /: /;s/^/   - /;'          >> $@
	@echo "BLEU-scores:"                                        >> $@
	@paste -d' ' $@.1 $@.2 | sed 's/ /: /;s/^/   - /'           >> $@
	@echo "chr-F-scores:"                                       >> $@
	@paste -d' ' $@.1 $@.3 | sed 's/ /: /;s/^/   - /'           >> $@
	@rm -f $@.1 $@.2 $@.3 $@.4 $@.5 $@.6 $@.7
endif



##-----------------------------
## create README-file
##-----------------------------

${MODEL_README}: ${MODEL_FINAL}
	@echo "# $(notdir ${RELEASE_PACKAGE})"               > $@
	@echo ''                                            >> $@
	@echo "* dataset: ${DATASET}"                       >> $@
	@echo "* model: ${MODELTYPE}"                       >> $@
	@echo "* source language(s): ${RAWSRCLANGS}"        >> $@
	@echo "* target language(s): ${RAWTRGLANGS}"        >> $@
	@echo "* model: ${MODELTYPE}"                       >> $@
	@echo "* pre-processing: ${PREPROCESS_DESCRIPTION}" >> $@
ifdef USE_TARGET_LABELS
	echo '* a sentence initial language token is required in the form of `>>id<<` (id = valid target language ID)' >> $@
	@echo "* valid language labels: ${LANGUAGELABELS}"  >> $@
endif
	@echo "* download: [$(notdir ${RELEASE_PACKAGE})](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${RELEASE_PACKAGE}))" >> $@
ifneq (${SKIP_DATA_DETAILS},1)
ifneq ("$(wildcard ${WORKDIR}/train/README.md)","")
	@echo -n "## Training data: "                       >> $@
	@tr "\n" "~"  < ${WORKDIR}/train/README.md |\
	tr "#" "\n" | grep '${DATASET}' | \
	tail -1 | tr "~" "\n"                               >> $@
	@echo ''                                            >> $@
endif
ifneq ("$(wildcard ${WORKDIR}/val/README.md)","")
	@echo -n "#"                                        >> $@
	@cat ${WORKDIR}/val/README.md                       >> $@
	@echo ''                                            >> $@
endif
endif
##-----------------------------
## add benchmark results
##-----------------------------
ifneq ("$(wildcard ${TEST_EVALUATION})","")
	@echo "* test set translations: [$(patsubst %.zip,%.test.txt,$(notdir ${RELEASE_PACKAGE}))](${MODELS_URL}/${LANGPAIRSTR}/$(patsubst %.zip,%.test.txt,$(notdir ${RELEASE_PACKAGE})))" >> $@
	@echo "* test set scores: [$(patsubst %.zip,%.eval.txt,$(notdir ${RELEASE_PACKAGE}))](${MODELS_URL}/${LANGPAIRSTR}/$(patsubst %.zip,%.eval.txt,$(notdir ${RELEASE_PACKAGE})))" >> $@
	@echo '' >> $@
	@echo '## Benchmarks'                                       >> $@
	@echo ''                                                    >> $@
## grep and normalise test set names
## ugly perl script that does some tansformation of language codes
	@grep -H BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	sed 's#^${WORKDIR}/\(.*\)\.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}\.\(.*\)\.eval:.*$$#\1.\2#' | \
	perl -pe 'if (/\.([^\.]+)\.([^\.\s]+)$$/){$$s=$$1;$$t=$$2;s/[\-\.]$$s?\-?$$t\.$$s\.$$t?$$/.$$s.$$t/;s/\.$$s\.$$t$$/.$$s-$$t/}' > $@.1
	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f3 -d ' ' > $@.2
	@grep chrF ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f3 -d ' ' > $@.3
	@ls ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	sed 's/\.eval//' | xargs wc -l | grep -v total | sed 's/^ *//' | cut -f1 -d' ' > $@.4
	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f16 -d ' ' | sed 's/)//' > $@.5
	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
	cut -f7 -d ' ' > $@.6
	@paste -d '/' $@.4 $@.5                                      > $@.7
	@echo '| testset | BLEU  | chr-F | #sent | #words | BP |'   >> $@
	@echo '|---------|-------|-------|-------|--------|----|'   >> $@
	@paste $@.1 $@.2 $@.3 $@.4 $@.5 $@.6 | \
	sed  "s/\t/ 	| /g;s/^/| /;s/$$/ |/" | \
	sort | uniq                                                 >> $@
	@rm -f $@.1 $@.2 $@.3 $@.4 $@.5 $@.6 $@.7
endif








${DIST_PACKAGE}: ${MODEL_FINAL}
ifneq (${SKIP_DIST_EVAL},1)
	@${MAKE} $(TEST_EVALUATION)
	@${MAKE} $(TEST_COMPARISON)
endif
##-----------------------------
## collect all files we need
##-----------------------------
	@${MAKE} ${MODEL_README}
	@${MAKE} ${MODEL_YML}
	@touch ${WORKDIR}/source.tcmodel
	@cp ${PREPROCESS_SRCMODEL} ${WORKDIR}/source.${SUBWORD_TYPE}
	@cp ${PREPROCESS_TRGMODEL} ${WORKDIR}/target.${SUBWORD_TYPE}
	@cp ${PREPROCESS_SCRIPT} ${WORKDIR}/preprocess.sh
	@cp ${POSTPROCESS_SCRIPT} ${WORKDIR}/postprocess.sh
	@chmod +x ${WORKDIR}/preprocess.sh
	@cp models/LICENSE ${WORKDIR}/
	@sed -e 's# - .*/\([^/]*\)$$# - \1#' \
	     -e 's/beam-size: [0-9]*$$/beam-size: 6/' \
	     -e 's/mini-batch: [0-9]*$$/mini-batch: 1/' \
	     -e 's/maxi-batch: [0-9]*$$/maxi-batch: 1/' \
	     -e 's/relative-paths: false/relative-paths: true/' \
	< ${MODEL_DECODER} > ${WORKDIR}/decoder.yml
##-----------------------------
## create the package
##-----------------------------
	cd ${WORKDIR} && zip ${notdir $@} \
		README.md LICENSE \
		${notdir ${MODEL_FINAL}} \
		${notdir ${MODEL_YML}} \
		${notdir ${MODEL_SRCVOCAB}} \
		${notdir ${MODEL_TRGVOCAB}} \
		${notdir ${MODEL_VALIDLOG}} \
		${notdir ${MODEL_TRAINLOG}} \
		source.* target.* decoder.yml \
		preprocess.sh postprocess.sh
ifneq ("$(wildcard ${WORKDIR}/${MODELCONFIG})","")
	@cd ${WORKDIR} && zip -u ${notdir $@} ${MODELCONFIG}
endif
##-----------------------------
## move files to release dir and cleanup
##-----------------------------
	@mkdir -p ${dir $@}
	@if [ -e ${RELEASE_PACKAGE} ]; then \
	   mkdir -p models-backup/${LANGPAIRSTR}/${DATE}; \
	   mv -f ${RELEASE_PACKAGE} models-backup/${LANGPAIRSTR}/${DATE}/; \
	   mv -f ${@:.zip=}-${DATE}.eval.txt models-backup/${LANGPAIRSTR}/${DATE}/; \
	   mv -f ${@:.zip=}-${DATE}.test.txt models-backup/${LANGPAIRSTR}/${DATE}/; \
	fi
	@mv -f ${WORKDIR}/${notdir $@} ${RELEASE_PACKAGE}
	@${MAKE} ${RELEASE_YML}
	@${MAKE} ${RELEASE_README}
ifneq ("$(wildcard ${TEST_EVALUATION})","")
	@cp $(TEST_EVALUATION) ${@:.zip=}-${DATE}.eval.txt
	@cp $(TEST_COMPARISON) ${@:.zip=}-${DATE}.test.txt
endif
	@rm -f $@
	@cd ${dir $@} && ln -s $(notdir ${RELEASE_PACKAGE}) ${notdir $@}
	@rm -f ${WORKDIR}/decoder.yml ${WORKDIR}/source.* ${WORKDIR}/target.*
	@rm -f ${WORKDIR}/preprocess.sh ${WORKDIR}/postprocess.sh




## refresh a release with the same time stamp
## in case it is already the newest one
## --> this is kind of dangerous as we may overwrite existing newer ones with older ones
## --> the reason for doing this is to update yml files and evaluation scores

refresh-release:
	if [[ ${DIST_PACKAGE} -nt ${MODEL_FINAL} ]]; then \
	  echo "updating ${shell realpath ${DIST_PACKAGE}}"; \
	  d=`realpath ${DIST_PACKAGE} | xargs basename | sed 's/^[^\-]*\-//;s/\.zip$$//'`; \
	  mkdir -p models-backup/${LANGPAIRSTR}/${DATE}; \
	  mv -f ${shell realpath ${DIST_PACKAGE}} models-backup/${LANGPAIRSTR}/${DATE}/; \
	  make DATE="$$d" release; \
	fi

refresh-release-yml:
ifneq ("$(wildcard ${TEST_EVALUATION})","")
	if [[ ${DIST_PACKAGE} -nt ${MODEL_FINAL} ]]; then \
	  echo "updating ${patsubst %.zip,%.yml,${shell realpath ${DIST_PACKAGE}}}"; \
	  d=`realpath ${DIST_PACKAGE} | xargs basename | sed 's/^[^\-]*\-//;s/\.zip$$//'`; \
	  if [ -e ${MODEL_YML} ]; then \
	    mv ${MODEL_YML} ${MODEL_YML}.${DATE}; \
	  fi; \
	  make DATE="$$d" release-yml; \
	fi
else
	@echo "no evaluation results found (${TEST_EVALUATION})"
	@echo "---------> skip refreshing the yml file"
endif

refresh-release-readme:
ifneq ("$(wildcard ${TEST_EVALUATION})","")
	if [[ ${DIST_PACKAGE} -nt ${MODEL_FINAL} ]]; then \
	  echo "updating ${LANGPAIRSTR}/README.md for ${notdir ${shell realpath ${DIST_PACKAGE}}}"; \
	  d=`realpath ${DIST_PACKAGE} | xargs basename | sed 's/^[^\-]*\-//;s/\.zip$$//'`; \
	  if [ -e ${MODEL_README} ]; then \
	    mv ${MODEL_README} ${MODEL_README}.${DATE}; \
	  fi; \
	  make DATE="$$d" release-readme; \
	fi
else
	@echo "no evaluation results found (${TEST_EVALUATION})"
	@echo "---------> skip refreshing the readme file"
endif





##### ------------------------------------
##### OLD release recipe: all in one
##### ------------------------------------


# ${DIST_PACKAGE}: ${MODEL_FINAL}
# ifneq (${SKIP_DIST_EVAL},1)
# 	@${MAKE} $(TEST_EVALUATION)
# 	@${MAKE} $(TEST_COMPARISON)
# endif
# 	@mkdir -p ${dir $@}
# 	@touch ${WORKDIR}/source.tcmodel
# 	@cp ${PREPROCESS_SRCMODEL} ${WORKDIR}/source.${SUBWORD_TYPE}
# 	@cp ${PREPROCESS_TRGMODEL} ${WORKDIR}/target.${SUBWORD_TYPE}
# 	@cp ${PREPROCESS_SCRIPT} ${WORKDIR}/preprocess.sh
# 	@cp ${POSTPROCESS_SCRIPT} ${WORKDIR}/postprocess.sh
# ##-----------------------------
# ## create YML file
# ##-----------------------------
# 	@echo "release: ${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.zip"  > ${@:.zip=}-${DATE}.yml
# 	@echo "release-date: $(DATE)"                     >> ${@:.zip=}-${DATE}.yml
# 	@echo "dataset-name: $(DATASET)"                  >> ${@:.zip=}-${DATE}.yml
# 	@echo "modeltype: $(MODELTYPE)"                   >> ${@:.zip=}-${DATE}.yml
# 	@echo "pre-processing: ${PREPROCESS_DESCRIPTION}" >> ${@:.zip=}-${DATE}.yml
# 	@echo "subwords:"                                 >> ${@:.zip=}-${DATE}.yml
# 	@echo "   - source: ${PRE_SRC}"                   >> ${@:.zip=}-${DATE}.yml
# 	@echo "   - target: ${PRE_TRG}"                   >> ${@:.zip=}-${DATE}.yml
# 	@echo "subword-models:"                           >> ${@:.zip=}-${DATE}.yml
# 	@echo "   - source: source.${SUBWORD_TYPE}"       >> ${@:.zip=}-${DATE}.yml
# 	@echo "   - target: target.${SUBWORD_TYPE}"       >> ${@:.zip=}-${DATE}.yml
# ifdef USE_TARGET_LABELS
# 	@echo "use-target-labels:"                        >> ${@:.zip=}-${DATE}.yml
# 	@for t in ${TRGLANGS}; do \
# 	  echo "   - >>$$t<<"                             >> ${@:.zip=}-${DATE}.yml; \
# 	done
# endif
# 	@echo "source-languages:"                         >> ${@:.zip=}-${DATE}.yml
# 	@for s in ${RAWSRCLANGS}; do\
# 	  echo "   - $$s"                                 >> ${@:.zip=}-${DATE}.yml; \
# 	done
# 	@echo "target-languages:"                         >> ${@:.zip=}-${DATE}.yml
# 	@for t in ${RAWTRGLANGS}; do\
# 	  echo "   - $$t"                                 >> ${@:.zip=}-${DATE}.yml; \
# 	done
# ifneq ("$(wildcard ${WORKDIR}/train/README.md)","")
# 	@echo "training-data:"                            >> ${@:.zip=}-${DATE}.yml
# 	@tr "\n" "~"  < ${WORKDIR}/train/README.md |\
# 	tr "#" "\n" | grep '^ ${DATASET}~' | \
# 	tail -1 | tr "~" "\n" | grep '^\* ' | \
# 	grep -v ': *$$' | grep -v ' 0$$' | \
# 	grep -v 'total size' | sed 's/^\* /   - /'        >> ${@:.zip=}-${DATE}.yml
# endif
# ifneq ("$(wildcard ${WORKDIR}/val/README.md)","")
# 	@echo "validation-data:"                          >> ${@:.zip=}-${DATE}.yml
# 	grep '^\* ' ${WORKDIR}/val/README.md | \
# 	grep -v ' 0$$' | \
# 	sed 's/^\* /   - /'                               >> ${@:.zip=}-${DATE}.yml
# endif
# ##-----------------------------
# ## create README-file
# ##-----------------------------
# 	@echo "# $(notdir ${@:.zip=})-${DATE}.zip"           > ${WORKDIR}/README.md
# 	@echo ''                                            >> ${WORKDIR}/README.md
# 	@echo "* dataset: ${DATASET}"                       >> ${WORKDIR}/README.md
# 	@echo "* model: ${MODELTYPE}"                       >> ${WORKDIR}/README.md
# 	@echo "* source language(s): ${RAWSRCLANGS}"        >> ${WORKDIR}/README.md
# 	@echo "* target language(s): ${RAWTRGLANGS}"        >> ${WORKDIR}/README.md
# 	@echo "* model: ${MODELTYPE}"                       >> ${WORKDIR}/README.md
# 	@echo "* pre-processing: ${PREPROCESS_DESCRIPTION}" >> ${WORKDIR}/README.md
# ifdef USE_TARGET_LABELS
# 	echo '* a sentence initial language token is required in the form of `>>id<<` (id = valid target language ID)' >> ${WORKDIR}/README.md
# 	@echo "* valid language labels: ${LANGUAGELABELS}"  >> ${WORKDIR}/README.md
# endif
# 	@echo "* download: [$(notdir ${@:.zip=})-${DATE}.zip](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.zip)" >> ${WORKDIR}/README.md
# ifneq (${SKIP_DATA_DETAILS},1)
# ifneq ("$(wildcard ${WORKDIR}/train/README.md)","")
# 	@echo -n "## Training data: "                       >> ${WORKDIR}/README.md
# 	@tr "\n" "~"  < ${WORKDIR}/train/README.md |\
# 	tr "#" "\n" | grep '${DATASET}' | \
# 	tail -1 | tr "~" "\n"                               >> ${WORKDIR}/README.md
# 	@echo ''                                            >> ${WORKDIR}/README.md
# endif
# ifneq ("$(wildcard ${WORKDIR}/val/README.md)","")
# 	@echo -n "#"                                        >> ${WORKDIR}/README.md
# 	@cat ${WORKDIR}/val/README.md                       >> ${WORKDIR}/README.md
# 	@echo ''                                            >> ${WORKDIR}/README.md
# endif
# endif
# ##-----------------------------
# ## add benchmark results
# ##-----------------------------
# ifneq ("$(wildcard ${TEST_EVALUATION})","")
# 	@echo "* test set translations: [$(notdir ${@:.zip=})-${DATE}.test.txt](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.test.txt)" >> ${WORKDIR}/README.md
# 	@echo "* test set scores: [$(notdir ${@:.zip=})-${DATE}.eval.txt](${MODELS_URL}/${LANGPAIRSTR}/$(notdir ${@:.zip=})-${DATE}.eval.txt)" >> ${WORKDIR}/README.md
# 	@echo '' >> ${WORKDIR}/README.md
# 	@echo '## Benchmarks'                                       >> ${WORKDIR}/README.md
# 	@echo ''                                                    >> ${WORKDIR}/README.md
# ## grep and normalise test set names
# ## ugly perl script that does some tansformation of language codes
# 	@grep -H BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
# 	sed 's#^${WORKDIR}/\(.*\)\.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}\.\(.*\)\.eval:.*$$#\1.\2#' | \
# 	perl -pe 'if (/\.([^\.]+)\.([^\.\s]+)$$/){$$s=$$1;$$t=$$2;s/[\-\.]$$s?\-?$$t\.$$s\.$$t?$$/.$$s.$$t/;s/\.$$s\.$$t$$/.$$s-$$t/}' > $@.1
# 	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
# 	cut -f3 -d ' ' > $@.2
# 	@grep chrF ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
# 	cut -f3 -d ' ' > $@.3
# 	@ls ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
# 	sed 's/\.eval//' | xargs wc -l | grep -v total | sed 's/^ *//' | cut -f1 -d' ' > $@.4
# 	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
# 	cut -f16 -d ' ' | sed 's/)//' > $@.5
# 	@grep BLEU ${WORKDIR}/*.${DATASET}.${PRE_SRC}-${PRE_TRG}${NR}.${MODELTYPE}.*.eval | \
# 	cut -f7 -d ' ' > $@.6
# 	@paste -d '/' $@.4 $@.5                                      > $@.7
# 	@echo '| testset | BLEU  | chr-F | #sent | #words | BP |'   >> ${WORKDIR}/README.md
# 	@echo '|---------|-------|-------|-------|--------|----|'   >> ${WORKDIR}/README.md
# 	@paste $@.1 $@.2 $@.3 $@.4 $@.5 $@.6 | \
# 	sed  "s/\t/ 	| /g;s/^/| /;s/$$/ |/" | \
# 	sort | uniq                                                 >> ${WORKDIR}/README.md
# 	@echo "test-data:"                                          >> ${@:.zip=}-${DATE}.yml
# 	@paste -d' ' $@.1 $@.7 | sed 's/ /: /;s/^/   - /;'          >> ${@:.zip=}-${DATE}.yml
# 	@echo "BLEU-scores:"                                        >> ${@:.zip=}-${DATE}.yml
# 	@paste -d' ' $@.1 $@.2 | sed 's/ /: /;s/^/   - /'           >> ${@:.zip=}-${DATE}.yml
# 	@echo "chr-F-scores:"                                       >> ${@:.zip=}-${DATE}.yml
# 	@paste -d' ' $@.1 $@.3 | sed 's/ /: /;s/^/   - /'           >> ${@:.zip=}-${DATE}.yml
# 	@rm -f $@.1 $@.2 $@.3 $@.4 $@.5 $@.6 $@.7 $@.testsize $@.testset
# endif
# ##-----------------------------
# ## create the package
# ##-----------------------------
# 	@cat ${WORKDIR}/README.md                           >> ${dir $@}README.md
# 	@echo ''                                            >> ${dir $@}README.md
# 	@cp models/LICENSE ${WORKDIR}/
# 	@chmod +x ${WORKDIR}/preprocess.sh
# 	@sed -e 's# - .*/\([^/]*\)$$# - \1#' \
# 	     -e 's/beam-size: [0-9]*$$/beam-size: 6/' \
# 	     -e 's/mini-batch: [0-9]*$$/mini-batch: 1/' \
# 	     -e 's/maxi-batch: [0-9]*$$/maxi-batch: 1/' \
# 	     -e 's/relative-paths: false/relative-paths: true/' \
# 	< ${MODEL_DECODER} > ${WORKDIR}/decoder.yml
# 	cd ${WORKDIR} && zip ${notdir $@} \
# 		README.md LICENSE \
# 		${notdir ${MODEL_FINAL}} \
# 		${notdir ${MODEL_SRCVOCAB}} \
# 		${notdir ${MODEL_TRGVOCAB}} \
# 		${notdir ${MODEL_VALIDLOG}} \
# 		${notdir ${MODEL_TRAINLOG}} \
# 		source.* target.* decoder.yml \
# 		preprocess.sh postprocess.sh
# ifneq ("$(wildcard ${WORKDIR}/${MODELCONFIG})","")
# 	@cd ${WORKDIR} && zip -u ${notdir $@} ${MODELCONFIG}
# endif
# ##-----------------------------
# ## move files to release dir and cleanup
# ##-----------------------------
# 	@mkdir -p ${dir $@}
# 	@mv -f ${WORKDIR}/${notdir $@} ${@:.zip=}-${DATE}.zip
# 	@cd ${dir $@} && zip -u ${notdir ${@:.zip=}-${DATE}.zip} ${notdir ${@:.zip=}-${DATE}.yml}
# ifneq ("$(wildcard ${TEST_EVALUATION})","")
# 	@cp $(TEST_EVALUATION) ${@:.zip=}-${DATE}.eval.txt
# 	@cp $(TEST_COMPARISON) ${@:.zip=}-${DATE}.test.txt
# endif
# 	@rm -f $@
# 	@cd ${dir $@} && ln -s $(notdir ${@:.zip=})-${DATE}.zip ${notdir $@}
# 	@rm -f ${WORKDIR}/decoder.yml ${WORKDIR}/source.* ${WORKDIR}/target.*
# 	@rm -f ${WORKDIR}/preprocess.sh ${WORKDIR}/postprocess.sh












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
	find ${RELEASEDIR}/ -type l | tar -cf models-links.tar -T -
	find ${RELEASEDIR}/ -type l -delete
	cd ${RELEASEDIR} && swift upload ${MODEL_CONTAINER} --changed --skip-identical *
	tar -xf models-links.tar
	rm -f models-links.tar
	swift post ${MODEL_CONTAINER} --read-acl ".r:*"
	swift list ${MODEL_CONTAINER} > index.txt
	swift upload ${MODEL_CONTAINER} index.txt
	rm -f index.txt


.PHONY: upload-models
upload-models:
	find ${MODELSHOME} -type l | tar -cf dev-models-links.tar -T -
	find ${MODELSHOME} -type l -delete
	cd ${WORKHOME} && swift upload ${DEV_MODEL_CONTAINER} --changed --skip-identical models
	tar -xf dev-models-links.tar
	rm -f dev-models-links.tar
	swift post ${DEV_MODEL_CONTAINER} --read-acl ".r:*"
	swift list ${DEV_MODEL_CONTAINER} > index.txt
	swift upload ${DEV_MODEL_CONTAINER} index.txt
	rm -f index.txt

.PHONY:
fetch-model:
	mkdir -p ${RELEASEDIR}/${LANGPAIRSTR}
	cd ${RELEASEDIR}/${LANGPAIRSTR} && \
	wget ${OBJECTSTORAGE}/${MODEL_CONTAINER}/${firstword ${call get-model-release,${LANGPAIRSTR}}}

#	wget -O ${RELEASEDIR}/${LANGPAIRSTR}/${LANGPAIRSTR}.zip \
#	${OBJECTSTORAGE}/${MODEL_CONTAINER}/${firstword ${call get-model-dist,${LANGPAIRSTR}}}
#	cd ${RELEASEDIR}/${LANGPAIRSTR} && unzip -n ${LANGPAIRSTR}.zip
#	rm -f ${RELEASEDIR}/${LANGPAIRSTR}/${LANGPAIRSTR}.zip

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


${EVALSCORES}: # ${WORKHOME}/eval/%.eval.txt: ${MODELSHOME}/%.eval
	mkdir -p ${dir $@}
	cp ${patsubst ${WORKHOME}/eval/%.eval.txt,${WORKHOME}/%.eval,$@} $@
#	cp $< $@

${EVALTRANSL}: # ${WORKHOME}/eval/%.test.txt: ${MODELSHOME}/%.compare
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
	          MODELSHOME=${MODELSHOME} dist; \
	done
	@echo "trained double ${words ${TRAINED_DOUBLE_MODELS}}"
	for l in ${TRAINED_DOUBLE_MODELS}; do \
	  n=`grep 'new best' work/$$l/*.valid1.log | tail -1 | cut -f12 -d ' '`; \
	  o=`grep 'new best' work/old-models/$$l/*.valid1.log | tail -1 | cut -f12 -d ' '`; \
	  if (( $$(echo "$$o < $$n" |bc -l) )); then \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" \
	            WORKHOME=${WORKHOME}/old-models \
	            MODELSHOME=${MODELSHOME} dist; \
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
MODEL_OLD_VOCAB     = ${WORKDIR}/${MODEL_OLD}.vocab.yml
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



create-yaml:
	for d in `find ${RELEASEDIR} -maxdepth 1 -mindepth 1 -type d`; do \
	    scripts/readme2yaml.pl $$d; \
	done


remove-underperforming:
	for d in `find ${RELEASEDIR}/ -type f -name '*.zip'`; do \
	  b=`echo $$d | sed 's/\.zip//'`; \
	  l=`echo $$b | sed 's#^${RELEASEDIR}/##' | xargs dirname`; \
	  f=`basename $$b`; \
	  if  [ `grep BLEU $$b.eval.txt | cut -f3 -d ' ' | cut -f1 -d '.'` -lt ${MIN_BLEU_SCORE} ]; then \
	    echo "remove $$d;"; \
	    swift delete ${MODEL_CONTAINER} $$l/$$f.zip; \
	    swift delete ${MODEL_CONTAINER} $$l/$$f.eval.txt; \
	    swift delete ${MODEL_CONTAINER} $$l/$$f.test.txt; \
	    swift delete ${MODEL_CONTAINER} $$l/$$f.yml; \
	    rm -f $$b.zip; \
	    rm -f $$b.eval.txt; \
	    rm -f $$b.test.txt; \
	    rm -f $$b.yml; \
	  else \
	    echo "keep $$d"; \
	  fi \
	done
