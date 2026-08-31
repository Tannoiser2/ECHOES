extends SceneTree
## Le carte del Narratore, pesate (ISSUES 114).
##
##   godot --headless --path godot --script res://cli/run_echo_weight_probe.gd -- \
##       --runs=100 --seed=7000
##
## Tre domande del committente, in quest'ordine, perche' la seconda e la terza
## non hanno senso se la prima risponde «quasi mai»:
##
##   1. **quando vengono calate?** — quante volte una carta viene giocata per
##      il suo Eco invece che per un'Azione normale (D-359: non c'e' piu' un
##      mazzo da distribuire, l'Eco e' il terzo blocco della carta Asset);
##   2. **quanto cambiano il mondo?** — quanti Effetti porta una calata, al
##      netto di quello che il giocatore paga, contro un'azione con una carta
##      Asset e contro un Consiglio approvato;
##   3. **servono a qualcosa?** — quali Echi non escono mai, e per quale dei
##      cinque rifiuti quelli rimasti in mano non si potevano calare.
##
## Il tavolo e' quello del cancello: cento anni pescati di CHR_00, quattro
## caratteri mescolati fra i seggi, semi da 7000. Cosi' i numeri stanno
## accanto a quelli del playtest e non a quelli di un tavolo diverso.
##
## **La prova che la sonda non e' cieca** e' stampata per prima: se le calate
## contate dal registro degli Effetti non combaciano con la pila `echo_played`
## del mondo, la sonda si ferma e lo dice. In questo progetto uno zero e' quasi
## sempre la sonda, non il gioco, e questo confronto e' il modo di saperlo:
## le due strade sono diverse — una legge gli Effetti, l'altra guarda il tavolo.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")

## Quello che una calata fa pagare, non quello che fa succedere: il prezzo
## della parola (D-118) e' una carta Asset scartata, e finisce nel registro
## sotto la stessa firma. Contarlo come «cambiamento del mondo» gonfierebbe
## ogni carta di uno.
const PRICE_TYPES: Array = ["DISCARD_ASSET", "REMOVE_ASSET", "MOVE_ASSET"]


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var runs: int = int(options.get("runs", 100))
	var first_seed: int = int(options.get("seed", 7000))

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var dealt: int = 0
	var played: int = 0
	var played_by_pile: int = 0
	var left_in_hand: int = 0
	var runs_with_one: int = 0
	var by_act: Dictionary = {}
	var by_card: Dictionary = {}
	var effects_echo: int = 0
	var price_effects: int = 0
	var effects_by_type: Dictionary = {}
	var plays_card: int = 0
	var effects_card: int = 0
	var councils: int = 0
	var effects_council: int = 0
	var forced_cards: int = 0
	var refusals: Dictionary = {}
	var hand_at_end: int = 0
	var hands_counted: int = 0
	var distinct_played: int = 0

	for index in range(runs):
		var seed_value: int = first_seed + index
		var session: RefCounted = GameSession.new(data)
		var seats: Array = GameSession.seats_for(data, "CHR_00", seed_value)
		session.setup("CHR_00", seats, seed_value)
		var table: RefCounted = Characters.deal(
			seats, RngService.new(seed_value * 31 + 7), session.log
		)
		var report: Dictionary = await session.run(table)
		var world: Dictionary = session.world

		played_by_pile += (world["echo_played"] as Array).size()

		# Un'azione non e' un Effetto: tutti gli Effetti di una stessa azione
		# portano la stessa firma (kind, id, attore, atto, round, sequenza).
		# Le calate sono le firme distinte, non le righe.
		var seen_plays: Dictionary = {}
		var seen_card_plays: Dictionary = {}
		var seen_councils: Dictionary = {}
		for effect in world["effect_log"]:
			var src: Dictionary = effect.get("source", {})
			var kind: String = str(src.get("kind", ""))
			var id: String = str(src.get("id", ""))
			var key: String = "%s|%s|%d|%d|%d" % [
				id, str(src.get("actor", "")), int(src.get("act", 0)),
				int(src.get("round", 0)), int(src.get("sequence", 0)),
			]
			if kind == "action" and id == "ACT_PLAY_ECHO":
				if not seen_plays.has(key):
					seen_plays[key] = true
					var act: int = int(src.get("act", 0))
					by_act[act] = int(by_act.get(act, 0)) + 1
				var type: String = str(effect.get("type", "?"))
				if PRICE_TYPES.has(type):
					price_effects += 1
				else:
					effects_echo += 1
					effects_by_type[type] = int(effects_by_type.get(type, 0)) + 1
			elif kind == "action" and id == "ACT_PLAY_CARD":
				if not seen_card_plays.has(key):
					seen_card_plays[key] = true
				if not PRICE_TYPES.has(str(effect.get("type", "?"))):
					effects_card += 1
			elif kind == "confluence":
				if not seen_councils.has(key):
					seen_councils[key] = true
				effects_council += 1
		played += seen_plays.size()
		# `echo_played` e' un insieme: lo stesso Eco calato due volte in un anno
		# — le carte hanno piu' copie in scatola — ci compare una volta sola.
		# Il confronto onesto e' fra carte **distinte**, non fra calate.
		var distinct_here: Dictionary = {}
		for card_id in world["echo_played"]:
			distinct_here[str(card_id)] = true
		distinct_played += distinct_here.size()
		plays_card += seen_card_plays.size()
		councils += seen_councils.size()
		if seen_plays.size() > 0:
			runs_with_one += 1

		for card_id in world["echo_played"]:
			by_card[str(card_id)] = int(by_card.get(str(card_id), 0)) + 1

		# Quello che resta in mano quando l'anno finisce, e perche' non si
		# poteva calare. E' una fotografia dell'ultimo istante, non la storia
		# della partita: vale per capire quale dei quattro rifiuti pesa, non
		# quante volte ha morso.
		for entity_id in seats:
			var entity: Dictionary = world["entities"][str(entity_id)]
			var hand: Array = entity["hand"] as Array
			left_in_hand += hand.size()
			hand_at_end += hand.size()
			hands_counted += 1
			for asset_id in hand:
				var why: String = session.actions.check(
					str(entity_id), "PLAY_ECHO", {"asset_card_id": str(asset_id)}
				)
				var bucket: String = _bucket(why)
				refusals[bucket] = int(refusals.get(bucket, 0)) + 1
				dealt += 1
		session.dispose()

	for card_id in data.echo_cards:
		if data.echo_cards[str(card_id)].get("forces_confluence_on", null) != null:
			forced_cards += 1

	print("")
	print("== LE CARTE DEL NARRATORE, PESATE - %d anni, tavolo misto, semi da %d ==" % [
		runs, first_seed
	])
	print("")
	print("PROVA CHE LA SONDA VEDE")
	print("  calate contate dal registro degli Effetti   %d" % played)
	print("  Echi distinti, dal registro                 %d" % distinct_played)
	print("  Echi distinti nella pila `echo_played`      %d" % played_by_pile)
	if played == 0:
		print("  ** ZERO: la sonda e' cieca, oppure nessuno cala mai. Non credere al resto. **")
	elif distinct_played != played_by_pile:
		print("  ** le due strade non combaciano: una carta calata due volte, o una firma persa. **")
	else:
		print("  le due strade combaciano.")

	print("")
	print("1. QUANDO VENGONO CALATE")
	print("  Echi calati sul tavolo          %6.2f per partita  (%d in tutto)" % [
		float(played) / float(runs), played
	])
	print("  carte giocate in tutto          %6.2f per partita  (%d in tutto)" % [
		float(played + plays_card) / float(runs), played + plays_card
	])
	if played + plays_card > 0:
		print("  quota delle giocate che e' un Eco    %5.1f%%" % [
			100.0 * float(played) / float(played + plays_card)
		])
	print("  carte in mano a fine partita    %6.2f per partita  (%d in tutto)" % [
		float(left_in_hand) / float(runs), left_in_hand
	])
	print("  partite con almeno una calata   %d su %d" % [runs_with_one, runs])
	var acts: Array = by_act.keys()
	acts.sort()
	for act in acts:
		print("    Atto %d                        %d calate" % [int(act), int(by_act[act])])

	print("")
	print("2. QUANTO CAMBIANO IL MONDO")
	print("  (senza il prezzo: %d Effetti di pagamento, %.2f per calata)" % [
		price_effects, (float(price_effects) / float(played)) if played > 0 else 0.0
	])
	print("  Effetti per carta del Narratore calata   %5.2f  (%d su %d calate)" % [
		(float(effects_echo) / float(played)) if played > 0 else 0.0, effects_echo, played
	])
	print("  Effetti per carta Asset giocata          %5.2f  (%d su %d azioni)" % [
		(float(effects_card) / float(plays_card)) if plays_card > 0 else 0.0,
		effects_card, plays_card
	])
	print("  Effetti per Consiglio                    %5.2f  (%d su %d Consigli)" % [
		(float(effects_council) / float(councils)) if councils > 0 else 0.0,
		effects_council, councils
	])
	print("")
	print("  Cosa scrivono, per tipo di Effetto")
	var types: Array = effects_by_type.keys()
	types.sort()
	for type in types:
		print("    %-24s %d" % [str(type), int(effects_by_type[type])])

	print("")
	print("3. SERVONO A QUALCOSA")
	print("  Echi scritti                     %d" % data.echo_cards.size())
	print("  Echi usciti almeno una volta     %d" % by_card.size())
	print("  Echi che non escono mai          %d" % (data.echo_cards.size() - by_card.size()))
	print("  carte che prescrivono un Consiglio  %d su %d scritte" % [
		forced_cards, data.echo_cards.size()
	])
	print("  mano di carte Asset a fine partita  %.2f (l'Eco costa la carta) " % [
		(float(hand_at_end) / float(hands_counted)) if hands_counted > 0 else 0.0
	])
	print("")
	print("  Perche' l'Eco delle carte in mano non si poteva calare (fotografia di fine partita)")
	var buckets: Array = refusals.keys()
	buckets.sort()
	for bucket in buckets:
		print("    %-34s %d" % [str(bucket), int(refusals[bucket])])

	print("")
	print("  Gli Echi, uno per uno (su %d partite)" % runs)
	var card_ids: Array = data.echo_cards.keys()
	card_ids.sort()
	for card_id in card_ids:
		var card: Dictionary = data.echo_cards[str(card_id)]
		var count: int = int(by_card.get(str(card_id), 0))
		print("    %-28s %-30s %4d  %s" % [
			str(card_id), str(card["title"]).substr(0, 30), count,
			"MAI" if count == 0 else "",
		])
	quit(0)


## I quattro rifiuti di `_check_play_echo`, ridotti alle loro famiglie: il testo
## porta dentro il nome della carta, e quello cambia a ogni riga.
func _bucket(why: String) -> String:
	if why == "":
		return "si poteva calare, non l'hanno voluta"
	if why.contains("il mondo non porta i segni"):
		return "il mondo non porta i segni (eleggibilita')"
	if why.contains("la mano non basta"):
		return "la mano non basta per pagarlo"
	if why.contains("Consiglio prescritto"):
		return "un Consiglio e' gia' prescritto"
	if why.contains("non e nella mano"):
		return "non e' in mano"
	if why.contains("non si cala in questo Atto"):
		return "l'Atto non lo permette (famiglia)"
	if why.contains("non porta un Eco"):
		return "la carta non porta un Eco"
	return why


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
