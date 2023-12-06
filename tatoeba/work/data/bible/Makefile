
SHELL    := bash
PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../../../


include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk

PIVOT = eng
BIBLE_HOME := ${HOME}/work/LumiNMT/data/bibles
BIBLE_LANGS := $(filter-out ${PIVOT},$(sort $(notdir $(shell find ${BIBLE_HOME} -name '*.txt' | cut -f1 -d-))))

BIBLES_TOKENIZED := $(wildcard ${BIBLE_HOME}/*.txt)
BIBLES_DETOKENIZED := $(patsubst ${BIBLE_HOME}/%,detok/%,${BIBLES_TOKENIZED})

DETOKENIZER = ../../../../tools/moses-scripts/scripts/tokenizer/detokenizer.perl

PIVOT2X       := $(patsubst %,${PIVOT}-%,${BIBLE_LANGS})
PIVOT2X_TRAIN := $(patsubst %,train/${PIVOT}-%,${BIBLE_LANGS})


all: detok
	for l in deu eng fra nld por spa; do \
	  ${MAKE} PIVOT=$$l pivot2x; \
	done

pivot2x: ${PIVOT2X}

detok: ${BIBLES_DETOKENIZED}

detok/%.txt: ${BIBLE_HOME}/%.txt
	mkdir -p $(dir $@)
	${DETOKENIZER} -l $(shell iso639 -2 -k -n $(firstword $(subst -, ,$(notdir $<)))) < $< > $@

${PIVOT}-%:
	mkdir -p $@
	rm -f $@/bibles.txt
	-for s in `ls detok/${PIVOT}-*.txt`; do \
	  for t in `ls detok/$(patsubst ${PIVOT}-%,%,$@)-*.txt`; do \
	    if [ $$s != $$t ]; then \
	      paste $$s $$t | grep -v '^	' | grep -v '	$$' | grep -v 'BLANK' >> $@/bibles.txt; \
	    fi \
	  done \
	done
	${UNIQ} < $@/bibles.txt > $@/bibles.uniq
	cut -f1 $@/bibles.uniq | ${GZIP} -c > $@/bibles.${PIVOT}.gz
	cut -f2 $@/bibles.uniq | ${GZIP} -c > $@/bibles.$(patsubst ${PIVOT}-%,%,$@).gz
	rm -f $@/bibles.txt $@/bibles.uniq



## make train/dev/test splits for all language pairs

BIBLE_TRAINSETS = $(patsubst %,train/%.gz,${BIBLE_LANGS})

bible-trainsets: ${BIBLE_TRAINSETS}

train/%.gz:
	@mkdir -p train test dev
	@rm -f $(@:.gz=) $@.tmp
	@echo -n "create $@"
	@for T in ${BIBLE_LANGS}; do \
	  echo -n '.'; \
	  for s in `ls detok/$(notdir $(@:.gz=))-*.txt`; do \
	    for t in `ls detok/$$T-*.txt`; do \
	      if [ $$s != $$t ]; then \
	        paste $$s $$t | grep -v '^	' | grep -v '	$$' | grep -v 'BLANK' >> $@.tmp; \
	      fi \
	    done \
	  done; \
	  ${UNIQ} < $@.tmp | sed "s/^/$$T	/" | ${SHUFFLE} 2>/dev/null > $@.uniq; \
	  head -500 $@.uniq >> test/$(notdir $(@:.gz=)); \
	  head -600 $@.uniq | tail -100 >> dev/$(notdir $(@:.gz=)); \
	  tail -n +601 $@.uniq >> $(@:.gz=); \
	  rm -f $@.tmp $@.uniq; \
	done
	@${GZIP} test/$(notdir $(@:.gz=)) dev/$(notdir $(@:.gz=)) $(@:.gz=)
	@echo "done"


## extract bitexts for a specific language (PIVOT) and all languages that language is aligned to

pivot2x-train: ${PIVOT2X_TRAIN}

train/${PIVOT}-%: train/${PIVOT}.gz
	mkdir -p $@
	${GZIP} -cd < $< | grep '$(patsubst train/${PIVOT}-%,%,$@)	' \
	| tee >(cut -f2 | ${GZIP} -c > $@/bible.${PIVOT}.gz) \
	| ${GZIP} -c $@/bible.$(patsubst train/${PIVOT}-%,%,$@).gz



## all bible bitexts in one file
## (this will be huge and take forever)

bibletranslations.tsv:
	rm -f $@ $@.tmp
	for S in ${BIBLE_LANGS}; do \
	  for T in ${BIBLE_LANGS}; do \
	    if [ ! $$S \> $$T ]; then \
	      echo "process $$S-$$T"; \
	      for s in `ls detok/$$S-*.txt`; do \
	        for t in `ls detok/$$T-*.txt`; do \
	          if [ $$s != $$t ]; then \
	            paste $$s $$t | grep -v '^	' | grep -v '	$$' | grep -v 'BLANK' >> $@.tmp; \
	          fi \
	        done \
	      done; \
	      ${UNIQ} < $@.tmp  | sed "s/^/$$S	$$T	/" >> $@; \
	      rm -f $@.tmp; \
	    fi \
	  done \
	done



BIBLE_LANGPAIRS := $(wildcard *-*)
BIBLE_LANGPAIRS_REVERSE := $(patsubst %,%-reverse,${BIBLE_LANGPAIRS})

reverse-langpairs: ${BIBLE_LANGPAIRS_REVERSE}

${BIBLE_LANGPAIRS_REVERSE}:
	@if [ ! -e $(word 2,$(subst -, ,$@))-$(word 1,$(subst -, ,$@)) ]; then \
	  echo "ln -s $(@:-reverse=) $(word 2,$(subst -, ,$@))-$(word 1,$(subst -, ,$@))"; \
	  ln -s $(@:-reverse=) $(word 2,$(subst -, ,$@))-$(word 1,$(subst -, ,$@)); \
	fi
