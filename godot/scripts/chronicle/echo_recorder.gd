extends RefCounted
## Echo Check and the Truth register (§12.4, §16).
##
## An Echo is written when the table produced something worth remembering:
##   - a Decisive Success, or
##   - a Success where both fronts spent heavily (S + O >= 6), or
##   - a Failure that cost the opposition dearly (O >= 6) - a memorable defeat
##     is still history.
##
## CREATE_ECHO and APPEND_TRUTH are irreversible Effects (§6.3).

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")
const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

const HEAVY_COMMITMENT: int = 6

var world: Dictionary
var data: RefCounted
var applier: RefCounted
var log: RefCounted
## Set by ConfluenceController: the Truth register keeps the *filled* sentence,
## because a $slot left in the permanent record would be a bug nobody can undo.
var narrative: RefCounted = null


func _init(p_world: Dictionary, p_data: RefCounted, p_applier: RefCounted, p_log: RefCounted) -> void:
	world = p_world
	data = p_data
	applier = p_applier
	log = p_log


func should_record(result: Dictionary) -> bool:
	var outcome: String = str(result["outcome"])
	var support: int = int(result["support_total"])
	var oppose: int = int(result["oppose_total"])
	if outcome == ConfluenceResolution.DECISIVE:
		return true
	if ConfluenceResolution.is_success(outcome) and support + oppose >= HEAVY_COMMITMENT:
		return true
	if outcome == ConfluenceResolution.FAILURE and oppose >= HEAVY_COMMITMENT:
		return true
	return false


## Writes the Echo and its Truth record. Returns the Effects applied.
func record(context: Dictionary, result: Dictionary, effect_ids: Array, source: Dictionary) -> Array:
	var echo_id: String = Ids.echo_id(world["echo_log"].size() + 1)
	var template: Dictionary = data.confluence_templates[str(context["template_id"])]
	var summary: String = _summary(template, context, result)

	var echo: Dictionary = {
		"echo_id": echo_id,
		"title": str(template.get("echo_title_template", template["title"])),
		"summary": summary,
		"act": int(world["act"]),
		"round": int(world["round"]),
		"participants": (context["participants"] as Array).duplicate(),
		"effect_ids": effect_ids.duplicate(),
		"tension_id": str(context["tension_id"]),
		"outcome": str(result["outcome"]),
	}

	var applied: Array = []
	var echo_effect: Dictionary = applier.apply(
		Effect.make("CREATE_ECHO", "echo", echo_id, echo, source)
	)
	if not echo_effect.is_empty():
		applied.append(echo_effect)

	var truth_id: String = Ids.truth_id(world["truth_log"].size() + 1)
	var truth: Dictionary = {
		"truth_id": truth_id,
		"text": "Anno %d, Atto %d: %s" % [int(world["year"]), int(world["act"]), summary],
		"act": int(world["act"]),
		"round": int(world["round"]),
		"echo_id": echo_id,
	}
	var truth_effect: Dictionary = applier.apply(
		Effect.make("APPEND_TRUTH", "truth", truth_id, truth, source)
	)
	if not truth_effect.is_empty():
		applied.append(truth_effect)

	log.bullet("Echo registrato [%s]: %s" % [echo_id, summary])
	log.bullet("Truth [%s] e ora immutabile." % truth_id)
	return applied


func _summary(template: Dictionary, context: Dictionary, result: Dictionary) -> String:
	var outcome: String = str(result["outcome"])
	var proposition_summary: String = ""
	for proposition in template["propositions"]:
		if str(proposition["id"]) != str(context.get("proposition_id", "")):
			continue
		# How a proposal falls reads nothing like how it triumphs, and the Truth
		# register is where a Chronicle gets reread. A band with no variant of its
		# own falls back to the single summary (D-032).
		var variants: Dictionary = proposition.get("echo_summaries", {})
		proposition_summary = str(
			variants.get(outcome, proposition.get("echo_summary", proposition["text"]))
		)
		break
	if proposition_summary == "":
		proposition_summary = str(template["title"])
	if narrative != null:
		proposition_summary = narrative.fill(proposition_summary, context.get("text_bindings", {}))
	if outcome == ConfluenceResolution.FAILURE:
		return "%s La proposta cadde (S%d O%d M%d)." % [
			proposition_summary,
			int(result["support_total"]),
			int(result["oppose_total"]),
			int(result["margin"]),
		]
	return "%s (S%d O%d M%d)." % [
		proposition_summary,
		int(result["support_total"]),
		int(result["oppose_total"]),
		int(result["margin"]),
	]
