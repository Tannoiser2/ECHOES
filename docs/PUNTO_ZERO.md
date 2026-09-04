# PUNTO ZERO — dov'è ECHOES, misurato

**Versione 0.1.415** · rimisurato per intero in 0.1.416 ([D-447](DECISIONS.md#d-447)).
Le versioni prima: rifatto in 0.1.349, rimisurato a pezzi in 0.1.379–0.1.382, e
poi fermo per **trentatré versioni** — le stesse in cui la lista delle M si è
svuotata e la pagina dell'app è stata riscritta. Tutti i numeri qui sotto sono
usciti dalle sonde oggi.

Questo documento non racconta cosa il gioco vuole essere. Dice **cosa fa oggi,
con i numeri**, e cosa è ancora aperto. È il foglio contro cui si decide: se una
voce qui sotto non ti torna, quella è la prima cosa da cambiare.

Tutti i numeri sono su **100 anni pescati di CHR_00, `--seed=7000`**, tavolo
misto salvo dove detto. Da [D-318](DECISIONS.md#d-318) non esiste più un anno
d'autore: ogni seme è una mappa diversa, e questo è il gioco che sta nella
scatola.

> **Perché questo foglio va rifatto e non aggiornato.** Una fotografia con una
> didascalia non è una misura: la regola è **rimisurare**, e i numeri qui sotto
> sono usciti dalle sonde oggi, non dalla memoria. Dove un numero non è
> confrontabile con quello di prima — perché la sonda è cambiata, non il gioco —
> è detto.

---

## 1. Quello che tiene

| | | com'era in 0.1.379 |
|---|---|---|
| suite | **746 prove / 114 suite / 93.907 asserzioni** verdi | 690 / 102 / 86.390 |
| il vincolo che non si negozia | **0 seggi bloccati su 8**, misto *e* uniforme | uguale |
| cancelli | **tutti e trentatré verdi** (vedi `CLAUDE.md`) | trentadue |
| Consigli per anno | misto **3–6** (media 3,53) · uniforme **3–5** (media 3,36) | 3,58 · 3,49 |
| Verità scritte | misto **136**, di cui 113 diverse · uniforme **139**, di cui 107 | 142/113 · 150/108 |

**Il cancello non si è mai rotto** in trentatré versioni, sette delle quali
hanno toccato i dati ([D-437](DECISIONS.md#d-437) → [D-443](DECISIONS.md#d-443)).
Le Verità scendono di sei sul misto e di undici sull'uniforme, e il costo è
scritto verbale per verbale: due Conseguenze e un segno usciti dalla scatola
([D-440](DECISIONS.md#d-440)), una Risonanza spostata verso Terra
([D-443](DECISIONS.md#d-443)). Un numero peggiorato e scritto vale più di un
numero nascosto.

**I cancelli sono trentatré, e costano ventotto secondi.** Ventotto veloci — il
ventottesimo è la scheda di ogni tipo di carta ([D-445](DECISIONS.md#d-445)) —
e cinque sonde lunghe, 881 secondi, che si girano una volta prima della PR.
Un comando solo, [`tools/gates.py`](../tools/gates.py), in due corsie
([D-418](DECISIONS.md#d-418)).

---

## 2. I due numeri di PZ-01

### Il difetto più grosso del progetto è sotto la soglia, di nove punti

Il criterio 2 della milestone — *«meno della metà dei turni sono passa»* — è
soddisfatto. `cli/run_pass_probe.gd`, 100 anni, tavolo misto:

| | oggi | in 0.1.380 |
|---|---|---|
| turni «passa» | **41,2%** (2.963 su 7.200) | 49,6% |
| per Atto | 42,4% → 40,5% → 40,6% | 50,2 → 48,2 → 50,4 |
| passa con **zero mosse legali** | **0 su 2.963** (media 23,2 mosse) | 0 su 3.571 |
| passa con la mano vuota | **4** su 2.963 (media 3,8 carte) | 9 |

**Gli otto punti non sono tutti gioco, e va detto.** In mezzo ci sono tre cose:
un'Azione della plancia che alza una Pietra ([D-412](DECISIONS.md#d-412), R1 —
e ACQUISIRE non era stampata su nessuna faccia), il cervello che si fa male
quando non ha di meglio ([D-424](DECISIONS.md#d-424)), e **la sonda corretta**
([D-422](DECISIONS.md#d-422)): fino alla 0.1.393 contava il tavolo e non la
mano. Il 49,6% e il 41,2% non sono lo stesso metro; quello che è confrontabile è
il margine dalla soglia, che da quattro decimi è diventato **nove punti**.

Le cause di quello che resta, misurate:

| | quota dei «passa» | dei 7.200 turni |
|---|---|---|
| mosse legali, nessuna che gli servisse | **87,8%** | **36,1%** |
| voleva un verbo, in mano niente | 7,0% | 2,9% |
| aveva il verbo e non poteva usarlo lì | 5,1% | 2,1% |

E la mano: su tutti i turni, **il 54,0% delle carte guardate è muto** — 46,0%
sanno dire qualcosa — e in **1.284 turni su 7.180 la mano è tutta muta**: lì
passare non è una scelta. Delle mute, l'88,0% le zittisce il cervello (una
scelta) e il 12,0% il tavolo (le regole): **zero murate dalla mappa**, da
[D-439](DECISIONS.md#d-439).

I verbi che il cervello vuole dire e non riesce: **INFLUENZARE 207**, TRAMARE
130, RIVENDICARE 17, FORGIARE 4. Di quelle 358 intenzioni, **209 sono pesca
sbagliata** e 149 bersaglio sbagliato. Erano 545 in 0.1.380: INFLUENZARE resta
il verbo in sofferenza, ed è la moneta più votata del tavolo
([D-442](DECISIONS.md#d-442)).

### Giocare rende, e di molto

`cli/run_asking_probe.gd` gioca ogni anno due volte con lo stesso seme: una col
tavolo vero, una col **tavolo di pietra** che non spende mai un'Occasione.

| | oggi | in 0.1.380 |
|---|---|---|
| obiettivi avverati giocando | **374 su 1.200** (31,2%) | 425 (35,4%) |
| avverati dal tavolo di pietra | **106** | 116 |
| **quanto rende giocare** | **+252,8%** | +266,4% |
| di quelli avverati, **già veri all'apertura** | **49** (13,1%) | 48 (11,3%) |

Gli obiettivi erano 17 e sono **19** ([D-436](DECISIONS.md#d-436)); la quota
scende perché due dei nuovi si pescano e non si avverano ancora. La regola di
casa della ROADMAP §1.4 — *nessun traguardo vero all'apertura, nessuno che si
avveri stando fermi* — regge:

- **due obiettivi su diciannove** rendono uguale o meglio stando fermi:
  `MOST_STONE` (−3%), `FULL_HANDS` (±0%);
- gli altri diciassette rendono da **+3%** a **+100%**.

**I tre di Pietra non sono più tutti e tre fermi.** In 0.1.380 *Più Pietra di
Tutti*, *Qualcosa che Resta in Piedi* e *L'Opera che Porta il Nome* rendevano
uguale o peggio stando fermi, con una causa sola: nessuna Pietra saliva per mano
di un'Azione. Da R1 ([D-412](DECISIONS.md#d-412)) una Pietra la alza
ACQUISIRE — **254 Pietre alzate da un'Azione in cento anni, contro 0** — e
*Qualcosa che Resta in Piedi* e *L'Opera* rendono **+27%**. Resta *Più Pietra
di Tutti*, che è un confronto: chi sta fermo lo vince quando gli altri
costruiscono per lui.

**E fra i Destini uno solo si avvera da fermi**: *SHARED_QUIET* (0,78 giocando,
0,96 fermi). Gli altri sedici chiedono di giocare.

---

## 3. La grammatica fisica: cosa esiste, e cosa il motore esegue

| | |
|---|---|
| Temi | **6** — Potere, Sopravvivenza, Terra, Antico, Fede, Vie |
| carte Asset con faccia fisica | **48 su 48**, ognuna col suo Eco **stampato sulla faccia** ([D-449](DECISIONS.md#d-449)) |
| Destini con faccia fisica | **23 su 23** |
| carte Domanda | **60** — dieci per Tema, tarocchi **fronte-retro**: davanti la domanda, dietro il suo Consiglio ([D-449](DECISIONS.md#d-449)) |
| carte Obiettivo | **19**, con una faccia da [D-445](DECISIONS.md#d-445) |
| tessere Regione | **10 nel parco, 6 pescate** ogni anno; **0 pose** su 151.200 lasciano una tessera isolata |
| i verbi | **7** — SEGNARE è il settimo ([D-423](DECISIONS.md#d-423)) |

**Il motore esegue**: la Risonanza, il bersaglio a segni delle Azioni
([D-273](DECISIONS.md#d-273)), la scelta fra le due Azioni stampate
([D-283](DECISIONS.md#d-283)), le clausole dei Destini mirate a segni
([D-327](DECISIONS.md#d-327)), la pista del Calore, il Consiglio che si apre sul
Tema più caldo, **«SI ACCENDE QUANDO»** ([D-330](DECISIONS.md#d-330)) e **«SI
DISCUTE DI»** ([D-432](DECISIONS.md#d-432)), la risoluzione con le caselle
([D-366](DECISIONS.md#d-366)), **la pedina col nome della domanda** — *«la
sceglie chi propone»*, [D-438](DECISIONS.md#d-438) — e chi siede l'anno
prossimo, che è una regola scritta sulla Chronicle ([D-431](DECISIONS.md#d-431)).

| il vocabolario delle caselle | distinti | applicazioni |
|---|---|---|
| **una casella lo sa dire** | **45 su 46** | **285 su 287** |
| verbo giusto, posto che non sa dire | 1 | 2 |
| verbo che manca | **0** | **0** |

| la Risonanza, misurata | oggi | in 0.1.380 |
|---|---|---|
| Risonanze in 100 anni | **4.255 — 42,5 per anno** | 3.779 — 37,8 |
| di quelle, aggravate | **24,7%** | 24,2% |
| col ponte alla questione in gioco | 2.364 | 2.112 |

Dove finisce il Calore, che è la cosa che decide quale Tema si apre:

| Antico | Sopravvivenza | Fede | Vie | Potere | Terra | min/max |
|---|---|---|---|---|---|---|
| 19,0% | 17,9% | 17,8% | 16,3% | 14,9% | **14,1%** | **0,74** |

Era 23,0% Fede contro 9,8% Terra (0,43) in 0.1.380. **Nessun Tema apre meno
della metà dei Consigli del più aperto**, su due semi: è il criterio ritagliato
di [D-443](DECISIONS.md#d-443), e la cura è stata una Risonanza sola spostata
dove la carta già contava.

---

## 4. Come è fatto il contenuto

Contato da `validate_data.py` e da `docs/COMPONENTI.md`, che si ricava i numeri
invece di battersi le cifre a mano ([D-373](DECISIONS.md#d-373)).

| | |
|---|---|
| Asset | **48** (132 copie), tutte con faccia fisica, ognuna col suo Eco |
| Echi | **48**, sulle carte Asset · Domande **60**, col Consiglio sul retro · Destini **23** · Obiettivi **19** · Casate **32** (8 case, una carta per vita) |
| Conseguenze | **63** · azioni **7** |
| Regioni 10 · Entità 8 · profili strategici 8 · Cronache **1** (CHR_00) | |
| segni nel dizionario | **177** · regole del segno **59** · icone **124** |
| template di Consiglio | 12 |
| **da stampare** | **84 fogli A4**, più quattro fogli-fustella |
| **segnalini** | **118 tipi, 152 pezzi**, più le pedine dei seggi |
| **da illustrare** | **161 soggetti**, 11 disegnati, **150 ancora segnaposto** |

**Ogni pezzo ha una scheda, e il dato per generarlo.** Da
[D-445](DECISIONS.md#d-445) [SCHEDE_CARTE](SCHEDE_CARTE.md) dice per ogni tipo
cos'è, che immagine porta col prompt generale, e cosa c'è scritto sopra voce per
voce; e `docs/schede/<tipo>.json` porta il record di ognuna delle **300 facce**
col prompt già composto. I segnalini hanno la loro in
[CATALOGO_PEDINE](CATALOGO_PEDINE.md).

**Il Consiglio sta sulla carta, dietro.** Ogni Domanda porta sul fronte le sue
domande e sul retro le caselle con cui il tavolo la risolve, da 18 a 25 per
carta ([D-449](DECISIONS.md#d-449)).

E le tre misure che vengono prima della matrice (`MISURA_MATRICE.md`):

| | |
|---|---|
| segni che qualcuno scrive | **174 su 177** |
| **orfani senza una ragione scritta** | **0** |
| clausole impossibili | **0** |
| Tensioni che nessun Destino incontra | **0** |
| **carte che aprono ancora una domanda in prestito** | **0** |
| livelli di Destino che si reggono solo su conteggi | **11 su 69**, tutti il `minimum` |
| coppie di case che hanno qualcosa per cui litigare | **13 su 28** |

E le misure che guardano il tavolo giocato:

| | |
|---|---|
| segni che non arrivano mai sul tavolo (`MISURA_TAVOLO`) | **53 su 177** |
| **punti regalati** / **porte murate** (`MISURA_SEGNI`) | **1** / **0** |
| vite scritte che non si siedono mai (`MISURA_VITE`) | **1 su 24** |
| testi che un giocatore può leggere (`REVISIONE_TESTI`) | **4.233** |
| pezzi e legami del flusso disegnato (`flusso.html`) | **1.050 / 4.381** |
| pezzi del disegno senza nemmeno una freccia | **1** (erano 7) |
| testi che vivono solo nel suggerimento del mouse (`MISURA_PAGINA`) | **2** |
| bersagli più stretti di un dito / pannelli che dipingono | **0** / **0** (erano 0 / 2) |
| quanto la pagina chiede su un tablet da 768 px | **678** (erano 788 in fila, senza la mappa) |

**La pagina dell'app mostra il tavolo, non lo stato** ([D-444](DECISIONS.md#d-444)):
mappa e mazzetti costruiscono nodi, la colonna di stato e il verbale sono pagine
che si aprono al posto del tavolo, e le carte in mano si posano sulla domanda o
sulla casa.

---

## 5. Le voci aperte — **nove**, e nessuna è mia

**9** voci aperte su 132, contate da `tools/issues_survey.py`. La lista viva è
[LE_TUE_DECISIONI.md](LE_TUE_DECISIONI.md), che si rigenera col suo cancello.

| chi la può muovere | quante | in 0.1.382 |
|---|---|---|
| il committente, con una parola | **0** | 15 |
| una persona che gioca — [63](ISSUES.md#63), [67](ISSUES.md#67) | 2 | 2 |
| **io, senza aspettare niente** | **0** | 4 |
| io, ma dietro una rossa | 0 | 2 |
| nessuno, finché non si gioca | 7 | 6 |

**Il giro non è fermo su niente che si possa misurare.** Le quindici parole sono
arrivate in una — *«sì a tutte»*, [D-427](DECISIONS.md#d-427) — e le quattordici
righe di lavoro che ne sono nate sono percorse tutte, l'ultima in 0.1.414. Quello
che resta aperto nomina una persona con l'app in mano: la [63](ISSUES.md#63)
(*giocare un anno intero senza che nessuno spieghi i bottoni*) e la
[67](ISSUES.md#67) (*la saga arriva al terzo anno su un tablet*), e sette voci
che aspettano una partita vera prima di dire se sono ancora vere.

---

## 6. Le decisioni che sono tue e non mie

**Nessuna in attesa.** Le quindici che questo foglio elencava in 0.1.382 sono
state prese in 0.1.397 ([D-427](DECISIONS.md#d-427)) e portate a termine una per
una; le ultime due parole — la scheda per tipo di carta, e *«44x68 è troppo
piccolo»* — sono [D-445](DECISIONS.md#d-445) e [D-446](DECISIONS.md#d-446).

**Quello che resta tuo è l'occhio**, e nessuna misura lo copre (§5ter):

1. **le carte stampate in mano** — 300 facce, 76 fogli, con la scheda e il dato
   per generarle. La Domanda a 63×88 è una taglia che ho scelto io dentro la tua
   parola: si cambia in un punto solo;
2. **il giro su un iPad vero** — la pagina chiede 678 px su 768 e nessun
   bersaglio è più stretto di un dito, ma quello che una persona *vede* non lo
   dice nessuna sonda. È la [63](ISSUES.md#63);
3. **l'arte**: 150 soggetti su 161 sono ancora segnaposto, e i prompt sono
   pronti ([BRIEF_ARTE](BRIEF_ARTE.md), e in ogni JSON delle schede).

---

## 7. Il debito che questo giro ha trovato

- **`docs/RULES_V0_2.md` è fermo a 0.1.38** e rimanda a un file che non esiste
  più. Resta perché è l'unico posto dove le regole sono scritte per esteso, con
  l'avvertenza in cima.
- **La traccia dei valori usciva dal foglio** — 223 mm su un A4 da 210 — e
  nessuna prova lo vedeva: contava i rettangoli, non dove stavano
  ([D-446](DECISIONS.md#d-446)). Adesso una prova chiede a ogni casella di
  stare dentro.
- **Diciannove carte Obiettivo non avevano una faccia**, e il censimento le
  contava fra le cose «che non si stampano» ([D-445](DECISIONS.md#d-445)).
- **La sonda dei «passa» contava il tavolo e non la mano**, da centoquaranta
  versioni ([D-422](DECISIONS.md#d-422)): la frase su cui la voce era discussa
  non diceva quello che sembrava.
- **Questo foglio è rimasto fermo trentatré versioni**, la terza volta: ed è
  la lezione 5, di nuovo.

---

## 8. Le lezioni che questo progetto ha pagato

Valgono più di metà del codice scritto.

1. **Uno zero è quasi sempre la sonda.** Diciotto volte finora. Prima di credere
   a uno zero, provalo su un caso che *deve* dare non-zero.
2. **Una guardia più generosa del motore non protegge: assolve.** Il censimento
   dichiarava che una Casa scrive il segno di *ogni* sua incarnazione; il motore
   la fondatrice la riconosce dal *non* averlo, e otto voci morte sono rimaste
   nel dizionario per versioni ([D-376](DECISIONS.md#d-376)).
3. **Un cancello che si soddisfa da solo è peggio di nessun cancello.** Un
   generato con un cancello garantisce che il file combaci col generatore —
   **non** che il generatore dica la verità. È così che una frase falsa si fa
   certificare fresca a ogni giro ([D-373](DECISIONS.md#d-373)).
4. **Una strada ritirata va riprovata, non archiviata.** D-348 aveva ritirato una
   proposta perché faceva cadere un test; ventitré versioni dopo il test non
   cadeva più, e nessuno l'aveva riprovata. Costo: sei clausole morte su tre
   Destini ([D-372](DECISIONS.md#d-372)).
5. **Un documento fermo mente più di un documento che manca.** Questo foglio è
   rimasto indietro tre volte: settanta versioni, cinquantaquattro, trentatré.
6. **Un generato senza cancello è un generato fermo, e nessuno lo vede
   fermarsi.** `build_review.py` è morto all'avvio per dieci versioni e la CI è
   rimasta verde tutto il tempo.
7. **Uno strumento che nomina un file per nome è una mina a scoppio ritardato.**
   Si legge a glob quello che c'è.
8. **Un disegno appena finito è la cosa di cui ci si fida di più e ci si
   dovrebbe fidare di meno.** Quindici pezzi isolati nel grafo sembravano quindici
   scoperte: erano tre regole che il disegno non conosceva e dodici scoperte vere
   ([D-381](DECISIONS.md#d-381)).
9. **Una regola scritta in due file diverge in silenzio.** Dove Python ha
   bisogno di sapere una cosa che il motore decide, la scrive **chi la esegue** —
   in fondo a un documento generato — e Python la legge di lì.
10. **Un numero fermo dopo due modifiche diverse è qualcuno che guarda altrove.**
    La sonda delle caselle diceva 700 offerte e 22 comprate dopo la catena
    scritta e dopo il punteggio corretto, identico al centesimo: la pedina non
    arrivava al motore ([D-438](DECISIONS.md#d-438)).
11. **Una prova che conta i pezzi e non dove stanno non vede un foglio che
    sborda.** La traccia dei valori aveva le caselle giuste, tredici millimetri
    fuori dalla pagina ([D-446](DECISIONS.md#d-446)).
12. **Una misura si dichiara, non si ottiene e basta.** Quindici bersagli larghi
    il giusto sullo schermo risultavano stretti quanto un capello alla sonda,
    perché chiedevano zero: un posto che chiede zero si stringe davvero dove lo
    schermo è stretto ([D-444](DECISIONS.md#d-444)).
