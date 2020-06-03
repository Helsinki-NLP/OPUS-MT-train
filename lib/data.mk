# -*-makefile-*-



## SKIP_LANGPAIRS can be used to skip certain language pairs
## in data preparation for multilingual models
## ---> this can be good to skip BIG language pairs
##      that would very much dominate all the data
## must be a pattern that can be matched by egrep
## e.g. en-de|en-fr

SKIP_LANGPAIRS ?= "nothing"

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

ifneq (${wildcard scripts/cleanup/${SRC}},)
  SRC_CLEANUP_SCRIPTS = | ${subst ${SPACE}, | ,${shell find scripts/cleanup/${SRC} -executable -type f}}
endif

ifneq (${wildcard scripts/cleanup/${TRG}},)
  TRG_CLEANUP_SCRIPTS = | ${subst ${SPACE}, | ,${shell find scripts/cleanup/${TRG} -executable -type f}}
endif


##-------------------------------------------------------------
## backtranslated data and pivot-based synthetic training data
##-------------------------------------------------------------

## back translation data
## - use only the latest backtranslations
##   if such a subdir exists

ifneq (${wildcard backtranslate/${TRG}-${SRC}/latest},)
  BACKTRANS_DIR = backtranslate/${TRG}-${SRC}/latest
else
  BACKTRANS_DIR = backtranslate/${TRG}-${SRC}
endif

## TODO: make it possible to select only parts of the BT data
## ---> use TRAINDATA_SIZE to take max the same amount of all shuffled BT data

ifeq (${USE_BACKTRANS},1)
  BACKTRANS_SRC = ${sort ${wildcard ${BACKTRANS_DIR}/*.${SRCEXT}.gz}}
  BACKTRANS_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${BACKTRANS_SRC}}
endif

ifeq (${USE_PIVOTING},1)
  PIVOTING_SRC = ${sort ${wildcard pivoting/${SRC}-${TRG}/latest/*.${SRCEXT}.gz} \
			${wildcard pivoting/${TRG}-${SRC}/latest/*.${SRCEXT}.gz}}
  PIVOTING_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${PIVOTING_SRC}}
endif


##-------------------------------------------------------------
## data sets (train/dev/test)
##-------------------------------------------------------------

CLEAN_TRAIN_SRC = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.clean.${SRCEXT}.gz,${TRAINSET}} \
			${BACKTRANS_SRC} ${PIVOTING_SRC}
CLEAN_TRAIN_TRG = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${CLEAN_TRAIN_SRC}}

CLEAN_DEV_SRC   = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.clean.${SRCEXT}.gz,${DEVSET}}
CLEAN_DEV_TRG   = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${CLEAN_DEV_SRC}}

CLEAN_TEST_SRC  = ${patsubst %,${DATADIR}/${PRE}/%.${LANGPAIR}.clean.${SRCEXT}.gz,${TESTSET}}
CLEAN_TEST_TRG  = ${patsubst %.${SRCEXT}.gz,%.${TRGEXT}.gz,${CLEAN_TEST_SRC}}

DATA_SRC := ${sort ${CLEAN_TRAIN_SRC} ${CLEAN_DEV_SRC} ${CLEAN_TEST_SRC}}
DATA_TRG := ${sort ${CLEAN_TRAIN_TRG} ${CLEAN_DEV_TRG} ${CLEAN_TEST_TRG}}



##-------------------------------------------------------------
## make data in reverse direction without re-doing word alignment etc ...
## ---> this is dangerous when things run in parallel
## ---> only works for bilingual models
##-------------------------------------------------------------

REV_LANGSTR = ${subst ${SPACE},+,$(TRGLANGS)}-${subst ${SPACE},+,$(SRCLANGS)}
REV_WORKDIR = ${WORKHOME}/${REV_LANGSTR}

reverse-data:
ifeq (${PRE_SRC},${PRE_TRG})
ifeq (${words ${SRCLANGS}},1)
ifeq (${words ${TRGLANGS}},1)
	-if [ -e ${TRAIN_SRC}.clean.${PRE_SRC}.gz ]; then \
	  mkdir -p ${REV_WORKDIR}/train; \
	  ln -s ${TRAIN_SRC}.clean.${PRE_SRC}.gz ${REV_WORKDIR}/train/${notdir ${TRAIN_TRG}.clean.${PRE_TRG}.gz}; \
	  ln -s ${TRAIN_TRG}.clean.${PRE_TRG}.gz ${REV_WORKDIR}/train/${notdir ${TRAIN_SRC}.clean.${PRE_SRC}.gz}; \
	  cp ${WORKDIR}/train/README.md ${REV_WORKDIR}/train/README.md; \
	fi
	-if [ -e ${SPMSRCMODEL} ]; then \
	  ln -s ${SPMSRCMODEL} ${REV_WORKDIR}/train/${notdir ${SPMTRGMODEL}}; \
	  ln -s ${SPMTRGMODEL} ${REV_WORKDIR}/train/${notdir ${SPMSRCMODEL}}; \
	fi
	if [ -e ${BPESRCMODEL} ]; then \
	  ln -s ${BPESRCMODEL} ${REV_WORKDIR}/train/${notdir ${BPETRGMODEL}}; \
	  ln -s ${BPETRGMODEL} ${REV_WORKDIR}/train/${notdir ${BPESRCMODEL}}; \
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
	-if [ -e ${MODEL_VOCAB} ]; then \
	  ln -s ${MODEL_VOCAB} ${REV_WORKDIR}/${notdir ${MODEL_VOCAB}}; \
	fi
	-if [ -e ${WORKDIR}/config.mk ]; then \
	   if [ ! -e ${REV_WORKDIR}/config.mk ]; then \
	     cp ${WORKDIR}/config.mk ${REV_WORKDIR}/config.mk; \
	   fi \
	fi
endif
endif
endif



clean-data:
	for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    ${MAKE} SRC=$$s TRG=$$t clean-data-source; \
	  done \
	done

clean-data-source: ${DATA_SRC} ${DATA_TRG}



## monolingual data sets (for sentence piece models)
.INTERMEDIATE: ${LOCAL_MONO_DATA}.${PRE} ${LOCAL_MONO_DATA}.raw ${LOCAL_MONO_DATA}.${PRE}.charfreq

mono-data: ${LOCAL_MONO_DATA}.${PRE}




## word alignment used for guided alignment

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

${TRAIN_ALG}: 	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
		${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz
	${MAKE} ${LOCAL_TRAIN_SRC}.algtmp ${LOCAL_TRAIN_TRG}.algtmp
	if  [ `head $(LOCAL_TRAIN_SRC).algtmp | wc -l` -gt 0 ]; then \
	  mkdir -p $(LOCAL_TRAIN_SRC).algtmp.d; \
	  mkdir -p $(LOCAL_TRAIN_TRG).algtmp.d; \
	  split -l ${MAX_WORDALIGN_SIZE} $(LOCAL_TRAIN_SRC).algtmp $(LOCAL_TRAIN_SRC).algtmp.d/; \
	  split -l ${MAX_WORDALIGN_SIZE} $(LOCAL_TRAIN_TRG).algtmp $(LOCAL_TRAIN_TRG).algtmp.d/; \
	  for s in `ls $(LOCAL_TRAIN_SRC).algtmp.d`; do \
	    echo "align part $$s"; \
	    ${WORDALIGN} --overwrite \
		-s $(LOCAL_TRAIN_SRC).algtmp.d/$$s \
		-t $(LOCAL_TRAIN_TRG).algtmp.d/$$s \
		-f $(LOCAL_TRAIN_SRC).algtmp.d/$$s.fwd \
		-r $(LOCAL_TRAIN_TRG).algtmp.d/$$s.rev; \
	  done; \
	  echo "merge and symmetrize"; \
	  cat $(LOCAL_TRAIN_SRC).algtmp.d/*.fwd > $(LOCAL_TRAIN_SRC).fwd; \
	  cat $(LOCAL_TRAIN_TRG).algtmp.d/*.rev > $(LOCAL_TRAIN_TRG).rev; \
	  ${ATOOLS} -c grow-diag-final -i $(LOCAL_TRAIN_SRC).fwd -j $(LOCAL_TRAIN_TRG).rev |\
	  ${GZIP} -c > $@; \
	  rm -f ${LOCAL_TRAIN_SRC}.algtmp.d/*; \
	  rm -f ${LOCAL_TRAIN_TRG}.algtmp.d/*; \
	  rmdir ${LOCAL_TRAIN_SRC}.algtmp.d; \
	  rmdir ${LOCAL_TRAIN_TRG}.algtmp.d; \
	  rm -f $(LOCAL_TRAIN_SRC).fwd $(LOCAL_TRAIN_TRG).rev; \
	fi
	rm -f ${LOCAL_TRAIN_SRC}.algtmp ${LOCAL_TRAIN_TRG}.algtmp





## copy OPUS data
## (check that the OPUS file really exists! if not, create and empty file)
##
## TODO: should we read all data from scratch using opus_read?
## - also: langid filtering and link prob filtering?

%.${SRCEXT}.raw:
	mkdir -p ${dir $@}
	c=${patsubst %.${LANGPAIR}.${SRCEXT}.raw,%,${notdir $@}}; \
	if [ -e ${OPUSHOME}/$$c/latest/moses/${LANGPAIR}.txt.zip ]; then \
	  unzip -d ${dir $@} -x README LICENSE \
	  ${OPUSHOME}/$$c/latest/moses/${LANGPAIR}.txt.zip; \
	  mv ${dir $@}$$c*.${LANGPAIR}.${SRCEXT} $@; \
	  mv ${dir $@}$$c*.${LANGPAIR}.${TRGEXT} \
	     ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \
	  rm -f ${@:.${SRCEXT}.raw=.xml} ${@:.${SRCEXT}.raw=.ids} ${dir $@}/README ${dir $@}/LICENSE; \
	elif [ -e ${OPUSHOME}/$$c/latest/xml/${LANGPAIR}.xml.gz ]; then \
	  echo "extract $$c (${LANGPAIR}) from OPUS"; \
	  opus_read ${OPUSREAD_ARGS} -rd ${OPUSHOME} -d $$c -s ${SRC} -t ${TRG} -wm moses -p raw > $@.tmp; \
	  cut -f1 $@.tmp > $@; \
	  cut -f2 $@.tmp > ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \
	  rm -f $@.tmp; \
	else \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	  echo "!! skip $@"; \
	  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; \
	fi

## TODO: do we need this?
##
#	else \
#	  touch $@; \
#	  touch ${@:.${SRCEXT}.raw=.${TRGEXT}.raw}; \


%.${TRGEXT}.raw: %.${SRCEXT}.raw
	@echo "done!"


.INTERMEDIATE: ${LOCAL_TRAIN_SRC} ${LOCAL_TRAIN_TRG} ${LOCAL_TRAIN_SRC}.charfreq ${LOCAL_TRAIN_TRG}.charfreq

## add training data for each language combination
## and put it together in local space
${LOCAL_TRAIN_SRC}: ${DEV_SRC} ${DEV_TRG}
	mkdir -p ${dir $@}
	rm -f ${LOCAL_TRAIN_SRC} ${LOCAL_TRAIN_TRG}
	echo ""                           > ${dir $@}README.md
	echo "# ${notdir ${TRAIN_BASE}}" >> ${dir $@}README.md
	echo ""                          >> ${dir $@}README.md
	-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ ! `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	      ${MAKE} DATASET=${DATASET} SRC:=$$s TRG:=$$t add-to-local-train-data; \
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


${LOCAL_TRAIN_TRG}: ${LOCAL_TRAIN_SRC}
	@echo "done!"


## add to the training data
## NEW: take away dependence on the clean pre-processed data
##      to avoid re-doing existing data and also avoid problems
##      of extra data that do not exist for a particular language pair
##      in multilingual data sets
## TODO: introduce under and over-sampling for multilingual data sets ...
add-to-local-train-data: 
ifneq (${wildcard ${CLEAN_TRAIN_SRC}},)
	${MAKE} ${CLEAN_TRAIN_SRC} ${CLEAN_TRAIN_TRG}
	@if [ `${GZIP} -cd < ${wildcard ${CLEAN_TRAIN_SRC}} | wc -l` != `${GZIP} -cd < ${wildcard ${CLEAN_TRAIN_TRG}} | wc -l` ]; then \
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
	echo -n "* ${SRC}-${TRG}: "                           >> ${dir ${LOCAL_TRAIN_SRC}}README.md
	for d in ${wildcard ${CLEAN_TRAIN_SRC}}; do \
	  l=`${GZIP} -cd < $$d | wc -l`; \
	  if [ $$l -gt 0 ]; then \
	    echo "$$d" | xargs basename | \
	    sed -e 's#.${SRC}.gz$$##' \
		-e 's#.clean$$##'\
		-e 's#.${LANGPAIR}$$##' | tr "\n" ' '         >> ${dir ${LOCAL_TRAIN_SRC}}README.md; \
	    echo -n "($$l) "                                  >> ${dir ${LOCAL_TRAIN_SRC}}README.md; \
	  fi \
	done
	echo ""                                               >> ${dir ${LOCAL_TRAIN_SRC}}README.md
	echo -n "* ${SRC}-${TRG}: total size = "              >> ${dir ${LOCAL_TRAIN_SRC}}README.md
	${GZIP} -cd < ${wildcard ${CLEAN_TRAIN_SRC}} | wc -l  >> ${dir ${LOCAL_TRAIN_SRC}}README.md
######################################
# multiple target languages?
#    --> add language labels
######################################
ifneq (${words ${TRGLANGS}},1)
	echo "more than one target language";
	${GZIP} -cd < ${wildcard ${CLEAN_TRAIN_SRC}} |\
	sed "s/^/>>${TRG}<< /" > ${LOCAL_TRAIN_SRC}.src
else
	echo "only one target language"
	${GZIP} -cd < ${wildcard ${CLEAN_TRAIN_SRC}} > ${LOCAL_TRAIN_SRC}.src
endif
	${GZIP} -cd < ${wildcard ${CLEAN_TRAIN_TRG}} > ${LOCAL_TRAIN_TRG}.trg
endif
######################################
#  FIT_DATA_SIZE is set?
#    --> shuffle data and fit the
#        data sets to a specific size
######################################
ifdef FIT_DATA_SIZE
	paste ${LOCAL_TRAIN_SRC}.src ${LOCAL_TRAIN_TRG}.trg | ${SHUFFLE} > ${LOCAL_TRAIN_SRC}.shuffled
	cut -f1 ${LOCAL_TRAIN_SRC}.shuffled > ${LOCAL_TRAIN_SRC}.src
	cut -f2 ${LOCAL_TRAIN_SRC}.shuffled > ${LOCAL_TRAIN_TRG}.trg
	rm -f ${LOCAL_TRAIN_SRC}.shuffled
	scripts/fit-data-size.pl ${FIT_DATA_SIZE} ${LOCAL_TRAIN_SRC}.src >> ${LOCAL_TRAIN_SRC}
	scripts/fit-data-size.pl ${FIT_DATA_SIZE} ${LOCAL_TRAIN_TRG}.trg >> ${LOCAL_TRAIN_TRG}
else
	cat ${LOCAL_TRAIN_SRC}.src >> ${LOCAL_TRAIN_SRC}
	cat ${LOCAL_TRAIN_TRG}.trg >> ${LOCAL_TRAIN_TRG}
endif
	rm -f ${LOCAL_TRAIN_SRC}.src ${LOCAL_TRAIN_TRG}.trg





####################
# development data
####################

show-devdata:
	@echo "${CLEAN_DEV_SRC}" 
	@echo "${CLEAN_DEV_TRG}"
	@echo ${SPMSRCMODEL}
	@echo ${SPMTRGMODEL}
	@echo "${DEV_SRC}.${PRE_SRC}"
	@echo "${DEV_TRG}.${PRE_TRG}"

raw-devdata: ${DEV_SRC} ${DEV_TRG}


${DEV_SRC}.shuffled.gz:
	mkdir -p ${dir $@}
	rm -f ${DEV_SRC} ${DEV_TRG}
	echo "# Validation data"                         > ${dir ${DEV_SRC}}/README.md
	echo ""                                         >> ${dir ${DEV_SRC}}/README.md
	-for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	    if [ ! `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	      ${MAKE} SRC=$$s TRG=$$t add-to-dev-data; \
	    else \
	      echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	    fi \
	  done \
	done
	paste ${DEV_SRC} ${DEV_TRG} | ${SHUFFLE} | ${GZIP} -c > $@
	echo -n "* total size of shuffled dev data: "        >> ${dir ${DEV_SRC}}README.md
	${GZIP} -cd < $@ | wc -l                             >> ${dir ${DEV_SRC}}README.md



## if we have less than twice the amount of DEVMINSIZE in the data set
## --> extract some data from the training data to be used as devdata

${DEV_SRC}: %: %.shuffled.gz
## if we extract test and dev data from the same data set
## ---> make sure that we do not have any overlap between the two data sets
## ---> reserve at least DEVMINSIZE data for dev data and keep the rest for testing
ifeq (${DEVSET},${TESTSET})
	if (( `${GZIP} -cd < $@.shuffled.gz | wc -l` < $$((${DEVSIZE} + ${TESTSIZE})) )); then \
	  if (( `${GZIP} -cd < $@.shuffled.gz | wc -l` < $$((${DEVSMALLSIZE} + ${DEVMINSIZE})) )); then \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f1 | head -${DEVMINSIZE} > ${DEV_SRC}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f2 | head -${DEVMINSIZE} > ${DEV_TRG}; \
	    mkdir -p ${dir ${TEST_SRC}}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f1 | tail -n +$$((${DEVMINSIZE} + 1)) > ${TEST_SRC}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f2 | tail -n +$$((${DEVMINSIZE} + 1)) > ${TEST_TRG}; \
	  else \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f1 | head -${DEVSMALLSIZE} > ${DEV_SRC}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f2 | head -${DEVSMALLSIZE} > ${DEV_TRG}; \
	    mkdir -p ${dir ${TEST_SRC}}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f1 | tail -n +$$((${DEVSMALLSIZE} + 1)) > ${TEST_SRC}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f2 | tail -n +$$((${DEVSMALLSIZE} + 1)) > ${TEST_TRG}; \
	  fi; \
	else \
	  ${GZIP} -cd < $@.shuffled.gz | cut -f1 | head -${DEVSIZE} > ${DEV_SRC}; \
	  ${GZIP} -cd < $@.shuffled.gz | cut -f2 | head -${DEVSIZE} > ${DEV_TRG}; \
	  mkdir -p ${dir ${TEST_SRC}}; \
	  ${GZIP} -cd < $@.shuffled.gz | cut -f1 | head -$$((${DEVSIZE} + ${TESTSIZE})) | tail -${TESTSIZE} > ${TEST_SRC}; \
	  ${GZIP} -cd < $@.shuffled.gz | cut -f2 | head -$$((${DEVSIZE} + ${TESTSIZE})) | tail -${TESTSIZE} > ${TEST_TRG}; \
	  ${GZIP} -cd < $@.shuffled.gz | cut -f1 | tail -n +$$((${DEVSIZE} + ${TESTSIZE})) | ${GZIP} -c > ${DEV_SRC}.notused.gz; \
	  ${GZIP} -cd < $@.shuffled.gz | cut -f2 | tail -n +$$((${DEVSIZE} + ${TESTSIZE})) | ${GZIP} -c > ${DEV_TRG}.notused.gz; \
	fi
else
	${GZIP} -cd < $@.shuffled.gz | cut -f1 | head -${DEVSIZE} > ${DEV_SRC}
	${GZIP} -cd < $@.shuffled.gz | cut -f2 | head -${DEVSIZE} > ${DEV_TRG}
	${GZIP} -cd < $@.shuffled.gz | cut -f1 | tail -n +$$((${DEVSIZE} + 1)) | ${GZIP} -c > ${DEV_SRC}.notused.gz
	${GZIP} -cd < $@.shuffled.gz | cut -f2 | tail -n +$$((${DEVSIZE} + 1)) | ${GZIP} -c > ${DEV_TRG}.notused.gz
endif
	echo ""                                         >> ${dir ${DEV_SRC}}/README.md
	echo -n "* devset = top "                       >> ${dir ${DEV_SRC}}/README.md
	wc -l < ${DEV_SRC} | tr "\n" ' '                >> ${dir ${DEV_SRC}}/README.md
	echo " lines of ${notdir $@}.shuffled!"         >> ${dir ${DEV_SRC}}/README.md
ifeq (${DEVSET},${TESTSET})
	echo -n "* testset = next "                     >> ${dir ${DEV_SRC}}/README.md
	wc -l < ${TEST_SRC} | tr "\n" ' '               >> ${dir ${DEV_SRC}}/README.md
	echo " lines of ${notdir $@}.shuffled!"         >> ${dir ${DEV_SRC}}/README.md
	echo "* remaining lines are added to traindata" >> ${dir ${DEV_SRC}}/README.md
	echo "# Test data"                               > ${dir ${TEST_SRC}}/README.md
	echo ""                                         >> ${dir ${TEST_SRC}}/README.md
	echo -n "testset = next "                       >> ${dir ${TEST_SRC}}/README.md
	wc -l < ${TEST_SRC} | tr "\n" ' '               >> ${dir ${TEST_SRC}}/README.md
	echo " lines of ../val/${notdir $@}.shuffled!"  >> ${dir ${TEST_SRC}}/README.md
endif


${DEV_TRG}: ${DEV_SRC}
	@echo "done!"


add-to-dev-data: ${CLEAN_DEV_SRC} ${CLEAN_DEV_TRG}
	mkdir -p ${dir ${DEV_SRC}}
ifneq (${wildcard ${CLEAN_DEV_SRC}},)
	echo -n "* ${LANGPAIR}: ${DEVSET}, " >> ${dir ${DEV_SRC}}README.md
	${GZIP} -cd < ${CLEAN_DEV_SRC} | wc -l        >> ${dir ${DEV_SRC}}README.md
ifneq (${words ${TRGLANGS}},1)
	echo "more than one target language";
	${GZIP} -cd < ${CLEAN_DEV_SRC} |\
	sed "s/^/>>${TRG}<< /" >> ${DEV_SRC}
else
	echo "only one target language"
	${GZIP} -cd < ${CLEAN_DEV_SRC} >> ${DEV_SRC}
endif
	${GZIP} -cd < ${CLEAN_DEV_TRG} >> ${DEV_TRG}
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
	else \
	  for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ ! `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	        ${MAKE} SRC=$$s TRG=$$t add-to-test-data; \
	      else \
	        echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	      fi \
	    done \
	  done; \
	  if [ ${TESTSIZE} -lt `cat $@ | wc -l` ]; then \
	    paste ${TEST_SRC} ${TEST_TRG} | ${SHUFFLE} | ${GZIP} -c > $@.shuffled.gz; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f1 | tail -${TESTSIZE} > ${TEST_SRC}; \
	    ${GZIP} -cd < $@.shuffled.gz | cut -f2 | tail -${TESTSIZE} > ${TEST_TRG}; \
	    echo ""                                                >> ${dir $@}/README.md; \
	    echo "testset = top ${TESTSIZE} lines of $@.shuffled!" >> ${dir $@}/README.md; \
	  fi \
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

add-to-test-data: ${CLEAN_TEST_SRC}
ifneq (${wildcard ${CLEAN_TEST_SRC}},)
	echo "* ${LANGPAIR}: ${TESTSET}" >> ${dir ${TEST_SRC}}README.md
ifneq (${words ${TRGLANGS}},1)
	echo "more than one target language";
	${GZIP} -cd < ${CLEAN_TEST_SRC} |\
	sed "s/^/>>${TRG}<< /" >> ${TEST_SRC}
else
	echo "only one target language"
	${GZIP} -cd < ${CLEAN_TEST_SRC} >> ${TEST_SRC}
endif
	${GZIP} -cd < ${CLEAN_TEST_TRG} >> ${TEST_TRG}
endif



## reduce training data size if necessary
ifdef TRAINSIZE
${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz: ${TRAIN_SRC}.clean.${PRE_SRC}.gz
	${GZIP} -cd < $< | head -${TRAINSIZE} | ${GZIP} -c > $@

${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz: ${TRAIN_TRG}.clean.${PRE_TRG}.gz
	${GZIP} -cd < $< | head -${TRAINSIZE} | ${GZIP} -c > $@
endif



${LOCAL_MONO_DATA}.raw:
	mkdir -p ${dir $@}
	rm -f $@
	-for l in ${LANGS}; do \
	  ${MAKE} DATASET=${DATASET} LANGID:=$$l \
		add-to-local-mono-data; \
	done

add-to-local-mono-data:
	for c in ${MONOSET}; do \
	  if [ -e ${OPUSHOME}/$$c/latest/mono/${LANGID}.txt.gz ]; then \
	    ${GZIP} -cd < ${OPUSHOME}/$$c/latest/mono/${LANGID}.txt.gz |\
	    scripts/filter/mono-match-lang.py -l ${LANGID} >> ${LOCAL_MONO_DATA}.raw; \
	  fi \
	done



##----------------------------------------------
## get data from local space and compress ...

${WORKDIR}/%.clean.${PRE_SRC}.gz: ${TMPDIR}/${LANGPAIRSTR}/%.clean.${PRE_SRC}
	mkdir -p ${dir $@}
	${GZIP} -c < $< > $@
	-cat ${dir $<}README.md >> ${dir $@}README.md

ifneq (${PRE_SRC},${PRE_TRG})
${WORKDIR}/%.clean.${PRE_TRG}.gz: ${TMPDIR}/${LANGPAIRSTR}/%.clean.${PRE_TRG}
	mkdir -p ${dir $@}
	${GZIP} -c < $< > $@
endif






include lib/preprocess.mk
include lib/bpe.mk
include lib/sentencepiece.mk


