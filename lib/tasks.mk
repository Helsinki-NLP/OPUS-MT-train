# -*-makefile-*-
#
# recipes for specific tasks
#


include ${REPOHOME}lib/data.mk
include ${REPOHOME}lib/train.mk
include ${REPOHOME}lib/test.mk
include ${REPOHOME}lib/quantize.mk

include ${REPOHOME}lib/slurm.mk
include ${REPOHOME}lib/generic.mk
include ${REPOHOME}lib/misc.mk

include ${REPOHOME}lib/allas.mk
include ${REPOHOME}lib/dist.mk


#------------------------------------------------------------------------
# create a model-specific config file
#------------------------------------------------------------------------

.PHONY: config local-config
config local-config: ${WORKDIR}/${MODELCONFIG}

#------------------------------------------------------------------------
# make various data sets (and word alignment)
#------------------------------------------------------------------------

.PHONY: data
data:
ifneq (${SKIP_MAKE_RAWDATA},1)
	@${MAKE} rawdata
endif
	@${MAKE} local-config
	@${MAKE} traindata
	@${MAKE} devdata
	@${MAKE} testdata
	@${MAKE} vocab
ifeq ($(filter align,${subst -, ,${MODELTYPE}}),align)
	@${MAKE} wordalign
endif

traindata: 	${TRAINDATA_SRC} ${TRAINDATA_TRG}
testdata:	${TESTDATA_SRC} ${TESTDATA_TRG}
devdata:	${DEVDATA_SRC} ${DEVDATA_TRG}
devdata-raw:	${DEV_SRC} ${DEV_TRG}

wordalign:	${TRAIN_ALG}


## just report whether all necessary data sets exist
## --> usefule for the data-and-train-job recipe that
##     decides whether to start a CPU job for creating 
##     data first before starting a GPU job for training
data-done:
	if [ -e ${TESTDATA_SRC} ]; then \
	  if [ -e ${TESTDATA_TRG} ]; then \
	    if [ -e ${DEVDATA_SRC} ]; then \
	      if [ -e ${DEVDATA_TRG} ]; then \
	        if [ -e ${TRAINDATA_SRC} ]; then \
	          if [ -e ${TRAINDATA_TRG} ]; then \
	            if [ "$(filter align,${subst -, ,${MODELTYPE}})" == "align" ]; then \
	              if [ -e ${TRAIN_ALG} ]; then \
			echo "all data sets exist"; \
	              fi \
	            else \
			echo "all data sets exist"; \
	            fi \
	          fi \
	        fi \
	      fi \
	    fi \
	  fi \
	fi

data-needed:
	@echo ${TRAINDATA_SRC} ${TRAINDATA_TRG}
	@echo ${DEVDATA_SRC} ${DEVDATA_TRG}
	@echo ${TESTDATA_SRC} ${TESTDATA_TRG}
	@echo ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
ifeq ($(filter align,${subst -, ,${MODELTYPE}}),align)
	@echo ${TRAIN_ALG}
endif

#------------------------------------------------------------------------
# train, translate and evaluate
#------------------------------------------------------------------------

## define how may repetitions of slurm jobs we
## can submit in case a jobs times out or breaks
## SLURM_REPEAT     = current iteration
## SLURM_MAX_REPEAT = maximum number of iterations we allow

SLURM_REPEAT     ?= 0
SLURM_MAX_REPEAT ?= 10


# train the model - if this is a slurm job (i.e. SLURM_JOBID is set):
# - submit another one that continues training in case the current one breaks
# - only continue a certain number of times to avoid infinte loops
train: 
ifdef SLURM_JOBID
	if [ ${SLURM_REPEAT} -lt ${SLURM_MAX_REPEAT} ]; then \
	  echo "submit job that continues to train in case the current one breaks or times out"; \
	  echo "current iteration: ${SLURM_REPEAT}"; \
	  make 	SLURM_REPEAT=$$(( ${SLURM_REPEAT} + 1 )) \
		SBATCH_ARGS="-d afternotok:${SLURM_JOBID}" $@.submit${GPUJOB_SUBMIT}; \
	else \
	  echo "reached maximum number of repeated slurm jobs: ${SLURM_REPEAT}"; \
	fi
endif
	${MAKE} ${MODEL_DONE}

vocab: ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
translate: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}
eval: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.eval
compare: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare

## ensemble of models (assumes to find them in subdirs of the WORKDIR)
translate-ensemble: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}
eval-ensemble: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}.eval


## combined tasks:
## train and evaluate
train-and-eval: 
ifdef SLURM_JOBID
	if [ ${SLURM_REPEAT} -lt ${SLURM_MAX_REPEAT} ]; then \
	  echo "submit job that continues to train in case the current one breaks or times out"; \
	  echo "current iteration: ${SLURM_REPEAT}"; \
	  make 	SBATCH_ARGS="-d afternotok:${SLURM_JOBID}" \
		SLURM_REPEAT=$$(( ${SLURM_REPEAT} + 1 )) $@.submit${GPUJOB_SUBMIT}; \
	else \
	  echo "reached maximum number of repeated slurm jobs: ${SLURM_REPEAT}"; \
	fi
endif
	${MAKE} ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare
	${MAKE} eval-testsets

## train model and start back-translation jobs once the model is ready
## (requires to create a dist package)
## TODO: does this still work?
train-and-start-bt-jobs: 
ifdef SLURM_JOBID
	if [ ${SLURM_REPEAT} -lt ${SLURM_MAX_REPEAT} ]; then \
	  echo "submit job that continues to train in case the current one breaks or times out"; \
	  echo "current iteration: ${SLURM_REPEAT}"; \
	  make 	SBATCH_ARGS="-d afternotok:${SLURM_JOBID}" \
		SLURM_REPEAT=$$(( ${SLURM_REPEAT} + 1 )) $@.submit${GPUJOB_SUBMIT}; \
	else \
	  echo "reached maximum number of repeated slurm jobs: ${SLURM_REPEAT}"; \
	fi
endif
	${MAKE} ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare
	${MAKE} local-dist
	${MAKE} -C backtranslate MODELHOME=${MODELDIR} translate-all-wikis-jobs






#------------------------------------------------------------------------
# create slurm jobs
#------------------------------------------------------------------------

## copy different HPC params for jobs that need to wordalign data or not
ifeq ($(findstring align,${MODELTYPE}),align)
  DATAJOB_HPCPARAMS = ${DATA_ALIGN_HPCPARAMS}
  ALLJOB_HPCPARAMS = ${DATA_ALIGN_HPCPARAMS} ${TRAINJOB_HPCPARAMS}
else
  DATAJOB_HPCPARAMS = ${DATA_PREPARE_HPCPARAMS}
  ALLJOB_HPCPARAMS = ${DATA_PREPARE_HPCPARAMS} ${TRAINJOB_HPCPARAMS}
endif

# all-job:
#  - check whether data files exist
#  - if not: create a CPU job that makes the data and starts a training job after that
#  - if yes: create the GPU training job (after checking that data sets are alright)

.PHONY: all-job
all-job: 
	@if [ "`${MAKE} -s data-done 2>/dev/null | grep 'data sets'`" == "all data sets exist" ]; then \
	  echo "........ all data files exist already!"; \
	  echo "........ submit a job for training the model!"; \
	  ${MAKE} ${TRAINJOB_HPCPARAMS} train-and-eval.submit${GPUJOB_SUBMIT}; \
	else \
	  echo "........ submit a CPU job for making data files first!"; \
	  echo "........ submit training job later!"; \
	  ${MAKE} ${ALLJOB_HPCPARAMS} data-and-train-job.submitcpu; \
	fi


# data-and-train job:
#  - prepare data sets
#  - create/submit the training job
# if this is inside a slurm job:
#  --> immediately submit the training job
#      with a dependency on the current one
#  --> avoid to wait until we can queue the training job

.PHONY: data-and-train-job
data-and-train-job:
ifdef SLURM_JOBID
	echo "submit training job after data creation job (${SLURM_JOBID})"
	make ${TRAINJOB_HPCPARAMS} SBATCH_ARGS="-d afterok:${SLURM_JOBID}" train-and-eval.submit${GPUJOB_SUBMIT}
	${MAKE} data
else
	${MAKE} data
	${MAKE} ${TRAINJOB_HPCPARAMS} train-and-eval.submit${GPUJOB_SUBMIT}
endif


# train-job:
#  - create/submit a jobb for training only (no evaluation!)
.PHONY: train-job
train-job:
	${MAKE} ${TRAINJOB_HPCPARAMS} train.submit${GPUJOB_SUBMIT}

# train-and-eval-job:
#  - create/submit a jobb for training (+ evaluation)
.PHONY: train-and-eval-job
train-and-eval-job:
	${MAKE} ${TRAINJOB_HPCPARAMS} train-and-eval.submit${GPUJOB_SUBMIT}




#---------------------------------------------------------------------
# run everything including backtranslation of wiki-data
#
## TODO: need to refresh backtranslate/index.html from time to time!
## ---> necessary for fetching latest wikidump with the correct link
#---------------------------------------------------------------------

.PHONY: all-and-backtranslate
all-and-backtranslate: ${WORKDIR}/${MODELCONFIG}
	${MAKE} data
	${MAKE} train
	${MAKE} eval
	${MAKE} compare
	${MAKE} local-dist
	-for t in ${TRGLANGS}; do \
	  for s in ${SRCLANGS}; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} -C backtranslate \
		SRC=$$s TRG=$$t \
		MODELHOME=${MODELDIR} \
		MAX_SENTENCES=${shell zcat ${TRAINDATA_SRC} | head -1000000 | wc -l} \
		all; \
	    fi \
	  done \
	done

.PHONY: all-and-backtranslate-allwikis
all-and-backtranslate-allwikis: ${WORKDIR}/${MODELCONFIG}
	${MAKE} data
	${MAKE} train
	${MAKE} eval
	${MAKE} compare
	${MAKE} local-dist
	-for t in ${TRGLANGS}; do \
	  for s in ${SRCLANGS}; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} -C backtranslate SRC=$$s TRG=$$t all-wikitext; \
	      ${MAKE} -C backtranslate \
		SRC=$$s TRG=$$t \
		MAX_SENTENCES=${shell zcat ${TRAINDATA_SRC} | head -1000000 | wc -l} \
		MODELHOME=${MODELDIR} \
		translate-all-wikis; \
	    fi \
	  done \
	done

.PHONY: all-and-backtranslate-allwikiparts
all-and-backtranslate-allwikiparts: ${WORKDIR}/${MODELCONFIG}
	${MAKE} data
	${MAKE} train
	${MAKE} eval
	${MAKE} compare
	${MAKE} local-dist
	-for t in ${TRGLANGS}; do \
	  for s in ${SRCLANGS}; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} -C backtranslate SRC=$$s TRG=$$t all-wikitext; \
	      ${MAKE} -C backtranslate \
		SRC=$$s TRG=$$t \
		MAX_SENTENCES=${shell zcat ${TRAINDATA_SRC} | head -1000000 | wc -l} \
		MODELHOME=${MODELDIR} \
		translate-all-wikiparts; \
	    fi \
	  done \
	done

## train a model with backtranslations of wikipedia data
## (1) train a model in the opposite direction and backtranslate wikipedia data
## (2) train a model with backtranslated data
.PHONY: all-with-bt
all-with-bt:
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-and-backtranslate
	${MAKE} all-bt

## train a model with backtranslations of ALL wikimedia wiki data
.PHONY: all-with-bt-all
all-with-bt-all:
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-and-backtranslate-allwikis
	${MAKE} all-bt

## and now with all parts of all wikis
.PHONY: all-with-bt-allparts
all-with-bt-allparts:
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-and-backtranslate-allwikiparts
	${MAKE} all-bt






## job1: submit jobs to create data, train models, backtranslate all, and train again

job1: ${WORKDIR}/${MODELCONFIG}
	${MAKE} HPC_MEM=12g HPC_CORES=4 job1-step1.submitcpu

job1-step1:
	${MAKE} data
	${MAKE} reverse-data
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" data
	-for t in ${TRGLANGS}; do \
	  ${MAKE} -C backtranslate SRC=${SRC} TRG=$$t all-wikitext; \
	done
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		HPC_CORES=1 HPC_MEM=${GPUJOB_HPC_MEM} job1-step2.submit${GPUJOB_SUBMIT}

job1-step2:
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		MAX_SENTENCES=${shell zcat ${TRAINDATA_SRC} | head -1000000 | wc -l} \
		all-and-backtranslate-allwikis
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		HPC_CORES=1 HPC_MEM=${GPUJOB_HPC_MEM} job1-step3.submit${GPUJOB_SUBMIT}

job1-step3:
	${MAKE} all-bt




print-info:
	@echo "model file: ${MODEL_START}"
	@echo "source vocab: ${MODEL_SRCVOCAB}"
	@echo "target vocab: ${MODEL_TRGVOCAB}"
	@echo "final model file: ${MODEL_FINAL}"
	@echo "latest compatible model: ${MODEL_LATEST}"
	ls -t 	${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}.model[0-9].npz \
			${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}-align.model[0-9].npz \
			${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}.best-perplexity.npz \
			${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}-align.best-perplexity.npz
