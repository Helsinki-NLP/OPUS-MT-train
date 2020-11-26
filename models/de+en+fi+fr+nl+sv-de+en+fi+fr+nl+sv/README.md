# opus-2020-10-04.zip

* dataset: opus
* model: transformer
* source language(s): de en fi fr nl sv
* target language(s): de en fi fr nl sv
* model: transformer
* pre-processing: normalization + SentencePiece (spm32k,spm32k)
* a sentence initial language token is required in the form of `>>id<<` (id = valid target language ID)
* download: [opus-2020-10-04.zip](https://object.pouta.csc.fi/OPUS-MT-models/de+en+fi+fr+nl+sv-de+en+fi+fr+nl+sv/opus-2020-10-04.zip)
* test set translations: [opus-2020-10-04.test.txt](https://object.pouta.csc.fi/OPUS-MT-models/de+en+fi+fr+nl+sv-de+en+fi+fr+nl+sv/opus-2020-10-04.test.txt)
* test set scores: [opus-2020-10-04.eval.txt](https://object.pouta.csc.fi/OPUS-MT-models/de+en+fi+fr+nl+sv-de+en+fi+fr+nl+sv/opus-2020-10-04.eval.txt)

## Training data:  opus

* de-en: 
* de-fi: 
* de-fr: 
* de-nl: 
* de-sv: 
* en-de: 
* en-fi: 
* en-fr: 
* en-nl: 
* en-sv: 
* fi-de: 
* fi-en: 
* fi-fr: 
* fi-nl: 
* fi-sv: 
* fr-de: 
* fr-en: 
* fr-fi: 
* fr-nl: 
* fr-sv: 
* nl-de: 
* nl-en: 
* nl-fi: 
* nl-fr: 
* nl-sv: 
* sv-de: 
* sv-en: 
* sv-fi: 
* sv-fr: 
* sv-nl: 
* unused dev/test data is added to training data
* total size (opus): 501437198


## Validation data

* de-en: OpenSubtitles, 21508596
* de-fi: OpenSubtitles, 12641471
* de-fr: OpenSubtitles, 15031870
* de-nl: OpenSubtitles, 14722152
* de-sv: OpenSubtitles, 8785182
* de-en: OpenSubtitles, 21508596
* en-fi: OpenSubtitles, 26457741
* en-fr: OpenSubtitles, 39527656
* en-nl: OpenSubtitles, 35049286
* en-sv: OpenSubtitles, 16169056
* de-fi: OpenSubtitles, 12641471
* en-fi: OpenSubtitles, 26457741
* fi-fr: OpenSubtitles, 18216582
* fi-nl: OpenSubtitles, 19868494
* fi-sv: OpenSubtitles, 13138133
* de-fr: OpenSubtitles, 15031870
* en-fr: OpenSubtitles, 39527656
* fi-fr: OpenSubtitles, 18216582
* fr-nl: OpenSubtitles, 23406778
* fr-sv: OpenSubtitles, 11422393
* de-nl: OpenSubtitles, 14722152
* en-nl: OpenSubtitles, 35049286
* fi-nl: OpenSubtitles, 19868494
* fr-nl: OpenSubtitles, 23406778
* nl-sv: OpenSubtitles, 12642707
* de-sv: OpenSubtitles, 8785182
* en-sv: OpenSubtitles, 16169056
* fi-sv: OpenSubtitles, 13138133
* fr-sv: OpenSubtitles, 11422393
* nl-sv: OpenSubtitles, 12642707
* total size of shuffled dev data: 501506812

* devset = top 2500  lines of opus-dev.src.shuffled!
* testset = next 2500  lines of opus-dev.src.shuffled!
* remaining lines are added to traindata

## Benchmarks

| testset               | BLEU  | chr-F |
|-----------------------|-------|-------|
| euelections_dev2019.de-fr-defr.de.fr 	| 16.5 	| 0.447 |
| euelections_dev2019.fr-de-frde.fr.de 	| 14.7 	| 0.439 |
| fiskmo_testset-fisv.fi.sv 	| 10.5 	| 0.394 |
| fiskmo_testset-svfi.sv.fi 	| 7.4 	| 0.402 |
| goethe-institute-test1-defi.de.fi 	| 9.7 	| 0.381 |
| goethe-institute-test2-defi.de.fi 	| 9.6 	| 0.376 |
| newsdev2015-enfi-enfi.en.fi 	| 11.3 	| 0.423 |
| newsdev2015-enfi-fien.fi.en 	| 17.3 	| 0.453 |
| newsdiscussdev2015-enfr-enfr.en.fr 	| 26.6 	| 0.532 |
| newsdiscussdev2015-enfr-fren.fr.en 	| 24.3 	| 0.512 |
| newsdiscusstest2015-enfr-enfr.en.fr 	| 29.4 	| 0.552 |
| newsdiscusstest2015-enfr-fren.fr.en 	| 26.6 	| 0.521 |
| newssyscomb2009-deen.de.en 	| 18.6 	| 0.468 |
| newssyscomb2009-defr.de.fr 	| 16.6 	| 0.449 |
| newssyscomb2009-ende.en.de 	| 14.7 	| 0.448 |
| newssyscomb2009-enfr.en.fr 	| 21.5 	| 0.502 |
| newssyscomb2009-frde.fr.de 	| 14.3 	| 0.438 |
| newssyscomb2009-fren.fr.en 	| 22.0 	| 0.498 |
| news-test2008-deen.de.en 	| 18.4 	| 0.464 |
| news-test2008-defr.de.fr 	| 16.3 	| 0.443 |
| news-test2008-ende.en.de 	| 15.1 	| 0.437 |
| news-test2008-enfr.en.fr 	| 19.2 	| 0.477 |
| news-test2008-frde.fr.de 	| 14.1 	| 0.431 |
| news-test2008-fren.fr.en 	| 18.9 	| 0.474 |
| newstest2009-deen.de.en 	| 17.6 	| 0.454 |
| newstest2009-defr.de.fr 	| 15.7 	| 0.434 |
| newstest2009-ende.en.de 	| 14.4 	| 0.439 |
| newstest2009-enfr.en.fr 	| 20.2 	| 0.487 |
| newstest2009-frde.fr.de 	| 13.9 	| 0.428 |
| newstest2009-fren.fr.en 	| 20.6 	| 0.484 |
| newstest2010-deen.de.en 	| 20.1 	| 0.484 |
| newstest2010-defr.de.fr 	| 17.3 	| 0.457 |
| newstest2010-ende.en.de 	| 15.7 	| 0.449 |
| newstest2010-enfr.en.fr 	| 22.4 	| 0.506 |
| newstest2010-frde.fr.de 	| 13.9 	| 0.432 |
| newstest2010-fren.fr.en 	| 22.5 	| 0.507 |
| newstest2011-deen.de.en 	| 17.9 	| 0.463 |
| newstest2011-defr.de.fr 	| 16.5 	| 0.444 |
| newstest2011-ende.en.de 	| 14.4 	| 0.435 |
| newstest2011-enfr.en.fr 	| 23.1 	| 0.515 |
| newstest2011-frde.fr.de 	| 13.6 	| 0.422 |
| newstest2011-fren.fr.en 	| 22.9 	| 0.510 |
| newstest2012-deen.de.en 	| 19.2 	| 0.469 |
| newstest2012-defr.de.fr 	| 16.8 	| 0.445 |
| newstest2012-ende.en.de 	| 14.6 	| 0.436 |
| newstest2012-enfr.en.fr 	| 22.2 	| 0.505 |
| newstest2012-frde.fr.de 	| 14.1 	| 0.422 |
| newstest2012-fren.fr.en 	| 23.1 	| 0.506 |
| newstest2013-deen.de.en 	| 21.3 	| 0.486 |
| newstest2013-defr.de.fr 	| 18.7 	| 0.453 |
| newstest2013-ende.en.de 	| 17.8 	| 0.464 |
| newstest2013-enfr.en.fr 	| 23.9 	| 0.505 |
| newstest2013-frde.fr.de 	| 15.7 	| 0.438 |
| newstest2013-fren.fr.en 	| 23.6 	| 0.506 |
| newstest2014-deen-deen.de.en 	| 20.7 	| 0.485 |
| newstest2014-fren-fren.fr.en 	| 25.5 	| 0.537 |
| newstest2015-ende-deen.de.en 	| 23.2 	| 0.501 |
| newstest2015-ende-ende.en.de 	| 21.4 	| 0.493 |
| newstest2015-enfi-enfi.en.fi 	| 13.2 	| 0.445 |
| newstest2015-enfi-fien.fi.en 	| 18.9 	| 0.463 |
| newstest2016-ende-deen.de.en 	| 25.8 	| 0.528 |
| newstest2016-ende-ende.en.de 	| 22.5 	| 0.505 |
| newstest2016-enfi-enfi.en.fi 	| 14.0 	| 0.446 |
| newstest2016-enfi-fien.fi.en 	| 19.4 	| 0.478 |
| newstest2017-ende-deen.de.en 	| 24.4 	| 0.511 |
| newstest2017-ende-ende.en.de 	| 20.0 	| 0.486 |
| newstest2017-enfi-enfi.en.fi 	| 15.6 	| 0.466 |
| newstest2017-enfi-fien.fi.en 	| 21.7 	| 0.496 |
| newstest2018-ende-deen.de.en 	| 28.4 	| 0.542 |
| newstest2018-ende-ende.en.de 	| 26.6 	| 0.537 |
| newstest2018-enfi-enfi.en.fi 	| 11.1 	| 0.421 |
| newstest2018-enfi-fien.fi.en 	| 16.1 	| 0.438 |
| newstest2019-deen-deen.de.en 	| 22.5 	| 0.499 |
| newstest2019-defr-defr.de.fr 	| 17.0 	| 0.460 |
| newstest2019-ende-ende.en.de 	| 25.3 	| 0.523 |
| newstest2019-enfi-enfi.en.fi 	| 14.1 	| 0.438 |
| newstest2019-fien-fien.fi.en 	| 19.7 	| 0.470 |
| newstest2019-frde-frde.fr.de 	| 14.9 	| 0.454 |
| newstestB2016-enfi-enfi.en.fi 	| 11.2 	| 0.422 |
| newstestB2016-enfi-fien.fi.en 	| 15.9 	| 0.443 |
| newstestB2017-enfi-enfi.en.fi 	| 12.7 	| 0.437 |
| newstestB2017-enfi-fien.fi.en 	| 18.6 	| 0.467 |
| newstestB2017-fien-fien.fi.en 	| 18.6 	| 0.467 |
| opus-test.multi.multi 	| 24.1 	| 0.439 |
| simplification-enen.en.en 	| 49.6 	| 0.714 |

