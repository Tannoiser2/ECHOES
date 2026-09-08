extends SceneTree
## **Quante scelte fa davvero chi gioca, e quante alternative ha a ognuna**
## (ISSUES 132, parola del committente: *«il gioco forse e' troppo
## semplificato, quali sono le effettive scelte che fa un giocatore?»*).
##
##   godot --headless --path godot --script res://cli/run_agency_probe.gd -- --runs=100
##
## Le sonde di questo progetto misurano cosa **il mondo** fa: gli esiti in
## banda, i seggi non bloccati, le Conseguenze che non escono. Nessuna misura
## quello che sta dall'altra parte del tavolo — **quante volte in un anno il
## gioco si ferma e chiede a una persona di decidere**, e quanto e' larga la
## forcella quando lo fa.
##
## E' il numero che decide se un gioco e' sottile o povero, e non si legge nel
## codice: i punti di decisione sono sette (l'interfaccia del decisore), ma
## sette punti di decisione con due opzioni ciascuno sono un gioco diverso da
## sette con dieci.
##
## Si misurano tutt'e due le cose, perche' separate mentono:
##
##   · **quante volte** il gioco chiede — la frequenza;
##   · **quanto e' largo il menu** — la forcella, media e massimo;
##   · e per l'Azione, **quante opzioni distinte per verbo**: dieci modi di
##     fare la stessa cosa non sono dieci scelte.
##
## Un cane da guardia si siede fra il cervello e il motore e conta, senza
## decidere niente: la stessa forma dello `Spy` di `run_boxes_probe`. Il menu
## dell'Azione e' quello **vero** — quello che il decisore umano stampa
## (`SeatDecider._action_options`), non una lista ricostruita a mano, o la
## sonda misurerebbe una lista sua.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## `punto -> {"volte": int, "opzioni": int, "max": int}`
var asked: Dictionary = {}
## Per l'Azione: quanti verbi distinti offriva il menu, ogni volta.
var verbs_offered: int = 0
var verb_samples: int = 0
var one_verb_only: int = 0
## Quante volte il menu dell'Azione offriva **una cosa sola** (o niente).
var no_choice: int = 0


func _note(point: String, options: int) -> void:
	var row: Dictionary = asked.get(point, {"volte": 0, "opzioni": 0, "max": 0})
	row["volte"] = int(row["volte"]) + 1
	row["opzioni"] = int(row["opzioni"]) + options
	row["max"] = maxi(int(row["max"]), options)
	asked[point] = row


class Spy extends RefCounted:
	var inner: RefCounted
	var owner: Object
	var reader: RefCounted

	func _init(who: RefCounted, p_owner: Object, p_reader: RefCounted) -> void:
		inner = who
		owner = p_owner
		reader = p_reader

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		# Il menu vero: quello che una persona vedrebbe. «Passa» compresa,
		# perche' passare e' una scelta che al tavolo si fa.
		var options: Array = reader.call("_action_options", entity_id, session)
		owner.call("_note", "Azione (una carta, una faccia)", options.size() + 1)
		# **Il verbo sta sulla faccia, non sulla voce del menu.** Dopo il filtro
		# della mano (`_through_the_hand`) ogni voce diventa `PLAY_CARD`: la
		# prima stesura di questa sonda contava quello e diceva «1,57 verbi su
		# 7» — un numero bassissimo e falso, che e' la forma di cecita' che
		# questo progetto ha gia' avuto sei volte. Il verbo si legge dove sta:
		# la carta, e quale delle sue due facce.
		var verbs: Dictionary = {}
		for option in options:
			verbs[_verb_of(option as Dictionary, session)] = true
		verbs.erase("")
		owner.set("verbs_offered", int(owner.get("verbs_offered")) + verbs.size())
		owner.set("verb_samples", int(owner.get("verb_samples")) + 1)
		if verbs.size() <= 1:
			owner.set("one_verb_only", int(owner.get("one_verb_only")) + 1)
		if options.size() <= 1:
			owner.set("no_choice", int(owner.get("no_choice")) + 1)
		return await inner.choose_action(entity_id, ao_index, session)

	## Il verbo che una voce del menu farebbe girare: quello stampato sulla
	## faccia della carta, o il template diretto quando la Chronicle non fa
	## passare le Azioni dalle carte.
	func _verb_of(option: Dictionary, session: RefCounted) -> String:
		var template: String = str(option.get("template", ""))
		if template != "PLAY_CARD":
			return template
		var params: Dictionary = option.get("params", {}) as Dictionary
		var asset: Variant = session.data.assets.get(str(params.get("asset_id", "")))
		if asset == null:
			return ""
		var faces: Array = ((asset as Dictionary).get("physical", {}) as Dictionary).get(
			"actions", []
		) as Array
		var index: int = int(params.get("face_action", -1))
		if index < 0 or index >= faces.size():
			return ""
		return str((faces[index] as Dictionary).get("template", ""))


	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		owner.call("_note", "Quale domanda porti al Consiglio", options.size())
		return await inner.choose_question(context, options, session)

	func choose_side(entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted) -> Dictionary:
		# Le due parti, piu' restare fuori.
		var menu: int = (offer.get("A", []) as Array).size() + (offer.get("B", []) as Array).size()
		owner.call("_note", "Con quale parte stai, e con quale pedina", menu + 1)
		return await inner.choose_side(entity_id, context, offer, session)

	func choose_box(entity_id: String, context: Dictionary, menu: Array, side: String, session: RefCounted) -> String:
		owner.call("_note", "Quale casella posi", menu.size())
		return await inner.choose_box(entity_id, context, menu, side, session)

	func choose_raise(entity_id: String, context: Dictionary, menu: Array, session: RefCounted) -> String:
		owner.call("_note", "Rilanci o passi", menu.size() + 1)
		return await inner.choose_raise(entity_id, context, menu, session)

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		owner.call("_note", "Quante carte impegni al voto", int(context.get("hand_size", limit)) + 1)
		return await inner.choose_commit(entity_id, context, limit, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		owner.call("_note", "Quale carta ti riprendi", 2)
		return await inner.choose_recovery(context, session)


func _initialize() -> void:
	var runs: int = 100
	var first: int = 7000
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--runs="):
			runs = int(a.substr(7))
		elif a.begins_with("--seed="):
			first = int(a.substr(7))
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for e in data.errors:
			printerr("  %s" % e)
		quit(3)
		return

	for run in range(runs):
		var seed_value: int = first + run
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup("CHR_00", seats, seed_value):
			printerr(session.last_error)
			quit(3)
			return
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		var brain: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		# Il lettore del menu: un decisore umano che non decide niente, usato
		# solo per chiedergli «cosa vedresti adesso».
		var reader: RefCounted = SeatDecider.new([], session.log)
		await session.run(Spy.new(brain, self, reader))

	var total: int = 0
	for point in asked:
		total += int((asked[point] as Dictionary)["volte"])
	print("LE SCELTE DI CHI GIOCA - %d anni, semi da %d, quattro seggi" % [runs, first])
	print("")
	print("  %-38s %8s %8s %7s %6s" % ["il gioco chiede", "volte", "l'anno", "media", "max"])
	var order: Array = asked.keys()
	order.sort_custom(func(a, b) -> bool:
		return int((asked[a] as Dictionary)["volte"]) > int((asked[b] as Dictionary)["volte"])
	)
	for point in order:
		var row: Dictionary = asked[point]
		print("  %-38s %8d %8.1f %7.1f %6d" % [
			point, int(row["volte"]), float(row["volte"]) / float(runs),
			float(row["opzioni"]) / float(maxi(int(row["volte"]), 1)), int(row["max"]),
		])
	print("")
	print("  in tutto        %d scelte in %d anni — %.1f l'anno sul tavolo, %.1f a testa" % [
		total, runs, float(total) / float(runs), float(total) / float(runs) / 4.0,
	])
	print("")
	print("  L'AZIONE, GUARDATA DA VICINO")
	print("    verbi distinti nel menu, in media   %.2f su 7" % (
		0.0 if verb_samples == 0 else float(verbs_offered) / float(verb_samples)
	))
	print("    volte con un verbo solo o nessuno   %d su %d (%.0f%%)" % [
		one_verb_only, verb_samples,
		0.0 if verb_samples == 0 else 100.0 * float(one_verb_only) / float(verb_samples),
	])
	print("    volte senza una vera scelta         %d su %d (%.0f%%)" % [
		no_choice, verb_samples,
		0.0 if verb_samples == 0 else 100.0 * float(no_choice) / float(verb_samples),
	])
	quit(0)
