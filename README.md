# ECHOES

Boardgame/GDR narrativo-strategico a Chronicle. Ogni Chronicle è una storia
completa nello stesso mondo persistente: i giocatori controllano Entità di scala
diversa — un sovrano, un popolo, una creatura antica, un individuo — preparano la
propria posizione mentre le Tensioni del mondo salgono, e si scontrano nelle
**Confluence**, gli eventi storici in cui il tavolo decide cosa succede davvero.

**Stato: Milestone 0.0 — Core Headless, completata, più un passo di
bilanciamento (0.0.1).** Il motore è completo e giocabile senza UI: una Chronicle
intera gira da riga di comando in meno di un secondo. La 0.1 (vertical slice
hotseat) non è iniziata.

- [Game Design](docs/GAME_DESIGN.md) — perché il gioco è fatto così
- [Regole v0.2](docs/RULES_V0_2.md) — cosa fa il codice, numeri compresi
- [Modello dati](docs/DATA_SCHEMA.md) · [Decisioni](docs/DECISIONS.md) ·
  [Piano di test](docs/TEST_PLAN.md) · [Roadmap](docs/ROADMAP.md) ·
  [Art Bible](docs/ART_BIBLE.md) · [Asset Manifest](docs/ASSET_MANIFEST.md)

---

## Requisiti

- **Godot 4.7.1 stable** — per la 0.0 basta il build headless
- **Python 3.10+** con `jsonschema>=4.18` per gli strumenti di validazione

```bash
pip install 'jsonschema>=4.18'
```

Nessun backend, nessuna API key, nessun servizio esterno. Tutto offline.

---

## Aprire il progetto

La cartella `godot/` è il progetto Godot: aprila direttamente dall'editor, oppure

```bash
godot --path godot                    # esegue la scena di boot (validazione dati)
godot --headless --path godot         # stessa cosa, senza finestra
```

In 0.0 la scena di boot esiste solo per validare i dati e dare qualcosa da
caricare agli smoke test. Non c'è UI di gioco: è previsto.

---

## Giocare nel browser

Il progetto esporta come applicazione web ed e pubblicato su GitHub Pages dal
workflow `.github/workflows/pages.yml` a ogni push su `main`. Non c'e niente da
installare: si apre una pagina.

L'export e **single-thread** di proposito. La build Web con i thread richiede
`SharedArrayBuffer`, che richiede gli header `COOP`/`COEP`, che GitHub Pages non
puo mandare. Un gioco a turni che aspetta un click non ha niente da guadagnare
dai thread e tutto da perdere dal non caricare.

Per costruirlo in locale servono Godot 4.7.1 e i suoi export template:

```bash
godot --headless --path godot --import
godot --headless --path godot --export-release "Web" ../build/web/index.html
python3 -m http.server -d build/web 8099     # e poi apri localhost:8099
```

## Sedersi al tavolo

```bash
tools/play.sh                      # un seggio (i Nahr) contro tre policy
tools/play.sh --seats=all          # tutti e quattro alla tastiera
tools/play.sh --seats=ENT_ALDRIC   # scegli il tuo
```

Lo script trova Godot da solo (`$GODOT`, poi il PATH, poi un binario lasciato
accanto al progetto). Sotto sta solo questo:

```bash
godot --headless --path godot --script res://cli/run_hotseat.gd -- \
    --seats=ENT_NAHR --seed=812
```

Gioca davvero: il tabellone si stampa dal punto di vista del tuo seggio — le
domande dell'anno con i numeri che *tu* puoi vedere, la mappa, la tua mano, il
tuo Destino con le caselle gia spuntate — e ti offre un menu delle sole azioni
che le regole accettano. In Consiglio scegli la domanda, la proposta, la tua
posizione e cosa impegni.

`--seats=all` mette tutti e quattro i seggi alla tastiera; qualsiasi seggio non
elencato lo gioca la policy. **Invio a vuoto su qualsiasi scelta la lascia
decidere alla policy**, quindi si puo giocare un seggio solo, o mollarne uno a
meta partita, o pipare un file di risposte e lasciare che finisca da sola.

Opzioni: `--seed=<n>` stesso seme stesso mondo · `--chronicle=CHR_02` la
Chronicle di libreria · `--quiet` toglie la traccia delle regole round per round
e lascia solo i Consigli, le carte Echo e il finale.

## Giocare una Chronicle da riga di comando

```bash
godot --headless --path godot --script res://cli/run_chronicle_sim.gd -- \
    --plan=res://data/chronicle_01/sim_plans/plan_a_grain_accord.json
```

Stampa il log pubblico dell'intera partita — azioni, Drift, presagi, la sequenza
A–K di ogni Confluence con la matematica in chiaro, i Destiny finali e il registro
delle Verità.

Opzioni: `--out=<file>` salva il save finale · `--log=<file>` salva il log ·
`--seed=<int>` sovrascrive il seed del piano · `--quiet` non stampa il log ·
`--lenient` non fallisce sulle scelte scriptate illegali · `--help`.

**Attenzione a cosa stai guardando.** I tre piani qui sotto sono *fixture di
regressione*: verificano che una sequenza di mosse decisa a mano produca sempre
lo stesso esito. I turni che il piano non copre li riempie una routine passiva
che di proposito non tocca le Tensioni, quindi in un piano scriptato quasi meta
dei turni sono "passa". Non e il gioco: e il manichino.

Per vedere una partita vera, con quattro giocatori che perseguono davvero il
proprio Destiny:

```bash
godot --headless --path godot --script res://cli/run_chronicle_sim.gd -- \
    --plan=res://data/chronicle_01/sim_plans/plan_a_grain_accord.json --policy
```

Il piano fornisce solo la Chronicle e il seed; ogni scelta la prendono i
giocatori. Nessun "passa", e 3-4 Confluence per partita.

Tutti e tre i piani in un colpo solo:

```bash
GODOT=/path/to/godot tools/run_sims.sh     # scrive log e save in out/
```

| piano | esiti | cosa mostra |
|---|---|---|
| `plan_a_grain_accord` | Decisive Success | il trono conquista il seggio di proponente e requisisce il grano senza opposizione |
| `plan_b_broken_council` | Failure ×2, Success with Cost | i Nahr chiedono la terra e il tavolo intero dice no: una sconfitta memorabile diventa comunque storia. Chiedono ancora, e cadono di misura sul Fattore Mondo. Alla terza il consiglio cede a caro prezzo |
| `plan_c_opened_mine` | Failure, Success | un Claim forza una Confluence fuori soglia sulle Miniere, e Vaerax la fa cadere |

---

## Test e validazione

```bash
# 72 test unit + smoke, headless
godot --headless --path godot --script res://tests/run_tests.gd
godot --headless --path godot --script res://tests/run_tests.gd -- --filter=confluence

# dati contro /schema, più integrità referenziale
python3 tools/validate_data.py

# il GDScript generato è ancora allineato agli schemi?
python3 tools/gen_gd_schema.py --check
python3 tools/build_manifest.py --check
```

### Sonda di bilanciamento

I piani scriptati verificano che le regole facciano quello che l'autore ha
scritto. La sonda misura l'altra cosa: cosa succede quando quattro giocatori
perseguono davvero il proprio Destiny.

```bash
godot --headless --path godot --script res://cli/run_balance_probe.gd -- --runs=40
```

Riporta la distribuzione delle Confluence per Chronicle contro l'attesa del §7,
gli esiti, gli Echo e i livelli Destiny raggiunti. `--influence-cap=N` e
`--presence-directions=UP` provano una variante di regole senza toccare i dati.
La storia della misura è in [DECISIONS D-021](docs/DECISIONS.md).

### Determinismo

Criterio §18.3: stesso seed e stesso piano devono produrre un save byte-identico.

```bash
OUT=/tmp/run1 tools/run_sims.sh && OUT=/tmp/run2 tools/run_sims.sh
cmp /tmp/run1/plan_a_grain_accord.save.json /tmp/run2/plan_a_grain_accord.save.json
```

---

## Struttura

```
schema/          JSON Schema 2020-12 — la fonte unica del modello dati
tools/           validate_data.py, gen_gd_schema.py, build_manifest.py, run_sims.sh
godot/
  autoload/      EventBus, DataRegistry, GameState, SaveManager
  scripts/
    core/        Effect, EffectApplier, RngService, SaveSerializer, schema_defs (generato)
    world/       WorldStateFactory, WorldStateService, ConditionEvaluator
    chronicle/   GameSession, ChronicleController, TensionSystem, EchoRecorder, DestinyEvaluator
    confluence/  ConfluenceController, confluence_resolution (Strategy baseline_v0)
    actions/     ActionResolver — i sei template
  data/          contenuto della Chronicle I (ridotto §18.2)
    seat/        seat_decider.gd — cosa un seggio vede e puo fare
                 policy_decider.gd — l'avversario
  ui/            game_screen.gd, main.tscn — il tavolo nel browser
  cli/           run_hotseat.gd, terminal_io.gd — il tavolo nel terminale
                 run_chronicle_sim.gd, scripted_decider.gd
                 run_balance_probe.gd e le altre sonde
  tests/         unit/ e smoke/, con il runner
docs/            design, regole, decisioni, piano di test, art bible
```

Due principi tengono insieme l'architettura:

**Ogni mutazione del mondo è un Effect.** Nessun sistema scrive sul WorldState:
costruisce Effect e li passa a `EffectApplier`, che ne calcola l'inverso, li
applica e li registra. Da lì arrivano gratis l'undo del Developer Mode, la
riproducibilità e un log che spiega ogni singola cosa successa al tavolo.

**Il motore non decide niente.** `ChronicleController` chiede ogni scelta a un
oggetto `decider`. Oggi è lo `ScriptedDecider` della CLI; in 0.1 sarà la UI
hotseat. Le regole non cambiano di una riga.

---

## Licenza

Codice: MIT. Contenuto di gioco e documentazione: CC BY-NC-SA 4.0.
Vedi [LICENSE.md](LICENSE.md).
