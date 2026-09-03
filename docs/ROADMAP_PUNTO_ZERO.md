# ROADMAP — Punto Zero fisico-first

Fusione fra la RoadMap del committente e quello che questo progetto ha già
misurato. Dove le due divergono, la divergenza è scritta con il numero che la
motiva: **un numero peggiorato e scritto vale più di un numero nascosto**.

> **Le righe in citazione dicono dove sta ogni fase, con la data e il verbale.**
> Rimesse in pari in **0.1.353**: si erano fermate alla 0.1.235, cioè a
> centodiciotto versioni fa, e un piano che dichiara «fatto» quello che è stato
> rifatto tre volte è peggio di un piano senza note.

Il mandato non cambia:

> Non salvare il vecchio sistema con micro-bilanciamenti.
> Costruire un Punto Zero fisico-first. L'app simula il tavolo, non lo sostituisce.
> **Se una regola non si può spiegare guardando il tavolo, va resa visibile o tolta.**

---

## 0. Dove le due roadmap coincidono

Su questo non c'è niente da discutere, ed è la maggior parte:

- il gioco è **fisico-first**, l'app è il tavolo simulato;
- **sei Temi** con una traccia di Calore, e a fine Atto il più caldo apre una Domanda;
- ogni carta è **un'Azione scelta più una Risonanza obbligatoria**, mai un evento
  che accade;
- **ogni tag deve essere letto** da almeno una carta, Domanda, Destino, Echo o
  regola di setup;
- il **Consiglio decide il significato**, non duplica le Azioni;
- **Echo e Cicatrici preparano la Chronicle dopo**, e si vedono sul tavolo;
- i **Destini si leggono guardando la mappa**;
- i **validatori** impediscono a contenuto muto di entrare;
- il vecchio gioco resta come banca di nomi, testi ed Entità.

Parte di questo **esiste già e ha un cancello in CI**, e da 0.1.353 la lista è
questa: 6 Temi come dato, **48 carte su 48** con faccia fisica e Risonanza che il
motore esegue davvero, **60 carte Tensione** che portano ognuna le proprie
Domande e Proposte, **23 Destini su 23** con faccia, e **ventisei cancelli** —
fra cui `tools/validate_physical.py`, che si vede mordere su 42 difetti
piantati. Vedi [PUNTO_ZERO.md](PUNTO_ZERO.md).

---

## 1. Le cinque cose che cambio, e perché

### 1.1 Un solo insieme di dati, non `physical_*` in parallelo

La RoadMap propone file `physical_locations`, `physical_cards`, `physical_questions`
che convivono coi vecchi. **Non farlo.**

Questo progetto ha già scritto il rischio a verbale, in
[ISSUES 69](ISSUES.md): *«due grammatiche che non si toccano divergono; fra dieci
carte saranno due giochi diversi con lo stesso nome.»* La cura adottata è stata
l'opposta e ha funzionato: **una carta sola con due facce**, e un campo che le
lega (`from_template`/`from_question` sulle Domande) che un cancello controlla.

Quindi: si **estende** il dato esistente con i campi nuovi, e si toglie il vecchio
campo quando il motore smette di leggerlo. Un solo `asset`, un solo `region`, un
solo `destiny`. Il parallelo si paga due volte: una nel tenerlo allineato, una nel
giorno che non lo è più.

### 1.2 Le 48 carte si ri-mirano, non si riscrivono

La RoadMap chiede **24 carte pilota nuove**. Ne esistono già **48 con faccia
fisica**, misurate: 364 Risonanze su 100 anni, la metà condizionale che scatta nel
10,2%, e un cancello che impedisce di scrivere una Risonanza cieca.

Riscriverle da capo butterebbe via l'unica parte del gioco nuovo che è già provata.
Il lavoro vero è **ri-mirare i loro bersagli sul dizionario tag e sulla mappa
nuovi**, e scrivere carte nuove **solo dove la mappa nuova chiede verbi che non
esistono** (porto, canale, palude, isola non hanno oggi nessuna carta che li sappia
nominare).

### 1.3 «Dare una ragione per agire» non è bilanciamento, ed è PZ-01

La RoadMap mette il bilanciamento in fondo (PZ-03) e ha ragione sui numeri. Ma il
difetto più grosso che questo gioco ha **non è numerico**:

| | |
|---|---|
| turni «passa» | **82,8%** su 7.200 |
| passa con **zero mosse legali** | **0 su 5.960** |
| mosse legali che aveva chi passava | **15,3 in media** |
| «nessuna mossa gli serviva» | **58,7% dei passa** |

Non gli mancava il permesso e non gli mancavano le carte: **gli mancava la
ragione**. È struttura, non taratura, ed è esattamente la cosa che un tavolo
fisico rende evidente in dieci minuti di partita.

Quindi PZ-01 non è finita quando la partita gira: **è finita quando meno della
metà dei turni sono passa**. Il numero va nel criterio di successo, non rimandato
a PZ-03.

> **Il criterio è soddisfatto, e [ISSUES 68](ISSUES.md#68) si è chiusa su di
> esso in 0.1.358** ([D-391](DECISIONS.md#d-391)): i turni «passa» sono **47,6%**
> a tavolo misto (3.428 su 7.200) e **47,9%** a tavolo uniforme, la forma è
> piatta per Atto — 48,0% / 46,7% / 48,1% — e **zero** di quei passa aveva zero
> mosse legali (media: 22,1 mosse, 4,4 carte in mano).
>
> **E la strada scritta qui prima — «82,8% → 42,1% → 46,4%» — non si poteva
> percorrere**: il 42,1% era misurato su `CHR_01`, cancellato con gli altri anni
> d'autore in D-317/D-318. Rimisurato sull'anno che esiste, il difetto non si è
> mai mosso: **47,6% in 0.1.260, 47,3% in 0.1.290, 46,7% prima di D-385, 47,6%
> oggi**. Meno di un punto in cento versioni.
>
> **Quello che resta non è il permesso: è la ragione**, e adesso ha un prezzo
> scritto. L'**84,0%** dei passa è *«nessuna mossa gli serviva»* — **il 40,0% di
> tutti i turni** — e la sua causa è [ISSUES 123](ISSUES.md#123): nessuna delle
> sei Azioni della plancia alza una Pietra. È una decisione del committente, non
> una taratura.

### 1.4 Cosa rende meglio agire che stare fermi va deciso *prima*

Corollario del punto sopra, e la lezione più cara di questa sessione. Nel vecchio
modello gli obiettivi **premiavano la passività**: su 100 anni il tavolo che non
spendeva mai un'Occasione ne avverava **470**, quello che giocava **465**. Giocare
rendeva **meno di niente**, e nessuno se n'era accorto per 250 decisioni.

Il modello nuovo dice «vincono le Entità che hanno realizzato meglio i propri
Destini». **Non basta come dichiarazione.** Ogni Destino e ogni obiettivo del Punto
Zero deve contenere almeno una clausola che il mondo **non muove da solo**, e il
metro esiste già: `run_asking_probe.gd` gioca ogni anno due volte con lo stesso
seme, una col tavolo vero e una con un **tavolo di pietra** che non agisce mai.

Regola di casa nuova, da rispettare mentre si scrive: *nessun traguardo può essere
vero all'apertura dell'anno, e nessuno può avverarsi stando fermi.*

> **Dove sta la regola, in 0.1.353.** Il metro dice **+267,8%**: 423 obiettivi
> avverati giocando contro 115 dal tavolo di pietra. Era **−1,1%** quando questa
> riga è stata scritta.
>
> | | |
> |---|---|
> | obiettivi che rendono uguale o meglio stando fermi | **3 su 17** |
> | Destini che si avverano da fermi | **1 su 23** |
>
> **E il vocabolario ha imparato a chiedere un gesto** ([D-386](DECISIONS.md#d-386),
> scelta del committente). Il difetto dei sei obiettivi fermi non era il conto —
> era **il tempo del verbo**: chiedevano di *avere*, e quello che si ha lo si
> perde agendo. `did_this_year` legge il verbale dell'anno invece del tavolo, con
> quattro gesti chiusi: alzare una Pietra, prendere una terra, posare una
> presenza, stringere un legame. **Sei → tre.**
>
> I tre che restano sono tutti e tre di Pietra, e la causa è misurata: in cento
> partite **nessuna Pietra è salita per mano di un'Azione** della plancia, e
> quelle che alza il Consiglio le alza più spesso per un tavolo che tace (199)
> che per uno che gioca (136). È [ISSUES 123](ISSUES.md#123), ed è una scelta
> del committente perché tocca la plancia.

### 1.5 La mappa non è assente: è incompleta

La RoadMap descrive i Luoghi come se andassero creati da zero. Le Regioni di oggi
**hanno già** `adjacency`, `presence_slots`, `biome`, `role`, `asset_sources`, tag
stampati e una posizione sulla mappa.

Manca il pezzo che conta, ed è quello che la RoadMap ha visto giusto: **la regola
del luogo**. Oggi agire in montagna e agire in città è la stessa cosa. Quindi la
Fase 2 non è «creare la mappa», è **dare a ogni luogo una regola, i Temi che
tocca, e gli slot per condizioni, opere e cicatrici** — e portarla da 6 a 10
luoghi.

---

## 2. Le fasi, riordinate

L'ordine cambia in un punto: **il dizionario tag e i Temi vengono prima della
mappa**, perché la regola di un luogo e il bersaglio di una carta si scrivono in
tag, e un tag scritto due volte in due modi è il difetto che stiamo togliendo.

### PZ-0 — Il dizionario dei tag *(nuovo, e viene per primo)*

Oggi i tag non esistono come dato: si deducono raschiando gli effetti, e il
validatore indovina l'ambito di ognuno. Servono come **collezione dichiarata**:

```text
id · nome stampato · categoria (luogo/funzione/stato/memoria/entità)
ambito (REGIONE | ENTITÀ | MONDO) · icona · chi lo scrive · chi lo legge
```

**Fatto quando** il validatore legge l'ambito dal dato invece di dedurlo, e ogni
tag usato da una carta, Domanda, Destino o regola è nel dizionario.

> **Fatto in 0.1.221** ([D-259](DECISIONS.md#d-259)): `godot/data/tags`, 171
> voci, e `validate_physical.py` legge l'ambito da lì — la deduzione è la
> controprova, e il self-test si vede mordere in CI. Restano fuori l'icona
> (aspetta l'arte) e la riunificazione delle parole doppie con `sign_labels.gd`
> e il registro: [ISSUES 70](ISSUES.md#70).

### PZ-1 — I sei Temi con la traccia del Calore

I Temi esistono; **il Calore no**. Oggi la Risonanza scalda «la questione più
vicina alla soglia di quel Tema»: è un ponte, non la cosa. Serve la traccia 0-6
per Tema, e la regola «a fine Atto il più caldo apre la sua Domanda».

**Fatto quando** il Calore è uno stato del mondo, e la Domanda di fine Atto si
pesca dal Tema più caldo invece che dalla Tensione a soglia.

> **Fatto in 0.1.222** ([D-260](DECISIONS.md#d-260)): `theme_heat` 0-6 per Tema,
> mosso solo per Effect con inverso, e il Consiglio di fine Atto apre la
> questione del Tema più caldo (mucchio più alto come ripiego dichiarato a
> pista fredda). La pista sente 1.056 Risonanze dove il ponte ne portava 364.
> Restano d'autore salita/discesa/fine Chronicle (§4.1), e la pesca della
> **carta Domanda fisica** resta con ISSUES 69: qui si sceglie il Tema, il
> testo al tavolo è ancora quello dei template.
>
> **Rifatto in 0.1.223** ([D-261](DECISIONS.md#d-261)), su decisione del
> committente: la pista aperta diventa **sei mazzetti di Tensioni** con
> gettoni coperti 0/1/2, la carta che si gira a due segnalini, la rivelazione
> a fine Atto, e il secondo dibattito da RIVENDICARE sul secondo mazzetto.
> Il nove di D-257 sparisce per costruzione: 3-6 Consigli l'anno.

### PZ-2 — I Luoghi: regola, Temi, slot, e da 6 a 10

Per ogni luogo: tag stampati, **regola del luogo**, Temi collegati, fonti carte,
slot (presenze, condizioni, opere, cicatrici), adiacenze. Quattro luoghi nuovi
portano funzioni che oggi non esistono: porto, canale/palude, isola, bosco.

**Fatto quando** agire in montagna non è come agire in città o sulla costa — e si
può dimostrare con una misura, non con una sensazione.

> **Mezzo passo in 0.1.225** ([D-263](DECISIONS.md#d-263)): la mappa **si
> pesca** — CHR_00, la Prima Chronicle senza scenario, 15 mappe su 15
> possibili in 100 semi, e l'app si apre da lì. Restano di questa fase la
> **regola del luogo** (agire in montagna ≠ agire in città) e le **quattro
> tessere nuove**, che sono materia d'autore (§4.4).
>
> **Le quattro tessere esistono da 0.1.227** ([D-265](DECISIONS.md#d-265)):
> Porto Cinerino, Palude dei Canali, Isola Muta, Bosco dei Confini — 10
> tessere, se ne pescano 6, ogni dominio su esattamente 5 così che ogni
> mappa li porti tutti. Della fase resta la **regola del luogo**.

### PZ-3 — Le carte: ri-mirare 48, scriverne poche nuove

Ri-mirare i bersagli delle 48 sul dizionario e sulla mappa nuovi; scrivere carte
nuove solo per i verbi che i luoghi nuovi chiedono.

**Fatto quando** nessuna carta nomina un id, ogni bersaglio esiste sulla mappa
nuova, e il validatore delle Risonanze cieche resta verde.

> **Mezzo passo in 0.1.224** ([D-262](DECISIONS.md#d-262)): il contenuto dei
> Consigli e degli Echo non nomina più nessun posto per id — bersagli a segni
> (`$region_with`/`$entity_with`), tessere con segno unico stampato, guardia
> che vieta gli id nuovi. Le 48 carte Asset restano da ri-mirare sulla mappa
> nuova quando esisterà (Fase C).
>
> **Chiuso in 0.1.235** ([D-273](DECISIONS.md#d-273)): censite, **30 su 30**
> a bersaglio REGION non erano garantite sul tavolo pescato; ri-mirate con la
> matematica di D-265 (il dominio affine sta su 5 tessere su 10 ⇒ garantite
> per costruzione) più i segni nuovi dove la finzione li chiede. Guardia 17
> nel validatore, dodicesimo difetto piantato. Carte nuove non servono: i
> luoghi nuovi chiedono gli stessi sei verbi. Il limite, a verbale: la
> ri-mira è della faccia fisica — farla **eseguire** al motore è il prossimo
> passo di ISSUES 69, ed è lì che i «passa» (ISSUES 68) potranno muoversi.

### PZ-4 — Le Domande: da 12 a 18

Tre per Tema: una generica sempre valida, due filtrate dai tag. Ognuna produce e
toglie tag visibili, e dichiara l'effetto sul setup dopo.

**Fatto quando** il Tema più caldo apre **sempre** almeno una Domanda valida, in
100 anni, senza eccezioni.

> **Rivisto in 0.1.228** ([D-266](DECISIONS.md#d-266)), parola del committente:
> **niente mazzetti di Domande** — *«nella carta Tensione ci sono già le
> domande collegate ai Tag del mondo»*. Le carte Domanda sono uscite dai dati
> (una strada a 18 carte, tentata nella PR #108, è stata revocata prima del
> merge). PZ-4 cambia oggetto: non un mazzo da stampare ma **la faccia della
> Tensione che porta le sue domande**. Il criterio «il Tema più caldo apre
> sempre» vale già per costruzione dal mazzetto pieno (D-264/D-265: 0 mazzetti
> vuoti su 600). La forma del dibattito — proponente → opportunità e bonus,
> avversari → malus — passa a PZ-5.

### PZ-5 — Il Consiglio leggibile, con la regola anti-passività

Il flusso della RoadMap, e la sua regola: se tutti si astengono, **succede
qualcosa comunque** — vantaggio al proponente, o Cicatrice automatica, o il Tema
resta caldo. Da scegliere e misurare.

**Fatto quando** il Consiglio cambia il significato delle Azioni già fatte, e
nessun Consiglio finisce senza lasciare traccia.

> **Fase A in 0.1.229** ([D-267](DECISIONS.md#d-267)): la forma del dibattito
> voluta dal committente — proponente → opportunità, **avversari → malus**: i
> pool del prezzo diventano menu di due voci e il primo OPPOSE dichiarato posa
> la pedina che decide quale scatta (44% dei Consigli su 100 semi). E la
> regola anti-passività, scelta fra le tre: **il silenzio avvantaggia il
> proponente** (+1 nei dati, 116 volte in 100 anni).
>
> **Fase B in 0.1.230** ([D-268](DECISIONS.md#d-268)), **e PZ-5 si chiude**:
> la controproposta del RIVENDICARE — pedina del prezzo scavalcando il primo
> OPPOSE, o voce del beneficio che a proposta passata **parla del
> rivendicante**; spendersi consuma il secondo dibattito. Il «fatto quando»
> tiene: le Azioni già fatte cambiano significato al Consiglio (presenze,
> carte, il RIVENDICARE stesso), e nessun Consiglio finisce senza traccia —
> Tensione mossa, una Conseguenza, il Ripple, e il silenzio ha una regola.
> Il costo dichiarato in D-268: i Consigli scendono a 3,6 di media, la
> taratura del «quando tenersi il secondo dibattito» è d'autore.
>
> **E poi PZ-5 si è riaperta due volte, perché il «fatto quando» non bastava.**
>
> **L'economia, in 0.1.264** ([D-280](DECISIONS.md#d-280)): il Consiglio non è
> più un menu di frasi d'autore ma un **vocabolario chiuso di caselle** — un
> beneficio è gratis, il tetto è tre, e le caselle si parametrizzano sulla
> carta. In 0.1.312 ([D-366](DECISIONS.md#d-366)) ogni casella impara a dire
> tutte e tre le cose: **cosa fa**, **su chi**, **dove**.
>
> **La moneta, in 0.1.353** ([D-387](DECISIONS.md#d-387), regola dettata dal
> committente): il secondo beneficio costa un **gettone RIVENDICARE**, preso
> giocando una carta Asset da quella faccia; un avversario ne spende uno per
> posare un costo, o si astiene. La misura che l'ha resa necessaria: prima, in
> 364 Consigli, **gli avversari sceglievano 34 prezzi** — 0,09 per Consiglio —
> e tutto il resto lo riempiva il mondo dall'alto della lista. Cioè la frase di
> D-267, *«avversari → malus»*, nei fatti non succedeva. Adesso sono **0,68 per
> Consiglio**.
>
> **Costo dichiarato:** i benefici comprati per Consiglio scendono da 1,71 a
> **1,40** — la moneta è poca, ed è [ISSUES 125](ISSUES.md#125).

### PZ-6 — Echo, Cicatrici, e il setup della Chronicle dopo

La procedura di fine Chronicle come sequenza fisica, eseguibile a mano.

**Fatto quando** la Chronicle successiva nasce dai segni visibili, e si può
rimontare il tavolo leggendo solo quello che c'è sopra.

> **Fatto in 0.1.231** ([D-269](DECISIONS.md#d-269)): la procedura sta in
> [PROCEDURA_FINE_CHRONICLE.md](PROCEDURA_FINE_CHRONICLE.md), sette passi a
> mano — e il «fatto quando» è **una prova**, non una promessa:
> `test_visible_handover.gd` eredita l'era nuova due volte, dal mondo intero
> e dal solo tavolo visibile (`visible_table.gd`, lista chiusa), e i due
> mondi devono nascere identici. Vale su CHR_01→CHR_02 e sulla saga pescata.

### PZ-7 — I Destini: 12, e nessuno che si avveri stando fermi

Sei condivisi, sei di Entità. Ognuno con Tema, tag osservati, e le tre righe
Minimum/Victory/Triumph leggibili.

**Fatto quando** `run_asking_probe.gd` dice che giocare rende **più** che stare
fermi, per ognuno dei dodici.

> **In 0.1.232** ([D-270](DECISIONS.md#d-270)): facce **23 su 23** (il
> sei-più-sei è superato dai fatti: otto case al tavolo pescato), sei
> condivisi che coprono i sei Temi, e la sonda per-Destino dentro
> `run_asking_probe`. Il criterio, misurato: **sul tavolo pescato 21 Destini
> su 22 chiedono di giocare** (pareggia solo NAHR); sull'anno scritto 17 su
> 22, e la coda — i Destini-custode — è taratura d'autore, coi numeri nel
> verbale. Lo strumento per chiuderla esiste e fa i nomi.
>
> **In 0.1.353 la coda è quasi finita: 22 Destini su 23 chiedono di giocare**,
> e l'unico che si avvera da fermi è `DST_SHARED_QUIET` — chiede che le
> questioni restino basse, e un tavolo che non fa niente le tiene basse per
> definizione. È lo stesso difetto dei tre obiettivi di §1.4, con la stessa
> cura: una clausola che chieda un gesto.
>
> E i **sei livelli di vittoria** che non nominavano nessun segno del mondo sono
> zero da [D-383](DECISIONS.md#d-383): i livelli che si reggono solo sul contare
> sono **11 su 69**, e sono tutti `minimum` — cioè soglie di sopravvivenza, non
> traguardi.

### PZ-8 — La UI come tavolo

Le cinque schermate della RoadMap: Mappa, Mano, Temi, Consiglio, Saga.

**Fatto quando** guardando lo schermo si capisce cosa esisterebbe sul tavolo — e
qui vale la regola §5ter di questo progetto: **nessuna misura copre quello che una
persona vede**. Va guardato su un iPad vero.

> **La parte misurabile in 0.1.233** ([D-271](DECISIONS.md#d-271)): le cinque
> schermate esistono e sono censite; le domande nuove del Consiglio (pedina,
> controproposta) arrivano al giocatore; il pannello del Destino legge le tre
> righe della carta (D-270). **Resta l'occhio**: il giro su iPad vero è del
> committente — §5ter non si chiude in headless.
>
> **Una misura, in 0.1.348** ([D-379](DECISIONS.md#d-379)): `MISURA_PAGINA.md`
> è il ventiseiesimo cancello, e dice **cosa la pagina chiede e con quale dito**
> — i testi che vivono solo nel suggerimento del mouse, i bersagli più stretti
> di un dito, i segni crudi finiti sotto gli occhi, e quanto la pagina chiede in
> confronto a un tablet.
>
> **La prima delle tre riviste, in 0.1.352** ([D-384](DECISIONS.md#d-384)):
> testi solo nel suggerimento del mouse **13 → 2**, bersagli sotto i 44 px
> **7 su 7 → 0**. È il bersaglio a crescere, non il testo.
>
> **Restano l'impaginazione** — 788 px in fila su un tablet da 768 — **e l'idea
> di cosa si guarda**: la mappa dipinge invece di costruire nodi, e nessun
> lettore di schermo la vede. Il committente le ha lasciate stare per adesso.
>
> **Le altre due, in 0.1.414** ([D-444](DECISIONS.md#d-444)): la pagina mostra
> il tavolo, non lo stato. Mappa e mazzetti costruiscono nodi — pannelli che
> dipingono **2 → 0** — la colonna di stato e il verbale sono pagine che si
> aprono al posto del tavolo, e la pagina chiede **678 px su 768** invece di
> 788 in fila. Resta l'occhio, com'era: il giro su iPad vero è del committente.

### PZ-9 — I validatori

I sette controlli che esistono, più i sei che la RoadMap chiede: luogo senza tag,
luogo senza funzione, Domanda senza Tema, Domanda senza tag e non marcata
generica, Destino che legge un tag inesistente, Echo senza effetto di setup.

**Fatto quando** nessun contenuto nuovo entra se produce tag muti o regole
invisibili — e il validatore **si è visto diventare rosso** su difetti piantati
apposta, perché una guardia che nessuno ha visto mordere non è una guardia.

> **Fatto in 0.1.234** ([D-272](DECISIONS.md#d-272)), coi sei riletti nel
> mondo di D-266 (la Domanda sta sulla Tensione): tessera senza segni,
> tessera che nessuno legge, Tensione senza domande, ponte delle domande
> rotto, Destino che osserva un segno fuori dal dizionario, Echo senza
> effetto. Self-test a **undici difetti piantati**, e la guardia si è vista
> mordere su ognuno — dati spediti puliti su tutti e sei prima ancora di
> scriverli.
>
> **In 0.1.353 i cancelli sono ventisei**, e `validate_physical.py` si vede
> mordere su **42 difetti piantati**. Fra i guardiani nuovi ce n'è uno che
> sorveglia i guardiani: `gates_survey.py` confronta la tabella di `CLAUDE.md`
> con la CI **nei due versi** — un cancello promesso e non girato non si
> lamenta, e uno girato e non promesso manda in rosso chi segue il documento.
>
> **E la lezione che questo passo ha pagato due volte** ([D-376](DECISIONS.md#d-376),
> [D-383](DECISIONS.md#d-383)): una guardia che **modella il motore diverso da
> com'è** sbaglia nei due versi. Prima ha lasciato passare otto gettoni che
> nessuno poteva posare; poi ha dichiarato non scrivibili tre segni che il gioco
> scrive 42, 43 e 145 volte, perché non sapeva delle caselle della Tensione né
> dei gradi delle Pietre.

---

## 3. Le milestone

### PZ-01 — una Chronicle demo giocabile

10 luoghi · 4 Entità · 6 Temi con Calore · 48 carte ri-mirate · 18 Domande · 12
Destini · Echo e Cicatrici · 3 Atti · Consiglio a fine Atto · setup esportabile.

**Fatto quando**, tutte e tre insieme:

1. dopo una partita si guarda la mappa e si capisce cosa è successo, cosa resta e
   quali Domande sono probabili dopo;
2. **meno della metà dei turni sono «passa»** (allora: 82,8%);
3. il playtest su 100 semi tiene **0 seggi bloccati su 8**.

> **Due su tre sono misurati e tengono** (0.1.358): i «passa» sono **47,6%** a
> tavolo misto e **47,9%** a uniforme, e il playtest su 100 semi tiene **0 seggi
> bloccati su 8 — sui due tavoli**. È il vincolo che non si negozia, e ogni
> decisione lo rifà.
>
> **Il primo non lo può dire una sonda**, ed è giusto così: *«si guarda la mappa
> e si capisce cosa è successo»* è un giudizio del committente su un tavolo vero.
> Quello che si può misurare intorno c'è: `MISURA_TAVOLO.md` dice quali segni
> arrivano posto per posto, `flusso.html` disegna chi mette cosa e chi la legge,
> `REVISIONE_TESTI.md` raccoglie i **2.968 testi** che un giocatore può leggere.

### PZ-02 — una mini-saga di tre Chronicle

**Fatto quando** la terza sembra figlia delle prime due; gli Echo hanno effetto e
non solo testo; le Entità si trasformano; le Domande non si ripetono uguali.

> **Tre delle quattro sono misurate** (0.1.353), su 12 saghe da 8 anni sui due
> tavoli — `run_saga.gd`, `run_inheritance_probe.gd`, `MISURA_VITE.md`:
>
> | | |
> |---|---|
> | salti d'era giocati | **168** |
> | **le Entità si trasformano** | **227 trasformazioni sedute** |
> | vite scritte che non si siedono mai | **1 su 18** |
> | l'Eredità ribalta il vincitore della saga | **10 saghe su 24** |
>
> Gli Echi hanno effetto da [D-355](DECISIONS.md#d-355): ogni carta Asset porta
> il suo, e si accende a segni. **«La terza sembra figlia delle prime due»**
> resta un giudizio, come il primo criterio di PZ-01 — ma il materiale c'è, e la
> saga si legge: `run_saga.gd` scrive un log per Chronicle e la mappa alla fine.

### PZ-03 — bilanciamento, quantità, durata, UI, print-and-play

**Non prima.** Con un'eccezione, ed è il punto 1.3: la ragione per agire non è
bilanciamento e non aspetta qui.

---

## 4. Cosa resta d'autore

Non le decido io, e la revisione nuova non può cominciare senza:

1. **Il Calore: quanto sale, quanto scende, e cosa fa se resta alto a fine
   Chronicle.** È il cuore del ritmo nuovo.
2. **La regola anti-passività del Consiglio**: quale delle tre.
3. **Cosa rende meglio agire che stare fermi**, nel modello nuovo — dopo la
   lezione del tavolo di pietra.
4. **I quattro luoghi nuovi**: cosa sono, e cosa portano che gli altri sei non
   hanno.
5. **Terra e Fede**: nel modello vecchio avevano una Tensione sola. Col Calore per
   Tema il problema cambia forma ma non sparisce — un Tema che nessuna carta
   scalda è un Tema che non si apre mai.

---

## 5. Come si lavora

Valgono le quattro regole di casa (vedi `CLAUDE.md`), e sopra tutte la domanda
della RoadMap, che va fatta a ogni modifica:

> **Questa cosa esisterebbe e sarebbe comprensibile sul tavolo fisico?**

Se la risposta è no, va ripensata.
