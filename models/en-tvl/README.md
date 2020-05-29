# Tatoeba-2020-01-17.zip

* dataset: Tatoeba
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [Tatoeba-2020-01-17.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/Tatoeba-2020-01-17.zip)
* test set translations: [Tatoeba-2020-01-17.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/Tatoeba-2020-01-17.test.txt)
* test set scores: [Tatoeba-2020-01-17.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/Tatoeba-2020-01-17.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.tvl 	| 46.9 	| 0.625 |

# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.tvl 	| 46.9 	| 0.625 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): tvl
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-tvl/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-tvl: Tatoeba (14) 
* en-tvl: total size = 14
* unused dev/test data is added to training data
* total size (opus+bt): 175142


## Validation data

* en-tvl: JW300

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.tvl 	| 47.7 	| 0.630 |

