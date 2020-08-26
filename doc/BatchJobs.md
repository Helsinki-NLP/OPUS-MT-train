# Running batch jobs

The beauty of the whole package is to run batch jobs for training many models in various settings. Some batch jobs are specified with their own targets, some others are specified in dedicated makefiles. Submitting jobs to SLURM is also supported to support job creation on a cluster in a convenient way.


## SLURM jobs

There are two generic implicit rules to submit jobs to SLURM using `sbatch` in [lib/slurm.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/slurm.mk):

* `%.submit`: submit a job to a GPU node
* `%.submitcpu`: submit a job to a CPU node

The suffix can be added to any target to trigger job submission instead of execution on the current shell.
The options are highly specific for the job management system on puhti@CSC and need to be adjusted if used on a different server. For more details look into `lib/env/mk` and `lib/slurm.mk`. The essential job that is submitted is a call to 'make' running the target without the suffix. For example,

```
make SRCLANGS=en TRGLANGS=de all.submit
```

submits a job to the GPU queue for running everything needed to prepare, train and evaluate a model for English-German (basically running `make all` on the allocated note). The variable assignments specified on the command-line magically get transferred to the job call (I still don't really know why - but this is great ...).

There are important variables that modify allocations requested by the job:

* `HPC_NODES`: number of nodes to be allocated (default: 1)
* `HPC_QUEUE`: SLURM CPU queue (default on puhti: small)
* `HPC_GPUQUEUE`: SLURM GPU queue (default: gpu)
* `HPC_DISK`: local disc space allocated in GB (default: 500)
* `HPC_TIME`: allocated walltime in hh::mm (default: 72:00)
* `HPC_CORES`: number of CPU cores (default: 1)
* `HPC_MEM`: allocated RAM (default: 4g)

There are 3 shortcuts/aliases for the lazy people:

* `MEM`: can be used instead of `HPC_MEM`
* `THREADS`: can be used instead of `HPC_CORES`
* `WALLTIME`: can be used instead of `HPC_TIME` but only allows `hh` (like `72`)


GPU-specific parameters include:

* `GPU`: device name (default: v100 on puhti)
* `NR_GPUS`: number of GPUs allocated (default: 1)
* `GPU_MODULES`: software packages to be loaded as module before running the make command


CPU-specific parameters are:

* `CPU_MODULES`: software packages to be loaded as module before running the make command


Extra parameters include:

* `EMAIL`: e-mail notification when the job is done
* `HPC_EXTRA`: can be set to add any additional parameters that need to be added to the slurm startup script
* `CSCPROJECT`: project ID to be billed on puhti




## Recipes that combine tasks


There is various targets that combine tasks, setup common pipelines or create very task-specific jobs. Some more generic targets are defined in the top-level Makefile and in `lib/generic.mk`. Some, possibly interesting ones are:

* `all`: make the entire pipeline from preparing to evaluation
* `train-and-eval`: train a model and evaluate on all test sets


Submitting jobs in combination with other tasks:

* `all-job`: prepare all data and then submit a GPU job to train and eval a model
* `train-job`: submit a GPU for taining a model (will also trigger multi-gpu jobs if specified in model-config)
* `train-and-eval-job`: the same as above but also evaluate all test sets
* `bilingual`: prepare all data, submit a multi-GPU training job, reverse the data and submit another multi-GPU job in reverse direction
* `bilingual-small`: the same as above but single GPU jobs, reduced MarianNMT workspace and faster validation frequencies
* `multilingual`: make data for a multilingual model and start a multi-GPU job to train it (use LANG to specify the languages to be used on both sides)


Some very complex tasks (might not work and be careful before running ... those targets are not well tested)

* `all2pivot`: make data and create jobs for all languages combined with a PIVOT language in both directions; use LANGS to specify the languages to be considered and PIVOT for the pivot language (default=en)
* `train-and-start-bt-jobs`: train a model, evaluate it, create a local distribution package, start back-translation of all wikidata in separate jobs (only for bilingual models)
* `all-and-backtranslate`: similar to above but start back-translation for all language pairs (in case this is a multilingual model), but no separate translation jobs and only wikipedia data
* `all-and-backtranslate-allwikis`: similar to above but back-translate data from all wikis
* `all-and-backtranslate-allwikiparts`: same as above but translate all parts of all wikis


Combining this to make it complete:

* `all-with-bt`: run `all-and-backtranslate` in reverse direction and then run `all-bt` (entire pipeline with back-translated data)
* `all-with-bt-all`: same as above but run `all-and-backtranslate-allwikis` first
* `all-with-bt-allparts` same as above but run `all-and-backtranslate-allwikiparts` first




## Generic rules

Some implicit rules can be used to trigger certain batch jobs. Typically, they can be used by adding a suffix to existing targets, for example:

* `%-all`: run a target over all language pairs in WORKHOME, for example `make eval-all`
* `%-allmodels`: run a target over all models in all sub-dirs in WORKHOME, for example `make eval-allmodels` (so this also includes different types of models for the same language pair)
* `%-allbilingual`: run a target over all bilingual models in WORKHOME, for example `make eval-allbilingual`
* `%-allmultilingual`: run a target over all multilingual models in WORKHOME, for example `make eval-allmultilingual`
* `%-all-parallel`: basically the same as `%-all` but enables parallelization


Generic rules for special model types:

* `%-bt`: include back-translation data, e.g., `make train-bt`
* `%-pivot`: include pivot-based tranlation, e.g., `make train-pivot`
* `%-RL`: right-to-left models, e.g., `make all-RL`
* `%-bpe`: use BPE instead of sentence-piece, e.g. `make all-bpe`