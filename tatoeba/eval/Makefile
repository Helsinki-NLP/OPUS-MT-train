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

GPUJOB_HPC_MEM = 20g


MODEL_STORAGE  := https://object.pouta.csc.fi/Tatoeba-MT-models
MODEL_DISTS    := ${shell ${WGET} -q -O - ${MODEL_STORAGE}/index.txt | grep '.zip$$' | grep -v '.eval.zip$$'}
MODEL_DIST     = ${firstword ${MODEL_DISTS}}
MODEL          = ${MODEL_DIST:.zip=}
MODEL_LANGPAIR = ${firstword ${subst /, ,${MODEL_DIST}}}
MODEL_URL      = ${MODEL_STORAGE}/${MODEL_DIST}

## directory with all test sets (submodule OPUS-MT-testsets)
TESTSET_HOME   := ${REPOHOME}OPUS-MT-testsets/testsets
TESTSET_INDEX  := ${REPOHOME}OPUS-MT-testsets/index.txt

## work directory (for the temporary models)
WORK_HOME      = ${PWD}
WORK_DIR       = ${WORK_HOME}/${MODEL}

## model directory (for test results)
## model score file and zipfile with evaluation results
# MODEL_HOME     = ${REPOHOME}models-tatoeba
MODEL_HOME     = ${REPOHOME}tatoeba/models
MODEL_DIR      = ${MODEL_HOME}/${MODEL}
MODEL_SCORES   = ${MODEL_DIR}.scores.txt
MODEL_EVALZIP  = ${MODEL_DIR}.eval.zip

LEADERBOARD_DIR = ${REPOHOME}scores

## all zip files with benchmark results
MODEL_EVALZIPS := ${patsubst %.zip,${MODEL_HOME}/%.eval.zip,${MODEL_DISTS}}

#-------------------------------------------------
## make all evaluation zip-files
#-------------------------------------------------
.PHONY: all
all: ${MODEL_EVALZIPS}


## test: make the first evaluation zip-file
.PHONY: first
first: $(firstword ${MODEL_EVALZIPS})


## check models that still need to be evaluated
## (i.e. *.eval.zip does not exist)
MODEL_EVALCHECK := ${patsubst %.zip,${MODEL_HOME}/%.eval.check,${MODEL_DISTS}}

.PNONY: print-eval-needed ${MODEL_EVALCHECK}
print-eval-needed: ${MODEL_EVALCHECK}
${MODEL_EVALCHECK}:
	@if [ ! -e $(@:.check=.zip) ]; then \
	  echo "need to make $(@:.check=.zip)"; \
	fi

#-------------------------------------------------
## phony targets to evaluate only new models
## or only models that exist locally
## (no dependency on testset index)
#-------------------------------------------------
MODEL_EVALNEW := ${patsubst %.zip,${MODEL_HOME}/%.eval.new,${MODEL_DISTS}}

.PNONY: eval-new eval-new-models ${MODEL_EVALNEW}
eval-new eval-new-models: ${MODEL_EVALNEW}
${MODEL_EVALNEW}:
	@if [ ! -e $(@:.new=.zip) ]; then \
	  ${MAKE} MODEL_DIST=${patsubst ${MODEL_HOME}/%.eval.new,%.zip,$@} eval-model; \
	fi


## filter out all models that exist locally
MODEL_LOCAL := ${filter ${patsubst %.zip,%.eval.new,$(wildcard ${MODEL_HOME}/*/*.zip)},${MODEL_EVALNEW}}
eval-local: ${MODEL_LOCAL}
print-eval-local:
	@echo ${MODEL_LOCAL} | tr ' ' "\n"

#-------------------------------------------------
## create zip-files with all evaluation files
## --> need to add scores if the TESTSET_INDEX has changed!
## if the zip file already exists: unpack first to avoid re-doing things
## TODO: should also fetch from ObjectStorage if it exists there!
#-------------------------------------------------
${MODEL_EVALZIPS}: ${TESTSET_INDEX}
	if [ -e $@ ]; then \
	  mkdir -p ${@:.eval.zip=}; \
	  unzip -d ${@:.eval.zip=} $@; \
	fi
	${MAKE} MODEL_DIST=${patsubst ${MODEL_HOME}/%.eval.zip,%.zip,$@} eval-model


#-------------------------------------------------
## evaluate the model with all benchmarks available
## register the scores and update the leaderboard
## final cleanup
#-------------------------------------------------
.PHONY: eval-model
eval-model: ${MODEL_SCORES}
	if [ -e $< ]; then \
	  ${MAKE} register-scores; \
	  ${MAKE} sort-leaderboards; \
	fi
	if [ -d ${MODEL_DIR} ]; then \
	  cd ${MODEL_DIR} && zip ${MODEL_EVALZIP} *.eval *.compare; \
	  rm -f ${MODEL_DIR}/*.eval; \
	  rm -f ${MODEL_DIR}/*.compare; \
	  rm -f ${MODEL_DIR}.done; \
	  rmdir ${MODEL_DIR}; \
	fi


## temporary directory with all benchmark results
${MODEL_DIR}.done:
	${MAKE} fetch
	${MAKE} eval-langpairs
	${MAKE} cleanup
	-touch $@

## cleanup some additional workfiles
.PHONY: cleanup
cleanup:
	rm -f ${WORK_DIR}/*.*
	rm -f ${WORK_DIR}/model/*
	rmdir ${WORK_DIR}/model
	rmdir ${WORK_DIR}
	rmdir ${WORK_HOME}/${MODEL_LANGPAIR}

#-------------------------------------------------
# fetch model and get supported languages
#-------------------------------------------------

## fetch translation model
.PHONY: fetch
fetch: ${WORK_DIR}/model/decoder.yml

${WORK_DIR}/model/decoder.yml:
	mkdir -p ${dir $@}
	${WGET} -q -O ${dir $@}model.zip ${MODEL_URL}
	unzip -d ${dir $@} ${dir $@}model.zip
## fix an old problem with the pre-process script
	mv ${dir $@}preprocess.sh ${dir $@}preprocess-old.sh
	sed 's#perl -C -pe.*$$#perl -C -pe  "s/(?!\\n)\\p{C}/ /g;" |#' \
		< ${dir $@}preprocess-old.sh > ${dir $@}preprocess.sh
	chmod +x ${dir $@}preprocess.sh


#-------------------------------------------------
# get supported source and target languages
#-------------------------------------------------
MODELINFO = ${WORK_DIR}/model/README.md
ifneq (${wildcard ${MODELINFO}},)
  SRCLANGS = ${shell grep '\* source language(s)' ${MODELINFO} | cut -f2 -d: | xargs}
  TRGLANGS = ${shell grep '\* valid language labels' ${MODELINFO} | cut -f2 -d: | tr '<>' '  ' | xargs}
ifeq (${words ${TRGLANGS}},0)
  TRGLANGS = ${shell grep '\* target language(s)' ${MODELINFO} | cut -f2 -d: | xargs}
endif
endif



#-------------------------------------------------
# all language pairs that the model supports
# find all test sets that we need to consider
#-------------------------------------------------
MODEL_LANGPAIRS = ${MODEL_LANGPAIR} \
	${shell for s in ${SRCLANGS}; do for t in ${TRGLANGS}; do echo "$$s-$$t"; done done}

## get language pairs for which we have test sets
ALL_LANGPAIRS := $(notdir ${wildcard ${TESTSET_HOME}/*})
LANGPAIRS     = ${sort $(filter ${ALL_LANGPAIRS},${MODEL_LANGPAIRS})}
LANGPAIR      = ${firstword ${LANGPAIRS}}
LANGPAIRSTR   = ${LANGPAIR}
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


## more than one target language
## --> need target language labels
ifneq (${words ${TRGLANGS}},1)
  USE_TARGET_LABELS = 1
else
  USE_TARGET_LABELS = 0
endif

## double-check whether the preprocessing script
## requires both language IDs or not
ifeq (${shell grep 'source-langid target-langid' ${WORK_DIR}/model/preprocess.sh 2>/dev/null | wc -l},1)
  USE_BOTH_LANGIDS = 1
endif

## take care of different calls to the pre-processing script
ifeq (${USE_BOTH_LANGIDS},1)
  PREPROCESS = ${WORK_DIR}/model/preprocess.sh ${SRC} ${TRG} ${WORK_DIR}/model/source.spm
else
  PREPROCESS = ${WORK_DIR}/model/preprocess.sh ${SRC} ${WORK_DIR}/model/source.spm
endif


${WORK_DIR}/${TESTSET}.${LANGPAIR}.input: ${TESTSET_DIR}/${TESTSET}.${SRC}
	${PREPROCESS} < $< > $@
## check whether we need to replace the target language labels
ifeq (${USE_TARGET_LABELS},1)
ifneq (${wildcard ${TESTSET_DIR}/${TESTSET}.${TRG}.labels},)
	cut -f2- -d' ' $@ > $@.tmp1
	sed 's/^/>>/;s/$$/<</' < ${TESTSET_DIR}/${TESTSET}.${TRG}.labels > $@.tmp2
	paste -d' ' $@.tmp2 $@.tmp1 > $@
	rm -f $@.tmp2 $@.tmp1
endif
endif


#-------------------------------------------------
# create output file (translation)
#-------------------------------------------------

.PHONY: output
output: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output

${WORK_DIR}/${TESTSET}.${LANGPAIR}.output: ${WORK_DIR}/${TESTSET}.${LANGPAIR}.input
	if [ -e $< ]; then \
	  if [ -s $< ]; then \
	    ${LOAD_ENV} && ${MARIAN_DECODER} -i $< \
		-c ${WORK_DIR}/model/decoder.yml \
		${MARIAN_DECODER_FLAGS} |\
	    sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' > $@; \
	  fi \
	fi


#-------------------------------------------------
# evaluation
#-------------------------------------------------

.PHONY: eval
eval: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval

## adjust tokenisation to non-space-separated languages
## TODO: is it correct to simply use 'zh' even for jpn or should we use 'intl'?
ifneq ($(filter cmn jpn yue zho,${TRG}),)
  SACREBLEU_PARAMS = --tokenize zh
endif

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval: 
	${MAKE} ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output
	if [ -e ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output ]; then \
	  if [ -s ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output ]; then \
		mkdir -p ${dir $@}; \
		cat ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output | \
		sacrebleu -f text ${SACREBLEU_PARAMS} ${TESTSET_DIR}/${TESTSET}.${TRG} > $@; \
		cat ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output | \
		sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 ${TESTSET_DIR}/${TESTSET}.${TRG} |\
		sed 's/\([0-9][0-9]\)\.\([0-9]*\)$$/0.\1\2/' >> $@; \
		paste -d "\n" \
			${TESTSET_DIR}/${TESTSET}.${SRC} \
			${TESTSET_DIR}/${TESTSET}.${TRG} \
			${WORK_DIR}/${TESTSET}.${LANGPAIR}.output |\
		sed 	-e "s/&apos;/'/g" \
			-e 's/&quot;/"/g' \
			-e 's/&lt;/</g' \
			-e 's/&gt;/>/g' \
			-e 's/&amp;/&/g' |\
		sed 'n;n;G;' > ${@:.eval=.compare}; \
	  fi \
	fi


#-------------------------------------------------
# collect all scores in a file
#-------------------------------------------------

.PHONY: scores
scores: ${MODEL_SCORES}

${MODEL_SCORES}: ${TESTSET_INDEX}
	${MAKE} ${MODEL_DIR}.done
	if [ -d ${MODEL_DIR} ]; then \
	  grep -H BLEU ${MODEL_DIR}/*eval | sort                   > $@.bleu; \
	  grep -H chrF ${MODEL_DIR}/*eval | sort                   > $@.chrf; \
	  cut -f1 -d: $@.bleu | rev | cut -f2 -d. | rev            > $@.langs; \
	  cut -f1 -d: $@.bleu | rev | cut -f1 -d/ | cut -f3- -d. | rev  > $@.testsets; \
	  cat $@.chrf | rev | cut -f1 -d' ' | rev                  > $@.chrf-scores; \
	  cut -f2 -d= $@.bleu | cut -f2 -d' '                      > $@.bleu-scores; \
	  cut -f1 -d: $@.bleu | rev | cut -f2,3 -d/ | \
	  rev | sed 's#^#${MODEL_STORAGE}/#' | sed 's/$$/.zip/'    > $@.urls; \
	  cut -f1 -d: $@.bleu | sed 's/.eval$$/.compare/' | \
	  xargs wc -l |  grep -v '[0-9] total' | \
	  perl -pe '$$_/=4;print "\n"' | tail -n +2                > $@.nrlines; \
	  cat $@.bleu | rev | cut -f1 -d' ' | rev | cut -f1 -d')'  > $@.nrwords; \
	  paste $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords                    > $@; \
	  rm -f $@.bleu $@.chrf $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords; \
	fi



##-------------------------------------------------------------------
## uodate leader boards with score from score files
## SCOREFILES = all score files in the model directories
## SCOREFILES_DONE = a flag that shows that the scores are registered
##-------------------------------------------------------------------

SCOREFILES := ${wildcard ${MODEL_HOME}/*/*.scores.txt}
SCOREFILES_DONE = ${SCOREFILES:.txt=.registered}
SCOREFILE_DONE = ${MODEL_SCORES:.txt=.registered}

## update all leader boards with all scores
update-leaderboards: ${SCOREFILES_DONE}
	${MAKE} sort-leaderboards

## register the scores for the current model
## (scores will be added to some temporary files sorted by language pair and benchmark)
## NOTE: this removes langIDs from newstest sets to avoid confusion and duplicates
register-scores: ${SCOREFILE_DONE}

${SCOREFILES_DONE}: %.registered: %.txt
	@echo "register scores from ${patsubst ${MODEL_HOME}/%,%,$<}"
	@cat $< | perl -e 'while (<>){ @a=split(/\t/); $$a[1]=~s/^(news.*)\-[a-z]{4}/$$1/; system "mkdir -p ${LEADERBOARD_DIR}/$$a[0]/$$a[1]"; open B,">>${LEADERBOARD_DIR}/$$a[0]/$$a[1]/bleu-scores.$(subst /,.,${patsubst ${MODEL_HOME}/%,%,$<}).unsorted.txt"; open C,">>${LEADERBOARD_DIR}/$$a[0]/$$a[1]/chrf-scores.$(subst /,.,${patsubst ${MODEL_HOME}/%,%,$<}).unsorted.txt"; print B "$$a[3]\t$$a[4]\n"; print C "$$a[2]\t$$a[4]\n"; close B; close C; }'
	touch $@


##-------------------------------------------------------------------
## UPDATE_SCORE_DIRS = directory that contains new scores
## LEADERBOARDS_BLEU = list of BLEU leader boards that need to be sorted
## LEADERBOARDS_BLEU = list of chr-F leader boards that need to be sorted
##-------------------------------------------------------------------

UPDATE_SCORE_DIRS := $(sort $(dir ${wildcard ${LEADERBOARD_DIR}/*/*/*.unsorted.txt}))
LEADERBOARDS_BLEU := $(patsubst %,%bleu-scores.txt,${UPDATE_SCORE_DIRS})
LEADERBOARDS_CHRF := $(patsubst %,%chrf-scores.txt,${UPDATE_SCORE_DIRS})

## sort all leaderboards for which we have new unsorted scores
.PHONY: sort-leaderboards
sort-leaderboards: ${LEADERBOARDS_BLEU} ${LEADERBOARDS_CHRF}

${LEADERBOARDS_BLEU}: ${UPDATE_SCORE_DIRS}
	@echo "sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"
	@cat $(dir $@)bleu-scores*.txt | grep '^[0-9]' | sort -u -k1,1nr > $@.sorted
	@rm -f $(dir $@)bleu-scores*.txt
	@mv $@.sorted $@

${LEADERBOARDS_CHRF}: ${UPDATE_SCORE_DIRS}
	@echo "sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"
	@cat $(dir $@)chrf-scores*.txt | grep '^[0-9]' | sort -u -k1,1nr > $@.sorted
	@rm -f $(dir $@)chrf-scores*.txt
	@mv $@.sorted $@

