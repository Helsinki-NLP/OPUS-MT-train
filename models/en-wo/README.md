# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): wo
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm1k,spm1k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-wo/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-wo/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-wo/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-wo: Tatoeba (3) Ubuntu (126) 
* en-wo: total size = 129
* unused dev/test data is added to training data
* total size (opus+bt): 10931


## Validation data

* en-wo: bible-uedin

* devset = top 2500  lines of bible-uedin.src.shuffled!
* testset = next 2500  lines of bible-uedin.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.en.wo 	| 46.6 	| 0.604 |

