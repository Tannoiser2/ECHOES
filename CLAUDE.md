# ECHOES — come si lavora qui

Boardgame narrativo-strategico. Godot 4.7.1 headless, GDScript tipato.
**Si parla italiano**, nei messaggi e nei verbali.

La direzione, decisa dal committente e valida da 0.1.218:

> **ECHOES è prima di tutto un gioco da tavolo, con un'app di supporto.**
> Non un gioco digitale con dei segnalini.
>
> Le Azioni cambiano il mondo. Il Consiglio decide cosa il mondo ricorderà.

Prima di cominciare qualsiasi cosa, leggi due documenti, in quest'ordine:

1. **[docs/PUNTO_ZERO.md](docs/PUNTO_ZERO.md)** — dov'è il gioco oggi, coi numeri
   misurati e le voci aperte;
2. **[docs/ROADMAP_PUNTO_ZERO.md](docs/ROADMAP_PUNTO_ZERO.md)** — dove sta andando,
   e le cinque cose su cui la direzione nuova corregge quella vecchia.

E la domanda da farsi a ogni modifica, che viene prima di ogni regola qui sotto:

> **Questa cosa esisterebbe e sarebbe comprensibile sul tavolo fisico?**

---

## Le quattro regole di casa

1. **Ogni modifica si misura su 100 semi prima di restare.** Il vincolo che non si
   negozia mai è **0 seggi bloccati su un solo livello su 8**, tavolo misto *e*
   uniforme:
   `godot --headless --path godot --script res://cli/run_playtest.gd -- --runs=100 --seed=7000`
2. **Quello che non è misurato va dichiarato.** *Un numero peggiorato e scritto vale
   più di un numero nascosto.* Se una modifica costa qualcosa, il costo si scrive.
3. **I verbali stanno in `docs/DECISIONS.md`, `docs/ISSUES.md` e `CHANGELOG.md`, nello
   stesso commit del codice.** Una decisione senza verbale non è stata presa.
4. **Dei comandi dei cancelli si guarda il codice di uscita, non l'output.**

---

## Il giro dei cancelli

Tutti vogliono `export GODOT=~/godot/Godot_v4.7.1-stable_linux.x86_64`.

| comando | cosa sorveglia |
|---|---|
| `python3 tools/validate_data.py` | i dati contro `/schema` |
| `python3 tools/validate_data.py --self-test` | che la guardia dei gettoni morda |
| `python3 tools/validate_physical.py --check` | **la grammatica fisica**: il dizionario dei segni (`godot/data/tags`) allineato ai dati — ambiti, mani, #cancelletti, muti con ragione — piu' carte senza Risonanza, Risonanze cieche, Temi senza Tensioni, tessere senza segni o che nessuno legge, Tensioni senza domande, ponti delle domande rotti, Destini che osservano l'inesistente, Echi senza effetto, bersagli non garantiti sul tavolo pescato |
| `python3 tools/validate_physical.py --self-test` | che la guardia del dizionario morda, su dodici difetti piantati |
| `python3 tools/gen_gd_schema.py --check` | `schema_defs.gd` allineato agli schemi |
| `python3 tools/build_manifest.py --check` | il manifesto degli asset |
| `python3 tools/build_sign_registry.py --check` | `docs/REGISTRO_SEGNI.md` |
| `python3 tools/dead_code.py` | codice che nessuno chiama |
| `bash tools/run_council_catalogue.sh --check` | `docs/CATALOGO_CONSIGLI.md` |
| `bash tools/run_card_catalogue.sh --check` | `docs/CATALOGO_CARTE.md` |
| `bash tools/run_export.sh --check-brief` | `docs/BRIEF_ARTE.md` |
| `$GODOT --headless --path godot --script res://tests/run_tests.gd` | la suite |

**Se tocchi uno schema, rigenera:** `python3 tools/gen_gd_schema.py`. Saltarlo fa
fallire il caricamento dei dati **in silenzio**, e i test vanno rossi altrove.

Le sonde stanno in `godot/cli/`. Le più usate: `run_playtest.gd` (il cancello),
`run_pass_probe.gd` (perché un seggio passa), `run_asking_probe.gd` (quanto rende
giocare), `run_resonance_probe.gd` (quante volte il mondo risponde).

---

## Le trappole che hanno morso davvero

- **GDScript non alza niente che si possa prendere.** Una chiave che manca o un
  metodo che non esiste **interrompono la funzione** senza errore. Una sonda che
  torna **zero** è quasi sempre cieca lei, non il gioco: in questo progetto è
  successo **quattro volte di fila**. Prima di credere a uno zero, provalo su un
  caso che *deve* dare non-zero.
- **Cambiare la firma di un metodo con un default rompe i suoi override** — e il
  file non compila, quindi la classe smette di esistere e la partita si blocca
  invece di fallire. Cerca sempre gli override.
- **Le lambda catturano per valore.** `_ready()` non gira per un nodo costruito
  fuori dall'albero.
- **Il `DataSet` condiviso di `test_case.gd` lo riscrivono altre prove.** Una prova
  che misura i **dati della scatola** deve costruirsi il suo.
- **Una prova che cerca una condizione fra i dati spediti può smettere di provare**
  senza dirlo, se quella condizione sparisce. Fabbricatela.
- **ThorVG non disegna `<text>`** negli SVG: provato, 0 pixel su 200941.

---

## Le due grammatiche

Il gioco è scritto due volte, e le due si controllano a vicenda.

- **Digitale** — quella che il motore esegue: `card_action`, `on_commit_effects`,
  i template di Consiglio, le clausole dei Destini.
- **Fisica** — quella che si legge al tavolo: il blocco `physical` sulle carte
  (bersaglio a segni, due Azioni, **Risonanza obbligatoria**, uso in Consiglio),
  le carte Tensione nei sei mazzetti, la faccia fisica dei Destini, i sei **Temi**.

**La Domanda non è una carta a parte** (D-266, per volere del committente): sta
sulla carta Tensione. Girata la Tensione sul Tema caldo, le sue domande — legate
ai segni del mondo — sono lì: il proponente sceglie le opportunità, gli avversari
i malus. Il ponte digitale è `possible_questions` sulla Tensione, verso i
template di Consiglio. **Il motore esegue già la Risonanza**; il resto della
faccia fisica non ancora — vedi ISSUES 69.

**Regole di scrittura di una carta fisica:**
- il bersaglio si dice **a segni**, mai col nome di una Regione;
- **due** Azioni, e due scelte diverse davvero;
- la Risonanza avviene **sempre** e scalda un Tema che esiste;
- la parte aggravata può temere solo un segno che **il verbo della carta
  raggiunge**: MUOVERE e TRAMARE arrivano a una Regione, FORGIARE a un'altra casa,
  INFLUENZARE e RIVENDICARE al mondo e a chi gioca. Il validatore lo controlla.

---

## Effect-sourcing

Ogni mutazione del mondo è un Effect con un inverso. Eccezioni dichiarate:
`saga_score`, `chronicles_played`, le assegnazioni di setup in `inherit_from`.
La Risonanza si firma `kind: "resonance"` con l'id della carta, così il verbale
distingue quello che il giocatore ha scelto da quello che il mondo ha risposto.

---

## Git

Si sviluppa sul ramo indicato dalla sessione, si apre una PR in bozza, e si
**mergia solo quando il committente lo dice**. Verbali nello stesso commit del
codice. Niente identificatori di modello in commit, PR o codice.
