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
const AssetText := preload("res://scripts/core/asset_text.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

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

## Piu' console, un decider (voce 27 fase 2 — D-135): `ios[seat]` e' l'io del
## telefono di quel seggio; `io` resta il ripiego condiviso (il terminale,
## l'hotseat, la console di riserva sullo schermo grande). Ogni ingresso
## pubblico dichiara a chi sta parlando prima di dire o chiedere: e' cosi'
## che l'avviso di un Destino finisce sul telefono giusto e su nessun altro.
var ios: Dictionary = {}
var _speaking_to: String = ""


func _io_now() -> Object:
	return ios.get(_speaking_to, io)


func _say(text: String) -> void:
	var ear: Object = _io_now()
	if ear != null:
		ear.say(text)


## Se l'io dall'altra parte disegna da se' il pannello del seggio. Chi lo fa
## non ha bisogno della versione a caratteri; chi tace risponde di no, che e'
## la risposta giusta per il terminale e per lo schermo del tavolo.
func _reads_own_state() -> bool:
	var ear: Object = _io_now()
	return ear != null and ear.has_method("shows_state") and bool(ear.shows_state())


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
	var ear: Object = _io_now()
	if entries.is_empty() or ear == null:
		return -1
	var labels: Array = []
	for entry in entries:
		labels.append(str(entry))
	var picked: int = await ear.choose(prompt, labels, subjects)
	if picked < 0 or picked >= entries.size():
		return -1
	return picked


# --- the turn ---------------------------------------------------------------

func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
	if not _is_human(entity_id):
		return fallback.choose_action(entity_id, ao_index, session)
	_speaking_to = entity_id

	_say("")
	# Il pannello a caratteri e' per chi non ha un pannello. Il terminale e lo
	# schermo del tavolo lo leggono; la console del telefono no: lei riceve gia'
	# lo `state` strutturato (D-134) e disegna domande, mano, Destino e rapporti
	# a sezioni. Mandarglielo lo stesso significa dire due volte le stesse cose,
	# la seconda peggio, in cima allo schermo piu' piccolo che abbiamo (D-143).
	if not _reads_own_state():
		_say(_board(entity_id, session))
	var options: Array = _action_options(entity_id, session)
	var labels: Array = []
	var subjects: Array = []
	for option in options:
		labels.append(str(option["label"]))
		subjects.append(option.get("subject", {}))
	labels.append("Passa")
	subjects.append({})
	# ISSUES 21: al tavolo fisico un compagno ti farebbe notare che stai
	# spegnendo la tua stessa spunta. L'app fa altrettanto: se la mossa scelta
	# spegne una clausola accesa del proprio Destino, una riga di avviso e la
	# scelta di ripensarci. Un cartello, non un consigliere.
	while true:
		var choice: int = await _choose(
			"%s, azione %d:" % [_name(entity_id, session), ao_index + 1], labels, subjects
		)
		if choice < 0:
			return fallback.choose_action(entity_id, ao_index, session)
		if choice >= options.size():
			return {"template": "PASS", "params": {}}
		var request: Dictionary = {
			"template": str(options[choice]["template"]),
			"params": options[choice]["params"],
		}
		var dying: Array = _clauses_this_switches_off(entity_id, request, session)
		if dying.is_empty():
			return request
		_say("  ⚠ Questa mossa spegne: %s" % ", ".join(PackedStringArray(dying)))
		var confirmed: int = await _choose(
			"  La fai lo stesso?", ["Sì, la faccio", "No, ci ripenso"]
		)
		if confirmed != 1:
			return request
	return {"template": "PASS", "params": {}}


## ISSUES 21: le clausole del proprio Destino, oggi accese, che questa azione
## spegnerebbe. L'anteprima è una sessione ricostruita dal salvataggio — stesso
## mondo, stesso dado, quindi la previsione è esatta — su cui l'azione viene
## eseguita davvero e poi buttata via: nessun ramo di regole duplicato da
## tenere allineato. Solo il posto proprio e solo clausole già vere: chi vuole
## sapere cosa conviene ha il tavolo, non un consigliere.
func _clauses_this_switches_off(
	entity_id: String, request: Dictionary, session: RefCounted
) -> Array:
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	if destiny == null:
		return []
	var lit: Array = []
	for level in ["minimum", "victory", "triumph"]:
		for condition in destiny[level]["conditions"]:
			if session.destinies.conditions.holds(condition, {"self": entity_id}):
				lit.append(condition)
	if lit.is_empty():
		return []
	var preview: RefCounted = GameSession.new(session.data)
	if not preview.restore(session.to_save("anteprima")):
		return []
	var dying: Array = []
	var outcome: Dictionary = preview.actions.execute(entity_id, request)
	if bool(outcome.get("ok", false)):
		for condition in lit:
			if preview.destinies.conditions.holds(condition, {"self": entity_id}):
				continue
			var said: String = "«%s»" % str(condition.get("label", ""))
			if not dying.has(said):
				dying.append(said)
	preview.dispose()
	return dying


## Every legal action, already checked against the rules, so a person is never
## offered something the resolver will refuse. This is the part a Confluence
## Board would draw as buttons in 0.1; the legality query is the same.
func _action_options(entity_id: String, session: RefCounted) -> Array:
	var out: Array = []
	var service: RefCounted = session.service

	# ISSUES 23 (D-118): le carte del Narratore in mano, quelle che la storia
	# accetta adesso. Il prezzo (una carta Asset) lo sceglie il resolver.
	for card_id in session.world["entities"][entity_id].get("echo_hand", []):
		var request: Dictionary = {"echo_card_id": str(card_id)}
		if session.actions.can_execute(entity_id, "PLAY_ECHO", request):
			out.append({
				"label": "Cala la carta del Narratore: %s" % str(
					session.data.echo_cards[str(card_id)]["title"]
				),
				"template": "PLAY_ECHO", "params": request,
			})

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

	# Il velo (D-125): l'arte inversa, per chi ha il segno che la concede.
	# Il resolver rifiuta da solo chi non ce l'ha: qui si offre, non si giudica.
	for tension_id in _sorted(session.world["tensions"].keys()):
		var veil: Dictionary = {"mode": "VEIL", "tension_id": str(tension_id)}
		if session.actions.can_execute(entity_id, "SCHEME", veil):
			out.append({
				"label": "Cala il velo su %s" % _tension(str(tension_id), session),
				"template": "SCHEME", "params": veil,
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
	_speaking_to = proponent
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
	_speaking_to = proponent
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
	_speaking_to = entity_id
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
	_speaking_to = entity_id
	if not _is_human(entity_id):
		return fallback.choose_commit(entity_id, context, limit, session)
	var ranked: Array = session.service.ranked_hand_for_tension(
		entity_id, str(context["tension_id"])
	)
	if ranked.is_empty():
		return []
	var relevant: Array = session.service.relevant_families(str(context["tension_id"]))

	var chosen: Array = []
	while chosen.size() < limit:
		var remaining: Array = []
		var labels: Array = []
		for asset_id in ranked:
			if chosen.has(asset_id):
				continue
			var asset: Dictionary = session.data.assets[str(asset_id)]
			remaining.append(asset_id)
			# What it is worth *here*, and what it does on the way out. Choosing
			# what to put down without either is choosing blind, and a quarter of
			# the library now does something to the world when committed (D-042).
			labels.append("%s — %s, vale %d\n%s" % [
				str(asset["title"]), str(asset["family"]).to_lower(),
				AssetText.value_on(asset, relevant),
				AssetText.note(asset),
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


## §12.3: if the proposal falls, whoever opposed it keeps **one** of the cards
## they put down. This is the last decision the rules give a player, and until
## 0.1.5 it was the only one nobody was ever asked - the engine picked the
## strongest recoverable card and moved on.
##
## It is asked *before* the roll, because that is when the rules ask it: the
## controller collects the recovery alongside the commits and only uses it if
## the Council actually falls. So the question is a real one - you are naming
## what you would save from a defeat that has not happened yet.
##
## Asked only when there is something to decide: a seat that did not oppose has
## no recovery, and one card left standing is not a choice.
func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
	var recovery: Dictionary = fallback.choose_recovery(context, session)
	for entity_id in humans:
		var seat: String = str(entity_id)
		_speaking_to = seat
		var stance: Dictionary = (context.get("stances", {}) as Dictionary).get(seat, {})
		if str(stance.get("stance", "")) != "OPPOSE":
			continue
		var options: Array = []
		var labels: Array = []
		for asset_id in (context.get("commits", {}) as Dictionary).get(seat, []):
			var asset: Variant = session.data.assets.get(str(asset_id))
			# ALWAYS_DISCARD never comes back, whoever wins: offering it would be
			# offering a choice the resolver is about to ignore.
			if asset == null or str(asset["discard_or_retain_rule"]) == "ALWAYS_DISCARD":
				continue
			options.append(str(asset_id))
			labels.append("%s — %s, forza %d" % [
				str(asset["title"]), str(asset["family"]).to_lower(), int(asset["strength"]),
			])
		if options.size() < 2:
			continue
		var choice: int = await _choose(
			"  %s, se la proposta cade quale carta ti riprendi?" % _name(seat, session), labels
		)
		if choice >= 0:
			recovery[seat] = str(options[choice])
	return recovery


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
		# ISSUES 22 (fase 2): la mappa non nasconde. Nella partita 15308 la
		# Valle Verde - contesa e senza controllore - non e' mai apparsa qui
		# per due atti. Una Regione segnata si vede anche senza presidi.
		var signs: Array = []
		for tag in world["regions"][str(region_id)]["tags"]:
			for prefix in ["condition:", "scar:", "structure:", "settlement:"]:
				if str(tag).begins_with(prefix):
					signs.append(SignLabels.label(str(tag), session.data))
					break
		if mine == 0 and control == null and signs.is_empty():
			continue
		var mark: String = ""
		if mine > 0:
			mark += "1 tuo" if mine == 1 else "%d tuoi" % mine
		if control != null:
			mark += "%s%s" % ["/" if mark != "" else "", _name(str(control), session)]
		if not signs.is_empty():
			mark += "%s%s" % ["; " if mark != "" else "", ", ".join(PackedStringArray(signs))]
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
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(entity_id))
	if destiny == null:
		return ""
	var rungs: Array = []
	for level in ["minimum", "victory", "triumph"]:
		var holds: bool = session.destinies.conditions.all_hold(destiny[level]["conditions"], {"self": entity_id})
		rungs.append("%s %s" % ["[x]" if holds else "[ ]", str(destiny[level]["label"])])
	return "Il tuo Destino: %s" % "  ".join(PackedStringArray(rungs))


func _tension_reading(tension_id: String, viewer_id: String, session: RefCounted) -> String:
	var value: int = session.service.visible_tension_value(tension_id, viewer_id)
	if value < 0:
		return "(velata)"
	return "%d/%d" % [value, session.tensions.threshold(tension_id)]


func _name(entity_id: String, session: RefCounted) -> String:
	var entity: Variant = session.data.entities.get(entity_id)
	return entity_id if entity == null else str(session.service.name_of(entity_id))


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
