# -*-makefile-*-



FIU2XXX = $(wildcard models-tatoeba/fiu-???)
XXX2FIU = $(wildcard models-tatoeba/???-fiu)


fiu2xxx-print-results:
	@for d in ${FIU2XXX}; do \
	  s='fiu';\
	  t=`echo $$d | cut -f3 -d'-'`;\
	  echo '\begin{table}[]'; \
	  echo '\centering'; \
	  echo '\begin{tabular}{|c|cc|}'; \
	  echo '\hline'; \
	  echo "$$s-$$t	& chr-F2 & BLEU \\\\"; \
	  echo '\hline'; \
	  cat $$d/README.md |\
	  tr "\n#" "~\n" | tail -1 | tr '~' "\n" |\
	  grep 'Tatoeba-test' | \
	  sed 's/Tatoeba-test\.//' |\
	  perl -e 'while (<>){@a=split(/\s*\|\s*/);print if ($$a[4]>=100);}' |\
	  cut -f2-4 -d'|' | tr '|' '&' | sed 's/$$/\\\\/'; \
	  echo '\end{tabular}'; \
	  echo -n '\caption{Results from the multilingual translation model between Finno-Ugric languages and '; \
	  iso639 $$t | tr '"' ' '; \
	  echo 'measured on the Tatoeba test set.}'; \
	  echo '\label{tab:my_label}'; \
	  echo '\end{table}'; \
	  echo ""; \
	done


xxx2fiu-print-results:
	@for d in ${XXX2FIU}; do \
	  t='fiu';\
	  s=`echo $$d | cut -f2 -d'/' | cut -f1 -d'-'`;\
	  echo '\begin{table}[]'; \
	  echo '\centering'; \
	  echo '\begin{tabular}{|c|cc|}'; \
	  echo '\hline'; \
	  echo "$$s-$$t	& chr-F2 & BLEU \\\\"; \
	  echo '\hline'; \
	  cat $$d/README.md |\
	  tr "\n#" "~\n" | tail -1 | tr '~' "\n" |\
	  grep 'Tatoeba-test' | \
	  sed 's/Tatoeba-test\.//' |\
	  perl -e 'while (<>){@a=split(/\s*\|\s*/);print if ($$a[4]>=100);}' |\
	  cut -f2-4 -d'|' | tr '|' '&' | sed 's/$$/\\\\/'; \
	  echo '\end{tabular}'; \
	  echo -n '\caption{Results from the multilingual translation model between '; \
	  iso639 $$s | tr '"' ' '; \
	  echo 'and Finno-Ugric languages measured on the Tatoeba test set.}'; \
	  echo '\label{tab:my_label}'; \
	  echo '\end{table}'; \
	  echo ""; \
	done



# FIU_DATASIZE = -1m

train-tatoeba-crossfiu: train-tatoeba-group2fiu train-tatoeba-fiu2group

eval-tatoeba-crossfiu: 	testsets-tatoeba-group2fiu testsets-tatoeba-fiu2group
	${MAKE} eval-tatoeba-group2fiu eval-tatoeba-fiu2group
	${MAKE} multieval-tatoeba-group2fiu multieval-tatoeba-fiu2group
#	${MAKE} evalall-tatoeba-group2fiu evalall-tatoeba-fiu2group

dist-tatoeba-crossfiu: eval-tatoeba-crossfiu
	${MAKE} dist-tatoeba-group2fiu dist-tatoeba-fiu2group

%-tatoeba-group2fiu:
	for s in ${OPUS_LANG_GROUPS}; do \
	    if [ "$$s" != "fiu" ]; then \
		${MAKE} ${TATOEBA_PARAMS} \
			MIN_SRCLANGS=2 MIN_TRGLANGS=2 \
			MAX_SRCLANGS=30 MAX_TRGLANGS=30 \
			MODELTYPE=transformer \
			FIT_DATA_SIZE=1000000 \
		tatoeba-$${s}2fiu-${@:-tatoeba-group2fiu=}${FIU_DATASIZE}; \
	    fi \
	done

#	      if [ -e work-tatoeba/$$s-fiu ]; then \
#	      fi \

%-tatoeba-fiu2group:
	for s in ${OPUS_LANG_GROUPS}; do \
	    if [ "$$s" != "fiu" ]; then \
		${MAKE} ${TATOEBA_PARAMS} \
			MIN_SRCLANGS=2 MIN_TRGLANGS=2 \
			MAX_SRCLANGS=30 MAX_TRGLANGS=30 \
			MODELTYPE=transformer \
			FIT_DATA_SIZE=1000000 \
		tatoeba-fiu2$${s}-${@:-tatoeba-fiu2group=}${FIU_DATASIZE}; \
	    fi \
	done

#	      if [ -e work-tatoeba/fiu-$$s ]; then \
#	      fi \
