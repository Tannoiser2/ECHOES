extends "res://tests/test_case.gd"
## Chi siede l'anno prossimo, e chi lo decide (D-431 — ISSUES 64).
##
## Fino alla 0.1.401 questa regola **non era scritta da nessuna parte**, e ogni
## sonda ne applicava una sua: `run_era_probe` ripescava il tavolo con un seme
## per era — meta' dei seggi cambiava casa, misurato in
## [D-237](docs/DECISIONS.md#d-237) — e `run_saga` lo teneva fermo per tutti i
## secoli della saga. **Due sonde, due giochi con lo stesso nome**, e nessuno
## aveva deciso quale fosse quello vero.
##
## Adesso la regola sta sulla Chronicle e la applicano tutte. Qui si prova che
## il motore la **esegue**: le tre strade si fabbricano, cosi' la prova regge
## anche il giorno che la Chronicle spedita cambia idea.

func before_each() -> void:
	new_session()


## Il dato si **fabbrica**: cercare una Chronicle con la regola voluta fra
## quelle spedite vorrebbe dire che il giorno che cambia la prova smette di
## provare, in silenzio.
func _data_with(rule: String) -> RefCounted:
	var loaded: RefCounted = session.data
	(loaded.chronicles["CHR_00"] as Dictionary)["seats_between_eras"] = rule
	return loaded


## **`REDRAW` ripesca, ed e' la regola scelta.** Il tavolo dell'anno dopo esce
## dal seme di quell'anno, non da chi sedeva prima.
func test_redraw_asks_the_bag_again() -> void:
	var loaded: RefCounted = _data_with("REDRAW")
	var prima: Array = ["ENT_ALDRIC", "ENT_NAHR", "ENT_LYRA", "ENT_VAERAX"]
	assert_eq(
		GameSession.seats_for_next_era(loaded, "CHR_00", 4242, prima),
		GameSession.seats_for(loaded, "CHR_00", 4242),
		"col REDRAW il tavolo e' quello che pesca il seme"
	)


## **`KEEP` tiene gli stessi**, qualunque cosa dica il seme.
func test_keep_holds_the_same_table() -> void:
	var loaded: RefCounted = _data_with("KEEP")
	var prima: Array = ["ENT_SALE", "ENT_VETRO", "ENT_CENERE", "ENT_LIBERE"]
	assert_eq(
		GameSession.seats_for_next_era(loaded, "CHR_00", 4242, prima), prima,
		"col KEEP siedono le stesse case"
	)


## **`KEEP_THEN_DRAW` tiene chi c'era**, e il tavolo resta della stessa misura.
func test_precedence_keeps_who_was_there() -> void:
	var loaded: RefCounted = _data_with("KEEP_THEN_DRAW")
	var prima: Array = ["ENT_SALE", "ENT_VETRO"]
	var dopo: Array = GameSession.seats_for_next_era(loaded, "CHR_00", 4242, prima)
	assert_eq(dopo.size(), prima.size(), "il tavolo non cambia misura")
	assert_true(dopo.has("ENT_SALE") and dopo.has("ENT_VETRO"), "chi c'era resta")


## **Il primo anno non ha un «prima»**, e allora si pesca comunque: e' il caso
## che apre ogni saga, e senza questa riga la regola non saprebbe cosa fare.
func test_the_first_year_simply_draws() -> void:
	var loaded: RefCounted = _data_with("KEEP")
	assert_eq(
		GameSession.seats_for_next_era(loaded, "CHR_00", 4242, []),
		GameSession.seats_for(loaded, "CHR_00", 4242),
		"il primo anno pesca, qualunque sia la regola"
	)


## **E la Chronicle spedita dichiara la sua.** Una regola che nessuno scrive e'
## quella che si e' deciso di non decidere: lo schema la pretende, e questa
## prova dice **quale** e' stata scelta.
func test_the_shipped_chronicle_says_which_rule_it_plays() -> void:
	assert_eq(
		str((session.data.chronicles["CHR_00"] as Dictionary).get("seats_between_eras", "")),
		"REDRAW",
		"CHR_00 ripesca il tavolo fra un anno e l'altro"
	)
