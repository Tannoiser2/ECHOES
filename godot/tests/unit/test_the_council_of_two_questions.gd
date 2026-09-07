extends "res://tests/test_case.gd"
## **Il Consiglio a due domande** (D-467, giro 3 in D-470).
##
## La carta girata offre due domande in contrasto; chi propone ne prende una e
## posa un beneficio gratis, gli altri prendono posizione e posano sulle
## caselle marcate della loro parte, si rilancia, il prezzo si conta per
## parte, e si vota senza dado contro il mucchio: A, B, o nessuna. Queste prove
## giocano il tavolo spedito (CHR_00 lo dichiara) con un decisore **scritto**,
## cosi' ogni esito e' fabbricato e non cercato; e tengono la Chronicle di
## prova sul giro vecchio, perche' non lo dichiara.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")


## Un decisore che fa quello che gli si dice: chi sta con B, quante carte
## impegna ognuno. Non pensa, esegue.
class Scripted extends RefCounted:
	var with_b: Array = []
	var cards_for: Dictionary = {}

	func choose_question(context: Dictionary, _options: Array, _session: RefCounted) -> String:
		return str(context.get("question_id", ""))

	func choose_box(_entity_id: String, _context: Dictionary, menu: Array, _side: String, _session: RefCounted) -> String:
		return "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])

	func choose_side(entity_id: String, _context: Dictionary, offer: Dictionary, _session: RefCounted) -> Dictionary:
		var side: String = "B" if with_b.has(entity_id) else "A"
		if (offer.get(side, []) as Array).is_empty():
			side = "A" if side == "B" else "B"
		var menu: Array = offer.get(side, []) as Array
		return {"side": side, "voice_id": "" if menu.is_empty() else str((menu[0] as Dictionary)["id"])}

	func choose_raise(_entity_id: String, _context: Dictionary, _menu: Array, _session: RefCounted) -> String:
		return ""

	func choose_commit(entity_id: String, _context: Dictionary, limit: int, session: RefCounted) -> Array:
		var wanted: int = mini(int(cards_for.get(entity_id, 0)), limit)
		return (session.service.hand(entity_id) as Array).slice(0, wanted)

	func choose_recovery(_context: Dictionary, _session: RefCounted) -> Dictionary:
		return {}


var _mine: RefCounted


func _table() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 7000)
	assert_true(_mine.setup("CHR_00", seats, 7000), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	return _mine


func after_each() -> void:
	super.after_each()
	if _mine != null:
		_mine.dispose()
		_mine = null


## La prima domanda in gioco che un Consiglio sa aprire.
func _openable(live: RefCounted) -> String:
	for tension_id in live.world["tensions"]:
		if live.confluence.can_open(str(tension_id)):
			return str(tension_id)
	return ""


func _heat(live: RefCounted, tension_id: String, value: int) -> void:
	var theme_id: String = str((live.data.tensions[tension_id] as Dictionary).get("theme", ""))
	(live.world["theme_heat"] as Dictionary)[theme_id] = value


func test_the_shipped_table_declares_two_questions_and_the_test_one_does_not() -> void:
	var live: RefCounted = _table()
	assert_true(live.confluence.two_questions(), "CHR_00 gioca a due domande")
	new_session()
	assert_false(session.confluence.two_questions(), "la Chronicle di prova gioca il giro di D-280")
	session.confluence.open("TEN_FAMINE", {"kind": "THRESHOLD"})
	assert_false(session.confluence.sides_open(), "e aprendo non ha due parti")


func test_opening_makes_two_sides_and_reads_the_pile() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	assert_ne(tension_id, "", "una domanda si apre")
	_heat(live, tension_id, 3)
	var context: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	assert_true(live.confluence.sides_open(), "con due parti")
	assert_eq(live.confluence.side_question("A"), str(context["question_id"]), "la A e' la domanda presa")
	var ids: Array = []
	for entry in (live.data.confluence_template_for(tension_id)["questions"] as Array):
		ids.append(str((entry as Dictionary)["id"]))
	assert_true(ids.has(live.confluence.side_question("B")), "la B e' l'altra della carta")
	assert_ne(live.confluence.side_question("B"), live.confluence.side_question("A"), "e non la stessa")
	assert_eq(live.confluence.pile(), 3, "il mucchio e' il valore rivelato del Tema")
	assert_eq(live.confluence.side_of(str(context["proponent"])), "A", "chi propone sta con A")
	live.confluence.current = {}


func test_a_pedina_falls_only_on_a_box_marked_for_its_side() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	var context: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var b_question: String = live.confluence.side_question("B")
	for entry in live.confluence.box_menu("B"):
		assert_true(
			((entry as Dictionary).get("for", []) as Array).has(b_question),
			"«%s» serve la domanda B" % str((entry as Dictionary)["id"])
		)
	var other: String = ""
	for entity_id in live.confluence.stance_order():
		other = str(entity_id)
		break
	assert_true(live.confluence.join_side(other, "B"), "un seggio prende la B")
	assert_eq(live.confluence.side_leader("B"), other, "ed e' lui che la guida")
	assert_eq(live.confluence.stance_of(other), "OPPOSE", "per il tavolo si oppone")
	assert_false(live.confluence.place_box(other, "NON_ESISTE"), "una casella che non c'e' si rifiuta")
	var a_only: String = ""
	for entry in live.confluence.box_menu("A"):
		if not ((entry as Dictionary).get("for", []) as Array).has(b_question):
			a_only = str((entry as Dictionary)["id"])
			break
	if a_only != "":
		assert_false(live.confluence.place_box(other, a_only), "e una casella della sola A non si posa per B")
	var menu: Array = live.confluence.box_menu("B")
	if not menu.is_empty():
		var first: String = str((menu[0] as Dictionary)["id"])
		assert_true(live.confluence.place_box(other, first), "una casella della B si posa")
		for entry in live.confluence.box_menu("B"):
			assert_ne(str((entry as Dictionary)["id"]), first, "e non e' piu' libera")
	live.confluence.current = {}


func test_the_price_is_settled_per_side_at_the_vote() -> void:
	var live: RefCounted = _table()
	var context: Dictionary = live.confluence.open(_openable(live), {"kind": "THRESHOLD"})
	var part: Dictionary = (live.confluence.current["sides"] as Dictionary)["A"] as Dictionary
	part["boxes"] = [
		{"by": "x", "voice": "B_1", "list": "benefits"},
		{"by": "x", "voice": "B_2", "list": "benefits"},
		{"by": "x", "voice": "C_1", "list": "costs"},
		{"by": "x", "voice": "B_3", "list": "benefits"},
	]
	var removed: Array = live.confluence.settle_prices()
	assert_eq(removed, ["B_3"], "un beneficio in piu' dei costi si tiene, il resto si toglie dall'ultimo")
	assert_eq(live.confluence.side_boxes("A", "benefits"), ["B_1", "B_2"], "restano due benefici")
	assert_eq(live.confluence.side_boxes("A", "costs"), ["C_1"], "e il costo")
	assert_false(context.is_empty(), "il Consiglio era aperto")
	live.confluence.current = {}


func test_three_outcomes_against_the_pile() -> void:
	assert_eq(ConfluenceResolution.two_sides_outcome(5, 3, 4), ConfluenceResolution.SUCCESS, "A batte B e il mucchio")
	assert_eq(ConfluenceResolution.two_sides_outcome(9, 3, 4), ConfluenceResolution.DECISIVE, "di molto")
	assert_eq(ConfluenceResolution.two_sides_outcome(4, 3, 4), ConfluenceResolution.SUCCESS_WITH_COST, "di misura")
	assert_eq(ConfluenceResolution.two_sides_outcome(3, 5, 4), ConfluenceResolution.COUNTER, "B batte A e il mucchio")
	assert_eq(ConfluenceResolution.two_sides_outcome(4, 4, 2), ConfluenceResolution.FAILURE, "a parita' non passa nessuna")
	assert_eq(ConfluenceResolution.two_sides_outcome(5, 3, 6), ConfluenceResolution.FAILURE, "e nemmeno sotto il mucchio")
	assert_eq(ConfluenceResolution.winner_of(ConfluenceResolution.COUNTER), "B", "vince la B")
	assert_false(ConfluenceResolution.is_success(ConfluenceResolution.COUNTER), "che per chi propone non e' un successo")


func test_when_b_wins_its_base_outcome_applies() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	_heat(live, tension_id, 1)
	var decider: Scripted = Scripted.new()
	# Chi propone lo dice il Consiglio aperto, e si richiude prima di giocarlo.
	var peek: Dictionary = live.confluence.open(tension_id, {"kind": "THRESHOLD"})
	var proponent: String = str(peek["proponent"])
	live.confluence.current = {}
	for entity_id in live.world["entities"]:
		if str(entity_id) != proponent:
			decider.with_b.append(str(entity_id))
			decider.cards_for[str(entity_id)] = 2
	var result: Dictionary = await live.chronicle.run_confluence(tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider)
	assert_false(result.is_empty(), "il Consiglio si e' risolto")
	assert_eq(str(result["outcome"]), ConfluenceResolution.COUNTER, "tre seggi con carte contro nessuna: vince la B (%s)" % str(result))
	assert_eq(str(result["winner"]), "B", "e lo dice")
	var b_question: String = str(result["winning_question_id"])
	var base: Array = []
	for entry in (live.data.confluence_template_for(tension_id)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == b_question:
			base = (entry as Dictionary)["base"] as Array
	assert_true(not base.is_empty(), "la B ha un esito di base")
	for consequence_id in base:
		assert_true((result["consequence_ids"] as Array).has(str(consequence_id)), "e si applica: %s" % str(consequence_id))
	assert_eq(int(result["world_factor"]), 0, "senza dado")


func test_when_nobody_reaches_the_pile_nothing_passes() -> void:
	var live: RefCounted = _table()
	var tension_id: String = _openable(live)
	_heat(live, tension_id, 99)
	var decider: Scripted = Scripted.new()
	for entity_id in live.world["entities"]:
		decider.cards_for[str(entity_id)] = 1
	var result: Dictionary = await live.chronicle.run_confluence(tension_id, {"kind": "THRESHOLD", "entity_id": ""}, decider)
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "nessuna parte arriva a 99")
	assert_eq(str(result["winner"]), "", "e non vince nessuno")
	assert_eq(int(result["pile"]), 99, "il mucchio e' scritto nel risultato")
