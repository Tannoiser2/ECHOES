extends "res://tests/test_case.gd"
## **La porta dell'Eco** (§12.4, D-488): quali Consigli il mondo si ricorda.
##
## Fino al 0.1.457 questa porta non aveva nessuna prova, e non e' un dettaglio:
## era una porta con **un buco e un cardine rotto**, e la suite intera passava
## verde lo stesso.
##
## Il buco: la controdomanda che vince — `COUNTER`, un Consiglio su tre —
## cadeva fuori da tutti e tre i rami, perche' non e' un successo del
## proponente e non e' un Fallimento. Misurato su cento anni: **zero Echi su
## 166 Consigli decisi dalla B**.
##
## Il cardine: «le due parti hanno speso tanto» chiedeva 6, scritto quando i
## totali erano solo le carte impegnate. Con le pedine (D-471) A+B fa 12,7 di
## media, e quella porta lasciava passare 273 dei 274 Consigli decisi da A.

const EchoRecorder := preload("res://scripts/chronicle/echo_recorder.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")


## `should_record` non tocca il mondo: guarda l'esito e i due totali. Il
## registro serve solo a `record`, che qui non si chiama.
func _door() -> RefCounted:
	return EchoRecorder.new({}, null, null, null)


func _asks(a: int, b: int, pile: int) -> Dictionary:
	return {
		"outcome": ConfluenceResolution.two_sides_outcome(a, b, pile),
		"support_total": a,
		"oppose_total": b,
	}


## **La decisione netta si ricorda, da qualunque parte del tavolo venga.**
## E' la riga che prima non c'era: la stessa distanza, con i numeri scambiati,
## dava un Eco a A e niente a B.
func test_a_wide_win_is_remembered_on_either_side() -> void:
	var door: RefCounted = _door()
	assert_eq(str(_asks(11, 6, 6)["outcome"]), ConfluenceResolution.DECISIVE, "A vince di cinque")
	assert_true(door.should_record(_asks(11, 6, 6)), "e il mondo se lo ricorda")
	assert_eq(str(_asks(6, 11, 6)["outcome"]), ConfluenceResolution.COUNTER, "gli stessi numeri scambiati")
	assert_true(door.should_record(_asks(6, 11, 6)), "e adesso se lo ricorda uguale")


## **La decisione di misura non lascia storia**, e nemmeno questa guarda in
## faccia chi ha vinto: passare per uno e' passare per uno.
func test_a_narrow_win_leaves_nothing() -> void:
	var door: RefCounted = _door()
	assert_eq(str(_asks(12, 11, 6)["outcome"]), ConfluenceResolution.SUCCESS_WITH_COST, "A passa di uno")
	assert_false(door.should_record(_asks(12, 11, 6)), "il tavolo lo dimentica")
	assert_false(door.should_record(_asks(11, 12, 6)), "e lo dimentica anche dall'altra parte")


## **La fascia di mezzo passa solo se il tavolo ci ha messo davvero tutto.**
## Dodici e' la mediana misurata di A+B: sotto, il Consiglio e' stato una
## discussione fra due; sopra, ci si e' seduto tutto il tavolo.
func test_the_clear_band_needs_the_whole_table() -> void:
	var door: RefCounted = _door()
	assert_eq(str(_asks(7, 4, 4)["outcome"]), ConfluenceResolution.SUCCESS, "fascia di mezzo, tavolo leggero")
	assert_false(door.should_record(_asks(7, 4, 4)), "undici in due: non e' storia")
	assert_true(door.should_record(_asks(8, 4, 4)), "dodici si'")
	assert_eq(str(_asks(4, 8, 4)["outcome"]), ConfluenceResolution.COUNTER, "e vale per la controdomanda")
	assert_true(door.should_record(_asks(4, 8, 4)), "che di dodici ne ha mossi gli stessi")


## **Una sconfitta costata cara resta storia**, e questa soglia non si e'
## mossa: e' un fronte solo, e sei per un fronte e' ancora tanto.
func test_an_expensive_defeat_is_still_history() -> void:
	var door: RefCounted = _door()
	assert_eq(str(_asks(3, 6, 9)["outcome"]), ConfluenceResolution.FAILURE, "nessuna arriva al mucchio")
	assert_true(door.should_record(_asks(3, 6, 9)), "ma l'opposizione ha speso sei")
	assert_false(door.should_record(_asks(3, 5, 9)), "con cinque, no")
