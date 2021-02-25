#
# backtranslate wiki data with Tatoeba-MT challenge data
#
# only works with sentencepiece models!
#

PWD      := ${shell pwd}
TOOLSDIR := ${PWD}/../tools

include ../lib/env.mk
include ../lib/config.mk
include ../lib/slurm.mk

SRC ?= fin
TRG ?= eng



# TATOEBA_STORAGE     = https://object.pouta.csc.fi/Tatoeba-Challenge
TATOEBA_STORAGE       = https://object.pouta.csc.fi/Tatoeba-Challenge-WikiShuffled
TATOEBA_GITRAW        = https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_RELEASED      = ${TATOEBA_GITRAW}/models/released-model-results.txt
TATOEBA_MODEL_STORAGE = https://object.pouta.csc.fi/Tatoeba-MT-models


## various sources are available
## can be general wikipedia, wikinews, wikibooks, ...
# WIKISOURCE ?= wikipedia
WIKISOURCE ?= wiki

## split size in nr-of-lines
## default part to be selected = aa
SPLIT_SIZE ?= 1000000


## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
MAX_LENGTH    ?= 100
MAX_SENTENCES ?= ${SPLIT_SIZE}


LANGPAIR = ${SRC}-${TRG}

PWD := $(shell pwd)



# MODELZIP = https://object.pouta.csc.fi/Tatoeba-Challenge/ang.tar
MODELZIP := ${shell wget -qq -O - ${TATOEBA_GITRAW}/models/released-model-results.txt |\
		grep '^${LANGPAIR}' | head -1 | cut -f4}
MODELINFO = ${patsubst ${TATOEBA_MODEL_STORAGE}/%.zip,${TATOEBA_GITRAW}/models/%.yml,${MODELZIP}}
MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}

MULTI_TARGET_MODEL := ${shell wget -qq -O - ${MODELINFO} | grep 'use-target-labels' | wc -l}
ifneq (${MULTI_TARGET_MODEL},0)
  TARGET_LANG_LABEL := ${shell wget -qq -O - ${MODELINFO} | grep -o '>>${TRG}.*<<'}
endif

RELEASED_WIKIS := $(patsubst %.tar,%,${shell wget -qq -O - ${TATOEBA_GITRAW}/Wiki.md | \
					grep -o 'WikiShuffled/...\.tar' | cut -f2 -d'/'})


WIKI_DIR     = ${PWD}/wiki
LANGID       = ${SRC}
PART         = aa
OUTPUT_DIR   = ${LANGPAIR}
WIKI_TXT     = ${WIKI_DIR}/${LANGID}/${WIKISOURCE}.${PART}.gz
WIKI_SRC     = ${OUTPUT_DIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.gz
WIKI_PRE     = ${OUTPUT_DIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz
WIKI_TRG     = ${OUTPUT_DIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${TRG}.gz

WIKI_LATEST_SRC = ${OUTPUT_DIR}/latest/${WIKISOURCE}.${PART}.${LANGPAIR}.${SRC}.gz
WIKI_LATEST_TRG = ${OUTPUT_DIR}/latest/${WIKISOURCE}.${PART}.${LANGPAIR}.${TRG}.gz


## all parts of this wiki
PARTS = ${sort ${patsubst ${WIKI_DIR}/${LANGID}/${WIKISOURCE}.%.gz,%,\
		${wildcard ${WIKI_DIR}/${LANGID}/${WIKISOURCE}.??.gz}}}

# WIKISOURCES = wiki wikibooks wikinews wikiquote wikisource wiktionary
WIKISOURCES = ${sort $(patsubst %.txt.gz,%,$(notdir ${wildcard ${WIKI_DIR}/${LANGID}/*.txt.gz})) \
		$(patsubst %.${PART}.gz,%,$(notdir ${wildcard ${WIKI_DIR}/${LANGID}/*.${PART}.gz}))}


## targets for all parts of the current wiki source

ALLWIKIPARTS_TXT = ${patsubst %,${WIKI_DIR}/${LANGID}/${WIKISOURCE}.%.gz,${PARTS}}
ALLWIKIPARTS_SRC = ${patsubst %,${OUTPUT_DIR}/${WIKISOURCE}.%_${MODELNAME}.${LANGPAIR}.${SRC}.gz,${PARTS}}
ALLWIKIPARTS_PRE = ${patsubst %,${OUTPUT_DIR}/${WIKISOURCE}.%_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz,${PARTS}}
ALLWIKIPARTS_TRG = ${patsubst %,${OUTPUT_DIR}/${WIKISOURCE}.%_${MODELNAME}.${LANGPAIR}.${TRG}.gz,${PARTS}}

ALLWIKIPARTS_LATEST_SRC = ${patsubst %,${OUTPUT_DIR}/latest/${WIKISOURCE}.%.${LANGPAIR}.${SRC}.gz,${PARTS}}
ALLWIKIPARTS_LATEST_TRG = ${patsubst %,${OUTPUT_DIR}/latest/${WIKISOURCE}.%.${LANGPAIR}.${TRG}.gz,${PARTS}}


## all wiki sources for the selected part

ALLWIKIS_TXT = ${patsubst %,${WIKI_DIR}/${LANGID}/%.${PART}.gz,${WIKISOURCES}}
ALLWIKIS_SRC = ${patsubst %,${OUTPUT_DIR}/%.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.gz,${WIKISOURCES}}
ALLWIKIS_PRE = ${patsubst %,${OUTPUT_DIR}/%.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz,${WIKISOURCES}}
ALLWIKIS_TRG = ${patsubst %,${OUTPUT_DIR}/%.${PART}_${MODELNAME}.${LANGPAIR}.${TRG}.gz,${WIKISOURCES}}



## don't delete translated text if the process crashes
.PRECIOUS: ${WIKI_TRG}


ifdef LOCAL_SCRATCH
  TMPDIR = ${LOCAL_SCRATCH}
endif

ifeq (${shell hostname --domain 2>/dev/null},bullx)
  LOAD_MODULES = module use -a /projappl/nlpl/software/modules/etc/ && \
		 module load nlpl-udpipe nlpl-opus &&
endif


.PHONY: all
all: translate

all-jobs: fetch
	${MAKE} prepare-allwikis
	${MAKE} translate-all-jobs

all2eng:
	for w in ${filter-out eng,${RELEASED_WIKIS}}; do \
	  echo "make SRC=$$w TRG=eng all-jobs"; \
	done


.PHONY: fetch
fetch: ${WIKI_DIR}/${SRC}

.PHONY: prepare
prepare: ${LANGPAIR}/${MODELNAME}/decoder.yml ${WIKI_TXT}

.PHONY: prepare-allwikis
prepare-allwikis: ${LANGPAIR}/${MODELNAME}/decoder.yml ${ALLWIKIS_TXT}

.PHONY: translate
translate: ${WIKI_LATEST_TRG}
	${MAKE} ${WIKI_LATEST_SRC}

## translate all parts
.PHONY: translate-all-parts
translate-all-parts: ${ALLWIKIPARTS_LATEST_TRG}
	${MAKE} ${ALLWIKIPARTS_LATEST_SRC}

## translate all wikis and all parts
.PHONY: translate-all
translate-all:
	for s in ${WIKISOURCES}; do \
	  ${MAKE} translate-allparts; \
	done

## create jobs for translating all parts
.PHONY: translate-all-parts-jobs
translate-all-parts-jobs: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for p in ${PARTS}; do \
	  ${MAKE} PART=$$p translate.submit; \
	done

## create jobs for translating all parts of all wikis
.PHONY: translate-all-jobs
translate-all-jobs: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for s in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$s translate-all-parts-jobs; \
	done






.PHONY: print-modelinfo
print-modelinfo:
	@echo ${MODELNAME}
	@echo ${MODELZIP}
	@echo ${MODELINFO}
	@echo "multi-target model: ${MULTI_TARGET_MODEL}"
	@echo "target language label: ${TARGET_LANG_LABEL}"





## fetch the latest model
## ---> TODO: should we fetch from ObjectStorage instead?

${LANGPAIR}/${MODELNAME}/decoder.yml:
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
  PREPROCESS_ARGS = ${SRC} ${TRG} ${LANGPAIR}/${MODELNAME}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${LANGPAIR}/${MODELNAME}/source.spm
endif




${WIKI_DIR}/${SRC}/%.${PART}.gz: | ${WIKI_DIR}/${SRC}
	${GZCAT} ${@:.${PART}.gz=.txt.gz} |\
	split -l ${SPLIT_SIZE} - ${patsubst %${PART}.gz,%,$@}
	gzip -f ${patsubst %${PART}.gz,%,$@}??


${WIKI_DIR}/${SRC}/%.txt.gz: ${WIKI_DIR}/${SRC}
	echo "done!"


${WIKI_DIR}/${SRC}:
	mkdir -p $@
	wget -O $@.tar ${TATOEBA_STORAGE}/${SRC}.tar
	tar -C ${dir $@} -xf $@.tar
	if [ -d ${WIKI_DIR}/data/${SRC} ]; then \
	  mv ${WIKI_DIR}/data/${SRC}/*.txt.gz $@/;\
	  rm -f ${WIKI_DIR}/data/${SRC}/*;\
	  rmdir ${WIKI_DIR}/data/${SRC};\
	  rmdir ${WIKI_DIR}/data;\
	fi
	if [ -e ${WIKI_DIR}/${SRC}/wiki.${SRC}.aa.gz ]; then \
	  for f in `ls ${WIKI_DIR}/${SRC}/*.${SRC}.*`; do \
	    mv 	$$f `echo $$f | sed 's/\.${SRC}\././'`; \
	  done \
	fi
	rm -f $@.tar

${OUTPUT_DIR}/%.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz: ${WIKI_DIR}/${SRC}/%.${PART}.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${GZCAT} $< |\
	grep -v '[<>{}]' |\
	${LANGPAIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${MAX_LENGTH});print;}' |\
	gzip -f > $@
endif



## merge SentencePiece segments in the source text
## (Why? because we filter out some data from the original wiki text, see above)

${WIKI_SRC}: ${WIKI_PRE}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${GZCAT} $< |\
	sed 's/ //g;s/▁/ /g' | \
	sed 's/^ *//;s/ *$$//' |\
	sed 's/^>>[a-z]*<< //' |\
	gzip -c > $@
endif




## overwrite the file with the latest translations
## --> this allows multiple translation iterations
##     without duplicating the data we want to use in MT training

${WIKI_LATEST_SRC}: ${WIKI_SRC}
	mkdir -p ${dir $@}
	cp $< $@

${WIKI_LATEST_TRG}: ${WIKI_TRG}
	mkdir -p ${dir $@}
	cp $< $@



## translate

%.${LANGPAIR}.${TRG}.gz: %.${LANGPAIR}.${SRC}.spm.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${LOADMODS} && cd ${LANGPAIR}/${MODELNAME} && ${MARIAN_DECODER} \
		-i ${PWD}/$< \
		-c decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
#ifneq (${LANGPAIR},)
#ifneq (${MODELNAME},)
#	rm -fr ${LANGPAIR}/${MODELNAME}
#endif
#endif
endif



check-length:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  echo "check $$d"; \
	  for S in `ls $$d/*.$$s.gz`; do \
	    T=`echo $$S | sed 's/.$$s.gz/.$$t.gz/'`; \
	    echo "$$S -- $$T"; \
	    ${GZCAT} $$S | wc -l; \
	    ${GZCAT} $$T | wc -l; \
	    if [ `${GZCAT} $$S | wc -l` != `${GZCAT} $$T | wc -l` ]; then \
	      echo "$$S != $$T"; \
	    fi \
	  done \
	done


