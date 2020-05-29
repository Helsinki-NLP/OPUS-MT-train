# -*-makefile-*-



%-nbfi-sami:
	make 	SRC=fi TRG=se PIVOT=nb \
		INCLUDE="OpenSubtitles giella glossary" \
		MODELHOME="../work/models/nb+nn+no+nb_NO+nn_NO+no_nb-fi" \
	${@:-nbfi-sami=}

%-nben-sami:
	make 	SRC=en TRG=se PIVOT=nb \
		INCLUDE="OpenSubtitles giella glossary" \
		MODELHOME="../models/nb+nn+no+nb_NO+nn_NO+no_nb-en" \
	${@:-nben-sami=}

