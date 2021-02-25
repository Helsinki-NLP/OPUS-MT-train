#
# backtranslate wiki data
#
# only works with sentencepiece models!
#

PWD      := ${shell pwd}
TOOLSDIR := ${PWD}/../tools

include ../lib/env.mk
include ../lib/config.mk
include ../lib/slurm.mk

SRC ?= af
TRG ?= en

## various sources are available
## can be general wikipedia, wikinews, wikibooks, ...
WIKISOURCE ?= wiki

## split size in nr-of-lines
## default part to be selected = aa
SPLIT_SIZE ?= 1000000
PART       ?= aa

## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
MAX_LENGTH    ?= 100
MAX_SENTENCES ?= ${SPLIT_SIZE}


LANGPAIR = ${SRC}-${TRG}

PWD := $(shell pwd)

MODELSDIR ?= ../models
MODELHOME ?= ${MODELSDIR}/${LANGPAIR}
## standard sort is different from UTF8-based sort
## --> prefer models with augmented data sets (separated by +)
##     we need the UTF8 sort order
## --> use bash sort and UTF8 locale
# MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
ifneq (${wildcard ${MODELHOME}},)
  MODELZIP  = ${lastword ${shell ls ${MODELHOME}/*-20*.zip 2>/dev/null | LANG=en_US.UTF-8 sort}}
  MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
endif

ifeq (${MODELNAME},)
ifneq (${wildcard ${WORKHOME/models/${LANGPAIR}}},)
  MODELHOME = ../${notdir ${WORKHOME}}/models/${LANGPAIR}
  # MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
  # MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/opus-20*.zip}}}
  MODELZIP  = ${lastword ${shell ls ${MODELHOME}/*-20*.zip 2>/dev/null | LANG=en_US.UTF-8 sort}}
  MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
endif
endif

## set to 1 if the model for backtranslation is a multi-target model
## --> need to use pre-processing script differently
ifeq ($(words $(subst +, ,$(lastword $(subst -, ,$(notdir ${MODELHOME}))))),1)
  MULTI_TARGET_MODEL = 0
else
  MULTI_TARGET_MODEL = 1
endif


ifdef LOCAL_SCRATCH
  TMPDIR = ${LOCAL_SCRATCH}
endif


ifeq (${shell hostname --domain 2>/dev/null},bullx)
  LOAD_MODULES = module use -a /projappl/nlpl/software/modules/etc/ && \
		 module load nlpl-udpipe nlpl-opus &&
endif

ifneq (${wildcard index.html},)
  WIKILANGS = 	${sort $(patsubst >%${WIKISOURCE}-,%,${shell grep -o '>..${WIKISOURCE}-' index.html})} \
		${sort $(patsubst >%${WIKISOURCE}-,%,${shell grep -o '>...${WIKISOURCE}-' index.html})}
endif



LANGID       = ${SRC}
WIKI_HOME    = wiki
WIKIDOC_HOME = wikidoc
WIKI_DIR     = ${WIKI_HOME}/${LANGID}
OUTPUT_DIR   = ${LANGPAIR}
WIKI_TXT     = ${WIKI_DIR}/${WIKISOURCE}.${LANGID}.${PART}.gz
WIKI_DOC     = ${WIKIDOC_HOME}/${LANGID}/${WIKISOURCE}.${LANGID}.gz
WIKI_SRC     = ${OUTPUT_DIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.gz
WIKI_PRE     = ${OUTPUT_DIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz
WIKI_TRG     = ${OUTPUT_DIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${TRG}.gz

WIKI_LATEST_SRC = ${OUTPUT_DIR}/latest/${WIKISOURCE}.${PART}.${LANGPAIR}.${SRC}.gz
WIKI_LATEST_TRG = ${OUTPUT_DIR}/latest/${WIKISOURCE}.${PART}.${LANGPAIR}.${TRG}.gz


## all parts of this wiki
PARTS = ${sort ${patsubst ${WIKI_DIR}/${WIKISOURCE}.${LANGID}.%.gz,%,${wildcard ${WIKI_DIR}/${WIKISOURCE}.${LANGID}.*.gz}}}


## don't delete translated text if the process crashes
.PRECIOUS: ${WIKI_TRG}

## find wiki downloads
ifneq (${wildcard index.html},)
  WIKI_JSON = $(shell grep -o '${LANGID}${WIKISOURCE}-[0-9]*-cirrussearch-content.json.gz' index.html | head -1)
endif

## we don't need to keep the json file
.INTERMEDIATE: ${WIKI_JSON} ${WIKI_PRE}


## find UDPipe model
ifndef UDPIPE_MODELS
  UDPIPE_MODELS=/projappl/nlpl/software/modules/udpipe/1.2.1-devel/models
endif

LANGNAME = ${shell ${LOAD_MODULES} ${ISO639} -n ${LANGID} | sed 's/"//g' | \
		cut -f1 -d';' | tr ' ' '-' | tr '[:upper:]' '[:lower:]'}

ifeq (${LANGNAME},)
  LANGNAME = xx
endif

ifneq (${wildcard ${UDPIPE_MODELS}},)
  UDPIPE_MODEL = ${notdir $(shell ${LOAD_MODULES} find ${UDPIPE_MODELS}/ -name "${LANGNAME}*.udpipe" | head -1)}
endif


all: index.html
	${MAKE} ${WIKI_LATEST_TRG}
	${MAKE} ${WIKI_LATEST_SRC}


## store wikidata on allas to make them accessible for everyone
## requires configuration for allas project OPUS-MT

store-wikidocs:
	cd wikidoc && a-put -b OPUS-MT-bt-wikidoc --nc --follow-links --override *
	swift post OPUS-MT-bt-wikidoc --read-acl ".r:*"

store-wiki:
	cd wiki && a-put -b OPUS-MT-bt-wiki --nc --follow-links --override *
	swift post OPUS-MT-bt-wiki --read-acl ".r:*"

fetch-wiki fetch:
	mkdir -p wiki
	wget -O wiki/${SRC}.tar https://object.pouta.csc.fi/OPUS-MT-bt-wiki/${SRC}.tar
	tar -C wiki -xf wiki/${SRC}.tar
	rm -f wiki/${SRC}.tar

fetch-wikidoc:
	mkdir -p wikidoc
	wget -O wikidoc/${SRC}.tar https://object.pouta.csc.fi/OPUS-MT-bt-wikidoc/${SRC}.tar
	tar -C wikidoc -xf wikidoc/${SRC}.tar
	rm -f wikidoc/${SRC}.tar


## tatoeba = tatoeba-monolingual data and tatoeba-models
## TODO: should we loop over all labels?

%-tatoeba:
	${MAKE}	WIKI_HOME=../work-tatoeba/data/mono \
		WIKISOURCES="wikipedia wikibooks wikinews wikiquote wikisource" \
		MODELSDIR=../models-tatoeba \
	${@:-tatoeba=}

# %-tatoeba:
#	${MAKE}	WIKI_HOME=wiki-iso639-3 \
#		WIKIDOC_HOME=wikidoc-iso639-3 \
#		MODELSDIR=../models-tatoeba \
#	${@:-tatoeba=}



## make ISO639-3 conform file links
wiki-iso639:
	for l in ${WIKILANGS}; do \
	  i=`iso639 -3 -n $$l`; \
	  mkdir -p wiki-iso639-3/$$i; \
	  for d in `ls wiki/$$l/*.gz`; do \
	    ln -s ${PWD}/$$d wiki-iso639-3/$$i/`basename $$d | sed "s/\.$$l\.\(..\.gz\)/.$$i.\1/"`; \
	  done \
	done

wiki-iso639-doc:
	for l in ${WIKILANGS}; do \
	  i=`iso639 -3 -n $$l`; \
	  mkdir -p wikidoc-iso639-3/$$i; \
	  for d in `ls wikidoc/$$l/*.gz`; do \
	    ln -s ${PWD}/$$d wikidoc-iso639-3/$$i/`basename $$d | sed "s/\.$$l\.\(..\.gz\)/.$$i.\1/"`; \
	  done \
	done



# WIKISOURCES = wiki wikibooks wikinews wikiquote wikisource wiktionary
WIKISOURCES = wiki wikibooks wikinews wikiquote wikisource

.PHONY: translate-all-wikis
translate-all-wikis: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for w in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$w extract-text; \
	  echo "find ${WIKI_DIR} -name '$$w.${LANGID}.${PART}.gz'"; \
	  if  [ `find ${WIKI_DIR} -name "$$w.${LANGID}.${PART}.gz" | wc -l` -gt 0 ]; then \
	    echo "${MAKE} WIKISOURCE=$$w translate"; \
	    ${MAKE} WIKISOURCE=$$w translate; \
	  fi \
	done

.PHONY: translate-all-wikiparts
translate-all-wikiparts: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for w in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$w extract-text; \
	  echo "find ${WIKI_DIR} -name '$$w.${LANGID}.${PART}.gz'"; \
	  if  [ `find ${WIKI_DIR} -name "$$w.${LANGID}.${PART}.gz" | wc -l` -gt 0 ]; then \
	    echo "${MAKE} WIKISOURCE=$$w translate-all-parts"; \
	    ${MAKE} WIKISOURCE=$$w translate-all-parts; \
	  fi \
	done


translate-all-wikis-jobs: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for w in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$w extract-text; \
	  echo "find ${WIKI_DIR} -name '$$w.${LANGID}.${PART}.gz'"; \
	  if  [ `find ${WIKI_DIR} -name "$$w.${LANGID}.${PART}.gz" | wc -l` -gt 0 ]; then \
	    echo "${MAKE} WIKISOURCE=$$w translate"; \
	    ${MAKE} WIKISOURCE=$$w HPC_MEM=4g HPC_CORES=1 WALLTIME=72 translate.submit; \
	  fi \
	done

translate-all-wikiparts-jobs: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for w in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$w extract-text; \
	  echo "find ${WIKI_DIR} -name '$$w.${LANGID}.${PART}.gz'"; \
	  if  [ `find ${WIKI_DIR} -name "$$w.${LANGID}.${PART}.gz" | wc -l` -gt 0 ]; then \
	    echo "${MAKE} WIKISOURCE=$$w translate-all-parts"; \
	    ${MAKE} WIKISOURCE=$$w HPC_MEM=4g HPC_CORES=1 WALLTIME=72 translate-all-parts-jobs; \
	  fi \
	done


all-wikitext:
	for w in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$w extract-text; \
	done

all-wikilangs: index.html
	for l in ${WIKILANGS}; do \
	  ${MAKE} LANGID=$$l extract-text; \
	done

all-wikilangs-fast: index.html
	for l in ${WIKILANGS}; do \
	  ${MAKE} SENTSPLITTER="${MOSESSCRIPTS}/ems/support/split-sentences.perl -l $$l" \
		LANGID=$$l extract-text; \
	done

all-wikis-all-langs: index.html
	for l in ${WIKILANGS}; do \
	  for w in ${WIKISOURCES}; do \
	    ${MAKE} WIKISOURCE=$$w LANGID=$$l extract-text; \
	  done \
	done


## aux function to print the selected modelname
.PHONY: print-modelname
print-modelname:
	@echo ${MODELNAME}
	@echo ${MODELZIP}
	@echo "${sort ${wildcard ${MODELHOME}/*-20*.zip}}"




all-wikidocs-all-langs: index.html
	for l in ${WIKILANGS}; do \
	  for w in ${WIKISOURCES}; do \
	    ${MAKE} SRC=$$l WIKISOURCE=$$w extract-doc; \
	  done \
	done


## nordic language wikis

all-nordic-wikidocs:
	for l in da  et  fi  fo  is  nn  no  sv; do \
	  for w in ${WIKISOURCES}; do \
	    ${MAKE} SRC=$$l WIKISOURCE=$$w extract-doc; \
	  done \
	done

# ar: Arabic
# bg: Bulgarian
# de: German
# el: Greek
# en: English
# es: Spanish
# fr: French
# hi: Hindi
# ru: Russian
# sw: Swahili
# th: Thai
# tr: Turkish
# ur: Urdu
# vi: Vietnamese
# zh: Chinese (Simplified)

xnli-wikidocs:
	for l in ar bg de el en es fr hi ru sw th tr ur vi zh; do \
	  for w in ${WIKISOURCES}; do \
	    ${MAKE} SRC=$$l WIKISOURCE=$$w extract-doc; \
	  done \
	done

## en and es are too big to run through udpipe ....
big-wikidocs:
	for l in en es; do \
	  ${MAKE} SENTSPLITTER="${MOSESSCRIPTS}/ems/support/split-sentences.perl -l $$l" \
		SRC=$$l WIKISOURCE=wiki extract-doc; \
	done

big-fr-wikidocs:
	for l in fr; do \
	  ${MAKE} SENTSPLITTER="${MOSESSCRIPTS}/ems/support/split-sentences.perl -l $$l" \
		SRC=$$l WIKISOURCE=wiki extract-doc; \
	done


#big-wikidocs:
#	for l in ca cs el en es; do \
#	  ${MAKE} SENTSPLITTER="${MOSESSCRIPTS}/ems/support/split-sentences.perl -l $$l" \
#		SRC=$$l WIKISOURCE=wiki extract-doc; \
#	done





translate-thl:
	${MAKE} WIKI_DIR=thl/${SRC} \
		OUTPUT_DIR=thl/${SRC}-${TRG} \
		WIKISOURCE=thl \
		HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	translate.submit






fetch-celtic:
	for l in ga cy br gd kw gv; do \
	  ${MAKE} SRC=$$l TRG=en MODELHOME=../models/ga+cy+br+gd+kw+gv-en all-wikitext; \
	done

## translate celtic languages using our multilingual model
## in both directions
translate-celtic-english:
	for l in ga cy br gd kw gv; do \
	  ${MAKE} SRC=$$l TRG=en MODELHOME=../models/ga+cy+br+gd+kw+gv-en all-wikis; \
	done

translate-english-celtic:
	for l in ga cy br gd kw gv; do \
	  ${MAKE} TRG=$$l SRC=en \
		MODELHOME=../models/en-ga+cy+br+gd+kw+gv \
		MULTI_TARGET_MODEL=1 \
	  	HPC_MEM=4g HPC_CORES=1 WALLTIME=72 translate.submit; \
	done


translate-english-celtic-missing:
	for l in gd; do \
	  ${MAKE} TRG=$$l SRC=en \
		MODELHOME=../models/en-ga+cy+br+gd+kw+gv \
		MULTI_TARGET_MODEL=1 \
	  	HPC_MEM=4g HPC_CORES=1 WALLTIME=72 translate.submit; \
	done



# test-celtic:
# 	for l in ga cy br gd kw gv; do \
# 	  ${MAKE} SRC=$$l TRG=en MODELHOME=../models/ga+cy+br+gd+kw+gv-en print-modelname; \
# 	done



## for Breton: use the multilingual celtic model to backtranslate
breton:
	${MAKE} SRC=br TRG=en MODELHOME=../models/ga+cy+br+gd+kw+gv-en all-wikis


assamese-english:
	${MAKE} SRC=as TRG=en MODELHOME=${HOME}/research/Opus-MT-train/work/models/as-en all-wikis

english-assamese:
	${MAKE} SRC=en TRG=as MODELHOME=${HOME}/research/Opus-MT-train/work/models/en-as translate.submit





small-romance:
	for l in wa frp oc ca rm lld fur lij lmo gl lad an mwl co nap scn vec sc la; do \
	  ${MAKE} SRC=$$l TRG=en MODELHOME=../models/fr+fr_BE+fr_CA+fr_FR+wa+frp+oc+ca+rm+lld+fur+lij+lmo+es+es_AR+es_CL+es_CO+es_CR+es_DO+es_EC+es_ES+es_GT+es_HN+es_MX+es_NI+es_PA+es_PE+es_PR+es_SV+es_UY+es_VE+pt+pt_br+pt_BR+pt_PT+gl+lad+an+mwl+it+it_IT+co+nap+scn+vec+sc+ro+la-en all-wikis; \
	done

# Tagalog (tl, tgl), Central Bikol (bcl), Malayalam (ml, mal), Bengali (bn, ben), and Mongolian (mn, mon)
wikimedia-focus-wikis:
	for l in tl bcl ml bn mn; do \
	  ${MAKE} SRC=$$l TRG=en all-wikis; \
	done

finland-focus-wikis:
	for l in ru et so ku fa sq vi th pl tr es ar; do \
	  ${MAKE} SRC=$$l TRG=fi all-wikitext; \
	done


uralic-wiki-texts:
	for l in se kv vep; do \
	  ${MAKE} SRC=$$l TRG=en all-wikitext; \
	done


# should be included: vep

uralic-wikis:
	for s in se kv vep; do \
	  for t in se sma smn sms smj vep et fi kv krl nb no nn ru sv en; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
		MULTI_TARGET_MODEL=1 \
		MODELHOME=${HOME}/research/Opus-MT-train/work/models/se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en-se+sma+smj+smn+sms+vep++et+fi+kv+krl+nb+no+nn+ru+sv+en \
		all-wikis; \
	     fi \
	  done \
	done


# fetch sami corpora from giellatekno

sami-corp:
	for l in sme sma smn sms smj; do \
	  ${MAKE} SRC=$$l giellatekno/$$l/corp.$$l.aa.gz; \
	done

giellatekno/${SRC}/corp.${SRC}.aa.gz: 
	${MAKE} victorio.uit.no/biggies/trunk/langs/${SRC}
	mkdir -p ${dir $@}
	find victorio.uit.no/biggies/trunk/langs/${SRC}/corp -type f -regex '.*/[^.]*.txt' |\
	xargs cat | grep . | sed 's/ ¶//' |\
	$(TOKENIZER)/detokenizer.perl -l fi | \
	split -l ${SPLIT_SIZE} - giellatekno/${SRC}/corp.${SRC}.
	gzip -f giellatekno/${SRC}/corp.${SRC}.*

victorio.uit.no/biggies/trunk/langs/${SRC}:
	wget -r -np https://victorio.uit.no/biggies/trunk/langs/${SRC}/corp

giellatekno/se: giellatekno/sme
	-cd giellatekno && ln -s sme se
	-cd giellatekno/sme && ln -s corp.sme.aa.gz corp.se.aa.gz

# cleanup-uralic:
# 	for s in se sma smn sms smj kv krl vep; do \
# 	  rm -fr $$s-$$s; \
# 	done


translate-sami: translate-sami-wiki translate-sami-corp

translate-sami-corp: sami-corp giellatekno/se
	for s in se sma smn sms smj; do \
	  for t in se sma smn sms smj et fi kv krl nb no nn ru sv en; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
	      WIKI_DIR=giellatekno/$$s \
	      WIKISOURCE=corp \
	      MULTI_TARGET_MODEL=1 \
	      MODELHOME=${HOME}/research/Opus-MT-train/work/models/se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en-se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en \
	      HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	      translate.submit; \
	    fi \
	  done \
	done

translate-sami-wiki:
	for s in se; do \
	  for t in se sma smn sms smj vep et fi kv krl nb no nn ru sv en; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
		MULTI_TARGET_MODEL=1 \
	        MODELHOME=${HOME}/research/Opus-MT-train/work/models/se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en-se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en \
	        HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	        translate.submit; \
	     fi \
	  done \
	done
	for s in no nn ru sv en; do \
	  for t in se sma smn sms smj; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
		MULTI_TARGET_MODEL=1 \
	        MODELHOME=${HOME}/research/Opus-MT-train/work/models/se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en-se+sma+smj+smn+sms+vep+et+fi+kv+krl+nb+no+nn+ru+sv+en \
	        HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	        translate.submit; \
	     fi \
	  done \
	done



### NEWNEWNEW

translate-sami-xx-wiki:
	for s in se; do \
	  for t in sma smn sms smj fi no sv; do \
	      ${MAKE} SRC=$$s TRG=$$t \
		MULTI_TARGET_MODEL=1 \
	        MODELHOME=${HOME}/research/Opus-MT-train/models/se+sma+smj+smn+sms-fi+nb+no+nn+ru+sv+en \
	        HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	        translate.submit; \
	  done \
	done


translate-sami-xx-corp: sami-corp giellatekno/se
	for s in se sma smn sms smj; do
	  for t in fi no sv; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRC=$$s TRG=$$t \
	      WIKI_DIR=giellatekno/$$s \
	      WIKISOURCE=corp \
	      MULTI_TARGET_MODEL=1 \
	      MODELHOME=${HOME}/research/Opus-MT-train/models/se+sma+smj+smn+sms-fi+nb+no+nn+ru+sv+en \
	      HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	      translate.submit; \
	    fi \
	  done \
	done

translate-xx-sami-wiki:
	for s in fi no nn sv; do \
	  for t in se sma smn sms smj; do \
	      ${MAKE} SRC=$$s TRG=$$t \
		MULTI_TARGET_MODEL=1 \
	        MODELHOME=${HOME}/research/Opus-MT-train/models/fi+nb+no+nn+ru+sv+en-se+sma+smj+smn+sms \
	        HPC_MEM=4g HPC_CORES=1 WALLTIME=72 \
	        translate.submit; \
	  done \
	done






get-data: ${WIKI_JSON}
extract-text: ${WIKI_TXT}
extract-doc: ${WIKI_DOC}
prepare-model: ${LANGPAIR}/${MODELNAME}/decoder.yml
prepare-data: ${WIKI_PRE}
translate: ${WIKI_LATEST_TRG}
	${MAKE} ${WIKI_LATEST_SRC}

## translate all parts
translate-all-parts: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for p in ${PARTS}; do \
	  ${MAKE} PART=$$p translate; \
	done

## create jobs for translating all parts
translate-all-parts-jobs: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for p in ${PARTS}; do \
	  ${MAKE} PART=$$p translate.submit; \
	done

print-names:
	echo ${LANGNAME}
	echo ${UDPIPE_MODEL}
	echo ${WIKI_JSON}
	echo ${MODELNAME}


## fetch the latest model
## ---> TODO: should we fetch from ObjectStorage instead?

${LANGPAIR}/${MODELNAME}/decoder.yml:
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	cp ${MODELZIP} ${dir $@}
	cd ${dir $@} && unzip *.zip
endif


## pre-process data
## ---> TODO: does that work for multilingual data that need prefix?

ifeq (${MULTI_TARGET_MODEL},1)
  PREPROCESS_ARGS = ${SRC} ${TRG} ${LANGPAIR}/${MODELNAME}/source.spm
else
  PREPROCESS_ARGS = ${SRC} ${LANGPAIR}/${MODELNAME}/source.spm
endif

${OUTPUT_DIR}/%.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz: ${WIKI_DIR}/%.${SRC}.${PART}.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${GZCAT} $< |\
	grep -v '[<>{}]' |\
	${LANGPAIR}/${MODELNAME}/preprocess.sh ${PREPROCESS_ARGS} |\
	perl -e 'while (<>){next if (split(/\s+/)>${MAX_LENGTH});print;}' |\
	head -${MAX_SENTENCES} |\
	gzip -c > $@
endif



## merge SentencePiece segments in the source text
## (Why? because we filter out some data from the original wiki text, see above)

${WIKI_SRC}: ${WIKI_PRE}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${GZCAT} $< |\
	sed 's/ //g;s/▁/ /g' | \
	sed 's/^ *//;s/ *$$//' |\
	sed 's/^>>[a-z]*<< //' |\
	gzip -c > $@
endif



## remove prefix from latest translation files

ALL_LATEST = ${wildcard */latest/*.gz}

fix-prefix:
	for d in ${ALL_LATEST}; do \
	  echo "fix $$d"; \
	  ${ZCAT} $$d | sed 's/^>>[a-z]*<< //' > $$d.fixed; \
	  cat $$d.fixed | gzip -c > $$d; \
	  rm -f $$d.fixed; \
	done


## overwrite the file with the latest translations
## --> this allows multiple translation iterations
##     without duplicating the data we want to use in MT training

${WIKI_LATEST_SRC}: ${WIKI_SRC}
	mkdir -p ${dir $@}
	cp $< $@

${WIKI_LATEST_TRG}: ${WIKI_TRG}
	mkdir -p ${dir $@}
	cp $< $@



## translate

%.${LANGPAIR}.${TRG}.gz: %.${LANGPAIR}.${SRC}.spm.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${LOADMODS} && cd ${LANGPAIR}/${MODELNAME} && ${MARIAN_DECODER} \
		-i ${PWD}/$< \
		-c decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
#ifneq (${LANGPAIR},)
#ifneq (${MODELNAME},)
#	rm -fr ${LANGPAIR}/${MODELNAME}
#endif
#endif
endif


## index of all downloadable files
index.html:
	wget -nv -O $@ https://dumps.wikimedia.org/other/cirrussearch/current

## wiki in json format
${WIKI_JSON}:
	wget -nv https://dumps.wikimedia.org/other/cirrussearch/current/${WIKI_JSON}




## languages with nonbreaking prefix files 
## (i.e. support for the Moses sentence splitter)
# ca cs de el en es fi fr ga hu is it lt lv nl pl pt ro ru sk sl sv ta yue zh

# MOSES_LANGS = ca cs de el en es fi fr ga hu is it lt lv nl pl pt ro ru sk sl sv ta yue zh
MOSES_LANGS = ca cs de el en es fi fr ga hu is it lt lv nl pl pt ro ru sk sl sv ta

## check whether there is a UDPipe model
## and LANGID is not supported by moses tools (they are much faster!)

ifneq (${UDPIPE_MODEL},)
ifneq ($(filter-out ${MOSES_LANGS},${LANGID}),)
  SENTSPLITTER = udpipe --input=horizontal --tokenize \
		${UDPIPE_MODELS}/${UDPIPE_MODEL} |\
		grep '^\# *text *= *\|\# newpar' |\
		sed 's/^\# *text *= *//'
endif
endif

## fallback = moses tools
SENTSPLITTER ?= sed 's/^ *$$/\# newpar/' | \
		${MOSESSCRIPTS}/ems/support/split-sentences.perl -l ${LANGID} |\
		sed -e "s/\# newpar/\n\# newpar\n/g"


## extract sentences and normalize
## - requires jq, udpipe, and moses-scripts
${WIKI_TXT}: ${WIKI_JSON}
	mkdir -p ${dir $@}
	${LOAD_MODULES} \
	${GZCAT} $< | ${JQ} -r '.text' | \
	grep -v 'null' |\
	grep -v '[<>{}]' |\
	${SENTSPLITTER} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
	python3 ../scripts/filter/mono-match-lang.py -l ${LANGID} |\
	${SORT} -u | ${SHUFFLE} |\
	split -l ${SPLIT_SIZE} - ${patsubst %${PART}.gz,%,$@}
	gzip -f ${patsubst %${PART}.gz,%,$@}*



#	$(TOKENIZER)/normalize-punctuation.perl |\


${WIKI_DOC}: ${WIKI_JSON}
	mkdir -p ${dir $@}
	${LOAD_MODULES} \
	${GZCAT} $< | ${JQ} -r '.text' | \
	sed 's/^ *null *$$//' |\
	grep -v '[<>{}]' |\
	${SENTSPLITTER} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
	sed 's/^# newpar$$//' |\
	python3 ../scripts/filter/mono-match-lang.py -l ${LANGID} |\
	gzip -c > $@



check-length:
	for d in `find . -maxdepth 1 -type d -name '*-*' -printf "%f "`; do \
	  s=`echo $$d | cut -f1 -d'-'`; \
	  t=`echo $$d | cut -f2 -d'-'`; \
	  echo "check $$d"; \
	  for S in `ls $$d/*.$$s.gz`; do \
	    T=`echo $$S | sed 's/.$$s.gz/.$$t.gz/'`; \
	    echo "$$S -- $$T"; \
	    ${GZCAT} $$S | wc -l; \
	    ${GZCAT} $$T | wc -l; \
	    if [ `${GZCAT} $$S | wc -l` != `${GZCAT} $$T | wc -l` ]; then \
	      echo "$$S != $$T"; \
	    fi \
	  done \
	done














## OLD: without splitting into parts
#
# ${WIKI_TXT}: ${WIKI_JSON}
# 	${LOAD_MODULES} \
# 	${ZCAT} $< | ${JQ} -r '.text' | \
# 	grep -v 'null' |\
# 	${SENTSPLITTER} |\
# 	$(TOKENIZER)/replace-unicode-punctuation.perl |\
# 	$(TOKENIZER)/remove-non-printing-char.perl |\
# 	$(TOKENIZER)/normalize-punctuation.perl |\
# 	sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
# 	gzip -c > $@







# afrikaans-afribooms-ud-2.4-190531.udpipe	af
# ancient_greek-perseus-ud-2.4-190531.udpipe
# ancient_greek-proiel-ud-2.4-190531.udpipe
# arabic-padt-ud-2.4-190531.udpipe	ar
# armenian-armtdp-ud-2.4-190531.udpipe
# basque-bdt-ud-2.4-190531.udpipe		eo
# belarusian-hse-ud-2.4-190531.udpipe
# bulgarian-btb-ud-2.4-190531.udpipe		bg
# catalan-ancora-ud-2.4-190531.udpipe		ca
# chinese-gsd-ud-2.4-190531.udpipe		zh
# classical_chinese-kyoto-ud-2.4-190531.udpipe	zh_tw
# coptic-scriptorium-ud-2.4-190531.udpipe
# croatian-set-ud-2.4-190531.udpipe		hr
# czech-cac-ud-2.4-190531.udpipe		cs
# czech-cltt-ud-2.4-190531.udpipe		cs
# czech-fictree-ud-2.4-190531.udpipe		cs
# czech-pdt-ud-2.4-190531.udpipe		cs
# danish-ddt-ud-2.4-190531.udpipe		da
# dutch-alpino-ud-2.4-190531.udpipe		nl
# dutch-lassysmall-ud-2.4-190531.udpipe		nl
# english-ewt-ud-2.4-190531.udpipe		en
# english-gum-ud-2.4-190531.udpipe		en
# english-lines-ud-2.4-190531.udpipe		en
# english-partut-ud-2.4-190531.udpipe		en
# estonian-edt-ud-2.4-190531.udpipe		et
# estonian-ewt-ud-2.4-190531.udpipe		et
# finnish-ftb-ud-2.4-190531.udpipe		fi
# finnish-tdt-ud-2.4-190531.udpipe		fi
# french-gsd-ud-2.4-190531.udpipe		fr
# french-partut-ud-2.4-190531.udpipe		fr
# french-sequoia-ud-2.4-190531.udpipe		fr
# french-spoken-ud-2.4-190531.udpipe		fr
# galician-ctg-ud-2.4-190531.udpipe		gl
# galician-treegal-ud-2.4-190531.udpipe		gl
# german-gsd-ud-2.4-190531.udpipe		de
# gothic-proiel-ud-2.4-190531.udpipe
# greek-gdt-ud-2.4-190531.udpipe		el
# hebrew-htb-ud-2.4-190531.udpipe		he
# hindi-hdtb-ud-2.4-190531.udpipe		hi
# hungarian-szeged-ud-2.4-190531.udpipe		hu
# indonesian-gsd-ud-2.4-190531.udpipe		id
# irish-idt-ud-2.4-190531.udpipe		cy
# italian-isdt-ud-2.4-190531.udpipe		it
# italian-partut-ud-2.4-190531.udpipe		it
# italian-postwita-ud-2.4-190531.udpipe		it
# italian-vit-ud-2.4-190531.udpipe		it
# japanese-gsd-ud-2.4-190531.udpipe		ja
# korean-gsd-ud-2.4-190531.udpipe		ko
# korean-kaist-ud-2.4-190531.udpipe		ko
# latin-ittb-ud-2.4-190531.udpipe		la
# latin-perseus-ud-2.4-190531.udpipe		la
# latin-proiel-ud-2.4-190531.udpipe		la
# latvian-lvtb-ud-2.4-190531.udpipe		lv
# lithuanian-alksnis-ud-2.4-190531.udpipe	lt
# lithuanian-hse-ud-2.4-190531.udpipe		lt
# maltese-mudt-ud-2.4-190531.udpipe		mt
# marathi-ufal-ud-2.4-190531.udpipe
# north_sami-giella-ud-2.4-190531.udpipe
# norwegian-bokmaal-ud-2.4-190531.udpipe	nb
# norwegian-nynorsklia-ud-2.4-190531.udpipe	nn
# norwegian-nynorsk-ud-2.4-190531.udpipe	nn
# old_church_slavonic-proiel-ud-2.4-190531.udpipe
# old_french-srcmf-ud-2.4-190531.udpipe
# old_russian-torot-ud-2.4-190531.udpipe
# persian-seraji-ud-2.4-190531.udpipe		fa
# polish-lfg-ud-2.4-190531.udpipe		pl
# polish-pdb-ud-2.4-190531.udpipe		pl
# portuguese-bosque-ud-2.4-190531.udpipe	pt
# portuguese-gsd-ud-2.4-190531.udpipe		pt
# romanian-nonstandard-ud-2.4-190531.udpipe	ro
# romanian-rrt-ud-2.4-190531.udpipe		ro
# russian-gsd-ud-2.4-190531.udpipe		ru
# russian-syntagrus-ud-2.4-190531.udpipe	ru
# russian-taiga-ud-2.4-190531.udpipe		ru
# serbian-set-ud-2.4-190531.udpipe		sr
# slovak-snk-ud-2.4-190531.udpipe		sk
# slovenian-ssj-ud-2.4-190531.udpipe		sl
# slovenian-sst-ud-2.4-190531.udpipe		sl
# spanish-ancora-ud-2.4-190531.udpipe		es
# spanish-gsd-ud-2.4-190531.udpipe		es
# swedish-lines-ud-2.4-190531.udpipe		sv
# swedish-talbanken-ud-2.4-190531.udpipe	sv
# tamil-ttb-ud-2.4-190531.udpipe
# telugu-mtg-ud-2.4-190531.udpipe
# turkish-imst-ud-2.4-190531.udpipe		tr
# ukrainian-iu-ud-2.4-190531.udpipe
# urdu-udtb-ud-2.4-190531.udpipe
# uyghur-udt-ud-2.4-190531.udpipe
# vietnamese-vtb-ud-2.4-190531.udpipe		vi
# wolof-wtb-ud-2.4-190531.udpipe




# https://dumps.wikimedia.org/other/cirrussearch/current/afwiki-20191209-cirrussearch-content.json.gz
# https://dumps.wikimedia.org/other/cirrussearch/current/afwiki-20191209-cirrussearch-general.json.gz

# https://dumps.wikimedia.org/other/cirrussearch/current/afwikibooks-20191209-cirrussearch-content.json.gz
# https://dumps.wikimedia.org/other/cirrussearch/current/afwikibooks-20191209-cirrussearch-general.json.gz

# https://dumps.wikimedia.org/other/cirrussearch/current/afwikiquote-20191209-cirrussearch-content.json.gz
# https://dumps.wikimedia.org/other/cirrussearch/current/afwikiquote-20191209-cirrussearch-general.json.gz

# https://dumps.wikimedia.org/other/cirrussearch/current/afwiktionary-20191209-cirrussearch-content.json.gz
# https://dumps.wikimedia.org/other/cirrussearch/current/afwiktionary-20191209-cirrussearch-general.json.gz


# enwiki-20191209-cirrussearch-content.json.gz       10-Dec-2019 11:04         22622822308
# enwiki-20191209-cirrussearch-content.json.gz.tmp   10-Dec-2019 10:57         21460369408
# enwiki-20191209-cirrussearch-general.json.gz       10-Dec-2019 16:22         50406322974
# enwiki-20191209-cirrussearch-general.json.gz.tmp   10-Dec-2019 15:50         44720914432
# enwikibooks-20191209-cirrussearch-content.json.gz  10-Dec-2019 16:24           319454731
# enwikibooks-20191209-cirrussearch-general.json.gz  10-Dec-2019 16:25            97206925
# enwikinews-20191209-cirrussearch-content.json.gz   10-Dec-2019 16:26            53746769
# enwikinews-20191209-cirrussearch-general.json.gz   10-Dec-2019 16:36           364098656
# enwikiquote-20191209-cirrussearch-content.json.gz  10-Dec-2019 16:38           234637326
# enwikiquote-20191209-cirrussearch-general.json.gz  10-Dec-2019 16:38            66848855
# enwikisource-20191209-cirrussearch-content.json.gz 10-Dec-2019 17:09          5236203374
# enwikisource-20191209-cirrussearch-content.json..> 10-Dec-2019 17:06          4597481472
# enwikisource-20191209-cirrussearch-general.json.gz 10-Dec-2019 17:11           152492247
# enwikiversity-20191209-cirrussearch-content.jso..> 10-Dec-2019 17:12           145288148
# enwikiversity-20191209-cirrussearch-general.jso..> 10-Dec-2019 17:13           193051475
# enwikivoyage-20191209-cirrussearch-content.json.gz 10-Dec-2019 17:14           179134384
# enwikivoyage-20191209-cirrussearch-general.json.gz 10-Dec-2019 17:15            99357806
# enwiktionary-20191209-cirrussearch-content.json.gz 10-Dec-2019 17:36          2319801836
# enwiktionary-20191209-cirrussearch-content.json..> 10-Dec-2019 17:23           918503424
# enwiktionary-20191209-cirrussearch-general.json.gz 10-Dec-2019 17:42           848846623
# enwiktionary-20191209-cirrussearch-general.json..> 10-Dec-2019 17:40           661585920


