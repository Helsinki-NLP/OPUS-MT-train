#
# evaluate released Tatoeba MT models
# with existing benchmarks (collected in OPUS-MT-testsets)
#

include Makefile.def

#-------------------------------------------------
## make all evaluation zip-files
#-------------------------------------------------
.PHONY: all
all: ${MODEL_EVALZIPS}


## test: make the first evaluation zip-file
.PHONY: first
first: $(firstword ${MODEL_EVALZIPS})



## do things in reverse order
## (just to start another job)

## convenient function to reverse a list
reverse = $(if $(wordlist 2,2,$(1)),$(call reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)),$(1))

MODEL_EVALZIPS_REVERSE = $(call reverse,${MODEL_EVALZIPS})

all-reverse: ${MODEL_EVALZIPS_REVERSE}

add-new-metrics:
	${MAKE} -j16 METRICS="spbleu chrf++" all

all-comet-reverse:
	make METRICS="comet" all-reverse



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


##-------------------------------------------------
## create zip-files with all evaluation files
## --> need to add scores if the TESTSET_INDEX has changed!
## if the zip file already exists: unpack first to avoid re-doing things
##-------------------------------------------------

${MODEL_EVALZIPS}: ${TESTSET_INDEX}
	@if [ -e $@ ]; then \
	  echo "unpack existing scores"; \
	  mkdir -p ${@:.eval.zip=}; \
	  unzip -d ${@:.eval.zip=} $@; \
	fi
	-${MAKE} MODEL_DISTS=${patsubst ${MODEL_HOME}/%.eval.zip,%.zip,$@} eval-model


##-------------------------------------------------
## evaluate the model with all benchmarks available
## - if a model score file is missing:
##      * fetch model and evaluation files
##      * try to run evaluation again
##      * make model score files again
##-------------------------------------------------

.PHONY: scores model-scores
scores model-scores: ${MODEL_EVAL_SCORES}
	@if [ $(words $(wildcard $^)) -ne $(words $^) ]; then \
	  echo "score files missing ... fetch model and scores!"; \
	  ${MAKE} fetch; \
	  ${MAKE} eval-langpairs; \
	  ${MAKE} cleanup; \
	  ${MAKE} ${MODEL_EVAL_SCORES}; \
	fi

##-------------------------------------------------
## evaluate the model with all benchmarks available
## register the scores and update the leaderboard
## pack evaluation files in a zip file
##-------------------------------------------------

.PHONY: eval-model
eval-model: ${MODEL_EVAL_SCORES}
	${MAKE} model-scores
	if [ -e $< ]; then \
	  ${MAKE} -f Makefile.register register-scores; \
	  ${MAKE} -f Makefile.register sort-leaderboards; \
	fi
	${MAKE} pack-model-scores

.PHONY: pack-model-scores
pack-model-scores:
	if [ -d ${MODEL_DIR} ]; then \
	  cd ${MODEL_DIR} && zip ${MODEL_EVALZIP} *.*; \
	  rm -f ${MODEL_DIR}/*.*; \
	  rmdir ${MODEL_DIR}; \
	fi

## cleanup some additional workfiles
.PHONY: cleanup
cleanup:
	rm -f ${WORK_DIR}/*.*
	rm -f ${WORK_DIR}/model/*
	rmdir ${WORK_DIR}/model
	rmdir ${WORK_DIR}
	-rmdir ${WORK_HOME}/${MODEL_LANGPAIR}

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
MODEL_LANGPAIRS := ${MODEL_LANGPAIR} \
	${shell for s in ${SRCLANGS}; do for t in ${TRGLANGS}; do echo "$$s-$$t"; done done}

## get language pairs for which we have test sets
ALL_LANGPAIRS := $(notdir ${wildcard ${TESTSET_HOME}/*})
LANGPAIRS     := ${sort $(filter ${ALL_LANGPAIRS},${MODEL_LANGPAIRS})}
LANGPAIR      := ${firstword ${LANGPAIRS}}
LANGPAIRSTR   := ${LANGPAIR}
SRC           := ${firstword ${subst -, ,${LANGPAIR}}}
TRG           := ${lastword ${subst -, ,${LANGPAIR}}}
TESTSET_DIR   := ${TESTSET_HOME}/${LANGPAIR}
TESTSETS      := ${notdir ${basename ${wildcard ${TESTSET_DIR}/*.${SRC}}}}
TESTSET       := ${firstword ${TESTSETS}}


MODEL_EVAL_MISSING := $(patsubst %,%.missing,${ALL_LANGPAIRS})

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

ifeq ($(filter comet,${METRICS}),comet)
  EVAL_FILES = ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet
else
  EVAL_FILES = ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval
endif

.PHONY: eval
eval: ${EVAL_FILES}


## individual evaluation files
INDIVIDUAL_EVAL_FILES = $(patsubst %,${MODEL_DIR}/${TESTSET}.${LANGPAIR}.%,${METRICS})

## concatenate all scores into one file
## exception: comet scores: take only the last line and add the name of the metric
## all others: just add the while file content (assume sacrebleu output)

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.eval: ${INDIVIDUAL_EVAL_FILES}
	for c in $^; do \
	  if [ $$c == ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet ]; then \
		tail -1 ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet | \
		sed 's/^.*score:/COMET+default =/' >> $@; \
	  else \
		cat $$c >> $@; \
	  fi \
	done
	rev $@ | sort | uniq -f2 | rev > $@.uniq
	mv -f $@.uniq $@

#	cat ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.bleu \
#	    ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.chrf            > $@
#	tail -1 ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet | \
#	sed 's/^.*score:/COMET+default =/'                     >> $@


${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare:
	${MAKE} ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output
	if [ -e ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output ]; then \
	  if [ -s ${WORK_DIR}/${TESTSET}.${LANGPAIR}.output ]; then \
		mkdir -p ${dir $@}; \
		paste -d "\n" \
			${TESTSET_DIR}/${TESTSET}.${SRC} \
			${TESTSET_DIR}/${TESTSET}.${TRG} \
			${WORK_DIR}/${TESTSET}.${LANGPAIR}.output |\
		sed 	-e "s/&apos;/'/g" \
			-e 's/&quot;/"/g' \
			-e 's/&lt;/</g' \
			-e 's/&gt;/>/g' \
			-e 's/&amp;/&/g' |\
		sed 'n;n;G;' > $@; \
	  fi \
	fi

## adjust tokenisation to non-space-separated languages
ifneq ($(filter cmn yue zho,${TRG}),)
  SACREBLEU_PARAMS = --tokenize zh
endif

ifneq ($(filter jpn,${TRG}),)
  SACREBLEU_PARAMS = --tokenize ja-mecab
endif

ifneq ($(filter kor,${TRG}),)
  SACREBLEU_PARAMS = --tokenize ko-mecab
endif



${MODEL_DIR}/${TESTSET}.${LANGPAIR}.spbleu: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare
	mkdir -p ${dir $@}
	sed -n '1~4p' $< > $@.src
	sed -n '2~4p' $< > $@.ref
	sed -n '3~4p' $< > $@.hyp
	cat $@.hyp | \
	sacrebleu -f text --metrics=bleu --tokenize  flores200 $@.ref > $@
	rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.bleu: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare
	mkdir -p ${dir $@}
	sed -n '1~4p' $< > $@.src
	sed -n '2~4p' $< > $@.ref
	sed -n '3~4p' $< > $@.hyp
	cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} $@.ref > $@
	rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.chrf: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare
	mkdir -p ${dir $@}
	sed -n '1~4p' $< > $@.src
	sed -n '2~4p' $< > $@.ref
	sed -n '3~4p' $< > $@.hyp
	cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 $@.ref |\
	perl -pe 'unless (/version\:1\./){@a=split(/\s+/);$$a[-1]/=100;$$_=join(" ",@a);}' > $@
	rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.chrf++: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare
	mkdir -p ${dir $@}
	sed -n '1~4p' $< > $@.src
	sed -n '2~4p' $< > $@.ref
	sed -n '3~4p' $< > $@.hyp
	cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 --chrf-word-order 2 $@.ref |\
	perl -pe 'unless (/version\:1\./){@a=split(/\s+/);$$a[-1]/=100;$$_=join(" ",@a);}' > $@
	rm -f $@.src $@.ref $@.hyp

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.ter: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare
	mkdir -p ${dir $@}
	sed -n '1~4p' $< > $@.src
	sed -n '2~4p' $< > $@.ref
	sed -n '3~4p' $< > $@.hyp
	cat $@.hyp | \
	sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=ter $@.ref > $@
	rm -f $@.src $@.ref $@.hyp

ifneq (${GPU_AVAILABLE},1)
  COMET_PARAM += --gpus 0
endif

${MODEL_DIR}/${TESTSET}.${LANGPAIR}.comet: ${MODEL_DIR}/${TESTSET}.${LANGPAIR}.compare
	mkdir -p ${dir $@}
	sed -n '1~4p' $< > $@.src
	sed -n '2~4p' $< > $@.ref
	sed -n '3~4p' $< > $@.hyp
	${LOAD_COMET_ENV} ${COMET_SCORE} ${COMET_PARAM} \
		-s $@.src -r $@.ref -t $@.hyp | cut -f2,3 > $@
	rm -f $@.src $@.ref $@.hyp




## make the comet score

.PHONY: comet
comet: 
	${MAKE} fetch
	${MAKE} comet-langpairs
	${MAKE} ${MODEL_COMETSCORES}

comet-score-file: ${MODEL_COMETSCORES}

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


#-------------------------------------------------
# collect BLEU and chrF scores in one file
#-------------------------------------------------
#
# updating scores for models that already have some scores registered
# - need to fetch eval file package
# - avoid re-running things that are already done
# - ingest the new evaluation scores
#

${MODEL_SCORES}: ${TESTSET_INDEX}
	-if [ ! -e $@ ]; then \
	  mkdir -p $(dir $@); \
	  wget -qq -O $@ ${MODEL_STORAGE}/${MODEL}.scores.txt; \
	fi
	${MAKE} fetch
	${MAKE} eval-langpairs
	${MAKE} cleanup
	if [ -d ${MODEL_DIR} ]; then \
	  grep -H BLEU ${MODEL_DIR}/*.bleu | sort                  > $@.bleu; \
	  grep -H chrF ${MODEL_DIR}/*.chrf | sort                  > $@.chrf; \
	  cut -f1 -d: $@.bleu | rev | cut -f2 -d. | rev            > $@.langs; \
	  cut -f1 -d: $@.bleu | rev | cut -f1 -d/ | cut -f3- -d. | rev  > $@.testsets; \
	  cat $@.chrf | rev | cut -f1 -d' ' | rev                  > $@.chrf-scores; \
	  cut -f2 -d= $@.bleu | cut -f2 -d' '                      > $@.bleu-scores; \
	  cut -f1 -d: $@.bleu | rev | cut -f2,3 -d/ | \
	  rev | sed 's#^#${MODEL_STORAGE}/#' | sed 's/$$/.zip/'    > $@.urls; \
	  cut -f1 -d: $@.bleu | sed 's/.bleu$$/.compare/' | \
	  xargs wc -l |  grep -v '[0-9] total' | \
	  perl -pe '$$_/=4;print "\n"' | tail -n +2                > $@.nrlines; \
	  cat $@.bleu | rev | cut -f1 -d' ' | rev | cut -f1 -d')'  > $@.nrwords; \
	  if [ -e $@ ]; then mv $@ $@.old; fi; \
	  paste $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords |\
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  sort -k1,1 -k2,2 -k4,4nr -k6,6nr -k7,7nr | \
	  rev | uniq -f5 | rev | sort -u                           > $@; \
	  if [ -e $@.old ]; then \
	    mv $@ $@.new; \
	    sort -k1,1 -k2,2 -m $@.new $@.old | \
	    rev | uniq -f5 | rev | sort -u                         > $@; \
	  fi; \
	  rm -f $@.bleu $@.chrf $@.langs $@.testsets \
		$@.chrf-scores $@.bleu-scores \
		$@.urls $@.nrlines $@.nrwords $@.old $@.new; \
	fi



## generic recipe for extracting scores for a metric
## (works for all sacrebleu results but not for other metrics)

${MODEL_DIR}.%-scores.txt: ${MODEL_SCORES}
	if [ -d ${MODEL_DIR} ]; then \
	  mkdir -p $(dir $@); \
	  grep -H . ${MODEL_DIR}/*.$(patsubst ${MODEL_DIR}.%-scores.txt,%,$@) > $@.all; \
	  cut -f1 -d: $@.all | rev | cut -f2 -d. | rev                        > $@.langs; \
	  cut -f1 -d: $@.all | rev | cut -f1 -d/ | cut -f3- -d. | rev         > $@.testsets; \
	  cut -f3 -d ' '  $@.all                                              > $@.scores; \
	  paste $@.langs $@.testsets $@.scores                               >> $@; \
	  cat $@ |\
	  sed -e 's/\(news.*[0-9][0-9][0-9][0-9]\)-[a-z][a-z][a-z][a-z]	/\1	/' |  \
	  sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	  rev | uniq -f1 | rev                                                > $@.sorted; \
	  mv -f $@.sorted $@; \
	  rm -f $@.all $@.langs $@.testsets $@.scores; \
	fi


## specific recipe for COMET scores

${MODEL_DIR}.comet-scores.txt: ${MODEL_SCORES}
	if [ -d ${MODEL_DIR} ]; then \
	  mkdir -p $(dir $@); \
	  grep -H '^score:' ${MODEL_DIR}/*.comet | sort                  > $@.comet; \
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




## OLD: extract BLEU and chrF scores from the combined score file

# ${MODEL_BLEUSCORES}: ${MODEL_SCORES}
# 	cut -f1,2,4 ${MODEL_SCORES} | \
# 	sed 's/\(news.*[0-9][0-9][0-9][0-9]\)\-[a-z][a-z][a-z][a-z]	/\1	/' |\
# 	sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
# 	rev | uniq -f1 | rev > $@


# ${MODEL_CHRFSCORES}: ${MODEL_SCORES}
# 	cut -f1,2,3 ${MODEL_SCORES} |\
# 	sed 's/\(news.*[0-9][0-9][0-9][0-9]\)\-[a-z][a-z][a-z][a-z]	/\1	/' |\
# 	sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
# 	rev | uniq -f1 | rev > $@



