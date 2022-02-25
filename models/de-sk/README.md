# opus_transformer-align_2022-02-19.zip

* dataset: opus
* model: transformer-align
* source language(s): de
* target language(s): sk
* raw source language(s): de
* raw target language(s): sk
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus_transformer-align_2022-02-19.zip](https://object.pouta.csc.fi/OPUS-MT-models/de-sk/opus_transformer-align_2022-02-19.zip)
## Training data:  opus

* de-sk: CCMatrix.de-sk.strict (24693931) DGT.de-sk.strict (3897093) ECB.de-sk.strict (86068) ELITR-ECA.de-sk.strict (43365) EMEA.de-sk.strict (747856) EUbookshop.de-sk.strict (335128) EUconst.de-sk.strict (6115) GNOME.de-sk.strict (127) JRC-Acquis.de-sk.strict (28389) KDE4.de-sk.strict (72205) KDEdoc.de-sk.strict (10801) MultiCCAligned.de-sk.strict (2415997) MultiParaCrawl.de-sk.strict (5281070) OpenSubtitles.de-sk.strict (3287374) PHP.de-sk.strict (25834) QED.de-sk.strict (130746) TED2020.de-sk.strict (93826) TildeMODEL.de-sk.strict (2011415) Ubuntu.de-sk.strict (1859) WikiMatrix.de-sk.strict (91079) XLEnt.de-sk.strict (229529) bible-uedin.de-sk.strict (30627) wikimedia.de-sk.strict (410) 
* de-sk: total size = 43520844
* unused dev/test data is added to training data
* total size (opus): 43548640


## Validation data

* de-sk: Europarl, 563387
* total-size-shuffled: 550326

* devset-selected: top 2500  lines of Europarl.src.shuffled
* testset-selected: next 2500  lines of Europarl.src.shuffled 
* devset-unused: added to traindata

* test set translations: [opus_transformer-align_2022-02-19.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/de-sk/opus_transformer-align_2022-02-19.test.txt)
* test set scores: [opus_transformer-align_2022-02-19.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/de-sk/opus_transformer-align_2022-02-19.eval.txt)

## Benchmarks

| testset | BLEU  | chr-F | #sent | #words | BP |
|---------|-------|-------|-------|--------|----|
| Europarl.de-sk 	| 29.2 	| 0.56574 	| 2500 	| 59265 	| 0.977 |

