
# Model fine-tuning

Scripts for fine-tuning transformer models using some small in-domain data.

* NOTE: this only works for bilingual SentencePiece models


## Requirements

* marian-nmt
* SentencePiece
* Moses pre-processing scripts
* OpusTools-perl (for extracting text from TMX)



## Basic use:


Make a fine-tune data set from newstest data (as part of the eval data in this package), for example for English-German:

```
make SRC=en TRG=de news-tune-data
make SRC=en TRG=de all
```


Fine-tune with data from a given TMX file (in the direction of sorted language IDs taken from the TMX file):

```
make TMXFILE=file.tmx tmx-tune
```

Fine-tune with data from a given TMX file in reverse direction:

```
make TMXFILE=file.tmx REVERSE=1 tmx-tune
```


## Output

The fine-tuned models are in subdirectories of the language pair and model name, for example

```
en-de/news/model
```

Test scores using the baseline and the fine-tuned models are in

```
en-de/news/test/*.eval
```


## Step-wise procedure


The whole procedure consists of several steps that can be done in isolation:

```
#  make data .............. pre-process train/dev data
#  make tune .............. fine-tune model
#  make translate ......... translate test set with fine-tuned model
#  make translate-baseline  translate test set with baseline model
#  make eval .............. evaluate test set translation (fine-tuned)
#  make eval-baseline ..... evaluate test set translation (baseline)
#  make compare ........... put together source, reference translation and system output
#  make compare-baseline .. same as compare but with baseline translation
```




## TODO

*  make it work with multilingual models (need to adjust preprocess-scripts for those models)
