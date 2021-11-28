#
# evaluate released Tatoeba MT models
# with existing benchmarks (collected in OPUS-MT-testsets)
#


## set the home directory of the repository
## this is to find the included makefiles
## (important to have a trailing '/')

SHELL    := bash
PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../

include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk


MODEL_STORAGE  := https://object.pouta.csc.fi/Tatoeba-MT-models
MODEL_DISTS    := ${shell wget -q -O - ${MODEL_STORAGE}/index.txt | grep '.zip$$'}
MODEL_DIST     = ${firstword ${MODEL_DISTS}}
MODEL          = ${MODEL_DIST:.zip=}
MODEL_LANGPAIR = ${firstword ${subst /, ,${MODEL_DIST}}}
MODEL_URL      = ${MODEL_STORAGE}/${MODEL_DIST}

## directory with all test sets (submodule OPUS-MT-testsets)
TESTSET_HOME   := ${REPOHOME}OPUS-MT-testsets/testsets

## work directory (for the temporary models)
WORK_HOME      = ${PWD}
WORK_DIR       = ${WORK_HOME}/${MODEL}

## model directory (for test results)
## model score file and zipfile with evaluation results
MODEL_HOME     = ${REPOHOME}models-tatoeba
MODEL_DIR      = ${MODEL_HOME}/${MODEL}
MODEL_SCORES   = ${MODEL_DIR}.scores.txt
MODEL_EVALZIP  = ${MODEL_DIR}.eval.zip

## all zip files with benchmark results
MODEL_EVALZIPS := ${patsubst %.zip,${MODEL_HOME}/%.eval.zip,${MODEL_DISTS}}


## make all evaluation zip-files
.PHONY: all
all: ${MODEL_EVALZIPS}

## test: make the first evaluation zip-file
.PHONY: first
first: $(firstword ${MODEL_EVALZIPS})


## zip-files with all evaluation files
${MODEL_EVALZIPS}:
	${MAKE} MODEL_DIST=${patsubst ${MODEL_HOME}/%.eval.zip,%.zip,$@} eval-model

.PHONY: eval-model
eval-model: ${MODEL_SCORES}
	cd ${MODEL_DIR} && zip ${MODEL_EVALZIP} *.eval *.compare
	rm -f ${MODEL_DIR}/*.eval
	rm -f ${MODEL_DIR}/*.compare
	rmdir ${MODEL_DIR}


## temporary directory with all benchmark results
${MODEL_DIR}:
	${MAKE} fetch
	${MAKE} eval-langpairs
	${MAKE} cleanup

## cleanup some additional workfiles
.PHONY: cleanup
cleanup:
	rm -f ${WORK_DIR}/*.*
	rm -f ${WORK_DIR}/model/*
	rmdir ${WORK_DIR}/model
	rmdir ${WORK_DIR}

#-------------------------------------------------
# fetch model and get supported languages
#-------------------------------------------------

## fetch translation model
.PHONY: fetch
fetch: ${WORK_DIR}/model/decoder.yml

${WORK_DIR}/model/decoder.yml:
	mkdir -p ${dir $@}
	wget -q -O ${dir $@}model.zip ${MODEL_URL}
	unzip -d ${dir $@} ${dir $@}model.zip

## get supported source and target languages
SRCLANGS = ${shell grep 'source language(s)' ${WORK_DIR}/model/README.md 2>/dev/null | cut -f2 -d: | xargs}
TRGLANGS = ${shell grep 'target language(s)' ${WORK_DIR}/model/README.md 2>/dev/null | cut -f2 -d: | xargs}

## more than one target language
## --> need target language labels
ifneq (${words ${TRGLANGS}},1)
  USE_TARGET_LABELS = 1
else
  USE_TARGET_LABELS = 0
endif


## all language pairs that the model supports
MODEL_LANGPAIRS = ${MODEL_LANGPAIR} \
	${shell for s in ${SRCLANGS}; do for t in ${TRGLANGS}; do echo "$$s-$$t"; done done}

## get language pairs for which we have test sets
ALL_LANGPAIRS = $(notdir ${wildcard ${TESTSET_HOME}/*})
LANGPAIRS     = ${sort $(filter ${ALL_LANGPAIRS},${MODEL_LANGPAIRS})}
LANGPAIR      = ${firstword ${LANGPAIRS}}
LANGPAIRSTR   = ${LANGPAIRS}
SRC           = ${firstword ${subst -, ,${LANGPAIR}}}
TRG           = ${lastword ${subst -, ,${LANGPAIR}}}
TESTSET_DIR   = ${TESTSET_HOME}/${LANGPAIR}
TESTSETS      = ${notdir ${basename ${wildcard ${TESTSET_DIR}/*.${SRC}}}}
TESTSET       = ${firstword ${TESTSETS}}


## eval all language pairs
.PHONY: eval-langpairs
eval-langpairs:
	for l in ${LANGPAIRS}; do \
	  ${MAKE} LANGPAIR=$$l eval-testsets; \
	done

## eval all testsets for the current langpair
.PHONY: eval-testsets
eval-testsets:
	for t in ${TESTSETS}; do \
	  ${MAKE} TESTSET=$$t eval; \
	done

#-------------------------------------------------
# create input file for translation
#-------------------------------------------------

.PHONY: input
input: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.input

${WORK_DIR}/${TESTSET}.${LANGPAIR}.input: ${TESTSET_DIR}/${TESTSET}.${SRC}
## check whether we need to specify the target language with labels
ifeq (${USE_TARGET_LABELS},1)
	${WORK_DIR}/model/preprocess.sh \
		${SRC} ${TRG} \
		${WORK_DIR}/model/source.spm \
	< $< > $@
## replace default label if language labels are given
ifneq (${wildcard ${TESTSET_DIR}/${TESTSET}.${TRG}.labels},)
	cut -f2- -d' ' $@ > $@.tmp1
	sed 's/^/>>/;s/$$/<</' < ${TESTSET_DIR}/${TESTSET}.${TRG}.labels > $@.tmp2
	paste -d' ' $@.tmp2 $@.tmp1 > $@
	rm -f $@.tmp2 $@.tmp1
endif
else
	${WORK_DIR}/model/preprocess.sh ${SRC} \
		${WORK_DIR}/model/source.spm \
	< $< > $@
endif


#-------------------------------------------------
# create output file (translation)
#-------------------------------------------------

.PHONY: output
output: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output

${WORK_DIR}/${TESTSET}.${LANGPAIR}.output: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.input
	${LOAD_ENV} && ${MARIAN_DECODER} -i $< \
		-c ${WORK_DIR}/model/decoder.yml \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' > $@


#-------------------------------------------------
# evaluation
#-------------------------------------------------

.PHONY: eval
eval: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval: 
	${MAKE} ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output
	mkdir -p ${dir $@}
	cat ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output | \
	sacrebleu ${TESTSET_DIR}/${TESTSET}.${TRG} > $@
	cat ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output | \
	sacrebleu --metrics=chrf --width=3 ${TESTSET_DIR}/${TESTSET}.${TRG} >> $@
	paste -d "\n" \
		${TESTSET_DIR}/${TESTSET}.${SRC} \
		${TESTSET_DIR}/${TESTSET}.${TRG} \
		${WORK_DIR}/${TESTSET}.${LANGPAIR}.output |\
	sed 	-e "s/&apos;/'/g" \
		-e 's/&quot;/"/g' \
		-e 's/&lt;/</g' \
		-e 's/&gt;/>/g' \
		-e 's/&amp;/&/g' |\
	sed 'n;n;G;' > ${@:.eval=.compare}


#-------------------------------------------------
# collect all scores in a file
#-------------------------------------------------

.PHONY: scores
scores: ${MODEL_SCORES}

${MODEL_SCORES}:
	${MAKE} ${MODEL_DIR}
	grep -H BLEU ${MODEL_DIR}/*eval | sort                   > $@.bleu
	grep -H chrF ${MODEL_DIR}/*eval | sort                   > $@.chrf
	cut -f1 -d: $@.bleu | rev | cut -f2 -d. | rev            > $@.langs
	cut -f1 -d: $@.bleu | rev | cut -f1 -d/ | cut -f3- -d. | rev  > $@.testsets
	cat $@.chrf | rev | cut -f1 -d' ' | rev                  > $@.chrf-scores
	cut -f2 -d= $@.bleu | cut -f2 -d' '                      > $@.bleu-scores
	cut -f1 -d: $@.bleu | rev | cut -f2,3 -d/ | \
	rev | sed 's#^#${MODEL_STORAGE}/#' | sed 's/$$/.zip/'    > $@.urls
	cut -f1 -d: $@.bleu | sed 's/.eval$$/.compare/' | \
	xargs wc -l |  grep -v '[0-9] total' | \
	perl -pe '$$_/=4;print "\n"' | tail -n +2                > $@.nrlines
	cat $@.bleu | rev | cut -f1 -d' ' | rev | cut -f1 -d')'  > $@.nrwords
	paste 	$@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords                    > $@
	rm -f 	$@.bleu $@.chrf $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords
