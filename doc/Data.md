# Creating data files


## Overview

Relevant makefiles:

* [Makefile](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/Makefile)
* [lib/config.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/config.mk)
* [lib/data.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/data.mk)
* [lib/preprocess.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/preprocess.mk)
* [lib/sentencepiece.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/sentencepiece.mk)
* [lib/bpe.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/bpe.mk)


Main recipes:

* `data`: create all data, subword models, optional word alignment, vocabulary
* `devdata`: create validation data set
* `testdata`: create test data set
* `traindata`: create train data set
* `reverse-data`: create data in reverse translation direction (bilingual models only)
* `wordalign`: make word alignments
* `spm-models`: train source and target language sentence-piece models
* `bpe-models`: train source and target language BPE models


Parameters / variables:

* `SRCLANGS`: list of source language codes
* `TRGLANGS`: list of target language codes
* `DEVSET`: corpus name for validation data (default: Tatoeba/GlobalVoices/infopankki/JW300/bible-uedin)
* `TESTSET`: corpus name for validation data (default: DEVSET)
* `TRAINSET`: list of corpora for training data (default: all except DEVSET, TESTSET, EXCLUDE_CORPORA (WMT-News, ...)
* `USE_REST_DEVDATA`: if set to 1 then unused DEVSET data is added to train (default: 1)
* `DEVSIZE`: number of sentence pairs in validation data (default: 5000/2500)
* `TESTSIZE`: number of sentence pairs in test data (default: 5000/2500)
* `DEVSMALLSIZE`: reduced size of validation data for small data sets (default: 10000)
* `TESTSMALLSIZE`: reduced size of test data for small data sets (default: 10000)
* `DEVMINSIZE`: minimum number of sentence pairs in validation data (default: 150)
* `BPESIZE`: subword segmentation model size (default: 32000)
* `SRCBPESIZE`: source language subword segmentation model size (default: BPESIZE)
* `TRGBPESIZE`: target language subword segmentation model size (default: BPESIZE)


Implicit rules:

* `%-bt`: include back-translations
* `%-pivot`: include pivot-based translations




## Detailed information

* data sets are defined in `lib/config.mk`
* data sets are created using recipes from `lib/data.mk` and `lib/preprocess.mk`
* subword models are trained and applied with recipes from `lib/sentencepiece.mk` and `bpe.mk`


The main target for creating data sets (train, validation, test sets) for a model translating from languages `xx` to languags `yy` is

```
make SRCLANGS="xx" TRGLANGS="yy" data
```

This command will in the standard setup

* fetch all available data from OPUS
* apply generic pre-processing and language-specific filtering if available
* create splits into train, val, test sets
* train sentence-piece models (separate for source and target language)
* segment data sets using those sentence-piece models
* applies some additional bitext cleaning (using Moses scripts)
* word-align all training data (used for guided alignment)
* create a vocabulary file for Marian-NMT


## Fetching and basic pre-processing

OPUS-MT finds available data in the OPUS collection (this requires a local copy of the data right now!) and merges all of them to create taining data. Test and validation data will be taken from one of the OPUS corpora and that data will be excluded from the training data. The settings of data sets can be found in `lib/config/mk`

* `DEVSET` - name of the corpus used for extracting validation data used during training
* `TESTSET` - name of the corpus used for extracting test data (default = same as DEVSET)
* `TRAINSET` - list of corpus names used for training

The variables can be set to override defaults. See below to understand how the defaults are determined.
Data sets, vocabulary, alignments and segmentation models will be stored in the work directory of the model (`work/LANGPAIRSTR/`). Here is an example for the language pair br-en:

```
# MarianNMT vocabulary file:
work/br-en/opus.spm4k-spm4k.vocab.yml

# test data:
work/br-en/test/README.md
work/br-en/test/Tatoeba.src
work/br-en/test/Tatoeba.src.spm4k
work/br-en/test/Tatoeba.trg

# validation data:
work/br-en/val/README.md
work/br-en/val/Tatoeba.src
work/br-en/val/Tatoeba.src.shuffled.gz
work/br-en/val/Tatoeba.src.spm4k
work/br-en/val/Tatoeba.trg
work/br-en/val/Tatoeba.trg.spm4k

# training data:
work/br-en/train/README.md
work/br-en/train/opus.src.clean.spm4k.gz
work/br-en/train/opus.trg.clean.spm4k.gz

# Sentence-piece models
work/br-en/train/opus.src.spm4k-model
work/br-en/train/opus.src.spm4k-model.vocab
work/br-en/train/opus.trg.spm4k-model
work/br-en/train/opus.trg.spm4k-model.vocab

# Word alignment
work/br-en/train/opus.spm4k-spm4k.src-trg.alg.gz
```


### Validation and test data

Validation data:

* the DEVSET has fallback options depending on availability (tested in this order Tatoeba, GlobalVoices, infopankki, JW300, bible-uedin)
* the DEVSET needs to contain at least 2 x DEVMINSIZE aligned sentence pairs (default 2x 150 = 300)
* the default size of a validation set is 5,000 sentence pairs for Tatoeba data and 2,500 sentence pairs for other corpora; The size can be adjusted by setting DEVSIZE
* the DEVSET corpus is shuffled and the development data is taken from the top of the shuffled data set (see `lib/data.mk`)


Test data:

* by default, test data is taken from the same corpus as validation data (override by setting TESTSET)
* the default size for the test set is the same as for the validation data (or as much as there is left after taking away the validation data)
* if there is not enough data for both, validation and test data then the size of both sets will be reduced to DEVSMALLSIZE and TESTSMALLSIZE (default for both is 1,000 sentence pairs)
* if there is less than DEVSMALLSIZE data available in that set then no test data will be created


Data from the DEVSET corpus that are not used for validation or testing will be added to the training data by default! This can be switched off by setting the variable `USE_REST_DEVDATA` to 0.


### Training data

Training data will be taken by default from all available OPUS corpora except for a number of pre-defined corpora that are always excluded (see `EXCLUDE_CORPORA` in `lib/data.mk`):

* WMT-News (this includes common test sets we don't want to train on)
* MPC1 (a non-public corpus)
* ELRA corpora (unclear status about their overlap and use in MT)

Furthermore, DEVSET and TESTSET corpora are excluded as well. Only remaining data from the DEVSET after removing validation and test data is added to the training data if `USE_REST_DEVDATA` is set to 1 (default). Information about the training data will be added to the README.md in `work/LANGPAIRSTR/train/`.

Currently, the makefile looks at the local copy of released OPUS data to find available data sets (see `OPUSCORPORA` in `lib/data.mk`).



## Customizing the setup


Most settings can be adjusted by setting corresponding variables to new values. Common changes are:

* don't run word-alignment: set `MODELTYPE=transformer`
* change the vocabulary size: set `BPESIZE=<yourvalue>` for example BPESIZE=4000 (this is also used for sentence-piece models)
* vocabulary sizes can also be set for source and target language independently (`SRCBPESIZE` and `TRGBPESIZE`)
* use BPE instead of sentence-piece (not recommended): set `SUBWORDS=bpe`
* don't use remaining DEVSET data in training: set `USE_REST_DEVDATA=0`
* change the size of test or validation data: set `DEVSIZE` and `TESTSIZE`
* specify a specific list of corpora to train on: set `TRAINSET="<space-separated-corpus-names>"`
* specify a specific test set: set `TESTSET=<corpusname>` (the same aplies for DEVSET)
* use all OPUS corpora but exclude some additional corpora from the list: modify `EXCLUDE_CORPORA`
* use a different name than the generated one based on language pairs: set `LANGPAIRSTR`



## Multilingual models


The same targets can be used transparently for creating data sets for multilingual models. `SRCLANGS` and `TRGLANGS` can include any number of valid language IDs (separated by space). The `data` target will extract ALL combinations of language pairs from those sets. To exclude certain combinations, you can set `SKIP_LANGPAIRS` with a pattern of language pairs to be excluded (separated by `|`). For example, `SKIP_LANGPAIRS="en-de|en-fr"` excludes English-German and English-French from the data.

If there are multiple target languages then language label tokens will automatically be added to all relevant data sets. They are added to the front of the source sentence and look like this `>>LANGID<<`. Development and test data also include data from all language pairs if available in the DEVSET/TESTSET corpus.



## Data sampling

It is possible to sample data instead using all that is available. This is done PER LANGUAGE PAIR and not per corpus!
This is especially useful for multilingual models where data size can very substantially between the various translation directions that are supported. The script support over and under-sampling and the procedure is controlled by those variables:

* `FIT_DATA_SIZE`: desired size per language pair (in number of aligned sentences)
* `MAX_OVER_SAMPLING`: maximum number of repeating the same data in over-sampling (default = 50)
* `SHUFFLE_DATA`: set to 1 to shuffle data per language pair to have better representation of each corpus involved

The `MAX_OVER_SAMPLING` variable is useful to avoid overe-representing tiny data sets and their potential noise.



## Add extra data

Extra data sets can be added by moving them to the directory of pre-processed bitexts (`work/data/simple`). They need to be aligned with two separate files representing source and target language (Moses format) and they need to be compressed with gzip (file extension `.gz`). You need to follow the naming convention: 

* `<CORPUSNAME>.<SRCID>-<TRGID>.clean.<SRCID>.gz` - source language file
* `<CORPUSNAME>.<SRCID>-<TRGID>.clean.<TRGID>.gz` - target language file

Replace CORPUSNAME with the name of resource, SRCID and TRGID with the language codes of your data. You can add any number of extra training sets in this way by listing their names (CORPUSNAME) in the variable `EXTRA_TRAINSET` (space separated). I don't need to mention that you should avoid spaces in any file name ....!



## Reverse translation direction

It can be useful to re-use data sets for the reverse translation direction. This is only useful for bilingual models (multilingual ones add language labels). We also don't support forward translated data. In order to create symbolic links and reverse word alignment to support translation from language yy to language xx do:

```
make SRCLANGS=xx TRGLANGS=yy reverse-data
```



## Include back-translated data


The directory for back-translation is by default in `backtranslate/${TRG}-${SRC}/latest` or `backtranslate/${TRG}-${SRC}`. You can move back-translated data there yourself or produce them using the back-translation procedured of OPUS-MT.

Back-translation is done for individual language pairs. Multilingual models are not supported. Therefore, set SRC and TRG if this needs to be specified. SRC defaults to the first language code in SRCLANGS and TRG to the last code in TRGLANGS.

All data file pairs with the extension `${SRC}.gz` and `${TRG}.gz` will be used. If this is not desired then it is also possible to override BACKTRANS_SRC with an explicit (space-separated) list of source language files. BACKTRANS_TRG can also be set but defaults to the same as BACKTRANS_SRC with the source language code replaced by the target language code. You need to specify the full path to those files!

The easiest way to enable the use of back-translated data is to start any target with the suffix `-bt`. For creating data sets:

```
make SRCLANGS=xx TRGLANGS=yy data-bt
```

This will 

* add the extension `+bt` to the name of the model
* enable the use of back-translated data found
* copy the final model trained without back-translation as the starting point if it exists
* copy the vocabulary file from the model without back-translation if it exists
