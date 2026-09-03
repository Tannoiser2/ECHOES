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
| chiuse | **114** |
| aperte | **18** |
| di cui **aspettano una tua decisione** | **0** |
| di cui sono mie da fare | **18** |

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
| 🟡 | **10** | **io**, da sola, senza aspettare niente |
| ⚪ | **6** | nessuno, per adesso: sono fuori dalla lista finché non giochi |

**Dieci.** Delle diciotto voci aperte, dieci le posso muovere senza di te — ed
è il numero che va detto per primo. **Il giro non è fermo su nessuna tua
parola.**

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
| — | [36](ISSUES.md#36) | la **(D)** adesso, il resto dopo la prima partita | 🟡 **M11** |

*(Questa tabella è un riepilogo, non una casa: ognuna di quelle voci vive sotto il
suo colore, e da 0.1.397 lo strumento va rosso se una voce prova ad abitare in due
posti — vedi [D-427](DECISIONS.md#d-427).)*

**Quello che questo cambia, ed è la cosa che chiedevi:** il giro non è più fermo
su di te. Delle ventidue voci aperte non ce n'è **nessuna** che aspetti una tua
parola — le due 🔵 aspettano una partita, non una decisione. Se una rossa nasce di
nuovo, nasce qui.

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

# 🟡 Sono mie, e non aspettano niente: **dieci**

Erano quattro. In 0.1.397 sono diventate **quattordici**: dieci sono arrivate qui
dalle rosse, perché la tua parola è arrivata e quello che resta è lavoro
([D-427](DECISIONS.md#d-427)). **Nessuna apre una voce nuova**, e ognuna che si
chiude sparisce dal conto qui sopra.

**L'ordine in cui le faccio**, che non è l'ordine dei numeri:

| | perché prima |
|---|---|
| **M5** — i bersagli murati | è il numero più grosso che c'è sul tavolo: **quattro turni su dieci** finiscono in «passo» |
| **M6** — le 46 righe stampate | senza, al tavolo fisico una carta non sa dire perché è uscita |
| **M7** — i quattro varchi | **ha una scadenza**: viene prima di commissionare i disegni |
| **M8** — la regola della saga | è una riga scritta e una sonda che smette di decidere da sola |
| **M9** — la faccia della Tensione | la seconda grammatica smette di divergere dalla prima |
| **M10** — le condizioni che non escono | la fame è un Tema del gioco e il motore quasi non la produce |
| **M11** — più vite per casa | è solo scrittura, e il metro esiste già |
| **M1–M4** | le quattro di prima, che non sono cambiate |
| **M12**, **M13** | si **rimisurano** adesso che R1 e R3 sono chiuse: potrebbero chiudersi da sole |
| **M14** — l'app che mostra il tavolo | **la più cara di tutte**, e va per ultima: ha bisogno che il resto sia fermo |

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

### M5. [128](ISSUES.md#128) — le carte murate: **lavorata in 0.1.398**

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

### M10. [82](ISSUES.md#82) — le condizioni che non succedono

**Lavorata in 0.1.403** ([D-433](DECISIONS.md#d-433)).

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

### M11. [36](ISSUES.md#36) — più vite per casa, con ingressi più fini

**Parola tua: sì**, la **(D)**: solo scrittura, nessun rischio. Il generatore
vero — la (C) — resta fermo per scelta: questo gioco è fatto di frasi che
qualcuno ha scritto.

**Fatto quando** la distanza fra due saghe sale sopra lo **0,86** di oggi, con le
mani d'apertura misurate insieme.

### M12. [111](ISSUES.md#111) — le Pietre che non si alzano mai

**Da rimisurare, e potrebbe chiudersi da sola.** La sua causa era *«nessuna
Azione della plancia alza una Pietra»*, e da 0.1.383 ACQUISIRE la alza: le Pietre
da Azione sono passate da **0 a 190** e quelle dal Consiglio da 148 a **211**.

**Fatto quando** ogni grado consumato si alza almeno una volta in cento partite,
o esce dalla scatola.

### M13. [4](ISSUES.md#4) — gli obiettivi non si incrociano

**Da rimisurare, e tre righe del suo criterio su quattro erano già passate.** La
quarta era la R3, che adesso è chiusa: sette Obiettivi nominano i segni della
mappa, e le coppie che si contendono una Regione sono passate da 15,5% a
**44,0%**.

| | chiedeva | l'ultima misura |
|---|---|---|
| Regioni contese a fine anno | > 3 su 6 | **3,40 su 6** ✅ |
| il padrone passa di mano | > 3 volte l'anno | **3,75 volte** ✅ |
| playtest | 0 su 8 | **0 su 8** ✅ |
| obiettivi contesi | ≥ un terzo del mazzo | **3 su 15** ❌ — da rifare |

Con lei si rimisura anche la [91](ISSUES.md#91), che sta fra le ⚪.

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

# ⚪ Fuori dalla lista finché non giochi: **sei**

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

**Di questo foglio, ogni numero è generato** ([D-426](DECISIONS.md#d-426)): il
conto in cima, il numero nel titolo di ogni colore, la tabella dei colori, il ✔
su una voce che ISSUES dice chiusa, e i due paragrafi che ripetono quei numeri a
parole — questo compreso. A mano resta **solo la domanda e la raccomandazione**
di ogni riga, che è quello che a mano deve restare.

Prima era generato il solo conto in cima, e il resto lo riscrivevo io: in un
giorno l'ho rattoppato quattro volte, e una l'hai vista tu. Un numero scritto a
mano invecchia il giorno dopo.

<!-- IN UNA RIGA: inizio - generato da tools/issues_survey.py -->

**Quello che resta da dire in una riga:** delle diciotto voci aperte ne posso
muovere **dieci** da sola. Due le verifica una persona che gioca, sei stanno
fuori dalla lista, e **nessuna aspetta una tua parola**.

<!-- IN UNA RIGA: fine -->

**E la regola 3 non serve più, per adesso.** Diceva: *se una rossa non arriva,
faccio la raccomandata e la segno come fatta sulla mia parola*. L'ho usata quattro
volte — R4, R6, R11, e prima ancora — e in 0.1.397 le rosse sono finite: hai
risposto a tutte e dodici. Resta scritta perché una rossa nuova può nascere in
qualsiasi momento, e allora vale di nuovo.
