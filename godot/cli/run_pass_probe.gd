extends SceneTree
## Perche' un seggio passa (ISSUES 68).
##
##   godot --headless --path godot --script res://cli/run_pass_probe.gd -- \
##       --runs=100 --seed=7000
##
## Nella partita che il committente ha giocato, **17 turni su 24 sono «passa»**:
## negli Atti due e tre quasi nessuno fa niente, e le carte in mano ci sono.
## Tutte le sonde di questo progetto misurano **cosa succede**; nessuna misura
## **cosa era disponibile e non e' stato preso**, ed e' l'unico numero che
## distingue tre malattie con tre cure opposte:
##
## 1. **non aveva mosse**: le regole non gli lasciavano fare niente. Cura: le
##    regole;
## 2. **non voleva niente**: mosse legali ce n'erano e nessuna lo avvicinava a
##    qualcosa. Cura: dare una ragione — obiettivi, premi, pressione;
## 3. **voleva e non sapeva dirlo**: aveva un'intenzione e in mano nessuna carta
##    che la esprimesse. Cura: il mazzo, o come si spende.
##
## Scegliere una senza il numero sarebbe indovinare, e questo progetto ha una
## regola contro l'indovinare.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")


## Il testimone: chiede al cervello cosa fa, e quando la risposta e' «passa» gli
## chiede **perche'** — ramo per ramo, con le sue stesse funzioni. Non decide
## niente: la partita con e senza testimone finisce uguale.
class Witness extends RefCounted:
	var inner: RefCounted
	var passes: int = 0
	var acts: int = 0
	var why: Dictionary = {}          # causa -> volte
	var legal_when_passing: Array = []  # mosse legali che aveva chi ha passato
	var hand_when_passing: Array = []
	var wanted_but_mute: Dictionary = {}  # intenzione che la mano non sapeva dire
	## E il taglio che separa «mano sbagliata» da «bersaglio sbagliato»: quando
	## voleva un verbo e non l'ha detto, quel verbo **ce l'aveva in mano**?
	var mute_with_the_verb: int = 0
	var mute_without_the_verb: int = 0
	## E per Atto: il committente ha notato che il vuoto si concentra dopo il
	## primo, ed e' una forma diversa dal vuoto sparso.
	var per_act: Dictionary = {}

	## **Quante carte in mano sanno dire qualcosa** (D-422).
	##
	## `_legal_moves` qui sotto conta le mosse che **il tavolo** accetterebbe, e
	## non chiede mai se la mano sappia pronunciarle. Misurato, dice 23,8 mosse
	## legali per ogni «passa» — un numero che sembra dire *«poteva fare
	## ventitre' cose e non ne ha fatta nessuna»* e invece non dice niente sulla
	## mano. Il committente l'ha visto per primo: *«e se non ci fosse proprio la
	## possibilita' di passare?»*, e la risposta e' che oggi non si puo', perche'
	## la mano puo' essere muta.
	##
	## Questo conta l'altra cosa: delle carte che hai **in mano**, quante hanno
	## almeno una giocata legale adesso. Una carta che non ne ha nessuna e' una
	## carta che al tavolo non si puo' calare, e un turno fatto solo di quelle e'
	## un turno in cui passare non e' una scelta.
	var hand_cards_seen: int = 0
	var hand_cards_speaking: int = 0
	var mute_hands: int = 0          # turni in cui **nessuna** carta sapeva dire
	var turns_measured: int = 0
	var mute_card_faces: Dictionary = {}   # asset -> volte che era muta in mano
	## **E delle mute, quante lo sono per le regole e quante per scelta.** Sono
	## due difetti con due cure opposte, e confonderli e' il modo in cui si
	## ripara la cosa sbagliata:
	##
	##  - **il tavolo non la prende**: nessun bersaglio legale, per nessuna delle
	##    due facce. Al tavolo quella carta, adesso, non si puo' proprio calare —
	##    ed e' una regola da guardare;
	##  - **il cervello non la vuole**: un bersaglio legale c'e', e il cervello
	##    non lo propone perche' si farebbe male (INFLUENZARE dalla parte
	##    sbagliata, FORGIARE in giu'). Non e' un difetto del gioco: e' una
	##    scelta, e sparisce da sola il giorno che passare non e' permesso.
	var mute_because_rules: int = 0
	var mute_because_choice: int = 0
	var walled_cards: Dictionary = {}   # asset -> volte che il tavolo non la prendeva
	## **E perche' non la prendeva** (M5). Un nome senza ragione non si ripara:
	## «Investitura muta 57 volte» non dice se le manca un bersaglio sulla mappa,
	## un gradino da salire o una casa da toccare — e sono tre cure diverse.
	var walled_why: Dictionary = {}     # asset -> {ragione -> volte}

	func _init(who: RefCounted) -> void:
		inner = who

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		# **La mano si guarda prima della scelta**, su ogni turno e non solo su
		# quelli che passano: e' l'unico modo di sapere se il muto e' la
		# condizione normale o l'eccezione.
		_look_at_the_hand(entity_id, session)
		var chosen: Dictionary = await inner.choose_action(entity_id, ao_index, session)
		var act: String = str(session.world.get("act", 0))
		var cell: Array = per_act.get(act, [0, 0])
		if str(chosen.get("template", "")) != "PASS":
			acts += 1
			cell[1] = int(cell[1]) + 1
			per_act[act] = cell
			return chosen
		passes += 1
		cell[0] = int(cell[0]) + 1
		per_act[act] = cell

		# **L'intenzione prima della mano.** Il cervello sceglie cosa vuole e poi
		# cerca una carta che lo dica: sono due passi, e falliscono in modo
		# diverso. Chiedere solo il risultato finale li confonde.
		var intent: Dictionary = _brain(entity_id)._choose_intent(entity_id, ao_index, session)
		var wish: String = str(intent.get("template", "PASS"))
		var hand: int = session.service.hand_size(entity_id)
		var legal: int = _legal_moves(entity_id, session)
		hand_when_passing.append(hand)
		legal_when_passing.append(legal)

		var cause: String = ""
		if wish != "PASS":
			var carried: int = _cards_with_verb(entity_id, wish, session)
			if carried > 0:
				mute_with_the_verb += 1
				cause = "aveva %s in mano e non poteva usarlo li'" % wish
			else:
				mute_without_the_verb += 1
				cause = "voleva %s e in mano non ne aveva nessuna" % wish
			wanted_but_mute[wish] = int(wanted_but_mute.get(wish, 0)) + 1
		elif hand == 0:
			cause = "mano vuota"
		elif legal == 0:
			cause = "nessuna mossa legale"
		else:
			cause = "mosse legali, nessuna che gli servisse"
		why[cause] = int(why.get(cause, 0)) + 1
		return chosen

	## Delle carte che ha in mano, quante ne sanno dire almeno una, qui e adesso.
	## Si chiede al cervello vero (`hand_plays`) invece di rifare il conto: una
	## seconda aritmetica si scosterebbe dalla prima, ed e' il modo in cui una
	## sonda comincia a misurare se stessa.
	func _look_at_the_hand(entity_id: String, session: RefCounted) -> void:
		var hand: Array = session.service.hand(entity_id)
		if hand.is_empty():
			return
		var speaking: Dictionary = {}
		for play in _brain(entity_id).hand_plays(entity_id, session):
			var said: String = str(
				((play as Dictionary)["params"] as Dictionary).get("asset_id", "")
			)
			if said != "":
				speaking[said] = true
		turns_measured += 1
		hand_cards_seen += hand.size()
		hand_cards_speaking += speaking.size()
		if speaking.is_empty():
			mute_hands += 1
		for asset_id in hand:
			if not speaking.has(str(asset_id)):
				mute_card_faces[str(asset_id)] = int(
					mute_card_faces.get(str(asset_id), 0)
				) + 1
				var perche: String = _why_the_table_refuses(
					entity_id, str(asset_id), session
				)
				if perche == "":
					mute_because_choice += 1
				else:
					mute_because_rules += 1
					# **E quali sono, per nome.** Il quinto che il tavolo non
					# prende e' il difetto vero, e ripararlo vuol dire sapere su
					# quali carte guardare: un numero senza nomi non si ripara.
					walled_cards[str(asset_id)] = int(
						walled_cards.get(str(asset_id), 0)
					) + 1
					var ragioni: Dictionary = walled_why.get(str(asset_id), {})
					ragioni[perche] = int(ragioni.get(perche, 0)) + 1
					walled_why[str(asset_id)] = ragioni

	## **Il tavolo la prenderebbe, e se no perche'?** Si chiede a `check` — le
	## regole vere — su tutti i bersagli che quel verbo ammette, senza nessuno
	## dei filtri con cui il cervello si protegge. Torna **stringa vuota** se il
	## tavolo la prenderebbe (e allora muta l'ha resa il cervello), altrimenti la
	## ragione che il motore ha ripetuto piu' volte.
	##
	## Da M5 torna la ragione e non un si'/no: sapere *quali* carte il tavolo non
	## prende non basta a ripararle, perche' «nessun luogo con quei segni», «non
	## hai una presenza da muovere» e «e' gia' in cima» chiedono tre cure diverse.
	func _why_the_table_refuses(
		entity_id: String, asset_id: String, session: RefCounted
	) -> String:
		var motivi: Dictionary = {}
		var per_faccia: Dictionary = {}
		var card: Variant = session.data.assets.get(asset_id)
		if card == null:
			return "carta sconosciuta"
		var printed: Array = (
			((card as Dictionary).get("physical", {}) as Dictionary).get("actions", []) as Array
		)
		for index in range(printed.size()):
			var kind: String = str((printed[index] as Dictionary).get("template", ""))
			var base: Dictionary = {"asset_id": asset_id, "face_action": index}
			match kind:
				"MOVE", "ACQUIRE":
					for region_id in session.world["regions"]:
						var ask: Dictionary = base.duplicate()
						ask["region_id"] = str(region_id)
						if kind == "ACQUIRE":
							ask["structure_type"] = str(
								(printed[index] as Dictionary).get("builds", "")
							)
						var no: String = session.actions.check(entity_id, "PLAY_CARD", ask)
						if no == "":
							return ""
						motivi[no] = int(motivi.get(no, 0)) + 1
						_conta(per_faccia, index, no)
				"INFLUENCE":
					for tension_id in session.world["tensions"]:
						var ask: Dictionary = base.duplicate()
						ask["tension_id"] = str(tension_id)
						var no: String = session.actions.check(entity_id, "PLAY_CARD", ask)
						if no == "":
							return ""
						motivi[no] = int(motivi.get(no, 0)) + 1
						_conta(per_faccia, index, no)
				"SCHEME":
					for tension_id in session.world["tensions"]:
						var ask: Dictionary = base.duplicate()
						ask["mode"] = "TENSION"
						ask["tension_id"] = str(tension_id)
						var no: String = session.actions.check(entity_id, "PLAY_CARD", ask)
						if no == "":
							return ""
						motivi[no] = int(motivi.get(no, 0)) + 1
						_conta(per_faccia, index, no)
					for region_id in session.world["regions"]:
						var ask: Dictionary = base.duplicate()
						ask["mode"] = "REGION"
						ask["region_id"] = str(region_id)
						var no: String = session.actions.check(entity_id, "PLAY_CARD", ask)
						if no == "":
							return ""
						motivi[no] = int(motivi.get(no, 0)) + 1
						_conta(per_faccia, index, no)
				"CLAIM":
					for tension_id in session.world["tensions"]:
						var ask: Dictionary = base.duplicate()
						ask["mode"] = "FORCE"
						ask["tension_id"] = str(tension_id)
						var no: String = session.actions.check(entity_id, "PLAY_CARD", ask)
						if no == "":
							return ""
						motivi[no] = int(motivi.get(no, 0)) + 1
						_conta(per_faccia, index, no)
				"FORGE":
					for other in session.world["turn_order"]:
						if str(other) == entity_id:
							continue
						for direction in ["UP", "DOWN"]:
							var ask: Dictionary = base.duplicate()
							ask["target_entity_id"] = str(other)
							ask["direction"] = str(direction)
							ask["consent"] = true
							var no_f: String = session.actions.check(entity_id, "PLAY_CARD", ask)
							if no_f == "":
								return ""
							motivi[no_f] = int(motivi.get(no_f, 0)) + 1
							_conta(per_faccia, index, no_f)
		# **Murata dalla mappa, o solo non qui?** (M5, D-439). Un rifiuto «non
		# arriva li'» dice che *quella* tessera non porta i segni della carta;
		# la carta e' murata davvero solo se **nessuna** tessera pescata li
		# porta — cioe' se ogni rifiuto, su ogni bersaglio di ogni faccia, e'
		# quello. Contarla fra le pareti «a segni» quando cinque tessere su sei
		# l'hanno rifiutata per un'altra regola vuol dire chiamare difetto del
		# bersaglio un turno gia' speso.
		#
		# Si guarda **faccia per faccia**: l'altra faccia puo' essere zitta per
		# una quota o un segno che vieta, e quello e' un turno speso, non una
		# mappa che non porta niente.
		for index in per_faccia:
			var ragioni: Dictionary = per_faccia[index] as Dictionary
			var solo_segni: bool = not ragioni.is_empty()
			for ragione in ragioni:
				if not str(ragione).contains("non arriva li'"):
					solo_segni = false
					break
			if solo_segni:
				return "murata dalla mappa: la faccia «%s» di «%s» non arriva su nessuna tessera pescata" % [
					str((printed[index] as Dictionary).get("label", str(index))),
					str((card as Dictionary).get("title", asset_id)),
				]
		# La ragione che il motore ha ripetuto di piu': con dieci Regioni provate
		# e dieci rifiuti uguali, quella e' la parete vera.
		var peggiore: String = "nessun bersaglio provato"
		var quante: int = -1
		for ragione in motivi:
			if int(motivi[ragione]) > quante:
				quante = int(motivi[ragione])
				peggiore = str(ragione)
		return peggiore

	## Un rifiuto in piu' sul conto di quella faccia.
	static func _conta(per_faccia: Dictionary, index: int, ragione: String) -> void:
		var ragioni: Dictionary = per_faccia.get(index, {})
		ragioni[ragione] = int(ragioni.get(ragione, 0)) + 1
		per_faccia[index] = ragioni

	## Quante carte in mano portano quel verbo. Il mazzo ne ha undici che
	## influenzano e dieci che muovono: se il cervello voleva influenzare e in
	## mano non ne aveva **nessuna**, e' un problema di pesca; se ne aveva una e
	## non poteva usarla, e' un problema di bersaglio. Due cure opposte.
	func _cards_with_verb(entity_id: String, verb: String, session: RefCounted) -> int:
		var found: int = 0
		for asset_id in session.service.hand(entity_id):
			var asset: Variant = session.data.assets.get(str(asset_id))
			if asset == null:
				continue
			# **I verbi di una carta sono quelli stampati sulla faccia** (D-283):
			# leggere il solo `card_action.kind` diceva «non ne aveva nessuna»
			# di carte che quel verbo lo dicono eccome.
			for action in (
				((asset as Dictionary).get("physical", {}) as Dictionary).get("actions", [])
				as Array
			):
				if str((action as Dictionary).get("template", "")) == verb:
					found += 1
					break
		return found


	## Il cervello di **questo** seggio.
	##
	## A tavolo misto `inner` non e' un cervello: e' il router che smista a
	## quattro caratteri diversi (D-053). Chiedere l'intenzione al router non
	## alza un errore che una sonda possa prendere — **interrompe la funzione**,
	## e la prima stesura di questa sonda ha contato 304 «passa» senza una sola
	## causa, restando muta invece che rossa. E' la stessa trappola di GDScript
	## che il cancello dei test sorveglia da D-224.
	func _brain(entity_id: String) -> RefCounted:
		if inner.get("seats") != null and (inner.get("seats") as Dictionary).has(entity_id):
			return (inner.get("seats") as Dictionary)[entity_id]
		return inner


	## Quante mosse le **regole** gli lascerebbero fare adesso. Non e' il
	## giudizio del cervello: e' il conto di quello che il tavolo accetterebbe.
	func _legal_moves(entity_id: String, session: RefCounted) -> int:
		var found: int = 0
		for region_id in session.world["regions"]:
			if session.actions.can_execute(entity_id, "MOVE", {"region_id": str(region_id)}):
				found += 1
		for tension_id in session.world["tensions"]:
			for delta in [1, -1]:
				if session.actions.can_execute(entity_id, "INFLUENCE", {
					"tension_id": str(tension_id), "delta": delta, "via": "PRESENCE"
				}):
					found += 1
			if session.actions.can_execute(entity_id, "SCHEME", {
				"mode": "TENSION", "tension_id": str(tension_id)
			}):
				found += 1
		for other_id in session.world["entities"]:
			if str(other_id) == entity_id:
				continue
			for direction in ["UP", "DOWN"]:
				if session.actions.can_execute(entity_id, "FORGE", {
					"target_entity_id": str(other_id), "direction": direction
				}):
					found += 1
		if session.actions.can_execute(entity_id, "CLAIM", {"mode": "CREATE"}):
			found += 1
		return found

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return await inner.choose_proposition(context, options, session)

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
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))
	var mixed: bool = not options.has("uniform")

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var passes: int = 0
	var acts: int = 0
	var why: Dictionary = {}
	var mute: Dictionary = {}
	var with_verb: int = 0
	var without_verb: int = 0
	var legal: Array = []
	var hands: Array = []
	var by_act: Dictionary = {}
	var seen_cards: int = 0
	var speaking_cards: int = 0
	var mute_hands: int = 0
	var measured: int = 0
	var mute_faces: Dictionary = {}
	var mute_rules: int = 0
	var mute_choice: int = 0
	var walled: Dictionary = {}
	var walled_why: Dictionary = {}

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
		var witness := Witness.new(
			Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log) if mixed
			else PolicyDecider.new(session.log)
		)
		var report: Dictionary = await session.run(witness)
		if report.is_empty():
			printerr("partita non conclusa al seme %d" % seed_value)
			quit(3)
			return
		passes += witness.passes
		acts += witness.acts
		for key in witness.why:
			why[key] = int(why.get(key, 0)) + int(witness.why[key])
		for key in witness.wanted_but_mute:
			mute[key] = int(mute.get(key, 0)) + int(witness.wanted_but_mute[key])
		with_verb += witness.mute_with_the_verb
		without_verb += witness.mute_without_the_verb
		for act in witness.per_act:
			var cell: Array = by_act.get(str(act), [0, 0])
			cell[0] = int(cell[0]) + int((witness.per_act[act] as Array)[0])
			cell[1] = int(cell[1]) + int((witness.per_act[act] as Array)[1])
			by_act[str(act)] = cell
		legal.append_array(witness.legal_when_passing)
		hands.append_array(witness.hand_when_passing)
		seen_cards += witness.hand_cards_seen
		speaking_cards += witness.hand_cards_speaking
		mute_hands += witness.mute_hands
		measured += witness.turns_measured
		mute_rules += witness.mute_because_rules
		mute_choice += witness.mute_because_choice
		for asset_id in witness.walled_cards:
			walled[str(asset_id)] = int(walled.get(str(asset_id), 0)) + int(
				witness.walled_cards[asset_id]
			)
		for asset_id in witness.walled_why:
			var somma: Dictionary = walled_why.get(str(asset_id), {})
			for ragione in (witness.walled_why[asset_id] as Dictionary):
				somma[str(ragione)] = int(somma.get(str(ragione), 0)) + int(
					(witness.walled_why[asset_id] as Dictionary)[ragione]
				)
			walled_why[str(asset_id)] = somma
		for asset_id in witness.mute_card_faces:
			mute_faces[str(asset_id)] = int(
				mute_faces.get(str(asset_id), 0)
			) + int(witness.mute_card_faces[asset_id])
		session.dispose()

	var turns: int = passes + acts
	print("")
	print("== PERCHE' UN SEGGIO PASSA - %d anni, %s, tavolo %s ==" % [
		runs, chronicle_id, "misto" if mixed else "uniforme",
	])
	print("")
	print("  Turni giocati: %d. Passa %d volte (%.1f%%)." % [
		turns, passes, 100.0 * float(passes) / float(maxi(1, turns)),
	])
	print("")
	print("  Perche':")
	var causes: Array = why.keys()
	causes.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(why[a]) > int(why[b])
	)
	for cause in causes:
		print("    %-46s %6d  %5.1f%% dei passa" % [
			str(cause), int(why[cause]),
			100.0 * float(int(why[cause])) / float(maxi(1, passes)),
		])
	# **La mano, e se sa dire qualcosa** (D-422). E' l'altra meta' del numero:
	# `_legal_moves` conta quello che il tavolo accetterebbe, questo conta quello
	# che la mano sa pronunciare, ed e' la differenza fra «non voleva» e «non
	# poteva».
	print("")
	print("  La mano, su tutti i turni (non solo quelli che passano):")
	print("    carte guardate            %6d in %d turni (media %.2f)" % [
		seen_cards, measured, float(seen_cards) / float(maxi(1, measured)),
	])
	print("    che sanno dire qualcosa   %6d  %5.1f%%" % [
		speaking_cards, 100.0 * float(speaking_cards) / float(maxi(1, seen_cards)),
	])
	print("    **mute**                  %6d  %5.1f%%" % [
		seen_cards - speaking_cards,
		100.0 * float(seen_cards - speaking_cards) / float(maxi(1, seen_cards)),
	])
	print("    turni con la mano tutta muta %6d  %5.1f%%  <- qui passare non e' una scelta" % [
		mute_hands, 100.0 * float(mute_hands) / float(maxi(1, measured)),
	])
	var mute_total: int = maxi(1, mute_rules + mute_choice)
	print("")
	print("    E delle mute, chi le ha zittite:")
	print("      il tavolo non le prende   %6d  %5.1f%%  <- le regole" % [
		mute_rules, 100.0 * float(mute_rules) / float(mute_total),
	])
	print("      il cervello non le vuole  %6d  %5.1f%%  <- una scelta, non un difetto" % [
		mute_choice, 100.0 * float(mute_choice) / float(mute_total),
	])
	if not walled.is_empty():
		var murate: Array = walled.keys()
		murate.sort_custom(func(a: Variant, b: Variant) -> bool:
			return int(walled[a]) > int(walled[b])
		)
		print("")
		print("      E il quinto che il tavolo non prende, per nome (%d carte diverse):" % murate.size())
		for i in range(mini(12, murate.size())):
			var asset_id: String = str(murate[i])
			var card: Dictionary = data.assets.get(asset_id, {}) as Dictionary
			var verbi: Array = []
			for face in ((card.get("physical", {}) as Dictionary).get("actions", []) as Array):
				verbi.append(str((face as Dictionary).get("template", "?")))
			# **La parete, non solo il nome.** La ragione che il motore ha
			# ripetuto di piu' su quella carta: e' l'unica cosa che dice quale
			# delle tre cure serve.
			var parete: String = "?"
			var quante: int = -1
			for ragione in (walled_why.get(asset_id, {}) as Dictionary):
				if int((walled_why[asset_id] as Dictionary)[ragione]) > quante:
					quante = int((walled_why[asset_id] as Dictionary)[ragione])
					parete = str(ragione)
			print("        %-26s %5d volte  %-13s  %s" % [
				str(card.get("title", asset_id)), int(walled[asset_id]),
				"/".join(PackedStringArray(verbi)), parete,
			])
	if not walled_why.is_empty():
		# **Le pareti, contate per quello che sono e non per carta.** Sapere che
		# «Mobilitazione e' murata 61 volte» non dice niente finche' non si sa
		# che a murarla e' una quota per giro e non un bersaglio che manca: la
		# prima e' una regola che funziona, il secondo un difetto da riparare.
		var pareti: Dictionary = {}
		for asset_id in walled_why:
			for ragione in (walled_why[asset_id] as Dictionary):
				pareti[str(ragione)] = int(pareti.get(str(ragione), 0)) + int(
					(walled_why[asset_id] as Dictionary)[ragione]
				)
		var elenco: Array = pareti.keys()
		elenco.sort_custom(func(a: Variant, b: Variant) -> bool:
			return int(pareti[a]) > int(pareti[b])
		)
		var totale_pareti: int = 0
		for ragione in pareti:
			totale_pareti += int(pareti[ragione])
		# E raccolte per **famiglia**, che e' il numero che decide cosa fare: una
		# quota per giro e un bersaglio che non esiste sono due mondi diversi.
		var famiglie: Dictionary = {}
		for ragione in pareti:
			var nome: String = "altro"
			var testo: String = str(ragione)
			if testo.contains("ha gia usato INFLUENCE"):
				nome = "la quota di INFLUENZARE, una per giro"
			elif testo.contains("e gia stata mossa"):
				nome = "la quota della questione, per giro"
			elif testo.begins_with("il segno lo vieta"):
				nome = "un segno del mondo lo vieta"
			elif testo.contains("Confluence e gia stata forzata"):
				nome = "il Consiglio si forza una volta per giro"
			elif testo.contains("da scartare"):
				nome = "il prezzo in carte da scartare"
			elif testo.begins_with("murata dalla mappa"):
				nome = "**murata dalla mappa: nessuna tessera porta i suoi segni**"
			elif testo.contains("non arriva li'"):
				nome = "il bersaglio a segni, non qui: altrove un'altra regola"
			famiglie[nome] = int(famiglie.get(nome, 0)) + int(pareti[ragione])
		var per_famiglia: Array = famiglie.keys()
		per_famiglia.sort_custom(func(a: Variant, b: Variant) -> bool:
			return int(famiglie[a]) > int(famiglie[b])
		)
		# **E quanta di quella parete cade su carte con un verbo solo.** Diciotto
		# carte su 48 stampano lo stesso verbo su tutte e due le facce: il giorno
		# che quel verbo e' bloccato — una quota per giro, un segno che lo vieta
		# — quella carta muore intera, perche' non ha una seconda strada. E'
		# l'unico numero che dice se la parete e' un difetto delle carte o una
		# regola che funziona.
		var muro_mono: int = 0
		var muro_due: int = 0
		for asset_id in walled:
			var scheda: Dictionary = data.assets.get(str(asset_id), {}) as Dictionary
			var verbi_carta: Dictionary = {}
			for face in ((scheda.get("physical", {}) as Dictionary).get("actions", []) as Array):
				verbi_carta[str((face as Dictionary).get("template", "?"))] = true
			if verbi_carta.size() <= 1:
				muro_mono += int(walled[asset_id])
			else:
				muro_due += int(walled[asset_id])
		print("")
		print("      E su che carte cade la parete:")
		print("        %5d  %5.1f%%  carte con **un verbo solo** su tutte e due le facce" % [
			muro_mono, 100.0 * float(muro_mono) / float(maxi(1, muro_mono + muro_due)),
		])
		print("        %5d  %5.1f%%  carte con due verbi diversi" % [
			muro_due, 100.0 * float(muro_due) / float(maxi(1, muro_mono + muro_due)),
		])
		print("")
		print("      E le pareti per famiglia, che e' quello che dice cosa riparare:")
		for nome in per_famiglia:
			print("        %5d  %5.1f%%  %s" % [
				int(famiglie[nome]),
				100.0 * float(famiglie[nome]) / float(maxi(1, totale_pareti)),
				str(nome),
			])
		print("")
		print("      E le pareti, per quello che sono (%d diverse):" % elenco.size())
		for i in range(mini(15, elenco.size())):
			print("        %5d  %5.1f%%  %s" % [
				int(pareti[elenco[i]]),
				100.0 * float(pareti[elenco[i]]) / float(maxi(1, totale_pareti)),
				str(elenco[i]),
			])
	if not mute_faces.is_empty():
		var worst: Array = mute_faces.keys()
		worst.sort_custom(func(a: Variant, b: Variant) -> bool:
			return int(mute_faces[a]) > int(mute_faces[b])
		)
		print("")
		print("    Le dieci carte piu' spesso mute in mano:")
		for i in range(mini(10, worst.size())):
			var asset_id: String = str(worst[i])
			print("      %-28s %6d volte" % [
				str(data.assets.get(asset_id, {}).get("title", asset_id)),
				int(mute_faces[asset_id]),
			])
	if not mute.is_empty():
		print("")
		print("  Le intenzioni che la mano non sapeva dire:")
		var wishes: Array = mute.keys()
		wishes.sort_custom(func(a: Variant, b: Variant) -> bool:
			return int(mute[a]) > int(mute[b])
		)
		for wish in wishes:
			print("    %-20s %d volte" % [str(wish), int(mute[wish])])
		print("")
		print("    con quel verbo gia' in mano:  %5d  (bersaglio sbagliato)" % with_verb)
		print("    senza nessuna carta cosi':    %5d  (pesca sbagliata)" % without_verb)
	print("")
	print("  E quando: i «passa» per Atto.")
	var acts_seen: Array = by_act.keys()
	acts_seen.sort_custom(func(a: Variant, b: Variant) -> bool: return int(a) < int(b))
	for act in acts_seen:
		var cell: Array = by_act[str(act)]
		var here: int = int(cell[0]) + int(cell[1])
		print("    Atto %s   passa %5d su %5d turni   %5.1f%%" % [
			str(act), int(cell[0]), here,
			100.0 * float(int(cell[0])) / float(maxi(1, here)),
		])
	print("")
	print("  Chi ha passato, quanto aveva in mano e quante mosse legali:")
	print("    carte in mano   media %5.2f   mai zero: %s" % [
		_average(hands), "no" if hands.has(0) else "si'",
	])
	print("    mosse legali    media %5.2f   zero in %d passa su %d" % [
		_average(legal), _zeros(legal), passes,
	])
	quit(0)


static func _average(numbers: Array) -> float:
	if numbers.is_empty():
		return 0.0
	var total: float = 0.0
	for value in numbers:
		total += float(value)
	return total / float(numbers.size())


static func _zeros(numbers: Array) -> int:
	var found: int = 0
	for value in numbers:
		if int(value) == 0:
			found += 1
	return found


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for argument in args:
		if not str(argument).begins_with("--"):
			continue
		var pair: PackedStringArray = str(argument).substr(2).split("=", true, 1)
		out[str(pair[0])] = str(pair[1]) if pair.size() > 1 else "1"
	return out
