extends SceneTree
## What a Destiny costs, measured before anyone plays and again while they do.
##
##   godot --headless --path godot --script res://cli/run_destiny_probe.gd -- \
##       --runs=40 --seed=1000 --chronicle=CHR_00
##
## Two questions, and the first one needs no dice at all.
##
## **What is already true before the year starts?** A Destiny clause that holds on
## the opening position is a clause nobody has to play for, and a whole level made
## of them is a level won by sitting still. The audit that produced this probe
## found the watcher taking VICTORY in 37 Chronicles out of 40 with two clauses
## that were true before the first token was placed.
##
## **And when does the ladder close?** A seat that finishes its Destiny in Act I
## has nothing to do for the other two thirds of the Chronicle. That does not show
## up in an outcome table - the seat still reports TRIUMPH - but it is the
## difference between a player and a spectator.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const LEVELS: Array = ["minimum", "victory", "triumph"]


## Chi siede al tavolo lo pesca il seme, non questo file (D-213): la
## biblioteca delle case apparecchia, e questa sonda tiene **il tavolo del
## primo seme** per tutte le sue partite - misura altro, e cambiare tavolo a
## ogni run vorrebbe dire misurare la pesca invece di quello che cerca.
func _seats(data: RefCounted, chronicle_id: String, seed_value: int) -> Array:
	return GameSession.seats_for(data, chronicle_id, seed_value)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 1000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	_free_at_the_start(data, chronicle_id, first_seed)
	await _when_the_ladder_closes(data, chronicle_id, runs, first_seed)
	await _what_a_seat_can_actually_get(data, chronicle_id, runs, first_seed)
	quit(0)


## Which Councils each seat gets to propose, and which tags it ends up wearing.
##
## A Destiny clause is only as reachable as the Consequence behind it, and a
## Consequence hands its tag to a *slot* - `$proponent`, `$rival`. So "some
## Consequence writes this tag" is not the same question as "this seat can get
## it", and writing a clause against the first is how a Destiny ends up
## impossible for the one house that carries it.
func _what_a_seat_can_actually_get(
	data: RefCounted, chronicle_id: String, runs: int, first_seed: int
) -> void:
	var SEATS: Array = _seats(data, chronicle_id, first_seed)
	var proposed: Dictionary = {}
	var tagged: Dictionary = {}
	for entity_id in SEATS:
		proposed[str(entity_id)] = 0
		tagged[str(entity_id)] = {}

	for index in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + index)
		var report: Dictionary = await session.run(PolicyDecider.new(session.log))
		for result in report["confluences"]:
			var who: String = str(result["proponent"])
			proposed[who] = int(proposed.get(who, 0)) + 1
		for entity_id in SEATS:
			for tag in session.world["entities"][str(entity_id)]["tags"]:
				if str(tag).begins_with("knows:"):
					continue
				var per: Dictionary = tagged[str(entity_id)]
				per[str(tag)] = int(per.get(str(tag), 0)) + 1
		session.dispose()

	print("")
	print("== COSA UN SEGGIO RIESCE DAVVERO A PRENDERSI (%d Chronicle) ==" % runs)
	print("")
	for entity_id in SEATS:
		var id: String = str(entity_id)
		var worn: Array = (tagged[id] as Dictionary).keys()
		worn.sort()
		var marks: Array = []
		for tag in worn:
			marks.append("%s %d/%d" % [str(tag), int(tagged[id][str(tag)]), runs])
		print("  %-10s propone %2d Consigli   %s" % [
			id.trim_prefix("ENT_"), int(proposed[id]),
			"niente" if marks.is_empty() else ", ".join(PackedStringArray(marks)),
		])


## Every clause of every Destiny, checked against the opening position - the
## table as it is dealt, before a single Action Opportunity is spent.
func _free_at_the_start(data: RefCounted, chronicle_id: String, first_seed: int) -> void:
	var SEATS: Array = _seats(data, chronicle_id, first_seed)
	var session: RefCounted = GameSession.new(data)
	session.setup(chronicle_id, SEATS, 1)
	for effect in session.factory_setup_effects():
		session.applier.apply(effect)

	print("== COSA E' GIA' VERO PRIMA DI COMINCIARE (%s) ==" % chronicle_id)
	print("")
	for entity_id in SEATS:
		var destiny: Dictionary = data.destinies[session.service.destiny_of(str(entity_id))]
		print("%s - %s" % [session.service.name_of(str(entity_id)), str(destiny["title"])])
		_print_ladder(session, destiny, {})
		print("")
	# Le carte condivisibili (voce 20, D-115): la stessa scala, letta una volta
	# per ogni seggio che la porta nel pool - "gia' vero" per uno puo' essere
	# "da fare" per un altro, ed e' esattamente cio' che va guardato.
	for entity_id in SEATS:
		var id: String = str(entity_id)
		for destiny_id in (data.entities[id] as Dictionary).get("destiny_pool", []):
			var pooled: Dictionary = data.destinies[str(destiny_id)]
			if str(pooled["entity_id"]) != "$self":
				continue
			print("%s, se giura - %s" % [session.service.name_of(id), str(pooled["title"])])
			_print_ladder(session, pooled, {"self": id})
			print("")
	session.dispose()


func _print_ladder(session: RefCounted, destiny: Dictionary, context: Dictionary) -> void:
	for level in LEVELS:
		var conditions: Array = destiny[str(level)]["conditions"]
		var held: int = 0
		var marks: Array = []
		for condition in conditions:
			var holds: bool = session.destinies.conditions.holds(condition, context)
			held += 1 if holds else 0
			marks.append("%s%s" % [
				"[gia' vero] " if holds else "[da fare]  ",
				str((condition as Dictionary).get("label", condition["type"])),
			])
		print("  %-8s %d/%d gia' vero%s" % [
			str(level), held, conditions.size(),
			"   <<< REGALATO" if held == conditions.size() else "",
		])
		for mark in marks:
			print("      %s" % str(mark))


## And the round at which each seat's whole ladder is closed - after which it has
## nothing left to play for, whatever the report says at the end.
func _when_the_ladder_closes(
	data: RefCounted, chronicle_id: String, runs: int, first_seed: int
) -> void:
	var SEATS: Array = _seats(data, chronicle_id, first_seed)
	var closed_at: Dictionary = {}
	var never: Dictionary = {}
	# Le scale condivise (voce 20, D-115) si misurano nelle stesse partite: per
	# ogni seggio che ne porta una nel pool, la chiave e' "seggio|carta".
	var shared: Array = []
	for entity_id in SEATS:
		closed_at[str(entity_id)] = []
		never[str(entity_id)] = 0
		for destiny_id in (data.entities[str(entity_id)] as Dictionary).get("destiny_pool", []):
			if str(data.destinies[str(destiny_id)]["entity_id"]) == "$self":
				var key: String = "%s|%s" % [str(entity_id), str(destiny_id)]
				shared.append(key)
				closed_at[key] = []
				never[key] = 0

	for index in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + index)
		var seen: Dictionary = {}
		session.chronicle.phase_changed.connect(
			func(act: int, round_number: int, phase: String) -> void:
				if phase != "ACTIONS":
					return
				var at: int = (act - 1) * int(data.chronicles[chronicle_id]["rounds_per_act"]) + round_number
				for entity_id in SEATS:
					var id: String = str(entity_id)
					if not seen.has(id):
						var destiny: Dictionary = data.destinies[session.service.destiny_of(id)]
						if _ladder_closed(session, destiny, {}):
							seen[id] = at
					for key in shared:
						if seen.has(key) or not str(key).begins_with(id + "|"):
							continue
						var pooled: Dictionary = data.destinies[str(key).get_slice("|", 1)]
						if _ladder_closed(session, pooled, {"self": id}):
							seen[key] = at
		)
		await session.run(PolicyDecider.new(session.log))
		for key in closed_at:
			if seen.has(key):
				(closed_at[key] as Array).append(int(seen[key]))
			else:
				never[key] = int(never[key]) + 1
		session.dispose()

	var rounds: int = int(data.chronicles[chronicle_id]["acts"]) * int(
		data.chronicles[chronicle_id]["rounds_per_act"]
	)
	print("== QUANDO LA SCALA E' GIA' TUTTA CHIUSA (%d Chronicle da %d round) ==" % [runs, rounds])
	print("")
	print("  %-22s %-16s %s" % ["seggio", "chiusa in anticipo", "round medio"])
	for entity_id in SEATS:
		_print_closure(str(entity_id), str(entity_id).trim_prefix("ENT_"), closed_at, runs)
	if not shared.is_empty():
		print("")
		print("  e le scale condivise, per chi le porta nel pool:")
		for key in shared:
			var label: String = "%s: %s" % [
				str(key).get_slice("|", 0).trim_prefix("ENT_"),
				str(key).get_slice("|", 1).trim_prefix("DST_SHARED_"),
			]
			_print_closure(str(key), label, closed_at, runs)


func _ladder_closed(session: RefCounted, destiny: Dictionary, context: Dictionary) -> bool:
	for level in LEVELS:
		if not session.destinies.conditions.all_hold(destiny[str(level)]["conditions"], context):
			return false
	return true


func _print_closure(key: String, label: String, closed_at: Dictionary, runs: int) -> void:
	var closures: Array = closed_at[key]
	var total: int = 0
	for value in closures:
		total += int(value)
	print("  %-22s %-16s %s" % [
		label,
		"%d/%d" % [closures.size(), runs],
		"-" if closures.is_empty() else "%.1f" % (float(total) / float(closures.size())),
	])


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
