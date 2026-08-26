extends VBoxContainer
## The year's questions, and where the seat stands on its own ladder.
##
## Same contract as the map: `render(session, viewer_id)` and nothing else. A
## Tension shows a number only to a seat entitled to read it, so a veiled
## question the viewer has not scouted is drawn as a bar with no fill and the
## word "velata" - present, unreadable, and clearly *there*, which is the whole
## point of a veiled Tension.

## The five levels a relation can sit at, warmest last, with the colour each one
## is drawn in. FORGE moves a relation one step along this list.
const RELATIONS: Dictionary = {
	"ENEMY": "#c8553d", "HOSTILE": "#b06b8f", "NEUTRAL": "#8a8172",
	"ALLY": "#6fa88a", "BOUND": "#e8b563",
}

const CardArt := preload("res://ui/card_art.gd")
const DropSlot := preload("res://ui/drop_slot.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

var _rows: Dictionary = {}
var _destiny: VBoxContainer
var _casata_card: TextureRect
var _destiny_card: TextureRect
var _relations: VBoxContainer

## I posti dove una carta puo' cadere: `"tension:ID"` e `"entity:ID"` ->
## `DropSlot`. Lo schermo li collega una volta sola, quando nascono (D-231).
var slots: Dictionary = {}

## Emesso quando una carta cade su una domanda o su una casa, con le scelte che
## quella carta porta per quel soggetto.
signal card_dropped(indices: Array)

## Qualcuno vuole leggere la scheda di questa domanda (D-236).
##
## Non e' una mossa: e' guardare. Al tavolo la scheda della Tensione la prendi
## in mano quando vuoi, e la rimetti giu'; da quando si gioca all'app e non al
## cartone, quel gesto deve esistere sullo schermo o non esiste affatto.
signal tension_opened(tension_id: String)

## Una carta **tenuta in mano** e' stata posata su questa riga (D-239).
##
## Su un tablet non esiste il trascinamento con cui e' nato tutto questo: il dito
## preme e scorre, e il gesto che sul desktop prende una carta li' fa scorrere la
## pagina. Il tocco pero' c'e' sempre, e sono due: **prendi** la carta, **posi**
## dove la vuoi usare. E' lo stesso gesto del tavolo vero, diviso in due tempi.
signal card_placed(index: int)

## `field:key -> indice della scelta`, riempito da chi tiene la carta in mano.
## Vuoto quando non c'e' niente in mano, e allora le righe tornano a essere
## quello che erano: un clic sulla domanda apre la sua scheda.
var held_places: Dictionary = {}

## La regola che questa Chronicle gioca, e il mucchio piu alto fra le domande
## che il seggio puo' leggere. Ricalcolati a ogni `render`.
var _at_end_of_act: bool = false
var _hottest: int = 1
var _leaders: int = 0
## La pista del Calore (PZ-1): se un Tema e' caldo, e' lei che sceglie la
## Domanda di fine Atto, e il mucchio piu' alto torna a essere una classifica.
var _any_theme_hot: bool = false


## Accende i posti dove la carta tenuta in mano puo' andare, e spegne gli altri.
## Chiamata da chi tiene la carta; il pannello non sa cosa sia una carta.
func hold(places: Dictionary) -> void:
	held_places = places.duplicate()
	for where in slots:
		(slots[where] as Object).call("light", held_places.has(str(where)))
var _claims: VBoxContainer
var _claims_header: Label
## Le righe che dicono a cosa serve il blocco: seguono la sorte della loro
## intestazione, perche' una spiegazione senza la cosa spiegata e' rumore.
var _claims_note: Label
var _signs_note: Label
## Il blocco della strategia dichiarata (D-289): cosa questa casa vuole
## lasciare nel mondo, e a che punto e'.
var _profile: VBoxContainer
var _profile_header: Label
var _profile_note: Label
var _signs: VBoxContainer
var _signs_header: Label
var _title: Label


func _ready() -> void:
	add_theme_constant_override("separation", 4)


func render(session: RefCounted, viewer_id: String) -> void:
	if _title == null:
		_build()
	# **Quale regola sta giocando questa Chronicle** (D-243). Col Consiglio a
	# fine Atto la soglia non apre piu' niente ([D-214](DECISIONS.md#d-214)) e
	# quello che conta e' **chi e' il mucchio piu alto**: e' quella domanda che
	# va al tavolo. La traccia continuava a dire «12/18», cioe' insegnava una
	# regola che questo gioco non ha piu'.
	_at_end_of_act = bool(
		((session.data.chronicles.get(
			str(session.world.get("chronicle_id", "")), {}
		) as Dictionary).get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)
	)
	_render_heat(session)
	_hottest = 1
	_leaders = 0
	for tension_id in session.world["tensions"]:
		var here: int = session.service.visible_tension_value(str(tension_id), viewer_id)
		if here > _hottest:
			_hottest = here
			_leaders = 1
		elif here == _hottest and here > 0:
			_leaders += 1
	for tension_id in _sorted(session.world["tensions"].keys()):
		var id: String = str(tension_id)
		if not _rows.has(id):
			_rows[id] = _add_row(str(session.data.tensions[id]["title"]), "tension", id)
		_update_row(_rows[id], session, id, viewer_id)
	_update_relations(session, viewer_id)
	_update_claims(session, viewer_id)
	_update_signs(session, viewer_id)
	_update_destiny(session, viewer_id)
	_update_profile(session, viewer_id)


func _build() -> void:
	_title = Label.new()
	_title.text = "LE QUESTIONI GIA' APERTE"
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", Color("#8a8172"))
	add_child(_title)
	# **Ogni blocco della colonna dice cosa e', in una riga** (D-282).
	#
	# Parola del committente: *«sulla colonna di destra non si capisce nulla»*,
	# seguita dall'elenco di quello che ci trovava — i mazzetti, «le domande
	# dell'anno (?)», i rapporti, i segni, il Destino, «poi ancora quattro
	# tensioni (?)». Aveva ragione due volte: **le stesse informazioni erano
	# li' tre volte** (i sei mazzetti disegnati, la riga CALORE che li
	# ripeteva a parole, le quattro barre), e nessun blocco diceva a cosa
	# servisse. Al tavolo non serve: una plancia ha le sue caselle stampate
	# accanto. Sullo schermo la riga sotto l'intestazione **e' quella stampa**.
	add_child(_note(
		"Le domande gia' sul tavolo quest'anno. INFLUENZARE e TRAMARE ne muovono"
		+ " la pressione; se a fine Atto nessun mazzetto e' caldo, il Consiglio"
		+ " si apre sulla piu' alta di queste."
	))


## I mazzetti dei Temi, in una riga (D-261): quanti gettoni **coperti** ha
## ognuno, e la carta girata dove c'e'. I valori non si dicono — si scoprono a
## fine Atto, quando i mazzetti si girano — quindi lo schermo mostra quello che
## il tavolo vede: «CALORE  Potere ·2 → La Successione   Vie ·1». I Temi a
## zero non si elencano: sul tavolo si vede il mazzetto fermo, sullo schermo
## sarebbe solo rumore.
func _render_heat(session: RefCounted) -> void:
	_any_theme_hot = false
	if not _at_end_of_act:
		return
	var counts: Dictionary = session.world.get("theme_tokens", {}) as Dictionary
	var fronts: Dictionary = session.world.get("theme_front", {}) as Dictionary
	var said: PackedStringArray = PackedStringArray()
	for theme_id in session.data.themes:
		var fallen: int = int(counts.get(str(theme_id), 0))
		if fallen <= 0:
			continue
		var title: String = str(session.data.themes[str(theme_id)]["title"])
		var line: String = "%s ·%d" % [title, fallen]
		var front: String = str(fronts.get(str(theme_id), ""))
		if front != "" and session.data.tensions.has(front):
			line += " → %s" % str(session.data.tensions[front]["title"])
		said.append(line)
	_any_theme_hot = not said.is_empty()


## La riga di una domanda, dentro il suo posto: da D-231 una carta che
## influenza o trama ci puo' cadere sopra, invece di essere un bottone.
func _add_row(title: String, field: String = "", key: String = "") -> Dictionary:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	add_child(_wrapped(box, field, key))

	var header := HBoxContainer.new()
	box.add_child(header)
	var name := Label.new()
	name.text = title
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.add_theme_font_size_override("font_size", 13)
	name.add_theme_color_override("font_color", Color("#d9d2c5"))
	header.add_child(name)
	var value := Label.new()
	value.add_theme_font_size_override("font_size", 13)
	header.add_child(value)

	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	box.add_child(bar)
	return {"value": value, "bar": bar}


func _update_row(row: Dictionary, session: RefCounted, tension_id: String, viewer_id: String) -> void:
	var threshold: int = session.tensions.threshold(tension_id)
	var visible_value: int = session.service.visible_tension_value(tension_id, viewer_id)
	var bar: ProgressBar = row["bar"]
	var value: Label = row["value"]
	bar.max_value = float(maxi(threshold, 1))

	if visible_value < 0:
		bar.value = 0.0
		value.text = "velata"
		value.add_theme_color_override("font_color", Color("#5f584c"))
		return
	bar.value = float(visible_value)
	if _at_end_of_act:
		# **Il conto e' relativo, non assoluto.** Nessun numero da raggiungere:
		# c'e' una gara fra quattro domande, e a fine Atto va al Consiglio quella
		# davanti. La barra si misura sul mucchio piu alto, cosi' le quattro
		# righe insieme dicono *la classifica* invece di quattro percentuali di
		# una soglia che non apre niente.
		bar.max_value = float(maxi(_hottest, 1))
		var leading: bool = visible_value >= _hottest and visible_value > 0
		# Con la pista calda la Domanda dell'Atto la sceglie il Tema (PZ-1):
		# il mucchio piu' alto resta una classifica, e dirgli «va al
		# Consiglio» sarebbe insegnare la regola vecchia.
		var crown: String = "  ·  a pari" if _leaders > 1 else "  ·  va al Consiglio"
		if _any_theme_hot:
			crown = "  ·  il mucchio piu' alto"
		value.text = "%d%s" % [visible_value, crown if leading else ""]
		var hot: Color = Color("#6fa88a")
		if leading:
			hot = Color("#e8b563") if _leaders > 1 else Color("#c8553d")
		elif visible_value >= _hottest - 1 and _hottest > 1:
			hot = Color("#c9a14a")
		value.add_theme_color_override("font_color", hot)
		_paint_bar(bar, hot)
		return
	value.text = "%d/%d" % [visible_value, threshold]
	# The colour is the warning: a question one step from its threshold is the
	# one worth spending an action on, and it should be findable at a glance.
	var margin: int = threshold - visible_value
	var tint: Color = Color("#6fa88a")
	if margin <= 0:
		tint = Color("#c8553d")
	elif margin <= 1:
		tint = Color("#e8b563")
	value.add_theme_color_override("font_color", tint)
	_paint_bar(bar, tint)


## Il colore della barra di una domanda. Estratto perche' adesso lo chiedono in
## due, e due copie della stessa riga sono due posti dove smettere di essere
## d'accordo.
func _paint_bar(bar: ProgressBar, tint: Color) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = tint
	bar.add_theme_stylebox_override("fill", fill)


## Where you stand with the other three. Public information - FORGE announces
## itself and the terminal has printed the level inside its own action labels
## since 0.0 - but until 0.1.6 the only way to read it in the browser was to
## look at a button offering to break it. Destinies count these levels, so a
## player who cannot see them is being scored on something invisible.
func _update_relations(session: RefCounted, viewer_id: String) -> void:
	if _relations == null:
		add_child(_spacer())
		var header := Label.new()
		header.text = "I RAPPORTI"
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(header)
		add_child(_note(
			"Come stai con le altre case. FORGIARE sposta un rapporto di un passo, e i Destini li contano."
		))
		_relations = VBoxContainer.new()
		_relations.add_theme_constant_override("separation", 1)
		add_child(_relations)

	for child in _relations.get_children():
		child.queue_free()
		_relations.remove_child(child)
	if viewer_id == "":
		return

	for entity_id in session.world["turn_order"]:
		var other: String = str(entity_id)
		if other == viewer_id:
			continue
		var level: String = session.service.relation_level(viewer_id, other)
		var row := HBoxContainer.new()
		# Anche la riga di un rapporto e' un posto: FORGIARE parla a una casa,
		# e questa e' la casa (D-231).
		_relations.add_child(_wrapped(row, "entity", other))

		var name := Label.new()
		name.text = session.service.name_of(other)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name.add_theme_font_size_override("font_size", 12)
		name.add_theme_color_override("font_color", Color("#c9bfae"))
		row.add_child(name)

		var value := Label.new()
		value.text = level.to_lower()
		value.add_theme_font_size_override("font_size", 12)
		value.add_theme_color_override("font_color", Color(str(RELATIONS.get(level, "#8a8172"))))
		row.add_child(value)


## I Diritti sul tavolo (l'inventario dell'app, ISSUES 22): un Claim creato e'
## un fatto pubblico - l'azione si annuncia - ma fin qui viveva solo nel
## verbale, e un giocatore non poteva guardare lo schermo e sapere chi tiene
## un diritto pronto a forzare un Consiglio. Il proprio in ambra, gli altrui
## nel colore neutro, il dominio con la sua parola italiana.
func _update_claims(session: RefCounted, viewer_id: String) -> void:
	if _claims == null:
		add_child(_spacer())
		_claims_header = Label.new()
		_claims_header.text = "I DIRITTI"
		_claims_header.add_theme_font_size_override("font_size", 12)
		_claims_header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(_claims_header)
		_claims_note = _note(
			"Chi ha rivendicato cosa: un Diritto maturo apre un secondo Consiglio nell'Atto."
		)
		add_child(_claims_note)
		_claims = VBoxContainer.new()
		_claims.add_theme_constant_override("separation", 1)
		add_child(_claims)

	for child in _claims.get_children():
		child.queue_free()
		_claims.remove_child(child)
	var shown: int = 0
	for claim in session.world.get("claims", []):
		var holder: String = str(claim.get("entity_id", ""))
		var line := Label.new()
		line.text = "%s — %s (atto %d)" % [
			session.service.name_of(holder),
			SignLabels.domain(str(claim.get("domain", ""))),
			int(claim.get("act", 0)),
		]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override(
			"font_color", Color("#e8b563") if holder == viewer_id else Color("#c9bfae")
		)
		_claims.add_child(line)
		shown += 1
	# Senza diritti la sezione sparisce, come i segni: niente intestazioni vuote.
	_claims_header.visible = shown > 0
	_claims_note.visible = shown > 0
	_claims.visible = shown > 0


## I segni che questa casa porta con sé - la fama, le scoperte, la scorta
## giurata, la porta sbarrata (ISSUES 22, D-107). Da quando i segni hanno un
## dente (D-105), un giocatore che non vede i propri viene giudicato da regole
## invisibili. Le parole vengono dal dizionario condiviso: le stesse dei
## segnalini di cartone.
func _update_signs(session: RefCounted, viewer_id: String) -> void:
	if _signs == null:
		add_child(_spacer())
		_signs_header = Label.new()
		_signs_header.text = "I SEGNI DELLA CASA"
		_signs_header.add_theme_font_size_override("font_size", 12)
		_signs_header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(_signs_header)
		_signs_note = _note(
			"Quello che la tua casa si porta addosso: fama, scoperte, promesse. Carte, Domande e Destini li leggono."
		)
		add_child(_signs_note)
		_signs = VBoxContainer.new()
		_signs.add_theme_constant_override("separation", 1)
		add_child(_signs)

	for child in _signs.get_children():
		child.queue_free()
		_signs.remove_child(child)
	var holder: Variant = session.world["entities"].get(viewer_id)
	if holder == null:
		_signs_header.visible = false
		_signs_note.visible = false
		_signs.visible = false
		return
	var tags: Array = (holder["tags"] as Array).duplicate()
	tags.sort()
	var shown: int = 0
	for tag in tags:
		var line := Label.new()
		line.text = SignLabels.label(str(tag), session.data)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 12)
		line.add_theme_color_override(
			"font_color",
			Color("#c8553d") if str(tag).begins_with("evicted:") else Color("#c9bfae")
		)
		_signs.add_child(line)
		shown += 1
	# Senza segni la sezione sparisce: un'intestazione sopra il nulla è rumore.
	_signs_header.visible = shown > 0
	_signs_note.visible = shown > 0
	_signs.visible = shown > 0


## La riga che dice a cosa serve il blocco sopra (D-282). Piccola e grigia:
## si legge la prima volta e poi si smette di vederla, che e' esattamente il
## comportamento di una scritta stampata sulla plancia.
func _note(text: String) -> Label:
	var line := Label.new()
	line.text = text
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.add_theme_font_size_override("font_size", 10)
	line.add_theme_color_override("font_color", Color("#6c6457"))
	return line


## **Cosa vuoi lasciare nel mondo** (D-289).
##
## Il Destino dice come si vince, e sta gia' qui sopra. Questo dice l'altra
## meta': quali segni questa casa vuole vedere sul tavolo a fine anno, e quali
## non vuole vederci — con accanto **se ci sono adesso**, perche' una strategia
## che non si puo' controllare a colpo d'occhio non e' una strategia, e' un
## foglietto.
##
## Legge il profilo strategico dai dati (`data/design_matrix`): la stessa
## fonte che il cervello usa per scegliere. Una casa senza profilo non mostra
## niente — la scatola ne ha otto e i profili sono quattro.
func _update_profile(session: RefCounted, viewer_id: String) -> void:
	if _profile == null:
		add_child(_spacer())
		_profile_header = Label.new()
		_profile_header.text = "COSA RESTERA' DI TE"
		_profile_header.tooltip_text = (
			"La strategia dichiarata di questa casa: i segni che vuole vedere nel"
			+ " mondo a fine partita, e quelli che non vuole."
		)
		_profile_header.add_theme_font_size_override("font_size", 12)
		_profile_header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(_profile_header)
		_profile_note = _note(
			"I segni che questa casa vuole vedere sul tavolo a fine anno, e quelli che non vuole. In oro quelli che ci sono adesso."
		)
		add_child(_profile_note)
		_profile = VBoxContainer.new()
		_profile.add_theme_constant_override("separation", 1)
		add_child(_profile)

	for child in _profile.get_children():
		child.queue_free()
		_profile.remove_child(child)
	var profiles: Variant = session.data.get("entity_profiles")
	var mine: Variant = null if profiles == null else (profiles as Dictionary).get(viewer_id)
	var shown: bool = mine != null
	_profile_header.visible = shown
	_profile_note.visible = shown
	_profile.visible = shown
	if not shown:
		return

	var said := Label.new()
	said.text = str((mine as Dictionary).get("in_one_line", ""))
	said.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	said.add_theme_font_size_override("font_size", 11)
	said.add_theme_color_override("font_color", Color("#c9bfae"))
	_profile.add_child(said)

	for pair in [["wants", "vuoi", "#6fa88a"], ["fears", "temi", "#c8553d"]]:
		for voice in (mine as Dictionary).get(str((pair as Array)[0]), []) as Array:
			var tag: String = str((voice as Dictionary).get("tag", ""))
			var here: bool = _world_carries(session, tag)
			var row := Label.new()
			row.text = "%s  %s%s" % [
				str((pair as Array)[1]), SignLabels.label(tag, session.data),
				"  ·  c'e'" if here else "",
			]
			row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			row.add_theme_font_size_override("font_size", 11)
			row.add_theme_color_override(
				"font_color", Color("#e8b563") if here else Color(str((pair as Array)[2]))
			)
			row.tooltip_text = str((voice as Dictionary).get("why", ""))
			_profile.add_child(row)


## Il segno e' sul tavolo adesso? Fatto del mondo, segno di una Regione, o segno
## di una casa: le tre case in cui un segno puo' vivere (D-259).
func _world_carries(session: RefCounted, tag: String) -> bool:
	if (session.world.get("global_tags", []) as Array).has(tag):
		return true
	for region_id in session.world.get("regions", {}):
		if ((session.world["regions"][str(region_id)] as Dictionary).get(
			"tags", []
		) as Array).has(tag):
			return true
	for entity_id in session.world.get("entities", {}):
		if ((session.world["entities"][str(entity_id)] as Dictionary).get(
			"tags", []
		) as Array).has(tag):
			return true
	return false


func _spacer() -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	return spacer


## The ladder, with the rungs that hold already ticked. A player who cannot read
## their own goal cannot steer towards it.
func _update_destiny(session: RefCounted, viewer_id: String) -> void:
	if _destiny == null:
		add_child(_spacer())
		var header := Label.new()
		header.text = "IL TUO DESTINO"
		header.tooltip_text = "La casa che giochi, e quello per cui e' venuta al tavolo."
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color("#8a8172"))
		add_child(header)
		add_child(_note(
			"Chi sei e cosa vuoi: le due carte che dicono a che gioco stai giocando quest'anno."
		))
		# I tarocchi dietro il paravento (D-101): la Casata e il Destino del
		# seggio sono le carte 70x120 dei fogli di stampa - il Destino lo vede
		# solo chi lo giura, come al tavolo, perche' questo pannello e' gia'
		# disegnato per il solo viewer.
		# **Due carte senza didascalia non sono due carte: sono due figure**
		# (D-244). Stavano qui da D-101, grandi e mute, e la domanda che si e'
		# presa e' quella giusta: *«le due carte destino cosa servono?»*. Al
		# tavolo fisico la risposta e' nella forma del cartoncino e in dove sta
		# posato; sullo schermo no, e allora si scrive.
		var tarots := HBoxContainer.new()
		tarots.add_theme_constant_override("separation", 6)
		add_child(tarots)
		_casata_card = _tarot()
		tarots.add_child(_titled(_casata_card, "CHI SEI"))
		_destiny_card = _tarot()
		tarots.add_child(_titled(_destiny_card, "COSA VUOI"))
		_destiny = VBoxContainer.new()
		_destiny.add_theme_constant_override("separation", 2)
		add_child(_destiny)

	for child in _destiny.get_children():
		child.queue_free()
		_destiny.remove_child(child)
	if viewer_id == "":
		return
	var entity: Variant = session.data.entities.get(viewer_id)
	if entity == null:
		return
	var destiny: Variant = session.data.destinies.get(session.service.destiny_of(viewer_id))
	if destiny == null:
		return
	# Il tarocco segue la vita (D-111): quando il seggio si trasforma, sul
	# tavolo si posa la carta della vita nuova - qui come al tavolo fisico.
	var casata_id: String = viewer_id
	var seat_state: Dictionary = session.world["entities"].get(viewer_id, {})
	var life_index: int = int(seat_state.get("incarnation", 0))
	var lives: Array = entity.get("incarnations", [])
	if life_index > 0 and life_index < lives.size():
		casata_id = str(lives[life_index]["id"])
	_casata_card.texture = CardArt.texture_for("entity", casata_id, session.data)
	_destiny_card.texture = CardArt.texture_for(
		"destiny", session.service.destiny_of(viewer_id), session.data
	)
	# E sotto ognuna il suo nome: la carta e' un'immagine, il nome e' il fatto.
	_caption(_casata_card, str(
		(session.world["entities"].get(viewer_id, {}) as Dictionary).get(
			"name", (entity as Dictionary)["name"]
		)
	))
	_caption(_destiny_card, str((destiny as Dictionary)["title"]))
	# I quattro obiettivi hanno preso il posto dei tre gradini, se la Chronicle
	# li dichiara (D-198). La lista la fa `objectives_of`, la stessa che scrive
	# il verbale di fine anno: due letture diverse dello stesso seggio erano il
	# difetto piu' facile da introdurre qui.
	var taken: Array = session.destinies.objectives_of(viewer_id)
	if not taken.is_empty():
		for entry in taken:
			var record: Dictionary = entry as Dictionary
			_rung_line(
				"%s%s" % [
					"" if bool(record["public"]) else "(coperto) ", str(record["label"])
				],
				bool(record["met"])
			)
		return
	for level in ["minimum", "victory", "triumph"]:
		_rung_line(
			rung_text(destiny, str(level)),
			session.destinies.conditions.all_hold(destiny[level]["conditions"], {"self": viewer_id})
		)


## La riga di un gradino, come si legge **al tavolo** (PZ-8, D-271): se il
## Destino ha una faccia fisica, la riga e' la sua — `physical.reads` e' la
## frase stampata sulla carta, e lo schermo dice quello che la carta dice
## (da D-270 ogni Destino spedito ce l'ha). Senza faccia, l'etichetta
## digitale del gradino: il ripiego resta per i Destini fabbricati nelle
## prove.
static func rung_text(destiny: Dictionary, level: String) -> String:
	var face: Dictionary = destiny.get("physical", {}) as Dictionary
	var said: String = str((face.get("reads", {}) as Dictionary).get(level, ""))
	if said != "":
		return said
	return str((destiny.get(level, {}) as Dictionary).get("label", ""))


## Una riga della scala. ASCII on purpose: the fallback font a Web export ships
## has no check mark, and a missing glyph renders as a tofu box - which reads as
## a bug in the game rather than a gap in the font.
func _rung_line(text: String, holds: bool) -> void:
	var line := Label.new()
	line.text = "%s %s" % ["[x]" if holds else "[ ]", text]
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.add_theme_font_size_override("font_size", 12)
	line.add_theme_color_override(
		"font_color", Color("#6fa88a") if holds else Color("#5f584c")
	)
	_destiny.add_child(line)


## Una carta con la sua etichetta sopra e il suo nome sotto.
##
## L'etichetta dice **a cosa serve** — sono due domande diverse, e leggerle
## affiancate e' il modo piu' rapido di capire il gioco: chi sei, e cosa vuoi.
func _titled(picture: TextureRect, label: String) -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var top := Label.new()
	top.text = label
	top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_theme_font_size_override("font_size", 10)
	top.add_theme_color_override("font_color", Color("#8a8172"))
	column.add_child(top)
	column.add_child(picture)
	var under := Label.new()
	under.name = "caption"
	under.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	under.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	under.add_theme_font_size_override("font_size", 11)
	under.add_theme_color_override("font_color", Color("#c9bfae"))
	column.add_child(under)
	return column


## Il nome sotto una delle due carte.
func _caption(picture: TextureRect, text: String) -> void:
	var column: Node = picture.get_parent()
	if column == null:
		return
	var under: Node = column.get_node_or_null("caption")
	if under != null:
		(under as Label).text = text


func _tarot() -> TextureRect:
	var picture := TextureRect.new()
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Un tarocco grande abbastanza da riconoscersi, non da occupare mezza
	# colonna: a 1.85 erano 130x222 l'uno, e da soli spingevano la mano fuori
	# dallo schermo (D-251).
	picture.custom_minimum_size = Vector2(70.0, 120.0) * 1.15
	picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return picture


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out


## Mette un pezzo di pannello dentro un posto dove una carta puo' cadere, e lo
## registra. Senza `field` non incarta niente: le sezioni che non sono bersaglio
## di nessuna carta restano quello che erano.
func _wrapped(inner: Control, field: String, key: String) -> Control:
	if field == "" or key == "":
		return inner
	var slot: PanelContainer = DropSlot.new()
	slot.field = field
	slot.key = key
	# Il posto dove **posare** quello che si tiene in mano vale per ogni riga —
	# una domanda o una casa — e viene prima della scheda: se stai posando una
	# carta, non stai leggendo.
	slot.gui_input.connect(func(event: InputEvent) -> void:
		if not (event is InputEventMouseButton):
			return
		var press := event as InputEventMouseButton
		if not press.pressed or press.button_index != MOUSE_BUTTON_LEFT:
			return
		var where: String = "%s:%s" % [field, key]
		if held_places.has(where):
			card_placed.emit(int(held_places[where]))
	)
	if field == "tension":
		# Un clic sulla riga apre la scheda. Il trascinamento resta quello che
		# era: chi prende una carta e la lascia cadere qui fa una mossa, chi
		# clicca e basta sta leggendo. Sono due gesti diversi e non si pestano
		# i piedi, perche' il trascinamento non passa mai da `gui_input`.
		slot.gui_input.connect(func(event: InputEvent) -> void:
			if held_places.has("%s:%s" % [field, key]):
				return
			if event is InputEventMouseButton \
					and (event as InputEventMouseButton).pressed \
					and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
				tension_opened.emit(key)
		)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.add_child(inner)
	slot.card_dropped.connect(func(indices: Array) -> void: card_dropped.emit(indices))
	slots["%s:%s" % [field, key]] = slot
	return slot
