
#-------------------------------------------------------------------
# experiments and models from the fiskmö project
#-------------------------------------------------------------------



## run things with individual data sets only
%-fiskmo:
	${MAKE} TRAINSET=fiskmo ${@:-fiskmo=}

%-opensubtitles:
	${MAKE} TRAINSET=OpenSubtitles ${@:-opensubtitles=}

%-finlex:
	${MAKE} TRAINSET=Finlex ${@:-finlex=}



## make some tests with crawled fiskmo data

FISKMO-DATASETS = crawl-v2-2M \
		crawl-v2-clean \
		yle-rss-v2-100K \
		yle-rss-v2-clean \
		fiskmo-crawl-articles-v1 \
		fiskmo-crawl-articles-v1-0.5 \
		fiskmo-crawl-articles-v1-0.8 \
		yle-2011-2018-articles-v1-0.8

## make fiskmo-fisv-data
## make fiskmo-fisv-train.submit
## make fiskmo-fisv-eval
## make fiskmo-fisv-eval-testsets
##
## make fiskmo-fisv-reverse-data
## make fiskmo-svfi-train.submit
## make fiskmo-fisv-eval
## make fiskmo-fisv-eval-testsets

fiskmo-missing:
	for d in crawl-v2-2M crawl-v2-clean; do \
	  rm -f ${WORKHOME}/fi-sv/*.submit; \
	  ${MAKE} SRCLANGS=fi TRGLANGS=sv DATASET=$$d TRAINSET=finnish-swedish-$$d \
		MODELTYPE=transformer train-dynamic; \
	done

fiskmo-svfi-missing:
	for d in crawl-v2-clean; do \
	  rm -f ${WORKHOME}/sv-fi/*.submit; \
	  ${MAKE} SRCLANGS=sv TRGLANGS=fi DATASET=$$d TRAINSET=finnish-swedish-$$d \
		train-dynamic; \
	done


fiskmo-fisv-%:
	for d in ${FISKMO-DATASETS}; do \
	  rm -f ${WORKHOME}/fi-sv/*.submit; \
	  ${MAKE} SRCLANGS=fi TRGLANGS=sv DATASET=$$d TRAINSET=finnish-swedish-$$d \
		${patsubst fiskmo-fisv-%,%,$@}; \
	done
	rm -f ${WORKHOME}/fi-sv/*.submit
	${MAKE} DATASET=fiskmo-crawl-all SRCLANGS=fi TRGLANGS=sv \
		TRAINSET="finnish-swedish-crawl-v2-2M yle-rss-v2-100K fiskmo-crawl-articles-v1 yle-2011-2018-articles-v1-0.8" \
		${patsubst fiskmo-fisv-%,%,$@}
	rm -f ${WORKHOME}/fi-sv/*.submit
	${MAKE} DATASET=fiskmo-crawl-clean SRCLANGS=fi TRGLANGS=sv \
		TRAINSET="finnish-swedish-crawl-v2-clean yle-rss-v2-clean fiskmo-crawl-articles-v1-0.8" \
		${patsubst fiskmo-fisv-%,%,$@}

fiskmo-svfi-%:
	for d in ${FISKMO-DATASETS}; do \
	  rm -f ${WORKHOME}/sv-fi/*.submit; \
	  ${MAKE} SRCLANGS=sv TRGLANGS=fi DATASET=$$d TRAINSET=finnish-swedish-$$d \
		${patsubst fiskmo-svfi-%,%,$@}; \
	done
	rm -f ${WORKHOME}/sv-fi/*.submit
	${MAKE} DATASET=fiskmo-crawl-all SRCLANGS=sv TRGLANGS=fi \
		TRAINSET="finnish-swedish-crawl-v2-2M yle-rss-v2-100K fiskmo-crawl-articles-v1 yle-2011-2018-articles-v1-0.8" \
		${patsubst fiskmo-svfi-%,%,$@}
	rm -f ${WORKHOME}/sv-fi/*.submit
	${MAKE} DATASET=fiskmo-crawl-clean SRCLANGS=sv TRGLANGS=fi \
		TRAINSET="finnish-swedish-crawl-v2-clean yle-rss-v2-clean fiskmo-crawl-articles-v1-0.8" \
		${patsubst fiskmo-svfi-%,%,$@}


