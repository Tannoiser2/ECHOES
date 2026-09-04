extends "res://tests/test_case.gd"
## D-107: ogni segno che i dati sanno scrivere ha una parola italiana nel
## dizionario condiviso - la stessa sulla mappa, nel pannello del seggio e sul
## segnalino di cartone. Un segno senza parola qui fallisce: e' il modo in cui
## un contenuto nuovo si ricorda di comprarsi il suo segnalino.

const SignLabels := preload("res://scripts/core/sign_labels.gd")


func before_each() -> void:
	new_session()


func _collect_written_tags() -> Dictionary:
	var found: Dictionary = {"region": {}, "entity": {}, "world": {}}
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
	# **E le rovine delle pietre.** Una pietra che crolla lascia una cicatrice,
	# e quella cicatrice non passa da nessun Effetto: e' scritta sul tipo di
	# struttura. `scar:burned_records` e' rimasta senza parola fino a D-249 —
	# usciva sul catalogo dei pezzi col proprio id.
	for structure_id in session.data.structure_types:
		var ruin: Dictionary = (
			session.data.structure_types[str(structure_id)] as Dictionary
		).get("ruin", {}) as Dictionary
		if str(ruin.get("scar", "")) != "":
			found["region"][str(ruin["scar"])] = true
	# **E le clausole.** Il censimento non le guardava, e quattordici segni del
	# mondo sono rimasti senza parola fino a D-236 — invisibili finche' una
	# clausola qualificata applicava i suoi effetti e basta, evidenti il giorno
	# che la scheda di una domanda ha cominciato a dire cosa lascia al mondo.
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
				"SET_GLOBAL_TAG":
					found["world"][tag] = true
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
		if not str(tag).contains("$"):
			_not_its_own_id(str(tag))


## E ogni segno che il mondo intero porta.
##
## I segni di Regione e di casa avevano gia' la loro guardia; quelli globali no,
## e la mancanza si vedeva solo dove nessuno guardava. Un `quota_guaranteed` che
## esce come «un segno cade sul mondo» non e' una regola che si puo' leggere:
## e' una condizione che si attacca al buio.
func test_every_world_sign_in_data_has_a_word() -> void:
	var written: Dictionary = _collect_written_tags()
	assert_true(written["world"].size() > 30, "il censimento trova i segni del mondo: %d" % written["world"].size())
	for tag in written["world"]:
		if str(tag).contains("$"):
			continue
		assert_true(
			SignLabels.known(str(tag)),
			"il segno del mondo '%s' ha la sua parola (D-107, D-236)" % tag
		)
		_not_its_own_id(str(tag))


## Una parola che contiene il proprio suffisso non e' una parola: e' un id
## vestito. `scoperta: trade_ledger` passava `known()` grazie al ripiego per
## prefisso, e finiva su una scheda del Consiglio.
func _not_its_own_id(tag: String) -> void:
	var suffix: String = tag.substr(tag.rfind(":") + 1)
	if not suffix.contains("_"):
		return
	assert_false(
		SignLabels.label(tag, session.data).contains(suffix),
		"la parola di '%s' non e' il suo id: «%s»" % [
			tag, SignLabels.label(tag, session.data)
		]
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

## **Ogni segno che puo' finire su una Regione ha un pezzo** (D-229).
##
## La mappa non scrive piu' i segni in fila: li **posa**, un gettone per segno,
## con la forma della sua famiglia. Un segno senza pezzo non e' un segno brutto:
## e' un segno **invisibile**, perche' `_draw_marks` lo salta e chi guarda la
## plancia non sa che c'e'. Era il modo piu' facile di perdere contenuto sul
## tavolo senza che nessuna prova se ne accorgesse.
func test_every_region_sign_has_a_piece() -> void:
	var loaded: RefCounted = data()
	var checked: int = 0
	for text in _region_signs(loaded):
		assert_ne(
			SignLabels.piece(str(text), loaded), "",
			"«%s» finisce su una Regione e non ha un pezzo con cui disegnarla" % str(text)
		)
		checked += 1
	assert_true(checked >= 20, "e vale per ogni segno di Regione: %d" % checked)


## Ogni segno che puo' finire su una Regione, da **tutte** le penne che lo
## scrivono: gli Effetti (Conseguenze, carte, Eco) e i **gradi delle pietre**,
## che non passano da nessun Effetto — la pietra posa il proprio tag salendo di
## grado, ed e' la penna che la prima stesura di questa prova non vedeva.
func _region_signs(loaded: RefCounted) -> Array:
	var out: Dictionary = {}
	for tag in (_collect_written_tags()["region"] as Dictionary):
		out[str(tag)] = true
	for structure_id in loaded.structure_types:
		var structure: Dictionary = loaded.structure_types[str(structure_id)] as Dictionary
		for grade in structure.get("grades", []) as Array:
			var tag: String = str((grade as Dictionary).get("tag", ""))
			if tag != "":
				out[tag] = true
		var ruin: Dictionary = structure.get("ruin", {}) as Dictionary
		if str(ruin.get("tag", "")) != "":
			out[str(ruin["tag"])] = true
	var signs: Array = []
	for tag in out:
		var text: String = str(tag)
		for prefix in ["condition:", "structure:", "settlement:", "scar:", "place:"]:
			if text.begins_with(prefix):
				signs.append(text)
				break
	signs.sort()
	return signs


## E il pezzo di una pietra e' la sua **famiglia**, letta dai dati e non da una
## tabella: se domani nasce una famiglia nuova il pezzo arriva da solo, e se
## nasce senza glifo questa prova lo dice.
##
## Il **grado** invece non si legge dal tag, ed e' una cosa che ho sbagliato una
## volta: un tag di pietra copre piu' gradi — `structure:granary` e' sia il
## Granaio sia il Grande Granaio — quindi grado e padrone stanno nel record del
## mondo, `{structure_type, grade, owner}`, e la mappa li prende da li'.
func test_a_stone_is_drawn_as_its_family() -> void:
	var loaded: RefCounted = data()
	var IconSet := preload("res://scripts/core/icon_set.gd")
	var known: Array = IconSet.names()
	var checked: int = 0
	for structure_id in loaded.structure_types:
		var structure: Dictionary = loaded.structure_types[str(structure_id)] as Dictionary
		var family: String = str(structure["family"]).to_lower()
		assert_true(
			known.has(family),
			"la famiglia «%s» non ha un glifo: la sua pietra si disegnerebbe come un buco"
			% family
		)
		assert_eq(
			SignLabels.family_of(str(structure_id), loaded), family,
			"«%s» si disegna con la forma della sua famiglia" % str(structure_id)
		)
		var grades: Array = structure.get("grades", [])
		for i in range(grades.size()):
			assert_eq(
				SignLabels.grade_name(str(structure_id), i + 1, loaded),
				str((grades[i] as Dictionary)["name"]),
				"e ogni grado si legge col nome che i dati gli danno"
			)
			checked += 1
	assert_true(checked >= 20, "e vale per ogni grado di ogni pietra: %d" % checked)


## E nessun segno di Regione si legge col suo suffisso inglese. Era la porta da
## cui uscivano «palace», «archive», «forest» sulla mappa.
func test_no_region_sign_reads_as_its_suffix() -> void:
	var loaded: RefCounted = data()
	for text in _region_signs(loaded):
		var suffix: String = str(text).get_slice(":", str(text).get_slice_count(":") - 1)
		assert_ne(
			SignLabels.label(str(text), loaded), suffix,
			"«%s» si legge col suo suffisso inglese invece che con una parola" % str(text)
		)
