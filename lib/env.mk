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

ifeq (${shell hostname},dx6-ibs-p2)
  APPLHOME     = /opt/tools
  WORKHOME     = ${shell realpath ${PWD}/work}
  OPUSHOME     = tiedeman@taito.csc.fi:/proj/nlpl/data/OPUS/
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  MARIAN       = ${APPLHOME}/marian/build
  LOADMODS     = echo "nothing to load"
else ifeq (${shell hostname},dx7-nkiel-4gpu)
  APPLHOME     = /opt/tools
  WORKHOME     = ${shell realpath ${PWD}/work}
  OPUSHOME     = tiedeman@taito.csc.fi:/proj/nlpl/data/OPUS/
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  MARIAN       = ${APPLHOME}/marian/build
  LOADMODS     = echo "nothing to load"
else ifneq ($(wildcard /wrk/tiedeman/research),)
  APPLHOME     = /proj/memad/tools
  WORKHOME     = /wrk/tiedeman/research/Opus-MT/work
  OPUSHOME     = /proj/nlpl/data/OPUS
  MOSESHOME    = /proj/nlpl/software/moses/4.0-65c75ff/moses
  MARIAN       = ${HOME}/appl_taito/tools/marian/build-gpu
  MARIANCPU    = ${HOME}/appl_taito/tools/marian/build-cpu
  LOADMODS     = ${LOADGPU}
else ifeq (${shell hostname --domain 2>/dev/null},bullx)
  CSCPROJECT   = project_2002688
  WORKHOME     = ${shell realpath ${PWD}/work}
  APPLHOME     = /projappl/project_2001194
  OPUSHOME     = /projappl/nlpl/data/OPUS
  MOSESHOME    = ${APPLHOME}/mosesdecoder
  EFLOMAL_HOME = ${APPLHOME}/eflomal/
  MARIAN       = ${APPLHOME}/marian-dev/build
  MARIANCPU    = ${APPLHOME}/marian-dev/build
  MARIANSPM    = ${APPLHOME}/marian-dev/build
  GPU          = v100
  GPU_MODULES  = python-env 
  CPU_MODULES  = python-env
  LOADMODS     = echo "nothing to load"
  HPC_QUEUE    = small
  export PATH := ${APPLHOME}/bin:${PATH}
endif



ifdef LOCAL_SCRATCH
  TMPDIR       = ${LOCAL_SCRATCH}
endif



## other tools and their locations

SCRIPTDIR    = ${PWD}/scripts
WORDALIGN    = ${EFLOMAL_HOME}align.py
ATOOLS       = ${FASTALIGN_HOME}atools

MULTEVALHOME = ${APPLHOME}/multeval
MOSESSCRIPTS = ${MOSESHOME}/scripts
TOKENIZER    = ${MOSESSCRIPTS}/tokenizer
SNMTPATH     = ${APPLHOME}/subword-nmt/subword_nmt


## SentencePiece
SPM_HOME     = ${MARIANSPM}



# SORT = sort -T ${TMPDIR} -S 50% --parallel=${THREADS}
SORT = sort -T ${TMPDIR} --parallel=${THREADS}
SHUFFLE = ${shell which terashuf 2>/dev/null}
ifeq (${SHUFFLE},)
  SHUFFLE = ${SORT} --random-sort
endif
GZIP := ${shell which pigz 2>/dev/null}
GZIP ?= gzip
ZCAT = ${GZIP} -cd <




## install pre-requisites
## TODO:
## * terashuf (https://github.com/alexandres/terashuf.git)
## * OpusTools-perl (https://github.com/Helsinki-NLP/OpusTools-perl)
## * marian-nmt


PIP := ${shell which pip3 2>/dev/null}
PIP ?= pip

PHONY: install-prerequisites install-prereq install-requirements
install-prerequisites install-prereq install-requirements:
	${PIP} install --user -r requirements.txt

