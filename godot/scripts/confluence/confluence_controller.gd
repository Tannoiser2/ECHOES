extends RefCounted
## The Confluence sequence A-K (§12.2).
##
## A state machine, not a script: open() runs A-C, the table then declares
## stances (D) and commits (E), and resolve() runs F-K in one atomic pass. The
## same object drives a headless simulation and, in 0.1, the Confluence Board.
##
## Resolution order inside resolve() - fixed, and documented in
## docs/RULES_V0_2.md so a Strategy swap cannot quietly change it:
##   1. World Factor roll                      (F)
##   2. Resolution maths                       (G)
##   3. Tension outcome (set to 1 / -2)        (H)
##   4. on_commit costs of the Assets spent    (H)
##   5. Outcome Consequences                   (H)
##   6. Cost / Decisive-bonus Consequence      (H)
##   7. Qualified Condition clause             (H)
##   8. Asset disposition                      (I)
##   9. Echo Check                             (J)
##  10. Ripple                                 (K)

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")
const ConsequenceCompiler := preload("res://scripts/chronicle/consequence_compiler.gd")
const ConditionEvaluator := preload("res://scripts/world/condition_evaluator.gd")
const EchoRecorder := preload("res://scripts/chronicle/echo_recorder.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")
const NarrativeText := preload("res://scripts/chronicle/narrative_text.gd")

const STANCES: Array = ["SUPPORT", "OPPOSE", "CONDITION", "ABSTAIN"]

signal step_changed(step: String, context: Dictionary)

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var rng: RefCounted
var log: RefCounted
var tensions: RefCounted

var service: RefCounted
var conditions: RefCounted
var compiler: RefCounted
var recorder: RefCounted
var narrative: RefCounted

var current: Dictionary = {}
var last_error: String = ""

var _chronicle: Dictionary


func _init(
	p_world: Dictionary,
	p_data: RefCounted,
	p_applier: RefCounted,
	p_rng: RefCounted,
	p_log: RefCounted,
	p_tensions: RefCounted
) -> void:
	world = p_world
	data = p_data
	applier = p_applier
	rng = p_rng
	log = p_log
	tensions = p_tensions
	service = WorldStateService.new(p_world, p_data)
	conditions = ConditionEvaluator.new(p_world, p_data)
	compiler = ConsequenceCompiler.new(p_data, p_world)
	narrative = NarrativeText.new(p_world, p_data, service)
	recorder = EchoRecorder.new(p_world, p_data, p_applier, p_log)
	recorder.narrative = narrative
	_chronicle = data.chronicles[world["chronicle_id"]]


func is_open() -> bool:
	return not current.is_empty()


# --- A, B, C ---------------------------------------------------------------

## Steps A (Trigger), B (Question) and the proponent half of C.
## `trigger` is {kind: THRESHOLD|CLAIM|ECHO_CARD, entity_id: ""}.
func open(tension_id: String, trigger: Dictionary) -> Dictionary:
	last_error = ""
	var template: Dictionary = data.confluence_template_for(tension_id)
	if template.is_empty():
		last_error = "nessun template di Confluence per '%s'" % tension_id
		return {}

	var index: int = int(world["confluence_count"])
	var proponent: String = str(trigger.get("entity_id", ""))
	if proponent == "" or not world["entities"].has(proponent):
		proponent = service.determine_proponent(tension_id, narrative.focus_region(tension_id))

	var question_id: String = _select_question(template, proponent, tension_id)
	if question_id == "":
		last_error = "nessuna domanda valida nel template '%s'" % template["id"]
		return {}

	current = {
		"confluence_id": "%s#%d" % [str(template["id"]), index + 1],
		"index": index,
		"template_id": str(template["id"]),
		"tension_id": tension_id,
		"trigger": trigger.duplicate(true),
		"question_id": question_id,
		"proponent": proponent,
		# Resolved once, at A, so every sentence in this Confluence names the same
		# Region and the same rival even if the world moves underneath it (H).
		"text_bindings": narrative.bindings_for(tension_id, proponent),
		"proposition_id": "",
		"stances": {},
		"commits": {},
		"world_factor": 0,
		"die": 0,
		"participants": [proponent],
		"step": "PROPOSITION",
		"act": int(world["act"]),
		"round": int(world["round"]),
	}

	log.section("CONFLUENCE %s - %s" % [current["confluence_id"], str(template["title"])])
	log.bullet("A. Trigger: %s su %s" % [str(trigger.get("kind", "THRESHOLD")), _tension_name(tension_id)])
	log.bullet("B. Domanda: %s" % say(_question_text(template, question_id)))
	# Chi ha aperto questo Consiglio si fara da parte al prossimo sulla stessa
	# domanda, se ci sara qualcun altro nella Regione di cui si discute (D-051).
	if not world.has("last_proponent"):
		world["last_proponent"] = {}
	world["last_proponent"][tension_id] = proponent
	log.bullet("C. Proponente: %s" % _name(proponent))
	step_changed.emit("QUESTION", current)
	return current


## §12.2 B: which questions the state of the Tension actually raises.
func available_questions() -> Array:
	if current.is_empty():
		return []
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	return _eligible_questions(template, str(current["proponent"]), str(current["tension_id"]))


## Step B: the proponent may pick any question the Tension has opened. Defaults
## to the sharpest one; a scripted plan or the 0.1 UI can pick another.
func set_question(question_id: String) -> bool:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return false
	for question in available_questions():
		if str(question["id"]) == question_id:
			current["question_id"] = question_id
			current["proposition_id"] = ""
			log.bullet("B. Domanda scelta: %s" % say(str(question["text"])))
			return true
	last_error = "domanda '%s' non disponibile" % question_id
	return false


## §12.2 B. Le domande che lo stato della Tensione apre davvero, **meno quelle
## che questa Chronicle ha gia' messo ai voti** finche' ne resta una nuova
## (D-061).
##
## Senza questo filtro il Debito della seconda saga poneva 94 volte su 94 la
## stessa domanda in quaranta Chronicle, e la meta' delle proposte scritte non
## veniva mai votata da nessuno: contenuto che esiste nei dati e non esiste al
## tavolo (D-035). Il filtro cade quando tutto e' stato chiesto - un Consiglio
## che ha esaurito le sue domande torna alla piu' affilata, come prima.
func _eligible_questions(template: Dictionary, proponent: String, tension_id: String) -> Array:
	var context: Dictionary = {"proponent": proponent, "tension": tension_id}
	var out: Array = []
	for question in template["questions"]:
		if conditions.all_hold(question["eligibility"], context):
			out.append(question)
	var asked: Array = _asked(tension_id)
	if asked.is_empty():
		return out
	var fresh: Array = []
	for question in out:
		if not asked.has(str((question as Dictionary)["id"])):
			fresh.append(question)
	return fresh if not fresh.is_empty() else out


func _asked(tension_id: String) -> Array:
	return (world.get("questions_asked", {}) as Dictionary).get(tension_id, []) as Array


func _mark_asked(tension_id: String, question_id: String) -> void:
	if question_id == "":
		return
	if not world.has("questions_asked"):
		world["questions_asked"] = {}
	var asked: Array = (world["questions_asked"] as Dictionary).get(tension_id, [])
	if not asked.has(question_id):
		asked.append(question_id)
	world["questions_asked"][tension_id] = asked


func _select_question(template: Dictionary, proponent: String, tension_id: String) -> String:
	# Deterministic default: the *last* eligible question in definition order.
	# Later questions are the sharper ones, gated on a hotter Tension, so a
	# Tension at breaking point asks the harder question by default.
	var eligible: Array = _eligible_questions(template, proponent, tension_id)
	if eligible.is_empty():
		return ""
	return str(eligible[eligible.size() - 1]["id"])


## Propositions the proponent may legally choose (C).
func available_propositions() -> Array:
	if current.is_empty():
		return []
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	var context: Dictionary = effect_context()
	var out: Array = []
	for proposition in template["propositions"]:
		if str(proposition["question_id"]) != str(current["question_id"]):
			continue
		if conditions.all_hold(proposition["eligibility"], context):
			out.append(proposition)
	return out


## Step C: the proponent picks one of the structured options (appendix A9 -
## free text returns with the Narrative Model in 0.4).
func set_proposition(proposition_id: String) -> bool:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return false
	for proposition in available_propositions():
		if str(proposition["id"]) == proposition_id:
			current["proposition_id"] = proposition_id
			current["step"] = "STANCE"
			log.bullet("C. Proposta: %s" % say(str(proposition["text"])))
			step_changed.emit("PROPOSITION", current)
			return true
	last_error = "proposta '%s' non disponibile" % proposition_id
	return false


# --- D: Stance -------------------------------------------------------------

## §12.2 D: public, in turn order from the proponent's left.
func stance_order() -> Array:
	return service.stance_order(str(current["proponent"])) if is_open() else []


func declare_stance(entity_id: String, stance: String, clause_id: String = "") -> bool:
	last_error = ""
	if current.is_empty() or str(current["step"]) not in ["STANCE", "COMMIT"]:
		last_error = "non e il momento di dichiarare una posizione"
		return false
	if entity_id == str(current["proponent"]):
		last_error = "il proponente non dichiara una posizione"
		return false
	if not STANCES.has(stance):
		last_error = "posizione non valida '%s'" % stance
		return false

	var record: Dictionary = {"stance": stance}
	if stance == "CONDITION":
		var clause: Dictionary = _find_clause(clause_id)
		if clause.is_empty():
			last_error = "clausola '%s' non presente nel template" % clause_id
			return false
		record["clause_id"] = clause_id
		log.bullet("D. %s: Condition - %s" % [_name(entity_id), say(str(clause["text"]))])
	else:
		log.bullet("D. %s: %s" % [_name(entity_id), stance])

	current["stances"][entity_id] = record
	if stance != "ABSTAIN" and not (current["participants"] as Array).has(entity_id):
		current["participants"].append(entity_id)
	return true


func _find_clause(clause_id: String) -> Dictionary:
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	for clause in template["condition_clauses"]:
		if str(clause["id"]) == clause_id:
			return clause
	return {}


# --- E: Commit -------------------------------------------------------------

func max_commit_for(entity_id: String) -> int:
	if entity_id == str(current["proponent"]):
		return int(_chronicle["max_commit_assets"])
	var stance: String = str(current["stances"].get(entity_id, {}).get("stance", "ABSTAIN"))
	if stance == "CONDITION":
		return int(_chronicle["max_condition_commit_assets"])
	if stance == "ABSTAIN":
		return 0
	return int(_chronicle["max_commit_assets"])


## §12.2 E: secret in hotseat, revealed simultaneously. The engine takes the
## commits one at a time and only reveals them in the log at resolve().
func commit(entity_id: String, asset_ids: Array) -> bool:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return false
	var limit: int = max_commit_for(entity_id)
	if asset_ids.size() > limit:
		last_error = "%s puo impegnare al massimo %d Asset" % [entity_id, limit]
		return false

	# Multiset check: the same card cannot be spent twice.
	var available: Array = service.hand(entity_id)
	for asset_id in asset_ids:
		var index: int = available.find(str(asset_id))
		if index < 0:
			last_error = "%s non ha '%s' in mano" % [entity_id, asset_id]
			return false
		available.remove_at(index)

	current["commits"][entity_id] = asset_ids.duplicate()
	if not asset_ids.is_empty() and not (current["participants"] as Array).has(entity_id):
		current["participants"].append(entity_id)
	current["step"] = "RESOLVE"
	return true


# --- F to K ----------------------------------------------------------------

## `recovery` maps an opposing entity id to the Asset it keeps on a Failure.
func resolve(recovery: Dictionary = {}) -> Dictionary:
	last_error = ""
	if current.is_empty():
		last_error = "nessuna Confluence aperta"
		return {}
	if str(current["proposition_id"]) == "":
		last_error = "nessuna proposta scelta"
		return {}

	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	var tension_id: String = str(current["tension_id"])
	var source: Dictionary = Effect.source(
		"confluence",
		str(current["confluence_id"]),
		str(current["proponent"]),
		int(world["act"]),
		int(world["round"]),
		int(world["effect_sequence"])
	)

	# F. World Factor.
	var die: int = rng.roll_d6()
	var factor: int = ConfluenceResolution.world_factor(die)
	current["die"] = die
	current["world_factor"] = factor

	# G. Resolution.
	var result: Dictionary = ConfluenceResolution.resolve(
		str(current["proponent"]),
		current["stances"],
		current["commits"],
		data.assets,
		service.relevant_families(tension_id),
		factor,
		int(_chronicle["condition_qualified_threshold"])
	)
	_log_commitments()
	log.bullet("F. World Factor: 1d6 = %d -> %+d" % [die, factor])
	# A qualified Condition is part of the margin (D-055), so it is part of the one
	# line a player reads to check the arithmetic - and an unqualified one is shown
	# too, crossed out of the sum, because "you spent two cards for nothing" is
	# exactly the thing that has to be visible.
	var condition: String = ""
	if int(result["condition_total"]) > 0:
		condition = (
			" C=%d" % int(result["condition_total"]) if bool(result["condition_qualified"])
			else " C=%d non qualificata" % int(result["condition_total"])
		)
	log.bullet(
		"G. S=%d%s O=%d W=%+d -> M=%d -> %s"
		% [
			int(result["support_total"]),
			condition,
			int(result["oppose_total"]),
			factor,
			int(result["margin"]),
			str(result["outcome"]),
		]
	)

	var applied: Array = []
	var outcome: String = str(result["outcome"])
	var context: Dictionary = effect_context()

	# H.1 The Tension itself. Failure drops it by 2 and leaves the question
	# alive (appendix A6); any success settles it to 1.
	var before: int = tensions.value(tension_id)
	var delta: int = -2 if outcome == ConfluenceResolution.FAILURE else 1 - before
	_apply(applied, Effect.make("ADJUST_TENSION", "tension", tension_id, {"delta": delta}, source))

	# H.2 What the committed cards cost their owners.
	for entity_id in current["commits"]:
		for asset_id in current["commits"][entity_id]:
			var asset: Variant = data.assets.get(str(asset_id))
			if asset == null:
				continue
			for spec in asset.get("on_commit_effects", []):
				var hook_context: Dictionary = context.duplicate()
				hook_context["actor"] = str(entity_id)
				_apply(applied, compiler.compile_spec(spec, hook_context, source))

	# H.3-H.5 Outcome consequences.
	var consequence_ids: Array = []
	if ConfluenceResolution.is_success(outcome):
		consequence_ids.append_array(_proposition()["success_consequences"])
		if outcome == ConfluenceResolution.SUCCESS_WITH_COST:
			consequence_ids.append_array(template["consequence_pools"]["cost"])
		elif outcome == ConfluenceResolution.DECISIVE:
			consequence_ids.append_array(template["consequence_pools"]["decisive_bonus"])
	else:
		consequence_ids.append_array(template["consequence_pools"]["failure"])
	for consequence_id in consequence_ids:
		for effect in compiler.compile(str(consequence_id), context, source):
			_apply(applied, effect)
		_apply_scar(applied, str(consequence_id), source)
	log.bullet("H. Conseguenze: %s" % ", ".join(PackedStringArray(consequence_ids)))

	# H.6 A qualified Condition rides along with any successful outcome (§12.3).
	if bool(result["condition_qualified"]) and ConfluenceResolution.is_success(outcome):
		for entity_id in current["stances"]:
			var stance: Dictionary = current["stances"][entity_id]
			if str(stance.get("stance", "")) != "CONDITION":
				continue
			var clause: Dictionary = _find_clause(str(stance.get("clause_id", "")))
			if clause.is_empty():
				continue
			log.bullet("H. Clausola qualificata: %s" % say(str(clause["text"])))
			for spec in clause["effects"]:
				_apply(applied, compiler.compile_spec(spec, context, source))

	# I. Asset disposition.
	_dispose_assets(applied, result, outcome, recovery, source)

	# J. Echo Check.
	var echo_created: bool = false
	if recorder.should_record(result):
		var effect_ids: Array = []
		for effect in applied:
			effect_ids.append(str(effect["effect_id"]))
		applied.append_array(recorder.record(current, result, effect_ids, source))
		echo_created = true
	else:
		log.bullet("J. Nessun Echo: la questione non ha lasciato un segno storico.")

	# K. Ripple: the closed Confluence pushes pressure onto its linked Tensions.
	for target in template["ripple"]["targets"]:
		_apply(
			applied,
			Effect.make(
				"ADJUST_TENSION",
				"tension",
				str(target),
				{"delta": int(template["ripple"]["delta"])},
				source
			)
		)
		log.bullet("K. Ripple: %s +%d" % [_tension_name(str(target)), int(template["ripple"]["delta"])])
	tensions.fire_omens(source)

	world["tensions"][tension_id]["resolved_count"] = (
		int(world["tensions"][tension_id]["resolved_count"]) + 1
	)
	world["confluence_count"] = int(world["confluence_count"]) + 1
	world["forced_confluence"] = null
	# Segnata **qui** e non all'apertura: una domanda vale come posta quando e'
	# stata messa ai voti davvero. Una Confluence annullata perche' nessuna
	# proposta era disponibile non consuma niente (D-061).
	_mark_asked(tension_id, str(current["question_id"]))

	result["echo_created"] = echo_created
	result["confluence_id"] = str(current["confluence_id"])
	result["tension_id"] = tension_id
	result["proponent"] = str(current["proponent"])
	result["proposition_id"] = str(current["proposition_id"])
	result["question_id"] = str(current["question_id"])
	# What actually landed, by id. The log has printed this line since 0.0; the
	# result carries it too so a front-end can show the table what it just did
	# without re-deriving which pool applied - which would be the resolution
	# order restated somewhere it could quietly fall out of step.
	result["consequence_ids"] = consequence_ids.duplicate()
	result["effect_ids"] = applied.map(func(e: Dictionary) -> String: return str(e["effect_id"]))
	current["step"] = "CLOSED"
	current["result"] = result
	step_changed.emit("RESOLVED", current)
	current = {}
	return result


## §12.3: on Failure the proponent loses everything committed and each opposer
## keeps one card of their choice. On any success everything is discarded unless
## the card's own rule says otherwise.
func _dispose_assets(
	applied: Array, result: Dictionary, outcome: String, recovery: Dictionary, source: Dictionary
) -> void:
	var failure: bool = outcome == ConfluenceResolution.FAILURE
	for entity_id in current["commits"]:
		var committed: Array = current["commits"][entity_id]
		var kept: String = ""
		if failure and _stance_of(str(entity_id)) == "OPPOSE" and not committed.is_empty():
			kept = str(recovery.get(entity_id, ""))
			if not committed.has(kept) or _retain_rule(kept) == "ALWAYS_DISCARD":
				kept = _default_recovery(committed)
		for asset_id in committed:
			if str(asset_id) == kept:
				kept = ""  # only one copy is recovered
				continue
			if _keeps_card(str(asset_id), failure):
				continue
			_apply(
				applied,
				Effect.make(
					"REMOVE_ASSET",
					"entity",
					str(entity_id),
					{"asset_id": str(asset_id), "destination": "DISCARD"},
					source
				)
			)
	log.bullet("I. Gli Asset impegnati sono stati risolti secondo le loro regole.")


func _keeps_card(asset_id: String, failure: bool) -> bool:
	match _retain_rule(asset_id):
		"RETAIN":
			return true
		"RETAIN_ON_SUCCESS":
			return not failure
	return false


func _retain_rule(asset_id: String) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return "DISCARD" if asset == null else str(asset["discard_or_retain_rule"])


func _default_recovery(committed: Array) -> String:
	# Deterministic fallback: the strongest card that is allowed to come back.
	var best: String = ""
	var best_strength: int = -1
	for asset_id in committed:
		if _retain_rule(str(asset_id)) == "ALWAYS_DISCARD":
			continue
		var asset: Variant = data.assets.get(str(asset_id))
		var strength: int = 0 if asset == null else int(asset["strength"])
		if strength > best_strength or (strength == best_strength and str(asset_id) < best):
			best = str(asset_id)
			best_strength = strength
	return best


func _apply_scar(applied: Array, consequence_id: String, source: Dictionary) -> void:
	if not compiler.creates_scar(consequence_id):
		return
	var consequence: Dictionary = data.consequences[consequence_id]
	var scar: Dictionary = consequence.get("scar", {})
	if scar.is_empty():
		push_warning("ConfluenceController: '%s' creates_scar without a scar block" % consequence_id)
		return
	var scar_id: String = Ids.scar_id(world["scars"].size() + 1)
	_apply(
		applied,
		Effect.make(
			"ADD_SCAR",
			"scar",
			scar_id,
			{
				"scar_id": scar_id,
				# The scar block is authored data like any other, so it may name
				# $region_focus rather than a Region that has to exist for ever.
				"region_id": compiler.substitute_string(str(scar["region_id"]), effect_context()),
				"tag": str(scar["tag"]),
				"description": say(str(scar["description"])),
			},
			source
		)
	)
	log.bullet("Scar: %s" % str(scar["description"]))


func _apply(applied: Array, effect: Dictionary) -> void:
	if effect.is_empty():
		return
	var stored: Dictionary = applier.apply(effect)
	if stored.is_empty():
		push_error("ConfluenceController: %s" % applier.last_error)
		return
	applied.append(stored)


func _log_commitments() -> void:
	log.bullet("E. Rivelazione simultanea degli impegni:")
	for entity_id in world["turn_order"]:
		if not current["commits"].has(entity_id):
			continue
		var committed: Array = current["commits"][entity_id]
		var titles: Array = []
		for asset_id in committed:
			titles.append(_asset_title(str(asset_id)))
		log.line(
			"      %s (%s): %s"
			% [
				_name(str(entity_id)),
				_stance_of(str(entity_id)),
				"nessun Asset" if titles.is_empty() else ", ".join(PackedStringArray(titles)),
			]
		)


func _stance_of(entity_id: String) -> String:
	if entity_id == str(current["proponent"]):
		return "PROPONENT"
	return str(current["stances"].get(entity_id, {}).get("stance", "ABSTAIN"))


func _proposition() -> Dictionary:
	var template: Dictionary = data.confluence_templates[str(current["template_id"])]
	for proposition in template["propositions"]:
		if str(proposition["id"]) == str(current["proposition_id"]):
			return proposition
	return {}


## The slots an authored Effect may name, resolved to *ids* against the world as
## it stands right now.
##
## Public, because a decider has to be able to score a proposition before voting
## on it, and it can only do that if it resolves $region_focus the same way K
## will. Reading these bindings off a second table would let the policy's idea of
## the proposition drift from the Effects the Council actually applies - which is
## how the table ended up abstaining on 96% of propositions (D-034).
func effect_context() -> Dictionary:
	if current.is_empty():
		return {}
	return {
		"proponent": str(current["proponent"]),
		"tension": str(current["tension_id"]),
		"confluence": str(current["confluence_id"]),
		# The Region this Tension is about right now, so a Consequence can say
		# "the place we are arguing over" instead of naming one for ever. Same
		# rule that picks $the_region for the narrative text.
		"region_focus": narrative.focus_region(str(current["tension_id"])),
		# And the seat it is being asked against, and the seat of power - the two
		# other things a Consequence usually means when it names a proper noun.
		"rival": narrative.rival_id(
			narrative.focus_region(str(current["tension_id"])), str(current["proponent"])
		),
		"capital": narrative.capital_region(),
		"adjacent": narrative.adjacent_to(narrative.focus_region(str(current["tension_id"]))),
		"rival_seat": narrative.seat_of(
			narrative.rival_id(
				narrative.focus_region(str(current["tension_id"])), str(current["proponent"])
			),
			narrative.focus_region(str(current["tension_id"]))
		),
	}


## Fill the $slots of an authored sentence from the running Confluence. The
## 0.1 Confluence Board calls this too: what the table reads and what the log
## records have to be the same string.
func say(text: String) -> String:
	return narrative.fill(text, current.get("text_bindings", {}))


func _question_text(template: Dictionary, question_id: String) -> String:
	for question in template["questions"]:
		if str(question["id"]) == question_id:
			return str(question["text"])
	return question_id


func _tension_name(tension_id: String) -> String:
	return str(data.tensions[tension_id]["title"])


func _asset_title(asset_id: String) -> String:
	var asset: Variant = data.assets.get(asset_id)
	return asset_id if asset == null else str(asset["title"])


func _name(entity_id: String) -> String:
	var entity: Variant = data.entities.get(entity_id)
	return entity_id if entity == null else str(service.name_of(entity_id))
