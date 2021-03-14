# -*-makefile-*-
#
# Makefile for running models with data from the Tatoeba Translation Challenge
# https://github.com/Helsinki-NLP/Tatoeba-Challenge
#
# NEWS
#
# - MODELTYPE=transformer is now default for all Tatoeba models
#   (no guided alignment!)
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



## general parameters for Tatoeba models


## NEW: release
TATOEBA_VERSION        ?= v2020-07-28

TATOEBA_DATAURL   := https://object.pouta.csc.fi/Tatoeba-Challenge
# TATOEBA_TEST_URL  := ${TATOEBA_DATAURL}-${TATOEBA_VERSION}
# TATOEBA_TRAIN_URL := ${TATOEBA_DATAURL}-${TATOEBA_VERSION}
# TATOEBA_MONO_URL  := ${TATOEBA_DATAURL}-${TATOEBA_VERSION}
TATOEBA_TEST_URL  := ${TATOEBA_DATAURL}
TATOEBA_TRAIN_URL := ${TATOEBA_DATAURL}
TATOEBA_MONO_URL  := ${TATOEBA_DATAURL}
TATOEBA_RAWGIT    := https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_WORK      ?= ${PWD}/work-tatoeba
TATOEBA_DATA      ?= ${TATOEBA_WORK}/data/${PRE}
TATOEBA_MONO      ?= ${TATOEBA_WORK}/data/mono

WIKILANGS         ?= ${notdir ${wildcard backtranslate/wiki-iso639-3/*}}
WIKIMACROLANGS    ?= $(sort ${shell ${GET_ISO_CODE} ${WIKILANGS}})

TATOEBA_MODEL_CONTAINER := Tatoeba-MT-models

TATOEBA_TRAINSET     = Tatoeba-train
TATOEBA_DEVSET       = Tatoeba-dev
TATOEBA_TESTSET      = Tatoeba-test
TATOEBA_DEVSET_NAME  = Tatoeba-dev
TATOEBA_TESTSET_NAME = Tatoeba-test
TATOEBA_RELEASEDIR   = ${PWD}/models-tatoeba
TATOEBA_MODELSHOME   = ${PWD}/models-tatoeba
TATOEBA_BTHOME       = ${PWD}/bt-tatoeba


## file with the source and target languages in the current model

TATOEBA_SRCLABELFILE = ${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.src
TATOEBA_TRGLABELFILE = ${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.trg

## get source and target languages from the label files

ifneq (${wildcard ${TATOEBA_SRCLABELFILE}},)
  TATOEBA_SRCLANGS = ${shell cat ${TATOEBA_SRCLABELFILE}}
endif
ifneq (${wildcard ${TATOEBA_TRGLABELFILE}},)
  TATOEBA_TRGLANGS = ${shell cat ${TATOEBA_TRGLABELFILE}}
endif
ifndef USE_TARGET_LABELS
ifneq (${words ${TATOEBA_TRGLANGS}},1)
  USE_TARGET_LABELS = 1
  TARGET_LABELS = $(patsubst %,>>%<<,${TATOEBA_TRGLANGS})
endif
endif



TATOEBA_PARAMS := TRAINSET=${TATOEBA_TRAINSET} \
		DEVSET=${TATOEBA_DEVSET} \
		TESTSET=${TATOEBA_TESTSET} \
		DEVSET_NAME=${TATOEBA_DEVSET_NAME} \
		TESTSET_NAME=${TATOEBA_TESTSET_NAME} \
		SMALLEST_TRAINSIZE=1000 \
		USE_REST_DEVDATA=0 \
		HELDOUTSIZE=0 \
		DEVSIZE=5000 \
		TESTSIZE=10000 \
		DEVMINSIZE=200 \
		WORKHOME=${TATOEBA_WORK} \
		BACKTRANS_HOME=${TATOEBA_BTHOME} \
		MODELSHOME=${TATOEBA_MODELSHOME} \
		RELEASEDIR=${TATOEBA_RELEASEDIR} \
                MODELS_URL=https://object.pouta.csc.fi/${TATOEBA_MODEL_CONTAINER} \
		MODEL_CONTAINER=${TATOEBA_MODEL_CONTAINER} \
		ALT_MODEL_DIR=tatoeba \
		SKIP_DATA_DETAILS=1 \
		MIN_BLEU_SCORE=10




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


.PHONY: tatoeba
tatoeba:
	${MAKE} tatoeba-prepare
	${MAKE} all-tatoeba

## start unidirectional training job
## - make data first, then submit a job
.PHONY: tatoeba-job
tatoeba-job:
	rm -f train-and-eval.submit
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba

## start jobs in both translation directions
.PHONY: tatoeba-bidirectional-job
tatoeba-bidirectional-job:
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba
ifneq (${SRCLANGS},${TRGLANGS})
	${MAKE} reverse-data-tatoeba
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" tatoeba-prepare
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-job-tatoeba
endif


## prepare data (config, train.dev.test data, labels)
.PHONY: tatoeba-prepare
tatoeba-prepare: # ${TATOEBA_DATA}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	${MAKE} local-config-tatoeba
	${MAKE} data-tatoeba

## train a model
.PHONY: tatoeba-train
tatoeba-train:
	${MAKE} train-tatoeba

## evaluate a model
.PHONY: tatoeba-eval
tatoeba-eval:
	${MAKE} compare-tatoeba

## fetch the essential data and get labels for language variants
## (this is done by the data targets above as well)
.PHONY: tatoeba-data tatoeba-labels
# tatoeba-data: ${TATOEBA_DATA}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
tatoeba-data: data-tatoeba
tatoeba-labels: ${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
		${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.trg

#		${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels \
#		${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${TRGEXT}.labels


## restart all language pairs of models that have not yet converged
## TODO: takes only the first model found in the directory
tatoeba-continue-unfinished:
	for d in `find ${TATOEBA_WORK}/  -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  if [ `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.valid1.log' | grep -v tuned | wc -l` -gt 0 ]; then \
	    if [ ! `find ${TATOEBA_WORK}/$$d -maxdepth 1  -name '*.done' | grep -v tuned | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`ls ${TATOEBA_WORK}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f3 -d.`; \
	      t=`ls ${TATOEBA_WORK}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-train; \
	    fi \
	  fi \
	done

## restart all language pairs of unreleased models
## unless they are converged already
## TODO: takes only the first model found in the directory
tatoeba-continue-unreleased:
	find ${TATOEBA_WORK}/       -maxdepth 1 -type d -name '???-???' -printf " %f" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  if [ `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.valid1.log' | grep -v tuned | wc -l` -gt 0 ]; then \
	    if [ ! `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.done' | grep -v tuned | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`ls ${TATOEBA_WORK}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f3 -d.`; \
	      t=`ls ${TATOEBA_WORK}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-train; \
	    fi \
	  fi \
	done
	rm -f $@.tt1 $@.tt2


## release all language pairs
## (including lang-group models)
tatoeba-release-all:
	for d in `find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	    p=`echo $$d | sed 's/-/2/'`; \
	    m=`echo $$f | cut -f3 -d.`; \
	    t=`echo $$f | cut -f1 -d.`; \
	    ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	    ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done

## release all models that have converged
tatoeba-release-finished:
	for d in `find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.done' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done


## release all models that are not yet released
tatoeba-release-unreleased:
	find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' | cut -f2 -d/ | sort > $@.tt1
	find models-tatoeba/ -maxdepth 1 -type d -name '???-???' | cut -f2 -d/ | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  for f in `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  fi \
	done
	rm -f $@.tt1 $@.tt2

tatoeba-release-unreleased-test:
	find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' -printf " %f" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  for f in `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      echo "${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall"; \
	      echo "${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist"; \
	  done \
	done
	rm -f $@.tt1 $@.tt2

## refresh release info for the latest model that converged in each directory
## ---> be aware of the danger of overwriting existing files
## ---> backups are stored in models-backup
tatoeba-refresh-finished:
	for d in `find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${TATOEBA_WORK}/$$d -maxdepth 1 -name '*.done' -printf "%A@\t%f\n" | sort -nr | cut -f2 | grep -v tuned | head -1`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-refresh; \
	  done \
	done



###########################################################################################
# models for backtranslation
###########################################################################################

tatoeba-wiki2eng:
	for l in ${WIKIMACROLANGS}; do \
	  if [ ! `find ${TATOEBA_WORK}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS=$$l TRGLANGS=eng tatoeba-job; \
	  fi \
	done

## macro-languages that we missed before
tatoeba-wiki2eng-macro:
	for l in $(filter-out ${WIKILANGS},${WIKIMACROLANGS}); do \
	  if [ ! `find ${TATOEBA_WORK}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS=$$l TRGLANGS=eng tatoeba-job; \
	  fi \
	done

tatoeba-print-missing-wiki:
	@echo $(filter-out ${WIKILANGS},${WIKIMACROLANGS})

tatoeba-wiki2eng-parent:
	for l in ${WIKIMACROLANGS}; do \
	  if [ ! `find ${TATOEBA_WORK}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo "check $$l-eng"; \
	    if [ `find ${TATOEBA_WORK}/$$l-eng/train -name 'opus.src.clean.spm*.gz' 2>/dev/null | wc -l` -gt 0 ]; then \
	      echo "check data size of $$l-eng"; \
	      if [ `find ${TATOEBA_WORK}/$$l-eng/train -name 'opus.src.clean.spm*.gz' 2>/dev/null | xargs zcat | head -100000 | wc -l` -lt 100000 ]; then \
		p=`langgroup -p $$l`; \
		echo "${MAKE} SRCLANGS=$$p TRGLANGS=eng tatoeba-$${p}2eng-train-1m"; \
	      fi \
	    fi \
	  fi \
	done

tatoeba-wiki2eng-done:
	for l in ${WIKIMACROLANGS}; do \
	  if [ `find models-tatoeba/$$l-eng -name '*.zip' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo "model available for $$l-eng"; \
	  elif [ `find ${TATOEBA_WORK}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo -n "model aivailbale for $$l-eng but not released"; \
	    if [ `find ${TATOEBA_WORK}/$$l-eng -name '*.eval' 2>/dev/null | wc -l` -gt 0 ]; then \
	      echo -n ", BLEU = "; \
	      grep BLEU ${TATOEBA_WORK}/$$l-eng/*eval | head -1 | cut -f3 -d' '; \
	    elif [ ! -e ${TATOEBA_WORK}/$$l-eng/test/Tatoeba-test.src ]; then \
	      echo ", missing eval file"; \
	      echo "make TATOEBA_WORK=${TATOEBA_WORK}-tmp SRCLANGS=$$l TRGLANGS=eng data-tatoeba"; \
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


#### language-group to English

GROUP2ENG_TRAIN   := $(patsubst %,tatoeba-%2eng-train,${OPUS_LANG_GROUPS})
GROUP2ENG_EVAL    := $(patsubst %,tatoeba-%2eng-eval,${OPUS_LANG_GROUPS})
GROUP2ENG_EVALALL := $(patsubst %,tatoeba-%2eng-evalall,${OPUS_LANG_GROUPS})
GROUP2ENG_DIST    := $(patsubst %,tatoeba-%2eng-dist,${OPUS_LANG_GROUPS})

#### English to language group

ENG2GROUP_TRAIN   := $(patsubst %,tatoeba-eng2%-train,${OPUS_LANG_GROUPS})
ENG2GROUP_EVAL    := $(patsubst %,tatoeba-eng2%-eval,${OPUS_LANG_GROUPS})
ENG2GROUP_EVALALL := $(patsubst %,tatoeba-eng2%-evalall,${OPUS_LANG_GROUPS})
ENG2GROUP_DIST    := $(patsubst %,tatoeba-eng2%-dist,${OPUS_LANG_GROUPS})

#### multilingual language-group (bi-directional

LANGGROUP_TRAIN   := $(foreach G,${OPUS_LANG_GROUPS},tatoeba-${G}2${G}-train)
LANGGROUP_EVAL    := $(patsubst %-train,%-eval,${LANGGROUP_TRAIN})
LANGGROUP_EVALALL := $(patsubst %-train,%-evalall,${LANGGROUP_TRAIN})
LANGGROUP_DIST    := $(patsubst %-train,%-dist,${LANGGROUP_TRAIN})

LANGGROUP_FIT_DATA_SIZE=1000000

## start all jobs with 1 million sampled sentence pairs per language pair
all-tatoeba-group2eng: 
	${MAKE} MIN_SRCLANGS=2 MODELTYPE=transformer \
		FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} ${GROUP2ENG_TRAIN}

all-tatoeba-eng2group: 
	${MAKE} MIN_TRGLANGS=2 MODELTYPE=transformer \
		FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} ${ENG2GROUP_TRAIN}

all-tatoeba-langgroup: 
	${MAKE} MIN_SRCLANGS=2 MAX_SRCLANGS=30 PIVOT=eng \
		MODELTYPE=transformer \
		FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} ${LANGGROUP_TRAIN}

all-tatoeba-cross-langgroups:
	for s in ${OPUS_LANG_GROUPS}; do \
	  for t in ${OPUS_LANG_GROUPS}; do \
	    if [ "$$s" != "$$t" ]; then \
		${MAKE} MIN_SRCLANGS=2 MIN_TRGLANGS=2 \
			MAX_SRCLANGS=30 MAX_TRGLANGS=30 \
			MODELTYPE=transformer \
			FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
		tatoeba-$${s}2$${t}-train; \
	    fi \
	  done \
	done

#			PIVOT=eng \




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

# tatoeba-eng2group-dist: ${ENG2GROUP_EVAL} ${ENG2GROUP_EVALALL}
#	${MAKE} ${ENG2GROUP_DIST}

## new: only start this if there is a model
all-tatoeba-group2eng-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${TATOEBA_WORK}/$$g-eng -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-dist; \
	  fi \
	done

all-tatoeba-eng2group-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${TATOEBA_WORK}/eng-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-dist; \
	  fi \
	done

all-tatoeba-langgroup-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${TATOEBA_WORK}/$$g-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
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
	             ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-prepare; \
	           fi \
	         fi \
	       fi \
	   fi )


## start the training job
## - create config file
## - create data sets
## - submit SLURM training job
tatoeba-%-train:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-train,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-train,%,$@},${PIVOT}}"; \
	   if [ ! `find ${TATOEBA_WORK}/$$s-$$t -maxdepth 1 -name '${DATASET}.*.done' | wc -l` -gt 0 ]; then \
	     if [ `echo $$S | tr ' ' "\n" | wc -l` -ge ${MIN_SRCLANGS} ]; then \
	       if [ `echo $$T | tr ' ' "\n" | wc -l` -ge ${MIN_TRGLANGS} ]; then \
	         if [ `echo $$S | tr ' ' "\n" | wc -l` -le ${MAX_SRCLANGS} ]; then \
	           if [ `echo $$T | tr ' ' "\n" | wc -l` -le ${MAX_TRGLANGS} ]; then \
	             ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-job; \
	           fi \
	         fi \
	       fi \
	     fi \
	   fi )


#	   S="${call find-langgroup,${firstword ${subst 2, ,${patsubst tatoeba-%-train,%,$@}}},${PIVOT}}"; \
#	   T="${call find-langgroup,${lastword ${subst 2, ,${patsubst tatoeba-%-train,%,$@}}},${PIVOT}}"; \



## evaluate with the model-specific test set
tatoeba-%-eval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    if [ `find ${TATOEBA_WORK}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-eval,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-eval,%,$@},${PIVOT}}" \
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
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    if [ `find ${TATOEBA_WORK}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-multilingual-eval; \
	      ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-sublang-eval; \
	    fi \
	  fi )

## evaluate test sets
tatoeba-%-eval-testsets:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval-testsets,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval-testsets,%,$@))); \
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    if [ `find ${TATOEBA_WORK}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-eval-testsets,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-eval-testsets,%,$@},${PIVOT}}" \
		eval-testsets-tatoeba; \
	    fi \
	  fi )

## evaluate test sets
tatoeba-%-testsets:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-testsets,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-testsets,%,$@))); \
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    if [ `find ${TATOEBA_WORK}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-testsets,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-testsets,%,$@},${PIVOT}}" \
		tatoeba-multilingual-testsets; \
	    fi \
	  fi )


## do all benchmark tests
## - model specific test set
## - other language-specific test sets
## - individual language pairs for multilingual models
tatoeba-%-evalall: tatoeba-%-eval-testsets tatoeba-%-multieval
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
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-dist,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-dist,%,$@},${PIVOT}}" \
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
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-refresh-release-readme,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-refresh-release-readme,%,$@},${PIVOT}}" \
		refresh-release-readme-tatoeba; \
	  fi )

## refresh yaml file of the latest release
tatoeba-%-refresh-release-yml:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-refresh-release-yml,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-refresh-release-yml,%,$@))); \
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-refresh-release-yml,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-refresh-release-yml,%,$@},${PIVOT}}" \
		refresh-release-yml-tatoeba; \
	  fi )

## refresh the entire release (create a new release with the old time stamp)
tatoeba-%-refresh-release: tatoeba-%-refresh-release-yml tatoeba-%-refresh-release-readme
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-refresh-release,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-refresh-release,%,$@))); \
	  if [ -e ${TATOEBA_WORK}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-refresh-release,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-refresh-release,%,$@},${PIVOT}}" \
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
			TATOEBA_DEVSET_NAME=Tatoeba-dev.${TUNE_SRC}-${TUNE_TRG} \
			TATOEBA_TESTSET_NAME=Tatoeba-test.${TUNE_SRC}-${TUNE_TRG} \
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
			DATASET=${DATASET}-tuned4${TUNE_DOMAIN}

TATOEBA_TUNE_PARAMS = CONTINUE_EXISTING=1 \
			MARIAN_VALID_FREQ=${TUNE_VALID_FREQ} \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EARLY_STOPPING=${TUNE_EARLY_STOPPING} \
			MARIAN_EXTRA='-e 5 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			DATASET=${DATASET}-tuned4${TUNE_TRAINSET} \
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
	  if [ -d ${TATOEBA_WORK}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t ${TATOEBA_LANGTUNE_PARAMS} tatoeba; \
	  fi )

#		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-langtune,%,$@},${PIVOT}}" \
#		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-langtune,%,$@},${PIVOT}}" \

tatoeba-%-langtunejob:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunejob,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunejob,%,$@))); \
	  if [ -d ${TATOEBA_WORK}/$$s-$$t ]; then \
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
	wget -O $@ ${TATOEBA_RAWGIT}/subsets/${patsubst tatoeba-%,%,$@}


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
	  if [ -d ${TATOEBA_WORK}/$$s-$$t ]; then \
	    ${MAKE} SRCLANGS=$$s TRGLANGS=$$t MIN_BLEU_SCORE=10 release-tatoeba; \
	  fi; \
	  if [ -d ${TATOEBA_WORK}/$$t-$$s ]; then \
	    ${MAKE} SRCLANGS=$$t TRGLANGS=$$s MIN_BLEU_SCORE=10 release-tatoeba; \
	  fi; \
	done

## evaluate existing models in a subset
## (this is handy if the model is not converged yet and we need to evaluate the current state)
tatoeba-evalsubset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  if [ -d ${TATOEBA_WORK}/$$s-$$t ]; then \
	    if  [ `find ${TATOEBA_WORK}/$$s-$$t -name '*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t compare-tatoeba; \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t eval-testsets-tatoeba; \
	    fi \
	  fi; \
	  if [ -d ${TATOEBA_WORK}/$$t-$$s ]; then \
	    if  [ `find ${TATOEBA_WORK}/$$t-$$s -name '*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
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
	  ${GZCAT} ${TATOEBA_DATA}/Tatoeba-train.$$l.clean.$$s.gz | wc -l >> $@; \
	done




###############################################################################
## generic targets for evaluating multilingual models (all supported lang-pairs)
###############################################################################


## evaluate all individual test sets in a multilingual model

.PHONY: tatoeba-multilingual-eval
tatoeba-multilingual-eval:
	-${MAKE} ${TATOEBA_PARAMS} tatoeba-multilingual-testsets
ifneq (${words ${SRCLANGS} ${TRGLANGS}},2)
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src ]; then \
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



## copy testsets into the multilingual model's test directory
.PHONY: tatoeba-multilingual-testsets
tatoeba-multilingual-testsets: ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-testsets.done

# ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-testsets.done-old:
# 	@for s in ${SRCLANGS}; do \
# 	  for t in ${TRGLANGS}; do \
# 	    if [ ! -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src ]; then \
# 	      wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 			${TATOEBA_RAWGIT}/data/test/$$s-$$t/test.txt; \
# 	      if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt ]; then \
# 	        echo "make Tatoeba-test.$$s-$$t"; \
# 		if [ "${USE_TARGET_LABELS}" == "1" ]; then \
# 	          cut -f2,3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
# 		  sed 's/^\([^ ]*\)	/>>\1<< /' \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		else \
# 		  cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		fi; \
# 	        cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
# 	      else \
# 	        wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 			${TATOEBA_RAWGIT}/data/test/$$t-$$s/test.txt; \
# 	        if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt ]; then \
# 	          echo "make Tatoeba-test.$$s-$$t"; \
# 		  if [ "${USE_TARGET_LABELS}" == "1" ]; then \
# 	            cut -f1,4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
# 		    sed 's/^\([^ ]*\)	/>>\1<< /' \
# 		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		  else \
# 		    cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		  fi; \
# 	          cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
# 		fi \
# 	      fi; \
# 	      rm -f ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
# 	    fi \
# 	  done \
# 	done
# 	if [ -d ${dir $@} ]; then \
# 	  touch $@; \
# 	fi


## a rather complex recipe to create testsets for individual language pairs
## in multilingual models
## - extract test sets for all (macro-)language combinations
## - extract potential sub-language pairs from combinations involving macro-languages


#	    if [ ! -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src ]; then \
#	    fi \

${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-testsets.done:
	@mkdir -p ${TATOEBA_WORK}/${LANGPAIRSTR}/test
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	      wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp \
			${TATOEBA_RAWGIT}/data/test/$$s-$$t/test.txt; \
	      if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp ]; then \
		cat ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp $(FIXLANGIDS) \
			> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
		if [ "$$s-$$t" != ${LANGPAIRSTR} ]; then \
	          echo "make Tatoeba-test.$$s-$$t"; \
		  if [ "${USE_TARGET_LABELS}" == "1" ]; then \
	            cut -f2,3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
		    sed 's/^\([^ ]*\)	/>>\1<< /' \
		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		  else \
		    cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		  fi; \
	          cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
		fi; \
		S=`cut -f1 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		T=`cut -f2 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
		  echo "extracting test sets for individual sub-language pairs!"; \
		  for a in $$S; do \
		    for b in $$T; do \
		      if [ "$$a-$$b" != ${LANGPAIRSTR} ]; then \
		        if [ ! -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.src ]; then \
	                  echo "make Tatoeba-test.$$a-$$b"; \
		          if [ "${USE_TARGET_LABELS}" == "1" ]; then \
		            grep "$$a	$$b	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			    cut -f2,3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.src; \
		          else \
		            grep "$$a	$$b	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			    cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.src; \
		          fi; \
		          grep "$$a	$$b	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
		          cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.trg; \
		        fi \
	              fi \
		    done \
		  done \
		fi; \
	      else \
	        wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp \
			${TATOEBA_RAWGIT}/data/test/$$t-$$s/test.txt; \
	        if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp ]; then \
		  cat ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp $(FIXLANGIDS) \
			> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
		  if [ "$$s-$$t" != ${LANGPAIRSTR} ]; then \
	            echo "make Tatoeba-test.$$s-$$t"; \
		    if [ "${USE_TARGET_LABELS}" == "1" ]; then \
	              cut -f1,4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
		      sed 's/^\([^ ]*\)	/>>\1<< /' \
		      > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		    else \
		      cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		      > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		    fi; \
	            cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
		  fi; \
		  S=`cut -f2 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		  T=`cut -f1 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		  if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
		    echo "extracting test sets for individual sub-language pairs!"; \
		    for a in $$S; do \
		      for b in $$T; do \
		        if [ "$$a-$$b" != ${LANGPAIRSTR} ]; then \
		          if [ ! -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.src ]; then \
	                    echo "make Tatoeba-test.$$a-$$b"; \
		            if [ "${USE_TARGET_LABELS}" == "1" ]; then \
		              grep "$$b	$$a	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			      cut -f1,4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			      > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.src; \
		            else \
		              grep "$$b	$$a	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
			      cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			      > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.src; \
		            fi; \
		            grep "$$b	$$a	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
		            cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$a-$$b.trg; \
		          fi \
		        fi \
		      done \
		    done \
		  fi; \
		fi \
	      fi; \
	      rm -f ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp; \
	      rm -f ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
	  done \
	done
	if [ -d ${dir $@} ]; then \
	  touch $@; \
	fi





# ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-testsets-with-subsets.done:
# 	@for s in ${SRCLANGS}; do \
# 	  for t in ${TRGLANGS}; do \
# 	      wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp \
# 			${TATOEBA_RAWGIT}/data/test/$$s-$$t/test.txt; \
# 	      if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp ]; then \
# 	        echo "make Tatoeba-test.$$s-$$t"; \
# 		cat ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp $(FIXLANGIDS) \
# 		> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
# 		if [ "${USE_TARGET_LABELS}" == "1" ]; then \
# 	          cut -f2,3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
# 		  sed 's/^\([^ ]*\)	/>>\1<< /' \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		else \
# 		  cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		fi; \
# 	        cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
# 		S=`cut -f1 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
# 		T=`cut -f2 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
# 		echo "languages found: $$S $$T"; \
# 		if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
# 		  echo "extracting test sets for individual sub-language pairs!"; \
# 		  for a in $$S; do \
# 		    for b in $$T; do \
# 	              echo "make Tatoeba-test.$$s-$$t.$$a-$$b"; \
# 		      if [ "${USE_TARGET_LABELS}" == "1" ]; then \
# 		        grep "$$a	$$b	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			cut -f2,3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
# 			> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.$$a-$$b.src; \
# 		      else \
# 		        grep "$$a	$$b	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
# 			> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.$$a-$$b.src; \
# 		      fi; \
# 		      grep "$$a	$$b	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 		      cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
# 			> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.$$a-$$b.trg; \
# 		    done \
# 		  done \
# 		fi; \
# 	      else \
# 	        wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp \
# 			${TATOEBA_RAWGIT}/data/test/$$t-$$s/test.txt; \
# 	        if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp ]; then \
# 	          echo "make Tatoeba-test.$$s-$$t"; \
# 		  cat ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp $(FIXLANGIDS) \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
# 		  if [ "${USE_TARGET_LABELS}" == "1" ]; then \
# 	            cut -f1,4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
# 		    sed 's/^\([^ ]*\)	/>>\1<< /' \
# 		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		  else \
# 		    cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
# 		  fi; \
# 	          cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
# 		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
# 		  S=`cut -f2 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
# 		  T=`cut -f1 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
# 		  echo "languages found: $$S $$T"; \
# 		  if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
# 		    echo "extracting test sets for individual sub-language pairs!"; \
# 		    for a in $$S; do \
# 		      for b in $$T; do \
# 	                echo "make Tatoeba-test.$$s-$$t.$$a-$$b"; \
# 		        if [ "${USE_TARGET_LABELS}" == "1" ]; then \
# 		          grep "$$b	$$a	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			  cut -f1,4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
# 			  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.$$a-$$b.src; \
# 		        else \
# 		          grep "$$b	$$a	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 			  cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
# 			  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.$$a-$$b.src; \
# 		        fi; \
# 		        grep "$$b	$$a	" < ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt |\
# 		        cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
# 			  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.$$a-$$b.trg; \
# 		      done \
# 		    done \
# 		  fi; \
# 		fi \
# 	      fi; \
# 	      rm -f ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.tmp; \
# 	      rm -f ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
# 	  done \
# 	done
# 	if [ -d ${dir $@} ]; then \
# 	  touch $@; \
# 	fi






## TODO:
## get test sets for sublanguages in sets of macro-languages

${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-testsets-langpairs.done:
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	  done \
	done




##----------------------------------------------------------------------------
## TODO: we need some procedures to run evaluations
##       for already released models
##       the code below fails because of various dependencies etc ...
##----------------------------------------------------------------------------

RELEASED_TATOEBA_MODEL = fiu-cpp/opus-2021-02-18.zip
RELEASED_TATOEBA_SRC2TRG = $(subst -,2,$(subst /,,$(dir ${RELEASED_TATOEBA_MODEL})))
RELEASED_TATOEBA_MODEL_URL = https://object.pouta.csc.fi/${TATOEBA_MODEL_CONTAINER}/${RELEASED_TATOEBA_MODEL}
EVAL_TATOEBA_WORKHOME  = ${PWD}/work-eval
EVAL_TATOEBA_WORKDIR   = ${EVAL_TATOEBA_WORKHOME}/$(dir ${RELEASED_TATOEBA_MODEL})

evaluate-released-tatoeba-model:
	mkdir -p ${EVAL_TATOEBA_WORKDIR}
	wget -O ${EVAL_TATOEBA_WORKHOME}/${RELEASED_TATOEBA_MODEL} ${RELEASED_TATOEBA_MODEL_URL}
	cd ${EVAL_TATOEBA_WORKDIR} && unzip -o $(notdir ${RELEASED_TATOEBA_MODEL})
	${MAKE} TATOEBA_WORK=${EVAL_TATOEBA_WORKHOME} \
		DECODER_CONFIG=${EVAL_TATOEBA_WORKDIR}decoder.yml \
		MODEL_FINAL=`grep .npz ${EVAL_TATOEBA_WORKDIR}decoder.yml | sed 's/^ *- *//'` \
		SPMSRCMODEL=${EVAL_TATOEBA_WORKDIR}source.spm \
		SPMTRGMODEL=${EVAL_TATOEBA_WORKDIR}target.spm \
	tatoeba-${RELEASED_TATOEBA_SRC2TRG}-testsets

##----------------------------------------------------------------------------




###############################################################################
## generic targets for tatoba models
###############################################################################

.PHONY: tatoeba-langlabel-files
tatoeba-langlabel-files: 	${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
				${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.trg \
				${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-languages.src \
				${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-languages.trg

${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-languages.%: ${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.%
	mkdir -p ${dir $@}
	cat $< | tr ' ' "\n" | cut -f1 -d'_' | cut -f1 -d'-' | \
	sed 's/ *$$//;s/^ *//' | tr "\n" ' '  > $@


## generic target for tatoeba challenge jobs
%-tatoeba: ${TATOEBA_SRCLABELFILE} ${TATOEBA_TRGLABELFILE}
	${MAKE} ${TATOEBA_PARAMS} \
		LANGPAIRSTR=${LANGPAIRSTR} \
		SRCLANGS="${shell cat ${word 1,$^}}" \
		TRGLANGS="${shell cat ${word 2,$^}}" \
		SRC=${SRC} TRG=${TRG} \
		EMAIL= \
	${@:-tatoeba=}


%-bttatoeba: 	${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
		${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.trg
	for s in ${shell cat ${word 1,$^}}; do \
	  for t in ${shell cat ${word 2,$^}}; do \
	    echo "${MAKE} -C backtranslate \
		SRC=$$s TRG=$$t \
		WIKI_HOME=wiki-iso639-3 \
		WIKIDOC_HOME=wikidoc-iso639-3 \
		MODELHOME=../models-tatoeba/${LANGPAIR} \
	    ${@:-bttatoeba=}"; \
	  done \
	done



## don't delete intermediate label files
.PRECIOUS: 	${TATOEBA_DATA}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz \
		${TATOEBA_DATA}/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz


## fetch data for all language combinations
## TODO: should we check whether we are supposed to skip some language pairs?

.PHONY: fetch-tatoeba-datasets
fetch-tatoeba-datasets:
	-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ "$$s" \< "$$t" ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t \
		${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$s.gz; \
	    else \
	      ${MAKE} SRCLANGS=$$t TRGLANGS=$$s \
		${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$t.gz; \
	    fi \
	  done \
	done


## collect all language labels in all language pairs
## (each language pair may include several language variants)
## --> this is necessary to set the languages that are present in a model

${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.src:
	${MAKE} fetch-tatoeba-datasets
	mkdir -p ${dir $@}
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      elif [ -e ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      fi; \
	      if [ -e ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      elif [ -e ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$t.labels >> $@.trg; \
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


${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.trg: ${TATOEBA_WORK}/${LANGPAIRSTR}/${DATASET}-langlabels.src
	if [ ! -e $@ ]; then rm $<; ${MAKE} $<; fi
	echo "done"


###############################################################################
## generate data files
###############################################################################


## don't delete those files
.SECONDARY: ${TATOEBA_DATA}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_DATA}/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_DATA}/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz

##-------------------------------------------------------------
## take care of languages IDs
## --> simplify some IDs from training data
## --> decide which ones to keep that do not exist in test data
##-------------------------------------------------------------

## langids that we want to keep from the training data even if they do not exist in the Tatoeba test sets
## (skip most lang-IDs because they mostly come from erroneous writing scripts --> errors in the data)
## the list is based on Tatoeba-Challenge/data/langids-train-only.txt

# TRAIN_ONLY_LANGIDS   = ${shell cat tatoeba/langids-train-only.txt ${FIXLANGIDS} | grep -v '^...$$' | tr "\n" ' '}
TRAIN_ONLY_LANGIDS   = ${shell cat tatoeba/langids-train-only.txt | tr "\n" ' '}
KEEP_LANGIDS         = bos_Cyrl cmn cnr cnr_Latn csb diq dnj dty fas fqs ful fur gcf got gug hbs hbs_Cyrl hmn \
			jak_Latn kam kmr kmr_Latn kom kur_Cyrl kuv_Arab kuv_Latn lld mol mrj msa_Latn mya_Cakm nep ngu \
			nor nor_Latn oss_Latn pan plt pnb_Guru pob prs qug quw quy quz qvi rmn rmy ruk san swa swc \
			syr syr_Syrc tgk_Latn thy tlh tmh toi tuk_Cyrl urd_Deva xal_Latn yid_Latn zho zlm
SKIP_LANGIDS         = ${filter-out ${KEEP_LANGIDS},${TRAIN_ONLY_LANGIDS}} \
			ang ara_Latn arq_Latn apc_Latn bul_Latn ell_Latn heb_Latn nob_Hebr rus_Latn
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
		| sed 's/jpn_[A-Za-z]*/jpn/g' \
		| sed 's/kor_[A-Za-z]*/kor/g' \
		| sed 's/nor_Latn/nor/g' \
		| sed 's/nor/nob/g' \
		| sed 's/bul_Latn/bul/g' \
		| sed 's/syr_Syrc/syr/g' \
		| sed 's/yid_Latn/yid/g' \
		| perl -pe 'if (/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/){if ($$2 ne "Hans" && $$2 ne "Hant"){s/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/$$1/} }'


#		| sed 's/ara_Latn/ara/;s/arq_Latn/arq/;' \



print-skiplangids:
	@echo ${SKIP_LANGIDS_PATTERN}


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


## convert Tatoeba Challenge data into the format we need
## - move the data into the right location with the suitable name
## - create devset if not given (part of training data)
## - divide into individual language pairs 
##   (if there is more than one language pair in the collection)
## 
## TODO: should we do some filtering like bitext-match, OPUS-filter ...
%/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz:
	@mkdir -p $@.d
	-wget -q -O $@.d/train.tar ${TATOEBA_TRAIN_URL}/${LANGPAIR}.tar
	-tar -C $@.d -xf $@.d/train.tar
	@rm -f $@.d/train.tar
	@if [ -e $@.d/data/${LANGPAIR}/test.src ]; then \
	  echo "........ move test files to ${dir $@}Tatoeba-test.${LANGPAIR}.clean.*"; \
	  mv $@.d/data/${LANGPAIR}/test.src ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}; \
	  mv $@.d/data/${LANGPAIR}/test.trg ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}; \
	  cat $@.d/data/${LANGPAIR}/test.id $(FIXLANGIDS) > ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id; \
	fi
	@if [ -e $@.d/data/${LANGPAIR}/dev.src ]; then \
	  mv $@.d/data/${LANGPAIR}/dev.src ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	  mv $@.d/data/${LANGPAIR}/dev.trg ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	  cat $@.d/data/${LANGPAIR}/dev.id $(FIXLANGIDS) > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	  if [ -e $@.d/data/${LANGPAIR}/train.src.gz ]; then \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.src.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.trg.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz | cut -f1 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.domain; \
	  fi; \
	else \
	  if [ -e $@.d/data/${LANGPAIR}/train.src.gz ]; then \
	    echo "no devdata available - get top 1000 from training data!"; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.src.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | head -1000 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | head -1000 | cut -f1 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.domain; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.src.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | tail -n +1001 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | tail -n +1001 | cut -f1 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.domain; \
	  fi \
	fi
## make sure that training data file exists even if it is empty
	@if [ -e ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT} ]; then \
	  touch ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	  touch ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	fi
#######################################
# save all lang labels that appear in the data
#######################################
	@cut -f1 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | \
		grep -v '${SKIP_LANGIDS_PATTERN}' | \
		tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)
	@cut -f2 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | \
		grep -v '${SKIP_LANGIDS_PATTERN}' | \
		tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)
	@cat ${dir $@}Tatoeba-*.${LANGPAIR}.clean.domain | sort -u |\
		tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.${SRCEXT}.gz=.domains)
#######################################
# cleanup temporary data
#######################################
	@if [ -d $@.d/data ]; then \
	  rm -f $@.d/data/${LANGPAIR}/*; \
	  rmdir $@.d/data/${LANGPAIR}; \
	  rmdir $@.d/data; \
	fi
	@rm -f $@.d/train.tar
	@rmdir $@.d
#######################################
# make data sets for individual 
# language pairs from the Tatoeba data
#######################################
	@if [ -e $(@:.${SRCEXT}.gz=.${SRCEXT}.labels) ]; then \
	  for s in `cat $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)`; do \
	    for t in `cat $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)`; do \
	      if [ "$$s" \< "$$t" ]; then \
	        echo "extract $$s-$$t data"; \
	        for d in dev test train; do \
		  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id ]; then \
	            paste ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id \
		          ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT} \
		          ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT} |\
	            grep -P "$$s\t$$t\t" > ${dir $@}Tatoeba-$$d.$$s-$$t; \
	            if [ -s ${dir $@}Tatoeba-$$d.$$s-$$t ]; then \
	              echo "........ make ${dir $@}Tatoeba-$$d.$$s-$$t.clean.*.gz"; \
	              cut -f3 ${dir $@}Tatoeba-$$d.$$s-$$t | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$s-$$t.clean.$$s.gz; \
	              cut -f4 ${dir $@}Tatoeba-$$d.$$s-$$t | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$s-$$t.clean.$$t.gz; \
	            fi; \
	            rm -f ${dir $@}Tatoeba-$$d.$$s-$$t; \
		  fi \
	        done \
	      else \
	        echo "extract $$t-$$s data"; \
	        for d in dev test train; do \
		  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id ]; then \
	            paste ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id \
		          ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT} \
		          ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT} |\
	            grep -P "$$s\t$$t\t" > ${dir $@}Tatoeba-$$d.$$t-$$s; \
	            if [ -s ${dir $@}Tatoeba-$$d.$$t-$$s ]; then \
	              echo "........ make ${dir $@}Tatoeba-$$d.$$t-$$s.clean.*.gz"; \
	              cut -f3 ${dir $@}Tatoeba-$$d.$$t-$$s | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$t-$$s.clean.$$t.gz; \
	              cut -f4 ${dir $@}Tatoeba-$$d.$$t-$$s | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$t-$$s.clean.$$s.gz; \
	            fi; \
	            rm -f ${dir $@}Tatoeba-$$d.$$t-$$s; \
		  fi \
	        done \
	      fi \
	    done \
	  done \
	fi
#######################################
# Finally, compress the big files with
# all the different language variants.
# If the code is the same as one of the
# variants then remove the file instead.
#######################################
	@for d in dev test train; do \
	  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT} ]; then \
	    if [ ! -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}.gz ]; then \
	      echo "........... compress ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}"; \
	      ${GZIP} ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}; \
	    else \
	      rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}; \
	    fi \
	  fi; \
	  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT} ]; then \
	    if [ ! -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}.gz ]; then \
	      echo "........... compress ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}"; \
	      ${GZIP} ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}; \
	    else \
	      rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}; \
	    fi \
	  fi; \
	  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.domain ]; then \
	    if [ ! -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.domain.gz ]; then \
	      ${GZIP} ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.domain; \
	    else \
	      rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.domain; \
	    fi \
	  fi; \
	  rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id; \
	done




## all the following data sets are created in the target of the
#@ source language training data

%/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"

%/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz %/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"

%/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz %/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"





test-tune-data: 
	make SRCEXT=bre TRGEXT=eng LANGPAIR=bre-eng \
	 ${TATOEBA_WORK}-test/data/simple/Tatoeba-OpenSubtitles-train.bre-eng.clean.bre.gz


## TODO: should we split into train/dev/test
##       problem: that would overlap with the previous training data

%/Tatoeba-${TUNE_DOMAIN}-train.${LANGPAIR}.clean.${SRCEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	paste 	<(gzip -cd ${<:.${SRCEXT}.gz=.domain.gz}) \
		<(gzip -cd $<) \
		<(gzip -cd ${<:.${SRCEXT}.gz=.${TRGEXT}.gz}) | \
	grep '^${TUNE_DOMAIN}	' |\
	tee >(cut -f1 | gzip -c >${@:.${SRCEXT}.gz=.domain.gz}) >(cut -f2 | gzip -c >$@) | \
	cut -f3 | gzip -c > ${@:.${SRCEXT}.gz=.${TRGEXT}.gz}




## make Tatoeba test files available in testset collection
## --> useful for testing various languages when creating multilingual models
testsets/${LANGPAIR}/Tatoeba-test.${LANGPAIR}.%: ${TATOEBA_DATA}/Tatoeba-test.${LANGPAIR}.clean.%
	mkdir -p ${dir $@}
	cp $< $@



# ###############################################################################
# ## generate result tables
# ###############################################################################

# TATOEBA_READMES = $(wildcard models-tatoeba/*/README.md)

# # RESULT_MDTABLE_HEADER = | Model | Language Pair | Test Set | chrF2 | BLEU | BP | Reference Length |\n|:---|----|----|----:|---:|----:|---:|\n
# # ADD_MDHEADER = perl -pe '@a=split;print "\n${RESULT_MDTABLE_HEADER}" if ($$b ne $$a[1]);$$b=$$a[1];'

# results/tatoeba-results-al%.md: tatoeba-results-al%
# 	mkdir -p ${dir $@}
# 	echo "# Tatoeba translation results" >$@
# 	echo "" >>$@
# 	echo "Note that some links to the actual models below are broken"                  >> $@
# 	echo "because the models are not yet released or their performance is too poor"    >> $@
# 	echo "to be useful for anything."                                                  >> $@
# 	echo ""                                                                            >> $@
# 	echo '| Model | Test Set | chrF2 | BLEU | BP | Reference Length |' >> $@
# 	echo '|:--|---|--:|--:|--:|--:|'                                                   >> $@
# 	grep -v '^model' $< | grep -v -- '----' | grep . | sort -k2,2 -k3,3 -k4,4nr |\
# 	perl -pe '@a=split;print "| lang = $$a[1] | | | |\n" if ($$b ne $$a[1]);$$b=$$a[1];' |\
# 	cut -f1,3- |\
# 	perl -pe '/^(\S*)\/(\S*)\t/;if (-d "models-tatoeba/$$1"){s/^(\S*)\/(\S*)\t/[$$1\/$$2](..\/models\/$$1)\t/;}' |\
# 	sed 's/	/ | /g;s/^/| /;s/$$/ |/;s/Tatoeba-test/tatoeba/' |\
# 	sed 's/\(news[^ ]*\)-...... /\1 /;s/\(news[^ ]*\)-.... /\1 /;'                     >> $@

# # sed 's#^\([^ 	]*\)/\([^ 	]*\)#[\1/\2](../models/\1)#' |\


# results/tatoeba-models-all.md: tatoeba-models-all
# 	mkdir -p ${dir $@}
# 	echo "# Tatoeba translation models" >$@
# 	echo "" >>$@
# 	echo "The scores refer to results on Tatoeba-test data"                            >> $@
# 	echo "For multilingual models, it is a mix of all language pairs"                  >> $@
# 	echo ""                                                                            >> $@
# 	echo '| Model | chrF2 | BLEU | BP | Reference Length |'                            >> $@
# 	echo '|:--|--:|--:|--:|--:|'                                                       >> $@
# 	cut -f1,4- $< | \
# 	perl -pe '/^(\S*)\/(\S*)\t/;if (-d "models-tatoeba/$$1"){s/^(\S*)\/(\S*)\t/[$$1\/$$2](..\/models\/$$1)\t/;}' |\
# 	sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                                   >> $@


# ## update files in the workdir
# ## (to be included in the git repository)

# ${TATOEBA_WORK}/tatoeba-results%: tatoeba-results%
# 	mkdir -p ${dir $@}
# 	-cat $@ > $@.old
# 	cp $< $@.new
# 	cat $@.old $@.new | sort | uniq > $@
# 	rm -f $@.old $@.new

# ${TATOEBA_WORK}/tatoeba-models-all: tatoeba-models-all
# 	mkdir -p ${dir $@}
# 	-cat $@ > $@.old
# 	cp $< $@.new
# 	cat $@.old $@.new | sort | uniq > $@
# 	rm -f $@.old $@.new

# ## get all results for all models and test sets
# tatoeba-results-all: ${TATOEBA_READMES}
# 	find ${TATOEBA_WORK} -name '*.eval' | sort | xargs grep chrF2 > $@.1
# 	find ${TATOEBA_WORK} -name '*.eval' | sort | xargs grep BLEU  > $@.2
# 	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.\([^\.]*\)\.eval:.*$$/\1-\2/' > $@.langpair
# 	cut -f3 -d '/' $@.1 | sed 's/\.\([^\.]*\)\.spm.*$$//;s/Tatoeba-test[^	]*/Tatoeba-test/' > $@.testset
# 	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.dataset
# 	cut -f2 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.modeldir
# 	cut -f2 -d '=' $@.1 | cut -f2 -d ' ' > $@.chrF2
# 	cut -f2 -d '=' $@.2 | cut -f2 -d ' ' > $@.bleu
# 	cut -f3 -d '=' $@.2 | cut -f2 -d ' ' > $@.bp
# 	cut -f6 -d '=' $@.2 | cut -f2 -d ' ' | cut -f1 -d')' > $@.reflen
# 	paste -d'/' $@.modeldir $@.dataset > $@.model
# 	paste $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen > $@
# 	rm -f $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen
# 	rm -f $@.modeldir $@.dataset $@.1 $@.2

# tatoeba-models-all: ${TATOEBA_READMES}
# 	find ${TATOEBA_WORK} -name 'Tatoeba-test.opus*.eval' | sort | xargs grep chrF2 > $@.1
# 	find ${TATOEBA_WORK} -name 'Tatoeba-test.opus*.eval' | sort | xargs grep BLEU  > $@.2
# 	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.\([^\.]*\)\.eval:.*$$/\1-\2/' > $@.langpair
# 	cut -f3 -d '/' $@.1 | sed 's/\.\([^\.]*\)\.spm.*$$//;s/Tatoeba-test[^	]*/Tatoeba-test/' > $@.testset
# 	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.dataset
# 	cut -f2 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.modeldir
# 	cut -f2 -d '=' $@.1 | cut -f2 -d ' ' > $@.chrF2
# 	cut -f2 -d '=' $@.2 | cut -f2 -d ' ' > $@.bleu
# 	cut -f3 -d '=' $@.2 | cut -f2 -d ' ' > $@.bp
# 	cut -f6 -d '=' $@.2 | cut -f2 -d ' ' | cut -f1 -d')' > $@.reflen
# 	paste -d'/' $@.modeldir $@.dataset > $@.model
# 	paste $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen > $@
# 	rm -f $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen
# 	rm -f $@.modeldir $@.dataset $@.1 $@.2

# models-tatoeba/released-models.txt: ${TATOEBA_READMES}
# 	-cat $@ > $@.old
# 	find models-tatoeba/ -name '*.eval.txt' | sort | xargs grep chrF2 > $@.1
# 	find models-tatoeba/ -name '*.eval.txt' | sort | xargs grep BLEU > $@.2
# 	cut -f3 -d '/' $@.1 | sed 's/\.eval.txt.*$$/.zip/' > $@.zip
# 	cut -f2 -d '/' $@.1 > $@.iso639-3
# 	paste -d '/' $@.iso639-3 $@.zip | sed 's#^#${TATOEBA_DATAURL}/#' > $@.url
# 	cut -f2 -d '/' $@.1 | xargs iso639 -2 -k -p | tr ' ' "\n" > $@.iso639-1
# 	cut -f2 -d '=' $@.1 | cut -f2 -d ' ' > $@.chrF2
# 	cut -f2 -d '=' $@.2 | cut -f2 -d ' ' > $@.bleu
# 	cut -f3 -d '=' $@.2 | cut -f2 -d ' ' > $@.bp
# 	cut -f6 -d '=' $@.2 | cut -f2 -d ' ' | cut -f1 -d')' > $@.reflen
# 	cut -f2 -d '/' $@.1 | sed 's/^\([^ \-]*\)$$/\1-\1/g' | tr '-' ' ' | \
# 	xargs iso639 -k | sed 's/$$/ /' |\
# 	sed -e 's/\" \"\([^\"]*\)\" /\t\1\n/g' | sed 's/^\"//g' > $@.langs
# 	paste $@.url $@.iso639-3 $@.iso639-1 $@.chrF2 $@.bleu $@.bp $@.reflen $@.langs > $@
# 	rm -f $@.url $@.iso639-3 $@.iso639-1 $@.chrF2 $@.bleu $@.bp $@.reflen $@.1 $@.2 $@.langs $@.zip
# 	cat $@.old $@.new | sort | uniq > $@
# 	rm -f $@.old $@.new

# models-tatoeba/released-model-results.txt: ${TATOEBA_READMES}
# 	-cat $@ > $@.old
# 	find models-tatoeba/ -name 'README.md' | sort | \
# 	xargs egrep -h '^(# |\| Tatoeba-test|\* download:)' |\
# 	tr "\t" " " | tr "\n" "\t" | sed "s/# /\n# /g" |\
# 	perl -e 'while (<>){s/^.*\((.*)\)/\1/;@_=split(/\t/);$$m=shift(@_);for (@_){print "$$_\t$$m\n";}}' |\
# 	grep -v '.multi.' |\
# 	sed -e 's/Tatoeba-test.\S*\(...\....\) /\1/' |\
# 	grep '^|' |\
# 	sed -e 's/ *| */\t/g' | cut -f2,3,4,6 > $@.new
# 	cat $@.old $@.new | sort -k1,1 -k3,3nr -k2,2nr -k4,4 | uniq > $@
# 	rm -f $@.old $@.new

# ## new: also consider the opposite translation direction!
# tatoeba-results-all-subset-%: tatoeba-%.md tatoeba-results-all-sorted-langpair
# 	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | sort -u  | tr "\n" '|' | sed 's/|$$//;s/\-/\\\-/g'}"; \
# 	  r="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | sort -u  | sed 's/\(...\)-\(...\)/\2-\1/' | tr "\n" '|' | sed 's/|$$//;s/\-/\\\-/g'}"; \
# 	  grep -P "$$l|$$r" ${word 2,$^} |\
# 	  perl -pe '@a=split;print "\n${RESULT_TABLE_HEADER}" if ($$b ne $$a[1]);$$b=$$a[1];' > $@ )

# tatoeba-results-all-langgroup: tatoeba-results-all
# 	grep -P "${subst ${SPACE},-eng|,${OPUS_LANG_GROUPS}}-eng" $< >> $@
# 	grep -P "eng-${subst ${SPACE},|eng-,${OPUS_LANG_GROUPS}}" $< >> $@
# 	grep -P "`echo '${OPUS_LANG_GROUPS}' | sed 's/\([^ ][^ ]*\)/\1-\1/g;s/ /\|/g'`" $< >> $@


# RESULT_TABLE_HEADER=model\tlanguage-pair\ttestset\tchrF2\tBLEU\tBP\treference-length\n--------------------------------------------------------------------------\n

# tatoeba-results-all-sorted-langpair: tatoeba-results-all
# 	sort -k2,2 -k3,3 -k4,4nr < $< |\
# 	perl -pe '@a=split;print "\n${RESULT_TABLE_HEADER}" if ($$b ne $$a[1]);$$b=$$a[1];' \
# 	> $@

# tatoeba-results-all-sorted-chrf2: tatoeba-results-all
# 	sort -k3,3 -k4,4nr < $< > $@

# tatoeba-results-all-sorted-bleu: tatoeba-results-all
# 	sort -k3,3 -k5,5nr < $< > $@




# #############
# ## OLD ones
# #############


# results/tatoeba-results-langgroup.md: tatoeba-results-langgroup
# 	mkdir -p ${dir $@}
# 	echo "# Tatoeba translation results"                                             > $@
# 	echo ""                                                                         >> $@
# 	echo "Multilingual models for language groups according to ISO639-5."           >> $@
# 	echo ""                                                                         >> $@
# 	echo "Note that some links to the actual models below are broken"               >> $@
# 	echo "because the models are not yet released or their performance is too poor" >> $@
# 	echo "to be useful for anything."                                               >> $@
# 	echo ""                                                                         >> $@
# 	echo "| Source | Target | Model | Test Set      | chrF2 | BLEU |"               >> $@
# 	echo "|--------|--------|------:|---------------|------:|-----:|"               >> $@
# 	grep multi $< | cut -f1 | xargs iso639 -p | tr '"' "\n" | \
# 		grep [a-z] | \
# 		sed 's/based\-/based | /' |\
# 		sed 's/languages\-/languages | /' |\
# 		sed 's/English\-/English | /;s/^/| /;s/$$/ /'  > $@.langpair
# 	grep multi $< |\
# 	sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
# 	sed 's/	/ | /g;s/^/| /;s/$$/ |/'                       > $@.rest
# 	paste $@.langpair $@.rest -d ' '                                                >> $@
# 	echo ""                                                                         >> $@
# 	echo "## Performance on individual language pairs"                              >> $@
# 	echo ""                                                                         >> $@
# 	echo "Note that some of the test sets are way too small to be reliable!"        >> $@
# 	echo ""                                                                         >> $@
# 	echo "| Source | Target | Model | Test Set      | chrF2 | BLEU |"               >> $@
# 	echo "|--------|--------|------:|---------------|------:|-----:|"               >> $@
# 	grep -v multi $< | cut -f1 | xargs iso639 -p | tr '"' "\n" | \
# 		grep [a-z] | \
# 		sed 's/based\-/based | /' |\
# 		sed 's/languages\-/languages | /' |\
# 		sed 's/English\-/English | /;s/^/| /;s/$$/ /'  > $@.langpair
# 	grep -v multi $< |\
# 	sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
# 	sed 's/	/ | /g;s/^/| /;s/$$/ |/'                       > $@.rest
# 	paste $@.langpair $@.rest -d ' '                                                >> $@
# 	rm -f $@.langpair $@.rest


# results/tatoeba-results-%.md: tatoeba-results-% tatoeba-results-BLEU-sorted-model
# 	mkdir -p ${dir $@}
# 	echo "# Tatoeba translation results" >$@
# 	echo "" >>$@
# 	echo "Note that some links to the actual models below are broken"               >>$@
# 	echo "because the models are not yet released or their performance is too poor" >> $@
# 	echo "to be useful for anything."                                               >> $@
# 	echo "" >>$@
# 	echo "| Model                 | Test Set   | chrF2      | BLEU     |"           >> $@
# 	echo "|----------------------:|------------|-----------:|---------:|"           >> $@
# 	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
# 	  grep -v -P "\t($$p)\t" $< |\
# 	  sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
# 	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                        >> $@ )



# results/tatoeba-results-chrF2%.md: tatoeba-results-chrF2% tatoeba-results-BLEU-sorted-model
# 	mkdir -p ${dir $@}
# 	echo "# Tatoeba translation results" >$@
# 	echo "" >>$@
# 	echo "| Model            | Test Set   | chrF2      |"               >> $@
# 	echo "|-----------------:|------------|-----------:|"                    >> $@
# 	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
# 	  grep -v -P "\t($$p)\t" $< |\
# 	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                 >> $@ )

# results/tatoeba-results-BLEU%.md: tatoeba-results-BLEU% tatoeba-results-BLEU-sorted-model
# 	mkdir -p ${dir $@}
# 	echo "# Tatoeba translation results" >$@
# 	echo "" >>$@
# 	echo "| Model            | Test Set   | BLEU       | Details  |"    >> $@
# 	echo "|-----------------:|------------|-----------:|---------:|"         >> $@
# 	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
# 	  grep -v -P "\t($$p)\t" $< |\
# 	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                 >> $@ )

# tatoeba-results-sorted:
# 	grep chrF2 ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' > $@.1
# 	grep BLEU ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	cut -f3 -d' ' > $@.2
# 	paste $@.1 $@.2 | sort -k3,3nr > $@
# 	rm -f $@.1 $@.2

# ## results with chrF and BLEU scores sorted by language pair
# tatoeba-results-sorted-langpair:
# 	grep chrF2 ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' > $@.1
# 	grep BLEU ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	cut -f3 -d' ' > $@.2
# 	paste $@.1 $@.2 | sort -k2,2 -k3,3nr > $@
# 	rm -f $@.1 $@.2

# tatoeba-results-sorted-model:
# 	grep chrF2 ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' > $@.1
# 	grep BLEU ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	cut -f3 -d' ' > $@.2
# 	paste $@.1 $@.2 | sort -k1,1 -k3,3nr > $@
# 	rm -f $@.1 $@.2

# tatoeba-results-BLEU-sorted:
# 	grep BLEU ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/BLEU.*1.4.2//' | cut -f2- -d'/' |sort -k3,3nr | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' | sed 's/\([0-9]\) /\1	/' | grep -v eval > $@

# tatoeba-results-BLEU-sorted-model:
# 	grep BLEU ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/BLEU.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#'  | sed 's/\([0-9]\) /\1	/' | \
# 	grep -v eval | sort -k1,1 -k3,3nr > $@

# tatoeba-results-BLEU-sorted-langpair:
# 	grep BLEU ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/BLEU.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#'  | sed 's/\([0-9]\) /\1	/' | \
# 	grep -v eval | sort -k2,2 -k3,3nr > $@

# tatoeba-results-chrF2-sorted:
# 	grep chrF2 ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' |sort -k3,3nr | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' > $@

# tatoeba-results-chrF2-sorted-model:
# 	grep chrF2 ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/chrF.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' | sort -k1,1 -k3,3nr > $@

# tatoeba-results-chrF2-sorted-langpair:
# 	grep chrF2 ${TATOEBA_WORK}/*/Tatoeba-test.*eval | \
# 	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
# 	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
# 	sed "s#/.#\t#" | \
# 	sed 's#.eval: = #\t#' | sort -k2,2 -k3,3nr > $@

# ## scores per subset
# tatoeba-results-subset-%: tatoeba-%.md tatoeba-results-sorted-langpair
# 	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | sort -u  | tr "\n" '|' | tr '-' '.' | sed 's/|$$//;s/\./\\\./g'}"; \
# 	  grep -P "$$l" ${word 2,$^} > $@ )

# tatoeba-results-langgroup: tatoeba-results-sorted-model
# 	grep -P "${subst ${SPACE},-eng|,${OPUS_LANG_GROUPS}}-eng" $< >> $@
# 	grep -P "eng-${subst ${SPACE},|eng-,${OPUS_LANG_GROUPS}}" $< >> $@
# 	grep -P "`echo '${OPUS_LANG_GROUPS}' | sed 's/\([^ ][^ ]*\)/\1-\1/g;s/ /\|/g'`" $< >> $@











###############################################################################
# auxiliary functions (REMOVE?)
###############################################################################


WRONGFILES = ${patsubst %.eval,%,${wildcard ${TATOEBA_WORK}/*/Tatoeba-test.opus*.eval}}

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
	  rm -f ${TATOEBA_WORK}/$$g-eng/Tatoeba-test.opus.spm32k-spm32k1.transformer.???.eng*; \
	  rm -f ${TATOEBA_WORK}/eng-$$g/Tatoeba-test.opus.spm32k-spm32k1.transformer.eng.???; \
	  rm -f ${TATOEBA_WORK}/eng-$$g/Tatoeba-test.opus.spm32k-spm32k1.transformer.eng.???.*; \
	done


remove-old-group:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ -e ${TATOEBA_WORK}/$$g-eng ]; then mv ${TATOEBA_WORK}/$$g-eng ${TATOEBA_WORK}/$$g-eng-old3; fi; \
	  if [ -e ${TATOEBA_WORK}/eng-$$g ]; then mv ${TATOEBA_WORK}/eng-$$g ${TATOEBA_WORK}/eng-$$g-old3; fi; \
	done




## resume training for all bilingual models that are not yet converged
.PHONY: tatoeba-resume-all tatoeba-continue-all
tatoeba-resume-all tatoeba-continue-all:
	for l in `find ${TATOEBA_WORK}/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	      if [ -d ${TATOEBA_WORK}/$$l ]; then \
		if [ ! `find ${TATOEBA_WORK}/$$l/ -maxdepth 1 -name '*.done' | wc -l` -gt 0 ]; then \
		  if [ `find ${TATOEBA_WORK}/$$l/ -maxdepth 1 -name '*.npz' | wc -l` -gt 0 ]; then \
		    echo "resume ${TATOEBA_WORK}/$$l"; \
		    make SRCLANGS=$$s TRGLANGS=$$t all-job-tatoeba; \
		  else \
		    echo "resume ${TATOEBA_WORK}/$$l"; \
		    make SRCLANGS=$$s TRGLANGS=$$t tatoeba-job; \
		  fi \
		else \
		  echo "done ${TATOEBA_WORK}/$$l"; \
		fi \
	      fi \
	  fi \
	done


## make release package for all bilingual models that are converged
.PHONY: tatoeba-dist-all
tatoeba-dist-all:
	for l in `find ${TATOEBA_WORK}/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	      if [ -d ${TATOEBA_WORK}/$$l ]; then \
		if [ `find ${TATOEBA_WORK}/$$l/ -maxdepth 1 -name '*transformer-align.model1.done' | wc -l` -gt 0 ]; then \
		  echo "make release for ${TATOEBA_WORK}/$$l"; \
		  make SRCLANGS=$$s TRGLANGS=$$t MODELTYPE=transformer-align release-tatoeba; \
		fi; \
		if [ `find ${TATOEBA_WORK}/$$l/ -maxdepth 1 -name '*transformer.model1.done' | wc -l` -gt 0 ]; then \
		  echo "make release for ${TATOEBA_WORK}/$$l"; \
		  make SRCLANGS=$$s TRGLANGS=$$t MODELTYPE=transformer release-tatoeba; \
		fi; \
	      fi \
	  fi \
	done



fixlabels.sh:
	for l in `find ${TATOEBA_WORK}-old/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	    if [ -d ${TATOEBA_WORK}/$$l ]; then \
	      echo "# ${TATOEBA_WORK}/$$l exists --- skip it!" >> $@; \
	      echo "mv ${TATOEBA_WORK}-old/$$l ${TATOEBA_WORK}-double/$$l" >> $@; \
	    else \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-labels; \
	      o=`grep '*' ${TATOEBA_WORK}-old/$$l/train/README.md | cut -f1 -d: | grep '-' | sed 's/\* //g' | cut -f1 -d- | sort -u | tr "\n" ' '`; \
	      O=`grep '*' ${TATOEBA_WORK}-old/$$l/train/README.md | cut -f1 -d: | grep '-' | sed 's/\* //g' | cut -f2 -d- | sort -u | tr "\n" ' '`; \
	      n=`cat ${TATOEBA_WORK}/data/simple/Tatoeba-train.$$l.clean.$$s.labels | tr ' ' "\n" | sort | grep . | tr "\n" ' '`; \
	      N=`cat ${TATOEBA_WORK}/data/simple/Tatoeba-train.$$l.clean.$$t.labels | tr ' ' "\n" | sort | grep . | tr "\n" ' '`; \
	      if [ "$$o" != "$$n" ] || [ "$$O" != "$$N" ] ; then \
	        echo "# labels in $$l are different ($$o / $$O - $$n / $$N)" >> $@; \
	        if [ -d ${TATOEBA_WORK}-old/$$l ]; then \
		  if [ "$$n" != " " ] && [ "$$n" != "" ]; then \
		    if [ "$$N" != " " ] && [ "$$N" != "" ]; then \
	              echo "# re-run $$l from scratch!" >> $@; \
	              echo "${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-job" >> $@; \
		    fi \
		  fi \
	        fi; \
	      else \
	        if [ -d ${TATOEBA_WORK}-old/$$l ]; then \
	          echo "mv ${TATOEBA_WORK}-old/$$l ${TATOEBA_WORK}/$$l" >> $@; \
	        fi; \
	      fi; \
	    fi \
	  fi \
	done 


tatoeba-missing-test:
	for d in `find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' | cut -f2 -d/`; do \
	  if [ ! -e ${TATOEBA_WORK}/$$d/test/Tatoeba-test.src ]; then \
	    if [ `find ${TATOEBA_WORK}/$$d/train -name '*-model' | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      echo "missing eval file for $$d"; \
	      mkdir -p ${TATOEBA_WORK}-tmp/$$d/train; \
	      rsync -av ${TATOEBA_WORK}/$$d/train/*model* ${TATOEBA_WORK}-tmp/$$d/train/; \
	      make FIT_DATA_SIZE=1000 LANGGROUP_FIT_DATA_SIZE=1000 TATOEBA_WORK=${TATOEBA_WORK}-tmp tatoeba-$$p-data; \
	      cp ${TATOEBA_WORK}-tmp/$$d/test/Tatoeba-test.* ${TATOEBA_WORK}/$$d/test/; \
	      rm -fr ${TATOEBA_WORK}-tmp/$$d; \
	    fi \
	  fi \
	done


tatoeba-touch-test:
	for d in `find ${TATOEBA_WORK}/ -maxdepth 1 -type d -name '???-???' | cut -f2 -d/`; do \
	  if [ -e ${TATOEBA_WORK}/$$d/test/Tatoeba-test.src ]; then \
	    if [ -e ${TATOEBA_WORK}/$$d/val/Tatoeba-dev.src ]; then \
	      touch -r ${TATOEBA_WORK}/$$d/val/Tatoeba-dev.src ${TATOEBA_WORK}/$$d/test/Tatoeba-test.src*; \
	      touch -r ${TATOEBA_WORK}/$$d/val/Tatoeba-dev.src ${TATOEBA_WORK}/$$d/test/Tatoeba-test.trg*; \
	    fi \
	  fi \
	done
