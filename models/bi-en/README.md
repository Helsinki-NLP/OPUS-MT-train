# QED-2020-01-17.zip

* dataset: QED
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [QED-2020-01-17.zip](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/QED-2020-01-17.zip)
* test set translations: [QED-2020-01-17.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/QED-2020-01-17.test.txt)
* test set scores: [QED-2020-01-17.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/QED-2020-01-17.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bi.en 	| 30.3 	| 0.458 |

# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bi.en 	| 30.3 	| 0.458 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): bi
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bi-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* bi-en: QED (27) 
* bi-en: total size = 27
* unused dev/test data is added to training data
* total size (opus+bt): 497074


## Validation data

* bi-en: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bi.en 	| 31.3 	| 0.472 |

