# opus+bt-2020-05-20.zip

* dataset: opus+bt
* model: transformer
* source language(s): fi
* target language(s): fa
* model: transformer
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* download: [opus+bt-2020-05-20.zip](https://object.pouta.csc.fi/OPUS-MT-models/fi-fa/opus+bt-2020-05-20.zip)
* test set translations: [opus+bt-2020-05-20.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi-fa/opus+bt-2020-05-20.test.txt)
* test set scores: [opus+bt-2020-05-20.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/fi-fa/opus+bt-2020-05-20.eval.txt)

## Training data:  opus+bt

* fa-fi: GNOME JW300 KDE4 OpenSubtitles QED Ubuntu wikimedia
* fa-fi backtranslations: backtranslate/fa-fi/latest/wiki.aa.fa-fi backtranslate/fa-fi/latest/wikinews.aa.fa-fi backtranslate/fa-fi/latest/wikiquote.aa.fa-fi
* unused dev/test data is added to training data


## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| infopankki.fi.fa 	| 48.9 	| 0.673 |

