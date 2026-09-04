extends SceneTree
## **Quanta scelta arriva davvero al tavolo** (ISSUES 72, D-343).
##
##   godot --headless --path godot --script res://cli/run_boxes_probe.gd -- --runs=20
##
## Il «fatto quando» di ISSUES 72 chiede una sonda che dica quanta scelta arriva
## davvero al tavolo, e non c'era. Le caselle del Consiglio si vedono
## nella scheda stampata e nei cataloghi; quello che nessuno sapeva e' **quante
## volte una casella viene offerta e quante viene presa**.
##
## Serve perche' una casella che nessuno compra e' identica, per il gioco, a una
## casella che non esiste — e la differenza fra le due si vede solo qui. La
## prima misura, in 20 partite: ABBASSA LA DOMANDA offerta 72 volte e comprata
## **una**. La casella funziona; il cervello preferisce quelle che cambiano la
## mappa.
##
## Un cane da guardia si siede fra il cervello e il Consiglio e conta, senza
## decidere niente: e' la stessa forma dello `StoneSeat` di `run_asking_probe`.
## **Il menu dei costi e' una lista di id**, non di voci, e va risolto sulla
## faccia della carta: la prima versione di questa sonda non lo faceva e diceva
## zero su tutti i costi — cioe' esattamente lo zero cieco che in questo
## progetto e' successo quattro volte.

const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")
const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

var bought: Dictionary = {}
## Le pedine posate su una domanda indicata col dito, per casella (D-438).
var named: Dictionary = {}
var offered: Dictionary = {}


class Spy extends RefCounted:
	var inner: RefCounted
	var offered: Dictionary
	var bought: Dictionary
	var named: Dictionary

	func _init(who: RefCounted, p_offered: Dictionary, p_bought: Dictionary, p_named: Dictionary) -> void:
		named = p_named
		inner = who
		offered = p_offered
		bought = p_bought

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		return await inner.choose_action(entity_id, ao_index, session)

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

	func choose_benefits(
		entity_id: String, context: Dictionary, menu: Array, session: RefCounted
	) -> Array:
		_note(menu, "offerto")
		var picked: Array = await inner.choose_benefits(entity_id, context, menu, session)
		_taken(menu, picked)
		return picked

	func choose_costs(
		entity_id: String, context: Dictionary, menu: Array, due: int, session: RefCounted
	) -> Array:
		# Il menu dei costi e' una lista di **id**, non di voci: si risolve
		# sulla faccia della carta in dibattito.
		var voci: Array = _cost_voices(session, menu)
		_note(voci, "offerto")
		var picked: Array = await inner.choose_costs(entity_id, context, menu, due, session)
		_taken(voci, picked)
		return picked

	## Il gettone del costo (D-387): un avversario alla volta, uno per pedina.
	func choose_cost_token(
		entity_id: String, context: Dictionary, menu: Array, session: RefCounted
	) -> String:
		var voci: Array = _cost_voices(session, menu)
		_note(voci, "offerto")
		var picked: String = await inner.choose_cost_token(entity_id, context, menu, session)
		_taken(voci, [] if picked == "" else [picked])
		return picked

	func _cost_voices(session: RefCounted, menu: Array) -> Array:
		var faccia: Dictionary = session.confluence.card_face()
		var out: Array = []
		for voice in (faccia.get("costs", []) as Array):
			if menu.has(str((voice as Dictionary).get("id", ""))):
				out.append(voice)
		return out

	func choose_counterclaim(
		entity_id: String, context: Dictionary, offer: Dictionary, session: RefCounted
	) -> Dictionary:
		return await inner.choose_counterclaim(entity_id, context, offer, session)

	func _note(menu: Array, _why: String) -> void:
		for voice in menu:
			var verb: String = _verb_of(voice)
			if verb != "":
				offered[verb] = int(offered.get(verb, 0)) + 1

	func _taken(menu: Array, picked: Array) -> void:
		for scelta in picked:
			var wanted: String = _id_of(scelta)
			for voice in menu:
				if _id_of(voice) == wanted and wanted != "":
					var verb: String = _verb_of(voice)
					if verb != "":
						bought[verb] = int(bought.get(verb, 0)) + 1
						# **E su quale domanda** (D-438, ISSUES 106): una pedina
						# che porta il nome di un'altra domanda e' il dito del
						# proponente, e si conta a parte — e' il pezzo del
						# criterio che la sonda non sapeva vedere.
						if scelta is Dictionary and str((scelta as Dictionary).get("question", "")) != "":
							named[verb] = int(named.get(verb, 0)) + 1

	func _verb_of(voice: Variant) -> String:
		return str((voice as Dictionary).get("verb", "")) if voice is Dictionary else ""

	func _id_of(voice: Variant) -> String:
		if voice is Dictionary:
			return str((voice as Dictionary).get("id", ""))
		return str(voice)


func _initialize() -> void:
	var runs: int = 20
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--runs="):
			runs = int(a.substr(7))
	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		quit(3)
		return
	var consigli: int = 0
	var diverse_per_anno: Array = []
	var diverse_finora: int = 0
	for run in range(runs):
		var seed_value: int = 7000 + run
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
		await session.run(Spy.new(brain, offered, bought, named))
		consigli += int(session.world.get("confluence_count", 0))
		# **Quante caselle diverse in un anno** (ISSUES 122, la misura che la
		# voce chiedeva): non «chi compra questa casella», ma quante ne vede
		# **un tavolo** in una partita. Una sola per anno vuol dire che le altre
		# ventitre' esistono per quando la prima non si puo' comprare.
		diverse_per_anno.append((bought.keys() as Array).size() - diverse_finora)
		diverse_finora = (bought.keys() as Array).size()
		session.dispose()
	print("%-18s %8s %8s" % ["casella", "offerta", "comprata"])
	var verbs: Array = offered.keys()
	verbs.sort()
	var totale_benefici: int = 0
	var totale_costi: int = 0
	for verb in verbs:
		var quante: int = int(bought.get(verb, 0))
		var e_beneficio: bool = CouncilEconomy.BENEFIT_VERBS.has(str(verb))
		if e_beneficio:
			totale_benefici += quante
		else:
			totale_costi += quante
		print("%-18s %8d %8d   %s%s" % [
			str(verb), int(offered[verb]), quante,
			"beneficio" if e_beneficio else "costo",
			"" if int(named.get(verb, 0)) == 0
				else "  · %d su un'altra domanda, indicata col dito" % int(named[verb]),
		])
	print("")
	print("  Consigli aperti in %d partite: %d" % [runs, consigli])
	print("  Benefici comprati:  %4d   (%.2f per Consiglio)" % [
		totale_benefici, float(totale_benefici) / float(maxi(1, consigli))
	])
	print("  Costi posati:       %4d   (%.2f per Consiglio)" % [
		totale_costi, float(totale_costi) / float(maxi(1, consigli))
	])
	print("  Caselle diverse comprate in tutto: %d su %d del vocabolario" % [
		(bought.keys() as Array).size(),
		CouncilEconomy.BENEFIT_VERBS.size() + CouncilEconomy.COST_VERBS.size(),
	])
	quit(0)
