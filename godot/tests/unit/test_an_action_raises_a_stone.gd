extends "res://tests/test_case.gd"
## **Un'Azione della plancia alza una Pietra** (ISSUES 123, D-412).
##
## Il numero che ha aperto la voce: in cento partite **992 Pietre alzate, zero
## per mano di un'Azione**. Ottocentocinquantasei le posava l'apertura, 136 il
## Consiglio o un'Eco. Chi voleva costruire doveva convincere il tavolo — e il
## Consiglio paga meglio chi tace.
##
## La causa non era una taratura: **ACQUISIRE non era stampata su nessuna delle
## 96 facce**, e il commento del cervello lo diceva gia' — *«nessuna carta porta
## ACQUISIRE»*. Un'Azione che nessuno puo' giocare.
##
## Adesso dodici facce la portano, e ognuna dice **quale** Pietra: al tavolo si
## prende il segnalino disegnato sulla carta, non se ne sceglie uno fra dieci.
##
## Qui si prova la cosa e i suoi tre no. **Il no conta quanto il si'**: la
## stessa domanda, dentro l'Effetto, e' un no-op silenzioso — giusto per una
## frase d'autore che nomina la terra sbagliata, sbagliatissimo per un'azione
## che una persona sceglie. Un'azione legale che non fa niente e non avvisa e'
## il difetto peggiore che si possa scrivere.

const StoneRules := preload("res://scripts/world/stone_rules.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")

const SEAT: String = "ENT_ALDRIC"
## «Riserva di Grano»: la seconda faccia costruisce il Granaio.
const CARD: String = "AST_WEALTH_GRAIN"
const STONE: String = "STR_GRANARY"
const FACE: int = 1


## **La regola e' un interruttore della Chronicle** (D-412), e le prove unitarie
## giocano su `CHR_TEST`, che di suo tiene ACQUISIRE com'era nella §10. Qui si
## accende a mano: cosi' questa suite misura **la regola**, non quale Chronicle
## il committente ha acceso oggi.
func before_each() -> void:
	new_session()
	(session.data.chronicles["CHR_TEST"] as Dictionary)["acquire_rules"] = {
		"can_build_stone": true,
	}


## E si rispegne. Il `DataSet` di `test_case` e' **condiviso**: un interruttore
## lasciato acceso qui lo troverebbe addosso la suite dopo, ed e' una trappola
## che in questo progetto ha gia' morso (il sacchetto della Deriva).
func after_each() -> void:
	if session != null:
		(session.data.chronicles["CHR_TEST"] as Dictionary).erase("acquire_rules")
	super.after_each()


## La carta in mano, e un luogo dove quella Pietra ci sta davvero.
##
## **Fabbricato, non cercato** (regola di casa): una prova che va a caccia di
## una condizione fra i dati spediti smette di provare in silenzio il giorno in
## cui quella condizione sparisce.
func _a_place_for_the_stone() -> String:
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(CARD):
		hand.append(CARD)
	for region_id in session.world["regions"]:
		var where: String = str(region_id)
		if not session.actions.card_reaches(CARD, where):
			continue
		if StoneRules.refusal(session.data, session.world, where, STONE) != "":
			continue
		# La presenza e' dell'azione, non della terra: si posa a mano, perche'
		# questa prova misura la costruzione e non il movimento.
		if session.service.presence_count(SEAT, where) <= 0:
			(session.world["entities"][SEAT]["presence"] as Array).append(where)
		return where
	return ""


## La pedina si posa e si toglie a mano: qui si misura **la costruzione**, non
## il movimento. La presenza sta sulla casa, non sulla tessera.
func _stand(where: String) -> void:
	var standing: Array = session.world["entities"][SEAT]["presence"] as Array
	if not standing.has(where):
		standing.append(where)


func _leave(where: String) -> void:
	var standing: Array = session.world["entities"][SEAT]["presence"] as Array
	while standing.has(where):
		standing.erase(where)


func _raise(where: String) -> Dictionary:
	return session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARD, "face_action": FACE, "region_id": where},
	})


## **La Pietra si alza, ed e' di chi l'ha alzata.**
func test_an_action_raises_a_stone() -> void:
	var where: String = _a_place_for_the_stone()
	assert_ne(where, "", "c'e' un luogo dove quella Pietra ci sta")

	var outcome: Dictionary = _raise(where)
	assert_true(bool(outcome["ok"]), "la mossa passa: %s" % str(outcome.get("error", "")))

	var mine: Dictionary = {}
	for standing in (session.world["regions"][where]["structures"] as Array):
		if str((standing as Dictionary)["structure_type"]) == STONE:
			mine = standing as Dictionary
	assert_false(mine.is_empty(), "e la Pietra e' li'")
	assert_eq(str(mine.get("owner", "")), SEAT, "ed e' sua")
	assert_eq(int(mine.get("grade", 0)), 1, "e comincia dal primo grado")
	assert_true(
		(session.world["regions"][where]["tags"] as Array).has("structure:granary"),
		"e il segno del grado si posa con lei"
	)


## **Senza presenza non si costruisce.** E' la meta' della regola che rende la
## Pietra una cosa che si conquista: prima ci si va, poi si alza.
func test_without_presence_the_stone_does_not_rise() -> void:
	var where: String = _a_place_for_the_stone()
	assert_ne(where, "", "c'e' un luogo dove quella Pietra ci sta")
	_leave(where)

	var refusal: String = session.actions.check(SEAT, "PLAY_CARD", {
		"asset_id": CARD, "face_action": FACE, "region_id": where,
	})
	assert_ne(refusal, "", "il posto senza presenza si rifiuta")
	assert_true(
		refusal.contains("presenza"),
		"e il rifiuto dice perche': «%s»" % refusal
	)


## **E il rifiuto arriva prima della spesa.** Questa e' la prova che vale le
## altre: un'azione che si lascia chiedere e poi non fa niente ha gia' preso
## l'Opportunita' di chi l'ha chiesta.
func test_a_refused_stone_costs_nothing() -> void:
	var where: String = _a_place_for_the_stone()
	assert_ne(where, "", "c'e' un luogo dove quella Pietra ci sta")
	_leave(where)
	var hand_before: int = session.service.hand_size(SEAT)

	var outcome: Dictionary = _raise(where)
	assert_false(bool(outcome["ok"]), "la mossa non passa")
	assert_eq(
		session.service.hand_size(SEAT), hand_before,
		"e la carta e' ancora in mano"
	)


## **La stessa domanda la fanno in due, e rispondono uguale.** L'Effetto tace e
## l'Azione parla, ma il si' e il no devono essere gli stessi: se divergessero,
## il cervello proporrebbe mosse che il motore poi scarta in silenzio — ed e'
## esattamente il modo in cui una sonda torna zero senza che niente sia rotto.
func test_the_engine_and_the_action_agree_on_the_land() -> void:
	var checked: int = 0
	var disagreements: Array = []
	for region_id in session.world["regions"]:
		var where: String = str(region_id)
		_stand(where)
		for type_id in session.data.structure_types:
			var stone: String = str(type_id)
			var land_says: bool = (
				StoneRules.refusal(session.data, session.world, where, stone) == ""
			)
			var action_says: bool = session.actions.check(SEAT, "ACQUIRE", {
				"region_id": where, "structure_type": stone,
			}) == ""
			checked += 1
			if land_says != action_says:
				disagreements.append("%s/%s" % [where, stone])
	# Uno zero qui sarebbe la prova cieca: se non si e' guardato niente, non si
	# e' misurato niente.
	assert_true(checked > 50, "si sono guardate abbastanza coppie: %d" % checked)
	assert_true(
		disagreements.is_empty(),
		"la terra e l'Azione dicono la stessa cosa: %s" % ", ".join(
			PackedStringArray(disagreements.slice(0, mini(5, disagreements.size())))
		)
	)


## **Le Pietre della terra non si alzano**: bosco, sorgente, passo, sito antico
## sono la tessera, non ci si costruisce sopra. Al tavolo nessuno proverebbe;
## nel motore c'era una porta aperta, e adesso e' chiusa a voce alta.
func test_the_land_itself_cannot_be_built() -> void:
	var wild: Array = []
	for type_id in session.data.structure_types:
		if not bool((session.data.structure_types[type_id] as Dictionary)["owned"]):
			wild.append(str(type_id))
	assert_false(wild.is_empty(), "nel catalogo ci sono Pietre della terra")

	var where: String = str(session.world["regions"].keys()[0])
	_stand(where)
	for type_id in wild:
		var refusal: String = session.actions.check(SEAT, "ACQUIRE", {
			"region_id": where, "structure_type": str(type_id),
		})
		assert_ne(refusal, "", "«%s» non si costruisce" % str(type_id))


## **Dodici facce la portano, e ognuna dice quale Pietra.** Se domani una faccia
## nascesse senza `builds`, il motore non saprebbe cosa alzare e l'Azione
## tornerebbe muta come prima — in silenzio, che e' il modo in cui questa voce
## e' rimasta aperta.
func test_every_printed_acquire_names_its_stone() -> void:
	var building: int = 0
	var mute: Array = []
	for asset_id in session.data.assets:
		var printed: Array = (
			((session.data.assets[asset_id] as Dictionary).get("physical", {}) as Dictionary)
				.get("actions", []) as Array
		)
		for face in printed:
			if str((face as Dictionary).get("template", "")) != "ACQUIRE":
				continue
			var stone: String = str((face as Dictionary).get("builds", ""))
			if stone == "" or not session.data.structure_types.has(stone):
				mute.append("%s: «%s»" % [str(asset_id), str((face as Dictionary)["label"])])
			else:
				building += 1
	assert_true(building >= 12, "almeno dodici facce alzano una Pietra: %d" % building)
	assert_true(
		mute.is_empty(),
		"e nessuna ACQUISIRE stampata resta senza la sua Pietra: %s" % ", ".join(
			PackedStringArray(mute)
		)
	)


## **E sullo schermo si puo' prendere.** Il motore che sa alzare una Pietra e
## una plancia che non la offre sono la stessa cosa di prima: una regola scritta
## e mai giocata. Qui si parte da quello che una persona ha davanti.
##
## La prova nasce da un difetto vero, trovato dopo aver scritto tutto il resto:
## le voci dirette del decider offrivano ACQUISIRE **solo per famiglia**, quindi
## la Pietra non arrivava mai a chi gioca.
func test_the_board_offers_the_stone() -> void:
	var decider: RefCounted = SeatDecider.new([SEAT], session.log)
	var where: String = _a_place_for_the_stone()
	assert_ne(where, "", "c'e' un luogo dove quella Pietra ci sta")

	var offers: Array = decider._action_options(SEAT, session)
	var raising: Array = []
	for offer in offers:
		var params: Dictionary = (offer as Dictionary)["params"] as Dictionary
		if str(params.get("structure_type", "")) != "":
			raising.append(str((offer as Dictionary)["label"]))
	assert_false(
		raising.is_empty(),
		"fra le %d voci ce n'e' una che alza una Pietra" % offers.size()
	)
	for label in raising:
		for id in ["STR_", "REG_", "ENT_", "AST_"]:
			assert_false(
				str(label).contains(str(id)),
				"e nessuna la chiama per id: «%s»" % str(label)
			)

