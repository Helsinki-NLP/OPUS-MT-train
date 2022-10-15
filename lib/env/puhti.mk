# -*-makefile-*-
#
# environment on puhti@CSC
#


DATA_PREPARE_HPCPARAMS = CPUJOB_HPC_CORES=2 CPUJOB_HPC_MEM=16g CPUJOB_HPC_DISK=3000
DATA_ALIGN_HPCPARAMS = CPUJOB_HPC_CORES=4 CPUJOB_HPC_JOBS=2 CPUJOB_HPC_MEM=64g CPUJOB_HPC_DISK=3000


CSCPROJECT   = project_2002688
# CSCPROJECT   = project_2002982
# CSCPROJECT    = project_2005625
WORKHOME     = ${shell realpath ${PWD}/work}
GPU          = v100
HPC_QUEUE    = small

ifneq (${wildcard /projappl/project_2001194/bin},)
  APPLHOME     = /projappl/project_2001194
  OPUSHOME     = /projappl/nlpl/data/OPUS
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  MOSESSCRIPTS = ${MOSESHOME}/scripts
  EFLOMAL_HOME = ${APPLHOME}/eflomal/
  MARIAN_HOME  = ${APPLHOME}/marian-dev/build/
  MARIAN       = ${APPLHOME}/marian-dev/build
# MARIAN_HOME  = ${APPLHOME}/marian/build/
# MARIAN       = ${APPLHOME}/marian/build
  SPM_HOME     = ${MARIAN_HOME}
  export PATH := ${APPLHOME}/bin:${PATH}
endif


# set LOCAL_SCRATCH to nvme disk if it exists
ifdef SLURM_JOBID
ifneq ($(wildcard /run/nvme/job_${SLURM_JOBID}/tmp),)
  LOCAL_SCRATCH := /run/nvme/job_${SLURM_JOBID}/tmp
endif
endif

# set tmpdir
ifdef LOCAL_SCRATCH
  TMPDIR     := ${LOCAL_SCRATCH}
  TMPWORKDIR := ${LOCAL_SCRATCH}
else
  TMPDIR := /scratch/${CSCPROJECT}
endif


# CPU_MODULES = gcc/8.3.0 cuda/10.1.168 cudnn/7.6.1.34-10.1 intel-mkl/2019.0.4 python-env 
# GPU_MODULES = gcc/8.3.0 cuda/10.1.168 cudnn/7.6.1.34-10.1 intel-mkl/2019.0.4 python-env
CPU_MODULES = perl python-data cuda intel-oneapi-mkl openmpi
GPU_MODULES = perl python-data cuda intel-oneapi-mkl openmpi
LOAD_CPU_ENV = module load ${CPU_MODULES} && module list
LOAD_GPU_ENV = module load ${GPU_MODULES} && module list

ifneq (${HPC_DISK},)
  HPC_GPU_ALLOCATION = --gres=gpu:${GPU}:${NR_GPUS},nvme:${HPC_DISK}
  HPC_CPU_EXTRA1     = \#SBATCH --gres=nvme:${HPC_DISK}
endif

ifneq (${GPUJOB_HPC_DISK},)
  HPC_GPU_ALLOCATION = --gres=gpu:${GPU}:${NR_GPUS},nvme:${GPUJOB_HPC_DISK}
endif

ifneq (${CPUJOB_HPC_DISK},)
  HPC_CPU_EXTRA1  = \#SBATCH --gres=nvme:${CPUJOB_HPC_DISK}
  MAKEARGS       += HPC_DISK=${CPUJOB_HPC_DISK}
endif


## extra SLURM directives (up to 3 numbered variables)
HPC_EXTRA1 = \#SBATCH --account=${CSCPROJECT}


BUILD_MODULES  = StdEnv perl python-data cuda intel-oneapi-mkl openmpi cmake
LOAD_BUILD_ENV = module purge && module load ${BUILD_MODULES} && module list

MARIAN_BUILD_MODULES  = StdEnv perl python-data cuda intel-oneapi-mkl openmpi cmake
LOAD_MARIAN_BUILD_ENV = module purge && module load ${MARIAN_BUILD_MODULES} && module list
MARIAN_BUILD_OPTIONS  =	-DTcmalloc_INCLUDE_DIR=/appl/spack/install-tree/gcc-8.3.0/gperftools-2.7-5w7w2c/include \
			-DTcmalloc_LIBRARY=/appl/spack/install-tree/gcc-8.3.0/gperftools-2.7-5w7w2c/lib/libtcmalloc.so \
			-DTCMALLOC_LIB=/appl/spack/install-tree/gcc-8.3.0/gperftools-2.7-5w7w2c/lib/libtcmalloc.so \
			-DCUDNN=ON \
			-DCOMPILE_CPU=ON \
			-DCOMPILE_CUDA=ON \
			-DCOMPILE_CUDA_SM35=OFF \
			-DCOMPILE_CUDA_SM50=OFF \
			-DCOMPILE_CUDA_SM60=OFF \
			-DCOMPILE_CUDA_SM70=ON \
			-DCOMPILE_CUDA_SM75=OFF \
			-DUSE_DOXYGEN=OFF \
			-DUSE_FBGEMM=1 \
			-DFBGEMM_STATIC=1


LOAD_COMET_ENV = module load pytorch &&
