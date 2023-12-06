# -*-makefile-*-
#
# generic implic targets that make our life a bit easier





unidirectional:
	${MAKE} data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train.submit-multigpu

bilingual:
	${MAKE} data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} reverse-data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		train.submit-multigpu

bilingual-big:
	${MAKE} data
	${MAKE} WALLTIME=72 HPC_MEM=8g HPC_CORES=1 train.submit-multigpu
	${MAKE} reverse-data
	${MAKE} WALLTIME=72 HPC_MEM=8g HPC_CORES=1 SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		train.submit-multigpu

bilingual-medium:
	${MAKE} data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 \
		MARIAN_VALID_FREQ=5000 MARIAN_WORKSPACE=10000 train.submit
	${MAKE} reverse-data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		MARIAN_VALID_FREQ=5000 MARIAN_WORKSPACE=10000 train.submit

bilingual-small:
	${MAKE} data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 \
		MARIAN_WORKSPACE=5000 MARIAN_VALID_FREQ=2500 train.submit
	${MAKE} reverse-data
	${MAKE} WALLTIME=72 HPC_MEM=4g HPC_CORES=1 SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		MARIAN_WORKSPACE=5000 MARIAN_VALID_FREQ=2500 train.submit



multilingual:
	${MAKE} SRCLANGS="${LANGS}" TRGLANGS="${LANGS}" data
	${MAKE} SRCLANGS="${LANGS}" TRGLANGS="${LANGS}" \
		WALLTIME=72 HPC_CORES=1 HPC_MEM=4g train.submit-multigpu

multilingual-big:
	${MAKE} SRCLANGS="${LANGS}" TRGLANGS="${LANGS}" data
	${MAKE} SRCLANGS="${LANGS}" TRGLANGS="${LANGS}" \
		WALLTIME=72 HPC_CORES=1 HPC_MEM=8g train.submit-multigpu

multilingual-medium:
	${MAKE} SRCLANGS="${LANGS}" TRGLANGS="${LANGS}" data
	${MAKE} SRCLANGS="${LANGS}" TRGLANGS="${LANGS}" \
		MARIAN_VALID_FREQ=5000 MARIAN_WORKSPACE=10000 \
		WALLTIME=72 HPC_CORES=1 HPC_MEM=4g train.submit-multigpu


all2pivot:
	for l in ${filter-out ${PIVOT},${LANGS}}; do \
	  ${MAKE} SRCLANGS="$$l" TRGLANGS="${PIVOT}" data; \
	  ${MAKE} SRCLANGS="$$l" TRGLANGS="${PIVOT}" HPC_CORES=1 HPC_MEM=4g train.submit-multigpu; \
	  ${MAKE} SRCLANGS="$$l" TRGLANGS="${PIVOT}" reverse-data; \
	  ${MAKE} SRCLANGS="${PIVOT}" TRGLANGS="$$l" HPC_CORES=1 HPC_MEM=4g train.submit-multigpu; \
	done



## submit train jobs with settings that depend on the size of the training data
## --> change WORKSPACE, MEM, nr of GPUs, validation frequency, stopping criterion

train-dynamic:
	if [ ! -e "${WORKHOME}/${LANGPAIRSTR}/train.submit" ]; then \
	  ${MAKE} data; \
	  s=`${ZCAT} ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz | head -10000001 | wc -l`; \
	  if [ $$s -gt 10000000 ]; then \
	    echo "${LANGPAIRSTR} bigger than 10 million"; \
	    ${MAKE} HPC_CORES=1 HPC_MEM=8g train.submit-multigpu; \
	  elif [ $$s -gt 1000000 ]; then \
	    echo "${LANGPAIRSTR} bigger than 1 million"; \
	    ${MAKE} \
	    	MARIAN_VALID_FREQ=2500 \
	    	HPC_CORES=1 HPC_MEM=8g train.submit; \
	  elif [ $$s -gt 100000 ]; then \
	    echo "${LANGPAIRSTR} bigger than 100k"; \
	    ${MAKE} \
	    	MARIAN_VALID_FREQ=1000 \
	    	MARIAN_WORKSPACE=5000 \
	    	MARIAN_VALID_MINI_BATCH=8 \
	    	HPC_CORES=1 HPC_MEM=4g train.submit; \
	  elif [ $$s -gt 10000 ]; then \
	    echo "${LANGPAIRSTR} bigger than 10k"; \
	    ${MAKE} \
	    	MARIAN_WORKSPACE=3500 \
	    	MARIAN_VALID_MINI_BATCH=4 \
	    	MARIAN_DROPOUT=0.5 \
	    	MARIAN_VALID_FREQ=1000 \
	    	HPC_CORES=1 HPC_MEM=4g train.submit; \
	  else \
	    echo "${LANGPAIRSTR} too small"; \
	  fi \
	fi

#	    	MARIAN_EARLY_STOPPING=5 \


bilingual-dynamic: train-dynamic
	if [ "${SRCLANGS}" != "${TRGLANGS}" ]; then \
	  ${MAKE} reverse-data; \
	  ${MAKE} TRGLANGS="${SRCLANGS}" SRCLANGS='${TRGLANGS}' train-dynamic; \
	fi





test-skip:
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	      echo "skip $$s-$$t"; \
	    fi \
	  done \
	done







## extension -all-langpairs: run something over all language pairs, e.g.
##   make wordalign-all-langpairs
## this goes sequentially over all language pairs
## for the parallelizable version of this: look at %-all-parallel
%-all-langpairs:
	for l in ${ALL_LANG_PAIRS}; do \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" ${@:-all-langpairs=}; \
	done

# run something over all language pairs that have trained models
## - make eval-allmodels
## - make dist-allmodels
%-allmodels:
	for l in ${ALL_LANG_PAIRS}; do \
	  m=`find ${WORKHOME}/$$l -maxdepth 1 -name '*.best-perplexity.npz' -printf "%f\n"`; \
	  for i in $$m; do \
	    s=`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`; \
	    t=`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`; \
	    d=`echo $$i | cut -f1 -d.`; \
	    x=`echo $$i | cut -f2 -d. | cut -f1 -d-`; \
	    y=`echo $$i | cut -f2 -d. | cut -f2 -d-`; \
	    v=`echo $$i | cut -f3 -d.`; \
	    echo "model    = $$i"; \
	    echo "dataset  = $$d"; \
	    echo "src-lang = $$s"; \
	    echo "trg-lang = $$t"; \
	    echo "pre-src  = $$x"; \
	    echo "pre-trg  = $$y"; \
	    echo "type     = $$v"; \
	    ${MAKE} \
		SRCLANGS="$$s" TRGLANGS="$$t" \
		DATASET=$$d \
		PRE_SRC=$$x PRE_TRG=$$y \
		MODELTYPE=$$v ${@:-allmodels=}; \
	  done \
	done

## OLD: doesn't work for different model variants
##
# %-allmodels:
# 	for l in ${ALL_LANG_PAIRS}; do \
# 	  if  [ `find ${WORKHOME}/$$l -name '*.${PRE_SRC}-${PRE_TRG}.*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
# 	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
# 		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" ${@:-allmodels=}; \
# 	  fi \
# 	done


listallmodels:
	@m=`find ${WORKDIR} -maxdepth 1 -name '*.best-perplexity.npz' -printf "%f\n"`; \
	for i in $$m; do \
	  d=`echo $$i | cut -f1 -d.`; \
	  s=`echo $$i | cut -f2 -d. | cut -f1 -d-`; \
	  t=`echo $$i | cut -f2 -d. | cut -f1 -d-`; \
	  v=`echo $$i | cut -f3 -d.`; \
	  echo "model   = $$i"; \
	  echo "dataset = $$d"; \
	  echo "pre-src = $$s"; \
	  echo "pre-trg = $$t"; \
	  echo "type    = $$v"; \
	done



## only bilingual models
%-allbilingual:
	for l in ${ALL_BILINGUAL_MODELS}; do \
	  if  [ `find ${WORKHOME}/$$l -name '*.${PRE_SRC}-${PRE_TRG}.*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" ${@:-allbilingual=}; \
	  fi \
	done

## only bilingual models
%-allmultilingual:
	for l in ${ALL_MULTILINGUAL_MODELS}; do \
	  if  [ `find ${WORKHOME}/$$l -name '*.${PRE_SRC}-${PRE_TRG}.*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" ${@:-allmultilingual=}; \
	  fi \
	done


## run something over all language pairs but make it possible to do it in parallel, for example
## - make dist-all-parallel
%-all-parallel:
	${MAKE} $(subst -all-parallel,,${patsubst %,$@__%-run-for-langpair,${ALL_LANG_PAIRS}})

## run a command that includes the langpair, for example
##   make wordalign__en-da+sv-run-for-langpair  ...... runs wordalign with SRCLANGS="en" TRGLANGS="da sv"
## What is this good for?
## ---> can run many lang-pairs in parallel instead of having a for loop and run sequencetially
%-run-for-langpair:
	${MAKE} SRCLANGS='$(subst +, ,$(firstword $(subst -, ,${lastword ${subst __, ,${@:-run-for-langpair=}}})))' \
		TRGLANGS='$(subst +, ,$(lastword $(subst -, ,${lastword ${subst __, ,${@:-run-for-langpair=}}})))' \
	${shell echo $@ | sed 's/__.*$$//'}


## right-to-left model
%-RL:
	${MAKE} MODEL=${MODEL}-RL \
		MARIAN_EXTRA="${MARIAN_EXTRA} --right-left" \
	${@:-RL=}



## include all backtranslation data as well in training

%-bt:
	${MAKE} DATASET=${DATASET}+bt USE_BACKTRANS=1 SHUFFLE_TRAINING_DATA=1 ${@:-bt=}


## include additional bitexts
%-xb:
	${MAKE} DATASET=${DATASET}+xb USE_EXTRA_BITEXTS=1 SHUFFLE_TRAINING_DATA=1 ${@:-xb=}



## adding a pivot language to the model
## --> add pivot language to each side (source and target)
## --> only start the task if the pivot language adds anything on either side
## --> make a new fresh vocabulary (don't copy an existing one)
## --> make a new BPE/sentencepiece model
## --> make a new config file

DEFAULT_PIVOT_LANG ?= en
PIVOT_LANG         ?= ${DEFAULT_PIVOT_LANG}

%-pivotlang:
	if [ "$(sort ${SRCLANGS} ${TRGLANGS} ${PIVOT_LANG})" != "$(sort ${SRCLANGS} ${TRGLANGS})" ]; then \
	  ${MAKE} DATASET=${DATASET}+${PIVOT_LANG} \
		SRCLANGS="$(sort ${SRCLANGS} ${PIVOT_LANG})" \
		TRGLANGS="$(sort ${TRGLANGS} ${PIVOT_LANG})" \
		SKIP_LANGPAIRS=${PIVOT_LANG}-${PIVOT_LANG} \
		MODEL_LATEST_VOCAB= \
		PIVOT=${PIVOT_LANG} \
		SUBWORD_MODEL_NAME=opus+${PIVOT_LANG} \
	  ${@:-pivotlang=}; \
	fi


## add forward translations

%-ft:
	${MAKE} DATASET=${DATASET}+ft USE_FORWARDTRANS=1 SHUFFLE_TRAINING_DATA=1 ${@:-ft=}

# use a selected set of forward translation
# TODO: only call the translation extraction recipe if there is no file that matches
#       the extension of that kind of extraction type (e.g. *.best95.gz)
#       --> this can go wrong

# default for ce-filter
FT_SELECTED ?= 95

%-ftbest:
	@-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ -e ${FORWARDTRANS_HOME}/$$s-$$t/latest ]; then \
	      if [ `ls ${FORWARDTRANS_HOME}/$$s-$$t/latest/ | grep "best${FT_SELECTED}.gz" | wc -l` -eq 0 ]; then \
	        echo "... extract best translations from $$s-$$t forward translations"; \
	        ${MAKE} -C ${FORWARDTRANS_HOME} SRC=$$s TRG=$$t \
			RETAIN=${FT_SELECTED} extract-best-translations; \
	      fi \
	    fi \
	  done \
	done
	${MAKE} DATASET=${DATASET}+ft${FT_SELECTED} \
		USE_FORWARDTRANS_SELECTED=${FT_SELECTED} \
		SHUFFLE_TRAINING_DATA=1 \
	${@:-ftbest=}

%-ftrawbest:
	@-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ -e ${FORWARDTRANS_HOME}/$$s-$$t/latest ]; then \
	      ${MAKE} -C ${FORWARDTRANS_HOME} SRC=$$s TRG=$$t \
			RETAIN=${FT_SELECTED} extract-rawbest-translations; \
	    fi \
	  done \
	done
	${MAKE} DATASET=${DATASET}+ftraw${FT_SELECTED} \
		USE_FORWARDTRANS_SELECTED_RAW=${FT_SELECTED} \
		SHUFFLE_TRAINING_DATA=1 \
	${@:-ftrawbest=}


## add forward translation of monolingual data
%-ftmono:
	${MAKE} DATASET=${DATASET}+ftmono USE_FORWARDTRANSMONO=1 SHUFFLE_TRAINING_DATA=1 ${@:-ftmono=}

## pivot-based backward translation
%-pbt:
	${MAKE} DATASET=${DATASET}+pbt USE_BACKWARD_PIVOTING=1 SHUFFLE_TRAINING_DATA=1 ${@:-pbt=}

## pivot-based backward translation
%-pft:
	${MAKE} DATASET=${DATASET}+pft USE_FORWARD_PIVOTING=1 SHUFFLE_TRAINING_DATA=1 ${@:-pft=}

## pivot-based backward translation
%-pivot:
	${MAKE} DATASET=${DATASET}+pivot USE_PIVOTING=1 ${@:-pivot=}

## don't use the regular parallel training data
## (only makes sense if bt, ft, or pivot-based data are activated)
%-nopar:
	${MAKE} DATASET=${DATASET}+nopar TRAINSET= ${@:-nopar=}

# TATOEBA_TRAINSET=

##-------------------------------------------------------------
## default: make separate sentencepiece models
## but create a joint vocabulary for training with
## tied embeddings
## alternatives:
## * joint-spm: create a joint sentencepiece model
## * separate-spm: create separate SPMs and use them directly
##-------------------------------------------------------------

## joint sentencepiece model and joint vocabulary
%-joint-spm:
	${MAKE} USE_JOINT_SUBWORD_MODEL=1 USE_SPM_VOCAB=1 MODEL_VARIANT=-jointvoc ${@:-joint-spm=}

## use sentenceopiece models directly as separate vocabularies
%-separate-spm:
	${MAKE} USE_SPM_VOCAB=1 MODEL_VARIANT=-sepvoc ${@:-separate-spm=}


PRETRAINED_SPM_SRC = ${wildcard ${RELEASEDIR}/spm/*/opusTC.$(firstword $(subst -, ,${LANGPAIRSTR})).${SUBWORD_SRCVOCAB_SIZE:000=}k.spm}
PRETRAINED_SPM_TRG = ${wildcard ${RELEASEDIR}/spm/*/opusTC.$(lastword $(subst -, ,${LANGPAIRSTR})).${SUBWORD_TRGVOCAB_SIZE:000=}k.spm}

%-pretrained-spm:
ifneq ($(wildcard $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMSRCMODEL})),)
ifneq (${PRETRAINED_SPM_SRC},)
	@echo "copy ${PRETRAINED_SPM_SRC}"
	mkdir -p $(dir $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMSRCMODEL}))
	cp ${PRETRAINED_SPM_SRC} $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMSRCMODEL})
	cp ${PRETRAINED_SPM_SRC}.vocab $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMSRCMODEL}).vocab
endif
endif
ifneq ($(wildcard $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMTRGMODEL})),)
ifneq (${PRETRAINED_SPM_TRG},)
	@echo "copy ${PRETRAINED_SPM_TRG}"
	mkdir -p $(dir $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMTRGMODEL}))
	cp ${PRETRAINED_SPM_TRG} $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMTRGMODEL})
	cp ${PRETRAINED_SPM_TRG}.vocab $(subst ${WORKHOME},${WORKHOME}-prespm,${SPMTRGMODEL}).vocab
endif
endif
	${MAKE} WORKHOME=${WORKHOME}-prespm ${@:-pretrained-spm=}





## for compatibility reasons: train on forward translated data and no regular train data
%-ftonly:
	${MAKE} DATASET=${DATASET}+ftonly \
		USE_FORWARDTRANS=1 \
		CONTINUE_EXISTING=1 \
		MARIAN_EARLY_STOPPING=${FT_MARIAN_EARLY_STOPPING} \
		TRAINSET= \
	${@:-ftonly=}

# TATOEBA_TRAINSET= \
#		MODELCONFIG=config-ft.mk \



%-big-align:
	${MAKE} MODELTYPE=transformer-big-align ${@:-big-align=}



## run a multigpu job (2 or 4 GPUs)

%-multigpu %-gpu0123:
	${MAKE} NR_GPUS=4 MARIAN_GPUS='0 1 2 3' $(subst -gpu0123,,${@:-multigpu=})

%-twogpu %-gpu01:
	${MAKE} NR_GPUS=2 MARIAN_GPUS='0 1' $(subst -gpu01,,${@:-twogpu=})

%-gpu23:
	${MAKE} NR_GPUS=2 MARIAN_GPUS='2 3' ${@:-gpu23=}

%-gpu8:
	${MAKE} NR_GPUS=8 MARIAN_GPUS='0 1 2 3 4 5 6 7' $(subst -gpu8,,$@)


## document level models
## devtest data should not be shuffled
%-doc:
	${MAKE} PRE_SRC=${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE} \
		PRE_TRG=${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE} \
		SHUFFLE_DEVDATA=0 \
	${@:-doc=}


## sentence-piece models
%-spm:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-spm} \
		PRE=simple SUBWORDS=spm \
	${@:-spm=}

## sentence-piece models with space-separated strings
%-nospace:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-nospace} \
		PRE=simple \
		SPMEXTRA=--split_by_whitespace=false \
	${@:-nospace=}


## with SPM models trained on monolingual data
%-monospm: ${SPMSRCMONO} ${SPMTRGMONO}
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-monospm} \
		SPMSRCMODEL=${SPMSRCMONO} \
		SPMTRGMODEL=${SPMTRGMONO} \
	${@:-monospm=}



## BPE models
%-bpe:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-bpe} \
		PRE=tok SUBWORDS=bpe \
		MODELTYPE=transformer \
	${@:-bpe=}






# ## sentence-piece models with langid-filtering (new default)
# %-langid:
# 	${MAKE} WORKHOME=${shell realpath ${PWD}/work-langid} \
# 		PRE=simple \
# 	${@:-langid=}


# %-bpe-memad:
# 	${MAKE} WORKHOME=${shell realpath ${PWD}/work-bpe-memad} \
# 		PRE=tok SUBWORDS=bpe \
# 		MODELTYPE=transformer \
# 	${@:-bpe-memad=}


## NEW: don't continue from existing models when including pivot data
## TODO: should we do that?
#
# PIVOT_MODEL       = ${MODEL_SUBDIR}${DATASET}+pivot${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}
# PIVOT_MODEL_BASE  = ${PIVOT_MODEL}.${MODELTYPE}.model${NR}
# PIVOT_MODEL_START = ${WORKDIR}/${PIVOT_MODEL_BASE}.npz
# PIVOT_MODEL_VOCAB = ${WORKDIR}/${PIVOT_MODEL}.vocab.yml

# %-pivot:
# ifneq (${wildcard ${MODEL_FINAL}},)
# ifeq (${wildcard ${PIVOT_MODEL_START}},)
# 	cp ${MODEL_FINAL} ${PIVOT_MODEL_START}
# 	cp ${MODEL_VOCAB} ${PIVOT_MODEL_VOCAB}
# endif
# endif
# 	rm -f ${WORKHOME}/${LANGPAIRSTR}/train.submit
# 	${MAKE} DATASET=${DATASET}+pivot \
# 		USE_PIVOTING=1 \
# 		CONTINUE_EXISTING=1 \
# 		MARIAN_EARLY_STOPPING=10 \
# 	${@:-pivot=}


# OLD: start with parameters from the standard transformer model
# NOW: big-align is not compatible with the dimensions settings anymore
#
# %-big-align:
# ifneq (${wildcard ${MODEL_FINAL}},)
# 	${MAKE} PRE_TRAINED_MODEL=${MODEL_FINAL} MODELTYPE=transformer-big-align ${@:-big-align=}
# else ifneq (${wildcard ${MODEL_START}},)
# 	${MAKE} PRE_TRAINED_MODEL=${MODEL_START} MODELTYPE=transformer-big-align ${@:-big-align=}
# else
# 	${MAKE} MODELTYPE=transformer-big-align ${@:-big-align=}
# endif
