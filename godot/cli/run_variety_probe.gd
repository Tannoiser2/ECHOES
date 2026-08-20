extends SceneTree
## Quanto si somigliano due saghe? (D-149)
##
##   godot --headless --path godot --script res://cli/run_variety_probe.gd -- \
##       --sagas=4 --chronicles=6 --seed=3000 --chronicle=CHR_01 --then=CHR_02
##
## Le sonde di questo progetto misurano il **motore**: gli esiti in banda, i
## seggi non bloccati, il filo trasparente, le fughe. Nessuna sa rispondere a
## «le partite sono diverse fra loro?», che e' una domanda sul **contenuto** —
## e senza una risposta, aggiungere varieta' e' aggiungere e sperare.
##
## Il metro sono le **Truth**: le frasi che una decisione lascia scritte nel
## registro. Sono il prodotto del gioco — quello che al tavolo si legge ad alta
## voce e che resta fra una Chronicle e l'altra — quindi due saghe che scrivono
## le stesse frasi hanno raccontato la stessa storia, per quanto diversi siano
## stati i numeri.
##
## Tre numeri, e il terzo e' quello che conta:
##   · **frasi distinte** — quante frasi diverse ha prodotto ognuna;
##   · **il nocciolo** — quante frasi compaiono in TUTTE le saghe: il fondo che
##     torna sempre, qualunque seme;
##   · **la distanza** — la media, su ogni coppia di saghe, di quanto le loro
##     frasi NON si sovrappongono (Jaccard: 0 = identiche, 1 = niente in comune).

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const LEVELS: Array = ["NONE", "MINIMUM", "VICTORY", "TRIUMPH"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var sagas: int = int(options.get("sagas", 4))
	var chronicles: int = int(options.get("chronicles", 6))
	var first_seed: int = int(options.get("seed", 3000))
	var first_id: String = str(options.get("chronicle", "CHR_01"))
	var later_id: String = str(options.get("then", first_id))
	# A tavolo misto per scelta: i quattro caratteri (D-053) sono la cosa piu'
	# vicina a persone vere che questo progetto abbia, e la varieta' si misura
	# su come giocano loro — quattro ottimizzatori identici sono il caso in cui
	# la ripetizione e' garantita per costruzione.
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var per_saga: Array = []
	var levels: Dictionary = {}
	var lives: Dictionary = {}
	for saga in range(sagas):
		var said: Dictionary = {}
		var carried: Dictionary = {}
		var results: Dictionary = {}
		var year: int = 0
		for index in range(chronicles):
			var chronicle_id: String = first_id if index == 0 else later_id
			var seed_value: int = first_seed + saga * 1000 + index
			var session: RefCounted = GameSession.new(data)
			var seats: Array = (data.chronicles[first_id]["entities"] as Array).duplicate()
			session.setup(chronicle_id, seats, seed_value)
			# L'eredita' e' la stessa di `run_saga`: il mondo di prima e i Destini
			# di prima, applicati dentro `run()`.
			session.inherit_from(carried, results)
			var decider: RefCounted = (
				Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
				else PolicyDecider.new(session.log)
			)
			var report: Dictionary = await session.run(decider)
			for entry in session.world["truth_log"]:
				said[_bare(str(entry["text"]))] = true
			for entity_id in seats:
				var level: String = str(report["destiny_results"][str(entity_id)]["level"])
				levels[level] = int(levels.get(level, 0)) + 1
			# La vita, non il seggio: `incarnation` e' l'indice nella catena delle
			# vite di quella casa, quindi «ENT_NAHR#2» e' il Regno e non il
			# Popolo. La prima stesura leggeva un campo che non esiste e
			# riportava quattro vite in trenta Chronicle — un numero che non
			# tornava guardando le saghe raccontate, ed e' cosi' che si e' visto.
			for entity_id in session.world["entities"]:
				var seat: Dictionary = session.world["entities"][str(entity_id)]
				lives["%s#%d" % [str(entity_id), int(seat.get("incarnation", 0))]] = true
			carried = (session.world as Dictionary).duplicate(true)
			results = (report["destiny_results"] as Dictionary).duplicate(true)
			year = int(session.world["year"])
			session.dispose()
		per_saga.append(said.keys())
		print("  saga %d/%d (semi da %d): %d frasi distinte, fino all'anno %d" % [
			saga + 1, sagas, first_seed + saga * 1000, (said.keys() as Array).size(), year
		])

	# Il nocciolo: le frasi che compaiono in tutte.
	var core: Dictionary = {}
	for text in per_saga[0]:
		var everywhere: bool = true
		for other in per_saga:
			if not (other as Array).has(text):
				everywhere = false
				break
		if everywhere:
			core[str(text)] = true

	# La distanza media fra due saghe qualsiasi.
	var total: float = 0.0
	var pairs: int = 0
	for i in range(sagas):
		for j in range(i + 1, sagas):
			var a: Array = per_saga[i]
			var b: Array = per_saga[j]
			var shared: int = 0
			for text in a:
				if b.has(text):
					shared += 1
			var union: int = a.size() + b.size() - shared
			total += 0.0 if union == 0 else 1.0 - float(shared) / float(union)
			pairs += 1

	var distinct: int = 0
	var seen: Dictionary = {}
	for said in per_saga:
		for text in said:
			seen[str(text)] = true
	distinct = seen.size()

	print("")
	print("== LA DISTANZA FRA LE SAGHE - %d saghe da %d Chronicle, tavolo %s ==" % [
		sagas, chronicles, "misto" if mixed else "uniforme"
	])
	print("  Frasi distinte in tutto: %d" % distinct)
	print("  Il nocciolo (in tutte le saghe): %d frasi — il %.0f%% di una saga media" % [
		core.size(), 100.0 * float(core.size()) / maxf(1.0, float(distinct) / float(sagas))
	])
	print("  DISTANZA MEDIA: %.2f  (0 = saghe identiche, 1 = niente in comune)" % (
		total / maxf(1.0, float(pairs))
	))
	var line: Array = []
	for level in LEVELS:
		line.append("%s %d" % [level, int(levels.get(level, 0))])
	print("  Destini raggiunti: %s" % "  ".join(PackedStringArray(line)))
	print("  Vite viste al tavolo: %d" % lives.size())
	quit(0)


## La frase nuda. Una Truth nasce con l'anno davanti («Anno 1640, Atto 2: …»)
## e il punteggio dietro («(S5 O0 M7)»): tenerli dentro vuol dire che due saghe
## non condividono **mai** una frase, e la prima stesura di questa sonda ha
## infatti riportato distanza 1,00 e nocciolo zero — un numero perfetto che
## misurava l'orologio invece della storia. Quello che conta e' cosa e' stato
## deciso, non quando e con che margine.
static func _bare(text: String) -> String:
	var out: String = text
	var colon: int = out.find(": ")
	if out.begins_with("Anno ") and colon > 0:
		out = out.substr(colon + 2)
	var score: int = out.rfind(" (S")
	if score > 0:
		out = out.substr(0, score)
	return out.strip_edges()


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for argument in args:
		if not argument.begins_with("--"):
			continue
		var pair: PackedStringArray = argument.substr(2).split("=", true, 1)
		options[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return options
