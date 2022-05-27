# -*-makefile-*-

TATOEBA_VERSION          ?= v2021-08-07
TATOEBA_VERSION_NOHYPHEN  = $(subst -,,${TATOEBA_VERSION})

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

# WORKHOME := ${PWD}/work-tatoeba

SMALLEST_TRAINSIZE  = 1000
USE_REST_DEVDATA    = 0
DATA_IS_SHUFFLED    = 1
DEVSIZE             = 5000
TESTSIZE            = 10000
DEVMINSIZE          = 200

# by default skip aligned data of the same language
# don't use anything from dev-data
# don't shuffle data because they are already shuffled
# but shuffle multilingual data to mix languages

SKIP_SAME_LANG            = 1
USE_REST_DEVDATA          = 0
SHUFFLE_DATA              = 0
SHUFFLE_DEVDATA           = 1
SHUFFLE_MULTILINGUAL_DATA = 1
DATA_IS_SHUFFLED          = 1


## Tatoeba specific data sets
TATOEBA_DATASET       := opusTC${TATOEBA_VERSION_NOHYPHEN}
TATOEBA_TRAINSET      := Tatoeba-train-${TATOEBA_VERSION}
TATOEBA_DEVSET        := Tatoeba-dev-${TATOEBA_VERSION}
TATOEBA_TESTSET       := Tatoeba-test-${TATOEBA_VERSION}

## the name is by default the same as the data set specifier
## (for some tasks the name can differ, i.e. tuning of multilingual models)
TATOEBA_DEVSET_NAME   := ${TATOEBA_DEVSET}
TATOEBA_TESTSET_NAME  := ${TATOEBA_TESTSET}
TATOEBA_TRAINSET_NAME := ${TATOEBA_TRAINSET}


## change data set names
## DATASET will also be the base name of the model file
DATASET             := ${TATOEBA_DATASET}
TRAINSET            := ${TATOEBA_TRAINSET}
DEVSET              := ${TATOEBA_DEVSET}
TESTSET             := ${TATOEBA_TESTSET}
DEVSET_NAME         := ${TATOEBA_DEVSET_NAME}
TESTSET_NAME        := ${TATOEBA_TESTSET_NAME}
TRAINSET_NAME       := ${TATOEBA_TRAINSET_NAME}

## 
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
# TATOEBA_RAWGIT_MASTER    := https://github.com/Helsinki-NLP/Tatoeba-Challenge/raw/master
# TATOEBA_RAWGIT_RELEASE   := https://github.com/Helsinki-NLP/Tatoeba-Challenge/raw/${TATOEBA_VERSION}


## data count files (file basename)
TATOEBA_DATA_COUNT_BASE    = ${TATOEBA_RAWGIT_MASTER}/data/release/${TATOEBA_VERSION}/released-bitexts
RELEASED_TATOEBA_DATA_URL  = ${TATOEBA_DATA_COUNT_BASE}.txt
RELEASED_TATOEBA_DATA_FILE = tatoeba/released-bitexts-${TATOEBA_VERSION}.txt

## all released language pairs with test sets > 200 test pairs
## also extract all source languages that are available for a give target language
## and vice versa
TATOEBA_RELEASED_DATA := $(shell ${WGET} -qq -O - ${TATOEBA_DATA_COUNT_BASE}-min200.txt | cut -f1)
TATOEBA_AVAILABLE_TRG  = ${sort ${filter-out ${SRC},${subst -, ,${filter %-${SRC} ${SRC}-%,${TATOEBA_RELEASED_DATA}}}}}
TATOEBA_AVAILABLE_SRC  = ${sort ${filter-out ${TRG},${subst -, ,${filter %-${TRG} ${TRG}-%,${TATOEBA_RELEASED_DATA}}}}}

## extract language pairs for a specific subset
TATOEBA_SUBSET               := lower
TATOEBA_RELEASED_SUBSET      := $(shell ${WGET} -qq -O - ${TATOEBA_DATA_COUNT_BASE}-${TATOEBA_SUBSET}.txt | cut -f1)
TATOEBA_AVAILABLE_SUBSET_TRG  = ${sort ${filter-out ${SRC},${subst -, ,${filter %-${SRC} ${SRC}-%,${TATOEBA_RELEASED_SUBSET}}}}}
TATOEBA_AVAILABLE_SUBSET_SRC  = ${sort ${filter-out ${TRG},${subst -, ,${filter %-${TRG} ${TRG}-%,${TATOEBA_RELEASED_SUBSET}}}}}




## all available language pairs
## (download the file once and keep it here to get the language pairs in the release)
TATOEBA_LANGPAIRS := ${shell if [ ! -e ${RELEASED_TATOEBA_DATA_FILE} ]; then \
				${WGET} -q -O ${RELEASED_TATOEBA_DATA_FILE} ${RELEASED_TATOEBA_DATA_URL}; \
			     fi; \
			     tail -n +2 ${RELEASED_TATOEBA_DATA_FILE} | cut -f1 }

## all available languages in tatoeba
TATOEBA_LANGS := $(sort $(subst -, ,${TATOEBA_LANGPAIRS}))

## SRCLANGS converted to macro languages used in tatoeba releases
## and all non-available languages filtered out
MACRO_SRCLANGS = $(filter ${sort ${shell iso639 -m -n ${SRCLANGS}}},${TATOEBA_LANGS})
MACRO_TRGLANGS = $(filter ${sort ${shell iso639 -m -n ${TRGLANGS}}},${TATOEBA_LANGS})




WIKILANGS         ?= ${notdir ${wildcard backtranslate/wiki-iso639-3/*}}
WIKIMACROLANGS    ?= $(sort ${shell ${GET_ISO_CODE} ${WIKILANGS}})

## ObjectStorage container name for Tatoeba models
TATOEBA_MODEL_CONTAINER := Tatoeba-MT-models


## file with the source and target languages in the current model

TATOEBA_SRCLABELFILE = ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src
TATOEBA_TRGLABELFILE = ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg

## get source and target languages from the label files

ifneq (${wildcard ${TATOEBA_SRCLABELFILE}},)
  TATOEBA_SRCLANGS = ${shell cat ${TATOEBA_SRCLABELFILE}}
else
  TATOEBA_SRCLANGS = ${SRCLANGS}
endif
ifneq (${wildcard ${TATOEBA_TRGLABELFILE}},)
  TATOEBA_TRGLANGS = ${shell cat ${TATOEBA_TRGLABELFILE}}
else
  TATOEBA_TRGLANGS = ${TRGLANGS}
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

# OPUS_LANGS3            = ${sort ${filter-out xxx,${shell ${GET_ISO_CODE} ${OPUSLANGS}}}}
# OPUS_LANG_PARENTS      = ${sort ${shell langgroup -p -n ${OPUS_LANGS3} 2>/dev/null}}
# OPUS_LANG_GRANDPARENTS = ${sort ${shell langgroup -p -n ${OPUS_LANG_PARENTS} 2>/dev/null}}
# OPUS_LANG_GROUPS       = ${sort ${OPUS_LANG_PARENTS} ${OPUS_LANG_GRANDPARENTS}}
