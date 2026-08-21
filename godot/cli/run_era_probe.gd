extends SceneTree
## La sonda delle ere: cosa fa il tempo a una saga, misurato (issue #25).
##
##   godot --headless --path godot --script res://cli/run_era_probe.gd -- \
##       --sagas=20 --chronicles=10 --seed=812 --then=CHR_02
##
## Una saga non e' una fila di primavere: fra un anno giocato e il prossimo
## possono passare venti anni o duecento (D-045), le persone diventano case,
## le case cambiano nome, e chi ha ottenuto il proprio Destino ne vuole un
## altro. run_saga racconta *una* saga; questa sonda ne gioca N e conta cosa
## il tempo fa davvero: quanti secoli copre una campagna, quante generazioni
## si siedono, quanti Destini ruotano, quante mani di domande diverse escono
## dalla biblioteca - e il numero che decide la prossima fase: **quanti fatti
## dell'anno uno arrivano all'ultimo anno, letterali e mai sbiaditi.** Un mondo
## che ricorda tutto per sempre non ha leggende: ha un archivio.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const WorldStateFactory := preload("res://scripts/world/world_state_factory.gd")


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var sagas: int = int(options.get("sagas", 20))
	var chronicles: int = int(options.get("chronicles", 10))
	var first_seed: int = int(options.get("seed", 812))
	var first_id: String = str(options.get("chronicle", "CHR_01"))
	var later_id: String = str(options.get("then", "CHR_02"))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var start_year: int = int(data.chronicles[first_id]["start_year"])
	print("SONDA DELLE ERE - %d saghe da %d Chronicle (%s poi %s), semi da %d" % [
		sagas, chronicles, first_id, later_id, first_seed
	])

	var spans: Array = []
	var jumps: Array = []
	var generations: int = 0
	var rotations: int = 0
	var weary_turns: int = 0
	var names_seen: Dictionary = {}
	# D-130: le vite mutate che siedono davvero, e i NONE per seggio attraverso
	# le ere. La Diaspora spunta la leva dell'espulsione: se il NONE di Nahr
	# sparisce dalle saghe, la vita va ritoccata - questa riga e' la sentinella.
	var lives_seated: Dictionary = {}
	# ISSUES 35: le istituzioni governano bene e non vogliono niente. La voce
	# chiedeva il conto dei livelli **per incarnazione** a tavolo misto: se una
	# Compagnia arriva al secondo gradino meno spesso di una Maestra, e' il
	# contenuto delle vite tardive; se ci arriva uguale, era il Minimo letto male.
	var levels_by_life: Dictionary = {}
	var levels_by_seat: Dictionary = {}
	var years_played: int = 0
	var hands: Dictionary = {}
	var echoed_candidates: int = 0
	var echoed_drawn: int = 0
	var account_candidates: int = 0
	var account_drawn: int = 0
	var warmed: int = 0
	var quieted: int = 0
	var drawn_total: int = 0
	var survivors: Dictionary = {}
	var survivor_avg: Array = []
	var first_year_facts_avg: Array = []
	var truths_final: Array = []
	var legends_final: Array = []
	var facts_final: Array = []

	# Il contenuto che legge le leggende (D-076): le carte MEMORIA e le proposte
	# la cui eleggibilita' nomina un `legend:`. Se a fine misura sono a zero,
	# sono contenuto che non esiste (D-035), e va detto qui, non scoperto poi.
	var memoria_cards: Array = []
	for card in data.echo_cards.values():
		if str(card["dramatic_family"]) == "MEMORIA":
			memoria_cards.append(str(card["id"]))
	var legend_propositions: Array = []
	for template in data.confluence_templates.values():
		for proposition in template["propositions"]:
			for condition in proposition.get("eligibility", []):
				if str((condition as Dictionary).get("tag", "")).begins_with("legend:"):
					legend_propositions.append(str(proposition["id"]))
	var memory_read: Dictionary = {}

	for saga_index in range(sagas):
		var seed_base: int = first_seed + saga_index * 1009
		var previous: Dictionary = {}
		var previous_results: Dictionary = {}
		var first_end_tags: Array = []
		var final_tags: Array = []
		var final_year: int = start_year

		for index in range(chronicles):
			var chronicle_id: String = first_id if index == 0 else later_id
			var session: RefCounted = GameSession.new(data)
			var seats: Array = (data.chronicles[chronicle_id]["entities"] as Array).duplicate()
			var seed_value: int = seed_base + index * 97
			session.setup(chronicle_id, seats, seed_value)
			session.inherit_from(previous, previous_results)
			if index > 0:
				jumps.append(session.years_passed())
				for entity_id in session.handover():
					var seat: Dictionary = session.handover()[entity_id]
					if bool(seat.get("changed", false)):
						generations += 1
						names_seen[str(seat["name"])] = true
					if bool(seat.get("transformed", false)):
						var life: String = str(seat["name"])
						lives_seated[life] = int(lives_seated.get(life, 0)) + 1
					if bool(seat.get("wants_new", false)):
						rotations += 1
					if bool(seat.get("weary", false)):
						weary_turns += 1
				var hand: Array = (session.world["tensions"] as Dictionary).keys()
				hand.sort()
				hands["|".join(PackedStringArray(hand))] = true
				# Il calore ereditato (D-088): quante pescate partono sopra o
				# sotto il valore d'autore.
				for tension_id in hand:
					drawn_total += 1
					var start: int = int(session.world["tensions"][str(tension_id)]["current_value"])
					var authored: int = int(data.tensions[str(tension_id)]["current_value"])
					if start > authored:
						warmed += 1
					elif start < authored:
						quieted += 1
				# La pesca che ascolta (D-079): delle candidate che l'era prima
				# aveva richiamato con un segno, quante sono state pescate.
				var pool: Dictionary = (
					data.chronicles[chronicle_id].get("tension_pool", {})
				)
				for tension_id in (pool.get("echoes", {}) as Dictionary):
					if not WorldStateFactory._era_carries_any(
						previous, pool["echoes"][str(tension_id)]
					):
						continue
					echoed_candidates += 1
					if hand.has(str(tension_id)):
						echoed_drawn += 1
				# E i conti rimasti aperti (D-087): le clausole tension_limit
				# negate nell'era prima, quando nominano una candidata.
				var owed: Dictionary = WorldStateFactory._open_accounts(previous_results)
				for tension_id in owed:
					if not (pool.get("candidates", []) as Array).has(str(tension_id)):
						continue
					account_candidates += 1
					if hand.has(str(tension_id)):
						account_drawn += 1

			var table: RefCounted = Characters.deal(
				seats, RngService.new(seed_value * 31 + 7), session.log
			)
			var report: Dictionary = await session.run(table)

			for card_id in session.world["echo_deck"]["drawn"]:
				if memoria_cards.has(str(card_id)):
					memory_read[str(card_id)] = int(memory_read.get(str(card_id), 0)) + 1
			for result in report["confluences"]:
				var voted: String = str((result as Dictionary).get("proposition_id", ""))
				if legend_propositions.has(voted):
					memory_read[voted] = int(memory_read.get(voted, 0)) + 1

			var tags: Array = (session.world["global_tags"] as Array).duplicate()
			tags = tags.filter(func(tag: Variant) -> bool: return not str(tag).begins_with("function:"))
			if index == 0:
				first_end_tags = tags.duplicate()
			final_tags = tags
			final_year = int(session.world["year"])
			if index == chronicles - 1:
				truths_final.append((session.world["truth_log"] as Array).size())
				legends_final.append(tags.filter(
					func(tag: Variant) -> bool: return str(tag).begins_with("legend:")
				).size())
				facts_final.append(tags.filter(
					func(tag: Variant) -> bool: return not str(tag).begins_with("legend:")
				).size())

			previous = session.world
			previous_results = report["destiny_results"]
			# Niente dispose: `previous` e' il mondo che il prossimo anno eredita.
			years_played += 1
			for entity_id in previous_results:
				var level: String = str(
					(previous_results[entity_id] as Dictionary).get("level", "")
				)
				if level == "":
					level = "NONE"
				var ladder: Dictionary = levels_by_seat.get(str(entity_id), {})
				ladder[level] = int(ladder.get(level, 0)) + 1
				levels_by_seat[str(entity_id)] = ladder
				var who: String = str(
					(session.world["entities"][str(entity_id)] as Dictionary).get("name", entity_id)
				)
				var life: Dictionary = levels_by_life.get(who, {})
				life[level] = int(life.get(level, 0)) + 1
				levels_by_life[who] = life

		spans.append(final_year - start_year)
		var survived: int = 0
		for tag in final_tags:
			if first_end_tags.has(tag):
				survived += 1
				survivors[str(tag)] = int(survivors.get(str(tag), 0)) + 1
		survivor_avg.append(survived)
		first_year_facts_avg.append(first_end_tags.size())

	spans.sort()
	jumps.sort()
	print("")
	print("  Anni coperti da una saga di %d Chronicle: mediana %d, da %d a %d" % [
		chronicles, int(spans[spans.size() / 2]), int(spans[0]), int(spans[spans.size() - 1])
	])
	print("  Salto fra due anni giocati: mediana %d anni, da %d a %d" % [
		int(jumps[jumps.size() / 2]), int(jumps[0]), int(jumps[jumps.size() - 1])
	])
	print("  Generazioni nuove sedute al tavolo: %d (%.1f per saga), %d nomi distinti" % [
		generations, float(generations) / maxf(sagas, 1), names_seen.size()
	])
	var life_names: Array = lives_seated.keys()
	life_names.sort()
	print("  Le vite mutate sedute nelle saghe:")
	for life in life_names:
		print("    %-34s %4d" % [str(life), int(lives_seated[life])])
	print("  I NONE per seggio, su %d anni giocati (la leva di D-067 deve restare vera):" % years_played)
	var seat_ids: Array = levels_by_seat.keys()
	seat_ids.sort()
	for seat_id in seat_ids:
		var ladder: Dictionary = levels_by_seat[seat_id]
		print("    %-14s NONE %3d   MINIMUM %3d   VICTORY %3d   TRIUMPH %3d" % [
			str(seat_id), int(ladder.get("NONE", 0)), int(ladder.get("MINIMUM", 0)),
			int(ladder.get("VICTORY", 0)), int(ladder.get("TRIUMPH", 0)),
		])
	# ISSUES 35, la misura che mancava: chi siede, e a che gradino arriva.
	print("  Chi siede e dove arriva (ISSUES 35), a tavolo misto:")
	var who_names: Array = levels_by_life.keys()
	who_names.sort()
	for who in who_names:
		var life: Dictionary = levels_by_life[who]
		var played: int = 0
		for key in life:
			played += int(life[key])
		if played < 8:
			continue
		var above: int = int(life.get("VICTORY", 0)) + int(life.get("TRIUMPH", 0))
		print("    %-34s %4d anni   supera il Minimo %3d%%" % [
			str(who), played, int(round(100.0 * float(above) / float(played)))
		])
	print("")
	print("  Destini cambiati perche' il precedente era ottenuto: %d (%.1f per saga)" % [
		rotations, float(rotations) / maxf(sagas, 1)
	])
	print("  Destini cambiati per stanchezza - l'erede non giura su cio' che ha visto fallire (D-081): %d (%.1f per saga)" % [
		weary_turns, float(weary_turns) / maxf(sagas, 1)
	])
	print("  Mani di domande diverse pescate dalla biblioteca: %d" % hands.size())
	if echoed_candidates > 0:
		print("  La pesca che ascolta (D-079): candidate richiamate da un segno pescate %d su %d (%d%%)" % [
			echoed_drawn, echoed_candidates, int(100.0 * echoed_drawn / echoed_candidates)
		])
	if account_candidates > 0:
		print("  I conti rimasti aperti (D-087): candidate richiamate da una clausola negata pescate %d su %d (%d%%)" % [
			account_drawn, account_candidates, int(100.0 * account_drawn / account_candidates)
		])
	if drawn_total > 0:
		print("  Il calore ereditato (D-088): su %d domande pescate, %d partono piu' calde e %d piu' quiete del valore d'autore" % [
			drawn_total, warmed, quieted
		])
	print("  Verita' nel registro all'ultimo anno: %.0f in media" % _mean(truths_final))
	print("")
	print("  All'ultimo anno il mondo porta in media %.1f fatti correnti e %.1f leggende." % [
		_mean(facts_final), _mean(legends_final)
	])
	print("  Dei %.1f fatti globali con cui si chiude l'anno uno, %.1f arrivano" % [
		_mean(first_year_facts_avg), _mean(survivor_avg)
	])
	print("  LETTERALI all'ultimo anno, secoli dopo. I sopravvissuti piu' frequenti:")
	var keys: Array = survivors.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool:
		if int(survivors[a]) == int(survivors[b]):
			return str(a) < str(b)
		return int(survivors[a]) > int(survivors[b])
	)
	for key in keys.slice(0, 12):
		print("    %-36s %3d" % [str(key), int(survivors[key])])

	print("")
	print("  La memoria letta: quante volte il contenuto ha nominato una leggenda")
	print("  (una voce a zero e' contenuto che non esiste, D-035):")
	for id in memoria_cards + legend_propositions:
		print("    %-36s %3d" % [str(id), int(memory_read.get(str(id), 0))])

	quit(0)


func _mean(values: Array) -> float:
	var total: float = 0.0
	for value in values:
		total += float(value)
	return total / maxf(values.size(), 1)


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
