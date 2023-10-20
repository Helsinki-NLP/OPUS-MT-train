# -*-makefile-*-
#
# environment on mahti@CSC
#
# https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/batch-job/
# https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/partitions/


DATA_PREPARE_HPCPARAMS = CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g
DATA_ALIGN_HPCPARAMS = CPUJOB_HPC_CORES=8 CPUJOB_HPC_JOBS=8 CPUJOB_HPC_MEM=64g
# DATA_ALIGN_HPCPARAMS = CPUJOB_HPC_CORES=128 CPUJOB_HPC_JOBS=20 CPUJOB_HPC_MEM=128g
GPUJOB_HPC_CORES = 56
GPUJOB_HPC_MEM = 32g


CSCPROJECT    = project_462000088
WORKHOME      = ${shell realpath ${PWD}/work}
OPUSHOME      = /scratch/project_462000088/data/OPUS
HPC_QUEUE     = small
SUBMIT_PREFIX = submitcpu
GPU           = a100
WALLTIME      = 72


MONITOR := time


# set tmpdir
ifdef LOCAL_SCRATCH
  TMPDIR      := ${LOCAL_SCRATCH}
  TMPWORKDIR  := ${LOCAL_SCRATCH}
else
  TMPDIR := /scratch/${CSCPROJECT}/tmp
endif


## select queue depending on the number of GPUs allocated
HPC_GPUQUEUE  = small-g

# ifeq (${NR_GPUS},1)
#  HPC_GPUQUEUE  = small-g
# else ifeq (${NR_GPUS},2)
#  HPC_GPUQUEUE  = small-g
# else
#  HPC_GPUQUEUE  = standard-g
# endif 



EXTRA_MODULES_DIR = /projappl/project_462000067/public/gnail/software/modules

CPU_MODULES   = cray-python parallel expat Perl wget
GPU_MODULES   = cray-python parallel expat Perl wget
LOAD_CPU_ENV  = module load LUMI/23.03 && module load ${CPU_MODULES}
LOAD_GPU_ENV  = module load LUMI/23.03 && module load ${GPU_MODULES}

# GPU_MODULES   = marian/lumi cray-python parallel
# LOAD_GPU_ENV  = module use -a ${EXTRA_MODULES_DIR} && module load ${GPU_MODULES}


# WGET := /appl/lumi/SW/LUMI-23.03/L/EB/wget/1.21.3-cpeCray-23.03/bin/wget -T 1
# MARIAN_HOME := /projappl/project_462000067/public/gnail/software/marian-320dd390/bin/
# MARIAN := ${MARIAN_HOME}marian


HPC_GPU_ALLOCATION = --gpus-per-node=${NR_GPUS}
HPC_GPU_EXTRA1 = \#SBATCH --cpus-per-task 56

# --gpus 	Set the total number of GPUs to be allocated for the job
# --gpus-per-node 	Set the number of GPUs per node
# --gpus-per-task 	Set the number of GPUs per task

# --mem 	Set the memory per node
# --mem-per-cpu 	Set the memory per allocated CPU cores
# --mem-per-gpu 	Set the memory per allocated GPU


## extra SLURM directives (up to 5 variables)
HPC_EXTRA1 = \#SBATCH --account=${CSCPROJECT}


## setup for compiling marian-nmt

# MARIAN_BUILD_MODULES  = gcc cuda cudnn openblas openmpi cmake
# LOAD_MARIAN_BUILD_ENV = module purge && module load ${MARIAN_BUILD_MODULES}

# /appl/spack/v017/install-tree/gcc-11.2.0/gperf-3.1-cxa2un

# MARIAN_BUILD_OPTIONS  = 

## setup for compiling extract-lex from marian-nmt

# LOAD_EXTRACTLEX_BUILD_ENV = cmake gcc/9.3.0 boost/1.68.0
# LOAD_EXTRACTLEX_BUILD_ENV = module load cmake boost

# LOAD_COMET_ENV = module load python-data pytorch cuda &&
# LOAD_COMET_ENV = module purge && module load pytorch && singularity_wrapper exec
# COMET_SCORE = ${HOME}/.local/bin/comet-score

# LOAD_COMET_ENV = module purge && module load pytorch &&
