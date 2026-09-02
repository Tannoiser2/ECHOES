extends "res://tests/test_case.gd"
## **SEGNARE, il settimo verbo** (ISSUES 128, D-423).
##
## Il numero che ha aperto la voce: **sette facce su 96 avevano il nome
## stampato, il testo scritto, i segni che posano — e nessun verbo.** La seconda
## Azione di Assedio, Leva Contadina, Le Porte Bruciate, Atto di Successione,
## Banda Armata, Censimento e Consiglio degli Anziani non si poteva giocare mai,
## contro la regola di casa: *«due Azioni, e due scelte diverse davvero»*.
##
## Erano tutte la stessa forma, ed e' la ragione per cui il verbo mancava: **la
## loro Azione e' il segno che lasciano**. Nessuno dei sei lo diceva — MUOVERE
## sposta, TRAMARE pretende un'informazione coperta, RIVENDICARE apre una
## Domanda. Parola del committente: *«Segnare»*.
##
## Qui si prova la cosa e i suoi due no. **Il no conta quanto il si'**: SEGNARE
## non ha un effetto suo — il suo effetto *sono* i segni stampati — quindi una
## faccia senza segni sarebbe un'azione legale che non fa niente e non avvisa,
## ed e' il difetto peggiore che si possa scrivere.

const SEAT: String = "ENT_ALDRIC"


func before_each() -> void:
	new_session()


## Una faccia SEGNARE fra i dati spediti, con la sua carta.
##
## **Cercata, ma con la rete sotto**: se un giorno non ce ne fosse nessuna la
## prova lo dice invece di passare in silenzio — e sarebbe una notizia, perche'
## vorrebbe dire che il settimo verbo non e' stampato da nessuna parte.
func _a_marking_face() -> Dictionary:
	for asset_id in session.data.assets:
		var printed: Array = (
			((session.data.assets[asset_id] as Dictionary).get("physical", {}) as Dictionary)
				.get("actions", []) as Array
		)
		for index in range(printed.size()):
			if str((printed[index] as Dictionary).get("template", "")) == "MARK":
				return {"asset_id": str(asset_id), "face": index, "voice": printed[index]}
	return {}


## Il luogo dove quella carta arriva. **Fabbricato, non sperato**: se nessuna
## tessera pescata porta i segni del bersaglio, glieli si posa — questa prova
## misura **il verbo**, non quale mappa e' uscita dal seme.
func _a_place_it_reaches(asset_id: String) -> String:
	for region_id in session.world["regions"]:
		if session.actions.card_reaches(asset_id, str(region_id)):
			return str(region_id)
	var target: Dictionary = (
		((session.data.assets[asset_id] as Dictionary)["physical"] as Dictionary)
			.get("target", {}) as Dictionary
	)
	var wanted: Array = target.get("any_tag", []) as Array
	if wanted.is_empty():
		return ""
	var where: String = str(session.world["regions"].keys()[0])
	(session.world["regions"][where]["tags"] as Array).append(str(wanted[0]))
	return where if session.actions.card_reaches(asset_id, where) else ""


func _hold(asset_id: String) -> void:
	var hand: Array = session.world["entities"][SEAT]["hand"] as Array
	if not hand.has(asset_id):
		hand.append(asset_id)


## **Il segno si posa, e la carta si spende.**
func test_the_seventh_verb_leaves_its_mark() -> void:
	var face: Dictionary = _a_marking_face()
	assert_false(face.is_empty(), "nella scatola c'e' una faccia SEGNARE")
	var asset_id: String = str(face["asset_id"])
	_hold(asset_id)
	var where: String = _a_place_it_reaches(asset_id)
	assert_ne(where, "", "e un luogo dove quella carta arriva")

	var puts: Array = (face["voice"] as Dictionary).get("puts_tag", []) as Array
	var clears: Array = (face["voice"] as Dictionary).get("clears_tag", []) as Array
	assert_true(puts.size() + clears.size() > 0, "quella faccia porta almeno un segno")
	# Un segno che si toglie va prima posato, o «togli» non avrebbe niente da
	# fare e la prova misurerebbe un no-op credendolo un si'.
	for tag in clears:
		var alive: Array = session.world["regions"][where]["tags"] as Array
		if not alive.has(str(tag)):
			alive.append(str(tag))

	var hand_before: int = session.service.hand_size(SEAT)
	var outcome: Dictionary = session.actions.execute(SEAT, {
		"template": "PLAY_CARD",
		"params": {"asset_id": asset_id, "face_action": int(face["face"]), "region_id": where},
	})
	assert_true(bool(outcome["ok"]), "la mossa passa: %s" % str(outcome.get("error", "")))

	var alive: Array = session.world["regions"][where]["tags"] as Array
	for tag in puts:
		assert_true(alive.has(str(tag)), "il segno «%s» e' sul luogo" % str(tag))
	for tag in clears:
		assert_false(alive.has(str(tag)), "e il segno «%s» non c'e' piu'" % str(tag))
	assert_eq(
		session.service.hand_size(SEAT), hand_before - 1,
		"e la carta si spende, come ogni Azione calata"
	)


## **Dove la carta non arriva, non si segna.** E' la meta' della regola che
## rende SEGNARE un'Azione invece di un timbro: il bersaglio a segni della
## faccia (D-274) vale per il settimo verbo come per MUOVERE.
func test_it_cannot_mark_where_the_card_does_not_reach() -> void:
	var face: Dictionary = _a_marking_face()
	assert_false(face.is_empty(), "nella scatola c'e' una faccia SEGNARE")
	var asset_id: String = str(face["asset_id"])
	_hold(asset_id)

	var unreachable: String = ""
	for region_id in session.world["regions"]:
		if not session.actions.card_reaches(asset_id, str(region_id)):
			unreachable = str(region_id)
			break
	if unreachable == "":
		# La carta arriva ovunque: si fabbrica il no togliendo i segni a una
		# tessera, invece di dichiarare la prova inapplicabile.
		unreachable = str(session.world["regions"].keys()[0])
		(session.world["regions"][unreachable]["tags"] as Array).clear()
	if session.actions.card_reaches(asset_id, unreachable):
		return  # bersaglio aperto: non c'e' un «non arriva» da provare

	var refusal: String = session.actions.check(SEAT, "PLAY_CARD", {
		"asset_id": asset_id, "face_action": int(face["face"]), "region_id": unreachable,
	})
	assert_ne(refusal, "", "il luogo che la carta non raggiunge si rifiuta")


## **E un SEGNARE che non segna si rifiuta.** Il motore lo dice a voce alta,
## invece di eseguire un'azione che non lascia niente: e' lo stesso no che
## D-412 ha dato ad ACQUISIRE, ed e' il difetto da cui questo verbo nasce.
func test_a_marking_face_with_no_marks_is_refused() -> void:
	var face: Dictionary = _a_marking_face()
	assert_false(face.is_empty(), "nella scatola c'e' una faccia SEGNARE")
	var asset_id: String = str(face["asset_id"])
	_hold(asset_id)
	var where: String = _a_place_it_reaches(asset_id)
	assert_ne(where, "", "e un luogo dove quella carta arriva")

	# I segni si tolgono **alla faccia**, non al mondo: cosi' si misura il no
	# del verbo e non quello del bersaglio.
	var voice: Dictionary = face["voice"] as Dictionary
	var puts: Array = (voice.get("puts_tag", []) as Array).duplicate()
	var clears: Array = (voice.get("clears_tag", []) as Array).duplicate()
	voice["puts_tag"] = []
	voice["clears_tag"] = []

	var refusal: String = session.actions.check(SEAT, "PLAY_CARD", {
		"asset_id": asset_id, "face_action": int(face["face"]), "region_id": where,
	})
	voice["puts_tag"] = puts
	voice["clears_tag"] = clears

	assert_ne(refusal, "", "una faccia SEGNARE senza segni si rifiuta")
	assert_true(
		refusal.contains("segno"),
		"e il rifiuto dice perche': «%s»" % refusal
	)


## **E nessuna faccia stampata resta senza verbo.** E' il difetto originale, e
## adesso lo tengono in tre: lo schema che pretende `template`, il validatore
## fisico, e questa riga — che guarda i dati veri della scatola.
func test_every_printed_face_carries_a_verb() -> void:
	var mute: Array = []
	var counted: int = 0
	var marking: int = 0
	for asset_id in shipped_data().assets:
		var printed: Array = (
			((shipped_data().assets[asset_id] as Dictionary).get("physical", {}) as Dictionary)
				.get("actions", []) as Array
		)
		for face in printed:
			counted += 1
			var verb: String = str((face as Dictionary).get("template", ""))
			if verb == "":
				mute.append("%s: «%s»" % [str(asset_id), str((face as Dictionary)["label"])])
			elif verb == "MARK":
				marking += 1
	# Uno zero qui sarebbe la prova cieca: se non si e' guardata nessuna faccia,
	# non si e' misurato niente.
	assert_true(counted > 90, "si sono guardate le facce della scatola: %d" % counted)
	assert_true(
		mute.is_empty(),
		"nessuna faccia stampata resta senza verbo: %s" % ", ".join(PackedStringArray(mute))
	)
	assert_eq(marking, 7, "e sette portano SEGNARE, quelle che erano mute")


## **Il settimo verbo esiste anche nella scatola**, non solo nel motore: la
## plancia ne elenca sette, e una regola che il tabellone non nomina e' una
## regola che al tavolo nessuno trova.
func test_the_board_lists_seven_verbs() -> void:
	assert_eq(shipped_data().actions.size(), 7, "i verbi della plancia sono sette")
	assert_true(shipped_data().actions.has("MARK"), "e uno e' SEGNARE")
	var mark: Dictionary = shipped_data().actions["MARK"] as Dictionary
	assert_eq(str(mark["title"]), "Segnare", "col nome che il committente ha detto")
