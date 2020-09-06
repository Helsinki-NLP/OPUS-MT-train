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
make -C backtranslate SRC=br fetch-wiki
```

Finally, we can translate the Breton Wikipedia to English using the br-en model we have trained above. We set the maximum to 50,000 in this example to reduce the time we need for translating. The default is 1 million sentences to be translated. Run this on a GPU machine and it should take about 1-2 hours:

```
make -C backtranslate SRC=br TRG=en MAX_SENTENCES=50000 translate
```

The translations are most probably really bad as the back-translation model is very poor (ca. 4 BLEU).
The translations will be stored in the `backtranslate` directory in a sub-folder `br-en` together with the model that has been used to translate. A copy of the latest translations is kept in `backtranslate/br-en/latest`. Those will be overwritten in case you re-translate the same data.

* the model used for back-translation:

```
backtranslate/br-en/opus-2020-09-04/source.spm
backtranslate/br-en/opus-2020-09-04/target.spm
backtranslate/br-en/opus-2020-09-04/preprocess.sh
backtranslate/br-en/opus-2020-09-04/postprocess.sh
backtranslate/br-en/opus-2020-09-04/opus.spm4k-spm4k.vocab.yml
backtranslate/br-en/opus-2020-09-04/opus.spm4k-spm4k.transformer.model1.npz.best-perplexity.npz
```

* the back-translated data from Wikipedia

```
backtranslate/br-en/wiki.aa_opus-2020-09-04.br-en.br.gz
backtranslate/br-en/wiki.aa_opus-2020-09-04.br-en.en.gz
backtranslate/br-en/latest/wiki.aa.br-en.br.gz
backtranslate/br-en/latest/wiki.aa.br-en.en.gz
```



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

Pivot-based translations are stored in `pivoting/en-br` together with the model that has been used for pivot translation between French and English, in this case for OpenSubtitles and OfisPublik data in Breton-French (`br-fr`):

* translation model:

```
pivoting/en-br/opus-2020-02-26/source.spm
pivoting/en-br/opus-2020-02-26/target.spm
pivoting/en-br/opus-2020-02-26/preprocess.sh
pivoting/en-br/opus-2020-02-26/postprocess.sh
pivoting/en-br/opus-2020-02-26/opus.spm32k-spm32k.vocab.yml
pivoting/en-br/opus-2020-02-26/opus.spm32k-spm32k.transformer-align.model1.npz.best-perplexity.npz
```

* pivot-based translations:

```
pivoting/en-br/OfisPublik.br-fr.opus-2020-02-26.br-en.fr.spm.gz
pivoting/en-br/OfisPublik.br-fr.opus-2020-02-26.br-en.en.gz
pivoting/en-br/OpenSubtitles.br-fr.opus-2020-02-26.br-en.fr.spm.gz
pivoting/en-br/OpenSubtitles.br-fr.opus-2020-02-26.br-en.en.gz
pivoting/en-br/latest/OfisPublik.br-fr.br-en.br.gz
pivoting/en-br/latest/OfisPublik.br-fr.br-en.en.gz
pivoting/en-br/latest/OpenSubtitles.br-fr.br-en.en.gz
pivoting/en-br/latest/OpenSubtitles.br-fr.br-en.br.gz
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

The results is still not much better as the back-translations are of poor quality. Note also that the test set is much too small to have reliable scores:

| testset               | BLEU  | chr-F  |
|-----------------------|-------|--------|
| opus                  | 3.9   | 0.1763 |
| opus+bt               | 4.3   | 0.1827 |


In summary, the translations are still useless, BLEU and chrF2 go slightly up but on that data set and with those performance level this does not say anything.

We can do the same with adding pivot-based translation produced above from Breton-French data.The principle is the same that we can simply add a suffix (`-pivot`) to the build targets to change the setup:

```
make SRCLANGS=en TRGLANGS=br data-pivot
make SRCLANGS=en TRGLANGS=br train-pivot
make SRCLANGS=en TRGLANGS=br eval-pivot
make SRCLANGS=en TRGLANGS=br compare-pivot
```

This will add all bitexts that can be found in `pivoting/en-br/latest` (and `pivoting/br-en/latest` if it exists) to the training data and re-uses the sentence-piece models and vocabulary from the base model. The pivot-based translations are substantially better than the back-translations with the poor reverse translation model.

| testset               | BLEU  | chr-F  |
|-----------------------|-------|--------|
| opus                  | 3.9   | 0.1763 |
| opus+bt               | 4.3   | 0.1827 |
| opus+pivot            | 4.8   | 0.2304 |


Finally, we can also combine back-translations and pivot-based translations and train models that include all of the extra data sets. This is simply done by combining the suffix codes:

```
make SRCLANGS=en TRGLANGS=br train-pivot-bt
make SRCLANGS=en TRGLANGS=br eval-pivot-bt
make SRCLANGS=en TRGLANGS=br compare-pivot-bt
```

Note that the order is important here to determine, which one of the models will be used as a base model to continue training on. In the example above, the model that includes back-translations (`opus+bt`) will be used as a starting point for training the new model with combined data sets. Calling `train-bt-pivot` will start with the pivot-augmented model (`opus+pivot`).


| testset               | BLEU  | chr-F  |
|-----------------------|-------|--------|
| opus                  | 3.9   | 0.1763 |
| opus+bt               | 4.3   | 0.1827 |
| opus+pivot            | 4.8   | 0.2304 |
| opus+bt+pivot         | 5.6   | 0.2187 |



## Multilingual models

## Packaging
