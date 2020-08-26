# Training models


Training a model can be started by simply running:

```
make SRCLANGS=xx TRGLANGS=yy train
```

This should be done on a machine with GPU or submitted to a GPU node via SLURM.
The default configuration and parameters for training Marian-NMT models are specifed in `lib/train.mk` and `lib/config/mk`.

```
	--type transformer \
        --max-length 500 \
        --mini-batch-fit \
	-w ${MARIAN_WORKSPACE} \
	--maxi-batch ${MARIAN_MAXI_BATCH} \
        --early-stopping ${MARIAN_EARLY_STOPPING} \
        --valid-freq ${MARIAN_VALID_FREQ} \
	--save-freq ${MARIAN_SAVE_FREQ} \
	--disp-freq ${MARIAN_DISP_FREQ} \
        --valid-metrics perplexity \
        --valid-mini-batch ${MARIAN_VALID_MINI_BATCH} \
        --beam-size 12 --normalize 1 --allow-unk \
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
	--guided-alignment ${TRAIN_ALG}
```

* guided alignment is only used with `MODELTYPE=transformer-align`.
* `MARIAN_WORKSPACE` is set depending on the GPU that is used (13000 for p100, 24000 for v100 and 10000 otherwise)
* if no GPU is found (tested using `nvidia-smi`) then the `--cpu-threads` flag is added automatically
* other default parameters are set like this:

```
MARIAN_GPUS             = 0
MARIAN_EXTRA            = 
MARIAN_VALID_FREQ       = 10000
MARIAN_SAVE_FREQ        = ${MARIAN_VALID_FREQ}
MARIAN_DISP_FREQ        = ${MARIAN_VALID_FREQ}
MARIAN_EARLY_STOPPING   = 10
MARIAN_VALID_MINI_BATCH = 16
MARIAN_MAXI_BATCH       = 500
MARIAN_DROPOUT          = 0.1
MARIAN_MAX_LENGTH	= 500
```


## Multi-GPU training

Multi-GPU training can be enabled by adding a suffix to the make target:

* `-multigpu` or `-gpu0123`: train on 4 GPUs (devices 0,1,2,3)
* `-twogpu` or `-gpu01`: train on 2 GPUs (devices 0,1)
* `-gpu23`: train on 2 GPUs (devices 2,3)

So, for example:

```
make SRCLANGS=xx TRGLANGS=yy train-multigpu
```


## Running on a cluster

Add the suffix `.submit` and set appropriate variables for job requirements, for example, 
starting a single-gpu job with walltime of 48 hours:


```
make SRCLANGS=xx TRGLANGS=yy WALLTIME=48 train.submit
```

This can be combined with the multi-gpu suffix:

```
make SRCLANGS=xx TRGLANGS=yy WALLTIME=48 train.submit-multigpu
```

More details on job management in [Slurm.md](Slurm.md)
