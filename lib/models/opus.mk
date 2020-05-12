


#-------------------------------------------------------------------
# OPUS-MT
#-------------------------------------------------------------------



# iso639 = aa ab ae af ak am an ar as av ay az ba be bg bh bi bm bn bo br bs ca ce ch cn co cr cs cu cv cy da de dv dz ee el en eo es et eu fa ff fi fj fo fr fy ga gd gl gn gr gu gv ha hb he hi ho hr ht hu hy hz ia id ie ig ik io is it iu ja jp jv ka kg ki kj kk kl km kn ko kr ks ku kv kw ky la lb lg li ln lo lt lu lv me mg mh mi mk ml mn mo mr ms mt my na nb nd ne ng nl nn no nr nv ny oc oj om or os pa pi pl po ps pt qu rm rn ro ru rw ry sa sc sd se sg sh si sk sl sm sn so sq sr ss st su sv sw ta tc te tg th ti tk tl tn to tr ts tt tw ty ua ug uk ur uz ve vi vo wa wo xh yi yo za zh zu

# NO_MEMAD = ${filter-out fi sv de fr nl,${iso639}}


#"de_AT de_CH de_DE de"
#"en_AU en_CA en_GB en_NZ en_US en_ZA en"
#"it_IT if"
#"es_AR es_CL es_CO es_CR es_DO es_EC es_ES es_GT es_HN es_MX es_NI es_PA es_PE es_PR es_SV es_UY es_VE es"
#"eu_ES eu"
#"hi_IN hi"
#"fr_BE fr_CA fr_FR fr"
#"fa_AF fa_IR fa"
#"ar_SY ar_TN ar"
#"bn_IN bn"
#da_DK
#bg_BG
#nb_NO
#nl_BE nl_NL
#tr_TR
### ze_en - English subtitles in chinese movies


OPUSLANGS = fi sv fr es de ar he "cmn cn yue ze_zh zh_cn zh_CN zh_HK zh_tw zh_TW zh_yue zhs zht zh" "pt_br pt_BR pt_PT pt" aa ab ace ach acm acu ada ady aeb aed ae afb afh af agr aha aii ain ajg aka ake akl ak aln alt alz amh ami amu am ang an aoc aoz apc ara arc arh arn arq ary arz ase asf ast as ati atj avk av awa aym ay azb "az_IR az" bal bam ban bar bas ba bbc bbj bci bcl bem ber "be_tarask be" bfi bg bho bhw bh bin bi bjn bm bn bnt bo bpy brx br bsn bs btg bts btx bua bug bum bvl bvy bxr byn byv bzj bzs cab cac cak cat cay ca "cbk_zam cbk" cce cdo ceb ce chf chj chk cho chq chr chw chy ch cjk cjp cjy ckb ckt cku cmo cnh cni cop co "crh_latn crh" crp crs cr csb cse csf csg csl csn csr cs cto ctu cuk cu cv cycl cyo cy daf da dga dhv dik din diq dje djk dng dop dsb dtp dty dua dv dws dyu dz ecs ee efi egl el eml enm eo esn  et eu ewo ext fan fat fa fcs ff fil fj fkv fon foo fo frm frp frr fse fsl fuc ful fur fuv fy gaa gag gan ga gbi gbm gcf gcr gd gil glk gl gn gom gor gos got grc gr gsg gsm gss gsw guc gug gum gur guw gu gv gxx gym hai hak hau haw ha haz hb hch hds hif hi hil him hmn hne hnj hoc ho hrx hr hsb hsh hsn ht hup hus hu hyw hy hz ia iba ibg ibo id ie ig ike ik ilo inh inl ins io iro ise ish iso is it iu izh jak jam jap ja jbo jdt jiv jmx jp jsl jv kaa kab kac kam kar kau ka kbd kbh kbp kea kek kg kha kik kin ki kjh kj kk kl kmb kmr km kn koi kok kon koo ko kpv kqn krc kri krl kr ksh kss ksw ks kum ku kvk kv kwn kwy kw kxi ky kzj lad lam la lbe lb ldn lez lfn lg lij lin liv li lkt lld lmo ln lou lo loz lrc lsp ltg lt lua lue lun luo lus luy lu lv lzh lzz mad mai mam map_bms mau max maz mco mcp mdf men me mfe mfs mgm mgr mg mhr mh mic min miq mi mk mlg ml mnc mni mnw mn moh mos mo mrj mrq mr "ms_MY ms" mt mus mvv mwl mww mxv myv my mzn mzy nah nan nap na nba "nb_NO nb nn_NO nn nog no_nb no" nch nci ncj ncs ncx ndc "nds_nl nds" nd new ne ngl ngt ngu ng nhg nhk nhn nia nij niu nlv nl nnh non nov npi nqo nrm nr nso nst nv nya nyk nyn nyu ny nzi oar oc ojb oj oke olo om orm orv or osx os ota ote otk pag pam pan pap pau pa pbb pcd pck pcm pdc pdt pes pfl pid pih pis pi plt pl pms pmy pnb pnt pon pot po ppk ppl prg prl prs pso psp psr ps pys quc que qug qus quw quy qu quz qvi qvz qya rap rar rcf rif rmn rms rmy rm rnd rn rom ro rsl rue run rup ru rw ry sah sat sa sbs scn sco sc sd seh se sfs sfw sgn sgs sg shi shn shs shy sh sid simple si sjn sk sl sma sml sm sna sn som son sop sot so sqk sq "sr_ME sr srp" srm srn ssp ss stq st sux su svk swa swc swg swh sw sxn syr szl "ta_LK ta" tcf tcy tc tdt tdx tet te "tg_TJ tg" thv th tig tir tiv ti tkl tk tlh tll "tl_PH tl" tly tmh tmp tmw tn tob tog toh toi toj toki top to tpi tpw trv tr tsc tss ts tsz ttj tt tum tvl tw tyv ty tzh tzl tzo udm ug uk umb urh "ur_PK ur" usp uz vec vep ve "vi_VN vi" vls vmw vo vro vsl wae wal war wa wba wes wls wlv wol wo wuu xal xho xh xmf xpe yao yap yaq ybb yi yor yo yua zab zai zam za zdj zea zib zlm zne zpa zpg zsl zsm "zul zu" zza


allopus2pivot:
	for l in ${filter-out ${PIVOT},${OPUSLANGS}}; do \
	  ${MAKE} WALLTIME=72 SRCLANGS="$$l" TRGLANGS=${PIVOT} bilingual-dynamic; \
	done

## this looks dangerous ....
allopus:
	for s in ${OPUSLANGS}; do \
	  for t in ${OPUSLANGS}; do \
	    if [ ! -e "${WORKHOME}/$$s-$$t/train.submit" ]; then \
	      echo "${MAKE} WALLTIME=72 SRCLANGS=\"$$s\" SRCLANGS=\"$$t\" bilingual-dynamic"; \
	      ${MAKE} WALLTIME=72 SRCLANGS="$$s" TRGLANGS="$$t" bilingual-dynamic; \
	    fi \
	  done \
	done

all2en:
	${MAKE} PIVOT=en allopus2pivot






allopus2pivot-small:
	for l in $(sort ${filter-out ${PIVOT},${OPUSLANGS}}); do \
	  ${MAKE} SRCLANGS="$$l" TRGLANGS=${PIVOT} local-config; \
	  ${MAKE} WALLTIME=72 SRCLANGS="$$l" TRGLANGS=${PIVOT} train-if-small; \
	done


train-if-small:
	if [ ${BPESIZE} -lt 12000 ]; then \
	  ${MAKE} data; \
	  ${MAKE} train-and-eval-job; \
	  ${MAKE} reverse-data; \
	  ${MAKE} TRGLANGS="${SRCLANGS}" SRCLANGS='${TRGLANGS}' train-and-eval-job; \
	fi




## make models with backtranslations in both directions
## for English-to-other language models
##
## --> xx-to-English-to backtranslations is on al parts of all wikis
## --> English-to-xx backtranslations is only one part of wikipedia
##
## NOTE: this does not work for multilingual models!

opus-enxx:
	${MAKE} SRCLANGS=${TRG} TRGLANGS=${SRC} all-and-backtranslate-allwikis
	${MAKE} all-and-backtranslate-bt
	${MAKE} SRCLANGS=${TRG} TRGLANGS=${SRC} all-bt
