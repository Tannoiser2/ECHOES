extends SceneTree
## I segni che le Azioni stampate posano davvero (D-283).
##
##   godot --headless --path godot --script res://cli/run_mark_probe.gd -- \
##       --runs=100 --seed=7000
##
## Il passo 1 del brief del Punto Zero chiede due cose: che **entrambe** le
## Azioni stampate su una carta siano eseguibili, e che si veda. Questa sonda
## misura tutte e due:
##
##   · quante volte si cala la **prima** meta' della carta e quante la seconda;
##   · quanti segni le Azioni posano sul mondo, per ambito;
##   · **quanti restano fuori**, cioe' quante volte un segno stampato non ha
##     trovato il proprio soggetto in quella mossa — e' il lavoro della fase
##     dopo, e finche' non e' zero si scrive.
##
## La regola di casa vale anche qui: uno zero e' quasi sempre la sonda cieca.
## Il conto dei segni si prende dal registro degli Effetti, che e' l'unica
## fonte di verita' su cosa e' successo davvero.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

const SIGN_EFFECTS: Array = [
	"SET_REGION_TAG", "REMOVE_REGION_TAG", "SET_GLOBAL_TAG",
	"REMOVE_GLOBAL_TAG", "SET_ENTITY_TAG", "REMOVE_ENTITY_TAG",
]


## L'avvolgente: delega tutto, segna quale meta' della carta e' stata calata e
## quali segni quella meta' **avrebbe** dovuto posare.
class Marks extends RefCounted:
	var inner: RefCounted
	var data: RefCounted
	var by_face: Dictionary = {0: 0, 1: 0, -1: 0}
	var printed: int = 0
	var homeless: Dictionary = {}

	func _init(p_data: RefCounted) -> void:
		data = p_data

	func choose_action(entity_id: String, ao_index: int, session: RefCounted) -> Dictionary:
		var request: Dictionary = inner.choose_action(entity_id, ao_index, session)
		if str(request.get("template", "")) != "PLAY_CARD":
			return request
		var params: Dictionary = request.get("params", {}) as Dictionary
		var index: int = int(params.get("face_action", -1))
		by_face[index] = int(by_face.get(index, 0)) + 1
		var card: Variant = data.assets.get(str(params.get("asset_id", "")))
		if card == null or index < 0:
			return request
		var faces: Array = (
			((card as Dictionary).get("physical", {}) as Dictionary).get("actions", []) as Array
		)
		if index >= faces.size():
			return request
		var face: Dictionary = faces[index] as Dictionary
		for field in ["puts_tag", "clears_tag"]:
			for tag in face.get(field, []):
				printed += 1
				var known: Variant = data.tags.get(str(tag))
				if known == null:
					continue
				var scopes: Array = (known as Dictionary).get("scope", []) as Array
				if scopes.has("GLOBAL"):
					continue
				# Il posto puo' venire dal verbo (`region_id`) o dalla faccia
				# (`mark_region_id`, D-284): guardarne uno solo direbbe senza
				# casa dei segni che una casa ce l'hanno.
				if scopes.has("REGION") and (
					str(params.get("region_id", "")) != ""
					or str(params.get("mark_region_id", "")) != ""
				):
					continue
				if scopes.has("ENTITY"):
					continue
				homeless[str(tag)] = int(homeless.get(str(tag), 0)) + 1
		return request

	func choose_commit(entity_id: String, context: Dictionary, limit: int, session: RefCounted) -> Array:
		return inner.choose_commit(entity_id, context, limit, session)

	func choose_question(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_question(context, options, session)

	func choose_proposition(context: Dictionary, options: Array, session: RefCounted) -> String:
		return inner.choose_proposition(context, options, session)

	func choose_stance(entity_id: String, context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_stance(entity_id, context, session)

	func choose_recovery(context: Dictionary, session: RefCounted) -> Dictionary:
		return inner.choose_recovery(context, session)


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		printerr(data.describe_errors())
		quit(1)
		return

	var marks: Marks = Marks.new(data)
	var laid: Dictionary = {}
	var wanted_marks: int = 0
	var feared_marks: int = 0
	var by_card: Dictionary = {}
	var plans: Array = []
	for i in range(runs):
		plans.append("CHR_01" if i % 2 == 0 else "CHR_03")

	for index in range(plans.size()):
		var chronicle_id: String = str(plans[index])
		var seed_value: int = first_seed + index
		var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
		var session: RefCounted = GameSession.new(data)
		if not session.setup(chronicle_id, seats, seed_value):
			printerr(session.last_error)
			session.dispose()
			continue
		marks.inner = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		await session.run(marks)
		for entry in (session.world.get("effect_log", []) as Array):
			var effect: Dictionary = (entry as Dictionary).get("effect", entry) as Dictionary
			if not SIGN_EFFECTS.has(str(effect.get("type", ""))):
				continue
			var source: Dictionary = effect.get("source", {}) as Dictionary
			# **Solo i segni della faccia.** Si riconoscono dalla firma
			# (`kind: "face_action"`, D-283): durante una carta calata anche il
			# verbo posa segni suoi — TRAMARE lascia le sue scoperte — e
			# contarli insieme direbbe il doppio del vero. Il primo giro di
			# questa sonda filtrava per giunta sul campo sbagliato e contava
			# **zero**: la trappola di casa, la quarta volta.
			if str(source.get("kind", "")) != "face_action":
				continue
			var tag: String = str((effect.get("payload", {}) as Dictionary).get("tag", ""))
			laid[tag] = int(laid.get(tag, 0)) + 1
			# **Chi l'ha posato, lo voleva?** (D-289) Il profilo strategico dice
			# cosa una casa vuole lasciare nel mondo: qui si conta quante volte
			# un segno posato e' proprio uno di quelli — e quante volte e' uno
			# che quella casa aveva dichiarato di temere.
			var actor: String = str(source.get("actor", ""))
			var profile: Variant = data.get("entity_profiles").get(actor)
			if profile != null and _is_about_me(effect, actor, session):
				# **Solo quando il segno riguarda me.** Un segno di Regione
				# posato sulla terra di un rivale non e' «quello che temo»: e'
				# quello che gli sto facendo. Il primo conto non distingueva, e
				# diceva 24 segni temuti contro 18 voluti — cioe' contava come
				# autolesionismo il sabotaggio riuscito.
				for voice in (profile as Dictionary).get("wants", []) as Array:
					if str((voice as Dictionary).get("tag", "")) == tag:
						wanted_marks += 1
				for voice in (profile as Dictionary).get("fears", []) as Array:
					if str((voice as Dictionary).get("tag", "")) == tag:
						feared_marks += 1
			var card_id: String = str(source.get("id", ""))
			by_card[card_id] = int(by_card.get(card_id, 0)) + 1
		session.dispose()

	print("")
	print("== I SEGNI DELLE AZIONI STAMPATE - %d anni, tavolo misto ==" % runs)
	print("")
	var first: int = int(marks.by_face.get(0, 0))
	var second: int = int(marks.by_face.get(1, 0))
	var blind: int = int(marks.by_face.get(-1, 0))
	var total: int = first + second + blind
	print("  carte calate: %d" % total)
	print("    prima Azione stampata   %6d   %5.1f%%" % [
		first, 0.0 if total == 0 else 100.0 * first / total
	])
	print("    seconda Azione stampata %6d   %5.1f%%" % [
		second, 0.0 if total == 0 else 100.0 * second / total
	])
	print("    senza indice (verbo dichiarato) %d" % blind)
	print("")
	var placed: int = 0
	for tag in laid:
		placed += int(laid[tag])
	var lost: int = 0
	for tag in marks.homeless:
		lost += int(marks.homeless[tag])
	print("  segni posati da chi li **voleva** (profilo, D-289): %d" % wanted_marks)
	print("  segni posati da chi li **temeva**:                  %d" % feared_marks)
	print("")
	print("  segni stampati sulle Azioni calate: %d" % marks.printed)
	print("    posati sul mondo:      %d" % placed)
	print("    senza un soggetto:     %d" % lost)
	if not marks.homeless.is_empty():
		print("")
		print("  I segni che non trovano dove stare (il lavoro della fase dopo):")
		for tag in _sorted_by_count(marks.homeless):
			print("    %-28s %d" % [str(tag), int(marks.homeless[str(tag)])])
	print("")
	print("  I segni posati piu' spesso:")
	var shown: int = 0
	for tag in _sorted_by_count(laid):
		print("    %-28s %d" % [str(tag), int(laid[str(tag)])])
		shown += 1
		if shown >= 12:
			break
	print("")
	quit(0)


## Il segno riguarda chi lo posa? Un segno del mondo si', sempre; uno di Regione
## solo se quella Regione e' sua; uno di casa solo se la casa e' lei.
func _is_about_me(effect: Dictionary, actor: String, session: RefCounted) -> bool:
	var target: Dictionary = effect.get("target", {}) as Dictionary
	match str(target.get("kind", "")):
		"global":
			return true
		"entity":
			return str(target.get("id", "")) == actor
		"region":
			var region: Dictionary = (session.world["regions"] as Dictionary).get(
				str(target.get("id", "")), {}
			) as Dictionary
			return str(region.get("control", "")) == actor
	return false


func _sorted_by_count(counts: Dictionary) -> Array:
	var keys: Array = counts.keys()
	keys.sort_custom(func(a: String, b: String) -> bool:
		var left: int = int(counts[a])
		var right: int = int(counts[b])
		if left == right:
			return str(a) < str(b)
		return left > right
	)
	return keys


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if not str(arg).begins_with("--"):
			continue
		var pair: PackedStringArray = str(arg).substr(2).split("=")
		out[pair[0]] = pair[1] if pair.size() > 1 else "1"
	return out
