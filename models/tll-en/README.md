# opus-2020-01-16.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-16.zip](https://object.pouta.csc.fi/OPUS-MT-models/tll-en/opus-2020-01-16.zip)
* test set translations: [opus-2020-01-16.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/tll-en/opus-2020-01-16.test.txt)
* test set scores: [opus-2020-01-16.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/tll-en/opus-2020-01-16.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.tll.en 	| 34.5 	| 0.500 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): tll
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/tll-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/tll-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/tll-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* tll-en: 
* tll-en: total size = 0
* unused dev/test data is added to training data
* total size (opus+bt): 223603


## Validation data

* en-tll: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.tll.en 	| 34.1 	| 0.502 |

