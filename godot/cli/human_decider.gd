extends RefCounted
## A seat played by a person, at the keyboard.
##
## The ChronicleController has never known who its players are - it asks a
## duck-typed `decider` and applies whatever comes back. Four of those exist for
## machines: ScriptedDecider replays authored plans, PolicyDecider plays to win,
## SuppressorDecider only ever calms things down, and the stance probe borrows
## PolicyDecider to read its mind. This is the fifth, and the first one that
## does not decide anything itself.
##
## It exists because the measurements have run out of things to say. Three
## rounds in a row found the *instrument* at fault rather than the rules, and
## what is left open (O-14: the crown sits at Minimum in 32 Chronicles out of 40)
## is a question about whether a game feels right, which no probe can answer.
##
## Seats not listed as human fall through to `fallback`, so one person can sit
## down against three policies.
##
## An empty answer always means "you decide" and hands that one choice back to
## the policy. That is also what makes a piped script work: Godot returns the
## same empty string for a bare Enter and for end-of-input, so there is no way to
## tell them apart - and no need to. Once the answers run out every remaining
## prompt reads empty, takes the default, and the policy finishes the Chronicle.
## An earlier version tried to detect EOF and latch itself off, which meant a
## player who accepted a single default was locked out of their own game.

const PolicyDecider := preload("res://cli/policy_decider.gd")

## Entity ids a person is playing.
var humans: Dictionary = {}
var fallback: RefCounted
var log: RefCounted
## Tests drive this decider to prove an unanswered table plays like the policy;
## the prompts are the point in a terminal and noise in a test run.
var quiet: bool = false


func _init(p_humans: Array, p_log: RefCounted = null) -> void:
	for entity_id in p_humans:
		humans[str(entity_id)] = true
	log = p_log
	fallback = PolicyDecider.new(p_log)


func _is_human(entity_id: String) -> bool:
	return humans.has(entity_id)


# --- reading a person -------------------------------------------------------

func _say(text: String) -> void:
	if not quiet:
		print(text)


## One line from the keyboard. Empty means "you decide" - and Godot returns the
## same empty string at end-of-input, which is why that is the right meaning.
func _ask(prompt: String) -> String:
	if quiet:
		return ""
	printraw("%s " % prompt)
	return OS.read_string_from_stdin(1024).strip_edges()


## A numbered menu. Returns the chosen index, or -1 for "you decide" - which is
## always an option, so a player can hand any single choice back to the policy
## without leaving the game.
func _choose(prompt: String, entries: Array, default_index: int = -1) -> int:
	if entries.is_empty():
		return -1
	for i in range(entries.size()):
		_say("   %2d) %s" % [i + 1, str(entries[i])])
	var suffix: String = " [invio = lascia decidere alla policy]"
	if default_index >= 0:
		suffix = " [invio = %d]" % (default_index + 1)
	var answer: String = _ask("%s%s" % [prompt, suffix])
	if answer == "":
		return default_index
	if not answer.is_valid_int():
		_say("   (non e un numero: decide la policy)")
		return default_index
	var index: int = answer.to_int() - 1
	if index < 0 or index >= entries.size():
		_say("   (fuori elenco: decide la policy)")
		return default_index
	return index


# --- the turn ---------------------------------------------------------------

func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_action(entity_id, ao_index, session)

	_say("")
	_say(_board(entity_id, session))
	var options: Array = _action_options(entity_id, session)
	var labels: Array = []
	for option in options:
		labels.append(str(option["label"]))
	labels.append("Passa")
	var choice: int = _choose(
		"%s, azione %d:" % [_name(entity_id, session), ao_index + 1], labels
	)
	if choice < 0:
		return fallback.choose_action(entity_id, ao_index, session)
	if choice >= options.size():
		return {"template": "PASS", "params": {}}
	return {
		"template": str(options[choice]["template"]),
		"params": options[choice]["params"],
	}


## Every legal action, already checked against the rules, so a person is never
## offered something the resolver will refuse. This is the part a Confluence
## Board would draw as buttons in 0.1; the legality query is the same.
func _action_options(entity_id: String, session: RefCounted) -> Array:
	var out: Array = []
	var service: RefCounted = session.service

	for family in ["AUTHORITY", "FORCE", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]:
		var request: Dictionary = {"family": family}
		if session.actions.can_execute(entity_id, "ACQUIRE", request):
			out.append({
				"label": "Acquisisci una carta %s" % family,
				"template": "ACQUIRE", "params": request,
			})

	for region_id in _sorted(session.world["regions"].keys()):
		var request: Dictionary = {"region_id": str(region_id)}
		if session.actions.can_execute(entity_id, "MOVE", request):
			out.append({
				"label": "Metti una presenza in %s" % _region(str(region_id), session),
				"template": "MOVE", "params": request,
			})

	for tension_id in _sorted(session.world["tensions"].keys()):
		for delta in [1, -1]:
			var request: Dictionary = {
				"tension_id": str(tension_id), "delta": delta, "via": "PRESENCE",
			}
			if not session.actions.can_execute(entity_id, "INFLUENCE", request):
				continue
			out.append({
				"label": "%s %s (%s)" % [
					"Alza" if delta > 0 else "Abbassa",
					_tension(str(tension_id), session),
					_tension_reading(str(tension_id), entity_id, session),
				],
				"template": "INFLUENCE", "params": request,
			})

	for tension_id in _sorted(session.world["tensions"].keys()):
		# Only what is actually hidden from you. An open Tension already shows its
		# number, and offering to scout it is offering a wasted Action Opportunity.
		if not session.tensions.is_veiled(str(tension_id)):
			continue
		if service.knows_tension(entity_id, str(tension_id)):
			continue
		var request: Dictionary = {"mode": "TENSION", "tension_id": str(tension_id)}
		if session.actions.can_execute(entity_id, "SCHEME", request):
			out.append({
				"label": "Scopri il numero di %s" % _tension(str(tension_id), session),
				"template": "SCHEME", "params": request,
			})

	for other_id in session.world["turn_order"]:
		if str(other_id) == entity_id:
			continue
		for direction in ["UP", "DOWN"]:
			var request: Dictionary = {
				"target_entity_id": str(other_id), "direction": direction,
			}
			if not session.actions.can_execute(entity_id, "FORGE", request):
				continue
			out.append({
				"label": "%s i rapporti con %s (ora %s)" % [
					"Avvicina" if direction == "UP" else "Rompi",
					_name(str(other_id), session),
					service.relation_level(entity_id, str(other_id)),
				],
				"template": "FORGE", "params": request,
			})
	return out


# --- the Council ------------------------------------------------------------

func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	if not _is_human(proponent):
		return fallback.choose_question(context, options, session)
	_say("")
	_say("  %s apre il Consiglio su %s." % [
		_name(proponent, session), _tension(str(context["tension_id"]), session),
	])
	var labels: Array = []
	for question in options:
		labels.append(session.confluence.say(str(question["text"])))
	var choice: int = _choose("  Quale domanda poni?", labels)
	if choice < 0:
		return fallback.choose_question(context, options, session)
	return str(options[choice]["id"])


func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
	var proponent: String = str(context["proponent"])
	if not _is_human(proponent):
		return fallback.choose_proposition(context, options, session)
	var labels: Array = []
	for proposition in options:
		labels.append(session.confluence.say(str(proposition["text"])))
	var choice: int = _choose("  Cosa proponi?", labels)
	if choice < 0:
		return fallback.choose_proposition(context, options, session)
	return str(options[choice]["id"])


func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_stance(entity_id, context, session)
	var template: Dictionary = session.data.confluence_templates[str(context["template_id"])]
	var clauses: Array = template["condition_clauses"]

	var labels: Array = ["Sostieni", "Opponiti", "Astieniti"]
	var clause_ids: Array = []
	for clause in clauses:
		clause_ids.append(str(clause["id"]))
		labels.append("Sostieni a condizione che: %s" % session.confluence.say(str(clause["text"])))
	var choice: int = _choose("  %s, cosa dici?" % _name(entity_id, session), labels)
	if choice < 0:
		return fallback.choose_stance(entity_id, context, session)
	match choice:
		0: return {"stance": "SUPPORT", "clause_id": ""}
		1: return {"stance": "OPPOSE", "clause_id": ""}
		2: return {"stance": "ABSTAIN", "clause_id": ""}
	return {"stance": "CONDITION", "clause_id": str(clause_ids[choice - 3])}


func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
	if not _is_human(entity_id):
		return fallback.choose_commit(entity_id, context, limit, session)
	var ranked: Array = session.service.ranked_hand_for_tension(
		entity_id, str(context["tension_id"])
	)
	if ranked.is_empty():
		return []
	_say("  %s puo impegnare fino a %d carte, in ordine di peso su questa domanda:"
		% [_name(entity_id, session), limit])
	for i in range(ranked.size()):
		var asset: Dictionary = session.data.assets[str(ranked[i])]
		_say("   %2d) %s (%s, forza %d)" % [
			i + 1, str(asset["title"]), str(asset["family"]), int(asset["strength"]),
		])
	var answer: String = _ask("  Quali impegni? (numeri separati da spazio, invio = decide la policy)")
	if answer == "":
		return fallback.choose_commit(entity_id, context, limit, session)
	var chosen: Array = []
	for token in answer.split(" ", false):
		if not str(token).is_valid_int():
			continue
		var index: int = str(token).to_int() - 1
		if index < 0 or index >= ranked.size():
			continue
		if chosen.has(ranked[index]):
			continue
		chosen.append(ranked[index])
	return chosen.slice(0, limit)


func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
	return fallback.choose_recovery(context, session)


# --- what a player needs to see --------------------------------------------

## The board, from one seat. Everything here is already public to that seat -
## a veiled Tension shows a number only to someone who has scouted it (§11.1).
func _board(entity_id: String, session: RefCounted) -> String:
	var world: Dictionary = session.world
	var lines: Array = []
	lines.append("+-- ATTO %d, ROUND %d %s" % [
		int(world["act"]), int(world["round"]), "-".repeat(40),
	])

	var questions: Array = []
	for tension_id in _sorted(world["tensions"].keys()):
		questions.append("%s %s" % [
			_tension(str(tension_id), session),
			_tension_reading(str(tension_id), entity_id, session),
		])
	lines.append("| Le domande dell'anno: %s" % ", ".join(PackedStringArray(questions)))

	var places: Array = []
	for region_id in _sorted(world["regions"].keys()):
		var mine: int = session.service.presence_count(entity_id, str(region_id))
		var control: Variant = world["regions"][str(region_id)].get("control", null)
		if mine == 0 and control == null:
			continue
		var mark: String = ""
		if mine > 0:
			mark += "1 tuo" if mine == 1 else "%d tuoi" % mine
		if control != null:
			mark += "%s%s" % ["/" if mark != "" else "", _name(str(control), session)]
		places.append("%s (%s)" % [_region(str(region_id), session), mark])
	lines.append("| Sulla mappa: %s" % ", ".join(PackedStringArray(places)))

	var cards: Array = []
	for asset_id in session.service.hand(entity_id):
		cards.append(str(session.data.assets[str(asset_id)]["title"]))
	lines.append("| In mano: %s" % ("niente" if cards.is_empty() else ", ".join(PackedStringArray(cards))))
	lines.append("| %s" % _destiny_line(entity_id, session))
	return "\n".join(PackedStringArray(lines))


## The Destiny as a ladder, marking which rung holds right now. A player cannot
## steer towards a goal they cannot read.
func _destiny_line(entity_id: String, session: RefCounted) -> String:
	var definition: Variant = session.data.entities.get(entity_id)
	if definition == null:
		return ""
	var destiny: Variant = session.data.destinies.get(str(definition["destiny_id"]))
	if destiny == null:
		return ""
	var rungs: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var holds: bool = session.destinies.conditions.all_hold(destiny[level]["conditions"], {})
		rungs.append("%s %s" % ["[x]" if holds else "[ ]", str(destiny[level]["label"])])
	return "Il tuo Destino: %s" % "  ".join(PackedStringArray(rungs))


func _tension_reading(tension_id: String, viewer_id: String, session: RefCounted) -> String:
	var value: int = session.service.visible_tension_value(tension_id, viewer_id)
	if value < 0:
		return "(velata)"
	return "%d/%d" % [value, session.tensions.threshold(tension_id)]


func _name(entity_id: String, session: RefCounted) -> String:
	var entity: Variant = session.data.entities.get(entity_id)
	return entity_id if entity == null else str(entity["name"])


func _region(region_id: String, session: RefCounted) -> String:
	var region: Variant = session.data.regions.get(region_id)
	return region_id if region == null else str(region["name"])


func _tension(tension_id: String, session: RefCounted) -> String:
	var tension: Variant = session.data.tensions.get(tension_id)
	return tension_id if tension == null else str(tension["title"])


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
