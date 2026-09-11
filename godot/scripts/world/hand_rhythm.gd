extends RefCounted
## **Il ritmo della mano** — la domanda scritta una volta sola.
##
## Forma decisa dal committente in [ISSUES 136](../../../docs/ISSUES.md#136),
## verbalizzata in [D-504](../../../docs/DECISIONS.md#d-504):
##
## > *«Nel primo turno si pescano 5 carte, se ne giocano due e se ne sceglie una
## > per il concilio. Le due rimaste si possono scartare oppure tenere. Nel
## > secondo turno si torna a pescare per arrivare a 5 carte e si ripete.»*
##
## Sono due regole distinte, e vanno accese insieme o non stanno in piedi:
##
## 1. **all'inizio di ogni turno la mano e' esattamente `hand_at_round_start`** —
##    si pesca quello che manca, e si scarta quello che sta sopra, perche'
##    ACQUISIRE puo' portarla oltre dentro il turno;
## 2. **a fine turno si coprono `cover_per_round` carte**, che escono dalla mano
##    e sono le sole che il Consiglio possa impegnare.
##
## La seconda e' quella che cambia il gioco: l'impegno al Consiglio diventa una
## scelta presa **prima** di sapere di cosa si parlera', invece che a mano
## aperta davanti alla domanda.
##
## La domanda sta qui, pura, perche' la fanno in cinque: il controller per far
## scattare la mano e per far coprire, il servizio per dire con che cosa si paga
## un Consiglio, il Consiglio per rifiutare un impegno che non e' coperto, i due
## decisori per scegliere, e la vista del tavolo per dire **quante** coperte ha
## un avversario senza dire quali. Cinque copie divergono in silenzio: e' la
## lezione 9 di casa.
##
## Al tavolo e' un gesto per turno: **pareggi la mano a cinque, e giri una carta
## a faccia in giu' davanti a te.**


## A quante carte torna la mano a inizio turno. Zero — e vale il ritmo di prima,
## `draw_per_act`, che pescava una volta per Atto — dove non e' dichiarato.
static func hand_target(chronicle: Dictionary) -> int:
	return int(
		(chronicle.get("personal_decks", {}) as Dictionary).get("hand_at_round_start", 0)
	)


## Quante carte si coprono a fine turno. Zero, e nessuno copre.
static func cover_per_round(chronicle: Dictionary) -> int:
	return int(
		(chronicle.get("personal_decks", {}) as Dictionary).get("cover_per_round", 0)
	)


## **Con che cosa si paga un Consiglio.** Dove si copre, si paga solo con le
## coperte; dove non si copre, con la mano aperta come sempre.
static func council_pays_from_covered(chronicle: Dictionary) -> bool:
	return cover_per_round(chronicle) > 0


## **Quante carte copre *questa* casa, in questo turno** (D-505).
##
## Parola del committente: *«se hai una pietra o una presenza o qualunque altra
## cosa che ci viene in mente puoi alzare il numero di carte che puoi coprire,
## fino al massimo delle tre che ti rimangono»*.
##
## Quindi `cover_per_round` non e' piu' il numero: e' **il pavimento**. Il resto
## lo guadagna la casa sulla mappa, e questo e' il punto — fino a qui quello che
## si faceva sul tavolo non comprava **peso in Consiglio**, e la direzione di
## casa dice che le Azioni cambiano il mondo e il Consiglio decide cosa il mondo
## ricordera'. Con questa regola le due meta' si toccano: **la mappa compra la
## memoria**.
##
## Il tetto e' doppio, e il secondo e' quello che conta: `cover_bonus.cap` nel
## dato, e **le carte che restano in mano** nel fatto. Coprire tutto quello che
## resta e' legale ed e' un sacrificio vero — quel turno non tieni niente per il
## prossimo — quindi il tetto non e' un numero d'autore, e' una scelta.
static func cover_for(
	chronicle: Dictionary, service: RefCounted, entity_id: String
) -> int:
	var floor_cards: int = cover_per_round(chronicle)
	if floor_cards <= 0:
		return 0
	var bonus: Dictionary = (
		chronicle.get("personal_decks", {}) as Dictionary
	).get("cover_bonus", {}) as Dictionary
	if bonus.is_empty():
		return floor_cards
	var earned: int = 0
	# **Le Pietre che ha costruito**: stanno ferme e si vedono sulla tessera.
	earned += service.stones_held(entity_id) * int(bonus.get("per_stone", 0))
	# **Le Regioni che tiene**, se la Chronicle lo dichiara.
	earned += service.control_count(entity_id) * int(bonus.get("per_control", 0))
	# **Le pedine posate.** Piu' generoso e piu' ballerino: cambiano ogni turno,
	# e al tavolo si ricontano ogni volta.
	earned += service.tokens_placed(entity_id) * int(bonus.get("per_token", 0))
	return mini(floor_cards + earned, int(bonus.get("cap", floor_cards + earned)))


## Le ragioni del numero, in italiano, per chi gioca: *«1 di base · +1 per la
## Pietra che tieni»*. Una regola che dà un numero senza dire da dove viene, al
## tavolo diventa un numero che nessuno controlla.
static func cover_reasons(
	chronicle: Dictionary, service: RefCounted, entity_id: String
) -> Array:
	var floor_cards: int = cover_per_round(chronicle)
	if floor_cards <= 0:
		return []
	var out: Array = ["%d di base" % floor_cards]
	var bonus: Dictionary = (
		chronicle.get("personal_decks", {}) as Dictionary
	).get("cover_bonus", {}) as Dictionary
	for entry in [
		["per_stone", service.stones_held(entity_id), "Pietra che tieni", "Pietre che tieni"],
		["per_control", service.control_count(entity_id), "Regione che tieni", "Regioni che tieni"],
		["per_token", service.tokens_placed(entity_id), "pedina posata", "pedine posate"],
	]:
		var each: int = int(bonus.get(str((entry as Array)[0]), 0))
		var how_many: int = int((entry as Array)[1])
		if each <= 0 or how_many <= 0:
			continue
		out.append("+%d per %d %s" % [
			each * how_many, how_many,
			str((entry as Array)[2]) if how_many == 1 else str((entry as Array)[3]),
		])
	return out
