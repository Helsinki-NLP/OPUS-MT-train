# -*-makefile-*-
#
# create data files for taining, validation and testing
# 
#  - combine all bitexts in TRAINSET
#  - add backtranslation, pivoted data if necessary
#  - add language labels if necessary (multi-target models)
#  - over/under-sampling of training data if necessary (multilingual models)
#  - shuffle dev/test data and divide into to disjoint sets
#  - reverse data sets for the other translation direction (bilingual models only)
#  - run word alignment if necessary (models with guided alignment = transformer-align)
#
#
# TODO: write data info to some model-specific file insetad of README.md
#       (applies for train/val/test!)


## training data size (generates count if not in README.md)
TRAINDATA_SIZE = ${shell \
	if [ -e ${WORKDIR}/train/README.md ]; then \
	  if [ `grep 'total size (${DATASET}):' ${WORKDIR}/train/README.md | wc -l` -gt 0 ]; then \
	    grep 'total size (${DATASET}):' ${WORKDIR}/train/README.md | cut -f2 -d':' ; \
	  elif [ -e ${TRAIN_SRC}.clean.${PRE_SRC}.gz ]; then \
	    echo -n '* total size (${DATASET}): ' >> ${WORKDIR}/train/README.md; \
	    ${GZIP} -cd < ${TRAIN_SRC}.clean.${PRE_SRC}.gz | wc -l >> ${WORKDIR}/train/README.md; \
	    grep 'total size (${DATASET}):' ${WORKDIR}/train/README.md | cut -f2 -d':' ; \
	  fi \
	elif [ -e ${TRAIN_SRC}.clean.${PRE_SRC}.gz ]; then \
	  echo '\# ${DATASET}'                  >> ${WORKDIR}/train/README.md; \
	  echo ''                               >> ${WORKDIR}/train/README.md; \
	  echo -n '* total size (${DATASET}): ' >> ${WORKDIR}/train/README.md; \
	  ${GZIP} -cd < ${TRAIN_SRC}.clean.${PRE_SRC}.gz | wc -l >> ${WORKDIR}/train/README.md; \
	  grep 'total size (${DATASET}):' ${WORKDIR}/train/README.md | cut -f2 -d':' ; \
	fi }


## look for cleanup scripts and put them into a pipe
## they should be executable and should basically read STDIN and print to STDOUT
## no further arguments are supported

ifneq (${wildcard ${REPOHOME}scripts/cleanup/${SRC}},)
  SRC_CLEANUP_SCRIPTS = | ${subst ${SPACE}, | ,${shell find ${REPOHOME}scripts/cleanup/${SRC} -executable -type f}}
endif

ifneq (${wildcard ${REPOHOME}scripts/cleanup/${TRG}},)
  TRG_CLEANUP_SCRIPTS = | ${subst ${SPACE}, | ,${shell find ${REPOHOME}scripts/cleanup/${TRG} -executable -type f}}
endif


##-------------------------------------------------------------
## backtranslated data and pivot-based synthetic training data
##-------------------------------------------------------------

## back translation data
## - use only the latest backtranslations
##   if such a subdir exists

BACKTRANS_HOME    ?= backtranslate
FORWARDTRANS_HOME ?= ${BACKTRANS_HOME}
PIVOTTRANS_HOME   ?= pivoting


ifneq (${wildcard ${BACKTRANS_HOME}/${TRG}-${SRC}/latest},)
  BACKTRANS_DIR = ${BACKTRANS_HOME}/${TRG}-${SRC}/latest
else
  BACKTRANS_DIR = ${BACKTRANS_HOME}/${TRG}-${SRC}
endif


## TODO: make it possible to select only parts of the BT data
## ---> use TRAINDATA_SIZE to take max the same amount of all shuffled BT data

# back-translation data (target-to-source)
ifeq (${USE_BACKTRANS},1)
  BACKTRANS_SRC = ${sort ${wildcard ${BACKTRANS_DIR}/*.${SRCEXT}.gz}}
  BACKTRANS_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${BACKTRANS_SRC}}
endif

# forward-translation data (source-to-target)
ifeq (${USE_FORWARDTRANS},1)
  FORWARDTRANS_SRC = ${sort ${wildcard ${FORWARDTRANS_HOME}/${SRC}-${TRG}/latest/*.${SRCEXT}.gz}}
  FORWARDTRANS_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${FORWARDTRANS_SRC}}
endif

# forward-translation data (source-to-target)
# filtered by reconstruction scores (ce filter)
ifneq (${USE_FORWARDTRANS_SELECTED},)
  FORWARDTRANS_SRC += ${sort ${wildcard ${FORWARDTRANS_HOME}/${SRC}-${TRG}/latest/*.${SRCEXT}.best${USE_FORWARDTRANS_SELECTED}.gz}}
  FORWARDTRANS_TRG += ${sort ${wildcard ${FORWARDTRANS_HOME}/${SRC}-${TRG}/latest/*.${TRGEXT}.best${USE_FORWARDTRANS_SELECTED}.gz}}
endif

## selected by "raw" (unnormalised) scores
ifneq (${USE_FORWARDTRANS_SELECTED_RAW},)
  FORWARDTRANS_SRC += ${sort ${wildcard ${FORWARDTRANS_HOME}/${SRC}-${TRG}/latest/*.${SRCEXT}.rawbest${USE_FORWARDTRANS_SELECTED_RAW}.gz}}
  FORWARDTRANS_TRG += ${sort ${wildcard ${FORWARDTRANS_HOME}/${SRC}-${TRG}/latest/*.${TRGEXT}.rawbest${USE_FORWARDTRANS_SELECTED_RAW}.gz}}
endif


# forward-translation data of monolingual data (source-to-target)
ifeq (${USE_FORWARDTRANSMONO},1)
  FORWARDTRANSMONO_SRC = ${sort ${wildcard ${BACKTRANS_HOME}/${SRC}-${TRG}/latest/*.${SRCEXT}.gz}}
  FORWARDTRANSMONO_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${FORWARDTRANSMONO_SRC}}
endif

# forward translation using pivoting (target language is automatically created)
ifeq (${USE_FORWARD_PIVOTING},1)
  PIVOTING_SRC = ${sort ${wildcard ${PIVOTTRANS_HOME}/${TRG}-${SRC}/latest/*.${SRCEXT}.gz}}
  PIVOTING_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${PIVOTING_SRC}}
endif

# backward translation using pivoting (source language is automatically created)
ifeq (${USE_BACKWARD_PIVOTING},1)
  PIVOTING_SRC = ${sort ${wildcard ${PIVOTTRANS_HOME}/${SRC}-${TRG}/latest/*.${SRCEXT}.gz}}
  PIVOTING_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${PIVOTING_SRC}}
endif

# pivot-based data augmentation data (in both directions)
ifeq (${USE_PIVOTING},1)
  PIVOTING_SRC = ${sort ${wildcard ${PIVOTTRANS_HOME}/${SRC}-${TRG}/latest/*.${SRCEXT}.gz} \
			${wildcard ${PIVOTTRANS_HOME}/${TRG}-${SRC}/latest/*.${SRCEXT}.gz}}
  PIVOTING_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${PIVOTING_SRC}}
endif


print-datasets:
	@echo ${TATOEBA_TRAINSET}
	@echo ${TRAINSET}
	@echo "all data:"
	@echo ${CLEAN_TRAIN_SRC}
	@echo ${CLEAN_TRAIN_TRG}
	@echo "back-translation data:"
	@echo ${BACKTRANS_SRC} 
	@echo ${BACKTRANS_TRG} 
	@echo "forward translation data:"
	@echo ${FORWARDTRANS_SRC} 
	@echo ${FORWARDTRANS_TRG} 
	@echo "monolingual forward translation data:"
	@echo ${FORWARDTRANSMONO_SRC} 
	@echo ${FORWARDTRANSMONO_TRG} 
	@echo "pivot-based translation data:"
	@echo ${PIVOTING_SRC}
	@echo ${PIVOTING_TRG}

##-------------------------------------------------------------
## data sets (train/dev/test)
##-------------------------------------------------------------

## data sets to be included in the train/dev/test sets
## with some basic pre-processing (see lib/preprocess.mk)

CLEAN_TRAIN_SRC    = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${SRCEXT}.gz,${TRAINSET}} \
			${BACKTRANS_SRC} ${FORWARDTRANS_SRC} ${FORWARDTRANSMONO_SRC} ${PIVOTING_SRC}
CLEAN_TRAIN_TRG    = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${TRGEXT}.gz,${TRAINSET}} \
			${BACKTRANS_TRG} ${FORWARDTRANS_TRG} ${FORWARDTRANSMONO_TRG} ${PIVOTING_TRG}

CLEAN_DEV_SRC      = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.${CLEAN_DEVDATA_TYPE}.${SRCEXT}.gz,${DEVSET}}
CLEAN_DEV_TRG      = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${CLEAN_DEV_SRC}}

CLEAN_TEST_SRC     = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.${CLEAN_TESTDATA_TYPE}.${SRCEXT}.gz,${TESTSET}}
CLEAN_TEST_TRG     = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${CLEAN_TEST_SRC}}

CLEAN_TEST_SRC_STATS = ${CLEAN_TEST_SRC:.gz=.stats}
CLEAN_TEST_TRG_STATS = ${CLEAN_TEST_TRG:.gz=.stats}


DATA_SRC := ${sort ${CLEAN_TRAIN_SRC} ${CLEAN_DEV_SRC} ${CLEAN_TEST_SRC}}
DATA_TRG := ${sort ${CLEAN_TRAIN_TRG} ${CLEAN_DEV_TRG} ${CLEAN_TEST_TRG}}


##-------------------------------------------------------------
## make data in reverse direction without re-doing word alignment etc ...
## ---> this is dangerous when things run in parallel
## ---> only works for bilingual models
##-------------------------------------------------------------

REV_LANGSTR = ${subst ${SPACE},+,$(TRGLANGS)}-${subst ${SPACE},+,$(SRCLANGS)}
REV_WORKDIR = ${WORKHOME}/${REV_LANGSTR}

.PHONY: reverse-data
reverse-data:
ifeq (${PRE_SRC},${PRE_TRG})
ifeq (${words ${SRCLANGS}},1)
ifeq (${words ${TRGLANGS}},1)
	mkdir -p ${REV_WORKDIR}/train
	-if [ -e ${TRAIN_SRC}.clean.${PRE_SRC}.gz ]; then \
	  ln -s ${TRAIN_SRC}.clean.${PRE_SRC}.gz ${REV_WORKDIR}/train/${notdir ${TRAIN_TRG}.clean.${PRE_TRG}.gz}; \
	  ln -s ${TRAIN_TRG}.clean.${PRE_TRG}.gz ${REV_WORKDIR}/train/${notdir ${TRAIN_SRC}.clean.${PRE_SRC}.gz}; \
	  cp ${WORKDIR}/train/README.md ${REV_WORKDIR}/train/README.md; \
	fi
	-if [ -e ${SUBWORD_SRC_MODEL} ]; then \
	  ln -s ${SUBWORD_SRC_MODEL} ${REV_WORKDIR}/train/${notdir ${SUBWORD_TRG_MODEL}}; \
	fi
	-if [ -e ${SUBWORD_TRG_MODEL} ]; then \
	  ln -s ${SUBWORD_TRG_MODEL} ${REV_WORKDIR}/train/${notdir ${SUBWORD_SRC_MODEL}}; \
	fi
	-if [ -e ${SUBWORD_SRC_MODEL}.vocab ]; then \
	  ln -s ${SUBWORD_SRC_MODEL}.vocab ${REV_WORKDIR}/train/${notdir ${SUBWORD_TRG_MODEL}}.vocab; \
	fi
	-if [ -e ${SUBWORD_TRG_MODEL}.vocab ]; then \
	  ln -s ${SUBWORD_TRG_MODEL}.vocab ${REV_WORKDIR}/train/${notdir ${SUBWORD_SRC_MODEL}}.vocab; \
	fi
	-if [ -e ${TRAIN_ALG} ]; then \
	  if [ ! -e ${REV_WORKDIR}/train/${notdir ${TRAIN_ALG}} ]; then \
	    ${GZIP} -cd < ${TRAIN_ALG} | ${MOSESSCRIPTS}/generic/reverse-alignment.perl |\
	    ${GZIP} -c > ${REV_WORKDIR}/train/${notdir ${TRAIN_ALG}}; \
	  fi \
	fi
	-if [ -e ${DEV_SRC}.${PRE_SRC} ]; then \
	  mkdir -p ${REV_WORKDIR}/val; \
	  ln -s ${DEV_SRC}.${PRE_SRC} ${REV_WORKDIR}/val/${notdir ${DEV_TRG}.${PRE_TRG}}; \
	  ln -s ${DEV_TRG}.${PRE_TRG} ${REV_WORKDIR}/val/${notdir ${DEV_SRC}.${PRE_SRC}}; \
	  ln -s ${DEV_SRC} ${REV_WORKDIR}/val/${notdir ${DEV_TRG}}; \
	  ln -s ${DEV_TRG} ${REV_WORKDIR}/val/${notdir ${DEV_SRC}}; \
	  ln -s ${DEV_SRC}.shuffled.gz ${REV_WORKDIR}/val/${notdir ${DEV_SRC}.shuffled.gz}; \
	  ln -s ${DEV_SRC}.notused.gz ${REV_WORKDIR}/val/${notdir ${DEV_TRG}.notused.gz}; \
	  ln -s ${DEV_TRG}.notused.gz ${REV_WORKDIR}/val/${notdir ${DEV_SRC}.notused.gz}; \
	  cp ${WORKDIR}/val/README.md ${REV_WORKDIR}/val/README.md; \
	fi
	-if [ -e ${TEST_SRC} ]; then \
	  mkdir -p ${REV_WORKDIR}/test; \
	  ln -s ${TEST_SRC} ${REV_WORKDIR}/test/${notdir ${TEST_TRG}}; \
	  ln -s ${TEST_TRG} ${REV_WORKDIR}/test/${notdir ${TEST_SRC}}; \
	  cp ${WORKDIR}/test/README.md ${REV_WORKDIR}/test/README.md; \
	fi
	-if [ -e ${MODEL_SRCVOCAB} ]; then \
	  ln -s ${MODEL_SRCVOCAB} ${REV_WORKDIR}/${notdir ${MODEL_TRGVOCAB}}; \
	fi
	-if [ -e ${MODEL_TRGVOCAB} ]; then \
	  ln -s ${MODEL_TRGVOCAB} ${REV_WORKDIR}/${notdir ${MODEL_SRCVOCAB}}; \
	fi
	-if [ -e ${MODEL_VOCAB} ]; then \
	  ln -s ${MODEL_VOCAB} ${REV_WORKDIR}/${notdir ${MODEL_VOCAB}}; \
	fi
##
## this is a bit dangerous with some trick to 
## swap parameters between SRC and TRG
##
	-if [ -e ${WORKDIR}/${MODELCONFIG} ]; then \
	   if [ ! -e ${REV_WORKDIR}/${MODELCONFIG} ]; then \
	     cat ${WORKDIR}/${MODELCONFIG} |\
	     sed -e 's/SRC/TTT/g;s/TRG/SRC/g;s/TTT/TRG/' |\
	     grep -v LANGPAIRSTR > ${REV_WORKDIR}/$(notdir ${MODELCONFIG}); \
	   fi \
	fi
endif
endif
endif




.PHONY: clean-data rawdata
clean-data rawdata:
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    echo "..... create raw data for $$s-$$t"; \
	    ${MAKE} SRC=$$s TRG=$$t clean-data-source; \
	  done \
	done

.PHONY: clean-data-source
clean-data-source: 
	@${MAKE} ${CLEAN_TEST_SRC} ${CLEAN_TEST_TRG}
	@${MAKE} ${CLEAN_TEST_SRC_STATS} ${CLEAN_TEST_TRG_STATS}
	@${MAKE} ${DATA_SRC} ${DATA_TRG}



## monolingual data sets (for sentence piece models)
.INTERMEDIATE: ${LOCAL_MONO_DATA}.${PRE} ${LOCAL_MONO_DATA}.raw

.PHONY: mono-data
mono-data: ${LOCAL_MONO_DATA}.${PRE}




## word alignment used for guided alignment
## (always remove intermediate files)

.INTERMEDIATE: ${LOCAL_TRAIN_SRC}.algtmp ${LOCAL_TRAIN_TRG}.algtmp 

${LOCAL_TRAIN_SRC}.algtmp: ${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz
	mkdir -p ${dir $@}
	${GZIP} -cd < $< > $@

${LOCAL_TRAIN_TRG}.algtmp: ${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz
	mkdir -p ${dir $@}
	${GZIP} -cd < $< > $@



## max number of lines in a corpus for running word alignment
## (split into chunks of max that size before aligning)

MAX_WORDALIGN_SIZE = 5000000
# MAX_WORDALIGN_SIZE = 10000000
# MAX_WORDALIGN_SIZE = 25000000

## nr of simultaneous word alignment jobs
## (assuming that each of them occupies up to 6 cores
NR_ALIGN_JOBS ?=  $$(( ${CPU_CORES} / 6 + 1 ))

## job forcing doesn't work within recipes
#	    ${MAKE} -j ${NR_ALIGN_JOBS} $$a

${TRAIN_ALG}: 	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
		${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz
	${MAKE} ${LOCAL_TRAIN_SRC}.algtmp ${LOCAL_TRAIN_TRG}.algtmp
	if  [ `head $(LOCAL_TRAIN_SRC).algtmp | wc -l` -gt 0 ]; then \
	  mkdir -p $(LOCAL_TRAIN_SRC).algtmp.d; \
	  mkdir -p $(LOCAL_TRAIN_TRG).algtmp.d; \
	  split -l ${MAX_WORDALIGN_SIZE} $(LOCAL_TRAIN_SRC).algtmp $(LOCAL_TRAIN_SRC).algtmp.d/; \
	  split -l ${MAX_WORDALIGN_SIZE} $(LOCAL_TRAIN_TRG).algtmp $(LOCAL_TRAIN_TRG).algtmp.d/; \
	  a=`ls $(LOCAL_TRAIN_SRC).algtmp.d/* | sed 's#$$#.alg#' | xargs`; \
	  if [ "$$a" != "" ]; then \
	    ${MAKE} $$a; \
	    cat $(LOCAL_TRAIN_SRC).algtmp.d/*.alg | ${GZIP} -c > $@; \
	    rm -f ${LOCAL_TRAIN_SRC}.algtmp.d/*; \
	    rm -f ${LOCAL_TRAIN_TRG}.algtmp.d/*; \
	  fi; \
	  rmdir ${LOCAL_TRAIN_SRC}.algtmp.d; \
	  rmdir ${LOCAL_TRAIN_TRG}.algtmp.d; \
	fi
	rm -f ${LOCAL_TRAIN_SRC}.algtmp ${LOCAL_TRAIN_TRG}.algtmp


## old: do this sequenctially
## new: do this in parallel via make (see above)
## disadvantage: may require more memory!

#	  for s in `ls $(LOCAL_TRAIN_SRC).algtmp.d`; do \
#	    echo "align part $$s"; \
#	    ${WORDALIGN} --overwrite \
#		-s $(LOCAL_TRAIN_SRC).algtmp.d/$$s \
#		-t $(LOCAL_TRAIN_TRG).algtmp.d/$$s \
#		-f $(LOCAL_TRAIN_SRC).algtmp.d/$$s.fwd \
#		-r $(LOCAL_TRAIN_TRG).algtmp.d/$$s.rev; \
#	  done;


$(LOCAL_TRAIN_SRC).algtmp.d/%.alg: $(LOCAL_TRAIN_SRC).algtmp.d/% $(LOCAL_TRAIN_TRG).algtmp.d/%
	echo "align part ${notdir $<}"
	${WORDALIGN} --overwrite \
		-s $(word 1,$^) \
		-t $(word 2,$^) \
		-f $(word 1,$^).fwd \
		-r $(word 2,$^).rev
	echo "merge and symmetrize part ${notdir $<}"
	${ATOOLS} -c grow-diag-final -i $(word 1,$^).fwd -j $(word 2,$^).rev > $@
	rm -f $(word 1,$^).fwd $(word 2,$^).rev




## fetch OPUS data, try in this order
##
## (1) check first whether they exist on the local file system
## (2) check that Moses files can be downloaded
## (3) read with opus_read from local file system
## (4) fetch and read with opus_read 
##
## TODO: 
##   - should we do langid filtering and link prob filtering here?
##     (could set OPUSREAD_ARGS for that)
##

%.${SRCEXT}.raw:
	mkdir -p ${dir $@}
	-( c=${patsubst %.${LANGPAIR}.${SRCEXT}.raw,%,${notdir $@}}; \
	  if [ -e ${OPUSHOME}/$$c/latest/moses/${LANGPAIR}.txt.zip ]; then \
	    unzip -d ${dir $@} -n ${OPUSHOME}/$$c/latest/moses/${LANGPAIR}.txt.zip; \
	    mv ${dir $@}$$c*.${LANGPAIR}.${SRCEXT} $@; \
	    mv ${dir $@}$$c*.${LANGPAIR}.${TRGEXT} ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \
	    rm -f ${@:.${SRCEXT}.raw=.xml} ${@:.${SRCEXT}.raw=.ids} ${dir $@}/README ${dir $@}/LICENSE; \
	  elif [ "${call url-exists,${call resource-url,${SRCEXT},${TRGEXT},${patsubst %.${LANGPAIR}.${SRCEXT}.raw,%,${notdir $@}}}}" == "1" ]; then \
	    l="${call resource-url,${SRCEXT},${TRGEXT},${patsubst %.${LANGPAIR}.${SRCEXT}.raw,%,${notdir $@}}}"; \
	    echo "============================================"; \
	    echo "fetch moses data from $$l"; \
	    echo "============================================"; \
	    wget -qq -O $@-$$c-${LANGPAIR}.zip $$l; \
	    unzip -d ${dir $@} -n $@-$$c-${LANGPAIR}.zip; \
	    mv ${dir $@}$$c*.${LANGPAIR}.${SRCEXT} $@; \
	    mv ${dir $@}$$c*.${LANGPAIR}.${TRGEXT} ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \
	    rm -f ${@:.${SRCEXT}.raw=.xml} ${@:.${SRCEXT}.raw=.ids} ${dir $@}/README ${dir $@}/LICENSE; \
	    rm -f $@-$$c-${LANGPAIR}.zip; \
	  elif [ -e ${OPUSHOME}/$$c/latest/xml/${LANGPAIR}.xml.gz ]; then \
	    echo "============================================"; \
	    echo "extract $$c (${LANGPAIR}) from XML in local OPUS copy"; \
	    echo "============================================"; \
	    opus_read ${OPUSREAD_ARGS} -ln -rd ${OPUSHOME} -d $$c -s ${SRC} -t ${TRG} \
			-wm moses -p raw -w $@ ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \
	  else \
	    echo "============================================"; \
	    echo "fetch $$c (${LANGPAIR}) from OPUS"; \
	    echo "============================================"; \
	    opus_read ${OPUSREAD_ARGS} -ln -q -dl ${TMPWORKDIR} -d $$c -s ${SRC} -t ${TRG} \
			-wm moses -p raw -w $@ ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \
	  fi )

#	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
#	    echo "!! skip $@"; \
#	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \


%.${TRGEXT}.raw: %.${SRCEXT}.raw
	@echo "done!"


## TODO: does this causes make to frequently redo the same data?
## --> could be a problem with large models!
.INTERMEDIATE: ${LOCAL_TRAIN_SRC} ${LOCAL_TRAIN_TRG}

## define dependency on DEVDATA if they need to be added to the train data
ifeq (${USE_REST_DEVDATA},1)
  LOCAL_TRAINDATA_DEPENDENCIES = ${DEV_SRC} ${DEV_TRG}
endif


## add training data for each language combination
## and put it together in local space
${LOCAL_TRAIN_SRC}: ${LOCAL_TRAINDATA_DEPENDENCIES}
	mkdir -p ${dir $@}
	echo ""                           > ${dir $@}README.md
	echo "# ${notdir ${TRAIN_BASE}}" >> ${dir $@}README.md
	echo ""                          >> ${dir $@}README.md
	rm -f ${LOCAL_TRAIN_SRC} ${LOCAL_TRAIN_TRG}
	-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ ! `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	      if [ "${SKIP_SAME_LANG}" == "1" ] && [ "$$s" == "$$t" ]; then \
	        echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	      else \
	        echo "..... add data for $$s-$$t"; \
	        ${MAKE} DATASET=${DATASET} SRC:=$$s TRG:=$$t add-to-local-train-data; \
	      fi \
	    else \
	      echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	    fi \
	  done \
	done
ifeq (${USE_REST_DEVDATA},1)
	if [ -e ${DEV_SRC}.notused.gz ]; then \
	  echo "* unused dev/test data is added to training data" >> ${dir $@}README.md; \
	  ${GZIP} -cd < ${DEV_SRC}.notused.gz >> ${LOCAL_TRAIN_SRC}; \
	  ${GZIP} -cd < ${DEV_TRG}.notused.gz >> ${LOCAL_TRAIN_TRG}; \
	fi
endif


## everything is done in the target above
${LOCAL_TRAIN_TRG}: ${LOCAL_TRAIN_SRC}
	@echo "done!"





## cut the data sets immediately if we don't have 
## to shuffle first! This saves a lot of time!

ifneq (${SHUFFLE_DATA},1)
ifdef FIT_DATA_SIZE
  CUT_DATA_SETS = | head -${FIT_DATA_SIZE}
endif
endif


## add language labels to the source language
## if we have multiple target languages

ifeq (${USE_TARGET_LABELS},1)
  LABEL_SOURCE_DATA = | sed "s/^/>>${TRG}<< /"
endif


## add to the training data

.PHONY: add-to-local-train-data
add-to-local-train-data: ${CLEAN_TRAIN_SRC} ${CLEAN_TRAIN_TRG}
ifdef CHECK_TRAINDATA_SIZE
	@if [ `${GZCAT} ${wildcard ${CLEAN_TRAIN_SRC}} | wc -l` != `${GZCAT} ${wildcard ${CLEAN_TRAIN_TRG}} | wc -l` ]; then \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo "source and target are not of same length!"; \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo ${CLEAN_TRAIN_SRC}; \
	  echo ${CLEAN_TRAIN_TRG}; \
	fi
endif
	@echo "..... add info about training data"
	@mkdir -p ${dir ${LOCAL_TRAIN_SRC}} ${dir ${LOCAL_TRAIN_TRG}}
	@echo -n "* ${SRC}-${TRG}: "                          >> ${dir ${LOCAL_TRAIN_SRC}}README.md
	@for d in ${wildcard ${CLEAN_TRAIN_SRC}}; do \
	  l=`${GZIP} -cd < $$d ${CUT_DATA_SETS} 2>/dev/null | wc -l`; \
	  if [ $$l -gt 0 ]; then \
	    echo "$$d" | xargs basename | \
	    sed -e 's#.${SRC}.gz$$##' \
		-e 's#.clean$$##'\
		-e 's#.${LANGPAIR}$$##' | tr "\n" ' '         >> ${dir ${LOCAL_TRAIN_SRC}}README.md; \
	    echo -n "($$l) "                                  >> ${dir ${LOCAL_TRAIN_SRC}}README.md; \
	  fi \
	done
	@echo ""                                              >> ${dir ${LOCAL_TRAIN_SRC}}README.md
######################################
# create local data files (add label if necessary)
######################################
	@echo "..... create training data in local scratch space"
	@${GZCAT} ${wildcard ${CLEAN_TRAIN_SRC}} ${CUT_DATA_SETS} 2>/dev/null \
		${LABEL_SOURCE_DATA} > ${LOCAL_TRAIN_SRC}.${LANGPAIR}.src
	@${GZCAT} ${wildcard ${CLEAN_TRAIN_TRG}} ${CUT_DATA_SETS} 2>/dev/null \
		> ${LOCAL_TRAIN_TRG}.${LANGPAIR}.trg
######################################
#  SHUFFLE_DATA is set?
#    --> shuffle data for each langpair
#    --> do this when FIT_DATA_SIZE is set!
######################################
ifeq (${SHUFFLE_DATA},1)
	@echo "..... shuffle training data"
	@paste ${LOCAL_TRAIN_SRC}.${LANGPAIR}.src ${LOCAL_TRAIN_TRG}.${LANGPAIR}.trg |\
		${SHUFFLE} > ${LOCAL_TRAIN_SRC}.shuffled
	@cut -f1 ${LOCAL_TRAIN_SRC}.shuffled > ${LOCAL_TRAIN_SRC}.${LANGPAIR}.src
	@cut -f2 ${LOCAL_TRAIN_SRC}.shuffled > ${LOCAL_TRAIN_TRG}.${LANGPAIR}.trg
	@rm -f ${LOCAL_TRAIN_SRC}.shuffled
endif
######################################
#  FIT_DATA_SIZE is set?
#    --> fit data to specific size
#    --> under/over sampling!
######################################
	@echo -n "* ${SRC}-${TRG}: total size = " >> ${dir ${LOCAL_TRAIN_SRC}}README.md
ifdef FIT_DATA_SIZE
	@echo "sample data to fit size = ${FIT_DATA_SIZE}"
	@${REPOHOME}scripts/fit-data-size.pl -m ${MAX_OVER_SAMPLING} ${FIT_DATA_SIZE} \
		${LOCAL_TRAIN_SRC}.${LANGPAIR}.src | wc -l >> ${dir ${LOCAL_TRAIN_SRC}}README.md
	@${REPOHOME}scripts/fit-data-size.pl -m ${MAX_OVER_SAMPLING} ${FIT_DATA_SIZE} \
		${LOCAL_TRAIN_SRC}.${LANGPAIR}.src >> ${LOCAL_TRAIN_SRC}
	@${REPOHOME}scripts/fit-data-size.pl -m ${MAX_OVER_SAMPLING} ${FIT_DATA_SIZE} \
		${LOCAL_TRAIN_TRG}.${LANGPAIR}.trg >> ${LOCAL_TRAIN_TRG}
else
	@cat ${LOCAL_TRAIN_SRC}.${LANGPAIR}.src | wc -l >> ${dir ${LOCAL_TRAIN_SRC}}README.md
	@cat ${LOCAL_TRAIN_SRC}.${LANGPAIR}.src >> ${LOCAL_TRAIN_SRC}
	@cat ${LOCAL_TRAIN_TRG}.${LANGPAIR}.trg >> ${LOCAL_TRAIN_TRG}
endif
	@rm -f ${LOCAL_TRAIN_SRC}.${LANGPAIR}.src ${LOCAL_TRAIN_TRG}.${LANGPAIR}.trg




####################
# development data
####################

.PHONY: show-devdata
show-devdata:
	@echo "${CLEAN_DEV_SRC}" 
	@echo "${CLEAN_DEV_TRG}"
	@echo ${SUBWORD_SRC_MODEL}
	@echo ${SUBWORD_TRG_MODEL}
	@echo "${DEV_SRC}.${PRE_SRC}"
	@echo "${DEV_TRG}.${PRE_TRG}"

.PHONY: raw-devdata
raw-devdata: ${DEV_SRC} ${DEV_TRG}


## TODO: should we have some kind of balanced shuffling
##       to avoid bias towards bigger language pairs?
## maybe introduce over/undersampling of dev data like we have for train data?

${DEV_SRC}.shuffled.gz:
	mkdir -p ${sort ${dir $@} ${dir ${DEV_SRC}} ${dir ${DEV_TRG}}}
	rm -f ${DEV_SRC} ${DEV_TRG}
	echo "# Validation data"                         > ${dir ${DEV_SRC}}README.md
	echo ""                                         >> ${dir ${DEV_SRC}}README.md
	-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ ! `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	      if [ "${SKIP_SAME_LANG}" == "1" ] && [ "$$s" == "$$t" ]; then \
	        echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	      else \
	        ${MAKE} SRC=$$s TRG=$$t add-to-dev-data; \
	      fi \
	    else \
	      echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	    fi \
	  done \
	done
ifeq (${SHUFFLE_DEVDATA},0)
	paste ${DEV_SRC} ${DEV_TRG} | ${GZIP} -c > $@
else
	paste ${DEV_SRC} ${DEV_TRG} | ${UNIQ} | ${SHUFFLE} | ${GZIP} -c > $@
endif
	echo -n "* total-size-shuffled: "            >> ${dir ${DEV_SRC}}README.md
	${GZIP} -cd < $@ | wc -l                     >> ${dir ${DEV_SRC}}README.md

## OLD: don't uniq the dev-data ...
##
#	paste ${DEV_SRC} ${DEV_TRG} | ${SHUFFLE} | ${GZIP} -c > $@
#	echo -n "* total size of shuffled dev data: "        >> ${dir ${DEV_SRC}}README.md


## if we have less than twice the amount of DEVMINSIZE in the data set
## --> extract some data from the training data to be used as devdata

${DEV_SRC}: %: %.shuffled.gz
## if we extract test and dev data from the same data set
## ---> make sure that we do not have any overlap between the two data sets
## ---> reserve at least DEVMINSIZE data for dev data and keep the rest for testing
ifeq (${DEVSET},${TESTSET})
	@if (( `${GZIP} -cd < $< | wc -l` < $$((${DEVSIZE} + ${TESTSIZE})) )); then \
	  if (( `${GZIP} -cd < $< | wc -l` < $$((${DEVSMALLSIZE} + ${DEVMINSIZE})) )); then \
	    echo "extract ${DEVMINSIZE} examples from ${DEVSET} for dev and test"; \
	    ${GZIP} -cd < $< | cut -f1 | head -${DEVMINSIZE} > ${DEV_SRC}; \
	    ${GZIP} -cd < $< | cut -f2 | head -${DEVMINSIZE} > ${DEV_TRG}; \
	    mkdir -p ${dir ${TEST_SRC}}; \
	    ${GZIP} -cd < $< | cut -f1 | tail -n +$$((${DEVMINSIZE} + 1)) > ${TEST_SRC}; \
	    ${GZIP} -cd < $< | cut -f2 | tail -n +$$((${DEVMINSIZE} + 1)) > ${TEST_TRG}; \
	  else \
	    echo "extract ${DEVSMALLSIZE} examples from ${DEVSET} for dev and test"; \
	    ${GZIP} -cd < $< | cut -f1 | head -${DEVSMALLSIZE} > ${DEV_SRC}; \
	    ${GZIP} -cd < $< | cut -f2 | head -${DEVSMALLSIZE} > ${DEV_TRG}; \
	    mkdir -p ${dir ${TEST_SRC}}; \
	    ${GZIP} -cd < $< | cut -f1 | tail -n +$$((${DEVSMALLSIZE} + 1)) > ${TEST_SRC}; \
	    ${GZIP} -cd < $< | cut -f2 | tail -n +$$((${DEVSMALLSIZE} + 1)) > ${TEST_TRG}; \
	  fi; \
	else \
	  echo "extract ${DEVSIZE} examples from ${DEVSET} for dev"; \
	  echo "extract ${TESTSIZE} examples from ${DEVSET} for test"; \
	  ${GZIP} -cd < $< | cut -f1 | head -${DEVSIZE} > ${DEV_SRC}; \
	  ${GZIP} -cd < $< | cut -f2 | head -${DEVSIZE} > ${DEV_TRG}; \
	  mkdir -p ${dir ${TEST_SRC}}; \
	  ${GZIP} -cd < $< | cut -f1 | head -$$((${DEVSIZE} + ${TESTSIZE})) | tail -${TESTSIZE} > ${TEST_SRC}; \
	  ${GZIP} -cd < $< | cut -f2 | head -$$((${DEVSIZE} + ${TESTSIZE})) | tail -${TESTSIZE} > ${TEST_TRG}; \
	  ${GZIP} -cd < $< | cut -f1 | tail -n +$$((${DEVSIZE} + ${TESTSIZE} + 1)) | ${GZIP} -c > ${DEV_SRC}.notused.gz; \
	  ${GZIP} -cd < $< | cut -f2 | tail -n +$$((${DEVSIZE} + ${TESTSIZE} + 1)) | ${GZIP} -c > ${DEV_TRG}.notused.gz; \
	fi
else
	@echo "extract ${DEVSIZE} examples from ${DEVSET} for dev"
	@${GZIP} -cd < $< | cut -f1 | head -${DEVSIZE} > ${DEV_SRC}
	@${GZIP} -cd < $< | cut -f2 | head -${DEVSIZE} > ${DEV_TRG}
	@${GZIP} -cd < $< | cut -f1 | tail -n +$$((${DEVSIZE} + 1)) | ${GZIP} -c > ${DEV_SRC}.notused.gz
	@${GZIP} -cd < $< | cut -f2 | tail -n +$$((${DEVSIZE} + 1)) | ${GZIP} -c > ${DEV_TRG}.notused.gz
endif
	@echo ""                                         >> ${dir ${DEV_SRC}}/README.md
	@echo -n "* devset-selected: top "               >> ${dir ${DEV_SRC}}/README.md
	@wc -l < ${DEV_SRC} | tr "\n" ' '                >> ${dir ${DEV_SRC}}/README.md
	@echo " lines of ${notdir $@}.shuffled"          >> ${dir ${DEV_SRC}}/README.md
ifeq (${DEVSET},${TESTSET})
	@echo -n "* testset-selected: next "             >> ${dir ${DEV_SRC}}/README.md
	@wc -l < ${TEST_SRC} | tr "\n" ' '               >> ${dir ${DEV_SRC}}/README.md
	@echo " lines of ${notdir $@}.shuffled "         >> ${dir ${DEV_SRC}}/README.md
	@echo "* devset-unused: added to traindata"      >> ${dir ${DEV_SRC}}/README.md
	@echo "# Test data"                               > ${dir ${TEST_SRC}}/README.md
	@echo ""                                         >> ${dir ${TEST_SRC}}/README.md
	@echo -n "testset-selected: next "               >> ${dir ${TEST_SRC}}/README.md
	@wc -l < ${TEST_SRC} | tr "\n" ' '               >> ${dir ${TEST_SRC}}/README.md
	@echo " lines of ../val/${notdir $@}.shuffled"   >> ${dir ${TEST_SRC}}/README.md
endif


${DEV_TRG}: ${DEV_SRC}
	@echo "done!"

.PHONY: add-to-dev-data
add-to-dev-data: ${CLEAN_DEV_SRC} ${CLEAN_DEV_TRG}
	@echo "add to devset: ${CLEAN_DEV_SRC}"
	@mkdir -p ${dir ${DEV_SRC}}
	@echo -n "* ${LANGPAIR}: ${DEVSET}, "         >> ${dir ${DEV_SRC}}README.md
	@${GZCAT} ${CLEAN_DEV_SRC} 2>/dev/null | wc -l >> ${dir ${DEV_SRC}}README.md
#-----------------------------------------------------------------
# sample devdata to balance size between different language pairs
# (only if FIT_DEVDATA_SIZE is set)
#-----------------------------------------------------------------
ifdef FIT_DEVDATA_SIZE
	@echo "sample dev data to fit size = ${FIT_DEVDATA_SIZE}"
	@${REPOHOME}scripts/fit-data-size.pl -m ${MAX_OVER_SAMPLING} ${FIT_DEVDATA_SIZE} \
		${CLEAN_DEV_SRC} 2>/dev/null ${LABEL_SOURCE_DATA} >> ${DEV_SRC}
	@${REPOHOME}scripts/fit-data-size.pl -m ${MAX_OVER_SAMPLING} ${FIT_DEVDATA_SIZE} \
		${CLEAN_DEV_TRG} 2>/dev/null                      >> ${DEV_TRG}
else
	@${GZCAT} ${CLEAN_DEV_SRC} 2>/dev/null ${LABEL_SOURCE_DATA} >> ${DEV_SRC}
	@${GZCAT} ${CLEAN_DEV_TRG} 2>/dev/null                      >> ${DEV_TRG}
endif


####################
# test data
####################
##
## if devset and testset are from the same source:
## --> use part of the shuffled devset
## otherwise: create the testset
## exception: TESTSET exists in TESTSET_DIR
## --> just use that one

${TEST_SRC}: ${DEV_SRC}
ifneq (${TESTSET},${DEVSET})
	mkdir -p ${dir $@}
	rm -f ${TEST_SRC} ${TEST_TRG}
	echo "# Test data"                         > ${dir ${TEST_SRC}}/README.md
	echo ""                                   >> ${dir ${TEST_SRC}}/README.md
	if [ -e ${TESTSET_DIR}/${TESTSET}.${SRCEXT}.${PRE}.gz ]; then \
	  ${MAKE} CLEAN_TEST_SRC=${TESTSET_DIR}/${TESTSET}.${SRCEXT}.${PRE}.gz \
		  CLEAN_TEST_TRG=${TESTSET_DIR}/${TESTSET}.${TRGEXT}.${PRE}.gz \
	  add-to-test-data; \
	elif [ ! -e $@ ]; then \
	  for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ ! `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	        if [ "${SKIP_SAME_LANG}" == "1" ] && [ "$$s" == "$$t" ]; then \
	          echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	        else \
	          ${MAKE} SRC=$$s TRG=$$t add-to-test-data; \
	        fi \
	      else \
	        echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	      fi \
	    done \
	  done; \
	  if [ ${TESTSIZE} -lt `cat $@ | wc -l` ]; then \
	    paste ${TEST_SRC} ${TEST_TRG} | ${SHUFFLE} | ${GZIP} -c > $@.shuffled.gz; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f1 | tail -${TESTSIZE} > ${TEST_SRC}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f2 | tail -${TESTSIZE} > ${TEST_TRG}; \
	    echo ""                                                        >> ${dir $@}/README.md; \
	    echo "testset-selected: top ${TESTSIZE} lines of $@.shuffled!" >> ${dir $@}/README.md; \
	  fi \
	else \
	  echo "test set $@ exists already! Don't overwrite!"; \
	  echo "TODO: should we touch it?"; \
	fi
else
	mkdir -p ${dir $@}
	if [ -e ${TESTSET_DIR}/${TESTSET}.${SRCEXT}.${PRE}.gz ]; then \
	  ${MAKE} CLEAN_TEST_SRC=${TESTSET_DIR}/${TESTSET}.${SRCEXT}.${PRE}.gz \
		  CLEAN_TEST_TRG=${TESTSET_DIR}/${TESTSET}.${TRGEXT}.${PRE}.gz \
	  add-to-test-data; \
	elif (( `${GZIP} -cd < $<.shuffled.gz | wc -l` < $$((${DEVSIZE} + ${TESTSIZE})) )); then \
	  ${GZIP} -cd < $<.shuffled.gz | cut -f1 | tail -n +$$((${DEVMINSIZE} + 1)) > ${TEST_SRC}; \
	  ${GZIP} -cd < $<.shuffled.gz | cut -f2 | tail -n +$$((${DEVMINSIZE} + 1)) > ${TEST_TRG}; \
	else \
	  ${GZIP} -cd < $<.shuffled.gz | cut -f1 | tail -${TESTSIZE} > ${TEST_SRC}; \
	  ${GZIP} -cd < $<.shuffled.gz | cut -f2 | tail -${TESTSIZE} > ${TEST_TRG}; \
	fi
endif

${TEST_TRG}: ${TEST_SRC}
	@echo "done!"

.PHONY: add-to-test-data
add-to-test-data: ${CLEAN_TEST_SRC}
	@echo "add to testset: ${CLEAN_TEST_SRC}"
	@echo "* ${LANGPAIR}: ${TESTSET}" >> ${dir ${TEST_SRC}}README.md
	@${GZCAT} ${CLEAN_TEST_SRC} 2>/dev/null ${LABEL_SOURCE_DATA} >> ${TEST_SRC}
	@${GZCAT} ${CLEAN_TEST_TRG} 2>/dev/null                      >> ${TEST_TRG}



## reduce training data size if necessary
ifdef TRAINSIZE
${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz: ${TRAIN_SRC}.clean.${PRE_SRC}.gz
	${GZIP} -cd < $< | head -${TRAINSIZE} | ${GZIP} -c > $@

${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz: ${TRAIN_TRG}.clean.${PRE_TRG}.gz
	${GZIP} -cd < $< | head -${TRAINSIZE} | ${GZIP} -c > $@
endif



## monolingual data: for language-specific sentence piece models
## that are independent of bitexts
## TODO: do we use this?

${LOCAL_MONO_DATA}.raw:
	mkdir -p ${dir $@}
	rm -f $@
	-for l in ${LANGS}; do \
	  ${MAKE} DATASET=${DATASET} LANGID:=$$l \
		add-to-local-mono-data; \
	done

## TODO: if it does not exist in local file system then use opus-tools to fetch!
.PHONY: add-to-local-mono-data
add-to-local-mono-data:
	for c in ${MONOSET}; do \
	  if [ -e ${OPUSHOME}/$$c/latest/mono/${LANGID}.txt.gz ]; then \
	    ${GZIP} -cd < ${OPUSHOME}/$$c/latest/mono/${LANGID}.txt.gz |\
	    ${REPOHOME}scripts/filter/mono-match-lang.py -l ${LANGID} >> ${LOCAL_MONO_DATA}.raw; \
	  fi \
	done



##----------------------------------------------
## get data from local space and compress ...
##----------------------------------------------

${WORKDIR}/%.${PRE_SRC}.gz: ${TMPWORKDIR}/${LANGPAIRSTR}/%.${PRE_SRC}
	mkdir -p ${dir $@}
	${GZIP} -c < $< > $@
	-cat ${dir $<}README.md >> ${dir $@}README.md

ifneq (${PRE_SRC},${PRE_TRG})
${WORKDIR}/%.${PRE_TRG}.gz: ${TMPWORKDIR}/${LANGPAIRSTR}/%.${PRE_TRG}
	mkdir -p ${dir $@}
	${GZIP} -c < $< > $@
endif






include ${REPOHOME}lib/preprocess.mk
include ${REPOHOME}lib/bpe.mk
include ${REPOHOME}lib/sentencepiece.mk


