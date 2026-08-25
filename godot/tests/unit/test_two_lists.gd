extends "res://tests/test_case.gd"
## Le due liste sulla carta Tensione (D-278, parola del committente).
##
## > «nelle tensioni ci dovrebbero essere anche i vantaggi e gli svantaggi che
## > possono essere scelti e proposti durante il consiglio... dovrebbe essere il
## > cuore del gioco.»
##
## Aveva ragione su un punto che nessuna prova sorvegliava: il meccanismo della
## pedina del prezzo c'era da D-267, ma **il contenuto no** — 52 carte su 60
## condividevano quattro menu generici, e il malus era la stessa coppia
## (`CNS_COST_UNREST` / `CNS_COST_DEBT`) per tutto il gioco. Qui si pretende che
## la scelta esista **su ogni carta**, e che sia il tavolo a leggerla.

const CouncilSheet := preload("res://ui/council_sheet.gd")
const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")


func before_each() -> void:
	new_session()


## **Ogni carta porta le sue due liste, e sono una scelta vera.** Due voci che
## portano la stessa Conseguenza sono una voce sola scritta due volte.
func test_every_card_carries_two_real_lists() -> void:
	var costs_seen: Dictionary = {}
	var vents_seen: Dictionary = {}
	for tension_id in data().tensions:
		var face: Dictionary = (data().tensions[str(tension_id)] as Dictionary).get(
			"physical", {}
		) as Dictionary
		assert_false(face.is_empty(), "«%s» ha la sua faccia" % [str(tension_id)])
		for pair in [["benefits", "verb"], ["costs", "verb"], ["failure", "verb"]]:
			var voices: Array = face.get(str(pair[0]), []) as Array
			assert_true(
				voices.size() >= (1 if str(pair[0]) == "failure" else 2),
				"«%s» offre le sue voci di %s" % [str(tension_id), str(pair[0])]
			)
			var carried: Dictionary = {}
			for voice in voices:
				var entry: Dictionary = voice as Dictionary
				assert_ne(str(entry["text"]), "", "ogni voce ha le sue parole")
				assert_true(
					CouncilEconomy.knows(str(entry["verb"]),
						"benefits" if str(pair[0]) == "benefits" else "costs"),
					"«%s» usa un verbo del vocabolario" % [str(entry["id"])]
				)
				assert_true(
					CouncilEconomy.missing_parameters(entry,
						"benefits" if str(pair[0]) == "benefits" else "costs").is_empty(),
					"«%s» porta i parametri che il suo verbo chiede" % [str(entry["id"])]
				)
				carried[str(entry["verb"])] = true
				if str(pair[0]) == "costs":
					costs_seen[str(entry["verb"])] = true
				elif str(pair[0]) == "benefits":
					vents_seen[str(entry["verb"])] = true
			if str(pair[0]) != "failure":
				assert_eq(
					carried.size(), voices.size(),
					"le voci di %s di «%s» fanno cose diverse: una scelta finta non e' una scelta"
					% [str(pair[0]), str(tension_id)]
				)
	# E la tavolozza e' larga: prima di D-278 era **una coppia sola** per tutte
	# e sessanta le carte, e questa riga sarebbe stata 2 e 2.
	assert_eq(costs_seen.size(), CouncilEconomy.COST_VERBS.size(), "tutti i verbi di costo sono in gioco")
	assert_eq(vents_seen.size(), CouncilEconomy.BENEFIT_VERBS.size(), "e tutti quelli di beneficio")


## **Il menu del prezzo che il Consiglio offre e' quello scritto sulla carta.**
## Non il pool del template: la carta comanda, il template e' il ripiego.
func test_the_council_offers_what_the_card_says() -> void:
	var checked: int = 0
	for tension_id in session.world["tensions"]:
		var context: Dictionary = session.confluence.open(str(tension_id), {"kind": "THRESHOLD"})
		if context.is_empty():
			continue
		var face: Dictionary = (data().tensions[str(tension_id)] as Dictionary)["physical"]
		var written: Array = []
		for voice in (face["costs"] as Array):
			written.append(str((voice as Dictionary)["id"]))
		assert_eq(
			session.confluence.price_menu()["cost"], written,
			"il Consiglio su «%s» offre i costi della sua carta" % [str(tension_id)]
		)
		# E la voce si legge con le parole della carta.
		assert_eq(
			session.confluence.price_voice_text("costs", str(written[0])),
			str((face["costs"] as Array)[0]["text"]),
			"e le legge com'e' scritto"
		)
		# Si chiude la questione a mano: la prova apre e guarda, non gioca.
		session.confluence.current = {}
		checked += 1
	assert_true(checked > 0, "almeno una questione aperta da provare")


## **La scheda della domanda le mostra**, e le mostra per tutte: 52 carte su 60
## non nominano un template proprio, e prima di D-278 la scheda diceva loro
## «Nessun Consiglio scritto per questa domanda».
func test_the_sheet_shows_both_lists_for_every_question() -> void:
	var sheet: PanelContainer = CouncilSheet.new()
	# `_ready()` non gira per un nodo costruito fuori dall'albero: la colonna
	# non esisterebbe e la pagina sarebbe vuota senza dirlo (trappola di casa).
	sheet._ready()
	for tension_id in data().tensions:
		sheet.show_tension(str(tension_id), data(), session)
		var page: String = _text_of(sheet)
		assert_false(
			page.contains("Nessun Consiglio scritto"),
			"«%s» ha un Consiglio da mostrare" % [str(tension_id)]
		)
		var face: Dictionary = (data().tensions[str(tension_id)] as Dictionary)["physical"]
		for list_name in ["benefits", "costs", "failure"]:
			for voice in (face[list_name] as Array):
				assert_true(
					page.contains(str((voice as Dictionary)["text"])),
					"la scheda di «%s» legge «%s»" % [
						str(tension_id), str((voice as Dictionary)["text"]).substr(0, 30)
					]
				)
	sheet.free()


func _text_of(node: Node) -> String:
	var out: String = ""
	if node is Label:
		out += "%s\n" % (node as Label).text
	for child in node.get_children():
		out += _text_of(child)
	return out
