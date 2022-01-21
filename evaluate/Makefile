
REPOHOME := ${PWD}/../
include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk


SRC       = en
TRG       = de
LANGPAIR  = ${SRC}-${TRG}

MODELHOME     = ../models/${LANGPAIR}
MODELZIP      = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
MODELNAME     = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
MODELSTORE    = OPUS-MT-models
MODELURL      = https://object.pouta.csc.fi/${MODELSTORE}/${LANGPAIR}

TESTSETDIR    = ../testsets/${LANGPAIR}
TESTSETS      = ${sort ${wildcard ${TESTSETDIR}/*.${SRC}.gz}}
TESTSET       = ${lastword ${TESTSETS}}

WORKDIR       = ${PWD}/${LANGPAIR}/${MODELNAME}
TEST_PRE      = ${WORKDIR}/${patsubst %.gz,%.pre,${notdir ${TESTSET}}}
TEST_TRANS    = ${TEST_PRE}.${TRG}
TEST_EVAL     = ${TEST_TRANS}.eval
TEST_EVALNORM = ${TEST_TRANS}.eval-norm



all: ${WORKDIR}/model/decoder.yml
	${MAKE} ${TEST_EVAL}
	${MAKE} cleanup





.INTERMEDIATE: ${WORKDIR}/model/decoder.yml

prepare-model: ${WORKDIR}/model/decoder.yml
${WORKDIR}/model/decoder.yml:
	mkdir -p ${dir $@}
ifneq (${wildcard ${MODELZIP}},)
	cp ${MODELZIP} ${dir $@}
else
	cd ${dir $@} && wget ${MODELURL}/${notdir ${MODELZIP}}
endif
	cd ${dir $@} && unzip -u *.zip


SUBWORD_MODEL = ${filter-out ${WORKDIR}/model/source.tcmodel,${wildcard ${WORKDIR}/model/source.*}}

ifneq (${wildcard ${WORKDIR}/model/preprocess.sh},)
  PREPROCESS = ${WORKDIR}/model/preprocess.sh ${SRC} ${SUBWORD_MODEL}
else ifeq (${SUBWORD_MODEL},${WORKDIR}/model/source.spm)
  PREPROCESS =  ${TOKENIZER}/replace-unicode-punctuation.perl |\
  ${TOKENIZER}/remove-non-printing-char.perl |\
  ${TOKENIZER}/normalize-punctuation.perl -l ${SRC} |\
  sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
  ${SPM_HOME}/spm_encode --model ${SUBWORD_MODEL}
else
  PREPROCESS = ${TOKENIZER}/replace-unicode-punctuation.perl |\
		${TOKENIZER}/remove-non-printing-char.perl |\
		${TOKENIZER}/normalize-punctuation.perl -l ${SRC} |\
		${TOKENIZER}/tokenizer.perl -a -l ${SRC} |\
		sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
		python3 ${SNMTPATH}/apply_bpe.py -c ${SUBWORD_MODEL}
endif

ifneq (${wildcard ${WORKDIR}/model/postprocess.sh},)
  POSTPROCESS = ${WORKDIR}/model/postprocess.sh
else ifeq (${SUBWORD_MODEL},${WORKDIR}/model/source.spm)
  POSTPROCESS = sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//'
else
  POSTPROCESS =	sed 's/\@\@ //g;s/ \@\@//g;s/ \@\-\@ /-/g' |\
		$(TOKENIZER)/detokenizer.perl -l ${TRG}
endif


prepare-data: ${TEST_PRE}
${TEST_PRE}: ${TESTSET} ${WORKDIR}/model/decoder.yml
	${ZCAT} $< | ${PREPROCESS} > $@


translate: ${TEST_TRANS}

## translate test set
${TEST_TRANS}: ${TEST_PRE} ${WORKDIR}/model/decoder.yml
	mkdir -p ${dir $@}
	cd ${dir ${word 2,$^}}; \
	${LOAD_ENV} && ${MARIAN_DECODER} -i $< \
		-c decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	${POSTPROCESS} |\
	sed 's/^ *//;s/ *$$//' > $@


eval: ${TEST_EVAL}

${TEST_EVAL}: ${TEST_TRANS}
	${ZCAT} ${patsubst %.${SRC}.gz,%.${TRG}.gz,${TESTSET}} > $@.ref
	cat $< | sacrebleu $@.ref > $@
	cat $< | sacrebleu --metrics=chrf --width=3 $@.ref >> $@
	rm -f $@.ref

${TEST_EVALNORM}: ${TEST_TRANS}
	${ZCAT} ${patsubst %.${SRC}.gz,%.${TRG}.gz,${TESTSET}} |\
	${TOKENIZER}/replace-unicode-punctuation.perl |\
	${TOKENIZER}/remove-non-printing-char.perl |\
	${TOKENIZER}/normalize-punctuation.perl -l ${TRG} |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' > $@.ref
	cat $< | sacrebleu $@.ref > $@
	cat $< | sacrebleu --metrics=chrf --width=3 $@.ref >> $@
	rm -f $@.ref


cleanup:
	rm -fr ${WORKDIR}/model
