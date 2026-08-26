extends RefCounted
## Effect construction helpers (spec v0.2 §6.3).
##
## An Effect is a plain Dictionary matching schema/effect.schema.json. Keeping it
## as data (rather than a typed object) means effect_log serialises and compares
## byte-for-byte with no conversion step, which is what §18.3 determinism needs.

const SchemaDefs := preload("res://scripts/core/schema_defs.gd")

## §6.3: an Echo or a Truth cannot be un-written. Undoing past one of these
## requires restoring a snapshot.
const IRREVERSIBLE: Array = ["CREATE_ECHO", "APPEND_TRUTH"]

## Which EffectType undoes which. Symmetric types invert themselves through
## inverse_payload; asymmetric ones name their counterpart. See DECISIONS D-002
## for why `inverse_type` is stored on the Effect rather than inferred.
const INVERSE_TYPE: Dictionary = {
	"ADJUST_TENSION": "ADJUST_TENSION",
	# La traccia del Calore (PZ-1): sale e scende su se stessa, col delta
	# davvero applicato nell'inverse_payload, come le Tensioni.
	"ADJUST_THEME_HEAT": "ADJUST_THEME_HEAT",
	"SET_TENSION_VISIBILITY": "SET_TENSION_VISIBILITY",
	"ADD_PRESENCE": "REMOVE_PRESENCE",
	"REMOVE_PRESENCE": "ADD_PRESENCE",
	"SET_CONTROL": "SET_CONTROL",
	"SET_REGION_TAG": "REMOVE_REGION_TAG",
	"REMOVE_REGION_TAG": "SET_REGION_TAG",
	"SET_GLOBAL_TAG": "REMOVE_GLOBAL_TAG",
	"REMOVE_GLOBAL_TAG": "SET_GLOBAL_TAG",
	"SET_RELATION": "SET_RELATION",
	"GRANT_ASSET": "REMOVE_ASSET",
	"REMOVE_ASSET": "GRANT_ASSET",
	"TRANSFER_ASSET": "TRANSFER_ASSET",
	"CREATE_CLAIM": "CONSUME_CLAIM",
	"CONSUME_CLAIM": "CREATE_CLAIM",
	"ADD_SCAR": "REMOVE_SCAR",
	"REMOVE_SCAR": "ADD_SCAR",
	"SET_ENTITY_TAG": "REMOVE_ENTITY_TAG",
	"REMOVE_ENTITY_TAG": "SET_ENTITY_TAG",
	"SET_ENTITY_ACTIVE": "SET_ENTITY_ACTIVE",
	# La terra che si costruisce (D-157). Alzare e abbattere sono l'uno
	# l'inverso dell'altro; salire di grado si inverte su se stesso, col grado
	# di prima nell'inverse_payload.
	"BUILD_STRUCTURE": "RAZE_STRUCTURE",
	"RAZE_STRUCTURE": "BUILD_STRUCTURE",
	"SET_STRUCTURE_GRADE": "SET_STRUCTURE_GRADE",
	# Una Pietra che passa di mano (D-305). Si inverte su se stessa, col padrone
	# di prima nell'inverse_payload: e' la stessa forma di SET_CONTROL, e per la
	# stessa ragione — la Pietra resta dov'e', cambia di chi e'.
	"SET_STRUCTURE_OWNER": "SET_STRUCTURE_OWNER",
	# Il grafo che si riscrive (D-166). Chiudere e riaprire un varco sono
	# l'uno l'inverso dell'altro: e' l'unica cosa della mappa che cambia la
	# **forma** del mondo e non solo cosa ci sta sopra.
	"CLOSE_PASSAGE": "OPEN_PASSAGE",
	"OPEN_PASSAGE": "CLOSE_PASSAGE",
}


## Build an un-applied Effect. effect_id, inverse_type and inverse_payload are
## filled in by EffectApplier at apply() time, when the previous state is known.
static func make(
	p_type: String,
	target_kind: String,
	target_id: String,
	payload: Dictionary,
	p_source: Dictionary
) -> Dictionary:
	return {
		"effect_id": "",
		"type": p_type,
		"target": {"kind": target_kind, "id": target_id},
		"payload": payload.duplicate(true),
		"source": p_source.duplicate(true),
		"reversible": is_reversible(p_type),
	}


static func source(
	kind: String,
	id: String,
	actor: String,
	act: int,
	p_round: int,
	sequence: int
) -> Dictionary:
	var out: Dictionary = {
		"kind": kind,
		"id": id,
		"act": act,
		"round": p_round,
		"sequence": sequence,
	}
	if actor != "":
		out["actor"] = actor
	return out


static func is_reversible(p_type: String) -> bool:
	return not IRREVERSIBLE.has(p_type)


static func is_known_type(p_type: String) -> bool:
	return SchemaDefs.EFFECT_TYPES.has(p_type)


## One-line rendering for the public log and the Developer Mode effect view.
static func describe(effect: Dictionary) -> String:
	var src: Dictionary = effect.get("source", {})
	var actor: String = str(src.get("actor", src.get("kind", "?")))
	return "[%s] %s %s:%s %s (by %s, A%d R%d)" % [
		effect.get("effect_id", "EFF_??????"),
		effect.get("type", "?"),
		effect.get("target", {}).get("kind", "?"),
		effect.get("target", {}).get("id", "?"),
		JSON.stringify(effect.get("payload", {})),
		actor,
		int(src.get("act", 0)),
		int(src.get("round", 0)),
	]
