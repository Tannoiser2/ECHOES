extends RefCounted
## Confluence resolution maths - Strategy "baseline_v0" (§12.3, appendix A5),
## riscritta a due domande (D-467, D-472).
##
## Pure functions over plain data: no world access, no RNG, no side effects.
## Swapping this file for another Strategy changes the maths and nothing else.
##
## Il voto e' **contro il mucchio**, senza dado: una parte vince se supera
## l'altra *e* arriva ai gettoni caduti sulla domanda. Le fasce di A sul
## margine su B sono quelle di sempre:
##   M <= 1         Success with Cost
##   2 <= M <= 4    Success
##   M >= 5         Decisive Success
## B che vince e' una fascia sua (COUNTER); nessuna che arriva e' FAILURE.

const STRATEGY_ID: String = "baseline_v0"

const FAILURE: String = "FAILURE"
const SUCCESS_WITH_COST: String = "SUCCESS_WITH_COST"
const SUCCESS: String = "SUCCESS"
const DECISIVE: String = "DECISIVE_SUCCESS"
## **Vince la controdomanda** (D-467, giro 3): la parte B ha superato la A e
## il mucchio. Per chi propone e' una sconfitta, per il mondo e' una decisione:
## si applicano l'esito di base e le caselle della domanda B.
const COUNTER: String = "COUNTER"


## The value one committed Asset contributes.
##
## Full strength when its family is relevant for the Tension, 1 otherwise: this
## is the whole reason preparation matters (§9). confluence_modifier applies
## afterwards.
static func asset_value(asset: Dictionary, relevant_families: Array, front: String) -> int:
	var family: String = str(asset["family"])
	var value: int = int(asset["strength"]) if relevant_families.has(family) else 1
	var modifier: Dictionary = asset.get("confluence_modifier", {"kind": "NONE", "value": 0})
	match str(modifier.get("kind", "NONE")):
		"FLAT_BONUS":
			value += int(modifier["value"])
		"RELEVANT_BONUS":
			if relevant_families.has(family):
				value += int(modifier["value"])
		"OPPOSE_BONUS":
			if front == "OPPOSE":
				value += int(modifier["value"])
	return maxi(0, value)


static func front_total(asset_ids: Array, assets: Dictionary, relevant: Array, front: String) -> int:
	var total: int = 0
	for asset_id in asset_ids:
		var asset: Variant = assets.get(str(asset_id))
		if asset != null:
			total += asset_value(asset, relevant, front)
	return total


## Il successo di **chi propone**: la sua domanda e' passata. La controdomanda
## che vince (COUNTER) e' una decisione del tavolo, non un successo di A.
static func is_success(outcome: String) -> bool:
	return outcome != FAILURE and outcome != COUNTER


## **Il voto a tre esiti, contro il mucchio** (D-467). Niente dado: una parte
## vince se supera l'altra **e** arriva al mucchio dei gettoni caduti sulla
## domanda; a parita', o se nessuna ci arriva, non passa nessuna. Le fasce di
## A restano quelle di sempre sul margine su B, cosi' il conto degli esiti si
## legge come prima; B che vince e' una fascia sua.
static func two_sides_outcome(a_total: int, b_total: int, pile: int) -> String:
	if a_total > b_total and a_total >= pile:
		var margin: int = a_total - b_total
		if margin >= 5:
			return DECISIVE
		if margin >= 2:
			return SUCCESS
		return SUCCESS_WITH_COST
	if b_total > a_total and b_total >= pile:
		return COUNTER
	return FAILURE


## Quale parte ha vinto: "A", "B", o "" se non e' passata nessuna.
static func winner_of(outcome: String) -> String:
	if outcome == COUNTER:
		return "B"
	return "A" if is_success(outcome) else ""


## **Le carte delle due parti, contate** (§12.3). Il proponente argomenta
## sempre per la sua domanda; chi sta con A sostiene, chi sta con B si
## oppone; chi non ha preso posizione non conta. L'esito lo dice
## `two_sides_outcome`, col mucchio: qui solo i totali, cosi' l'aritmetica si
## legge — e il chiamante ci somma le pedine (D-471).
##
## `stances`: entity_id -> {stance}
## `commits`: entity_id -> [asset_id, ...]
static func resolve(
	proponent_id: String,
	stances: Dictionary,
	commits: Dictionary,
	assets: Dictionary,
	relevant_families: Array,
	support_bonus: int = 0,
	oppose_bonus: int = 0
) -> Dictionary:
	var support_assets: Array = []
	var oppose_assets: Array = []

	support_assets.append_array(commits.get(proponent_id, []))

	for entity_id in stances:
		if str(entity_id) == proponent_id:
			continue
		var committed: Array = commits.get(entity_id, [])
		match str(stances[entity_id].get("stance", "ABSTAIN")):
			"SUPPORT":
				support_assets.append_array(committed)
			"OPPOSE":
				oppose_assets.append_array(committed)
			_:
				pass

	# I fronti che valgono di più (D-125, STANCE_MODIFIER): il chiamante li ha
	# già pesati per seggio; qui entrano nel totale, e solo se il fronte esiste
	# - un bonus su zero carte sarebbe un voto gratis, e resta zero.
	var support_total: int = front_total(support_assets, assets, relevant_families, "SUPPORT")
	var oppose_total: int = front_total(oppose_assets, assets, relevant_families, "OPPOSE")
	if support_total > 0:
		support_total += support_bonus
	if oppose_total > 0:
		oppose_total += oppose_bonus

	return {
		"strategy": STRATEGY_ID,
		"support_total": support_total,
		"oppose_total": oppose_total,
		"support_assets": support_assets,
		"oppose_assets": oppose_assets,
	}
