# Back-translation

Translate monolingual data (extracted from various wikimedia sources) to create synthetic training data.


## Overview

Relevant makefiles:

* [Makefile](Makefile)
* [lib/config.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/config.mk)

Main recipes:

* `all`: translate wiki data for the specified language
* `get-data`:
* `extract-text`:
* `extract-doc`:
* `prepare-model`:
* `prepare-data`:
* `translate`:
* `check-length`:
* `print-names`:
* `print-modelname`:


Recipes for fetching data and pre-processing batch jobs:

* `index.html`:
* `all-wikitext`:
* `all-wikilangs`:
* `all-wikilangs-fast`:
* `all-wikis-all-langs`:
* `all-wikidocs-all-langs`:
* `wiki-iso639`: link (shuffled) wikisources to iso639-3 conform language labels
* `wiki-iso639-doc`: same as above but for non-shuffled wikisources with document boundaries


Recipes for translating wiki data:

* `translate-all-parts`:
* `translate-all-wikis`: 
* `translate-all-wikiparts`:
* `translate-all-parts-jobs`:
* `translate-all-wikis-jobs`:
* `translate-all-wikiparts-jobs`:


Recipes for Sami languages:

* `sami-corp`:
* `translate-sami`:
* `translate-sami-corp`:
* `translate-sami-wiki`:
* `translate-sami-xx-wiki`:
* `translate-sami-xx-corp`:
* `translate-xx-sami-wiki`:


Recipes for Celtic languages:

* `fetch-celtic`:
* `translate-celtic-english`:
* `translate-english-celtic`:
* `breton`:


Recipes for Nordic and Uralic languages:

* `finland-focus-wikis`:
* `translate-thl`:
* `all-nordic-wikidocs`:
* `uralic-wiki-texts`:
* `uralic-wikis`:


Other task-specific recipes:

* `xnli-wikidocs`:
* `small-romance`:
* `wikimedia-focus-wikis`:



Parameters / variables:

* `SRC`:
* `TRG`:
* `WIKISOURCE`:
* `SPLIT_SIZE`:
* `MAX_LENGTH`:
* `MAX_SENTENCES`:
* `PART`:
* `MODELSDIR`:
* `MULTI_TARGET_MODEL`:
* `WIKI_HOME`:
* `WIKIDOC_HOME`:



## Detailed information

Use Wiki data:

* json processor: https://stedolan.github.io/jq/
* wiki JSON dumps: https://dumps.wikimedia.org/other/cirrussearch/current/

NOTE: this only works for SentencePiece models


## TODO

*  download base models from ObjectStorage
*  DONE? make it work with multilingual models (need to adjust preprocess-scripts for those models)
