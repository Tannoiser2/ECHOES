# ECHOES

Boardgame/GDR narrativo-strategico a Chronicle. Ogni Chronicle è una storia
completa nello stesso mondo persistente: i giocatori controllano Entità di scala
diversa — un sovrano, un popolo, una creatura antica, un individuo — preparano la
propria posizione mentre le Tensioni del mondo salgono, e si scontrano nelle
**Confluence**, gli eventi storici in cui il tavolo decide cosa succede davvero.

**Stato: Milestone 0.1 — Vertical Slice Hotseat, completata (0.1.18).** Si gioca
una Chronicle intera dal browser o dal terminale, su due saghe, con salvataggio e
ripresa; una partita headless gira in meno di un secondo; e i pezzi si stampano
dagli stessi dati. Prossima: la 0.2, bilanciamento — cosa resta è scritto in
[ISSUES.md](docs/ISSUES.md).

- [Game Design](docs/GAME_DESIGN.md) — perché il gioco è fatto così
- [Regole v0.2](docs/RULES_V0_2.md) — cosa fa il codice, numeri compresi
- [Componenti](docs/COMPONENTS.md) — cosa si stampa e cosa sta sullo schermo
- [Modello dati](docs/DATA_SCHEMA.md) · [Decisioni](docs/DECISIONS.md) ·
  [Piano di test](docs/TEST_PLAN.md) · [Roadmap](docs/ROADMAP.md) ·
  [Da fare](docs/ISSUES.md) · [Changelog](CHANGELOG.md) ·
  [Art Bible](docs/ART_BIBLE.md) · [Asset Manifest](docs/ASSET_MANIFEST.md)

---

## Come funziona il gioco

[docs/MECCANICA.md](docs/MECCANICA.md) — la meccanica per intero in un foglio
solo: il tempo, la mappa, le casate, le Tensioni, le sette azioni, il Consiglio
passo per passo con la matematica, le carte, i Destini e cosa attraversa gli
anni. È il posto da cui partire se non hai mai visto ECHOES.

## Requisiti

- **Godot 4.7.1 stable** — per giocare da terminale basta il build headless
- **Python 3.10+** con `jsonschema>=4.18` per gli strumenti di validazione

```bash
pip install 'jsonschema>=4.18'
```

Nessun backend, nessuna API key, nessun servizio esterno. Tutto offline.

---

## Aprire il progetto

La cartella `godot/` è il progetto Godot: aprila direttamente dall'editor, oppure

```bash
godot --path godot                    # apre il gioco (ui/main.tscn)
godot --headless --path godot --script res://tests/run_tests.gd   # i test
```

La scena principale e `ui/main.tscn`: la stessa che gira nel browser, perche e
la stessa partita. `scenes/boot/` resta come validazione dati per gli smoke test
e non e piu la scena di avvio.

---

## Giocare nel browser

Il progetto esporta come applicazione web ed e pubblicato su GitHub Pages dal
workflow `.github/workflows/pages.yml` a ogni push su `main`. Non c'e niente da
installare: si apre una pagina.

La pagina si apre su **«Come si gioca»**: cosa fa un'azione, quali sono le
domande dell'anno con le loro soglie, cosa succede in un Consiglio e come si
vince. Si toglie di mezzo appena scegli un seggio e torna con il bottone in
fondo alla colonna. Sopra le scelte c'è sempre una riga che dice cosa sta per
succedere — «La Carestia è a un passo dalla soglia».

Si sceglie **il seggio, l'anno e il mondo**: `CHR_01` è la Carestia Rossa con le
sue quattro domande scritte a mano, `CHR_02` ne pesca quattro dalla biblioteca e
non è mai due volte la stessa storia; il seme può essere casuale, riscritto a
mano, o quello della partita appena finita.

Poi si gioca sul tabellone: le **Regioni cerchiate d'oro**
sono quelle dove puoi mettere una presenza, e ci si va premendole. Le altre azioni
stanno nella colonna a destra, insieme alle domande dell'anno e al tuo Destino.
Quando si apre un **Consiglio** la mappa lascia il centro alla plancia: la
domanda, la proposta, chi dice cosa, cosa ognuno ha impegnato, e **le Conseguenze
che la proposta scriverebbe sul mondo** — comprese quelle che lasciano una
Cicatrice. Alla fine il tiro e il conto restano su schermo finche non premi
Avanti.

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

## Perché non si supera il Minimo

```bash
godot --headless --path godot --script res://cli/run_rung_probe.gd -- \
    --runs=60 --seed=7000
```

Sessanta Chronicle a tavolo misto, e per ogni Destino **quale clausola** resta
in sospeso e quanto spesso. Non «la Vittoria è difficile» — quella non è una
diagnosi — ma «questa condizione non si avvera mai, e nel 77% dei casi è
perché dipende da una promessa che nessun bot fa».

Stampa anche il tabellone a fine anno, che è dove si legge una clausola scritta
«almeno due Regioni»: il **30%** dei seggi finisce senza nessuna Regione, il
**12%** ne tiene due, e il **44% delle caselle non è di nessuno**. In un anno
intero una casa guadagna in media un quarto di Regione — e la sonda conta anche
perché: `ACT_CLAIM` («Rivendicare») non prende una Regione, apre una domanda e
poi strappa un Consiglio, e su 60 partite le rivendicazioni aperte sono 63 ma
quelle **portate fino in fondo 15** ([ISSUES 37](docs/ISSUES.md)).

## I bot contro il caso

```bash
godot --headless --path godot --script res://cli/run_bot_probe.gd -- \
    --runs=40 --seed=7000
```

Lo stesso mondo giocato due volte — una col seggio studiato alla policy, una
allo stesso seggio che tira a sorte fra le mosse legali — e il confronto sul
**Destino raggiunto**. Un avversario che non batte il sorteggio non è un
avversario: questo lo batte in 26 partite su 40, e il caso manca il Destino
minimo in 20 partite mentre la policy non lo manca mai.

## La stanza senza schermo (console sui telefoni)

```bash
godot --headless --path godot --script res://cli/run_room.gd -- \
    --seed=7000 --chronicle=CHR_01 --port=8137 --pages=8123
```

Apre la stanza della voce 27 senza la scena Godot che la avvolge: stampa un
indirizzo per seggio, serve le pagine e aspetta i telefoni. Chi apre il proprio
indirizzo gioca quel seggio; gli altri sono policy. Serve per provare la console
da un altro apparecchio senza aprire una finestra — e per fotografare quello che
si vede sul telefono con un browser vero al posto di un mockup.

`--seats=<n>` quanti seggi aspettano un telefono (2 di default) · `--port` il
filo · `--pages` le pagine. La stanza con l'interfaccia sta nel menu dell'app:
«Apro la stanza — console sui telefoni».

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

## Stampare le carte

Le stesse righe JSON che muovono la partita producono i pezzi fisici: il gioco è
un boardgame con un'app, non uno dei due.

```bash
GODOT=/path/to/godot tools/run_export.sh            # il mazzo intero, in out/export
GODOT=/path/to/godot tools/run_export.sh --proof    # una copia per faccia, per correggere
```

Escono **25 fogli A4 in SVG, in scala 1:1** con i segni di taglio — carte 63×88
mm tre per tre, tessere Regione 80×80 due per tre, il mazzo espanso per
`deck_copies` (48 facce Asset = 132 carte) — più il brief d'arte, cioè ogni
`art_prompt_key` in uso col MASTER PROMPT della ART_BIBLE già composto. Il brief
è anche committato in [`docs/BRIEF_ARTE.md`](docs/BRIEF_ARTE.md), così si legge
senza generare niente; la CI controlla che sia allineato.

L'arte è segnaposto finché non arriva quella vera: ogni immagine generata mostra
in chiaro la propria chiave e lascia libero il terzo basso, dove andrà il testo.
Dentro l'app, **F4** apre l'anteprima di stampa (e **F3** il cruscotto per chi
sviluppa).

Per consegnare un'illustrazione si copia il PNG in `godot/art/`, con il nome
della sua chiave: `asset.force.levy` → `art/asset/force/levy.png`. Se il file
c'è si disegna quello, se non c'è il segnaposto — nel gioco, nell'anteprima e in
stampa. I dettagli in [`godot/art/README.md`](godot/art/README.md).

---

## Test e validazione

```bash
# 144 test unit + smoke, headless
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

Vale anche per i fogli di stampa, che sono testo e quindi si confrontano riga
per riga:

```bash
OUT=/tmp/exp1 tools/run_export.sh && OUT=/tmp/exp2 tools/run_export.sh
diff -r /tmp/exp1 /tmp/exp2
```

---

## Struttura

```
schema/          JSON Schema 2020-12 — la fonte unica del modello dati
tools/           validate_data.py, gen_gd_schema.py, build_manifest.py, run_sims.sh, run_export.sh
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
oggetto `decider`: lo `ScriptedDecider` dei piani, il `PolicyDecider` delle
sonde, i quattro caratteri del playtest, la UI del browser. Sono lo stesso
motore con l'altro capo del tubo diverso, e le regole non cambiano di una riga.

---

## Licenza

Codice: MIT. Contenuto di gioco e documentazione: CC BY-NC-SA 4.0.
Vedi [LICENSE.md](LICENSE.md).
