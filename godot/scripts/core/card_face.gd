extends RefCounted
## Cosa c'e' stampato su un pezzo, detto una volta sola (§19.4, §21).
##
## Il gioco e' un gioco da tavolo fisico con un'app, non uno dei due
## (COMPONENTS §1): le stesse righe JSON devono produrre la carta che si stampa
## e la carta che si vede sullo schermo. Questo e' il posto in cui succede.
## Ricevuta una definizione, restituisce una **faccia**: titolo, sottotitolo,
## accento, cifra d'angolo, corpo, note, pie' di pagina, chiave d'arte.
##
## Funzioni pure su dizionari: niente mondo, niente sessione, niente RNG. Chi
## disegna - il foglio di stampa in SVG, l'anteprima dentro l'app - decide solo
## *come*, mai *cosa*.
##
## Le tre tabelle qui sotto stavano sparse fra le viste: i colori di famiglia
## dentro `asset_card.gd`, le famiglie drammatiche e le funzioni di Propp dentro
## `echo_card_view.gd`. Due tabelle che devono essere d'accordo e non hanno un
## posto comune finiscono per non esserlo, e adesso il posto comune e' questo.

const AssetText := preload("res://scripts/core/asset_text.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")
const CouncilText := preload("res://scripts/core/council_text.gd")

## Le sei famiglie di Asset e il loro accento. Un solo accento saturo per
## famiglia (ART_BIBLE): la carta si riconosce dal bordo prima che dal titolo.
const FAMILY_COLOURS: Dictionary = {
	"AUTHORITY": "#e8b563",
	"FORCE": "#c8553d",
	"PEOPLE": "#6fa88a",
	"KNOWLEDGE": "#7fa6c9",
	"WEALTH": "#c9a86a",
	"BONDS": "#b06b8f",
}
const NEUTRAL: String = "#8a8172"

## Le quattro famiglie drammatiche delle carte Echo, colore prima: nell'arco di
## tre Atti il colore e' la cosa che un giocatore impara a leggere.
const DRAMA: Dictionary = {
	"PRESSURE": {"colour": "#c9a86a", "label": "PRESSIONE — qualcosa si accumula"},
	"RUPTURE": {"colour": "#c8553d", "label": "ROTTURA — qualcosa si spezza"},
	"TURN": {"colour": "#7fa6c9", "label": "SVOLTA — qualcosa cambia direzione"},
	"RESOLUTION": {"colour": "#6fa88a", "label": "RISOLUZIONE — qualcosa si chiude"},
}

## Le funzioni di Propp hanno nomi inglesi nei dati perche' e' da li che viene la
## morfologia; al tavolo si legge italiano. Un nome che manca esce come id invece
## di sparire.
const PROPP: Dictionary = {
	"LACK": "mancanza", "OMEN": "presagio", "BETRAYAL": "tradimento", "LOSS": "perdita",
	"DISCOVERY": "scoperta", "REVELATION": "rivelazione", "SACRIFICE": "sacrificio",
	"RECONCILIATION": "riconciliazione", "PROHIBITION": "divieto", "THREAT": "minaccia",
	"USURPATION": "usurpazione", "ATTACK": "attacco", "GIFT": "dono",
	"TRANSFORMATION": "trasformazione", "LIBERATION": "liberazione", "RETURN": "ritorno",
	"REQUEST": "richiesta", "TEMPTATION": "tentazione", "VIOLATION": "violazione",
	"SEPARATION": "separazione", "ENCOUNTER": "incontro", "CONQUEST": "conquista",
	"PUNISHMENT": "punizione", "SUCCESSION": "successione",
}

const RARITY: Dictionary = {"COMMON": "comune", "UNCOMMON": "non comune", "RARE": "rara"}

const BIOMES: Dictionary = {
	"CITY": "citta", "VALLEY": "valle", "STEPPE": "steppa", "MOUNTAIN": "montagna",
	"UNDERGROUND": "sottosuolo", "ROAD": "strada", "FOREST": "foresta", "COAST": "costa",
}

## I cinque mazzi che si stampano come carte 2:3, piu' le tessere quadrate. Le
## Consequence non sono qui perche' non sono un pezzo: si vedono sulla mappa come
## overlay, e la COMPONENTS §2 lo dice gia'.
## **E la scheda del Consiglio** (D-338): un pezzo suo, uno per Tensione.
##
## La carta Tensione resta **mini**, perche' D-097 la vuole appoggiata alla
## traccia dei valori: e' il segnalino della domanda in gioco, e una carta da
## tarocco sulla traccia non ci sta. Ma quello che serve per **risolvere** un
## Consiglio — la domanda, le proposte con cosa lasciano, le dodici caselle
## dell'economia — sono 870 caratteri mediani, e su una mini non entrano.
##
## Quindi due pezzi con due mestieri: la mini dice **quando** la domanda si
## scalda e sta sulla traccia; il tarocco dice **cosa si puo' proporre e cosa
## costa**, e si tira fuori quando il Consiglio si apre. E' il «fatto quando»
## di ISSUES 89: una proposta si risolve guardando questa scheda e la mappa.
## Come si chiama, su una carta Eco, il posto che l'Effetto colpisce: non «dove
## si discute», che e' la parola del Consiglio (D-344).
const DOVE_CADE: String = "nel luogo della carta"

const DECKS: Array = ["asset", "echo", "tension", "council", "destiny", "entity"]
const TILES: Array = ["region"]

## Come si chiamano al tavolo, che e' come vanno chiamati ovunque li si nomini:
## sul foglio di stampa, nell'anteprima e nel riepilogo dell'export.
const DECK_LABELS: Dictionary = {
	"asset": "carte Asset", "echo": "carte Echo", "tension": "carte Domanda",
	"council": "schede Consiglio",
	"destiny": "carte Destino", "entity": "carte Casata", "region": "tessere Regione",
}


static func family_colour(family: String) -> String:
	return str(FAMILY_COLOURS.get(family, NEUTRAL))


## Ogni faccia stampabile del set, in ordine stabile: prima per mazzo, poi per
## id. Ordine stabile perche' due export dello stesso dato devono uscire uguali
## byte per byte, come i salvataggi (§18.3).
static func every(data: RefCounted) -> Array:
	var out: Array = []
	for deck in DECKS + TILES:
		out.append_array(deck_of(str(deck), data))
	return out


static func deck_of(deck: String, data: RefCounted) -> Array:
	var source: Dictionary = _source(deck, data)
	var ids: Array = source.keys()
	# Il tarocco per ogni vita (D-111): il mazzo Casata porta anche le
	# incarnazioni oltre la prima - stessa taglia, stesso seggio in
	# sottotitolo, nome e volto propri. La prima vita e' gia' la carta base.
	if deck == "entity":
		for entity_id in source:
			var incarnations: Array = (source[entity_id] as Dictionary).get("incarnations", [])
			for index in range(1, incarnations.size()):
				ids.append(str(incarnations[index]["id"]))
	ids.sort()
	var out: Array = []
	for id in ids:
		out.append(of(deck, str(id), data))
	return out


static func _source(deck: String, data: RefCounted) -> Dictionary:
	match deck:
		"asset": return data.assets
		"echo": return data.echo_cards
		"tension": return data.tensions
		"council": return data.tensions
		"destiny": return data.destinies
		"entity": return data.entities
		"region": return data.regions
	return {}


## Una faccia. `copies` e' quante volte va stampata: sugli Asset e' `deck_copies`
## (D-040), su tutto il resto e' una.
static func of(deck: String, id: String, data: RefCounted) -> Dictionary:
	var item: Dictionary = _source(deck, data).get(id, {})
	# Una vita del seggio (INC_..., D-111): la carta e' il seggio con sopra i
	# campi della vita - nome, descrizione, valori, arte - e l'id della vita,
	# cosi' la cache e i fogli la tengono distinta dalla carta base.
	if item.is_empty() and deck == "entity" and id.begins_with("INC_"):
		var found: Dictionary = life_of(id, data)
		if found.is_empty():
			return {}
		item = (found["seat"] as Dictionary).duplicate()
		for field in ["name", "description", "action_values", "art_prompt_key"]:
			if (found["life"] as Dictionary).has(field):
				item[field] = found["life"][field]
		item["id"] = id
	if item.is_empty():
		return {}
	match deck:
		"asset": return _asset(item, data)
		"echo": return _echo(item, data)
		"tension": return _tension(item)
		"council": return _council(item, data)
		"destiny": return _destiny(item, data)
		"entity": return _entity(item, data)
		"region": return _region(item, data)
	return {}


## La vita e il suo seggio, cercati per id (INC_...): {seat, life}, o vuoto.
static func life_of(life_id: String, data: RefCounted) -> Dictionary:
	for entity_id in data.entities:
		var seat: Dictionary = data.entities[entity_id]
		for life in seat.get("incarnations", []):
			if str((life as Dictionary).get("id", "")) == life_id:
				return {"seat": seat, "life": life}
	return {}


static func _face(deck: String, id: String, shape: String) -> Dictionary:
	return {
		"deck": deck, "id": id, "shape": shape, "title": "", "subtitle": "",
		"accent": NEUTRAL, "corner": "", "body": [], "notes": [], "footer": "",
		"art_prompt_key": "", "copies": 1, "secret": false,
		# Vuoto tranne che sulle Regioni: quelle non hanno un segnaposto generico
		# ma il proprio terreno, generato dal bioma (D-057).
		"terrain": "",
		# La famiglia, quando ce n'e' una: serve al glifo di sistema, che e' lo
		# stesso sullo schermo e in stampa.
		"family": "",
	}


## `data` serve per la riga meccanica: i segni che una carta posa sul mondo si
## dicono con la loro parola italiana, e quella la sa `SignLabels` leggendo il
## set. Lo prendono gia' `_echo` e `_destiny` per la stessa ragione.
static func _asset(asset: Dictionary, data: RefCounted) -> Dictionary:
	var family: String = str(asset["family"])
	var face: Dictionary = _face("asset", str(asset["id"]), "TAROT")
	face["title"] = str(asset["title"])
	# **In italiano** (D-339): la famiglia e' un enum, e `to_lower()` stampava
	# «authority» su otto carte, «bonds» su altre otto, e cosi' per tutte e 48.
	face["subtitle"] = "%s · %s" % [
		SignLabels.family(family), str(RARITY.get(str(asset["rarity"]), "")),
	]
	face["accent"] = family_colour(family)
	# La forza sta nell'angolo perche' e' l'unico numero che si legge con la carta
	# ancora in mano, a ventaglio.
	face["corner"] = str(int(asset["strength"]))
	# **La carta stampa la faccia che si gioca, non il racconto** (D-340).
	#
	# Fino alla 0.1.304 qui c'era `rules_text` — voce d'autore — e le tre righe
	# meccaniche del blocco digitale. Il blocco `physical`, che e' la carta come
	# si usa al tavolo (bersaglio a segni, due Azioni, Risonanza, uso in
	# Consiglio), non lo stampava nessuno: 48 carte su 48, e ce l'hanno tutte.
	#
	# Il racconto esce dalla faccia e resta nel dato: lo legge il brief d'arte,
	# che e' il posto dove serve. Sulla carta ogni riga e' un segno che si posa
	# in un posto preciso o un'azione che si fa.
	#
	# **Il ripiego e' dichiarato**: una carta senza blocco fisico stampa la
	# vecchia faccia e lo dice, invece di uscire muta. Lo schema tiene il blocco
	# opzionale finche' la conversione non e' finita, e un giorno in cui la
	# conversione torna indietro dev'essere un giorno che si vede.
	var physical: Array = AssetText.physical_lines(asset, data)
	if physical.is_empty():
		face["body"] = [str(asset.get("rules_text", ""))]
		face["notes"] = [
			AssetText.action_note(asset),
			AssetText.note(asset, data),
			str(asset.get("acquisition_rule", "")),
			"questa carta non ha ancora una faccia fisica",
		]
	else:
		face["body"] = []
		# **Ogni riga ha la sua intestazione** (D-345): lo scheletro delle carte
		# ha trovato 27 facce su 48 con una riga meccanica senza etichetta —
		# «+1 sul suo tema · si scarta se la impegni · costa: …» — e una riga
		# senza intestazione e' una riga che al tavolo si legge per ultima.
		face["notes"] = physical + [
			"IMPEGNI  %s" % AssetText.note(asset, data),
			"PRENDI  %s" % str(asset.get("acquisition_rule", "")),
		]
	face["family"] = family
	face["art_prompt_key"] = str(asset["art_prompt_key"])
	face["copies"] = int(asset.get("deck_copies", 1))
	face["footer"] = str(asset["id"])
	return face


static func _echo(card: Dictionary, data: RefCounted) -> Dictionary:
	var family: String = str(card["dramatic_family"])
	var described: Dictionary = DRAMA.get(family, {"colour": NEUTRAL, "label": family})
	var face: Dictionary = _face("echo", str(card["id"]), "TAROT")
	face["title"] = str(card["title"])
	var function_id: String = str(card["function_id"])
	face["subtitle"] = "%s · funzione di Propp: %s" % [
		str(described["label"]).split(" —")[0], str(PROPP.get(function_id, function_id.to_lower())),
	]
	face["accent"] = str(described["colour"])
	# **La carta Eco diceva solo cosa si prova, mai cosa succede** (D-344).
	#
	# Trentanove carte su trentanove: **86 Effetti scritti nel dato e zero
	# stampati**, piu' 38 condizioni che dicono quando la carta puo' uscire e
	# che nessuno vedeva. Sulla faccia c'era la `description` — *«Qualcosa che
	# c'era non c'e' piu', e la sua assenza comincia a organizzare le giornate
	# di tutti»* — e basta.
	#
	# Adesso: **QUANDO ESCE** (le condizioni) e **IL MONDO** (quello che la carta
	# fa), chiesto ad `AssetText` come ogni altra riga meccanica del progetto, in
	# modo che la carta non possa dire una cosa e il motore farne un'altra.
	face["body"] = []
	# **E la condizione si genera, non si ricopia.** Le `label` d'autore portano
	# l'id dentro — *«TEN_FAMINE e' in gioco quest'anno»* — su 24 delle 38: e' un
	# id interno su una carta da giocatore, la stessa cosa che D-339 ha tolto da
	# tutte le altre facce. I campi ci sono (`tension_id`, `tag`), e la frase si
	# costruisce da quelli; la `label` resta il ripiego per le forme che i campi
	# non sanno ancora dire.
	var quando: Array = []
	for condition in card.get("eligibility", []) as Array:
		var said: String = _when_it_comes(condition as Dictionary, data)
		if said != "":
			quando.append(said)
	if not quando.is_empty():
		face["notes"].append("QUANDO ESCE  %s" % " · ".join(PackedStringArray(quando)))
	# **Due modi di attaccare un Effetto a una carta Eco**, e tutti e due vanno
	# stampati: un Effetto scritto sulla carta (75 su 86) e una Conseguenza
	# chiamata per id (11). Otto carte hanno **solo** la seconda forma: la prima
	# stesura di questa faccia leggeva soltanto `effect`, e quelle otto uscivano
	# mute. L'ha presa la prova che nessuna faccia sia vuota, che c'era gia'.
	var fa: Array = []
	for hook_v in card.get("effect_hooks", []) as Array:
		var hook: Dictionary = hook_v
		var said: String = ""
		match str(hook.get("kind", "")):
			"EFFECT":
				var effect: Dictionary = hook.get("effect", {})
				if not effect.is_empty():
					said = AssetText.effect_note(effect, data, DOVE_CADE)
			"CONSEQUENCE":
				var consequence: Variant = data.consequences.get(
					str(hook.get("consequence_id", ""))
				)
				if consequence != null:
					said = CouncilText.consequence_note(
						consequence as Dictionary, data, Callable(), DOVE_CADE
					)
		if said != "" and not fa.has(said):
			fa.append(said)
	if not fa.is_empty():
		face["notes"].append("IL MONDO  %s" % " · ".join(PackedStringArray(fa)))
	# Due delle ventiquattro convocano un Consiglio (§12.1 b): e' la carta che si
	# prende il tavolo, e sulla carta stampata dev'esserci scritto.
	var forced: Variant = card.get("forces_confluence_on", null)
	if forced != null and data.tensions.has(str(forced)):
		face["notes"].append(
			"CONVOCA IL CONSIGLIO  su %s" % str(data.tensions[str(forced)]["title"])
		)
	face["art_prompt_key"] = str(card.get("art_prompt_key", ""))
	face["footer"] = str(card["id"])
	return face


## Quando una carta Eco puo' uscire, in parole del tavolo (D-344).
static func _when_it_comes(condition: Dictionary, data: RefCounted) -> String:
	match str(condition.get("type", "")):
		"tension_limit":
			var asked: String = str(condition.get("tension_id", ""))
			if data.tensions.has(asked):
				return "%s e' al tavolo" % str((data.tensions[asked] as Dictionary)["title"])
		"state_tag_present":
			return "il mondo porta %s" % AssetText.sign_word(str(condition.get("tag", "")), data)
		"any_of":
			var one: Array = []
			for inner in condition.get("conditions", []) as Array:
				var said: String = _when_it_comes(inner as Dictionary, data)
				if said != "" and not one.has(said):
					one.append(said)
			if not one.is_empty():
				return " oppure ".join(PackedStringArray(one))
	# Niente da generare: resta la frase d'autore, che almeno e' scritta per chi
	# gioca — e se porta un id lo prende la prova di D-339.
	return str(condition.get("label", ""))


static func _tension(tension: Dictionary) -> Dictionary:
	var face: Dictionary = _face("tension", str(tension["id"]), "MINI")
	face["title"] = str(tension["title"])
	# La velatura e' una regola e sta nel dato `visibility`: la carta la
	# dichiara da se', cosi' la descrizione resta racconto (D-099).
	# **In italiano** (D-339): `domain` e `relevant_asset_families` sono enum, e
	# stamparli minuscoli stampa inglese. Sulla Carestia si leggeva «domanda ·
	# survival» e «al Consiglio valgono: wealth, people, authority».
	face["subtitle"] = "domanda%s · %s" % [
		"" if str(tension["visibility"]) == "OPEN" else " velata",
		SignLabels.domain(str(tension["domain"])),
	]
	# La soglia e' il numero che sta sulla traccia: la carta la ripete perche' la
	# traccia e' dall'altra parte del tavolo.
	face["corner"] = str(int(tension["threshold"]))
	# **Niente racconto sulla carta Domanda** (D-341). La `description` e' voce
	# d'autore — *«Non e' ancora fame. E' il calcolo, fatto a voce bassa, di
	# quanto manchi alla fame»* — ed e' il primo blocco che un giocatore incontra
	# su una carta che deve dirgli **quando la domanda si scalda**. E' la stessa
	# scelta di D-340 sulla carta Asset: il racconto resta nel dato, lo legge il
	# brief d'arte, e sulla carta ogni riga e' una regola.
	face["body"] = []
	# **SI ACCENDE QUANDO, sulla carta** (D-337). Fino alla 0.1.301 la faccia
	# stampata portava `triggers`, che e' prosa d'autore — *«Ogni raccolto
	# mancato nella Valle Verde»* — e un giocatore la legge senza sapere quando
	# la Tensione sale. La regola vera esiste da D-330, e' scritta in segni, il
	# motore la esegue, e **non era stampata da nessuna parte**: la carta diceva
	# la frase che non si puo' giocare e nascondeva quella che si gioca.
	#
	# Lo scambio toglie anche 1.559 caratteri dal mazzo: la regola in segni e'
	# piu' corta della prosa che sostituisce.
	#
	# Le 13 Tensioni senza casella tengono la prosa, perche' per loro vale
	# ancora il ponte di D-261 e non c'e' altro da stampare.
	var rules: Array = tension.get("heats_when", []) as Array
	var rise: String = ""
	if rules.is_empty():
		rise = "SI ACCENDE QUANDO  %s" % " ".join(PackedStringArray(tension.get("triggers", [])))
	else:
		var said: Array = []
		for rule in rules:
			said.append(str((rule as Dictionary).get("text", "")))
		rise = "SI ACCENDE QUANDO  %s" % " · ".join(PackedStringArray(said))
	face["notes"] = [
		rise,
		"SI RAFFREDDA  %s" % " ".join(PackedStringArray(tension.get("decrease_rules", []))),
		"AL CONSIGLIO VALGONO  %s" % ", ".join(PackedStringArray(
			(tension["relevant_asset_families"] as Array).map(
				func(f: Variant) -> String: return SignLabels.family(str(f))
			)
		)),
	]
	face["footer"] = str(tension["id"])
	return face


## La scheda del Consiglio che una Tensione apre: la domanda, le proposte con
## cosa lasciano, e le dodici caselle. La riga di ogni proposta e' la stessa che
## D-336 ha fatto dire il vero — fino alla 0.1.301 diceva «dove si discute»
## anche quando la cosa succedeva altrove.
static func _council(tension: Dictionary, data: RefCounted) -> Dictionary:
	var face: Dictionary = _face("council", str(tension["id"]), "TAROT")
	face["title"] = str(tension["title"])
	face["subtitle"] = "il Consiglio che questa domanda apre"
	# **Perche' due domande** (D-341). Il committente, davanti alla scheda: *«due
	# domande? Perche' due»*. La ragione era scritta e non stampata: undici
	# domande su ventitre' portano una `eligibility` con la sua `label` — «La
	# Carestia e' al limite» — e la scheda la buttava via. Una domanda che
	# compare senza una ragione visibile e' una domanda che al tavolo non si sa
	# quando fare.
	var council: Dictionary = tension.get("council", {}) as Dictionary
	var body: Array = []
	for entry in council.get("questions", []) as Array:
		var question: Dictionary = entry
		var asked: String = CouncilText.speak(str(question.get("text", "")))
		var needs: Array = CouncilText.needs_of(question.get("eligibility", []) as Array)
		if not needs.is_empty():
			asked += "  — solo se: %s" % " e ".join(PackedStringArray(needs))
		body.append(asked)
	face["body"] = body

	# **Le caselle, una per riga, e sono tutta la scheda.**
	#
	# *«I costi e benefici dove sono?»* — in fondo, dopo quattro proposte in
	# prosa, e tutte e sei schiacciate in un'unica riga separata da punti.
	#
	# Le proposte scritte **non sono piu' su questa scheda**, e non e' una scelta
	# di gusto: e' una misura. Rimesse le caselle al loro posto — in cima, una
	# per riga, che e' come si legge un elenco da cui si sceglie — le proposte
	# non ci stanno piu': **due schede su dodici sfondano il bordo** e La
	# Carestia scende al 74%, il pavimento sotto cui il corpo non si legge. E non
	# ci stanno nemmeno senza la loro frase: provato, resta una scheda fuori.
	#
	# Sulla scheda resta la grammatica del tavolo (D-280): la domanda, e le
	# dodici caselle con cui si risolve. **Cosa si perde e' dichiarato**: le
	# proposte che l'app risolve fanno cose che nessuna casella sa dire — «la
	# Foresta va al grado 2», «il rivale entra in una Regione confinante» — ed e'
	# esattamente il 65% misurato in ISSUES 89. Finche' quella voce e' aperta, il
	# tavolo e l'app non risolvono lo stesso Consiglio, e la scheda dice quello
	# che il tavolo puo' fare. Le proposte restano intere, col loro effetto, in
	# `docs/CATALOGO_CONSIGLI.md`.
	var physical: Dictionary = tension.get("physical", {}) as Dictionary
	for pair in [["benefits", "SI OTTIENE"], ["costs", "SI PAGA"], ["failure", "SE CADE"]]:
		var voices: Array = physical.get(str(pair[0]), []) as Array
		if voices.is_empty():
			continue
		face["notes"].append(str(pair[1]))
		for voice in voices:
			face["notes"].append("· %s" % str((voice as Dictionary).get("text", "")))
	face["footer"] = str(tension["id"])
	return face


static func _destiny(destiny: Dictionary, data: RefCounted) -> Dictionary:
	var face: Dictionary = _face("destiny", str(destiny["id"]), "TAROT")
	face["title"] = str(destiny["title"])
	var owner_id: String = str(destiny["entity_id"])
	if owner_id == "$self":
		# Il Destino condivisibile (D-115) non ha una casa in calce: la carta
		# dice a chi appartiene nel momento in cui qualcuno lo giura.
		face["subtitle"] = "per chi lo giura"
	else:
		face["subtitle"] = str(data.entities[owner_id]["name"]) if data.entities.has(owner_id) else owner_id
	# **Niente racconto** (D-344), come su Asset e Domanda: la scala e' la carta,
	# e la `description` era il primo blocco che si leggeva su un pezzo che si
	# guarda per contare quanto manca.
	face["body"] = []
	# La scala per intero, clausola per clausola: e' la carta che un giocatore
	# guarda piu' di ogni altra, e la guarda per contare quanto gli manca.
	var rungs: Array = []
	# **I tre gradini in italiano** (D-345): si leggeva «MINIMUM», «VICTORY»,
	# «TRIUMPH» sul tarocco che una casa guarda per contare quanto le manca —
	# tre parole interne su una carta da giocatore, la stessa cosa che D-339 ha
	# tolto da tutte le altre facce.
	const STEPS: Dictionary = {
		"minimum": "SOGLIA", "victory": "VITTORIA", "triumph": "TRIONFO",
	}
	for level in ["minimum", "victory", "triumph"]:
		var rung: Dictionary = destiny[level]
		var clauses: Array = []
		for condition in rung["conditions"]:
			clauses.append(str((condition as Dictionary).get("label", condition["type"])))
		rungs.append("%s  %s: %s" % [
			str(STEPS[level]), str(rung["label"]), " · ".join(PackedStringArray(clauses)),
		])
	face["notes"] = rungs
	face["footer"] = str(destiny["id"])
	face["art_prompt_key"] = str(destiny.get("art_prompt_key", ""))
	# Sta dietro il paravento (COMPONENTS §5): il foglio la stampa, l'anteprima la
	# marca, e chi la stampa sa che non va lasciata sul tavolo.
	face["secret"] = true
	return face


static func _entity(entity: Dictionary, data: RefCounted) -> Dictionary:
	var face: Dictionary = _face("entity", str(entity["id"]), "TAROT")
	face["title"] = str(entity["name"])
	# **In italiano** (D-339): archetipo e bisogno sono enum, e si leggeva
	# «people · vuole survival» sul tarocco che resta in vista tutta la partita.
	face["subtitle"] = "%s · vuole %s" % [
		SignLabels.archetype(str(entity["archetype"])),
		SignLabels.need(str(entity["need"])),
	]
	# **Niente racconto** (D-344): il tarocco della Casata resta in vista tutta
	# la partita e deve dire cosa la casa **sa fare** e cosa **vuole lasciare**.
	face["body"] = []
	var values: Array = []
	var actions: Dictionary = entity["action_values"]
	var names: Array = actions.keys()
	names.sort()
	for action in names:
		# I verbi, non i loro nomi interni: si leggeva «acquire 3 · claim 1».
		values.append("%s %d" % [SignLabels.action(str(action)), int(actions[action])])
	face["notes"] = ["SA FARE  %s" % " · ".join(PackedStringArray(values))]
	# **Cosa questa casa vuole lasciare, e cosa diventa se non ce la fa**
	# (D-288 e D-290). La strategia dichiarata stava in un file che leggevano il
	# cervello e lo schermo; sul tavolo fisico non stava da nessuna parte, e una
	# soglia che nomina dei segni che non sono stampati accanto sarebbe un
	# rimando al manuale. Il tarocco della Casata resta in vista tutta la
	# partita: e' il suo posto.
	for line in _house_promise(entity, data):
		face["notes"].append(line)
	# **Non** il Destino: quello e' una carta a parte e sta dietro il paravento.
	# Una carta Entity con sopra l'obiettivo del suo giocatore sarebbe il modo
	# piu' rapido di rendere pubblico l'unico segreto che regge il gioco.
	face["art_prompt_key"] = str(entity.get("art_prompt_key", ""))
	face["footer"] = str(entity["id"])
	return face


## Le due righe della carta Casata che vengono dal profilo strategico: quello
## che la casa vuole lasciare, e la porta del tempo che quei segni tiene chiusa.
## Vuote per una casa senza profilo — la scatola ne ha otto e i profili sono
## quattro.
static func _house_promise(entity: Dictionary, data: RefCounted) -> Array:
	var out: Array = []
	if data == null:
		return out
	var profiles: Variant = data.get("entity_profiles")
	if profiles == null:
		return out
	# La carta di una vita porta l'id della vita; il profilo e' della casa.
	var house_id: String = str(entity.get("id", ""))
	var lives: Array = entity.get("incarnations", []) as Array
	var now: int = 0
	for index in range(lives.size()):
		if str((lives[index] as Dictionary).get("id", "")) == house_id:
			now = index
	if house_id.begins_with("INC_"):
		for entity_id in data.entities:
			for life in (data.entities[str(entity_id)] as Dictionary).get("incarnations", []):
				if str((life as Dictionary).get("id", "")) == house_id:
					house_id = str(entity_id)
	var profile: Variant = (profiles as Dictionary).get(house_id)
	if profile == null:
		return out
	var wanted: PackedStringArray = PackedStringArray()
	for voice in (profile as Dictionary).get("wants", []) as Array:
		wanted.append(SignLabels.label(str((voice as Dictionary).get("tag", "")), data))
	if not wanted.is_empty():
		out.append("VUOI LASCIARE  %s" % " · ".join(wanted))
	for index in range(now + 1, lives.size()):
		var door: Dictionary = (lives[index] as Dictionary).get("also_enters", {}) as Dictionary
		if door.is_empty():
			continue
		out.append("SE NON CE LA FAI  dopo %d anni con meno di %d di questi segni: %s" % [
			int(door.get("after_years", 0)), int(door.get("holds_at_least", 1)),
			str((lives[index] as Dictionary).get("name", "")),
		])
		break
	return out


## Come si legge un varco sulla faccia stampata: il lato, non la lettera.
const EDGE_WORDS: Dictionary = {
	"N": "alto", "E": "destra", "S": "basso", "O": "sinistra",
}


static func _region(region: Dictionary, data: RefCounted) -> Dictionary:
	var face: Dictionary = _face("region", str(region["id"]), "TILE")
	face["title"] = str(region["name"])
	# **Due conti diversi, e la tessera li diceva a meta'** (D-365, ISSUES 116).
	# «posti» erano solo quelli delle pedine; dove si posa una Pietra non lo
	# diceva nessuno, ed e' il pezzo che la struttura fisica mette sulla tessera.
	face["subtitle"] = "%s · %d pedine · %d Pietre" % [
		str(BIOMES.get(str(region["biome"]), str(region["biome"]).to_lower())),
		int(region["presence_slots"]),
		int(region["build_slots"]),
	]
	# **I segni della tessera** (D-344). Una carta Azione si gioca «su un luogo
	# con #granaio»: senza i segni stampati sulla tessera quel bersaglio non si
	# puo' trovare col dito, e la carta e' ingiocabile. Trentadue segni sulle
	# dieci tessere, e non ne era stampato **nessuno**.
	face["body"] = []
	var segni: Array = []
	for tag in region.get("tags", []) as Array:
		var word: String = AssetText.sign_word(str(tag), data)
		if word != "" and not segni.has(word):
			segni.append(word)
	face["notes"] = []
	# **I varchi, stampati sulla tessera** (D-390, parola del committente). Una
	# tessera si posa girandola finche' un varco combacia con quello della
	# tessera accanto, e da li' in poi «si puo' passare» si legge guardando i
	# due lati. Senza questa riga la regola vivrebbe solo nell'app — che e'
	# esattamente quello che la direzione di questo progetto vieta.
	face["edges"] = (region.get("edges", []) as Array).duplicate()
	var varchi: Array = []
	for side in (face["edges"] as Array):
		varchi.append(str(EDGE_WORDS.get(str(side), str(side))))
	if not varchi.is_empty():
		face["notes"].append("VARCHI  %s" % " · ".join(PackedStringArray(varchi)))
	if not segni.is_empty():
		face["notes"].append("SEGNI  %s" % " · ".join(PackedStringArray(segni)))
	# Le famiglie in italiano (D-339): la tessera diceva «fonti: authority, force».
	# E **quali** Pietre ci stanno: senza questa riga un giocatore sa che ha due
	# spazi e non sa cosa metterci. La lista si ricava dai biomi che ogni Pietra
	# dichiara, cioe' dalla stessa regola che il motore fa rispettare.
	var ci_stanno: Array = []
	var tipi: Array = data.structure_types.keys()
	tipi.sort()
	for type_id in tipi:
		var tipo: Dictionary = data.structure_types[str(type_id)]
		if not bool(tipo["owned"]):
			continue
		if (tipo["biomes"] as Array).has(str(region["biome"])):
			ci_stanno.append(str(tipo["name"]).to_lower())
	if not ci_stanno.is_empty():
		face["notes"].append("CI STANNO  %s" % " · ".join(PackedStringArray(ci_stanno)))
	face["notes"].append("FONTI  %s" % ", ".join(PackedStringArray(
		(region.get("asset_sources", []) as Array).map(
			func(f: Variant) -> String: return SignLabels.family(str(f))
		)
	)))
	face["art_prompt_key"] = str(region.get("art_prompt_key", ""))
	face["terrain"] = str(region["biome"])
	face["footer"] = str(region["id"])
	return face
