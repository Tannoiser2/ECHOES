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
const DECKS: Array = ["asset", "echo", "tension", "destiny", "entity"]
const TILES: Array = ["region"]

## Come si chiamano al tavolo, che e' come vanno chiamati ovunque li si nomini:
## sul foglio di stampa, nell'anteprima e nel riepilogo dell'export.
const DECK_LABELS: Dictionary = {
	"asset": "carte Asset", "echo": "carte Echo", "tension": "carte Domanda",
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
		"destiny": return data.destinies
		"entity": return data.entities
		"region": return data.regions
	return {}


## Una faccia. `copies` e' quante volte va stampata: sugli Asset e' `deck_copies`
## (D-040), su tutto il resto e' una.
static func of(deck: String, id: String, data: RefCounted) -> Dictionary:
	var item: Dictionary = _source(deck, data).get(id, {})
	if item.is_empty():
		return {}
	match deck:
		"asset": return _asset(item)
		"echo": return _echo(item, data)
		"tension": return _tension(item)
		"destiny": return _destiny(item, data)
		"entity": return _entity(item)
		"region": return _region(item)
	return {}


static func _face(deck: String, id: String, shape: String) -> Dictionary:
	return {
		"deck": deck, "id": id, "shape": shape, "title": "", "subtitle": "",
		"accent": NEUTRAL, "corner": "", "body": [], "notes": [], "footer": "",
		"art_prompt_key": "", "copies": 1, "secret": false,
		# Vuoto tranne che sulle Regioni: quelle non hanno un segnaposto generico
		# ma il proprio terreno, generato dal bioma (D-057).
		"terrain": "",
	}


static func _asset(asset: Dictionary) -> Dictionary:
	var family: String = str(asset["family"])
	var face: Dictionary = _face("asset", str(asset["id"]), "CARD")
	face["title"] = str(asset["title"])
	face["subtitle"] = "%s · %s" % [family.to_lower(), str(RARITY.get(str(asset["rarity"]), ""))]
	face["accent"] = family_colour(family)
	# La forza sta nell'angolo perche' e' l'unico numero che si legge con la carta
	# ancora in mano, a ventaglio.
	face["corner"] = str(int(asset["strength"]))
	face["body"] = [str(asset.get("rules_text", ""))]
	# La riga meccanica e' quella che il resolver legge davvero, chiesta ad
	# `AssetText` e non riscritta: una carta non puo' stampare una cosa e farne
	# un'altra (D-042).
	face["notes"] = [AssetText.note(asset), str(asset.get("acquisition_rule", ""))]
	face["art_prompt_key"] = str(asset["art_prompt_key"])
	face["copies"] = int(asset.get("deck_copies", 1))
	face["footer"] = str(asset["id"])
	return face


static func _echo(card: Dictionary, data: RefCounted) -> Dictionary:
	var family: String = str(card["dramatic_family"])
	var described: Dictionary = DRAMA.get(family, {"colour": NEUTRAL, "label": family})
	var face: Dictionary = _face("echo", str(card["id"]), "CARD")
	face["title"] = str(card["title"])
	var function_id: String = str(card["function_id"])
	face["subtitle"] = "%s · funzione di Propp: %s" % [
		str(described["label"]).split(" —")[0], str(PROPP.get(function_id, function_id.to_lower())),
	]
	face["accent"] = str(described["colour"])
	face["body"] = [str(card["description"])]
	# Due delle ventiquattro convocano un Consiglio (§12.1 b): e' la carta che si
	# prende il tavolo, e sulla carta stampata dev'esserci scritto.
	var forced: Variant = card.get("forces_confluence_on", null)
	if forced != null and data.tensions.has(str(forced)):
		face["notes"] = ["Convoca un Consiglio su %s." % str(data.tensions[str(forced)]["title"])]
	face["art_prompt_key"] = str(card.get("art_prompt_key", ""))
	face["footer"] = str(card["id"])
	return face


static func _tension(tension: Dictionary) -> Dictionary:
	var face: Dictionary = _face("tension", str(tension["id"]), "CARD")
	face["title"] = str(tension["title"])
	face["subtitle"] = "domanda · %s" % str(tension["domain"]).to_lower()
	# La soglia e' il numero che sta sulla traccia: la carta la ripete perche' la
	# traccia e' dall'altra parte del tavolo.
	face["corner"] = str(int(tension["threshold"]))
	face["body"] = [str(tension.get("description", ""))]
	face["notes"] = [
		"sale: %s" % " ".join(PackedStringArray(tension.get("triggers", []))),
		"scende: %s" % " ".join(PackedStringArray(tension.get("decrease_rules", []))),
		"al Consiglio valgono: %s" % ", ".join(
			PackedStringArray(tension["relevant_asset_families"])
		).to_lower(),
	]
	face["footer"] = str(tension["id"])
	return face


static func _destiny(destiny: Dictionary, data: RefCounted) -> Dictionary:
	var face: Dictionary = _face("destiny", str(destiny["id"]), "CARD")
	face["title"] = str(destiny["title"])
	var owner_id: String = str(destiny["entity_id"])
	face["subtitle"] = str(data.entities[owner_id]["name"]) if data.entities.has(owner_id) else owner_id
	face["body"] = [str(destiny.get("description", ""))]
	# La scala per intero, clausola per clausola: e' la carta che un giocatore
	# guarda piu' di ogni altra, e la guarda per contare quanto gli manca.
	var rungs: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var rung: Dictionary = destiny[level]
		var clauses: Array = []
		for condition in rung["conditions"]:
			clauses.append(str((condition as Dictionary).get("label", condition["type"])))
		rungs.append("%s — %s: %s" % [
			level.to_upper(), str(rung["label"]), " · ".join(PackedStringArray(clauses)),
		])
	face["notes"] = rungs
	face["footer"] = str(destiny["id"])
	# Sta dietro il paravento (COMPONENTS §5): il foglio la stampa, l'anteprima la
	# marca, e chi la stampa sa che non va lasciata sul tavolo.
	face["secret"] = true
	return face


static func _entity(entity: Dictionary) -> Dictionary:
	var face: Dictionary = _face("entity", str(entity["id"]), "CARD")
	face["title"] = str(entity["name"])
	face["subtitle"] = "%s · vuole %s" % [
		str(entity["archetype"]).to_lower(), str(entity["need"]).to_lower(),
	]
	face["body"] = [str(entity.get("description", ""))]
	var values: Array = []
	var actions: Dictionary = entity["action_values"]
	var names: Array = actions.keys()
	names.sort()
	for action in names:
		values.append("%s %d" % [str(action).to_lower(), int(actions[action])])
	face["notes"] = [" · ".join(PackedStringArray(values))]
	# **Non** il Destino: quello e' una carta a parte e sta dietro il paravento.
	# Una carta Entity con sopra l'obiettivo del suo giocatore sarebbe il modo
	# piu' rapido di rendere pubblico l'unico segreto che regge il gioco.
	face["art_prompt_key"] = str(entity.get("art_prompt_key", ""))
	face["footer"] = str(entity["id"])
	return face


static func _region(region: Dictionary) -> Dictionary:
	var face: Dictionary = _face("region", str(region["id"]), "TILE")
	face["title"] = str(region["name"])
	face["subtitle"] = "%s · %d posti" % [
		str(BIOMES.get(str(region["biome"]), str(region["biome"]).to_lower())),
		int(region["presence_slots"]),
	]
	face["body"] = [str(region.get("description", ""))]
	face["notes"] = ["fonti: %s" % ", ".join(
		PackedStringArray(region.get("asset_sources", []))
	).to_lower()]
	face["art_prompt_key"] = str(region.get("art_prompt_key", ""))
	face["terrain"] = str(region["biome"])
	face["footer"] = str(region["id"])
	return face
