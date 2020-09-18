# -*-makefile-*-



%-nbfi-sami:
	make 	SRC=fi TRG=se PIVOT=nb \
		INCLUDE="OpenSubtitles giella glossary" \
		MODELHOME="../work/models/nb+nn+no+nb_NO+nn_NO+no_nb-fi" \
		PIVOT_LANGPAIR=nb+nn+no+nb_NO+nn_NO+no_nb-fi \
		MODEL_CONTAINER=${DEV_MODEL_CONTAINER} \
	${@:-nbfi-sami=}

%-nben-sami:
	make 	SRC=en TRG=se PIVOT=nb \
		INCLUDE="OpenSubtitles giella glossary" \
		MODELHOME="../models/nb+nn+no+nb_NO+nn_NO+no_nb-en" \
		PIVOT_LANGPAIR=nb+nn+no+nb_NO+nn_NO+no_nb-en \
		MODEL_CONTAINER=${DEV_MODEL_CONTAINER} \
	${@:-nben-sami=}

