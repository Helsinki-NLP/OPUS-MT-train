# Train Opus-MT models

This package includes scripts for training NMT models using MarianNMT and OPUS data for [OPUS-MT](https://github.com/Helsinki-NLP/Opus-MT). More details are given in the [Makefile](Makefile) but documentation needs to be improved. Also, the targets require a specific environment and right now only work well on the CSC HPC cluster in Finland.


## Pre-trained models

The subdirectory [models](https://github.com/Helsinki-NLP/Opus-MT-train/tree/master/models) contains information about pre-trained models that can be downloaded from this project. They are distribted with a [CC-BY 4.0 license](https://creativecommons.org/licenses/by/4.0/) license.


## Prerequisites

Running the scripts does not work out of the box because many settings are adjusted for the local installations on our IT infrastructure at [CSC](https://docs.csc.fi/). Here is an incomplete list of prerequisites needed for running a process. It is on our TODO list to make the training procedures and setting more transparent and self-contained but this will take time ...

* [marian-nmt](https://github.com/marian-nmt/): The essential NMT toolkit we use in OPUS-MT; make sure you compile a version with GPU and SentencePiece support!
* [Moses scripts](https://github.com/moses-smt/mosesdecoder): various pre- and post-processing scripts from the Moses SMT toolkit (also bundled here: [marian-nmt](https://github.com/marian-nmt/moses-scripts))
* [OpusTools](https://pypi.org/project/opustools): library and tools for accessing OPUS data
* [OpusTools-perl](https://github.com/Helsinki-NLP/OpusTools-perl): additional tools for accessing OPUS data
* [iso-639](https://pypi.org/project/iso-639/): a Python package for ISO 639 language codes

Optional software:

* [terashuf](https://github.com/alexandres/terashuf): efficiently shuffle massive data sets
* [pigz](https://zlib.net/pigz/): multithreaded gzip



## Structure of the training scripts

Essential files for making new models:

* `Makefile`: top-level makefile
* `lib/env.mk`: system-specific environment (now based on CSC machines)
* `lib/config.mk`: essential model configuration
* `lib/data.mk`: data pre-processing tasks
* `lib/generic.mk`: generic implicit rules that can extend other tasks
* `lib/dist.mk`: make packages for distributing models (CSC ObjectStorage based)
* `lib/slurm.mk`: submit jobs with SLURM

There are also make targets for specific models and tasks. Look into `lib/models/` to see what has been defined already. 
Note that this frequently changes! There is, for example:

* `lib/models/multilingual.mk`: various multilingual models
* `lib/models/celtic.mk`: data and models for Celtic languages
* `lib/models/doclevel.mk`: experimental document-level models


Run this if you want to train a model, for example for translating English to French:

```
make SRCLANGS=en TRGLANGS=fr train
```

To evaluate the model with the automatically generated test data (from the Tatoeba corpus as a default) run:

```
make SRCLANGS=en TRGLANGS=fr eval
```

For multilingual (more than one language on either side) models run, for example:

```
make SRCLANGS="de en" TRGLANGS="fr es pt" train
make SRCLANGS="de en" TRGLANGS="fr es pt" eval
```

Note that data pre-processing should run on CPUs and training/testing on GPUs. To speed up things you can process data sets in parallel using the jobs flag of make, for example using 8 threads:

```
make -j 8 SRCLANG=en TRGLANG=fr data
```




## Upload to Object Storage

This is only for internal use:

```
swift upload OPUS-MT --changed --skip-identical name-of-file
swift post OPUS-MT --read-acl ".r:*"
```

