# opus-2020-01-21.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-21.zip](https://object.pouta.csc.fi/OPUS-MT-models/niu-en/opus-2020-01-21.zip)
* test set translations: [opus-2020-01-21.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/niu-en/opus-2020-01-21.test.txt)
* test set scores: [opus-2020-01-21.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/niu-en/opus-2020-01-21.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.niu.en 	| 46.1 	| 0.604 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): niu
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/niu-en/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/niu-en/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/niu-en/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* niu-en: Tatoeba (23) 
* niu-en: total size = 23
* unused dev/test data is added to training data
* total size (opus+bt): 219436


## Validation data

* en-niu: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.niu.en 	| 46.4 	| 0.611 |

