extends Node
## Autoload wrapper around DataSet (§5).
##
## Boot validation lives here: if res://data does not satisfy the generated
## schema definitions, the project refuses to start a Chronicle and reports
## every error at once rather than crashing later.

const DataSet := preload("res://scripts/core/data_set.gd")

signal validation_finished(ok: bool, errors: PackedStringArray)

var data: RefCounted = null
var is_valid: bool = false


func _ready() -> void:
	load_data()


func load_data(root: String = "res://data") -> bool:
	data = DataSet.new()
	is_valid = data.load_from(root)
	if not is_valid:
		for error in data.errors:
			push_error("DataRegistry: %s" % error)
	validation_finished.emit(is_valid, data.errors)
	return is_valid


func errors() -> PackedStringArray:
	return data.errors if data != null else PackedStringArray()
