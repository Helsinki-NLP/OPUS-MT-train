# -*-makefile-*-
#
# model configurations
#


## name of the model-specific configuration file
MODELCONFIG ?= config.mk


## various ways of setting the model languages

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


## final default is sv-fi
## NEW: don't do this ... can create confusion ...
##
# SRCLANGS ?= sv
# TRGLANGS ?= fi


## set SRC and TRG unless they are specified already
ifneq (${words ${SRCLANGS}},1)
  SRC ?= multi
else
  SRC = ${SRCLANGS}
endif
ifneq (${words ${TRGLANGS}},1)
  TRG ?= multi
else
  TRG = ${TRGLANGS}
endif


## OLD: set to first and last lang
## --> this makes the evaluation look like it is one lang-pair
##
# SRC ?= ${firstword ${SRCLANGS}}
# TRG ?= ${lastword ${TRGLANGS}}


## SKIP_LANGPAIRS can be used to skip certain language pairs
## in data preparation for multilingual models
## ---> this can be good to skip BIG language pairs
##      that would very much dominate all the data
## must be a pattern that can be matched by egrep
## e.g. en-de|en-fr

SKIP_LANGPAIRS ?= "nothing"


## set SHUFFLE_DATA if you want to shuffle data for 
## each language pair to be added to the training data
## --> especially useful in connection with FIT_DATA_SIZE
##  
# SHUFFLE_DATA = 1

## devtest data is shuffled by default
SHUFFLE_DEVDATA = 1


## set FIT_DATA_SIZE to a specific value to fit the training data
## to a certain number of lines for each language pair in the collection
## --> especially useful for multilingual models for balancing the 
##     the size for each language pair
## the script does both, over- and undersampling
##
# FIT_DATA_SIZE = 100000

## maximum number of repeating the same data set 
## in oversampling
MAX_OVER_SAMPLING ?= 50


## set CHECK_TRAINDATA_SIZE if you want to check that each
## bitext has equal number of lines in source and target
## ---> this only prints a warning if not
##
# CHECK_TRAINDATA_SIZE


# sorted languages and langpair used to match resources in OPUS
SORTLANGS   = $(sort ${SRC} ${TRG})
SPACE       = $(empty) $(empty)
LANGPAIR    = ${firstword ${SORTLANGS}}-${lastword ${SORTLANGS}}
LANGSRCSTR  = ${subst ${SPACE},+,$(SRCLANGS)}
LANGTRGSTR  = ${subst ${SPACE},+,$(TRGLANGS)}
LANGPAIRSTR = ${LANGSRCSTR}-${LANGTRGSTR}


## for monolingual things
LANGS ?= ${SRCLANGS}
LANGID ?= ${firstword ${LANGS}}
LANGSTR ?= ${subst ${SPACE},+,$(LANGS)}


## for same language pairs: add numeric extension
## (this is neccessary to keep source and target files separate)
ifeq (${SRC},$(TRG))
  SRCEXT = ${SRC}1
  TRGEXT = ${SRC}2
else
  SRCEXT = ${SRC}
  TRGEXT = ${TRG}
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

DEVSIZE     = 2500
TESTSIZE    = 2500

## NEW: significantly reduce devminsize
## (= absolute minimum we need as devdata)
## NEW: define an alternative small size for DEV and TEST
## OLD DEVMINSIZE:
# DEVMINSIZE  = 1000

DEVSMALLSIZE  = 1000
TESTSMALLSIZE = 1000
DEVMINSIZE    = 250


## set additional argument options for opus_read (if it is used)
## e.g. OPUSREAD_ARGS = -a certainty -tr 0.3
OPUSREAD_ARGS = 


##----------------------------------------------------------------------------
## resources in OPUS
##----------------------------------------------------------------------------

## OLD: get corpora directly from the file system
#
# ELRA_CORPORA = ${patsubst %/latest/xml/${LANGPAIR}.xml.gz,%,\
#		${patsubst ${OPUSHOME}/%,%,\
#		${shell ls ${OPUSHOME}/ELRA-*/latest/xml/${LANGPAIR}.xml.gz 2>/dev/null}}}
#
# EXCLUDE_CORPORA ?= WMT-News MPC1 ${ELRA_CORPORA}
#
# OPUSCORPORA  = $(filter-out ${EXCLUDE_CORPORA},${patsubst %/latest/xml/${LANGPAIR}.xml.gz,%,\
#		${patsubst ${OPUSHOME}/%,%,\
#		${shell ls ${OPUSHOME}/*/latest/xml/${LANGPAIR}.xml.gz 2>/dev/null}}})
#
# OPUSMONOCORPORA = $(filter-out ${EXCLUDE_CORPORA} ,${patsubst %/latest/mono/${LANGID}.txt.gz,%,\
#		${patsubst ${OPUSHOME}/%,%,\
#		${shell ls ${OPUSHOME}/*/latest/mono/${LANGID}.txt.gz}}})


## NEW: get data from the OPUS-API

OPUSAPI = http://opus.nlpl.eu/opusapi/

get-opus-mono      = ${shell wget -qq -O - ${OPUSAPI}?source=${1}\&corpora=True | ${JQ} '.corpora[]' | tr '"' ' '}
get-opus-bitexts   = ${shell wget -qq -O - ${OPUSAPI}?source=${1}\&target=${2}\&corpora=True | ${JQ} '.corpora[]' | tr '"' ' '}
get-bigger-bitexts = ${shell wget -qq -O - ${OPUSAPI}?source=${1}\&target=${2}\&preprocessing=xml\&version=latest | \
	${JQ} -r '.corpora[1:] | .[] | select(.source!="") | select(.target!="") | select(.alignment_pairs>${3}) | .corpus' }
get-opus-langs     = ${shell wget -qq -O - ${OPUSAPI}?languages=True | ${JQ} '.languages[]' | tr '"' ' '}
get-opus-version   = ${shell wget -qq -O - ${OPUSAPI}?source=${1}\&target=${2}\&corpus=${3}\&preprocessing=xml\&version=latest | ${JQ} '.corpora[] | .version' | sed 's/"//g' | head -1}
get-elra-bitexts   = ${shell wget -qq -O - ${OPUSAPI}?source=${1}\&target=${2}\&corpora=True | \
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

POTENTIAL_DEVSETS = Tatoeba GlobalVoices infopankki JW300 bible-uedin
BIGGER_BITEXTS   := ${call get-bigger-bitexts,${SRC},${TRG},${DEVSMALLSIZE}}
SMALLER_BITEXTS  := ${call get-bigger-bitexts,${SRC},${TRG},${DEVMINSIZE}}
DEVSET ?= ${firstword 	${filter ${POTENTIAL_DEVSETS},${BIGGER_BITEXTS}} \
			${filter ${POTENTIAL_DEVSETS},${SMALLER_BITEXTS}}}

## why would we need foreach?
#DEVSET ?= ${firstword 	${foreach c,${POTENTIAL_DEVSETS},${filter ${c},${BIGGER_BITEXTS}}} \
# 			${foreach c,${POTENTIAL_DEVSETS},${filter ${c},${SMALLER_BITEXTS}}}}



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
ALL_LANG_PAIRS := ${shell ls ${WORKHOME} | grep -- '-' | grep -v old}
ALL_BILINGUAL_MODELS := ${shell echo '${ALL_LANG_PAIRS}' | tr ' ' "\n" |  grep -v -- '\+'}
ALL_MULTILINGUAL_MODELS := ${shell echo '${ALL_LANG_PAIRS}' | tr ' ' "\n" | grep -- '\+'}


##----------------------------------------------------------------------------
## pre-processing and vocabulary
##----------------------------------------------------------------------------

SUBWORDS   ?= spm
BPESIZE    ?= 32000
SRCBPESIZE ?= ${BPESIZE}
TRGBPESIZE ?= ${BPESIZE}

BPEMODELNAME ?= opus

BPESRCMODEL  ?= ${WORKDIR}/train/${BPEMODELNAME}.src.bpe${SRCBPESIZE:000=}k-model
BPETRGMODEL  ?= ${WORKDIR}/train/${BPEMODELNAME}.trg.bpe${TRGBPESIZE:000=}k-model

SPMSRCMODEL  ?= ${WORKDIR}/train/${BPEMODELNAME}.src.spm${SRCBPESIZE:000=}k-model
SPMTRGMODEL  ?= ${WORKDIR}/train/${BPEMODELNAME}.trg.spm${TRGBPESIZE:000=}k-model

.PRECIOUS: ${BPESRCMODEL} ${BPETRGMODEL}
.PRECIOUS: ${SPMSRCMODEL} ${SPMTRGMODEL}


VOCABSIZE  ?= $$((${SRCBPESIZE} + ${TRGBPESIZE} + 1000))

## for document-level models
CONTEXT_SIZE = 100

## pre-processing type
# PRE     = norm
PRE       = simple
PRE_SRC   = ${SUBWORDS}${SRCBPESIZE:000=}k
PRE_TRG   = ${SUBWORDS}${TRGBPESIZE:000=}k


##-------------------------------------
## default name of the data set (and the model)
##-------------------------------------

DATASET ?= opus

## DATADIR = directory where the train/dev/test data are
## WORKDIR = directory used for training

DATADIR  = ${WORKHOME}/data
WORKDIR  = ${WORKHOME}/${LANGPAIRSTR}
MODELDIR = ${WORKHOME}/models/${LANGPAIRSTR}
SPMDIR   = ${WORKHOME}/SentencePieceModels

## data sets
TRAIN_BASE = ${WORKDIR}/train/${DATASET}
TRAIN_SRC  = ${TRAIN_BASE}.src
TRAIN_TRG  = ${TRAIN_BASE}.trg
TRAIN_ALG  = ${TRAIN_BASE}${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}.src-trg.alg.gz

## training data in local space
LOCAL_TRAIN_SRC = ${TMPDIR}/${LANGPAIRSTR}/train/${DATASET}.src
LOCAL_TRAIN_TRG = ${TMPDIR}/${LANGPAIRSTR}/train/${DATASET}.trg
LOCAL_MONO_DATA = ${TMPDIR}/${LANGSTR}/train/${DATASET}.mono

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

DEV_SRC   ?= ${WORKDIR}/val/${DEVSET_NAME}.src
DEV_TRG   ?= ${WORKDIR}/val/${DEVSET_NAME}.trg

TEST_SRC  ?= ${WORKDIR}/test/${TESTSET_NAME}.src
TEST_TRG  ?= ${WORKDIR}/test/${TESTSET_NAME}.trg


MODEL_SUBDIR =
MODEL        = ${MODEL_SUBDIR}${DATASET}${TRAINSIZE}.${PRE_SRC}-${PRE_TRG}
# MODELTYPE  = transformer-align
MODELTYPE    = transformer
NR           = 1

MODEL_BASENAME   = ${MODEL}.${MODELTYPE}.model${NR}
MODEL_VALIDLOG   = ${MODEL}.${MODELTYPE}.valid${NR}.log
MODEL_TRAINLOG   = ${MODEL}.${MODELTYPE}.train${NR}.log
MODEL_START      = ${WORKDIR}/${MODEL_BASENAME}.npz
MODEL_FINAL      = ${WORKDIR}/${MODEL_BASENAME}.npz.best-perplexity.npz
MODEL_DECODER    = ${MODEL_FINAL}.decoder.yml

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




## latest model with the same pre-processing but any data or modeltype
## except for models that include the string 'tuned4' (fine-tuned models)
## --> this will be used if the flag CONTINUE_EXISTING is set on

ifdef CONTINUE_EXISTING
  MODEL_LATEST = $(firstword \
	${shell ls -t ${WORKDIR}/*.${PRE_SRC}-${PRE_TRG}.*.best-perplexity.npz \
		2>/dev/null | grep -v 'tuned4' })
  MODEL_LATEST_VOCAB     = $(shell echo "${MODEL_LATEST}" | \
		sed 's|\.${PRE_SRC}-${PRE_TRG}\..*$$|.${PRE_SRC}-${PRE_TRG}.vocab.yml|')
  MODEL_LATEST_OPTIMIZER = $(shell echo "${MODEL_LATEST}" | \
		sed 's|.best-perplexity.npz|.optimizer.npz|')
endif



## test set translation and scores

TEST_TRANSLATION = ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}
TEST_EVALUATION  = ${TEST_TRANSLATION}.eval
TEST_COMPARISON  = ${TEST_TRANSLATION}.compare



## parameters for running Marian NMT

MARIAN_GPUS             = 0
MARIAN_EXTRA            = 
MARIAN_VALID_FREQ       = 10000
MARIAN_SAVE_FREQ        = ${MARIAN_VALID_FREQ}
MARIAN_DISP_FREQ        = ${MARIAN_VALID_FREQ}
MARIAN_EARLY_STOPPING   = 10
MARIAN_VALID_MINI_BATCH = 16
MARIAN_MAXI_BATCH       = 500
MARIAN_DROPOUT          = 0.1
MARIAN_MAX_LENGTH	= 500

MARIAN_DECODER_GPU    = -b 12 -n1 -d ${MARIAN_GPUS} \
			--mini-batch 8 --maxi-batch 32 --maxi-batch-sort src \
			--max-length ${MARIAN_MAX_LENGTH} --max-length-crop
MARIAN_DECODER_CPU    = -b 12 -n1 --cpu-threads ${HPC_CORES} \
			--mini-batch 8 --maxi-batch 32 --maxi-batch-sort src \
			--max-length ${MARIAN_MAX_LENGTH} --max-length-crop
MARIAN_DECODER_FLAGS = ${MARIAN_DECODER_GPU}


## TODO: currently marianNMT crashes with workspace > 26000
ifeq (${GPU},p100)
  MARIAN_WORKSPACE = 13000
else ifeq (${GPU},v100)
  # MARIAN_WORKSPACE = 30000
  # MARIAN_WORKSPACE = 26000
  MARIAN_WORKSPACE = 24000
  # MARIAN_WORKSPACE = 18000
  # MARIAN_WORKSPACE = 16000
else
  MARIAN_WORKSPACE = 10000
endif

## check whether we have GPUs available
## if not: use CPU mode for decoding
ifneq ($(wildcard ${NVIDIA_SMI}),)
ifeq (${shell nvidia-smi | grep failed | wc -l},1)
  MARIAN_DECODER_FLAGS = ${MARIAN_DECODER_CPU}
  MARIAN_EXTRA = --cpu-threads ${HPC_CORES}
endif
else
  MARIAN_DECODER_FLAGS = ${MARIAN_DECODER_CPU}
  MARIAN_EXTRA = --cpu-threads ${HPC_CORES}
endif

## weights associated with training examples
ifneq ("$(wildcard ${TRAIN_WEIGHTS})","")
	MARIAN_TRAIN_WEIGHTS = --data-weighting ${TRAIN_WEIGHTS}
endif



### training a model with Marian NMT
##
## NR allows to train several models for proper ensembling
## (with shared vocab)
##
## DANGER: if several models are started at the same time
## then there is some racing issue with creating the vocab!

ifdef NR
  SEED=${NR}${NR}${NR}${NR}
else
  SEED=1234
endif




## make some data size-specific configuration parameters
## TODO: is it OK to delete LOCAL_TRAIN data?

.PHONY: config local-config
config local-config: ${WORKDIR}/${MODELCONFIG}

SMALLEST_TRAINSIZE = 10000
SMALL_TRAINSIZE    = 100000
MEDIUM_TRAINSIZE   = 500000
LARGE_TRAINSIZE    = 1000000
LARGEST_TRAINSIZE  = 10000000

${WORKDIR}/${MODELCONFIG}:
	mkdir -p ${dir $@}
	if [ -e ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz ]; then \
	  ${MAKE} ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.charfreq \
		  ${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.charfreq; \
	  s=`${ZCAT} ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz | head -10000001 | wc -l`; \
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
	  echo "GPUJOB_HPC_MEM = 8g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = -multigpu" >> $@; \
	  echo "BPESIZE    = ${BPESIZE}"    >> $@; \
	  echo "DEVSIZE    = ${DEVSIZE}"    >> $@; \
	  echo "TESTSIZE   = ${TESTSIZE}"   >> $@; \
	  echo "DEVMINSIZE = ${DEVMINSIZE}" >> $@; \
	elif [ $$s -gt ${LARGE_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data bigger than ${LARGE_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 8g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = "         >> $@; \
	  echo "MARIAN_VALID_FREQ = 2500"  >> $@; \
	  echo "BPESIZE    = ${BPESIZE}"    >> $@; \
	  echo "DEVSIZE    = ${DEVSIZE}"    >> $@; \
	  echo "TESTSIZE   = ${TESTSIZE}"   >> $@; \
	  echo "DEVMINSIZE = ${DEVMINSIZE}" >> $@; \
	elif [ $$s -gt ${MEDIUM_TRAINSIZE} ]; then \
	  echo "# ${LANGPAIRSTR} training data bigger than ${MEDIUM_TRAINSIZE}" > $@; \
	  echo "GPUJOB_HPC_MEM = 4g"       >> $@; \
	  echo "GPUJOB_SUBMIT  = "         >> $@; \
	  echo "MARIAN_VALID_FREQ = 2500"  >> $@; \
	  echo "MARIAN_WORKSPACE  = 10000" >> $@; \
	  echo "BPESIZE    = 12000"         >> $@; \
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
	  echo "BPESIZE     = 4000"        >> $@; \
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
	  echo "BPESIZE     = 1000"        >> $@; \
	  echo "DEVSIZE     = 500"         >> $@; \
	  echo "TESTSIZE    = 1000"        >> $@; \
	  echo "DEVMINSIZE  = 100"         >> $@; \
	else \
	    echo "${LANGPAIRSTR} too small"; \
	fi; \
	if [ -e $@ ]; then \
	  if [ $$S -gt 1000 ]; then \
	    echo "SRCBPESIZE  = 32000"     >> $@; \
	  fi; \
	  if [ $$T -gt 1000 ]; then \
	    echo "TRGBPESIZE  = 32000"     >> $@; \
	  fi; \
	fi
	echo "SRCLANGS    = ${SRCLANGS}"    >> $@
	echo "TRGLANGS    = ${TRGLANGS}"    >> $@
	echo "SKIPLANGS   = ${SKIPLANGS}"   >> $@
	echo "LANGPAIRSTR = ${LANGPAIRSTR}" >> $@
	echo "DATASET     = ${DATASET}"     >> $@
	echo "TRAINSET    = ${TRAINSET}"    >> $@
	echo "DEVSET      = ${DEVSET}"      >> $@
	echo "TESTSET     = ${TESTSET}"     >> $@
	echo "PRE         = ${PRE}"         >> $@
	echo "SUBWORDS    = ${SUBWORDS}"    >> $@
ifdef SHUFFLE_DATA
	echo "SHUFFLE_DATA      = ${SHUFFLE_DATA}"       >> $@
endif
ifdef FIT_DATA_SIZE
	echo "FIT_DATA_SIZE     = ${FIT_DATA_SIZE}"      >> $@
endif
	echo "MAX_OVER_SAMPLING = ${MAX_OVER_SAMPLING}"  >> $@
	echo "USE_REST_DEVDATA  = ${USE_REST_DEVDATA}"   >> $@
ifdef USE_TARGET_LABELS
	echo "USE_TARGET_LABELS = ${USE_TARGET_LABELS}"  >> $@
endif
ifdef USE_SPM_VOCAB
	echo "USE_SPM_VOCAB = ${USE_SPM_VOCAB}"  >> $@
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



