# OPUS-MT-train tutorial

This tutorial goes through some common tasks with the example of training models to translate from English Breton to English. We assume that you have a working setup of all tools required. Check the [installation documentation](../Setup.md) for further information.


## Basic configuration and data sets


* create a local configuration file with language-specific settings

```
make SRCLANGS=en TRGLANGS=br local-config
```


* create data sets, subword segmentation models and NMT vocabulary

```
make SRCLANGS=en TRGLANGS=br data
```

This will also download the necessary files if they don't exist on the local file system. It will train sentence piece models for each language separately and apply the model to all data sets. Finally, it also creates the vocabulary file from the segmented training data.


## Train the model

Training the model requires a GPU. Run this directly on a machine with appropriate hardware and CUDA libraries installed or submit a job to some GPU nodes on a cluster.

```
make SRCLANGS=en TRGLANGS=br train
```

Depending on the size of the data this will take hours, days or weeks to finish. The stopping criterion is set to 10 subsequent non-improved validation scores on validation data. For en-br this will take 1-2 hours. For submitting jobs have a look at the [documentation for batch jobs](BatchJobs.md).

Traininng can always be resumed in case the process crashes for some reason using the same command as above.



## Evaluate the model

Evaluation can be done at any time there is a model from one of the validation steps or the final model after convergence. Running the translation and evaluation of the given test set is done by calling:

```
make SRCLANGS=en TRGLANGS=br translate
make SRCLANGS=en TRGLANGS=br eval
```

Translation runs, naturally, faster on a GPU but can also be done in reasonable time on CPU cores. You can add cores by setting the `THREADS` variable. Evaluation is done using sacrebleu and translations as wells as BLEU/chrF2 scores ars stored in the work directory, in this case in

```
work/en-br/Tatoeba.opus.spm4k-spm4k1.transformer.en.br
work/en-br/Tatoeba.opus.spm4k-spm4k1.transformer.en.br.eval
```

There is also a recipe for merging input, reference translation and system output into one file for better readability:

```
make SRCLANGS=en TRGLANGS=br compare
less work/en-br/Tatoeba.opus.spm4k-spm4k1.transformer.en.br.compare
```

Translation and evaluation files will be overwritten when a new model appears and the evaluation target is called again.



## Generate back-translations

Back-translation requires a moel in the opposite direction. First thing to do is to reverse the data. This can be done without generating them from scratch:

```
make SRCLANGS=en TRGLANGS=br reverse-data
```

Now train a new model but in the opposite direction:

```
make SRCLANGS=br TRGLANGS=en train
```

After training we need to create a package to be used by back-translation. Run this to create a package in `work/models/br-en`:

```
make SRCLANGS=br TRGLANGS=en dist
```


The next step is to fetch some monolingual data to be back-translated. OPUS-MT is prepared to use Wiki data from various Wikimedia wikis (Wikipedia, Wikiquote, Wikisource, Wikibooks, Wikinews). You can fetch the prepared data sets by running:

```
make -C backtranslation SRC=br fetch-wikidoc
```

Finally, we can translate the Breton Wikipedia to English using the br-en model we have trained above (run this on a GPU machine):

```
make -C backtranslation SRC=br translate
```

The translations are most probably really bad as the back-translation model is vry poor (around 4 BLEU).




## Generate pivot-based translations

## Re-train using back-translations and pivot translations

## Multilingual models

## Packaging
