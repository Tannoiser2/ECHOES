extends "res://tests/test_case.gd"
## Il rubinetto della mano (ISSUES 47, D-185).
##
## «La presenza nelle regioni deve essere fondamentale nella pesca delle carte,
## tipo due presenze due carte.»
##
## Quante carte lo dicono le pedine, **di che famiglia** lo dice la Regione dove
## stanno. I due freni sono la parte che conta: il **pavimento** tiene in gioco
## chi resta senza mappa, il **tetto** e' il freno alla divergenza misurata in
## D-183 — piu' presenza da' piu' carte, piu' carte danno piu' presenza.

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


func _chronicle() -> Dictionary:
	return session.data.chronicles["CHR_TEST"] as Dictionary


func _hand_size() -> int:
	return (session.world["entities"][SEAT]["hand"] as Array).size()


func _presence(regions: Array) -> void:
	(session.world["entities"][SEAT]["presence"] as Array).assign(regions)


## Spento - il default - il rubinetto non esiste e le carte si pescano solo
## con ACQUISIRE, come in v0.2.
func test_without_the_rule_the_map_gives_nothing() -> void:
	assert_true(
		(_chronicle().get("hand_refill", {}) as Dictionary).is_empty(),
		"sul lato classico dell'interruttore la Chronicle non tiene rubinetto"
	)
	var before: int = _hand_size()
	session.chronicle.call("_refill_hands", 1)
	assert_eq(_hand_size(), before, "senza la regola nessuno pesca")


## Due presenze, due carte.
func test_two_tokens_two_cards() -> void:
	_chronicle()["hand_refill"] = {"per_token": 1, "floor": 0, "cap": 9}
	_presence(["REG_EREDAN", "REG_VALLE_VERDE"])
	var before: int = _hand_size()
	session.chronicle.call("_refill_hands", 1)
	assert_eq(_hand_size(), before + 2, "due pedine danno due carte")
	_chronicle()["hand_refill"] = {}


## Il tetto: e' il freno alla divergenza, e deve mordere prima delle pedine.
func test_the_cap_is_the_brake() -> void:
	_chronicle()["hand_refill"] = {"per_token": 1, "floor": 0, "cap": 2}
	_presence(["REG_EREDAN", "REG_VALLE_VERDE", "REG_STRADA_MERCANTI"])
	var before: int = _hand_size()
	session.chronicle.call("_refill_hands", 1)
	assert_eq(_hand_size(), before + 2, "tre pedine, ma il tetto e due")
	_chronicle()["hand_refill"] = {}


## Il pavimento: chi non ha piu' niente sulla mappa pesca lo stesso, o non si
## rialza. D-183 dice che oggi non succede mai, ma e' il freno che costa meno.
func test_the_floor_keeps_the_landless_in_the_game() -> void:
	_chronicle()["hand_refill"] = {"per_token": 1, "floor": 1, "cap": 3}
	_presence([])
	var before: int = _hand_size()
	session.chronicle.call("_refill_hands", 1)
	assert_eq(_hand_size(), before + 1, "senza pedine si pesca il pavimento")
	_chronicle()["hand_refill"] = {}


## E la famiglia la sceglie la mappa: chi tiene solo le Montagne Rosse pesca
## quello che le Montagne Rosse danno (FORCE o BONDS), non quello che vuole.
func test_the_region_decides_the_family() -> void:
	_chronicle()["hand_refill"] = {"per_token": 1, "floor": 0, "cap": 3}
	_presence(["REG_MONTAGNE_ROSSE"])
	var before: Array = (session.world["entities"][SEAT]["hand"] as Array).duplicate()
	session.chronicle.call("_refill_hands", 1)
	var after: Array = session.world["entities"][SEAT]["hand"] as Array
	assert_eq(after.size(), before.size() + 1, "una pedina, una carta")
	var fresh: String = ""
	for card_id in after:
		if not before.has(str(card_id)):
			fresh = str(card_id)
		elif after.count(str(card_id)) > before.count(str(card_id)):
			fresh = str(card_id)
	assert_ne(fresh, "", "la carta nuova si trova")
	var family: String = str((session.data.assets[fresh] as Dictionary)["family"])
	var sources: Array = (session.data.regions["REG_MONTAGNE_ROSSE"] as Dictionary)["asset_sources"]
	assert_true(
		sources.has(family),
		"la carta viene da cio' che la Regione da' (%s, e la Regione da' %s)" % [family, sources]
	)
	_chronicle()["hand_refill"] = {}


## Il tetto sulla **mano**: il rubinetto riempie fino a un numero e non oltre.
## E' il freno vero, perche' il `cap` per Atto limita la pesca ma non la mano -
## le carte non spese restano li' e lo scarto si accumula lo stesso (D-185).
## Chi ha ancora carte pesca meno; chi le ha spese pesca pieno.
func test_the_hand_cap_fills_up_to_a_number() -> void:
	_chronicle()["hand_refill"] = {"per_token": 1, "floor": 0, "cap": 9, "hand_cap": 4}
	_presence(["REG_EREDAN", "REG_VALLE_VERDE", "REG_STRADA_MERCANTI"])
	var before: int = _hand_size()
	assert_eq(before, 2, "la mano di partenza e due carte")
	session.chronicle.call("_refill_hands", 1)
	assert_eq(_hand_size(), 4, "tre pedine, ma si riempie fino a quattro")
	_chronicle()["hand_refill"] = {}


## E chi e' gia' al tetto non pesca niente, per quante pedine abbia.
func test_a_full_hand_draws_nothing() -> void:
	_chronicle()["hand_refill"] = {"per_token": 1, "floor": 2, "cap": 9, "hand_cap": 2}
	_presence(["REG_EREDAN", "REG_VALLE_VERDE", "REG_STRADA_MERCANTI"])
	var before: int = _hand_size()
	session.chronicle.call("_refill_hands", 1)
	assert_eq(_hand_size(), before, "chi e' al tetto non pesca, e nemmeno il pavimento lo scavalca")
	_chronicle()["hand_refill"] = {}
