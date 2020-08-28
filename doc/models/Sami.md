# Models for Sami languages

Recipes for training multilingual language models involving Sami languages.


## Overview

Relevant makefiles:

* [Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile)
* [lib/models/sami.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/models/sami.mk)
* [backtranslate/Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/Makefile)


Main recipes:

* `sami-data`: fetch and convert external data sets and prepare the train/dev/test splits
* `sami-train`: train a multilingual model for Sami languages
* `sami-eval`: evaluate the multilingual model above
* `sami-dist`: create a release package for the multilingual model

See also implict rules for additional common recipes.

Recipes for back-translation (go to sub-directory `backtranslate`):

* `sami-corp`: download monolingual Sami corpora from Giellatekno
* `translate-sami-corp`: translate monolingual Sami corpora with a multilingual model (hardcoded in [backtranslate/Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/Makefile))
* `translate-sami-wiki`: translate Northern Sami wiki data to all kinds of languages using a multilingual model (hardcoded in [backtranslate/Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/Makefile)) and translate wiki data for a selected number of languages (currently: no, nn ru, sv, en) to Sami languages using the same multilingual model
* `translate-sami`: do both of the things above (`translate-sami-corp` and `translate-sami-wiki`)
* `translate-sami-xx-wiki`: translate wiki data from Northern Sami to other Sami languages, Finnish, Norwegian, and Swedish using a "sami-xx" model
* `translate-xx-sami-wiki`: translate wiki data from Finnish, Norwegian, and Swedish to Sami languages using a "xx-sami" model
* `translate-sami-xx-corp`: translate monolingual corpora from Giellatekno from Sami languages to Finnish, Norwegian, and Swedish using a "sami-xx" model


Recipes for pivot-based translation (go to sub-directory `pivoting`), set `SRC` (e.g. fi), `TRG` (e.g. se) and `PIVOT` (e.g. nb)

* `all`: fetch model, prepare data sets and translate
* `prepare`: prepare the data sets (pivot bitexts))
* `translate`: translate the pivot bitexts



Data-related recipes:

* `fetch-sami-tmx`: fetch translation memories from Giellatekno
* `convert-sami-tmx`: convert the TMX files from above
* `merge-sami-data`: merge the converted TMX files into one bitext
* `convert-sami-gloss`: convert bilingual glossaries from Giellatekno


Parameters / variables:

* `GIELLATEKNO_HOME`: URL for Giellatekno resources (default: https://victorio.uit.no/biggies/trunk)
* `GIELLATEKNO_TM_HOME`: directory of translation memories (default: ${GIELLATEKNO_HOME}/mt/omegat)
* `GIELLATEKNO_SAMI_TM`: list of translation memories to be downloaded (see [lib/models/sami.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/models/sami.mk))


Implicit rules:

* `%-sami`: run recipe for a multilingual model including Sami languages (e.g. `make train-sami`)
* `%-sami-xx`: run recipe for a model that translates Sami languages to selected other languages
* `%-xx-sami`: run recipe for a model that translates selected languages to Sami languages
* `%-bt`: include back-translated data (can be combined with the implicit rules above, e.g. `make train-bt-sami`)
* `%-pivot`: include pivot-based translations (can be combined with the implicit rules above, e.g. `make train-pivot-sami`)



## Notes

## To-do list

