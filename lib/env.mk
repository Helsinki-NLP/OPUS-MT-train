# -*-makefile-*-
#
# settings of the environment
# - essential tools and their paths
# - system-specific settings
#


## modules to be loaded in sbatch scripts

CPU_MODULES = gcc/6.2.0 mkl
GPU_MODULES = cuda-env/8 mkl
# GPU_MODULES = python-env/3.5.3-ml cuda-env/8 mkl


# job-specific settings (overwrite if necessary)
# HPC_EXTRA: additional SBATCH commands

NR_GPUS     = 1
HPC_NODES   = 1
HPC_DISK    = 500
HPC_QUEUE   = serial
HPC_GPUQUEUE = gpu
# HPC_MODULES = nlpl-opus python-env/3.4.1 efmaral moses
# HPC_MODULES = nlpl-opus moses cuda-env marian python-3.5.3-ml
HPC_MODULES = ${GPU_MODULES}
HPC_EXTRA   = 

MEM         = 4g
THREADS     = 1
WALLTIME    = 72


## set variables with HPC prefix

HPC_TIME  ?= ${WALLTIME}:00
HPC_CORES ?= ${THREADS}
HPC_MEM   ?= ${MEM}

GPUJOB_HPC_MEM ?= 4g



# GPU    = k80
GPU      = p100
DEVICE   = cuda
LOADCPU  = module load ${CPU_MODULES}
LOADGPU  = module load ${GPU_MODULES}
LOADMODS = echo "nothing to load"

WORKHOME = ${PWD}/work


ifeq (${shell hostname},dx6-ibs-p2)
  APPLHOME     = /opt/tools
  WORKHOME     = ${shell realpath ${PWD}/work}
  OPUSHOME     = tiedeman@taito.csc.fi:/proj/nlpl/data/OPUS/
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  MOSESSCRIPTS = ${MOSESHOME}/scripts
  MARIAN_HOME  = ${APPLHOME}/marian/build/
  MARIAN       = ${APPLHOME}/marian/build
else ifeq (${shell hostname},dx7-nkiel-4gpu)
  APPLHOME     = /opt/tools
  WORKHOME     = ${shell realpath ${PWD}/work}
  OPUSHOME     = tiedeman@taito.csc.fi:/proj/nlpl/data/OPUS/
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  MOSESSCRIPTS = ${MOSESHOME}/scripts
  MARIAN_HOME  = ${APPLHOME}/marian/build/
  MARIAN       = ${APPLHOME}/marian/build
else ifneq ($(wildcard /wrk/tiedeman/research),)
  APPLHOME     = /proj/memad/tools
  WORKHOME     = /wrk/tiedeman/research/Opus-MT/work
  OPUSHOME     = /proj/nlpl/data/OPUS
  MOSESHOME    = /proj/nlpl/software/moses/4.0-65c75ff/moses
  MOSESSCRIPTS = ${MOSESHOME}/scripts
  MARIAN_HOME  = ${HOME}/appl_taito/tools/marian/build-gpu/
  MARIAN       = ${HOME}/appl_taito/tools/marian/build-gpu
  LOADMODS     = ${LOADGPU}
else ifeq (${shell hostname --domain 2>/dev/null},bullx)
  CSCPROJECT   = project_2002688
  WORKHOME     = ${shell realpath ${PWD}/work}
  APPLHOME     = /projappl/project_2001194
  OPUSHOME     = /projappl/nlpl/data/OPUS
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  MOSESSCRIPTS = ${MOSESHOME}/scripts
  EFLOMAL_HOME = ${APPLHOME}/eflomal/
  MARIAN_HOME  = ${APPLHOME}/marian-dev/build/
  MARIAN       = ${APPLHOME}/marian-dev/build
  SPM_HOME     = ${MARIAN_HOME}
  GPU          = v100
  GPU_MODULES  = python-env 
  CPU_MODULES  = python-env
  HPC_QUEUE    = small
  export PATH := ${APPLHOME}/bin:${PATH}
endif


ifdef LOCAL_SCRATCH
  TMPDIR       = ${LOCAL_SCRATCH}
endif


## tools and their locations

SCRIPTDIR      ?= ${PWD}/scripts

ISO639         ?= ${shell which iso639     || echo 'perl ${PWD}/tools/LanguageCodes/ISO-639-3/bin/iso639'}
PIGZ           ?= ${shell which pigz       || echo ${PWD}/tools/pigz/pigz}
TERASHUF       ?= ${shell which terashuf   || echo ${PWD}/tools/terashuf/terashuf}
MARIAN         ?= ${shell which marian     || echo ${PWD}/tools/marian-dev/build/marian}
MARIAN_HOME    ?= $(dir ${MARIAN})
SPM_HOME       ?= ${dir ${MARIAN}}
FASTALIGN      ?= ${shell which fast_align || echo ${PWD}/tools/fast_align/build/fast_align}
FASTALIGN_HOME ?= ${dir ${FASTALIGN}}
ATOOLS         ?= ${FASTALIGN_HOME}atools
EFLOMAL        ?= ${shell which efmoral || echo ${PWD}/tools/eflomal/eflomal}
EFLOMAL_HOME   ?= ${dir ${EFLOMAL}}
WORDALIGN      ?= ${EFLOMAL_HOME}align.py
EFMORAL        ?= ${EFLOMAL_HOME}efmoral
MOSESSCRIPTS   ?= ${PWD}/tools/moses-scripts/scripts


## marian-nmt binaries

MARIAN_TRAIN   = ${MARIAN_HOME}marian
MARIAN_DECODER = ${MARIAN_HOME}marian-decoder
MARIAN_VOCAB   = ${MARIAN_HOME}marian-vocab



TOKENIZER    = ${MOSESSCRIPTS}/tokenizer
SNMTPATH     = ${APPLHOME}/subword-nmt/subword_nmt

## SentencePiece
SPM_TRAIN    = ${SPM_HOME}spm_train
SPM_ENCODE   = ${SPM_HOME}spm_encode


SORT    := sort -T ${TMPDIR} --parallel=${THREADS}
SHUFFLE := ${shell which ${TERASHUF} || echo "${SORT} --random-sort"}
GZIP    := ${shell which ${PIGZ}     || echo gzip}
GZCAT   := ${GZIP} -cd
ZCAT    := gzip -cd






# TODO: delete those?
MULTEVALHOME = ${APPLHOME}/multeval




## install pre-requisites
## TODO:
## * terashuf (https://github.com/alexandres/terashuf.git)
## * OpusTools-perl (https://github.com/Helsinki-NLP/OpusTools-perl)
## * marian-nmt


PREREQ_TOOLS := ${ISO639} ${ATOOLS} ${PIGZ} ${TERASHUF} ${MARIAN} ${EFMORAL}

PIP  := ${shell which pip3 2>/dev/null || echo pip}
CPAN := ${shell which cpanm 2>/dev/null || echo cpan}

NVIDIA_SMI := ${shell which nvidia-smi 2>/dev/null}
ifneq ($(wildcard ${NVIDIA_SMI}),)
ifeq (${shell nvidia-smi | grep failed | wc -l},1)
  MARIAN_BUILD_OPTIONS=-DCOMPILE_CUDA=off
endif
else
  MARIAN_BUILD_OPTIONS=-DCOMPILE_CUDA=off
endif


PHONY: install-prerequisites install-prereq install-requirements
install-prerequisites install-prereq install-requirements:
	${PIP} install --user -r requirements.txt
	${MAKE} ${PREREQ_TOOLS}


tools/LanguageCodes/ISO-639-3/bin/iso639:
	${MAKE} tools/LanguageCodes/ISO-639-5/lib/ISO/639/5.pm

tools/LanguageCodes/ISO-639-5/lib/ISO/639/5.pm:
	${MAKE} -C tools/LanguageCodes all

tools/fast_align/build/atools:
	mkdir -p ${dir $@}
	cd ${dir $@} && cmake ..
	${MAKE} -C ${dir $@}

tools/pigz/pigz:
	${MAKE} -C ${dir $@}

tools/terashuf/terashuf:
	${MAKE} -C ${dir $@}


## For Mac users:
## - install protobuf: sudo port install protobuf3-cpp
## - install MKL (especially for cpu use):
##   file:///opt/intel/documentation_2020/en/mkl/ps2020/get_started.htm

tools/marian-dev/build/marian:
	mkdir -p ${dir $@}
	cd ${dir $@} && cmake -DUSE_SENTENCEPIECE=on ${MARIAN_BUILD_OPTIONS} ..
	${MAKE} -C ${dir $@} -j


## for Mac users: use gcc to compile eflomal
##
## sudo port install gcc10
## gcc-mp-10 -Ofast -march=native -Wall --std=gnu99 -Wno-unused-function -g -fopenmp -c eflomal.c
## gcc-mp-10 -lm -lgomp -fopenmp  eflomal.o   -o eflomal
##
## sudo port install llvm-devel py-cython py-numpy
## sudo port select --set python python38
## sudo port select --set python3 python38
## sudo port select --set cython cython38
## cd tools/efmoral
## sudo env python3 setup.py install

tools/eflomal/eflomal:
	${MAKE} -C ${dir $@} all
	python3 setup.py install
#	python3 setup.py install --install-dir ${HOME}/.local
