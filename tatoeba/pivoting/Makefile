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
MODELZIP := ${shell wget -qq -O - ${TATOEBA_RELEASED} | grep '^${TRANSLATE_LANGPAIR}' | head -1 | cut -f4}
MODELINFO = ${patsubst ${TATOEBA_MODEL_STORAGE}/%.zip,${TATOEBA_GITRAW}/models/%.yml,${MODELZIP}}
MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
MODELDIR  = ${OUTPUT_DIR}/${TRANSLATE_LANGPAIR}/${MODELNAME}

MULTI_TARGET_MODEL := ${shell wget -qq -O - ${MODELINFO} | grep 'use-target-labels' | wc -l}
ifneq (${MULTI_TARGET_MODEL},0)
  TARGET_LANG_LABEL := ${shell wget -qq -O - ${MODELINFO} | grep -o '>>${TRG}.*<<'}
endif



BITEXT_DATADIR = ${PWD}/../work/data/simple
MODEL_WORKDIR  = ${PWD}/../work/${PIVOT}-${TRG}
BITEXT_SRCRAW  = ${BITEXT_DATADIR}/Tatoeba-train-${TATOEBA_VERSION}.${SORTED_LANGPAIR}.clean.${PIVOT}.gz
BITEXT_SRCPRE  = ${wildcard ${MODEL_WORKDIR}/train/opusTC${TATOEBA_VERSION_NOHYPHEN}.src.clean.spm*.gz}

BITEXT_BASE    = ${OUTPUT_DIR}/Tatoeba-train.${MODELNAME}.${PIVOT}-${SRC}-${TRG}
BITEXT_SRC     = ${BITEXT_BASE}.${SRC}.${PART}.gz
BITEXT_PRE     = ${BITEXT_BASE}.${SRC}.spm.${PART}.gz
BITEXT_TRG     = ${BITEXT_BASE}.${TRG}.${PART}.gz

BITEXT_LATEST_SRC    = ${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.${PART}.${SRC}.gz
BITEXT_LATEST_TRG    = ${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.${PART}.${TRG}.gz
BITEXT_LATEST_README = ${OUTPUT_DIR}/latest/README.md


## all parts of the bitext
PARTS                 = $(subst .,,${suffix ${basename ${wildcard ${BITEXT_PRE:${PART}.gz=}??.gz}}})
ALL_BITEXT_LATEST_SRC = ${patsubst %,${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.%.${SRC}.gz,${PARTS}}
ALL_BITEXT_LATEST_TRG = ${patsubst %,${OUTPUT_DIR}/latest/Tatoeba-train.${PIVOT}-${SRC}-${TRG}.%.${TRG}.gz,${PARTS}}


## don't delete translated text even if the process crashes
.PRECIOUS: ${BITEXT_BASE}.${TRG}.%.gz

.PHONY: all
all: translate

.PHONY: prepare
prepare: ${MODELDIR}/decoder.yml ${BITEXT_PRE}

.PHONY: translate
translate: ${BITEXT_LATEST_README} ${BITEXT_LATEST_TRG}
	${MAKE} ${BITEXT_LATEST_SRC}

## translate all parts
.PHONY: translate-all-parts
translate-all-parts: ${ALL_BITEXT_LATEST_TRG}
	${MAKE} source-all-parts

.PHONY: source-all-parts
source-all-parts: ${ALL_BITEXT_LATEST_SRC}


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
	wget -O ${dir $@}/model.zip ${MODELZIP}
	cd ${dir $@} && unzip model.zip
	rm -f ${dir $@}/model.zip
	mv ${dir $@}/preprocess.sh ${dir $@}/preprocess-old.sh
	sed 's#perl -C -pe.*$$#perl -C -pe  "s/(?!\\n)\\p{C}/ /g;" |#' \
	< ${dir $@}/preprocess-old.sh > ${dir $@}/preprocess.sh
	chmod +x ${dir $@}/preprocess.sh
endif


## pre-process data

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${SRC} ${TRG} ${MODELDIR}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${MODELDIR}/source.spm
endif



ifeq (${BITEXT_SRCPRE},)

${BITEXT_SRCRAW}:
	${MAKE} -C .. SRCLANGS=${PIVOT} TRGLANGS=${TRG} clean-data

else

${BITEXT_SRCRAW}: ${BITEXT_SRCPRE}
	sed 's/ //g;s/▁/ /g' < $< | sed 's/^ *//;s/ *$$//' | ${GZIP} -f > $@

endif


${BITEXT_PRE}: ${BITEXT_SRCRAW}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${MODELDIR}/decoder.yml
	${GZCAT} $< |\
	grep -v '[<>{}]' |\
	${MODELDIR}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${MAX_LENGTH});print;}' |\
	split -l ${SPLIT_SIZE} - ${patsubst %${PART}.gz,%,$@}
	${GZIP} -f ${patsubst %${PART}.gz,%,$@}??
endif



## merge SentencePiece segments in the source text
## (Why? because we filter out some data from the original wiki text, see above)

${BITEXT_BASE}.${SRC}.%.gz: ${BITEXT_BASE}.${SRC}.spm.%.gz
	if [ -e ${patsubst ${BITEXT_BASE}.${SRC}.%.gz,${BITEXT_BASE}.${TRG}.%.gz,$@} ]; then \
	  mkdir -p ${dir $@}; \
	  ${GZCAT} $< |\
	  sed 's/ //g;s/▁/ /g' | \
	  sed 's/^ *//;s/ *$$//' |\
	  sed 's/^>>[a-z]*<< //' |\
	  gzip -c > $@; \
	fi


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

${BITEXT_BASE}.${TRG}.%.gz: ${BITEXT_BASE}.${SRC}.spm.%.gz
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
	  for S in `ls ${OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	  done \
	fi

check-translated:
	@for S in `ls ${OUTPUT_DIR}/*.${SRC}.spm.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	done

check-length:
	@echo "check ${OUTPUT_DIR}"
	@${MAKE} check-translated
	@${MAKE} check-latest


remove-%-all check-%-all:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  make SRC=$$s TRG=$$t ${@:-all=}; \
	done



remove-incomplete:
	${MAKE} remove-incomplete-translated
	${MAKE} remove-incomplete-latest

remove-incomplete-translated:
	@echo "check ${OUTPUT_DIR}"
	@mkdir -p ${OUTPUT_DIR}/incomplete
	@for S in `ls ${OUTPUT_DIR}/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${OUTPUT_DIR}/incomplete/; \
	      mv $$T ${OUTPUT_DIR}/incomplete/; \
	    fi \
	done


remove-incomplete-latest:
	@echo "check ${OUTPUT_DIR}"
	@mkdir -p ${OUTPUT_DIR}/incomplete/latest
	@if [ -d ${OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${OUTPUT_DIR}/incomplete/latest/; \
	      mv $$T ${OUTPUT_DIR}/incomplete/latest/; \
	    fi \
	  done \
	fi

