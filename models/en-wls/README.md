# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): en
* target language(s): wls
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-wls/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-wls/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-wls/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* unused dev/test data is added to training data
* total size (opus+bt): 156156


## Validation data

* en-wls: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.wls 	| 35.6 	| 0.565 |

