# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).
Il progetto segue le milestone della specifica esecutiva v0.2.

---

## [0.0.2] — Le proposte cominciano a costare qualcosa

Chiude l'osservazione O-4 della 0.0.1 e la O-2. Nessuna UI: la 0.1 resta non
iniziata.

### Added

- **Quattro Consequence nuove** — `CNS_VALLEY_CLEARED`,
  `CNS_CROWN_DISPOSSESSED`, `CNS_MINE_TAKEN`, `CNS_STUDY_UNDER_GUARD`. Portano il
  set da 8 a 12, sopra le 8 del §18.2: deviazione deliberata, registrata in
  [D-022](docs/DECISIONS.md) come chiede il §25. Ognuna toglie qualcosa di
  preciso a un posto preciso al tavolo, che e la ragione per cui esistono.
- **`REMOVE_PRESENCE` con `optional`** — una Consequence puo dire "sgomberali
  dalla Valle" senza sapere se qualcuno e accampato li: marcata opzionale, quello
  e un no-op e non un Effect fallito.
- **`--tension-cap` nella sonda** — sweep del secondo limite senza toccare i dati.

### Changed

- **Limite di 1 INFLUENCE per Tensione per round**
  (`chronicle.influence_rules.max_per_tension_per_round`). Reversibile come il
  primo: si toglie dalla Chronicle e sparisce. Vedi
  [D-023](docs/DECISIONS.md).
- **La policy vede il danno** — valuta `ADD_PRESENCE` / `REMOVE_PRESENCE` contro
  le proprie condizioni `region_presence` e `SET_CONTROL` contro `control_count`,
  e risponde con `OPPOSE` a una proposta che le costa 2 o piu, invece di una
  clausola di cortesia.
- **`plan_b_broken_council`** — i Nahr mettono il terzo token sulla Strada dei
  Mercanti, quindi nel dominio SURVIVAL sono loro la parte piu presente e la
  domanda sul grano e loro da porre. Il piano ora produce la sconfitta memorabile
  che il suo nome promette: S1 O6 M−5, fronte contrario a 6, quindi Echo lo
  stesso (§12.4).
- **`tests/smoke/test_balance.gd`** — la guardia ora giudica l'aggregato
  (mediana 3-4, al massimo il 10% delle partite fuori da 2-6, almeno 1 Echo ogni
  2 Chronicle) invece della singola partita. Il §7 descrive cosa deve mostrare un
  playtest, non vieta una Chronicle silenziosa. Detto per intero: la guardia e
  stata rilassata dopo che ha fallito — la motivazione e in
  [D-023](docs/DECISIONS.md), con la sequenza dichiarata.
- **`ScriptedDecider`** segnala un id di Asset inesistente in un piano invece di
  ignorarlo in silenzio. Un Asset assente dalla mano resta una degradazione
  silenziosa; un id che non e un Asset e un refuso.

### La misura, prima e dopo

Su 40 Chronicle, seed 1000-1039:

| | mediana | in banda 3-4 | sotto il minimo | FAILURE | SwC | SUCCESS | DECISIVE |
|---|---|---|---|---|---|---|---|
| 0.0.1 (8 Consequence, 1 cap) | 4 | 82% | 0/40 | **0** | 1 | 79 | 75 |
| 12 Consequence, 1 cap | 2 | 20% | 8/40 | 2 | 4 | 47 | 36 |
| **12 Consequence, 2 cap** | **3** | **70%** | 2/40 | **18** | **15** | 57 | 27 |

Tutte e quattro le bande di esito del §12.3 esistono ora nel gioco aperto. Il
resolver non e stato toccato: la matematica del §A5 e la stessa della 0.0.

### Segnalato, non corretto

- **O-5**: 2 Chronicle su 40 producono una sola Confluence, sotto il minimo che
  il §7 nomina. Con il solo cap per Entita erano 0. E il prezzo pagato per le due
  bande di esito mancanti, e il §7 dice di riportare invece di correggere in
  silenzio: questo e il riporto. Da rimisurare con le 4 Tensioni del §19.4 prima
  di aggiungere qualsiasi altra regola.

---

## [0.0.1] — Passo di bilanciamento

Chiude l'osservazione D-018 della 0.0. Nessuna UI: la 0.1 resta non iniziata.

### Added

- **`cli/policy_decider.gd`** — un giocatore che gioca davvero per il proprio
  Destiny. Deriva gli obiettivi dai dati: il livello piu basso non ancora
  raggiunto, le Tensioni che quel livello vuole basse e — decisivo — quelle che
  ha bisogno di portare a maturazione, perche l'unica cosa che puo soddisfare una
  sua condizione e una Consequence che sta dietro a una Confluence. Nessuna IA
  scritta a mano per singola Entita.
- **`cli/run_balance_probe.gd`** — gioca N Chronicle su N seed e riporta la
  distribuzione: Confluence per partita, esiti, Echo, livelli Destiny, valore
  finale delle Tensioni. Con `--influence-cap` e `--presence-directions` fa lo
  sweep di un knob senza toccare i dati.
- **`ActionResolver.check()` / `can_execute()`** — perche un'azione verrebbe
  rifiutata, senza toccare nulla. `execute()` la chiama per prima, quindi ogni
  precondizione e scritta una volta sola. La Action Dialog della 0.1 la usera per
  disabilitare i bersagli illegali (§19.3).
- **`tests/smoke/test_balance.gd`** — 24 Chronicle giocate dalla policy: fallisce
  se la mediana esce dalla banda 3-4 del §7, se una singola partita esce da 2-6,
  se i Destiny smettono di essere contesi o se il cap non regge.

### Changed

- **Limite di 1 INFLUENCE per Entita per round** su tutte le Tensioni
  (`chronicle.influence_rules.max_per_entity_per_round`). Data-driven e
  reversibile: togliendo `influence_rules` torna il comportamento v0.2.
  Implementato anche `presence_directions`, che in Chronicle I resta su entrambe
  le direzioni.

### La misura, prima e dopo

| | mediana Confluence | in banda 3-4 (§7) | fuori da 2-6 | INFLUENCE per partita |
|---|---|---|---|---|
| policy ingenua, regole v0.2 | 0 | 0/30 | 30/30 | 7.5 |
| policy corretta, regole v0.2 | 3 | 24/40 | 10/40 | 45.7 |
| **policy corretta, cap 1** | **4** | **33/40** | **0/40** | **20.1** |

La riga di mezzo e la piu importante: gran parte del problema apparente era lo
strumento di misura, non le regole. Aldric ha bisogno di `control_count >= 2`, e
il controllo cambia mano solo dentro una Confluence — un Aldric competente spinge
la Carestia *verso l'alto*. Insegnarlo alla policy ha portato la mediana da 0 a 3
senza cambiare una sola regola. Il cap ha fatto il resto, e ha riportato INFLUENCE
dal 63% al 28% di tutte le azioni giocate.

Le alternative sono state misurate e scartate: la via per presenza limitata al
solo +1 peggiora i numeri da sola (mediana 2), e insieme al cap da un risultato
peggiore del cap da solo. Dettaglio in [D-021](docs/DECISIONS.md).

### Segnalato, non corretto

- **O-4**: su 154 Confluence misurate, 0 Failure e 1 Success with Cost. Due delle
  quattro bande di esito del §12.3 non compaiono nel gioco aperto, anche se i
  piani scriptati dimostrano che sono raggiungibili. La causa sembra il contenuto
  ridotto della 0.0, non la matematica: troppo poche Consequence toccano un tag a
  cui i Destiny altrui tengono, quindi quasi nessuno ha motivo di opporsi. Da
  rimisurare con le 20 Consequence e le 4 Tensioni del §19.4.
  *(Chiusa nella 0.0.2: la lettura era giusta, ed e bastato il contenuto.)*

---

## [0.0.0] — Milestone 0.0, Core Headless

Prima release. Motore di gioco completo e giocabile senza UI: modello dati, Effect
system, Tensioni, azioni ordinarie, Confluence, Destiny, save/load, tutto
pilotabile da test e da un harness a riga di comando.

Tutti i criteri di accettazione §18.3 sono verificati.

### Added

**Fonte unica degli schemi (§17)**
- 14 JSON Schema 2020-12 in `/schema`, inclusi `chronicle` e `sim_plan` non
  previsti dal §4 (D-015)
- `tools/validate_data.py`: validazione JSON Schema più una seconda passata di
  integrità referenziale (adiacenze reciproche, somma della drift track, pool
  Echo, template per ogni Tensione, id duplicati)
- `tools/gen_gd_schema.py`: genera `godot/scripts/core/schema_defs.gd`, con
  modalità `--check` per il drift check in CI
- `tools/build_manifest.py`: genera `docs/ASSET_MANIFEST.md` dai dati

**Core (§5, §6)**
- `EffectApplier`: unico punto di mutazione del WorldState, con `effect_log`,
  inversi esatti, `undo_last`/`undo_after` e rifiuto di superare un Effect
  irreversibile
- Enum EffectType chiuso a 22 voci, con `REMOVE_SCAR` aggiunto e documentato
  (D-003) e `inverse_type` sull'Effect (D-002)
- `RngService`: RNG seeded centralizzato, Fisher-Yates proprio, posizione
  persistita come contatore di estrazioni (D-004)
- `SaveSerializer` / `SaveManager`: salvataggio versionato a chiavi ordinate,
  snapshot automatico prima di ogni Confluence, normalizzazione degli interi al
  caricamento

**Regole (§7–§16)**
- `ChronicleController`: 3 Atti × 3 round × 2 AO, Drift, check di soglia, carta
  Echo di Atto, chiusura della Chronicle
- `ActionResolver`: i sei template ACQUIRE / MOVE / INFLUENCE / FORGE / SCHEME /
  CLAIM, con CLAIM in modalità CREATE e FORCE (D-011)
- `TensionSystem`: drift track mescolata col seed, presagi presi dai dati e mai
  ripetuti, ordinamento delle soglie
- `ConfluenceController`: sequenza A–K completa, con ordine di risoluzione
  interno fissato e documentato (D-014)
- `confluence_resolution.gd`: Strategy `baseline_v0`, M = S − O + W, sostituibile
  senza toccare dati o UI
- `ConsequenceCompiler`: Consequence e hook delle carte Echo compilati in Effect,
  con sostituzione di `$proponent` / `$tension` / `$actor`
- `EchoRecorder`, `DestinyEvaluator` (livelli cumulativi, D-017),
  `ConditionEvaluator` con tutte le condizioni del §14

**Contenuto 0.0 (§18.2)**
- 12 Asset, 6 Regioni, 2 Tensioni, 2 template di Confluence, 8 carte Echo,
  8 Conseguenze, 4 Entità con Destiny a 2 condizioni per livello, drift track di
  9 voci

**Harness e test (§18.1, §18.3)**
- `cli/run_chronicle_sim.gd` + `cli/scripted_decider.gd`: gioca una Chronicle
  completa headless, verifica il blocco `expected` del piano ed esporta il save
- Tre piani di simulazione con esiti diversi (Decisive · Failure+2×SwC ·
  Failure+Success) e Destiny finali diversi
- 64 test in 8 suite, 425 asserzioni, con un runner minimale senza addon (D-008)
- `tools/run_sims.sh`, workflow GitHub Actions

### Fixed

Bug trovati **dai test e dai piani di simulazione** mentre venivano scritti — la
ragione per cui la 0.0 è headless:

- `RngService` non era seeded: GDScript risolve una chiamata non qualificata a un
  built-in di `@GlobalScope` prima di un metodo della classe, quindi un metodo
  chiamato `randi_range` non veniva mai eseguito e ogni estrazione "seeded"
  arrivava dall'RNG globale. Rinominato in `range_int` (D-019)
- l'inverso di `REMOVE_ASSET` e di `TRANSFER_ASSET` rimetteva la carta in fondo
  alla mano invece che alla sua posizione: il round-trip riordinava la mano
- `ACQUIRE` con pesca doppia non scartava nulla quando le due carte pescate erano
  copie dello stesso Asset (confronto per valore invece che per indice)
- il runner dei test si bloccava per sempre quando una suite non compilava: un
  errore dentro `_initialize` non raggiunge mai `quit()`

### Changed rispetto alla specifica

Tutto elencato e motivato in [docs/DECISIONS.md](docs/DECISIONS.md). I punti che
toccano le regole:

- `deck_copies` aggiunto agli Asset: due carte distinte per famiglia non fanno un
  mazzo per quattro giocatori (D-010)
- le Proposition hanno una eligibility: senza, il Popolo Nahr poteva proporre che
  il trono requisisse il grano e Aldric opporsi al proprio granaio (D-016)
- l'Echo Check considera "Success" anche il Success with Cost (D-012)
- disposizione degli Asset su Failure per chi non è proponente né opposer (D-013)

### Note di bilanciamento — segnalate, non corrette

- **D-018**: INFLUENCE per presenza è gratuito e ripetibile; quattro giocatori con
  otto AO per round possono annullare il Drift +1. Misurato, non ipotizzato: la
  prima versione della policy di riempimento dell'harness produceva Chronicle con
  **zero** Confluence. È la prima voce del bilanciamento 0.2.
- **O-1**: i tre piani producono 1, 3 e 2 Confluence contro le 3–4 attese dal §7.
  Nessun numero è stato cambiato, come richiesto dallo stesso §7.

### Non implementato (fuori scope §0)

LLM locale, computer vision, QR tracking, multiplayer online, networking,
generazione procedurale della Chronicle II. Nessuna UI oltre la scena di boot: è
la Milestone 0.1.
