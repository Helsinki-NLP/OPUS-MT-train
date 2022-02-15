# -*-makefile-*-

## 23 official EU languages:
#
# English
# German
# Swedish
# Finnish
# Dutch
# Danish
# Spanish
# Czech
# French
# Polish
# Portuguese
# Latvian
# Romanian
# Estonian
# Bulgarian
# Greek, Modern (1453-)
# Slovak
# Italian
# Maltese
# Slovenian
# Croatian
# Lithuanian
# Irish
# Hungarian

ELG_EU_LANGIDS = eng deu swe fin nld dan spa ces fra pol por lav ron est bul ell slk ita mlt slv hrv lit gle hun

ELG_EU_SELECTED = gmq nld pol por lav ron est bul ell ita mlt slv hbs lit cel hun glg eus zle zls zlw tur ara heb sqi fin
ELG_EU_SELECTED_MULTILANG = "ces slk" "cat oci spa" "por glg"
ELG_EU_SELECTED_BIG = spa fra deu

# "fry ltz nds afr"
# "cat oci"


elg-eng2all:
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	  ${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-job-bt; \
	done
	for l in ${ELG_EU_SELECTED}; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-trainjob-bt; \
	done
	for l in ${ELG_EU_SELECTED_BIG}; do \
	  ${MAKE} MODELTYPE=transformer-big \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-eng2$${l}-trainjob-bt; \
	done


elg-all2eng:
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	  ${MAKE} MODELTYPE=transformer-big TRGLANGS=eng SRCLANGS="$$l" \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-job-bt; \
	done
	for l in $(filter-out hun mlt,${ELG_EU_SELECTED}); do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2eng-trainjob-bt; \
	done
	for l in ${ELG_EU_SELECTED_BIG}; do \
	  ${MAKE} MODELTYPE=transformer-big \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-$${l}2eng-trainjob-bt; \
	done


elg-all2spa:
	${MAKE} MODELTYPE=transformer-big TRGLANGS=eng SRCLANGS="cat oci spa" \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-job-bt




elg-eng2all-eval1:
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	  ${MAKE} WALLTIME=1 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-sublang-eval-bt.submit; \
	  ${MAKE} WALLTIME=1 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-eval-bt.submit; \
	  ${MAKE} GPUJOB_HPC_MEM=20g WALLTIME=1 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-eval-testsets-bt.submit; \
	done

elg-eng2all-eval2:
	for l in ${ELG_EU_SELECTED}; do \
	  if [ -e ${wildcard work/eng-$$l/*.npz} ]; then \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-evalall-bt.submit; \
	  fi \
	done




elg-eng2xxx-eval:
	${MAKE} WALLTIME=2 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="fry ltz nds afr" tatoeba-sublang-eval-bt.submit
	${MAKE} WALLTIME=2 MODELTYPE=transformer-big tatoeba-eng2cel-multieval-bt.submit
	${MAKE} GPUJOB_HPC_MEM=32g WALLTIME=2 MODELTYPE=transformer-big tatoeba-eng2lit-eval-testsets-bt.submit


elg-eng2missing:
	for l in est lav ron hbs sqi spa fra ita por zlw ara heb deu fin; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-trainjob-bt; \
	done

elg-eng2slv:
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2slv-trainjob-bt-separate-spm; \


elg-missing:
	  ${MAKE} MODELTYPE=transformer-big SRCLANGS=zlw TRGLANGS=gmq \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zlw2gmq-trainjob-bt-pivotlang

elg-missing2:
	  ${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="ces slk" tatoeba-job-bt
	  ${MAKE} MODELTYPE=transformer-big SRCLANGS=zlw TRGLANGS=gmq \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zlw2gmq-trainjob-bt


elg-eng2fra:
	${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS=fra \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
	tatoeba-job-bt

elg-eng2zls:
	${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS=zls \
		MARIAN_EXTRA=--no-restore-corpus \
	tatoeba-job-bt

elg-eng2heb:
	${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS=heb MARIAN_EXTRA=--no-restore-corpus tatoeba-job-bt

elg-eng2spa:
	${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS=spa \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
	tatoeba-job-bt
