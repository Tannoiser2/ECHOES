extends "res://tests/test_case.gd"
## Le pedine sulla carta, e la regola del silenzio (D-280, D-267 — riscritte
## sul Consiglio a due domande, D-467 / D-472).
##
## Parola del committente, sulla sua carta d'esempio: la carta offre benefici
## e costi, e **quello che il Consiglio posa e' quello che il mondo ricorda**.
## Da D-472 il giro e' uno solo: chi propone prende una domanda (la A), gli
## altri stanno con lei o con l'altra (la B), ognuno posa pedine sulle
## caselle marcate per la sua parte, e al voto contro il mucchio si applicano
## l'esito di base e **tutte le pedine** — benefici *e* costi — della parte
## che vince; se non vince nessuna, scattano gli effetti stampati. La
## Cicatrice e' un costo come gli altri (D-303). E la regola anti-passivita'
## della roadmap (PZ-5) resta: se nessuno prende posizione, il silenzio
## avvantaggia il proponente — un numero nei dati, reversibile.
##
## Quello che e' uscito con D-472, e qui non si prova piu': il dado truccato,
## «un beneficio gratis e ogni altro costa», il tetto dei gettoni, la pedina
## del prezzo posata da chi paga, «senza gettone niente si paga».
##
## Gli esiti si forzano col **mucchio**, non col caso: mucchio a zero e una
## sola parte con pedine, e quella vince; mucchio a 99, e non arriva nessuna.
## Una prova che dipendesse dal seme smetterebbe di provare senza dirlo.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

const TENSION: String = "TEN_FAMINE"


var _hushed_question: String = ""
var _hushed_said: Array = []


func before_each() -> void:
	new_session()


func after_each() -> void:
	# La regola del silenzio e' dato spedito (1): le prove che la spengono o la
	# gonfiano devono rimetterla, o il prossimo test la troverebbe storta.
	var chronicle: Dictionary = data().chronicles["CHR_TEST"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = 1
	# E l'esito di base zittito torna a parlare: il DataSet e' condiviso.
	if _hushed_question != "":
		for entry in (data().confluence_template_for(TENSION)["questions"] as Array):
			if str((entry as Dictionary)["id"]) == _hushed_question:
				(entry as Dictionary)["base"] = _hushed_said
		_hushed_question = ""
	super.after_each()


## **Zittisce l'esito di base della domanda A** (D-305, riletto da D-469).
##
## La carta si spende **per ultima**, e prima di lei parla l'esito di base
## della domanda che ha vinto: sulla Carestia quello alza un Granaio e abbassa
## la domanda — le stesse cose che due caselle vendono. Una prova che vuole
## vedere **cosa lascia la casella** deve quindi fabbricarsi il silenzio,
## invece di sperare che la frase d'autore non le rubi il lavoro.
func _hush_the_base() -> void:
	_hushed_question = session.confluence.side_question("A")
	for entry in (data().confluence_template_for(TENSION)["questions"] as Array):
		if str((entry as Dictionary)["id"]) == _hushed_question:
			_hushed_said = ((entry as Dictionary)["base"] as Array).duplicate()
			(entry as Dictionary)["base"] = []


## Le voci scritte sulla carta in dibattito. Le prove le leggono invece di
## scriverle a mano: la faccia e' dato spedito, e un id fisso qui dentro
## smetterebbe di provare il giorno che la carta cambia parole (D-278).
func _voices(list_name: String) -> Array:
	var out: Array = []
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		out.append(str((voice as Dictionary)["id"]))
	return out


## La prima voce di una lista col verbo chiesto, o "".
func _voice_with_verb(list_name: String, verb: String) -> String:
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		if str((voice as Dictionary).get("verb", "")) == verb:
			return str((voice as Dictionary)["id"])
	return ""


## Il testo stampato di una voce, per leggerlo nel verbale.
func _text_of(list_name: String, voice_id: String) -> String:
	for voice in (data().tensions[TENSION]["physical"][list_name] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			return str((voice as Dictionary)["text"])
	return ""


## Gli id offerti a una parte, nell'ordine del menu.
func _offered(side: String) -> Array:
	var out: Array = []
	for entry in session.confluence.box_menu(side):
		out.append(str((entry as Dictionary)["id"]))
	return out


## Apre il Consiglio sulla Carestia col **mucchio** voluto — il valore del Tema
## si legge all'apertura (D-467), quindi si scrive prima — e poi fabbrica il
## tavolo su cui ogni casella della carta morde.
func _open(pile: int = 0) -> Dictionary:
	var theme_id: String = str(data().tensions[TENSION].get("theme", ""))
	if not session.world.has("theme_heat"):
		session.world["theme_heat"] = {}
	(session.world["theme_heat"] as Dictionary)[theme_id] = pile
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence su %s si apre" % TENSION)
	assert_true(session.confluence.sides_open(), "con le due parti")
	assert_eq(session.confluence.pile(), pile, "e il mucchio e' quello scritto")
	_make_every_casella_live()
	return context


## **Il tavolo in cui ogni casella della carta puo' fare qualcosa** (D-306).
##
## Da D-306 il menu offre solo le caselle vive: «Riapri l'accesso» non si posa
## dove non c'e' niente di chiuso. Una prova che vuole misurare **la carta
## intera** si fabbrica il mondo che la rende intera, invece di dipendere da
## quale tessera e' uscita dal seme. E' la regola di casa.
##
## Le due condizioni si posano in quest'ordine apposta: RIMUOVI CONDIZIONE
## prende la prima `condition:` che trova, quindi becca #fame e lascia
## #tagliata_fuori a RIAPRI. Due caselle, due segni, nessuna che ruba il lavoro
## all'altra.
func _make_every_casella_live() -> void:
	var context: Dictionary = session.confluence.effect_context()
	var region_id: String = str(context.get("region_focus", ""))
	assert_ne(region_id, "", "il Consiglio discute di un luogo")
	var region: Dictionary = session.world["regions"][region_id]
	var tags: Array = region["tags"] as Array
	for tag in ["condition:starving", "condition:cut_off"]:
		if not tags.has(tag):
			tags.append(tag)
	for tag in ["condition:rationed", "structure:tollgate", "condition:indebted"]:
		tags.erase(tag)
	# CAMBIA CONTROLLO morde solo se il luogo non e' gia' suo; CEDI CONTROLLO
	# solo se non lo si sta cedendo a chi lo tiene. Un terzo che non e' ne' il
	# proponente ne' il rivale soddisfa tutte e due.
	var proponent: String = str(context.get("proponent", ""))
	var rival: String = str(context.get("rival", ""))
	for entity_id in session.world["entities"]:
		if str(entity_id) != proponent and str(entity_id) != rival:
			region["control"] = str(entity_id)
			break
	# E il Calore a meta' pista: RAFFREDDA ha da dove scendere, SCALDA ha dove
	# salire. Il mucchio e' gia' stato letto all'apertura, e non si muove.
	var theme_id: String = str(data().tensions[TENSION].get("theme", ""))
	if theme_id != "":
		(session.world["theme_heat"] as Dictionary)[theme_id] = 3
	# E il filo col rivale non e' gia' nemico, o MUOVI UN RAPPORTO non muove.
	if rival != "":
		for key in [
			"%s|%s" % [proponent, rival], "%s|%s" % [rival, proponent],
		]:
			if (session.world["relations"] as Dictionary).has(str(key)):
				((session.world["relations"] as Dictionary)[str(key)] as Dictionary)["level"] = "NEUTRAL"


func _others(proponent: String) -> Array:
	var out: Array = []
	for entity_id in session.confluence.stance_order():
		if str(entity_id) != proponent:
			out.append(str(entity_id))
	return out


## Il proponente mette una carta vera sul tavolo: i bonus del fronte entrano
## solo su un fronte che ha carte, e lo smaltimento di I. scarta quello che e'
## stato impegnato — una carta inventata farebbe strillare l'applier.
func _proponent_commits_one(proponent: String) -> void:
	var hand: Array = session.service.hand(proponent)
	assert_true(hand.size() > 0, "il proponente ha una carta da mettere sul tavolo")
	assert_true(session.confluence.commit(proponent, [hand[0]]), "e la impegna")


func _log_says(needle: String) -> bool:
	for line in session.log.lines:
		if str(line).contains(needle):
			return true
	return false


## **La carta offre benefici e costi vivi, e ogni parte vede le caselle
## marcate per la sua domanda** (D-278, D-469).
func test_the_card_offers_benefits_and_costs() -> void:
	_open()
	var face: Dictionary = data().tensions[TENSION]["physical"]
	assert_eq(
		session.confluence.live_voices("benefits").size(), (face["benefits"] as Array).size(),
		"sul tavolo fabbricato ogni beneficio stampato e' vivo"
	)
	var live_costs: Array = []
	for voice in session.confluence.live_voices("costs"):
		live_costs.append(str((voice as Dictionary)["id"]))
	assert_eq(live_costs, _voices("costs"), "e ogni costo stampato morde, nell'ordine della carta")
	assert_true((face["failure"] as Array).size() >= 1, "e se cade, la carta dice gia' cosa succede")
	for side in ["A", "B"]:
		var question_id: String = session.confluence.side_question(side)
		var menu: Array = session.confluence.box_menu(side)
		assert_true(menu.size() > 0, "la parte %s ha caselle da posare" % side)
		var lists: Dictionary = {}
		for entry in menu:
			assert_true(
				((entry as Dictionary).get("for", []) as Array).has(question_id),
				"«%s» e' marcata per la domanda %s" % [str((entry as Dictionary)["id"]), side]
			)
			lists[str((entry as Dictionary)["list"])] = true
		assert_true(lists.has("benefits") and lists.has("costs"), "e sono benefici e costi insieme")


## **Una casella che non puo' fare niente non e' nel menu** (D-306).
##
## Al tavolo nessuno posa la pedina su «Riapri l'accesso» se il luogo non e'
## chiuso: si guarda la mappa e si vede. La casella si fabbrica (regola di
## casa): RIAPRI e' quella con l'interruttore piu' semplice — un luogo chiuso —
## e si marca per la domanda A, cosi' e' il proponente a poterla posare.
func test_a_casella_that_can_do_nothing_is_not_on_the_menu() -> void:
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var reopen: String = "B_REOPEN_PROVA"
	var benefits: Array = data().tensions[TENSION]["physical"]["benefits"] as Array
	benefits.append({
		"id": reopen, "verb": "REOPEN", "text": "Riapri l'accesso: il luogo torna raggiungibile.",
		"for": [session.confluence.side_question("A")],
	})
	var region_id: String = str(session.confluence.effect_context()["region_focus"])

	# Col luogo chiuso la casella e' viva: il mondo qui se l'e' fabbricato
	# `_open`, e la prova lo verifica invece di darlo per buono.
	assert_true(_offered("A").has(reopen), "col luogo tagliato fuori, RIAPRI si puo' posare")

	# Tolto il segno, la casella e' morta.
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).erase("condition:cut_off")
	assert_false(_offered("A").has(reopen), "senza niente di chiuso, RIAPRI non e' piu' sul menu")
	assert_false(
		session.confluence.place_box(proponent, reopen),
		"e non si posa nemmeno chiamandola per nome"
	)
	assert_true(str(session.confluence.last_error) != "", "il rifiuto dice perche'")
	# Il proponente non resta a mani vuote: le altre caselle sono ancora vive.
	assert_true(session.confluence.box_menu("A").size() > 0, "il menu non si svuota")

	# E rimesso il segno, la pedina si posa: lo zero di sopra era la regola,
	# non una casella cieca.
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).append("condition:cut_off")
	assert_true(session.confluence.place_box(proponent, reopen), "col luogo di nuovo chiuso si posa")
	assert_true(session.confluence.side_boxes("A", "benefits").has(reopen), "ed e' fra le pedine della A")
	# La DataSet e' condivisa: la casella fabbricata se ne va.
	benefits.pop_back()


## **Un fatto che il mondo ricorda gia' non si ricorda due volte** (D-308):
## la casella si spegne, come ogni altra che qui non farebbe niente (D-306).
func test_a_fact_the_world_already_holds_is_not_on_the_menu() -> void:
	var context: Dictionary = _open()
	var voice_id: String = _voice_with_verb("benefits", "REMEMBER")
	assert_ne(voice_id, "", "la carta offre un fatto da lasciare al mondo")
	var fact: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			fact = str((voice as Dictionary)["tag"])
	assert_ne(fact, "", "e il fatto ha un nome")
	assert_true(_offered("A").has(voice_id), "il mondo non lo ricorda ancora: la casella e' viva")

	(session.world["global_tags"] as Array).append(fact)
	assert_false(_offered("A").has(voice_id), "il mondo lo ricorda gia': la casella e' spenta")
	assert_false(
		session.confluence.place_box(str(context["proponent"]), voice_id),
		"e non si posa nemmeno chiamandola per nome"
	)


## **IL MONDO RICORDA: il Consiglio decide cosa il mondo ricordera'** (D-308).
##
## La memoria si posa sul **mondo**, non sul luogo: e' la sola casella del
## beneficio che esce dalla Regione in discussione. Mucchio a zero, una pedina
## sola sulla A e nessuno sulla B: la A vince, e il fatto resta.
func test_the_world_remembers_what_the_council_bought() -> void:
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	var voice_id: String = _voice_with_verb("benefits", "REMEMBER")
	assert_ne(voice_id, "", "la carta offre un fatto da lasciare al mondo")
	var fact: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			fact = str((voice as Dictionary)["tag"])
	assert_false((session.world["global_tags"] as Array).has(fact), "e il mondo non lo ricorda ancora")
	_hush_the_base()
	assert_true(session.confluence.place_box(proponent, voice_id), "il proponente posa la pedina")

	var result: Dictionary = session.confluence.resolve()
	assert_true(
		ConfluenceResolution.is_success(str(result["outcome"])),
		"una pedina contro nessuna, sopra un mucchio a zero: la A passa (%s)" % str(result["outcome"])
	)
	assert_eq(str(result["winner"]), "A", "e lo dice")
	assert_true((session.world["global_tags"] as Array).has(fact), "e adesso il mondo lo ricorda: «%s»" % fact)


## **Il mondo ricorda cosa il Consiglio ha posato: benefici E costi della
## parte che vince** (D-467 §4), e niente di quello che l'altra parte aveva
## posato. La A posa un beneficio e un costo, la B un costo; mucchio a zero,
## la A ha piu' pedine: vince, e sul mondo restano il Granaio e #razionato,
## non la cessione che la B voleva.
func test_on_success_benefits_and_costs_of_the_winning_side_apply() -> void:
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	var others: Array = _others(proponent)
	var region_id: String = str(session.confluence.effect_context()["region_focus"])
	_hush_the_base()

	var stone: String = _voice_with_verb("benefits", "BUILD_STONE")
	var condition: String = _voice_with_verb("costs", "ADD_CONDITION")
	var yield_it: String = _voice_with_verb("costs", "YIELD_CONTROL")
	assert_true(_offered("A").has(stone) and _offered("A").has(condition), "la A ha il Granaio e #razionato")
	assert_true(_offered("B").has(yield_it), "e la B ha la cessione")
	assert_true(session.confluence.place_box(proponent, stone), "il proponente posa il beneficio")
	assert_true(session.confluence.join_side(str(others[0]), "A"), "un alleato sta con la A")
	assert_true(session.confluence.place_box(str(others[0]), condition), "e posa il costo: posare un costo e' sostenere")
	assert_true(session.confluence.join_side(str(others[1]), "B"), "un avversario prende la B")
	assert_true(session.confluence.place_box(str(others[1]), yield_it), "e posa la sua pedina")

	var held_by: Variant = (session.world["regions"][region_id] as Dictionary)["control"]
	var result: Dictionary = session.confluence.resolve()
	assert_true(ConfluenceResolution.is_success(str(result["outcome"])), "due pedine contro una: la A passa")
	assert_eq(int(result["pedine_a"]), 2, "le pedine della A sono contate")
	assert_eq(int(result["pedine_b"]), 1, "e quelle della B")
	assert_true(_log_says("H. Beneficio: %s" % _text_of("benefits", stone)), "il beneficio posato si applica")
	assert_true(_log_says("H. Prezzo: %s" % _text_of("costs", condition)), "e il costo posato dalla stessa parte si paga")
	assert_false(_log_says("H. Prezzo: %s" % _text_of("costs", yield_it)), "la pedina della parte che ha perso non fa niente")
	var region: Dictionary = session.world["regions"][region_id]
	assert_true((region["tags"] as Array).has("condition:rationed"), "sul luogo resta #razionato")
	assert_eq(_stone_owner(region_id, "STR_GRANARY"), proponent, "e il Granaio e' di chi propone")
	assert_eq(region["control"], held_by, "e il controllo non e' stato ceduto")


## **Se non passa nessuna, scattano gli effetti stampati.** Non li sceglie
## nessuno: la carta dice che il mondo non sopporta l'indecisione, e quello
## succede. Mucchio a 99: nessuna parte ci arriva, per quante pedine posi.
func test_on_failure_the_printed_effects_fire() -> void:
	var context: Dictionary = _open(99)
	var proponent: String = str(context["proponent"])
	var region_id: String = str(session.confluence.effect_context()["region_focus"])
	var stone: String = _voice_with_verb("benefits", "BUILD_STONE")
	assert_true(session.confluence.place_box(proponent, stone), "il proponente posa un beneficio")
	_proponent_commits_one(proponent)
	# #fame lo ha messo il tavolo fabbricato: si toglie, cosi' l'effetto
	# stampato ha qualcosa da lasciare e la prova lo vede sul mondo.
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).erase("condition:starving")

	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "nessuna parte arriva a 99")
	assert_eq(str(result["winner"]), "", "e non vince nessuno")
	for voice in (data().tensions[TENSION]["physical"]["failure"] as Array):
		assert_true(
			_log_says("H. Il mondo non aspetta: %s" % str((voice as Dictionary)["text"])),
			"il verbale legge l'effetto stampato: «%s»" % str((voice as Dictionary)["text"]).substr(0, 30)
		)
	assert_true(
		((session.world["regions"][region_id] as Dictionary)["tags"] as Array).has("condition:starving"),
		"e #fame e' sul luogo"
	)
	assert_false(_log_says("H. Beneficio: %s" % _text_of("benefits", stone)), "la pedina posata non si applica")


## **La Cicatrice e' un costo come gli altri** (D-303, parola del committente).
## Sta fra i costi della carta, si posa sulla parte come ogni altra pedina, e
## quando la parte vince scatta come tutti gli altri: resta una Cicatrice sul
## luogo.
func test_the_scar_is_a_cost_like_the_others() -> void:
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	var region_id: String = str(session.confluence.effect_context()["region_focus"])
	var scar_id: String = _voice_with_verb("costs", "SCAR")
	assert_ne(scar_id, "", "la carta offre una Cicatrice")
	var side: String = "A" if _offered("A").has(scar_id) else "B"
	assert_true(_offered(side).has(scar_id), "ed e' una casella della carta come le altre")
	_hush_the_base()
	if side == "B":
		var other: String = str(_others(proponent)[0])
		assert_true(session.confluence.join_side(other, "B"), "chi la posa sta dalla sua parte")
		assert_true(session.confluence.place_box(other, scar_id), "la Cicatrice si posa come qualunque altro costo")
	else:
		assert_true(session.confluence.place_box(proponent, scar_id), "la Cicatrice si posa come qualunque altro costo")
	assert_true(session.confluence.side_boxes(side, "costs").has(scar_id), "ed e' fra i costi della parte")

	var before: int = (session.world["scars"] as Array).size()
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["winner"]), side, "la parte con la pedina vince")
	var left: bool = false
	for i in range(before, (session.world["scars"] as Array).size()):
		if str(((session.world["scars"] as Array)[i] as Dictionary)["region_id"]) == region_id:
			left = true
	assert_true(left, "e sul luogo resta una Cicatrice: il costo scatta come gli altri")


## **La carta vince, e la Pietra gia' alzata passa a chi l'ha posata**
## (D-305, ISSUES 86).
##
## Il caso e' quello vero del tavolo: nel luogo c'e' gia' un Granaio, di un
## altro. Il proponente posa «Costruisci 1 Pietra: Granaio». Prima di D-305
## quel BUILD era un no-op silenzioso; adesso al tavolo c'e' un Granaio solo,
## e quello e' quello che il Consiglio ha deciso: **passa di mano**, e il
## verbale lo dice.
func test_a_bought_stone_already_standing_passes_to_the_buyer() -> void:
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	var region: String = str(session.confluence.effect_context()["region_focus"])
	var voice_id: String = _voice_with_verb("benefits", "BUILD_STONE")
	assert_ne(voice_id, "", "la carta offre di costruire una Pietra")
	var stone: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			stone = str((voice as Dictionary)["structure"])

	# La Pietra si pianta a mano, intestata a un altro: la prova si fabbrica il
	# caso invece di sperare che i dati spediti glielo regalino.
	var other: String = str(_others(proponent)[0])
	((session.world["regions"][region] as Dictionary)["structures"] as Array).append({
		"structure_type": stone, "grade": 1, "owner": other,
	})
	assert_eq(_stone_owner(region, stone), other, "il Granaio c'e' gia', ed e' di un altro")
	_hush_the_base()
	assert_true(session.confluence.place_box(proponent, voice_id), "e la casella e' viva lo stesso: passa di mano")

	var before: int = session.log.lines.size()
	var result: Dictionary = session.confluence.resolve()
	assert_true(ConfluenceResolution.is_success(str(result["outcome"])), "la A passa")
	assert_eq(_stone_owner(region, stone), proponent, "la Pietra posata e' di chi l'ha posata")
	assert_eq(_stones_of_type(region, stone), 1, "e resta una sola: al tavolo c'e' un Granaio solo")
	var said: bool = false
	for i in range(before, session.log.lines.size()):
		if str(session.log.lines[i]).contains("passa a"):
			said = true
	assert_true(said, "e il verbale dice che e' passata di mano, invece di tacere")


## Di chi e' la Pietra di questo tipo in questo luogo, o "" se non c'e'.
func _stone_owner(region: String, type_id: String) -> String:
	for structure in ((session.world["regions"][region] as Dictionary)["structures"] as Array):
		if str((structure as Dictionary)["structure_type"]) == type_id:
			return str((structure as Dictionary).get("owner", ""))
	return ""


## Quante Pietre di questo tipo stanno in questo luogo. Deve essere una.
func _stones_of_type(region: String, type_id: String) -> int:
	var count: int = 0
	for structure in ((session.world["regions"][region] as Dictionary)["structures"] as Array):
		if str((structure as Dictionary)["structure_type"]) == type_id:
			count += 1
	return count


## **E la carta dice cosa ha lasciato sul mondo** (D-292).
##
## La Conseguenza d'autore narrava ogni suo Effetto — «Su Valle Verde resta un
## segno: razionata» — e la voce della carta no: il verbale diceva «Beneficio:
## costruisci un Granaio» e poi taceva. Meta' del Consiglio scriveva in
## silenzio, e una sonda che contava quello che il tavolo legge dava **zero**
## alla carta e 443 alla frase d'autore: un numero falso, prodotto da un difetto
## vero.
func test_the_card_says_what_it_left_behind() -> void:
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	var stone: String = _voice_with_verb("benefits", "BUILD_STONE")
	assert_ne(stone, "", "la carta offre di costruire una Pietra")
	_hush_the_base()
	assert_true(session.confluence.place_box(proponent, stone), "il proponente posa la Pietra")
	var before: int = session.log.lines.size()
	var result: Dictionary = session.confluence.resolve()
	assert_true(ConfluenceResolution.is_success(str(result["outcome"])), "la A passa")

	# La riga della voce c'e' — quella c'era gia'. Quello che si pretende qui e'
	# **la riga subito sotto**: cosa quella voce ha scritto sul mondo. Il
	# registro incolonna «- H. Beneficio: ...» e sotto «-   il mondo ricorda…»,
	# quindi una riga narrata e' una riga che **non** comincia con la lettera
	# di un passo.
	var said: int = -1
	for i in range(before, session.log.lines.size()):
		if str(session.log.lines[i]).contains("H. Beneficio: %s" % _text_of("benefits", stone)):
			said = i
	assert_true(said >= 0, "il verbale legge il beneficio posato")
	assert_true(said + 1 < session.log.lines.size(), "e non e' l'ultima riga del verbale")
	var below: String = _unbulleted(str(session.log.lines[said + 1]))
	assert_false(
		_is_step(below),
		"subito sotto il beneficio c'e' cosa ha lasciato, non il passo dopo: «%s»" % below
	)


## Una riga del registro senza il trattino dell'elenco.
func _unbulleted(line: String) -> String:
	var text: String = line.strip_edges()
	return text.substr(2).strip_edges() if text.begins_with("- ") else text


## «H. …», «I. …»: una riga che apre un passo della sequenza, non un Effetto.
func _is_step(text: String) -> bool:
	return text.length() > 2 and text[1] == "." and "ABCDEFGHIJK".contains(text[0])


## **Il silenzio avvantaggia il proponente**, della misura scritta nei dati -
## e solo un proponente che ci ha messo del proprio: il bonus entra nel fronte,
## e un fronte a zero carte resta zero come ogni altro peso del Consiglio.
## Nella regola nuova il silenzio e' **nessuno che prende parte**: le
## posizioni restano vuote, e `resolve` legge il numero.
func test_silence_advantages_the_proponent_by_the_written_number() -> void:
	var with_rule: Dictionary = _silent_council(3)
	var without: Dictionary = _silent_council(0)
	assert_eq(
		int(with_rule["margin"]) - int(without["margin"]), 3,
		"il silenzio vale esattamente il numero scritto nei dati"
	)
	assert_true(
		bool(with_rule["spoke"]),
		"la regola parla nel verbale: un bonus muto sarebbe invisibile al tavolo"
	)
	assert_false(bool(without["spoke"]), "a regola spenta il silenzio non parla")


## **Basta una voce a rompere il silenzio.** Un solo seggio che prende la B,
## anche senza posare e senza carte, e il bonus non esiste.
func test_one_declared_stance_breaks_the_silence() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_TEST"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = 3
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	var others: Array = _others(proponent)
	assert_true(session.confluence.join_side(str(others[0]), "B"), "un seggio prende l'altra domanda")
	session.confluence.pass_turn(str(others[0]))
	for i in range(1, others.size()):
		session.confluence.pass_turn(str(others[i]))
	_proponent_commits_one(proponent)
	var result: Dictionary = session.confluence.resolve()
	assert_false(
		_log_says("Il tavolo tace"),
		"una posizione presa rompe il silenzio, anche senza carte"
	)
	assert_eq(int(result["cards_a"]), int(result["support_total"]), "e la A vale le sue carte, senza il bonus")


## Un Consiglio dove nessuno prende parte, col bonus del silenzio a `bonus`:
## torna margine e voce a verbale. Sessione nuova ogni volta, cosi' i due giri
## si confrontano alla pari - e il log si legge **prima** che la sessione dopo
## lo butti via, che e' l'errore da cui questa funzione e' nata.
func _silent_council(bonus: int) -> Dictionary:
	new_session()
	var chronicle: Dictionary = data().chronicles["CHR_TEST"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = bonus
	var context: Dictionary = _open(0)
	var proponent: String = str(context["proponent"])
	for entity_id in _others(proponent):
		session.confluence.pass_turn(str(entity_id))
	_proponent_commits_one(proponent)
	var result: Dictionary = session.confluence.resolve()
	return {
		"margin": int(result["margin"]),
		"spoke": _log_says("Il tavolo tace: il silenzio avvantaggia il proponente"),
	}
