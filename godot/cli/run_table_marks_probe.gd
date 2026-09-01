extends SceneTree
## Quali segni arrivano sul tavolo, posto per posto
##
##   godot --headless --path godot --script res://cli/run_table_marks_probe.gd -- \
##       --runs=100 --seed=7000 --chronicle=CHR_00
##
## La sonda dei segni (`run_world_marks_probe.gd`) guarda **le memorie del mondo
## e le condizioni dei luoghi**: sessantasei segni su duecentoquattro. Degli altri
## centotrentotto non sapeva niente nessuno — e dentro c'erano **tutte** le
## Cicatrici, **tutte** le Pietre e tutto quello che sta sulla scheda di una casa.
##
## Questa parte dall'altra domanda, quella del committente: *«tutti questi tag
## devono essere equilibrati e non devono essere 200 con alcuni che non vengono
## mai posati o letti e altri che sono sempre chiamati».* Per rispondere serve
## guardare **ogni** segno che sul tavolo ha un pezzo di cartone — i 180 con un
## `table_place` diverso da NONE (D-350) — e dirlo **posto per posto**, perche'
## un gettone di condizione che esce trenta volte e una Cicatrice che non esce
## mai sono due difetti diversi e stanno in due sacchetti diversi.
##
## **Le Pietre non passano dal registro degli Effetti.** `_apply_grade_tag` le
## scrive dritte dentro `region["tags"]`: una sonda che legge solo il log e'
## cieca su tutte e ventisette, e questa lo sarebbe stata. Percio' qui si
## guardano anche BUILD_STRUCTURE, SET_STRUCTURE_GRADE e RAZE_STRUCTURE, e il
## segno si ricava dal grado, come fa il motore.
##
## Tre numeri per ogni segno, e il primo non e' il secondo:
##
##   · **all'apertura** — in quante partite sta gia' sul tavolo quando si comincia.
##     Per un segno stampato sulla tessera e' tutta la sua vita: nessuno lo posa
##     perche' c'e' gia'.
##   · **posato** — quante volte la partita lo mette, dopo l'apertura.
##   · **tolto** — quante volte la partita lo leva. Su un dischetto rotondo il
##     numero e' basso e non zero: **togliere una Cicatrice e' raro, non
##     impossibile** (D-357). Serve un pezzo che sappia farlo, e non capita da
##     solo ne' a fine Atto come per una condizione.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## I sette posti, nell'ordine in cui si guarda il tavolo: prima la tessera, poi
## quello che ci si posa sopra e accanto, poi la casa, poi il mondo.
const PLACES := [
	["TILE_PRINTED", "stampato sulla tessera",
		"la natura del luogo. Nessuno lo posa: c'e' gia'."],
	["TILE_SLOT", "uno spazio sulla tessera",
		"le Pietre e i gradi che le degradano."],
	["ZONE_TOKEN", "un gettone accanto alla tessera",
		"lo stato di adesso: si mette e si toglie."],
	["SCAR_TOKEN", "un dischetto rotondo",
		"le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo."],
	["HOUSE_SHEET", "sulla scheda della casa",
		"chi sei adesso, e la vita che stai vivendo."],
	["WORLD_MEMORY", "un gettone sul bordo della mappa",
		"quello che il mondo ricorda (ISSUES 110)."],
]

const PUTS := ["SET_REGION_TAG", "SET_GLOBAL_TAG", "SET_ENTITY_TAG"]
const TAKES := ["REMOVE_REGION_TAG", "REMOVE_GLOBAL_TAG", "REMOVE_ENTITY_TAG"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")
	var out_path: String = str(options.get("out", ""))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Ogni segno che sul tavolo ha un pezzo di cartone. NONE resta fuori: e'
	# contabilita' del motore, e nessuna fustella la taglia.
	var place_of: Dictionary = {}
	for tag_id in data.tags:
		var place: String = str((data.tags[tag_id] as Dictionary).get("table_place", ""))
		if place != "" and place != "NONE":
			place_of[str(tag_id)] = place
	if place_of.is_empty():
		printerr("nessun segno dichiara un posto sul tavolo: il dizionario e' vecchio")
		quit(3)
		return

	# Il segno che ogni grado di ogni Pietra posa. Il motore lo ricava cosi', e
	# se qui si sbagliasse la sonda direbbe zero su tutte le Pietre.
	var grade_tags: Dictionary = {}
	for type_id in data.structure_types:
		var grades: Array = (data.structure_types[type_id] as Dictionary).get("grades", []) as Array
		var tags: Array = []
		for grade in grades:
			tags.append(str((grade as Dictionary).get("tag", "")))
		grade_tags[str(type_id)] = tags

	var at_setup: Dictionary = {}
	var at_end: Dictionary = {}
	var placed: Dictionary = {}
	var removed: Dictionary = {}
	for run in range(runs):
		var seed_value: int = first_seed + run
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr("setup fallito: %s" % session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		# Quello che c'e' gia' quando si comincia: per un segno stampato sulla
		# tessera e' l'unica cosa vera che si possa dire di lui.
		for seen in _on_the_table(session.world, place_of):
			at_setup[seen] = int(at_setup.get(seen, 0)) + 1
		var from_setup: int = (session.world["effect_log"] as Array).size()

		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return

		var scar_tag: Dictionary = {}
		var log_entries: Array = session.world["effect_log"] as Array
		for index in range(from_setup, log_entries.size()):
			var e: Dictionary = (
				(log_entries[index] as Dictionary).get("effect", log_entries[index])
			) as Dictionary
			var kind: String = str(e.get("type", ""))
			var payload: Dictionary = (e.get("payload", {}) as Dictionary)
			if PUTS.has(kind) or TAKES.has(kind):
				var what: String = str(payload.get("tag", ""))
				if what == "" or not place_of.has(what):
					continue
				if PUTS.has(kind):
					placed[what] = int(placed.get(what, 0)) + 1
				else:
					removed[what] = int(removed.get(what, 0)) + 1
				continue
			# Le Cicatrici hanno un blocco loro: non sono un SET_REGION_TAG, e la
			# prima stesura di questa sonda non le vedeva — dodici Cicatrici su
			# tredici sembravano non arrivare mai, e invece.
			if kind == "ADD_SCAR":
				var mark: String = str(payload.get("tag", ""))
				if mark != "" and place_of.has(mark):
					placed[mark] = int(placed.get(mark, 0)) + 1
					scar_tag[str(payload.get("scar_id", ""))] = mark
				continue
			if kind == "REMOVE_SCAR":
				var gone: String = str(scar_tag.get(str(payload.get("scar_id", "")), ""))
				if gone != "" and place_of.has(gone):
					removed[gone] = int(removed.get(gone, 0)) + 1
				continue
			# Le Pietre: il segno sta nel grado, non nel payload.
			if kind == "BUILD_STRUCTURE" or kind == "SET_STRUCTURE_GRADE" or kind == "RAZE_STRUCTURE":
				var type_id: String = str(payload.get("structure_type", ""))
				var tags: Array = grade_tags.get(type_id, []) as Array
				if tags.is_empty():
					continue
				var grade: int = int(payload.get("grade", 1))
				var tag: String = ""
				if kind == "RAZE_STRUCTURE":
					tag = str(tags[0])
				elif grade > 0 and grade <= tags.size():
					tag = str(tags[grade - 1])
				if tag == "" or not place_of.has(tag):
					continue
				if kind == "RAZE_STRUCTURE":
					removed[tag] = int(removed.get(tag, 0)) + 1
				else:
					placed[tag] = int(placed.get(tag, 0)) + 1
		# La misura che non dipende da quali Effetti la sonda sa leggere: cosa
		# c'e' sul tavolo quando la partita finisce. Se un segno e' li', ci e'
		# arrivato — comunque ci sia arrivato.
		for seen in _on_the_table(session.world, place_of):
			at_end[seen] = int(at_end.get(seen, 0)) + 1
		session.dispose()

	_report(
		runs, mixed, place_of, at_setup, at_end, placed, removed, out_path,
		_beyond_the_year(data, place_of)
	)


## I segni che stanno sul tavolo adesso, guardati dove stanno davvero: sulle
## tessere, sulle case, sul mondo. **Non** dal registro degli Effetti, che dei
## segni stampati e delle Pietre non sa niente.
func _on_the_table(world: Dictionary, place_of: Dictionary) -> Array:
	var seen: Dictionary = {}
	for region_id in (world.get("regions", {}) as Dictionary):
		var region: Dictionary = (world["regions"] as Dictionary)[region_id] as Dictionary
		for tag in (region.get("tags", []) as Array):
			if place_of.has(str(tag)):
				seen[str(tag)] = true
	for entity_id in (world.get("entities", {}) as Dictionary):
		var entity: Dictionary = (world["entities"] as Dictionary)[entity_id] as Dictionary
		for tag in (entity.get("tags", []) as Array):
			if place_of.has(str(tag)):
				seen[str(tag)] = true
	for tag in (world.get("global_tags", []) as Array):
		if place_of.has(str(tag)):
			seen[str(tag)] = true
	return seen.keys()


## **I segni che questa sonda non puo' vedere, ricavati** (D-376).
##
## Gioca un anno per partita: il passaggio di consegne fra un'era e l'altra non
## avviene mai. Due famiglie si scrivono **solo li'**:
##
## - `life:<id>` — lo posa il seggio quando una vita oltre la prima si siede
##   (`GameSession`, D-109). Uno per incarnazione scritta, e si ricava dalle
##   Case: non si ricopia una lista.
## - `legend:<fatto>` — lo posa la sbiadita di un salto lungo su un fatto che la
##   Cronaca non dichiara duraturo (`WorldStateFactory`).
##
## Quelle si misurano in `MISURA_VITE.md`, che le saghe le gioca.
static func _beyond_the_year(data: RefCounted, place_of: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for entity_id in data.entities:
		var lives: Array = (data.entities[str(entity_id)] as Dictionary).get(
			"incarnations", []
		) as Array
		for index in range(1, lives.size()):
			out["life:%s" % str((lives[index] as Dictionary)["id"])] = true
	for tag in place_of:
		if str(tag).begins_with("legend:"):
			out[str(tag)] = true
	return out


func _report(
	runs: int, mixed: bool, place_of: Dictionary, at_setup: Dictionary,
	at_end: Dictionary, placed: Dictionary, removed: Dictionary, out_path: String,
	beyond_the_year: Dictionary
) -> void:
	var lines: Array = []
	lines.append("# ECHOES — quali segni arrivano sul tavolo, posto per posto")
	lines.append("")
	lines.append("<!-- FILE GENERATO — si rifa' con `tools/run_table_survey.sh`. -->")
	lines.append("")
	lines.append("Ogni segno che sul tavolo ha un pezzo di cartone — i **%d** con un posto" % place_of.size())
	lines.append("dichiarato (D-350) — e se in cento partite ci arriva davvero.")
	lines.append("")
	lines.append("La sonda dei segni ne guardava 66: le memorie del mondo e le condizioni dei")
	lines.append("luoghi. Questa li guarda tutti, **posto per posto**, perche' un gettone che")
	lines.append("esce trenta volte e una Cicatrice che non esce mai sono due difetti diversi.")
	lines.append("")
	lines.append("**all'apertura** = in quante partite c'e' gia' quando si comincia ·")
	lines.append("**posato** = quante volte la partita lo mette · **tolto** = quante volte lo leva ·")
	lines.append("**a fine partita** = in quante partite e' sul tavolo alla fine.")
	lines.append("")
	lines.append("L'ultima colonna e' quella di cui fidarsi: non passa dal registro degli")
	lines.append("Effetti, guarda il tavolo. Le prime tre dipendono da quali Effetti questa")
	lines.append("sonda sa leggere, e in questo progetto quella e' la strada di sette difetti.")
	lines.append("")
	lines.append("**E %d segni sono fuori dalla portata di questa misura** (D-376): questa" % beyond_the_year.size())
	lines.append("sonda gioca **un anno per partita**, e loro il motore li scrive solo al")
	lines.append("passaggio di consegne fra un'era e l'altra — la vita che si siede, il fatto")
	lines.append("che sbiadisce in leggenda. Chiamarli «non arriva mai» accanto a un segno")
	lines.append("che davvero nessuno posa metterebbe due difetti diversi sotto la stessa")
	lines.append("parola. Quelli li misura [MISURA_VITE.md](MISURA_VITE.md), che gioca le saghe.")
	lines.append("")
	lines.append("Misura: `cli/run_table_marks_probe.gd`, %d partite, tavolo %s, semi da 7000."
		% [runs, "misto" if mixed else "uniforme"])
	lines.append("")

	var never_any: Array = []
	for entry in PLACES:
		var key: String = str(entry[0])
		var here: Array = []
		for tag in place_of:
			if str(place_of[tag]) == key:
				here.append(str(tag))
		here.sort()
		if here.is_empty():
			continue
		var arrives: Array = []
		var never: Array = []
		for tag in here:
			if (int(at_setup.get(tag, 0)) > 0 or int(placed.get(tag, 0)) > 0
					or int(at_end.get(tag, 0)) > 0):
				arrives.append(tag)
			else:
				never.append(tag)
				never_any.append(tag)
		lines.append("## %s" % str(entry[1]))
		lines.append("")
		lines.append("%s" % str(entry[2]))
		lines.append("")
		lines.append("**%d segni: %d arrivano sul tavolo, %d non ci arrivano mai.**"
			% [here.size(), arrives.size(), never.size()])
		lines.append("")
		lines.append("| segno | all'apertura | posato | tolto | a fine partita | |")
		lines.append("|---|---|---|---|---|---|")
		for tag in here:
			var open_count: int = int(at_setup.get(tag, 0))
			var put_count: int = int(placed.get(tag, 0))
			var cut_count: int = int(removed.get(tag, 0))
			var end_count: int = int(at_end.get(tag, 0))
			var note: String = ""
			if open_count == 0 and put_count == 0 and end_count == 0:
				# **Uno zero che questa sonda non puo' evitare non e' una
				# misura** (D-376). Questa gioca `setup` + `run`: **un anno,
				# una partita**. I segni che il motore scrive solo al passaggio
				# di consegne fra un'era e l'altra — la vita che si siede, il
				# fatto che sbiadisce in leggenda — qui non possono arrivare
				# **per costruzione**, e chiamarli «non arriva mai» accanto a
				# un segno che davvero nessuno posa mette due cose diverse
				# sotto la stessa parola.
				note = (
					"*fuori portata: si scrive al salto d'era*"
					if beyond_the_year.has(tag) else "**non arriva mai**"
				)
			elif key == "SCAR_TOKEN" and put_count > 0 and cut_count > put_count:
				note = "**tolta piu' volte di quante si posa**"
			elif open_count == runs and put_count == 0:
				note = "sempre in tavola"
			lines.append("| `%s` | %d | %d | %d | %d | %s |"
				% [tag, open_count, put_count, cut_count, end_count, note])
		lines.append("")

	lines.append("## I segni che non arrivano mai")
	lines.append("")
	if never_any.is_empty():
		lines.append("Nessuno: ogni segno con un pezzo di cartone, in cento partite, ci arriva.")
	else:
		lines.append("Hanno un posto sul tavolo, e in cento partite non ci si posano mai.")
		lines.append("Sono **%d su %d**." % [never_any.size(), place_of.size()])
		lines.append("")
		lines.append("| segno | dove starebbe |")
		lines.append("|---|---|")
		never_any.sort()
		for tag in never_any:
			var where: String = ""
			for entry in PLACES:
				if str(entry[0]) == str(place_of[tag]):
					where = str(entry[1])
			lines.append("| `%s` | %s |" % [tag, where])
	lines.append("")

	var text: String = "\n".join(PackedStringArray(lines))
	if out_path != "":
		var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
		if file == null:
			printerr("non riesco a scrivere %s" % out_path)
			quit(3)
			return
		file.store_string(text)
		file.close()
	else:
		print(text)
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		var clean: String = arg.lstrip("-")
		if clean.contains("="):
			var halves: PackedStringArray = clean.split("=", true, 1)
			out[halves[0]] = halves[1]
		else:
			out[clean] = true
	return out
