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

## simple hack that makes chrF scores compatible with previous version
## of sacrebleu (now: score in percentages)
## --> this breaks easily if the score < 10 or = 100

%.eval: % ${TEST_TRG}
	paste ${TEST_SRC}.${PRE_SRC} ${TEST_TRG} | grep $$'.\t' | cut -f2 > $@.ref
	cat $< | sacrebleu -f text ${SACREBLEU_PARAMS} $@.ref > $@
	cat $< | sacrebleu -f text ${SACREBLEU_PARAMS} --metrics=chrf --width=3 $@.ref |\
	sed 's/\([0-9][0-9]\)\.\([0-9]*\)$$/0.\1\2/'         >> $@
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


# print-bleu-scores:
# 	grep BLEU ${WORKHOME}/*/*.eval |\
# 	sed 's#^${WORKHOME}/##' |\
# 	sed 's/\.\([^\.]*\)\.\([^\.]*\)\.\([^\.]*\)\.eval[^ ]* = \([0-9\.]*\).*$$/	\1	\2-\3	\4/' |\
# 	sed 's#^\([^/]*\)/\([^\.]*\)\.[^	]*	#\1	\2	#'



print-bleu-scores:
	grep BLEU ${WORKHOME}/*/*.eval |\
	perl -pe 's#^${WORKHOME}/([^/]*)/([^\.]+)\.(.*?-.*?\.)?([^\.]+\.[^\.]+\.[^\.]+)\.([^\.]+)\.([^\.]+)\.eval:.*? = ([0-9\.]+) .*$$#$$5-$$6\t$$7\t$$2\t$$1\t$$4#' |\
	perl -pe '@a=split(/\t/);if($$a[0]=~/multi/){$$a[0]=$$a[3];};$$_=join("\t",@a);' |\
	sort -k3,3 -k1,1 -k2,2nr



pretty-print-bleu-scores:
	grep BLEU ${WORKHOME}/*/*.eval |\
	perl -pe 's#^${WORKHOME}/([^/]*)/([^\.]+)\.(.*?-.*?\.)?([^\.]+\.[^\.]+\.[^\.]+)\.([^\.]+)\.([^\.]+)\.eval:.*? = ([0-9\.]+) .*$$#$$5-$$6\t$$7\t$$2\t$$1\t$$4#' |\
	perl -pe '@a=split(/\t/);if($$a[0]=~/multi/){$$a[0]=$$a[3];};$$_=join("\t",@a);' |\
	sort -k3,3 -k1,1 -k2,2nr |\
	perl -e 'while (<>){@a=split(/\t/);printf "%15s  %5.2f  %-25s  %-15ss  %s",@a;}'


print-bleu-scores2:
	grep BLEU ${WORKHOME}/*/*.eval |\
	perl -pe 's#^${WORKHOME}/([^/]*)/([^\.]+)\.(.*?-.*?\.)?([^\.]+)\.[^\.]+\.([^\.]+)\.([^\.]+)\.([^\.]+)\.eval:.*? = ([0-9\.]+) .*$$#$$6-$$7\t$$8\t$$2\t$$1\t$$4\t$$5#' |\
	perl -pe '@a=split(/\t/);if($$a[0]=~/multi/){$$a[0]=$$a[3];};$$_=join("\t",@a);' |\
	sort -k3,3 -k1,1 -k2,2nr

pretty-print-bleu-scores2:
	grep BLEU ${WORKHOME}/*/*.eval |\
	perl -pe 's#^${WORKHOME}/([^/]*)/([^\.]+)\.(.*?-.*?\.)?([^\.]+)\.[^\.]+\.([^\.]+)\.([^\.]+)\.([^\.]+)\.eval:.*? = ([0-9\.]+) .*$$#$$6-$$7\t$$8\t$$2\t$$1\t$$4\t$$5#' |\
	perl -pe '@a=split(/\t/);if($$a[0]=~/multi/){$$a[0]=$$a[3];};$$_=join("\t",@a);' |\
	sort -k3,3 -k1,1 -k2,2nr |\
	perl -e 'while (<>){@a=split(/\t/);printf "%15s  %5.2f  %-25s  %-15s  %-25s  %s",@a;}'

