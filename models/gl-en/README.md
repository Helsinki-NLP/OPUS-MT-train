# opus-2019-12-05.zip

* dataset: opus
* model: transformer
* pre-processing: normalization + tokenization + BPE
* download: [opus-2019-12-05.zip](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2019-12-05.zip)
* test set translations: [opus-2019-12-05.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2019-12-05.test.txt)
* test set scores: [opus-2019-12-05.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2019-12-05.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.gl.en 	| 43.4 	| 0.608 |

# opus-2019-12-18.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2019-12-18.zip](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2019-12-18.zip)
* test set translations: [opus-2019-12-18.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2019-12-18.test.txt)
* test set scores: [opus-2019-12-18.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2019-12-18.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.gl.en 	| 42.5 	| 0.604 |

# opus-2020-05-09.zip

* dataset: opus
* model: transformer-align
* pre-processing: normalization + SentencePiece
* download: [opus-2020-05-09.zip](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2020-05-09.zip)
* test set translations: [opus-2020-05-09.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2020-05-09.test.txt)
* test set scores: [opus-2020-05-09.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus-2020-05-09.eval.txt)

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.gl.en 	| 42.4 	| 0.612 |

# opus+bt-2020-05-23.zip

* dataset: opus+bt
* model: transformer-align
* source language(s): gl
* target language(s): en
* model: transformer-align
* pre-processing: normalization + SentencePiece (spm4k,spm4k)
* download: [opus+bt-2020-05-23.zip](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus+bt-2020-05-23.zip)
* test set translations: [opus+bt-2020-05-23.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus+bt-2020-05-23.test.txt)
* test set scores: [opus+bt-2020-05-23.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/gl-en/opus+bt-2020-05-23.eval.txt)

## Training data:  opus+bt

* gl-en: GNOME (3200) KDE4 (67826) OpenSubtitles (126339) QED (26362) Ubuntu (3155) 
* gl-en: total size = 226882
* total size (opus+bt): 226522


## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| Tatoeba.gl.en 	| 44.0 	| 0.618 |

