# opus-2019-12-18.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2019-12-18.zip](https://object.pouta.csc.fi/OPUS-MT-models/ber-en/opus-2019-12-18.zip)
* test set translations: [opus-2019-12-18.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/ber-en/opus-2019-12-18.test.txt)
* test set scores: [opus-2019-12-18.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/ber-en/opus-2019-12-18.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.ber.en 	| 37.3 	| 0.566 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): ber
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm1k,spm1k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/ber-en/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/ber-en/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/ber-en/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* ber-en: QED (23) Ubuntu (6) wiki.aa.en-ber (918298) 
* ber-en: total size = 918327
* unused dev/test data is added to training data
* total size (opus+bt): 983147


## Validation data

* ber-en: Tatoeba

* devset = top 5000  lines of Tatoeba.src.shuffled!
* testset = next 5000  lines of Tatoeba.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.ber.en 	| 23.8 	| 0.445 |

