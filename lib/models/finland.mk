


#-------------------------------------------------------------------
# important secondary langs in Finland
#-------------------------------------------------------------------


fiet:
	${MAKE} SRCLANGS=fi TRGLANGS=et bilingual-medium

fi-so:
	${MAKE} data-fi-so
	${MAKE} train-dynamic-fi-so
	${MAKE} reverse-data-fi-so
	${MAKE} train-dynamic-so-fi

%-fi-so:
	${MAKE} HELDOUTSIZE=0 BPESIZE=4000 DEVSIZE=1000 TESTSIZE=1000 DEVMINSIZE=100 \
		SRCLANGS=fi TRGLANGS=so data \
	${@:-fi-so=}

%-so-fi:
	${MAKE} HELDOUTSIZE=0 BPESIZE=4000 DEVSIZE=1000 TESTSIZE=1000 DEVMINSIZE=100 \
		SRCLANGS=so TRGLANGS=fi data \
	${@:-so-fi=}


fi-xx:
	for l in ru et ar so ku fa sq vi th tr es pl; do \
	  ${MAKE} WALLTIME=72 SRCLANGS="$$l" TRGLANGS=fi \
		HPC_MEM=12g HPC_CORES=2 bilingual-dynamic.submitcpu; \
	done

en-xx:
	for l in so ku fa sq vi th; do \
	  ${MAKE} WALLTIME=72 SRCLANGS="$$l" TRGLANGS=en \
		HPC_MEM=12g HPC_CORES=2 bilingual-dynamic.submitcpu; \
	done


fi-zh:
	${MAKE} SRCLANGS=fi \
		TRGLABGS="cmn cn yue ze_zh zh_cn zh_CN zh_HK zh_tw zh_TW zh_yue zhs zht zh" \
		HPC_MEM=12g HPC_CORES=2 \
	train-dynamic.submitcpu
	${MAKE} TRGLANGS=fi \
		SRCLABGS="cmn cn yue ze_zh zh_cn zh_CN zh_HK zh_tw zh_TW zh_yue zhs zht zh" \
		HPC_MEM=12g HPC_CORES=2 \
	train-dynamic.submitcpu


#-------------------------------------------------------------------
# add THL backtranslation data (and also all other backtranslations)
#-------------------------------------------------------------------

%-thl:
	rm -f ${WORKHOME}/${LANGPAIRSTR}/train.submit
	${MAKE} BACKTRANS_SRC="${BACKTRANS_SRC} ${wildcard backtranslate/thl/${TRG}-${SRC}/latest/*.${SRCEXT}.gz}" \
		BACKTRANS_TRG="${BACKTRANS_TRG} ${wildcard backtranslate/thl/${TRG}-${SRC}/latest/*.${TRGEXT}.gz}" \
		DATASET=${DATASET}+bt+thl USE_BACKTRANS=1 \
		MARIAN_EARLY_STOPPING=10 \
	${@:-thl=}


