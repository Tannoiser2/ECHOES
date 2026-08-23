extends "res://tests/test_case.gd"
## ISSUES 21: la mossa che spegne il tuo Destino avverta prima.
##
## Nella partita vera al seme 15308 Vaerax entra nell'ultimo round con la
## prima spunta accesa («Presenza sulle Montagne Rosse») e la spegne da solo:
## un MOVE al limite dei token toglie il presidio dalla montagna senza che
## l'app dica nulla. Al tavolo fisico un compagno te lo farebbe notare; il
## SeatDecider - lo stesso del terminale e del browser (D-038) - adesso lo fa:
## una riga di avviso e la scelta di ripensarci. Solo il posto proprio, solo
## clausole gia' accese, nessun suggerimento strategico.

const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")

const MOUNTAIN: String = "REG_MONTAGNE_ROSSE"


## Un io con le risposte in fila: ogni chiamata a choose consuma la prossima.
## Registra tutto quello che gli viene detto e offerto, per le asserzioni.
class ScriptedIo extends RefCounted:
	var said: Array = []
	var asks: Array = []
	var answers: Array = []

	func say(text: String) -> void:
		said.append(str(text))

	func choose(_prompt: String, labels: Array, _subjects: Array = []) -> int:
		asks.append(labels.duplicate())
		if answers.is_empty():
			return -1
		return int(answers.pop_front())


func _apply(type: String, kind: String, id: String, payload: Dictionary) -> void:
	session.applier.apply(
		Effect.make(type, kind, id, payload, Effect.source("developer", "TEST", "", 1, 1, 0))
	)


## Vaerax al limite dei token, il primo sulla montagna: qualunque MOVE verso
## un'altra Regione toglie da li'. E' la forma della mossa del seme 15308.
func _seat_vaerax_on_the_mountain() -> void:
	var presence: Array = (session.world["entities"]["ENT_VAERAX"]["presence"] as Array).duplicate()
	for region_id in presence:
		_apply("REMOVE_PRESENCE", "entity", "ENT_VAERAX", {"region_id": str(region_id)})
	# **Una sola pedina sulla montagna, e la montagna prima in ordine.** Due
	# cose, e tutte e due contano:
	#
	#   · una sola, perche' la clausola chiede `min: 1` e con due toglierne una
	#     non spegne niente. La prima stesura distribuiva a giro su tre Regioni:
	#     col tetto a 3 tornava una ciascuna, ma D-211 l'ha portato a 4 e il
	#     giro ne posava **due** sulla montagna;
	#   · prima in ordine, perche' la pedina che parte la sceglie
	#     `_pick_source_region`, che legge `regions_with_presence` — e quella
	#     **ordina**. Le altre Regioni stanno tutte dopo «MONTAGNE» in
	#     alfabeto, cosi' qualunque mossa altrove parte da li'. Con le Miniere
	#     in mano toccava a loro, e l'avviso taceva per la ragione giusta.
	var limit: int = int(session.data.chronicles["CHR_01"]["presence_tokens"])
	_apply("ADD_PRESENCE", "entity", "ENT_VAERAX", {"region_id": MOUNTAIN})
	# Le tre Regioni si ripetono a giro invece di prenderne altre: le altre due
	# della mappa — Eredan e le Miniere — stanno **prima** di «MONTAGNE» in
	# alfabeto, e metterci una pedina sposterebbe la partenza di
	# `_pick_source_region` altrove, che e' esattamente cio' che questa prova non
	# vuole. Due pedine sulla stessa Regione sono legali e contano (§10), quindi
	# il giro riempie il tetto senza toccare l'ordine. Con D-227 il tetto e'
	# cinque e le tre Regioni non bastavano piu': la prova posava quattro pedine
	# invece di cinque, Vaerax non era al limite, e l'avviso taceva per la
	# ragione sbagliata.
	var elsewhere: Array = ["REG_STRADA_MERCANTI", "REG_TERRE_NAHR", "REG_VALLE_VERDE"]
	for i in range(limit - 1):
		_apply("ADD_PRESENCE", "entity", "ENT_VAERAX", {
			"region_id": str(elsewhere[i % elsewhere.size()])
		})
	assert_eq(
		session.service.presence_count("ENT_VAERAX", MOUNTAIN), 1,
		"una sola pedina sulla montagna: e' la forma della mossa del seme 15308"
	)
	assert_eq(
		str((session.service.regions_with_presence("ENT_VAERAX") as Array)[0]), MOUNTAIN,
		"e la montagna e' la prima in ordine: e' da li' che parte chi si sposta"
	)


func _decider_with(io: RefCounted) -> RefCounted:
	var decider: RefCounted = SeatDecider.new(["ENT_VAERAX"], null)
	decider.io = io
	return decider


func _first_move_away(decider: RefCounted) -> int:
	var options: Array = decider._action_options("ENT_VAERAX", session)
	for i in range(options.size()):
		if str(options[i]["template"]) != "MOVE":
			continue
		if str(options[i]["params"]["region_id"]) != MOUNTAIN:
			return i
	return -1


func test_the_move_of_seed_15308_warns_before_confirming() -> void:
	new_session()
	_seat_vaerax_on_the_mountain()
	var io := ScriptedIo.new()
	var decider: RefCounted = _decider_with(io)
	var move: int = _first_move_away(decider)
	assert_true(move >= 0, "ci deve essere una mossa che porta via dalla montagna")

	io.answers = [move, 0]  # la mossa, poi «Sì, la faccio»
	var request: Dictionary = await decider.choose_action("ENT_VAERAX", 0, session)

	var warned: bool = false
	for line in io.said:
		if str(line).contains("spegne") and str(line).contains("Presenza sulle Montagne Rosse"):
			warned = true
	assert_true(warned, "l'avviso nomina la clausola che si spegnerebbe")
	assert_eq(io.asks.size(), 2, "prima la mossa, poi la conferma: due domande")
	assert_eq(str(request["template"]), "MOVE", "confermata, la mossa resta sua")
	# L'avviso e' un'anteprima: il mondo vero non deve essere stato toccato.
	assert_true(
		(session.world["entities"]["ENT_VAERAX"]["presence"] as Array).has(MOUNTAIN),
		"il presidio sulla montagna e' ancora li': nessuna anteprima e' trapelata"
	)


func test_thinking_again_returns_to_the_menu() -> void:
	new_session()
	_seat_vaerax_on_the_mountain()
	var io := ScriptedIo.new()
	var decider: RefCounted = _decider_with(io)
	var move: int = _first_move_away(decider)
	assert_true(move >= 0, "ci deve essere una mossa che porta via dalla montagna")

	var options: int = decider._action_options("ENT_VAERAX", session).size()
	io.answers = [move, 1, options]  # la mossa, «No, ci ripenso», poi «Passa»
	var request: Dictionary = await decider.choose_action("ENT_VAERAX", 0, session)

	assert_eq(str(request["template"]), "PASS", "il ripensamento torna al menu, e si puo' passare")
	assert_eq(io.asks.size(), 3, "mossa, conferma, e il menu di nuovo")


func test_a_move_that_leaves_the_destiny_alone_says_nothing() -> void:
	new_session()
	_seat_vaerax_on_the_mountain()
	var io := ScriptedIo.new()
	var decider: RefCounted = _decider_with(io)
	# Un ACQUIRE non tocca presenze, tag o Tensioni: nessuna clausola si spegne.
	var options: Array = decider._action_options("ENT_VAERAX", session)
	var quiet: int = -1
	for i in range(options.size()):
		if str(options[i]["template"]) == "ACQUIRE":
			quiet = i
	assert_true(quiet >= 0, "ci deve essere un'azione che non tocca il Destino")

	io.answers = [quiet]
	var request: Dictionary = await decider.choose_action("ENT_VAERAX", 0, session)

	assert_eq(str(request["template"]), "ACQUIRE", "la mossa torna senza cerimonie")
	assert_eq(io.asks.size(), 1, "nessuna conferma chiesta")
	for line in io.said:
		assert_false(str(line).contains("spegne"), "e nessun avviso detto: %s" % str(line))
