extends SceneTree
## **Cosa vede chi gioca, quando l'app gli chiede qualcosa.**
##
##   godot --headless --path godot --script res://cli/run_menu_probe.gd -- --runs=20
##
## La sonda si siede a un seggio come una persona — `SeatDecider` con un `io`
## che **registra invece di scegliere** — e guarda i menu che le arrivano: il
## testo della domanda, le voci, e cosa ognuna dice di se'. Poi risponde «non
## scelgo», e la policy gioca il turno: la partita va avanti da sola e la sonda
## ha visto tutto senza cambiare niente.
##
## Il numero che cerca e' quello che il committente ha visto giocando: **la
## stessa voce, parola per parola, ripetuta N volte nello stesso menu.** Sei
## «Sbarrare la strada · a Porto Cinerino» in fila non sono sei scelte: sono una
## scelta che lo schermo non sa distinguere. La sonda le conta e dice **cosa le
## distingue davvero**, guardando i loro bersagli — se non le distingue niente,
## sono doppioni veri.

const DataSet := preload("res://scripts/core/data_set.gd")
const GameSession := preload("res://scripts/chronicle/game_session.gd")
const SeatDecider := preload("res://scripts/seat/seat_decider.gd")


## Un `io` che non sceglie: guarda, scrive, e lascia decidere alla policy.
class Registro extends RefCounted:
	var menus: Array = []

	func say(_text: String) -> void:
		pass

	## **Si conta quello che si vede** (D-490). Le scorciatoie — la stessa
	## giocata che la mano e la mappa offrono col gesto — viaggiano nella lista
	## ma non diventano pulsanti: contarle direbbe che il menu e' lungo come
	## prima, mentre chi gioca ne vede sette.
	func choose(prompt: String, labels: Array, subjects: Array = []) -> int:
		var seen: Array = []
		var about: Array = []
		var hidden: int = 0
		for i in range(labels.size()):
			var subject: Dictionary = (subjects[i] if i < subjects.size() else {}) as Dictionary
			if bool(subject.get("shortcut", false)):
				hidden += 1
				continue
			seen.append(labels[i])
			about.append(subject)
		menus.append({
			"prompt": prompt, "labels": seen, "subjects": about, "shortcuts": hidden,
		})
		return -1


func _initialize() -> void:
	var runs: int = 20
	var chronicle_id: String = "CHR_00"
	var first_seed: int = 3000
	for argument in OS.get_cmdline_user_args():
		if str(argument).begins_with("--runs="):
			runs = int(str(argument).split("=")[1])
		elif str(argument).begins_with("--seed="):
			first_seed = int(str(argument).split("=")[1])
		elif str(argument).begins_with("--chronicle="):
			chronicle_id = str(argument).split("=")[1]

	var data: RefCounted = DataSet.new()
	if not data.load_from("res://data"):
		for error in data.errors:
			printerr("  %s" % error)
		quit(3)
		return

	var registro: Registro = Registro.new()
	for i in range(runs):
		var seats: Array = GameSession.seats_for(data, chronicle_id, first_seed + i)
		var session: RefCounted = GameSession.new(data)
		session.setup(chronicle_id, seats, first_seed + i)
		# Una persona sola al primo seggio: gli altri tre restano policy, che e'
		# il tavolo di D-038 e anche quello che il committente ha giocato.
		var table: RefCounted = SeatDecider.new([str(seats[0])], session.log)
		table.io = registro
		await session.run(table)
		session.dispose()

	_racconta(registro.menus)
	quit(0)


func _racconta(menus: Array) -> void:
	var voci: int = 0
	var senza_posto: int = 0
	var piu_lungo: int = 0
	var doppie_menu: int = 0
	var doppie_voci: int = 0
	var per_prompt: Dictionary = {}
	var scorciatoie: int = 0
	var esempi: Array = []
	var distinzioni: Dictionary = {}
	var verbi: Dictionary = {}
	for menu in menus:
		var labels: Array = (menu as Dictionary)["labels"] as Array
		var subjects: Array = (menu as Dictionary)["subjects"] as Array
		voci += labels.size()
		piu_lungo = maxi(piu_lungo, labels.size())
		var gruppi: Dictionary = {}
		for i in range(labels.size()):
			var testo: String = str(labels[i])
			var indici: Array = gruppi.get(testo, []) as Array
			indici.append(i)
			gruppi[testo] = indici
			if not _ha_un_posto(subjects[i] as Dictionary):
				senza_posto += 1
			var verbo: String = str((subjects[i] as Dictionary).get("verb", ""))
			if verbo != "":
				verbi[verbo] = int(verbi.get(verbo, 0)) + 1
		var doppie_qui: int = 0
		for testo in gruppi:
			var indici: Array = gruppi[testo] as Array
			if indici.size() < 2:
				continue
			doppie_qui += indici.size()
			var cambia: String = _cosa_cambia(subjects, indici)
			distinzioni[cambia] = int(distinzioni.get(cambia, 0)) + 1
			if esempi.size() < 8:
				esempi.append("%dx  %s   [%s]" % [indici.size(), str(testo), cambia])
		if doppie_qui > 0:
			doppie_menu += 1
			doppie_voci += doppie_qui
		scorciatoie += int((menu as Dictionary).get("shortcuts", 0))
		var chiave: String = _famiglia(str((menu as Dictionary)["prompt"]))
		per_prompt[chiave] = int(per_prompt.get(chiave, 0)) + 1

	print("")
	print("== SONDA DEI MENU — cosa vede chi gioca ==")
	print("")
	print("Menu offerti a una persona: %d" % menus.size())
	print("  voci in tutto            %d  (%.1f per menu, il piu' lungo %d)" % [
		voci, float(voci) / maxf(menus.size(), 1), piu_lungo,
	])
	print("  voci senza un posto      %d (%d%%) — restano bottoni" % [
		senza_posto, senza_posto * 100 / maxi(voci, 1),
	])
	print("  scorciatoie, non viste   %d — la mano e la mappa le offrono col gesto" % scorciatoie)
	print("")
	print("**Voci ripetute parola per parola dentro lo stesso menu**")
	print("  menu che ne hanno       %d su %d (%d%%)" % [
		doppie_menu, menus.size(), doppie_menu * 100 / maxi(menus.size(), 1),
	])
	print("  voci coinvolte          %d su %d (%d%%)" % [
		doppie_voci, voci, doppie_voci * 100 / maxi(voci, 1),
	])
	print("")
	print("  e cosa le distingue davvero:")
	for chiave in _ordinate(distinzioni):
		print("    %-40s %d volte" % [str(chiave), int(distinzioni[chiave])])
	print("")
	print("  qualche esempio:")
	for esempio in esempi:
		print("    %s" % esempio)
	print("")
	print("**I verbi che una persona si vede offrire** (i sette di §10):")
	for chiave in ["MOVE", "SCHEME", "INFLUENCE", "FORGE", "CLAIM", "ACQUIRE", "MARK"]:
		print("  %-12s %d" % [str(chiave), int(verbi.get(chiave, 0))])
	print("")
	print("Domande, per famiglia:")
	for chiave in _ordinate(per_prompt):
		print("  %-40s %d" % [str(chiave), int(per_prompt[chiave])])


static func _ha_un_posto(about: Dictionary) -> bool:
	for field in ["region", "tension", "entity", "box"]:
		if str(about.get(field, "")) != "":
			return true
	return false


## Cosa cambia fra due voci che si leggono identiche. Se non cambia niente che
## la sonda sappia guardare, sono **doppioni veri**.
static func _cosa_cambia(subjects: Array, indici: Array) -> String:
	var chiavi: Dictionary = {}
	for i in indici:
		for chiave in (subjects[int(i)] as Dictionary):
			chiavi[str(chiave)] = true
	var diverse: Array = []
	for chiave in chiavi:
		var visto: Dictionary = {}
		for i in indici:
			visto[str((subjects[int(i)] as Dictionary).get(chiave, ""))] = true
		if visto.size() > 1:
			diverse.append(str(chiave))
	if diverse.is_empty():
		return "niente: sono doppioni"
	diverse.sort()
	return " + ".join(PackedStringArray(diverse))


static func _famiglia(prompt: String) -> String:
	if prompt.contains("azione"):
		return "l'azione del turno"
	if prompt.contains("rilanci"):
		return "il rilancio al Consiglio"
	if prompt.contains("domanda"):
		return "quale domanda poni"
	if prompt.contains("impegn") or prompt.contains("Impegn"):
		return "quali carte impegni"
	if prompt.contains("Tema"):
		return "quale Tema scaldi"
	if prompt.contains("parte") or prompt.contains("Con "):
		return "con quale parte stai"
	return prompt.strip_edges().substr(0, 38)


static func _ordinate(conto: Dictionary) -> Array:
	var chiavi: Array = conto.keys()
	chiavi.sort_custom(func(a, b): return int(conto[a]) > int(conto[b]))
	return chiavi
