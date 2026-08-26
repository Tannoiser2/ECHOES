extends SceneTree
## **Quante volte il mondo si ricorda** (D-286).
##
##   godot --headless --path godot --script res://cli/run_memory_probe.gd -- \
##       --runs=40 --seed=812
##
## La pesca dell'era successiva **ascolta** (D-079): una domanda i cui echi sono
## ancora sul tavolo pesa il triplo. Fino a D-286 quel meccanismo non ascoltava
## le **memorie del mondo** — tredici segni scritti dai Consigli e dalle
## Conseguenze e poi riletti da nessuno: la Carta che vale per un tempo solo, il
## cristallo misurato, la successione con testimoni, i diritti d'acqua.
##
## Questa sonda gioca un anno per intero e poi chiede al mondo finito: **quali
## domande, l'anno prossimo, tornerebbero chiamate — e da quale segno**. Le
## memorie nuove si contano a parte: se restassero a zero sarebbero contenuto
## che non esiste, che e' la frase che questo progetto ha gia' scritto tre volte
## (D-035).

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## Le memorie che D-286 ha messo in ascolto.
const NUOVE: Array = [
	"amnesty_granted", "succession_witnessed", "succession_settled",
	"charter_for_all", "charter_temporary", "crystal_measured",
	"descent_witnessed", "debt_staggered", "distribution_audited",
	"quota_guaranteed", "relic_recorded", "water_shared", "water_rights",
	"knowledge_shared", "toll_shared",
]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 812))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr(data.describe_errors())
		quit(1)
		return

	var called: Dictionary = {}       # segno -> quante volte ha chiamato
	var by_question: Dictionary = {}  # domanda -> quante volte chiamata
	var years: int = 0
	var with_memory: int = 0

	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			session.dispose()
			continue
		await session.run(Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		))
		years += 1
		# Il mondo finito, e la mano di domande che l'era dopo pescherebbe.
		var world: Dictionary = session.world
		var chronicle: Dictionary = data.chronicles[chronicle_id] as Dictionary
		var echoes: Dictionary = (chronicle.get("tension_pool", {}) as Dictionary).get(
			"echoes", {}
		) as Dictionary
		var memory_called: bool = false
		for tension_id in echoes:
			var mark: String = _carried(world, echoes[str(tension_id)] as Array)
			if mark == "":
				continue
			by_question[str(tension_id)] = int(by_question.get(str(tension_id), 0)) + 1
			called[mark] = int(called.get(mark, 0)) + 1
			if NUOVE.has(mark):
				memory_called = true
		if memory_called:
			with_memory += 1
		session.dispose()

	print("")
	print("== QUANTE VOLTE IL MONDO SI RICORDA - %d anni ==" % years)
	print("")
	print("  Anni in cui una **memoria** chiama una domanda: %d su %d" % [
		with_memory, years
	])
	print("")
	print("  Chi chiama, e quante volte:")
	for tag in _sorted_by_count(called):
		print("    %-28s %4d%s" % [
			str(tag), int(called[str(tag)]), "   <- memoria (D-286)" if NUOVE.has(str(tag)) else ""
		])
	print("")
	print("  Le domande che tornano chiamate:")
	for tension_id in _sorted_by_count(by_question):
		print("    %-28s %4d" % [str(tension_id), int(by_question[str(tension_id)])])
	print("")
	quit(0)


## Il primo segno che il mondo porta ancora, con la stessa regola della pesca
## (`_carried_mark`): fatto globale, leggenda del fatto, o segno su una Regione.
func _carried(world: Dictionary, tags: Array) -> String:
	var facts: Array = world.get("global_tags", []) as Array
	for tag in tags:
		if facts.has(str(tag)) or facts.has("legend:%s" % str(tag)):
			return str(tag)
		for region_id in world.get("regions", {}):
			if ((world["regions"][str(region_id)] as Dictionary).get("tags", []) as Array).has(str(tag)):
				return str(tag)
	return ""


func _sorted_by_count(counts: Dictionary) -> Array:
	var keys: Array = counts.keys()
	keys.sort_custom(func(a: String, b: String) -> bool:
		var left: int = int(counts[a])
		var right: int = int(counts[b])
		if left == right:
			return str(a) < str(b)
		return left > right
	)
	return keys


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if not str(arg).begins_with("--"):
			continue
		var pair: PackedStringArray = str(arg).substr(2).split("=")
		out[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return out
