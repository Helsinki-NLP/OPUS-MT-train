# Translating and evaluating


## Overview

Relevant makefiles:

* [Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile)
* [lib/config.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/config.mk)
* [lib/test.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/test.mk)

Main recipes:

* `translate`: tanslate test set
* `eval`: evaluate translated test set
* `compare`: merge input, output, reference
* `eval-testsets`: translate and evaluate all test sets
* `eval-ensemble`: evaluate model ensemble
* `eval-RL`: evaluate right-to-left model
* `eval-allmodels`: evaluate all models in WORKHOME

Parameters / variables:

* `SRCLANGS`: list of source language codes
* `TRGLANGS`: list of target language codes
* `MODELTYPE`: transformer or transformer-align (with guided alignment) (default: transformer-align)



## Detailed information

Basic targets for translating and evaluating the test set can be done by running:

```
make [OPTIONS] translate
make [OPTIONS] eval
make [OPTIONS] compare
```

Set the options to correspond to your model, so at least `SRCLANGS` and `TRGLANGS`.
It is not necessary to call `make translate` separately as `make eval` requires the translated data. `make compare` generates a file that merges input, output and reference translation for comparison.

The translations and evaluation scores will be stored in the work directory of the current model (`work/${LANGPAIRSTR}`) with the name of the test set and the name of the model.

* translations: `${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}`
* scores: `${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.eval`
* comparison: `${WORKDIR}/${TESTSET_NAME}.${MODEL}${NR}.${MODELTYPE}.${SRC}.${TRG}.compare`


## Translate additional test sets

There is a collection of addiitonal test sets in `testsets/`. It is possible to run through all test sets of language pairs that are supported by the current model by calling:

```
make [OPTIONS] eval-testsets
```

All tanslations and evaluation scores will be stored with the test set names in the work directory of the model.
