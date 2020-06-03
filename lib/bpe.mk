# -*-makefile-*-


##----------------------------------------------
## BPE
##----------------------------------------------

bpe-models: ${BPESRCMODEL} ${BPETRGMODEL}

## source/target specific bpe
## - make sure to leave the language flags alone!
## - make sure that we do not delete the BPE code files
## if the BPE models already exist
## ---> do not create new ones and always keep the old ones
## ---> need to delete the old ones if we want to create new BPE models


# BPESRCMODEL = ${TRAIN_SRC}.bpe${SRCBPESIZE:000=}k-model
# BPETRGMODEL = ${TRAIN_TRG}.bpe${TRGBPESIZE:000=}k-model

## NEW: always use the same name for the BPE models
## --> avoid overwriting validation/test data with new segmentation models
##     if a new data set is used
BPESRCMODEL = ${WORKDIR}/train/${BPEMODELNAME}.src.bpe${SRCBPESIZE:000=}k-model
BPETRGMODEL = ${WORKDIR}/train/${BPEMODELNAME}.trg.bpe${TRGBPESIZE:000=}k-model


.PRECIOUS: ${BPESRCMODEL} ${BPETRGMODEL}

# ${BPESRCMODEL}: ${WORKDIR}/%.bpe${SRCBPESIZE:000=}k-model: ${TMPDIR}/${LANGPAIRSTR}/%
# ${BPESRCMODEL}: ${LOCAL_TRAIN_SRC}
${BPESRCMODEL}: 
	${MAKE} ${LOCAL_TRAIN_SRC}
	mkdir -p ${dir $@}
ifeq ($(TRGLANGS),${firstword ${TRGLANGS}})
	python3 ${SNMTPATH}/learn_bpe.py -s $(SRCBPESIZE) < ${LOCAL_TRAIN_SRC} > $@
else
	cut -f2- -d ' ' ${LOCAL_TRAIN_SRC} > ${LOCAL_TRAIN_SRC}.text
	python3 ${SNMTPATH}/learn_bpe.py -s $(SRCBPESIZE) < ${LOCAL_TRAIN_SRC}.text > $@
	rm -f ${LOCAL_TRAIN_SRC}.text
endif


## no labels on the target language side
# ${BPETRGMODEL}: ${WORKDIR}/%.bpe${TRGBPESIZE:000=}k-model: ${TMPDIR}/${LANGPAIRSTR}/%
# ${BPETRGMODEL}: ${LOCAL_TRAIN_TRG}
${BPETRGMODEL}: 
	${MAKE} ${LOCAL_TRAIN_TRG}
	mkdir -p ${dir $@}
	python3 ${SNMTPATH}/learn_bpe.py -s $(TRGBPESIZE) < ${LOCAL_TRAIN_TRG} > $@


%.src.bpe${SRCBPESIZE:000=}k: %.src ${BPESRCMODEL}
ifeq ($(TRGLANGS),${firstword ${TRGLANGS}})
	python3 ${SNMTPATH}/apply_bpe.py -c $(word 2,$^) < $< > $@
else
	cut -f1 -d ' ' $< > $<.labels
	cut -f2- -d ' ' $< > $<.txt
	python3 ${SNMTPATH}/apply_bpe.py -c $(word 2,$^) < $<.txt > $@.txt
	paste -d ' ' $<.labels $@.txt > $@
	rm -f $<.labels $<.txt $@.txt
endif

%.trg.bpe${TRGBPESIZE:000=}k: %.trg ${BPETRGMODEL}
	python3 ${SNMTPATH}/apply_bpe.py -c $(word 2,$^) < $< > $@


## this places @@ markers in front of punctuations
## if they appear to the right of the segment boundary
## (useful if we use BPE without tokenization)
%.segfix: %
	perl -pe 's/(\P{P})\@\@ (\p{P})/$$1 \@\@$$2/g' < $< > $@



%.trg.txt: %.trg
	mkdir -p ${dir $@}
	mv $< $@

%.src.txt: %.src
	mkdir -p ${dir $@}
	mv $< $@

