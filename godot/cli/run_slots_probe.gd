extends SceneTree
## Cosa costerebbe far rispettare i biomi e i posti (ISSUES 116).
##
##   godot --headless --path godot --script res://cli/run_slots_probe.gd -- --runs=100
##
## Tre domande, prima di cambiare una regola:
##
##   1. **quante Pietre si alzano oggi**, e su che bioma;
##   2. **quante sarebbero rifiutate** dal vincolo che le Pietre dichiarano gia'
##      nel campo `biomes` e che nessuno legge;
##   3. **quante volte una tessera terrebbe piu' Pietre di quante ne ha posti.**
##
## Le Pietre `owned: false` — bosco, sorgente, passo, sito antico — sono la terra
## e non si costruiscono: non occupano un posto, e il conto le tiene fuori.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## I posti per bioma, come li ha decisi il committente: legati al bioma.
const POSTI: Dictionary = {
	"CITY": 3, "VALLEY": 3, "ROAD": 3,
	"COAST": 2, "STEPPE": 2, "UNDERGROUND": 2, "MOUNTAIN": 2, "FOREST": 2,
	"MARSH": 1, "ISLAND": 1,
}


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

	var alzate: int = 0
	var per_bioma: Dictionary = {}
	var rifiutate_bioma: int = 0
	var rifiutate_dettaglio: Dictionary = {}
	var oltre_i_posti: int = 0
	var oltre_dettaglio: Dictionary = {}
	var terra: int = 0
	var in_piedi_dove_non_puo: int = 0

	for index in range(runs):
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		session.setup("CHR_00", seats, seed_value)
		var table: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(table)
		var world: Dictionary = session.world

		# Quante Pietre costruibili sta tenendo ogni tessera a fine partita: e'
		# la sola strada che non passa dal registro degli Effetti.
		for region_id in world["regions"]:
			var region: Dictionary = world["regions"][str(region_id)]
			var bioma: String = str(data.regions[str(region_id)]["biome"])
			var tenute: int = 0
			for s in (region.get("structures", []) as Array):
				var tipo: Variant = data.structure_types.get(
					str((s as Dictionary).get("structure_type", ""))
				)
				if tipo == null:
					continue
				if not bool((tipo as Dictionary).get("owned", false)):
					continue
				tenute += 1
			for s2 in (region.get("structures", []) as Array):
				var t2: Variant = data.structure_types.get(
					str((s2 as Dictionary).get("structure_type", ""))
				)
				if t2 == null:
					continue
				if not ((t2 as Dictionary).get("biomes", []) as Array).has(bioma):
					in_piedi_dove_non_puo += 1
			var posti: int = int(POSTI.get(bioma, 2))
			if tenute > posti:
				oltre_i_posti += 1
				var k: String = "%s (%d posti, ne tiene %d)" % [bioma, posti, tenute]
				oltre_dettaglio[k] = int(oltre_dettaglio.get(k, 0)) + 1

		for effect in world["effect_log"]:
			if str(effect.get("type", "")) != "BUILD_STRUCTURE":
				continue
			var tipo_id: String = str((effect.get("payload", {}) as Dictionary).get("structure_type", ""))
			var tipo: Variant = data.structure_types.get(tipo_id)
			if tipo == null:
				continue
			if not bool((tipo as Dictionary).get("owned", false)):
				terra += 1
				continue
			alzate += 1
			var dove: String = str((effect.get("target", {}) as Dictionary).get("id", ""))
			var regione: Variant = data.regions.get(dove)
			if regione == null:
				continue
			var bioma2: String = str((regione as Dictionary)["biome"])
			per_bioma[bioma2] = int(per_bioma.get(bioma2, 0)) + 1
			if not ((tipo as Dictionary).get("biomes", []) as Array).has(bioma2):
				rifiutate_bioma += 1
				var key: String = "%s su %s" % [tipo_id, bioma2]
				rifiutate_dettaglio[key] = int(rifiutate_dettaglio.get(key, 0)) + 1
		session.dispose()

	print("")
	print("== I POSTI E I BIOMI - %d anni, tavolo misto ==" % runs)
	print("")
	print("Pietre costruibili alzate      %6.2f per partita  (%d)" % [
		float(alzate) / float(runs), alzate
	])
	print("Pietre della terra (owned:false) %4.2f per partita  (%d) - non occupano un posto" % [
		float(terra) / float(runs), terra
	])
	print("")
	print("1. DOVE SI COSTRUISCE OGGI")
	var biomi: Array = per_bioma.keys()
	biomi.sort()
	for b in biomi:
		print("   %-13s %4d" % [str(b), int(per_bioma[b])])

	print("")
	print("2. QUANTE IL VINCOLO DEI BIOMI NE RIFIUTEREBBE")
	print("   %d su %d  (%.1f%%)" % [
		rifiutate_bioma, alzate,
		(100.0 * float(rifiutate_bioma) / float(alzate)) if alzate > 0 else 0.0
	])
	var keys: Array = rifiutate_dettaglio.keys()
	keys.sort()
	for k in keys:
		print("     %-34s %d" % [str(k), int(rifiutate_dettaglio[k])])

	print("")
	print("2b. E QUANTE NE STANNO DAVVERO IN PIEDI DOVE NON POTREBBERO")
	print("   (questa non passa dal registro: guarda il tavolo a fine partita)")
	print("   %d" % in_piedi_dove_non_puo)

	print("")
	print("3. QUANTE VOLTE UNA TESSERA SFORA I SUOI POSTI")
	print("   %d volte in %d partite" % [oltre_i_posti, runs])
	var ok: Array = oltre_dettaglio.keys()
	ok.sort()
	for k in ok:
		print("     %-34s %d" % [str(k), int(oltre_dettaglio[k])])
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
