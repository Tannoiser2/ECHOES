extends RefCounted
## What crosses the gap between one Chronicle and the next (D-045).
##
## A Chronicle is a year. A saga is not: between two of them the world can move
## by a season or by two centuries, and the difference is the whole point of a
## Chronicle game. Until 0.1.8 the engine added exactly **one year** and sat the
## same four people back down at the table, which is why a ten-Chronicle audit
## produced *"la corona fu divisa in due"* six times: the same king kept
## reopening the same question the following spring.
##
## The rule here is that the **id is the seat, not the person**. `ENT_ALDRIC` is
## the house that holds Eredan; who is sitting in the chair is `world.entities`
## state, and it changes when enough time passes. That keeps every Region, Scar
## and relation the previous Chronicle wrote pointing at something that still
## exists.
##
## Three things carry across, each with its own condition - all three true, none
## of them unconditionally:
##
## - **la posizione**, sempre. The map is the world and the world does not
##   restart (that part already worked: `WorldStateFactory.inheritance_effects`).
## - **i rapporti**, ma il tempo li smussa. On a long jump every relation moves
##   one step towards NEUTRAL: a hatred outlives the people who felt it, but not
##   for ever, and not undimmed.
## - **il Destino**, ma solo di chi ha fallito. A house that got what it wanted
##   wants something else next time; a house that did not, tries again. This is
##   the one that stops a Chronicle from being a rerun.

const LIFETIME_YEARS: int = 25
const DECAY_YEARS: int = 50
const WARMER: Array = ["ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND"]
const ACHIEVED: Array = ["VICTORY", "TRIUMPH"]

## Dopo quante ere a mani vuote un erede smette di giurare sull'ambizione che
## ha visto fallire (D-081). Tre, per scelta del committente (0.1.36): a due
## le case cambiavano ambizione al ritmo dei salti; la terza delusione e' una
## tradizione, e un erede non giura su una tradizione di fallimenti.
const WEARY_ERAS: int = 3


## How long since the previous Chronicle. An integer is taken as it is; a
## `{min, max}` is drawn with the seeded RNG, so a saga is reproducible and
## still not a metronome.
static func years_between(chronicle: Dictionary, rng: RefCounted) -> int:
	var declared: Variant = chronicle.get("years_after_previous", 1)
	if typeof(declared) == TYPE_DICTIONARY:
		var low: int = int((declared as Dictionary).get("min", 1))
		var high: int = int((declared as Dictionary).get("max", low))
		return low if high <= low else rng.range_int(low, high)
	return int(declared)


## Who is at the table now, and what they want.
##
## Returns `{entity_id: {name, destiny_id, generation, changed, note}}`.
## `previous_results` is the Destiny report of the Chronicle that just ended -
## `{entity_id: {level: ...}}` - and may be empty, in which case nobody has
## achieved anything and every Destiny is kept.
static func plan(
	previous: Dictionary,
	previous_results: Dictionary,
	chronicle: Dictionary,
	data: RefCounted,
	years: int
) -> Dictionary:
	var out: Dictionary = {}
	for entity_id in chronicle["entities"]:
		var id: String = str(entity_id)
		var definition: Variant = data.entities.get(id)
		if definition == null:
			continue
		var before: Dictionary = (previous.get("entities", {}) as Dictionary).get(id, {})
		var generation: int = int(before.get("generation", 0))
		var incarnation: int = int(before.get("incarnation", 0))
		var incarnations: Array = definition.get("incarnations", [])
		# La vita corrente del seggio (D-108): la definizione con sopra i campi
		# dell'incarnazione al tavolo. Con la sola prima incarnazione (o senza)
		# e' la definizione di sempre.
		var active: Dictionary = active_view(definition, incarnation)
		var name: String = str(before.get("name", active["name"]))
		var destiny_id: String = str(before.get("destiny_id", definition["destiny_id"]))
		var changed: bool = false
		var wants_new: bool = false
		var weary: bool = false
		var transformed: bool = false
		var revived: bool = false
		var transformed_from: String = ""
		var entry_kind: String = ""
		var note: String = ""

		# D-109: il seggio morto puo' sopravvivere alla creatura - se una vita
		# ON_DEATH e' scritta, entra adesso, e il seggio torna al tavolo. E'
		# l'unico ingresso che non aspetta il tempo: la morte e' gia' successa.
		if not bool(before.get("active", true)):
			var risen: int = _next_life(definition, incarnation, previous, before, false)
			if risen >= 0 and str(incarnations[risen].get("entry", "")) == "ON_DEATH":
				transformed_from = str(active["name"])
				incarnation = risen
				active = active_view(definition, incarnation)
				name = str(active["name"])
				note = str(active.get("description", ""))
				generation = 0
				transformed = true
				revived = true
				entry_kind = "ON_DEATH"
				changed = true

		# D-109: la storia giocata puo' scegliere la vita anche senza una morte
		# o una linea esaurita - il popolo che si e' insediato diventa regno
		# quando il suo segno sta sul mondo, non quando finisce una lista.
		if not transformed:
			var called: int = _next_life(definition, incarnation, previous, before, false)
			if called >= 0 and str(incarnations[called].get("entry", "")) == "ON_TAG":
				transformed_from = str(active["name"])
				incarnation = called
				active = active_view(definition, incarnation)
				name = str(active["name"])
				note = str(active.get("description", ""))
				generation = 0
				transformed = true
				entry_kind = "ON_TAG"
				changed = true

		# A person does not survive two centuries; a people and a thing under a
		# mountain do. Which is which is authored, not guessed - and it belongs
		# to the *life*, not to the seat: a dynasty that became a republic stops
		# dying (D-108).
		if not transformed \
				and str(active.get("persistence", "MORTAL")) == "MORTAL" \
				and years >= LIFETIME_YEARS:
			var successors: Array = active.get("successors", [])
			var next_life: int = _next_life(definition, incarnation, previous, before, true)
			if not successors.is_empty() or active.has("name_grammar") or next_life >= 0:
				generation += 1
				if generation <= successors.size():
					# The first generations are written by hand, with a line each
					# about who they were. Those are the interesting ones.
					var successor: Dictionary = successors[generation - 1]
					name = str(successor["name"])
					note = str(successor.get("description", ""))
				elif next_life >= 0:
					# La linea si esaurisce e il seggio cambia natura (D-108):
					# la dinastia diventa repubblica, i saggi un culto - e fra
					# piu' vite candidate sceglie la storia giocata (D-109).
					transformed_from = str(active["name"])
					incarnation = next_life
					active = active_view(definition, incarnation)
					name = str(active["name"])
					note = str(active.get("description", ""))
					generation = 0
					transformed = true
					entry_kind = str(
						incarnations[incarnation].get("entry", "LINE_EXHAUSTED")
					)
				else:
					name = compose_name(active, generation - successors.size())
					note = "%s generazione della casa" % _ordinal_word(generation + 1)
				changed = true

		# Whoever is sitting there now: if the seat got what it wanted, it wants
		# the next thing. If it did not, it tries again - and *that* is what
		# keeps a question alive across generations instead of across springs.
		var level: String = str((previous_results.get(id, {}) as Dictionary).get("level", ""))
		var barren: int = int(before.get("barren", 0))
		if before.is_empty():
			barren = 0
		elif ACHIEVED.has(level):
			barren = 0
		else:
			barren += 1
		if ACHIEVED.has(level):
			var pool: Array = definition.get("destiny_pool", [])
			if pool.size() > 1:
				var at: int = pool.find(destiny_id)
				destiny_id = str(pool[(at + 1) % pool.size()])
				wants_new = true
		# L'iniquita' del tempo (D-081): senza questo ramo, chi otteneva
		# cambiava ambizione e chi falliva riprovava la stessa **per mille
		# anni** - misurato, Aldric macinava lo stesso Destino per un'intera
		# saga in 6 su 20. Il Destino e' della persona: l'erede che si siede
		# dopo WEARY_ERAS ere a mani vuote giura su altro. Chi non cambia
		# persona non si stanca - Vaerax e' sotto la montagna apposta.
		elif changed and barren >= WEARY_ERAS:
			var pool: Array = definition.get("destiny_pool", [])
			if pool.size() > 1:
				var at: int = pool.find(destiny_id)
				destiny_id = str(pool[(at + 1) % pool.size()])
				weary = true
				barren = 0
				if note.ends_with("."):
					note = note.substr(0, note.length() - 1)
				if note != "":
					note += ". "
				note += "Non ha giurato sull'ambizione che ha visto fallire"

		out[id] = {
			"name": name,
			"destiny_id": destiny_id,
			"generation": generation,
			"incarnation": incarnation,
			"changed": changed,
			"wants_new": wants_new,
			"weary": weary,
			"transformed": transformed,
			"transformed_from": transformed_from,
			"entry_kind": entry_kind,
			"revived": revived,
			"barren": barren,
			"note": note,
		}
	return out


## La prossima vita del seggio, o -1: la prima candidata dopo quella corrente,
## in ordine d'autore, il cui ingresso e' vero adesso (D-109). ON_DEATH vale
## solo per un seggio morto; ON_TAG quando il suo segno sta sul mondo, sulla
## casa o su una Regione; LINE_EXHAUSTED solo quando la linea e' davvero
## finita (`exhausted`).
static func _next_life(
	definition: Dictionary, incarnation: int, previous: Dictionary,
	before: Dictionary, exhausted: bool
) -> int:
	var incarnations: Array = definition.get("incarnations", [])
	for index in range(incarnation + 1, incarnations.size()):
		var life: Dictionary = incarnations[index]
		match str(life.get("entry", "")):
			"ON_DEATH":
				if not bool(before.get("active", true)):
					return index
			"ON_TAG":
				if _sign_anywhere(str(life.get("entry_tag", "")), previous, before):
					return index
			"LINE_EXHAUSTED":
				if exhausted:
					return index
	return -1


static func _sign_anywhere(tag: String, previous: Dictionary, before: Dictionary) -> bool:
	if tag == "":
		return false
	if (previous.get("global_tags", []) as Array).has(tag):
		return true
	if (before.get("tags", []) as Array).has(tag):
		return true
	for region_id in previous.get("regions", {}):
		var region: Dictionary = previous["regions"][region_id]
		if (region.get("tags", []) as Array).has(tag):
			return true
	return false


## La definizione del seggio con sopra la vita corrente: i campi che
## un'incarnazione dichiara (nome, natura, valori, arte, successori, grammatica
## dei nomi) coprono quelli della definizione; il resto resta del seggio.
static func active_view(definition: Dictionary, incarnation: int) -> Dictionary:
	var incarnations: Array = definition.get("incarnations", [])
	if incarnation <= 0 or incarnation >= incarnations.size():
		return definition
	var view: Dictionary = definition.duplicate()
	var life: Dictionary = incarnations[incarnation]
	for field in ["name", "description", "persistence", "action_values",
			"art_prompt_key", "successors", "name_grammar"]:
		if life.has(field):
			view[field] = life[field]
		elif field in ["successors", "name_grammar"]:
			# La vita nuova non eredita gli eredi della vecchia: una linea
			# esaurita resta esaurita.
			view.erase(field)
	return view


## A name for a generation nobody wrote down.
##
## Any hand-written list runs out: the first audit of this feature used four
## names per house and a ten-Chronicle saga wore them out at the sixth jump, so
## a second "Re Serane" sat down four centuries after the first one and read as
## a bug rather than as a tradition (D-046).
##
## So the house declares how it makes names instead of listing them: a pattern
## with slots, a bag of given names, titles, epithets. The choice is a pure
## function of the generation - no RNG - so a saga stays reproducible and a name
## is stable no matter when it is asked for.
##
## Numbering is what makes it endless *and* right: houses do reuse names, which
## is precisely why they number them. Serane, then Serane II four generations
## later. That is a tradition; it is not a repeat.
static func compose_name(definition: Dictionary, index: int) -> String:
	var grammar: Dictionary = definition.get("name_grammar", {})
	var given: Array = grammar.get("given", [])
	if given.is_empty():
		return str(definition["name"])

	var step: int = maxi(0, index - 1)
	var cycle: int = step / given.size()
	var out: String = str(grammar.get("pattern", "{given}"))
	out = out.replace("{given}", str(given[step % given.size()]))
	out = out.replace("{ordinal}", "" if cycle == 0 else " %s" % _roman(cycle + 1))
	out = out.replace("{title}", _pick(grammar.get("titles", []), cycle, "Re"))
	out = out.replace("{epithet}", _pick(grammar.get("epithets", []), cycle, ""))
	return out.strip_edges()


static func _pick(options: Array, index: int, fallback: String) -> String:
	return fallback if options.is_empty() else str(options[index % options.size()])


const ROMAN: Array = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
const ORDINALS: Array = [
	"", "prima", "seconda", "terza", "quarta", "quinta", "sesta", "settima",
	"ottava", "nona", "decima", "undicesima", "dodicesima",
]


static func _roman(value: int) -> String:
	return str(ROMAN[value]) if value < ROMAN.size() else str(value)


static func _ordinal_word(value: int) -> String:
	return str(ORDINALS[value]) if value < ORDINALS.size() else "%da" % value


## One step towards NEUTRAL, applied to a relation level. Time softens; it does
## not reconcile - that is what FORGE and a Council are for.
static func decayed(level: String) -> String:
	var at: int = WARMER.find(level)
	var middle: int = WARMER.find("NEUTRAL")
	if at < 0 or at == middle:
		return level
	return str(WARMER[at + (1 if at < middle else -1)])


static func decays_after(years: int) -> bool:
	return years >= DECAY_YEARS
