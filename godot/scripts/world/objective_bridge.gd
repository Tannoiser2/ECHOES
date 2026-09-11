extends RefCounted
## **Cosa un obiettivo chiede al mazzetto** — il ponte che mancava
## ([ISSUES 136](../../../docs/ISSUES.md#136), punto 5).
##
## Il mazzetto personale di [D-499](../../../docs/DECISIONS.md#d-499) si compone
## sulle **famiglie che la presenza raggiunge**: le tessere dove una casa sta
## dicono da quali mazzi pesca. E' una regola bella, e guarda una cosa sola: la
## mappa. Quello che la casa **vuole** — i tre obiettivi che l'anno le ha dato —
## non entra nel conto.
##
## Sei obiettivi su 19 chiedono un **gesto fatto quest'anno**, e un gesto lo fa
## una faccia di carta:
##
## | il gesto | la faccia che lo fa | perche' |
## |---|---|---|
## | RAISE_STONE | ACQUISIRE **che costruisce** | l'unico verbo che alza una Pietra (D-412) |
## | TAKE_GROUND | RIVENDICARE | `SET_CONTROL` esce da li' |
## | SPREAD | MUOVERE | una presenza si posa muovendola |
## | TIGHTEN_BOND | FORGIARE | il verbo dei rapporti (D-430) |
##
## E tre chiedono **carte di una famiglia in mano** (`asset_threshold`), che e'
## la stessa domanda detta con l'altra meta' del mazzo.
##
## La tabella sta qui e non in tre posti perche' la leggono in tre: la sonda che
## misura il buco, la composizione del mazzetto che lo tappa, e la prova che
## tiene ferma la corrispondenza. E `self_test()` va rossa il giorno in cui
## qualcuno aggiunge un gesto allo schema senza dire quale faccia lo serve —
## perche' quel giorno l'obiettivo nuovo sarebbe **decorazione**, e nessuno se
## ne accorgerebbe.

const SchemaDefs := preload("res://scripts/core/schema_defs.gd")

## Il gesto, e la faccia che lo sa fare.
const SERVED_BY: Dictionary = {
	"RAISE_STONE": "ACQUIRE",
	"TAKE_GROUND": "CLAIM",
	"SPREAD": "MOVE",
	"TIGHTEN_BOND": "FORGE",
}


## Cosa questo obiettivo chiede a chi lo prende, in termini di carte:
## `{"verbs": ["ACQUIRE"], "families": {"BONDS": 1}}`. Vuoto per gli obiettivi
## che guardano solo il mondo — e sono la maggior parte, giustamente: un
## obiettivo non deve essere una lista della spesa.
static func asks_of_deck(objective: Dictionary) -> Dictionary:
	var verbs: Array = []
	var families: Dictionary = {}
	for condition in (objective.get("conditions", []) as Array):
		_read_condition(condition as Dictionary, verbs, families)
	return {"verbs": verbs, "families": families}


static func _read_condition(condition: Dictionary, verbs: Array, families: Dictionary) -> void:
	var kind: String = str(condition.get("type", ""))
	# `any_of` e `some_of` portano dentro altre condizioni: un obiettivo che dice
	# «o questo o quello» chiede tutt'e due le strade, e il mazzetto che ne serve
	# una sola va bene lo stesso. Per questo entrano nella lista ma la
	# **garanzia** guarda se ne resta servita almeno una (vedi `missing_in`).
	for nested in (condition.get("conditions", []) as Array):
		_read_condition(nested as Dictionary, verbs, families)
	if kind == "did_this_year":
		var gesture: String = str(condition.get("gesture", ""))
		var verb: String = str(SERVED_BY.get(gesture, ""))
		if verb != "" and not verbs.has(verb):
			verbs.append(verb)
		return
	if kind == "asset_threshold":
		var family: String = str(condition.get("family", ""))
		# Un tetto («non piu' di cinque carte in mano») non chiede niente al
		# mazzetto: si rispetta buttando, non pescando.
		if family == "" or not condition.has("min"):
			return
		families[family] = maxi(int(families.get(family, 0)), int(condition["min"]))


## Questa carta sa fare quel verbo? Si guardano **le facce stampate**, che sono
## quelle che il motore gioca (`PolicyDecider.hand_plays`), e ACQUISIRE conta
## solo dove **costruisce**: la faccia che pesca una carta non alza una Pietra,
## ed e' la stessa riga che il cervello salta.
static func face_serves(asset: Dictionary, verb: String) -> bool:
	for face in ((asset.get("physical", {}) as Dictionary).get("actions", []) as Array):
		if str((face as Dictionary).get("template", "")) != verb:
			continue
		if verb == "ACQUIRE" and str((face as Dictionary).get("builds", "")) == "":
			continue
		return true
	return false


## Le carte del mucchio che sanno fare quel verbo.
static func cards_serving(pile: Array, data, verb: String) -> Array:
	var out: Array = []
	for asset_id in pile:
		var asset: Variant = data.assets.get(str(asset_id))
		if asset != null and face_serves(asset as Dictionary, verb):
			out.append(str(asset_id))
	return out


## Quante carte di quella famiglia ci sono nel mucchio.
static func cards_of_family(pile: Array, data, family: String) -> int:
	var count: int = 0
	for asset_id in pile:
		var asset: Variant = data.assets.get(str(asset_id))
		if asset != null and str((asset as Dictionary)["family"]) == family:
			count += 1
	return count


## **Cosa questo mazzetto non puo' dare a questo obiettivo**, in righe leggibili.
## Vuoto se l'obiettivo e' servito — o se non chiede niente di carte.
static func missing_in(pile: Array, objective: Dictionary, data) -> Array:
	var asks: Dictionary = asks_of_deck(objective)
	var out: Array = []
	for verb in (asks["verbs"] as Array):
		if cards_serving(pile, data, str(verb)).is_empty():
			out.append("nessuna carta che sappia %s" % str(verb))
	for family in (asks["families"] as Dictionary):
		var wanted: int = int((asks["families"] as Dictionary)[family])
		var have: int = cards_of_family(pile, data, str(family))
		if have < wanted:
			out.append("%s: ne chiede %d, nel mazzetto %d" % [str(family), wanted, have])
	return out


## **La guardia della tabella**: ogni gesto che lo schema conosce deve avere la
## sua faccia. Torna la lista di quelli che non ce l'hanno — vuota, e siamo a
## posto.
static func self_test() -> Array:
	var orphans: Array = []
	for gesture in SchemaDefs.GESTURES:
		if not SERVED_BY.has(str(gesture)):
			orphans.append(str(gesture))
	return orphans
