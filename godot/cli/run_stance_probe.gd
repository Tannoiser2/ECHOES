extends SceneTree
## Stance probe: why does nobody ever oppose? (O-6)
##
##   godot --headless --path godot --script res://cli/run_stance_probe.gd -- \
##       --runs=40 --seed=3000
##
## The balance probe says *that* Failure and Success-with-Cost are rare; it does
## not say why. Opposition is the only thing that can push a margin down, so if
## the table never opposes, the resolver never gets a chance to produce anything
## but Success. This probe opens the policy up and measures the one number that
## decides a stance: the score a proposition gets against each seat's Destiny.
##
## Per Confluence it records, for every non-proponent, the score and the stance
## that score produced - and, for every Effect in the proposition's Consequences,
## whether that Effect moved the score at all. The second tally is the important
## one: an Effect type that is never worth a single point is an axis of conflict
## the policy cannot see, no matter what the content says.
##
## Read-only. It plays the same games the balance probe plays and changes
## nothing about them.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## I seggi li dice la Chronicle: la sonda guardava solo la prima saga, e la
## seconda e' quella che di clausole sulle Tensioni non ne aveva nessuna.
var seats: Array = []


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 3000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	if not data.chronicles.has(chronicle_id):
		printerr("nessuna Chronicle '%s'" % chronicle_id)
		quit(4)
		return
	# Il tavolo del primo seme, tenuto per tutte le partite (D-213).
	seats = GameSession.seats_for(data, chronicle_id, first_seed)

	# stance -> count, score -> count, effect type -> [seen, moved the score]
	var stances: Dictionary = {}
	var scores: Dictionary = {}
	var by_effect: Dictionary = {}
	var by_entity: Dictionary = {}
	var rooms: Dictionary = {}
	var voted: Dictionary = {}
	# Le clausole: quale viene davvero posta con una CONDITION, e quante
	# Condition si qualificano. Una clausola mai scelta e' contenuto che non
	# esiste (D-035), e fino alla 0.1.27 la policy prendeva sempre la prima.
	var clauses: Dictionary = {}
	# In a Dictionary, not two ints: a lambda captures a local by value, so
	# counters incremented inside the callback would read zero out here.
	var counters: Dictionary = {"confluences": 0, "opposed": 0, "qualified": 0}

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, seats, first_seed + i)
		var probe: RefCounted = PolicyDecider.new(null)
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				if step != "PROPOSITION":
					return
				counters["confluences"] = int(counters["confluences"]) + 1
				var proponent: String = str(context["proponent"])
				var proposition: Dictionary = _proposition(data, context)
				if proposition.is_empty():
					return
				var room: String = "%s / %s" % [
					str(context["tension_id"]).replace("TEN_", ""),
					str(proponent).replace("ENT_", ""),
				]
				rooms[room] = int(rooms.get(room, 0)) + 1
				var put: String = "%s / %s" % [
					str(context["question_id"]), str(context["proposition_id"])
				]
				voted[put] = int(voted.get(put, 0)) + 1
				var any_opposition: bool = false
				for entity_id in seats:
					if str(entity_id) == proponent:
						continue
					var score: int = probe._score_proposition(
						proposition, str(entity_id), proponent, session
					)
					var declared: Dictionary = probe.choose_stance(
						str(entity_id), context, session
					)
					var stance: String = str(declared["stance"])
					stances[stance] = int(stances.get(stance, 0)) + 1
					if stance == "CONDITION":
						var clause_id: String = str(declared.get("clause_id", ""))
						clauses[clause_id] = int(clauses.get(clause_id, 0)) + 1
					scores[score] = int(scores.get(score, 0)) + 1
					if stance == "OPPOSE" or stance == "CONDITION":
						any_opposition = true
					var key: String = "%s/%s" % [str(entity_id), stance]
					by_entity[key] = int(by_entity.get(key, 0)) + 1
					_attribute(probe, proposition, str(entity_id), proponent, session, by_effect)
				if any_opposition:
					counters["opposed"] = int(counters["opposed"]) + 1
		)
		await session.run(PolicyDecider.new(session.log))
		for result in session.chronicle.confluence_results:
			if bool((result as Dictionary).get("condition_qualified", false)):
				counters["qualified"] = int(counters["qualified"]) + 1
		session.dispose()

	_report(
		runs, int(counters["confluences"]), int(counters["opposed"]),
		stances, scores, by_entity, by_effect, rooms, voted
	)
	_report_clauses(clauses, int(counters["qualified"]))
	quit(0)


## La meta' negoziale del Consiglio: quali clausole vengono poste, e quante
## Condition arrivano a qualificarsi davvero (D-055: solo una Condition
## qualificata entra nel margine).
func _report_clauses(clauses: Dictionary, qualified: int) -> void:
	print("")
	print("Le clausole poste con una CONDITION, e i Consigli con Condition qualificata: %d" % qualified)
	var keys: Array = clauses.keys()
	keys.sort()
	for key in keys:
		print("  %-24s %5d" % [str(key), int(clauses[key])])


## Score every Effect on its own, so we can see which axes are alive. An Effect
## type that is seen hundreds of times and never scores is not a quiet Effect -
## it is one the policy has no opinion about.
func _attribute(
	probe: RefCounted,
	proposition: Dictionary,
	entity_id: String,
	proponent_id: String,
	session: RefCounted,
	by_effect: Dictionary
) -> void:
	var goals: Dictionary = probe._tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	for consequence_id in proposition["success_consequences"]:
		var consequence: Variant = session.data.consequences.get(str(consequence_id))
		if consequence == null:
			continue
		for effect in consequence["effects"]:
			var type: String = str(effect["type"])
			var row: Dictionary = by_effect.get(type, {"seen": 0, "scored": 0})
			row["seen"] = int(row["seen"]) + 1
			if probe._score_effect(effect, entity_id, proponent_id, goals, session, bindings) != 0:
				row["scored"] = int(row["scored"]) + 1
			by_effect[type] = row


func _proposition(data: RefCounted, context: Dictionary) -> Dictionary:
	var template: Variant = data.confluence_templates.get(str(context["template_id"]))
	if template == null:
		return {}
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(context.get("proposition_id", "")):
			return proposition
	return {}


func _report(
	runs: int,
	confluences: int,
	opposed: int,
	stances: Dictionary,
	scores: Dictionary,
	by_entity: Dictionary,
	by_effect: Dictionary,
	rooms: Dictionary,
	voted: Dictionary
) -> void:
	print("")
	print("== PERCHE NESSUNO SI OPPONE - %d Chronicle ==" % runs)
	print("")
	print("Consigli osservati            %d" % confluences)
	print("Consigli con almeno un no     %d  (%.0f%%)" % [
		opposed, 100.0 * float(opposed) / float(maxi(1, confluences))
	])

	print("")
	print("Posizioni dichiarate")
	var stance_keys: Array = stances.keys()
	stance_keys.sort()
	var total: int = 0
	for key in stance_keys:
		total += int(stances[key])
	for key in stance_keys:
		print("  %-10s %5d  (%.1f%%)" % [
			str(key), int(stances[key]), 100.0 * float(stances[key]) / float(maxi(1, total))
		])

	print("")
	print("Punteggio della proposta, dal punto di vista di chi non la propone")
	var score_keys: Array = scores.keys()
	score_keys.sort()
	for key in score_keys:
		print("  %+3d        %5d  (%.1f%%)" % [
			int(key), int(scores[key]), 100.0 * float(scores[key]) / float(maxi(1, total))
		])

	print("")
	print("Per seggio")
	var entity_keys: Array = by_entity.keys()
	entity_keys.sort()
	for key in entity_keys:
		print("  %-28s %5d" % [str(key), int(by_entity[key])])

	print("")
	print("Ogni Effect, quante volte e stato letto e quante volte ha spostato il")
	print("punteggio. Uno che non lo sposta mai e un motivo di lite invisibile.")
	var effect_keys: Array = by_effect.keys()
	effect_keys.sort()
	for key in effect_keys:
		var row: Dictionary = by_effect[key]
		var scored: int = int(row["scored"])
		print("  %-26s letto %5d   pesato %5d %s" % [
			str(key), int(row["seen"]), scored, "" if scored > 0 else "  <-- MAI",
		])

	# A seat that never opposes may simply never be in the room: this probe only
	# scores non-proponents, and a Tension whose Council is always opened by the
	# one Entity that cares about it never gives that Entity a vote to cast.
	print("")
	print("Chi era nella stanza: Tensione / proponente")
	var room_keys: Array = rooms.keys()
	room_keys.sort()
	for key in room_keys:
		print("  %-28s %5d" % [str(key), int(rooms[key])])


	print("")
	print("Domande poste e proposte messe ai voti")
	var voted_keys: Array = voted.keys()
	voted_keys.sort()
	for key in voted_keys:
		print("  %-58s %4d" % [str(key), int(voted[key])])


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		text = text.substr(2)
		var split: int = text.find("=")
		if split < 0:
			options[text] = true
		else:
			options[text.substr(0, split)] = text.substr(split + 1)
	return options
