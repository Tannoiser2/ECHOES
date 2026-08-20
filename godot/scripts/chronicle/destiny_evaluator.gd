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


## One-line summary for the Chronicle End log.
func describe(result: Dictionary) -> String:
	var destiny: Dictionary = data.destinies[str(result["destiny_id"])]
	var seat: Dictionary = (world["entities"] as Dictionary).get(str(result["entity_id"]), {})
	var who: String = str(seat.get("name", data.entities[str(result["entity_id"])]["name"]))
	var label: String = "nessun livello raggiunto"
	match str(result["level"]):
		"MINIMUM":
			label = str(destiny["minimum"]["label"])
		"VICTORY":
			label = str(destiny["victory"]["label"])
		"TRIUMPH":
			label = str(destiny["triumph"]["label"])
	return "%s - %s: %s" % [who, str(result["level"]), label]
