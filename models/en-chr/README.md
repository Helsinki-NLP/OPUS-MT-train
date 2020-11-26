# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): en
* target language(s): chr
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm1k,spm1k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-chr/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-chr/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-chr/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-chr: Tatoeba (22) Ubuntu (6) wikimedia (5) 
* en-chr: total size = 33
* unused dev/test data is added to training data
* total size (opus+bt): 10938


## Validation data

* chr-en: bible-uedin, 15905
* total size of shuffled dev data: 15905

* devset = top 2500  lines of bible-uedin.src.shuffled!
* testset = next 2500  lines of bible-uedin.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.en.chr 	| 44.6 	| 0.569 |

