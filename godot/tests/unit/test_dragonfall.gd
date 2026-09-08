extends "res://tests/test_case.gd"
## La morte di Vaerax (D-127, decisione B della seduta sulle vite): la
## Conseguenza spegne il drago, segna la montagna con la caduta, e il Culto
## che nasce da quella morte (ON_DEATH, gia' provato in test_incarnations)
## legge proprio quella cicatrice. E il drago si difende: il punteggio teme
## la propria fine piu' di qualunque clausola.
##
## La porta di Propp - «la caccia si propone solo dopo una Rivelazione» - era
## l'eleggibilita' della proposta P_SLAY_THE_DRAGON, e le proposte sono
## uscite dal codice con il Consiglio di D-280 (D-467, D-472). Nel Consiglio
## a due domande CNS_DRAGON_SLAIN non sta nell'esito di base di nessuna
## delle due domande del Risveglio, quindi oggi nessun voto ci arriva: la
## prova della porta non ha piu' niente da custodire e non c'e' piu'.

const Effect := preload("res://scripts/core/effect.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")


func before_each() -> void:
	new_session()


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
