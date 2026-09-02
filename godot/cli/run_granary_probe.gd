extends SceneTree
## **La Pietra Granaio cade mai fuori da una terra da granaio?** (ISSUES 70)
##
##   godot --headless --path godot --script res://cli/run_granary_probe.gd -- --runs=100 --seed=7000
##
## `#granaio` sta su diciotto facce, e fino a [D-406](../docs/DECISIONS.md#d-406)
## diciassette accettavano solo la **vocazione** della terra, non la **Pietra**
## costruita. Allargarle vale la pena solo se la Pietra finisce davvero, qualche
## volta, dove la vocazione non c'e': altrimenti sarebbe una riga in piu' che non
## apre nessun posto.
##
## Questa sonda tiene onesto quel numero, e si rigira quando serve. Misurato in
## 0.1.375: **9 partite su cento**, in tre Regioni diverse.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		quit(3)
		return

	var con_pietra: int = 0
	var pietra_senza_vocazione: int = 0
	var partite_col_caso: int = 0
	var nomi: Dictionary = {}

	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup("CHR_00", seats, seed_value):
			quit(3)
			return
		await session.run(PolicyDecider.new(session.log))
		var qui: int = 0
		for region_id in session.world["regions"]:
			var tags: Array = session.world["regions"][str(region_id)]["tags"] as Array
			if not tags.has("structure:granary"):
				continue
			con_pietra += 1
			if not tags.has("granary"):
				pietra_senza_vocazione += 1
				qui += 1
				nomi[str(region_id)] = int(nomi.get(str(region_id), 0)) + 1
		if qui > 0:
			partite_col_caso += 1
		session.dispose()

	print("")
	print("== LA PIETRA GRANAIO E LA TERRA DA GRANAIO - %d partite ==" % runs)
	print("  Regioni che finiscono con la Pietra:            %d" % con_pietra)
	print("  di cui SENZA la vocazione:                      %d" % pietra_senza_vocazione)
	print("  partite in cui succede almeno una volta:        %d su %d" % [partite_col_caso, runs])
	for region_id in nomi:
		print("    %-24s %d" % [str(region_id), int(nomi[str(region_id)])])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
