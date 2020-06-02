# -*-makefile-*-

TATOEBA_DATA   = https://object.pouta.csc.fi/Tatoeba-Challenge
TATOEBA_RAWGIT = https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_WORK   = ${PWD}/work-tatoeba


tatoeba-prepare:
	${MAKE} local-config-tatoeba
	${MAKE} data-tatoeba

tatoeba-train:
	${MAKE} train-tatoeba

tatoeba-eval:
	${MAKE} compare-tatoeba


## run all language pairs for a given subset
tatoeba-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-prepare; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t all-job-tatoeba; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t reverse-data-tatoeba; \
	  ${MAKE} SRCLANGS=$$t TRGLANGS=$$s all-job-tatoeba; \
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
	${@:-tatoeba=}



## don't delete those files
.SECONDARY: ${TATOEBA_WORK}/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz

## TODO: should we do some filtering like bitext-match, OPUS-filter ...
%/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz:
	mkdir -p $@.d
	wget -q -O $@.d/train.tar ${TATOEBA_DATA}/${LANGPAIR}.tar
	tar -C $@.d -xf $@.d/train.tar
	gzip -c < $@.d/data/${LANGPAIR}/test.src > ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz
	gzip -c < $@.d/data/${LANGPAIR}/test.trg > ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz
	if [ -e $@.d/data/${LANGPAIR}/dev.src ]; then \
	  gzip -c < $@.d/data/${LANGPAIR}/dev.src > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  gzip -c < $@.d/data/${LANGPAIR}/dev.trg > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz; \
	  mv $@.d/data/${LANGPAIR}/train.src.gz ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  mv $@.d/data/${LANGPAIR}/train.trg.gz ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz; \
	else \
	  echo "no devdata available - get top 1000 from training data!"; \
	  zcat $@.d/data/${LANGPAIR}/train.src.gz | tail -n +1001 | gzip -c > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  zcat $@.d/data/${LANGPAIR}/train.trg.gz | tail -n +1001 | gzip -c > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz; \
	  zcat $@.d/data/${LANGPAIR}/train.src.gz | head -1000 | gzip -c > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz; \
	  zcat $@.d/data/${LANGPAIR}/train.trg.gz | head -1000 | gzip -c > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz; \
	fi
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
