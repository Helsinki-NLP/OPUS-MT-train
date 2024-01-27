# -*-makefile-*-


#------------------------------------------------------------------------
# vocabulary files:
#   - for SentencePiece models: take vocabulary from the spm-model
#   - otherwise: create vocab from training data
#   - always re-use existing vocabulary files (never overwrite!)
#   - copy an existing vocab file if MODEL_LATEST_VOCAB exists
#     (this is for continuing training with other pre-trained models)
#------------------------------------------------------------------------

## extract vocabulary from sentence piece model

${WORKDIR}/${MODEL}.src.vocab: ${SUBWORD_SRC_MODEL}
	cut -f1 < $<.vocab > $@
ifeq (${USE_TARGET_LABELS},1)
	echo "${TARGET_LABELS}" | tr ' ' "\n" >> $@
endif

${WORKDIR}/${MODEL}.trg.vocab: ${SUBWORD_TRG_MODEL}
	cut -f1 < $<.vocab > $@


ifneq ($(findstring spm,${SUBWORDS}),)

## make vocabulary from the source and target language specific
## sentence piece models (concatenate and yamlify)

${WORKDIR}/${MODEL}.vocab.yml: ${WORKDIR}/${MODEL}.src.vocab ${WORKDIR}/${MODEL}.trg.vocab
ifeq ($(wildcard $@),)
ifneq ($(wildcard ${MODEL_LATEST_VOCAB}),)
ifneq (${MODEL_LATEST_VOCAB},$@)
	cp ${MODEL_LATEST_VOCAB} $@
endif
else
	cat $^ | sort -u | ${REPOHOME}scripts/vocab2yaml.py > $@
endif
else
	@echo "$@ already exists! We will re-use it ..."
	touch $@
endif

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
	${LOAD_ENV} && ${ZCAT} $^ | ${MARIAN_VOCAB} --max-size ${VOCABSIZE} > $@
endif
else
	@echo "$@ already exists!"
	@echo "WARNING! No new vocabulary is created even though the data has changed!"
	@echo "WARNING! Delete the file if you want to start from scratch!"
	touch $@
endif
endif


#------------------------------------------------------------------------
# training MarianNMT models
#   - different kind of model types require different settings
#   - add word alignment to pre-requisites if necessary
#   - continue training from MODEL_LATEST (if it exists)
#   - initialise model with parameters from PRE_TRAINED_MODEL (if set)
#------------------------------------------------------------------------


## print the model that will be used to initalise training
## this needs to be compatible in architecture!

print-model-names:
	@echo "initial parameters from: ${PRE_TRAINED_MODEL}"
	@echo "       start with model: ${MODEL_LATEST}"
	@echo "         write model to: ${MODEL_START}"

print-marian-path:
	@echo ${MARIAN}


MARIAN_OPTIMIZER_PARAMS ?= 0.9 0.98 1e-09
MARIAN_LEARNING_RATE ?= 0.0003


## possible model variants
MARIAN_MODELS_DONE   = 	${patsubst %,${WORKDIR}/${MODEL}.%.model${NR}.done,${MODELTYPES}}

MARIAN_TRAIN_PREREQS = 	${TRAIN_SRC}.clean.${PRE_SRC}${TRAINSIZE}.gz \
			${TRAIN_TRG}.clean.${PRE_TRG}${TRAINSIZE}.gz \
			$(sort ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB})


## define validation and early-stopping parameters
## as well as pre-requisites for training the model
## TODO: do we want to add valid-metrics "ce-mean-words" and "bleu-detok"?

ifndef SKIP_VALIDATION
  MARIAN_TRAIN_PREREQS += ${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG}
  MARIAN_STOP_CRITERIA = --early-stopping ${MARIAN_EARLY_STOPPING} \
        --valid-freq ${MARIAN_VALID_FREQ} \
        --valid-sets ${DEV_SRC}.${PRE_SRC} ${DEV_TRG}.${PRE_TRG} \
        --valid-metrics perplexity \
        --valid-mini-batch ${MARIAN_VALID_MINI_BATCH} \
	--valid-max-length 100 \
	--valid-log ${WORKDIR}/${MODEL}.${MODELTYPE}.valid${NR}.log \
        --beam-size 6 --normalize 1 --allow-unk
  MODEL_FINAL = ${WORKDIR}/${MODEL_BASENAME}.npz.best-perplexity.npz
else
  MODEL_FINAL = ${WORKDIR}/${MODEL_BASENAME}.npz
endif


## tie all embeddings if we have a common vocab
## for target and source language
## otherwise: only tie target embeddings
## TODO: if we use pre-defined tasks than tied-embeddings-all is set to true
##       How can we unset it if it should not be used?

MARIAN_TIE_EMBEDDINGS = --tied-embeddings-all

ifeq ($(USE_SPM_VOCAB),1)
ifneq (${USE_JOINT_SUBWORD_MODEL},1)
  MARIAN_TIE_EMBEDDINGS = --tied-embeddings
endif
endif


# start weights with a pre-trained model

ifneq (${wildcard ${PRE_TRAINED_MODEL}},)
  MARIAN_EXTRA += --pretrained-model ${PRE_TRAINED_MODEL}
endif


##------------------------------------------------
## transformer models (not using pre-defined tasks)
##
## dependencies and extra parameters
## for different models and guided alignment
##------------------------------------------------


## if substring '-align' is part of the MODELTYPE:
## add parameters and dependencies for guided alignment
ifneq ($(subst -align,,${MODELTYPE}),${MODELTYPE})
  MARIAN_TRAIN_PREREQS += ${TRAIN_ALG}
  MARIAN_EXTRA += --guided-alignment ${TRAIN_ALG}
endif


ifeq ($(subst -align,,${MODELTYPE}),transformer-tiny)
  MARIAN_ENC_DEPTH = 3
  MARIAN_DEC_DEPTH = 2
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 256
  MARIAN_EXTRA += --transformer-decoder-autoreg rnn \
		--dec-cell ssru # --fp16
endif

## difference to student model in bergamot (tiny11):
# --transformer-dim-ffn 1536 --enc-depth 6 --transformer-ffn-activation relu
# 32000 vocab in total (tied source and target)
#    --mini-batch-fit -w 9000 --mini-batch 1000 --maxi-batch 1000 --devices $GPUS --sync-sgd --optimizer-delay 2 \
#    --learn-rate 0.0003 --lr-report --lr-warmup 16000 --lr-decay-inv-sqrt 32000 \
#    --cost-type ce-mean-words \
#    --optimizer-params 0.9 0.98 1e-09 --clip-norm 0

ifeq ($(subst -align,,${MODELTYPE}),transformer-tiny11)
  MARIAN_ENC_DEPTH = 6
  MARIAN_DEC_DEPTH = 2
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 256
  MARIAN_CLIP_NORM = 0
  MARIAN_EXTRA += --transformer-decoder-autoreg rnn \
		--dec-cell ssru --optimizer-delay 2 \
		 --transformer-dim-ffn 1536
# --dim-vocabs ${SUBWORD_SRCVOCAB_SIZE} ${SUBWORD_TRGVOCAB_SIZE}
# --fp16
endif


ifeq ($(subst -align,,${MODELTYPE}),transformer-small)
  MARIAN_ENC_DEPTH = 6
  MARIAN_DEC_DEPTH = 2
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 512
  MARIAN_EXTRA += --transformer-decoder-autoreg rnn --dec-cell ssru
  # --fp16
endif



##------------------------------------------------
## transformer-base
## transformer-big
##
## look at task aliases:
## https://github.com/marian-nmt/marian-dev/blob/master/src/common/aliases.cpp
##------------------------------------------------

ifeq ($(subst -align,,${MODELTYPE}),transformer-base)
  MARIAN_TRAINING_PARAMETER = --task transformer-base # --fp16
endif

ifeq ($(subst -align,,${MODELTYPE}),transformer-big)
  MARIAN_TRAINING_PARAMETER = --task transformer-big \
				--optimizer-delay 2 # --fp16
  GPUJOB_HPC_MEM = 64g
endif


ifeq ($(subst -align,,${MODELTYPE}),transformer-24x12)
  MARIAN_ENC_DEPTH = 24
  MARIAN_DEC_DEPTH = 12
  MARIAN_ATT_HEADS = 8
  MARIAN_DIM_EMB = 1024
  MARIAN_OPTIMIZER_PARAMS = 0.92 0.998 1e-09
  MARIAN_LEARNING_RATE = 0.0001
  MARIAN_EXTRA += --optimizer-delay 10 --lr-warmup-cycle --fp16
  MARIAN_VALID_FREQ = 2000
  MARIAN_SAVE_FREQ = 2000
  MARIAN_DISP_FREQ = 2000
  GPUJOB_HPC_MEM = 64g
endif


ifeq ($(subst -align,,${MODELTYPE}),transformer-24x12b)
  MARIAN_ENC_DEPTH = 24
  MARIAN_DEC_DEPTH = 12
  MARIAN_ATT_HEADS = 16
  MARIAN_DIM_EMB = 1024
  MARIAN_OPTIMIZER_PARAMS = 0.92 0.998 1e-09
  MARIAN_LEARNING_RATE = 0.0001
  MARIAN_EXTRA += --transformer-dim-ffn 4096 --transformer-dim-aan 4096 --optimizer-delay 10 --lr-warmup-cycle --fp16
  MARIAN_VALID_FREQ = 2000
  MARIAN_SAVE_FREQ = 2000
  MARIAN_DISP_FREQ = 2000
  GPUJOB_HPC_MEM = 64g
endif

ifeq ($(subst -align,,${MODELTYPE}),transformer-24x24)
  MARIAN_ENC_DEPTH = 24
  MARIAN_DEC_DEPTH = 24
  MARIAN_ATT_HEADS = 16
  MARIAN_DIM_EMB = 1024
  MARIAN_OPTIMIZER_PARAMS = 0.95 0.998 1e-09
  MARIAN_LEARNING_RATE = 0.00005
  MARIAN_EXTRA += --transformer-dim-ffn 8192 --transformer-dim-aan 4096 --optimizer-delay 20 --lr-warmup-cycle --fp16
#  MARIAN_OPTIMIZER_PARAMS = 0.92 0.998 1e-09
#  MARIAN_LEARNING_RATE = 0.0001
#  MARIAN_EXTRA += --transformer-dim-ffn 8192 --transformer-dim-aan 4096 --optimizer-delay 10 --lr-warmup-cycle --fp16
  MARIAN_VALID_FREQ = 2000
  MARIAN_SAVE_FREQ = 2000
  MARIAN_DISP_FREQ = 2000
  GPUJOB_HPC_MEM = 64g
endif


ifeq ($(subst -align,,${MODELTYPE}),transformer-12x12)
  MARIAN_ENC_DEPTH = 12
  MARIAN_DEC_DEPTH = 12
  MARIAN_ATT_HEADS = 16
  MARIAN_DIM_EMB = 1024
  MARIAN_OPTIMIZER_PARAMS = 0.92 0.998 1e-09
  MARIAN_LEARNING_RATE = 0.0001
  MARIAN_EXTRA += --transformer-dim-ffn 4096 --optimizer-delay 10 --lr-warmup-cycle --fp16
  MARIAN_VALID_FREQ = 5000
  MARIAN_SAVE_FREQ = 2000
  MARIAN_DISP_FREQ = 5000
  GPUJOB_HPC_MEM = 64g
endif


ifeq ($(subst -align,,${MODELTYPE}),transformer-12x6)
  MARIAN_ENC_DEPTH = 12
  MARIAN_DEC_DEPTH = 6
  MARIAN_ATT_HEADS = 16
  MARIAN_DIM_EMB = 1024
  MARIAN_OPTIMIZER_PARAMS = 0.92 0.998 1e-09
  MARIAN_LEARNING_RATE = 0.0001
  MARIAN_EXTRA += --transformer-dim-ffn 4096 --optimizer-delay 10 --lr-warmup-cycle --fp16
  MARIAN_VALID_FREQ = 5000
  MARIAN_SAVE_FREQ = 2000
  MARIAN_DISP_FREQ = 5000
  GPUJOB_HPC_MEM = 64g
endif

ifeq ($(subst -align,,${MODELTYPE}),transformer-6x12)
  MARIAN_ENC_DEPTH = 6
  MARIAN_DEC_DEPTH = 12
  MARIAN_ATT_HEADS = 16
  MARIAN_DIM_EMB = 1024
  MARIAN_OPTIMIZER_PARAMS = 0.92 0.998 1e-09
  MARIAN_LEARNING_RATE = 0.0001
  MARIAN_EXTRA += --transformer-dim-ffn 4096 --optimizer-delay 10 --lr-warmup-cycle --fp16
  MARIAN_VALID_FREQ = 5000
  MARIAN_SAVE_FREQ = 2000
  MARIAN_DISP_FREQ = 5000
  GPUJOB_HPC_MEM = 64g
endif




##------------------------------------------------
## set training parameters
## (unless they are already set above)
##------------------------------------------------

MARIAN_TRAINING_PARAMETER ?= \
	--type transformer \
        --max-length ${MARIAN_MAX_LENGTH} \
	--maxi-batch ${MARIAN_MAXI_BATCH} \
        --mini-batch-fit \
	--max-length-factor 3 \
        --enc-depth ${MARIAN_ENC_DEPTH} \
	--dec-depth ${MARIAN_DEC_DEPTH} \
	--dim-emb ${MARIAN_DIM_EMB} \
        ${MARIAN_TIE_EMBEDDINGS} \
        --transformer-heads ${MARIAN_ATT_HEADS} \
        --transformer-dropout ${MARIAN_DROPOUT} \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
	--label-smoothing 0.1 \
        --learn-rate ${MARIAN_LEARNING_RATE} \
	--lr-warmup 16000 \
	--lr-decay-inv-sqrt 16000 \
	--lr-report \
        --optimizer-params ${MARIAN_OPTIMIZER_PARAMS} \
	--clip-norm ${MARIAN_CLIP_NORM} \
        --sync-sgd \
        --exponential-smoothing

## TODO: --fp16 seems to have changed from previous versions:
## --> cannot continue training with newer version
# old: --precision float16 float32 float32 --cost-scaling 7 2000 2 0.05 10 1
# new: --precision float16 float32 --cost-scaling 0 1000 2 0.05 10 1e-5f
#
## --> leave it out for the time being?
## --> or: only add it of we don't continue training with existing models?
##     (it seems that it can take the info from the internal config info)




##------------------------------------------------
## finally: recipe for training the model
##------------------------------------------------

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
## remove yaml-file for parameters to avoid incompatibilities
## TODO: do we need this
	rm -f ${@:.done=.yml}
##--------------------------------------------------------------------
## TODO: LOAD_ENV - do we need to do that each time we call marian?
##       shouldn't that be rather the standard environdment that we
##       load anyway before calling make? It is already set in the
##       SLURM scripts ...
##--------------------------------------------------------------------
	${LOAD_ENV} && ${MONITOR} ${MARIAN_TRAIN} \
		${MARIAN_TRAINING_PARAMETER} \
		${MARIAN_EXTRA} \
		${MARIAN_STOP_CRITERIA} \
		${MARIAN_DATA_STORAGE} \
		--workspace ${MARIAN_WORKSPACE} \
		--model $(@:.done=.npz) \
		--train-sets ${word 1,$^} ${word 2,$^} ${MARIAN_TRAIN_WEIGHTS} \
		--vocabs ${MODEL_SRCVOCAB} ${MODEL_TRGVOCAB} \
		--save-freq ${MARIAN_SAVE_FREQ} \
		--disp-freq ${MARIAN_DISP_FREQ} \
		--log $(@:.model${NR}.done=.train${NR}.log) \
		--devices ${MARIAN_GPUS} \
		--seed ${SEED} \
		--tempdir ${TMPDIR} \
		--shuffle ${MARIAN_SHUFFLE} \
		--sharding ${MARIAN_SHARDING} \
		--overwrite --disp-first 10 --disp-label-counts \
		--keep-best 2>>$(@:.done=.log) 1>&2
	touch $@





# extract lexical links
# --> required for shortlists
# NOTE: requires that extract_lex is installed
# NOTE: requires word alignment (TRAIN_ALG)

.PHONY: lex-s2t lex-t2s 
lex-s2t: ${TRAIN_S2T}
lex-t2s: ${TRAIN_T2S}

${TRAIN_S2T}: ${TRAIN_ALG} ${TRAINDATA_SRC} ${TRAINDATA_TRG}
	mkdir -p ${LOCAL_TRAIN}.algtmp
	${GZCAT} $< > ${LOCAL_TRAIN}.algtmp/corpus.aln
	${GZCAT} ${word 2,$^} > ${LOCAL_TRAIN}.algtmp/corpus.src
	${GZCAT} ${word 3,$^} > ${LOCAL_TRAIN}.algtmp/corpus.trg
	${EXTRACT_LEX} 	${LOCAL_TRAIN}.algtmp/corpus.trg \
			${LOCAL_TRAIN}.algtmp/corpus.src \
			${LOCAL_TRAIN}.algtmp/corpus.aln \
			${LOCAL_TRAIN}.algtmp/lex.s2t \
			${LOCAL_TRAIN}.algtmp/lex.t2s
	${GZIP} -c ${LOCAL_TRAIN}.algtmp/lex.s2t > ${TRAIN_S2T}
	${GZIP} -c ${LOCAL_TRAIN}.algtmp/lex.t2s > ${TRAIN_T2S}
	rm -f 	${LOCAL_TRAIN}.algtmp/lex.s2t ${LOCAL_TRAIN}.algtmp/lex.t2s \
		${LOCAL_TRAIN}.algtmp/corpus.src ${LOCAL_TRAIN}.algtmp/corpus.trg \
		${LOCAL_TRAIN}.algtmp/corpus.aln
	rmdir ${LOCAL_TRAIN}.algtmp

${TRAIN_T2S}: ${TRAIN_S2T}
	echo "done!"

