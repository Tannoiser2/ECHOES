extends RefCounted
## What a seat can see and what it may do - without saying how it is shown.
##
## The ChronicleController has never known who its players are - it asks a
## duck-typed `decider` and applies whatever comes back. Four of those exist for
## machines: ScriptedDecider replays authored plans, PolicyDecider plays to win,
## SuppressorDecider only ever calms things down, and the stance probe borrows
## PolicyDecider to read its mind. This is the base of the ones a person drives,
## and the first that decides nothing itself.
##
## It holds the two things both front-ends need and neither should own twice:
## the board as one seat sees it, and the list of actions the rules will
## actually accept. `cli/human_decider.gd` renders those to a terminal,
## `ui/ui_decider.gd` to buttons in a browser. Two implementations of "what may
## I do right now" would be two implementations to keep in agreement (D-038).
##
## Seats not listed as human fall through to `fallback`, so one person can sit
## down against three policies.
##
## How a choice is *shown* is injected, not inherited: `io` is any object with
## `say(text)` and `choose(prompt, labels) -> int`. A terminal implements it with
## stdout and stdin, the browser screen with a panel and buttons, and a test
## leaves it null - which makes every choice defer to the policy, exactly what a
## seat nobody is watching should do.
##
## Injected rather than subclassed for a concrete reason, found by loading the
## exported build in a real browser: `extends "res://path.gd"` does not resolve
## in an exported project, while `preload` does. That is why this whole codebase
## uses `const X := preload(...)` and no `class_name`, and the rule holds here.

const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## Entity ids a person is playing.
var humans: Dictionary = {}
var fallback: RefCounted
var log: RefCounted


func _init(p_humans: Array, p_log: RefCounted = null) -> void:
	for entity_id in p_humans:
		humans[str(entity_id)] = true
	log = p_log
	fallback = PolicyDecider.new(p_log)


func _is_human(entity_id: String) -> bool:
	return humans.has(entity_id)


# --- reading a person -------------------------------------------------------

## Anything with `say(text)` and `choose(prompt, labels) -> int`. Null means
## nobody is watching this seat.
var io: Object = null


func _say(text: String) -> void:
	if io != null:
		io.say(text)


## Offer the choices and wait for one. Returns the chosen index, or -1 for
## "you decide", which hands this single choice back to the policy without
## taking the player out of their game.
##
## A coroutine: a mouse cannot answer on the same frame it was asked, and
## `ChronicleController.run()` is awaitable precisely so this can suspend the
## Chronicle in place instead of freezing it (D-038).
##
## `subjects[i]` says what choice `i` is *about* - `{"region": "REG_X"}` and
## nothing else so far - so a front-end that draws the world can put the choice
## where the thing is, instead of in a list beside it. It is a fact about the
## choice, not an instruction about the screen: the terminal ignores it, and no
## front-end may infer legality from it, because the entry only exists at all if
## the rules already accepted it (D-039).
func _choose(prompt: String, entries: Array, subjects: Array = []) -> int:
	if entries.is_empty() or io == null:
		return -1
	var labels: Array = []
	for entry in entries:
		labels.append(str(entry))
	var picked: int = await io.choose(prompt, labels, subjects)
	if picked < 0 or picked >= entries.size():
		return -1
	return picked


# --- the turn ---------------------------------------------------------------

func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_action(entity_id, ao_index, session)

	_say("")
	_say(_board(entity_id, session))
	var options: Array = _action_options(entity_id, session)
	var labels: Array = []
	var subjects: Array = []
	for option in options:
		labels.append(str(option["label"]))
		subjects.append(option.get("subject", {}))
	labels.append("Passa")
	subjects.append({})
	var choice: int = await _choose(
		"%s, azione %d:" % [_name(entity_id, session), ao_index + 1], labels, subjects
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
				# The one choice that has a place on a map: a front-end that draws
				# one can offer it there instead of as a line of text.
				"subject": {"region": str(region_id)},
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
	var choice: int = await _choose("  Quale domanda poni?", labels)
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
	var choice: int = await _choose("  Cosa proponi?", labels)
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
	var choice: int = await _choose("  %s, cosa dici?" % _name(entity_id, session), labels)
	if choice < 0:
		return fallback.choose_stance(entity_id, context, session)
	match choice:
		0: return {"stance": "SUPPORT", "clause_id": ""}
		1: return {"stance": "OPPOSE", "clause_id": ""}
		2: return {"stance": "ABSTAIN", "clause_id": ""}
	return {"stance": "CONDITION", "clause_id": str(clause_ids[choice - 3])}


## Commit one card at a time until the limit or "basta". The terminal could take
## a whole line of numbers and the browser cannot, so this is the shape both can
## drive - and it reads closer to what committing is: you put one thing down,
## then decide whether to put another.
func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
	if not _is_human(entity_id):
		return fallback.choose_commit(entity_id, context, limit, session)
	var ranked: Array = session.service.ranked_hand_for_tension(
		entity_id, str(context["tension_id"])
	)
	if ranked.is_empty():
		return []

	var chosen: Array = []
	while chosen.size() < limit:
		var remaining: Array = []
		var labels: Array = []
		for asset_id in ranked:
			if chosen.has(asset_id):
				continue
			var asset: Dictionary = session.data.assets[str(asset_id)]
			remaining.append(asset_id)
			labels.append("%s (%s, forza %d)" % [
				str(asset["title"]), str(asset["family"]), int(asset["strength"]),
			])
		if remaining.is_empty():
			break
		labels.append("Non impegno altro")
		var picked: int = await _choose(
			"  %s impegna (%d di %d):" % [_name(entity_id, session), chosen.size(), limit],
			labels
		)
		if picked < 0:
			# "You decide" on an empty hand-so-far means the whole commit.
			return fallback.choose_commit(entity_id, context, limit, session) if chosen.is_empty() else chosen
		if picked >= remaining.size():
			break
		chosen.append(remaining[picked])
	return chosen


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
