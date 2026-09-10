extends "res://tests/test_case.gd"
## **Il potere della casa** (D-503, ISSUES 136 punto 4).
##
## Parola del committente, dopo un anno giocato a mano: *«anche il potere di una
## entita' mi deve permettere di fare qualcosa»*. Il tarocco della Casata
## stampava `SA FARE  acquisire 3 · muovere 2 · influenzare 4 · forgiare 2 ·
## tramare 1 · rivendicare 4` e restava in vista tutta la partita, ma quei
## numeri li leggevano **tre posti e nessuno era una regola**: la faccia che li
## stampa, la scheda che la documenta, e l'eredita' alla successione.
##
## Adesso il numero piu' alto e' il potere: quel verbo si gioca **senza carta**,
## una volta per Atto. Al tavolo e' il tarocco che si ruota, e si rimette
## diritto all'Atto dopo.
##
## **La condizione se la fabbrica questa prova**: CHR_TEST non dichiara
## `house_power`, e una prova che cercasse il potere fra i dati spediti
## smetterebbe di provare in silenzio il giorno che l'interruttore si sposta.

const CardFace := preload("res://scripts/core/card_face.gd")

## Re Aldric: `influenzare 4 · rivendicare 4`, e MUOVERE a 2. Serve una casa con
## un verbo migliore **e** uno peggiore, per provare tutt'e due i lati.
const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


func _chronicle() -> Dictionary:
	return session.data.chronicles["CHR_TEST"] as Dictionary


## Accende il potere: la regola nella Chronicle **e** il tarocco diritto nel
## mondo. Le due meta' vanno accese insieme — una dichiarazione accesa e un
## mondo che il potere non ce l'ha sono due meta' di due giochi diversi, ed e'
## l'errore che D-184 ha gia' pagato una volta col rubinetto.
func _arm(per_act: int = 1, cards_are_the_coin: bool = false) -> void:
	var chronicle: Dictionary = _chronicle()
	chronicle["house_power"] = {"per_act": per_act}
	if cards_are_the_coin:
		chronicle["actions_from_cards"] = true
	session.actions.set("_chronicle", chronicle)
	for entity_id in session.world["entities"]:
		(session.world["entities"][str(entity_id)] as Dictionary)["house_power"] = per_act


func _disarm() -> void:
	var chronicle: Dictionary = _chronicle()
	chronicle.erase("house_power")
	chronicle.erase("actions_from_cards")


func _left() -> int:
	return int((session.world["entities"][SEAT] as Dictionary).get("house_power", 0))


func _influence(with_power: bool) -> Dictionary:
	var params: Dictionary = {
		"tension_id": "TEN_FAMINE", "delta": 1, "via": "PRESENCE",
	}
	if with_power:
		params["house_power"] = true
	return session.actions.execute(SEAT, {"template": "INFLUENCE", "params": params})


## **Il verbo migliore si gioca senza carta**, e con le carte come unica moneta
## e' la sola porta che resta aperta a mano vuota. Provato sui due lati dello
## stesso interruttore: senza il potere l'Azione e' rifiutata perche' vuole una
## carta, col potere passa.
func test_the_best_verb_is_played_without_a_card() -> void:
	_arm(1, true)
	var refused: Dictionary = _influence(false)
	assert_false(bool(refused["ok"]), "senza carta e senza potere non si influenza")
	assert_true(
		str(refused["error"]).contains("con le carte"),
		"e il motivo e la moneta: «%s»" % str(refused["error"])
	)

	var done: Dictionary = _influence(true)
	assert_true(bool(done["ok"]), "col potere della casa passa: %s" % str(done["error"]))
	assert_eq(_left(), 0, "e il tarocco resta ruotato")
	_disarm()


## **Solo il verbo che la casa sa fare meglio.** MUOVERE per Aldric vale 2
## contro il 4 di influenzare e rivendicare: il potere non lo apre, e il rifiuto
## dice quali sono i suoi verbi invece di dire soltanto no.
func test_the_power_opens_only_the_verb_the_house_does_best() -> void:
	_arm()
	var refused: Dictionary = session.actions.execute(SEAT, {
		"template": "MOVE",
		"params": {"region_id": "REG_STRADA_MERCANTI", "house_power": true},
	})
	assert_false(bool(refused["ok"]), "il potere non apre un verbo qualunque")
	assert_true(
		str(refused["error"]).contains("influenzare")
		and str(refused["error"]).contains("rivendicare"),
		"e dice quali sono i suoi: «%s»" % str(refused["error"])
	)
	assert_eq(_left(), 1, "e il tarocco e ancora diritto")
	_disarm()


## **Una volta per Atto.** Il secondo tentativo si rifiuta **per il potere
## speso**, non per un'altra regola: qui la prova e' delicata di proposito,
## perche' INFLUENZARE ha anche un tetto suo per round (`influence_rules`) e un
## rifiuto letto di sfuggita sembrerebbe la stessa cosa. Il messaggio dice
## quale delle due porte si e' chiusa.
func test_the_power_is_spent_once_per_act() -> void:
	_arm()
	assert_true(bool(_influence(true)["ok"]), "il primo passa")
	var refused: Dictionary = _influence(true)
	assert_false(bool(refused["ok"]), "il secondo no")
	assert_true(
		str(refused["error"]).contains("gia' speso"),
		"e il motivo e il potere, non il tetto di INFLUENZARE: «%s»" % str(refused["error"])
	)
	_disarm()


## **Un'Azione rifiutata non costa il potere**, come non costa la carta: qui il
## delta 3 non e' una mossa legale, e il tarocco resta diritto.
func test_a_refused_action_does_not_spend_the_power() -> void:
	_arm()
	var refused: Dictionary = session.actions.execute(SEAT, {
		"template": "INFLUENCE",
		"params": {
			"tension_id": "TEN_FAMINE", "delta": 3, "via": "PRESENCE", "house_power": true,
		},
	})
	assert_false(bool(refused["ok"]), "tre gradini in una volta non si fanno")
	assert_eq(_left(), 1, "e il potere non e stato speso")
	_disarm()


## **E dove la Chronicle il potere non lo da', il potere non c'e'.** Provato
## girando l'interruttore invece di fidarsi: il mondo ha il tarocco diritto, la
## dichiarazione no, e l'Azione col potere si rifiuta. Senza questa prova
## l'interruttore potrebbe non essere letto da nessuno e le altre prove
## direbbero le stesse cose.
func test_without_the_chronicle_there_is_no_power() -> void:
	assert_false(_chronicle().has("house_power"), "la Chronicle di prova non lo dichiara")
	(session.world["entities"][SEAT] as Dictionary)["house_power"] = 1
	var refused: Dictionary = _influence(true)
	assert_false(bool(refused["ok"]), "senza la regola non c'e potere da spendere")
	assert_true(
		str(refused["error"]).contains("non hanno un potere"),
		"e il motivo e la Chronicle: «%s»" % str(refused["error"])
	)


## **E il potere si legge sulla carta**, accanto ai numeri che lo decidono. Una
## regola che sta nel manuale e non sul cartoncino, al tavolo non esiste.
func test_the_tarot_prints_the_power() -> void:
	_arm()
	var face: Dictionary = CardFace.of("entity", SEAT, session.data)
	var notes: Array = face["notes"] as Array
	var power_line: String = ""
	for note in notes:
		if str(note).begins_with("POTERE"):
			power_line = str(note)
	assert_true(power_line != "", "il tarocco porta la riga del potere: %s" % str(notes))
	assert_true(
		power_line.contains("influenzare") and power_line.contains("rivendicare"),
		"e nomina i verbi migliori di questa casa: «%s»" % power_line
	)
	assert_true(
		power_line.contains("senza carta"),
		"e dice cosa il potere permette: «%s»" % power_line
	)
	_disarm()
