extends RefCounted
## Compiles Consequences and Echo-card hooks into Effects (§6.3, §16).
##
## Authored data holds Effect *specs* with $variables ($proponent, $tension,
## $actor...). This resolves them against the running context and hands back
## real Effects; nothing else in the codebase turns data into mutations.

const Effect := preload("res://scripts/core/effect.gd")
const Ids := preload("res://scripts/core/ids.gd")

var data: RefCounted


func _init(p_data: RefCounted) -> void:
	data = p_data


## Compile one Consequence id into its Effects.
func compile(consequence_id: String, context: Dictionary, source: Dictionary) -> Array:
	var consequence: Variant = data.consequences.get(consequence_id)
	if consequence == null:
		push_error("ConsequenceCompiler: unknown consequence '%s'" % consequence_id)
		return []
	var effects: Array = []
	for spec in consequence["effects"]:
		var effect: Dictionary = compile_spec(spec, context, source)
		if not effect.is_empty():
			effects.append(effect)
	return effects


func compile_many(consequence_ids: Array, context: Dictionary, source: Dictionary) -> Array:
	var effects: Array = []
	for consequence_id in consequence_ids:
		effects.append_array(compile(str(consequence_id), context, source))
	return effects


## Compile a bare Effect spec (Echo-card EFFECT hooks, Asset on_commit_effects,
## Condition clauses).
func compile_spec(spec: Dictionary, context: Dictionary, source: Dictionary) -> Dictionary:
	var target: Dictionary = spec["target"]
	var target_id: String = _substitute_string(str(target["id"]), context)
	if target_id.begins_with("$"):
		push_error("ConsequenceCompiler: unresolved variable '%s'" % target_id)
		return {}
	var payload: Dictionary = _substitute(spec.get("payload", {}), context)
	return Effect.make(str(spec["type"]), str(target["kind"]), target_id, payload, source)


## Does a Consequence write a Scar? Scars only exist where the data says so (§12.4).
func creates_scar(consequence_id: String) -> bool:
	var consequence: Variant = data.consequences.get(consequence_id)
	return consequence != null and bool(consequence.get("creates_scar", false))


func _substitute(value: Variant, context: Dictionary) -> Variant:
	match typeof(value):
		TYPE_STRING:
			return _substitute_string(str(value), context)
		TYPE_DICTIONARY:
			var out: Dictionary = {}
			for key in (value as Dictionary):
				out[key] = _substitute((value as Dictionary)[key], context)
			return out
		TYPE_ARRAY:
			var list: Array = []
			for item in (value as Array):
				list.append(_substitute(item, context))
			return list
	return value


## Public: the Confluence controller resolves the authored Scar block with it,
## because a Scar may name $region_focus like any other authored target.
func substitute_string(value: String, context: Dictionary) -> String:
	return _substitute_string(value, context)


func _substitute_string(value: String, context: Dictionary) -> String:
	if not value.contains("$"):
		return value
	var out: String = value
	for key in context:
		out = out.replace("$%s" % key, str(context[key]))
	return out
