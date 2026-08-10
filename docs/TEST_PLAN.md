# ECHOES — Piano di test

Tutto gira headless, senza editor e senza addon.

```bash
godot --headless --path godot --script res://tests/run_tests.gd
godot --headless --path godot --script res://tests/run_tests.gd -- --filter=effect
python3 tools/validate_data.py
python3 tools/gen_gd_schema.py --check
GODOT=/path/to/godot tools/run_sims.sh
```

Stato 0.0.3: **79 test in 10 suite, 542 asserzioni, tutto verde**, più i 3 piani di
simulazione che passano le proprie asserzioni.

La sonda di bilanciamento gioca N Chronicle con giocatori che perseguono davvero
il proprio Destiny e riporta la distribuzione dei risultati:

```bash
godot --headless --path godot --script res://cli/run_balance_probe.gd -- --runs=40
# quanto puo muoversi il mondo, e quanto si muove in dieci Chronicle di fila:
godot --headless --path godot --script res://cli/run_world_probe.gd -- --runs=40 --campaign=10
# ogni frase distinta che il motore ha davvero prodotto, slot riempiti:
godot --headless --path godot --script res://cli/run_text_probe.gd -- --runs=40
# sweep di un knob senza toccare i dati:
godot --headless --path godot --script res://cli/run_balance_probe.gd -- \
    --runs=40 --influence-cap=1 --tension-cap=1 --presence-directions=UP
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
| `unit/test_confluence_resolution.gd` | 8 | M = S − O + W, le quattro bande e i loro confini, la tabella 1d6 del World Factor, il valore di un Asset con e senza rilevanza, i tre `confluence_modifier`, il fatto che i Commit di una Condition stiano fuori da S e O e che chi si astiene non contribuisca |
| `unit/test_effect_applier.gd` | 6 | round-trip per tutti e 20 i tipi reversibili (con una guardia che fallisce se un tipo dell'enum generato non ha un test), il clamp a zero che resta invertibile, il no-op su un tag già presente, l'irreversibilità di Echo e Truth, il rifiuto di un tipo fuori enum, la progressività degli id |
| `unit/test_action_resolver.gd` | 22 | i sei template: pesca doppia con e senza fonte, limite di mano, adiacenza e spostamento, INFLUENCE per presenza e per scarto, il rifiuto su Tensione velata, FORGE in su e in giù, i tre modi di SCHEME, CLAIM create + force con tutte le precondizioni, e che un'azione rifiutata non cambi nulla |
| `unit/test_tension_drift.gd` | 8 | la traccia di Drift deterministica per seed e diversa fra seed, la distribuzione dichiarata, il consumo in ordine, il Drift come Effect di sistema, i presagi che scattano una volta sola e col testo dei dati, la velatura nel log pubblico e l'ordinamento delle soglie |
| `unit/test_destiny_evaluator.gd` | 5 | la scala completa Minimum → Victory → Triumph, la cumulatività (perdere il Minimum azzera il livello), il conteggio delle Scoperte, un risultato per ogni posto, e l'evidenza che registra condizioni ed Echo |
| `unit/test_snapshot_and_save.gd` | 5 | lo snapshot che riporta indietro oltre un Echo, l'undo che si ferma esattamente sull'irreversibile, il round-trip save/load, la stabilità byte-per-byte del testo, la posizione dell'RNG che sopravvive al salvataggio |
| `smoke/test_data_boot.gd` | 8 | il caricamento e la validazione dei dati, il contenuto (§18.2 piu le deviazioni dichiarate D-022/D-024), un Asset da 1 e uno da 2 per famiglia, i numeri di baseline della Chronicle, la raggiungibilità di ogni soglia, la scena di boot, la copertura dello schema generato, e che ogni hook di carta Echo compili in almeno un Effect |
| `smoke/test_balance.gd` | 5 | il numero di Confluence su 24 partite giocate dal policy decider resta nella banda del §7 giudicata sull'aggregato (mediana 3-4, al massimo il 10% delle partite fuori da 2-6, almeno 1 Echo ogni 2 Chronicle), i Destiny restano contesi, i due cap su INFLUENCE reggono per una Chronicle intera ricostruita dall'effect_log, la sonda e deterministica e la policy non propone mai un'azione illegale |
| `unit/test_narrative_text.gd` | 6 | la Regione a fuoco segue il tag condition e resta nel dominio, la stessa frase autorata nomina un posto diverso in due mondi diversi, le forme italiane (articolo, locativo, genitivo) e la maiuscola di uno slot in testa, l'ordine di sostituzione per lunghezza, e che nessuno slot irrisolto finisca nel registro Truth |
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
