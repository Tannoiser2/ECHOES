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

	func _init(who: RefCounted) -> void:
		inner = who

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
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
			if str(((asset as Dictionary).get("card_action", {}) as Dictionary).get("kind", "")) == verb:
				found += 1
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
	var chronicle_id: String = str(options.get("chronicle", "CHR_01"))
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
