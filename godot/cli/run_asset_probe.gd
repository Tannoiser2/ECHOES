extends SceneTree
## Le carte che nessuno gioca (ISSUES 3): quali Asset vivono davvero.
##
##   godot --headless --path godot --script res://cli/run_asset_probe.gd -- \
##       --runs=100 --seed=7000
##
## 48 facce, 132 carte, e nessuno aveva mai contato quali vengono acquisite e
## impegnate. E' la stessa forma di problema che il progetto ha gia' trovato
## per le proposte (D-063): contenuto scritto, legale, e che non succede mai.
## La lezione da riportare e' identica: la misura si fa a tavolo misto,
## perche' l'ottimizzatore da solo dichiara morto contenuto che vivo lo e'.
##
## Per ogni faccia: quante volte e' stata pescata con un'azione, quante e'
## arrivata in una mano dal setup, quante e' stata spesa - impegnata a un
## Consiglio, scartata per una spinta, spesa per la parola - e quante e'
## rimasta in mano a fine anno. Una carta committata e recuperata da chi si
## oppone non lascia un Effect di scarto: il conteggio della spesa e' quindi
## un pavimento, non un soffitto, ed e' scritto qui perche' nessuno lo
## scambi per esatto.

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
		plan.append("CHR_01" if i % 2 == 0 else "CHR_03")

	print("SONDA DEGLI ASSET - %d partite, tavolo misto, semi da %d" % [runs, first_seed])

	var dealt: Dictionary = {}      # dal setup
	var drawn: Dictionary = {}      # con ACQUIRE
	var committed: Dictionary = {}  # spesa a un Consiglio
	var pushed: Dictionary = {}     # scartata per INFLUENCE
	var claimed: Dictionary = {}    # spesa per CLAIM
	var held: Dictionary = {}       # in mano a fine anno

	for index in range(plan.size()):
		var chronicle_id: String = str(plan[index])
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var chronicle_seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		session.setup(chronicle_id, chronicle_seats, seed_value)
		var table: RefCounted = Characters.deal(
			chronicle_seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(table)

		for effect in session.world["effect_log"]:
			var kind: String = str(effect["type"])
			var asset_id: String = str(effect.get("payload", {}).get("asset_id", ""))
			if asset_id == "":
				continue
			var source: Dictionary = effect["source"]
			if kind == "GRANT_ASSET":
				if str(source.get("id", "")) == "SETUP":
					dealt[asset_id] = int(dealt.get(asset_id, 0)) + 1
				elif str(source.get("id", "")) == "ACT_ACQUIRE":
					drawn[asset_id] = int(drawn.get(asset_id, 0)) + 1
			elif kind == "REMOVE_ASSET":
				if str(source.get("kind", "")) == "confluence":
					committed[asset_id] = int(committed.get(asset_id, 0)) + 1
				elif str(source.get("id", "")) == "ACT_INFLUENCE":
					pushed[asset_id] = int(pushed.get(asset_id, 0)) + 1
				elif str(source.get("id", "")) == "ACT_CLAIM":
					claimed[asset_id] = int(claimed.get(asset_id, 0)) + 1
		for entity_id in chronicle_seats:
			for asset_id in session.world["entities"][str(entity_id)]["hand"]:
				held[str(asset_id)] = int(held.get(str(asset_id), 0)) + 1
		session.dispose()

	_report(data, dealt, drawn, committed, pushed, claimed, held)
	quit(0)


func _report(
	data: RefCounted,
	dealt: Dictionary,
	drawn: Dictionary,
	committed: Dictionary,
	pushed: Dictionary,
	claimed: Dictionary,
	held: Dictionary
) -> void:
	var families: Dictionary = {}
	var never_touched: Array = []
	var never_spent: Array = []

	print("")
	print("  %-30s %6s %6s %8s %6s %6s %6s" % [
		"faccia", "setup", "pesca", "consigl", "spinta", "parola", "fine"
	])
	var ids: Array = data.assets.keys()
	ids.sort()
	for asset_id in ids:
		var id: String = str(asset_id)
		var asset: Dictionary = data.assets[id]
		var row: Array = [
			int(dealt.get(id, 0)), int(drawn.get(id, 0)), int(committed.get(id, 0)),
			int(pushed.get(id, 0)), int(claimed.get(id, 0)), int(held.get(id, 0)),
		]
		var touched: int = int(row[0]) + int(row[1])
		var spent: int = int(row[2]) + int(row[3]) + int(row[4])
		var family: String = str(asset["family"])
		var tally: Dictionary = families.get(family, {"touched": 0, "spent": 0})
		tally["touched"] = int(tally["touched"]) + touched
		tally["spent"] = int(tally["spent"]) + spent
		families[family] = tally
		var note: String = ""
		if touched == 0:
			note = "  <- mai in una mano"
			never_touched.append(id)
		elif spent == 0:
			note = "  <- pescata e mai spesa"
			never_spent.append(id)
		print("  %-30s %6d %6d %8d %6d %6d %6d%s" % [
			id, row[0], row[1], row[2], row[3], row[4], row[5], note
		])

	print("")
	print("  Per famiglia: quante volte in mano, quante spese")
	var family_keys: Array = families.keys()
	family_keys.sort()
	for family in family_keys:
		var tally: Dictionary = families[family]
		print("    %-12s in mano %5d   spese %5d" % [
			str(family), int(tally["touched"]), int(tally["spent"])
		])

	print("")
	print("== LA CODA ==")
	print("  mai in una mano — %d" % never_touched.size())
	for id in never_touched:
		print("    %s" % str(id))
	print("  pescate e mai spese — %d" % never_spent.size())
	for id in never_spent:
		print("    %s" % str(id))


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
