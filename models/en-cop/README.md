# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): cop
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm1k,spm1k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-cop/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-cop/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-cop/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* unused dev/test data is added to training data
* total size (opus+bt): 10896


## Validation data

* cop-en: bible-uedin, 15901
* total size of shuffled dev data: 15901

* devset = top 2500  lines of bible-uedin.src.shuffled!
* testset = next 2500  lines of bible-uedin.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.en.cop 	| 45.6 	| 0.651 |

