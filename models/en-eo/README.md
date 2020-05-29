# opus-2019-12-04.zip

* dataset: opus
* model: transformer
* pre-processing: normalization + tokenization + BPE
* download: [opus-2019-12-04.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2019-12-04.zip)
* test set translations: [opus-2019-12-04.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2019-12-04.test.txt)
* test set scores: [opus-2019-12-04.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2019-12-04.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.eo 	| 32.4 	| 0.533 |

# opus-2019-12-18.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2019-12-18.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2019-12-18.zip)
* test set translations: [opus-2019-12-18.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2019-12-18.test.txt)
* test set scores: [opus-2019-12-18.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2019-12-18.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.eo 	| 49.5 	| 0.682 |

# opus-2020-05-23.zip

* dataset: opus
* model: transformer-align
* source language(s): en
* target language(s): eo
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2020-05-23.zip)
* test set translations: [opus-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2020-05-23.test.txt)
* test set scores: [opus-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-eo/opus-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-eo: bible-uedin (61412) Books (1492) GlobalVoices (2779) GNOME (19165) KDE4 (37316) OpenSubtitles (51388) QED (15746) Ubuntu (4441) 
* en-eo: total size = 193739
* unused dev/test data is added to training data
* total size (opus+bt): 405729


## Validation data

* en-eo: Tatoeba

* devset = top 5000  lines of Tatoeba.src.shuffled!
* testset = next 5000  lines of Tatoeba.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.eo 	| 50.7 	| 0.693 |

