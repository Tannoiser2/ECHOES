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
	# **Sei per lato, non di piu'** (D-467, D-469). Quattro in D-453, parola
	# del committente — fino alla 0.1.421 questa riga pretendeva il vocabolario
	# intero, da 8 a 12 per lato: un menu che nessuno legge. Con due domande in
	# contrasto e quattro seggi, quattro finivano prima del primo giro di
	# rilancio: sei sono le caselle di due parti, e il tetto e' questo.
	for tension_id in data().tensions:
		var face: Dictionary = (data().tensions[str(tension_id)] as Dictionary).get(
			"physical", {}
		) as Dictionary
		for list_name in ["benefits", "costs"]:
			assert_true(
				(face.get(list_name, []) as Array).size() <= 6,
				"«%s» porta al massimo sei %s" % [str(tension_id), list_name]
			)
	assert_true(costs_seen.size() >= 4, "almeno quattro verbi di costo in gioco: %d" % costs_seen.size())
	assert_true(vents_seen.size() >= 4, "e almeno quattro di beneficio: %d" % vents_seen.size())


## **Le caselle che il Consiglio offre sono quelle scritte sulla carta.**
## Non il pool del template: la carta comanda, il template e' il ripiego. Da
## D-472 l'offerta e' `box_menu(parte)`: per ogni parte, le caselle della
## carta marcate per la sua domanda — benefici e costi insieme — che qui
## farebbero qualcosa (D-306), nell'ordine della carta e con le sue parole.
func test_the_council_offers_what_the_card_says() -> void:
	var checked: int = 0
	var boxes_seen: int = 0
	for tension_id in session.world["tensions"]:
		var context: Dictionary = session.confluence.open(str(tension_id), {"kind": "THRESHOLD"})
		if context.is_empty():
			continue
		assert_true(session.confluence.sides_open(), "«%s» apre con due parti" % [str(tension_id)])
		var face: Dictionary = (data().tensions[str(tension_id)] as Dictionary)["physical"]
		# La carta, nell'ordine in cui si legge: prima i benefici, poi i costi.
		var written: Array = []
		for list_name in ["benefits", "costs"]:
			for voice in (face[list_name] as Array):
				written.append(str((voice as Dictionary)["id"]))
		for side in ["A", "B"]:
			var question_id: String = session.confluence.side_question(side)
			var offered: Array = []
			for entry in session.confluence.box_menu(side):
				var box: Dictionary = entry as Dictionary
				offered.append(str(box["id"]))
				# Ogni casella offerta sta sulla carta, e' marcata per la
				# domanda di questa parte, e dice da che lista viene.
				var voice: Dictionary = _voice_by_id(
					face[str(box["list"])] as Array, str(box["id"])
				)
				assert_false(
					voice.is_empty(),
					"«%s» e' una %s stampata su «%s»" % [str(box["id"]), str(box["list"]), str(tension_id)]
				)
				assert_true(
					(box.get("for", []) as Array).has(question_id),
					"e serve la domanda %s" % side
				)
				# E la voce si legge con le parole della carta.
				assert_eq(
					str(box.get("text", "")), str(voice.get("text", "")),
					"e si legge com'e' scritta"
				)
			# **Nell'ordine della carta, e solo le caselle vive** (D-306): il
			# menu e' la lista stampata meno quelle che qui e adesso non
			# farebbero niente.
			var expected: Array = []
			for voice_id in written:
				if offered.has(str(voice_id)):
					expected.append(str(voice_id))
			assert_eq(
				offered, expected,
				"la parte %s su «%s» ha le caselle della carta, nel suo ordine" % [side, str(tension_id)]
			)
			boxes_seen += offered.size()
		# Si chiude la questione a mano: la prova apre e guarda, non gioca.
		session.confluence.current = {}
		checked += 1
	assert_true(checked > 0, "almeno una questione aperta da provare")
	# Prima di credere a un menu vuoto: su tutte le questioni aperte, almeno
	# una parte ha avuto qualcosa da posare.
	assert_true(boxes_seen > 0, "e almeno una casella e' stata offerta: %d" % boxes_seen)


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
## della prova resta, **giocata sulla regola nuova** (D-472): la casella si
## fabbrica sulla Carestia, marcata per la domanda A; chi propone la posa con
## `place_box`, il Consiglio si vota col mucchio a zero, e nel registro degli
## Effetti c'e' la domanda in discussione mossa di un passo in giu'.
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

	# E la casella, posata sulla parte giusta, muove la domanda che si discute.
	var tension_id: String = "TEN_FAMINE"
	var box_id: String = "B_COOL_Q_PROVA"
	var benefits: Array = (loaded.tensions[tension_id] as Dictionary)["physical"]["benefits"] as Array
	_pile(tension_id, 0)
	var context: Dictionary = session.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Carestia apre il suo Consiglio")
	benefits.append({
		"id": box_id, "verb": "COOL_QUESTION", "text": "Abbassa la domanda.",
		"for": [session.confluence.side_question("A")],
	})
	# L'esito di base della domanda A abbassa la Carestia da solo (CNS_DISTRIBUTION_AUDITED):
	# si zittisce, cosi' il passo in giu' che si conta e' quello della pedina.
	var hushed: Array = _hush_the_base(tension_id)
	(session.world["tensions"][tension_id] as Dictionary)["current_value"] = 3
	var proponent: String = str(context["proponent"])
	assert_true(session.confluence.place_box(proponent, box_id), "chi propone posa la casella sulla A")
	var before: int = (session.world["effect_log"] as Array).size()
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["winner"]), "A", "una pedina contro nessuna sopra un mucchio a zero: vince la A")
	var moved: int = 0
	for i in range(before, (session.world["effect_log"] as Array).size()):
		var effect: Dictionary = (session.world["effect_log"] as Array)[i] as Dictionary
		if str(effect["type"]) != "ADJUST_TENSION":
			continue
		if str((effect["target"] as Dictionary)["id"]) != tension_id:
			continue
		if int((effect["payload"] as Dictionary).get("delta", 0)) == -1:
			moved += 1
	assert_eq(moved, 1, "la casella muove la domanda in discussione di un passo in giu'")
	assert_true(
		_log_says("H. Beneficio: Abbassa la domanda."), "e il verbale legge la casella posata"
	)
	# La DataSet e' condivisa: la casella fabbricata se ne va, e la base torna.
	benefits.pop_back()
	_restore_the_base(tension_id, hushed)


## **E non si posa una pedina su una traccia che non si puo' muovere** (D-306).
##
## Una domanda gia' a zero non si abbassa: al tavolo il segnalino e' in fondo e
## si vede. Senza questa prova la casella sarebbe una scelta finta nel caso in
## cui serve di piu' — quando la domanda e' gia' risolta. Prima di credere al
## menu che non la offre, la stessa casella si vede offerta con la traccia
## alta.
func test_a_question_at_zero_is_not_offered() -> void:
	var tension_id: String = "TEN_FAMINE"
	var box_id: String = "B_COOL_Q_PROVA"
	var benefits: Array = (data().tensions[tension_id] as Dictionary)["physical"]["benefits"] as Array
	var context: Dictionary = session.confluence.open(tension_id, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Carestia apre il suo Consiglio")
	benefits.append({
		"id": box_id, "verb": "COOL_QUESTION", "text": "Abbassa la domanda.",
		"for": [session.confluence.side_question("A")],
	})
	var proponent: String = str(context["proponent"])
	(session.world["tensions"][tension_id] as Dictionary)["current_value"] = 3
	assert_true(_offered("A").has(box_id), "con la traccia a 3, abbassare e' sul menu")
	(session.world["tensions"][tension_id] as Dictionary)["current_value"] = 0
	assert_false(_offered("A").has(box_id), "con la traccia a 0, non e' piu' offerta")
	assert_false(
		session.confluence.place_box(proponent, box_id),
		"e non si posa nemmeno chiamandola per nome"
	)
	benefits.pop_back()
	session.confluence.current = {}
	# E una domanda che questa Cronaca non ha pescata non si muove affatto.
	assert_false(
		CouncilEconomy.voice_bites(
			{"id": "V", "verb": "COOL_QUESTION", "text": ""}, "benefits",
			{"tension": "TEN_CHE_NON_CE"}, {"tensions": {}}, "THM_SOPRAVVIVENZA", null
		),
		"una domanda che non e al tavolo non si abbassa"
	)


## Gli id offerti a una parte, nell'ordine del menu.
func _offered(side: String) -> Array:
	var out: Array = []
	for entry in session.confluence.box_menu(side):
		out.append(str((entry as Dictionary)["id"]))
	return out


## Il mucchio che il Consiglio leggera' all'apertura: il Calore del Tema.
func _pile(tension_id: String, value: int) -> void:
	var theme_id: String = str((data().tensions[tension_id] as Dictionary).get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = value


## Zittisce l'esito di base della domanda A sulla carta, e torna quello che
## c'era: il DataSet e' condiviso, e chi zittisce rimette.
func _hush_the_base(tension_id: String) -> Array:
	var question_id: String = session.confluence.side_question("A")
	for entry in (data().confluence_template_for(tension_id)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == question_id:
			var said: Array = ((entry as Dictionary)["base"] as Array).duplicate()
			(entry as Dictionary)["base"] = []
			return [question_id, said]
	return []


func _restore_the_base(tension_id: String, hushed: Array) -> void:
	if hushed.is_empty():
		return
	for entry in (data().confluence_template_for(tension_id)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == str(hushed[0]):
			(entry as Dictionary)["base"] = hushed[1]


func _log_says(needle: String) -> bool:
	for line in session.log.lines:
		if str(line).contains(needle):
			return true
	return false


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
