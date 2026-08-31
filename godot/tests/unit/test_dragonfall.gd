extends "res://tests/test_case.gd"
## La morte di Vaerax (D-127, decisione B della seduta sulle vite): per via
## di Propp. La caccia si propone solo quando una Rivelazione ha mostrato
## cosa dorme; la Conseguenza spegne il drago, segna la montagna con la
## caduta, e il Culto che nasce da quella morte (ON_DEATH, gia' provato in
## test_incarnations) legge proprio quella cicatrice. E il drago si difende:
## il punteggio teme la propria fine piu' di qualunque clausola.

const Effect := preload("res://scripts/core/effect.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func before_each() -> void:
	new_session()


func _heat(tension_id: String, target: int) -> void:
	var current: int = int(session.world["tensions"][tension_id]["current_value"])
	if current == target:
		return
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", tension_id,
		{"delta": target - current}, {"kind": "TEST", "id": "heat"}
	))


func _proposition_ids() -> Array:
	var out: Array = []
	for proposition in session.confluence.available_propositions():
		out.append(str((proposition as Dictionary)["id"]))
	return out


## La carta di Propp e' la porta: senza la funzione della Rivelazione la
## caccia non si puo' nemmeno proporre.
func test_the_hunt_needs_the_revelation_first() -> void:
	_heat("TEN_AWAKENING", 6)
	var context: Dictionary = session.confluence.open("TEN_AWAKENING", {"kind": "THRESHOLD"})
	assert_false(context.is_empty(), "il Consiglio si apre")
	session.confluence.set_question("Q_AWAKENING_MOUNTAIN")
	assert_false(
		_proposition_ids().has("P_SLAY_THE_DRAGON"),
		"senza Rivelazione la caccia non e' sul tavolo"
	)
	session.confluence.current = {}
	# La Rivelazione si fa succedere **calando la carta che la porta** (D-358):
	# la porta della caccia non e' piu' un segno nascosto sul mondo, e' una carta
	# scoperta sul tavolo.
	var rivelazione: String = ""
	for card in session.data.echo_cards.values():
		if str(card.get("function_id", "")) == "REVELATION":
			rivelazione = str(card["id"])
			break
	assert_ne(rivelazione, "", "esiste una carta che porta la Rivelazione")
	(session.world["echo_played"] as Array).append(rivelazione)
	session.confluence.open("TEN_AWAKENING", {"kind": "THRESHOLD"})
	session.confluence.set_question("Q_AWAKENING_MOUNTAIN")
	assert_true(
		_proposition_ids().has("P_SLAY_THE_DRAGON"),
		"mostrato cio' che dorme, la caccia si puo' proporre"
	)


## La Conseguenza: il drago si spegne, la montagna porta la caduta, e la
## memoria che armera' il Culto e' esattamente quella cicatrice.
func test_the_slaying_puts_out_the_dragon_and_scars_the_mountain() -> void:
	var source: Dictionary = Effect.source("test", "TEST", "", 3, 1, 0)
	for effect in session.compiler.compile("CNS_DRAGON_SLAIN", {}, source):
		session.applier.apply(effect)
	assert_false(
		bool(session.world["entities"]["ENT_VAERAX"].get("active", true)),
		"il drago non e' piu' al tavolo"
	)
	assert_false(
		session.service.active_entities().has("ENT_VAERAX"),
		"e il giro delle azioni non lo chiama"
	)
	assert_true(
		(session.world["global_tags"] as Array).has("dragon_slain"),
		"il mondo ricorda"
	)


## Il drago si difende: la propria fine pesa nel punteggio piu' di ogni
## clausola, e per gli altri seggi resta un fatto neutro.
func test_the_dragon_fears_its_own_end() -> void:
	var decider: RefCounted = PolicyDecider.new(null)
	var effect: Dictionary = {
		"type": "SET_ENTITY_ACTIVE",
		"target": {"kind": "entity", "id": "ENT_VAERAX"},
		"payload": {"active": false},
	}
	var goals: Dictionary = decider._tag_goals("ENT_VAERAX", session)
	var fear: int = decider._score_effect(
		effect, "ENT_VAERAX", "ENT_LYRA", goals, session, {}
	)
	assert_true(fear <= -6, "la propria morte vale un no assoluto: %d" % fear)
	var bystander: int = decider._score_effect(
		effect, "ENT_ALDRIC", "ENT_LYRA", decider._tag_goals("ENT_ALDRIC", session), session, {}
	)
	assert_eq(bystander, 0, "la morte altrui non e' un obiettivo di nessuno")
