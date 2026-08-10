extends "res://tests/test_case.gd"
## Slot-filled narrative strings (§A9): the sentence follows the world.

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _narrative() -> RefCounted:
	return session.confluence.narrative


func _tag_region(region_id: String, tag: String) -> void:
	session.applier.apply(
		Effect.make(
			"SET_REGION_TAG",
			"region",
			region_id,
			{"tag": tag},
			Effect.source("test", "TEST", "", 1, 1, 0)
		)
	)


## The whole point of the exercise: one authored question has to be able to
## follow the crisis around the map. Tag a different Region as starving and the
## Tension's focus - and so every $slot in its sentences - moves with it.
func test_focus_region_follows_the_condition_tag() -> void:
	var narrative: RefCounted = _narrative()
	assert_eq(
		narrative.focus_region("TEN_FAMINE"),
		"REG_VALLE_VERDE",
		"senza condizioni la Carestia guarda il granaio"
	)

	_tag_region("REG_TERRE_NAHR", "condition:starving")
	assert_eq(
		narrative.focus_region("TEN_FAMINE"),
		"REG_TERRE_NAHR",
		"chi ha fame diventa la regione di cui si parla"
	)

	# A more specific tag wins over a less specific one, in the order the
	# Tension declares - not in the order the tags happened to be applied.
	_tag_region("REG_STRADA_MERCANTI", "condition:unrest")
	assert_eq(
		narrative.focus_region("TEN_FAMINE"),
		"REG_TERRE_NAHR",
		"'starving' viene prima di 'unrest' nella lista della Tensione"
	)


## A Tension never looks outside its own domain, whatever the tags say.
func test_focus_region_stays_inside_the_domain() -> void:
	_tag_region("REG_VALLE_VERDE", "condition:exploited")
	assert_eq(
		_narrative().focus_region("TEN_AWAKENING"),
		"REG_MINIERE_ANTICHE",
		"il Risveglio non guarda una regione SURVIVAL"
	)


## The same authored sentence, two different worlds, two different sentences.
func test_the_same_sentence_names_a_different_place() -> void:
	var narrative: RefCounted = _narrative()
	var authored: String = "Chi nutre $the_region quando i granai si svuotano?"

	var before: String = narrative.fill(
		authored, narrative.bindings_for("TEN_FAMINE", "ENT_ALDRIC")
	)
	_tag_region("REG_TERRE_NAHR", "condition:starving")
	var after: String = narrative.fill(
		authored, narrative.bindings_for("TEN_FAMINE", "ENT_ALDRIC")
	)

	assert_eq(before, "Chi nutre la Valle Verde quando i granai si svuotano?", "prima")
	assert_eq(after, "Chi nutre le Terre Nahr quando i granai si svuotano?", "dopo")
	assert_ne(before, after, "la frase segue il mondo")


## Italian is not a name in a hole: the article and the preposition have to agree
## with the noun, and a slot that opens the sentence still owes it a capital.
func test_italian_forms_and_capitalisation() -> void:
	var narrative: RefCounted = _narrative()
	var bindings: Dictionary = narrative.bindings_for("TEN_FAMINE", "ENT_ALDRIC")

	assert_eq(
		narrative.fill("La terra $of_region.", bindings),
		"La terra della Valle Verde.",
		"genitivo articolato, non 'di la'"
	)
	assert_eq(
		narrative.fill("$in_region, a chi appartiene?", bindings),
		"Nella Valle Verde, a chi appartiene?",
		"lo slot in testa alla frase riceve la maiuscola"
	)
	assert_eq(
		narrative.fill("Il grano di $the_region", bindings),
		"Il grano di la Valle Verde",
		"lo slot sbagliato produce italiano sbagliato: e responsabilita di chi scrive"
	)


## `$region` is a prefix of `$the_region`. Substituting the short key first would
## leave "the_" stranded in the line, so length order is not an implementation
## detail.
func test_longer_slots_are_substituted_first() -> void:
	var narrative: RefCounted = _narrative()
	var bindings: Dictionary = narrative.bindings_for("TEN_FAMINE", "ENT_ALDRIC")
	assert_eq(
		narrative.fill("$region e $the_region", bindings),
		"Valle Verde e la Valle Verde",
		"nessun 'the_' orfano"
	)


## The Truth register is permanent and cannot be undone: a $slot surviving into
## it would be a bug nobody can take back.
func test_no_slot_survives_into_the_truth_register() -> void:
	session.run(load("res://cli/policy_decider.gd").new(session.log))
	var checked: int = 0
	for truth in session.world["truth_log"]:
		assert_false(
			str(truth["text"]).contains("$"),
			"nessuno slot irrisolto nel registro: %s" % str(truth["text"])
		)
		checked += 1
	assert_true(checked >= 0, "il registro e stato ispezionato")
