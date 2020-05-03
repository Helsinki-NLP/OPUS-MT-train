

#-------------------------------------------------------------------
# Romance-languages - English models
#-------------------------------------------------------------------

LANGS_FR_VARIANTS = fr_BE fr_CA fr_FR
LANGS_ES_VARIANTS = es_AR es_CL es_CO es_CR es_DO es_EC es_ES es_GT es_HN es_MX es_NI es_PA es_PE es_PR es_SV es_UY es_VE
LANGS_PT_VARIANTS = pt_br pt_BR pt_PT
LANGS_ROMANCE = fr ${LANGS_FR_VARIANTS} wa frp oc ca rm lld fur lij lmo es ${LANGS_ES_VARIANTS} pt ${LANGS_PT_VARIANTS} gl lad an mwl it it_IT co nap scn vec sc ro la

%-romance-english:
	${MAKE} HPC_DISK=1000 HELDOUTSIZE=0 MODELTYPE=transformer SRCLANGS="${LANGS_ROMANCE}" TRGLANGS=en \
	${@:-romance-english=}

%-english-romance:
	${MAKE} HPC_DISK=1000 HELDOUTSIZE=0 MODELTYPE=transformer TRGLANGS="${LANGS_ROMANCE}" SRCLANGS=en \
	${@:-english-romance=}


