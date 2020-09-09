# Models for Sami languages

Recipes for training multilingual language models involving Sami languages.


## Overview

Relevant makefiles:

* [Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile)
* [lib/models/sami.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/models/sami.mk)
* [backtranslate/Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/backtranslate/Makefile)


Main recipes:

* `sami-data`: fetch and convert external data sets
* `data-sami`: prepare data for a multilingual model including Sami languages
* `train-sami`: train a multilingual model for Sami languages
* `eval-sami`: evaluate the multilingual model above
* `dist-sami`: create a release package for the multilingual model

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
* `%-pivot`: include pivot-based translations (can be combined with the implicit rules above, e.g. `make train-pivot-sam
i`)


## Detailed information


There are special recipes for working with Sami languages. First of all, we would like to include additional data sets to extend the training data and to have decent amounts of test data for evaluation. Open data sources are availabel from [Giellatekno](https://victorio.uit.no) and they can be downloaded and converted using:

```
make sami-data
```

This assumes that `wget` is available on your system and the [OpusTools-perl](https://github.com/Helsinki-NLP/OpusTools-perl) package is installed (see also [installation and setup](https://github.com/Helsinki-NLP/Opus-MT-train/tree/master/doc/Setup.md)).

If everything works fine you should see non-empty files in `work/data/simple` with the basename `giella` and `glossary`:

```
ls -al work/data/simple/giella*
-rw-r--r-- 1 tiedeman 3.3M Sep  9 12:34 work/data/simple/giella.fi-se.clean.fi.gz
-rw-r--r-- 1 tiedeman 3.2M Sep  9 12:34 work/data/simple/giella.fi-se.clean.se.gz
-rw-r--r-- 1 tiedeman 1.1M Sep  9 12:34 work/data/simple/giella.fi-smn.clean.fi.gz
-rw-r--r-- 1 tiedeman 1.1M Sep  9 12:34 work/data/simple/giella.fi-smn.clean.smn.gz
-rw-r--r-- 1 tiedeman 6.9M Sep  9 12:34 work/data/simple/giella.nb-se.clean.nb.gz
-rw-r--r-- 1 tiedeman 7.2M Sep  9 12:34 work/data/simple/giella.nb-se.clean.se.gz
-rw-r--r-- 1 tiedeman 608K Sep  9 12:34 work/data/simple/giella.nb-sma.clean.nb.gz
-rw-r--r-- 1 tiedeman 633K Sep  9 12:34 work/data/simple/giella.nb-sma.clean.sma.gz
-rw-r--r-- 1 tiedeman 238K Sep  9 12:34 work/data/simple/giella.nb-smj.clean.nb.gz
-rw-r--r-- 1 tiedeman 240K Sep  9 12:34 work/data/simple/giella.nb-smj.clean.smj.gz
-rw-r--r-- 1 tiedeman 644K Sep  9 12:34 work/data/simple/giella.se-sma.clean.se.gz
-rw-r--r-- 1 tiedeman 633K Sep  9 12:34 work/data/simple/giella.se-sma.clean.sma.gz
-rw-r--r-- 1 tiedeman 410K Sep  9 12:34 work/data/simple/giella.se-smn.clean.se.gz
-rw-r--r-- 1 tiedeman 424K Sep  9 12:34 work/data/simple/giella.se-smn.clean.smn.gz

ls -al work/data/simple/glossary*
-rw-r--r-- 1 tiedeman  33K Sep  9 12:34 work/data/simple/glossary.fi-se.clean.fi.gz
-rw-r--r-- 1 tiedeman  37K Sep  9 12:34 work/data/simple/glossary.fi-se.clean.se.gz
-rw-r--r-- 1 tiedeman  75K Sep  9 12:34 work/data/simple/glossary.fi-smn.clean.fi.gz
-rw-r--r-- 1 tiedeman 120K Sep  9 12:34 work/data/simple/glossary.fi-smn.clean.smn.gz
-rw-r--r-- 1 tiedeman 122K Sep  9 12:34 work/data/simple/glossary.fi-sms.clean.fi.gz
-rw-r--r-- 1 tiedeman 171K Sep  9 12:34 work/data/simple/glossary.fi-sms.clean.sms.gz
-rw-r--r-- 1 tiedeman 150K Sep  9 12:34 work/data/simple/glossary.nb-se.clean.nb.gz
-rw-r--r-- 1 tiedeman 282K Sep  9 12:34 work/data/simple/glossary.nb-se.clean.se.gz
-rw-r--r-- 1 tiedeman  65K Sep  9 12:34 work/data/simple/glossary.nb-sma.clean.nb.gz
-rw-r--r-- 1 tiedeman  82K Sep  9 12:34 work/data/simple/glossary.nb-sma.clean.sma.gz
-rw-r--r-- 1 tiedeman  43K Sep  9 12:34 work/data/simple/glossary.nb-smj.clean.nb.gz
-rw-r--r-- 1 tiedeman  52K Sep  9 12:34 work/data/simple/glossary.nb-smj.clean.smj.gz
-rw-r--r-- 1 tiedeman  21K Sep  9 12:34 work/data/simple/glossary.se-sma.clean.se.gz
-rw-r--r-- 1 tiedeman  23K Sep  9 12:34 work/data/simple/glossary.se-sma.clean.sma.gz
-rw-r--r-- 1 tiedeman  38K Sep  9 12:34 work/data/simple/glossary.se-smj.clean.se.gz
-rw-r--r-- 1 tiedeman  38K Sep  9 12:34 work/data/simple/glossary.se-smj.clean.smj.gz
-rw-r--r-- 1 tiedeman  23K Sep  9 12:34 work/data/simple/glossary.se-smn.clean.se.gz
-rw-r--r-- 1 tiedeman  23K Sep  9 12:34 work/data/simple/glossary.se-smn.clean.smn.gz
```


### Training bilingual models

The first step is to prepare data using the additional data sets from above. In this example, we use Northern-Sami to Finnish as the example and take data from the Giellatekno resources as validation and test set and add `glossary` as extra training data.

```
make SRCLANGS=se TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary BPESIZE=4000 config
make SRCLANGS=se TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary data
```

Note that we reduce the vocabulary size to 4,000 per language to accomodate the low-reource scenario and change the name of the data set to mark the extra data that we use (this will also be used in the model name). Note also that The `giella` data set will be the main data set we can use and that a large portion will be used as training data even though we specify the data set as validation and test data. This is because of the automatic extraction of distinct dev/test sets that makes it possible to add all remaining data points to the training data.

Training and evaluating this model works in the same way as for other models but keep the extra parameters:

```
make SRCLANGS=se TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary train
make SRCLANGS=se TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary eval
```


### Training multilingual models

Multilingual models can be done by adding languages, for example including 5 Sami languages as a source:

```
make SRCLANGS="se sma smj smn sms" TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary BPESIZE=4000 config
make SRCLANGS="se sma smj smn sms" TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary data
make SRCLANGS="se sma smj smn sms" TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary train
make SRCLANGS="se sma smj smn sms" TRGLANGS=fi DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary eval
```

Any set of languages can be used as source or target language. The system automatically uses all combinations of languages to train the model. This can have undesired effects when some high-resource languages can dominate the setup. For example, training a multilingual model for Northern Sami, Finnish, and Norwegian (nynorsk and bokmål) may exclude the translations between Finnish and Norwegian using the `SKIP_LANGPAIRS` parameter:

```
make SRCLANGS="se fi nb nn" TRGLANGS="se fi nb nn" DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary BPESIZE=4000 config
make SRCLANGS="se fi nb nn" TRGLANGS="se fi nb nn" SKIP_LANGPAIRS="fi-nb|fi-nn" DATASET=opus+giella DEVSET=giella TESTSET=giella EXTRA_TRAINSET=glossary data
...
```

There are pre-defined implict rules that define certain setups of multilingual models that include Sami languages:

* `%-sami`: recipes for symmetric multilingual models that cover `se sma smj smn sms vep et fi kv krl nb no nn ru sv en` but exclude all combinations of high-resource/non-Finno-Ugric languages (`nb no nn ru sv en`)
* `%-sami-xx`: recipes for models that translate from Sami languages (`se sma smj smn sms`) to Nordic languages, English and Russian (`nb no nn ru sv en`)
* `%-xx-sami`: recipes for models in the opposite direction


So, one can simply run to create models to translate from Sami languages to the given high-resource languages:

```
make config-sami-xx
make data-sami-xx
make train-sami-xx
make eval-sami-xx
```


### Back-translation

The first step is to fetch some monolingual data for Sami languages:

```
make -C backtranslate SRC=se fetch-wiki
make -C backtranslate sami-corp
```

The second recipe may fail. Try again and check the data in `backtranslate/wiki/se` and `backtranslate/giellatekno`.




## Notes

## To-do list

