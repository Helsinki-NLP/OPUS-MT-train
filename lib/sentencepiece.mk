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

# SPMSRCMODEL = ${TRAIN_SRC}.spm${SRCBPESIZE:000=}k-model
# SPMTRGMODEL = ${TRAIN_TRG}.spm${TRGBPESIZE:000=}k-model

## NEW: always use the same name for the SPM models
## --> avoid overwriting validation/test data with new segmentation models
##     if a new data set is used
SPMSRCMODEL = ${WORKDIR}/train/${BPEMODELNAME}.src.spm${SRCBPESIZE:000=}k-model
SPMTRGMODEL = ${WORKDIR}/train/${BPEMODELNAME}.trg.spm${TRGBPESIZE:000=}k-model
# SPMEXTRA = --split_by_whitespace=false
SPMEXTRA = 

.PRECIOUS: ${SPMSRCMODEL} ${SPMTRGMODEL}

## set to 1 if you want to generate SPM vocab file
GENERATE_SPM_VOC = 0


## we keep the dependency on LOCAL_TRAIN_SRC
## to make multi-threaded make calls behave properly
## --> otherwise there can be multiple threads writing to the same file!

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
	cut -f2- -d ' ' ${LOCAL_TRAIN_SRC} | grep . | ${SHUFFLE} > ${LOCAL_TRAIN_SRC}.text
else
	grep . ${LOCAL_TRAIN_SRC} | ${SHUFFLE} > ${LOCAL_TRAIN_SRC}.text
endif
	${MAKE} ${LOCAL_TRAIN_SRC}.charfreq
	if [ `cat ${LOCAL_TRAIN_SRC}.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SRCBPESIZE) --input=${LOCAL_TRAIN_SRC}.text \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(SRCBPESIZE) --input=${LOCAL_TRAIN_SRC}.text \
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
	grep . ${LOCAL_TRAIN_TRG} | ${SHUFFLE} > ${LOCAL_TRAIN_TRG}.text
	${MAKE} ${LOCAL_TRAIN_TRG}.charfreq
	if [ `cat ${LOCAL_TRAIN_TRG}.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(TRGBPESIZE) --input=${LOCAL_TRAIN_TRG}.text \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(TRGBPESIZE) --input=${LOCAL_TRAIN_TRG}.text \
		--character_coverage=1.0 --hard_vocab_limit=false; \
	fi
	mv $@.model $@
ifeq (${GENERATE_SPM_VOC},1)
	${SPM_ENCODE} --model=$@ --generate_vocabulary < ${LOCAL_TRAIN_TRG}.text > $@.voc
endif
	rm -f ${LOCAL_TRAIN_TRG}.text
endif





## sentence piece model trained on monolingual data
SPMMODEL   = ${SPMDIR}/${LANGSTR}/${BPEMODELNAME}.spm${BPESIZE:000=}k-model
SPMSRCMONO = ${SPMDIR}/${LANGSRCSTR}/${BPEMODELNAME}.spm${SRCBPESIZE:000=}k-model
SPMTRGMONO = ${SPMDIR}/${LANGTRGSTR}/${BPEMODELNAME}.spm${TRGBPESIZE:000=}k-model

## vocabulary files created from monolingual data
SPMVOCAB    = ${SPMDIR}/${LANGSTR}/${BPEMODELNAME}.spm${BPESIZE:000=}k.vocab.yml
SPMSRCVOCAB = ${SPMDIR}/${LANGSRCSTR}/${BPEMODELNAME}.spm${SRCBPESIZE:000=}k.vocab.yml
SPMTRGVOCAB = ${SPMDIR}/${LANGTRGSTR}/${BPEMODELNAME}.spm${TRGBPESIZE:000=}k.vocab.yml

.PRECIOUS: ${SPMMODEL} ${SPMSRCMONO} ${SPMTRGMONO} ${SPMVOCAB}

mono-spm-vocab: ${SPMVOCAB}

ifneq (${SPMVOCAB},${SPMSRCVOCAB})
  ${SPMSRCVOCAB}:
	${MAKE} LANGS=${SRCLANGS} BPESIZE=${SRCBPESIZE} mono-spm-vocab
endif

ifneq (${SPMVOCAB},${SPMTRGVOCAB})
  ${SPMTRGVOCAB}:
	${MAKE} LANGS=${TRGLANGS} BPESIZE=${TRGBPESIZE} mono-spm-vocab
endif


${SPMVOCAB}: ${LOCAL_MONO_DATA}.${PRE} ${SPMMODEL}
ifeq ($(wildcard ${SPMVOCAB}),)
	mkdir -p ${dir $@}
	${SPM_ENCODE} --model ${SPMMODEL} < $< |\
	${MARIAN_VOCAB} --max-size ${VOCABSIZE} > $@
else
	@echo "$@ already exists!"
	@echo "WARNING! No new vocabulary is created even though the data has changed!"
	@echo "WARNING! Delete the file if you want to start from scratch!"
	touch $@
endif



## sentence piece model trained on monolingual data

mono-spm-model: ${SPMMODEL}

ifneq (${SPMMODEL},${SPMSRCMONO})
  ${SPMSRCMONO}:
	${MAKE} LANGS=${SRCLANGS} BPESIZE=${SRCBPESIZE} mono-spm-model
endif

ifneq (${SPMMODEL},${SPMTRGMONO})
  ${SPMTRGMONO}:
	${MAKE} LANGS=${TRGLANGS} BPESIZE=${TRGBPESIZE} mono-spm-model
endif


${SPMMODEL}: ${LOCAL_MONO_DATA}.${PRE}
ifeq ($(wildcard ${SPMMODEL}),)
	mkdir -p ${dir $@}
	grep . $< | ${SHUFFLE} > $<.text
	${MAKE} ${LOCAL_MONO_DATA}.${PRE}.charfreq
	if [ `cat ${LOCAL_MONO_DATA}.${PRE}.charfreq | wc -l` -gt 1000 ]; then \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(TRGBPESIZE) --input=$<.text \
		--character_coverage=0.9995 --hard_vocab_limit=false; \
	else \
	  ${SPM_TRAIN} ${SPMEXTRA} \
		--model_prefix=$@ --vocab_size=$(TRGBPESIZE) --input=$<.text \
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

%.src.spm${SRCBPESIZE:000=}k: %.src ${SPMSRCMODEL}
ifeq (${USE_TARGET_LABELS},1)
	cut -f1 -d ' ' $< > $<.labels
	cut -f2- -d ' ' $< > $<.txt
	${SPM_ENCODE} --model $(word 2,$^) < $<.txt > $@.txt
	paste -d ' ' $<.labels $@.txt > $@
	rm -f $<.labels $<.txt $@.txt
else
	${SPM_ENCODE} --model $(word 2,$^) < $< > $@
endif

%.trg.spm${TRGBPESIZE:000=}k: %.trg ${SPMTRGMODEL}
	${SPM_ENCODE} --model $(word 2,$^) < $< > $@


## document-level models (with guided alignment)
%.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz:
	${MAKE} PRE_SRC=spm${SRCBPESIZE:000=}k PRE_TRG=spm${TRGBPESIZE:000=}k wordalign
	${SCRIPTDIR}/large-context.pl -l ${CONTEXT_SIZE} \
		${patsubst %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz,%.src.spm${SRCBPESIZE:000=}k.gz,$@} \
		${patsubst %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz,%.trg.spm${TRGBPESIZE:000=}k.gz,$@} \
		${patsubst %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz,%.spm${SRCBPESIZE:000=}k-spm${TRGBPESIZE:000=}k.src-trg.alg.gz,$@} \
	| ${GZIP} > $@.tmp.gz
	${GZIP} -cd < $@.tmp.gz | cut -f1 | ${GZIP} -c > $@
	${GZIP} -cd < $@.tmp.gz | cut -f2 | ${GZIP} -c > ${subst .src.,.trg.,$@}
	${GZIP} -cd < $@.tmp.gz | cut -f3 | \
		${GZIP} -c > ${patsubst %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz,\
		%.spm${SRCBPESIZE:000=}k.doc${CONTEXT_SIZE}-spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.src-trg.alg.gz,$@}
	rm -f $@.tmp.gz

%.trg.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz: %.src.spm${SRCBPESIZE:000=}k.doc${CONTEXT_SIZE}.gz
	@echo "done!"



## for validation and test data:
%.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}:
	${MAKE} PRE_SRC=spm${SRCBPESIZE:000=}k PRE_TRG=spm${TRGBPESIZE:000=}k devdata
	${MAKE} PRE_SRC=spm${SRCBPESIZE:000=}k PRE_TRG=spm${TRGBPESIZE:000=}k testdata
	./large-context.pl -l ${CONTEXT_SIZE} \
		${patsubst %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE},%.src.spm${SRCBPESIZE:000=}k,$@} \
		${patsubst %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE},%.trg.spm${TRGBPESIZE:000=}k,$@} \
	| ${GZIP} > $@.tmp.gz
	${GZIP} -cd < $@.tmp.gz | cut -f1 > $@
	${GZIP} -cd < $@.tmp.gz | cut -f2 > ${subst .src.,.trg.,$@}
	rm -f $@.tmp.gz

%.trg.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}: %.src.spm${TRGBPESIZE:000=}k.doc${CONTEXT_SIZE}
	@echo "done!"

