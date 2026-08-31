extends "res://tests/test_case.gd"
## The screen does not know anybody's name (D-050).
##
## The second saga shipped complete - four houses, six questions, sixteen
## Destinies, two Chronicles, all of it validated and playable from the terminal -
## and the browser could not reach a line of it. Three constants were the whole
## reason: a list of the first saga's four Entity ids in `game_screen.gd`, a
## table of their display names next to it, and a `match` on those same ids in
## `map_view.gd` handing out map colours. Everything else on that screen was
## already reading the data.
##
## Content that cannot be reached is content that does not exist, which is the
## same sentence D-035 wrote about the propositions the policy never chose. So
## this is a lint, and it is deliberately blunt: **no Entity id appears anywhere
## in the UI**. A screen that names a house is a screen that has an opinion about
## which saga is being played, and it is not entitled to one.
##
## Chronicle ids are *not* checked. Two remain, both as the fallback for "the
## data set failed to load and there is nothing to list" - a default, not a
## choice - and both are one line from the code that reads the real list.

const UI_DIR: String = "res://ui"


func test_no_screen_names_an_entity() -> void:
	var files: Array = _scripts_in(UI_DIR)
	assert_true(files.size() > 4, "trovati gli script della UI: %d" % files.size())

	for path in files:
		var source: String = _read(str(path))
		assert_true(source != "", "%s si legge" % str(path))
		for entity_id in data().entities:
			# The doc comment above says the id out loud on purpose, and a comment
			# is not code: only what the screen actually runs is checked.
			assert_false(
				_mentions_outside_comments(source, str(entity_id)),
				"%s nomina %s: lo schermo non deve sapere chi siede al tavolo"
				% [str(path), str(entity_id)]
			)


## And the other half of the same rule: every Chronicle in the box has to be
## reachable. A screen that lists two of four is the bug this file exists for,
## in the other direction.
func test_every_chronicle_seats_its_own_table() -> void:
	for chronicle_id in data().chronicles:
		var chronicle: Dictionary = data().chronicles[str(chronicle_id)]
		var seats: Array = chronicle["entities"]
		assert_true(seats.size() >= 2, "%s ha un tavolo" % str(chronicle_id))
		for entity_id in seats:
			assert_true(
				data().entities.has(str(entity_id)),
				"%s siede %s, che esiste" % [str(chronicle_id), str(entity_id)]
			)
			var definition: Dictionary = data().entities[str(entity_id)]
			assert_true(
				data().destinies.has(str(definition["destiny_id"])),
				"%s vuole qualcosa di scritto" % str(entity_id)
			)


func _scripts_in(path: String) -> Array:
	var out: Array = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if name.ends_with(".gd"):
			out.append("%s/%s" % [path, name])
		name = dir.get_next()
	dir.list_dir_end()
	out.sort()
	return out


func _read(path: String) -> String:
	var handle: FileAccess = FileAccess.open(path, FileAccess.READ)
	if handle == null:
		return ""
	var text: String = handle.get_as_text()
	handle.close()
	return text


## True if `needle` appears on a line that is not a comment. Godot has no
## block comments, so a line is code up to the first `#` outside a string - and
## since no Entity id is ever quoted next to one, a plain split is enough here.
func _mentions_outside_comments(source: String, needle: String) -> bool:
	for line in source.split("\n"):
		var text: String = str(line)
		var hash_at: int = text.find("#")
		if hash_at >= 0:
			text = text.substr(0, hash_at)
		if text.contains(needle):
			return true
	return false


## D-359: non c'e' piu' una mano del Narratore accanto agli Asset - l'Eco e' il
## terzo blocco della carta che si ha gia' in mano, e la vista lo dice nel
## tooltip. Il test compila e disegna la vista, che la suite headless altrimenti
## non carica mai - il debito scoperto in 0.1.60, pagato qui per questa vista.
func test_hand_view_draws_one_card_each_with_its_echo() -> void:
	new_session()
	var viewer: String = str(session.world["turn_order"][0])
	var view: HBoxContainer = preload("res://ui/hand_view.gd").new()
	view.render(session, viewer)
	assert_eq(
		view.get_child_count(),
		session.service.hand_size(viewer),
		"una figura per ogni Asset in mano, e nessun mazzo a parte"
	)
	var said_echo: bool = false
	for child in view.get_children():
		if str((child as Control).tooltip_text).begins_with("L'ECO - "):
			said_echo = true
	assert_true(said_echo, "e ogni carta dice quale Eco porta")
	view.free()
