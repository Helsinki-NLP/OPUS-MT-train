

MEMAD_LANGS = de en fi fr nl sv
MEMAD_LANGS3 = deu eng fin fra nld swe

#-------------------------------------------------------------------
# models for the MeMAD project based on Tatoeba MT challenge data
#-------------------------------------------------------------------

tatoeba-memad: tatoeba-memad-multi tatoeba-memad-bilingual

tatoeba-memad-multi: tatoeba-memad-m2m tatoeba-memad-m2e tatoeba-memad-e2m

tatoeba-memad-e2m:
	${MAKE} TRGLANGS="${MEMAD_LANGS3}" SRCLANGS="eng" \
		HPC_DISK=500 MODELTYPE=transformer-align tatoeba-job-1m

tatoeba-memad-m2e:
	${MAKE} SRCLANGS="${MEMAD_LANGS3}" TRGLANGS="eng" \
		HPC_DISK=500 MODELTYPE=transformer-align tatoeba-job-1m

tatoeba-memad-m2m:
	${MAKE} SRCLANGS="${MEMAD_LANGS3}" TRGLANGS="${MEMAD_LANGS3}" \
		SKIP_LANGPAIRS="deu-deu|eng-eng|fin-fin|fra-fra|nld-nld|swe-swe" \
		HPC_DISK=500 MODELTYPE=transformer-align tatoeba-job-1m

tatoeba-memad-bilingual:
	@for s in ${MEMAD_LANGS3}; do \
	  for t in ${MEMAD_LANGS3}; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} HPC_DISK=500 SRCLANGS=$$s TRGLANGS=$$t \
			MODELTYPE=transformer-align tatoeba-job; \
	    fi \
	  done \
	done



tatoeba-memad-dist:
	${MAKE} TRGLANGS="${MEMAD_LANGS3}" SRCLANGS="eng" \
		MODELTYPE=transformer-align \
		tatoeba-multilingual-eval-1m compare-tatoeba-1m eval-testsets-tatoeba-1m
	${MAKE} TRGLANGS="${MEMAD_LANGS3}" SRCLANGS="eng" \
		TATOEBA_RELEASEDIR=models-memad \
		TATOEBA_MODELSHOME=models-memad \
		MODELTYPE=transformer-align release-tatoeba-1m
	${MAKE} SRCLANGS="${MEMAD_LANGS3}" TRGLANGS="eng" \
		MODELTYPE=transformer-align \
		tatoeba-multilingual-eval-1m compare-tatoeba-1m eval-testsets-tatoeba-1m
	${MAKE} SRCLANGS="${MEMAD_LANGS3}" TRGLANGS="eng" \
		TATOEBA_RELEASEDIR=models-memad \
		TATOEBA_MODELSHOME=models-memad \
		MODELTYPE=transformer-align release-tatoeba-1m
	${MAKE} SRCLANGS="${MEMAD_LANGS3}" TRGLANGS="${MEMAD_LANGS3}" \
		SKIP_LANGPAIRS="deu-deu|eng-eng|fin-fin|fra-fra|nld-nld|swe-swe" \
		MODELTYPE=transformer-align \
		tatoeba-multilingual-eval-1m compare-tatoeba-1m eval-testsets-tatoeba-1m
	${MAKE} SRCLANGS="${MEMAD_LANGS3}" TRGLANGS="${MEMAD_LANGS3}" \
		SKIP_LANGPAIRS="deu-deu|eng-eng|fin-fin|fra-fra|nld-nld|swe-swe" \
		TATOEBA_RELEASEDIR=models-memad \
		TATOEBA_MODELSHOME=models-memad \
		MODELTYPE=transformer-align release-tatoeba-1m
	@for s in ${MEMAD_LANGS3}; do \
	  for t in ${MEMAD_LANGS3}; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t \
			MODELTYPE=transformer-align \
		tatoeba-multilingual-eval compare-tatoeba eval-testsets-tatoeba; \
	      ${MAKE} SRCLANGS=$$s TRGLANGS=$$t \
			TATOEBA_RELEASEDIR=models-memad \
			TATOEBA_MODELSHOME=models-memad \
			MODELTYPE=transformer-align release-tatoeba; \
	    fi \
	  done \
	done



#----------------------------------------------------------------
# fine-tuning on YLE subtitle data
#----------------------------------------------------------------

tatoeba-yletest-fisv:
	${MAKE} TESTSET_HOME=${PWD}/memad-testsets \
		MODELTYPE=transformer-align \
	tatoeba-fin2swe-testsets


MEMAD_SUBTYPE  = FIN-SWE
MEMAD_LANGPAIR = fin2swe
MEMAD_TUNETASK = tune


tatoeba-yletune-all: tatoeba-yletune-finswe-all tatoeba-yletune-swefin-all
tatoeba-yletune-finswe-all: tatoeba-yletune-finswe tatoeba-yletune-fihswe \
			tatoeba-yletune-finswh tatoeba-yletune-fihswh tatoeba-yletune-fisw
tatoeba-yletune-swefin-all: tatoeba-yletune-swefin tatoeba-yletune-swefih \
			tatoeba-yletune-swhfin tatoeba-yletune-swhfih tatoeba-yletune-swfi

tatoeba-yleeval-all:
	${MAKE} MEMAD_TUNETASK=tuneeval tatoeba-yletune-all

tatoeba-yledist-all:
	${MAKE} MEMAD_TUNETASK=tunedist \
		TATOEBA_RELEASEDIR=models-memad-tuned \
		TATOEBA_MODELSHOME=models-memad-tuned \
	tatoeba-yletune-all


tatoeba-yletune-finswe:
	${MAKE} MEMAD_SUBTYPE=FIN-SWE MEMAD_LANGPAIR=fin2swe tatoeba-yletune

tatoeba-yletune-fihswe:
	${MAKE} MEMAD_SUBTYPE=FIH-SWE MEMAD_LANGPAIR=fin2swe tatoeba-yletune

tatoeba-yletune-finswh:
	${MAKE} MEMAD_SUBTYPE=FIN-SWH MEMAD_LANGPAIR=fin2swe tatoeba-yletune

tatoeba-yletune-fihswh:
	${MAKE} MEMAD_SUBTYPE=FIH-SWH MEMAD_LANGPAIR=fin2swe tatoeba-yletune

tatoeba-yletune-fisw:
	${MAKE} MEMAD_SUBTYPE=FI-SW MEMAD_LANGPAIR=fin2swe tatoeba-yletune



tatoeba-yletune-swefin:
	${MAKE} MEMAD_SUBTYPE=FIN-SWE MEMAD_LANGPAIR=swe2fin tatoeba-yletune

tatoeba-yletune-swefih:
	${MAKE} MEMAD_SUBTYPE=FIH-SWE MEMAD_LANGPAIR=swe2fin tatoeba-yletune

tatoeba-yletune-swhfin:
	${MAKE} MEMAD_SUBTYPE=FIN-SWH MEMAD_LANGPAIR=swe2fin tatoeba-yletune

tatoeba-yletune-swhfih:
	${MAKE} MEMAD_SUBTYPE=FIH-SWH MEMAD_LANGPAIR=swe2fin tatoeba-yletune

tatoeba-yletune-swfi:
	${MAKE} MEMAD_SUBTYPE=FI-SW MEMAD_LANGPAIR=swe2fin tatoeba-yletune


tatoeba-yletune:
	${MAKE} TESTSET_HOME=${PWD}/memad-testsets \
		MODELTYPE=transformer-align \
		TUNE_TRAINSET=YLE-train.${MEMAD_SUBTYPE} \
		TUNE_DEVSET=YLE-dev.${MEMAD_SUBTYPE} \
		TUNE_TESTSET=YLE-test.${MEMAD_SUBTYPE} \
	tatoeba-${MEMAD_LANGPAIR}-${MEMAD_TUNETASK}


## tuning with OpenSubtitles
## (does not seem to work well ...)

tatoeba-tune-fisv:
	${MAKE} TESTSET_HOME=${PWD}/memad-testsets \
		MODELTYPE=transformer-align \
	tatoeba-fin2swe-domaintune

tatoeba-testtuned-fisv:
	${MAKE} TESTSET_HOME=${PWD}/memad-testsets \
		MODELTYPE=transformer-align \
	tatoeba-fin2swe-evalall tatoeba-swe2fin-domaintuneeval

tatoeba-tune-svfi:
	${MAKE} TESTSET_HOME=${PWD}/memad-testsets \
		MODELTYPE=transformer-align \
	tatoeba-swe2fin-domaintune

tatoeba-testtuned-svfi:
	${MAKE} TESTSET_HOME=${PWD}/memad-testsets \
		MODELTYPE=transformer-align \
	tatoeba-swe2fin-evalall tatoeba-swe2fin-domaintuneeval


MEMAD_DATATYPE = train
MEMAD_LANGPAIR = fin-swe
MEMAD_LANG3 = FIN
MEMAD_LANG2 = fi

memad-yle-data:
	for s in FIN-SWE FIN-SWH FIH-SWE FIH-SWH FI-SW; do \
	  for d in train dev test; do \
	    ${MAKE} MEMAD_DATATYPE=$$d MEMAD_LANG3=fin MEMAD_LANGPAIR=fin-swe MEMAD_LANG2=fi \
		work-tatoeba/data/simple/YLE-$$d.$$s.fin-swe.clean.fin.gz \
		work-tatoeba/data/simple/YLE-$$d.$$s.fin-swe.clean.fin.labels; \
	    ${MAKE} MEMAD_DATATYPE=$$d MEMAD_LANG3=swe MEMAD_LANGPAIR=fin-swe MEMAD_LANG2=sv \
		work-tatoeba/data/simple/YLE-$$d.$$s.fin-swe.clean.swe.gz \
		work-tatoeba/data/simple/YLE-$$d.$$s.fin-swe.clean.swe.labels; \
	  done \
	done

work-tatoeba/data/simple/YLE-${MEMAD_DATATYPE}.%.${MEMAD_LANGPAIR}.clean.${MEMAD_LANG3}.gz: YLE/%.${MEMAD_DATATYPE}.${MEMAD_LANG2}
	gzip -c < $< > $@

work-tatoeba/data/simple/YLE-${MEMAD_DATATYPE}.%.${MEMAD_LANGPAIR}.clean.${MEMAD_LANG3}.labels:
	echo -n ${MEMAD_LANG3} > $@



#----------------------------------------------------------------
# other OPUS models
#----------------------------------------------------------------

# FIT_DATA_SIZE=2000000 

memad-multi-subs:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" \
		SKIP_LANGPAIRS="de-de|en-en|fi-fi|fr-fr|nl-nl|sv-sv" \
		DEVSET=OpenSubtitles TRAINSET= MODELTYPE=transformer data
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" \
		SKIP_LANGPAIRS="de-de|en-en|fi-fi|fr-fr|nl-nl|sv-sv" \
		DEVSET=OpenSubtitles TRAINSET= MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 train.submit-multigpu

memad-multi-subs-dist:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" \
		SKIP_LANGPAIRS="de-de|en-en|fi-fi|fr-fr|nl-nl|sv-sv" \
		DEVSET=OpenSubtitles TRAINSET= MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 eval
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" \
		SKIP_LANGPAIRS="de-de|en-en|fi-fi|fr-fr|nl-nl|sv-sv" \
		DEVSET=OpenSubtitles TRAINSET= MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 eval-testsets
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" \
		SKIP_LANGPAIRS="de-de|en-en|fi-fi|fr-fr|nl-nl|sv-sv" \
		DEVSET=OpenSubtitles TRAINSET= MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 release

memad-multi-subs-release:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" \
		SKIP_LANGPAIRS="de-de|en-en|fi-fi|fr-fr|nl-nl|sv-sv" \
		DEVSET=OpenSubtitles TRAINSET= MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 release



memad-multi-train:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer data
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 HPC_DISK=1500 train.submit-multigpu

%-memad-multi:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer data
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer \
		${@:-memad-multi=}


memad-multiparallel: memad-multiparallel-basic \
		memad-multiparallel-all \
		memad-multiparallel-intra \
		memad-multiparallel-intra-all

memad-multiparallel-basic:
	mkdir $@
	cd $@ && opus2multi /projappl/nlpl/data/OPUS/OpenSubtitles/latest/xml en de fi fr nl sv

memad-multiparallel-all:
	mkdir $@
	cd $@ && opus2multi /projappl/nlpl/data/OPUS/OpenSubtitles/latest/all en de fi fr nl sv

memad-multiparallel-intra:
	mkdir $@
	cd $@ && opus2multi -i /projappl/nlpl/data/OPUS/OpenSubtitles/latest/xml/en-en.xml.gz\
		/projappl/nlpl/data/OPUS/OpenSubtitles/latest/xml en de fi fr nl sv

memad-multiparallel-intra-all:
	mkdir $@
	cd $@ && opus2multi -i /projappl/nlpl/data/OPUS/OpenSubtitles/latest/xml/en-en.xml.gz\
		/projappl/nlpl/data/OPUS/OpenSubtitles/latest/all en de fi fr nl sv



memad2en:
	${MAKE} LANGS="${MEMAD_LANGS}" PIVOT=en all2pivot


memad-fiensv:
	${MAKE} SRCLANGS=sv TRGLANGS=fi traindata-spm
	${MAKE} SRCLANGS=sv TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=sv TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=sv TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=sv TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi traindata-spm
	${MAKE} SRCLANGS=en TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=en TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=en TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu

memad250-fiensv:
	${MAKE} CONTEXT_SIZE=250 memad-fiensv_doc

memad-fiensv_doc:
	${MAKE} SRCLANGS=sv TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=sv TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=en TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=en TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-doc.submit-multigpu

memad-fiensv_more:
	${MAKE} SRCLANGS=sv TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=sv TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} CONTEXT_SIZE=500 memad-fiensv_doc


memad:
	for s in fi en sv de fr nl; do \
	  for t in en fi sv de fr nl; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/${DATASET}.*.valid${NR.log}; then\
	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t bilingual-dynamic; \
	      fi \
	    fi \
	  done \
	done

#	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t data; \
#	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g train.submit-multigpu; \



fiensv_bpe:
	${MAKE} SRCLANGS=fi TRGLANGS=sv traindata-bpe 
	${MAKE} SRCLANGS=fi TRGLANGS=sv devdata-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=sv wordalign-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-bpe.submit-multigpu
	${MAKE} SRCLANGS=fi TRGLANGS=en traindata-bpe 
	${MAKE} SRCLANGS=fi TRGLANGS=en devdata-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=en wordalign-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-bpe.submit-multigpu


fiensv_spm:
	${MAKE} SRCLANGS=fi TRGLANGS=sv traindata-spm 
	${MAKE} SRCLANGS=fi TRGLANGS=sv devdata-spm
	${MAKE} SRCLANGS=fi TRGLANGS=sv wordalign-spm
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=fi TRGLANGS=en traindata-spm 
	${MAKE} SRCLANGS=fi TRGLANGS=en devdata-spm
	${MAKE} SRCLANGS=fi TRGLANGS=en wordalign-spm
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu

fifr_spm:
	${MAKE} SRCLANGS=fr TRGLANGS=fi traindata-spm 
	${MAKE} SRCLANGS=fr TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=fr TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=fr TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=fr TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=fr WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu

fifr_doc:
	${MAKE} SRCLANGS=fr TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=fr TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=fr TRGLANGS=fi WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=fr TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=fr WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu


fide_spm:
	${MAKE} SRCLANGS=de TRGLANGS=fi traindata-spm 
	${MAKE} SRCLANGS=de TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=de TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=de TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=de TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=de WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu



memad_spm:
	for s in fi en sv de fr nl; do \
	  for t in en fi sv de fr nl; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/*.valid${NR.log}; then\
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t traindata-spm; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t devdata-spm; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t wordalign-spm; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g train-spm.submit-multigpu; \
	      fi \
	    fi \
	  done \
	done


memad_doc:
	for s in fi en sv; do \
	  for t in en fi sv; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/*.valid${NR.log}; then\
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t traindata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t devdata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g MODELTYPE=transformer train-doc.submit-multigpu; \
	      fi \
	    fi \
	  done \
	done

memad_docalign:
	for s in fi en sv; do \
	  for t in en fi sv; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/*.valid${NR.log}; then\
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t traindata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t devdata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g train-doc.submit-multigpu; \
	      fi \
	    fi \
	  done \
	done



enfisv:
	${MAKE} SRCLANGS="en fi sv" TRGLANGS="en fi sv" traindata devdata wordalign
	${MAKE} SRCLANGS="en fi sv" TRGLANGS="en fi sv" HPC_MEM=4g WALLTIME=72 HPC_CORES=1 train.submit-multigpu



en-fiet:
	${MAKE} SRCLANGS="en" TRGLANGS="et fi" traindata devdata
	${MAKE} SRCLANGS="en" TRGLANGS="et fi" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} TRGLANGS="en" SRCLANGS="et fi" traindata devdata
	${MAKE} TRGLANGS="en" SRCLANGS="et fi" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu



memad-multi1:
	for s in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$s" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$s" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	done
	for s in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	  for t in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	    fi \
	  done \
	done

memad-multi2:
	for s in "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	  for t in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	    fi \
	  done \
	done

memad-multi3:
	for s in "${SCANDINAVIAN}" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="en" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="en" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	      ${MAKE} SRCLANGS="en" TRGLANGS="$$s" traindata devdata; \
	      ${MAKE} SRCLANGS="en" TRGLANGS="$$s" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	done
	${MAKE} SRCLANGS="en" TRGLANGS="fr" traindata devdata
	${MAKE} SRCLANGS="en" TRGLANGS="fr" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} SRCLANGS="fr" TRGLANGS="en" traindata devdata
	${MAKE} SRCLANGS="fr" TRGLANGS="en" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu





memad-fi:
	for l in en sv de fr; do \
	  ${MAKE} SRCLANGS=$$l TRGLANGS=fi traindata devdata; \
	  ${MAKE} SRCLANGS=$$l TRGLANGS=fi HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	  ${MAKE} TRGLANGS=$$l SRCLANGS=fi traindata devdata; \
	  ${MAKE} TRGLANGS=$$l SRCLANGS=fi HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	done

