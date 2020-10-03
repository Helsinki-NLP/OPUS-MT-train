

# more efficient parallelisation

from Bergamot:
https://github.com/browsermt/students/blob/master/train-student/alignment/generate-alignment-and-shortlist.sh

```
# Subword segmentation with SentencePiece.
test -s $DIR/corpus.spm.$SRC || cat $CORPUS_SRC | pigz -dc | parallel --no-notice --pipe -k -j16 --block 50M "$MARIAN/spm_encode --model $VOCAB" > $DIR/corpus.spm.$SRC
test -s $DIR/corpus.spm.$TRG || cat $CORPUS_TRG | pigz -dc | parallel --no-notice --pipe -k -j16 --block 50M "$MARIAN/spm_encode --model $VOCAB" > $DIR/corpus.spm.$TRG
```


# related projects

* https://browser.mt (bergamot project)
* https://nteu.eu
* https://gourmet-project.eu
* https://elitr.eu
* https://www.european-language-grid.eu

Multilingual data:

* http://lr-coordination.eu (ELRC)
* https://www.pret-a-llod.eu
* https://www.taus.net


further resources: (from http://techiaith.cymru/translation/demo/?lang=en)
contact: Dewi Jones (d.b.jones@bangor.ac.uk)

http://techiaith.cymru/corpws/Moses/CofnodYCynulliad/CofnodYCynulliad.tar.gz
http://techiaith.cymru/corpws/Moses/Deddfwriaeth/Deddfwriaeth.tar.gz
http://techiaith.cymru/corpws/Moses/Meddalwedd/Meddalwedd.tar.gz
http://techiaith.cymru/alinio/rhestr_geiriau.tsv
http://techiaith.cymru/alinio/hunalign/cy-en.dic

(see work/data/cy-en)



# celtic languages

LANGS = "ga cy br gd kv gv"


```
ga	gle			Irish			yes (ga)
cy	wel/cym			Welsh			yes (cy)
br	bre	bre/xbm/obt	Breton			yes (br)
gd	gla			Scottish Gaelic		yes (gd)
kw	cor	cor/cnx/oco	Cornish	 		yes (kw)
gv	glv			Manx			yes (gv)
```


# Romance

LANGS = "fr wa frp oc ca rm lld fur lij lmo es pt gl lad an mwl it co nap scn vec sc ro la"
LANGS_FR = "fr_BE fr_CA fr_FR"
LANGS_ES = "es_AR es_CL es_CO es_CR es_DO es_EC es_ES es_GT es_HN es_MX es_NI es_PA es_PE es_PR es_SV es_UY es_VE"
LANGS_PT = "pt_br pt_BR pt_PT"
LANGS_IT = "it_IT"


## Gallo-Romance

```
fr							yes (regional variants: BE CA FR)
wa	wln			Walloon			yes
	pcs			Picard			no
	nrf			Norman			no
	frp			FRanco-Provencal	yes
oc	oci			Occitano-Romance	yes

ca	cat			Catalan			yes (ca/cat)
rm	roh			Romansh			yes (rm)
	lld			Ladin			yes
	fur			Friulan			yes
	lij			Liguran			yes
	lmo			Lombard			yes (very little / noisy wikimedia)
```

## Iberian-Romance

```
es							yes (regional variants: AR CL CO CR DO EC ES GT HN MX NI PA PE PR SV UY VE)
pt							yes (variants: br BR PT)
gl							yes
	lad			Ladino			yes
an	arg			Aragonese		yes (an)
	mxi			Mozarabic		no
	mwl			Mirandese		yes (very little / noisy wikimedia)
```

## Italo-Dalmatian

```
it							yes (regional variants: IT)
co	cos			Corsican		yes
	nap			Napolitan		yes (very little / noisy wikimedia)
	scn			Sicilian		yes (very little / noisy wikimedia)
	dlm			Dalmatian		no
	vec			Venetian		yes
	itk			Judeo-Italian		no
```

## Sardinian

```
sc	srd			Sardinian		yes
```

## Eastern Romance

```
ro							yes
```

## Early forms

```
la							yes
				Vulgar
```