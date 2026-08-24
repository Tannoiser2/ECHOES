extends "res://tests/test_case.gd"
## La traccia del Calore (PZ-1).
##
## Il Calore era un ponte: la Risonanza scaldava «la questione piu' vicina alla
## soglia del Tema», e la pista che il tavolo fisico legge non esisteva da
## nessuna parte. Da PZ-1 e' **stato del mondo**: sei Temi, un segnalino 0-6
## ciascuno, mosso solo per Effect col suo inverso — e a fine Atto il Tema piu'
## caldo apre la sua Domanda.
##
## La lezione di casa vale anche qui: prima di credere a uno zero, provalo su
## un caso che deve dare non-zero. Ogni prova qui sotto fabbrica il suo caso.

const Effect := preload("res://scripts/core/effect.gd")

## Una carta con la faccia fisica, e il Tema che la sua Risonanza scalda.
const CARTA: String = "AST_AUTHORITY_CENSUS"
const TEMA: String = "THM_POTERE"


func before_each() -> void:
	new_session()


func _give(entity_id: String, asset_id: String) -> void:
	session.applier.apply(Effect.make(
		"GRANT_ASSET", "entity", entity_id, {"asset_id": asset_id},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


func _heat(theme_id: String) -> int:
	return int((session.world.get("theme_heat", {}) as Dictionary).get(theme_id, 0))


func _warm(theme_id: String, delta: int) -> void:
	session.applier.apply(Effect.make(
		"ADJUST_THEME_HEAT", "theme", theme_id, {"delta": delta},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


## **La pista esiste dal primo round, e parte fredda.** Tutti e sei i Temi:
## un Tema assente dalla pista non e' un Tema freddo, e' un buco.
func test_the_track_starts_cold_for_every_theme() -> void:
	var track: Dictionary = session.world.get("theme_heat", {}) as Dictionary
	assert_eq(track.size(), data().themes.size(), "la pista ha una tacca per Tema")
	for theme_id in data().themes:
		assert_true(track.has(str(theme_id)), "il Tema %s sta sulla pista" % [str(theme_id)])
		assert_eq(int(track[str(theme_id)]), 0, "%s parte freddo" % [str(theme_id)])


## **Giocare una carta con la faccia scalda la pista del suo Tema.** Il caso
## non-zero fabbricato: prima 0, poi almeno il Calore scritto sulla carta.
func test_playing_a_faced_card_heats_the_track() -> void:
	assert_eq(_heat(TEMA), 0, "prima della carta la pista e' fredda")
	var face: Dictionary = (data().assets[CARTA] as Dictionary).get("physical", {}) as Dictionary
	var written: int = int((face.get("resonance", {}) as Dictionary).get("heat", 0))
	assert_true(written > 0, "la carta dichiara un Calore")

	var tension_id: String = ""
	for candidate in session.world["tensions"]:
		tension_id = str(candidate)
		break
	_give("ENT_ALDRIC", CARTA)
	var outcome: Dictionary = session.actions.execute("ENT_ALDRIC", {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARTA, "mode": "TENSION", "tension_id": tension_id},
	})
	assert_true(bool(outcome.get("ok", false)), "la carta si gioca: %s" % [str(outcome.get("error", ""))])
	assert_true(
		_heat(TEMA) >= written,
		"la pista di %s segna almeno %d (segna %d)" % [TEMA, written, _heat(TEMA)]
	)


## **Il tetto e' sei, e l'inverso e' esatto anche sotto il tetto.** Una salita
## mozzata che tornasse indietro intera lascerebbe la pista piu' fredda di
## com'era: il round-trip e' la guardia dell'effect-sourcing.
func test_the_heat_clamps_at_six_and_round_trips() -> void:
	_warm(TEMA, 2)
	assert_eq(_heat(TEMA), 2, "la pista sale di quanto scritto")
	_warm(TEMA, 10)
	assert_eq(_heat(TEMA), 6, "la pista si ferma a sei")
	assert_true(session.applier.undo_last(1), "l'ultimo Effetto si annulla")
	assert_eq(_heat(TEMA), 2, "l'inverso rende solo quello che il tetto aveva lasciato salire")
	assert_true(session.applier.undo_last(1), "anche il primo si annulla")
	assert_eq(_heat(TEMA), 0, "la pista torna fredda")


## **E non scende mai sotto lo zero.**
func test_the_track_never_reads_below_zero() -> void:
	_warm(TEMA, -3)
	assert_eq(_heat(TEMA), 0, "raffreddare un Tema freddo lo lascia a zero")
	assert_true(session.applier.undo_last(1), "e l'inverso non lo scalda")
	assert_eq(_heat(TEMA), 0, "la pista resta a zero")


## **Un Tema che non esiste non si scalda: l'Effetto fallisce, non tace.**
func test_heating_a_ghost_theme_fails_loudly() -> void:
	var stored: Dictionary = session.applier.apply(Effect.make(
		"ADJUST_THEME_HEAT", "theme", "THM_FANTASMA", {"delta": 1},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	assert_true(stored.is_empty(), "l'Effetto su un Tema inesistente non passa")
	assert_ne(str(session.applier.last_error), "", "e dice perche'")


## **A fine Atto la Domanda e' quella del Tema piu' caldo.** Si scalda un Tema
## solo, e la questione scelta deve essere una sua.
func test_the_hottest_theme_opens_the_act_question() -> void:
	_warm(TEMA, 3)
	var chosen: String = str(session.chronicle._question_of_the_hottest_theme())
	assert_ne(chosen, "", "la pista calda sceglie una questione")
	assert_eq(
		str((data().tensions[chosen] as Dictionary).get("theme", "")), TEMA,
		"la questione scelta appartiene al Tema piu' caldo"
	)


## **Sotto il freddo decide il mucchio.** Pista tutta a zero: la scelta per
## Tema si ritira, e resta la regola vecchia — che e' il ripiego dichiarato.
func test_a_cold_track_chooses_nothing() -> void:
	assert_eq(
		str(session.chronicle._question_of_the_hottest_theme()), "",
		"nessun Tema caldo, nessuna scelta dalla pista"
	)


## **Il Tema che ha parlato torna a zero, gli altri tengono il loro.**
func test_the_theme_that_spoke_cools_and_the_rest_keep_burning() -> void:
	_warm(TEMA, 4)
	_warm("THM_VIE", 2)
	session.chronicle._cool_theme_after_council(TEMA, 1)
	assert_eq(_heat(TEMA), 0, "il Tema della Domanda torna freddo")
	assert_eq(_heat("THM_VIE"), 2, "un fuoco che nessuno ha guardato non si spegne da solo")
	# E il raffreddamento e' nel verbale, con la firma del sistema.
	var last: Dictionary = (session.world["effect_log"] as Array).back() as Dictionary
	assert_eq(str(last.get("type", "")), "ADJUST_THEME_HEAT", "il raffreddamento e' un Effetto")
	assert_eq(str((last.get("source", {}) as Dictionary).get("id", "")), "ACT_END", "firmato dalla fine dell'Atto")
