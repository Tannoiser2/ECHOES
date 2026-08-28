extends "res://tests/test_case.gd"
## §18.3: Destiny evaluated at all three levels.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")


func before_each() -> void:
	new_session()


func _apply(type: String, kind: String, id: String, payload: Dictionary) -> void:
	session.applier.apply(
		Effect.make(type, kind, id, payload, Effect.source("developer", "TEST", "", 3, 3, 0))
	)


## D-087: i conti rimasti aperti. Le clausole negate escono anche come dati -
## e' la meta' strutturata delle evidence, quella che il motore 0.3 legge per
## far nascere l'era dopo dai conti di quella prima.
func test_unmet_conditions_are_recorded_as_data() -> void:
	var result: Dictionary = session.destinies.evaluate("DST_VAERAX")
	var unmet: Array = result["unmet"]
	assert_true(unmet.size() > 0, "in partenza qualche clausola e' negata")
	for condition in unmet:
		assert_true((condition as Dictionary).has("type"), "ogni conto aperto e' la clausola, come dato")
	# La Vittoria di Vaerax chiede le gallerie sigillate: finche' non lo sono,
	# quel conto e' aperto. Appena lo sono, si chiude.
	var wants_seal: bool = false
	for condition in unmet:
		if str((condition as Dictionary).get("tag", "")) == "mine_sealed":
			wants_seal = true
	assert_true(wants_seal, "il sigillo mancante e' fra i conti aperti")
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})
	var after: Array = session.destinies.evaluate("DST_VAERAX")["unmet"]
	for condition in after:
		assert_false(
			str((condition as Dictionary).get("tag", "")) == "mine_sealed"
			and str((condition as Dictionary).get("type", "")) == "state_tag_present",
			"sigillate le gallerie, quel conto e' chiuso"
		)
	_apply("REMOVE_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})


## Vaerax walks the full ladder: Minimum, then Victory, then Triumph, and the
## level only rises while every lower level still holds.
func test_three_levels_for_vaerax() -> void:
	# Vaerax opens on Minimum, and that is the fix of D-051. He used to open on
	# *Victory*: his second rung was "the Crystal has not been exploited" and "the
	# Miniere have not been emptied", two clauses that are true before a token is
	# placed and that hold in 37 Chronicles out of 40. A watcher who has already
	# won by sitting down is a watcher with nothing to play, which is the same
	# defect D-048 found in the scholars' seat one milestone earlier.
	var result: Dictionary = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "MINIMUM", "in partenza ha solo il Minimo")
	assert_true(bool(result["levels"]["MINIMUM"]), "condizioni Minimum soddisfatte")
	assert_false(bool(result["levels"]["VICTORY"]), "le gallerie non sono ancora sigillate")

	# The seal is the Victory, and it is a thing he has to obtain in a Council.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "VICTORY", "sigillate le gallerie, e il Cristallo non e uscito")

	# And the stake still costs him it: exploiting the Crystal is the one thing
	# his Destiny is against, whatever else is true.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"})
	assert_eq(
		str(session.destinies.evaluate("DST_VAERAX")["level"]), "MINIMUM",
		"Cristallo sfruttato: resta solo il Minimum"
	)
	_apply("REMOVE_GLOBAL_TAG", "world", "WORLD", {"tag": "crystal_exploited"})

	# Il Trionfo non e' piu' una lista da soddisfare per intero: e' una spina —
	# le gallerie non svuotate — e **quattro strade su cinque** (D-167). Qui se
	# ne prendono tre, e non bastano.
	_apply("ADJUST_TENSION", "tension", "TEN_AWAKENING", {"delta": -1})
	_apply("ADJUST_TENSION", "tension", "TEN_ROADS", {"delta": 3})
	_apply("ADJUST_TENSION", "tension", "TEN_FAMINE", {"delta": 3})
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "VICTORY", "tre strade su quattro non sono un Trionfo")

	# La quarta e' una pietra, e questo e' il punto della seduta sulla terra: il
	# passo frana, il giro lungo lo fa chi vuole, e la montagna e' di nuovo
	# lontana. Un Trionfo deciso da una cosa che sta sulla mappa.
	_apply(
		"SET_STRUCTURE_GRADE",
		"region",
		"REG_MONTAGNE_ROSSE",
		{"structure_type": "STR_PASS", "grade": 2}
	)
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "TRIUMPH", "col passo franato la quarta strada c'e': Triumph")

	# Losing the mountain drops him to nothing at all, whatever else is true.
	# **Da D-327 il Minimo mira a segni**, non alla montagna per nome: per
	# spegnerlo bisogna toglierlo da **ogni** terra che porta quei segni, ed e'
	# proprio quello che la riga dice adesso.
	_leave_every_place_with(["wild", "domain:ANCIENT"], "ENT_VAERAX")
	result = session.destinies.evaluate("DST_VAERAX")
	assert_eq(str(result["level"]), "NONE", "senza Minimum non c'e livello, anche col Triumph vero")
	assert_true(bool(result["levels"]["TRIUMPH"]), "le condizioni di Triumph restano vere")
	assert_false(bool(result["levels"]["MINIMUM"]), "ma il Minimum e caduto")


## Togliere la casa da **ogni** terra che porta uno di quei segni (D-327).
## Con le clausole mirate a segni, sgomberare un posto solo non spegne niente:
## la riga guarda tutte le tessere col segno stampato.
func _leave_every_place_with(signs: Array, entity_id: String) -> void:
	for region_id in session.world["regions"]:
		var here: String = str(region_id)
		var carries: bool = false
		for sign in signs:
			if session.service.region_has_tag(here, str(sign)):
				carries = true
				break
		if not carries:
			continue
		while session.service.presence_count(entity_id, here) > 0:
			_apply("REMOVE_PRESENCE", "entity", entity_id, {"region_id": here})


func test_victory_needs_the_consequence_that_grants_it() -> void:
	var result: Dictionary = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "MINIMUM", "i Nahr partono da Minimum")
	assert_false(bool(result["levels"]["VICTORY"]), "l'insediamento non e ancora riconosciuto")

	# nahr_settled is written by CNS_NAHR_SETTLEMENT, and the Nahr already hold
	# the Valley: that is the Victory. The Triumph now also asks that the crown
	# be divided (O-12) - a people can only stop somewhere while the throne is
	# busy with itself - so settling alone no longer reaches it.
	# Tre segni sul mondo chiudono le due strade che parlano di un anno calmo:
	# senza, la scelta del Trionfo sarebbe gia' soddisfatta all'apertura, e un
	# gradino vero non si regala prima che qualcuno giochi (D-167).
	for i in range(3):
		_apply(
			"ADD_SCAR",
			"world",
			"WORLD",
			{
				"scar_id": "SCR_TEST_NAHR_%d" % i,
				"region_id": "REG_VALLE_VERDE",
				"tag": "scar:burned",
				"description": "il segno numero %d della prova" % i,
			}
		)
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "nahr_settled"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "VICTORY", "insediamento riconosciuto: Victory")
	assert_false(bool(result["levels"]["TRIUMPH"]), "ma la corona e ancora una sola")

	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "crown_divided"})
	# E la Successione ancora aperta: finche' si discute chi siede, nessuno ha il
	# tempo di mandare via un popolo. E' la stessa cosa che dice `crown_divided`,
	# detta con un numero - e detta cosi' tira contro Aldric, che la vuole sotto
	# 4, invece che contro nessuno (D-066).
	_apply("ADJUST_TENSION", "tension", "TEN_SUCCESSION", {"delta": 3})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "TRIUMPH", "corona spezzata e Valle aperta: Triumph")

	# Sealing the Valley denies the Triumph without touching the Victory.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "valley_sealed"})
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(str(result["level"]), "VICTORY", "la Valle chiusa blocca il Triumph")
	assert_false(bool(result["levels"]["TRIUMPH"]), "condizione di Triumph fallita")

	# And losing the granary presence takes the Victory away as well. Da D-327
	# la riga guarda **il segno**, non la Valle per nome: si sgombera ogni terra
	# che lo porta.
	_leave_every_place_with(["granary", "domain:SURVIVAL"], "ENT_NAHR")
	result = session.destinies.evaluate("DST_NAHR")
	assert_eq(
		str(result["level"]), "NONE",
		"sgomberate tutte le terre del #granaio cade anche il Minimo, che guarda il #pascolo"
	)


## Discoveries are counted from the 'discovery:' tags an Entity has earned - and
## what they are worth (D-048).
##
## This test used to end at "one Discovery and presence in the Mines: Victory",
## and it passed, and that was the bug. A Discovery costs **one action** - SCHEME
## on a veiled Tension - and the Mines are where Lyra is standing when the
## Chronicle is dealt. So the scholars' Victory was two SCHEMEs, and a probe over
## forty Chronicles found her whole ladder - Minimum, Victory *and* Triumph -
## closed by **Act I round two, forty times out of forty**. She then spent the
## remaining seventeen Action Opportunities drawing cards she had no use for.
##
## Knowing something is the Minimum now. The Victory is the other half of the
## title - *poter tornare a guardare* - and it has to be obtained from a Council.
func test_discovery_count_drives_lyra() -> void:
	var result: Dictionary = session.destinies.evaluate("DST_LYRA")
	assert_eq(str(result["level"]), "NONE", "senza Scoperte Lyra non raggiunge nemmeno il Minimum")

	session.actions.execute(
		"ENT_LYRA", {"template": "SCHEME", "params": {"mode": "TENSION", "tension_id": "TEN_AWAKENING"}}
	)
	result = session.destinies.evaluate("DST_LYRA")
	assert_eq(
		str(result["level"]), "MINIMUM",
		"sapere qualcosa e il Minimo: una SCHEME non e una Vittoria"
	)

	# Two Discoveries are still two actions, and still do not buy the rung above.
	_apply("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "discovery:crystal"})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "MINIMUM",
		"e nemmeno due"
	)

	# La Vittoria non e' piu' una porta sola (D-169). Le Miniere non sigillate
	# valgono gia' una strada all'apertura; la scorta e' la seconda, e **due su
	# tre** aprono il gradino. Prima di D-169 questa riga saliva dritta al
	# Trionfo, e quello era il difetto: sotto la porta non c'era altro da pagare.
	_apply("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "escort_sworn"})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "VICTORY",
		"con la scorta giurata la Vittoria si apre, e si ferma li'"
	)

	# E il Trionfo adesso chiede **quattro** Scoperte, non due: la spina di prima
	# era vera nel 100% degli anni misurati, cioe' non era una spina (D-168).
	for name in ["depth", "old_road", "water"]:
		_apply("SET_ENTITY_TAG", "entity", "ENT_LYRA", {"tag": "discovery:%s" % name})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "TRIUMPH",
		"quattro Scoperte e le strade ancora aperte: la scala arriva in fondo"
	)

	# E il gradino sopra e' una scelta, non una lista: tre strade su cinque
	# (D-167, D-169). All'apertura ne ha quattro, e **le cicatrici ne chiudono
	# due**.
	_apply(
		"ADD_SCAR",
		"world",
		"WORLD",
		{
			"scar_id": "SCR_TEST_ROAD",
			"region_id": "REG_STRADA_MERCANTI",
			"tag": "scar:broken_bridge",
			"description": "il ponte rotto della prova",
		}
	)
	_apply(
		"ADD_SCAR",
		"world",
		"WORLD",
		{
			"scar_id": "SCR_TEST_MINE",
			"region_id": "REG_MINIERE_ANTICHE",
			"tag": "scar:open_wound",
			"description": "la galleria aperta della prova",
		}
	)
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "VICTORY",
		"due segni sulla strada e sulle gallerie chiudono due strade"
	)

	# E una pietra ne rimette una: lo studio con un tetto suo vale quanto una
	# strada pulita. E' il punto della seduta sulla terra — un livello che si
	# decide con qualcosa che sta sulla mappa.
	_apply(
		"BUILD_STRUCTURE",
		"region",
		"REG_MINIERE_ANTICHE",
		{"structure_type": "STR_KEEP", "grade": 1, "owner": "ENT_LYRA"}
	)
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "TRIUMPH",
		"con un tetto sullo studio la terza strada torna"
	)

	# And the Triumph on top of it is a stake, not a purchase: put a guard on the
	# study and it goes, without anything she did being undone.
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "study_supervised"})
	assert_eq(
		str(session.destinies.evaluate("DST_LYRA")["level"]), "VICTORY",
		"una guardia allo studio costa il Trionfo e lascia la Vittoria"
	)


## Voce 20 (D-115): il Destino condivisibile scrive "$self" al posto della casa,
## e le clausole si risolvono su chi lo giura. La stessa carta, giurata da due
## seggi diversi, legge due mondi diversi.
func test_shared_destiny_resolves_on_the_holder() -> void:
	# Da D-170 il Minimo di questa carta e' una Regione, non la fama: chiedere la
	# fama per esistere lasciava a NONE un terzo dei seggi che la giuravano, e un
	# Minimo e' una soglia di sopravvivenza. La fama e' salita alla Vittoria.
	var result: Dictionary = session.destinies.evaluate("DST_SHARED_RENOWN", "ENT_ALDRIC")
	assert_eq(str(result["entity_id"]), "ENT_ALDRIC", "la carta appartiene a chi la giura")
	assert_true(bool(result["levels"]["MINIMUM"]), "una Regione: il Minimo tiene")
	assert_false(bool(result["levels"]["VICTORY"]), "ma senza fama la Vittoria no")

	_apply("SET_ENTITY_TAG", "entity", "ENT_ALDRIC", {"tag": "renowned"})
	result = session.destinies.evaluate("DST_SHARED_RENOWN", "ENT_ALDRIC")
	assert_true(bool(result["levels"]["VICTORY"]), "la fama di Aldric apre la sua Vittoria")
	# La stessa carta in mano ai Nahr non legge Aldric: legge i Nahr.
	var other: Dictionary = session.destinies.evaluate("DST_SHARED_RENOWN", "ENT_NAHR")
	assert_eq(str(other["entity_id"]), "ENT_NAHR", "il risultato porta il nome del giurante")
	assert_false(bool(other["levels"]["VICTORY"]), "la fama di Aldric non e' fama dei Nahr")
	_apply("REMOVE_ENTITY_TAG", "entity", "ENT_ALDRIC", {"tag": "renowned"})


## E quando la rotazione del pool (D-045/D-081) posa una carta condivisa su un
## seggio, evaluate_all la valuta sul seggio che la porta - non su nessuno.
func test_evaluate_all_reads_shared_destiny_on_the_seat() -> void:
	session.world["entities"]["ENT_ALDRIC"]["destiny_id"] = "DST_SHARED_LAND"
	var results: Dictionary = session.destinies.evaluate_all()
	var result: Dictionary = results["ENT_ALDRIC"]
	assert_eq(str(result["destiny_id"]), "DST_SHARED_LAND", "il seggio giura la carta del pool")
	assert_eq(str(result["entity_id"]), "ENT_ALDRIC", "e la carta si risolve sul seggio")
	# Aldric apre la Chronicle con una Regione controllata: il Minimo della
	# Terra che Risponde e' suo dalla prima mano, i gradini sopra no.
	assert_true(bool(result["levels"]["MINIMUM"]), "una Regione controllata: il Minimo tiene")
	assert_false(bool(result["levels"]["TRIUMPH"]), "tre Regioni non le ha nessuno in apertura")


## Every seated Entity gets its own result; there is no shared score (§14).
func test_evaluate_all_covers_every_seat() -> void:
	var results: Dictionary = session.destinies.evaluate_all()
	assert_eq(results.size(), 4, "un risultato per ogni Entita al tavolo")
	for entity_id in session.world["turn_order"]:
		assert_true(results.has(str(entity_id)), "risultato presente per %s" % entity_id)
		assert_true(
			["NONE", "MINIMUM", "VICTORY", "TRIUMPH"].has(str(results[entity_id]["level"])),
			"livello valido per %s" % entity_id
		)


## §14: the result keeps *how* it was reached, for the Legacy propagation.
func test_evidence_records_conditions_and_echoes() -> void:
	_apply("SET_GLOBAL_TAG", "world", "WORLD", {"tag": "mine_sealed"})
	_apply(
		"CREATE_ECHO",
		"echo",
		"ECHO_0001",
		{
			"echo_id": "ECHO_0001",
			"title": "Prova",
			"summary": "Le Miniere furono sigillate.",
			"act": 3,
			"round": 3,
			"participants": ["ENT_VAERAX"],
			"effect_ids": [],
		}
	)
	var result: Dictionary = session.destinies.evaluate("DST_VAERAX")
	var evidence: String = "\n".join(PackedStringArray(result["evidence"]))
	assert_true(evidence.contains("MINIMUM"), "le condizioni di ogni livello sono elencate")
	assert_true(evidence.contains("TRIUMPH"), "compreso il Triumph")
	assert_true(evidence.contains("ECHO_0001"), "gli Echo a cui ha partecipato sono allegati")
	assert_true(evidence.contains("[x]"), "le condizioni soddisfatte sono marcate")
