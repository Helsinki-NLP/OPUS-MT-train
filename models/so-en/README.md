# opus-2019-12-05.zip

* dataset: opus
* model: transformer
* pre-processing: normalization + tokenization + BPE
* download: [opus-2019-12-05.zip](https://object.pouta.csc.fi/OPUS-MT-models/so-en/opus-2019-12-05.zip)
* test set translations: [opus-2019-12-05.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/so-en/opus-2019-12-05.test.txt)
* test set scores: [opus-2019-12-05.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/so-en/opus-2019-12-05.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.so.en 	| 36.8 	| 0.568 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): so
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/so-en/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/so-en/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/so-en/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* so-en: bible-uedin (62051) GNOME (452) Tanzil (93259) Ubuntu (16) wikimedia (316) 
* so-en: total size = 156094
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
| infopankki.so.en 	| 97.6 	| 0.982 |

