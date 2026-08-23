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
	# Quattro scoperte uscivano col proprio suffisso in mezzo alla frase —
	# «scoperta: trade_ledger». Il ripiego per prefisso le faceva passare per
	# note (`known()` diceva si'), e nessuna prova poteva vedere la differenza
	# fra una parola e un id vestito da parola (D-236).
	"discovery:shared_record": "scoperta: il registro condiviso",
	"discovery:the_measure": "scoperta: la misura",
	"discovery:the_omen": "scoperta: il presagio",
	"discovery:trade_ledger": "scoperta: il registro dei traffici",
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
## **I fatti del mondo** — quelli globali, che non stanno su una Regione ne' su
## una casa ma sulla Cronaca, e che l'anno dopo richiamano le domande (D-079).
##
## Mancavano, e si vedeva sulle carte: «Registro» e «Credito» dicevano al
## giocatore «un segno cade sul mondo» invece di «il mondo registra: i conti
## sono pubblici». Trenta fatti, e ognuno e' una cosa successa — quindi si
## dicono al **passato**, che e' come li legge chi apre la Cronaca l'anno dopo.
const WORLD_WORDS: Dictionary = {
	"account_settled": "il conto e' stato saldato",
	# **I quattordici che la clausola scrive** (D-236). Erano senza parola, e
	# fino a ieri non si vedevano: una clausola qualificata applicava i suoi
	# effetti e basta. Da quando la scheda di una domanda si legge sullo schermo
	# **prima** del Consiglio, quella riga e' esattamente il pezzo su cui si
	# decide se attaccare una condizione, e diceva «un segno cade sul mondo».
	"amnesty_granted": "l'amnistia e' stata concessa",
	"betrayal_spoken": "il tradimento e' stato detto ad alta voce",
	"crystal_measured": "il Cristallo e' stato misurato",
	"parley_held": "ci si e' parlato",
	"petition_heard": "la richiesta e' stata ascoltata",
	"someone_paid": "qualcuno ha pagato",
	"charter_for_all": "la Carta vale per tutti",
	"charter_temporary": "la Carta vale per un tempo solo",
	"debt_staggered": "il debito e' stato dilazionato",
	"descent_witnessed": "la discesa e' stata fatta davanti a testimoni",
	"distribution_audited": "la distribuzione e' stata contata",
	"knowledge_shared": "quello che si e' saputo lo sanno tutti",
	"list_witnessed": "la lista e' stata letta davanti a testimoni",
	"quota_guaranteed": "una quota e' garantita",
	"relic_recorded": "la reliquia e' a registro",
	"return_promised": "il ritorno e' stato promesso",
	"succession_witnessed": "la successione ha avuto testimoni",
	"toll_shared": "il pedaggio si divide",
	"water_shared": "l'acqua si divide",
	"burden_shared": "il peso e' stato diviso",
	"charter_written": "la Carta e' stata scritta",
	"crown_dispossessed": "la corona e' stata spogliata",
	"crown_divided": "la corona e' stata divisa",
	"crystal_exploited": "il Cristallo e' stato sfruttato",
	"debt_called": "il debito e' stato chiamato",
	"debt_forgiven": "il debito e' stato perdonato",
	"dragon_slain": "il drago e' stato abbattuto",
	"faith_established": "la fede ha avuto un posto",
	"grain_requisitioned": "il grano e' stato requisito",
	"heir_named": "l'erede e' stato nominato",
	"ledger_public": "i conti sono pubblici",
	"mine_sealed": "le Miniere sono state sigillate",
	"mountain_forgotten": "la montagna e' diventata racconto",
	"nahr_settled": "i Nahr si sono fermati",
	"no_charter": "la Carta non e' stata scritta",
	"oath_broken": "il giuramento e' stato rotto",
	"order_restored": "l'ordine e' stato ristabilito",
	"question_unresolved": "una domanda e' rimasta aperta",
	"relic_buried": "la reliquia e' stata sepolta",
	"relic_shown": "la reliquia e' stata mostrata",
	"seal_kept": "il sigillo ha tenuto",
	"seal_kept_twice": "il sigillo ha tenuto due volte",
	"study_supervised": "lo studio e' sotto sorveglianza",
	"succession_by_law": "la successione e' passata per legge",
	"succession_settled": "la successione e' stata risolta",
	"valley_sealed": "la Valle e' stata chiusa",
	"water_moves": "l'acqua ha cambiato strada",
	"water_priced": "l'acqua ha un prezzo",
}

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
	if WORLD_WORDS.has(tag):
		return str(WORLD_WORDS[tag])
	# Una leggenda e' il fatto di prima, un'era dopo (D-225): si dice cosi'.
	if tag.begins_with("legend:") and WORLD_WORDS.has(tag.trim_prefix("legend:")):
		return "si racconta che %s" % str(WORLD_WORDS[tag.trim_prefix("legend:")])
	if tag.begins_with("evicted:"):
		return "cacciata da %s" % _region_name(tag.trim_prefix("evicted:"), data)
	# **E se non c'e' una parola scritta, la pietra ha gia' il suo nome nei
	# dati** (D-229): `grades[].name` e' «Reggia», «Citta'», «Archivio». Prima
	# questa funzione tornava il suffisso inglese — sulla mappa si leggeva
	# «palace», «archive», «forest» — e per `settlement:` faceva di peggio,
	# cercando una **casa** con quel nome e stampando «insediamento: city».
	#
	# Il ripiego sta **dopo** REGION_WORDS e non prima: un tag di pietra copre
	# piu' gradi — `structure:granary` e' sia il Granaio sia il Grande Granaio —
	# quindi la parola scritta a mano e' quella giusta per il tag, e il nome del
	# grado e' solo il ripiego per i tag che nessuno ha ancora battezzato.
	var stone: String = _stone_name(tag, data)
	if stone != "":
		return stone
	if tag.begins_with("settlement:"):
		return "insediamento: %s" % _entity_name(tag.trim_prefix("settlement:"), data)
	if tag.begins_with("discovery:"):
		return "scoperta: %s" % tag.trim_prefix("discovery:")
	# Un segno nuovo senza parola si legge comunque - e il test lo segnala.
	return tag.get_slice(":", tag.get_slice_count(":") - 1)


## Il nome che i dati danno a questa pietra, o "".
static func _stone_name(tag: String, data) -> String:
	if data == null:
		return ""
	for structure_id in data.structure_types:
		var structure: Dictionary = data.structure_types[str(structure_id)] as Dictionary
		for grade in structure.get("grades", []) as Array:
			if str((grade as Dictionary).get("tag", "")) == tag:
				return str((grade as Dictionary).get("name", ""))
		var ruin: Dictionary = structure.get("ruin", {}) as Dictionary
		if str(ruin.get("tag", "")) == tag:
			return str(ruin.get("name", ""))
	return ""


static func known(tag: String) -> bool:
	if REGION_WORDS.has(tag) or ENTITY_WORDS.has(tag) or WORLD_WORDS.has(tag):
		return true
	if tag.begins_with("legend:") and WORLD_WORDS.has(tag.trim_prefix("legend:")):
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


## **Che pezzo e' un segno** (D-229): il nome del glifo con cui si disegna sulla
## mappa e sul foglio dei segnalini.
##
## Per le pietre la famiglia la dicono **i dati** — `structures/*.json` lega ogni
## grado al proprio tag — cosi' non c'e' una tabella da tenere allineata a mano:
## se domani nasce una famiglia nuova, il pezzo arriva da solo. Per tutto il
## resto vale il livello del segno, che e' quello che il prefisso dichiara gia'.
static func piece(tag: String, data = null) -> String:
	var family: String = _stone_family(tag, data)
	if family != "":
		return family
	for level in ["condition", "scar", "structure", "settlement", "place"]:
		if tag.begins_with("%s:" % level):
			# `place:` non ha un livello suo fra le icone: e' terra, non opera.
			return "luogo" if level == "place" else level
	return ""


## La famiglia della pietra che posa questo tag, in minuscolo, o "".
static func _stone_family(tag: String, data) -> String:
	if data == null:
		return ""
	for structure_id in data.structure_types:
		var structure: Dictionary = data.structure_types[str(structure_id)] as Dictionary
		for grade in structure.get("grades", []) as Array:
			if str((grade as Dictionary).get("tag", "")) == tag:
				return str(structure.get("family", "")).to_lower()
		var ruin: Dictionary = structure.get("ruin", {}) as Dictionary
		if str(ruin.get("tag", "")) == tag:
			return str(structure.get("family", "")).to_lower()
	return ""


## **La famiglia di un tipo di pietra**, in minuscolo: e' con quella che si
## disegna. Prende il tipo (`STR_KEEP`) e non il tag, perche' un tag di pietra
## copre piu' gradi e il grado vero sta nel mondo — `region.structures` porta
## `{structure_type, grade, owner}`, che e' l'unica verita' su cosa c'e' e di chi
## e'.
static func family_of(structure_type: String, data) -> String:
	if data == null:
		return ""
	var definition: Variant = data.structure_types.get(structure_type)
	if definition == null:
		return ""
	return str((definition as Dictionary).get("family", "")).to_lower()


## Il nome del grado in cui sta questa pietra adesso: «Torre di veglia»,
## «Castello», «Reggia».
static func grade_name(structure_type: String, grade: int, data) -> String:
	if data == null:
		return ""
	var definition: Variant = data.structure_types.get(structure_type)
	if definition == null:
		return ""
	var grades: Array = (definition as Dictionary).get("grades", [])
	if grade < 1 or grade > grades.size():
		return str((definition as Dictionary).get("name", ""))
	return str((grades[grade - 1] as Dictionary).get("name", ""))
