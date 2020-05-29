# QED-2020-01-17.zip

* dataset: QED
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [QED-2020-01-17.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-run/QED-2020-01-17.zip)
* test set translations: [QED-2020-01-17.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-run/QED-2020-01-17.test.txt)
* test set scores: [QED-2020-01-17.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-run/QED-2020-01-17.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.run 	| 34.2 	| 0.591 |

# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-run/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-run/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-run/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.run 	| 34.2 	| 0.591 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): run
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-run/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-run/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-run/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-run: QED (13) 
* en-run: total size = 13
* unused dev/test data is added to training data
* total size (opus+bt): 380448


## Validation data

* en-run: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.run 	| 34.8 	| 0.600 |

