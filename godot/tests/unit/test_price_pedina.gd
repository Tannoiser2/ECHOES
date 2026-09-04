extends "res://tests/test_case.gd"
## L'economia del Consiglio, e la regola del silenzio (D-280, D-267).
##
## Parola del committente, sulla sua carta d'esempio: **il proponente compra i
## benefici, gli avversari scelgono in che moneta paga** — un costo per ogni
## beneficio oltre il primo, e il tetto e' tre (D-303: la Cicatrice non
## compra, e' un costo come gli altri). Se
## la proposta passa si applicano benefici **e** costi; se cade, scattano gli
## effetti stampati, che non sceglie nessuno. E la regola anti-passivita' della
## roadmap (PZ-5): se tutti si astengono, il silenzio avvantaggia il
## proponente - un numero nei dati, reversibile.
##
## Gli esiti si forzano col dado truccato e col morso del mondo annullato: una
## prova che dipendesse dal caso o dai segni di partenza smetterebbe di provare
## senza dirlo.

const CouncilEconomy := preload("res://scripts/confluence/council_economy.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

const TENSION: String = "TEN_FAMINE"


## Un dado che dice sempre lo stesso numero: il World Factor diventa una scelta
## della prova, non un caso.
class RiggedDie extends RefCounted:
	var value: int = 3

	func roll_d6() -> int:
		return value


## die -> World Factor: [-2, -1, 0, 0, 1, 2]. La prova sceglie il dado che
## produce il fattore voluto.
const DIE_FOR_FACTOR: Dictionary = {-2: 1, -1: 2, 0: 3, 1: 5, 2: 6}


var _hushed: String = ""
var _hushed_template: String = ""
var _hushed_said: Array = []


func before_each() -> void:
	new_session()


func after_each() -> void:
	# La regola del silenzio e' dato spedito (1): le prove che la spengono o la
	# gonfiano devono rimetterla, o il prossimo test la troverebbe storta.
	var chronicle: Dictionary = data().chronicles["CHR_TEST"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = 1
	# E la frase d'autore zittita torna a parlare (D-305).
	if _hushed != "":
		for proposition in (data().confluence_templates[_hushed_template]["propositions"] as Array):
			if str((proposition as Dictionary)["id"]) == _hushed:
				(proposition as Dictionary)["success_consequences"] = _hushed_said
		_hushed = ""


## **Zittisce la frase d'autore della proposta in dibattito** (D-305).
##
## Da D-305 la carta si spende **per ultima**, e la frase d'autore non le passa
## piu' sopra. Ma la frase puo' ancora fare *prima* la stessa cosa che la carta
## vende — sui dati spediti, 67 Effetti d'autore parlano la lingua delle
## caselle (ISSUES 87) — e allora il beneficio comprato trova il lavoro gia'
## fatto e non lascia niente di nuovo.
##
## Una prova che vuole vedere **cosa lascia la casella** deve quindi fabbricarsi
## il silenzio, invece di sperare che la proposta pescata non duplichi il verbo:
## e' la regola di casa, e qui morde per la terza volta oggi.
func _hush_the_authored_voice() -> void:
	_hushed_template = str(session.confluence.current["template_id"])
	_hushed = str(session.confluence.current["proposition_id"])
	for proposition in (data().confluence_templates[_hushed_template]["propositions"] as Array):
		if str((proposition as Dictionary)["id"]) == _hushed:
			_hushed_said = ((proposition as Dictionary)["success_consequences"] as Array).duplicate()
			(proposition as Dictionary)["success_consequences"] = []


func _rig(factor: int) -> void:
	var die: RiggedDie = RiggedDie.new()
	die.value = int(DIE_FOR_FACTOR[factor])
	session.confluence.rng = die


## Le voci scritte sulla carta in dibattito. Le prove le leggono invece di
## scriverle a mano: la faccia e' dato spedito, e un id fisso qui dentro
## smetterebbe di provare il giorno che la carta cambia parole (D-278).
func _voices(list_name: String) -> Array:
	var out: Array = []
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)[list_name] as Array):
		out.append(str((voice as Dictionary)["id"]))
	return out


## I benefici stampati sulla carta in dibattito.
func _benefits() -> Array:
	return _voices("benefits")


func _first_cost() -> String:
	return str(_voices("costs")[0])


func _other_cost() -> String:
	return str(_voices("costs")[1])


func _a_cost() -> String:
	return _other_cost()


## Il terzo costo della carta: serve alle prove che vogliono una voce **diversa**
## da quella che il mondo prenderebbe da solo (la prima della lista).
func _third_cost() -> String:
	return str(_voices("costs")[2])


func _open_with_proposition() -> Dictionary:
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence su %s si apre" % TENSION)
	var options: Array = session.confluence.available_propositions()
	assert_true(options.size() > 0, "almeno una proposta disponibile")
	session.confluence.set_proposition(str(options[0]["id"]))
	_make_every_casella_live()
	return context


## **Il tavolo in cui ogni casella della carta puo' fare qualcosa** (D-306).
##
## Da D-306 il menu offre solo le caselle vive: «Riapri l'accesso» non si compra
## dove non c'e' niente di chiuso. Una prova che vuole misurare **l'economia**
## — uno gratis, ogni altro un costo, tetto tre — ha bisogno della carta intera,
## quindi si fabbrica il mondo che la rende intera, invece di dipendere da quale
## tessera e' uscita dal seme. E' la regola di casa, e in questa giornata e' la
## quarta volta che serve.
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
	# salire.
	var theme_id: String = str(data().tensions[TENSION].get("theme", ""))
	if theme_id != "":
		if not session.world.has("theme_heat"):
			session.world["theme_heat"] = {}
		(session.world["theme_heat"] as Dictionary)[theme_id] = 3
	# **E le caselle di D-366**, che guardano cose che prima nessuna casella
	# guardava: chi porta cosa addosso, chi sta dove, il filo fra due case, il
	# grado di una Pietra. Una carta con quelle caselle in un mondo che non le
	# regge offre meno di quello che stampa, ed e' giusto — ma allora non e'
	# piu' il tavolo su cui si misura l'economia.
	if proponent != "":
		((session.world["entities"][proponent] as Dictionary)["tags"] as Array).erase("renowned")
	if rival != "":
		# Il rivale sta **qui** e non **accanto**: cosi' UNA PRESENZA SE NE VA
		# ha una pedina da togliere e UNA PRESENZA ENTRA ha dove posarla.
		(session.world["entities"][rival] as Dictionary)["presence"] = [region_id]
		# E il filo con lui non e' gia' nemico, o MUOVI UN RAPPORTO non muove.
		for key in [
			"%s|%s" % [proponent, rival], "%s|%s" % [rival, proponent],
		]:
			if (session.world["relations"] as Dictionary).has(str(key)):
				((session.world["relations"] as Dictionary)[str(key)] as Dictionary)["level"] = "NEUTRAL"
	# Una Foresta cresciuta, cosi' UNA PIETRA SCENDE ha un grado da scendere.
	_stand_a_forest(region, 2)


## Una Foresta in piedi al grado voluto, senza toccare le altre Pietre.
func _stand_a_forest(region: Dictionary, grade: int) -> void:
	for structure in (region["structures"] as Array):
		if str((structure as Dictionary).get("structure_type", "")) == "STR_FOREST":
			(structure as Dictionary)["grade"] = grade
			return
	(region["structures"] as Array).append({
		"structure_type": "STR_FOREST", "grade": grade, "owner": null,
	})


func _others(proponent: String) -> Array:
	var out: Array = []
	for entity_id in session.confluence.stance_order():
		if str(entity_id) != proponent:
			out.append(str(entity_id))
	return out


## Il fattore del mondo che annulla il morso dei segni (ISSUES 24): cosi' il
## margine e' esattamente S - O, qualunque tavolo sia uscito dal seme.
func _factor_cancelling_bite(proponent: String) -> int:
	var bite: Dictionary = TagRules.council_world_factor(
		data(), session.world, TENSION, proponent
	)
	return clampi(-int(bite["delta"]), -2, 2)


## **Il menu viene dal template, e la prima voce e' quella del mondo.**
func test_the_card_offers_benefits_and_costs() -> void:
	_open_with_proposition()
	var face: Dictionary = data().tensions[TENSION]["physical"]
	assert_eq(
		session.confluence.benefit_menu().size(), (face["benefits"] as Array).size(),
		"il proponente vede i benefici stampati sulla carta"
	)
	assert_eq(
		session.confluence.price_menu()["cost"], _voices("costs"),
		"e il fronte avverso vede i costi stampati"
	)
	assert_true((face["failure"] as Array).size() >= 1, "e se cade, la carta dice gia' cosa succede")


## **L'economia: due sono gratis, ogni altro costa un gettone** ([D-417](../../docs/DECISIONS.md#d-417),
## ISSUES 122 + 125, parola del committente: *«due acquisti liberi»*). E' la riga
## in mezzo alla carta, ed e' quella che rende il Consiglio una decisione invece
## di un menu — con la differenza che la moneta il proponente se l'e' guadagnata
## un turno prima, giocando una carta Asset dalla sua faccia RIVENDICARE.
##
## Era **uno**, ed era D-280 alla lettera. Misurato: con un solo acquisto libero
## le caselle **vive** per Consiglio erano una — le altre ventitre' esistevano
## per quando la prima non si poteva comprare — e i benefici comprati per
## Consiglio erano 1,22. Coi due liberi sono **2,25**.
func test_one_benefit_is_free_and_every_other_costs_one() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var benefits: Array = _benefits()
	assert_true(session.confluence.set_benefits([]), "si puo' anche non comprare niente")
	var free: int = CouncilEconomy.FREE_BENEFITS
	assert_true(
		session.confluence.set_benefits(benefits.slice(0, free)),
		"i primi %d si comprano" % free
	)
	assert_eq(session.confluence.claim_tokens(proponent), 0, "e sono gratis")
	assert_false(
		session.confluence.set_benefits(benefits.slice(0, free + 1)),
		"quello dopo, senza gettoni, non si compra"
	)
	_give_tokens(proponent, 2)
	assert_true(
		session.confluence.set_benefits(benefits.slice(0, free + 1)),
		"col gettone si'"
	)
	assert_eq(session.confluence.claim_tokens(proponent), 1, "e costa un gettone")
	assert_false(
		session.confluence.set_benefits(benefits.slice(0, CouncilEconomy.MAX_BENEFITS + 1)),
		"e il tetto e' tre: sulla carta non ci stanno altre pedine (D-303)"
	)
	assert_eq(
		session.confluence.claim_tokens(proponent), 1,
		"il rifiuto non tocca quello che era gia' comprato"
	)
	# **E quello che non si compra piu' torna in mano**: le pedine si posano e
	# si tolgono, e la borsa segue.
	assert_true(
		session.confluence.set_benefits(benefits.slice(0, free)),
		"si torna ai gratis"
	)
	assert_eq(session.confluence.claim_tokens(proponent), 2, "e i gettoni tornano")
	assert_false(
		session.confluence.set_benefits([str(benefits[0]), str(benefits[0])]),
		"una pedina per voce"
	)
	assert_false(
		session.confluence.set_benefits(["B_INVENTATO"]),
		"e solo sui benefici che la carta stampa"
	)


## **IL MONDO RICORDA: il Consiglio decide cosa il mondo ricordera'** (D-308,
## ISSUES 76 strada a).
##
## Il verbo che mancava. I cinque verbi del beneficio spostavano cose —
## riapri, ripulisci, costruisci, cambia controllo, raffredda — e **nessuno
## scriveva un fatto**. Misurato: dei segni che le otto case dichiarano di
## voler lasciare nel mondo, un Consiglio ne sapeva dare sette, e tutti e
## sette erano Pietre. Il resto sono memorie, e solo una frase d'autore le
## sapeva scrivere.
##
## La memoria si posa sul **mondo**, non sul luogo: e' la sola casella del
## beneficio che esce dalla Regione in discussione.
func test_the_world_remembers_what_the_council_bought() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var fact: String = ""
	var voice_id: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary).get("verb", "")) == "REMEMBER":
			voice_id = str((voice as Dictionary)["id"])
			fact = str((voice as Dictionary)["tag"])
	assert_ne(fact, "", "la carta offre un fatto da lasciare al mondo")
	assert_false(
		(session.world["global_tags"] as Array).has(fact),
		"e il mondo non lo ricorda ancora"
	)

	var offered: Array = []
	for voice in session.confluence.benefit_menu():
		offered.append(str((voice as Dictionary)["id"]))
	assert_true(offered.has(voice_id), "la casella e' viva: il fatto non c'e' ancora")
	assert_true(session.confluence.set_benefits([voice_id]), "il proponente la compra")

	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_true(ConfluenceResolution.is_success(str(result["outcome"])), "la proposta passa")
	assert_true(
		(session.world["global_tags"] as Array).has(fact),
		"e adesso il mondo lo ricorda: «%s»" % fact
	)


## **Un fatto che il mondo ricorda gia' non si ricorda due volte** (D-308):
## la casella si spegne, come ogni altra che qui non farebbe niente (D-306).
func test_a_fact_the_world_already_holds_is_not_on_the_menu() -> void:
	_open_with_proposition()
	var fact: String = ""
	var voice_id: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary).get("verb", "")) == "REMEMBER":
			voice_id = str((voice as Dictionary)["id"])
			fact = str((voice as Dictionary)["tag"])
	assert_ne(fact, "", "la carta offre un fatto da lasciare al mondo")

	(session.world["global_tags"] as Array).append(fact)
	var offered: Array = []
	for voice in session.confluence.benefit_menu():
		offered.append(str((voice as Dictionary)["id"]))
	assert_false(offered.has(voice_id), "il mondo lo ricorda gia': la casella e' spenta")
	assert_false(
		session.confluence.set_benefits([voice_id]),
		"e non si compra nemmeno chiamandola per nome"
	)


## **Una casella che non puo' fare niente non si compra** (D-306).
##
## Al tavolo nessuno posa la pedina su «Riapri l'accesso» se il luogo non e'
## chiuso: si guarda la mappa e si vede. Misurato prima della regola, il **44%**
## dei benefici comprati non lasciava niente — e si pagava lo stesso.
##
## La prova toglie il segno che rende viva la casella, e pretende due cose: che
## la casella sparisca dal menu, e che comprarla si rifiuti anche nominandola
## per id.
func test_a_casella_that_can_do_nothing_is_not_on_the_menu() -> void:
	# **La casella si fabbrica** (regola di casa): da D-453 il menu e' a quattro
	# e RIAPRI non sta piu' sulla Carestia. La regola che si prova — una
	# casella che non farebbe niente non si offre — vale per qualunque casella,
	# e RIAPRI e' quella con l'interruttore piu' semplice: un luogo chiuso.
	var reopen: String = "B_REOPEN_PROVA"
	var benefits: Array = data().tensions[TENSION]["physical"]["benefits"] as Array
	benefits.append({"id": reopen, "verb": "REOPEN", "text": "Riapri l'accesso: il luogo torna raggiungibile."})
	var context: Dictionary = _open_with_proposition()
	var region_id: String = str(session.confluence.effect_context()["region_focus"])

	# Col luogo chiuso la casella e' viva: il mondo qui se l'e' fabbricato
	# `_open_with_proposition`, e la prova lo verifica invece di darlo per buono.
	var offered: Array = []
	for voice in session.confluence.benefit_menu():
		offered.append(str((voice as Dictionary)["id"]))
	assert_true(offered.has(reopen), "col luogo tagliato fuori, RIAPRI si puo' comprare")
	assert_true(session.confluence.set_benefits([reopen]), "e si compra")

	# Tolto il segno, la casella e' morta.
	((session.world["regions"][region_id] as Dictionary)["tags"] as Array).erase("condition:cut_off")
	offered = []
	for voice in session.confluence.benefit_menu():
		offered.append(str((voice as Dictionary)["id"]))
	assert_false(offered.has(reopen), "senza niente di chiuso, RIAPRI non e' piu' sul menu")
	assert_false(
		session.confluence.set_benefits([reopen]),
		"e non si compra nemmeno chiamandola per nome"
	)
	assert_true(str(session.confluence.last_error) != "", "il rifiuto dice perche'")
	# Il proponente non resta a mani vuote: le altre caselle sono ancora vive.
	assert_true(session.confluence.benefit_menu().size() > 0, "il menu non si svuota")
	# La DataSet e' condivisa: la casella fabbricata se ne va.
	benefits.pop_back()


## **E non si compra piu' di quanto si possa pagare** (D-306). Il primo
## beneficio e' gratis; ogni altro vuole un costo che morda. Se sulla carta ne
## resta vivo uno solo, il tetto scende da tre a due.
##
## Il caso si costruisce fino in fondo, senza rami che potrebbero non provare
## niente: si spengono cinque costi su sei — i tre che posano un segno gia'
## posato, SCALDA TEMA col Calore al tetto, CEDI CONTROLLO verso chi il luogo
## lo tiene gia' — e resta la Cicatrice, che morde sempre.
func test_you_cannot_buy_more_than_you_can_pay_for() -> void:
	_open_with_proposition()
	var region_id: String = str(session.confluence.effect_context()["region_focus"])
	var region: Dictionary = session.world["regions"][region_id]
	assert_true(
		session.confluence.benefit_menu().size() >= 3,
		"il tavolo fabbricato offre almeno tre benefici vivi"
	)
	# **Sette da D-343**: ALZA LA DOMANDA e' entrata nel vocabolario. Il numero
	# si legge dal vocabolario che esegue, non si riscrive qui: una casella
	# nuova domani non deve far fallire questa prova per il motivo sbagliato.
	# Il numero si legge dalla **carta**, non si riscrive qui: una casella
	# nuova domani non deve far fallire questa prova per il motivo sbagliato.
	# Fino a D-366 si leggeva dal vocabolario, e i due numeri erano lo stesso
	# perche' ogni carta portava una voce per verbo; adesso il vocabolario ha
	# piu' verbi di quante pedine stiano su una carta, e quello che questa prova
	# pretende e' che **tutto quello che la carta stampa morda**.
	assert_eq(
		(session.confluence.price_menu()["cost"] as Array).size(),
		((data().tensions[TENSION]["physical"]["costs"]) as Array).size(),
		"tutti i costi stampati sulla carta mordono"
	)

	var tags: Array = region["tags"] as Array
	for tag in ["condition:rationed", "structure:tollgate", "condition:indebted"]:
		if not tags.has(tag):
			tags.append(tag)
	var theme_id: String = str(data().tensions[TENSION].get("theme", ""))
	(session.world["theme_heat"] as Dictionary)[theme_id] = 6
	# E **tutte** le domande in cima alla loro traccia: ALZA LA DOMANDA non ha
	# piu' dove andare, come SCALDA TEMA col Calore al tetto.
	#
	# Tutte e non solo quella in discussione: da D-366 una casella puo' chiamare
	# per nome un'altra domanda — la carta della Carestia alza quella legata — e
	# spegnere la sola domanda a fuoco lascerebbe viva la casella gemella.
	# Spegnere tutta la pista e' anche piu' robusto: una carta che domani
	# chiamasse una terza domanda non farebbe fallire questa prova per la
	# ragione sbagliata.
	for asked in session.world["tensions"]:
		(session.world["tensions"][str(asked)] as Dictionary)["current_value"] = int(
			(data().tensions[str(asked)] as Dictionary)["threshold"]
		)
	# CEDI CONTROLLO cede al rivale: se il luogo e' gia' suo non toglie niente,
	# e se la questione non ha un rivale cede alla terra — allora non morde su
	# un luogo che gia' non e' di nessuno.
	# Il rivale si legge da `effect_context()`, che e' quello che le caselle
	# guardano: il contesto restituito da `open()` e' un'altra cosa, e prenderlo
	# di li' faceva fallire la prova per la ragione sbagliata.
	var rival: String = str(session.confluence.effect_context().get("rival", ""))
	if rival == "":
		region["control"] = null
	else:
		region["control"] = rival
	# E le caselle di D-366 spente una per una, con lo stesso metro: si spegne
	# quello che guardano, non la casella.
	if rival != "":
		# Il rivale sta gia' anche accanto: UNA PRESENZA ENTRA non ha dove
		# entrare. E il filo con lui e' gia' nemico: MUOVI UN RAPPORTO non muove.
		var next_door: Array = (session.world.get("adjacency", {}) as Dictionary).get(
			region_id, []
		) as Array
		var camped: Array = [region_id]
		if not next_door.is_empty():
			camped.append(str(next_door[0]))
		(session.world["entities"][rival] as Dictionary)["presence"] = camped
		for key in [
			"%s|%s" % [str(session.confluence.effect_context().get("proponent", "")), rival],
			"%s|%s" % [rival, str(session.confluence.effect_context().get("proponent", ""))],
		]:
			if (session.world["relations"] as Dictionary).has(str(key)):
				((session.world["relations"] as Dictionary)[str(key)] as Dictionary)["level"] = "ENEMY"
	# E la Foresta al grado minimo: UNA PIETRA SCENDE non ha dove scendere.
	_stand_a_forest(region, 1)

	assert_eq(
		(session.confluence.price_menu()["cost"] as Array).size(), 1,
		"resta viva solo la Cicatrice"
	)
	var live: Array = session.confluence.benefit_menu()
	assert_true(live.size() >= 3, "i benefici vivi bastano ancora per provarci")
	var three: Array = [
		str((live[0] as Dictionary)["id"]),
		str((live[1] as Dictionary)["id"]),
		str((live[2] as Dictionary)["id"]),
	]
	# **Il tetto lo dicono i gettoni** (D-387), non piu' i costi vivi: quello
	# che il proponente puo' posare dipende da quello che ha in mano.
	var proponent: String = str(session.confluence.current["proponent"])
	var free: int = CouncilEconomy.FREE_BENEFITS
	# **Il tetto e' i gratis piu' i gettoni.** Il numero si legge dalla regola e
	# non si riscrive qui: il giorno in cui il committente cambia i liberi,
	# questa prova deve misurare ancora la regola e non la taratura di ieri.
	assert_false(
		session.confluence.set_benefits(three.slice(0, free + 1)),
		"a mani vuote non si compra oltre i %d gratis" % free
	)
	_give_tokens(proponent, 1)
	assert_true(
		session.confluence.set_benefits(three.slice(0, free + 1)),
		"col gettone si', perche' i primi %d sono gratis e il dopo ha la sua moneta" % free
	)
	assert_eq(session.confluence.claim_tokens(proponent), 0, "e il gettone e' speso")


## **La carta vince, e la Pietra gia' alzata passa a chi l'ha comprata**
## (D-305, ISSUES 86).
##
## Il caso e' quello vero del tavolo: nel luogo c'e' gia' un Granaio, di un
## altro. Il proponente compra la casella «Costruisci 1 Pietra: Granaio» e la
## paga. Prima di D-305 quel BUILD era un no-op silenzioso e il beneficio
## comprato non lasciava niente; adesso al tavolo c'e' un Granaio solo, e quello
## e' quello che il Consiglio ha comprato: **passa di mano**, e il verbale lo
## dice.
func test_a_bought_stone_already_standing_passes_to_the_buyer() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var region: String = str(session.confluence.effect_context()["region_focus"])
	assert_ne(region, "", "il Consiglio discute di un luogo")
	var stone: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary).get("verb", "")) == "BUILD_STONE":
			stone = str((voice as Dictionary)["structure"])
	assert_ne(stone, "", "la carta offre di costruire una Pietra")

	# La Pietra si pianta a mano, intestata a un altro: la prova si fabbrica il
	# caso invece di sperare che i dati spediti glielo regalino.
	var other: String = str(_others(proponent)[0])
	((session.world["regions"][region] as Dictionary)["structures"] as Array).append({
		"structure_type": stone, "grade": 1, "owner": other,
	})
	assert_eq(_stone_owner(region, stone), other, "il Granaio c'e' gia', ed e' di un altro")

	var bought: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary).get("verb", "")) == "BUILD_STONE":
			bought = str((voice as Dictionary)["id"])
	session.confluence.set_benefits([bought])
	_rig(_factor_cancelling_bite(proponent))
	var before: int = session.log.lines.size()
	var result: Dictionary = session.confluence.resolve()
	assert_true(ConfluenceResolution.is_success(str(result["outcome"])), "la proposta passa")
	assert_eq(
		_stone_owner(region, stone), proponent,
		"la Pietra comprata e pagata e' di chi l'ha comprata"
	)
	assert_eq(
		_stones_of_type(region, stone), 1,
		"e resta una sola: al tavolo c'e' un Granaio solo"
	)
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


## **La Cicatrice e' un costo, non una moneta d'acquisto** (D-303, parola del
## committente). Sta fra i sei costi che il fronte avverso puo' scegliere, e
## quando la sceglie scatta come tutti gli altri; quello che non fa piu' e'
## sfondare il tetto dei benefici.
func test_the_scar_is_a_cost_like_the_others() -> void:
	var context: Dictionary = _open_with_proposition()
	var scar_id: String = ""
	for voice in (data().tensions[TENSION]["physical"]["costs"] as Array):
		if str((voice as Dictionary)["verb"]) == "SCAR":
			scar_id = str((voice as Dictionary)["id"])
	assert_ne(scar_id, "", "la carta offre una Cicatrice")
	assert_true(
		(session.confluence.price_menu()["cost"] as Array).has(scar_id),
		"e il fronte avverso puo' sceglierla come prezzo"
	)
	# Un avversario spende il suo gettone e sceglie la Cicatrice (D-387).
	session.confluence.set_benefits(_benefits().slice(0, 1))
	var others: Array = _others(str(context["proponent"]))
	session.confluence.declare_stance(str(others[0]), "OPPOSE")
	_give_tokens(str(others[0]), 1)
	assert_true(
		session.confluence.place_cost(str(others[0]), scar_id),
		"la Cicatrice si posa come qualunque altro costo"
	)
	assert_true(
		(session.confluence.priced_costs() as Array).has(scar_id),
		"e allora la Cicatrice scatta"
	)


## **La pedina del prezzo la posa chi la paga** (D-387, ISSUES 122). Non e'
## piu' un diritto del primo OPPOSE: e' una spesa, e la fa chiunque non
## proponga, **una pedina a testa**, finche' sulla carta c'e' posto.
func test_the_price_pedina_is_placed_by_whoever_pays_for_it() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var others: Array = _others(proponent)
	session.confluence.set_benefits(_benefits().slice(0, 1))

	assert_false(
		session.confluence.place_cost(str(others[0]), _a_cost()),
		"senza gettone non si posa niente"
	)
	assert_false(
		session.confluence.place_cost(proponent, _a_cost()),
		"e il proponente non si fa pagare da se'"
	)
	_give_tokens(str(others[0]), 2)
	_give_tokens(str(others[1]), 1)
	_give_tokens(str(others[2]), 1)
	assert_false(
		session.confluence.place_cost(str(others[0]), "C_INVENTATO"),
		"una voce fuori dalla carta si rifiuta"
	)
	assert_true(
		session.confluence.place_cost(str(others[0]), _a_cost()),
		"chi spende il gettone posa la pedina"
	)
	assert_eq(session.confluence.claim_tokens(str(others[0])), 1, "e il gettone se ne va")
	assert_false(
		session.confluence.place_cost(str(others[0]), _third_cost()),
		"una pedina a testa, anche a chi ne ha due"
	)
	assert_false(
		session.confluence.place_cost(str(others[1]), _a_cost()),
		"e una pedina per voce"
	)
	assert_true(
		session.confluence.place_cost(str(others[1]), _third_cost()),
		"un secondo avversario ne posa un'altra"
	)
	assert_false(
		session.confluence.place_cost(str(others[2]), _first_cost()),
		"e sulla carta ci stanno due pedine di costo, non tre"
	)
	assert_eq(
		session.confluence.claim_tokens(str(others[2])), 1,
		"a chi non l'ha posata il gettone resta"
	)


## **Se la proposta cade, scattano gli effetti stampati.** Non li sceglie
## nessuno: la carta dice che il mondo non sopporta l'indecisione, e quello
## succede. Fronte avverso carico e proponente a mani vuote: il fallimento e'
## certo.
func test_on_failure_the_printed_effects_fire() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var opposer: String = str(_others(proponent)[0])
	session.confluence.declare_stance(opposer, "OPPOSE")
	# La mano vera, non carte inventate: lo smaltimento di I. scarta quello che
	# e' stato impegnato, e una carta che il seggio non ha farebbe strillare
	# l'applier senza provare niente.
	var hand: Array = session.service.hand(opposer)
	assert_true(hand.size() > 0, "l'oppositore ha una mano da impegnare")
	session.confluence.current["commits"][opposer] = hand
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "la proposta cade")
	for voice in (data().tensions[TENSION]["physical"]["failure"] as Array):
		assert_true(
			_log_says(str((voice as Dictionary)["text"])),
			"il verbale legge l'effetto stampato: «%s»"
				% str((voice as Dictionary)["text"]).substr(0, 30)
		)


## **Se passa, si applicano i benefici comprati e i costi scelti** — insieme,
## come dice la carta. Margine forzato a zero: la proposta passa.
func test_on_success_benefits_and_costs_are_applied() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var opposer: String = str(_others(proponent)[0])
	_give_tokens(proponent, 1)
	session.confluence.set_benefits(_benefits().slice(0, 2))
	session.confluence.declare_stance(opposer, "OPPOSE")
	_give_tokens(opposer, 1)
	assert_true(
		session.confluence.place_cost(opposer, _third_cost()),
		"un avversario spende il gettone e sceglie la moneta"
	)
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_true(
		ConfluenceResolution.is_success(str(result["outcome"])),
		"margine zero: la proposta passa"
	)
	for voice_id in _benefits().slice(0, 2):
		assert_true(
			_log_says(_text_of("benefits", str(voice_id))),
			"il beneficio comprato si applica: «%s»" % _text_of("benefits", str(voice_id)).substr(0, 24)
		)
	assert_true(
		_log_says(_text_of("costs", _third_cost())),
		"e il costo scelto dagli avversari si paga"
	)


## **Senza gettoni non si paga niente** (D-387, ISSUES 122). E' il rovescio
## esatto della regola di prima, ed e' la ragione della decisione: fino a D-386
## il prezzo era **dovuto** — tanti costi quanti benefici oltre il primo — e se
## il fronte avverso taceva lo prendeva il mondo dall'alto della lista. Adesso
## il prezzo lo **compra** chi lo vuole, e una proposta che nessuno vuole far
## pagare passa gratis.
func test_without_a_token_nothing_is_paid() -> void:
	var context: Dictionary = _open_with_proposition()
	_give_tokens(str(context["proponent"]), 1)
	session.confluence.set_benefits(_benefits().slice(0, 2))
	assert_eq(
		session.confluence.priced_costs(), [],
		"nessuno ha speso un gettone: la proposta passa gratis"
	)


## I gettoni in mano a una casa, senza passare dal turno: qui si prova il
## Consiglio, non da dove arriva la moneta — quella la prova
## `test_a_claim_card_pays_the_council`.
func _give_tokens(entity_id: String, quanti: int) -> void:
	var effect: GDScript = load("res://scripts/core/effect.gd")
	for i in range(quanti):
		session.applier.apply(effect.make(
			"GRANT_CLAIM_TOKEN", "entity", entity_id, {},
			effect.source("system", "TEST", "", 1, 1, 0)
		))


## Il testo stampato di una voce, per leggerlo nel verbale.
func _text_of(list_name: String, voice_id: String) -> String:
	for voice in (data().tensions[TENSION]["physical"][list_name] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			return str((voice as Dictionary)["text"])
	return ""


## **Il silenzio avvantaggia il proponente**, della misura scritta nei dati -
## e solo un proponente che ci ha messo del proprio: il bonus entra nel fronte,
## e un fronte a zero carte resta zero come ogni altro peso del Consiglio.
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


## **Basta una voce a rompere il silenzio.** Un solo OPPOSE dichiarato, anche a
## mani vuote, e il bonus non esiste.
func test_one_declared_stance_breaks_the_silence() -> void:
	var chronicle: Dictionary = data().chronicles["CHR_TEST"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = 3
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var others: Array = _others(proponent)
	session.confluence.declare_stance(str(others[0]), "OPPOSE")
	for i in range(1, others.size()):
		session.confluence.declare_stance(str(others[i]), "ABSTAIN")
	var hand: Array = session.service.hand(proponent)
	assert_true(hand.size() > 0, "il proponente ha una carta da mettere sul tavolo")
	session.confluence.current["commits"][proponent] = [hand[0]]
	_rig(_factor_cancelling_bite(proponent))
	session.confluence.resolve()
	assert_false(
		_log_says("Il tavolo tace"),
		"una posizione dichiarata rompe il silenzio, anche senza carte"
	)


## Un Consiglio dove tutti si astengono, col bonus del silenzio a `bonus`:
## torna margine e voce a verbale. Sessione nuova ogni volta, cosi' i due giri
## si confrontano alla pari - e il log si legge **prima** che la sessione dopo
## lo butti via, che e' l'errore da cui questa funzione e' nata.
func _silent_council(bonus: int) -> Dictionary:
	new_session()
	var chronicle: Dictionary = data().chronicles["CHR_TEST"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = bonus
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	for entity_id in _others(proponent):
		session.confluence.declare_stance(str(entity_id), "ABSTAIN")
	var hand: Array = session.service.hand(proponent)
	assert_true(hand.size() > 0, "il proponente ha una carta da mettere sul tavolo")
	session.confluence.current["commits"][proponent] = [hand[0]]
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	return {
		"margin": int(result["margin"]),
		"spoke": _log_says("Il tavolo tace: il silenzio avvantaggia il proponente"),
	}


func _log_says(needle: String) -> bool:
	for line in session.log.lines:
		if str(line).contains(needle):
			return true
	return false


## **E la carta dice cosa ha lasciato sul mondo** (D-292).
##
## La Conseguenza d'autore narrava ogni suo Effetto — «Su Valle Verde resta un
## segno: razionata» — e la voce della carta no: il verbale diceva «Beneficio:
## costruisci un Granaio» e poi taceva. Meta' del Consiglio scriveva in
## silenzio, e una sonda che contava quello che il tavolo legge dava **zero**
## alla carta e 443 alla frase d'autore: un numero falso, prodotto da un difetto
## vero.
func test_the_card_says_what_it_left_behind() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var opposer: String = str(_others(proponent)[0])
	# La Pietra: e' il beneficio che lascia il segno piu' facile da riconoscere
	# nel verbale, e sta sulla carta, non scritto qui.
	var stone: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary).get("verb", "")) == "BUILD_STONE":
			stone = str((voice as Dictionary)["id"])
	assert_ne(stone, "", "la carta offre di costruire una Pietra")
	_hush_the_authored_voice()
	session.confluence.set_benefits([stone])
	session.confluence.declare_stance(opposer, "OPPOSE")
	_rig(_factor_cancelling_bite(proponent))
	var before: int = session.log.lines.size()
	var result: Dictionary = session.confluence.resolve()
	assert_true(ConfluenceResolution.is_success(str(result["outcome"])), "la proposta passa")

	# La riga della voce c'e' — quella c'era gia'. Quello che si pretende qui e'
	# **la riga subito sotto**: cosa quella voce ha scritto sul mondo. Il
	# registro incolonna «- H. Beneficio: ...» e sotto «-   il mondo ricorda…»,
	# quindi una riga narrata e' una riga che **non** comincia con la lettera
	# di un passo.
	var said: int = -1
	for i in range(before, session.log.lines.size()):
		if str(session.log.lines[i]).contains("H. Beneficio: %s" % _text_of("benefits", stone)):
			said = i
	assert_true(said >= 0, "il verbale legge il beneficio comprato")
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
