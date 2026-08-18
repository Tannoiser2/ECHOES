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


func test_with_no_signs_on_the_board_every_hook_is_neutral() -> void:
	# D-105: le cinque regole di casa viaggiano nei dati, ma i loro segni
	# (granaio, fame, razzia, giuramento, fama) non esistono a inizio
	# partita - quindi ogni gancio resta neutro finché il gioco non li posa.
	assert_eq(
		session.data.tag_rules.size(), 34,
		"le regole di D-105, i poteri di vita di D-109 e D-124, i denti di D-117 e le cicatrici di D-122"
	)
	var bonus: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_ALDRIC", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(bonus["delta"]), 0, "nessun bonus d'azione")
	var factor: Dictionary = TagRules.council_world_factor(
		session.data, session.world, "TEN_FAMINE", "ENT_ALDRIC"
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
		"when": {"scope": "REGION", "tag": "structure:prova"},
		"template": "INFLUENCE", "delta": 1,
	})
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", "REG_TERRE_NAHR", {"tag": "structure:prova"}, source
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


# --- ISSUES 25 (D-116): i denti che aggiungono e tolgono --------------------


## Con zero regole dei tipi nuovi, ogni gancio nuovo resta neutro: il telaio
## si misura vuoto prima che i denti veri si accendano (stesso rito di D-104).
func test_new_hooks_are_neutral_without_rules() -> void:
	assert_eq(
		TagRules.action_gate(session.data, session.world, "ENT_ALDRIC", "FORGE"),
		"", "nessun divieto"
	)
	var bias: Dictionary = TagRules.draw_bias(session.data, session.world, "ENT_ALDRIC", "FORCE")
	assert_eq(str(bias["bias"]), "", "nessuna pesca piegata")
	var squeeze: Dictionary = TagRules.hand_limit_delta(session.data, session.world, "ENT_ALDRIC")
	assert_eq(int(squeeze["delta"]), 0, "il limite di mano non si muove")
	assert_eq(
		TagRules.relation_floor(session.data, session.world, "ENT_ALDRIC|ENT_NAHR"),
		"", "nessun pavimento"
	)


func test_action_gate_forbids_while_the_sign_stands() -> void:
	_rule("TGR_INTERDETTO", {"kind": "ACTION_GATE", "template": "ACQUIRE"})
	var params: Dictionary = {"family": "FORCE"}
	assert_eq(
		session.actions.check("ENT_ALDRIC", "ACQUIRE", params), "",
		"senza segno la pesca e' legale"
	)
	_set_global("test_sign")
	var refusal: String = session.actions.check("ENT_ALDRIC", "ACQUIRE", params)
	assert_true(
		refusal.contains("il segno lo vieta"),
		"col segno la pesca e' vietata, e il rifiuto si firma: %s" % refusal
	)
	# E il divieto pesa una volta sola, dentro check(): execute() lo rispetta.
	var result: Dictionary = session.actions.execute(
		"ENT_ALDRIC", {"template": "ACQUIRE", "params": params}
	)
	assert_false(bool(result.get("ok", true)), "execute rifiuta con lo stesso motivo")


## La pesca piegata guarda le prime due carte e prende quella che il segno
## impone; l'altra resta dov'era, e l'indice viaggia nell'Effect.
func test_draw_bias_malus_takes_the_worse_of_two() -> void:
	var family: String = _family_without_source("ENT_VAERAX")
	var pair: Dictionary = _weak_and_strong(family)
	_rule("TGR_MERCATO_GUASTO", {
		"kind": "DRAW_BIAS", "family": family, "bias": "MALUS",
		"title": "Il mercato guasto",
	})
	_set_global("test_sign")
	var deck: Dictionary = session.world["decks"][family]
	var rest: Array = []
	for id in deck["draw"]:
		if str(id) != pair["strong"] and str(id) != pair["weak"]:
			rest.append(str(id))
	deck["draw"] = [pair["strong"], pair["weak"]] + rest
	var result: Dictionary = session.actions.execute(
		"ENT_VAERAX", {"template": "ACQUIRE", "params": {"family": family}}
	)
	assert_true(bool(result.get("ok", false)), "la pesca riesce: %s" % str(result.get("error", "")))
	assert_true(
		(session.world["entities"]["ENT_VAERAX"]["hand"] as Array).has(pair["weak"]),
		"in mano arriva la carta debole"
	)
	assert_eq(
		str((session.world["decks"][family]["draw"] as Array)[0]), pair["strong"],
		"la carta forte resta in cima al mazzo"
	)


func test_hand_limit_delta_squeezes_the_hand() -> void:
	_rule("TGR_ASSEDIO_STRINGE", {
		"kind": "HAND_LIMIT", "hand_limit_delta": -3, "title": "L'assedio stringe",
	})
	_set_global("test_sign")
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	var family: String = _family_without_source("ENT_VAERAX")
	# Quattro carte in mano dal nulla: al limite nuovo (7-3=4) la quinta
	# pescata deve costare uno scarto immediato.
	var stock: Array = _assets_of(family)
	for i in range(4):
		session.applier.apply(Effect.make(
			"GRANT_ASSET", "entity", "ENT_VAERAX",
			{"source": "VOID", "asset_id": str(stock[i])}, source
		))
	var result: Dictionary = session.actions.execute(
		"ENT_VAERAX", {"template": "ACQUIRE", "params": {"family": family}}
	)
	assert_true(bool(result.get("ok", false)), "la pesca riesce: %s" % str(result.get("error", "")))
	assert_eq(
		session.service.hand_size("ENT_VAERAX"), 4,
		"la mano torna al limite stretto dal segno"
	)
	var told: bool = false
	for line in session.log.lines:
		if str(line).contains("L'assedio stringe"):
			told = true
	assert_true(told, "la stretta si firma a verbale")


func test_grant_on_set_hands_the_named_card() -> void:
	var family: String = _family_without_source("ENT_NAHR")
	# In fondo alla pila, non in cima: la consegna deve trovarla ovunque sia.
	var deck: Dictionary = session.world["decks"][family]
	var granted: String = str((deck["draw"] as Array).back())
	_rule("TGR_CANALE", {
		"kind": "GRANT_ON_SET",
		"when": {"scope": "GLOBAL", "tag": "canal_built"},
		"grant": {"asset_id": granted, "give_to": "ACTOR"},
	})
	var copies: int = (deck["draw"] as Array).count(granted)
	var source: Dictionary = Effect.source("action", "ACT_TEST", "ENT_NAHR", 1, 1, 0)
	session.applier.apply(Effect.make(
		"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "canal_built"}, source
	))
	var hand: Array = session.world["entities"]["ENT_NAHR"]["hand"]
	assert_true(hand.has(granted), "chi costruisce il canale riceve la carta")
	# Un mazzo può portare due copie della stessa carta: la consegna ne
	# toglie una sola.
	assert_eq(
		(session.world["decks"][family]["draw"] as Array).count(granted), copies - 1,
		"una copia e' uscita dal mazzo"
	)
	# Posare lo stesso segno di nuovo e' un no-op: nessuna seconda consegna.
	session.applier.apply(Effect.make(
		"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "canal_built"}, source
	))
	assert_eq(hand.count(granted), 1, "una carta sola, anche se il segno torna")


func test_grant_on_set_to_target_reads_the_marked_entity() -> void:
	var family: String = _family_without_source("ENT_LYRA")
	var granted: String = str((session.world["decks"][family]["draw"] as Array)[0])
	_rule("TGR_INVESTITURA_DONA", {
		"kind": "GRANT_ON_SET",
		"when": {"scope": "ENTITY", "tag": "canal_rights"},
		"grant": {"asset_id": granted, "give_to": "TARGET"},
	})
	var source: Dictionary = Effect.source("action", "ACT_TEST", "ENT_ALDRIC", 1, 1, 0)
	session.applier.apply(Effect.make(
		"SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "canal_rights"}, source
	))
	assert_true(
		(session.world["entities"]["ENT_LYRA"]["hand"] as Array).has(granted),
		"la carta va a chi porta il segno, non a chi lo posa"
	)


func test_relation_floor_holds_and_the_cap_wins() -> void:
	_rule("TGR_SANGUE", {
		"kind": "RELATION_FLOOR", "min_level": "NEUTRAL",
		"when": {"scope": "GLOBAL", "tag": "blood_bond"},
	})
	_set_global("blood_bond")
	var source: Dictionary = Effect.source("test", "TEST", "", 1, 1, 0)
	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", "ENT_ALDRIC|ENT_NAHR", {"level": "ENEMY"}, source
	))
	assert_eq(
		str(session.world["relations"]["ENT_ALDRIC|ENT_NAHR"]["level"]), "NEUTRAL",
		"il sangue non si sceglie: sotto il pavimento non si scende"
	)
	# Tetto e pavimento insieme: la ferita scritta pesa piu' del vincolo.
	_rule("TGR_GIURAMENTO_ROTTO", {
		"kind": "RELATION_CAP", "max_level": "HOSTILE",
		"when": {"scope": "GLOBAL", "tag": "oath_broken"},
	})
	_set_global("oath_broken")
	session.applier.apply(Effect.make(
		"SET_RELATION", "relation", "ENT_ALDRIC|ENT_NAHR", {"level": "ALLY"}, source
	))
	assert_eq(
		str(session.world["relations"]["ENT_ALDRIC|ENT_NAHR"]["level"]), "HOSTILE",
		"quando tetto e pavimento si contraddicono, vince il tetto"
	)


## La famiglia per cui il seggio NON ha una Regione-fonte: cosi' la pesca e'
## singola e il test legge esattamente una carta.
func _family_without_source(entity_id: String) -> String:
	for family in ["FORCE", "AUTHORITY", "WEALTH", "KNOWLEDGE", "PEOPLE", "BONDS"]:
		var has_source: bool = false
		for region_id in session.service.regions_with_presence(entity_id):
			if (session.data.regions[str(region_id)]["asset_sources"] as Array).has(family):
				has_source = true
		if not has_source:
			return str(family)
	return "FORCE"


func _assets_of(family: String) -> Array:
	var out: Array = []
	var ids: Array = session.data.assets.keys()
	ids.sort()
	for id in ids:
		if str(session.data.assets[id]["family"]) == family:
			out.append(str(id))
	return out


func _weak_and_strong(family: String) -> Dictionary:
	var weak: String = ""
	var strong: String = ""
	for id in _assets_of(family):
		var strength: int = int(session.data.assets[id]["strength"])
		if weak == "" or strength < int(session.data.assets[weak]["strength"]):
			weak = id
		if strong == "" or strength > int(session.data.assets[strong]["strength"]):
			strong = id
	return {"weak": weak, "strong": strong}


func test_chronicle_filter_keeps_rules_at_home() -> void:
	_rule("TGR_ALTROVE", {
		"template": "INFLUENCE", "delta": 2, "chronicle_id": "CHR_03",
	})
	_set_global("test_sign")
	var bonus: Dictionary = TagRules.action_bonus(
		session.data, session.world, "ENT_ALDRIC", "INFLUENCE", "TEN_FAMINE"
	)
	assert_eq(int(bonus["delta"]), 0, "una regola della Chronicle III non morde nella I")
