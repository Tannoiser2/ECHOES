extends RefCounted
## Il telaio dei segni con un dente (ISSUES 24, Fase 2 - D-104).
##
## Una tag_rule è un dato d'autore: un segno che, finché sta sul mondo, su una
## Regione, su un'Entità o su una relazione, piega una meccanica dichiarata.
## Questo helper è l'unico punto che sa leggere le regole; i quattro ganci nel
## motore (INFLUENCE, World Factor, movimento, relazioni) gli chiedono solo il
## risultato. Con zero regole attive ogni funzione restituisce il suo neutro,
## e il motore si comporta esattamente come prima: il telaio si misura vuoto,
## i denti si accendono uno alla volta.

const LEVEL_ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]


## Le regole attive di un tipo, nel loro ordine di id: deterministico come
## tutto il resto (§18.3).
static func active(data, kind: String, chronicle_id: String) -> Array:
	if data == null:
		return []
	var out: Array = []
	var ids: Array = data.tag_rules.keys()
	ids.sort()
	for id in ids:
		var rule: Dictionary = data.tag_rules[id]
		if not bool(rule.get("active", false)):
			continue
		if str(rule.get("kind", "")) != kind:
			continue
		var wanted: String = str(rule.get("chronicle_id", ""))
		if wanted != "" and wanted != chronicle_id:
			continue
		out.append(rule)
	return out


## ACTION_MODIFIER: di quanto il segno piega un'azione, e con che titoli.
## REGION vale se il segno sta su una Regione dove chi agisce ha presenza.
static func action_bonus(
	data, world: Dictionary, entity_id: String, template: String, tension_id: String
) -> Dictionary:
	var delta: int = 0
	var titles: Array = []
	for rule in active(data, "ACTION_MODIFIER", str(world.get("chronicle_id", ""))):
		if str(rule.get("template", "")) != template:
			continue
		var wanted_tension: String = str(rule.get("tension_id", ""))
		if wanted_tension != "" and wanted_tension != tension_id:
			continue
		if _sign_present(world, rule["when"], {"entity_id": entity_id}):
			delta += int(rule.get("delta", 0))
			titles.append(str(rule["title"]))
	return {"delta": delta, "titles": titles}


## COUNCIL_MODIFIER: di quanto i segni pesano sul World Factor del Consiglio.
## Al tavolo del Consiglio gli scope si leggono così: GLOBAL è il mondo,
## ENTITY è il proponente (la fama precede chi propone), REGION è una Regione
## qualsiasi che porti il segno (se da qualche parte si muore di fame, la fame
## siede al tavolo).
static func council_world_factor(
	data, world: Dictionary, tension_id: String, proponent_id: String
) -> Dictionary:
	var delta: int = 0
	var titles: Array = []
	for rule in active(data, "COUNCIL_MODIFIER", str(world.get("chronicle_id", ""))):
		var wanted_tension: String = str(rule.get("tension_id", ""))
		if wanted_tension != "" and wanted_tension != tension_id:
			continue
		var when: Dictionary = rule["when"]
		var present: bool = false
		if str(when.get("scope", "")) == "REGION":
			present = _any_region_has(world, str(when.get("tag", "")))
		else:
			present = _sign_present(world, when, {"entity_id": proponent_id})
		if present:
			delta += int(rule.get("world_factor_delta", 0))
			titles.append(str(rule["title"]))
	return {"delta": delta, "titles": titles}


## GATE: "" (nessuna porta), "BLOCK" o "ALLOW" per l'ingresso in una Regione.
## BLOCK vince su ALLOW: una porta sbarrata resta sbarrata.
static func movement_gate(data, world: Dictionary, region_id: String) -> String:
	var verdict: String = ""
	for rule in active(data, "GATE", str(world.get("chronicle_id", ""))):
		var when: Dictionary = rule["when"]
		if str(when.get("scope", "")) != "REGION":
			continue
		if not _region_has(world, region_id, str(when.get("tag", ""))):
			continue
		var movement: String = str(rule.get("movement", ""))
		if movement == "BLOCK":
			return "BLOCK"
		if movement == "ALLOW":
			verdict = "ALLOW"
	return verdict


## RELATION_CAP: il tetto più basso fra le regole accese per questa coppia,
## o "" se nessuna morde.
static func relation_cap(data, world: Dictionary, relation_key: String) -> String:
	var cap: String = ""
	for rule in active(data, "RELATION_CAP", str(world.get("chronicle_id", ""))):
		if not _sign_present(world, rule["when"], {"relation_key": relation_key}):
			continue
		var level: String = str(rule.get("max_level", ""))
		if level == "":
			continue
		if cap == "" or LEVEL_ORDER.find(level) < LEVEL_ORDER.find(cap):
			cap = level
	return cap


static func clamp_level(level: String, cap: String) -> String:
	if cap == "":
		return level
	if LEVEL_ORDER.find(level) > LEVEL_ORDER.find(cap):
		return cap
	return level


static func _sign_present(world: Dictionary, when: Dictionary, context: Dictionary) -> bool:
	var tag: String = str(when.get("tag", ""))
	match str(when.get("scope", "")):
		"GLOBAL":
			return (world.get("global_tags", []) as Array).has(tag)
		"ENTITY":
			var entity: Variant = world.get("entities", {}).get(str(context.get("entity_id", "")))
			return entity != null and (entity["tags"] as Array).has(tag)
		"REGION":
			var entity_id: String = str(context.get("entity_id", ""))
			var holder: Variant = world.get("entities", {}).get(entity_id)
			if holder == null:
				return false
			for region_id in holder["presence"]:
				if _region_has(world, str(region_id), tag):
					return true
			return false
		"RELATION":
			var relation: Variant = world.get("relations", {}).get(str(context.get("relation_key", "")))
			return relation != null and (relation["tags"] as Array).has(tag)
	return false


static func _region_has(world: Dictionary, region_id: String, tag: String) -> bool:
	var region: Variant = world.get("regions", {}).get(region_id)
	return region != null and (region["tags"] as Array).has(tag)


static func _any_region_has(world: Dictionary, tag: String) -> bool:
	for region_id in world.get("regions", {}):
		if _region_has(world, str(region_id), tag):
			return true
	return false
