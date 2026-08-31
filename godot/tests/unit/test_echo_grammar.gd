extends "res://tests/test_case.gd"
## The Propp layer (§15, D-030): dramatic families shape the Act, narrative
## functions order the story.

const Effect := preload("res://scripts/core/effect.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const SchemaDefs := preload("res://scripts/core/schema_defs.gd")


## Calare una carta lascia il segno di quello che e' successo, cosi' una carta
## dopo puo' chiederlo. Dalla 0.1.80 la carta la cala una mano, come azione.
##
## **Dove sta quel segno e' cambiato** (D-358). Prima era un `function:` scritto
## sul mondo, che `effect_text` nascondeva al giocatore: cambiava chi poteva
## uscire l'anno dopo, e al tavolo non si vedeva. Adesso e' la carta stessa, nella
## pila scoperta degli Echi calati — la grammatica di Propp resta identica, e si
## legge guardando il tavolo invece di fidarsi dell'app.
func test_playing_a_card_records_its_function() -> void:
	new_session()
	assert_true(
		(session.world["echo_played"] as Array).is_empty(),
		"all'inizio nessuna carta e' stata calata"
	)
	assert_false(
		str(session.world["global_tags"]).contains("function:"),
		"e il mondo non porta nessun segno nascosto"
	)
	# D-359: l'Eco non arriva da un mazzo, e' il terzo blocco di una carta Asset
	# in mano. Si mette in mano la carta che lo porta, e i segni che accende.
	var card_id: String = "ECH_LACK"
	var asset_id: String = "AST_FORCE_LEVY"
	assert_eq(
		str(data().assets[asset_id]["echo_id"]), card_id,
		"la prova punta alla carta che porta questo Eco"
	)
	var hand: Array = session.world["entities"]["ENT_ALDRIC"]["hand"] as Array
	hand.append(asset_id)
	if hand.size() < 2:
		hand.append("AST_FORCE_WARBAND")
	for condition in data().echo_cards[card_id]["eligibility"]:
		var region: String = str(session.world["regions"].keys()[0])
		(session.world["regions"][region]["tags"] as Array).append(
			str((condition as Dictionary)["tag"])
		)
	var before: int = session.service.hand_size("ENT_ALDRIC")
	var result: Dictionary = session.actions.execute(
		"ENT_ALDRIC", {"template": "PLAY_ECHO", "params": {"asset_card_id": asset_id}}
	)
	assert_true(bool(result.get("ok", false)), "la carta si cala: %s" % str(result.get("error", "")))

	var calate: Array = session.world["echo_played"] as Array
	assert_true(calate.has(card_id), "la carta calata sta nella pila scoperta: %s" % str(calate))
	var conditions: RefCounted = load("res://scripts/world/condition_evaluator.gd").new(
		session.world, data()
	)
	assert_true(
		conditions.holds({
			"type": "echo_function_played",
			"function": str(data().echo_cards[card_id]["function_id"]),
		}),
		"e da li' si legge la funzione che ha svolto"
	)
	assert_false(
		str(session.world["global_tags"]).contains("function:"),
		"senza scriverne niente sul mondo: quel segno non esiste piu' (D-358)"
	)
	# La parola si paga (D-118), e nella versione potenziata costa **due** carte:
	# quella che parla e un'altra scartata.
	assert_eq(
		session.service.hand_size("ENT_ALDRIC"), before - 2,
		"l'Eco costa la carta piu' un'altra scartata"
	)
	assert_false(
		(session.world["entities"]["ENT_ALDRIC"]["hand"] as Array).has(asset_id),
		"e la carta che l'ha detto non e' piu' in mano"
	)


## Propp's order, expressed as data: a card that presupposes something is not
## eligible until that something has happened.
func test_a_card_that_presupposes_something_waits_for_it() -> void:
	new_session()
	var card: Dictionary = data().echo_cards["ECH_RECONCILIATION"]
	assert_false(card["eligibility"].is_empty(), "la riconciliazione ha una precondizione")

	var conditions: RefCounted = load("res://scripts/world/condition_evaluator.gd").new(
		session.world, data()
	)
	assert_false(
		conditions.all_hold(card["eligibility"], {}),
		"senza un tradimento non e ancora giocabile"
	)

	# Il tradimento si fa succedere **calando la carta che lo porta**, non
	# scrivendo un segno a mano: e' la stessa cosa che farebbe un giocatore.
	var tradimento: String = ""
	for altro in data().echo_cards.values():
		if str(altro.get("function_id", "")) == "BETRAYAL":
			tradimento = str(altro["id"])
			break
	assert_ne(tradimento, "", "esiste una carta che porta il tradimento")
	(session.world["echo_played"] as Array).append(tradimento)
	assert_true(
		conditions.all_hold(card["eligibility"], {}),
		"dopo un tradimento, si"
	)


## An Act whose whole pool is gated could draw nothing at all, and the arc would
## simply not close. Every family must keep at least one card that presupposes
## nothing - over-gating RESOLUTION is what made Act 3 stop resolving.
func test_every_dramatic_family_keeps_an_unconditional_card() -> void:
	var families: Dictionary = {}
	for card in data().echo_cards.values():
		var family: String = str(card["dramatic_family"])
		if (card["eligibility"] as Array).is_empty():
			families[family] = str(card["id"])
	for family in ["PRESSURE", "RUPTURE", "TURN", "RESOLUTION"]:
		assert_true(
			families.has(family),
			"la famiglia %s non ha nessuna carta sempre giocabile" % family
		)


## L'Atto non pesca piu': **sceglie chi puo' parlare** (D-359). `act_echo_pools`
## era il sacchetto pesato da cui usciva una carta; adesso e' il cancello che
## dice quali famiglie si possono calare in quell'Atto. La forma in tre atti
## regge lo stesso, e la prova va fatta sul cancello, non sull'arco: nell'Atto 1
## CHR_00 ammette solo PRESSIONE, quindi l'Eco di una carta RISOLUZIONE dev'essere
## rifiutato **con quella ragione**, e quello di una PRESSIONE no.
func test_the_act_gates_which_family_may_speak() -> void:
	new_session()
	assert_eq(int(session.world["act"]), 1, "la prova parte dall'Atto 1")
	var pressione: String = _asset_whose_echo_is(data(), "PRESSURE")
	var risoluzione: String = _asset_whose_echo_is(data(), "RESOLUTION")
	assert_ne(pressione, "", "esiste una carta col suo Eco di pressione")
	assert_ne(risoluzione, "", "esiste una carta col suo Eco di risoluzione")

	var hand: Array = session.world["entities"]["ENT_ALDRIC"]["hand"] as Array
	hand.append(pressione)
	hand.append(risoluzione)
	hand.append("AST_FORCE_WARBAND")

	var fuori: String = session.actions.check(
		"ENT_ALDRIC", "PLAY_ECHO", {"asset_card_id": risoluzione}
	)
	assert_true(
		fuori.contains("non si cala in questo Atto"),
		"una risoluzione nell'Atto 1 va rifiutata per l'Atto, non per altro: «%s»" % fuori
	)
	var dentro: String = session.actions.check(
		"ENT_ALDRIC", "PLAY_ECHO", {"asset_card_id": pressione}
	)
	assert_false(
		dentro.contains("non si cala in questo Atto"),
		"e una pressione nell'Atto 1 non deve mai essere rifiutata per l'Atto: «%s»" % dentro
	)


## Una carta il cui Eco e' di quella famiglia e non chiede niente al mondo: cosi'
## la prova sopra misura il cancello dell'Atto e nient'altro.
func _asset_whose_echo_is(a_data: RefCounted, family: String) -> String:
	var ids: Array = a_data.assets.keys()
	ids.sort()
	for asset_id in ids:
		var echo: Variant = a_data.echo_cards.get(
			str((a_data.assets[str(asset_id)] as Dictionary)["echo_id"])
		)
		if echo == null:
			continue
		if str((echo as Dictionary)["dramatic_family"]) != family:
			continue
		if not ((echo as Dictionary)["eligibility"] as Array).is_empty():
			continue
		return str(asset_id)
	return ""


## The deck covers Propp's set exactly: every function the schema declares has a
## card, and the four dramatic families are balanced. Content that exists only in
## the enum is content that cannot happen.
func test_every_declared_function_has_a_card() -> void:
	var by_function: Dictionary = {}
	var by_family: Dictionary = {}
	for card in data().echo_cards.values():
		by_function[str(card["function_id"])] = str(card["id"])
		var family: String = str(card["dramatic_family"])
		by_family[family] = int(by_family.get(family, 0)) + 1

	for function_id in SchemaDefs.DEFS["echo_card"]["properties"]["function_id"]["enum"]:
		assert_true(
			by_function.has(str(function_id)),
			"la funzione '%s' e dichiarata nello schema ma nessuna carta la svolge" % function_id
		)
	# **Le famiglie stanno in pari** (D-359). Il conto per saga non ha piu' senso:
	# non c'e' un mazzo che una Chronicle compone coi soli Echi che parlano delle
	# sue questioni, perche' non c'e' un mazzo — ogni carta Asset porta il suo, e
	# le 48 carte sono nella scatola tutte insieme. Quello che conta adesso e' che
	# nessuna famiglia sia sottile: un Atto che ammette solo RISOLUZIONE e ne
	# trova due sul mazzo delle carte non risolve niente.
	var atteso: int = data().echo_cards.size() / 4
	for family in ["PRESSURE", "RUPTURE", "TURN", "RESOLUTION"]:
		assert_eq(
			int(by_family.get(family, 0)), atteso,
			"la famiglia %s deve pesare quanto le altre" % family
		)


## Two different cards must not ask for the same drawing (D-049).
##
## The second saga's twelve cards were generated with the key built from family
## and function - `echo.pressure.request` - which is exactly the key the first
## saga's Supplica already had. Nine of the twelve collided, and nothing noticed:
## the manifest lists whatever it is given. An art key is an order to somebody,
## and two cards sharing one is two cards that come back as the same picture.
func test_no_two_cards_ask_for_the_same_drawing() -> void:
	var seen: Dictionary = {}
	for card in data().echo_cards.values():
		var key: String = str(card["art_prompt_key"])
		assert_false(
			seen.has(key),
			"%s e %s chiedono lo stesso disegno: '%s'" % [str(seen.get(key, "")), str(card["id"]), key]
		)
		seen[key] = str(card["id"])


## `any_of` is what lets Propp's alternatives be written down: a Return follows a
## Separation *or* a Prohibition. Every other condition list in the data is an AND.
func test_any_of_holds_when_one_branch_does() -> void:
	new_session()
	var conditions: RefCounted = load("res://scripts/world/condition_evaluator.gd").new(
		session.world, data()
	)
	var condition: Dictionary = {
		"type": "any_of",
		"conditions": [
			{"type": "state_tag_present", "scope": "GLOBAL", "tag": "function:PROHIBITION"},
			{"type": "state_tag_present", "scope": "GLOBAL", "tag": "function:SEPARATION"},
		],
	}
	assert_false(conditions.holds(condition, {}), "nessuno dei due rami vale")

	session.applier.apply(
		Effect.make(
			"SET_GLOBAL_TAG", "world", "WORLD", {"tag": "function:SEPARATION"},
			Effect.source("test", "TEST", "", 1, 1, 0)
		)
	)
	assert_true(conditions.holds(condition, {}), "basta che ne valga uno")
