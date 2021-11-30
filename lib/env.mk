# -*-makefile-*-
#
# settings of the environment
# - essential tools and their paths
# - system-specific settings
#

SHELL := /bin/bash

# job-specific settings (overwrite if necessary)
# HPC_EXTRA: additional SBATCH commands

NR_GPUS      = 1
HPC_NODES    = 1
HPC_DISK     = 500
HPC_QUEUE    = serial
HPC_GPUQUEUE = gpu


MEM          = 4g
THREADS      = 1
WALLTIME     = 72

GPUJOB_HPC_MEM ?= 4g

GPU          = v100
DEVICE       = cuda
LOAD_CPU_ENV = echo "nothing to load"
LOAD_GPU_ENV = echo "nothing to load"

## default SLURM option to allocate GPU resources
HPC_GPU_ALLOCATION = --gres=gpu:${GPU}:${NR_GPUS}


WORKHOME = ${PWD}/work


## anything that needs to be done to load
## the build environment for specific software

LOAD_BUILD_ENV        = echo "nothing to load"
LOAD_MARIAN_BUILD_ENV = echo "nothing to load"


ifeq (${shell hostname -d 2>/dev/null},mahti.csc.fi)
  include ${REPOHOME}lib/env/mahti.mk
else ifeq (${shell hostname},dx6-ibs-p2)
  include ${REPOHOME}lib/env/dx6.mk
else ifeq (${shell hostname},dx7-nkiel-4gpu)
  include ${REPOHOME}lib/env/dx7.mk
else ifneq ($(wildcard /wrk/tiedeman/research),)
  include ${REPOHOME}lib/env/taito.mk
else ifeq (${shell hostname --domain 2>/dev/null},bullx)
  include ${REPOHOME}lib/env/puhti.mk
endif


## set variables with HPC prefix

HPC_TIME  ?= ${WALLTIME}:00
HPC_CORES ?= ${THREADS}
HPC_MEM   ?= ${MEM}


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



## check that we have a GPU available
## TODO: this assumes that we have nvidia-smi on the system

NVIDIA_SMI := ${shell which nvidia-smi 2>/dev/null}
ifneq ($(wildcard ${NVIDIA_SMI}),)
ifeq (${shell nvidia-smi | grep failed | wc -l},1)
  MARIAN_BUILD_OPTIONS += -DCOMPILE_CUDA=off
  LOAD_ENV = ${LOAD_CPU_ENV}
else
  LOAD_ENV = ${LOAD_GPU_ENV}
endif
else
  MARIAN_BUILD_OPTIONS += -DCOMPILE_CUDA=off
  LOAD_ENV = ${LOAD_CPU_ENV}
endif





# TODO: delete those?
MULTEVALHOME = ${APPLHOME}/multeval




## install prerequisites

PREREQ_TOOLS := $(lastword ${ISO639}) ${ATOOLS} ${PIGZ} ${TERASHUF} ${JQ} ${MARIAN} ${EFLOMAL} ${TMX2MOSES}
PREREQ_PERL  := ISO::639::3 ISO::639::5 OPUS::Tools XML::Parser

PIP  := ${shell which pip3  2>/dev/null || echo pip}
CPAN := ${shell which cpanm 2>/dev/null || echo cpan}


## setup local Perl environment
## better install local::lib and put this into your .bashrc:
##
## eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"

export PATH                := ${HOME}/perl5/bin:${PATH}
export PERL5LIB            := ${HOME}/perl5/lib/perl5:${PERL5LIB}}
export PERL_LOCAL_LIB_ROOT := ${HOME}/perl5:${PERL_LOCAL_LIB_ROOT}}
export PERL_MB_OPT         := --install_base "${HOME}/perl5"
export PERL_MM_OPT         := INSTALL_BASE=${HOME}/perl5


PHONY: install-prerequisites install-prereq install-requirements
install-prerequisites install-prereq install-requirements:
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
	mkdir -p ${TOOLSDIR}
	cd ${TOOLSDIR} && git clone https://github.com/alexandres/terashuf.git
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
	mkdir -p ${TOOLSDIR}
	cd ${TOOLSDIR} && git clone https://github.com/marian-nmt/marian-dev.git
	mkdir -p ${dir $@}
	cd ${dir $@} && ${LOAD_MARIAN_BUILD_ENV} && cmake -DUSE_SENTENCEPIECE=on ${MARIAN_BUILD_OPTIONS} ..
	${MAKE} -C ${dir $@} -j8

${TOOLSDIR}/protobuf/bin/protoc:
	mkdir -p ${TOOLSDIR}
	cd ${TOOLSDIR} && git clone https://github.com/protocolbuffers/protobuf.git
	cd ${TOOLSDIR}/protobuf && git submodule update --init --recursive
	cd ${TOOLSDIR}/protobuf && ./autogen.sh
	cd ${TOOLSDIR}/protobuf && ./configure --prefix=${TOOLSDIR}/protobuf
	${MAKE} -C ${TOOLSDIR}/protobuf

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


${TOOLSDIR}/OpusTools-perl/scripts/convert/tmx2moses:
	mkdir -p ${TOOLSDIR}
	cd ${TOOLSDIR} && https://github.com/Helsinki-NLP/OpusTools-perl
	cd ${TOOLSDIR}/OpusTools-perl && perl Makefile.PL
	cd ${TOOLSDIR}/OpusTools-perl && ${MAKE} install
