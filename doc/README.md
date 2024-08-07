# OPUS-MT-train documentation

This package includes scripts and makefiles to train NMT models and here is some incomplete documentation.
The build targets are all included in various makefiles and the main idea is to provide a flexible setup for running different jobs for many language pairs and to support all tasks necessary to build and test a model.

The package includes 4 components:

* basic training of bilingual and multilingual models ([Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile))
* [Generating back-translations](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/README.md) for data augmentation ([Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/Makefile))
* [Fine-tuning models](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/finetune/README.md) for domain adaptation ([Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/finetune/Makefile))
* [Generate pivot-language-based translations](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/pivoting/README.md) for data augmentation ([pivoting](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/pivoting/Makefile))

Information about [installation and setup is available here.](https://github.com/Helsinki-NLP/Opus-MT-train/tree/master/doc/Setup.md).

More information about specific tasks:

* [Creating data files](Data.md)
* [Training models](Train.md)
* [Testing models](Test.md)
* [Running batch jobs](BatchJobs.md)
* [Packaging, releases and storage](ReleaseAndStore.md)


Tutorials (to-do)

* [Low-resource translation](tutorials/low-resource.md)
* [Multilingual models](tutorials/multilingual.md)


Documentation of project-specific models:

* [Models for the Tatoeba MT Challenge](TatoebaChallenge.md)
* [Celtic language models](projects/Celtic.md)
* [Romance language models](projects/Romance.md)
* [Russian models](projects/Russian.md)
* [Sami language models](projects/Sami.md)
* [Languages in Finland](projects/Finland.md)
* [Multilingual models](projects/Multilingual.md)
* [Doc-level models](projects/Doclevel.md)
* [Simplification models](projects/Simplify.md)
* [Fiskmö project](projects/fiskmo.md)
* [MeMAD project](projects/memad.md)
* [Wikimedia collaboration model](projects/Wikimedia.md)





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
make [OPTIONS] config
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


Targets for specific models and projects in `lib/projects/`, currently:


* `lib/projects.mk`: high-level makefile that includes enabled projects
* `lib/projects/celtic.mk`: data and models Celtic languages
* `lib/projects/finland.mk`: main languages spoken in Finland
* `lib/projects/fiskmo.mk`: models related to the fiskmö project
* `lib/projects/memad.mk`: models related to the MeMAD project
* `lib/projects/multilingual.mk`: various multilingual models
* `lib/projects/opus.mk`: models covering OPUS languages
* `lib/projects/romance.mk`: Romance languages
* `lib/projects/russian.mk`: data and models for Russian
* `lib/projects/sami.mk`: data and models for Sami languages
* `lib/projects/wikimedia.mk`: models related to WikiMedia collaboration
* `lib/projects/wikimatrix.mk`: models that include WikiMatrix data


Targets related to the Tatoeba MT Challenge:

* `lib/projects/tatoeba.mk`


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



