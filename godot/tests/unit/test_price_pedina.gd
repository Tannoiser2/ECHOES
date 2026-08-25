extends "res://tests/test_case.gd"
## La pedina del prezzo, e la regola del silenzio (PZ-5 Fase A, D-267).
##
## Parola del committente (D-266): al Consiglio il proponente sceglie le
## opportunita' e i bonus, **gli avversari scelgono i malus**. Qui la meta'
## degli avversari: il primo seggio del fronte avverso posa la pedina sul menu
## del prezzo - il costo se la proposta passa pagando, lo sfogo se cade - e la
## risoluzione fa scattare **quella** voce, non il pool intero. E la regola
## anti-passivita' della roadmap (PZ-5): se tutti si astengono, il silenzio
## avvantaggia il proponente - un numero nei dati, reversibile.
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
		out.append(str((voice as Dictionary)["takes"]))
	return out


func _first_cost() -> String:
	return str(_voices("costs")[0])


func _other_cost() -> String:
	return str(_voices("costs")[1])


func _a_cost() -> String:
	return _other_cost()


func _first_vent() -> String:
	return str(_voices("failures")[0])


func _other_vent() -> String:
	return str(_voices("failures")[1])


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
func test_the_menu_is_the_card_face() -> void:
	_open_with_proposition()
	var face: Dictionary = data().tensions[TENSION]["physical"]
	var menu: Dictionary = session.confluence.price_menu()
	var written_costs: Array = []
	for voice in (face["costs"] as Array):
		written_costs.append(str((voice as Dictionary)["takes"]))
	var written_vents: Array = []
	for voice in (face["failures"] as Array):
		written_vents.append(str((voice as Dictionary)["takes"]))
	assert_eq(menu["cost"], written_costs, "il menu del costo e' quello scritto sulla carta")
	assert_eq(menu["failure"], written_vents, "il menu dello sfogo e' quello scritto sulla carta")
	assert_true(written_costs.size() >= 2, "sulla carta ci sono almeno due costi: uno solo non e' una scelta")
	assert_true(written_vents.size() >= 2, "sulla carta ci sono almeno due sfoghi")

	# E la voce si legge **con le parole della carta**, non col titolo della
	# Conseguenza: e' quello che al tavolo si sceglie.
	assert_eq(
		session.confluence.price_voice_text("costs", str(written_costs[0])),
		str((face["costs"] as Array)[0]["text"]),
		"la voce del costo si legge com'e' scritta sulla carta"
	)

	var vents: Array = menu["failure"] as Array
	assert_eq(
		session.confluence._priced(vents, ""), str(vents[0]),
		"senza pedina decide il mondo: la prima voce"
	)
	assert_eq(
		session.confluence._priced(vents, str(vents[1])), str(vents[1]),
		"con la pedina decide il fronte avverso"
	)
	assert_eq(
		session.confluence._priced(vents, "CNS_NON_ESISTE"), str(vents[0]),
		"una pedina fuori menu non decide niente"
	)


## **Una questione senza faccia usa ancora il pool del template** (D-278): la
## carta comanda dove c'e', e dove non c'e' il gioco non si ferma. Si toglie la
## faccia a mano dal `DataSet` della prova, che e' l'unico modo di provare il
## ripiego adesso che tutte e sessanta le carte ce l'hanno.
func test_without_a_face_the_template_pool_still_serves() -> void:
	var face: Dictionary = (data().tensions[TENSION] as Dictionary)["physical"]
	(data().tensions[TENSION] as Dictionary).erase("physical")
	_open_with_proposition()
	var pools: Dictionary = data().confluence_templates[
		str(session.confluence.current["template_id"])
	]["consequence_pools"]
	var menu: Dictionary = session.confluence.price_menu()
	assert_eq(menu["cost"], pools["cost"], "senza faccia, il costo torna al pool del template")
	assert_eq(menu["failure"], pools["failure"], "senza faccia, lo sfogo torna al pool del template")
	assert_eq(
		session.confluence.price_voice_text("costs", str((pools["cost"] as Array)[0])), "",
		"e senza faccia non c'e' una parola della carta da leggere"
	)
	(data().tensions[TENSION] as Dictionary)["physical"] = face


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
	assert_false(
		session.confluence.place_price(str(others[0]), _a_cost(), ""),
		"chi sostiene non posa la pedina del prezzo"
	)
	assert_false(
		session.confluence.place_price(str(others[2]), _a_cost(), ""),
		"il secondo oppositore non posa la pedina del prezzo"
	)
	assert_false(
		session.confluence.place_price(str(others[1]), "CNS_ROYAL_GRANARY", ""),
		"una voce fuori dal menu del costo si rifiuta"
	)
	assert_true(
		session.confluence.place_price(str(others[1]), _a_cost(), _other_vent()),
		"il primo oppositore posa la pedina su voci del menu"
	)


## **Se la proposta cade, lo sfogo e' quello della pedina.** Fronte avverso
## carico e proponente a mani vuote: il fallimento e' certo, e la Conseguenza
## che scatta e' quella scelta, non la prima del pool.
func test_on_failure_the_chosen_vent_fires() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var opposer: String = str(_others(proponent)[0])
	session.confluence.declare_stance(opposer, "OPPOSE")
	assert_true(
		session.confluence.place_price(opposer, "", _other_vent()),
		"la pedina si posa sul solo sfogo"
	)
	# La mano vera, non carte inventate: lo smaltimento di I. scarta quello che
	# e' stato impegnato, e una carta che il seggio non ha farebbe strillare
	# l'applier senza provare niente.
	var hand: Array = session.service.hand(opposer)
	assert_true(hand.size() > 0, "l'oppositore ha una mano da impegnare")
	session.confluence.current["commits"][opposer] = hand
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "la proposta cade")
	assert_true(
		(result["consequence_ids"] as Array).has(_other_vent()),
		"lo sfogo scattato e' quello della pedina"
	)
	assert_false(
		(result["consequence_ids"] as Array).has(_first_vent()),
		"la prima voce del pool non scatta: dal pool esce una voce sola"
	)


## **Se passa con un costo, il costo e' quello della pedina.** Margine forzato
## a zero (nessuna carta, morso annullato dal dado): Success with Cost.
func test_on_success_with_cost_the_chosen_price_fires() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var opposer: String = str(_others(proponent)[0])
	session.confluence.declare_stance(opposer, "OPPOSE")
	assert_true(
		session.confluence.place_price(opposer, _other_cost(), ""),
		"la pedina si posa sul solo costo"
	)
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_eq(
		str(result["outcome"]), ConfluenceResolution.SUCCESS_WITH_COST,
		"margine zero: passa pagando"
	)
	assert_true(
		(result["consequence_ids"] as Array).has(_other_cost()),
		"il costo scattato e' quello della pedina"
	)
	assert_false(
		(result["consequence_ids"] as Array).has(_first_cost()),
		"la prima voce del pool non scatta: dal pool esce una voce sola"
	)


## **Senza pedina decide il mondo**: la prima voce del pool, com'e' sempre
## stato quando il pool aveva una voce sola.
func test_without_a_pedina_the_world_picks_the_first_voice() -> void:
	var context: Dictionary = _open_with_proposition()
	var proponent: String = str(context["proponent"])
	var opposer: String = str(_others(proponent)[0])
	session.confluence.declare_stance(opposer, "OPPOSE")
	var hand: Array = session.service.hand(opposer)
	assert_true(hand.size() > 0, "l'oppositore ha una mano da impegnare")
	session.confluence.current["commits"][opposer] = hand
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "la proposta cade")
	assert_true(
		(result["consequence_ids"] as Array).has(_first_vent()),
		"senza pedina scatta la prima voce del pool"
	)
	assert_false(
		(result["consequence_ids"] as Array).has(_other_vent()),
		"e soltanto quella"
	)


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
