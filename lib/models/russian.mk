


## include yandex data in training

enru-yandex:
	${MAKE} DATASET=opus+yandex MODELTYPE=transformer SRCLANGS=en TRGLANGS=ru EXTRA_TRAINSET=yandex data
	${MAKE} DATASET=opus+yandex MODELTYPE=transformer SRCLANGS=en TRGLANGS=ru EXTRA_TRAINSET=yandex reverse-data
	${MAKE} DATASET=opus+yandex MODELTYPE=transformer SRCLANGS=en TRGLANGS=ru EXTRA_TRAINSET=yandex \
		WALLTIME=72 HPC_CORES=1 HPC_MEM=8g MARIAN_WORKSPACE=12000 MARIAN_EARLY_STOPPING=15 train.submit-multigpu
	${MAKE} DATASET=opus+yandex MODELTYPE=transformer SRCLANGS=ru TRGLANGS=en EXTRA_TRAINSET=yandex \
		WALLTIME=72 HPC_CORES=1 HPC_MEM=4g MARIAN_EARLY_STOPPING=15 train.submit-multigpu

enru-yandex-bt:
	${MAKE} DATASET=opus+yandex MODELTYPE=transformer SRCLANGS=en TRGLANGS=ru EXTRA_TRAINSET=yandex data-bt
	${MAKE} DATASET=opus+yandex MODELTYPE=transformer SRCLANGS=en TRGLANGS=ru EXTRA_TRAINSET=yandex \
		WALLTIME=72 HPC_CORES=1 HPC_MEM=12g MARIAN_WORKSPACE=12000 MARIAN_EARLY_STOPPING=15 train-bt.submit-multigpu

