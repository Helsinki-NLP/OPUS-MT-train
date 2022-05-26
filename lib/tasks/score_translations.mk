# -*-makefile-*-
#
#
# score translations by applying a reverse translation models
# on the translations and the given input sentences
#
# --> used as a CE-filter to remove some noise
#
# OPUSMT_OUTPUT_DIR ....... contains all bitext to be filtered (e.g. FT_OUTPUT_DIR/latest)
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
  REV_SRC_PREPROCESS_ARGS = ${TRG} ${SRC} ${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME}/source.spm
  REV_TRG_PREPROCESS_ARGS = ${SRC} ${TRG} ${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME}/target.spm noflags
else
  REV_SRC_PREPROCESS_ARGS = ${TRG} ${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME}/source.spm
  REV_TRG_PREPROCESS_ARGS = ${SRC} ${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME}/target.spm
endif


#########################################################################
## score translations with reverse translation model
## normalize scores (see https://github.com/browsermt/students)
#########################################################################

SCOREFILES    = $(patsubst %.${SRC}.gz,%.${SRC}.scores.gz,$(wildcard ${OPUSMT_OUTPUT_DIR}/*.${SRC}.gz))
RAWSCOREFILES = $(patsubst %.${SRC}.gz,%.${SRC}.raw-scores.gz,$(wildcard ${OPUSMT_OUTPUT_DIR}/*.${SRC}.gz))

.PHONY: score-translation score-translations
.PHONY: sort-scored-translations sort-raw-scored-translations
score-translation: ${BITEXT_SRC:.gz=.scores.gz}
score-translations: ${SCOREFILES}
sort-scored-translations: ${OPUSMT_OUTPUT_DIR}/bitext.sorted.gz
sort-raw-scored-translations: ${OPUSMT_OUTPUT_DIR}/bitext.sorted-raw.gz

.PHONY: print-score-file
print-score-file:
	echo ${BITEXT_SRC:.gz=.scores.gz}

${OPUSMT_OUTPUT_DIR}/%.${SRC}.scores.gz: ${OPUSMT_OUTPUT_DIR}/%.${SRC}.gz
	${MAKE} SRC=${TRG} TRG=${SRC} opusmt-model
	${GZCAT} ${<:.${SRC}.gz=.${TRG}.gz} |\
	${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME}/preprocess.sh ${REV_SRC_PREPROCESS_ARGS} | \
	${GZIP} -c > $@.src.gz
	${GZCAT} $< |\
	${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME}/preprocess.sh ${REV_TRG_PREPROCESS_ARGS} | \
	${GZIP} -c > $@.trg.gz
	${LOAD_ENV} && \
	cd ${OPUSMT_OUTPUT_DIR}/${REV_MODELNAME} && \
	${MARIAN_SCORER} \
		-m `grep -A1 models decoder.yml | tail -1 | sed 's/ *- //'` \
		-v `grep -A2 vocabs decoder.yml | tail -2 | sed 's/ *- //' | tr "\n" ' '` \
		-t ../$(notdir $@).src.gz ../$(notdir $@).trg.gz \
		${MARIAN_SCORER_FLAGS} |\
	${GZIP} -c > ../$(notdir $(@:.scores.gz=.raw-scores.gz))
	paste <(gzip -dc $(@:.scores.gz=.raw-scores.gz)) <(gzip -dc $@.trg.gz) | \
	python3 ${SCRIPTDIR}/normalize-scores.py | cut -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz


${OPUSMT_OUTPUT_DIR}/bitext.sorted.gz: ${SCOREFILES}
	${GZCAT} ${OPUSMT_OUTPUT_DIR}/*.${SRC}.scores.gz | ${GZIP} -c > $@.scores.gz
	${GZCAT} ${OPUSMT_OUTPUT_DIR}/*.${SRC}.gz | ${GZIP} -c > $@.src.gz
	${GZCAT} ${OPUSMT_OUTPUT_DIR}/*.${TRG}.gz | ${GZIP} -c > $@.trg.gz
	paste <(gzip -cd $@.scores.gz) <(gzip -cd $@.src.gz) <(gzip -cd $@.trg.gz) |\
	LC_ALL=C sort -n -k1,1 -S 10G | uniq -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz $@.scores.gz


${OPUSMT_OUTPUT_DIR}/bitext.sorted-raw.gz: ${RAWSCOREFILES}
	${GZCAT} ${OPUSMT_OUTPUT_DIR}/*.${SRC}.raw-scores.gz | ${GZIP} -c > $@.raw-scores.gz
	${GZCAT} ${OPUSMT_OUTPUT_DIR}/*.${SRC}.gz | ${GZIP} -c > $@.src.gz
	${GZCAT} ${OPUSMT_OUTPUT_DIR}/*.${TRG}.gz | ${GZIP} -c > $@.trg.gz
	paste <(gzip -cd $@.raw-scores.gz) <(gzip -cd $@.src.gz) <(gzip -cd $@.trg.gz) |\
	LC_ALL=C sort -n -k1,1 -S 10G | uniq -f1 | ${GZIP} -c > $@
	rm -f $@.src.gz $@.trg.gz $@.raw-scores.gz


#########################################################################
## extract the best translations from the ranked list
## CEFILTER_REMOVE controls how much will be removed (proportionally)
#########################################################################

.PHONY: extract-best-translations extract-rawbest-translations
extract-best-translations: ${OPUSMT_OUTPUT_DIR}/best${CEFILTER_RETAIN}/bitext.${SRC}.gz
extract-rawbest-translations: ${OPUSMT_OUTPUT_DIR}/rawbest${CEFILTER_RETAIN}/bitext.${SRC}.gz

${OPUSMT_OUTPUT_DIR}/best${CEFILTER_RETAIN}/%.${SRC}.gz: ${OPUSMT_OUTPUT_DIR}/%.sorted.gz
	mkdir -p $(dir $@)
	$(eval STARTLINE := $(shell ${GZIP} -dc $< | wc -l | sed "s|$$|*$(CEFILTER_REMOVE)|" | bc | cut -f1 -d.))
	@echo Removing $(CEFILTER_REMOVE) removes $(STARTLINE) lines
	${GZIP} -dc $< | tail -n +$(STARTLINE) | cut -f2,3 | \
	tee >(cut -f1 | gzip -c >$@) |\
	cut -f2 | gzip -c > ${@:.${SRC}.gz=.${TRG}.gz}

${OPUSMT_OUTPUT_DIR}/best${CEFILTER_RETAIN}/%.${TRG}.gz: ${OPUSMT_OUTPUT_DIR}/best${CEFILTER_RETAIN}/%.${SRC}.gz
	@echo "done!"

%.${SRC}.rawbest${CEFILTER_RETAIN}.gz: %.sorted-raw.gz
	$(eval STARTLINE := $(shell ${GZIP} -dc $< | wc -l | sed "s|$$|*$(CEFILTER_REMOVE)|" | bc | cut -f1 -d.))
	@echo Removing $(CEFILTER_REMOVE) removes $(STARTLINE) lines
	${GZIP} -dc $< | tail -n +$(STARTLINE) | cut -f2,3 | \
	tee >(cut -f1 | gzip -c >$@) |\
	cut -f2 | gzip -c > ${@:.${SRC}.rawbest${CEFILTER_RETAIN}.gz=.${TRG}.rawbest${CEFILTER_RETAIN}.gz}

%.${TRG}.rawbest${CEFILTER_RETAIN}.gz: %.${SRC}.rawbest${CEFILTER_RETAIN}.gz
	@echo "done!"


