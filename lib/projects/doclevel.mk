# -*-makefile-*-


DOCLEVEL_BENCHMARK_DATA = https://zenodo.org/record/3525366/files/doclevel-MT-benchmark-discomt2019.zip




#-------------------------------------------------------------------
# document-level MT (concatenation approach)
#-------------------------------------------------------------------


doclevel:
	${MAKE} ost-datasets
	${MAKE} traindata-doc-ost
	${MAKE} devdata-doc-ost
	${MAKE} wordalign-doc-ost
	${MAKE} CONTEXT_SIZE=${CONTEXT_SIZE} MODELTYPE=${MODELTYPE} \
		HPC_CORES=1 WALLTIME=72 HPC_MEM=4g train-doc-ost.submit




## continue document-level training with a new context size

ifndef NEW_CONTEXT
  NEW_CONTEXT = $$(($(CONTEXT_SIZE) + $(CONTEXT_SIZE)))
endif

continue-doctrain:
	mkdir -p ${WORKDIR}/${MODEL}
	cp ${MODEL_VOCAB} ${WORKDIR}/${MODEL}/$(subst .doc${CONTEXT_SIZE},.doc${NEW_CONTEXT},${notdir ${MODEL_VOCAB}})
	cp ${MODEL_FINAL} ${WORKDIR}/${MODEL}/$(subst .doc${CONTEXT_SIZE},.doc${NEW_CONTEXT},$(notdir ${MODEL_BASENAME})).npz
	${MAKE} MODEL_SUBDIR=${MODEL}/ CONTEXT_SIZE=$(NEW_CONTEXT) train-doc




## continue training with a new dataset

ifndef NEW_DATASET
  NEW_DATASET = OpenSubtitles
endif

continue-datatrain:
	mkdir -p ${WORKDIR}/${MODEL}
	cp ${MODEL_VOCAB} ${WORKDIR}/${MODEL}/$(patsubst ${DATASET}%,${NEW_DATASET}%,${notdir ${MODEL_VOCAB}})
	cp ${MODEL_FINAL} ${WORKDIR}/${MODEL}/$(patsubst ${DATASET}%,${NEW_DATASET}%,${MODEL_BASENAME}).npz
	if [ -e ${BPESRCMODEL} ]; then \
	  cp ${BPESRCMODEL} $(patsubst ${WORKDIR}/train/${DATASET}%,${WORKDIR}/train/${NEW_DATASET}%,${BPESRCMODEL}); \
	  cp ${BPETRGMODEL} $(patsubst ${WORKDIR}/train/${DATASET}%,${WORKDIR}/train/${NEW_DATASET}%,${BPETRGMODEL}); \
	fi
	if [ -e ${SPMSRCMODEL} ]; then \
	  cp ${SPMSRCMODEL} $(patsubst ${WORKDIR}/train/${DATASET}%,${WORKDIR}/train/${NEW_DATASET}%,${SPMSRCMODEL}); \
	  cp ${SPMTRGMODEL} $(patsubst ${WORKDIR}/train/${DATASET}%,${WORKDIR}/train/${NEW_DATASET}%,${SPMTRGMODEL}); \
	fi
	${MAKE} MODEL_SUBDIR=${MODEL}/ DATASET=$(NEW_DATASET) train


# MARIAN_EXTRA="${MARIAN_EXTRA} --no-restore-corpus"





## use the doclevel benchmark data sets
%-ost:
	${MAKE} ost-datasets
	${MAKE} SRCLANGS=en TRGLANGS=de \
		TRAINSET=ost-train \
		DEVSET=ost-dev \
		TESTSET=ost-test \
		DEVSIZE=100000 TESTSIZE=100000 HELDOUTSIZE=0 \
	${@:-ost=}




ost-datasets: 	${DATADIR}/${PRE}/ost-train.de-en.clean.de.gz \
		${DATADIR}/${PRE}/ost-train.de-en.clean.en.gz \
		${DATADIR}/${PRE}/ost-dev.de-en.clean.de.gz \
		${DATADIR}/${PRE}/ost-dev.de-en.clean.en.gz \
		${DATADIR}/${PRE}/ost-test.de-en.clean.de.gz \
		${DATADIR}/${PRE}/ost-test.de-en.clean.en.gz


.INTERMEDIATE: ${WORKHOME}/doclevel-MT-benchmark

## download the doc-level data set
${WORKHOME}/doclevel-MT-benchmark:
	wget -O $@.zip DOCLEVEL_BENCHMARK_DATA?download=1
	unzip -d ${dir $@} $@.zip
	rm -f $@.zip

${DATADIR}/${PRE}/ost-train.de-en.clean.de.gz: ${WORKHOME}/doclevel-MT-benchmark
	mkdir -p ${dir $@}
	$(TOKENIZER)/detokenizer.perl -l de < $</train/ost.tok.de | gzip -c > $@

${DATADIR}/${PRE}/ost-train.de-en.clean.en.gz: ${WORKHOME}/doclevel-MT-benchmark
	mkdir -p ${dir $@}
	$(TOKENIZER)/detokenizer.perl -l en < $</train/ost.tok.en | gzip -c > $@

${DATADIR}/${PRE}/ost-dev.de-en.clean.de.gz: ${WORKHOME}/doclevel-MT-benchmark
	mkdir -p ${dir $@}
	$(TOKENIZER)/detokenizer.perl -l de < $</dev/ost.tok.de | gzip -c > $@

${DATADIR}/${PRE}/ost-dev.de-en.clean.en.gz: ${WORKHOME}/doclevel-MT-benchmark
	mkdir -p ${dir $@}
	$(TOKENIZER)/detokenizer.perl -l en < $</dev/ost.tok.en | gzip -c > $@

${DATADIR}/${PRE}/ost-test.de-en.clean.de.gz: ${WORKHOME}/doclevel-MT-benchmark
	mkdir -p ${dir $@}
	$(TOKENIZER)/detokenizer.perl -l de < $</test/ost.tok.de | gzip -c > $@

${DATADIR}/${PRE}/ost-test.de-en.clean.en.gz: ${WORKHOME}/doclevel-MT-benchmark
	mkdir -p ${dir $@}
	$(TOKENIZER)/detokenizer.perl -l en < $</test/ost.tok.en | gzip -c > $@


