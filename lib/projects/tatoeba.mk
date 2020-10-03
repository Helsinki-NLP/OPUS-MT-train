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
#   make tatoeba-group2eng ...... start train jobs for all language groups to English
#   make tatoeba-eng2group ...... start train jobs for English to all language groups
#   make tatoeba-langgroup ...... start train jobs for bi-directional models for all language groups
#
#   make tatoeba-langgroups ..... make all jobs from above
#
#
#   make tatoeba-group2eng-dist . make package for all trained group2eng models
#   make tatoeba-eng2group-dist . make package for all trained eng2group models
#   make tatoeba-langgroup-dist . make package for all trained langgroup models
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
# generate evaluation tables
#
#   rm -f tatoeba-results* results/*.md
#   make tatoeba-results-md
#---------------------------------------------------------------------



## general parameters for Tatoeba models

TATOEBA_DATAURL := https://object.pouta.csc.fi/Tatoeba-Challenge
TATOEBA_RAWGIT  := https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_WORK    ?= ${PWD}/work-tatoeba
TATOEBA_DATA    ?= ${TATOEBA_WORK}/data/${PRE}
TATOEBA_MONO    ?= ${TATOEBA_WORK}/data/mono


TATOEBA_MODEL_CONTAINER := Tatoeba-MT-models

TATOEBA_PARAMS := TRAINSET=Tatoeba-train \
		DEVSET=Tatoeba-dev \
		TESTSET=Tatoeba-test \
		TESTSET_NAME=Tatoeba-test \
		SMALLEST_TRAINSIZE=1000 \
		USE_REST_DEVDATA=0 \
		HELDOUTSIZE=0 \
		DEVSIZE=5000 \
		TESTSIZE=10000 \
		DEVMINSIZE=200 \
		WORKHOME=${TATOEBA_WORK} \
		MODELSHOME=${PWD}/models-tatoeba \
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
tatoeba-labels: ${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels \
		${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${TRGEXT}.labels


.PHONY: tatoeba-results
tatoeba-results:
	rm -f tatoeba-results* tatoeba-models-all results/*.md
	${MAKE} tatoeba-results-md
	rm -f models-tatoeba/released-models.txt
	${MAKE} models-tatoeba/released-models.txt

.PHONY: tatoeba-released-models
tatoeba-released-models: models-tatoeba/released-models.txt

## create result tables in various variants and for various subsets
## markdown pages are for reading on-line in the Tatoeba Challenge git
## ---> link results dir to the local copy of the Tatoeba Challenge git
.PHONY: tatoeba-results-md
tatoeba-results-md: tatoeba-results-sorted tatoeba-results-sorted-model tatoeba-results-sorted-langpair \
		results/tatoeba-results-sorted.md \
		results/tatoeba-results-sorted-model.md \
		results/tatoeba-results-sorted-langpair.md \
		results/tatoeba-results-BLEU-sorted.md \
		results/tatoeba-results-BLEU-sorted-model.md \
		results/tatoeba-results-BLEU-sorted-langpair.md \
		results/tatoeba-results-chrF2-sorted.md \
		results/tatoeba-results-chrF2-sorted-model.md \
		results/tatoeba-results-chrF2-sorted-langpair.md \
		tatoeba-results-subset-zero \
		tatoeba-results-subset-lowest \
		tatoeba-results-subset-lower \
		tatoeba-results-subset-medium \
		tatoeba-results-subset-higher \
		tatoeba-results-subset-highest \
		results/tatoeba-results-subset-zero.md \
		results/tatoeba-results-subset-lowest.md \
		results/tatoeba-results-subset-lower.md \
		results/tatoeba-results-subset-medium.md \
		results/tatoeba-results-subset-higher.md \
		results/tatoeba-results-subset-highest.md \
		results/tatoeba-results-langgroup.md \
		tatoeba-results-all \
		tatoeba-results-all-subset-zero \
		tatoeba-results-all-subset-lowest \
		tatoeba-results-all-subset-lower \
		tatoeba-results-all-subset-medium \
		tatoeba-results-all-subset-higher \
		tatoeba-results-all-subset-highest \
		results/tatoeba-results-all.md \
		results/tatoeba-results-all-subset-zero.md \
		results/tatoeba-results-all-subset-lowest.md \
		results/tatoeba-results-all-subset-lower.md \
		results/tatoeba-results-all-subset-medium.md \
		results/tatoeba-results-all-subset-higher.md \
		results/tatoeba-results-all-subset-highest.md \
		tatoeba-models-all \
		results/tatoeba-models-all.md




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

tatoeba-langgroups: 
	${MAKE} tatoeba-group2eng
	${MAKE} tatoeba-eng2group
	${MAKE} tatoeba-langgroup


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
tatoeba-group2eng: 
	${MAKE} MIN_SRCLANGS=2 MODELTYPE=transformer FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} ${GROUP2ENG_TRAIN}

tatoeba-eng2group: 
	${MAKE} MIN_TRGLANGS=2 MODELTYPE=transformer FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} ${ENG2GROUP_TRAIN}

tatoeba-langgroup: 
	${MAKE} MIN_SRCLANGS=2 MAX_SRCLANGS=30 PIVOT=eng \
		MODELTYPE=transformer \
		FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} ${LANGGROUP_TRAIN}


## sample 2 million sentence pairs
tatoeba-langgroups-2m: 
	${MAKE} CONTINUE_EXISTING=1 LANGGROUP_FIT_DATA_SIZE=2000000 DATASET=opus2m MARIAN_VALID_FREQ=10000 \
	tatoeba-group2eng tatoeba-eng2group tatoeba-langgroup

tatoeba-langgroups-2m-dist:
	${MAKE} FIT_DATA_SIZE=2000000 DATASET=opus2m \
	tatoeba-group2eng-dist tatoeba-eng2groug-dist tatoeba-langgroug-dist

tatoeba-group2eng-2m-dist:
	${MAKE} FIT_DATA_SIZE=2000000 DATASET=opus2m tatoeba-group2eng-dist

tatoeba-eng2group-2m-dist:
	${MAKE} FIT_DATA_SIZE=2000000 DATASET=opus2m tatoeba-eng2group-dist



## sample 4 million sentence pairs
tatoeba-langgroups-4m: 
	${MAKE} CONTINUE_EXISTING=1 LANGGROUP_FIT_DATA_SIZE=4000000 DATASET=opus4m MARIAN_VALID_FREQ=10000 \
	tatoeba-group2eng tatoeba-eng2group 
# tatoeba-langgroup

tatoeba-langgroups-4m-dist:
	${MAKE} FIT_DATA_SIZE=4000000 DATASET=opus4m \
	tatoeba-group2eng-dist tatoeba-eng2groug-dist tatoeba-langgroug-dist


## evaluate and create dist packages

## old: just depend on eval and dist targets
## --> this would also start training if there is no model
## --> do this only if a model exists! (see below)

# tatoeba-eng2group-dist: ${ENG2GROUP_EVAL} ${ENG2GROUP_EVALALL}
#	${MAKE} ${ENG2GROUP_DIST}

## new: only start this if there is a model
tatoeba-group2eng-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${TATOEBA_WORK}/$$g-eng -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-dist; \
	  fi \
	done

tatoeba-eng2group-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${TATOEBA_WORK}/eng-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-dist; \
	  fi \
	done

tatoeba-langgroup-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${TATOEBA_WORK}/$$g-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-dist; \
	  fi \
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



## generic targets to start combinations of languages or language groups
## set variables below to avoid starting models with too few or too many languages
## on source or target side

MIN_SRCLANGS ?= 1
MIN_TRGLANGS ?= 1
MAX_SRCLANGS ?= 7000
MAX_TRGLANGS ?= 7000

tatoeba-%-train:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   S="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))) | xargs iso639 -m -n}))"; \
	   T="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))) | xargs iso639 -m -n}))"; \
	   if [ ! `find ${TATOEBA_WORK}/$$s-$$t -name '${DATASET}.*.done' | wc -l` -gt 0 ]; then \
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

tatoeba-%-data:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))); \
	   S="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))) | xargs iso639 -m -n}))"; \
	   T="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))) | xargs iso639 -m -n}))"; \
	     if [ `echo $$S | tr ' ' "\n" | wc -l` -ge ${MIN_SRCLANGS} ]; then \
	       if [ `echo $$T | tr ' ' "\n" | wc -l` -ge ${MIN_TRGLANGS} ]; then \
	         if [ `echo $$S | tr ' ' "\n" | wc -l` -le ${MAX_SRCLANGS} ]; then \
	           if [ `echo $$T | tr ' ' "\n" | wc -l` -le ${MAX_TRGLANGS} ]; then \
	             ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-prepare; \
	           fi \
	         fi \
	       fi \
	   fi )



tatoeba-%-eval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  S="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))) | xargs iso639 -m -n}))"; \
	  T="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))) | xargs iso639 -m -n}))"; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" ${TATOEBA_PARAMS} compare )


tatoeba-%-evalall:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))); \
	  S="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))) | xargs iso639 -m -n}))"; \
	  T="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))) | xargs iso639 -m -n}))"; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" eval-tatoeba; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" eval-testsets-tatoeba; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-multilingual-eval )


tatoeba-%-dist:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  S="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))) | xargs iso639 -m -n}))"; \
	  T="$(filter ${OPUS_LANGS3},$(sort ${PIVOT} ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))) | xargs iso639 -m -n}))"; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" ${TATOEBA_PARAMS} best-dist )









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
	    ${MAKE} SRCLANGS=$$s TRGLANGS=$$t MIN_BLEU_SCORE=10 best-dist-tatoeba; \
	  fi; \
	  if [ -d ${TATOEBA_WORK}/$$t-$$s ]; then \
	    ${MAKE} SRCLANGS=$$t TRGLANGS=$$s MIN_BLEU_SCORE=10 best-dist-tatoeba; \
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
		  LANGPAIRSTR=${<:.md=} tatoeba-multilingual-eval )


## make a release package to distribute
tatoeba-multilingual-distsubset-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  dist-tatoeba; )


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


## evaluate all individual language pairs for a multilingual model
.PHONY: tatoeba-multilingual-eval
tatoeba-multilingual-eval:
	-${MAKE} tatoeba-multilingual-testsets
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
		TRAINSET=Tatoeba-train \
		DEVSET=Tatoeba-dev \
		TESTSET=Tatoeba-test.$$s-$$t \
		TESTSET_NAME=Tatoeba-test.$$s-$$t \
		USE_REST_DEVDATA=0 \
		HELDOUTSIZE=0 \
		DEVSIZE=5000 \
		TESTSIZE=10000 \
		DEVMINSIZE=200 \
		WORKHOME=${TATOEBA_WORK} \
	      compare; \
	    fi \
	  done \
	done


#	( S=`${GET_ISO_CODE} -m ${SRCLANGS} | tr ' ' "\n" | sort -u | tr "\n" ' '`; \
#	  T=`${GET_ISO_CODE} -m ${TRGLANGS} | tr ' ' "\n" | sort -u | tr "\n" ' '`; \

## copy testsets into the multilingual model's test directory
.PHONY: tatoeba-multilingual-testsets
tatoeba-multilingual-testsets:
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ ! -e ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src ]; then \
	      wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt ${TATOEBA_RAWGIT}/data/test/$$s-$$t/test.txt; \
	      if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt ]; then \
	        echo "make Tatoeba-test.$$s-$$t"; \
		if [ "${words ${TRGLANGS}}" == "1" ]; then \
		  cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		else \
	          cut -f2,3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
		  sed 's/^\([^ ]*\)	/>>\1<< /' \
		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		fi; \
	        cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		> ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
	      else \
	        wget -q -O ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt ${TATOEBA_RAWGIT}/data/test/$$t-$$s/test.txt; \
	        if [ -s ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt ]; then \
	          echo "make Tatoeba-test.$$s-$$t"; \
		  if [ "${words ${TRGLANGS}}" == "1" ]; then \
		    cut -f4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		  else \
	            cut -f1,4 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt | \
		    sed 's/^\([^ ]*\)	/>>\1<< /' \
		    > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.src; \
		  fi; \
	          cut -f3 ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt \
		  > ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.trg; \
		fi \
	      fi; \
	      rm -f ${TATOEBA_WORK}/${LANGPAIRSTR}/test/Tatoeba-test.$$s-$$t.txt; \
	    fi \
	  done \
	done



###############################################################################
## generic targets for tatoba models
###############################################################################


## generic target for tatoeba challenge jobs
%-tatoeba: ${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels \
	   ${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${TRGEXT}.labels
	if [ -s ${word 1,$^} ]; then \
	  if [ -s ${word 2,$^} ]; then \
	    ${MAKE} ${TATOEBA_PARAMS} \
		LANGPAIRSTR=${LANGPAIRSTR} \
		SRCLANGS="${shell cat ${word 1,$^} | sed 's/ *$$//;s/^ *//'}" \
		TRGLANGS="${shell cat ${word 2,$^} | sed 's/ *$$//;s/^ *//'}" \
		SRC=${SRC} TRG=${TRG} \
		EMAIL= \
	    ${@:-tatoeba=}; \
	  fi \
	fi

%-bttatoeba: 	${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels \
		${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${TRGEXT}.labels
	for s in ${shell cat ${word 1,$^} | sed 's/ *$$//;s/^ *//'}; do \
	  for t in ${shell cat ${word 2,$^} | sed 's/ *$$//;s/^ *//'}; do \
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

## all language labels in all language pairs
## (each language pair may include several language variants)
## --> this is necessary to set the languages that are present in a model

${TATOEBA_DATA}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels:
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
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      elif [ -e ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      fi \
	    done \
	done
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$s-$$t.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      elif [ -e ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/Tatoeba-train.$$t-$$s.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      fi \
	    done \
	done
	cat $@.src | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/ *$$//' > $@
	cat $@.trg | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/ *$$//' > $(@:.${SRCEXT}.labels=.${TRGEXT}.labels)
	rm -f $@.src $@.trg



%.${LANGPAIRSTR}.clean.${TRGEXT}.labels: %.${LANGPAIRSTR}.clean.${SRCEXT}.labels
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
			ang ara_Latn aze_Latn bul_Latn ell_Latn heb_Latn rus_Latn
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
		| sed 's/ara_Latn/ara/;s/arq_Latn/arq/;s/apc_Latn/apc/' \
		| sed 's/kor_[A-Za-z]*/kor/g' \
		| sed 's/nor_Latn/nor/g' \
		| sed 's/nor/nob/g' \
		| sed 's/bul_Latn/bul/g' \
		| sed 's/syr_Syrc/syr/g' \
		| sed 's/yid_Latn/yid/g' \
		| perl -pe 'if (/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/){if ($$2 ne "Hans" && $$2 ne "Hant"){s/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/$$1/} }'


print-skiplangids:
	@echo ${SKIP_LANGIDS_PATTERN}


## monolingual data from Tatoeba challenge (wiki data)

${TATOEBA_MONO}/%.labels:
	mkdir -p $@.d
	wget -q -O $@.d/mono.tar ${TATOEBA_DATAURL}/$(patsubst %.labels,%,$(notdir $@)).tar
	tar -C $@.d -xf $@.d/mono.tar
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
	mkdir -p $@.d
	-wget -q -O $@.d/train.tar ${TATOEBA_DATAURL}/${LANGPAIR}.tar
	-tar -C $@.d -xf $@.d/train.tar
	if [ -e $@.d/data/${LANGPAIR}/test.src ]; then \
	  mv $@.d/data/${LANGPAIR}/test.src ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}; \
	  mv $@.d/data/${LANGPAIR}/test.trg ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}; \
	  cat $@.d/data/${LANGPAIR}/test.id $(FIXLANGIDS) > ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id; \
	fi
	if [ -e $@.d/data/${LANGPAIR}/dev.src ]; then \
	  mv $@.d/data/${LANGPAIR}/dev.src ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	  mv $@.d/data/${LANGPAIR}/dev.trg ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	  cat $@.d/data/${LANGPAIR}/dev.id $(FIXLANGIDS) > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	  if [ -e $@.d/data/${LANGPAIR}/train.src.gz ]; then \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.src.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.trg.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	  fi; \
	else \
	  if [ -e $@.d/data/${LANGPAIR}/train.src.gz ]; then \
	    echo "no devdata available - get top 1000 from training data!"; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.src.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | head -1000 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.src.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	    ${GZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | tail -n +1001 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	  fi \
	fi
## make sure that training data file exists even if it is empty
	if [ -e ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT} ]; then \
	  touch ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	  touch ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	fi
#######################################
# save all lang labels that appear the data
#######################################
	cut -f1 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | grep -v '${SKIP_LANGIDS_PATTERN}' | \
		tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)
	cut -f2 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | grep -v '${SKIP_LANGIDS_PATTERN}' | \
		tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)
#######################################
# cleanup temporary data
#######################################
	if [ -d $@.d/data ]; then \
	  rm -f $@.d/data/${LANGPAIR}/*; \
	  rmdir $@.d/data/${LANGPAIR}; \
	  rmdir $@.d/data; \
	fi
	rm -f $@.d/train.tar
	rmdir $@.d
#######################################
# make data sets for individual 
# language pairs from the Tatoeba data
#######################################
	if [ -e $(@:.${SRCEXT}.gz=.${SRCEXT}.labels) ]; then \
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
# all the differnt language variants.
# If the code is the same as one of the
# variants then remove the file instead.
#######################################
	for d in dev test train; do \
	  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT} ]; then \
	    if [ ! -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}.gz ]; then \
	      ${GZIP} ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}; \
	    else \
	      rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}; \
	    fi \
	  fi; \
	  if [ -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT} ]; then \
	    if [ ! -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}.gz ]; then \
	      ${GZIP} ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}; \
	    else \
	      rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}; \
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


## make Tatoeba test files available in testset collection
## --> useful for testing various languages when creating multilingual models
testsets/${LANGPAIR}/Tatoeba-test.${LANGPAIR}.%: ${TATOEBA_DATA}/Tatoeba-test.${LANGPAIR}.clean.%
	mkdir -p ${dir $@}
	cp $< $@



###############################################################################
## generate result tables
###############################################################################


# RESULT_MDTABLE_HEADER = | Model | Language Pair | Test Set | chrF2 | BLEU | BP | Reference Length |\n|:---|----|----|----:|---:|----:|---:|\n
# ADD_MDHEADER = perl -pe '@a=split;print "\n${RESULT_MDTABLE_HEADER}" if ($$b ne $$a[1]);$$b=$$a[1];'

results/tatoeba-results-al%.md: tatoeba-results-al%
	mkdir -p ${dir $@}
	echo "# Tatoeba translation results" >$@
	echo "" >>$@
	echo "Note that some links to the actual models below are broken"                  >> $@
	echo "because the models are not yet released or their performance is too poor"    >> $@
	echo "to be useful for anything."                                                  >> $@
	echo ""                                                                            >> $@
	echo '| Model | Test Set | chrF2 | BLEU | BP | Reference Length |' >> $@
	echo '|:--|---|--:|--:|--:|--:|'                                                   >> $@
	grep -v '^model' $< | grep -v -- '----' | grep . | sort -k2,2 -k3,3 -k4,4nr |\
	perl -pe '@a=split;print "| lang = $$a[1] | | | |\n" if ($$b ne $$a[1]);$$b=$$a[1];' |\
	cut -f1,3- |\
	perl -pe '/^(\S*)\/(\S*)\t/;if (-d "models-tatoeba/$$1"){s/^(\S*)\/(\S*)\t/[$$1\/$$2](..\/models\/$$1)\t/;}' |\
	sed 's/	/ | /g;s/^/| /;s/$$/ |/;s/Tatoeba-test/tatoeba/' |\
	sed 's/\(news[^ ]*\)-...... /\1 /;s/\(news[^ ]*\)-.... /\1 /;'                     >> $@

# sed 's#^\([^ 	]*\)/\([^ 	]*\)#[\1/\2](../models/\1)#' |\


results/tatoeba-models-all.md: tatoeba-models-all
	mkdir -p ${dir $@}
	echo "# Tatoeba translation models" >$@
	echo "" >>$@
	echo "The scores refer to results on Tatoeba-test data"                            >> $@
	echo "For multilingual models, it is a mix of all language pairs"                  >> $@
	echo ""                                                                            >> $@
	echo '| Model | chrF2 | BLEU | BP | Reference Length |'                            >> $@
	echo '|:--|--:|--:|--:|--:|'                                                       >> $@
	cut -f1,4- $< | \
	perl -pe '/^(\S*)\/(\S*)\t/;if (-d "models-tatoeba/$$1"){s/^(\S*)\/(\S*)\t/[$$1\/$$2](..\/models\/$$1)\t/;}' |\
	sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                                   >> $@


## get all results for all models and test sets
tatoeba-results-all:
	find work-tatoeba -name '*.eval' | sort | xargs grep chrF2 > $@.1
	find work-tatoeba -name '*.eval' | sort | xargs grep BLEU  > $@.2
	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.\([^\.]*\)\.eval:.*$$/\1-\2/' > $@.langpair
	cut -f3 -d '/' $@.1 | sed 's/\.\([^\.]*\)\.spm.*$$//;s/Tatoeba-test[^	]*/Tatoeba-test/' > $@.testset
	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.dataset
	cut -f2 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.modeldir
	cut -f2 -d '=' $@.1 | cut -f2 -d ' ' > $@.chrF2
	cut -f2 -d '=' $@.2 | cut -f2 -d ' ' > $@.bleu
	cut -f3 -d '=' $@.2 | cut -f2 -d ' ' > $@.bp
	cut -f6 -d '=' $@.2 | cut -f2 -d ' ' | cut -f1 -d')' > $@.reflen
	paste -d'/' $@.modeldir $@.dataset > $@.model
	paste $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen > $@
	rm -f $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen
	rm -f $@.modeldir $@.dataset $@.1 $@.2

tatoeba-models-all:
	find work-tatoeba -name 'Tatoeba-test.opus*.eval' | sort | xargs grep chrF2 > $@.1
	find work-tatoeba -name 'Tatoeba-test.opus*.eval' | sort | xargs grep BLEU  > $@.2
	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.\([^\.]*\)\.eval:.*$$/\1-\2/' > $@.langpair
	cut -f3 -d '/' $@.1 | sed 's/\.\([^\.]*\)\.spm.*$$//;s/Tatoeba-test[^	]*/Tatoeba-test/' > $@.testset
	cut -f3 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.dataset
	cut -f2 -d '/' $@.1 | sed 's/^.*\.\([^\.]*\)\.spm.*$$/\1/' > $@.modeldir
	cut -f2 -d '=' $@.1 | cut -f2 -d ' ' > $@.chrF2
	cut -f2 -d '=' $@.2 | cut -f2 -d ' ' > $@.bleu
	cut -f3 -d '=' $@.2 | cut -f2 -d ' ' > $@.bp
	cut -f6 -d '=' $@.2 | cut -f2 -d ' ' | cut -f1 -d')' > $@.reflen
	paste -d'/' $@.modeldir $@.dataset > $@.model
	paste $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen > $@
	rm -f $@.model $@.langpair $@.testset $@.chrF2 $@.bleu $@.bp $@.reflen
	rm -f $@.modeldir $@.dataset $@.1 $@.2

models-tatoeba/released-models.txt:
	find models-tatoeba/ -name '*.eval.txt' | sort | xargs grep chrF2 > $@.1
	find models-tatoeba/ -name '*.eval.txt' | sort | xargs grep BLEU > $@.2
	cut -f3 -d '/' $@.1 | sed 's/\.eval.txt.*$$/.zip/;s#^#${TATOEBA_DATAURL}/#' > $@.url
	cut -f2 -d '/' $@.1 > $@.iso639-3
	cut -f2 -d '/' $@.1 | xargs iso639 -2 -k -p | tr ' ' "\n" > $@.iso639-1
	cut -f2 -d '=' $@.1 | cut -f2 -d ' ' > $@.chrF2
	cut -f2 -d '=' $@.2 | cut -f2 -d ' ' > $@.bleu
	cut -f3 -d '=' $@.2 | cut -f2 -d ' ' > $@.bp
	cut -f6 -d '=' $@.2 | cut -f2 -d ' ' | cut -f1 -d')' > $@.reflen
	cut -f2 -d '/' $@.1 | sed 's/^\([^ \-]*\)$$/\1-\1/g' | tr '-' ' ' | \
	xargs iso639 -k | sed 's/$$/ /' |\
	sed -e 's/\" \"\([^\"]*\)\" /\t\1\n/g' | sed 's/^\"//g' > $@.langs
	paste $@.url $@.iso639-3 $@.iso639-1 $@.chrF2 $@.bleu $@.bp $@.reflen $@.langs > $@
	rm -f $@.url $@.iso639-3 $@.iso639-1 $@.chrF2 $@.bleu $@.bp $@.reflen $@.1 $@.2 $@.langs


tatoeba-results-all-subset-%: tatoeba-%.md tatoeba-results-all-sorted-langpair
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | sort -u  | tr "\n" '|' | tr '-' '.' | sed 's/|$$//;s/\./\\\-/g'}"; \
	  grep -P "$$l" ${word 2,$^} |\
	  perl -pe '@a=split;print "\n${RESULT_TABLE_HEADER}" if ($$b ne $$a[1]);$$b=$$a[1];' > $@ )

tatoeba-results-all-langgroup: tatoeba-results-all
	grep -P "${subst ${SPACE},-eng|,${OPUS_LANG_GROUPS}}-eng" $< >> $@
	grep -P "eng-${subst ${SPACE},|eng-,${OPUS_LANG_GROUPS}}" $< >> $@
	grep -P "`echo '${OPUS_LANG_GROUPS}' | sed 's/\([^ ][^ ]*\)/\1-\1/g;s/ /\|/g'`" $< >> $@


RESULT_TABLE_HEADER=model\tlanguage-pair\ttestset\tchrF2\tBLEU\tBP\treference-length\n--------------------------------------------------------------------------\n

tatoeba-results-all-sorted-langpair: tatoeba-results-all
	sort -k2,2 -k3,3 -k4,4nr < $< |\
	perl -pe '@a=split;print "\n${RESULT_TABLE_HEADER}" if ($$b ne $$a[1]);$$b=$$a[1];' \
	> $@

tatoeba-results-all-sorted-chrf2: tatoeba-results-all
	sort -k3,3 -k4,4nr < $< > $@

tatoeba-results-all-sorted-bleu: tatoeba-results-all
	sort -k3,3 -k5,5nr < $< > $@


# perl -pe '@a=split;print "\nmodel\tlanguage-pair\ttestset\tchrF2\tBLEU\tBP\treference-length\n" if ($b ne $a[1]);$b=$a[1];' < tatoeba-results-all-sorted-langpair | less




#############
## OLD ones
#############


results/tatoeba-results-langgroup.md: tatoeba-results-langgroup
	mkdir -p ${dir $@}
	echo "# Tatoeba translation results"                                             > $@
	echo ""                                                                         >> $@
	echo "Multilingual models for language groups according to ISO639-5."           >> $@
	echo ""                                                                         >> $@
	echo "Note that some links to the actual models below are broken"               >> $@
	echo "because the models are not yet released or their performance is too poor" >> $@
	echo "to be useful for anything."                                               >> $@
	echo ""                                                                         >> $@
	echo "| Source | Target | Model | Test Set      | chrF2 | BLEU |"               >> $@
	echo "|--------|--------|------:|---------------|------:|-----:|"               >> $@
	grep multi $< | cut -f1 | xargs iso639 -p | tr '"' "\n" | \
		grep [a-z] | \
		sed 's/based\-/based | /' |\
		sed 's/languages\-/languages | /' |\
		sed 's/English\-/English | /;s/^/| /;s/$$/ /'  > $@.langpair
	grep multi $< |\
	sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
	sed 's/	/ | /g;s/^/| /;s/$$/ |/'                       > $@.rest
	paste $@.langpair $@.rest -d ' '                                                >> $@
	echo ""                                                                         >> $@
	echo "## Performance on individual language pairs"                              >> $@
	echo ""                                                                         >> $@
	echo "Note that some of the test sets are way too small to be reliable!"        >> $@
	echo ""                                                                         >> $@
	echo "| Source | Target | Model | Test Set      | chrF2 | BLEU |"               >> $@
	echo "|--------|--------|------:|---------------|------:|-----:|"               >> $@
	grep -v multi $< | cut -f1 | xargs iso639 -p | tr '"' "\n" | \
		grep [a-z] | \
		sed 's/based\-/based | /' |\
		sed 's/languages\-/languages | /' |\
		sed 's/English\-/English | /;s/^/| /;s/$$/ /'  > $@.langpair
	grep -v multi $< |\
	sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
	sed 's/	/ | /g;s/^/| /;s/$$/ |/'                       > $@.rest
	paste $@.langpair $@.rest -d ' '                                                >> $@
	rm -f $@.langpair $@.rest


results/tatoeba-results-%.md: tatoeba-results-% tatoeba-results-BLEU-sorted-model
	mkdir -p ${dir $@}
	echo "# Tatoeba translation results" >$@
	echo "" >>$@
	echo "Note that some links to the actual models below are broken"               >>$@
	echo "because the models are not yet released or their performance is too poor" >> $@
	echo "to be useful for anything."                                               >> $@
	echo "" >>$@
	echo "| Model                 | Test Set   | chrF2      | BLEU     |"           >> $@
	echo "|----------------------:|------------|-----------:|---------:|"           >> $@
	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
	  grep -v -P "\t($$p)\t" $< |\
	  sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                        >> $@ )

#	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
#	  grep -v -P "\t($$p)\t" $< | xargs iso639 -p | tr '"' "\n" | grep [a-z]        > $@.langpair )
#	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
#	  grep -v -P "\t($$p)\t" $< |\
#	  sed 's#^\([^ 	]*\)#[\1](../models/\1)#' |\
#	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                        > $@.rest )
#	paste $@.langpair $@.rest -d '|'                                                >> $@
#	rm -f $@.langpair $@.rest


results/tatoeba-results-chrF2%.md: tatoeba-results-chrF2% tatoeba-results-BLEU-sorted-model
	mkdir -p ${dir $@}
	echo "# Tatoeba translation results" >$@
	echo "" >>$@
	echo "| Model            | Test Set   | chrF2      |"               >> $@
	echo "|-----------------:|------------|-----------:|"                    >> $@
	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
	  grep -v -P "\t($$p)\t" $< |\
	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                 >> $@ )

results/tatoeba-results-BLEU%.md: tatoeba-results-BLEU% tatoeba-results-BLEU-sorted-model
	mkdir -p ${dir $@}
	echo "# Tatoeba translation results" >$@
	echo "" >>$@
	echo "| Model            | Test Set   | BLEU       | Details  |"    >> $@
	echo "|-----------------:|------------|-----------:|---------:|"         >> $@
	( p=`grep -P 'ref_len = 1?[0-9]?[0-9]\)' tatoeba-results-BLEU-sorted-model | cut -f2 | sort -u | tr "\n" '|' | sed 's/|$$//'`; \
	  grep -v -P "\t($$p)\t" $< |\
	  sed 's/	/ | /g;s/^/| /;s/$$/ |/'                                 >> $@ )

tatoeba-results-sorted:
	grep chrF2 work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' > $@.1
	grep BLEU work-tatoeba/*/Tatoeba-test.*eval | \
	cut -f3 -d' ' > $@.2
	paste $@.1 $@.2 | sort -k3,3nr > $@
	rm -f $@.1 $@.2

## results with chrF and BLEU scores sorted by language pair
tatoeba-results-sorted-langpair:
	grep chrF2 work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' > $@.1
	grep BLEU work-tatoeba/*/Tatoeba-test.*eval | \
	cut -f3 -d' ' > $@.2
	paste $@.1 $@.2 | sort -k2,2 -k3,3nr > $@
	rm -f $@.1 $@.2

tatoeba-results-sorted-model:
	grep chrF2 work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' > $@.1
	grep BLEU work-tatoeba/*/Tatoeba-test.*eval | \
	cut -f3 -d' ' > $@.2
	paste $@.1 $@.2 | sort -k1,1 -k3,3nr > $@
	rm -f $@.1 $@.2

tatoeba-results-BLEU-sorted:
	grep BLEU work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/BLEU.*1.4.2//' | cut -f2- -d'/' |sort -k3,3nr | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' | sed 's/\([0-9]\) /\1	/' | grep -v eval > $@

tatoeba-results-BLEU-sorted-model:
	grep BLEU work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/BLEU.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#'  | sed 's/\([0-9]\) /\1	/' | \
	grep -v eval | sort -k1,1 -k3,3nr > $@

tatoeba-results-BLEU-sorted-langpair:
	grep BLEU work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/BLEU.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#'  | sed 's/\([0-9]\) /\1	/' | \
	grep -v eval | sort -k2,2 -k3,3nr > $@

tatoeba-results-chrF2-sorted:
	grep chrF2 work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' |sort -k3,3nr | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' > $@

tatoeba-results-chrF2-sorted-model:
	grep chrF2 work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/chrF.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' | sort -k1,1 -k3,3nr > $@

tatoeba-results-chrF2-sorted-langpair:
	grep chrF2 work-tatoeba/*/Tatoeba-test.*eval | \
	sed 's/chrF2.*1.4.2//' | cut -f2- -d'/' | \
	sed 's/Tatoeba.*\(transformer-align\.\|transformer\.\)/\./' | \
	sed "s#/.#\t#" | \
	sed 's#.eval: = #\t#' | sort -k2,2 -k3,3nr > $@

## scores per subset
tatoeba-results-subset-%: tatoeba-%.md tatoeba-results-sorted-langpair
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | sort -u  | tr "\n" '|' | tr '-' '.' | sed 's/|$$//;s/\./\\\./g'}"; \
	  grep -P "$$l" ${word 2,$^} > $@ )

tatoeba-results-langgroup: tatoeba-results-sorted-model
	grep -P "${subst ${SPACE},-eng|,${OPUS_LANG_GROUPS}}-eng" $< >> $@
	grep -P "eng-${subst ${SPACE},|eng-,${OPUS_LANG_GROUPS}}" $< >> $@
	grep -P "`echo '${OPUS_LANG_GROUPS}' | sed 's/\([^ ][^ ]*\)/\1-\1/g;s/ /\|/g'`" $< >> $@











###############################################################################
# auxiliary functions
###############################################################################


WRONGFILES = ${patsubst %.eval,%,${wildcard work-tatoeba/*/Tatoeba-test.opus*.eval}}

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
	  rm -f work-tatoeba/$$g-eng/Tatoeba-test.opus.spm32k-spm32k1.transformer.???.eng*; \
	  rm -f work-tatoeba/eng-$$g/Tatoeba-test.opus.spm32k-spm32k1.transformer.eng.???; \
	  rm -f work-tatoeba/eng-$$g/Tatoeba-test.opus.spm32k-spm32k1.transformer.eng.???.*; \
	done


remove-old-group:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ -e work-tatoeba/$$g-eng ]; then mv work-tatoeba/$$g-eng work-tatoeba/$$g-eng-old3; fi; \
	  if [ -e work-tatoeba/eng-$$g ]; then mv work-tatoeba/eng-$$g work-tatoeba/eng-$$g-old3; fi; \
	done




## resume training for all bilingual models that are not yet converged
.PHONY: tatoeba-resume-all tatoeba-continue-all
tatoeba-resume-all tatoeba-continue-all:
	for l in `find work-tatoeba/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	      if [ -d work-tatoeba/$$l ]; then \
		if [ ! `find work-tatoeba/$$l/ -name '*.done' | wc -l` -gt 0 ]; then \
		  if [ `find work-tatoeba/$$l/ -name '*.npz' | wc -l` -gt 0 ]; then \
		    echo "resume work-tatoeba/$$l"; \
		    make SRCLANGS=$$s TRGLANGS=$$t all-job-tatoeba; \
		  else \
		    echo "resume work-tatoeba/$$l"; \
		    make SRCLANGS=$$s TRGLANGS=$$t tatoeba-job; \
		  fi \
		else \
		  echo "done work-tatoeba/$$l"; \
		fi \
	      fi \
	  fi \
	done


## make release package for all bilingual models that are converged
.PHONY: tatoeba-dist-all
tatoeba-dist-all:
	for l in `find work-tatoeba/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	      if [ -d work-tatoeba/$$l ]; then \
		if [ `find work-tatoeba/$$l/ -name '*transformer-align.model1.done' | wc -l` -gt 0 ]; then \
		  echo "make release for work-tatoeba/$$l"; \
		  make SRCLANGS=$$s TRGLANGS=$$t MODELTYPE=transformer-align dist-tatoeba; \
		fi; \
		if [ `find work-tatoeba/$$l/ -name '*transformer.model1.done' | wc -l` -gt 0 ]; then \
		  echo "make release for work-tatoeba/$$l"; \
		  make SRCLANGS=$$s TRGLANGS=$$t MODELTYPE=transformer dist-tatoeba; \
		fi; \
	      fi \
	  fi \
	done



fixlabels.sh:
	for l in `find work-tatoeba-old/ -maxdepth 1 -mindepth 1 -type d -printf '%f '`; do \
	  s=`echo $$l | cut -f1 -d'-'`; \
	  t=`echo $$l | cut -f2 -d'-'`; \
	  if [ -d ${HOME}/research/Tatoeba-Challenge/data/$$s-$$t ] || \
	     [ -d ${HOME}/research/Tatoeba-Challenge/data/$$t-$$s ]; then \
	    if [ -d work-tatoeba/$$l ]; then \
	      echo "# work-tatoeba/$$l exists --- skip it!" >> $@; \
	      echo "mv work-tatoeba-old/$$l work-tatoeba-double/$$l" >> $@; \
	    else \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-labels; \
	      o=`grep '*' work-tatoeba-old/$$l/train/README.md | cut -f1 -d: | grep '-' | sed 's/\* //g' | cut -f1 -d- | sort -u | tr "\n" ' '`; \
	      O=`grep '*' work-tatoeba-old/$$l/train/README.md | cut -f1 -d: | grep '-' | sed 's/\* //g' | cut -f2 -d- | sort -u | tr "\n" ' '`; \
	      n=`cat work-tatoeba/data/simple/Tatoeba-train.$$l.clean.$$s.labels | tr ' ' "\n" | sort | grep . | tr "\n" ' '`; \
	      N=`cat work-tatoeba/data/simple/Tatoeba-train.$$l.clean.$$t.labels | tr ' ' "\n" | sort | grep . | tr "\n" ' '`; \
	      if [ "$$o" != "$$n" ] || [ "$$O" != "$$N" ] ; then \
	        echo "# labels in $$l are different ($$o / $$O - $$n / $$N)" >> $@; \
	        if [ -d work-tatoeba-old/$$l ]; then \
		  if [ "$$n" != " " ] && [ "$$n" != "" ]; then \
		    if [ "$$N" != " " ] && [ "$$N" != "" ]; then \
	              echo "# re-run $$l from scratch!" >> $@; \
	              echo "${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-job" >> $@; \
		    fi \
		  fi \
	        fi; \
	      else \
	        if [ -d work-tatoeba-old/$$l ]; then \
	          echo "mv work-tatoeba-old/$$l work-tatoeba/$$l" >> $@; \
	        fi; \
	      fi; \
	    fi \
	  fi \
	done 
