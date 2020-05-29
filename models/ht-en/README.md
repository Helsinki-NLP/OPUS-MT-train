# opus-2020-01-09.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-09.zip](https://object.pouta.csc.fi/OPUS-MT-models/ht-en/opus-2020-01-09.zip)
* test set translations: [opus-2020-01-09.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/ht-en/opus-2020-01-09.test.txt)
* test set scores: [opus-2020-01-09.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/ht-en/opus-2020-01-09.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.ht.en 	| 37.5 	| 0.542 |
| Tatoeba.ht.en 	| 57.0 	| 0.689 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): ht
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/ht-en/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/ht-en/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/ht-en/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* ht-en: QED (4643) Tatoeba (45) Ubuntu (225) wikimedia (83) 
* ht-en: total size = 4996
* unused dev/test data is added to training data
* total size (opus+bt): 204693


## Validation data

* en-ht: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.ht.en 	| 36.8 	| 0.545 |

