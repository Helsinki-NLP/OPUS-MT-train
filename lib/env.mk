# -*-makefile-*-
#
# settings of the environment
# - essential tools and their paths
# - system-specific settings
#

SHELL    := /bin/bash
PWD      ?= ${shell pwd}
REPOHOME ?= ${PWD}/

# job-specific settings (overwrite if necessary)
# HPC_EXTRA: additional SBATCH commands

NR_GPUS      = 1
HPC_NODES    = 1
# HPC_DISK   = 500
HPC_QUEUE    = serial
HPC_GPUQUEUE = gpu


MEM          ?= 4g
CORES        ?= 1
WALLTIME     ?= 72


GPU          = v100
DEVICE       = cuda
LOAD_CPU_ENV = echo "nothing to load"
LOAD_GPU_ENV = echo "nothing to load"

## default SLURM option to allocate GPU resources
HPC_GPU_ALLOCATION = --gres=gpu:${GPU}:${NR_GPUS}


WORKHOME ?= ${PWD}/work


## anything that needs to be done to load
## the build environment for specific software

LOAD_BUILD_ENV            = echo "nothing to load"
LOAD_MARIAN_BUILD_ENV     = ${LOAD_BUILD_ENV}
LOAD_EXTRACTLEX_BUILD_ENV = ${LOAD_BUILD_ENV}


## load system-specific environments

ifeq (${shell hostname -d 2>/dev/null},mahti.csc.fi)
  HPC_HOST = mahti
  include ${REPOHOME}lib/env/mahti.mk
else ifeq (${shell hostname},dx6-ibs-p2)
  HPC_HOST = dx6
  include ${REPOHOME}lib/env/dx6.mk
else ifeq (${shell hostname},dx7-nkiel-4gpu)
  HPC_HOST = dx7
  include ${REPOHOME}lib/env/dx7.mk
# else ifneq ($(wildcard /wrk/tiedeman/research),)
#   HPC_HOST = taito
#   include ${REPOHOME}lib/env/taito.mk
else ifeq (${shell hostname --domain 2>/dev/null},bullx)
  HPC_HOST = puhti
  include ${REPOHOME}lib/env/puhti.mk
endif


## default settings for CPU cores to be used

CPU_CORES ?= ${CORES}
THREADS   ?= ${CPU_CORES}

## set variables with HPC prefix
## (this is mostly for backwards compatibility)

HPC_TIME    ?= ${WALLTIME}:00
HPC_CORES   ?= ${CPU_CORES}
HPC_THREADS ?= ${HPC_CORES}
HPC_MEM     ?= ${MEM}

## number parallel jobs in make
## (for slurm jobs)

ifdef JOBS
  HPC_JOBS  ?= ${JOBS}
else
  JOBS      ?= ${THREADS}
  HPC_JOBS  ?= ${HPC_THREADS}
endif


SUBMIT_PREFIX ?= submit

ifndef TMPDIR
  TMPDIR := /tmp
endif

ifndef TMPWORKDIR
  TMPWORKDIR := ${shell mktemp -d -p ${TMPDIR}}
endif
export TMPWORKDIR


## tools and their locations

SCRIPTDIR      ?= ${REPOHOME}scripts
TOOLSDIR       ?= ${REPOHOME}tools

ISO639         ?= ${shell which iso639    2>/dev/null || echo 'perl ${TOOLSDIR}/LanguageCodes/ISO-639-3/bin/iso639'}
PIGZ           ?= ${shell which pigz      2>/dev/null || echo ${TOOLSDIR}/pigz/pigz}
TERASHUF       ?= ${shell which terashuf  2>/dev/null || echo ${TOOLSDIR}/terashuf/terashuf}
JQ             ?= ${shell which jq        2>/dev/null || echo ${TOOLSDIR}/jq/jq}
PROTOC         ?= ${shell which protoc    2>/dev/null || echo ${TOOLSDIR}/protobuf/bin/protoc}
MARIAN         ?= ${shell which marian    2>/dev/null || echo ${TOOLSDIR}/marian-dev/build/marian}
MARIAN_HOME    ?= $(dir ${MARIAN})
SPM_HOME       ?= ${dir ${MARIAN}}
FASTALIGN      ?= ${shell which fast_align  2>/dev/null || echo ${TOOLSDIR}/fast_align/build/fast_align}
FASTALIGN_HOME ?= ${dir ${FASTALIGN}}
ATOOLS         ?= ${FASTALIGN_HOME}atools
EFLOMAL        ?= ${shell which eflomal     2>/dev/null || echo ${TOOLSDIR}/eflomal/eflomal}
EFLOMAL_HOME   ?= ${dir ${EFLOMAL}}
WORDALIGN      ?= ${EFLOMAL_HOME}align.py
EFLOMAL        ?= ${EFLOMAL_HOME}eflomal
EXTRACT_LEX    ?= ${shell which extract_lex 2>/dev/null || echo ${TOOLSDIR}/extract-lex/build/extract_lex}
MOSESSCRIPTS   ?= ${TOOLSDIR}/moses-scripts/scripts
TMX2MOSES      ?= ${shell which tmx2moses 2>/dev/null || echo ${TOOLSDIR}/OpusTools-perl/scripts/convert/tmx2moses}

GET_ISO_CODE   ?= ${ISO639} -m


## marian-nmt binaries

MARIAN_TRAIN   = ${MARIAN_HOME}marian
MARIAN_DECODER = ${MARIAN_HOME}marian-decoder
MARIAN_SCORER  = ${MARIAN_HOME}marian-scorer
MARIAN_VOCAB   = ${MARIAN_HOME}marian-vocab


TOKENIZER    = ${MOSESSCRIPTS}/tokenizer


##--------------------------------------------------------
## Tools for creating efficient student models:
##
## browsermt branch of marian-nmt
## https://github.com/browsermt/marian-dev
##--------------------------------------------------------

BROWSERMT_HOME    ?= ${TOOLSDIR}/browsermt
BROWSERMT_TRAIN    = ${BROWSERMT_HOME}/marian-dev/build/marian
BROWSERMT_DECODE   = ${BROWSERMT_HOME}/marian-dev/build/marian-decoder
BROWSERMT_CONVERT  = ${BROWSERMT_HOME}/marian-dev/build/marian-conv



## BPE
SUBWORD_BPE  ?= ${shell which subword-nmt 2>/dev/null || echo ${TOOLSDIR}/subword-nmt/subword_nmt/subword_nmt.py}
SUBWORD_HOME ?= ${dir ${SUBWORD_BPE}}
ifeq (${shell which subword-nmt 2>/dev/null},)
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
WGET    := wget -T 1


## check that we have a GPU available
## TODO: this assumes that we have nvidia-smi on the system

NVIDIA_SMI := ${shell which nvidia-smi 2>/dev/null}
ifneq ($(wildcard ${NVIDIA_SMI}),)
ifeq (${shell nvidia-smi | grep failed | wc -l},1)
  MARIAN_BUILD_OPTIONS += -DCOMPILE_CUDA=off
  LOAD_ENV = ${LOAD_CPU_ENV}
else
  GPU_AVAILABLE = 1
  LOAD_ENV = ${LOAD_GPU_ENV}
endif
else
  MARIAN_BUILD_OPTIONS += -DCOMPILE_CUDA=off
  LOAD_ENV = ${LOAD_CPU_ENV}
endif



COMET_SCORE ?= comet-score




## install prerequisites
## 
## TODO: add OpusFilter?

PREREQ_TOOLS := $(lastword ${ISO639}) ${ATOOLS} ${PIGZ} ${TERASHUF} ${MARIAN} ${EFLOMAL} ${TMX2MOSES}
PREREQ_PERL  := ISO::639::3 ISO::639::5 OPUS::Tools XML::Parser

## additional tools:
## - extract-lex for extracting short lists
## - browsermt_train for quantization
## - jq to extract text from cirrus-search dumps of wikipedia (for back-transaltion)
##
## install those with `make install-all`

EXTRA_TOOLS  := ${EXTRACT_LEX} ${BROWSERMT_TRAIN} ${JQ} 


PIP  := ${shell which pip3  2>/dev/null || echo pip}
CPAN := ${shell which cpanm 2>/dev/null || echo cpan}


PIP  := ${shell ${LOAD_BUILD_ENV} >/dev/null 2>/dev/null && which pip3  2>/dev/null || echo pip}
CPAN := ${shell ${LOAD_BUILD_ENV} >/dev/null 2>/dev/null && which cpanm 2>/dev/null || echo cpan}

## setup local Perl environment
## better install local::lib and put this into your .bashrc:
##
## eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"

export PATH                := ${HOME}/perl5/bin:${PATH}:${MARIAN_HOME}:${SPM_HOME}:${FASTALIGN_HOME}
export PERL5LIB            := ${HOME}/perl5/lib/perl5:${PERL5LIB}}
export PERL_LOCAL_LIB_ROOT := ${HOME}/perl5:${PERL_LOCAL_LIB_ROOT}}
export PERL_MB_OPT         := --install_base "${HOME}/perl5"
export PERL_MM_OPT         := INSTALL_BASE=${HOME}/perl5

## quick hack to fix a problem in marian-dev submodule fbgemm
## --> googletest changed to 'main' from 'master' (stupid)
## TODO: remove this again once it is not needed anymore!

PHONY: install install-prerequisites install-prereq install-requirements
install install-prerequisites install-prereq install-requirements:
	-git submodule update --init --recursive --remote
	cp 	tools/marian-dev/src/3rd_party/fbgemm/.gitmodules \
		tools/marian-dev/src/3rd_party/fbgemm/.gitmodules.backup
	cat tools/marian-dev/src/3rd_party/fbgemm/.gitmodules.backup |\
	sed 's#google/googletest#google/googletest|	branch = main#' | tr '|' "\n" | uniq \
	> tools/marian-dev/src/3rd_party/fbgemm/.gitmodules
	cp 	tools/browsermt/marian-dev/src/3rd_party/fbgemm/.gitmodules \
		tools/browsermt/marian-dev/src/3rd_party/fbgemm/.gitmodules.backup
	cat tools/browsermt/marian-dev/src/3rd_party/fbgemm/.gitmodules.backup |\
	sed 's#google/googletest#google/googletest|	branch = main#' | tr '|' "\n" | uniq \
	> tools/browsermt/marian-dev/src/3rd_party/fbgemm/.gitmodules
	git submodule update --init --recursive --remote
	${LOAD_BUILD_ENV} && ${PIP} install --user -r requirements.txt
	${LOAD_BUILD_ENV} && ${MAKE} install-perl-modules
	${LOAD_BUILD_ENV} && ${MAKE} ${PREREQ_TOOLS}
	if [ ! -e scores ]; then \
	  ln -s OPUS-MT-leaderboard/scores scores; \
	fi

PHONY: install-all
install-all: install install-extra-tools


.PHONY: install-prereq-tools
install-prereq-tools:
	${LOAD_BUILD_ENV} && ${MAKE} ${PREREQ_TOOLS}



.PHONY: install-perl-modules
install-perl-modules:
	for p in ${PREREQ_PERL}; do \
	  perl -e "use $$p;" 2> /dev/null || ${CPAN} -i $$p; \
	done

.PHONY: install-extra-tools
install-extra-tools:
	${LOAD_BUILD_ENV} && ${MAKE} ${EXTRA_TOOLS}


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


## Don't need this anymore - it's a submodule
#	mkdir -p ${TOOLSDIR}
#	cd ${TOOLSDIR} && git clone https://github.com/alexandres/terashuf.git

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
##
## TODO: do we still need to compile protobuf?

${TOOLSDIR}/marian-dev/build/marian: # ${PROTOC}
	mkdir -p ${dir $@}
	cd ${dir $@} && ${LOAD_MARIAN_BUILD_ENV} && cmake -DUSE_SENTENCEPIECE=on ${MARIAN_BUILD_OPTIONS} ..
	${LOAD_MARIAN_BUILD_ENV} && ${MAKE} -C ${dir $@} -j8

${TOOLSDIR}/browsermt/marian-dev/build/marian: # ${PROTOC}
	mkdir -p ${dir $@}
	cd ${dir $@} && ${LOAD_MARIAN_BUILD_ENV} && cmake ..
	${LOAD_MARIAN_BUILD_ENV} && ${MAKE} -C ${dir $@} -j8

## OBSOLETE?
${TOOLSDIR}/protobuf/bin/protoc:
	mkdir -p ${TOOLSDIR}
	if [ ! -e ${dir $@} ]; then \
	  cd ${TOOLSDIR} && git clone https://github.com/protocolbuffers/protobuf.git; \
	fi
	cd ${TOOLSDIR}/protobuf && git submodule update --init --recursive
	cd ${TOOLSDIR}/protobuf && ./autogen.sh
	cd ${TOOLSDIR}/protobuf && ./configure --prefix=${TOOLSDIR}/protobuf
	${MAKE} -C ${TOOLSDIR}/protobuf

${TOOLSDIR}/extract-lex/build/extract_lex:
	mkdir -p ${TOOLSDIR}
	if [ ! -e ${TOOLSDIR}/extract-lex ]; then \
	  cd ${TOOLSDIR} && git clone https://github.com/marian-nmt/extract-lex; \
	fi
	mkdir -p ${dir $@}
	cd ${dir $@} && ${LOAD_EXTRACTLEX_BUILD_ENV} && cmake ..
	${LOAD_EXTRACTLEX_BUILD_ENV} && ${MAKE} -C ${dir $@} -j4


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

.PHONY: install-eflomal
install-eflomal:
${TOOLSDIR}/eflomal/eflomal:
	${MAKE} -C ${dir $@} all
	cd ${dir $@} && python3 setup.py install --user
#	python3 setup.py install --install-dir ${HOME}/.local


${TOOLSDIR}/OpusTools-perl/scripts/convert/tmx2moses:
	mkdir -p ${TOOLSDIR}
	cd ${TOOLSDIR} && https://github.com/Helsinki-NLP/OpusTools-perl
	cd ${TOOLSDIR}/OpusTools-perl && perl Makefile.PL
	cd ${TOOLSDIR}/OpusTools-perl && ${MAKE} install
