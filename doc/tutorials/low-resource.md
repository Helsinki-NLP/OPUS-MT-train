# OPUS-MT-train tutorial

This tutorial goes through some common tasks with the example of training models to translate from Breton to English. First of all, clone the repository from github:


```
git clone git@github.com:Helsinki-NLP/OPUS-MT-train.git
cd OPUS-MT-train
```


## Basic configuration and data sets


* create a local configuration file with language-specific settings

```
make SRCLANGS=br TRGLANGS=en local-config
```


* create data sets, subword segmentation models, word alignments and model vocabulary

```
make SRCLANGS=br TRGLANGS=en data
```


## Train the model

## Evaluate the model

## Generate back-translations

## Generate pivot-based translations

## Re-train using back-translations and pivot translations

## Multilingual models

## Packaging
