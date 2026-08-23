extends "res://tests/test_case.gd"
## I mucchi coperti (ISSUES 49 fase 3).
##
## «Ogni carta o azione fa pescare uno o più segnalini coperti che danno un
## valore a una tensione. A un certo punto, quando parte la Confluence, si
## girano, e la tensione col punteggio più alto viene dibattuta.»
##
## Coprire un mucchio in cui ogni gettone vale 1 non nasconde niente: si conta a
## occhio. Quindi la regola è **una sola cosa in due metà** — i gettoni prendono
## un valore dal sacchetto, e il punteggio smette di essere pubblico. Provarne
## una sola vuol dire spedire mezza regola.
##
## E c'è una terza cosa, che è la lezione di §5ter: **nessuna misura copre quello
## che una persona legge**. Il verbale, la scheda del seggio e la pagina d'aiuto
## sono tre finestre sullo stesso numero, e basta che una resti aperta perché
## coprire diventi teatro. Qui si guardano tutte e tre.

const Effect := preload("res://scripts/core/effect.gd")

const FACES: Array = [0, 1, 1, 2]


func before_each() -> void:
	new_session()


func _covered(faces: Array = FACES) -> Dictionary:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["tension_tokens"] = {
		"per_action": 1, "replaces_drift": true, "table_gate": 2, "covered": faces
	}
	session.actions.set("_chronicle", chronicle)
	return chronicle


func _open(gate: int = 2) -> Dictionary:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	chronicle["tension_tokens"] = {
		"per_action": 1, "replaces_drift": true, "table_gate": gate
	}
	session.actions.set("_chronicle", chronicle)
	return chronicle


func _token(tension_id: String, worth: int) -> void:
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", tension_id, {"delta": worth},
		Effect.source("system", "TENSION_TOKEN", "", 1, 1, 0)
	))


## Senza il sacchetto dei valori niente è coperto: è il lato classico
## dell'interruttore, e va detto per primo.
func test_without_the_bag_nothing_is_covered() -> void:
	_open()
	assert_false(session.tensions.piles_are_covered(), "senza `covered` i mucchi si leggono")
	assert_true(
		session.tensions.public_status("TEN_FAMINE").contains("/")
			or not session.tensions.public_status("TEN_FAMINE").contains("coperti"),
		"il verbale scoperto non parla di gettoni coperti"
	)


## Dichiarato il sacchetto, il verbale pubblico smette di dire il punteggio e
## dice quanti gettoni sono caduti — quello che al tavolo si vede davvero.
func test_the_public_log_says_the_pile_not_the_score() -> void:
	_covered()
	_token("TEN_FAMINE", 2)
	_token("TEN_FAMINE", 0)
	var line: String = session.tensions.public_status("TEN_FAMINE")
	assert_true(line.contains("2 gettoni coperti"), "dice quanti gettoni: '%s'" % line)
	assert_false(
		line.contains(str(session.tensions.value("TEN_FAMINE"))),
		"e non dice il punteggio: '%s'" % line
	)


## E non dice nemmeno quale sia il più alto: quella riga **è** l'informazione
## che coprire toglie, e stamparla renderebbe la copertura una decorazione.
func test_the_public_log_never_names_the_tallest() -> void:
	_covered()
	_token("TEN_FAMINE", 2)
	for tension_id in session.world["tensions"]:
		assert_false(
			session.tensions.public_status(str(tension_id)).contains("più alto"),
			"coperto, il verbale non nomina il mucchio più alto"
		)


## Il gettone bianco: vale zero, non muove niente, **ma è sceso**. Conta per il
## mucchio e si vede cadere, ed è metà del punto di coprire — se lo zero non
## contasse, contare i gettoni tornerebbe a dire il punteggio.
func test_the_blank_token_still_lands() -> void:
	_covered()
	var before: int = session.tensions.value("TEN_FAMINE")
	_token("TEN_FAMINE", 0)
	assert_eq(session.tensions.value("TEN_FAMINE"), before, "lo zero non muove il punteggio")
	assert_eq(session.tensions.tokens_on("TEN_FAMINE"), 1, "ma il gettone è sceso lo stesso")


## E il conto dei gettoni non conta la Deriva: quella non è un gettone del
## tavolo, e sommarla direbbe un mucchio che nessuno ha costruito.
func test_the_pile_counts_tokens_and_not_the_drift() -> void:
	_covered()
	_token("TEN_FAMINE", 1)
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 1},
		Effect.source("system", "DRIFT", "", 1, 1, 0)
	))
	assert_eq(session.tensions.tokens_on("TEN_FAMINE"), 1, "un gettone, non due")


## Il cancello continua a contare i **gettoni**: coprire cambia quale domanda
## vince, non quanto spesso si parla.
func test_covering_does_not_change_how_often_the_council_opens() -> void:
	_covered()
	session.world["tokens_in_bag"] = 1
	assert_true(session.tensions.tensions_at_threshold().is_empty(), "sotto il cancello si tace")
	session.world["tokens_in_bag"] = 2
	assert_false(session.tensions.tensions_at_threshold().is_empty(), "al cancello si apre")


## La scheda che una persona ha in mano è la seconda finestra: se qui il numero
## restasse scritto, coprire il verbale sarebbe teatro.
func test_the_seat_sheet_is_covered_too() -> void:
	_covered()
	_token("TEN_AWAKENING", 2)
	var decider: RefCounted = load("res://scripts/seat/seat_decider.gd").new(
		["ENT_LYRA"], session.log
	)
	var reading: String = decider._tension_reading("TEN_AWAKENING", "ENT_LYRA", session)
	assert_true(reading.contains("coperti") or reading.contains("gettone"), "dice i gettoni: '%s'" % reading)
	assert_false(reading.contains("più alto"), "e non dice chi è il più alto: '%s'" % reading)


## E la terza finestra: la pagina d'aiuto. Una persona che conta i gettoni e
## crede di sapere l'altezza sta giocando un altro gioco, e la pagina glielo
## deve dire.
func test_the_help_page_says_the_piles_are_covered() -> void:
	var chronicle: Dictionary = session.data.chronicles["CHR_01"] as Dictionary
	var before: Variant = chronicle.get("tension_tokens")
	chronicle["tension_tokens"] = {
		"per_action": 1, "replaces_drift": true, "table_gate": 2, "covered": FACES
	}
	# La pagina e' un nodo, non un oggetto contato: si costruisce, le si chiede
	# il testo e la si libera a mano.
	var panel: Node = load("res://ui/help_panel.gd").new()
	var lines: Array = panel.call("_lines", session.data, "CHR_01")
	panel.free()
	if before == null:
		chronicle.erase("tension_tokens")
	else:
		chronicle["tension_tokens"] = before
	var text: String = "\n".join(PackedStringArray(lines))
	assert_true(text.contains("MUCCHI SONO COPERTI"), "la pagina lo dice")
	assert_true(text.contains("quanti gettoni"), "e dice cosa si vede davvero")
	assert_true(text.contains("0 / 1 / 1 / 2"), "e nomina le facce del sacchetto")
