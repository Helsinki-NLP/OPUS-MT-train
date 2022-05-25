# -*-makefile-*-



#------------------------------------------------------------------
# refreshing existing releases (useful to update information)
#------------------------------------------------------------------

## refresh yaml-file and readme of the latest released package
tatoeba-%-refresh: tatoeba-%-refresh-release-yml tatoeba-%-refresh-release-readme
	@echo "done!"

## refresh release readme with info from latest released model
tatoeba-%-refresh-release-readme:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-refresh-release-readme,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-refresh-release-readme,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-refresh-release-readme,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-refresh-release-readme,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		refresh-release-readme-tatoeba; \
	  fi )

## refresh yaml file of the latest release
tatoeba-%-refresh-release-yml:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-refresh-release-yml,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-refresh-release-yml,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-refresh-release-yml,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-refresh-release-yml,%,$@},${PIVOT}}" \
		refresh-release-yml-tatoeba; \
	  fi )

## refresh the entire release (create a new release with the old time stamp)
tatoeba-%-refresh-release: tatoeba-%-refresh-release-yml tatoeba-%-refresh-release-readme
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-refresh-release,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-refresh-release,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-refresh-release,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-refresh-release,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		refresh-release-tatoeba; \
	  fi )




###############################################################################
# auxiliary functions (REMOVE?)
###############################################################################



## does not work like this anymore I think ...

# %-bttatoeba: 	${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
# 		${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg
# 	for s in ${shell cat ${word 1,$^}}; do \
# 	  for t in ${shell cat ${word 2,$^}}; do \
# 	    echo "${MAKE} -C backtranslate \
# 		SRC=$$s TRG=$$t \
# 		WIKI_HOME=wiki-iso639-3 \
# 		WIKIDOC_HOME=wikidoc-iso639-3 \
# 		MODELHOME=${TATOEBA_MODELSHOME}/${SORTED_LANGPAIR} \
# 	    ${@:-bttatoeba=}"; \
# 	  done \
# 	done



##----------------------------------------------------------------------------
## TODO: we need some procedures to run evaluations
##       for already released models
##       the code below fails because of various dependencies etc ...
## --> moved evaluation to sub-dir eval!!!
##----------------------------------------------------------------------------

RELEASED_TATOEBA_MODEL = fiu-cpp/opus-2021-02-18.zip
RELEASED_TATOEBA_SRC2TRG = $(subst -,2,$(subst /,,$(dir ${RELEASED_TATOEBA_MODEL})))
RELEASED_TATOEBA_MODEL_URL = https://object.pouta.csc.fi/${TATOEBA_MODEL_CONTAINER}/${RELEASED_TATOEBA_MODEL}
EVAL_WORKHOMEHOME  = ${PWD}/work-eval
EVAL_WORKHOMEDIR   = ${EVAL_WORKHOMEHOME}/$(dir ${RELEASED_TATOEBA_MODEL})

evaluate-released-tatoeba-model:
	mkdir -p ${EVAL_WORKHOMEDIR}
	${WGET} -O ${EVAL_WORKHOMEHOME}/${RELEASED_TATOEBA_MODEL} ${RELEASED_TATOEBA_MODEL_URL}
	cd ${EVAL_WORKHOMEDIR} && unzip -o $(notdir ${RELEASED_TATOEBA_MODEL})
	${MAKE} WORKHOME=${EVAL_WORKHOMEHOME} \
		DECODER_CONFIG=${EVAL_WORKHOMEDIR}decoder.yml \
		MODEL_FINAL=`grep .npz ${EVAL_WORKHOMEDIR}decoder.yml | sed 's/^ *- *//'` \
		SPMSRCMODEL=${EVAL_WORKHOMEDIR}source.spm \
		SPMTRGMODEL=${EVAL_WORKHOMEDIR}target.spm \
	tatoeba-${RELEASED_TATOEBA_SRC2TRG}-testsets

##----------------------------------------------------------------------------


WRONGFILES = ${patsubst %.eval,%,${wildcard ${WORKHOME}/*/${TATOEBA_TESTSET}.opus*.eval}}

move-wrong:
	for f in ${WRONGFILES}; do \
	  s=`echo $$f | cut -f2 -d'/' | cut -f1 -d'-'`; \
	  t=`echo $$f | cut -f2 -d'/' | cut -f2 -d'-'`; \
	  c=`echo $$f | sed "s/align.*$$/align.$$s.$$t/"`; \
	  if [ "$$f" != "$$c" ]; then \
	    echo "fix $$f"; \
	    mv $$f $$c; \
	    mv $$f.compare $$c.compare; \
	    mv $$f.eval $$c.eval; \
	  fi \
	done



remove-old-groupeval:
	for g in ${OPUS_LANG_GROUPS}; do \
	  rm -f ${WORKHOME}/$$g-eng/${TATOEBA_TESTSET}.${TATOEBA_DATASET}.spm32k-spm32k1.transformer.???.eng*; \
	  rm -f ${WORKHOME}/eng-$$g/${TATOEBA_TESTSET}.${TATOEBA_DATASET}.spm32k-spm32k1.transformer.eng.???; \
	  rm -f ${WORKHOME}/eng-$$g/${TATOEBA_TESTSET}.${TATOEBA_DATASET}.spm32k-spm32k1.transformer.eng.???.*; \
	done


remove-old-group:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ -e ${WORKHOME}/$$g-eng ]; then mv ${WORKHOME}/$$g-eng ${WORKHOME}/$$g-eng-old3; fi; \
	  if [ -e ${WORKHOME}/eng-$$g ]; then mv ${WORKHOME}/eng-$$g ${WORKHOME}/eng-$$g-old3; fi; \
	done




## resume training for all bilingual models that are not yet converged
.PHONY: tatoeba-resume-all tatoeba-continue-all
tatoeba-resume-all tatoeba-continue-all:
	for l in `find ${WORKHOME}/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	      if [ -d ${WORKHOME}/$$l ]; then \
		if [ ! `find ${WORKHOME}/$$l/ -maxdepth 1 -name '*.done' | wc -l` -gt 0 ]; then \
		  if [ `find ${WORKHOME}/$$l/ -maxdepth 1 -name '*.npz' | wc -l` -gt 0 ]; then \
		    echo "resume ${WORKHOME}/$$l"; \
		    make SRCLANGS=$$s TRGLANGS=$$t all-job-tatoeba; \
		  else \
		    echo "resume ${WORKHOME}/$$l"; \
		    make SRCLANGS=$$s TRGLANGS=$$t tatoeba-job; \
		  fi \
		else \
		  echo "done ${WORKHOME}/$$l"; \
		fi \
	      fi \
	  fi \
	done


## make release package for all bilingual models that are converged
.PHONY: tatoeba-dist-all
tatoeba-dist-all:
	for l in `find ${WORKHOME}/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	      if [ -d ${WORKHOME}/$$l ]; then \
		if [ `find ${WORKHOME}/$$l/ -maxdepth 1 -name '*transformer-align.model1.done' | wc -l` -gt 0 ]; then \
		  echo "make release for ${WORKHOME}/$$l"; \
		  make SRCLANGS=$$s TRGLANGS=$$t MODELTYPE=transformer-align release-tatoeba; \
		fi; \
		if [ `find ${WORKHOME}/$$l/ -maxdepth 1 -name '*transformer.model1.done' | wc -l` -gt 0 ]; then \
		  echo "make release for ${WORKHOME}/$$l"; \
		  make SRCLANGS=$$s TRGLANGS=$$t MODELTYPE=transformer release-tatoeba; \
		fi; \
	      fi \
	  fi \
	done



fixlabels.sh:
	for l in `find ${WORKHOME}-old/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	    if [ -d ${WORKHOME}/$$l ]; then \
	      echo "# ${WORKHOME}/$$l exists --- skip it!" >> $@; \
	      echo "mv ${WORKHOME}-old/$$l ${WORKHOME}-double/$$l" >> $@; \
	    else \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-labels; \
	      o=`grep '*' ${WORKHOME}-old/$$l/train/README.md | cut -f1 -d: | grep '-' | sed 's/\* //g' | cut -f1 -d- | sort -u | tr "\n" ' '`; \
	      O=`grep '*' ${WORKHOME}-old/$$l/train/README.md | cut -f1 -d: | grep '-' | sed 's/\* //g' | cut -f2 -d- | sort -u | tr "\n" ' '`; \
	      n=`cat ${WORKHOME}/data/simple/${TATOEBA_TRAINSET}.$$l.clean.$$s.labels | tr ' ' "\n" | sort | grep . | tr "\n" ' '`; \
	      N=`cat ${WORKHOME}/data/simple/${TATOEBA_TRAINSET}.$$l.clean.$$t.labels | tr ' ' "\n" | sort | grep . | tr "\n" ' '`; \
	      if [ "$$o" != "$$n" ] || [ "$$O" != "$$N" ] ; then \
	        echo "# labels in $$l are different ($$o / $$O - $$n / $$N)" >> $@; \
	        if [ -d ${WORKHOME}-old/$$l ]; then \
		  if [ "$$n" != " " ] && [ "$$n" != "" ]; then \
		    if [ "$$N" != " " ] && [ "$$N" != "" ]; then \
	              echo "# re-run $$l from scratch!" >> $@; \
	              echo "${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-job" >> $@; \
		    fi \
		  fi \
	        fi; \
	      else \
	        if [ -d ${WORKHOME}-old/$$l ]; then \
	          echo "mv ${WORKHOME}-old/$$l ${WORKHOME}/$$l" >> $@; \
	        fi; \
	      fi; \
	    fi \
	  fi \
	done 


tatoeba-missing-test:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' | cut -f2 -d/`; do \
	  if [ ! -e ${WORKHOME}/$$d/test/${TATOEBA_TESTSET}.src ]; then \
	    if [ `find ${WORKHOME}/$$d/train -name '*-model' | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      echo "missing eval file for $$d"; \
	      mkdir -p ${WORKHOME}-tmp/$$d/train; \
	      rsync -av ${WORKHOME}/$$d/train/*model* ${WORKHOME}-tmp/$$d/train/; \
	      make FIT_DATA_SIZE=1000 LANGGROUP_FIT_DATA_SIZE=1000 WORKHOME=${WORKHOME}-tmp tatoeba-$$p-data; \
	      cp ${WORKHOME}-tmp/$$d/test/${TATOEBA_TESTSET}.* ${WORKHOME}/$$d/test/; \
	      rm -fr ${WORKHOME}-tmp/$$d; \
	    fi \
	  fi \
	done


tatoeba-touch-test:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' | cut -f2 -d/`; do \
	  if [ -e ${WORKHOME}/$$d/test/${TATOEBA_TESTSET}.src ]; then \
	    if [ -e ${WORKHOME}/$$d/val/${TATOEBA_DEVSET}.src ]; then \
	      touch -r ${WORKHOME}/$$d/val/${TATOEBA_DEVSET}.src ${WORKHOME}/$$d/test/${TATOEBA_TESTSET}.src*; \
	      touch -r ${WORKHOME}/$$d/val/${TATOEBA_DEVSET}.src ${WORKHOME}/$$d/test/${TATOEBA_TESTSET}.trg*; \
	    fi \
	  fi \
	done
