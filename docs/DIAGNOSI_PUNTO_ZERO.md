# Diagnosi Punto Zero — cosa serve la visione e cosa no

Risposta al brief *«ECHOES - Punto Zero: grammatica del gioco e direzione di
restyling»*, punto per punto. Scritta il 25 agosto 2026, sul codice a
`0.1.244`.

**Come è stata fatta:** con le sonde, non a impressione. Ogni numero qui sotto
viene da un comando che si può rieseguire, ed è scritto accanto alla riga.
Dove non ho misurato, lo dico.

---

## 1. Dove vive ogni cosa

| Pezzo | Dati | Motore | Schermo |
|---|---|---|---|
| **Asset** (48 facce, 132 carte) | `godot/data/assets/assets_core.json`, `schema/asset.schema.json` | `scripts/actions/action_resolver.gd` (`PLAY_CARD`), `scripts/seat/seat_decider.gd` (`_through_the_hand`), `scripts/core/card_face.gd` | `ui/asset_card.gd`, `ui/hand_view.gd`, `ui/game_screen.gd` (`_card_sheet`) |
| **Tensioni** (60) | `godot/data/tensions/*.json`, `schema/tension.schema.json` | `scripts/chronicle/tension_system.gd`, `scripts/confluence/confluence_controller.gd`, `scripts/confluence/council_economy.gd` | `ui/council_sheet.gd`, `ui/confluence_board.gd` |
| **Domande** | *due sistemi*: `world["tensions"]` (le quattro dell'anno) e i sei mazzetti (`theme_heat`, `theme_tokens`, `theme_front`) | `chronicle_controller.gd` (`_front_of_hottest_theme`, `_hottest_with_something_to_say`) | `ui/theme_decks_view.gd`, `ui/status_panel.gd` |
| **Destini** (9) | `godot/data/destinies/*.json` | `scripts/chronicle/destiny_evaluator.gd` | `ui/status_panel.gd` (le due carte), `ui/echo_card_view.gd` |
| **Mappa** (10 tessere, se ne pescano 6) | `godot/data/regions/*`, `world["map_positions"]` | `scripts/chronicle/game_session.gd` (setup), `scripts/actions/action_resolver.gd` | `ui/map_view.gd` |
| **Confluence** | i template in `godot/data/chronicle_*/`, le facce sulle Tensioni | `scripts/confluence/*` | `ui/confluence_board.gd`, `ui/council_sheet.gd` |
| **Segni** (il dizionario) | `godot/data/tags/*` | `scripts/core/sign_labels.gd`, `effect_text.gd` | ovunque |

---

## 2. Cosa è già allineato alla visione

Queste sei cose il motore le **esegue**, non le racconta:

1. **Il bersaglio a segni** (D-274). MUOVERE e TRAMARE arrivano solo dove i
   segni stampati sulla faccia stanno davvero. La carta non nomina Regioni.
2. **La Risonanza obbligatoria**. Ogni carta calata scalda il suo Tema, e la
   mutazione si firma `kind: "resonance"` così il verbale distingue la scelta
   del giocatore dalla risposta del mondo.
3. **I sei mazzetti** (D-261): gettoni coperti, prima carta girata al secondo
   gettone, il mazzetto più caldo apre il Consiglio di fine Atto.
4. **L'economia del Consiglio** (D-280): 11 verbi chiusi legati ai segni,
   1 beneficio gratis, ogni altro costa un costo, la Cicatrice ne compra uno
   oltre il limite. Il proponente compra, gli avversari scelgono la moneta.
   Misurato: **1,53 benefici comprati per Consiglio**, 61 prezzi in 40 anni,
   29 Cicatrici.
5. **La mappa pescata** (D-265): 10 tessere, se ne pescano 6, vicinanza per
   accostamento, e ogni bersaglio delle 48 carte esiste su ogni tavolo
   pescabile (D-273 lo prova sui 100 semi).
6. **I Destini leggono il mondo** e non gli aggettivi: `region_presence`,
   `control_count`, `state_tag_absent` su segni veri. Nessuna clausola dice
   «ha capito qualcosa».

---

## 3. Cosa è ancora finto, doppio o solo digitale

### 3.1 La seconda Azione stampata non esiste, per il motore

È il difetto più grosso, ed è esattamente il punto 1 dei tuoi «problemi
attuali».

`seat_decider.gd:354` — una carta si può calare **solo col verbo dichiarato in
`card_action.kind`**. Le due Azioni stampate sulla faccia non contano.

Misurato sui dati:

- **48 su 48** le prime Azioni portano un verbo eseguibile;
- **37 su 48** le seconde ne portano uno — *e non viene mai offerto*;
- **11 su 48** le seconde non hanno nemmeno il verbo: solo testo e un
  `puts_tag`;
- `puts_tag` compare **52** volte e `clears_tag` **12**, e il motore non ne
  esegue **nessuna**.

Cosa costa, misurato (`run_card_ledger.gd`, 100 anni):

- **23,2%** delle carte pescate viene calato per agire; **41,4%** finisce al
  voto; **una su 2,8 non fa né l'una né l'altra**;
- per verbo: MUOVERE calato il 43,8% delle volte, FORGIARE il **5,9%**;
- **tre carte non si calano mai** — Credito, Chiavi del Granaio, Ipoteca sulle
  Terre — e sono tutte e tre FORGIARE.

E il conto del passare (`run_pass_probe.gd`, 7.200 turni): **si passa l'84,3%
delle volte**, e la prima ragione (54,7% dei passa) è *«aveva mosse legali,
nessuna che gli servisse»*. La seconda e la terza sono *«voleva INFLUENZARE e
non aveva quella carta»* e *«ce l'aveva e non poteva usarla lì»*: **1.840 volte
su 6.073 la mano non sapeva dire l'intenzione**. Con due verbi per carta invece
di uno, la stessa mano dice il doppio delle cose.

### 3.2 Le Domande sono due sistemi sovrapposti

Il gioco ha oggi **due** economie della stessa cosa:

- le **quattro questioni dell'anno** (`world["tensions"]`, valore 0–6), mosse
  da INFLUENZARE e TRAMARE;
- i **sei mazzetti dei Temi**, scaldati dalla Risonanza di ogni carta calata.

Il Consiglio di fine Atto si apre **sui mazzetti**; le quattro restano come
ripiego dichiarato per l'Atto in cui nessuna Risonanza ha scaldato niente
(`chronicle_controller.gd:695`). È il motivo per cui la colonna di destra
mostrava le stesse informazioni due volte, ed è la cosa che hai visto subito:
*«poi ancora quattro tensioni (?)»*.

Non l'ho tolto da solo: è una regola, e le regole le decidi tu. La proposta sta
al punto 5.

### 3.3 Le Memorie non esistono

Il brief chiede tre classi di segno persistente — condizioni, cicatrici,
**memorie**. Nei dati ci sono **14 condizioni** e **13 cicatrici**. Le memorie
sono **zero**: `grep -ro "memory:" godot/data` non trova niente.

Manca quindi tutta la metà buona della memoria: il gioco sa registrare le
ferite (`scar:`), non i patti, i miracoli, i martiri e i segreti pubblici.

### 3.4 Una carta dice un verbo che non ha stampato

`AST_BONDS_OLD_DEBT` dichiara `CLAIM` al motore e stampa INFLUENZARE e
FORGIARE. È l'unica delle 48, ed è aperta da tre versioni in attesa della tua
scelta: allineare la faccia, o cambiare il verbo dichiarato.

### 3.5 Quello che il brief chiede alla saga, e che oggi non c'è

- **tre segreti pescati** per Entità all'inizio della saga: oggi ogni Entità ha
  un Destino scritto (9 in tutto), non un pescato di segreti;
- **10 Chronicle**: la scatola ne ha 4, di cui 2 sono seguiti;
- **le Entità che cambiano forma** fra una Chronicle e l'altra: c'è la
  successione (`succession.gd`) e l'eredità, non la trasformazione.

Non sono difetti: sono la parte di visione non ancora costruita. La scrivo
perché il brief chiede di distinguerla da quella costruita male.

---

## 4. Fisico ma non ancora eseguibile

Questo è l'elenco stretto — la faccia stampata dice una cosa, il motore non la
sa fare:

| Cosa dice la faccia | Quante volte | Cosa fa il motore |
|---|---|---|
| La seconda Azione di una carta | 48 carte | niente: non la offre mai |
| `puts_tag` su un'Azione | 52 | niente |
| `clears_tag` su un'Azione | 12 | niente |
| «metti #razionato», «togli #chiuso» e simili nel testo delle Azioni | 11 carte senza verbo | niente |

Le facce delle **Tensioni** invece sono eseguibili per intero da D-280:
benefici, costi e i due effetti stampati del fallimento girano tutti.

---

## 5. Il piano, in passi piccoli e misurabili

**Passo 1 — entrambe le Azioni eseguibili** (è quello che il brief chiede per
primo). I verbi giocabili di una carta diventano **quelli stampati sulla sua
faccia**, non il solo `card_action.kind`; `puts_tag` e `clears_tag` diventano
Effetti con inverso; le 11 seconde Azioni senza verbo ne ricevono uno chiuso
(`SEGNA`, che mette o toglie un segno sul bersaglio). L'app le offre entrambe,
come già fa la scheda della carta.
*Fatto quando*: ogni carta ha almeno un'Azione calata in 100 anni, la seconda
Azione viene scelta almeno una volta su cinque, il passare scende sotto il 60%,
e il cancello resta 0 seggi bloccati su 8.

**Passo 2 — le Memorie.** Terza classe di segno accanto a condizioni e
cicatrici, con le sue otto voci nel dizionario, prodotta dai Consigli che
*riescono* (oggi un Consiglio riuscito lascia solo benefici) e letta da Destini
e Chronicle successive.
*Fatto quando*: ogni memoria del dizionario viene scritta almeno una volta in
100 anni **e** letta da almeno un Destino o una Domanda.

**Passo 3 — una sola economia delle domande.** Le quattro questioni dell'anno
spariscono; INFLUENZARE e TRAMARE agiscono sui **mazzetti** (scaldare e
raffreddare un Tema, girare o coprire una carta). Resta una sola pista, quella
fisica.
*Costo da misurare prima*: INFLUENZARE è il verbo più desiderato dai bot
(1.979 intenzioni su 7.200 turni); spostarlo sui mazzetti cambia il gioco, e
va misurato sui 100 semi prima di restare.
**Questo passo è una tua decisione, non mia.**

**Passo 4 — il turno che decide.** Con i passi 1 e 3 il passare dovrebbe
scendere da solo; se non basta, si guarda la pesca (oggi la mano si riempie a
`hand_refill` e la sonda dice che chi passa ha in media 7 carte e 15 mosse
legali: il problema non è quante ne ha, è che dicono tutte la stessa cosa).

**Passo 5 — la saga lunga.** Segreti pescati, Entità che cambiano forma, le
Chronicle dalla 5 alla 10. È lavoro di contenuto, e viene dopo che il turno
funziona.

---

## 6. La frase guida, applicata

> *«Non ottimizzare il sistema esistente: verifica se il sistema esistente
> serve davvero questa visione.»*

Risposta secca: **serve, tranne in tre punti.** Il bersaglio a segni, la
Risonanza, i mazzetti, l'economia del Consiglio e la mappa pescata sono già la
grammatica del brief, costruita e misurata. I tre punti dove non serve sono la
seconda Azione che non esiste (passo 1), le Memorie che mancano (passo 2) e le
due economie della stessa domanda (passo 3).

Nessuno dei tre si chiude con una taratura di numeri.
