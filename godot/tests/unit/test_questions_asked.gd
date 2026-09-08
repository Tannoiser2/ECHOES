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
##
## Col Consiglio a due domande (D-467, D-472) la memoria cambia di una riga:
## **vale come posta la domanda che ha vinto** - la A del proponente o la B
## di chi l'ha presa - e se non vince nessuna non si consuma niente. Le prove
## fabbricano l'esito col mucchio: 99 e nessuna parte ci arriva, 0 e vince
## chi ha una carta o una pedina in piu'.

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


## Il mucchio del voto e' il calore del Tema all'apertura (D-467): si fissa
## prima di aprire, ed e' la leva con cui una prova decide chi puo' vincere.
func _pile(tension_id: String, value: int) -> void:
	var theme_id: String = str((session.data.tensions[tension_id] as Dictionary).get("theme", ""))
	(session.world["theme_heat"] as Dictionary)[theme_id] = value


func _question_ids() -> Array:
	var out: Array = []
	for question in session.confluence.available_questions():
		out.append(str((question as Dictionary)["id"]))
	return out


## Chiude il Consiglio aperto: ogni altro seggio prende la parte detta e posa
## una pedina se la parte ha una casella libera; chi ha una mano impegna
## quante carte puo' - il proponente solo se la prova lo vuole; poi si vota.
func _vote(side: String, proponent_commits: bool = true) -> Dictionary:
	var proponent: String = str(session.confluence.current["proponent"])
	for entity_id in session.confluence.stance_order():
		var seat: String = str(entity_id)
		assert_true(session.confluence.join_side(seat, side), "%s sta con %s" % [seat, side])
		var menu: Array = session.confluence.box_menu(side)
		if not menu.is_empty():
			session.confluence.place_box(seat, str((menu[0] as Dictionary)["id"]))
	for entity_id in session.world["turn_order"]:
		var seat: String = str(entity_id)
		if seat == proponent and not proponent_commits:
			continue
		var hand: Array = session.service.hand(seat)
		var limit: int = session.confluence.max_commit_for(seat)
		assert_true(
			session.confluence.commit(seat, hand.slice(0, limit)),
			"%s impegna le carte" % seat
		)
	return session.confluence.resolve()


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
	# E la parte A che segue e' la sua: e' cosi' che il contenuto scritto e mai
	# votato torna raggiungibile (D-035).
	assert_eq(session.confluence.side_question("A"), "Q_FAMINE_GRAIN", "la parte A e' la domanda nuova")


## Quando non resta piu' niente da chiedere, il Consiglio non si apre (D-077).
##
## La guardia qui difendeva l'opposto - «il filtro si toglie di mezzo e si
## ripropone tutto» - e alla frequenza dei Consigli del 2022 il caso era
## teorico. La prima saga giocata l'ha reso reale: la stessa domanda decisa
## due volte nello stesso anno, e nel 1827 due eredi nominati da due
## proponenti diversi. Una domanda decisa resta decisa.
func test_when_every_question_has_been_asked_the_council_stays_shut() -> void:
	session.world["questions_asked"] = {TENSION: ["Q_FAMINE_LAND", "Q_FAMINE_GRAIN"]}
	assert_false(
		session.confluence.has_fresh_question(TENSION),
		"la Tensione non ha piu' niente di nuovo da chiedere"
	)
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_true(context.is_empty(), "e il Consiglio non si apre")
	assert_true(
		session.confluence.has_fresh_question("TEN_ROADS"),
		"mentre una Tensione con domande ancora da fare resta apribile"
	)


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


## E nemmeno un voto senza vincitore consuma: se nessuna parte arriva al
## mucchio non si e' deciso niente, e la domanda resta sul tavolo (D-077,
## riletta in D-467). Senza questo, un Consiglio andato male chiudeva la
## questione per l'anno intero - e con D-077 nessuno poteva piu' riaprirla:
## la prima misura lo pagava in seggi bloccati, non in Consigli risparmiati.
func test_when_no_side_wins_the_question_stays_on_the_table() -> void:
	# Mucchio a 99: nessuna parte ci arriva, qualunque cosa impegni.
	_pile(TENSION, 99)
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence si apre")
	var question_id: String = str(context["question_id"])
	var result: Dictionary = _vote("A")
	assert_eq(str(result["outcome"]), "FAILURE", "e non passa nessuna parte")
	assert_eq(str(result["winner"]), "", "nessuno ha vinto")
	assert_eq(
		(session.world["questions_asked"] as Dictionary).get(TENSION, []), [],
		"non decisa: la domanda non risulta posta"
	)
	assert_true(
		session.confluence.has_fresh_question(TENSION),
		"e la Tensione puo' ancora aprire un Consiglio"
	)
	# Il fallimento ha sfogato la Tensione, quindi la domanda affilata non e'
	# al momento eleggibile. Quando la Carestia torna al limite, la domanda
	# rimasta senza risposta torna sul tavolo.
	_heat(TENSION, 6)
	var again: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_eq(
		str(again["question_id"]), question_id,
		"che ripropone la stessa domanda rimasta senza risposta"
	)


## La riga nuova di D-467: si segna **la domanda che ha vinto**, non quella
## che il proponente aveva preso. Tre seggi con carte e pedine sulla B contro
## un proponente a mani vuote: vince la B, e ai voti risulta posta la sua
## domanda; quella del proponente resta fresca e torna sul tavolo.
func test_the_question_marked_asked_is_the_one_that_won() -> void:
	_pile(TENSION, 0)
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_eq(str(context["question_id"]), "Q_FAMINE_LAND", "il proponente ha preso la piu' affilata")
	assert_eq(session.confluence.side_question("B"), "Q_FAMINE_GRAIN", "e l'altra e' la B")
	var result: Dictionary = _vote("B", false)
	assert_eq(str(result["outcome"]), "COUNTER", "tre seggi con carte contro nessuna: vince la B (%s)" % str(result))
	assert_eq(str(result["winning_question_id"]), "Q_FAMINE_GRAIN", "e il risultato dice quale domanda")
	assert_eq(
		(session.world["questions_asked"] as Dictionary).get(TENSION, []), ["Q_FAMINE_GRAIN"],
		"risulta posta la domanda che ha vinto, non quella del proponente"
	)
	_heat(TENSION, 6)
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_eq(_question_ids(), ["Q_FAMINE_LAND"], "e la domanda del proponente resta da fare")


## E il campo nasce vuoto in ogni Chronicle: la memoria e' dell'anno che si sta
## giocando, non del mondo.
func test_a_new_chronicle_starts_with_nothing_asked() -> void:
	assert_true(session.world.has("questions_asked"), "il campo c'e")
	assert_eq(session.world["questions_asked"], {}, "e comincia vuoto")


## D-094: la spirale del fallimento si chiude ri-decidendo. Un voto senza
## vincitore scrive `question_unresolved` e apre il conto dell'era; quando la
## questione torna ai voti e una parte vince, il conto si chiude e il segno
## sparisce dal mondo.
func test_deciding_the_fallen_question_closes_the_spiral() -> void:
	_pile(TENSION, 99)
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_eq(str(_vote("A")["outcome"]), "FAILURE", "non passa nessuna parte")
	assert_true(
		(session.world["global_tags"] as Array).has("question_unresolved"),
		"e il mondo porta il segno della spirale"
	)
	assert_eq(session.world["open_failures"], [TENSION], "il conto dell'era e' aperto")

	# Mucchio a zero e tutti con A: stavolta una parte vince.
	_heat(TENSION, 6)
	_pile(TENSION, 0)
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	var result: Dictionary = _vote("A")
	assert_true(str(result["outcome"]) != "FAILURE", "stavolta il tavolo decide (%s)" % str(result["outcome"]))
	assert_eq(str(result["winner"]), "A", "e vince la A")
	assert_true((session.world["open_failures"] as Array).is_empty(), "il conto si chiude")
	assert_false(
		(session.world["global_tags"] as Array).has("question_unresolved"),
		"e il segno sparisce: la spirale e' chiusa"
	)


## Il segno ereditato da un'era prima invece non si chiude per caso: nessun
## conto di quest'era lo riguarda, e lo scioglie solo la via del riprendere
## (P_RETAKE_QUESTION, D-094).
func test_an_inherited_mark_does_not_close_by_accident() -> void:
	session.applier.apply(Effect.make(
		"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "question_unresolved"},
		{"kind": "TEST", "id": "inherited"}
	))
	_pile(TENSION, 0)
	session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_true(str(_vote("A")["outcome"]) != "FAILURE", "il Consiglio decide")
	assert_true(
		(session.world["global_tags"] as Array).has("question_unresolved"),
		"ma il segno di un'altra era resta sul mondo"
	)
