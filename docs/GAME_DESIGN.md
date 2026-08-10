# ECHOES — Game Design

ECHOES è un boardgame/GDR narrativo-strategico a Chronicle. Ogni Chronicle è una
storia completa ambientata nello stesso mondo persistente. I giocatori controllano
Entità di scala differente — un sovrano, un popolo, una creatura antica, un
individuo — ognuna con obiettivi propri e incompatibili.

Questo documento spiega **perché** il gioco è fatto così. Per le regole operative
vedi [RULES_V0_2.md](RULES_V0_2.md); per il modello dati
[DATA_SCHEMA.md](DATA_SCHEMA.md).

---

## L'idea centrale

Il gameplay ordinario non è il gioco: è la **preparazione** al gioco.

Durante i round i giocatori acquisiscono Asset, spostano presenza, coltivano
relazioni e sondano ciò che il mondo nasconde. Nel frattempo le Tensioni salgono
da sole — il Drift è il mondo che continua a esistere mentre i giocatori si
organizzano. Quando una Tensione raggiunge la soglia si apre una **Confluence**:
un evento storico in cui tutti possono intervenire, e in cui gli Asset accumulati
diventano argomenti.

Il valore di un Asset non è intrinseco. Una Riserva di Grano vale 1 in una
questione sul Cristallo Rosso e vale piena forza nella Carestia. Chi ha previsto
quale Tensione sarebbe maturata arriva alla Confluence con le carte giuste; chi ha
accumulato a caso arriva con carte che valgono 1. **La preparazione è la scelta di
quale futuro credere.**

---

## Perché le Confluence sono il payoff

Tre proprietà le rendono il centro del tavolo:

1. **Chiunque può intervenire.** Il proponente formula la proposta, ma ogni altro
   giocatore dichiara pubblicamente Support, Oppose, Condition o Abstain, e poi
   impegna Asset in segreto. Nessuno è spettatore.
2. **La Condition è una terza via.** Non è né sostegno né opposizione: è "passi,
   ma a questa condizione". Se chi la pone impegna abbastanza, la clausola si
   attacca a ogni esito di successo. È il modo in cui un perdente strutturale
   ottiene comunque qualcosa.
3. **Il fallimento non risolve nulla.** Una proposta che cade fa scendere la
   Tensione di 2, non la azzera: la questione resta viva e può tornare. Non si
   può "vincere" una Confluence non facendola passare.

Il World Factor (1d6 mappato su −2…+2) esiste perché il tavolo non debba mai
essere certo del risultato prima di rivelare gli impegni. È abbastanza piccolo da
non ribaltare una preparazione seria e abbastanza grande da rendere rischioso un
margine di 1.

---

## Le cinque parole

Il sistema distingue rigidamente cinque cose che i giochi narrativi tendono a
confondere:

| | cos'è | esempio |
|---|---|---|
| **State** | condizione attuale e modificabile | la Valle Verde è controllata da Eredan |
| **Relation** | legame fra Entità | Aldric e i Nahr sono ENEMY, con un DEBT |
| **Echo** | fatto storico registrato | «Il grano della Valle passò sotto il sigillo del trono» |
| **Scar** | un Echo che ha cambiato la mappa | le Miniere sono sigillate, e si vede |
| **Truth** | record immutabile | quello che il mondo ricorderà nella Chronicle II |

Uno State si può cambiare. Un Echo no: `CREATE_ECHO` e `APPEND_TRUTH` sono gli
unici Effect irreversibili del sistema, e persino il Developer Mode può tornare
indietro solo ripristinando uno snapshot. Questa asimmetria è la regola di design
più importante del gioco: **la storia costa**.

---

## Le quattro Entità della Chronicle I

Sono progettate perché nessuna coppia possa vincere insieme del tutto.

- **Re Aldric** (Sovrano, Potere) — controlla il centro politico e dipende dal
  cibo che non produce. Vuole una Carestia bassa *e* il controllo su chi la
  risolve.
- **Popolo Nahr** (Popolo, Sopravvivenza) — undicimila persone che si spostano
  perché la terra ha smesso di rispondere. Vogliono fermarsi senza smettere di
  essere Nahr: l'insediamento riconosciuto conta solo se la Valle non è stata
  chiusa.
- **Lyra** (Individuo, Conoscenza) — vuole capire il Cristallo Rosso e poter
  tornare a guardarlo. Sigillare le Miniere la sconfigge anche se la salva.
- **Vaerax** (Creatura, Protezione) — sa cosa c'è sotto le Montagne e vuole che
  continui a dormire. Il suo Triumph richiede esattamente ciò che nega Lyra.

Il conflitto è strutturale, non arbitrato: Aldric e i Nahr si contendono la stessa
Valle, Lyra e Vaerax lo stesso sigillo. Nessuno dei quattro può ottenere il
proprio Triumph senza togliere qualcosa a un altro.

---

## Perché due Tensioni, e perché una velata

**La Carestia** è aperta: tutti vedono il numero, tutti possono spingerlo. È la
questione su cui si negozia.

**Il Risveglio** è velata: si vedono i presagi — le lampade che si spengono
insieme, la neve che non attecchisce — ma non il numero. Solo SCHEME lo apre, e
solo per chi lo ha fatto. Serve a due cose: dà a Lyra e Vaerax un'informazione
che gli altri non hanno, e crea la sensazione che il mondo stia facendo qualcosa
mentre il tavolo discute d'altro.

Il Risveglio, da solo, non arriva alla soglia: il suo Drift non basta. Ci arriva
perché il **Ripple** di una Confluence sulla Carestia lo spinge, o perché una
carta Echo lo porta allo scoperto. È voluto: la questione antica diventa urgente
*a causa* di come il tavolo ha risolto quella immediata.

---

## Cosa fa l'app, e cosa non fa

L'app gestisce **regole e memoria**. Non inventa esiti: le domande, le proposte,
le clausole e i messaggi dei presagi vengono tutti dai dati. Il codice non scrive
mai una riga di narrativa che non sia stata autorata.

L'eventuale IA futura (0.4) sarà **narratore/interprete, non arbitro**: prenderà
un esito già determinato meccanicamente e lo racconterà. Per questo le proposte in
v0.x si scelgono da opzioni strutturate e non si scrivono a mano — un esito deve
restare risolvibile e testabile senza un modello linguistico.

---

## Perché la 0.0 è headless

La v0.1 della specifica chiedeva motore, UI e ~150 elementi di contenuto in
un'unica milestone. Il rischio era generare contenuto bilanciato prima di sapere
se le regole funzionano.

La 0.0 gioca una Chronicle completa da riga di comando in meno di un secondo.
Questo ha già pagato: durante lo sviluppo i piani di simulazione hanno mostrato
che quattro giocatori con otto AO possono annullare il Drift +1 per nove round
di fila, e che una Confluence poteva finire con il Popolo Nahr che proponeva al
trono di requisire il grano. Nessuna delle due cose si sarebbe vista guardando
il codice, e trovarle dopo aver disegnato 48 carte sarebbe costato molto di più.

Entrambe sono documentate in [DECISIONS.md](DECISIONS.md) — la prima come
questione di bilanciamento aperta per la 0.2 ([D-018](DECISIONS.md#d-018)), la
seconda risolta nei dati aggiungendo eligibility alle proposte
([D-016](DECISIONS.md#d-016)).
