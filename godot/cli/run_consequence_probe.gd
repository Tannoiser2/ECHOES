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
## **Dal Consiglio a due domande (D-467, D-472) chi elenca una Conseguenza e'
## una domanda, non una proposta**: l'esito di base sta in `questions[i].base`
## e quello del rifiuto in `questions[i].refused` (D-475),
## sulla carta, e esce quando **quella domanda vince** il voto contro l'altra
## (`winning_question_id` nel risultato). Le proposte e le loro
## `success_consequences` sono uscite dal codice con il Consiglio di D-280, e
## la lista rimasta nei dati non la legge nessuno. Le tre porte restano, con
## nomi nuovi: la carta non arriva mai al Consiglio; la domanda non e' mai
## eleggibile come A (sta ai voti solo come Contro); ai voti e mai vinta.
##
## Il modo di saperlo e' guardare il Consiglio da dentro mentre succede: il
## Consiglio annuncia i suoi passi — QUESTION all'apertura, RESOLVED a voto
## fatto — e un ascoltatore si mette in mezzo, non decide niente, e scrive
## quello che passa. Fino a D-472 era un registratore seduto fra il tavolo e il
## cervello (`choose_proposition`); ora la scelta non e' piu' una chiamata al
## cervello, perche' le due domande vanno ai voti tutt'e due.
##
## E c'e' una quarta possibilita' che la voce non nomina, e i dati la dicono
## prima di qualunque partita: **una Conseguenza che nessuna domanda elenca**.
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

	# Chi elenca ogni Conseguenza, letto dai dati: una domanda della carta
	# (`questions[i].base`, D-467), oppure niente.
	var listed_by: Dictionary = {}  # consequence_id -> [question_id]
	# **E i sacchetti sono una casa diversa** (D-401): una Conseguenza pescata
	# dal sacchetto del costo o del fallimento non si sceglie — capita. Il
	# verdetto che vale per una proposta («offerta tante volte, presa zero») su
	# di lei direbbe il falso, quindi si tiene separata.
	var pooled_in: Dictionary = {}  # consequence_id -> ["CNF_X (failure)"]
	# **Chi elenca si legge dalla carta, non dal template crudo** (D-461): dal
	# 0.1.272 ogni carta porta le sue Domande e il template e' solo il ripiego.
	# Letto crudo, il template diceva ancora le liste di allora — e chiamava
	# «orfana» una Conseguenza che tre carte elencano.
	# Quali Conseguenze hanno una strada che passa dal **rifiuto** (D-475), e
	# quali dalla vittoria di una domanda: cambia il verdetto, perche' una che
	# esce solo quando il tavolo **non** decide non e' «sempre perdente».
	var only_refused: Dictionary = {}
	var reached_by_winning: Dictionary = {}
	for tension_id in data.tensions:
		var sheet: Dictionary = data.confluence_template_for(str(tension_id)) as Dictionary
		for entry in sheet.get("questions", []):
			var question: Dictionary = entry as Dictionary
			# **E il rifiuto della domanda** (D-475): cosa resta al mondo se il
			# tavolo la respinge. Senza questa riga la sonda chiamava «orfane»
			# quattro Conseguenze che una domanda elenca — la corona che perde
			# il titolo, il debito chiamato, la cinghia stretta, chi se ne va —
			# ed e' la forma di cecita' che questo file ha gia' avuto due volte.
			for list_name in ["base", "refused"]:
				for consequence_id in question.get(list_name, []):
					var who: Array = listed_by.get(str(consequence_id), [])
					if not who.has(str(question["id"])):
						who.append(str(question["id"]))
					listed_by[str(consequence_id)] = who
					# **L'id resta quello vero**, o le due tabelle che seguono
					# — quante volte quella domanda e' stata offerta, presa,
					# vinta — non lo trovano piu' e la sonda direbbe «mai
					# arrivata al Consiglio» di una domanda che ci arriva ogni
					# anno. La strada la ricorda questa mappa, a parte.
					if list_name == "refused":
						only_refused[str(consequence_id)] = true
					else:
						reached_by_winning[str(consequence_id)] = true
	for template_id in data.confluence_templates:
		var template: Dictionary = data.confluence_templates[str(template_id)] as Dictionary
		# **E i sacchetti del Consiglio** (D-401). Una Conseguenza puo' avere una
		# casa che non e' una proposta: il costo, il fallimento, il premio di chi
		# decide. La sonda non li guardava, e chiamava «orfana» una Conseguenza
		# che il Consiglio pesca quando la proposta **cade** — che e' l'opposto
		# di orfana. Quinta volta in questo progetto che uno zero era la sonda.
		for pool_name in (template.get("consequence_pools", {}) as Dictionary):
			for consequence_id in (template["consequence_pools"][str(pool_name)] as Array):
				var pooled: Array = pooled_in.get(str(consequence_id), [])
				var etichetta: String = "%s (%s)" % [str(template_id), str(pool_name)]
				if not pooled.has(etichetta):
					pooled.append(etichetta)
				pooled_in[str(consequence_id)] = pooled

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

	# Le tre colonne di una domanda (D-467): quante volte era **eleggibile**
	# all'apertura, quante volte e' stata **ai voti** (come A o come B — la B
	# non passa dall'eligibility, sta sul tavolo perche' la carta la porta) e
	# quante volte ha **vinto**. E le volte in cui la sua carta era al
	# Consiglio e lei non era eleggibile: esclusa, ma ai voti come Contro.
	var offered: Dictionary = {}
	var chosen: Dictionary = {}
	var won: Dictionary = {}
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
				var table: RefCounted = Characters.deal(
					seats, RngService.new(seed_value * 31 + 7), session.log
				)
				# L'ascoltatore (D-472): i passi del Consiglio, non le chiamate
				# al cervello. I dizionari si catturano per riferimento, e i
				# conti si leggono fuori dalla lambda (CLAUDE.md, le trappole).
				session.confluence.step_changed.connect(
					func(step: String, context: Dictionary) -> void:
						_listen(session, step, context, offered, chosen, won, excluded)
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
				var report: Dictionary = await session.run(table)
				if report.is_empty():
					printerr("partita non conclusa al seme %d" % seed_value)
					quit(3)
					return
				years_played += 1
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
		var pools: Array = pooled_in.get(consequence_id, [])
		if who.is_empty() and not pools.is_empty():
			by = ", ".join(PackedStringArray(pools))
			verdict = (
				"STA IN UN SACCHETTO: non si sceglie, capita — esce solo se il "
				+ "Consiglio finisce cosi'"
			)
		elif who.is_empty():
			var cards: Array = carried_by.get(consequence_id, [])
			if cards.is_empty():
				by = "nessuno"
				verdict = "ORFANA: nessuna domanda la elenca e nessuna carta la porta"
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
		elif only_refused.has(consequence_id) and not reached_by_winning.has(consequence_id):
			by = ", ".join(PackedStringArray(who))
			verdict = (
				"LA PORTA IL RIFIUTO (D-475): esce quando quella domanda e' "
				+ "respinta e non passa nessuna delle due — in %d Consigli non e' capitato" % councils
			)
		else:
			var seen: int = 0
			var taken: int = 0
			var victories: int = 0
			for question_id in who:
				seen += int(offered.get(str(question_id), 0))
				taken += int(chosen.get(str(question_id), 0))
				victories += int(won.get(str(question_id), 0))
			by = ", ".join(PackedStringArray(who))
			if taken == 0:
				verdict = "FUORI PORTATA: la sua carta non e' mai arrivata al Consiglio"
			elif seen == 0:
				# Ai voti solo come Contro: mai eleggibile come A, e chi la
				# prende non l'ha mai portata oltre il mucchio.
				var barred: int = 0
				for question_id in who:
					barred += int(excluded.get(str(question_id), 0))
				verdict = (
					"NON IDONEA: al Consiglio %d volte solo come Contro, esclusa come A tutte, e non vince mai"
					% barred
				)
			elif victories == 0:
				verdict = "SEMPRE PERDENTE: ai voti %d volte (eleggibile %d), e non vince mai" % [
					taken, seen,
				]
			else:
				# Ha vinto, ma la Conseguenza non e' scattata: o una clausola
				# `requires_entity` l'ha fermata (D-213, D-262), o si legge il
				# verbale. Detto invece che taciuto.
				verdict = "VINTA %d volte su %d ai voti, e la Conseguenza non e' scattata lo stesso" % [
					victories, taken,
				]
		print("  %-24s %-34s %s" % [consequence_id, by, verdict])
	print("")
	print("  Per confronto: le domande mai ai voti, in %d Consigli." % councils)
	var never_voted: Array = []
	for consequence_id in listed_by:
		for question_id in listed_by[consequence_id]:
			if int(chosen.get(str(question_id), 0)) == 0 and not never_voted.has(str(question_id)):
				never_voted.append(str(question_id))
	never_voted.sort()
	if never_voted.is_empty():
		print("    nessuna: ogni domanda arriva prima o poi sul tavolo.")
	else:
		for question_id in never_voted:
			print("    %-22s la sua carta non e' mai arrivata al Consiglio" % str(question_id))
	quit(0)


## L'ascoltatore del Consiglio a due domande (D-467, D-472). All'apertura
## (QUESTION) si annota quali domande della carta erano eleggibili e quali no;
## a voto fatto (RESOLVED) quali erano ai voti — la A del proponente e la B —
## e quale ha vinto. Non tocca il risultato: la stessa partita con e senza
## ascoltatore finisce uguale.
func _listen(
	session: RefCounted, step: String, context: Dictionary,
	offered: Dictionary, chosen: Dictionary, won: Dictionary, excluded: Dictionary
) -> void:
	if step == "QUESTION":
		var here: Dictionary = {}
		for option in session.confluence.available_questions():
			var id: String = str((option as Dictionary)["id"])
			here[id] = true
			offered[id] = int(offered.get(id, 0)) + 1
		var template: Dictionary = session.data.confluence_template_for(
			str(context["tension_id"])
		) as Dictionary
		for entry in template.get("questions", []):
			var id: String = str((entry as Dictionary)["id"])
			if not here.has(id):
				excluded[id] = int(excluded.get(id, 0)) + 1
		return
	if step != "RESOLVED":
		return
	# Si legge a voto fatto e non all'apertura: il proponente puo' cambiare
	# domanda dopo `open()`, e le parti si riaprono con lei.
	for side in ["A", "B"]:
		var id: String = str(
			((context.get("sides", {}) as Dictionary).get(side, {}) as Dictionary).get("question_id", "")
		)
		if id != "":
			chosen[id] = int(chosen.get(id, 0)) + 1
	var winner: String = str((context.get("result", {}) as Dictionary).get("winning_question_id", ""))
	if winner != "":
		won[winner] = int(won.get(winner, 0)) + 1


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not str(argument).begins_with("--"):
			continue
		var pair: PackedStringArray = str(argument).substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
