extends RefCounted
## One running Chronicle: WorldState plus every system that acts on it (§5).
##
## Owns no scene, no node and no autoload. GameState holds one of these for the
## UI; the CLI harness and the tests build their own. That is the whole reason
## Milestone 0.0 can play a full Chronicle with `godot --headless`.

const RngService := preload("res://scripts/core/rng_service.gd")
const EffectApplier := preload("res://scripts/core/effect_applier.gd")
const GameLog := preload("res://scripts/core/game_log.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")
const WorldStateService := preload("res://scripts/world/world_state_service.gd")
const TensionSystem := preload("res://scripts/chronicle/tension_system.gd")
const ActionResolver := preload("res://scripts/actions/action_resolver.gd")
const ConfluenceController := preload("res://scripts/confluence/confluence_controller.gd")
const ConsequenceCompiler := preload("res://scripts/chronicle/consequence_compiler.gd")
const DestinyEvaluator := preload("res://scripts/chronicle/destiny_evaluator.gd")
const ChronicleController := preload("res://scripts/chronicle/chronicle_controller.gd")
const SaveSerializer := preload("res://scripts/core/save_serializer.gd")
const Succession := preload("res://scripts/chronicle/succession.gd")

signal effect_applied(effect: Dictionary)
signal log_line(text: String)

## How many years the jump into this Chronicle covered, and who changed across
## it. Zero and empty for the Chronicle that starts a saga.
var _years_passed: int = 0
var _handover: Dictionary = {}

var data: RefCounted
var world: Dictionary = {}
var rng: RefCounted
var log: RefCounted
var applier: RefCounted
var service: RefCounted
var tensions: RefCounted
var actions: RefCounted
var confluence: RefCounted
var compiler: RefCounted
var destinies: RefCounted
var chronicle: RefCounted

var assignments: Dictionary = {}
## Chi si e' seduto davvero. Con la biblioteca delle case (D-213) chi chiama
## non lo sa prima: passa una lista vuota e lo legge qui dopo `setup`.
var seats: Array = []
var destiny_results: Dictionary = {}
var snapshots: Array = []
var last_error: String = ""

var _chronicle_def: Dictionary = {}
var _inherited: Dictionary = {}


func _init(p_data: RefCounted) -> void:
	data = p_data


## Build a fresh Chronicle. `seats` is the seating order, seat 0 goes first.
## Un piano scriptato puo' riscrivere le regole della Chronicle per la durata
## della propria partita (D-188). Sta qui, statica, perche' la usano **sia** la
## sonda da riga di comando **sia** la suite: quando le due strade divergono, la
## suite dice verde e la CI dice rosso — ed e' successo.
## Chi si siede, prima che la partita cominci (D-213).
##
## Sta **fuori** da `setup` per una ragione sola: il tavolo va saputo prima -
## chi apparecchia i caratteri, chi stampa una scheda, chi scrive una riga di
## resoconto lo chiede prima che il mondo esista. E stando fuori la pesca non
## consuma l'RNG della partita: c'e' una strada sola, e il seme che apparecchia
## e' lo stesso che gioca.
static func seats_for(p_data: RefCounted, chronicle_id: String, seed_value: int) -> Array:
	if not p_data.chronicles.has(chronicle_id):
		return []
	return WorldStateFactory.resolve_seats(
		p_data.chronicles[chronicle_id] as Dictionary, RngService.new(seed_value)
	)


## **Chi siede l'anno prossimo** (D-431, ISSUES 64).
##
## Fino alla 0.1.401 questa regola **non era scritta da nessuna parte**, e ogni
## sonda ne applicava una sua: `run_era_probe` ripescava il tavolo con un seme
## per era — meta' dei seggi cambiava casa — e `run_saga` lo teneva fermo per
## tutti i suoi secoli. Due sonde, due giochi, e nessuno aveva deciso quale
## fosse quello vero.
##
## Adesso la regola sta sulla Chronicle (`seats_between_eras`) e la applicano
## tutte. La scelta del committente e' **`REDRAW`**: *le case passano, il mondo
## resta* — in una saga si gioca il mondo, non la propria casa.
static func seats_for_next_era(
	p_data: RefCounted,
	chronicle_id: String,
	seed_value: int,
	previous_seats: Array
) -> Array:
	if previous_seats.is_empty():
		return seats_for(p_data, chronicle_id, seed_value)
	if not p_data.chronicles.has(chronicle_id):
		return previous_seats
	var rule: String = str(
		(p_data.chronicles[chronicle_id] as Dictionary).get("seats_between_eras", "REDRAW")
	)
	match rule:
		"KEEP":
			return previous_seats.duplicate()
		"KEEP_THEN_DRAW":
			# Chi c'era ha precedenza: si tiene chi sedeva, e si pesca solo per
			# i posti che avanzano — cosi' il tavolo cresce invece di cambiare.
			var kept: Array = previous_seats.duplicate()
			for entity_id in seats_for(p_data, chronicle_id, seed_value):
				if kept.size() >= previous_seats.size():
					break
				if not kept.has(entity_id):
					kept.append(entity_id)
			return kept
		_:
			return seats_for(p_data, chronicle_id, seed_value)


static func apply_plan_overrides(p_data: RefCounted, plan: Dictionary) -> void:
	var overrides: Dictionary = plan.get("chronicle_overrides", {}) as Dictionary
	if overrides.is_empty():
		return
	var chronicle: Variant = p_data.chronicles.get(str(plan.get("chronicle_id", "")))
	if chronicle == null:
		return
	for key in overrides:
		(chronicle as Dictionary)[str(key)] = overrides[key]


func setup(chronicle_id: String, seats: Array, seed_value: int) -> bool:
	last_error = ""
	if not data.chronicles.has(chronicle_id):
		last_error = "Chronicle sconosciuta '%s'" % chronicle_id
		return false
	_chronicle_def = data.chronicles[chronicle_id]
	var pool: Dictionary = _chronicle_def.get("entity_pool", {}) as Dictionary
	for entity_id in seats:
		var table: Array = (
			(pool["candidates"] as Array) if not pool.is_empty()
			else (_chronicle_def["entities"] as Array)
		)
		if not table.has(str(entity_id)):
			last_error = "'%s' non fa parte della Chronicle '%s'" % [entity_id, chronicle_id]
			return false

	if seats.is_empty():
		last_error = "nessun seggio: chiedere il tavolo a `seats_for` prima di `setup`"
		return false

	rng = RngService.new(seed_value)
	# Il resto del mondo legge `entities` dalla Chronicle - le pedine di
	# partenza, i mazzi, la successione. Con un tavolo pescato quella lista dice
	# **le candidate**, non i seduti: senza questa copia il gioco
	# apparecchierebbe otto case e ne farebbe giocare quattro.
	if not pool.is_empty():
		_chronicle_def = _chronicle_def.duplicate(true)
		_chronicle_def["entities"] = seats.duplicate()

	# Le tessere della mappa si pescano (D-263): come per le case, la lista
	# `regions` della Chronicle dice le candidate, e da qui in poi dice le
	# tessere uscite. Il dado e' derivato dal seme — la mappa non consuma il
	# caso della partita (lezione di D-150).
	if not (_chronicle_def.get("region_pool", {}) as Dictionary).is_empty():
		if pool.is_empty():
			_chronicle_def = _chronicle_def.duplicate(true)
		_chronicle_def["regions"] = WorldStateFactory.resolve_map(
			_chronicle_def, RngService.new(seed_value * 53 + 29), data
		)

	log = GameLog.new()
	log.line_added.connect(func(text: String) -> void: log_line.emit(text))

	world = WorldStateFactory.build(_chronicle_def, data, rng, seats)
	self.seats = seats.duplicate()
	for index in range(seats.size()):
		assignments[str(index)] = str(seats[index])
	_wire_systems()
	return true


## Rebuild a session around a loaded WorldState.
func restore(save: Dictionary) -> bool:
	last_error = ""
	var chronicle_id: String = str(save["chronicle_id"])
	if not data.chronicles.has(chronicle_id):
		last_error = "Chronicle sconosciuta '%s'" % chronicle_id
		return false
	_chronicle_def = data.chronicles[chronicle_id]
	world = (save["world_state"] as Dictionary).duplicate(true)
	assignments = (save["assignments"] as Dictionary).duplicate(true)
	destiny_results = (save.get("destiny_results", {}) as Dictionary).duplicate(true)

	rng = RngService.new(int(world["rng_seed"]))
	rng.reseed(int(world["rng_seed"]), int(world["rng_state"]))
	log = GameLog.new()
	log.line_added.connect(func(text: String) -> void: log_line.emit(text))
	_wire_systems()
	# Il registro dei Consigli chiusi prima dell'interruzione (ISSUES 23 fase 2):
	# torna nel controller nuovo, cosi' il rapporto di fine anno conta tutto l'anno.
	chronicle.confluence_results = (save.get("confluence_results", []) as Array).duplicate(true)
	return true


func _wire_systems() -> void:
	applier = EffectApplier.new(world, data)
	applier.effect_applied.connect(func(effect: Dictionary) -> void: effect_applied.emit(effect))
	service = WorldStateService.new(world, data)
	compiler = ConsequenceCompiler.new(data, world)
	tensions = TensionSystem.new(world, data, applier, log)
	actions = ActionResolver.new(world, data, applier, rng, log, tensions)
	confluence = ConfluenceController.new(world, data, applier, rng, log, tensions)
	destinies = DestinyEvaluator.new(world, data)
	chronicle = ChronicleController.new(self)
	# ISSUES 23 (D-118): l'azione PLAY_ECHO paga e giudica nel resolver, ma la
	# carta parla nel ChronicleController - funzione, effetti, presagi.
	actions.play_card = chronicle.play_narrator_card


func factory_setup_effects() -> Array:
	return WorldStateFactory.setup_effects(_chronicle_def, data, world)


## Continue a campaign: what the previous Chronicle left behind is applied on
## top of a fresh setup. Call before run(); the truth and echo registers are
## copied straight across because they are the world's memory, not its state.
##
## `results` is the Destiny report of the Chronicle that just ended. It decides
## one thing and one only: whether a seat keeps the Destiny it failed or moves
## on to the next one it wanted (D-045). Omitting it means nobody achieved
## anything, which is the right reading for a world that has no report.
func inherit_from(previous: Dictionary, results: Dictionary = {}) -> void:
	_inherited = previous
	if previous.is_empty():
		return
	# How much time passed is the Chronicle's own declaration - one year for a
	# written year, a drawn span of decades for a library one.
	_years_passed = Succession.years_between(_chronicle_def, rng)
	world["year"] = int(previous.get("year", world["year"])) + _years_passed
	world["echo_log"] = (previous.get("echo_log", []) as Array).duplicate(true)
	world["echo_played"] = (previous.get("echo_played", []) as Array).duplicate(true)
	world["truth_log"] = (previous.get("truth_log", []) as Array).duplicate(true)
	# **La mappa e' della saga** (D-263): un'era che pesca le tessere gioca su
	# quelle uscite alla prima, qualunque seme la apra. Se la pesca cieca di
	# questo seme ha detto altro, il mondo si rimonta sulle tessere ereditate
	# — Regioni, forma, questioni che la mappa regge, mazzetti.
	if not (_chronicle_def.get("region_pool", {}) as Dictionary).is_empty():
		var saga_map: Array = (previous.get("regions", {}) as Dictionary).keys()
		if not saga_map.is_empty() and saga_map != (_chronicle_def["regions"] as Array):
			_chronicle_def = _chronicle_def.duplicate(true)
			_chronicle_def["regions"] = saga_map.duplicate()
			WorldStateFactory.rebuild_drawn_map(world, _chronicle_def, data, rng)
	# La pesca che ascolta (D-079): il setup ha pescato l'anno alla cieca,
	# perche' il mondo di prima non era ancora noto. Adesso lo e': se il pool
	# dichiara degli echi, si ridanno le carte pesate sui segni ereditati.
	WorldStateFactory.redeal_tensions(world, _chronicle_def, data, rng, previous, results, _years_passed)
	# E il verbale d'apertura (D-089): perche' queste domande. Solo lettura,
	# dopo che la mano e' data; il tavolo lo trova in testa al log.
	world["opening_record"] = WorldStateFactory.opening_record(
		world, _chronicle_def, data, previous, results
	)
	# La meta' della mappa (D-090): come si piazza, e cosa il tempo le ha
	# fatto. Derivata dagli stessi Effects che la piazzeranno al setup.
	world["map_record"] = WorldStateFactory.map_record(
		world, _chronicle_def, data, previous, _years_passed
	)

	# Un anno in piu' di campagna (D-181): la saga sa quanto e' lunga, ed e'
	# quello che le permette di dire se un vincitore c'e' gia' o no.
	world["chronicles_played"] = int(previous.get("chronicles_played", 0)) + 1
	# Il punteggio della campagna attraversa le ere (D-180). Non e' un Effetto:
	# e' un contatore, come `confluence_count`, e sta fra le eccezioni dichiarate
	# all'effect-sourcing. Passa **sempre**, anche se questa Chronicle non
	# dichiara `saga_scoring`: un anno che non tiene il conto non e' un anno che
	# lo azzera.
	for entity_id in world["entities"]:
		var before: Dictionary = (previous.get("entities", {}) as Dictionary).get(
			str(entity_id), {}
		) as Dictionary
		(world["entities"][str(entity_id)] as Dictionary)["saga_score"] = int(
			before.get("saga_score", 0)
		)

	# **I tre coperti sono della saga, non dell'anno** (ISSUES 58,
	# [D-237](../../../docs/DECISIONS.md#d-237)) — se la Chronicle lo dichiara.
	#
	# «Ogni entita' ha un obiettivo palese e tre segreti che si pescano
	# all'inizio della saga»: e' l'idea di partenza, e il setup di ogni anno li
	# ripescava. La differenza non e' di sfumatura: con obiettivi d'anno ogni
	# Chronicle e' un contenitore chiuso e la campagna e' una somma di partite;
	# con obiettivi di saga, al terzo anno stai costruendo verso qualcosa che
	# nessuno ha visto, e una mossa che sembra sbagliata oggi puo' essere il
	# quarto passo di un piano di otto.
	#
	# Come `saga_score` qui sopra, e' un **passaggio di setup**, non una mossa:
	# succede prima che la partita cominci, sullo stesso mondo che sta
	# nascendo, ed e' fra le eccezioni dichiarate all'effect-sourcing (§6.3).
	#
	# Una casa che si siede adesso e non c'era prima pesca i propri: non e'
	# un'eccezione, e' l'unica risposta possibile — non ha una saga alle spalle
	# da cui ereditare.
	if str((_chronicle_def.get("objectives", {}) as Dictionary).get("drawn", "")) == "per_saga":
		for entity_id in world["entities"]:
			var seated_before: Dictionary = (previous.get("entities", {}) as Dictionary).get(
				str(entity_id), {}
			) as Dictionary
			var carried: Array = seated_before.get("objectives", []) as Array
			if not carried.is_empty():
				(world["entities"][str(entity_id)] as Dictionary)["objectives"] = (
					carried.duplicate()
				)

	_handover = Succession.plan(previous, results, _chronicle_def, data, _years_passed)
	var mutations: Array = []
	for entity_id in _handover:
		var seat: Variant = world["entities"].get(str(entity_id))
		if seat == null:
			continue
		seat["name"] = str(_handover[entity_id]["name"])
		seat["destiny_id"] = str(_handover[entity_id]["destiny_id"])
		seat["generation"] = int(_handover[entity_id]["generation"])
		# Le ere a mani vuote viaggiano col seggio: e' il contatore che fa
		# stancare un erede della stessa ambizione (D-081).
		seat["barren"] = int(_handover[entity_id].get("barren", 0))
		# E da quanti anni questa pelle e' seduta (D-290): e' la meta' che
		# mancava alla soglia di trasformazione. Come `barren`, e' un contatore
		# di setup e non un Effetto — sta fra le eccezioni dichiarate.
		seat["life_years"] = int(_handover[entity_id].get("life_years", 0))
		# La vita corrente del seggio (D-108): quando la linea si esaurisce,
		# l'incarnazione successiva prende il posto - e il verbale lo dice.
		seat["incarnation"] = int(_handover[entity_id].get("incarnation", 0))
		# D-109: il seggio morto rivive nella vita ON_DEATH, e ogni vita oltre
		# la prima porta il suo segno `life:` - e' il gancio che le tag_rules
		# leggono per i poteri per vita.
		if bool(_handover[entity_id].get("revived", false)):
			seat["active"] = true
		var life_index: int = int(seat["incarnation"])
		if life_index > 0:
			var lives: Array = data.entities[str(entity_id)].get("incarnations", [])
			if life_index < lives.size():
				var life_tag: String = "life:%s" % str(lives[life_index]["id"])
				if not (seat["tags"] as Array).has(life_tag):
					seat["tags"].append(life_tag)
		if bool(_handover[entity_id].get("transformed", false)):
			var opening: String = ""
			match str(_handover[entity_id].get("entry_kind", "")):
				"ON_DEATH":
					opening = "%s non c'è più, ma il seggio non muore: al suo posto siede %s."
				"ON_TAG":
					opening = "I segni hanno scelto: al posto di %s siede %s."
				_:
					opening = "La linea di %s si è esaurita: al suo posto siede %s."
			var line: String = opening % [
				str(_handover[entity_id]["transformed_from"]),
				str(_handover[entity_id]["name"]),
			]
			var told: String = str(_handover[entity_id].get("note", ""))
			if told != "":
				line += " " + told
			mutations.append(line)

	# Il verbale si legge dopo la successione: i conti aperti portano i nomi
	# dell'era prima (chi li ha lasciati), la mappa quelli dell'era nuova
	# (chi la tiene adesso).
	if not (world["opening_record"] as Array).is_empty() \
			or not (world["map_record"] as Dictionary).is_empty() \
			or not mutations.is_empty():
		log.section("IL VERBALE D'APERTURA - anno %d, %d anni dopo" % [
			int(world["year"]), _years_passed
		])
		for line in mutations:
			log.bullet(str(line))
		for line in WorldStateFactory.opening_lines(world["opening_record"], data):
			log.bullet(str(line))
		var map_lines: Array = WorldStateFactory.map_lines(world["map_record"], data, world)
		if not map_lines.is_empty():
			log.line("La mappa che si eredita:")
			for line in map_lines:
				log.bullet(str(line))


func years_passed() -> int:
	return _years_passed


func handover() -> Dictionary:
	return _handover


func inheritance_effects() -> Array:
	return WorldStateFactory.inheritance_effects(
		_inherited, _chronicle_def, data, _years_passed
	)


func chronicle_def() -> Dictionary:
	return _chronicle_def


## Keep world_state.rng_state in step with the RNG before anything reads it.
func sync_rng_state() -> void:
	world["rng_state"] = rng.get_draws()


func to_save(label: String = "") -> Dictionary:
	sync_rng_state()
	return SaveSerializer.to_save(self, label)


## §6.3 / §22: automatic snapshot before every Confluence, so Developer Mode can
## rewind past an irreversible Echo.
func take_snapshot(label: String) -> Dictionary:
	var snapshot: Dictionary = to_save(label)
	snapshots.append(snapshot)
	return snapshot


func restore_snapshot(index: int = -1) -> bool:
	if snapshots.is_empty():
		last_error = "nessuno snapshot disponibile"
		return false
	var snapshot: Dictionary = snapshots[index if index >= 0 else snapshots.size() - 1]
	return restore(snapshot)


## Developer Mode undo (§6.3). Refuses to step past an irreversible Effect.
func undo(count: int = 1) -> bool:
	if not applier.undo_last(count):
		last_error = applier.last_error
		return false
	return true


func run(decider: Object) -> Dictionary:
	return await chronicle.run(decider)


## Break the session <-> log/applier signal cycles so the objects can be freed.
## Call it when a session is discarded; RefCounted alone cannot collect a cycle.
func dispose() -> void:
	if log != null:
		for connection in log.line_added.get_connections():
			log.line_added.disconnect(connection["callable"])
	if applier != null:
		for connection in applier.effect_applied.get_connections():
			applier.effect_applied.disconnect(connection["callable"])
	snapshots.clear()
	chronicle = null
	confluence = null
	actions = null
	tensions = null
	destinies = null
	service = null
	compiler = null
	applier = null
