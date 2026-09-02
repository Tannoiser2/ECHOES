extends "res://tests/test_case.gd"
## **Il fallimento si compra** (ISSUES 119, D-419).
##
## Il numero che ha aperto la voce: in cento partite il segno di chi ha parlato
## e perso — `spoke_and_lost` — si posava **8 volte**, su otto case e trecento
## Consigli. Un Consiglio su undici cadeva, e cadeva quando **i numeri non
## tornavano**: nessuno lo faceva cadere. Una minaccia che si vede una volta
## ogni dodici partite non e' una minaccia, ed e' la ragione per cui il tavolo
## che tace veniva premiato.
##
## Adesso lo stesso gettone di [D-387] ha **due usi, e sono uno la rinuncia
## dell'altro**: posato su un costo dice *«passi, ma paghi»*, speso contro dice
## *«questa non deve passare»*. Una proposta cade perche' qualcuno l'ha voluta
## far cadere.
##
## **E la prima stesura non si poteva giocare.** Chiedeva di aver gia'
## dichiarato OPPOSE, e in dodici saghe la richiesta e' arrivata cinque volte e
## si e' vista rifiutare cinque volte: chi aveva il gettone quasi mai aveva
## anche impegnato carte contro. Il verbale lo diceva a voce alta — *«non ha
## dichiarato di opporsi»* — e per una volta lo zero non era la sonda cieca ma
## la regola stessa. Comprare opposizione **e'** opporsi, e questa prova tiene
## fermo il no che resta: chi ha detto di stare dalla parte della proposta non
## paga per farla cadere.

const TENSION: String = "TEN_FAMINE"


## Un dado fermo: l'esito diventa una scelta della prova, non un caso.
class RiggedDie extends RefCounted:
	var value: int = 3

	func roll_d6() -> int:
		return value


func before_each() -> void:
	new_session()
	# La regola e' un numero della Chronicle (D-419), e le prove unitarie
	# girano su CHR_TEST, che di suo non compra opposizione. Qui si accende a
	# mano: cosi' si misura **la regola**, non quale Chronicle e' accesa oggi.
	(
		(session.data.chronicles["CHR_TEST"] as Dictionary)["confluence_rules"] as Dictionary
	)["opposition_token_weight"] = 2


func after_each() -> void:
	# E si rispegne. Il `DataSet` di `test_case` e' **condiviso**: un numero
	# lasciato acceso qui se lo troverebbe addosso la suite dopo.
	if session != null:
		(
			(session.data.chronicles["CHR_TEST"] as Dictionary)["confluence_rules"] as Dictionary
		).erase("opposition_token_weight")
	super.after_each()


func _open() -> Dictionary:
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence su %s si apre" % TENSION)
	var options: Array = session.confluence.available_propositions()
	assert_true(options.size() > 0, "almeno una proposta disponibile")
	session.confluence.set_proposition(str(options[0]["id"]))
	var die: RiggedDie = RiggedDie.new()
	session.confluence.rng = die
	return context


func _others(proponent: String) -> Array:
	var out: Array = []
	for entity_id in session.confluence.stance_order():
		if str(entity_id) != proponent:
			out.append(str(entity_id))
	return out


func _give_tokens(entity_id: String, quanti: int) -> void:
	var effect: GDScript = load("res://scripts/core/effect.gd")
	for i in range(quanti):
		session.applier.apply(effect.make(
			"GRANT_CLAIM_TOKEN", "entity", entity_id, {},
			effect.source("system", "TEST", "", 1, 1, 0)
		))


## **Un gettone speso contro pesa nel margine, del numero scritto.**
func test_a_token_spent_against_weighs_in_the_margin() -> void:
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var avversario: String = str(_others(proponent)[0])
	_give_tokens(avversario, 1)

	assert_true(session.confluence.buy_opposition(avversario), "il gettone si spende contro")
	assert_eq(session.confluence.claim_tokens(avversario), 0, "e se ne va")
	assert_eq(session.confluence.opposition_placed(), 1, "la pedina e' sulla carta")

	var result: Dictionary = session.confluence.resolve()
	assert_eq(
		int(result["bought_opposition"]), 2,
		"e pesa il numero della Chronicle: %s" % str(result)
	)


## **E lo stesso Consiglio, senza quel gettone, ha un margine piu' alto di
## due.** E' la prova che vale le altre: senza il confronto, «pesa nel margine»
## e' una frase, e il numero potrebbe entrare due volte o non entrare affatto.
func test_the_same_council_costs_two_margin_points() -> void:
	var con_gettone: int = _margin_with_opposition(true)
	var senza: int = _margin_with_opposition(false)
	assert_eq(
		senza - con_gettone, 2,
		"il gettone contro vale esattamente il numero scritto (%d contro %d)" % [
			senza, con_gettone
		]
	)


func _margin_with_opposition(compra: bool) -> int:
	new_session()
	(
		(session.data.chronicles["CHR_TEST"] as Dictionary)["confluence_rules"] as Dictionary
	)["opposition_token_weight"] = 2
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var avversario: String = str(_others(proponent)[0])
	_give_tokens(avversario, 1)
	if compra:
		assert_true(session.confluence.buy_opposition(avversario), "il gettone si spende")
	return int(session.confluence.resolve()["margin"])


## **Comprare opposizione non chiede di aver gia' dichiarato OPPOSE.** E' la
## meta' della regola che la rende giocabile: al tavolo, pagare per far cadere
## una proposta *e'* la presa di posizione.
func test_an_abstaining_seat_can_still_pay_against() -> void:
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var avversario: String = str(_others(proponent)[0])
	session.confluence.declare_stance(avversario, "ABSTAIN")
	_give_tokens(avversario, 1)
	assert_true(
		session.confluence.buy_opposition(avversario),
		"chi si astiene puo' comunque pagare: %s" % session.confluence.last_error
	)


## **Ma chi sta dalla parte della proposta no.** Il no che resta, e l'unico che
## al tavolo si legge da solo: non si paga per far cadere una cosa che si e'
## appena detto di sostenere.
func test_the_supporting_side_cannot_pay_against() -> void:
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var altri: Array = _others(proponent)
	for side in ["SUPPORT", "CONDITION"]:
		var seggio: String = str(altri[0])
		session.confluence.declare_stance(seggio, str(side))
		_give_tokens(seggio, 1)
		assert_false(
			session.confluence.buy_opposition(seggio),
			"chi ha detto %s non paga contro" % str(side)
		)
		assert_eq(
			session.confluence.claim_tokens(seggio), 1,
			"e il gettone gli resta: un no non costa"
		)
		# Il gettone si rende, perche' la prova ne posa uno per giro.
		session.applier.apply(load("res://scripts/core/effect.gd").make(
			"SPEND_CLAIM_TOKEN", "entity", seggio, {},
			load("res://scripts/core/effect.gd").source("system", "TEST", "", 1, 1, 0)
		))
	assert_false(
		session.confluence.buy_opposition(proponent),
		"e il proponente non si oppone alla sua proposta"
	)


## **Una pedina a testa.** Chi ha due gettoni non compra due volte lo stesso
## fronte: al tavolo la pedina e' una, e la seconda non avrebbe dove stare.
func test_one_pedina_per_seat() -> void:
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var avversario: String = str(_others(proponent)[0])
	_give_tokens(avversario, 2)
	assert_true(session.confluence.buy_opposition(avversario), "la prima si posa")
	assert_false(session.confluence.buy_opposition(avversario), "la seconda no")
	assert_eq(session.confluence.claim_tokens(avversario), 1, "e il secondo gettone resta")


## **Spenta, il gettone compra solo costi.** La regola e' un numero della
## Chronicle, quindi e' reversibile: senza questa prova, spegnerla non
## risulterebbe da nessuna parte e il comportamento vecchio non avrebbe una
## guardia.
func test_with_the_rule_off_the_token_buys_no_opposition() -> void:
	(
		(session.data.chronicles["CHR_TEST"] as Dictionary)["confluence_rules"] as Dictionary
	)["opposition_token_weight"] = 0
	var context: Dictionary = _open()
	var proponent: String = str(context["proponent"])
	var avversario: String = str(_others(proponent)[0])
	_give_tokens(avversario, 1)
	assert_eq(session.confluence.opposition_weight(), 0, "questa Chronicle non la compra")
	assert_false(session.confluence.buy_opposition(avversario), "e il gettone non si spende cosi'")
	assert_eq(session.confluence.claim_tokens(avversario), 1, "resta in mano")
