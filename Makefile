# -*-makefile-*-
#
# train Opus-MT models using MarianNMT
#
#--------------------------------------------------------------------
#
# (1) train NMT model
#
# make train .............. train NMT model for current language pair
#
# (2) translate and evaluate
#
# make translate .......... translate test set
# make eval ............... evaluate
#
#--------------------------------------------------------------------
#
#   Makefile.tasks ...... various common and specific tasks/experiments
#   Makefile.generic .... generic targets (in form of prefixes to be added to other targets)
#
# Examples from Makefile.tasks:
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
# Some examples using generic extensions
#
# * submit job to train en-ru with backtranslation data from backtranslate/
#   make HPC_CORES=4 WALLTIME=24 SRCLANGS=en TRGLANGS=ru unidirectional-add-backtranslations.submitcpu
#
# * submit job that evaluates all currently trained models:
#   make eval-allmodels.submit
#   make eval-allbilingual.submit   # only bilingual models
#   make eval-allbilingual.submit   # only multilingual models
#
#--------------------------------------------------------------------
#
# general parameters / variables (see Makefile.config)
#   SRCLANGS ............ set source language(s)      (en)
#   TRGLANGS ............ set target language(s)      (de)
#
# 
# submit jobs by adding suffix to make-target to be run
#   .submit ........ job on GPU nodes (for train and translate)
#   .submitcpu ..... job on CPU nodes (for translate and eval)
#
# for example:
#    make train.submit
#
# run a multigpu job, for example
#    make train-multigpu.submit
#    make train-twogpu.submit
#    make train-gpu01.submit
#    make train-gpu23.submit
#
#
# typical procedure: train and evaluate en-de with 3 models in ensemble
#
# make data.submitcpu
# make vocab.submit
# make NR=1 train.submit
# make NR=2 train.submit
# make NR=3 train.submit
#
# make NR=1 eval.submit
# make NR=2 eval.submit
# make NR=3 eval.submit
# make eval-ensemble.submit
#
#
# include right-to-left models:
#
# make NR=1 train-RL.submit
# make NR=2 train-RL.submit
# make NR=3 train-RL.submit
#
#
#--------------------------------------------------------------------
# train several versions of the same model (for ensembling)
#
#   make NR=1 ....
#   make NR=2 ....
#   make NR=3 ....
#
# DANGER: problem with vocabulary files if you start them simultaneously
#         --> racing situation for creating them between the processes
#
#--------------------------------------------------------------------
# resume training
#
#   make resume
#
#--------------------------------------------------------------------
# translate with ensembles of models
#
#   make translate-ensemble
#   make eval-ensemble
#
# this only makes sense if there are several models
# (created with different NR)
#--------------------------------------------------------------------


# check and adjust lib/env.mk and lib/config.mk
# add specific tasks in lib/tasks.mk


include lib/env.mk
include lib/config.mk

## load model-specific configuration parameters
ifneq ($(wildcard ${WORKDIR}/config.mk),)
  include ${WORKDIR}/config.mk
endif

include lib/data.mk
include lib/train.mk
include lib/test.mk

include lib/misc.mk
include lib/dist.mk
include lib/slurm.mk

include lib/generic.mk
include lib/langsets.mk
# include lib/tasks.mk
include lib/models/celtic.mk
include lib/models/finland.mk
include lib/models/fiskmo.mk
include lib/models/memad.mk
include lib/models/multilingual.mk
include lib/models/opus.mk
include lib/models/romance.mk
include lib/models/russian.mk
include lib/models/sami.mk
include lib/models/wikimedia.mk

include lib/models/doclevel.mk
include lib/models/simplify.mk


# include Makefile.env
# include Makefile.config
# include Makefile.dist
# include Makefile.tasks
# include Makefile.data
# include Makefile.doclevel
# include Makefile.generic
# include Makefile.slurm


#------------------------------------------------------------------------
# make various data sets
#------------------------------------------------------------------------


.PHONY: data
data:	${TRAIN_SRC}.clean.${PRE_SRC}.gz ${TRAIN_TRG}.clean.${PRE_TRG}.gz \
	${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
	${MAKE} ${TEST_SRC}.${PRE_SRC} ${TEST_TRG}
	${MAKE} ${MODEL_VOCAB}
ifeq (${MODELTYPE},transformer-align)
	${MAKE} ${TRAIN_ALG}
endif


traindata: 	${TRAIN_SRC}.clean.${PRE_SRC}.gz ${TRAIN_TRG}.clean.${PRE_TRG}.gz
tunedata: 	${TUNE_SRC}.${PRE_SRC} ${TUNE_TRG}.${PRE_TRG}
testdata:	${TEST_SRC}.${PRE_SRC} ${TEST_TRG}
devdata:	${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
devdata-raw:	${DEV_SRC} ${DEV_TRG}

wordalign:	${TRAIN_ALG}



#------------------------------------------------------------------------
# train, translate and evaluate
#------------------------------------------------------------------------


## other model types
vocab: ${MODEL_VOCAB}
train: ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
translate: ${WORKDIR}/${TESTSET}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}
eval: ${WORKDIR}/${TESTSET}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.eval
compare: ${WORKDIR}/${TESTSET}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare

## ensemble of models (assumes to find them in subdirs of the WORKDIR)
translate-ensemble: ${WORKDIR}/${TESTSET}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}
eval-ensemble: ${WORKDIR}/${TESTSET}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}.eval



