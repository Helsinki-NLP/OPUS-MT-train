# Release packages and storage

This file provides information about cxreating releases and how store work files and released packages. This is mainly for internal use by the OPUS-MT project and is specific to the infrastructure at CSC.

## Overview

Relevant makefiles:

* [Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile)
* [lib/env.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/env.mk)
* [lib/config.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/config.mk)
* [lib/dist.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/dist.mk)


Main recipes:

* `dist`: create a distribution package for the specified NMT model (default location: `WORKHOME/models`)
* `release`: create a release package (in `models/`)
* `best-dist`: scans the work directory of the selected language pair and create a release package from the model with the highest BLEU score
* `upload`: upload released models to CSC ObjectStore (allas); requires setup and login to `project_2000661` via `allas-conf`
* `upload-models`: upload work models (packages from `WORKHOME/models`) to development container on CSC ObjectStore
* `store`: store the `WORKDIR` on CSC ObjectStore (for internal use)
* `store-data`: store data in `WORKHOME/data` (raw bitexts) on CSC ObjectStore (for internal use)
* `fetch`: fetch work files stored on CSC ObjectStore for specified language pair; does not overwrite (for internal use)
* `fetch-data`: fetch `WORKHOME/data` from CSC ObjectStore; does not overwrite (for internal use)


Parameters / variables:

* `SRCLANGS`: list of source language codes
* `TRGLANGS`: list of target language codes
* `WORKHOME`: top-level work directory
* `MIN_BLEU_SCORE`: BLEU score threshold for release packages (default: 20)
* `MODEL_CONTAINER`: name of ObjectStore container (default: OPUS-MT-models)
* `DEV_MODEL_CONTAINER`: name of ObjectStore container (default: OPUS-MT-dev)
* `WORK_SRCDIR`: top-level work home directory to fetch models from (for `store`), default: `WORKHOME`
* `WORK_DESTDIR`: top-level work home directory to store models from (for `fetcg`), default: `WORKHOME`

