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
	assert_eq(loaded.assets.size(), 12, "12 Asset (2 per famiglia)")
	assert_eq(loaded.regions.size(), 6, "6 Regioni: le 5 principali piu un raccordo")
	assert_eq(loaded.tensions.size(), 2, "2 Tensioni")
	assert_eq(loaded.confluence_templates.size(), 2, "2 template di Confluence")
	assert_eq(loaded.echo_cards.size(), 8, "8 carte Echo")
	assert_eq(loaded.consequences.size(), 8, "8 Conseguenze")
	assert_eq(loaded.entities.size(), 4, "4 Entita")
	assert_eq(loaded.destinies.size(), 4, "4 Destiny")
	assert_eq(loaded.actions.size(), 6, "i sei template di azione")


func test_every_family_has_one_of_each_strength() -> void:
	var loaded: RefCounted = data()
	for family in SchemaDefs.ASSET_FAMILIES:
		var strengths: Array = []
		for asset in loaded.assets_of_family(str(family)):
			strengths.append(int(asset["strength"]))
		strengths.sort()
		assert_eq(strengths, [1, 2], "la famiglia %s ha un Asset da 1 e uno da 2" % family)


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
	for entry in chronicle["drift_distribution"]:
		drift_by_tension[str(entry["tension_id"])] = int(entry["count"])

	for tension_id in chronicle["tensions"]:
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
