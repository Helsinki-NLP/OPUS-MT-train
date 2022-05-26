# -*-makefile-*-
#
# translate text with OPUS-MT models
#
# - find and fecth best model according to leader board
# - split and prepare source language data
# - translate and post-process data
# - move to separate sub-dir with the latest translations



## text to be translated (expect gzipped raw data file, one sentence per line)

CORPUS_SRCRAW  ?= $(firstword ${CLEAN_TRAIN_SRC})


## work directories

OPUSMT_WORKHOME    = ${WORKHOME}/translations
OPUSMT_OUTPUT_DIR ?= ${OPUSMT_WORKHOME}/${LANGPAIR}


## translations together with the original source text (=bitext)

CORPUS_PART   ?= aa
CORPUS_NAME   ?= data
CORPUS_BASE    = ${OPUSMT_OUTPUT_DIR}/${CORPUS_NAME}.${MODELNAME}.${LANGPAIR}
CORPUS_SRC     = ${CORPUS_BASE}.${SRC}.${CORPUS_PART}.gz
CORPUS_PRE     = ${CORPUS_BASE}.${SRC}.spm.${CORPUS_PART}.gz
CORPUS_TRG     = ${CORPUS_BASE}.${TRG}.${CORPUS_PART}.gz


## latest translations in a separate sub-directory

CORPUS_LATEST_SRC    = ${OPUSMT_OUTPUT_DIR}/latest/${CORPUS_NAME}.${CORPUS_PART}.${LANGPAIR}.${SRC}.gz
CORPUS_LATEST_TRG    = ${OPUSMT_OUTPUT_DIR}/latest/${CORPUS_NAME}.${CORPUS_PART}.${LANGPAIR}.${TRG}.gz
CORPUS_LATEST_README = ${OPUSMT_OUTPUT_DIR}/latest/README.md


## all parts of the bitext

CORPUS_PARTS          = $(subst .,,${suffix ${basename ${wildcard ${CORPUS_PRE:${CORPUS_PART}.gz=}??.gz}}})
ALL_CORPUS_SRC        = ${patsubst %,${CORPUS_BASE}.${SRC}.%.gz,${CORPUS_PARTS}}
ALL_CORPUS_TRG        = ${patsubst %,${CORPUS_BASE}.${TRG}.%.gz,${CORPUS_PARTS}}
ALL_CORPUS_LATEST_SRC = ${patsubst %,${OPUSMT_OUTPUT_DIR}/latest/${CORPUS_NAME}.%.${LANGPAIR}.${SRC}.gz,${CORPUS_PARTS}}
ALL_CORPUS_LATEST_TRG = ${patsubst %,${OPUSMT_OUTPUT_DIR}/latest/${CORPUS_NAME}.%.${LANGPAIR}.${TRG}.gz,${CORPUS_PARTS}}


## don't remove files of intermediate translations
.PRECIOUS: ${ALL_CORPUS_SRC} ${ALL_CORPUS_TRG}



## split size in nr-of-lines
## default part to be selected = aa
OPUSMT_SPLIT_SIZE ?= 1000000

## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
OPUSMT_MAX_LENGTH ?= 200



#########################################################################
## find the best OPUS-MT model from the leaderboard
#########################################################################

best-opusmt-model = ${shell grep -H .  ${LEADERBOARD_HOME}/${1}/*/${2}.txt | \
			sed 's/txt:[0-9\.]*//' | sed -r 's/tatoeba-test-v[0-9]{4}-[0-9]{2}-[0-9]{2}/tatoeba-test/' | \
			rev | uniq -f1 | rev | cut -f2 | uniq -c | sort -nr | head -1 | sed 's/^.*http/http/'}
MODELZIP        := ${call best-opusmt-model,${LANGPAIR},bleu-scores}
MODELINFO       := ${MODELZIP:.zip=.yml}
MODELNAME       := ${patsubst %.zip,%,${notdir ${MODELZIP}}}




## fetch the model
.PHONY: opusmt-model
opusmt-model: ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/decoder.yml

## prepare model and data (current part only)
.PHONY: opusmt-prepare
opusmt-prepare: opusmt-mtmodel ${CORPUS_PRE}

## translate current part
.PHONY: opusmt-translate
opusmt-translate: ${CORPUS_LATEST_TRG}
	${MAKE} opusmt-model
	${MAKE} ${CORPUS_LATEST_SRC} ${CORPUS_LATEST_README}

## create a slurm job to translate the data
.PHONY: opusmt-translate-job
opusmt-translate-job:
	${MAKE} opusmt-translate.${SUBMIT_PREFIX}

## translate all parts
.PHONY: opusmt-translate-all-parts opusmt-translate-all
opusmt-translate-all opusmt-translate-all-parts: ${ALL_CORPUS_LATEST_TRG}
	${MAKE} opusmt-all-source-parts


## create individual jobs for translating each part of the input data
## (only start the job if the file does not exist yet)
.PHONY: opusmt-translate-all-jobs opusmt-translate-all-parts-jobs
opusmt-translate-all-jobs opusmt-translate-all-parts-jobs:
	for p in ${CORPUS_PARTS}; do \
	  if [ ! -e ${OPUSMT_OUTPUT_DIR}/${CORPUS_NAME}.$${p}_${MODELNAME}.${LANGPAIR}.${TRG}.gz ]; then \
	    rm -f opusmt-translate.${SUBMIT_PREFIX}; \
	    ${MAKE} CORPUS_PART=$$p opusmt-translate.${SUBMIT_PREFIX}; \
	  fi \
	done


## create all source language parts
.PHONY: opusmt-all-source-parts
opusmt-all-source-parts: ${ALL_CORPUS_LATEST_SRC}




## check whether we need target language labels

MULTI_TARGET_MODEL := ${shell ${WGET} -qq -O - ${MODELINFO} | grep 'use-target-labels' | wc -l}
ifneq (${MULTI_TARGET_MODEL},0)
  TARGET_LANG_LABEL := ${shell ${WGET} -qq -O - ${MODELINFO} | grep -o '>>${TRG}.*<<' | head -1}
endif


.PHONY: print-modelinfo
print-modelinfo:
	@echo ${MODELNAME}
	@echo ${MODELZIP}
	@echo ${MODELINFO}
	@echo "multi-target model: ${MULTI_TARGET_MODEL}"
	@echo "target language label: ${TARGET_LANG_LABEL}"

.PHONY: print-modelname
print-modelname:
	@echo ${MODELNAME}


#########################################################################
## fetch the best model
#########################################################################

${OPUSMT_OUTPUT_DIR}/${MODELNAME}/decoder.yml:
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${WGET} -q -O ${dir $@}/model.zip ${MODELZIP}
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
  PREPROCESS_ARGS = ${SRC} ${TRG} ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/source.spm
endif


${CORPUS_PRE}: ${CORPUS_SRCRAW} mosesdecoder marian-dev
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/decoder.yml
	${GZCAT} $< |\
	grep -v '[<>{}]' |\
	${OPUSMT_OUTPUT_DIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${OPUSMT_MAX_LENGTH});print;}' |\
	split -l ${OPUSMT_SPLIT_SIZE} - ${patsubst %${CORPUS_PART}.gz,%,$@}
	${GZIP} -f ${patsubst %${CORPUS_PART}.gz,%,$@}??
endif

## just to make sure that the pre-processing script
## finds the moses-scripts and spm-encode
mosesdecoder:
	ln -s ${MOSESHOME} $@

marian-dev:
	ln -s ${MARIAN_HOME:/build/=} $@

## merge SentencePiece segments in the source text
## (Why? because we may want to have bitexts from all parts)

${CORPUS_BASE}.${SRC}.%.gz: ${CORPUS_BASE}.${SRC}.spm.%.gz
	if [ -e ${patsubst ${CORPUS_BASE}.${SRC}.%.gz,${CORPUS_BASE}.${TRG}.%.gz,$@} ]; then \
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

${CORPUS_BASE}.${TRG}.%.gz: ${CORPUS_BASE}.${SRC}.spm.%.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/decoder.yml
	${LOAD_ENV} && \
	${MARIAN_DECODER} \
		-c ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/decoder.yml \
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

${OPUSMT_OUTPUT_DIR}/latest/${CORPUS_NAME}.%.${LANGPAIR}.${SRC}.gz: ${CORPUS_BASE}.${SRC}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${OPUSMT_OUTPUT_DIR}/latest/${CORPUS_NAME}.%.${LANGPAIR}.${TRG}.gz: ${CORPUS_BASE}.${TRG}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${CORPUS_LATEST_README}: ${OPUSMT_OUTPUT_DIR}/${MODELNAME}/README.md
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
	@if [ -d ${OPUSMT_OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${OPUSMT_OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
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
	@for S in `ls ${OPUSMT_OUTPUT_DIR}/*.${SRC}.spm.gz`; do \
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
	@mkdir -p ${OPUSMT_OUTPUT_DIR}/incomplete
	@for S in `ls ${OPUSMT_OUTPUT_DIR}/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${OPUSMT_OUTPUT_DIR}/incomplete/; \
	      mv $$T ${OPUSMT_OUTPUT_DIR}/incomplete/; \
	    fi \
	done

opusmt-remove-incomplete-latest:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${OPUSMT_OUTPUT_DIR}/incomplete/latest
	@if [ -d ${OPUSMT_OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${OPUSMT_OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${OPUSMT_OUTPUT_DIR}/incomplete/latest/; \
	      mv $$T ${OPUSMT_OUTPUT_DIR}/incomplete/latest/; \
	    fi \
	  done \
	fi
