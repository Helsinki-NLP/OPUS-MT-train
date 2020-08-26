
# Models for the Tatoeba Translation Challenge


This is information about scripts for training and testing models with data from the [Tatoeba Translation Challenge](https://github.com/Helsinki-NLP/Tatoeba-Challenge). The build targets are defined in [lib/models/tatoeba.mk](https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master/lib/models/tatoeba.mk).


## Train and evaluate a single translation pair

For example, for Afrikaans-Esperanto:

```
make SRCLANGS=afr TRGLANGS=epo tatoeba-prepare
make SRCLANGS=afr TRGLANGS=epo tatoeba-train
make SRCLANGS=afr TRGLANGS=epo tatoeba-eval
```


## Start job for a single language pair

For example, for Afrikaans-Esperanto:

```
make SRCLANGS=afr TRGLANGS=epo tatoeba-job
```

You can also initiate jobs for transation models in both directions:

```
make SRCLANGS=afr TRGLANGS=epo tatoeba-bidirectional-job
```



## Multilingual models


Multilingual models that include all combinations of given source and target languages can be trained by calling the following special target, which first fetches the necessary data for all language pairs and then starts a training job. Here is an example with Afrikaans+Dutch as source languages and German+English+Spanish as target languages:

```
make SRCLANGS="afr nld" TRGLANGS="deu eng spa" tatoeba-job
```

In order to evaluate all language pairs using Tatoeba test data one can run:

```
make SRCLANGS="afr nld" TRGLANGS="deu eng spa" tatoeba-multilingual-eval
```

In order to skip certain language pairs one can set `SKIP_LANGPAIRS`, for example to skip `afr-eng` and `nld-spa` one can run:

```
make SRCLANGS="afr nld" TRGLANGS="deu eng spa" SKIP_LANGPAIRS="afr-eng|nld-spa" tatoeba-job
```




## Start jobs for all pairs in an entire subset


The following commands can be used to train all language pairs from a given subset of the Tatoeba Challenge data set. Note that each of them runs over all language pairs and prepares the data sets before submitting training and evluation jobs. Naturally, this will take a lot of time. Once the data sets are prepared, this does not have to be re-done. Jobs are submitted to the SLURM batch management system (make sure that this works in your setup).

```
make tatoeba-subset-lowest
make tatoeba-subset-lower
make tatoeba-subset-medium
make MODELTYPE=transformer tatoeba-subset-higher
make MODELTYPE=transformer tatoeba-subset-highest
```

Release packages can also be created for the entire subset (`medium` in the example below) by running:

```
make tatoeba-distsubset-medium
```

If training did not converge in time or jobs are interrupted then evaluation can also be invoked for the entire subset (`medium` in the example again) by running:

```
make tatoeba-evalsubset-medium
```


## Start jobs for multilingual models from one of the subsets

The commands below can be used to create mulitlingual NMT models with all languages involved in each of the Tatoeba Challenge subsets. First, all data sets will be created (which will take substantial amount of time) and after that the training jobs are submitted using SLURM. Data selections are automatically under/over-sampled to include equal amounts of training data for each language pair (base on the number of lines in the data).

```
make tatoeba-multilingual-subset-zero
make tatoeba-multilingual-subset-lowest
make tatoeba-multilingual-subset-lower
make tatoeba-multilingual-subset-medium
make tatoeba-multilingual-subset-higher
make tatoeba-multilingual-subset-highest
```

Note that this includes many languages and may not work well and training will take a lot of time as well.

Similar to the subset targets above, there are also special targets for creating release packages and for evaluating multilingual models. A release package is created by running:

```
make tatoeba-multilingual-distsubset-zero
make tatoeba-multilingual-distsubset-lowest
...
```

Another special thing is that multilingual models cover many language pairs. In order to run all test sets for all language pairs one can run:

```
make tatoeba-multilingual-evalsubset-zero
make tatoeba-multilingual-evalsubset-lowest
...
```

Note that this can be quite a lot of language pairs!



## Working with language groups

Language groups are defined according to ISO639-5. The Perl module ISO::639::5 needs to be installed 
to retrieve the language group hierarchy. Various combinations of language groups and English can be
trained using the following commands (note that this starts all combinations, see below for individual jobs):

```
make tatoeba-group2eng   # start train jobs for all language groups to English
make tatoeba-eng2group   # start train jobs for English to all language groups
make tatoeba-langgroup   # start train jobs for bi-directional models for all language groups
```

The targets above train models on over/under-sampled datasets to balance language pairs included in the multilingual model. The sample size per language pair is 1 million sentence pairs with a threshold of 50 for the maximum number of repeating the same data.

Combine all jobs above using:

```
make tatoeba-langgroups
```


Create release packages from the language group models

```
make tatoeba-group2eng-dist  # make package for all trained group2eng models
make tatoeba-eng2group-dist  # make package for all trained eng2group models
make tatoeba-langgroup-dist  # make package for all trained langgroup models
```

Jobs for specific tasks and language groups; example task: `gmw2eng` (it's recommended to use `MODELTYPE=transformer` to skip word alignment and `FIT_DATA_SIZE` controls the data size used in over- and undersampling data to balance various language pairs in the training data):

```
make MODELTYPE=transformer FIT_DATA_SIZE=1000000 tateoba-gmw2eng-train    # make data and start training job
make MODELTYPE=transformer FIT_DATA_SIZE=1000000 tateoba-gmw2eng-eval     # evaluate model with multilingual test data
make MODELTYPE=transformer FIT_DATA_SIZE=1000000 tateoba-gmw2eng-evalall  # evaluate model with all individual language pairs
make MODELTYPE=transformer FIT_DATA_SIZE=1000000 tateoba-gmw2eng-dist     # create release package
```

Similar jobs can be started for any supported language group from and to English
and also as a bidirectional model for all languages in the given language group.
Replace `gmw2eng` with, for example, `eng2gem` (English to Germanic) or 
`gmq` (multilingual model for North Germanic languages).





## Generate evaluation tables

Various lists and tables can be generated from the evaluated model files. Remove old files and generat new ones by running:

```
rm -f tatoeba-results* results/*.md
make tatoeba-results-md
```
