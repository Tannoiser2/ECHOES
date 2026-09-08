extends "res://tests/test_case.gd"
## **Le due schede non dicono le stesse cose, e la fascia si chiude**
## ([D-478](DECISIONS.md#d-478)).
##
## Parola del committente, davanti alla pagina: *«la mia casa e obiettivi
## mostrano le stesse cose e poi la finestra e' piccolissima in altezza e non si
## legge nulla, falla collassabile, ma quando e' aperta deve avere almeno
## l'altezza di una carta»*.
##
## Due cose distinte, e una prova per ognuna. La prima e' un doppione — la
## stessa forma di difetto che [D-473](DECISIONS.md#d-473) aveva tolto dalla
## scheda della casa e che era rimasta fra le due schede; la seconda e' una
## misura, e il numero e' quello di [D-246](DECISIONS.md#d-246): una carta si
## legge solo se ci sta tutta.

const GameScreen := preload("res://ui/game_screen.gd")
const StatusPanel := preload("res://ui/status_panel.gd")
const AssetCard := preload("res://ui/asset_card.gd")


func before_each() -> void:
	new_session()


## Le intestazioni che una persona **vede**: un nodo nascosto non e' un
## doppione, e contarlo direbbe rosso su una scheda che al tavolo e' pulita.
func _headings(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label and (child as Control).visible:
			var said: String = str((child as Label).text)
			# Le intestazioni dei blocchi sono in maiuscolo: e' la stampa della
			# plancia (D-282), e distingue un titolo da una riga di prosa.
			if said != "" and said == said.to_upper() and said.length() > 3:
				into.append(said)
		_headings(child, into)


## **Nessun blocco sta su tutt'e due le schede.** Prima di D-478 il Destino e il
## profilo stavano su entrambe: due terzi della scheda erano identici.
func test_no_block_is_on_both_sheets() -> void:
	var mine: StatusPanel = StatusPanel.new()
	mine.render(session, str(session.world["turn_order"][0]))
	var goals: StatusPanel = StatusPanel.new()
	goals.only_goals = true
	goals.render(session, str(session.world["turn_order"][0]))

	var here: Array = []
	_headings(mine, here)
	var there: Array = []
	_headings(goals, there)
	assert_false(here.is_empty(), "la plancia dice qualcosa: %s" % str(here))
	assert_false(there.is_empty(), "e gli obiettivi anche: %s" % str(there))
	for heading in there:
		assert_false(
			here.has(heading),
			"«%s» sta su tutt'e due le schede: %s contro %s" % [heading, str(here), str(there)]
		)
	mine.free()
	goals.free()


## E ognuna tiene il suo mestiere: gli Obiettivi dicono a che gioco giochi, la
## plancia quello che tieni tu.
func test_each_sheet_keeps_its_own_job() -> void:
	var goals: StatusPanel = StatusPanel.new()
	goals.only_goals = true
	goals.render(session, str(session.world["turn_order"][0]))
	var there: Array = []
	_headings(goals, there)
	assert_true(
		there.has("IL TUO DESTINO"),
		"la scheda degli Obiettivi porta il Destino: %s" % str(there)
	)
	goals.free()


## **La fascia si chiude, e aperta e' alta almeno una carta.** Chiusa lascia lo
## spazio alla mappa; aperta non scende mai sotto l'altezza che una carta
## chiede per leggersi (D-246).
func test_the_strip_collapses_and_opens_a_card_tall() -> void:
	var screen: Node = GameScreen.new()
	screen.call("_build")
	var tabs: Control = screen.get("_tabs")
	var button: Button = screen.get("_tabs_button")
	assert_true(tabs != null and button != null, "la fascia e la sua maniglia esistono")

	assert_true(tabs.visible, "all'apertura la fascia e' aperta")
	assert_true(
		tabs.custom_minimum_size.y >= AssetCard.wanted_height(),
		"e alta almeno una carta: %d contro %d" % [
			int(tabs.custom_minimum_size.y), int(AssetCard.wanted_height())
		]
	)

	screen.call("_toggle_tabs", false)
	assert_false(tabs.visible, "chiusa sparisce")
	assert_eq(int(tabs.custom_minimum_size.y), 0, "e non tiene piu' spazio")
	assert_true(
		button.visible and str(button.text).contains("aprire"),
		"ma la maniglia resta, e dice come riaprirla: «%s»" % str(button.text)
	)

	screen.call("_toggle_tabs", true)
	assert_true(
		tabs.visible and tabs.custom_minimum_size.y >= AssetCard.wanted_height(),
		"e riaperta torna alta una carta"
	)
	screen.free()
