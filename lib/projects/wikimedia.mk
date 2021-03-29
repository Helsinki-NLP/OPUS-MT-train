
#-------------------------------------------------------------------
# wikimedia tasks
#-------------------------------------------------------------------

as-en:
	${MAKE} data-as-en
	${MAKE} train-dynamic-as-en
	${MAKE} reverse-data-as-en
	${MAKE} train-dynamic-en-as

en-bcl:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" DEVSET=wikimedia all-job

bcl-en:
	${MAKE} SRCLANGS="bcl" TRGLANGS="en" DEVSET=wikimedia all-job


en-bcl-nt:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" \
		DATASET=${DATASET}+nt \
		EXTRA_TRAINSET="new-testament" \
		DEVSET=wikimedia all-job

bcl-en-nt:
	${MAKE} SRCLANGS="bcl" TRGLANGS="en" \
		DATASET=${DATASET}+nt \
		EXTRA_TRAINSET="new-testament" \
		DEVSET=wikimedia all-job

%-en-bcl:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" DEVSET=wikimedia ${@:-en-bcl=}


%-bcl-en:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" DEVSET=wikimedia ${@:-bcl-en=}


%-en-bcl-nt:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" \
		DATASET=${DATASET}+nt \
		EXTRA_TRAINSET="new-testament" \
		DEVSET=wikimedia \
	${@:-en-bcl-nt=}

%-bcl-en-nt:
	${MAKE} SRCLANGS="bcl" TRGLANGS="en" \
		DATASET=${DATASET}+nt \
		EXTRA_TRAINSET="new-testament" \
		DEVSET=wikimedia \
	${@:-bcl-en-nt=}







# ENAS_BPE = 4000
ENAS_BPE  = 1000
ENBCL_BPE = 1000

%-as-en:
	${MAKE} HELDOUTSIZE=0 DEVSIZE=1000 TESTSIZE=1000 DEVMINSIZE=100 BPESIZE=${ENAS_BPE} \
		SRCLANGS="as" TRGLANGS="en" \
	${@:-as-en=}

%-en-as:
	${MAKE} HELDOUTSIZE=0 DEVSIZE=1000 TESTSIZE=1000 DEVMINSIZE=100 BPESIZE=${ENAS_BPE} \
		SRCLANGS="en" TRGLANGS="as" \
	${@:-en-as=}





WIKI_BT2ENG = abk ady afr amh ang ara arg asm ast awa aze bak bam bar bel ben bod bre bul cat ceb ces cha che chr chv cor cos crh csb cym dan deu dsb ell epo est eus ewe ext fao fas fij fin fra frr fry ful gla gle glg glv got grn guj hat hau haw hbs heb hif hin hsb hun hye ibo ido iku ile ilo ina isl ita jam jav jbo jpn kab kal kan kat kaz khm kin kir kom kor ksh kur lad lao lat lav lfn lij lin lit lmo ltz lug mah mai mal mar mdf mkd mlg mlt mnw mon mri msa mwl mya myv nau nav nds nep nld nor nov nya oci ori oss pag pan pap pdc pms pol por pus que roh rom ron rue run rus sag sah san scn sco sin slv sme smo sna snd som spa sqi stq sun swa swe tah tam tat tel tet tgk tgl tha tir ton tpi tso tuk tur tyv udm uig ukr urd uzb vec vie vol war wln wol xal xho yid yor zho zul


## start jobs for all languages where we have back-translations

wiki-eng2all-with-bt:
	for l in ${WIKI_BT2ENG}; do \
	  if [ -d work-tatoeba/$$l-eng ]; then \
	    if [ `cat work-tatoeba/$$l-eng/opus-langlabels.src | tr " " "\n" | grep . | wc -l` -eq 1 ]; then \
	      echo "fetch back-translations for $$l-eng"; \
	      ${MAKE} -C bt-tatoeba SRC=$$l TRG=eng fetch-bt; \
	      echo "start training eng-$$l with backtranslation data"; \
	      ${MAKE} HPC_MEM=32g HPC_CORES=4 tatoeba-eng2$$l-train-bt.submitcpu; \
	    fi \
	  fi \
	done

WIKI_BT2ENG_PARENTS = ${sort ${shell langgroup -p ${WIKI_BT2ENG}}}

wiki-eng2allgroups-with-bt:
	for l in $(filter-out roa,${WIKI_BT2ENG_PARENTS}); do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    echo "mv work-tatoeba/eng-$$l work-tatoeba-old"; \
	    mv work-tatoeba/eng-$$l work-tatoeba-old; \
	  fi; \
	  echo "start training eng-$$l with backtranslation data"; \
	  ${MAKE} HPC_MEM=32g HPC_CORES=4 tatoeba-eng2$$l-train-bt-1m.submitcpu; \
	done

