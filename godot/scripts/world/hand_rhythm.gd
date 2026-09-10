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
