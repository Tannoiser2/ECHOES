extends PanelContainer
## How the game is played, on the screen where it is played.
##
## The rules live in `docs/RULES_V0_2.md`, which is exactly where a player will
## never look. Until 0.1.4 a person opened the page, chose a seat, and was handed
## fourteen buttons with no way to find out what any of them were for.
##
## Half of this page is written from the data rather than typed out: the Regions,
## the year's questions with their thresholds and the families each one listens
## to, the shape of the year. A rules page that can fall out of step with the
## rules is worse than none, and the parts that can drift are the parts that
## come from `DataSet` (D-041).

const SECTION: String = "[color=#e8b563][b]%s[/b][/color]"

var _text: RichTextLabel


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#16130f")
	style.border_color = Color("#3a332a")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	add_theme_stylebox_override("panel", style)

	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.selection_enabled = true
	_text.add_theme_font_size_override("normal_font_size", 13)
	_text.add_theme_color_override("default_color", Color("#c9bfae"))
	add_child(_text)


## `data` may be null - the page opens before any Chronicle is loaded - and then
## the parts that come from the world are simply left out.
func render(data: RefCounted, chronicle_id: String = "CHR_01") -> void:
	if _text == null:
		return
	_text.clear()
	_text.append_text("\n".join(PackedStringArray(_lines(data, chronicle_id))))


func _lines(data: RefCounted, chronicle_id: String) -> Array:
	var out: Array = []
	out.append(SECTION % "COME SI GIOCA")
	out.append("")
	out.append(
		"Sei una delle quattro Entita sedute allo stesso tavolo: un re, un popolo, "
		+ "una studiosa e qualcosa di molto antico. Una Chronicle e [b]un anno[/b], "
		+ "e alla fine di quell'anno quello che avete deciso resta scritto."
	)
	out.append("")

	out.append(SECTION % "L'ANNO")
	var chronicle: Variant = null if data == null else data.chronicles.get(chronicle_id)
	if chronicle != null:
		out.append(
			"%d Atti da %d round. In ogni round hai [b]%d azioni[/b]: %d in tutto."
			% [
				int(chronicle["acts"]), int(chronicle["rounds_per_act"]),
				int(chronicle["action_opportunities_per_round"]),
				int(chronicle["acts"]) * int(chronicle["rounds_per_act"])
					* int(chronicle["action_opportunities_per_round"]),
			]
		)
		out.append(
			"Tieni al massimo %d carte in mano e ne impegni al massimo %d per Consiglio."
			% [int(chronicle["hand_limit"]), int(chronicle["max_commit_assets"])]
		)
	out.append("")

	out.append(SECTION % "UN'AZIONE E UNA DI QUESTE SEI COSE")
	out.append("[b]Muovere[/b] — metti una presenza: clicchi una Regione cerchiata d'oro.")
	out.append("[b]Acquisire[/b] — peschi una carta di una famiglia (ne escono due, ne tieni una).")
	out.append("[b]Influenzare[/b] — alzi o abbassi di 1 una domanda dell'anno. Una sola volta per round, e ti serve una presenza in una Regione di quel dominio.")
	out.append("[b]Tramare[/b] — leggi il numero di una domanda velata. Lo sai solo tu.")
	out.append("[b]Forgiare[/b] — muovi di un passo il rapporto con un altro giocatore.")
	out.append("[b]Rivendicare[/b] — scarti una carta AUTHORITY per prenotarti il diritto di aprire tu il prossimo Consiglio su un tema.")
	out.append("")

	if data != null and chronicle != null:
		# A Chronicle either names its questions or draws them from a pool: the
		# library Chronicles do the second, and a rules page that assumed the
		# first would crash on exactly the Chronicle a returning player picks.
		var questions: Array = chronicle.get("tensions", [])
		var drawn: bool = questions.is_empty()
		if drawn:
			questions = (chronicle.get("tension_pool", {}) as Dictionary).get("candidates", [])
		out.append(SECTION % ("LE DOMANDE DI QUEST'ANNO" if not drawn else "LE DOMANDE POSSIBILI"))
		out.append(
			"Salgono da sole ogni round. [b]Quando una arriva alla sua soglia si apre "
			+ "un Consiglio[/b], ed e li che il gioco decide qualcosa."
		)
		if drawn:
			out.append(
				"Questa Chronicle ne pesca %d fra queste: due partite non fanno la stessa storia."
				% int((chronicle.get("tension_pool", {}) as Dictionary).get("count", 4))
			)
		for tension_id in questions:
			var tension: Variant = data.tensions.get(str(tension_id))
			if tension == null:
				continue
			out.append(
				"  · [b]%s[/b] — soglia %d, ascolta %s"
				% [
					str(tension["title"]), int(tension["threshold"]),
					", ".join(PackedStringArray(tension["relevant_asset_families"])).to_lower(),
				]
			)
		out.append("")

	out.append(SECTION % "IL CONSIGLIO")
	out.append("Propone chi ha [b]piu presenza[/b] nella Regione di cui si discute — per questo muoversi conta.")
	out.append("Mette una proposta sul tavolo, e la plancia ti mostra [b]cosa scrivera sul mondo[/b] se passa, Cicatrici comprese.")
	out.append("Gli altri dicono sostengo, mi oppongo, a condizione che, oppure si astengono.")
	out.append("Poi tutti impegnano carte, coperte, rivelate insieme.")
	out.append("")
	out.append(
		"Una carta vale la sua [b]forza piena[/b] solo se la sua famiglia e fra quelle "
		+ "che la domanda ascolta. Altrimenti vale 1: e tutta qui la ragione per cui "
		+ "prepararsi significa qualcosa. La mano in basso te lo dice carta per carta."
	)
	out.append("Alla fine: [b]sostegno − opposizione + 1d6[/b]. Sotto zero la proposta cade; da 5 in su passa senza discussione.")
	out.append("")

	if data != null and data.echo_cards.size() > 0:
		out.append(SECTION % "LE CARTE ECHO")
		out.append(
			"Alla fine di ogni Atto ne esce una, e non la pesca nessuno di voi: sono "
			+ "%d carte, una per ogni [b]funzione di Propp[/b] — mancanza, presagio, "
			% data.echo_cards.size()
			+ "tradimento, scoperta, ritorno. Muovono il mondo da sole, e due di loro "
			+ "convocano un Consiglio sul posto."
		)
		out.append(
			"L'Atto in cui esce decide che tipo puo essere: il primo solo [b]pressione[/b], "
			+ "l'ultimo soprattutto [b]risoluzione[/b]. La forma di una storia sta nel "
			+ "mazzo, non nella testa di chi la racconta."
		)
		out.append("")

	out.append(SECTION % "COME SI VINCE")
	out.append(
		"Ognuno ha un [b]Destino[/b] a tre gradini, in basso a destra, e nessun altro "
		+ "sa qual e il tuo. Le caselle spuntate valgono adesso: se una si spegne, "
		+ "l'hai persa. Si guarda alla fine dell'anno."
	)
	out.append("")
	out.append(
		"[color=#8a8172]Quindi: piazzati dove si decidera la domanda che ti serve, "
		+ "arrivaci con le carte della famiglia giusta, e fai passare — o cadere — la "
		+ "proposta che ti sposta di un gradino.[/color]"
	)

	if data != null:
		out.append("")
		out.append(SECTION % "LA MAPPA")
		var places: Array = []
		for region_id in _sorted(data.regions.keys()):
			places.append(str(data.regions[str(region_id)]["name"]))
		out.append(
			"%d Regioni: %s. Hai %s token presenza. Dove stai decide che carte puoi "
			% [
				places.size(), ", ".join(PackedStringArray(places)),
				"3" if chronicle == null else str(int(chronicle["presence_tokens"])),
			]
			+ "pescare e che domande puoi spingere."
		)
	return out


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out
