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


## --- e la carta deve **starci**, dentro il posto che la contiene (D-246) ---
##
## *«Sono tagliate e non c'e' scritto nulla sopra.»* Erano la stessa frase: il
## testo che D-242 aveva aggiunto sta **sotto** l'immagine, e quello che si taglia
## di una carta troppo alta e' il fondo. La carta chiedeva 196 pixel, la mano ne
## dava 200, e bastava un titolo su due righe.

const HandView := preload("res://ui/hand_view.gd")


## L'altezza che la carta chiede e' la somma delle sue parti, e nessuna parte
## puo' essere schiacciata via: ogni riga ha la propria altezza minima.
func test_a_card_asks_for_room_for_all_of_its_parts() -> void:
	var card: Control = AssetCard.new()
	card.render(
		session.data.assets[str((session.data.assets as Dictionary).keys()[0])] as Dictionary,
		[], false, session.data
	)
	var wanted: float = AssetCard.wanted_height()
	assert_true(wanted >= 240.0, "una carta con quattro pezzi chiede spazio per quattro: %.0f" % wanted)
	assert_eq(
		card.custom_minimum_size.y, wanted,
		"e quello che chiede e' quello che dichiara"
	)

	# Ogni riga di testo ha un pavimento: senza, il contenitore le schiaccia a
	# zero prima di lasciare che la carta sfori, ed e' esattamente il modo in cui
	# il testo era sparito.
	var floors: int = 0
	for child in card.get_child(0).get_children():
		if child is Label and (child as Label).custom_minimum_size.y > 0.0:
			floors += 1
	assert_true(floors >= 3, "le righe di testo hanno un pavimento: %d" % floors)
	card.free()


## E un titolo lungo non allunga la carta: si ferma a due righe. Un titolo che
## va a capo tre volte era il modo piu' rapido di far uscire il fondo dal
## contenitore.
func test_a_long_title_does_not_grow_the_card() -> void:
	var longest: Dictionary = {}
	var length: int = 0
	for asset_id in session.data.assets:
		var asset: Dictionary = session.data.assets[str(asset_id)] as Dictionary
		if str(asset["title"]).length() > length:
			length = str(asset["title"]).length()
			longest = asset
	var card: Control = AssetCard.new()
	card.render(longest, [], false, session.data)
	for child in card.get_child(0).get_children():
		if child is Label and str((child as Label).text) == str(longest["title"]):
			assert_eq(
				(child as Label).max_lines_visible, 2,
				"il titolo piu' lungo della scatola si ferma a due righe: «%s»" % str(longest["title"])
			)
	assert_eq(
		card.custom_minimum_size.y, AssetCard.wanted_height(),
		"e la carta resta alta quanto le altre"
	)
	card.free()


## **La mano e' alta quanto la carta.** Il numero non si indovina in un altro
## file: si chiede alla carta. E' l'indovinello che ha prodotto il taglio.
func test_the_hand_is_as_tall_as_the_card_it_holds() -> void:
	var screen: Node = load("res://ui/game_screen.gd").new()
	var wanted: float = AssetCard.wanted_height()
	# La riga che conta sta nel codice dello schermo: la si legge da li', perche'
	# costruire tutta la schermata in una prova headless vorrebbe dire montare
	# mezza applicazione per misurare un numero.
	var source: String = FileAccess.get_file_as_string("res://ui/game_screen.gd")
	assert_true(
		source.contains("AssetCard.wanted_height()"),
		"la mano chiede alla carta quanto e' alta, invece di indovinarlo"
	)
	assert_true(wanted > 0.0, "e la carta sa rispondere: %.0f" % wanted)
	screen.free()


## --- e la colonna di lato non puo' spingere la mano fuori dallo schermo ---
##
## *«Le carte sono quasi sparite del tutto.»* Non erano piccole: erano **sotto il
## bordo della finestra**. La colonna di destra cresce con quello che c'e' da
## dire — quattro domande, i rapporti, i diritti, i segni, il Destino con le sue
## due carte — e la sua **altezza minima decideva la pagina**: se chiede piu' di
## quanto la finestra ha, tutto quello che sta sotto finisce fuori.
##
## E' un difetto che nessuno vede su un monitor alto e che si vede sempre su un
## portatile o un tablet in orizzontale (D-251).


## Il numero che rende il rischio un fatto: la colonna **puo'** essere piu' alta
## di una finestra vera. Finche' e' cosi', non puo' stare in una pagina che non
## scorre.
func test_the_side_column_can_be_taller_than_a_window() -> void:
	var live: RefCounted = _fresh()
	var panel: Node = StatusPanel.new()
	# Serve un albero per far calcolare a Godot le misure minime, e questa prova
	# non e' un Node: il ramo principale si chiede al motore.
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	tree.root.add_child(panel)
	panel.render(live, str(live.world["turn_order"][0]))
	var wanted: float = panel.get_combined_minimum_size().y
	panel.queue_free()
	assert_true(
		wanted > 600.0,
		"la colonna di stato chiede piu' di 600 px: %.0f — e una finestra da tablet ne ha ~700" % wanted
	)


## Quindi la pagina la mette dentro qualcosa che scorre. Letto dal codice: per
## misurarlo su una schermata montata servirebbe mezza applicazione in piedi, e
## la riga che conta e' una sola.
func test_the_side_column_lives_inside_something_that_scrolls() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/game_screen.gd")
	# Da D-279 dentro `reading` c'e' una colonna sola — i sei mazzetti piu' il
	# pannello di stato — quindi la prova guarda **quella**: il patto e' che lo
	# stato stia dentro il pannello che scorre, non che ci sia attaccato
	# direttamente.
	assert_true(
		source.contains("reading.add_child(decks_column)"),
		"la colonna della lettura sta dentro un pannello che scorre"
	)
	assert_true(
		source.contains("decks_column.add_child(_status)"),
		"e il pannello di stato sta in quella colonna"
	)
	assert_false(
		source.contains("right.add_child(_status)"),
		"e non piu' attaccato dritto alla colonna, dove la sua altezza decideva la pagina"
	)


## E quello che resta — la mano piu' una mappa degna di questo nome — ci sta
## dentro una finestra bassa. Se domani la carta cresce ancora, questa prova lo
## dice prima che le carte spariscano di nuovo sotto il bordo.
func test_the_hand_and_a_map_fit_a_short_window() -> void:
	var hand: float = AssetCard.wanted_height() + 14.0
	var map: float = 260.0
	assert_true(
		hand + map <= 700.0,
		"mano (%.0f) e mappa (%.0f) stanno in una finestra da 700: %.0f" % [hand, map, hand + map]
	)

