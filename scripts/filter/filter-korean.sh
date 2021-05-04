#!/usr/bin/bash
#
# extra filtering for Korean data
# filter out data that has characters other than Hang
#
# USAGE: filter-korean.sh srclangid trglangid < tab-sepatared-bitext > filtered-bitext
#


tmpsrc=`mktemp`
tmptrg=`mktemp`
tmplang=`mktemp`


if [ "$1" == "kor" ] || [ "$1" == "ko" ]; then
    column=1
elif [ "$2" == "kor" ] || [ "$2" == "ko" ]; then
    column=2
fi

## don't touch test sets
if [ "$3" == "test" ]; then
    column=0
fi


if [ $column -gt 0 ]; then
  echo "... filter Korean bitexts" >&2
  perl -CIOE -pe 's/[\x{2060}\x{200B}\x{feff}]//g'
else 
  cat
fi


## OLD: check script
## this is slow ....

# if [ $column -gt 0 ]; then
#   echo "... filter Korean bitexts ($tmplang $tmpsrc $tmptrg)" >&2
#   perl -CIOE -pe 's/[\x{2060}\x{200B}\x{feff}]//g' |
#   tee >(cut -f1 > $tmpsrc) >(cut -f2 > $tmptrg) |
#   cut -f$column |
#   perl -CIOE -pe 'use utf8;s/\p{P}//g;s/[^\S\n]//g;s/▁//g;s/[0-9]//g' | 
#   langscript -a > $tmplang

#   paste $tmplang $tmpsrc $tmptrg | 
#   grep $'Hang ([0-9]*)\s*\t' |
#   cut -f2,3

#   rm -f $tmplang $tmpsrc $tmptrg
# else 
#   cat
# fi

