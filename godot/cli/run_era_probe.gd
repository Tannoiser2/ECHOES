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
	# D-176 ha lasciato aperta una voce: la linea della Cenere/Fuochi arriva al
	# secondo gradino la meta' delle volte delle altre. Il conto per incarnazione
	# dice *quanto*, non *cosa manca*: la sonda dei gradini lo sa fare, ma solo su
	# una Chronicle sola, e il NONE della Cenere si vede solo nelle saghe. Qui si
	# contano le clausole rimaste in sospeso quando l'anno chiude a NONE.
	var none_causes: Dictionary = {}
	# E l'ipotesi che ne segue: le Montagne Rosse sono l'unica Regione a tre
	# slot invece di quattro, e il Minimo della Cenere ne chiede due. Se
	# l'occupazione altrui negli anni chiusi a NONE e' piu' alta che negli
	# altri, la casa non fallisce: viene soffocata.
	var slots_none: Array = []
	var slots_other: Array = []
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
	# La proposta del committente: dare un valore ai livelli e sommarli lungo la
	# saga, per avere un vincitore di campagna. Prima di scriverla come regola si
	# misura **quale scala** produce un vincitore sensato: una che paghi il Minimo
	# quanto basta fa vincere chi e' sopravvissuto, che e' l'opposto di cio' che il
	# gioco premia (D-150: il Minimo e' una soglia, non un obiettivo).
	var scales: Dictionary = {
		"A 0/1/2/3  lineare": [0, 1, 2, 3],
		"B 0/1/3/6  crescente": [0, 1, 3, 6],
		"C 0/1/3/5": [0, 1, 3, 5],
		"D -1/1/3/6 il NONE punisce": [-1, 1, 3, 6],
		"E 0/0/1/3  esistere non paga": [0, 0, 1, 3],
	}
	# D-181: la soglia delle dieci Chronicle rende concreta una domanda che D-180
	# aveva dichiarato senza risposta - se il conto renda ininfluenti gli ultimi
	# anni. La misura e' **l'ultimo anno in cui la testa cambia**: se in media e'
	# il secondo su dieci, la campagna e' decisa da un pezzo quando si dichiara.
	var lead_changes: Array = []
	var last_change: Array = []
	var scale_wins: Dictionary = {}      # scala -> {seggio: saghe vinte}
	var scale_ties: Dictionary = {}      # scala -> pareggi
	var scale_agree_top: Dictionary = {} # scala -> vincitore = chi ha piu' Trionfi
	var scale_agree_min: Dictionary = {} # scala -> vincitore = chi ha piu' Minimi

	for saga_index in range(sagas):
		var seed_base: int = first_seed + saga_index * 1009
		var previous: Dictionary = {}
		var previous_results: Dictionary = {}
		var saga_levels: Dictionary = {}
		var leaders_by_year: Array = []
		var first_end_tags: Array = []
		var final_tags: Array = []
		var final_year: int = start_year

		for index in range(chronicles):
			var chronicle_id: String = first_id if index == 0 else later_id
			var session: RefCounted = GameSession.new(data)
			var seed_value: int = seed_base + index * 97
			var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
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

			var top_score: int = -999999
			var top_who: String = ""
			for entity_id in (session.world["entities"] as Dictionary):
				var seat_now: Dictionary = session.world["entities"][str(entity_id)] as Dictionary
				if int(seat_now.get("saga_score", 0)) > top_score:
					top_score = int(seat_now.get("saga_score", 0))
					top_who = str(entity_id)
			leaders_by_year.append(top_who)

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
				var tally: Array = saga_levels.get(str(entity_id), [0, 0, 0, 0]) as Array
				tally[["NONE", "MINIMUM", "VICTORY", "TRIUMPH"].find(level)] += 1
				saga_levels[str(entity_id)] = tally
				if level == "NONE":
					for condition in (previous_results[entity_id] as Dictionary)["unmet"]:
						var key: String = "%s|%s" % [
							str(entity_id), str((condition as Dictionary).get("label", "?"))
						]
						none_causes[key] = int(none_causes.get(key, 0)) + 1
				if str(entity_id) == "ENT_CENERE":
					var taken: int = 0
					for other_id in (session.world["entities"] as Dictionary):
						if str(other_id) == "ENT_CENERE":
							continue
						taken += session.service.presence_count(
							str(other_id), "REG_MONTAGNE_ROSSE"
						)
					var row: Array = [
						taken,
						session.service.presence_count("ENT_CENERE", "REG_MONTAGNE_ROSSE"),
						session.service.presence_count("ENT_CENERE", "REG_MINIERE_ANTICHE"),
						session.service.tokens_placed("ENT_CENERE"),
					]
					if level == "NONE":
						slots_none.append(row)
					else:
						slots_other.append(row)

		# Chi era in testa dopo ogni anno, col punteggio vero tenuto dal motore.
		var changes: int = 0
		var last: int = 0
		var leader_before: String = ""
		for i in range(leaders_by_year.size()):
			var who_leads: String = str(leaders_by_year[i])
			if who_leads != leader_before and leader_before != "":
				changes += 1
				last = i + 1
			leader_before = who_leads
		lead_changes.append(changes)
		last_change.append(last)

		# Fine saga: chi vincerebbe, con ognuna delle scale candidate.
		for label in scales:
			var values: Array = scales[label] as Array
			var best: int = -999999
			var winners: Array = []
			var by_score: Dictionary = {}
			for entity_id in saga_levels:
				var tally: Array = saga_levels[entity_id] as Array
				var score: int = 0
				for i in range(4):
					score += int(tally[i]) * int(values[i])
				by_score[str(entity_id)] = score
				if score > best:
					best = score
					winners = [str(entity_id)]
				elif score == best:
					winners.append(str(entity_id))
			if winners.size() > 1:
				scale_ties[label] = int(scale_ties.get(label, 0)) + 1
				continue
			var winner: String = str(winners[0])
			var table: Dictionary = scale_wins.get(label, {})
			table[winner] = int(table.get(winner, 0)) + 1
			scale_wins[label] = table
			# Il vincitore e' anche chi ha piu' Trionfi? E chi ha piu' Minimi?
			var top_seat: String = ""
			var top_count: int = -1
			var min_seat: String = ""
			var min_count: int = -1
			for entity_id in saga_levels:
				var tally: Array = saga_levels[entity_id] as Array
				if int(tally[3]) > top_count:
					top_count = int(tally[3])
					top_seat = str(entity_id)
				if int(tally[1]) > min_count:
					min_count = int(tally[1])
					min_seat = str(entity_id)
			if winner == top_seat:
				scale_agree_top[label] = int(scale_agree_top.get(label, 0)) + 1
			if winner == min_seat:
				scale_agree_min[label] = int(scale_agree_min.get(label, 0)) + 1

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
	if not last_change.is_empty():
		var sum_changes: float = 0.0
		for value in lead_changes:
			sum_changes += float(value)
		var sum_last: float = 0.0
		var decided_early: int = 0
		for value in last_change:
			sum_last += float(value)
			if int(value) <= 3:
				decided_early += 1
		print("")
		print("  LA CAMPAGNA E' ANCORA VIVA? (D-181)")
		print("    cambi di testa per saga            %.1f" % (sum_changes / float(lead_changes.size())))
		print("    ultimo cambio di testa, anno       %.1f su %d" % [
			sum_last / float(last_change.size()), chronicles,
		])
		print("    saghe decise entro il terzo anno   %d su %d" % [
			decided_early, last_change.size(),
		])
	print("")
	print("  IL VINCITORE DELLA SAGA - quale scala di punteggio, su %d saghe" % sagas)
	print("     (il vincitore dovrebbe somigliare a chi ha piu' Trionfi, non a chi ha piu' Minimi)")
	var scale_names: Array = scales.keys()
	scale_names.sort()
	for label in scale_names:
		var table: Dictionary = scale_wins.get(label, {})
		var spread: Array = []
		var seat_ids2: Array = table.keys()
		seat_ids2.sort()
		for seat_id in seat_ids2:
			spread.append("%s %d" % [str(seat_id).replace("ENT_", ""), int(table[seat_id])])
		print("    %-28s  come i Trionfi %2d/%d   come i Minimi %2d/%d   pareggi %d" % [
			label,
			int(scale_agree_top.get(label, 0)), sagas,
			int(scale_agree_min.get(label, 0)), sagas,
			int(scale_ties.get(label, 0)),
		])
		print("        chi vince: %s" % ", ".join(PackedStringArray(spread)))
	print("")
	print("  I NONE per seggio, su %d anni giocati (la leva di D-067 deve restare vera):" % years_played)
	var seat_ids: Array = levels_by_seat.keys()
	seat_ids.sort()
	for seat_id in seat_ids:
		var ladder: Dictionary = levels_by_seat[seat_id]
		print("    %-14s NONE %3d   MINIMUM %3d   VICTORY %3d   TRIUMPH %3d" % [
			str(seat_id), int(ladder.get("NONE", 0)), int(ladder.get("MINIMUM", 0)),
			int(ladder.get("VICTORY", 0)), int(ladder.get("TRIUMPH", 0)),
		])
	if not none_causes.is_empty():
		print("  Perche' un anno chiude a NONE - le clausole del Minimo rimaste in sospeso:")
		var causes: Array = none_causes.keys()
		causes.sort_custom(func(a, b): return int(none_causes[a]) > int(none_causes[b]))
		for key in causes:
			var parts: PackedStringArray = str(key).split("|")
			print("    %-14s %4d   %s" % [parts[0], int(none_causes[key]), parts[1]])
	if not slots_none.is_empty():
		print("  Dove tiene i gettoni la Cenere a fine anno (Montagne Rosse: 3 slot):")
		print("    %-26s %8s %8s %8s %8s" % [
			"", "altrui", "sue", "miniere", "gettoni"
		])
		for group in [["negli anni a NONE", slots_none], ["in tutti gli altri", slots_other]]:
			var rows: Array = group[1] as Array
			if rows.is_empty():
				continue
			var sums: Array = [0.0, 0.0, 0.0, 0.0]
			for row in rows:
				for i in range(4):
					sums[i] = float(sums[i]) + float((row as Array)[i])
			var count: float = float(rows.size())
			print("    %-26s %8.2f %8.2f %8.2f %8.2f   su %d anni" % [
				str(group[0]),
				float(sums[0]) / count, float(sums[1]) / count,
				float(sums[2]) / count, float(sums[3]) / count, rows.size(),
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
