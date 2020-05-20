# opus-2020-01-16.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* a sentence initial language token is required in the form of `>>id<<` (id = valid target language ID)
* download: [opus-2020-01-16.zip](https://object.pouta.csc.fi/OPUS-MT-models/fi-cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh/opus-2020-01-16.zip)
* test set translations: [opus-2020-01-16.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi-cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh/opus-2020-01-16.test.txt)
* test set scores: [opus-2020-01-16.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi-cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh/opus-2020-01-16.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.fi.zh 	| 23.4 	| 0.326 |

# opus-2020-05-20.zip

* dataset: opus
* model: transformer
* source language(s): fi
* target language(s): cmn cn yue ze_zh zh_cn zh_CN zh_HK zh_tw zh_TW zh_yue zhs zht zh
* model: transformer
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* a sentence initial language token is required in the form of `>>id<<` (id = valid target language ID)
* download: [opus-2020-05-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/fi-cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh/opus-2020-05-20.zip)
* test set translations: [opus-2020-05-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi-cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh/opus-2020-05-20.test.txt)
* test set scores: [opus-2020-05-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi-cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh/opus-2020-05-20.eval.txt)

## Training data:  opus

* cmn-fi: Tatoeba
* fi-yue: Tatoeba wikimedia
* fi-ze_zh: OpenSubtitles
* fi-zh_cn: OpenSubtitles
* fi-zh_CN: GNOME KDE4 Ubuntu
* fi-zh_HK: GNOME KDE4 Ubuntu
* fi-zh_tw: OpenSubtitles
* fi-zh_TW: GNOME KDE4 PHP Ubuntu
* fi-zh: bible-uedin EUbookshop PHP QED Ubuntu wikimedia
* unused dev/test data is added to training data


## Validation data

* cmn-fi: bible-uedin
* cn-fi: bible-uedin
* fi-yue: bible-uedin
* fi-ze_zh: bible-uedin
* fi-zh_cn: bible-uedin
* fi-zh_CN: bible-uedin
* fi-zh_HK: bible-uedin
* fi-zh_tw: bible-uedin
* fi-zh_TW: bible-uedin
* fi-zh_yue: bible-uedin
* fi-zhs: bible-uedin
* fi-zht: bible-uedin
* fi-zh: infopankki

* devset = top 2500  lines of opus-dev.src.shuffled!
* testset = next 2500  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| opus-test.fi.zh 	| 33.9 	| 0.367 |

