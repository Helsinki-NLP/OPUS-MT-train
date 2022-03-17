
#-------------------------------------------------------------------
# multilingual model for Sami languages
#-------------------------------------------------------------------

# sami-data: fetch-sami-tmx convert-sami-tmx move-sami-data convert-sami-gloss
sami-data: 
	${MAKE} -j 1 fetch-sami-tmx convert-sami-tmx merge-sami-data convert-sami-gloss

sami-train: train-sami
sami-eval: eval-sami
sami-dist: dist-sami



GIELLATEKNO_HOME = https://victorio.uit.no/biggies/trunk
GIELLATEKNO_TM_HOME = ${GIELLATEKNO_HOME}/mt/omegat

GIELLATEKNO_SAMI_TM = 	fin-smn/tm/finsmn.tmx \
			fin-sme/tm/finsme.tmx \
			fin-sms/tm/finsms.tmx \
			sme-smn/tm/smesmn.tmx \
			sme-smj/tm/smesmj.tmx \
			sme-nob/tm/smenob.tmx \
			sme-sma/tm/smesma.tmx \
			nob-smj/tm/nobsmj.tmx \
			nob-sme/tm/nobsme-2012.tmx \
			nob-sme/tm/nobsme-admin.tmx \
			nob-sme/tm/nobsme-bible.tmx \
			nob-sme/tm/nobsme-facta.tmx \
			nob-sme/tm/nobsme-laws.tmx \
			nob-sme/tm/nobsme-science.tmx \
			nob-sma/tm/nobsma.tmx \
			sma-nob/tm/smanob.tmx


## glossaries

convert-sami-gloss:
	mkdir -p ${DATADIR}/${PRE}
	${WGET} ${GIELLATEKNO_TM_HOME}/fin-smn/glossary/finsmn.utf8
	cut -f1 finsmn.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.fi-smn.clean.fi.gz
	cut -f2 finsmn.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.fi-smn.clean.smn.gz
	rm -f finsmn.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/fin-sme/glossary/finsme.utf8
	cut -f1 finsme.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.fi-se.clean.fi.gz
	cut -f2 finsme.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.fi-se.clean.se.gz
	rm -f finsme.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/fin-sms/glossary/finsms.utf8
	cut -f1 finsms.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.fi-sms.clean.fi.gz
	cut -f2 finsms.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.fi-sms.clean.sms.gz
	rm -f finsms.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/sme-smn/glossary/smesmn.utf8
	cut -f1 smesmn.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.se-smn.clean.se.gz
	cut -f2 smesmn.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.se-smn.clean.smn.gz
	rm -f smesmn.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/sme-smj/glossary/glossary.utf8
	cut -f1 glossary.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.se-smj.clean.se.gz
	cut -f2 glossary.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.se-smj.clean.smj.gz
	rm -f glossary.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/sme-nob/glossary/smenob.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/sme-nob/glossary/termwiki.utf8
	cut -f1 smenob.utf8 > ${DATADIR}/${PRE}/glossary.nb-se.clean.se
	cut -f2 smenob.utf8 > ${DATADIR}/${PRE}/glossary.nb-se.clean.nb
	cut -f1 termwiki.utf8 >> ${DATADIR}/${PRE}/glossary.nb-se.clean.se
	cut -f2 termwiki.utf8 >> ${DATADIR}/${PRE}/glossary.nb-se.clean.nb
	gzip -f ${DATADIR}/${PRE}/glossary.nb-se.clean.se
	gzip -f ${DATADIR}/${PRE}/glossary.nb-se.clean.nb
	rm -f smenob.utf8 termwiki.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/sme-sma/glossary/glossary.utf8
	cut -f1 glossary.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.se-sma.clean.se.gz
	cut -f2 glossary.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.se-sma.clean.sma.gz
	rm -f glossary.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/nob-smj/glossary/nobsmj.utf8
	cut -f1 nobsmj.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.nb-smj.clean.nb.gz
	cut -f2 nobsmj.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.nb-smj.clean.smj.gz
	rm -f nobsmj.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/nob-sme/glossary/nobsme.utf8
	cut -f1 nobsme.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.nb-se.clean.nb.gz
	cut -f2 nobsme.utf8 | gzip -c > ${DATADIR}/${PRE}/glossary.nb-se.clean.se.gz
	rm -f nobsme.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/nob-sma/glossary/nobsma.utf8
	${WGET} ${GIELLATEKNO_TM_HOME}/sma-nob/glossary/termwiki.utf8
	cut -f1 nobsma.utf8 > ${DATADIR}/${PRE}/glossary.nb-sma.clean.nb
	cut -f2 nobsma.utf8 > ${DATADIR}/${PRE}/glossary.nb-sma.clean.sma
	cut -f1 termwiki.utf8 >>${DATADIR}/${PRE}/glossary.nb-sma.clean.sma
	cut -f2 termwiki.utf8 >> ${DATADIR}/${PRE}/glossary.nb-sma.clean.nb
	gzip -f ${DATADIR}/${PRE}/glossary.nb-sma.clean.sma
	gzip -f ${DATADIR}/${PRE}/glossary.nb-sma.clean.nb
	rm -f nobsma.utf8 termwiki.utf8

fetch-sami-tmx: ${GIELLATEKNO_SAMI_TM}
convert-sami-tmx:
	for t in ${GIELLATEKNO_SAMI_TM}; do \
	  mkdir -p ${DATADIR}/sami; \
	  ${TMX2MOSES} -r -o ${DATADIR}/sami/`echo -n $$t | xargs basename | sed 's/.tmx//'` $$t; \
	done

## OLD: individual file names
move-sami-data:
	for f in `ls ${DATADIR}/sami`; do \
	  gzip -c < ${DATADIR}/sami/$$f \
	  > ${DATADIR}/${PRE}/`echo -n $$f | sed 's/\.\([^.]*\)$$/.clean.\1.gz/'`; \
	done

## NEW: merge all giellatekno TMs into one corpus
merge-sami-data:
	mkdir -p ${DATADIR}/${PRE}
	for s in fi nb se sma smj smn; do \
	  for t in fi nb se sma smj smn; do \
	    if [ `ls ${DATADIR}/sami/*.$$s-$$t.$$s 2>/dev/null | wc -l` -gt 0 ]; then \
	      p=`echo "$$s $$t" | tr ' ' "\n" | sort | tr "\n" '-' | sed 's/\-$$//'`; \
	      cat ${DATADIR}/sami/*.$$s-$$t.$$s >> ${DATADIR}/${PRE}/giella.$$p.clean.$$s; \
	      cat ${DATADIR}/sami/*.$$s-$$t.$$t >> ${DATADIR}/${PRE}/giella.$$p.clean.$$t; \
	    fi \
	  done \
	done
	for s in fi nb sma smj smn; do \
	  if [ `ls ${DATADIR}/sami/*.$$s-sme.$$s 2>/dev/null | wc -l` -gt 0 ]; then \
	    p=`echo "$$s se" | tr ' ' "\n" | sort | tr "\n" '-' | sed 's/\-$$//'`; \
	    cat ${DATADIR}/sami/*.$$s-sme.$$s >> ${DATADIR}/${PRE}/giella.$$p.clean.$$s; \
	    cat ${DATADIR}/sami/*.$$s-sme.sme >> ${DATADIR}/${PRE}/giella.$$p.clean.se; \
	  fi \
	done
	for t in fi nb sma smj smn; do \
	  if [ `ls ${DATADIR}/sami/*.sme-$$t.sem 2>/dev/null | wc -l` -gt 0 ]; then \
	    p=`echo "$$t se" | tr ' ' "\n" | sort | tr "\n" '-' | sed 's/\-$$//'`; \
	    cat ${DATADIR}/sami/*.sme-$$t.sme >> ${DATADIR}/${PRE}/giella.$$p.clean.se; \
	    cat ${DATADIR}/sami/*.sme-$$t.$$t >> ${DATADIR}/${PRE}/giella.$$p.clean.$$t; \
	  fi \
	done
	gzip -f ${DATADIR}/${PRE}/giella.*-*.clean.?? ${DATADIR}/${PRE}/giella.*-*.clean.???




${GIELLATEKNO_SAMI_TM}:
	mkdir -p ${dir $@}
	${WGET} -O $@ ${GIELLATEKNO_TM_HOME}/$@


## name of the sami data sets
# SAMI_EXTRA = ${patsubst %.tmx,%,${notdir ${GIELLATEKNO_SAMI_TM}}} glossary


#		FIT_DATA_SIZE=200000 \

%-finno-ugric:
	${MAKE} DATASET=${DATASET}+giella \
		HELDOUTSIZE=0 \
		BPESIZE=4000 \
		DEVSET=giella \
		TESTSET=giella \
		DEVMINSIZE=100 \
		EXTRA_TRAINSET="glossary" \
		SRCLANGS="se sma smj smn sms vep et fi kv krl nb no nn ru sv en" \
		TRGLANGS="se sma smj smn sms vep et fi kv krl nb no nn ru sv en" \
		SKIP_LANGPAIRS="en-en|en-et|en-fi|en-nb|en-no|en-nn|en-ru|en-sv|et-et|et-fi|et-nb|et-no|et-nn|et-ru|et-sv|fi-fi|fi-nb|fi-no|fi-nn|fi-ru|fi-sv|nb-nb|nb-no|nb-nn|nb-ru|nb-sv|no-no|no-nn|no-ru|no-sv|nn-nn|nn-ru|nn-sv|ru-ru|ru-sv|sv-sv" \
	${@:-sami=}

%-sami:
	${MAKE} DATASET=${DATASET}+giella \
		HELDOUTSIZE=0 \
		BPESIZE=4000 \
		DEVSET=giella \
		TESTSET=giella \
		DEVMINSIZE=100 \
		EXTRA_TRAINSET="glossary" \
		SRCLANGS="se sma smj smn sms fi nb no nn ru sv en" \
		TRGLANGS="se sma smj smn sms fi nb no nn ru sv en" \
		SKIP_LANGPAIRS="en-en|en-fi|en-nb|en-no|en-nn|en-ru|en-sv|fi-fi|fi-nb|fi-no|fi-nn|fi-ru|fi-sv|nb-nb|nb-no|nb-nn|nb-ru|nb-sv|no-no|no-nn|no-ru|no-sv|nn-nn|nn-ru|nn-sv|ru-ru|ru-sv|sv-sv" \
	${@:-sami=}



%-sami-xx:
	${MAKE} DATASET=${DATASET}+giella \
		HELDOUTSIZE=0 \
		BPESIZE=4000 \
		DEVSET=giella \
		TESTSET=giella \
		DEVMINSIZE=100 \
		EXTRA_TRAINSET="glossary" \
		SRCLANGS="se sma smj smn sms" \
		TRGLANGS="fi nb no nn ru sv en" \
	${@:-sami-xx=}

%-xx-sami:
	${MAKE} DATASET=${DATASET}+giella \
		HELDOUTSIZE=0 \
		BPESIZE=4000 \
		DEVSET=giella \
		TESTSET=giella \
		DEVMINSIZE=100 \
		EXTRA_TRAINSET="glossary" \
		TRGLANGS="se sma smj smn sms" \
		SRCLANGS="fi nb no nn ru sv en" \
	${@:-xx-sami=}



