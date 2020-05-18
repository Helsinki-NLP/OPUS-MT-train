
#-------------------------------------------------------------------
# models for Celtic languages
#-------------------------------------------------------------------

# examples:
#
#   make train-celtic-english
#   make train-bt-celtic-english
#   make train-pivot-bt-celtic-english
#
#   make HPC_CORES=2 HPC_MEM=8g all-job-pivot-bt-english-celtic.submitcpu
#   make HPC_CORES=2 HPC_MEM=8g CELTIC_BPESIZE=12000 all-job-pivot-bt-celtic-english.submitcpu


## reduce vocabulary

# CELTIC_BPESIZE = 12000
CELTIC_BPESIZE = 4000


## only OPUS data

%-celtic-english-opus:
	${MAKE} HELDOUTSIZE=0 BPESIZE=${CELTIC_BPESIZE} SRCLANGS="ga cy br gd kw gv" TRGLANGS=en ${@:-celtic-english-opus=}

%-english-celtic-opus:
	${MAKE} HELDOUTSIZE=0 BPESIZE=${CELTIC_BPESIZE} TRGLANGS="ga cy br gd kw gv" SRCLANGS=en TRG=ga SRC=en ${@:-english-celtic-opus=}


# more data for cy-en

%-celtic-english: ${DATADIR}/${PRE}/dic.cy-en.clean.cy.gz
	${MAKE} DATASET=opus+techiaith HELDOUTSIZE=0 BPESIZE=${CELTIC_BPESIZE} \
		EXTRA_TRAINSET="CofnodYCynulliad Deddfwriaeth Meddalwedd rhestr_geiriau dic" \
		SRCLANGS="ga cy br gd kw gv" TRGLANGS=en \
	${@:-celtic-english=}

%-english-celtic: ${DATADIR}/${PRE}/dic.cy-en.clean.cy.gz
	${MAKE} DATASET=opus+techiaith HELDOUTSIZE=0 BPESIZE=${CELTIC_BPESIZE} \
		EXTRA_TRAINSET="CofnodYCynulliad Deddfwriaeth Meddalwedd rhestr_geiriau dic" \
		TRGLANGS="ga cy br gd kw gv" SRCLANGS=en TRG=ga SRC=en \
	${@:-english-celtic=}




## extra data from http://techiaith.cymru

# http://techiaith.cymru/corpws/Moses/CofnodYCynulliad/CofnodYCynulliad.tar.gz
# http://techiaith.cymru/corpws/Moses/Deddfwriaeth/Deddfwriaeth.tar.gz
# http://techiaith.cymru/corpws/Moses/Meddalwedd/Meddalwedd.tar.gz
# http://techiaith.cymru/alinio/rhestr_geiriau.tsv
# http://techiaith.cymru/alinio/hunalign/cy-en.dic

.PHONY: welsh-data
welsh-data: ${DATADIR}/${PRE}/dic.cy-en.clean.cy.gz

${DATADIR}/${PRE}/dic.cy-en.clean.cy.gz:
	for c in CofnodYCynulliad Deddfwriaeth Meddalwedd; do \
	  wget http://techiaith.cymru/corpws/Moses/$$c/$$c.tar.gz; \
	  tar -xzf $$c.tar.gz; \
	  $(TOKENIZER)/detokenizer.perl -l cy < $$c.cy |\
	  $(MOSESSCRIPTS)/recaser/detruecase.perl | gzip -c > ${DATADIR}/${PRE}/$$c.cy-en.clean.cy.gz; \
	  $(TOKENIZER)/detokenizer.perl -l en < $$c.en |\
	  $(MOSESSCRIPTS)/recaser/detruecase.perl | gzip -c > ${DATADIR}/${PRE}/$$c.cy-en.clean.en.gz; \
	  rm -f $$c.tar.gz; \
	done
	wget http://techiaith.cymru/alinio/rhestr_geiriau.tsv
	tail -n +16 rhestr_geiriau.tsv | cut -f1 | gzip -c > ${DATADIR}/${PRE}/rhestr_geiriau.cy-en.clean.en.gz
	tail -n +16 rhestr_geiriau.tsv | cut -f2 | gzip -c > ${DATADIR}/${PRE}/rhestr_geiriau.cy-en.clean.cy.gz
	rm -f rhestr_geiriau.tsv
	wget http://techiaith.cymru/alinio/hunalign/cy-en.dic
	cut -f1 -d '@' < cy-en.dic | sed 's/ $$*//' | gzip -c > ${DATADIR}/${PRE}/dic.cy-en.clean.en.gz
	cut -f2 -d '@' < cy-en.dic | sed 's/^ *//' | gzip -c > ${DATADIR}/${PRE}/dic.cy-en.clean.cy.gz

${DATADIR}/${PRE}/%.cy-en.clean.cy.gz:
	wget http://techiaith.cymru/corpws/Moses/$(patsubst %.cy-en.clean.cy.gz,%.tar.gz,${notdir $@})
	tar -xzf $(patsubst %.cy-en.clean.cy.gz,%.tar.gz,${notdir $@})
	$(TOKENIZER)/detokenizer.perl -l cy < $(patsubst %.cy-en.clean.cy.gz,%.cy,${notdir $@}) |\
	$(MOSESSCRIPTS)/recaser/detruecase.perl | gzip -c > $@
	$(TOKENIZER)/detokenizer.perl -l en < $(patsubst %.cy-en.clean.cy.gz,%.en,${notdir $@}) |\
	$(MOSESSCRIPTS)/recaser/detruecase.perl | gzip -c > ${@:.cy.gz=.en.gz}
	rm -f $(patsubst %.cy-en.clean.cy.gz,%.tar.gz,${notdir $@})


