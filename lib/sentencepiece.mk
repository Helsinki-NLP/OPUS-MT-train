# -*-makefile-*-
#
# create sentence piece models
#
#   - create models from each part of a bitext
#   - individual models for each language in each language pair
#   - do not create new models if the data changes
#     ---> models need to use the same segmentation/vocab
#
# TODO: should we do that for monolingual files instead
#       for creating them from the bilingual data only?
#  ---> could use more data
#  ---> don't need to re-create models for each language pair
#

.INTERMEDIATE: ${LOCAL_MONO_DATA}.${PRE}.charfreq
.INTERMEDIATE: ${LOCAL_TRAIN_SRC}.charfreq ${LOCAL_TRAIN_TRG}.charfreq

##----------------------------------------------
## sentence piece
##----------------------------------------------

spm-models: ${SPMSRCMODEL} ${SPMTRGMODEL}

# SPMEXTRA = --split_by_whitespace=false
SPMEXTRA = 

## set to 1 if you want to generate SPM vocab file
GENERATE_SPM_VOC = 0

# SPM_INPUT_SIZE  = 10000000
SPM_INPUT_SIZE    = 2000000
SPM_SHUFFLE_INPUT = 0

ifneq (${DATA_IS_SHUFFLED},1)
  SPM_PREPROCESS = grep . | ${SHUFFLE}
else
  SPM_PREPROCESS = grep .
endif


##-------------------------------------------
## simple trick to use a joint subword model:
##   just duplicate the model to work for
##   source and target language texts
##-------------------------------------------

ifeq ($(USE_JOINT_SUBWORD_MODEL),1)

${SPMSRCMODEL}: ${SPM_MODEL}
	ln -s $< $@
	ln -s $<.vocab $@.vocab

${SPMTRGMODEL}: ${SPM_MODEL}
	ln -s $< $@
	ln -s $<.vocab $@.vocab

else

##-------------------------------------------
## source and target side specific subword models:
##
## we keep the dependency on LOCAL_TRAIN_SRC
## to make multi-threaded make calls behave properly
## --> otherwise there can be multiple threads writing to the same file!
##-------------------------------------------

${SPMSRCMODEL}: ${LOCAL_TRAIN_SRC}
ifneq (${wildcard ${SPMSRCMODEL}},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! back-date $<"
	touch -r $@ $<
else
	mkdir -p ${dir $@}
ifeq (${USE_TARGET_LABELS},1)
	cut -f2- -d ' ' ${LOCAL_TRAIN_SRC} | ${SPM_PREPROCESS} | head -${SPM_INPUT_SIZE} > ${LOCAL_TRAIN_SRC}.text
else
	cat ${LOCAL_TRAIN_SRC} | ${SPM_PREPROCESS} | head -${SPM_INPUT_SIZE} > ${LOCAL_TRAIN_SRC}.text
endif
	${MAKE} ${LOCAL_TRAIN_SRC}.charfreq
	if [ `cat ${LOCAL_TRAIN_SRC}.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_SRCVOCAB_SIZE) --input=${LOCAL_TRAIN_SRC}.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_SRCVOCAB_SIZE) --input=${LOCAL_TRAIN_SRC}.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=1.0 --hard_vocab_limit=false; \
	fi
	mv $@.model $@
ifeq (${GENERATE_SPM_VOC},1)
	${SPM_ENCODE} --model=$@ --generate_vocabulary < ${LOCAL_TRAIN_SRC}.text > $@.voc
endif
	rm -f ${LOCAL_TRAIN_SRC}.text
endif


## no labels on the target language side
${SPMTRGMODEL}: ${LOCAL_TRAIN_TRG}
ifneq (${wildcard ${SPMTRGMODEL}},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! back-date $<"
	touch -r $@ $<
else
	mkdir -p ${dir $@}
	cat ${LOCAL_TRAIN_TRG} | ${SPM_PREPROCESS} | head -${SPM_INPUT_SIZE} > ${LOCAL_TRAIN_TRG}.text
	${MAKE} ${LOCAL_TRAIN_TRG}.charfreq
	if [ `cat ${LOCAL_TRAIN_TRG}.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_TRGVOCAB_SIZE) --input=${LOCAL_TRAIN_TRG}.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_TRGVOCAB_SIZE) --input=${LOCAL_TRAIN_TRG}.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=1.0 --hard_vocab_limit=false; \
	fi
	mv $@.model $@
ifeq (${GENERATE_SPM_VOC},1)
	${SPM_ENCODE} --model=$@ --generate_vocabulary < ${LOCAL_TRAIN_TRG}.text > $@.voc
endif
	rm -f ${LOCAL_TRAIN_TRG}.text
endif

endif


##-------------------------------------------
## joint sentence piece model
## (concatenate both, source and target language texts)
##-------------------------------------------

${SPM_MODEL}: ${LOCAL_TRAIN_SRC} ${LOCAL_TRAIN_TRG}
ifneq (${wildcard ${SPM_MODEL}},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! back-date $^"
	touch -r $@ $<
else
	mkdir -p ${dir $@}
	cat ${LOCAL_TRAIN_TRG} | ${SPM_PREPROCESS} | head -$$((${SPM_INPUT_SIZE}/2)) > ${LOCAL_TRAIN}.tmp
	cat ${LOCAL_TRAIN_TRG} | ${SPM_PREPROCESS} | head -$$((${SPM_INPUT_SIZE}/2)) >> ${LOCAL_TRAIN}.tmp
	${SHUFFLE} < ${LOCAL_TRAIN}.tmp > ${LOCAL_TRAIN}.text
	rm -f ${LOCAL_TRAIN}.tmp
	${MAKE} ${LOCAL_TRAIN}.text.charfreq
	if [ `cat ${LOCAL_TRAIN}.text.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_TRGVOCAB_SIZE) --input=${LOCAL_TRAIN}.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_TRGVOCAB_SIZE) --input=${LOCAL_TRAIN}.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=1.0 --hard_vocab_limit=false; \
	fi
	mv $@.model $@
ifeq (${GENERATE_SPM_VOC},1)
	${SPM_ENCODE} --model=$@ --generate_vocabulary < ${LOCAL_TRAIN}.text > $@.voc
endif
	rm -f ${LOCAL_TRAIN}.text
endif







## sentence piece model trained on monolingual data
SPM_MONO    = ${SPMDIR}/${LANGSTR}/${SUBWORD_MODEL_NAME}.${SUBWORDS}${BPESIZE:000=}k-model
SPM_SRCMONO = ${SPMDIR}/${LANGSRCSTR}/${SUBWORD_MODEL_NAME}.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k-model
SPM_TRGMONO = ${SPMDIR}/${LANGTRGSTR}/${SUBWORD_MODEL_NAME}.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k-model

## vocabulary files created from monolingual data
SPMVOCAB    = ${SPMDIR}/${LANGSTR}/${SUBWORD_MODEL_NAME}.${SUBWORDS}${BPESIZE:000=}k.vocab.yml
SPMSRCVOCAB = ${SPMDIR}/${LANGSRCSTR}/${SUBWORD_MODEL_NAME}.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k.vocab.yml
SPMTRGVOCAB = ${SPMDIR}/${LANGTRGSTR}/${SUBWORD_MODEL_NAME}.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.vocab.yml

.PRECIOUS: ${SPM_MONO} ${SPM_SRCMONO} ${SPM_TRGMONO} ${SPMVOCAB}

mono-spm-vocab: ${SPMVOCAB}


ifneq (${SPMVOCAB},${SPMSRCVOCAB})
  ${SPMSRCVOCAB}:
	${MAKE} LANGS="${SRCLANGS}" BPESIZE=${SUBWORD_SRCVOCAB_SIZE} mono-spm-vocab
endif

ifneq (${SPMSRCVOCAB},${SPMTRGVOCAB})
ifneq (${SPMVOCAB},${SPMTRGVOCAB})
  ${SPMTRGVOCAB}:
	${MAKE} LANGS="${TRGLANGS}" BPESIZE=${SUBWORD_TRGVOCAB_SIZE} mono-spm-vocab
endif
endif

${SPMVOCAB}: ${LOCAL_MONO_DATA}.${PRE} ${SPM_MONO}
ifeq ($(wildcard ${SPMVOCAB}),)
	mkdir -p ${dir $@}
	${SPM_ENCODE} --model ${SPM_MONO} < $< |\
	${MARIAN_VOCAB} --max-size ${VOCABSIZE} > $@
else
	@echo "$@ already exists!"
	@echo "WARNING! No new vocabulary is created even though the data has changed!"
	@echo "WARNING! Delete the file if you want to start from scratch!"
	touch $@
endif



## sentence piece model trained on monolingual data

mono-spm-model: ${SPM_MONO}

ifneq (${SPM_MONO},${SPM_SRCMONO})
  ${SPM_SRCMONO}:
	${MAKE} LANGS="${SRCLANGS}" BPESIZE=${SUBWORD_SRCVOCAB_SIZE} mono-spm-model
endif

ifneq (${SPMSRCMODEL},${SPM_TRGMONO})
ifneq (${SPM_MONO},${SPM_TRGMONO})
  ${SPM_TRGMONO}:
	${MAKE} LANGS="${TRGLANGS}" BPESIZE=${SUBWORD_TRGVOCAB_SIZE} mono-spm-model
endif
endif


${SPM_MONO}: ${LOCAL_MONO_DATA}.${PRE}
ifeq ($(wildcard ${SPM_MONO}),)
	mkdir -p ${dir $@}
	cat $< | ${SPM_PREPROCESS} | head -${SPM_INPUT_SIZE} > $<.text
	${MAKE} ${LOCAL_MONO_DATA}.${PRE}.charfreq
	if [ `cat ${LOCAL_MONO_DATA}.${PRE}.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_TRGVOCAB_SIZE) --input=$<.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SUBWORD_TRGVOCAB_SIZE) --input=$<.text \
		--input_sentence_size ${SPM_INPUT_SIZE} --shuffle_input_sentence ${SPM_SHUFFLE_INPUT} \
		--character_coverage=1.0 --hard_vocab_limit=false; \
	fi
	mv $@.model $@
	${SPM_ENCODE} --model=$@ --generate_vocabulary < $<.text > $@.voc
	rm -f $<.text
else
	@echo "$@ already exists!"
	@echo "WARNING! No new SPM model created!"
	@echo "WARNING! Delete the file if you want to start from scratch!"
endif

## SentencePiece parameters:
##
# --input_sentence_size (maximum size of sentences the trainer loads)  type: int32  default: 10000000
# --hard_vocab_limit (If set to false, --vocab_size is considered as a soft limit.)  type: bool  default: true
# --training_sentence_size (maximum size of sentences to train sentence pieces)  type: int32  default: 10000000
# --vocab_size (vocabulary size)  type: int32  default: 8000


## character frequence table
## --> used to decide about the character coverage level

## awk-based char-counter
#%.charfreq: %
#	sed 's/./& /g' < $< | tr ' ' "\n" | grep . |\
#	awk '!/^$$/{a[$$0]++}END{for (i in a)print i,a[i];}' > $@

## python-based char-counter (seems to be the fastest version)
## restrict to 1 million lines
%.charfreq: %
	head -1000000 $< > $<.1m
	-python -c "import collections, pprint; pprint.pprint(dict(collections.Counter(open('$<.1m', 'r').read())))" > $@
	rm -f $<.1m

%.charfreq: %.gz
	${GZIP} -cd < $< | head -1000000 > $<.1m
	-python -c "import collections, pprint; pprint.pprint(dict(collections.Counter(open('$<.1m', 'r').read())))" > $@
	rm -f $<.1m


## slow version
%.charfreq2: %
	head -10000000 $< |\
	sed 's/./& /g' | \
	tr ' ' "\n" | grep . |\
	sort | uniq -c > $@



## TODO: should we have vocab limits?
## --vocabulary={vocab_file}.L1 --vocabulary_threshold=50
## see https://github.com/google/sentencepiece#c-from-source

%.src.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k: %.src ${SUBWORD_SRC_MODEL}
ifeq (${USE_TARGET_LABELS},1)
	cut -f1 -d ' ' $< > $<.labels
	cut -f2- -d ' ' $< > $<.txt
	${SPM_ENCODE} --model $(word 2,$^) < $<.txt > $@.txt
	paste -d ' ' $<.labels $@.txt > $@
	rm -f $<.labels $<.txt $@.txt
else
	${SPM_ENCODE} --model $(word 2,$^) < $< > $@
endif

%.trg.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k: %.trg ${SUBWORD_TRG_MODEL}
	${SPM_ENCODE} --model $(word 2,$^) < $< > $@


## document-level models (with guided alignment)
%.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz:
	${MAKE} PRE_SRC=spm${SUBWORD_SRCVOCAB_SIZE:000=}k PRE_TRG=spm${SUBWORD_TRGVOCAB_SIZE:000=}k wordalign
	${SCRIPTDIR}/large-context.pl -l ${CONTEXT_SIZE} \
		${patsubst %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz,%.src.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k.gz,$@} \
		${patsubst %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz,%.trg.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.gz,$@} \
		${patsubst %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz,%.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k-spm${SUBWORD_TRGVOCAB_SIZE:000=}k.src-trg.alg.gz,$@} \
	| ${GZIP} > $@.tmp.gz
	${GZIP} -cd < $@.tmp.gz | cut -f1 | ${GZIP} -c > $@
	${GZIP} -cd < $@.tmp.gz | cut -f2 | ${GZIP} -c > ${subst .src.,.trg.,$@}
	${GZIP} -cd < $@.tmp.gz | cut -f3 | \
		${GZIP} -c > ${patsubst %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz,\
		%.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}-spm${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.src-trg.alg.gz,$@}
	rm -f $@.tmp.gz

%.trg.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz: %.src.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}.gz
	@echo "done!"



## for validation and test data:
%.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}:
	${MAKE} PRE_SRC=spm${SUBWORD_SRCVOCAB_SIZE:000=}k PRE_TRG=spm${SUBWORD_TRGVOCAB_SIZE:000=}k devdata
	${MAKE} PRE_SRC=spm${SUBWORD_SRCVOCAB_SIZE:000=}k PRE_TRG=spm${SUBWORD_TRGVOCAB_SIZE:000=}k testdata
	${SCRIPTDIR}/large-context.pl -l ${CONTEXT_SIZE} \
		${patsubst %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE},%.src.${SUBWORDS}${SUBWORD_SRCVOCAB_SIZE:000=}k,$@} \
		${patsubst %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE},%.trg.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k,$@} \
	| ${GZIP} > $@.tmp.gz
	${GZIP} -cd < $@.tmp.gz | cut -f1 > $@
	${GZIP} -cd < $@.tmp.gz | cut -f2 > ${subst .src.,.trg.,$@}
	rm -f $@.tmp.gz

%.trg.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}: %.src.${SUBWORDS}${SUBWORD_TRGVOCAB_SIZE:000=}k.doc${CONTEXT_SIZE}
	@echo "done!"

