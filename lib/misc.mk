
#------------------------------------------------------------------------
# some helper functions
#------------------------------------------------------------------------

ALL_DATA_SETS = ${patsubst %.${SRCEXT}.gz,%,${CLEAN_TRAIN_SRC}}

check-bitext-length:
	for d in ${ALL_DATA_SETS}; do \
	  if [ `${ZCAT} $$d.${SRCEXT}.gz | wc -l` != `${ZCAT} $$d.${TRGEXT}.gz | wc -l` ]; then \
	    echo "not the same number of lines in $$d"; \
	  fi \
	done


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


## TODO: this does not seem to work as the config does not match
## (optmiser cannot contintue to run ....)
## move model files to a new name
## (useful if using as starting point for another modeltyp
##  for example, continue training without guided alignment)

ifndef OLDMODELTYPE
  OLDMODELTYPE=transformer-align
endif

ifndef NEWMODELTYPE
  NEWMODELTYPE=transformer
endif

OLDMODEL_BASE  = ${WORKDIR}/${MODEL}.${OLDMODELTYPE}.model${NR}
NEWMODEL_BASE  = ${WORKDIR}/${MODEL}.${NEWMODELTYPE}.model${NR}

move-model:
ifeq (${wildcard ${NEWMODEL_BASE}.npz},)
	cp ${OLDMODEL_BASE}.npz ${NEWMODEL_BASE}.npz
	cp ${OLDMODEL_BASE}.npz.best-perplexity.npz ${NEWMODEL_BASE}.npz.best-perplexity.npz
	cp ${OLDMODEL_BASE}.npz.optimizer.npz ${NEWMODEL_BASE}.npz.optimizer.npz
	cp ${OLDMODEL_BASE}.npz.orig.npz ${NEWMODEL_BASE}.npz.orig.npz
	cp ${OLDMODEL_BASE}.npz.progress.yml ${NEWMODEL_BASE}.npz.progress.yml
	cp ${OLDMODEL_BASE}.npz.yml ${NEWMODEL_BASE}.npz.yml
	sed 's/${OLDMODELTYPE}/${NEWMODELTYPE}/' \
		< ${OLDMODEL_BASE}.npz.decoder.yml \
		> ${NEWMODEL_BASE}.npz.decoder.yml
	sed 's/${OLDMODELTYPE}/${NEWMODELTYPE}/' \
		< ${OLDMODEL_BASE}.npz.best-perplexity.npz.decoder.yml \
		> ${NEWMODEL_BASE}.npz.best-perplexity.npz.decoder.yml
else
	@echo "new model ${NEWMODEL_BASE}.npz exists already!"
endif





## make symbolic links to spm-models
## (previously we had data-specific models but now we want to re-use existing ones)

fix-spm-models:
	cd work-spm; \
	for l in ${ALL_LANG_PAIRS}; do \
	  cd $$l/train; \
	  if [ ! -e opus.src.spm32k-model ]; then \
	    ln -s *.src.spm32k-model opus.src.spm32k-model; \
	    ln -s *.trg.spm32k-model opus.trg.spm32k-model; \
	  fi; \
	  cd ../..; \
	done
