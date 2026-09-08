extends "res://tests/test_case.gd"
## **La Risonanza avviene comunque, ma il Tema lo scegli tu**
## ([D-482](DECISIONS.md#d-482)).
##
## Domanda del committente: *«quali sono le effettive scelte che fa un
## giocatore? […] quale il meccanismo di gioco di echoes?»*
## ([ISSUES 132](../../docs/ISSUES.md#132)). La risposta misurata era: il
## meccanismo c'e' ed e' **l'agenda** — il Tema piu' caldo decide quale domanda
## va al Consiglio — ma quella leva si muoveva **alla cieca**, perche' la
## Risonanza scaldava il Tema stampato e basta.
##
## Adesso la carta ne stampa due e chi la gioca dice quale. La Risonanza resta
## obbligatoria: non si puo' non scaldare niente.

const Effect := preload("res://scripts/core/effect.gd")

## Una carta che stampa due Temi.
const CARTA: String = "AST_AUTHORITY_CENSUS"


func before_each() -> void:
	new_session()


func _give(entity_id: String, asset_id: String) -> void:
	session.applier.apply(Effect.make(
		"GRANT_ASSET", "entity", entity_id, {"asset_id": asset_id},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


func _resonance() -> Dictionary:
	return (data().assets[CARTA]["physical"] as Dictionary)["resonance"] as Dictionary


## I gettoni caduti sul mazzetto di un Tema.
##
## Si guardano i **gettoni**, non il Calore: il gettone della Risonanza e'
## coperto (D-261) e puo' valere 0, 1 o 2 — un mazzetto che ha preso un gettone
## da zero e' scaldato lo stesso, e il tavolo lo vede cadere. Contare il Calore
## qui vorrebbe dire scrivere una prova che va rossa quando il sacchetto pesca
## uno zero.
func _tokens_on(theme_id: String) -> int:
	return int((session.world.get("theme_tokens", {}) as Dictionary).get(theme_id, 0))


## Gioca la carta chiedendo un Tema, e torna il Calore dei due Temi dopo.
func _play_asking(theme_id: String) -> Dictionary:
	var echo: Dictionary = _resonance()
	var params: Dictionary = {"asset_id": CARTA, "mode": "TENSION"}
	for tension_id in session.world["tensions"]:
		params["tension_id"] = str(tension_id)
		break
	if theme_id != "":
		params["resonance_theme"] = theme_id
	_give("ENT_ALDRIC", CARTA)
	var outcome: Dictionary = session.actions.execute("ENT_ALDRIC", {
		"template": "PLAY_CARD", "params": params,
	})
	assert_true(bool(outcome.get("ok", false)),
		"la carta si gioca: %s" % [str(outcome.get("error", ""))])
	return {
		"primo": _tokens_on(str(echo["theme"])),
		"secondo": _tokens_on(str(echo.get("or_theme", ""))),
	}


## **La carta stampa due Temi**, e sono due davvero.
func test_the_card_prints_two_themes() -> void:
	var echo: Dictionary = _resonance()
	assert_ne(str(echo.get("or_theme", "")), "", "la carta offre un secondo Tema")
	assert_ne(str(echo["theme"]), str(echo["or_theme"]), "e i due Temi sono diversi")


## **Chiedendo il secondo, si scalda il secondo.** E' la scelta, ed e' l'unica
## leva che chi gioca ha sull'agenda del tavolo.
func test_asking_for_the_other_theme_heats_the_other_theme() -> void:
	var echo: Dictionary = _resonance()
	var dopo: Dictionary = _play_asking(str(echo["or_theme"]))
	assert_true(int(dopo["secondo"]) > 0, "il gettone e' caduto sul secondo Tema")
	assert_eq(int(dopo["primo"]), 0, "e non sul primo")


## **Senza chiedere niente, scalda quello stampato per primo.** E' quello che
## fanno i salvataggi vecchi e ogni carta che di Temi ne offre uno solo.
func test_asking_nothing_heats_the_printed_theme() -> void:
	var dopo: Dictionary = _play_asking("")
	assert_true(int(dopo["primo"]) > 0, "il gettone e' caduto sul Tema stampato")
	assert_eq(int(dopo["secondo"]), 0, "e non sull'altro")


## **E un Tema che la carta non stampa non vale.** Chiedere «Fede» a una carta
## che offre Potere e Vie non scalda la Fede: la Risonanza e' quella stampata,
## non una terza cosa.
func test_a_theme_the_card_does_not_print_is_refused() -> void:
	var echo: Dictionary = _resonance()
	var estraneo: String = ""
	for theme_id in data().themes:
		if str(theme_id) != str(echo["theme"]) and str(theme_id) != str(echo.get("or_theme", "")):
			estraneo = str(theme_id)
			break
	assert_ne(estraneo, "", "esiste un Tema che questa carta non stampa")
	var dopo: Dictionary = _play_asking(estraneo)
	assert_eq(_tokens_on(estraneo), 0, "sul Tema estraneo non cade niente")
	assert_true(int(dopo["primo"]) > 0, "e il gettone cade su quello stampato per primo")


## **Ogni carta che stampa due Temi offre la scelta.** Una carta con due Temi e
## una Risonanza che ne scalda uno solo e' la leva vecchia, quella cieca: la
## guardia sta anche in `validate_physical.py`, e qui vale sui dati spediti.
func test_every_two_theme_card_offers_the_choice() -> void:
	var senza: Array = []
	for asset_id in data().assets:
		var card: Dictionary = data().assets[asset_id] as Dictionary
		var face: Dictionary = card.get("physical", {}) as Dictionary
		if face.is_empty():
			continue
		if (face.get("themes", []) as Array).size() < 2:
			continue
		var echo: Dictionary = face.get("resonance", {}) as Dictionary
		if str(echo.get("or_theme", "")) == "":
			senza.append(str(asset_id))
	assert_eq(senza.size(), 0, "carte con due Temi e nessuna scelta: %s" % str(senza))
