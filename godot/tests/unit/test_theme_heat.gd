extends "res://tests/test_case.gd"
## I mazzetti dei Temi (D-261, parola del committente — prima PZ-1/D-260).
##
## Sei Temi, sei mazzetti di Tensioni coperti. Una Risonanza fa cadere sul
## mazzetto del suo Tema tanti gettoni **coperti** quanto il Calore della
## carta, ognuno col valore pescato dal sacchetto (0/1/2). A due segnalini la
## prima carta si gira e il tavolo sa quale Tensione si va scaldando. A fine
## Atto i mazzetti si rivelano: il piu' alto porta al Consiglio la sua carta
## girata, il secondo va a chi ha rivendicato un secondo dibattito, e poi i
## mazzetti si spendono.
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


func _tokens(theme_id: String) -> int:
	return int((session.world.get("theme_tokens", {}) as Dictionary).get(theme_id, 0))


func _warm(theme_id: String, delta: int) -> void:
	session.applier.apply(Effect.make(
		"ADJUST_THEME_HEAT", "theme", theme_id, {"delta": delta},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


func _play(who: String, asset_id: String, which: int = 0) -> Dictionary:
	# `which` sceglie la questione bersaglio: lo scouting non si ripete sulla
	# stessa Tensione, quindi due giocate della stessa carta ne toccano due.
	var ids: Array = (session.world["tensions"] as Dictionary).keys()
	ids.sort()
	var tension_id: String = str(ids[which % ids.size()])
	_give(who, asset_id)
	return session.actions.execute(who, {
		"template": "PLAY_CARD",
		"params": {"asset_id": asset_id, "mode": "TENSION", "tension_id": tension_id},
	})


## **I mazzetti esistono dal primo round: tutti e sei, freddi e coperti.**
## Ogni questione in gioco sta nel mazzetto del suo Tema, e nessuna carta e'
## girata.
func test_the_decks_start_cold_and_covered() -> void:
	var track: Dictionary = session.world.get("theme_heat", {}) as Dictionary
	var decks: Dictionary = session.world.get("theme_decks", {}) as Dictionary
	assert_eq(track.size(), data().themes.size(), "una pista per Tema")
	assert_eq(decks.size(), data().themes.size(), "un mazzetto per Tema")
	var dealt: int = 0
	for theme_id in data().themes:
		assert_eq(int(track[str(theme_id)]), 0, "%s parte freddo" % [str(theme_id)])
		assert_eq(_tokens(str(theme_id)), 0, "%s parte senza gettoni" % [str(theme_id)])
		assert_eq(
			str(session.tensions.theme_front(str(theme_id))), "",
			"%s parte tutto coperto" % [str(theme_id)]
		)
		for tension_id in (decks[str(theme_id)] as Array):
			dealt += 1
			assert_eq(
				str((data().tensions[str(tension_id)] as Dictionary).get("theme", "")),
				str(theme_id),
				"«%s» sta nel mazzetto del suo Tema" % [str(tension_id)]
			)
	assert_eq(dealt, (session.world["tensions"] as Dictionary).size(),
		"ogni questione in gioco sta in un mazzetto")


## **La Risonanza fa cadere gettoni coperti: tanti quanto il Calore della
## carta.** Il conto dei gettoni e' certo; il valore lo decide il sacchetto
## (0/1/2), quindi si prova l'intervallo, non il numero.
func test_playing_a_faced_card_drops_covered_tokens() -> void:
	assert_eq(_tokens(TEMA), 0, "prima della carta il mazzetto e' vuoto")
	var face: Dictionary = (data().assets[CARTA] as Dictionary).get("physical", {}) as Dictionary
	var written: int = int((face.get("resonance", {}) as Dictionary).get("heat", 0))
	assert_true(written > 0, "la carta dichiara un Calore")

	var outcome: Dictionary = _play("ENT_ALDRIC", CARTA)
	assert_true(bool(outcome.get("ok", false)), "la carta si gioca: %s" % [str(outcome.get("error", ""))])
	assert_true(_tokens(TEMA) >= written, "cadono almeno %d gettoni (caduti: %d)" % [written, _tokens(TEMA)])
	assert_true(
		_heat(TEMA) <= 2 * _tokens(TEMA),
		"il valore (%d) non supera due volte i gettoni (%d): il sacchetto e' 0/1/2" % [_heat(TEMA), _tokens(TEMA)]
	)


## **A due segnalini la prima carta si gira.** Due Risonanze da un gettone
## l'una sullo stesso Tema, e il fronte compare — ed e' la testa del mazzetto
## deciso dal setup.
func test_the_first_card_flips_at_two_tokens() -> void:
	var expected: String = str((session.world["theme_decks"][TEMA] as Array)[0]) \
		if not (session.world["theme_decks"][TEMA] as Array).is_empty() else ""
	assert_ne(expected, "", "il mazzetto di %s ha almeno una carta" % TEMA)
	assert_true(bool(_play("ENT_ALDRIC", CARTA).get("ok", false)), "la prima carta si gioca")
	if _tokens(TEMA) < 2:
		assert_eq(str(session.tensions.theme_front(TEMA)), "", "a un segnalino resta coperto")
		var again: Dictionary = _play("ENT_ALDRIC", CARTA, 1)
		assert_true(bool(again.get("ok", false)), "la seconda si gioca: %s" % [str(again.get("error", ""))])
	assert_true(_tokens(TEMA) >= 2, "due segnalini sono caduti")
	assert_eq(str(session.tensions.theme_front(TEMA)), expected,
		"la carta girata e' la testa del mazzetto")


## **Il tetto e' sei, e l'inverso e' esatto anche sotto il tetto.**
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


## **Il mazzetto piu' alto porta al Consiglio la sua carta girata.** Si scalda
## un Tema solo: la questione scelta e' del suo mazzetto, e diventa (o era) il
## suo fronte.
func test_the_hottest_deck_opens_with_its_front() -> void:
	_warm(TEMA, 3)
	var chosen: String = str(session.chronicle._front_of_hottest_theme(""))
	assert_ne(chosen, "", "il mazzetto caldo sceglie una questione")
	assert_eq(
		str((data().tensions[chosen] as Dictionary).get("theme", "")), TEMA,
		"la questione scelta appartiene al Tema piu' caldo"
	)
	assert_eq(str(session.tensions.theme_front(TEMA)), chosen,
		"ed e' la carta girata di quel mazzetto")


## **Il secondo dibattito esclude il Tema del primo.** Due Temi caldi: il
## secondo scelto non e' il primo.
func test_the_second_council_takes_the_second_deck() -> void:
	_warm(TEMA, 4)
	_warm("THM_SOPRAVVIVENZA", 2)
	var first: String = str(session.chronicle._front_of_hottest_theme(""))
	assert_eq(str((data().tensions[first] as Dictionary).get("theme", "")), TEMA, "il primo e' il piu' caldo")
	var second: String = str(session.chronicle._front_of_hottest_theme(TEMA))
	assert_ne(second, "", "il secondo dibattito trova una questione")
	assert_eq(
		str((data().tensions[second] as Dictionary).get("theme", "")), "THM_SOPRAVVIVENZA",
		"ed e' il secondo mazzetto piu' alto"
	)


## **A mazzetti freddi la rivelazione non sceglie niente.**
func test_a_cold_table_chooses_nothing() -> void:
	assert_eq(
		str(session.chronicle._front_of_hottest_theme("")), "",
		"nessun Tema caldo, nessuna scelta dai mazzetti"
	)


## **I mazzetti si spendono a fine Atto: tutti.** E la carta girata resta
## girata — una questione scoperta non si copre piu'.
func test_the_piles_are_spent_after_the_councils() -> void:
	_warm(TEMA, 4)
	_warm("THM_VIE", 2)
	session.world["theme_tokens"][TEMA] = 3
	var front: String = str(session.tensions.flip_theme_front(TEMA))
	assert_ne(front, "", "una carta e' girata")
	session.chronicle._spend_the_piles(1)
	assert_eq(_heat(TEMA), 0, "il mazzetto dibattuto torna freddo")
	assert_eq(_heat("THM_VIE"), 0, "anche quello non dibattuto: l'Atto nuovo riparte da zero")
	assert_eq(_tokens(TEMA), 0, "i gettoni lasciano il tavolo")
	assert_eq(str(session.tensions.theme_front(TEMA)), front, "la carta girata resta girata")
	var last: Dictionary = (session.world["effect_log"] as Array).back() as Dictionary
	assert_eq(str(last.get("type", "")), "ADJUST_THEME_HEAT", "lo spendere e' un Effetto")
	assert_eq(str((last.get("source", {}) as Dictionary).get("id", "")), "ACT_END", "firmato dalla fine dell'Atto")
