# -*-makefile-*-

AMERICASNLP_WORK     ?= ${PWD}/work-americasnlp
AMERICASNLP_TESTSETS ?= ${PWD}/americasnlp-testsets
AMERICASNLP_BTHOME   ?= ${PWD}/bt-americasnlp




AMERICASNLP_SRC = es
AMERICASNLP_TRG = aym bzd cni gn hch nah oto quy shp tar tnh wix
AMERICASNLP_TRG_EXTRA = que quz shi

LANGGROUP_NAI = $(sort ${shell langgroup -n nai} ${shell langgroup nai | iso639 -k -2 -n})
LANGGROUP_SAI = $(sort ay ayr ayc ${shell langgroup -n sai} ${shell langgroup sai | iso639 -k -2 -n})
LANGGROUP_CAI = $(sort ${shell langgroup -n cai} ${shell langgroup cai | iso639 -k -2 -n})

AMERICASNLP_TRGALL = $(sort ${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA} \
			$(filter ${OPUSLANGS},${LANGGROUP_NAI} ${LANGGROUP_SAI} ${LANGGROUP_CAI}))

# AMERICASNLP_TRGALL = ${sort ${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA} ${LANGGROUP_NAI} ${LANGGROUP_SAI}}


AMERICASNLP_FIT_DATA_SIZE = 100000
AMERICASNLP_PIVOT = en


# /scratch/project_2001194/yves/americas/backtrans/merged/*.dedup.*


americasnlp-data:
	mkdir -p ${AMERICASNLP_WORK}/data/simple
	rm -f americasnlp2021.es-*
	for l in ${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA}; do \
	  for t in `find americasnlp2021-st/data -name "*.$$l"`; do \
	    s=`echo "$$t" | sed "s/\.$$l$$/.es/"`; \
	    if [ $$l \< es ]; then p="$$l-es"; else p="es-$$l"; fi; \
	    if [ `basename $$s` == 'dev.es' ]; then \
	      echo "test set: $${t}-es"; \
	      cat $$s >> ${AMERICASNLP_WORK}/data/simple/americasnlp2021-test.$$p.clean.es; \
	      cat $$t >> ${AMERICASNLP_WORK}/data/simple/americasnlp2021-test.$$p.clean.$$l; \
	    elif [ -e $$s ]; then \
	      echo "add to train: $${t}-es"; \
	      cat $$s >> americasnlp2021.es-$$l.es; \
	      cat $$t >> americasnlp2021.es-$$l.$$l; \
	    fi \
	  done \
	done
	for l in ${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA}; do \
	  if [ $$l \< es ]; then p="$$l-es"; else p="es-$$l"; fi; \
	  paste americasnlp2021.es-$$l.es americasnlp2021.es-$$l.$$l |\
	  grep . | grep -v '^ *	' | grep -v '	 *$$' | ${SORT} -u | ${SHUFFLE} > americasnlp2021.es-$$l.shuffled; \
	  head -100 americasnlp2021.es-$$l.shuffled | cut -f1 \
		> ${AMERICASNLP_WORK}/data/simple/americasnlp2021-dev.$$p.clean.es; \
	  head -100 americasnlp2021.es-$$l.shuffled | cut -f2 \
		> ${AMERICASNLP_WORK}/data/simple/americasnlp2021-dev.$$p.clean.$$l; \
	  tail -n +101 americasnlp2021.es-$$l.shuffled | cut -f1 \
		> ${AMERICASNLP_WORK}/data/simple/americasnlp2021-train.$$p.clean.es; \
	  tail -n +101 americasnlp2021.es-$$l.shuffled | cut -f2 \
		> ${AMERICASNLP_WORK}/data/simple/americasnlp2021-train.$$p.clean.$$l; \
	  gzip -f ${AMERICASNLP_WORK}/data/simple/americasnlp2021-*.$$p.clean.es; \
	  gzip -f ${AMERICASNLP_WORK}/data/simple/americasnlp2021-*.$$p.clean.$$l; \
	done


americasnlp-testdata:
	for l in ${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA}; do \
	  for t in `find americasnlp2021-st/data -name "dev.$$l"`; do \
	    s=`echo "$$t" | sed "s/\.$$l$$/.es/"`; \
	    echo "test set: $${t}-es"; \
	    mkdir -p americasnlp-testsets/es-$$l; \
	    gzip -c < $$s > americasnlp-testsets/es-$$l/americasnlp2021-devtest.es.gz; \
	    gzip -c < $$t > americasnlp-testsets/es-$$l/americasnlp2021-devtest.$$l.gz; \
	    mkdir -p americasnlp-testsets/$$l-es; \
	    gzip -c < $$s > americasnlp-testsets/$$l-es/americasnlp2021-devtest.es.gz; \
	    gzip -c < $$t > americasnlp-testsets/$$l-es/americasnlp2021-devtest.$$l.gz; \
	  done \
	done


AMERICASNLP_YVES_BTDIR = /scratch/project_2001194/yves/americas/backtrans/merged

americasnlp-btdata:
	for l in ${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA}; do \
	  if [ -e ${AMERICASNLP_YVES_BTDIR}/backtrans_$$l.dedup.$$l ]; then \
	    mkdir -p ${AMERICASNLP_BTHOME}/$$l-es/latest; \
	    gzip -c < ${AMERICASNLP_YVES_BTDIR}/backtrans_$$l.dedup.$$l > ${AMERICASNLP_BTHOME}/$$l-es/latest/backtrans_$$l.dedup.$$l.gz; \
	    gzip -c < ${AMERICASNLP_YVES_BTDIR}/backtrans_$$l.dedup.es > ${AMERICASNLP_BTHOME}/$$l-es/latest/backtrans_$$l.dedup.es.gz; \
	  fi \
	done


%-americasnlp:
	make 	SRCLANGS="${AMERICASNLP_SRC}" \
		TRGLANGS="${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA}" \
		WORKHOME=${AMERICASNLP_WORK} \
		BACKTRANS_HOME=${AMERICASNLP_BTHOME} \
		TESTSET_HOME=${AMERICASNLP_TESTSETS} \
		MODELTYPE=transformer-align \
		SRCBPESIZE=32000 \
		TRGBPESIZE=32000 \
		BPESIZE=32000 \
		GPUJOB_HPC_MEM=8g \
		MARIAN_VALID_FREQ=2500 \
		DATASET=americasnlp \
		TRAINSET=americasnlp2021-train \
		EXTRA_TRAINSET=americasnlp2021-train \
		DEVSET=americasnlp2021-dev \
		TESTSET=americasnlp2021-test \
		DEVSET_NAME=americasnlp2021-dev \
		TESTSET_NAME=americasnlp2021-test \
		FIT_DATA_SIZE=${AMERICASNLP_FIT_DATA_SIZE} \
		SHUFFLE_DATA=1 \
		LANGPAIRSTR="es-xx" \
	${@:-americasnlp=}


%-americasnlp-langtune:
	make 	CONTINUE_EXISTING=1 \
		MARIAN_VALID_FREQ=${TUNE_VALID_FREQ} \
		MARIAN_DISP_FREQ=${TUNE_DISP_FREQ} \
		MARIAN_SAVE_FREQ=${TUNE_SAVE_FREQ} \
		MARIAN_EARLY_STOPPING=${TUNE_EARLY_STOPPING} \
		MARIAN_EXTRA='-e 5 --no-restore-corpus' \
		GPUJOB_SUBMIT=${TUNE_GPUJOB_SUBMIT} \
		DATASET=americasnlp-tuned4${TUNE_SRC}2${TUNE_TRG} \
		SRCLANGS="${TUNE_SRC}" \
		TRGLANGS="${TUNE_TRG}" \
		WORKHOME=${AMERICASNLP_WORK} \
		BACKTRANS_HOME=${AMERICASNLP_BTHOME} \
		TESTSET_HOME=${AMERICASNLP_TESTSETS} \
		MODELTYPE=transformer-align \
		SRCBPESIZE=32000 \
		TRGBPESIZE=32000 \
		BPESIZE=32000 \
		GPUJOB_HPC_MEM=8g \
		TRAINSET=americasnlp2021-train \
		EXTRA_TRAINSET=americasnlp2021-train \
		DEVSET=americasnlp2021-dev \
		TESTSET=americasnlp2021-test \
		DEVSET_NAME=americasnlp2021-dev \
		TESTSET_NAME=americasnlp2021-test \
		FIT_DATA_SIZE=${AMERICASNLP_FIT_DATA_SIZE} \
		SHUFFLE_DATA=1 \
		LANGPAIRSTR="es-xx" \
	${@:-americasnlp-langtune=}



%-americasnlp-reverse:
	make 	TRGLANGS="${AMERICASNLP_SRC}" \
		SRCLANGS="${AMERICASNLP_TRG} ${AMERICASNLP_TRG_EXTRA}" \
		WORKHOME=${AMERICASNLP_WORK} \
		BACKTRANS_HOME=${AMERICASNLP_BTHOME} \
		TESTSET_HOME=${AMERICASNLP_TESTSETS} \
		MODELTYPE=transformer-align \
		SRCBPESIZE=32000 \
		TRGBPESIZE=32000 \
		BPESIZE=32000 \
		GPUJOB_HPC_MEM=8g \
		MARIAN_VALID_FREQ=2500 \
		DATASET=americasnlp \
		TRAINSET=americasnlp2021-train \
		EXTRA_TRAINSET=americasnlp2021-train \
		DEVSET=americasnlp2021-dev \
		TESTSET=americasnlp2021-test \
		DEVSET_NAME=americasnlp2021-dev \
		TESTSET_NAME=americasnlp2021-test \
		FIT_DATA_SIZE=${AMERICASNLP_FIT_DATA_SIZE} \
		SHUFFLE_DATA=1 \
		LANGPAIRSTR="xx-es" \
	${@:-americasnlp-reverse=}


%-americasnlp-opus:
	make 	SRCLANGS="${AMERICASNLP_SRC} ${AMERICASNLP_PIVOT}" \
		TRGLANGS="${AMERICASNLP_TRGALL}" \
		WORKHOME=${AMERICASNLP_WORK} \
		BACKTRANS_HOME=${AMERICASNLP_BTHOME} \
		TESTSET_HOME=${AMERICASNLP_TESTSETS} \
		MODELTYPE=transformer-align \
		SRCBPESIZE=32000 \
		TRGBPESIZE=32000 \
		BPESIZE=32000 \
		GPUJOB_HPC_MEM=8g \
		DATASET=opus-americasnlp \
		EXTRA_TRAINSET=americasnlp2021-train \
		DEVSET=americasnlp2021-dev \
		TESTSET=americasnlp2021-test \
		DEVSET_NAME=americasnlp2021-dev \
		TESTSET_NAME=americasnlp2021-test \
		FIT_DATA_SIZE=${AMERICASNLP_FIT_DATA_SIZE} \
		SHUFFLE_DATA=1 \
		LANGPAIRSTR="es+en-xx" \
	${@:-americasnlp-opus=}

%-americasnlp-opus-reverse:
	make 	TRGLANGS="${AMERICASNLP_SRC} ${AMERICASNLP_PIVOT}" \
		SRCLANGS="${AMERICASNLP_TRGALL}" \
		WORKHOME=${AMERICASNLP_WORK} \
		BACKTRANS_HOME=${AMERICASNLP_BTHOME} \
		TESTSET_HOME=${AMERICASNLP_TESTSETS} \
		MODELTYPE=transformer-align \
		SRCBPESIZE=32000 \
		TRGBPESIZE=32000 \
		BPESIZE=32000 \
		GPUJOB_HPC_MEM=8g \
		DATASET=opus-americasnlp \
		EXTRA_TRAINSET=americasnlp2021-train \
		DEVSET=americasnlp2021-dev \
		TESTSET=americasnlp2021-test \
		DEVSET_NAME=americasnlp2021-dev \
		TESTSET_NAME=americasnlp2021-test \
		FIT_DATA_SIZE=${AMERICASNLP_FIT_DATA_SIZE} \
		SHUFFLE_DATA=1 \
		LANGPAIRSTR="xx-es+en" \
	${@:-americasnlp-opus-reverse=}

