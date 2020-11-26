# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): cjp
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm1k,spm1k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-cjp/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-cjp/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-cjp/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* unused dev/test data is added to training data
* total size (opus+bt): 10750


## Validation data

* cjp-en: bible-uedin, 15749
* total size of shuffled dev data: 15749

* devset = top 2500  lines of bible-uedin.src.shuffled!
* testset = next 2500  lines of bible-uedin.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.en.cjp 	| 31.8 	| 0.535 |

