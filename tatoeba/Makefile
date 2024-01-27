# -*-makefile-*-
#
# Makefile for running models with data from the Tatoeba Translation Challenge
# https://github.com/Helsinki-NLP/Tatoeba-Challenge
#
#
# TODO:
#   - check that all recipes still work like shown below
#   - remove obsolete stuff and cleanup
#   - add some more diagnostic and cleanup targets
#
#---------------------------------------------------------------------
# train and evaluate a single translation pair, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-prepare
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-train
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-eval
#
#
# start job for a single language pair in one direction or
# in both directions, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-job
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-bidirectional-job
#
#----------------------------------------------------------------------------------
#
# it is also possible to use the following shortcuts:
#
#   make tatoeba-afr2epo-data
#   make tatoeba-afr2epo-train
#   make tatoeba-afr2epo-trainjob
#   make tatoeba-afr2epo-eval
#   make tatoeba-afr2epo-dist
#
# which is also useful for jobs for language groups, example task: "gmw2eng"
#
#   make tateoba-gmw2eng-train .. make data and start training job
#   make tateoba-gmw2eng-eval ... evaluate model with multilingual test data
#   make tateoba-gmw2eng-evalall  evaluate model with all individual language pairs
#   make tateoba-gmw2eng-dist ... create release package
#
# Similar jobs can be started for any supported language group from and to English
# and also as a bidirectional model for all languages in the given language group.
# Replace "gmw2eng" with, for example, "eng2gem" (English to Germanic) or 
# "gmq" (multilingual model for North Germanic languages).
#
# another shortcut for adding a pivot language to multilingual models if necessary:
#
#   make tatoeba-gmw2zle-train-pivotlang
#
# this would add English (= default pivot language) to the set of target languages
# but NOT to the set of source languages because English is part of gmw!
#
#----------------------------------------------------------------------------------
#
# start jobs for all pairs in an entire subset:
#
#   make tatoeba-subset-lowest
#   make tatoeba-subset-lower
#   make tatoeba-subset-medium
#   make MODELTYPE=transformer tatoeba-subset-higher
#   make MODELTYPE=transformer tatoeba-subset-highest
#
# other jobs to run on the entire subset (example = medium):
#
#   make tatoeba-distsubset-medium .... create release files
#   make tatoeba-evalsubset-medium .... eval all models
#
#
# start jobs for multilingual models from one of the subsets
#
#   make tatoeba-multilingual-subset-zero
#   make tatoeba-multilingual-subset-lowest
#   make tatoeba-multilingual-subset-lower
#   make tatoeba-multilingual-subset-medium
#   make tatoeba-multilingual-subset-higher
#   make tatoeba-multilingual-subset-highest
#
# other jobs to run on the entire subset (example = medium):
#
#   make tatoeba-multilingual-distsubset-medium .... create release files
#   make tatoeba-multilingual-evalsubset-medium .... eval all langpairs
#---------------------------------------------------------------------
# jobs for multilingual language group models
#
#   make all-tatoeba-group2eng ...... start train jobs for all language groups to English
#   make all-tatoeba-eng2group ...... start train jobs for English to all language groups
#   make all-tatoeba-langgroup ...... start train jobs for bi-directional models for all language groups
#
#   make all-tatoeba-langgroups ..... make all jobs from above
#
#
#   make all-tatoeba-group2eng-dist . make package for all trained group2eng models
#   make all-tatoeba-eng2group-dist . make package for all trained eng2group models
#   make all-tatoeba-langgroup-dist . make package for all trained langgroup models
#
#
#---------------------------------------------------------------------


SHELL    := bash
PWD      := ${shell pwd}
REPOHOME := ${PWD}/../


## Tatoeba Challenge Data release number
# TATOEBA_VERSION    = v2020-07-28
# TATOEBA_VERSION      = v2021-08-07
TATOEBA_VERSION      = v2023-09-26


include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config/tatoeba.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/tasks.mk
include ${REPOHOME}lib/tasks/tatoeba/data.mk
include ${REPOHOME}lib/tasks/tatoeba/tune.mk
include ${REPOHOME}lib/tasks/tatoeba/misc.mk

include ${REPOHOME}lib/projects/distill.mk
include ${REPOHOME}lib/projects/elg.mk


.PHONY: all
all: 
	${MAKE} tatoeba-prepare
	${MAKE} data-tatoeba
	${MAKE} train-tatoeba
	${MAKE} eval-tatoeba
	${MAKE} compare-tatoeba
	${MAKE} eval-testsets-tatoeba



jhubc.count:
	pigz -cd < work/mul-mul/train/jhubc.src.clean.spm64k.gz | wc -l > $@
	pigz -cd < work/mul-mul/train/jhubc.trg.clean.spm64k.gz | wc -l >> $@


opusjhubc: work/mul-mul/train/opusTCv20230926+bt+jhubc.src.clean.spm64k.gz

work/mul-mul/train/opusTCv20230926+bt+jhubc.src.clean.spm64k.gz: work/mul-mul/train/jhubc.clean.spm64k work/mul-mul/train/opusTCv20230926+bt.clean.spm64k
	paste -d "\n" $^ | grep -v '^	*$$' | tee >(cut -f1 | pigz -c > $@) \
	| cut -f2 \
	| pigz -c > work/mul-mul/train/opusTCv20230926+bt+jhubc.trg.clean.spm64k.gz

work/mul-mul/train/jhubc.clean.spm64k:
	paste 	<(pigz -cd work/mul-mul/train/jhubc.src.clean.spm64k.gz) \
		<(pigz -cd work/mul-mul/train/jhubc.trg.clean.spm64k.gz) \
	> $@

work/mul-mul/train/opusTCv20230926+bt.clean.spm64k:
	paste 	<(pigz -cd work/mul-mul/train/opusTCv20230926+bt.src.clean.spm64k.gz) \
		<(pigz -cd work/mul-mul/train/opusTCv20230926+bt.trg.clean.spm64k.gz) \
	> $@



WRONG_LUMI_LANGS = fin-isl fra-nld hun-spa nld-spa nld-swe pol-por por-swe deu-eng eng-spa eng-por

redo-lumidata:
	for l in ${WRONG_LUMI_LANGS}; do \
	  rm -f work/data/simple/*$${l}*; \
	  rm -f $$l-strict-data; \
	done
	${MAKE} $(patsubst %,%-strict-data,${WRONG_LUMI_LANGS})
	${MAKE} restart-lumijobs

restart-lumijobs:
	make MARIAN_EXTRA=--no-restore-corpus lumi-jobs lumi-eulangs
	make MARIAN_EXTRA=--no-restore-corpus lumi-big-multi-eng lumi-big-multi-eng2 lumi-big-multi-eng3
	make MARIAN_EXTRA=--no-restore-corpus lumi-big-multi2

# work/data/simple/Tatoeba-train-v2023-09-26.eng-spa.strict.eng.gz
CLEANDATA_BASENAME = work/data/simple/Tatoeba-train-v2023-09-26
CHECK_DATASETS = $(patsubst %,%-checksize,${TATOEBA_LANGPAIRS})

check-cleandata-sizes: ${CHECK_DATASETS}

%-checksize:
	@if [ `${GZIP} -cd < ${CLEANDATA_BASENAME}.${@:-checksize=}.clean.$(firstword $(subst -, ,${@:-checksize=})).gz | wc -l` -ne \
	     `${GZIP} -cd < ${CLEANDATA_BASENAME}.${@:-checksize=}.clean.$(lastword $(subst -, ,${@:-checksize=})).gz | wc -l` ]; then \
	  echo "different size: ${@:-checksize=}"; \
	else \
	  echo "same size: ${@:-checksize=}"; \
	fi


print-langpairs:
	@echo "$(sort ${TATOEBA_LANGPAIRS})" | tr " " "\n"

ALL_STRICT_DATASETS = $(patsubst %,%-strict-data,${TATOEBA_LANGPAIRS})
all-strict-datasets: ${ALL_STRICT_DATASETS}

%-strict-data:
	( s=$(firstword $(subst -, ,$(@:-strict-data=))); \
	  t=$(lastword $(subst -, ,$(@:-strict-data=))); \
	  if [ ! $$s \> $$t ]; then \
	    ${MAKE} SRC=$$s TRG=$$t clean-data-source; \
	    ${MAKE} SRC=$$s TRG=$$t strict-clean-datasets; \
	  fi )
	touch $@

strict-clean-datasets:
	for s in $(sort $(shell cat ${CLEAN_TRAIN_SRC:.${CLEAN_TRAINDATA_TYPE}.${SRCEXT}.gz=.clean.${SRCEXT}.labels})); do \
	  for t in $(sort $(shell cat ${CLEAN_TRAIN_TRG:.${CLEAN_TRAINDATA_TYPE}.${TRGEXT}.gz=.clean.${TRGEXT}.labels})); do \
	    ${MAKE} SRC=$$s TRGL=$$t strict-clean-dataset; \
	  done \
	done

strict-clean-dataset:
	if [ -e ${CLEAN_TEST_SRC} ] && [ -e ${CLEAN_TEST_TRG} ]; then \
	  ${MAKE} ${CLEAN_TEST_SRC_STATS} ${CLEAN_TEST_TRG_STATS}; \
	fi
	if [ -e ${CLEAN_TRAIN_SRC:.${CLEAN_TRAINDATA_TYPE}.${SRCEXT}.gz=.clean.${SRCEXT}.gz} ]; then \
	  ${MAKE} strict-clean-data; \
	fi



#################################################
## fixed sentence piece models for all langs
#################################################

## store basic parallel data on allas

.PHONY: store-helsinki-data
store-helsinki-data:
	which a-get
	swift upload Helsinki-NLP-data-opusmtTC --changed --skip-identical --use-slo --segment-size 5G  work/data


# or rather base 2 sizes?
# 16384 32768 65536 8192 4096
# (but this breaks the way we create the short size string)

TRGLANG_GROUP ?= gmw
TRGLANG_GROUP_LANGS = $(call find-langgroup,${TRGLANG_GROUP})

SUBWORD_TRG_SHORTSIZE = ${SUBWORD_TRGVOCAB_SIZE:000=}k
SUBWORD_TRG_NAME = ${lastword ${subst -, ,${LANGPAIRSTR}}}

tatoeba-tokenizer-groups:
	for g in ${OPUS_LANG_GROUPS}; do \
	  ${MAKE} TRGLANG_GROUP=$$g tatoeba-tokenizer-group; \
	done

TOKENIZER_LANGGROUPS_MAXNRLANGS = 25
TOKENIZER_LANGGROUPS_MINNRLANGS = 2

tatoeba-tokenizer-group:
	echo "${TRGLANG_GROUP}: ${TRGLANG_GROUP_LANGS}"
	if [ $(words ${TRGLANG_GROUP_LANGS}) -ge ${TOKENIZER_LANGGROUPS_MINNRLANGS} ]; then \
	  if [ $(words ${TRGLANG_GROUP_LANGS}) -le ${TOKENIZER_LANGGROUPS_MAXNRLANGS} ]; then \
	  	rm -f work/eng-${TRGLANG_GROUP}/opusTCv20210807-languages.trg; \
	  	rm -f work/eng-${TRGLANG_GROUP}/opusTCv20210807-langlabels.trg; \
		${MAKE} DATA_SAMPLING_WEIGHT=0.3 MAX_DATA_SIZE=100000000 \
			SRCLANGS=eng TRGLANGS="${TRGLANG_GROUP_LANGS}" \
			LANGPAIRSTR="eng-${TRGLANG_GROUP}" tatoeba-tokenizer; \
	  fi \
	fi

tatoeba-tokenizer-mul:
	${MAKE} TRGLANG_GROUP=mul \
		TOKENIZER_SIZES="16000 32000 64000" \
		TOKENIZER_LANGGROUPS_MAXNRLANGS=6000 \
		TOKENIZER_LANGGROUPS_MINNRLANGS=25 tatoeba-tokenizer-group

MISSING_TOK_LANGS = bos hau hrv ind kir nob nno oci ori pan pol por ron sin slk sqi srp swe tam tgk tha
tatoeba-tokenizer-missing:
	for l in ${filter ${TATOEBA_LANGS},${MISSING_TOK_LANGS}}; do \
	  ${MAKE} SRC=eng TRG=$$l DATA_SAMPLING_WEIGHT=0.3 tatoeba-tokenizer; \
	done

tatoeba-tokenizer-missing2:
#	for l in hbs nor msa; do \
#	  ${MAKE} SRC=eng TRG=$$l DATA_SAMPLING_WEIGHT=0.3 tokenizer-fetch-data; \
#	done
	for l in bos_Cyrl bos_Latn srp_Cyrl srp_Latn; do \
	  ${MAKE} SRC=eng TRG=$$l DATA_SAMPLING_WEIGHT=0.3 tatoeba-tokenizer; \
	done

tatoeba-tokenizer-missing3:
	for l in ${filter-out ${TATOEBA_LANGS},${MISSING_TOK_LANGS}}; do \
	  ${MAKE} SRC=eng TRG=$$l DATA_SAMPLING_WEIGHT=0.3 tatoeba-tokenizer; \
	done


tatoeba-tokenizer-langs:
	for l in ${filter-out eng,${TATOEBA_LANGS}}; do \
	  ${MAKE} SRC=eng TRG=$$l DATA_SAMPLING_WEIGHT=0.3 tatoeba-tokenizer; \
	done
	${MAKE} SRC=fra TRG=eng DATA_SAMPLING_WEIGHT=0.3 tatoeba-tokenizer

reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))
tatoeba-tokenizer-langs-reverse:
	for l in $(call reverse,$(filter-out eng,${TATOEBA_LANGS})); do \
	  ${MAKE} SRC=eng TRG=$$l DATA_SAMPLING_WEIGHT=0.3 tatoeba-tokenizer; \
	done

tatoeba-tokenizer-check:
	for l in ${filter-out eng,${TATOEBA_LANGS}}; do \
	  if [ -e models/spm/eng-$$l/opusTC.$$l.4k.spm.vocab ]; then \
	    if [ `cat models/spm/eng-$$l/opusTC.$$l.4k.spm.vocab | wc -l` -lt 4000 ]; then \
	      echo "remove models/spm/eng-$$l/opusTC.$$l.4k.spm.vocab"; \
	      mkdir -p models/spm-removed/eng-$$l; \
	      mv models/spm/eng-$$l/opusTC.$$l.4k.spm* models/spm-removed/eng-$$l; \
	    fi \
	  fi; \
	  if [ -e models/spm/eng-$$l/opusTC.$$l.8k.spm.vocab ]; then \
	    if [ `cat models/spm/eng-$$l/opusTC.$$l.8k.spm.vocab | wc -l` -lt 8000 ]; then \
	      echo "remove models/spm/eng-$$l/opusTC.$$l.8k.spm.vocab"; \
	      mkdir -p models/spm-removed/eng-$$l; \
	      mv models/spm/eng-$$l/opusTC.$$l.8k.spm* models/spm-removed/eng-$$l; \
	    fi \
	  fi; \
	  if [ -e models/spm/eng-$$l/opusTC.$$l.16k.spm.vocab ]; then \
	    if [ `cat models/spm/eng-$$l/opusTC.$$l.16k.spm.vocab | wc -l` -lt 16000 ]; then \
	      echo "remove models/spm/eng-$$l/opusTC.$$l.16k.spm.vocab"; \
	      mkdir -p models/spm-removed/eng-$$l; \
	      mv models/spm/eng-$$l/opusTC.$$l.16k.spm* models/spm-removed/eng-$$l; \
	    fi \
	  fi; \
	  if [ -e models/spm/eng-$$l/opusTC.$$l.32k.spm.vocab ]; then \
	    if [ `cat models/spm/eng-$$l/opusTC.$$l.32k.spm.vocab | wc -l` -lt 32000 ]; then \
	      echo "remove models/spm/eng-$$l/opusTC.$$l.32k.spm.vocab"; \
	      mkdir -p models/spm-removed/eng-$$l; \
	      mv models/spm/eng-$$l/opusTC.$$l.32k.spm* models/spm-removed/eng-$$l; \
	    fi \
	  fi; \
	  if [ -e models/spm/eng-$$l/opusTC.$$l.64k.spm.vocab ]; then \
	    if [ `cat models/spm/eng-$$l/opusTC.$$l.64k.spm.vocab | wc -l` -lt 64000 ]; then \
	      echo "remove models/spm/eng-$$l/opusTC.$$l.64k.spm.vocab"; \
	      mkdir -p models/spm-removed/eng-$$l; \
	      mv models/spm/eng-$$l/opusTC.$$l.64k.spm* models/spm-removed/eng-$$l; \
	    fi \
	  fi; \
	done


TOKENIZER_SIZES = 16000 32000 64000 8000 4000

tokenizer-fetch-data: 
	rm -fr ${WORKDIR}/spm
	mkdir -p ${WORKDIR}/spm/train
	${MAKE} WORKDIR=${WORKDIR}/spm fetch-datasets
	${MAKE} WORKDIR=${WORKDIR}/spm langlabel-files
	${MAKE} WORKDIR=${WORKDIR}/spm rawdata
	${MAKE} WORKDIR=${WORKDIR}/spm local-config

# ifneq ($(words $(wildcard ${RELEASEDIR}/spm/${LANGPAIRSTR}/opusTC.${SUBWORD_TRG_NAME}.*.spm)),$(words ${TOKENIZER_SIZES}))

tatoeba-tokenizer: 
ifeq ($(wildcard ${RELEASEDIR}/spm/${LANGPAIRSTR}/opusTC.${SUBWORD_TRG_NAME}.*.spm),)
	rm -fr ${WORKDIR}/spm
	mkdir -p ${WORKDIR}/spm/train
	${MAKE} WORKDIR=${WORKDIR}/spm fetch-datasets
	${MAKE} WORKDIR=${WORKDIR}/spm langlabel-files
	${MAKE} WORKDIR=${WORKDIR}/spm rawdata-tatoeba
	${MAKE} WORKDIR=${WORKDIR}/spm local-config-tatoeba
	for s in ${TOKENIZER_SIZES}; do \
	  ${MAKE} SUBWORD_TRGVOCAB_SIZE=$$s tatoeba-spmodel; \
	done
	rm -fr ${WORKDIR}/spm
endif

tatoeba-spmodel: ${RELEASEDIR}/spm/${LANGPAIRSTR}/opusTC.${SUBWORD_TRG_NAME}.${SUBWORD_TRG_SHORTSIZE}.spm

${RELEASEDIR}/spm/${LANGPAIRSTR}/opusTC.${SUBWORD_TRG_NAME}.${SUBWORD_TRG_SHORTSIZE}.spm:
	mkdir -p ${dir $@}
	${MAKE} WORKDIR=${WORKDIR}/spm SPM_INPUT_SIZE=10000000 spm-trgmodel-tatoeba > $@.stdout 2>$@.stderr
	mv ${WORKDIR}/spm/train/$(notdir ${SPMTRGMODEL}) $@
	mv ${WORKDIR}/spm/train/$(notdir ${SPMTRGMODEL}).vocab $@.vocab
	if [ `cat $@.vocab | wc -l` -lt ${SUBWORD_TRGVOCAB_SIZE} ]; then \
	  mkdir -p ${RELEASEDIR}/spm-removed/${LANGPAIRSTR}; \
	  mv $@* ${RELEASEDIR}/spm-removed/${LANGPAIRSTR}/; \
	fi


## upload to allas

TATOEBA_SPM_BUCKET = https://object.pouta.csc.fi/Tatoeba-MT-spm
tatoeba-spmodel-upload:
	which a-put
	mkdir -p ${RELEASEDIR}/spm/tmp
	cd ${RELEASEDIR}/spm/tmp && ln -s ../*-*/* . 
	cd ${RELEASEDIR}/spm/tmp && swift upload Tatoeba-MT-spm --changed --skip-identical *.*
	rm -f ${RELEASEDIR}/spm/tmp/*
	rmdir ${RELEASEDIR}/spm/tmp
	swift post Tatoeba-MT-spm --read-acl ".r:*"
	echo "# Tatoeba-MT Sentence Piece Models" > SentencePieceModels.md
	echo ""                                  >> SentencePieceModels.md
	echo "```python"                         >> SentencePieceModels.md
	echo "import sentencepiece as spm"       >> SentencePieceModels.md
	echo "sp = spm.SentencePieceProcessor(model_file='opusTC.eng.16k.spm')" >> SentencePieceModels.md
	echo "print(sp.encode(['Hello world', 'This is a tokenization-test'], out_type=str))" >> SentencePieceModels.md
	echo "```"                               >> SentencePieceModels.md
	echo ""                                  >> SentencePieceModels.md
	swift list Tatoeba-MT-spm | grep '\.spm$$' |\
	sed 's#^\(.*\)$$#* [\1](${TATOEBA_SPM_BUCKET}/\1) ([vocab](${TATOEBA_SPM_BUCKET}/\1.vocab), [log stdout](${TATOEBA_SPM_BUCKET}/\1.stdout), [log stderr](${TATOEBA_SPM_BUCKET}/\1.stderr))#' >> SentencePieceModels.md


##################################################################################################
##################################################################################################







## start unidirectional training job
## - make data first, then submit a job
.PHONY: tatoeba-job
tatoeba-job:
	rm -f train-and-eval.submit
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba

## start jobs in both translation directions
.PHONY: tatoeba-bidirectional-job
tatoeba-bidirectional-job:
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba
ifneq (${SRCLANGS},${TRGLANGS})
	${MAKE} reverse-data-tatoeba
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" tatoeba-prepare
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-job-tatoeba
endif



## generic recipe to replace SRCLANGS and TRGLANGS
## with all languages that are part of the Tatoeba data sets
## (there can be sub-languages in each package)
%-tatoeba: ${TATOEBA_SRCLABELFILE} ${TATOEBA_TRGLABELFILE} ${TATOEBA_LANGIDS_TRAINONLY}
	${MAKE} LANGPAIRSTR=${LANGPAIRSTR} \
		SRCLANGS="${shell cat ${word 1,$^}}" \
		TRGLANGS="${shell cat ${word 2,$^}}" \
	${@:-tatoeba=}


## prepare data (fetch data and extract language labesl)
.PHONY: tatoeba-prepare
tatoeba-prepare: ${TATOEBA_LANGIDS_TRAINONLY}
	${MAKE} fetch-datasets
	${MAKE} langlabel-files


## prepare and make all data files (dev/test/train)
.PHONY: prepare-and-data tatoeba-prepare-and-data
prepare-and-data tatoeba-prepare-and-data: ${TATOEBA_LANGIDS_TRAINONLY}
	${MAKE} fetch-datasets
	${MAKE} langlabel-files
	${MAKE} data-tatoeba


## for compatibility: recipes with tatoeba prefix
.PHONY: tatoeba-data tatoeba-train tatoeba-eval tatoeba-compare
tatoeba-data: data
tatoeba-train: train
tatoeba-eval: eval
tatoeba-compare: compare


## fetch the essential data and get labels for language variants
.PHONY: tatoeba-data tatoeba-labels
tatoeba-labels: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
		${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg


## a file that contains langids without test data
.PHONY: trainonly_langids
trainonly_langids: ${TATOEBA_LANGIDS_TRAINONLY}

print-langgroups:
	@echo ${OPUS_LANG_GROUPS}



## release all impoved models
##  - check leaderboard scores
##  - get all models that have at least one improved BLEU score
##  - make a release if the model is done
##
## caveat: does not check for model parameters/types etc!

show-improved-models:
	make -s compare-bleu-score-table-tatoeba | \
		grep -v '	0	[a-z]' | grep -v '	-[0-9]' | \
		cut -f6 | sort -u | xargs



release-improved-models:
	for l in ${shell make -s compare-bleu-score-table-tatoeba | \
		grep -v '	0	[a-z]' | grep -v '	-[0-9]' | \
		cut -f6 | sort -u | xargs}; do \
	    s=`echo "$$l" | cut -f1 -d-`; \
	    t=`echo "$$l" | cut -f2 -d-`; \
	    make SRCLANGS="$$s" TRGLANGS="$$t" release-if-done-tatoeba; \
	done

## release all models with improved scores even if they are not yet done
release-all-improved-models:
	for l in ${shell make -s compare-bleu-score-table-tatoeba | \
		grep -v '	0	[a-z]' | grep -v '	-[0-9]' | \
		cut -f6 | sort -u | xargs}; do \
	    s=`echo "$$l" | cut -f1 -d-`; \
	    t=`echo "$$l" | cut -f2 -d-`; \
	    make SRCLANGS="$$s" TRGLANGS="$$t" release-tatoeba; \
	done



###############################################################################
## generic targets for evaluating multilingual models (all supported lang-pairs)
###############################################################################


## evaluate all individual test sets in a multilingual model

.PHONY: tatoeba-multilingual-eval
tatoeba-multilingual-eval:
	-${MAKE} tatoeba-multilingual-testsets
ifneq (${words ${SRCLANGS} ${TRGLANGS}},2)
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ -e ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
		TATOEBA_TESTSET=${TATOEBA_TESTSET}.$$s-$$t \
		TATOEBA_TESTSET_NAME=${TATOEBA_TESTSET}.$$s-$$t \
	      compare-tatoeba; \
	    fi \
	  done \
	done
endif


## evaluate individual language pairs
## (above data sets include macro-languages that include 
##  several individual languages, e.g. hbs or msa)
## the additional prefix '-tatoeba' does the magic
## and expands SRCLANGS and TRGLANGS to individual
## language pairs!

.PHONY: tatoeba-sublang-eval
tatoeba-sublang-eval: tatoeba-multilingual-eval-tatoeba
	@echo "done!"




##------------------------------------------------------------------------------------
## generic targets to start combinations of languages or language groups
## set variables below to avoid starting models with too few or too many languages
## on source or target side
##------------------------------------------------------------------------------------

MIN_SRCLANGS ?= 1
MIN_TRGLANGS ?= 1
MAX_SRCLANGS ?= 7000
MAX_TRGLANGS ?= 7000

# find-langgroup = $(filter ${OPUS_LANGS3},\
# 		$(sort ${shell langgroup $(1) | xargs iso639 -m -n} ${1} ${2}))


## OLD (singleonly - only allows single languages)
## NEW: also splits on '+' to allow for multiple languages

find-langgroup-singleonly = $(filter $(sort ${shell langgroup $(1) | xargs iso639 -m -n} ${1} ${2}),${TATOEBA_LANGS})
find-langgroup = $(filter $(sort ${shell langgroup $(subst +, ,$(1)) | xargs iso639 -m -n} $(subst +, ,${1}) ${2}),${TATOEBA_LANGS})
find-srclanggroup = $(call find-langgroup,$(firstword ${subst -, ,${subst 2, ,${1}}}),${2})
find-trglanggroup = $(call find-langgroup,$(lastword ${subst -, ,${subst 2, ,${1}}}),${2})

find-langgroup-pair = $(sort $(call find-srclanggroup,${1}) $(call find-trglanggroup,${1}) ${2})



## expand language groups to individual languages and language pairs

SRCLANGGROUP ?= gmw
TRGLANGGROUP ?= gmw

LANGGROUP_SRCLANGS := ${call find-srclanggroup,${SRCLANGGROUP},${PIVOT}}
LANGGROUP_TRGLANGS := ${call find-srclanggroup,${TRGLANGGROUP},${PIVOT}}
LANGGROUP_LANGPAIRS := $(foreach S,${LANGGROUP_SRCLANGS},$(foreach T,${LANGGROUP_TRGLANGS},${S}-${T}))

## remove non-supported language pairs (make pattern to skip those language pairs)
## also remove combinations of the same language if SKIP_SAME_LANG is set to 1

ifeq (${SKIP_SAME_LANG},1)
  LANGGROUP_SAMELANG_LANGPAIRS := $(foreach L,${LANGGROUP_SRCLANGS},${L}-${L})
  LANGGROUP_SKIP_LANGPAIRS := ${LANGGROUP_SAMELANG_LANGPAIRS} $(filter-out ${TATOEBA_LANGPAIRS},${LANGGROUP_LANGPAIRS})
  LANGGROUP_USE_LANGPAIRS := $(filter-out ${LANGGROUP_SKIP_LANGPAIRS},${LANGGROUP_LANGPAIRS})
  LANGGROUP_SKIP_LANGPAIR_PATTERN := $(subst ${SPACE},|,${LANGGROUP_SKIP_LANGPAIRS})
else
  LANGGROUP_SKIP_LANGPAIRS := $(filter-out ${TATOEBA_LANGPAIRS},${LANGGROUP_LANGPAIRS})
  LANGGROUP_USE_LANGPAIRS := $(filter ${TATOEBA_LANGPAIRS},${LANGGROUP_LANGPAIRS})
  LANGGROUP_SKIP_LANGPAIR_PATTERN := $(subst ${SPACE},|,${LANGGROUP_SKIP_LANGPAIRS})
endif


## print languages in this set
tatoeba-%-langs:
	@( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langs,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langs,%,$@))); \
	   echo "${call find-srclanggroup,${patsubst tatoeba-%-langs,%,$@},${PIVOT}}"; \
	   echo "${call find-trglanggroup,${patsubst tatoeba-%-langs,%,$@},${PIVOT}}"; )
	@echo 'use: ${LANGGROUP_USE_LANGPAIRS}'
	@echo 'skip: ${LANGGROUP_SKIP_LANGPAIR_PATTERN}'


## shortcut to start a target only if certain language group limits are met
## (maximum and minimum number of languages)
%-groupsize-limits:
	@if [ ${words ${SRCLANGS}} -ge ${MIN_SRCLANGS} ]; then \
	  if [ ${words ${TRGLANGS}} -ge ${MIN_TRGLANGS} ]; then \
	    if [ ${words ${SRCLANGS}} -le ${MAX_SRCLANGS} ]; then \
	      if [ ${words ${TRGLANGS}} -le ${MAX_TRGLANGS} ]; then \
		${MAKE} ${@:-groupsize-limits=}; \
	      fi \
	    fi \
	  fi \
	fi

## create data sets (also works for language groups)
tatoeba-%-data:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-data,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-data,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-data,%,$@},${PIVOT}}"; \
	   ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="$$S" TRGLANGS="$$T" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
	   tatoeba-prepare-and-data-groupsize-limits; )


## train a tatoeba model
## - create config file
## - create data sets
## - run training and evaluation
tatoeba-%-train:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-train,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-train,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-train,%,$@},${PIVOT}}"; \
	   ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
			all-groupsize-limits; )

## start the training job
## - create config file
## - create data sets
## - submit SLURM training job
tatoeba-%-trainjob:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-trainjob,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-trainjob,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-trainjob,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-trainjob,%,$@},${PIVOT}}"; \
	   if [ ! `find ${WORKHOME}/$$s-$$t -maxdepth 1 -name '${TATOEBA_DATASET}.*${MODELTYPE}.model${NR}.done' | wc -l` -gt 0 ]; then \
	     ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
			tatoeba-job-groupsize-limits; \
	   else \
	      echo "..... already done! ($$s-$$t/${TATOEBA_DATASET}.*${MODELTYPE}.model${NR}.done)"; \
	   fi )


## add pivot languages
tatoeba-%-pivotlang:
	@if [ "$(call find-langgroup-pair,$(word 2,$(subst -, ,$@)),${TATOEBA_PIVOT})" != \
	      "$(call find-langgroup-pair,$(word 2,$(subst -, ,$@)))" ]; then \
	  ${MAKE} PIVOT=${TATOEBA_PIVOT} \
		DATASET=${DATASET}+${TATOEBA_PIVOT} \
		MODEL_LATEST_VOCAB= \
		BPEMODELNAME=opus+${TATOEBA_PIVOT} \
	  ${@:-pivotlang=}; \
	else \
	  echo "pivot language '${TATOEBA_PIVOT}' is already included in $@!"; \
	fi

#		SKIP_LANGPAIRS=${TATOEBA_PIVOT}-${TATOEBA_PIVOT} \


gmq-info:
	langgroup gmq
	echo $(filter nor,$(TATOEBA_LANGS))
	echo ${call find-srclanggroup,gmq}

tatoeba-%-info:
	-( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-info,%,$@))); \
	   t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-info,%,$@))); \
	   S="${call find-srclanggroup,${patsubst tatoeba-%-info,%,$@},${PIVOT}}"; \
	   T="${call find-trglanggroup,${patsubst tatoeba-%-info,%,$@},${PIVOT}}"; \
	   ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
			TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
			TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
			print-info; )


## evaluate with the model-specific test set
tatoeba-%-eval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-eval,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-eval,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
		compare-tatoeba; \
	    fi \
	  fi )

## run evaluation for indivudual language pairs
## in case of multilingual models
tatoeba-%-multieval:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-multieval,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-multieval,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-multieval,%,$@},${PIVOT}}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-multieval,%,$@},${PIVOT}}"; \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
		tatoeba-multilingual-eval; \
	      ${MAKE} LANGPAIRSTR=$$s-$$t SRCLANGS="$$S" TRGLANGS="$$T" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
		tatoeba-sublang-eval; \
	    fi \
	  fi )

## evaluate test sets
tatoeba-%-eval-testsets:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-eval-testsets,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-eval-testsets,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    if [ `find ${WORKHOME}/$$s-$$t/ -name '*.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-eval-testsets,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-eval-testsets,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
		eval-testsets-tatoeba; \
	    fi \
	  fi )

## create test sets
tatoeba-%-testsets:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-testsets,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-testsets,%,$@))); \
	  ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-testsets,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-testsets,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
		tatoeba-multilingual-testsets; )

## do all benchmark tests
## - model specific test set
## - other language-specific test sets
## - individual language pairs for multilingual models
tatoeba-%-evalall: tatoeba-%-eval tatoeba-%-multieval tatoeba-%-eval-testsets
	@echo "Done!"


##------------------------------------------------------------------
## create a release package
## (only if BLEU is > MIN_BLEU_SCORE)
## (suffix -release is an alias for -dist)
##------------------------------------------------------------------

tatoeba-%-release:
	${MAKE} ${@:-release=-dist}

tatoeba-%-dist:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-dist,%,$@))); \
	  if [ -e ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t \
		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-dist,%,$@},${PIVOT}}" \
		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-dist,%,$@},${PIVOT}}" \
		TATOEBA_SRCLANG_GROUP="`langgroup -n $$s | xargs iso639 -m -n | sort`" \
		TATOEBA_TRGLANG_GROUP="`langgroup -n $$t | xargs iso639 -m -n | sort`" \
		release-tatoeba; \
	  fi )




##------------------------------------------------------------------------------------
## shortcuts for different kinds of data balancing
##  1 million
##  2 million
##  4 million
##------------------------------------------------------------------------------------


## make all lang-group models using different data samples
## (1m, 2m or 4m sentence pairs)
##
## make all-tatoeba-langgroups-1m
## make all-tatoeba-langgroups-2m
## make all-tatoeba-langgroups-4m
## 
## or eng2group and group2eng models, e.g.
##
## make all-tatoeba-group2eng-2m
## make all-tatoeba-eng2group-2m
##
## make release packages for all group models, e.g.
##
## make all-tatoeba-group2eng-dist-2m
## make all-tatoeba-langgroup-dist-2m

%-1m:
	${MAKE} LANGGROUP_FIT_DATA_SIZE=1000000 \
		FIT_DATA_SIZE=1000000 \
		DATASET=${DATASET}1m \
		MARIAN_VALID_FREQ=10000 \
	${@:-1m=}

%-2m:
	${MAKE} CONTINUE_EXISTING=1 \
		LANGGROUP_FIT_DATA_SIZE=2000000 \
		FIT_DATA_SIZE=2000000 \
		DATASET=${DATASET}2m \
		MARIAN_VALID_FREQ=10000 \
	${@:-2m=}

%-4m:
	${MAKE} CONTINUE_EXISTING=1 \
		LANGGROUP_FIT_DATA_SIZE=4000000 \
		FIT_DATA_SIZE=4000000 \
		DATASET=${DATASET}4m \
		MARIAN_VALID_FREQ=10000 \
	${@:-4m=}





##------------------------------------------------------------------------------------
## some convenient recipes for various specific tasks
##   TODO: do all of them still work?
##------------------------------------------------------------------------------------



## restart all language pairs of models that have not yet converged
## TODO: takes only the first model found in the directory
tatoeba-continue-unfinished:
	for d in `find ${WORKHOME}/  -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  if [ `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' | grep -v tuned | wc -l` -gt 0 ]; then \
	    if [ ! `find ${WORKHOME}/$$d -maxdepth 1  -name '*.done' | grep -v tuned | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f3 -d.`; \
	      t=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-train; \
	    fi \
	  fi \
	done

## restart all language pairs of unreleased models
## unless they are converged already
## TODO: takes only the first model found in the directory
tatoeba-continue-unreleased:
	find ${WORKHOME}/           -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  if [ `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' | grep -v tuned | wc -l` -gt 0 ]; then \
	    if [ ! `find ${WORKHOME}/$$d -maxdepth 1 -name '*.done' | grep -v tuned | wc -l` -gt 0 ]; then \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f3 -d.`; \
	      t=`ls ${WORKHOME}/$$d/*.valid1.log | head -1 | cut -f3 -d/ | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-train; \
	    fi \
	  fi \
	done
	rm -f $@.tt1 $@.tt2


## release all language pairs
## (including lang-group models)
tatoeba-release-all:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	    p=`echo $$d | sed 's/-/2/'`; \
	    m=`echo $$f | cut -f3 -d.`; \
	    t=`echo $$f | cut -f1 -d.`; \
	    ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	    ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done

## release all models that have converged
tatoeba-release-finished:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.done' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done


## release all models that are not yet released
tatoeba-release-unreleased:
	find ${WORKHOME}/       -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist; \
	  done \
	done
	rm -f $@.tt1 $@.tt2

tatoeba-release-unreleased-test:
	find ${WORKHOME}/       -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt1
	find ${TATOEBA_MODELSHOME}/ -maxdepth 1 -type d -name '???-???' -printf "%f\n" | sort > $@.tt2
	for d in `diff $@.tt1 $@.tt2 | grep '<' | cut -f2 -d' '`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.valid1.log' -printf " %f" | grep -v tuned`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      echo "${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-evalall"; \
	      echo "${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-dist"; \
	  done \
	done
#	rm -f $@.tt1 $@.tt2

## refresh release info for the latest model that converged in each directory
## ---> be aware of the danger of overwriting existing files
## ---> backups are stored in models-backup
tatoeba-refresh-finished:
	for d in `find ${WORKHOME}/ -maxdepth 1 -type d -name '???-???' -printf " %f"`; do \
	  for f in `find ${WORKHOME}/$$d -maxdepth 1 -name '*.done' -printf "%A@\t%f\n" | sort -nr | cut -f2 | grep -v tuned | head -1`; do \
	      p=`echo $$d | sed 's/-/2/'`; \
	      m=`echo $$f | cut -f3 -d.`; \
	      t=`echo $$f | cut -f1 -d.`; \
	      ${MAKE} DATASET=$$t MODELTYPE=$$m tatoeba-$$p-refresh; \
	  done \
	done





###########################################################################################
# start combinations with a specific source/target language
###########################################################################################

## similar but for all available languages
## (not only the ones from the subset)
## NOTE: no size balancing to 1m as default in langgroup recipes!

tatoeba-src2all:
	for l in ${TATOEBA_AVAILABLE_TRG}; do \
	    ${MAKE} tatoeba-${SRC}2$$l-trainjob; \
	done

tatoeba-src2langgroup:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_TRG} 2>/dev/null}}; do \
	    ${MAKE} 	FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
			MIN_TRGLANGS=2 \
			SKIP_SAME_LANG=1 \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
		tatoeba-${SRC}2$$l-trainjob; \
	done

tatoeba-all2trg:
	for l in ${TATOEBA_AVAILABLE_SRC}; do \
	    ${MAKE} tatoeba-$${l}2${TRG}-trainjob; \
	done

tatoeba-langgroup2trg:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_SRC} 2>/dev/null}}; do \
	    ${MAKE} 	FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
			MIN_SRCLANGS=2 \
			SKIP_SAME_LANG=1 \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
	    	tatoeba-$${l}2${TRG}-trainjob; \
	done

## TODO: do we always want to include the pivot=eng?
tatoeba-langgroups all-tatoeba-langgroup: 
	for g in ${OPUS_LANG_GROUPS}; do \
	  ${MAKE} 	MIN_SRCLANGS=3 \
			PIVOT=eng \
			SKIP_SAME_LANG=1 \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
			FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
		tatoeba-$${g}2$${g}-trainjob; \
	done

#			MAX_SRCLANGS=30 \


## TODO: do we want to include the pivot=eng?
tatoeba-cross-langgroups all-tatoeba-cross-langgroups:
	for s in ${OPUS_LANG_GROUPS}; do \
	  for t in ${OPUS_LANG_GROUPS}; do \
	    if [ "$$s" != "$$t" ]; then \
		${MAKE} MIN_SRCLANGS=2 MIN_TRGLANGS=2 \
			SKIP_SAME_LANG=1 \
			FIT_DATA_SIZE=${LANGGROUP_FIT_DATA_SIZE} \
			MODELTYPE=${LANGGROUP_MODELTYPE} \
		tatoeba-$${s}2$${t}-trainjob; \
	    fi \
	  done \
	done

#			MAX_SRCLANGS=30 MAX_TRGLANGS=30 \
#			PIVOT=eng \




###########################################################################################
# start combinations with a specific source/target language
###########################################################################################
#
# make SRC=deu tatoeba-src2all-reasonable
# make SRC=deu tatoeba-src2all-small
#
# make TRG=deu tatoeba-all2trg-reasonable
# make TRG=deu tatoeba-all2trg-small
#

tatoeba-src2all-subset:
	for l in ${TATOEBA_AVAILABLE_SUBSET_TRG}; do \
	    ${MAKE} tatoeba-${SRC}2$$l-trainjob; \
	done

tatoeba-src2langgroup-subset:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_SUBSET_TRG} 2>/dev/null}}; do \
	    ${MAKE} tatoeba-${SRC}2$$l-trainjob-1m; \
	done

tatoeba-all2trg-subset:
	for l in ${TATOEBA_AVAILABLE_SUBSET_SRC}; do \
	    ${MAKE} tatoeba-$${l}2${TRG}-trainjob; \
	done

tatoeba-langgroup2trg-subset:
	for l in ${sort ${shell langgroup -p -n ${TATOEBA_AVAILABLE_SUBSET_SRC} 2>/dev/null}}; do \
	    ${MAKE} tatoeba-$${l}2${TRG}-trainjob-1m; \
	done

## all subsets

tatoeba-src2all-subsets:
	${MAKE} TATOEBA_SUBSET=lowest  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=lower   tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-src2all-subset

tatoeba-all2trg-subsets:
	${MAKE} TATOEBA_SUBSET=lowest  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=lower   tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-all2trg-subset


## reasonable size (all except lower and lowest)

tatoeba-src2all-reasonable:
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-src2all-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-src2all-subset

tatoeba-all2trg-reasonable:
	${MAKE} TATOEBA_SUBSET=medium  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=higher  tatoeba-all2trg-subset
	${MAKE} TATOEBA_SUBSET=highest tatoeba-all2trg-subset


## backoff to multilingual models and language groups
## lower / lowest resource languages and zero-shot

tatoeba-src2all-small:
	${MAKE} TATOEBA_SUBSET=lower     tatoeba-src2langgroup-subset
	${MAKE} TATOEBA_SUBSET=lowest    tatoeba-src2langgroup-subset
	${MAKE} TATOEBA_SUBSET=zero-shot tatoeba-src2langgroup-subset

tatoeba-all2trg-small:
	${MAKE} TATOEBA_SUBSET=lower     tatoeba-langgroup2trg-subset
	${MAKE} TATOEBA_SUBSET=lowest    tatoeba-langgroup2trg-subset
	${MAKE} TATOEBA_SUBSET=zero-shot tatoeba-langgroup2trg-subset





###########################################################################################
# models for wiki languages (that can be used to back-translate wiki-texts)
###########################################################################################

tatoeba-wiki2eng:
	for l in ${WIKIMACROLANGS}; do \
	  if [ ! `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS=$$l TRGLANGS=eng tatoeba-job; \
	  fi \
	done

## macro-languages that we missed before
tatoeba-wiki2eng-macro:
	for l in $(filter-out ${WIKILANGS},${WIKIMACROLANGS}); do \
	  if [ ! `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    ${MAKE} SRCLANGS=$$l TRGLANGS=eng tatoeba-job; \
	  fi \
	done

tatoeba-print-missing-wiki:
	@echo $(filter-out ${WIKILANGS},${WIKIMACROLANGS})

tatoeba-wiki2eng-parent:
	for l in ${WIKIMACROLANGS}; do \
	  if [ ! `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo "check $$l-eng"; \
	    if [ `find ${WORKHOME}/$$l-eng/train -name '${TATOEBA_DATASET}.src.clean.spm*.gz' 2>/dev/null | wc -l` -gt 0 ]; then \
	      echo "check data size of $$l-eng"; \
	      if [ `find ${WORKHOME}/$$l-eng/train -name '${TATOEBA_DATASET}.src.clean.spm*.gz' 2>/dev/null | xargs zcat | head -100000 | wc -l` -lt 100000 ]; then \
		p=`langgroup -p $$l`; \
		echo "${MAKE} SRCLANGS=$$p TRGLANGS=eng tatoeba-$${p}2eng-train-1m"; \
	      fi \
	    fi \
	  fi \
	done

tatoeba-wiki2eng-done:
	for l in ${WIKIMACROLANGS}; do \
	  if [ `find ${TATOEBA_MODELSHOME}/$$l-eng -name '*.zip' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo "model available for $$l-eng"; \
	  elif [ `find ${WORKHOME}/$$l-eng -name '*.done' 2>/dev/null | wc -l` -gt 0 ]; then \
	    echo -n "model aivailbale for $$l-eng but not released"; \
	    if [ `find ${WORKHOME}/$$l-eng -name '*.eval' 2>/dev/null | wc -l` -gt 0 ]; then \
	      echo -n ", BLEU = "; \
	      grep BLEU ${WORKHOME}/$$l-eng/*eval | head -1 | cut -f3 -d' '; \
	    elif [ ! -e ${WORKHOME}/$$l-eng/test/${TATOEBA_TESTSET}.src ]; then \
	      echo ", missing eval file"; \
	      echo "make WORKHOME=${WORKHOME}-tmp SRCLANGS=$$l TRGLANGS=eng data-tatoeba"; \
	    else \
	      echo ", run 'make tatoeba-$${l}2eng-evalall'"; \
	    fi \
	  fi \
	done



###########################################################################################
# language groups
###########################################################################################


## start all jobs for all combinations of 
## - language groups and English (separate in both directions)
## - languages in language groups (bi-directional)
##
## language groups include parents and grandparents

all-tatoeba-langgroups: 
	${MAKE} all-tatoeba-group2eng
	${MAKE} all-tatoeba-eng2group
	${MAKE} all-tatoeba-langgroup

all-tatoeba-group2eng: 
	${MAKE} TRG=eng tatoeba-langgroup2trg

all-tatoeba-eng2group: 
	${MAKE} SRC=eng tatoeba-src2langgroup


#---------------------------
# some special recipes for multilingual models with 4 million data fitting
#---------------------------

## include back-translations and fit to 4 million training exampels
all-tatoeba-langgroups-bt-4m: 
	${MAKE} all-tatoeba-group2eng-bt-4m
	${MAKE} all-tatoeba-eng2group-bt-4m
	${MAKE} all-tatoeba-langgroup-bt-4m
#	${MAKE} all-tatoeba-cross-langgroups-bt-4m

SELECTED_LANGGROUPS = cel bat fiu gem gmw gmq roa sla zle zls zlw

tatoeba-selected-langgroups:
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-cross-langgroups-bt-4m
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-langgroup-bt-4m
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-group2eng-bt-4m
	${MAKE} OPUS_LANG_GROUPS="${SELECTED_LANGGROUPS}" all-tatoeba-eng2group-bt-4m

tatoeba-gmw2langgroups-bt-4m:
	${MAKE} SRC=gmw tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=gmw tatoeba-langgroup2trg-bt-4m

tatoeba-roa2langgroups-bt-4m:
	${MAKE} SRC=roa tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=roa tatoeba-langgroup2trg-bt-4m

tatoeba-gmq2langgroups-bt-4m:
	${MAKE} SRC=gmq tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=gmq tatoeba-langgroup2trg-bt-4m

tatoeba-zlw2langgroups-bt-4m:
	${MAKE} SRC=zlw tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=zlw tatoeba-langgroup2trg-bt-4m

tatoeba-zle2langgroups-bt-4m:
	${MAKE} SRC=zle tatoeba-src2langgroup-bt-4m
	${MAKE} TRG=zle tatoeba-langgroup2trg-bt-4m


## temporary recipe for evaluating all 4m multilingual models that are done
tatoeba-eval-4m:
	for p in `ls ${WORKHOME}/*/*4m*done | cut -f2 -d/ | sed 's/\-/2/'`; do \
	  make MODELTYPE=transformer tatoeba-$$p-multieval-bt-4m; \
	  make MODELTYPE=transformer tatoeba-$$p-eval-testsets-bt-4m; \
	done

tatoeba-dist-4m:
	for p in `ls ${WORKHOME}/*/*4m*done | cut -f2 -d/ | sed 's/\-/2/'`; do \
	  make MODELTYPE=transformer tatoeba-$$p-dist-bt-4m; \
	done




## evaluate and create dist packages

## old: just depend on eval and dist targets
## --> this would also start training if there is no model
## --> do this only if a model exists! (see below)

## new: only start this if there is a model
all-tatoeba-group2eng-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${WORKHOME}/$$g-eng -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-$${g}2eng-dist; \
	  fi \
	done

all-tatoeba-eng2group-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${WORKHOME}/eng-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer tatoeba-eng2$${g}-dist; \
	  fi \
	done

all-tatoeba-langgroup-dist:
	for g in ${OPUS_LANG_GROUPS}; do \
	  if [ `find ${WORKHOME}/$$g-$$g -name '*.npz' | wc -l` -gt 0 ]; then \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-eval; \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-evalall; \
	    ${MAKE} MODELTYPE=transformer PIVOT=eng tatoeba-$${g}2$${g}-dist; \
	  fi \
	done



##---------------------------------------------------------
## train all models with backtranslations
##---------------------------------------------------------

TATOEBA_RELEASED_BT   = https://object.pouta.csc.fi/Tatoeba-MT-bt/released-data.txt

tatoeba-all-bt:
	for b in ${shell wget -qq -O - ${TATOEBA_RELEASED_BT} | grep -v '.txt' | cut -f1 -d'/' | sort -u}; do \
	  s=`echo $$b | cut -f1 -d'-'`; \
	  t=`echo $$b | cut -f2 -d'-'`; \
	  echo "${MAKE} -C bt-tatoeba SRC=$$s TRG=$$t fetch-bt"; \
	  echo "${MAKE} MODELTYPE=transformer-align HPC_CORES=2 HPC_MEM=32g tatoeba-$${t}2$${s}-train-bt.submitcpu"; \
	done



## special targets for some big language-group models
## (restriction above is for max 25 languages)

ine-ine:
	    ${MAKE} LANGPAIRSTR=ine-ine \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup ine | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup ine | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
		    HPC_DISK=1500 \
	    train-and-eval-job-tatoeba

sla-sla:
	    ${MAKE} LANGPAIRSTR=sla-sla \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup sla | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup sla | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
	    train-and-eval-job-tatoeba

gem-gem:
	    ${MAKE} LANGPAIRSTR=gem-gem \
		    SRCLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup gem | xargs iso639 -m -n}))" \
		    TRGLANGS="$(filter ${OPUS_LANGS3},$(sort ${shell langgroup gem | xargs iso639 -m -n}))" \
		    MODELTYPE=transformer \
	            FIT_DATA_SIZE=1000000 \
	    train-and-eval-job-tatoeba





#################################################################################
# run things for all language pairs in a specific subset
# (zero, lowest, lower, medium, higher, highest)
#################################################################################

## get the markdown page for a specific subset
tatoeba-%.md:
	wget -O $@ ${TATOEBA_RAWGIT_MASTER}/subsets/${TATOEBA_VERSION}/${patsubst tatoeba-%,%,$@}


## run all language pairs for a given subset
## in both directions
tatoeba-subset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-bidirectional-job; \
	done

## make dist-packages for all language pairs in a subset
tatoeba-distsubset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} SRCLANGS=$$s TRGLANGS=$$t MIN_BLEU_SCORE=10 release-tatoeba; \
	  fi; \
	  if [ -d ${WORKHOME}/$$t-$$s ]; then \
	    ${MAKE} SRCLANGS=$$t TRGLANGS=$$s MIN_BLEU_SCORE=10 release-tatoeba; \
	  fi; \
	done

## evaluate existing models in a subset
## (this is handy if the model is not converged yet and we need to evaluate the current state)
tatoeba-evalsubset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    if  [ `find ${WORKHOME}/$$s-$$t -name '*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t compare-tatoeba; \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t eval-testsets-tatoeba; \
	    fi \
	  fi; \
	  if [ -d ${WORKHOME}/$$t-$$s ]; then \
	    if  [ `find ${WORKHOME}/$$t-$$s -name '*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      ${MAKE} SRCLANGS=$$t TRGLANGS=$$s compare-tatoeba; \
	      ${MAKE} SRCLANGS=$$t TRGLANGS=$$s eval-testsets-tatoeba; \
	    fi \
	  fi \
	done



###############################################################################
## multilingual models from an entire subset
## (all languages in that subset on both sides)
###############################################################################

## training:
## set FIT_DATA_SIZE to biggest one in subset but at least 10000
## set of languages is directly taken from the markdown page at github
tatoeba-multilingual-subset-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  tatoeba-job; )


## TODO: take this target away?
## just start without making data first ...
tatoeba-multilingual-startjob-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  all-job-tatoeba; )


## evaluate all language pairs in both directions
tatoeba-multilingual-evalsubset-%: tatoeba-%.md
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  ${MAKE} SRCLANGS="$$l" TRGLANGS="$$l" \
		  LANGPAIRSTR=${<:.md=} tatoeba-multilingual-eval tatoeba-sublang-eval )


## make a release package to distribute
tatoeba-multilingual-distsubset-%: tatoeba-%.md tatoeba-trainsize-%.txt
	( l="${shell grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr '-' "\n" | sort -u  | tr "\n" ' ' | sed 's/ *$$//'}"; \
	  s=${shell sort -k2,2nr $(word 2,$^) | head -1 | cut -f2 -d' '}; \
	  if [ $$s -lt 10000 ]; then s=10000; fi; \
	  ${MAKE} SRCLANGS="$$l" \
		  TRGLANGS="$$l" \
		  FIT_DATA_SIZE=$$s \
		  LANGPAIRSTR=${<:.md=} \
	  release-tatoeba; )


## print all data sizes in this set
## --> used to set the max data size per lang-pair
##     for under/over-sampling (FIT_DATA_SIZE)
tatoeba-trainsize-%.txt: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  echo -n "$$l " >> $@; \
	  ${GZCAT} ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$l.clean.$$s.gz | wc -l >> $@; \
	done






## fix names of eval/test files

# NEWMODELS = ${wildcard models/*/*_20*zip}
# EVAL_NEWMODELS = $(patsubst %.zip,%.eval.txt,${NEWMODELS})
# TEST_NEWMODELS = $(patsubst %.zip,%.test.txt,${NEWMODELS})

# fix-eval-files: ${EVAL_NEWMODELS} ${TEST_NEWMODELS}

# ${EVAL_NEWMODELS} ${TEST_NEWMODELS}:
# 	@( f=`echo $@ | sed 's/\_\(....\-..\-..\.[a-z]*.txt\)/-\1/'`; \
# 	  if [ -e $$f ]; then \
# 	    echo "mv $$f $@"; \
# 	    mv $$f $@; \
# 	  else \
# 	    echo "$$f does not exist"; \
# 	  fi )

# fix-refresh-readmes:
# 	for s in ell eus hbs ita lit; do \
# 	  make MODELTYPE=transformer-big SRCLANGS=$$s TRGLANGS=eng refresh-release-readme-bt-tatoeba; \
# 	done
# 	for t in ara bul hun lit mlt ron tur; do \
# 	  make MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS=$$t refresh-release-readme-bt-tatoeba; \
# 	done
