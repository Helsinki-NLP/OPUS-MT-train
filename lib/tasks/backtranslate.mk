# -*-makefile-*-
#
# back-translate monolingual data
#


# max sentence length in subword tokens
BT_MAX_LENGTH ?= 200

# reverse language pair (translate target language into source language)
BT_LANGPAIR = ${TRG}-${SRC}


## storage for prepared wiki data (default monolingual data)
TATOEBA_RELEASE := v2020-07-28
TATOEBA_STORAGE := https://object.pouta.csc.fi/Tatoeba-Challenge-${TATOEBA_RELEASE}


# input files and names, output directory
# BT_INPUT_NAMES = wikipedia wikibooks wikinews wikiquote wikisource wiktionary

BT_INPUT_NAMES = $(sort $(patsubst %.txt.gz,%,$(notdir ${wildcard ${MONO_DATADIR}/${TRG}/*.txt.gz})))
BT_INPUT_NAME  = wikipedia
BT_INPUT_FILE  = ${MONO_DATADIR}/${TRG}/${BT_INPUT_NAME}.txt.gz
BT_OUTPUT_DIR  = ${BACKTRANS_HOME}/${BT_LANGPAIR}



#---------------------------------------------------------------
# main recipes for preparing and translating data
#---------------------------------------------------------------

## extra parameters to call translation recipes
## NOTE: need to swap source and target language to translate from target to source language

BT_MAKE_PARAMS = SRC=${TRG} TRG=${SRC} INPUT_FILE=${BT_INPUT_FILE} OUTPUT_DIR=${BT_OUTPUT_DIR} OPUSMT_MAX_LENGTH=${BT_MAX_LENGTH}


.PHONY: bt-all-jobs
bt-all-jobs:
	${MAKE} bt-prepare
	${MAKE} back-translate-all-jobs

.PHONY: ftmono-all-jobs
ftmono-all-jobs:
	${MAKE} SRC=${TRG} TRG=${SRC} bt-prepare
	${MAKE} SRC=${TRG} TRG=${SRC} back-translate-all-jobs

.PHONY: bt-prepare
bt-prepare: ${BT_INPUT_FILE}
	${MAKE} ${BT_MAKE_PARAMS} opusmt-prepare


# back-translate
# back-translate-all-parts ......... translate all parts of the input data
# back-translate-all-parts-jobs .... create jobs for translating all parts

.PHONY: back-translate back-translate-all-parts back-translate-all-parts-jobs
back-translate back-translate-all-parts back-translate-all-parts-jobs:
	${MAKE} ${BT_MAKE_PARAMS} $(patsubst back-%,opusmt-%,$@)


# back-translate-all ............... translate all parts of all sources
# back-translate-all-jobs .......... create jobs for all parts and all sources


.PHONY: back-translate-all back-translate-all-jobs
back-translate-all back-translate-all-jobs:
	for s in ${BT_INPUT_NAMES}; do \
	  ${MAKE} BT_INPUT_NAME=$$s $(subst -all,-all-parts,$@); \
	done


# bt-prepare-all-sources ........... preprocess all source files
# back-translate-all-sources ....... translate all sources but only one part
# back-translate-all-sources-job ... create individual jobs to translate one part for each source

.PHONY: bt-prepare-all-sources back-translate-all-sources back-translate-all-sources-job
bt-prepare-all-sources back-translate-all-sources back-translate-all-sources-job:
	for s in ${BT_INPUT_NAMES}; do \
	  ${MAKE} BT_INPUT_NAME=$$s $(subst -all-sources,,$@); \
	done


## get WIKI data and extract the languages
## --> multiple languages can be included in one release (like nno in nor)
## --> de-duplicate and shuffle the data as well

# $(patsubst ${MONO_DATADIR}/%/${BT_INPUT_NAME}.txt.gz,%,$@)

${MONO_DATADIR}/%/${BT_INPUT_NAME}.txt.gz:
	mkdir -p ${dir $@}
	${WGET} -q -O $@.tar ${TATOEBA_STORAGE}/${shell iso639 -m -n $(patsubst ${MONO_DATADIR}/%/${BT_INPUT_NAME}.txt.gz,%,$@)}.tar
	tar -C ${dir $@} -xf $@.tar
	rm -f $@.tar
	for f in `find ${dir $@} -name '*.id.gz'`; do \
	  t=`echo $$f | sed 's/\.id\.gz/.txt.gz/'`; \
	  l=`echo $(patsubst ${MONO_DATADIR}/%/${BT_INPUT_NAME}.txt.gz,%,$@) | sed 's/cmn/zho/;s/nob/nor.*/'`; \
	  paste <(${GZIP} -cd $$f) <(${GZIP} -cd $$t) |\
	  grep "^$$l	" | cut -f2 | grep . | \
	  ${UNIQ} | ${SHUFFLE} | ${GZIP} -c >  ${dir $@}`basename $$t`; \
	done
	for f in `find ${dir $@} -name '*.txt.gz'`; do \
	  if [ ! `${GZIP} -cd $$f | head | wc -l` -gt 0 ]; then \
	    rm -f $$f; \
	  fi \
	done
	rm -fr $(dir $@)data



## forward recipes to translate-recipes (see translate.mk)

BT_GENERIC_RECIPES = 	bt-check-length bt-check-latest \
			bt-check-translated bt-remove-incomplete \
			bt-remove-incomplete-translated bt-remove-incomplete-latest \
			bt-scores-check-latest bt-scores-remove-incomplete-latest


PHONY: ${BT_GENERIC_RECIPES}
${BT_GENERIC_RECIPES}:
	${MAKE} ${BT_MAKE_PARAMS} $(subst bt-,opusmt-,$@)

bt-remove-%-all bt-check-%-all:
	${MAKE} ${BT_MAKE_PARAMS} $(subst bt-,opusmt-,$@)



#---------------------------------------------------------------
## recipes to score translations (see score_translations.mk)
#---------------------------------------------------------------

# bt-score-translations ........... score translations with reverse NMT models
# bt-sort-scored-translations ..... sort translations by reverse translation score
# bt-extract-best-translations .... remove translation pairs with lowest score (default 5%)

PHONY: bt-score-translations bt-sort-scored-translations bt-extract-best-translations
bt-score-translations bt-sort-scored-translations bt-extract-best-translations:
	${MAKE} SRC=${TRG} TRG=${SRC} OUTPUT_DIR=${BT_OUTPUT_DIR}/latest $(subst bt-,,$@)


#---------------------------------------------------------------
# fetch & release data (requires to be connected to allas@CSC)
#---------------------------------------------------------------

## container for storing backtranslations
BT_CONTAINER        := Tatoeba-MT-bt
BT_WORK_CONTAINER   := project-Tatoeba-MT-bt
TATOEBA_RELEASED_BT := https://object.pouta.csc.fi/${BT_CONTAINER}/released-data.txt
RELEASED_BT_ALL     := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_BT}}
RELEASED_BT         := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_BT} | grep '^${BT_LANGPAIR}/'}

bt-fetch:
	mkdir -p ${BACKTRANS_HOME}
	( cd ${BACKTRANS_HOME}; \
	  for d in ${RELEASED_BT}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${BT_CONTAINER}/$$d; \
	  done )

bt-fetch-all:
	mkdir -p ${BACKTRANS_HOME}
	( cd ${BACKTRANS_HOME}; \
	  for d in ${RELEASED_BT_ALL}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${BT_CONTAINER}/$$d; \
	  done )

bt-release-all: bt-upload-all
	${MAKE} ${BACKTRANS_HOME}/released-data.txt ${BACKTRANS_HOME}/released-data-size.txt

.PHONY: bt-upload bt-release
bt-release bt-upload: ${BT_LATEST_README}
	cd ${BACKTRANS_HOME} && swift upload ${BT_CONTAINER} --changed --skip-identical ${BT_LANGPAIR}/latest
	${MAKE} ${BACKTRANS_HOME}/released-data.txt
	swift post ${BT_CONTAINER} --read-acl ".r:*"

.PHONY: bt-upload-all
bt-upload-all:
	( cd ${BACKTRANS_HOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    ${MAKE} SRC=$$s TRG=$$t ${@:-all=}; \
	  done )

${BACKTRANS_HOME}/released-data.txt: ${BACKTRANS_HOME}
	swift list ${BT_CONTAINER} | grep -v README.md | grep -v '.txt' > $@
	cd ${BACKTRANS_HOME} && swift upload ${BT_CONTAINER} $(notdir $@)


${BACKTRANS_HOME}/released-data-size.txt: ${BACKTRANS_HOME}
	swift download ${BT_CONTAINER} released-data-size.txt
	mv $@ $@.${TODAY}
	head -n-1 $@.${TODAY} | grep [a-z] > $@.old
	${MAKE} bt-check-latest-all        > $@.new
	cat $@.old $@.new | grep '^[1-9]' | sort -k2,2  > $@
	cat $@ | awk '{ sum += $$1 } END { print sum }' > $@.tmp
	cat $@.tmp >> $@
	cd ${BACKTRANS_HOME} && swift upload ${BT_CONTAINER} $(notdir $@)
	cd ${BACKTRANS_HOME} && swift upload ${BT_CONTAINER} $(notdir $@).${TODAY}
	rm -f $@.tmp $@.${TODAY} $@.new $@.old

# download released data

.PHONY: bt-download
bt-download: ${MONO_DATADIR}/${TRG}


#---------------------------------------------------------------
# store / retrieve work files (requires allas connection)
# (this is for storing work files and not for releasing data!)
#---------------------------------------------------------------

.PHONY: bt-store
bt-store:
	cd ${BACKTRANS_HOME} && a-put -b ${BT_WORK_CONTAINER} --nc --follow-links --override ${BT_LANGPAIR}

.PHONY: bt-store-all
bt-store-all:
	( cd ${BACKTRANS_HOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    make SRC=$$s TRG=$$t ${@:-all=}; \
	  done )

.PHONY: bt-retrieve
bt-retrieve:
	mkdir -p ${BACKTRANS_HOME}
	cd ${BACKTRANS_HOME} && a-get ${BT_WORK_CONTAINER}/${BT_LANGPAIR}.tar

