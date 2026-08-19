extends "res://tests/test_case.gd"
## Il filo in casa (voce 27, fase 2 — D-135): il protocollo delle console,
## l'io remoto e l'instradamento per seggio. Il trasporto vero si misura con
## run_wire_probe (byte per byte); il contenuto con run_console_probe (100
## semi); qui si inchiodano le meccaniche che quelle sonde danno per scontate.

const Protocol := preload("res://scripts/net/console_protocol.gd")
const ConsoleIO := preload("res://scripts/net/console_io.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")


class EarIO:
	var heard: Array = []
	var answer: int = 0

	func say(text: String) -> void:
		heard.append(str(text))

	func choose(_prompt: String, _labels: Array, _subjects: Array = []) -> int:
		return answer


func before_each() -> void:
	new_session()


## Il protocollo va e torna intero: quello che si codifica si decodifica.
func test_the_protocol_round_trips() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var message: Dictionary = Protocol.state_message(session, seat)
	var back: Dictionary = Protocol.decode(Protocol.encode(message))
	assert_eq(str(back["kind"]), "state", "il tipo sopravvive al filo")
	assert_eq(
		str((back["model"] as Dictionary)["name"]), session.service.name_of(seat),
		"il modello sopravvive al filo"
	)
	assert_true(Protocol.decode("non e' json").is_empty(), "il rumore diventa un vuoto, non un crash")


## L'io remoto: lo stato fresco prima della domanda, la risposta giusta la
## sblocca, quella stantia si scarta, quella fuori misura vale «decidi tu».
func test_the_remote_io_asks_and_hears() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var io: RefCounted = ConsoleIO.new(session, seat)
	var wire: Array = []
	io.outgoing.connect(func(message: Dictionary) -> void: wire.append(message))

	io.say("una riga per il telefono")
	assert_eq(str((wire[0] as Dictionary)["kind"]), "say", "il say viaggia")

	var picked: Array = []
	var runner := func() -> void:
		picked.append(await io.choose("scegli", ["a", "b", "c"]))
	runner.call()
	assert_eq(str((wire[1] as Dictionary)["kind"]), "state", "prima della domanda, lo stato fresco")
	assert_eq(str((wire[2] as Dictionary)["kind"]), "choose", "poi la domanda")
	var ask_id: int = int((wire[2] as Dictionary)["ask_id"])

	io.deliver(Protocol.chosen_message(ask_id - 1, 0))
	assert_true(picked.is_empty(), "una risposta stantia non risponde")
	io.deliver({"kind": "say", "text": "rumore"})
	assert_true(picked.is_empty(), "il rumore nemmeno")
	io.deliver(Protocol.chosen_message(ask_id, 2))
	assert_eq(picked, [2], "la risposta giusta sblocca la scelta")
	assert_true((io.pending() as Dictionary).is_empty(), "e la domanda si chiude")

	picked.clear()
	runner.call()
	var second: int = int((wire[wire.size() - 1] as Dictionary)["ask_id"])
	assert_true(second > ask_id, "ogni domanda ha il suo numero")
	assert_false((io.pending() as Dictionary).is_empty(), "la domanda aperta si puo' riproporre")
	io.deliver(Protocol.chosen_message(second, 99))
	assert_eq(picked, [-1], "l'indice fuori misura vale «decidi tu»")


## L'instradamento (D-135): con due console, la domanda di un seggio arriva
## al suo telefono e a nessun altro; chi non ha console usa il ripiego.
func test_each_seat_hears_only_its_own_console() -> void:
	var seats: Array = session.world["turn_order"]
	var first: String = str(seats[0])
	var second: String = str(seats[1])
	var decider: RefCounted = SeatDecider.new([first, second], session.log)
	var mine := EarIO.new()
	var theirs := EarIO.new()
	decider.ios = {first: mine, second: theirs}

	await decider.choose_action(first, 0, session)
	assert_true(mine.heard.size() > 0, "la plancia arriva alla console del seggio")
	assert_eq(theirs.heard.size(), 0, "e non alla console del vicino")

	mine.heard.clear()
	await decider.choose_action(second, 0, session)
	assert_true(theirs.heard.size() > 0, "il secondo seggio sente la sua")
	assert_eq(mine.heard.size(), 0, "la prima tace")

	# Il ripiego condiviso resta per chi non ha console (hotseat, riserva).
	var shared := EarIO.new()
	var lone: RefCounted = SeatDecider.new([first], session.log)
	lone.io = shared
	await lone.choose_action(first, 0, session)
	assert_true(shared.heard.size() > 0, "senza console si parla allo schermo comune")


## La perquisizione trova quello che deve trovare - e non di piu'. Le mani
## si controllano sulla struttura (le carte hanno copie: il titolo non e'
## un segreto, quali copie tieni si'), i Destini altrui sulle parole.
func test_the_audit_smells_a_planted_leak() -> void:
	var seats: Array = session.world["turn_order"]
	var mine: String = str(seats[0])
	var theirs: String = str(seats[1])
	var clean: Dictionary = Protocol.state_message(session, mine)
	assert_eq(Protocol.audit(clean, session, mine).size(), 0, "lo stato vero e' pulito")

	# Un titolo scartato a verbale non e' una fuga, anche se un vicino ne
	# tiene una copia: la prosa non si accusa.
	var their_hand: Array = session.service.hand(theirs)
	assert_true(their_hand.size() > 0, "il vicino ha una mano da proteggere")
	var twin: String = str(session.data.assets[str(their_hand[0])]["title"])
	var prose: Dictionary = Protocol.say_message(session, "scarta %s e rivendica." % twin)
	assert_eq(
		Protocol.audit(prose, session, mine).size(), 0,
		"una copia nominata nella prosa non e' la mano di nessuno"
	)

	# Lo state di un altro seggio, instradato a me: questa e' LA fuga.
	var stolen: Dictionary = Protocol.state_message(session, theirs)
	assert_true(
		Protocol.audit(stolen, session, mine).size() > 0,
		"lo state altrui sul mio filo si fiuta (mano e nome non tornano)"
	)

	# E il gradino del Destino altrui e' una frase d'autore: nel testo si fiuta.
	var their_destiny: Dictionary = session.data.destinies[session.service.destiny_of(theirs)]
	var leaky: Dictionary = Protocol.say_message(
		session, "ho letto «%s» sul suo tarocco" % str(their_destiny["minimum"]["label"])
	)
	assert_true(
		Protocol.audit(leaky, session, mine).size() > 0,
		"il Destino altrui nel messaggio si fiuta"
	)
