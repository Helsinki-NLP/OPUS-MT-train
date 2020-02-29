# Misc clean up on corpus
# sed -i -f corpora-cleanup.sed corpus/*.txt
# Chillu normalization
s/ന്‍/ൻ/g
s/ള്‍/ൾ/g
s/ല്‍/ൽ/g
s/ര്‍/ർ/g
s/ന്‍/ൻ/g
s/ണ്‍/ൺ/g
# Remove ZWNJ at end of words
s/\xE2\x80\x8C$//g
# Remove all other ZWJ
s/\xE2\x80\x8D//g
# Remove all soft hyphens
s/\xC2\xAD//g
# Replace old au sign with new one
s/‍ൌ/ൗ/g

#Common mistakes
s/പക്ഷെ/പക്ഷേ/g
# ZWNJs
s/ു‌/ു/g
s/ി‌/ു/g
s/ോ‌/ോ/g
s/ാ‌/ാ/g
s/ഒാ/ഓ/g
# ൻറെ -> ന്റെ at the end of words
s/ൻറെ/ന്റെ/g
s/ൻറ്$/ന്റ്/g
s/ൻറും$/ന്റും/g
s/ൻറിൽ$/ന്റിൽ/g
# ുൻപോൾ - ുമ്പോൾ
s/ുൻപോൾ/ുമ്പോൾ/g