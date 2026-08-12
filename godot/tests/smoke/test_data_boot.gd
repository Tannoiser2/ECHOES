extends "res://tests/test_case.gd"
## Smoke: the data set loads and validates, and the scenes that exist can be
## instantiated (§18.3, §23).

# DataSet comes from test_case.gd; re-declaring it here would be a parse error.
const SchemaDefs := preload("res://scripts/core/schema_defs.gd")


func test_data_loads_and_validates() -> void:
	var loaded: RefCounted = DataSet.new()
	var ok: bool = loaded.load_from("res://data")
	assert_true(ok, "boot validation:\n%s" % loaded.describe_errors())
	assert_true(loaded.loaded_documents > 0, "almeno un documento caricato")


## §18.2: the reduced content the milestone actually asks for.
func test_reduced_content_matches_the_milestone() -> void:
	var loaded: RefCounted = data()
	assert_eq(loaded.assets.size(), 48, "48 Asset, 8 per famiglia: il traguardo §19.4 (D-040)")
	assert_eq(loaded.regions.size(), 6, "6 Regioni: le 5 principali piu un raccordo")
	# Grown past §18.2's reduced set on purpose, and measured: D-024 records why
	# 2 Tensions and 8 Consequences could not move the world enough to matter.
	assert_eq(loaded.tensions.size(), 6, "6 Tensioni in biblioteca (§18.2 ne chiedeva 2; vedi D-024, D-028)")
	assert_eq(loaded.confluence_templates.size(), 5, "5 Consigli, uno dei quali legato a un dominio")
	assert_eq(loaded.echo_cards.size(), 24, "24 carte Echo: una per ogni funzione di Propp (vedi D-024, D-031)")
	assert_eq(loaded.consequences.size(), 32, "32 Conseguenze (§18.2 ne chiedeva 8; vedi D-022, D-024)")
	assert_eq(loaded.chronicles.size(), 2, "CHR_01 scritta a mano, CHR_02 assemblata dalla biblioteca")
	assert_eq(loaded.entities.size(), 4, "4 Entita")
	assert_eq(loaded.destinies.size(), 4, "4 Destiny")
	assert_eq(loaded.actions.size(), 6, "i sei template di azione")


## §19.4: eight cards per family, and the same curve in each - four at 1, two at
## 2, two at 3. A family with a different shape is a family that plays a
## different game, and ACQUIRE gives no way to tell which one you are drawing
## from until it is too late.
##
## The curve is not decoration either: it is what keeps a prepared hand worth
## about four points instead of six, which is the difference between "passa" and
## "passa senza discussione" (D-040).
func test_every_family_has_the_same_curve() -> void:
	var loaded: RefCounted = data()
	for family in SchemaDefs.ASSET_FAMILIES:
		var strengths: Array = []
		for asset in loaded.assets_of_family(str(family)):
			strengths.append(int(asset["strength"]))
		strengths.sort()
		assert_eq(
			strengths, [1, 1, 1, 1, 2, 2, 3, 3],
			"la famiglia %s ha 8 carte: quattro da 1, due da 2, due da 3" % family
		)


## Every family can say no, and every family has one card that counts for more
## when the question is its own. Without the first a table can only ever push,
## which is what O-6 measured; without the second preparation is just drawing.
func test_every_family_can_refuse_and_has_a_card_of_its_own() -> void:
	var loaded: RefCounted = data()
	for family in SchemaDefs.ASSET_FAMILIES:
		var oppose: int = 0
		var relevant: int = 0
		for asset in loaded.assets_of_family(str(family)):
			match str(asset["confluence_modifier"]["kind"]):
				"OPPOSE_BONUS": oppose += 1
				"RELEVANT_BONUS": relevant += 1
		assert_true(oppose >= 2, "%s ha almeno due carte che pagano sul fronte Oppose" % family)
		assert_true(relevant >= 1, "%s ha almeno una carta che vale di piu sul suo tema" % family)


## The two strongest cards in a family are worth 6 in a relevant Tension, which
## is a whole Confluence on its own. Every one of them pays for it: it is spent
## whatever happens, and it does something to the world on the way out. Without
## that they are simply the correct play, and preparation stops being a choice.
func test_the_strongest_cards_all_cost_something() -> void:
	var loaded: RefCounted = data()
	var checked: int = 0
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[asset_id]
		if int(asset["strength"]) < 3:
			continue
		checked += 1
		assert_eq(
			str(asset["discard_or_retain_rule"]), "ALWAYS_DISCARD",
			"%s e da 3: si deve scartare comunque" % asset_id
		)
		assert_true(
			(asset.get("on_commit_effects", []) as Array).size() > 0,
			"%s e da 3: impegnarla deve costare qualcosa al mondo" % asset_id
		)
	assert_eq(checked, 12, "due carte da 3 per famiglia")


## Rarity is not decoration: one word fixes both how strong a card is and how
## many copies of it are in the deck. A player who has seen a family twice knows
## what the deck holds without a manual, and the deck arithmetic stops depending
## on 48 individual decisions.
func test_rarity_fixes_strength_and_copies() -> void:
	var copies: Dictionary = {"COMMON": 4, "UNCOMMON": 2, "RARE": 1}
	var strength: Dictionary = {"COMMON": 1, "UNCOMMON": 2, "RARE": 3}
	var loaded: RefCounted = data()
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[asset_id]
		var rarity: String = str(asset["rarity"])
		assert_eq(
			int(asset["deck_copies"]), int(copies[rarity]),
			"%s e %s: %d copie nel mazzo" % [asset_id, rarity, int(copies[rarity])]
		)
		assert_eq(
			int(asset["strength"]), int(strength[rarity]),
			"%s e %s: forza %d" % [asset_id, rarity, int(strength[rarity])]
		)


func test_chronicle_matches_the_baseline_numbers() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_01"]
	assert_eq(int(chronicle["acts"]), 3, "3 Atti")
	assert_eq(int(chronicle["rounds_per_act"]), 3, "3 round per Atto")
	assert_eq(int(chronicle["action_opportunities_per_round"]), 2, "2 AO per round")
	assert_eq(int(chronicle["hand_limit"]), 7, "limite di mano 7")
	assert_eq(int(chronicle["presence_tokens"]), 3, "3 token presenza")
	assert_eq(int(chronicle["max_commit_assets"]), 3, "massimo 3 Asset impegnati")
	assert_eq(int(chronicle["max_condition_commit_assets"]), 2, "massimo 2 per una Condition")

	var drift: int = 0
	for entry in chronicle["drift_distribution"]:
		drift += int(entry["count"])
	assert_eq(drift, 9, "la traccia di Drift copre tutti i 9 round")


## A Tension has to be able to reach its threshold at all, or the Confluence it
## guards could never open. Drift alone is not required: the Ripple of a linked
## Tension's Confluence counts too, which is exactly how TEN_AWAKENING is meant
## to become urgent (see docs/DECISIONS.md D-009).
func test_every_tension_can_reach_its_threshold() -> void:
	var loaded: RefCounted = data()
	var chronicle: Dictionary = loaded.chronicles["CHR_01"]
	var drift_by_tension: Dictionary = {}
	for entry in chronicle.get("drift_distribution", []):
		drift_by_tension[str(entry["tension_id"])] = int(entry["count"])

	for tension_id in chronicle.get("tensions", []):
		var tension: Dictionary = loaded.tensions[str(tension_id)]
		var reachable: int = int(tension["current_value"]) + int(drift_by_tension.get(tension_id, 0))
		# One Ripple per Confluence opened on a template that points here.
		for template in loaded.confluence_templates.values():
			if (template["ripple"]["targets"] as Array).has(str(tension_id)):
				reachable += int(template["ripple"]["delta"])
		assert_true(
			reachable >= int(tension["threshold"]),
			"%s: da %d, con Drift e Ripple, non arriva mai a %d"
			% [tension_id, int(tension["current_value"]), int(tension["threshold"])]
		)


func test_boot_scene_instantiates() -> void:
	var packed: Variant = load("res://scenes/boot/boot.tscn")
	assert_true(packed != null, "la scena di boot si carica")
	if packed == null:
		return
	var scene: Node = (packed as PackedScene).instantiate()
	assert_true(scene != null, "la scena di boot si istanzia")
	if scene != null:
		scene.free()


## The generated schema definitions must still describe the data we ship: this
## catches a schema_defs.gd that drifted from /schema without regeneration.
func test_generated_schema_covers_every_collection() -> void:
	for schema_id in SchemaDefs.COLLECTION_SCHEMA_IDS:
		assert_true(
			SchemaDefs.DEFS.has(str(schema_id)),
			"schema_defs.gd definisce '%s'" % schema_id
		)
	assert_eq(SchemaDefs.EFFECT_TYPES.size(), 22, "l'enum EffectType chiuso ha 22 voci")


## Every Echo-card hook has to compile to at least one Effect. A card whose
## Consequence uses a $variable the card cannot supply compiles to nothing and
## says so only in a push_error, so the card silently does nothing at the table -
## which is exactly what CNS_HARVEST_RETURNS and CNS_CROWN_DIVIDED did.
func test_every_echo_card_hook_compiles_to_something() -> void:
	new_session()
	var source: Dictionary = load("res://scripts/core/effect.gd").source(
		"echo_card", "TEST", "", 1, 1, 0
	)
	for card in data().echo_cards.values():
		for hook in card["effect_hooks"]:
			var bindings: Dictionary = session.chronicle.card_bindings(hook)
			if str(hook["kind"]) == "CONSEQUENCE":
				assert_false(
					session.compiler.compile(str(hook["consequence_id"]), bindings, source).is_empty(),
					"%s: la Consequence '%s' non compila in nessun Effect"
					% [str(card["id"]), str(hook["consequence_id"])]
				)
			else:
				assert_false(
					session.compiler.compile_spec(hook["effect"], bindings, source).is_empty(),
					"%s: un hook EFFECT non compila" % str(card["id"])
				)
