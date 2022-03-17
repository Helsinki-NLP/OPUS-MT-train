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

PWD      := ${shell pwd}
REPOHOME := ${PWD}/../../

include ${REPOHOME}lib/env.mk
include ${REPOHOME}lib/config.mk
include ${REPOHOME}lib/slurm.mk


SRC = fin
TRG = eng


## change decoder settings
## TODO: do we need this?

MARIAN_BEAM_SIZE  = 1
MARIAN_MINI_BATCH = 128
MARIAN_MAXI_BATCH = 256
MARIAN_MAX_LENGTH = 200
MARIAN_WORKSPACE  = 12000

# MARIAN_MINI_BATCH = 768
# MARIAN_MAXI_BATCH = 2048


TATOEBA_VERSION          ?= v2021-08-07
TATOEBA_VERSION_NOHYPHEN ?= $(subst -,,${TATOEBA_VERSION})

TATOEBA_GITRAW        = https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master
TATOEBA_RELEASED      = ${TATOEBA_GITRAW}/models/released-model-results-all.txt
TATOEBA_RELEASED_BT   = https://object.pouta.csc.fi/Tatoeba-MT-bt/released-data.txt
TATOEBA_MODEL_STORAGE = https://object.pouta.csc.fi/Tatoeba-MT-models

## container for storing backtranslations
BT_CONTAINER          = Tatoeba-MT-bt
BT_CWORK_ONTAINER     = project-Tatoeba-MT-bt

## split size in nr-of-lines
## default part to be selected = aa
SPLIT_SIZE ?= 1000000

## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
MAX_LENGTH    ?= 200
MAX_SENTENCES ?= ${SPLIT_SIZE}

SORTLANGS          = $(sort ${SRC} ${TRG})
LANGPAIR           = ${SRC}-${TRG}
SORTED_LANGPAIR    = ${firstword ${SORTLANGS}}-${lastword ${SORTLANGS}}

PWD := $(shell pwd)



# MODELZIP = https://object.pouta.csc.fi/Tatoeba-Challenge/ang.tar
MODELZIP := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED} | grep '^${LANGPAIR}' | head -1 | cut -f4}
MODELINFO = ${patsubst ${TATOEBA_MODEL_STORAGE}/%.zip,${TATOEBA_GITRAW}/models/%.yml,${MODELZIP}}
MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}

MULTI_TARGET_MODEL := ${shell ${WGET} -qq -O - ${MODELINFO} | grep 'use-target-labels' | wc -l}
ifneq (${MULTI_TARGET_MODEL},0)
  TARGET_LANG_LABEL := ${shell ${WGET} -qq -O - ${MODELINFO} | grep -o '>>${TRG}.*<<' | head -1}
endif

RELEASED_BITEXTS := $(patsubst %.tar,%,${shell ${WGET} -qq -O - ${TATOEBA_GITRAW}/Wiki.md | \
					grep -o 'WikiShuffled/...\.tar' | cut -f2 -d'/'})

RELEASED_BITEXTS_REV = ${shell (for d in ${RELEASED_BITEXTS}; do echo $$d; done) | tac}


PART           ?= aa
OUTPUT_DIR     ?= ${LANGPAIR}

BITEXT_DATADIR = ${PWD}/../work/data/simple
MODEL_WORKDIR  = ${PWD}/../work/${LANGPAIR}
BITEXT_SRCRAW  = ${BITEXT_DATADIR}/Tatoeba-train-${TATOEBA_VERSION}.${SORTED_LANGPAIR}.${CLEAN_TRAINDATA_TYPE}.${SRC}.gz

BITEXT_BASE    = ${OUTPUT_DIR}/Tatoeba-train.${MODELNAME}.${LANGPAIR}
BITEXT_SRC     = ${BITEXT_BASE}.${SRC}.${PART}.gz
BITEXT_PRE     = ${BITEXT_BASE}.${SRC}.spm.${PART}.gz
BITEXT_TRG     = ${BITEXT_BASE}.${TRG}.${PART}.gz

BITEXT_LATEST_SRC    = ${OUTPUT_DIR}/latest/Tatoeba-train.${PART}.${LANGPAIR}.${SRC}.gz
BITEXT_LATEST_TRG    = ${OUTPUT_DIR}/latest/Tatoeba-train.${PART}.${LANGPAIR}.${TRG}.gz
BITEXT_LATEST_README = ${OUTPUT_DIR}/latest/README.md


## all parts of the bitext
PARTS                 = $(subst .,,${suffix ${basename ${wildcard ${BITEXT_PRE:${PART}.gz=}??.gz}}})
ALL_BITEXT_LATEST_SRC = ${patsubst %,${OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${SRC}.gz,${PARTS}}
ALL_BITEXT_LATEST_TRG = ${patsubst %,${OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${TRG}.gz,${PARTS}}


## don't delete translated text even if the process crashes
.PRECIOUS: ${BITEXT_BASE}.${TRG}.%.gz

.PHONY: all
all: prepare
	${MAKE} translate-all-parts
	${MAKE} score-translations
	${MAKE} sort-scored-translations


.PHONY: mtmodel
mtmodel: ${LANGPAIR}/${MODELNAME}/decoder.yml

.PHONY: prepare
prepare: ${LANGPAIR}/${MODELNAME}/decoder.yml ${BITEXT_PRE}

.PHONY: translate
translate: ${BITEXT_LATEST_README} ${BITEXT_LATEST_TRG}
	${MAKE} ${BITEXT_LATEST_SRC}

## translate all parts
.PHONY: translate-all-parts
translate-all-parts: ${ALL_BITEXT_LATEST_TRG}
	${MAKE} source-all-parts

.PHONY: source-all-parts
source-all-parts: ${ALL_BITEXT_LATEST_SRC}


.PHONY: print-modelinfo
print-modelinfo:
	@echo ${MODELNAME}
	@echo ${MODELZIP}
	@echo ${MODELINFO}
	@echo "multi-target model: ${MULTI_TARGET_MODEL}"
	@echo "target language label: ${TARGET_LANG_LABEL}"

print-modelname:
	@echo ${MODELNAME}

##-------------------------------------------
## translation model in reverse direction
## --> for scoring translations
##-------------------------------------------

REV_LANGPAIR  = ${TRG}-${SRC}
REV_MODELZIP := ${shell ${WGET} -qq -O - ${TATOEBA_RELEASED} | grep '^${REV_LANGPAIR}' | head -1 | cut -f4}
REV_MODELINFO = ${patsubst ${TATOEBA_MODEL_STORAGE}/%.zip,${TATOEBA_GITRAW}/models/%.yml,${REV_MODELZIP}}
REV_MODELNAME = ${patsubst %.zip,%,${notdir ${REV_MODELZIP}}}

REV_MULTI_TARGET_MODEL := ${shell ${WGET} -qq -O - ${REV_MODELINFO} | grep 'use-target-labels' | wc -l}
ifeq (${REV_MULTI_TARGET_MODEL},1)
  REV_SRC_PREPROCESS_ARGS = ${TRG} ${SRC} ${REV_LANGPAIR}/${REV_MODELNAME}/source.spm
  REV_TRG_PREPROCESS_ARGS = ${SRC} ${TRG} ${REV_LANGPAIR}/${REV_MODELNAME}/target.spm noflags
else
  REV_SRC_PREPROCESS_ARGS = ${TRG} ${REV_LANGPAIR}/${REV_MODELNAME}/source.spm
  REV_TRG_PREPROCESS_ARGS = ${SRC} ${REV_LANGPAIR}/${REV_MODELNAME}/target.spm
endif


## score translations with reverse translation model
## normalize scores (see https://github.com/browsermt/students)

SCOREFILES    = $(patsubst %.${SRC}.gz,%.${SRC}.scores.gz,$(wildcard ${OUTPUT_DIR}/latest/*.${SRC}.gz))
RAWSCOREFILES = $(patsubst %.${SRC}.gz,%.${SRC}.raw-scores.gz,$(wildcard ${OUTPUT_DIR}/latest/*.${SRC}.gz))

.PHONY: score-translation score-translations
score-translation: ${BITEXT_LATEST_SRC:.gz=.scores.gz}
score-translations: ${SCOREFILES}
sort-scored-translations: ${OUTPUT_DIR}/latest/Tatoeba-train.sorted.gz
sort-raw-scored-translations: ${OUTPUT_DIR}/latest/Tatoeba-train.sorted-raw.gz

print-score-file:
	echo ${BITEXT_LATEST_SRC:.gz=.scores.gz}

${OUTPUT_DIR}/latest/%.${SRC}.scores.gz: ${OUTPUT_DIR}/latest/%.${SRC}.gz
	${MAKE} SRC=${TRG} TRG=${SRC} mtmodel
	${GZCAT} ${<:.${SRC}.gz=.${TRG}.gz} |\
	${REV_LANGPAIR}/${REV_MODELNAME}/preprocess.sh ${REV_SRC_PREPROCESS_ARGS} | \
	${GZIP} -c > $@.src.gz
	${GZCAT} $< |\
	${REV_LANGPAIR}/${REV_MODELNAME}/preprocess.sh ${REV_TRG_PREPROCESS_ARGS} | \
	${GZIP} -c > $@.trg.gz
	${LOAD_ENV} && \
	cd ${REV_LANGPAIR}/${REV_MODELNAME} && \
	${MARIAN_SCORER} \
		-m `grep -A1 models decoder.yml | tail -1 | sed 's/ *- //'` \
		-v `grep -A2 vocabs decoder.yml | tail -2 | sed 's/ *- //' | tr "\n" ' '` \
		-t ${PWD}/$@.src.gz ${PWD}/$@.trg.gz \
		${MARIAN_SCORER_FLAGS} |\
	${GZIP} -c > ${PWD}/$(@:.scores.gz=.raw-scores.gz)
	paste <(gzip -dc $(@:.scores.gz=.raw-scores.gz)) <(gzip -dc $@.trg.gz) | \
	python3 ${SCRIPTDIR}/normalize-scores.py | cut -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz


${OUTPUT_DIR}/latest/Tatoeba-train.sorted.gz: ${SCOREFILES}
	${GZCAT} ${OUTPUT_DIR}/latest/*.${SRC}.scores.gz | ${GZIP} -c > $@.scores.gz
	${GZCAT} ${OUTPUT_DIR}/latest/*.${SRC}.gz | ${GZIP} -c > $@.src.gz
	${GZCAT} ${OUTPUT_DIR}/latest/*.${TRG}.gz | ${GZIP} -c > $@.trg.gz
	paste <(gzip -cd $@.scores.gz) <(gzip -cd $@.src.gz) <(gzip -cd $@.trg.gz) |\
	LC_ALL=C sort -n -k1,1 -S 10G | uniq -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz


${OUTPUT_DIR}/latest/Tatoeba-train.sorted-raw.gz: ${RAWSCOREFILES}
	${GZCAT} ${OUTPUT_DIR}/latest/*.${SRC}.raw-scores.gz | ${GZIP} -c > $@.raw-scores.gz
	${GZCAT} ${OUTPUT_DIR}/latest/*.${SRC}.gz | ${GZIP} -c > $@.src.gz
	${GZCAT} ${OUTPUT_DIR}/latest/*.${TRG}.gz | ${GZIP} -c > $@.trg.gz
	paste <(gzip -cd $@.raw-scores.gz) <(gzip -cd $@.src.gz) <(gzip -cd $@.trg.gz) |\
	LC_ALL=C sort -n -k1,1 -S 10G | uniq -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz


# Part of the data to be removed (0.05 is 5%)
# RETAIN - give a number in percent about how much to retain
# REMOVE - 
#
# (see https://github.com/browsermt/students)

# REMOVE = 0.05
# RETAIN = ${shell echo "100-100*${REMOVE}/1;" | bc}
RETAIN = 95
REMOVE = ${shell echo "scale=2; (100-${RETAIN})/100" | bc}

extract-best-translations: ${OUTPUT_DIR}/latest/Tatoeba-train.${SRC}.best${RETAIN}.gz
extract-rawbest-translations: ${OUTPUT_DIR}/latest/Tatoeba-train.${SRC}.rawbest${RETAIN}.gz

%.${SRC}.best${RETAIN}.gz: %.sorted.gz
	$(eval STARTLINE := $(shell ${GZIP} -dc $< | wc -l | sed "s|$$|*$(REMOVE)|" | bc | cut -f1 -d.))
	@echo Removing $(REMOVE) removes $(STARTLINE) lines
	${GZIP} -dc $< | tail -n +$(STARTLINE) | cut -f2,3 | \
	tee >(cut -f1 | gzip -c >$@) |\
	cut -f2 | gzip -c > ${@:.${SRC}.best${RETAIN}.gz=.${TRG}.best${RETAIN}.gz}

%.${TRG}.best${RETAIN}.gz: %.${SRC}.best${RETAIN}.gz
	@echo "done!"

%.${SRC}.rawbest${RETAIN}.gz: %.sorted-raw.gz
	$(eval STARTLINE := $(shell ${GZIP} -dc $< | wc -l | sed "s|$$|*$(REMOVE)|" | bc | cut -f1 -d.))
	@echo Removing $(REMOVE) removes $(STARTLINE) lines
	${GZIP} -dc $< | tail -n +$(STARTLINE) | cut -f2,3 | \
	tee >(cut -f1 | gzip -c >$@) |\
	cut -f2 | gzip -c > ${@:.${SRC}.rawbest${RETAIN}.gz=.${TRG}.rawbest${RETAIN}.gz}

%.${TRG}.raawbest${RETAIN}.gz: %.${SRC}.rawbest${RETAIN}.gz
	@echo "done!"







## fetch the latest model

${LANGPAIR}/${MODELNAME}/decoder.yml:
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${WGET} -O ${dir $@}/model.zip ${MODELZIP}
	cd ${dir $@} && unzip model.zip
	rm -f ${dir $@}/model.zip
	mv ${dir $@}/preprocess.sh ${dir $@}/preprocess-old.sh
	sed 's#perl -C -pe.*$$#perl -C -pe  "s/(?!\\n)\\p{C}/ /g;" |#' \
	< ${dir $@}/preprocess-old.sh > ${dir $@}/preprocess.sh
	chmod +x ${dir $@}/preprocess.sh
endif


## pre-process data

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${SRC} ${TRG} ${LANGPAIR}/${MODELNAME}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${LANGPAIR}/${MODELNAME}/source.spm
endif


${BITEXT_SRCRAW}:
	${MAKE} -C .. SRCLANGS=${SRC} TRGLANGS=${TRG} rawdata-tatoeba

${BITEXT_PRE}: ${BITEXT_SRCRAW}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${GZCAT} $< |\
	grep -v '[<>{}]' |\
	${LANGPAIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${MAX_LENGTH});print;}' |\
	split -l ${SPLIT_SIZE} - ${patsubst %${PART}.gz,%,$@}
	${GZIP} -f ${patsubst %${PART}.gz,%,$@}??
endif





## merge SentencePiece segments in the source text
## (Why? because we filter out some data from the original wiki text, see above)

${BITEXT_BASE}.${SRC}.%.gz: ${BITEXT_BASE}.${SRC}.spm.%.gz
	if [ -e ${patsubst ${BITEXT_BASE}.${SRC}.%.gz,${BITEXT_BASE}.${TRG}.%.gz,$@} ]; then \
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

${OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${SRC}.gz: ${BITEXT_BASE}.${SRC}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${OUTPUT_DIR}/latest/Tatoeba-train.%.${LANGPAIR}.${TRG}.gz: ${BITEXT_BASE}.${TRG}.%.gz
	mkdir -p ${dir $@}
	rsync $< $@

${BITEXT_LATEST_README}: ${LANGPAIR}/${MODELNAME}/README.md
	mkdir -p ${dir $@}
	rsync $< $@


## translate

${BITEXT_BASE}.${TRG}.%.gz: ${BITEXT_BASE}.${SRC}.spm.%.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${LOAD_ENV} && cd ${LANGPAIR}/${MODELNAME} && \
	${MARIAN_DECODER} \
		-c decoder.yml \
		-i ${PWD}/$< \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
endif



check-latest:
	@if [ -d ${LANGPAIR}/latest ]; then \
	  for S in `ls ${LANGPAIR}/latest/*.${SRC}.gz`; do \
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

check-scores:
	@if [ -d ${LANGPAIR}/latest ]; then \
	  for T in `ls ${LANGPAIR}/latest/*.${TRG}.gz`; do \
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


check-translated:
	@for S in `ls ${LANGPAIR}/*.${SRC}.spm.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	    else \
	      echo "$$a	$$S	$$T"; \
	    fi \
	done

check-length:
	@echo "check ${LANGPAIR}"
	@${MAKE} check-translated
	@${MAKE} check-latest


remove-%-all check-%-all:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  make SRC=$$s TRG=$$t ${@:-all=}; \
	done



remove-incomplete:
	${MAKE} remove-incomplete-translated
	${MAKE} remove-incomplete-latest

remove-incomplete-translated:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${LANGPAIR}/incomplete
	@for S in `ls ${LANGPAIR}/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${LANGPAIR}/incomplete/; \
	      mv $$T ${LANGPAIR}/incomplete/; \
	    fi \
	done


remove-incomplete-latest:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${LANGPAIR}/incomplete/latest
	@if [ -d ${LANGPAIR}/latest ]; then \
	  for S in `ls ${LANGPAIR}/latest/*.${SRC}.gz`; do \
	    T=`echo $$S | sed 's/.${SRC}.gz/.${TRG}.gz/'`; \
	    a=`${GZCAT} $$S | wc -l`; \
	    b=`${GZCAT} $$T | wc -l`; \
	    if [ $$a != $$b ]; then \
	      echo "$$a != $$b	$$S	$$T"; \
	      mv $$S ${LANGPAIR}/incomplete/latest/; \
	      mv $$T ${LANGPAIR}/incomplete/latest/; \
	    fi \
	  done \
	fi






# ## for testing purposes

# score2-translation: ${BITEXT_LATEST_SRC:.gz=.scores2}
# score3-translation: ${BITEXT_LATEST_SRC:.gz=.scores3}

# ${OUTPUT_DIR}/latest/%.${SRC}.scores2: ${OUTPUT_DIR}/latest/%.${SRC}.gz
# 	${MAKE} SRC=${TRG} TRG=${SRC} mtmodel
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

# ${OUTPUT_DIR}/latest/%.${SRC}.scores3: ${OUTPUT_DIR}/latest/%.${SRC}.gz
# 	${LOAD_ENV} && \
# 	cd ${REV_LANGPAIR}/${REV_MODELNAME} && \
# 	${MARIAN_SCORER} \
# 		-m `grep -A1 models decoder.yml | tail -1 | sed 's/ *- //'` \
# 		-v `grep -A2 vocabs decoder.yml | tail -2 | sed 's/ *- //' | tr "\n" ' '` \
# 		-t ${PWD}/$@.src.gz ${PWD}/$@.trg.gz \
# 		-n1 -d 0 -w 10000 --mini-batch 128 \
# 		--max-length 200 --max-length-crop \
# 		--maxi-batch 256 --maxi-batch-sort src

