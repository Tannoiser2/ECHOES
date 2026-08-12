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
