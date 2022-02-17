


## fix sub-directories for newstests:
## remove langid extension that causes duplicates
## --> still need to sort leaderboards again!

NEWS = ${wildcard *-*/news*-[a-z][a-z][a-z][a-z]}

move:
	for o in ${NEWS}; do \
	  n=`echo $$o | sed 's/\-[a-z][a-z][a-z][a-z]$$//'`; \
	  b=`basename $$o`; \
	  mkdir -p $$n; \
	  mv $$o/bleu-scores.txt $$n/bleu-scores.$$b.unsorted.txt; \
	  mv $$o/chrf-scores.txt $$n/chrf-scores.$$b.unsorted.txt; \
	  rmdir $$o; \
	done
