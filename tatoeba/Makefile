# -*-makefile-*-
#
# Makefile for running models with data from the Tatoeba Translation Challenge
# https://github.com/Helsinki-NLP/Tatoeba-Challenge
#
#
#---------------------------------------------------------------------
# train and evaluate a single translation pair, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-prepare
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-train
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-eval
#
#
# start job for a single language pair in one direction or
# in both directions, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-job
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-bidirectional-job
#
#
# start jobs for all pairs in an entire subset:
#
#   make tatoeba-subset-lowest
#   make tatoeba-subset-lower
#   make tatoeba-subset-medium
#   make MODELTYPE=transformer tatoeba-subset-higher
#   make MODELTYPE=transformer tatoeba-subset-highest
#
# other jobs to run on the entire subset (example = medium):
#
#   make tatoeba-distsubset-medium .... create release files
#   make tatoeba-evalsubset-medium .... eval all models
#
#
# start jobs for multilingual models from one of the subsets
#
#   make tatoeba-multilingual-subset-zero
#   make tatoeba-multilingual-subset-lowest
#   make tatoeba-multilingual-subset-lower
#   make tatoeba-multilingual-subset-medium
#   make tatoeba-multilingual-subset-higher
#   make tatoeba-multilingual-subset-highest
#
# other jobs to run on the entire subset (example = medium):
#
#   make tatoeba-multilingual-distsubset-medium .... create release files
#   make tatoeba-multilingual-evalsubset-medium .... eval all langpairs
#---------------------------------------------------------------------
# jobs for multilingual language group models
#
#   make all-tatoeba-group2eng ...... start train jobs for all language groups to English
#   make all-tatoeba-eng2group ...... start train jobs for English to all language groups
#   make all-tatoeba-langgroup ...... start train jobs for bi-directional models for all language groups
#
#   make all-tatoeba-langgroups ..... make all jobs from above
#
#
#   make all-tatoeba-group2eng-dist . make package for all trained group2eng models
#   make all-tatoeba-eng2group-dist . make package for all trained eng2group models
#   make all-tatoeba-langgroup-dist . make package for all trained langgroup models
#
#
# jobs for specific tasks and language groups, example task: "gmw2eng"
#
#   make tateoba-gmw2eng-train .. make data and start training job
#   make tateoba-gmw2eng-eval ... evaluate model with multilingual test data
#   make tateoba-gmw2eng-evalall  evaluate model with all individual language pairs
#   make tateoba-gmw2eng-dist ... create release package
#
# Similar jobs can be started for any supported language group from and to English
# and also as a bidirectional model for all languages in the given language group.
# Replace "gmw2eng" with, for example, "eng2gem" (English to Germanic) or 
# "gmq" (multilingual model for North Germanic languages).
#---------------------------------------------------------------------
#
# OBSOLETE (now done in tatoebe repo)
#
# generate evaluation tables
#
#   rm -f tatoeba-results* results/*.md
#   make tatoeba-results-md
#---------------------------------------------------------------------


SHELL    := bash
PWD      := ${shell pwd}
REPOHOME := ${PWD}/../


ifeq (${SRCLANGS},)
ifdef SRC
  SRCLANGS = ${SRC}
endif
endif
ifeq (${TRGLANGS},)
ifdef TRG
  TRGLANGS = ${TRG}
endif
endif


## Tatoeba Challenge Data release number
# TATOEBA_VERSION        ?= v2020-07-28
TATOEBA_VERSION          ?= v2021-08-07
TATOEBA_VERSION_NOHYPHEN ?= $(subst -,,${TATOEBA_VERSION})


## this will be the base name of the model file
TATOEBA_DATASET    := opusTC${TATOEBA_VERSION_NOHYPHEN}

TATOEBA_TRAINSET   := Tatoeba-train-${TATOEBA_VERSION}
TATOEBA_DEVSET     := Tatoeba-dev-${TATOEBA_VERSION}
TATOEBA_TESTSET    := Tatoeba-test-${TATOEBA_VERSION}

DATASET             = ${TATOEBA_DATASET}
TRAINSET            = ${TATOEBA_TRAINSET}
DEVSET              = ${TATOEBA_DEVSET}
TESTSET             = ${TATOEBA_TESTSET}
DEVSET_NAME         = ${TATOEBA_DEVSET}
TESTSET_NAME        = ${TATOEBA_TESTSET}
TRAINSET_NAME       = ${TATOEBA_TRAINSET}

SMALLEST_TRAINSIZE  = 1000
USE_REST_DEVDATA    = 0
DATA_IS_SHUFFLED    = 1
DEVSIZE             = 5000
TESTSIZE            = 10000
DEVMINSIZE          = 200

BACKTRANS_HOME      = ${PWD}/back-translate
FORWARDTRANS_HOME   = ${PWD}/forward-translate
MODELSHOME          = ${PWD}/models
RELEASEDIR          = ${PWD}/models

MODELS_URL          = https://object.pouta.csc.fi/${TATOEBA_MODEL_CONTAINER}
MODEL_CONTAINER     = ${TATOEBA_MODEL_CONTAINER}

SKIP_DATA_DETAILS   = 1
DEFAULT_PIVOT_LANG  = eng
MIN_BLEU_SCORE      = 10
TATOEBA_PIVOT      ?= ${DEFAULT_PIVOT_LANG}


## don't need local scratch space
## TODO: do we need it?
HPC_DISK =


include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/tasks.mk

include ${REPOHOME}lib/projects/distill.mk



## general parameters for Tatoeba models

TATOEBA_DATAURL   := https://object.pouta.csc.fi/Tatoeba-Challenge
TATOEBA_TEST_URL  := ${TATOEBA_DATAURL}-${TATOEBA_VERSION}
TATOEBA_TRAIN_URL := ${TATOEBA_DATAURL}-${TATOEBA_VERSION}
TATOEBA_MONO_URL  := ${TATOEBA_DATAURL}-${TATOEBA_VERSION}
TATOEBA_DATA      ?= ${WORKHOME}/data/${PRE}
TATOEBA_MONO      ?= ${WORKHOME}/data/mono

## list of language IDs that only appear in the training data
## (fetched from Tatoeba github)
TATOEBA_LANGIDS_TRAINONLY = tatoeba/langids-train-only-${TATOEBA_VERSION}.txt

# TATOEBA_RAWGIT         := https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_RAWGIT_MASTER    := https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_RAWGIT_RELEASE   := https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/${TATOEBA_VERSION}


## data count files (file basename)
TATOEBA_DATA_COUNT_BASE = ${TATOEBA_RAWGIT_MASTER}/data/release/${TATOEBA_VERSION}/released-bitexts

## all released language pairs with test sets > 200 test pairs
## also extract all source languages that are available for a give target language
## and vice versa
TATOEBA_RELEASED_DATA   = $(shell wget -qq -O - ${TATOEBA_DATA_COUNT_BASE}-min200.txt | cut -f1)
TATOEBA_AVAILABLE_TRG   = ${sort ${filter-out ${SRC},${subst -, ,${filter %-${SRC} ${SRC}-%,${TATOEBA_RELEASED_DATA}}}}}
TATOEBA_AVAILABLE_SRC   = ${sort ${filter-out ${TRG},${subst -, ,${filter %-${TRG} ${TRG}-%,${TATOEBA_RELEASED_DATA}}}}}

## extract language pairs for a specific subset
TATOEBA_SUBSET               = lower
TATOEBA_RELEASED_SUBSET      = $(shell wget -qq -O - ${TATOEBA_DATA_COUNT_BASE}-${TATOEBA_SUBSET}.txt | cut -f1)
TATOEBA_AVAILABLE_SUBSET_TRG = ${sort ${filter-out ${SRC},${subst -, ,${filter %-${SRC} ${SRC}-%,${TATOEBA_RELEASED_SUBSET}}}}}
TATOEBA_AVAILABLE_SUBSET_SRC = ${sort ${filter-out ${TRG},${subst -, ,${filter %-${TRG} ${TRG}-%,${TATOEBA_RELEASED_SUBSET}}}}}


WIKILANGS         ?= ${notdir ${wildcard backtranslate/wiki-iso639-3/*}}
WIKIMACROLANGS    ?= $(sort ${shell ${GET_ISO_CODE} ${WIKILANGS}})

## ObjectStorage container name for Tatoeba models
TATOEBA_MODEL_CONTAINER := Tatoeba-MT-models


## file with the source and target languages in the current model

TATOEBA_SRCLABELFILE = ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src
TATOEBA_TRGLABELFILE = ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg

## get source and target languages from the label files

ifneq (${wildcard ${TATOEBA_SRCLABELFILE}},)
  TATOEBA_SRCLANGS := ${shell cat ${TATOEBA_SRCLABELFILE}}
else
  TATOEBA_SRCLANGS := ${SRCLANGS}
endif
ifneq (${wildcard ${TATOEBA_TRGLABELFILE}},)
  TATOEBA_TRGLANGS := ${shell cat ${TATOEBA_TRGLABELFILE}}
else
  TATOEBA_TRGLANGS := ${TRGLANGS}
endif

ifdef TATOEBA_TRGLANGS
ifneq (${words ${TATOEBA_TRGLANGS}},1)
  USE_TARGET_LABELS = 1
  TARGET_LABELS = $(patsubst %,>>%<<,$(sort ${TATOEBA_TRGLANGS} ${TATOEBA_TRGLANG_GROUP}))
endif
endif



## default parameters for some recipes with language groups
## - modeltype
## - size balancing
LANGGROUP_MODELTYPE     ?= transformer
LANGGROUP_FIT_DATA_SIZE ?= 1000000



## NEW (2012-12-15): use default (always shuffle training data)
#
# DATA_IS_SHUFFLED    = 1
# MARIAN_SHUFFLE      = data
# MARIAN_DATA_STORAGE = --sqlite
# HPC_DISK            = 500

# ## unless we have multilingual models:
# ## no need to shuffle data again, just shuffle batches
# ## no need to store data in sqlite databases
# ifeq (${words ${SRCLANGS}},1)
# ifeq (${words ${TRGLANGS}},1)
#   MARIAN_SHUFFLE      = batches
#   MARIAN_DATA_STORAGE =
#   HPC_DISK            =
# endif
# endif




GET_ISO_CODE   := ${ISO639} -m

## taken from the Tatoeba-Challenge Makefile
## requires local data for setting TATOEBA_LANGS

# TATOEBA_LANGS       = ${sort ${patsubst %.txt.gz,%,${notdir ${wildcard ${OPUSHOME}/Tatoeba/latest/mono/*.txt.gz}}}}
# TATOEBA_LANGS3      = ${sort ${filter-out xxx,${shell ${GET_ISO_CODE} ${TATOEBA_LANGS}}}}
# TATOEBA_LANGGROUPS  = ${sort ${shell langgroup -p -n ${TATOEBA_LANGS3} 2>/dev/null}}
# TATOEBA_LANGGROUPS1 = ${shell langgroup -g -n ${TATOEBA_LANGS3} 2>/dev/null | tr " " "\n" | grep '+'}
# TATOEBA_LANGGROUPS2 = ${shell langgroup -G -n ${TATOEBA_LANGS3} 2>/dev/null | tr " " "\n" | grep '+'}

OPUS_LANGS3            := ${sort ${filter-out xxx,${shell ${GET_ISO_CODE} ${OPUSLANGS}}}}
OPUS_LANG_PARENTS      := ${sort ${shell langgroup -p -n ${OPUS_LANGS3} 2>/dev/null}}
OPUS_LANG_GRANDPARENTS := ${sort ${shell langgroup -p -n ${OPUS_LANG_PARENTS} 2>/dev/null}}
OPUS_LANG_GROUPS       := ${sort ${OPUS_LANG_PARENTS} ${OPUS_LANG_GRANDPARENTS}}


.PHONY: all
all: 
	${MAKE} prepare
	${MAKE} train-tatoeba
	${MAKE} eval-tatoeba
	${MAKE} compare-tatoeba
	${MAKE} eval-testsets-tatoeba

## generic recipe to replace SRCLANGS and TRGLANGS
## with all languages that are part of the Tatoeba data sets
## (there can be sub-languages in each package)
%-tatoeba: ${TATOEBA_SRCLABELFILE} ${TATOEBA_TRGLABELFILE} ${TATOEBA_LANGIDS_TRAINONLY}
	${MAKE} LANGPAIRSTR=${LANGPAIRSTR} \
		SRCLANGS="${shell cat ${word 1,$^}}" \
		TRGLANGS="${shell cat ${word 2,$^}}" \
	${@:-tatoeba=}


## prepare data (config, train.dev.test data, labels)
.PHONY: prepare tatoeba-prepare
prepare tatoeba-prepare: ${TATOEBA_LANGIDS_TRAINONLY}
	${MAKE} fetch-datasets
	${MAKE} langlabel-files
	${MAKE} local-config
	${MAKE} data-tatoeba

.PHONY: trainonly_langids
trainonly_langids: ${TATOEBA_LANGIDS_TRAINONLY}


## start unidirectional training job
## - make data first, then submit a job
.PHONY: tatoeba-job job slurmjob
job slurmjob tatoeba-job:
	rm -f train-and-eval.submit
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba

## start jobs in both translation directions
.PHONY: tatoeba-bidirectional-job bidirectional-job
bidirectional-job tatoeba-bidirectional-job:
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba
ifneq (${SRCLANGS},${TRGLANGS})
	${MAKE} reverse-data-tatoeba
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" tatoeba-prepare
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-job-tatoeba
endif



## for compatibility: recipes with tatoeba prefix
.PHONY: tatoeba-data tatoeba-train tatoeba-eval tatoeba-compare
tatoeba-data: data
tatoeba-train: train
tatoeba-eval: eval
tatoeba-compare: compare

## fetch the essential data and get labels for language variants
## (this is done by the data targets above as well)
.PHONY: tatoeba-data tatoeba-labels
tatoeba-labels: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
		${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg


## restart all language pairs of models that have not yet converged
## TODO: takes only the first model found in the directory
tatoeba-continue-unfinished:
	for d in `find ${WORKHOME}/  -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  if [ `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' | grep -v tuned | wc -l` -gt 0 ]; then \
	    if [ ! `find ${WORKHOME}/$$d -maxdepth 1  -name '*.done' | grep -v tuned | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f3 -d.`; \
	      t=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-train; \
	    fi \
	  fi \
	done

## restart all language pairs of unreleased models
## unless they are converged already
## TODO: takes only the first model found in the directory
tatoeba-continue-unreleased:
	find ${WORKHOME}/       -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  if [ `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' | grep -v tuned | wc -l` -gt 0 ]; then \
	    if [ ! `find ${WORKHOME}/$$d -maxdepth 1 -name '*.done' | grep -v tuned | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f3 -d.`; \
	      t=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-train; \
	    fi \
	  fi \
	done
	rm -f $@.tt1 $@.tt2


## release all language pairs
## (including lang-group models)
tatoeba-release-all:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	    p=`echo $$d | sed 's/-/2/'`; \
	    m=`echo $$f | cut -f3 -d.`; \
	    t=`echo $$f | cut -f1 -d.`; \
	    ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	    ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done

## release all models that have converged
tatoeba-release-finished:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.done' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done


## release all models that are not yet released
tatoeba-release-unreleased:
	find ${WORKHOME}/       -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done
	rm -f $@.tt1 $@.tt2

tatoeba-release-unreleased-test:
	find ${WORKHOME}/       -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      echo "${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall"; \
	      echo "${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist"; \
	  done \
	done
#	rm -f $@.tt1 $@.tt2

## refresh release info for the latest model that converged in each directory
## ---> be aware of the danger of overwriting existing files
## ---> backups are stored in models-backup
tatoeba-refresh-finished:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.done' -printf "%A@\t%f\n" | sort -nr | cut -f2 | grep -v tuned | head -1`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-refresh; \
	  done \
	done





###########################################################################################
# start combinations with a specific source/target language
###########################################################################################

## similar but for all available languages
## (not only the ones from the subset)
## NOTE: no size balancing to 1m as default in langgroup recipes!

tatoeba-src2all:
	for l in ${TATOEBA_AVAILABLE_TRG}; do \
	    ${MAKE} tatoeba-${SRC}2$$l-trainjob; \
	done

tatoeba-src2langgroup:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_TRG} 2>/dev/null}}; do \
	    ${MAKE} 	FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
			MIN_TRGLANGS=2 \
			SKIP_SAME_LANG=1 \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
		tatoeba-${SRC}2$$l-trainjob; \
	done

tatoeba-all2trg:
	for l in ${TATOEBA_AVAILABLE_SRC}; do \
	    ${MAKE} tatoeba-$${l}2${TRG}-trainjob; \
	done

tatoeba-langgroup2trg:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_SRC} 2>/dev/null}}; do \
	    ${MAKE} 	FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
			MIN_SRCLANGS=2 \
			SKIP_SAME_LANG=1 \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
	    	tatoeba-$${l}2${TRG}-trainjob; \
	done

## TODO: do we always want to include the pivot=eng?
tatoeba-langgroups all-tatoeba-langgroup: 
	for g in ${OPUS_LANG_GROUPS}; do \
	  ${MAKE} 	MIN_SRCLANGS=3 \
			PIVOT=eng \
			SKIP_SAME_LANG=1 \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
			FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
		tatoeba-$${g}2$${g}-trainjob; \
	done

#			MAX_SRCLANGS=30 \


## TODO: do we want to include the pivot=eng?
tatoeba-cross-langgroups all-tatoeba-cross-langgroups:
	for s in ${OPUS_LANG_GROUPS}; do \
	  for t in ${OPUS_LANG_GROUPS}; do \
	    if [ "$$s" != "$$t" ]; then \
		${MAKE} MIN_SRCLANGS=2 MIN_TRGLANGS=2 \
			SKIP_SAME_LANG=1 \
			FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
		tatoeba-$${s}2$${t}-trainjob; \
	    fi \
	  done \
	done

#			MAX_SRCLANGS=30 MAX_TRGLANGS=30 \
#			PIVOT=eng \




###########################################################################################
# start combinations with a specific source/target language
###########################################################################################
#
# make SRC=deu tatoeba-src2all-reasonable
# make SRC=deu tatoeba-src2all-small
#
# make TRG=deu tatoeba-all2trg-reasonable
# make TRG=deu tatoeba-all2trg-small
#

tatoeba-src2all-subset:
	for l in ${TATOEBA_AVAILABLE_SUBSET_TRG}; do \
	    ${MAKE} tatoeba-${SRC}2$$l-trainjob; \
	done

tatoeba-src2langgroup-subset:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_SUBSET_TRG} 2>/dev/null}}; do \
	    ${MAKE} tatoeba-${SRC}2$$l-trainjob-1m; \
	done

tatoeba-all2trg-subset:
	for l in ${TATOEBA_AVAILABLE_SUBSET_SRC}; do \
	    ${MAKE} tatoeba-$${l}2${TRG}-trainjob; \
	done

tatoeba-langgroup2trg-subset:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_SUBSET_SRC} 2>/dev/null}}; do \
	    ${MAKE} tatoeba-$${l}2${TRG}-trainjob-1m; \
	done

## all subsets

tatoeba-src2all-subsets:
	${MAKE} TATOEBA_SUBSET=lowest  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=lower   tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-src2all-subset

tatoeba-all2trg-subsets:
	${MAKE} TATOEBA_SUBSET=lowest  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=lower   tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-all2trg-subset


## reasonable size (all except lower and lowest)

tatoeba-src2all-reasonable:
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-src2all-subset

tatoeba-all2trg-reasonable:
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-all2trg-subset


## backoff to multilingual models and language groups
## lower / lowest resource languages and zero-shot

tatoeba-src2all-small:
	${MAKE} TATOEBA_SUBSET=lower     tatoeba-src2langgroup-subset
	${MAKE} TATOEBA_SUBSET=lowest    tatoeba-src2langgroup-subset
	${MAKE} TATOEBA_SUBSET=zero-shot tatoeba-src2langgroup-subset

tatoeba-all2trg-small:
	${MAKE} TATOEBA_SUBSET=lower     tatoeba-langgroup2trg-subset
	${MAKE} TATOEBA_SUBSET=lowest    tatoeba-langgroup2trg-subset
	${MAKE} TATOEBA_SUBSET=zero-shot tatoeba-langgroup2trg-subset





###########################################################################################
# models for backtranslation
###########################################################################################

tatoeba-wiki2eng:
	for l in ${WIKIMACROLANGS}; do \
	  if [ ! `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS=$$l TRGLANGS=eng tatoeba-job; \
	  fi \
	done

## macro-languages that we missed before
tatoeba-wiki2eng-macro:
	for l in $(filter-out ${WIKILANGS},${WIKIMACROLANGS}); do \
	  if [ ! `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS=$$l TRGLANGS=eng tatoeba-job; \
	  fi \
	done

tatoeba-print-missing-wiki:
	@echo $(filter-out ${WIKILANGS},${WIKIMACROLANGS})

tatoeba-wiki2eng-parent:
	for l in ${WIKIMACROLANGS}; do \
	  if [ ! `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo "check $$l-eng"; \
	    if [ `find ${WORKHOME}/$$l-eng/train -name '${TATOEBA_DATASET}.src.clean.spm*.gz' 2>/dev/null | wc -l` -gt 0 ]; then \
	      echo "check data size of $$l-eng"; \
	      if [ `find ${WORKHOME}/$$l-eng/train -name '${TATOEBA_DATASET}.src.clean.spm*.gz' 2>/dev/null | xargs zcat | head -100000 | wc -l` -lt 100000 ]; then \
		p=`langgroup -p $$l`; \
		echo "${MAKE} SRCLANGS=$$p TRGLANGS=eng tatoeba-$${p}2eng-train-1m"; \
	      fi \
	    fi \
	  fi \
	done

tatoeba-wiki2eng-done:
	for l in ${WIKIMACROLANGS}; do \
	  if [ `find ${TATOEBA_MODELSHOME}/$$l-eng -name '*.zip' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo "model available for $$l-eng"; \
	  elif [ `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo -n "model aivailbale for $$l-eng but not released"; \
	    if [ `find ${WORKHOME}/$$l-eng -name '*.eval' 2>/dev/null | wc -l` -gt 0 ]; then \
	      echo -n ", BLEU = "; \
	      grep BLEU ${WORKHOME}/$$l-eng/*eval | head -1 | cut -f3 -d' '; \
	    elif [ ! -e ${WORKHOME}/$$l-eng/test/${TATOEBA_TESTSET}.src ]; then \
	      echo ", missing eval file"; \
	      echo "make WORKHOME=${WORKHOME}-tmp SRCLANGS=$$l TRGLANGS=eng data-tatoeba"; \
	    else \
	      echo ", run 'make tatoeba-$${l}2eng-evalall'"; \
	    fi \
	  fi \
	done



###########################################################################################
# language groups
###########################################################################################

print-langgroups:
	@echo ${OPUS_LANG_GROUPS}


## start all jobs for all combinations of 
## - language groups and English (separate in both directions)
## - languages in language groups (bi-directional)
##
## language groups include parents and grandparents

all-tatoeba-langgroups: 
	${MAKE} all-tatoeba-group2eng
	${MAKE} all-tatoeba-eng2group
	${MAKE} all-tatoeba-langgroup

all-tatoeba-group2eng: 
	${MAKE} TRG=eng tatoeba-langgroup2trg

all-tatoeba-eng2group: 
	${MAKE} SRC=eng tatoeba-src2langgroup


#---------------------------
# some special recipes for multilingual models with 4 million data fitting
#---------------------------

## include back-translations and fit to 4 million training exampels
all-tatoeba-langgroups-bt-4m: 
	${MAKE} all-tatoeba-group2eng-bt-4m
	${MAKE} all-tatoeba-eng2group-bt-4m
	${MAKE} all-tatoeba-langgroup-bt-4m
#	${MAKE} all-tatoeba-cross-langgroups-bt-4m

SELECTED_LANGGROUPS = cel bat fiu gem gmw gmq roa sla zle zls zlw

tatoeba-selected-langgroups:
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-cross-langgroups-bt-4m
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-langgroup-bt-4m
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-group2eng-bt-4m
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-eng2group-bt-4m

tatoeba-gmw2langgroups-bt-4m:
	${MAKE} SRC=gmw tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=gmw tatoeba-langgroup2trg-bt-4m

tatoeba-roa2langgroups-bt-4m:
	${MAKE} SRC=roa tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=roa tatoeba-langgroup2trg-bt-4m

tatoeba-gmq2langgroups-bt-4m:
	${MAKE} SRC=gmq tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=gmq tatoeba-langgroup2trg-bt-4m

tatoeba-zlw2langgroups-bt-4m:
	${MAKE} SRC=zlw tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=zlw tatoeba-langgroup2trg-bt-4m

tatoeba-zle2langgroups-bt-4m:
	${MAKE} SRC=zle tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=zle tatoeba-langgroup2trg-bt-4m


## temporary recipe for evaluating all 4m multilingual models that are done
tatoeba-eval-4m:
	for p in `ls ${WORKHOME}/*/*4m*done | cut -f2 -d/ | sed 's/\-/2/'`; do \
	  make MODELTYPE=transformer tatoeba-$$p-multieval-bt-4m; \
	  make MODELTYPE=transformer tatoeba-$$p-eval-testsets-bt-4m; \
	done

tatoeba-dist-4m:
	for p in `ls ${WORKHOME}/*/*4m*done | cut -f2 -d/ | sed 's/\-/2/'`; do \
	  make MODELTYPE=transformer tatoeba-$$p-dist-bt-4m; \
	done


## make all lang-group models using different data samples
## (1m, 2m or 4m sentence pairs)
##
## make all-tatoeba-langgroups-1m
## make all-tatoeba-langgroups-2m
## make all-tatoeba-langgroups-4m
## 
## or eng2group and group2eng models, e.g.
##
## make all-tatoeba-group2eng-2m
## make all-tatoeba-eng2group-2m
##
## make release packages for all group models, e.g.
##
## make all-tatoeba-group2eng-dist-2m
## make all-tatoeba-langgroup-dist-2m

%-1m:
	${MAKE} LANGGROUP_FIT_DATA_SIZE=1000000 \
		FIT_DATA_SIZE=1000000 \
		DATASET=${DATASET}1m \
		MARIAN_VALID_FREQ=10000 \
	${@:-1m=}

%-2m:
	${MAKE} CONTINUE_EXISTING=1 \
		LANGGROUP_FIT_DATA_SIZE=2000000 \
		FIT_DATA_SIZE=2000000 \
		DATASET=${DATASET}2m \
		MARIAN_VALID_FREQ=10000 \
	${@:-2m=}

%-4m:
	${MAKE} CONTINUE_EXISTING=1 \
		LANGGROUP_FIT_DATA_SIZE=4000000 \
		FIT_DATA_SIZE=4000000 \
		DATASET=${DATASET}4m \
		MARIAN_VALID_FREQ=10000 \
	${@:-4m=}



## evaluate and create dist packages

## old: just depend on eval and dist targets
## --> this would also start training if there is no model
## --> do this only if a model exists! (see below)

## new: only start this if there is a model
all-tatoeba-group2eng-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${WORKHOME}/$$g-eng -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-dist; \
	  fi \
	done

all-tatoeba-eng2group-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${WORKHOME}/eng-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-dist; \
	  fi \
	done

all-tatoeba-langgroup-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${WORKHOME}/$$g-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-dist; \
	  fi \
	done



##---------------------------------------------------------
## train all models with backtranslations
##---------------------------------------------------------

TATOEBA_RELEASED_BT   = https://object.pouta.csc.fi/Tatoeba-MT-bt/released-data.txt

tatoeba-all-bt:
	for b in ${shell wget -qq -O - ${TATOEBA_RELEASED_BT} | grep -v '.txt' | cut -f1 -d'/' | sort -u}; do \
	  s=`echo $$b | cut -f1 -d'-'`; \
	  t=`echo $$b | cut -f2 -d'-'`; \
	  echo "${MAKE} -C bt-tatoeba SRC=$$s TRG=$$t fetch-bt"; \
	  echo "${MAKE} MODELTYPE=transformer-align HPC_CORES=2 HPC_MEM=32g tatoeba-$${t}2$${s}-train-bt.submitcpu"; \
	done



## special targets for some big language-group models
## (restriction above is for max 25 languages)

ine-ine:
	    ${MAKE} LANGPAIRSTR=ine-ine \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup ine | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup ine | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
		    HPC_DISK=1500 \
	    train-and-eval-job-tatoeba

sla-sla:
	    ${MAKE} LANGPAIRSTR=sla-sla \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup sla | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup sla | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
	    train-and-eval-job-tatoeba

gem-gem:
	    ${MAKE} LANGPAIRSTR=gem-gem \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup gem | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup gem | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
	    train-and-eval-job-tatoeba



##------------------------------------------------------------------------------------
## generic targets to start combinations of languages or language groups
## set variables below to avoid starting models with too few or too many languages
## on source or target side
##------------------------------------------------------------------------------------

MIN_SRCLANGS ?= 1
MIN_TRGLANGS ?= 1
MAX_SRCLANGS ?= 7000
MAX_TRGLANGS ?= 7000

find-langgroup = $(filter ${OPUS_LANGS3},\
		$(sort ${shell langgroup $(1) | xargs iso639 -m -n} ${1} ${2}))

find-srclanggroup = $(call find-langgroup,$(firstword ${subst -, ,${subst 2, ,${1}}}),${2})
find-trglanggroup = $(call find-langgroup,$(lastword ${subst -, ,${subst 2, ,${1}}}),${2})

find-langgroup-pair = $(sort $(call find-srclanggroup,${1}) $(call find-trglanggroup,${1}) ${2})

tatoeba-%-langs:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langs,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langs,%,$@))); \
	   echo "${call find-srclanggroup,${patsubst tatoeba-%-langs,%,$@},${PIVOT}}"; \
	   echo "${call find-trglanggroup,${patsubst tatoeba-%-langs,%,$@},${PIVOT}}"; )


## create data sets (also works for language groups)
tatoeba-%-data:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-data,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-data,%,$@},${PIVOT}}"; \
	     if [ `echo $$S | tr ' ' "\n" | wc -l` -ge ${MIN_SRCLANGS} ]; then \
	       if [ `echo $$T | tr ' ' "\n" | wc -l` -ge ${MIN_TRGLANGS} ]; then \
	         if [ `echo $$S | tr ' ' "\n" | wc -l` -le ${MAX_SRCLANGS} ]; then \
	           if [ `echo $$T | tr ' ' "\n" | wc -l` -le ${MAX_TRGLANGS} ]; then \
	             ${MAKE} LANGPAIRSTR=$$s-$$t \
			SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
			tatoeba-prepare; \
	           fi \
	         fi \
	       fi \
	   fi )


## create data sets (also works for language groups)
tatoeba-labeltest:
	@echo "${call find-trglanggroup,eng2roa,}"
	@echo "${call find-langgroup,roa,}"
	@echo "${shell langgroup roa | xargs iso639 -m -n}"
	@echo "$(filter ${OPUS_LANGS3},${shell langgroup roa | xargs iso639 -m -n})"


## train a tatoeba model
## - create config file
## - create data sets
## - run training and evaluation
tatoeba-%-train:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-train,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-train,%,$@},${PIVOT}}"; \
	   if [ ! `find ${WORKHOME}/$$s-$$t -maxdepth 1 -name '${TATOEBA_DATASET}.*${MODELTYPE}.model${NR}.done' | wc -l` -gt 0 ]; then \
	     if [ `echo $$S | tr ' ' "\n" | wc -l` -ge ${MIN_SRCLANGS} ]; then \
	       if [ `echo $$T | tr ' ' "\n" | wc -l` -ge ${MIN_TRGLANGS} ]; then \
	         if [ `echo $$S | tr ' ' "\n" | wc -l` -le ${MAX_SRCLANGS} ]; then \
	           if [ `echo $$T | tr ' ' "\n" | wc -l` -le ${MAX_TRGLANGS} ]; then \
	             ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
			tatoeba-prepare; \
	             ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
			all-tatoeba; \
	           fi \
	         fi \
	       fi \
	     fi \
	   else \
	      echo "..... already done! ($$s-$$t/${TATOEBA_DATASET}.*${MODELTYPE}.model${NR}.done)"; \
	   fi )


## start the training job
## - create config file
## - create data sets
## - submit SLURM training job
tatoeba-%-trainjob:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-trainjob,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-trainjob,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-trainjob,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-trainjob,%,$@},${PIVOT}}"; \
	   if [ ! `find ${WORKHOME}/$$s-$$t -maxdepth 1 -name '${TATOEBA_DATASET}.*${MODELTYPE}.model${NR}.done' | wc -l` -gt 0 ]; then \
	     if [ `echo $$S | tr ' ' "\n" | wc -l` -ge ${MIN_SRCLANGS} ]; then \
	       if [ `echo $$T | tr ' ' "\n" | wc -l` -ge ${MIN_TRGLANGS} ]; then \
	         if [ `echo $$S | tr ' ' "\n" | wc -l` -le ${MAX_SRCLANGS} ]; then \
	           if [ `echo $$T | tr ' ' "\n" | wc -l` -le ${MAX_TRGLANGS} ]; then \
	             ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
			tatoeba-job; \
	           fi \
	         fi \
	       fi \
	     fi \
	   else \
	      echo "..... already done! ($$s-$$t/${TATOEBA_DATASET}.*${MODELTYPE}.model${NR}.done)"; \
	   fi )


#	   S="${call find-langgroup,${firstword ${subst 2, ,${patsubst tatoeba-%-train,%,$@}}},${PIVOT}}"; \
#	   T="${call find-langgroup,${lastword ${subst 2, ,${patsubst tatoeba-%-train,%,$@}}},${PIVOT}}"; \


## add pivot languages
tatoeba-%-pivotlang:
	@if [ "$(call find-langgroup-pair,$(word 2,$(subst -, ,$@)),${TATOEBA_PIVOT})" != \
	     "$(call find-langgroup-pair,$(word 2,$(subst -, ,$@)))" ]; then \
	  ${MAKE} PIVOT=${TATOEBA_PIVOT} \
		DATASET=${DATASET}+${TATOEBA_PIVOT} \
		MODELCONFIG=${MODELCONFIG:.mk=+${TATOEBA_PIVOT}.mk} \
		MODEL_LATEST_VOCAB= \
		SKIP_LANGPAIRS=${TATOEBA_PIVOT}-${TATOEBA_PIVOT} \
		BPEMODELNAME=opus+${TATOEBA_PIVOT} \
	  ${@:-pivotlang=}; \
	else \
	  echo "pivot language '${TATOEBA_PIVOT}' is already included in $@!"; \
	fi


## evaluate with the model-specific test set
tatoeba-%-eval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-eval,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-eval,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		compare-tatoeba; \
	    fi \
	  fi )

## run evaluation for indivudual language pairs
## in case of multilingual models
tatoeba-%-multieval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-multieval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-multieval,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-multieval,%,$@},${PIVOT}}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-multieval,%,$@},${PIVOT}}"; \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		tatoeba-multilingual-eval; \
	      ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		tatoeba-sublang-eval; \
	    fi \
	  fi )

## evaluate test sets
tatoeba-%-eval-testsets:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval-testsets,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval-testsets,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-eval-testsets,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-eval-testsets,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		eval-testsets-tatoeba; \
	    fi \
	  fi )

## evaluate test sets
tatoeba-%-testsets:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-testsets,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-testsets,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-testsets,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-testsets,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		tatoeba-multilingual-testsets; \
	    fi \
	  fi )


## do all benchmark tests
## - model specific test set
## - other language-specific test sets
## - individual language pairs for multilingual models
tatoeba-%-evalall: tatoeba-%-eval tatoeba-%-multieval tatoeba-%-eval-testsets
	@echo "Done!"


##------------------------------------------------------------------
## create a release package
## (only if BLEU is > MIN_BLEU_SCORE)
## (suffix -release is an alias for -dist)
##------------------------------------------------------------------

tatoeba-%-release:
	${MAKE} ${@:-release=-dist}

tatoeba-%-dist:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-dist,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-dist,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t`" \
		release-tatoeba; \
	  fi )


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


##------------------------------------------------------------------------------------
## make data and start a job for
## fine-tuning a mulitlingual tatoeba model
## for a specific language pair
## set SRC and TRG to specify the language pair, e.g.
##
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtune
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunedist
##
## (makes only sense if there is already such a pre-trained multilingual model)
## langtune for all language combinations:
##
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtuneall
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunealldist
##
## start langtunejobs:
##
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunejob
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunealljobs
##------------------------------------------------------------------------------------

TATOEBA_LANGTUNE_PARAMS = CONTINUE_EXISTING=1 \
			MARIAN_VALID_FREQ=${TUNE_VALID_FREQ} \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EARLY_STOPPING=${TUNE_EARLY_STOPPING} \
			MARIAN_EXTRA='-e 5 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} \
			TATOEBA_DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} \
			TATOEBA_DEVSET_NAME=${TATOEBA_DEVSET}.${TUNE_SRC}-${TUNE_TRG} \
			TATOEBA_TESTSET_NAME=${TATOEBA_TESTSET}.${TUNE_SRC}-${TUNE_TRG} \
			SRCLANGS="${TUNE_SRC}" \
			TRGLANGS="${TUNE_TRG}"

#			LANGPAIRSTR=${LANGPAIRSTR}


TATOEBA_DOMAINTUNE_PARAMS = 	CONTINUE_EXISTING=1 \
			SKIP_VALIDATION=1 \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EXTRA='-e 1 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			FIT_DATA_SIZE=${TUNE_FIT_DATA_SIZE} \
			TATOEBA_TRAINSET=Tatoeba-${TUNE_DOMAIN}-train \
			TATOEBA_DATASET=${DATASET}-tuned4${TUNE_DOMAIN} \
			DATASET=${DATASET}-tuned4${TUNE_DOMAIN}

TATOEBA_TUNE_PARAMS = CONTINUE_EXISTING=1 \
			MARIAN_VALID_FREQ=${TUNE_VALID_FREQ} \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EARLY_STOPPING=${TUNE_EARLY_STOPPING} \
			MARIAN_EXTRA='-e 5 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			DATASET=${DATASET}-tuned4${TUNE_TRAINSET} \
			TATOEBA_DATASET=${DATASET}-tuned4${TUNE_TRAINSET} \
			TATOEBA_TRAINSET=${TUNE_TRAINSET} \
			TATOEBA_DEVSET_NAME=${TUNE_DEVSET} \
			TATOEBA_TESTSET_NAME=${TUNE_TESTSET}


tatoeba-%-tune: tatoeba-%-data
	${MAKE} ${TATOEBA_TUNE_PARAMS} ${patsubst tatoeba-%-tune,tatoeba-%-train,$@}

tatoeba-%-tuneeval:
	${MAKE} ${TATOEBA_TUNE_PARAMS} ${patsubst tatoeba-%-tuneeval,tatoeba-%-evalall,$@}

tatoeba-%-tunedist:
	${MAKE} ${TATOEBA_TUNE_PARAMS} ${patsubst tatoeba-%-tunedist,tatoeba-%-dist,$@}



tatoeba-%-domaintune: tatoeba-%-data
	${MAKE} ${TATOEBA_DOMAINTUNE_PARAMS} ${patsubst tatoeba-%-domaintune,tatoeba-%-train,$@}

tatoeba-%-domaintuneeval:
	${MAKE} ${TATOEBA_DOMAINTUNE_PARAMS} ${patsubst tatoeba-%-domaintuneeval,tatoeba-%-evalall,$@}

tatoeba-%-domaintunedist:
	${MAKE} ${TATOEBA_DOMAINTUNE_PARAMS} ${patsubst tatoeba-%-domaintunedist,tatoeba-%-dist,$@}



tatoeba-langtune:
	${MAKE} ${TATOEBA_LANGTUNE_PARAMS} tatoeba

tatoeba-langtuneeval:
	${MAKE} ${TATOEBA_LANGTUNE_PARAMS} \
		compare-tatoeba \
		tatoeba-multilingual-eval \
		tatoeba-sublang-eval \
		eval-testsets-tatoeba

tatoeba-langtunedist:
	${MAKE} ${TATOEBA_LANGTUNE_PARAMS} release-tatoeba

tatoeba-%-langtune:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtune,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtune,%,$@))); \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t ${TATOEBA_LANGTUNE_PARAMS} tatoeba; \
	  fi )

#		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-langtune,%,$@},${PIVOT}}" \
#		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-langtune,%,$@},${PIVOT}}" \

tatoeba-%-langtunejob:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunejob,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunejob,%,$@))); \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t ${TATOEBA_LANGTUNE_PARAMS} tatoeba-job; \
	  fi )

#		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-langtunejob,%,$@},${PIVOT}}" \
#		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-langtunejob,%,$@},${PIVOT}}" \

tatoeba-%-langtuneeval:
	${MAKE} DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} ${@:-langtuneeval=-evalall}

tatoeba-%-langtunedist:
	${MAKE} DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} ${@:-langtunedist=-dist}

tatoeba-%-langtuneall:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtuneall,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtuneall,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-langtuneall,%,$@},''}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-langtuneall,%,$@},''}"; \
	  for a in $$S; do \
	    for b in $$T; do \
	      if [ "$$a" != "$$b" ]; then \
	        ${MAKE} TUNE_SRC=$$a TUNE_TRG=$$b ${@:-langtuneall=-langtune}; \
	      fi \
	    done \
	  done )

tatoeba-%-langtunealldist:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunealldist,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunealldist,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-langtunealldist,%,$@},''}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-langtunealldist,%,$@},''}"; \
	  for a in $$S; do \
	    for b in $$T; do \
	      if [ "$$a" != "$$b" ]; then \
	        ${MAKE} TUNE_SRC=$$a TUNE_TRG=$$b ${@:-langtunealldist=-langtunedist}; \
	      fi \
	    done \
	  done )

tatoeba-%-langtunealljobs:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunealljobs,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunealljobs,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-langtunealljobs,%,$@},''}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-langtunealljobs,%,$@},''}"; \
	  for a in $$S; do \
	    for b in $$T; do \
	      if [ "$$a" != "$$b" ]; then \
	        ${MAKE} WALLTIME=12 TUNE_SRC=$$a TUNE_TRG=$$b ${@:-langtunealljobs=-langtunejob}; \
	      fi \
	    done \
	  done )



#################################################################################
# run things for all language pairs in a specific subset
# (zero, lowest, lower, medium, higher, highest)
#################################################################################

## get the markdown page for a specific subset
tatoeba-%.md:
	wget -O $@ ${TATOEBA_RAWGIT_MASTER}/subsets/${TATOEBA_VERSION}/${patsubst tatoeba-%,%,$@}


## run all language pairs for a given subset
## in both directions
tatoeba-subset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-bidirectional-job; \
	done

## make dist-packages for all language pairs in a subset
tatoeba-distsubset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} SRCLANGS=$$s TRGLANGS=$$t MIN_BLEU_SCORE=10 release-tatoeba; \
	  fi; \
	  if [ -d ${WORKHOME}/$$t-$$s ]; then \
	    ${MAKE} SRCLANGS=$$t TRGLANGS=$$s MIN_BLEU_SCORE=10 release-tatoeba; \
	  fi; \
	done

## evaluate existing models in a subset
## (this is handy if the model is not converged yet and we need to evaluate the current state)
tatoeba-evalsubset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    if  [ `find ${WORKHOME}/$$s-$$t -name '*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t compare-tatoeba; \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t eval-testsets-tatoeba; \
	    fi \
	  fi; \
	  if [ -d ${WORKHOME}/$$t-$$s ]; then \
	    if  [ `find ${WORKHOME}/$$t-$$s -name '*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} SRCLANGS=$$t TRGLANGS=$$s compare-tatoeba; \
	      ${MAKE} SRCLANGS=$$t TRGLANGS=$$s eval-testsets-tatoeba; \
	    fi \
	  fi \
	done



###############################################################################
## multilingual models from an entire subset
## (all languages in that subset on both sides)
###############################################################################

## training:
## set FIT_DATA_SIZE to biggest one in subset but at least 10000
## set of languages is directly taken from the markdown page at github
tatoeba-multilingual-subset-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  tatoeba-job; )


## TODO: take this target away?
## just start without making data first ...
tatoeba-multilingual-startjob-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  all-job-tatoeba; )


## evaluate all language pairs in both directions
tatoeba-multilingual-evalsubset-%: tatoeba-%.md
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  ${MAKE} SRCLANGS="$$l" TRGLANGS="$$l" \
		  LANGPAIRSTR=${<:.md=} tatoeba-multilingual-eval tatoeba-sublang-eval )


## make a release package to distribute
tatoeba-multilingual-distsubset-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  release-tatoeba; )


## print all data sizes in this set
## --> used to set the max data size per lang-pair
##     for under/over-sampling (FIT_DATA_SIZE)
tatoeba-trainsize-%.txt: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  echo -n "$$l " >> $@; \
	  ${GZCAT} ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$l.clean.$$s.gz | wc -l >> $@; \
	done




###############################################################################
## generic targets for evaluating multilingual models (all supported lang-pairs)
###############################################################################


## evaluate all individual test sets in a multilingual model

.PHONY: tatoeba-multilingual-eval
tatoeba-multilingual-eval:
	-${MAKE} tatoeba-multilingual-testsets
ifneq (${words ${SRCLANGS} ${TRGLANGS}},2)
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ -e ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
		TATOEBA_TESTSET=${TATOEBA_TESTSET}.$$s-$$t \
		TATOEBA_TESTSET_NAME=${TATOEBA_TESTSET}.$$s-$$t \
	      compare-tatoeba; \
	    fi \
	  done \
	done
endif


## evaluate individual language pairs
## (above data sets include macro-languages that include 
##  several individual languages, e.g. hbs or msa)
## the additional prefix '-tatoeba' does the magic
## and expands SRCLANGS and TRGLANGS to individual
## language pairs!

.PHONY: tatoeba-sublang-eval
tatoeba-sublang-eval: tatoeba-multilingual-eval-tatoeba
	@echo "done!"



## an overly complex recipe to create testsets for individual language pairs
## - extract test sets for all (macro-)language combinations
## - extract potential sub-language pairs from combinations involving macro-languages
## - store those testsets in the multilingual model's test directory
.PHONY: tatoeba-multilingual-testsets
tatoeba-multilingual-testsets: ${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba${TATOEBA_VERSION_NOHYPHEN}-testsets.done

MULTILING_TESTSETS_DONE = ${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba-testsets.done \
		${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba${TATOEBA_VERSION_NOHYPHEN}-testsets.done

${MULTILING_TESTSETS_DONE}:
	@mkdir -p ${WORKHOME}/${LANGPAIRSTR}/test
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	      wget -q -O ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp \
			${TATOEBA_RAWGIT_RELEASE}/data/test/$$s-$$t/test.txt; \
	      if [ -s ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp ]; then \
		cat ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp $(FIXLANGIDS) \
			> ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt; \
		if [ "$$s-$$t" != ${LANGPAIRSTR} ]; then \
	          echo "make ${TATOEBA_TESTSET}.$$s-$$t"; \
		  if [ "${USE_TARGET_LABELS}" == "1" ]; then \
	            cut -f2,3 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt | \
		    sed 's/^\([^ ]*\)	/>>\1<< /' \
		    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		  else \
		    cut -f3 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		  fi; \
	          cut -f4 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		  > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.trg; \
		fi; \
		S=`cut -f1 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		T=`cut -f2 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
		  echo "extracting test sets for individual sub-language pairs!"; \
		  for a in $$S; do \
		    for b in $$T; do \
		      if [ "$$a-$$b" != ${LANGPAIRSTR} ]; then \
		        if [ ! -e ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src ]; then \
	                  echo "make ${TATOEBA_TESTSET}.$$a-$$b"; \
		          if [ "${USE_TARGET_LABELS}" == "1" ]; then \
		            grep "$$a	$$b	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			    cut -f2,3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		          else \
		            grep "$$a	$$b	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			    cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		          fi; \
		          grep "$$a	$$b	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
		          cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			  > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.trg; \
		        fi \
	              fi \
		    done \
		  done \
		fi; \
	      else \
	        wget -q -O ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp \
			${TATOEBA_RAWGIT_RELEASE}/data/test/$$t-$$s/test.txt; \
	        if [ -s ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp ]; then \
		  cat ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp $(FIXLANGIDS) \
			> ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt; \
		  if [ "$$s-$$t" != ${LANGPAIRSTR} ]; then \
	            echo "make ${TATOEBA_TESTSET}.$$s-$$t"; \
		    if [ "${USE_TARGET_LABELS}" == "1" ]; then \
	              cut -f1,4 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt | \
		      sed 's/^\([^ ]*\)	/>>\1<< /' \
		      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		    else \
		      cut -f4 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		    fi; \
	            cut -f3 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.trg; \
		  fi; \
		  S=`cut -f2 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		  T=`cut -f1 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		  if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
		    echo "extracting test sets for individual sub-language pairs!"; \
		    for a in $$S; do \
		      for b in $$T; do \
		        if [ "$$a-$$b" != ${LANGPAIRSTR} ]; then \
		          if [ ! -e ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src ]; then \
	                    echo "make ${TATOEBA_TESTSET}.$$a-$$b"; \
		            if [ "${USE_TARGET_LABELS}" == "1" ]; then \
		              grep "$$b	$$a	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			      cut -f1,4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		            else \
		              grep "$$b	$$a	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			      cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		            fi; \
		            grep "$$b	$$a	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
		            cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.trg; \
		          fi \
		        fi \
		      done \
		    done \
		  fi; \
		fi \
	      fi; \
	      rm -f ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp; \
	      rm -f ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt; \
	  done \
	done
	if [ -d ${dir $@} ]; then \
	  touch $@; \
	fi


## TODO:
## get test sets for sublanguages in sets of macro-languages

${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba-testsets-langpairs.done:
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	  done \
	done




###############################################################################
## generic targets for tatoba models
###############################################################################

# ${TATOEBA_SRCLABELFILE} ${TATOEBA_TRGLABELFILE}

.PHONY: tatoeba-langlabel-files langlabel-files
tatoeba-langlabel-files langlabel-files: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
					${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg \
					${WORKHOME}/${LANGPAIRSTR}/${DATASET}-languages.src \
					${WORKHOME}/${LANGPAIRSTR}/${DATASET}-languages.trg

${WORKHOME}/${LANGPAIRSTR}/${DATASET}-languages.%: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.%
	mkdir -p ${dir $@}
	cat $< | tr ' ' "\n" | cut -f1 -d'_' | cut -f1 -d'-' | \
	sed 's/ *$$//;s/^ *//' | tr "\n" ' '  > $@



%-bttatoeba: 	${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
		${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg
	for s in ${shell cat ${word 1,$^}}; do \
	  for t in ${shell cat ${word 2,$^}}; do \
	    echo "${MAKE} -C backtranslate \
		SRC=$$s TRG=$$t \
		WIKI_HOME=wiki-iso639-3 \
		WIKIDOC_HOME=wikidoc-iso639-3 \
		MODELHOME=${TATOEBA_MODELSHOME}/${LANGPAIR} \
	    ${@:-bttatoeba=}"; \
	  done \
	done



## don't delete intermediate label files
.PRECIOUS: 	${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
		${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz


## fetch data for all language combinations
## TODO: should we check whether we are supposed to skip some language pairs?

.PHONY: fetch-tatoeba-datasets fetch-datasets
fetch-datasets fetch-tatoeba-datasets:
	-for s in ${sort ${SRC} ${SRCLANGS}}; do \
	  for t in ${sort ${TRG} ${TRGLANGS}}; do \
	    if [ "$$s" \< "$$t" ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t \
		${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$s.gz; \
	    else \
	      ${MAKE} SRCLANGS=$$t TRGLANGS=$$s \
		${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$t.gz; \
	    fi \
	  done \
	done


## collect all language labels in all language pairs
## (each language pair may include several language variants)
## --> this is necessary to set the languages that are present in a model

${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src:
	${MAKE} fetch-tatoeba-datasets
	mkdir -p ${dir $@}
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      elif [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      fi; \
	      if [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      elif [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      fi; \
	    done \
	done
	if [ -e $@.src ]; then \
	  cat $@.src | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $@; \
	  rm $@.src; \
	else \
	  echo "${SRCLANGS}" > $@; \
	fi
	if [ -e $@.trg ]; then \
	  cat $@.trg | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.src=.trg); \
	  rm $@.trg; \
	else \
	  echo "${TRGLANGS}" > $(@:.src=.trg); \
	fi


${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src
	if [ ! -e $@ ]; then rm $<; ${MAKE} $<; fi
	echo "done"


###############################################################################
## generate data files
###############################################################################


## don't delete those files
.SECONDARY: ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${TRGEXT}.gz

##-------------------------------------------------------------
## take care of languages IDs
## --> simplify some IDs from training data
## --> decide which ones to keep that do not exist in test data
##-------------------------------------------------------------

## langids that we want to keep from the training data even if they do not exist in the Tatoeba test sets
## (skip most lang-IDs because they mostly come from erroneous writing scripts --> errors in the data)
## the list is based on ${TATOEBA_LANGIDS_TRAINONLY}
## special codes: see https://en.wikipedia.org/wiki/ISO_15924

# TRAIN_ONLY_LANGIDS   = ${shell cat ${TATOEBA_LANGIDS_TRAINONLY} | grep -v '^...$$' | tr "\n" ' '}
TRAIN_ONLY_LANGIDS   = ${shell cat ${TATOEBA_LANGIDS_TRAINONLY} | tr "\n" ' '}
KEEP_LANGIDS         = bos_Cyrl cmn cnr cnr_Latn csb diq dnj dty fas fqs ful fur gcf got gug hbs hbs_Cyrl hmn \
			jak_Latn kam kmr kmr_Latn kom kur_Cyrl kuv_Arab kuv_Latn lld mol mrj msa_Latn mya_Cakm nep ngu \
			nor nor_Latn oss_Latn pan plt pnb_Guru pob prs qug quw quy quz qvi rmn rmy ruk san swa swc \
			syr syr_Syrc tgk_Latn thy tlh tmh toi tuk_Cyrl urd_Deva xal_Latn yid_Latn zho zlm
SKIP_LANGIDS         = ${filter-out ${KEEP_LANGIDS},${TRAIN_ONLY_LANGIDS}} \
			ang ara_Latn arq_Latn apc_Latn bul_Latn ell_Latn eng_Tibt \
			eng_Zinh heb_Latn hun_Zinh nob_Hebr rus_Latn \
			..._Qa[ab][a-x] ..._Zinh ..._Zmth ..._Zsym ..._Zxxx ..._Zyyy ..._Zzzz
SKIP_LANGIDS_PATTERN = ^\(${subst ${SPACE},\|,${SKIP_LANGIDS}}\)$$

## modify language IDs in training data to adjust them to test sets
## --> fix codes for chinese and take away script information (not reliable!)
##     except the distinction between traditional and simplified
##     assume that all zho is cmn
## --> take away regional codes
## --> take away script extension that may come with some codes
FIXLANGIDS = 	| sed 's/zho\(.*\)_HK/yue\1/g;s/zho\(.*\)_CN/cmn\1/g;s/zho\(.*\)_TW/cmn\1/g;s/zho/cmn/g;' \
		| sed 's/\_[A-Z][A-Z]//g' \
		| sed 's/\-[a-z]*//g' \
		| sed 's/\_Brai//g' \
		| sed 's/bul_Latn/bul/g' \
		| sed 's/jpn_[A-Za-z]*/jpn/g' \
		| sed 's/kor_[A-Za-z]*/kor/g' \
		| sed 's/nor_Latn/nor/g' \
		| sed 's/non_Latn/non/g' \
		| sed 's/nor/nob/g' \
		| sed 's/syr_Syrc/syr/g' \
		| sed 's/yid_Latn/yid/g' \
		| perl -pe 'if (/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/){if ($$2 ne "Hans" && $$2 ne "Hant"){s/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/$$1/} }'

#		| sed 's/ara_Latn/ara/;s/arq_Latn/arq/;' \



print-skiplangids:
	@echo ${SKIP_LANGIDS_PATTERN}

tatoeba/langids-train-only-${TATOEBA_VERSION}.txt:
	mkdir -p ${dir $@}
	wget -O $@ ${TATOEBA_RAWGIT_MASTER}/data/release/${TATOEBA_VERSION}/langids-train-only.txt

## monolingual data from Tatoeba challenge (wiki data)

${TATOEBA_MONO}/%.labels:
	mkdir -p $@.d
# the old URL without versioning:
	-wget -q -O $@.d/mono.tar ${TATOEBA_DATAURL}/$(patsubst %.labels,%,$(notdir $@)).tar
	-tar -C $@.d -xf $@.d/mono.tar
	rm -f $@.d/mono.tar
# the new URLs with versioning:
	-wget -q -O $@.d/mono.tar ${TATOEBA_MONO_URL}/$(patsubst %.labels,%,$(notdir $@)).tar
	-tar -C $@.d -xf $@.d/mono.tar
	rm -f $@.d/mono.tar
	find $@.d -name '*.id.gz' | xargs ${ZCAT} | sort -u | tr "\n" ' ' | sed 's/ $$//' > $@
	for c in `find $@.d -name '*.id.gz' | sed 's/\.id\.gz//'`; do \
	  echo "extract all data from $$c.txt.gz"; \
	  ${GZIP} -d $$c.id.gz; \
	  ${GZIP} -d $$c.txt.gz; \
	  b=`basename $$c`; \
	  for l in `sort -u $$c.id`; do \
	    echo "extract $$l from $$b"; \
	    mkdir -p ${TATOEBA_MONO}/$$l; \
	    paste $$c.id $$c.txt | grep "^$$l	" | cut -f2 | grep . |\
	    ${SORT} -u | ${SHUFFLE} | split -l 1000000 - ${TATOEBA_MONO}/$$l/$$b.$$l.; \
	    ${GZIP} ${TATOEBA_MONO}/$$l/$$b.$$l.*; \
	  done; \
	  rm -f $$c.id $$c.txt; \
	done
	rm -fr $@.d


##-------------------------------------------------------------------------------------------
## convert Tatoeba Challenge data into the format we need
## - move the data into the right location with the suitable name
## - create devset if not given (part of training data)
## - divide into individual language pairs 
##   (if there is more than one language pair in the collection)
## 
## TODO: should we do some filtering like bitext-match, OPUS-filter ...
##-------------------------------------------------------------------------------------------

## relative directory within the data distributions of Tatoeba MT data files
TATOEBADATA = data/release/${TATOEBA_VERSION}/${LANGPAIR}

## fetch and convert the data and check whether we should extract
## sub-language pairs from the collection
%/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz:
	${MAKE} $@.d/source.labels $@.d/target.labels
	@if [ `cat $@.d/source.labels $@.d/target.labels | wc -w` -gt 2 ]; then \
	  echo ".... found sublanguages in the data"; \
	  b="$@.d/${TATOEBADATA}"; \
	  for s in `cat $@.d/source.labels`; do \
	    for t in `cat $@.d/target.labels`; do \
	      if [ "$$s" \< "$$t" ]; then \
	        echo ".... extract $$s-$$t data"; \
	        for d in dev test train; do \
	          paste <(gzip -cd $$b/$$d.id.gz) <(gzip -cd $$b/$$d.src.gz) <(gzip -cd $$b/$$d.trg.gz) | \
			grep -P "^$$s\t$$t\t" > $@.d/$$d; \
	          if [ -s $@.d/$$d ]; then \
	            cut -f1,2 $@.d/$$d | ${GZIP} -c > ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.$$s-$$t.clean.id.gz; \
	            cut -f3 $@.d/$$d | ${GZIP} -c > ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.$$s-$$t.clean.$$s.gz; \
	            cut -f4 $@.d/$$d | ${GZIP} -c > ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.$$s-$$t.clean.$$t.gz; \
	          fi \
	        done; \
	        if [ -e ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.id.gz ]; then \
	          paste <(gzip -cd $$b/$$d.id.gz) <(gzip -cd $$b/$$d.domain.gz) | grep -P "^$$s\t$$t\t" | cut -f3 | \
	          ${GZIP} -c > ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.domain.gz; \
	          ${ZCAT} ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.domain.gz |\
	          sort -u > ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.domains; \
	          echo "$$s" >> ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.$$s.labels; \
	          echo "$$t" >> ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.$$t.labels; \
	        fi \
	      fi \
	    done \
	  done \
	fi
	@if [ ! -e ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SRCEXT}.gz ]; then \
	  echo ".... move data files"; \
	  b="$@.d/${TATOEBADATA}"; \
	  for d in dev test train; do \
	    mv $$b/$$d.src.gz ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTSRCEXT}.gz; \
	    mv $$b/$$d.trg.gz ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTTRGEXT}.gz; \
	    mv $$b/$$d.id.gz ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.${LANGPAIR}.clean.id.gz; \
	  done; \
	  ${ZCAT} $$b/train.domain.gz | sort -u | tr "\n" ' ' | sed 's/ *$$//' \
		> ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.domains; \
	  mv $$b/train.domain.gz ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.domain.gz; \
	  mv $@.d/source.labels ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTSRCEXT}.labels; \
	  mv $@.d/target.labels ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTTRGEXT}.labels; \
	fi
	@echo ".... cleanup of temporary files"
	@rm -fr $@.d


## fetch data
%.gz.d/data.fetched:
	@echo ".... fetch data (${LANGPAIR}.tar)"
	@mkdir -p ${dir $@}
	-wget -q -O ${dir $@}train.tar ${TATOEBA_TRAIN_URL}/${LANGPAIR}.tar
	-tar -C ${dir $@} -xf ${dir $@}train.tar
	@rm -f ${dir $@}train.tar
	@touch $@


## make dev data (extract additional examples from the training data if neccessary)
%.gz.d/devdata.created: %.gz.d/data.fetched
	@if [ -e ${dir $@}${TATOEBADATA}/dev.src ]; then \
	  if [ `cat ${dir $@}${TATOEBADATA}/dev.src | wc -l` -gt 50 ]; then \
	    touch $@; \
	  else \
	    mv ${dir $@}${TATOEBADATA}/dev.src $@.dev.src; \
	    mv ${dir $@}${TATOEBADATA}/dev.trg $@.dev.trg; \
	    mv ${dir $@}${TATOEBADATA}/dev.id  $@.dev.id; \
	  fi \
	fi
	@if [ ! -e $@ ]; then \
	  if [ -e ${dir $@}${TATOEBADATA}/train.src.gz ]; then \
	    echo "........ too little devdata available - get top 1000 from training data!"; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.src.gz | head -1000                >> $@.dev.src; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.trg.gz | head -1000                >> $@.dev.trg; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz  | head -1000 | cut -f2,3    >> $@.dev.id; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.src.gz | tail -n +1001 | ${GZIP} -f > $@.src.gz; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.trg.gz | tail -n +1001 | ${GZIP} -f > $@.trg.gz; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz  | tail -n +1001 | ${GZIP} -f > $@.id.gz; \
	    mv $@.src.gz ${dir $@}${TATOEBADATA}/train.src.gz; \
	    mv $@.trg.gz ${dir $@}${TATOEBADATA}/train.trg.gz; \
	    mv $@.id.gz  ${dir $@}${TATOEBADATA}/train.id.gz; \
	  fi; \
	  mv $@.dev.src ${dir $@}${TATOEBADATA}/dev.src; \
	  mv $@.dev.trg ${dir $@}${TATOEBADATA}/dev.trg; \
	  mv $@.dev.id  ${dir $@}${TATOEBADATA}/dev.id; \
	  touch $@; \
	fi

## fix language IDs and make sure that dev/test/train exist
%.gz.d/data.fixed: %.gz.d/devdata.created
	@echo ".... fix language codes"
	@if [ -e ${dir $@}${TATOEBADATA}/train.id.gz ]; then \
	  ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz | cut -f2,3 $(FIXLANGIDS) | ${GZIP} -c > ${dir $@}train.id.gz; \
	  ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz | cut -f1 | ${GZIP} -c > ${dir $@}train.domain.gz; \
	  mv ${dir $@}train.id.gz ${dir $@}train.domain.gz ${dir $@}${TATOEBADATA}/; \
	else \
	  touch ${dir $@}${TATOEBADATA}/train.src ${dir $@}${TATOEBADATA}/train.trg; \
	  touch ${dir $@}${TATOEBADATA}/train.id ${dir $@}${TATOEBADATA}/train.domain; \
	  ${GZIP} -cd ${dir $@}${TATOEBADATA}/train.*; \
	fi
	@touch ${dir $@}${TATOEBADATA}/test.id ${dir $@}${TATOEBADATA}/test.src ${dir $@}${TATOEBADATA}/test.trg
	@touch ${dir $@}${TATOEBADATA}/dev.id ${dir $@}${TATOEBADATA}/dev.src ${dir $@}${TATOEBADATA}/dev.trg
	@cat ${dir $@}${TATOEBADATA}/dev.id  $(FIXLANGIDS) > ${dir $@}dev.id
	@cat ${dir $@}${TATOEBADATA}/test.id $(FIXLANGIDS) > ${dir $@}test.id
	@mv ${dir $@}dev.id ${dir $@}test.id ${dir $@}${TATOEBADATA}/
	@${GZIP} -f ${dir $@}${TATOEBADATA}/dev.* ${dir $@}${TATOEBADATA}/test.*


## get source language labels
%.gz.d/source.labels: %.gz.d/data.fixed
	@${ZCAT} ${dir $@}${TATOEBADATA}/*.id.gz | cut -f1 | sort -u | \
	grep -v '${SKIP_LANGIDS_PATTERN}' | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $@

## get target language labels
%.gz.d/target.labels: %.gz.d/data.fixed
	@${ZCAT} ${dir $@}${TATOEBADATA}/*.id.gz | cut -f2 | sort -u | \
	grep -v '${SKIP_LANGIDS_PATTERN}' | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $@


## all the following data sets are created in the target of the
#@ source language training data

%/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz
	@echo "done!"

%/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${SRCEXT}.gz %/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${TRGEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz
	@echo "done!"

%/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${SRCEXT}.gz %/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${TRGEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz
	@echo "done!"





test-tune-data: 
	make SRCEXT=bre TRGEXT=eng LANGPAIR=bre-eng \
	 ${WORKHOME}-test/data/simple/Tatoeba-OpenSubtitles-train.bre-eng.clean.bre.gz


## TODO: should we split into train/dev/test
##       problem: that would overlap with the previous training data

%/Tatoeba-${TUNE_DOMAIN}-train.${LANGPAIR}.clean.${SRCEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz
	paste 	<(gzip -cd ${<:.${SRCEXT}.gz=.domain.gz}) \
		<(gzip -cd $<) \
		<(gzip -cd ${<:.${SRCEXT}.gz=.${TRGEXT}.gz}) | \
	grep '^${TUNE_DOMAIN}	' |\
	tee >(cut -f1 | gzip -c >${@:.${SRCEXT}.gz=.domain.gz}) >(cut -f2 | gzip -c >$@) | \
	cut -f3 | gzip -c > ${@:.${SRCEXT}.gz=.${TRGEXT}.gz}




## make Tatoeba test files available in testset collection
## --> useful for testing various languages when creating multilingual models
testsets/${LANGPAIR}/${TATOEBA_TESTSET}.${LANGPAIR}.%: ${TATOEBA_DATA}/${TATOEBA_TESTSET}.${LANGPAIR}.clean.%
	mkdir -p ${dir $@}
	cp $< $@






###############################################################################
# auxiliary functions (REMOVE?)
###############################################################################


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
	wget -O ${EVAL_WORKHOMEHOME}/${RELEASED_TATOEBA_MODEL} ${RELEASED_TATOEBA_MODEL_URL}
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
