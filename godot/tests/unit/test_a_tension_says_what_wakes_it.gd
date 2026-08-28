extends "res://tests/test_case.gd"
## **SI ACCENDE QUANDO** ([D-330](../../docs/DECISIONS.md#d-330)).
##
## La casella che il committente ha disegnato sulla faccia della Tensione: la
## carta dice, in regola leggibile al tavolo, **cosa le fa prendere Calore**.
## Fino alla 0.1.292 il Calore andava sempre alla questione piu' vicina alla
## soglia del suo Tema — un ponte che il codice stesso dichiarava provvisorio
## (D-261). Adesso va a quella che **quel gesto** riguarda.
##
## Il banco della suite porta **una sola questione per Tema**, e con una sola
## questione il ponte e la casella sceglierebbero la stessa: la prova passerebbe
## senza provare niente. Quindi la seconda questione **se la fabbrica**, e la
## mette lontanissima dalla soglia — cosi' il ponte non la sceglierebbe mai, e
## se il Calore ci arriva e' stata la casella.

const Effect := preload("res://scripts/core/effect.gd")

const SEAT: String = "ENT_ALDRIC"
const CARD: String = "AST_FORCE_LEVY"
const MARK: String = "condition:contested"
const TWIN: String = "TEN_TEST_TWIN"


func before_each() -> void:
	new_session()


## La carta, con un'Azione stampata che posa un segno: la forma di 29 carte
## della scatola. Copiata da `test_both_printed_actions`, che la usa per la
## stessa ragione.
func _a_card_that_marks() -> void:
	var card: Dictionary = session.data.assets[CARD] as Dictionary
	var face: Dictionary = card["physical"] as Dictionary
	face["actions"] = [{
		"label": "Tenerli a casa", "text": "...", "template": "MOVE",
		"puts_tag": [MARK],
	}]
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(CARD):
		hand.append(CARD)


## Il Tema che quella carta scalda: si chiede alla carta, non si scrive a mano.
func _theme_of_the_card() -> String:
	var card: Dictionary = session.data.assets[CARD] as Dictionary
	return str(((card["physical"] as Dictionary)["resonance"] as Dictionary)["theme"])


## La seconda questione di quel Tema, in gioco e lontana dalla soglia.
func _fabricate_twin(rules: Array) -> String:
	var twin: Dictionary = (session.data.tensions["TEN_FAMINE"] as Dictionary).duplicate(true)
	twin["id"] = TWIN
	twin["title"] = "La Gemella di Prova"
	twin["theme"] = _theme_of_the_card()
	twin["threshold"] = 12
	twin["heats_when"] = rules
	session.data.tensions[TWIN] = twin
	session.world["tensions"][TWIN] = {
		"id": TWIN, "current_value": 1, "visibility": "OPEN",
		"fired_omens": [], "resolved_count": 0,
	}
	return TWIN


## Le questioni di quel Tema gia' in gioco, gemella esclusa.
func _siblings() -> Array:
	var out: Array = []
	for tension_id in session.world["tensions"]:
		if str(tension_id) == TWIN:
			continue
		var definition: Dictionary = session.data.tensions[str(tension_id)]
		if str(definition.get("theme", "")) == _theme_of_the_card():
			out.append(str(tension_id))
	out.sort()
	return out


## Dove quella carta si puo' calare adesso.
func _somewhere_legal() -> String:
	for region_id in session.world["regions"]:
		var params: Dictionary = {
			"asset_id": CARD, "face_action": 0, "region_id": str(region_id),
		}
		if session.actions.check(SEAT, "PLAY_CARD", params) == "":
			return str(region_id)
	return ""


func _play() -> Dictionary:
	var region_id: String = _somewhere_legal()
	assert_ne(region_id, "", "la carta si puo' calare da qualche parte")
	return session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARD, "face_action": 0, "region_id": region_id},
	})


## **La questione che il gesto riguarda prende il Calore, non la piu' vicina.**
func test_the_printed_rule_chooses_the_question() -> void:
	_a_card_that_marks()
	var twin: String = _fabricate_twin([{
		"text": "una carta posa #conteso", "puts_tag": [MARK],
	}])
	var before: int = session.tensions.value(twin)

	var outcome: Dictionary = _play()
	assert_true(bool(outcome.get("ok", false)),
		"la carta si gioca: %s" % [str(outcome.get("error", ""))])
	assert_true(session.tensions.value(twin) > before,
		"il Calore e' andato alla questione che il gesto riguarda (%d -> %d)"
			% [before, session.tensions.value(twin)])


## **Senza casella, vale il ponte** — il ripiego dichiarato, non un caso.
func test_without_the_box_the_bridge_still_carries() -> void:
	_a_card_that_marks()
	var twin: String = _fabricate_twin([])
	var siblings: Array = _siblings()
	assert_true(siblings.size() > 0, "il Tema ha gia' una questione in gioco")
	var before_twin: int = session.tensions.value(twin)
	var before_others: int = 0
	for tension_id in siblings:
		before_others += session.tensions.value(str(tension_id))

	assert_true(bool(_play().get("ok", false)), "la carta si gioca")
	assert_eq(session.tensions.value(twin), before_twin,
		"senza riga la gemella non prende niente")
	var after_others: int = 0
	for tension_id in siblings:
		after_others += session.tensions.value(str(tension_id))
	assert_true(after_others > before_others,
		"il ponte ha portato il Calore altrove (%d -> %d)" % [before_others, after_others])


## **Il filtro del luogo morde.** Senza questa prova, `on_region_with` sarebbe
## decorazione: una riga che chiede la miniera si accenderebbe ovunque.
func test_the_place_filter_bites() -> void:
	_a_card_that_marks()
	var twin: String = _fabricate_twin([{
		"text": "una carta posa #conteso su una Regione con #miniera",
		"puts_tag": [MARK], "on_region_with": ["mine"],
	}])
	var before: int = session.tensions.value(twin)

	assert_true(bool(_play().get("ok", false)), "la carta si gioca")
	assert_eq(session.tensions.value(twin), before,
		"la riga non si e' accesa: il gesto non e' caduto su una #miniera")


## **Una riga senza verbo non si accende.** Il validatore la vieta nei dati;
## questa tiene onesto il motore anche se ci arrivasse lo stesso.
func test_a_rule_with_no_verb_never_wakes() -> void:
	_a_card_that_marks()
	var twin: String = _fabricate_twin([{"text": "una riga che non guarda niente"}])
	var before: int = session.tensions.value(twin)

	assert_true(bool(_play().get("ok", false)), "la carta si gioca")
	assert_eq(session.tensions.value(twin), before,
		"una riga senza verbo non ha svegliato niente")
