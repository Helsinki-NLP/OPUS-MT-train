# -*-makefile-*-


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
