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
##
## default resources for GPU jobs
## (most of them relate to CPU resources like MEM, CORES, ...)
## typically we model single node jobs, which can still have multiple GPUs!
GPUJOB_HPC_QUEUE   ?= ${HPC_GPUQUEUE}
GPUJOB_HPC_MEM     ?= 4g
GPUJOB_HPC_NODES   ?= 1
GPUJOB_HPC_CORES   ?= 1
GPUJOB_HPC_THREADS ?= ${GPUJOB_HPC_CORES}
GPUJOB_HPC_JOBS    ?= ${GPUJOB_HPC_THREADS}
GPUJOB_HPC_TIME    ?= ${HPC_TIME}


SLURM_JOBNAME ?= $(subst -,,${LANGPAIRSTR})

## exclude broken nodes:
## list comma separated nodes to be excluded
# BROKEN_NODES = g6301


%.submit:
	mkdir -p ${WORKDIR}
	echo '#!/bin/bash -l' > $@
	echo '#SBATCH -J "$(SLURM_JOBNAME)${@:.submit=}"' >>$@
	echo '#SBATCH -o $(SLURM_JOBNAME)${@:.submit=}.out.%j' >> $@
	echo '#SBATCH -e $(SLURM_JOBNAME)${@:.submit=}.err.%j' >> $@
ifdef EMAIL
	echo '#SBATCH --mail-type=END' >> $@
	echo '#SBATCH --mail-user=${EMAIL}' >> $@
endif
	echo '#SBATCH --mem=${GPUJOB_HPC_MEM}' >> $@
	echo '#SBATCH -n ${GPUJOB_HPC_CORES}' >> $@
	echo '#SBATCH -N ${GPUJOB_HPC_NODES}' >> $@
	echo '#SBATCH -t ${GPUJOB_HPC_TIME}:00' >> $@
	echo '#SBATCH -p ${GPUJOB_HPC_QUEUE}' >> $@
	echo '#SBATCH ${HPC_GPU_ALLOCATION}' >> $@
ifdef BROKEN_NODES
	echo '#SBATCH --exclude=${BROKEN_NODES}' >> $@
endif
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
	echo 'srun ${MAKE} -j ${GPUJOB_HPC_JOBS} ${MAKEARGS} ${@:.submit=}' >> $@
	echo 'echo "Finishing at `date`"' >> $@
	sbatch ${SBATCH_ARGS} $@
	mkdir -p ${WORKDIR}
	mv $@ ${WORKDIR}/$@

# 	echo 'srun ${MAKE} NR=${NR} MODELTYPE=${MODELTYPE} DATASET=${DATASET} SRC=${SRC} TRG=${TRG} PRE_SRC=${PRE_SRC} PRE_TRG=${PRE_TRG} ${MAKEARGS} ${@:.submit=}' >> $@


## submit job to cpu queue
## copy resources to CPUjob-specific variables

CPUJOB_HPC_QUEUE   ?= ${HPC_QUEUE}
CPUJOB_HPC_MEM     ?= ${HPC_MEM}
CPUJOB_HPC_NODES   ?= ${HPC_NODES}
CPUJOB_HPC_TIME    ?= ${HPC_TIME}
CPUJOB_HPC_CORES   ?= ${HPC_CORES}
CPUJOB_HPC_THREADS ?= ${CPUJOB_HPC_CORES}
CPUJOB_HPC_JOBS    ?= ${CPUJOB_HPC_THREADS}

%.submitcpu:
	mkdir -p ${WORKDIR}
	echo '#!/bin/bash -l' > $@
	echo '#SBATCH -J "$(SLURM_JOBNAME)${@:.submitcpu=}"'      >>$@
	echo '#SBATCH -o $(SLURM_JOBNAME)${@:.submitcpu=}.out.%j' >> $@
	echo '#SBATCH -e $(SLURM_JOBNAME)${@:.submitcpu=}.err.%j' >> $@
ifdef EMAIL
	echo '#SBATCH --mail-type=END'                            >> $@
	echo '#SBATCH --mail-user=${EMAIL}'                       >> $@
endif
	echo '#SBATCH --mem=${CPUJOB_HPC_MEM}'                    >> $@
	echo '#SBATCH -n ${CPUJOB_HPC_CORES}' >> $@
	echo '#SBATCH -N ${CPUJOB_HPC_NODES}' >> $@
	echo '#SBATCH -p ${CPUJOB_HPC_QUEUE}' >> $@
	echo '#SBATCH -t ${CPUJOB_HPC_TIME}:00' >> $@
ifdef BROKEN_NODES
	echo '#SBATCH --exclude=${BROKEN_NODES}' >> $@
endif
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
	echo '${MAKE} -j ${CPUJOB_HPC_JOBS} ${MAKEARGS} ${@:.submitcpu=}' >> $@
	echo 'echo "Finishing at `date`"' >> $@
	sbatch ${SBATCH_ARGS} $@
	mkdir -p ${WORKDIR}
	mv $@ ${WORKDIR}/$@


#	echo '${MAKE} -j ${HPC_CORES} DATASET=${DATASET} SRC=${SRC} TRG=${TRG} PRE_SRC=${PRE_SRC} PRE_TRG=${PRE_TRG} ${MAKEARGS} ${@:.submitcpu=}' >> $@
