# -*-makefile-*-

#------------------------------------------------------------------------
# translate and evaluate all test sets in testsets/
#------------------------------------------------------------------------

## testset dir for all test sets in this language pair
## and all trokenized test sets that can be found in that directory
TESTSET_HOME    = ${PWD}/testsets
TESTSET_DIR     = ${TESTSET_HOME}/${SRC}-${TRG}
TESTSETS        = $(sort $(patsubst ${TESTSET_DIR}/%.${SRCEXT}.gz,%,${wildcard ${TESTSET_DIR}/*.${SRCEXT}.gz}))
TESTSETS_PRESRC = $(patsubst %,${TESTSET_DIR}/%.${SRCEXT}.${PRE}.gz,${TESTSETS})
TESTSETS_PRETRG = $(patsubst %,${TESTSET_DIR}/%.${TRGEXT}.${PRE}.gz,${TESTSETS})

# TESTSETS_PRESRC = $(patsubst %.gz,%.${PRE}.gz,${sort $(subst .${PRE},,${wildcard ${TESTSET_DIR}/*.${SRC}.gz})})
# TESTSETS_PRETRG = $(patsubst %.gz,%.${PRE}.gz,${sort $(subst .${PRE},,${wildcard ${TESTSET_DIR}/*.${TRG}.gz})})

## eval all available test sets
eval-testsets:
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    ${MAKE} SRC=$$s TRG=$$t compare-testsets-langpair; \
	  done \
	done

eval-heldout:
	${MAKE} TESTSET_HOME=${HELDOUT_DIR} eval-testsets

%-testsets-langpair: ${TESTSETS_PRESRC} ${TESTSETS_PRETRG}
	@echo "testsets: ${TESTSET_DIR}/*.${SRCEXT}.gz"
	for t in ${TESTSETS}; do \
	  ${MAKE} TESTSET=$$t ${@:-testsets-langpair=}; \
	done



#------------------------------------------------------------------------
# translate with an ensemble of several models
#------------------------------------------------------------------------

ENSEMBLE = ${wildcard ${WORKDIR}/${MODEL}.${MODELTYPE}.model*.npz.best-perplexity.npz}

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.ensemble.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${ENSEMBLE}
	mkdir -p ${dir $@}
	grep . $< > $@.input
	${LOADMODS} && ${MARIAN}/marian-decoder -i $@.input \
		--models ${ENSEMBLE} \
		--vocabs ${WORKDIR}/${MODEL}.vocab.yml \
			${WORKDIR}/${MODEL}.vocab.yml \
			${WORKDIR}/${MODEL}.vocab.yml \
		${MARIAN_DECODER_FLAGS} > $@.output
ifeq (${PRE_TRG},spm${TRGBPESIZE:000=}k)
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
	${LOADMODS} && ${MARIAN}/marian-decoder -i $@.input \
		-c ${word 2,$^}.decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} > $@.output
ifeq (${PRE_TRG},spm${TRGBPESIZE:000=}k)
	sed 's/ //g;s/▁/ /g' < $@.output | sed 's/^ *//;s/ *$$//' > $@
else
	sed 's/\@\@ //g;s/ \@\@//g;s/ \@\-\@ /-/g' < $@.output |\
	$(TOKENIZER)/detokenizer.perl -l ${TRG} > $@
endif
	rm -f $@.input $@.output



%.eval: % ${TEST_TRG}
	paste ${TEST_SRC}.${PRE_SRC} ${TEST_TRG} | grep $$'.\t' | cut -f2 > $@.ref
	cat $< | sacrebleu $@.ref > $@
	cat $< | sacrebleu --metrics=chrf --width=3 $@.ref >> $@
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
