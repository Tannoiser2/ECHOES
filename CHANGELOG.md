# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).
Il progetto segue le milestone della specifica esecutiva v0.2.

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
