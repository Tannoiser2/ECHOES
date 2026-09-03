extends RefCounted
## Le parole italiane dei segni (ISSUES 22, Fase 3 - D-107).
##
## Un segno che morde deve avere un nome che si legge al tavolo: sulla mappa
## dell'app, nel pannello del seggio e sul segnalino di cartone stampato dalla
## fustella. Questo dizionario è l'unico posto dove un tag diventa una parola;
## la mappa, il pannello e il foglio dei segnalini lo condividono, e un test
## garantisce che ogni segno scritto nei dati abbia qui la sua parola — un
## segno senza nome è un bug, non un'atmosfera.

# --- GENERATO da tools/gen_sign_labels.py — non si corregge qui ---

## I segni che si posano su una Regione.
const REGION_WORDS: Dictionary = {
	"condition:abandoned": "abbandonata",
	"condition:contested": "contesa",
	"condition:cut_off": "tagliata fuori",
	"condition:emptied": "svuotata",
	"condition:exploited": "sfruttata",
	"condition:guarded": "sorvegliata",
	"condition:indebted": "indebitata",
	"condition:lean": "magra",
	"condition:mourning": "in lutto",
	"condition:plundered": "depredata",
	"condition:rationed": "razionata",
	"condition:starving": "affamata",
	"condition:unrest": "inquieta",
	"scar:abandoned": "l'abbandono",
	"scar:broken_bridge": "il ponte rotto",
	"scar:broken_word": "la parola rotta",
	"scar:burned_records": "i registri bruciati",
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

## I segni che una casa si porta addosso.
const ENTITY_WORDS: Dictionary = {
	"ancient": "antica",
	"anointed": "la custodia riconosciuta",
	"ash": "la cenere",
	"ash_watch": "la veglia della cenere",
	"crowned": "la corona",
	"discovery:crystal": "scoperta: il cristallo",
	"discovery:legend": "scoperta: la leggenda",
	"discovery:relic": "scoperta: la reliquia",
	"discovery:shared_record": "scoperta: il registro condiviso",
	"discovery:supervised_record": "scoperta: lo studio custodito",
	"discovery:the_charter": "scoperta: la carta",
	"discovery:the_ledger": "scoperta: il registro",
	"discovery:the_measure": "scoperta: la misura",
	"discovery:the_omen": "scoperta: il presagio",
	"discovery:trade_ledger": "scoperta: il registro dei traffici",
	"discovery:written_law": "scoperta: la legge scritta",
	"escort_sworn": "la scorta giurata",
	"failed_proposal": "la proposta caduta",
	"free_cities": "le città libere",
	"guild": "la gilda",
	"hard_bargain": "la parola fredda",
	"heir_named": "l'erede e' stato nominato",
	"migrating": "in cammino",
	"order": "l'ordine",
	"renowned": "la fama",
	"scholar": "il sapere",
	"sleeping": "dormiente",
	"spoke_and_lost": "la proposta caduta in Consiglio",
	"took_by_hand": "si e' servito da solo",
	"twice_uprooted": "due volte sradicato",
	"uprooted": "sradicato",
	"watched": "sotto osservazione",
	"water_rights": "i diritti d'acqua",
}

## Le memorie del mondo, al centro del tavolo.
const WORLD_WORDS: Dictionary = {
	"account_settled": "il conto e' stato saldato",
	"amnesty_granted": "l'amnistia e' stata concessa",
	"betrayal_spoken": "il tradimento e' stato detto ad alta voce",
	"burden_shared": "il peso e' stato diviso",
	"charter_for_all": "la Carta vale per tutti",
	"charter_temporary": "la Carta vale per un tempo solo",
	"charter_written": "la Carta e' stata scritta",
	"crown_dispossessed": "la corona e' stata spogliata",
	"crown_divided": "la corona e' stata divisa",
	"crystal_exploited": "il Cristallo e' stato sfruttato",
	"crystal_measured": "il Cristallo e' stato misurato",
	"debt_called": "il debito e' stato chiamato",
	"debt_forgiven": "il debito e' stato perdonato",
	"debt_staggered": "il debito e' stato dilazionato",
	"descent_witnessed": "la discesa e' stata fatta davanti a testimoni",
	"distribution_audited": "la distribuzione e' stata contata",
	"dragon_slain": "il drago e' stato abbattuto",
	"faith_established": "la fede ha avuto un posto",
	"grain_requisitioned": "il grano e' stato requisito",
	"heir_named": "l'erede e' stato nominato",
	"knowledge_shared": "quello che si e' saputo lo sanno tutti",
	"ledger_public": "i conti sono pubblici",
	"list_witnessed": "la lista e' stata letta davanti a testimoni",
	"mine_sealed": "le Miniere sono state sigillate",
	"mountain_forgotten": "la montagna e' diventata racconto",
	"nahr_settled": "i Nahr si sono fermati",
	"no_charter": "la Carta non e' stata scritta",
	"oath_broken": "il giuramento e' stato rotto",
	"order_restored": "l'ordine e' stato ristabilito",
	"parley_held": "ci si e' parlato",
	"petition_heard": "la richiesta e' stata ascoltata",
	"price_in_lives": "si e' pagato in vite",
	"question_unresolved": "una domanda e' rimasta aperta",
	"quota_guaranteed": "una quota e' garantita",
	"relic_buried": "la reliquia e' stata sepolta",
	"relic_recorded": "la reliquia e' a registro",
	"relic_shown": "la reliquia e' stata mostrata",
	"return_promised": "il ritorno e' stato promesso",
	"rumour_running": "la voce corre",
	"seal_kept": "il sigillo ha tenuto",
	"seal_kept_twice": "il sigillo ha tenuto due volte",
	"someone_paid": "qualcuno ha pagato",
	"study_supervised": "lo studio e' sotto sorveglianza",
	"succession_by_law": "la successione e' passata per legge",
	"succession_settled": "la successione e' stata risolta",
	"succession_witnessed": "la successione ha avuto testimoni",
	"toll_shared": "il pedaggio si divide",
	"valley_sealed": "la Valle e' stata chiusa",
	"water_moves": "l'acqua ha cambiato strada",
	"water_priced": "l'acqua ha un prezzo",
	"water_shared": "l'acqua si divide",
}

# --- fine del blocco generato ---

const DOMAIN_WORDS: Dictionary = {
	"SURVIVAL": "la sopravvivenza",
	"RESOURCE": "le risorse",
	"TERRITORY": "il territorio",
	# **Il quinto dominio mancava** (D-339): lo schema ne dichiara cinque e
	# questa tabella ne aveva quattro, cosi' una Tensione del sapere stampava
	# «knowledge» sulla propria carta. Il ripiego non protesta, scrive inglese.
	"KNOWLEDGE": "il sapere",
	"ANCIENT": "l'antico",
}

## Le sei famiglie delle carte, in italiano.
##
## Stavano dentro `help_panel.gd`, che e' una vista: una tabella di parole
## chiusa in una vista la vede solo quella vista, e la carta stampata scriveva
## «wealth, people, authority» al tavolo. Stanno qui perche' qui e' il posto
## dove un id diventa una parola — la stessa regola dei segni e dei domini.
const FAMILY_WORDS: Dictionary = {
	"FORCE": "forza",
	"AUTHORITY": "autorità",
	"PEOPLE": "gente",
	"KNOWLEDGE": "sapere",
	"WEALTH": "ricchezza",
	"BONDS": "legami",
}


static func domain(id: String) -> String:
	return str(DOMAIN_WORDS.get(id, id.to_lower()))


## I sei verbi, in italiano. Stessa storia delle famiglie (D-339): le parole
## c'erano dentro `help_panel.gd`, e la carta Casata stampava i propri valori
## come «acquire 3 · claim 1 · forge 3».
const ACTION_WORDS: Dictionary = {
	"MOVE": "muovere",
	"INFLUENCE": "influenzare",
	"SCHEME": "tramare",
	"FORGE": "forgiare",
	"CLAIM": "rivendicare",
	"ACQUIRE": "acquisire",
}


static func family(id: String) -> String:
	return str(FAMILY_WORDS.get(id, id.to_lower()))


## Che cosa e' una casa, e cosa cerca. Due enum che finivano sul tarocco della
## Casata — la carta che resta in vista tutta la partita — come «faction · vuole
## wealth» (D-339).
const ARCHETYPE_WORDS: Dictionary = {
	"SOVEREIGN": "sovrano", "PEOPLE": "popolo", "INDIVIDUAL": "individuo",
	"CREATURE": "creatura", "FACTION": "fazione", "CULT": "culto",
}

const NEED_WORDS: Dictionary = {
	"POWER": "il potere", "SURVIVAL": "la sopravvivenza", "KNOWLEDGE": "il sapere",
	"PROTECTION": "la protezione", "WEALTH": "la ricchezza", "FAITH": "la fede",
	"FREEDOM": "la liberta'",
}


static func action(id: String) -> String:
	return str(ACTION_WORDS.get(id.to_upper(), id.to_lower()))


static func archetype(id: String) -> String:
	return str(ARCHETYPE_WORDS.get(id, id.to_lower()))


static func need(id: String) -> String:
	return str(NEED_WORDS.get(id, id.to_lower()))


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
	# **E il dizionario dei segni ha gia' la parola stampata** (D-336). Il campo
	# `title` e', per definizione dello schema, «il nome stampato: come il segno
	# si chiama sul tavolo e nei verbali» — e per i segni della tessera
	# (`granaio`, `pascolo`, `cristallo`, `capitale`) e' l'unico posto che ce
	# l'ha. Finche' questa riga non c'era, una frase che nominava il luogo
	# stampava il tag inglese: *«in una Regione con crystal_site»*.
	if data != null:
		var entry: Variant = (data.tags as Dictionary).get(tag)
		if entry != null:
			var printed: String = str((entry as Dictionary).get("title", ""))
			if printed != "":
				return printed
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
	# **Un segnaposto non e' il nome di un posto** (D-336). `evicted:` porta
	# dentro la Regione da cui si e' stati cacciati, e su una carta quella
	# Regione non e' ancora scelta: c'e' scritto `$region_focus`. Finche' questa
	# riga non c'era, la frase stampava lo slot — *«cacciata da $region_focus»* —
	# e si e' visto solo quando la frase ha cominciato a nominare il segno.
	match id:
		"$region_focus", "$focus_region":
			return "dove si discuteva"
		"$adjacent":
			return "una Regione confinante"
		"$rival_seat":
			return "la sede del rivale"
		"$capital":
			return "la capitale"
	if id.begins_with("$"):
		return "un posto deciso al tavolo"
	return id


static func _entity_name(id: String, data) -> String:
	if data != null and data.entities.has(id):
		return str(data.entities[id]["name"])
	# **Il buco puo' stare dentro il segno** (D-336): `settlement:$proponent` e'
	# l'insediamento di chi propone, e su una carta chi propone non e' ancora
	# scelto. Come per le Regioni, un segnaposto si dice a parole invece di
	# arrivare stampato fino alla scheda.
	match id:
		"$proponent":
			return "chi propone"
		"$rival":
			return "il rivale"
		"$actor":
			return "chi gioca"
	if id.begins_with("$"):
		return "una casa decisa al tavolo"
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
