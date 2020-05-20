# -*-makefile-*-



%-sami:
	make 	SRC=fi TRG=se PIVOT=nb \
		INCLUDE="OpenSubtitles giella glossary" \
		MODELHOME="../work/models/nb+nn+no+nb_NO+nn_NO+no_nb-fi" \
	${@:-sami=}

