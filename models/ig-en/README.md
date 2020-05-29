# opus-2020-01-09.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-09.zip](https://object.pouta.csc.fi/OPUS-MT-models/ig-en/opus-2020-01-09.zip)
* test set translations: [opus-2020-01-09.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/ig-en/opus-2020-01-09.test.txt)
* test set scores: [opus-2020-01-09.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/ig-en/opus-2020-01-09.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.ig.en 	| 36.7 	| 0.520 |
| Tatoeba.ig.en 	| 46.3 	| 0.528 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): ig
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/ig-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/ig-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/ig-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* ig-en: GNOME (18652) Tatoeba (16) Ubuntu (509) wikimedia (1030) 
* ig-en: total size = 20207
* unused dev/test data is added to training data
* total size (opus+bt): 453369


## Validation data

* en-ig: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.ig.en 	| 38.5 	| 0.539 |

