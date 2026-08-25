extends "res://tests/test_case.gd"
## **La colonna di destra si legge** (D-282).
##
## Il committente, davanti all'app: *«sulla colonna di destra non si capisce
## nulla: ci sono i mazzetti dei temi, le domande dell'anno (?), i rapporti, i
## segni della casa, il destino, poi ancora quattro tensioni (?)»*.
##
## Due difetti in uno. Il primo: **la stessa cosa era li' tre volte** — i sei
## mazzetti disegnati (D-279), la riga «CALORE» che li ripeteva a parole, e le
## quattro questioni con le barre. Il secondo: nessun blocco diceva a cosa
## servisse, e un blocco che non dice cosa e' non e' informazione, e' arredo.
##
## Al tavolo la plancia ha le sue scritte stampate accanto alle caselle. Queste
## prove tengono quelle scritte: **ogni intestazione ha la sua riga**, e nessuna
## riga resta senza la cosa che spiega.

const StatusPanel := preload("res://ui/status_panel.gd")

## L'intestazione di un blocco e la sua spiegazione si distinguono per corpo:
## 12 la prima, 10 la seconda. E' la stessa gerarchia di una carta stampata.
const HEADER_SIZE: int = 12
const NOTE_SIZE: int = 10


func before_each() -> void:
	new_session()


func _panel() -> Node:
	var panel: Node = StatusPanel.new()
	panel.render(session, str(session.world["turn_order"][0]))
	return panel


## Ogni intestazione visibile porta la sua riga di spiegazione, subito sotto.
func test_every_heading_says_what_the_block_is_for() -> void:
	var panel: Node = _panel()
	var children: Array = panel.get_children()
	var headers: int = 0
	for i in range(children.size()):
		var child: Node = children[i]
		if not (child is Label) or not (child as Label).visible:
			continue
		if int((child as Label).get_theme_font_size("font_size")) != HEADER_SIZE:
			continue
		headers += 1
		var title: String = str((child as Label).text)
		assert_true(i + 1 < children.size(), "«%s» non e' l'ultima cosa della colonna" % title)
		var below: Node = children[i + 1]
		assert_true(below is Label, "sotto «%s» c'e' una riga che spiega" % title)
		assert_eq(
			int((below as Label).get_theme_font_size("font_size")), NOTE_SIZE,
			"e la riga sotto «%s» e' una spiegazione, non un'altra intestazione" % title
		)
		assert_true(
			str((below as Label).text).length() > 30,
			"e dice qualcosa: «%s»" % str((below as Label).text)
		)
	assert_true(headers >= 3, "la colonna ha i suoi blocchi: %d" % headers)
	panel.free()


## E una spiegazione senza la cosa spiegata non resta sullo schermo: i blocchi
## che spariscono quando sono vuoti — i Diritti, i segni della casa — si portano
## via anche la propria riga.
func test_no_explanation_outlives_the_thing_it_explains() -> void:
	var panel: Node = _panel()
	var children: Array = panel.get_children()
	for i in range(children.size()):
		var child: Node = children[i]
		if not (child is Label):
			continue
		if int((child as Label).get_theme_font_size("font_size")) != NOTE_SIZE:
			continue
		if not (child as Label).visible:
			continue
		assert_true(i > 0, "una spiegazione non apre la colonna")
		var above: Node = children[i - 1]
		assert_true(
			above is Label and (above as Label).visible,
			"la riga «%s» ha sopra la sua intestazione, accesa" % str((child as Label).text)
		)
	panel.free()


## **E la stessa cosa non si dice due volte.** La riga «CALORE» ripeteva a
## parole i sei mazzetti che stanno disegnati sopra, e le quattro questioni si
## chiamavano «le domande dell'anno» come se fossero *le* domande — mentre le
## domande, da D-261, sono i mazzetti.
func test_the_column_does_not_say_the_same_thing_twice() -> void:
	var panel: Node = _panel()
	var said: Array = []
	_labels_of(panel, said)
	var column: String = " · ".join(PackedStringArray(said))
	assert_false(column.contains("CALORE"), "la pista non si ripete a parole: %s" % column)
	assert_false(
		column.contains("LE DOMANDE DELL'ANNO"),
		"e le quattro questioni non si spacciano per le domande: %s" % column
	)
	assert_true(
		column.contains("LE QUESTIONI GIA' APERTE"),
		"si chiamano per quello che sono: %s" % column
	)
	panel.free()


func _labels_of(node: Node, into: Array) -> void:
	for child in node.get_children():
		if child is Label:
			into.append(str((child as Label).text))
		_labels_of(child, into)
