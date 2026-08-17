extends "res://tests/test_case.gd"
## D-107: ogni segno che i dati sanno scrivere ha una parola italiana nel
## dizionario condiviso - la stessa sulla mappa, nel pannello del seggio e sul
## segnalino di cartone. Un segno senza parola qui fallisce: e' il modo in cui
## un contenuto nuovo si ricorda di comprarsi il suo segnalino.

const SignLabels := preload("res://scripts/core/sign_labels.gd")


func before_each() -> void:
	new_session()


func _collect_written_tags() -> Dictionary:
	var found: Dictionary = {"region": {}, "entity": {}}
	var writers: Array = []
	for consequence_id in session.data.consequences:
		var consequence: Dictionary = session.data.consequences[consequence_id]
		writers.append(consequence.get("effects", []))
		var scar: Dictionary = consequence.get("scar", {})
		if not scar.is_empty():
			found["region"][str(scar.get("tag", ""))] = true
	for card_id in session.data.echo_cards:
		for hook in session.data.echo_cards[card_id].get("effect_hooks", []):
			if str(hook.get("kind", "")) == "EFFECT":
				writers.append([hook.get("effect", {})])
	for asset_id in session.data.assets:
		writers.append(session.data.assets[asset_id].get("on_commit_effects", []))
	for effects in writers:
		for effect in effects:
			var tag: String = str(effect.get("payload", {}).get("tag", ""))
			if tag == "":
				continue
			match str(effect.get("type", "")):
				"SET_REGION_TAG":
					found["region"][tag] = true
				"SET_ENTITY_TAG":
					found["entity"][tag] = true
	return found


func test_every_region_sign_in_data_has_a_word() -> void:
	var written: Dictionary = _collect_written_tags()
	assert_true(written["region"].size() > 20, "il censimento trova i segni di Regione")
	for tag in written["region"]:
		var clean: String = str(tag).replace("$proponent", "ENT_ALDRIC")
		assert_true(
			SignLabels.known(clean),
			"il segno di Regione '%s' ha la sua parola (D-107)" % tag
		)


func test_every_entity_sign_in_data_has_a_word() -> void:
	var written: Dictionary = _collect_written_tags()
	assert_true(written["entity"].size() > 10, "il censimento trova i segni di casa")
	for tag in written["entity"]:
		assert_true(
			SignLabels.known(str(tag)),
			"il segno di casa '%s' ha la sua parola (D-107)" % tag
		)


func test_words_are_italian_not_tag_suffixes() -> void:
	assert_eq(SignLabels.label("condition:cut_off"), "tagliata fuori", "la condizione parla")
	assert_eq(SignLabels.label("scar:unanswered"), "la domanda sul muro", "la Cicatrice parla")
	assert_eq(SignLabels.label("structure:granary"), "il granaio", "la struttura parla")
	assert_eq(SignLabels.label("renowned"), "la fama", "il segno di casa parla")
	assert_eq(
		SignLabels.label("evicted:REG_VALLE_VERDE", session.data),
		"cacciata da Valle Verde", "la cacciata nomina la Regione"
	)
	assert_eq(
		SignLabels.label("settlement:ENT_NAHR", session.data),
		"insediamento: Popolo Nahr", "l'insediamento nomina la casa"
	)