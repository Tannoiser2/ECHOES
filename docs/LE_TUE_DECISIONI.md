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

## 0.1.397 — hai risposto a tutte e dodici, e questa smette di essere una lista di domande

*«Sì a tutte»*, in tre parole ([D-427](DECISIONS.md#d-427)). Delle dodici rosse
**quattro voci si sono chiuse** — la Pietra costa la carta e basta, i cinque
Obiettivi che sono un conto puro restano, il gettone contro pesa 1, la
sovrapposizione fra frasi d'autore e caselle è voluta — e **otto sono passate fra
le mie**, perché quello che gli mancava era una parola e adesso è un lavoro.

**Il numero che conta è questo: da ventisei voci aperte di cui dodici ferme su di
te, a ventidue di cui nessuna.** La lista non è più corta perché ho lavorato: è
più corta perché hai deciso, ed è il tipo di accorciamento che *«questo giro deve
finire»* chiedeva.

Da qui in avanti questo foglio è un **elenco di lavori con un ordine**, non un
elenco di domande. Se una rossa nuova nasce, nasce in cima, e lo strumento dei
cancelli va rosso se non le do una casa.

---

## 0.1.398–0.1.405 — le tredici «M» sono passate, e ne resta una

Otto versioni, otto verbali, otto PR. **Delle quattordici righe di lavoro che
la tua parola aveva creato, tredici sono state percorse**: sei voci si sono
chiuse, quattro sono uscite dalla lista o hanno cambiato casa, tre restano
aperte con la causa finalmente scritta giusta. La quattordicesima — l'app che
mostra il tavolo — è quella che apriremo dopo, ed è la più cara di tutte.

| | voce | dove è finita |
|---|---|---|
| **M5** | [128](ISSUES.md#128) | lavorata in 0.1.398 — e **la proposta che avevi avallato era sbagliata**: la parete non erano i bersagli ([D-428](DECISIONS.md#d-428)); ✔ **chiusa** in 0.1.409 |
| **M6** | [100](ISSUES.md#100) | ✔ **chiusa** in 0.1.400 — le 46 righe si stampano come le genera il motore |
| **M7** | [127](ISSUES.md#127) | ✔ **chiusa** in 0.1.399 — quattro varchi disegnati, i chiusi li copre un gettone |
| **M8** | [64](ISSUES.md#64) | ✔ **chiusa** in 0.1.401 — chi siede l'anno prossimo è una regola scritta |
| **M9** | [69](ISSUES.md#69) | ✔ **chiusa** in 0.1.402 — la carta Tensione dice su cosa si discute |
| **M10** | [82](ISSUES.md#82) | lavorata in 0.1.403 — il motore la fame la sapeva solo togliere ([D-433](DECISIONS.md#d-433)); ✔ **chiusa** in 0.1.407 per misura |
| **M11** | [36](ISSUES.md#36) | percorsa in 0.1.404, e la voce esce fra le ⚪: il resto lo guardi tu, dopo una partita |
| **M12** | [111](ISSUES.md#111) | rimisurata in 0.1.405 — **resta aperta**, ma le due cause scritte sono cadute e la vera è misurata |
| **M13** | [4](ISSUES.md#4) | ✔ **chiusa** in 0.1.405 — gli obiettivi si incrociano, e il conto non si scrive più a mano |
| **M14** | [65](ISSUES.md#65) | **da fare**, e va per ultima: ha bisogno che il resto sia fermo |

**M1**, **M2**, **M3** e **M4** — le quattro di prima — non sono state toccate in
questo giro e restano fra le mie. La **M3** ha un debito noto: **il suo criterio
va ritagliato prima di lavorarci**, perché per aritmetica non è raggiungibile.

E quello che il giro è costato, in una riga: **il cancello 0 su 8 non si è mai
rotto**, su tavolo misto e uniforme, in nessuna delle otto versioni.

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
| chiuse | **122** |
| aperte | **10** |
| di cui **aspettano una tua decisione** | **0** |
| di cui sono mie da fare | **10** |

E il ritmo, voce per voce, per fascia di venticinque versioni:

| versioni | aperte | chiuse |
|---|---|---|
| 0.1.250–0.1.274 | 12 | 6 |
| 0.1.275–0.1.299 | 13 | 7 |
| 0.1.300–0.1.324 | 12 | 4 |
| 0.1.325–0.1.349 | 7 | 8 |
| 0.1.350–0.1.374 | 6 | 20 |
| 0.1.375–0.1.399 | 1 | 6 |

*(Conto generato da `tools/issues_survey.py`: i numeri 1, 2, 3, 4 sono usati due volte, in due milestone diverse; 67 voci non dicono a che versione si sono aperte.)*

<!-- CONTO: fine -->

---

## Come si legge, adesso

Non più per colore, ma per **chi la può muovere**. È l'unica domanda che serve a
te: se una riga aspetta una tua parola, il tempo che passa è tempo perso; se
aspetta me, non devi farci niente.

<!-- COLORI: inizio - generato da tools/issues_survey.py -->

| | quante | chi la muove |
|---|---|---|
| 🔴 | **nessuna** | **tu** — e oggi non c'è niente che aspetti una tua parola |
| 🔵 | **2** | **una persona che gioca**. Non si misurano: si verificano giocando |
| 🟡 | **1** | **io**, da sola, senza aspettare niente |
| ⚪ | **7** | nessuno, per adesso: sono fuori dalla lista finché non giochi |

**Una.** Delle dieci voci aperte, una le posso muovere senza di te — ed è il
numero che va detto per primo. **Il giro non è fermo su nessuna tua parola.**

<!-- COLORI: fine -->

---

# 🔴 Aspettano te: **nessuna**

**Per la prima volta da quando questa lista esiste, non c'è niente di rosso.** In
0.1.397 hai risposto a tutte e dodici con una parola sola — *«sì a tutte»* — e
questo è dove sono finite ([D-427](DECISIONS.md#d-427)):

| | voce | cosa hai detto | dov'è finita |
|---|---|---|---|
| R1 | [123](ISSUES.md#123) | la Pietra alzata da un'Azione costa la carta, e basta | **chiusa** |
| R3 | [120](ISSUES.md#120) | i cinque Obiettivi che sono un conto puro restano | **chiusa** |
| R4 | [119](ISSUES.md#119) | il gettone contro pesa **1**, e le facce restano undici | **chiusa** |
| R9 | [87](ISSUES.md#87) | la sovrapposizione è voluta: si tiene e si dichiara | **chiusa** |
| R6 | [69](ISSUES.md#69) | il formato era già deciso: il resto è lavoro mio | 🟡 **M9** |
| R7 | [128](ISSUES.md#128) | si allargano i bersagli murati, e il passare resta | 🟡 **M5** |
| R8 | [65](ISSUES.md#65) | la **(3)**: l'app mostra il tavolo, non lo stato | 🟡 **M14** |
| R10 | [100](ISSUES.md#100) | le 46 righe si stampano come le genera il motore | 🟡 **M6** |
| R12 | [64](ISSUES.md#64) | la saga ricambia i seggi ed è giusto: si scrive | 🟡 **M8** |
| R13 | [127](ISSUES.md#127) | **(2)**: quattro varchi disegnati, i chiusi coperti | 🟡 **M7** |
| — | [82](ISSUES.md#82) | non si pota niente: il buco sono le condizioni | 🟡 **M10** |
| — | [36](ISSUES.md#36) | la **(D)** adesso, il resto dopo la prima partita | **percorsa**, poi ⚪ |

*(Questa tabella è un riepilogo, non una casa: ognuna di quelle voci vive sotto il
suo colore, e da 0.1.397 lo strumento va rosso se una voce prova ad abitare in due
posti — vedi [D-427](DECISIONS.md#d-427).)*

**Quello che questo cambia, ed è la cosa che chiedevi:** il giro non è più fermo
su di te. Delle diciassette voci ancora aperte non ce n'è **nessuna** che aspetti
una tua parola — le due 🔵 aspettano una partita, non una decisione. Se una rossa
nasce di nuovo, nasce qui.

---

# 🔵 Aspettano una partita e non una misura: **due**

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

# 🟡 Sono mie, e non aspettano niente: **una**

Erano quattordici in 0.1.397, dieci arrivate qui dalle rosse
([D-427](DECISIONS.md#d-427)). Sei si erano chiuse e una era uscita dalla lista
entro 0.1.405; **le sette che restavano si sono chiuse in 0.1.407–0.1.413**, su
parola tua — *«vai con M»* — una versione per M, ognuna col suo verbale e col
cancello 0 su 8 rimisurato. **Nessuna ha aperto una voce nuova.** Resta la
quattordicesima, che va per ultima da sempre.

**Quello che resta:**

| | perché, e a che punto è |
|---|---|
| **M14** — [65](ISSUES.md#65), l'app che mostra il tavolo | **la più cara di tutte, e adesso tocca a lei**: aspettava che carte, tessere e faccia della Tensione fossero ferme, e adesso lo sono. È la prossima sessione |

### ✔ M1. [56](ISSUES.md#56) — nove Conseguenze su sessantacinque non escono mai: **chiusa in 0.1.410**

**Chiusa in 0.1.410** ([D-440](DECISIONS.md#d-440)): rimisurate su 200 anni in
saga erano **sei**. Tre sono uscite dalla scatola, e con loro **#requisito**;
tre restano con la ragione scritta — l'unica strada di una domanda, e le due
porte delle Cicatrici rare che hai deciso di tenere. Su due semi ne restano
quattro a zero, e non le stesse quattro: a 200 anni il criterio misura il seme.


Erano undici, e il numero è sceso perché sono state rimisurate **in saga**, dove
cinque di loro possono uscire: chiedono una leggenda o un'era precedente, e in
cento anni scollegati non potevano nemmeno salire su una scheda.

Delle nove, **sette hanno un tentativo solo o poco più**: un aneddoto, non un
verdetto. L'unica con abbastanza casi è `CNS_COST_DEBT`, la cui proposta è stata
scelta 9 volte su 9 e non è mai passata.

**Fatto quando** ogni Conseguenza esce almeno una volta su 200 anni, **o esce
dalla scatola**. Le tolgo, non le riscrivo tre volte.

### ✔ M2. [59](ISSUES.md#59) — il verbo che nessuno gioca: **chiusa in 0.1.412**

**Chiusa in 0.1.412** ([D-442](DECISIONS.md#d-442)): il libro mastro dice che una
carta si spende per agire *oppure* si impegna al voto, e contando i due modi
nessun verbo sta sotto la metà del più spesa — INFLUENZARE al 59,9% contro
l'89,2% di MUOVERE, ed è la moneta più votata. Zero carte mai calate. La lettura
stretta (30,0% di sole calate, per la quota di una per giro) è scritta accanto.


La voce era su tre difetti e **due sono spariti da soli**: FORGIARE e TRAMARE
non sono più i verbi morti (8,4% e 9,9% → 52,4% e 75,6%), WEALTH non è più la
famiglia inerte (3,1× → 1,17×), e le carte mai calate sono passate da quattro a
una.

**Il difetto adesso si chiama INFLUENZARE**: il verbo meno giocato (18,5%) e la
moneta più votata, con quasi metà delle sue carte che non fa niente.

**Fatto quando** nessun verbo si gioca meno della metà del più giocato, e ogni
carta viene calata per agire almeno una volta in cento anni.

### ✔ M3. [60](ISSUES.md#60) — lo scarto fra la domanda più e meno ascoltata: **chiusa in 0.1.413**

**Chiusa in 0.1.413** ([D-443](DECISIONS.md#d-443)): il criterio è ritagliato per
Tema, che è quello che il contenuto governa — quale domanda si apre è la sorte
del mazzetto. Con una Risonanza spostata verso Terra nessun Tema apre meno della
metà dei Consigli del più aperto, su due semi, e nessuna domanda è muta su tutti
e due. Lo scarto fra due domande resta scritto come osservazione.


Rimisurata in 0.1.377, e **dice un'altra cosa di quando è stata scritta**. Le
domande erano dodici, sono sessanta: le mute sono passate da una su dodici a
**una su sessanta** (*I Recinti*), ma lo scarto fra la più e la meno ascoltata è
passato da 3,5× a **13,1×**.

E il suo criterio scritto **non è più raggiungibile per aritmetica**: chiede che
nessuna resti senza Consiglio in più di un quarto degli anni in cui è in gioco, e
con 3,58 Consigli l'anno su sessanta domande la più ascoltata del tavolo arriva
al 62,5%. **Il criterio va ritagliato prima di lavorarci** — zero domande mute, e
lo scarto sotto un fattore da decidere. Il numero da battere è **13,1×**.

### ✔ M4. [106](ISSUES.md#106) — la pedina non porta con sé il nome della domanda: **chiusa in 0.1.408**

**Chiusa in 0.1.408** ([D-438](DECISIONS.md#d-438)): il cervello pesa la casella
su ogni segnalino in tavola e posa la pedina sul migliore, l'hotseat chiede *«su
quale domanda?»*, e la sonda vede il gesto: **91 acquisti su 728** offerte (era
22 su 700), **17** su una domanda indicata col dito. Cancello 0 su 8.


«La sceglie chi propone», ma la pedina muove solo la domanda in discussione: è il
beneficio meno interessante che si possa offrire, e infatti la casella è comprata
**una volta su settantadue**. Copre 59 applicazioni su 90.

**Fatto quando** un proponente può posare la pedina su una domanda che nomina, il
verbale dice quale, e la sonda delle caselle mostra se la casella smette di essere
quella che nessuno compra.

### ✔ M5. [128](ISSUES.md#128) — le carte murate: **chiusa in 0.1.409**

**Chiusa in 0.1.409** ([D-439](DECISIONS.md#d-439)): la sonda ha imparato a
distinguere una carta che non arriva *su quella tessera* da una che non arriva
*su nessuna*, e la seconda — la sola che il criterio chiede a zero — è **0 su
1.882** rifiuti in cento anni. I 109 «a segni» sono tutti «non qui, altrove sì».


**Parola tua: sì.** Il passare non si toglie — toglierlo costa il **42% della
memoria del mondo** e non porta i «passa» a zero, li porta a 36,1%.

> **Al tavolo.** Hai sette carte in mano e non ne puoi calare nessuna. Dici
> *«passo»*, e non è una scelta.

**E la proposta che avevi avallato era sbagliata** ([D-428](DECISIONS.md#d-428)).
Dicevo *«allargo i bersagli»* dando per scontato che la parete fosse un problema
di bersagli. Ho fatto dire alla sonda **perché** il tavolo rifiuta una carta, e
quattro quinti della parete sono **le regole che fanno quello per cui sono
scritte**: la quota di INFLUENZARE una per giro, i segni che vietano, il
Consiglio che si forza una volta per giro, il prezzo in carte.

**Ma il quinto vero era peggio:** tre Regioni della mappa non le raggiungeva quasi
nessuno — L'Isola Muta **7 carte su 30**, il Bosco 8, le Montagne Rosse 8, contro
le 28 di Eredan. Le Regioni civili portano tre segni di dominio, quelle selvatiche
uno.

| 100 partite, tavolo misto | prima | **dopo** |
|---|---|---|
| il tavolo non le prende | 12,7% | **11,0%** |
| di cui **il bersaglio a segni** | 246 eventi | **78** |
| carte diverse murate | 35 | **23** |
| L'Isola Muta la raggiungono | 7 su 30 | **8** |
| Montagne Rosse | 8 | **12** |
| turni «passa» | 40,8% | **40,1%** |

**Il costo, e non è zero:** sul tavolo misto gli esiti scendono di un gradino —
DECISIVE **114 → 105** — e le Verità scritte **146 → 142**. Più carte giocabili
vuol dire più case che agiscono e più proposte contestate. Cancello 0 su 8.

**Il criterio che avevo scritto era rotto.** Dicevo *«sotto il 5%»*: non ci si
arriva, perché oltre il 90% di quell'11,0% sono regole volute. È lo stesso errore
della M3.

**Fatto quando** nessuna carta è murata da un bersaglio a segni che la mappa non
porta. Ne resta una famiglia sola — *Diritto di Ospitalità*, che rifiuta i luoghi
contesi **per come è scritta**: non è un difetto, è la carta.

> **E una cosa aspetta te, ed è l'unica che muoverebbe ancora il numero.** Il
> **61,2%** della parete cade sulle **diciotto carte che stampano lo stesso verbo
> su tutte e due le facce** (nove INFLUENZARE, otto FORGIARE, una TRAMARE):
> quando quel verbo è bloccato, la carta muore intera perché non ha una seconda
> strada. `CLAUDE.md` lo chiede già — *«due Azioni, e due scelte diverse
> davvero»* — e dargliela **cambia cosa fa la carta**: è una scelta d'autore, non
> una taratura.

### ✔ M6. [100](ISSUES.md#100) — le 46 righe «SI ACCENDE QUANDO»

**Fatta in 0.1.400** ([D-430](DECISIONS.md#d-430)).

> **Al tavolo.** Giri la Tensione *«I Voti Non Sciolti»* e in basso c'è scritto
> **quando** quella carta si scalda: *«due case scendono a nemiche · qualcuno
> posa il #lutto»*. Prima quella riga non c'era: la carta si scaldava e non lo
> diceva da nessuna parte.

| 100 anni, seme 7000 | prima | **dopo** |
|---|---|---|
| **Tensioni con la casella «si accende»** | **47 su 60** | **60 su 60** |
| righe nei dati | 66 | **92** |
| di cui scritte a mano | 4 | **92** |

Tre cose in una: **62 righe riscritte** una per una (la condizione non si tocca,
cambia la frase che si legge), **il verbo dei rapporti** — `SET_RELATION` esce
159 volte su vent'anni e nessuna riga poteva nominarlo — e **le tredici caselle**
che mancavano, sei delle quali usano il verbo nuovo.

**Il costo, e i due tavoli non dicono la stessa cosa:** sul misto le Verità
scritte scendono da **142 a 135**, sull'uniforme salgono da **134 a 141**. Più
questioni sveglie vuol dire più Consigli che passano puliti, e un successo che
non costa niente lascia meno memoria. I due numeri non si sommano: questa
modifica **avvicina i due tavoli** invece di spostarli insieme. Cancello 0 su 8.

### ✔ M7. [127](ISSUES.md#127) — quattro varchi disegnati, e un gettone

**Fatta in 0.1.399** ([D-429](DECISIONS.md#d-429)), ed era quella con la
scadenza: andava chiusa **prima** di commissionare i disegni.

Ogni tessera si illustra adesso con la strada che arriva a **tutti e quattro i
bordi**, e i lati che il dato chiude si coprono con la pedina **«varco chiuso»**:
il disegno non gira mai, perché non c'è nessun bordo diverso dagli altri. Cambia
**il prompt di una tessera su dieci** — solo l'Isola Muta ha lati chiusi — e la
fustella passa da 124 a **125** segnalini.

**La misura delle 200 mappe non cambia, e l'ho detto invece di rifarla per
finta:** la (2) non è una regola di posa. I varchi nel dato restano quelli, la
tessera si gira come prima, e il cancello lo dimostra — **0 pose non connesse su
151.200**.

### ✔ M8. [64](ISSUES.md#64) — la saga ricambia metà tavolo, ed è la regola

**Fatta in 0.1.401** ([D-431](DECISIONS.md#d-431)).

> **Al tavolo.** Finisce l'anno. Si rimettono nel sacchetto le otto carte
> casato, si pescano le quattro dell'anno nuovo, e chi rientra riprende la sua
> **con sopra tutto quello che aveva**. È scritto in
> [PROCEDURA_FINE_CHRONICLE](PROCEDURA_FINE_CHRONICLE.md) al punto 5-bis, dove
> un giocatore lo legge **prima** di affezionarsi ad Aldric.

**E il difetto non era la regola: era che non ce n'era una.** Erano **due sonde
con due regole diverse** — `run_era_probe` ripescava a ogni era, `run_saga`
teneva il tavolo fermo per secoli — e nessuna delle due leggeva niente. Due
giochi con lo stesso nome.

Adesso la regola sta sulla Chronicle (`seats_between_eras`) e lo schema la
**pretende**: `REDRAW`, `KEEP`, `KEEP_THEN_DRAW`. Il motore le sa eseguire tutte
e tre; le sonde le applicano invece di deciderle.

**Costo: nessuna misura si muove** — `REDRAW` è quello che il playtest e le sonde
già facevano. Cancello 0 su 8.

### ✔ M9. [69](ISSUES.md#69) — la faccia della Tensione, stampata ed eseguita

**Fatta in 0.1.402** ([D-432](DECISIONS.md#d-432)).

> **Al tavolo.** Giri la Tensione sul Tema caldo e adesso la carta dice **su cosa
> si discute**: *«La montagna fuma di nuovo: si mette qualcuno a guardarla, o si
> scrive che ha sempre fumato? · E le bocche aperte sul fianco, si murano?»*
> Prima diceva quando si scalda, quando si raffredda e cosa vale al Consiglio —
> e taceva sulla ragione per cui la si gira.

| | prima | **dopo** |
|---|---|---|
| Tensioni che dicono su cosa si discute | **0 su 60** | **60 su 60** |
| corpo rimpicciolito | 0 su 60 | **2 su 60** (la più stretta all'85%) |

**Il resto del «fatto quando» era già fatto, e l'ho verificato invece di
darlo per buono:** il motore esegue l'Azione scelta **e** la Risonanza, e il Tema
che ne esce è quello stampato (`test_the_world_answers`). L'app che lo mostra è
la **M14**.

**Un ritrovamento per strada:** le **clausole** sono rimaste tutte sui template —
21 su 12, zero sulle Tensioni — e **nove dei dieci segni che solo loro scrivono
non escono mai**. È finito come riga sotto la **M1**, che è la voce di quella
famiglia.

### ✔ M10. [82](ISSUES.md#82) — le condizioni che non succedono: **chiusa in 0.1.407**

**Lavorata in 0.1.403** ([D-433](DECISIONS.md#d-433)), **chiusa in 0.1.407**
([D-437](DECISIONS.md#d-437)): rimisurata sulla stessa sonda, i mai visti in
quarant'anni sono **due** — `#requisito`, che solo il Consiglio scrive ed è la
M1, e `scar:dragonfall`, la Cicatrice rara che hai deciso di tenere. L'altra
Cicatrice rara esce tre anni su quaranta. È esattamente il «fatto quando».

**I numeri della voce erano invecchiati, e la sonda guardava tardi.** La fustella
leggeva le Regioni **dopo** la fine dell'anno: un gettone posato a marzo e tolto
a settembre, a dicembre non c'è più. Ma la domanda della fustella è **quanti
pezzi la scatola deve avere**, non cosa resta a dicembre. Adesso conta anche i
gettoni posati dentro l'anno, e gioca **tutti e due i tavoli**.

**E il difetto vero era che nessuna carta posava quelle condizioni:** quattro
facce tolgono `#magro` e nessuna lo mette. *Il motore la fame la sapeva solo
togliere.* La cura era già scritta su una carta — *Marcia*, «marciare verso il
grano»: un esercito che marcia sul grano **se lo mangia**.

| 40 anni, seme 7000 | prima | **dopo** |
|---|---|---|
| tipi visti almeno una volta | 28 su 34 | **31 su 34** |
| **mai visti** | **6** | **3** |

**Per `#requisito` la cura non è una carta:** requisire è quello che **il tavolo
decide**, non un gesto che si fa da soli. È un segno del Consiglio per
costruzione, e il fatto che non esca è la **M1**.

**Il costo, e non è piccolo:** Verità scritte da **135 a 129** sul misto e da
**141 a 134** sull'uniforme, nella stessa direzione su tutt'e due. Una terra
magra è una terra su cui si litiga di più e si conclude di meno. Cancello 0 su 8.
**Se preferisci la memoria alla fame, tornare indietro è una riga** — dimmelo.

**Fatto quando** dei tre gettoni mai visti resta solo quello che il Consiglio
scrive, e le due Cicatrici rare che hai deciso di tenere.

### M11. Più vite per casa: **la strada (D) è percorsa**, in 0.1.404

La voce ([36](ISSUES.md#36), [D-434](DECISIONS.md#d-434)) esce dalle mie e va
fra le ⚪: quello che resta non è lavoro mio.

**Parola tua: sì**, la **(D)**: solo scrittura, nessun rischio. Il generatore
vero — la (C) — resta fermo per scelta: questo gioco è fatto di frasi che
qualcuno ha scritto.

> **Al tavolo.** Rigiochi la stessa linea per la terza volta. Le case sono le
> stesse otto, e a un certo punto ognuna diventa la stessa cosa che è diventata
> le altre due volte. Adesso ognuna ha **quattro** strade invece di tre, e
> quale prende dipende da cosa il mondo ha scritto quell'anno.

Sei case avevano tre vite e due ne avevano quattro: adesso ne hanno **quattro
tutte e otto**. Ogni porta è un segno che il mondo scrive davvero — da
`charter_temporary` (18 volte in cento partite) a `escort_sworn` (207) — e la
grammatica fisica ha preteso che ognuna delle sei avesse anche **un potere**, se
no era un nome senza conseguenze.

| 12 saghe × 8 anni, due tavoli | prima | **dopo** |
|---|---|---|
| vite scritte oltre la prima | 18 | **24** |
| **vite che non si sono mai sedute** | 1 | **1** |
| trasformazioni sedute | 237 | **269** |

**Tutte e sei si siedono.** Gli Ospiti di Nahr entrano 11 volte su uniforme e 10
su misto: al primo giro sono la quarta vita più giocata della scatola.

**E il «fatto quando» che avevo scritto non si può soddisfare, e vale la pena
sapere perché.** Chiedeva la distanza fra due saghe sopra lo 0,86. Su tre semi la
distanza fa 0,67/0,65/0,59 prima e **0,62/0,69/0,58** dopo: è **ferma**, e lo
scarto fra un seme e l'altro è più largo della differenza. Le frasi del verbale
le scrive il Consiglio sulla **questione** in discussione, non la casa che
propone — quindi quale vita siede non cambia quale frase resta scritta. La
distanza misura la varietà delle **domande**, e questa strada non poteva
muoverla. (Lo 0,86, poi, è misurato su due linee che oggi non esistono più: la
partenza vera sulla linea di oggi era **0,64**.)

**Il prezzo, scritto:** le vite vecchie siedono meno — la Diaspora di Nahr da
10/11 a **4/4**, il Culto della Misura da 8/8 a **4/6** — perché le
trasformazioni salgono ma si spalmano su ventiquattro vite invece che su
diciotto. E sei illustrazioni in più: 155 → **161**. Cancello **0 su 8**.

### ✔ M12. [111](ISSUES.md#111) — le Pietre che non si alzano mai: **chiusa in 0.1.411**

**Chiusa in 0.1.411** ([D-441](DECISIONS.md#d-441)): il bosco diradato non aveva
più nessuno che lo scrivesse ed è uscito dalla scatola; il passo franato e la
sorgente bassa arrivano in saga, e il criterio è ritagliato lì; la città non
arriva nemmeno in trenta Chronicle, ed è scritto — resta perché la scala è una
tua decisione (ISSUES 40).


**Rimisurata in 0.1.405, e non si chiude: ma adesso sappiamo perché**
([D-435](DECISIONS.md#d-435)).

> **Al tavolo.** Il Consiglio ti offre *«una Pietra del luogo sale di grado»*, e
> tu non la prendi mai. Non perché non ti serva: perché quella casella, quando
> la Pietra è un bosco o una sorgente, per il cervello del gioco **valeva zero**.

Le due cause che la voce aveva scritto sono cadute tutte e due: le Conseguenze
che posano quei gradi **vengono scelte**. La vera era una riga sola — il valore
della casella si leggeva dal *padrone della Pietra*, e un bosco, una sorgente,
un passo, un sito antico **non hanno padrone**. Dodici caselle su ventisette
valevano zero per costruzione, e la casella era offerta 128 volte in cento
partite e comprata **4**.

| 100 partite, tavolo misto | prima | **dopo** |
|---|---|---|
| UNA PIETRA SALE, offerta / comprata | 128 / **4** | 128 / **6** |
| gradi di Pietra che non arrivano mai | 4 | **4** — e non sono più gli stessi |
| segni mai arrivati, forme escluse (semi 7000 / 8000) | 51 / 54 | **54 / 52** |

**E il conto dei segni mai arrivati non si è mosso**, che è la cosa onesta da
dirti: una decina di quei segni escono zero, una o due volte in cento partite, e
lo scarto fra due semi è largo quanto la differenza fra prima e dopo. Quello che
si è mosso è la sola riga di UNA PIETRA SALE, ed è poco.

**E due dei quattro non erano difetti**: `settlement:$proponent` e
`evicted:$region_focus` portano un segnaposto nell'id, e la forma nuda non arriva
mai per costruzione. Adesso la misura lo dichiara invece di contarli fra i mancanti.

**Perché la lascio aperta.** Sei acquisti su centoventotto sono ancora quasi
zero: la casella perde contro COSTRUISCI PIETRA e CAMBIA CONTROLLO in un
Consiglio che compra 2,33 benefici. Alzarne il valore da 2 a 3 è la mossa che la
[117](ISSUES.md#117) ha già provato altrove e **rifiutato** — la casella si
mangiava le altre — e non si cura una casella morta facendone morire un'altra.

**Fatto quando** ogni grado consumato si alza almeno una volta in cento partite,
o esce dalla scatola. Ne restano **quattro**: il bosco diradato, il passo
franato, la città e la sorgente bassa. E il passo è l'unica Pietra della scatola che **nessuna Tensione
nomina**: nessun Consiglio può toccarlo.

### M13. ✔ [4](ISSUES.md#4) — gli obiettivi non si incrociano: **chiusa in 0.1.405**

Tre righe del criterio passavano già. La quarta stava ferma su un numero
**contato a mano** — «3 su 15» — quando il mazzo era già di diciassette: lo
stesso difetto per cui questo foglio si genera da solo
([D-436](DECISIONS.md#d-436)).

**Adesso lo conta la sonda**, con la regola scritta: due case non possono avere
insieme un obiettivo che chiede o di essere **il primo**, o di **tenere due terre
di uno stesso dominio** — di un dominio ne entrano in gioco tre o quattro su sei.

E ne ho scritte due, che completano una famiglia: «Due Terre, una Voce» aveva il
Territorio, adesso **Il Fondo Antico** ha l'Antico e **Le Due Rese** le risorse.
Una ambizione per dominio, e nessuna delle tre si può avere in due.

| | chiedeva | **l'ultima misura** |
|---|---|---|
| Regioni contese a fine anno | > 3 su 6 | **3,71 su 6** ✅ |
| il padrone passa di mano | più di prima | **3,87 volte** ✅ |
| obiettivi contesi | ≥ un terzo del mazzo | **7 su 19** (36,8%) ✅ |
| playtest | 0 su 8 | **0 su 8** ✅ |

**Il prezzo, scritto** — *e qui mi correggo*: avevo scritto «due illustrazioni in
più». **Non è vero.** Le due carte portano il loro prompt come le altre
diciassette, ma il censimento dell'arte conta solo carte Asset, Echi, tessere,
case e Destini: gli obiettivi non ci sono mai stati, e i soggetti restano **161**.
Il buco vero è quello — diciannove carte con un prompt scritto che quel conto non
vede — ed è una riga sotto l'arte, non una voce nuova. Le Verità salgono —
130 → **133** sul misto, 134 → **145** sull'uniforme.

Con lei si è rimisurata anche la [91](ISSUES.md#91), che sta fra le ⚪: le
clausole già vere all'apertura scendono da **47,1%** a **46,2%**.

### M14. [65](ISSUES.md#65) — l'app smette di mostrare lo stato

**Parola tua: sì**, la **(3)**, ed è la più cara della lista.

> **Al tavolo.** La plancia è aperta e il tablet sta di lato. Oggi il tablet
> mostra **un cruscotto**: elenchi, valori, questioni con un numero accanto. Deve
> mostrare **il tavolo** — la mappa con le pedine dove stanno, e quello che è
> appena successo scritto come lo racconteresti a voce.

**Va per ultima**, e non per paura: ha bisogno che le carte, le tessere e la
faccia della Tensione siano ferme, se no si disegna due volte la stessa pagina.

**Fatto quando** la pagina segue la decisione scritta, e la 🔵
[63](ISSUES.md#63) si può verificare giocandoci.

---

# ⚪ Fuori dalla lista finché non giochi: **sette**

Non perché non valgano: perché **ognuna di queste è un gioco nuovo**, e aprirla
adesso è esattamente il giro che vuoi chiudere. Restano scritte dove sono.

| | perché è fuori |
|---|---|
| [98](ISSUES.md#98) — ogni segno dichiara se pesa o se è colore | è un **metodo**, non una cosa: genera lavoro all'infinito. La sua metà utile era il gruppo dei segni, e quello è finito in 0.1.363 |
| [39](ISSUES.md#39) — le strutture con una vita (torre → castello → reggia) | tua idea grossa, e tocca la plancia. Dopo R1, che tocca la plancia anche lui |
| [47](ISSUES.md#47) — le carte come unica moneta | tua idea grossa: riscrive l'economia del turno |
| [50](ISSUES.md#50) — quattro obiettivi al posto dei tre gradini | tua idea grossa, e R3 la anticipa in parte |
| [27](ISSUES.md#27) — il tavolo sullo schermo grande e le console in tasca | milestone 0.6, e ha bisogno che l'app della 63 esista prima |
| [36](ISSUES.md#36) — linee sempre diverse: la strada **(D)** è percorsa ([D-434](DECISIONS.md#d-434)) | quello che resta sono le strade **A** e **B** e le cinque domande secche, e per tua parola si guardano **dopo la prima partita vera** |
| [91](ISSUES.md#91) — i punti già veri all'apertura, **46,2% in 0.1.405** | **la sua cura era R3**, ed è arrivata: rimisurata con la M13, scende da 47,1% a **46,2%** sullo stesso tavolo e lo stesso seme. Sotto la metà e ancora in calo — ma il 60,5% con cui è nata è misurato su un altro tavolo, e i due numeri non stanno in fila ([D-391](DECISIONS.md#d-391)) |

---

# E una cosa che non è una voce: l'arte

**150 illustrazioni su 161 sono ancora un segnaposto** (`docs/COMPONENTI.md`). I
prompt sono tutti scritti, e generati dai dati veri. È lavoro meccanico, e le due
decisioni che lo bloccavano — il formato di una carta e come si disegna una
tessera — sono chiuse: **si può commissionare quando vuoi**. Non è nella lista
perché non è una voce: è la scatola.

**E una riga trovata qui, in 0.1.406:** quel conto di 161 guarda carte Asset,
Echi, tessere, case e Destini. **Le diciannove carte Obiettivo portano un prompt
scritto e non ci sono dentro** — quindi i soggetti veri da disegnare sono di più
di quanto quel numero dica. Non apro una voce: è una riga sotto questa.

---

## Come finisce

**Di questo foglio, ogni numero è generato** ([D-426](DECISIONS.md#d-426)): il
conto in cima, il numero nel titolo di ogni colore, la tabella dei colori, il ✔
su una voce che ISSUES dice chiusa, e i due paragrafi che ripetono quei numeri a
parole — questo compreso. A mano resta **solo la domanda e la raccomandazione**
di ogni riga, che è quello che a mano deve restare.

Prima era generato il solo conto in cima, e il resto lo riscrivevo io: in un
giorno l'ho rattoppato quattro volte, e una l'hai vista tu. Un numero scritto a
mano invecchia il giorno dopo.

**E succede ancora, dove il generatore non arriva.** In questo giro tre numeri
scritti a mano si sono rotti da soli — «3 su 15» di obiettivi contesi quando il
mazzo era di diciassette, «53 regole dei segni» dentro una prova, «due
illustrazioni in più» che non erano vere. Due li conta adesso una sonda, il terzo
l'ho corretto qui sopra. **La regola è sempre la stessa: se un numero si può
generare, non si scrive.**

<!-- IN UNA RIGA: inizio - generato da tools/issues_survey.py -->

**Quello che resta da dire in una riga:** delle dieci voci aperte ne posso
muovere **una** da sola. Due le verifica una persona che gioca, sette stanno
fuori dalla lista, e **nessuna aspetta una tua parola**.

<!-- IN UNA RIGA: fine -->

**E la regola 3 non serve più, per adesso.** Diceva: *se una rossa non arriva,
faccio la raccomandata e la segno come fatta sulla mia parola*. L'ho usata quattro
volte — R4, R6, R11, e prima ancora — e in 0.1.397 le rosse sono finite: hai
risposto a tutte e dodici. Resta scritta perché una rossa nuova può nascere in
qualsiasi momento, e allora vale di nuovo.
