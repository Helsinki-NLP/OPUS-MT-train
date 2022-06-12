# -*-makefile-*-
#
# translate big texts with OPUS-MT models
# essential variables:
#
#   INPUT_FILE ......... gzipped plain text file (one sentence per line)
#   OUTPUT_DIR ......... output directory
#   SRC ................ source language ID
#   TRG ................ target language ID
#
# - find and fetch best model according to leader board
# - split and prepare source language data
# - translate and post-process data
# - move to separate sub-dir with the latest translations



## text to be translated (expect gzipped raw data file, one sentence per line)

INPUT_FILE  ?= $(firstword ${CLEAN_TRAIN_SRC})
INPUT_NAME  ?= $(basename $(notdir ${INPUT_FILE:.gz=}))


## work directories

OPUSMT_WORKHOME = ${WORKHOME}/translations
OUTPUT_DIR     ?= ${OPUSMT_WORKHOME}/${LANGPAIR}



## find the best OPUS-MT model from the leaderboard for this language pair

best-opusmt-model = ${shell grep -H .  ${LEADERBOARD_HOME}/${1}/*/${2}.txt | \
			sed 's/txt:[0-9\.]*//' | sed -r 's/tatoeba-test-v[0-9]{4}-[0-9]{2}-[0-9]{2}/tatoeba-test/' | \
			rev | uniq -f1 | rev | cut -f2 | uniq -c | sort -nr | head -1 | sed 's/^.*http/http/'}
OPUSMT_MODELZIP  := ${call best-opusmt-model,${LANGPAIR},bleu-scores}
OPUSMT_MODELINFO := ${OPUSMT_MODELZIP:.zip=.yml}
OPUSMT_MODELNAME := ${patsubst %.zip,%,${notdir ${OPUSMT_MODELZIP}}}
OPUSMT_MODELDIR  ?= ${OUTPUT_DIR}/${OPUSMT_MODELNAME}


## translations in various parts

OUTPUT_PART  ?= aa
OUTPUT_BASE  = ${OUTPUT_DIR}/${INPUT_NAME}.${OPUSMT_MODELNAME}.${LANGPAIR}
OUTPUT_SRC   = ${OUTPUT_BASE}.${SRC}.${OUTPUT_PART}.gz
OUTPUT_PRE   = ${OUTPUT_BASE}.${SRC}.spm.${OUTPUT_PART}.gz
OUTPUT_TRG   = ${OUTPUT_BASE}.${TRG}.${OUTPUT_PART}.gz


## latest translations in a separate sub-directory

OUTPUT_LATEST_SRC    = ${OUTPUT_DIR}/latest/${INPUT_NAME}.${OUTPUT_PART}.${LANGPAIR}.${SRC}.gz
OUTPUT_LATEST_TRG    = ${OUTPUT_DIR}/latest/${INPUT_NAME}.${OUTPUT_PART}.${LANGPAIR}.${TRG}.gz
OUTPUT_LATEST_README = ${OUTPUT_DIR}/latest/README.md


## all parts of the bitext

OUTPUT_PARTS          = $(subst .,,${suffix ${basename ${wildcard ${OUTPUT_PRE:${OUTPUT_PART}.gz=}??.gz}}})
ALL_OUTPUT_SRC        = ${patsubst %,${OUTPUT_BASE}.${SRC}.%.gz,${OUTPUT_PARTS}}
ALL_OUTPUT_TRG        = ${patsubst %,${OUTPUT_BASE}.${TRG}.%.gz,${OUTPUT_PARTS}}
ALL_OUTPUT_LATEST_SRC = ${patsubst %,${OUTPUT_DIR}/latest/${INPUT_NAME}.%.${LANGPAIR}.${SRC}.gz,${OUTPUT_PARTS}}
ALL_OUTPUT_LATEST_TRG = ${patsubst %,${OUTPUT_DIR}/latest/${INPUT_NAME}.%.${LANGPAIR}.${TRG}.gz,${OUTPUT_PARTS}}


## don't remove files of intermediate translations
# .PRECIOUS: ${OUTPUT_SRC} ${OUTPUT_TRG} ${ALL_OUTPUT_SRC} ${ALL_OUTPUT_TRG}
.PRECIOUS: ${OUTPUT_BASE}.${SRC}.%.gz ${OUTPUT_BASE}.${TRG}.%.gz


## split size in nr-of-lines
## default part to be selected = aa
OPUSMT_SPLIT_SIZE ?= 1000000

## maximum input length (number sentence piece segments)
## NEW: don't set this by default but rather make this a choice
# OPUSMT_MAX_LENGTH ?= 200





## fetch the model
.PHONY: opusmt-model
opusmt-model: ${OPUSMT_MODELDIR}/decoder.yml

## prepare model and data (current part only)
.PHONY: opusmt-prepare
opusmt-prepare: opusmt-model ${OUTPUT_PRE}

## translate current part
.PHONY: opusmt-translate
opusmt-translate: ${OUTPUT_TRG}
	${MAKE} ${OUTPUT_LATEST_SRC} ${OUTPUT_LATEST_TRG} ${OUTPUT_LATEST_README}

## create a slurm job to translate the data
.PHONY: opusmt-translate-job
opusmt-translate-job:
	${MAKE} opusmt-translate.${SUBMIT_PREFIX}

## translate all parts
.PHONY: opusmt-translate-all-parts opusmt-translate-all
opusmt-translate-all opusmt-translate-all-parts: ${ALL_OUTPUT_LATEST_TRG}
	${MAKE} opusmt-all-source-parts


## create individual jobs for translating each part of the input data
## (only start the job if the file does not exist yet)
.PHONY: opusmt-translate-all-jobs opusmt-translate-all-parts-jobs
opusmt-translate-all-jobs opusmt-translate-all-parts-jobs:
	for p in ${OUTPUT_PARTS}; do \
	  if [ ! -e ${OUTPUT_DIR}/${INPUT_NAME}.$${p}_${OPUSMT_MODELNAME}.${LANGPAIR}.${TRG}.gz ]; then \
	    rm -f opusmt-translate.${SUBMIT_PREFIX}; \
	    ${MAKE} OUTPUT_PART=$$p opusmt-translate.${SUBMIT_PREFIX}; \
	  fi \
	done


## create all source language parts
.PHONY: opusmt-all-source-parts
opusmt-all-source-parts: ${ALL_OUTPUT_LATEST_SRC}




## check whether we need target language labels

MULTI_TARGET_MODEL := ${shell ${WGET} -qq -O - ${OPUSMT_MODELINFO} | grep 'use-target-labels' | wc -l}
ifneq (${MULTI_TARGET_MODEL},0)
  TARGET_LANG_LABEL := ${shell ${WGET} -qq -O - ${OPUSMT_MODELINFO} | grep -o '>>${TRG}.*<<' | head -1}
endif


.PHONY: print-modelinfo
print-modelinfo:
	@echo ${OPUSMT_MODELNAME}
	@echo ${OPUSMT_MODELZIP}
	@echo ${OPUSMT_MODELINFO}
	@echo "multi-target model: ${MULTI_TARGET_MODEL}"
	@echo "target language label: ${TARGET_LANG_LABEL}"

.PHONY: print-modelname
print-modelname:
	@echo ${OPUSMT_MODELNAME}


#########################################################################
## fetch the best model
#########################################################################

${OPUSMT_MODELDIR}/decoder.yml:
ifneq (${OPUSMT_MODELZIP},)
	mkdir -p ${dir $@}
	${WGET} -q -O ${dir $@}/model.zip ${OPUSMT_MODELZIP}
	cd ${dir $@} && unzip model.zip
	rm -f ${dir $@}/model.zip
	mv ${dir $@}/preprocess.sh ${dir $@}/preprocess-old.sh
	sed 's#perl -C -pe.*$$#perl -C -pe  "s/(?!\\n)\\p{C}/ /g;" |#' \
	< ${dir $@}/preprocess-old.sh > ${dir $@}/preprocess.sh
	chmod +x ${dir $@}/preprocess.sh
endif


#########################################################################
## pre-process source language data
## - split into parts
## - subword tokenisation etc
#########################################################################

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${SRC} ${TRG} ${OPUSMT_MODELDIR}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${OPUSMT_MODELDIR}/source.spm
endif


## prepare input data (only if a model and an input file exist)
## NOTE: if OPUSMT_MAX_LENGTH is set then do seom extra filtering!

${OUTPUT_PRE}: ${INPUT_FILE} mosesdecoder marian-dev tools/marian-dev tools/moses-scripts
ifneq (${OPUSMT_MODELZIP},)
ifneq (${INPUT_FILE},)
	mkdir -p ${dir $@}
	${MAKE} ${OPUSMT_MODELDIR}/decoder.yml
ifdef OPUSMT_MAX_LENGTH
	${GZCAT} $< | grep -v '[<>{}]' |\
	${OPUSMT_MODELDIR}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${OPUSMT_MAX_LENGTH});print;}' |\
	split -l ${OPUSMT_SPLIT_SIZE} - ${patsubst %${OUTPUT_PART}.gz,%,$@}
else
	${GZCAT} $< | ${OPUSMT_MODELDIR}/preprocess.sh ${PREPROCESS_ARGS} |\
	split -l ${OPUSMT_SPLIT_SIZE} - ${patsubst %${OUTPUT_PART}.gz,%,$@}
endif
	${GZIP} -f ${patsubst %${OUTPUT_PART}.gz,%,$@}??
endif
endif

## just to make sure that the pre-processing script
## finds the moses-scripts and spm-encode
mosesdecoder:
	ln -s ${MOSESHOME} $@

marian-dev:
	ln -s ${MARIAN_HOME:/build/=} $@

tools/marian-dev:
	mkdir -p $(dir $@)
	ln -s ${MARIAN_HOME:/build/=} $@

tools/moses-scripts:
	mkdir -p $(dir $@)
	ln -s ${MOSESHOME} $@


## merge SentencePiece segments in the source text
## (Why? because we may want to have bitexts from all parts)

${OUTPUT_BASE}.${SRC}.%.gz: ${OUTPUT_BASE}.${SRC}.spm.%.gz
	if [ -e ${patsubst ${OUTPUT_BASE}.${SRC}.%.gz,${OUTPUT_BASE}.${TRG}.%.gz,$@} ]; then \
	  mkdir -p ${dir $@}; \
	  ${GZCAT} $< |\
	  sed 's/ //g;s/▁/ /g' | \
	  sed 's/^ *//;s/ *$$//' |\
	  sed 's/^>>[a-z]*<< //' |\
	  gzip -c > $@; \
	fi


#########################################################################
## translate
#########################################################################

${OUTPUT_BASE}.${TRG}.%.gz: ${OUTPUT_BASE}.${SRC}.spm.%.gz
ifneq (${OPUSMT_MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${OPUSMT_MODELDIR}/decoder.yml
	${LOAD_ENV} && \
	${MARIAN_DECODER} \
		-c ${OPUSMT_MODELDIR}/decoder.yml \
		-i $< \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > $@
endif


#########################################################################
## move latest translations to a separate directory
##
## --> this allows multiple translation iterations
##     without duplicating the data we want to use in MT training
#########################################################################

${OUTPUT_DIR}/latest/${INPUT_NAME}.%.${LANGPAIR}.${SRC}.gz: ${OUTPUT_BASE}.${SRC}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${OUTPUT_DIR}/latest/${INPUT_NAME}.%.${LANGPAIR}.${TRG}.gz: ${OUTPUT_BASE}.${TRG}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${OUTPUT_LATEST_README}: ${OPUSMT_MODELDIR}/README.md
	mkdir -p ${dir $@}
	rsync $< $@



#########################################################################
## sanity checking
## - check length (number of lines)
## - remove incomplete translations
#########################################################################

opusmt-check-length:
	@echo "check ${LANGPAIR}"
	@${MAKE} opusmt-check-translated
	@${MAKE} opusmt-check-latest

opusmt-check-latest:
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

opusmt-check-translated:
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

opusmt-remove-%-all opusmt-check-%-all:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  make SRC=$$s TRG=$$t ${@:-all=}; \
	done

opusmt-remove-incomplete:
	${MAKE} opusmt-remove-incomplete-translated
	${MAKE} opusmt-remove-incomplete-latest

opusmt-remove-incomplete-translated:
	@echo "check ${LANGPAIR}"
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

opusmt-remove-incomplete-latest:
	@echo "check ${LANGPAIR}"
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
