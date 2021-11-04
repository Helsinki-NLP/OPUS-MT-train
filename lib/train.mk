# -*-makefile-*-


#------------------------------------------------------------------------
# vocabulary
#------------------------------------------------------------------------



## extract vocabulary from sentence piece model

${WORKDIR}/${MODEL}.src.vocab: ${SPMSRCMODEL}
	cut -f1 < $<.vocab > $@
ifeq (${USE_TARGET_LABELS},1)
	echo "${TARGET_LABELS}" | tr ' ' "\n" >> $@
endif

${WORKDIR}/${MODEL}.trg.vocab: ${SPMTRGMODEL}
	cut -f1 < $<.vocab > $@


ifeq (${SUBWORDS},spm)

## make vocabulary from the source and target language specific
## sentence piece models (concatenate and yamlify)

${WORKDIR}/${MODEL}.vocab.yml: ${WORKDIR}/${MODEL}.src.vocab ${WORKDIR}/${MODEL}.trg.vocab
	cat $^ | sort -u | scripts/vocab2yaml.py > $@

else

## fallback: make vocabulary from the training data
## - no new vocabulary is created if the file already exists!
## - need to delete the file if you want to create a new one!

${WORKDIR}/${MODEL}.vocab.yml:	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
				${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz
ifeq ($(wildcard $@),)
ifneq ($(wildcard ${MODEL_LATEST_VOCAB}),)
ifneq (${MODEL_LATEST_VOCAB},$@)
	cp ${MODEL_LATEST_VOCAB} $@
endif
else
	mkdir -p ${dir $@}
	${LOADMODS} && ${ZCAT} $^ | ${MARIAN_VOCAB} --max-size ${VOCABSIZE} > $@
endif
else
	@echo "$@ already exists!"
	@echo "WARNING! No new vocabulary is created even though the data has changed!"
	@echo "WARNING! Delete the file if you want to start from scratch!"
	touch $@
endif
endif


print-latest:
	@echo "latest model: ${MODEL_LATEST}"
	@echo "start model:  ${MODEL_START}"



#------------------------------------------------------------------------
# training MarianNMT models
#------------------------------------------------------------------------


## possible model variants
MARIAN_MODELS_DONE   = 	${patsubst %,${WORKDIR}/${MODEL}.%.model${NR}.done,${MODELTYPES}}

MARIAN_TRAIN_PREREQS = 	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
			${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz \
			$(sort ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB})


## define validation and early-stopping parameters
## as well as pre-requisites for training the model

ifndef SKIP_VALIDATION
  MARIAN_TRAIN_PREREQS += ${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
  MARIAN_STOP_CRITERIA = --early-stopping ${MARIAN_EARLY_STOPPING} \
        --valid-freq ${MARIAN_VALID_FREQ} \
        --valid-sets ${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG} \
        --valid-metrics perplexity \
        --valid-mini-batch ${MARIAN_VALID_MINI_BATCH} \
	--valid-log ${WORKDIR}/${MODEL}.${MODELTYPE}.valid${NR}.log \
        --beam-size 12 --normalize 1 --allow-unk \
	--overwrite --keep-best
  MODEL_FINAL = ${WORKDIR}/${MODEL_BASENAME}.npz.best-perplexity.npz
else
  MODEL_FINAL = ${WORKDIR}/${MODEL_BASENAME}.npz
endif


## tie all embeddings if we have a common vocab
## for target and source language
## otherwise: only tie target embeddings

ifeq ($(USE_SPM_VOCAB),1)
  MARIAN_TIE_EMBEDDINGS = --tied-embeddings
else
  MARIAN_TIE_EMBEDDINGS = --tied-embeddings-all
endif


# start weights with a pre-trained model

ifneq (${wildcard ${PRE_TRAINED_MODEL}},)
  MARIAN_EXTRA += --pretrained-model ${PRE_TRAINED_MODEL}
endif


## dependencies and extra parameters
## for different models and guided alignment

ifeq (${MODELTYPE},transformer-align)
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --guided-alignment ${TRAIN_ALG}
endif

ifeq (${MODELTYPE},transformer-small-align)
  MARIAN_ENC_DEPTH = 6
  MARIAN_DEC_DEPTH = 2
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 512
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --guided-alignment ${TRAIN_ALG} --transformer-decoder-autoreg rnn --dec-cell ssru
endif

ifeq (${MODELTYPE},transformer-tiny-align)
  MARIAN_ENC_DEPTH = 3
  MARIAN_DEC_DEPTH = 2
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 256
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --guided-alignment ${TRAIN_ALG} --transformer-decoder-autoreg rnn --dec-cell ssru
endif

ifeq (${MODELTYPE},transformer-tiny)
  MARIAN_ENC_DEPTH = 3
  MARIAN_DEC_DEPTH = 2
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 256
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --transformer-decoder-autoreg rnn --dec-cell ssru
endif

ifeq (${MODELTYPE},transformer-big-align)
  MARIAN_ENC_DEPTH = 12
  MARIAN_ATT_HEADS = 16
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --guided-alignment ${TRAIN_ALG}
  GPUJOB_HPC_MEM = 16g
endif

ifeq (${MODELTYPE},transformer-big)
  MARIAN_ENC_DEPTH = 12
  MARIAN_ATT_HEADS = 16
  GPUJOB_HPC_MEM = 16g
endif

#  MARIAN_DIM_EMB = 1024


## finally: recipe for training transformer model

${MARIAN_MODELS_DONE}: ${MARIAN_TRAIN_PREREQS}
	mkdir -p ${dir $@}
##--------------------------------------------------------------------
## in case we want to continue training from the latest existing model
## (check lib/config.mk to see how the latest model is found)
##--------------------------------------------------------------------
ifeq (${wildcard ${MODEL_START}},)
ifneq (${wildcard ${MODEL_LATEST}},)
ifneq (${MODEL_LATEST},${MODEL_START})
	cp ${MODEL_LATEST} ${MODEL_START}
endif
endif
endif
##--------------------------------------------------------------------
	${LOADMODS} && ${MARIAN_TRAIN} ${MARIAN_EXTRA} \
	${MARIAN_STOP_CRITERIA} \
        --model $(@:.done=.npz) \
        --train-sets ${word 1,$^} ${word 2,$^} ${MARIAN_TRAIN_WEIGHTS} \
        --max-length ${MARIAN_MAX_LENGTH} \
        --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
        --mini-batch-fit \
	-w ${MARIAN_WORKSPACE} \
	--maxi-batch ${MARIAN_MAXI_BATCH} \
	--save-freq ${MARIAN_SAVE_FREQ} \
	--disp-freq ${MARIAN_DISP_FREQ} \
        --log $(@:.model${NR}.done=.train${NR}.log) \
	--type transformer \
        --enc-depth ${MARIAN_ENC_DEPTH} \
	--dec-depth ${MARIAN_DEC_DEPTH} \
	--dim-emb ${MARIAN_DIM_EMB} \
        --transformer-heads ${MARIAN_ATT_HEADS} \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
        --transformer-dropout ${MARIAN_DROPOUT} \
	--label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 --fp16 \
        ${MARIAN_TIE_EMBEDDINGS} \
	--devices ${MARIAN_GPUS} \
        --sync-sgd \
	--seed ${SEED} \
	--sqlite \
	--tempdir ${TMPDIR} \
        --exponential-smoothing
	touch $@









## TODO: do we need the following recipes?

## resume training on an existing model
resume:
	if [ -e ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.npz.best-perplexity.npz ]; then \
	  cp ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.npz.best-perplexity.npz \
	     ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.npz; \
	fi
	sleep 1
	rm -f ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done
	${MAKE} train

is-done:
	@if [ -e ${WORKDIR}/${MODEL}.${MODELTYPE}.model${NR}.done ]; then \
	  echo "............. ${LANGPAIRSTR}/${MODEL}.${MODELTYPE}.model${NR}.done"; \
	fi
