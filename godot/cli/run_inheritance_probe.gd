extends SceneTree
## **L'Eredita'**: il mondo parla ancora la lingua che quella casa voleva lasciare?
##
##   godot --headless --path godot --script res://cli/run_inheritance_probe.gd -- \
##       --sagas=12 --chronicles=8 --seed=812 --then=CHR_00
##
## Dal documento del committente sulle trasformazioni:
##
## > *«La domanda non deve essere: l'Entita' e' ancora in gioco? La domanda deve
## > essere: il mondo parla ancora la lingua che quell'Entita' voleva lasciare?»*
##
## E il vincolo che ne segue: **non premiare la durata in se'**. Una casa
## immortale o collettiva non prende punti perche' dura; li prende se il suo
## Echo ha modellato il mondo.
##
## Questa sonda **non cambia nessuna regola**: gioca le saghe come sono e tiene
## un secondo punteggio a fianco, per sapere il prezzo prima di scriverlo — come
## fece D-181 con le cinque scale. Ad ogni salto d'era classifica ogni casa e le
## assegna al piu' un bonus:
##
##   radicata      +3  tiene almeno due dei suoi desideri, e uno e' diventato leggenda
##   fedele        +2  tiene almeno due dei suoi desideri (che abbia cambiato pelle o no)
##   sopravvissuta +1  e' ancora al tavolo, ma di quello che voleva resta poco
##   distorta      +1  ha cambiato pelle e non tiene piu' niente di quello che voleva
##   svanita       +0  non siede piu'
##
## E poi la domanda che decide se l'Eredita' vale la pena: **il vincitore che
## produce somiglia a chi ha piu' Trionfi, o a chi e' semplicemente durato?**

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const Characters := preload("res://scripts/seat/table_of_characters.gd")
const RngService := preload("res://scripts/core/rng_service.gd")
const PolicyDecider := preload("res://scripts/seat/policy_decider.gd")

## La scala dei gradini, per il confronto: e' la B di D-181, quella che nella
## sonda delle ere somigliava di piu' ai Trionfi.
const LADDER: Dictionary = {"NONE": 0, "MINIMUM": 1, "VICTORY": 3, "TRIUMPH": 6}
const BONUS: Dictionary = {
	"radicata": 3, "fedele": 2, "sopravvissuta": 1, "distorta": 1, "svanita": 0
}
## Quanti desideri deve tenere una casa perche' il mondo parli ancora la sua
## lingua. Due: con uno solo, un segno rimasto per caso basterebbe.
const TIENE: int = 2


func _initialize() -> void:
	var options: Dictionary = _parse_args(OS.get_cmdline_user_args())
	var sagas: int = int(options.get("sagas", 12))
	var chronicles: int = int(options.get("chronicles", 8))
	var first_seed: int = int(options.get("seed", 812))
	var first_id: String = str(options.get("chronicle", "CHR_00"))
	var later_id: String = str(options.get("then", "CHR_00"))
	# **La variante che la prima misura ha reso necessaria** (D-299): contare
	# solo quello che il mondo **poteva** perdere. I desideri di una casa sono
	# spesso memorie, e una memoria scritta resta per sempre: contarla come
	# Eredita' vuol dire pagare una casa per una cosa fatta una volta, a ogni
	# salto, per sempre — cioe' premiare la durata con un altro nome, che e'
	# esattamente quello che il committente non vuole.
	var variante: String = str(options.get("variante", ""))
	var solo_perdibili: bool = variante == "perdibili"
	# **La terza variante, e la piu' promettente** (D-299): l'Eredita' la
	# scrive **il tempo**. Al salto d'era il motore trasforma in `legend:<fatto>`
	# i fatti che sbiadiscono: una leggenda e' letteralmente «il mondo parla
	# ancora di quella cosa un secolo dopo», che e' la frase del committente
	# tradotta in un dato che esiste gia'.
	var solo_leggende: bool = variante == "leggende"

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var esiti: Dictionary = {}          # classificazione -> quante volte
	var eredita_wins: Dictionary = {}   # seggio -> saghe vinte all'Eredita'
	var ladder_wins: Dictionary = {}    # seggio -> saghe vinte coi gradini
	var accordo_trionfi: int = 0
	var accordo_gradini: int = 0
	var accordo_durata: int = 0
	# **La domanda vera** (D-299): l'Eredita' non e' una scala alternativa, e' un
	# bonus **sopra** i gradini. Quindi quello che conta non e' chi vince
	# all'Eredita' da sola, ma se sommarla **cambia** il vincitore della saga, e
	# in che direzione: verso chi ha vinto gli anni o verso chi e' durato.
	var accordo_combinato: int = 0
	var accordo_gradini_trionfi: int = 0
	var ribaltate: int = 0
	var saghe_contate: int = 0
	var punti_per_casa: Dictionary = {}
	var salti_per_casa: Dictionary = {}

	for tavolo in ["uniforme", "misto"]:
		for saga_index in range(sagas):
			var seed_base: int = first_seed + saga_index * 1009
			var previous: Dictionary = {}
			var previous_results: Dictionary = {}
			var eredita: Dictionary = {}
			var gradini: Dictionary = {}
			var trionfi: Dictionary = {}
			var presenze: Dictionary = {}
			for index in range(chronicles):
				var chronicle_id: String = first_id if index == 0 else later_id
				var session: RefCounted = GameSession.new(data)
				var seed_value: int = seed_base + index * 97
				var seats: Array = GameSession.seats_for(data, chronicle_id, seed_value)
				session.setup(chronicle_id, seats, seed_value)
				session.inherit_from(previous, previous_results)
				if index > 0:
					for entity_id in session.handover():
						var esito: String = _classify(
							data, str(entity_id), previous,
							session.handover()[entity_id] as Dictionary,
							solo_perdibili, solo_leggende
						)
						esiti[esito] = int(esiti.get(esito, 0)) + 1
						eredita[str(entity_id)] = int(eredita.get(str(entity_id), 0)) + int(BONUS[esito])
						punti_per_casa[str(entity_id)] = int(
							punti_per_casa.get(str(entity_id), 0)
						) + int(BONUS[esito])
						salti_per_casa[str(entity_id)] = int(
							salti_per_casa.get(str(entity_id), 0)
						) + 1
				var brain: RefCounted = (
					PolicyDecider.new(session.log) if tavolo == "uniforme"
					else Characters.deal(seats, RngService.new(seed_value * 31 + 7), session.log)
				)
				var report: Dictionary = await session.run(brain)
				previous = session.world
				previous_results = report.get("destiny_results", {})
				for entity_id in previous_results:
					var level: String = str(
						(previous_results[entity_id] as Dictionary).get("level", "NONE")
					)
					if level == "":
						level = "NONE"
					gradini[str(entity_id)] = int(gradini.get(str(entity_id), 0)) + int(LADDER[level])
					presenze[str(entity_id)] = int(presenze.get(str(entity_id), 0)) + 1
					if level == "TRIUMPH":
						trionfi[str(entity_id)] = int(trionfi.get(str(entity_id), 0)) + 1
			saghe_contate += 1
			var chi_eredita: String = _best(eredita)
			var chi_gradini: String = _best(gradini)
			var chi_trionfi: String = _best(trionfi)
			var chi_durata: String = _best(presenze)
			if chi_eredita != "":
				eredita_wins[chi_eredita] = int(eredita_wins.get(chi_eredita, 0)) + 1
			if chi_gradini != "":
				ladder_wins[chi_gradini] = int(ladder_wins.get(chi_gradini, 0)) + 1
			if chi_eredita != "" and chi_eredita == chi_trionfi:
				accordo_trionfi += 1
			if chi_eredita != "" and chi_eredita == chi_gradini:
				accordo_gradini += 1
			if chi_eredita != "" and chi_eredita == chi_durata:
				accordo_durata += 1
			var combinato: Dictionary = {}
			for entity_id in gradini:
				combinato[str(entity_id)] = int(gradini[entity_id]) + int(
					eredita.get(str(entity_id), 0)
				)
			var chi_combinato: String = _best(combinato)
			if chi_combinato != "" and chi_combinato == chi_trionfi:
				accordo_combinato += 1
			if chi_gradini != "" and chi_gradini == chi_trionfi:
				accordo_gradini_trionfi += 1
			if chi_combinato != "" and chi_gradini != "" and chi_combinato != chi_gradini:
				ribaltate += 1

	print("")
	print("== L'EREDITA' - %d saghe da %d anni, sui due tavoli%s ==" % [
		sagas, chronicles,
		(" - VARIANTE: solo quello che si poteva perdere" if solo_perdibili
			else (" - VARIANTE: la leggenda, cioe' quello che il tempo racconta ancora"
				if solo_leggende else ""))
	])
	print("")
	print("  Come si e' chiuso ogni salto d'era:")
	var ordine: Array = ["radicata", "fedele", "sopravvissuta", "distorta", "svanita"]
	var totale: int = 0
	for esito in ordine:
		totale += int(esiti.get(esito, 0))
	for esito in ordine:
		var quante: int = int(esiti.get(esito, 0))
		print("    %-14s +%d   %5d   %4.1f%%" % [
			esito, int(BONUS[esito]), quante,
			100.0 * float(quante) / float(maxi(1, totale))
		])
	print("")
	print("  Il vincitore dell'Eredita' e' anche...")
	print("    chi ha piu' Trionfi     %d su %d" % [accordo_trionfi, saghe_contate])
	print("    chi vince coi gradini   %d su %d" % [accordo_gradini, saghe_contate])
	print("    chi e' semplicemente durato di piu'  %d su %d" % [accordo_durata, saghe_contate])
	print("")
	print("  E la domanda vera: sommata ai gradini, l'Eredita' migliora o peggiora?")
	print("    vincitore coi soli gradini = chi ha piu' Trionfi   %d su %d" % [
		accordo_gradini_trionfi, saghe_contate
	])
	print("    vincitore con gradini + Eredita' = chi ha piu' Trionfi  %d su %d" % [
		accordo_combinato, saghe_contate
	])
	print("    saghe in cui l'Eredita' ribalta il vincitore        %d su %d" % [
		ribaltate, saghe_contate
	])
	print("")
	print("  Eredita' media per salto d'era, casa per casa")
	print("  (il vincolo del committente: una casa immortale non deve prendere")
	print("   punti solo perche' dura)")
	var case: Array = punti_per_casa.keys()
	case.sort()
	for entity_id in case:
		print("    %-14s %.2f  (%d salti)" % [
			str(entity_id), float(punti_per_casa[entity_id]) / float(
				maxi(1, int(salti_per_casa.get(str(entity_id), 1)))
			), int(salti_per_casa.get(str(entity_id), 0))
		])
	quit(0)


## La classificazione di una casa a un salto d'era.
func _classify(
	data: RefCounted, entity_id: String, previous: Dictionary, seat: Dictionary,
	solo_perdibili: bool = false, solo_leggende: bool = false
) -> String:
	var before: Dictionary = (previous.get("entities", {}) as Dictionary).get(
		entity_id, {}
	) as Dictionary
	if not bool(before.get("active", true)):
		return "svanita"
	var profile: Variant = (data.get("entity_profiles") as Dictionary).get(entity_id)
	if profile == null:
		return "sopravvissuta"
	var tiene: int = 0
	var leggenda: bool = false
	for voice in (profile as Dictionary).get("wants", []) as Array:
		var tag: String = str((voice as Dictionary).get("tag", ""))
		if solo_perdibili and not _perdibile(tag):
			continue
		if _somewhere(previous, before, tag):
			tiene += 1
		if _somewhere(previous, before, "legend:%s" % tag):
			leggenda = true
	var mutata: bool = bool(seat.get("transformed", false))
	if solo_leggende:
		# Qui non conta quanto tieni: conta se il mondo **racconta ancora**
		# quello che volevi lasciare. Radicata e' la leggenda; distorta e' aver
		# cambiato pelle senza lasciarne una.
		if leggenda:
			return "radicata"
		return "distorta" if mutata else "sopravvissuta"
	if tiene >= TIENE and leggenda and not mutata:
		return "radicata"
	if tiene >= TIENE:
		return "fedele"
	if mutata and tiene == 0:
		return "distorta"
	return "sopravvissuta"


## Un segno che il mondo sa togliere: condizioni, Pietre, insediamenti,
## Cicatrici, controllo. Le memorie no — quelle, una volta scritte, restano.
func _perdibile(tag: String) -> bool:
	for prefisso in ["condition:", "structure:", "settlement:", "scar:", "discovery:"]:
		if tag.begins_with(prefisso):
			return true
	return false


func _somewhere(previous: Dictionary, before: Dictionary, tag: String) -> bool:
	if (previous.get("global_tags", []) as Array).has(tag):
		return true
	if (before.get("tags", []) as Array).has(tag):
		return true
	for region_id in previous.get("regions", {}):
		if ((previous["regions"][str(region_id)] as Dictionary).get(
			"tags", []
		) as Array).has(tag):
			return true
	return false


## Chi sta piu' in alto, o "" se sono in parita': un pareggio non e' un
## vincitore, e contarlo come tale gonfierebbe gli accordi.
func _best(punti: Dictionary) -> String:
	var best: int = -999999
	var chi: Array = []
	for entity_id in punti:
		var quanto: int = int(punti[entity_id])
		if quanto > best:
			best = quanto
			chi = [str(entity_id)]
		elif quanto == best:
			chi.append(str(entity_id))
	return str(chi[0]) if chi.size() == 1 else ""


func _parse_args(args: PackedStringArray) -> Dictionary:
	var out: Dictionary = {}
	for arg in args:
		if str(arg).begins_with("--") and str(arg).contains("="):
			var pair: PackedStringArray = str(arg).substr(2).split("=")
			out[str(pair[0])] = str(pair[1])
	return out
