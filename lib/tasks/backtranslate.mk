# -*-makefile-*-
#
# back-translate monolingual data
#


## storage for wikipedia data
TATOEBA_RELEASE       = v2020-07-28
TATOEBA_STORAGE       = https://object.pouta.csc.fi/Tatoeba-Challenge-${TATOEBA_RELEASE}
# TATOEBA_WIKI_STORAGE  = https://object.pouta.csc.fi/Tatoeba-Challenge-WikiShuffled


## container for storing backtranslations
BT_CONTAINER          = Tatoeba-MT-bt
BT_WORK_CONTAINER     = project-Tatoeba-MT-bt

## various sources are available
## can be general wikipedia, wikinews, wikibooks, ...
BT_MONO_SOURCE ?= wikipedia



BT_MONO_DATADIR = ${MONO_DATADIR}
BT_WORKHOME     = ${BACKTRANS_HOME}

BT_LANGID       = ${SRC}
BT_PART         = aa
BT_OUTPUT_DIR   = ${BT_WORKHOME}/${LANGPAIR}
BT_MONO_TXT     = ${BT_MONO_DATADIR}/${BT_LANGID}/${BT_MONO_SOURCE}.txt.gz


# BT_MONO_SOURCES = wiki wikibooks wikinews wikiquote wikisource wiktionary
BT_MONO_SOURCES = ${sort $(patsubst %.txt.gz,%,$(notdir ${wildcard ${BT_MONO_DATADIR}/${BT_LANGID}/*.txt.gz}))




## don't delete translated text if the process crashes
# .PRECIOUS: ${BT_MONO_TRG} ${BT_ALLPARTS_TRG} ${BT_ALL_TRG}



bt-all-jobs: download
	${MAKE} bt-prepare-all
	${MAKE} back-translate-all-jobs

# all2eng:
# 	for w in ${filter-out eng,${RELEASED_WIKIS}}; do \
# 	  make EMAIL= HPC_CORES=128 HPC_MEM=160g HPC_TIME=24:00 SRC=$$w TRG=eng bt-all-jobs; \
# 	done


## do only the ones that we do not have already!

bt-new2trg:
	for s in ${TATOEBA_TRANSLATABLE_WIKILANGS}; do \
	  if [ ! -d $$s-eng ]; then \
	    ${MAKE} EMAIL= HPC_CORES=128 HPC_MEM=160g HPC_TIME=24:00 SRC=$$s TRG=${TRG} bt-all-jobs; \
	  fi \
	done

bt-all2eng:
	${MAKE} SRC=fin TRG=eng bt-all2trg

bt-all2trg:
	for s in ${TATOEBA_TRANSLATABLE_WIKILANGS}; do \
	  ${MAKE} EMAIL= HPC_CORES=128 HPC_MEM=160g HPC_TIME=24:00 SRC=$$s TRG=${TRG} bt-all-jobs; \
	done


## translate English to all reliable target languages
bt-eng2all:
	${MAKE} SRC=eng TRG=fin bt-src2all


## translate current source language to all reliable target languages
bt-src2all:
	for t in ${TATOEBA_RELIABLE_TRG}; do \
	  if [ ! -e ${SRC}-$$t/latest/${BT_MONO_SOURCE}.${BT_PART}.${SRC}-$$t.$$t.gz ]; then \
	    ${MAKE} EMAIL= HPC_CORES=128 HPC_MEM=160g HPC_TIME=24:00 SRC=${SRC} TRG=$$t bt-prepare; \
	    ${MAKE} EMAIL= HPC_CORES=128 HPC_MEM=160g HPC_TIME=24:00 SRC=${SRC} TRG=$$t back-translate.${SUBMIT_PREFIX}; \
	  fi \
	done




RELEASED_BT_ALL := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_BT}}
RELEASED_BT := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_BT} | grep '^${BT_OUTPUT_DIR}/'}

fetch-bt:
	( cd ${BT_WORKHOME}; \
	  for d in ${RELEASED_BT}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${BT_CONTAINER}/$$d; \
	  done )

fetch-all-bt:
	( cd ${BT_WORKHOME}; \
	  for d in ${RELEASED_BT_ALL}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${BT_CONTAINER}/$$d; \
	  done )


#---------------------------------------------------------------
# release data 
#---------------------------------------------------------------

bt-release-all: bt-upload-all
	${MAKE} ${BT_WORKHOME}/released-data.txt ${BT_WORKHOME}/released-data-size.txt

.PHONY: bt-upload bt-release
bt-release bt-upload: ${BT_LATEST_README}
	cd ${BT_WORKHOME} && swift upload ${BT_CONTAINER} --changed --skip-identical ${LANGPAIR}/latest
	${MAKE} ${BT_WORKHOME}/released-data.txt
	swift post ${BT_CONTAINER} --read-acl ".r:*"

.PHONY: bt-upload-all
bt-upload-all:
	( cd ${BT_WORKHOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    make SRC=$$s TRG=$$t ${@:-all=}; \
	  done )

${BT_WORKHOME}/released-data.txt: ${BT_WORKHOME}
	swift list ${BT_CONTAINER} | grep -v README.md | grep -v '.txt' > $@
	cd ${BT_WORKHOME} && swift upload ${BT_CONTAINER} $(notdir $@)

TODAY := $(shell date +%F)

${BT_WORKHOME}/released-data-size.txt: ${BT_WORKHOME}
	swift download ${BT_CONTAINER} released-data-size.txt
	mv $@ $@.${TODAY}
	head -n-1 $@.${TODAY} | grep [a-z] > $@.old
	${MAKE} bt-check-latest-all        > $@.new
	cat $@.old $@.new | grep '^[1-9]' | sort -k2,2  > $@
	cat $@ | awk '{ sum += $$1 } END { print sum }' > $@.tmp
	cat $@.tmp >> $@
	cd ${BT_WORKHOME} && swift upload ${BT_CONTAINER} $(notdir $@)
	cd ${BT_WORKHOME} && swift upload ${BT_CONTAINER} $(notdir $@).${TODAY}
	rm -f $@.tmp $@.${TODAY} $@.new $@.old

# download released data

.PHONY: bt-download
bt-download: ${BT_MONO_DATADIR}/${SRC}


#---------------------------------------------------------------
# store / fetch translations
# (this is for storing work files and not for releasing data!)
#---------------------------------------------------------------

.PHONY: bt-store
bt-store:
	cd ${BT_WORKHOME} && a-put -b ${BT_WORK_CONTAINER} --nc --follow-links --override ${LANGPAIR}

.PHONY: bt-store-all
bt-store-all:
	( cd ${BT_WORKHOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    make SRC=$$s TRG=$$t ${@:-all=}; \
	  done )

.PHONY: bt-retrieve bt-fetch
bt-retrieve bt-fetch:
	cd ${BT_WORKHOME} && a-get ${WORK_CONTAINER}/${LANGPAIR}.tar






.PHONY: bt-prepare
bt-prepare: ${BT_MONO_TXT}
	${MAKE} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-model

.PHONY: bt-prepare-all
bt-prepare-all: ${BT_ALL_TXT}
	${MAKE} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-model

.PHONY: back-translate
back-translate:
	${MAKE} CORPUS_NAME=${BT_MONO_SOURCE} CORPUS_SRCRAW=${BT_MONO_TXT} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-translate

## translate all parts
.PHONY: back-translate-all-parts
back-translate-all-parts:
	${MAKE} CORPUS_NAME=${BT_MONO_SOURCE} CORPUS_SRCRAW=${BT_MONO_TXT} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-translate-all-parts


## translate all wikis and all parts
.PHONY: back-translate-all
back-translate-all:
	for s in ${BT_MONO_SOURCES}; do \
	  ${MAKE} CORPUS_NAME=$$s CORPUS_SRCRAW=${BT_MONO_TXT} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-translate-all-parts; \
	done


## create all source language files
.PHONY: bt-latest-all-source-parts
bt-latest-all-source-parts:
	${MAKE} CORPUS_NAME=${BT_MONO_SOURCE} CORPUS_SRCRAW=${BT_MONO_TXT} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-all-source-parts


.PHONY: bt-latest-all-sources
bt-latest-all-sources:
	for s in ${BT_MONO_SOURCES}; do \
	  ${MAKE} CORPUS_NAME=$$s CORPUS_SRCRAW=${BT_MONO_TXT} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR} opusmt-all-source-parts; \
	done





## create jobs for translating all parts
## (only start the job if the file does not exist yet)
.PHONY: back-translate-all-parts-jobs
back-translate-all-parts-jobs:
	for p in ${BT_PARTS}; do \
	  if [ ! -e ${BT_OUTPUT_DIR}/${BT_MONO_SOURCE}.$${p}_${MODELNAME}.${LANGPAIR}.${TRG}.gz ]; then \
	    rm -f back-translate.${SUBMIT_PREFIX}; \
	    ${MAKE} BT_PART=$$p back-translate.${SUBMIT_PREFIX}; \
	  fi \
	done

## create jobs for translating all parts of all wikis
.PHONY: back-translate-all-jobs
back-translate-all-jobs:
	for s in ${BT_MONO_SOURCES}; do \
	  ${MAKE} BT_MONO_SOURCE=$$s back-translate-all-parts-jobs; \
	done








## NEW: get proper released WIKI data and extract the languages
## --> multiple languages can be included in one release (like nno in nor)
## --> shuffle the data as well


# de-duplicate and shuffle
${BT_MONO_DATADIR}/${SRC}/${BT_MONO_SOURCE}.txt.gz:
	mkdir -p ${dir $@}
	${WGET} -O $@.tar ${TATOEBA_STORAGE}/${shell iso639 -m -n ${SRC}}.tar
	tar -C ${dir $@} -xf $@.tar
	rm -f $@.tar
	for f in `find ${dir $@} -name '*.id.gz'`; do \
	  t=`echo $$f | sed 's/\.id\.gz/.txt.gz/'`; \
	  l=`echo ${SRC} | sed 's/cmn/zho/;s/nob/nor.*/'`; \
	  paste <(${GZIP} -cd $$f) <(${GZIP} -cd $$t) |\
	  grep "^$$l	" | cut -f2 | grep . | \
	  ${UNIQ} | ${SHUFFLE} | ${GZIP} -c >  ${dir $@}`basename $$t`; \
	done
	for f in `find ${dir $@} -name '*.txt.gz'`; do \
	  if [ ! `${GZIP} -cd $$f | head | wc -l` -gt 0 ]; then \
	    rm -f $$f; \
	  fi \
	done
	rm -fr ${BT_MONO_DATADIR}/${SRC}/data








bt-check-latest:
	@if [ -d ${BT_OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${BT_OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
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

bt-check-translated:
	@for S in `ls ${BT_OUTPUT_DIR}/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	done

bt-check-length:
	@echo "check ${LANGPAIR}"
	@${MAKE} bt-check-translated
	@${MAKE} bt-check-latest


bt-remove-%-all bt-check-%-all:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  make SRC=$$s TRG=$$t ${@:-all=}; \
	done



bt-remove-incomplete:
	${MAKE} bt-remove-incomplete-translated
	${MAKE} bt-remove-incomplete-latest

bt-remove-incomplete-translated:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${BT_OUTPUT_DIR}/incomplete
	@for S in `ls ${BT_OUTPUT_DIR}/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${BT_OUTPUT_DIR}/incomplete/; \
	      mv $$T ${BT_OUTPUT_DIR}/incomplete/; \
	    fi \
	done


bt-remove-incomplete-latest:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${BT_OUTPUT_DIR}/incomplete/latest
	@if [ -d ${BT_OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${BT_OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${BT_OUTPUT_DIR}/incomplete/latest/; \
	      mv $$T ${BT_OUTPUT_DIR}/incomplete/latest/; \
	    fi \
	  done \
	fi

