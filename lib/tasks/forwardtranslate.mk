# -*-makefile-*-
#
# forward translation to be used for 
# knowledge distillation
#
# only works with sentencepiece models!
#
# TODO's
#
#   - forward-translate monolingual data (re-use bt-data)
#   - reconstruction filtering (score translation in opposite direction)
#     (use weights? normalise-script from bergamot/students)
#   - other kind of data filtering / selection?
#   - create lexical shortlists (see bergamot)
#   - finetune alphas in intgemm8 models (see bergamot)
#   - benchmark distilled models
#



## change decoder settings
## TODO: do we need this?

FT_MARIAN_BEAM_SIZE  = 1
FT_MARIAN_MINI_BATCH = 128
FT_MARIAN_MAXI_BATCH = 256
FT_MARIAN_MAX_LENGTH = 200
FT_MARIAN_WORKSPACE  = 12000

# FT_MARIAN_MINI_BATCH = 768
# FT_MARIAN_MAXI_BATCH = 2048




## split size in nr-of-lines
## default part to be selected = aa
FT_SPLIT_SIZE ?= 1000000

## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
FT_MAX_LENGTH    ?= 200



## DO WE NEED THOSE?

# RELEASED_BITEXTS := $(patsubst %.tar,%,${shell ${WGET} -qq -O - ${TATOEBA_GITRAW}/Wiki.md | \
# 					grep -o 'WikiShuffled/...\.tar' | cut -f2 -d'/'})
# 
# RELEASED_BITEXTS_REV = ${shell (for d in ${RELEASED_BITEXTS}; do echo $$d; done) | tac}
#



FT_WORKHOME    = ${WORKHOME}/forward_translations
FT_OUTPUT_DIR ?= ${FT_WORKHOME}/${LANGPAIR}
FT_PART       ?= aa

FT_BITEXT_SRCRAW  = ${CLEAN_TRAIN_SRC}
# FT_BITEXT_SRCRAW  = ${DATADIR}/${PRE}/Tatoeba-train-${TATOEBA_VERSION}.${SORTED_LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${SRC}.gz

FT_BITEXT_BASE    = ${FT_OUTPUT_DIR}/Tatoeba-train.${MODELNAME}.${LANGPAIR}
FT_BITEXT_SRC     = ${FT_BITEXT_BASE}.${SRC}.${FT_PART}.gz
FT_BITEXT_PRE     = ${FT_BITEXT_BASE}.${SRC}.spm.${FT_PART}.gz
FT_BITEXT_TRG     = ${FT_BITEXT_BASE}.${TRG}.${FT_PART}.gz

FT_BITEXT_LATEST_SRC    = ${FT_OUTPUT_DIR}/latest/Tatoeba-train.${FT_PART}.${LANGPAIR}.${SRC}.gz
FT_BITEXT_LATEST_TRG    = ${FT_OUTPUT_DIR}/latest/Tatoeba-train.${FT_PART}.${LANGPAIR}.${TRG}.gz
FT_BITEXT_LATEST_README = ${FT_OUTPUT_DIR}/latest/README.md


## all parts of the bitext
FT_PARTS                 = $(subst .,,${suffix ${basename ${wildcard ${FT_BITEXT_PRE:${FT_PART}.gz=}??.gz}}})
FT_ALL_BITEXT_LATEST_SRC = ${patsubst %,${FT_OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${SRC}.gz,${FT_PARTS}}
FT_ALL_BITEXT_LATEST_TRG = ${patsubst %,${FT_OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${TRG}.gz,${FT_PARTS}}


## don't delete translated text even if the process crashes
.PRECIOUS: ${FT_BITEXT_BASE}.${TRG}.%.gz

.PHONY: ft-all
ft-all: ft-prepare
	${MAKE} forward-translate-all-parts
	${MAKE} OUTPUT_DIR=${FT_OUTPUT_DIR}/latest score-translations
	${MAKE} OUTPUT_DIR=${FT_OUTPUT_DIR}/latest sort-scored-translations
	${MAKE} OUTPUT_DIR=${FT_OUTPUT_DIR}/latest extract-best-translations


.PHONY: ft-mtmodel
ft-mtmodel:
	${MAKE} OUTPUT_DIR=${FT_OUTPUT_DIR} best-model

.PHONY: ft-prepare
ft-prepare: ft-mtmodel ${FT_BITEXT_PRE}

.PHONY: forward-translate
forward-translate: ${FT_BITEXT_LATEST_README} ${FT_BITEXT_LATEST_TRG}
	${MAKE} ${FT_BITEXT_LATEST_SRC}

## forward-translate all parts
.PHONY: forward-translate-all-parts forward-translate-all
forward-translate-all forward-translate-all-parts: ${FT_ALL_BITEXT_LATEST_TRG}
	${MAKE} ft-source-all-parts

.PHONY: ft-source-all-parts
ft-source-all-parts: ${FT_ALL_BITEXT_LATEST_SRC}







## pre-process data

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${SRC} ${TRG} ${FT_OUTPUT_DIR}/${MODELNAME}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${FT_OUTPUT_DIR}/${MODELNAME}/source.spm
endif


${FT_BITEXT_SRCRAW}:
	${MAKE} SRCLANGS=${SRC} TRGLANGS=${TRG} rawdata-tatoeba

${FT_BITEXT_PRE}: ${FT_BITEXT_SRCRAW}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${FT_OUTPUT_DIR}/${MODELNAME}/decoder.yml
	${GZCAT} $< |\
	grep -v '[<>{}]' |\
	${FT_OUTPUT_DIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${FT_MAX_LENGTH});print;}' |\
	split -l ${FT_SPLIT_SIZE} - ${patsubst %${FT_PART}.gz,%,$@}
	${GZIP} -f ${patsubst %${FT_PART}.gz,%,$@}??
endif





## merge SentencePiece segments in the source text
## (Why? because we filter out some data from the original wiki text, see above)

${FT_BITEXT_BASE}.${SRC}.%.gz: ${FT_BITEXT_BASE}.${SRC}.spm.%.gz
	if [ -e ${patsubst ${FT_BITEXT_BASE}.${SRC}.%.gz,${FT_BITEXT_BASE}.${TRG}.%.gz,$@} ]; then \
	  mkdir -p ${dir $@}; \
	  ${GZCAT} $< |\
	  sed 's/ //g;s/▁/ /g' | \
	  sed 's/^ *//;s/ *$$//' |\
	  sed 's/^>>[a-z]*<< //' |\
	  gzip -c > $@; \
	fi


## overwrite the file with the latest translations
## --> this allows multiple translation iterations
##     without duplicating the data we want to use in MT training

${FT_OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${SRC}.gz: ${FT_BITEXT_BASE}.${SRC}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${FT_OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${TRG}.gz: ${FT_BITEXT_BASE}.${TRG}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${FT_BITEXT_LATEST_README}: ${FT_OUTPUT_DIR}/${MODELNAME}/README.md
	mkdir -p ${dir $@}
	rsync $< $@


## forward-translate

${FT_BITEXT_BASE}.${TRG}.%.gz: ${FT_BITEXT_BASE}.${SRC}.spm.%.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${FT_OUTPUT_DIR}/${MODELNAME}/decoder.yml
	${LOAD_ENV} && cd ${FT_OUTPUT_DIR}/${MODELNAME} && \
	${MARIAN_DECODER} \
		-c decoder.yml \
		-i ${PWD}/$< \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
endif



ft-check-latest:
	@if [ -d ${FT_OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${FT_OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	  done \
	fi

ft-check-scores:
	@if [ -d ${FT_OUTPUT_DIR}/latest ]; then \
	  for T in `ls ${FT_OUTPUT_DIR}/latest/*.${TRG}.gz`; do \
	    S=`echo $$T | sed 's/.${TRG}.gz/.${SRC}.scores.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	  done \
	fi


ft-check-translated:
	@for S in `ls ${FT_OUTPUT_DIR}/*.${SRC}.spm.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	done

ft-check-length:
	@echo "check ${LANGPAIR}"
	@${MAKE} ft-check-translated
	@${MAKE} ft-check-latest


ft-remove-%-all ft-check-%-all:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  make SRC=$$s TRG=$$t ${@:-all=}; \
	done



ft-remove-incomplete:
	${MAKE} ft-remove-incomplete-translated
	${MAKE} ft-remove-incomplete-latest

ft-remove-incomplete-translated:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${FT_OUTPUT_DIR}/incomplete
	@for S in `ls ${FT_OUTPUT_DIR}/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${FT_OUTPUT_DIR}/incomplete/; \
	      mv $$T ${FT_OUTPUT_DIR}/incomplete/; \
	    fi \
	done


ft-remove-incomplete-latest:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${FT_OUTPUT_DIR}/incomplete/latest
	@if [ -d ${FT_OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${FT_OUTPUT_DIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${FT_OUTPUT_DIR}/incomplete/latest/; \
	      mv $$T ${FT_OUTPUT_DIR}/incomplete/latest/; \
	    fi \
	  done \
	fi






# ## for testing purposes

# score2-translation: ${FT_BITEXT_LATEST_SRC:.gz=.scores2}
# score3-translation: ${FT_BITEXT_LATEST_SRC:.gz=.scores3}

# ${FT_OUTPUT_DIR}/latest/%.${SRC}.scores2: ${FT_OUTPUT_DIR}/latest/%.${SRC}.gz
# 	${MAKE} SRC=${TRG} TRG=${SRC} ft-mtmodel
# 	${GZCAT} ${<:.${SRC}.gz=.${TRG}.gz} |\
# 	${REV_LANGPAIR}/${REV_MODELNAME}/preprocess.sh ${REV_SRC_PREPROCESS_ARGS} | \
# 	${GZIP} -c > $@.src.gz
# 	${GZCAT} $< |\
# 	${REV_LANGPAIR}/${REV_MODELNAME}/preprocess.sh ${REV_TRG_PREPROCESS_ARGS} | \
# 	${GZIP} -c > $@.trg.gz
# 	${LOAD_ENV} && \
# 	cd ${REV_LANGPAIR}/${REV_MODELNAME} && \
# 	${MARIAN_SCORER} \
# 		-m `grep -A1 models decoder.yml | tail -1 | sed 's/ *- //'` \
# 		-v `grep -A2 vocabs decoder.yml | tail -2 | sed 's/ *- //' | tr "\n" ' '` \
# 		-t ${PWD}/$@.src.gz ${PWD}/$@.trg.gz \
# 		-n1 -d 0 --mini-batch 1 --maxi-batch 1 --log ${PWD}/$@.log > ${PWD}/$@ 2>${PWD}/$@.err

# ${FT_OUTPUT_DIR}/latest/%.${SRC}.scores3: ${FT_OUTPUT_DIR}/latest/%.${SRC}.gz
# 	${LOAD_ENV} && \
# 	cd ${REV_LANGPAIR}/${REV_MODELNAME} && \
# 	${MARIAN_SCORER} \
# 		-m `grep -A1 models decoder.yml | tail -1 | sed 's/ *- //'` \
# 		-v `grep -A2 vocabs decoder.yml | tail -2 | sed 's/ *- //' | tr "\n" ' '` \
# 		-t ${PWD}/$@.src.gz ${PWD}/$@.trg.gz \
# 		-n1 -d 0 -w 10000 --mini-batch 128 \
# 		--max-length 200 --max-length-crop \
# 		--maxi-batch 256 --maxi-batch-sort src

