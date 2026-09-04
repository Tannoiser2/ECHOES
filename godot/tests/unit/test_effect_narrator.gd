extends "res://tests/test_case.gd"
## ISSUES 22, Fase 1: every Effect a Consequence lands has a spoken line, with
## table names and never ids — the crown losing the Valle Verde was silent in
## the chronicle played at seed 15308, and that silence is the bug.

const Effect := preload("res://scripts/core/effect.gd")
const EffectNarrator := preload("res://scripts/chronicle/effect_narrator.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func before_each() -> void:
	new_session()


func _narrated(type: String, kind: String, id: String, payload: Dictionary) -> String:
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	var stored: Dictionary = session.applier.apply(Effect.make(type, kind, id, payload, source))
	assert_false(stored.is_empty(), "l'effetto %s si applica" % type)
	return EffectNarrator.narrate(stored, session.data)


func test_control_change_is_a_sentence_with_names() -> void:
	var said: String = _narrated(
		"SET_CONTROL", "region", "REG_VALLE_VERDE", {"entity_id": "ENT_NAHR"}
	)
	assert_true(said.contains("Valle Verde"), "la Regione col suo nome: %s" % said)
	assert_true(said.contains("Popolo Nahr"), "il controllore col suo nome: %s" % said)
	assert_false(said.contains("REG_"), "nessun id di Regione al tavolo")
	assert_false(said.contains("ENT_"), "nessun id di Entità al tavolo")


func test_losing_control_names_who_lost_it() -> void:
	var said: String = _narrated("SET_CONTROL", "region", "REG_EREDAN", {"entity_id": null})
	assert_true(said.contains("non risponde più a"), "la perdita è detta: %s" % said)
	assert_true(said.contains("Re Aldric"), "chi perde ha un nome: %s" % said)


func test_presence_and_tags_speak() -> void:
	var lost: String = _narrated(
		"REMOVE_PRESENCE", "entity", "ENT_ALDRIC", {"region_id": "REG_VALLE_VERDE"}
	)
	assert_true(
		lost.contains("Re Aldric") and lost.contains("Valle Verde"),
		"la presenza persa ha nomi: %s" % lost
	)
	var marked: String = _narrated(
		"SET_REGION_TAG", "region", "REG_VALLE_VERDE", {"tag": "nahr_settled"}
	)
	# **Il segno si legge con la sua parola, non col suo id** (D-228). Questa riga
	# chiedeva che nella narrazione comparisse `nahr_settled`, cioe' pretendeva il
	# nome interno: la prova teneva fermo il difetto invece della regola. Adesso
	# `SignLabels` copre anche i fatti del mondo e la frase e' quella che si legge
	# al tavolo.
	assert_true(
		marked.contains("i Nahr si sono fermati"),
		"il segno si legge con la sua parola: %s" % marked
	)
	assert_false(marked.contains("nahr_settled"), "e non col suo id: %s" % marked)
	var entity_marked: String = _narrated(
		"SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "renown"}
	)
	assert_true(entity_marked.contains("Lyra"), "il seggio col suo nome: %s" % entity_marked)


func test_tension_moves_use_the_title_and_the_applied_delta() -> void:
	var said: String = _narrated("ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 1})
	assert_true(said.contains("La Carestia"), "la Tensione col suo titolo: %s" % said)
	assert_true(said.contains("sale di 1"), "il verso e la misura: %s" % said)


func test_unveiling_a_tension_is_announced() -> void:
	# Nessuna Tensione nasce velata (D-450): si vela prima, o svelare e' un no-op.
	_narrated("SET_TENSION_VISIBILITY", "tension", "TEN_AWAKENING", {"visibility": "VEILED"})
	var said: String = _narrated(
		"SET_TENSION_VISIBILITY", "tension", "TEN_AWAKENING", {"visibility": "OPEN"}
	)
	assert_true(said.contains("non è più velata"), "lo svelamento è detto: %s" % said)


func test_noops_and_bookkeeping_stay_silent() -> void:
	# Tagging what is already tagged changes nothing, so it says nothing.
	var first: String = _narrated("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "gt_once"})
	assert_true(first != "", "il primo segno parla")
	var again: String = _narrated("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "gt_once"})
	assert_eq(again, "", "il segno ripetuto tace")
	# La contabilita' di Propp non si tace piu': **non esiste piu'** (D-358).
	# Questa riga chiedeva al verbale di stare zitto su un segno che il motore
	# scriveva e la vista nascondeva. Adesso la grammatica di Propp si legge
	# dalle carte calate sul tavolo, e un segno che il verbale deve nascondere
	# non c'e'. Quello che resta da provare e' che **non ne torni uno**.
	var nascosto: String = _narrated(
		"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "function:separation"}
	)
	assert_true(
		nascosto != "",
		"nessun segno e' piu' muto per convenzione: se torna un `function:` sul"
		+ " mondo, il verbale lo dice invece di ingoiarlo"
	)


func test_a_full_chronicle_names_consequences_never_ids() -> void:
	await session.run(PolicyDecider.new(session.log))
	var titled: int = 0
	for line in session.log.lines:
		var text: String = str(line)
		assert_false(text.contains("H. Conseguenze: CNS_"), "gli id non si leggono più")
		if text.contains("H. Conseguenza - "):
			titled += 1
			assert_false(text.contains("CNS_"), "la Conseguenza parla col titolo: %s" % text)
	assert_true(titled > 0, "almeno una Conseguenza col titolo nel verbale")
