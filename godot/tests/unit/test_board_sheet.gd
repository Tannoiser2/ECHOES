extends "res://tests/test_case.gd"
## Il tabellone in SVG per la vetrina (D-145): la mappa disegnata dagli stessi
## piani del canvas. Non si prova che sia *bello* — quello lo guarda un occhio —
## ma che ci sia tutto quello che il tavolo deve vedere, e niente che non gli
## spetti.

const BoardSheet := preload("res://scripts/core/board_sheet.gd")
const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return Effect.source("test", "TEST", "", 1, 1, 0)


func test_every_region_is_on_the_board_with_its_name() -> void:
	var svg: String = BoardSheet.board_svg(session)
	assert_true(svg.begins_with("<svg"), "e' un SVG")
	for region_id in session.world["regions"]:
		var name: String = str(session.data.regions[str(region_id)]["name"])
		assert_true(svg.contains(name), "«%s» sta sul tabellone" % name)


## Una pedina per presenza: si contano come i pezzi veri (D-138). Il conto si
## fa sulle ombre, che sono una per pezzo — i tratti di una sagoma sono tanti.
func test_a_pawn_appears_for_every_presence() -> void:
	var before: int = BoardSheet.board_svg(session).count("<ellipse")
	var seat: String = str(session.world["turn_order"][0])
	var region: String = str(session.world["regions"].keys()[0])
	session.applier.apply(Effect.make(
		"ADD_PRESENCE", "entity", seat, {"region_id": region}, _source()
	))
	var after: int = BoardSheet.board_svg(session).count("<ellipse")
	assert_eq(after, before + 1, "una presenza in piu', una pedina in piu'")


## Il colore dice la casa, e viene dall'ordine di turno come sul canvas (D-050):
## due seggi diversi non possono uscire dello stesso colore.
func test_the_seats_do_not_share_a_colour() -> void:
	var seen: Dictionary = {}
	for entity_id in session.world["turn_order"]:
		var colour: String = BoardSheet._seat_colour(session.world, str(entity_id))
		assert_false(seen.has(colour), "«%s» ha un colore suo" % str(entity_id))
		seen[colour] = true


## E il tabellone non sa niente delle mani: e' pubblico per costruzione, e la
## prova sta accanto a quella della vetrina (D-144).
func test_the_board_carries_no_hand() -> void:
	var svg: String = BoardSheet.board_svg(session)
	for entity_id in session.world["turn_order"]:
		for asset_id in session.service.hand(str(entity_id)):
			var title: String = str(session.data.assets[str(asset_id)]["title"])
			assert_false(
				svg.contains(title), "«%s» e' in mano, non sul tabellone" % title
			)
