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
# make various data sets (and word alignment)
#------------------------------------------------------------------------

.PHONY: data
data:	
	@${MAKE} rawdata
	@${MAKE} ${WORKDIR}/${MODELCONFIG}
	@${MAKE} ${TRAINDATA_SRC} ${TRAINDATA_TRG}
	@${MAKE} ${DEVDATA_SRC} ${DEVDATA_TRG}
	@${MAKE} ${TESTDATA_SRC} ${TESTDATA_TRG}
	@${MAKE} ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
ifeq ($(filter align,${subst -, ,${MODELTYPE}}),align)
	@${MAKE} ${TRAIN_ALG}
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
	@echo ${SUBWORDS}
	@echo ${USE_JOINT_SUBWORD_MODEL}
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


## other model types
vocab: ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
train: ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
translate: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}
eval: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.eval
compare: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare

## ensemble of models (assumes to find them in subdirs of the WORKDIR)
translate-ensemble: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}
eval-ensemble: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}.eval


## combined tasks:
## train and evaluate
train-and-eval: ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare
	${MAKE} eval-testsets

## train model and start back-translation jobs once the model is ready
## (requires to create a dist package)
## TODO: does this still work?
train-and-start-bt-jobs: ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare
	${MAKE} local-dist
	${MAKE} -C backtranslate MODELHOME=${MODELDIR} translate-all-wikis-jobs






#------------------------------------------------------------------------
# create slurm jobs
#------------------------------------------------------------------------

# all-job:
#  - check whether data files exist
#  - if not: create a CPU job that makes the data and starts a training job after that
#  - if yes: create the GPU training job (after checking that data sets are alright)
#
# TODO: should we rather submit both jobs with dependencies between them?
#       (see sbatch --dependencies)
.PHONY: all-job
all-job: 
	${MAKE} -s data-needed
	@if [ "`${MAKE} -s data-done 2>/dev/null | grep 'data sets'`" == "all data sets exist" ]; then \
	  echo "........ all data files exist already!"; \
	  echo "........ let's check that everything is OK!"; \
	  echo "........ and create a job for training the model!"; \
	  ${MAKE} data-and-train-job; \
	else \
	  echo "........ create a job for making data files first!"; \
	  echo "........ start trainnig job later!"; \
	  ${MAKE} data-and-train-job.submitcpu; \
	fi

all-job-test: 
	@if [ "`${MAKE} -s data-done 2>/dev/null | grep 'data sets'`" == "all data sets exist" ]; then \
	  echo "exist!"; \
	else \
	  echo "does not exist!"; \
	fi

# data-and-train job:
#  - prepare data sets
#  - create/submit the training job
.PHONY: data-and-train-job
data-and-train-job:
	${MAKE} data
	${MAKE} train-and-eval-job

# train-job:
#  - create/submit a jobb for training only (no evaluation!)
.PHONY: train-job
train-job:
	${MAKE} train.submit${GPUJOB_SUBMIT}

# train-and-eval-job:
#  - create/submit a jobb for training (+ evaluation)
.PHONY: train-and-eval-job
train-and-eval-job:
	${MAKE} train-and-eval.submit${GPUJOB_SUBMIT}




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


