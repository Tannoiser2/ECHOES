extends RefCounted
## Read-only queries over the WorldState (§5).
##
## Nothing here mutates. Anything that would change the world builds an Effect
## and hands it to EffectApplier instead.

const Ids := preload("res://scripts/core/ids.gd")
const TagRules := preload("res://scripts/world/tag_rules.gd")

const RELATION_ORDER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]

var world: Dictionary
var data: RefCounted


func _init(p_world: Dictionary, p_data: RefCounted) -> void:
	world = p_world
	data = p_data


# --- presence and regions --------------------------------------------------

## Who is sitting in this seat right now, and what they want.
##
## The id is the seat; the name and the Destiny are state, because between two
## Chronicles a century can pass and the person changes while the house does not
## (D-045). Everything that shows a name to a player goes through here, or it
## will show the founder's name to their great-granddaughter's table.
func name_of(entity_id: String) -> String:
	var entity: Variant = world["entities"].get(entity_id)
	if entity != null and str(entity.get("name", "")) != "":
		return str(entity["name"])
	var definition: Variant = data.entities.get(entity_id)
	return entity_id if definition == null else str(definition["name"])


func destiny_of(entity_id: String) -> String:
	var entity: Variant = world["entities"].get(entity_id)
	if entity != null and str(entity.get("destiny_id", "")) != "":
		return str(entity["destiny_id"])
	var definition: Variant = data.entities.get(entity_id)
	return "" if definition == null else str(definition["destiny_id"])


## How many handovers this seat has been through. 0 is the founder.
func generation_of(entity_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	return 0 if entity == null else int(entity.get("generation", 0))


func presence_count(entity_id: String, region_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return 0
	var count: int = 0
	for held in entity["presence"]:
		if str(held) == region_id:
			count += 1
	return count


func tokens_placed(entity_id: String) -> int:
	var entity: Variant = world["entities"].get(entity_id)
	return 0 if entity == null else (entity["presence"] as Array).size()


func regions_with_presence(entity_id: String) -> Array:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return []
	var unique: Array = []
	for region_id in entity["presence"]:
		if not unique.has(region_id):
			unique.append(region_id)
	unique.sort()
	return unique


func region_has_tag(region_id: String, tag: String) -> bool:
	var region: Variant = world["regions"].get(region_id)
	return region != null and (region["tags"] as Array).has(tag)


func regions_of_domain(domain: String) -> Array:
	var tag: String = Ids.domain_tag(domain)
	var out: Array = []
	for region_id in world["regions"]:
		if region_has_tag(str(region_id), tag):
			out.append(str(region_id))
	out.sort()
	return out


## INFLUENCE requires presence in a Region carrying the Tension's domain (§10).
func has_presence_in_domain(entity_id: String, domain: String) -> bool:
	for region_id in regions_of_domain(domain):
		if presence_count(entity_id, region_id) > 0:
			return true
	return false


func presence_in_domain(entity_id: String, domain: String) -> int:
	var total: int = 0
	for region_id in regions_of_domain(domain):
		total += presence_count(entity_id, region_id)
	return total


## MOVE legality (§10): the destination must border a Region you already hold,
## or be one of your Chronicle starting Regions.
func can_move_to(entity_id: String, region_id: String) -> bool:
	if not world["regions"].has(region_id):
		return false
	# Un Consiglio che ti ha cacciato tiene la porta chiusa fino a fine atto
	# (D-067): il tag lo mette la risoluzione, il giro d'atto lo toglie. Vince
	# anche sul diritto di rientrare in una Regione iniziale, che e' il punto -
	# salvo per la vita che ha smesso di avere un centro (D-130): il suo PASS
	# dichiarato attraversa anche la cacciata.
	var evicted: Variant = world["entities"].get(entity_id)
	if evicted != null and (evicted["tags"] as Array).has("evicted:%s" % region_id):
		if TagRules.eviction_pass(data, world, entity_id) == "":
			return false
	# ISSUES 24: un segno sulla Regione può sbarrare la porta o concederla
	# anche senza adiacenza. BLOCK vince, come la cacciata di D-067 - salvo
	# per chi porta un segno PASS (D-125): quello attraversa i BLOCK delle
	# regole, non la cacciata.
	var gate: String = TagRules.movement_gate(data, world, region_id, entity_id)
	if gate == "BLOCK":
		return false
	var definition: Variant = data.entities.get(entity_id)
	if definition != null and (definition["presence"] as Array).has(region_id):
		return true
	for held in regions_with_presence(entity_id):
		if neighbours_of(held).has(region_id):
			return true
	return gate == "ALLOW"


## I vicini di una Regione **adesso** (D-166). Il grafo e' stato del mondo: un
## passo franato toglie un arco, e da li' in poi quelle due Regioni non si
## toccano piu'. Senza il grafo nel mondo — un salvataggio vecchio, una sonda
## che non l'ha costruito — si ripiega sul dato, che e' la forma di partenza.
func neighbours_of(region_id: String) -> Array:
	var graph: Dictionary = world.get("adjacency", {})
	if graph.has(region_id):
		return graph[region_id]
	var definition: Variant = data.regions.get(region_id)
	return [] if definition == null else (definition["adjacency"] as Array)


## Se da questa Regione si arriva a tutte le altre in gioco. E' la guardia che
## impedisce a un varco chiuso di spezzare il mondo in due: una Regione
## irraggiungibile e' un Destino impossibile, e nessuna frase d'autore vale
## quel prezzo.
func every_region_reachable() -> bool:
	var all_regions: Array = (world["regions"] as Dictionary).keys()
	if all_regions.size() <= 1:
		return true
	var seen: Dictionary = {str(all_regions[0]): true}
	var queue: Array = [str(all_regions[0])]
	while not queue.is_empty():
		var here: String = str(queue.pop_back())
		for neighbour in neighbours_of(here):
			if seen.has(str(neighbour)):
				continue
			seen[str(neighbour)] = true
			queue.append(str(neighbour))
	return seen.size() == all_regions.size()


func region_free_slots(region_id: String) -> int:
	var slots: int = int(data.regions[region_id]["presence_slots"])
	var used: int = 0
	for entity_id in world["entities"]:
		used += presence_count(str(entity_id), region_id)
	return slots - used


## Quanto pesa una casa in una Regione (D-158). E' il conto che decide chi la
## tiene, quando la Chronicle dichiara `control_rules.contested`: le **pietre**
## che ci ha (il valore del grado di ogni sua struttura) piu' le **pedine** che
## ci tiene dentro.
##
## Il committente l'ha detto cosi': «se una entita' ha un castello (che magari
## vale 3) ma un'altra ha un esercito che occupa la regione (che vale 4) la
## regione viene controllata da chi ha di piu'». Le due monete sono diverse e
## si sommano nella stessa colonna: **un castello e' una presenza che non se ne
## va, una pedina e' un castello che si puo' spostare.**
##
## I **luoghi del mondo** (`owned: false` nel catalogo: foreste, passi, fiumi)
## non contano per nessuno — non sono di nessuno per costruzione.
func control_strength(entity_id: String, region_id: String) -> int:
	var rules: Dictionary = _contest_rules()
	var total: int = presence_count(entity_id, region_id) * int(
		rules.get("presence_weight", 1)
	)
	var region: Variant = world["regions"].get(region_id)
	if region == null:
		return total
	for structure in (region as Dictionary).get("structures", []):
		var record: Dictionary = structure as Dictionary
		if str(record.get("owner", "")) != entity_id:
			continue
		var definition: Variant = data.structure_types.get(str(record["structure_type"]))
		if definition == null or not bool(definition["owned"]):
			continue
		var grades: Array = definition["grades"]
		var grade: int = clampi(int(record["grade"]), 1, grades.size())
		total += int((grades[grade - 1] as Dictionary)["value"])
	return total


## Chi la tiene, secondo il conto. Restituisce `{entity_id, strength, tied}`.
##
## **A parita' non cambia niente**: chi ce l'ha se la tiene, e se non ce l'ha
## nessuno resta di nessuno. Per togliere una Regione a qualcuno bisogna
## **superarlo**, non pareggiarlo — altrimenti il padrone di una casella
## contesa cambierebbe a ogni pedina che passa.
func strongest_in(region_id: String) -> Dictionary:
	var region: Variant = world["regions"].get(region_id)
	if region == null:
		return {"entity_id": null, "strength": 0, "tied": false}
	var best: Variant = null
	var best_strength: int = 0
	var tied: bool = false
	for entity_id in world["turn_order"]:
		var seat: String = str(entity_id)
		var strength: int = control_strength(seat, region_id)
		if strength <= 0:
			continue
		if strength > best_strength:
			best = seat
			best_strength = strength
			tied = false
		elif strength == best_strength:
			tied = true
	return {"entity_id": best, "strength": best_strength, "tied": tied}


## Chi dovrebbe tenere questa Regione adesso, o `null`. Rispetta il pareggio:
## il padrone in carica resta finche' qualcuno non lo supera.
func rightful_holder(region_id: String) -> Variant:
	var region: Variant = world["regions"].get(region_id)
	if region == null:
		return null
	var holder: Variant = (region as Dictionary).get("control", null)
	var best: Dictionary = strongest_in(region_id)
	if best["entity_id"] == null:
		# Nessuno ha niente li': la casella torna a nessuno solo se le regole
		# lo dicono, che e' `lapse_without_presence` detto dentro l'anno.
		return null
	if bool(best["tied"]):
		# Pareggio: se chi e' in carica e' fra i primi, resta; altrimenti niente.
		if holder != null and control_strength(str(holder), region_id) == int(best["strength"]):
			return holder
		return holder
	return best["entity_id"]


func _contest_rules() -> Dictionary:
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle == null:
		return {}
	return (chronicle.get("control_rules", {}) as Dictionary).get("contested", {})


func contest_is_on() -> bool:
	return not _contest_rules().is_empty()


func control_count(entity_id: String) -> int:
	var count: int = 0
	for region_id in world["regions"]:
		if str(world["regions"][region_id].get("control", "")) == entity_id:
			count += 1
	return count


# --- assets ----------------------------------------------------------------

func hand(entity_id: String) -> Array:
	var entity: Variant = world["entities"].get(entity_id)
	return [] if entity == null else (entity["hand"] as Array).duplicate()


func hand_size(entity_id: String) -> int:
	return hand(entity_id).size()


func count_family_in_hand(entity_id: String, family: String) -> int:
	var count: int = 0
	for asset_id in hand(entity_id):
		if Ids.asset_family(str(asset_id)) == family:
			count += 1
	return count


func first_asset_of_family(entity_id: String, family: String) -> String:
	for asset_id in hand(entity_id):
		if Ids.asset_family(str(asset_id)) == family:
			return str(asset_id)
	return ""


func first_asset_of_families(entity_id: String, families: Array) -> String:
	for family in families:
		var found: String = first_asset_of_family(entity_id, str(family))
		if found != "":
			return found
	return ""


## Assets in hand ranked by what they are worth in this Tension, strongest
## first. Used by the CLI default policy and by Developer Mode previews.
func ranked_hand_for_tension(entity_id: String, tension_id: String) -> Array:
	var relevant: Array = data.tensions[tension_id]["relevant_asset_families"]
	var ranked: Array = hand(entity_id)
	ranked.sort_custom(func(a: Variant, b: Variant) -> bool:
		var score_a: int = _commit_score(str(a), relevant)
		var score_b: int = _commit_score(str(b), relevant)
		if score_a == score_b:
			return str(a) < str(b)
		return score_a > score_b
	)
	return ranked


func _commit_score(asset_id: String, relevant: Array) -> int:
	var asset: Variant = data.assets.get(asset_id)
	if asset == null:
		return 0
	if relevant.has(str(asset["family"])):
		return int(asset["strength"]) * 2
	return 1


# --- tensions --------------------------------------------------------------

func tension_value(tension_id: String) -> int:
	return int(world["tensions"][tension_id]["current_value"])


func tension_visibility(tension_id: String) -> String:
	return str(world["tensions"][tension_id]["visibility"])


func is_tension_open(tension_id: String) -> bool:
	return tension_visibility(tension_id) == "OPEN"


## Che cosa nasconde una Tensione velata, deciso dalla Chronicle e non dal
## codice (D-187). Due regole:
##
##   `HIDES_ALL` - il default, e il gioco fino a 0.1.154: velata vuol dire che
##     il numero non si vede e sulla domanda non si puo' agire, finche' non la
##     si scopre.
##   `HIDES_THRESHOLD` - il valore e' pubblico come per una domanda aperta, ed
##     e' **la soglia** a stare coperta. Chiesta dal committente: «il mondo lo
##     sa quale e' il valore ma i giocatori nel gioco fisico no, e quindi
##     nessuno sa quando le velate si attivano». Al tavolo vero e' una carta
##     girata a faccia in giu' accanto al segnalino.
static func veil_hides_threshold_only(p_world: Dictionary, p_data: RefCounted) -> bool:
	var chronicle: Variant = p_data.chronicles.get(str(p_world.get("chronicle_id", "")))
	if chronicle == null:
		return false
	return str((chronicle as Dictionary).get("veiled_tensions", "HIDES_ALL")) == "HIDES_THRESHOLD"


func hides_threshold_only() -> bool:
	return veil_hides_threshold_only(world, data)


## What `viewer_id` is allowed to know. Returns -1 when the value is hidden from
## them: a veiled Tension only shows its number to Entities that have scouted it
## with SCHEME (§10, §11.1) — a meno che la Chronicle non nasconda **solo la
## soglia**, e allora il numero lo vedono tutti.
func visible_tension_value(tension_id: String, viewer_id: String) -> int:
	if is_tension_open(tension_id):
		return tension_value(tension_id)
	if hides_threshold_only():
		return tension_value(tension_id)
	if knows_tension(viewer_id, tension_id):
		return tension_value(tension_id)
	return -1


## E la soglia: si vede se la domanda e' aperta, o se questa casa l'ha scoperta.
## Torna -1 quando resta coperta.
func visible_tension_threshold(tension_id: String, viewer_id: String) -> int:
	if is_tension_open(tension_id) or knows_tension(viewer_id, tension_id):
		return tension_threshold(tension_id)
	return -1


## La soglia vera: quella scritta piu' il ritocco del sacchetto (D-192). Chi
## legge la soglia da qui e da `TensionSystem.threshold()` deve leggere lo stesso
## numero — un seggio che decide su una soglia diversa da quella che apre il
## Consiglio gioca un altro gioco.
func tension_threshold(tension_id: String) -> int:
	var bonus: int = 0
	var chronicle: Variant = data.chronicles.get(str(world.get("chronicle_id", "")))
	if chronicle != null:
		var rules: Dictionary = (chronicle as Dictionary).get(
			"tension_tokens", {}
		) as Dictionary
		if not rules.is_empty():
			bonus = int(rules.get("threshold_bonus", 0))
	return int(data.tensions[tension_id]["threshold"]) + bonus


func knows_tension(entity_id: String, tension_id: String) -> bool:
	var entity: Variant = world["entities"].get(entity_id)
	if entity == null:
		return false
	return (entity["tags"] as Array).has(Ids.knows_tension_tag(tension_id))


func tension_domain(tension_id: String) -> String:
	return str(data.tensions[tension_id]["domain"])


func relevant_families(tension_id: String) -> Array:
	return data.tensions[tension_id]["relevant_asset_families"]


# --- relations -------------------------------------------------------------

func relation_level(a: String, b: String) -> String:
	var record: Variant = world["relations"].get(Ids.relation_key(a, b))
	return "NEUTRAL" if record == null else str(record["level"])


func relation_rank(a: String, b: String) -> int:
	return RELATION_ORDER.find(relation_level(a, b))


func relation_tags(a: String, b: String) -> Array:
	var record: Variant = world["relations"].get(Ids.relation_key(a, b))
	return [] if record == null else (record["tags"] as Array).duplicate()


static func shift_relation(level: String, steps: int) -> String:
	var index: int = RELATION_ORDER.find(level)
	if index < 0:
		index = RELATION_ORDER.find("NEUTRAL")
	return str(RELATION_ORDER[clampi(index + steps, 0, RELATION_ORDER.size() - 1)])


# --- claims ----------------------------------------------------------------

func claims_of(entity_id: String) -> Array:
	var out: Array = []
	for claim in world["claims"]:
		if str(claim["entity_id"]) == entity_id:
			out.append(claim)
	return out


func claim_for_domain(entity_id: String, domain: String) -> Dictionary:
	for claim in claims_of(entity_id):
		if str(claim["domain"]) == domain:
			return claim
	return {}


# --- turn order ------------------------------------------------------------

func active_entities() -> Array:
	var out: Array = []
	for entity_id in world["turn_order"]:
		if bool(world["entities"][entity_id]["active"]):
			out.append(str(entity_id))
	return out


## §12.2 C: proponent is whoever forced the Claim; otherwise most presence in the
## Tension's Regions, tie-broken by relevant Assets in hand, then turn order.
##
## "The Tension's Regions" used to mean its whole domain. It now means the Region
## the question is actually *about* - the same focus the narrative and the
## Consequences use - when the caller can name one (D-036). Counting the domain
## let one Entity own a question for ever: `domain:ANCIENT` is two Regions and
## Vaerax's Destiny plants him in both, so all 40 Councils on the Awakening were
## his, and he was never in the room as a voter on the only Tension he cares
## about. Counting the focus asks a narrower and truer question: who is standing
## in the place we are arguing over?
## And the word goes round (D-051).
##
## D-036 narrowed the count from the domain to the focus Region, which stopped
## one seat owning a question by standing in two places. It did not stop one seat
## owning a question by standing in *the* place: the ranking is deterministic, so
## in any stable matchup the same house opens the same Council in all forty
## measured Chronicles, and the seat on the other side of that question never
## gets to put anything on the table. Measured three times in three different
## pairs - Vaerax against Lyra, the Ash Lords against the Order, and back again
## when the first fix moved it - which is what makes it a rule and not a tuning
## problem.
##
## So: whoever opened the last Council on this question steps aside, if anybody
## else is standing where it is being argued. Not a rotation imposed from
## outside - a council does not let the same person open the same question twice
## running, and everything else about the ranking is unchanged.
func determine_proponent(tension_id: String, focus_region: String = "") -> String:
	var previous: String = str(
		(world.get("last_proponent", {}) as Dictionary).get(tension_id, "")
	)
	if previous != "":
		var others: Array = []
		for entity_id in active_entities():
			if str(entity_id) == previous:
				continue
			if focus_region == "" or presence_count(str(entity_id), focus_region) > 0:
				others.append(str(entity_id))
		# Only if somebody else is actually in the room. A question nobody else
		# is standing over goes back to whoever is.
		if not others.is_empty():
			return _rank_proponent(tension_id, focus_region, others)
	return _rank_proponent(tension_id, focus_region, active_entities())


func _rank_proponent(tension_id: String, focus_region: String, among: Array) -> String:
	var domain: String = tension_domain(tension_id)
	var families: Array = relevant_families(tension_id)
	var best: String = ""
	var best_presence: int = -1
	var best_assets: int = -1
	var best_order: int = 999
	for entity_id in among:
		var presence: int = (
			presence_count(str(entity_id), focus_region) if focus_region != ""
			else presence_in_domain(str(entity_id), domain)
		)
		var assets: int = 0
		for family in families:
			assets += count_family_in_hand(str(entity_id), str(family))
		var order: int = (world["turn_order"] as Array).find(entity_id)
		var better: bool = false
		if presence > best_presence:
			better = true
		elif presence == best_presence:
			if assets > best_assets:
				better = true
			elif assets == best_assets and order < best_order:
				better = true
		if better:
			best = str(entity_id)
			best_presence = presence
			best_assets = assets
			best_order = order
	return best


## §12.2 D: stances are declared starting from the player to the proponent's left.
func stance_order(proponent_id: String) -> Array:
	var order: Array = active_entities()
	var start: int = order.find(proponent_id)
	if start < 0:
		return order
	var out: Array = []
	for offset in range(1, order.size()):
		out.append(order[(start + offset) % order.size()])
	return out
