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


## we keep the dependency on LOCAL_TRAIN_SRC
## to make multi-threaded make calls behave properly
## --> otherwise there can be multiple threads writing to the same file!

${BPESRCMODEL}: ${LOCAL_TRAIN_SRC}
ifneq (${wildcard ${BPESRCMODEL}},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! back-date $<"
	touch -r $@ $<
else
	mkdir -p ${dir $@}
ifeq (${USE_TARGET_LABELS},1)
	cut -f2- -d ' ' ${LOCAL_TRAIN_SRC} > ${LOCAL_TRAIN_SRC}.text
	${BPE_LEARN} -s $(SRCBPESIZE) < ${LOCAL_TRAIN_SRC}.text > $@
	rm -f ${LOCAL_TRAIN_SRC}.text
else
	${BPE_LEARN} -s $(SRCBPESIZE) < ${LOCAL_TRAIN_SRC} > $@
endif
endif

## no labels on the target language side
${BPETRGMODEL}: ${LOCAL_TRAIN_TRG}
ifneq (${wildcard ${BPETRGMODEL}},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! back-date $<"
	touch -r $@ $<
else
	mkdir -p ${dir $@}
	${BPE_LEARN} -s $(TRGBPESIZE) < ${LOCAL_TRAIN_TRG} > $@
endif



%.src.bpe${SRCBPESIZE:000=}k: %.src ${BPESRCMODEL}
ifeq (${USE_TARGET_LABELS},1)
	cut -f1 -d ' ' $< > $<.labels
	cut -f2- -d ' ' $< > $<.txt
	${BPE_APPLY} -c $(word 2,$^) < $<.txt > $@.txt
	paste -d ' ' $<.labels $@.txt > $@
	rm -f $<.labels $<.txt $@.txt
else
	${BPE_APPLY} -c $(word 2,$^) < $< > $@
endif

%.trg.bpe${TRGBPESIZE:000=}k: %.trg ${BPETRGMODEL}
	${BPE_APPLY} -c $(word 2,$^) < $< > $@


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

