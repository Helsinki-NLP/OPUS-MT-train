

2LETTER_DIRS  = ${wildcard ??-??}
2LETTER_FILES = ${sort ${wildcard ??-??/*.??.gz}}

TXT = $(patsubst %.sgm,%,${wildcard *.sgm})

all: ${TXT}



## TICO-19 translation benchmark
## from https://tico-19.github.io/index.html

TICO19_TEST = ${patsubst tico19-testset/test/test.%.tsv,%/tico19-test.en.gz,${wildcard tico19-testset/test/*.tsv}}

tico19-testset:
	wget https://tico-19.github.io/data/tico19-testset.zip
	unzip tico19-testset.zip
	rm -f tico19-testset.zip
	rm -fr __MACOSX
	${MAKE} tico19-testdata

.PHONY: tico19-testdata
tico19-testdata: ${TICO19_TEST}

${TICO19_TEST}: %/tico19-test.en.gz: tico19-testset/test/test.%.tsv
	mkdir -p ${dir $@}
	cut -f3 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' | gzip -c > $@
	cut -f4 $< | tail -n +2 | sed 's/^ *//;s/ *$$//' | gzip -c > ${@:en.gz=${patsubst en-%/,%,$(dir $@)}}.gz


TICODATADIRS = $(sort $(subst /,,${dir ${wildcard */tico19-test.*}}))
crosslink-tico:
	-for d in ${TICODATADIRS}; do \
	  s=`echo "$$d" | cut -f1 -d'-'`; \
	  t=`echo "$$d" | cut -f2 -d'-'`; \
	  mkdir -p $$t-$$s; \
	  cd $$t-$$s; \
	  ln -s ../$$d/tico19* .; \
	  cd ..; \
	done





list-files:
	@echo "${2LETTER_FILES}" | tr ' ' "\n"

missing-files:
	for f in ${2LETTER_FILES}; do \
	  d=`dirname $$f`; \
	  b=`basename $$f`; \
	  s=`echo "$$d" | cut -f1 -d '-'`; \
	  t=`echo "$$d" | cut -f2 -d '-'`; \
	  S=`echo $$b | sed "s/.\(..\).gz/.$$s.gz/"`; \
	  T=`echo $$b | sed "s/.\(..\).gz/.$$t.gz/"`; \
	  if [ ! -e $$d/$$S ]; then \
	    echo "not found: $$d/$$S"; \
	    if [ -e $$t-$$s/$$S ]; then \
	      echo "but found: $$t-$$s/$$S ... copying"; \
	      cp $$t-$$s/$$S $$d/$$S; \
	    fi \
	  fi; \
	  if [ ! -e $$d/$$T ]; then \
	    echo "not found: $$d/$$T"; \
	    if [ -e $$t-$$s/$$T ]; then \
	      echo "but found: $$t-$$s/$$T ... copying"; \
	      cp $$t-$$s/$$T $$d/$$T; \
	    fi \
	  fi; \
	done



## link iso639-1 codes to iso-639-3 codes (using macro-languages)
## this is very slow but only needs to be done once ....
iso-codes:
	for f in ${2LETTER_FILES}; do \
	  l=`echo $$f | sed 's/^.*\.\(..\).gz$$/\1/'`; \
	  L=`iso639 -m -n $$l`; \
	  F=`echo $$f | sed "s/.\(..\).gz$$/.$$L.gz/"`; \
	  if [ ! -e $$F ]; then \
	    echo "make $$F"; \
	    d=`dirname $$f`; \
	    b=`basename $$f`; \
	    B=`basename $$F`; \
	    cd $$d;ln -s $$b $$B;cd ..; \
	  fi \
	done

iso-code-dirs:
	for d in ${2LETTER_DIRS}; do \
	  l=`iso639 -p -m -n $$d`; \
	  if [ ! -e $$l ]; then \
	    echo "make $$l"; \
	    ln -s $$d $$l; \
	  fi \
	done


${TXT}: %: %.sgm
	grep '</seg>' $< |\
	sed 's/<[^>]*>//g' |\
	sed 's/^ *//' |\
	sed 's/ *$$//' |\
	sed 's/  */ /g' |\
	sed	-e 's/&quot;/"/g' \
		-e 's/&gt;/>/g' \
		-e 's/&lt;/</g' \
		-e 's/&amp;/&/g' \
		-e "s/&apos;/'/g" > $@


fix:
	for s in ${wildcard *-src*}; do \
	  mv $$s `echo $$s | sed 's/-src//'`; \
	done
	for s in ${wildcard *-ref*}; do \
	  mv $$s `echo $$s | sed 's/-ref//'`; \
	done


