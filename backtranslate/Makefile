#
# backtranslate wiki data
#
# only works with sentencepiece models!
#

include ../Makefile.env
include ../Makefile.config
include ../Makefile.slurm

SRC = af
TRG = en

## various sources are available
## can be general wikipedia, wikinews, wikibooks, ...
WIKISOURCE = wiki

## maximum input length (number sentence piece segments)
## maximum number of sentences to be translated (top N lines)
MAX_LENGTH = 100
MAX_SENTENCES = 1000000
PART = aa

LANGPAIR = ${SRC}-${TRG}


MODELHOME = ../models/${LANGPAIR}
MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}

ifeq (${MODELNAME},)
  MODELHOME = ../work-langid/models/${LANGPAIR}
  # MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/*-20*.zip}}}
  MODELZIP  = ${lastword ${sort ${wildcard ${MODELHOME}/opus-20*.zip}}}
  MODELNAME = ${patsubst %.zip,%,${notdir ${MODELZIP}}}
endif


LOAD_MODULES = 	module use -a /projappl/nlpl/software/modules/etc/ && \
		module load nlpl-udpipe nlpl-opus &&

WIKILANGS = 	${sort $(patsubst >%${WIKISOURCE}-,%,${shell grep -o '>..${WIKISOURCE}-' index.html})} \
		${sort $(patsubst >%${WIKISOURCE}-,%,${shell grep -o '>...${WIKISOURCE}-' index.html})}


LANGID   = ${SRC}
WIKI_DIR = wiki/${LANGID}
WIKI_TXT = ${WIKI_DIR}/${WIKISOURCE}.${LANGID}.${PART}.gz
WIKI_SRC = ${LANGPAIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.gz
WIKI_PRE = ${LANGPAIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz
WIKI_TRG = ${LANGPAIR}/${WIKISOURCE}.${PART}_${MODELNAME}.${LANGPAIR}.${TRG}.gz

## all parts of this wiki
PARTS = ${sort ${patsubst ${WIKI_DIR}/${WIKISOURCE}.${LANGID}.%.gz,%,${wildcard ${WIKI_DIR}/${WIKISOURCE}.${LANGID}.*.gz}}}


## don't delete translated text if the process crashes
.PRECIOUS: ${WIKI_TRG}

## find wiki downloads
WIKI_JSON = $(shell grep -o '${LANGID}${WIKISOURCE}-[0-9]*-cirrussearch-content.json.gz' index.html | head -1)

## we don't need to keep the json file
.INTERMEDIATE: ${WIKI_JSON} ${WIKI_PRE}


## find UDPipe model
ifndef UDPIPE_MODELS
  UDPIPE_MODELS=/projappl/nlpl/software/modules/udpipe/1.2.1-devel/models
endif
LANGNAME = ${shell ${LOAD_MODULES} opus-iso639 -e ${LANGID} | \
		cut -f1 -d';' | tr ' ' '-' | tr '[:upper:]' '[:lower:]'}
UDPIPE_MODEL = ${notdir $(shell ${LOAD_MODULES} find ${UDPIPE_MODELS}/ -name "${LANGNAME}*.udpipe" | head -1)}



all: index.html
	${MAKE} ${WIKI_SRC} ${WIKI_TRG}


# WIKISOURCES = wiki wikibooks wikinews wikiquote wikisource wiktionary
WIKISOURCES = wiki wikibooks wikinews wikiquote wikisource

all-wikis: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for w in ${WIKISOURCES}; do \
	  ${MAKE} WIKISOURCE=$$w extract-text; \
	  echo "find ${WIKI_DIR} -name '$$w.${LANGID}.${PART}.gz'"; \
	  if  [ `find ${WIKI_DIR} -name "$$w.${LANGID}.${PART}.gz" | wc -l` -gt 0 ]; then \
	    echo "${MAKE} WIKISOURCE=$$w HPC_CORES=1 WALLTIME=72 translate.submit"; \
	    ${MAKE} WIKISOURCE=$$w HPC_MEM=4g HPC_CORES=1 WALLTIME=72 translate.submit; \
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



## for Breton: use the multilingual celtic model to backtranslate
breton:
	${MAKE} SRC=br TRG=en MODELHOME=../models/ga+cy+br+gd+kv+gv-en all-wikis

## do the same for all Celtic languages in the model
celtic:
	for l in ga cy br gd kv gv; do \
	  ${MAKE} SRC=$$l TRG=en MODELHOME=../models/ga+cy+br+gd+kv+gv-en all-wikis; \
	done



# Tagalog (tl, tgl), Central Bikol (bcl), Malayalam (ml, mal), Bengali (bn, ben), and Mongolian (mn, mon)
focus-wikis:
	for l in tl bcl ml bn mn; do \
	  ${MAKE} SRC=$$l TRG=en all-wikis; \
	done

get-data: ${WIKI_JSON}
extract-text: ${WIKI_TXT}
prepare-model: ${LANGPAIR}/${MODELNAME}/decoder.yml
prepare-data: ${WIKI_PRE}
translate: ${WIKI_SRC} ${WIKI_TRG}

## translate all parts
translate-all-parts: ${LANGPAIR}/${MODELNAME}/decoder.yml
	for p in ${PARTS}; do \
	  ${MAKE} PART=$$p translate; \
	done

## create jobs for translating all parts
submit-translate-all-parts: ${LANGPAIR}/${MODELNAME}/decoder.yml
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

${LANGPAIR}/%.${PART}_${MODELNAME}.${LANGPAIR}.${SRC}.spm.gz: ${WIKI_DIR}/%.${SRC}.${PART}.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	zcat $< |\
	grep -v '[<>{}]' |\
	${LANGPAIR}/${MODELNAME}/preprocess.sh ${SRC} ${LANGPAIR}/${MODELNAME}/source.spm |\
	perl -e 'while (<>){next if (split(/\s+/)>${MAX_LENGTH});print;}' |\
	head -${MAX_SENTENCES} |\
	gzip -c > $@
endif



## merge SentencePiece segments in the source text
## (Why? because we filter out some data from the original wiki text, see above)

${WIKI_SRC}: ${WIKI_PRE}
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	zcat $< |\
	sed 's/ //g;s/▁/ /g' | \
	sed 's/^ *//;s/ *$$//' |\
	gzip -c > $@
endif


## translate

%.${LANGPAIR}.${TRG}.gz: %.${LANGPAIR}.${SRC}.spm.gz
ifneq (${MODELZIP},)
	mkdir -p ${dir $@}
	${MAKE} ${LANGPAIR}/${MODELNAME}/decoder.yml
	${LOADMODS} && cd ${LANGPAIR}/${MODELNAME} && ${MARIAN}/marian-decoder \
		-i ${PWD}/$< \
		-c decoder.yml \
		-d ${MARIAN_GPUS} \
		${MARIAN_DECODER_FLAGS} |\
	sed 's/ //g;s/▁/ /g' | sed 's/^ *//;s/ *$$//' |\
	gzip -c > ${PWD}/$@
ifneq (${LANGPAIR},)
ifneq (${MODELNAME},)
	rm -fr ${LANGPAIR}/${MODELNAME}
endif
endif
endif


## index of all downloadable files
index.html:
	wget -nv -O $@ https://dumps.wikimedia.org/other/cirrussearch/current

## wiki in json format
${WIKI_JSON}:
	wget -nv https://dumps.wikimedia.org/other/cirrussearch/current/${WIKI_JSON}


## check whether there is a UDPipe model
## backoff to moses tools
ifneq (${UDPIPE_MODEL},)
  SENTSPLITTER = udpipe --input=horizontal --tokenize \
		${UDPIPE_MODELS}/${UDPIPE_MODEL} |\
		grep '^\# *text *= *' |\
		sed 's/^\# *text *= *//'
else
  SENTSPLITTER = ${MOSESSCRIPTS}/ems/support/split-sentences.perl -l ${LANGID}
endif

## extract sentences and normalize
## - requires jq, udpipe, and moses-scripts
${WIKI_TXT}: ${WIKI_JSON}
	mkdir -p ${dir $@}
	${LOAD_MODULES} \
	zcat $< | jq -r '.text' | \
	grep -v 'null' |\
	grep -v '[<>{}]' |\
	${SENTSPLITTER} |\
	$(TOKENIZER)/replace-unicode-punctuation.perl |\
	$(TOKENIZER)/remove-non-printing-char.perl |\
	sed 's/  */ /g;s/^ *//g;s/ *$$//g' |\
	python3 ../scripts/filter/mono-match-lang.py -l ${LANGID} |\
	split -l ${MAX_SENTENCES} - ${patsubst %${PART}.gz,%,$@}
	gzip -f ${patsubst %${PART}.gz,%,$@}*


#	$(TOKENIZER)/normalize-punctuation.perl |\



## OLD: without splitting into parts
#
# ${WIKI_TXT}: ${WIKI_JSON}
# 	${LOAD_MODULES} \
# 	zcat $< | jq -r '.text' | \
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
