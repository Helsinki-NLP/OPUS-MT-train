
#------------------------------------------------------------------------
# some helper functions
#------------------------------------------------------------------------


## check whether a model is converged or not
finished:
	@if grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKDIR}/${MODEL_VALIDLOG}; then\
	   echo "${WORKDIR}/${MODEL_BASENAME} finished"; \
	else \
	   echo "${WORKDIR}/${MODEL_BASENAME} unfinished"; \
	fi

## remove job files if no trained file exists
delete-broken-submit:
	for l in ${ALL_LANG_PAIRS}; do \
	  if [ -e ${WORKHOME}/$$l/train.submit ]; then \
	    if  [ ! `find ${WORKHOME}/$$l -name '*.${PRE_SRC}-${PRE_TRG}.*.best-perplexity.npz' | wc -l` -gt 0 ]; then \
	      echo "rm -f ${WORKHOME}/$$l/train.submit"; \
	      rm -f ${WORKHOME}/$$l/train.submit; \
	    fi \
	  fi \
	done




## fix a problem with missing links from reverse-data
## --> this caused that models with bt data used less data
## --> need to restart those!

fix-missing-val:
	for f in `find work/ -type l -name '*.shuffled.gz' | grep -v old | sed 's/.src.shuffled.gz//'`; do \
	  if [ ! -e $$f.src.notused.gz ]; then \
	    echo "missing $$f.src.notused.gz!"; \
	    s=`echo $$f | cut -f2 -d'/' | cut -f1 -d'-'`; \
	    t=`echo $$f | cut -f2 -d'/' | cut -f2 -d'-'`; \
	    d=`echo $$f | cut -f4 -d'/'`; \
	    if [ -e work/$$t-$$s/val/$$d.trg.notused.gz ]; then \
	      echo "linking ${PWD}/work/$$t-$$s/val/$$d.trg.notused.gz"; \
	      ln -s ${PWD}/work/$$t-$$s/val/$$d.trg.notused.gz $$f.src.notused.gz; \
	      ln -s ${PWD}/work/$$t-$$s/val/$$d.src.notused.gz $$f.trg.notused.gz; \
	      if [ `ls work/$$s-$$t/opus*+bt*valid1.log 2>/dev/null | wc -l` -gt 0 ]; then \
		echo "opus+bt model exists! move it away!"; \
		mkdir work/$$s-$$t/old-bt-model; \
		mv work/$$s-$$t/*+bt* work/$$s-$$t/old-bt-model/; \
	      fi; \
	    fi; \
	  fi \
	done
