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
   Mentre si lavora **bastano 30 semi** per vedere il verso di una modifica
   (`--runs=30`: **50 s** invece di 163). I 100 restano il cancello e si girano prima
   di aprire la PR, e **un numero preso su 30 semi non si scrive nei verbali**
   ([D-418](docs/DECISIONS.md#d-418)).
2. **Quello che non è misurato va dichiarato.** *Un numero peggiorato e scritto vale
   più di un numero nascosto.* Se una modifica costa qualcosa, il costo si scrive.
   E **un numero si scrive col tavolo su cui è misurato**: due misure prese su
   anni diversi non si mettono in fila come se fossero una strada. È costato una
   voce tenuta aperta cento versioni ([D-391](docs/DECISIONS.md#d-391)).
3. **I verbali stanno in `docs/DECISIONS.md`, `docs/ISSUES.md` e `CHANGELOG.md`, nello
   stesso commit del codice.** Una decisione senza verbale non è stata presa.
4. **Dei comandi dei cancelli si guarda il codice di uscita, non l'output.**

---

## Il giro dei cancelli

Tutti vogliono `export GODOT=~/godot/Godot_v4.7.1-stable_linux.x86_64`.

**Sono trentadue, e non si girano a mano uno per uno.** Li gira
[`tools/gates.py`](tools/gates.py), in tre modi:

- **senza argomenti** — i **27 veloci**, ventisei secondi in tutto: dopo ogni modifica;
- **`--lenti`** — le **5 sonde lunghe**: una volta, prima di aprire la PR;
- **`--rigenera`** — rifà i documenti generati invece di controllarli, quando uno
  va rosso solo perché è vecchio. È il rosso che costa più tempo di tutti.

La corsia lenta **non è facoltativa**: è quella che si gira una volta invece che
venti. La CI le gira tutte comunque, e
[`gates_survey.py`](tools/gates_survey.py) tiene questa tabella e la CI uguali.

**La lista dei cancelli è questa tabella, e non ce n'è una seconda:**
`gates.py` la legge da qui, colonna del costo compresa — misurata su un container
Linux, e serve solo a dire in quale corsia va un cancello.

| comando | costo | cosa sorveglia |
|---|---|---|
| `python3 tools/validate_data.py` | 0.6 s | i dati contro `/schema` |
| `python3 tools/validate_data.py --self-test` | 0.1 s | che la guardia dei gettoni morda |
| `python3 tools/validate_physical.py --check` | 0.1 s | **la grammatica fisica**: il dizionario dei segni (`godot/data/tags`) allineato ai dati — ambiti, mani, #cancelletti, muti con ragione — piu' carte senza Risonanza, Risonanze cieche, Temi senza Tensioni, tessere senza segni o che nessuno legge, Tensioni senza domande, ponti delle domande rotti, Destini che osservano l'inesistente, Echi senza effetto, bersagli non garantiti sul tavolo pescato, liste di opportunita'/malus monche o con scelte finte sulle carte Tensione |
| `python3 tools/validate_physical.py --self-test` | 2.6 s | che la guardia del dizionario morda, su ogni difetto piantato |
| `python3 tools/gen_gd_schema.py --check` | 0.1 s | `schema_defs.gd` allineato agli schemi |
| `python3 tools/gen_sign_labels.py --check` | 0.1 s | **le parole dei segni**: `sign_labels.gd` generato dal dizionario, cosi' un segno si battezza una volta sola |
| `python3 tools/build_manifest.py --check` | 0.1 s | il manifesto degli asset |
| `python3 tools/build_sign_registry.py --check` | 0.2 s | `docs/REGISTRO_SEGNI.md` |
| `python3 tools/build_flow.py --check` | 0.1 s | `docs/flusso.html`: **il flusso disegnato** — scegli un pezzo e vedi con le frecce chi ce lo mette, dove finisce, chi lo legge e cosa accende |
| `python3 tools/dead_code.py` | 0.1 s | codice che nessuno chiama |
| `python3 tools/token_catalogue.py --check` | 0.1 s | `docs/CATALOGO_PEDINE.md`: **una scheda per segnalino** — cos'e', cosa rappresenta, il prompt — e che nessun segnalino resti senza |
| `python3 tools/components_survey.py --check` | 0.3 s | `docs/COMPONENTI.md`: **quanti pezzi ha la scatola** — carte, tessere, segnalini, arte — e cosa manca perche' l'app dica tutto quello che dice il tavolo |
| `python3 tools/build_review.py --check` | 0.6 s | `docs/REVISIONE_TESTI.md`: **ogni testo che un giocatore puo' leggere**, in ordine di lettura e col suo id — e che non ne manchi nessuno: ogni frase dei dati o e' nel documento, o e' dichiarata come cosa che nessuno legge |
| `python3 tools/build_review.py --self-test` | 1.1 s | che la guardia dei testi veda un blocco nuovo non dichiarato |
| `python3 tools/matrix_survey.py --check` | 0.2 s | `docs/MISURA_MATRICE.md`: **le tre misure che vengono prima della matrice** — segni orfani, obiettivi che non si possono puntare col dito, Tensioni che non incontrano nessun Destino |
| `bash tools/run_council_catalogue.sh --check` | 1 s | `docs/CATALOGO_CONSIGLI.md` |
| `bash tools/run_card_catalogue.sh --check` | 1 s | `docs/CATALOGO_CARTE.md` |
| `bash tools/run_lives_survey.sh --check` | 186 s | `docs/MISURA_VITE.md`: **quante delle vite scritte delle case si siedono davvero al tavolo**, in dodici saghe sui due tavoli |
| `bash tools/run_tiles_probe.sh --check` | 328 s | `docs/MISURA_TESSERE.md`: **tutte le pose possibili della mappa**, enumerate — 210 pescate per 720 ordini — e quante lasciano una tessera isolata |
| `bash tools/run_card_skeleton.sh --check` | 1 s | `docs/SCHELETRO_CARTE.md`: **cosa porta ogni faccia**, ricavato dalle facce vere — i blocchi di ogni mazzo, su quante carte, e una carta vera per mazzo |
| `bash tools/run_box_survey.sh --check` | 1 s | `docs/MISURA_CASELLE.md`: **cosa una casella del Consiglio sa dire e cosa il Consiglio fa lo stesso** — il vocabolario letto chiamandolo, non ricopiato |
| `bash tools/run_marks_survey.sh --check` | 102 s | `docs/MISURA_SEGNI.md`: **quali segni il mondo scrive davvero, e chi li guarda** — quelli scritti spesso che nessuna clausola nomina, e quelli nominati che non escono mai |
| `bash tools/run_table_survey.sh --check` | 105 s | `docs/MISURA_TAVOLO.md`: **quali segni arrivano sul tavolo, posto per posto** — tutti e 180, con l'ultima colonna che non passa dal registro degli Effetti ma guarda il tavolo a fine partita |
| `bash tools/run_page_survey.sh --check` | 3 s | `docs/MISURA_PAGINA.md`: **cosa la pagina dell'app dice e con quale dito** — i testi che vivono solo nel suggerimento del mouse, i bersagli piu' stretti di un dito, i segni crudi finiti sotto gli occhi, e quanto la pagina chiede in confronto a un tablet |
| `bash tools/run_export.sh --check-brief` | 4 s | `docs/BRIEF_ARTE.md` |
| `python3 tools/issues_survey.py --check` | 0.1 s | **che il conto delle voci sia vero e che nessuna resti senza casa**: una voce chiusa porta il ✅ nel titolo, ogni voce aperta e' **ospitata** da una sezione a colore di [la lista](docs/LE_TUE_DECISIONI.md) — una sola, e del colore che il suo cartellino dice — e di quel foglio si rigenera **tutta la spina dorsale**: i numeri dei titoli (quelli in grassetto), la tabella dei colori, il ✔ sulle voci chiuse, i paragrafi del conto |
| `python3 tools/issues_survey.py --self-test` | 0.1 s | che le otto guardie del foglio delle decisioni mordano, su condizioni **fabbricate** e non cercate fra i dati |
| `python3 tools/gates_survey.py --check` | 0.1 s | **che questa tabella e la CI siano lo stesso giro**: un cancello promesso e non girato non si lamenta, e uno girato e non promesso manda in rosso chi segue il documento |
| `python3 tools/gates_survey.py --self-test` | 0.1 s | che la guardia dei cancelli morda, nei due versi |
| `python3 tools/gates.py --self-test` | 0.1 s | **che il giro in un comando sia questo giro**: un cancello senza costo scritto, o perso per strada, darebbe verde piu' in fretta |
| `bash tools/run_sims.sh` | 8 s | che ogni anno arrivi in fondo, e che lo stesso seme dia lo stesso salvataggio |
| `$GODOT --headless --path godot --script res://tests/run_tests.gd` | 160 s | la suite |

**Se tocchi uno schema, rigenera:** `python3 tools/gen_gd_schema.py`. Saltarlo fa
fallire il caricamento dei dati **in silenzio**, e i test vanno rossi altrove.

Le sonde stanno in `godot/cli/`. Le più usate: `run_playtest.gd` (il cancello),
`run_pass_probe.gd` (perché un seggio passa), `run_asking_probe.gd` (quanto rende
giocare), `run_resonance_probe.gd` (quante volte il mondo risponde),
`run_boxes_probe.gd` (quante volte una casella del Consiglio viene offerta e
quante viene presa).

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
sulla carta Tensione — e con lei **le due liste**: i *benefici* che il
proponente compra e i *costi* con cui paga. La forma finale è
[D-280](docs/DECISIONS.md#d-280): verbi chiusi legati ai segni della mappa,
posati con le pedine, dentro un'economia — *1 beneficio è gratis, ogni altro
costa 1 costo, una Cicatrice ne compra uno oltre il limite* — e **il
proponente compra, gli avversari scelgono in che moneta paga**. Niente costo
di apertura: la Tensione si risolve a fine Atto. Oggi il motore legge il menu
del prezzo dalla faccia della carta (D-278 Fase A, la strada); l'economia è da
costruire (ISSUES 72). Girata la Tensione sul Tema caldo, le sue domande — legate
ai segni del mondo — sono lì: il proponente sceglie le opportunità, gli avversari
i malus. Il ponte digitale è `possible_questions` sulla Tensione, verso i
template di Consiglio. **Il motore esegue già la Risonanza e il bersaglio a
segni** (D-274: MUOVERE e TRAMARE arrivano solo dove i segni della faccia
stanno); il resto della faccia fisica non ancora — vedi ISSUES 69.

**Regole di scrittura di una carta fisica:**
- il bersaglio si dice **a segni**, mai col nome di una Regione;
- **due** Azioni, e due scelte diverse davvero;
- la Risonanza avviene **sempre** e scalda un Tema che esiste;
- la parte aggravata può temere solo un segno che **il verbo della carta
  raggiunge**: MUOVERE, TRAMARE e SEGNARE arrivano a una Regione, FORGIARE a
  un'altra casa, INFLUENZARE e RIVENDICARE al mondo e a chi gioca. Il validatore
  lo controlla.
- **ogni faccia porta un verbo, e i verbi sono sette** ([D-423](docs/DECISIONS.md#d-422)):
  ai sei di §10 si è aggiunto **SEGNARE** — *«lascia un segno sul luogo che la
  carta raggiunge»* — perché sette facce su 96 avevano il nome stampato e nessun
  verbo: quello che facevano non lo diceva nessuno dei sei. Una faccia SEGNARE
  senza segni è rifiutata: il suo effetto **sono** i segni.

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
