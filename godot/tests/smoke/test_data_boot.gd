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
	var loaded: RefCounted = shipped_data()
	# Shared by every saga: the rules, the cards you can hold, and the land.
	assert_eq(loaded.assets.size(), 48, "48 Asset, 8 per famiglia: il traguardo §19.4 (D-040)")
	# Dieci da 0.1.227 (D-265): le sei di sempre piu' le quattro tessere di
	# PZ-2 — porto, palude, isola, bosco — con i domini bilanciati a 5/5/5/5.
	assert_eq(loaded.regions.size(), 10, "10 tessere in scatola: le sei di sempre piu' le quattro di PZ-2")
	assert_eq(loaded.actions.size(), 6, "i sei template di azione")

	# Un setup solo (D-213). Fino a 0.1.181 questa prova contava «due saghe»
	# con due biblioteche separate, e contarle separate **era** la voce: due
	# tavoli scritti a mano sono due giochi che non si incontrano mai.
	#
	# **Uno da 0.1.281** (D-318): gli anni d'autore sono stati cancellati. Ne
	# resta uno — la Prima Chronicle, che non ha uno scenario, pesca le tessere
	# della mappa e apparecchia da sola — e prosegue **se stessa**, cosi' una
	# saga e' una catena di anni pescati invece di due storie scritte.
	assert_eq(loaded.chronicles.size(), 1, "un anno solo, e si pesca")
	assert_true(loaded.chronicles.has("CHR_00"), "CHR_00 esiste")

	# La Chronicle pesca dalla **biblioteca intera** — 60 Tensioni, 10 per Tema
	# — che e' la metafora di D-028 portata fino in fondo: le domande sono
	# biblioteca, la Chronicle e' la mano. Prima di D-318 gli anni d'autore ne
	# vedevano dodici, e la prova contava quelle.
	_library_is_shared(loaded, ["CHR_00"], 60, 8)
	assert_eq(loaded.tensions.size(), 60, "60 Tensioni in biblioteca, 10 per Tema (D-265)")
	var drawn_pool: Array = (
		(loaded.chronicles["CHR_00"]["tension_pool"] as Dictionary)["candidates"] as Array
	)
	assert_eq(drawn_pool.size(), 60, "la Prima Chronicle pesca da tutta la biblioteca")
	var per_theme: Dictionary = {}
	for tension_id in loaded.tensions:
		var theme: String = str((loaded.tensions[str(tension_id)] as Dictionary).get("theme", ""))
		per_theme[theme] = int(per_theme.get(theme, 0)) + 1
	for theme_id in loaded.themes:
		assert_eq(int(per_theme.get(str(theme_id), 0)), 10,
			"%s ha dieci Tensioni: parola del committente (D-265)" % [str(theme_id)])
	# Quindici da 0.1.189: i tre nuovi sono **contesi** (D-221), cioe' li puo'
	# prendere un seggio alla volta. Prima era uno su dodici, e un tavolo di
	# quattro solitari non e' un tavolo.
	#
	# Sedici da 0.1.217: «Qualcosa Deve Rompersi» e' il primo obiettivo del mazzo
	# che chiede una Tensione alta, cioe' il primo che chiede **INFLUENZARE** —
	# il verbo che i seggi volevano dire nel 79% delle intenzioni mute e che
	# nessuna clausola chiedeva ([D-255](DECISIONS.md#d-255)).
	assert_eq(loaded.objectives.size(), 17, "17 obiettivi, pescati dallo stesso mazzo da tutti")


## Cosa c'e' in biblioteca, e che **e' la stessa per ogni anno**. Contarlo per
## Chronicle direbbe soltanto quante righe ha un file; contarlo cosi' dice la
## cosa che la voce chiedeva: nessun anno pesca da un mazzo suo.
func _library_is_shared(
	loaded: RefCounted, chronicle_ids: Array, tensions: int, seats: int
) -> void:
	var first_questions: Array = []
	var first_table: Array = []
	for chronicle_id in chronicle_ids:
		var chronicle: Dictionary = loaded.chronicles[str(chronicle_id)]
		var questions: Array = (
			(chronicle["tension_pool"] as Dictionary)["candidates"] as Array
		).duplicate()
		var table: Array = (
			(chronicle["entity_pool"] as Dictionary)["candidates"] as Array
		).duplicate()
		questions.sort()
		table.sort()
		if first_questions.is_empty():
			first_questions = questions
			first_table = table
		assert_eq(
			questions, first_questions,
			"%s pesca le domande dalla stessa biblioteca" % chronicle_id
		)
		assert_eq(
			table, first_table, "%s apparecchia dalle stesse case" % chronicle_id
		)
	assert_eq(first_questions.size(), tensions, "%d domande in biblioteca" % tensions)
	assert_eq(first_table.size(), seats, "%d case pescabili" % seats)
	# E ogni casa pescabile deve sapere cosa vuole, altrimenti un seme la
	# siederebbe senza Destino.
	for entity_id in first_table:
		var definition: Dictionary = loaded.entities[str(entity_id)]
		var pool: Array = definition.get("destiny_pool", [str(definition["destiny_id"])])
		assert_false(pool.is_empty(), "%s ha almeno un Destino" % entity_id)
		for destiny_id in pool:
			assert_true(
				loaded.destinies.has(str(destiny_id)),
				"il Destino %s di %s esiste" % [destiny_id, entity_id]
			)


## §19.4: eight cards per family, and the same curve in each - four at 1, two at
## 2, two at 3. A family with a different shape is a family that plays a
## different game, and ACQUIRE gives no way to tell which one you are drawing
## from until it is too late.
##
## The curve is not decoration either: it is what keeps a prepared hand worth
## about four points instead of six, which is the difference between "passa" and
## "passa senza discussione" (D-040).
func test_every_family_has_the_same_curve() -> void:
	var loaded: RefCounted = shipped_data()
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
	var loaded: RefCounted = shipped_data()
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
	var loaded: RefCounted = shipped_data()
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
	var loaded: RefCounted = shipped_data()
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
	var chronicle: Dictionary = data().chronicles["CHR_00"]
	assert_eq(int(chronicle["acts"]), 3, "3 Atti")
	assert_eq(int(chronicle["rounds_per_act"]), 3, "3 round per Atto")
	assert_eq(int(chronicle["action_opportunities_per_round"]), 2, "2 AO per round")
	assert_eq(int(chronicle["hand_limit"]), 7, "limite di mano 7")
	assert_eq(
		int(chronicle["presence_tokens"]), 5,
		"5 token presenza (D-227: tre di riserva — D-211 non aveva scelto «quattro», aveva scelto «tre affama la mappa»)"
	)
	assert_eq(int(chronicle["max_commit_assets"]), 3, "massimo 3 Asset impegnati")
	assert_eq(int(chronicle["max_condition_commit_assets"]), 2, "massimo 2 per una Condition")

	# Da D-207 CHR_01 pesca le sue domande, quindi non puo' piu' scrivere un
	# sacchetto per nome: il sacchetto lo compone il motore sulla mano pescata.
	# Quello che resta vero, e che conta, e' che copra tutti i round.
	assert_false(
		chronicle.has("drift_distribution"),
		"una Chronicle che pesca non scrive il proprio sacchetto"
	)
	# **E qui serviva un mondo.** Questa prova non ne apriva nessuno, quindi
	# `session` era null e la riga sotto interrompeva la funzione: l'errore
	# finiva in un log, la suite restava verde, e la traccia di Drift non era
	# misurata da nessuno. Trovato guardando gli errori di script di una
	# esecuzione verde, che e' l'unico modo di trovarli.
	new_session()
	assert_eq(
		(session.world["drift_track"] as Array).size(), 9,
		"la traccia di Drift copre tutti i 9 round"
	)


## A Tension has to be able to reach its threshold at all, or the Confluence it
## guards could never open. Drift alone is not required: the Ripple of a linked
## Tension's Confluence counts too, which is exactly how TEN_AWAKENING is meant
## to become urgent (see docs/DECISIONS.md D-009).
## Il criterio forte - «sacchetto piu' Ripple bastano da soli ad arrivare a
## soglia» - **era vero di una Chronicle sola**, quella scritta a mano, e questo
## test guardava solo quella. Misurato su tutta la biblioteca (0.1.175): la
## Febbre Bassa, i Pozzi Bassi, il Risveglio, il Debito, la Reliquia e la Carta
## non ci arrivano, e non ci arrivavano gia' prima in CHR_02 e CHR_04. Non e'
## un difetto nuovo: e' che quelle domande salgono **per mano dei giocatori**,
## e da D-192 il calore lo pescano loro (`replaces_drift`), quindi il sacchetto
## non e' nemmeno in gioco.
##
## Resta vero, e va difeso, il difetto che questo test cercava davvero: una
## domanda che **niente al mondo puo' muovere**. Quella e' una scena senza
## leva, e valida in silenzio.
##
## Il numero vero - quante volte ogni domanda arriva davvero al Consiglio - sta
## in ISSUES 51, misurato invece che dedotto.
func test_every_tension_can_reach_its_threshold() -> void:
	var loaded: RefCounted = shipped_data()
	for chronicle_id in loaded.chronicles:
		var chronicle: Dictionary = loaded.chronicles[str(chronicle_id)]
		var rounds: int = int(chronicle["acts"]) * int(chronicle["rounds_per_act"])
		var pool: Dictionary = chronicle.get("tension_pool", {})
		var playing: Array = (chronicle.get("tensions", []) as Array).duplicate()
		var floor_chips: int = 0
		if not pool.is_empty():
			playing = (pool["candidates"] as Array).duplicate()
			# Il sacchetto della biblioteca gira round-robin sulle pescate: la
			# domanda meno servita ne prende `round / pescate`.
			floor_chips = rounds / int(pool["count"])
		else:
			var declared: Dictionary = {}
			for entry in chronicle.get("drift_distribution", []):
				declared[str(entry["tension_id"])] = int(entry["count"])
			floor_chips = -1  # per-domanda, letto sotto

		for tension_id in playing:
			var tension: Dictionary = loaded.tensions[str(tension_id)]
			var pushes: int = floor_chips
			if pushes < 0:
				pushes = 0
				for entry in chronicle.get("drift_distribution", []):
					if str(entry["tension_id"]) == str(tension_id):
						pushes = int(entry["count"])
			for template in loaded.confluence_templates.values():
				if (template["ripple"]["targets"] as Array).has(str(tension_id)):
					pushes += int(template["ripple"]["delta"])
			assert_true(
				pushes > 0,
				"%s in %s: niente al mondo la spinge — ne' sacchetto ne' Ripple"
				% [str(tension_id), str(chronicle_id)]
			)


## A Destiny clause nobody can ever make true.
##
## `DST_LYRA_TAUGHT` asked, in its Triumph, for `crystal_measured`,
## `petition_heard` and `parley_held` - **all three of them**. No Consequence in
## the game writes any of the three, and none is on the table at the start, so
## the scholars' second Destiny was not hard to win: it was impossible, and the
## measured saga duly reported that seat at MINIMUM ten Chronicles out of ten.
##
## Nothing caught it because a tag is just a string: it validates, it loads, it
## evaluates to false for ever. So this walks every Destiny clause that asks for
## a tag to be *present* and insists something in the world can put it there.
##
## Only `state_tag_present` is checked. A clause asking for a tag to be *absent*
## is a stake, not a goal - it is true until someone breaks it, and a tag nothing
## writes simply makes it a stake nobody can take.
func test_no_destiny_asks_for_a_tag_nothing_can_write() -> void:
	var loaded: RefCounted = shipped_data()

	var writable: Dictionary = {}
	for consequence in loaded.consequences.values():
		for effect in consequence["effects"]:
			if not str(effect["type"]).begins_with("SET_"):
				continue
			var tag: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
			if tag != "":
				writable[tag] = str(consequence["id"])
	# An Echo card can write one too, and so can the opening position.
	for card in loaded.echo_cards.values():
		for effect in card.get("effects", []):
			var tag: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
			if str(effect["type"]).begins_with("SET_") and tag != "":
				writable[tag] = str(card["id"])
	for region in loaded.regions.values():
		for tag in region["tags"]:
			writable[str(tag)] = str(region["id"])
	for chronicle in loaded.chronicles.values():
		for tag in chronicle.get("global_tags", []):
			writable[str(tag)] = str(chronicle["id"])
	# Il motore scrive anche (due mani sue): i conti d'era posano i segni
	# delle loro catene (D-133), e il tempo sbiadisce in `legend:<fatto>`
	# ogni fatto scrivibile che almeno una Chronicle non dichiara perenne
	# (D-075) - la leggenda del Cristallo e' un obiettivo raggiungibile,
	# quella del sigillo perenne no.
	for chronicle in loaded.chronicles.values():
		for tally in chronicle.get("era_tallies", []):
			for sign in (tally as Dictionary)["chain"]:
				writable[str(sign)] = str((tally as Dictionary)["id"])
	# **E le due bocche che questa guardia non conosceva** (D-383).
	#
	# La lista sopra e' cresciuta una penna per volta e si era fermata prima di
	# due che il tavolo usa eccome:
	#
	# - **le caselle della carta Tensione** (D-280): IL MONDO RICORDA posa un
	#   segno globale, AGGIUNGI CONDIZIONE e CICATRICE ne posano uno sul luogo.
	#   `knowledge_shared` esce da tre caselle e si scrive **145 volte** su cento
	#   partite, e questa guardia lo dava per non scrivibile;
	# - **i gradi delle Pietre**: una Pietra alzata posa il segno del suo grado,
	#   ed e' cosi' che nascono `settlement:village` e `structure:archive` — 42 e
	#   43 scritture su cento partite.
	#
	# Una guardia che modella il motore **meno generoso di com'e'** non protegge
	# da niente: vieta una clausola vera. E' lo stesso difetto di D-376 visto
	# dall'altra faccia.
	for tension in loaded.tensions.values():
		var face: Dictionary = (tension as Dictionary).get("physical", {}) as Dictionary
		for list_name in ["benefits", "costs", "failure"]:
			for voice in (face.get(list_name, []) as Array):
				var tag: String = str((voice as Dictionary).get("tag", ""))
				if tag != "":
					writable[tag] = str((tension as Dictionary)["id"])
	for structure in loaded.structure_types.values():
		for grade in ((structure as Dictionary).get("grades", []) as Array):
			var tag: String = str((grade as Dictionary).get("tag", ""))
			if tag != "":
				writable[tag] = str((structure as Dictionary)["id"])
	for tag in writable.keys().duplicate():
		var fact: String = str(tag)
		if fact.begins_with("legend:") or fact.begins_with("function:"):
			continue
		for chronicle in loaded.chronicles.values():
			if not (chronicle.get("enduring_facts", []) as Array).has(fact):
				writable["legend:%s" % fact] = "il tempo (D-075)"
				break

	for destiny in loaded.destinies.values():
		for level in ["minimum", "victory", "triumph"]:
			for condition in _flattened(destiny[level]["conditions"]):
				if str((condition as Dictionary).get("type", "")) != "state_tag_present":
					continue
				var tag: String = str((condition as Dictionary)["tag"])
				assert_true(
					writable.has(tag),
					"%s/%s chiede '%s', che niente al mondo puo scrivere"
					% [str(destiny["id"]), level, tag]
				)


## Conditions can nest inside `any_of` / `some_of` / `all_of`, and the one that
## mattered here was nested: two of the three unreachable tags were inside an
## `any_of`. Da D-167 le scelte dei Trionfi sono `some_of`, e una clausola
## dentro una scelta e' esattamente dove un tag irraggiungibile si nasconde.
func _flattened(conditions: Array) -> Array:
	var out: Array = []
	for condition in conditions:
		var kind: String = str((condition as Dictionary).get("type", ""))
		if kind == "any_of" or kind == "some_of" or kind == "all_of":
			out.append_array(_flattened((condition as Dictionary)["conditions"]))
		else:
			out.append(condition)
	return out


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
	assert_eq(SchemaDefs.EFFECT_TYPES.size(), 29, "l'enum EffectType chiuso ha 29 voci")


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
