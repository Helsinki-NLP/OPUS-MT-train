# -*-makefile-*-




## clean data
## OLD: apply cleanup script from Moses
##      --> this might not be a good idea before subword splitting for languages without spaces
## NEW: do this later after splitting into subword units
##
## TODO:
## - does this effect sentence piece / BPE models in some negative way?
## - should we increase the length filter when cleaning later? How much?
## - should we apply some other cleanup scripts here to get rid of some messy stuff?

%.clean.${SRCEXT}.gz: %.${SRCEXT}.${PRE} %.${TRGEXT}.${PRE}
	cat ${word 1,$^} |\
	perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' |\
	perl -CS -pe 's/\&\s*\#\s*160\s*\;/ /g' > $@.1
	cat ${word 2,$^} |\
	perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' |\
	perl -CS -pe 's/\&\s*\#\s*160\s*\;/ /g' > $@.2
	paste $@.1 $@.2 |\
	scripts/filter/bitext-match-lang.py -s ${SRC} -t ${TRG} > $@.bitext
	cut -f1 $@.bitext | ${GZIP} -c > $@
	cut -f2 $@.bitext | ${GZIP} -c > $(@:.clean.${SRCEXT}.gz=.clean.${TRGEXT}.gz)
	rm -f $@.bitext $@.1 $@.2
	if [ ! `${ZCAT} "$@" | head | wc -l` -gt 0 ]; then rm -f $@; fi
	if [ ! `${ZCAT} "$(@:.clean.${SRCEXT}.gz=.clean.${TRGEXT}.gz)" | head | wc -l` -gt 0 ]; then \
	  rm -f $(@:.clean.${SRCEXT}.gz=.clean.${TRGEXT}.gz); \
	fi

%.clean.${TRGEXT}.gz: %.clean.${SRCEXT}.gz
	@echo "done!"



##----------------------------------------------
## tokenization
##----------------------------------------------


## normalisation for Chinese
%.zh_tw.tok: %.zh_tw.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

%.zh_cn.tok: %.zh_cn.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

%.zh.tok: %.zh.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

## generic target for tokenization
%.tok: %.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl \
		-l ${lastword ${subst 1,,${subst 2,,${subst ., ,$(<:.raw=)}}}} |\
	$(TOKENIZER)/tokenizer.perl -a -threads $(THREADS) \
		-l ${lastword ${subst 1,,${subst 2,,${subst ., ,$(<:.raw=)}}}} |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@



### TODO: make language-specific pre-processing ....
### use SRC_CLEANUP_SCRIPTS TRG_CLEANUP_SCRIPTS

## only normalisation
%.norm.gz: %.gz
	$(LOAD_MOSES) ${GZIP} -cd < $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' | ${GZIP} -c > $@

%.norm: %.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

%.${SRCEXT}.norm: %.${SRCEXT}.raw
	$(LOAD_MOSES) cat $< ${SRC_CLEANUP_SCRIPTS} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

%.${TRGEXT}.norm: %.${TRGEXT}.raw
	$(LOAD_MOSES) cat $< ${TRG_CLEANUP_SCRIPTS} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/normalize-punctuation.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@


## minimal pre-processing
%.simple.gz: %.gz
	$(LOAD_MOSES) ${GZIP} -cd < $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/deescape-special-chars.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' | ${GZIP} -c > $@

%.simple: %.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/deescape-special-chars.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

%.${SRCEXT}.simple: %.${SRCEXT}.raw
	$(LOAD_MOSES) cat $< ${SRC_CLEANUP_SCRIPTS} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/deescape-special-chars.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@

%.${TRGEXT}.simple: %.${TRGEXT}.raw
	$(LOAD_MOSES) cat $< ${TRG_CLEANUP_SCRIPTS} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/deescape-special-chars.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' > $@



## remove all spaces (treat everything as a long string)
%.nospace: %.raw
	$(LOAD_MOSES) cat $< |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	$(TOKENIZER)/deescape-special-chars.perl |\
	sed 's/^ *//;s/  */ /g;s/ *$$//g' |\
	sed 's/ /▁/g' > $@


## generic targets to make it possible to work with compressed data
## when running the same pre-processing pipeline
## TODO: does that destroy anything?
## TODO: do we need this?

# %.raw: %.gz
# 	${GZIP} -cd < $< > $@

# %.${PRE}.gz: %.${PRE}
# 	${GZIP} -c < $< > $@






## the above should avoid having repeating the pipeline below

# %.norm.gz: %.gz
# 	$(LOAD_MOSES) ${GZIP} -cd < $< |\
# 	$(TOKENIZER)/replace-unicode-punctuation.perl |\
# 	$(TOKENIZER)/remove-non-printing-char.perl |\
# 	$(TOKENIZER)/normalize-punctuation.perl |\
# 	sed 's/^ *//;s/  */ /g;s/ *$$//g' | ${GZIP} -c > $@

# %.simple.gz: %.gz
# 	$(LOAD_MOSES) ${GZIP} -cd < $< |\
# 	$(TOKENIZER)/replace-unicode-punctuation.perl |\
# 	$(TOKENIZER)/remove-non-printing-char.perl |\
# 	$(TOKENIZER)/deescape-special-chars.perl |\
# 	sed 's/^ *//;s/  */ /g;s/ *$$//g' | ${GZIP} -c > $@

# %.nospace.gz: %.gz
# 	$(LOAD_MOSES) ${GZIP} -cd < $< |\
# 	$(TOKENIZER)/replace-unicode-punctuation.perl |\
# 	$(TOKENIZER)/remove-non-printing-char.perl |\
# 	$(TOKENIZER)/deescape-special-chars.perl |\
# 	sed 's/^ *//;s/  */ /g;s/ *$$//g' |\
# 	sed 's/ /▁/g' |\
# 	${GZIP} -c > $@



## no further pre-processing

%.src.plain: %.src
	mv $< $@
	ln -s $@ $<

%.trg.plain: %.trg
	mv $< $@
	ln -s $@ $<



## increase max number of tokens to 250
## (TODO: should MIN_NTOKENS be 1?)
MIN_NR_TOKENS = 0
MAX_NR_TOKENS = 250

## apply the cleanup script from Moses
%.src.clean.${PRE_SRC}: %.src.${PRE_SRC} %.trg.${PRE_TRG}
	rm -f $@.${SRCEXT} $<.${TRGEXT}
	ln -s ${word 1,$^} $<.${SRCEXT}
	ln -s ${word 2,$^} $<.${TRGEXT}
	$(MOSESSCRIPTS)/training/clean-corpus-n.perl $< $(SRCEXT) $(TRGEXT) $@ ${MIN_NR_TOKENS} ${MAX_NR_TOKENS}
	rm -f $<.${SRCEXT} $<.${TRGEXT}
	mv $@.${SRCEXT} $@
	mv $@.${TRGEXT} $(@:.src.clean.${PRE_SRC}=.trg.clean.${PRE_TRG})
	echo -n "* total size (${DATASET}): " >> ${dir $@}README.md
	cat $@ | wc -l >> ${dir $@}README.md


%.trg.clean.${PRE_TRG}: %.src.clean.${PRE_SRC}
	@echo "done!"


# tokenize testsets
testsets/%.raw: testsets/%.gz
	${GZIP} -cd < $< > $@

testsets/%.${PRE}.gz: testsets/%.${PRE}
	${GZIP} -c < $< > $@

ALLTEST = $(patsubst %.gz,%.${PRE}.gz,${sort $(subst .${PRE},,${wildcard testsets/*/*.??.gz})})

tokenize-testsets prepare-testsets: ${ALLTEST}

