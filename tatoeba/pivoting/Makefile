#
# translate PIVOT language into SRC language
# to make a synthetic SRC-TRG corpus from another
# PIVOT-TRG corpus


PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../

include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk


SRC = swe
TRG = fin
PIVOT = eng


## change decoder settings
## TODO: do we need this?

MARIAN_BEAM_SIZE=1
MARIAN_MINI_BATCH=100
MARIAN_MAXI_BATCH=100
MARIAN_MAX_LENGTH=200
MARIAN_WORKSPACE=12000


TATOEBA_VERSION          ?= v2021-08-07
TATOEBA_VERSION_NOHYPHEN ?= $(subst -,,${TATOEBA_VERSION})

# TATOEBA_GITRAW        = https://github.com/Helsinki-NLP/Tatoeba-Challenge/raw
TATOEBA_GITRAW        = https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_RELEASED      = ${TATOEBA_GITRAW}/models/released-model-results-all.txt
TATOEBA_RELEASED_BT   = https://object.pouta.csc.fi/Tatoeba-MT-bt/released-data.txt
TATOEBA_MODEL_STORAGE = https://object.pouta.csc.fi/Tatoeba-MT-models

## container for storing backtranslations
BT_CONTAINER          = Tatoeba-MT-bt
BT_CWORK_ONTAINER     = project-Tatoeba-MT-bt

## split size in nr-of-lines
## default part to be selected = aa
SPLIT_SIZE ?= 1000000

## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
MAX_LENGTH    ?= 200
MAX_SENTENCES ?= ${SPLIT_SIZE}

TRANSLATE_LANGPAIR = ${PIVOT}-${SRC}
ORIGINAL_LANGPAIR  = ${PIVOT}-${TRG}
NEW_LANGPAIR       = ${SRC}-${TRG}

SORTLANGS          = $(sort ${PIVOT} ${TRG})
SORTED_LANGPAIR    = ${firstword ${SORTLANGS}}-${lastword ${SORTLANGS}}

PART           ?= aa
OUTPUT_DIR     ?= ${NEW_LANGPAIR}


# MODELZIP = https://object.pouta.csc.fi/Tatoeba-Challenge/ang.tar
MODELZIP := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED} | grep '^${TRANSLATE_LANGPAIR}' | head -1 | cut -f4}
MODELINFO = ${patsubst ${TATOEBA_MODEL_STORAGE}/%.zip,${TATOEBA_GITRAW}/models/%.yml,${MODELZIP}}
MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
MODELDIR  = ${OUTPUT_DIR}/${TRANSLATE_LANGPAIR}/${MODELNAME}

MULTI_TARGET_MODEL := ${shell ${WGET} -qq -O - ${MODELINFO} | grep 'use-target-labels' | wc -l}
ifneq (${MULTI_TARGET_MODEL},0)
  TARGET_LANG_LABEL := ${shell ${WGET} -qq -O - ${MODELINFO} | grep -o '>>${TRG}.*<<'}
endif



BITEXT_DATADIR  = ${PWD}/../work/data/simple
MODEL_WORKDIR   = ${PWD}/../work/${PIVOT}-${TRG}
BITEXT_PIVOTRAW = ${BITEXT_DATADIR}/Tatoeba-train-${TATOEBA_VERSION}.${SORTED_LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${PIVOT}.gz
BITEXT_TRGRAW   = ${BITEXT_DATADIR}/Tatoeba-train-${TATOEBA_VERSION}.${SORTED_LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${TRG}.gz

BITEXT_BASE    = ${OUTPUT_DIR}/Tatoeba-train.${MODELNAME}.${PIVOT}-${SRC}-${TRG}
BITEXT_PIVOT   = ${BITEXT_BASE}.${PIVOT}.${PART}.gz
BITEXT_PRE     = ${BITEXT_BASE}.${PIVOT}.spm.${PART}.gz
BITEXT_SRC     = ${BITEXT_BASE}.${SRC}.${PART}.gz
BITEXT_TRG     = ${BITEXT_BASE}.${TRG}.${PART}.gz

BITEXT_LATEST_SRC    = ${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.${PART}.${SRC}.gz
BITEXT_LATEST_TRG    = ${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.${PART}.${TRG}.gz
BITEXT_LATEST_README = ${OUTPUT_DIR}/latest/README.md


## all parts of the bitext
PARTS                 = $(subst .,,${suffix ${basename ${wildcard ${BITEXT_PRE:${PART}.gz=}??.gz}}})
ALL_BITEXT_LATEST_SRC = ${patsubst %,${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.%.${SRC}.gz,${PARTS}}
ALL_BITEXT_LATEST_TRG = ${patsubst %,${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.%.${TRG}.gz,${PARTS}}


## don't delete translated text even if the process crashes
.PRECIOUS: ${BITEXT_BASE}.${SRC}.%.gz

.PHONY: all
all: translate

.PHONY: prepare
prepare: ${MODELDIR}/decoder.yml ${BITEXT_PRE}

.PHONY: translate
translate: ${BITEXT_LATEST_README} ${BITEXT_LATEST_SRC}
	${MAKE} ${BITEXT_LATEST_TRG}

## translate all parts
.PHONY: translate-all-parts
translate-all-parts: ${ALL_BITEXT_LATEST_SRC} ${BITEXT_LATEST_TRG}
	${MAKE} target-all-parts

.PHONY: target-all-parts
target-all-parts: ${BITEXT_LATEST_TRG}
	${MAKE} ${ALL_BITEXT_LATEST_TRG}


.PHONY: print-modelinfo
print-modelinfo:
	@echo ${MODELNAME}
	@echo ${MODELZIP}
	@echo ${MODELINFO}
	@echo "multi-target model: ${MULTI_TARGET_MODEL}"
	@echo "target language label: ${TARGET_LANG_LABEL}"

## fetch the latest model

${MODELDIR}/decoder.yml:
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${WGET} -O ${dir $@}/model.zip ${MODELZIP}
	cd ${dir $@} && unzip model.zip
	rm -f ${dir $@}/model.zip
	mv ${dir $@}/preprocess.sh ${dir $@}/preprocess-old.sh
	sed 's#perl -C -pe.*$$#perl -C -pe  "s/(?!\\n)\\p{C}/ /g;" |#' \
	< ${dir $@}/preprocess-old.sh > ${dir $@}/preprocess.sh
	chmod +x ${dir $@}/preprocess.sh
endif


## pre-process data

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${PIVOT} ${SRC} ${MODELDIR}/source.spm
else
  PREPROCESS_ARGS = ${PIVOT} ${MODELDIR}/source.spm
endif



${BITEXT_PIVOTRAW}:
	${MAKE} -C .. SRCLANGS=${PIVOT} TRGLANGS=${TRG} clean-data

${BITEXT_PRE}: ${BITEXT_PIVOTRAW}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${MODELDIR}/decoder.yml
	${GZCAT} $< |\
	${MODELDIR}/preprocess.sh ${PREPROCESS_ARGS} |\
	split -l ${SPLIT_SIZE} - ${patsubst %${PART}.gz,%,$@}
	${GZIP} -f ${patsubst %${PART}.gz,%,$@}??
endif

${BITEXT_TRG}: ${BITEXT_TRGRAW}
	${GZCAT} $< |\
	split -l ${SPLIT_SIZE} - ${patsubst %${PART}.gz,%,$@}
	${GZIP} -f ${patsubst %${PART}.gz,%,$@}??


## overwrite the file with the latest translations
## --> this allows multiple translation iterations
##     without duplicating the data we want to use in MT training

${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.%.${SRC}.gz: ${BITEXT_BASE}.${SRC}.%.gz
	mkdir -p ${dir $@}
	cp $< $@

${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.%.${TRG}.gz: ${BITEXT_BASE}.${TRG}.%.gz
	mkdir -p ${dir $@}
	cp $< $@

${BITEXT_LATEST_README}: ${MODELDIR}/README.md
	mkdir -p ${dir $@}
	cp $< $@


## translate

${BITEXT_BASE}.${SRC}.%.gz: ${BITEXT_BASE}.${PIVOT}.spm.%.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${MODELDIR}/decoder.yml
	${LOAD_ENV} && cd ${MODELDIR} && \
	${MARIAN_DECODER} \
		-c decoder.yml \
		-i ${PWD}/$< \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
endif


check-latest:
	@if [ -d ${OUTPUT_DIR}/latest ]; then \
	  for T in `ls ${OUTPUT_DIR}/latest/*.${TRG}.gz`; do \
	    S=`echo $$T | sed 's/.${TRG}.gz/.${SRC}.gz/'`; \
	    if [ ! -e $$S ]; then \
	      echo "$$S does not exist!"; \
	    fi \
	  done; \
	  for S in `ls ${OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    if [ ! -e $$T ]; then \
	      echo "$$T does not exist!"; \
	    else \
	      a=`${GZCAT} $$S | wc -l`; \
	      b=`${GZCAT} $$T | wc -l`; \
	      if [ $$a != $$b ]; then \
	        echo "$$a != $$b	$$S	$$T"; \
	      else \
	        echo "$$a	$$S	$$T"; \
	      fi \
	    fi \
	  done; \
	fi

remove-incomplete-latest:
	@echo "check ${OUTPUT_DIR}"
	@mkdir -p ${OUTPUT_DIR}/incomplete/latest
	@if [ -d ${OUTPUT_DIR}/latest ]; then \
	  for T in `ls ${OUTPUT_DIR}/latest/*.${TRG}.gz`; do \
	    S=`echo $$T | sed 's/.${TRG}.gz/.${SRC}.gz/'`; \
	    if [ ! -e $$S ]; then \
	      echo "$$S does not exist!"; \
	      mv $$T ${OUTPUT_DIR}/incomplete/latest/; \
	    fi \
	  done; \
	  for S in `ls ${OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    if [ ! -e $$T ]; then \
	      echo "$$T does not exist!"; \
	      mv $$S ${OUTPUT_DIR}/incomplete/latest/; \
	    else \
	      a=`${GZCAT} $$S | wc -l`; \
	      b=`${GZCAT} $$T | wc -l`; \
	      if [ $$a != $$b ]; then \
	        echo "$$a != $$b	$$S	$$T"; \
	        mv $$S ${OUTPUT_DIR}/incomplete/latest/; \
	        mv $$T ${OUTPUT_DIR}/incomplete/latest/; \
	      fi \
	    fi \
	  done \
	fi

