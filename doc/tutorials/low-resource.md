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

Depending on the size of the data this will take hours, days or weeks to finish. The stopping criterion is set to 10 subsequent non-improved validation scores on validation data. For en-br this will take 1-2 hours. For submitting jobs have a look at the [documentation for batch jobs](BatchJobs.md). Progress will be printed to STDERR and logfiles in the work-directory `br-en/opus.spm4k-spm4k.transformer.train1.log` with validation scores in `br-en/opus.spm4k-spm4k.transformer.valid1.log`.

Training can always be resumed in case the process crashes for some reason using the same command as above.



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
The basic model with OPUS data should be quite poor and will obatain scores below 10 BLEU. This is what I got:

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.br         | 3.9   | 0.1763 |

Note that the data splits are done on-the-fly from shuffled data sets and this may vary when re-doing the data splits. This also means that new data splits are not compatible with previous test sets and should not be used to evaluate against other models. Remaining examples from the testset corpus are added to training data and in new splits there will be different kinds of overlaps between test and train!



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

The quality of the translations in the opposite direction are still poor but let's see if the can be used for augmenting the training data anyway. Here is a comparison between both translation directions in my run:

| testset               | BLEU  | chr-F  |
|-----------------------|-------|--------|
| Tatoeba.en.br         | 3.9   | 0.1763 |
| Tatoeba.br.en 	| 4.0 	| 0.2027 |



The next step is to fetch some monolingual data to be back-translated. OPUS-MT is prepared to use Wiki data from various Wikimedia wikis (Wikipedia, Wikiquote, Wikisource, Wikibooks, Wikinews). You can fetch the prepared data sets by running:

```
make -C backtranslation SRC=br fetch-wiki
```

Finally, we can translate the Breton Wikipedia to English using the br-en model we have trained above. We set the maximum to 10,000 in this example to reduce the time we need for translating. The default is 1 million sentences to be translated. Run this on a GPU machine and it should take about 20 minutes:

```
make -C backtranslation SRC=br TRG=en MAX_SENTENCES=10000 translate
```

The translations are most probably really bad as the back-translation model is very poor (around 4 BLEU).
The translations will be stored in the current directory in a sub-folder `br-en` together with the model that has been used to translate. A copy of the latest translations is kept in `br-en/latest`. Those will be overwritten in case you re-translate the same data.

Translating 50,000 sentences from Breton to English took about 50 minutes in our experiment.


## Generate pivot-based translations

Another way of augmenting training data is to translate existing bitexts on one side of the bitext to create more data for the language pair we are interested in. For example, for the case of English-Breton translation we can translate the French part of French-Breton bitexts to English using an existing French-English translation model. The latter is a high-resource language pair and decent transaltions can be expected. All this is supported by the recipes in `pivoting`.

Forst of all, you can check what kind of bitexts are available for a pivot language like French:

```
make -C pivoting SRC=en TRG=br PIVOT=fr print-all-data
```

Nexts thing is that we need a translation model for the pivot language to the source language. If there is none in `models/fr-en` then we can fetch one from the pre-trained translation models:

```
make SRCLANGS=fr TRGLANGS=en fetch-model
```

Hopefully, the system can now find that model and we can prepare the pivot bitexts and translate them all:

```
make -C pivoting SRC=en TRG=br PIVOT=fr print-modelname
make -C pivoting SRC=en TRG=br PIVOT=fr all
```





## Re-train using back-translations and pivot translations

We can now use back-translated data to train a new model, add the suffix `-bt` to the same targets as we have used before:

```
make SRCLANGS=en TRGLANGS=br data-bt
make SRCLANGS=en TRGLANGS=br train-bt
```

Those commands will re-use existing sentence-piece models, vocabulary files and will initialize the model with the one trained on OPUS data without back-translations. The early stopping settings are increased to 15 iterations without improvement. The model name will now be changed into `opus+bt` and logs will be stored `br-en/opus+bt.spm4k-spm4k.transformer.train1.log` with validation scores in `br-en/opus+bt.spm4k-spm4k.transformer.valid1.log`

Evaluation can be done in the same way:

```
make SRCLANGS=en TRGLANGS=br eval-bt
make SRCLANGS=en TRGLANGS=br compare-bt
```

The results is not good as the back-translations are of poor quality. Note also that the test set is much too small to have reliable scores:

| testset               | BLEU  | chr-F  |
|-----------------------|-------|--------|
| opus                  | 3.9   | 0.1763 |
| opus+bt               | 3.5   | 0.1949 |

In summary, the translations are still useless, chrF2 goes up and BLEU goes down but on that data set and with those performance level this does not say anything.



## Multilingual models

## Packaging
