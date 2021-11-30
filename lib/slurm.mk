# -*-makefile-*-



# enable e-mail notification by setting EMAIL

WHOAMI = $(shell whoami)
ifeq ("$(WHOAMI)","tiedeman")
  EMAIL = jorg.tiedemann@helsinki.fi
endif


##---------------------------------------------
## submit jobs
##---------------------------------------------


## submit job to gpu queue
##	echo '#SBATCH --exclude=r18g08' >> $@

SLURM_JOBNAME ?= $(subst -,,${LANGPAIRSTR})

%.submit:
	mkdir -p ${WORKDIR}
	echo '#!/bin/bash -l' > $@
	echo '#SBATCH -J "$(SLURM_JOBNAME)${@:.submit=}"' >>$@
	echo '#SBATCH -o $(SLURM_JOBNAME)${@:.submit=}.out.%j' >> $@
	echo '#SBATCH -e $(SLURM_JOBNAME)${@:.submit=}.err.%j' >> $@
	echo '#SBATCH --mem=${HPC_MEM}' >> $@
ifdef EMAIL
	echo '#SBATCH --mail-type=END' >> $@
	echo '#SBATCH --mail-user=${EMAIL}' >> $@
endif
	echo '#SBATCH -n 1' >> $@
	echo '#SBATCH -N 1' >> $@
	echo '#SBATCH -p ${HPC_GPUQUEUE}' >> $@
	echo '#SBATCH ${HPC_GPU_ALLOCATION}' >> $@
	echo '#SBATCH -t ${HPC_TIME}:00' >> $@
	echo '${HPC_EXTRA}' >> $@
	echo '${HPC_EXTRA1}' >> $@
	echo '${HPC_EXTRA2}' >> $@
	echo '${HPC_EXTRA3}' >> $@
	echo '${HPC_GPU_EXTRA1}' >> $@
	echo '${HPC_GPU_EXTRA2}' >> $@
	echo '${HPC_GPU_EXTRA3}' >> $@
	echo '${LOAD_GPU_ENV}'           >> $@
	echo 'cd $${SLURM_SUBMIT_DIR:-.}' >> $@
	echo 'pwd' >> $@
	echo 'echo "Starting at `date`"' >> $@
	echo 'srun ${MAKE} ${MAKEARGS} ${@:.submit=}' >> $@
	echo 'echo "Finishing at `date`"' >> $@
	sbatch $@
	mkdir -p ${WORKDIR}
	mv $@ ${WORKDIR}/$@

# 	echo 'srun ${MAKE} NR=${NR} MODELTYPE=${MODELTYPE} DATASET=${DATASET} SRC=${SRC} TRG=${TRG} PRE_SRC=${PRE_SRC} PRE_TRG=${PRE_TRG} ${MAKEARGS} ${@:.submit=}' >> $@


## submit job to cpu queue

%.submitcpu:
	mkdir -p ${WORKDIR}
	echo '#!/bin/bash -l' > $@
	echo '#SBATCH -J "$(SLURM_JOBNAME)${@:.submitcpu=}"'      >>$@
	echo '#SBATCH -o $(SLURM_JOBNAME)${@:.submitcpu=}.out.%j' >> $@
	echo '#SBATCH -e $(SLURM_JOBNAME)${@:.submitcpu=}.err.%j' >> $@
	echo '#SBATCH --mem=${HPC_MEM}'                           >> $@
ifdef EMAIL
	echo '#SBATCH --mail-type=END'                            >> $@
	echo '#SBATCH --mail-user=${EMAIL}'                       >> $@
endif
	echo '#SBATCH -n ${HPC_CORES}' >> $@
	echo '#SBATCH -N ${HPC_NODES}' >> $@
	echo '#SBATCH -p ${HPC_QUEUE}' >> $@
	echo '#SBATCH -t ${HPC_TIME}:00' >> $@
	echo '${HPC_EXTRA}' >> $@
	echo '${HPC_EXTRA1}' >> $@
	echo '${HPC_EXTRA2}' >> $@
	echo '${HPC_EXTRA3}' >> $@
	echo '${HPC_CPU_EXTRA1}' >> $@
	echo '${HPC_CPU_EXTRA2}' >> $@
	echo '${HPC_CPU_EXTRA3}' >> $@
	echo '${LOAD_GPU_ENV}'           >> $@
	echo 'cd $${SLURM_SUBMIT_DIR:-.}' >> $@
	echo 'pwd' >> $@
	echo 'echo "Starting at `date`"' >> $@
	echo '${MAKE} -j ${HPC_CORES} ${MAKEARGS} ${@:.submitcpu=}' >> $@
	echo 'echo "Finishing at `date`"' >> $@
	sbatch $@
	mkdir -p ${WORKDIR}
	mv $@ ${WORKDIR}/$@


#	echo '${MAKE} -j ${HPC_CORES} DATASET=${DATASET} SRC=${SRC} TRG=${TRG} PRE_SRC=${PRE_SRC} PRE_TRG=${PRE_TRG} ${MAKEARGS} ${@:.submitcpu=}' >> $@
