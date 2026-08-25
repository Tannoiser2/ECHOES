extends "res://tests/test_case.gd"
## L'economia del Consiglio, e la regola del silenzio (D-280, D-267).
##
## Parola del committente, sulla sua carta d'esempio: **il proponente compra i
## benefici, gli avversari scelgono in che moneta paga** — un costo per ogni
## beneficio oltre il primo, e una Cicatrice ne compra uno oltre il limite. Se
## la proposta passa si applicano benefici **e** costi; se cade, scattano gli
## effetti stampati, che non sceglie nessuno. E la regola anti-passivita' della
## roadmap (PZ-5): se tutti si astengono, il silenzio avvantaggia il
## proponente - un numero nei dati, reversibile.
##
## Gli esiti si forzano col dado truccato e col morso del mondo annullato: una
## prova che dipendesse dal caso o dai segni di partenza smetterebbe di provare
## senza dirlo.

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


func before_each() -> void:
	new_session()


func after_each() -> void:
	# La regola del silenzio e' dato spedito (1): le prove che la spengono o la
	# gonfiano devono rimetterla, o il prossimo test la troverebbe storta.
	var chronicle: Dictionary = data().chronicles["CHR_01"]
	(chronicle["confluence_rules"] as Dictionary)["silence_support_bonus"] = 1


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
	return context


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


## **L'economia: uno e' gratis, ogni altro si paga.** E' la riga in mezzo alla
## carta, ed e' quella che rende il Consiglio una decisione invece di un menu.
func test_one_benefit_is_free_and_every_other_costs_one() -> void:
	_open_with_proposition()
	var benefits: Array = _benefits()
	assert_true(session.confluence.set_benefits([]), "si puo' anche non comprare niente")
	assert_eq(session.confluence.costs_due(), 0, "e allora non si paga")
	assert_true(session.confluence.set_benefits([str(benefits[0])]), "un beneficio si compra")
	assert_eq(session.confluence.costs_due(), 0, "il primo e' gratis")
	assert_true(session.confluence.set_benefits(benefits.slice(0, 2)), "due benefici")
	assert_eq(session.confluence.costs_due(), 1, "il secondo costa un costo")
	assert_true(session.confluence.set_benefits(benefits.slice(0, 3)), "tre benefici")
	assert_eq(session.confluence.costs_due(), 2, "il terzo ne costa un altro")
	assert_true(
		session.confluence.set_benefits(benefits.slice(0, 4)),
		"il quarto si prende accettando la Cicatrice"
	)
	assert_eq(
		session.confluence.costs_due(), 3,
		"e allora il prezzo e' due costi piu' la Cicatrice"
	)
	assert_false(
		session.confluence.set_benefits(benefits.slice(0, 5)),
		"oltre la Cicatrice non ci stanno altre pedine"
	)
	assert_false(
		session.confluence.set_benefits([str(benefits[0]), str(benefits[0])]),
		"una pedina per voce"
	)
	assert_false(
		session.confluence.set_benefits(["B_INVENTATO"]),
		"e solo sui benefici che la carta stampa"
	)


## **Con la Cicatrice accettata, la Cicatrice si paga davvero.** Il quarto
## beneficio non e' gratis: fra i costi che scattano c'e' la voce CICATRICE,
## anche se il fronte avverso ne aveva scelte altre.
func test_the_fourth_benefit_brings_the_scar() -> void:
	_open_with_proposition()
	session.confluence.set_benefits(_benefits().slice(0, 4))
	var scar_id: String = ""
	for voice in (data().tensions[TENSION]["physical"]["costs"] as Array):
		if str((voice as Dictionary)["verb"]) == "SCAR":
			scar_id = str((voice as Dictionary)["id"])
	assert_ne(scar_id, "", "la carta offre una Cicatrice")
	assert_true(
		(session.confluence.priced_costs() as Array).has(scar_id),
		"e chi ha comprato il quarto beneficio se la prende"
	)


## **La pedina spetta al primo OPPOSE nell'ordine delle dichiarazioni**, ed e'
## un diritto che non si usurpa: non chi sostiene, non il secondo oppositore.
func test_the_pedina_belongs_to_the_first_opposer() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var others: Array = _others(proponent)
	assert_eq(session.confluence.first_opposer(), "", "senza OPPOSE dichiarati non c'e' fronte avverso")

	session.confluence.declare_stance(str(others[0]), "SUPPORT")
	session.confluence.declare_stance(str(others[1]), "OPPOSE")
	session.confluence.declare_stance(str(others[2]), "OPPOSE")
	assert_eq(
		session.confluence.first_opposer(), str(others[1]),
		"il primo OPPOSE nell'ordine delle dichiarazioni parla per il fronte"
	)
	# Il proponente ha comprato tre benefici: due costi da pagare.
	session.confluence.set_benefits(_benefits().slice(0, 3))
	assert_eq(session.confluence.costs_due(), 2, "tre benefici costano due costi")
	assert_false(
		session.confluence.place_costs(str(others[0]), [_a_cost()]),
		"chi sostiene non sceglie il prezzo"
	)
	assert_false(
		session.confluence.place_costs(str(others[2]), [_a_cost()]),
		"il secondo oppositore non sceglie il prezzo"
	)
	assert_false(
		session.confluence.place_costs(str(others[1]), ["C_INVENTATO"]),
		"una voce fuori dalla carta si rifiuta"
	)
	assert_false(
		session.confluence.place_costs(str(others[1]), _voices("costs").slice(0, 3)),
		"e non si posano piu' pedine di quante la proposta ne costa"
	)
	assert_true(
		session.confluence.place_costs(str(others[1]), [_a_cost(), _third_cost()]),
		"il primo oppositore sceglie in che moneta si paga"
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
	session.confluence.set_benefits(_benefits().slice(0, 2))
	session.confluence.declare_stance(opposer, "OPPOSE")
	assert_eq(session.confluence.costs_due(), 1, "due benefici costano un costo")
	assert_true(
		session.confluence.place_costs(opposer, [_third_cost()]),
		"il fronte avverso sceglie la moneta"
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


## **Senza scelta decide il mondo**: il prezzo si prende dall'alto della lista,
## perche' una carta che resta muta non deve poter uscire senza pagare.
func test_without_a_choice_the_world_takes_from_the_top() -> void:
	_open_with_proposition()
	session.confluence.set_benefits(_benefits().slice(0, 2))
	assert_eq(session.confluence.costs_due(), 1, "un costo da pagare")
	assert_eq(
		session.confluence.priced_costs(), [_first_cost()],
		"e nessuno l'ha scelto: prende il mondo, dall'alto"
	)


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
	var chronicle: Dictionary = data().chronicles["CHR_01"]
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
	var chronicle: Dictionary = data().chronicles["CHR_01"]
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
