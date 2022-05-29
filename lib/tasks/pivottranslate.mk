# -*-makefile-*-
#
# pivot-based translation
#


PT_TRANSLATE_LANGPAIR = ${PIVOT}-${SRC}
PT_ORIGINAL_LANGPAIR  = ${PIVOT}-${TRG}
PT_NEW_LANGPAIR       = ${SRC}-${TRG}

PT_SORTLANGS          = $(sort ${PIVOT} ${TRG})
PT_SORTED_LANGPAIR    = ${firstword ${PT_SORTLANGS}}-${lastword ${PT_SORTLANGS}}


## take source language part of the training data as input

PT_INPUT_FILES = $(filter-out ${DATADIR}/${PRE}/${DEVSET}.% ${DATADIR}/${PRE}/${TESTSET}.%,\
		$(wildcard ${DATADIR}/${PRE}/*.${PT_SORTED_LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${PIVOT}.gz))
PT_INPUT_FILE  = $(firstword ${PT_INPUT_FILES})
PT_INPUT_NAME  = $(basename $(notdir ${PT_INPUT_FILE:.gz=}))
PT_TARGET_FILE = $(PT_INPUT_FILE:.${PIVOT}.gz=.${TRG}.gz)
PT_OUTPUT_DIR  = ${PIVOTTRANS_HOME}/${PT_NEW_LANGPAIR}



#---------------------------------------------------------------
# main recipes for preparing and translating data
#---------------------------------------------------------------

## extra parameters to call translation recipes

PT_MAKE_PARAMS = SRC=${PIVOT} TRG=${SRC} INPUT_FILE=${PT_INPUT_FILE} OUTPUT_DIR=${PT_OUTPUT_DIR}


.PHONY: pt-all-jobs
pt-all-jobs:
	${MAKE} pt-prepare
	${MAKE} forward-translate-all-jobs

.PHONY: pt-prepare
pt-prepare:
	${MAKE} SRC=${PIVOT} rawdata
	${MAKE} ${PT_MAKE_PARAMS} opusmt-model




pt-info:
	@echo "output dir: ${PT_OUTPUT_DIR}"
	@echo "input file: ${PT_INPUT_FILE}"
	@echo "input file: ${PT_INPUT_FILES}"


# pivot-translate
# pivot-translate-all-parts ......... translate all parts of the input data
# pivot-translate-all-parts-jobs .... create jobs for translating all parts

.PHONY: pivot-translate pivot-translate-all-parts pivot-translate-all-parts-jobs
pivot-translate pivot-translate-all-parts pivot-translate-all-parts-jobs:
	${MAKE} SRC=${PIVOT} rawdata
	${MAKE} ${PT_MAKE_PARAMS} $(patsubst pivot-%,opusmt-%,$@)
	${MAKE} pivot-target-files


## the original target language file needs to be split in the same way as the source file
PT_OUTPUT_LATEST_TRG = ${PT_OUTPUT_DIR}/latest/${PT_INPUT_NAME}.aa.${PIVOT}-${SRC}.${TRG}.gz

.PHONY: pivot-target-files pt-target-files
pivot-target-files pt-target-files: ${PT_OUTPUT_LATEST_TRG}
${PT_OUTPUT_LATEST_TRG}: ${PT_TARGET_FILE}
	${GZCAT} $< | split -l ${OPUSMT_SPLIT_SIZE} - ${patsubst %aa.${PIVOT}-${SRC}.${TRG}.gz,%,$@}
	find $(dir $@) -name '${PT_INPUT_NAME}.[a-z][a-z]' -exec mv {} {}.${PIVOT}-${SRC}.${TRG} \;
	${GZIP} -f ${PT_OUTPUT_DIR}/latest/${PT_INPUT_NAME}.??.${PIVOT}-${SRC}.${TRG}



# pivot-translate-all ............... translate all parts of all sources
# pivot-translate-all-jobs .......... create jobs for all parts and all sources

.PHONY: pivot-translate-all pivot-translate-all-jobs
pivot-translate-all pivot-translate-all-jobs:
	for s in ${PT_INPUT_FILES}; do \
	  ${MAKE} PT_INPUT_FILE=$$s $(subst -all,-all-parts,$@); \
	done


# pivot-translate-all-sources ....... translate all sources but only one part
# pivot-translate-all-sources-job ... create individual jobs to translate one part for each source

.PHONY: pivot-translate-all-sources pivot-translate-all-sources-job
pivot-translate-all-sources pivot-translate-all-sources-job:
	for s in ${PT_INPUT_FILES}; do \
	  ${MAKE} PT_INPUT_FILE=$$s $(subst -all-sources,,$@); \
	done



## forward recipes to translate-recipes (see translate.mk)

PT_GENERIC_RECIPES = 	pt-check-length pt-check-latest \
			pt-check-translated pt-remove-incomplete \
			pt-remove-incomplete-translated pt-remove-incomplete-latest

PHONY: ${PT_GENERIC_RECIPES}
${PT_GENERIC_RECIPES}:
	${MAKE} ${PT_MAKE_PARAMS} $(subst pt-,opusmt-,$@)

pt-remove-%-all pt-check-%-all:
	${MAKE} ${PT_MAKE_PARAMS} $(subst pt-,opusmt-,$@)


#---------------------------------------------------------------
## recipes to score translations (see score_translations.mk)
#---------------------------------------------------------------

# pt-score-translations ........... score translations with reverse NMT models
# pt-sort-scored-translations ..... sort translations by reverse translation score
# pt-extract-best-translations .... remove translation pairs with lowest score (default 5%)

PHONY: pt-score-translations pt-sort-scored-translations pt-extract-best-translations
pt-score-translations pt-sort-scored-translations pt-extract-best-translations:
	${MAKE} OUTPUT_DIR=${PT_OUTPUT_DIR}/latest $(subst pt-,,$@)



#---------------------------------------------------------------
# fetch and release data (requires to be connected to allas@CSC)
#---------------------------------------------------------------

## container for storing forward translations
PT_CONTAINER        := Tatoeba-MT-pt
PT_WORK_CONTAINER   := project-Tatoeba-MT-pt
TATOEBA_RELEASED_PT := https://object.pouta.csc.fi/${PT_CONTAINER}/released-data.txt
RELEASED_PT         := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED_PT} | grep '^${LANGPAIR}/'}

pt-fetch:
	mkdir -p ${PIVOTTRANS_HOME}
	( cd ${PIVOTTRANS_HOME}; \
	  for d in ${RELEASED_PT}; do \
	    echo "fetch $$d"; \
	    mkdir -p `dirname $$d`; \
	    ${WGET} -qq -O $$d https://object.pouta.csc.fi/${PT_CONTAINER}/$$d; \
	  done )

pt-release-all: pt-upload-all
	${MAKE} ${PIVOTTRANS_HOME}/released-data.txt ${PIVOTTRANS_HOME}/released-data-size.txt

.PHONY: pt-upload pt-release
pt-release pt-upload: ${PT_LATEST_README}
	cd ${PIVOTTRANS_HOME} && swift upload ${PT_CONTAINER} --changed --skip-identical ${LANGPAIR}/latest
	${MAKE} ${PIVOTTRANS_HOME}/released-data.txt
	swift post ${PT_CONTAINER} --read-acl ".r:*"

.PHONY: pt-upload-all
pt-upload-all:
	( cd ${PIVOTTRANS_HOME}; \
	  for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	    s=`echo $$d | cut -f1 -d'-'`; \
	    t=`echo $$d | cut -f2 -d'-'`; \
	    ${MAKE} SRC=$$s TRG=$$t ${@:-all=}; \
	  done )

${PIVOTTRANS_HOME}/released-data.txt: ${PIVOTTRANS_HOME}
	swift list ${PT_CONTAINER} | grep -v README.md | grep -v '.txt' > $@
	cd ${PIVOTTRANS_HOME} && swift upload ${PT_CONTAINER} $(notdir $@)


${PIVOTTRANS_HOME}/released-data-size.txt: ${PIVOTTRANS_HOME}
	swift download ${PT_CONTAINER} released-data-size.txt
	mv $@ $@.${TODAY}
	head -n-1 $@.${TODAY} | grep [a-z] > $@.old
	${MAKE} pt-check-latest-all        > $@.new
	cat $@.old $@.new | grep '^[1-9]' | sort -k2,2  > $@
	cat $@ | awk '{ sum += $$1 } END { print sum }' > $@.tmp
	cat $@.tmp >> $@
	cd ${PIVOTTRANS_HOME} && swift upload ${PT_CONTAINER} $(notdir $@)
	cd ${PIVOTTRANS_HOME} && swift upload ${PT_CONTAINER} $(notdir $@).${TODAY}
	rm -f $@.tmp $@.${TODAY} $@.new $@.old


