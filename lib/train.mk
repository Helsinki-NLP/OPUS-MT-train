# -*-makefile-*-




## resume training on an existing model
resume:
	if [ -e ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.npz.best-perplexity.npz ]; then \
	  cp ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.npz.best-perplexity.npz \
	     ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.npz; \
	fi
	sleep 1
	rm -f ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} train


#------------------------------------------------------------------------
# training MarianNMT models
#------------------------------------------------------------------------


## make vocabulary
## - no new vocabulary is created if the file already exists!
## - need to delete the file if you want to create a new one!

${MODEL_VOCAB}:	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
		${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz
ifeq ($(wildcard ${MODEL_VOCAB}),)
	mkdir -p ${dir $@}
	${LOADMODS} && zcat $^ | ${MARIAN}/marian-vocab --max-size ${VOCABSIZE} > $@
else
	@echo "$@ already exists!"
	@echo "WARNING! No new vocabulary is created even though the data has changed!"
	@echo "WARNING! Delete the file if you want to start from scratch!"
	touch $@
endif


## NEW: take away dependency on ${MODEL_VOCAB}
## (will be created by marian if it does not exist)

## train transformer model
${WORKDIR}/${MODEL}.transformer.model${NR}.done: \
		${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
		${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz \
		${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
	mkdir -p ${dir $@}
	${LOADMODS} && ${MARIAN}/marian ${MARIAN_EXTRA} \
        --model $(@:.done=.npz) \
	--type transformer \
        --train-sets ${word 1,$^} ${word 2,$^} ${MARIAN_TRAIN_WEIGHTS} \
        --max-length 500 \
        --vocabs ${MODEL_VOCAB} ${MODEL_VOCAB} \
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
        --beam-size 12 --normalize 1 --allow-unk \
        --log $(@:.model${NR}.done=.train${NR}.log) \
	--valid-log $(@:.model${NR}.done=.valid${NR}.log) \
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







## NEW: take away dependency on ${MODEL_VOCAB}

## train transformer model with guided alignment
${WORKDIR}/${MODEL}.transformer-align.model${NR}.done: \
		${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
		${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz \
		${TRAIN_ALG} \
		${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
	mkdir -p ${dir $@}
	${LOADMODS} && ${MARIAN}/marian ${MARIAN_EXTRA} \
        --model $(@:.done=.npz) \
	--type transformer \
        --train-sets ${word 1,$^} ${word 2,$^} ${MARIAN_TRAIN_WEIGHTS} \
        --max-length 500 \
        --vocabs ${MODEL_VOCAB} ${MODEL_VOCAB} \
        --mini-batch-fit \
	-w ${MARIAN_WORKSPACE} \
	--maxi-batch ${MARIAN_MAXI_BATCH} \
        --early-stopping ${MARIAN_EARLY_STOPPING} \
        --valid-freq ${MARIAN_VALID_FREQ} \
	--save-freq ${MARIAN_SAVE_FREQ} \
	--disp-freq ${MARIAN_DISP_FREQ} \
        --valid-sets ${word 4,$^} ${word 5,$^} \
        --valid-metrics perplexity \
        --valid-mini-batch ${MARIAN_VALID_MINI_BATCH} \
        --beam-size 12 --normalize 1 --allow-unk \
        --log $(@:.model${NR}.done=.train${NR}.log) \
	--valid-log $(@:.model${NR}.done=.valid${NR}.log) \
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
        --exponential-smoothing \
	--guided-alignment ${word 3,$^}
	touch $@



