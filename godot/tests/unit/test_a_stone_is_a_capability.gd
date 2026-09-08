extends "res://tests/test_case.gd"
## **Una Pietra e' una capacita', non un +1**
## ([D-484](DECISIONS.md#d-484)).
##
## Domanda del committente ([ISSUES 132](../../docs/ISSUES.md#132), punto 3):
## *«Le Pietre diventano capacita'? Il telaio (`ACTION_DISCOUNT`,
## `ACTION_MODIFIER`, `ACTION_GRANT`) c'e' e ha 4 regole in tutto.»*
##
## Il telaio c'era e non si poteva usare: `ACTION_DISCOUNT` lo leggeva **solo**
## RIVENDICARE, e le altre due strade che costano una carta — INFLUENZARE senza
## presenza e FORGIARE in su (D-188) — non lo guardavano nemmeno. Una regola di
## sconto scritta su di loro sarebbe stata inchiostro: e infatti in tutta la
## scatola ce n'era **una**.

const Effect := preload("res://scripts/core/effect.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")


func before_each() -> void:
	new_session()


func _source() -> Dictionary:
	return Effect.source("system", "TEST", "", 1, 1, 0)


## La Regione dove il seggio ha una presenza, con la Pietra chiesta sopra.
func _a_place_of_mine(entity_id: String, tag: String) -> String:
	var region_id: String = ""
	for id in session.world["regions"]:
		var presence: Array = (session.world["regions"][str(id)] as Dictionary).get(
			"presence", []
		) as Array
		if presence.has(entity_id):
			region_id = str(id)
			break
	if region_id == "":
		region_id = str((session.world["regions"] as Dictionary).keys()[0])
		session.applier.apply(Effect.make(
			"ADD_PRESENCE", "entity", entity_id, {"region_id": region_id}, _source()
		))
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).append(tag)
	return region_id


## **Lo sconto vale per i tre verbi che pagano una carta**, non piu' per uno
## solo. Le tre regole sono dati: Archivio su INFLUENZARE, Granaio su FORGIARE,
## Dogana su RIVENDICARE.
func test_the_discount_answers_for_every_verb_that_costs_a_card() -> void:
	var seat: String = str(session.world["turn_order"][0])
	for pair in [["structure:archive", "INFLUENCE"], ["structure:granary", "FORGE"],
			["structure:tollgate", "CLAIM"]]:
		new_session()
		seat = str(session.world["turn_order"][0])
		var verb: String = str((pair as Array)[1])
		assert_eq(
			TagRules.action_discount(session.data, session.world, seat, verb), "",
			"senza la Pietra, «%s» si paga" % verb
		)
		_a_place_of_mine(seat, str((pair as Array)[0]))
		assert_ne(
			TagRules.action_discount(session.data, session.world, seat, verb), "",
			"con «%s» in mano, «%s» non si paga" % [str((pair as Array)[0]), verb]
		)


## **E la Pietra alzata di grado da' qualcosa che il primo grado non da'**: la
## Biblioteca tiene una carta in piu'. E' la prima capacita' che premia
## l'**alzare** una Pietra invece del solo costruirla (ISSUES 111).
func test_the_second_grade_gives_what_the_first_does_not() -> void:
	var seat: String = str(session.world["turn_order"][0])
	var prima: int = int(TagRules.hand_limit_delta(session.data, session.world, seat)["delta"])
	_a_place_of_mine(seat, "structure:library")
	var dopo: int = int(TagRules.hand_limit_delta(session.data, session.world, seat)["delta"])
	assert_eq(dopo - prima, 1, "la Biblioteca alza di uno il limite di mano")


## E il Castello pesa su **ogni** domanda, non su una sola: una capacita' non e'
## un argomento su un tema solo.
func test_the_castle_weighs_on_every_question() -> void:
	var seat: String = str(session.world["turn_order"][0])
	_a_place_of_mine(seat, "structure:castle")
	var viste: int = 0
	for tension_id in session.world["tensions"]:
		var bite: Dictionary = TagRules.action_bonus(
			session.data, session.world, seat, "INFLUENCE", str(tension_id)
		)
		if int(bite["delta"]) > 0:
			viste += 1
	assert_eq(viste, (session.world["tensions"] as Dictionary).size(),
		"il Castello pesa su tutte le domande in gioco")
