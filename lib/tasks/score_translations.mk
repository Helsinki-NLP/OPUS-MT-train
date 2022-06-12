# -*-makefile-*-
#
#
# score translations by applying a reverse translation models
# on the translations and the given input sentences
#
# --> used as a CE-filter to remove some noise
#
# OUTPUT_DIR .............. contains all bitext to be filtered (e.g. FT_OUTPUT_DIR/latest)
# CEFILTER_RETAIN ......... give a number in percent about how much data to retain (default=95%)
# 



# CEFILTER_REMOVE: Part of the data to be removed (0.05 is 5%)
# (see https://github.com/browsermt/students)

# CEFILTER_REMOVE ?= 0.05
# CEFILTER_RETAIN  = ${shell echo "100-100*${REMOVE}/1;" | bc}
CEFILTER_RETAIN ?= 95
CEFILTER_REMOVE  = ${shell echo "scale=2; (100-${CEFILTER_RETAIN})/100" | bc}


##-------------------------------------------
## translation model in reverse direction
## --> for scoring translations
##-------------------------------------------

REV_LANGPAIR   = ${TRG}-${SRC}
REV_MODELZIP  := ${call best-opusmt-model,${REV_LANGPAIR},bleu-scores}
REV_MODELINFO := ${REV_MODELZIP:.zip=.yml}
REV_MODELNAME  = ${patsubst %.zip,%,${notdir ${REV_MODELZIP}}}

REV_MULTI_TARGET_MODEL := ${shell ${WGET} -qq -O - ${REV_MODELINFO} | grep 'use-target-labels' | wc -l}
ifeq (${REV_MULTI_TARGET_MODEL},1)
  REV_SRC_PREPROCESS_ARGS = ${TRG} ${SRC} ${OUTPUT_DIR}/${REV_MODELNAME}/source.spm
  REV_TRG_PREPROCESS_ARGS = ${SRC} ${TRG} ${OUTPUT_DIR}/${REV_MODELNAME}/target.spm noflags
else
  REV_SRC_PREPROCESS_ARGS = ${TRG} ${OUTPUT_DIR}/${REV_MODELNAME}/source.spm
  REV_TRG_PREPROCESS_ARGS = ${SRC} ${OUTPUT_DIR}/${REV_MODELNAME}/target.spm
endif


#########################################################################
## score translations with reverse translation model
## normalize scores (see https://github.com/browsermt/students)
#########################################################################

SCOREFILES    = $(patsubst %.${SRC}.gz,%.${SRC}.scores.gz,$(wildcard ${OUTPUT_DIR}/*.${SRC}.gz))
RAWSCOREFILES = $(patsubst %.${SRC}.gz,%.${SRC}.raw-scores.gz,$(wildcard ${OUTPUT_DIR}/*.${SRC}.gz))

.PHONY: score-translation score-translations
.PHONY: sort-scored-translations sort-raw-scored-translations
score-translation: ${BITEXT_SRC:.gz=.scores.gz}
score-translations: ${SCOREFILES}
sort-scored-translations: ${OUTPUT_DIR}/bitext.sorted.gz
sort-raw-scored-translations: ${OUTPUT_DIR}/bitext.sorted-raw.gz

.PHONY: print-score-file
print-score-file:
	@echo ${BITEXT_SRC:.gz=.scores.gz}
	@echo ${SCOREFILES}
	@echo "tenplate: ${OUTPUT_DIR}/*.${SRC}.gz"

${OUTPUT_DIR}/%.${SRC}.scores.gz: ${OUTPUT_DIR}/%.${SRC}.gz mosesdecoder marian-dev tools/marian-dev tools/moses-scripts
	${MAKE} SRC=${TRG} TRG=${SRC} opusmt-model
	${GZCAT} ${<:.${SRC}.gz=.${TRG}.gz} |\
	${OUTPUT_DIR}/${REV_MODELNAME}/preprocess.sh ${REV_SRC_PREPROCESS_ARGS} | \
	${GZIP} -c > $@.src.gz
	${GZCAT} $< |\
	${OUTPUT_DIR}/${REV_MODELNAME}/preprocess.sh ${REV_TRG_PREPROCESS_ARGS} | \
	${GZIP} -c > $@.trg.gz
	${LOAD_ENV} && \
	cd ${OUTPUT_DIR}/${REV_MODELNAME} && \
	${MARIAN_SCORER} \
		-m `grep -A1 models decoder.yml | tail -1 | sed 's/ *- //'` \
		-v `grep -A2 vocabs decoder.yml | tail -2 | sed 's/ *- //' | tr "\n" ' '` \
		-t ../$(notdir $@).src.gz ../$(notdir $@).trg.gz \
		${MARIAN_SCORER_FLAGS} |\
	${GZIP} -c > ../$(notdir $(@:.scores.gz=.raw-scores.gz))
	paste <(gzip -dc $(@:.scores.gz=.raw-scores.gz)) <(gzip -dc $@.trg.gz) | \
	python3 ${SCRIPTDIR}/normalize-scores.py | cut -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz


${OUTPUT_DIR}/bitext.sorted.gz: ${SCOREFILES}
	${GZCAT} $^ | ${GZIP} -c > $@.scores.gz
	${GZCAT} $(patsubst %.${SRC}.scores.gz,%.${SRC}.gz,$^) | ${GZIP} -c > $@.src.gz
	${GZCAT} $(patsubst %.${SRC}.scores.gz,%.${TRG}.gz,$^) | ${GZIP} -c > $@.trg.gz
	paste <(gzip -cd $@.scores.gz) <(gzip -cd $@.src.gz) <(gzip -cd $@.trg.gz) |\
	LC_ALL=C sort -n -k1,1 -S 10G | uniq -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz $@.scores.gz


${OUTPUT_DIR}/bitext.sorted-raw.gz: ${RAWSCOREFILES}
	${GZCAT} $^ | ${GZIP} -c > $@.raw-scores.gz
	${GZCAT} $(patsubst %.${SRC}.raw-scores.gz,%.${SRC}.gz,$^) | ${GZIP} -c > $@.src.gz
	${GZCAT} $(patsubst %.${SRC}.raw-scores.gz,%.${TRG}.gz,$^) | ${GZIP} -c > $@.trg.gz
	paste <(gzip -cd $@.raw-scores.gz) <(gzip -cd $@.src.gz) <(gzip -cd $@.trg.gz) |\
	LC_ALL=C sort -n -k1,1 -S 10G | uniq -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz $@.raw-scores.gz


#########################################################################
## extract the best translations from the ranked list
## CEFILTER_REMOVE controls how much will be removed (proportionally)
#########################################################################

.PHONY: extract-best-translations extract-rawbest-translations
extract-best-translations: ${OUTPUT_DIR}/best${CEFILTER_RETAIN}/bitext.${SRC}.gz
extract-rawbest-translations: ${OUTPUT_DIR}/rawbest${CEFILTER_RETAIN}/bitext.${SRC}.gz

${OUTPUT_DIR}/best${CEFILTER_RETAIN}/%.${SRC}.gz: ${OUTPUT_DIR}/%.sorted.gz
	mkdir -p $(dir $@)
	$(eval STARTLINE := $(shell ${GZIP} -dc $< | wc -l | sed "s|$$|*$(CEFILTER_REMOVE)|" | bc | cut -f1 -d.))
	@echo Removing $(CEFILTER_REMOVE) removes $(STARTLINE) lines
	${GZIP} -dc $< | tail -n +$(STARTLINE) | cut -f2,3 | \
	tee >(cut -f1 | gzip -c >$@) |\
	cut -f2 | gzip -c > ${@:.${SRC}.gz=.${TRG}.gz}

${OUTPUT_DIR}/best${CEFILTER_RETAIN}/%.${TRG}.gz: ${OUTPUT_DIR}/best${CEFILTER_RETAIN}/%.${SRC}.gz
	@echo "done!"

%.${SRC}.rawbest${CEFILTER_RETAIN}.gz: %.sorted-raw.gz
	$(eval STARTLINE := $(shell ${GZIP} -dc $< | wc -l | sed "s|$$|*$(CEFILTER_REMOVE)|" | bc | cut -f1 -d.))
	@echo Removing $(CEFILTER_REMOVE) removes $(STARTLINE) lines
	${GZIP} -dc $< | tail -n +$(STARTLINE) | cut -f2,3 | \
	tee >(cut -f1 | gzip -c >$@) |\
	cut -f2 | gzip -c > ${@:.${SRC}.rawbest${CEFILTER_RETAIN}.gz=.${TRG}.rawbest${CEFILTER_RETAIN}.gz}

%.${TRG}.rawbest${CEFILTER_RETAIN}.gz: %.${SRC}.rawbest${CEFILTER_RETAIN}.gz
	@echo "done!"


opusmt-scores-check-latest:
	@if [ -d ${OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${OUTPUT_DIR}/latest/*.scores.gz`; do \
	    B=`echo $$S | sed 's/.${SRC}.scores.gz//'`; \
	    s=`${GZCAT} $$B.${SRC}.gz | wc -l`; \
	    t=`${GZCAT} $$B.${TRG}.gz | wc -l`; \
	    r=`${GZCAT} $$B.${SRC}.raw-scores.gz | wc -l`; \
	    if [ $$r != $$s ] || [ $$r != $$t ]; then \
	      echo "incomplete ($$s, $$t, $$r): $$S"; \
	    else \
	      echo "OK: $$S"; \
	    fi \
	  done \
	fi

opusmt-scores-remove-incomplete-latest:
	@echo "check ${LANGPAIR}"
	@mkdir -p ${OUTPUT_DIR}/incomplete/latest
	@if [ -d ${OUTPUT_DIR}/latest ]; then \
	  for S in `ls ${OUTPUT_DIR}/latest/*.scores.gz`; do \
	    B=`echo $$S | sed 's/.${SRC}.scores.gz//'`; \
	    s=`${GZCAT} $$B.${SRC}.gz | wc -l`; \
	    t=`${GZCAT} $$B.${TRG}.gz | wc -l`; \
	    r=`${GZCAT} $$B.${SRC}.raw-scores.gz | wc -l`; \
	    if [ $$r != $$s ] || [ $$r != $$t ]; then \
	      echo "incomplete - remove ($$s, $$t, $$r): $$S"; \
	      mv $$B.${SRC}.raw-scores.gz ${OUTPUT_DIR}/incomplete/latest; \
	      mv $$B.${SRC}.scores.gz ${OUTPUT_DIR}/incomplete/latest; \
	    fi \
	  done \
	fi
