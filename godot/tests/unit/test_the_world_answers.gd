extends "res://tests/test_case.gd"
## Il mondo risponde ([D-257](DECISIONS.md#d-257)).
##
## E' la regola che il committente ha messo al centro della direzione fisica:
## *«La Risonanza non e' opzionale. E' la reazione del mondo all'Azione scelta.»*
## Fino alla 0.1.218 stava scritta sulle carte e non succedeva: dodici carte
## avevano una Risonanza e il motore non ne apriva una.
##
## Una regola che avviene **sempre** e' anche la piu' facile da perdere senza
## accorgersene: sparisce e la partita gira lo stesso, un po' piu' fredda. Queste
## sono le sue guardie.

const Effect := preload("res://scripts/core/effect.gd")

## Una carta con la faccia fisica, e il Tema che scalda.
const CARTA: String = "AST_AUTHORITY_CENSUS"
const TEMA: String = "THM_POTERE"


func before_each() -> void:
	new_session()


func _tensions_of_theme() -> Array:
	var out: Array = []
	for tension_id in session.world["tensions"]:
		var definition: Dictionary = data().tensions[str(tension_id)]
		if str(definition.get("theme", "")) == TEMA:
			out.append(str(tension_id))
	out.sort()
	return out


func _give(entity_id: String, asset_id: String) -> void:
	session.applier.apply(Effect.make(
		"GRANT_ASSET", "entity", entity_id, {"asset_id": asset_id},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


func _set_tension(tension_id: String, value: int) -> void:
	var now: int = session.tensions.value(tension_id)
	session.applier.apply(Effect.make(
		"ADJUST_TENSION", "tension", tension_id, {"delta": value - now},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))


## **Giocare la carta scalda il Tema scritto sulla carta.**
func test_playing_a_faced_card_heats_its_theme() -> void:
	var theme_tensions: Array = _tensions_of_theme()
	assert_true(theme_tensions.size() > 0, "il Tema ha almeno una questione in gioco")
	for tension_id in theme_tensions:
		_set_tension(str(tension_id), 1)
	var before: int = 0
	for tension_id in theme_tensions:
		before += session.tensions.value(str(tension_id))

	_give("ENT_ALDRIC", CARTA)
	var outcome: Dictionary = session.actions.execute("ENT_ALDRIC", {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARTA, "mode": "TENSION", "tension_id": str(theme_tensions[0])},
	})
	assert_true(bool(outcome.get("ok", false)), "la carta si gioca: %s" % [str(outcome.get("error", ""))])

	var after: int = 0
	for tension_id in theme_tensions:
		after += session.tensions.value(str(tension_id))
	assert_true(after > before, "il Tema si e' scaldato (%d -> %d)" % [before, after])


## **La Risonanza si firma.** Senza, il verbale non distingue quello che il
## giocatore ha scelto da quello che il mondo ha risposto — e una sonda l'ha
## gia' contata zero volte mentre avveniva.
func test_the_answer_says_who_it_was() -> void:
	var theme_tensions: Array = _tensions_of_theme()
	for tension_id in theme_tensions:
		_set_tension(str(tension_id), 1)
	_give("ENT_ALDRIC", CARTA)
	session.actions.execute("ENT_ALDRIC", {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARTA, "mode": "TENSION", "tension_id": str(theme_tensions[0])},
	})
	var signed: int = 0
	for entry in (session.world["effect_log"] as Array):
		var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
		var source: Dictionary = effect.get("source", {}) as Dictionary
		if str(source.get("kind", "")) == "resonance":
			signed += 1
			assert_eq(str(source.get("id", "")), CARTA, "la firma porta la carta")
	assert_true(signed > 0, "il verbale contiene almeno una Risonanza firmata")


## **La Risonanza avvicina, non decide.** Una questione a un passo dalla soglia
## non riceve da lei il punto che la apre: il Consiglio lo convoca qualcuno.
func test_the_answer_never_opens_a_council_by_itself() -> void:
	var theme_tensions: Array = _tensions_of_theme()
	for tension_id in theme_tensions:
		var threshold: int = int((data().tensions[str(tension_id)] as Dictionary)["threshold"])
		_set_tension(str(tension_id), threshold - 1)
	var before: Array = []
	for tension_id in theme_tensions:
		before.append(session.tensions.value(str(tension_id)))

	_give("ENT_ALDRIC", CARTA)
	session.actions.execute("ENT_ALDRIC", {
		"template": "PLAY_CARD",
		"params": {"asset_id": CARTA, "mode": "TENSION", "tension_id": str(theme_tensions[0])},
	})
	for index in range(theme_tensions.size()):
		var tension_id: String = str(theme_tensions[index])
		var threshold: int = int((data().tensions[tension_id] as Dictionary)["threshold"])
		assert_true(
			session.tensions.value(tension_id) < threshold,
			"«%s» non e' stata portata alla soglia dalla Risonanza" % tension_id
		)


## **Una carta senza faccia non fa rispondere niente.**
##
## Da 0.1.220 tutte e quarantotto le carte hanno una faccia, quindi questa prova
## se ne costruisce una **senza**: prende una carta della scatola e le toglie il
## blocco `physical` in una DataSet tutta sua. Nella prima stesura cercava una
## carta spoglia fra quelle spedite e, finita la conversione, non ne trovava piu'
## nessuna — una prova che smette di provare senza dirlo. Adesso la condizione
## se la fabbrica, e vale anche il giorno che la scatola cambia.
##
## Serve perche' una reazione inventata dal codice sarebbe esattamente la regola
## invisibile che questa direzione vuole togliere: se la carta non la dichiara,
## il mondo sta zitto.
func test_a_card_without_a_face_answers_nothing() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	var plain: String = ""
	for asset_id in loaded.assets:
		var card: Dictionary = loaded.assets[str(asset_id)]
		if str((card.get("card_action", {}) as Dictionary).get("kind", "")) == "SCHEME":
			plain = str(asset_id)
			(loaded.assets[plain] as Dictionary).erase("physical")
			break
	assert_ne(plain, "", "una carta da spogliare si trova")
	assert_false(
		(loaded.assets[plain] as Dictionary).has("physical"),
		"e adesso non ha una faccia"
	)

	var stripped: RefCounted = GameSession.new(loaded)
	var seats: Array = GameSession.seats_for(loaded, "CHR_00", 4242)
	assert_true(stripped.setup("CHR_00", seats, 4242), "l'anno si apre")
	for effect in stripped.factory_setup_effects():
		stripped.applier.apply(effect)
	# **Un seggio vero di questa partita.** La prima stesura nominava Aldric, che
	# in un roster pescato col seme puo' non esserci: l'Effetto falliva, la carta
	# non si giocava, e le asserzioni passavano su un mondo dove non era successo
	# niente. Una prova che passa perche' non ha provato niente e' peggio di una
	# rossa.
	var who: String = ""
	for entity_id in (stripped.world["entities"] as Dictionary).keys():
		if bool(((stripped.world["entities"] as Dictionary)[str(entity_id)] as Dictionary)["active"]):
			who = str(entity_id)
			break
	assert_ne(who, "", "al tavolo c'e' qualcuno")
	stripped.applier.apply(Effect.make(
		"GRANT_ASSET", "entity", who, {"asset_id": plain},
		Effect.source("system", "TEST", "", 1, 1, 0)
	))
	var tension_id: String = ""
	for candidate in (stripped.world["tensions"] as Dictionary).keys():
		tension_id = str(candidate)
		break
	var outcome: Dictionary = stripped.actions.execute(who, {
		"template": "PLAY_CARD",
		"params": {"asset_id": plain, "mode": "TENSION", "tension_id": tension_id},
	})
	assert_true(
		bool(outcome.get("ok", false)),
		"la carta spoglia si gioca davvero: %s" % [str(outcome.get("error", ""))]
	)
	for entry in (stripped.world["effect_log"] as Array):
		var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
		assert_ne(
			str((effect.get("source", {}) as Dictionary).get("kind", "")), "resonance",
			"«%s» non ha una faccia, e non risponde" % plain
		)
	stripped.dispose()


## E la controprova: **tutte le carte spedite ce l'hanno.** La conversione e'
## finita, e se qualcuno ne aggiunge una spoglia questa riga lo dice.
func test_every_shipped_card_has_a_face() -> void:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	for asset_id in loaded.assets:
		assert_true(
			(loaded.assets[str(asset_id)] as Dictionary).has("physical"),
			"«%s» ha una faccia fisica" % [str(asset_id)]
		)
