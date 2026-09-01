extends RefCounted
## Turns an applied Effect into one spoken chronicle line (ISSUES 22, Fase 1).
##
## The world was already changing under the Consequences and the act Echo
## cards; it was just changing silently — in the played chronicle at seed
## 15308 the crown lost the Valle Verde and no line said so. Every sentence
## here uses table names, never ids. Returns "" for Effects that must not be
## narrated: no-ops (nothing actually moved), bookkeeping (`function:` tags,
## Echo/Truth records that have their own lines), and the Scar, which already
## speaks for itself.

const SignLabels := preload("res://scripts/core/sign_labels.gd")

const VISIBILITY_SAID: Dictionary = {
	"OPEN": "%s non è più velata: il suo numero è sul tavolo.",
	"VEILED": "%s torna velata.",
	"SECRET": "%s scompare dalla vista del tavolo.",
}


static func narrate(effect: Dictionary, data) -> String:
	if bool(effect.get("inverse_payload", {}).get("noop", false)):
		return ""
	var target_id: String = str(effect.get("target", {}).get("id", ""))
	var payload: Dictionary = effect.get("payload", {})
	match str(effect.get("type", "")):
		"ADJUST_TENSION":
			# The inverse stores the delta that undoes the change, so the delta
			# that really happened (clamps included) is its negation.
			var applied: int = -int(effect.get("inverse_payload", {}).get("delta", 0))
			if applied == 0:
				return ""
			var verb: String = "sale" if applied > 0 else "scende"
			return "%s %s di %d." % [_tension(target_id, data), verb, absi(applied)]
		"ADJUST_THEME_HEAT":
			# Stessa regola delle Tensioni: si narra il delta davvero applicato,
			# tetto compreso, che e' la negazione dell'inverso.
			var moved: int = -int(effect.get("inverse_payload", {}).get("delta", 0))
			if moved == 0:
				return ""
			if moved > 0:
				return "Il Tema %s si scalda di %d." % [_theme(target_id, data), moved]
			return "Il Tema %s si raffredda." % _theme(target_id, data)
		"SET_TENSION_VISIBILITY":
			var visibility: String = str(payload.get("visibility", ""))
			if not VISIBILITY_SAID.has(visibility):
				return ""
			return str(VISIBILITY_SAID[visibility]) % _tension(target_id, data)
		"ADD_PRESENCE":
			return "%s mette radici in %s." % [
				_entity(target_id, data), _region(str(payload.get("region_id", "")), data)
			]
		"REMOVE_PRESENCE":
			return "%s perde la presenza in %s." % [
				_entity(target_id, data), _region(str(payload.get("region_id", "")), data)
			]
		"SET_CONTROL":
			var next: Variant = payload.get("entity_id", null)
			var before: Variant = effect.get("inverse_payload", {}).get("entity_id", null)
			if next == null and before == null:
				return ""
			if next == null:
				return "%s non risponde più a %s." % [
					_region(target_id, data), _entity(str(before), data)
				]
			return "%s passa sotto il controllo di %s." % [
				_region(target_id, data), _entity(str(next), data)
			]
		# **Le Pietre e le strade parlano** (D-292). Erano gli unici cambiamenti
		# della mappa che il verbale non diceva: al Consiglio si comprava
		# «Costruisci 1 Pietra: Granaio», la Pietra si alzava davvero, e sul
		# tavolo non restava una riga che lo raccontasse. Il piu' fisico di
		# tutti i gesti era il piu' muto.
		"BUILD_STRUCTURE":
			var built: String = SignLabels.grade_name(
				str(payload.get("structure_type", "")), int(payload.get("grade", 1)), data
			)
			if built == "":
				return ""
			return "In %s si alza: %s." % [_region(target_id, data), built]
		"RAZE_STRUCTURE":
			var razed: String = SignLabels.grade_name(
				str(payload.get("structure_type", "")),
				int(effect.get("inverse_payload", {}).get("grade", 1)), data
			)
			if razed == "":
				return ""
			return "In %s non resta niente di: %s." % [_region(target_id, data), razed]
		"SET_STRUCTURE_OWNER":
			# Una Pietra che cambia padrone (D-305): al tavolo si sposta il
			# segnalino della casa sotto il Granaio, e il verbale lo dice.
			var passed: String = SignLabels.grade_name(
				str(payload.get("structure_type", "")), 1, data
			)
			if passed == "":
				return ""
			var to_whom: Variant = payload.get("entity_id", null)
			if to_whom == null:
				return "In %s non e' piu' di nessuno: %s." % [_region(target_id, data), passed]
			return "In %s passa a %s: %s." % [
				_region(target_id, data), _entity(str(to_whom), data), passed
			]
		"SET_STRUCTURE_GRADE":
			var type_id: String = str(payload.get("structure_type", ""))
			var was: int = int(effect.get("inverse_payload", {}).get("grade", 0))
			var now: int = int(payload.get("grade", 0))
			if was == 0 or now == was:
				return ""
			var name_now: String = SignLabels.grade_name(type_id, now, data)
			if name_now == "":
				return ""
			return "In %s %s: %s." % [
				_region(target_id, data), "cresce" if now > was else "decade", name_now
			]
		"CLOSE_PASSAGE":
			return "Fra %s e %s non si passa piu'." % [
				_region(target_id, data), _region(str(payload.get("region_id", "")), data)
			]
		"OPEN_PASSAGE":
			return "Fra %s e %s si torna a passare." % [
				_region(target_id, data), _region(str(payload.get("region_id", "")), data)
			]
		"SET_REGION_TAG":
			return "Su %s resta un segno: «%s»." % [
				_region(target_id, data), SignLabels.label(str(payload.get("tag", "")), data)
			]
		"REMOVE_REGION_TAG":
			return "Da %s si cancella il segno «%s»." % [
				_region(target_id, data), SignLabels.label(str(payload.get("tag", "")), data)
			]
		"SET_GLOBAL_TAG":
			var tag: String = str(payload.get("tag", ""))
			return "Il mondo ricorda: «%s»." % SignLabels.label(tag, data)
		"REMOVE_GLOBAL_TAG":
			return "Il mondo dimentica: «%s»." % SignLabels.label(str(payload.get("tag", "")), data)
		"SET_ENTITY_TAG":
			return "%s porta ora il segno «%s»." % [
				_entity(target_id, data), SignLabels.label(str(payload.get("tag", "")), data)
			]
		"REMOVE_ENTITY_TAG":
			return "%s si libera del segno «%s»." % [
				_entity(target_id, data), SignLabels.label(str(payload.get("tag", "")), data)
			]
		"SET_RELATION":
			return _relation(target_id, payload, data)
		"GRANT_ASSET":
			return "%s riceve %s." % [
				_entity(target_id, data), _asset(str(payload.get("asset_id", "")), data)
			]
		"REMOVE_ASSET":
			return "%s perde %s." % [
				_entity(target_id, data), _asset(str(payload.get("asset_id", "")), data)
			]
		"TRANSFER_ASSET":
			return "%s passa da %s a %s." % [
				_asset(str(payload.get("asset_id", "")), data),
				_entity(str(payload.get("from", "")), data),
				_entity(str(payload.get("to", "")), data),
			]
		"CREATE_CLAIM":
			return "Nasce un diritto: %s rivendica il dominio %s." % [
				_entity(str(payload.get("entity_id", "")), data),
				str(payload.get("domain", "")),
			]
		"CONSUME_CLAIM":
			return "Un diritto si spegne: %s." % str(payload.get("claim_id", ""))
		"GRANT_CLAIM_TOKEN":
			return "%s prende un gettone di rivendicazione." % _entity(target_id, data)
		"SPEND_CLAIM_TOKEN":
			return "%s spende un gettone di rivendicazione." % _entity(target_id, data)
		"SET_ENTITY_ACTIVE":
			if bool(payload.get("active", true)):
				return "%s torna al tavolo." % _entity(target_id, data)
			return "%s lascia il tavolo." % _entity(target_id, data)
	# ADD_SCAR speaks through its own "Scar:" line; CREATE_ECHO and
	# APPEND_TRUTH through the Echo/Truth sections. Anything new stays silent
	# until it earns a sentence here.
	return ""


static func _relation(key: String, payload: Dictionary, data) -> String:
	var halves: PackedStringArray = key.split("|")
	if halves.size() != 2:
		return ""
	var pair: String = "fra %s e %s" % [
		_entity(halves[0], data), _entity(halves[1], data)
	]
	if payload.has("level"):
		return "La relazione %s è ora %s." % [pair, str(payload["level"])]
	if payload.has("add_tag"):
		return "Resta scritto, %s: «%s»." % [pair, str(payload["add_tag"])]
	if payload.has("remove_tag"):
		return "Si cancella, %s: «%s»." % [pair, str(payload["remove_tag"])]
	return ""


static func _entity(id: String, data) -> String:
	if data != null and data.entities.has(id):
		return str(data.entities[id]["name"])
	return id


static func _region(id: String, data) -> String:
	if data != null and data.regions.has(id):
		return str(data.regions[id]["name"])
	return id


static func _tension(id: String, data) -> String:
	if data != null and data.tensions.has(id):
		return str(data.tensions[id]["title"])
	return id


static func _theme(id: String, data) -> String:
	if data != null and data.themes.has(id):
		return str(data.themes[id]["title"])
	return id


static func _asset(id: String, data) -> String:
	if data != null and data.assets.has(id):
		return "«%s»" % str(data.assets[id]["title"])
	return id
