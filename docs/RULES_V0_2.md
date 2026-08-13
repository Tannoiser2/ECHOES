# ECHOES — Regole v0.2 (implementate in 0.0)

Il testo di riferimento è la specifica esecutiva v0.2. Questo documento descrive
**cosa fa il codice**: i numeri che sono davvero in gioco, le regole dove la
specifica lasciava un margine e come è stato chiuso. Ogni scostamento è marcato
con il riferimento a [DECISIONS.md](DECISIONS.md).

Tutti i numeri qui sotto sono data-driven: vivono in
`godot/data/chronicle_01/chronicle_01.json` e nei file di `godot/data/`, non nel
codice.

---

## 1. Struttura temporale (§7)

| valore | default | dove |
|---|---|---|
| Atti | 3 | `chronicle.acts` |
| Round per Atto | 3 | `chronicle.rounds_per_act` |
| Action Opportunities per giocatore per round | 2 | `chronicle.action_opportunities_per_round` |
| Limite di mano | 7 | `chronicle.hand_limit` |
| Token presenza per Entità | 3 | `chronicle.presence_tokens` |
| Asset impegnabili in Confluence | 0–3 | `chronicle.max_commit_assets` |
| Asset impegnabili da una Condition | 0–2 | `chronicle.max_condition_commit_assets` |
| Soglia di qualificazione della Condition | 2 | `chronicle.condition_qualified_threshold` |
| INFLUENCE per Entità per round | 1 | `chronicle.influence_rules.max_per_entity_per_round` |
| INFLUENCE per Tensione per round | 1 | `chronicle.influence_rules.max_per_tension_per_round` |
| Tensioni in gioco | 4 | `chronicle.tensions` |
| Soglie | 6 / 6 / 6 / 5 | `tension.threshold` |
| Regioni tenibili senza sforzo | 2 | `chronicle.control_rules.max_stable_control` |

**Sovraestensione** (D-027): ogni Regione tenuta oltre `max_stable_control` alza
di 1, ogni round, la Tensione del **dominio di quella Regione**. Non è una
penalità a chi sta vincendo: è la situazione che risponde. E a inizio di una
Chronicle di campagna, una Regione tenuta senza nessuno dentro torna a nessuno —
non si governa dove non si è.

Ordine di un round:

1. **ACTIONS** — in ordine di turno, ogni Entità attiva spende le sue 2 AO
   consecutivamente. Le AO non si accumulano fra round.
2. **DRIFT** — il mondo applica +1 a una Tensione secondo la drift track.
3. **THRESHOLD_CHECK** — si apre al massimo **una** Confluence.
4. Fine Atto: si pesca 1 carta Echo dal pool dell'Atto.
5. Fine Chronicle: valutazione Destiny, registrazione finale, salvataggio.

Un'azione rifiutata consuma comunque l'AO: il tempo passa anche quando il piano
non funziona.

---

## 2. Le sei azioni ordinarie (§10)

Ogni AO compra esattamente uno di questi template. Tutti i costi e tutti gli
effetti passano da un Effect.

### ACQUIRE
Pesca 1 Asset dal mazzo di una famiglia a scelta. Se l'Entità ha presenza in una
Regione che elenca quella famiglia fra le proprie `asset_sources`, pesca 2 e ne
tiene 1 (l'altra va negli scarti di quella famiglia).

Quando il mazzo di pesca è vuoto gli scarti vengono rimescolati con l'RNG seeded.
Se anche gli scarti sono vuoti l'azione è **illegale**: non c'è niente da pescare.

All'ottavo Asset in mano se ne scarta uno (default: il più debole).

### MOVE
Aggiunge o sposta 1 token presenza in una Regione **adiacente** a una in cui hai
già presenza, oppure in una delle tue Regioni iniziali. Con i 3 token già sul
tavolo, MOVE ne sposta uno; serve `from_region_id` (default: la prima Regione
occupata diversa dalla destinazione). Una Regione non può ospitare più token dei
suoi `presence_slots`; un MOVE che non ha spazio viene rifiutato **senza costo di
stato** (il token già rimosso viene rimesso a posto).

Più token nella stessa Regione sono ammessi e contano: la presenza è un numero,
non un flag. È quel numero a decidere il proponente di una Confluence.

### INFLUENCE
Modifica di ±1 una Tensione. Serve **una** delle due:

- presenza in una Regione taggata `domain:<dominio della Tensione>` — gratis;
- lo scarto di 1 Asset di una famiglia rilevante per quella Tensione.

Una Tensione velata non è influenzabile finché *quella* Entità non ne conosce il
valore (SCHEME). Conoscerlo è personale: scoprirlo non lo rivela agli altri.

**Limite: 1 INFLUENCE per Entità per round**, su tutte le Tensioni insieme
(`chronicle.influence_rules.max_per_entity_per_round`). Senza, quattro giocatori
con otto AO annullano il Drift +1 e la Chronicle non produce mai una Confluence:
misurato, non ipotizzato — vedi [D-021](DECISIONS.md#d-021). Il limite si toglie
da configurazione e si torna al comportamento v0.2 originale.

**Limite: 1 INFLUENCE per Tensione per round**
(`chronicle.influence_rules.max_per_tension_per_round`). Il primo limite dice
quanto in fretta può muoversi una *persona*; questo dice quanto in fretta può
muoversi una *domanda*, qualunque cosa voglia il tavolo. Quattro giocatori a cui
interessa la stessa Tensione potrebbero comunque portarla a soglia in un round
solo — vedi [D-023](DECISIONS.md#d-023). Anche questo si toglie da
configurazione.

**La pressione si sposta, non sparisce** (D-029). Spingere **giù** una Tensione
alza di 1 una delle sue `linked_tensions` — quella al valore più basso fra
quelle in gioco. Non si spegne una crisi: si sceglie quale avere.

Senza questa regola un tavolo che spinge solo verso il basso tiene l'intera
Chronicle in silenzio: misurato, 33 partite su 40 senza una sola Confluence.
Con quattro giocatori a una INFLUENCE per round il conto è 4 in giù, 4 spostate
in su e il +1 del Drift — la soppressione totale lavora per il mondo. Spingere
**verso l'alto** non sposta niente: alimentare direttamente un incendio non è
uno scambio.

Il knob `presence_directions` esiste ed è implementato (limita a quali direzioni
si applica la via gratuita per presenza), ma in Chronicle I copre entrambe: da
solo peggiorava i numeri.

### FORGE
Sposta di 1 passo una relazione sulla scala
`ENEMY ↔ HOSTILE ↔ NEUTRAL ↔ ALLY ↔ BOUND`.

- **Verso l'alto**: serve il consenso dell'altro giocatore e lo scarto di 1 Asset
  BONDS.
- **Verso il basso**: unilaterale e gratuito, ma finisce nel log pubblico.

I tag speciali (PACT, DEBT, PROMISE, VENDETTA, KINSHIP) non si applicano con
FORGE: arrivano da Asset e Consequence.

### SCHEME
Uno fra:

- **TENSION** — leggi in privato il valore di una Tensione. Lascia il tag
  `knows_tension:<id>`; se la Tensione era velata lascia anche
  `discovery:<id>`, perché aprire un velo è una Scoperta e conta per i Destiny.
- **ECHO_DECK** — guarda le prime 2 carte del mazzo Echo dell'Atto corrente.
- **REGION** — leggi l'informazione privata di una Regione, se ne ha una.

Il risultato è privato: torna al chiamante, non al log pubblico.

### CLAIM
- **CREATE** — scarta 1 Asset AUTHORITY, crea un Claim su un dominio di Tensione.
- **FORCE** — in un round **successivo**, con la Tensione a valore ≥ 3, consuma il
  Claim e scarta 1 ulteriore AUTHORITY. A fine round si apre una Confluence su
  quella Tensione al posto delle soglie in coda, e il proponente è chi ha forzato.

Forzare costa 1 AO ([D-011](DECISIONS.md#d-011)). Una sola Confluence forzata per
round.

---

## 3. Tensioni (§11)

Chronicle I in 0.0:

| Tensione | dominio | iniziale | soglia | visibilità | famiglie rilevanti |
|---|---|---|---|---|---|
| TEN_FAMINE — La Carestia | SURVIVAL | 3 | 6 | aperta | WEALTH, PEOPLE, AUTHORITY |
| TEN_AWAKENING — Il Risveglio | ANCIENT | 2 | 6 | **velata** | KNOWLEDGE, FORCE, BONDS |
| TEN_SUCCESSION — La Successione | TERRITORY | 2 | 6 | aperta | AUTHORITY, BONDS, FORCE |
| TEN_ROADS — Le Vie Interrotte | RESOURCE | 1 | 5 | **velata** | WEALTH, KNOWLEDGE, PEOPLE |

La soglia del Risveglio è scesa da 7 a 6 quando le Tensioni sono passate da 2 a
4: nove gettoni di Drift divisi in quattro non ne portano più una a 7 da soli
([D-024](DECISIONS.md#d-024)).

**Regione a fuoco**: ogni Tensione dichiara `focus_region_tags`, e il motore le
associa la Regione del suo dominio che porta il primo tag della lista (a parità,
quella con più presenza). È la Regione che riempie `$the_region` nel testo e
`$region_focus` negli Effect: una domanda autorata una volta sola segue la crisi
sulla mappa invece di nominare per sempre lo stesso posto.

**Drift**: una traccia di 9 voci (2× FAMINE, 3× AWAKENING, 2× SUCCESSION,
2× ROADS) mescolata una volta a inizio partita con l'RNG seeded, consumata una
per round. Il Drift è un Effect con
`source.kind = "system"`.

**Presagi**: quando una Tensione raggiunge un `omen_thresholds.at` per la prima
volta, il messaggio **definito nei dati** viene detto in pubblico. Non rivela mai
il numero, e non si ripete. Il codice non inventa mai un presagio.

**Velatura**: una Tensione velata non mostra il valore nel log pubblico
(`"Il Risveglio: velata"`). Raggiunge comunque la soglia e apre comunque la
Confluence: il mondo reagisce anche a ciò che il tavolo non ha ancora misurato.

**Soglia**: al check di fine round, le Tensioni a valore ≥ soglia sono ordinate
per valore decrescente, poi per ordine di definizione nella Chronicle. La prima
apre la Confluence; le altre restano in coda e vengono ricontrollate il round
dopo.

---

## 4. Asset (§9)

Sei famiglie: FORCE, AUTHORITY, PEOPLE, KNOWLEDGE, WEALTH, BONDS.

In una Confluence un Asset impegnato vale la sua **forza piena** se la famiglia è
fra le `relevant_asset_families` della Tensione, **1** altrimenti. Il
`confluence_modifier` si applica dopo:

| kind | effetto |
|---|---|
| `NONE` | nessuno |
| `FLAT_BONUS` | +valore sempre |
| `RELEVANT_BONUS` | +valore solo se la famiglia è rilevante |
| `OPPOSE_BONUS` | +valore solo sul fronte Oppose |

Regole di scarto:

| `discard_or_retain_rule` | dopo la Confluence |
|---|---|
| `DISCARD` | scartato, salvo recupero di un opposer su Failure |
| `ALWAYS_DISCARD` | scartato sempre, non recuperabile |
| `RETAIN_ON_SUCCESS` | resta in mano se la proposta passa |
| `RETAIN` | resta sempre in mano |

`on_commit_effects` sono Effect che la carta stessa paga quando viene impegnata
(la Banda Armata alza di 1 la Tensione in gioco).

---

## 5. Confluence: la sequenza A–K (§12.2)

**A. Trigger** — soglia, Claim forzato o carta Echo.
**B. Question** — dal template, fra quelle la cui eligibility è soddisfatta
**meno quelle che questa Tensione ha già messo ai voti nella Chronicle**: un
Consiglio non rimette in discussione quello che ha già deciso, finché gli resta
qualcosa che non ha ancora chiesto ([D-061](DECISIONS.md#d-061)). Quando le ha
fatte tutte tornano disponibili tutte. Default fra quelle rimaste: l'**ultima**
eligibile in ordine di definizione, cioè la più dura
([D-016](DECISIONS.md#d-016)). Il proponente può sceglierne un'altra.
**C. Proposition** — il proponente è chi ha forzato il Claim; altrimenti chi ha
più presenza nelle Regioni del dominio, poi chi ha più Asset di famiglie
rilevanti in mano, poi l'ordine di turno. Sceglie fra le opzioni strutturate del
template la cui eligibility è soddisfatta (niente testo libero in v0.x).
**D. Stance** — **pubblica**, in ordine di turno dal giocatore alla sinistra del
proponente: Support, Oppose, Condition o Abstain. Chi sceglie Condition dichiara
subito la clausola.
**E. Commit** — **segreto**: 0–3 Asset (0–2 per una Condition), rivelati
simultaneamente.
**F. World Factor** — 1d6 seeded: `1→−2 · 2→−1 · 3→0 · 4→0 · 5→+1 · 6→+2`.
**G. Resolve** — vedi sotto.
**H. Consequence** · **I. State Change** · **J. Echo Check** · **K. Ripple**.

### Matematica (Strategy `baseline_v0`)

```
S = somma dei valori del fronte Support (proponente incluso)
C = somma dei valori del fronte Condition, se la clausola è qualificata (0 altrimenti)
O = somma dei valori del fronte Oppose
W = World Factor
M = S + C − O + W
```

| M | esito |
|---|---|
| ≤ −1 | **Failure** |
| 0 … 1 | **Success with Cost** |
| 2 … 4 | **Success** |
| ≥ 5 | **Decisive Success** |

Gli Asset impegnati da chi ha dichiarato Condition restano contati a parte: se il
loro totale è ≥ 2 la clausola è **qualificata**, si allega a ogni esito di
successo **e il totale entra nel margine dalla parte del Support**. Una condizione
è «sono a favore, a un patto», e chi la pone paga per farla passare
([D-055](DECISIONS.md#d-055)). Una condizione non qualificata non allega niente e
non sposta il margine: le carte sono spese lo stesso.

Effetti sulla Tensione:

- **Failure** — la Tensione scende di 2 e la questione resta aperta (§A6).
- ogni successo — la Tensione va a 1.

### Ordine di applicazione dentro G–K

Fissato, perché è osservabile ([D-014](DECISIONS.md#d-014)):

1. tiro del World Factor
2. matematica
3. esito sulla Tensione (−2 oppure a 1)
4. `on_commit_effects` degli Asset impegnati
5. Consequence dell'esito (successo: quelle della proposta · fallimento: il pool
   `failure`)
6. pool `cost` (solo Success with Cost) oppure `decisive_bonus` (solo Decisive)
7. clausola della Condition, se qualificata e l'esito è un successo
8. disposizione degli Asset impegnati
9. Echo Check
10. Ripple

### Disposizione degli Asset (§12.3, [D-013](DECISIONS.md#d-013))

- **Failure**: tutto l'impegnato viene scartato, tranne 1 Asset a scelta per ogni
  opposer. Un `ALWAYS_DISCARD` non può essere quello recuperato.
- **Successo**: tutto scartato salvo `RETAIN` / `RETAIN_ON_SUCCESS`.

### Echo Check (§12.4)

Si crea un Echo (e il relativo Truth) se:

- esito **Decisive**; oppure
- esito **Success** o **Success with Cost** con S + O ≥ 6; oppure
- esito **Failure** con O ≥ 6 — una sconfitta memorabile è storia.

`CREATE_ECHO` e `APPEND_TRUTH` sono **irreversibili**.

### Ripple (§12.2 K)

La Confluence chiusa applica il `ripple` del template: +1 (o +2) alle Tensioni
collegate. È così che il Risveglio diventa urgente
([D-009](DECISIONS.md#d-009)).

---

## 6. Carte Echo (§15)

Le carte non contengono eventi scriptati: hanno `function_id`, `eligibility` e
`effect_hooks`. A fine Atto si pesca la prima carta del mazzo che appartenga alle
famiglie drammatiche del pool di quell'Atto e la cui eligibility sia soddisfatta.

| Atto | pool |
|---|---|
| 1 | PRESSIONE |
| 2 | PRESSIONE + ROTTURA + SVOLTA |
| 3 | ROTTURA + SVOLTA + RISOLUZIONE |

Una carta con `forces_confluence_on` apre una Confluence subito, a fine Atto
([D-007](DECISIONS.md#d-007)).

---

## 7. Destiny (§14)

Tre livelli — Minimum, Victory, Triumph — valutati automaticamente sul WorldState
come composizione di condizioni riutilizzabili: `control_count`,
`state_tag_present` / `state_tag_absent`, `asset_threshold`, `entity_alive`,
`relation_state`, `tension_limit`, `discovery_count`, `region_presence`,
`promise_kept` / `promise_broken`.

I livelli sono **cumulativi** ([D-017](DECISIONS.md#d-017)): un Triumph richiede
anche Victory e Minimum. Nessun punteggio generale; più giocatori possono
ottenere Victory. Il risultato conserva anche *come* è stato raggiunto — le
condizioni verificate e gli Echo a cui l'Entità ha partecipato.

Definizioni ausiliarie:

- **discovery_count** conta i tag `discovery:` sull'Entità.
- **promise_kept** è vero se la coppia porta un tag PROMISE o PACT e la relazione
  non è precipitata sotto NEUTRAL; **promise_broken** è vero se porta VENDETTA, o
  se una promessa esiste e la relazione è ostile.

---

## 8. Informazione privata (§19.2)

Il log pubblico non contiene mai:

- il valore di una Tensione velata;
- il risultato di uno SCHEME;
- gli impegni prima della rivelazione simultanea.

Contiene sempre le Stance, le rotture di relazione e ogni cambiamento di State.
`tests/smoke/test_chronicle_run.gd` verifica che il valore velato non compaia nel
log di una partita completa.
