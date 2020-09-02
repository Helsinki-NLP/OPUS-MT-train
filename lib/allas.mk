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

