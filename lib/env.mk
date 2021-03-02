# -*-makefile-*-
#
# settings of the environment
# - essential tools and their paths
# - system-specific settings
#

SHELL := /bin/bash


## setup local Perl environment
## better install local::lib and put this into your .bashrc:
##
## eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"

export PATH                := ${HOME}/perl5/bin:${PATH}
export PERL5LIB            := ${HOME}/perl5/lib/perl5:${PERL5LIB}}
export PERL_LOCAL_LIB_ROOT := ${HOME}/perl5:${PERL_LOCAL_LIB_ROOT}}
export PERL_MB_OPT         := --install_base "${HOME}/perl5"
export PERL_MM_OPT         := INSTALL_BASE=${HOME}/perl5


## modules to be loaded in sbatch scripts

CPU_MODULES = gcc/6.2.0 mkl
GPU_MODULES = cuda-env/8 mkl
INSTALL_MODULES = cmake perl/5.30.0
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
LOADCPU  = echo "nothing to load"
LOADGPU  = echo "nothing to load"
LOADMODS = echo "nothing to load"

WORKHOME = ${PWD}/work



ifeq (${shell hostname -d 2>/dev/null},mahti.csc.fi)
#  CSCPROJECT    = project_2002688
  CSCPROJECT   = project_2003093
#  CSCPROJECT   = project_2002982
  WORKHOME      = ${shell realpath ${PWD}/work}
  APPLHOME      = /projappl/project_2003093/
  OPUSHOME      = /projappl/nlpl/data/OPUS
  MOSESHOME     = ${APPLHOME}/install/mosesdecoder
  MOSESSCRIPTS  = ${MOSESHOME}/scripts
  EFLOMAL_HOME  = ${APPLHOME}/install/eflomal/
  MARIAN_HOME   = ${APPLHOME}/install/marian/build/
  MARIAN        = ${MARIAN_HOME}
  SPM_HOME      = ${MARIAN_HOME}
  CPU_MODULES   = python-env
  HPC_QUEUE     = medium
  LOADCPU       = module load ${CPU_MODULES}
  SUBMIT_PREFIX = submitcpu
  export PATH := ${APPLHOME}/bin:${PATH}
else ifeq (${shell hostname},dx6-ibs-p2)
  GPU          = pascal
  APPLHOME     = /opt/tools
  WORKHOME     = ${shell realpath ${PWD}/work}
#  OPUSHOME     = tiedeman@taito.csc.fi:/proj/nlpl/data/OPUS/
#  MOSESHOME    = ${APPLHOME}/mosesdecoder
#  MOSESSCRIPTS = ${MOSESHOME}/scripts
#  MARIAN_HOME  = ${APPLHOME}/marian/build/
#  MARIAN       = ${APPLHOME}/marian/build
#  SUBWORD_HOME = ${APPLHOME}/subword-nmt/subword_nmt
else ifeq (${shell hostname},dx7-nkiel-4gpu)
  GPU          = pascal
  APPLHOME     = /opt/tools
  WORKHOME     = ${shell realpath ${PWD}/work}
  MARIAN_BUILD_OPTIONS += -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-9.2
#			-DPROTOBUF_LIBRARY=/usr/lib/x86_64-linux-gnu/libprotobuf.so.9 \
#	   		-DPROTOBUF_INCLUDE_DIR=/usr/include/google/protobuf \
#			-DPROTOBUF_PROTOC_EXECUTABLE=${PWD}/tools/protobuf/src/protoc
#  OPUSHOME     = tiedeman@taito.csc.fi:/proj/nlpl/data/OPUS/
#  MOSESHOME    = ${APPLHOME}/mosesdecoder
#  MOSESSCRIPTS = ${MOSESHOME}/scripts
#  MARIAN_HOME  = ${APPLHOME}/marian/build/
#  MARIAN       = ${APPLHOME}/marian/build
#  SUBWORD_HOME = ${APPLHOME}/subword-nmt/subword_nmt
else ifneq ($(wildcard /wrk/tiedeman/research),)
  APPLHOME     = /proj/memad/tools
  WORKHOME     = /wrk/tiedeman/research/Opus-MT/work
  OPUSHOME     = /proj/nlpl/data/OPUS
  MOSESHOME    = /proj/nlpl/software/moses/4.0-65c75ff/moses
  MOSESSCRIPTS = ${MOSESHOME}/scripts
  MARIAN_HOME  = ${HOME}/appl_taito/tools/marian/build-gpu/
  MARIAN       = ${HOME}/appl_taito/tools/marian/build-gpu
  LOADCPU      = module load ${CPU_MODULES}
  LOADGPU      = module load ${GPU_MODULES}
  LOADMODS     = ${LOADGPU}
else ifeq (${shell hostname --domain 2>/dev/null},bullx)
  CSCPROJECT   = project_2002688
#  CSCPROJECT   = project_2002982
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
  LOADCPU      = module load ${CPU_MODULES}
  LOADGPU      = module load ${GPU_MODULES}
  export PATH := ${APPLHOME}/bin:${PATH}
endif

SUBMIT_PREFIX ?= submit

ifdef LOCAL_SCRATCH
  TMPDIR       = ${LOCAL_SCRATCH}
endif

TMPDIR ?= /tmp

## tools and their locations

SCRIPTDIR      ?= ${PWD}/scripts
TOOLSDIR       ?= ${PWD}/tools

ISO639         ?= ${shell which iso639    2>/dev/null || echo 'perl ${TOOLSDIR}/LanguageCodes/ISO-639-3/bin/iso639'}
PIGZ           ?= ${shell which pigz      2>/dev/null || echo ${TOOLSDIR}/pigz/pigz}
TERASHUF       ?= ${shell which terashuf  2>/dev/null || echo ${TOOLSDIR}/terashuf/terashuf}
JQ             ?= ${shell which jq        2>/dev/null || echo ${TOOLSDIR}/jq/jq}
PROTOC         ?= ${shell which protoc    2>/dev/null || echo ${TOOLSDIR}/protobuf/bin/protoc}
MARIAN         ?= ${shell which marian    2>/dev/null || echo ${TOOLSDIR}/marian-dev/build/marian}
MARIAN_HOME    ?= $(dir ${MARIAN})
SPM_HOME       ?= ${dir ${MARIAN}}
FASTALIGN      ?= ${shell which fast_align 2>/dev/null || echo ${TOOLSDIR}/fast_align/build/fast_align}
FASTALIGN_HOME ?= ${dir ${FASTALIGN}}
ATOOLS         ?= ${FASTALIGN_HOME}atools
EFLOMAL        ?= ${shell which eflomal   2>/dev/null || echo ${TOOLSDIR}/eflomal/eflomal}
EFLOMAL_HOME   ?= ${dir ${EFLOMAL}}
WORDALIGN      ?= ${EFLOMAL_HOME}align.py
EFLOMAL        ?= ${EFLOMAL_HOME}eflomal
MOSESSCRIPTS   ?= ${TOOLSDIR}/moses-scripts/scripts
TMX2MOSES      ?= ${shell which tmx2moses 2>/dev/null || echo ${TOOLSDIR}/OpusTools-perl/scripts/convert/tmx2moses}

## marian-nmt binaries

MARIAN_TRAIN   = ${MARIAN_HOME}marian
MARIAN_DECODER = ${MARIAN_HOME}marian-decoder
MARIAN_VOCAB   = ${MARIAN_HOME}marian-vocab


TOKENIZER    = ${MOSESSCRIPTS}/tokenizer



## BPE
SUBWORD_BPE  ?= ${shell which subword-nmt 2>/dev/null || echo ${TOOLSDIR}/subword-nmt/subword_nmt/subword_nmt.py}
SUBWORD_HOME ?= ${dir ${SUBWORD_BPE}}
ifeq (${shell which subword-nmt},)
  BPE_LEARN ?= python3 ${SUBWORD_HOME}/learn_bpe.py
  BPE_APPLY ?= python3 ${SUBWORD_HOME}/apply_bpe.py
else
  BPE_LEARN ?= ${SUBWORD_BPE} learn-bpe
  BPE_APPLY ?= ${SUBWORD_BPE} apply-bpe
endif

## SentencePiece
SPM_TRAIN    = ${SPM_HOME}spm_train
SPM_ENCODE   = ${SPM_HOME}spm_encode


SORT    := sort -T ${TMPDIR} --parallel=${THREADS}
SHUFFLE := ${shell which ${TERASHUF} 2>/dev/null || echo "${SORT} --random-sort"}
GZIP    := ${shell which ${PIGZ}     2>/dev/null || echo gzip}
GZCAT   := ${GZIP} -cd
ZCAT    := gzip -cd
UNIQ    := ${SORT} -u





# TODO: delete those?
MULTEVALHOME = ${APPLHOME}/multeval




## install pre-requisites
## TODO:
## * terashuf (https://github.com/alexandres/terashuf.git)
## * OpusTools-perl (https://github.com/Helsinki-NLP/OpusTools-perl)
## * marian-nmt


PREREQ_TOOLS := $(lastword ${ISO639}) ${ATOOLS} ${PIGZ} ${TERASHUF} ${JQ} ${MARIAN} ${EFLOMAL}
PREREQ_PERL  := ISO::639::3 ISO::639::5 OPUS::Tools XML::Parser

PIP  := ${shell which pip3  2>/dev/null || echo pip}
CPAN := ${shell which cpanm 2>/dev/null || echo cpan}

NVIDIA_SMI := ${shell which nvidia-smi 2>/dev/null}
ifneq ($(wildcard ${NVIDIA_SMI}),)
ifeq (${shell nvidia-smi | grep failed | wc -l},1)
  MARIAN_BUILD_OPTIONS += -DCOMPILE_CUDA=off
endif
else
  MARIAN_BUILD_OPTIONS += -DCOMPILE_CUDA=off
endif


PHONY: install-prerequisites install-prereq install-requirements
install-prerequisites install-prereq install-requirements:
	if [ `hostname --domain` = "bullx" ]; then \
	  module load ${INSTALL_MODULES}; \
	fi
	${PIP} install --user -r requirements.txt
	${MAKE} install-perl-modules
	${MAKE} ${PREREQ_TOOLS}

.PHONY: install-perl-modules
install-perl-modules:
	for p in ${PREREQ_PERL}; do \
	  perl -e "use $$p;" 2> /dev/null || ${CPAN} -i $$p; \
	done

${TOOLSDIR}/LanguageCodes/ISO-639-3/bin/iso639:
	${MAKE} tools/LanguageCodes/ISO-639-5/lib/ISO/639/5.pm

${TOOLSDIR}/LanguageCodes/ISO-639-5/lib/ISO/639/5.pm:
	${MAKE} -C tools/LanguageCodes all

${TOOLSDIR}/fast_align/build/atools:
	mkdir -p ${dir $@}
	cd ${dir $@} && cmake ..
	${MAKE} -C ${dir $@}

${TOOLSDIR}/pigz/pigz:
	${MAKE} -C ${dir $@}

${TOOLSDIR}/terashuf/terashuf:
	${MAKE} -C ${dir $@}

${TOOLSDIR}/jq/jq:
	cd ${dir $@} && git submodule update --init
	cd ${dir $@} && autoreconf -fi
	cd ${dir $@} && ./configure --with-oniguruma=builtin
	${MAKE} -C ${dir $@} all

## For Mac users:
## - install protobuf: sudo port install protobuf3-cpp
## - install MKL (especially for cpu use):
##   file:///opt/intel/documentation_2020/en/mkl/ps2020/get_started.htm

${TOOLSDIR}/marian-dev/build/marian: ${PROTOC}
	mkdir -p ${dir $@}
	cd ${dir $@} && cmake -DUSE_SENTENCEPIECE=on ${MARIAN_BUILD_OPTIONS} ..
	${MAKE} -C ${dir $@} -j

${TOOLSDIR}/protobuf/bin/protoc:
	cd tools && git clone https://github.com/protocolbuffers/protobuf.git
	cd tools/protobuf && git submodule update --init --recursive
	cd tools/protobuf && ./autogen.sh
	cd tools/protobuf && ./configure --prefix=${TOOLSDIR}/protobuf
	${MAKE} -C tools/protobuf

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

${TOOLSDIR}/eflomal/eflomal:
	${MAKE} -C ${dir $@} all
	cd ${dir $@} && python3 setup.py install --user
#	python3 setup.py install --install-dir ${HOME}/.local
