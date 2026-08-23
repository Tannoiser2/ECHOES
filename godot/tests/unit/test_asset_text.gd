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
## segnalino di cartone: «la Regione discussa diventa affamata», non «un segno
## cade sul mondo». Il ripiego esiste per non mentire, non per essere usato.
func test_a_sign_on_a_card_carries_its_own_word() -> void:
	var loaded: RefCounted = data()
	var vague: Array = []
	for asset_id in loaded.assets:
		var asset: Dictionary = loaded.assets[str(asset_id)]
		for effect in asset.get("on_commit_effects", []):
			if not AssetText.SIGN_COSTS.has(str((effect as Dictionary).get("type", ""))):
				continue
			if AssetText.effect_note(effect as Dictionary, loaded) == "un segno cade sul mondo":
				vague.append(str(asset["title"]))
	assert_eq(vague, [], "ogni segno su una carta ha la sua parola")
