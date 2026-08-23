extends "res://tests/test_case.gd"
## Nessun tavolo apre senza una storia ([D-216](DECISIONS.md#d-216)).
##
## Con le case pescate (D-213) le relazioni scritte solo dentro la vecchia linea
## lasciavano **un tavolo su sette** con quattro estranei: nessuna clausola che
## legge un legame si qualificava, il peso dell'alleanza al Consiglio non si
## applicava mai, e FORGIARE partiva da zero per tutti. Non è un tavolo
## tranquillo: è un tavolo senza storia.
##
## La prova sta qui e non solo nella guardia dei dati perché le due cose dicono
## cose diverse. La guardia dice **che ogni coppia è scritta**; questa dice
## **che quello che è scritto arriva davvero al tavolo che il seme apparecchia** —
## e sono due affermazioni che si sono già staccate una volta, quando due
## clausole nominavano una casa che poteva non sedersi.

const ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]


func _hot_pairs(seats: Array) -> int:
	var hot: int = 0
	for i in range(seats.size()):
		for j in range(i + 1, seats.size()):
			if session.service.relation_level(str(seats[i]), str(seats[j])) != "NEUTRAL":
				hot += 1
	return hot


## Su cinquanta tavoli pescati, nessuno apre piatto.
func test_no_drawn_table_opens_without_a_single_bond() -> void:
	for index in range(50):
		var seed_value: int = 7000 + index * 3
		var seats: Array = GameSession.seats_for(data(), "CHR_01", seed_value)
		if session != null:
			session.dispose()
		session = GameSession.new(data())
		assert_true(session.setup("CHR_01", seats, seed_value), "il seme apparecchia")
		for effect in session.factory_setup_effects():
			session.applier.apply(effect)
		assert_true(
			_hot_pairs(seats) > 0,
			"seme %d: %s si conoscono" % [seed_value, ", ".join(PackedStringArray(seats))]
		)


## E le relazioni che arrivano al mondo sono quelle scritte, non un default:
## un tavolo interamente misto — due case di una linea e due dell'altra — porta
## almeno un legame **incrociato**, che è esattamente quello che mancava.
func test_a_mixed_table_carries_a_crossed_bond() -> void:
	var grain: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
	var mixed: Array = ["ENT_ALDRIC", "ENT_LYRA", "ENT_SALE", "ENT_VETRO"]
	if session != null:
		session.dispose()
	session = GameSession.new(data())
	assert_true(session.setup("CHR_01", mixed, 4242), "il tavolo misto si apparecchia")
	var crossed: int = 0
	for first in mixed:
		for second in mixed:
			if str(first) >= str(second):
				continue
			var same_side: bool = grain.has(str(first)) == grain.has(str(second))
			if same_side:
				continue
			if session.service.relation_level(str(first), str(second)) != "NEUTRAL":
				crossed += 1
	assert_true(crossed > 0, "almeno un legame attraversa i secoli: %d" % crossed)
