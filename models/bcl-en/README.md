
# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bcl.en 	| 56.8 	| 0.705 |


# opus-2020-02-11.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-02-11.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-02-11.zip)
* test set translations: [opus-2020-02-11.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-02-11.test.txt)
* test set scores: [opus-2020-02-11.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-02-11.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bcl.en 	| 56.1 	| 0.697 |


# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* bcl-en: wikimedia (1106) 
* bcl-en: total size = 1106
* unused dev/test data is added to training data
* total size (opus+bt): 458304


## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bcl.en 	| 57.6 	| 0.712 |


# opus+nt-2021-03-29.zip

* dataset: opus+nt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+nt-2021-03-29.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt-2021-03-29.zip)
## Training data:  opus+nt

* bcl-en: JW300 (470468) new-testament (11623) 
* bcl-en: total size = 482091
* total size (opus+nt): 482047


## Validation data

* bcl-en: wikimedia, 1153
* total-size-shuffled: 775

* devset-selected: top 250  lines of wikimedia.src.shuffled!
* testset-selected: next 525  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt-2021-03-29.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt-2021-03-29.test.txt)
* test set scores: [opus+nt-2021-03-29.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt-2021-03-29.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 10.4 	| 0.320 	| 525 	| 27109 	| 0.477 |

