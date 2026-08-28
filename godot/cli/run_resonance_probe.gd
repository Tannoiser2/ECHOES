extends SceneTree
## Quante volte il mondo risponde (ISSUES 69, D-257).
##
##   godot --headless --path godot --script res://cli/run_resonance_probe.gd -- \
##       --runs=100 --seed=7000
##
## La Risonanza e' la regola che il committente ha messo al centro della
## direzione fisica: *ogni Azione ha una reazione del mondo, e non si sceglie.*
## Una regola cosi' vive o muore su un numero solo — **quanto spesso succede**.
## Se risponde a una carta su venti non e' una regola, e' un caso; se risponde a
## ogni carta, e' una tassa.
##
## La sonda conta le carte giocate, quelle che hanno una faccia fisica, e le
## Risonanze che ne escono, divise per Tema. Non decide niente: la partita con e
## senza sonda finisce uguale.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var played: int = 0        # carte giocate
	var faced: int = 0         # di quelle, con una faccia fisica
	var answered: int = 0      # e quante hanno fatto rispondere il mondo
	var bridged: int = 0       # di quelle, quante hanno anche avvicinato una questione
	var per_theme: Dictionary = {}
	var per_card: Dictionary = {}
	var per_event: Dictionary = {}   # firma della giocata -> gettoni caduti
	var marks: int = 0         # le Risonanze aggravate, che lasciano un segno

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
		var report: Dictionary = await session.run(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return
		# Il verbale degli Effetti dice cosa e' successo davvero: la Risonanza e'
		# un Effetto come gli altri, e chiederlo al log invece che al codice e'
		# l'unico modo di misurare la regola e non la propria intenzione.
		for entry in (session.world["effect_log"] as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			var source: Dictionary = effect.get("source", {}) as Dictionary
			# La Risonanza si firma: `kind` vale «resonance» e `id` porta la
			# carta. La prima stesura di questa sonda cercava un `template` che
			# la sorgente non ha mai avuto, e ha contato **zero** su venti anni
			# mentre le Risonanze avvenivano. Zero e' la risposta piu' pericolosa
			# che una sonda possa dare.
			if str(source.get("kind", "")) != "resonance":
				continue
			var asset_id: String = str(source.get("id", ""))
			if asset_id == "":
				continue
			var card: Variant = data.assets.get(asset_id)
			if card == null:
				continue
			var face: Dictionary = (card as Dictionary).get("physical", {}) as Dictionary
			if face.is_empty():
				continue
			var echo: Dictionary = face.get("resonance", {}) as Dictionary
			if echo.is_empty():
				continue
			# **La risposta del mondo e' il mazzetto** (D-261): ogni Risonanza fa
			# cadere gettoni coperti sul suo Tema — anche quando nessuna
			# questione di quel Tema e' in gioco, dove prima cadeva nel vuoto.
			# I gettoni della stessa carta giocata condividono la firma
			# (carta, atto, round, sequenza): raggrupparli distingue **quante
			# volte il mondo ha risposto** da **quanti gettoni sono caduti».
			# Il ponte sulle Tensioni si conta a parte, perche' e' lui che
			# avvicina i Consigli finche' le Domande vivono li'.
			if str(effect.get("type", "")) == "ADJUST_THEME_HEAT":
				# Il seme in testa alla firma: due anni diversi possono avere la
				# stessa (carta, atto, round, sequenza), e senza il seme i loro
				# gettoni si sommerebbero in un evento solo.
				var stamp: String = "%d|%s|%d|%d|%d" % [
					seed_value, asset_id, int(source.get("act", 0)),
					int(source.get("round", 0)), int(source.get("sequence", 0)),
				]
				per_event[stamp] = int(per_event.get(stamp, 0)) + 1
				if int(per_event[stamp]) == 1:
					answered += 1
					var theme: String = str(echo.get("theme", ""))
					per_theme[theme] = int(per_theme.get(theme, 0)) + 1
					per_card[asset_id] = int(per_card.get(asset_id, 0)) + 1
				# **L'aggravata si riconosce dai gettoni in piu'.** Il Calore
				# base scritto sulla carta dice quanti ne cadono sempre: il
				# gettone oltre quel numero e' la meta' condizionale scattata.
				# (La stesura precedente guardava il delta, che adesso e' il
				# valore pescato dal sacchetto: avrebbe contato aggravata ogni
				# pesca da 2 — un numero sbagliato in silenzio.)
				if int(per_event[stamp]) == int(echo.get("heat", 1)) + 1:
					marks += 1
			if str(effect.get("type", "")) == "ADJUST_TENSION":
				bridged += 1
		played += int((session.world.get("cards_played_count", 0)))
		session.dispose()

	print("")
	print("== QUANTE VOLTE IL MONDO RISPONDE - %d anni, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme",
	])
	print("")
	var faces: int = 0
	for asset_id in data.assets:
		if (data.assets[str(asset_id)] as Dictionary).has("physical"):
			faces += 1
	print("  Carte con una faccia fisica: %d su %d" % [faces, data.assets.size()])
	print("  Risonanze avvenute:          %d in %d anni  (%.1f per anno)" % [
		answered, runs, float(answered) / float(maxi(1, runs)),
	])
	print("  Di quelle, col ponte:        %d — hanno anche avvicinato una questione in gioco" % bridged)
	print("  Di quelle, aggravate:        %d  (%.1f%%) — il bersaglio portava gia' il segno temuto" % [
		marks, 100.0 * float(marks) / float(maxi(1, answered)),
	])
	print("")
	print("  Su quale Tema finisce il Calore:")
	var themes: Array = per_theme.keys()
	themes.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(per_theme[a]) > int(per_theme[b])
	)
	for theme in themes:
		var title: String = str((data.themes.get(str(theme), {}) as Dictionary).get("title", theme))
		print("    %-18s %6d  %5.1f%%" % [
			title, int(per_theme[theme]),
			100.0 * float(int(per_theme[theme])) / float(maxi(1, answered)),
		])
	print("")
	print("  Quali carte fanno rispondere il mondo:")
	var cards: Array = per_card.keys()
	cards.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(per_card[a]) > int(per_card[b])
	)
	for asset_id in cards:
		print("    %-30s %5d" % [
			str((data.assets[str(asset_id)] as Dictionary)["title"]), int(per_card[asset_id]),
		])
	var silent: Array = []
	for asset_id in data.assets:
		var card: Dictionary = data.assets[str(asset_id)]
		if card.has("physical") and not per_card.has(str(asset_id)):
			silent.append(str(card["title"]))
	if not silent.is_empty():
		print("")
		print("  E quelle che non hanno mai risposto (%d): %s" % [
			silent.size(), ", ".join(PackedStringArray(silent)),
		])
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not str(argument).begins_with("--"):
			continue
		var pair: PackedStringArray = str(argument).substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
