
#-------------------------------------------------------------------
# wikimedia tasks
#-------------------------------------------------------------------

as-en:
	${MAKE} data-as-en
	${MAKE} train-dynamic-as-en
	${MAKE} reverse-data-as-en
	${MAKE} train-dynamic-en-as


BCL_DEVSIZE = 1000
BCL_TESTSIZE = 1000


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
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" \
		DEVSET=wikimedia \
		DEVSIZE=${BCL_DEVSIZE} TESTSIZE=${BCL_TESTSIZE} \
		USE_REST_DEVDATA=1 ${@:-en-bcl=}


%-bcl-en:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" \
		DEVSET=wikimedia \
		DEVSIZE=${BCL_DEVSIZE} TESTSIZE=${BCL_TESTSIZE} \
		USE_REST_DEVDATA=1 ${@:-bcl-en=}


%-en-bcl-nt:
	${MAKE} SRCLANGS="en" TRGLANGS="bcl" \
		DATASET=${DATASET}+nt \
		EXTRA_TRAINSET="new-testament" \
		DEVSET=wikimedia DEVSIZE=${BCL_DEVSIZE} TESTSIZE=${BCL_TESTSIZE} USE_REST_DEVDATA=1 \
	${@:-en-bcl-nt=}

%-bcl-en-nt:
	${MAKE} SRCLANGS="bcl" TRGLANGS="en" \
		DATASET=${DATASET}+nt \
		EXTRA_TRAINSET="new-testament" \
		DEVSET=wikimedia DEVSIZE=${BCL_DEVSIZE} TESTSIZE=${BCL_TESTSIZE} USE_REST_DEVDATA=1 \
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



#-----------------------------------------------------------------------------
# start jobs for all languages where we have back-translations into English
#-----------------------------------------------------------------------------

## languages for which we have back translated wiki data into English
WIKI_BT2ENG = abk ady afr amh ang ara arg asm ast awa aze bak bam bar bel ben bod bre bul cat ceb ces cha che chr chv cor cos crh csb cym dan deu dsb ell epo est eus ewe ext fao fas fij fin fra frr fry ful gla gle glg glv got grn guj hat hau haw hbs heb hif hin hsb hun hye ibo ido iku ile ilo ina isl ita jam jav jbo jpn kab kal kan kat kaz khm kin kir kom kor ksh kur lad lao lat lav lfn lij lin lit lmo ltz lug mah mai mal mar mdf mkd mlg mlt mnw mon mri msa mwl mya myv nau nav nds nep nld nor nov nya oci ori oss pag pan pap pdc pms pol por pus que roh rom ron rue run rus sag sah san scn sco sin slv sme smo sna snd som spa sqi stq sun swa swe tah tam tat tel tet tgk tgl tha tir ton tpi tso tuk tur tyv udm uig ukr urd uzb vec vie vol war wln wol xal xho yid yor zho zul bos_Latn cmn_Hans cmn_Hant hrv ind nno nob srp_Cyrl srp_Latn


## start jobs for all languages where we have back-translations into English
wiki-eng2all-with-bt:
	for l in ${WIKI_BT2ENG}; do \
	   echo "fetch $$l wiki backtranslations"; \
	  ${MAKE} -C bt-tatoeba SRC=$$l TRG=eng fetch-bt; \
	done
	for l in ${sort ${shell iso639 -m -n ${WIKI_BT2ENG}}}; do \
	   echo "start training eng-$$l with backtranslation data"; \
	   ${MAKE} EMAIL= HPC_MEM=32g HPC_CORES=4 tatoeba-eng2$$l-train-bt.submitcpu; \
	done

#	for l in ${WIKI_BT2ENG}; do \
#	  if [ -d work-tatoeba/$$l-eng ]; then \
#	    if [ `cat work-tatoeba/$$l-eng/opus-langlabels.src | tr " " "\n" | grep . | wc -l` -eq 1 ]; then \
#	      echo "fetch back-translations for $$l-eng"; \
#	      ${MAKE} -C bt-tatoeba SRC=$$l TRG=eng fetch-bt; \
#	      echo "start training eng-$$l with backtranslation data"; \
#	      ${MAKE} EMAIL= HPC_MEM=32g HPC_CORES=4 tatoeba-eng2$$l-train-bt.submitcpu; \
#	    fi \
#	  fi \
#	done

wiki-eng2all-with-bt-continue:
	for l in ${WIKI_BT2ENG}; do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    if [ ! `find work-tatoeba/eng-$$l -name 'opus+bt.*model1.done' | wc -l` -gt 0 ]; then \
	      echo "continue training eng-$$l with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-eng2$$l-train-bt; \
	    fi \
	  fi \
	done

wiki-eng2all-with-bt-eval:
	for l in ${WIKI_BT2ENG}; do \
          if [ -d work-tatoeba/eng-$$l ]; then \
            if [ `find work-tatoeba/eng-$$l -name 'opus+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
              ${MAKE} EMAIL= WALLTIME=4 tatoeba-eng2$$l-evalall-bt.submit; \
            fi \
          fi \
        done

#	    if [ `find work-tatoeba/eng-$$l -name 'opus+bt.*model1.done' | wc -l` -gt 0 ]; then \

wiki-eng2all-with-bt-dist:
	for l in ${WIKI_BT2ENG}; do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    if [ `find work-tatoeba/eng-$$l -name 'opus+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      echo "continue training eng-$$l with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-eng2$$l-dist-bt; \
	    fi \
	  fi \
	done



#-----------------------------------------------------------------------------
# models for translating English into language groups with backtranslations 
# (does not fetch back-translations - they need to be available in bt-tatoeba!)
#-----------------------------------------------------------------------------

WIKI_BT2ENG_PARENTS = ${sort ${shell iso639 -m -n ${WIKI_BT2ENG} | xargs langgroup -p}}

wiki-eng2allgroups-with-bt:
	for l in ${WIKI_BT2ENG_PARENTS}; do \
	  echo "start training eng-$$l with backtranslation data"; \
	  ${MAKE} EMAIL= HPC_MEM=32g HPC_CORES=4 tatoeba-eng2$$l-train-bt-1m.submitcpu; \
	done

wiki-eng2allgroups-with-bt-continue:
	for l in ${WIKI_BT2ENG_PARENTS}; do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    if [ ! `find work-tatoeba/eng-$$l -name 'opus1m+bt.*model1.done' | wc -l` -gt 0 ]; then \
	      echo "continue training eng-$$l with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-eng2$$l-train-bt-1m; \
	    fi \
	  fi \
	done

wiki-eng2allgroups-with-bt-eval:
	for l in ${WIKI_BT2ENG_PARENTS}; do \
          if [ -d work-tatoeba/eng-$$l ]; then \
            if [ `find work-tatoeba/eng-$$l -name 'opus1m+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
              ${MAKE} EMAIL= WALLTIME=8 tatoeba-eng2$$l-evalall-bt-1m.submit; \
            fi \
          fi \
        done

#	    if [ `find work-tatoeba/eng-$$l -name 'opus1m+bt.*model1.done' | wc -l` -gt 0 ]; then \

wiki-eng2allgroups-with-bt-dist:
	for l in ${WIKI_BT2ENG_PARENTS}; do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    if [ `find work-tatoeba/eng-$$l -name 'opus1m+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      echo "continue training eng-$$l with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-eng2$$l-dist-bt-1m; \
	    fi \
	  fi \
	done






#-----------------------------------------------------------------------------
# start jobs for all languages where we have back-translations from English
#-----------------------------------------------------------------------------

## languages for which we have back translated wiki data from English

WIKI_ENG2BT = afr ara aze bel ben bos_Latn bre bul cat ceb ces cmn_Hans cmn_Hant cym dan deu ell epo est eus fao fin fra fry gle glg heb hin hrv hun hye ido ilo ina ind isl ita lav lit ltz mal mar mkd mlt msa nds nld nno nob pol por ron run rus spa sqi srp_Cyrl srp_Latn swa swe tam tgl tha tur ukr urd uzb_Latn vie war zho zsm_Latn


wiki-all2eng-with-bt:
	for l in ${WIKI_ENG2BT}; do \
	   echo "fetch $$l wiki backtranslations"; \
	  ${MAKE} -C bt-tatoeba TRG=$$l SRC=eng fetch-bt; \
	done
	for l in ${sort ${shell iso639 -m -n ${WIKI_ENG2BT}}}; do \
	  if [ ! `find work-tatoeba/$$l-eng -name 'opus+bt.*model1.done' | wc -l` -gt 0 ]; then \
	    if [ `find work-tatoeba/$$l-eng -name 'opus+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
	       echo "continue training $$l-eng with backtranslation data"; \
	       ${MAKE} EMAIL= tatoeba-$${l}2eng-train-bt; \
	    else \
	       echo "start training $$l-eng with backtranslation data"; \
	       ${MAKE} EMAIL= HPC_MEM=32g HPC_CORES=4 tatoeba-$${l}2eng-train-bt.submitcpu; \
	    fi \
	  fi \
	done


wiki-all2eng-with-bt-continue:
	for l in ${WIKI_ENG2BT}; do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    if [ ! `find work-tatoeba/$$l-eng -name 'opus+bt.*model1.done' | wc -l` -gt 0 ]; then \
	      echo "continue training $$l-eng with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-$${l}2eng-train-bt; \
	    fi \
	  fi \
	done

wiki-all2eng-with-bt-eval:
	for l in ${WIKI_ENG2BT}; do \
          if [ -d work-tatoeba/$$l-eng ]; then \
            if [ `find work-tatoeba/$$l-eng -name 'opus+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
              ${MAKE} EMAIL= WALLTIME=4 tatoeba-$${l}2eng-evalall-bt.submit; \
            fi \
          fi \
        done

#	    if [ `find work-tatoeba/$$l-eng -name 'opus+bt.*model1.done' | wc -l` -gt 0 ]; then \

wiki-all2eng-with-bt-dist:
	for l in ${WIKI_ENG2BT}; do \
	  if [ -d work-tatoeba/$$l-eng ]; then \
	    if [ `find work-tatoeba/$$l-eng -name 'opus+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      echo "continue training $$l-eng with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-$${l}2eng-dist-bt; \
	    fi \
	  fi \
	done










WIKI_ENG2BT_PARENTS = ${sort ${shell iso639 -m -n ${WIKI_ENG2BT} | xargs langgroup -p}}

wiki-allgroups2eng-with-bt:
	for l in ${WIKI_ENG2BT_PARENTS}; do \
	  if [ ! `find work-tatoeba/$$l-eng -name 'opus1m+bt.*model1.done' | wc -l` -gt 0 ]; then \
	    if [ `find work-tatoeba/$$l-eng -name 'opus1m+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
	       echo "continue training $$l-eng with backtranslation data"; \
	       ${MAKE} EMAIL= tatoeba-$${l}2eng-train-bt-1m; \
	    else \
	       echo "start training $$l-eng with backtranslation data"; \
	       ${MAKE} EMAIL= HPC_MEM=32g HPC_CORES=4 tatoeba-$${l}2eng-train-bt-1m.submitcpu; \
	    fi \
	  fi \
	done


wiki-allgroups2eng-with-bt-continue:
	for l in ${WIKI_ENG2BT_PARENTS}; do \
	  if [ -d work-tatoeba/eng-$$l ]; then \
	    if [ ! `find work-tatoeba/$$l-eng -name 'opus1m+bt.*model1.done' | wc -l` -gt 0 ]; then \
	      echo "continue training $$l-eng with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-$${l}2eng-train-bt-1m; \
	    fi \
	  fi \
	done

wiki-allgroups2eng-with-bt-eval:
	for l in ${WIKI_ENG2BT_PARENTS}; do \
          if [ -d work-tatoeba/$$l-eng ]; then \
            if [ `find work-tatoeba/$$l-eng -name 'opus1m+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
              ${MAKE} EMAIL= WALLTIME=4 tatoeba-$${l}2eng-evalall-bt-1m.submit; \
            fi \
          fi \
        done

#	    if [ `find work-tatoeba/$$l-eng -name 'opus1m+bt.*model1.done' | wc -l` -gt 0 ]; then \

wiki-allgroups2eng-with-bt-dist:
	for l in ${WIKI_ENG2BT_PARENTS}; do \
	  if [ -d work-tatoeba/$$l-eng ]; then \
	    if [ `find work-tatoeba/$$l-eng -name 'opus1m+bt*best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      echo "continue training $$l-eng with backtranslation data"; \
	      ${MAKE} EMAIL= tatoeba-$${l}2eng-dist-bt-1m; \
	    fi \
	  fi \
	done
