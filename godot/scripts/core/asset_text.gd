extends RefCounted
## What a card does, in one line, said the same way everywhere.
##
## The authored `rules_text` is the card's voice - it explains and it flavours.
## This is the mechanical summary underneath it: what the modifier gives, what
## happens to the card afterwards, and what committing it costs the world. It is
## built from the fields the resolver actually reads, so a card cannot say one
## thing and do another (D-042).
##
## Shared because both front-ends need it and neither should own it: the
## terminal prints it beside a commit option, the browser puts it in the card's
## tooltip. Pure functions over an Asset dictionary - no world, no session.

const ConfluenceResolution := preload("res://scripts/confluence/confluence_resolution.gd")

## The Effect types an `on_commit_effects` entry can carry, in the words a player
## would use. Anything not listed still reports honestly, by type.
const COSTS: Dictionary = {
	"ADJUST_TENSION": "la domanda in gioco sale",
	"ADD_PRESENCE": "il tuo rivale entra dove si discute",
	"REMOVE_PRESENCE": "perdi la tua presenza dove si discute",
	"SET_TENSION_VISIBILITY": "la domanda si apre a tutti",
}

const DISPOSITION: Dictionary = {
	"DISCARD": "si scarta se la impegni",
	"ALWAYS_DISCARD": "si scarta comunque",
	"RETAIN": "non si scarta mai",
	"RETAIN_ON_SUCCESS": "torna in mano se la proposta passa",
}


## The mechanical half, comma-separated: bonus, disposition, cost.
static func note(asset: Dictionary) -> String:
	var parts: Array = []
	var bonus: String = modifier_note(asset)
	if bonus != "":
		parts.append(bonus)
	parts.append(str(DISPOSITION.get(str(asset["discard_or_retain_rule"]), "")))
	var cost: String = cost_note(asset)
	if cost != "":
		parts.append("costa: %s" % cost)
	return " · ".join(PackedStringArray(parts))


static func modifier_note(asset: Dictionary) -> String:
	var modifier: Dictionary = asset.get("confluence_modifier", {"kind": "NONE", "value": 0})
	var value: int = int(modifier.get("value", 0))
	match str(modifier.get("kind", "NONE")):
		"FLAT_BONUS":
			return "+%d sempre" % value
		"RELEVANT_BONUS":
			return "+%d sul suo tema" % value
		"OPPOSE_BONUS":
			return "+%d se ti opponi" % value
	return ""


static func cost_note(asset: Dictionary) -> String:
	var said: Array = []
	for effect in asset.get("on_commit_effects", []):
		var kind: String = str((effect as Dictionary)["type"])
		var text: String = str(COSTS.get(kind, kind.to_lower()))
		if not said.has(text):
			said.append(text)
	return ", ".join(PackedStringArray(said))


## What this card adds to the Support front of a Council on this Tension - the
## resolver's own arithmetic, not a copy of it.
static func value_on(asset: Dictionary, relevant_families: Array) -> int:
	return ConfluenceResolution.asset_value(asset, relevant_families, "SUPPORT")


## Everything the card would say if it had room: what it is, what it does, and
## the sentence its author wrote.
static func tooltip(asset: Dictionary) -> String:
	var lines: Array = ["%s — %s, forza %d" % [
		str(asset["title"]), str(asset["family"]).to_lower(), int(asset["strength"]),
	]]
	lines.append(note(asset))
	var rules: String = str(asset.get("rules_text", ""))
	if rules != "":
		lines.append("")
		lines.append(rules)
	return "\n".join(PackedStringArray(lines))
