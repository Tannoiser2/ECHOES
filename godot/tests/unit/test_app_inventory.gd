extends "res://tests/test_case.gd"
## L'inventario dell'app (ISSUES 22, su richiesta del committente): i Diritti
## si vedono nel pannello, e la mappa sa quale Regione un Effect ha toccato -
## la parte pura dell'eco del cambiamento, quella che una suite headless puo'
## inchiodare senza un mouse.

const MapView := preload("res://ui/map_view.gd")
const StatusPanel := preload("res://ui/status_panel.gd")
const Effect := preload("res://scripts/core/effect.gd")


func _apply(type: String, kind: String, id: String, payload: Dictionary) -> void:
	session.applier.apply(
		Effect.make(type, kind, id, payload, Effect.source("developer", "TEST", "", 1, 1, 0))
	)


## La mappa dei tipi sta in un posto solo, ed e' questa. Un no-op non accende
## niente: non e' cambiato nulla, e un'eco su un trono che non si e' mosso
## sarebbe la stessa bugia che D-121 ha tolto dal verbale.
func test_the_map_knows_which_region_an_effect_touched() -> void:
	assert_eq(
		MapView.region_of_effect({
			"type": "SET_CONTROL", "target": {"kind": "region", "id": "REG_EREDAN"},
			"payload": {"entity_id": "ENT_ALDRIC"}, "inverse_payload": {"entity_id": null},
		}),
		"REG_EREDAN", "il controllo tocca la sua Regione"
	)
	assert_eq(
		MapView.region_of_effect({
			"type": "ADD_PRESENCE", "target": {"kind": "entity", "id": "ENT_NAHR"},
			"payload": {"region_id": "REG_VALLE_VERDE"}, "inverse_payload": {},
		}),
		"REG_VALLE_VERDE", "la presenza tocca dove si posa, non chi la posa"
	)
	assert_eq(
		MapView.region_of_effect({
			"type": "SET_CONTROL", "target": {"kind": "region", "id": "REG_EREDAN"},
			"payload": {"entity_id": null}, "inverse_payload": {"entity_id": null, "noop": true},
		}),
		"", "un no-op non accende niente"
	)
	assert_eq(
		MapView.region_of_effect({
			"type": "ADJUST_TENSION", "target": {"kind": "tension", "id": "TEN_FAMINE"},
			"payload": {"delta": 1}, "inverse_payload": {"delta": -1},
		}),
		"", "una Tensione non abita un punto della mappa"
	)


## Un Diritto creato e' un fatto pubblico: il pannello lo dice, col dominio
## nella sua parola italiana e il nome di chi lo tiene.
func test_the_panel_shows_who_holds_a_claim() -> void:
	new_session()
	var viewer: String = str(session.world["turn_order"][0])
	_apply("CREATE_CLAIM", "claim", "CLM_TEST", {
		"claim_id": "CLM_TEST", "entity_id": viewer,
		"domain": "TERRITORY", "act": 2, "round": 1,
	})
	var panel: VBoxContainer = StatusPanel.new()
	panel.render(session, viewer)
	var said: String = _all_labels(panel)
	assert_true(said.contains("I DIRITTI"), "la sezione esiste quando un Diritto esiste")
	assert_true(said.contains("il territorio"), "il dominio parla italiano, non enum")
	assert_true(
		said.contains(session.service.name_of(viewer)),
		"e si legge chi lo tiene"
	)
	panel.free()


## Senza Diritti, niente intestazione: un titolo sopra il nulla e' rumore.
func test_without_claims_the_section_stays_out_of_the_way() -> void:
	new_session()
	var viewer: String = str(session.world["turn_order"][0])
	var panel: VBoxContainer = StatusPanel.new()
	panel.render(session, viewer)
	var found: Dictionary = {"claims_header_visible": false}
	_walk(panel, func(node: Node) -> void:
		if node is Label and str((node as Label).text) == "I DIRITTI" and (node as Label).visible:
			found["claims_header_visible"] = true
	)
	assert_false(bool(found["claims_header_visible"]), "l'intestazione resta nascosta")
	panel.free()


func _all_labels(root: Node) -> String:
	var out: Array = []
	_walk(root, func(node: Node) -> void:
		if node is Label and (node as Label).visible:
			out.append(str((node as Label).text))
	)
	return "\n".join(PackedStringArray(out))


func _walk(node: Node, visit: Callable) -> void:
	visit.call(node)
	for child in node.get_children():
		_walk(child, visit)
