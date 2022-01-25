# -*-makefile-*-
#
#


STUDENT_CEFILTER  = 95
STUDENT_VOCAB = separate-spm
# STUDENT_VOCAB = joint-spm

ifeq (${HPC_HOST},mahti)
  STUDENT_HPCPARAMS = CPUJOB_HPC_CORES=128 CPUJOB_HPC_MEM=128g CPUJOB_HPC_JOBS=20
else
  STUDENT_HPCPARAMS = CPUJOB_HPC_CORES=4 CPUJOB_HPC_MEM=64g
endif


#-------------------------------------------------------------------------
# train a student model:
#
# "all-job" recipe will first create the data (run on CPU with submitcpu)
# and then submit a train job to run on a GPU node (submit)
#
# ftbest = ce-filtered forward translations (FT_SELECTED = percentage of data to keep)
# nopar = don't use original parallel corpora
# separate-spm = separate sentence piece models and separate vacbabularies 
#-------------------------------------------------------------------------


## example for how to call generic train and test recipes 
## for specific language pairs:

fineng-train-student:
	make SRCLANGS=fin TRGLANGS=eng train-tiny11-student

fineng-test-student:
	make SRCLANGS=fin TRGLANGS=eng test-tiny11-student



## generic recipes for training and testing student models

train-student:
	make ${STUDENT_HPCPARAMS} FT_SELECTED=${STUDENT_CEFILTER} \
		all-job-ftbest-nopar-${STUDENT_VOCAB}-tatoeba

test-student:
	make FT_SELECTED=${STUDENT_CEFILTER} HPC_MEM=20g WALLTIME=2 \
		eval-ftbest-nopar-${STUDENT_VOCAB}-tatoeba.submit \
		eval-testsets-ftbest-nopar-${STUDENT_VOCAB}-tatoeba.submit

release-student:
	make ${STUDENT_HPCPARAMS} FT_SELECTED=${STUDENT_CEFILTER} \
		release-ftbest-nopar-${STUDENT_VOCAB}-tatoeba

quantize-student:
	make FT_SELECTED=${STUDENT_CEFILTER} HPC_MEM=20g WALLTIME=2 \
		lexical-shortlist-ftbest-nopar-${STUDENT_VOCAB}-tatoeba \
		quantize-ftbest-nopar-${STUDENT_VOCAB}-tatoeba \
		quantize-alphas-ftbest-nopar-${STUDENT_VOCAB}-tatoeba

quantize-finetuned-student:
	make FT_SELECTED=${STUDENT_CEFILTER} HPC_MEM=20g WALLTIME=2 \
		quantize-tuned-alphas-ftbest-nopar-${STUDENT_VOCAB}-tatoeba


test-quantized-student:
	make FT_SELECTED=${STUDENT_CEFILTER} HPC_MEM=20g WALLTIME=2 \
		test-intgemm8-all-ftbest-nopar-${STUDENT_VOCAB}-tatoeba \
		test-intgemm8-all-shortlist-ftbest-nopar-${STUDENT_VOCAB}-tatoeba

test-quantized-finetuned-student:
	make FT_SELECTED=${STUDENT_CEFILTER} HPC_MEM=20g WALLTIME=2 \
		test-intgemm8-alltuned-ftbest-nopar-${STUDENT_VOCAB}-tatoeba \
		test-intgemm8-alltuned-shortlist-ftbest-nopar-${STUDENT_VOCAB}-tatoeba





## different kinds of model types

%-tiny-student:
	${MAKE} MODELTYPE=transformer-tiny-align ${@:tiny-student=student}

%-tiny11-student:
	${MAKE} MODELTYPE=transformer-tiny11-align ${@:tiny11-student=student}

%-small-student:
	${MAKE} MODELTYPE=transformer-small-align ${@:small-student=student}







## before we can train we need to generate the training data
## (forward translations by a strong teacher model)
## NOTE: this only works for tatoeba models now!
##
## fetch the teacher model and prepare data
## forward translate data
## score with a reverse translation model
## sort by normalised score for ce-filtering
##
## TODO: should automate this more ...
##       (all in one recipe?)
## ---> make -C forward-translate SRC=fin TRG=swe all

# make -C forward-translate SRC=fin TRG=swe prepare
# make -C forward-translate HPC_MEM=20g SRC=fin TRG=swe translate-all-parts.submit
# make -C forward-translate HPC_MEM=24g SRC=fin TRG=swe score-translations.submit
# make -C forward-translate sort-scored-translations







# ### OLD #####

# ## train Afrikaans-English
# ## - only with forward-translated data
# ## - on the previous Tatoeba data set (to compare with other score)

# afreng-ft:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 	all-job-ft-train-only-tatoeba

# afreng-ft-small:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-ft-train-only-tatoeba

# afreng-ft-tiny:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-ft-train-only-tatoeba


# ## train Afrikaans-English
# ## - with forward-translated data
# ## - and back-translated data
# ## - on the previous Tatoeba data set (to compare with other score)

# afreng-ft-bt:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 	all-job-ft-train-only-bt-tatoeba

# afreng-ft-bt-small:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-ft-train-only-bt-tatoeba

# afreng-ft-bt-tiny:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-ft-train-only-bt-tatoeba


# ## for comparison: small/tiny without forward translations

# afreng-bt-small:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# afreng-bt-tiny:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba




# afreng:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 	all-job-tatoeba


# afreng-small:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-tatoeba

# afreng-tiny:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-tatoeba

# afreng-small-eval:
# 	make 	TATOEBA_VERSION=v2020-07-28 \
# 		BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=afr TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	eval-tatoeba





# ## small models for Finnish-English

# small-fineng-finswe: 	fineng-bt-small fineng-bt-tiny \
# 			engfin-bt-small engfin-bt-tiny \
# 			finswe-bt-small finswe-bt-tiny \
# 			swefin-bt-small swefin-bt-tiny

# fineng-bt-small:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=fin TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# fineng-bt-tiny:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=fin TRGLANGS=eng \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# engfin-bt-small:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=eng TRGLANGS=fin \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# engfin-bt-tiny:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=eng TRGLANGS=fin \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba


# ## small models for Finnish-Swedish

# finswe-bt-small:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=fin TRGLANGS=swe \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# finswe-bt-tiny:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=fin TRGLANGS=swe \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# swefin-bt-small:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=swe TRGLANGS=fin \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba

# swefin-bt-tiny:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=swe TRGLANGS=fin \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	all-job-bt-tatoeba





# test-engfin-small:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=eng TRGLANGS=fin \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	eval-testsets-bt-tatoeba

# test-engfin-tiny:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=eng TRGLANGS=fin \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	eval-testsets-bt-tatoeba

# test-fineng-small:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=fin TRGLANGS=eng \
# 		MODELTYPE=transformer-small-align \
# 		MARIAN_WORKSPACE=10000 \
# 	eval-testsets-bt-tatoeba

# test-fineng-tiny:
# 	make	BT_CONTINUE_EXISTING=0 \
# 		SRCLANGS=fin TRGLANGS=eng \
# 		MODELTYPE=transformer-tiny-align \
# 		MARIAN_WORKSPACE=10000 \
# 	eval-testsets-bt-tatoeba
