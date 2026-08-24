extends "res://tests/test_case.gd"
## Il tavolo si legge senza l'app ([D-256](DECISIONS.md#d-256)).
##
## La direzione nuova dice una cosa sola, e la dice in dieci modi: **ECHOES e' un
## gioco da tavolo con un'app di supporto, non un gioco digitale con dei
## segnalini.** Quello che un giocatore ha davanti — la carta, il gettone, la
## Domanda, la scheda del Destino — deve bastare a giocare.
##
## Questa prova non misura niente: i conti stanno in `tools/validate_physical.py`.
## Tiene la riga che divide le due grammatiche, e va rossa il giorno che una
## faccia fisica smette di essere leggibile al tavolo:
##
## - una carta che nomina una Regione invece di un segno e' muta in ogni altra
##   Cronaca, e al tavolo e' una carta che non si puo' giocare;
## - una carta senza Risonanza e' un pulsante: fa la cosa e il mondo non risponde;
## - una carta con una sola Azione e' un evento che accade, non uno strumento;
## - una Domanda senza segni richiesti si apre sempre, e allora non e' una
##   domanda: e' un passaggio obbligato con tre finali.

const VERBI: Array = ["MOVE", "INFLUENCE", "SCHEME", "FORGE", "CLAIM"]


func before_each() -> void:
	new_session()


## Una DataSet tutta sua: quella condivisa la riscrivono altre prove, e questa
## legge i **dati della scatola**.
func _shipped() -> RefCounted:
	var loaded: RefCounted = DataSet.new()
	assert_true(loaded.load_from("res://data"), "i dati della scatola si leggono")
	return loaded


func _faces(loaded: RefCounted) -> Array:
	var out: Array = []
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[str(asset_id)]
		if asset.has("physical"):
			out.append([str(asset_id), asset["physical"] as Dictionary])
	return out


## Il pilota e' un pilota: almeno due carte per famiglia, o non prova niente.
func test_the_pilot_covers_every_family() -> void:
	var loaded: RefCounted = _shipped()
	var per_family: Dictionary = {}
	for pair in _faces(loaded):
		var family: String = str((loaded.assets[str((pair as Array)[0])] as Dictionary)["family"])
		per_family[family] = int(per_family.get(family, 0)) + 1
	for family in ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]:
		assert_true(
			int(per_family.get(str(family), 0)) >= 2,
			"%s ha almeno due carte convertite (ne ha %d)" % [family, int(per_family.get(str(family), 0))]
		)


## **Nessuna carta nomina un posto.** E' la regola che rende una carta
## ristampabile: il bersaglio si dice a segni, e i segni ci sono in ogni Cronaca.
func test_no_card_names_a_place_or_a_house() -> void:
	var loaded: RefCounted = _shipped()
	for pair in _faces(loaded):
		var card: Dictionary = (pair as Array)[1]
		var target: Dictionary = card["target"] as Dictionary
		var lines: Array = [str(target["text"])]
		for action in card["actions"]:
			lines.append(str((action as Dictionary)["text"]))
		lines.append(str((card["resonance"] as Dictionary)["text"]))
		for line in lines:
			for prefix in ["REG_", "ENT_", "TEN_", "CNS_", "AST_"]:
				assert_false(
					str(line).contains(str(prefix)),
					"%s non nomina un id (%s)" % [str((pair as Array)[0]), str(prefix)]
				)


## **La Risonanza c'e' sempre, e scalda un Tema che esiste.**
func test_every_face_answers_with_the_world() -> void:
	var loaded: RefCounted = _shipped()
	for pair in _faces(loaded):
		var card: Dictionary = (pair as Array)[1]
		var resonance: Dictionary = card["resonance"] as Dictionary
		assert_true(
			loaded.themes.has(str(resonance["theme"])),
			"%s scalda un Tema che esiste" % [str((pair as Array)[0])]
		)
		assert_true(int(resonance["heat"]) >= 1, "%s scalda di almeno 1" % [str((pair as Array)[0])])
		assert_false(str(resonance["text"]).is_empty(), "%s dice cosa succede" % [str((pair as Array)[0])])


## **Due Azioni, e sono due scelte diverse.** Una carta le cui due Azioni dicono
## la stessa cosa e' una carta con una sola Azione scritta due volte.
func test_every_face_offers_a_real_choice() -> void:
	var loaded: RefCounted = _shipped()
	for pair in _faces(loaded):
		var card: Dictionary = (pair as Array)[1]
		var actions: Array = card["actions"] as Array
		assert_eq(actions.size(), 2, "%s offre due Azioni" % [str((pair as Array)[0])])
		var first: Dictionary = actions[0] as Dictionary
		var second: Dictionary = actions[1] as Dictionary
		assert_ne(
			str(first["label"]), str(second["label"]),
			"%s: le due Azioni non si chiamano uguale" % [str((pair as Array)[0])]
		)
		assert_ne(
			str(first["text"]), str(second["text"]),
			"%s: le due Azioni non fanno la stessa cosa" % [str((pair as Array)[0])]
		)


## **Ogni Tema ha un mazzo, e ogni Domanda chiede qualcosa al tavolo.**
func test_every_theme_has_questions_that_ask_something() -> void:
	var loaded: RefCounted = _shipped()
	var per_theme: Dictionary = {}
	for question_id in loaded.question_cards:
		var question: Dictionary = loaded.question_cards[str(question_id)]
		per_theme[str(question["theme"])] = int(per_theme.get(str(question["theme"]), 0)) + 1
		assert_true(
			(question["requires_any_tag"] as Array).size() > 0,
			"%s chiede almeno un segno al tavolo" % [str(question_id)]
		)
		assert_true(
			(question["outcomes"] as Array).size() >= 2,
			"%s ha almeno due esiti" % [str(question_id)]
		)
	for theme_id in loaded.themes:
		assert_true(
			int(per_theme.get(str(theme_id), 0)) > 0,
			"il Tema %s ha un mazzo: il Calore che sale deve aprire qualcosa" % [str(theme_id)]
		)


## **Ogni Tensione appartiene a un Tema.** Senza, il suo Calore non finisce su
## nessuna traccia, e a fine Atto il tavolo non sa cosa si apre.
func test_every_tension_belongs_to_a_theme() -> void:
	var loaded: RefCounted = _shipped()
	for tension_id in loaded.tensions:
		var tension: Dictionary = loaded.tensions[str(tension_id)]
		assert_true(
			loaded.themes.has(str(tension.get("theme", ""))),
			"%s sta su una traccia che esiste" % [str(tension_id)]
		)


## **Il Destino dice dove guardare.** Tre righe, e i segni che osserva.
func test_a_destiny_says_what_to_look_at() -> void:
	var loaded: RefCounted = _shipped()
	var faced: int = 0
	for destiny_id in loaded.destinies:
		var destiny: Dictionary = loaded.destinies[str(destiny_id)]
		if not destiny.has("physical"):
			continue
		faced += 1
		var face: Dictionary = destiny["physical"] as Dictionary
		assert_true((face["observes"] as Array).size() > 0, "%s guarda qualcosa" % [str(destiny_id)])
		for level in ["minimum", "victory", "triumph"]:
			assert_false(
				str((face["reads"] as Dictionary)[level]).is_empty(),
				"%s dice cosa serve per %s" % [str(destiny_id), level]
			)
	assert_true(faced >= 8, "almeno otto Destini hanno una faccia leggibile (ne hanno %d)" % faced)
