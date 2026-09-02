extends "res://tests/test_case.gd"
## Le clausole mirano per segni, non per nome ([D-327](DECISIONS.md#d-327)).
##
## Da [D-265](DECISIONS.md#d-265) la mappa si pesca sei tessere su dieci, e
## [D-326](DECISIONS.md#d-326) ha misurato il prezzo: **il 43.1% delle righe dei
## Destini nominava una terra che quell'anno non usciva**. Una riga che nasce
## morta non e' una regola, e' inchiostro.
##
## Adesso una riga dice `any_tag`, e vuol dire «una terra che porta uno di questi
## segni». Al tavolo si guardano le tessere col segno stampato.
##
## Le tre letture da provare, perche' sono tre e non una:
##
##   · **presenza** — vera se c'e' una terra cosi' dove il conto torna. Non la
##     somma: «presidiata» vuol dire due pedine nello stesso posto;
##   · **il segno del luogo** — `state_tag_present` vera se **una** terra cosi'
##     ce l'ha, quindi `state_tag_absent` vuol dire «nessuna di quelle»;
##   · **le Cicatrici** — contate su tutte le terre cosi'.

const Effect := preload("res://scripts/core/effect.gd")

const SEATS: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]


func _sign_of_first_region() -> Array:
	var first: String = str((session.world["regions"] as Dictionary).keys()[0])
	var tags: Array = session.data.regions[first]["tags"] as Array
	return [first, str(tags[0])]


## Una riga a segni trova il suo posto: la presenza si conta sulla terra che
## porta il segno, esattamente come se l'avesse nominata.
func test_presence_finds_the_place_by_its_sign() -> void:
	new_session()
	var pair: Array = _sign_of_first_region()
	var where: String = str(pair[0])
	var sign: String = str(pair[1])
	var seat: String = SEATS[0]
	var before: int = session.service.presence_count(seat, where)
	var clause: Dictionary = {
		"type": "region_presence", "entity_id": seat,
		"any_tag": [sign], "min": before + 1,
	}
	assert_false(
		session.destinies.conditions.holds(clause, {"self": seat}),
		"prima di posare, la riga non e' vera"
	)
	session.applier.apply(Effect.make(
		"ADD_PRESENCE", "entity", seat, {"region_id": where},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_true(
		session.destinies.conditions.holds(clause, {"self": seat}),
		"posata la pedina sulla terra col segno «%s», la riga e' vera" % sign
	)


## Un segno che nessuna tessera pescata porta non e' una riga vera per sbaglio:
## e' falsa, e basta. Serve a provare che il motore non stia dicendo si' a caso.
func test_a_sign_no_tile_carries_is_simply_false() -> void:
	new_session()
	var clause: Dictionary = {
		"type": "region_presence", "entity_id": SEATS[0],
		"any_tag": ["segno_che_non_esiste"], "min": 1,
	}
	assert_false(
		session.destinies.conditions.holds(clause, {"self": SEATS[0]}),
		"nessuna tessera porta quel segno: la riga e' falsa"
	)


## Il segno del luogo: `absent` vuol dire **nessuna** delle terre cosi'.
func test_absent_means_none_of_those_places() -> void:
	new_session()
	var pair: Array = _sign_of_first_region()
	var where: String = str(pair[0])
	var sign: String = str(pair[1])
	var absent: Dictionary = {
		"type": "state_tag_absent", "scope": "REGION",
		"any_tag": [sign], "tag": "condition:unrest",
	}
	assert_true(
		session.destinies.conditions.holds(absent, {}),
		"all'apertura nessuna di quelle terre e' in rivolta"
	)
	session.applier.apply(Effect.make(
		"SET_REGION_TAG", "region", where, {"tag": "condition:unrest"},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_false(
		session.destinies.conditions.holds(absent, {}),
		"basta che **una** terra col segno «%s» sia in rivolta" % sign
	)


## Le Cicatrici si contano su tutte le terre che portano il segno.
func test_scars_are_counted_on_every_place_with_the_sign() -> void:
	new_session()
	var pair: Array = _sign_of_first_region()
	var where: String = str(pair[0])
	var sign: String = str(pair[1])
	var clean: Dictionary = {"type": "scar_count", "any_tag": [sign], "max": 0}
	assert_true(
		session.destinies.conditions.holds(clean, {}),
		"all'apertura quelle terre non portano Cicatrici"
	)
	session.applier.apply(Effect.make(
		"ADD_SCAR", "region", where,
		{"tag": "scar:open_wound", "region_id": where},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_false(
		session.destinies.conditions.holds(clean, {}),
		"una Cicatrice su una terra col segno «%s» rompe la riga" % sign
	)


## E la promessa che il validatore fa: **nessuna clausola spedita nomina una
## Regione per nome**. Se ne ricompare una, la mappa pescata puo' non averla.
func test_no_shipped_clause_names_a_region_by_name() -> void:
	var checked: int = 0
	for source in [shipped_data().destinies, shipped_data().objectives]:
		for item_id in (source as Dictionary):
			for clause in _clauses_of((source as Dictionary)[item_id]):
				var named: String = str((clause as Dictionary).get("region_id", ""))
				assert_true(
					named == "" or named.begins_with("$"),
					"%s nomina %s per nome: su una mappa pescata puo' non esserci"
						% [str(item_id), named]
				)
				checked += 1
	assert_true(checked > 0, "la prova ha guardato almeno una clausola")


func _clauses_of(item: Variant) -> Array:
	var out: Array = []
	_walk(item, out)
	return out


func _walk(item: Variant, out: Array) -> void:
	if item is Dictionary:
		var d: Dictionary = item as Dictionary
		if d.has("type"):
			out.append(d)
		for key in d:
			_walk(d[key], out)
	elif item is Array:
		for value in (item as Array):
			_walk(value, out)


## **E un conto puo' contare per segni** ([D-413](DECISIONS.md#d-413), ISSUES
## 120). Le due clausole di conteggio che stavano fuori da D-327 — quante terre
## tieni e quante Pietre hai in piedi — adesso leggono `any_tag` come le altre
## tre: **si contano solo quelle terre**.
##
## E' la differenza fra un obiettivo che si verifica facendo un totale a mente e
## uno che si verifica **guardando la mappa**. Erano otto obiettivi su
## diciassette a reggersi su un totale; adesso e' uno.
func test_a_count_can_count_by_signs() -> void:
	new_session()
	var seat: String = SEATS[0]
	# **Fabbricato, non cercato**: la casa tiene *tutte* le terre, cosi' il conto
	# per segni e' l'unica cosa che puo' fare la differenza fra le due letture.
	var marked: String = ""
	var sign: String = ""
	var all_regions: Array = (session.world["regions"] as Dictionary).keys()
	for region_id in all_regions:
		(session.world["regions"][str(region_id)] as Dictionary)["control"] = seat
	var pair: Array = _sign_of_first_region()
	marked = str(pair[0])
	sign = str(pair[1])

	var counted_everywhere: Dictionary = {
		"type": "control_count", "entity_id": "$self", "min": all_regions.size(),
	}
	var counted_by_sign: Dictionary = {
		"type": "control_count", "entity_id": "$self", "min": 1, "any_tag": [sign],
	}
	var context: Dictionary = {"self": seat}
	assert_true(
		session.destinies.conditions.holds(counted_everywhere, context),
		"tiene tutte e %d le terre" % all_regions.size()
	)
	assert_true(
		session.destinies.conditions.holds(counted_by_sign, context),
		"e ne tiene almeno una col segno «%s»" % sign
	)

	# E il conto per segni **non e'** il conto di tutte: se lo fosse, questa
	# riga passerebbe lo stesso e la prova non misurerebbe niente.
	var too_many: Dictionary = {
		"type": "control_count", "entity_id": "$self",
		"min": all_regions.size(), "any_tag": [sign],
	}
	var tiles_with_sign: int = 0
	for region_id in all_regions:
		if (session.data.regions[str(region_id)]["tags"] as Array).has(sign):
			tiles_with_sign += 1
	if tiles_with_sign < all_regions.size():
		assert_false(
			session.destinies.conditions.holds(too_many, context),
			"il conto per segni guarda %d tessere su %d, non tutte"
				% [tiles_with_sign, all_regions.size()]
		)

