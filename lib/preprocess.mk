# -*-makefile-*-


## clean-corpus script parameters
## (for filtering subword-segmented bitexts)
##
## (TODO: should MIN_NTOKENS be 1?)
# MIN_NR_TOKENS    = 0
# MAX_NR_TOKENS    = 250
MIN_NR_TOKENS    = 1
MAX_NR_TOKENS    = 500
NR_TOKEN_RATIO   = 2
MAX_TOKEN_LENGTH = 100

## default values in the original script:
##
# MAX_TOKEN_LENGTH = 1000
# NR_TOKEN_RATIO = 9


## compute some ratios and thresholds that could be useful for filtering training data
## use test sets for those stats assuming that they are representative and clean
##
## - word-ratio threshold = max ratio between number of words
## - char-ratio threshold = max ratio between number of characters

ifneq ($(wildcard ${CLEAN_TEST_SRC_STATS}),)
  NR_LINES_RAWSRCTEST = $(word 1,$(shell cat ${CLEAN_TEST_SRC_STATS}))
  NR_WORDS_RAWSRCTEST = $(word 2,$(shell cat ${CLEAN_TEST_SRC_STATS}))
  NR_CHARS_RAWSRCTEST = $(word 3,$(shell cat ${CLEAN_TEST_SRC_STATS}))
  NR_BYTES_RAWSRCTEST = $(word 4,$(shell cat ${CLEAN_TEST_SRC_STATS}))
  UNIQUE_CHARS_RAWSRCTEST = $(shell sed -n 2,2p ${CLEAN_TEST_SRC_STATS})
  LONGEST_LINE_RAWSRCTEST = $(shell sed -n 3,3p ${CLEAN_TEST_SRC_STATS})
  LONGEST_WORD_RAWSRCTEST = $(shell sed -n 4,4p ${CLEAN_TEST_SRC_STATS})
endif

ifneq ($(wildcard ${CLEAN_TEST_TRG_STATS}),)
  NR_LINES_RAWTRGTEST = $(word 1,$(shell cat ${CLEAN_TEST_TRG_STATS}))
  NR_WORDS_RAWTRGTEST = $(word 2,$(shell cat ${CLEAN_TEST_TRG_STATS}))
  NR_CHARS_RAWTRGTEST = $(word 3,$(shell cat ${CLEAN_TEST_TRG_STATS}))
  NR_BYTES_RAWTRGTEST = $(word 4,$(shell cat ${CLEAN_TEST_TRG_STATS}))
  UNIQUE_CHARS_RAWTRGTEST = $(shell sed -n 2,2p ${CLEAN_TEST_TRG_STATS})
  LONGEST_LINE_RAWTRGTEST = $(shell sed -n 3,3p ${CLEAN_TEST_TRG_STATS})
  LONGEST_WORD_RAWTRGTEST = $(shell sed -n 4,4p ${CLEAN_TEST_TRG_STATS})
endif

ifdef NR_WORDS_RAWSRCTEST
ifdef NR_WORDS_RAWTRGTEST
  WORD_RATIO_SRCTRG_RAWTEST = $$(( ${NR_WORDS_RAWSRCTEST} / ${NR_WORDS_RAWTRGTEST} )) 
  WORD_RATIO_TRGSRC_RAWTEST = $$(( ${NR_WORDS_RAWTRGTEST} / ${NR_WORDS_RAWSRCTEST} )) 
  WORD_RATIO_RAWTEST = ${shell printf "%s\n" ${WORD_RATIO_SRCTRG_RAWTEST} ${WORD_RATIO_TRGSRC_RAWTEST} | sort -nr | head -1}
  WORD_RATIO_THRESHOLD = $$(( ${WORD_RATIO_RAWTEST} + 1 ))
endif
endif

ifdef NR_CHARS_RAWSRCTEST
ifdef NR_CHARS_RAWTRGTEST
  CHAR_RATIO_SRCTRG_RAWTEST = $$(( ${NR_CHARS_RAWSRCTEST} / ${NR_CHARS_RAWTRGTEST} )) 
  CHAR_RATIO_TRGSRC_RAWTEST = $$(( ${NR_CHARS_RAWTRGTEST} / ${NR_CHARS_RAWSRCTEST} )) 
  CHAR_RATIO_RAWTEST = ${shell printf "%s\n" ${CHAR_RATIO_SRCTRG_RAWTEST} ${CHAR_RATIO_TRGSRC_RAWTEST} | sort -nr | head -1}
  CHAR_RATIO_THRESHOLD = $$(( ${CHAR_RATIO_RAWTEST} + 1 ))
endif
endif

ifdef UNIQUE_CHARS_RAWSRCTEST
ifdef UNIQUE_CHARS_RAWTRGTEST
  CHARSET_RATIO_SRCTRG_RAWTEST = $$(( ${UNIQUE_CHARS_RAWSRCTEST} / ${UNIQUE_CHARS_RAWTRGTEST} )) 
  CHARSET_RATIO_TRGSRC_RAWTEST = $$(( ${UNIQUE_CHARS_RAWTRGTEST} / ${UNIQUE_CHARS_RAWSRCTEST} )) 
  CHARSET_RATIO_RAWTEST = ${shell printf "%s\n" ${CHARSET_RATIO_SRCTRG_RAWTEST} ${CHARSET_RATIO_TRGSRC_RAWTEST} | sort -nr | head -1}
  CHARSET_RATIO_THRESHOLD = $$(( ${CHARSET_RATIO_RAWTEST} + 1 ))
endif
endif

ifdef LONGEST_LINE_RAWSRCTEST
ifdef LONGEST_LINE_RAWTRGTEST
  LONGEST_LINE_RAWTEST = ${shell printf "%s\n" ${LONGEST_LINE_RAWSRCTEST} ${LONGEST_LINE_RAWTRGTEST} | sort -nr | head -1}
  LONGEST_LINE_THRESHOLD = $$(( 1 + ${LONGEST_LINE_RAWTEST} * 4 ))
endif
endif

ifdef LONGEST_WORD_RAWSRCTEST
ifdef LONGEST_WORD_RAWTRGTEST
  LONGEST_WORD_RAWTEST = ${shell printf "%s\n" ${LONGEST_WORD_RAWSRCTEST} ${LONGEST_WORD_RAWTRGTEST} | sort -nr | head -1}
  LONGEST_WORD_THRESHOLD = $$(( 1 + ${LONGEST_WORD_RAWTEST} * 4 ))
endif
endif


## print thresholds that are conmputed from
## test set statistics

print_data_thresholds:
	@echo "source stats from ${CLEAN_TEST_SRC_STATS}"
	@echo "target stats from ${CLEAN_TEST_TRG_STATS}"
	@echo "Thresholds:"
	@echo "   word ratio: ${WORD_RATIO_THRESHOLD} (${NR_WORDS_RAWSRCTEST},${NR_WORDS_RAWTRGTEST})"
	@echo "   char ratio: ${CHAR_RATIO_THRESHOLD} (${NR_CHARS_RAWSRCTEST},${NR_CHARS_RAWTRGTEST})"
	@echo "charset ratio: ${CHARSET_RATIO_THRESHOLD} (${UNIQUE_CHARS_RAWSRCTEST},${UNIQUE_CHARS_RAWTRGTEST})"
	@echo "  line length: ${LONGEST_LINE_THRESHOLD} (1 + 4 * max(${LONGEST_LINE_RAWSRCTEST},${LONGEST_LINE_RAWTRGTEST}))"
	@echo "  word length: ${LONGEST_WORD_THRESHOLD} (1 + 4 * max(${LONGEST_WORD_RAWSRCTEST},${LONGEST_WORD_RAWTRGTEST}))"


STRICT_TRAIN_SRC = $(patsubst %.clean.${SRCEXT}.gz,%.strict.${SRCEXT}.gz,${CLEAN_TRAIN_SRC})

strict-clean-data: ${STRICT_TRAIN_SRC}

%.strict.${SRCEXT}.gz: %.clean.${SRCEXT}.gz
ifdef WORD_RATIO_THRESHOLD
	$(MOSESSCRIPTS)/training/clean-corpus-n.perl \
		-ratio ${WORD_RATIO_THRESHOLD} \
		-max-word-length ${LONGEST_WORD_THRESHOLD} \
		$(<:.${SRCEXT}.gz=) \
		$(SRCEXT) $(TRGEXT) \
		$(@:.${SRCEXT}.gz=) \
		${MIN_NR_TOKENS} ${MAX_NR_TOKENS}
	${GZIP} -f $(@:.gz=) $(@:.${SRCEXT}.gz=.${TRGEXT})
else
	-ln -s $< $@
	-ln -s $(<:.${SRCEXT}.gz=.${TRGEXT}.gz) $(@:.${SRCEXT}.gz=.${TRGEXT}.gz)
endif

%.strict.${TRGEXT}.gz: %.strict.${SRCEXT}.gz
	@echo "done!"








## basic data cleanup pipeline
## TODO: integrate OpusFilter


## should we remove zero-width spaces?
##   perl -CIOE -pe 's/[\x{2060}\x{200B}\x{feff}]//g'

%.clean.${SRCEXT}.gz: %.${SRCEXT}.${PRE} %.${TRGEXT}.${PRE}
	cat ${word 1,$^} |\
	perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' |\
	perl -CIOE -pe 's/[\x{2060}\x{200B}\x{feff}]//g' |\
	perl -CS -pe 's/\&\s*\#\s*160\s*\;/ /g' > $@.1
	cat ${word 2,$^} |\
	perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' |\
	perl -CIOE -pe 's/[\x{2060}\x{200B}\x{feff}]//g' |\
	perl -CS -pe 's/\&\s*\#\s*160\s*\;/ /g' > $@.2
	paste $@.1 $@.2 |\
	${REPOHOME}scripts/filter/bitext-match-lang.py -s ${SRC} -t ${TRG} > $@.bitext
	cut -f1 $@.bitext | ${GZIP} -c > $@
	cut -f2 $@.bitext | ${GZIP} -c > $(@:.clean.${SRCEXT}.gz=.clean.${TRGEXT}.gz)
	rm -f $@.bitext $@.1 $@.2
	if [ ! `${ZCAT} "$@" | head | wc -l` -gt 0 ]; then rm -f $@; fi
	if [ ! `${ZCAT} "$(@:.clean.${SRCEXT}.gz=.clean.${TRGEXT}.gz)" | head | wc -l` -gt 0 ]; then \
	  rm -f $(@:.clean.${SRCEXT}.gz=.clean.${TRGEXT}.gz); \
	fi

%.clean.${TRGEXT}.gz: %.clean.${SRCEXT}.gz
	@echo "done!"



## store some file size statistics 
## - line 1:  nr-of-lines  nr-of-words  nr-of-characters  nr-of-bytes
## - line 2: nr-of-unique-characters
## - line 3: length-of-longest-line
## - line 4: length-of-longest-word

%.stats: %.gz
	${GZCAT} $< | wc -lwmc > $@
	${GZCAT} $< | sed 's/./& /g' | tr ' ' "\n" | sort -u | wc -l >> $@
	${GZCAT} $< | wc -L >> $@
	${GZCAT} $< | tr ' ' "\n" | wc -L >> $@


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


## minimal pre-processing (is that the same as norm?)
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




## apply the cleanup script from Moses
%.src.clean.${PRE_SRC}: %.src.${PRE_SRC} %.trg.${PRE_TRG}
	rm -f $@.${SRCEXT} $<.${TRGEXT}
	ln -s ${word 1,$^} $<.${SRCEXT}
	ln -s ${word 2,$^} $<.${TRGEXT}
	$(MOSESSCRIPTS)/training/clean-corpus-n.perl \
		-ratio ${NR_TOKEN_RATIO} \
		-max-word-length ${MAX_TOKEN_LENGTH} \
		$< $(SRCEXT) $(TRGEXT) $@ ${MIN_NR_TOKENS} ${MAX_NR_TOKENS}
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

