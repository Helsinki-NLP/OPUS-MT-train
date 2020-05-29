#
# pivoting - translate training data via pivot models
#
#
# TODO: exclude certain corpora like GNOME Ubuntu, (bible-uedin) ...
#       ---> this will basically be the same for all languages
#

PWD := $(shell pwd)

## language (SRC->TRG) pair we need
SRC = fi
TRG = se

## pivot language
PIVOT  = nb

## always include those data sets even if they have the same target language pair
INCLUDE = OpenSubtitles

## specify additional data sets to exclude
# EXCLUDE = bible-uedin DGT GlobalVoices GNOME infopankki KDE4 KDEdoc Tanzil Ubuntu

## langpair (sorted lang id's) of the original data
## to be translated from PIVOT to SRC
ORIGINAL_LANGPAIR = ${firstword ${sort ${PIVOT} ${TRG}}}-${lastword ${sort ${PIVOT} ${TRG}}}
PIVOT_LANGPAIR    = ${PIVOT}-${SRC}

include ../lib/env.mk
include ../lib/config.mk
include ../lib/slurm.mk

include lib/models.mk

## max number of sentences to translate
## TODO: should also support splitting and translating subsets in parallel
MAX_PIVOT_SENTENCES ?= 1000000


ORIGINAL_DATADIR     ?= ${PWD}/../work/data

EXCLUDE_DATASETS    = ${sort \
			${filter-out \
			 ${patsubst %,${ORIGINAL_DATADIR}/${PRE}/%.${ORIGINAL_LANGPAIR}.clean.${TRG}.gz,${INCLUDE}},\
			  ${patsubst %.${LANGPAIR}.clean.${TRG}.gz,%.${ORIGINAL_LANGPAIR}.clean.${TRG}.gz,\
			   ${wildcard ${ORIGINAL_DATADIR}/${PRE}/*.${LANGPAIR}.clean.${TRG}.gz}}} \
			${patsubst %,${ORIGINAL_DATADIR}/${PRE}/%.${ORIGINAL_LANGPAIR}.clean.${TRG}.gz,${EXCLUDE}}}

ORIGINAL_DATASETS_TRG = ${filter-out ${EXCLUDE_DATASETS},\
			${wildcard ${ORIGINAL_DATADIR}/${PRE}/*.${ORIGINAL_LANGPAIR}.clean.${TRG}.gz}}
ORIGINAL_DATASETS_SRC = ${patsubst %.${TRG}.gz,%.${PIVOT}.gz,${ORIGINAL_DATASETS_TRG}}

ORIGINAL_DATASRC     ?= ${firstword ${ORIGINAL_DATASETS_SRC}}
ORIGINAL_DATATRG     ?= ${firstword ${ORIGINAL_DATASETS_TRG}}

DATASET_NAMES = $(patsubst %.clean,%,$(patsubst %.${PIVOT}.gz,%,${notdir ${ORIGINAL_DATASETS_SRC}}))
DATASET_NAME  = $(patsubst %.clean,%,$(patsubst %.${PIVOT}.gz,%,${notdir ${ORIGINAL_DATASRC}}))

## output dir
OUTPUT_DIR       = ${SRC}-${TRG}


#--------------------------------------------------------------------------
# find a model to translate the original data
#--------------------------------------------------------------------------
## if there is no model for the pivot translation pair
## ---> look for a multilingual model that includes both languages
## TODO: make sure that PIVOT and SRC do not match other lang-IDs!!!
## TODO: what do we do if there is more than one multilingual model? 
##       --> need to define preference mechanism
## TODO: this should better come from some API or at least ObjectStorage
##       (not local disk)
ifeq ($(wildcard ../models/${PIVOT_LANGPAIR}),)
ifeq ($(wildcard ../models/*${PIVOT}*-${SRC}),)
ifeq ($(wildcard ../models/${PIVOT}-*${SRC}*),)
  MODELHOME = $(firstword $(wildcard ../models/*${PIVOT}*-*${SRC}*))
else
  MODELHOME = $(firstword $(wildcard ../models/${PIVOT}-*${SRC}*))
endif
else
  MODELHOME = $(firstword $(wildcard ../models/*${PIVOT}*-${SRC}))
endif
else
  MODELHOME = ../models/${PIVOT_LANGPAIR}
endif


## select the latest NMT model (assume this is the best one)
## standard sort is different from UTF8-based sort
## --> prefer models with augmented data sets (separated by +)
##     we need the UTF8 sort order
## --> use bash sort and UTF8 locale
# MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
MODELZIP  = ${lastword ${shell ls ${MODELHOME}/*-20*.zip | LANG=en_US.UTF-8 sort}}
MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}


## no released model found?
## ---> find a local one in the work directory
ifeq (${MODELNAME},)
ifeq ($(wildcard ../work/models/${PIVOT_LANGPAIR}),)
ifeq ($(wildcard ../work/models/*${PIVOT}*-${SRC}),)
ifeq ($(wildcard ../work/models/${PIVOT}-*${SRC}*),)
  MODELHOME = $(firstword $(wildcard ../work/models/*${PIVOT}*-*${SRC}*))
else
  MODELHOME = $(firstword $(wildcard ../work/models/${PIVOT}-*${SRC}*))
endif
else
  MODELHOME = $(firstword $(wildcard ../work/models/*${PIVOT}*-${SRC}))
endif
else
  MODELHOME = ../work/models/${PIVOT_LANGPAIR}
endif
  # MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
  MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/opus-20*.zip}}}
  MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
endif

## set to 1 if the model for backtranslation is a multi-target model
## --> need to use pre-processing script differently
ifeq ($(words $(subst +, ,$(lastword $(subst -, ,$(notdir ${MODELHOME}))))),1)
  MULTI_TARGET_MODEL = 0
else
  MULTI_TARGET_MODEL = 1
endif

## decoder config
DECODER = ${OUTPUT_DIR}/${MODELNAME}/decoder.yml



ifdef LOCAL_SCRATCH
  TMPDIR = ${LOCAL_SCRATCH}
endif

#--------------------------------------------------------------------------
# target files to be created
#--------------------------------------------------------------------------

## just one data set
TRANSLATED_SRC        = ${OUTPUT_DIR}/${DATASET_NAME}.${MODELNAME}.${LANGPAIR}.${PIVOT}.gz
TRANSLATED_PRE        = ${OUTPUT_DIR}/${DATASET_NAME}.${MODELNAME}.${LANGPAIR}.${PIVOT}.spm.gz
TRANSLATED_TRG        = ${OUTPUT_DIR}/${DATASET_NAME}.${MODELNAME}.${LANGPAIR}.${SRC}.gz
TRANSLATED_LATEST_SRC = ${OUTPUT_DIR}/latest/${DATASET_NAME}.${LANGPAIR}.${SRC}.gz
TRANSLATED_LATEST_TRG = ${OUTPUT_DIR}/latest/${DATASET_NAME}.${LANGPAIR}.${TRG}.gz

## all data sets
ALL_TRANSLATED_SRC        = $(patsubst %,${OUTPUT_DIR}/%.${MODELNAME}.${LANGPAIR}.${PIVOT}.gz,${DATASET_NAMES})
ALL_TRANSLATED_TRG        = $(patsubst %,${OUTPUT_DIR}/%.${MODELNAME}.${LANGPAIR}.${SRC}.gz,${DATASET_NAMES})
ALL_TRANSLATED_LATEST_SRC = $(patsubst %,${OUTPUT_DIR}/latest/%.${LANGPAIR}.${SRC}.gz,${DATASET_NAMES})
ALL_TRANSLATED_LATEST_TRG = $(patsubst %,${OUTPUT_DIR}/latest/%.${LANGPAIR}.${TRG}.gz,${DATASET_NAMES})



# .INTERMEDIATE: ${TRANSLATED_PRE}
.PHONY: all prepare translate


all: ${DECODER} ${ALL_TRANSLATED_LATEST_SRC} ${ALL_TRANSLATED_LATEST_TRG}

prepare: ${TRANSLATED_PRE}

translate: ${TRANSLATED_TRG}





## aux function to print the selected modelname and data sets
.PHONY: print-modelname
print-modelname:
	@echo ${MODELNAME}
	@echo ${MODELZIP}
	@echo "${sort ${wildcard ${MODELHOME}/*-20*.zip}}"

.PHONY: print-data
print-data:
#	@echo ${ORIGINAL_DATASRC}
	@echo ${DATASET_NAME}
#	@echo ${TRANSLATED_SRC}
#	@echo ${TRANSLATED_TRG}
#	@echo ${TRANSLATED_LATEST_SRC}
#	@echo ${TRANSLATED_LATEST_TRG}

.PHONY: print-all-data
print-all-data:
#	@echo "${ORIGINAL_DATASETS_TRG}"
	@echo "${DATASET_NAMES}"
#	@echo "${ALL_TRANSLATED_SRC}"
#	@echo "${ALL_TRANSLATED_TRG}"
#	@echo "${ALL_TRANSLATED_LATEST_SRC}"
#	@echo "${ALL_TRANSLATED_LATEST_TRG}"

print-excludes:
	@echo ${patsubst %,%.${ORIGINAL_LANGPAIR}.clean.${TRG}.gz,${INCLUDE}}
	@echo "${EXCLUDE_PATTERN}"
	@echo "${EXCLUDE_DATASETS}"


## fetch the latest model
## ---> TODO: should we fetch from ObjectStorage instead?

${OUTPUT_DIR}/${MODELNAME}/decoder.yml:
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	cp ${MODELZIP} ${dir $@}
	cd ${dir $@} && unzip *.zip
endif


#--------------------------------------------------------------------------
## pre-process data
#--------------------------------------------------------------------------

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${PIVOT} ${SRC} ${OUTPUT_DIR}/${MODELNAME}/source.spm
else
  PREPROCESS_ARGS = ${PIVOT} ${OUTPUT_DIR}/${MODELNAME}/source.spm
endif

${TRANSLATED_PRE}: ${ORIGINAL_DATASRC}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${DECODER}
	zcat $< |\
	head -${MAX_PIVOT_SENTENCES} |\
	${OUTPUT_DIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	gzip -c > $@
endif


# the same in an implict rule (makes it possible to run things in parallel)
${OUTPUT_DIR}/%.${MODELNAME}.${LANGPAIR}.${PIVOT}.spm.gz: ${ORIGINAL_DATADIR}/${PRE}/%.clean.${PIVOT}.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${DECODER}
	zcat $< |\
	${OUTPUT_DIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	gzip -c > $@
endif





## overwrite the file with the latest translations
## --> this allows multiple translation iterations
##     without duplicating the data we want to use in MT training

${OUTPUT_DIR}/latest/%.${LANGPAIR}.${SRC}.gz: ${OUTPUT_DIR}/%.${MODELNAME}.${LANGPAIR}.${SRC}.gz
	mkdir -p ${dir $@}
	cp $< $@

${OUTPUT_DIR}/latest/%.${LANGPAIR}.${TRG}.gz: 	${ORIGINAL_DATADIR}/${PRE}/%.clean.${TRG}.gz \
						${OUTPUT_DIR}/latest/%.${LANGPAIR}.${SRC}.gz
	mkdir -p ${dir $@}
	cp $< $@

${TRANSLATED_LATEST_TRG}: ${ORIGINAL_DATATRG} ${TRANSLATED_LATEST_SRC}
	mkdir -p ${dir $@}
	cp $< $@




## translate

%.${LANGPAIR}.${SRC}.gz: %.${LANGPAIR}.${PIVOT}.spm.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${OUTPUT_DIR}/${MODELNAME}/decoder.yml
	${LOADMODS} && cd ${OUTPUT_DIR}/${MODELNAME} && ${MARIAN}/marian-decoder \
		-i ${PWD}/$< \
		-c decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
endif







check-length:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  echo "check $$d"; \
	  for S in `ls $$d/*.$$s.gz`; do \
	    T=`echo $$S | sed 's/.$$s.gz/.$$t.gz/'`; \
	    echo "$$S -- $$T"; \
	    zcat $$S | wc -l; \
	    zcat $$T | wc -l; \
	    if [ `zcat $$S | wc -l` != `zcat $$T | wc -l` ]; then \
	      echo "$$S != $$T"; \
	    fi \
	  done \
	done

