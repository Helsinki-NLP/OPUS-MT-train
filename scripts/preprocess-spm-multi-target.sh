#!/bin/bash
#
# USAGE preprocess.sh source-langid target-langid spmodel [noflags] < input > output
#
# replace SPMENCODE with your own setup! 
#
# CHANGES
#
#  * issue with perl code that removes control characters
#    unicode property Other = \p{C}) seems to remove 
#    newline characters as well --> add negative lookahead
#    to avoid removing newline characters!


if [ `hostname -d` == "bullx" ]; then
  APPLHOME=/projappl/project_2001569
  SPMENCODE=${APPLHOME}/marian-dev/build-spm/spm_encode
else
  SPMENCODE=`which spm_encode || echo "${PWD}/tools/marian-dev/build/spm_encode"`
fi


if [ "$4" == "noflags" ]; then
    sed -e 's/，/,/g' \
	-e 's/。 */. /g' \
	-e 's/、/,/g' \
	-e 's/”/"/g' \
	-e 's/“/"/g' \
	-e 's/∶/:/g' \
	-e 's/：/:/g' \
	-e 's/？/\?/g' \
	-e 's/《/"/g' \
	-e 's/》/"/g' \
	-e 's/）/\)/g' \
	-e 's/！/\!/g' \
	-e 's/（/\(/g' \
	-e 's/；/;/g' \
	-e 's/１/"/g' \
	-e 's/」/"/g' \
	-e 's/「/"/g' \
	-e 's/０/0/g' \
	-e 's/３/3/g' \
	-e 's/２/2/g' \
	-e 's/５/5/g' \
	-e 's/６/6/g' \
	-e 's/９/9/g' \
	-e 's/７/7/g' \
	-e 's/８/8/g' \
	-e 's/４/4/g' \
	-e 's/． */. /g' \
	-e 's/～/\~/g' \
	-e "s/’/\'/g" \
	-e 's/…/\.\.\./g' \
	-e 's/━/\-/g' \
	-e 's/〈/\</g' \
	-e 's/〉/\>/g' \
	-e 's/【/\[/g' \
	-e 's/】/\]/g' \
	-e 's/％/\%/g' |    
	perl -C -pe 's/\p{C}/ /g;' |
	sed 's/  */ /g;s/^ *//g;s/ *$//g' |
	${SPMENCODE} --model $3
else
    sed -e 's/，/,/g' \
	-e 's/。 */. /g' \
	-e 's/、/,/g' \
	-e 's/”/"/g' \
	-e 's/“/"/g' \
	-e 's/∶/:/g' \
	-e 's/：/:/g' \
	-e 's/？/\?/g' \
	-e 's/《/"/g' \
	-e 's/》/"/g' \
	-e 's/）/\)/g' \
	-e 's/！/\!/g' \
	-e 's/（/\(/g' \
	-e 's/；/;/g' \
	-e 's/１/"/g' \
	-e 's/」/"/g' \
	-e 's/「/"/g' \
	-e 's/０/0/g' \
	-e 's/３/3/g' \
	-e 's/２/2/g' \
	-e 's/５/5/g' \
	-e 's/６/6/g' \
	-e 's/９/9/g' \
	-e 's/７/7/g' \
	-e 's/８/8/g' \
	-e 's/４/4/g' \
	-e 's/． */. /g' \
	-e 's/～/\~/g' \
	-e "s/’/\'/g" \
	-e 's/…/\.\.\./g' \
	-e 's/━/\-/g' \
	-e 's/〈/\</g' \
	-e 's/〉/\>/g' \
	-e 's/【/\[/g' \
	-e 's/】/\]/g' \
	-e 's/％/\%/g' |    
	perl -C -pe  's/(?!\n)\p{C}/ /g;'
	sed 's/  */ /g;s/^ *//g;s/ *$//g' |
	${SPMENCODE} --model $3 |
	sed "s/^/>>$2<< /"
fi

