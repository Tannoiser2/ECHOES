extends "res://tests/test_case.gd"
## La controproposta del RIVENDICARE (PZ-5 Fase B, D-268).
##
## Parola del committente (D-261): il RIVENDICARE *«puo' servire in primis per
## fare una controproposta sulla Tensione che si va dibattendo - mettere una
## pedina su un beneficio o su un costo - oppure per dibattere una seconda
## tensione»*. Qui il primo uso: chi ha pagato l'azione puo' prendersi la
## pedina del prezzo scavalcando l'ordine delle dichiarazioni, o rivendicare
## una voce del beneficio - che a proposta passata **parla di lui**.
##
## La voce rivendicata si fabbrica (regola di casa): una Conseguenza sintetica
## che scrive un segno sul $proponent - cosi' la prova vede con i suoi occhi
## su chi atterra, senza dipendere dal contenuto spedito.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

const TENSION: String = "TEN_FAMINE"
const PRIZE: String = "CNS_PROVA_RIVENDICATA"
const PRIZE_TAG: String = "prova:rivendicata"

var _saved_success: Array = []
var _touched_proposition: String = ""


class RiggedDie extends RefCounted:
	var value: int = 3

	func roll_d6() -> int:
		return value


const DIE_FOR_FACTOR: Dictionary = {-2: 1, -1: 2, 0: 3, 1: 5, 2: 6}


func before_each() -> void:
	new_session()
	data().consequences[PRIZE] = {
		"id": PRIZE,
		"title": "Il Premio della Prova",
		"category": "INFLUENCE",
		"description": "Una voce fabbricata per vedere su chi atterra.",
		"effects": [
			{
				"type": "SET_ENTITY_TAG",
				"target": {"kind": "entity", "id": "$proponent"},
				"payload": {"tag": PRIZE_TAG},
			}
		],
	}


func after_each() -> void:
	# Il DataSet e' condiviso fra le prove: la Conseguenza fabbricata esce, e
	# la proposta toccata riavra' le sue voci vere.
	data().consequences.erase(PRIZE)
	if _touched_proposition != "":
		var template: Dictionary = data().confluence_templates["CNF_FAMINE_01"]
		for proposition in template["propositions"]:
			if str(proposition["id"]) == _touched_proposition:
				proposition["success_consequences"] = _saved_success
		_touched_proposition = ""


func _rig(factor: int) -> void:
	var die: RiggedDie = RiggedDie.new()
	die.value = int(DIE_FOR_FACTOR[factor])
	session.confluence.rng = die


func _factor_cancelling_bite(proponent: String) -> int:
	var bite: Dictionary = TagRules.council_world_factor(
		data(), session.world, TENSION, proponent
	)
	return clampi(-int(bite["delta"]), -2, 2)


## Apre il Consiglio e mette il Premio fra le voci del beneficio della
## proposta scelta, ricordandosi cosa c'era prima.
func _open_with_prize() -> Dictionary:
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence su %s si apre" % TENSION)
	var options: Array = session.confluence.available_propositions()
	assert_true(options.size() > 0, "almeno una proposta disponibile")
	var chosen: Dictionary = options[0] as Dictionary
	_touched_proposition = str(chosen["id"])
	_saved_success = (chosen["success_consequences"] as Array).duplicate()
	chosen["success_consequences"] = [PRIZE]
	session.confluence.set_proposition(str(chosen["id"]))
	return context


func _others(proponent: String) -> Array:
	var out: Array = []
	for entity_id in session.confluence.stance_order():
		if str(entity_id) != proponent:
			out.append(str(entity_id))
	return out


## **La voce rivendicata parla del rivendicante.** A proposta passata il segno
## atterra su chi ha fatto la controproposta, non sul proponente.
func test_a_claimed_benefit_lands_on_the_claimant() -> void:
	var context: Dictionary = _open_with_prize()
	var proponent: String = str(context["proponent"])
	var claimant: String = str(_others(proponent)[0])
	assert_true(
		session.confluence.place_counterclaim(claimant, "benefit", PRIZE),
		"la controproposta rivendica la voce del beneficio"
	)
	var hand: Array = session.service.hand(proponent)
	assert_true(hand.size() > 0, "il proponente ha carte da impegnare")
	session.confluence.current["commits"][proponent] = hand
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_true(
		ConfluenceResolution.is_success(str(result["outcome"])),
		"la proposta passa (esito: %s)" % str(result["outcome"])
	)
	assert_eq(str(result["counterclaim"]), "benefit", "il diritto risulta speso")
	assert_true(
		(session.world["entities"][claimant]["tags"] as Array).has(PRIZE_TAG),
		"il segno della voce rivendicata sta sul rivendicante"
	)
	assert_false(
		(session.world["entities"][proponent]["tags"] as Array).has(PRIZE_TAG),
		"e non sul proponente: la voce ha cambiato bocca"
	)


## **La pedina presa per controproposta scavalca il primo OPPOSE.** Il diritto
## pagato con l'azione batte l'ordine delle dichiarazioni.
func test_a_counterclaimed_price_overrides_the_first_opposer() -> void:
	var context: Dictionary = _open_with_prize()
	var proponent: String = str(context["proponent"])
	var others: Array = _others(proponent)
	var first_opposer: String = str(others[0])
	var claimant: String = str(others[1])
	session.confluence.declare_stance(first_opposer, "OPPOSE")
	assert_true(
		session.confluence.place_counterclaim(claimant, "price", "", "CNS_OATH_BROKEN"),
		"il rivendicante prende la pedina senza essere il primo OPPOSE"
	)
	var hand: Array = session.service.hand(first_opposer)
	assert_true(hand.size() > 0, "l'oppositore ha una mano da impegnare")
	session.confluence.current["commits"][first_opposer] = hand
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["outcome"]), ConfluenceResolution.FAILURE, "la proposta cade")
	assert_eq(str(result["counterclaim"]), "price", "il diritto risulta speso")
	assert_true(
		(result["consequence_ids"] as Array).has("CNS_OATH_BROKEN"),
		"lo sfogo e' quello della controproposta"
	)
	assert_false(
		(result["consequence_ids"] as Array).has("CNS_FAILURE_SPIRAL"),
		"non la prima voce del pool"
	)


## **Il diritto ha le sue regole.** Il proponente non controproppone a se
## stesso; una voce fuori dal beneficio si rifiuta; senza controproposta il
## risultato non dichiara niente di speso.
func test_the_counterclaim_has_rules() -> void:
	var context: Dictionary = _open_with_prize()
	var proponent: String = str(context["proponent"])
	var claimant: String = str(_others(proponent)[0])
	assert_false(
		session.confluence.place_counterclaim(proponent, "benefit", PRIZE),
		"il proponente non controproppone a se stesso"
	)
	assert_false(
		session.confluence.place_counterclaim(claimant, "benefit", "CNS_ROYAL_GRANARY"),
		"una voce che non e' nel beneficio della proposta si rifiuta"
	)
	assert_false(
		session.confluence.place_counterclaim(claimant, "sconosciuta", PRIZE),
		"un modo sconosciuto si rifiuta"
	)
	var hand: Array = session.service.hand(proponent)
	session.confluence.current["commits"][proponent] = hand
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_eq(str(result["counterclaim"]), "", "senza controproposta niente risulta speso")
