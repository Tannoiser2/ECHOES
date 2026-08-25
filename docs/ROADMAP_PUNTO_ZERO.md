# ROADMAP — Punto Zero fisico-first

Fusione fra la RoadMap del committente e quello che questo progetto ha già
misurato. Dove le due divergono, la divergenza è scritta con il numero che la
motiva: **un numero peggiorato e scritto vale più di un numero nascosto**.

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

Parte di questo **esiste già e ha un cancello in CI**: 6 Temi come dato, 48 carte
su 48 con faccia fisica e Risonanza che il motore esegue davvero, 12 Domande
fisiche legate ai Consigli da cui nascono, 8 Destini su 20 con faccia,
`tools/validate_physical.py` con sette controlli. Vedi
[PUNTO_ZERO.md](PUNTO_ZERO.md).

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

---

## 3. Le milestone

### PZ-01 — una Chronicle demo giocabile

10 luoghi · 4 Entità · 6 Temi con Calore · 48 carte ri-mirate · 18 Domande · 12
Destini · Echo e Cicatrici · 3 Atti · Consiglio a fine Atto · setup esportabile.

**Fatto quando**, tutte e tre insieme:

1. dopo una partita si guarda la mappa e si capisce cosa è successo, cosa resta e
   quali Domande sono probabili dopo;
2. **meno della metà dei turni sono «passa»** (oggi: 82,8%);
3. il playtest su 100 semi tiene **0 seggi bloccati su 8**.

### PZ-02 — una mini-saga di tre Chronicle

**Fatto quando** la terza sembra figlia delle prime due; gli Echo hanno effetto e
non solo testo; le Entità si trasformano; le Domande non si ripetono uguali.

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
