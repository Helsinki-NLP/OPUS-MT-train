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







## extension -all: run something over all language pairs, e.g.
##   make wordalign-all
## this goes sequentially over all language pairs
## for the parallelizable version of this: look at %-all-parallel
%-all:
	for l in ${ALL_LANG_PAIRS}; do \
	    ${MAKE} SRCLANGS="`echo $$l | cut -f1 -d'-' | sed 's/\\+/ /g'`" \
		    TRGLANGS="`echo $$l | cut -f2 -d'-' | sed 's/\\+/ /g'`" ${@:-all=}; \
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
## start from the pre-trained opus model if it exists

BT_MODEL       = ${MODEL_SUBDIR}${DATASET}+bt${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}
BT_MODEL_BASE  = ${BT_MODEL}.${MODELTYPE}.model${NR}
BT_MODEL_START = ${WORKDIR}/${BT_MODEL_BASE}.npz
BT_MODEL_VOCAB = ${WORKDIR}/${BT_MODEL}.vocab.yml

BT_MARIAN_EARLY_STOPPING = 15


# %-add-backtranslations:
%-bt:
ifneq (${wildcard ${MODEL_FINAL}},)
ifeq (${wildcard ${BT_MODEL_START}},)
	cp ${MODEL_FINAL} ${BT_MODEL_START}
	cp ${MODEL_VOCAB} ${BT_MODEL_VOCAB}
endif
endif
	rm -f ${WORKHOME}/${LANGPAIRSTR}/train.submit
	${MAKE} DATASET=${DATASET}+bt \
		USE_BACKTRANS=1 \
		CONTINUE_EXISTING=1 \
		MODELCONFIG=config-bt.mk \
		MARIAN_EARLY_STOPPING=${BT_MARIAN_EARLY_STOPPING} \
	${@:-bt=}

#		CLEAN_TRAIN_SRC="${CLEAN_TRAIN_SRC} ${BACKTRANS_SRC}" \
#		CLEAN_TRAIN_TRG="${CLEAN_TRAIN_TRG} ${BACKTRANS_TRG}" \



PIVOT_MODEL       = ${MODEL_SUBDIR}${DATASET}+pivot${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}
PIVOT_MODEL_BASE  = ${PIVOT_MODEL}.${MODELTYPE}.model${NR}
PIVOT_MODEL_START = ${WORKDIR}/${PIVOT_MODEL_BASE}.npz
PIVOT_MODEL_VOCAB = ${WORKDIR}/${PIVOT_MODEL}.vocab.yml

%-pivot:
ifneq (${wildcard ${MODEL_FINAL}},)
ifeq (${wildcard ${PIVOT_MODEL_START}},)
	cp ${MODEL_FINAL} ${PIVOT_MODEL_START}
	cp ${MODEL_VOCAB} ${PIVOT_MODEL_VOCAB}
endif
endif
	rm -f ${WORKHOME}/${LANGPAIRSTR}/train.submit
	${MAKE} DATASET=${DATASET}+pivot \
		USE_PIVOTING=1 \
		CONTINUE_EXISTING=1 \
		MARIAN_EARLY_STOPPING=10 \
	${@:-pivot=}




## run a multigpu job (2 or 4 GPUs)

%-multigpu %-gpu0123:
	${MAKE} NR_GPUS=4 MARIAN_GPUS='0 1 2 3' $(subst -gpu0123,,${@:-multigpu=})

%-twogpu %-gpu01:
	${MAKE} NR_GPUS=2 MARIAN_GPUS='0 1' $(subst -gpu01,,${@:-twogpu=})

%-gpu23:
	${MAKE} NR_GPUS=2 MARIAN_GPUS='2 3' ${@:-gpu23=}


## run on CPUs (translate-cpu, eval-cpu, translate-ensemble-cpu, ...)
%-cpu:
	${MAKE} LOADMODS='${LOADCPU}' \
		MARIAN_DECODER_FLAGS="${MARIAN_DECODER_CPU}" \
	${@:-cpu=}


## document level models
## devtest data should not be shuffled
%-doc:
	${MAKE} PRE_SRC=spm${SRCBPESIZE:000=}k.doc${CONTEXT_SIZE} \
		PRE_TRG=spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE} \
		SHUFFLE_DEVDATA=0 \
	${@:-doc=}


## sentence-piece models
%-spm:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-spm} \
		PRE=norm SUBWORDS=spm \
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


%-spm-noalign:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-spm-noalign} \
		MODELTYPE=transformer \
		PRE=norm SUBWORDS=spm \
	${@:-spm-noalign=}


## sentence-piece models with langid-filtering (new default)
%-langid:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-langid} \
		PRE=simple \
	${@:-langid=}

## sentence-piece models with langid-filtering (new default)
%-langid-noalign:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-langid-noalign} \
		MODELTYPE=transformer \
		PRE=simple \
	${@:-langid-noalign=}



## BPE models
%-bpe:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-bpe} \
		PRE=tok SUBWORDS=bpe \
		MODELTYPE=transformer \
	${@:-bpe=}

%-bpe-align:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-bpe-align} \
		PRE=tok SUBWORDS=bpe \
	${@:-bpe-align=}

%-bpe-memad:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-bpe-memad} \
		PRE=tok SUBWORDS=bpe \
		MODELTYPE=transformer \
	${@:-bpe-memad=}

%-bpe-old:
	${MAKE} WORKHOME=${shell realpath ${PWD}/work-bpe-old} \
		PRE=tok SUBWORDS=bpe \
		MODELTYPE=transformer \
	${@:-bpe-old=}




