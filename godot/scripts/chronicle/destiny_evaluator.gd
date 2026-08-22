extends RefCounted
## Destiny evaluation at the end of a Chronicle (§14).
##
## No overall score, no ranking: every player gets their own level, and more
## than one can reach Victory. Levels are cumulative - Triumph requires the
## Victory and Minimum conditions too, so a "Triumph" always contains a
## "Victory". The evidence list keeps *how* it was reached, for the Legacy
## propagation that arrives with the World Engine in 0.3.

const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")

const LEVELS: Array = ["minimum", "victory", "triumph"]
const LEVEL_NAMES: Array = ["MINIMUM", "VICTORY", "TRIUMPH"]

var world: Dictionary
var data: RefCounted
var conditions: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted) -> void:
	world = p_world
	data = p_data
	conditions = ConditionEvaluator.new(p_world, p_data)


func evaluate_all() -> Dictionary:
	var results: Dictionary = {}
	for entity_id in world["turn_order"]:
		var definition: Variant = data.entities.get(str(entity_id))
		if definition == null:
			continue
		# The Destiny is state, not definition: a house that got what it wanted
		# last Chronicle is chasing the next thing now (D-045).
		var seat: Dictionary = (world["entities"] as Dictionary).get(str(entity_id), {})
		var destiny_id: String = str(seat.get("destiny_id", definition["destiny_id"]))
		results[str(entity_id)] = evaluate(destiny_id, str(entity_id))
	return results


## `holder` e' chi ha giurato questo Destino. Per un Destino identitario
## coincide con l'entity_id scritto nel dato; per un Destino condivisibile
## (voce 20, D-115) l'entity_id e' "$self" e le clausole si risolvono su chi
## lo giura: la stessa carta, un'ambizione per ciascuno.
func evaluate(destiny_id: String, holder: String = "") -> Dictionary:
	var destiny: Dictionary = data.destinies[destiny_id]
	var entity_id: String = str(destiny["entity_id"])
	if entity_id == "$self":
		entity_id = holder
	var context: Dictionary = {"self": entity_id}

	# La Chronicle puo' dichiarare che i gradini non ci sono piu' (D-198): allora
	# non si guarda fin dove si e' saliti, si contano gli obiettivi avverati.
	var rules: Dictionary = _objective_rules()
	if not rules.is_empty():
		return _by_objectives(destiny_id, destiny, entity_id, context, rules)

	var achieved: Dictionary = {}
	var reached: String = "NONE"
	var evidence: Array = []
	# I conti rimasti aperti (D-087): le clausole negate, come dati e non come
	# prosa. Sono la meta' strutturata delle evidence - quello che una casa
	# voleva e non ha avuto - ed e' cio' che il motore 0.3 legge per far
	# nascere l'era dopo dai conti di quella prima.
	var unmet: Array = []
	var cumulative: bool = true

	for i in range(LEVELS.size()):
		var level: Dictionary = destiny[LEVELS[i]]
		var holds: bool = conditions.all_hold(level["conditions"], context)
		achieved[LEVEL_NAMES[i]] = holds
		for condition in level["conditions"]:
			# Una clausola che offre una scelta porta con se' le sue strade
			# (D-167): la prova dice quante ne servivano e quali sono cadute.
			for line in conditions.describe_all(condition, context):
				evidence.append("%s %s" % [LEVEL_NAMES[i], str(line)])
			if not conditions.holds(condition, context):
				unmet.append((condition as Dictionary).duplicate(true))
				# E se quello che manca e' una scelta, mancano **delle strade**: il
				# conto aperto e' quello, non «tre di queste cinque». Senza,
				# spostare meta' delle clausole dentro le scelte avrebbe tolto un
				# livello di dettaglio proprio ai conti che l'era dopo eredita
				# (D-087) — la meta' strutturata delle evidence.
				for road in conditions.open_roads(condition, context):
					unmet.append(road)
		# A higher level only counts while every lower one still holds.
		cumulative = cumulative and holds
		if cumulative:
			reached = str(LEVEL_NAMES[i])

	for echo in world["echo_log"]:
		if (echo["participants"] as Array).has(entity_id):
			evidence.append("ECHO %s: %s" % [str(echo["echo_id"]), str(echo["summary"])])

	return {
		"destiny_id": destiny_id,
		"entity_id": entity_id,
		"level": reached,
		"levels": achieved,
		"evidence": evidence,
		"unmet": unmet,
	}


## Le regole degli obiettivi, se la Chronicle le dichiara. Vuote, e tutto il
## resto del file non le vede nemmeno: la scala cumulativa resta quella di sempre.
func _objective_rules() -> Dictionary:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return {}
	return (chronicle as Dictionary).get("objectives", {}) as Dictionary


## Gli obiettivi di un seggio, con quelli che tengono gia' spuntati: il palese
## per primo, poi i suoi nascosti. Lista vuota se la Chronicle non li dichiara.
##
## E' l'unico posto dove si decide **quali sono i quattro**: il verbale di fine
## anno, il pannello del giocatore e la console leggono tutti di qui. Due letture
## diverse dello stesso seggio erano il difetto piu' facile da introdurre, ed e'
## esattamente quello che D-194 ha gia' pagato una volta con la mano.
func objectives_of(entity_id: String) -> Array:
	var rules: Dictionary = _objective_rules()
	if rules.is_empty():
		return []
	var seat: Dictionary = (world["entities"] as Dictionary).get(entity_id, {}) as Dictionary
	var destiny_id: String = str(seat.get("destiny_id", ""))
	if destiny_id == "" or not data.destinies.has(destiny_id):
		return []
	return _taken_by(destiny_id, entity_id, {"self": entity_id}, rules)


func _taken_by(
	destiny_id: String, entity_id: String, context: Dictionary, rules: Dictionary
) -> Array:
	var destiny: Dictionary = data.destinies[destiny_id]
	var public_level: String = str(rules.get("public_from", "victory"))
	var out: Array = [{
		"id": destiny_id,
		"title": str(destiny["title"]),
		"label": str((destiny[public_level] as Dictionary)["label"]),
		"public": true,
		"met": conditions.all_hold((destiny[public_level] as Dictionary)["conditions"], context),
	}]
	var seat: Dictionary = (world["entities"] as Dictionary).get(entity_id, {}) as Dictionary
	for objective_id in seat.get("objectives", []):
		var objective: Variant = data.objectives.get(str(objective_id))
		if objective == null:
			continue
		var record: Dictionary = objective as Dictionary
		out.append({
			"id": str(objective_id),
			"title": str(record["title"]),
			"label": str(record["label"]),
			"public": false,
			"met": conditions.all_hold(record["conditions"], context),
		})
	return out


## Quattro obiettivi al posto di tre gradini (D-198).
##
## Uno **palese**, che e' il Destino giurato letto al gradino che la Chronicle
## dichiara — la casa e' venuta al tavolo per quello, e lo sanno tutti. Tre
## **nascosti**, pescati all'apertura e scritti sul seggio.
##
## Il livello non sparisce: sarebbe stato il modo piu' rapido per rompere il
## verbale, il pannello, il libro della saga e il punteggio di campagna, che
## leggono tutti un livello. Si **deriva** dal conto, con la tabella che la
## Chronicle scrive (`levels`), e resta cumulativo verso il basso: chi arriva a
## VICTORY ha tenuto anche MINIMUM, perche' e' quello che quella parola ha
## sempre voluto dire.
func _by_objectives(
	destiny_id: String,
	destiny: Dictionary,
	entity_id: String,
	context: Dictionary,
	rules: Dictionary
) -> Dictionary:
	var public_level: String = str(rules.get("public_from", "victory"))
	var taken: Array = []
	var evidence: Array = []
	var unmet: Array = []

	var public_conditions: Array = (destiny[public_level] as Dictionary)["conditions"]
	taken = _taken_by(destiny_id, entity_id, context, rules)
	for condition in public_conditions:
		for line in conditions.describe_all(condition, context):
			evidence.append("PALESE %s" % [str(line)])
		if not conditions.holds(condition, context):
			unmet.append((condition as Dictionary).duplicate(true))
			for road in conditions.open_roads(condition, context):
				unmet.append(road)

	var seat: Dictionary = (world["entities"] as Dictionary).get(entity_id, {}) as Dictionary
	for objective_id in seat.get("objectives", []):
		var objective: Variant = data.objectives.get(str(objective_id))
		if objective == null:
			continue
		var record: Dictionary = objective as Dictionary
		for condition in record["conditions"]:
			for line in conditions.describe_all(condition, context):
				evidence.append("NASCOSTO %s" % [str(line)])
			if not conditions.holds(condition, context):
				unmet.append((condition as Dictionary).duplicate(true))
				for road in conditions.open_roads(condition, context):
					unmet.append(road)

	var met: int = 0
	for entry in taken:
		if bool((entry as Dictionary)["met"]):
			met += 1

	var ladder: Array = rules.get("levels", ["NONE"]) as Array
	var reached: String = str(ladder[mini(met, ladder.size() - 1)])
	# Il livello raggiunto contiene quelli sotto: e' cosi' che lo legge tutto
	# quello che gia' esiste, e cambiarlo qui avrebbe cambiato il significato
	# della parola invece della regola.
	var achieved: Dictionary = {}
	var rung: int = LEVEL_NAMES.find(reached)
	for i in range(LEVEL_NAMES.size()):
		achieved[LEVEL_NAMES[i]] = rung >= i

	for echo in world["echo_log"]:
		if (echo["participants"] as Array).has(entity_id):
			evidence.append("ECHO %s: %s" % [str(echo["echo_id"]), str(echo["summary"])])

	return {
		"destiny_id": destiny_id,
		"entity_id": entity_id,
		"level": reached,
		"levels": achieved,
		"evidence": evidence,
		"unmet": unmet,
		"objectives": taken,
		"objectives_met": met,
	}


## One-line summary for the Chronicle End log.
func describe(result: Dictionary) -> String:
	var destiny: Dictionary = data.destinies[str(result["destiny_id"])]
	var seat: Dictionary = (world["entities"] as Dictionary).get(str(result["entity_id"]), {})
	var who: String = str(seat.get("name", data.entities[str(result["entity_id"])]["name"]))
	# Con gli obiettivi la riga non puo' essere l'etichetta di un gradino: il
	# livello e' **derivato** da un conto, e stampare «Il regno decide» a chi
	# quel Destino non l'ha chiuso sarebbe la bugia piu' facile di tutta la
	# regola (D-198). Si dice il conto, e quali.
	if result.has("objectives"):
		var taken: Array = result["objectives"] as Array
		var names: Array = []
		for entry in taken:
			var record: Dictionary = entry as Dictionary
			if bool(record["met"]):
				names.append(str(record["label"]))
		var how: String = " · ".join(names) if not names.is_empty() else "niente"
		var many: int = int(result["objectives_met"])
		return "%s - %s: %d %s su %d (%s)" % [
			who, str(result["level"]), many,
			"obiettivo" if many == 1 else "obiettivi", taken.size(), how
		]
	var label: String = "nessun livello raggiunto"
	match str(result["level"]):
		"MINIMUM":
			label = str(destiny["minimum"]["label"])
		"VICTORY":
			label = str(destiny["victory"]["label"])
		"TRIUMPH":
			label = str(destiny["triumph"]["label"])
	return "%s - %s: %s" % [who, str(result["level"]), label]
