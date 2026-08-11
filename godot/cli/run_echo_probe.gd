extends SceneTree
## Echo probe: what the Propp layer is actually doing (§15, DECISIONS O-10).
##
##   godot --headless --path godot --script res://cli/run_echo_probe.gd -- --runs=40
##
## Two questions, and they have different answers.
##
## `dramatic_family` (PRESSURE / RUPTURE / TURN / RESOLUTION) gates which cards
## an Act may draw, so it is load-bearing: it is the three-act shape, enforced.
##
## `function_id` - the 24 narrative functions - orders the story: drawing a card
## records the function it performed, and a card that presupposes something is
## not eligible until that something has happened (D-030). This probe checks the
## grammar actually holds: no function arriving without its antecedent, no
## function repeating inside one Chronicle, and enough distinct arcs that two
## Chronicles do not feel like the same one.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://cli/policy_decider.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]

## Propp's point is that functions come in an order. These are the pairs where a
## card only makes sense once something else has happened, used here purely to
## measure how often the current deck violates them.
const NEEDS_ANTECEDENT: Dictionary = {
	"RETURN": ["PROHIBITION", "SEPARATION"],
	"RECONCILIATION": ["BETRAYAL", "VIOLATION", "ATTACK", "SEPARATION"],
	"LIBERATION": ["USURPATION", "PROHIBITION", "CONQUEST"],
	"PUNISHMENT": ["VIOLATION", "BETRAYAL", "USURPATION", "CONQUEST"],
	"REVELATION": ["DISCOVERY"],
	"VIOLATION": ["PROHIBITION", "REQUEST"],
	"CONQUEST": ["ATTACK", "THREAT", "USURPATION"],
	"SUCCESSION": ["THREAT", "USURPATION", "CONQUEST", "SEPARATION"],
	"TRANSFORMATION": ["THREAT"],
	"GIFT": ["LACK"],
}


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 6000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var per_act: Dictionary = {}
	var function_counts: Dictionary = {}
	var repeats: int = 0
	var chronicles_with_repeat: int = 0
	var orphans: int = 0
	var chronicles_with_orphan: int = 0
	var arcs: Dictionary = {}

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, SEATS, first_seed + i)
		session.run(PolicyDecider.new(session.log))

		var drawn: Array = []
		for card_id in session.world["echo_deck"]["drawn"]:
			drawn.append(data.echo_cards[str(card_id)])

		var seen_functions: Dictionary = {}
		var had_repeat: bool = false
		var had_orphan: bool = false
		var arc: Array = []
		for index in range(drawn.size()):
			var card: Dictionary = drawn[index]
			var function_id: String = str(card["function_id"])
			var family: String = str(card["dramatic_family"])
			arc.append(family.substr(0, 3))
			function_counts[function_id] = int(function_counts.get(function_id, 0)) + 1
			var key: String = "%d/%s" % [index + 1, family]
			per_act[key] = int(per_act.get(key, 0)) + 1

			if seen_functions.has(function_id):
				repeats += 1
				had_repeat = true
			if NEEDS_ANTECEDENT.has(function_id):
				var satisfied: bool = false
				for antecedent in NEEDS_ANTECEDENT[function_id]:
					if seen_functions.has(str(antecedent)):
						satisfied = true
				if not satisfied:
					orphans += 1
					had_orphan = true
			seen_functions[function_id] = true

		if had_repeat:
			chronicles_with_repeat += 1
		if had_orphan:
			chronicles_with_orphan += 1
		arcs[" ".join(PackedStringArray(arc))] = int(arcs.get(" ".join(PackedStringArray(arc)), 0)) + 1
		session.dispose()

	print("")
	print("== LO STRATO DI PROPP - %d Chronicle, %s ==" % [runs, chronicle_id])
	print("")
	print("Famiglia drammatica per Atto (questa il motore la usa davvero)")
	var keys: Array = per_act.keys()
	keys.sort()
	for key in keys:
		print("  Atto %-24s %d" % [str(key).replace("/", " - "), int(per_act[key])])

	print("")
	print("Archi drammatici distinti su %d partite: %d" % [runs, arcs.size()])
	var arc_keys: Array = arcs.keys()
	arc_keys.sort()
	for key in arc_keys:
		print("  %-24s %dx" % [str(key), int(arcs[key])])

	print("")
	print("Funzioni narrative (la grammatica di Propp, D-030)")
	print("  funzioni distinte pescate    %d su 24 dichiarate nello schema" % function_counts.size())
	print("  ripetizioni dentro una stessa Chronicle   %d (%d/%d partite)" % [
		repeats, chronicles_with_repeat, runs
	])
	print("  funzioni senza il loro antecedente        %d (%d/%d partite)" % [
		orphans, chronicles_with_orphan, runs
	])
	print("")
	var function_keys: Array = function_counts.keys()
	function_keys.sort()
	for key in function_keys:
		print("  %-18s %dx" % [str(key), int(function_counts[key])])
	quit(0)


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
