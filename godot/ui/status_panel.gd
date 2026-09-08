extends VBoxContainer
## **La plancia della propria casa**: i Diritti, i segni, e cosa si vuole
## lasciare. Stesso contratto della mappa: `render(session, viewer_id)`.
##
## **E niente di quello che sta gia' da un'altra parte** (D-473, parola del
## committente: *«nella scheda La mia casa ci sono anche informazioni ripetute
## (come le tensioni), anche i rapporti sono visualizzati doppi»*). Aveva
## ragione, e i doppioni erano tre:
##
## - le **sei piste dei Temi**, che stanno gia' nella colonna a sinistra;
## - le **domande dell'anno** con le barre e il mucchio piu' alto, che stanno
##   nella stessa colonna, dove sono anche il posto in cui una carta cade;
## - i **rapporti con le altre case**, che stanno nella riga dei seggi sotto la
##   mappa (`seats_strip.gd`) — e li' sono anche il posto dove cade FORGIARE.
##
## Erano centocinquanta righe di codice e tre occasioni di dire due cose
## diverse sullo stesso fatto. Qui resta quello che al tavolo sta davvero
## davanti a chi gioca, e da nessun'altra parte.

const CardArt := preload("res://ui/card_art.gd")
const CardFace := preload("res://scripts/core/card_face.gd")
const FaceCard := preload("res://ui/face_card.gd")
const SeatsStrip := preload("res://ui/seats_strip.gd")
const DropSlot := preload("res://ui/drop_slot.gd")
const SignLabels := preload("res://scripts/core/sign_labels.gd")

var _destiny: VBoxContainer
var _casata_card: TextureRect
var _destiny_card: TextureRect

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


## **La scheda degli obiettivi** (D-464, rifatta da D-473): le carte che dicono
## a che gioco stai giocando — Casata, Destino, e i tre Obiettivi pescati.
var only_goals: bool = false


func render(session: RefCounted, viewer_id: String) -> void:
	if _title == null:
		_build()
	if only_goals:
		_title.visible = false
		_update_destiny(session, viewer_id)
		_update_profile(session, viewer_id)
		return
	_title.visible = true
	_update_claims(session, viewer_id)
	_update_signs(session, viewer_id)
	_update_destiny(session, viewer_id)
	_update_profile(session, viewer_id)


## **Ogni blocco dice cosa e', in una riga** (D-282, parola del committente:
## *«sulla colonna di destra non si capisce nulla»*). Al tavolo non serve —
## una plancia ha le sue caselle stampate accanto; sullo schermo la riga sotto
## l'intestazione **e' quella stampa**.
func _build() -> void:
	_title = Label.new()
	_title.text = "LA TUA PLANCIA"
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", Color("#8a8172"))
	add_child(_title)
	add_child(_note(
		"Quello che tieni tu: i Diritti pronti a forzare un Consiglio, i segni"
		+ " che porti addosso, e cosa vuoi lasciare nel mondo."
	))


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
	line.add_theme_font_size_override("font_size", 11)
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
		# Nessun suggerimento sull'intestazione: la nota qui sotto dice la
		# stessa cosa, e la dice a chiunque (D-384).
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
			_profile.add_child(row)
			# **La ragione si legge, non si sorvola** (D-242, D-384). Stava nel
			# suggerimento del mouse: nove frasi d'autore che su un tablet non
			# esistono. Adesso stanno sotto la riga che spiegano.
			var perche: String = str((voice as Dictionary).get("why", ""))
			if perche != "":
				var motivo := Label.new()
				motivo.text = perche
				motivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				motivo.add_theme_font_size_override("font_size", 11)
				motivo.add_theme_color_override("font_color", Color("#8a8172"))
				_profile.add_child(motivo)

	_add_threshold(session, viewer_id, mine as Dictionary)


## **E cosa succede se non li tieni** (D-290): la soglia, stampata sotto i segni
## che conta. Al tavolo e' la riga in fondo alla carta della Casata — «dopo un
## secolo, se il mondo non porta almeno due di questi, la casa diventa
## un'altra cosa» — e accanto c'e' l'unico numero che serve per saperlo:
## **da quanti anni questa pelle e' seduta**.
func _add_threshold(session: RefCounted, viewer_id: String, profile: Dictionary) -> void:
	var entity: Variant = session.data.entities.get(viewer_id)
	if entity == null:
		return
	var seat: Dictionary = (session.world.get("entities", {}) as Dictionary).get(
		viewer_id, {}
	) as Dictionary
	var lives: Array = (entity as Dictionary).get("incarnations", []) as Array
	var now: int = int(seat.get("incarnation", 0))
	for index in range(now + 1, lives.size()):
		var life: Dictionary = lives[index] as Dictionary
		var door: Dictionary = life.get("also_enters", {}) as Dictionary
		if door.is_empty():
			continue
		var held: int = 0
		for voice in profile.get("wants", []) as Array:
			if _world_carries(session, str((voice as Dictionary).get("tag", ""))):
				held += 1
		var line := Label.new()
		line.text = "dopo %d anni con meno di %d di questi segni: diventi %s" % [
			int(door.get("after_years", 0)), int(door.get("holds_at_least", 1)),
			str(life.get("name", "")),
		]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 11)
		line.add_theme_color_override("font_color", Color("#b06b8f"))
		_profile.add_child(line)
		var che_vita: String = str(life.get("description", ""))
		if che_vita != "":
			var racconto := Label.new()
			racconto.text = che_vita
			racconto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			racconto.add_theme_font_size_override("font_size", 11)
			racconto.add_theme_color_override("font_color", Color("#8a8172"))
			_profile.add_child(racconto)
		var clock := Label.new()
		clock.text = "questa casa e' cosi' da %d anni · adesso ne tieni %d" % [
			int(seat.get("life_years", 0)), held,
		]
		clock.add_theme_font_size_override("font_size", 11)
		clock.add_theme_color_override(
			"font_color",
			Color("#c8553d") if held < int(door.get("holds_at_least", 1)) else Color("#8a8172")
		)
		_profile.add_child(clock)
		return


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
		# La riga sotto lo dice gia', e la dice anche col dito (D-384).
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
		_draw_objectives(session, taken)
		return
	for level in ["minimum", "victory", "triumph"]:
		_rung_line(
			rung_text(destiny, str(level)),
			session.destinies.conditions.all_hold(destiny[level]["conditions"], {"self": viewer_id})
		)


## **Le carte Obiettivo, come carte** (D-473, parola del committente: *«nella
## scheda Obiettivi dovrebbero esserci le tre carte obiettivo pescate che ti
## danno punti alla fine della chronicle»*).
##
## Ci sono sempre state — si pescano per saga (D-237), stanno in
## `entities[id].objectives`, e il mazzo delle diciannove si stampa gia' dai
## fogli — ma sullo schermo erano tre righe di testo sotto il Destino: la
## stessa cosa che al tavolo tieni in mano coperta, ridotta a un elenco.
##
## La prima voce che `objectives_of` torna e' il **Destino**, che ha gia' il
## suo tarocco qui sopra: qui si disegnano le altre, e sotto ognuna si dice se
## a oggi e' raggiunta.
func _draw_objectives(session: RefCounted, taken: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_destiny.add_child(row)
	for entry in taken:
		var record: Dictionary = entry as Dictionary
		if bool(record["public"]):
			# Il Destino: la sua carta sta gia' qui sopra, grande.
			continue
		var face: Dictionary = CardFace.of("objective", str(record["id"]), session.data)
		if face.is_empty():
			continue
		var card := FaceCard.new()
		card.set_size_name("piccola")
		row.add_child(card)
		card.render(face, session.data)
	# E sotto le carte, in una riga sola, quali sono gia' raggiunte: al tavolo
	# e' la carta girata dalla parte giusta, qui e' la spunta di sempre.
	for entry in taken:
		var record: Dictionary = entry as Dictionary
		_rung_line(str(record["label"]), bool(record["met"]))


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
	top.add_theme_font_size_override("font_size", 11)
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
	# **Alto come un dito** (D-243, misurato dalla sonda della pagina in D-379).
	# I sette posti dove una carta puo' cadere chiedevano 19 e 29 pixel: col
	# mouse si prendono, col dito no. La riga dentro resta quella che era — e'
	# il bersaglio a crescere, non il testo.
	slot.custom_minimum_size.y = 44
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
