# OPUS-MT-train documentation

This package includes scripts and makefiles to train NMT models and here is some incomplete documentation.
The build targets are all included in various makefiles and the main idea is to provide a flexible setup for running different jobs for many language pairs and to support all tasks necessary to build and test a model.

The package includes 4 components:

* [basic training](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile) of bilingual and multilingual models
* [back-translation](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/Makefile) for data augmentation
* [fine-tuning](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/finetune/Makefile) for domain adaptation
* [pivoting](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/pivoting/Makefile) for data augmentation


More information about specific tasks:

* [Creating data files](Data.md)
* [Training models](Train.md)
* [Testing models](Test.md)
* [Running batch jobs](BatchJobs.md)
* [Generating back-translations](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/README.md)
* [Fine-tuning models](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/finetune/README.md)
* [Generate pivot-language-based translations](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/pivoting/README.md)
* [Models for the Tatoeba MT Challenge](TatoebaChallenge.md)

Tutorials (to-do)

* [Low-resource translation](tutorials/low-resource.md)
* [Multilingual models](tutorials/multilingual.md)



## Main structure of build scripts


The make targets and essential system properties are defined in a number of makefiles that are included from top-level Makefiles.

* `Makefile`: top-level makefile for main tasks
* `backtranslate/Makefile`: top-level makefile for generating back-translations
* `finetune/Makefile`: top-level makefile for fine-tuning
* `pivoting/Makefile`: top-level makefile for pivot-based translations


Configurations and definitions about the system environment are stored in

* `lib/env.mk`: system-specific environment (now based on CSC machines)
* `lib/config.mk`: essential model configuration
* `lib/langsets.mk`: definition of language sets
* `${WORKDIR}/config.mk`: model-specific configuration (only if it exists)

The model specific configuration can store properties that otherwise need to be given on the command-line when calling make targets. You can generate the configuration file using

```
make [OPTIONS] local-config
```


Essential targets for training and testing NMT models are provided in

* `lib/data.mk`: data pre-processing tasks
* `lib/train.mk`: training models
* `lib/test.mk`: translating with existing models and evaluating test sets
* `lib/test.mk`: translating with existing models and evaluating test sets


Targets for job management, packaging and other project related tasks:

* `lib/slurm.mk`: submit jobs with SLURM
* `lib/dist.mk`: make packages for distributing models (CSC ObjectStorage based)
* `lib/generic.mk`: generic implicit rules that can extend other tasks
* `lib/misc.mk`: miscellaneuous tasks


Targets for specific models and projects in `lib/models/`, currently:


* `lib/models/celtic.mk`: data and models Celtic languages
* `lib/models/finland.mk`: main languages spoken in Finland
* `lib/models/fiskmo.mk`: models related to the fiskmö project
* `lib/models/memad.mk`: models related to the MeMAD project
* `lib/models/multilingual.mk`: various multilingual models
* `lib/models/opus.mk`: models covering OPUS languages
* `lib/models/romance.mk`: Romance languages
* `lib/models/russian.mk`: data and models for Russian
* `lib/models/sami.mk`: data and models for Sami languages
* `lib/models/wikimedia.mk`: models related to WikiMedia collaboration
* `lib/models/wikimatrix.mk`: models that include WikiMatrix data


Targets related to the Tatoeba MT Challenge:

* `lib/models/tatoeba.mk`


Scripts for various tasks in `scripts/`:

* `scripts/filter`: filtering data (currently language identification only)
* `scripts/cleanup`: language-specific cleanup scripts (should not remove lines to keep alignment)



## Data structure

* original source data is expected in `${OPUSHOME}` (see `lib/env.mk`)
* pre-processed data will be stored in `work/data/simple` (current default setting, can be adjusted with WORKHOME and settings for PRE)
* model-specific data is stored in `work/LANGPAIRSTR`
* model-specific training data: `work/LANGPAIRSTR/train`
* model-specific validation data: `work/LANGPAIRSTR/val`
* model-specific test data: `work/LANGPAIRSTR/test`
* additional test sets are stored in `testsets/` sorted by language pair
* released models are stored in `models/LANGPAIRSTR`


`LANGPAIRSTR` is generated from the specifed source languages and target languages. Source and target language IDs are merged using `+` as a delimiter and those merged strings are merged using `-`. For example, `fi+et-en` is a the model directory for a multilingual models that includes Finnish and Estonian as source languages and English as target language.



