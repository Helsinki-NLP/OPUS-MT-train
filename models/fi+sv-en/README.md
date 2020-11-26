# opus-2020-10-10.zip

* dataset: opus
* model: transformer
* source language(s): fi sv
* target language(s): en
* model: transformer
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus-2020-10-10.zip](https://object.pouta.csc.fi/OPUS-MT-models/fi+sv-en/opus-2020-10-10.zip)
* test set translations: [opus-2020-10-10.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi+sv-en/opus-2020-10-10.test.txt)
* test set scores: [opus-2020-10-10.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi+sv-en/opus-2020-10-10.eval.txt)

## Training data:  opus

* fi-en: Books (3618) DGT (4887825) ECB (139089) ELRA-W0217 (9772) ELRA-W0220 (53703) ELRA-W0305 (15) ELRC_2922 (312) ELRC_2923 (394) ELRC_3382 (3357) ELRC_416 (696) EMEA (875550) EUbookshop (2027241) EUconst (7220) Europarl (1954995) GNOME (59709) JRC-Acquis (15927) JW300 (2001165) KDE4 (90150) OpenSubtitles (26457741) PHP (24293) ParaCrawl (3089564) QED (98509) TildeMODEL (2983582) Ubuntu (7470) bible-uedin (61917) infopankki (84378) 
* fi-en: total size = 44938192
* sv-en: Books (3047) DGT (4780207) ELRA-W0130 (2170) ELRA-W0213 (1924) ELRA-W0222 (6560) ELRA-W0239 (8265) ELRA-W0305 (1132) ELRC_2922 (499) ELRC_2923 (492) ELRC_3382 (3738) ELRC_416 (1062) EMEA (840417) EUbookshop (1885825) EUconst (7010) Europarl (1870175) GNOME (126) GlobalVoices (8012) JRC-Acquis (666453) JW300 (1641702) KDE4 (190266) OpenSubtitles (16169056) PHP (18420) ParaCrawl (6000734) QED (161764) RF (174) Tanzil (126202) TildeMODEL (3102585) Ubuntu (5678) WikiSource (32427) bible-uedin (61205) infopankki (51688) 
* sv-en: total size = 37649015
* unused dev/test data is added to training data
* total size (opus): 82379895


## Validation data

* en-fi: Tatoeba, 78868
* en-sv: Tatoeba, 24256
* total size of shuffled dev data: 103084

* devset = top 2500  lines of opus-dev.src.shuffled!
* testset = next 2500  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| newsdev2015-enfi-fien.fi.en 	| 25.5 	| 0.536 |
| newstest2015-enfi-fien.fi.en 	| 26.9 	| 0.545 |
| newstest2016-enfi-fien.fi.en 	| 28.6 	| 0.567 |
| newstest2017-enfi-fien.fi.en 	| 31.9 	| 0.589 |
| newstest2018-enfi-fien.fi.en 	| 23.4 	| 0.514 |
| newstest2019-fien-fien.fi.en 	| 28.5 	| 0.560 |
| newstestB2016-enfi-fien.fi.en 	| 23.8 	| 0.523 |
| newstestB2017-enfi-fien.fi.en 	| 27.2 	| 0.554 |
| newstestB2017-fien-fien.fi.en 	| 27.2 	| 0.554 |
| opus-test.multi.en 	| 58.2 	| 0.721 |

