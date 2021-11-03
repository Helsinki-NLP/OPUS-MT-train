# -*-makefile-*-
#
# environment on dx7@UH
#


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
