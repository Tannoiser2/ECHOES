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
				# **La firma di una casella e' il verbo col suo bersaglio**
				# (D-366): la stessa casella puntata su due posti diversi — qui
				# e la capitale — o su due case diverse e' una scelta vera, e il
				# tavolo la vede guardando dov'e' posata la pedina.
				carried[_signature(entry)] = true
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
	# **Quattro per lato, non di piu'** (D-453, parola del committente). Fino
	# alla 0.1.421 questa riga pretendeva il vocabolario intero in gioco —
	# e il vocabolario intero stava su ogni carta, da 8 a 12 per lato: un menu
	# che nessuno legge. Adesso la tavolozza in gioco e' quello che il tavolo
	# compra, e la carta ne porta al massimo quattro.
	for tension_id in data().tensions:
		var face: Dictionary = (data().tensions[str(tension_id)] as Dictionary).get(
			"physical", {}
		) as Dictionary
		for list_name in ["benefits", "costs"]:
			assert_true(
				(face.get(list_name, []) as Array).size() <= 4,
				"«%s» porta al massimo quattro %s" % [str(tension_id), list_name]
			)
	assert_true(costs_seen.size() >= 4, "almeno quattro verbi di costo in gioco: %d" % costs_seen.size())
	assert_true(vents_seen.size() >= 4, "e almeno quattro di beneficio: %d" % vents_seen.size())


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
		# **Nell'ordine della carta, e solo le caselle vive** (D-306): il menu
		# e' la lista stampata meno quelle che qui e adesso non farebbero
		# niente. Fino a D-366 le sette caselle di allora mordevano sempre in
		# questo scenario, e la prova poteva pretendere le due liste identiche;
		# adesso una carta puo' offrire «la Foresta scende di 1 grado» dove
		# nessuna Foresta sta in piedi, e quella pedina non si posa.
		var offered: Array = session.confluence.price_menu()["cost"] as Array
		var expected: Array = []
		for voice_id in written:
			if offered.has(str(voice_id)):
				expected.append(str(voice_id))
		assert_eq(
			offered, expected,
			"il Consiglio su «%s» offre i costi della sua carta, nel suo ordine"
			% [str(tension_id)]
		)
		# Con quattro costi sulla carta (D-453) ne bastano due vivi per far
		# pagare un secondo beneficio: era sette quando il menu era il vocabolario.
		assert_true(
			offered.size() >= 2,
			"e su «%s» ne offre abbastanza da comprarci qualcosa: %d" % [str(tension_id), offered.size()]
		)
		# E la voce si legge con le parole della carta.
		assert_eq(
			session.confluence.price_voice_text("costs", str(offered[0])),
			str(_voice_by_id(face["costs"] as Array, str(offered[0])).get("text", "")),
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


## **La casella che muove una domanda** (D-343, ISSUES 89).
##
## Fino alla 0.1.307 il vocabolario del Consiglio sapeva muovere il Calore di un
## **Tema** e non la traccia di una **domanda**: sul tavolo sono due piste
## diverse, e `ADJUST_TENSION` — 90 applicazioni su 336, un quarto di tutto
## quello che un Consiglio fa — non lo diceva nessuna casella.
##
## **Riscritta in D-453**: la casella non sta piu' su ogni carta — offerta 720
## volte in cento partite e comprata 75, e' uscita dal menu a quattro. Quello
## che ogni carta porta adesso e' la **memoria** (IL MONDO RICORDA, D-308): la
## storia della carta, che il taglio ha tenuto per regola. La seconda meta'
## della prova resta: dove la casella c'e', muove la domanda in discussione.
func test_a_question_can_be_moved_by_a_box() -> void:
	var loaded: RefCounted = data()
	var con_memoria: int = 0
	for tension_id in loaded.tensions:
		var physical: Dictionary = (loaded.tensions[str(tension_id)] as Dictionary).get(
			"physical", {}
		)
		if physical.is_empty():
			continue
		var verbi: Array = []
		for voice in physical["benefits"] as Array:
			verbi.append(str((voice as Dictionary)["verb"]))
		if verbi.has("REMEMBER") or verbi.has("FORGET"):
			con_memoria += 1
	assert_eq(con_memoria, 60, "ogni carta Domanda porta la sua memoria fra i benefici")

	# E la casella produce l'Effetto giusto, sulla domanda che si discute.
	var context: Dictionary = {"tension": "TEN_FAMINE", "proponent": "ENT_ALDRIC"}
	var world: Dictionary = {"tensions": {"TEN_FAMINE": {"current_value": 3}}}
	for pair in [["COOL_QUESTION", "benefits", -1], ["HEAT_QUESTION", "costs", 1]]:
		var effects: Array = CouncilEconomy.effects_for(
			{"id": "V", "verb": str(pair[0]), "text": ""}, str(pair[1]),
			context, world, "THM_SOPRAVVIVENZA", {}
		)
		assert_eq(effects.size(), 1, "%s produce un Effetto solo" % str(pair[0]))
		var effect: Dictionary = effects[0]
		assert_eq(str(effect["type"]), "ADJUST_TENSION", "%s muove una domanda" % str(pair[0]))
		assert_eq(str((effect["target"] as Dictionary)["id"]), "TEN_FAMINE",
			"%s muove la domanda in discussione" % str(pair[0]))
		assert_eq(int((effect["payload"] as Dictionary)["delta"]), int(pair[2]),
			"%s muove di un passo" % str(pair[0]))


## **E non si posa una pedina su una traccia che non si puo' muovere** (D-306).
##
## Una domanda gia' a zero non si abbassa: al tavolo il segnalino e' in fondo e
## si vede. Senza questa prova la casella sarebbe una scelta finta nel caso in
## cui serve di piu' — quando la domanda e' gia' risolta.
func test_a_question_at_zero_is_not_offered() -> void:
	var context: Dictionary = {"tension": "TEN_FAMINE", "proponent": "ENT_ALDRIC"}
	for pair in [[3, true], [0, false]]:
		var world: Dictionary = {"tensions": {"TEN_FAMINE": {"current_value": int(pair[0])}}}
		assert_eq(
			CouncilEconomy.voice_bites(
				{"id": "V", "verb": "COOL_QUESTION", "text": ""}, "benefits",
				context, world, "THM_SOPRAVVIVENZA", null
			),
			bool(pair[1]),
			"con la traccia a %d, abbassare %s" % [
				int(pair[0]), "morde" if bool(pair[1]) else "non morde",
			]
		)
	# E una domanda che questa Cronaca non ha pescata non si muove affatto.
	assert_false(
		CouncilEconomy.voice_bites(
			{"id": "V", "verb": "COOL_QUESTION", "text": ""}, "benefits",
			{"tension": "TEN_CHE_NON_CE"}, {"tensions": {}}, "THM_SOPRAVVIVENZA", null
		),
		"una domanda che non e al tavolo non si abbassa"
	)


## Quello che una casella fa davvero, in una riga: il verbo, il posto e la casa.
## Due voci con la stessa firma sono la stessa pedina scritta due volte.
static func _signature(voice: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for field in [
		"verb", "dove", "place_tag", "question", "verso", "verso_tag",
		"chi", "who_tag", "tag", "structure", "level",
	]:
		parts.append(str(voice.get(field, "")))
	return "|".join(parts)


## La voce di una lista, cercata per id.
static func _voice_by_id(voices: Array, voice_id: String) -> Dictionary:
	for voice in voices:
		if str((voice as Dictionary).get("id", "")) == voice_id:
			return voice as Dictionary
	return {}
