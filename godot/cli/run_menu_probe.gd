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
	## **Il seggio che non pesca mai** (domanda del committente: *«se un
	## giocatore non pesca carte, c'e' il rischio che non abbia carte per fare
	## tutti gli atti?»*). Acceso, la sonda salta ACQUISIRE ogni volta che
	## glielo offrono, e quello che resta si conta.
	var never_draws: bool = false

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
		# **Sceglie sempre la prima voce**, e non e' pigrizia: rispondendo «non
		# scelgo» il turno tornava alla policy e la sonda non vedeva mai il
		# **secondo** e il **terzo** passo del menu — quelli dove si scelgono il
		# bersaglio e la carta. Misurava il primo e credeva di aver visto tutto.
		#
		# Prendendo sempre la prima, la sonda gioca una partita sua — diversa da
		# quella della policy, e va detto — ma vede ogni menu che l'app
		# mostrerebbe a una persona, che e' quello che deve misurare.
		if labels.is_empty():
			return -1
		if never_draws:
			for i in range(labels.size()):
				var subject: Dictionary = (
					(subjects[i] if i < subjects.size() else {}) as Dictionary
				)
				if str(subject.get("verb", "")) != "ACQUIRE":
					return i
		return 0


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
	for argument in OS.get_cmdline_user_args():
		if str(argument) == "--senza-pescare":
			registro.never_draws = true
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

	_skips_the_draw = registro.never_draws
	_racconta(registro.menus)
	quit(0)


## Se questo giro ha saltato ACQUISIRE: serve solo al titolo del rapporto.
var _skips_the_draw: bool = false


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
	var con_effetto: int = 0
	var giocate: int = 0
	var bersagli: int = 0
	var con_effetto_qui: int = 0
	var solo_passa: int = 0
	var turni: int = 0
	var frasi: Dictionary = {}
	var piu_lunga: int = 0
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
			# **Dice anche cosa succede, o solo come si chiama** (D-492): una
			# voce che porta l'effetto della faccia va a capo.
			var about: Dictionary = subjects[i] as Dictionary
			var verbo: String = str(about.get("verb", ""))
			if verbo != "":
				verbi[verbo] = int(verbi.get(verbo, 0)) + 1
			# **Le voci che portano una carta da calare** (D-492): al secondo
			# passo il bersaglio, al terzo la carta. Il primo passo nomina il
			# verbo e basta — non c'e' ancora niente da calare — e non conta.
			var un_posto: bool = (
				about.has("region") or about.has("tension") or about.has("entity")
			)
			if str(about.get("asset", "")) != "":
				giocate += 1
				if str(labels[i]).contains("\n"):
					con_effetto += 1
			elif verbo != "" and un_posto:
				bersagli += 1
				if str(labels[i]).contains("\n"):
					con_effetto_qui += 1
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
		# **Chi resta senza carte** (la domanda del committente): un menu
		# dell'azione dove l'unica cosa da fare e' passare.
		if str((menu as Dictionary)["prompt"]).contains("cosa fai?"):
			turni += 1
			if labels.size() <= 1:
				solo_passa += 1
		var chiave: String = _famiglia(str((menu as Dictionary)["prompt"]))
		per_prompt[chiave] = int(per_prompt.get(chiave, 0)) + 1
		# **Quante frasi diverse si legge una persona** (ISSUES 136, punto 7).
		# Non quante domande: quante **frasi**. Una domanda che riscrive la sua
		# intestazione a ogni passo — «copre 1 di 3», «copre 2 di 3» — al tavolo
		# non e' la stessa domanda che continua: e' un cartello nuovo da
		# rileggere, e chi gioca lo rilegge.
		var frase: String = str((menu as Dictionary)["prompt"]).strip_edges()
		frasi[frase] = int(frasi.get(frase, 0)) + 1
		piu_lunga = maxi(piu_lunga, frase.length())

	print("")
	print("== SONDA DEI MENU — cosa vede chi gioca%s ==" % (
		", senza mai pescare" if _skips_the_draw else ""
	))
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
	print("**Quante frasi diverse si legge, per fare sempre le stesse cose**")
	print("  frasi di domanda diverse %d  (su %d menu)" % [frasi.size(), menus.size()])
	print("  la piu' lunga            %d caratteri" % piu_lunga)
	var lunghe: Array = frasi.keys()
	lunghe.sort_custom(func(a, b): return str(a).length() > str(b).length())
	for i in range(mini(3, lunghe.size())):
		print("    %s" % str(lunghe[i]).replace("\n", " / "))
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
	print("  voci che **nominano una carta**: %d" % giocate)
	print("  di quelle, dicono **cosa succede**: %d (%d%%)" % [
		con_effetto, con_effetto * 100 / maxi(giocate, 1),
	])
	print("  voci che sono **un bersaglio** (la carta si sceglie dopo): %d" % bersagli)
	print("  di quelle, con una carta sola dietro, dicono cosa succede: %d (%d%%)" % [
		con_effetto_qui, con_effetto_qui * 100 / maxi(bersagli, 1),
	])
	print("")
	print("**Occasioni in cui l'unica cosa da fare e' passare**: %d su %d (%d%%)" % [
		solo_passa, turni, solo_passa * 100 / maxi(turni, 1),
	])
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
