extends "res://tests/test_case.gd"
## Il pool degli obiettivi (D-197), misurato prima di essere scritto.
##
## Il committente ha chiuso la domanda dei gradini: «gli obiettivi sostituiscono
## i gradini, se si ottengono tutti e 4 e' un trionfo, se non se ne raggiunge
## nessuno e' un none». Con quattro obiettivi per seggio e uno solo palese, il
## pool nascosto e' il posto dove il gioco si decide — e un pool scritto male
## non fa rumore: un obiettivo che non si avvera mai assomiglia in tutto e per
## tutto a un obiettivo difficile.
##
## Quindi qui si prova quello che un occhio non vede: che il pool sia grande
## abbastanza per pescarne tre senza svuotarlo, che ogni obiettivo si possa
## giurare a **qualunque** tavolo, e che ogni clausola sia una che il motore sa
## davvero valutare. I tassi (dal 10,2% al 79,0% su 100 Chronicle) stanno nella
## sonda `run_objective_probe.gd`, non qui: un test non e' il posto dove si
## misura una probabilita'.

const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")

## Il vocabolario che ConditionEvaluator sa valutare (§14). Un obiettivo scritto
## con un predicato fuori da questa lista fa `push_warning` e torna false: si
## comporterebbe come un obiettivo impossibile, in silenzio.
const KNOWN: Array = [
	"control_count", "state_tag_present", "state_tag_absent", "asset_threshold",
	"entity_alive", "relation_state", "tension_limit", "discovery_count",
	"region_presence", "promise_kept", "promise_broken", "structure_count",
	"scar_count", "any_of", "some_of", "leads_in", "tension_count",
]


func before_each() -> void:
	new_session()


## Tre pescate su un pool di sei sarebbero mezzo pool ogni partita, e il draft
## non sceglierebbe niente. Dodici e' il numero misurato in D-197.
func test_the_pool_is_large_enough_to_draw_three_from() -> void:
	assert_true(
		data().objectives.size() >= 12,
		"il pool ha almeno 12 obiettivi (ne ha %d)" % [data().objectives.size()]
	)


## Un obiettivo del pool lo pesca chiunque, in qualunque Chronicle. Se nomina
## una casa, una Regione o una Tensione, nel mondo del Sale e' falso per
## costruzione — e nessuno se ne accorge.
func test_every_objective_can_be_sworn_by_anyone() -> void:
	for objective_id in data().objectives:
		var objective: Dictionary = data().objectives[str(objective_id)]
		for condition in objective["conditions"]:
			_no_local_names(condition as Dictionary, str(objective_id))


## Ogni clausola dev'essere una che il motore sa valutare: un predicato scritto
## male non e' un errore, e' un obiettivo che non si avvera mai.
func test_every_clause_is_one_the_engine_knows() -> void:
	for objective_id in data().objectives:
		var objective: Dictionary = data().objectives[str(objective_id)]
		for condition in objective["conditions"]:
			_known_predicate(condition as Dictionary, str(objective_id))


## E che si valuti davvero, su un seggio vero, senza esplodere: la prova che il
## pool e il motore parlano la stessa lingua.
func test_the_pool_evaluates_on_a_real_seat() -> void:
	var conditions: RefCounted = ConditionEvaluator.new(session.world, data())
	var context: Dictionary = {"self": "ENT_ALDRIC"}
	var answered: int = 0
	for objective_id in data().objectives:
		var objective: Dictionary = data().objectives[str(objective_id)]
		var holds: bool = conditions.all_hold(objective["conditions"], context)
		# All'apertura la casa esiste e non ha ancora fatto niente: quello che
		# conta e' che la domanda abbia una risposta, non quale sia.
		assert_true(holds or not holds, "«%s» si valuta" % [str(objective["title"])])
		answered += 1
	assert_eq(answered, data().objectives.size(), "tutti gli obiettivi rispondono")


## Ogni obiettivo porta la riga che andra' a verbale: senza, a fine anno il
## foglio direbbe «obiettivo raggiunto» e basta.
func test_every_objective_says_what_it_means() -> void:
	for objective_id in data().objectives:
		var objective: Dictionary = data().objectives[str(objective_id)]
		assert_true(str(objective_id).begins_with("OBJ_"), "%s e' un obiettivo" % [objective_id])
		assert_false(str(objective["label"]).is_empty(), "%s ha la riga a verbale" % [objective_id])
		assert_false(str(objective["title"]).is_empty(), "%s ha un titolo" % [objective_id])


func _no_local_names(condition: Dictionary, objective_id: String) -> void:
	if condition.has("entity_id"):
		assert_eq(
			str(condition["entity_id"]), "$self",
			"%s: una clausola del pool si risolve su chi la pesca" % [objective_id]
		)
	for key in ["region_id", "tension_id", "other_entity_id"]:
		# `$any` non nomina nessuno: e' la forma generica che lascia a un
		# obiettivo condiviso di chiedere un'alleanza senza sapere con chi
		# ([D-255](DECISIONS.md#d-255)). Ogni altro nome resta vietato.
		if key == "other_entity_id" and str(condition.get(key, "")) == "$any":
			continue
		# E per le Regioni la stessa forma ([D-315](DECISIONS.md#d-315)):
		# `$any` guarda tutta la mappa, `$rival` solo le terre che tiene un
		# altro. Senza di loro **nessun** obiettivo del pool puo' chiedere un
		# segno di Regione, e i segni di Regione temuti restano voluti da
		# nessuno.
		if key == "region_id" and ["$any", "$rival"].has(str(condition.get(key, ""))):
			continue
		assert_false(
			condition.has(key),
			"%s: la clausola nomina `%s`, che esiste in una Chronicle sola" % [objective_id, key]
		)
	for sub in condition.get("conditions", []):
		_no_local_names(sub as Dictionary, objective_id)


func _known_predicate(condition: Dictionary, objective_id: String) -> void:
	assert_true(
		KNOWN.has(str(condition.get("type", ""))),
		"%s: «%s» e' un predicato che il motore conosce" % [
			objective_id, str(condition.get("type", ""))
		]
	)
	for sub in condition.get("conditions", []):
		_known_predicate(sub as Dictionary, objective_id)


## Un obiettivo conteso non si puo' spartire, ed e' l'unica cosa che lo rende
## conteso ([D-221](DECISIONS.md#d-221)).
##
## Su dodici obiettivi **uno solo** metteva due case l'una contro l'altra: gli
## altri contavano roba propria, quindi quattro seggi potevano soddisfarli tutti
## e quattro senza mai toccarsi. Questa prova chiede la cosa che la parola
## «conteso» vuol dire: **al massimo un seggio alla volta**.
func test_a_contested_objective_can_be_taken_by_one_seat_at_a_time() -> void:
	var conditions: RefCounted = ConditionEvaluator.new(session.world, data())
	var contested: Array = []
	for objective_id in data().objectives:
		var objective: Dictionary = data().objectives[str(objective_id)]
		for condition in objective["conditions"]:
			if str((condition as Dictionary).get("type", "")) == "leads_in":
				contested.append(objective)
				break
	assert_true(contested.size() >= 3, "il pool porta obiettivi contesi: %d" % contested.size())

	# Si sporca il tavolo perche' la domanda non sia vuota: se nessuno ha
	# niente, «piu' di tutti» e' falso per tutti e la prova non proverebbe.
	var effect: GDScript = load("res://scripts/core/effect.gd")
	session.applier.apply(effect.make(
		"ADD_PRESENCE", "entity", "ENT_ALDRIC", {"region_id": "REG_VALLE_VERDE"},
		effect.source("system", "TEST", "", 1, 1, 0)
	))
	session.applier.apply(effect.make(
		"BUILD_STRUCTURE", "region", "REG_VALLE_VERDE",
		{"structure_type": "STR_KEEP", "grade": 1, "owner": "ENT_ALDRIC"},
		effect.source("system", "TEST", "", 1, 1, 0)
	))

	for objective in contested:
		var takers: Array = []
		for entity_id in session.world["entities"]:
			if conditions.all_hold(objective["conditions"], {"self": str(entity_id)}):
				takers.append(str(entity_id))
		assert_true(
			takers.size() <= 1,
			"«%s» lo prende al massimo uno: %s" % [
				str(objective["title"]), ", ".join(PackedStringArray(takers))
			]
		)
