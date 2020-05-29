# opus-2020-01-16.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-16.zip](https://object.pouta.csc.fi/OPUS-MT-models/yo-en/opus-2020-01-16.zip)
* test set translations: [opus-2020-01-16.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/yo-en/opus-2020-01-16.test.txt)
* test set scores: [opus-2020-01-16.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/yo-en/opus-2020-01-16.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.yo.en 	| 33.8 	| 0.496 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): yo
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/yo-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/yo-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/yo-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* yo-en: GNOME (3928) Tatoeba (31) Ubuntu (76) 
* yo-en: total size = 4035
* unused dev/test data is added to training data
* total size (opus+bt): 435278


## Validation data

* en-yo: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.yo.en 	| 36.3 	| 0.519 |

