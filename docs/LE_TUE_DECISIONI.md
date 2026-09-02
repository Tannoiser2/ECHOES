# La lista che finisce

Domanda del committente, 0.1.361:

> *«Nessuna però deve portare ad altre issue. Perché qui ne chiudiamo una ma ne
> apriamo dieci. Questo giro deve finire e dobbiamo arrivare a un punto che sia
> giocabile. Da lì possiamo ripartire se servono aggiustamenti.»*

**Questa è quella lista.** Non è l'elenco di tutto quello che si può migliorare:
è l'elenco di quello che sta fra oggi e **una partita che si può giocare**.

## La regola che la fa finire

1. **Ogni riga di questa lista ha una fine scritta.** Non «migliora X»: *«fatto
   quando Y»*, e Y è una cosa che si misura o si guarda.
2. **Niente di quello che faccio qui apre una voce nuova.** Se una misura trova
   qualcosa, diventa **una riga sotto la voce che l'ha trovata**, non una voce
   con tre strade.
3. **Le rosse le sblocchi tu con una parola.** Ognuna ha la mia raccomandazione.
   Se non rispondi, faccio quella raccomandata e lo scrivo: **una decisione non
   presa è più cara di una decisione sbagliata**, perché il gioco resta fermo.

---

## Riscritta in 0.1.382, e non è un riordino: il conto era sbagliato

Hai detto che alcune cose scritte qui non erano vere. Le ho ricontrollate una per
una contro il testo delle voci e contro i numeri di oggi. **Ne ho trovate cinque**,
e la prima cambia la lista, non la sua forma.

### 1. «Dieci aspettano una tua decisione» — sono **quindici**

Il conto in fondo lo genera `tools/issues_survey.py`, e conta il **cartellino**
`da-decidere`. Ma cinque voci aperte dicono nel loro **«fatto quando»** che
aspettano te, e il cartellino non ce l'avevano:

| voce | quello che il suo testo dice |
|---|---|
| [80](ISSUES.md#80) | *«è la modifica che vale la parola del committente, non la mia»* |
| [87](ISSUES.md#87) | *«Tre letture, e la scelta è del committente»* — e lo dice due volte |
| [65](ISSUES.md#65) | *«Fatto quando c'è una decisione scritta su **quale** delle tre riviste si sta facendo»* |
| [82](ISSUES.md#82) | *«Fatto quando il committente ha scelto»* |
| [36](ISSUES.md#36) | *«Fatto quando il committente ha risposto alle cinque domande secche»* |

**Il cartellino adesso ce l'hanno**, e il conto qui sotto dice quindici da solo.
Non ho cambiato il criterio di nessuna: ho fatto seguire il cartellino al testo,
invece di leggere il conto e crederci.

### 2. Alla [87](ISSUES.md#87) avevo dato un criterio che non è il suo

Il gruppo G7 diceva *«fatto quando gli acquisti a vuoto sono sotto il 5%»*. Quel
numero non sta nella voce: la voce dice **tre letture, e la scelta è del
committente**. Avevo scritto una misura al posto di una parola — cioè avevo messo
nella colonna «mie» una cosa che non posso decidere. È l'errore che vale gli altri
quattro messi insieme, perché fa sembrare più corta la lista.

### 3. «Un anno intero senza mai un id» era più larga della misura

La prova guardava solo quello che il decider mette davanti a una persona. **Il
verbale no** — e il verbale sta sullo schermo, accanto alle domande. Ci stavano
otto righe su 584: *«presenza: REG_MINIERE_ANTICHE»*, *«CONFLUENCE
CNF_ANY_ANCIENT#3»*. Riparate le due sorgenti e allargata la prova in 0.1.382: ora
guarda domande **e** verbale, ed è zero.

### 4. e 5. Due numeri fermi

- V3 diceva **4.136 testi** in `REVISIONE_TESTI.md`. Oggi sono **4.172**.
- Il paragrafo finale diceva *«nove rosse, otto gialle, quattro verdi, ventuno
  righe»* quando due gialle si erano già chiuse e una rossa era stata aggiunta.
  Il totale in fondo non si aggiornava insieme alle righe sopra: adesso il totale
  è il conto generato, e non è più scritto a mano da nessuna parte.

---

<!-- CONTO: inizio - generato da tools/issues_survey.py -->

| | |
|---|---|
| voci scritte | **132** |
| chiuse | **105** |
| aperte | **27** |
| di cui **aspettano una tua decisione** | **13** |
| di cui sono mie da fare | **14** |

E il ritmo, voce per voce, per fascia di venticinque versioni:

| versioni | aperte | chiuse |
|---|---|---|
| 0.1.250–0.1.274 | 12 | 5 |
| 0.1.275–0.1.299 | 13 | 7 |
| 0.1.300–0.1.324 | 12 | 4 |
| 0.1.325–0.1.349 | 7 | 8 |
| 0.1.350–0.1.374 | 6 | 20 |
| 0.1.375–0.1.399 | 1 | 5 |

*(Conto generato da `tools/issues_survey.py`: i numeri 1, 2, 3, 4 sono usati due volte, in due milestone diverse; 67 voci non dicono a che versione si sono aperte.)*

<!-- CONTO: fine -->

---

## Come si legge, adesso

Non più per colore, ma per **chi la può muovere**. È l'unica domanda che serve a
te: se una riga aspetta una tua parola, il tempo che passa è tempo perso; se
aspetta me, non devi farci niente.

| | quante | chi la muove |
|---|---|---|
| 🔴 | **13** | **tu**, con una parola. Undici stanno sulla strada, due sono fuori |
| 🔵 | **2** | **una persona che gioca**. Non si misurano: si verificano giocando |
| 🟡 | **4** | **io**, da sola, senza aspettare niente |
| ⚫ | **2** | io, ma **dopo** una rossa: si chiudono con lei |
| ⚪ | **6** | nessuno, per adesso: sono fuori dalla lista finché non giochi |

**Quattro.** Delle ventisette voci aperte, quattro le posso muovere senza di te.
Questo è il numero che la lista di prima non diceva, e che va detto per primo:
**il giro non è fermo su di me, è fermo su tredici parole.**

---

# 🔴 Tredici aspettano te

Sotto ognuna: la domanda in una riga, il numero che la motiva, cosa farei io.

## Le undici che stanno fra oggi e una partita

### ✔ R1. [123](ISSUES.md#123) — decisa in 0.1.383: **(a)**, e dodici facce

Parola tua: **«R1 (a)»** ([D-412](DECISIONS.md#d-412)). ACQUISIRE alza una Pietra
dove hai presenza, e **dodici facce** la portano stampata, ognuna col nome della
Pietra che alza: al tavolo si prende il segnalino disegnato sulla carta.

Da **zero** Pietre alzate da un'Azione in cento partite a **190**. I «passa» da
49,6% a 46,1%. E la causa non era una taratura: **ACQUISIRE non era stampata su
nessuna delle 96 facce**.

**Resta aperta una riga della voce**, e aspetta ancora te: se la Pietra alzata da
un'Azione debba costare qualcosa oltre la carta. La misuro insieme alla
[119](ISSUES.md#119) — sono la stessa domanda vista da due parti.

### ✔ R2. [122](ISSUES.md#122) + [125](ISSUES.md#125) — chiuse in 0.1.388

Parola tua: **«due acquisti liberi, RIVENDICARE a 15»**, e poi **«undici»**
davanti ai numeri ([D-417](DECISIONS.md#d-417)).

I due acquisti liberi sono **il numero più redditizio di tutto il giro**:
benefici comprati per Consiglio da **1,22 a 2,25**, e la casella che nessuno
comprava da 22 a **83** acquisti su 700 offerte — da una su 32 a una su 8. Costa
niente: «passa» fermo al 46,1%, cancello 0 su 8 sui due tavoli.

**E il quindici l'ha corretto la misura.** Le quindici facce costano quasi sei
punti di «passa» (46,0% → 51,9%), perché quattro vanno tolte a verbi che il
cervello gioca. La compensazione esiste — abbassare la riserva della mano — ma
costa **venti Verità scritte su 158, il 13% della memoria del mondo**. Hai scelto
undici: il 92% del guadagno senza toccare né i turni né la memoria.

**Ha mosso anche due voci che aspettavano**: le Pietre alzate dal Consiglio da
148 a **211** ([111](ISSUES.md#111)), e il terzo pezzo della
[106](ISSUES.md#106) — la casella si compra perché adesso c'è la moneta.

### ✔ R3. [120](ISSUES.md#120) — decisa in 0.1.384: **sì**, e da otto ne resta uno

Parola tua: **«R3 sì»** ([D-413](DECISIONS.md#d-413)). Sette Obiettivi riscritti
sui segni della mappa: non *«due Regioni»* ma *«la Regione dove sta il Bosco»*.

Gli obiettivi che si reggevano **solo su un totale** da **otto su diciassette** a
**uno**. E le coppie che si contendono una Regione da 15,5% a **44,0%**: quasi
una su due, dove prima era una su sette. Questo è il numero che dice che
l'obiettivo adesso si può togliere all'avversario.

**Resta aperta una riga della voce**: i cinque che restano un'addizione pura sono
gli unici che una casa senza mappa può ancora vincere, e toglierli è una scelta
sul gioco, non una misura. Aspetta te.

### ✔ R4. [119](ISSUES.md#119) — fatta la raccomandata in 0.1.391: **(b)**

Hai detto *«passa alla prossima rossa»* senza rispondere, e vale la regola qui
sopra: **faccio quella raccomandata e lo scrivo** ([D-419](DECISIONS.md#d-419)).

Il gettone di rivendicazione adesso ha **due usi che si escludono**: su un costo
dice *«passi, ma paghi»*, speso contro dice *«questa non deve passare»* e pesa 1
nel margine.

**Il numero grosso non è quello che guardavo.** Le proposte che cadono salgono di
un quinto (33 → 39 sul tavolo misto), ma quelle che passano **in scioltezza**
scendono di un sesto (127 → 105). Il gettone contro raramente affonda una
proposta: molto più spesso la **ridimensiona**.

**Il peso 2 l'ho misurato, non stimato:** porta i FAILURE del tavolo misto da 39
a **55**, ma quelli dell'uniforme da 10 a **21** — quasi il triplo dello stato
spento. Il cancello tiene sui due tavoli, ma sull'uniforme si torna vicino al
difetto che D-378 aveva appena tolto: i Consigli che cadono per aritmetica
invece che per conflitto. Per questo ho lasciato **1**.

**Resta una riga, e aspetta te:** il segno di chi ha parlato e perso è passato da
6 a 8 su cento partite — un terzo in più, e ancora *una volta ogni dodici
partite*. I gettoni sono pochi e adesso hanno due usi in concorrenza. **Il
gettone contro deve pesare 1 o 2?** Oppure le facce RIVENDICARE devono diventare
più di undici?

### ✔ R5. [80](ISSUES.md#80) — decisa in 0.1.392: **il dado resta com'è**

Era l'unica rossa su cui non avevo una raccomandazione, e la parola è arrivata:
**il dado resta al centro** ([D-420](DECISIONS.md#d-420)). La sequenza A-K resta
intera, il World Factor resta nel margine, e l'economia le sta **accanto per
scelta**, non per lavoro non finito. **La voce si chiude** — le altre due parti
erano già fatte.

E la scelta il tavolo la sostiene: fra 0.1.353 e 0.1.391 l'economia ha smesso di
essere un contorno senza togliere di mezzo il dado — due acquisti liberi, il
gettone che compra il prezzo, e adesso quello che compra l'opposizione, che
**entra nel margine** insieme al dado invece che dopo.

### ✔ R6. [69](ISSUES.md#69) — fatta la raccomandata in 0.1.393: **il tarocco**

Hai scelto di andare avanti su questa senza rispondere alla domanda del formato,
e vale la regola qui sopra ([D-421](DECISIONS.md#d-421)). L'Eco segue le Asset,
perché da D-359 è un blocco stampato sulla stessa carta.

| mazzo asset, 48 facce | 63×88 | **70×120** |
|---|---|---|
| corpo rimpicciolito | **46 su 48** | **0 su 48** |
| la più stretta | 74% | **100%** |
| illustrazione media | 35% | **49%** |
| la più piccola | 34% — il pavimento | **43%** |

**E prima di cambiare ho scritto la misura**, che non esisteva: lo scheletro
delle carte diceva quali blocchi una carta porta, non se ci stanno. Adesso lo
dice chiamando la stessa funzione che disegna lo stampabile, ed è un cancello.

**Il costo, e va detto:** i fogli A4 da **49 a 67** (+37%), le Asset da sole da
15 a 33. E una mano da sette carte adesso è sette tarocchi — si è preferita una
carta che si legge a una mano che si maneggia. Se al tavolo la mano darà
fastidio più del testo stretto, tornare indietro è **una riga**.

### R7. [128](ISSUES.md#128) — il passare, e le carte che non sanno dire niente

**È tua, e l'hai aperta tu**: *«e se non ci fosse proprio la possibilità di
passare? O fai le azioni o giochi l'Eco. Non c'è provare.»*

Misurato: togliere il passare così com'è porta i «passa» da 45,2% a **36,1%** —
non a zero — e costa **il 42% della memoria del mondo** (Verità scritte 135 →
78). Ma la misura ha trovato la causa vera, e nessuno l'aveva mai presa: delle
carte che una casa ha **in mano**, il **59,3%** non si può calare, e **un turno
su quattro la mano è tutta muta** — lì passare non è una scelta.

E le mute sono due difetti opposti:

| delle mute | | |
|---|---|---|
| **il cervello non le vuole** | 82,3% | una scelta, non un difetto |
| **il tavolo non le prende** | 17,7% | le regole |

> **Farei la (1): il cervello accetta di farsi male quando non ha di meglio.**
> Le sue due prudenze — *INFLUENZARE solo nel verso giusto*, *FORGIARE solo in
> su* — valgono finché una mossa migliore esiste, e cadono quando non esiste. È
> una riga, non tocca nessuna regola del tavolo, e da sola dovrebbe recuperare i
> quattro quinti. Poi si guarda il quinto che resta, che è il difetto vero.

Le tre strade stanno per esteso nella voce. **Non l'ho fatta di mia iniziativa
perché cambia come si sente il turno**, e quello lo decidi tu.

### R8. [65](ISSUES.md#65) — quale delle tre riviste della pagina

Questa la credevo mia, e non lo è: il suo «fatto quando» chiede *«una decisione
scritta su **quale** delle tre riviste si sta facendo»*. La passata di
leggibilità l'ho fatta (0.1.376) ed è la prima delle tre. Le altre due non le
posso scegliere io.

> **Le tre, e sono davvero diverse:** (1) una passata di leggibilità — **fatta**;
> (2) un'altra **disposizione** della pagina, cioè dove stanno le cose; (3)
> un'altra idea di **cosa si guarda** — l'app smette di mostrare lo stato e
> mostra il tavolo.
>
> **Farei la (3)**, perché è quella che la direzione di 0.1.218 chiede: *un gioco
> da tavolo con un'app di supporto*. Ma è la più cara delle tre, ed è per questo
> che non la comincio da sola.

Va insieme alla 🔵 [63](ISSUES.md#63) qui sotto: quella la verifichi giocando,
questa la decidi prima.

### R9. [87](ISSUES.md#87) — le frasi d'autore contro le caselle del prezzo

Fra le Conseguenze spedite, **67 Effetti d'autore fanno esattamente quello che le
caselle del prezzo fanno**. Il danno ha un numero: **il 24% dei benefici comprati
non lascia niente**, perché la frase l'aveva già fatto gratis. Il taglio A ha
portato gli acquisti a vuoto dal 24% al 9%, poi risaliti all'11%.

> **Farei la (3): si tiene così e si dichiara.** La sovrapposizione è voluta, chi
> compra compra la certezza, e il verbale già lo dice — *«e non lascia niente:
> era già così»*. La (1) è la direzione di D-280 portata fino in fondo e costa
> **67 Effetti da riscrivere**; la (2) è una regola nuova da spiegare al tavolo.

**Questa era la voce che avevo messo fra le mie con un criterio inventato.** La
voce dice tre letture e la scelta è tua, e lo dice due volte.

### R10. [100](ISSUES.md#100) — le caselle «SI ACCENDE QUANDO»

Le 46 facce che dicono quando una Tensione si scalda sono ancora **derivate**:
le calcola il motore invece di leggerle dalla carta. Al tavolo fisico quella
riga o è stampata o non esiste.

> **Farei: si stampano come stanno.** Il motore le genera già bene; si
> congelano nel dato, e da lì si correggono a mano quelle che suonano male. È
> una tua parola perché sono **quarantasei frasi che un giocatore legge**.

### R11. [124](ISSUES.md#124) — le due case che non possono vincere l'Eredità

L'Eredità (+3 per ogni leggenda che porta il tuo nome, tua parola in 0.1.353) è
**strutturalmente zero** per due case su otto: il loro profilo non ha una voce
che una leggenda possa portare.

> **Farei: si scrive quella voce.** Due righe di dato, mezz'ora, e nessuna regola
> cambia. La metto rossa solo perché è **cosa vogliono quelle due case**, e
> questo lo decidi tu.

### R12. [64](ISSUES.md#64) — una saga ricambia metà tavolo

Fra un anno e l'altro di una saga **metà dei seggi cambia casa**, e nessuno ha
mai deciso che dovesse. O è la cosa giusta — le case passano, il mondo resta — o
è un difetto.

> **Farei: è giusto, e si dichiara.** È il gioco che hai voluto: *le Azioni
> cambiano il mondo, il Consiglio decide cosa il mondo ricorderà*. Ma va scritto
> sulla scatola, non lasciato succedere.

### R13. [127](ISSUES.md#127) — la tessera si gira, e l'arte si gira con lei

Da D-390 una tessera si posa **ruotata**, perché i varchi combacino. Un
disegno ha un alto e un basso.

> **Farei (2): l'arte disegna tutti e quattro i varchi, e i lati chiusi si
> coprono con un gettone.** Allargati i varchi a trentotto su quaranta (D-393)
> questo costa **un gettone su una tessera sola** — l'Isola Muta — e l'arte non
> gira mai. Va deciso **prima** di commissionare i disegni, ed è per questo che
> è qui.

## Le due che aspettano te, ma non stanno sulla strada

Aspettano una tua parola come le altre tredici, ma **nessuna delle due sta fra
oggi e una partita giocabile**: se non rispondi, il giro finisce lo stesso.

| voce | cosa aspetta | perché può aspettare |
|---|---|---|
| [82](ISSUES.md#82) — la coda della fustella | *«il committente ha scelto»* fra tenere e potare le Cicatrici rare | è una potatura di **componenti**: si fa quando la scatola si stampa, non prima |
| [36](ISSUES.md#36) — il generatore di linee | le tue cinque risposte secche su come si permutano Destini, ruoli e incarnazioni | è un **gioco nuovo dentro il gioco**. Dopo la prima partita |

---

# 🔵 Due aspettano una partita, non una misura

Queste due non le posso chiudere io **per come sono scritte**, e non perché mi
manchi il tempo: il loro criterio nomina una persona che gioca.

### [63](ISSUES.md#63) — l'app è un prototipo giocabile?

> *«Fatto quando una persona può giocare un anno intero senza che nessuno le
> spieghi cosa fanno i bottoni, perché non ci sono bottoni da spiegare.»*

**Quello che si poteva misurare, è misurato.** Il motore chiede qualcosa a una
persona in **dieci punti**, contati sul codice, e da 0.1.378 ognuno ha una prova
che parte dal decider e finisce su quello che si tocca. Da 0.1.382 una prova
gioca **un anno intero** e non trova un id — né nelle domande né nel verbale.
Il gesto sul tablet è in due tempi (tocca la carta, si accende dove può andare,
tocca il posto), perché il trascinamento sul dito non esiste.

**Quello che resta non è una misura: è aprire l'app e giocarci un anno.** Se
dopo quell'ora la voce è ancora aperta, sarà aperta su una cosa vista, che è
un'altra voce e un altro giro.

### [67](ISSUES.md#67) — la saga arriva in fondo?

> *«Fatto quando una saga arriva almeno al terzo anno su un tablet.»*

*«La saga si ferma alla seconda partita»* — parola tua, e la causa **non è mai
stata riprodotta**. Il motore gira pulito per quattro anni di fila in headless:
il difetto, se c'è, è nello schermo, e nessuna prova headless lo può toccare.
La cosa onesta da dire è che **non so se questa voce sia ancora vera**.

---

# 🟡 Le quattro che sono mie, e non aspettano niente

Le faccio in quest'ordine. Nessuna apre una voce nuova.

### M1. [56](ISSUES.md#56) — nove Conseguenze su sessantacinque non escono mai

Erano undici, e il numero è sceso perché sono state rimisurate **in saga**, dove
cinque di loro possono uscire: chiedono una leggenda o un'era precedente, e in
cento anni scollegati non potevano nemmeno salire su una scheda.

Delle nove, **sette hanno un tentativo solo o poco più**: un aneddoto, non un
verdetto. L'unica con abbastanza casi è `CNS_COST_DEBT`, la cui proposta è stata
scelta 9 volte su 9 e non è mai passata.

**Fatto quando** ogni Conseguenza esce almeno una volta su 200 anni, **o esce
dalla scatola**. Le tolgo, non le riscrivo tre volte.

### M2. [59](ISSUES.md#59) — il verbo che nessuno gioca

La voce era su tre difetti e **due sono spariti da soli**: FORGIARE e TRAMARE
non sono più i verbi morti (8,4% e 9,9% → 52,4% e 75,6%), WEALTH non è più la
famiglia inerte (3,1× → 1,17×), e le carte mai calate sono passate da quattro a
una.

**Il difetto adesso si chiama INFLUENZARE**: il verbo meno giocato (18,5%) e la
moneta più votata, con quasi metà delle sue carte che non fa niente.

**Fatto quando** nessun verbo si gioca meno della metà del più giocato, e ogni
carta viene calata per agire almeno una volta in cento anni.

### M3. [60](ISSUES.md#60) — lo scarto fra la domanda più e meno ascoltata

Rimisurata in 0.1.377, e **dice un'altra cosa di quando è stata scritta**. Le
domande erano dodici, sono sessanta: le mute sono passate da una su dodici a
**una su sessanta** (*I Recinti*), ma lo scarto fra la più e la meno ascoltata è
passato da 3,5× a **13,1×**.

E il suo criterio scritto **non è più raggiungibile per aritmetica**: chiede che
nessuna resti senza Consiglio in più di un quarto degli anni in cui è in gioco, e
con 3,58 Consigli l'anno su sessanta domande la più ascoltata del tavolo arriva
al 62,5%. **Il criterio va ritagliato prima di lavorarci** — zero domande mute, e
lo scarto sotto un fattore da decidere. Il numero da battere è **13,1×**.

### M4. [106](ISSUES.md#106) — la pedina non porta con sé il nome della domanda

«La sceglie chi propone», ma la pedina muove solo la domanda in discussione: è il
beneficio meno interessante che si possa offrire, e infatti la casella è comprata
**una volta su settantadue**. Copre 59 applicazioni su 90.

**Fatto quando** un proponente può posare la pedina su una domanda che nomina, il
verbale dice quale, e la sonda delle caselle mostra se la casella smette di essere
quella che nessuno compra.

---

# ⚫ Le due che sono mie, ma dopo una tua parola

Non sono in attesa di lavoro: sono in attesa che una rossa si sblocchi. Se la
rossa passa, queste si chiudono **con lei**, e probabilmente da sole.

### [111](ISSUES.md#111) — le Pietre che non si alzano mai → chiude con **R1**

E adesso si sa che **non dipende da una riga di dati**: i tre gradi consumati che
restano hanno ognuno la sua Conseguenza, che mira nel posto giusto — verificato
prima di cambiare la mira, e la mira era già buona. La causa è la stessa della
M1: **quelle proposte il cervello non le compra mai**, perché nessuna Azione
della plancia alza una Pietra.

### [4](ISSUES.md#4) — gli obiettivi non si incrociano → chiude con **R3**

**Rimisurata oggi, e metà del suo criterio è soddisfatta.** La voce chiedeva
*«le Regioni contese a fine anno sono più di tre su sei e il padrone cambia mano
più di tre volte l'anno, col playtest ancora 0/8»*. Su 100 partite CHR_00 a
tavolo misto, seme 7000:

| | chiedeva | oggi | |
|---|---|---|---|
| Regioni contese a fine anno | > 3 su 6 | **3,40 su 6** | ✅ |
| il padrone passa di mano | > 3 volte l'anno | **3,75 volte** | ✅ |
| playtest | 0 su 8 | **0 su 8** | ✅ |
| obiettivi contesi | ≥ un terzo del mazzo | **3 su 15** | ❌ |

Le tre righe sulla mappa sono passate. La quarta è **esattamente la R3**: un
obiettivo che si vince contando non lo si può contendere. Chiudi quella e questa
si chiude con lei — e con lei la [91](ISSUES.md#91).

---

# ⚪ Sei fuori dalla lista, finché non giochi

Non perché non valgano: perché **ognuna di queste è un gioco nuovo**, e aprirla
adesso è esattamente il giro che vuoi chiudere. Restano scritte dove sono.

| | perché è fuori |
|---|---|
| [98](ISSUES.md#98) — ogni segno dichiara se pesa o se è colore | è un **metodo**, non una cosa: genera lavoro all'infinito. La sua metà utile era il gruppo dei segni, e quello è finito in 0.1.363 |
| [39](ISSUES.md#39) — le strutture con una vita (torre → castello → reggia) | tua idea grossa, e tocca la plancia. Dopo R1, che tocca la plancia anche lui |
| [47](ISSUES.md#47) — le carte come unica moneta | tua idea grossa: riscrive l'economia del turno |
| [50](ISSUES.md#50) — quattro obiettivi al posto dei tre gradini | tua idea grossa, e R3 la anticipa in parte |
| [27](ISSUES.md#27) — il tavolo sullo schermo grande e le console in tasca | milestone 0.6, e ha bisogno che l'app della 63 esista prima |
| [91](ISSUES.md#91) — i punti già veri all'apertura, **48,4% oggi** | **la sua cura è R3**. Si rimisura dopo, e probabilmente si chiude da sola. Sotto la metà per la prima volta — ma il 60,5% con cui è nata è misurato su un altro tavolo, e i due numeri non stanno in fila ([D-391](DECISIONS.md#d-391)) |

---

# E una cosa che non è una voce: l'arte

**144 illustrazioni su 155 sono ancora un segnaposto** (`docs/COMPONENTI.md`). I
prompt sono tutti scritti, e generati dai dati veri. È lavoro meccanico, e va
**dopo R6 e R12**, che decidono il formato di una carta e come si disegna una
tessera. Non è nella lista perché non è una voce: è la scatola.

---

## Come finisce

**Il conto in cima è generato**, e non lo riscrivo a mano da nessuna parte: era
il quinto degli errori, ed era di forma. Un totale scritto a mano invecchia il
giorno dopo, e questo era invecchiato di tre righe.

**Quello che resta da dire in una riga:** delle ventisette voci aperte ne posso
muovere **quattro** da sola. Due le verifica una persona che gioca, due si
chiudono dietro una rossa, sei stanno fuori dalla lista, e **tredici aspettano
una tua parola**.

Se una rossa non arriva, faccio la raccomandata e la segno come *fatta sulla mia
parola*, così non è il gioco a stare fermo ad aspettare. **Tranne la R5**: quella
non ha una raccomandazione, perché la voce dice che non è mia da dare.
