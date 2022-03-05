# -*-makefile-*-

##------------------------------------------------------------------------------------
## make data and start a job for
## fine-tuning a mulitlingual tatoeba model
## for a specific language pair
## set SRC and TRG to specify the language pair, e.g.
##
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtune
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunedist
##
## (makes only sense if there is already such a pre-trained multilingual model)
## langtune for all language combinations:
##
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtuneall
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunealldist
##
## start langtunejobs:
##
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunejob
##   make TUNE_SRC=bel TUNE_TRG=nld tatoeba-zle2gmw-langtunealljobs
##------------------------------------------------------------------------------------

TATOEBA_LANGTUNE_PARAMS = CONTINUE_EXISTING=1 \
			MARIAN_VALID_FREQ=${TUNE_VALID_FREQ} \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EARLY_STOPPING=${TUNE_EARLY_STOPPING} \
			MARIAN_EXTRA='-e 5 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} \
			TATOEBA_DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} \
			TATOEBA_DEVSET_NAME=${TATOEBA_DEVSET}.${TUNE_SRC}-${TUNE_TRG} \
			TATOEBA_TESTSET_NAME=${TATOEBA_TESTSET}.${TUNE_SRC}-${TUNE_TRG} \
			SRCLANGS="${TUNE_SRC}" \
			TRGLANGS="${TUNE_TRG}"

#			LANGPAIRSTR=${LANGPAIRSTR}


TATOEBA_DOMAINTUNE_PARAMS = 	CONTINUE_EXISTING=1 \
			SKIP_VALIDATION=1 \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EXTRA='-e 1 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			FIT_DATA_SIZE=${TUNE_FIT_DATA_SIZE} \
			TATOEBA_TRAINSET=Tatoeba-${TUNE_DOMAIN}-train \
			TATOEBA_DATASET=${DATASET}-tuned4${TUNE_DOMAIN} \
			DATASET=${DATASET}-tuned4${TUNE_DOMAIN}

TATOEBA_TUNE_PARAMS = CONTINUE_EXISTING=1 \
			MARIAN_VALID_FREQ=${TUNE_VALID_FREQ} \
			MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
			MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
			MARIAN_EARLY_STOPPING=${TUNE_EARLY_STOPPING} \
			MARIAN_EXTRA='-e 5 --no-restore-corpus' \
			GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
			DATASET=${DATASET}-tuned4${TUNE_TRAINSET} \
			TATOEBA_DATASET=${DATASET}-tuned4${TUNE_TRAINSET} \
			TATOEBA_TRAINSET=${TUNE_TRAINSET} \
			TATOEBA_DEVSET_NAME=${TUNE_DEVSET} \
			TATOEBA_TESTSET_NAME=${TUNE_TESTSET}


tatoeba-%-tune: tatoeba-%-data
	${MAKE} ${TATOEBA_TUNE_PARAMS} ${patsubst tatoeba-%-tune,tatoeba-%-train,$@}

tatoeba-%-tuneeval:
	${MAKE} ${TATOEBA_TUNE_PARAMS} ${patsubst tatoeba-%-tuneeval,tatoeba-%-evalall,$@}

tatoeba-%-tunedist:
	${MAKE} ${TATOEBA_TUNE_PARAMS} ${patsubst tatoeba-%-tunedist,tatoeba-%-dist,$@}



tatoeba-%-domaintune: tatoeba-%-data
	${MAKE} ${TATOEBA_DOMAINTUNE_PARAMS} ${patsubst tatoeba-%-domaintune,tatoeba-%-train,$@}

tatoeba-%-domaintuneeval:
	${MAKE} ${TATOEBA_DOMAINTUNE_PARAMS} ${patsubst tatoeba-%-domaintuneeval,tatoeba-%-evalall,$@}

tatoeba-%-domaintunedist:
	${MAKE} ${TATOEBA_DOMAINTUNE_PARAMS} ${patsubst tatoeba-%-domaintunedist,tatoeba-%-dist,$@}



tatoeba-langtune:
	${MAKE} ${TATOEBA_LANGTUNE_PARAMS} tatoeba

tatoeba-langtuneeval:
	${MAKE} ${TATOEBA_LANGTUNE_PARAMS} \
		compare-tatoeba \
		tatoeba-multilingual-eval \
		tatoeba-sublang-eval \
		eval-testsets-tatoeba

tatoeba-langtunedist:
	${MAKE} ${TATOEBA_LANGTUNE_PARAMS} release-tatoeba

tatoeba-%-langtune:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtune,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtune,%,$@))); \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t ${TATOEBA_LANGTUNE_PARAMS} tatoeba-all; \
	  fi )

#		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-langtune,%,$@},${PIVOT}}" \
#		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-langtune,%,$@},${PIVOT}}" \

tatoeba-%-langtunejob:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunejob,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunejob,%,$@))); \
	  if [ -d ${WORKHOME}/$$s-$$t ]; then \
	    ${MAKE} LANGPAIRSTR=$$s-$$t ${TATOEBA_LANGTUNE_PARAMS} tatoeba-job; \
	  fi )

#		SRCLANGS="${call find-srclanggroup,${patsubst tatoeba-%-langtunejob,%,$@},${PIVOT}}" \
#		TRGLANGS="${call find-trglanggroup,${patsubst tatoeba-%-langtunejob,%,$@},${PIVOT}}" \

tatoeba-%-langtuneeval:
	${MAKE} DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} ${@:-langtuneeval=-evalall}

tatoeba-%-langtunedist:
	${MAKE} DATASET=${DATASET}-tuned4${TUNE_SRC}2${TUNE_TRG} ${@:-langtunedist=-dist}

tatoeba-%-langtuneall:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtuneall,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtuneall,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-langtuneall,%,$@},''}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-langtuneall,%,$@},''}"; \
	  for a in $$S; do \
	    for b in $$T; do \
	      if [ "$$a" != "$$b" ]; then \
	        ${MAKE} TUNE_SRC=$$a TUNE_TRG=$$b ${@:-langtuneall=-langtune}; \
	      fi \
	    done \
	  done )

tatoeba-%-langtunealldist:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunealldist,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunealldist,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-langtunealldist,%,$@},''}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-langtunealldist,%,$@},''}"; \
	  for a in $$S; do \
	    for b in $$T; do \
	      if [ "$$a" != "$$b" ]; then \
	        ${MAKE} TUNE_SRC=$$a TUNE_TRG=$$b ${@:-langtunealldist=-langtunedist}; \
	      fi \
	    done \
	  done )

tatoeba-%-langtunealljobs:
	( s=$(firstword $(subst 2, ,$(patsubst tatoeba-%-langtunealljobs,%,$@))); \
	  t=$(lastword  $(subst 2, ,$(patsubst tatoeba-%-langtunealljobs,%,$@))); \
	  S="${call find-srclanggroup,${patsubst tatoeba-%-langtunealljobs,%,$@},''}"; \
	  T="${call find-trglanggroup,${patsubst tatoeba-%-langtunealljobs,%,$@},''}"; \
	  for a in $$S; do \
	    for b in $$T; do \
	      if [ "$$a" != "$$b" ]; then \
	        ${MAKE} WALLTIME=12 TUNE_SRC=$$a TUNE_TRG=$$b ${@:-langtunealljobs=-langtunejob}; \
	      fi \
	    done \
	  done )

