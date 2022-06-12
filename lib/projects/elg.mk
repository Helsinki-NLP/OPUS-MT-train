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


elg-new-bigmodels:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-deu2fin-trainjob-bt
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-spa2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-fra2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-por2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-ita2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-tur2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-ara2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zho2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zls2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zlw2fin-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-spa2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-fra2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-por2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-ita2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-tur2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-ara2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zho2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zls2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-zlw2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-bat2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-gmq2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-heb2deu-trainjob
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-vie2deu-trainjob

elg-new-bigmodels1:
	rm -f work/deu-fin/train/*.gz work/deu-fin/train/size_per_language_pair.txt
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-deu2fin-trainjob-bt
	for l in spa fra por ita tur ara zho zls zlw; do \
	  rm -f work/$${l}-fin/train/*.gz work/$${l}-fin/train/size_per_language_pair.txt; \
	  rm -f work/$${l}-deu/train/*.gz work/$${l}-deu/train/size_per_language_pair.txt; \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.3 tatoeba-$${l}2fin-trainjob; \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.3 tatoeba-$${l}2deu-trainjob; \
	done
	for l in bat gmq heb vie; do \
	  rm -f work/$${l}-deu/train/*.gz work/$${l}-deu/train/size_per_language_pair.txt; \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.3 tatoeba-$${l}2deu-trainjob; \
	done


elg-new-bigmodels2:
	${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big tatoeba-fin2deu-trainjob-bt
	for l in spa fra por ita tur ara zho zls zlw; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.3 tatoeba-fin2$$l-trainjob; \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.3 tatoeba-deu2$$l-trainjob; \
	done
	for l in bat gmq heb vie; do \
	  ${MAKE} MARIAN_EXTRA=--no-restore-corpus MODELTYPE=transformer-big DATA_SAMPLING_WEIGHT=0.3 tatoeba-deu2$$l-trainjob; \
	done


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
	${MAKE} MODELTYPE=transformer-big CPUJOB_HPC_MEM=32g tatoeba-gmq2zle-trainjob-pbt

elg-zle2gmq-pivot:
	${MAKE} MODELTYPE=transformer-big CPUJOB_HPC_MEM=32g tatoeba-zle2gmq-trainjob-pft

elg-gmq2zle-xb:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 CPUJOB_HPC_MEM=32g tatoeba-gmq2zle-trainjob-pbt-bt-xb

elg-zle2gmq-xb:
	${MAKE} MODELTYPE=transformer-big CONTINUE_EXISTING=1 CPUJOB_HPC_MEM=32g tatoeba-zle2gmq-trainjob-pft-bt-xb




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
