# -*-makefile-*-
#
# create efficient models
# inspired by browsermt
#
# - binary lexical shortlists
# - several variants of quantization
# - finetuned quantization
# - test translations with various quantized models



.PHONY: lexical-shortlist
lexical-shortlist: ${MODEL_BIN_SHORTLIST}

${MODEL_BIN_SHORTLIST}: ${TRAIN_S2T} ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
	${BROWSERMT_CONVERT} \
		--shortlist $< ${SHORTLIST_NRVOC} ${SHORTLIST_NRTRANS} 0 \
		--vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		--dump $@


.PHONY: quantize quantize-alphas quantize-tuned quantize-tuned-alphas intgemm8tuned
quantize: ${MODEL_BIN}
quantize-alphas: ${MODEL_BIN_ALPHAS}
quantize-tuned: ${MODEL_BIN_TUNED}
quantize-tuned-alphas: ${MODEL_BIN_TUNED_ALPHAS}

intgemm8tuned: ${MODEL_INTGEMM8TUNED}


# ${MODEL_BIN}: ${MODEL_FINAL}
%.intgemm8.bin: %.npz.best-perplexity.npz
	mkdir -p ${dir $@}
	${BROWSERMT_CONVERT} -g intgemm8 -f $< -t $@

%.intgemm8.alphas.bin: %.alphas.npz
	${BROWSERMT_CONVERT} --gemm-type intgemm8 -f $< -t $@

%.alphas.npz: %.quantmults %.npz.best-perplexity.npz
	${BROWSERMT_HOME}/marian-dev/scripts/alphas/extract_stats.py $^ $@

## NOTE: need to run this on CPU and with one core only!
%.quantmults: %.npz.best-perplexity.npz
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--skip-cost --cpu-threads 1 \
		--quiet --quiet-translation \
		-m $< --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i ${DEV_SRC}.${PRE_SRC} -o ${DEV_SRC}.${PRE_SRC}.${TRG} \
		--dump-quantmult --log $@.log 2> $@


## additional finetuning for intgemm8

%.intgemm8tuned.bin: %.intgemm8tuned.npz
	mkdir -p ${dir $@}
	${BROWSERMT_CONVERT} -g intgemm8 -f $< -t $@

%.intgemm8tuned.alphas.bin: %.finetune-alphas.npz
	${BROWSERMT_CONVERT} --gemm-type intgemm8 -f $< -t $@

%.finetune-alphas.npz: %.fine-quantmults %.intgemm8tuned.npz
	${BROWSERMT_HOME}/marian-dev/scripts/alphas/extract_stats.py $^ $@

## NOTE: need to run this on CPU and with one core only!
%.finetune-quantmults: %.intgemm8tuned.npz
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--skip-cost --cpu-threads 1 \
		--quiet --quiet-translation \
		-m $< --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i ${DEV_SRC}.${PRE_SRC} -o ${DEV_SRC}.${PRE_SRC}.${TRG} \
		--dump-quantmult --log $@.log 2> $@

%.intgemm8tuned.npz: %.npz.best-perplexity.npz
	cp $< $@
	${LOAD_ENV} && ${BROWSERMT_TRAIN} \
		${MARIAN_TRAINING_PARAMETER} \
		${MARIAN_EXTRA} \
		${MARIAN_DATA_STORAGE} \
		--model $@ \
		--devices ${MARIAN_GPUS} -w 8000 --cost-type ce-mean-words \
		--valid-freq 200 --save-freq 200 --disp-freq 100 --disp-first 10 \
		--valid-metrics ce-mean-words \
		--valid-sets ${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG} \
		--valid-translation-output ${DEV_SRC}.${PRE_SRC}.${TRG} \
		--early-stopping 20 --overwrite --keep-best --quantize-bits 8 \
		--train-sets 	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
				${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz \
				${MARIAN_TRAIN_WEIGHTS} \
		--vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		--log $(@:.npz=.train${NR}.log) \
		--valid-log $(@:.npz=.valid${NR}.log) \
		--tempdir ${TMPDIR} \
		--shuffle ${MARIAN_SHUFFLE}

# 		--optimizer-delay 4
#		--mini-batch-fit  --mini-batch 1000 --maxi-batch 1000 --sync-sgd 
#		--learn-rate 0.0003 --lr-report --lr-warmup 16000 --lr-decay-inv-sqrt 32000 \
#		--optimizer-params 0.9 0.98 1e-09 --clip-norm 0 \
#		--valid-metrics ce-mean-words \
#		--quiet-translation --valid-mini-batch 16 --beam-size 1 --normalize 1 \




## test quanitized student models
## need to run this on CPU!!
.PHONY: test-intgemm8 test-intgemm8 test-intgemm8alpha test-intgemm8-shortlist test-intgemm8alpha-shortlist

test-intgemm8-all: test-intgemm8 test-intgemm8shift test-intgemm8alpha 
test-intgemm8-all-shortlist: test-intgemm8-shortlist test-intgemm8shift-shortlist test-intgemm8alpha-shortlist
test-intgemm8-alltuned: test-intgemm8tuned test-intgemm8tunedshift test-intgemm8tunedalpha 
test-intgemm8-alltuned-shortlist: test-intgemm8tuned-shortlist test-intgemm8tunedshift-shortlist test-intgemm8tunedalpha-shortlist


test-intgemm8: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8.${SRC}.${TRG}.eval
test-intgemm8shift: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shift.${SRC}.${TRG}.eval
test-intgemm8alpha: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shiftAlphas.${SRC}.${TRG}.eval
test-intgemm8-shortlist: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8.shortlist.${SRC}.${TRG}.eval
test-intgemm8shift-shortlist: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shift.shortlist.${SRC}.${TRG}.eval
test-intgemm8alpha-shortlist: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shiftAlphas.shortlist.${SRC}.${TRG}.eval
test-intgemm8tuned: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tuned.${SRC}.${TRG}.eval
test-intgemm8tunedshift: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshift.${SRC}.${TRG}.eval
test-intgemm8tunedalpha: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshiftAlphas.${SRC}.${TRG}.eval
test-intgemm8tuned-shortlist: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tuned.shortlist.${SRC}.${TRG}.eval
test-intgemm8tunedshift-shortlist: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshift.shortlist.${SRC}.${TRG}.eval
test-intgemm8tunedalpha-shortlist: ${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshiftAlphas.shortlist.${SRC}.${TRG}.eval


${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8 --skip-cost --cpu-threads ${HPC_CORES} \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shift.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shift --skip-cost --cpu-threads ${HPC_CORES} \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shiftAlphas.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_ALPHAS}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shiftAlpha --skip-cost --cpu-threads ${HPC_CORES} \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_ALPHAS} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@



## with shortlists

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8.shortlist.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN} ${MODEL_BIN_SHORTLIST}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8 --skip-cost --cpu-threads ${HPC_CORES} \
		--shortlist ${MODEL_BIN_SHORTLIST} false \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shift.shortlist.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN} ${MODEL_BIN_SHORTLIST}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shift --skip-cost --cpu-threads ${HPC_CORES} \
		--shortlist ${MODEL_BIN_SHORTLIST} false \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8shiftAlphas.shortlist.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_ALPHAS} ${MODEL_BIN_SHORTLIST}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shiftAlpha --skip-cost --cpu-threads ${HPC_CORES} \
		--shortlist ${MODEL_BIN_SHORTLIST} false \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_ALPHAS} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@




## finetuned quantization

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tuned.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_TUNED}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8 --skip-cost --cpu-threads ${HPC_CORES} \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_TUNED} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshift.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_TUNED}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shift --skip-cost --cpu-threads ${HPC_CORES} \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_TUNED} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshiftAlphas.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_TUNED_ALPHAS}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shiftAlpha --skip-cost --cpu-threads ${HPC_CORES} \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_TUNED_ALPHAS} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@



## with shortlists

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tuned.shortlist.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_TUNED} ${MODEL_BIN_SHORTLIST}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8 --skip-cost --cpu-threads ${HPC_CORES} \
		--shortlist ${MODEL_BIN_SHORTLIST} false \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_TUNED} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshift.shortlist.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_TUNED} ${MODEL_BIN_SHORTLIST}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shift --skip-cost --cpu-threads ${HPC_CORES} \
		--shortlist ${MODEL_BIN_SHORTLIST} false \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_TUNED} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@

${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.intgemm8tunedshiftAlphas.shortlist.${SRC}.${TRG}: ${TEST_SRC}.${PRE_SRC} ${MODEL_BIN_TUNED_ALPHAS} ${MODEL_BIN_SHORTLIST}
	${BROWSERMT_DECODE} \
		--beam-size 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
		--int8shiftAlpha --skip-cost --cpu-threads ${HPC_CORES} \
		--shortlist ${MODEL_BIN_SHORTLIST} false \
		--quiet --quiet-translation --log $@.log \
		-m ${MODEL_BIN_TUNED_ALPHAS} --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		-i $< | \
	sed 's/ //g;s/▁/ /g;s/^ *//;s/ *$$//' > $@


