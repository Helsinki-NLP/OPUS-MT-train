# opus-2020-01-09.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-09.zip](https://object.pouta.csc.fi/OPUS-MT-models/lg-en/opus-2020-01-09.zip)
* test set translations: [opus-2020-01-09.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/lg-en/opus-2020-01-09.test.txt)
* test set scores: [opus-2020-01-09.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/lg-en/opus-2020-01-09.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.lg.en 	| 32.6 	| 0.480 |
| Tatoeba.lg.en 	| 5.4 	| 0.243 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): lg
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/lg-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/lg-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/lg-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* lg-en: GNOME (638) QED (178) Tatoeba (2) Ubuntu (153) wikimedia (98) 
* lg-en: total size = 1069
* unused dev/test data is added to training data
* total size (opus+bt): 229610


## Validation data

* en-lg: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.lg.en 	| 33.3 	| 0.491 |

