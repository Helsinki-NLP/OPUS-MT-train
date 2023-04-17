# -*-makefile-*-
#
# environment on mahti@CSC
#


DATA_PREPARE_HPCPARAMS = CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g
DATA_ALIGN_HPCPARAMS = CPUJOB_HPC_CORES=128 CPUJOB_HPC_JOBS=20 CPUJOB_HPC_MEM=128g


# CSCPROJECT    = project_2002982
CSCPROJECT    = project_2002688
# CSCPROJECT    = project_2005625
WORKHOME      = ${shell realpath ${PWD}/work}
OPUSHOME      = /projappl/nlpl/data/OPUS
HPC_QUEUE     = medium
SUBMIT_PREFIX = submitcpu
GPU           = a100
WALLTIME      = 36


MARIAN = ${shell which marian-no-mpi 2>/dev/null || which marian 2>/dev/null || echo ${TOOLSDIR}/marian-dev/build/marian}



## test whether we have permissions to see pre-installed software
ifneq (${wildcard /projappl/project_2003093/install-old},)
  APPLHOME       = /projappl/project_2003093/
  MOSESHOME      = ${APPLHOME}/install/mosesdecoder
  MOSESSCRIPTS   = ${MOSESHOME}/scripts
  EFLOMAL_HOME   = ${APPLHOME}/install/eflomal/
  BROWSERMT_HOME = ${APPLHOME}/install/browsermt
  MARIAN_HOME    = ${APPLHOME}/install/marian-dev/build/
  MARIAN         = ${MARIAN_HOME}
  SPM_HOME       = ${MARIAN_HOME}
  export PATH   := ${APPLHOME}/bin:${PATH}
endif

export PATH                := ${HOME}/perl5/bin:${PATH}:${MARIAN_HOME}:${SPM_HOME}:${FASTALIGN_HOME}
export PERL5LIB            := ${HOME}/perl5/lib/perl5:${PERL5LIB}}
export PERL_LOCAL_LIB_ROOT := ${HOME}/perl5:${PERL_LOCAL_LIB_ROOT}}
export PERL_MB_OPT         := --install_base "${HOME}/perl5"
export PERL_MM_OPT         := INSTALL_BASE=${HOME}/perl5


# set tmpdir
ifdef LOCAL_SCRATCH
  TMPDIR      := ${LOCAL_SCRATCH}
  TMPWORKDIR  := ${LOCAL_SCRATCH}
else
  TMPDIR := /scratch/${CSCPROJECT}
endif


## select queue depending on the number of GPUs allocated
ifeq (${NR_GPUS},1)
 HPC_GPUQUEUE  = gpusmall
else ifeq (${NR_GPUS},2)
 HPC_GPUQUEUE  = gpusmall
else
 HPC_GPUQUEUE  = gpumedium
endif 




CPU_MODULES   = gcc cuda cudnn openblas openmpi
GPU_MODULES   = gcc cuda cudnn openblas openmpi
LOAD_CPU_ENV  = module load ${CPU_MODULES}
LOAD_GPU_ENV  = module load ${GPU_MODULES}


ifneq (${HPC_DISK},)
  HPC_GPU_ALLOCATION = --gres=gpu:${GPU}:${NR_GPUS},nvme:${HPC_DISK}
endif

ifneq (${GPUJOB_HPC_DISK},)
  HPC_GPU_ALLOCATION = --gres=gpu:${GPU}:${NR_GPUS},nvme:${GPUJOB_HPC_DISK}
endif


## extra SLURM directives (up to 5 variables)
HPC_EXTRA1 = \#SBATCH --account=${CSCPROJECT}


## setup for compiling marian-nmt

MARIAN_BUILD_MODULES  = gcc cuda cudnn openblas openmpi cmake
LOAD_MARIAN_BUILD_ENV = module purge && module load ${MARIAN_BUILD_MODULES}

# /appl/spack/v017/install-tree/gcc-11.2.0/gperf-3.1-cxa2un

# MARIAN_BUILD_OPTIONS  = -DTcmalloc_INCLUDE_DIR=/appl/spack/v016/install-tree/gcc-10.3.0/gperftools-2.7-ibnifm/include \
#			-DTcmalloc_LIBRARY=/appl/spack/v016/install-tree/gcc-10.3.0/gperftools-2.7-ibnifm/lib/libtcmalloc.so \
#			-DTCMALLOC_LIB=/appl/spack/v016/install-tree/gcc-10.3.0/gperftools-2.7-ibnifm/lib/libtcmalloc.so \

MARIAN_BUILD_OPTIONS  = -DCUDNN=ON \
			-DCOMPILE_CPU=ON \
			-DCOMPILE_CUDA_SM80=ON \
			-DCOMPILE_CUDA=ON \
			-DCOMPILE_CUDA_SM35=OFF \
			-DCOMPILE_CUDA_SM50=OFF \
			-DCOMPILE_CUDA_SM60=OFF \
			-DCOMPILE_CUDA_SM70=OFF \
			-DCOMPILE_CUDA_SM75=OFF \
			-DCOMPILE_AVX512=OFF \
			-DUSE_MPI=ON \
			-DUSE_DOXYGEN=OFF \
			-DCOMPILE_TURING=OFF \
			-DCOMPILE_VOLTA=OFF \
			-DCOMPILE_PASCAL=OFF \
			-DUSE_FBGEMM=1 \
			-DFBGEMM_STATIC=1


## setup for compiling extract-lex from marian-nmt

# LOAD_EXTRACTLEX_BUILD_ENV = cmake gcc/9.3.0 boost/1.68.0
LOAD_EXTRACTLEX_BUILD_ENV = module load cmake boost

# LOAD_COMET_ENV = module load python-data pytorch cuda &&
# LOAD_COMET_ENV = module purge && module load pytorch && singularity_wrapper exec
# COMET_SCORE = ${HOME}/.local/bin/comet-score

LOAD_COMET_ENV = module purge && module load pytorch &&
