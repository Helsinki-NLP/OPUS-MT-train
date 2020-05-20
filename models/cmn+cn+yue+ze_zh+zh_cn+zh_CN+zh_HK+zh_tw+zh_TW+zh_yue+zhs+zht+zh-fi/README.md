# Tatoeba-2020-01-17.zip

* dataset: Tatoeba
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [Tatoeba-2020-01-17.zip](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/Tatoeba-2020-01-17.zip)
* test set translations: [Tatoeba-2020-01-17.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/Tatoeba-2020-01-17.test.txt)
* test set scores: [Tatoeba-2020-01-17.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/Tatoeba-2020-01-17.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.cmn.fi 	| 21.6 	| 0.497 |

# opus-2020-01-20.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-01-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/opus-2020-01-20.zip)
* test set translations: [opus-2020-01-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/opus-2020-01-20.test.txt)
* test set scores: [opus-2020-01-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/opus-2020-01-20.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| bible-uedin.cmn.fi 	| 21.6 	| 0.497 |

# opus-2020-05-20.zip

* dataset: opus
* model: transformer
* source language(s): cmn cn yue ze_zh zh_cn zh_CN zh_HK zh_tw zh_TW zh_yue zhs zht zh
* target language(s): fi
* model: transformer
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus-2020-05-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/opus-2020-05-20.zip)
* test set translations: [opus-2020-05-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/opus-2020-05-20.test.txt)
* test set scores: [opus-2020-05-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/cmn+cn+yue+ze_zh+zh_cn+zh_CN+zh_HK+zh_tw+zh_TW+zh_yue+zhs+zht+zh-fi/opus-2020-05-20.eval.txt)

## Training data:  opus

* cmn-fi: Tatoeba
* cmn-fi: Tatoeba
* fi-yue: Tatoeba wikimedia
* fi-yue: Tatoeba wikimedia
* fi-ze_zh: OpenSubtitles
* fi-ze_zh: OpenSubtitles
* fi-zh_cn: OpenSubtitles
* fi-zh_cn: OpenSubtitles
* fi-zh_CN: GNOME KDE4 Ubuntu
* fi-zh_CN: GNOME KDE4 Ubuntu
* fi-zh_HK: GNOME KDE4 Ubuntu
* fi-zh_HK: GNOME KDE4 Ubuntu
* fi-zh_tw: OpenSubtitles
* fi-zh_tw: OpenSubtitles
* fi-zh_TW: GNOME KDE4 PHP Ubuntu
* fi-zh_TW: GNOME KDE4 PHP Ubuntu
* fi-zh: bible-uedin EUbookshop PHP QED Ubuntu wikimedia
* unused dev/test data is added to training data
* fi-zh: bible-uedin EUbookshop PHP QED Ubuntu wikimedia
* unused dev/test data is added to training data


## Validation data

* cmn-fi: bible-uedin
* cn-fi: bible-uedin
* cmn-fi: bible-uedin
* cmn-fi: bible-uedin
* cn-fi: bible-uedin
* cn-fi: bible-uedin
* fi-yue: bible-uedin
* fi-yue: bible-uedin
* fi-yue: bible-uedin
* fi-ze_zh: bible-uedin
* fi-ze_zh: bible-uedin
* fi-ze_zh: bible-uedin
* fi-zh_cn: bible-uedin
* fi-zh_cn: bible-uedin
* fi-zh_cn: bible-uedin
* fi-zh_CN: bible-uedin
* fi-zh_CN: bible-uedin
* fi-zh_CN: bible-uedin
* fi-zh_HK: bible-uedin
* fi-zh_HK: bible-uedin
* fi-zh_HK: bible-uedin
* fi-zh_tw: bible-uedin
* fi-zh_tw: bible-uedin
* fi-zh_tw: bible-uedin
* fi-zh_TW: bible-uedin
* fi-zh_TW: bible-uedin
* fi-zh_TW: bible-uedin
* fi-zh_yue: bible-uedin
* fi-zh_yue: bible-uedin
* fi-zh_yue: bible-uedin
* fi-zhs: bible-uedin
* fi-zhs: bible-uedin
* fi-zhs: bible-uedin
* fi-zht: bible-uedin
* fi-zht: bible-uedin
* fi-zht: bible-uedin
* fi-zh: infopankki
* fi-zh: infopankki
* fi-zh: infopankki

* devset = top 56220  lines of opus-dev.src.shuffled!
* testset = next 2500  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

* devset = top 2500  lines of opus-dev.src.shuffled!
* testset = next 2500  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

* devset = top 2500  lines of opus-dev.src.shuffled!
* testset = next 2500  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| opus-test.cmn.fi 	| 64.3 	| 0.693 |

