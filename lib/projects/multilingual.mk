


icelandic:
	${MAKE} SRCLANGS=is TRGLANGS=en bilingual
	${MAKE} SRCLANGS=is TRGLANGS="da no nn nb sv" bilingual
	${MAKE} SRCLANGS=is TRGLANGS=fi bilingual

germanic:
	${MAKE} LANGS="${GERMANIC}" HPC_DISK=1500 multilingual

scandinavian:
	${MAKE} LANGS="${SCANDINAVIAN}" multilingual-medium


nordic:
	${MAKE} SRCLANGS="${SCANDINAVIAN}" TRGLANGS="${FINNO_UGRIC}" traindata
	${MAKE} SRCLANGS="${SCANDINAVIAN}" TRGLANGS="${FINNO_UGRIC}" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} TRGLANGS="${SCANDINAVIAN}" SRCLANGS="${FINNO_UGRIC}" traindata
	${MAKE} TRGLANGS="${SCANDINAVIAN}" SRCLANGS="${FINNO_UGRIC}" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu

romance:
	${MAKE} SRCLANGS="${ROMANCE}" TRGLANGS="${FINNO_UGRIC}" traindata
	${MAKE} SRCLANGS="${ROMANCE}" TRGLANGS="${FINNO_UGRIC}" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} TRGLANGS="${ROMANCE}" SRCLANGS="${FINNO_UGRIC}" traindata
	${MAKE} TRGLANGS="${ROMANCE}" SRCLANGS="${FINNO_UGRIC}" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu

westgermanic:
	${MAKE} SRCLANGS="${WESTGERMANIC}" TRGLANGS="${FINNO_UGRIC}" traindata
	${MAKE} SRCLANGS="${WESTGERMANIC}" TRGLANGS="${FINNO_UGRIC}" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} TRGLANGS="${WESTGERMANIC}" SRCLANGS="${FINNO_UGRIC}" traindata
	${MAKE} TRGLANGS="${WESTGERMANIC}" SRCLANGS="${FINNO_UGRIC}" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu


germanic-romance:
	${MAKE} SRCLANGS="${ROMANCE}" \
		TRGLANGS="${GERMANIC}" traindata
	${MAKE} HPC_MEM=4g HPC_CORES=1 SRCLANGS="${ROMANCE}" \
		TRGLANGS="${GERMANIC}" train.submit-multigpu
	${MAKE} TRGLANGS="${ROMANCE}" \
		SRCLANGS="${GERMANIC}" traindata devdata
	${MAKE} HPC_MEM=4g HPC_CORES=1 TRGLANGS="${ROMANCE}" \
		SRCLANGS="${GERMANIC}" train.submit-multigpu




