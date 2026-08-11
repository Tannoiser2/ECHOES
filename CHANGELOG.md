# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).
Il progetto segue le milestone della specifica esecutiva v0.2.

---

## [0.0.12] — Nessuno aveva un motivo per essere nella stanza

Chiude O-12, O-13 e la serratura di Vaerax. Tre cose aperte, sistemate insieme
perche erano la stessa cosa vista da tre lati.

### Changed

- **Il proponente lo decide il posto, non il dominio.** §12.2 C dice "piu
  presenza nelle Regioni della Tensione"; era letto come l'intero dominio, ora e
  la Regione di cui si sta discutendo. `domain:ANCIENT` sono due Regioni e il
  Destino di Vaerax lo pianta in entrambe: tutti e 40 i Consigli sul Risveglio
  erano suoi, e non era mai in aula a votare l'unica Tensione che gli importa.
  Misurate due estensioni del dominio: **nessuna rompe la serratura**, una la
  peggiora. Le Vie passano da 2 proponenti a 4, la Successione da 1 a 2.

- **O-12: la Successione e le Vie hanno una posta in gioco.** Il primo tentativo
  — un `tension_limit` a testa — ha peggiorato le cose: un tetto fa spendere
  azioni a tenere giu la Tensione, e tenerla giu fa smettere di porre la domanda.
  Le Vie erano passate da 36 Consigli a 6. Una posta non deve essere un limite su
  un numero: un **tag** pesa sulle proposte e non guida nessuna azione. Due
  coppie di poste direttamente opposte — `crown_divided` fra Aldric e i Nahr,
  `condition:cut_off` fra Lyra e Vaerax — danno la lite senza il silenzio.

- **O-13: `P_ANY_LEAVE` ha un motivo per essere proposta.** Dare solo
  `ADJUST_TENSION -2` non bastava: `P_ANY_RATION` offriva lo stesso sollievo piu
  la Regione, quindi andarsene restava dominato. Il premio giusto era scritto
  nella categoria stessa della Conseguenza — **MIGRATION, non LOSS**: chi se ne
  va arriva da qualche parte. Ora arriva al voto 7 volte su 40 Chronicle, e
  `condition:abandoned` viene scritto per la prima volta.

- **La banda dichiarata passa da 4-5 a 5-6.** Misurata, isolata e dichiarata, non
  aggiustata in silenzio. E la giustificazione non e "il test falliva": il 3-4 di
  §7 sulle due Tensioni di §18.2 e 1,5-2,0 Confluence **per Tensione**, mentre il
  4-5 di D-026 su quattro Tensioni e 1,0-1,25 — era piu severo di quanto §7 abbia
  mai chiesto. Il tasso misurato ora e 1,3 per Tensione, ancora sotto quello di
  §7.

### Measured

| | prima | dopo |
|---|---|---|
| consigli con almeno un no | 28% | **50%** |
| seggi che si oppongono almeno una volta | 3 | **4** |
| opposizioni di Vaerax | 0 | **26** |
| mappe di controllo distinte | 8 | **16** |
| stato finale distinto (su 40 partite) | 38 | **40** |
| Scar per Chronicle | 1,60 | **2,00** |
| tag mai scritti (CHR_01 / CHR_02) | 3 / 1 | 3 / **0** |

Ogni singola Chronicle su quaranta finisce ora in uno stato del mondo diverso.

### Fixed

- **I tre piani di simulazione, riautorati.** Plan B spostava un token sulla
  Strada dei Mercanti per vincere il dominio SURVIVAL: sotto la regola nuova e il
  posto sbagliato, perche il Consiglio parla della Valle. Spostato nella Valle, la
  sua storia torna esatta — i Nahr chiedono la terra e il tavolo intero risponde
  di no, **S1 O7 M−4**. Plan A e sceso da tre Consigli a due, e il motivo e il
  gioco che funziona: la requisizione decisiva sgombera i Nahr dalla Valle, e
  senza quella presenza nessuno puo piu toccare le Vie per il resto dell'anno. Ora
  il piano lo dice nella propria descrizione invece di pretendere un numero.

### Open

- **O-14** — la classifica dei Destini si e inclinata: Aldric resta al Minimum in
  32 Chronicle su 40, Lyra arriva al Triumph in 32. Nessuno e piu congelato come
  prima di D-035, ma lo spread e sbilanciato. Registrato e non tarato: tre giri di
  misura di fila hanno trovato lo strumento in torto e non le regole, e la lezione
  e non correre alle manopole.

---

## [0.0.11] — La prima domanda di ogni Consiglio non veniva mai posta

Chiude O-6 e O-8. Cercavo contenuto da scrivere e ho trovato di nuovo lo
strumento — ma stavolta quello che c'era sotto valeva piu della correzione.

### Changed

- **`PolicyDecider.choose_question` sceglie davvero.** Restituiva `""`, cioe
  rinunciava a scegliere, e vinceva sempre il default: *l'ultima* domanda
  ammissibile. Ogni seconda domanda e vincolata a una Tensione al limite, e un
  Consiglio si apre solo quando la sua Tensione e al limite — quindi la seconda
  domanda era sempre ammissibile e **la prima domanda di ogni template non e
  mai stata posta in quaranta Chronicle**. Le sue proposte non potevano essere
  votate e le loro Conseguenze non potevano scattare: era tutto O-8.

  Un essere umano al tavolo se le vedeva offrire entrambe. Il contenuto non era
  irraggiungibile: era il giocatore che misura a non allungare mai la mano.

### Measured

| | prima | dopo |
|---|---|---|
| coppie domanda/proposta votate | 7 su 18 | **12** |
| tag di Regione mai scritti | 9 | **3** |
| consigli con almeno un no | 16% | **28%** |
| SUCCESS_WITH_COST | 6 | **27** |
| DECISIVE_SUCCESS | 105 (57%) | **76 (39%)** |
| mappe di controllo distinte | 3 | **8** |
| Scar per Chronicle | 1.15 | **1.60** |

E i Destini si sono scongelati. Nella saga di dieci Chronicle Lyra faceva
TRIUMPH dieci volte su dieci e Vaerax VICTORY dieci su dieci, ogni anno,
identici. Ora Aldric fa MIN 18 / VIC 10 / TRI 12, Lyra MIN 23 / TRI 17, Vaerax
VIC 22 / TRI 18. Nessun seggio ha piu un finale gia scritto.

### Fixed

- **La guardia di D-034 era scritta male.** Contava quante volte ogni Effect
  spostava il punteggio durante partite vere, ed e fallita appena il contenuto
  si e mosso — non perche la policy fosse cieca, ma perche le proposte che ora
  vengono avanti toccano la Successione e le Vie, che **nessun Destino di
  CHR_01 nomina** (O-12). Una guardia che non sa distinguere "la policy e
  cieca" da "il contenuto si e spostato" e peggio di niente: grida al lupo a
  ogni cambio di contenuto e si zittisce tarando. Riscritta come quattro casi
  costruiti, e verificata togliendo un ramo alla volta.
- **`run_world_probe` mentiva su un tag.** Un tag scritto attraverso uno slot
  (`settlement:$proponent`) e autorato in una forma e atterra in un'altra:
  confrontare le due grafie lo dava per "MAI" mentre scattava ogni partita.

### Open

- **O-12** — nessun Destino mette un limite sulla Successione o sulle Vie.
  Quattro Tensioni, due poste in gioco.
- **O-13** — `P_ANY_LEAVE` toglie presenza e controllo *al proponente stesso*:
  nessuno che gioca per vincere la proporrebbe mai.
- **Vaerax possiede la sua domanda.** Misurato: non e sistemabile dal contenuto.

---

## [0.0.10] — Perche nessuno diceva di no

Restringe O-6. La domanda era: se le crisi arrivano al voto, perche il tavolo le
approva quasi sempre? La risposta e la stessa delle ultime due volte — non le
regole, lo strumento che le misura.

### Added

- **`cli/run_stance_probe.gd`** — la sonda che ha risposto. Per ogni consiglio e
  ogni seggio che non propone registra il punteggio calcolato dalla policy e la
  posizione che ne e uscita, e per ogni Effect se quell'Effect ha spostato il
  punteggio **anche una sola volta**. Il secondo conteggio e quello che conta: un
  Effect letto centinaia di volte e mai pesato non e un Effect silenzioso, e un
  motivo di lite che la policy non sa vedere.

  Ha trovato **96% di ABSTAIN** e un punteggio con soli tre valori possibili
  (−2, 0, +2): `ADJUST_TENSION` (letto 489 volte), `SET_CONTROL` (210),
  `SET_ENTITY_TAG` (300) e `SET_RELATION` (171) non pesavano **mai**.

### Changed

- **`ConfluenceController.effect_context()` e ora pubblico** (era `_context()`).
  Un decisore deve poter valutare una proposta *prima* di votarla, e puo farlo
  solo se risolve `$region_focus` come lo risolvera il passo K. La policy usa la
  tabella del Consiglio, non una copia, cosi le due non possono divergere.
- **`PolicyDecider._score_effect` legge tre assi che prima non vedeva.**
  - `ADJUST_TENSION` contro le clausole `tension_limit`: −2 la spinta che rompe
    una clausola che regge, +2 quella che ne ripara una rotta, ±1 il semplice
    muoversi nella direzione sbagliata o giusta dentro la banda. Rompere una
    clausola vale un no; una direzione che non piace vale una clausola.
  - `SET_ENTITY_TAG discovery:*` contro `discovery_count`, +2 e solo a chi la
    riceve: che un altro impari qualcosa non ti costa niente.
  - Gli `$slot` vengono risolti, e questo da solo ha riportato in vita
    `SET_CONTROL` e `REMOVE_PRESENCE` senza toccarne il punteggio.

  I conflitti erano **gia scritti nei dati**: una proposta che alza la Carestia
  contro un popolo il cui Destino la tiene sotto tre e una lite che il contenuto
  aveva scritto e lo strumento non sapeva leggere.

### Measured

| | prima | dopo |
|---|---|---|
| ABSTAIN | 96.0% | **84.1%** |
| OPPOSE | 2.8% | **5.4%** |
| SUPPORT | 1.2% | **10.5%** |
| consigli con almeno un no | 8% | **16%** |
| FAILURE (su ~180 Confluence) | 7 | **23** |

Non chiude O-6: `DECISIVE_SUCCESS` resta al 57%, e Vaerax si astiene ancora
144 volte su 144 — ma non per cecita della policy: **tutti e 40 i consigli sul
Risveglio li apre lui**, quindi non e mai nella stanza a votare l'unica Tensione
che il suo Destino nomina. Quella e una questione di contenuto.

---

## [0.0.9] — Il vicino, il tipo di luogo, e uno strumento che mentiva

Chiude O-11, il prezzo pagato nella 0.0.8.

### Added

- **`$adjacent`** — la Regione accanto a quella in discussione, scelta come il
  vicino che porta gia **meno segni**. Il danno si sparge invece di accumularsi,
  e si legge bene: il guaio va dove non e ancora stato.
- **`$region_with:<tag>`** — uno slot parametrico: nomina un **tipo** di luogo
  invece di un luogo. Una Conseguenza puo dire *il granaio*, *il crocevia*, *il
  sito del cristallo* e viaggiare da una Chronicle all'altra senza conoscere la
  mappa. Risolto dal compilatore, che per questo ha ricevuto un riferimento al
  mondo; `validate_data.py` verifica che il tag sia dichiarato da qualche
  Regione, cosi un refuso fallisce alla build invece di risolversi in silenzio.

### Changed

- **`PolicyDecider.choose_proposition` rompe i pareggi con l'RNG di sessione.**
  Partiva da `options[0]` e la sostituiva solo con un punteggio *strettamente*
  maggiore: quasi tutte le proposte pareggiano a zero, quindi la prima opzione
  legale vinceva sempre e **dodici delle diciotto proposte autorate non sono mai
  state scelte in quaranta Chronicle**. E un cambio allo *strumento di misura*,
  non alle regole — la stessa lezione di D-021.

### Fixed

- **`run_world_probe` mentiva.** Stampava "il controllo e cambiato: NO" per una
  campagna in cui Aldric perde la capitale alla seconda Chronicle, i Nahr la
  prendono alla sesta e Aldric la riprende alla decima — perche confrontava solo
  la prima e l'ultima mappa, e coincidevano. Ora conta tutte le mappe di
  controllo attraversate. Una misura che confronta gli estremi chiama "nessun
  cambiamento" un viaggio di andata e ritorno.

### La misura

| | 0.0.8 | 0.0.9 |
|---|---|---|
| mappe di controllo distinte (40 partite) | 3 | **5** |
| set di tag distinti | 21 | **31** |
| stato finale distinto | 24 | **31** |
| Scar per Chronicle | 0.17 | **1.52** |
| proposte diverse messe ai voti | 6 | **10** |
| frasi Truth distinte | 56 su 94 | **73 su 104** |
| tag sulla mappa in 10 Chronicle | 1 → 10 | **1 → 17** |

Le Scar per Chronicle sono ora il doppio di quante ne avevamo **prima** che la
0.0.8 le perdesse (0.75): la generalizzazione e finita in attivo, non solo
recuperata.

---

## [0.0.8] — Conseguenze a slot, e un registro che non si ripete

Chiude la meta di contenuto di D-028, che era rimasta dichiarata e non fatta.

### Added

- **Quattro slot invece di uno** negli Effect: `$region_focus` (il posto di cui
  discutiamo), `$capital` (il seggio del potere), `$rival` (il posto al tavolo
  contro cui la domanda e posta), `$rival_seat` (dove quel posto sta davvero).
  Sono le quattro cose che una Conseguenza intende quando nomina un nome proprio.
- **`echo_summaries`**: una proposta puo portare una frase per ogni banda di
  esito. Come cade una proposta non si legge come quando trionfa, e il registro
  delle Truth e il posto dove una Chronicle si rilegge. Una banda senza variante
  ricade sulla frase unica, quindi non si e dovuto riscrivere niente.
- **`docs/COMPONENTS.md`**: quale testo sta su quale pezzo fisico, cosa e sullo
  schermo, cosa e segreto e dietro quale paravento. Non era in nessuna specifica.

### Changed

- **21 Conseguenze su 23** riscritte a slot: sono contenuto di biblioteca, non
  piu di Chronicle. I bersagli relazione diventano `$proponent|$rival`, e il
  compilatore normalizza la chiave dopo la sostituzione — la coppia va in ordine
  crescente e i dati non possono sapere come e seduto il tavolo.
- 13 proposte su 18 portano varianti di esito.

### Fixed

- **`$rival` e prefisso di `$rival_seat`**, e il compilatore sostituiva in ordine
  di dizionario: lo slot diventava `ENT_NAHR_seat`, un bersaglio inesistente,
  segnalato solo da un push_error dentro l'applier. Chiavi ordinate per lunghezza
  decrescente, la stessa correzione che `NarrativeText.fill` aveva gia.
- Il controllo statico dei binding non spezzava un bersaglio relazione sul `|`,
  quindi meta coppia non veniva verificata.

### La misura

| | prima | dopo |
|---|---|---|
| frasi Truth distinte su 40 Chronicle | 22 su 63 | **56 su 94** |

E il salto piu grosso di varieta narrativa mai misurato nel progetto, ed e
costato una quarantina di frasi scritte.

### Il prezzo, ed e reale

| | prima | dopo |
|---|---|---|
| mappe di controllo distinte | 6 | **3** |
| Scar per Chronicle | 0.75 | **0.17** |
| il controllo cambia in 10 Chronicle | si | **no** |

`$region_focus` e **stabile** per una Tensione, quindi ogni Conseguenza di quella
Tensione finisce sullo stesso posto, dove sei Regioni scritte a mano spargevano
il danno sulla mappa. Tre Conseguenze sono state ripuntate su `$rival_seat` e
`$capital` e ne hanno recuperato una parte, non tutta.

E uno scambio, ed e registrato come tale: le Conseguenze ora si riusano fra
Chronicle, e la mappa si muove meno dentro una sola. Vedi O-11.

---

## [0.0.7] — Le 24 funzioni

D-030 aveva cablato la grammatica, ma solo 16 delle 24 funzioni dichiarate nello
schema avevano una carta. Le otto mancanti erano anche le piu interessanti da
vincolare: una Punizione dopo una Violazione, una Separazione che rende possibile
un Ritorno.

### Added

- **Otto carte Echo** (16 → 24), una per ogni funzione ancora scoperta: Supplica
  (REQUEST), Offerta (TEMPTATION), Parola Data (VIOLATION), Partenza
  (SEPARATION), Incontro (ENCOUNTER), Presa (CONQUEST), Conto (PUNISHMENT), Chi
  Siede (SUCCESSION). Il mazzo e ora **24 carte, 6 per famiglia drammatica, una
  per funzione dichiarata** — e un test impone tutti e tre i numeri.
- **La condizione `any_of`**: vale se almeno una delle condizioni annidate vale.
  Ogni lista di condizioni nei dati e un AND, e la grammatica di Propp e piena di
  alternative — un Ritorno segue una Separazione **o** una Chiusura. Senza, le
  otto carte nuove non si potevano scrivere onestamente. Dodici righe
  nell'evaluator, un `$ref` a se stesso nello schema, un ramo di ricorsione nel
  validatore.
- Tre Conseguenze nuove (29 → 32) per gli effetti delle carte nuove.

### Changed

- `ECH_ROADS_OPEN`, `ECH_RECONCILIATION` e `ECH_AMNESTY` usano `any_of`: i
  vincoli a un solo antecedente le rendevano piu rare di quanto la grammatica
  richieda.

### La misura

| | D-030 | D-031 |
|---|---|---|
| funzioni con una carta | 16/24 | **24/24** |
| funzioni pescate in 40 Chronicle | 16 | **21** |
| funzioni senza antecedente | 0 | **0** |
| Atto 3 risolve | 23/40 | **28/40** |

Verificato anche sulla Chronicle di biblioteca: 22 funzioni pescate, 0 orfane.

### Segnalato, non corretto

- `SACRIFICE` esce 14 volte su 40 perche e l'unica carta RESOLUTION che non
  presuppone niente, e l'Atto 3 chiede prima una risoluzione. E il prezzo
  dell'invariante — ogni famiglia mantiene una carta sempre giocabile — e
  spianarlo vorrebbe dire inventare un antecedente che un sacrificio non ha.
- La banda delle Confluence e scesa dall'85% al 70% dentro 4-5 con il mazzo piu
  largo, sempre senza niente fuori da 2-7. Resta O-6.

---

## [0.0.6] — Propp entra davvero nel gioco

Le carte Echo portavano due metadati narrativi. Uno lavorava, l'altro era
un'etichetta che il motore non leggeva mai.

### La verifica

`cli/run_echo_probe.gd` su 40 Chronicle:

- **`dramatic_family` era portante**: decide quali carte un Atto puo pescare,
  quindi la forma in tre atti era gia imposta (Atto 1 PRESSURE 40/40).
- **`function_id` non era letto da nessuna riga di codice.** Un grep lo trovava
  in un posto solo: la colonna che lo stampa nel manifest.

Il prezzo: **19 funzioni in 18 partite su 40 arrivavano senza il loro
antecedente** — un Ritorno da cui non si era partiti, una Riconciliazione senza
tradimento, una Liberazione senza niente di proibito. Il punto di Propp e che le
funzioni hanno un **ordine**, e niente lo faceva rispettare.

### Added

- **`function:<ID>` come tag globale** quando una carta viene pescata, applicato
  come un normale Effect. E l'unica modifica al motore, che continua a non
  conoscere il nome di nessuna funzione.
- **La grammatica sulle carte**, nel blocco `eligibility` che avevano gia: la
  Riconciliazione aspetta un tradimento, l'Amnistia un'usurpazione, le Vie
  Riaperte una chiusura, il Giuramento una minaccia, l'Annata Buona una carestia,
  la Rivelazione una scoperta.
- **`cli/run_echo_probe.gd`** e **`tests/unit/test_echo_grammar.gd`**.

### Changed

- **`act_echo_pools[].families` e un sacchetto pesato**, non un insieme:
  ripetere una famiglia la rende piu probabile, e l'RNG seeded decide l'ordine in
  cui le famiglie vengono provate. Nessuna modifica allo schema — le ripetizioni
  erano gia legali, semplicemente non significavano niente.

### Due cose che si sono rotte, e cosa hanno insegnato

**Stringere troppo impedisce all'arco di chiudersi.** Con tutte e quattro le
carte RESOLUTION vincolate, l'Atto 3 e passato da risolvere 18/40 a 11/40: la
pesca saltava le carte vincolate e ripiegava su una rottura. Risolto lasciando
`ECH_SACRIFICE` senza condizioni — un sacrificio non presuppone niente, e una
scelta — e protetto da un test: **ogni famiglia drammatica deve mantenere almeno
una carta sempre giocabile**.

**Una preferenza stretta non e una forma, e un binario.** Leggendo il pool come
preferenza ordinata usciva **un solo arco in tutte e quaranta le partite**: PRE
RUP RES, 40/40. Forma perfetta, zero storia. Da li il sacchetto pesato.

### La misura

| | prima | dopo |
|---|---|---|
| funzioni senza antecedente | 19 (18/40) | **0** |
| Atto 1 apre in PRESSURE | 40/40 | 40/40 |
| Atto 3 risolve | 18/40 | **23/40** |
| archi drammatici distinti | 9 | 9 |

Un Atto 3 che finisce a meta crisi il 40% delle volte non e un difetto: la
domanda rimasta aperta e quello che la Chronicle successiva eredita.

Non previsto, di nuovo: la banda delle Confluence e salita all'**85%** dentro
4-5, dal 75%.

---

## [0.0.5] — Le crisi non si spengono, si spostano

Una verifica chiesta dall'autore: le crisi scoppiano sempre, o un tavolo puo
tenerle chiuse? La risposta misurata era **si, puo tenerle chiuse** — e questo
lo corregge.

### Added

- **`cli/suppressor_decider.gd`** — un tavolo che fa solo soppressione: quattro
  Entita che spendono ogni AO per ricacciare giu la Tensione piu alta che possono
  toccare, comprando una SCHEME quando serve a sbloccarne una velata. Nessuno
  gioca cosi: e uno stress test.
- **`cli/run_crisis_probe.gd`** — fa giocare le stesse Chronicle ai due tavoli e
  riporta, per ogni Tensione, quante volte e scoppiata, il **picco** raggiunto
  (il valore finale nasconde una Tensione portata sull'orlo e ricacciata giu) e
  quanta pressione del mondo e stata annullata.
- **`influence_rules.displacement_on_decrease`** (D-029) — spingere giu una
  Tensione ne alza una delle sue `linked_tensions`. Non si spegne una crisi: si
  sceglie quale avere. Reversibile: si toglie e sparisce.
- Tre test nella suite di bilanciamento sulla regola nuova, incluso che lo
  spostamento **non** consumi una seconda INFLUENCE.

### Changed

- **Il grafo dei collegamenti fra Tensioni riscritto.** Prima tutto alimentava la
  Carestia e niente alimentava le Vie Interrotte, quindi lo spostamento riempiva
  una domanda e ne affamava un'altra. Ora e un anello con corde, verificato in
  modo che ogni Tensione alimenti e sia alimentata — sia fra le sei della
  biblioteca sia fra le quattro di Chronicle I.
- **`plan_c_opened_mine`** dimostra ora D-029: i Nahr tengono la Carestia sotto
  soglia in ogni round degli Atti 2 e 3 e ci **riescono**, ma il peso che tolgono
  di li si scarica altrove, e a scoppiare sono il Risveglio e le Vie Interrotte.

### Fixed

- Lo spostamento ha un proprio `source.id` (`ACT_INFLUENCE_DISPLACED`) pur
  restando attribuito a chi ha agito: senza, il cap per round su INFLUENCE —
  che si ricostruisce dal log — lo contava come una seconda azione.
- La sonda contava zero spinte: una lambda GDScript cattura una variabile locale
  **per valore**, quindi i contatori incrementati dentro il gestore del segnale
  non tornavano indietro. Ora sono in un Dictionary.

### La misura

Prima della regola, 40 Chronicle:

| | quattro Destiny | solo soppressione |
|---|---|---|
| Confluence per Chronicle | 3.60 | **0.17** |
| Chronicle senza nessuna | 0/40 | **33/40** |
| La Carestia e scoppiata | 35/40 | **0/40** |
| Il Risveglio | 38/40 | **0/40** |
| Le Vie Interrotte | 21/40 | **0/40** |

1400 spinte in giu contro 452 del mondo. Tre a uno.

Dopo:

| | prima | dopo |
|---|---|---|
| soppressori: Chronicle silenziose | 33/40 | **1/40** |
| soppressori: Confluence per Chronicle | 0.17 | **2.73** |
| tavolo normale | 3.60 | 4.58 |

La soppressione **compra** ancora qualcosa (2.73 contro 4.58): tenere giu una
domanda resta una mossa vera con un effetto vero. Non puo piu comprare il
silenzio.

### Effetto non previsto

Il bilanciamento e migliorato da solo: **75% delle partite nella banda 4-5**
contro il 42%, e niente sotto 2 o sopra 7. Chiude anche O-5.

---

## [0.0.4] — Le decisioni prese

Tre scelte dell'autore, implementate e misurate: la banda del §7, il leader che
scappa, e il modello di campagna.

### Changed

- **Banda 4-5 invece di 3-4** (D-026). Il numero del §7 era scritto per due
  Tensioni; una Chronicle ne porta quattro e la mediana misurata e 4. Deviazione
  dichiarata, non taratura silenziosa: `test_balance.gd` e la sonda portano
  entrambi la banda nuova e citano l'entry.

### Added

- **`chronicle.control_rules`** (D-027) — tenere non e gratis, e la risposta e
  dell'autore: non una penalita a chi sta vincendo, ma una pressione che nasce
  dalla situazione. Un impero cade per la propria dimensione.
  - `max_stable_control`: ogni Regione tenuta oltre il limite alza la Tensione
    **del dominio di quella Regione**, una volta per round. Al tavolo si legge
    come "tieni anche la strada? allora la domanda sulla strada e tua".
  - `lapse_without_presence`: a inizio Chronicle una Regione tenuta senza
    nessuno dentro torna a nessuno. Non si governa dove non si e.
- **Contenuto di biblioteca** (D-028) — l'autore ha scelto il modello **B**:
  niente Chronicle pre-scritte, si assemblano.
  - `confluence_template.applies_to_domain` — un Consiglio puo servire un intero
    dominio invece di una sola Tensione. E il risparmio piu grosso del progetto:
    i Consigli erano circa un terzo del costo di scrittura di una Chronicle, ed
    erano la parte da riscrivere ogni volta. `CNF_ANY_SURVIVAL` e il primo,
    scritto interamente a slot.
  - `chronicle.tension_pool` — una Chronicle **pesca** le proprie Tensioni invece
    di elencarle. Il sorteggio usa lo stesso RNG seeded dei mazzi: stesso seed,
    stesso anno. `CHR_02` e la prima in forma biblioteca e pesca 4 domande su 6.
  - `TEN_PLAGUE` e `TEN_THIRST`: le prime Tensioni **senza un Consiglio proprio**,
    che ne ricevono uno completo gratis.
  - Tre Conseguenze scritte solo a slot (`CNS_RATIONED`, `CNS_ABANDONED`,
    `CNS_SHARED_BURDEN`): il modello per generalizzare le altre 26.
- **`tests/unit/test_library_content.gd`** — 6 test sul meccanismo nuovo.

### Fixed

- **`ADJUST_TENSION` / `SET_TENSION_VISIBILITY` su una Tensione non in gioco**
  ora sono un no-op invece di un fallimento: il contenuto di biblioteca nomina
  domande che una data Chronicle puo non aver pescato. Un id che **non e** una
  Tensione resta un errore — la distinzione e quello che tiene un refuso rumoroso.
- **`$tension` nelle condizioni `tension_limit`** e **`$region_focus` nel blocco
  Scar** ora si risolvono: un Consiglio di dominio non sa quale domanda serve
  finche non si apre.
- **La policy** non presume piu che il bersaglio di un `SET_CONTROL` sia una
  Regione nominata: puo essere uno slot che si risolve solo all'apertura.

### La misura

Il leader che scappa, dieci Chronicle ereditate, stessi seed:

```
prima   Re - Vae Re  Re  Re     (dalla quinta in poi, immobile)
dopo    Re - Vae Re  Pop -  ->  Re - Vae - - -  ->  Re - Vae Re - -
```

Il controllo si espande e si ritira invece di congelarsi. Truth 13 → 16, frasi
distinte 12 → 15, Scar per Chronicle 0.45 → 0.75.

E la Chronicle di biblioteca gira per dieci anni pescando ogni volta una mano
diversa di domande, senza un solo errore e senza che nessuno l'abbia scritta.

### Segnalato, non corretto

- **O-6** resta aperta per meta: la banda e decisa (D-026), ma Failure e Success
  with Cost restano assottigliate (9 e 5 contro 18 e 15).
- **O-8**: sei Conseguenze su 29 non scattano mai.
- Le 26 Conseguenze piu vecchie nominano ancora una Regione precisa: sono
  contenuto di Chronicle, non di biblioteca. Generalizzarle e il prossimo pezzo
  di B, ed e lavoro di scrittura, non di motore.

---

## [0.0.3] — Un mondo che si puo muovere

Misura prima, contenuto dopo. La domanda era: dopo dieci Chronicle, quanto e
cambiato il mondo? Con il contenuto della 0.0.2 la risposta era **quasi niente**.

### Added

- **`cli/run_world_probe.gd`** — due misure. `--runs` gioca N Chronicle
  indipendenti e conta quante configurazioni finali *distinte* escono: e il
  soffitto della varieta dentro una partita. `--campaign` ne gioca K di seguito,
  ognuna che eredita la precedente, e dice quanto il mondo si e spostato da dove
  era partito.
- **`GameSession.inherit_from()`** — il minimo di propagazione che una misura
  richiede: controllo, tag persistenti, relazioni, Scar, Echo e Truth passano
  alla Chronicle successiva; mano, mazzi, presenza, Tensioni e Claim si
  ridistribuiscono. L'eredita passa dall'applier come Effect, quindi ha lo stesso
  log e la stessa inversa di tutto il resto. Il motore di propagazione vero
  resta la 0.3.
- **Due Tensioni nuove** — `TEN_SUCCESSION` (TERRITORY, aperta) e `TEN_ROADS`
  (RESOURCE, velata), con i loro due Consigli, quattro domande e sette proposte.
- **14 Consequence nuove** (12 → 26) di tre forme che non esistevano: che
  **guariscono** (tolgono i tag condition, senza le quali il mondo poteva solo
  saturare), che **cambiano il controllo**, che **lasciano una Scar** — il
  meccanismo era implementato dalla 0.0 e non lo usava nessuno.
- **8 carte Echo nuove** (8 → 16). Sono l'unico contenuto che si applica senza
  che nessuno lo scelga, quindi muovono il mondo a prescindere dal tavolo.
- **`$region_focus` nel contesto degli Effect** — una Consequence puo dire "la
  Regione di cui stiamo discutendo" invece di nominarne una per sempre.
- **Controllo statico dei binding** in `validate_data.py`: un `$variabile` che il
  motore non sa risolvere compila a niente e lo dice solo in un push_error. E
  esattamente quello che `CNS_HARVEST_RETURNS` faceva su una carta Echo.
- **`test_every_echo_card_hook_compiles_to_something`** — la stessa guardia a
  runtime.

### Changed

- **`scripted_confluence.tension_id`** — un piano indirizza una Confluence per
  Tensione invece che per indice di corsa (D-025). Con l'indice, aggiungere
  contenuto faceva atterrare la direttiva del grano sul consiglio delle strade.
- **Baseline spostate e dichiarate** (§25): il sacchetto del Drift e 2/3/2/2 su
  quattro Tensioni invece di 5/4, e la soglia di `TEN_AWAKENING` scende da 7 a 6.

### Fixed

- **L'inversa di `REMOVE_REGION_TAG` rimetteva il tag in fondo alla lista** invece
  che al suo posto, quindi l'undo non tornava byte per byte. Stessa classe del bug
  sull'ordine della mano della 0.0. Trovato perche un tag nuovo nei dati ha
  spostato `capital` dall'ultima posizione.
- **Le carte Echo non sapevano risolvere `$proponent` e `$region_focus`**: gli
  hook di due carte nuove applicavano zero Effect in silenzio.

### La misura, prima e dopo

Su 40 Chronicle indipendenti, stessi seed:

| | 2 Tensioni, 12 Consequence | 4 Tensioni, 26 Consequence |
|---|---|---|
| mappe di controllo distinte | 2 | **6** |
| set di tag distinti | 14 | **26** |
| stato finale distinto | 14 | **28** |
| Scar per Chronicle | 0.00 | **0.45** |
| relazioni distinte | 2 | 2 |

E dieci Chronicle di seguito, che era la domanda:

| | prima | dopo |
|---|---|---|
| il controllo e cambiato | **mai** | si, due volte |
| tag sulla mappa | 3 → 5 | 1 → **11** |
| Scar accumulate | 0 | **9** |
| coppie Tensione/Regione a fuoco | 3 | **6** |
| frasi distinte lette | 17 | 12 |

L'ultima riga e la piu onesta: **le frasi distinte sono calate.** Il mondo si
muove molto di piu, ma con quattro Tensioni ogni Confluence e meno contesa,
quindi ne restano meno che meritino un Echo. La varieta e passata dallo stato,
non dal testo.

### Segnalato, non corretto

- **O-6**: il bilanciamento di D-021/D-023 e regredito — 42% nella banda del §7
  contro il 70%, FAILURE da 18 a 9. La banda 3-4 era scritta per il contenuto
  ridotto del §18.2; se descriva ancora una Chronicle a 4 Tensioni e una domanda
  di design, non una da tarare in silenzio.
- **O-7**: la campagna ha un leader che scappa. Aldric parte con una Regione e
  alla quinta Chronicle ne ha cinque, e non ne perde piu nessuna. L'eredita
  compone il vantaggio e niente lo inverte.
- **O-8**: sei Consequence su 26 non scattano mai. Contenuto irraggiungibile e
  contenuto che non esiste.

---

## [0.0.2] — Le proposte cominciano a costare qualcosa

Chiude l'osservazione O-4 della 0.0.1 e la O-2. Nessuna UI: la 0.1 resta non
iniziata.

### Added

- **Quattro Consequence nuove** — `CNS_VALLEY_CLEARED`,
  `CNS_CROWN_DISPOSSESSED`, `CNS_MINE_TAKEN`, `CNS_STUDY_UNDER_GUARD`. Portano il
  set da 8 a 12, sopra le 8 del §18.2: deviazione deliberata, registrata in
  [D-022](docs/DECISIONS.md) come chiede il §25. Ognuna toglie qualcosa di
  preciso a un posto preciso al tavolo, che e la ragione per cui esistono.
- **`REMOVE_PRESENCE` con `optional`** — una Consequence puo dire "sgomberali
  dalla Valle" senza sapere se qualcuno e accampato li: marcata opzionale, quello
  e un no-op e non un Effect fallito.
- **`--tension-cap` nella sonda** — sweep del secondo limite senza toccare i dati.

### Changed

- **Limite di 1 INFLUENCE per Tensione per round**
  (`chronicle.influence_rules.max_per_tension_per_round`). Reversibile come il
  primo: si toglie dalla Chronicle e sparisce. Vedi
  [D-023](docs/DECISIONS.md).
- **La policy vede il danno** — valuta `ADD_PRESENCE` / `REMOVE_PRESENCE` contro
  le proprie condizioni `region_presence` e `SET_CONTROL` contro `control_count`,
  e risponde con `OPPOSE` a una proposta che le costa 2 o piu, invece di una
  clausola di cortesia.
- **`plan_b_broken_council`** — i Nahr mettono il terzo token sulla Strada dei
  Mercanti, quindi nel dominio SURVIVAL sono loro la parte piu presente e la
  domanda sul grano e loro da porre. Il piano ora produce la sconfitta memorabile
  che il suo nome promette: S1 O6 M−5, fronte contrario a 6, quindi Echo lo
  stesso (§12.4).
- **`tests/smoke/test_balance.gd`** — la guardia ora giudica l'aggregato
  (mediana 3-4, al massimo il 10% delle partite fuori da 2-6, almeno 1 Echo ogni
  2 Chronicle) invece della singola partita. Il §7 descrive cosa deve mostrare un
  playtest, non vieta una Chronicle silenziosa. Detto per intero: la guardia e
  stata rilassata dopo che ha fallito — la motivazione e in
  [D-023](docs/DECISIONS.md), con la sequenza dichiarata.
- **`ScriptedDecider`** segnala un id di Asset inesistente in un piano invece di
  ignorarlo in silenzio. Un Asset assente dalla mano resta una degradazione
  silenziosa; un id che non e un Asset e un refuso.

### La misura, prima e dopo

Su 40 Chronicle, seed 1000-1039:

| | mediana | in banda 3-4 | sotto il minimo | FAILURE | SwC | SUCCESS | DECISIVE |
|---|---|---|---|---|---|---|---|
| 0.0.1 (8 Consequence, 1 cap) | 4 | 82% | 0/40 | **0** | 1 | 79 | 75 |
| 12 Consequence, 1 cap | 2 | 20% | 8/40 | 2 | 4 | 47 | 36 |
| **12 Consequence, 2 cap** | **3** | **70%** | 2/40 | **18** | **15** | 57 | 27 |

Tutte e quattro le bande di esito del §12.3 esistono ora nel gioco aperto. Il
resolver non e stato toccato: la matematica del §A5 e la stessa della 0.0.

### Segnalato, non corretto

- **O-5**: 2 Chronicle su 40 producono una sola Confluence, sotto il minimo che
  il §7 nomina. Con il solo cap per Entita erano 0. E il prezzo pagato per le due
  bande di esito mancanti, e il §7 dice di riportare invece di correggere in
  silenzio: questo e il riporto. Da rimisurare con le 4 Tensioni del §19.4 prima
  di aggiungere qualsiasi altra regola.

---

## [0.0.1] — Passo di bilanciamento

Chiude l'osservazione D-018 della 0.0. Nessuna UI: la 0.1 resta non iniziata.

### Added

- **`cli/policy_decider.gd`** — un giocatore che gioca davvero per il proprio
  Destiny. Deriva gli obiettivi dai dati: il livello piu basso non ancora
  raggiunto, le Tensioni che quel livello vuole basse e — decisivo — quelle che
  ha bisogno di portare a maturazione, perche l'unica cosa che puo soddisfare una
  sua condizione e una Consequence che sta dietro a una Confluence. Nessuna IA
  scritta a mano per singola Entita.
- **`cli/run_balance_probe.gd`** — gioca N Chronicle su N seed e riporta la
  distribuzione: Confluence per partita, esiti, Echo, livelli Destiny, valore
  finale delle Tensioni. Con `--influence-cap` e `--presence-directions` fa lo
  sweep di un knob senza toccare i dati.
- **`ActionResolver.check()` / `can_execute()`** — perche un'azione verrebbe
  rifiutata, senza toccare nulla. `execute()` la chiama per prima, quindi ogni
  precondizione e scritta una volta sola. La Action Dialog della 0.1 la usera per
  disabilitare i bersagli illegali (§19.3).
- **`tests/smoke/test_balance.gd`** — 24 Chronicle giocate dalla policy: fallisce
  se la mediana esce dalla banda 3-4 del §7, se una singola partita esce da 2-6,
  se i Destiny smettono di essere contesi o se il cap non regge.

### Changed

- **Limite di 1 INFLUENCE per Entita per round** su tutte le Tensioni
  (`chronicle.influence_rules.max_per_entity_per_round`). Data-driven e
  reversibile: togliendo `influence_rules` torna il comportamento v0.2.
  Implementato anche `presence_directions`, che in Chronicle I resta su entrambe
  le direzioni.

### La misura, prima e dopo

| | mediana Confluence | in banda 3-4 (§7) | fuori da 2-6 | INFLUENCE per partita |
|---|---|---|---|---|
| policy ingenua, regole v0.2 | 0 | 0/30 | 30/30 | 7.5 |
| policy corretta, regole v0.2 | 3 | 24/40 | 10/40 | 45.7 |
| **policy corretta, cap 1** | **4** | **33/40** | **0/40** | **20.1** |

La riga di mezzo e la piu importante: gran parte del problema apparente era lo
strumento di misura, non le regole. Aldric ha bisogno di `control_count >= 2`, e
il controllo cambia mano solo dentro una Confluence — un Aldric competente spinge
la Carestia *verso l'alto*. Insegnarlo alla policy ha portato la mediana da 0 a 3
senza cambiare una sola regola. Il cap ha fatto il resto, e ha riportato INFLUENCE
dal 63% al 28% di tutte le azioni giocate.

Le alternative sono state misurate e scartate: la via per presenza limitata al
solo +1 peggiora i numeri da sola (mediana 2), e insieme al cap da un risultato
peggiore del cap da solo. Dettaglio in [D-021](docs/DECISIONS.md).

### Segnalato, non corretto

- **O-4**: su 154 Confluence misurate, 0 Failure e 1 Success with Cost. Due delle
  quattro bande di esito del §12.3 non compaiono nel gioco aperto, anche se i
  piani scriptati dimostrano che sono raggiungibili. La causa sembra il contenuto
  ridotto della 0.0, non la matematica: troppo poche Consequence toccano un tag a
  cui i Destiny altrui tengono, quindi quasi nessuno ha motivo di opporsi. Da
  rimisurare con le 20 Consequence e le 4 Tensioni del §19.4.
  *(Chiusa nella 0.0.2: la lettura era giusta, ed e bastato il contenuto.)*

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
