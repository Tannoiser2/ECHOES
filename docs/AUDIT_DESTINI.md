# AUDIT — I Destini, e il fatto che nessuno perda mai

Documento di consegna per una sessione che parte da zero. Non presuppone niente
di quello che è stato detto altrove: tutto quello che serve per lavorare al
problema sta qui dentro o è linkato da qui.

**Stato**: 0.1.25 · 180 test in 25 suite verdi · `main` pubblicato su
<https://tannoiser2.github.io> a ogni merge.

---

## 1. Cos'è ECHOES, in dieci righe

Boardgame narrativo-strategico a **Chronicle**: ogni partita è **un anno** nello
stesso mondo. Quattro Entità di scala diversa — una corona, un popolo, una
persona, una cosa che dorme sotto la montagna — preparano la propria posizione e
poi si siedono a un **Consiglio** (Confluence), dove una domanda viene decisa e
quello che si decide **resta scritto**.

- Un anno è 3 Atti da 3 round, 2 azioni a testa per round.
- Le **Tensioni** sono le domande dell'anno; salgono da sole (Drift) e quando una
  tocca la sua soglia si apre un Consiglio.
- Al Consiglio: A trigger · B domanda · C proposta · D posizione (Support /
  Oppose / Condition / Abstain) · E impegno segreto di Asset · F 1d6 · G
  risoluzione **M = S + C − O + W** · H–K conseguenze, Echo, Ripple.
- Ogni seggio ha un **Destino** segreto a tre gradini — Minimum, Victory,
  Triumph, **cumulativi**: se cade il Minimum il livello è NONE qualunque altra
  cosa sia vera.
- Il gioco esiste come app (Godot, gira anche nel browser) e come pezzi da
  stampare. La app è il modo in cui si misura.

Documenti: [RULES_V0_2.md](RULES_V0_2.md) le regole · [GAME_DESIGN.md](GAME_DESIGN.md)
il perché · [DECISIONS.md](DECISIONS.md) ogni deviazione dalla specifica, con i
numeri · [ISSUES.md](ISSUES.md) cosa resta.

---

## 2. Il problema

### 2.1 Il numero

Su **400 risultati di seggio** (100 partite × 4 seggi, tavolo misto,
`run_playtest.gd --runs=100 --seed=7000`):

| livello | quante volte |
|---|---|
| **NONE** | **1** |
| MINIMUM | 205 |
| VICTORY | 181 |
| TRIUMPH | 13 |

Una scala a quattro gradini in cui il primo succede **una volta su
quattrocento** e il quarto nel 3% dei casi è una scala a due gradini. E il
gradino che manca è quello che dà peso a tutti gli altri: **se non puoi fallire,
"Vittoria" vuol dire solo "ho giocato"**.

Lo si vede anche a occhio nudo: due partite giocate nel browser sono finite una
con quattro VICTORY su quattro e una con tre VICTORY e un NONE.

### 2.2 La causa, che non è il bilanciamento

Non è che i Minimi siano *facili*. È che **non sono perdibili**. I Minimi degli
otto seggi in gioco sono fatti di tre condizioni sole:

| seggio | Minimum |
|---|---|
| Re Aldric | `entity_alive` + `region_presence(REG_EREDAN)` |
| Popolo Nahr | `entity_alive` + `region_presence(REG_TERRE_NAHR)` |
| Lyra | `entity_alive` + `discovery_count ≥ 1` |
| Vaerax | `entity_alive` + `region_presence(REG_MONTAGNE_ROSSE)` |
| Maestra Ilve | `entity_alive` + `region_presence(REG_STRADA_MERCANTI)` |
| Kessa dei Fuochi | `region_presence(REG_MONTAGNE_ROSSE)` |
| Priore Anselmo | `entity_alive` + `region_presence(REG_MINIERE_ANTICHE)` |
| Le Città Libere | `entity_alive` + `region_presence(REG_EREDAN)` |

E adesso il fatto che regge tutto:

**`SET_ENTITY_ACTIVE` compare ZERO volte in tutti i dati del gioco.** Il tipo di
Effect esiste nell'enum, nello schema e in `effect_applier.gd`, ed è implementato
e testato. Nessuna Consequence, nessuna carta Echo, nessun Asset lo emette mai.
`entity_alive` è in **7 Minimi su 8** ed è **strutturalmente infalsificabile**.

**`REMOVE_PRESENCE` compare 5 volte in tutti i dati**, e nessuna delle cinque può
togliere una presenza a qualcun altro contro la sua volontà:

- 3 Consequence (`CNS_VALLEY_CLEARED`, `CNS_ABANDONED`, `CNS_EXODUS`), tutte con
  `"optional": true` e tutte sulla `$region_focus` — cioè solo sulla Regione di
  cui si sta discutendo, che quasi mai è quella che il Minimo nomina;
- 2 Asset (`AST_FORCE_BURNED_GATE`, `AST_PEOPLE_EXODUS`), che rimuovono la
  presenza **di chi gioca la carta** (`$actor`): sono costi che ci si infligge da
  soli.

E le 13 Consequence della seconda saga non ne contengono **nessuna**.

`discovery_count` (il Minimo di Lyra) è monotono: le Scoperte si accumulano e non
si tolgono.

> **Conclusione dell'audit**: NONE non è raro per sfortuna. **Perdere non è
> implementato.** L'unico modo per cadere sotto il Minimo è farlo a sé stessi.

Questo riformula l'issue: non è un problema di taratura, è un pezzo di gioco che
manca.

### 2.3 Il secondo problema, che vive nello stesso file

**L'asse dei rapporti quasi non esiste.** Dalla 0.1.25 il punteggio di una
proposta **sa leggere** un rapporto che si muove
([D-066](DECISIONS.md#d-066)) — c'è il ramo, ci sono i test — e continua a pesare
**zero su 156** letture, perché:

- solo **2 Consequence su 45** contengono `SET_RELATION`, entrambe nella prima
  saga;
- **nessun Destino in gioco** ha una clausola `relation_state` (l'unica in tutti
  i dati sta in `DST_VAERAX_WATCHED`, un Destino di successione).

Forgiare — muovere di un passo il rapporto con un altro giocatore — è **una delle
sei azioni del gioco** e non ha quasi niente su cui mordere. È ISSUES 14.

I due problemi si somigliano: un'Entità che non può essere spenta e un rapporto
che non può diventare ostilità sono lo stesso buco visto da due lati. **Il gioco
non ha modo di far male a nessuno.**

---

## 3. Cosa è già stato provato, per non rifarlo

Ogni voce ha i numeri nel documento linkato.

| | cosa | esito |
|---|---|---|
| [D-034](DECISIONS.md#d-034) | il tavolo si asteneva sul 96% delle proposte | era la policy, non il contenuto |
| [D-035](DECISIONS.md#d-035) | contenuto che la policy non sceglie mai | *«tarare la policy finché il suo contenuto si accende è adattare la misura alla risposta»* |
| [D-051](DECISIONS.md#d-051) | seggi bloccati su un livello solo | causa: quattro ottimizzatori identici. Da qui il **tavolo misto** |
| [D-055](DECISIONS.md#d-055) | prima leva sull'Oppose: la Condition entra nel margine | fallimenti 315 → 282; non ha detronizzato l'Oppose |
| [D-061](DECISIONS.md#d-061) | un Consiglio non rimette ai voti una domanda già decisa | Truth ripetute 20 Chronicle su 40 → 0 |
| [D-063](DECISIONS.md#d-063) | perché certe proposte non arrivano mai ai voti | «mai eleggibile» = 0; **il proponente lo decide il posto, e il posto è di chi vuole l'esito ovvio** |
| [D-064](DECISIONS.md#d-064) | seconda leva: chi si oppone non recupera la carta | divario aggressivo/prudente 37 → 26 |
| [D-066](DECISIONS.md#d-066) | i Destini non nominavano le domande che si aprivano | ABSTAIN 80% → 70%; `ADJUST_TENSION` pesato 6/468 → 266/669 |

**Un tentativo già respinto, con i numeri**: una Conseguenza che alzava di 1 la
domanda quando una proposta cadeva rendeva il blocco **più** conveniente, non
meno, e portava le Chronicle sopra il tetto del §7.

---

## 4. Le trappole in cui si cade lavorando qui

Quattro, e ognuna è costata almeno un giro.

1. **L'ottimizzatore da solo sotto-riporta.** Misurato a tavolo uniforme, il
   contenuto della prima saga sembra morto per 2 proposte su 15; a tavolo misto
   (i quattro caratteri di D-051) sono **15 su 15**. Ogni misura di
   «raggiungibilità» va fatta col tavolo misto, altrimenti si riscrive contenuto
   che funziona.
2. **Una clausola a livello Victory non è una clausola a livello Triumph.** Le
   dieci clausole di D-066 messe a livello Victory hanno fatto crollare la
   Vittoria da 192 a 126 su 400 e bloccato un seggio; spostate a Triumph, il
   punteggio le legge lo stesso (`_conditions()` legge tutti e tre i livelli) e
   il bilanciamento regge.
3. **Rendere contesi i Consigli allarga il divario aggressivo/prudente.** Da 26 a
   31 in D-066. Non è rumore: il carattere aggressivo è costruito per
   approfittare dei contesi. I due obiettivi tirano in direzioni diverse, e va
   messo in conto invece che tarato via.
4. **Regola di casa: una modifica alle regole si misura *prima* di scriverla**, e
   o entra con i numeri accanto, o è scritta come respinta con i numeri accanto.

---

## 5. Gli strumenti, con i numeri di riferimento da confrontare

Godot 4.7.1, headless. Sostituisci `godot` col percorso del binario.

```bash
# La suite. Deve restare verde: 180 test in 25 suite, 4508 asserzioni.
godot --headless --path godot --script res://tests/run_tests.gd

# Dati e schemi. Il generato va rigenerato dopo ogni modifica a /schema.
python3 tools/validate_data.py
python3 tools/gen_gd_schema.py          # riscrive godot/scripts/core/schema_defs.gd
python3 tools/gen_gd_schema.py --check  # come lo verifica la CI
python3 tools/build_manifest.py --check

# Determinismo: due giri in cartelle diverse e diff -r, devono essere identici.
OUT=/tmp/a tools/run_sims.sh && OUT=/tmp/b tools/run_sims.sh && diff -r /tmp/a /tmp/b
OUT=/tmp/x tools/run_export.sh && OUT=/tmp/y tools/run_export.sh && diff -r /tmp/x /tmp/y
```

### La misura che conta per questo problema

```bash
godot --headless --path godot --script res://cli/run_playtest.gd -- --runs=100 --seed=7000
```

Stessi 100 semi di D-055, metà prima saga e metà seconda, tavolo misto e tavolo
uniforme sugli stessi semi. **Baseline 0.1.25, tavolo misto:**

```
Consigli   media 5.97   mediana 6   da 4 a 7     <- la banda del §7: non deve uscirne
Esiti      FAIL 219  SUCC 86  SUCC 107  DECI 185
Verita     512 scritte, 480 diverse

carattere              NONE / MINIMUM / VICTORY / TRIUMPH
prudente                 0  64  34   2
aggressivo               1  29  65   5
distratto                0  45  52   3
ostinato                 0  67  30   3

tavolo uniforme   seggi bloccati su un solo livello: 3 su 8
tavolo misto      seggi bloccati su un solo livello: 0 su 8
```

**Le due colonne da guardare**: `NONE` (oggi 1 su 400 — è il problema) e `seggi
bloccati a tavolo misto` (oggi 0 su 8 — non deve peggiorare).

### Le altre sonde

```bash
# Perche' nessuno si oppone: il punteggio di una proposta seggio per seggio, e
# quali Effect non spostano MAI un punteggio.
godot --headless --path godot --script res://cli/run_stance_probe.gd -- --runs=40 --chronicle=CHR_03
#   baseline 0.1.25 — CHR_01: ABSTAIN 70,2%, Consigli con un no 68%
#                     CHR_03: ABSTAIN 74,1%, Consigli con un no 53%
#                     SET_RELATION: letto 156, pesato 0   <- ISSUES 14

# Cosa il tavolo poteva dire e cosa ha detto, e perche' una proposta non arriva
# mai ai voti (tre motivi diversi, tre rimedi diversi).
godot --headless --path godot --script res://cli/run_choice_probe.gd -- --chronicle=CHR_03 --tavolo=misto
#   baseline: 5 proposte su 20 non arrivano mai ai voti

# Ogni frase distinta che il motore ha prodotto, e le ripetizioni dentro la
# stessa Chronicle.
godot --headless --path godot --script res://cli/run_text_probe.gd -- --runs=40 --chronicle=CHR_03

# Sweep di un knob senza toccare i dati.
godot --headless --path godot --script res://cli/run_playtest.gd -- --runs=100 --oppose-recovery=1
godot --headless --path godot --script res://cli/run_balance_probe.gd -- --runs=40 --influence-cap=1
```

In `godot/cli/` ci sono quindici script, dieci dei quali sono sonde — `balance`,
`choice`, `crisis`, `destiny`, `echo`, `margin`, `silence`, `stance`, `text`,
`world` — e ognuna ha in testa il commento che dice a quale domanda risponde.
**Se la domanda che ti serve non ha una sonda, scrivila**: è il modo in cui
questo progetto ha trovato ogni difetto che conta, questo compreso.

---

## 6. Dove guardare nel codice

| cosa | dove |
|---|---|
| valutazione dei Destini, i tre gradini cumulativi | `godot/scripts/chronicle/destiny_evaluator.gd` |
| se una condizione vale, per tutti i 12 tipi | `godot/scripts/world/condition_evaluator.gd` |
| cosa vale una proposta per un seggio (`_score_effect`) | `godot/scripts/seat/policy_decider.gd` |
| applicazione degli Effect e i loro inversi | `godot/scripts/core/effect_applier.gd` |
| la sequenza A–K del Consiglio | `godot/scripts/confluence/confluence_controller.gd` |
| i Destini | `godot/data/destinies/destinies_chronicle_0{1,3}.json` |
| le Conseguenze | `godot/data/consequences/consequences_chronicle_0{1,3}.json` |
| le carte Echo | `godot/data/echoes/` |
| schemi JSON (fonte di verità) | `/schema` → `tools/gen_gd_schema.py` → `godot/scripts/core/schema_defs.gd` |

---

## 7. Direzioni possibili, non decise

Nessuna di queste è stata misurata. Vanno provate **una alla volta**, sugli
stessi 100 semi, e il risultato va scritto in `DECISIONS.md` che entri o che
venga respinto.

1. **Dare un uso a `SET_ENTITY_ACTIVE`.** È il modo più diretto: una Conseguenza
   per saga che possa spegnere un'Entità. Ma spegnere un giocatore a metà anno è
   una decisione di design, non di taratura — un seggio eliminato è un giocatore
   che guarda gli altri finire.
2. **Rendere le presenze togliibili sul serio.** Consequence con
   `REMOVE_PRESENCE` non opzionale, e su una Regione nominata invece che sulla
   `$region_focus`. Più mite della 1 e probabilmente sufficiente: un Minimo che
   nomina Eredan diventa perdibile solo se qualcuno può cacciarti da Eredan.
3. **Riscrivere i Minimi.** Oggi sono «esisti ancora» e «sei ancora lì». Un
   Minimo che chiedesse qualcosa che si può perdere in un anno — una relazione,
   un controllo, un tag — cambierebbe la scala senza toccare il motore. Attenzione
   alla trappola 2: un Minimo troppo duro non crea tensione, azzera i livelli di
   tutti.
4. **Accettare NONE ≈ 0 e togliere il gradino**, scrivendo la scala a tre livelli.
   È una risposta legittima e va scartata con un motivo, non per omissione.
5. **Per ISSUES 14**: Conseguenze che facciano nemici (`SET_RELATION` verso
   `HOSTILE`/`ENEMY`) e almeno una clausola `relation_state` per tavolo. Qui il
   codice è già pronto e manca solo il contenuto.

**Attenzione a un effetto di secondo ordine**: i livelli di Destino non sono solo
il punteggio finale. `policy_decider._open_levels()` li usa per decidere *cosa un
seggio gioca*, quindi rendere il Minimum perdibile cambia anche il comportamento
di tutti durante l'anno, non solo la riga del risultato. Va misurato con la sonda
delle posizioni, non solo col playtest.

---

## 8. Regole di casa del repository

- **Tutta la comunicazione col committente è in italiano.** Il codice e i
  commenti seguono lo stile del file in cui stanno (misto: molti commenti in
  inglese, i più recenti in italiano). I documenti in `docs/` sono in italiano.
- **GDScript tipato**, niente `class_name`: si usa `const X := preload(...)`.
  Una inner class può fare `extends` di una const preloaded.
- **Effect-sourcing**: ogni mutazione della WorldState è un `Effect` con il suo
  inverso. Le eccezioni dichiarate sono `CREATE_ECHO` e `APPEND_TRUTH`
  (irreversibili) e il setup strutturale ([D-006](DECISIONS.md#d-006)).
- **Determinismo**: stesso seme ⇒ stesso mondo, fino al dado. Due giri di
  `run_sims.sh` e di `run_export.sh` devono dare cartelle identiche. Niente
  `Date`/random fuori da `RngService`.
- **Dopo ogni modifica a `/schema`** va rilanciato `tools/gen_gd_schema.py`,
  altrimenti la CI fallisce su `--check`.
- Ogni deviazione dalla specifica v0.2 va scritta in `DECISIONS.md` con il numero
  che l'ha motivata. Il documento si legge dal fondo: le decisioni recenti stanno
  in testa, dopo D-018.
- `docs/ISSUES.md` è l'indice di cosa resta: una voce si chiude nello stesso
  commit che la risolve.
- Branch e PR: si sviluppa e si pusha **solo** sul branch assegnato, le PR si
  aprono **come bozza**, e ogni commento su GitHub finisce con il footer di
  attribuzione.

---

## 9. Cosa vuol dire «fatto»

Una variante è chiusa quando:

- è misurata con `run_playtest.gd --runs=100 --seed=7000`, e **NONE smette di
  essere un livello teorico** — oppure è scritta come respinta con i numeri
  accanto;
- i **seggi bloccati a tavolo misto restano 0 su 8** e i Consigli per Chronicle
  restano nella banda del §7 (mediana 3–6, oggi 5,97);
- la suite è verde, `validate_data.py` passa, sim ed export restano
  deterministici;
- c'è una voce in `DECISIONS.md` con la tabella prima/dopo, e `ISSUES.md` 15 è
  aggiornata o chiusa.
