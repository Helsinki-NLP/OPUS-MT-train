# -*-makefile-*-

## 23 official EU languages:
#
# English
# German
# Swedish
# Finnish
# Dutch
# Danish
# Spanish
# Czech
# French
# Polish
# Portuguese
# Latvian
# Romanian
# Estonian
# Bulgarian
# Greek, Modern (1453-)
# Slovak
# Italian
# Maltese
# Slovenian
# Croatian
# Lithuanian
# Irish
# Hungarian

ELG_EU_LANGIDS = eng deu swe fin nld dan spa ces fra pol por lav ron est bul ell slk ita mlt slv hrv lit gle hun

ELG_EU_SELECTED = gmq nld spa fra pol por lav ron est bul ell ita mlt slv hbs lit cel hun glg eus zle zls zlw tur ara heb sqi deu fin
ELG_EU_SELECTED_MULTILANG = "ces slk" "cat oci" "fry ltz nds afr"


elg-eng2all:
	for l in ${ELG_EU_SELECTED_MULTILANG}; do \
	  ${MAKE} MODELTYPE=transformer-big SRCLANGS=eng TRGLANGS="$$l" tatoeba-job-bt; \
	done
	for l in ${ELG_EU_SELECTED}; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-trainjob-bt; \
	done

elg-eng2missing:
	for l in est lav ron hbs sqi spa fra ita por zlw ara heb deu fin; do \
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2$${l}-trainjob-bt; \
	done

elg-eng2slv:
	  ${MAKE} MODELTYPE=transformer-big tatoeba-eng2slv-trainjob-bt-separate-spm; \
