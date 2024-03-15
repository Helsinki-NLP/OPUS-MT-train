# -*-makefile-*-
#
#  TODO: problems with racing situations in data pre-processing?
#        (e.g. when starting simultanously jobs for both translation directions)
#   --> strict filtering is done in work/data/simple/ ...
#
#

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

HPLT1_LANGS = ara hbs cat eng est eus fin gle glg hin isl mkd mlt nor sqi swa zho

PIVOTS ?= deu eng fra por spa


LUMI_TASK = trainjob
LUMI_EVAL_TASK = eval-testsets
# LUMI_EVAL_TASK = evalall




## languages that cover a minimum of 10 languages according to ISO 639 codes
##
## languages printed in this way and then sorted:
##
#	for l in $(shell langgroup -p `langgroup mul` | tr ' ' "\n" | sort -u); do \
#	  if [ `langgroup $$l | wc -w` -gt 10 ]; then \
#	    echo $$l; \
#	  else \
#	    p=`langgroup -p $$l`; \
#	    if [ `langgroup $$p | wc -w` -gt 10 ]; then \
#	      echo $$p; \
#	    fi \
#	  fi \
#	done


MIN10_LANG_GROUPS = aav afa alg alv aql art ath aus awd azc bad bai bat ber bnt cau cba ccn cdc cel cmc csu cus dmn dra esx fiu fox gem gmq gmw hmx hok iir inc ine ira iro itc kar kdo kro map mkh mno mul mun myn nah nai ngf nic nub omq omv oto paa phi poz pqe pqw roa sai sal sdv sem sio sit sla smi ssa tai tbq trk tup tuw urj xgn xnd zhx




lumi-eval-jobs:
	make HPC_MEM=64g HPC_TIME=8:00 lumi-bigger-multi-eval-bt.submit
	make HPC_MEM=64g HPC_TIME=8:00 lumi-biggest-multi-eval-bt.submit
	make HPC_MEM=64g HPC_TIME=8:00 lumi-bigger-gmq+eng2fin-eval.submit
	make HPC_MEM=64g HPC_TIME=8:00 lumi-enfisv-bigger-eval.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-base.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-big.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-bigger.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-biggest.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK=${LUMI_EVAL_TASK} LUMI_TASK2=${LUMI_EVAL_TASK} lumi-big-fin.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK=${LUMI_EVAL_TASK} lumi-bigger-fin.submit
	make HPC_MEM=64g HPC_TIME=8:00 lumi-big-multi-eval.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK2=${LUMI_EVAL_TASK} lumi-eulangs.submit
	make HPC_MEM=64g HPC_TIME=8:00 LUMI_TASK2=${LUMI_EVAL_TASK} lumi-eulangs-12x6.submit

lumi-eval-job:
	make HPC_MEM=64g lumi-eval.submit

lumi-eval:
	-make lumi-bigger-gmq+eng2fin-eval
	-make lumi-enfisv-bigger-eval
	-make LUMI_TASK=${LUMI_EVAL_TASK} LUMI_TASK2=${LUMI_EVAL_TASK} lumi-big-fin
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bigger-fin
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bigger-fin2eng
	-make LUMI_TASK2=${LUMI_EVAL_TASK} lumi-eulangs
	-make LUMI_TASK2=${LUMI_EVAL_TASK} lumi-eulangs-12x6
	-make LUMI_TASK2=${LUMI_EVAL_TASK} lumi-eulangs-24x12
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-base
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-big
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-bigger
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-wikimedia-biggest
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-models
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-models2
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-urj2nordic
	-make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-nordic2urj
	-make lumi-big-multi-eval
	-make lumi-bigger-multi-eval-bt
	-make lumi-biggest-multi-eval-bt



lumi-eval2-job:
	make HPC_MEM=64g lumi-eval2.submit

lumi-eval2:
	make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-models
	make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-models2
	make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-urj2nordic
	make LUMI_TASK=${LUMI_EVAL_TASK} lumi-bible-nordic2urj




LUMI_TASK2 = train-job

lumi-eulangs:
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="eulangs" \
		SKIP_SAME_LANG=0 \
		SKIP_MAKE_RAWDATA=1 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-12x12 \
		SRCLANGS="${ELG_EU_LANGIDS}" \
		TRGLANGS="${ELG_EU_LANGIDS}" ${LUMI_TASK2}-bt-100max

lumi-eulangs-12x6:
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="eulangs" \
		SKIP_SAME_LANG=0 \
		SKIP_MAKE_RAWDATA=1 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-12x6 \
		SRCLANGS="${ELG_EU_LANGIDS}" \
		TRGLANGS="${ELG_EU_LANGIDS}" ${LUMI_TASK2}-bt-100max

lumi-eulangs-24x12:
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="eulangs" \
		SKIP_SAME_LANG=0 \
		SKIP_MAKE_RAWDATA=1 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-24x12b \
		SRCLANGS="${ELG_EU_LANGIDS}" \
		TRGLANGS="${ELG_EU_LANGIDS}" ${LUMI_TASK2}-bt-100max


%-100max:
	${MAKE} MAX_DATA_SIZE=100000000 DATASET=${DATASET}max100 ${@:-100max=}



LUMI_MULTI_ARGS = DATA_SAMPLING_WEIGHT=0.5 GPUJOB_SUBMIT=-gpu8 SKIP_SAME_LANG=0 SKIP_MAKE_RAWDATA=1

# MARIAN_EXTRA=--no-restore-corpus



lumi_bible_urj2eng:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-urj2eng-${LUMI_TASK}-jhubc

lumi_bible_urj2world:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-urj2deu+eng+fra+por+spa-${LUMI_TASK}-jhubc


# also interesting:
# (but need to prepare bible data for urj lang pairs!)
#
# lumi_bible_urj2urj lumi_bible_gmq+urj2gmq+urj


lumi-bible-big-models: 
	for l in $(MIN10_LANG_GROUPS); do \
	  ${MAKE} 	lumi_biblebig_$${l}2deu+eng+fra+por+spa \
			lumi_biblebig_deu+eng+fra+por+spa2$${l}; \
	done


lumi-bible-12x6-models: 
	for l in $(MIN10_LANG_GROUPS); do \
	  ${MAKE} 	lumi_bible12x6_$${l}2deu+eng+fra+por+spa \
			lumi_bible12x6_deu+eng+fra+por+spa2$${l}; \
	done

lumi-bible-12x6-models-eval: 
	for l in $(MIN10_LANG_GROUPS); do \
	  ${MAKE} GPUJOB_HPC_JOBS=2 LUMI_TASK=eval-testsets lumi_bible12x6_$${l}2deu+eng+fra+por+spa; \
	  ${MAKE} GPUJOB_HPC_JOBS=2 LUMI_TASK=eval-testsets lumi_bible12x6_deu+eng+fra+por+spa2$${l}; \
	done





lumi-bible-mul2world:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 \
		tatoeba-mul2deu+eng+fra+por+spa-${LUMI_TASK}-jhubc-bt-max25 \
		tatoeba-deu+eng+fra+por+spa2mul-${LUMI_TASK}-jhubc-bt-max25

lumi-bible-world2mul:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-6x12 \
		tatoeba-deu+eng+fra+por+spa2mul-${LUMI_TASK}-jhubc-bt-max25


lumi-bible-urj2nordic:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big \
		tatoeba-urj2fin+nob+nno+swe+rus-${LUMI_TASK}-jhubc-bt
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big \
		tatoeba-fin+nob+nno+swe+rus2urj-${LUMI_TASK}-jhubc-bt

lumi-bible-urj2nordic-eval:
	${MAKE} LUMI_TASK=eval-testsets lumi-bible-urj2nordic

# lumi-bible-nordic2urj:
#	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big \
#		tatoeba-fin+nob+nno+swe+rus2urj-${LUMI_TASK}-jhubc-bt


LUMI_JHUBC_MODEL = transformer-12x6

lumi_bible12x6_%:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 \
		tatoeba-$(patsubst lumi_bible12x6_%,%,$@)-${LUMI_TASK}-jhubc-bt-max50

lumi_biblebig_%:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big \
		tatoeba-$(patsubst lumi_biblebig_%,%,$@)-${LUMI_TASK}-jhubc-bt-max50





JHUBC_SPM = ${WORKHOME}/mul-mul/train/opus+bible.spm64k-model

%-m2m_jhubc:
	${MAKE} TATOEBA_DATASET=jhubc DATASET=jhubc \
		BPESIZE=64000 \
		VOCABSIZE=65536 \
		SPMSRCMODEL=${JHUBC_SPM} \
		SPMTRGMODEL=${JHUBC_SPM} $(@:-m2m_jhubc=)


lumi-bible:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-mul2mul-${LUMI_TASK}-m2m_jhubc

lumi-bible-huge:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x24 tatoeba-mul2mul-${LUMI_TASK}-m2m_jhubc

lumi-bible-big:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-mul2mul-${LUMI_TASK}-m2m_jhubc



lumi-bible-eval:
	${MAKE} LUMI_TASK=eval-testsets lumi-bible

lumi-bible-big-eval:
	${MAKE} LUMI_TASK=eval-testsets lumi-bible-big


lumi-bible-eval-english:
	${MAKE} LUMI_TASK=eval-english-testsets lumi-bible



# OPUS-TC + BT + JHUBC

%-m2m_opusjhubc:
	${MAKE} TATOEBA_DATASET=opusTCv20230926+bt+jhubc DATASET=opusTCv20230926+bt+jhubc \
		BPESIZE=64000 \
		VOCABSIZE=65536 \
		SPMSRCMODEL=${JHUBC_SPM} \
		SPMTRGMODEL=${JHUBC_SPM} $(@:-m2m_opusjhubc=)

lumi-opusbible: lumi-opusbible-big lumi-opusbible-bigger # lumi-opusbible-huge

lumi-opusbible-big:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-mul2mul-${LUMI_TASK}-m2m_opusjhubc

lumi-opusbible-bigger:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-mul2mul-${LUMI_TASK}-m2m_opusjhubc

lumi-opusbible-huge:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x24 tatoeba-mul2mul-${LUMI_TASK}-m2m_opusjhubc


lumi-opusbible-big-eval:
	${MAKE} GPUJOB_HPC_JOBS=4 LUMI_TASK=eval-testsets lumi-opusbible-big.submit

lumi-opusbible-big-eval-english:
	${MAKE} GPUJOB_HPC_JOBS=4 LUMI_TASK=eval-english-testsets lumi-opusbible-big.submit

lumi-opusbible-bigger-eval-english:
	${MAKE} GPUJOB_HPC_JOBS=4 LUMI_TASK=eval-english-testsets lumi-opusbible-bigger.submit




lumi-opusbible-big-eval-pivots:
	for l in ${PIVOTS}; do \
	  ${MAKE} GPUJOB_HPC_JOBS=1 PIVOT=$$l LUMI_TASK=eval-pivot-testsets lumi-opusbible-big.submit; \
	done

lumi-opusbible-bigger-eval-pivots:
	for l in ${PIVOTS}; do \
	  ${MAKE} GPUJOB_HPC_JOBS=1 PIVOT=$$l LUMI_TASK=eval-pivot-testsets lumi-opusbible-bigger.submit; \
	done


## eval only flores200

# eval-testsets-flores200.tsv

lumi-opusbible-big-eval-flores200-pivots:
	${MAKE} TESTSETS_TSV=eval-testsets-flores200.tsv lumi-opusbible-big-eval-pivots



test-hplt-eval:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-fin2eng-eval-testsets-bt


hplt1_models-eval:
	${MAKE} LUMI_TASK=eval-testsets hplt1_models
	${MAKE} LUMI_TASK=eval-testsets hplt1_models-reverse
	${MAKE} LUMI_TASK=eval-testsets hplt1_models-big

hplt1_models-big:
	for l in ${HPLT1_LANGS}; do \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-$${l}2eng-${LUMI_TASK}-bt; \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-eng2$${l}-${LUMI_TASK}-bt; \
	done

hplt1_models:
	for l in ${HPLT1_LANGS}; do \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-$${l}2eng-${LUMI_TASK}-bt; \
	done

hplt1_models-reverse:
	for l in ${HPLT1_LANGS}; do \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2$${l}-${LUMI_TASK}-bt; \
	done



hplt1-missing:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-swa2eng-${LUMI_TASK}-bt
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-gle2eng-${LUMI_TASK}-bt
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-gle2eng-${LUMI_TASK}-bt
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2gle-${LUMI_TASK}-bt
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-fin2eng-${LUMI_TASK}-bt
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-eng2gle-${LUMI_TASK}-bt





printdatasets:
	@echo "test source ${TESTDATA_SRC}"
	@echo "test source ${TESTDATA_TRG}"
	@echo "dev source ${DEVDATA_SRC}"
	@echo "dev source ${DEVDATA_TRG}"
	@echo "train source ${TRAINDATA_SRC}"
	@echo "train source ${TRAINDATA_TRG}"


lumi-wikimedia-bigger-rev:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-6x12 tatoeba-eng2alv-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-6x12 tatoeba-eng2bnt-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-6x12 tatoeba-eng2poz-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-6x12 tatoeba-eng2urj-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-6x12 MAX_DATA_SIZE=25000000 tatoeba-eng2mul-${LUMI_TASK}-bt-bibles


lumi-wikimedia-bigger:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-alv2eng-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2alv-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-bnt2eng-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2bnt-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-poz2eng-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2poz-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-urj2eng-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2urj-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 MAX_DATA_SIZE=25000000 tatoeba-mul2eng-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 MAX_DATA_SIZE=25000000 tatoeba-eng2mul-${LUMI_TASK}-bt-bibles

lumi-wikimedia-biggest:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-eng2poz-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-eng2mul-${LUMI_TASK}-bt-bibles
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-poz2eng-${LUMI_TASK}-bt-bibles
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-mul2eng-${LUMI_TASK}-bt-bibles

lumi-wikimedia-big:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-eng2alv-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-eng2poz-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-eng2pqe-${LUMI_TASK}-bt-bibles

lumi-wikimedia-base:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2bik-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2guw-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2pqe-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2tah-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2yue-${LUMI_TASK}-bt-bibles
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-align tatoeba-eng2zho-${LUMI_TASK}-bt-bibles

lumi-wikimedia-bre:
	make GPUJOB_SUBMIT=-gpu8 \
		SKIP_SAME_LANG=0 \
		SKIP_MAKE_RAWDATA=1 \
		DATA_SAMPLING_WEIGHT=0.5 \
		SRCLANGS="eng fra" \
		TRGLANGS="bre" \
	tatoeba-job-bt-bibles

lumi-wikimedia-bikol:
	make GPUJOB_SUBMIT=-gpu8 \
		SKIP_SAME_LANG=0 \
		SKIP_MAKE_RAWDATA=1 \
		DATA_SAMPLING_WEIGHT=0.5 \
		SRCLANGS="deu eng fra nld por spa" \
		TRGLANGS="bik" \
	tatoeba-job-bt-bibles



#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-eng2poz-${LUMI_TASK}-bt-bibles
#	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-eng2pqe-${LUMI_TASK}-bt-bibles






lumi-big-fin:
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-gmw2fin-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-fin2gmw-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-sla2fin-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-fin2sla-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-itc2fin-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-fin2itc-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-gem2fin-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-fin2gem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-ine2fin-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-fin2ine-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-mul2fin-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-fin2mul-${LUMI_TASK}
	-for l in jpn zho ara tur; do \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-$${l}2fin-${LUMI_TASK}; \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align tatoeba-fin2$${l}-${LUMI_TASK}; \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align SRCLANGS="$$l eng" TRGLANGS=fin ${LUMI_TASK2}; \
	  make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big-align TRGLANGS="$$l eng" SRCLANGS=fin ${LUMI_TASK2}; \
	done


## bigger transformer models for fin-eng and fin-swe in both directions

lumi-bigger-fin:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6-align tatoeba-fin2swe-${LUMI_TASK}-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6-align tatoeba-swe2fin-${LUMI_TASK}-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6-align tatoeba-fin2eng-${LUMI_TASK}-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6-align tatoeba-eng2fin-${LUMI_TASK}-bt

lumi-bigger-fin2eng:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-fin2eng-${LUMI_TASK}-bt


## bigger transformer models for North-Germanic + English to Finnish translation
##                           and Finnish to North-Germanic + English

lumi-bigger-gmq+eng2fin:
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="gmq+eng-fin" \
		SKIP_SAME_LANG=0 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-12x6 \
		SRCLANGS="dan fao isl jut nno nob non nrn ovd qer rmg swe eng" \
		TRGLANGS="fin" tatoeba-job-bt
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="fin-gmq+eng" \
		SKIP_SAME_LANG=0 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-12x6 \
		TRGLANGS="dan fao isl jut nno nob non nrn ovd qer rmg swe eng" \
		SRCLANGS="fin" tatoeba-job-bt


lumi-bigger-gmq+eng2fin-eval:
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="gmq+eng-fin" \
		SKIP_SAME_LANG=0 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-12x6 \
		SRCLANGS="dan fao isl jut nno nob non nrn ovd qer rmg swe eng" \
		TRGLANGS="fin" ${LUMI_EVAL_TASK}-bt
	make GPUJOB_SUBMIT=-gpu8 \
		LANGPAIRSTR="fin-gmq+eng" \
		SKIP_SAME_LANG=0 \
		DATA_SAMPLING_WEIGHT=0.5 \
		MODELTYPE=transformer-12x6 \
		TRGLANGS="dan fao isl jut nno nob non nrn ovd qer rmg swe eng" \
		SRCLANGS="fin" ${LUMI_EVAL_TASK}-bt



# 	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 TATOEBA_PIVOT=eng tatoeba-gmq2fin-${LUMI_TASK}-bt-pivotlang
# 	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 TATOEBA_PIVOT=eng tatoeba-fin2gmq-${LUMI_TASK}-bt-pivotlang





lumi-big-multi:
	${MAKE} LUMI_TASK=trainjob MODELTYPE=transformer-big lumi-multi

lumi-big-multi-bt:
	${MAKE} LUMI_TASK=trainjob-bt MODELTYPE=transformer-big lumi-multi


lumi-big-multi-eval:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK} MODELTYPE=transformer-big lumi-multi

lumi-big-multi-bt-eval:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK}-bt MODELTYPE=transformer-big lumi-multi




lumi-bigger-multi:
	${MAKE} LUMI_TASK=trainjob MODELTYPE=transformer-12x6 lumi-multi

lumi-bigger-multi-bt:
	${MAKE} LUMI_TASK=trainjob-bt MODELTYPE=transformer-12x6 lumi-multi

lumi-bigger-multi-eval:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK} MODELTYPE=transformer-12x6 lumi-multi

lumi-bigger-multi-eval-bt:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK}-bt MODELTYPE=transformer-12x6 lumi-multi



lumi-biggest-multi:
	${MAKE} LUMI_TASK=trainjob MODELTYPE=transformer-12x12 lumi-multi

lumi-biggest-multi-bt:
	${MAKE} LUMI_TASK=trainjob-bt MODELTYPE=transformer-12x12 lumi-multi

lumi-biggest-multi-eval-bt:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK}-bt MODELTYPE=transformer-12x12 lumi-multi



lumi-huge-multi:
	${MAKE} LUMI_TASK=trainjob MODELTYPE=transformer-24x12b lumi-multi

lumi-huge-multi-bt:
	${MAKE} LUMI_TASK=trainjob-bt MODELTYPE=transformer-24x12b lumi-multi

lumi-huge-multi-eval:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK} MODELTYPE=transformer-24x12b lumi-multi

lumi-huge-multi-bt-eval:
	${MAKE} LUMI_TASK=${LUMI_EVAL_TASK}-bt MODELTYPE=transformer-24x12b lumi-multi



lumi-restart-broken:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-zls2eng-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-sla2eng-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-itc2gem-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-gem2itc-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-gem2eng-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-eng2urj-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-eng2ine-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-zlw2eng-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2zlw-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2zls-trainjob-bt
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2zle-trainjob-bt



lumi-multi:
	-make ${LUMI_MULTI_ARGS} tatoeba-sla2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2sla-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-gem2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2gem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2itc-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-itc2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-zlw2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2zlw-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-zle2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2zle-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-zls2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2zls-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-sem2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2sem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-urj2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2urj-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-alv2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2alv-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-sit2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2sit-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-sla2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2sla-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-ine2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-eng2ine-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-mul2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-eng2mul-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-itc2gem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-gem2itc-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-gem2gem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-itc2itc-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-sla2sla-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 tatoeba-ine2ine-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} MAX_DATA_SIZE=25000000 DEVSIZE=20000 tatoeba-mul2mul-${LUMI_TASK}



## start models

lumi-extra-multi-bt:
	${MAKE} LUMI_TASK=trainjob-bt-max100 MODELTYPE=transformer-12x12 lumi-multi-big
	${MAKE} LUMI_TASK=trainjob-bt-max50 MODELTYPE=transformer-12x12 lumi-multi-biggest

lumi-extra2-multi-bt:
	${MAKE} LUMI_TASK=trainjob-bt-max100 MODELTYPE=transformer-24x12b lumi-multi-big
	${MAKE} LUMI_TASK=trainjob-bt-max50 MODELTYPE=transformer-24x12b lumi-multi-biggest

lumi-ineine50:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12b tatoeba-ine2ine-trainjob-bt-max50

lumi-mulmul50:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-mul2mul-trainjob-bt-max50
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-mul2mul-trainjob-bt-max50
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12b tatoeba-mul2mul-trainjob-bt-max50

lumi-mulmul50-12x12:
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-mul2mul-trainjob-bt-max50


lumi-mulmul: lumi-opusbible-big lumi-opusbible-bigger
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-mul2mul-trainjob-bt
	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-mul2mul-trainjob-bt-max50


lumi-mulmul50-eval:
	for l in ${PIVOTS}; do \
	  ${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 GPUJOB_HPC_JOBS=1 PIVOT=$$l tatoeba-mul2mul-eval-pivot-testsets-bt-max50.submit; \
	done

#	${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 GPUJOB_HPC_JOBS=2 tatoeba-mul2mul-eval-english-testsets-bt-max50.submit

lumi-mulmul25-eval:
	for l in ${PIVOTS}; do \
	  ${MAKE} ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 GPUJOB_HPC_JOBS=1 PIVOT=$$l tatoeba-mul2mul-eval-pivot-testsets-bt.submit; \
	done


lumi-mulmul50-restart:
	${MAKE} ${LUMI_MULTI_ARGS} MARIAN_EARLY_STOPPING=15 MODELTYPE=transformer-12x12 tatoeba-mul2mul-trainjob-bt-max50


lumi-multi-big:
	-make ${LUMI_MULTI_ARGS} tatoeba-ine2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2ine-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-mul2eng-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-eng2mul-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-itc2gem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-gem2itc-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-gem2gem-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-itc2itc-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} tatoeba-sla2sla-${LUMI_TASK}

lumi-multi-biggest:
	-make ${LUMI_MULTI_ARGS} tatoeba-ine2ine-${LUMI_TASK}
	-make ${LUMI_MULTI_ARGS} DEVSIZE=20000 tatoeba-mul2mul-${LUMI_TASK}


%-max25:
	${MAKE} MAX_DATA_SIZE=25000000 DATASET=${DATASET}max25 $(@:-max25=)

%-max50:
	${MAKE} MAX_DATA_SIZE=50000000 DATASET=${DATASET}max50 ${@:-max50=}

%-max100:
	${MAKE} MAX_DATA_SIZE=100000000 DATASET=${DATASET}max100 ${@:-max100=}



lumi-multi-restart:
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-mul2eng-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-eng2mul-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-sit2eng-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 tatoeba-eng2sit-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-mul2eng-trainjob-bt-bibles
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-eng2mul-trainjob-bt-bibles

#	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 DEVSIZE=20000 tatoeba-mul2mul-trainjob-bt-bibles


lumi-multi-ine2ine:
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 MAX_DATA_SIZE=25000000 tatoeba-ine2ine-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 tatoeba-ine2ine-trainjob-bt
#	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 MAX_DATA_SIZE=25000000 tatoeba-ine2ine-${LUMI_TASK}

lumi-multi-mul2mul:
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x12 MAX_DATA_SIZE=25000000 DEVSIZE=20000 tatoeba-mul2mul-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 MAX_DATA_SIZE=25000000 DEVSIZE=20000 tatoeba-mul2mul-trainjob-bt

lumi-multi-alv:
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-alv2eng-trainjob-bt
	-make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-12x6 tatoeba-eng2alv-trainjob-bt




lumi-huge-multi-eng:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 tatoeba-gem2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 tatoeba-eng2gem-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 tatoeba-itc2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 tatoeba-eng2itc-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 tatoeba-sla2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 tatoeba-eng2sla-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 MAX_DATA_SIZE=25000000 tatoeba-ine2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 MAX_DATA_SIZE=25000000 tatoeba-eng2ine-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 MAX_DATA_SIZE=25000000 tatoeba-mul2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-24x12 MAX_DATA_SIZE=25000000 tatoeba-eng2mul-trainjob

lumi-big-multi-eng:
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-gem2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-eng2gem-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-itc2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-eng2itc-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-sla2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big tatoeba-eng2sla-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big MAX_DATA_SIZE=25000000 tatoeba-ine2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big MAX_DATA_SIZE=25000000 tatoeba-eng2ine-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big MAX_DATA_SIZE=25000000 tatoeba-mul2eng-trainjob
	make ${LUMI_MULTI_ARGS} MODELTYPE=transformer-big MAX_DATA_SIZE=25000000 tatoeba-eng2mul-trainjob





lumi-enfisv-bigger:
	make GPUJOB_SUBMIT=-gpu8 \
		DATA_SAMPLING_WEIGHT=0.5 \
		SKIP_SAME_LANG=0 \
		MODELTYPE=transformer-12x6 \
		SRCLANGS="eng fin swe" \
		TRGLANGS="eng fin swe" tatoeba-job-bt

lumi-enfisv-bigger-eval:
	make GPUJOB_SUBMIT=-gpu8 \
		DATA_SAMPLING_WEIGHT=0.5 \
		SKIP_SAME_LANG=0 \
		MODELTYPE=transformer-12x6 \
		SRCLANGS="eng fin swe" \
		TRGLANGS="eng fin swe" ${LUMI_EVAL_TASK}-bt



lumi-enfisv-big:
	make GPUJOB_SUBMIT=-gpu8 \
		DATA_SAMPLING_WEIGHT=0.5 \
		SKIP_SAME_LANG=0 \
		MODELTYPE=transformer-big-align \
		SRCLANGS="eng fin swe" \
		TRGLANGS="eng fin swe" tatoeba-job

lumi-enfisv-big-noalign:
	make GPUJOB_SUBMIT=-gpu8 \
		GPUJOB_HPC_MEM=64g \
		DATA_SAMPLING_WEIGHT=0.5 \
		SKIP_SAME_LANG=0 \
		MODELTYPE=transformer-big \
		SRCLANGS="eng fin swe" \
		TRGLANGS="eng fin swe" tatoeba-job

lumi-enfisv-big-noalign-eval:
	make 	GPUJOB_HPC_MEM=64g \
		MODELTYPE=transformer-big \
		SRCLANGS="eng fin swe" \
		TRGLANGS="eng fin swe" ${LUMI_EVAL_TASK}-tatoeba tatoeba-eval tatoeba-eval-testsets



lumi-enfisv-big-noalign-bt:
	make GPUJOB_SUBMIT=-gpu8 \
		GPUJOB_HPC_MEM=64g \
		DATA_SAMPLING_WEIGHT=0.5 \
		SKIP_SAME_LANG=0 \
		MODELTYPE=transformer-big \
		SRCLANGS="eng fin swe" \
		TRGLANGS="eng fin swe" tatoeba-job-bt




# raul-timo: rus2eng ukr2eng sla2eng ine2eng mul2eng
# raul-timo: sla2eng ine2eng mul2eng
raul-timo: ita2eng fra2eng spa2eng por2eng cat2eng

#	${MAKE} rus2eng
#	${MAKE} ukr2eng
#	${MAKE} sla2eng
#	${MAKE} ine2eng
#	${MAKE} mul2eng

rus2eng ukr2eng ita2eng fra2eng por2eng spa2eng cat2eng:
	make MODELTYPE=transformer tatoeba-$@-data-5m

sla2eng ine2eng mul2eng:
	make MODELTYPE=transformer tatoeba-$@-data-5m0.5temp

roa2eng:
	make MODELTYPE=transformer tatoeba-$@-data-5m0.5temp


%-5m:
	${MAKE} LANGGROUP_FIT_DATA_SIZE=5000000 \
		FIT_DATA_SIZE=5000000 \
		DATASET=${DATASET}5m \
	${@:-5m=}

%-5m0.5temp:
	${MAKE} DATA_SAMPLING_WEIGHT=0.5 \
		MAX_DATA_SIZE=5000000 \
		DATASET=${DATASET}5m \
	${@:-5m0.5temp=}



fin2eng-extended-align:
	${MAKE} MODELTYPE=transformer-align DATASET=${DATASET}+news tatoeba-fin2eng-trainjob-bt

eng2fin-extended-align:
	${MAKE} MODELTYPE=transformer-align DATASET=${DATASET}+news tatoeba-eng2fin-trainjob-bt

swe2fin-extended-align:
	${MAKE} MODELTYPE=transformer-align DATASET=${DATASET}+news tatoeba-swe2fin-trainjob-bt-pbt

fin2swe-extended-align:
	${MAKE} MODELTYPE=transformer-align tatoeba-fin2swe-trainjob-bt-pbt






fin2eng-extended-release:
	${MAKE} MODELTYPE=transformer-big DATASET=${DATASET}+news tatoeba-fin2eng-dist-bt
	${MAKE} MODELTYPE=transformer-big DATASET=${DATASET}+news tatoeba-eng2fin-dist-bt

swe2fin-extended-release:
	${MAKE} MODELTYPE=transformer-big DATASET=${DATASET}+news tatoeba-swe2fin-dist-bt-pbt


fin2eng-extended:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 DATASET=${DATASET}+news tatoeba-fin2eng-trainjob-bt

eng2fin-extended:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 DATASET=${DATASET}+news tatoeba-eng2fin-trainjob-bt

swe2fin-extended:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 DATASET=${DATASET}+news tatoeba-swe2fin-trainjob-bt-pbt

fin2swe-extended:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 tatoeba-fin2swe-trainjob-bt-pbt


24x12-${LUMI_EVAL_TASK}:
	${MAKE} MODELTYPE=transformer-24x12 DATASET=${DATASET}+news \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
		MARIAN_EXTRA=--no-restore-corpus \
	tatoeba-fin2eng-${LUMI_EVAL_TASK}-bt
	${MAKE} MODELTYPE=transformer-24x12 DATASET=${DATASET}+news \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
	tatoeba-eng2fin-${LUMI_EVAL_TASK}-bt
	${MAKE} MODELTYPE=transformer-24x12 \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
		MARIAN_EXTRA=--no-restore-corpus \
	tatoeba-fin2swe-${LUMI_EVAL_TASK}-bt-pbt
	${MAKE} MODELTYPE=transformer-24x12 \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
	tatoeba-swe2fin-${LUMI_EVAL_TASK}-bt-pbt




fin2eng-24x12:
	${MAKE} MODELTYPE=transformer-24x12 DATASET=${DATASET}+news \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
		MARIAN_EXTRA=--no-restore-corpus \
	tatoeba-fin2eng-trainjob-bt

#		GPUJOB_SUBMIT=-gpu01 \

eng2fin-24x12:
	${MAKE} MODELTYPE=transformer-24x12 DATASET=${DATASET}+news \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
	tatoeba-eng2fin-trainjob-bt

fin2swe-24x12:
	${MAKE} MODELTYPE=transformer-24x12 \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
		MARIAN_EXTRA=--no-restore-corpus \
	tatoeba-fin2swe-trainjob-bt-pbt

swe2fin-24x12:
	${MAKE} MODELTYPE=transformer-24x12 \
		GPUJOB_HPC_MEM=64g \
		GPUJOB_SUBMIT=-gpu0123 \
	tatoeba-swe2fin-trainjob-bt-pbt






elg-release-models:
	make MODELTYPE=transformer-big release-all-improved-models-bt
	make MODELTYPE=transformer-big release-all-improved-models
	make release-all-improved-models
	make release-all-improved-models-bt

elg-release-tiny-models:
	for l in bul dan deu fin hun nob ron swe tur; do make STUDENT_DATA=pft SRCLANGS=ukr TRGLANGS=$$l release-tiny11-student; done


ukreng-train-student:
	make SRCLANGS=ukr TRGLANGS=eng train-tiny11-student

engukr-train-student:
	make SRCLANGS=eng TRGLANGS=ukr train-tiny11-student

ukreng-test-student:
	make SRCLANGS=ukr TRGLANGS=eng test-tiny11-student
	make SRCLANGS=eng TRGLANGS=ukr test-tiny11-student


# ukreng-quantize-student:
# 	make SRCLANGS=ukr TRGLANGS=eng quantize-tiny11-student
#	make SRCLANGS=ukr TRGLANGS=eng quantize-finetuned-tiny11-student
#	make SRCLANGS=ukr TRGLANGS=eng test-quantized-tiny11-student
#	make SRCLANGS=ukr TRGLANGS=eng test-quantized-finetuned-tiny11-student

engukr-quantize-student:
	make SRCLANGS=eng TRGLANGS=ukr quantize-tiny11-student
	make SRCLANGS=eng TRGLANGS=ukr test-quantized-tiny11-student


## special thing: student models with pivot-based data (does that work?)
## --> does not work very well ...
elg-ukr-students:
	for l in bul dan deu fin hun nob ron swe slk tur; do \
	  ${MAKE} STUDENT_DATA=ftmono-pft-nopar SRCLANGS=ukr TRGLANGS=$$l train-tiny11-student; \
	done


elg-test-tiny2:
	${MAKE} EMAIL= SRCLANGS=ukr TRGLANGS=eng test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=eng TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=eng TRGLANGS=ukr STUDENT_DATA=ftbest-bt-nopar test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=deu TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=deu TRGLANGS=ukr STUDENT_DATA=ftbest-bt-nopar test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=deu TRGLANGS=ukr STUDENT_DATA=ftbest-ftmono-nopar test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=deu TRGLANGS=ukr STUDENT_DATA=pft-pbt-bt test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=ukr TRGLANGS=deu test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=ukr TRGLANGS=deu STUDENT_DATA=ftbest-bt-nopar test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=ukr TRGLANGS=deu STUDENT_DATA=ftbest-ftmono-nopar test-tiny11-student
	${MAKE} EMAIL= SRCLANGS="ces slk" TRGLANGS=ukr STUDENT_DATA=pft-pbt-bt test-tiny11-student
	${MAKE} EMAIL= SRCLANGS=gmq TRGLANGS=ukr STUDENT_DATA=pft-pbt-bt test-tiny11-student

elg-dist-tiny2:
	${MAKE} EMAIL= SRCLANGS=ukr TRGLANGS=eng quantize-tiny11-student release-tiny11-student
	${MAKE} EMAIL= SRCLANGS=eng TRGLANGS=ukr quantize-tiny11-student release-tiny11-student
	${MAKE} EMAIL= SRCLANGS=deu TRGLANGS=ukr STUDENT_DATA=ftbest-ftmono-nopar quantize-tiny11-student release-tiny11-student
	${MAKE} EMAIL= SRCLANGS="ces slk" TRGLANGS=ukr STUDENT_DATA=pft-pbt-bt quantize-tiny11-student release-tiny11-student


elg-test-tiny:
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt SRCLANGS=fin TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt SRCLANGS=ukr TRGLANGS=fin test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=hun TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=hun test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=ron TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=ron test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=swe TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=swe test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=pol TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=pol test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=lit TRGLANGS=ukr test-tiny11-student
	${MAKE} EMAIL= STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=lit test-tiny11-student

elg-dist-tiny:
	${MAKE} STUDENT_DATA=pft-pbt SRCLANGS=fin TRGLANGS=ukr release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt SRCLANGS=ukr TRGLANGS=fin release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=hun TRGLANGS=ukr release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=hun release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ron TRGLANGS=ukr release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=ron release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=swe TRGLANGS=ukr release-tiny11-student
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=swe release-tiny11-student

#	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=pol TRGLANGS=ukr release-tiny11-student
#	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=pol release-tiny11-student
#	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=lit TRGLANGS=ukr release-tiny11-student
#	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=lit release-tiny11-student




## tiny11 transformer model for finnish with pivot data (reuse student recipes)
elg-fin2ukr-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=fin TRGLANGS=ukr train-tiny11-student

elg-ukr2fin-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=fin train-tiny11-student



elg-gmq2ukr-tiny11:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='${DATA_PREPARE_HPCPARAMS} CPUJOB_HPC_DISK=1000' \
		DATA_ALIGN_HPCPARAMS="${DATA_ALIGN_HPCPARAMS} CPUJOB_HPC_DISK=1000" \
		CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 \
		STUDENT_DATA=pft-pbt-bt SRCLANGS="dan isl nno nob nor swe" TRGLANGS=ukr \
		LANGPAIRSTR="gmq-ukr" train-tiny11-student

elg-gmq2ukr-small:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MARIAN_EARLY_STOPPING=15 \
		STUDENT_DATA=ftbest-ftmono-nopar \
		SRCLANGS="dan nob swe" TRGLANGS=ukr \
		LANGPAIRSTR="gmq-ukr" train-small-student



## tiny11 transformer model for finnish with pivot data (reuse student recipes)
elg-hun2ukr-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=hun TRGLANGS=ukr MARIAN_EXTRA=--no-restore-corpus train-tiny11-student

elg-ukr2hun-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=hun train-tiny11-student


elg-ron2ukr-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ron TRGLANGS=ukr train-tiny11-student

elg-ukr2ron-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=ron train-tiny11-student

elg-swe2ukr-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=swe TRGLANGS=ukr train-tiny11-student

elg-ukr2swe-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=swe train-tiny11-student


elg-pol2ukr-tiny11:
	${MAKE} MARIAN_EARLY_STOPPING=20 CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=pft-pbt-bt SRCLANGS=pol TRGLANGS=ukr train-tiny11-student

elg-ukr2pol-tiny11:
	${MAKE} CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=pol train-tiny11-student


elg-lit2ukr-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=lit TRGLANGS=ukr train-tiny11-student

elg-ukr2lit-tiny11:
	${MAKE} STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr TRGLANGS=lit train-tiny11-student


elg-pol2ukr-student2:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MARIAN_EARLY_STOPPING=15 CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=pft-pbt-bt-xb SRCLANGS=pol TRGLANGS=ukr train-tiny11-student

elg-ukr2pol-student2:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MARIAN_EARLY_STOPPING=15 CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=pft-pbt-bt-xb SRCLANGS=ukr TRGLANGS=pol train-tiny11-student





elg-ces_slk2ukr-tiny11:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus GPUJOB_HPC_MEM=24g \
		DATA_PREPARE_HPCPARAMS='${DATA_PREPARE_HPCPARAMS} CPUJOB_HPC_DISK=1000' \
		DATA_ALIGN_HPCPARAMS="${DATA_ALIGN_HPCPARAMS} CPUJOB_HPC_DISK=1000" \
		CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 \
		STUDENT_DATA=pft-pbt-bt SRCLANGS="ces slk" TRGLANGS=ukr train-tiny11-student



elg-deu2ukr-tiny11:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus GPUJOB_HPC_MEM=24g \
		DATA_PREPARE_HPCPARAMS='${DATA_PREPARE_HPCPARAMS} CPUJOB_HPC_DISK=1000' \
		DATA_ALIGN_HPCPARAMS="${DATA_ALIGN_HPCPARAMS} CPUJOB_HPC_DISK=1000" \
		CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 \
		STUDENT_DATA=pft-pbt-bt SRCLANGS=deu TRGLANGS=ukr train-tiny11-student

elg-ukr2deu-tiny11:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus STUDENT_DATA=pft-pbt-bt SRCLANGS=ukr CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 TRGLANGS=deu train-tiny11-student


elg-deu2ukr-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=deu TRGLANGS=ukr train-tiny11-student

elg-ukr2deu-student:
	${MAKE} SRCLANGS=ukr TRGLANGS=deu train-tiny11-student

elg-deu2ukr-student2:
	${MAKE} SRCLANGS=deu TRGLANGS=ukr STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student

elg-deu2ukr-student3:
	${MAKE} MODELZIP=https://object.pouta.csc.fi/Tatoeba-MT-models/deu-ukr/opusTCv20210807+pbt_transformer-align_2022-03-07.zip \
		SRCLANGS=deu TRGLANGS=ukr STUDENT_DATA=ftbest-bt-nopar train-tiny11-student

elg-ukr2deu-student2:
	${MAKE} SRCLANGS=ukr TRGLANGS=deu STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student

elg-ukr2deu-student3:
	${MAKE} MODELZIP=https://object.pouta.csc.fi/Tatoeba-MT-models/ukr-deu/opusTCv20210807_transformer-big_2022-03-14.zip \ SRCLANGS=ukr TRGLANGS=deu STUDENT_DATA=ftbest-bt-nopar train-tiny11-student


elg-deu2ukr-student4:
	${MAKE} MARIAN_EARLY_STOPPING=15 STUDENT_DATA=ftbest-ftmono-nopar SRCLANGS=deu TRGLANGS=ukr train-small-student

elg-ukr2deu-student4:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=deu STUDENT_DATA=ftbest-ftmono-nopar train-small-student


elg-ukr2gmq-small:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=swe STUDENT_DATA=ftbest-ftmono-nopar train-small-student
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=dan STUDENT_DATA=ftbest-ftmono-nopar train-small-student
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=nob STUDENT_DATA=ftbest-ftmono-nopar train-small-student


elg-dan2ukr-small:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=dan TRGLANGS=ukr STUDENT_DATA=ftbest-ftmono-nopar train-small-student

elg-swe2ukr-small:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=swe TRGLANGS=ukr STUDENT_DATA=ftbest-ftmono-nopar train-small-student

elg-nob2ukr-small:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=nob TRGLANGS=ukr STUDENT_DATA=ftbest-ftmono-nopar train-small-student






elg-fin2ukr-student2:
	${MAKE} SUBWORD_VOCAB_SIZE=16000 MARIAN_EARLY_STOPPING=15 SRCLANGS=fin TRGLANGS=ukr CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student


elg-fin2ukr-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=fin TRGLANGS=ukr CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student

elg-ukr2fin-student:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=fin CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student

elg-zle2fin-student:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MARIAN_EARLY_STOPPING=15 \
		DATA_PREPARE_HPCPARAMS='${DATA_PREPARE_HPCPARAMS} CPUJOB_HPC_DISK=1000' \
		DATA_ALIGN_HPCPARAMS="${DATA_ALIGN_HPCPARAMS} CPUJOB_HPC_DISK=1000" \
		CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 \
		STUDENT_DATA=ftbest-ftmono-nopar SRCLANGS="ukr rus" TRGLANGS=fin \
		LANGPAIRSTR="zle-fin-tiny" train-tiny11-student


elg-fin2rus-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=fin TRGLANGS=rus CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student

elg-rus2fin-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=rus TRGLANGS=fin CHECK_TRAINDATA_SIZE=1 CLEAN_CORPUS_TRAINING_DATA=1 STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student




elg-spa2ukr-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=spa TRGLANGS=ukr train-tiny11-student

elg-ukr2spa-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=spa train-tiny11-student


elg-fra2ukr-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=fra TRGLANGS=ukr train-tiny11-student

elg-ukr2fra-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=fra train-tiny11-student

elg-eng2ukr-student:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=eng TRGLANGS=ukr train-tiny11-student

elg-ukr2eng-student:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=eng train-tiny11-student


elg-eng2ukr-student2:
	${MAKE} MARIAN_EARLY_STOPPING=15 STUDENT_DATA=ftbest-ftmono-nopar SRCLANGS=eng TRGLANGS=ukr train-tiny11-student

elg-ukr2eng-student2:
	${MAKE} CONTINUE_EXISTING=1 MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=eng STUDENT_DATA=ftbest-ftmono-nopar train-tiny11-student



elg-eng2ukr-student3:
	${MAKE} MARIAN_EARLY_STOPPING=15 STUDENT_DATA=ftbest-ftmono-nopar SRCLANGS=eng TRGLANGS=ukr train-small-student

elg-ukr2eng-student3:
	${MAKE} MARIAN_EARLY_STOPPING=15 SRCLANGS=ukr TRGLANGS=eng STUDENT_DATA=ftbest-ftmono-nopar train-small-student



## missing evaluations and dist packages
## TODO: should probabubly also restart them!
##       (also zls-zle and zle-zls)

elg-dist-missing:
	for l in deu fra ita por spa; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-eval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-multieval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-eval-testsets; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-dist; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-eval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-multieval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-eval-testsets; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-dist; \
	done
	for l in fin2zle zlw2zle zle2zlw zle2zls zls2zle; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}-eval-bt; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}-multieval-bt; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}-eval-testsets-bt; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}-dist-bt; \
	done
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-multieval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-testsets-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-dist-pbt



elg-zle2fin-pivot:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zle2fin-trainjob-pbt-pft-bt

elg-fin2zle-pivot:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-fin2zle-trainjob-pbt-pft-bt


elg-new-bigmodels: elg-new-bigmodels1 elg-new-bigmodels2 elg-new-bigmodels3 elg-new-bigmodels4

elg-new-bigmodels1:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-deu2fin-trainjob-bt
	for l in spa fra por ita tur ara zho zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.5 tatoeba-$${l}2fin-trainjob; \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.5 tatoeba-$${l}2deu-trainjob; \
	done
	for l in bat gmq heb vie; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.5 tatoeba-$${l}2deu-trainjob; \
	done


elg-new-bigmodels2:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-fin2deu-trainjob-bt
	for l in spa fra por ita tur ara zho zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.5 tatoeba-fin2$$l-trainjob; \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.5 tatoeba-deu2$$l-trainjob; \
	done
	for l in bat gmq heb vie; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.5 tatoeba-deu2$$l-trainjob; \
	done

elg-new-bigmodels3:
	for l in ara bat cel eus fas gmq heb itc sqi tur vie zho zle zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MODELTYPE=transformer-big \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 tatoeba-$${l}2itc-trainjob; \
	done
	for l in cel eus fas sqi; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MODELTYPE=transformer-big \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 tatoeba-$${l}2deu-trainjob; \
	done
	for l in ara bat cel eus fas heb sqi tur vie zho zle zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MODELTYPE=transformer-big \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 tatoeba-$${l}2gmq-trainjob; \
	done


elg-new-bigmodels4:
	for l in ara bat cel eus fas gmq heb sqi tur vie zho zle zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MODELTYPE=transformer-big \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 tatoeba-itc2$${l}-trainjob; \
	done
	for l in cel eus fas sqi; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MODELTYPE=transformer-big \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 tatoeba-deu2$${l}-trainjob; \
	done
	for l in ara bat cel eus fas heb gmq sqi tur vie zho zle zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus \
		MODELTYPE=transformer-big \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 tatoeba-gmq2$${l}-trainjob; \
	done


elg-new-bigmodels5:
	${MAKE} MODELTYPE=transformer-big MARIAN_EXTRA=--no-restore-corpus \
		SKIP_SAME_LANG=1 \
		DATA_SAMPLING_WEIGHT=0.5 \
		SRCLANGS="jpn kor zho" \
		TRGLANGS="jpn kor zho" tatoeba-job



elg-new-bigmodels-multieval:
	-for l in ara deu fin fra gmq heb jpn por spa zho; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-sla2$${l}-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2sla-multieval; \
	done
	-${MAKE} MODELTYPE=transformer-big tatoeba-sla2sla-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-sla2kor-multieval-separate-spm
	-${MAKE} MODELTYPE=transformer-big tatoeba-kor2sla-multieval-separate-spm
	-for l in zls zlw; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2fin-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2deu-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-fin2$${l}-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-deu2$${l}-multieval; \
	done
	-for l in bat gmq; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2deu-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-deu2$${l}-multieval; \
	done
	-for l in ara bat cel eus fas gmq gmw heb sqi tur vie zho zle zls zlw; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2itc-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-itc2$${l}-multieval; \
	done
	-for l in ara bat cel eus fas heb sqi tur vie zho zle zls zlw; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2gmq-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-gmq2$${l}-multieval; \
	done
	-${MAKE} MODELTYPE=transformer-big tatoeba-cel2deu-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-deu2cel-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-bat2bat-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-cel2cel-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-gmq2gmq-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-itc2itc-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-gmw2gmw-multieval



elg-sla-train:
	-for l in ara deu fin fra gmq heb jpn por spa zho; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-sla2$${l}-trainjob; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2sla-trainjob; \
	done
	-${MAKE} MODELTYPE=transformer-big tatoeba-sla2sla-trainjob
	-${MAKE} MODELTYPE=transformer-big tatoeba-sla2kor-trainjob-separate-spm
	-${MAKE} MODELTYPE=transformer-big tatoeba-kor2sla-trainjob-separate-spm

elg-sla-multieval:
	-for l in ara deu fin fra gmq heb jpn por spa zho; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-sla2$${l}-multieval; \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2sla-multieval; \
	done
	-${MAKE} MODELTYPE=transformer-big tatoeba-sla2sla-multieval
	-${MAKE} MODELTYPE=transformer-big tatoeba-sla2kor-multieval-separate-spm
	-${MAKE} MODELTYPE=transformer-big tatoeba-kor2sla-multieval-separate-spm





elg-zho:
	${MAKE} MODELTYPE=transformer-big tatoeba-zho2eng-trainjob


elg-continue-missing:
	for l in deu fra ita por spa; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-trainjob; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-trainjob; \
	done
	${MAKE} MODELTYPE=transformer-big tatoeba-fin2zle-trainjob-bt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-trainjob-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-zlw2zle-trainjob-bt
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2zlw-trainjob-bt
	${MAKE} MODELTYPE=transformer-big tatoeba-zls2zle-trainjob-bt
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2zls-trainjob-bt

elg-zlw2zle-xb:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 MARIAN_EXTRA=--no-restore-corpus tatoeba-zlw2zle-trainjob-bt-xb

elg-zle2zlw-xb:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 MARIAN_EXTRA=--no-restore-corpus tatoeba-zle2zlw-trainjob-bt-xb



elg-ukr-students-test:
	${MAKE} STUDENT_DATA=ftmono-pft-nopar SRCLANGS=ukr TRGLANGS=deu train-tiny11-student
	${MAKE} STUDENT_DATA=ftmono-pft-nopar SRCLANGS=ukr TRGLANGS=hun train-tiny11-student


elg-eval: 
	${MAKE} elg-eval-tfbig
	${MAKE} elg-eval-multi
	${MAKE} elg-eval-zle
	${MAKE} elg-pivot-eval

elg-eval-tfbig:
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

elg-eval-multi:
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	    ${MAKE} MODELTYPE=transformer-big SRCLANGS="$$l" TRGLANGS=eng eval-bt-tatoeba; \
	    ${MAKE} MODELTYPE=transformer-big SRCLANGS="$$l" TRGLANGS=eng tatoeba-multilingual-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big SRCLANGS="$$l" TRGLANGS=eng eval-testsets-bt-tatoeba; \
	    ${MAKE} MODELTYPE=transformer-big TRGLANGS="$$l" SRCLANGS=eng eval-bt-tatoeba; \
	    ${MAKE} MODELTYPE=transformer-big TRGLANGS="$$l" SRCLANGS=eng tatoeba-multilingual-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big TRGLANGS="$$l" SRCLANGS=eng eval-testsets-bt-tatoeba; \
	done

elg-eval-zle:
	for p in zle2zle zlw2zle zle2fin fin2zle zle2zlw zls2zle zle2zls; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-testsets-bt; \
	done
	for p in bat2zle zle2bat; do \
	    ${MAKE} tatoeba-$${p}-eval; \
	    ${MAKE} tatoeba-$${p}-multieval; \
	    ${MAKE} tatoeba-$${p}-eval-testsets; \
	done

elg-release-zlszle:
	for p in zls2zle zle2zls; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-testsets-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-dist-bt; \
	done

elg-release-cesslk2ukr:
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr eval-pbt-tatoeba
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr tatoeba-multilingual-eval-pbt
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr release-pbt-tatoeba

elg-release-ukr2cesslk:
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr eval-pft-tatoeba
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr tatoeba-multilingual-eval-pft
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr release-pft-tatoeba



elg-eval-big2zle:
	for l in deu fra spa por ita; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-eval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-multieval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-zle2$${l}-eval-testsets; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-eval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-multieval; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${l}2zle-eval-testsets; \
	done

elg-eng2zle-xb:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big CONTINUE_EXISTING=1 tatoeba-eng2zle-trainjob-bt-xb

elg-zle2eng-xb:
	${MAKE} MARIAN_EARLY_STOPPING=25 MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big CONTINUE_EXISTING=1 tatoeba-zle2eng-trainjob-bt-xb


elg-fin2zle-xb:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big CONTINUE_EXISTING=1 tatoeba-fin2zle-trainjob-pbt-pft-bt-xb
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big CONTINUE_EXISTING=1 tatoeba-zle2fin-trainjob-pbt-pft-bt-xb



elg-pivot-eval:
	for l in dan swe fin deu ron tur; do \
	  if [ -e work/$$l-ukr ]; then \
	    ${MAKE} tatoeba-$${l}2ukr-eval-pbt; \
	  fi; \
	  if [ -e work/ukr-$$l ]; then \
	    ${MAKE} tatoeba-ukr2$${l}-eval-pft; \
	  fi; \
	done
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr eval-pbt-tatoeba
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr tatoeba-multilingual-eval-pbt
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr eval-pft-tatoeba
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr tatoeba-multilingual-eval-pft
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-multieval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-testsets-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-eval-pft
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-multieval-pft
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-eval-testsets-pft


# temporary - eval models I forgot to evaluate so far ...
elg-eval-extra:
	for p in bat2zle zle2bat; do \
	    ${MAKE} tatoeba-$${p}-eval; \
	    ${MAKE} tatoeba-$${p}-multieval; \
	    ${MAKE} tatoeba-$${p}-eval-testsets; \
	done
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-multieval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-testsets-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-eval-pft
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-multieval-pft
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-eval-testsets-pft
	for p in zls2zle zle2zls fin2zle zle2fin; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-testsets-bt; \
	done




elg-dist-zle:
	for p in zle2zle zlw2zle zle2zlw; do \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-multieval-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-eval-testsets-bt; \
	    ${MAKE} MODELTYPE=transformer-big tatoeba-$${p}-dist-bt; \
	done


elg-dist-pivot:
	for l in deu dan swe tur fin ron hun; do \
	  ${MAKE} tatoeba-$${l}2ukr-dist-pbt; \
	  ${MAKE} tatoeba-ukr2$${l}-dist-pft; \
	done
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr dist-pbt-tatoeba
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr dist-pft-tatoeba
	${MAKE} tatoeba-gmq2zle-dist-pbt
	${MAKE} tatoeba-zle2gmq-dist-pft



elg-dist-pivot-tmp:
	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr dist-pbt-tatoeba
	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr dist-pft-tatoeba

elg-eval-pivot-tmp:
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-eval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-gmq2zle-multieval-pbt
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-eval-pft
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2gmq-multieval-pft


#	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr eval-pbt-tatoeba
#	${MAKE} SRCLANGS="ces slk" TRGLANGS=ukr tatoeba-multilingual-eval-pbt
#	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr eval-pft-tatoeba
#	${MAKE} TRGLANGS="ces slk" SRCLANGS=ukr tatoeba-multilingual-eval-pft



elg-gmq2zle-pivot:
	${MAKE} MODELTYPE=transformer-big CPUJOB_HPC_MEM=64g tatoeba-gmq2zle-trainjob-pbt

elg-zle2gmq-pivot:
	${MAKE} MODELTYPE=transformer-big CPUJOB_HPC_MEM=64g tatoeba-zle2gmq-trainjob-pft

elg-gmq2zle-xb:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 CPUJOB_HPC_MEM=64g tatoeba-gmq2zle-trainjob-pbt-bt-xb

elg-zle2gmq-xb:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 CPUJOB_HPC_MEM=64g tatoeba-zle2gmq-trainjob-pft-bt-xb




elg-bat2zle:
	${MAKE} tatoeba-bat2zle-trainjob

elg-zle2bat:
	${MAKE} tatoeba-zle2bat-trainjob


elg-dan2ukr:
	${MAKE} tatoeba-dan2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2dan-trainjob-pft

elg-swe2ukr:
	${MAKE} tatoeba-swe2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2swe-trainjob-pft

elg-fin2ukr:
	${MAKE} tatoeba-fin2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2fin-trainjob-pft

elg-ukr2fin:
	${MAKE} tatoeba-ukr2fin-trainjob-pbt-pft




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

elg-hun2ukr:
	${MAKE} tatoeba-hun2ukr-trainjob-pbt
	${MAKE} tatoeba-ukr2hun-trainjob-pft




## continue with pivot-based model training (after shuffling)
## (because it was not shuffled before, now shuffling is done by default)
elg-ukr2deu-continue:
	rm -f work/ukr-deu/*.done
	${MAKE} SRCLANGS=ukr TRGLANGS=deu shuffle-training-data-pft-tatoeba
	${MAKE} MARIAN_EARLY_STOPPING=15 MARIAN_EXTRA=--no-restore-corpus tatoeba-ukr2deu-trainjob-pft

elg-deu2ukr-continue:
	rm -f work/deu-ukr/*.done
	${MAKE} SRCLANGS=deu TRGLANGS=ukr shuffle-training-data-pbt-tatoeba
	${MAKE} MARIAN_EARLY_STOPPING=15 MARIAN_EXTRA=--no-restore-corpus tatoeba-deu2ukr-trainjob-pbt









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
	    ${MAKE} GPUJOB_HPC_MEM=24g WALLTIME=1 MODELTYPE=transformer-big tatoeba-eng2$${l}-${LUMI_EVAL_TASK}-bt.submit; \
	  fi \
	done

elg-all2eng-eval:
	for l in ${ELG_EU_SELECTED} ${ELG_EU_SELECTED_BIG}; do \
	  if [ -e ${wildcard work/$${l}-eng/*.npz} ]; then \
	    ${MAKE} GPUJOB_HPC_MEM=24g WALLTIME=1 MODELTYPE=transformer-big tatoeba-$${l}2eng-${LUMI_EVAL_TASK}-bt.submit; \
	  fi \
	done


elg-tune4ukr2eng:
	${MAKE} MODELTYPE=transformer-big TUNE_SRC=ukr TUNE_TRG=eng tatoeba-zle2eng-langtunejob


## including English as a pivot language
elg-zle2zlw-pivot:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2zlw-trainjob-bt-pivotlang

elg-zlw2zle-pivot:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zlw2zle-trainjob-bt-pivotlang


elg-zle2zlw:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=24g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2zlw-trainjob-bt

elg-zlw2zle:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=24g CPUJOB_HPC_DISK=1000' \
		tatoeba-zlw2zle-trainjob-bt

elg-zle2zls:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=24g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2zls-trainjob-bt

elg-zls2zle:
	${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=24g CPUJOB_HPC_DISK=1000' \
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

elg-big2zle:
	for l in deu fra spa por ita; do \
	  ${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-$${l}2zle-trainjob; \
	done

elg-zle2big:
	for l in deu fra spa por ita; do \
	  ${MAKE} MODELTYPE=transformer-big \
		MARIAN_EXTRA=--no-restore-corpus \
		DATA_PREPARE_HPCPARAMS='CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=1000' \
		tatoeba-zle2$${l}-trainjob; \
	done


elg-zle2fin:
	${MAKE} MODELTYPE=transformer-big tatoeba-zle2fin-trainjob-bt

elg-fin2zle:
	${MAKE} MODELTYPE=transformer-big tatoeba-fin2zle-trainjob-bt



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



# SCORE_BASE_URL = https://github.com/Helsinki-NLP/OPUS-MT-train/blob/master
# SCORE_BASE_URL = https://github.com/Helsinki-NLP/OPUS-MT-train/blob/puhti
SCORE_BASE_URL = https://github.com/Helsinki-NLP/OPUS-MT-leaderboard/blob/master


print-best-eng:
	@grep '^[1-9][0-9]\.' ../scores/eng-*/flores101-devtest/bleu-scores*txt | \
	grep -v 'txt:1[0-5]\.' | ${GREP_MODELS} \
	sed 's/:/	/' | sort -nr | rev | uniq -f2 | rev| cut -f3 | sort -u
	@grep '^[1-9][0-9]\.' ../scores/*-eng/flores101-devtest/bleu-scores*txt | \
	grep -v 'txt:1[0-5]\.' | ${GREP_MODELS} \
	sed 's/:/	/' | sort -nr | rev | uniq -f2 | rev| cut -f3 | sort -u


print-best-ukr:
	@grep '^[1-9][0-9]\.' ../scores/ukr-*/flores101-devtest/bleu-scores*txt | \
	grep -v 'txt:1[0-5]\.' | ${GREP_MODELS} \
	sed 's/:/	/' | sort -nr | rev | uniq -f2 | rev| cut -f3 | sort -u
	@grep '^[1-9][0-9]\.' ../scores/*-ukr/flores101-devtest/bleu-scores*txt | \
	grep -v 'txt:1[0-5]\.' | ${GREP_MODELS} \
	sed 's/:/	/' | sort -nr | rev | uniq -f2 | rev| cut -f3 | sort -u

print-base-ukr:
	make -s GREP_MODELS="grep -v 'transformer-big' | grep -v 'tiny' |" print-best-ukr

print-big-ukr:
	make -s GREP_MODELS="grep 'transformer-big' |" print-best-ukr

print-tiny-ukr:
	make -s GREP_MODELS="grep 'tiny' |" print-best-ukr


print-ukr2x-table:
	@echo '| language pair | lang-IDs | BLEU | model |'
	@echo '|---------------|----------|------|-------|'
	@grep '^[1-9][0-9]\.' ../scores/ukr-*/flores101-devtest/bleu-scores*txt | \
	grep -v 'txt:1[0-5]\.' | ${GREP_MODELS} \
	sed 's/:/	/' | sort -nr | rev | uniq -f2 | rev| sort   > $@.tmp1
	@cut -f3 -d'/' $@.tmp1                                                       > $@.langids
	@cut -f1 $@.langids | xargs iso639 -p  | sed "s/^\"//;s/\"$$//;s#\" \"#\n#g" > $@.langnames
	@cut -f1 $@.tmp1 | sed 's#^\.\.#${SCORE_BASE_URL}#'                          > $@.bleufile
	@cut -f2 $@.tmp1                                                             > $@.bleuscore
	@cut -f3 $@.tmp1                                                             > $@.link
	@paste $@.bleuscore $@.bleufile | sed 's/	/\]\(/;s/^/\[/;s/$$/\)/'     > $@.bleulink
	@paste $@.langnames $@.langids $@.bleulink $@.link |\
	grep -v 'Indonesian' | grep -v 'Afrikaans' |\
	sed 's/	/ | /g;s/^/| /;s/$$/ |/' |\
	sed 's#\(https://object.pouta.csc.fi/Tatoeba-MT-models/\)\(.*\).zip#[\2](\1\2.zip)#'
	@rm -f $@.*


print-x2ukr-table:
	@echo '| language pair | lang-IDs | BLEU | model |'
	@echo '|---------------|----------|------|-------|'
	@grep '^[1-9][0-9]\.' ../scores/*-ukr/flores101-devtest/bleu-scores*txt | \
	grep -v 'txt:1[0-5]\.' | ${GREP_MODELS} \
	sed 's/:/	/' | sort -nr | rev | uniq -f2 | rev| sort   > $@.tmp1
	@cut -f3 -d'/' $@.tmp1                                                       > $@.langids
	@cut -f1 $@.langids | xargs iso639 -p  | sed "s/^\"//;s/\"$$//;s#\" \"#\n#g" > $@.langnames
	@cut -f1 $@.tmp1 | sed 's#^\.\.#${SCORE_BASE_URL}#'                          > $@.bleufile
	@cut -f2 $@.tmp1                                                             > $@.bleuscore
	@cut -f3 $@.tmp1                                                             > $@.link
	@paste $@.bleuscore $@.bleufile | sed 's/	/\]\(/;s/^/\[/;s/$$/\)/'     > $@.bleulink
	@paste $@.langnames $@.langids $@.bleulink $@.link |\
	grep -v 'Indonesian' | grep -v 'Afrikaans' |\
	sed 's/	/ | /g;s/^/| /;s/$$/ |/' |\
	sed 's#\(https://object.pouta.csc.fi/Tatoeba-MT-models/\)\(.*\).zip#[\2](\1\2.zip)#'
	@rm -f $@.*

opus-mt-ukr-flores-devtest.md:
	echo "# OPUS-MT models for Ukrainian" > $@
	echo "" >> $@
	echo "The following tables list the best OPUS-MT models for translating from and to Ukrainian according to the flores101 devtest benchmark. Results are given in standard BLEU scores (using sacrebleu)." >> $@
	echo "" >> $@
	echo "## Translations from Ukrainian" >> $@
	echo "" >> $@
	make -s print-ukr2x-table >> $@
	echo "" >> $@
	echo "## Translations to Ukrainian" >> $@
	echo "" >> $@
	make -s print-x2ukr-table >> $@


opus-mt-ukr-flores-devtest-tiny.md:
	echo "# OPUS-MT models for Ukrainian" > $@
	echo "" >> $@
	echo "The following tables list the best OPUS-MT models for translating from and to Ukrainian according to the flores101 devtest benchmark. Results are given in standard BLEU scores (using sacrebleu)." >> $@
	echo "" >> $@
	echo "## Translations from Ukrainian" >> $@
	echo "" >> $@
	make -s GREP_MODELS="grep 'tiny' |" print-ukr2x-table >> $@
	echo "" >> $@
	echo "## Translations to Ukrainian" >> $@
	echo "" >> $@
	make -s GREP_MODELS="grep 'tiny' |" print-x2ukr-table >> $@


opus-mt-ukr-flores-devtest-big.md:
	echo "# OPUS-MT models for Ukrainian" > $@
	echo "" >> $@
	echo "The following tables list the best OPUS-MT models for translating from and to Ukrainian according to the flores101 devtest benchmark. Results are given in standard BLEU scores (using sacrebleu)." >> $@
	echo "" >> $@
	echo "## Translations from Ukrainian" >> $@
	echo "" >> $@
	make -s GREP_MODELS="grep 'transformer-big' |" print-ukr2x-table >> $@
	echo "" >> $@
	echo "## Translations to Ukrainian" >> $@
	echo "" >> $@
	make -s GREP_MODELS="grep 'transformer-big' |" print-x2ukr-table >> $@

opus-mt-ukr-flores-devtest-base.md:
	echo "# OPUS-MT models for Ukrainian" > $@
	echo "" >> $@
	echo "The following tables list the best OPUS-MT models for translating from and to Ukrainian according to the flores101 devtest benchmark. Results are given in standard BLEU scores (using sacrebleu)." >> $@
	echo "" >> $@
	echo "## Translations from Ukrainian" >> $@
	echo "" >> $@
	make -s GREP_MODELS="grep -v 'transformer-big' | grep -v 'tiny' |" print-ukr2x-table >> $@
	echo "" >> $@
	echo "## Translations to Ukrainian" >> $@
	echo "" >> $@
	make -s GREP_MODELS="grep -v 'transformer-big' | grep -v 'tiny' |" print-x2ukr-table >> $@
