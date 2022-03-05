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

ELG_EU_SELECTED = nld pol por lav ron est bul ell ita mlt slv hbs lit cel hun glg eus tur ara heb sqi fin
ELG_EU_SELECTED_MULTILANG = "ces slk" "cat oci spa" "por glg"
ELG_EU_SELECTED_BIG = gmq zle zls zlw spa fra deu

# "fry ltz nds afr"
# "cat oci"



elg-eval: 
	for l in ${ELG_EU_SELECTED} ${ELG_EU_SELECTED_BIG}; do \
	  if [ -e ${wildcard work/eng-$$l/*.npz} ]; then \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-eval-testsets-bt; \
	  fi; \
	  if [ -e ${wildcard work/$${l}-eng/*.npz} ]; then \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2eng-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2eng-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2eng-eval-testsets-bt; \
	  fi; \
	done
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	    ${MAKE} MODELTYPE=transformer-big SRCLANGS="$$l" TRGLANGS=eng eval-bt-tatoeba; \
	    ${MAKE} MODELTYPE=transformer-big SRCLANGS="$$l" TRGLANGS=eng tatoeba-multilingual-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big SRCLANGS="$$l" TRGLANGS=eng eval-testsets-bt-tatoeba; \
	    ${MAKE} MODELTYPE=transformer-big TRGLANGS="$$l" SRCLANGS=eng eval-bt-tatoeba; \
	    ${MAKE} MODELTYPE=transformer-big TRGLANGS="$$l" SRCLANGS=eng tatoeba-multilingual-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big TRGLANGS="$$l" SRCLANGS=eng eval-testsets-bt-tatoeba; \
	done
	for p in zle2zle zlw2zle zle2fin zle2zlw; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-testsets-bt; \
	done

elg-eval-zle:
	for p in zle2zle zlw2zle zle2fin zle2zlw; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-testsets-bt; \
	done


elg-pivot-eval:
	for l in dan swe fin deu ron tur; do
	  ${MAKE} tatoeba-$${l}2ukr-eval-pbt; \
	  ${MAKE} tatoeba-ukr2$${l}-eval-pft; \
	done
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr eval-tatoeba
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr tatoeba-multilingual-eval
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr eval-tatoeba
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr tatoeba-multilingual-eval


elg-dan2ukr:
	${MAKE} tatoeba-dan2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2dan-trainjob-pft

elg-swe2ukr:
	${MAKE} tatoeba-swe2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2swe-trainjob-pft

elg-fin2ukr:
	${MAKE} tatoeba-fin2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2fin-trainjob-pft

elg-deu2ukr:
	${MAKE} tatoeba-deu2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2deu-trainjob-pft

elg-slk2ukr:
	${MAKE} tatoeba-slk2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2slk-trainjob-pft

elg-ces_slk2ukr:
	${MAKE} SRCLANGS=ukr TRGLANGS="ces slk" tatoeba-job-pft
	${MAKE} TRGLANGS=ukr SRCLANGS="ces slk" tatoeba-job-pbt

elg-ron2ukr:
	${MAKE} tatoeba-ron2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2ron-trainjob-pft

elg-tur2ukr:
	${MAKE} tatoeba-tur2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2tur-trainjob-pft


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
	for l in ${ELG_EU_SELECTED}; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2eng-trainjob-bt; \
	done
	for l in ${ELG_EU_SELECTED_BIG}; do \
	  ${MAKE} MODELTYPE=transformer-big \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-$${l}2eng-trainjob-bt; \
	done





elg-eng2all-eval1:
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	  ${MAKE} WALLTIME=1 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-sublang-eval-bt.submit; \
	  ${MAKE} WALLTIME=1 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-eval-bt.submit; \
	  ${MAKE} GPUJOB_HPC_MEM=24g WALLTIME=1 MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-eval-testsets-bt.submit; \
	done

elg-eng2all-eval2:
	for l in ${ELG_EU_SELECTED} ${ELG_EU_SELECTED_BIG}; do \
	  if [ -e ${wildcard work/eng-$$l/*.npz} ]; then \
	    ${MAKE} GPUJOB_HPC_MEM=24g WALLTIME=1 MODELTYPE=transformer-big tatoeba-eng2$${l}-evalall-bt.submit; \
	  fi \
	done

elg-all2eng-eval:
	for l in ${ELG_EU_SELECTED} ${ELG_EU_SELECTED_BIG}; do \
	  if [ -e ${wildcard work/$${l}-eng/*.npz} ]; then \
	    ${MAKE} GPUJOB_HPC_MEM=24g WALLTIME=1 MODELTYPE=transformer-big tatoeba-$${l}2eng-evalall-bt.submit; \
	  fi \
	done


elg-tune4ukr2eng:
	${MAKE} MODELTYPE=transformer-big TUNE_SRC=ukr TUNE_TRG=eng tatoeba-zle2eng-langtunejob



elg-zle2zlx:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2zlw-trainjob-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zlw2zle-trainjob-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2zls-trainjob-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zls2zle-trainjob-bt



elg-zle2zle:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2zle-trainjob-bt

elg-gmq2zle:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-gmq2zle-trainjob-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2gmq-trainjob-bt

elg-zle2fin:
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2fin-trainjob-bt



elg-sla2sla:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-sla2sla-trainjob-bt


elg-eng2cel:
	${MAKE} MODELTYPE=transformer-big \
		CLEAN_TRAINDATA_TYPE=clean \
		CLEAN_DEVDATA_TYPE=clean \
	tatoeba-eng2cel-trainjob-bt

elg-por2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-por2eng-trainjob-bt

elg-lav2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		tatoeba-lav2eng-trainjob-bt

elg-ara2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-ara2eng-trainjob-bt

elg-zle2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2eng-trainjob-bt

elg-zls2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zls2eng-trainjob-bt

elg-multi2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		SRCLANGS=eng TRGLANGS="cat oci spa" \
	tatoeba-job-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		SRCLANGS=eng TRGLANGS="por glg" \
	tatoeba-job-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		TRGLANGS=eng SRCLANGS="cat oci spa" \
	tatoeba-job-bt
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		TRGLANGS=eng SRCLANGS="por glg" \
	tatoeba-job-bt

elg-eng2spa:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		SRCLANGS=eng TRGLANGS="cat oci spa" \
	tatoeba-job-bt


elg-ces2eng:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		TRGLANGS=eng SRCLANGS="ces slk" \
	tatoeba-job-bt

elg-eng2ces:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		SRCLANGS=eng TRGLANGS="ces slk" \
	tatoeba-job-bt




## test with separate vocabs
elg-eng2slv:
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2slv-trainjob-bt-separate-spm; \


## more temp disk and no-restore
elg-eng2fra:
	${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS=fra \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
	tatoeba-job-bt



elg-eng2fin:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		tatoeba-eng2fin-trainjob-bt



good-ukr-models:
	@grep '^[^ ]*-ukr'  ~/research/Tatoeba-Challenge/models/released-model-results-all.txt | \
	grep -v 'tuned4' | rev | uniq -f5 | rev | grep '[3-9][0-9]\.[0-9]' | grep -P '\t[0-9]{3,}\t'
	@grep '^ukr-'  ~/research/Tatoeba-Challenge/models/released-model-results-all.txt | \
	grep -v 'tuned4' | rev | uniq -f5 | rev | grep '[3-9][0-9]\.[0-9]' | grep -P '\t[0-9]{3,}\t'

ukr-model-table:
	make -s good-ukr-models |\
	cut -f1-4 |\
	sed 's/	/	|	/g;s/^/| /;s/$$/ |/' |\
	sed 's#\(https://object.pouta.csc.fi/Tatoeba-MT-models/\)\(.*\).zip#[\2](\1\2.zip)#'


ukr-model-table2:
	make -s good-ukr-models | cut -f1-4 > $@.tmp1
	cut -f1 $@.tmp1 | xargs iso639 -p  | sed "s/^\"//;s/\"$$//;s#\" \"#\n#g" > $@.tmp2
	paste $@.tmp2 $@.tmp1 |\
	sed 's/	/	|	/g;s/^/| /;s/$$/ |/' |\
	sed 's#\(https://object.pouta.csc.fi/Tatoeba-MT-models/\)\(.*\).zip#[\2](\1\2.zip)#'
	rm -f $@.tmp*
