extends "res://tests/test_case.gd"
## **Due copie della stessa carta sono due carte** (ISSUES 136, punto 7).
##
## In scatola una carta ha piu' di una copia — `deck_copies`, 132 copie su 48
## carte diverse — quindi una mano con due «Giuramento» e' normale, e misurata:
## su 32 mani di fine anno, **sette** ne avevano una doppia.
##
## I menu contavano i **nomi** e sbagliavano due volte: stampavano la stessa
## riga due volte (una scelta che lo schermo non sa distinguere), e scelta la
## prima **la seconda copia spariva** — quindi non si poteva ne' coprire ne'
## scartare ne' impegnare, mentre `ConfluenceController.commit` le conta come
## multinsieme da sempre. La regola c'era; il menu la contraddiceva.
##
## **La mano di queste prove e' fabbricata.** Cercare fra i dati spediti una
## mano con due copie voleva dire misurare la pesca invece del menu, e il giorno
## in cui la pesca cambia la prova smetterebbe di provare in silenzio.

const HandMenu := preload("res://scripts/seat/hand_menu.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")
const Effect := preload("res://scripts/core/effect.gd")

var _mine: RefCounted


## Un io che guarda e prende sempre la prima voce: quello che ci interessa e'
## **cosa gli e' stato mostrato**, non cosa avrebbe scelto una persona.
class Registro extends RefCounted:
	var menus: Array = []
	var detto: Array = []
	## Il menu e' in ordine di forza, non di mano: per provare le copie bisogna
	## dire **quale** voce si vuole, non «la prima».
	var prefer: String = ""

	func say(text: String) -> void:
		detto.append(text)

	func choose(prompt: String, labels: Array, subjects: Array = []) -> int:
		menus.append({"prompt": prompt, "labels": labels, "subjects": subjects})
		if prefer != "":
			for i in range(labels.size()):
				if str(labels[i]).contains(prefer):
					return i
		return 0


func _table() -> RefCounted:
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
	return _mine


func after_each() -> void:
	super.after_each()
	if _mine != null:
		_mine.dispose()
		_mine = null


## La mano che le prove vogliono: due copie di una carta, e una terza diversa.
func _a_hand_with_two_copies(live: RefCounted, seat: String) -> Array:
	var ids: Array = live.data.assets.keys()
	ids.sort()
	var twice: String = str(ids[0])
	var once: String = str(ids[1])
	var hand: Array = (live.world["entities"][seat] as Dictionary)["hand"] as Array
	hand.clear()
	hand.append_array([twice, twice, once])
	return [twice, once]


func _seat_and_registry(live: RefCounted, seat: String, prefer: String = "") -> Array:
	var registro: Registro = Registro.new()
	registro.prefer = prefer
	var table: RefCounted = SeatDecider.new([seat], live.log)
	table.io = registro
	return [table, registro]


## La voce che parla di questa carta, cercata per titolo: il menu e' ordinato
## per forza, e dare per scontato un posto nella lista proverebbe l'ordine.
func _entry_about(labels: Array, title: String) -> String:
	for label in labels:
		if str(label).contains(title):
			return str(label)
	return ""


func _title(live: RefCounted, asset_id: String) -> String:
	return str((live.data.assets[asset_id] as Dictionary)["title"])


## **Una voce sola, e dice quante ne hai.** Prima erano due righe identiche.
func test_two_copies_are_one_button_that_says_how_many() -> void:
	var live: RefCounted = _table()
	var seat: String = str((live.world["turn_order"] as Array)[0])
	var cards: Array = _a_hand_with_two_copies(live, seat)
	var pair: Array = _seat_and_registry(live, seat)
	await (pair[0] as RefCounted).choose_cover(seat, 1, live)
	var menus: Array = (pair[1] as Registro).menus
	assert_eq(menus.size(), 1, "una domanda sola per una carta da coprire")
	var labels: Array = (menus[0] as Dictionary)["labels"] as Array
	assert_eq(labels.size(), 2, "due voci per tre carte: le copie sono accorpate")
	var doppia: String = _entry_about(labels, _title(live, str(cards[0])))
	assert_true(doppia != "", "la carta che hai in due copie ha la sua voce")
	assert_true(doppia.contains("(ne hai 2)"), "e dice quante ne hai: %s" % doppia)
	var singola: String = _entry_about(labels, _title(live, str(cards[1])))
	assert_false(
		singola.contains("(ne hai"),
		"la carta che hai in una copia non porta il conto: sarebbe rumore"
	)


## **E sono due carte da coprire.** Prima la seconda copia spariva dal menu.
func test_two_copies_are_two_cards_to_cover() -> void:
	var live: RefCounted = _table()
	var seat: String = str((live.world["turn_order"] as Array)[0])
	var cards: Array = _a_hand_with_two_copies(live, seat)
	var pair: Array = _seat_and_registry(live, seat, _title(live, str(cards[0])))
	var chosen: Array = await (pair[0] as RefCounted).choose_cover(seat, 2, live)
	assert_eq(chosen.size(), 2, "due carte scelte")
	assert_eq(str(chosen[0]), str(cards[0]), "la prima e' la carta doppia")
	assert_eq(
		str(chosen[1]), str(cards[0]),
		"e la seconda e' la sua altra copia, non un'altra carta"
	)
	# E il mondo le copre tutt'e due: l'Effetto prende la prima occorrenza.
	for asset_id in chosen:
		live.applier.apply(Effect.make(
			"COVER_ASSET", "entity", seat, {"asset_id": str(asset_id)},
			Effect.source("system", "ROUND_ENDS", seat, 1, 1, 0)
		))
	assert_eq(live.service.covered_size(seat), 2, "due coperte davanti a te")
	assert_eq(
		live.service.hand(seat).size(), 1,
		"e in mano resta solo la terza carta"
	)


## **La domanda non cambia sotto le dita.** Era «copre 1 di 3 per il Consiglio —
## 1 di base · +1 per 1 Pietra che tieni», poi «copre 2 di 3...»: un cartello
## nuovo da rileggere a ogni carta. Il numero e le ragioni si dicono una volta.
func test_the_question_does_not_change_under_your_fingers() -> void:
	var live: RefCounted = _table()
	var seat: String = str((live.world["turn_order"] as Array)[0])
	_a_hand_with_two_copies(live, seat)
	var pair: Array = _seat_and_registry(live, seat)
	await (pair[0] as RefCounted).choose_cover(seat, 2, live)
	var menus: Array = (pair[1] as Registro).menus
	assert_eq(menus.size(), 2, "due domande per due carte")
	assert_eq(
		str((menus[0] as Dictionary)["prompt"]),
		str((menus[1] as Dictionary)["prompt"]),
		"e sono la stessa frase, parola per parola"
	)
	assert_true(
		str((menus[0] as Dictionary)["prompt"]).contains("quale carta copri?"),
		"la domanda dice cosa chiede: %s" % str((menus[0] as Dictionary)["prompt"])
	)
	# Il conto e le ragioni ci sono, ma li dice il racconto, una volta sola.
	var detto: String = " / ".join(PackedStringArray((pair[1] as Registro).detto))
	assert_true(detto.contains("2 carte"), "quante ne copre si dice: %s" % detto)
	assert_true(detto.contains("di base"), "e da dove viene il numero: %s" % detto)


## Anche il menu degli scarti accorpa, e anche li' due copie sono due carte.
func test_the_discard_menu_folds_too() -> void:
	var live: RefCounted = _table()
	var seat: String = str((live.world["turn_order"] as Array)[0])
	var cards: Array = _a_hand_with_two_copies(live, seat)
	var pair: Array = _seat_and_registry(live, seat, _title(live, str(cards[0])))
	var chosen: Array = await (pair[0] as RefCounted).choose_discards(seat, 2, live)
	var labels: Array = ((pair[1] as Registro).menus[0] as Dictionary)["labels"] as Array
	assert_eq(
		labels.size(), 3,
		"due carte piu' «Tengo il resto in mano», per tre carte in mano"
	)
	var doppia: String = _entry_about(labels, _title(live, str(cards[0])))
	assert_true(doppia.contains("(ne hai 2)"), "e il conto c'e': %s" % doppia)
	assert_eq(chosen.size(), 2, "e si buttano tutt'e due le copie")
	assert_eq(str(chosen[0]), str(chosen[1]), "che sono la stessa carta")


## **Il filtro del motore conta le copie, non i nomi.** Era `out.has(id)`, e
## buttava via la seconda copia in silenzio: il decisore chiedeva due coperte e
## ne otteneva una, senza che niente lo dicesse.
func test_the_engine_counts_copies_not_names() -> void:
	var pile: Array = ["AST_A", "AST_A", "AST_B"]
	assert_eq(
		HandMenu.kept(["AST_A", "AST_A"], pile, 2).size(), 2,
		"due copie chieste e due tenute"
	)
	assert_eq(
		HandMenu.kept(["AST_A", "AST_A", "AST_A"], pile, 3).size(), 2,
		"tre chieste, ma di copie ce ne sono due"
	)
	assert_eq(
		HandMenu.kept(["AST_Z"], pile, 1).size(), 0,
		"una carta che non hai non si tiene"
	)
	assert_eq(
		HandMenu.kept(["AST_A", "AST_B"], pile, 1).size(), 1,
		"e il tetto resta un tetto"
	)


## La regola del mucchio, guardata da sola: togliere una copia non toglie
## l'altra, e l'ordine del mucchio resta quello.
func test_the_pile_is_a_pile_and_not_a_set() -> void:
	var pile: Array = ["AST_A", "AST_B", "AST_A", "AST_C"]
	var left: Array = HandMenu.left_after(pile, ["AST_A"])
	assert_eq(left.size(), 3, "una copia via, tre carte")
	assert_true(left.has("AST_A"), "e l'altra copia e' ancora li'")
	var folded: Array = HandMenu.folded(pile)
	assert_eq(folded.size(), 3, "tre voci per quattro carte")
	assert_eq(str((folded[0] as Dictionary)["asset"]), "AST_A", "l'ordine del mucchio resta")
	assert_eq(int((folded[0] as Dictionary)["copies"]), 2, "con le sue due copie")
	assert_eq(HandMenu.copies_note(1), "", "una copia non si annuncia")
