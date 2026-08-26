extends "res://tests/test_case.gd"
## La controproposta del RIVENDICARE (PZ-5 Fase B, D-268; riscritta da D-304).
##
## Parola del committente (D-261): il RIVENDICARE *«puo' servire in primis per
## fare una controproposta sulla Tensione che si va dibattendo - mettere una
## pedina su un beneficio o su un costo - oppure per dibattere una seconda
## tensione»*. Qui il primo uso: chi ha pagato l'azione puo' prendersi la
## pedina del prezzo scavalcando l'ordine delle dichiarazioni, o rivendicare
## **una casella che il proponente ha appena comprato sulla carta** - che a
## proposta passata parla di lui.
##
## D-304 ha rimesso in fila le due meta': prima si rivendicava fra le
## Conseguenze del *template*, mentre il proponente comprava dalla faccia
## della carta. Due elenchi diversi per la stessa pedina. Adesso e' una pedina
## su una pedina.
##
## La voce rivendicata si fabbrica (regola di casa): un beneficio sintetico
## che **costruisce una Pietra**, cosi' la prova vede con i suoi occhi di chi
## e' quello che resta, senza dipendere da cosa e' stampato sulle carte
## spedite. Si guarda la Pietra e non il controllo perche' le Conseguenze
## d'autore si applicano **dopo** la carta e possono riassegnare il controllo
## del luogo (ISSUES 86): la Pietra costruita, invece, resta di chi l'ha
## alzata.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

const TENSION: String = "TEN_FAMINE"
const PRIZE: String = "B_PROVA_RIVENDICATA"
const STONE: String = "STR_GRANARY"

var _saved_benefits: Array = []


class RiggedDie extends RefCounted:
	var value: int = 3

	func roll_d6() -> int:
		return value


const DIE_FOR_FACTOR: Dictionary = {-2: 1, -1: 2, 0: 3, 1: 5, 2: 6}


func before_each() -> void:
	new_session()
	# La casella fabbricata, in testa alla lista: alza una Pietra intestata a
	# **chi la posa**, che e' proprio quello che la controproposta cambia.
	var face: Dictionary = data().tensions[TENSION]["physical"] as Dictionary
	_saved_benefits = (face["benefits"] as Array).duplicate()
	var fabricated: Array = [
		{
			"id": PRIZE,
			"verb": "BUILD_STONE",
			"text": "Prova: alza una Pietra per chi ha posato questa pedina.",
			"structure": STONE,
		}
	]
	fabricated.append_array(_saved_benefits)
	face["benefits"] = fabricated


func after_each() -> void:
	# Il DataSet e' condiviso fra le prove: la casella fabbricata esce.
	if not _saved_benefits.is_empty():
		(data().tensions[TENSION]["physical"] as Dictionary)["benefits"] = _saved_benefits
		_saved_benefits = []


func _rig(factor: int) -> void:
	var die: RiggedDie = RiggedDie.new()
	die.value = int(DIE_FOR_FACTOR[factor])
	session.confluence.rng = die


func _factor_cancelling_bite(proponent: String) -> int:
	var bite: Dictionary = TagRules.council_world_factor(
		data(), session.world, TENSION, proponent
	)
	return clampi(-int(bite["delta"]), -2, 2)


## Le voci dello sfogo scritte sulla carta in dibattito (D-278): il menu del
## prezzo viene da li', quindi le prove lo leggono invece di scriverlo a mano.
func _costs() -> Array:
	var out: Array = []
	for voice in ((data().tensions[TENSION]["physical"] as Dictionary)["costs"] as Array):
		out.append(str((voice as Dictionary)["id"]))
	return out


func _first_vent() -> String:
	return str(_costs()[0])


func _other_vent() -> String:
	return str(_costs()[2])


## Il testo stampato di un costo: e' quello che il verbale legge (D-280).
func _cost_text(voice_id: String) -> String:
	for voice in (data().tensions[TENSION]["physical"]["costs"] as Array):
		if str((voice as Dictionary)["id"]) == voice_id:
			return str((voice as Dictionary)["text"])
	return ""


## Apre il Consiglio, sceglie una proposta e **compra la casella fabbricata**:
## solo quello che il proponente ha comprato si puo' rivendicare (D-304).
func _open_with_prize() -> Dictionary:
	var context: Dictionary = session.confluence.open(TENSION, {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "la Confluence su %s si apre" % TENSION)
	var options: Array = session.confluence.available_propositions()
	assert_true(options.size() > 0, "almeno una proposta disponibile")
	session.confluence.set_proposition(str((options[0] as Dictionary)["id"]))
	assert_true(session.confluence.set_benefits([PRIZE]), "il proponente compra la casella")
	return context


func _others(proponent: String) -> Array:
	var out: Array = []
	for entity_id in session.confluence.stance_order():
		if str(entity_id) != proponent:
			out.append(str(entity_id))
	return out


## **La casella rivendicata parla del rivendicante.** A proposta passata il
## controllo del luogo va a chi ha fatto la controproposta, non al proponente.
func test_a_claimed_benefit_lands_on_the_claimant() -> void:
	var context: Dictionary = _open_with_prize()
	var proponent: String = str(context["proponent"])
	var region: String = str(session.confluence.effect_context()["region_focus"])
	assert_ne(region, "", "il Consiglio discute di un luogo")
	var claimant: String = str(_others(proponent)[0])
	assert_eq(_stone_owner(region), "", "nel luogo non c'e' ancora quella Pietra: la prova puo' vederla nascere")
	assert_true(
		session.confluence.place_counterclaim(claimant, "benefit", PRIZE),
		"la controproposta rivendica la casella comprata"
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
	assert_eq(_stone_owner(region), claimant, "la Pietra della casella rivendicata e' sua")
	assert_ne(_stone_owner(region), proponent, "e non del proponente: la voce ha cambiato bocca")
	assert_true(
		_log_says("La voce rivendicata parla di"),
		"e il verbale lo dice, invece di farlo in silenzio"
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
	var benefits: Array = []
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		benefits.append(str((voice as Dictionary)["id"]))
	session.confluence.set_benefits(benefits.slice(0, 2))
	assert_true(
		session.confluence.place_counterclaim(claimant, "price", _other_vent()),
		"il rivendicante prende la pedina senza essere il primo OPPOSE"
	)
	# Il proponente ha comprato due benefici: un costo da pagare, e a sceglierlo
	# e' il rivendicante invece del primo OPPOSE.
	_rig(_factor_cancelling_bite(proponent))
	var result: Dictionary = session.confluence.resolve()
	assert_true(
		ConfluenceResolution.is_success(str(result["outcome"])),
		"la proposta passa (esito: %s)" % str(result["outcome"])
	)
	assert_eq(str(result["counterclaim"]), "price", "il diritto risulta speso")
	assert_true(
		_log_says(_cost_text(_other_vent())),
		"il prezzo pagato e' quello della controproposta"
	)
	assert_false(
		_log_says(_cost_text(_first_vent())),
		"non la prima voce del menu, che sarebbe stata quella del mondo"
	)


## Di chi e' la Pietra fabbricata in questo luogo, o "" se non c'e'.
func _stone_owner(region: String) -> String:
	for structure in ((session.world["regions"][region] as Dictionary)["structures"] as Array):
		if str((structure as Dictionary)["structure_type"]) == STONE:
			return str((structure as Dictionary).get("owner", ""))
	return ""


## Il verbale ha detto questa frase?
func _log_says(needle: String) -> bool:
	if needle == "":
		return false
	for line in session.log.lines:
		if str(line).contains(needle):
			return true
	return false


## **Il diritto ha le sue regole.** Il proponente non controproppone a se
## stesso; una casella che nessuno ha comprato si rifiuta - anche se sta
## stampata sulla carta (D-304); senza controproposta il risultato non
## dichiara niente di speso.
func test_the_counterclaim_has_rules() -> void:
	var context: Dictionary = _open_with_prize()
	var proponent: String = str(context["proponent"])
	var claimant: String = str(_others(proponent)[0])
	assert_false(
		session.confluence.place_counterclaim(proponent, "benefit", PRIZE),
		"il proponente non controproppone a se stesso"
	)
	var printed_but_unbought: String = ""
	for voice in (data().tensions[TENSION]["physical"]["benefits"] as Array):
		if str((voice as Dictionary)["id"]) != PRIZE:
			printed_but_unbought = str((voice as Dictionary)["id"])
			break
	assert_ne(printed_but_unbought, "", "la carta stampa altre caselle oltre a quella comprata")
	assert_false(
		session.confluence.place_counterclaim(claimant, "benefit", printed_but_unbought),
		"una casella stampata ma non comprata non si rivendica: la pedina va su una pedina"
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
