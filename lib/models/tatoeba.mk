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
# start job for a single language pair in one direction or
# in both directions, for example:
#
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-job
#   make SRCLANGS=afr TRGLANGS=epo tatoeba-bidirectional-job
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

tatoeba-bidirectional-job:
	${MAKE} tatoeba-prepare
	${MAKE} all-job-tatoeba
ifneq (${SRCLANGS},${TRGLANGS})
	${MAKE} reverse-data-tatoeba
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" tatoeba-prepare
	${MAKE} SRCLANGS="${TRGLANGS}" TRGLANGS="${SRCLANGS}" all-job-tatoeba
endif

tatoeba-prepare: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	${MAKE} local-config-tatoeba
	${MAKE} data-tatoeba

tatoeba-train:
	${MAKE} train-tatoeba

tatoeba-eval:
	${MAKE} compare-tatoeba

tatoeba-step0: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels
tatoeba-step1: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz


## run all language pairs for a given subset
tatoeba-subset-%: tatoeba-%.md
	for l in `grep '\[' $< | cut -f2 -d '[' | cut -f1 -d ']'`; do \
	  s=`echo $$l | cut -f1 -d '-'`; \
	  t=`echo $$l | cut -f2 -d '-'`; \
	  ${MAKE} SRCLANGS=$$s TRGLANGS=$$t tatoeba-bidirectional-job; \
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
# %-tatoeba: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
# %-tatoeba: 	${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels \
#		${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIRSTR}.clean.${TRGEXT}.labels
# %-tatoeba: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
%-tatoeba: ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels
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
		SRCLANGS="${shell cat $<  | sed 's/ *$$//'}" \
		TRGLANGS="${shell cat $(<:.${SRCEXT}.labels=.${TRGEXT}.labels)  | sed 's/ *$$//'}" \
		LANGPAIRSTR=${LANGPAIRSTR} \
		EMAIL= \
	${@:-tatoeba=}


${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.${LANGPAIRSTR}.clean.${SRCEXT}.labels:
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ "$$s" \< "$$t" ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t \
		${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$s-$$t.clean.$$s.gz; \
	    fi \
	  done \
	done
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$s-$$t.clean.$$s.labels ]; then \
		cat ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$s-$$t.clean.$$s.labels \
		>> $@.src; \
	      elif [ -e ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$t-$$s.clean.$$s.labels ]; then \
		cat ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$t-$$s.clean.$$s.labels \
		>> $@.src; \
	      fi \
	    done \
	done
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$s-$$t.clean.$$t.labels ]; then \
		cat ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$s-$$t.clean.$$t.labels \
		>> $@.trg; \
	      elif [ -e ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$t-$$s.clean.$$t.labels ]; then \
		cat ${PWD}/work-tatoeba/data/${PRE}/Tatoeba-train.$$t-$$s.clean.$$t.labels \
		>> $@.trg; \
	      fi \
	    done \
	done
	cat $@.src | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/ *$$//' > $@
	cat $@.trg | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/ *$$//' > $(@:.${SRCEXT}.labels=.${TRGEXT}.labels)
	rm -f $@.src $@.trg



%.${LANGPAIRSTR}.clean.${SRCEXT}.labels: %.${LANGPAIRSTR}.clean.${SRCEXT}.labels
	echo "done"





## don't delete those files
.SECONDARY: ${TATOEBA_WORK}/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_WORK}/data/${PRE}/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz


## modify language IDs in training data to adjust them to test sets
## --> fix codes for chinese
## --> take away regional codes
## --> take away script extension that may come with some codes
FIXLANGIDS = 	| sed 's/zho\(\)_HK/yue\1/;s/zho\(\)_CN/cmn\1/;s/zho\(\)_TW/cmn\1/;' \
		| sed 's/\_[A-Z][A-Z]//' \
		| sed 's/\-[a-z]*//'

## convert Tatoeba Challenge data into the format we need
## - move the data into the right location with the suitable name
## - create devset if not given (part of training data)
## - divide into individual language pairs 
##   (if there is more than one language pair in the collection)
## 
## TODO: should we do some filtering like bitext-match, OPUS-filter ...
%/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz:
	mkdir -p $@.d
	wget -q -O $@.d/train.tar ${TATOEBA_DATA}/${LANGPAIR}.tar
	tar -C $@.d -xf $@.d/train.tar
	mv $@.d/data/${LANGPAIR}/test.src ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}
	mv $@.d/data/${LANGPAIR}/test.trg ${dir $@}Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}
	mv $@.d/data/${LANGPAIR}/test.id  ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id
	if [ -e $@.d/data/${LANGPAIR}/dev.src ]; then \
	  mv $@.d/data/${LANGPAIR}/dev.src ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	  mv $@.d/data/${LANGPAIR}/dev.trg ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	  mv $@.d/data/${LANGPAIR}/dev.id  ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.src.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.trg.gz > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.id.gz | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	else \
	  echo "no devdata available - get top 1000 from training data!"; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.src.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | head -1000 > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | head -1000 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-dev.${LANGPAIR}.clean.id; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.src.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.trg.gz | tail -n +1001 > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}; \
	  ${ZCAT} $@.d/data/${LANGPAIR}/train.id.gz  | tail -n +1001 | cut -f2,3 $(FIXLANGIDS) > ${dir $@}Tatoeba-train.${LANGPAIR}.clean.id; \
	fi
#######################################
# labels in the data
# TODO: should we take all in all data sets?
# NOW: only look for the ones in test data
#######################################
#	cut -f1 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)
#	cut -f2 ${dir $@}Tatoeba-*.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)
	cut -f1 ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)
	cut -f2 ${dir $@}Tatoeba-test.${LANGPAIR}.clean.id | sort -u | tr "\n" ' ' > $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)
	rm -f $@.d/data/${LANGPAIR}/*
	rmdir $@.d/data/${LANGPAIR}
	rmdir $@.d/data
	rm -f $@.d/train.tar
	rmdir $@.d
#######################################
# make data sets for individual 
# language pairs from the Tatoeba data
# TODO: now we only grep for langpairs 
#       available in test data
# --> should we also include other 
#     training data with a dummy label?
# --> how do we efficiently grep for 
#     everything that is not one of the langpairs?
#     grep -v and a big list of alternative lang-pairs ...
#######################################
	for s in `cat $(@:.${SRCEXT}.gz=.${SRCEXT}.labels)`; do \
	  for t in `cat $(@:.${SRCEXT}.gz=.${TRGEXT}.labels)`; do \
	    if [ "$$s" \< "$$t" ]; then \
	      echo "extract $$s-$$t data"; \
	      for d in dev test train; do \
	        paste ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id \
		      ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT} \
		      ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT} |\
	        grep -P "$$s\t$$t\t" > ${dir $@}Tatoeba-$$d.$$s-$$t; \
	        if [ -s ${dir $@}Tatoeba-$$d.$$s-$$t ]; then \
	          cut -f3 ${dir $@}Tatoeba-$$d.$$s-$$t | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$s-$$t.clean.$$s.gz; \
	          cut -f4 ${dir $@}Tatoeba-$$d.$$s-$$t | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$s-$$t.clean.$$t.gz; \
	        fi; \
	        rm -f ${dir $@}Tatoeba-$$d.$$s-$$t; \
	      done \
	    else \
	      echo "extract $$t-$$s data"; \
	      for d in dev test train; do \
	        paste ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id \
		      ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT} \
		      ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT} |\
	        grep -P "$$s\t$$t\t" > ${dir $@}Tatoeba-$$d.$$t-$$s; \
	        if [ -s ${dir $@}Tatoeba-$$d.$$t-$$s ]; then \
	          cut -f3 ${dir $@}Tatoeba-$$d.$$t-$$s | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$t-$$s.clean.$$t.gz; \
	          cut -f4 ${dir $@}Tatoeba-$$d.$$t-$$s | ${GZIP} -c > ${dir $@}Tatoeba-$$d.$$t-$$s.clean.$$s.gz; \
	        fi; \
	        rm -f ${dir $@}Tatoeba-$$d.$$t-$$s; \
	      done \
	    fi \
	  done \
	done
#######################################
# finally, compress the big datafiles
# and cleanup
#######################################
	for d in dev test train; do \
	  if [ ! -e ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}.gz ]; then \
	    ${GZIP} -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}; \
	    ${GZIP} -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}; \
	  else \
	    rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${SRCEXT}; \
	    rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.${TRGEXT}; \
	  fi; \
	  rm -f ${dir $@}Tatoeba-$$d.${LANGPAIR}.clean.id; \
	done


%/Tatoeba-train.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"

%/Tatoeba-dev.${LANGPAIR}.clean.${SRCEXT}.gz %/Tatoeba-dev.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"

%/Tatoeba-test.${LANGPAIR}.clean.${SRCEXT}.gz %/Tatoeba-test.${LANGPAIR}.clean.${TRGEXT}.gz: %/Tatoeba-train.${LANGPAIR}.clean.${SRCEXT}.gz
	echo "done!"
