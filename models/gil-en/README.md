# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/gil-en/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/gil-en/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/gil-en/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.gil.en 	| 36.0 	| 0.522 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): gil
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/gil-en/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/gil-en/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/gil-en/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* gil-en: Tatoeba (14) wiki.aa (964767) 
* gil-en: total size = 964781
* unused dev/test data is added to training data
* total size (opus+bt): 1168199


## Validation data

* en-gil: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.gil.en 	| 35.1 	| 0.521 |

