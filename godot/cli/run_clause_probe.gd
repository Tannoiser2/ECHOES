extends SceneTree
## Quanto costa una clausola, **prima** di scriverla in un Destino.
##
##   godot --headless --path godot --script res://cli/run_clause_probe.gd -- \
##       --runs=40 --seed=7000 --candidates=tools/clause_candidates.json
##
## D-161 ha pagato una volta il prezzo di scrivere cinque clausole a occhio:
## tre impossibili al 100%, due mai mancate, zero utili. La sonda dei gradini
## dice quanto manca una clausola **che e' gia' scritta**; questa dice quanto
## mancherebbe una clausola **che non lo e' ancora**, e costa un file di prova
## invece di un commit da rifare.
##
## Il file dei candidati e' una lista di `{id, note, condition}`. Ogni candidato
## viene valutato a fine anno per **ogni seggio al tavolo**, col contesto
## `$self` legato al seggio: cosi' la stessa clausola si legge su otto case
## diverse in un giro solo, ed e' li' che si vede se e' una porta per una casa e
## un muro per un'altra.
##
## Tavolo misto e semi della sonda dei gradini, di proposito: i due numeri vanno
## letti uno accanto all'altro.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 7000))
	# Il file dei candidati sta in `tools/`, fuori da `data/`: e' una prova, non
	# contenuto, e non deve passare dagli schemi ne' finire nel manifest.
	var default_path: String = ProjectSettings.globalize_path("res://").path_join(
		"../tools/clause_candidates.json"
	)
	var path: String = str(options.get("candidates", default_path))

	var candidates: Array = _read_candidates(path)
	if candidates.is_empty():
		printerr("nessun candidato leggibile in '%s'" % path)
		quit(2)
		return

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var held: Dictionary = {}   # "candidato|casa" -> quante volte vera
	var seen: Dictionary = {}   # "candidato|casa" -> quante volte guardata
	for index in range(runs):
		var chronicle_id: String = "CHR_01" if index % 2 == 0 else "CHR_03"
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
		session.setup(chronicle_id, seats, seed_value)
		var decider: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(decider)
		var judge: RefCounted = ConditionEvaluator.new(session.world, data)
		for entity_id in seats:
			for candidate in candidates:
				var record: Dictionary = candidate as Dictionary
				var key: String = "%s|%s" % [str(record["id"]), str(entity_id)]
				seen[key] = int(seen.get(key, 0)) + 1
				if judge.holds(record["condition"] as Dictionary, {"self": str(entity_id)}):
					held[key] = int(held.get(key, 0)) + 1
		session.dispose()
		if (index + 1) % 10 == 0:
			print("  %d/%d partite" % [index + 1, runs])

	print("")
	print("== LE CLAUSOLE CANDIDATE - %d Chronicle a tavolo misto, semi da %d ==" % [runs, first_seed])
	print("   Si legge come la sonda dei gradini al contrario: qui e' la quota di")
	print("   volte in cui la clausola **e' vera** a fine anno. Vicino a 100 e' un")
	print("   regalo, vicino a 0 e' un muro, e in mezzo c'e' un obiettivo.")
	for candidate in candidates:
		var record: Dictionary = candidate as Dictionary
		print("")
		print("  %s — %s" % [str(record["id"]), str(record.get("note", ""))])
		var houses: Array = []
		for key in seen:
			if str(key).begins_with(str(record["id"]) + "|"):
				houses.append(str(key).split("|")[1])
		houses.sort()
		for entity_id in houses:
			var key: String = "%s|%s" % [str(record["id"]), str(entity_id)]
			var times: int = int(seen.get(key, 0))
			print("    %-12s %3.0f%%   (%d su %d)" % [
				str(entity_id),
				100.0 * float(held.get(key, 0)) / maxf(1.0, float(times)),
				int(held.get(key, 0)), times,
			])
	quit(0)


func _read_candidates(path: String) -> Array:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Array:
		return parsed as Array
	if parsed is Dictionary and (parsed as Dictionary).has("items"):
		return (parsed as Dictionary)["items"] as Array
	return []


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
