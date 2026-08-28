extends SceneTree
## Quando qualcuno viene cacciato, e chi recupera prima di fine anno?
##
##   godot --headless --path godot --script res://cli/run_eviction_probe.gd -- \
##       --runs=100 --seed=7000
##
## D-067 ha concluso che NONE non e raro per sfortuna: perdere non era
## implementato. Le prime Conseguenze che tolgono una presenza a qualcun altro
## rispondono a meta della domanda — adesso cacciare si puo. Questa sonda
## risponde all'altra meta: **quante volte succede davvero, in che momento
## dell'anno, e quante volte la vittima rientra con una MOVE prima che il
## Destino venga letto.** Una espulsione recuperata non e sprecata (costa
## un'azione e si vede nei livelli), ma solo quella non recuperata produce NONE.
##
## Stessi semi e stesso tavolo misto di run_playtest, cosi i numeri si
## confrontano riga per riga.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var plan: Array = []
	for i in range(runs):
		plan.append("CHR_00")

	print("SONDA ESPULSIONI - %d partite, tavolo misto, semi da %d" % [runs, first_seed])

	# Un tentativo e ogni REMOVE_PRESENCE che un Consiglio applica a qualcuno che
	# non e il proponente; "a vuoto" e il no-op dell'optional (il bersaglio non era
	# li); "sul Minimo" e quando la Regione tolta e una che il Minimo della vittima
	# nomina, cioe l'unico caso che puo produrre NONE.
	var attempted: int = 0
	var landed: int = 0
	var on_minimum: int = 0
	var none_after_eviction: int = 0
	var none_total: int = 0
	var by_round: Dictionary = {}
	var by_victim: Dictionary = {}
	var stories: Array = []

	for index in range(plan.size()):
		var chronicle_id: String = str(plan[index])
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, seats, seed_value)
		var table: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		var report: Dictionary = await session.run(table)

		var evicted_on_minimum: Dictionary = {}
		for effect in session.world["effect_log"]:
			if str(effect["type"]) != "REMOVE_PRESENCE":
				continue
			var source: Dictionary = effect["source"]
			var victim: String = str(effect["target"]["id"])
			if str(source.get("kind", "")) != "confluence":
				continue
			if str(source.get("actor", "")) == victim:
				continue  # costo autoinflitto (CNS_ABANDONED, CNS_EXODUS): altra storia
			attempted += 1
			if bool(effect.get("inverse_payload", {}).get("noop", false)):
				continue  # optional a vuoto: il bersaglio non era li
			landed += 1
			var region_id: String = str(effect["payload"].get("region_id", ""))
			var key: String = "atto %d round %d" % [int(source.get("act", 0)), int(source.get("round", 0))]
			by_round[key] = int(by_round.get(key, 0)) + 1
			by_victim[victim] = int(by_victim.get(victim, 0)) + 1
			if _minimum_names(victim, region_id, session):
				on_minimum += 1
				evicted_on_minimum[victim] = key

		for entity_id in seats:
			var level: String = str(report["destiny_results"][str(entity_id)]["level"])
			if level != "NONE":
				continue
			none_total += 1
			var when: String = str(evicted_on_minimum.get(str(entity_id), ""))
			if when != "":
				none_after_eviction += 1
			stories.append("seme %d (%s): %s finisce NONE%s" % [
				seed_value, chronicle_id, str(entity_id),
				", cacciato sul Minimo (%s)" % when if when != "" else ", senza espulsione altrui",
			])
		session.dispose()

	print("")
	print("  Tentativi (REMOVE_PRESENCE su altri, dai Consigli):  %d" % attempted)
	print("  Applicate (il bersaglio era li):                     %d" % landed)
	print("  Di cui su una Regione del Minimo della vittima:      %d" % on_minimum)
	print("  Vittime finite NONE dopo una di queste:              %d" % none_after_eviction)
	print("  NONE totali del tavolo misto:                        %d" % none_total)
	print("  Recuperate (cacciato sul Minimo ma non NONE):        %d" % (on_minimum - none_after_eviction))

	print("")
	print("  Quando cadono (atto/round):")
	var round_keys: Array = by_round.keys()
	round_keys.sort()
	for key in round_keys:
		print("    %-18s %d" % [str(key), int(by_round[key])])

	print("")
	print("  Su chi cadono:")
	var victim_keys: Array = by_victim.keys()
	victim_keys.sort()
	for key in victim_keys:
		print("    %-14s %d" % [str(key), int(by_victim[key])])

	if not stories.is_empty():
		print("")
		print("  Le partite con un NONE:")
		for line in stories:
			print("    %s" % str(line))
	quit(0)


## La Regione tolta e una che il Minimo della vittima nomina con region_presence.
func _minimum_names(entity_id: String, region_id: String, session: RefCounted) -> bool:
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	if destiny == null:
		return false
	for condition in destiny["minimum"]["conditions"]:
		if str(condition.get("type", "")) != "region_presence":
			continue
		if str(condition.get("entity_id", "")) != entity_id:
			continue
		if str(condition.get("region_id", "")) == region_id:
			return true
	return false


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
