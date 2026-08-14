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

### 1. ✅ Opporsi non costa abbastanza: la seconda leva — fatta in 0.1.24

`regola` · `da-misurare` · **chiusa** ([D-064](DECISIONS.md#d-064))

La leva scelta fra le tre in elenco è la prima: **chi si oppone non recupera la
carta quando la proposta cade**. Sugli stessi 100 semi di D-055 il divario in
Vittorie fra aggressivo e prudente passa da **37 a 26** (69-32 → 66-40), i
fallimenti da 274 a 251, e i Consigli per Chronicle restano 5,96 — dentro la
banda del §7, che è quello che la Conseguenza tentata la prima volta aveva
sfondato. Sta in `confluence_rules.opposer_recovers_on_failure`, quindi si toglie
senza toccare il codice.

**Non ha detronizzato l'Oppose**: 66 contro 40 resta una distanza. Le altre due
varianti in elenco non sono state misurate, e [D-063](DECISIONS.md#d-063) ne ha
aggiunta una terza che sembra più mirata di tutt'e tre — **il diritto di
proporre**, che il gioco sposta già con `CLAIM`. È il primo candidato della 0.2.

<details><summary>Il testo dell'issue come era stato scritto</summary>

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

</details>

### 2. Tre-cinque template di Confluence in più

`contenuto` · milestone **0.2**

Dieci template su due saghe. Le domande che una Tensione può porre sono la parte
di contenuto che si vede di più al tavolo, ed è quella che si ripete prima.

**Aggiornato due volte dalle misure.** Prima [D-061](DECISIONS.md#d-061): metà
delle domande già scritte non veniva mai posta. Poi
[D-063](DECISIONS.md#d-063), con la sonda `run_choice_probe.gd`, che ha risposto
alle domande lasciate aperte qui sopra:

- **eligibility che non si avvera mai: zero**, in tutt'e due le saghe. Ipotesi
  chiusa.
- **il tavolo uniforme sotto-riporta**: CHR_01 passa da 13 proposte su 15 a
  **15 su 15** appena si misura col tavolo misto. La prima saga è tutta
  raggiungibile.
- **un template che CHR_03 non poteva aprire** (`CNF_ANY_SURVIVAL`, 3 proposte):
  tolto dalla lista, e adesso `validate_data.py` lo controlla.
- restano **5 proposte su 20** in CHR_03 che nessuno sceglie nemmeno a tavolo
  misto, e non è perché sono scritte male: esistono solo come cose che qualcun
  altro vuole evitare, e l'unico seggio che ne vorrebbe una non prende mai la
  parola su quella domanda.

Quindi il lavoro qui non è più «scrivere altri template»: è il diritto di
proporre (issue 1).

**Fatto quando** i nuovi template passano `validate_data.py`, ogni proposta è
raggiungibile in gioco (D-035: una proposta che la policy non sceglie mai è
contenuto che non esiste) e `test_balance.gd` resta in banda.

### 3. Le carte che nessuno gioca

`contenuto` · `da-misurare` · milestone **0.2**

48 facce Asset, 132 carte. Nessuno ha mai contato quali vengono davvero
acquisite e impegnate: è esattamente la forma di problema che il progetto ha già
trovato due volte guardando un numero che nessuno guardava.

**Metà fatta in 0.1.24** ([D-063](DECISIONS.md#d-063)): `cli/run_choice_probe.gd`
fa questo conteggio per le **proposte di Confluence** e separa i tre motivi per
cui una non arriva mai ai voti. Manca la stessa cosa per gli Asset, e la lezione
da riportare è che la misura va fatta **a tavolo misto**: l'ottimizzatore da solo
dichiara morto contenuto che vivo lo è.

**Fatto quando** una sonda riporta, su 100 Chronicle, quante volte ogni Asset è
stato pescato, tenuto e impegnato — e la coda (le carte a zero) è o riscritta o
tolta, con la decisione a verbale.

### 14. L'asse dei rapporti quasi non esiste

`contenuto` · `da-misurare` · milestone **0.2**

Dalla 0.1.25 il punteggio di una proposta **sa leggere** un rapporto che si
muove ([D-066](DECISIONS.md#d-066)), e continua a pesare **zero su 156**: solo
**2 Consequence su 45** muovono un rapporto, e nessun Destino in gioco nomina una
coppia. Forgiare è una delle sei azioni del gioco e non ha quasi niente su cui
mordere.

**Fatto quando** `run_stance_probe.gd` riporta `SET_RELATION` con un numero
diverso da zero nella colonna «pesato», e il modo per arrivarci è scritto a
verbale: Conseguenze che facciano nemici, e clausole `relation_state` nei Destini
al tavolo. Vedi [AUDIT_DESTINI.md](AUDIT_DESTINI.md) §2.3.

### 15. Nessuno perde mai

`regola` · `da-misurare` · milestone **0.2**

Su 400 risultati di seggio in 100 partite: **NONE 1**, MINIMUM 205, VICTORY 181,
TRIUMPH 13. Una scala a quattro gradini in cui il primo non succede mai e il
quarto succede nel 3% dei casi è una scala a due gradini — e il gradino che manca
è quello che dà peso a tutti gli altri. Se non puoi fallire, «Vittoria» vuol dire
solo «ho giocato».

La causa non è la taratura: **perdere non è implementato.**
`SET_ENTITY_ACTIVE` compare **zero volte in tutti i dati** — è in 7 Minimi su 8 e
niente lo può falsificare — e le 5 `REMOVE_PRESENCE` che esistono sono o
opzionali sulla `$region_focus` o costi che ci si infligge da soli. L'audit
completo, con le direzioni possibili e le trappole, sta in
[AUDIT_DESTINI.md](AUDIT_DESTINI.md).

**Fatto quando** una variante è misurata sugli stessi 100 semi di D-055 e NONE
smette di essere un livello teorico — o è scritta come respinta con i numeri
accanto.

---

## Arte e componenti fisici

### 4. ✅ Il quarto MASTER PROMPT — fatto in 0.1.24

`arte` · `decisione` · **chiusa** ([D-065](DECISIONS.md#d-065))

Scelto il **ritratto**, che è quello che D-060 aveva già assegnato alle Casate
quando ha riscritto la regola 3. Variation key sui sei archetipi; due di quelle
righe non sono un volto, ed è per loro che il prompt dice *one subject* e non
*one face*. Lo stemma resta il ripiego dichiarato: la chiave non cambierebbe,
cambierebbe solo il prompt.

`ArtBible.keys_without_prompt()` torna vuota, e il test che contava le chiavi
scoperte è diventato la guardia che pretende che restino zero.

<details><summary>Il testo dell'issue come era stato scritto</summary>

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

</details>

### 5. ✅ Un posto dove mettere l'arte vera — fatto in 0.1.21

`arte` · `motore` · **chiusa** ([D-059](DECISIONS.md#d-059))

La convenzione è il nome del file: la chiave con i punti al posto delle barre,
sotto `res://art/` (vedi [`godot/art/README.md`](../godot/art/README.md)). Se il
file c'è si disegna quello, se non c'è il segnaposto — sullo schermo,
nell'anteprima e nel foglio di stampa, che lo incorpora come `data:` URI.

Più `map.board`, il tabellone dipinto: l'unica chiave che non sta nei dati.

**Resta da fare**: consegnare le illustrazioni. Le chiavi sono 98 e i prompt
sono già scritti uno per uno in [BRIEF_ARTE.md](BRIEF_ARTE.md) — la mappa e le
sei tessere Regione sono arrivate, restano le 48 Asset, le 36 Echo e le 8
Casate — che dalla 0.1.24 hanno il loro prompt come tutte le altre
([D-065](DECISIONS.md#d-065)).

### 6. ✅ L'iconografia di sistema — fatta in 0.1.20

`arte` · `ux` · **chiusa** ([D-058](DECISIONS.md#d-058))

Dodici glifi senza colore — le sei famiglie, i quattro livelli della mappa, i due
marker — disegnati sia sullo schermo sia in stampa dallo stesso piano. La prova
del monocromatico a 16 px esce dall'export come `prova_icone.svg`, quindi si
rigenera invece di invecchiare. Il vincolo ha respinto due disegni prima di
chiudersi: FORCE era la stessa cosa del marker di Tensione, KNOWLEDGE era la
lettera A.

**Resta fuori**: i glifi delle famiglie sono sulle carte e sulla mappa, ma la
plancia azione e i paraventi non esistono ancora come pezzi, quindi non li usano.
Si aggiungeranno con loro.

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
