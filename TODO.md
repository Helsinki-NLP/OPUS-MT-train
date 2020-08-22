
# Things to do


## Bugs

* something is wrong with multi-threaded data preparation
* balancing data for multilingual models does not work well with one lang-pair that is tiny


## General settings

* better hyperparameters for low-resource setting (lower batch sizes, smaller vocabularies ...)
* better data selection (data cleaning / filtering); use opus-filter?
* better balance between general data sets and backtranslations


## Backtranslation

* status: basically working, need better integration?!
* add backtranslations to training data
* can use monolingual data from tokenized wikipedia dumps: https://sites.google.com/site/rmyeid/projects/polyglot
* https://dumps.wikimedia.org/backup-index.html
* better in JSON: https://dumps.wikimedia.org/other/cirrussearch/current/

## Fine-tuning and domain adaptation

* status: basically working
* do we want to publishfine-tuned data or rather the fina-tuning procedures? (using a docker container?)


## Show-case some selected language pairs

* collaboration with wikimedia
* focus languages: Tagalog (tl, tgl), Central Bikol (bcl), Malayalam (ml, mal), Bengali (bn, ben), and Mongolian (mn, mon)


## Tatoeba MT models



Labels are only taken from test data but this can be a problem if there are relevant data sets that will be missed out

* example: nor (there is only nno nob in the test data but most of the data for Norwegian is only tagged as nor_Latn); 
* another example: hbs (hbs labels do not exist in test data)
* possible solution: take all labels from train data; problem: some noisy labels may influence the model a lot and it would be better to leave them out (wrong script data etc); another issue: over-sampling data sets that only exist in train data may damage the model
