
# Models for the Tatoeba Translation Challenge


This is information about scripts for training and testing models with data from the [Tatoeba Translation Challenge](https://github.com/Helsinki-NLP/Tatoeba-Challenge). The build targets are defined in `lib/models/tatoeba.mk`.


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



## Start jobs for all pairs in an entire subset


The following commands can be used to train all language pairs from a given subset of the Tatoeba Challenge data set. Note that each of them runs over all language pairs and prepares the data sets before submitting training and evluation jobs. Naturally, this will take a lot of time. Once the data sets are prepared, this does not have to be re-done. Jobs are submitted to the SLURM batch management system (make sure that this works in your setup).

```
make tatoeba-subset-lowest
make tatoeba-subset-lower
make tatoeba-subset-medium
make MODELTYPE=transformer tatoeba-subset-higher
make MODELTYPE=transformer tatoeba-subset-highest
```


## Start jobs for multilingual models from one of the subsets

The commands below can be used to create mulitlingual NMT models with all languages involved in each of the Tatoeba Challenge subsets. First, all data sets will be created (which will take substantial amount of time) and after that the training jobs are submitted using SLURM. Data selections are automatically under/over-sampled to include equal amounts of training data for each language pair (base on the number of lines in the data).

```
make tatoeba-multilingual-subset-lowest
make tatoeba-multilingual-subset-lower
make tatoeba-multilingual-subset-medium
make tatoeba-multilingual-subset-higher
make tatoeba-multilingual-subset-highest
```

Note that this includes many languages and may not work well and training will take a lot of time as well.