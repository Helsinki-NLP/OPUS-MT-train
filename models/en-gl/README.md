# opus-2019-12-04.zip

* dataset: opus
* model: transformer
* pre-processing: normalization + tokenization + BPE
* download: [opus-2019-12-04.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus-2019-12-04.zip)
* test set translations: [opus-2019-12-04.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus-2019-12-04.test.txt)
* test set scores: [opus-2019-12-04.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus-2019-12-04.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.gl 	| 42.1 	| 0.643 |

# opus-2019-12-18.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2019-12-18.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus-2019-12-18.zip)
* test set translations: [opus-2019-12-18.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus-2019-12-18.test.txt)
* test set scores: [opus-2019-12-18.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus-2019-12-18.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.gl 	| 36.4 	| 0.572 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): en
* target language(s): gl
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/en-gl/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* en-gl: GNOME (3200) KDE4 (67826) OpenSubtitles (126339) QED (26362) Ubuntu (3155) wiki.ab.gl-en (942708) wikibooks.aa.gl-en (11039) wikiquote.aa.gl-en (3871) wikisource.aa.gl-en (21560) 
* en-gl: total size = 1206060
* total size (opus+bt): 1205526


## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.en.gl 	| 43.5 	| 0.641 |

