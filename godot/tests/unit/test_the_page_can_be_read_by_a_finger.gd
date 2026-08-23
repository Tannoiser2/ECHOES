extends "res://tests/test_case.gd"
## Quello che una persona legge sullo schermo, quando lo schermo si tiene in
## mano (D-242, D-243, D-244).
##
## Tre difetti trovati giocando su un tablet, e sotto ce n'e' uno solo: **il
## testo che spiega le cose viveva nel suggerimento del mouse**, cioe' in un
## posto che su un touchscreen non esiste. La carta era una figurina con un
## numero; le due carte del Destino due figure mute; e la traccia delle domande
## diceva una regola che il gioco non ha piu'.
##
## Il cancello non guarda lo schermo (§5ter). Queste prove lo guardano.

const StatusPanel := preload("res://ui/status_panel.gd")
const AssetCard := preload("res://ui/asset_card.gd")


func before_each() -> void:
	new_session()


## Una partita tutta sua, letta dai file.
##
## La DataSet condivisa la riscrivono altre prove — due cancellano
## `confluence_rules.at_end_of_act` per misurare la regola vecchia — e una prova
## che chiede *«cosa legge una persona nella scatola cosi' com'e' spedita»* non
## puo' misurare l'attrezzo di scena di qualcun altro. Ha gia' detto il falso una
## volta, sostenendo che questa Chronicle non tiene il Consiglio a fine Atto.
var _mine: RefCounted


func _fresh() -> RefCounted:
	if _mine != null:
		return _mine
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	_mine = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_01", 4242)
	assert_true(_mine.setup("CHR_01", seats, 4242), "e l'anno si apre")
	for effect in _mine.factory_setup_effects():
		_mine.applier.apply(effect)
	return _mine


func _panel() -> Node:
	var live: RefCounted = _fresh()
	var panel: Node = StatusPanel.new()
	panel.render(live, str(live.world["turn_order"][0]))
	return panel


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label:
			into.append(str((child as Label).text))
		_labels_of(child, into)


## **La carta dice il proprio nome e il proprio verbo sulla faccia.**
##
## Non nel suggerimento: col dito non c'e' nessun «sopra» da cui farlo uscire.
## Se un giorno tornassero li', su un tablet la mano tornerebbe a essere una
## fila di figurine con un numero sotto.
func test_a_card_says_its_name_and_its_verb_on_its_face() -> void:
	var checked: int = 0
	for asset_id in session.data.assets:
		var card: Control = AssetCard.new()
		card.render(session.data.assets[str(asset_id)] as Dictionary, [], false, session.data)
		var lines: Array = []
		_labels_of(card, lines)
		assert_true(
			lines.has(str((session.data.assets[str(asset_id)] as Dictionary)["title"])),
			"«%s» porta il proprio nome sulla faccia" % str(asset_id)
		)
		var said: String = " · ".join(PackedStringArray(lines))
		assert_false(said.contains("$"), "e nessun buco: %s" % said)
		assert_false(said.contains(str(asset_id)), "e nessun id: %s" % said)
		card.free()
		checked += 1
	assert_true(checked >= 40, "per ogni carta della scatola: %d" % checked)


## E il verbo c'e' davvero: ogni carta ne porta uno (D-228), quindi una faccia
## senza verbo vuol dire che la faccia ha smesso di leggerlo.
func test_the_verb_is_on_the_face_too() -> void:
	var with_a_verb: int = 0
	for asset_id in session.data.assets:
		var asset: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		var card: Control = AssetCard.new()
		card.render(asset, [], false, session.data)
		var lines: Array = []
		_labels_of(card, lines)
		for line in lines:
			if str(line) != "" and str(line) != str(asset["title"]) \
					and not str(line).begins_with("forza"):
				with_a_verb += 1
				break
		card.free()
	assert_true(with_a_verb >= 40, "le carte che dicono cosa fanno: %d" % with_a_verb)


## **La traccia dice la regola di adesso, non quella di due versioni fa.**
##
## Col Consiglio a fine Atto la soglia non apre piu' niente (D-214): quello che
## conta e' chi e' il mucchio piu alto. Finche' la riga scriveva «12/18»
## insegnava un numero da raggiungere che non esiste — lo stesso errore che
## D-224 ha corretto sulla pagina d'aiuto, in un altro posto.
func test_the_question_track_does_not_teach_a_dead_threshold() -> void:
	var live: RefCounted = _fresh()
	var chronicle: Dictionary = live.data.chronicles[
		str(live.world["chronicle_id"])
	] as Dictionary
	assert_true(
		bool((chronicle.get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)),
		"questa Chronicle tiene il Consiglio a fine Atto"
	)
	var panel: Node = _panel()
	var rows: Dictionary = panel.get("_rows")
	assert_true(rows.size() >= 4, "le domande dell'anno ci sono: %d" % rows.size())
	var marked: int = 0
	for tension_id in rows:
		var said: String = str(((rows[tension_id] as Dictionary)["value"] as Label).text)
		assert_false(
			said.contains("/"),
			"«%s» non promette piu' una soglia: «%s»" % [str(tension_id), said]
		)
		if said.contains("Consiglio") or said.contains("a pari"):
			marked += 1
	assert_true(marked >= 1, "e la domanda davanti si vede che e' davanti")
	panel.free()


## Con la soglia ancora viva, invece, la riga la dice: la regola sta nei dati e
## la pagina la segue, invece di avere un'opinione propria.
func test_where_the_threshold_still_opens_something_the_row_says_so() -> void:
	var live: RefCounted = _fresh()
	var chronicle: Dictionary = live.data.chronicles[
		str(live.world["chronicle_id"])
	] as Dictionary
	var rules: Dictionary = chronicle["confluence_rules"] as Dictionary
	var before: bool = bool(rules.get("at_end_of_act", false))
	rules["at_end_of_act"] = false
	var panel: Node = _panel()
	var rows: Dictionary = panel.get("_rows")
	var with_threshold: int = 0
	for tension_id in rows:
		if str(((rows[tension_id] as Dictionary)["value"] as Label).text).contains("/"):
			with_threshold += 1
	panel.free()
	rules["at_end_of_act"] = before
	assert_true(with_threshold >= 1, "senza il Consiglio a fine Atto la soglia torna a contare")


## **Le due carte del Destino dicono cosa sono.**
##
## *«Le due carte destino cosa servono?»* — la domanda e' arrivata perche' erano
## due figure grandi e mute. Adesso una dice chi sei e l'altra cosa vuoi, e sotto
## ognuna c'e' il suo nome.
func test_the_two_tarots_say_what_they_are() -> void:
	var panel: Node = _panel()
	var lines: Array = []
	_labels_of(panel, lines)
	assert_true(lines.has("CHI SEI"), "la prima carta dice di essere la casa")
	assert_true(lines.has("COSA VUOI"), "la seconda dice di essere il Destino")

	var live: RefCounted = _fresh()
	var viewer: String = str(live.world["turn_order"][0])
	var house: String = str(
		(live.world["entities"][viewer] as Dictionary).get(
			"name", (live.data.entities[viewer] as Dictionary)["name"]
		)
	)
	var destiny: Dictionary = live.data.destinies[
		live.service.destiny_of(viewer)
	] as Dictionary
	assert_true(lines.has(house), "e sotto la prima c'e' il nome della casa: %s" % house)
	assert_true(
		lines.has(str(destiny["title"])),
		"e sotto la seconda il nome del Destino: %s" % str(destiny["title"])
	)
	panel.free()
