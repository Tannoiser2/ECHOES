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
##
## E scriverla dai dati non basta, perche' **da quale** dichiarazione la si scrive
## e' a sua volta una cosa che si puo' sbagliare. La sezione dei Consigli pendeva
## da `tension_tokens.table_gate`; D-214 ha tolto quella chiave dai dati spediti e
## la sezione e' caduta nel ramo di due versioni prima, portandosi via anche i
## mucchi coperti che ci stavano annidati dentro. Per tre commit questa pagina ha
## detto a chi la legge sei cose false, con la suite verde e il playtest a 0/8.
##
## Quindi da D-224 vale una regola in piu', e c'e' una prova che la tiene:
## **ogni frase pende dalla dichiarazione che la rende vera, e da nessun'altra**.
## `test_the_page_says_only_what_the_data_says` disegna questa pagina su tutte le
## Chronicle spedite, e poi la ridisegna **togliendo una dichiarazione alla
## volta**: se una frase resta quando la sua regola non c'e' piu', o sparisce
## quando c'e', la suite va rossa. Chi aggiunge un paragrafo qui aggiunge una
## clausola li'.

const SignLabels := preload("res://scripts/core/sign_labels.gd")
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
func render(data: RefCounted, chronicle_id: String = "CHR_00") -> void:
	if _text == null:
		return
	_text.clear()
	_text.append_text("\n".join(PackedStringArray(_lines(data, chronicle_id))))


func _lines(data: RefCounted, chronicle_id: String) -> Array:
	var out: Array = []
	out.append(SECTION % "COME SI GIOCA")
	out.append("")
	# Chi siede al tavolo lo dice la Chronicle, e da D-213 **quasi mai per nome**:
	# `entities` scritto e' il tavolo d'autore, `entity_pool` e' la biblioteca, e
	# quando c'e' la biblioteca vince lei (`WorldStateFactory.resolve_seats`).
	# Questa pagina si apre **prima** che il tavolo sia pescato — la si legge dalla
	# schermata di stanza, con i dati e nessun mondo — quindi non puo' dire chi
	# siede: puo' dire soltanto **che si pesca, e fra quanti**. Elencare le quattro
	# case scritte era raccontare l'era chiusa che D-213 ha smontato.
	var table: Dictionary = {} if data == null or not data.chronicles.has(chronicle_id) \
		else (data.chronicles[chronicle_id].get("entity_pool", {}) as Dictionary)
	var seated: Array = []
	if data != null and data.chronicles.has(chronicle_id) and table.is_empty():
		for entity_id in data.chronicles[chronicle_id]["entities"]:
			if data.entities.has(str(entity_id)):
				seated.append(str(data.entities[str(entity_id)]["name"]))
	if not table.is_empty():
		out.append(
			"Sei una delle [b]%d Entita[/b] sedute allo stesso tavolo, e chi siede non "
			% int(table.get("count", 4))
			+ "e scritto da nessuna parte: [b]si pescano a inizio saga[/b] fra %d case. "
			% (table["candidates"] as Array).size()
			+ "Non ci sono due ere separate — secoli lontani possono trovarsi seduti "
			+ "insieme. Una Chronicle e [b]un anno[/b], e alla fine di quell'anno quello "
			+ "che avete deciso resta scritto."
		)
	else:
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

	# **Questa parte si scrive dalle regole e dalle carte, non a mano** (D-194,
	# D-195). Era un elenco battuto a macchina — «un'azione e una di queste sei
	# cose» — ed e' rimasto a descrivere il gioco di prima per tre versioni. Poi
	# l'ho rattoppato invece di riscriverlo, e il committente ha dovuto dirlo due
	# volte: **le azioni non si scelgono piu', le portano le carte**. Adesso la
	# pagina parte dalla mano, e i mestieri delle famiglie li conta dai dati.
	var rules: Dictionary = {} if chronicle == null else (chronicle as Dictionary)
	var with_cards: bool = bool(rules.get("actions_from_cards", false))
	var refill: Dictionary = rules.get("hand_refill", {}) as Dictionary

	if not with_cards:
		out.append(SECTION % "UN'AZIONE E UNA DI QUESTE SEI COSE")
		out.append("[b]Muovere[/b] — metti una presenza: clicchi una Regione cerchiata d'oro.")
		out.append("[b]Acquisire[/b] — peschi una carta di una famiglia (ne escono due, ne tieni una).")
		out.append("[b]Influenzare[/b] — alzi o abbassi di 1 una domanda dell'anno. Una sola volta per round, e ti serve una presenza in una Regione di quel dominio.")
		out.append(
			"[b]Tramare[/b] — %s. Lo sai solo tu."
			% (
				"leggi a quanto esplode una domanda velata"
				if str(rules.get("veiled_tensions", "HIDES_ALL")) == "HIDES_THRESHOLD"
				else "leggi il numero di una domanda velata"
			)
		)
		out.append("[b]Forgiare[/b] — muovi di un passo il rapporto con un altro giocatore.")
		# La deroga a §10 (D-191) non dipende dalle carte: vale anche di qua.
		var same_round: Dictionary = rules.get("claim_rules", {}) as Dictionary
		if bool(same_round.get("same_round_when_ready", false)):
			out.append(
				"[b]Rivendicare[/b] — se la domanda e gia a [b]%d[/b] o piu la prendi "
				% int(same_round.get("ready_at", 3))
				+ "adesso e [b]il Consiglio lo apri tu[/b]; se non ci e ancora arrivata, "
				+ "te la prenoti per quando maturera."
			)
		else:
			out.append("[b]Rivendicare[/b] — scarti una carta AUTHORITY per prenotarti il diritto di aprire tu il prossimo Consiglio su un tema.")
	else:
		out.append(SECTION % "NON SI SCEGLIE UN'AZIONE: SI CALA UNA CARTA")
		out.append(
			"Non c'e una lista di cose che puoi fare. C'e [b]la tua mano[/b], e ogni "
			+ "carta porta scritta l'unica cosa che sa fare."
		)
		out.append("")
		out.append(
			"Ogni carta e [b]tre cose insieme[/b]: [b]un'azione[/b], [b]un valore al "
			+ "Consiglio[/b] (la sua famiglia e la sua forza) e [b]un effetto suo[/b], "
			+ "che scatta quando la impegni al voto."
		)
		out.append(
			"Calarla per agire [b]la spende[/b], e quella carta non votera piu. Ogni "
			+ "turno e la stessa domanda: [i]la spendo per fare, o la tengo per "
			+ "votare?[/i]"
		)
		out.append("")
		if refill.is_empty():
			out.append("Le carte si pescano con ACQUISIRE, come prima.")
		else:
			# Il rubinetto per intero, **tutti e cinque i numeri**. Ne stampava due
			# — quante per pedina e il tetto — e taceva pavimento, soffitto e la
			# carta del possesso: chi leggeva sapeva la regola sbagliata a meta',
			# che e' il modo piu' lungo di dire che non la sapeva.
			var per_token: int = int(refill.get("per_token", 1))
			var per_control: int = int(refill.get("per_control", 0))
			out.append(
				"[b]Le carte te le dà la mappa.[/b] A inizio di ogni Atto peschi %d "
				% per_token
				+ "cart%s per ogni gettone di presenza"
				% ("a" if per_token == 1 else "e")
				+ (
					", e %d [b]per ogni Regione che controlli[/b]" % per_control
					if per_control > 0 else ""
				)
				+ (
					" — mai meno di %d, mai più di %d" % [
						int(refill["floor"]), int(refill["cap"])
					] if refill.has("floor") and refill.has("cap") else ""
				)
				+ ", fino a %d in mano%s. E [b]la Regione dove tieni la pedina decide "
				% [
					int(refill.get("hand_cap", 7)),
					(" (e ogni Regione che controlli alza anche quel tetto di %d)" % per_control)
						if per_control > 0 else "",
				]
				+ "di che famiglia[/b]: quindi la mappa non dice solo [i]quante[/i] "
				+ "carte hai, dice [i]che cose sai fare[/i]."
			)
			if per_control > 0:
				out.append("")
				out.append(
					"[color=#8a8172]Ed e per questo che [b]tenere[/b] una Regione non e "
					+ "lo stesso che starci dentro: la presenza dice dove sei, il "
					+ "possesso paga una carta in piu e un posto in piu dove tenerla. "
					+ "Prendere la maggioranza a qualcuno gliela toglie.[/color]"
				)
		out.append("")
		out.append(SECTION % "COSA SANNO FARE LE FAMIGLIE")
		for line in _families_can_do(data):
			out.append(line)
		var claim: Dictionary = rules.get("claim_rules", {}) as Dictionary
		if bool(claim.get("same_round_when_ready", false)):
			out.append("")
			out.append(
				"Una carta che [b]rivendica[/b]: se la domanda e gia a [b]%d[/b] o piu "
				% int(claim.get("ready_at", 3))
				+ "la prendi adesso e [b]il Consiglio lo apri tu[/b]; se non ci e ancora "
				+ "arrivata, te la prenoti per quando maturera."
			)
		if str(rules.get("veiled_tensions", "HIDES_ALL")) == "HIDES_THRESHOLD":
			out.append(
				"Una carta che [b]trama[/b] gira la carta coperta di una domanda: "
				+ "scopri [b]a quanto esplode[/b], e lo sai solo tu."
			)
		var tokens: Dictionary = rules.get("tension_tokens", {}) as Dictionary
		if not tokens.is_empty():
			out.append("")
			# **Chi** scalda le domande e' una dichiarazione a se': `replaces_drift`
			# spegne la Deriva a orologio (D-192). Questa riga la dava per accesa
			# comunque, e tre paragrafi piu' giu' la pagina diceva l'opposto — la
			# stessa pagina, due regole diverse, e nessuno che le leggesse insieme.
			out.append(
				"[b]E ogni cosa che fai scalda il mondo:[/b] a ogni azione riuscita cade "
				+ "un gettone su una delle domande dell'anno. "
				+ (
					"Non è il tempo a scaldarle: siete voi."
					if bool(tokens.get("replaces_drift", false))
					else "E intanto il tempo le scalda per conto suo, round dopo round."
				)
			)
	out.append("")

	if data != null and chronicle != null:
		# **La biblioteca vince sul tavolo d'autore**, qui come in
		# `WorldStateFactory.resolve_tensions`: una Chronicle che dichiara tutte e
		# due gioca il pool, e la sua lista scritta e' un residuo. Questa pagina
		# aveva la precedenza al contrario — leggeva `tensions` per prima — e
		# quindi su CHR_01 e CHR_03 annunciava quattro domande fisse in un anno
		# che ne pesca quattro su dodici. Una pagina che legge i dati in un ordine
		# e il motore nell'altro non e' meno battuta a macchina delle altre.
		var pool: Dictionary = chronicle.get("tension_pool", {}) as Dictionary
		var drawn: bool = not pool.is_empty()
		var questions: Array = pool.get("candidates", []) if drawn \
			else chronicle.get("tensions", [])
		out.append(SECTION % ("LE DOMANDE POSSIBILI" if drawn else "LE DOMANDE DI QUEST'ANNO"))

		# **Quando si apre un Consiglio.** Fino a D-214 lo diceva un cancello sul
		# tavolo, `tension_tokens.table_gate`; D-214 l'ha tolto dai dati e questa
		# sezione — appesa a quella chiave — e' caduta di colpo nel ramo di due
		# versioni prima. Adesso e' appesa alla dichiarazione che decide davvero
		# (`confluence_rules.at_end_of_act`), ed e' misurata nei due sensi.
		#
		# E sono **tre**, non due: il Consiglio di chiusura (D-214), il cancello
		# sul tavolo (D-203, ancora vivo nel motore e giocato da un piano) e la
		# soglia per domanda di sempre. La pagina le sapeva dire tutte e tre e ne
		# ha perse due in un colpo perche' pendevano dalla chiave sbagliata.
		# L'ordine e' quello del motore: `_end_of_round_confluence` guarda prima
		# il fine Atto, poi il cancello.
		var at_end: bool = bool(
			(rules.get("confluence_rules", {}) as Dictionary).get("at_end_of_act", false)
		)
		var gate: int = int((rules.get("tension_tokens", {}) as Dictionary).get("table_gate", 0))
		if at_end:
			out.append(
				"[b]NON C'È UN NUMERO DA RAGGIUNGERE: IL CONSIGLIO SI TIENE ALLA FINE DI "
				+ "OGNI ATTO.[/b] Ogni carta che qualcuno cala fa cadere un gettone su una "
				+ "domanda, e i mucchi crescono. Quando l'Atto si chiude il tavolo si "
				+ "siede comunque, e la domanda che si dibatte è il [b]mucchio più "
				+ "alto[/b] — non quella che ha superato un numero suo. Poi i mucchi "
				+ "ripartono da zero."
			)
			out.append("")
			out.append(
				"Quindi le domande non hanno una soglia da aspettare: hanno un'altezza, e "
				+ "quella che conta è chi sta più in alto quando l'Atto finisce. Scaldarne "
				+ "una non serve a farla [i]esplodere[/i]: serve a portarla [b]davanti al "
				+ "tavolo[/b] invece di un'altra."
			)
			out.append("")
			out.append(
				"%d Atti vuol dire [b]almeno %d Consigli[/b] in un anno: nessuna partita "
				% [int(chronicle["acts"]), int(chronicle["acts"])]
				+ "si chiude senza che il tavolo abbia deciso qualcosa, e i gettoni non "
				+ "dicono più [i]se[/i] si parla — dicono soltanto [i]di cosa[/i]."
			)
		elif gate > 0:
			out.append(
				("[b]NON C'È UNA SOGLIA PER DOMANDA: CE N'È UNA PER IL TAVOLO.[/b] "
				+ "Ogni carta che qualcuno cala fa cadere un gettone su una domanda, "
				+ "e i mucchi crescono. Quando sul tavolo sono scesi [b]%d gettoni[/b] "
				+ "si apre un Consiglio, e la domanda che si dibatte è il "
				+ "[b]mucchio più alto[/b] — non quella che ha superato un numero suo. "
				+ "Poi il conto riparte da zero.") % gate
			)
			out.append("")
			out.append(
				"Quindi le domande non hanno un numero da raggiungere: hanno un'altezza, "
				+ "e quella che conta è chi sta più in alto quando il Consiglio si apre. "
				+ "Scaldarne una vuol dire portarla davanti al tavolo."
			)
		else:
			out.append(
				"Salgono da sole ogni round. [b]Quando una arriva alla sua soglia si apre "
				+ "un Consiglio[/b], ed e li che il gioco decide qualcosa."
			)

		# I mucchi coperti (ISSUES 49 fase 3): se la Chronicle dichiara il
		# sacchetto dei valori, la pagina lo deve dire — una persona che conta i
		# gettoni e crede di sapere l'altezza sta giocando un altro gioco.
		#
		# Stava annidato dentro il cancello del tavolo, quindi il giorno che il
		# cancello e' sparito dai dati e' sparito anche questo: la regola era
		# ancora accesa e la pagina non la nominava piu'. Adesso pende dalla
		# propria dichiarazione, che e' l'unica cosa da cui debba pendere.
		var covered: Array = (rules.get("tension_tokens", {}) as Dictionary).get("covered", [])
		if not covered.is_empty():
			# JSON legge `[0, 1, 1, 2]` come numeri in virgola mobile, e stampati
			# cosi' diventano «vale 0.0 / 1.0 / 1.0 / 2.0» — un valore di gettone
			# con la virgola non vuol dire niente a chi legge. Si e' visto solo
			# guardando la pagina disegnata, che e' il punto di §5ter.
			var faces: Array = []
			for face in covered:
				faces.append(str(int(face)))
			out.append("")
			# La coda della frase dipende da **come si apre il Consiglio**, non
			# dal sacchetto: col Consiglio a fine Atto il coperto nasconde chi
			# sale sul tavolo, a soglia nasconde quanto manca. Tenerne una sola
			# vorrebbe dire dirne una falsa in meta' dei casi.
			out.append(
				("[b]E I MUCCHI SONO COPERTI.[/b] Un gettone non vale sempre "
				+ "uno: vale %s, e lo sa solo il sacchetto. Sul tavolo vedi "
				+ "[b]quanti gettoni[/b] sono caduti su ogni domanda, non "
				+ "quanto pesano. Si girano quando il Consiglio si apre")
				% " / ".join(PackedStringArray(faces))
				+ (
					" — e il mucchio più alto non è per forza quello più grosso."
					if at_end or gate > 0
					else " — e una domanda che sembra lontana può essere già arrivata."
				)
			)
		# E la presa di parola vale **comunque**: RIVENDICARE esiste in tutti e tre
		# i modi di aprire un Consiglio, cambia solo quanto si aspetta. Questa nota
		# stava annidata dentro il cancello del tavolo e prometteva la presa
		# immediata anche a chi non l'aveva dichiarata — un giocatore che ci
		# contava scopriva al tavolo di essersi soltanto prenotato.
		out.append("")
		if bool((rules.get("claim_rules", {}) as Dictionary).get("same_round_when_ready", false)):
			out.append(
				"[color=#8a8172]E un Consiglio in più lo puoi aprire tu: chi ha una "
				+ "rivendicazione matura la spende e chiama la domanda che vuole, senza "
				+ "aspettare%s. È il modo di portare al tavolo una [b]seconda[/b] "
				% (" la fine dell'Atto" if at_end else " i gettoni")
				+ "domanda.[/color]"
			)
		else:
			out.append(
				"[color=#8a8172]E un Consiglio lo puoi chiamare anche tu: chi rivendica "
				+ "una domanda se la prenota, e quando maturerà il tavolo si siede su "
				+ "quella e non su un'altra.[/color]"
			)

		if drawn:
			out.append("")
			out.append(
				"Questa Chronicle ne pesca %d fra queste %d: due partite non fanno la "
				% [int(pool.get("count", 4)), questions.size()]
				+ "stessa storia, e le domande di quest'anno le sapete solo dopo che sono "
				+ "uscite."
			)
		for tension_id in questions:
			var tension: Variant = data.tensions.get(str(tension_id))
			if tension == null:
				continue
			# Col Consiglio a fine Atto la soglia scritta non apre piu' niente:
			# stamparla qui vorrebbe dire far aspettare un numero che non
			# succede — lo stesso errore delle sei azioni promesse (D-195).
			if at_end or gate > 0:
				out.append(
					"  · [b]%s[/b] — ascolta %s"
					% [
						str(tension["title"]),
						", ".join(PackedStringArray(tension["relevant_asset_families"])).to_lower(),
					]
				)
			else:
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
		out.append(SECTION % "L'ECO DELLE CARTE")
		out.append(
			"Ogni carta Asset porta stampato un terzo blocco: il suo [b]Eco[/b], la "
			+ "versione potenziata della carta. Non c'e' un mazzo a parte da cui "
			+ "pescarlo — ce l'hai gia' in mano, sotto le due Azioni normali."
		)
		out.append(
			"Calarlo costa [b]la carta[/b], come giocarla per una delle sue Azioni. "
			+ "Quello che cambia sono le condizioni: si puo' fare solo se il mondo porta "
			+ "i segni che quell'Eco nomina, ed e' scritto sulla faccia."
		)
		out.append(
			"L'Atto decide che tipo di Eco puo' parlare: il primo solo [b]pressione[/b], "
			+ "l'ultimo soprattutto [b]risoluzione[/b]. La forma di una storia sta nelle "
			+ "carte, non nella testa di chi la racconta."
		)
		out.append("")

	out.append(SECTION % "COME SI VINCE")
	var goals: Dictionary = rules.get("objectives", {}) as Dictionary
	if not goals.is_empty():
		var hidden: int = int(goals.get("hidden", 3))
		out.append(
			("[b]NON SI SALE UNA SCALA: SI CONTANO GLI OBIETTIVI.[/b] All'inizio "
			+ "dell'anno te ne tocca uno [b]palese[/b] — quello per cui la tua casa e "
			+ "venuta al tavolo, e lo sanno tutti — e ne peschi %d [b]coperti[/b], che "
			+ "non vede nessun altro. In basso a destra ci sono tutti e %d, coi coperti "
			+ "segnati come tali: sono i tuoi, quindi tu li vedi.") % [hidden, hidden + 1]
		)
		out.append("")
		out.append(
			("Alla fine dell'anno si contano quelli che si sono avverati. [b]Tutti e "
			+ "%d e un trionfo. Nessuno e un anno perso.[/b] In mezzo ci sono i "
			+ "successi parziali, e ognuno vale un numero diverso alla fine della "
			+ "saga.") % (hidden + 1)
		)
		out.append("")
		out.append(
			"Le caselle spuntate valgono [b]adesso[/b]: se una si spegne, l'hai persa. "
			+ "Si guarda solo alla fine dell'anno."
		)
		if data != null and not data.objectives.is_empty():
			out.append("")
			out.append(
				("[color=#8a8172]I coperti si pescano da %d obiettivi condivisi: "
				+ "chiedono cose che valgono in qualunque mondo — Regioni che "
				+ "rispondono, pietre in piedi, cicatrici che non ci sono, carte "
				+ "ancora in mano. Nessuno di loro nomina una casa o un posto, "
				+ "perche' li puo pescare chiunque.[/color]") % data.objectives.size()
			)
		out.append("")
		out.append(
			"[color=#8a8172]Quindi: dei quattro, uno lo sanno tutti e tre no. Chi "
			+ "ti guarda inseguire il palese non sa cos'altro stai contando — ed e "
			+ "quello, il gioco.[/color]"
		)
	else:
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
		# Con `[...]` una chiave mancante non e' un valore assente: e' un errore
		# che interrompe il disegno a meta' pagina e finisce in un log che nessuno
		# legge — la pagina si accorcia e basta. La prova l'ha trovato togliendo
		# la dichiarazione, che e' il motivo per cui la prova la toglie.
		var tokens: int = 3 if chronicle == null else int(chronicle.get("presence_tokens", 3))
		out.append(
			"%d Regioni: %s. Hai %d token presenza. Dove stai decide che carte puoi "
			% [places.size(), ", ".join(PackedStringArray(places)), tokens]
			+ "pescare e che domande puoi spingere."
		)
		# **E quel numero e' un tetto, non una dotazione** (D-223). Fino ad allora
		# valeva per i giocatori e non per il mondo: un Consiglio poteva posare la
		# quinta pedina di una casa che ne ha quattro. Adesso il tetto vale per
		# tutti, e allora e' una regola che chi gioca deve sapere — perche' e'
		# quella che rende **muoversi** una scelta invece di un accumulo.
		if (chronicle as Dictionary).has("presence_tokens"):
			out.append("")
			out.append(
				"E [b]%d è il tetto[/b], non una dotazione: la %da pedina non si posa, la "
				% [tokens, tokens + 1]
				+ "si sposta. Vale anche per quello che decide un Consiglio. Per essere "
				+ "in un posto nuovo devi [b]lasciarne uno vecchio[/b], e lasciarlo vuol "
				+ "dire perdere quello che ci tenevi."
			)
	return out


func _sorted(keys: Array) -> Array:
	var out: Array = keys.duplicate()
	out.sort()
	return out


## I mestieri delle famiglie, **contati dalle carte** e non elencati a mano.
##
## E' il punto di D-195: se domani una carta cambia mestiere, questa riga cambia
## con lei. La mappa decide che famiglia peschi, quindi questa tabella e' la
## risposta vera alla domanda «cosa posso fare, stando qui?».
func _families_can_do(data: RefCounted) -> Array:
	if data == null:
		return []
	const VERBS: Dictionary = {
		"MOVE": "muovere", "INFLUENCE": "influenzare", "SCHEME": "tramare",
		"FORGE": "forgiare", "CLAIM": "rivendicare", "ACQUIRE": "acquisire",
	}
	const FAMILIES: Array = ["FORCE", "AUTHORITY", "PEOPLE", "KNOWLEDGE", "WEALTH", "BONDS"]
	# I nomi li dice `SignLabels` (D-339): erano una tabella qui dentro, e una
	# tabella di parole chiusa in una vista la vede solo quella vista — la carta
	# stampata scriveva «wealth, people, authority».
	var counted: Dictionary = {}
	for asset_id in data.assets:
		var card: Dictionary = data.assets[str(asset_id)] as Dictionary
		var action: Dictionary = card.get("card_action", {}) as Dictionary
		if action.is_empty():
			continue
		var family: String = str(card["family"])
		var kind: String = str(action["kind"])
		var per: Dictionary = counted.get(family, {}) as Dictionary
		per[kind] = int(per.get(kind, 0)) + 1
		counted[family] = per
	var out: Array = []
	for family in FAMILIES:
		var per: Dictionary = counted.get(family, {}) as Dictionary
		if per.is_empty():
			continue
		var kinds: Array = per.keys()
		kinds.sort_custom(func(a: String, b: String) -> bool:
			if int(per[a]) == int(per[b]):
				return str(a) < str(b)
			return int(per[a]) > int(per[b])
		)
		var parts: Array = []
		for kind in kinds:
			parts.append("%d %s" % [int(per[str(kind)]), str(VERBS.get(str(kind), kind))])
		out.append("[b]%s[/b] — %s" % [
			SignLabels.family(str(family)).to_upper(), ", ".join(PackedStringArray(parts))
		])
	return out
