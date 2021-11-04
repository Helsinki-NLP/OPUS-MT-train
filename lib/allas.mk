# -*-makefile-*-
#
# recipes for interacrting with allas


#---------------------------------------------------------------------
# store and fetch workdata
# requires module load allas && allas-conf
# select project_2002688 (OPUS-MT)
#  - "make store" overrides
#  - "make fetch" does not override (delete dir first)
#  - storing data will resolve symbolic links
#---------------------------------------------------------------------

.PHONY: store store-data fetch fetch-data

## directories and container names to be used
WORK_SRCDIR       ?= ${WORKHOME}
WORK_DESTDIR      ?= ${WORKHOME}
WORK_CONTAINER    ?= OPUS-MT-train_${notdir ${WORKHOME}}-${WHOAMI}
WORK_CONTAINER_JT ?= OPUS-MT-train_${notdir ${WORKHOME}}-tiedeman

ALLAS_STORAGE_URL = https://object.pouta.csc.fi/


## store workdir on allas
store:
	cd ${WORK_SRCDIR} && a-put -b ${WORK_CONTAINER} --nc --follow-links --override ${LANGPAIRSTR}

## fetch workdir from allas (user-specific container)
fetch:
	mkdir -p ${WORK_DESTDIR}
	cd ${WORK_DESTDIR} && a-get ${WORK_CONTAINER}/${LANGPAIRSTR}.tar

## get it from user tiedeman
fetch-tiedeman:
	mkdir -p ${WORK_DESTDIR}
	cd ${WORK_DESTDIR} && a-get ${WORK_CONTAINER_JT}/${LANGPAIRSTR}.tar


## store and fetch data dir (raw data files)
store-data:
	cd ${WORK_SRCDIR} && a-put -b ${WORK_CONTAINER} --nc --follow-links --override data

fetch-data:
	mkdir -p ${WORK_DESTDIR}
	cd ${WORK_DESTDIR} && a-get ${WORK_CONTAINER}/data.tar



## generic recipe for storing work data and removing it from the file system
## DANGEROUS --- this really deletes the data!
## NOTE: makes container also world-readable (see swift post command)
##       --> this makes it easier to fetch things without login credentials
##       --> should not store sensitive data here!
%.stored: %
	if [ "$(firstword $(subst -, ,$(subst /, ,$@)))" == "work" ]; then \
	  b=OPUS-MT-train_$(subst /,-,$(dir $@))${WHOAMI}; \
	  cd $(dir $@); \
	  a-put -b $$b --nc --follow-links --override $(notdir $<); \
	  rm -fr $(notdir $<); \
	  touch $(notdir $@); \
	  rm -f $(notdir $(@:stored=.fetched)); \
	  swift post $$b --read-acl ".r:*"
	fi


## TODO: fetch with wget instead of using a-commands
## fetch work data from allas
%.fetched:
	if [ "$(firstword $(subst -, ,$(subst /, ,$@)))" == "work" ]; then \
	  cd $(dir $@); \
	  a-get OPUS-MT-train_$(subst /,-,$(dir $@))${WHOAMI}/$(notdir $(@:.fetched=.tar)); \
	  touch $(notdir $@); \
	  rm -f $(notdir $(@:fetched=.stored)); \
	fi

## another way of fetching work data
## requires settings SRCLANGS and TRGLANGS (or LANGPAIRSTR directly)
work-%/${LANGPAIRSTR}:
	mkdir -p $(dir $@)
	cd $(dir $@) && a-get OPUS-MT-train_$(subst /,-,$(dir $@))${WHOAMI}/${LANGPAIRSTR}.tar


UPLOAD_MODELS=$(patsubst %,%.stored,${wildcard work-tatoeba/[dg-rt-z]*})
upload-workfiles: ${UPLOAD_MODELS}
