# -*-makefile-*-
#
# environment on puhti@CSC
#

CPU_MODULES = gcc/6.2.0 mkl
GPU_MODULES = cuda-env/8 mkl




#   CSCPROJECT   = project_2003288
CSCPROJECT   = project_2002688
#  CSCPROJECT   = project_2000309
#  CSCPROJECT   = project_2002982
WORKHOME     = ${shell realpath ${PWD}/work}
APPLHOME     = /projappl/project_2001194
OPUSHOME     = /projappl/nlpl/data/OPUS
MOSESHOME    = ${APPLHOME}/mosesdecoder
MOSESSCRIPTS = ${MOSESHOME}/scripts
EFLOMAL_HOME = ${APPLHOME}/eflomal/
MARIAN_HOME  = ${APPLHOME}/marian/build/
MARIAN       = ${APPLHOME}/marian/build
SPM_HOME     = ${MARIAN_HOME}
GPU          = v100
GPU_MODULES  = python-env 
CPU_MODULES  = python-env
HPC_QUEUE    = small
LOADCPU      = module load ${CPU_MODULES}
LOADGPU      = module load ${GPU_MODULES}
export PATH := ${APPLHOME}/bin:${PATH}


BUILD_MODULES = cmake perl/5.30.0
LOAD_BUILD_ENV = module load ${BUILD_MODULES}

MARIAN_BUILD_MODULES = gcc/8.3.0 cuda/10.1.168 cudnn/7.6.1.34-10.1 intel-mkl/2019.0.4 cmake/3.18.2
LOAD_MARIAN_BUILD_ENV = module purge && module load ${MARIAN_BUILD_MODULES}
MARIAN_BUILD_OPTIONS =	-DTcmalloc_INCLUDE_DIR=/appl/spack/install-tree/gcc-8.3.0/gperftools-2.7-5w7w2c/include \
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
			-DUSE_DOXYGEN=OFF

