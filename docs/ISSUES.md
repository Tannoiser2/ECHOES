# ECHOES — quello che resta da fare, in pezzi apribili

La roadmap dice *dove si va*. Questo dice **cosa si apre domani mattina**: ogni
voce è un'issue già scritta — titolo, etichette, milestone, perché esiste, cosa
la chiude — pronta da incollare su GitHub così com'è.

Sta nel repository e non solo su GitHub per una ragione precisa: una voce qui
dentro invecchia insieme al codice che la rende obsoleta, e si chiude nello
stesso commit che la risolve. Quando una di queste viene aperta davvero, si
segna il numero accanto al titolo.

**Regola di casa, e vale per metà di questa lista:** una modifica alle regole si
**misura prima di scriverla**. Gli strumenti ci sono già — `cli/run_playtest.gd`
(100 partite a tavolo misto), `cli/run_balance_probe.gd`, le sonde in `cli/` — e
il progetto ha già tre casi a verbale in cui la modifica ovvia peggiorava le
cose ([D-051](DECISIONS.md#d-051), [D-055](DECISIONS.md#d-055)).

Legenda etichette: `regola` · `contenuto` · `arte` · `motore` · `ux` ·
`strumenti` · `da-misurare` · `decisione` · `debito`

---

## Milestone 0.2 — Bilanciamento

### 1. Opporsi non costa abbastanza: la seconda leva

`regola` · `da-misurare` · milestone **0.2**

La prima leva è partita con la 0.1.17: una Condition qualificata entra nel
margine ([D-055](DECISIONS.md#d-055)). I fallimenti sono scesi da 315/603 a
282/596 e i seggi bloccati da 1 su 8 a 0 su 8. **Non ha detronizzato l'Oppose**:
su 100 partite a tavolo misto l'aggressivo chiude 61 Vittorie contro le 22 del
prudente.

Manca un prezzo vero sul fronte contrario. Un tentativo è già stato fatto e
respinto: una Conseguenza che alzava di 1 la domanda quando una proposta cadeva
rendeva il blocco **più** conveniente, non meno, e portava le Chronicle sopra il
tetto del §7.

Da provare, misurando: chi si oppone non recupera la carta quando la proposta
cade · l'Oppose costa un Asset in più a parità di voce · il proponente sceglie
per ultimo. Una alla volta.

**Fatto quando** una variante è misurata su gli stessi 100 semi di D-055 con
`run_playtest.gd`, e o entra con i numeri accanto, o è scritta come respinta con
i numeri accanto.

### 2. Tre-cinque template di Confluence in più

`contenuto` · milestone **0.2**

Dieci template su due saghe. Le domande che una Tensione può porre sono la parte
di contenuto che si vede di più al tavolo, ed è quella che si ripete prima.

**Fatto quando** i nuovi template passano `validate_data.py`, ogni proposta è
raggiungibile in gioco (D-035: una proposta che la policy non sceglie mai è
contenuto che non esiste) e `test_balance.gd` resta in banda.

### 3. Le carte che nessuno gioca

`contenuto` · `da-misurare` · milestone **0.2**

48 facce Asset, 132 carte. Nessuno ha mai contato quali vengono davvero
acquisite e impegnate: è esattamente la forma di problema che il progetto ha già
trovato due volte guardando un numero che nessuno guardava.

**Fatto quando** una sonda riporta, su 100 Chronicle, quante volte ogni Asset è
stato pescato, tenuto e impegnato — e la coda (le carte a zero) è o riscritta o
tolta, con la decisione a verbale.

---

## Arte e componenti fisici

### 4. Il quarto MASTER PROMPT, o via le chiavi `entity.*`

`arte` · `decisione`

L'export di stampa passa in rassegna ogni chiave d'arte in uso e ha trovato che
le **otto `entity.*` non hanno un MASTER PROMPT**: i tre della ART_BIBLE sono
carta Asset, carta Echo e tessera Regione, e nessuno è un ritratto
([D-056](DECISIONS.md#d-056)).

Due strade, e sono esclusive: si scrive MASTER PROMPT 4 (ritratto di Casata, con
la sua variation key per archetipo), oppure le carte Casata rinunciano
all'illustrazione e le chiavi si tolgono dai dati.

**Fatto quando** `ArtBible.keys_without_prompt()` torna vuota e
`test_print_export.test_the_keys_without_a_prompt_are_the_ones_we_know_about` è
aggiornato di conseguenza.

### 5. Un posto dove mettere l'arte vera

`arte` · `motore`

Il segnaposto esiste e il brief pure, ma **non c'è modo di sostituire il
segnaposto con un'immagine**: niente nel codice carica un file d'immagine per
`art_prompt_key`.

Serve una convenzione (`godot/art/<art_prompt_key>.png`, o un manifesto che le
mappi) e un solo punto che decida: se il file c'è si disegna quello, se non c'è
si disegna il segnaposto — sia nell'anteprima sia nell'SVG, che dovrà
incorporare l'immagine come `data:` URI per restare un file solo.

**Fatto quando** una carta con l'illustrazione vera e una senza convivono nello
stesso foglio, e l'export resta deterministico.

### 6. L'iconografia di sistema, leggibile a 16 px in monocromatico

`arte` · `ux`

La ART_BIBLE chiede overlay e icone come **grafica di sistema**: sei famiglie di
Asset, i livelli `structure:` / `condition:` / `settlement:` / `scar:`, i marker
di Tensione ed Echo. Non esistono — sulla mappa i tag si leggono ancora come
parole sotto il nome. Il vincolo è dichiarato: se un'icona ha bisogno del colore
per distinguersi da un'altra, va ridisegnata.

Il terreno delle Regioni è già fatto ([D-057](DECISIONS.md#d-057)) e mostra la
strada: un piano di tratti normalizzati che disegnano sia lo schermo sia l'SVG.
Le icone possono usare lo stesso vocabolario.

**Fatto quando** il set esiste come SVG nel repository, la mappa e le carte lo
usano, e la prova in monocromatico a 16 px è nel documento.

### 7. Decidere il formato fisico

`decisione` · milestone **0.6**

La COMPONENTS §7 lascia aperte tre cose che non sono di design ma di produzione:
dimensioni carte (l'export dà per buono 63×88 mm), materiale del tabellone, tipo
di paravento. E se l'app gira su un tablet passato di mano o sui telefoni dei
giocatori — la Tensione velata funziona in entrambi i casi, il secondo costa di
più da costruire.

**Fatto quando** la scelta è scritta in COMPONENTS §7 al posto della lista di
domande.

### 8. Un PDF, non venticinque SVG

`strumenti`

Per una tipografia servono un PDF e i profili di stampa; oggi escono 25 SVG. La
conversione è meccanica ma va fatta da qualcosa che non sia un passaggio a mano.

**Fatto quando** `tools/run_export.sh --pdf` produce un unico PDF con le pagine
in ordine, e la CI continua a confrontare gli SVG (che restano la sorgente
diffabile).

---

## Milestone 0.3 — World Propagation

### 9. La Chronicle II generata dalle evidence

`motore` · milestone **0.3**

`destiny_results.evidence` registra già **come** ogni obiettivo è stato
raggiunto, e nessuno lo legge. `world_state_factory.inheritance_effects()` porta
avanti la metà che serviva a misurare — controllo, tag della mappa, relazioni
che sbiadiscono — ma la generazione strutturata dell'anno dopo non c'è.

**Fatto quando** da una Chronicle conclusa esce una Chronicle nuova con domande
scelte dalle conseguenze di quella prima, e due Chronicle in fila si giocano
senza che nessuno scriva JSON a mano.

### 10. Il registro delle Truth non ha una vista

`ux` · milestone **1.0**

Le Truth sono l'unico pezzo di carta che il gioco **produce** invece di
consumare (COMPONENTS §6), e a fine anno vivono solo nel log. Nessuna schermata
le mostra insieme, e l'export non le stampa.

**Fatto quando** a fine Chronicle si vede la cronaca dell'anno, e
`run_export.gd` sa scriverla come pagine del Chronicle Book.

---

## Debiti dichiarati

### 11. `marker_id` non è usato da nessun codice

`debito` · milestone **0.5**

Ogni Regione, Entità, Tensione e carta Echo ha un `marker_id` nello schema e nei
dati. Nessuna riga di GDScript lo legge: esiste per il prototipo di computer
vision della 0.5.

**Fatto quando** o il prototipo lo usa, o il campo viene tolto dallo schema. Un
campo che nessuno legge è un campo che nessuno mantiene.

### 12. Il salvataggio nel browser sta in IndexedDB

`debito` · `ux`

Il Web export tiene `user://` in IndexedDB. La guardia c'è
(`OS.is_userfs_persistent()`), ma una partita persa perché il browser ha pulito
lo spazio è una partita persa in silenzio.

**Fatto quando** la schermata dice, prima di cominciare, se questo browser sa
tenere il salvataggio — e offre di scaricarlo quando non lo sa.

### 13. Il testo delle carte non ha una revisione editoriale

`contenuto` · `debito`

305 frasi, circa 3.300 parole, due saghe. Sono state scritte insieme al codice e
mai rilette di fila. L'export dà per la prima volta il modo di farlo: 25 fogli,
una carta accanto all'altra.

**Fatto quando** qualcuno ha letto i fogli dall'inizio alla fine e le correzioni
sono nei JSON.

---

## Come si aprono

Ogni voce qui sopra è già un'issue: il titolo dopo il numero, le etichette e la
milestone dalla riga sotto, il resto come corpo. Chi le apre segna il numero
GitHub accanto al titolo, così questo documento resta l'indice e non una seconda
verità.
