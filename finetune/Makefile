#
# fine-tune an existing model
#
#  make news-tune-data ...... create tunig data from newstest sets
#  make all ................. tune and eval
#
#
# NOTE: this only works for SentencePiece models
#
# TODO
# - download base models from ObjectStorage
# - make it work with multilingual models
#   --> need to adjust preprocess-scripts for those models
#

include ../Makefile.env
include ../Makefile.config
include ../Makefile.slurm


SRC       = en
TRG       = de
LANGPAIR  = ${SRC}-${TRG}
MODEL     = news

TRAIN_SRC = ${patsubst %.gz,%,$(wildcard ${LANGPAIR}/${MODEL}/train/*.${SRC}.gz)}
DEV_SRC   = ${patsubst %.gz,%,$(wildcard ${LANGPAIR}/${MODEL}/dev/*.${SRC}.gz)}
TEST_SRC  = ${patsubst %.gz,%,$(wildcard ${LANGPAIR}/${MODEL}/test/*.${SRC}.gz)}

TRAIN_TRG = ${patsubst %.${SRC},%.${TRG},${TRAIN_SRC}}
DEV_TRG   = ${patsubst %.${SRC},%.${TRG},${DEV_SRC}}
TEST_TRG  = ${patsubst %.${SRC},%.${TRG},${TEST_SRC}}


BASEMODELHOME     = ../models/${LANGPAIR}
BASEMODELZIP      = ${lastword ${sort ${wildcard ${BASEMODELHOME}/*-20*.zip}}}
BASEMODELNAME     = ${patsubst %.zip,%,${notdir ${BASEMODELZIP}}}


TUNED_MODEL       = ${LANGPAIR}/${MODEL}/model/${BASEMODELNAME}_${MODEL}.transformer.model
TUNED_MODEL_VOCAB = ${LANGPAIR}/${MODEL}/model/${BASEMODELNAME}_${MODEL}.vocab.yml


MARIAN_WORKSPACE       = 5000
MARIAN_VALID_FREQ     = 100
MARIAN_SAVE_FREQ      = ${MARIAN_VALID_FREQ}
MARIAN_DISP_FREQ      = ${MARIAN_VALID_FREQ}
MARIAN_EARLY_STOPPING = 5




.PHONY: all
all: ${TEST_SRC}.${TRG}.compare


.PHONY: news-enfi
news-enfi:
	${MAKE} SRC=en TRG=fi MODEL=news \
		TRAIN_SRC=en-fi/news/train/newstest2015-2018.en \
		TRAIN_TRG=en-fi/news/train/newstest2015-2018.fi \
		DEV_SRC=en-fi/news/dev/newsdev2015-enfi.en \
		DEV_TRG=en-fi/news/dev/newsdev2015-enfi.fi \
		TEST_SRC=en-fi/news/test/newstest2019-enfi.en \
		TEST_TRG=en-fi/news/test/newstest2019-enfi.fi \
	all

.PHONY: goethe-fide
goethe-ende:
	${MAKE} SRC=fi TRG=de MODEL=goethe \
		TRAIN_SRC=fi-de/goethe/train/goethe-institute-train.fi \
		TRAIN_TRG=fi-de/goethe/train/goethe-institute-train.de \
		DEV_SRC=fi-de/goethe/dev/goethe-institute-dev1.fi \
		DEV_TRG=fi-de/goethe/dev/goethe-institute-dev1.de \
		TEST_SRC=fi-de/goethe/test/goethe-institute-test1.fi \
		TEST_TRG=fi-de/goethe/test/goethe-institute-test1.de \
	all



## make news tuning data from testsets

TESTSETS_HOME     = ../testsets/${LANGPAIR}
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
	mkdir -p ${LANGPAIR}/news/train
	mkdir -p ${LANGPAIR}/news/dev
	mkdir -p ${LANGPAIR}/news/test
	cp ${NEWS_TESTSET_SRC} ${LANGPAIR}/news/test/
	cp ${NEWS_TESTSET_TRG} ${LANGPAIR}/news/test/
	cp ${NEWS_DEVSET_SRC} ${LANGPAIR}/news/dev/
	cp ${NEWS_DEVSET_TRG} ${LANGPAIR}/news/dev/
	zcat ${NEWS_TRAINSET_SRC} | gzip -c > ${LANGPAIR}/news/train/news.${SRC}.gz
	zcat ${NEWS_TRAINSET_TRG} | gzip -c > ${LANGPAIR}/news/train/news.${TRG}.gz
endif
endif
endif



.PHONY: data
data: ${TRAIN_SRC}.pre.gz ${TRAIN_TRG}.pre.gz ${DEV_SRC}.pre.gz ${DEV_TRG}.pre.gz

.INTERMEDIATE: ${LANGPAIR}/${BASEMODELNAME}/decoder.yml
${LANGPAIR}/${BASEMODELNAME}/decoder.yml:
	mkdir -p ${dir $@}
	cp ${BASEMODELZIP} ${dir $@}
	cd ${dir $@} && unzip -u *.zip

${TRAIN_SRC}.pre.gz ${DEV_SRC}.pre.gz ${TEST_SRC}.pre.gz: %.pre.gz: %.gz ${LANGPAIR}/${BASEMODELNAME}/decoder.yml
	zcat $< |\
	${LANGPAIR}/${BASEMODELNAME}/preprocess.sh ${SRC} ${LANGPAIR}/${BASEMODELNAME}/source.spm |\
	gzip -c > $@

${TRAIN_TRG}.pre.gz ${DEV_TRG}.pre.gz: %.pre.gz: %.gz ${LANGPAIR}/${BASEMODELNAME}/decoder.yml
	zcat $< |\
	${LANGPAIR}/${BASEMODELNAME}/preprocess.sh ${SRC} ${LANGPAIR}/${BASEMODELNAME}/target.spm |\
	gzip -c > $@




.PHONY: tune
tune: ${TUNED_MODEL}.done

## train transformer model
${TUNED_MODEL}.npz.best-perplexity.npz: ${TUNED_MODEL}.done

${TUNED_MODEL}.done: ${TRAIN_SRC}.pre.gz ${TRAIN_TRG}.pre.gz ${DEV_SRC}.pre.gz ${DEV_TRG}.pre.gz \
		${LANGPAIR}/${BASEMODELNAME}/decoder.yml
	mkdir -p ${dir $@}
	if [ ! -e ${@:done=npz} ]; then \
	  cp ${LANGPAIR}/${BASEMODELNAME}/*.npz ${@:done=npz}; \
	  cp ${LANGPAIR}/${BASEMODELNAME}/*.vocab.yml ${TUNED_MODEL_VOCAB}; \
	fi
	${LOADMODS} && ${MARIAN}/marian ${MARIAN_EXTRA} \
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
translate: ${TEST_SRC}.${TRG}.gz

## translate test set
${TEST_SRC}.${TRG}.gz: ${TEST_SRC}.pre.gz ${TUNED_MODEL}.npz.best-perplexity.npz
	mkdir -p ${dir $@}
	${LOADMODS} && ${MARIAN}/marian-decoder -i $< \
		-c ${word 2,$^}.decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > $@



.PHONY: eval
eval: ${TEST_SRC}.${TRG}.eval

${TEST_SRC}.${TRG}.eval: ${TEST_SRC}.${TRG}.gz ${TEST_TRG}.gz
	zcat ${TEST_TRG} > $@.ref
	zcat $< | sacrebleu $@.ref > $@
	zcat $< | sacrebleu --metrics=chrf --width=3 $@.ref >> $@
	rm -f $@.ref



.PHONY: compare
compare: ${TEST_SRC}.${TRG}.compare

${TEST_SRC}.${TRG}.compare: ${TEST_SRC}.${TRG}.eval
	zcat ${TEST_SRC}.gz > $@.1
	zcat ${TEST_TRG}.gz > $@.2
	zcat ${<:.eval=.gz} > $@.3
	paste -d "\n" $@.1 $@.2 $@.3 |\
	sed 	-e "s/&apos;/'/g" \
		-e 's/&quot;/"/g' \
		-e 's/&lt;/</g' \
		-e 's/&gt;/>/g' \
		-e 's/&amp;/&/g' |\
	sed 'n;n;G;' > $@
	rm -f $@.1 $@.2 $@.3
