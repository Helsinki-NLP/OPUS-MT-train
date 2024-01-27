
SHELL    := bash
PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../../../


include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk

PIVOT = eng
BIBLE_HOME := ${HOME}/work/LumiNMT/data/bibles
BIBLE_LANGS := $(sort $(notdir $(shell find ${BIBLE_HOME} -name '*.txt' | cut -f1 -d-)))

BIBLES_TOKENIZED := $(wildcard ${BIBLE_HOME}/*.txt)
BIBLES_DETOKENIZED := $(patsubst ${BIBLE_HOME}/%,detok/%,${BIBLES_TOKENIZED})
BIBLES_NONEMPTY := $(patsubst ${BIBLE_HOME}/%.txt,detok/%.nonempty,${BIBLES_TOKENIZED})

DETOKENIZER = ../../../../tools/moses-scripts/scripts/tokenizer/detokenizer.perl

PIVOT2X         := $(patsubst %,${PIVOT}-%,$(filter-out ${PIVOT},${BIBLE_LANGS}))
PIVOT2X_TRAIN   := $(patsubst %,train-split/${PIVOT}-%,$(filter-out ${PIVOT},${BIBLE_LANGS}))


MUL2MUL_WORKDIR := ../../mul-mul


all: detok
	for l in deu eng fra nld por spa; do \
	  ${MAKE} PIVOT=$$l pivot2x; \
	done

big-lang-train:
	for l in deu eng fra por spa; do \
	  ${MAKE} PIVOT=$$l pivot2x-train; \
	done

other-lang-train:
	for l in fin nob nno swe rus; do \
	  ${MAKE} PIVOT=$$l pivot2x-train; \
	done




## extract bitexts for a specific language (PIVOT) and all languages that language is aligned to
## this includes ALL lines (no dedicated dev or test sets!)
pivot2x: ${PIVOT2X}

## extract bitexts for a specific language (PIVOT) and all languages that language is aligned to
## this takes data from the training data (leaving dev and test sets)
pivot2x-train: ${PIVOT2X_TRAIN}





detok: ${BIBLES_DETOKENIZED}

detok/%.txt: ${BIBLE_HOME}/%.txt
	mkdir -p $(dir $@)
	${DETOKENIZER} -l $(shell iso639 -2 -k -n $(firstword $(subst -, ,$(notdir $<)))) < $< > $@

${PIVOT2X}: ${PIVOT}-%:
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
## we will use lines 29222 - 30221 for test
##             lines 28722 - 29221 for dev
## all other lines as training data
## Why? Because those lines have quite a good coverage across all bible translations

BIBLE_TRAINSETS := $(patsubst %,train/%.gz,${BIBLE_LANGS})
BIBLE_DEVSETS   := $(patsubst detok/%.txt,dev/%_28721-29220.txt,${BIBLES_DETOKENIZED})
BIBLE_TESTSETS  := $(patsubst detok/%.txt,test/%_29221-30221.txt,${BIBLES_DETOKENIZED})


BIBLE_TRAINTOK  := $(patsubst %,train-tokenized/%.gz,${BIBLE_LANGS})


bible-datasets: ${BIBLE_DEVSETS} ${BIBLE_TESTSETS} ${BIBLE_TRAINSETS}

test/%_29221-30221.txt: detok/%.txt
	@mkdir -p test
	@awk 'NR>=29222 && NR<=30221' $< > $@

dev/%_28721-29220.txt: detok/%.txt
	@mkdir -p dev
	@awk 'NR>=28722 && NR<=29221' $< > $@

train/%.gz:
	@mkdir -p train
	@rm -f $(@:.gz=) $@.tmp
	@echo -n "create $@"
	@for T in ${BIBLE_LANGS}; do \
	  echo -n '.'; \
	  for s in `ls detok/$(notdir $(@:.gz=))-*.txt`; do \
	    for t in `ls detok/$$T-*.txt`; do \
	      if [ $$s != $$t ]; then \
	        paste $$s $$t | awk 'NR<28722 || NR>30221'   | grep -v '^	' | grep -v '	$$' | grep -v 'BLANK' >> $@.tmp; \
	      fi \
	    done \
	  done; \
	  ${UNIQ} < $@.tmp | sed "s/^/$$T	/" | ${SHUFFLE} 2>/dev/null >> $(@:.gz=); \
	  rm -f $@.tmp; \
	done
	@${GZIP} $(@:.gz=)
	@echo "done"


train-split/${PIVOT}-%: train/${PIVOT}.gz
	mkdir -p $@
	${GZIP} -cd < $< | grep '^$(patsubst train-split/${PIVOT}-%,%,$@)	' \
	| tee >(cut -f2 | ${GZIP} -c > $@/bible.${PIVOT}.gz) \
	| cut -f3 | ${GZIP} -c > $@/bible.$(patsubst train-split/${PIVOT}-%,%,$@).gz
	-cd train-split && ln -s $(notdir $@) $(patsubst train-split/${PIVOT}-%,%,$@)-${PIVOT}


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


get-nonempty-lines: ${BIBLES_NONEMPTY}

detok/%.nonempty: detok/%.txt
	grep -E --line-number -v '^(|BLANK)$$' $< | cut -f1 -d: > $@




#####################################################################################


.PHONY: tokenize tokenize-opus tokenize-bibles

tokenize: tokenize-opus tokenize-bibles

tokenize-opus: ${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm64k.gz \
		${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.trg.clean.spm64k.gz

tokenize-opus-src: ${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm64k.gz
tokenize-opus-trg: ${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.trg.clean.spm64k.gz

tokenize-bibles: ${BIBLE_TRAINTOK}


${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm64k.gz: \
			${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm32k.gz \
			${MUL2MUL_WORKDIR}/train/opus+bible.spm64k-model
	${GZIP} -cd < $< \
	| parallel --pipe --keep-order -q -L10000 sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' \
	| parallel --pipe --keep-order -q -L10000 cut -f2- -d' ' \
	| parallel --pipe --keep-order -q -L10000 spm_encode --model $(word 2,$^) > $@.src
	paste -d ' ' <(${GZIP} -cd < $< | cut -f1 -d' ') $@.src | ${GZIP} -c > $@
	rm -f $@.src

${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.trg.clean.spm64k.gz: \
			${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.trg.clean.spm32k.gz \
			${MUL2MUL_WORKDIR}/train/opus+bible.spm64k-model
	${GZIP} -cd < $< \
	| parallel --pipe --keep-order -q -L10000 sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' \
	| parallel --pipe --keep-order -q -L10000 spm_encode --model $(word 2,$^) \
	| ${GZIP} -c > $@


## language label files for the bible model

BIBLE_LANGLABEL_FILES = ${MUL2MUL_WORKDIR}/bibles-langlabels.src ${MUL2MUL_WORKDIR}/jhubc-langlabels.trg \
			${MUL2MUL_WORKDIR}/bibles-languages.src ${MUL2MUL_WORKDIR}/jhubc-languages.trg

OPUS_LANGLABEL_FILES = 	${MUL2MUL_WORKDIR}/opusTCv20230926+jhubc-langlabels.src \
			${MUL2MUL_WORKDIR}/opusTCv20230926+jhubc-langlabels.trg \
			${MUL2MUL_WORKDIR}/opusTCv20230926+jhubc-languages.src \
			${MUL2MUL_WORKDIR}/opusTCv20230926+jhubc-languages.trg

bible-langlabel-files: ${BIBLE_LANGLABEL_FILES}
opus-langlabel-files: ${OPUS_LANGLABEL_FILES}

${BIBLE_LANGLABEL_FILES}:
	find detok -name '*.txt' -printf "%f\n" | cut -f1 -d- | sort -u | tr "\n" ' ' > $@

${OPUS_LANGLABEL_FILES}: ${MUL2MUL_WORKDIR}/opusTCv20230926+jhubc-%: ${MUL2MUL_WORKDIR}/bibles-%
	cat ${MUL2MUL_WORKDIR}/opusTCv20230926-langlabels.src $< | tr ' ' "\n" | sort -u | tr "\n" ' ' > $@




## sentence piece model from bible data and OPUS mul-mul data

bible-spm: ${MUL2MUL_WORKDIR}/train/opus+bible.spm64k-model

${MUL2MUL_WORKDIR}/train/opus+bible.spm64k-model:
	pigz -cd < ${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm64k.gz \
	| sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' \
	| head -1000000 > /scratch/project_462000088/tmp/mul.txt
	find detok/ -name '*.txt' | xargs cat | terashuf \
	| head -1000000 >> /scratch/project_462000088/tmp/mul.txt
	spm_train  --byte_fallback \
	   --model_prefix=$@ \
	   --vocab_size=64000 \
	   --input=/scratch/project_462000088/tmp/mul.txt \
	   --input_sentence_size 2000000 \
	   --shuffle_input_sentence 0 \
	   --character_coverage=0.9995 \
	   --hard_vocab_limit=false
	rm -f /scratch/project_462000088/tmp/mul.txt
	mv $@.model $@


train-tokenized/%.gz: train/%.gz ${MUL2MUL_WORKDIR}/train/opus+bible.spm64k-model
	mkdir -p ${dir $@}
	${GZIP} -cd < $< | cut -f2 \
	| parallel --pipe --keep-order -q -L10000 spm_encode --model $(word 2,$^) > $@.src
	${GZIP} -cd < $< | cut -f3 \
	| parallel --pipe --keep-order -q -L10000 spm_encode --model $(word 2,$^) > $@.trg
	paste <(${GZIP} -cd < $< | cut -f1) $@.src $@.trg | ${GZIP} -c > $@
	rm -f $@.src $@.trg



bible-traindata: ${MUL2MUL_WORKDIR}/train/jhubc.src.clean.spm64k.gz

${MUL2MUL_WORKDIR}/train/jhubc.src.clean.spm64k.gz:
	find train-tokenized -name '*.gz' \
	| xargs zcat \
	| sed 's/^\([^	]*\)	/>>\1<< /' \
	| terashuf \
	| tee >(cut -f1 | ${GZIP} -c >$@) \
	| cut -f2 \
	| ${GZIP} -c > $(patsubst %.src.clean.spm64k.gz,%.trg.clean.spm64k.gz,$@)

${MUL2MUL_WORKDIR}/train/jhubc.trg.clean.spm64k.gz: ${MUL2MUL_WORKDIR}/train/jhubc.src.clean.spm64k.gz
	@echo "done!"


# ${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt+jhubc.src.clean.spm64k.gz: \
# 			${MUL2MUL_WORKDIR}/train/jhubc.src.clean.spm64k.gz \
# 			${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm64k.gz
# 	zcat $^ > $@.tmpsrc
# 	zcat $(patsubst %.src.clean.spm64k.gz,%.trg.clean.spm64k.gz,$^) > $@.tmptrg
# 	paste $@.tmpsrc $@.tmptrg | terashuf | tee >(cut -f1 | ${GZIP} -c > $@) \
#	| cut -f2 \
#	| ${GZIP} -c > $(patsubst %.src.clean.spm64k.gz,%.trg.clean.spm64k.gz,$@)


opus_bible-traindata: ${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt+jhubc.src.clean.spm64k.gz

${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt+jhubc.src.clean.spm64k.gz:
	if [ ! -e $@.tmp.gz ]; then \
	  paste <(${GZIP} -cd <${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.src.clean.spm64k.gz) \
		<(${GZIP} -cd <${MUL2MUL_WORKDIR}/train/opusTCv20230926+bt.trg.clean.spm64k.gz) \
	  | parallel --pipe --keep-order -q -L10000 --max-procs 8 sed 's/^>>\([^ ]*\)<< /\1	/' \
	  | ${GZIP} -c > $@.tmp.gz; \
	fi
	zcat $@.tmp.gz train-tokenized/*.gz \
	| parallel --pipe --keep-order -q -L10000 sed 's/^\([^	]*\)	/>>\1<< /' \
	| MEMORY=16 terashuf \
	| tee >(cut -f1 | ${GZIP} -c >$@) \
	| cut -f2 \
	| ${GZIP} -c > $(patsubst %.src.clean.spm64k.gz,%.trg.clean.spm64k.gz,$@)
	rm -f $@.tmp.gz




bible-traindata-fast: ${MUL2MUL_WORKDIR}/train/jhubc_fast.src.clean.spm64k.gz

${MUL2MUL_WORKDIR}/train/jhubc_fast.src.clean.spm64k.gz:
	find train-tokenized -name '*.gz' \
	| xargs zcat \
	| parallel --pipe --keep-order -q -L10000 sed 's/^\([^	]*\)	/>>\1<< /' \
	| MEMORY=56 terashuf \
	| tee >(cut -f1 | ${GZIP} -c >$@) \
	| cut -f2 \
	| ${GZIP} -c > $(patsubst %.src.clean.spm64k.gz,%.trg.clean.spm64k.gz,$@)
