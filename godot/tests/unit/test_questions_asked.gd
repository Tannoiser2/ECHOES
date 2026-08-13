extends "res://tests/test_case.gd"
## Un Consiglio non rimette ai voti quello che ha gia' deciso (D-061).
##
## La sonda di testo ha trovato la cosa guardando quaranta Chronicle della
## seconda saga: il Debito poneva **94 volte su 94** la stessa domanda, e delle
## ventitre proposte scritte ne arrivavano ai voti dieci. Il registro delle
## Truth lo mostrava a chi giocava - la stessa frase tre volte nello stesso anno,
## con solo i numeri diversi.
##
## La causa non era la fortuna: la domanda affilata e' l'ultima in ordine di
## definizione, il default la sceglie sempre, e la policy - che gioca per il
## proprio Destiny - trova sempre la stessa proposta migliore. Niente di
## casuale, quindi niente che il caso potesse variare.
##
## Quello che questi test tengono fermo e' il filtro: **finche' resta una
## domanda che questa Tensione non ha ancora fatto, si fa quella**. Quando sono
## finite si torna alla piu' affilata, come prima.

const Effect := preload("res://scripts/core/effect.gd")

const TENSION: String = "TEN_FAMINE"
const TEMPLATE: String = "CNF_FAMINE_01"


func before_each() -> void:
	new_session()
	# La seconda domanda del template e' aperta solo con la Carestia al limite:
	# senza questo la scelta non esiste e il filtro non ha niente da filtrare.
	_heat(TENSION, 6)


func _heat(tension_id: String, target: int) -> void:
	var current: int = int(session.world["tensions"][tension_id]["current_value"])
	if current == target:
		return
	session.applier.apply(
		Effect.make(
			"ADJUST_TENSION",
			"tension",
			tension_id,
			{"delta": target - current},
			{"kind": "TEST", "id": "heat"}
		)
	)


func _question_ids() -> Array:
	var out: Array = []
	for question in session.confluence.available_questions():
		out.append(str((question as Dictionary)["id"]))
	return out


## Il default non cambia: la prima volta si fa la domanda piu' affilata.
func test_the_first_council_still_asks_the_sharpest_question() -> void:
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence si apre")
	assert_eq(_question_ids().size(), 2, "con la Carestia al limite le domande sono due")
	assert_eq(
		str(context["question_id"]), "Q_FAMINE_LAND",
		"e il default resta l'ultima in ordine di definizione, la piu affilata"
	)


## Il cuore: una domanda gia' messa ai voti esce dal tavolo finche' ne resta
## un'altra.
func test_a_question_already_put_to_the_vote_is_not_asked_again() -> void:
	session.world["questions_asked"] = {TENSION: ["Q_FAMINE_LAND"]}
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_eq(_question_ids(), ["Q_FAMINE_GRAIN"], "resta solo quella che non e stata fatta")
	assert_eq(
		str(context["question_id"]), "Q_FAMINE_GRAIN", "e il default e quella nuova"
	)
	# E le proposte che seguono sono le sue: e' cosi' che il contenuto scritto e
	# mai votato torna raggiungibile (D-035).
	var seen: Array = []
	for proposition in session.confluence.available_propositions():
		seen.append(str((proposition as Dictionary)["question_id"]))
	assert_false(seen.is_empty(), "la domanda nuova ha le sue proposte")
	assert_false(seen.has("Q_FAMINE_LAND"), "e nessuna e della domanda gia decisa")


## Quando non resta piu' niente da chiedere il filtro si toglie di mezzo: un
## Consiglio senza domande non e' un Consiglio.
func test_when_every_question_has_been_asked_the_filter_lets_go() -> void:
	session.world["questions_asked"] = {TENSION: ["Q_FAMINE_LAND", "Q_FAMINE_GRAIN"]}
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence si apre lo stesso")
	assert_eq(_question_ids().size(), 2, "e le domande tornano tutte")
	assert_eq(str(context["question_id"]), "Q_FAMINE_LAND", "col default di sempre")


## La memoria e' della Tensione, non del tavolo: due questioni diverse non si
## consumano le domande a vicenda.
func test_the_memory_belongs_to_the_tension() -> void:
	session.world["questions_asked"] = {TENSION: ["Q_FAMINE_LAND"]}
	_heat("TEN_ROADS", 6)
	var context: Dictionary = session.confluence.open("TEN_ROADS", {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "le Vie Interrotte aprono il loro Consiglio")
	assert_eq(_question_ids().size(), 2, "con tutte e due le domande ancora da fare")


## Una domanda vale come posta quando e' stata messa ai voti davvero: si segna
## alla risoluzione, non all'apertura. Una Confluence che si apre e non si chiude
## non consuma niente.
func test_an_unresolved_council_consumes_nothing() -> void:
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_eq(
		(session.world["questions_asked"] as Dictionary).get(TENSION, []), [],
		"aperta e non risolta: la Tensione non ha ancora chiesto niente"
	)


## E il campo nasce vuoto in ogni Chronicle: la memoria e' dell'anno che si sta
## giocando, non del mondo.
func test_a_new_chronicle_starts_with_nothing_asked() -> void:
	assert_true(session.world.has("questions_asked"), "il campo c'e")
	assert_eq(session.world["questions_asked"], {}, "e comincia vuoto")
