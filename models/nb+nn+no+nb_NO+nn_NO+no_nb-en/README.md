# opus-2020-05-22.zip

* dataset: opus
* model: transformer-align
* source language(s): nb nn no nb_NO nn_NO no_nb
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus-2020-05-22.zip](https://object.pouta.csc.fi/OPUS-MT-models/nb+nn+no+nb_NO+nn_NO+no_nb-en/opus-2020-05-22.zip)
* test set translations: [opus-2020-05-22.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/nb+nn+no+nb_NO+nn_NO+no_nb-en/opus-2020-05-22.test.txt)
* test set scores: [opus-2020-05-22.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/nb+nn+no+nb_NO+nn_NO+no_nb-en/opus-2020-05-22.eval.txt)

## Training data:  opus

* nb-en: EUbookshop (27499) GNOME (116) KDE4 (93556) QED (124570) Ubuntu (3294) 
* nb-en: total size = 249035
* nn-en: GNOME (367687) KDE4 (76910) QED (3569) Ubuntu (38767) wikimedia (383) 
* nn-en: total size = 487316
* no-en: bible-uedin (61093) Books (3412) GNOME (7124) OpenSubtitles (8071047) Tanzil (134647) TildeMODEL (325194) Ubuntu (7925) wikimedia (66) 
* no-en: total size = 8610508
* nb_NO-en: GNOME (1) 
* nb_NO-en: total size = 1
* nn_NO-en: GNOME (1) 
* nn_NO-en: total size = 1
* no_nb-en: GNOME (20) 
* no_nb-en: total size = 20
* unused dev/test data is added to training data
* total size (opus): 11179800


## Validation data

* en-nb: Tatoeba, 9282
* en-nn: Tatoeba, 940
* en-no: JW300, 1837668
* en-nb_NO: bible-uedin, 0
* en-nn_NO: bible-uedin, 0
* en-no_nb: bible-uedin, 0
* total size of shuffled dev data: 1847890

* devset = top 5000  lines of opus-dev.src.shuffled!
* testset = next 5000  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| opus-test.nb.en 	| 44.7 	| 0.623 |

