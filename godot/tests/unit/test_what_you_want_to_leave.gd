extends "res://tests/test_case.gd"
## **Il profilo strategico si legge sullo schermo** (D-289).
##
## Il profilo di D-288 dice cosa una casa vuole lasciare nel mondo. Scritto e
## basta sarebbe un documento: serve che **chi gioca lo veda mentre gioca**, e
## che veda a che punto e' — quali dei segni che vuole sono gia' sul tavolo.
##
## Le prove tengono tre cose: che il blocco compaia per una casa che il profilo
## ce l'ha, che **nomini almeno un suo segno in italiano** (non il tag), e che
## sparisca del tutto — intestazione e spiegazione comprese — per una casa che
## il profilo non ce l'ha. La scatola ne ha otto e i profili sono quattro.

const StatusPanel := preload("res://ui/status_panel.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")


func before_each() -> void:
	new_session()


func _panel(viewer_id: String) -> Node:
	var panel: Node = StatusPanel.new()
	panel.render(session, viewer_id)
	return panel


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label and (child as Label).visible:
			into.append(str((child as Label).text))
		_labels_of(child, into)


func _column(panel: Node) -> String:
	var said: Array = []
	_labels_of(panel, said)
	return " · ".join(PackedStringArray(said))


## Il blocco c'e', e dice in una riga cosa quella casa e' venuta a fare.
func test_the_block_says_what_this_house_wants_to_leave() -> void:
	var profile: Dictionary = session.data.entity_profiles["ENT_ALDRIC"] as Dictionary
	var panel: Node = _panel("ENT_ALDRIC")
	var column: String = _column(panel)
	assert_true(column.contains("COSA RESTERA' DI TE"), "il blocco c'e': %s" % column)
	assert_true(
		column.contains(str(profile["in_one_line"])),
		"e porta la riga del profilo: %s" % column
	)
	panel.free()


## E nomina i segni **in italiano**: il tag `condition:starving` sulla colonna
## sarebbe un identificatore, non una parola del tavolo.
func test_it_names_its_signs_in_words() -> void:
	var profile: Dictionary = session.data.entity_profiles["ENT_ALDRIC"] as Dictionary
	var panel: Node = _panel("ENT_ALDRIC")
	var column: String = _column(panel)
	var named: int = 0
	for group in ["wants", "fears"]:
		for voice in profile[group] as Array:
			var tag: String = str((voice as Dictionary)["tag"])
			assert_false(column.contains(tag), "il tag grezzo non si stampa: %s" % tag)
			if column.contains(SignLabels.label(tag, session.data)):
				named += 1
	assert_true(named >= 3, "i segni del profilo si leggono: %d nominati" % named)
	panel.free()


## Una casa senza profilo non lascia in giro un'intestazione vuota: sparisce
## anche la riga che la spiegava (la regola di D-282).
func test_a_house_without_a_profile_shows_nothing() -> void:
	var kept: Variant = session.data.entity_profiles["ENT_ALDRIC"]
	session.data.entity_profiles.erase("ENT_ALDRIC")
	var panel: Node = _panel("ENT_ALDRIC")
	var column: String = _column(panel)
	session.data.entity_profiles["ENT_ALDRIC"] = kept
	assert_false(column.contains("COSA RESTERA' DI TE"), "nessuna intestazione: %s" % column)
	assert_false(
		column.contains("I segni che questa casa vuole vedere"),
		"e nessuna spiegazione orfana: %s" % column
	)
	panel.free()


## **E la prova morde.** Se il blocco tornasse a essere arredo — un'intestazione
## senza i segni sotto — la prima di queste asserzioni resterebbe verde: quello
## che tiene il blocco vivo e' che i segni ci siano, contati.
func test_the_signs_are_counted_not_assumed() -> void:
	var panel: Node = _panel("ENT_VAERAX")
	var rows: Array = []
	_labels_of(panel, rows)
	var voices: int = 0
	for row in rows:
		if str(row).begins_with("vuoi ") or str(row).begins_with("temi "):
			voices += 1
	var profile: Dictionary = session.data.entity_profiles["ENT_VAERAX"] as Dictionary
	assert_eq(
		voices, (profile["wants"] as Array).size() + (profile["fears"] as Array).size(),
		"ogni voce del profilo ha la sua riga"
	)
	panel.free()


## **E la soglia si legge insieme ai segni che conta** (D-290). Una regola che
## decide cosa diventi la tua casa e che non sta scritta accanto ai segni che la
## decidono e' una regola che al tavolo non esiste: sarebbe il manuale.
func test_the_threshold_is_printed_under_the_signs_it_counts() -> void:
	var panel: Node = _panel("ENT_ALDRIC")
	var column: String = _column(panel)
	assert_true(
		column.contains("diventi La Repubblica della Valle"),
		"la soglia dice in cosa si diventa: %s" % column
	)
	assert_true(column.contains("dopo 150 anni"), "e dopo quanto: %s" % column)
	assert_true(
		column.contains("questa casa e' cosi' da"),
		"e da quanto sei quello che sei: %s" % column
	)
	panel.free()


## Una casa la cui vita non dichiara nessuna porta del tempo non mostra nessuna
## soglia: Vaerax si trasforma per il Cristallo, non per il calendario.
func test_a_house_without_a_time_door_shows_no_threshold() -> void:
	var panel: Node = _panel("ENT_VAERAX")
	var column: String = _column(panel)
	assert_true(column.contains("COSA RESTERA' DI TE"), "il blocco c'e' lo stesso")
	assert_false(column.contains("dopo 150 anni"), "ma nessuna soglia: %s" % column)
	panel.free()
