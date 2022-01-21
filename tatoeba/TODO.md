

# Pivot-based data augmentation

* pbt: pivot-back-translated (e.g. translate eng to swe to change fin-eng into fin-swe training data)
* pft: pivot-forward-translated (e.g. translate eng to fin to change eng-swe into fin-swe training data)
* pivotalign: merge fin-eng and eng-swe into fin-swe training data by simply matching eng sentences (see OPUS)
* pftonly pbtonly paonly: targets to use only those pivot-based data sets (no standard train data) (--> distillation)


# Cleanup and documentation

* cleanup / remove complicated testset evaluation for multilingual models
* cleanup recipes for tatoeba model training
* improve documentation
* tutorials


# Evaluation

* better link information about evaluation of released models (see eval subdir)
* integrate NMT map (move to OPUS-MT-map)
* better score tables / leaderboards for released NMT models


# Knowledge distillation and compact models

* systematically test model architectures
* multilingual distillation
* better data selection for student models
* quantization and tuned int8 models (train alphas) - see browsermt/students
* lexical shortlists
* better integration into translateLocally / OPUS-MT-app