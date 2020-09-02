#
# fine-tune an existing model
# set SRC and TRG to source and target language IDs
#
#  make SRCLANGS=xx TRGLANGS=yy news-tune-data ...... create tuning data from newstest sets
#  make SRCLANGS=xx TRGLANGS=yy all ................. tune and eval
#
#
# create a package from the fine-tuned model
# NOTE: set SRCLANGS and TRGLANSG to make the top-level makefile happy
#
#  make SRCLANGS=xx TRGLANGS=yy dist
#
#
# other targets for special cases
#
#  make news-enfi ......... make tuned model for en-fi News
#  make goethe-defi ....... make model for Goethe Institute data
#  make waen .............. fine tune fr-en model for Walloon-English
#  make enwa .............. same as waen but for English-Walloon
#  make waen-dist ......... make a package for wa-en
#
#
# other targets for sub-tasks
#
#  make data .............. pre-process train/dev data
#  make tune .............. fine-tune model
#  make translate ......... translate test set with fine-tuned model
#  make translate-baseline  translate test set with baseline model
#  make eval .............. evaluate test set translation (fine-tuned)
#  make eval-baseline ..... evaluate test set translation (baseline)
#  make compare ........... put together source, reference translation and system output
#  make compare-baseline .. same as compare but with baseline translation
#
#
# NOTE: all this only works for SentencePiece models
#
# TODO
# - download base models from ObjectStorage
# - make it work with multilingual models
#   --> need to adjust preprocess-scripts for those models
#

include ../lib/env.mk
include ../lib/config.mk
include ../lib/slurm.mk


MODEL     = news


TRAIN_SRC = ${patsubst %.gz,%,$(wildcard ${LANGPAIRSTR}/${MODEL}/train/*.${SRC}.gz)}
DEV_SRC   = ${patsubst %.gz,%,$(wildcard ${LANGPAIRSTR}/${MODEL}/dev/*.${SRC}.gz)}
TEST_SRC  = ${patsubst %.gz,%,$(wildcard ${LANGPAIRSTR}/${MODEL}/test/*.${SRC}.gz)}

TRAIN_TRG = ${patsubst %.${SRC},%.${TRG},${TRAIN_SRC}}
DEV_TRG   = ${patsubst %.${SRC},%.${TRG},${DEV_SRC}}
TEST_TRG  = ${patsubst %.${SRC},%.${TRG},${TEST_SRC}}

OBJECTSTORAGE  = https://object.pouta.csc.fi
MODELCONTAINER = OPUS-MT-models
MODELINDEX     = ${OBJECTSTORAGE}/${MODELCONTAINER}/index.txt


# base model to be finetuned

ifndef BASE_SRCLANGS
  BASE_SRCLANGS = ${SRCLANGS}
endif
ifndef BASE_TRGLANGS
  BASE_TRGLANGS = ${TRGLANGS}
endif
BASE_LANGSRCSTR  = ${subst ${SPACE},+,$(BASE_SRCLANGS)}
BASE_LANGTRGSTR  = ${subst ${SPACE},+,$(BASE_TRGLANGS)}
BASE_LANGPAIRSTR = ${BASE_LANGSRCSTR}-${BASE_LANGTRGSTR}



# BASEMODELHOME     = ../models/${LANGPAIRSTR}
# BASEMODELZIP      = ${lastword ${sort ${wildcard ${BASEMODELHOME}/*-20*.zip}}}
# BASEMODELNAME     = ${patsubst %.zip,%,${notdir ${BASEMODELZIP}}}

BASEMODELHOME     = ${OBJECTSTORAGE}/${MODELCONTAINER}/${BASE_LANGPAIRSTR}
BASEMODELZIP      = ${lastword ${sort ${notdir ${shell grep '${BASE_LANGPAIRSTR}/${DATASET}-.*\.zip' model-index.txt}}}}
BASEMODELNAME     = ${BASEMODELZIP:.zip=}_${BASE_LANGPAIRSTR}

TUNED_MODEL       = ${LANGPAIRSTR}/${MODEL}/model/${BASEMODELNAME}_${MODEL}.transformer.model
TUNED_MODEL_VOCAB = ${LANGPAIRSTR}/${MODEL}/model/${BASEMODELNAME}_${MODEL}.vocab.yml


MARIAN_WORKSPACE      = 5000
MARIAN_VALID_FREQ     = 100
MARIAN_SAVE_FREQ      = ${MARIAN_VALID_FREQ}
MARIAN_DISP_FREQ      = ${MARIAN_VALID_FREQ}
MARIAN_EARLY_STOPPING = 5




.PHONY: all
all: model-index.txt
	${MAKE} ${TEST_SRC}.${BASEMODELNAME}.${TRG}.compare
	${MAKE} ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.compare


model-index.txt:
	wget -nv -O $@ ${MODELINDEX}


## convert a TMX file to create dev-test-train data
## and start fine-tuning in the direction of sorted lang-IDs
## set REVERSE = 1 to run in the opposite direction
##
## - this also does some filtering of the TMX
##    based on language identification and simple scripts and regexes
## - it assumes that ${TMX} points to a valid TMX files
## - it assumes that there are only 2 languages in the TMX (it will only use 2)


TMXFILE = VNK-Hallituksen_vuosikertomus.tmx
TMXBASE = ${TMXFILE:.tmx=}
REVERSE = 0

tmx-tune:
	cat ${TMXFILE} |\
	tmx2moses -r -o ${TMXBASE}
	if [ ${REVERSE} -gt 0 ]; then \
	  t=`ls ${TMXBASE}.*-* | sort | sed 's/^.*\.\([a-z]*\)$$/\1/' | head -1`; \
	  s=`ls ${TMXBASE}.*-* | sort | sed 's/^.*\.\([a-z]*\)$$/\1/' | tail -1`; \
	else \
	  s=`ls ${TMXBASE}.*-* | sort | sed 's/^.*\.\([a-z]*\)$$/\1/' | head -1`; \
	  t=`ls ${TMXBASE}.*-* | sort | sed 's/^.*\.\([a-z]*\)$$/\1/' | tail -1`; \
	fi; \
	echo $$s; echo $$t; \
	mkdir -p $$s-$$t; \
	paste ${TMXBASE}.*-*.$$s ${TMXBASE}.*-*.$$t | \
	sort | uniq | \
	python3 ../scripts/filter/bitext-match-lang.py -s $$s -t $$t | \
	grep -v '[<>{}]' |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
	shuf > ${TMXBASE}.$$s-$$t.shuffled; \
	mkdir -p $$s-$$t/${TMXBASE}/dev; \
	mkdir -p $$s-$$t/${TMXBASE}/test; \
	mkdir -p $$s-$$t/${TMXBASE}/train; \
	head -1000 ${TMXBASE}.$$s-$$t.shuffled | cut -f1 | gzip -c \
		> $$s-$$t/${TMXBASE}/test/${TMXBASE}.$$s.gz; \
	head -1000 ${TMXBASE}.$$s-$$t.shuffled | cut -f2 | gzip -c \
		> $$s-$$t/${TMXBASE}/test/${TMXBASE}.$$t.gz; \
	head -2001 ${TMXBASE}.$$s-$$t.shuffled | tail -1000 | cut -f1 | gzip -c \
		> $$s-$$t/${TMXBASE}/dev/${TMXBASE}.$$s.gz; \
	head -2001 ${TMXBASE}.$$s-$$t.shuffled | tail -1000 | cut -f2 | gzip -c \
		> $$s-$$t/${TMXBASE}/dev/${TMXBASE}.$$t.gz; \
	tail -n +2002 ${TMXBASE}.$$s-$$t.shuffled | cut -f1 | gzip -c \
		> $$s-$$t/${TMXBASE}/train/${TMXBASE}.$$s.gz; \
	tail -n +2002 ${TMXBASE}.$$s-$$t.shuffled | cut -f2 | gzip -c \
		> $$s-$$t/${TMXBASE}/train/${TMXBASE}.$$t.gz; \
	mv ${TMXBASE}.*-* $$s-$$t/; \
	${MAKE} SRCLANGS=$$s TRGLANGS=$$t MODEL=${TMXBASE} \
		TRAIN_SRC=$$s-$$t/${TMXBASE}/train/${TMXBASE}.$$s \
		TRAIN_TRG=$$s-$$t/${TMXBASE}/train/${TMXBASE}.$$t \
		DEV_SRC=$$s-$$t/${TMXBASE}/dev/${TMXBASE}.$$s \
		DEV_TRG=$$s-$$t/${TMXBASE}/dev/${TMXBASE}.$$t \
		TEST_SRC=$$s-$$t/${TMXBASE}/test/${TMXBASE}.$$s \
		TEST_TRG=$$s-$$t/${TMXBASE}/test/${TMXBASE}.$$t \
	all




## awful hack to fix a problem with the pre-processing script for the target language

.PHONY: en-simplify
en-simplify:
	${MAKE} SRCLANGS=en1 TRGLANGS=en2 \
		MODEL=simplewiki_v1 \
		SRCPRE_PARA="en en en1-en2/opus-2020-03-02/source.spm" \
		TRGPRE_PARA="en en en1-en2/opus-2020-03-02/target.spm | sed 's/^>>en<< //'" \
		BASEMODELHOME=../models/en+el+es+fi-en+el+es+fi \
		BASEMODELZIP=opus-2020-03-02.zip \
		TRAIN_SRC=en1-en2/simplewiki_v1/train/simplewiki_v1-training.en-en.clean.en1 \
		TRAIN_TRG=en1-en2/simplewiki_v1/train/simplewiki_v1-training.en-en.clean.en2 \
		DEV_SRC=en1-en2/simplewiki_v1/dev/simplewiki_v1-tuning.en-en.clean.en1 \
		DEV_TRG=en1-en2/simplewiki_v1/dev/simplewiki_v1-tuning.en-en.clean.en2 \
		TEST_SRC=en1-en2/simplewiki_v1/test/simplewiki_v1-testing.en-en.clean.en1 \
		TEST_TRG=en1-en2/simplewiki_v1/test/simplewiki_v1-testing.en-en.clean.en2 \
	all


.PHONY: news-enfi
news-enfi:
	${MAKE} SRCLANGS=en TRGLANGS=fi MODEL=news \
		TRAIN_SRC=en-fi/news/train/newstest2015-2018.en \
		TRAIN_TRG=en-fi/news/train/newstest2015-2018.fi \
		DEV_SRC=en-fi/news/dev/newsdev2015-enfi.en \
		DEV_TRG=en-fi/news/dev/newsdev2015-enfi.fi \
		TEST_SRC=en-fi/news/test/newstest2019-enfi.en \
		TEST_TRG=en-fi/news/test/newstest2019-enfi.fi \
	all

.PHONY: goethe-defi
goethe-defi:
	${MAKE} SRCLANGS=de TRGLANGS=fi MODEL=goethe \
		TRAIN_SRC=de-fi/goethe/train/goethe-institute-train.de \
		TRAIN_TRG=de-fi/goethe/train/goethe-institute-train.fi \
		DEV_SRC=de-fi/goethe/dev/goethe-institute-dev1.de \
		DEV_TRG=de-fi/goethe/dev/goethe-institute-dev1.fi \
		TEST_SRC=de-fi/goethe/test/goethe-institute-test1.de \
		TEST_TRG=de-fi/goethe/test/goethe-institute-test1.fi \
	all

goethe2-defi:
	${MAKE} SRCLANGS=de TRGLANGS=fi MODEL=goethe2 \
		TRAIN_SRC=de-fi/goethe/train/goethe-institute-train2.de \
		TRAIN_TRG=de-fi/goethe/train/goethe-institute-train2.fi \
		DEV_SRC=de-fi/goethe/dev/goethe-institute-dev2.de \
		DEV_TRG=de-fi/goethe/dev/goethe-institute-dev2.fi \
		TEST_SRC=de-fi/goethe/test/goethe-institute-test1.de \
		TEST_TRG=de-fi/goethe/test/goethe-institute-test1.fi \
	all


## without reference normalisation
goethe-other:
	${GZCAT} de-fi/goethe/test/goethe-institute-test1.fi.gz > $@.ref
	for s in systran yandex google; do \
	  cat ${HOME}/research/GoetheInstitute/data/test_de_oaversetted_van_$$s.txt |\
	   gzip -c > de-fi/goethe/test/goethe-institute-test1.de.$$s.de.gz; \
	  ${GZCAT} de-fi/goethe/test/goethe-institute-test1.de.$$s.de.gz | sacrebleu $@.ref \
	  > de-fi/goethe/test/goethe-institute-test1.de.$$s.de.eval; \
	  ${GZCAT} de-fi/goethe/test/goethe-institute-test1.de.$$s.de.gz | sacrebleu --metrics=chrf --width=3 $@.ref \
	  >> de-fi/goethe/test/goethe-institute-test1.de.$$s.de.eval; \
	done
	rm -f $@.ref

## with reference normalisation (should not do this)
goethe-other-norm:
	${GZCAT} de-fi/goethe/test/goethe-institute-test1.fi.gz |\
	${TOKENIZER}/replace-unicode-punctuation.perl |\
	${TOKENIZER}/remove-non-printing-char.perl |\
	${TOKENIZER}/normalize-punctuation.perl -l ${TRG} |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' > $@.ref
	for s in systran yandex google; do \
	  cat ${HOME}/research/GoetheInstitute/data/test_de_oaversetted_van_$$s.txt |\
	  ${TOKENIZER}/replace-unicode-punctuation.perl |\
	  ${TOKENIZER}/remove-non-printing-char.perl |\
	  ${TOKENIZER}/normalize-punctuation.perl -l ${TRG} |\
	  sed 's/  */ /g;s/^ *//g;s/ *$$//g' | gzip -c > de-fi/goethe/test/goethe-institute-test1.de.$$s.de.gz; \
	  ${GZCAT} de-fi/goethe/test/goethe-institute-test1.de.$$s.de.gz | sacrebleu $@.ref \
	  > de-fi/goethe/test/goethe-institute-test1.de.$$s.de.eval-norm; \
	  ${GZCAT} de-fi/goethe/test/goethe-institute-test1.de.$$s.de.gz | sacrebleu --metrics=chrf --width=3 $@.ref \
	  >> de-fi/goethe/test/goethe-institute-test1.de.$$s.de.eval-norm; \
	done
	rm -f $@.ref

goethe-test:
	${MAKE} SRCLANGS=de TRGLANGS=fi MODEL=goethe-test \
		TRAIN_SRC=de-fi/goethe-test/train/goethe-all.de \
		TRAIN_TRG=de-fi/goethe-test/train/goethe-all.fi \
		DEV_SRC=de-fi/goethe-test/dev/goethe-institute-dev1.de \
		DEV_TRG=de-fi/goethe-test/dev/goethe-institute-dev1.fi \
		TEST_SRC=de-fi/goethe-test/test/goethe-institute-test1.de \
		TEST_TRG=de-fi/goethe-test/test/goethe-institute-test1.fi \
	all




## make dist:
## 
## make a package of the fine-tuned model
## and copy it into the models directory (../models)

## test data evaluation for to generate info about test score in the README.md
OLD_TEST_EVAL = ${TEST_SRC}.${BASEMODELNAME}.${TRG}.eval
NEW_TEST_DATA = ${patsubst %.${SRC},%,${notdir ${TEST_SRC}}}
NEW_TEST_EVAL = ${LANGPAIRSTR}/${MODEL}/model/${NEW_TEST_DATA}.${DATASET}-${MODEL}.${PRE_SRC}-${PRE_TRG}${NR}.transformer.${SRC}.${TRG}.eval

dist:
	cp ${OLD_TEST_EVAL} ${NEW_TEST_EVAL}
	${MAKE} -C .. \
		MODELSHOME=${PWD}/../models \
		MODELS_URL=https://object.pouta.csc.fi/OPUS-MT-models \
		DATASET=${DATASET}-${MODEL} \
		SRCLANGS=${SRCLANGS} TRGLANGS=${TRGLANGS} \
		PREPROCESS_TYPE=spm \
		MODELTYPE=transformer \
		PREPROCESS_SRCMODEL=${PWD}/${LANGPAIRSTR}/${BASEMODELNAME}/source.spm \
		PREPROCESS_TRGMODEL=${PWD}/${LANGPAIRSTR}/${BASEMODELNAME}/target.spm \
		PREPROCESS_DESCRIPTION="normalization + SentencePiece" \
		MODEL_FINAL=${PWD}/${TUNED_MODEL}.npz.best-perplexity.npz \
		MODEL_DECODER=${PWD}/${TUNED_MODEL}.npz.best-perplexity.npz.decoder.yml \
		MODEL_VOCAB=${PWD}/${TUNED_MODEL_VOCAB} \
		MODEL_VALIDLOG=${patsubst %.model,%.valid.log,${PWD}/${TUNED_MODEL}} \
		MODEL_TRAINLOG=${patsubst %.model,%.train.log,${PWD}/${TUNED_MODEL}} \
		TEST_EVALUATION=${PWD}/${TEST_SRC}.${BASEMODELNAME}.${TRG}.eval \
		TEST_COMPARISON=${PWD}/${TEST_SRC}.${BASEMODELNAME}.${TRG}.compare \
		WORKDIR=${PWD}/${LANGPAIRSTR}/${MODEL}/model \
	dist



# ## fine-tune en-fr model for walloon
# ## --> can we do that?

waen:	wa-en/opus/train/opus.wa.gz \
	wa-en/opus/train/opus.en.gz \
	wa-en/opus/dev/Tatoeba.wa.gz \
	wa-en/opus/dev/Tatoeba.en.gz \
	wa-en/opus/test/Tatoeba.wa.gz \
	wa-en/opus/test/Tatoeba.en.gz
	${MAKE} MODEL=opus \
		MARIAN_VALID_FREQ=500 \
		SRCLANGS=wa TRGLANGS=en \
		BASE_SRCLANGS=fr BASE_TRGLANGS=en all

wa-en/opus/train/opus.wa.gz: ../work/wa-en/train/opus.src.clean.spm32k.gz
	mkdir -p ${dir $@}
	${GZCAT} $< | sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' | gzip -c > $@

wa-en/opus/train/opus.en.gz: ../work/wa-en/train/opus.trg.clean.spm32k.gz
	mkdir -p ${dir $@}
	${GZCAT} $< | sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' | gzip -c > $@

wa-en/opus/dev/Tatoeba.wa.gz: ../work/wa-en/val/Tatoeba.src
	mkdir -p ${dir $@}
	gzip -c < $< > $@

wa-en/opus/dev/Tatoeba.en.gz: ../work/wa-en/val/Tatoeba.trg
	mkdir -p ${dir $@}
	gzip -c < $< > $@

wa-en/opus/test/Tatoeba.wa.gz: ../work/wa-en/test/Tatoeba.src
	mkdir -p ${dir $@}
	gzip -c < $< > $@

wa-en/opus/test/Tatoeba.en.gz: ../work/wa-en/test/Tatoeba.trg
	mkdir -p ${dir $@}
	gzip -c < $< > $@


enwa:	en-wa/opus/train/opus.wa.gz \
	en-wa/opus/train/opus.en.gz \
	en-wa/opus/dev/Tatoeba.wa.gz \
	en-wa/opus/dev/Tatoeba.en.gz \
	en-wa/opus/test/Tatoeba.wa.gz \
	en-wa/opus/test/Tatoeba.en.gz
	${MAKE} MODEL=opus \
		MARIAN_VALID_FREQ=500 \
		SRCLANGS=en TRGLANGS=wa \
		BASE_SRCLANGS=en BASE_TRGLANGS=fr all

en-wa/opus/train/opus.en.gz: ../work/en-wa/train/opus.src.clean.spm32k.gz
	mkdir -p ${dir $@}
	${GZCAT} $< | sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' | gzip -c > $@

en-wa/opus/train/opus.wa.gz: ../work/en-wa/train/opus.trg.clean.spm32k.gz
	mkdir -p ${dir $@}
	${GZCAT} $< | sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' | gzip -c > $@

en-wa/opus/dev/Tatoeba.en.gz: ../work/en-wa/val/Tatoeba.src
	mkdir -p ${dir $@}
	gzip -c < $< > $@

en-wa/opus/dev/Tatoeba.wa.gz: ../work/en-wa/val/Tatoeba.trg
	mkdir -p ${dir $@}
	gzip -c < $< > $@

en-wa/opus/test/Tatoeba.en.gz: ../work/en-wa/test/Tatoeba.src
	mkdir -p ${dir $@}
	gzip -c < $< > $@

en-wa/opus/test/Tatoeba.wa.gz: ../work/en-wa/test/Tatoeba.trg
	mkdir -p ${dir $@}
	gzip -c < $< > $@





# ## fine-tune en-fr model for walloon
# ## --> can we do that?

# ENWA = ${wildcard ${OPUSHOME}/*/latest/moses/en-wa.*}
# enwa-data: en-fr/enwa/train/enwa.fr.gz
# waen-data: fr-en/enwa/train/enwa.fr.gz
# waen-dist:
# 	${MAKE} SRCLANGS=wa TRGLANGS=en SRC=fr TRG=en MODEL=enwa dist


# en-fr/enwa/train/enwa.fr.gz: ${ENWA}
# 	mkdir -p en-fr/tmp
# 	cd en-fr/tmp; \
# 	for c in ${ENWA}; do \
# 	  unzip -n $$c; \
# 	done
# 	cat en-fr/tmp/*.wa > en-fr/all.wa
# 	cat en-fr/tmp/*.en > en-fr/all.en
# 	paste en-fr/all.en en-fr/all.wa |\
# 	$(TOKENIZER)/replace-unicode-punctuation.perl |\
# 	perl -CS -pe 'tr[\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}][]cd;' |\
# 	sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
# 	sort | uniq | shuf > en-fr/all.en-wa
# 	mkdir -p en-fr/enwa/dev
# 	mkdir -p en-fr/enwa/test
# 	mkdir -p en-fr/enwa/train
# 	head -1000 en-fr/all.en-wa | cut -f1 | gzip -c \
# 		> en-fr/enwa/test/enwa.en.gz
# 	head -1000 en-fr/all.en-wa | cut -f2 | gzip -c \
# 		> en-fr/enwa/test/enwa.fr.gz
# 	head -2001 en-fr/all.en-wa | tail -1000 | cut -f1 | gzip -c \
# 		> en-fr/enwa/dev/enwa.en.gz
# 	head -2001 en-fr/all.en-wa | tail -1000 | cut -f2 | gzip -c \
# 		> en-fr/enwa/dev/enwa.fr.gz
# 	tail -n +2002 en-fr/all.en-wa | cut -f1 | gzip -c \
# 		> en-fr/enwa/train/enwa.en.gz
# 	tail -n +2002 en-fr/all.en-wa | cut -f2 | gzip -c \
# 		> en-fr/enwa/train/enwa.fr.gz
# 	rm -f en-fr/all.*
# 	rm -fr en-fr/tmp



# fr-en/enwa/train/enwa.fr.gz: en-fr/enwa/train/enwa.fr.gz
# 	mkdir -p fr-en/enwa/dev
# 	mkdir -p fr-en/enwa/test
# 	mkdir -p fr-en/enwa/train
# 	cp en-fr/enwa/test/enwa.en.gz fr-en/enwa/test/
# 	cp en-fr/enwa/test/enwa.fr.gz fr-en/enwa/test/
# 	cp en-fr/enwa/dev/enwa.en.gz fr-en/enwa/dev/
# 	cp en-fr/enwa/dev/enwa.fr.gz fr-en/enwa/dev/
# 	cp en-fr/enwa/train/enwa.en.gz fr-en/enwa/train/
# 	cp en-fr/enwa/train/enwa.fr.gz fr-en/enwa/train/


# enwa: en-fr/enwa/train/enwa.fr.gz
# 	${MAKE} SRC=en TRG=fr MODEL=enwa all

# waen: fr-en/enwa/train/enwa.fr.gz
# 	${MAKE} SRC=fr TRG=en MODEL=enwa all





## make news tuning data from testsets

TESTSETS_HOME     = ../testsets/${LANGPAIRSTR}
NEWS_ALLSETS_SRC  = ${sort ${wildcard ${TESTSETS_HOME}/news*.${SRC}.gz}}
NEWS_ALLSETS_TRG  = ${sort ${wildcard ${TESTSETS_HOME}/news*.${TRG}.gz}}
NEWS_DEVSET_SRC   = ${firstword ${NEWS_ALLSETS_SRC}}
NEWS_DEVSET_TRG   = ${firstword ${NEWS_ALLSETS_TRG}}
NEWS_TESTSET_SRC  = ${lastword ${NEWS_ALLSETS_SRC}}
NEWS_TESTSET_TRG  = ${lastword ${NEWS_ALLSETS_TRG}}
NEWS_TRAINSET_SRC = ${filter-out ${NEWS_DEVSET_SRC} ${NEWS_TESTSET_SRC},${NEWS_ALLSETS_SRC}}
NEWS_TRAINSET_TRG = ${filter-out ${NEWS_DEVSET_TRG} ${NEWS_TESTSET_TRG},${NEWS_ALLSETS_TRG}}

.PHONY: news-tune-data
news-tune-data:
ifneq (${words ${NEWS_ALLSETS_SRC}},0)
ifneq (${words ${NEWS_ALLSETS_SRC}},1)
ifneq (${words ${NEWS_ALLSETS_SRC}},2)
	mkdir -p ${LANGPAIRSTR}/news/train
	mkdir -p ${LANGPAIRSTR}/news/dev
	mkdir -p ${LANGPAIRSTR}/news/test
	cp ${NEWS_TESTSET_SRC} ${LANGPAIRSTR}/news/test/
	cp ${NEWS_TESTSET_TRG} ${LANGPAIRSTR}/news/test/
	cp ${NEWS_DEVSET_SRC} ${LANGPAIRSTR}/news/dev/
	cp ${NEWS_DEVSET_TRG} ${LANGPAIRSTR}/news/dev/
	${ZCAT} ${NEWS_TRAINSET_SRC} | gzip -c > ${LANGPAIRSTR}/news/train/news.${SRC}.gz
	${ZCAT} ${NEWS_TRAINSET_TRG} | gzip -c > ${LANGPAIRSTR}/news/train/news.${TRG}.gz
endif
endif
endif



.PHONY: data
data: ${TRAIN_SRC}.pre.gz ${TRAIN_TRG}.pre.gz ${DEV_SRC}.pre.gz ${DEV_TRG}.pre.gz

.PHONY: basemodel
basemodel: ${LANGPAIRSTR}/${BASEMODELNAME}/decoder.yml
${LANGPAIRSTR}/${BASEMODELNAME}/decoder.yml:
	mkdir -p ${dir $@}
ifneq (${wildcard ${BASEMODELHOME}/${BASEMODELZIP}},)
	unzip -u -d ${dir $@} ${BASEMODELHOME}/${BASEMODELZIP}
else ifneq (${BASEMODELZIP},)
	wget -nv -O ${dir $@}/${BASEMODELZIP} ${BASEMODELHOME}/${BASEMODELZIP}
	cd ${dir $@} && unzip -u ${BASEMODELZIP}
else
	@echo "no model found for ${LANGAIR}!"
endif


SRCPRE_PARA = ${SRC} ${LANGPAIRSTR}/${BASEMODELNAME}/source.spm
TRGPRE_PARA = ${TRG} ${LANGPAIRSTR}/${BASEMODELNAME}/target.spm

.INTERMEDIATE: ${TRAIN_SRC}.pre.gz ${DEV_SRC}.pre.gz ${TEST_SRC}.pre.gz
${TRAIN_SRC}.pre.gz ${DEV_SRC}.pre.gz ${TEST_SRC}.pre.gz: %.pre.gz: %.gz ${LANGPAIRSTR}/${BASEMODELNAME}/decoder.yml
	${GZCAT} $< |\
	${LANGPAIRSTR}/${BASEMODELNAME}/preprocess.sh ${SRCPRE_PARA} |\
	gzip -c > $@

.INTERMEDIATE: ${TRAIN_TRG}.pre.gz ${DEV_TRG}.pre.gz
${TRAIN_TRG}.pre.gz ${DEV_TRG}.pre.gz: %.pre.gz: %.gz ${LANGPAIRSTR}/${BASEMODELNAME}/decoder.yml
	${GZCAT} $< |\
	${LANGPAIRSTR}/${BASEMODELNAME}/preprocess.sh ${TRGPRE_PARA} |\
	gzip -c > $@




.PHONY: tune
tune: ${TUNED_MODEL}.done

## train transformer model
${TUNED_MODEL}.npz.best-perplexity.npz: ${TUNED_MODEL}.done

${TUNED_MODEL}.done: ${TRAIN_SRC}.pre.gz ${TRAIN_TRG}.pre.gz ${DEV_SRC}.pre.gz ${DEV_TRG}.pre.gz \
		${LANGPAIRSTR}/${BASEMODELNAME}/decoder.yml
	mkdir -p ${dir $@}
	if [ ! -e ${@:done=npz} ]; then \
	  cp ${LANGPAIRSTR}/${BASEMODELNAME}/*.npz ${@:done=npz}; \
	  cp ${LANGPAIRSTR}/${BASEMODELNAME}/*.vocab.yml ${TUNED_MODEL_VOCAB}; \
	fi
	${LOADMODS} && ${MARIAN_TRAIN} ${MARIAN_EXTRA} \
        --model $(@:.done=.npz) \
	--type transformer \
        --train-sets ${word 1,$^} ${word 2,$^} ${MARIAN_TRAIN_WEIGHTS} \
        --max-length 500 \
        --vocabs ${TUNED_MODEL_VOCAB} ${TUNED_MODEL_VOCAB} \
        --mini-batch-fit \
	-w ${MARIAN_WORKSPACE} \
	--maxi-batch ${MARIAN_MAXI_BATCH} \
        --early-stopping ${MARIAN_EARLY_STOPPING} \
        --valid-freq ${MARIAN_VALID_FREQ} \
	--save-freq ${MARIAN_SAVE_FREQ} \
	--disp-freq ${MARIAN_DISP_FREQ} \
        --valid-sets ${word 3,$^} ${word 4,$^} \
        --valid-metrics perplexity \
        --valid-mini-batch ${MARIAN_VALID_MINI_BATCH} \
        --beam-size 12 --normalize 1 \
        --log $(@:.model.done=.train.log) --valid-log $(@:.model.done=.valid.log) \
        --enc-depth 6 --dec-depth 6 \
        --transformer-heads 8 \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
        --transformer-dropout ${MARIAN_DROPOUT} \
	--label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        --tied-embeddings-all \
	--overwrite --keep-best \
	--devices ${MARIAN_GPUS} \
        --sync-sgd --seed ${SEED} \
	--sqlite \
	--tempdir ${TMPDIR} \
        --exponential-smoothing
	touch $@



.PHONY: translate
translate: ${TEST_SRC}.${BASEMODELNAME}.${TRG}.gz

## translate test set
${TEST_SRC}.${BASEMODELNAME}.${TRG}.gz: ${TEST_SRC}.pre.gz ${TUNED_MODEL}.npz.best-perplexity.npz
	mkdir -p ${dir $@}
	${LOADMODS} && ${MARIAN_DECODER} \
		-i $< \
		-c ${word 2,$^}.decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > $@


.PHONY: translate-baseline
translate-baseline: ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.gz

## translate test set
${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.gz: ${TEST_SRC}.pre.gz ${LANGPAIRSTR}/${BASEMODELNAME}/decoder.yml
	mkdir -p ${dir $@}
	cd ${LANGPAIRSTR}/${BASEMODELNAME}; \
	${LOADMODS} && ${MARIAN_DECODER} \
		-i ${PWD}/$< \
		-c decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@



.PHONY: eval eval-baseline
eval: ${TEST_SRC}.${BASEMODELNAME}.${TRG}.eval
eval-baseline: ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.eval

## without reference normalisation
${TEST_SRC}.${BASEMODELNAME}.${TRG}.eval ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.eval: %.eval: %.gz ${TEST_TRG}.gz
	${ZCAT} ${TEST_TRG}.gz > $@.ref
	${ZCAT} $< | sacrebleu $@.ref > $@
	${ZCAT} $< | sacrebleu --metrics=chrf --width=3 $@.ref >> $@
	rm -f $@.ref

## with reference normalisation (should not do this)
${TEST_SRC}.${BASEMODELNAME}.${TRG}.eval-norm ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.eval-norm: %.eval-norm: %.gz ${TEST_TRG}.gz
	${ZCAT} ${TEST_TRG}.gz |\
	${TOKENIZER}/replace-unicode-punctuation.perl |\
	${TOKENIZER}/remove-non-printing-char.perl |\
	${TOKENIZER}/normalize-punctuation.perl -l ${TRG} |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' > $@.ref
	${ZCAT} $< | sacrebleu $@.ref > $@
	${ZCAT} $< | sacrebleu --metrics=chrf --width=3 $@.ref >> $@
	rm -f $@.ref




.PHONY: compare compare-baseline
compare: ${TEST_SRC}.${BASEMODELNAME}.${TRG}.compare
compare-baseline: ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.compare

${TEST_SRC}.${BASEMODELNAME}.${TRG}.compare ${TEST_SRC}.${BASEMODELNAME}.baseline.${TRG}.compare: %.compare: %.eval
	${ZCAT} ${TEST_SRC}.gz > $@.1
	${ZCAT} ${TEST_TRG}.gz > $@.2
	${ZCAT} ${<:.eval=.gz} > $@.3
	paste -d "\n" $@.1 $@.2 $@.3 |\
	sed 	-e "s/&apos;/'/g" \
		-e 's/&quot;/"/g' \
		-e 's/&lt;/</g' \
		-e 's/&gt;/>/g' \
		-e 's/&amp;/&/g' |\
	sed 'n;n;G;' > $@
	rm -f $@.1 $@.2 $@.3
