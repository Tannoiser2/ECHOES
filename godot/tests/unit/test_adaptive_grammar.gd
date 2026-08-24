extends "res://tests/test_case.gd"
## La grammatica adattiva (D-262, Fase B della direzione a tessere).
##
## Il contenuto dei Consigli e degli Echo non nomina piu' un posto o una casa
## per id: dice un **segno** — la Regione col #granaio, chi porta #dormiente —
## e il compilatore lo risolve sulla mappa che c'e'. Cosi' la stessa
## Conseguenza viaggia su qualunque tavolo, che e' la premessa delle tessere
## pescate (Fase C).

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _spec(kind: String, id: String) -> Dictionary:
	return {
		"type": "SET_REGION_TAG" if kind == "region" else "SET_ENTITY_TAG",
		"target": {"kind": kind, "id": id},
		"payload": {"tag": "condition:unrest"},
	}


func _compile(kind: String, id: String) -> Dictionary:
	return session.compiler.compile_spec(
		_spec(kind, id), {}, Effect.source("system", "TEST", "", 1, 1, 0)
	)


## **Il segno unico della tessera risolve al posto giusto.** Sono le coppie
## che le riscritture di D-262 hanno sostituito: se una tessera perde il suo
## segno, questa riga lo dice prima che una Conseguenza parli a vuoto.
func test_the_printed_sign_finds_its_tile() -> void:
	var atteso: Dictionary = {
		"granary": "REG_VALLE_VERDE",
		"mine": "REG_MINIERE_ANTICHE",
		"nomad_range": "REG_TERRE_NAHR",
		"wild": "REG_MONTAGNE_ROSSE",
		"capital": "REG_EREDAN",
		"trade": "REG_STRADA_MERCANTI",
	}
	for tag in atteso:
		# Non tutte le tessere stanno in ogni Chronicle: si prova solo dove la
		# mappa dell'anno ha il posto.
		if not (session.world["regions"] as Dictionary).has(str(atteso[tag])):
			continue
		var effect: Dictionary = _compile("region", "$region_with:%s" % tag)
		assert_eq(
			str((effect.get("target", {}) as Dictionary).get("id", "")), str(atteso[tag]),
			"il segno «%s» trova la sua tessera" % [str(tag)]
		)


## **Chi porta il segno risponde per nome.** Il selettore delle case legge il
## segno vivo: qui se ne fabbrica uno, cosi' la prova non dipende dal roster
## pescato col seme.
func test_the_carried_sign_finds_its_house() -> void:
	var who: String = ""
	for entity_id in session.world["turn_order"]:
		who = str(entity_id)
		break
	assert_ne(who, "", "al tavolo c'e' qualcuno")
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", who, {"tag": "discovery:test_mark"},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	var effect: Dictionary = _compile("entity", "$entity_with:discovery:test_mark")
	assert_eq(
		str((effect.get("target", {}) as Dictionary).get("id", "")), who,
		"il segno addosso trova la casa che lo porta"
	)


## **Nessuno lo porta: la clausola compila a niente, senza errore.** E' la
## regola di D-106 estesa ai selettori — il mondo non parla di chi non siede.
func test_an_unworn_sign_compiles_to_silence() -> void:
	var effect: Dictionary = _compile("entity", "$entity_with:segno_che_nessuno_porta")
	assert_true(effect.is_empty(), "la clausola sul segno assente non produce un Effetto")


## **Il requisito a segno si legge dal tavolo vivo.**
func test_requires_entity_tag_reads_the_live_table() -> void:
	var who: String = ""
	for entity_id in session.world["turn_order"]:
		who = str(entity_id)
		break
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", who, {"tag": "discovery:test_badge"},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_true(
		bool(session.confluence._someone_carries("discovery:test_badge")),
		"il segno appena posato si vede"
	)
	assert_false(
		bool(session.confluence._someone_carries("segno_che_nessuno_porta")),
		"un segno che nessuno porta non si inventa"
	)


## **Niente id fissi nel contenuto: la controprova dal dato spedito.** La
## guardia vera sta in validate_data (e si e' vista mordere su un difetto
## piantato); questa riga tiene il divieto anche sotto gli occhi della suite.
func test_shipped_councils_name_no_region_by_id() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	var offese: int = 0
	for collection in [loaded.consequences, loaded.confluence_templates, loaded.echo_cards]:
		for doc_id in collection:
			offese += _region_ids_in(collection[doc_id])
	assert_eq(offese, 0, "nessuna Conseguenza, template o Echo nomina una Regione per id")


func _region_ids_in(node: Variant) -> int:
	var found: int = 0
	match typeof(node):
		TYPE_DICTIONARY:
			for key in (node as Dictionary):
				found += _region_ids_in((node as Dictionary)[key])
		TYPE_ARRAY:
			for value in (node as Array):
				found += _region_ids_in(value)
		TYPE_STRING:
			if str(node).begins_with("REG_"):
				found += 1
	return found
