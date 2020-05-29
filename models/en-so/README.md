# opus-2019-12-04.zip

* dataset: opus
* model: transformer
* pre-processing: normalization + tokenization + BPE
* download: [opus-2019-12-04.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-so/opus-2019-12-04.zip)
* test set translations: [opus-2019-12-04.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-so/opus-2019-12-04.test.txt)
* test set scores: [opus-2019-12-04.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-so/opus-2019-12-04.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.so 	| 78.3 	| 0.829 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): en
* target language(s): so
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-so/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-so/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-so/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-so: bible-uedin (62051) GNOME (452) Tanzil (93259) Ubuntu (16) wikimedia (316) 
* en-so: total size = 156094
* unused dev/test data is added to training data
* total size (opus+bt): 197435


## Validation data

* en-so: infopankki

* devset = top 1000  lines of infopankki.src.shuffled!
* testset = next 1000  lines of infopankki.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| infopankki.en.so 	| 94.5 	| 0.965 |

