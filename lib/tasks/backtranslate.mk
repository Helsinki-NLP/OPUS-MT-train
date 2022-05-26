# -*-makefile-*-
#
# back-translate monolingual data
#


## container for storing backtranslations
BT_CONTAINER          = Tatoeba-MT-bt
BT_WORK_CONTAINER     = project-Tatoeba-MT-bt

## storage for wikipedia data
TATOEBA_RELEASE     := v2020-07-28
TATOEBA_STORAGE     := https://object.pouta.csc.fi/Tatoeba-Challenge-${TATOEBA_RELEASE}
TATOEBA_RELEASED_BT := https://object.pouta.csc.fi/${BT_CONTAINER}/released-data.txt


## various sources are available
## can be general wikipedia, wikinews, wikibooks, ...
BT_MONO_SOURCE ?= wikipedia


BT_LANGID       = ${SRC}
BT_PART         = aa
BT_OUTPUT_DIR   = ${BACKTRANS_HOME}/${LANGPAIR}
BT_MONO_TXT     = ${MONO_DATADIR}/${BT_LANGID}/${BT_MONO_SOURCE}.txt.gz


# BT_MONO_SOURCES = wiki wikibooks wikinews wikiquote wikisource wiktionary
BT_MONO_SOURCES = $(sort $(patsubst %.txt.gz,%,$(notdir ${wildcard ${MONO_DATADIR}/${BT_LANGID}/*.txt.gz})))




## don't delete translated text if the process crashes
# .PRECIOUS: ${BT_MONO_TRG} ${BT_ALLPARTS_TRG} ${BT_ALL_TRG}



bt-all-jobs: bt-download
	${MAKE} bt-prepare-all
	${MAKE} back-translate-all-jobs


RELEASED_BT_ALL     := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_BT}}
RELEASED_BT         := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_BT} | grep '^${LANGPAIR}/'}

bt-fetch:
	( cd ${BACKTRANS_HOME}; \
	  for d in ${RELEASED_BT}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${BT_CONTAINER}/$$d; \
	  done )

bt-fetch-all:
	( cd ${BACKTRANS_HOME}; \
	  for d in ${RELEASED_BT_ALL}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${BT_CONTAINER}/$$d; \
	  done )


#---------------------------------------------------------------
# release data 
#---------------------------------------------------------------

bt-release-all: bt-upload-all
	${MAKE} ${BACKTRANS_HOME}/released-data.txt ${BACKTRANS_HOME}/released-data-size.txt

.PHONY: bt-upload bt-release
bt-release bt-upload: ${BT_LATEST_README}
	cd ${BACKTRANS_HOME} && swift upload ${BT_CONTAINER} --changed --skip-identical ${LANGPAIR}/latest
	${MAKE} ${BACKTRANS_HOME}/released-data.txt
	swift post ${BT_CONTAINER} --read-acl ".r:*"

.PHONY: bt-upload-all
bt-upload-all:
	( cd ${BACKTRANS_HOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    make SRC=$$s TRG=$$t ${@:-all=}; \
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
bt-download: ${MONO_DATADIR}/${SRC}


#---------------------------------------------------------------
# store / retrieve work files
# (this is for storing work files and not for releasing data!)
#---------------------------------------------------------------

.PHONY: bt-store
bt-store:
	cd ${BACKTRANS_HOME} && a-put -b ${BT_WORK_CONTAINER} --nc --follow-links --override ${LANGPAIR}

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
	cd ${BACKTRANS_HOME} && a-get ${WORK_CONTAINER}/${LANGPAIR}.tar


## extra parameters to call translation recipes

BT_MAKE_PARAMS = CORPUS_NAME=${BT_MONO_SOURCE} CORPUS_SRCRAW=${BT_MONO_TXT} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR}

.PHONY: bt-prepare
bt-prepare: ${BT_MONO_TXT}
	${MAKE} ${BT_MAKE_PARAMS} opusmt-model

.PHONY: bt-prepare-all
bt-prepare-all: ${BT_ALL_TXT}
	${MAKE} ${BT_MAKE_PARAMS} opusmt-model


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
	for s in ${BT_MONO_SOURCES}; do \
	  ${MAKE} BT_MONO_SOURCE=$$s $(subst -all,-all-parts,$@); \
	done


# back-translate-all-sources ....... translate all sources but only one part
# back-translate-all-sources-job ... create individual jobs to translate one part for each source

.PHONY: back-translate-all-sources back-translate-all-sources-job
back-translate-all-sources back-translate-all-sources-job:
	for s in ${BT_MONO_SOURCES}; do \
	  ${MAKE} BT_MONO_SOURCE=$$s $(subst -all-sources,,$@); \
	done




## get WIKI data and extract the languages
## --> multiple languages can be included in one release (like nno in nor)
## --> de-duplicate and shuffle the data as well

${MONO_DATADIR}/${SRC}/${BT_MONO_SOURCE}.txt.gz:
	mkdir -p ${dir $@}
	${WGET} -q -O $@.tar ${TATOEBA_STORAGE}/${shell iso639 -m -n ${SRC}}.tar
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
	rm -fr ${MONO_DATADIR}/${SRC}/data



## forward recipes to translate-recipes

PHONY: bt-check-length bt-check-latest bt-check-translated bt-remove-incomplete bt-remove-incomplete-translated bt-remove-incomplete-latest
bt-check-length bt-check-latest bt-check-translated bt-remove-incomplete bt-remove-incomplete-translated bt-remove-incomplete-latest:
	${MAKE} ${BT_MAKE_PARAMS} $(subst bt-,opusmt-,$@)


bt-remove-%-all bt-check-%-all:
	${MAKE} ${BT_MAKE_PARAMS} $(subst bt-,opusmt-,$@)


# bt-score-translations ........... score translations with reverse NMT models
# bt-sort-scored-translations ..... sort translations by reverse translation score
# bt-extract-best-translations .... remove translation pairs with lowest score (default 5%)

PHONY: bt-score-translations bt-sort-scored-translations bt-extract-best-translations
bt-score-translations bt-sort-scored-translations bt-extract-best-translations:
	${MAKE} OPUSMT_OUTPUT_DIR=${BT_OUTPUT_DIR}/latest $(subst bt-,,$@)
