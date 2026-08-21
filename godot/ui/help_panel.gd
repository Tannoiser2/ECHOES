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
	# Who is at the table comes from the Chronicle: there is more than one age in
	# the box now, and they seat nobody in common (D-050).
	var seated: Array = []
	if data != null and data.chronicles.has(chronicle_id):
		for entity_id in data.chronicles[chronicle_id]["entities"]:
			if data.entities.has(str(entity_id)):
				seated.append(str(data.entities[str(entity_id)]["name"]))
	out.append(
		"Sei una delle Entita sedute allo stesso tavolo%s. Una Chronicle e [b]un anno[/b], "
		% ("" if seated.is_empty() else ": %s" % ", ".join(PackedStringArray(seated)))
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

	# **Questa parte si scrive dalle regole, non a mano** (D-194). Era un elenco
	# battuto a macchina, ed e' rimasto a descrivere il gioco di prima per tre
	# versioni: prometteva un ACQUISIRE che non esiste piu' e un TRAMARE che
	# leggeva il numero invece della soglia. Il commento in cima a questo file lo
	# diceva gia' — «una pagina di regole che puo' sfasarsi dalle regole e'
	# peggio di niente» — e la parte battuta a macchina e' esattamente quella che
	# si e' sfasata.
	var rules: Dictionary = {} if chronicle == null else (chronicle as Dictionary)
	var with_cards: bool = bool(rules.get("actions_from_cards", false))
	out.append(SECTION % ("UN'AZIONE E UNA CARTA CALATA" if with_cards else "UN'AZIONE E UNA DI QUESTE SEI COSE"))
	if with_cards:
		out.append(
			"Ogni carta e [b]tre cose insieme[/b]: un'azione, un valore al Consiglio "
			+ "e un effetto suo. Calarla per agire la spende, e quella carta [b]non "
			+ "votera piu[/b]. E li che sta il gioco: la spendo per fare, o la tengo "
			+ "per votare?"
		)
		out.append("")
	out.append("[b]Muovere[/b] — metti una presenza: clicchi una Regione cerchiata d'oro.")
	if not with_cards:
		out.append("[b]Acquisire[/b] — peschi una carta di una famiglia (ne escono due, ne tieni una).")
	out.append("[b]Influenzare[/b] — alzi o abbassi di 1 una domanda dell'anno. Una sola volta per round, e ti serve una presenza in una Regione di quel dominio (o la carta stessa paga).")
	out.append(
		"[b]Tramare[/b] — %s. Lo sai solo tu."
		% (
			"leggi a quanto esplode una domanda velata"
			if str(rules.get("veiled_tensions", "HIDES_ALL")) == "HIDES_THRESHOLD"
			else "leggi il numero di una domanda velata"
		)
	)
	out.append("[b]Forgiare[/b] — muovi di un passo il rapporto con un altro giocatore.")
	var ready_at: int = int((rules.get("claim_rules", {}) as Dictionary).get("ready_at", 3))
	if bool((rules.get("claim_rules", {}) as Dictionary).get("same_round_when_ready", false)):
		out.append(
			"[b]Rivendicare[/b] — se una domanda e gia a [b]%d[/b] o piu, scarti una "
			% ready_at
			+ "carta AUTORITA e [b]apri tu il Consiglio, adesso[/b]. Se non ci e ancora "
			+ "arrivata, te la prenoti e la riscuoti quando matura."
		)
	else:
		out.append("[b]Rivendicare[/b] — scarti una carta AUTHORITY per prenotarti il diritto di aprire tu il prossimo Consiglio su un tema.")
	var refill: Dictionary = rules.get("hand_refill", {}) as Dictionary
	if not refill.is_empty():
		out.append("")
		out.append(
			"[b]Le carte te le da la mappa.[/b] A inizio di ogni Atto peschi %d "
			% int(refill.get("per_token", 1))
			+ "cart%s per ogni gettone di presenza, fino a %d in mano — e [b]la Regione "
			% ["a" if int(refill.get("per_token", 1)) == 1 else "e", int(refill.get("hand_cap", 7))]
			+ "dove tieni la pedina decide di che famiglia[/b]."
		)
	if not (rules.get("tension_tokens", {}) as Dictionary).is_empty():
		out.append(
			"[b]E ogni cosa che fai scalda il mondo:[/b] a ogni azione riuscita cade "
			+ "un gettone su una delle domande dell'anno. Non e il tempo a scaldarle: "
			+ "siete voi."
		)
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
			"Alla fine di ogni Atto ne esce una, e non la pesca nessuno di voi: una per "
			+ "ogni [b]funzione di Propp[/b] — mancanza, presagio, tradimento, scoperta, "
			+ "ritorno. Muovono il mondo da sole, e due di loro convocano un Consiglio "
			+ "sul posto."
		)
		# The count used to be `data.echo_cards.size()`, which was right while there
		# was one saga and became the total across all of them. A year's deck holds
		# the cards that could matter to *its* questions, and nothing else (D-049).
		out.append(
			"Il mazzo di quest'anno ne tiene %d: una carta che parla di una domanda "
			% _deck_size(data, chronicle_id)
			+ "che quest'anno non si sta facendo non viene distribuita."
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


## How many Echo cards this Chronicle's deck actually holds. Mirrors the rule in
## `WorldStateFactory._build_echo_deck`: a card whose eligibility names a Tension
## the Chronicle is not asking about can never be drawn.
func _deck_size(data: RefCounted, chronicle_id: String) -> int:
	var chronicle: Variant = data.chronicles.get(chronicle_id)
	if chronicle == null:
		return data.echo_cards.size()
	var asked: Dictionary = {}
	for tension_id in chronicle.get("tensions", []):
		asked[str(tension_id)] = true
	for tension_id in (chronicle.get("tension_pool", {}) as Dictionary).get("candidates", []):
		asked[str(tension_id)] = true

	var total: int = 0
	for card in data.echo_cards.values():
		var out_of_year: bool = false
		for condition in card["eligibility"]:
			if str((condition as Dictionary).get("type", "")) != "tension_limit":
				continue
			var tension_id: String = str((condition as Dictionary).get("tension_id", ""))
			if tension_id.begins_with("$"):
				continue
			if not asked.has(tension_id):
				out_of_year = true
		if not out_of_year:
			total += 1
	return total
