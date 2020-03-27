#!/bin/bash
#
# USAGE preprocess.sh source-langid target-langid bpecodes [noflags] < input > output
#
#
# replace MOSESHOME and SPMENCODE with your own setup! 

if [ `hostname -d` == "bullx" ]; then
  APPLHOME=/projappl/project_2001569
  MOSESHOME=${APPLHOME}/mosesdecoder
  SPMENCODE=${APPLHOME}/marian-dev/build-spm/spm_encode
elif [ `hostname -d` == "csc.fi" ]; then
  APPLHOME=/proj/memad/tools
  MOSESHOME=/proj/nlpl/software/moses/4.0-65c75ff/moses
  SPMENCODE=${APPLHOME}/marian-dev/build-spm/spm_encode
else
  MOSESHOME=${PWD}/mosesdecoder
  SPMENCODE=${PWD}/marian-dev/build/spm_encode
fi

MOSESSCRIPTS=${MOSESHOME}/scripts
TOKENIZER=${MOSESSCRIPTS}/tokenizer

if [ "$4" == "noflags" ]; then
  ${TOKENIZER}/replace-unicode-punctuation.perl |
  ${TOKENIZER}/remove-non-printing-char.perl |
  sed 's/  */ /g;s/^ *//g;s/ *$//g' |
  ${SPMENCODE} --model $3
else
  ${TOKENIZER}/replace-unicode-punctuation.perl |
  ${TOKENIZER}/remove-non-printing-char.perl |
  sed 's/  */ /g;s/^ *//g;s/ *$//g' |
  ${SPMENCODE} --model $3 |
  sed "s/^/>>$2<< /"
fi

# ${TOKENIZER}/normalize-punctuation.perl -l $1 |
