#!/bin/bash
#
# USAGE preprocess.sh source-langid target-langid [noflags] < input > output
#
#

if [ "$3" == "noflags" ]; then
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
	sed 's/  */ /g;s/^ *//g;s/ *$//g'
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
	perl -C -pe  's/(?!\n)\p{C}/ /g;' |
	perl -CIOE -pe 's/[\x{2060}\x{200B}\x{feff}]//g' |\
	sed 's/  */ /g;s/^ *//g;s/ *$//g' |
	sed "s/^/>>$2<< /"
fi

