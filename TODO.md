
# Things to do


## data preparation

* do temperature-based balanced sampling (see https://arxiv.org/pdf/1907.05019.pdf)


## slurm job pipelines

Create slurm jobs with dependencies to create pipelines of jobs.
(add --dependencies to sbatch)
see https://hpc.nih.gov/docs/job_dependencies.html
https://hpc.nih.gov/docs/userguide.html#depend
grep for job is (pattern: 'Submitted batch job 946074')


## Issues

* racing situations in work/data with jobs that fetch data for the same language pairs!
* get rid of BPE to simplify the scripts


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
* do we want to publish fine-tuned data or rather the fina-tuning procedures? (using a docker container?)


## Show-case some selected language pairs

* collaboration with wikimedia
* focus languages: Tagalog (tl, tgl), Central Bikol (bcl), Malayalam (ml, mal), Bengali (bn, ben), and Mongolian (mn, mon)



# Other requests

* Hebrew-->English and Hebrew-->Russian (Shaul Dar)