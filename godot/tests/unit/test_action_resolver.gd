extends "res://tests/test_case.gd"
## The six action templates (§10): what each one costs, and what it refuses.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")


func before_each() -> void:
	new_session()


func _do(entity_id: String, template: String, params: Dictionary = {}) -> Dictionary:
	return session.actions.execute(entity_id, {"template": template, "params": params})


## §10 ACQUIRE: a source Region turns the draw into draw-2-keep-1.
func test_acquire_with_a_source_region_draws_two_and_keeps_one() -> void:
	# Aldric holds Eredan, which sources AUTHORITY and WEALTH.
	var before: int = session.service.hand_size("ENT_ALDRIC")
	var result: Dictionary = _do("ENT_ALDRIC", "ACQUIRE", {"family": "AUTHORITY"})
	assert_true(bool(result["ok"]), "l'azione riesce: %s" % str(result["error"]))
	assert_eq((result["info"]["drawn"] as Array).size(), 2, "pesca 2 carte")
	assert_eq(session.service.hand_size("ENT_ALDRIC"), before + 1, "ne tiene 1")
	assert_true(
		(session.world["decks"]["AUTHORITY"]["discard"] as Array).size() >= 1,
		"l'altra finisce negli scarti"
	)


func test_acquire_without_a_source_region_draws_one() -> void:
	# Vaerax holds the Mountains and the Mines: no PEOPLE source anywhere.
	var before: int = session.service.hand_size("ENT_VAERAX")
	var result: Dictionary = _do("ENT_VAERAX", "ACQUIRE", {"family": "PEOPLE"})
	assert_true(bool(result["ok"]), "l'azione riesce")
	assert_eq((result["info"]["drawn"] as Array).size(), 1, "pesca 1 sola carta")
	assert_eq(session.service.hand_size("ENT_VAERAX"), before + 1, "la mano cresce di 1")


func test_acquire_refuses_an_unknown_family() -> void:
	var result: Dictionary = _do("ENT_ALDRIC", "ACQUIRE", {"family": "GLORIA"})
	assert_false(bool(result["ok"]), "una famiglia inesistente viene rifiutata")


## §9: hand limit 7; the eighth Asset forces a discard.
func test_hand_limit_forces_a_discard() -> void:
	var limit: int = int(session.chronicle_def()["hand_limit"])
	for _i in range(12):
		_do("ENT_ALDRIC", "ACQUIRE", {"family": "AUTHORITY"})
		if session.service.hand_size("ENT_ALDRIC") >= limit:
			break
	_do("ENT_ALDRIC", "ACQUIRE", {"family": "AUTHORITY"})
	assert_true(
		session.service.hand_size("ENT_ALDRIC") <= limit,
		"la mano non supera mai %d carte" % limit
	)


## §10 MOVE: only into a Region bordering one you hold (or a starting Region).
func test_move_requires_adjacency() -> void:
	var far: Dictionary = _do("ENT_ALDRIC", "MOVE", {"region_id": "REG_MONTAGNE_ROSSE"})
	assert_false(bool(far["ok"]), "le Montagne non confinano con la presenza di Aldric")

	var near: Dictionary = _do("ENT_ALDRIC", "MOVE", {"region_id": "REG_STRADA_MERCANTI"})
	assert_true(bool(near["ok"]), "la Strada confina con Eredan: %s" % str(near["error"]))
	assert_eq(session.service.presence_count("ENT_ALDRIC", "REG_STRADA_MERCANTI"), 1, "token posato")


func test_move_relocates_once_all_tokens_are_placed() -> void:
	_do("ENT_ALDRIC", "MOVE", {"region_id": "REG_STRADA_MERCANTI"})
	assert_eq(session.service.tokens_placed("ENT_ALDRIC"), 3, "tutti e tre i token sono sul tavolo")

	var result: Dictionary = _do(
		"ENT_ALDRIC", "MOVE", {"region_id": "REG_TERRE_NAHR", "from_region_id": "REG_EREDAN"}
	)
	assert_true(bool(result["ok"]), "con 3 token si sposta: %s" % str(result["error"]))
	assert_eq(session.service.tokens_placed("ENT_ALDRIC"), 3, "il totale resta 3")
	assert_eq(session.service.presence_count("ENT_ALDRIC", "REG_EREDAN"), 0, "il token ha lasciato Eredan")


## §10 INFLUENCE: presence in the domain, or discard a relevant Asset.
func test_influence_by_presence_is_free() -> void:
	var hand_before: int = session.service.hand_size("ENT_ALDRIC")
	var before: int = session.tensions.value("TEN_FAMINE")
	var result: Dictionary = _do(
		"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE"}
	)
	assert_true(bool(result["ok"]), "Aldric ha presenza in una Regione SURVIVAL: %s" % str(result["error"]))
	assert_eq(session.tensions.value("TEN_FAMINE"), before + 1, "la Tensione sale di 1")
	assert_eq(session.service.hand_size("ENT_ALDRIC"), hand_before, "la presenza non costa carte")


func test_influence_by_discard_spends_a_relevant_asset() -> void:
	# Vaerax has no presence in a SURVIVAL Region, so he has to pay.
	session.applier.apply(
		Effect.make(
			"GRANT_ASSET",
			"entity",
			"ENT_VAERAX",
			{"asset_id": "AST_WEALTH_GRAIN", "source": "VOID"},
			Effect.source("developer", "TEST", "", 1, 1, 0)
		)
	)
	var hand_before: int = session.service.hand_size("ENT_VAERAX")
	var result: Dictionary = _do(
		"ENT_VAERAX", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": -1}
	)
	assert_true(bool(result["ok"]), "paga con un Asset rilevante: %s" % str(result["error"]))
	assert_eq(str(result["info"]["via"]), "DISCARD", "la via e lo scarto")
	assert_eq(session.service.hand_size("ENT_VAERAX"), hand_before - 1, "una carta e stata spesa")


func test_influence_refuses_a_veiled_tension() -> void:
	var result: Dictionary = _do(
		"ENT_VAERAX", "INFLUENCE", {"tension_id": "TEN_AWAKENING", "delta": -1}
	)
	assert_false(bool(result["ok"]), "una Tensione velata non e influenzabile")

	_do("ENT_VAERAX", "SCHEME", {"mode": "TENSION", "tension_id": "TEN_AWAKENING"})
	var after: Dictionary = _do(
		"ENT_VAERAX", "INFLUENCE", {"tension_id": "TEN_AWAKENING", "delta": -1, "via": "PRESENCE"}
	)
	assert_true(bool(after["ok"]), "dopo lo SCHEME diventa raggiungibile: %s" % str(after["error"]))


func test_influence_refuses_a_delta_other_than_one() -> void:
	var result: Dictionary = _do(
		"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 3, "via": "PRESENCE"}
	)
	assert_false(bool(result["ok"]), "INFLUENCE muove di 1, non di 3")


## §10 FORGE: up needs consent and a Bond; down is unilateral and free.
func test_forge_up_needs_consent_and_a_bond() -> void:
	var refused: Dictionary = _do(
		"ENT_NAHR", "FORGE", {"target_entity_id": "ENT_LYRA", "direction": "UP"}
	)
	assert_false(bool(refused["ok"]), "senza consenso non si sale")

	var hand_before: int = session.service.hand_size("ENT_NAHR")
	var result: Dictionary = _do(
		"ENT_NAHR", "FORGE", {"target_entity_id": "ENT_LYRA", "direction": "UP", "consent": true}
	)
	assert_true(bool(result["ok"]), "con consenso e un BONDS si sale: %s" % str(result["error"]))
	assert_eq(session.service.relation_level("ENT_NAHR", "ENT_LYRA"), "ALLY", "NEUTRAL -> ALLY")
	assert_eq(session.service.hand_size("ENT_NAHR"), hand_before - 1, "il Bond e stato speso")


func test_forge_down_is_free_and_public() -> void:
	var hand_before: int = session.service.hand_size("ENT_ALDRIC")
	var lines_before: int = session.log.lines.size()
	var result: Dictionary = _do(
		"ENT_ALDRIC", "FORGE", {"target_entity_id": "ENT_NAHR", "direction": "DOWN"}
	)
	assert_true(bool(result["ok"]), "scendere e sempre possibile: %s" % str(result["error"]))
	assert_eq(session.service.relation_level("ENT_ALDRIC", "ENT_NAHR"), "ENEMY", "HOSTILE -> ENEMY")
	assert_eq(session.service.hand_size("ENT_ALDRIC"), hand_before, "scendere non costa nulla")
	assert_true(session.log.lines.size() > lines_before, "la rottura finisce nel log pubblico")


## §10 SCHEME: three modes, each leaving an auditable trace and no public leak.
func test_scheme_tension_grants_knowledge_and_a_discovery() -> void:
	var result: Dictionary = _do(
		"ENT_LYRA", "SCHEME", {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}
	)
	assert_true(bool(result["ok"]), "SCHEME riuscito: %s" % str(result["error"]))
	assert_true(bool(result["info"]["private"]), "il risultato e privato")
	assert_eq(int(result["info"]["value"]), 2, "il valore velato viene rivelato al solo attore")
	var tags: Array = session.world["entities"]["ENT_LYRA"]["tags"]
	assert_true(tags.has(Ids.knows_tension_tag("TEN_AWAKENING")), "ora la conosce")
	assert_true(tags.has("discovery:TEN_AWAKENING"), "aprire un velo e una Scoperta")

	for line in session.log.lines:
		assert_false(str(line).contains("TEN_AWAKENING: 2"), "il valore non compare nel log pubblico")


func test_scheme_refuses_a_tension_already_known() -> void:
	_do("ENT_LYRA", "SCHEME", {"mode": "TENSION", "tension_id": "TEN_AWAKENING"})
	var again: Dictionary = _do(
		"ENT_LYRA", "SCHEME", {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}
	)
	assert_false(bool(again["ok"]), "non si spende un'AO per sapere quello che gia si sa")


func test_scheme_echo_deck_shows_two_cards_of_the_act_pool() -> void:
	var result: Dictionary = _do("ENT_LYRA", "SCHEME", {"mode": "ECHO_DECK"})
	assert_true(bool(result["ok"]), "SCHEME sul mazzo Echo: %s" % str(result["error"]))
	var peek: Array = result["info"]["echo_peek"]
	assert_true(peek.size() <= 2, "al massimo due carte")
	for card_id in peek:
		assert_eq(
			str(data().echo_cards[str(card_id)]["dramatic_family"]),
			"PRESSURE",
			"nell'Atto 1 si pesca solo da PRESSIONE"
		)


func test_scheme_region_requires_private_information() -> void:
	var result: Dictionary = _do("ENT_LYRA", "SCHEME", {"mode": "REGION", "region_id": "REG_EREDAN"})
	assert_false(bool(result["ok"]), "Eredan non ha informazioni private")

	var mine: Dictionary = _do(
		"ENT_LYRA", "SCHEME", {"mode": "REGION", "region_id": "REG_MINIERE_ANTICHE"}
	)
	assert_true(bool(mine["ok"]), "le Miniere si: %s" % str(mine["error"]))
	assert_true(str(mine["info"]["region_secret"]).length() > 0, "il segreto viene restituito")


## §10 CLAIM: create in one round, force in a later one, two Authority spent.
func test_claim_create_then_force() -> void:
	var no_authority: Dictionary = _do("ENT_LYRA", "CLAIM", {"mode": "CREATE", "domain": "ANCIENT"})
	assert_false(bool(no_authority["ok"]), "senza AUTHORITY non si rivendica")

	var created: Dictionary = _do("ENT_ALDRIC", "CLAIM", {"mode": "CREATE", "domain": "ANCIENT"})
	assert_true(bool(created["ok"]), "Aldric ha un Diritto di Corona: %s" % str(created["error"]))
	assert_eq((session.world["claims"] as Array).size(), 1, "il Claim esiste")

	var too_soon: Dictionary = _do(
		"ENT_ALDRIC", "CLAIM", {"mode": "FORCE", "tension_id": "TEN_AWAKENING"}
	)
	assert_false(bool(too_soon["ok"]), "non si forza nello stesso round in cui si rivendica")

	# A later round, one more Authority in hand, and a Tension worth forcing.
	session.world["round"] = 2
	session.world["tensions"]["TEN_AWAKENING"]["current_value"] = 4
	_do("ENT_ALDRIC", "ACQUIRE", {"family": "AUTHORITY"})
	var forced: Dictionary = _do(
		"ENT_ALDRIC", "CLAIM", {"mode": "FORCE", "tension_id": "TEN_AWAKENING"}
	)
	assert_true(bool(forced["ok"]), "ora si puo forzare: %s" % str(forced["error"]))
	assert_eq((session.world["claims"] as Array).size(), 0, "il Claim e stato consumato")
	assert_eq(
		str(session.world["forced_confluence"]["tension_id"]),
		"TEN_AWAKENING",
		"la Confluence forzata e in attesa di fine round"
	)
	assert_eq(
		str(session.world["forced_confluence"]["entity_id"]),
		"ENT_ALDRIC",
		"il proponente sara chi ha forzato"
	)


func test_claim_force_needs_a_tension_worth_forcing() -> void:
	_do("ENT_ALDRIC", "CLAIM", {"mode": "CREATE", "domain": "ANCIENT"})
	session.world["round"] = 2
	session.world["tensions"]["TEN_AWAKENING"]["current_value"] = 2
	_do("ENT_ALDRIC", "ACQUIRE", {"family": "AUTHORITY"})
	var result: Dictionary = _do(
		"ENT_ALDRIC", "CLAIM", {"mode": "FORCE", "tension_id": "TEN_AWAKENING"}
	)
	assert_false(bool(result["ok"]), "sotto 3 la Tensione non si forza")


## A refused action must leave the world exactly as it was.
func test_a_refused_action_changes_nothing() -> void:
	var before: String = canonical(session.world)
	var result: Dictionary = _do("ENT_ALDRIC", "MOVE", {"region_id": "REG_MONTAGNE_ROSSE"})
	assert_false(bool(result["ok"]), "azione illegale")
	assert_eq(canonical(session.world), before, "nessun Effect e stato applicato")


## D-021: one INFLUENCE per Entity per round, across all Tensions.
func test_influence_is_capped_per_round() -> void:
	var cap: int = int(
		session.chronicle_def().get("influence_rules", {}).get("max_per_entity_per_round", 0)
	)
	assert_true(cap > 0, "la Chronicle I dichiara un cap")

	for i in range(cap):
		var allowed: Dictionary = _do(
			"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE"}
		)
		assert_true(bool(allowed["ok"]), "l'uso %d rientra nel limite: %s" % [i + 1, str(allowed["error"])])

	var refused: Dictionary = _do(
		"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE"}
	)
	assert_false(bool(refused["ok"]), "oltre il limite l'azione e rifiutata")

	# The cap is per Entity, not per table.
	var other: Dictionary = _do(
		"ENT_NAHR", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": -1, "via": "PRESENCE"}
	)
	assert_true(bool(other["ok"]), "un'altra Entita ha la sua quota: %s" % str(other["error"]))

	# And it covers every Tension, not one each.
	_do("ENT_LYRA", "SCHEME", {"mode": "TENSION", "tension_id": "TEN_AWAKENING"})
	assert_false(
		session.actions.can_execute(
			"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_AWAKENING", "delta": 1}
		),
		"il limite vale su tutte le Tensioni insieme"
	)


## The allowance is per round: a new round hands it back.
func test_influence_allowance_returns_next_round() -> void:
	_do("ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE"})
	assert_false(
		session.actions.can_execute(
			"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1}
		),
		"quota esaurita in questo round"
	)
	session.world["influence_used"] = {}
	assert_true(
		session.actions.can_execute(
			"ENT_ALDRIC", "INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1}
		),
		"nel round successivo si ricomincia"
	)


## check() must agree with execute(): a legality check that says yes to something
## execute refuses would make the 0.1 Action Dialog lie to the player.
func test_check_agrees_with_execute() -> void:
	var cases: Array = [
		["ACQUIRE", {"family": "AUTHORITY"}],
		["ACQUIRE", {"family": "GLORIA"}],
		["MOVE", {"region_id": "REG_STRADA_MERCANTI"}],
		["MOVE", {"region_id": "REG_MONTAGNE_ROSSE"}],
		["INFLUENCE", {"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE"}],
		["INFLUENCE", {"tension_id": "TEN_AWAKENING", "delta": 1}],
		["FORGE", {"target_entity_id": "ENT_NAHR", "direction": "DOWN"}],
		["FORGE", {"target_entity_id": "ENT_NAHR", "direction": "UP"}],
		["SCHEME", {"mode": "REGION", "region_id": "REG_EREDAN"}],
		["SCHEME", {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}],
		["CLAIM", {"mode": "CREATE", "domain": "ANCIENT"}],
		["CLAIM", {"mode": "FORCE", "tension_id": "TEN_AWAKENING"}],
	]
	for case in cases:
		var template: String = str(case[0])
		var params: Dictionary = case[1]
		var predicted: bool = session.actions.can_execute("ENT_ALDRIC", template, params)
		var actual: Dictionary = _do("ENT_ALDRIC", template, params)
		assert_eq(
			bool(actual["ok"]),
			predicted,
			"check() e execute() concordano su %s %s (%s)" % [template, params, str(actual["error"])]
		)
