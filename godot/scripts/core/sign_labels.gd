extends RefCounted
## Le parole italiane dei segni (ISSUES 22, Fase 3 - D-107).
##
## Un segno che morde deve avere un nome che si legge al tavolo: sulla mappa
## dell'app, nel pannello del seggio e sul segnalino di cartone stampato dalla
## fustella. Questo dizionario è l'unico posto dove un tag diventa una parola;
## la mappa, il pannello e il foglio dei segnalini lo condividono, e un test
## garantisce che ogni segno scritto nei dati abbia qui la sua parola — un
## segno senza nome è un bug, non un'atmosfera.

## I segni che si posano su una Regione.
const REGION_WORDS: Dictionary = {
	"condition:abandoned": "abbandonata",
	"condition:contested": "contesa",
	"condition:cut_off": "tagliata fuori",
	"condition:emptied": "svuotata",
	"condition:exploited": "sfruttata",
	"condition:indebted": "indebitata",
	"condition:lean": "magra",
	"condition:mourning": "in lutto",
	"condition:plundered": "depredata",
	"condition:rationed": "razionata",
	"condition:requisitioned": "requisita",
	"condition:starving": "affamata",
	"condition:unrest": "inquieta",
	"condition:guarded": "sorvegliata",
	"scar:abandoned": "l'abbandono",
	"scar:broken_bridge": "il ponte rotto",
	"scar:broken_word": "la parola rotta",
	"scar:changed_hands": "passata di mano",
	"scar:divided_seal": "il sigillo diviso",
	"scar:dragonfall": "la caduta del drago",
	"scar:emptied": "lo sgombero",
	"scar:open_wound": "la ferita aperta",
	"scar:plundered": "la razzia",
	"scar:sealed_border": "il confine sigillato",
	"scar:the_empty_chair": "il seggio vuoto",
	"scar:unanswered": "la domanda sul muro",
	"settlement:march": "la marca",
	"settlement:market": "il mercato",
	"structure:canal": "il canale",
	"structure:granary": "il granaio",
	"structure:sealed": "il sigillo",
	"structure:tollgate": "il pedaggio",
	"structure:watchtower": "la torre di veglia",
}

## I segni che una casa porta con sé.
const ENTITY_WORDS: Dictionary = {
	"anointed": "la custodia riconosciuta",
	"ash_watch": "la veglia della cenere",
	"discovery:crystal": "scoperta: il cristallo",
	"discovery:legend": "scoperta: la leggenda",
	"discovery:relic": "scoperta: la reliquia",
	"discovery:supervised_record": "scoperta: lo studio custodito",
	"discovery:the_charter": "scoperta: la carta",
	"discovery:the_ledger": "scoperta: il registro",
	"discovery:written_law": "scoperta: la legge scritta",
	"escort_sworn": "la scorta giurata",
	"uprooted": "sradicato",
	"twice_uprooted": "due volte sradicato",
	"failed_proposal": "la proposta caduta",
	"heir_named": "l'erede nominato",
	"renowned": "la fama",
	"water_rights": "i diritti d'acqua",
	"crowned": "la corona",
	"migrating": "in cammino",
	"scholar": "il sapere",
	"ancient": "antica",
	"sleeping": "dormiente",
	"guild": "la gilda",
	"order": "l'ordine",
	"ash": "la cenere",
	"free_cities": "le città libere",
}


## I domini delle Tensioni, in italiano: un Claim rivendica un dominio, e sul
## pannello si legge la parola, non l'enum (ISSUES 22, l'inventario dell'app).
const DOMAIN_WORDS: Dictionary = {
	"SURVIVAL": "la sopravvivenza",
	"RESOURCE": "le risorse",
	"TERRITORY": "il territorio",
	"ANCIENT": "l'antico",
}


static func domain(id: String) -> String:
	return str(DOMAIN_WORDS.get(id, id.to_lower()))


## La parola di un segno, con il vocabolario giusto per dove sta. `data` serve
## solo ai segni che portano un id dentro (la cacciata da una Regione,
## l'insediamento di una casa): senza, resta l'id — leggibile, mai vuoto.
static func label(tag: String, data = null) -> String:
	if REGION_WORDS.has(tag):
		return str(REGION_WORDS[tag])
	if ENTITY_WORDS.has(tag):
		return str(ENTITY_WORDS[tag])
	if tag.begins_with("evicted:"):
		return "cacciata da %s" % _region_name(tag.trim_prefix("evicted:"), data)
	if tag.begins_with("settlement:"):
		return "insediamento: %s" % _entity_name(tag.trim_prefix("settlement:"), data)
	if tag.begins_with("discovery:"):
		return "scoperta: %s" % tag.trim_prefix("discovery:")
	# Un segno nuovo senza parola si legge comunque - e il test lo segnala.
	return tag.get_slice(":", tag.get_slice_count(":") - 1)


static func known(tag: String) -> bool:
	if REGION_WORDS.has(tag) or ENTITY_WORDS.has(tag):
		return true
	for prefix in ["evicted:", "settlement:", "discovery:"]:
		if tag.begins_with(prefix):
			return true
	return false


static func _region_name(id: String, data) -> String:
	if data != null and data.regions.has(id):
		return str(data.regions[id]["name"])
	return id


static func _entity_name(id: String, data) -> String:
	if data != null and data.entities.has(id):
		return str(data.entities[id]["name"])
	return id
