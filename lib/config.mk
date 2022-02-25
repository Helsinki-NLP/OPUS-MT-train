# -*-makefile-*-
#
# model and environment configurations
#


# load model-specific configuration parameters
# if they exist in the work directory

##---------------------------------------------------------------
## default name of the data set (and the model)
##---------------------------------------------------------------

TRAINSET_NAME ?= opus
DATASET       ?= ${TRAINSET_NAME}

## various ways of setting the model languages
##
## (1) explicitly set source and target languages, for example:
##     SRCLANGS="da no sv" TRGLANGS="fi da"
##
## (2) specify language pairs, for example:
##     LANGPAIRS="de-en fi-sv da-es"
##     this will set SRCLANGS="de fi da" TRGLANGS="en sv es"
##

## if LANGPAIRS are set and the model is not supposed to be SYMMETRIC
## then set SRCLANGS and TRGLANGS to the languages in LANGPAIRS
ifdef LANGPAIRS
  SRCLANGS ?= ${sort ${shell echo "${LANGPAIRS}" | tr ' ' "\n" | cut -f1 -d '-'}}
  TRGLANGS ?= ${sort ${shell echo "${LANGPAIRS}" | tr ' ' "\n" | cut -f2 -d '-'}}
endif


## LANGPAISTR is used as a sub-dir in WORKHOME
SPACE         := $(empty) $(empty)
LANGSRCSTR    ?= ${subst ${SPACE},+,$(SRCLANGS)}
LANGTRGSTR    ?= ${subst ${SPACE},+,$(TRGLANGS)}
LANGPAIRSTR   ?= ${LANGSRCSTR}-${LANGTRGSTR}
WORKDIR        = ${WORKHOME}/${LANGPAIRSTR}

## default model type
MODELTYPE    =  transformer-align



MODELCONFIG = ${DATASET}${MODEL_VARIANT}.${MODELTYPE}.mk
ifneq ($(wildcard ${WORKDIR}/${MODELCONFIG}),)
  include ${WORKDIR}/${MODELCONFIG}
endif



## some pre-defined language sets
include ${REPOHOME}lib/langsets.mk


## supported model types
## configuration for each type is in lib/train.mk

MODELTYPES   = 	transformer \
		transformer-align \
		transformer-base \
		transformer-base-align \
		transformer-big \
		transformer-big-align \
		transformer-small \
		transformer-small-align \
		transformer-tiny \
		transformer-tiny-align \
		transformer-tiny11 \
		transformer-tiny11-align



## name of the model-specific configuration file
## NEW: make it more model specific
#
# MODELCONFIG ?= config.mk




## set SRC and TRG unless they are specified already
ifneq (${words ${SRCLANGS}},1)
  SRC ?= multi
else
  SRC ?= ${SRCLANGS}
endif
ifneq (${words ${TRGLANGS}},1)
  TRG ?= multi
else
  TRG ?= ${TRGLANGS}
endif


##----------------------------------------------------------------------
## SKIP_LANGPAIRS can be used to skip certain language pairs
## in data preparation for multilingual models
## ---> this can be good to skip BIG language pairs
##      that would very much dominate all the data
## must be a pattern that can be matched by egrep
## e.g. en-de|en-fr
##
## SKIP_SAME_LANG - set to 1 to skip data with the same language
##                  on both sides
##----------------------------------------------------------------------

SKIP_LANGPAIRS ?= "nothing"
SKIP_SAME_LANG ?= 0


##----------------------------------------------------------------------
## set SHUFFLE_DATA if you want to shuffle data for 
## each language pair to be added to the training data
## --> especially useful in connection with FIT_DATA_SIZE
## set DATA_IS_SHUFFLED=1 if the training data is already shuffled
## --> useful to avoid shuffling when training sentence piece model
## NEW (2021-12-16): SHUFFLE_DATA is now set by default
## --> can now also avoid sqlite and data shuffling inside MarianNMT
## --> is that a problem (would MarianNMT use different random shuffles / epoch?)
##----------------------------------------------------------------------

SHUFFLE_DATA ?= 1
# DATA_IS_SHUFFLED ?= 1

## devtest data is shuffled by default
SHUFFLE_DEVDATA ?= 1

## shuffle multilingual training data to mix language examples
SHUFFLE_MULTILINGUAL_DATA ?= 1

##----------------------------------------------------------------------
## set FIT_DATA_SIZE to a specific value to fit the training data
## to a certain number of lines for each language pair in the collection
## --> especially useful for multilingual models for balancing the 
##     the size for each language pair
## the script does both, over- and undersampling
##----------------------------------------------------------------------

# FIT_DATA_SIZE ?= 100000

## similar for the dev data: set FIT_DEVDATA_SIZE to
## balance the size of the devdata for each language pair
##
# FIT_DEVDATA_SIZE = 

## define a default dev size fit for multilingual models
## TODO: is 1000 too small? or too big?
## TODO: should this depend on the number of languages involved?

ifneq (${words ${TRGLANGS}},1)
  FIT_DEVDATA_SIZE ?= 1000
endif
ifneq (${words ${SRCLANGS}},1)
  FIT_DEVDATA_SIZE ?= 1000
endif

## maximum number of repeating the same data set 
## in oversampling
MAX_OVER_SAMPLING ?= 50


##----------------------------------------------------------------------
## set CHECK_TRAINDATA_SIZE if you want to check that each
## bitext has equal number of lines in source and target
## ---> this only prints a warning if not
##----------------------------------------------------------------------
# CHECK_TRAINDATA_SIZE = 1


# sorted languages and langpair used to match resources in OPUS
SORTLANGS   = $(sort ${SRC} ${TRG})
SORTSRC     = ${firstword ${SORTLANGS}}
SORTTRG     = ${lastword ${SORTLANGS}}
LANGPAIR    = ${SORTSRC}-${SORTTRG}


## for monolingual things
LANGS   ?= ${SRCLANGS}
LANGID  ?= ${firstword ${LANGS}}
LANGSTR ?= ${subst ${SPACE},+,$(LANGS)}


## for same language pairs: add numeric extension
## (this is neccessary to keep source and target files separate)
ifeq (${SRC},$(TRG))
  SRCEXT     = ${SRC}1
  TRGEXT     = ${SRC}2
  SORTSRCEXT = ${SORTSRC}1
  SORTTRGEXT = ${SORTSRC}2
else
  SRCEXT     = ${SRC}
  TRGEXT     = ${TRG}
  SORTSRCEXT = ${SORTSRC}
  SORTTRGEXT = ${SORTTRG}
endif

## set a flag to use target language labels
## in multi-target models
ifneq (${words ${TRGLANGS}},1)
  USE_TARGET_LABELS = 1
  TARGET_LABELS ?= $(patsubst %,>>%<<,${TRGLANGS})
endif


## size of dev data, test data and BPE merge operations
## NEW default size = 2500 (keep more for training for small languages)
## NOTE: size will be increased to 5000 for Tatoeba

DEVSIZE     ?= 2500
TESTSIZE    ?= 2500

## set some additional thresholds for 
## the size of test and dev data
## DEVMINSIZE is the absolute minimum we require
## to run any training procedures

DEVSMALLSIZE  ?= 1000
TESTSMALLSIZE ?= 1000
DEVMINSIZE    ?= 250


## set additional argument options for opus_read (if it is used)
## e.g. OPUSREAD_ARGS = -a certainty -tr 0.3
OPUSREAD_ARGS = 


##----------------------------------------------------------------------------
## resources in OPUS
##----------------------------------------------------------------------------


## get available data from the OPUS-API

OPUSAPI = http://opus.nlpl.eu/opusapi/
OPUSAPI_WGET = wget -qq --no-check-certificate -O - ${OPUSAPI}?

get-opus-mono      = ${shell ${OPUSAPI_WGET}source=${1}\&corpora=True | ${JQ} '.corpora[]' | tr '"' ' '}
get-opus-bitexts   = ${shell ${OPUSAPI_WGET}source=${1}\&target=${2}\&corpora=True | ${JQ} '.corpora[]' | tr '"' ' '}
get-bigger-bitexts = ${shell ${OPUSAPI_WGET}source=${1}\&target=${2}\&preprocessing=xml\&version=latest | \
	${JQ} -r '.corpora[1:] | .[] | select(.source!="") | select(.target!="") | select(.alignment_pairs>${3}) | .corpus' }
get-opus-langs     = ${shell ${OPUSAPI_WGET}languages=True | ${JQ} '.languages[]' | tr '"' ' '}
get-opus-version   = ${shell ${OPUSAPI_WGET}source=${1}\&target=${2}\&corpus=${3}\&preprocessing=xml\&version=latest | ${JQ} '.corpora[] | .version' | sed 's/"//g' | head -1}
get-elra-bitexts   = ${shell ${OPUSAPI_WGET}source=${1}\&target=${2}\&corpora=True | \
	${JQ} '.corpora[]' | tr '"' ' ' | grep '^ *ELR[CA][-_]'}


## start of some functions to check whether there is a resource for downloading
## open question: links to the latest release do not exist in the storage
## --> would it be better to get that done via the OPUS API?

OPUS_STORE = https://object.pouta.csc.fi/OPUS-
url-status = ${shell curl -Is -K HEAD ${1} | head -1}
url-exists = ${shell if [ "${call url-status,${1}}" == "HTTP/1.1 200 OK" ]; then echo 1; else echo 0; fi}
resource-url = ${shell echo "${OPUS_STORE}${3}/${call get-opus-version,${1},${2},${3}}/moses/${1}-${2}.txt.zip"}


## exclude certain data sets
# EXCLUDE_CORPORA ?= WMT-News MPC1 ${call get-elra-bitexts,${SRC},${TRG}}
EXCLUDE_CORPORA ?= WMT-News MPC1

# all matching corpora in OPUS except for some that we want to exclude
OPUSCORPORA = $(filter-out ${EXCLUDE_CORPORA},${call get-opus-bitexts,${SRC},${TRG}})

## monolingual data
OPUSMONOCORPORA = $(filter-out ${EXCLUDE_CORPORA},${call get-opus-mono,${LANGID}})

## all languages in OPUS
## TODO: do we need this?
OPUSLANGS := ${call get-opus-langs}




##----------------------------------------------------------------------------
## train/dev/test data
##----------------------------------------------------------------------------


## select a suitable DEVSET
##   - POTENTIAL_DEVSETS lists more or less reliable corpora (in order of priority)
##   - BIGGER_BITEXTS lists all bitext with more than DEVSMALLSIZE sentence pairs
##   - SMALLER_BITEXTS lists potentially smaller bitexts but at least DEVMINSIZE big
##   - DEVSET is the first of the potential devset that exists with sufficient size
## TODO: what do we do if there is no devset?

POTENTIAL_DEVSETS = Tatoeba GlobalVoices infopankki wikimedia TED2020 Europarl OpenSubtitles JW300 bible-uedin
BIGGER_BITEXTS   := ${call get-bigger-bitexts,${SRC},${TRG},${DEVSMALLSIZE}}
SMALLER_BITEXTS  := ${call get-bigger-bitexts,${SRC},${TRG},${DEVMINSIZE}}
DEVSET ?= ${firstword 	${filter ${POTENTIAL_DEVSETS},${BIGGER_BITEXTS}} \
			${filter ${POTENTIAL_DEVSETS},${SMALLER_BITEXTS}}}

print-potential-datasets:
	@echo "bigger  : ${BIGGER_BITEXTS}"
	@echo "smaller : ${SMALLER_BITEXTS}"
	@echo "selected: ${DEVSET}"


## increase dev/test sets for Tatoeba (very short sentences!)
ifeq (${DEVSET},Tatoeba)
  DEVSIZE  = 5000
  TESTSIZE = 5000
endif


## in case we want to use some additional data sets
# EXTRA_TRAINSET =

## TESTSET= DEVSET, TRAINSET = OPUS - WMT-News,DEVSET.TESTSET
TESTSET  ?= ${DEVSET}
TRAINSET ?= $(filter-out ${EXCLUDE_CORPORA} ${DEVSET} ${TESTSET},${OPUSCORPORA} ${EXTRA_TRAINSET})
MONOSET  ?= $(filter-out ${EXCLUDE_CORPORA} ${DEVSET} ${TESTSET},${OPUSMONOCORPORA} ${EXTRA_TRAINSET})

## 1 = use remaining data from dev/test data for training
USE_REST_DEVDATA ?= 1



## for model fine-tuning

TUNE_SRC ?= ${SRC}
TUNE_TRG ?= ${TRG}

TUNE_DOMAIN         ?= OpenSubtitles
TUNE_FIT_DATA_SIZE  ?= 1000000

TUNE_VALID_FREQ     ?= 1000
TUNE_DISP_FREQ      ?= 1000
TUNE_SAVE_FREQ      ?= 1000
TUNE_EARLY_STOPPING ?= 5
TUNE_GPUJOB_SUBMIT  ?= 



## existing projects in WORKHOME
ALL_LANG_PAIRS          := ${shell ls ${WORKHOME} 2>/dev/null | grep -- '-' | grep -v old}
ALL_BILINGUAL_MODELS    := ${shell echo '${ALL_LANG_PAIRS}' | tr ' ' "\n" |  grep -v -- '\+'}
ALL_MULTILINGUAL_MODELS := ${shell echo '${ALL_LANG_PAIRS}' | tr ' ' "\n" | grep -- '\+'}


##----------------------------------------------------------------------------
## pre-processing and vocabulary
##----------------------------------------------------------------------------

## joint source+target sentencepiece model
ifeq (${USE_JOINT_SUBWORD_MODEL},1)
  SUBWORDS = jointspm
endif

## type of subword segmentation (bpe|spm)
## model vocabulary size (NOTE: BPESIZE is used as default)
SUBWORDS              ?= spm
BPESIZE               ?= 32000
SRCBPESIZE            ?= ${BPESIZE}
TRGBPESIZE            ?= ${BPESIZE}
SUBWORD_VOCAB_SIZE    ?= ${BPESIZE}
SUBWORD_SRCVOCAB_SIZE ?= ${SUBWORD_VOCAB_SIZE}
SUBWORD_TRGVOCAB_SIZE ?= ${SUBWORD_VOCAB_SIZE}

SUBWORD_MODEL_NAME ?= opus

ifeq (${SUBWORDS},bpe)
  BPESRCMODEL       = ${WORKDIR}/train/${SUBWORD_MODEL_NAME}.src.bpe${SUBWORD_SRCVOCAB_SIZE:000=}k-model
  BPETRGMODEL       = ${WORKDIR}/train/${SUBWORD_MODEL_NAME}.trg.bpe${SUBWORD_TRGVOCAB_SIZE:000=}k-model
  BPE_MODEL         = ${WORKDIR}/train/${SUBWORD_MODEL_NAME}.bpe${SUBWORD_VOCAB_SIZE:000=}k-model
  SUBWORD_SRC_MODEL = ${BPESRCMODEL}
  SUBWORD_TRG_MODEL = ${BPETRGMODEL}
else
  SPMSRCMODEL       = ${WORKDIR}/train/${SUBWORD_MODEL_NAME}.src.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k-model
  SPMTRGMODEL       = ${WORKDIR}/train/${SUBWORD_MODEL_NAME}.trg.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k-model
  SPM_MODEL         = ${WORKDIR}/train/${SUBWORD_MODEL_NAME}.${SUBWORDS}${SUBWORD_VOCAB_SIZE:000=}k-model
  SUBWORD_SRC_MODEL = ${SPMSRCMODEL}
  SUBWORD_TRG_MODEL = ${SPMTRGMODEL}
  SUBWORD_SRC_VOCAB = ${SPMSRCMODEL}.vocab
  SUBWORD_TRG_VOCAB = ${SPMTRGMODEL}.vocab
endif


## don't delete subword models!
.PRECIOUS: ${SUBWORD_SRC_MODEL} ${SUBWORD_TRG_MODEL}

## size of the joined vocabulary
## TODO: heuristically add 1,000 to cover language labels is a bit ad-hoc
VOCABSIZE  ?= $$((${SUBWORD_SRCVOCAB_SIZE} + ${SUBWORD_TRGVOCAB_SIZE} + 1000))

## for document-level models
CONTEXT_SIZE ?= 100


## pre-processing/data-cleanup type
## PRE .......... apply basic normalisation scripts
## CLEAN_TYPE ... clean = simple noise filtering
##                strict = some additional cleanup based on test set stats
## CLEAN_TESTDATA_TYPE should stay as 'clean' because
## we need those data sets to get the parameters
## for the strict mode

PRE                  ?= simple
CLEAN_TRAINDATA_TYPE ?= strict
CLEAN_DEVDATA_TYPE   ?= strict
CLEAN_TESTDATA_TYPE  ?= clean


## subword splitting type
PRE_SRC   = ${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k
PRE_TRG   = ${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k



## dev and test data come from one specific data set
## if we have a bilingual model

ifeq (${words ${SRCLANGS}},1)
ifeq (${words ${TRGLANGS}},1)
  DEVSET_NAME  ?= ${DEVSET}
  TESTSET_NAME ?= ${TESTSET}
endif
endif

## otherwise we give them a generic name

DEVSET_NAME  ?= opus-dev
TESTSET_NAME ?= opus-test


## DATADIR = directory where the train/dev/test data are
## TODO: MODELDIR still in use?
## TODO: SPMDIR still in use? (monolingual sp models)

DATADIR  = ${WORKHOME}/data
MODELDIR = ${WORKHOME}/models/${LANGPAIRSTR}
SPMDIR   = ${WORKHOME}/SentencePieceModels

## train data sets (word alignment for the guided alignment option)
TRAIN_BASE = ${WORKDIR}/train/${DATASET}
TRAIN_SRC  = ${TRAIN_BASE}.src
TRAIN_TRG  = ${TRAIN_BASE}.trg
TRAIN_ALG  = ${TRAIN_BASE}${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}.src-trg.alg.gz
TRAIN_S2T  = ${TRAIN_BASE}${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}.s2t.gz
TRAIN_T2S  = ${TRAIN_BASE}${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}.t2s.gz

## data sets that are pre-processed and ready to be used
TRAINDATA_SRC = ${TRAIN_SRC}.clean.${PRE_SRC}.gz 
TRAINDATA_TRG = ${TRAIN_TRG}.clean.${PRE_TRG}.gz
DEVDATA_SRC   = ${DEV_SRC}.${PRE_SRC} 
DEVDATA_TRG   = ${DEV_TRG}.${PRE_TRG}
TESTDATA_SRC  = ${TEST_SRC}.${PRE_SRC} 
TESTDATA_TRG  = ${TEST_TRG}

## training data in local space
LOCAL_TRAIN_SRC = ${TMPWORKDIR}/${LANGPAIRSTR}/train/${DATASET}.src
LOCAL_TRAIN_TRG = ${TMPWORKDIR}/${LANGPAIRSTR}/train/${DATASET}.trg
LOCAL_TRAIN     = ${TMPWORKDIR}/${LANGPAIRSTR}/train/${DATASET}
LOCAL_MONO_DATA = ${TMPWORKDIR}/${LANGSTR}/train/${DATASET}.mono

## dev and test data
DEV_SRC   ?= ${WORKDIR}/val/${DEVSET_NAME}.src
DEV_TRG   ?= ${WORKDIR}/val/${DEVSET_NAME}.trg

TEST_SRC  ?= ${WORKDIR}/test/${TESTSET_NAME}.src
TEST_TRG  ?= ${WORKDIR}/test/${TESTSET_NAME}.trg


## home directories for back and forward translation
BACKTRANS_HOME    ?= backtranslate
FORWARDTRANS_HOME ?= ${BACKTRANS_HOME}
PIVOTTRANS_HOME   ?= pivoting



## model basename and optional sub-dir
## NR is used to create model ensembles
## NR is also used to generate a seed value for initialisation

MODEL            =  ${MODEL_SUBDIR}${DATASET}${TRAINSIZE}${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}
NR               =  1

MODEL_BASENAME   = ${MODEL}.${MODELTYPE}.model${NR}
MODEL_VALIDLOG   = ${MODEL}.${MODELTYPE}.valid${NR}.log
MODEL_TRAINLOG   = ${MODEL}.${MODELTYPE}.train${NR}.log
MODEL_START      = ${WORKDIR}/${MODEL_BASENAME}.npz
MODEL_DONE       = ${WORKDIR}/${MODEL_BASENAME}.done
MODEL_FINAL      = ${WORKDIR}/${MODEL_BASENAME}.npz.best-perplexity.npz
MODEL_DECODER    = ${MODEL_FINAL}.decoder.yml

## quantized models
MODEL_BIN              = ${WORKDIR}/${MODEL_BASENAME}.intgemm8.bin
MODEL_BIN_ALPHAS       = ${WORKDIR}/${MODEL_BASENAME}.intgemm8.alphas.bin
MODEL_BIN_TUNED        = ${WORKDIR}/${MODEL_BASENAME}.intgemm8tuned.bin
MODEL_BIN_TUNED_ALPHAS = ${WORKDIR}/${MODEL_BASENAME}.intgemm8tuned.alphas.bin
MODEL_INTGEMM8TUNED    = ${WORKDIR}/${MODEL_BASENAME}.intgemm8tuned.npz

## lexical short-lists
SHORTLIST_NRVOC     = 100
SHORTLIST_NRTRANS   = 100
MODEL_BIN_SHORTLIST = ${WORKDIR}/${MODEL}.lex-s2t-${SHORTLIST_NRVOC}-${SHORTLIST_NRTRANS}.bin




.PRECIOUS: ${MODEL_FINAL} ${MODEL_BIN}


## for sentence-piece models: get plain text vocabularies
## for others: extract vocabulary from training data with MarianNMT
## backwards compatibility: if there is already a vocab-file then use it

# ifeq (${SUBWORDS},spm)
# ifeq ($(wildcard ${WORKDIR}/${MODEL}.vocab.yml),)
#   USE_SPM_VOCAB ?= 1
# endif
# endif

## use vocab from sentence piece instead of 
## marian_vocab from training data

ifeq ($(USE_SPM_VOCAB),1)
  MODEL_VOCAB     = ${WORKDIR}/${MODEL}.vocab.yml
  MODEL_SRCVOCAB  = ${WORKDIR}/${MODEL}.src.vocab
  MODEL_TRGVOCAB  = ${WORKDIR}/${MODEL}.trg.vocab
else
  MODEL_VOCAB     = ${WORKDIR}/${MODEL}.vocab.yml
  MODEL_SRCVOCAB  = ${MODEL_VOCAB}
  MODEL_TRGVOCAB  = ${MODEL_VOCAB}
endif



# find the latest model that has the same modeltype/modelvariant with or without guided alignment
# to be used if the flag CONTINUE_EXISTING is set to 1
# - without guided alignment (remove if part of the current): ${subst -align,,${MODELTYPE}}
# - with guided alignment (remove and add again):             ${subst -align,,${MODELTYPE}}-align
#
# Don't use the ones that are tuned for a specific language pair or domain!

ifeq (${CONTINUE_EXISTING},1)
  MODEL_LATEST = $(firstword \
	${shell ls -t 	${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}.model[0-9].npz \
			${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}-align.model[0-9].npz \
			${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}.best-perplexity.npz \
			${WORKDIR}/*${MODEL_VARIANT}.${PRE_SRC}-${PRE_TRG}.${subst -align,,${MODELTYPE}}-align.best-perplexity.npz \
		2>/dev/null | grep -v 'tuned4' })
  MODEL_LATEST_VOCAB     = $(shell echo "${MODEL_LATEST}" | \
		sed 's|\.${PRE_SRC}-${PRE_TRG}\..*$$|.${PRE_SRC}-${PRE_TRG}.vocab.yml|')
  MARIAN_EARLY_STOPPING = 15
endif



## test set translation and scores

TEST_TRANSLATION = ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}
TEST_EVALUATION  = ${TEST_TRANSLATION}.eval
TEST_COMPARISON  = ${TEST_TRANSLATION}.compare



## parameters for running Marian NMT

MARIAN_GPUS             ?= 0
MARIAN_EXTRA            = 
MARIAN_VALID_FREQ       ?= 10000
MARIAN_SAVE_FREQ        ?= ${MARIAN_VALID_FREQ}
MARIAN_DISP_FREQ        ?= ${MARIAN_VALID_FREQ}
MARIAN_EARLY_STOPPING   ?= 10
MARIAN_VALID_MINI_BATCH ?= 16
MARIAN_MAXI_BATCH       ?= 500
MARIAN_DROPOUT          ?= 0.1
MARIAN_MAX_LENGTH	?= 500
MARIAN_ENC_DEPTH        ?= 6
MARIAN_DEC_DEPTH        ?= 6
MARIAN_ATT_HEADS        ?= 8
MARIAN_DIM_EMB          ?= 512
MARIAN_CLIP_NORM        ?= 5

## default = shuffle data and batches 
## (set to batches or none to change this)
# MARIAN_SHUFFLE        ?= data
MARIAN_SHUFFLE          ?= batches

## default: use sqlite database to store data
## remove this to use regular temp data
## set to --shuffle-in-ram to keep all shuffled data in RAM
# MARIAN_DATA_STORAGE     ?= --sqlite


## set to global for lower memory usage in multiprocess training
## TODO: does this parameter really work?
MARIAN_SHARDING         ?= local


## TODO: currently marianNMT crashes with workspace > 26000 (does it?)
## TODO: move this to individual env settings?
##       problem: we need to know MODELTYPE before we can set this
ifeq (${GPU},p100)
  MARIAN_WORKSPACE = 13000

else ifeq (${GPU},a100)
ifeq ($(subst -align,,${MODELTYPE}),transformer-big)
  MARIAN_WORKSPACE = 15000
else ifeq ($(subst -align,,${MODELTYPE}),transformer-small)
  MARIAN_WORKSPACE = 10000
else ifeq ($(subst -align,,${MODELTYPE}),transformer-tiny)
  MARIAN_WORKSPACE = 10000
else ifeq ($(subst -align,,${MODELTYPE}),transformer-tiny11)
  MARIAN_WORKSPACE = 10000
else
  MARIAN_WORKSPACE = 20000
endif

else ifeq (${GPU},v100)
ifeq ($(subst -align,,${MODELTYPE}),transformer-big)
  MARIAN_WORKSPACE = 15000
else ifeq ($(subst -align,,${MODELTYPE}),transformer-small)
  MARIAN_WORKSPACE = 10000
else ifeq ($(subst -align,,${MODELTYPE}),transformer-tiny)
  MARIAN_WORKSPACE = 10000
else ifeq ($(subst -align,,${MODELTYPE}),transformer-tiny11)
  MARIAN_WORKSPACE = 10000
else
  MARIAN_WORKSPACE = 20000
endif

else
  MARIAN_WORKSPACE = 10000
endif


## TODO: do we need to reduce workspace for decoding?
# MARIAN_DECODER_WORKSPACE = $$((${MARIAN_WORKSPACE} / 2))
MARIAN_DECODER_WORKSPACE = 10000


## weights associated with training examples
ifneq ("$(wildcard ${TRAIN_WEIGHTS})","")
	MARIAN_TRAIN_WEIGHTS = --data-weighting ${TRAIN_WEIGHTS}
endif


## NR allows to train several models for proper ensembling
## (with shared vocab)
## DANGER: if several models are started at the same time
## then there is some racing issue with creating the vocab!

ifdef NR
  SEED=${NR}${NR}${NR}${NR}
else
  SEED=1234
endif


## decoder flags (CPU and GPU variants)

MARIAN_BEAM_SIZE = 4
MARIAN_MINI_BATCH = 256
MARIAN_MAXI_BATCH = 512
# MARIAN_MINI_BATCH = 512
# MARIAN_MAXI_BATCH = 1024
# MARIAN_MINI_BATCH = 768
# MARIAN_MAXI_BATCH = 2048


ifeq ($(GPU_AVAILABLE),1)
  MARIAN_SCORER_FLAGS = -n1 -d ${MARIAN_GPUS} \
			--quiet-translation -w ${MARIAN_DECODER_WORKSPACE} \
			--mini-batch ${MARIAN_MINI_BATCH} --maxi-batch ${MARIAN_MAXI_BATCH} --maxi-batch-sort src
  MARIAN_DECODER_FLAGS = -b ${MARIAN_BEAM_SIZE} -n1 -d ${MARIAN_GPUS} \
			--quiet-translation -w ${MARIAN_DECODER_WORKSPACE} \
			--mini-batch ${MARIAN_MINI_BATCH} --maxi-batch ${MARIAN_MAXI_BATCH} --maxi-batch-sort src \
			--max-length ${MARIAN_MAX_LENGTH} --max-length-crop
# --fp16
else
  MARIAN_SCORER_FLAGS = -n1 --cpu-threads ${HPC_CORES} \
			--quiet-translation \
			--mini-batch ${HPC_CORES} --maxi-batch 100 --maxi-batch-sort src
  MARIAN_DECODER_FLAGS = -b ${MARIAN_BEAM_SIZE} -n1 --cpu-threads ${HPC_CORES} \
			--quiet-translation \
			--mini-batch ${HPC_CORES} --maxi-batch 100 --maxi-batch-sort src \
			--max-length ${MARIAN_MAX_LENGTH} --max-length-crop
  MARIAN_EXTRA = --cpu-threads ${HPC_CORES}
endif






## make some data size-specific configuration parameters
## TODO: is it OK to delete LOCAL_TRAIN data?

SMALLEST_TRAINSIZE ?= 10000
SMALL_TRAINSIZE    ?= 100000
MEDIUM_TRAINSIZE   ?= 500000
LARGE_TRAINSIZE    ?= 1000000
LARGEST_TRAINSIZE  ?= 10000000

${WORKDIR}/${MODELCONFIG}:
	@echo ".... create model configuration file '$@'"
	@mkdir -p ${dir $@}
	@if [ -e ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz ]; then \
	  ${MAKE} ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.charfreq \
		  ${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.charfreq; \
	  s=`${GZCAT} ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz | head -10000001 | wc -l`; \
	  S=`cat ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.charfreq | wc -l`; \
	  T=`cat ${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.charfreq | wc -l`; \
	else \
	  ${MAKE} ${LOCAL_TRAIN_SRC}; \
	  ${MAKE} ${LOCAL_TRAIN_SRC}.charfreq ${LOCAL_TRAIN_TRG}.charfreq; \
	  s=`head -10000001 ${LOCAL_TRAIN_SRC} | wc -l`; \
	  S=`cat ${LOCAL_TRAIN_SRC}.charfreq | wc -l`; \
	  T=`cat ${LOCAL_TRAIN_TRG}.charfreq | wc -l`; \
	fi; \
	if [ $$s -gt ${LARGEST_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data bigger than ${LARGEST_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 16g"        >> $@; \
	  echo "GPUJOB_SUBMIT  = -gpu01" >> $@; \
	  echo "SUBWORD_VOCAB_SIZE    = ${SUBWORD_VOCAB_SIZE}"    >> $@; \
	  echo "DEVSIZE    = ${DEVSIZE}"    >> $@; \
	  echo "TESTSIZE   = ${TESTSIZE}"   >> $@; \
	  echo "DEVMINSIZE = ${DEVMINSIZE}" >> $@; \
	elif [ $$s -gt ${LARGE_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data bigger than ${LARGE_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 12g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = "         >> $@; \
	  echo "MARIAN_VALID_FREQ = 2500"  >> $@; \
	  echo "SUBWORD_VOCAB_SIZE    = ${SUBWORD_VOCAB_SIZE}"    >> $@; \
	  echo "DEVSIZE    = ${DEVSIZE}"    >> $@; \
	  echo "TESTSIZE   = ${TESTSIZE}"   >> $@; \
	  echo "DEVMINSIZE = ${DEVMINSIZE}" >> $@; \
	elif [ $$s -gt ${MEDIUM_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data bigger than ${MEDIUM_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 8g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = "         >> $@; \
	  echo "MARIAN_VALID_FREQ = 2500"  >> $@; \
	  echo "MARIAN_WORKSPACE  = 10000" >> $@; \
	  echo "SUBWORD_VOCAB_SIZE    = 12000"         >> $@; \
	  echo "DEVSIZE    = ${DEVSIZE}"    >> $@; \
	  echo "TESTSIZE   = ${TESTSIZE}"   >> $@; \
	  echo "DEVMINSIZE = ${DEVMINSIZE}" >> $@; \
	elif [ $$s -gt ${SMALL_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data bigger than ${SMALL_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 4g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = "         >> $@; \
	  echo "MARIAN_VALID_FREQ = 1000"  >> $@; \
	  echo "MARIAN_WORKSPACE  = 5000"  >> $@; \
	  echo "MARIAN_VALID_MINI_BATCH = 8" >> $@; \
	  echo "SUBWORD_VOCAB_SIZE     = 4000"        >> $@; \
	  echo "DEVSIZE     = 1000"        >> $@; \
	  echo "TESTSIZE    = 1000"        >> $@; \
	  echo "DEVMINSIZE  = 250"         >> $@; \
	elif [ $$s -gt ${SMALLEST_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data less than ${SMALLEST_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 4g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = "         >> $@; \
	  echo "MARIAN_VALID_FREQ = 1000"  >> $@; \
	  echo "MARIAN_WORKSPACE  = 3500"  >> $@; \
	  echo "MARIAN_DROPOUT    = 0.5"   >> $@; \
	  echo "MARIAN_VALID_MINI_BATCH = 4" >> $@; \
	  echo "SUBWORD_VOCAB_SIZE     = 1000"        >> $@; \
	  echo "DEVSIZE     = 500"         >> $@; \
	  echo "TESTSIZE    = 1000"        >> $@; \
	  echo "DEVMINSIZE  = 100"         >> $@; \
	else \
	    echo "${LANGPAIRSTR} too small"; \
	fi; \
	if [ -e $@ ]; then \
	  if [ $$S -gt 1000 ]; then \
	    echo "SUBWORD_SRCVOCAB_SIZE  = 32000"     >> $@; \
	  fi; \
	  if [ $$T -gt 1000 ]; then \
	    echo "SUBWORD_TRGVOCAB_SIZE  = 32000"     >> $@; \
	  fi; \
	fi
	@echo "SRCLANGS    = ${SRCLANGS}"    >> $@
	@echo "TRGLANGS    = ${TRGLANGS}"    >> $@
	@echo "SKIPLANGS   = ${SKIPLANGS}"   >> $@
	@echo "LANGPAIRSTR = ${LANGPAIRSTR}" >> $@
	@echo "DATASET     = ${DATASET}"     >> $@
	@echo "TRAINSET    = ${TRAINSET}"    >> $@
	@echo "DEVSET      = ${DEVSET}"      >> $@
	@echo "TESTSET     = ${TESTSET}"     >> $@
	@echo "PRE         = ${PRE}"         >> $@
	@echo "SUBWORDS    = ${SUBWORDS}"    >> $@
ifdef SHUFFLE_DATA
	@echo "SHUFFLE_DATA      = ${SHUFFLE_DATA}"       >> $@
endif
ifdef FIT_DATA_SIZE
	@echo "FIT_DATA_SIZE     = ${FIT_DATA_SIZE}"      >> $@
endif
ifdef FIT_DEVDATA_SIZE
	@echo "FIT_DEVDATA_SIZE  = ${FIT_DEVDATA_SIZE}"   >> $@
endif
	@echo "MAX_OVER_SAMPLING = ${MAX_OVER_SAMPLING}"  >> $@
	@echo "USE_REST_DEVDATA  = ${USE_REST_DEVDATA}"   >> $@
ifdef USE_TARGET_LABELS
	@echo "USE_TARGET_LABELS = ${USE_TARGET_LABELS}"  >> $@
endif
ifdef USE_SPM_VOCAB
	@echo "USE_SPM_VOCAB = ${USE_SPM_VOCAB}"  >> $@
endif
ifdef USE_JOINT_SUBWORD_MODEL
	@echo "USE_JOINT_SUBWORD_MODEL = ${USE_JOINT_SUBWORD_MODEL}"  >> $@
endif






################################################################
### DEPRECATED? ################################################
################################################################

## list of all languages in OPUS
## TODO: do we still need this?
## --> see OPUSLANGS which is directly taken from the API
opus-langs.txt:
	wget -O $@.tmp ${OPUSAPI}?languages=true
	grep '",' $@.tmp | tr '",' '  ' | sort | tr "\n" ' ' | sed 's/  */ /g' > $@
	rm -f $@.tmp

## all language pairs in opus in one file
## TODO: do we need this file?
opus-langpairs.txt:
	for l in ${OPUS_LANGS}; do \
	  wget -O $@.tmp ${OPUSAPI}?source=$$l\&languages=true; \
	  grep '",' $@.tmp | tr '",' '  ' | sort | tr "\n" ' ' | sed 's/  */ /g' > $@.tmp2; \
	  for t in `cat $@.tmp2`; do \
	    if [ $$t \< $$l ]; then \
	      echo "$$t-$$l" >> $@.all; \
	    else \
	      echo "$$l-$$t" >> $@.all; \
	    fi \
	  done; \
	  rm -f $@.tmp $@.tmp2; \
	done
	tr ' ' "\n" < $@.all |\
	sed 's/ //g' | sort -u | tr "\n" ' ' > $@
	rm -f $@.all


