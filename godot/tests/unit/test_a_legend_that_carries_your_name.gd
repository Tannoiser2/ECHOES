extends "res://tests/test_case.gd"
## **L'Eredita'** (D-385 — ISSUES 84, scelta del committente):
## *«a fine saga, +3 per ogni leggenda che porta il tuo nome»*.
##
## Una leggenda porta il tuo nome quando racconta uno dei segni che la tua casa
## aveva dichiarato di voler lasciare — i `wants` del profilo strategico. Le
## leggende le fabbrica il tempo al salto d'era (D-075), non i giocatori.
##
## **La trappola di casa, presa di petto**: una prova che chiede *«quante
## leggende?»* a un mondo che non ne ha darebbe zero e passerebbe sempre, anche
## col conto rotto. Quindi il primo caso e' quello che **deve** dare non-zero, e
## il mondo se lo fabbrica la prova.

const ChronicleController := preload("res://scripts/chronicle/chronicle_controller.gd")


func before_each() -> void:
	new_session()


## La casa e i due segni che aveva dichiarato di voler lasciare.
func _a_house_with_wants() -> Array:
	var ids: Array = (session.data.entity_profiles as Dictionary).keys()
	ids.sort()
	for entity_id in ids:
		var wants: Array = (
			(session.data.entity_profiles[str(entity_id)] as Dictionary).get("wants", [])
		)
		if wants.size() >= 2:
			return [str(entity_id), str((wants[0] as Dictionary)["tag"]),
				str((wants[1] as Dictionary)["tag"])]
	return []


## Il caso che deve dare non-zero.
func test_two_legends_are_worth_six() -> void:
	var found: Array = _a_house_with_wants()
	assert_false(found.is_empty(), "c'e' una casa con almeno due desideri scritti")
	var world: Dictionary = {"global_tags": [
		"legend:%s" % str(found[1]), "legend:%s" % str(found[2]),
	]}
	assert_eq(
		ChronicleController.legacy_points(world, session.data, str(found[0])),
		2 * ChronicleController.LEGACY_PER_LEGEND,
		"due leggende col tuo nome valgono due volte il premio"
	)
	assert_eq(
		ChronicleController.legends_named_after(world, session.data, str(found[0])).size(),
		2, "e si sanno dire per nome"
	)


## **Il fatto non e' la leggenda.** Il segno ancora vero sul tavolo non paga:
## paga solo quello di cui il mondo racconta ancora. E' la riga che tiene
## l'Eredita' lontana dal premiare la durata (D-299).
func test_a_fact_still_true_pays_nothing() -> void:
	var found: Array = _a_house_with_wants()
	assert_false(found.is_empty(), "c'e' una casa con almeno due desideri scritti")
	var world: Dictionary = {"global_tags": [str(found[1]), str(found[2])]}
	assert_eq(
		ChronicleController.legacy_points(world, session.data, str(found[0])), 0,
		"un fatto ancora vero non e' una leggenda"
	)


## E la leggenda di un altro non paga te.
func test_someone_elses_legend_pays_nothing() -> void:
	var ids: Array = (session.data.entity_profiles as Dictionary).keys()
	ids.sort()
	var mine: String = ""
	var theirs: String = ""
	var their_tag: String = ""
	for entity_id in ids:
		var wants: Array = (
			(session.data.entity_profiles[str(entity_id)] as Dictionary).get("wants", [])
		)
		if wants.is_empty():
			continue
		if mine == "":
			mine = str(entity_id)
			continue
		var mine_tags: Array = []
		for voice in ((session.data.entity_profiles[mine] as Dictionary)["wants"] as Array):
			mine_tags.append(str((voice as Dictionary)["tag"]))
		for voice in wants:
			if not mine_tags.has(str((voice as Dictionary)["tag"])):
				theirs = str(entity_id)
				their_tag = str((voice as Dictionary)["tag"])
				break
		if theirs != "":
			break
	assert_false(theirs.is_empty(), "due case vogliono lasciare cose diverse")
	var world: Dictionary = {"global_tags": ["legend:%s" % their_tag]}
	assert_eq(
		ChronicleController.legacy_points(world, session.data, theirs),
		ChronicleController.LEGACY_PER_LEGEND, "la sua leggenda la paga a lui"
	)
	assert_eq(
		ChronicleController.legacy_points(world, session.data, mine), 0,
		"e non la paga a me"
	)
