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




ISO639         := iso639
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
	rm -f tatoeba-results* results/*.md
	${MAKE} tatoeba-results-md

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
		results/tatoeba-results-langgroup.md



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

LANGGROUP_TRAIN   := $(patsubst %,tatoeba-%-train,${OPUS_LANG_GROUPS})
LANGGROUP_EVAL    := $(patsubst %,tatoeba-%-eval,${OPUS_LANG_GROUPS})
LANGGROUP_EVALALL := $(patsubst %,tatoeba-%-evalall,${OPUS_LANG_GROUPS})
LANGGROUP_DIST    := $(patsubst %,tatoeba-%-dist,${OPUS_LANG_GROUPS})


## start all jobs for language group to English translation
tatoeba-group2eng: 
	${MAKE} MIN_SRCLANGS=2 MODELTYPE=transformer FIT_DATA_SIZE=1000000 ${GROUP2ENG_TRAIN}

tatoeba-eng2group: 
	${MAKE} MIN_TRGLANGS=2 MODELTYPE=transformer FIT_DATA_SIZE=1000000 ${ENG2GROUP_TRAIN}

tatoeba-langgroup: 
	${MAKE} MIN_SRCLANGS=2 MAX_SRCLANGS=25 MODELTYPE=transformer FIT_DATA_SIZE=1000000 ${LANGGROUP_TRAIN}


## old: just depend on eval and dist targets
## --> this would also start training if there is no model
## --> do this only if a model exists! (see below)

# tatoeba-eng2group-dist: ${ENG2GROUP_EVAL} ${ENG2GROUP_EVALALL}
#	${MAKE} ${ENG2GROUP_DIST}

## only start this if there is a model
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
	    ${MAKE} tatoeba-$${g}-eval; \
	    ${MAKE} tatoeba-$${g}-evalall; \
	    ${MAKE} tatoeba-$${g}-dist; \
	  fi \
	done


ine-ine:
	    ${MAKE} LANGPAIRSTR=ine-ine \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup ine | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup ine | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
	    train-and-eval-job-tatoeba; \


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
	   S="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))) | xargs iso639 -m -n}))"; \
	   T="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))) | xargs iso639 -m -n}))"; \
	   if [ ! `find ${TATOEBA_WORK}/$$s-$$t -name '*.done' | wc -l` -gt 0 ]; then \
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


tatoeba-%-eval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  S="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))) | xargs iso639 -m -n}))"; \
	  T="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))) | xargs iso639 -m -n}))"; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" ${TATOEBA_PARAMS} compare )


tatoeba-%-evalall:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))); \
	  S="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))) | xargs iso639 -m -n}))"; \
	  T="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-evalall,%,$@))) | xargs iso639 -m -n}))"; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" tatoeba-multilingual-eval )

tatoeba-%-dist:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  S="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(firstword $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))) | xargs iso639 -m -n}))"; \
	  T="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(lastword  $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))) | xargs iso639 -m -n}))"; \
	  ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" ${TATOEBA_PARAMS} best-dist )





# ## start all jobs for language group to English translation
# tatoeba-group2eng: ${GROUP2ENG_TRAIN}

# # langgroup gmq | xargs iso639 -m

# ${GROUP2ENG_TRAIN}:
# 	-if [ `echo $(filter ${OPUS_LANGS3},$(sort \
# 	              ${shell langgroup $(patsubst tatoeba-%2eng-train,%,$@) | \
# 	                      xargs iso639 -m -n})) | \
# 	       tr ' ' "\n" | wc -l` -gt 1 ]; then \
# 	  if [ ! `find ${TATOEBA_WORK}/$(patsubst tatoeba-%2eng-train,%,$@)-eng -name '*.done' | wc -l` -gt 0 ]; then \
# 	    ${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%2eng-train,%,$@)-eng \
# 	            SRCLANGS="$(filter ${OPUS_LANGS3},$(sort \
# 	                        ${shell langgroup $(patsubst tatoeba-%2eng-train,%,$@) | \
# 	                                xargs iso639 -m -n}))" \
# 		    TRGLANGS=eng \
# 		    MODELTYPE=transformer \
# 	            FIT_DATA_SIZE=1000000 \
# 	    tatoeba-job; \
# 	  fi \
# 	fi


# ## this would be easier but does not check whether a mode exists
# ## --> tries to build it if there is no model

# # tatoeba-group2eng-dist: ${GROUP2ENG_EVAL} ${GROUP2ENG_EVALALL}
# # 	${MAKE} ${GROUP2ENG_DIST}

# ${GROUP2ENG_EVAL}:
# 	${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%2eng-eval,%,$@)-eng \
# 		SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%2eng-eval,%,$@) | xargs iso639 -m -n}))" \
# 		TRGLANGS=eng \
# 		MODELTYPE=transformer \
# 		${TATOEBA_PARAMS} \
# 	compare

# ${GROUP2ENG_EVALALL}:
# 	${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%2eng-evalall,%,$@)-eng \
# 		SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%2eng-evalall,%,$@) | xargs iso639 -m -n}))" \
# 		TRGLANGS=eng MODELTYPE=transformer FIT_DATA_SIZE=1000000 \
# 	tatoeba-multilingual-eval

# ${GROUP2ENG_DIST}:
# 	${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%2eng-dist,%,$@)-eng \
# 		SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%2eng-dist,%,$@) | xargs iso639 -m -n}))" \
# 		TRGLANGS=eng \
# 		MODELTYPE=transformer \
# 		${TATOEBA_PARAMS} \
# 	best-dist



# tatoeba-eng2group: ${ENG2GROUP_TRAIN}




# ${ENG2GROUP_TRAIN}:
# 	-if [ `echo $(filter ${OPUS_LANGS3},$(sort \
# 	              ${shell langgroup $(patsubst tatoeba-eng2%-train,%,$@) | \
# 	                      xargs iso639 -m -n})) | \
# 	       tr ' ' "\n" | wc -l` -gt 1 ]; then \
# 	  if [ ! `find ${TATOEBA_WORK}/eng-$(patsubst tatoeba-eng2%-train,%,$@) -name '*.done' | wc -l` -gt 0 ]; then \
# 	    ${MAKE} LANGPAIRSTR=eng-$(patsubst tatoeba-eng2%-train,%,$@) \
# 		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort \
# 	                        ${shell langgroup $(patsubst tatoeba-eng2%-train,%,$@) | \
# 	                                xargs iso639 -m -n}))" \
# 		    SRCLANGS=eng \
# 		    MODELTYPE=transformer \
# 		    FIT_DATA_SIZE=1000000 \
# 	    tatoeba-job; \
# 	  fi \
# 	fi

# ${ENG2GROUP_EVAL}:
# 	${MAKE} LANGPAIRSTR=eng-$(patsubst tatoeba-eng2%-eval,%,$@) \
# 		SRCLANGS=eng \
# 		TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-eng2%-eval,%,$@) | xargs iso639 -m -n}))" \
# 		MODELTYPE=transformer \
# 		${TATOEBA_PARAMS} \
# 	compare

# ${ENG2GROUP_EVALALL}:
# 	${MAKE} LANGPAIRSTR=eng-$(patsubst tatoeba-eng2%-evalall,%,$@) \
# 		TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-eng2%-evalall,%,$@) | xargs iso639 -m -n}))" \
# 		SRCLANGS=eng MODELTYPE=transformer FIT_DATA_SIZE=1000000 \
# 	tatoeba-multilingual-eval

# ${ENG2GROUP_DIST}:
# 	${MAKE} LANGPAIRSTR=eng-$(patsubst tatoeba-eng2%-dist,%,$@) \
# 		SRCLANGS=eng \
# 		TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-eng2%-dist,%,$@) | xargs iso639 -m -n}))" \
# 		MODELTYPE=transformer \
# 		${TATOEBA_PARAMS} \
# 	best-dist

# tatoeba-langgroup: ${LANGGROUP_TRAIN}

# ${LANGGROUP_TRAIN}:
# 	-if [ `echo $(filter ${OPUS_LANGS3},$(sort \
# 	              ${shell langgroup $(patsubst tatoeba-%-train,%,$@) | \
# 	                      xargs iso639 -m -n})) | \
# 	       tr ' ' "\n" | wc -l` -gt 1 ]; then \
# 	 if [ `echo $(filter ${OPUS_LANGS3},$(sort \
# 	              ${shell langgroup $(patsubst tatoeba-%-train,%,$@) | \
# 	                      xargs iso639 -m -n})) | \
# 	       tr ' ' "\n" | wc -l` -lt 16 ]; then \
# 	  if [ ! `find ${TATOEBA_WORK}/$(patsubst tatoeba-%-train,%,$@)-$(patsubst tatoeba-%-train,%,$@) \
# 			-name '*.done' | wc -l` -gt 0 ]; then \
# 	    ${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%-train,%,$@)-$(patsubst tatoeba-%-train,%,$@) \
# 		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort \
# 	                        ${shell langgroup $(patsubst tatoeba-%-train,%,$@) | \
# 	                                xargs iso639 -m -n}))" \
# 		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort \
# 	                        ${shell langgroup $(patsubst tatoeba-%-train,%,$@) | \
# 	                                xargs iso639 -m -n}))" \
# 		    MODELTYPE=transformer \
# 	            FIT_DATA_SIZE=1000000 \
# 	    tatoeba-job; \
# 	  fi \
# 	fi \
# 	fi

# ${LANGGROUP_EVAL}:
# 	${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%-eval,%,$@)-$(patsubst tatoeba-%-eval,%,$@) \
# 		SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%-eval,%,$@) | xargs iso639 -m -n}))" \
# 		TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%-eval,%,$@) | xargs iso639 -m -n}))" \
# 		MODELTYPE=transformer \
# 		${TATOEBA_PARAMS} \
# 	compare

# ${LANGGROUP_EVALALL}:
# 	${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%-evalall,%,$@)-$(patsubst tatoeba-%-evalall,%,$@) \
# 		SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%-evalall,%,$@) | xargs iso639 -m -n}))" \
# 		TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%-evalall,%,$@) | xargs iso639 -m -n}))" \
# 		MODELTYPE=transformer FIT_DATA_SIZE=1000000 \
# 	tatoeba-multilingual-eval

# ${LANGGROUP_DIST}:
# 	${MAKE} LANGPAIRSTR=$(patsubst tatoeba-%-dist,%,$@)-$(patsubst tatoeba-%-dist,%,$@) \
# 		SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%-dist,%,$@) | xargs iso639 -m -n}))" \
# 		TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup $(patsubst tatoeba-%-dist,%,$@) | xargs iso639 -m -n}))" \
# 		MODELTYPE=transformer \
# 		${TATOEBA_PARAMS} \
# 	best-dist








###########################################################################################








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
	  zcat ${TATOEBA_DATA}/Tatoeba-train.$$l.clean.$$s.gz | wc -l >> $@; \
	done




###############################################################################
## generic targets for evaluating multilingual models (all supported lang-pairs)
###############################################################################


## evaluate all individual language pairs for a multilingual model
.PHONY: tatoeba-multilingual-eval
tatoeba-multilingual-eval:
	${MAKE} tatoeba-multilingual-testsets
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
		| perl -pe 'if (/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/){if ($$2 ne "Hans" && $$2 ne "Hant"){s/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/$$1/} }'



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
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.src.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.trg.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.id.gz | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	  fi; \
	else \
	  if [ -e $@.d/data/${LANGPAIR}/train.src.gz ]; then \
	    echo "no devdata available - get top 1000 from training data!"; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.src.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | head -1000 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.src.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	    ${ZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | tail -n +1001 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	  fi \
	fi
## make sure that training data file exists even if it is empty
	if [ -e ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT} ]; then \
	  touch ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	  touch ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	fi
#######################################
# save all labels in the data
# TODO: de we also need labels from train data?
#######################################
#	cut -f1 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)
#	cut -f2 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)
	if [ -e ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id ]; then \
	  cut -f1 ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${SRCEXT}.labels); \
	  cut -f2 ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${TRGEXT}.labels); \
	fi
#######################################
# special treatment for Chinese: add cmn without script info
# (because it is common in train but not in test data)
#######################################
ifeq (${SRC},zho)
	if [ -e $(@:.${SRCEXT}.gz=.${SRCEXT}.labels) ]; then \
	  if [ `grep 'cmn ' $(@:.${SRCEXT}.gz=.${SRCEXT}.labels) | wc -l` -eq 0 ]; then \
	    echo -n 'cmn' >> $(@:.${SRCEXT}.gz=.${SRCEXT}.labels); \
	  fi \
	fi
endif
ifeq (${TRG},zho)
	if [ -e $(@:.${SRCEXT}.gz=.${TRGEXT}.labels) ]; then \
	  if [ `grep 'cmn ' $(@:.${SRCEXT}.gz=.${TRGEXT}.labels) | wc -l` -eq 0 ]; then \
	    echo -n 'cmn' >> $(@:.${SRCEXT}.gz=.${TRGEXT}.labels); \
	  fi \
	fi
endif
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


## old fix for Chinese: add zho and variants ...
#
# ifeq (${SRC},zho)
# 	if [ -e $(@:.${SRCEXT}.gz=.${SRCEXT}.labels) ]; then \
# 	  echo -n 'zho zho_Hans zho_Hant cmn' >> $(@:.${SRCEXT}.gz=.${SRCEXT}.labels); \
# 	  tr ' ' "\n" < $(@:.${SRCEXT}.gz=.${SRCEXT}.labels) | \
# 	  sort -u | tr "\n" ' ' >$(@:.${SRCEXT}.gz=.${SRCEXT}.labels).tmp; \
# 	  mv $(@:.${SRCEXT}.gz=.${SRCEXT}.labels).tmp $(@:.${SRCEXT}.gz=.${SRCEXT}.labels); \
# 	fi
# endif
# ifeq (${TRG},zho)
# 	if [ -e $(@:.${SRCEXT}.gz=.${TRGEXT}.labels) ]; then \
# 	  echo -n 'zho zho_Hans zho_Hant cmn' >> $(@:.${SRCEXT}.gz=.${TRGEXT}.labels); \
# 	  tr ' ' "\n" < $(@:.${SRCEXT}.gz=.${TRGEXT}.labels) | \
# 	  sort -u | tr "\n" ' ' >$(@:.${SRCEXT}.gz=.${TRGEXT}.labels).tmp; \
# 	  mv $(@:.${SRCEXT}.gz=.${TRGEXT}.labels).tmp $(@:.${SRCEXT}.gz=.${TRGEXT}.labels); \
# 	fi
# endif



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


results/tatoeba-results%.md: tatoeba-results% tatoeba-results-BLEU-sorted-model
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
