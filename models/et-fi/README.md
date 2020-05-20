# opus-2020-01-08.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-08.zip](https://object.pouta.csc.fi/OPUS-MT-models/et-fi/opus-2020-01-08.zip)
* test set translations: [opus-2020-01-08.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/et-fi/opus-2020-01-08.test.txt)
* test set scores: [opus-2020-01-08.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/et-fi/opus-2020-01-08.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.et.fi 	| 26.6 	| 0.546 |

# opus-2020-05-20.zip

* dataset: opus
* model: transformer-align
* source language(s): et
* target language(s): fi
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus-2020-05-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/et-fi/opus-2020-05-20.zip)
* test set translations: [opus-2020-05-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/et-fi/opus-2020-05-20.test.txt)
* test set scores: [opus-2020-05-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/et-fi/opus-2020-05-20.eval.txt)

## Validation data

* et-fi: infopankki, 51611
* total size of shuffled dev data: 51611

* devset = top 2500  lines of infopankki.src.shuffled!
* testset = next 2500  lines of infopankki.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| infopankki.et.fi 	| 61.3 	| 0.813 |

