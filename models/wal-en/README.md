# opus-2020-01-24.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-24.zip](https://object.pouta.csc.fi/OPUS-MT-models/wal-en/opus-2020-01-24.zip)
* test set translations: [opus-2020-01-24.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/wal-en/opus-2020-01-24.test.txt)
* test set scores: [opus-2020-01-24.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/wal-en/opus-2020-01-24.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.wal.en 	| 22.5 	| 0.386 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): wal
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/wal-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/wal-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/wal-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* wal-en: bible-uedin (15453) 
* wal-en: total size = 15453
* unused dev/test data is added to training data
* total size (opus+bt): 120442


## Validation data

* en-wal: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.wal.en 	| 22.4 	| 0.398 |

