# Le tre misure che vengono prima della matrice

Generato da `tools/matrix_survey.py` — non si scrive a mano.

Le tre domande che il committente ha messo ai punti 8, 9 e 10 del suo
piano, misurate sui dati di oggi **prima** di scrivere un file nuovo.

| | |
|---|---|
| segni nel dizionario | 175 |
| di cui qualcuno scrive | 171 |
| orfani in tutto | 53 |
| **di cui senza una ragione scritta** | **0** |
| livelli di Destino (minimo/vittoria/trionfo) | 69 |
| **clausole impossibili** (chiedono un segno che niente scrive) | **0** |
| **livelli che si reggono solo su conteggi** | **11** |
| di cui vittoria o trionfo (il minimo e' una soglia di sopravvivenza) | 0 |
| livelli che non nominano nessun segno del mondo | 25 |
| Tensioni | 60 |
| **Tensioni che non toccano nessun segno nominato da un Destino** | **0** |
| **carte che aprono ancora una domanda in prestito** | **0** |
| segni che l'eredita' porta avanti | 49 |
| profili strategici scritti | 8 |
| segni che quelle case vogliono o temono | 97 |
| **fra i voluti, quelli che un Consiglio sa dare** | **24** |
| segni che aiutano una casa e ne danneggiano un'altra | 29 |
| **coppie di case che hanno qualcosa per cui litigare** | **28 su 28** |

---

## 1. I segni orfani

Un segno e' orfano se **qualcuno lo scrive** e poi nessuna Entita' lo
desidera o lo teme (Destini **e** obiettivi), nessuna Tensione lo mette
o lo toglie, e nessuna regola del segno lo usa: si posa sul tavolo e non
entra in nessuna partita.

Non tutti gli orfani sono un difetto: **53 su 53 portano gia' la loro
ragione scritta** nel dizionario — memorie narrate (D-103), etichette di
famiglia, gradi di pietra, domini che si cercano col dito. Restano fuori
quelli **senza una riga che spieghi perche' esistono**: sono questi che
la matrice deve prendere per primi.

### Orfani senza una ragione scritta: 0

Nessuno.

### Orfani dichiarati: 53

| segno | la ragione che porta scritta |
|---|---|
| `ancient` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `betrayal_spoken` | memoria del mondo che le facce fisiche usano come **bersaglio**, non come premio: una carta dice «se il tradimento e' st |
| `capital` | funzione stampata sulla tessera: e' uno dei segni con cui le carte dicono **dove** si agisce, e il legame che le frasi d |
| `crystal_site` | luogo stampato sulla tessera: la fonte del cristallo e' un **posto**, e serve da bersaglio a carte, Tensioni e Conseguen |
| `discovery:supervised_record` | una scoperta: le clausole che la contano la guardano tutte insieme, non per nome, e nessun Destino la desidera da sola — |
| `discovery:the_measure` | una scoperta: le clausole che la contano la guardano tutte insieme, non per nome, e nessun Destino la desidera da sola — |
| `discovery:the_omen` | una scoperta: le clausole che la contano la guardano tutte insieme, non per nome, e nessun Destino la desidera da sola — |
| `discovery:trade_ledger` | una scoperta: le clausole che la contano la guardano tutte insieme, non per nome, e nessun Destino la desidera da sola — |
| `discovery:written_law` | una scoperta: le clausole che la contano la guardano tutte insieme, non per nome, e nessun Destino la desidera da sola — |
| `domain:ANCIENT` | il dominio della Regione: e' il segno che dice quale Tensione guarda quale posto, e si legge cercandolo col dito sulla m |
| `domain:RESOURCE` | il dominio della Regione: e' il segno che dice quale Tensione guarda quale posto, e si legge cercandolo col dito sulla m |
| `domain:SURVIVAL` | il dominio della Regione: e' il segno che dice quale Tensione guarda quale posto, e si legge cercandolo col dito sulla m |
| `domain:TERRITORY` | il dominio della Regione: e' il segno che dice quale Tensione guarda quale posto, e si legge cercandolo col dito sulla m |
| `dragon_slain` | memoria del mondo: narrata (D-103), ereditata |
| `forest` | tessera nuova di PZ-2 (D-265). Non e' la pietra STR_FOREST, e a differenza del granaio non c'e' collisione: le facce sta |
| `free_cities` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `granary` | vocazione del luogo, stampata sulla Regione: non e' la pietra structure:granary, e le facce che stampano #granaio accett |
| `guild` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `harbor` | vocazione della tessera nuova di PZ-2 (D-265): dove il mare concede e fa pagare |
| `hard_bargain` | marchio di memoria (D-278): ha ottenuto cedendo poco, e il tavolo se lo ricorda — il motore non lo interroga |
| `heir_named` | vive sia sulla casa (entry_tag della successione) sia sul mondo (fatto ricordato) |
| `island` | tessera nuova di PZ-2 (D-265): il posto che si raggiunge solo volendo |
| `legend:debt_called` | la forma postuma di un fatto: il passaggio di Chronicle promuove a racconto quello che il mondo non tiene piu' per vero  |
| `legend:oath_broken` | la forma postuma di un fatto: il passaggio di Chronicle promuove a racconto quello che il mondo non tiene piu' per vero  |
| `legend:order_restored` | la forma postuma di un fatto: il passaggio di Chronicle promuove a racconto quello che il mondo non tiene piu' per vero  |
| `life:INC_LYRA_ARCHIVE` | la vita che la casa sta vivendo: sta stampata sulla sua scheda, e una regola del segno la legge alla successione |
| `life:INC_VETRO_SCHOOL` | la vita che la casa sta vivendo: sta stampata sulla sua scheda, e una regola del segno la legge alla successione |
| `marsh` | tessera nuova di PZ-2 (D-265): acqua ferma, canali vecchi, febbri |
| `migrating` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `mine` | vocazione del luogo, stampata sulla Regione (D-262): il posto dove si scava, che le Conseguenze nominano col segno invec |
| `order` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `parley_held` | memoria scritta da una carta Echo e letta dalle facce fisiche come **bersaglio**: dice che al tavolo ci si e' parlati, e |
| `petition_heard` | memoria scritta da una carta Echo e letta dalle facce fisiche come **bersaglio**, come `parley_held`: e' una cosa succes |
| `place:collapsed_pass` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:dry_spring` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:low_spring` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:pass` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:stripped_site` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `price_in_lives` | memoria del mondo (D-278): una decisione passata al prezzo di qualcuno che non c'e' piu' — si legge al centro del tavolo |
| `scar:burned_records` | la Cicatrice che l'Archivio (STR_ARCHIVE) lascia sulla tessera andando in rovina; nessuna clausola la nomina, come scar: |
| `scar:divided_seal` | il dente vivo e' crown_divided, letto dai Destini. La Conseguenza che lo scioglieva, Un Solo Trono, non e' uscita una vo |
| `scholar` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `settlement:$proponent` | porta un id dinamico: chi vive li' e' scritto nel segno stesso |
| `sleeping` | era etichetta di famiglia muta; da D-262 la legge la grammatica adattiva ($entity_with e requires_entity_tag): dice chi  |
| `someone_paid` | memoria del mondo: narrata (D-103), ereditata |
| `spoke_and_lost` | marchio di memoria (D-278): ha proposto e la proposta e' caduta — si legge sulla carta del casato |
| `structure:castle` | secondo grado della Torre (STR_KEEP). Arriva sul tavolo — 92 volte in cento partite, e a fine partita ci sta in 65 — e l |
| `structure:library` | secondo grado dell'Archivio (STR_ARCHIVE), la Grande Biblioteca. Arriva 14 volte in cento partite e le facce la nominano |
| `structure:palace` | terzo grado della Torre (STR_KEEP). **Oggi non arriva mai**, e quello e' un difetto vero — ma e' il difetto delle Pietre |
| `took_by_hand` | marchio di memoria (D-278): non ha aspettato la decisione, ha preso — si legge sulla carta del casato |
| `trade` | funzione stampata sulla tessera: il commercio e' uno dei segni con cui le carte dicono **dove**, ed e' letto da carte, D |
| `watched` | marchio di memoria (D-278): chi ha imposto la guardia se lo porta addosso, e si legge sulla carta del casato — il motore |
| `wild` | luogo stampato sulla tessera: il selvaggio e' un **posto**, bersaglio di carte, Destini, Tensioni e Conseguenze. Non lo  |

## 2. Gli obiettivi che non si possono puntare col dito

Due difetti diversi. Il primo e' grave: una clausola chiede un segno che
**niente scrive**, e allora quel livello non si puo' raggiungere. Il
secondo e' di leggibilita': un livello che non nomina nessun segno, non
ha un bersaglio a segni e non ha un pezzo da indicare — si verifica
facendo un totale a mente, e al tavolo non lo si mostra col dito.

**Non e' lo stesso conto del punto 5.** Li' la domanda e' se una
Tensione possa parlare di quel livello, e allora un `#granaio` non
aiuta: si indica benissimo, ma nessuna Tensione lo scrive. Qui la
domanda e' se un giocatore capisca dove guardare, e il segno stampato
sulla tessera basta. I due numeri sono 11 e 25.

**Clausole impossibili: 0**

**Livelli che si reggono solo su conteggi: 11 su 69**

Di questi, **11 sono il minimo** — una clausola sola, la soglia sotto
la quale la casa non c'e' piu': *«il trono regge»*, *«il popolo
sopravvive»*. Li' il conto e' la cosa giusta, e nessuna Tensione deve
nominarli per minacciarli: chi ti toglie l'ultima Regione te li toglie.
**Gli altri 0 sono vittoria o trionfo** — cioe' quello per cui una
casa viene ricordata — e quelli si riducono a un'addizione.

| Destino | livello | clausole | come si legge |
|---|---|---|---|
| DST_LYRA | minimum | 1 | Ha capito qualcosa |
| DST_NAHR_ROOTED | minimum | 1 | Qualcosa che resta, piantato |
| DST_LYRA_TAUGHT | minimum | 1 | Qualcosa è stato insegnato |
| DST_SALE_OPEN | minimum | 1 | Una terra risponde alla Gilda |
| DST_LIBERE_WATER | minimum | 1 | Un'opera alzata |
| DST_SHARED_RENOWN | minimum | 1 | Un posto che risponde al tuo nome |
| DST_SHARED_LAND | minimum | 1 | Un posto che risponde |
| DST_SHARED_ACCOUNTS | minimum | 1 | Due conti tenuti sotto controllo |
| DST_SHARED_QUIET | minimum | 1 | Tre questioni tenute giù |
| DST_SHARED_LORE | minimum | 1 | Una cosa vista |
| DST_SHARED_HAND | minimum | 1 | Le mani non vuote |

## 4. Quanto di quello che una casa vuole, il tavolo sa darlo

I profili strategici (`data/design_matrix`) dicono cosa una casa vuole
lasciare nel mondo. Qui si chiede se il tavolo abbia i mezzi: **chi puo'
dare quel segno** — un Consiglio vinto, una carta calata, una
Conseguenza — e chi puo' infliggere quello che teme. Una casa che vuole
cose che nessuno sa dare non ha una strategia: ha un desiderio.

### ENT_ALDRIC

> Un regno che, quando lui non ci sara' piu', si sappia ancora a chi obbedisce.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `succession_by_law` | **si'** | **si'** | Conseguenza, faccia della Tensione, fatto che dura |
| vuole | `crowned` | no | no | casato |
| vuole | `structure:granary` | **si'** | **si'** | Pietra |
| vuole | `order_restored` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `crown_divided` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| teme | `condition:unrest` | **si'** | **si'** | Conseguenza, Risonanza, carta Asset, carta Echo, faccia della Tensione |
| teme | `condition:starving` | **si'** | **si'** | Conseguenza, Risonanza, carta Echo, faccia della Tensione |
| teme | `question_unresolved` | no | no | Conseguenza |
| teme | `scar:changed_hands` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `charter_written` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `discovery:the_charter` | no | no | Conseguenza |
| teme | `nahr_settled` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| teme | `structure:tollgate` | **si'** | **si'** | Pietra |
| teme | `mine_sealed` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |

### ENT_CENERE

> Una montagna che paghi chi ci e' sceso, e che non decida chi non ci e' mai stato.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `crystal_exploited` | **si'** | **si'** | Conseguenza, faccia della Tensione |
| vuole | `ash` | no | no | casato |
| vuole | `discovery:crystal` | no | **si'** | Conseguenza |
| vuole | `structure:tollgate` | **si'** | **si'** | Pietra |
| teme | `mine_sealed` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| teme | `structure:sealed` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `condition:emptied` | **si'** | **si'** | Conseguenza, carta Echo, faccia della Tensione |
| teme | `study_supervised` | no | no | Conseguenza |
| teme | `faith_established` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `anointed` | no | no | Conseguenza |
| teme | `crystal_measured` | **si'** | **si'** | carta Echo, faccia della Tensione |
| teme | `ledger_public` | **si'** | **si'** | Conseguenza, carta Asset, faccia della Tensione, fatto che dura |

### ENT_LIBERE

> Sette citta' che si reggono senza una corona sopra, e una Carta che lo dica per iscritto.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `charter_written` | **si'** | no | Conseguenza, faccia della Tensione |
| vuole | `charter_for_all` | **si'** | no | faccia della Tensione |
| vuole | `water_moves` | **si'** | no | Conseguenza, carta Echo, faccia della Tensione |
| vuole | `debt_forgiven` | **si'** | **si'** | Conseguenza, carta Echo, faccia della Tensione |
| vuole | `discovery:the_charter` | no | no | Conseguenza |
| teme | `crowned` | no | no | casato |
| teme | `no_charter` | no | no | Conseguenza |
| teme | `condition:cut_off` | **si'** | **si'** | Conseguenza, carta Asset, carta Echo, faccia della Tensione |
| teme | `water_priced` | no | no | Conseguenza |
| teme | `debt_called` | **si'** | **si'** | Conseguenza, carta Asset, faccia della Tensione |
| teme | `anointed` | no | no | Conseguenza |
| teme | `account_settled` | **si'** | no | Conseguenza, carta Echo, faccia della Tensione |
| teme | `structure:tollgate` | **si'** | **si'** | Pietra |
| teme | `structure:archive` | **si'** | **si'** | Pietra |

### ENT_LYRA

> Che quello che ha capito resti scritto dove chiunque possa rileggerlo, anche chi non le crede.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `discovery:crystal` | no | **si'** | Conseguenza |
| vuole | `knowledge_shared` | **si'** | **si'** | carta Echo, faccia della Tensione |
| vuole | `crystal_measured` | **si'** | **si'** | carta Echo, faccia della Tensione |
| vuole | `structure:archive` | **si'** | **si'** | Pietra |
| vuole | `discovery:legend` | no | **si'** | Conseguenza |
| vuole | `discovery:the_ledger` | no | **si'** | Conseguenza |
| vuole | `question_unresolved` | no | no | Conseguenza |
| teme | `mine_sealed` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| teme | `study_supervised` | no | no | Conseguenza |
| teme | `condition:guarded` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `scar:unanswered` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `faith_established` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `anointed` | no | no | Conseguenza |
| teme | `crystal_exploited` | **si'** | **si'** | Conseguenza, faccia della Tensione |
| teme | `debt_called` | **si'** | **si'** | Conseguenza, carta Asset, faccia della Tensione |

### ENT_NAHR

> Fermarsi da qualche parte senza smettere di poter andare via.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `nahr_settled` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| vuole | `settlement:village` | **si'** | **si'** | Pietra |
| vuole | `nomad_range` | no | no | tessera |
| vuole | `burden_shared` | no | no | Conseguenza, carta Echo |
| teme | `valley_sealed` | no | no | Conseguenza, fatto che dura |
| teme | `scar:sealed_border` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `condition:emptied` | **si'** | **si'** | Conseguenza, carta Echo, faccia della Tensione |
| teme | `condition:cut_off` | **si'** | **si'** | Conseguenza, carta Asset, carta Echo, faccia della Tensione |
| teme | `condition:guarded` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `structure:tollgate` | **si'** | **si'** | Pietra |
| teme | `charter_written` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `knowledge_shared` | **si'** | **si'** | carta Echo, faccia della Tensione |
| teme | `structure:sealed` | **si'** | no | Conseguenza, faccia della Tensione |

### ENT_SALE

> Un mondo dove una firma vale, e dove chi ha promesso paga anche quando e' scomodo.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `debt_called` | **si'** | **si'** | Conseguenza, carta Asset, faccia della Tensione |
| vuole | `account_settled` | **si'** | no | Conseguenza, carta Echo, faccia della Tensione |
| vuole | `structure:tollgate` | **si'** | **si'** | Pietra |
| vuole | `ledger_public` | **si'** | **si'** | Conseguenza, carta Asset, faccia della Tensione, fatto che dura |
| vuole | `discovery:the_ledger` | no | **si'** | Conseguenza |
| teme | `debt_forgiven` | **si'** | **si'** | Conseguenza, carta Echo, faccia della Tensione |
| teme | `condition:cut_off` | **si'** | **si'** | Conseguenza, carta Asset, carta Echo, faccia della Tensione |
| teme | `crown_divided` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| teme | `oath_broken` | no | **si'** | Conseguenza |

### ENT_VAERAX

> Che la montagna torni un posto dove non si va, e che nessuno ricordi bene perche'.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `mine_sealed` | **si'** | no | Conseguenza, faccia della Tensione, fatto che dura |
| vuole | `study_supervised` | no | no | Conseguenza |
| vuole | `mountain_forgotten` | **si'** | no | catena delle ere, faccia della Tensione |
| vuole | `place:sleeping_site` | **si'** | no | Pietra |
| teme | `crystal_exploited` | **si'** | **si'** | Conseguenza, faccia della Tensione |
| teme | `discovery:crystal` | no | **si'** | Conseguenza |
| teme | `condition:exploited` | **si'** | no | Conseguenza, Risonanza, faccia della Tensione |
| teme | `knowledge_shared` | **si'** | **si'** | carta Echo, faccia della Tensione |
| teme | `condition:unrest` | **si'** | **si'** | Conseguenza, Risonanza, carta Asset, carta Echo, faccia della Tensione |
| teme | `discovery:legend` | no | **si'** | Conseguenza |

### ENT_VETRO

> Che quello che fu misurato una volta resti custodito, e non torni in discussione ogni generazione.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `anointed` | no | no | Conseguenza |
| vuole | `faith_established` | **si'** | no | Conseguenza, faccia della Tensione |
| vuole | `relic_buried` | **si'** | no | Conseguenza, faccia della Tensione |
| vuole | `structure:sealed` | **si'** | no | Conseguenza, faccia della Tensione |
| teme | `knowledge_shared` | **si'** | **si'** | carta Echo, faccia della Tensione |
| teme | `crystal_measured` | **si'** | **si'** | carta Echo, faccia della Tensione |
| teme | `ledger_public` | **si'** | **si'** | Conseguenza, carta Asset, faccia della Tensione, fatto che dura |
| teme | `condition:emptied` | **si'** | **si'** | Conseguenza, carta Echo, faccia della Tensione |
| teme | `discovery:legend` | no | **si'** | Conseguenza |
| teme | `discovery:the_ledger` | no | **si'** | Conseguenza |

## 3. Le Tensioni che non incontrano nessun Destino

Una Tensione ha conflitto se **aiuta qualcuno e minaccia qualcun altro**:
aiuta chi vede sparire un segno che teme o comparire uno che vuole,
minaccia chi vede il contrario. Senza conflitto, al Consiglio nessuno
avrebbe una ragione per opporsi.

**E qui c'e' il numero che vale il viaggio.** Tutte e 60 le Tensioni
hanno un conflitto *strutturale* — la loro faccia alza una Pietra e
incide una Cicatrice, e i Destini contano l'una e l'altra — ma quel
conflitto e' **identico su tutte**: e' il modello della faccia (D-280),
non e' contenuto. Il conflitto che distingue una questione dall'altra e'
quello **nominato**, e li' il conto e' **0 su 60**.

**Il conto e' un pavimento**: guarda i segni che la faccia della carta
posa e toglie, non il controllo, non il Calore, non chi ci guadagna in
voti. Una Tensione che compare qui e' certamente muta; una che non
compare non e' certamente viva. La colonna **la guarda** conta le case
il cui Destino dichiara di osservare uno dei suoi segni (`observes`,
D-270): un interesse c'e', ma non e' ancora un conflitto.

Nessuna: ogni Tensione aiuta qualcuno e minaccia qualcun altro.

## 5. Gli incroci: chi litiga con chi, e per cosa

*«Gli stessi segni devono trasformare piu' Entita' in direzioni
diverse»* — la linea delle trasformazioni. Qui si misura sui dati di
oggi: per ogni segno, **chi aiuta** e **chi danneggia**, mettendo
insieme quello che i Destini chiedono e quello che i profili
dichiarano. Un segno che aiuta qualcuno e non danneggia nessuno non e'
una questione: e' un regalo, e al Consiglio nessuno avra' mai una
ragione per opporsi.

**Segni che incrociano davvero: 29.**

**Il conto e' un pavimento**, come quello delle Tensioni: guarda i
segni **nominati** da un Destino o da un profilo, non i conteggi. Un
Destino che chiede due Pietre o zero Cicatrici entra in conflitto con
mezzo tavolo senza nominare niente — ma quel conflitto vale per tutti
allo stesso modo, e quindi non distingue una coppia dall'altra. Qui
interessa **cosa fa litigare queste due case e non altre**.

La colonna **cambia pelle** dice se quel segno e' fra quelli che una
porta del tempo legge (D-290): perderlo non sposta una clausola, sposta
**cosa quella casa diventera'**.

| segno | aiuta | danneggia | cambia pelle | chi lo sa scrivere |
|---|---|---|---|---|
| `structure:tollgate` | CENERE, SALE | ALDRIC, LIBERE, NAHR | **si'** | Azione stampata, Pietra |
| `charter_written` | LIBERE, VETRO | ALDRIC, NAHR | — | Conseguenza, faccia della Tensione |
| `anointed` | VETRO | CENERE, LIBERE, LYRA | **si'** | Conseguenza |
| `condition:cut_off` | VAERAX | LIBERE, NAHR, SALE | — | Azione stampata, Conseguenza, carta Asset, carta Echo, faccia della Tensione |
| `knowledge_shared` | LYRA | NAHR, VAERAX, VETRO | **si'** | Azione stampata, carta Echo, faccia della Tensione |
| `ledger_public` | SALE | CENERE, SALE, VETRO | **si'** | Azione stampata, Conseguenza, carta Asset, faccia della Tensione, fatto che dura |
| `mine_sealed` | VAERAX | ALDRIC, CENERE, LYRA | — | Conseguenza, faccia della Tensione, fatto che dura |
| `crown_divided` | NAHR | ALDRIC, SALE | — | Conseguenza, faccia della Tensione, fatto che dura |
| `crystal_exploited` | CENERE | LYRA, VAERAX | **si'** | Azione stampata, Conseguenza, faccia della Tensione |
| `crystal_measured` | LYRA | CENERE, VETRO | **si'** | Azione stampata, carta Echo, faccia della Tensione |
| `debt_called` | SALE | LIBERE, LYRA | **si'** | Azione stampata, Conseguenza, carta Asset, faccia della Tensione |
| `discovery:crystal` | CENERE, LYRA | VAERAX | **si'** | Azione stampata, Conseguenza |
| `discovery:legend` | LYRA | VAERAX, VETRO | **si'** | Azione stampata, Conseguenza |
| `discovery:the_ledger` | LYRA, SALE | VETRO | **si'** | Azione stampata, Conseguenza |
| `faith_established` | VETRO | CENERE, LYRA | **si'** | Conseguenza, faccia della Tensione |
| `question_unresolved` | LYRA | ALDRIC, SALE | **si'** | Conseguenza |
| `structure:sealed` | VETRO | CENERE, NAHR | **si'** | Conseguenza, faccia della Tensione |
| `study_supervised` | VAERAX | CENERE, LYRA | — | Conseguenza |
| `account_settled` | SALE | LIBERE | **si'** | Conseguenza, carta Echo, faccia della Tensione |
| `condition:contested` | NAHR | ALDRIC | — | Azione stampata, Conseguenza, carta Asset, carta Echo, faccia della Tensione |
| `crowned` | ALDRIC | LIBERE | **si'** | casato |
| `debt_forgiven` | LIBERE | SALE | — | Azione stampata, Conseguenza, carta Echo, faccia della Tensione |
| `discovery:the_charter` | LIBERE | ALDRIC | — | Conseguenza |
| `nahr_settled` | NAHR | ALDRIC | **si'** | Conseguenza, faccia della Tensione, fatto che dura |
| `relic_buried` | VETRO | CENERE | **si'** | Conseguenza, faccia della Tensione |
| `rumour_running` | VAERAX | VETRO | — | Conseguenza |
| `structure:archive` | LYRA | LIBERE | **si'** | Azione stampata, Pietra |
| `succession_by_law` | ALDRIC | NAHR | **si'** | Azione stampata, Conseguenza, faccia della Tensione, fatto che dura |
| `water_priced` | SALE | LIBERE | — | Conseguenza |

### Le coppie che non hanno niente per cui litigare

Il controllo che la linea delle trasformazioni chiede: **due case
devono condividere almeno un segno che le spinge in direzioni
opposte**. Le coppie che non ce l'hanno possono sedere allo stesso
tavolo per otto anni senza incontrarsi mai.

**Coppie incrociate: 28 su 28.**

**Tutte le case hanno un profilo**, quindi quello che resta non e'
piu' un buco di dichiarazioni: e' la superficie. Un incrocio
richiede che **lo stesso segno** sia nominato da una casa come
voluto e da un'altra come temuto, e ogni casa ne nomina otto o
nove; il resto di quello che i Destini chiedono non nomina nessun
segno — 25 livelli su 69, conteggi e bersagli a segni stampati —
e litiga con tutti allo stesso modo.
Le coppie ancora mute si chiudono in due modi: **una faccia di
Tensione** che metta uno di quei segni sul tavolo dove le due case
si incontrano, oppure **un `denies`** scritto — che e' un incrocio
dichiarato a mano, e costa una riga.

Nessuna coppia resta muta: ogni casa ha una questione con ogni altra.

### Quante questioni ha ogni coppia

| coppia | segni condivisi | quali |
|---|---|---|
| LYRA ↔ VETRO | 6 | `anointed`, `crystal_measured`, `discovery:legend`, `discovery:the_ledger`, `faith_established`, `knowledge_shared` |
| LIBERE ↔ SALE | 5 | `account_settled`, `debt_called`, `debt_forgiven`, `structure:tollgate`, `water_priced` |
| LYRA ↔ VAERAX | 5 | `discovery:crystal`, `discovery:legend`, `knowledge_shared`, `mine_sealed`, `study_supervised` |
| ALDRIC ↔ NAHR | 4 | `condition:contested`, `crown_divided`, `nahr_settled`, `succession_by_law` |
| CENERE ↔ VAERAX | 4 | `crystal_exploited`, `discovery:crystal`, `mine_sealed`, `study_supervised` |
| CENERE ↔ VETRO | 4 | `anointed`, `faith_established`, `relic_buried`, `structure:sealed` |
| ALDRIC ↔ LIBERE | 3 | `charter_written`, `crowned`, `discovery:the_charter` |
| CENERE ↔ LYRA | 2 | `crystal_exploited`, `crystal_measured` |
| LYRA ↔ SALE | 2 | `debt_called`, `question_unresolved` |
| NAHR ↔ SALE | 2 | `crown_divided`, `structure:tollgate` |
| NAHR ↔ VETRO | 2 | `charter_written`, `structure:sealed` |
| SALE ↔ VETRO | 2 | `discovery:the_ledger`, `ledger_public` |
| ALDRIC ↔ CENERE | 1 | `structure:tollgate` |
| ALDRIC ↔ LYRA | 1 | `question_unresolved` |
| ALDRIC ↔ SALE | 1 | `structure:tollgate` |
| ALDRIC ↔ VAERAX | 1 | `mine_sealed` |
| ALDRIC ↔ VETRO | 1 | `charter_written` |
| CENERE ↔ LIBERE | 1 | `structure:tollgate` |
| CENERE ↔ NAHR | 1 | `structure:tollgate` |
| CENERE ↔ SALE | 1 | `ledger_public` |
| LIBERE ↔ LYRA | 1 | `structure:archive` |
| LIBERE ↔ NAHR | 1 | `charter_written` |
| LIBERE ↔ VAERAX | 1 | `condition:cut_off` |
| LIBERE ↔ VETRO | 1 | `anointed` |
| LYRA ↔ NAHR | 1 | `knowledge_shared` |
| NAHR ↔ VAERAX | 1 | `condition:cut_off` |
| SALE ↔ VAERAX | 1 | `condition:cut_off` |
| VAERAX ↔ VETRO | 1 | `rumour_running` |

