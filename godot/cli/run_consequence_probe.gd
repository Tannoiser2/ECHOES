extends SceneTree
## Perche' dieci Conseguenze non escono mai (ISSUES 56).
##
##   godot --headless --path godot --script res://cli/run_consequence_probe.gd -- \
##       --runs=100 --seed=7000
##
## [D-223](../docs/DECISIONS.md#d-223) ha contato **quante** Conseguenze non
## escono: dieci su cinquantadue, e sono i nomi grossi del catalogo — il drago
## che muore, la corona che si ricompone, il giuramento che si rompe. ISSUES 56
## chiede la seconda domanda, che e' quella che decide cosa fare:
##
## > per ognuna delle dieci, se la proposizione che la elenca sia mai stata
## > scelta, e se no perche' — **non idonea**, **mai proposta**, o **sempre
## > perdente**. Sono tre difetti diversi con tre rimedi diversi.
##
## Il modo di saperlo e' guardare il Consiglio da dentro mentre succede: chi
## decide riceve **le proposte idonee** e ne sceglie una. Un registratore si
## siede in mezzo, non decide niente, e scrive quello che passa — e' la stessa
## forma di `ConsoleIO`, che ascolta senza avere opinioni.
##
## E c'e' una quarta possibilita' che la voce non nomina, e i dati la dicono
## prima di qualunque partita: **una Conseguenza che nessuna proposta elenca**.
## Quattro delle dieci arrivano da una carta Echo, non da un Consiglio, e per
## quelle la domanda giusta e' un'altra: la carta e' mai uscita?
##
## E una quinta, che la voce non poteva nominare perche' la misura di allora non
## la vedeva: **contenuto che vive nella saga e non nell'anno**. Con `--saga=N`
## la sonda gioca N Chronicle di fila invece di N anni scollegati, ed e'
## l'unico modo di vedere le proposte che chiedono una **leggenda** — che nasce
## solo quando fra due anni giocati passano abbastanza decenni. Su anni
## scollegati quelle proposte sono morte per costruzione, e chiamarle morte
## sarebbe stato un errore della sonda, non un difetto del gioco.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## Chi ascolta il Consiglio senza parlarci.
##
## Inoltra ogni domanda a chi decide davvero e annota **cosa gli e' stato
## offerto** e **cosa ha scelto**. Non tocca il risultato: la stessa partita con
## e senza registratore finisce uguale, ed e' il motivo per cui i numeri di
## questa sonda valgono per la partita vera.
class Watcher extends RefCounted:
	var inner: RefCounted
	var offered: Dictionary = {}   # proposition_id -> volte offerta
	var chosen: Dictionary = {}    # proposition_id -> volte scelta
	var excluded: Dictionary = {}  # proposition_id -> volte esclusa con la sua domanda in tavola

	func _init(who: RefCounted) -> void:
		inner = who

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		return await inner.choose_action(entity_id, ao_index, session)

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		var here: Dictionary = {}
		for option in options:
			var id: String = str((option as Dictionary)["id"])
			here[id] = true
			offered[id] = int(offered.get(id, 0)) + 1
		# **Chi non e' stato offerto, e c'era il Consiglio giusto.** Sapere che
		# una proposta non e' mai arrivata sul tavolo non dice ancora perche':
		# il Consiglio non si e' mai tenuto, oppure si e' tenuto e lei e' stata
		# esclusa. Sono due difetti diversi con due rimedi diversi, e qui si
		# separano — contando solo le volte in cui **quella domanda** era sul
		# tavolo, perche' una proposta che risponde a un'altra domanda non e'
		# stata esclusa: non era in argomento.
		var template: Dictionary = session.data.confluence_templates[
			str(context["template_id"])
		] as Dictionary
		var asked: String = str(context.get("question_id", ""))
		for entry in template.get("propositions", []):
			var candidate: Dictionary = entry as Dictionary
			if here.has(str(candidate["id"])):
				continue
			if asked != "" and str(candidate.get("question_id", "")) != asked:
				continue
			var out: String = str(candidate["id"])
			excluded[out] = int(excluded.get(out, 0)) + 1
		var picked: String = await inner.choose_proposition(context, options, session)
		if picked != "":
			chosen[picked] = int(chosen.get(picked, 0)) + 1
		return picked

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_stance(entity_id, context, session)

	func choose_commit(
		entity_id: String, context: Dictionary, limit: int, session: RefCounted
	) -> Array:
		return await inner.choose_commit(entity_id, context, limit, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return await inner.choose_recovery(context, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))
	# `--saga=N` gioca N Chronicle di fila invece di anni scollegati.
	var saga: int = int(options.get("saga", 0))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	# Chi elenca ogni Conseguenza, letto dai dati: una proposta, oppure niente.
	var listed_by: Dictionary = {}  # consequence_id -> [proposition_id]
	for template_id in data.confluence_templates:
		var template: Dictionary = data.confluence_templates[str(template_id)] as Dictionary
		for entry in template.get("propositions", []):
			var proposition: Dictionary = entry as Dictionary
			for consequence_id in proposition.get("success_consequences", []):
				var who: Array = listed_by.get(str(consequence_id), [])
				if not who.has(str(proposition["id"])):
					who.append(str(proposition["id"]))
				listed_by[str(consequence_id)] = who

	# E chi la porta quando non e' una proposta: una carta Echo. Per quelle la
	# domanda non e' «e' stata scelta», e' «la carta e' mai uscita».
	var carried_by: Dictionary = {}  # consequence_id -> [echo_card_id]
	for card_id in data.echo_cards:
		var card: Dictionary = data.echo_cards[str(card_id)] as Dictionary
		for hook in card.get("effect_hooks", []):
			var consequence_id: String = str((hook as Dictionary).get("consequence_id", ""))
			if consequence_id == "":
				continue
			var who: Array = carried_by.get(consequence_id, [])
			if not who.has(str(card_id)):
				who.append(str(card_id))
			carried_by[consequence_id] = who

	var offered: Dictionary = {}
	var chosen: Dictionary = {}
	var excluded: Dictionary = {}
	var played: Dictionary = {}      # echo_card_id -> volte calata sul tavolo
	var drawn: Dictionary = {}       # echo_card_id -> volte uscita dal mazzo
	var fired: Dictionary = {}     # consequence_id -> volte applicata
	var councils: int = 0

	var lines: Array = []
	if saga <= 1:
		for chronicle_id in ["CHR_00"]:
			lines.append([str(chronicle_id)])
	else:
		var chain: Array = ["CHR_00"]
		for index in range(saga - 1):
			chain.append(str(options.get("then", "CHR_00")))
		lines.append(chain)

	var years_played: int = 0
	for chain in lines:
		for run in range(runs):
			var previous: Dictionary = {}
			var previous_results: Dictionary = {}
			for index in range((chain as Array).size()):
				var chronicle_id: String = str((chain as Array)[index])
				var seed_value: int = first_seed + run * 1009 + index * 97
				var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
				var session: RefCounted = GameSession.new(data)
				if not session.setup(chronicle_id, seats, seed_value):
					printerr("setup fallito: %s" % session.last_error)
					quit(3)
					return
				if previous.is_empty():
					for effect in session.factory_setup_effects():
						session.applier.apply(effect)
				else:
					# L'anno che eredita non rinasce dal nulla: prende il mondo di
					# prima e ci fa passare sopra il tempo. E' li' che nascono le
					# leggende, e le leggende sono meta' della domanda.
					session.inherit_from(previous, previous_results)
				var watcher := Watcher.new(
					Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
				)
				# Una carta Echo non scatta perche' e' in mano: scatta quando
				# qualcuno la **cala** (ISSUES 23, D-118). Pescata e calata sono
				# due numeri diversi, e confonderli qui avrebbe dato la risposta
				# sbagliata a tutte e quattro le Conseguenze che passano di li'.
				# E quando la cala, la Conseguenza che la carta porta e' scattata
				# **li'**, non in un Consiglio: `confluence_results` non la vede,
				# e contare solo di la' avrebbe dichiarato morte due Conseguenze
				# che invece escono.
				session.chronicle.act_echo_drawn.connect(
					func(card: Dictionary, applied: Array) -> void:
						var id: String = str(card["id"])
						played[id] = int(played.get(id, 0)) + 1
						if applied.is_empty():
							return
						for hook in card.get("effect_hooks", []):
							var cid: String = str((hook as Dictionary).get("consequence_id", ""))
							if cid != "":
								fired[cid] = int(fired.get(cid, 0)) + 1
				)
				var report: Dictionary = await session.run(watcher)
				if report.is_empty():
					printerr("partita non conclusa al seme %d" % seed_value)
					quit(3)
					return
				years_played += 1
				for id in watcher.offered:
					offered[id] = int(offered.get(id, 0)) + int(watcher.offered[id])
				for id in watcher.chosen:
					chosen[id] = int(chosen.get(id, 0)) + int(watcher.chosen[id])
				for id in watcher.excluded:
					excluded[id] = int(excluded.get(id, 0)) + int(watcher.excluded[id])
				# Pescata e calata sono due numeri diversi, e la distanza fra i
				# due e' la diagnosi: una carta che nessuno pesca e' un problema
				# di mazzo, una che tutti pescano e nessuno cala e' un problema
				# di **ragione per giocarla**.
				for card_id in (session.world["echo_played"] as Array):
					drawn[str(card_id)] = int(drawn.get(str(card_id), 0)) + 1
				for record in (session.chronicle.confluence_results as Array):
					councils += 1
					for consequence_id in (record as Dictionary).get("consequence_ids", []):
						fired[str(consequence_id)] = int(fired.get(str(consequence_id), 0)) + 1
				previous = session.world
				previous_results = report["destiny_results"]
				# Niente dispose finche' la catena non finisce: `previous` e' il
				# mondo che l'anno dopo eredita.
			previous = {}

	print("")
	print("== PERCHE' UNA CONSEGUENZA NON ESCE - %d anni%s, %d Consigli ==" % [
		years_played,
		"" if saga <= 1 else " in %d saghe da %d" % [runs, saga],
		councils,
	])
	print("")
	var silent: Array = []
	for consequence_id in data.consequences:
		if int(fired.get(str(consequence_id), 0)) == 0:
			silent.append(str(consequence_id))
	silent.sort()
	print("  %d Conseguenze su %d non escono mai." % [silent.size(), data.consequences.size()])
	print("")
	print("  %-24s %-34s %s" % ["Conseguenza", "chi la elenca", "verdetto"])
	for consequence_id in silent:
		var who: Array = listed_by.get(consequence_id, [])
		var verdict: String = ""
		var by: String = ""
		if who.is_empty():
			var cards: Array = carried_by.get(consequence_id, [])
			if cards.is_empty():
				by = "nessuno"
				verdict = "ORFANA: nessuna proposta la elenca e nessuna carta la porta"
			else:
				var pulls: int = 0
				var seen_in_hand: int = 0
				for card_id in cards:
					pulls += int(played.get(str(card_id), 0))
					seen_in_hand += int(drawn.get(str(card_id), 0))
				by = ", ".join(PackedStringArray(cards))
				if pulls > 0:
					verdict = "LA CARTA E' STATA CALATA %d volte e la Conseguenza non e' scattata" % pulls
				elif seen_in_hand == 0:
					verdict = "CARTA MAI USCITA DAL MAZZO"
				else:
					verdict = (
						"NESSUNA RAGIONE PER GIOCARLA: pescata %d volte, calata zero" % seen_in_hand
					)
		else:
			var seen: int = 0
			var taken: int = 0
			for proposition_id in who:
				seen += int(offered.get(str(proposition_id), 0))
				taken += int(chosen.get(str(proposition_id), 0))
			by = ", ".join(PackedStringArray(who))
			if seen == 0:
				var barred: int = 0
				for proposition_id in who:
					barred += int(excluded.get(str(proposition_id), 0))
				verdict = (
					"NON IDONEA: la sua domanda e' stata posta %d volte e lei e' stata esclusa tutte" % barred
					if barred > 0
					else "FUORI PORTATA: la sua domanda non e' mai arrivata al tavolo"
				)
			elif taken == 0:
				verdict = "MAI SCELTA: offerta %d volte, presa zero" % seen
			else:
				verdict = "SEMPRE PERDENTE: scelta %d volte su %d offerte, e non passa mai" % [
					taken, seen,
				]
		print("  %-24s %-34s %s" % [consequence_id, by, verdict])
	print("")
	print("  Per confronto: le proposte mai offerte a nessuno, in %d Consigli." % councils)
	var never_offered: Array = []
	for consequence_id in listed_by:
		for proposition_id in listed_by[consequence_id]:
			if int(offered.get(str(proposition_id), 0)) == 0 and not never_offered.has(str(proposition_id)):
				never_offered.append(str(proposition_id))
	never_offered.sort()
	if never_offered.is_empty():
		print("    nessuna: ogni proposta arriva prima o poi sul tavolo.")
	else:
		for proposition_id in never_offered:
			print("    %-22s esclusa %d volte con la sua domanda in tavola" % [
				str(proposition_id), int(excluded.get(str(proposition_id), 0)),
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
