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

%.submit:
	mkdir -p ${WORKDIR}
	echo '#!/bin/bash -l' > $@
	echo '#SBATCH -J "$(subst -,,${LANGPAIRSTR})${@:.submit=}"' >>$@
	echo '#SBATCH -o $(subst -,,${LANGPAIRSTR})${@:.submit=}.out.%j' >> $@
	echo '#SBATCH -e $(subst -,,${LANGPAIRSTR})${@:.submit=}.err.%j' >> $@
	echo '#SBATCH --mem=${HPC_MEM}' >> $@
	echo '#SBATCH --exclude=r18g08' >> $@
ifdef EMAIL
	echo '#SBATCH --mail-type=END' >> $@
	echo '#SBATCH --mail-user=${EMAIL}' >> $@
endif
	echo '#SBATCH -n 1' >> $@
	echo '#SBATCH -N 1' >> $@
	echo '#SBATCH -p ${HPC_GPUQUEUE}' >> $@
ifeq (${shell hostname -d 2>/dev/null},mahti.csc.fi)
	echo '#SBATCH --account=${CSCPROJECT}' >> $@
endif
ifeq (${shell hostname --domain 2>/dev/null},bullx)
	echo '#SBATCH --account=${CSCPROJECT}' >> $@
	echo '#SBATCH --gres=gpu:${GPU}:${NR_GPUS},nvme:${HPC_DISK}' >> $@
else
	echo '#SBATCH --gres=gpu:${GPU}:${NR_GPUS}' >> $@
endif
	echo '#SBATCH -t ${HPC_TIME}:00' >> $@
	echo 'module use -a /proj/nlpl/modules' >> $@
	for m in ${GPU_MODULES}; do \
	  echo "module load $$m" >> $@; \
	done
	echo 'module list' >> $@
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
	echo '#SBATCH -J "$(subst -,,${LANGPAIRSTR})${@:.submitcpu=}"' >>$@
	echo '#SBATCH -o $(subst -,,${LANGPAIRSTR})${@:.submitcpu=}.out.%j' >> $@
	echo '#SBATCH -e $(subst -,,${LANGPAIRSTR})${@:.submitcpu=}.err.%j' >> $@
	echo '#SBATCH --mem=${HPC_MEM}' >> $@
ifdef EMAIL
	echo '#SBATCH --mail-type=END' >> $@
	echo '#SBATCH --mail-user=${EMAIL}' >> $@
endif
ifeq (${shell hostname -d 2>/dev/null},mahti.csc.fi)
	echo '#SBATCH --account=${CSCPROJECT}' >> $@
endif
ifeq (${shell hostname --domain 2>/dev/null},bullx)
	echo '#SBATCH --account=${CSCPROJECT}' >> $@
	echo '#SBATCH --gres=nvme:${HPC_DISK}' >> $@
endif
	echo '#SBATCH -n ${HPC_CORES}' >> $@
	echo '#SBATCH -N ${HPC_NODES}' >> $@
	echo '#SBATCH -p ${HPC_QUEUE}' >> $@
	echo '#SBATCH -t ${HPC_TIME}:00' >> $@
	echo '${HPC_EXTRA}' >> $@
	echo 'module use -a /proj/nlpl/modules' >> $@
	for m in ${CPU_MODULES}; do \
	  echo "module load $$m" >> $@; \
	done
	echo 'module list' >> $@
	echo 'cd $${SLURM_SUBMIT_DIR:-.}' >> $@
	echo 'pwd' >> $@
	echo 'echo "Starting at `date`"' >> $@
	echo '${MAKE} -j ${HPC_CORES} ${MAKEARGS} ${@:.submitcpu=}' >> $@
	echo 'echo "Finishing at `date`"' >> $@
	sbatch $@
	mkdir -p ${WORKDIR}
	mv $@ ${WORKDIR}/$@


#	echo '${MAKE} -j ${HPC_CORES} DATASET=${DATASET} SRC=${SRC} TRG=${TRG} PRE_SRC=${PRE_SRC} PRE_TRG=${PRE_TRG} ${MAKEARGS} ${@:.submitcpu=}' >> $@
