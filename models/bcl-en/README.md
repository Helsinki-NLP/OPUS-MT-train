# 





# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bcl.en 	| 56.8 	| 0.705 |







# opus-2020-02-11.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-02-11.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-02-11.zip)
* test set translations: [opus-2020-02-11.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-02-11.test.txt)
* test set scores: [opus-2020-02-11.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus-2020-02-11.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bcl.en 	| 56.1 	| 0.697 |







# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* bcl-en: wikimedia (1106) 
* bcl-en: total size = 1106
* unused dev/test data is added to training data
* total size (opus+bt): 458304


## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| JW300.bcl.en 	| 57.6 	| 0.712 |







# opus+nt-2021-03-29.zip

* dataset: opus+nt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+nt-2021-03-29.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt-2021-03-29.zip)
## Training data:  opus+nt

* bcl-en: JW300 (470468) new-testament (11623) 
* bcl-en: total size = 482091
* total size (opus+nt): 482047


## Validation data

* bcl-en: wikimedia, 1153
* total-size-shuffled: 775

* devset-selected: top 250  lines of wikimedia.src.shuffled!
* testset-selected: next 525  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt-2021-03-29.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt-2021-03-29.test.txt)
* test set scores: [opus+nt-2021-03-29.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt-2021-03-29.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 10.4 	| 0.320 	| 525 	| 27109 	| 0.477 |






# opus+nt+bt-2021-04-01.zip

* dataset: opus+nt+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus+nt+bt-2021-04-01.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-01.zip)
## Training data:  opus+nt+bt

* bcl-en: JW300 (470468) new-testament (11623) wiki.aa.en-bcl (969821) wikinews.aa.en-bcl (357946) 
* bcl-en: total size = 1809858
* total size (opus+nt+bt): 1809767


## Validation data

* bcl-en: wikimedia, 1153
* total-size-shuffled: 775

* devset-selected: top 250  lines of wikimedia.src.shuffled!
* testset-selected: next 525  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt+bt-2021-04-01.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-01.test.txt)
* test set scores: [opus+nt+bt-2021-04-01.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-01.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 28.2 	| 0.498 	| 525 	| 27109 	| 0.799 |





# opus+nt+bt+bt-2021-04-03.zip

* dataset: opus+nt+bt+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus+nt+bt+bt-2021-04-03.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt+bt-2021-04-03.zip)
## Training data:  opus+nt+bt+bt

* bcl-en: JW300 (470468) new-testament (11623) wiki.aa.en-bcl (969821) wikibooks.aa.en-bcl (985129) wikinews.aa.en-bcl (357946) wikiquote.aa.en-bcl (987266) wikisource.aa.en-bcl (948077) 
* bcl-en: total size = 4730330
* total size (opus+nt+bt+bt): 4730231


## Validation data

* bcl-en: wikimedia, 1153
* total-size-shuffled: 775

* devset-selected: top 250  lines of wikimedia.src.shuffled!
* testset-selected: next 525  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt+bt+bt-2021-04-03.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt+bt-2021-04-03.test.txt)
* test set scores: [opus+nt+bt+bt-2021-04-03.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt+bt-2021-04-03.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 16.2 	| 0.461 	| 525 	| 27109 	| 1.000 |




# opus+nt+bt+bt+bt-2021-04-05.zip

* dataset: opus+nt+bt+bt+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus+nt+bt+bt+bt-2021-04-05.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt+bt+bt-2021-04-05.zip)
## Training data:  opus+nt+bt+bt+bt

* bcl-en: JW300 (470468) new-testament (11623) wiki.aa.en-bcl (969821) wikibooks.aa.en-bcl (985129) wikinews.aa.en-bcl (357946) wikiquote.aa.en-bcl (987266) wikisource.aa.en-bcl (948077) 
* bcl-en: total size = 4730330
* total size (opus+nt+bt+bt+bt): 4730224


## Validation data

* bcl-en: wikimedia, 1153
* total-size-shuffled: 775

* devset-selected: top 250  lines of wikimedia.src.shuffled!
* testset-selected: next 525  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt+bt+bt+bt-2021-04-05.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt+bt+bt-2021-04-05.test.txt)
* test set scores: [opus+nt+bt+bt+bt-2021-04-05.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt+bt+bt-2021-04-05.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 24.2 	| 0.497 	| 525 	| 27109 	| 1.000 |



# opus+nt+bt-2021-04-09.zip

* dataset: opus+nt+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus+nt+bt-2021-04-09.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-09.zip)
## Training data:  opus+nt+bt

* bcl-en: JW300 (470468) new-testament (11623) wiki.aa.en-bcl (969821) wikibooks.aa.en-bcl (985129) wikinews.aa.en-bcl (357946) wikiquote.aa.en-bcl (987266) wikisource.aa.en-bcl (948077) 
* bcl-en: total size = 4730330
* unused dev/test data is added to training data
* total size (opus+nt+bt): 4731419


## Validation data

* bcl-en: wikimedia, 2767
* total-size-shuffled: 1966

* devset-selected: top 250  lines of wikimedia.src.shuffled!
* testset-selected: next 500  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt+bt-2021-04-09.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-09.test.txt)
* test set scores: [opus+nt+bt-2021-04-09.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-09.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 33.5 	| 0.562 	| 500 	| 28621 	| 0.868 |


# opus+nt+bt-2021-04-12.zip

* dataset: opus+nt+bt
* model: transformer-align
* source language(s): bcl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus+nt+bt-2021-04-12.zip](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-12.zip)
## Training data:  opus+nt+bt

* bcl-en: JW300 (470468) new-testament (11623) wiki.aa.en-bcl (969821) wikibooks.aa.en-bcl (985129) wikinews.aa.en-bcl (357946) wikiquote.aa.en-bcl (987266) wikisource.aa.en-bcl (948077) 
* bcl-en: total size = 4730330
* unused dev/test data is added to training data
* total size (opus+nt+bt): 4732437


## Validation data

* bcl-en: wikimedia, 5033
* total-size-shuffled: 4207

* devset-selected: top 1000  lines of wikimedia.src.shuffled!
* testset-selected: next 1000  lines of wikimedia.src.shuffled!
* devset-unused: added to traindata

* test set translations: [opus+nt+bt-2021-04-12.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-12.test.txt)
* test set scores: [opus+nt+bt-2021-04-12.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/bcl-en/opus+nt+bt-2021-04-12.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| wikimedia.bcl-en 	| 31.5 	| 0.523 	| 1000 	| 31520 	| 0.836 |

