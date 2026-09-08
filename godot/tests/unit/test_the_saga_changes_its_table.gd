extends "res://tests/test_case.gd"
## **Una saga cambia tavolo, e la pagina lo deve fare** (D-473, parola del
## committente: *«la terza Chronicle ripartiva dalla prima quando chiedevo di
## andare avanti»*).
##
## La regola sta sulla Chronicle da [D-431](../../docs/DECISIONS.md#d-431) —
## `seats_between_eras: REDRAW`, *«le case passano, il mondo resta»* — e le
## sonde la applicano da allora. La pagina no: rimetteva a sedere le quattro
## case **scritte** a ogni era, quindi dieci anni di saga erano dieci volte lo
## stesso tavolo. Da fuori, il terzo anno sembrava il primo.
##
## Qui si prova la regola (che il tavolo cambi davvero) e la cosa che la rende
## giocabile: **chi gioca tiene il posto, non la casa**.

const GameScreen := preload("res://ui/game_screen.gd")


## Il tavolo dell'era dopo non e' quello scritto sulla Chronicle: e' quello che
## la regola pesca. Se un giorno i due tornassero uguali, questa prova lo dice.
func test_the_next_era_draws_a_different_table() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	var written: Array = (loaded.chronicles["CHR_00"]["entities"] as Array).duplicate()
	assert_eq(
		str((loaded.chronicles["CHR_00"] as Dictionary).get("seats_between_eras", "")),
		"REDRAW",
		"la Chronicle spedita dice che il tavolo si ripesca"
	)
	var changed: int = 0
	var seats: Array = written.duplicate()
	var seed_value: int = 4242
	for era in range(4):
		seed_value += 97
		var next: Array = GameSession.seats_for_next_era(loaded, "CHR_00", seed_value, seats)
		assert_eq(next.size(), seats.size(), "e il tavolo resta di quattro posti")
		if next != seats:
			changed += 1
		seats = next
	assert_true(changed >= 1, "in quattro ere il tavolo cambia almeno una volta")


## **Chi gioca tiene il posto.** La casa che sedeva li' e' passata; la persona
## che la giocava prende quella che ci si siede adesso, e non resta fuori.
func test_a_person_keeps_the_seat_when_the_house_passes() -> void:
	var before: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
	var now: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_SALE", "ENT_VETRO"]
	var humans: Array = GameScreen._inherit_seats(["ENT_LYRA"], before, now)
	assert_eq(humans, ["ENT_SALE"], "chi giocava il terzo posto gioca il terzo posto")


## Una casa che resta al tavolo tiene la sua persona, anche se ha cambiato
## posto: e' la stessa casa, e chi la gioca la segue.
func test_a_house_that_stays_keeps_its_player() -> void:
	var before: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
	var now: Array = ["ENT_VETRO", "ENT_LYRA", "ENT_SALE", "ENT_ALDRIC"]
	var humans: Array = GameScreen._inherit_seats(["ENT_LYRA", "ENT_ALDRIC"], before, now)
	assert_true(humans.has("ENT_LYRA"), "Lyra e' ancora al tavolo, e la gioca la stessa persona")
	assert_true(humans.has("ENT_ALDRIC"), "e cosi' Aldric")
	assert_eq(humans.size(), 2, "due persone, due seggi")


## E due persone non finiscono sulla stessa casa: sarebbe un seggio giocato due
## volte, che al tavolo non esiste.
func test_two_people_never_land_on_the_same_house() -> void:
	var before: Array = ["ENT_A", "ENT_B", "ENT_C", "ENT_D"]
	var now: Array = ["ENT_X", "ENT_X", "ENT_Y", "ENT_Z"]
	var humans: Array = GameScreen._inherit_seats(["ENT_A", "ENT_B"], before, now)
	assert_eq(humans.size(), 1, "il secondo non si siede sulla stessa casa del primo")
