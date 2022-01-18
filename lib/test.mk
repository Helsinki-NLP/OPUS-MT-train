# -*-makefile-*-

#------------------------------------------------------------------------
# translate and evaluate all test sets in testsets/
#------------------------------------------------------------------------

## testset dir for all test sets in this language pair
## and all trokenized test sets that can be found in that directory
TESTSET_HOME    = ${REPOHOME}testsets
TESTSET_DIR     = ${TESTSET_HOME}/${SRC}-${TRG}
TESTSETS        = $(sort $(patsubst ${TESTSET_DIR}/%.${SRCEXT}.gz,%,${wildcard ${TESTSET_DIR}/*.${SRCEXT}.gz}))
TESTSETS_PRESRC = $(patsubst %,${TESTSET_DIR}/%.${SRCEXT}.${PRE}.gz,${TESTSETS})
TESTSETS_PRETRG = $(patsubst %,${TESTSET_DIR}/%.${TRGEXT}.${PRE}.gz,${TESTSETS})


## eval all available test sets
eval-testsets:
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    ${MAKE} SRC=$$s TRG=$$t compare-testsets-langpair; \
	  done \
	done

%-testsets-langpair: ${TESTSETS_PRESRC} ${TESTSETS_PRETRG}
	@echo "testsets: ${TESTSET_DIR}/*.${SRCEXT}.gz"
	for t in ${TESTSETS}; do \
	  ${MAKE} TESTSET=$$t TESTSET_NAME=$$t-${SRC}${TRG} ${@:-testsets-langpair=}; \
	done



#------------------------------------------------------------------------
# translate with an ensemble of several models
#------------------------------------------------------------------------

ENSEMBLE = ${wildcard ${WORKDIR}/${MODEL}.${MODELTYPE}.model*.npz.best-perplexity.npz}

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${ENSEMBLE}
	mkdir -p ${dir $@}
	grep . $< > $@.input
	${LOAD_ENV} && ${MARIAN_DECODER} -i $@.input \
		--models ${ENSEMBLE} \
		--vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		${MARIAN_DECODER_FLAGS} > $@.output
ifneq ($(findstring spm,${PRE_TRG}),)
	sed 's/ //g;s/▁/ /g' < $@.output | sed 's/^ *//;s/ *$$//' > $@
else
	sed 's/\@\@ //g;s/ \@\@//g;s/ \@\-\@ /-/g' < $@.output |\
	$(TOKENIZER)/detokenizer.perl -l ${TRG} > $@
endif
	rm -f $@.input $@.output


#------------------------------------------------------------------------
# translate, evaluate and generate a file 
# for comparing system to reference translations
#------------------------------------------------------------------------

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_FINAL}
	mkdir -p ${dir $@}
	grep . $< > $@.input
	${LOAD_ENV} && ${MARIAN_DECODER} -i $@.input \
		-c ${word 2,$^}.decoder.yml \
		${MARIAN_DECODER_FLAGS} > $@.output
ifneq ($(findstring spm,${PRE_TRG}),)
	sed 's/ //g;s/▁/ /g' < $@.output | sed 's/^ *//;s/ *$$//' > $@
else
	sed 's/\@\@ //g;s/ \@\@//g;s/ \@\-\@ /-/g' < $@.output |\
	$(TOKENIZER)/detokenizer.perl -l ${TRG} > $@
endif
	rm -f $@.input $@.output

## adjust tokenisation to non-space-separated languages
## TODO: is it correct to simply use 'zh' or should we use 'intl'?
ifneq ($(filter zh zho jp jpn cmn,${TRGLANGS}),)
  SACREBLEU_PARAMS = --tokenize zh
endif

%.eval: % ${TEST_TRG}
	paste ${TEST_SRC}.${PRE_SRC} ${TEST_TRG} | grep $$'.\t' | cut -f2 > $@.ref
	cat $< | sacrebleu -f text ${SACREBLEU_PARAMS} $@.ref > $@
	cat $< | sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 $@.ref >> $@
	rm -f $@.ref


%.compare: %.eval
	grep . ${TEST_SRC} > $@.1
	grep . ${TEST_TRG} > $@.2
	grep . ${<:.eval=} > $@.3
	paste -d "\n" $@.1 $@.2 $@.3 |\
	sed 	-e "s/&apos;/'/g" \
		-e 's/&quot;/"/g' \
		-e 's/&lt;/</g' \
		-e 's/&gt;/>/g' \
		-e 's/&amp;/&/g' |\
	sed 'n;n;G;' > $@
	rm -f $@.1 $@.2 $@.3
