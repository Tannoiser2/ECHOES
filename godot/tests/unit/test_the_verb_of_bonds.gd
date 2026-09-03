extends "res://tests/test_case.gd"
## Il verbo dei rapporti in «SI ACCENDE QUANDO» (D-430 — ISSUES 100).
##
## I verbi della casella erano sei, e guardavano tutti la **mappa**: un segno
## posato o tolto, una Pietra costruita, il controllo che cambia, una Presenza
## che arriva o se ne va. `SET_RELATION` esce **159 volte su vent'anni** e non
## c'era modo di nominarlo — quindi le tredici Tensioni che parlano di rapporti
## (*I Voti Non Sciolti*, *Il Diritto d'Asilo*, *La Vecchia Guardia*, *I Nomi
## Vecchi*) restavano **senza casella**: la carta non poteva dire perche' si
## scalda.
##
## Qui si prova il verbo, non i dati: le righe sono **fabbricate**, cosi' la
## prova regge anche il giorno che una Tensione cambia faccia.

const Effect := preload("res://scripts/core/effect.gd")


func before_each() -> void:
	new_session()


func _relation_effect(level: String) -> Dictionary:
	return {
		"type": "SET_RELATION",
		"target": {"id": "ENT_ALDRIC|ENT_LYRA"},
		"payload": {"level": level},
	}


## **Il verbo si accende su un cambio di rapporto.** Senza filtro, ogni livello
## d'arrivo va bene: e' la riga di *Le Staffette* — «due case cambiano il patto
## che le lega».
func test_the_verb_wakes_on_any_change_of_bond() -> void:
	var rule: Dictionary = {"text": "prova", "changes_relation": true}
	assert_true(
		session.actions._rule_matches(rule, [_relation_effect("ALLY")]),
		"un rapporto che sale accende la riga"
	)
	assert_true(
		session.actions._rule_matches(rule, [_relation_effect("ENEMY")]),
		"e anche uno che scende"
	)


## **E il filtro guarda il livello d'arrivo.** *Il Diritto d'Asilo* si scalda
## quando due case **si legano**, non quando rompono: la riga chiede ALLY o
## BOUND e su ENEMY resta fredda.
func test_the_filter_looks_at_where_the_bond_lands() -> void:
	var rule: Dictionary = {
		"text": "prova",
		"changes_relation": true,
		"relation_becomes": ["ALLY", "BOUND"],
	}
	assert_true(
		session.actions._rule_matches(rule, [_relation_effect("BOUND")]),
		"il legame che arriva al sangue accende"
	)
	assert_false(
		session.actions._rule_matches(rule, [_relation_effect("ENEMY")]),
		"la rottura no"
	)


## **Il verbo non si accende su altro.** Una Presenza che arriva non e' un
## patto: se questa riga si accendesse su tutto, la carta direbbe una cosa e ne
## farebbe un'altra.
func test_the_verb_does_not_wake_on_a_gesture_on_the_map() -> void:
	var rule: Dictionary = {"text": "prova", "changes_relation": true}
	assert_false(
		session.actions._rule_matches(rule, [{
			"type": "ADD_PRESENCE",
			"target": {"id": "ENT_ALDRIC"},
			"payload": {"region_id": "REG_EREDAN"},
		}]),
		"una Presenza non e' un rapporto"
	)


## **E una riga che non dice nessun verbo resta spenta**, anche col filtro del
## livello: e' la coppia che la guardia dei dati rifiuta, e qui si vede perche'
## — il motore la scarta, e al tavolo sembrerebbe una regola.
func test_a_level_filter_alone_stays_cold() -> void:
	assert_false(
		session.actions._rule_matches(
			{"text": "prova", "relation_becomes": ["ALLY"]},
			[_relation_effect("ALLY")]
		),
		"senza il verbo la riga non si accende"
	)


## **Le tredici hanno la loro casella.** Era il «fatto quando» della voce: nessuna
## Tensione resta senza la riga che dice quando si scalda.
func test_every_tension_now_says_when_it_heats() -> void:
	var senza: Array = []
	for tension_id in session.data.tensions:
		var card: Dictionary = session.data.tensions[tension_id] as Dictionary
		if (card.get("heats_when", []) as Array).is_empty():
			senza.append(str(tension_id))
	assert_eq(
		senza.size(), 0,
		"ogni Tensione ha la sua casella (senza: %s)" % ", ".join(PackedStringArray(senza))
	)
