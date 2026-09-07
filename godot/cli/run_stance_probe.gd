extends SceneTree
## Stance probe: why does nobody ever oppose? (O-6)
##
##   godot --headless --path godot --script res://cli/run_stance_probe.gd -- \
##       --runs=40 --seed=3000
##
## The balance probe says *that* Failure and Success-with-Cost are rare; it does
## not say why. Opposition is the only thing that can push a margin down, so if
## the table never opposes, the resolver never gets a chance to produce anything
## but Success.
##
## **Dal Consiglio a due domande (D-467, D-472) opporsi e' prendere la B**: la
## domanda del proponente (A) contro l'altra della carta (B). Non c'e' piu'
## una proposta da giudicare ne' un `choose_stance`: il cervello sceglie la
## parte con `choose_side`, e il numero che decide e' `_side_base_score` — quanto
## vale, per quel seggio, l'esito di base (`questions[i].base`) della domanda di
## ogni parte — piu' la casella migliore di quella parte (`_voice_score`).
##
## Per Consiglio la sonda registra, per ogni seggio non proponente, il punteggio
## di A e di B, la parte che il cervello prenderebbe a scheda pulita — e, per
## ogni Effetto nelle Conseguenze delle due domande, se quell'Effetto ha mosso
## il punteggio. Il secondo conto e' quello importante: un tipo di Effetto che
## non vale mai un punto e' un asse di conflitto che la policy non vede.
##
## Read-only. It plays the same games the balance probe plays and changes
## nothing about them.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## I seggi li dice la Chronicle: la sonda guardava solo la prima saga, e la
## seconda e' quella che di clausole sulle Tensioni non ne aveva nessuna.
var seats: Array = []


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 40))
	var first_seed: int = int(options.get("seed", 3000))
	var chronicle_id: String = str(options.get("chronicle", "CHR_00"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	if not data.chronicles.has(chronicle_id):
		printerr("nessuna Chronicle '%s'" % chronicle_id)
		quit(4)
		return
	# Il tavolo del primo seme, tenuto per tutte le partite (D-213).
	seats = GameSession.seats_for(data, chronicle_id, first_seed)

	# side -> count, score -> count, effect type -> [seen, moved the score]
	# `stances` e' la parte che il cervello **prenderebbe** all'apertura, a
	# scheda pulita; `by_entity` e' la parte che il seggio **ha preso** davvero,
	# letta a voto fatto (D-467): le due possono divergere, perche' fra
	# l'apertura e la presa di posizione il proponente puo' cambiare domanda e
	# le caselle si consumano.
	var stances: Dictionary = {}
	var scores: Dictionary = {}
	var by_effect: Dictionary = {}
	var by_entity: Dictionary = {}
	var rooms: Dictionary = {}
	var voted: Dictionary = {}
	# **Le carte piatte** (D-456): quelle che, messe ai voti, non hanno mosso
	# il punteggio di nessun seggio, ne' con la A ne' con la B. Sono il
	# contenuto che non fa litigare: per ogni coppia di domande, quante volte e'
	# stata votata, quante e' rimasta piatta, e quali Effetti porta — cosi' si
	# vede cosa riscrivere, carta per carta.
	var flat: Dictionary = {}
	# In a Dictionary, not two ints: a lambda captures a local by value, so
	# counters incremented inside the callback would read zero out here.
	var counters: Dictionary = {"confluences": 0, "opposed": 0, "predicted_b": 0}

	for i in range(runs):
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, seats, first_seed + i)
		var probe: RefCounted = PolicyDecider.new(null)
		session.confluence.step_changed.connect(
			func(step: String, context: Dictionary) -> void:
				# Il passo PROPOSITION non c'e' piu' (D-472). All'apertura
				# (QUESTION) le due parti sono gia' aperte e nessuno ha ancora
				# preso posizione: e' il momento di chiedere al cervello cosa
				# farebbe. A voto fatto (RESOLVED) si legge cosa ha fatto.
				if step == "RESOLVED":
					var b_seats: Array = (
						((context.get("sides", {}) as Dictionary).get("B", {}) as Dictionary)
						.get("seats", []) as Array
					)
					if not b_seats.is_empty():
						counters["opposed"] = int(counters["opposed"]) + 1
					for entity_id in seats:
						if str(entity_id) == str(context["proponent"]):
							continue
						var taken: String = session.confluence.side_of(str(entity_id))
						if taken == "":
							taken = "NESSUNA"
						var key: String = "%s/%s" % [str(entity_id), taken]
						by_entity[key] = int(by_entity.get(key, 0)) + 1
					return
				if step != "QUESTION":
					return
				counters["confluences"] = int(counters["confluences"]) + 1
				var proponent: String = str(context["proponent"])
				var pair: Dictionary = _questions(data, session)
				if pair.is_empty():
					return
				var room: String = "%s / %s" % [
					str(context["tension_id"]).replace("TEN_", ""),
					str(proponent).replace("ENT_", ""),
				]
				rooms[room] = int(rooms.get(room, 0)) + 1
				var put: String = "%s contro %s" % [str(pair["A"]["id"]), str(pair["B"]["id"])]
				voted[put] = int(voted.get(put, 0)) + 1
				var offer: Dictionary = {
					"A": session.confluence.box_menu("A"), "B": session.confluence.box_menu("B"),
				}
				var any_b: bool = false
				var anyone_moved: bool = false
				for entity_id in seats:
					if str(entity_id) == proponent:
						continue
					var lean: Dictionary = _lean(probe, str(entity_id), proponent, session)
					if int(lean["A"]) != 0 or int(lean["B"]) != 0:
						anyone_moved = true
					var declared: Dictionary = probe.choose_side(
						str(entity_id), context, offer, session
					)
					var side: String = str(declared.get("side", ""))
					if side == "":
						side = "NESSUNA"
					stances[side] = int(stances.get(side, 0)) + 1
					# Il numero che decide: quanto la B vale piu' della A per
					# questo seggio. Sopra zero il cervello pende verso il no.
					var score: int = int(lean["B"]) - int(lean["A"])
					scores[score] = int(scores.get(score, 0)) + 1
					if side == "B":
						any_b = true
					_attribute(probe, pair, str(entity_id), proponent, session, by_effect)
				if any_b:
					counters["predicted_b"] = int(counters["predicted_b"]) + 1
				var flat_key: String = "%s / %s" % [
					str(context["tension_id"]).replace("TEN_", ""), put
				]
				if not flat.has(flat_key):
					var kinds: Dictionary = {}
					for side in ["A", "B"]:
						for consequence_id in (pair[side] as Dictionary).get("base", []):
							var consequence: Variant = data.consequences.get(str(consequence_id))
							if consequence == null:
								continue
							for effect in (consequence as Dictionary).get("effects", []):
								kinds[str((effect as Dictionary).get("type", ""))] = true
					var listed: Array = kinds.keys()
					listed.sort()
					flat[flat_key] = {"voted": 0, "flat": 0, "effects": listed}
				flat[flat_key]["voted"] = int(flat[flat_key]["voted"]) + 1
				if not anyone_moved:
					flat[flat_key]["flat"] = int(flat[flat_key]["flat"]) + 1
		)
		await session.run(PolicyDecider.new(session.log))
		session.dispose()

	_report(
		runs, int(counters["confluences"]), int(counters["opposed"]),
		int(counters["predicted_b"]), stances, scores, by_entity, by_effect, rooms, voted
	)
	_report_flat(flat)
	quit(0)


## Score every Effect on its own, so we can see which axes are alive. An Effect
## type that is seen hundreds of times and never scores is not a quiet Effect -
## it is one the policy has no opinion about. Si leggono le Conseguenze di base
## delle due domande in gioco (D-467), non piu' quelle di una proposta.
func _attribute(
	probe: RefCounted,
	pair: Dictionary,
	entity_id: String,
	proponent_id: String,
	session: RefCounted,
	by_effect: Dictionary
) -> void:
	var goals: Dictionary = probe._tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	for side in ["A", "B"]:
		for consequence_id in (pair[side] as Dictionary).get("base", []):
			var consequence: Variant = session.data.consequences.get(str(consequence_id))
			if consequence == null:
				continue
			for effect in consequence["effects"]:
				var type: String = str(effect["type"])
				var row: Dictionary = by_effect.get(type, {"seen": 0, "scored": 0})
				row["seen"] = int(row["seen"]) + 1
				if probe._score_effect(effect, entity_id, proponent_id, goals, session, bindings) != 0:
					row["scored"] = int(row["scored"]) + 1
				by_effect[type] = row


## Il punteggio di base delle due parti per un seggio, con lo stesso metro del
## cervello (`_side_base_score`, D-467): la B non ha ancora una guida
## all'apertura, e allora — come fa `choose_side` — parla di chi la valuta.
func _lean(probe: RefCounted, entity_id: String, proponent: String, session: RefCounted) -> Dictionary:
	var goals: Dictionary = probe._tag_goals(entity_id, session)
	var bindings: Dictionary = session.confluence.effect_context()
	var out: Dictionary = {}
	for side in ["A", "B"]:
		var leader: String = session.confluence.side_leader(side)
		if leader == "":
			leader = entity_id
		out[side] = int(probe._side_base_score(side, entity_id, leader, goals, session, bindings))
	out["proponent"] = proponent
	return out


## Le due domande in gioco, prese dalla carta (D-452, D-467): la A e' quella
## del proponente, la B l'altra. Vuoto se la carta non ne ha due.
func _questions(data: RefCounted, session: RefCounted) -> Dictionary:
	var template: Dictionary = data.confluence_template_for(
		str(session.confluence.current.get("tension_id", ""))
	)
	if template.is_empty():
		return {}
	var out: Dictionary = {}
	for side in ["A", "B"]:
		var question_id: String = session.confluence.side_question(side)
		for question in template.get("questions", []):
			if str((question as Dictionary)["id"]) == question_id:
				out[side] = question
	if not out.has("A") or not out.has("B"):
		return {}
	return out


func _report(
	runs: int,
	confluences: int,
	opposed: int,
	predicted_b: int,
	stances: Dictionary,
	scores: Dictionary,
	by_entity: Dictionary,
	by_effect: Dictionary,
	rooms: Dictionary,
	voted: Dictionary
) -> void:
	print("")
	print("== PERCHE NESSUNO SI OPPONE - %d Chronicle ==" % runs)
	print("")
	print("Consigli osservati            %d" % confluences)
	# Il no e' la B (D-467): chi la prende si oppone alla domanda del proponente.
	print("Consigli con almeno un seggio sulla B, a voto fatto     %d  (%.0f%%)" % [
		opposed, 100.0 * float(opposed) / float(maxi(1, confluences))
	])
	print("Consigli dove il cervello avrebbe preso la B all'apertura %d  (%.0f%%)" % [
		predicted_b, 100.0 * float(predicted_b) / float(maxi(1, confluences))
	])

	print("")
	print("Parte che il cervello prenderebbe all'apertura (A sostiene, B si oppone)")
	var stance_keys: Array = stances.keys()
	stance_keys.sort()
	var total: int = 0
	for key in stance_keys:
		total += int(stances[key])
	for key in stance_keys:
		print("  %-10s %5d  (%.1f%%)" % [
			str(key), int(stances[key]), 100.0 * float(stances[key]) / float(maxi(1, total))
		])

	print("")
	print("Quanto la B vale piu' della A, dal punto di vista di chi non propone")
	print("(esito di base delle due domande, _side_base_score; sopra zero pende al no)")
	var score_keys: Array = scores.keys()
	score_keys.sort()
	for key in score_keys:
		print("  %+3d        %5d  (%.1f%%)" % [
			int(key), int(scores[key]), 100.0 * float(scores[key]) / float(maxi(1, total))
		])

	print("")
	print("Per seggio: la parte presa davvero, a voto fatto")
	var entity_keys: Array = by_entity.keys()
	entity_keys.sort()
	for key in entity_keys:
		print("  %-28s %5d" % [str(key), int(by_entity[key])])

	print("")
	print("Ogni Effect, quante volte e stato letto e quante volte ha spostato il")
	print("punteggio. Uno che non lo sposta mai e un motivo di lite invisibile.")
	var effect_keys: Array = by_effect.keys()
	effect_keys.sort()
	for key in effect_keys:
		var row: Dictionary = by_effect[key]
		var scored: int = int(row["scored"])
		print("  %-26s letto %5d   pesato %5d %s" % [
			str(key), int(row["seen"]), scored, "" if scored > 0 else "  <-- MAI",
		])

	# A seat that never opposes may simply never be in the room: this probe only
	# scores non-proponents, and a Tension whose Council is always opened by the
	# one Entity that cares about it never gives that Entity a vote to cast.
	print("")
	print("Chi era nella stanza: Tensione / proponente")
	var room_keys: Array = rooms.keys()
	room_keys.sort()
	for key in room_keys:
		print("  %-28s %5d" % [str(key), int(rooms[key])])


	print("")
	print("Le coppie di domande messe ai voti: A contro B")
	var voted_keys: Array = voted.keys()
	voted_keys.sort()
	for key in voted_keys:
		print("  %-58s %4d" % [str(key), int(voted[key])])


## Le carte che non fanno litigare, dalla piu' piatta: votate N volte, piatte
## M — cioe' nessun seggio ha mosso il punteggio su nessuna delle due domande —
## e gli Effetti che portano.
func _report_flat(flat: Dictionary) -> void:
	print("")
	print("Le carte piatte: votate, piatte (nessun seggio pesa A ne' B), e cosa fanno")
	var keys: Array = flat.keys()
	keys.sort_custom(func(a, b) -> bool:
		var fa: float = float(flat[a]["flat"]) / float(maxi(1, int(flat[a]["voted"])))
		var fb: float = float(flat[b]["flat"]) / float(maxi(1, int(flat[b]["voted"])))
		if fa != fb:
			return fa > fb
		return str(a) < str(b)
	)
	var all_flat: int = 0
	for key in keys:
		var row: Dictionary = flat[key]
		if int(row["flat"]) == int(row["voted"]):
			all_flat += 1
		print("  %-44s %3d votate %3d piatte   %s" % [
			str(key), int(row["voted"]), int(row["flat"]), ", ".join(PackedStringArray(row["effects"]))
		])
	print("  coppie messe ai voti: %d, sempre piatte: %d" % [keys.size(), all_flat])


func _parse_args(args: PackedStringArray) -> Dictionary:
	var options: Dictionary = {}
	for arg in args:
		var text: String = str(arg)
		if not text.begins_with("--"):
			continue
		text = text.substr(2)
		var split: int = text.find("=")
		if split < 0:
			options[text] = true
		else:
			options[text.substr(0, split)] = text.substr(split + 1)
	return options
