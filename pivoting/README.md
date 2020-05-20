
# Pivot-based data augmentation

The idea of this folder is to create synthetic training data by translating existing bitexts for a different language pair on one side. An example is to create training data for translation from Breton to English from bitexts in Breton and French. The French part of the auxiliary corpus is translated to English using a strong French-English translation model.


This assumes that

* auxiliary data sets are in `ORIGINAL_DATADIR` (defaults to `${PWD}/../work/data`)
* packaged translation models can be found in `${PWD}/../models` or `${PWD}/../models`


## Usage

Set variables SRC, TRG and PIVOT and run `make all`, for example to translate French-Breton data to English-Breton:

```
make SRC=en TRG=br PIVOT=fr all
```

You can print the data that will be translated and the model that will be used for that by running:

```
make SRC=en TRG=br PIVOT=fr print-all-data
make SRC=en TRG=br PIVOT=fr print-modelname
```

If this does not print anything then running `make all` does not make sense. For submitting a job via slurm you can add the suffic `.submit` to the call, e.g.

```
make SRC=en TRG=br PIVOT=fr all.submit
```



## Specific models

Special targets for specific models are defined in `lib/models.mk`. Use them like this:

* Sami language model: `make all-sami` (can also do `make print-all-data-sami` and `make print-modelname-sami`)



## TODO

* get models from ObjectStorage instead to fetch them from the local filesystem
* get auxiliary data from OPUS instead of pre-processed data in the OPUS-MT dir (with hard-coded path)
