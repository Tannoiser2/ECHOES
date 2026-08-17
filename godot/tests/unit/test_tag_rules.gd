extends "res://tests/test_case.gd"
## ISSUES 24, Fase 2: il telaio delle tag_rules. Con zero regole ogni gancio
## restituisce il suo neutro; con una regola sintetica accesa, ogni gancio
## morde dove dichiara. I denti veri arrivano in Fase 3, scritti d'autore e
## misurati: qui si prova che il telaio li reggerà.

const Effect := preload("res://scripts/core/effect.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")


func before_each() -> void:
	new_session()


func _rule(id: String, overrides: Dictionary) -> void:
	var rule: Dictionary = {
		"id": id,
		"title": "Regola di prova",
		"when": {"scope": "GLOBAL", "tag": "test_sign"},
		"kind": "ACTION_MODIFIER",
		"active": true,
	}
	rule.merge(overrides, true)
	session.data.tag_rules[id] = rule


func _set_global(tag: String) -> void:
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	session.applier.apply(Effect.make("SET_GLOBAL_TAG", "world", "WORLD", {"tag": tag}, source))


func test_without_rules_every_hook_is_neutral() -> void:
	assert_eq(session.data.tag_rules.size(), 0, "il telaio parte vuoto: zero regole nei dati")
	var bonus: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_ALDRIC", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(bonus["delta"]), 0, "nessun bonus d'azione")
	var factor: Dictionary = TagRules.council_world_factor(
		session.data, session.world, "TEN_FAMINE"
	)
	assert_eq(int(factor["delta"]), 0, "nessun peso sul Consiglio")
	assert_eq(
		TagRules.movement_gate(session.data, session.world, "REG_VALLE_VERDE"),
		"", "nessuna porta"
	)
	assert_eq(
		TagRules.relation_cap(session.data, session.world, "ENT_ALDRIC|ENT_NAHR"),
		"", "nessun tetto"
	)


func test_a_spent_rule_never_bites() -> void:
	_rule("TGR_SPENTA", {"active": false, "delta": 2, "template": "INFLUENCE"})
	_set_global("test_sign")
	var bonus: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_ALDRIC", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(bonus["delta"]), 0, "una regola spenta è un progetto, non una meccanica")


func test_action_modifier_bites_through_influence() -> void:
	_rule("TGR_GRANAIO", {
		"title": "Il granaio parla",
		"template": "INFLUENCE", "delta": 1, "tension_id": "TEN_FAMINE",
	})
	_set_global("test_sign")
	var before: int = int(session.world["tensions"]["TEN_FAMINE"]["current_value"])
	var result: Dictionary = session.actions.execute(
		"ENT_NAHR", {"template": "INFLUENCE", "params": {"tension_id": "TEN_FAMINE", "delta": 1}}
	)
	assert_true(bool(result.get("ok", false)), "l'azione riesce: %s" % str(result.get("error", "")))
	var after: int = int(session.world["tensions"]["TEN_FAMINE"]["current_value"])
	assert_eq(after - before, 2, "il +1 del segno allarga il passo: 1 diventa 2")
	var told: bool = false
	for line in session.log.lines:
		if str(line).contains("Il segno pesa: Il granaio parla."):
			told = true
	assert_true(told, "la regola che morde si firma a verbale")


func test_action_modifier_respects_tension_filter() -> void:
	_rule("TGR_SOLO_CARESTIA", {
		"template": "INFLUENCE", "delta": 1, "tension_id": "TEN_FAMINE",
	})
	_set_global("test_sign")
	var bonus: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_NAHR", "INFLUENCE", "TEN_SUCCESSION"
	)
	assert_eq(int(bonus["delta"]), 0, "il segno sulla Carestia non tocca la Successione")


func test_region_scope_needs_presence_on_the_marked_region() -> void:
	_rule("TGR_LOCALE", {
		"when": {"scope": "REGION", "tag": "structure:granary"},
		"template": "INFLUENCE", "delta": 1,
	})
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", "REG_TERRE_NAHR", {"tag": "structure:granary"}, source
	))
	var with_presence: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_NAHR", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(with_presence["delta"]), 1, "i Nahr stanno nelle Terre Nahr: il segno pesa")
	var without: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_LYRA", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(without["delta"]), 0, "Lyra non ha presenza lì: per lei il segno tace")


func test_gate_blocks_and_allows_movement() -> void:
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	# Le Terre Nahr sono adiacenti per i Nahr: una porta BLOCK le sbarra.
	_rule("TGR_SBARRATA", {
		"kind": "GATE", "movement": "BLOCK",
		"when": {"scope": "REGION", "tag": "scar:sealed_border"},
	})
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", "REG_VALLE_VERDE", {"tag": "scar:sealed_border"}, source
	))
	assert_false(
		session.service.can_move_to("ENT_NAHR", "REG_VALLE_VERDE"),
		"la Valle col confine sigillato non si entra"
	)
	# Una porta ALLOW concede un passo che l'adiacenza negherebbe.
	_rule("TGR_PASSO", {
		"kind": "GATE", "movement": "ALLOW",
		"when": {"scope": "REGION", "tag": "settlement:march"},
	})
	assert_false(
		session.service.can_move_to("ENT_NAHR", "REG_MINIERE_ANTICHE"),
		"senza segno le Miniere restano lontane"
	)
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", "REG_MINIERE_ANTICHE", {"tag": "settlement:march"}, source
	))
	assert_true(
		session.service.can_move_to("ENT_NAHR", "REG_MINIERE_ANTICHE"),
		"il passo concesso apre la via anche senza adiacenza"
	)


func test_relation_cap_holds_the_ceiling() -> void:
	_rule("TGR_GIURAMENTO", {
		"kind": "RELATION_CAP", "max_level": "HOSTILE",
		"when": {"scope": "GLOBAL", "tag": "oath_broken"},
	})
	_set_global("oath_broken")
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", "ENT_ALDRIC|ENT_NAHR", {"level": "ALLY"}, source
	))
	assert_eq(
		str(session.world["relations"]["ENT_ALDRIC|ENT_NAHR"]["level"]), "HOSTILE",
		"col giuramento spezzato la relazione non sale sopra HOSTILE"
	)
	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", "ENT_ALDRIC|ENT_NAHR", {"level": "ENEMY"}, source
	))
	assert_eq(
		str(session.world["relations"]["ENT_ALDRIC|ENT_NAHR"]["level"]), "ENEMY",
		"scendere resta sempre possibile"
	)


func test_chronicle_filter_keeps_rules_at_home() -> void:
	_rule("TGR_ALTROVE", {
		"template": "INFLUENCE", "delta": 2, "chronicle_id": "CHR_03",
	})
	_set_global("test_sign")
	var bonus: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_ALDRIC", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(bonus["delta"]), 0, "una regola della Chronicle III non morde nella I")
