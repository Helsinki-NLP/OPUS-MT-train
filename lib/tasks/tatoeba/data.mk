# -*-makefile-*-


# ${TATOEBA_SRCLABELFILE} ${TATOEBA_TRGLABELFILE}

.PHONY: tatoeba-langlabel-files langlabel-files
tatoeba-langlabel-files langlabel-files: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src \
					${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg \
					${WORKHOME}/${LANGPAIRSTR}/${DATASET}-languages.src \
					${WORKHOME}/${LANGPAIRSTR}/${DATASET}-languages.trg

${WORKHOME}/${LANGPAIRSTR}/${DATASET}-languages.%: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.%
	mkdir -p ${dir $@}
	cat $< | tr ' ' "\n" | cut -f1 -d'_' | cut -f1 -d'-' | \
	sed 's/ *$$//;s/^ *//' | tr "\n" ' '  > $@



## don't delete intermediate label files
.PRECIOUS: 	${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
		${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz


## fetch data for all language combinations
## TODO: should we check whether we are supposed to skip some language pairs?

.PHONY: fetch-tatoeba-datasets fetch-datasets
fetch-datasets fetch-tatoeba-datasets:
	-for s in ${sort ${SRCLANGS}}; do \
	  for t in ${sort ${TRGLANGS}}; do \
	    if [ `echo "$$s-$$t $$t-$$s" | egrep '${SKIP_LANGPAIRS}' | wc -l` -gt 0 ]; then \
	        echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	    else \
	      if [ "$$s" \< "$$t" ]; then \
	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t \
		  ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$s.gz; \
	      else \
	        if [ "${SKIP_SAME_LANG}" == "1" ] && [ "$$s" == "$$t" ]; then \
	          echo "!!!!!!!!!!! skip language pair $$s-$$t !!!!!!!!!!!!!!!!"; \
	        else \
	          ${MAKE} SRCLANGS=$$t TRGLANGS=$$s \
		    ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$t.gz; \
	        fi \
	      fi \
	    fi \
	  done \
	done


## collect all language labels in all language pairs
## (each language pair may include several language variants)
## --> this is necessary to set the languages that are present in a model

${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src:
	${MAKE} fetch-tatoeba-datasets
	mkdir -p ${dir $@}
	for s in ${SRCLANGS}; do \
	    for t in ${TRGLANGS}; do \
	      if [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      elif [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$s.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$s.labels >> $@.src; \
		echo -n ' ' >> $@.src; \
	      fi; \
	      if [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$s-$$t.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      elif [ -e ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$t.labels ]; then \
		cat ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.$$t-$$s.clean.$$t.labels >> $@.trg; \
		echo -n ' ' >> $@.trg; \
	      fi; \
	    done \
	done
	if [ -e $@.src ]; then \
	  cat $@.src | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $@; \
	  rm $@.src; \
	else \
	  echo "${SRCLANGS}" > $@; \
	fi
	if [ -e $@.trg ]; then \
	  cat $@.trg | tr ' ' "\n" | sort -u | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $(@:.src=.trg); \
	  rm $@.trg; \
	else \
	  echo "${TRGLANGS}" > $(@:.src=.trg); \
	fi


${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.trg: ${WORKHOME}/${LANGPAIRSTR}/${DATASET}-langlabels.src
	if [ ! -e $@ ]; then rm $<; ${MAKE} $<; fi
	echo "done"



###############################################################################
## generate data files
###############################################################################


## don't delete those files
.SECONDARY: ${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${TRGEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${SRCEXT}.gz \
	${TATOEBA_DATA}/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${TRGEXT}.gz

##-------------------------------------------------------------
## take care of languages IDs
## --> simplify some IDs from training data
## --> decide which ones to keep that do not exist in test data
##-------------------------------------------------------------

## langids that we want to keep from the training data even if they do not exist in the Tatoeba test sets
## (skip most lang-IDs because they mostly come from erroneous writing scripts --> errors in the data)
## the list is based on ${TATOEBA_LANGIDS_TRAINONLY}
## special codes: see https://en.wikipedia.org/wiki/ISO_15924

# TRAIN_ONLY_LANGIDS   = ${shell cat ${TATOEBA_LANGIDS_TRAINONLY} | grep -v '^...$$' | tr "\n" ' '}
TRAIN_ONLY_LANGIDS   = ${shell cat ${TATOEBA_LANGIDS_TRAINONLY} | tr "\n" ' '}
KEEP_LANGIDS         = bos_Cyrl cmn cnr cnr_Latn csb diq dnj dty fas fqs ful fur gcf got gug hbs hbs_Cyrl hmn \
			jak_Latn kam kmr kmr_Latn kom kur_Cyrl kuv_Arab kuv_Latn lld mol mrj msa_Latn mya_Cakm nep ngu \
			nor nor_Latn oss_Latn pan plt pnb_Guru pob prs qug quw quy quz qvi rmn rmy ruk san swa swc \
			syr syr_Syrc tgk_Latn thy tlh tmh toi tuk_Cyrl urd_Deva xal_Latn yid_Latn zho zlm
SKIP_LANGIDS         = ${filter-out ${KEEP_LANGIDS},${TRAIN_ONLY_LANGIDS}} \
			ang ara_Latn arq_Latn apc_Latn bul_Latn ell_Latn eng_Tibt \
			eng_Zinh eng_.... heb_Latn hun_Zinh nob_Hebr rus_Latn \
			..._Qa[ab][a-x] ..._Zinh ..._Zmth ..._Zsym ..._Zxxx ..._Zyyy ..._Zzzz
SKIP_LANGIDS_PATTERN = ^\(${subst ${SPACE},\|,${SKIP_LANGIDS}}\)$$

## modify language IDs in training data to adjust them to test sets
## --> fix codes for chinese and take away script information (not reliable!)
##     except the distinction between traditional and simplified
##     assume that all zho is cmn
## --> take away regional codes
## --> take away script extension that may come with some codes
FIXLANGIDS = 	| sed 's/zho\(.*\)_HK/yue\1/g;s/zho\(.*\)_CN/cmn\1/g;s/zho\(.*\)_TW/cmn\1/g;s/zho/cmn/g;' \
		| sed 's/\_[A-Z][A-Z]//g' \
		| sed 's/\-[a-z]*//g' \
		| sed 's/\_Brai//g' \
		| sed 's/bul_Latn/bul/g' \
		| sed 's/jpn_[A-Za-z]*/jpn/g' \
		| sed 's/kor_[A-Za-z]*/kor/g' \
		| sed 's/nor_Latn/nor/g' \
		| sed 's/non_Latn/non/g' \
		| sed 's/nor/nob/g' \
		| sed 's/syr_Syrc/syr/g' \
		| sed 's/yid_Latn/yid/g' \
		| perl -pe 'if (/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/){if ($$2 ne "Hans" && $$2 ne "Hant"){s/(cjy|cmn|gan|lzh|nan|wuu|yue|zho)_([A-Za-z]{4})/$$1/} }'

#		| sed 's/ara_Latn/ara/;s/arq_Latn/arq/;' \



print-skiplangids:
	@echo ${SKIP_LANGIDS_PATTERN}

tatoeba/langids-train-only-${TATOEBA_VERSION}.txt:
	mkdir -p ${dir $@}
	wget -O $@ ${TATOEBA_RAWGIT_MASTER}/data/release/${TATOEBA_VERSION}/langids-train-only.txt

## monolingual data from Tatoeba challenge (wiki data)

${TATOEBA_MONO}/%.labels:
	mkdir -p $@.d
# the old URL without versioning:
	-wget -q -O $@.d/mono.tar ${TATOEBA_DATAURL}/$(patsubst %.labels,%,$(notdir $@)).tar
	-tar -C $@.d -xf $@.d/mono.tar
	rm -f $@.d/mono.tar
# the new URLs with versioning:
	-wget -q -O $@.d/mono.tar ${TATOEBA_MONO_URL}/$(patsubst %.labels,%,$(notdir $@)).tar
	-tar -C $@.d -xf $@.d/mono.tar
	rm -f $@.d/mono.tar
	find $@.d -name '*.id.gz' | xargs ${ZCAT} | sort -u | tr "\n" ' ' | sed 's/ $$//' > $@
	for c in `find $@.d -name '*.id.gz' | sed 's/\.id\.gz//'`; do \
	  echo "extract all data from $$c.txt.gz"; \
	  ${GZIP} -d $$c.id.gz; \
	  ${GZIP} -d $$c.txt.gz; \
	  b=`basename $$c`; \
	  for l in `sort -u $$c.id`; do \
	    echo "extract $$l from $$b"; \
	    mkdir -p ${TATOEBA_MONO}/$$l; \
	    paste $$c.id $$c.txt | grep "^$$l	" | cut -f2 | grep . |\
	    ${SORT} -u | ${SHUFFLE} | split -l 1000000 - ${TATOEBA_MONO}/$$l/$$b.$$l.; \
	    ${GZIP} ${TATOEBA_MONO}/$$l/$$b.$$l.*; \
	  done; \
	  rm -f $$c.id $$c.txt; \
	done
	rm -fr $@.d


##-------------------------------------------------------------------------------------------
## convert Tatoeba Challenge data into the format we need
## - move the data into the right location with the suitable name
## - create devset if not given (part of training data)
## - divide into individual language pairs 
##   (if there is more than one language pair in the collection)
## 
## TODO: should we do some filtering like bitext-match, OPUS-filter ...
##-------------------------------------------------------------------------------------------

## relative directory within the data distributions of Tatoeba MT data files
TATOEBADATA = data/release/${TATOEBA_VERSION}/${LANGPAIR}

## fetch and convert the data and check whether we should extract
## sub-language pairs from the collection
%/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz:
	${MAKE} $@.d/source.labels $@.d/target.labels
	@if [ `cat $@.d/source.labels $@.d/target.labels | wc -w` -gt 1 ]; then \
	  echo ".... found sublanguages in the data"; \
	  b="$@.d/${TATOEBADATA}"; \
	  for s in `cat $@.d/source.labels`; do \
	    for t in `cat $@.d/target.labels`; do \
	      if [ "$$s" \< "$$t" ]; then \
	        echo ".... extract $$s-$$t data"; \
	        for d in dev test train; do \
	          paste <(gzip -cd $$b/$$d.id.gz) <(gzip -cd $$b/$$d.src.gz) <(gzip -cd $$b/$$d.trg.gz) | \
			grep -P "^$$s\t$$t\t" > $@.d/$$d; \
	          if [ -s $@.d/$$d ]; then \
	            cut -f1,2 $@.d/$$d | ${GZIP} -c > ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.$$s-$$t.clean.id.gz; \
	            cut -f3 $@.d/$$d | ${GZIP} -c > ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.$$s-$$t.clean.$$s.gz; \
	            cut -f4 $@.d/$$d | ${GZIP} -c > ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.$$s-$$t.clean.$$t.gz; \
	          fi \
	        done; \
	        if [ -e ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.id.gz ]; then \
	          paste <(gzip -cd $$b/$$d.id.gz) <(gzip -cd $$b/$$d.domain.gz) | grep -P "^$$s\t$$t\t" | cut -f3 | \
	          ${GZIP} -c > ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.domain.gz; \
	          ${ZCAT} ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.domain.gz |\
	          sort -u > ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.domains; \
	          echo "$$s" >> ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.$$s.labels; \
	          echo "$$t" >> ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.$$s-$$t.clean.$$t.labels; \
	        fi \
	      fi \
	    done \
	  done \
	fi
	@if [ ! -e ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SRCEXT}.gz ]; then \
	  echo ".... move data files"; \
	  b="$@.d/${TATOEBADATA}"; \
	  for d in dev test train; do \
	    mv $$b/$$d.src.gz ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTSRCEXT}.gz; \
	    mv $$b/$$d.trg.gz ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTTRGEXT}.gz; \
	    mv $$b/$$d.id.gz ${dir $@}Tatoeba-$$d-${TATOEBA_VERSION}.${LANGPAIR}.clean.id.gz; \
	  done; \
	  ${ZCAT} $$b/train.domain.gz | sort -u | tr "\n" ' ' | sed 's/ *$$//' \
		> ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.domains; \
	  mv $$b/train.domain.gz ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.domain.gz; \
	  mv $@.d/source.labels ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTSRCEXT}.labels; \
	  mv $@.d/target.labels ${dir $@}Tatoeba-train-${TATOEBA_VERSION}.${LANGPAIR}.clean.${SORTTRGEXT}.labels; \
	fi
	@echo ".... cleanup of temporary files"
	@rm -fr $@.d


## fetch data
## don't break if this fails!
%.gz.d/data.fetched:
	@echo ".... fetch data (${LANGPAIR}.tar)"
	@mkdir -p ${dir $@}
	-wget -q -O ${dir $@}train.tar ${TATOEBA_TRAIN_URL}/${LANGPAIR}.tar
	@if [ -e ${dir $@}train.tar ]; then \
	  tar -C ${dir $@} -xf ${dir $@}train.tar; \
	  rm -f ${dir $@}train.tar; \
	fi
	@touch $@


## make dev data (extract additional examples from the training data if neccessary)
%.gz.d/devdata.created: %.gz.d/data.fetched
	@if [ -e ${dir $@}${TATOEBADATA}/dev.src ]; then \
	  if [ `cat ${dir $@}${TATOEBADATA}/dev.src | wc -l` -gt 50 ]; then \
	    touch $@; \
	  else \
	    mv ${dir $@}${TATOEBADATA}/dev.src $@.dev.src; \
	    mv ${dir $@}${TATOEBADATA}/dev.trg $@.dev.trg; \
	    mv ${dir $@}${TATOEBADATA}/dev.id  $@.dev.id; \
	  fi \
	fi
	@if [ ! -e $@ ]; then \
	  if [ -e ${dir $@}${TATOEBADATA}/train.src.gz ]; then \
	    echo "........ too little devdata available - get top 1000 from training data!"; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.src.gz | head -1000                >> $@.dev.src; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.trg.gz | head -1000                >> $@.dev.trg; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz  | head -1000 | cut -f2,3    >> $@.dev.id; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.src.gz | tail -n +1001 | ${GZIP} -f > $@.src.gz; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.trg.gz | tail -n +1001 | ${GZIP} -f > $@.trg.gz; \
	    ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz  | tail -n +1001 | ${GZIP} -f > $@.id.gz; \
	    mv $@.src.gz ${dir $@}${TATOEBADATA}/train.src.gz; \
	    mv $@.trg.gz ${dir $@}${TATOEBADATA}/train.trg.gz; \
	    mv $@.id.gz  ${dir $@}${TATOEBADATA}/train.id.gz; \
	  fi; \
	  mv $@.dev.src ${dir $@}${TATOEBADATA}/dev.src; \
	  mv $@.dev.trg ${dir $@}${TATOEBADATA}/dev.trg; \
	  mv $@.dev.id  ${dir $@}${TATOEBADATA}/dev.id; \
	  touch $@; \
	fi

## fix language IDs and make sure that dev/test/train exist
%.gz.d/data.fixed: %.gz.d/devdata.created
	@echo ".... fix language codes"
	@if [ -e ${dir $@}${TATOEBADATA}/train.id.gz ]; then \
	  ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz | cut -f2,3 $(FIXLANGIDS) | ${GZIP} -c > ${dir $@}train.id.gz; \
	  ${GZCAT} ${dir $@}${TATOEBADATA}/train.id.gz | cut -f1 | ${GZIP} -c > ${dir $@}train.domain.gz; \
	  mv ${dir $@}train.id.gz ${dir $@}train.domain.gz ${dir $@}${TATOEBADATA}/; \
	else \
	  touch ${dir $@}${TATOEBADATA}/train.src ${dir $@}${TATOEBADATA}/train.trg; \
	  touch ${dir $@}${TATOEBADATA}/train.id ${dir $@}${TATOEBADATA}/train.domain; \
	  ${GZIP} -cd ${dir $@}${TATOEBADATA}/train.*; \
	fi
	@touch ${dir $@}${TATOEBADATA}/test.id ${dir $@}${TATOEBADATA}/test.src ${dir $@}${TATOEBADATA}/test.trg
	@touch ${dir $@}${TATOEBADATA}/dev.id ${dir $@}${TATOEBADATA}/dev.src ${dir $@}${TATOEBADATA}/dev.trg
	@cat ${dir $@}${TATOEBADATA}/dev.id  $(FIXLANGIDS) > ${dir $@}dev.id
	@cat ${dir $@}${TATOEBADATA}/test.id $(FIXLANGIDS) > ${dir $@}test.id
	@mv ${dir $@}dev.id ${dir $@}test.id ${dir $@}${TATOEBADATA}/
	@${GZIP} -f ${dir $@}${TATOEBADATA}/dev.* ${dir $@}${TATOEBADATA}/test.*


## get source language labels
%.gz.d/source.labels: %.gz.d/data.fixed
	@${ZCAT} ${dir $@}${TATOEBADATA}/*.id.gz | cut -f1 | sort -u | \
	grep -v '${SKIP_LANGIDS_PATTERN}' | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $@

## get target language labels
%.gz.d/target.labels: %.gz.d/data.fixed
	@${ZCAT} ${dir $@}${TATOEBADATA}/*.id.gz | cut -f2 | sort -u | \
	grep -v '${SKIP_LANGIDS_PATTERN}' | tr "\n" ' ' | sed 's/^ *//;s/ *$$//' > $@


## all the following data sets are created in the target of the
#@ source language training data

%/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz
	@echo "done!"

%/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${SRCEXT}.gz %/${TATOEBA_DEVSET}.${LANGPAIR}.clean.${TRGEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz
	@echo "done!"

%/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${SRCEXT}.gz %/${TATOEBA_TESTSET}.${LANGPAIR}.clean.${TRGEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${TRGEXT}.gz
	@echo "done!"





test-tune-data: 
	make SRCEXT=bre TRGEXT=eng LANGPAIR=bre-eng \
	 ${WORKHOME}-test/data/simple/Tatoeba-OpenSubtitles-train.bre-eng.clean.bre.gz


## TODO: should we split into train/dev/test
##       problem: that would overlap with the previous training data

%/Tatoeba-${TUNE_DOMAIN}-train.${LANGPAIR}.clean.${SRCEXT}.gz: %/${TATOEBA_TRAINSET}.${LANGPAIR}.clean.${SRCEXT}.gz
	paste 	<(gzip -cd ${<:.${SRCEXT}.gz=.domain.gz}) \
		<(gzip -cd $<) \
		<(gzip -cd ${<:.${SRCEXT}.gz=.${TRGEXT}.gz}) | \
	grep '^${TUNE_DOMAIN}	' |\
	tee >(cut -f1 | gzip -c >${@:.${SRCEXT}.gz=.domain.gz}) >(cut -f2 | gzip -c >$@) | \
	cut -f3 | gzip -c > ${@:.${SRCEXT}.gz=.${TRGEXT}.gz}




## make Tatoeba test files available in testset collection
## --> useful for testing various languages when creating multilingual models
testsets/${LANGPAIR}/${TATOEBA_TESTSET}.${LANGPAIR}.%: ${TATOEBA_DATA}/${TATOEBA_TESTSET}.${LANGPAIR}.clean.%
	mkdir -p ${dir $@}
	cp $< $@




## an overly complex recipe to create testsets for individual language pairs
## - extract test sets for all (macro-)language combinations
## - extract potential sub-language pairs from combinations involving macro-languages
## - store those testsets in the multilingual model's test directory
.PHONY: tatoeba-multilingual-testsets
tatoeba-multilingual-testsets: ${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba${TATOEBA_VERSION_NOHYPHEN}-testsets.done

MULTILING_TESTSETS_DONE = ${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba-testsets.done \
		${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba${TATOEBA_VERSION_NOHYPHEN}-testsets.done

${MULTILING_TESTSETS_DONE}:
	@mkdir -p ${WORKHOME}/${LANGPAIRSTR}/test
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	      wget -q -O ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp \
			${TATOEBA_RAWGIT_RELEASE}/data/test/$$s-$$t/test.txt; \
	      if [ -s ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp ]; then \
		cat ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp $(FIXLANGIDS) \
			> ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt; \
		if [ "$$s-$$t" != ${LANGPAIRSTR} ]; then \
	          echo "make ${TATOEBA_TESTSET}.$$s-$$t"; \
		  if [ "${USE_TARGET_LABELS}" == "1" ]; then \
	            cut -f2,3 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt | \
		    sed 's/^\([^ ]*\)	/>>\1<< /' \
		    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		  else \
		    cut -f3 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		  fi; \
	          cut -f4 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		  > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.trg; \
		fi; \
		S=`cut -f1 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		T=`cut -f2 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
		  echo "extracting test sets for individual sub-language pairs!"; \
		  for a in $$S; do \
		    for b in $$T; do \
		      if [ "$$a-$$b" != ${LANGPAIRSTR} ]; then \
		        if [ ! -e ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src ]; then \
	                  echo "make ${TATOEBA_TESTSET}.$$a-$$b"; \
		          if [ "${USE_TARGET_LABELS}" == "1" ]; then \
		            grep "$$a	$$b	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			    cut -f2,3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		          else \
		            grep "$$a	$$b	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			    cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		          fi; \
		          grep "$$a	$$b	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
		          cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			  > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.trg; \
		        fi \
	              fi \
		    done \
		  done \
		fi; \
	      else \
	        wget -q -O ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp \
			${TATOEBA_RAWGIT_RELEASE}/data/test/$$t-$$s/test.txt; \
	        if [ -s ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp ]; then \
		  cat ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp $(FIXLANGIDS) \
			> ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt; \
		  if [ "$$s-$$t" != ${LANGPAIRSTR} ]; then \
	            echo "make ${TATOEBA_TESTSET}.$$s-$$t"; \
		    if [ "${USE_TARGET_LABELS}" == "1" ]; then \
	              cut -f1,4 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt | \
		      sed 's/^\([^ ]*\)	/>>\1<< /' \
		      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		    else \
		      cut -f4 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.src; \
		    fi; \
	            cut -f3 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt \
		    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.trg; \
		  fi; \
		  S=`cut -f2 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		  T=`cut -f1 ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			sort -u | tr "\n" ' ' | sed 's/ *$$//'`; \
		  if [ `echo "$$S $$T" | tr ' ' "\n" | wc -l` -gt 2 ]; then \
		    echo "extracting test sets for individual sub-language pairs!"; \
		    for a in $$S; do \
		      for b in $$T; do \
		        if [ "$$a-$$b" != ${LANGPAIRSTR} ]; then \
		          if [ ! -e ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src ]; then \
	                    echo "make ${TATOEBA_TESTSET}.$$a-$$b"; \
		            if [ "${USE_TARGET_LABELS}" == "1" ]; then \
		              grep "$$b	$$a	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			      cut -f1,4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		            else \
		              grep "$$b	$$a	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
			      cut -f4 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			      > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.src; \
		            fi; \
		            grep "$$b	$$a	" < ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt |\
		            cut -f3 | sed 's/^\([^ ]*\)	/>>\1<< /' \
			    > ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$a-$$b.trg; \
		          fi \
		        fi \
		      done \
		    done \
		  fi; \
		fi \
	      fi; \
	      rm -f ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.tmp; \
	      rm -f ${WORKHOME}/${LANGPAIRSTR}/test/${TATOEBA_TESTSET}.$$s-$$t.txt; \
	  done \
	done
	if [ -d ${dir $@} ]; then \
	  touch $@; \
	fi


## TODO:
## get test sets for sublanguages in sets of macro-languages

${WORKHOME}/${LANGPAIRSTR}/test/Tatoeba-testsets-langpairs.done:
	@for s in ${SRCLANGS}; do \
	  for t in ${TRGLANGS}; do \
	  done \
	done


