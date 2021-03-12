# -*-makefile-*-
#
# train and test Opus-MT models using MarianNMT
#
#--------------------------------------------------------------------
#
# make all
#
# make data ............... create training data
# make train .............. train NMT model
# make translate .......... translate test set
# make eval ............... evaluate
#
# make all-job ............ create config, data and submit training job
# make train-job .......... submit training job
#
#--------------------------------------------------------------------
# general parameters / variables (see lib/config.mk)
#
# * most essential parameters (language IDs used in OPUS):
#
# SRCLANGS ................ set of source languages
# TRGLANGS ................ set of target languages
#
# * other important parameters (can leave defaults)
#
# MODELTYPE ............... transformer|transformer-align
# TRAINSET ................ set of corpora used for training (default = all of OPUS)
# TESTSET ................. test set corpus (default - subset of Tatoeba with some fallbacks)
# DEVSET .................. validation corpus (default - another subset of TESTSET)
#
# DEVSIZE ................. nr of sentences in validation data
# TESTSIZE ................ nr of sentences in test data
#
# TESTSMALLSIZE ........... reduced size for low-resource settings
# DEVSMALLSIZE ............ reduced size for low-resource settings
# DEVMINSIZE .............. minimum size for validation data
#--------------------------------------------------------------------
# lib/generic.mk
#
# There are implicit targets that define certain frequent tasks
# They typically modify certain settings and make another target
# with those modifiction. They can be used by adding a suffix to
# the actual target that needs to be done. For example, 
# adding -RL triggers right-to-left models:
#
#   make train-RL
#   make eval-RL
#
# Another example would be to run something over a number of models,
# for example, translate and evaluate with those models:
#
#   make eval-allmodels.submit
#   make eval-allbilingual.submit     # only bilingual models
#   make eval-allmultlingual.submit   # only multilingual models
#--------------------------------------------------------------------
# lib/slurm.mk
#
# Defines generic targets for submitting jobs. They work in the 
# same way as the generic targets in lib/generic.mk but submit a
# job using SLURM sbatch. This only works if the SLURM parameters
# are correctly set. Check lib/env.mk, lib/config.mk and lib/slurm.mk
#
#   %.submit ........ job on GPU nodes (for train and translate)
#   %.submitcpu ..... job on CPU nodes (for translate and eval)
#
# They can be combined with any other target, even with generic 
# extensions described above. For exaple, subkit a job to train
# an en-ru right-to-left model for 24 hours you can run
#
#   make WALLTIME=24 SRCLANGS=en TRGLANGS=ru train-RL.submit
#
# Other extensions can be added to modify the SLURM job, for example
# to submit the same job to run on multiple GPUs on one node:
#
#   make WALLTIME=24 SRCLANGS=en TRGLANGS=ru train-RL.submit-multigpu
#
# There can also be targets that submit jobs via SLURM, for exampl
# the train-job target. This can be combined with starting a CPU
# job to create the data sets, which will then submit the train
# job on GPUs once the training data are ready. For example, to
# submit a job with 4 threads (using make -j 4) that will run
# the train-job target on a CPU node allocating 4 CPU cores you
# can do:
#
#   make HPC_CORES=4 SRCLANGS=en TRGLANGS=ru train-job-RL.submitcpu
#
#--------------------------------------------------------------------
# lib/dist.mk
#
# Targets to create and upload packages of trained models
#
#--------------------------------------------------------------------
# There are various special targets for specific and generic tasks.
# Look into the makefiles in lib/generic.mk and lib/models/*.mk
# Many of those targets can be further adjusted by setting certain variables
# Some examples are below but all of those things are subject to change ....
#
#
# * submit job to train a model in one specific translation direction
#   (make data on CPU and then start a job on a GPU node with 4 GPUs)
#   make SRCLANGS=en TRGLANGS=de unidrectional.submitcpu
#
# * submit jobs to train a model in both translation directions
#   (make data on CPU, reverse data and start 2 jobs on a GPU nodes with 4 GPUs each)
#   make SRCLANGS=en TRGLANGS=de bilingual.submitcpu
#
# * same as bilingual but guess some HPC settings based on data size
#   make SRCLANGS=en TRGLANGS=de bilingual-dynamic.submitcpu
#
# * submit jobs for all OPUS languages to PIVOT language in both directions using bilingual-dynamic
#   make PIVOT=en allopus2pivot              # run loop on command line
#   make PIVOT=en allopus2pivot.submitcpu    # submit the same as CPU-based job
#   make all2en.submitcpu                    # short form of the same
#
# * submit jobs for all combinations of OPUS languages (this is huge!)
#   (only if there is no train.submit in the workdir of the language pair)
#   make PIVOT=en allopus.submitcpu
#
# * submit a job to train a multilingual model with the same languages on both sides
#   make LANGS="en de fr" multilingual.submitcpu
#
#--------------------------------------------------------------------
# Ensembles: One can train a number of models and ensemble them.
# NOTE: make sure that the data files and vocabularies exist before
#       training models. Otherwise, thete could be a racing situation
#       when those jobs start simultaneously!!!
# 
#
# make data
# make vocab
# make NR=1 train.submit
# make NR=2 train.submit
# make NR=3 train.submit
#
# make NR=1 eval.submit
# make NR=2 eval.submit
# make NR=3 eval.submit
#
# make eval-ensemble.submit
#
#--------------------------------------------------------------------

## model-specific configuration file
MODELCONFIG = config.mk

# check and adjust lib/env.mk and lib/config.mk

include lib/env.mk

.PHONY: install
install: install-prerequisites
# If we need prerequisites, that has to happen before including eg. config.mk

include lib/config.mk

# load model-specific configuration parameters
# if they exist in the work directory

ifneq ($(wildcard ${WORKDIR}/${MODELCONFIG}),)
  include ${WORKDIR}/${MODELCONFIG}
endif

include lib/data.mk
include lib/train.mk
include lib/test.mk

include lib/misc.mk
include lib/dist.mk
include lib/slurm.mk
include lib/allas.mk

include lib/generic.mk
include lib/langsets.mk
include lib/projects.mk


.PHONY: all
all: ${WORKDIR}/${MODELCONFIG}
	${MAKE} data
	${MAKE} train
	${MAKE} eval
	${MAKE} compare
	${MAKE} eval-testsets



#---------------------------------------------------------------------
# run everything including backtranslation of wiki-data
#
## TODO: need to refrehs backtranslate/index.html from time to time!
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
		MAX_SENTENCES=${shell zcat ${TRAIN_SRC}.clean.${PRE_SRC}.gz | head -1000000 | wc -l} \
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
		MAX_SENTENCES=${shell zcat ${TRAIN_SRC}.clean.${PRE_SRC}.gz | head -1000000 | wc -l} \
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
		MAX_SENTENCES=${shell zcat ${TRAIN_SRC}.clean.${PRE_SRC}.gz | head -1000000 | wc -l} \
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
		MAX_SENTENCES=${shell zcat ${TRAIN_SRC}.clean.${PRE_SRC}.gz | head -1000000 | wc -l} \
		all-and-backtranslate-allwikis
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" \
		HPC_CORES=1 HPC_MEM=${GPUJOB_HPC_MEM} job1-step3.submit${GPUJOB_SUBMIT}

job1-step3:
	${MAKE} all-bt




#------------------------------------------------------------------------
# create slurm jobs
#------------------------------------------------------------------------

.PHONY: all-job
all-job: ${WORKDIR}/${MODELCONFIG}
	${MAKE} data
	${MAKE} train-and-eval-job

.PHONY: train-job
train-job:
	${MAKE} HPC_CORES=1 HPC_MEM=${GPUJOB_HPC_MEM} train.submit${GPUJOB_SUBMIT}

.PHONY: train-and-eval-job
train-and-eval-job:
	${MAKE} HPC_CORES=1 HPC_MEM=${GPUJOB_HPC_MEM} train-and-eval.submit${GPUJOB_SUBMIT}

#------------------------------------------------------------------------
# make various data sets (and word alignment)
#------------------------------------------------------------------------

.PHONY: data
data:	${TRAIN_SRC}.clean.${PRE_SRC}.gz ${TRAIN_TRG}.clean.${PRE_TRG}.gz \
	${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
	${MAKE} ${TEST_SRC}.${PRE_SRC} ${TEST_TRG}
	${MAKE} ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
ifeq (${MODELTYPE},transformer-align)
	${MAKE} ${TRAIN_ALG}
endif


traindata: 	${TRAIN_SRC}.clean.${PRE_SRC}.gz ${TRAIN_TRG}.clean.${PRE_TRG}.gz
testdata:	${TEST_SRC}.${PRE_SRC} ${TEST_TRG}
devdata:	${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
devdata-raw:	${DEV_SRC} ${DEV_TRG}

wordalign:	${TRAIN_ALG}



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
train-and-start-bt-jobs: ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare
	${MAKE} local-dist
	${MAKE} -C backtranslate MODELHOME=${MODELDIR} translate-all-wikis-jobs

