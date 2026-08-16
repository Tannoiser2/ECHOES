# ECHOES — Piano di test

Tutto gira headless, senza editor e senza addon.

```bash
godot --headless --path godot --script res://tests/run_tests.gd
godot --headless --path godot --script res://tests/run_tests.gd -- --filter=effect
python3 tools/validate_data.py
python3 tools/gen_gd_schema.py --check
GODOT=/path/to/godot tools/run_sims.sh
```

Stato 0.1.54: **215 test in 29 suite, 4513 asserzioni, tutto verde**, più i 3
piani di simulazione che passano le proprie asserzioni e l'export di stampa che
esce identico a ogni rigenerazione.

La sonda di bilanciamento gioca N Chronicle con giocatori che perseguono davvero
il proprio Destiny e riporta la distribuzione dei risultati:

```bash
godot --headless --path godot --script res://cli/run_balance_probe.gd -- --runs=40
# quanto puo muoversi il mondo, e quanto si muove in dieci Chronicle di fila:
godot --headless --path godot --script res://cli/run_world_probe.gd -- --runs=40 --campaign=10
# la stessa cosa sulla Chronicle assemblata dalla biblioteca:
godot --headless --path godot --script res://cli/run_world_probe.gd -- --campaign=10 --chronicle=CHR_02
# ogni frase distinta che il motore ha davvero prodotto, slot riempiti:
godot --headless --path godot --script res://cli/run_text_probe.gd -- --runs=40
# le crisi scoppiano sempre? un tavolo che fa solo soppressione contro uno normale:
godot --headless --path godot --script res://cli/run_crisis_probe.gd -- --runs=40
# lo strato di Propp: archi drammatici e funzioni senza antecedente:
godot --headless --path godot --script res://cli/run_echo_probe.gd -- --runs=40
# cosa il tavolo poteva dire e cosa ha detto, e perche' una proposta non arriva mai ai voti:
godot --headless --path godot --script res://cli/run_choice_probe.gd -- --chronicle=CHR_03 --tavolo=misto
# perche nessuno si oppone: il punteggio di una proposta seggio per seggio,
# e quali Effect non spostano mai un punteggio (D-066):
godot --headless --path godot --script res://cli/run_stance_probe.gd -- --runs=40 --chronicle=CHR_03
# sweep di un knob senza toccare i dati:
godot --headless --path godot --script res://cli/run_balance_probe.gd -- \
    --runs=40 --influence-cap=1 --tension-cap=1 --presence-directions=UP
godot --headless --path godot --script res://cli/run_playtest.gd -- --runs=100 --oppose-recovery=1
```

---

## Cosa copre cosa

### Criteri di accettazione §18.3

| criterio | dove |
|---|---|
| Progetto apribile senza errori, boot validation passa | `smoke/test_data_boot.gd` |
| `validate_data.py` passa | CI + locale |
| I 3 script di partita girano fino in fondo senza errori | `smoke/test_chronicle_run.gd::test_every_plan_runs_to_the_end` |
| …con esiti finali diversi fra loro | `…::test_plans_meet_their_expectations_and_differ` |
| Stesso seed + stesso script ⇒ save byte-identico | `…::test_same_seed_and_plan_give_an_identical_save` |
| Tabella del resolver, tutti e 4 gli esiti | `unit/test_confluence_resolution.gd` |
| apply/undo round-trip per ogni EffectType reversibile | `unit/test_effect_applier.gd` |
| Snapshot restore oltre un `CREATE_ECHO` | `unit/test_snapshot_and_save.gd` |
| Valutazione Destiny sui 3 livelli | `unit/test_destiny_evaluator.gd` |
| save/load round-trip con uguaglianza profonda | `unit/test_snapshot_and_save.gd` |
| Drift deterministico | `unit/test_tension_drift.gd` |
| Almeno un Echo e un Truth generati automaticamente | `…::test_at_least_one_plan_writes_history` |

### Le suite

| suite | test | cosa verifica |
|---|---|---|
| `unit/test_confluence_resolution.gd` | 8 | M = S + C − O + W, le quattro bande e i loro confini, la tabella 1d6 del World Factor, il valore di un Asset con e senza rilevanza, i tre `confluence_modifier`, il fatto che una Condition qualificata entri nel margine dalla parte del Support mentre una non qualificata non sposti niente (D-055), e che chi si astiene non contribuisca |
| `unit/test_effect_applier.gd` | 6 | round-trip per tutti e 20 i tipi reversibili (con una guardia che fallisce se un tipo dell'enum generato non ha un test), il clamp a zero che resta invertibile, il no-op su un tag già presente, l'irreversibilità di Echo e Truth, il rifiuto di un tipo fuori enum, la progressività degli id |
| `unit/test_action_resolver.gd` | 22 | i sei template: pesca doppia con e senza fonte, limite di mano, adiacenza e spostamento, INFLUENCE per presenza e per scarto, il rifiuto su Tensione velata, FORGE in su e in giù, i tre modi di SCHEME, CLAIM create + force con tutte le precondizioni, e che un'azione rifiutata non cambi nulla |
| `unit/test_tension_drift.gd` | 8 | la traccia di Drift deterministica per seed e diversa fra seed, la distribuzione dichiarata, il consumo in ordine, il Drift come Effect di sistema, i presagi che scattano una volta sola e col testo dei dati, la velatura nel log pubblico e l'ordinamento delle soglie |
| `unit/test_destiny_evaluator.gd` | 5 | la scala completa Minimum → Victory → Triumph, la cumulatività (perdere il Minimum azzera il livello), il conteggio delle Scoperte, un risultato per ogni posto, e l'evidenza che registra condizioni ed Echo |
| `unit/test_snapshot_and_save.gd` | 5 | lo snapshot che riporta indietro oltre un Echo, l'undo che si ferma esattamente sull'irreversibile, il round-trip save/load, la stabilità byte-per-byte del testo, la posizione dell'RNG che sopravvive al salvataggio |
| `smoke/test_data_boot.gd` | 8 | il caricamento e la validazione dei dati, il contenuto (§18.2 piu le deviazioni dichiarate D-022/D-024), un Asset da 1 e uno da 2 per famiglia, i numeri di baseline della Chronicle, la raggiungibilità di ogni soglia, la scena di boot, la copertura dello schema generato, e che ogni hook di carta Echo compili in almeno un Effect |
| `smoke/test_balance.gd` | 8 | il numero di Confluence su 24 partite giocate dal policy decider resta nella banda del §7 giudicata sull'aggregato (mediana 5-6 da D-077, al massimo il 10% delle partite fuori da 2-8, almeno 1 Echo ogni 2 Chronicle), i Destiny restano contesi, i due cap su INFLUENCE reggono per una Chronicle intera ricostruita dall'effect_log, la sonda e deterministica e la policy non propone mai un'azione illegale; piu D-029: spingere giu una Tensione ne alza una collegata, lo spostamento non consuma una seconda INFLUENCE ed e distinguibile nel log, e spingere in su non sposta niente |
| `unit/test_echo_grammar.gd` | 6 | pescare una carta registra la funzione narrativa svolta, una carta che presuppone qualcosa non e giocabile finche quel qualcosa non e successo, ogni famiglia drammatica mantiene almeno una carta sempre giocabile, il pool dell'Atto e un sacchetto pesato che da archi diversi su seed diversi tenendo l'Atto 1 in tensione, ogni funzione dichiarata nello schema ha una carta con sei carte per famiglia, e `any_of` vale quando almeno un ramo vale |
| `unit/test_art_library.gd` | 5 | la chiave diventa il percorso del file, un'immagine che c'e' si legge davvero (un PNG di prova da 4x4 in `tests/fixtures/`), **un'immagine che manca non e' un errore** - niente immagine, niente texture, niente da incorporare - il `data:` URI e' stabile e sta dentro un attributo XML, e il foglio di stampa senza illustrazioni disegna quello che disegnava prima |
| `unit/test_icon_set.gd` | 7 | ogni famiglia e ogni livello di tag presenti nei dati hanno il proprio glifo, nessun tratto esce dal quadrato (meta' spessore per le spezzate, il raggio per i punti), nessun glifo e' la copia di un altro ne' ci si sovrappone, l'SVG di un glifo porta un colore solo - il vincolo del monocromatico della ART_BIBLE - la carta Asset porta la propria famiglia fino in stampa, e la prova a occhio contiene tutti e dodici i segni |
| `unit/test_region_art.gd` | 6 | ogni tratto del terreno resta dentro la tessera, ogni bioma dei dati ha la propria tavolozza e il proprio disegno, la stessa Regione esce identica a ogni chiamata mentre due Regioni dello stesso bioma differiscono, un bioma sconosciuto disegna comunque qualcosa, la tessera stampata porta il proprio bioma (e nessun altro mazzo lo fa) e l'SVG della tessera e' ben formato |
| `unit/test_print_export.gd` | 10 | ogni faccia stampabile del set ci sta nella propria carta (nessun `overflow`, corpo mai sotto il 74%), nessuna faccia vuota, la carta Casata non stampa mai il proprio Destino e ogni carta Destino e' marcata segreta, il mazzo espanso per `deck_copies` (48 facce Asset = 132 carte su 15 fogli), il segnaposto d'arte deterministico e diverso per chiave, l'SVG che protegge i caratteri XML e resta in millimetri, il brief che legge i MASTER PROMPT dalla ART_BIBLE, e il fatto che **nessuna chiave in uso resti senza MASTER PROMPT** (D-065), col ritratto di Casata che prende l'accento del proprio archetipo e non quello della famiglia di Asset che si chiama allo stesso modo |
| `unit/test_library_content.gd` | 8 | una Tensione senza Consiglio proprio prende quello del suo dominio, ogni Tensione della biblioteca ne trova uno, il sorteggio delle Tensioni e deterministico per seed e varia fra seed, una Chronicle scritta a mano resta invariata, un Effect su una Tensione non in gioco e un no-op mentre un id inesistente resta un errore, la pesca ascolta i segni dell'era prima - stessa mano a parita di seme e mondo, il segno pesa, la leggenda richiama quanto il fatto (D-079) - la ripesca rida anche il sacchetto del Drift, e una Chronicle assemblata gioca fino in fondo |
| `unit/test_narrative_text.gd` | 6 | la Regione a fuoco segue il tag condition e resta nel dominio, la stessa frase autorata nomina un posto diverso in due mondi diversi, le forme italiane (articolo, locativo, genitivo) e la maiuscola di uno slot in testa, l'ordine di sostituzione per lunghezza, e che nessuno slot irrisolto finisca nel registro Truth |
| `unit/test_questions_asked.gd` | 7 | il default della prima Confluence non cambia (la domanda piu affilata), una domanda gia messa ai voti esce dal tavolo finche ne resta una nuova - e le proposte che seguono sono le sue - un Consiglio che ha esaurito le domande non si apre (D-077), una proposta bocciata lascia la domanda sul tavolo, la memoria e della Tensione e non del tavolo, una Confluence aperta e non risolta non consuma niente, e ogni Chronicle comincia senza niente di chiesto (D-061) |
| `unit/test_log_export.gd` | 6 | il nome del file sopravvive a un filesystem e porta il seme, una sessione senza Chronicle ha comunque un nome, l'intestazione porta il seme e non inventa quello che non sa, fuori dal browser il file si scrive e chi ha premuto sa dove, e un log vuoto non scarica niente (D-062) |
| `unit/test_stance_scoring.gd` | 5 | quello che un seggio riesce a vedere di una proposta (D-066): un rapporto che rompe una clausola costa e uno che la ripara vale, un rapporto fra altri due non e affar mio, senza una clausola che nomini qualcuno il ramo nuovo non inventa opinioni, una clausola `min` legge anche una spinta che non le passa sotto la soglia, e la stessa spinta si legge in due versi opposti a due seggi diversi |
| `unit/test_chronicle_book.gd` | 5 | ogni Verita scritta finisce sulla pagina della cronaca, le pagine sono A4 veri e numerati, ottanta Verita si spezzano in piu pagine invece di uscire dal foglio, un anno muto lo dice, e ogni pagina si rasterizza per la vista in-app (D-086) |
| `smoke/test_library_balance.gd` | 1 | l'anno-biblioteca ereditato da quello scritto decide qualcosa: Consigli dentro i limiti duri del §7 e mediana nella banda dichiarata alla nascita, per la coppia della corona e quella delle citta (D-080) |
| `smoke/test_chronicle_run.gd` | 6 | i tre piani giocati per intero, le loro asserzioni `expected`, il fatto che finiscano diversamente, Echo e Truth automatici, il determinismo per seed, e che il log pubblico non riveli mai il valore velato |

---

## Piani di simulazione

Ogni piano porta un blocco `expected` che l'harness verifica a fine corsa: sono
test di regressione, non solo tre log.

Sono **fixture, non partite rappresentative**: i turni non scriptati li riempie
una routine passiva (che di proposito non steer le Tensioni, vedi D-021), quindi
circa meta dei turni di un piano risultano "passa". Per una partita giocata da
avversari veri si usa `--policy`, che sostituisce le scelte del piano con il
policy decider e non lascia nessun turno vuoto.

| piano | Confluence | esiti | cosa esercita |
|---|---|---|---|
| `plan_a_grain_accord` | 1 | Decisive Success | trigger da soglia, conquista del seggio di proponente con la presenza, Condition qualificata, Echo, Aldric a Triumph |
| `plan_b_broken_council` | 3 | Failure ×2, Success with Cost | FORGE verso il basso, MOVE che decide chi e il proponente, un fronte Oppose a 6 che genera l'Echo da sconfitta, recupero degli Asset su Failure, una Condition con clausola, una Failure decisa dal Fattore Mondo |
| `plan_c_opened_mine` | 2 | Failure, Success | CLAIM/CREATE + CLAIM/FORCE (trigger c del §12.1), SCHEME che apre una Tensione velata, una Confluence forzata che poi cade |

Verifica manuale del determinismo:

```bash
OUT=/tmp/run1 tools/run_sims.sh && OUT=/tmp/run2 tools/run_sims.sh
cmp /tmp/run1/plan_a_grain_accord.save.json /tmp/run2/plan_a_grain_accord.save.json
```

---

## Cosa non è coperto

- **Nessuna scena oltre quella di boot.** Non esiste UI in 0.0; gli smoke test
  sulle scene arrivano con la 0.1 (§19.6).
- **Nessun test di performance.** Una Chronicle completa applica ~130 Effect: non
  c'è niente da misurare ancora. Per riferimento, 8 Chronicle complete girano in
  circa 0,6 secondi.
- **Failure e Success with Cost non compaiono** nelle partite del policy decider
  (0 e 1 su 154 Confluence misurate). E' una lacuna di contenuto, non di
  matematica: vedi [O-4](DECISIONS.md).
- **`promise_kept` / `promise_broken`** sono implementati e usati dal
  `ConditionEvaluator`, ma nessun Destiny di 0.0 li richiede, quindi non hanno un
  test dedicato. Arriveranno con i Destiny completi della 0.1.
- **Godot headless in CI** è attivo (il workflow scarica 4.7.1). Se in futuro
  diventasse indisponibile, la validazione dei dati e il drift check restano il
  minimo garantito richiesto dal §23.
