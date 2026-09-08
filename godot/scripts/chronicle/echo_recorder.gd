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
	# **La proposta sta sulla carta** (D-462): letta dal template crudo, il
	# riassunto della proposta non si trovava per le carte senza copia — e
	# cinquantatre' su sessanta non ce l'avevano.
	var template: Dictionary = data.confluence_template_for(str(context["tension_id"]))
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
	log.bullet("Truth [%s] è ora immutabile." % truth_id)
	return applied


func _summary(template: Dictionary, context: Dictionary, result: Dictionary) -> String:
	# Il registro tiene la domanda che ha vinto, o che nessuna e' arrivata al
	# mucchio (D-467). Niente proposta, niente dado: da D-472 e' l'unico giro.
	var winner: String = str(result.get("winner", ""))
	var count: String = "A%d B%d, mucchio %d" % [
		int(result["support_total"]), int(result["oppose_total"]), int(result.get("pile", 0)),
	]
	if winner == "":
		return "%s: nessuna delle due domande arrivo' al mucchio (%s)." % [str(template["title"]), count]
	var question_id: String = str(((context["sides"] as Dictionary)[winner] as Dictionary).get("question_id", ""))
	var asked: String = str(template["title"])
	for entry in template.get("questions", []) as Array:
		if str((entry as Dictionary).get("id", "")) == question_id:
			asked = str((entry as Dictionary).get("text", ""))
	if narrative != null:
		asked = narrative.fill(asked, context.get("text_bindings", {}))
	return "Il Consiglio rispose: %s (%s)." % [asked, count]
