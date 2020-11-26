# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): zne
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-zne/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-zne/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-zne/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* unused dev/test data is added to training data
* total size (opus+bt): 184853


## Validation data

* en-zne: JW300, 189924
* total size of shuffled dev data: 189924

* devset = top 2500  lines of JW300.src.shuffled!
* testset = next 2500  lines of JW300.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.en.zne 	| 32.0 	| 0.556 |

