# -*-makefile-*-
#
# forward-translate data
#


# max sentence length in subword tokens
FT_MAX_LENGTH ?= 200

## take source language part of the training data as input

FT_INPUT_FILES = ${CLEAN_TRAIN_SRC}
FT_INPUT_FILE  = $(firstword ${FT_INPUT_FILES})
FT_OUTPUT_DIR  = ${FORWARDTRANS_HOME}/${LANGPAIR}


#---------------------------------------------------------------
# main recipes for preparing and translating data
#---------------------------------------------------------------

## extra parameters to call translation recipes

FT_MAKE_PARAMS = INPUT_FILE=${FT_INPUT_FILE} OUTPUT_DIR=${FT_OUTPUT_DIR} OPUSMT_MAX_LENGTH=${FT_MAX_LENGTH}


.PHONY: ft-all-jobs
ft-all-jobs:
	${MAKE} ft-prepare-all
	${MAKE} forward-translate-all-jobs

.PHONY: ft-prepare
ft-prepare: ${FT_INPUT_FILE}
	${MAKE} ${FT_MAKE_PARAMS} opusmt-prepare

.PHONY: ft-prepare-all
ft-prepare-all: ${FT_INPUT_FILES}
	for s in $^; do \
	  ${MAKE} FT_INPUT_FILE=$$s ${FT_MAKE_PARAMS} opusmt-prepare; \
	done


# forward-translate ................... translate one part of input data
# forward-translate-all-parts ......... translate all parts of the input data
# forward-translate-all-parts-jobs .... create jobs for translating all parts

.PHONY: forward-translate forward-translate-all-parts forward-translate-all-parts-jobs
forward-translate forward-translate-all-parts forward-translate-all-parts-jobs:
	${MAKE} ${FT_MAKE_PARAMS} $(patsubst forward-%,opusmt-%,$@)


# forward-translate-all ............... translate all parts of all sources
# forward-translate-all-jobs .......... create jobs for all parts and all sources

.PHONY: forward-translate-all forward-translate-all-jobs
forward-translate-all forward-translate-all-jobs:
	for s in ${FT_INPUT_FILES}; do \
	  ${MAKE} FT_INPUT_FILE=$$s $(subst -all,-all-parts,$@); \
	done


# forward-translate-all-sources ....... translate all sources but only one part
# forward-translate-all-sources-job ... create individual jobs to translate one part for each source

.PHONY: forward-translate-all-sources forward-translate-all-sources-job
forward-translate-all-sources forward-translate-all-sources-job:
	for s in ${FT_INPUT_FILES}; do \
	  ${MAKE} FT_INPUT_FILE=$$s $(subst -all-sources,,$@); \
	done



## forward recipes to translate-recipes (see translate.mk)

FT_GENERIC_RECIPES = 	ft-check-length ft-check-latest \
			ft-check-translated ft-remove-incomplete \
			ft-remove-incomplete-translated ft-remove-incomplete-latest \
			ft-scores-check-latest ft-scores-remove-incomplete-latest

PHONY: ${FT_GENERIC_RECIPES}
${FT_GENERIC_RECIPES}:
	${MAKE} ${FT_MAKE_PARAMS} $(subst ft-,opusmt-,$@)

ft-remove-%-all ft-check-%-all:
	${MAKE} ${FT_MAKE_PARAMS} $(subst ft-,opusmt-,$@)


#---------------------------------------------------------------
## recipes to score translations (see score_translations.mk)
#---------------------------------------------------------------

# ft-score-translations ........... score translations with reverse NMT models
# ft-sort-scored-translations ..... sort translations by reverse translation score
# ft-extract-best-translations .... remove translation pairs with lowest score (default 5%)

PHONY: ft-score-translations ft-sort-scored-translations ft-extract-best-translations
ft-score-translations ft-sort-scored-translations ft-extract-best-translations:
	${MAKE} OUTPUT_DIR=${FT_OUTPUT_DIR}/latest $(subst ft-,,$@)



#---------------------------------------------------------------
# fetch and release data (requires to be connected to allas@CSC)
#---------------------------------------------------------------

## container for storing forward translations
FT_CONTAINER        := Tatoeba-MT-ft
FT_WORK_CONTAINER   := project-Tatoeba-MT-ft
TATOEBA_RELEASED_FT := https://object.pouta.csc.fi/${FT_CONTAINER}/released-data.txt
RELEASED_FT         := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_FT} | grep '^${LANGPAIR}/'}

ft-fetch:
	mkdir -p ${FORWARDTRANS_HOME}
	( cd ${FORWARDTRANS_HOME}; \
	  for d in ${RELEASED_FT}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${FT_CONTAINER}/$$d; \
	  done )

ft-release-all: ft-upload-all
	${MAKE} ${FORWARDTRANS_HOME}/released-data.txt ${FORWARDTRANS_HOME}/released-data-size.txt

.PHONY: ft-upload ft-release
ft-release ft-upload: ${FT_LATEST_README}
	cd ${FORWARDTRANS_HOME} && swift upload ${FT_CONTAINER} --changed --skip-identical ${LANGPAIR}/latest
	${MAKE} ${FORWARDTRANS_HOME}/released-data.txt
	swift post ${FT_CONTAINER} --read-acl ".r:*"

.PHONY: ft-upload-all
ft-upload-all:
	( cd ${FORWARDTRANS_HOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    ${MAKE} SRC=$$s TRG=$$t ${@:-all=}; \
	  done )

${FORWARDTRANS_HOME}/released-data.txt: ${FORWARDTRANS_HOME}
	swift list ${FT_CONTAINER} | grep -v README.md | grep -v '.txt' > $@
	cd ${FORWARDTRANS_HOME} && swift upload ${FT_CONTAINER} $(notdir $@)


${FORWARDTRANS_HOME}/released-data-size.txt: ${FORWARDTRANS_HOME}
	swift download ${FT_CONTAINER} released-data-size.txt
	mv $@ $@.${TODAY}
	head -n-1 $@.${TODAY} | grep [a-z] > $@.old
	${MAKE} ft-check-latest-all        > $@.new
	cat $@.old $@.new | grep '^[1-9]' | sort -k2,2  > $@
	cat $@ | awk '{ sum += $$1 } END { print sum }' > $@.tmp
	cat $@.tmp >> $@
	cd ${FORWARDTRANS_HOME} && swift upload ${FT_CONTAINER} $(notdir $@)
	cd ${FORWARDTRANS_HOME} && swift upload ${FT_CONTAINER} $(notdir $@).${TODAY}
	rm -f $@.tmp $@.${TODAY} $@.new $@.old


