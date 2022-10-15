

MODELS = ${shell find . -type f -name '*.zip'}


## fix decoder.yml to match the typical setup 
## and the names of the model and vocab in the zip file

fix-config:
	for m in ${MODELS}; do \
	  f=`unzip -l $$m | grep -oi '[^ ]*npz'`; \
	  v=`unzip -l $$m | grep -oi '[^ ]*vocab.yml'`; \
	  echo 'models:' > decoder.yml; \
	  echo "  - $$f" >> decoder.yml; \
	  echo 'vocabs:' >> decoder.yml; \
	  echo "  - $$v" >> decoder.yml; \
	  echo "  - $$v" >> decoder.yml; \
	  echo 'beam-size: 6' >> decoder.yml; \
	  echo 'normalize: 1' >> decoder.yml; \
	  echo 'word-penalty: 0' >> decoder.yml; \
	  echo 'mini-batch: 1' >> decoder.yml; \
	  echo 'maxi-batch: 1' >> decoder.yml; \
	  echo 'maxi-batch-sort: src' >> decoder.yml; \
	  echo 'relative-paths: true' >> decoder.yml; \
	  zip $$m decoder.yml; \
	done
	rm -f decoder.yml




SCOREFILES := ${wildcard */*.scores.txt}
BLEUSCOREFILES := ${SCOREFILES:.scores.txt=.bleu-scores.txt}
CHRFSCOREFILES := ${SCOREFILES:.scores.txt=.chrf-scores.txt}

create-score-files: ${BLEUSCOREFILES} ${CHRFSCOREFILES}

%.bleu-scores.txt: %.scores.txt
	cut -f1,2,4 $< | \
	sed 's/\(news.*[0-9][0-9][0-9][0-9]\)\-[a-z][a-z][a-z][a-z]	/\1	/' |\
	sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	rev | uniq -f1 | rev > $@


%.chrf-scores.txt: %.scores.txt
	cut -f1,2,3 $< |\
	sed 's/\(news.*[0-9][0-9][0-9][0-9]\)\-[a-z][a-z][a-z][a-z]	/\1	/' |\
	sed -e 's/\(news.*2021\)\.[a-z][a-z]\-[a-z][a-z]	/\1	/' |\
	rev | uniq -f1 | rev > $@

