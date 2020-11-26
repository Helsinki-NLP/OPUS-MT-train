# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): ve
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-ve/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-ve/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-ve/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-ve: Ubuntu (4) wikimedia (2) 
* en-ve: total size = 6
* unused dev/test data is added to training data
* total size (opus+bt): 208084


## Validation data

* en-ve: JW300, 213086
* total size of shuffled dev data: 213086

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.ve 	| 40.5 	| 0.616 |

