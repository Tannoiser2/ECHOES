extends "res://tests/test_case.gd"
## **Un'Occasione non si butta** (D-285, passo 4 del brief del Punto Zero).
##
## Misurato: si passava l'**82% dei turni**, e due terzi di quei passa erano
## «mosse legali, nessuna che gli servisse» — con sette carte in mano e quindici
## mosse legali in media. Non era un problema di regole ne' di mazzo: era che il
## cervello, quando nessuna delle sue intenzioni scattava, tornava indietro
## senza nemmeno guardare cosa la mano permetteva.
##
## Due difetti, uno dentro l'altro. Il ripiego non veniva **mai provato**
## (`_as_card_play` usciva alla prima riga quando l'intenzione era PASSA); e la
## lista delle mosse possibili guardava **un solo verbo per carta e un solo
## bersaglio per verbo**, quindi era quasi sempre vuota anche quando veniva
## chiesta.
##
## La riserva resta: una carta calata e' una carta che al Consiglio non vota, e
## il mondo ricorda solo i Consigli in cui qualcuno ha messo peso.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


## La partita della scatola, dove le carte sono l'unica moneta.
var _mine: RefCounted


func _cards_table() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(_mine.setup("CHR_00", seats, 4242), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	_mine.world["act"] = 1
	_mine.world["round"] = 1
	_mine.world["phase"] = "ACTIONS"
	return _mine


## **Con la mano piena e il tavolo pieno di mosse, non si passa.**
func test_a_full_hand_does_not_pass() -> void:
	var live: RefCounted = _cards_table()
	var brain: RefCounted = PolicyDecider.new(null)
	var silent: Array = []
	for entity_id in live.world["turn_order"]:
		var seat: String = str(entity_id)
		if live.service.hand_size(seat) < 5:
			continue
		var chosen: Dictionary = brain.choose_action(seat, 0, live)
		if str(chosen.get("template", "PASS")) == "PASS":
			silent.append("%s (mano %d)" % [seat, live.service.hand_size(seat)])
	assert_true(
		silent.is_empty(),
		"nessun seggio a mano piena resta fermo: %s" % [silent]
	)


## **Ma la riserva si tiene.** La regola del ripiego, provata da sola: sopra la
## soglia che il Consiglio puo' accettare si gioca, a quella soglia si tiene. La
## mano non e' solo carburante, e' anche voce — e il mondo ricorda solo i
## Consigli in cui qualcuno ha messo peso.
func test_the_reserve_for_the_council_is_kept() -> void:
	var live: RefCounted = _cards_table()
	var brain: RefCounted = PolicyDecider.new(null)
	var seat: String = str(live.world["turn_order"][0])
	var hand: Array = live.world["entities"][seat]["hand"] as Array
	var kept: Array = hand.duplicate()
	var reserve: int = int(
		(live.data.chronicles["CHR_00"] as Dictionary).get("max_commit_assets", 3)
	) + 1
	while hand.size() < reserve + 2:
		hand.append(str(kept[hand.size() % kept.size()]))
	assert_ne(
		str(brain._rather_than_nothing(seat, live).get("template", "PASS")), "PASS",
		"con la mano sopra la riserva si gioca (mano %d, riserva %d)" % [hand.size(), reserve]
	)
	while hand.size() > reserve:
		hand.pop_back()
	assert_eq(
		str(brain._rather_than_nothing(seat, live).get("template", "PASS")), "PASS",
		"e alla riserva si tiene (mano %d)" % hand.size()
	)
	hand.clear()
	hand.append_array(kept)


## **La lista delle mosse possibili guarda tutte le facce e tutti i bersagli.**
## Prima ne guardava una e uno, ed era vuota anche con la mano piena.
func test_the_hand_lists_every_face_and_every_target() -> void:
	var live: RefCounted = _cards_table()
	var brain: RefCounted = PolicyDecider.new(null)
	var seat: String = str(live.world["turn_order"][0])
	var plays: Array = brain.hand_plays(seat, live)
	assert_true(plays.size() > 0, "la mano ha delle mosse: %d" % plays.size())
	var cards: Dictionary = {}
	var faces: Dictionary = {}
	for play in plays:
		var params: Dictionary = (play as Dictionary)["params"] as Dictionary
		cards[str(params.get("asset_id", ""))] = true
		faces["%s|%d" % [
			str(params.get("asset_id", "")), int(params.get("face_action", -1)),
		]] = true
	assert_true(cards.size() > 1, "e parlano piu' carte: %d" % cards.size())
	assert_true(
		faces.size() > cards.size(),
		"e qualche carta offre piu' di una meta' o piu' di un bersaglio: %d facce su %d carte"
		% [faces.size(), cards.size()]
	)


## **Due mosse non si propongono mai**, perche' sono danni che il cervello
## farebbe a se stesso per noia: spingere una domanda dalla parte sbagliata, e
## rompere un patto.
func test_the_two_moves_that_hurt_are_never_offered() -> void:
	var live: RefCounted = _cards_table()
	var brain: RefCounted = PolicyDecider.new(null)
	for entity_id in live.world["turn_order"]:
		var seat: String = str(entity_id)
		var goals: Dictionary = brain._tension_goals(seat, live)
		for play in brain.hand_plays(seat, live):
			var params: Dictionary = (play as Dictionary)["params"] as Dictionary
			if str(params.get("direction", "")) != "":
				assert_ne(
					str(params.get("direction", "")), "DOWN",
					"nessun patto rotto per noia (%s)" % seat
				)
			var tension_id: String = str(params.get("tension_id", ""))
			if tension_id == "" or not goals.has(tension_id):
				continue
			var card: Dictionary = live.data.assets[
				str(params["asset_id"])
			] as Dictionary
			var fixed: Dictionary = (
				(card.get("card_action", {}) as Dictionary).get("params", {}) as Dictionary
			)
			if not fixed.has("delta"):
				continue
			assert_eq(
				int(fixed["delta"]), int(goals[tension_id]),
				"e nessuna domanda spinta dalla parte sbagliata (%s, %s)" % [seat, tension_id]
			)
