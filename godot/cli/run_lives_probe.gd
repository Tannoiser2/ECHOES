extends SceneTree
## **La sonda delle vite**: quante volte una casa diventa qualcos'altro (D-290).
##
##   godot --headless --path godot --script res://cli/run_lives_probe.gd -- \
##       --sagas=12 --chronicles=8 --seed=812 --then=CHR_02 [--out=FILE]
##
## Una casa ha piu' vite (`incarnations`, D-108/D-109): il popolo che si insedia
## diventa regno, la scuola diventa culto, il regno diventa repubblica. Le vite
## sono scritte; quello che nessuno aveva mai contato e' **quante di quelle
## scritte si siedono davvero al tavolo**, e dopo quanto tempo.
##
## E' la misura che viene prima della soglia di trasformazione: una vita che in
## dodici saghe non si e' mai seduta e' contenuto che esiste nei dati e non
## esiste al tavolo (D-035), e una porta in piu' non si progetta senza sapere
## quante di quelle che ci sono si aprono.
##
## Deterministica: stessi semi, stesso conto.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## Le tre fasce del tempo fra un anno giocato e il prossimo. Non sono d'autore:
## escono dai salti misurati (da 20 a 200 anni, mediana 100).
const SHORT: int = 50
const LONG: int = 150


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var sagas: int = int(options.get("sagas", 12))
	var chronicles: int = int(options.get("chronicles", 8))
	var first_seed: int = int(options.get("seed", 812))
	var first_id: String = str(options.get("chronicle", "CHR_01"))
	var later_id: String = str(options.get("then", "CHR_02"))
	var out_path: String = str(options.get("out", ""))
	# **I due tavoli, come al cancello.** Quante case si trasformano dipende da
	# come si gioca: quattro ottimizzatori scavano il mondo in un modo, un tavolo
	# di caratteri misti in un altro. Misurare uno solo vorrebbe dire tarare la
	# soglia su meta' del gioco.
	var tables: Array = ["uniforme", "misto"]

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Le vite scritte, per nome: e' il paniere su cui si conta chi si siede.
	# La prima vita di ogni casa non conta - quella siede sempre, per forza.
	var written: Array = []
	for entity_id in data.entities:
		var lives: Array = (data.entities[str(entity_id)] as Dictionary).get("incarnations", [])
		for index in range(1, lives.size()):
			var life: Dictionary = lives[index] as Dictionary
			written.append({
				"entity_id": str(entity_id),
				"id": str(life["id"]),
				"name": str(life["name"]),
				"entry": str(life.get("entry", "")),
				"tag": str(life.get("entry_tag", "")),
			})

	var seated: Dictionary = {}          # id della vita -> {tavolo: quante volte}
	var when_years: Dictionary = {}      # id della vita -> anni dall'inizio saga
	var jumps_by_band: Array = [0, 0, 0] # breve / medio / lungo
	var jumps: int = 0
	var mutations: int = 0
	var churn: Dictionary = {}           # casa -> mutazioni in tutte le saghe

	for table_name in tables:
		for saga_index in range(sagas):
			var seed_base: int = first_seed + saga_index * 1009
			var previous: Dictionary = {}
			var previous_results: Dictionary = {}
			var start_year: int = int(data.chronicles[first_id]["start_year"])
			for index in range(chronicles):
				var chronicle_id: String = first_id if index == 0 else later_id
				var session: RefCounted = GameSession.new(data)
				var seed_value: int = seed_base + index * 97
				var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
				session.setup(chronicle_id, seats, seed_value)
				session.inherit_from(previous, previous_results)
				if index > 0:
					jumps += 1
					var span: int = session.years_passed()
					if span < SHORT:
						jumps_by_band[0] += 1
					elif span <= LONG:
						jumps_by_band[1] += 1
					else:
						jumps_by_band[2] += 1
					for entity_id in session.handover():
						var seat: Dictionary = session.handover()[entity_id] as Dictionary
						if not bool(seat.get("transformed", false)):
							continue
						mutations += 1
						churn[str(entity_id)] = int(churn.get(str(entity_id), 0)) + 1
						var who: String = str(seat["name"])
						var life_id: String = _life_id(data, str(entity_id), who)
						var tally: Dictionary = seated.get(life_id, {}) as Dictionary
						tally[str(table_name)] = int(tally.get(str(table_name), 0)) + 1
						seated[life_id] = tally
						var elapsed: Array = when_years.get(life_id, []) as Array
						elapsed.append(int(session.world["year"]) - start_year)
						when_years[life_id] = elapsed
				var brain: RefCounted = (
					PolicyDecider.new(session.log) if str(table_name) == "uniforme"
					else Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
				)
				var report: Dictionary = await session.run(brain)
				previous = session.world
				previous_results = report.get("destiny_results", {})

	var lines: PackedStringArray = PackedStringArray()
	lines.append("# Le vite delle case, contate")
	lines.append("")
	lines.append("Generato da `cli/run_lives_probe.gd` — non si scrive a mano.")
	lines.append("")
	lines.append("    godot --headless --path godot --script res://cli/run_lives_probe.gd -- \\")
	lines.append("        --sagas=%d --chronicles=%d --seed=%d --then=%s" % [
		sagas, chronicles, first_seed, later_id
	])
	lines.append("")
	lines.append("Una casa ha piu' vite scritte: il popolo diventa regno, la scuola")
	lines.append("diventa culto, il regno diventa repubblica. Qui si conta **quante di")
	lines.append("quelle vite si siedono davvero al tavolo**, giocando %d saghe da %d" % [
		sagas, chronicles
	])
	lines.append("anni **su due tavoli** — quattro ottimizzatori e un tavolo di")
	lines.append("caratteri misti, come al cancello — e dopo quanto tempo.")
	lines.append("")
	lines.append("| | |")
	lines.append("|---|---|")
	lines.append("| vite scritte oltre la prima | %d |" % written.size())
	var never: int = 0
	for life in written:
		if (seated.get(str((life as Dictionary)["id"]), {}) as Dictionary).is_empty():
			never += 1
	lines.append("| **vite che non si sono mai sedute** | **%d** |" % never)
	lines.append("| salti d'era giocati | %d |" % jumps)
	lines.append("| trasformazioni sedute | %d |" % mutations)
	lines.append("| salti brevi (sotto %d anni) / medi / lunghi (oltre %d) | %d / %d / %d |" % [
		SHORT, LONG, jumps_by_band[0], jumps_by_band[1], jumps_by_band[2]
	])
	lines.append("")
	lines.append("## Le vite, una per una")
	lines.append("")
	lines.append("| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |")
	lines.append("|---|---|---|---|---|---|---|")
	written.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var left: int = _total(seated.get(str(a["id"]), {}))
		var right: int = _total(seated.get(str(b["id"]), {}))
		if left != right:
			return left > right
		return str(a["id"]) < str(b["id"])
	)
	for life in written:
		var entry: Dictionary = life as Dictionary
		var tally: Dictionary = seated.get(str(entry["id"]), {}) as Dictionary
		var years: Array = when_years.get(str(entry["id"]), []) as Array
		years.sort()
		lines.append("| %s | %s | %s | %s | %s | %s | %s |" % [
			_cell(int(tally.get("uniforme", 0))), _cell(int(tally.get("misto", 0))),
			str(entry["name"]), str(entry["entity_id"]), str(entry["entry"]),
			("`%s`" % str(entry["tag"])) if str(entry["tag"]) != "" else "—",
			str(years[years.size() / 2]) if not years.is_empty() else "—",
		])
	lines.append("")
	lines.append("## Quanto spesso una casa cambia pelle")
	lines.append("")
	lines.append("Una casa che muta a ogni salto non ha un'identita': ha un costume.")
	lines.append("Il conto e' mutazioni su %d salti giocati." % jumps)
	lines.append("")
	lines.append("| casa | mutazioni | ogni quanti salti |")
	lines.append("|---|---|---|")
	var houses: Array = churn.keys()
	houses.sort()
	for entity_id in houses:
		var many: int = int(churn[str(entity_id)])
		lines.append("| %s | %d | 1 ogni %.1f |" % [
			str(entity_id), many, float(jumps) / float(maxi(1, many))
		])
	lines.append("")
	var text: String = "\n".join(lines) + "\n"
	if out_path == "":
		print(text)
	else:
		var handle: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
		if handle == null:
			printerr("non riesco a scrivere %s" % out_path)
			quit(3)
			return
		handle.store_string(text)
		handle.close()
	quit(0)


## Zero si scrive in grassetto: e' il numero che conta, non il rumore.
func _cell(count: int) -> String:
	return "**0**" if count == 0 else str(count)


func _total(tally: Variant) -> int:
	var sum: int = 0
	for key in (tally as Dictionary):
		sum += int((tally as Dictionary)[key])
	return sum


## Il nome della vita seduta torna dall'handover; l'id lo si ritrova nei dati.
## Due vite con lo stesso nome non esistono (il validatore lo vieta).
func _life_id(data: RefCounted, entity_id: String, name: String) -> String:
	for life in (data.entities[entity_id] as Dictionary).get("incarnations", []):
		if str((life as Dictionary)["name"]) == name:
			return str((life as Dictionary)["id"])
	return name


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
