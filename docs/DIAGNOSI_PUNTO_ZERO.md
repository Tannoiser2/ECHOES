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

### 3.3 Le Memorie esistono, ma nessuno le scriveva

**Correzione alla prima stesura di questa diagnosi.** Avevo scritto che le
Memorie non esistono, cercandole col prefisso `memory:` che il brief usa. È
falso, e il dizionario dei segni lo dice: le voci di categoria **MEMORY** sono
**80** — su 183 segni in tutto — accanto a 19 STATE (le condizioni), 22 PLACE,
31 ENTITY e 31 FUNCTION. I patti, i miracoli, i martiri e i segreti pubblici
ci sono; hanno un id nudo (`amnesty_granted`, `oath_broken`) invece del
prefisso.

Il difetto è un altro, ed è più preciso: **27 di quelle 80 non le legge
nessuno**, e **20 sono dichiarate come scritte da `asset_physical`** — cioè
dalla faccia stampata delle carte, che è esattamente lo scrittore che il
motore non eseguiva (§3.1). Il dizionario prometteva uno scrittore che non
girava mai.

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

**Passo 1 — entrambe le Azioni eseguibili — FATTO in 0.1.245**
([D-283](DECISIONS.md#d-283)). Misurato su 100 anni a tavolo misto: **1.412
carte calate, di cui il 16,6% con la seconda Azione stampata**; degli 851 segni
stampati sulle Azioni calate **537 sono stati posati sul mondo** e 314 non
hanno trovato il proprio soggetto (una condizione di Regione in una mossa che
non nomina nessuna Regione). Il cancello tiene: 0 seggi bloccati su 8.
**Quello che non ha funzionato, scritto:** il passare scende solo dall'**84,3%
all'82,3%**, contro il 60% che avevo messo come traguardo. La prima ragione per
cui un seggio passa non erano i verbi della mano — è *«mosse legali, nessuna
che gli servisse»*, salita dal 54,7% al 65,1% dei passa. **È appetito del
cervello, non grammatica delle carte**, e va aggredita da lì (passo 4). Restano
tre carte mai calate in 100 anni, tutte FORGIARE.

**Passo 1bis — i 314 segni senza soggetto — FATTO in 0.1.246**
([D-284](DECISIONS.md#d-284)). La carta dice *dove* col suo bersaglio a segni, e
chi cala sceglie il luogo fra quelli che raggiunge — sulla mappa, se è una
persona. Misurato su 100 anni: **862 segni stampati, 862 posati, zero senza
soggetto**. Cancello 0/8.

**Come era il passo 1** (è quello che il brief chiede per primo). I verbi giocabili di una carta diventano **quelli stampati sulla sua
faccia**, non il solo `card_action.kind`; `puts_tag` e `clears_tag` diventano
Effetti con inverso; le 11 seconde Azioni senza verbo ne ricevono uno chiuso
(`SEGNA`, che mette o toglie un segno sul bersaglio). L'app le offre entrambe,
come già fa la scheda della carta.
*Fatto quando*: ogni carta ha almeno un'Azione calata in 100 anni, la seconda
Azione viene scelta almeno una volta su cinque, il passare scende sotto il 60%,
e il cancello resta 0 seggi bloccati su 8.

**Passo 2 — le Memorie che nessuno legge.** Le 80 voci MEMORY ci sono e da
D-283 le carte le scrivono davvero; ne restano **27 che nessuno legge**. Una
memoria scritta e mai letta è un segnalino che si posa e non serve a niente.
Vanno legate a chi le deve leggere: le clausole dei Destini, le condizioni di
ingresso delle Tensioni, il setup della Chronicle successiva.
*Fatto quando*: nessuna voce MEMORY del dizionario ha `read_by` vuoto, e ogni
memoria scritta in 100 anni viene letta almeno una volta.

**Passo 3 — una sola economia delle domande.** Le quattro questioni dell'anno
spariscono; INFLUENZARE e TRAMARE agiscono sui **mazzetti** (scaldare e
raffreddare un Tema, girare o coprire una carta). Resta una sola pista, quella
fisica.
*Costo da misurare prima*: INFLUENZARE è il verbo più desiderato dai bot
(1.979 intenzioni su 7.200 turni); spostarlo sui mazzetti cambia il gioco, e
va misurato sui 100 semi prima di restare.
**Questo passo è una tua decisione, non mia.**

**Passo 4 — il turno che decide — FATTO in 0.1.247**
([D-285](DECISIONS.md#d-285)). Non erano le carte: era l'**appetito**. Il
ripiego del cervello non veniva mai provato, e la lista delle mosse possibili
guardava un solo verbo per carta e un solo bersaglio per verbo. Adesso si passa
il **42,1%** dei turni invece dell'82,1%, il **55%** delle carte pescate si cala
(era 23,2%) e **nessuna carta resta muta** in 100 anni.
*Il costo, scritto*: le Verità scritte scendono da 295 a 256 (−13%), perché chi
spende sulla mappa ha meno peso da mettere nel Consiglio — e il mondo ricorda
solo i Consigli in cui qualcuno ha messo peso. La riserva di mano è il
quadrante, e la sua curva sta in D-285.

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
