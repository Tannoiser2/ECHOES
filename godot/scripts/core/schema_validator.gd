extends RefCounted
## Runtime data validation driven by the generated schema_defs.gd (§17).
##
## This never restates a rule: every constraint it enforces was generated from
## the JSON Schemas in /schema. tools/validate_data.py does the same job with
## the full JSON Schema engine; this is the boot-time guard inside Godot.

const SchemaDefs := preload("res://scripts/core/schema_defs.gd")

static var _regex_cache: Dictionary = {}


## Validate a whole collection document ({schema_id, version, items}).
static func validate_document(document: Dictionary, where: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not document.has("schema_id"):
		errors.append("%s: missing 'schema_id'" % where)
		return errors
	var schema_id: String = str(document["schema_id"])
	if not SchemaDefs.COLLECTION_SCHEMA_IDS.has(schema_id):
		errors.append("%s: unknown schema_id '%s'" % [where, schema_id])
		return errors
	if not document.has("items") or typeof(document["items"]) != TYPE_ARRAY:
		errors.append("%s: 'items' must be an array" % where)
		return errors

	var definition: Dictionary = SchemaDefs.DEFS[schema_id]
	var index: int = 0
	for item in document["items"]:
		var label: String = "%s[%d]" % [where, index]
		if typeof(item) == TYPE_DICTIONARY and (item as Dictionary).has("id"):
			label = "%s[%s]" % [where, item["id"]]
		errors.append_array(validate_item(item, definition, label))
		index += 1
	return errors


static func validate_item(item: Variant, definition: Dictionary, where: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if typeof(item) != TYPE_DICTIONARY:
		errors.append("%s: expected an object" % where)
		return errors
	var dict: Dictionary = item

	for required in definition.get("required", []):
		if not dict.has(required):
			errors.append("%s: missing required field '%s'" % [where, required])

	var properties: Dictionary = definition.get("properties", {})
	if not bool(definition.get("additional_properties", true)):
		for key in dict.keys():
			if not properties.has(key):
				errors.append("%s: unexpected field '%s'" % [where, key])

	for key in dict.keys():
		if not properties.has(key):
			continue
		errors.append_array(_check_value(dict[key], properties[key], "%s.%s" % [where, key]))
	return errors


static func _check_value(value: Variant, rule: Dictionary, where: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var expected: String = str(rule.get("type", "Variant"))

	if value == null:
		if not bool(rule.get("nullable", false)):
			errors.append("%s: null is not allowed" % where)
		return errors

	if not _type_matches(value, expected):
		errors.append("%s: expected %s, got %s" % [where, expected, type_string(typeof(value))])
		return errors

	if rule.has("enum") and not (rule["enum"] as Array).has(value):
		errors.append("%s: '%s' is not one of %s" % [where, value, rule["enum"]])
	if rule.has("pattern") and typeof(value) == TYPE_STRING:
		if not _matches(str(value), str(rule["pattern"])):
			errors.append("%s: '%s' does not match %s" % [where, value, rule["pattern"]])
	if rule.has("min") and _as_number(value) < float(rule["min"]):
		errors.append("%s: %s is below minimum %s" % [where, value, rule["min"]])
	if rule.has("max") and _as_number(value) > float(rule["max"]):
		errors.append("%s: %s is above maximum %s" % [where, value, rule["max"]])
	if rule.has("min_length") and typeof(value) == TYPE_STRING:
		if str(value).length() < int(rule["min_length"]):
			errors.append("%s: string shorter than %d" % [where, int(rule["min_length"])])
	if typeof(value) == TYPE_ARRAY:
		var array: Array = value
		if rule.has("min_items") and array.size() < int(rule["min_items"]):
			errors.append("%s: needs at least %d entries" % [where, int(rule["min_items"])])
		if rule.has("max_items") and array.size() > int(rule["max_items"]):
			errors.append("%s: allows at most %d entries" % [where, int(rule["max_items"])])
		if rule.has("element"):
			for i in range(array.size()):
				errors.append_array(
					_check_value(array[i], rule["element"], "%s[%d]" % [where, i])
				)
	return errors


static func _type_matches(value: Variant, expected: String) -> bool:
	match expected:
		"Variant":
			return true
		"String":
			return typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME
		"int":
			# A JSON integer can arrive as a float; accept it when it is integral.
			if typeof(value) == TYPE_INT:
				return true
			return typeof(value) == TYPE_FLOAT and is_equal_approx(float(value), roundf(float(value)))
		"float":
			return typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT
		"bool":
			return typeof(value) == TYPE_BOOL
		"Array":
			return typeof(value) == TYPE_ARRAY
		"Dictionary":
			return typeof(value) == TYPE_DICTIONARY
	return true


static func _as_number(value: Variant) -> float:
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value)
	return 0.0


static func _matches(value: String, pattern: String) -> bool:
	if not _regex_cache.has(pattern):
		var regex := RegEx.new()
		if regex.compile(pattern) != OK:
			# An uncompilable pattern is a generator bug, not a data bug; do not
			# fail the data because of it.
			_regex_cache[pattern] = null
		else:
			_regex_cache[pattern] = regex
	var cached: Variant = _regex_cache[pattern]
	if cached == null:
		return true
	return (cached as RegEx).search(value) != null
