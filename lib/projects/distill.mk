# -*-makefile-*-
#
#


STUDENT_MODELTYPE = transformer-tiny11-align

ifeq (${HPC_HOST},mahti)
  STUDENT_HPCPARAMS_CPU = HPC_CORES=128 HPC_MEM=128g HPC_JOBS=20
else
  STUDENT_HPCPARAMS_CPU = HPC_CORES=4 HPC_MEM=64g
endif

train-student:
	make ${STUDENT_HPCPARAMS_CPU} MODELTYPE=${STUDENT_MODELTYPE} \
	all-job-ftbest-nopar-separate-spm-tatoeba.submitcpu

fineng-student:
	make SRCLANGS=fin TRGLANGS=eng train-student

finswe-student:
	make SRCLANGS=fin TRGLANGS=swe train-student

swefin-student:
	make SRCLANGS=swe TRGLANGS=fin train-student







### OLD #####

## train Afrikaans-English
## - only with forward-translated data
## - on the previous Tatoeba data set (to compare with other score)

afreng-ft:
	make 	TATOEBA_VERSION=v2020-07-28 \
		SRCLANGS=afr TRGLANGS=eng \
	all-job-ft-train-only-tatoeba

afreng-ft-small:
	make 	TATOEBA_VERSION=v2020-07-28 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-ft-train-only-tatoeba

afreng-ft-tiny:
	make 	TATOEBA_VERSION=v2020-07-28 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-ft-train-only-tatoeba


## train Afrikaans-English
## - with forward-translated data
## - and back-translated data
## - on the previous Tatoeba data set (to compare with other score)

afreng-ft-bt:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
	all-job-ft-train-only-bt-tatoeba

afreng-ft-bt-small:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-ft-train-only-bt-tatoeba

afreng-ft-bt-tiny:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-ft-train-only-bt-tatoeba


## for comparison: small/tiny without forward translations

afreng-bt-small:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

afreng-bt-tiny:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba




afreng:
	make 	TATOEBA_VERSION=v2020-07-28 \
		SRCLANGS=afr TRGLANGS=eng \
	all-job-tatoeba


afreng-small:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-tatoeba

afreng-tiny:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-tatoeba

afreng-small-eval:
	make 	TATOEBA_VERSION=v2020-07-28 \
		BT_CONTINUE_EXISTING=0 \
		SRCLANGS=afr TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	eval-tatoeba





## small models for Finnish-English

small-fineng-finswe: 	fineng-bt-small fineng-bt-tiny \
			engfin-bt-small engfin-bt-tiny \
			finswe-bt-small finswe-bt-tiny \
			swefin-bt-small swefin-bt-tiny

fineng-bt-small:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=fin TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

fineng-bt-tiny:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=fin TRGLANGS=eng \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

engfin-bt-small:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=eng TRGLANGS=fin \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

engfin-bt-tiny:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=eng TRGLANGS=fin \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba


## small models for Finnish-Swedish

finswe-bt-small:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=fin TRGLANGS=swe \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

finswe-bt-tiny:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=fin TRGLANGS=swe \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

swefin-bt-small:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=swe TRGLANGS=fin \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba

swefin-bt-tiny:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=swe TRGLANGS=fin \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	all-job-bt-tatoeba





test-engfin-small:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=eng TRGLANGS=fin \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	eval-testsets-bt-tatoeba

test-engfin-tiny:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=eng TRGLANGS=fin \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	eval-testsets-bt-tatoeba

test-fineng-small:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=fin TRGLANGS=eng \
		MODELTYPE=transformer-small-align \
		MARIAN_WORKSPACE=10000 \
	eval-testsets-bt-tatoeba

test-fineng-tiny:
	make	BT_CONTINUE_EXISTING=0 \
		SRCLANGS=fin TRGLANGS=eng \
		MODELTYPE=transformer-tiny-align \
		MARIAN_WORKSPACE=10000 \
	eval-testsets-bt-tatoeba
