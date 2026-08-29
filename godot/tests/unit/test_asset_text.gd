extends "res://tests/test_case.gd"
## What a card says it does, against what it does (D-042).
##
## `AssetText` is the one place that turns an Asset into a sentence, and both
## front-ends read it: the terminal prints it beside a commit option, the browser
## puts it in the card's tooltip. If it drifts from the resolver, every player
## chooses on a number that will not arrive.

const AssetText := preload("res://scripts/core/asset_text.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")


## The number on the card is the number the resolution uses. Not a copy of the
## formula - the same call, over every card in the library and both cases of the
## only thing that changes it.
func test_the_value_shown_is_the_value_the_resolver_gives() -> void:
	var loaded: RefCounted = data()
	var checked: int = 0
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[asset_id]
		var family: String = str(asset["family"])
		for relevant in [[family], []]:
			assert_eq(
				AssetText.value_on(asset, relevant),
				ConfluenceResolution.asset_value(asset, relevant, "SUPPORT"),
				"%s: il valore mostrato e quello che entra nella somma" % asset_id
			)
			checked += 1
	assert_eq(checked, loaded.assets.size() * 2, "ogni carta, dentro e fuori tema")


## Every card says what happens to it afterwards. "Si scarta comunque" is the
## difference between spending a card and lending it, and a player deciding
## without it is deciding on half the information.
func test_every_card_says_what_becomes_of_it() -> void:
	var loaded: RefCounted = data()
	for asset_id in loaded.assets:
		var note: String = AssetText.note(loaded.assets[asset_id])
		assert_true(note != "", "%s deve dire cosa le succede dopo" % asset_id)
		assert_false(
			note.contains("$"), "%s: nessuno slot non risolto nel testo" % asset_id
		)


## A card that does something to the world when committed says so, in words,
## and one that does not stays quiet. This is what makes the 12 strongest cards
## a decision instead of the obvious play.
func test_a_card_that_costs_something_says_so() -> void:
	var loaded: RefCounted = data()
	var costed: int = 0
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[asset_id]
		var note: String = AssetText.note(asset)
		if (asset.get("on_commit_effects", []) as Array).is_empty():
			assert_false(note.contains("costa:"), "%s non costa niente e non deve dirlo" % asset_id)
			continue
		costed += 1
		assert_true(note.contains("costa:"), "%s ha un costo e deve dichiararlo" % asset_id)
	assert_true(costed >= 12, "le carte con un costo sono almeno le dodici da 3, misurate %d" % costed)


## The bonus is quoted the way the resolver applies it: a card that only pays on
## the Oppose front must not read as if it always did.
func test_the_bonus_is_quoted_for_the_front_that_gets_it() -> void:
	var loaded: RefCounted = data()
	var seen: Dictionary = {}
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[asset_id]
		var kind: String = str(asset["confluence_modifier"]["kind"])
		var note: String = AssetText.modifier_note(asset)
		seen[kind] = true
		match kind:
			"NONE":
				assert_eq(note, "", "%s non ha bonus" % asset_id)
			"FLAT_BONUS":
				assert_true(note.contains("sempre"), "%s: +N sempre" % asset_id)
			"RELEVANT_BONUS":
				assert_true(note.contains("tema"), "%s: +N sul suo tema" % asset_id)
			"OPPOSE_BONUS":
				assert_true(note.contains("opponi"), "%s: +N se ti opponi" % asset_id)
	for kind in ["NONE", "FLAT_BONUS", "RELEVANT_BONUS", "OPPOSE_BONUS"]:
		assert_true(seen.has(kind), "la biblioteca esercita %s" % kind)


## The tooltip carries the card's own sentence as well as the mechanics: the
## authored text is the reason a card is memorable, and dropping it would leave
## a spreadsheet row.
func test_the_tooltip_keeps_the_card_its_own_words() -> void:
	var loaded: RefCounted = data()
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[asset_id]
		var tooltip: String = AssetText.tooltip(asset)
		assert_true(tooltip.contains(str(asset["title"])), "%s: il titolo" % asset_id)
		var rules: String = str(asset.get("rules_text", ""))
		if rules != "":
			assert_true(tooltip.contains(rules), "%s: la riga scritta dall'autore" % asset_id)


## **Una carta dice il verbo che porta** (D-228).
##
## Prima non lo diceva: la scheda portava famiglia, forza, modificatore, che fine
## fa la carta e cosa costa impegnarla — e mai «se la cali, muovi una presenza».
## Al tavolo e' la prima domanda, non l'ultima, e chi sceglieva sceglieva alla
## cieca su meta' della carta.
func test_every_card_names_the_verb_it_carries() -> void:
	var loaded: RefCounted = data()
	var checked: int = 0
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[str(asset_id)]
		var kind: String = str((asset.get("card_action", {}) as Dictionary).get("kind", ""))
		if kind == "" or kind == "NONE":
			continue
		var said: String = AssetText.action_note(asset)
		assert_true(
			said != "" and not said.begins_with("un'azione senza parole"),
			"«%s» porta %s e lo dice: «%s»" % [str(asset["title"]), kind, said]
		)
		assert_true(
			AssetText.tooltip(asset, loaded).contains(said),
			"e la scheda lo scrive, non solo la funzione"
		)
		checked += 1
	assert_true(checked >= 40, "e vale per tutte le carte con un'azione: %d" % checked)


## **E nessuna carta parla in tecnico.**
##
## Misurato prima di rimediare: su **49 effetti di carta**, 21 avevano una frase
## e **28 stampavano il proprio tipo in minuscolo**. Sull'«Assedio» un giocatore
## leggeva davvero «costa: la domanda in gioco sale, raze_structure». Un tipo in
## minuscolo sembra una regola e non lo e': e' il nome interno di un Effetto,
## finito su una carta.
##
## La funzione adesso **dichiara** quello che non sa dire, invece di travestirlo
## da regola — e questa prova prende la dichiarazione.
func test_no_card_speaks_in_effect_types() -> void:
	var loaded: RefCounted = data()
	var effects: int = 0
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[str(asset_id)]
		for effect in asset.get("on_commit_effects", []):
			var said: String = AssetText.effect_note(effect as Dictionary, loaded)
			assert_false(
				said.begins_with("un effetto senza parole"),
				"«%s»: l'effetto %s non ha una frase da tavolo"
				% [str(asset["title"]), str((effect as Dictionary).get("type", "?"))]
			)
			assert_false(
				said.contains("_"),
				"«%s»: la frase «%s» porta ancora un nome interno" % [str(asset["title"]), said]
			)
			effects += 1
	assert_true(effects >= 45, "e vale per ogni effetto di ogni carta: %d" % effects)


## E i segni si dicono **con la parola del segno**, la stessa della mappa e del
## segnalino di cartone: «dove si discute diventa affamata», non col nome
## interno del tag. La prova non guarda piu' un elenco di tipi (D-336: quello
## non esiste piu', la frase si costruisce dall'Effetto intero): guarda ogni
## Effetto che **porta un segno nel payload**, che e' la stessa cosa detta dal
## dato invece che da una costante.
func test_a_sign_on_a_card_carries_its_own_word() -> void:
	var loaded: RefCounted = data()
	var vague: Array = []
	var seen: int = 0
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[str(asset_id)]
		for effect in asset.get("on_commit_effects", []):
			var tag: String = str(
				((effect as Dictionary).get("payload", {}) as Dictionary).get("tag", "")
			)
			if tag == "":
				continue
			seen += 1
			var said: String = AssetText.effect_note(effect as Dictionary, loaded)
			if said.contains(tag):
				vague.append("%s: «%s»" % [str(asset["title"]), said])
	assert_eq(vague, [], "ogni segno su una carta si dice con la sua parola")
	assert_true(seen >= 20, "e la prova ha guardato abbastanza segni: %d" % seen)


## **Una riga stampata che non dice dove non dice niente** (D-336).
##
## Fino alla 0.1.300 la frase era una stringa fissa per tipo di Effetto, e
## prometteva sempre lo stesso posto: *«si alza una costruzione dove si
## discute»* anche quando la costruzione si alzava altrove. Contro i dati, **89
## righe su 164 dicevano il falso** — e il cancello del catalogo non se ne
## accorgeva, perche' controlla che il documento combaci col generatore, non che
## il generatore dica il vero.
##
## Questa e' la guardia che mancava. Non confronta due testi: prende **ogni
## Effetto che una proposta puo' applicare** e chiede alla frase di nominare il
## suo posto, la sua casa, il suo verso. Un bersaglio che il vocabolario non
## conosce cade su un ripiego **dichiarato**, e la prova lo prende — cosi' un
## bersaglio nuovo si vede il giorno che entra, non tre mesi dopo al tavolo.
func test_every_council_effect_says_where_it_lands() -> void:
	var loaded: RefCounted = data()
	var muti: Array = []
	var visti: int = 0
	for consequence_id in loaded.consequences:
		var consequence: Dictionary = loaded.consequences[str(consequence_id)]
		for effect in consequence.get("effects", []) as Array:
			visti += 1
			var said: String = AssetText.effect_note(effect as Dictionary, loaded)
			var ripiego: bool = (
				said.contains("non sa dire")
				or said.begins_with("un effetto senza parole")
			)
			# E nessun segnaposto deve arrivare fino alla riga: `$rival_seat` sulla
			# scheda e' un nome interno, non una parola del tavolo.
			if ripiego or said.contains("$"):
				muti.append("%s: «%s»" % [str(consequence_id), said])
	assert_eq(muti, [], "ogni Effetto di una Conseguenza dice dove cade")
	assert_true(visti >= 150, "e la prova li ha guardati tutti: %d" % visti)


## E la guardia morde: un bersaglio che il vocabolario non conosce **deve**
## finire sul ripiego dichiarato. Senza questa, la prova qui sopra passerebbe
## anche se `_place` inventasse un posto qualsiasi.
func test_an_unknown_target_is_declared_not_invented() -> void:
	var said: String = AssetText.effect_note({
		"type": "SET_REGION_TAG",
		"target": {"kind": "region", "id": "$un_posto_seminato_apposta"},
		"payload": {"tag": "condition:contested"},
	}, data())
	assert_true(said.contains("non sa dire"),
		"un posto che il vocabolario non conosce si dichiara: «%s»" % said)
