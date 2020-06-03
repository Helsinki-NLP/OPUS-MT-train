# -*-makefile-*-
#
# Makefile for running models with data from the Tatoeba Translation Challenge
# https://github.com/Helsinki-NLP/Tatoeba-Challenge
#
#
#---------------------------------------------------------------------
# train and evaluate a single translation pair, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-prepare
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-train
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-eval
#
#
# start job for a single language pair in both directions, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-job
#
#
# start jobs for all pairs in an entire subset:
#
#   make tatoeba-subset-lowest
#   make tatoeba-subset-lower
#   make tatoeba-subset-medium
#   make MODELTYPE=transformer tatoeba-subset-higher
#   make MODELTYPE=transformer tatoeba-subset-highest
#
#
# start jobs for multilingual models from one of the subsets
#
#   make tatoeba-multilingual-subset-lowest
#   make tatoeba-multilingual-subset-lower
#   make tatoeba-multilingual-subset-medium
#   make tatoeba-multilingual-subset-higher
#   make tatoeba-multilingual-subset-highest
#---------------------------------------------------------------------




TATOEBA_DATA   = https://object.pouta.csc.fi/Tatoeba-Challenge
TATOEBA_RAWGIT = https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_WORK   = ${PWD}/work-tatoeba

print-langs:
	echo "${SRCLANGS}"
	echo "${TRGLANGS}"

tatoeba-job:
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba
ifneq (${SRCLANGS},${TRGLANGS})
	${MAKE} reverse-data-tatoeba
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-job-tatoeba
endif

tatoeba-prepare:
	${MAKE} local-config-tatoeba
	${MAKE} data-tatoeba

tatoeba-train:
	${MAKE} train-tatoeba

tatoeba-eval:
	${MAKE} compare-tatoeba


## run all language pairs for a given subset
tatoeba-subset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-job; \
	done

## set FIT_DATA_SIZE for under/over-sampling of data!
## set of language pairs is directly taken from the markdown page at github
tatoeba-multilingual-subset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t clean-data-tatoeba; \
	done
	${MAKE} ${patsubst tatoeba-%.md,tatoeba-trainsize-%.txt,$<}
	( l=`grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']' | tr ' -' "\n\n" | sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
	  s=`head -1 ${patsubst tatoeba-%.md,tatoeba-trainsize-%.txt,$<} | cut -f2 -d' '`; \
	  ${MAKE} FIT_DATA_SIZE=$$s \
		SRCLANGS="$$l" TRGLANGS="$$l" \
		LANGPAIRSTR=${<:.md=} tatoeba-job )

## print all data sizes in this set
tatoeba-trainsize-%.txt: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  echo -n "$$l " >> $@; \
	  zcat ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$l.clean.$$s.gz | wc -l >> $@; \
	done

## get the markdown page for a specific subset
tatoeba-%.md:
	wget -O $@ ${TATOEBA_RAWGIT}/subsets/${patsubst tatoeba-%,%,$@}





## generic target for tatoeba challenge jobs
%-tatoeba: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo $<
	${MAKE} TRAINSET=Tatoeba-train \
		DEVSET=Tatoeba-dev \
		TESTSET=Tatoeba-test \
		TESTSET_NAME=Tatoeba-test \
		SMALLEST_TRAINSIZE=1000 \
		USE_REST_DEVDATA=0 \
		HELDOUTSIZE=0 \
		DEVSIZE=5000 \
		TESTSIZE=10000 \
		DEVMINSIZE=200 \
		WORKHOME=${TATOEBA_WORK} \
		EMAIL= \
	${@:-tatoeba=}



## don't delete those files
.SECONDARY: ${TATOEBA_WORK}/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz


BASIC_FILTERS = | perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' \
		| perl -CS -pe 's/\&\s*\#\s*160\s*\;/ /g' \
		| $(TOKENIZER)/remove-non-printing-char.perl \
		| $(TOKENIZER)/deescape-special-chars.perl

## TODO: should we add $(TOKENIZER)/replace-unicode-punctuation.perl ?
## TODO: add this? sed 's/_/ /g'
## this sed line from https://github.com/aboSamoor/polyglot/issues/71 does not seem to work
#		| sed 's/[\00\01\02\03\04\05\06\07\08\0b\0e\0f\10\11\12\13\14\15\16\17\18\19\1a\1b\1c\1d\1e\1f\7f\80\81\82\83\84\85\86\87\88\89\8a\8b\8c\8d\8e\8f\90\91\92\93\94\95\96\97\98\99\9a\9b\9c\9d\9e\9f]//g'


## TODO: should we do some filtering like bitext-match, OPUS-filter ...
%/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz:
	mkdir -p $@.d
	wget -q -O $@.d/train.tar ${TATOEBA_DATA}/${LANGPAIR}.tar
	tar -C $@.d -xf $@.d/train.tar
	${GZIP} -c < $@.d/data/${LANGPAIR}/test.src > ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz
	${GZIP} -c < $@.d/data/${LANGPAIR}/test.trg > ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz
	${GZIP} -cd < $@.d/data/${LANGPAIR}/train.src.gz ${BASIC_FILTERS} > $@.1
	${GZIP} -cd < $@.d/data/${LANGPAIR}/train.trg.gz ${BASIC_FILTERS} > $@.2
	paste $@.1 $@.2 | scripts/filter/bitext-match-lang.py -s ${SRC} -t ${TRG} > $@.bitext
	rm -f $@.1 $@.2
	if [ -e $@.d/data/${LANGPAIR}/dev.src ]; then \
	  ${GZIP} -c < $@.d/data/${LANGPAIR}/dev.src > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  ${GZIP} -c < $@.d/data/${LANGPAIR}/dev.trg > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz; \
	  cut -f1 $@.bitext | ${GZIP} -c > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  cut -f2 $@.bitext | ${GZIP} -c > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz; \
	else \
	  echo "no devdata available - get top 1000 from training data!"; \
	  cut -f1 $@.bitext | head -1000 | ${GZIP} -c > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  cut -f2 $@.bitext | head -1000 | ${GZIP} -c > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz; \
	  cut -f1 $@.bitext | tail -n +1001 | ${GZIP} -c > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  cut -f2 $@.bitext | tail -n +1001 | ${GZIP} -c > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz; \
	fi
	rm -f $@.bitext
	rm -f $@.d/data/${LANGPAIR}/*
	rmdir $@.d/data/${LANGPAIR}
	rmdir $@.d/data
	rm -f $@.d/train.tar
	rmdir $@.d

%/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"

%/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz %/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"

%/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz %/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"
