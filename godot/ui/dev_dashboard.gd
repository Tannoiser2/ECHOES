extends PanelContainer
## Il cruscotto: quello che le sonde misurano, dentro la partita (§25.14, D-054).
##
## Tutto quello che questo progetto ha imparato sul proprio gioco e arrivato da
## uno strumento da riga di comando - il margine, il silenzio, i Destini, il
## playtest - e ogni volta la stessa forma: qualcuno guarda un numero che nessuno
## stava guardando e trova che era li da quattro milestone. Il costo di quel giro
## e che bisogna esportare, rigiocare e rileggere un file, quindi lo si fa solo
## quando si sospetta gia qualcosa.
##
## Questo mette le stesse quattro tabelle **dentro la partita che si sta
## giocando**, aggiornate a ogni fase: le domande e chi le ha spinte, la scala di
## ogni Destino clausola per clausola, i Consigli con S/O/margine, e le ultime
## righe del registro degli Effect con la loro sorgente.
##
## **Mostra tutto, comprese le cose coperte**: il valore di una Tensione velata,
## la mano di tutti, chi ha spinto cosa. E' esattamente quello che serve a chi
## sviluppa e esattamente quello che rovina una partita, quindi lo dice in
## grande e sta dietro un tasto che nessuno preme per sbaglio.
##
## Non decide niente e non legge nessuna regola: come ogni altra vista, prende
## una sessione e disegna quello che c'e (D-038).

const EffectText := preload("res://scripts/core/effect_text.gd")

const SECTION: String = "[color=#e8b563][b]%s[/b][/color]"
const DIM: String = "[color=#8a8172]%s[/color]"
## Quante righe di registro tenere sott'occhio. Il registro intero di una
## Chronicle e trecento Effect: quello che serve guardando giocare e la coda.
const TAIL: int = 14

var _text: RichTextLabel
## Le spinte sulle Tensioni, divise per chi le ha fatte. Il registro le contiene
## tutte ma sommarle a ogni disegno vorrebbe dire rileggerlo intero ogni volta,
## e questa vista si ridisegna a ogni fase.
var _pushes: Dictionary = {}


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#12100e")
	style.border_color = Color("#c8553d")
	style.set_border_width_all(2)
	style.set_content_margin_all(14)
	add_theme_stylebox_override("panel", style)

	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.scroll_following = false
	_text.selection_enabled = true
	_text.add_theme_font_size_override("normal_font_size", 11)
	_text.add_theme_color_override("default_color", Color("#c9c2b4"))
	add_child(_text)


## Chi ha spinto quale domanda. Va agganciato alla sessione appena esiste:
## `effect_applied` passa di qui una volta per Effect, e la vista somma invece
## di rileggere.
func watch(session: RefCounted) -> void:
	_pushes = {}
	session.effect_applied.connect(
		func(effect: Dictionary) -> void:
			if str(effect["type"]) != "ADJUST_TENSION":
				return
			var id: String = str(effect["target"]["id"])
			var kind: String = str(effect["source"]["kind"])
			if not _pushes.has(id):
				_pushes[id] = {}
			_pushes[id][kind] = int(_pushes[id].get(kind, 0)) + int(effect["payload"]["delta"])
	)


func render(session: RefCounted) -> void:
	_text.clear()
	if session == null:
		_text.append_text(DIM % "Nessuna partita in corso.")
		return
	_text.append_text("\n".join(PackedStringArray(_lines(session))))


func _lines(session: RefCounted) -> Array:
	var world: Dictionary = session.world
	var data: RefCounted = session.data
	var out: Array = []

	out.append("[color=#c8553d][b]CRUSCOTTO[/b] — mostra anche quello che al tavolo e coperto[/color]")
	out.append("")

	out.append(SECTION % "L'ANNO")
	out.append(
		"%s, anno %d · atto %d round %d · %s" % [
			str(data.chronicles[str(world["chronicle_id"])]["title"]),
			int(world["year"]), int(world["act"]), int(world["round"]), str(world["phase"]),
		]
	)
	out.append(DIM % ("seme %d · %d estrazioni · %d Effect · %d Consigli" % [
		int(world["rng_seed"]), int(session.rng.get_draws()),
		(world["effect_log"] as Array).size(), int(world["confluence_count"]),
	]))
	out.append("")

	# --- le domande, e chi le ha spinte -------------------------------------
	out.append(SECTION % "LE DOMANDE")
	out.append(DIM % "  domanda            ora  soglia   mondo  tavolo  consigli")
	for tension_id in world["tensions"]:
		var id: String = str(tension_id)
		var moved: Dictionary = _pushes.get(id, {})
		out.append("  %-18s %3d %6d %7d %7d %9d%s" % [
			str(data.tensions[id]["title"]),
			session.tensions.value(id), session.tensions.threshold(id),
			int(moved.get("system", 0)), int(moved.get("action", 0)),
			int(world["tensions"][id]["resolved_count"]),
			DIM % "  velata" if session.tensions.is_veiled(id) else "",
		])
	out.append("")

	# --- le scale dei Destini, clausola per clausola -------------------------
	out.append(SECTION % "CHI VUOLE COSA")
	for entity_id in world["turn_order"]:
		var seat: String = str(entity_id)
		var destiny: Dictionary = data.destinies[session.service.destiny_of(seat)]
		out.append("  [b]%s[/b] — %s   %s" % [
			session.service.name_of(seat), str(destiny["title"]),
			DIM % ("mano %d · %s" % [
				session.service.hand_size(seat),
				", ".join(PackedStringArray(session.service.regions_with_presence(seat))),
			]),
		])
		for level in ["minimum", "victory", "triumph"]:
			var marks: Array = []
			for condition in destiny[str(level)]["conditions"]:
				var holds: bool = session.destinies.conditions.holds(condition, {})
				# `[x]` e `[ ]`, come li scrive gia il resto del gioco: il segno di
				# spunta non e nel font e usciva come un quadratino vuoto, che in
				# una tabella di clausole vere e false e' il peggior carattere
				# possibile.
				marks.append("%s%s[/color]" % [
					"[color=#6fa88a][x] " if holds else "[color=#8a8172][ ] ",
					str((condition as Dictionary).get("label", condition["type"])),
				])
			out.append("    %-9s %s" % [str(level), " · ".join(PackedStringArray(marks))])
		out.append("")

	# --- i Consigli ----------------------------------------------------------
	var councils: Array = session.chronicle.confluence_results
	if not councils.is_empty():
		out.append(SECTION % "I CONSIGLI")
		for result in councils:
			out.append("  %-18s %-16s %-18s S%d O%d M%+d" % [
				str(data.tensions[str(result["tension_id"])]["title"]),
				session.service.name_of(str(result["proponent"])),
				str(result["outcome"]),
				int(result["support_total"]),
				int(result["oppose_total"]), int(result["margin"]),
			])
		out.append("")

	# --- la coda del registro ------------------------------------------------
	out.append(SECTION % "IL REGISTRO, ULTIME RIGHE")
	var log: Array = world["effect_log"]
	for i in range(maxi(0, log.size() - TAIL), log.size()):
		var effect: Dictionary = log[i]
		out.append("  %s %s" % [
			DIM % ("[%s/%s]" % [
				str(effect["source"]["kind"]), str(effect["source"]["id"])
			]),
			EffectText.say(effect, session.data),
		])
	return out
