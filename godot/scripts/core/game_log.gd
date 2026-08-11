extends RefCounted
## Public log of the table (§16, §19.3).
##
## Everything a player would see or hear at the table goes here. Private
## information (veiled Tension values, secret Commits before reveal, private
## Region information) must never be written to it.

signal line_added(text: String)

var lines: PackedStringArray = PackedStringArray()
var echo_to_stdout: bool = false


func line(text: String) -> void:
	lines.append(text)
	if echo_to_stdout:
		print(text)
	line_added.emit(text)


func section(title: String) -> void:
	line("")
	line("== %s ==" % title)


func bullet(text: String) -> void:
	line("  - %s" % text)


func text() -> String:
	return "\n".join(Array(lines))
