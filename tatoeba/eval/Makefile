#
# evaluate released Tatoeba MT models
# with existing benchmarks (collected in OPUS-MT-testsets)
#
#
#
# comet-score:
#   on puhti: module load pytorch && comet-score
#   on mahti: module load python-data && comet-score



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


MODEL_STORAGE     := https://object.pouta.csc.fi/Tatoeba-MT-models
ifndef MODEL_DISTS
ifneq ($(wildcard models.missing),)
  MODEL_DISTS     := $(shell cat models.missing)
else
  MODEL_DISTS     := ${shell ${WGET} -q -O - ${MODEL_STORAGE}/index.txt | grep '.zip$$' | grep -v '.eval.zip$$'}
endif
endif

MODEL_DIST         = ${firstword ${MODEL_DISTS}}
MODEL              = ${MODEL_DIST:.zip=}
MODEL_LANGPAIR     = ${firstword ${subst /, ,${MODEL_DIST}}}
MODEL_URL          = ${MODEL_STORAGE}/${MODEL_DIST}
MODEL_EVAL_URL     = ${MODEL_URL:.zip=.eval.zip}

## directory with all test sets (submodule OPUS-MT-testsets)
TESTSET_HOME   := ${REPOHOME}OPUS-MT-testsets/testsets
TESTSET_INDEX  := ${REPOHOME}OPUS-MT-testsets/index.txt

## work directory (for the temporary models)
WORK_HOME      = ${PWD}
WORK_DIR       = ${WORK_HOME}/${MODEL}

## model directory (for test results)
## model score file and zipfile with evaluation results
# MODEL_HOME     = ${REPOHOME}models-tatoeba
MODEL_HOME      = ${REPOHOME}tatoeba/models
MODEL_DIR       = ${MODEL_HOME}/${MODEL}
MODEL_SCORES    = ${MODEL_DIR}.scores.txt
MODEL_EVALZIP   = ${MODEL_DIR}.eval.zip
LEADERBOARD_DIR = ${REPOHOME}scores


MODEL_BLEUSCORES    = ${MODEL_DIR}.bleu-scores.txt
MODEL_CHRFSCORES    = ${MODEL_DIR}.chrf-scores.txt
MODEL_COMETSCORES   = ${MODEL_DIR}.comet-scores.txt


## fix individual score files for all modesl in the index!

ALL_MODEL_BLEUSCORES = ${patsubst %.zip,%.bleu-scores,${MODEL_DISTS}}
ALL_MODEL_CHRFSCORES = ${patsubst %.zip,%.chrf-scores,${MODEL_DISTS}}

all-individual-scores: ${ALL_MODEL_BLEUSCORES} ${ALL_MODEL_CHRFSCORES}

${ALL_MODEL_BLEUSCORES}:
	-${MAKE} MODEL_DISTS=${@:.bleu-scores=.zip} individual-scores
#	-${MAKE} MODEL_DISTS=${@:.bleu-scores=.zip} ${MODEL_HOME}/$@.txt

${ALL_MODEL_CHRFSCORES}:
	-${MAKE} MODEL_DISTS=${@:.chrf-scores=.zip} ${MODEL_HOME}/$@.txt



## MODEL_NOTEVALS ... all released models that do not have an evaluation file yet
## MODEL_LOCAL ...... all model packages in the local release dir
##
## NEW: don't set those variables by default as this slows down other makefile calls


# MODEL_NOTEVALS    := $(shell ${WGET} -q -O - ${MODEL_STORAGE}/index.txt | grep '.zip$$' | \
			sed 's/\.eval\.zip/.zip/' | sort | uniq -c | sed 's/^ *//' | grep '^1 ' | cut -f2 -d' ')
# MODEL_LOCAL       := $(patsubst ${MODEL_HOME}/%,%,$(filter-out %.eval.zip,$(shell find ${MODEL_HOME}/ -type f -name '*.zip')))



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


print-model-list:
	@echo "${MODEL_DISTS}"
	@echo "number of models: ${words ${MODEL_DISTS}}"

#-------------------------------------------------
## phony targets to evaluate only new models
## or only models that exist locally
## (no dependency on testset index)
#-------------------------------------------------

## check models that still need to be evaluated
## (i.e. *.eval.zip does not exist)

.PNONY: print-eval-needed
print-eval-needed:
	@echo "$(shell ${WGET} -q -O - ${MODEL_STORAGE}/index.txt | grep '.zip$$' | \
		sed 's/\.eval\.zip/.zip/' | sort | uniq -c | sed 's/^ *//' | grep '^1 ' | cut -f2 -d' ')" | \
	tr ' ' "\n"

.PNONY: eval-new eval-new-models
eval-new eval-new-models:
	${MAKE} MODEL_DISTS="$(shell ${WGET} -q -O - ${MODEL_STORAGE}/index.txt | grep '.zip$$' | \
		sed 's/\.eval\.zip/.zip/' | sort | uniq -c | sed 's/^ *//' | grep '^1 ' | cut -f2 -d' ')" all


.PHONY: print-eval-local
print-eval-local:
	@echo "$(patsubst ${MODEL_HOME}/%,%,$(filter-out %.eval.zip,$(shell find ${MODEL_HOME}/ -type f -name '*.zip')))" | tr ' ' "\n"

.PHONY: eval-local
eval-local:
	${MAKE} MODEL_DISTS="$(patsubst ${MODEL_HOME}/%,%,$(filter-out %.eval.zip,$(shell find ${MODEL_HOME}/ -type f -name '*.zip')))" all

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
	-${MAKE} MODEL_DISTS=${patsubst ${MODEL_HOME}/%.eval.zip,%.zip,$@} eval-model


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
	  cd ${MODEL_DIR} && zip ${MODEL_EVALZIP} *.*; \
	  rm -f ${MODEL_DIR}/*.eval; \
	  rm -f ${MODEL_DIR}/*.compare; \
	  rm -f ${MODEL_DIR}/*.comet; \
	  rm -f ${MODEL_DIR}.done; \
	  rmdir ${MODEL_DIR}; \
	fi

#	  cd ${MODEL_DIR} && zip ${MODEL_EVALZIP} *.eval *.compare;


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
fetch: ${WORK_DIR}/model/decoder.yml ${MODEL_DIR}


## prepare the model evaluation file directory
## fetch already existing evaluations
${MODEL_DIR}:
	mkdir -p $@
	-if [ -e ${MODEL_EVALZIP} ]; then \
	  cd ${MODEL_DIR}; \
	  unzip -n ${MODEL_EVALZIP}; \
	fi
	-${WGET} -q -O ${MODEL_DIR}/eval.zip ${MODEL_EVAL_URL}
	-if [ -e ${MODEL_DIR}/eval.zip ]; then \
	  cd ${MODEL_DIR}; \
	  unzip -n eval.zip; \
	  rm -f eval.zip; \
	fi


localmodel:
	if [ -e ${MODEL_HOME}/${MODEL_DIST} ]; then \
	  echo "local model found: ${MODEL_HOME}/${MODEL_DIST}"; \
	else \
	  echo "${MODEL_URL}"; \
	fi

## fetch the model (either from local release dir or from the model storage)
${WORK_DIR}/model/decoder.yml:
	mkdir -p ${dir $@}
	if [ -e ${MODEL_HOME}/${MODEL_DIST} ]; then \
	  cp ${MODEL_HOME}/${MODEL_DIST} ${dir $@}model.zip; \
	else \
	  ${WGET} -q -O ${dir $@}model.zip ${MODEL_URL}; \
	fi
	unzip -d ${dir $@} ${dir $@}model.zip
## fix an old problem with the pre-process script
	mv ${dir $@}preprocess.sh ${dir $@}preprocess-old.sh
	sed -e 's#perl -C -pe.*$$#perl -C -pe  "s/(?!\\n)\\p{C}/ /g;" |#' \
	    -e 's#/projappl/project_2001569#$${HOME}/projappl#' \
	    -e 's#SPMENCODE=.*$$#SPMENCODE=`which spm_encode || echo "$${PWD}/tools/marian-dev/build/spm_encode"`#' \
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



MODEL_EVAL_MISSING = $(patsubst %,%.missing,${ALL_LANGPAIRS})
METRICS = bleu chrf comet

.PHONY: find-missing
find-missing: models.missing
models.missing: ${MODEL_EVAL_MISSING}
	find . -name '*.missing' | xargs cat | cut -f1 | sort -u > $@

${MODEL_EVAL_MISSING}:
	if [ -e ${LEADERBOARD_DIR}/$(@:.missing=)/model-list.txt ]; then \
	  for m in `grep 'Tatoeba-MT-models' ${LEADERBOARD_DIR}/$(@:.missing=)/model-list.txt`; do\
	    for t in $(sort $(basename $(filter-out %.labels,$(notdir $(wildcard ${TESTSET_HOME}/$(@:.missing=)/*.*))))); do \
	      for b in ${METRICS}; do \
	        if [ ! -f ${LEADERBOARD_DIR}/$(@:.missing=)/$$t/$$b-scores.txt ]; then \
	          echo "$$m	$$t	$$b" | sed 's#^.*MT-models/##' >> $@; \
	        elif [ `grep "$$m" ${LEADERBOARD_DIR}/$(@:.missing=)/$$t/$$b-scores.txt | wc -l` -eq 0 ]; then \
	          echo "$$m	$$t	$$b" | sed 's#^.*MT-models/##' >> $@; \
	        fi \
	      done \
	    done \
	  done \
	fi

#	  for t in `find ${LEADERBOARD_DIR}/$$l -mindepth 1 -maxdepth 1 -type d -printf " %f"`; do \


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
	  ${MAKE} TESTSET=$$t eval comet-eval; \
	done




## make score files for individual metrics
## (more convenient to read and extend with new metrics)
## TODO: make them by default and create proper dependencies

individual-scores: ${MODEL_BLEUSCORES} ${MODEL_CHRFSCORES} ${MODEL_COMETSCORES}

${MODEL_BLEUSCORES}: ${MODEL_SCORES}
	cut -f1,2,4 ${MODEL_SCORES} | \
	sed 's/\(news.*[0-9][0-9][0-9][0-9]\)\-[a-z][a-z][a-z][a-z]	/\1	/' |\
	sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	rev | uniq -f1 | rev > $@


${MODEL_CHRFSCORES}: ${MODEL_SCORES}
	cut -f1,2,3 ${MODEL_SCORES} |\
	sed 's/\(news.*[0-9][0-9][0-9][0-9]\)\-[a-z][a-z][a-z][a-z]	/\1	/' |\
	sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	rev | uniq -f1 | rev > $@


EVAL_FILES       = ${wildcard ${MODEL_DIR}/*.eval}
COMET_EVAL_FILES = ${wildcard ${MODEL_DIR}/*.comet}
${MODEL_COMETSCORES}: ${COMET_EVAL_FILES}
	if [ -d ${MODEL_DIR} ]; then \
	  mkdir -p $(dir $@); \
	  grep -H COMET ${MODEL_DIR}/*eval | sort                        > $@.comet; \
	  cut -f1 -d: $@.comet | rev | cut -f2 -d. | rev                 > $@.langs; \
	  cut -f1 -d: $@.comet | rev | cut -f1 -d/ | cut -f3- -d. | rev  > $@.testsets; \
	  cat $@.comet | rev | cut -f1 -d' ' | rev                       > $@.comet-scores; \
	  paste $@.langs $@.testsets $@.comet-scores                     >> $@; \
	  cat $@ |\
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  rev | uniq -f1 | rev                                           > $@.sorted; \
	  mv -f $@.sorted $@; \
	  rm -f $@.comet $@.langs $@.testsets $@.comet-scores; \
	fi

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


ifneq (${wildcard ${WORK_DIR}}/model/preprocess.sh,)

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



## make the comet score

.PHONY: comet
comet: 
	${MAKE} fetch
	${MAKE} comet-langpairs
	${MAKE} ${MODEL_COMETSCORES}


comet-score-file: ${MODEL_COMETSCORES}
comet-register-scores: ${MODEL_COMETSCORES:.txt=.registered}
bleu-register-scores: ${MODEL_BLEUSCORES:.txt=.registered}
chrf-register-scores: ${MODEL_CHRFSCORES:.txt=.registered}



.PHONY: comet-langpairs
comet-langpairs:
	for l in ${LANGPAIRS}; do \
	  ${MAKE} LANGPAIR=$$l comet-testsets; \
	done

.PHONY: comet-testsets
comet-testsets:
	for t in ${TESTSETS}; do \
	  ${MAKE} TESTSET=$$t comet-eval; \
	done

.PHONY: comet-eval
comet-eval: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet

ifneq (${GPU_AVAILABLE},1)
  COMET_PARAM += --gpus 0
endif

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval
	mkdir -p ${dir $@}
	sed -n '1~4p' $(<:.eval=.compare) > $@.src
	sed -n '2~4p' $(<:.eval=.compare) > $@.ref
	sed -n '3~4p' $(<:.eval=.compare) > $@.hyp
	${LOAD_COMET_ENV} comet-score ${COMET_PARAM} \
		-s $@.src -r $@.ref -t $@.hyp | cut -f2,3 > $@
	tail -1 $@ | sed 's/^.*score:/COMET+default =/' >> $<
	rm -f $@.src $@.ref $@.hyp


#-------------------------------------------------
# collect all scores in a file
#-------------------------------------------------
#
# updating scores for models that already have some scores registered
# - need to fetch eval file package
# - avoid re-running things that are already done
# - ingest the new evaluation scores
#

.PHONY: scores
scores: ${MODEL_SCORES}

${MODEL_SCORES}: ${TESTSET_INDEX} ${MODEL_COMETSCORES}
	-if [ ! -e $@ ]; then \
	  mkdir -p $(dir $@); \
	  wget -qq -O $@ ${MODEL_STORAGE}/${MODEL}.scores.txt; \
	fi
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
		$@.urls $@.nrlines $@.nrwords                     >> $@; \
	  cat $@ | \
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  rev | uniq -f5 | rev | sort -u                           > $@.sorted; \
	  mv -f $@.sorted $@; \
	  rm -f $@.bleu $@.chrf $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords; \
	fi
	${MAKE} individual-scores



##-------------------------------------------------------------------
## uodate leader boards with score from score files
## SCOREFILES = all score files in the model directories
## SCOREFILES_DONE = a flag that shows that the scores are registered
##-------------------------------------------------------------------

SCOREFILES := ${wildcard ${MODEL_HOME}/*/*.scores.txt}
SCOREFILES_DONE = ${SCOREFILES:.txt=.registered}
SCOREFILE_DONE = ${MODEL_SCORES:.txt=.registered}

BLEUSCOREFILE_DONE = ${MODEL_BLEUSCORES:.txt=.registered}
CHRFSCOREFILE_DONE = ${MODEL_CHRFSCORES:.txt=.registered}
COMETSCOREFILE_DONE = ${MODEL_COMETSCORES:.txt=.registered}


## update all leader boards with all scores
update-leaderboards: ${SCOREFILES_DONE}
	${MAKE} sort-leaderboards

## register the scores for the current model
## (scores will be added to some temporary files sorted by language pair and benchmark)
## NOTE: this removes langIDs from newstest sets to avoid confusion and duplicates

# register-scores: ${SCOREFILE_DONE}
# register-scores: ${BLEUSCOREFILE_DONE} ${CHRFSCOREFILE_DONE} ${COMETSCOREFILE_DONE}
register-scores: ${SCOREFILE_DONE} ${COMETSCOREFILE_DONE}


${SCOREFILES_DONE}: %.registered: %.txt
	@echo "register scores from ${patsubst ${MODEL_HOME}/%,%,$<}"
	@cat $< | perl -e 'while (<>){ @a=split(/\t/); $$a[1]=~s/^(news.*)\-[a-z]{4}/$$1/; system "mkdir -p ${LEADERBOARD_DIR}/$$a[0]/$$a[1]"; open B,">>${LEADERBOARD_DIR}/$$a[0]/$$a[1]/bleu-scores.$(subst /,.,${patsubst ${MODEL_HOME}/%,%,$<}).unsorted.txt"; open C,">>${LEADERBOARD_DIR}/$$a[0]/$$a[1]/chrf-scores.$(subst /,.,${patsubst ${MODEL_HOME}/%,%,$<}).unsorted.txt"; print B "$$a[3]\t$$a[4]\n"; print C "$$a[2]\t$$a[4]\n"; close B; close C; }'
	touch $@

${MODEL_DIR}.%-scores.registered: ${MODEL_DIR}.%-scores.txt
	@echo "register scores from ${patsubst ${MODEL_HOME}/%,%,$<}"
	@cat $< | perl -e 'while (<>){ chomp; @a=split(/\t/);system "mkdir -p ${LEADERBOARD_DIR}/$$a[0]/$$a[1]"; open C,">>${LEADERBOARD_DIR}/$$a[0]/$$a[1]/$(patsubst ${MODEL_DIR}.%-scores.txt,%-scores,$<).$(subst /,.,${patsubst ${MODEL_HOME}/%,%,$<}).unsorted.txt"; print C "$$a[2]\t${MODEL_URL}\n"; close C; }'
	touch $@

##-------------------------------------------------------------------
## UPDATE_SCORE_DIRS = directory that contains new scores
## LEADERBOARDS_BLEU = list of BLEU leader boards that need to be sorted
## LEADERBOARDS_BLEU = list of chr-F leader boards that need to be sorted
##-------------------------------------------------------------------

UPDATE_SCORE_DIRS  := $(sort $(dir ${wildcard ${LEADERBOARD_DIR}/*/*/*.unsorted.txt}))
LEADERBOARDS_BLEU  := $(patsubst %,%bleu-scores.txt,${UPDATE_SCORE_DIRS})
LEADERBOARDS_CHRF  := $(patsubst %,%chrf-scores.txt,${UPDATE_SCORE_DIRS})
LEADERBOARDS_COMET := $(patsubst %,%comet-scores.txt,${UPDATE_SCORE_DIRS})

## sort all leaderboards for which we have new unsorted scores
.PHONY: sort-leaderboards sort-bleu-leaderboards sort-chrf-leaderboards sort-comet-leaderboards
sort-leaderboards: ${LEADERBOARDS_BLEU} ${LEADERBOARDS_CHRF} ${LEADERBOARDS_COMET}
sort-bleu-leaderboards:  ${LEADERBOARDS_BLEU}
sort-chrf-leaderboards:  ${LEADERBOARDS_CHRF}
sort-comet-leaderboards:  ${LEADERBOARDS_COMET}

${LEADERBOARDS_BLEU}: ${UPDATE_SCORE_DIRS}
	@echo "sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"
	@cat $(dir $@)bleu-scores*.txt | grep '^[0-9]' | sort -k1,1nr | uniq -f1 > $@.sorted
	@rm -f $(dir $@)bleu-scores*.txt
	@mv $@.sorted $@

${LEADERBOARDS_CHRF}: ${UPDATE_SCORE_DIRS}
	@echo "sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"
	@cat $(dir $@)chrf-scores*.txt | grep '^[0-9]' | sort -k1,1nr | uniq -f1 > $@.sorted
	@rm -f $(dir $@)chrf-scores*.txt
	@mv $@.sorted $@

${LEADERBOARDS_COMET}: ${UPDATE_SCORE_DIRS}
	@echo "sort ${patsubst ${LEADERBOARD_DIR}/%,%,$@}"
	@cat $(dir $@)comet-scores*.txt | grep '^[0-9]' | sort -k1,1nr | uniq -f1 > $@.sorted
	@rm -f $(dir $@)comet-scores*.txt
	@mv $@.sorted $@

