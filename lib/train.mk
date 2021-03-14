# -*-makefile-*-


#------------------------------------------------------------------------
# vocabulary
#------------------------------------------------------------------------


ifeq (${SUBWORDS},spm)

## make vocabulary from the source and target language specific
## sentence piece models (concatenate and yamlify)

${MODEL_VOCAB}: ${SPMSRCMODEL} ${SPMTRGMODEL}
	cut -f1 < ${word 1,$^}.vocab > ${@:.vocab.yml=.src.vocab}
	cut -f1 < ${word 2,$^}.vocab > ${@:.vocab.yml=.trg.vocab}
ifeq (${USE_TARGET_LABELS},1)
	echo "${TARGET_LABELS}" | tr ' ' "\n" >> ${@:.vocab.yml=.src.vocab}
endif
	cat ${@:.vocab.yml=.src.vocab} ${@:.vocab.yml=.trg.vocab} | \
	sort -u | nl -v 0 | sed 's/^ *//'> $@.numbered
	cut -f1 $@.numbered > $@.ids
	cut -f2 $@.numbered | sed 's/\\/\\\\/g;s/\"/\\\"/g;s/^\(.*\)$$/"\1"/;s/$$/:/'> $@.tokens
	paste -d ' ' $@.tokens $@.ids > $@
	rm -f $@.tokens $@.ids $@.numbered

else

## fallback: make vocabulary from the training data
## - no new vocabulary is created if the file already exists!
## - need to delete the file if you want to create a new one!

${MODEL_VOCAB}:	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
		${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz
ifeq ($(wildcard ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}),)
ifneq (${MODEL_LATEST_VOCAB},)
	cp ${MODEL_LATEST_VOCAB} ${MODEL_VOCAB}
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



## if USE_SPM_VOCAB is set:
## get separate source and target language vocabularies
## from the two individual sentence piece models

ifeq ($(USE_SPM_VOCAB),1)
${MODEL_SRCVOCAB}: ${SPMSRCMODEL}
	cut -f1 < $<.vocab > $@
ifeq (${USE_TARGET_LABELS},1)
	echo "${TARGET_LABELS}" | tr ' ' "\n" >> $@
endif

${MODEL_TRGVOCAB}: ${SPMTRGMODEL}
	cut -f1  < $<.vocab > $@
endif




print-latest:
ifneq (${wildcard ${MODEL_LATEST}},)
ifeq (${wildcard ${MODEL_START}},)
	@echo "cp ${MODEL_LATEST} ${MODEL_START}"
endif
endif



#------------------------------------------------------------------------
# training MarianNMT models
#------------------------------------------------------------------------


## possible model variants
MARIAN_MODELS_DONE = 	${WORKDIR}/${MODEL}.transformer.model${NR}.done \
			${WORKDIR}/${MODEL}.transformer-align.model${NR}.done

MARIAN_TRAIN_PREREQS = 	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
			${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz


## define validation and early-stopping parameters
## as well as pre-requisites for training the model
##
## NEW: take away dependency on ${MODEL_VOCAB}
## (will be created by marian if it does not exist)
## TODO: should we create the dependency again?

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



## dependencies and extra parameters
## for models with guided alignment

ifeq (${MODELTYPE},transformer-align)
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --guided-alignment ${TRAIN_ALG}
endif



## finally: recipe for training transformer model

${MARIAN_MODELS_DONE}: ${MARIAN_TRAIN_PREREQS}
	mkdir -p ${dir $@}
##--------------------------------------------------------------------
## in case we want to continue training from the latest existing model
## (check lib/config.mk to see how the latest model is found)
##--------------------------------------------------------------------
ifeq (${wildcard ${MODEL_START}},)
ifneq (${MODEL_LATEST},)
ifneq (${MODEL_LATEST_VOCAB},)
	cp ${MODEL_LATEST_VOCAB} ${MODEL_VOCAB}
	cp ${MODEL_LATEST} ${MODEL_START}
endif
endif
endif
##--------------------------------------------------------------------
	${MAKE} ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB}
	${LOADMODS} && ${MARIAN_TRAIN} ${MARIAN_EXTRA} \
	${MARIAN_STOP_CRITERIA} \
        --model $(@:.done=.npz) \
	--type transformer \
        --train-sets ${word 1,$^} ${word 2,$^} ${MARIAN_TRAIN_WEIGHTS} \
        --max-length 500 \
        --vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
        --mini-batch-fit \
	-w ${MARIAN_WORKSPACE} \
	--maxi-batch ${MARIAN_MAXI_BATCH} \
	--save-freq ${MARIAN_SAVE_FREQ} \
	--disp-freq ${MARIAN_DISP_FREQ} \
        --log $(@:.model${NR}.done=.train${NR}.log) \
        --enc-depth 6 --dec-depth 6 \
        --transformer-heads 8 \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
        --transformer-dropout ${MARIAN_DROPOUT} \
	--label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        ${MARIAN_TIE_EMBEDDINGS} \
	--devices ${MARIAN_GPUS} \
        --sync-sgd --seed ${SEED} \
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
