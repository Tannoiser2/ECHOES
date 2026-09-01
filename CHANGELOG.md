# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).
Il progetto segue le milestone della specifica esecutiva v0.2.

---

## 0.1.362 — La passata di verità: sei voci erano già chiuse, e una era rossa (D-394)

La prima verde della lista, e ha fatto quello che prometteva: **rileggere ogni
voce aperta contro i numeri di oggi** invece che contro quelli con cui è nata.
Sei voci su cinquantuno cadono, e **una era rossa** — cioè aspettava una parola
del committente che non serviva più.

| voce | perché cade |
|---|---|
| [66](docs/ISSUES.md#66) 🔴 | *«o CHR_03 si raggiunge, o è stato tolto»*: **è stato tolto** in D-318, quarantaquattro versioni fa |
| [46](docs/ISSUES.md#46) | la saga del Sale è `CHR_03`, cancellata: il difetto era su un anno che non esiste |
| [52](docs/ISSUES.md#52) | Lyra è il **seggio migliore** del tavolo uniforme: 3 NONE, 23 Vittorie, 3 Trionfi |
| [45](docs/ISSUES.md#45) | Kessa dei Fuochi sta nella banda su tutt'e due i tavoli, e Le Custodi della Cenere sono la **seconda vita più seduta** |
| [83](docs/ISSUES.md#83) | la casa che muta più spesso è a **1 salto su 4,7**, sopra il limite |
| [48](docs/ISSUES.md#48) | la Strada dei Mercanti è la **seconda Regione più abitata**: 1,07 → 2,23 presenze |

**E un difetto di misura corretto strada facendo**: `run_move_probe` divideva le
presenze per gli anni giocati invece che per gli anni in cui la tessera è
**pescata**. Con sei tessere su dieci, i quaranta anni in cui una Regione non è
sul tavolo entravano nella media come zeri — un terzo di errore su ogni riga.

Voci aperte: **51 → 45**. Decisioni che aspettano il committente: **11 → 10**.
Nessuna riga di gioco è cambiata: erano già tutte e sei vere.

---

## 0.1.361 — La lista che finisce, e una guardia perché finisca

Parola del committente:

> *«Nessuna però deve portare ad altre issue. Perché qui ne chiudiamo una ma ne
> apriamo dieci. Questo giro deve finire e dobbiamo arrivare a un punto che sia
> giocabile.»*

`docs/LE_TUE_DECISIONI.md` non è più un foglio di decisioni: è **la lista che
finisce**. Ventidue righe — **dieci rosse** (sue, una parola ciascuna), **otto
gialle** e **quattro verdi** (mie) — e ognuna con una fine scritta, non un
«migliora X». Tutto quello che non sta fra qui e una partita giocabile è in
fondo, nella sezione *fuori dalla lista*, con scritto perché.

**E la lista non può perdere pezzi.** `tools/issues_survey.py` ha una seconda
guardia: **ogni voce aperta dev'essere nominata dalla lista** — una rossa, una
gialla, una verde, o la sezione che dice perché aspetta. Girata la prima volta ha
trovato quattro voci senza casa. Una voce aperta che nessuno nomina è esattamente
il modo in cui una lista smette di finire.

**Cinque voci hanno cambiato colore**, e la ragione è scritta su ognuna: la
[98](docs/ISSUES.md#98) e la [91](docs/ISSUES.md#91) escono dalle decisioni
(la prima è un metodo che genera lavoro all'infinito, la seconda ha la sua cura
dentro un'altra rossa); la [96](docs/ISSUES.md#96), la [126](docs/ISSUES.md#126)
e la [82](docs/ISSUES.md#82) non aspettano più una parola. La
[69](docs/ISSUES.md#69) ne diventa una: quello che le resta è il **formato della
carta**, e va deciso prima dell'arte.

Le decisioni che aspettano il committente passano da 15 a **11 voci, dieci
domande**.

---

## 0.1.360 — I varchi si allargano: torna la densità della griglia (D-393)

Parola del committente, il giorno dopo D-390:

> *«Sì a questo punto aggiungi qualche lato per tornare ai 7 della griglia
> precedente.»*

**Da ventisei lati aperti a trentotto.** Nove tessere su dieci sono croci;
l'Isola Muta resta un angolo — due approdi e due lati di mare, che è l'unico
posto dove il gioco racconta un lato chiuso.

### La curva, prima di scegliere

| lati aperti su 40 | confini per mappa |
|---|---|
| 26 (D-390) | 5,30 |
| 31 | 5,95 |
| 35 | 6,21 |
| **38 (oggi)** | **6,80** |
| 40 | 7,00 |

**Il 7 esatto costa i quaranta lati** — con la regola dei varchi ci si torna solo
se nessun lato è chiuso, e allora `edges` non distingue più niente. Ma la curva è
piatta in cima: fra 38 e 40 ci sono **0,20 confini per mappa**, meno del 3%.

### Dove siamo, sulle 151.200 pose enumerate

| | griglia (D-275) | varchi 26 | **varchi 38** |
|---|---|---|---|
| confini per mappa | 7 | 5,30 | **6,80** |
| tessere con un vicino solo | — | 46,2% | **6,7%** |
| il padrone passa di mano, in un anno | 3,57 | 3,48 | **3,87** |
| Regioni con più di una casa a fine anno | 3,62 su 6 | 3,24 | **3,57** |
| Regioni con un padrone a fine anno | 5,29 su 6 | 5,01 | **5,20** |
| pose che lasciano una tessera isolata | — | **0 su 151.200** | **0 su 151.200** |

**La lotta per la terra non è tornata al livello della griglia: l'ha superata** —
3,87 passaggi di mano per anno contro 3,57 (+8,4%).

### Una strada provata e non tenuta

Un secondo criterio nella posa — *«a parità di varchi combacianti gira la tessera
coi varchi liberi verso il vuoto»* — non costava nessun lato. Misurato: **5,08
contro 5,08**, vicoli ciechi da 52,1% a 52,5%. La densità la fanno i lati, non
l'astuzia della posa.

---

## 0.1.359 — Quello che il tavolo non vede si divide in tre (D-392)

[ISSUES 88](docs/ISSUES.md#88) chiedeva un taglio: *«se sono le carte non
pescate è rigiocabilità; se sono le domande di carte che sono state girate, è il
difetto vecchio»*. Adesso `cli/run_who_writes_probe.gd` lo fa, guardando il
mazzetto prima e dopo — e i pezzi sono **tre**, non due.

| cento anni, CHR_00 | domande | proposte |
|---|---|---|
| scritte | 120 | 194 |
| **usate** | **99 (83%)** | **126 (65%)** |
| 1. mai pescate | 0 | 0 |
| 2. pescate, mai in discussione | 8 (7%) | 29 (15%) |
| **3. in discussione, mai scelte** | **13 (11%)** | **39 (20%)** |

La riga 2 è aritmetica: 312 Consigli in cento anni, e ognuno apre **una domanda
sola**. Solo la riga 3 è un difetto.

**Un taglio ha cambiato la risposta, ed è scritto.** Alla prima misura le
proposte mute erano 66 (34%). Sbagliato: una proposta si vota **dentro** la sua
domanda, e se la domanda non è mai stata posta la proposta non è stata scartata.
Passate quelle 30 alla riga 2, la cifra vera è 39 (20%). Tutte e 194 le proposte
portano un `question_id` che esiste — verificato, 0 vuoti e 0 pendenti.

E il titolo della voce non regge più: il *«poco più di un terzo»* era misurato su
`CHR_01`, cancellato con gli altri anni d'autore.

**La voce resta aperta a 20,1%**, con le **13 domande** e le **39 proposte**
scritte per nome, più le quattro Tensioni che in cento anni non arrivano mai a un
Consiglio (`TEN_ENCLOSURE`, `TEN_FLOOD`, `TEN_PASTURE`, `TEN_WEIGHTS`). Un
difetto si lavora per nome, non per percentuale.

---

## 0.1.358 — La voce più grossa si chiude, e il conto delle voci si misura (D-391)

Nessuna riga di motore. Solo due misure, e tutt'e due dicono che i numeri scritti
erano sbagliati.

### ISSUES 68 si chiude sulla condizione che si era scritta da sola

*«Fatto quando i «passa» scendono sotto la metà dei turni, e il playtest resta
0/8.»* Cento anni, seme 7000: **47,6%** a tavolo misto (3.428 su 7.200) e
**47,9%** a tavolo uniforme, **0 seggi bloccati su 8** su tutti e due i tavoli.

**Ed era vera da cento versioni.** L'ultima riga della voce diceva *«oggi sono
all'82,8%»* ed era ferma a 0.1.217. E la strada scritta sotto — *82,1% → 42,1%
→ oggi* — **confrontava misure prese su anni diversi**: il 42,1% è di `CHR_01`,
cancellato con gli altri anni d'autore in D-317/D-318. Chiederlo oggi risponde
`Chronicle sconosciuta 'CHR_01'`. Rimisurato sull'anno che esiste, il difetto non
si è mai mosso: **47,6% in 0.1.260, 47,3% in 0.1.290, 46,7% prima di D-385,
47,6% oggi** — meno di un punto in cento versioni. Costo dichiarato dell'ultimo
blocco (D-385…D-390): **+0,9 punti**, misurato.

Da qui, seconda regola di casa: **un numero si scrive col tavolo su cui è
misurato.**

**Quello che resta ha un'altra voce, e adesso ha un prezzo.** L'**84,0%** dei
«passa» è *«nessuna mossa gli serviva»* — **il 40,0% di tutti i turni**, e chi
passa ha 22,1 mosse legali e 4,4 carte in mano. È [ISSUES 123](docs/ISSUES.md#123): nessuna delle sei
Azioni della plancia alza una Pietra. **Quaranta turni su cento sono il prezzo di
quella decisione non presa**, ed è scritto lì.

### Il conto delle voci non si contava a mano

Chiudendo la 68 è venuto fuori che il foglio delle decisioni portava numeri
falsi: *66 chiuse, 60 aperte*. **Tredici voci chiuse non avevano il ✅ nel
titolo** (35, 41–44, 68, 71, 72, 89, 103, 107, 112, 113, 115), quindi nessun
conteggio poteva vederle; la 113 portava il suffisso «— CHIUSA in 0.1.328»
scritto due volte. Il conto vero è **80 chiuse su 131, 51 aperte, 15 che
aspettano il committente**.

E smentisce la frase che ci stava sotto: *«apro più di quanto chiudo, e
sistematicamente»* si appoggiava a una fascia data a 7 aperte e 0 chiuse. È **7 e
8** — l'unica fascia in cui si chiude più di quanto si apra.

`tools/issues_survey.py` è il **ventottesimo e ventinovesimo cancello**: rigenera
il blocco del conto e va rosso se una voce dichiara «chiusa in 0.1.x» senza il
segno. Una mezza chiusura non conta, e le quattro che ci sono restano aperte.

---

## 0.1.357 — Il confine è un varco, non un accostamento (D-390)

Regola dettata dal committente, e riscrive D-275.

> *«Bisogna dare delle adiacenze: Eredan in tutti e quattro i lati, le montagne
> magari solo su due. Se due lati hanno adiacenze in comune lo spostamento è
> permesso. E deve essere calcolato in modo che non ci siano tessere isolate.»*

### Cosa c'era

Due mappe, e se ne giocava una sola: l'`adjacency` scritto a mano sulle dieci
tessere **non lo leggeva nessuno** sul tavolo pescato, dove i vicini erano chi
capitava di fianco nella griglia. E due letture divergenti della stessa parola —
`narrative_text` e `board_sheet` leggevano il grafo **del dato** mentre la
partita giocava su quello **del mondo**: il gioco funzionava e il racconto
mentiva. Adesso tutti e due leggono il tavolo.

### La regola

Ogni tessera dichiara i suoi **varchi**: quali dei quattro lati si attraversano.
Cinque forme — **croce** (Eredan, la Strada), **T** (Valle, Nahr, Porto),
**corridoio** (Montagne, Bosco), **angolo** (Palude, Miniere), **vicolo cieco**
(l'Isola Muta). Ventisei lati aperti su quaranta.

E la posa non è più una griglia: **si posa accanto a una tessera già posata,
girandola finché il lato che si tocca porta un varco su tutte e due**, e fra le
pose possibili si sceglie quella che fa combaciare più varchi.

**La promessa viene per costruzione**: una tessera entra solo attaccandosi
attraverso un varco. E non si campiona — **si enumera**, come il committente ha
chiesto: 210 pescate per 720 ordini fanno **151.200 pose**, e la sonda le fa
tutte chiamando la posa del motore. È il **ventisettesimo cancello**.

| tutte le pose che il gioco può produrre | |
|---|---|
| pose enumerate | **151.200** |
| pose che **lasciano fuori una tessera** | **0** |
| pose che **lasciano una tessera isolata** | **0** |
| pescate che si rompono in almeno un ordine | **0 su 210** |

### Il costo, scritto

| | griglia | varchi |
|---|---|---|
| confini per mappa | **7** | **5,30** |
| tessere con un vicino solo | — | **46,2%** |
| il padrone passa di mano, in un anno | 3,57 | **3,48** |
| Regioni con più di una casa a fine anno | 3,62 su 6 | **3,24** |

**La mappa è più stretta di un quarto**, ed è quello che la regola dice. La
lotta per la terra si muove poco: −2,5% sui passaggi di mano.

### E il varco si vede

La faccia stampata della tessera porta `VARCHI alto · destra`; il prompt d'arte
dice a chi disegna dove la strada arriva al bordo e quali lati sono chiusi dal
terreno; il disegno del flusso porta i varchi come pezzo.

Aperta [ISSUES 127](docs/ISSUES.md#127): la tessera si gira, e l'arte si gira
con lei — tre strade, ed è una scelta d'autore.

**Cancello:** 0 seggi bloccati su un solo livello su 8, misto e uniforme. Suite
**680 prove / 101 suite / 86.562 asserzioni** verde.

---

## 0.1.356 — Nel grafo c'erano dodici Consigli, e nella scatola sono sessanta

### E la risposta a «non si arriva mai al punto di chiudere?»

**No, non con questo metodo**, e i numeri lo dicono: 126 voci, 66 chiuse, 60
aperte — e per fascia di venticinque versioni ne apro sistematicamente più di
quante ne chiudo (12/5, 12/7, 12/3, 7/0). Non è disordine: la regola di casa è
*misura prima di scrivere*, e ogni misura trova qualcosa. È il metodo che ha
tenuto il gioco onesto, e **non ha una fine sua**.

**La lista non è il traguardo.** PZ-01 ha tre criteri, due sono misurati e
tengono — «meno della metà dei turni sono passa» (46,4%) e «0 seggi bloccati su
8». Il terzo — *«dopo una partita si guarda la mappa e si capisce cosa è
successo»* — **non lo può dire nessuna sonda**. Si chiude giocando.

Scritto [`docs/LE_TUE_DECISIONI.md`](docs/LE_TUE_DECISIONI.md): le **quattordici**
voci che aspettano il committente, una riga a testa, il numero che le motiva e la
mia raccomandazione — così si chiudono in mezz'ora invece che una alla volta.

**E da qui non apro più voci nuove**: quello che una misura trova diventa una
riga sotto la voce che l'ha trovato, non una voce nuova con tre strade.

*(Corretta anche la contabilità: due voci dicevano CHIUSA nel titolo senza il
segno, e risultavano aperte — 62 → 60.)*

Domanda del committente: *«perché nel grafo ci sono solo 12 carte del
Consiglio?»*. Perché il disegno chiamava «Consiglio» i **dodici template
d'autore** — le clausole e i tre sacchetti — e la **Scheda Consiglio**, che nella
scatola è una per carta Tensione, **non era un pezzo**: le sue due Domande e le
sue tre Proposte pendevano direttamente dalla carta.

Quindi chi contava i Consigli nel grafo ne trovava **dodici** e chi li contava in
`COMPONENTI.md` ne trovava **sessanta**, e i due numeri non si potevano
riconciliare guardando il disegno.

Adesso la scheda c'è, e la catena si legge per intero:

> **carta Tensione → Scheda Consiglio → Domanda → Proposta → Conseguenza**

e la scheda **si tiene col template** per quello che il template continua a dare:
le clausole che un avversario attacca prima del voto, e i tre sacchetti.

| | prima | dopo |
|---|---|---|
| pezzi | 964 | **1.024** |
| legami | 4.262 | **4.322** |
| nodi «Scheda Consiglio» | — | **60** |

Nessun dato è cambiato: è il disegno che non nominava un pezzo che esiste.

---

## 0.1.355 — Il RIVENDICARE non spreca il diritto: spreca la prenotazione (D-389)

**Chiusa [ISSUES 53](docs/ISSUES.md#53)**, la voce che diceva *«RIVENDICARE può
forzare un Consiglio che poi non si apre»*. D-261 aveva cambiato la regola e
lasciato scritto che le **43 aperture rifiutate** andavano rimisurate sotto
quella nuova. Rimisurate, su 100 partite:

| il diritto del RIVENDICARE, dove va a finire | |
|---|---|
| apre un secondo dibattito | 15 |
| speso in controproposta | 59 |
| **si spegne senza trovare niente** | **0** |

Zero, e i tre numeri chiudono il conto: 15 + 59 + 0 = 74, esattamente i Consigli
strappati.

### E per strada, un conto sbagliato da sempre

La stessa sonda dichiarava **12** Consigli strappati, e i tre numeri qui sopra ne
chiedevano **74**. Contava gli Effetti `CONSUME_CLAIM` — ma D-191 dice che
**senza prenotazione non c'è niente da consumare**: chi strappa un Consiglio su
una domanda già matura lo fa in una mossa sola, e quel FORCE non emetteva nessun
Effetto da contare.

**E questo corregge una frase di [D-387](docs/DECISIONS.md#d-387)**, scritta
ieri: *«131 diritti su 140 morivano senza essere usati»*. Quello che muore non è
il diritto — è la **prenotazione**.

| su 100 partite | |
|---|---|
| prenotazioni aperte | 285 |
| **prenotazioni mai spese** | **273** |
| Consigli strappati senza averne bisogno | 62 su 74 |

Il RIVENDICARE **rende**, 74 volte su cento partite. Quello che quasi non serve
mai è la sua **prima metà**: il cervello prenota 285 volte e spende 12. Aperta
[ISSUES 126](docs/ISSUES.md#126), con due letture — è il cervello, o è la regola.

**Nessuna regola è cambiata**: sono due righe di una sonda.

---

## 0.1.354 — La sonda che diceva 92,3% guardava dalla parte sbagliata (D-388)

Rimisurando la superficie contesa sul codice di oggi, una riga non tornava:

```
condition:contested         0 /   60   <-- MAI
```

**Il mondo lo scrive 452 volte in cento partite.** Uno zero su una cosa che
succede quattro volte a partita non è un difetto del gioco: è la sonda che
guarda dalla parte sbagliata — la trappola che questo progetto ha già pagato
cinque volte.

`run_contest_probe` chiedeva se una memoria temuta fosse comparsa **lì dove la
clausola la teme**, e il posto lo leggeva alla lettera: `region_id`. Ma una
clausola del pool **non può nominare una Regione** — la pesca chiunque, e dice
`$any` o punta un bersaglio a segni. Quindi **ogni clausola di Regione risultava
«mai toccata», sempre, per costruzione.**

| | diceva | dice |
|---|---|---|
| memorie temute che qualcuno ha provato a scrivere | **7,7%** | **24,6%** |
| `condition:contested` | 0 / 60 **MAI** | **58 / 2** |
| `condition:unrest` | 0 / 74 **MAI** | **42 / 32** |
| `condition:cut_off` | 0 / 14 **MAI** | 8 / 6 |

**Cosa resta vero, e adesso è un elenco corto e onesto:** sei segni che una
clausola teme e che in cento partite nessuno ha mai scritto — `valley_sealed`,
`crystal_exploited`, `failed_proposal`, `no_charter`, `relic_buried`,
`relic_shown`. Tutte memorie globali, tutti punti che nessuno può rompere. È la
strada 2 di ISSUES 96, e sono carte stampate: la scelta è del committente.

**E il resto della misura, rifatto sul gioco di oggi:**

| | D-321 (0.1.283) | oggi |
|---|---|---|
| clausole già vere all'apertura | 54,3% | **47,6%** |
| clausole contese | 21,4% | **24,1%** |

Tutti e due nella direzione che ISSUES 91 chiede, e la ragione si legge:
`did_this_year` porta **152 clausole** che nessuno contende ma che nessuno trova
già fatte — un obiettivo che chiede un gesto non è contendibile, ma non è
nemmeno dotazione.

**Nessuna regola è cambiata**: è una sonda, non il gioco. Suite 679/101/86.480
verde.

---

## 0.1.353 — Quattro decisioni del committente: l'Eredità, il gesto, la moneta

Quattro voci che erano **sue e non mie** sono state decise, e sono scritte.

### L'Eredità: +3 per ogni leggenda che porta il tuo nome ([D-385](docs/DECISIONS.md#d-385))

Chiude [ISSUES 84](docs/ISSUES.md#84). Una leggenda porta il tuo nome quando
racconta uno dei segni che la tua casa aveva dichiarato di voler lasciare. Non
la scrive nessun giocatore: la fabbrica il **tempo**, al salto d'era.

| su 24 saghe | |
|---|---|
| saghe in cui l'Eredità **ribalta il vincitore** | **10 su 24** |
| accordo con chi ha più Trionfi, con e senza | 3 su 24 → 3 su 24 |

**Il costo dichiarato: due case su otto prendono zero, sempre** — Nahr e Vaerax.
Non giocano male: i segni che vogliono lasciare sono muri e insediamenti, e un
segno di Regione non diventa mai leggenda; oppure sono `enduring_facts`, e un
fatto che il mondo tiene per vero per sempre non è una cosa di cui *si racconta*.
Aperta [ISSUES 124](docs/ISSUES.md#124).

### Il tempo del verbo: una clausola che legge il verbale ([D-386](docs/DECISIONS.md#d-386))

Chiude la parte fattibile di [ISSUES 120](docs/ISSUES.md#120). `did_this_year`
è la prima clausola del vocabolario che non guarda **come sta il tavolo** ma
**cos'è successo**: legge il registro degli Effetti dell'anno e cerca uno di
quattro gesti — alzare una Pietra, prendere una terra, posare una presenza,
stringere un legame.

| obiettivi che rendono uguale o meglio **stando fermi** | 6 | **3** |
|---|---|---|

Curati `BOUND_HOUSE` (da −19% a **+12%**), `THE_LONGEST_REACH` (−10% → **+4%**),
`THE_WIDEST_SPREAD` (+0% → **+7%**). **Peggiorati e scritti**: `MOST_STONE` da
+0% a **−7%** e `A_WORK` da −3% a **−6%**.

E il numero che conta di più: **quanto rende giocare da +160,7% a +267,8%**, con
i Destini che si avverano da fermi da due a **uno**.

I tre che restano hanno una causa sola, misurata: **nessuna Azione della plancia
alza una Pietra** — una in cento partite — e le Pietre le alza il Consiglio, che
è **più generoso con un tavolo che tace** (199 contro 165). Aperta
[ISSUES 123](docs/ISSUES.md#123).

### I gettoni di rivendicazione ([D-387](docs/DECISIONS.md#d-387))

Chiude a metà [ISSUES 122](docs/ISSUES.md#122), con la regola dettata dal
committente. Il proponente posa **un beneficio gratis**; ogni altro costa **un
gettone RIVENDICARE**, che si guadagna giocando una carta Asset dalla sua faccia
RIVENDICARE. Gli altri si astengono, o spendono un gettone per **posare un
costo**. Se nessuno spende, la proposta passa senza prezzo.

| su 100 partite | prima | dopo |
|---|---|---|
| benefici comprati per Consiglio | 1,71 | **1,40** |
| **costi posati dagli avversari, per Consiglio** | **0,09** | **0,68** |
| costi posati in tutto | 34 | **217** |

Prima, in 364 Consigli gli avversari sceglievano **34 prezzi**: tutto il resto lo
riempiva il mondo dall'alto della lista, e la frase di D-280 — *«gli avversari
scelgono in che moneta paga»* — nei fatti non succedeva.

**Il costo dichiarato:** le caselle vive per Consiglio non sono salite, sono
**scese**. Con 2,8 carte RIVENDICARE giocate per partita i gettoni bastano per
circa un acquisto in più *per partita*, non per Consiglio. Aperta
[ISSUES 125](docs/ISSUES.md#125).

E RIVENDICARE adesso rende due volte: prima, **131 diritti su 140 morivano senza
essere usati** in cinquanta partite.

### ISSUES 119 riscritta con gli esempi

Su richiesta del committente: cosa si vede al tavolo quando un Consiglio passa e
quando cade, cosa vive nella banda del fallimento — `spoke_and_lost` si posa
**8 volte in cento partite** — e le tre strade con un esempio ciascuna.

### Il grafo: un elenco invece di un nome da indovinare

Su richiesta del committente. Il bottone **elenco** apre tutti i **964 pezzi**
raccolti per genere — 48 carte, 60 Tensioni, 194 proposte, 174 segni… — con un
filtro che restringe. Prima l'unico modo di arrivare a una carta era scriverne
il nome.

Nel disegno entrano anche i quattro **gesti** e la **moneta** del Consiglio:
964 pezzi, 4.262 legami; pezzi senza nemmeno una freccia **12 → 7**.

### E per strada

- **Gli obiettivi non erano in `REVISIONE_TESTI.md`**: diciassette carte che si
  tengono in mano tutto l'anno, in un documento che promette *ogni testo che un
  giocatore può leggere*. 2.898 → **2.968 testi**.
- **Un segnalino in più nella scatola**: 118 tipi → **119**, 142 pezzi → **154**.
- Due EffectType nuovi, `GRANT_CLAIM_TOKEN` e `SPEND_CLAIM_TOKEN`, l'uno
  l'inverso dell'altro.

**Cancello:** 0 seggi bloccati su un solo livello su 8, tavolo misto e uniforme.
Suite **679 prove / 101 suite / 86.480 asserzioni** verdi, ventisei cancelli
verdi.

---

## 0.1.352 — La prima delle tre riviste: quello che si legge col dito (D-384)

Delle tre riviste che si nascondono in *«tutta la pagina va rivista»*
(ISSUES 65), fatta **la prima** — quella che la voce stessa dichiara finibile, e
che da D-379 ha un metro.

| | prima | dopo |
|---|---|---|
| **testi che vivono solo nel suggerimento del mouse** | **13** | **2** |
| **bersagli più stretti di un dito (44 px)** | **7 su 7** | **0** |

Spostate sotto gli occhi: le **nove ragioni** di un segno voluto o temuto, la
**descrizione della vita** che ti aspetta alla porta del tempo, e il **nome
dell'Eco** sulla carta in mano — *«forza 2 · eco: La Parola Data»*. Tolti due
suggerimenti che ripetevano una nota già stampata.

I sette posti dove si lascia cadere una carta chiedevano 19 e 29 pixel: adesso 44,
la stessa misura che D-243 aveva già stabilito per le carte in mano. **È il
bersaglio a crescere, non il testo.**

I due che restano sono il testo intero dei due Echi in mano: stamparlo vuol dire
allungare la carta, e quella è la **seconda** rivista. L'impaginazione e l'idea
di cosa si guarda restano scelte del committente.

Cancello: **0 seggi bloccati su 8**. 26 cancelli verdi, suite verde.

---

## 0.1.351 — I sei livelli di vittoria nominano un segno, e una guardia si è allargata (D-383)

D-377 aveva misurato **sei livelli di vittoria o trionfo** che si reggono solo
sul contare, tutti sui Destini condivisi. Un segno **del mondo** non è di
nessuno, ed è la strada che la casa aveva già in uso: sei clausole, una per
livello, ognuna con un segno che quel Destino **dichiara già di osservare**.

| | prima | dopo |
|---|---|---|
| livelli che si reggono solo sul contare | 17 su 69 | **11 su 69** |
| **di cui vittoria o trionfo** | **6** | **0** |

Gli undici che restano sono tutti il `minimum`, dove il conto è la cosa giusta.
Ogni segno scelto contro la misura: tutti e sei sono scritti dal mondo su cento
partite, da 458 volte (`condition:contested`) a 13 (`condition:abandoned`).

**E una guardia che modellava il motore meno generoso di com'è.** Tre clausole
hanno fatto cadere `test_no_destiny_asks_for_a_tag_nothing_can_write`, che
dichiarava `settlement:village`, `structure:archive` e `knowledge_shared` non
scrivibili da niente: sono scritti 42, 43 e 145 volte. Alla lista delle penne
mancavano **le caselle della carta Tensione** e **i gradi delle Pietre**. È D-376
visto dall'altra faccia — lì la guardia assolveva, qui avrebbe vietato una
clausola vera. Allargata e provata piantando un difetto.

**Costi:** gli obiettivi avverati scendono da 453 a 438 su 1.200, e il vantaggio
di giocare da +168,0% a +160,7%. In cambio tre Destini condivisi su quattro
pagano meglio chi gioca. `SHARED_QUIET` resta l'unico che si avvera da fermi, e
non lo ribalterebbe nessun segno: chiede che le questioni restino basse, e un
tavolo che non fa niente le tiene basse per definizione.

Cancello: **0 seggi bloccati su 8**, misto e uniforme. 26 cancelli verdi.

---

## 0.1.350 — Un Tema con una carta sola, e due caselle che nessuno comprava (D-382)

**L'Antico riceveva 32 Risonanze su 3.725, lo 0,9%**, ed era in cima al Punto
Zero da nove versioni. La causa non era sottile: **una carta su 48, una copia
nel mazzo, un punto di calore** contro le trentasette copie della Fede.

Spostate **otto Risonanze**, scegliendo le carte in cui il Tema nuovo era già
nella frase d'autore — *«è una cosa che c'era prima dell'accordo»* (Legame di
Sangue), *«chi ricorda decide cosa c'era prima»* (Consiglio degli Anziani). Il
testo stampato nomina il Tema, quindi riscriverlo era metà del lavoro.

| dove finisce il Calore | prima | dopo |
|---|---|---|
| Fede | 33,7% | 22,9% |
| **Antico** | **0,9%** | **20,7%** |
| Terra | 7,0% | **9,9%** |

**E la porta murata si è aperta da sola.** `mountain_forgotten` era l'ultima
clausola che chiedeva una cosa che il mondo non scrive mai. Con l'Antico che si
apre, il mondo la scrive: **porte murate 1 → 0**.

### Le due caselle di ISSUES 117

**ABBASSA LA DOMANDA** era offerta 730 volte e comprata **zero**: valeva 1
contro il 3 di CAMBIA CONTROLLO, e il primo beneficio è gratis. Adesso **legge
quello su cui agisce** — raffreddare una domanda a terra non vale niente,
raffreddarne una a un passo dal Consiglio vale quanto alzare una Pietra.

Provata prima a 3: comprata 393 volte su 716, e le altre si svuotavano. **Una
casella che mangia le altre è sbagliata quanto una che nessuno compra.** Scesa
a 2 — e allora è crollata RAFFREDDA TEMA, che ha avuto la stessa cura: vale 2 se
è il Tema **col rombo più avanti**. Poi è caduta una prova, e aveva ragione lei:
MUOVI UN RAPPORTO, offerto nove volte in cento saghe, non veniva più preso.

| casella | prima | dopo |
|---|---|---|
| **ABBASSA LA DOMANDA** | 0 su 730 | **26 su 728** |
| **RAFFREDDA TEMA** | 22 su 365 | **115 su 364** |
| MUOVI UN RAPPORTO | 2 su 7 | **6 su 9** |

**UNA CASATA LASCIA IL TAVOLO resta a zero, e la decisione è di lasciarla lì:**
lo zero è la congiunzione (Vaerax al tavolo *e* quella carta in discussione), non
la casella. È la cosa più drastica del gioco e vale una applicazione in tutto il
corpo scritto.

**Costi dichiarati:** UNA PIETRA SALE scende da 14 acquisti a 2; le
trasformazioni sedute da 233 a 226; i Consigli cadono ancora un po' meno (37 → 28
sul misto). E i segni che non arrivano mai sul tavolo scendono da 52 a **48**.

**Quello che non si chiude tarando:** il primo beneficio è gratis, quindi viene
preso solo quello che vale di più, e a parità vince sempre lo stesso. Ogni
casella alzata ne spegne un'altra. Aperta come **ISSUES 122**.

Cancello: **0 seggi bloccati su 8**, misto e uniforme. 26 cancelli verdi.

---

## 0.1.349 — Il Punto Zero rimisurato, e due tavoli che erano scambiati

`PUNTO_ZERO.md` è il primo documento che `CLAUDE.md` dice di leggere, ed era
**fermo alla 0.1.294** — cinquantaquattro versioni — con una banda in cima che
elencava i numeri che sapevo cambiati. Una fotografia con una didascalia non è
una misura.

Rifatto per intero, con le sonde rilanciate oggi: `run_pass_probe`,
`run_asking_probe`, `run_resonance_probe`, il cancello dei cento semi, e i
documenti generati che un cancello tiene freschi.

| | diceva | oggi |
|---|---|---|
| suite | 634 prove / 35.900 asserzioni | **665 / 86.347** |
| cancelli | 19 | **26** |
| turni «passa» | 47,3% | **46,7%** |
| quanto rende giocare | +183,1% | **+168,0%** |
| Destini che si avverano da fermi | 3 su 19 | **2 su 23** |
| segni nel dizionario / che qualcuno scrive | 182 / 149 | **174 / 170** |
| carte con una domanda in prestito | 28 | **0** |
| Effetti che una casella sa dire | *«il motore non esegue»* | **44 su 46, 334 applicazioni su 336** |
| da stampare | 39 fogli A4, 67 tipi di segnalino | **49 fogli, 118 tipi** |

E sei misure che nella versione vecchia non esistevano: i segni che non arrivano
mai sul tavolo, i punti regalati e le porte murate, le vite che non si siedono,
i testi in revisione, i pezzi del flusso disegnato, e la pagina dell'app.

**La voce più grossa del progetto non c'è più.** Quel foglio diceva *«il motore
non esegue la risoluzione della proposta: 642 Effetti d'autore che nessuna carta
stampa»*. ISSUES 89 è chiusa da 0.1.332.

### E una correzione: i due tavoli erano scambiati

D-378, la sua riga qui e ISSUES 119 dicevano *«FAILURE da 108 a 37 sul tavolo
uniforme, da 25 a 14 sul misto»*. È il contrario: **la sonda stampa il misto per
primo**, e li avevo letti al rovescio. I numeri sono quelli, le etichette no.
Corrette in tutti e tre i posti.

Cancello: **0 seggi bloccati su 8**, misto e uniforme. 26 cancelli verdi.

---

## 0.1.348 — I tre pezzi «che nessuno tocca» erano tre buchi del disegno (D-381)

D-380 aveva lasciato quindici pezzi senza nemmeno una freccia e li aveva messi in
due voci: dodici Obiettivi che si vincono contando (vera) e **tre pezzi che
«nessuno tocca»** (ISSUES 121). Quella voce era sbagliata.

| pezzo | diceva | i dati dicono |
|---|---|---|
| `uprooted` | nessuno lo posa | lo posa **chiunque tolga una presenza**: undici pezzi (D-130) |
| `scar:burned_records` | Cicatrice che nessuno incide | la lascia **l'Archivio in rovina**, e ogni Pietra ha la sua |
| `ACT_ACQUIRE` | Azione che nessuno nomina | le danno un valore **tutte e ventisei le vite** |

Il disegno non le vedeva perché sono tre regole che nel dato **non sono un
effetto**: la conseguenza di un gesto, una faccia della Pietra (`ruin`), un numero
sulla carta della casa (`action_values`). La regola della cacciata non è stata
ricopiata: si **importa** da `validate_physical`, dov'era già scritta.

**Legami 4033 → 4232. Pezzi senza una freccia: 15 → 12**, e i dodici che restano
sono gli Obiettivi della 120 — quelli sì, contenuto.

La lezione: un disegno appena finito è la cosa di cui ci si fida di più e ci si
dovrebbe fidare di meno. Quindici pezzi isolati sembravano quindici scoperte;
erano tre regole mancanti e dodici scoperte vere.

**E la copia da pubblicare la fa lo strumento.** Un Artifact incarta quello che
gli si dà dentro un `<body>` suo: fin qui gli si consegnava il file intero, col
suo `<!doctype>` e il suo `<head>`, e funzionava **per tolleranza del browser,
non per costruzione**. `build_flow.py --artifact=PATH` toglie l'involucro e
lascia il contenuto — con una guardia che si ferma se l'involucro non viene via,
perché una pagina pubblicata a metà non se ne accorgerebbe nessuno.

Costo: nessuno. Cancello **0 seggi bloccati su 8**. 26 cancelli verdi.

---

## 0.1.347 — Il disegno del flusso conosceva tutto tranne la cosa centrale (D-380)

Parola del committente: *«clicco su una carta e mi dà tutto quello che fa»*.

`flusso.html` mostrava le carte, i segni, le Pietre, i Destini, le caselle — e
**dodici proposte**, quelle dei template, che dal 0.1.345 il motore non legge più
per nessuna carta. Delle **120 domande** e delle **194 proposte** che stanno sulle
carte, niente. Terza volta che una sonda guarda ancora la casa vecchia, dopo il
catalogo dei Consigli (0.1.273) e la revisione dei testi (0.1.345).

Adesso la catena si percorre col dito: **una carta apre una domanda, la domanda ha
le sue risposte, una risposta porta una Conseguenza, la Conseguenza posa un
segno** — e il segno, girato, dice chi altro lo guarda.

| pezzo nuovo | quanti |
|---|---|
| Domande | 120 |
| Proposte (dalle carte) | 194 |
| Vite delle case | 26 |
| Clausole | 21 |
| Obiettivi | 17 |
| Consigli | 12 |
| Profili strategici | 8 |

**573 → 959 pezzi, 3118 → 4033 legami.**

Le vite hanno chiuso un buco che si vedeva senza saperlo leggere: `twice_uprooted`
era un segno che nessuna freccia toccava. Lo legge la successione.

**Due cose che il disegno diceva male.** Il riquadro porta ventidue lettere, e
*«La montagna fuma di n…»* non è una domanda: adesso c'è **la scheda del pezzo
scelto**, con la frase intera e quello che quel pezzo dichiara. E i rami hanno un
ordine — prima la catena del Consiglio, poi quello che resta al mondo, poi il
minuto — perché col tetto di nove per sorgente restavano fuori proprio le domande.

**Il ponte, invece della copia:** quale Consiglio serve quale carta lo scrive
**chi la regola la esegue** — `run_council_catalogue.gd`, in fondo al catalogo — e
`build_flow` lo legge, con una guardia che ferma il disegno se il ponte sparisce.

**E quindici pezzi restano senza nemmeno una freccia**, ognuno una cosa vera:
dodici Obiettivi su diciassette si vincono contando e non nominano nessun pezzo
del tavolo (lo stesso difetto che D-377 ha misurato sui Destini), due segni che
nessuno posa né legge, e `ACT_ACQUIRE`, l'unica Azione che nessuna carta nomina.

Costo: nessuno, né motore né dati. La pagina passa da 538 a 732 KB, provata con
Chromium. Cancello: **0 seggi bloccati su 8**. 26 cancelli verdi.

---

## 0.1.346 — La pagina si misura, così la prossima passata non costa un pomeriggio (D-379)

ISSUES 65 porta una frase sola del committente — *«tutta la pagina dell'app va
rivista»* — e accanto la ragione per cui è ferma da trentacinque versioni:
**nessuna sonda tocca questa pagina**, quindi ogni giro costa il pomeriggio di
una persona con l'app in mano, ed è successo tre volte di fila.

Scritta la sonda: `cli/run_page_survey.gd` → `docs/MISURA_PAGINA.md`, cancello in
CI. Ventisei cancelli invece di venticinque.

| | |
|---|---|
| **testi che vivono solo nel suggerimento del mouse** | **13** |
| **bersagli più stretti di un dito (44 px)** | **7 su 7** |
| **parole tecniche sotto gli occhi** | **1** |
| larghezza chiesta in fila, senza la mappa | **788 px** su un tablet da 768 |

**E quello che la sonda non vede lo scrive.** Il testo ricco headless non si
legge — `text` e `get_parsed_text()` tornano tutti e due zero, provato — quindi
il documento conta i blocchi e dichiara di non saperli leggere. Due pannelli
(la mappa e i mazzetti dei Temi) **dipingono invece di costruire nodi**: questa
sonda non li vede, e nemmeno un lettore di schermo. La cornice resta fuori
perché nomina un autoload che una sonda a riga di comando non ha, quindi
7 bersagli è un pavimento, non un totale.

Presa in pieno la trappola di casa: il primo giro contava **118 nodi**, cioè
pannelli quasi vuoti che sembravano puliti — `_ready()` non arriva a un nodo
seduto prima che il ciclo parta. E il riconoscitore delle parole tecniche ne
trovava undici, dieci delle quali erano italiano con i due punti dentro: adesso
un segno **si chiede al dizionario** invece di indovinarlo.

**Non ripara nessuno dei venti difetti che ha contato**, ed è deliberato: la 65
dice *«fatto quando c'è una decisione scritta su quale delle tre riviste si sta
facendo»*, e quella è del committente. Adesso ce l'ha davanti con dei numeri.

Cancello: **0 seggi bloccati su 8**, misto e uniforme. 26 cancelli verdi.

---

## 0.1.345 — Gli ultimi tre Temi, e la sonda che leggeva ancora la vecchia casa (D-378)

**Ventotto carte su sessanta aprivano il dibattito di un'altra.** Tredici carte
del dominio ANTICO chiedevano tutte *«Chi tiene d'occhio quello che c'è
$in_region?»*: al tavolo si leggeva la stessa riga tre volte.

Il lavoro era fermo *«in attesa della parola del committente»* su ISSUES 89 —
che è **chiusa da 0.1.332**. L'attesa era finita e nessuno l'aveva notato.

Scritti i tre Temi che mancavano, uno per volta: **Antico** (9 carte, 18 domande,
27 proposte), **Fede** (9 / 18 / 27), **Terra** (10 / 20 / 30). **28 → 19 → 10 →
0 carte in prestito**, e i 194 testi delle proposte sono 194 testi diversi.

**E la terza sonda che guardava ancora i template.** `REVISIONE_TESTI.md`
promette *«ogni testo che un giocatore può leggere»* e la sua sezione 5 leggeva
i template: **saltava 314 testi** — tutte le domande e tutte le proposte vere —
e ne mostrava 194 che ormai nessuno legge. Il cancello non se ne accorgeva
perché confronta il documento col generatore, non il generatore con la realtà.
Adesso legge le carte, e stampa anche le **clausole**, che nessuna sezione
mostrava.

**Il costo, misurato:** i Consigli cadono molto meno — FAILURE da **108 a 37**
sul tavolo misto, da **25 a 14** sull'uniforme (le etichette erano scambiate:
corrette in 0.1.349). Ogni carta offre tre strade sue,
e il tavolo ne trova una che gli va bene. Un Consiglio che quasi non cade ha
meno posta: aperta come **ISSUES 119**.

Il primo effetto collaterale è stato chiuso subito: meno fallimenti, meno
`rumour_running` — che lo scriveva solo il sacchetto dei fallimenti ANTICO — e
si riapriva una porta murata che D-372 aveva appena chiuso. Scritta
**`CNS_WORD_GOES_ROUND`**: il Consiglio decide di non decidere, e la voce corre
lo stesso.

| | prima | dopo |
|---|---|---|
| carte con una domanda in prestito | 28 su 60 | **0 su 60** |
| testi di proposta distinti | 122 su 186 | **194 su 194** |
| testi in `REVISIONE_TESTI.md` | 2486 | **2898** |
| punti regalati / porte murate | 2 / 1 | **1 / 1** |
| vite che non si siedono mai | 2 | **1** |
| trasformazioni sedute in 12 saghe | 223 | **233** |
| segni che non arrivano mai sul tavolo | 50 | **52** |
| Consigli caduti (misto / uniforme) | 108 / 25 | **37 / 14** |

Guadagno non in programma: **La Leggenda della Montagna si siede**.

Cancello: **0 seggi bloccati su 8**, misto e uniforme. 25 cancelli verdi.

---

## 0.1.344 — Un `#granaio` si indica col dito, ma nessuna Tensione lo scrive (D-377)

`MISURA_MATRICE.md` contava **31 livelli di Destino su 69** che «si reggono solo
sul contare». Quattordici non lo erano.

Due erano clausole che il dito lo si punta eccome — il segnalino sulla traccia di
una domanda è **la cosa più indicabile del gioco**. Dodici chiedevano un
**bersaglio a segni**: *«una pedina dove c'è il #granaio»*, la grammatica fisica
del gioco (D-274). La misura guardava `tag` e non `any_tag`, così *«il trono
regge»* — una pedina dove c'è la **#capitale** — risultava un totale a mente.

E un numero solo faceva due mestieri: al punto 2 la domanda è *«si capisce dove
guardare?»* e un `#granaio` basta; al punto 5 è *«una Tensione può parlarne?»* e
un `#granaio` non serve, perché nessuna Tensione lo scrive. Adesso sono **due
numeri**, e la frase del punto 5 non cambia: era giusta col numero giusto per
caso.

Dei 17 che restano, **undici sono il `minimum`** — la soglia sotto la quale la
casa non c'è più, dove il conto è la cosa giusta. Gli altri **sei sono vittoria o
trionfo, e stanno tutti su Destini condivisi**: un obiettivo che deve valere per
tutti non può nominare il segno di nessuno. Scelta di disegno, non difetto: sta
al committente.

Chiuso a mano un caso solo: **`DST_SHARED_LORE` non guardava niente**
(`observes: []`, unico su 23). Adesso guarda `crystal_site`, `mine_sealed`,
`knowledge_shared`, `rumour_running`. `observes` non entra in nessuna condizione
di vittoria: costo di equilibrio zero per costruzione.

| | prima | dopo |
|---|---|---|
| livelli «solo conteggi» | 31 | **17** |
| di cui vittoria o trionfo | 9 | **6** |
| livelli che non nominano nessun segno | *non misurato* | **31** |
| Destini che non guardano niente | 1 | **0** |

Cancello: **0 seggi bloccati su 8**, tavolo misto e uniforme. 25 cancelli verdi.

---

## 0.1.343 — Uno zero che una sonda non può evitare non è una misura (D-376)

`MISURA_TAVOLO.md` contava **58** segni che non arrivano mai sul tavolo.
Guardati per famiglia, due erano **intere**: `life:` 26 su 26, `legend:` 3 su 3.
E una famiglia dove non arriva niente non è contenuto raro: è una penna.

La sonda fa `setup` + `run` — **un anno, una partita**. Il passaggio fra un'era e
l'altra non avviene mai, e quei segni il motore li scrive **solo lì**.
**Ventuno dei 58 non potevano arrivare per costruzione**, e stavano accanto a un
segno che davvero nessuno posa, sotto la stessa parola.

Adesso li chiama **fuori portata** e dice dove si misurano — e l'elenco è
ricavato dalle incarnazioni delle Case e dal prefisso nel dizionario, non
scritto a mano (lezione di D-373).

**E otto gettoni che nessuno potrà mai posare.** Le vite fondatrici avevano un
segno `life:` nel dizionario, con posto e cartone, e il motore non lo scrive —
la fondatrice si riconosce dal *non* averlo. La guardia non li vedeva perché
dichiarava che una Casa scrive il segno di *ogni* incarnazione: **una guardia
che modella il motore più generoso di com'è non protegge, assolve.** Allineata,
ha nominato tutte e otto le voci morte.

| | prima | dopo |
|---|---|---|
| segni che «non arrivano mai» | **58** | **29** |
| di quelli, fuori portata | — | **21** |
| voci del dizionario | 182 | **174** |
| difetti piantati | 41 | **42** |

I ventinove che restano sono difetti veri, e sono già divisi per causa.

Nessun costo: **0 seggi bloccati su 8** e le Verità non si muovono di una riga.

---

## 0.1.342 — L'arte non è bloccata da niente (D-375)

Le illustrazioni non le disegna chi scrive il codice — 144 soggetti su 155 sono
segnaposto. Ma una domanda vicina si poteva chiudere, e vale prima di
commissionare: **se domani arrivano 144 file, il gioco li prende?**

Provato posando un PNG vero al posto di un segnaposto e guardando ogni punto
della catena: il censimento passa da 11 a 12, l'app lo carica, e **il foglio di
stampa lo incorpora** — `asset_01.svg` e `asset_06.svg` portano quattro
`<image>` ciascuno col disegno dentro.

**Non c'è niente da sbloccare**, e le illustrazioni si possono consegnare **una
alla volta**: la scatola si stampa a ogni stadio.

**E una lettura sbagliata, corretta guardando.** Il README dell'export dice
«l'arte è segnaposto», e se ne era concluso che il foglio ignorasse i file
consegnati. Falso: quella riga descrive lo stato di oggi, non il comportamento.
È D-373 al contrario — là una prosa diceva il falso sui dati, qui una prosa vera
sui dati è stata letta come falsa sul codice. **In tutti e due i casi la cura è
guardare, non leggere.**

Nessun costo: non cambia una riga sotto `godot/`.

---

## 0.1.341 — La porta del tempo dice quando si cambia pelle, non quale (D-374)

Sette vite scritte su diciotto non si sedevano **mai** in dodici saghe.
Sembrava contenuto raro. **Quattro erano murate per costruzione**, e la prova è
che una di loro aspetta `debt_called`, un fatto che il mondo scrive **232 volte
su cento partite**.

La causa è la porta del tempo di D-290: il motore la consulta **prima** della
linea esaurita, e salta gli indici di mezzo senza guardarli. Le quattro vite
murate stanno esattamente lì, davanti a una vita con quella porta — che si apre
a 150 anni mentre la linea si esaurisce a 393-565.

**La cura è una regola già scritta**: D-109, *«fra più vite candidate sceglie la
storia giocata»*. La porta del tempo dice *quando* si cambia pelle; i segni
dicono *quale*.

| in dodici saghe | prima | dopo |
|---|---|---|
| **vite mai sedute** | **7** | **2** |
| trasformazioni | 210 | **223** |
| Il Banco Nero | 0 | **9 / 8** |
| I Forni Riaccesi | 0 | **9 / 6** |

**Il prezzo, dichiarato:** La Compagnia del Sale scende da 9/8 a 1/1 — è il
posto ceduto al Banco Nero. La Compagnia entrava perché il tempo passava, il
Banco entra perché il debito è stato chiamato.

**E un'ipotesi bocciata da una prova esistente**, tenuta a verbale: far valere
`legend:<fatto>` come il fatto nudo sembrava ovvio, e distruggeva la
distinzione fra un fatto vivo e uno sbiadito su cui la Leggenda della Montagna
si siede al posto del corpo. Tolta.

Le due che restano sono entrambe di Vaerax e bloccate per costruzione: una entra
`ON_DEATH` dietro una casa che non muore, l'altra aspetta il terzo anello della
catena delle ere. Da decidere, non da riparare.

Playtest identico a D-372 riga per riga — il playtest gioca anni singoli e le
successioni non scattano. **0 seggi bloccati su 8.**

---

## 0.1.340 — Un numero battuto a mano si fa certificare fresco mentre mente (D-373)

`COMPONENTI.md` diceva *«nessuna delle dieci tessere dice quanti spazi-Pietra ha
né quali»*. Vero quando fu scritto, falso da **sei versioni**: D-365 ha messo
`build_slots` su tutte e dieci. Il cancello non ha detto niente, e ha ragione
lui: controlla che il file combaci col generatore, non che il generatore dica la
verità.

**Non era una, erano tre**, cercate col metodo invece che a occhio:

| diceva | i dati dicono |
|---|---|
| «i **183** segni del dizionario» | **182** |
| «Presenza e controllo — **12** per casa» | la Cronaca ne dichiara **5** |
| «nessuna delle dieci dice quanti spazi-Pietra ha» | tutte e dieci, **21 spazi** |

La seconda è la peggiore: `COMPONENTI.md` è il documento che si manda a chi
stampa, e quella riga faceva tagliare **più del doppio** delle pedine di presenza.

Le tre frasi adesso si **ricavano**. La prova che è la strada giusta era già nel
file, due righe sotto: il paragrafo dell'arte non è mai invecchiato perché è
sempre stato un conto.

**E una guardia**: prima di generare, lo strumento legge la propria prosa e
pretende che ogni cifra arrivi da un conto. Le eccezioni si dichiarano una per
una con la ragione per cui non invecchiano. Provata piantando il difetto.

E una cifra che questo censimento non può ricalcolare — quella di un'altra sonda
— non è stata inventata: è stata tolta, lasciando la frase a dire la cosa vera.

Nessun costo sul gioco: non cambia una riga sotto `godot/`.

---

## 0.1.339 — Il blocco di D-348 non c'era più (D-372)

D-348 aveva scritto la seconda penna di `mine_sealed`, l'aveva misurata (3
scritture su 100 anni contro 0) e l'aveva **ritirata** perché faceva cadere
`test_claim_policy`. Da allora la voce aspettava di capire perché.

Rimessa la proposta identica, e prima di ragionarci sopra **riprodotto il
guasto** — che è la prima cosa da fare e l'unica che dice la verità. **Il test
non cade più**, e nemmeno nessun altro.

Ventitré versioni separano D-348 da qui, e in mezzo la politica di
rivendicazione è cambiata: fra le altre D-191, che ha aggiunto la presa di
parola in un colpo, cioè proprio il ramo che decide se una domanda si prenota o
si strappa. Il blocco era reale allora ed è stato sciolto da un'altra parte,
senza che nessuno se ne accorgesse.

| su 100 partite | prima | dopo |
|---|---|---|
| `mine_sealed` scritto | **0** | **3** |
| punti regalati (temuti e mai scritti) | 5 | **3** |
| porte murate (voluti e mai scritti) | 4 | **1** |

**Le tre porte murate di Vaerax si aprono** — `DST_VAERAX · VITTORIA`,
`DST_VAERAX_LEGEND · VITTORIA`, `DST_VAERAX_LEGEND · TRIONFO` — e i tre punti
regalati a Lyra smettono di essere gratis.

**Resta chiuso** `DST_VAERAX_LEGEND · SOGLIA`: chiede il terzo anello della
catena delle ere, che vuole tre successioni di fila col sigillo intatto. Con tre
partite su cento, la catena non parte.

| su 100 anni, tavolo misto | prima | dopo |
|---|---|---|
| esiti FAIL | 110 | **108** |
| Verità scritte | 153 | **154** |
| **Verità diverse** | 137 | **139** |
| seggi bloccati su un solo livello | **0 su 8** | **0 su 8** |

Una strada in più che il tavolo può prendere è una storia in più che il mondo
può raccontare. Sul tavolo uniforme il movimento è opposto e della stessa
taglia, e si dichiara.

**La lezione:** una strada ritirata va **riprovata**, non archiviata. Il costo di
riprovare era un comando; quello di non riprovare sono state sei clausole morte
su tre Destini per ventitré versioni.

---

## 0.1.338 — Perché tre segni non si scrivono mai (D-371)

`mine_sealed` è mai scritto in cento partite, ed è insieme **tre punti regalati**
e **tre porte murate**. ISSUES 108 lo spiegava con due presupposti, e **nessuno
dei due regge**.

«`TEN_AWAKENING` non arriva mai al tavolo»: **arriva** — su cento partite ci
arrivano tutte e sessanta le domande, e il Risveglio in sei, con un picco di 17
contro una soglia di 6. Il «mai» veniva da venti partite.

«Dipende da una proposta sola»: **no** — la casella IL MONDO RICORDA lo scrive
già su due carte. Aggiunta anche alla terza, quella la cui domanda *è* la
miniera sigillata e che poteva dimenticarla senza saperla scrivere. Misurato:
resta a zero.

**Tre ipotesi provate e cadute** prima di quella giusta, e stanno tutte a
verbale perché ognuna sembrava ovvia: la casella mancante, «un segno che scrive
solo il Consiglio non esce mai» (falso: 29 segni, 3 a zero, e `order_restored`
ne fa 78), «conta su quante carte sta» (falso: `question_unresolved` non sta su
nessuna e ne fa 77).

| segno | template **generici** che lo producono | scritture su 100 partite |
|---|---|---|
| `order_restored` | **4 su 4** | 78 |
| `question_unresolved` | 1 | 77 |
| `mine_sealed` | **0** | **0** |
| `study_supervised` | **0** | **0** |
| `valley_sealed` | **0** | **0** |

**I tre mai scritti sono esattamente i tre che non stanno in nessun template
generico.** Vivono dentro il Consiglio di una carta sola, e quello non si apre
quasi mai: quattro domande pescate su sessanta, 3,5 Consigli a partita.

Detta come si direbbe al tavolo: **quello che può succedere solo dentro il
Consiglio di una carta sola, non succede.**

Nessun costo: il playtest dà gli stessi numeri di D-370, riga per riga.

---

## 0.1.337 — La Reggia esiste, e due voci vecchie rimisurate

Nessun codice: due voci di `ISSUES.md` che portavano numeri di sei versioni fa,
rifatte sui documenti sorvegliati invece che a memoria.

**ISSUES 111 diceva «dieci Pietre che non si alzano mai».** Erano sei a D-366 e
adesso sono **cinque** — e quello che se n'è andato è `structure:palace`, la
**Reggia**: il terzo grado del Presidio non era mai stato costruito in tutta la
storia misurata del gioco, era scritto nel catalogo e basta. L'ha alzato la
casella UNA PIETRA SALE di D-370. Confronto fatto sui due documenti committati,
non a occhio.

Il conto totale dei segni che non arrivano mai sale da 59 a 60, e **non è un
peggioramento**: `seal_kept` e `seal_kept_twice` sono entrati nel dizionario con
D-369, quindi adesso si contano. Non arrivavano nemmeno prima — non li guardava
nessuno.

E i cinque che restano sono **tre difetti diversi**, non una lista sola: uno è il
grado di mezzo che una frase d'autore salta, due sono Conseguenze mai scelte
(ISSUES 108), due sono Pietre che quasi nessuna carta costruisce.

**ISSUES 107** diceva «sedici carte su trentanove senza condizione stampata».
Sono **cinque su quarantotto**: gli Echi sono 48 da D-359 e D-362 li ha accesi
sui segni del mondo invece che sulla lotteria del limite di Tensione.

---

## 0.1.336 — Le caselle sulle sessanta carte (D-370)

D-366 ha dato al Consiglio ventiquattro caselle e cinque carte su sessanta le
usavano. **Ma un menu uguale su tutte le carte è il difetto che D-278 ha
corretto**, quindi la regola non è «aggiungi le caselle»: è **ricava le caselle
da quello che ogni carta ha già di suo**. 188 voci nuove, nessuna scritta a mano.

Il pezzo che vale di più: `linked_tensions` sta su tutte e sessanta le carte e lo
legge **una cosa sola**, l'azione INFLUENZARE. Il Consiglio non lo sapeva
toccare. Con `dove: QUESTION` ogni carta può muovere la domanda che ha legato a
sé, e sono quindici insiemi di legami diversi.

UNA PIETRA SALE/SCENDE va sulle carte che costruiscono una Pietra a **tre gradi
distinti**: non su Granaio, Canale, Pedaggio e Archivio, che hanno due gradi
collo stesso segno — una Pietra che sale senza che sulla tessera cambi niente è
una casella che non si vede. CHIUDI LA STRADA sulle quindici carte di TERRITORIO.

| in cento saghe | offerta prima | offerta adesso | comprata |
|---|---|---|---|
| UNA PIETRA SALE | **0** | **131** | 10 |
| CHIUDI LA STRADA | **0** | **9** | 0 |
| UNA PIETRA SCENDE | **0** | **1** | 0 |

**Ventitré caselle su ventiquattro sono offerte almeno una volta.**

**Le due cose che restano, scritte.** UNA CASATA LASCIA IL TAVOLO resta a zero:
vuole Vaerax al tavolo mentre si discute della sola carta che la offre, e la
congiunzione non capita — allargarla è una decisione di chi progetta, non una
misura. E ABBASSA LA DOMANDA fa **720 offerte e 3 acquisti**: il difetto che
D-343 aveva già dichiarato, che le carte nuove hanno raddoppiato.

**E un bersaglio che mentiva**, trovato passando: `CNS_SEALED_VALLEY` scriveva un
fatto del mondo con bersaglio `$adjacent`, uno su 68. Il motore lo eseguiva lo
stesso ignorando il bersaglio, quindi non lo vedeva nessuno. Adesso lo schema non
lo lascia tornare.

| su 100 anni, tavolo misto | prima | dopo |
|---|---|---|
| esiti FAIL | 107 | **110** |
| esiti SUCC netti | 110 | **107** |
| Verità scritte | 150 | **153** |
| seggi bloccati su un solo livello | **0 su 8** | **0 su 8** |

Tre proposte in più cadono, e tre Verità in più si scrivono. Il tavolo uniforme
non si muove. Un menu più largo rende più facile comprare qualcosa che gli
avversari possono far pagare caro.

---

## 0.1.335 — Il tempo è una penna (D-369) — chiude ISSUES 112

`seal_kept` e `seal_kept_twice` sono due anelli della catena delle ere: il mondo
li scriveva, l'app li stampava, avevano la scheda del disegno — e **non erano
voci del dizionario**. Il controllo *ogni segno toccato è nel dizionario* non li
vedeva, perché li nomina la catena dentro il dato di Cronaca e quel percorso il
censimento non lo raschiava.

Le due voci si aggiungono in un minuto; quello che chiude la questione è il
varco. Adesso una Cronaca **scrive** ogni anello e **legge** ogni anello — non
«ogni anello oltre il primo», che è quello che la prima stesura diceva e che la
guardia ha bocciato avendo ragione lei: `WorldStateFactory` scorre tutta la
catena per sapere a che punto è il conto.

Ha portato a galla una mano sbagliata che nessuno cercava: `mountain_forgotten`
diceva `written_by: ["tension"]`, e la catena lo posa eccome.

**E il disegno aveva lo stesso buco dall'altra parte**: le due voci comparivano
come pezzi senza una freccia. Adesso la catena delle ere è un pezzo del grafo.

| | prima | dopo |
|---|---|---|
| voci del dizionario | 180 | **182** |
| pezzi del disegno | 577 | **580** |
| difetti piantati | 40 | **41** |

**E la misura lo dice a voce alta**: i tre anelli *non arrivano mai* sul tavolo.
Non è un difetto nuovo — è ISSUES 108 che diventa visibile: la catena parte da
`mine_sealed`, che in cento partite nessuno scrive. Prima quel buco era coperto
da due segni fuori catalogo.

Nessun costo sul gioco: non cambia una riga sotto `godot/`.

---

## 0.1.334 — Il disegno conosce le caselle (D-368)

Il grafo scriveva **«sul luogo della domanda»** su ogni freccia che usciva da
una carta Tensione. Fino alla 0.1.332 era vero; da D-366 non lo è più, e un
disegno che lo scrive ancora mente — che è peggio di un disegno che tace.

E su **cinque caselle su otto taceva del tutto**: le due della presenza, il
rapporto, la domanda che si scopre, la casa che lascia il tavolo non toccano né
un segno né una Pietra, quindi non producevano nessuna freccia. Erano invisibili
nel documento che dovrebbe mostrare il flusso del tavolo.

Adesso **una casella è un pezzo del grafo**: si sceglie come una carta o un
segno, e si vede chi la offre e dove va a finire. I nomi si leggono da
`MISURA_CASELLE.md` — lo stesso ponte del controllo 24, non una seconda copia.

| `docs/flusso.html` | prima | dopo |
|---|---|---|
| pezzi | 552 | **577** |
| legami | 1748 | **2742** |

**E due guardie che sono la cosa che resta.** Il template filtra gli archi su
`VERBS` e i pezzi su `KINDS`: quello che non sta lì dentro finisce nel JSON e
sparisce dal disegno senza che nessuno lo dica. È successo scrivendo questa
versione — il verso «chiama» è entrato con le caselle, e tredici archi veri sono
stati generati e buttati via. Adesso lo strumento legge quelle due tabelle dal
template e si ferma prima. Più una terza: un `dove` o un `chi` nuovo nello
schema che nessuno ha imparato a raccontare ferma lo strumento invece di
scrivere una freccia vuota.

Nessun costo sul gioco: non cambia una riga sotto `godot/`. La copia pubblicata
come Artifact va ripubblicata a mano — il cancello sorveglia il file nel
repository, non il link.

---

## 0.1.333 — I cancelli sono gli stessi da tutte e due le parti (D-367)

La tabella «Il giro dei cancelli» di `CLAUDE.md` e i workflow sono due liste
scritte a mano nello stesso repository, e non c'era niente che le tenesse
uguali. In un giorno solo si sono scostate nei due versi: prima il documento ne
elencava sette e la CI ne girava otto, poi il documento ne elencava ventidue e
la CI ne girava diciannove.

Il secondo verso fa più male ed è quello che nessuno nota: **un cancello che non
gira non si lamenta.** E da D-366 uno dei tre mancanti era peggio degli altri —
`docs/MISURA_CASELLE.md` è il **lato motore** del controllo che tiene uguali
l'enum delle carte e il vocabolario che esegue: vecchio quel documento, quel
controllo dà verde per il motivo sbagliato.

**Non i tre passi mancanti e basta**: la guardia che tiene uguali le due liste,
`tools/gates_survey.py`, messa nel giro dove guarda anche sé stessa.

| | prima | dopo |
|---|---|---|
| cancelli in `CLAUDE.md` | 22 | **25** |
| di quelli, girati dalla CI | 19 | **25** |
| girati dalla CI e non documentati | 1 | **0** |

Aggiunti alla CI: lo scheletro delle carte, le caselle del Consiglio, il brief
d'arte. Aggiunto alla tabella: `run_sims.sh`, che la CI girava da sempre e il
documento non diceva.

E un cancello che era scritto due volte in due modi: il passo dell'export
controllava il brief con un `diff` a mano invece del `--check-brief` che il
documento promette. Adesso lancia il comando documentato.

Nessun costo sul gioco: non cambia una riga sotto `godot/`. I 25 cancelli
girano verdi, presi dalla lista di `CLAUDE.md` **letta a macchina** — contarli a
occhio è il modo in cui si è sbagliato due volte oggi.

---

## 0.1.332 — Una casella dice cosa fa, su chi, e dove (D-366) — chiude ISSUES 89

Le otto caselle che mancavano al Consiglio sono scritte. Ma misurando per
scriverle è saltata fuori la riga più grossa, che nessun documento guardava:
**venticinque Effetti su quarantasei avevano il verbo giusto e nessun posto dove
puntarlo** — 104 applicazioni, più di quelle che mancavano di verbo.

Non era contenuto che mancava: era un campo.

| campo | vocabolario | quando manca |
|---|---|---|
| `dove` | `FOCUS` · `ADJACENT` · `CAPITAL` · `RIVAL_SEAT` · `REGION_WITH` · `QUESTION` | dove si discute |
| `chi` | `PROPONENT` · `RIVAL` · `HOUSE_WITH` · `NOBODY` | chi propone |

Facoltativi tutti e due, e i valori di riposo sono come il Consiglio ha sempre
funzionato: nessuna delle sessanta carte di prima cambia di un millimetro.

**Le otto caselle**: POSA UN SEGNO SU UNA CASATA (44 applicazioni), MUOVI UN
RAPPORTO (11), UNA PRESENZA ENTRA O SE NE VA (10), UNA PIETRA SALE O SCENDE (9),
IL MONDO DIMENTICA (3), UNA DOMANDA VELATA SI SCOPRE (2), UNA CASATA LASCIA IL
TAVOLO (1), CHIUDI LA STRADA (1). Sei stanno in tutte e due le liste: con `chi`
la stessa casella cambia segno secondo dove punta la pedina.

| `docs/MISURA_CASELLE.md` | prima | dopo |
|---|---|---|
| Effetti che una casella sa dire | 5 su 46 | **44 su 46** |
| applicazioni coperte | 151 su 336 | **333 su 336** |
| verbi che mancano | 16 | **0** |
| posti che la casella non sa dire | 25 | **2** |

Le due che restano sono dichiarate e non sono caselle da scrivere: `$conditioner`
è un bersaglio che al Consiglio non esiste, e un `SET_GLOBAL_TAG` puntato su una
Regione è un difetto dei dati (ISSUES 117).

**E sono su carte vere**: diciotto voci nuove su cinque carte, ognuna trascritta
da quello che il Consiglio di quella domanda già faceva. In cento saghe: POSA UN
SEGNO SU UNA CASATA 45 offerte e 12 acquisti, MUOVI UN RAPPORTO 8 e 2, UNA
PRESENZA SE NE VA 7 e 2. **Quattro non si sono viste mai** — le due della Pietra,
la strada chiusa, la casa che lascia il tavolo: mordono solo dove la loro
condizione tiene, e le condizioni sono strette apposta. Il numero si scrive
perché è peggiore di quello che si sperava (ISSUES 117).

**Tre cancelli nuovi**: lo schema e il motore devono nominare le stesse caselle
(il lato motore letto da `MISURA_CASELLE.md`, che una sonda genera chiamandole);
un posto senza il suo parametro; un segno addosso a una casa che non è di ambito
ENTITY. Difetti piantati 34 → **40**. E una guardia vecchia che adesso chiede la
cosa giusta: due pedine fanno «la stessa cosa» se hanno lo stesso verbo **e lo
stesso bersaglio**.

| su 100 anni, tavolo uniforme | prima | dopo |
|---|---|---|
| esiti SUCC netti | 158 | 156 |
| esiti DECI | 141 | 143 |
| Verità scritte | 163 | **165** |
| seggi bloccati su un solo livello | **0 su 8** | **0 su 8** |

Il tavolo misto non si muove di una riga.

---

## 0.1.331 — La terra decide cosa ci si costruisce (D-365) — chiude ISSUES 116

La struttura fisica mette **sulla tessera** gli spazi dove si costruisce. La
tessera diceva dove vanno le pedine e non dove vanno le Pietre.

E la causa vera non l'aveva decisa nessuno: **lo schema delle Pietre ammetteva
sei biomi su dieci.** COAST, MARSH, ISLAND e FOREST non si potevano nemmeno
scrivere, e quattro tessere risultavano «dove non si costruisce niente».

| | |
|---|---|
| `build_slots` sulla tessera | legati al bioma: 3 / 2 / 1 |
| i biomi | tutti e dieci, e **un elenco solo** |
| il motore | non alza sul bioma sbagliato ne' dove non c'e' posto |
| la faccia | «foresta · 3 pedine · 2 Pietre · CI STANNO presidio, insediamento…» |

Larghi dove ha senso: cinque «no» su sessanta caselle, e ognuno dice qualcosa —
il grano marcisce nell'umido, chi si sposta non archivia, l'acqua non si porta
in salita.

| su 100 anni | prima | dopo |
|---|---|---|
| Pietre alzate | 519 | 520 |
| tessere che sforano i posti | **4** | **0** |
| Pietre in piedi dove non potrebbero | — | **0** |

L'ultima riga non passa dal registro: guarda il tavolo. Il registro dice ancora
sei tentativi rifiutati — sono tentativi, e il motore li ha respinti.

**Due cancelli nuovi**: il «cantiere murato» (una tessera con spazi dove nessuna
Pietra puo' stare), difetti piantati 33 → **34**; e la guardia che tiene uguali
i due elenchi di biomi, che morde nel verso in cui il difetto era invisibile.

---

## 0.1.330 — Il censimento conta le facce che si leggono (D-364)

«84 facce fisiche mancanti» non era vero: il censimento contava i blocchi
scritti a mano e chiamava mancante tutto il resto. Tre mazzi su sei hanno una
faccia **ricavata dai dati** (D-344), e non e' un abbozzo — e' una garanzia, che
scrivendola a mano si perderebbe.

Adesso le facce si contano dalle facce: `SCHELETRO_CARTE.md` le ricava dalle
facce vere, e il censimento legge quel documento. **275 facce stampate, nessun
pezzo senza.**

E il buco vero, trovato cercando quello finto: la tessera non dichiara gli
spazi dove si costruisce — ISSUES 116.

---

## 0.1.329 — Su una faccia non si stampa un nome interno (D-363)

Cercando le 48 facce che mancavano agli Echi ho scoperto che **non mancavano**:
si generano dai dati per una decisione presa apposta (D-344), perche' la carta
non possa dire una cosa e il motore farne un'altra. Erano pero' incompiute.

| | prima | dopo |
|---|---|---|
| facce che stampavano `region with:granary` | **19** su 48 | **0** |
| segni detti col proprio identificativo | **13** | **0** |

> scrive «L'Ordine Rimesso in Piedi» · Nel mondo: **l'amnistia e' stata concessa**
>
> Il Debito sale di 1, o la domanda che il tavolo ha aperto · **un luogo con
> commercio**: e' pieno di debiti

Nessuno se n'era accorto **perche'** la faccia si genera: la si guarda una volta
e poi ci si fida. `test_no_face_prints_an_internal_name` rende quella fiducia
meritata — 665 prove, 84717 asserzioni.

---

## 0.1.328 — Le 48 Risonanze dicono di quanto scaldano (D-362)

Chiude ISSUES 113, aperta in 0.1.323 guardando il grafo del flusso, e ISSUES 107.

Ogni Risonanza porta un'aggravante: se il bersaglio ha un certo segno scalda di
piu', e a volte gli posa addosso un gettone. **Quarantotto carte su quarantotto
non lo dicevano.** Adesso lo dicono tutte, in una riga costruita dai campi che
il motore legge — quindi non puo' dire una cosa e farne un'altra.

| | prima | dopo |
|---|---|---|
| Risonanze con un'aggravante | 48 | 48 |
| **che non la dicono** | **48** | **0** |
| difetti piantati nella guardia | 32 | **33** |

**Controllo 22**: se una Risonanza dichiara `if_target_tag` o `extra_tag`, il
nome stampato di quel segno deve comparire nel testo. Non la bellezza della
frase — quella e' d'autore — ma che il segno sia nominato.

### Tre errori che il cancello mi ha fatto correggere

- **La portata cambia la frase.** `_carries` guarda anche la scheda di chi cala
  la carta: un segno di casata funziona, ma la faccia deve dire di chi e' —
  «se **porti** #fama», non «se il luogo…».
- **Il nome stampato, non una parafrasi.** Avevo scritto «un debito e' stato
  chiamato» dove il dizionario stampa «debito chiamato». Chi cerca il segno sul
  tavolo non lo trova, se la carta lo chiama in un terzo modo.
- **Una Cicatrice si dice Cicatrice**: su *L'Esodo* il gettone in piu' e'
  `scar:emptied`, e un dischetto rotondo non e' un gettone qualunque.

### E l'Eco non sceglie un bersaglio

Scelta del committente: un'Azione e' una **mossa**, un Eco e' un **fatto che
decidi di far accadere**. La scelta vera e' un'altra, e sta sulla stessa carta:
la spendo per una delle sue due Azioni, o per il suo Eco?

---

## 0.1.328 — La Risonanza dice di quanto scalda (D-362)

Chiude ISSUES 113, che era il difetto piu' diffuso mai misurato qui: **48 carte
su 48** scaldavano di piu' di quanto la faccia dicesse.

Adesso ogni Risonanza porta la sua aggravante scritta, col nome stampato del
segno e il calore **totale** — non l'incremento, che al tavolo nessuno somma.

> Scalda Potere +2. Le porte bruciate si raccontano per due generazioni, e
> nessuna versione e' la tua. **Se una domanda e' rimasta aperta: Potere +3.**

La forma segue l'ambito del segno: `se il luogo e'…` per una Regione, `se
porti…` per un segno di casata, la memoria detta com'e' scritta per il mondo. E
dove il segno extra e' una Cicatrice, la frase lo dice: un dischetto non e' un
gettone.

**Il cancello** (controllo 22 di `validate_physical.py`) chiede che il nome
stampato del segno compaia nel testo. Non giudica la frase — quella e' d'autore
— ma il segno dev'esserci. Difetti piantati nel `--self-test`: 32 → **33**.

Il cancello ha anche bocciato la mia prima stesura, che scriveva «un debito e'
stato chiamato» dove il dizionario stampa «debito chiamato». Aveva ragione: chi
cerca quel segno sul tavolo non lo trova, se la carta lo chiama in un terzo modo.

---

## 0.1.327 — Le chiavi del payload le decide il tipo dell'Effetto (D-361)

Chiude ISSUES 115, aperta ieri quando una carta che ho scritto io diceva il
contrario di quello che faceva.

`effect.schema.json` dichiara per 27 tipi su 29 quali chiavi il payload puo'
portare, con `additionalProperties: false`. La lista viene da **quello che
`EffectApplier` legge**, non dai dati: ricavarla dai dati avrebbe reso legge il
primo refuso. `CREATE_ECHO` e `APPEND_TRUTH` restano liberi perche' scrivono il
payload intero in un registro, e li' ogni chiave e' contenuto.

Otto casi piantati nel `--self-test`, fra cui il difetto vero.

### Trenta parole che non facevano niente

Acceso, il cancello ha trovato **30 `optional` decorativi** su tipi dove il
motore non li guarda: togliere una cosa che non c'e' e' gia' un no-op
incondizionato. Tolte. Non cambia niente a runtime, ed e' proprio per questo:
una parola sulla carta che non fa nulla e' una bugia, e finche' resta scritta
qualcuno la legge come una leva.

---

## 0.1.326 — L'Eco costa la carta, e nient'altro (D-360)

Due leve che la 0.1.325 aveva lasciato in piedi come tarature dichiarate, decise
dal committente: *«l'eco non deve costare due carte, e' una opzione come le
azioni, solo che ha condizioni piu' stringenti»*.

**Il prezzo.** La parola pagata di D-118 nasceva quando l'Eco stava in un mazzo
separato e la carta Asset era il pedaggio per far parlare una carta non tua.
Adesso l'Eco **e' la carta**: calarlo costa la carta, come giocarla per una
delle sue due Azioni. A distinguerlo sono le condizioni — l'Atto e i segni del
mondo — non il conto.

**Il tetto di una calata per Atto per seggio.** Stava nel decisore e non su
nessun pezzo: un limite che non e' stampato da nessuna parte non e' una regola
del gioco, e' un'abitudine dell'app. Chi ne cala due ha speso due carte, e
quello e' gia' il freno.

| su 100 anni | mazzo | fuso | +Atto cumulativo | +D-360 |
|---|---|---|---|---|
| Echi calati per partita | 0,40 | 0,64 | 0,70 | **0,81** |
| partite con almeno una | 37 | 46 | 49 | **49** |
| Echi mai usciti | 27/39 | 33/48 | 31/48 | **29/48** |
| fermi per l'Atto | — | 382 | 0 | **0** |
| fermi per il prezzo | 228 | 58 | 58 | **0** |

Il doppio del mazzo, e i freni strutturali a zero. Quello che resta e' una
preferenza, non un blocco: meta' degli Echi fermi era **legale**, e il decisore
sceglie l'Azione normale. Ma il decisore pesa un Eco sui propri obiettivi e non
su quello che lascia scritto nel mondo, e su quello non e' un buon giudice: il
numero vero lo dira' un tavolo con delle persone.

---

## 0.1.325 — Via il mazzo del Narratore: l'Eco e' la versione potenziata della carta (D-359)

Ordine del committente, dopo la misura della 0.1.324: *«fai la 1 e la 3, via
mazzo separato, le carte di Propp si "fondono" con le carte asset, diciamo che
sono una versione "potenziata"»*.

### Cosa cambia sul tavolo

Non c'e' piu' un mazzo del Narratore, ne' una mano separata, ne' un sacchetto
che pesca a inizio Atto. **Ogni carta Asset porta il suo Eco stampato sotto le
due Azioni**: la sua versione potenziata. Si cala al posto di un'Azione normale,
costa **la carta**, come giocarla per una delle sue Azioni, e si accende solo se
il mondo porta i segni che quell'Eco nomina.

| | prima | dopo |
|---|---|---|
| mazzi da stampare | 7 | **6** |
| fogli A4 di carte e tessere | 54 | **49** |
| Echi scritti | 39 | **48**, uno per carta |
| clausole `tension_limit` sugli Echi | 25 | **0** |
| pezzi senza una faccia fisica | 75 | **36** |

### Perche' erano fermi

25 Echi su 39 chiedevano una **Tensione nominata**, e dopo D-318 l'anno pesca
quattro questioni su sessanta. L'eleggibilita' la nominava perche' **l'effetto**
la nomina: un `ADJUST_TENSION` su una questione fuori dal tavolo fallisce.

Il nodo si scioglie con `$tension`, che c'era gia': risolve alla questione
d'autore se e' aperta, e altrimenti a una che c'e'. La carta parla sempre.

### Quello che non si e' toccato, e per poco non lo toccavo

Al primo passaggio avevo cancellato anche le dieci clausole
`echo_function_played` — la grammatica di Propp che D-358 aveva appena messo
sul tavolo scoperto. Quella non e' una lotteria: dipende da cosa il tavolo ha
calato, non dal sorteggio dell'anno. Se n'e' accorta una prova che c'era gia',
e il passaggio e' stato rifatto **chirurgico**: si toglie solo `tension_limit`.
Dieci clausole di Propp prima, dieci dopo.

### E il costo, che si scrive

Cento anni pescati, semi da 7000, tavolo misto — **misurati oggi da tutte e due
le parti**, non confrontati con un numero di un mese fa:

| su 100 anni, tavolo misto | prima (main) | dopo (D-359) |
|---|---|---|
| NONE | 174 | **196** |
| MINIMUM | 304 | 286 |
| VICTORY | 316 | 312 |
| TRIUMPH | 6 | 6 |
| Consigli per anno | 3,44 | **3,52** |
| Verita' scritte | 157 | **150** |

**Ventidue seggi in piu' escono a mani vuote**, e il mondo scrive sette Verita'
in meno. Il gioco e' un po' piu' duro.

Ha una ragione: l'Eco costa **due** carte, e settanta Echi calati su cento anni
sono settanta carte che non hanno fatto un'Azione. In cambio si tiene mezzo
Consiglio in piu' per anno, perche' un Eco scalda una questione.

Il vincolo che non si negozia regge: **0 seggi bloccati su un solo livello su
8**, tavolo misto e uniforme.

### La misura del mazzo, prima e dopo

| su 100 anni | mazzo (0.1.324) | fuso (D-359) |
|---|---|---|
| Echi calati per partita | 0,40 | **0,70** |
| partite con almeno una calata | 37 | **49** |
| fermi per l'Atto | — | **0** |
| fermi perche' il mondo non porta i segni | 758 | 482 |
| fermi ma legali, e nessuno li ha voluti | 495 | **481** |

**+75% di calate, e non basta.** Il numero e' salito e resta basso, e va scritto
com'e'. Ma e' un numero diverso da prima: non e' piu' un mazzo che non arriva in
mano — l'Eco e' sempre in mano, sotto le due Azioni, e meta' di quelli fermi
erano **legali**. Il tavolo lo soppesa e sceglie l'Azione normale, perche' due
carte per 2,7 Effetti contro due Azioni per 2,1 e' un margine sottile.

Le due leve per alzarlo ancora sono tarature del committente, non difetti: il
**prezzo** (due carte, o una) e il **tetto di una calata per Atto per seggio**,
che sta nel decisore e non e' una regola stampata.

### Un segno muto in meno

`burden_shared` (48 scritture, nessun lettore) adesso accende due Echi: i muti
dichiarati scendono da 12 a **11**.

Ne avevo annunciati due. Il secondo, `someone_paid`, non c'e': la sua carta
aveva gia' una clausola di Propp, e la regola chirurgica non le aggiunge un
segno. L'ha contato il cancello del registro, non io.

---

## 0.1.324 — Il mazzo del Narratore arriva sul tavolo 0,4 volte per partita (ISSUES 114)

Una sonda nuova, nessuna regola toccata: prima di scrivere le 39 facce che
mancano alle carte Eco, il committente ha chiesto se quel mazzo si gioca.

### `cli/run_echo_weight_probe.gd`

Tre domande, nell'ordine in cui le ha poste — la seconda e la terza non hanno
senso se la prima risponde «quasi mai». Cento anni pescati, tavolo misto, semi
da 7000: lo stesso tavolo del cancello, così i numeri stanno accanto a quelli
del playtest.

La sonda stampa **per prima la prova di non essere cieca**: le calate contate
dal registro degli Effetti contro la pila `echo_played` letta dal mondo. Due
strade diverse, e se non combaciano si ferma. In questo progetto uno zero è
quasi sempre la sonda.

### Cosa dice

| | |
|---|---|
| carte distribuite in mano | 15,21 per partita |
| **carte calate sul tavolo** | **0,40 per partita — il 2,6%** |
| partite in cui nessuno ne cala nessuna | **63 su 100** |
| carte scritte / mai uscite in 100 partite | 39 / **27** |
| di 40 calate, quante sono `ECH_SACRIFICE` | **24** |

Quando escono pesano — 3,10 Effetti contro 1,05 di una carta Asset — ma su cento
partite scrivono 124 Effetti contro i 5093 del Consiglio: **il 2,4%** di quello
che cambia il mondo.

### La causa

**25 carte su 39 chiedono che una Tensione nominata sia in gioco quest'anno.**
Il mazzo fu scritto contro i due anni d'autore dalle Tensioni fisse; D-318 li ha
cancellati e ha misurato il guadagno — 48 carte Tensione su 60 tornate al tavolo
— senza misurare cosa costava allo strato di Propp. Questo è quel costo, trovato
due mesi dopo e adesso scritto.

Tre strade in ISSUES 114, e la domanda che viene prima: un mazzo che arriva sul
tavolo 0,4 volte per partita esiste nella scatola? È una decisione del
committente, non del misuratore.

---

## 0.1.323 — Le 48 Risonanze fanno tutte una cosa che non dicono (ISSUES 113)

Nessun codice cambia: cambia un numero, e il numero è tutto.

Il committente ha guardato il grafo del flusso su `question_unresolved` — «*a
volte si trovano cose strane semplicemente guardando*». Il segno era in ordine.
Le carte che lo leggono no.

```
carte con Risonanza fisica     : 48
  con aggravante nel motore    : 48
  che la faccia NON dice       : 48
```

Ogni Risonanza ha un `if_target_tag` con `extra_heat` — scalda di più se il
bersaglio porta un certo segno, e a volte gli posa addosso un gettone in più.
**Nessuna delle quarantotto lo scrive.** *Le Porte Bruciate* dice «Scalda Potere
+2» e ne dà 3 quando sul bordo della mappa c'è `#question_unresolved`.

È lo stesso difetto del Magistrato che ha aperto ISSUES 113, ma non è un caso
isolato: è il **100%** del pezzo di carta che CLAUDE.md chiama obbligatorio. La
misura è nel corpo di ISSUES 113, insieme a cosa comporta per la cura.

---

## 0.1.322 — Via la grammatica di Propp dal mondo, e una Cicatrice si può togliere (D-357, D-358)

Due ordini del committente: *«ELIMINA ogni cosa che vive solo nell'app»* e
*«togliere una cicatrice è raro ma può accadere»*.

### La grammatica di Propp non si nasconde più (D-358)

Giocare una carta Eco scriveva sul mondo un segno `function:ATTACK`,
`function:BETRAYAL`, uno dei ventiquattro. Quel segno **decideva chi poteva
uscire l'anno dopo**, e `effect_text.gd` lo **nascondeva apposta** con una
costante che si chiamava `HIDDEN_TAG_PREFIX`. Una regola che cambia il gioco e
che al tavolo non si può vedere.

La regola resta — *«ci si riconcilia dopo qualunque rottura»* è Propp, non si
tocca. Cambia dove si legge: **le carte Eco calate stanno scoperte sul tavolo**,
e ognuna porta la sua funzione stampata.

| | prima | dopo |
|---|---|---|
| voci del dizionario | 204 | **180** |
| clausole `state_tag_present: function:X` | 27 | **0** |
| seggi bloccati (misto / uniforme) | 0/8 · 0/8 | **0/8 · 0/8** |
| test | 664 | **664, verdi** |

**Un errore preso in tempo:** la prima stesura leggeva `echo_deck.drawn`, che
comprende le carte ancora **in mano**. Avrebbe risposto «c'è stato un tradimento»
perché qualcuno ha la carta in mano, allargando la grammatica in silenzio.
Serviva `echo_played`, le carte **calate**.

E `test_visible_handover` — *«l'era nuova nasce dal solo tavolo visibile: niente
stato nascosto nell'eredità»* — ha morso subito, per la ragione giusta.

### Una Cicatrice si può togliere, di rado (D-357)

D-350 aveva scritto che il dischetto **non torna nella riserva**, e la sonda ne
aveva fatto una bandierina contro `scar:unanswered`. **Sbagliate tutt'e due:**
quella rimozione è progettata da D-112, ed è la cura rara del Magistrato.

La differenza fra un gettone di zona e una Cicatrice non è «per sempre contro
temporaneo»: è **quanto costa levarla**. Corretta in tre posti.

### Cosa resta app-only (ISSUES 113)

Il Magistrato toglie `scar:unanswered` con un effetto digitale, e la sua faccia
fisica quella Cicatrice non la nomina. `on_commit_effects` e `physical.actions`
sono due liste separate, e **nessun cancello controlla che dicano la stessa
cosa**. Va misurato prima di tagliare.

---

## 0.1.321 — Il grafo non mostrava nessuna Cicatrice (D-354)

Trovato dal committente, guardando il disegno di una Conseguenza e chiedendo di
spiegargliela: «La Domanda sul Muro» mostrava **due frecce in uscita su tre**.
Mancava la Cicatrice.

**Quindici Conseguenze posano una Cicatrice con un blocco loro** (`creates_scar`
più `scar`) invece che con un Effetto, e `build_flow.py` cercava solo i tipi di
effetto: di quelle quindici non ne mostrava **nessuna**. Da **1582 a 1597
legami**.

È lo stesso inciampo che un commento in `validate_physical` aveva già scritto —
*«la cicatrice non è un SET_REGION_TAG: è un blocco suo»* — e ci sono cascato lo
stesso, sullo stesso pezzo, per la seconda volta in un giorno: la prima era
`ADD_SCAR` nella sonda del tavolo. **Le Cicatrici sono il posto dove questo
progetto è cieco**: tre strumenti su tre, scritti in giornate diverse, hanno
mancato lo stesso blocco.

---

## 0.1.320 — I cinquantuno gettoni del bordo hanno una faccia (D-356)

Chiude [ISSUES 110](docs/ISSUES.md). D-351 aveva dato un posto alla memoria del
mondo e lasciato scritto cosa mancava: **51 schede del disegno su 52**, l'unica
parte del catalogo delle pedine che si scrive a mano.

**Cinquanta schede nuove**, più `heir_named` spostato dal foglio delle case a
quello del mondo, dove doveva stare.

**La forma postuma non è un gettone in più.** I tre `legend:` non hanno una
parola stampata, e sembrava un buco: non lo è. Sono «la forma postuma di un
fatto», e tutt'e tre hanno il loro fatto base già nella lista. Sul tavolo è **lo
stesso gettone, girato** — il fatto da una parte, il racconto dall'altra.

**Il costo, ed è grosso.** `components_survey` non li contava, perché leggeva
solo i segni delle Regioni e delle case:

| | prima | dopo |
|---|---|---|
| tipi di segnalino | 67 | **118** |
| pezzi da tagliare | 91 | **142** |
| fogli-fustella | 3 | **4** |

E `MISURA_TAVOLO` dice la cosa che pesa: di quei 51, **19 non si posano mai** in
cento partite. Diciannove fustelle per gettoni che nessuno tocca. Non le tolgo:
prima conviene chiedersi se il difetto è il gettone o il fatto che nessuno lo
scrive.

Nuova [ISSUES 112](docs/ISSUES.md): `seal_kept` e `seal_kept_twice` hanno la
parola e ora la scheda, ma **non sono voci del dizionario** — li nomina la catena
delle ere, e quel percorso il censimento non lo raschia.

664 test verdi.

---

## 0.1.319 — Una clausola non è un lettore (D-355)

L'ultima delle tre riparazioni di [ISSUES 102](docs/ISSUES.md), che **si chiude**.

`MISURA_SEGNI` chiudeva con la lista dei segni «che nessuna clausola nomina». Il
difetto era nella parola *clausola*: quelle colonne leggono solo i passi di
Destini e Obiettivi, e una regola del segno, la faccia di una carta, un Consiglio
o una Tensione non comparivano da nessuna parte.

**Il documento sbagliava su sedici righe su venti.** Diceva muti venti segni;
muti davvero ne sono **quattro** — e sono esattamente i quattro che
`REGISTRO_SEGNI` dichiara con la loro ragione. Fra i sedici sbagliati c'era
`condition:guarded`, che da D-353 **vieta di tramare**: il documento lo chiamava
muto due ore dopo che gli avevamo messo un dente.

Colonna nuova, **«chi altro lo legge»**, presa dal `read_by` del dizionario — che
il controllo 4 di `validate_physical` tiene onesto nei due versi. Appoggiarsi a
una lista già sorvegliata invece di scrivere un terzo censimento: i tre scritti
da capo questa settimana hanno prodotto tre punti ciechi.

Due prove nuove sulla funzione pura `letture()`: un segno con un lettore e zero
clausole **esce** dai muti, e un segno voluto e mai scritto **resta** murato
anche se qualcuno lo legge. Provate togliendo la riparazione: rosse.

664 test verdi.

---

## 0.1.318 — Il flusso del tavolo si disegna, e si rigenera da solo (D-354)

Voluto dal committente: *«quando evidenzio una carta, un tag, una locazione o
qualunque altra cosa, mi deve far vedere l'albero delle connessioni […] più
grafico con frecce e meno tabelle»*, e *«il grafo deve sempre rigenerarsi»*.

`tools/build_flow.py` → **`docs/flusso.html`**. Si sceglie un pezzo e si vede
**a sinistra chi ce lo mette, a destra chi lo legge e cosa ne segue**, disegnato
con le frecce. Uno, due o tre passi; ogni pezzo si mette al centro con un tocco;
si filtra per tipo di legame e per tipo di pezzo.

**543 pezzi, 1582 legami.** Tre tipi di nodo nuovi: i **luoghi** (le dieci
tessere coi segni stampati e le adiacenze), le **azioni**, le **Pietre** coi loro
gradi.

**Il verso della lettura è rovesciato apposta.** Il dato dice «questa carta legge
#granaio»; il tavolo chiede «#granaio chi lo legge, e quelli cosa fanno». Girato
l'arco, la catena scorre in un verso solo: *una carta **posa** un segno · il
segno è **letto da** una regola · la regola **vieta** un'azione.*

**Nuovo cancello** `python3 tools/build_flow.py --check`, in CI: va rosso se il
disegno non è più quello che i dati dicono. Provato piantando una regola finta.

Il disegno sta in `tools/flow_template.html` e i dati in `godot/data`: si
incontrano solo nel generatore, come il MASTER PROMPT di D-349.

---

## 0.1.317 — Sotto gli occhi della guardia non si trama (D-353)

Primo passo della potatura chiesta dal committente. `condition:guarded` — posato
**36 volte in 100 anni** dal prezzo di una proposta che passa, e letto da nessuna
regola — adesso morde: `TGR_GUARDED_NO_SCHEME` vieta **TRAMARE** a chi ha
presenza in una Regione sorvegliata. Stessa forma del divieto di D-117: dove
qualcuno guarda, non si ordisce.

**I muti del registro passano da 13 a 12.**

| | prima | dopo |
|---|---|---|
| seggi bloccati (misto / uniforme) | 0/8 · 0/8 | **0/8 · 0/8** |
| Consigli media, misto | 3.43 | 3.43 |
| Consigli media, uniforme | 3.48 | **3.46** |
| segni che non arrivano mai | 67 su 180 | **66 su 180** |
| vite che non si siedono mai | 7 | **6** |
| trasformazioni sedute | 208 | 197 |

Il costo è **due centesimi di Consiglio** e **undici trasformazioni in meno**, ed
è scritto: un divieto in più è una strada in meno.

E una cosa migliora, che non era lo scopo: **«Il Banco Nero» si siede**. In cento
partite non si era mai aperto; adesso una volta sì. Un divieto sposta le strade,
e qualcuna porta dove prima non passava nessuno.

E una cosa storta che resta: `MISURA_SEGNI` scrive ancora «nessuno lo guarda»
accanto a `condition:guarded`, e adesso è falso — è la terza riparazione di
ISSUES 102, ancora aperta.

---

## 0.1.316 — La sonda del tavolo, e la memoria del mondo trova il suo posto (D-351, D-352)

**La misura che mancava.** `MISURA_SEGNI` guarda 66 segni su 204. ISSUES 102
l'aveva scritto con un numero che non lascia scampo: *214 Pietre alzate, e nel
conto dei segni ne risultavano sette.*

`cli/run_table_marks_probe.gd` guarda **tutti e 180** i segni che hanno un posto
sul tavolo, e li conta **posto per posto**. Nuovo documento
[MISURA_TAVOLO.md](docs/MISURA_TAVOLO.md), nuovo cancello
`tools/run_table_survey.sh --check`, in CI.

**La prova d'accettazione di ISSUES 102 e' superata:** 1062 Pietre alzate in 100
partite, 1195 segni di Pietra contati — le 1062 piu' 133 cambi di grado. Prima
erano **sette**.

### Cosa dice la prima misura

**113 segni su 180 arrivano sul tavolo. 67 non ci arrivano mai.**

| posto | arrivano | non arrivano |
|---|---|---|
| stampato sulla tessera | 15 | **0** |
| un gettone accanto alla tessera | 13 | 1 |
| un dischetto rotondo | 10 | 3 |
| uno spazio sulla tessera | 17 | 10 |
| un gettone sul bordo della mappa | 32 | 20 |
| sulla scheda della casa | 26 | 33 |

### Due cecità pagate scrivendola

- **Le Pietre non passano dal registro degli Effetti** (`_apply_grade_tag` scrive
  dritto su `region["tags"]`): la sonda guarda `BUILD_STRUCTURE` e i cambi di
  grado, e ricava il segno dal grado come fa il motore.
- **Le Cicatrici hanno un blocco loro.** La prima stesura diceva *«12 Cicatrici
  su 13 non arrivano mai»*, ed era falso: non guardava `ADD_SCAR`. Ne arrivano
  **10 su 13**. È il secondo strumento di questo progetto a cadere sullo stesso
  inciampo, e il commento che lo avvisava era già scritto.

Perché non ce ne sia una terza, la sonda porta una colonna che **non passa dal
registro**: *a fine partita*. Se un segno è sul tavolo quando si finisce, ci è
arrivato — comunque ci sia arrivato.

### La memoria del mondo si posa sul bordo della mappa (D-351)

Scelta del committente per [ISSUES 110](docs/ISSUES.md): i 52 segni che il mondo
ricorda sono **gettoni sul bordo della mappa**. Un fatto del mondo è del mondo,
non di un luogo né di una casa.

Il costo, misurato prima: 49 su 52 hanno già la parola stampata; **51 su 52 non
hanno la scheda del disegno**, ed è la parte che si scrive a mano. Resta da fare,
ed è scritto in ISSUES 110. E di quei 52 gettoni, **20 non si posano mai** in
cento partite: conviene saperlo prima di tagliare la fustella.

### E la potatura non è quello che sembrava (ISSUES 111)

Le 10 Pietre che non si alzano mai sono **due difetti diversi**, non uno:

- **sei hanno già chi le scrive**, e la Conseguenza non viene mai scelta —
  `CNS_MINE_SEALED` scrive sia `mine_sealed` sia `place:open_site`, ed è lo
  stesso difetto di ISSUES 108 contato in un altro posto;
- **tre non hanno nessuno**: `structure:palace`, `settlement:city` (nessun
  effetto tocca `STR_SETTLEMENT`, a nessun grado) e `structure:road` (ISSUES 101).

Nessuna regola cambiata in questa versione: 662 test verdi, **0 seggi bloccati
su 8**.

---

## 0.1.315 — Ogni segno dice in che punto del tavolo lo prendi in mano (D-350)

Voluto dal committente: *«ogni tessera ha tag che la descrivono e non può
cambiare; sulla tessera degli spazi dove costruire; fuori dalla tessera token
che indicano lo stato, a parte i token rotondi che rappresentano le cicatrici;
sulle schede delle entità altre zone».*

**`table_place` su tutte e 204 le voci del dizionario.** `scope` diceva a chi
appartiene un segno, `category` che cosa è: mancava **dove lo prendi in mano**,
e senza quello non si sa cosa stampare. `condition:emptied` e `scar:emptied`
vivono tutt'e due su una Regione, ma uno è un gettone che torna nella riserva e
l'altro un dischetto che resta.

| posto | segni | di cui scritti sul mondo | muti |
|---|---|---|---|
| stampato sulla tessera | 15 | 0 | — |
| uno spazio sulla tessera (Pietre e loro gradi) | 27 | 5 | 1 |
| gettone accanto alla tessera | 14 | 14 | 1 |
| dischetto rotondo (Cicatrici) | 13 | 12 | — |
| sulla scheda della casa | 59 | 23 | 4 |
| memoria del mondo — **posto da decidere** | 52 | 48 | 7 |
| il tavolo non lo mostra | 24 | 0 | — |

**180 segni stanno sul tavolo, 24 sono contabilità.**

Due cose trovate assegnando i posti, e nessuna era scritta:

- **I gradi di una Pietra sono lo stesso spazio.** `place:forest` →
  `place:thinned_wood` → `place:cursed_wood` sono i tre gradi di `STR_FOREST`:
  un bosco che si assottiglia è la stessa Pietra a un grado diverso, non un
  gettone che si aggiunge.
- **La memoria del mondo non ha un posto** — 52 segni, un quarto del dizionario,
  che non stanno né sulla tessera né sulla scheda. Nuova [ISSUES 110](docs/ISSUES.md).

**La guardia** (controllo 21 di `validate_physical.py`) morde su quattro difetti
piantati: un segno senza posto, una Cicatrice messa fra i gettoni che si
tolgono, un grado di Pietra spacciato per gettone, un segno della scheda messo
sulla tessera. La guardia sale da 28 a **32 difetti piantati**.

Il registro dei segni guadagna la sezione **«Il tavolo: dove sta ogni segno»**,
e la tabella dei muti dice in che posto sta ognuno.

**Nessuna regola cambiata, nessun segno tolto o aggiunto:** è un'etichetta su
quello che c'era. 662 test verdi, **0 seggi bloccati su 8** su tutti e due i
tavoli, Consigli 3.48 di media (uniforme) — identico a prima.

---

## 0.1.314 — Il MASTER PROMPT esce da ART_BIBLE anche per Python (D-349)

`tools/token_catalogue.py` legge il MASTER PROMPT 6 e le sue varianti di
contorno da `docs/ART_BIBLE.md`, invece di tenerne una seconda copia scritta a
mano. Cambiare il documento adesso cambia il catalogo. Chiude
[ISSUES 109](docs/ISSUES.md).

*Il codice era entrato senza i suoi verbali, contro la terza regola di casa:
questa riga e D-349 arrivano in ritardo, col commit di D-350.*

---

## 0.1.313 — Vaerax ha una seconda via per sigillare la miniera (D-348, ritirata in 0.1.315)

Aggiunta proposta `P_SEAL_MINE_FOR_FIELDS` al Consiglio del Grano. Il segno
`mine_sealed` arriva ora da due caselle diverse — il Risveglio (raro) e la
Carestia (comune). Su 100 anni, il segno esce **3 volte** anziché 0.

Apre la strada a ISSUES 108: bilanciamento di Vaerax e Lyra.

---

## 0.1.312 — Il prompt di una carta dice la scena, non il nome (D-347)

Il committente: *«rigenera anche i vari cataloghi delle carte, e anche il prompt
che descrive ogni carta: non quello generico — valido per tutta la grafica del
gioco, determina lo stile — ma la descrizione della situazione della carta»*, e
col messaggio lo stile, *painterly concept-art*, che vale per tutto.

### 87 carte mandavano a chi disegna il proprio titolo

Il brief prendeva il soggetto dalla **prima riga del corpo stampato**. D-340 ha
tolto il racconto dalla faccia scrivendo, nel commento che lo faceva, che *«il
racconto resta nel dato: lo legge il brief d'arte»* — e il brief leggeva la
faccia, che era rimasta senza. Da allora **48 Asset e 39 Eco** su 146 chiavi
uscivano col nome della carta dentro un paragrafo di stile.

Il cancello del brief e' rimasto verde: confronta il documento con quello che il
codice produce, e il codice produceva lo stesso niente dalle due parti. **Un
cancello che confronta due copie della stessa cosa non si accorge mai che la
cosa e' vuota.** Nona volta.

### Quattro cose, quattro posti

| | dove sta |
|---|---|
| **lo stile** — come si dipinge | `ART_BIBLE.md`, `LO STILE`, una volta sola |
| **la tavolozza** — con quali colori | «Direzione visiva» e le tabelle di variazione |
| **l'inquadratura** — cosa c'e' nel riquadro | i sei MASTER PROMPT |
| **la situazione** — cosa succede in questa carta | nel dato, una riga per carta |

Il brief stampa lo stile **in cima, una volta** invece di 146, e ogni carta porta
la sua scena.

### E `rules_text` faceva ancora due mestieri

**35 Asset su 48** aprivano la riga d'autore con una regola — `+1 sul fronte
Oppose`, `Si scarta sempre`, `Forza 3` — che da D-340 sta gia' sulla faccia,
riga per riga. Tolte da tutte e 48 **tenendo le parole dell'autore**: la riga
`IMPEGNI` le porta tutte, quindi non si e' perso niente.

### E per strada: 33 facce col cancelletto su una frase

`SEMPRE Fede +2 · se il bersaglio ha #il giuramento e' stato rotto`. D-344 aveva
messo la regola in `_sign` — cancelletto solo su una parola sola — e `_hash` lo
rimetteva a forza. Una regola che vale in un posto e non nell'altro non e' una
regola.

### Cambiato

- `docs/ART_BIBLE.md`: la sezione `LO STILE`, e i sei MASTER PROMPT che adesso
  dicono **inquadratura** e chiedono `{SITUAZIONE}`.
- `scripts/core/art_bible.gd`: legge lo stile, e la scena la prende **dal dato**
  della carta e non dalla faccia stampata.
- `data/assets/assets_core.json`: 48 scene, senza le regole che stanno sulla
  faccia.
- `scripts/core/asset_text.gd`: `_hash` si fida di `_sign`.
- Cinque guardie nuove in `test_print_export.gd`, quattro provate rimettendo
  **il difetto vero** com'era.
- Rigenerati: `BRIEF_ARTE`, `CATALOGO_CARTE`, `REVISIONE_TESTI`.

### Il conto

| su 100 semi | prima | dopo |
|---|---|---|
| seggi bloccati su un solo livello | **0 su 8** | **0 su 8** |

Suite da 657 a **662 prove**. Fuori resta il MASTER PROMPT 6 dei segnalini —
pittogrammi monocromi, lo stile pittorico non li riguarda — il cui testo e'
pero' **ricopiato** in `tools/token_catalogue.py`: **ISSUES 109**.

---

## 0.1.311 — Punti regalati e porte murate: due difetti opposti, due liste (D-346)

Il committente: *«Mergia, rigenera il grafo dei #tag e vai avanti.»*

Rigenerato, il grafo era allineato. Quello che non tornava era **cosa diceva**.

### Una tabella che raccontava il rovescio di se stessa

`MISURA_SEGNI.md` chiudeva con una lista sola — **«Punti regalati: guardati e
mai scritti»** — e ci sommava dentro i due versi in cui una clausola nomina un
segno, che sono **opposti**:

- lo **teme** (`state_tag_absent`) e il segno non esce mai → la clausola e'
  **vera dall'apertura**: un punto regalato;
- lo **vuole** (`state_tag_present`) e il segno non esce mai → la clausola e'
  **falsa per sempre**: una porta murata.

Dei 14 appigli in quella lista, **4 erano porte murate lette come regali**.
Ottava volta che un documento generato non fallisce e racconta la storia
sbagliata.

### Le quattro porte sono tutte di Vaerax

| passo | chiede | esce in 100 partite |
|---|---|---|
| `DST_VAERAX` · VITTORIA | `mine_sealed` | **0** |
| `DST_VAERAX_LEGEND` · SOGLIA | `mountain_forgotten` | **0** |
| `DST_VAERAX_LEGEND` · VITTORIA | `mine_sealed` | **0** |
| `DST_VAERAX_LEGEND` · TRIONFO | `mine_sealed` | **0** |

Un Destino murato a tutti e tre i passi. La catena: in 100 partite il Consiglio
del Risveglio apre `Q_AWAKENING_CRYSTAL` **una volta**, `Q_AWAKENING_MOUNTAIN`
**mai**; quell'unica volta il sigillo ando' ai voti e non passo'. Da li' non
parte la catena delle ere `TLY_SEAL`, quindi `mountain_forgotten` non si posa,
quindi la vita `INC_VAERAX_LEGEND` non siede **mai** e la regola
`TGR_LEGEND_VOICE` non morde **mai**.

### E i dieci regali

Il peggiore e' **`DST_LYRA_TAUGHT` · TRIONFO**: tre condizioni, due regalate.

### Cambiato

- `cli/run_world_marks_probe.gd`: tre liste invece di due, e **ogni riga dice il
  passo del Destino** che ci sta appeso — `DST_VAERAX · VITTORIA`, non un numero.
- La classificazione e' una funzione **pura**, `letture()`, perche' era li' che
  il difetto stava e non si poteva interrogare.
- `tests/unit/test_a_walled_step_is_not_a_free_point.gd`: tre prove, provate
  rimettendo la somma `f + v` al suo posto.
- `data/tags/tags_core.json`: la nota di `mountain_forgotten` diceva *«nessuno lo
  scrive piu'»* e non era vero — lo posa la catena delle ere, che pero' non
  aggancia mai il primo anello. Adesso lo dice.

### Il conto

| su 100 semi | prima | dopo |
|---|---|---|
| seggi bloccati su un solo livello | **0 su 8** | **0 su 8** |

Nessuna regola del motore toccata. Suite da 654 a **657 prove**. Le quattro
porte restano murate: aprirle e' bilanciamento, e sta in **ISSUES 108** con le
tre strade.

---

## 0.1.310 — Lo scheletro delle carte, e le righe che non dicevano cosa erano (D-345)

Il committente: *«voglio la struttura e lo scheletro di tutte le carte, poi devi
chiarire bene cosa sono le carte eco (carte di propp?), quale è la differenza
con carte azione?»*

### Lo scheletro non si scrive: si ricava

`docs/SCHELETRO_CARTE.md`, generato e sorvegliato da un cancello — il
ventunesimo. Per ogni mazzo guarda **tutte le facce vere** e raccoglie i blocchi
che portano, contando su quante carte ognuno compare.

| mazzo | formato | facce | pezzi |
|---|---|---|---|
| Asset | 63×88 | 48 | 132 |
| Eco | 63×88 | 39 | 39 |
| Domanda | 44×68 | 60 | 60 |
| Consiglio | 70×120 | 60 | 60 |
| Destino | 70×120 | 23 | 23 |
| Casata | 70×120 | 26 | 26 |
| Regione | 80×80 | 10 | 10 |

### E ricavarlo ha trovato due difetti

**Quattro mazzi avevano righe senza intestazione**: 180 sulle Domande, 64 sulle
Casate, 27 sulle Asset, 20 sulle tessere. Adesso ognuna ha la sua — `SI ACCENDE
QUANDO`, `SI RAFFREDDA`, `SEGNI`, `FONTI`, `SA FARE`, `VUOI LASCIARE`, `IMPEGNI`.

**E il Destino stampava tre parole inglesi** — `MINIMUM`, `VICTORY`, `TRIUMPH` —
sul tarocco che una casa guarda per contare quanto le manca. La prova di D-339
non le prendeva perché non sono enum dei dati. Adesso **SOGLIA**, **VITTORIA**,
**TRIONFO**.

### Carte Eco e carte Azione

Sono tutte e due carte che si calano da una mano e costano un'Occasione. Quello
che cambia è **quanto scegli**.

| | carta **Azione** | carta **Eco** |
|---|---|---|
| quante | 48 facce, 132 copie | 39 facce, una copia ciascuna |
| come arriva | ACQUISIRE, o la mappa | due a testa a inizio Atto |
| **scegli il bersaglio** | **sì** | **no**: lo decide il mondo |
| **scegli cosa fa** | **sì**, fra due Azioni | **no** |
| Risonanza | sempre | mai |
| lascia nel mondo | i segni delle sue Azioni | `function:<Propp>` |

**Sì, sono le carte di Propp**: ognuna porta una funzione della morfologia, e
calarla scrive quella funzione **sul mondo** come un segno — che è quello che le
rende un motore e non un evento, perché altre carte chiedono che una funzione
sia già successa.

**In una riga:** con una carta Azione scegli *dove* e *cosa*; con una carta Eco
scegli *solo quando*. Ed è anche il suo punto debole, dichiarato: una carta
senza scelta non è una decisione. È **ISSUES 107**.

### Il costo

Niente sul gioco: 100 semi identici, **0 seggi bloccati su un solo livello su
8**. Suite da 653 a **654 prove**.

### Verbali

**D-345** in `DECISIONS.md`, **ISSUES 107** aperta, `docs/SCHELETRO_CARTE.md` col
suo cancello.

---

## 0.1.309 — Il 100% delle carte si legge: via il racconto, sulla faccia gli Effetti (D-344)

Il committente: *«ogni azione, effetto e #tag deve essere visibile sulla carta,
eliminiamo testo narrativo inutile […] il 100% delle carte devono essere lette e
capite»*. D-340 aveva fatto le Asset, D-341 la scheda del Consiglio e la carta
Domanda: restavano quattro mazzi.

### Le carte Eco dicevano cosa si prova, mai cosa succede

**39 su 39. 86 Effetti scritti nel dato, zero stampati**, più 38 condizioni che
dicono quando la carta può uscire e che nessuno vedeva. Adesso la carta porta
**QUANDO ESCE** e **IL MONDO**:

> **QUANDO ESCE** La Carestia è al tavolo
> **IL MONDO** La Carestia sale · in una Regione con #granaio diventa #magra ·
> viene giù Granaio in una Regione con #granaio

Due modi di attaccare un Effetto, e all'inizio ne leggevo uno solo: otto carte
usano **solo** la forma «Conseguenza per id» e uscivano mute. L'ha presa la prova
che nessuna faccia sia vuota, che c'era già.

E la condizione **si genera**: le `label` d'autore portano l'id dentro — *«TEN_FAMINE
è in gioco quest'anno»* — su **24 delle 38**.

### La tessera Regione non portava i suoi segni

**32 segni su dieci tessere, nessuno stampato.** Ed è il difetto che rende
ingiocabile tutto il resto: una carta Azione si gioca «su un luogo con
#granaio», e se nessuna tessera dice #granaio quel bersaglio non si trova col
dito.

`_region` **costruiva già** la riga, e il foglio la buttava via prima di
disegnarla. Una riga calcolata e mai disegnata è il modo più silenzioso di non
stampare una regola: la prova nuova legge **l'inchiostro**, non la faccia.

### Il cancelletto, e dove non va

Ogni segno lo porta: `#granaio`, `#magra`, `#conteso`. **Tranne dove il nome
stampato non è una parola sola** — «dominio: la sopravvivenza», «il grano è stato
requisito». Il primo tentativo cuciva le parole coi trattini bassi
(`#tagliata_fuori`, `#cacciata_da_dove_si_discuteva`) e **le ha prese subito la
prova di D-339**: un `#` con dei trattini somiglia a un id.

### «Dove si discute» non vale su ogni carta

È la parola del Consiglio, sbagliata su una carta Eco che un Consiglio non lo
apre: **12 Effetti su 110**. Adesso chi disegna la faccia dice come si chiama
quel posto.

### Il costo

| | fuori dal bordo | col corpo stretto |
|---|---|---|
| **Eco (39)** | **0** | **0** |
| Domanda · Consiglio · Destino · Casata · Regione | 0 | 0 |
| Asset (48) | 0 | 46 (il debito di D-340) |

Le carte Eco dicono quattro volte più cose e stanno a corpo pieno: quello che
entra è più corto del racconto che esce.

**Sul gioco niente**: 100 semi identici, **0 seggi bloccati su un solo livello su
8**. Suite da 650 a **653 prove**.

### Verbali

**D-344** in `DECISIONS.md`. Tre guardie nuove, tutte partite dai dati e tutte
provate su un difetto piantato.

---

## 0.1.308 — La prima casella: il Consiglio sa muovere una domanda (D-343)

D-342 ha nominato nove caselle mancanti; questa è la prima, e vale da sola **90
applicazioni su 336**. È quella che il committente non riusciva a leggere sulla
scheda — *«La Carestia +1 non so cosa intende»*.

| | |
|---|---|
| **ABBASSA LA DOMANDA** | beneficio · sposta di 1 indietro il segnalino |
| **ALZA LA DOMANDA** | costo · sposta di 1 avanti il segnalino |

Su tutte e 60 le carte, con la riga che dice quale segnalino si muove. E come
SCALDA TEMA si ferma al tetto del Calore, queste si fermano ai capi della
traccia: una domanda a zero non si abbassa, una in cima non si alza.

### Sulla carta, molta strada

| `MISURA_CASELLE` | prima | dopo |
|---|---|---|
| **verbo che manca** | 27 distinti · 171 usi | **16 · 81** |

### Al tavolo, una volta su settantadue

Una sonda nuova — `run_boxes_probe.gd`, il «fatto quando» che ISSUES 72 chiedeva
— conta quante volte una casella è offerta e quante è presa. Venti partite:

| casella | offerta | comprata |
|---|---|---|
| CAMBIA CONTROLLO | 32 | **32** |
| RAFFREDDA TEMA | 72 | 6 |
| **ABBASSA LA DOMANDA** | **72** | **1** |

**La casella c'è, si gioca, e il cervello quasi non la vuole.** Non ho ritoccato
il suo valore: alzarlo è equilibrio, e l'equilibrio si misura. Ed è la ragione
per cui il playtest non si muove — una casella che nessuno compra è, per il
gioco, identica a una che non esiste, e la differenza si vede solo con questa
sonda.

### Il costo

**Sul vincolo niente**: 100 semi identici, **0 seggi bloccati su un solo livello
su 8**. Sul mondo poco e in meglio: `MISURA_VITE` dice **208 trasformazioni
sedute invece di 204**. Suite da 648 a **650 prove**.

### Tre copie della stessa lista

I verbi stavano in tre posti — lo schema, il modulo che li esegue, il validatore
— e la terza si è vista quando una casella nuova è entrata nelle altre due: **il
validatore ha bocciato dati validi**. Ora legge l'enum dallo schema.

### Due correzioni

La sonda di D-342 costruiva un contesto finto **senza la domanda in
discussione**, e le caselle nuove uscivano vuote: avrebbe detto che nessuna
casella sa muovere una domanda mentre due lo facevano.

E i numeri di «Il conto» in D-342, in 0.1.307 e in ISSUES 89 erano **64/41/231**
— di una misura precedente ai pool. Il documento che citano diceva già
**121/44/171**. Corretti: è il difetto contro cui D-342 è stata scritta,
commesso nella decisione che lo denuncia.

### Verbali

**D-343** in `DECISIONS.md`, **ISSUES 89** aggiornata, **ISSUES 72** chiusa (la
sonda che mancava c'è), **ISSUES 106** aperta: *«la sceglie chi propone»* chiede
che la pedina porti con sé il nome della domanda, e quello tocca l'API dei
benefici, i due cervelli e il tabellone.

---

## 0.1.307 — Il «65% non traducibile» era un elenco di nove caselle (D-342)

Nessun verbo del gioco toccato: una sonda, un cancello e un documento. Ma la
voce più pesante aperta cambia forma.

### La correzione viene dal committente

ISSUES 89 diceva che **il 65% di quello che una proposta fa non è traducibile in
casella**. Portato un esempio vero, il committente:

> *«La casella dice: chiudi una strada tra una tessera #pascolo e #selvaggio, se
> c'è si può usare quella casella altrimenti no. Non vedo perché non potrebbe
> essere scritta su una casella.»*

Aveva ragione su tutti e tre i punti che avevo chiamato ostacoli. Il 65% contava
contro le **dodici caselle di adesso**, non contro quello che una casella può
dire: era una misura giusta presentata come una conclusione sbagliata.

### E l'economia era già costruita

`council_economy.gd` **esiste, esegue e ha già la sua idoneità**: dodici verbi,
l'economia di D-280, il prezzo scelto dagli avversari. ISSUES 72 la dava da
costruire.

Quindi il quadro vero, che nessun documento diceva: **il Consiglio cambia il
mondo in due modi che girano insieme** — le caselle, e le Conseguenze d'autore
che la proposta porta con sé. Il controller applica tutte e due. Da D-341 la
scheda ne stampa solo le prime.

### La misura

`cli/run_box_survey.gd` prende ogni Effetto che un Consiglio può applicare — le
proposte, i tre pool e le clausole — e lo confronta col vocabolario. **Il
vocabolario non è ricopiato**: la sonda chiama `effects_for` e guarda cosa esce.

| | distinti | applicazioni |
|---|---|---|
| una casella di oggi lo sa dire | 4 | 121 |
| verbo giusto, posto che la casella non sa dire | 15 | 44 |
| **verbo che manca** | **27** | **171** |

E i 27 si raggruppano in **nove caselle**. La più pesante vale da sola **90
applicazioni su 336**, ed è quella che il committente non riusciva a leggere
sulla scheda — *«La Carestia +1 non so cosa intende»*: l'effetto sposta la
traccia di un'altra domanda, e non c'era scritto. Scelta presa: **la sceglie chi
propone**.

Una differenza strutturale emersa misurando: **le caselle di oggi non toccano le
domande.** RAFFREDDA e SCALDA TEMA muovono un *Tema*; tutte e 90 quelle
applicazioni muovono una *domanda*. Due tracce diverse, e nessuna casella sa
muovere la seconda.

### Il costo

Nessuno: playtest 100 semi identico, **0 seggi bloccati su un solo livello su
8**, suite invariata a 648 prove. Il cancello morde — piantato un
`CLOSE_PASSAGE` in una Conseguenza, `--check` esce 1 — e la sonda si rifiuta di
scrivere se dalle caselle non esce un solo Effetto.

### Verbali

**D-342** in `DECISIONS.md`, **ISSUES 89** riscritta col conto nuovo, **ISSUES
72** corretta (diceva «da costruire» una cosa costruita), `docs/MISURA_CASELLE.md`
e il suo cancello — il ventesimo.

---

## 0.1.306 — Due grammatiche sulla stessa scheda, e le caselle stavano in fondo (D-341)

Le tre domande del committente sulla scheda de La Carestia: *«due domande? Perché
due, i costi e benefici dove sono? Ci sono testi ridondanti e inutili»*. Tre
difetti diversi, tutti e tre misurabili.

### «Perché due»: la ragione era scritta e buttata via

**Ventuno condizioni** — 11 di domande, 10 di proposte — hanno una `label`
scritta per il giocatore (*«La Carestia è al limite»*, *«Solo chi porta la corona
può requisire»*), e **nessuna arrivava sulla scheda**. `CouncilText` le calcolava
già e la faccia le scartava.

### «I costi e benefici dove sono»: in fondo, e schiacciati

Le dodici caselle di D-280 — la grammatica con cui il tavolo risolve un Consiglio
— stavano dopo quattro proposte in prosa, sei per riga separate da punti. Adesso
in cima, **una per riga**.

### E allora le proposte non ci stanno più — misurato, non deciso

| scheda 70×120 | fuori dal bordo |
|---|---|
| caselle in cima, proposte intere | **2 su 12** |
| caselle in cima, proposte **senza la frase** | **1 su 12** |
| **caselle sole** | **0 su 60** |

Non è la prosa a non starci: sono le proposte. Sulla scheda resta la grammatica
del tavolo — la domanda con la sua condizione, e le dodici caselle. **Da 2.399
caratteri a 737**, tutte e 60 a corpo pieno.

**Cosa si perde, dichiarato:** le proposte che l'app risolve fanno cose che
nessuna casella sa dire — *«Foresta va al grado 2»*, *«il rivale entra in una
Regione confinante»* — ed è il **65% misurato in ISSUES 89**. Finché quella voce
è aperta, la scheda dice quello che il tavolo può fare. Le proposte restano
intere in `CATALOGO_CONSIGLI`.

### Due riparazioni di grammatica

**Una Cicatrice è un segno in un posto, non una frase.** Stampava la
`description` (1.142 caratteri su quindici schede) e taceva `tag` e `region_id`,
che sono campi: adesso dice *«e resta una Cicatrice: lo sgombero dove si
discute»*.

**Sessantacinque caselle cominciavano con un racconto** — *«Cade, e i granai
restano chiusi a chiave: chi ha fame se lo ricorda. Al luogo si aggiunge
#fame.»* La regola è l'ultima frase, e SE CADE dice già il resto: **35.057
caratteri → 31.172**.

### La carta Domanda perde il racconto, come la carta Asset

Stessa scelta di D-340: da **421 caratteri a 293**, e tutte e 60 stampano a corpo
pieno.

### ISSUES 103 si chiude

Le **841 caselle** entrano in `REVISIONE_TESTI`, ognuna col suo id —
`TEN_FAMINE, se cade — F_CONDITION` — così le sessantacinque riscritte si
rileggono con una riga. Il documento cresce di 3.635 righe.

### Il costo

**Nessuno sul gioco:** playtest 100 semi identico, **0 seggi bloccati su un solo
livello su 8**, misto e uniforme. Suite da 644 a **648 prove**; quattro guardie
nuove, tutte provate su un difetto piantato.

### Verbali

**D-341** in `DECISIONS.md`, **ISSUES 103** chiusa, **ISSUES 104** aperta (tre
proposte su quarantanove fanno la stessa identica cosa: la prosa lo nascondeva).

---

## 0.1.305 — La carta stampava il racconto e taceva la faccia che si gioca (D-340)

Il committente, guardando la carta Azione generata: *«devi eliminare ogni
narrativa prolissa e far capire esattamente al giocatore che quel beneficio è un
#tag che si mette in un posto preciso, o una azione che si fa. Ovvio che servono
carte gigantesche se si scrive la divina commedia su di esse.»*

### La carta Asset **è** la carta Azione, e non lo stampava

È lei che porta il blocco `physical` — bersaglio a segni, due Azioni, Risonanza,
uso in Consiglio. Ce l'hanno tutte e 48, e la faccia stampata non ne diceva
niente: al suo posto `rules_text`, che è voce d'autore.

| sul blocco `physical` | scritto | stampato |
|---|---|---|
| bersaglio a segni | 48 | **0** |
| Azioni | 96 | **48**, solo come verbo |
| Risonanza — avviene sempre | 48 | **0** |
| uso in Consiglio | 48 | **0** |

E il racconto che ne prendeva il posto: **48 carte su 48** nominavano una Regione
per nome, che è la cosa che la grammatica fisica vieta; **12 su 48** ripetevano
un fatto già detto dalla riga meccanica accanto.

### Tre righe su cinque non si scrivono a mano

**SEMPRE** e **AL CONSIGLIO** sono interamente campi strutturati, e adesso si
generano da quelli: è l'unico modo perché la carta non possa dire una cosa e il
motore farne un'altra. È la lezione di D-336, dove 89 frasi su 164 erano costanti
scritte accanto a dati che nel frattempo erano cambiati.

### Il racconto tolto dai 96 testi

Tutte le Azioni avevano la stessa forma — la regola, poi una frase di colore.
Riscritte tenendo ogni regola, comprese quelle nascoste in coda: **8.666
caratteri → 5.751, il 34% in meno**.

### Il costo, dichiarato

| su 48 carte | prima | dopo |
|---|---|---|
| fuori dal bordo | 0 | **0** |
| corpo sotto la misura piena | **4** | **46** |
| la più stretta | — | **77%** |

La carta dice quattro volte più cose e il corpo si stringe; l'illustrazione è
scesa al suo pavimento del 34% su tutte e 48. Nessuna sfonda il bordo, nessuna
scende sotto il 74% che la prova sorveglia — ma 46 su 48 stampano rimpicciolito,
e la decisione che resta è del committente: **tarocco anche per le Asset, o
l'illustrazione lascia la faccia delle regole**.

Sul gioco niente: playtest 100 semi identico, **0 seggi bloccati su un solo
livello su 8**, misto e uniforme.

### Il documento dei testi ne mancava 1.128

`REVISIONE_TESTI` raccoglieva `title` e `rules_text` e lasciava fuori il blocco
fisico intero: **287 testi su 288** delle carte Asset, e **841 su 841** delle
caselle di Tensione. È la sesta volta che un documento generato non fallisce e
racconta il mondo sbagliato — dopo D-329, D-333, D-334, D-336 e D-338. Riparata
la parte Asset; le Tensioni sono **ISSUES 103**.

### Verbali

**D-340** in `DECISIONS.md`, **ISSUES 69** aggiornata (la faccia si stampa; resta
il formato), **ISSUES 103** aperta. Suite da 642 a **644 prove**; giro completo
dei cancelli verde per codice di uscita.

---

## 0.1.304 — Le carte parlavano inglese, e nessuno le guardava (D-339)

Il committente, dopo la scheda del Consiglio: *«poi fammi un esempio di carta»*.
Generata **La Carestia** in scala 1:1 e guardata. Sul sottotitolo:

> domanda · **survival** · al Consiglio valgono: **wealth, people, authority**

Le parole italiane **esistevano**: i domini in `SignLabels`, le famiglie chiuse
dentro `help_panel.gd` — che è una vista, e una tabella di parole chiusa in una
vista la vede solo quella vista.

### Non erano due carte

| dove | cosa si leggeva |
|---|---|
| **48 carte Asset** | `authority · comune` |
| **10 tessere Regione** | `fonti: authority, force` |
| **carte Casata** e ogni vita | `faction · vuole wealth` |
| **le Casate**, valori d'azione | `acquire 3 · claim 1 · forge 3` |
| **60 carte Domanda** | `domanda · survival` |
| 54 stringhe di dato | `ACQUIRE su AUTHORITY` |
| 2 descrizioni | `dominio SURVIVAL (D-028)` — anche l'id di una decisione |

Cinque enum senza parola italiana — famiglie, archetipi, bisogni, verbi — più
`KNOWLEDGE`, che mancava alla tabella dei domini che già esisteva.

### Fatto

- **Cinque tabelle in `SignLabels`**, il posto dichiarato dove un id diventa una
  parola. `help_panel.gd` non ha più la sua.
- **Le facce le usano**: Asset, Regione, Casata (sottotitolo e valori), Domanda.
- **56 stringhe di dato corrette** — tutte con la stessa forma meccanica, non
  voce d'autore.

### La guardia

Non guarda un elenco di parole vietate: prende **gli enum dai dati** e chiede che
nessuno arrivi su una faccia com'è scritto nel JSON. **Ha morso quattro volte di
fila** mentre riparavo — Asset, Casate, Regioni, e archetipi/bisogni che avevo
mappato sulla tabella sbagliata.

### Il costo, dichiarato

**Nessuno sul gioco**: playtest 100 semi, **0 seggi bloccati su un solo livello
su 8**. Quattro documenti generati rigenerati (`CATALOGO_CARTE`,
`CATALOGO_CONSIGLI`, `REVISIONE_TESTI`, `BRIEF_ARTE`), tutte le derive sono la
stessa correzione. Suite da 641 a **642 prove**, diciannove cancelli verdi.

---

## 0.1.303 — La scheda del Consiglio: due pezzi, due mestieri (D-338)

Il committente, dopo la misura di D-337: *«facciamo formato tarocco o quello che
serve in più»*.

Provato il tarocco per la carta intera, **non basta**: `TEN_SUCCESSION`, con
sette proposte, esce dal bordo anche a 70×120. E c'è una ragione più seria: una
prova che c'era già dice *«le domande sono mini, **per la traccia**»* — è D-097,
ed è fisica. La carta Tensione **sta appoggiata alla traccia dei valori**.

Quindi la seconda metà della frase: **quello che serve in più**.

| pezzo | formato | mestiere |
|---|---|---|
| carta **Domanda** | 44×68, resta mini | sta sulla traccia, dice **quando** la domanda si scalda |
| scheda **Consiglio** | 70×120, tarocco | si tira fuori quando il Consiglio si apre, dice **cosa si può proporre e cosa costa** |

Sulla scheda: la domanda, ogni proposta **con cosa lascia** (la riga che D-336 ha
fatto dire il vero), e le **dodici caselle** — SI OTTIENE, SI PAGA, SE CADE — che
non erano stampate da nessuna parte.

### La misura ha scelto la forma, non io

| tentativo | esito |
|---|---|
| tutto sulla carta, **mini** | non ci sta, di quattro volte (D-337) |
| tutto sulla carta, **tarocco** | **una carta sborda** |
| **carta mini + scheda tarocco** | **tutte e 60 ci stanno** |

### Il costo, dichiarato

**Sessanta pezzi di cartone in più.** I fogli A4 di carte e tessere passano da
**39 a 54**; con i tre fogli-fustella la scatola ne stampa 57. È il prezzo che
ISSUES 89 prevedeva per la strada (b), pagato dove costa meno: non sulla carta
che tieni in mano tutta la partita, ma su una scheda che tiri fuori quando serve.

**Nessun costo sul gioco:** playtest 100 semi, **0 seggi bloccati su un solo
livello su 8**. Non è cambiata una regola.

### E un documento che non sapeva di avere sessanta pezzi in più

`components_survey.py` costruisce la tabella dei mazzi da **righe scritte a
mano**, non dai mazzi che `CardFace` dichiara. Aggiunto un mazzo, il documento
che conta i pezzi della scatola non se n'è accorto e **non è fallito**. Aggiunta
la riga; che la tabella si costruisca da sola resta da fare.

Diciannove cancelli verdi, suite 641 prove / **36.404 asserzioni**.

---

## 0.1.302 — La carta stampava la frase che non si può giocare (D-337)

D-336 ha fatto dire il vero alla frase, ma quella riga vive in due documenti.
ISSUES 89 chiede la **carta**. Quindi: cosa c'è stampato sulla carta Tensione?

**Niente del lavoro fisico degli ultimi sessanta rilasci.** Non le dodici
caselle di D-280, non SI ACCENDE QUANDO di D-330, non la domanda né le proposte
di D-310. Titolo, soglia, descrizione, prosa, famiglie: è la faccia di prima di
D-280.

### Il numero che decide, e non lo decido io

| blocco | mediana | max |
|---|---|---|
| descrizione | 89 | 162 |
| si accende quando | 63 | 189 |
| **le caselle** | **582** | 653 |
| la domanda | 85 | 122 |
| le proposte | 203 | 592 |
| **tutto insieme** | **1.024** | **1.484** |

Su una carta **44×68 mm**, che ne regge duecento scarsi. ISSUES 89 prevedeva
«la carta diventa fitta»: **non ci sta, di quattro volte**. Il rimedio è una
decisione di prodotto — formato più grande, un retro, o una scheda del Consiglio
a parte — e sta in ISSUES 89 con questo numero accanto.

### Quello che ci sta, ed era anche un difetto

La carta stampava `triggers`, prosa d'autore: *«Ogni raccolto mancato nella
Valle Verde»*. Un giocatore la legge e non sa quando la Tensione sale. La regola
vera esiste da D-330, è in segni, il motore la esegue: *«una carta posa #fame o
#requisito o #malcontento»*.

**La carta stampava la frase che non si può giocare e nascondeva quella che si
gioca.** Scambiate.

### Il costo, dichiarato — ed è negativo

Lo scambio **toglie 1.559 caratteri dal mazzo**: 5.063 di prosa contro 3.504 di
regole. Più giocabile e più corta. Le 13 Tensioni senza casella tengono la
prosa, perché per loro vale ancora il ponte.

Playtest 100 semi identico — 159/143 misto, 149/125 uniforme, **0 seggi bloccati
su un solo livello su 8**. Suite da 640 a **641 prove**, diciannove cancelli
verdi.

---

## 0.1.301 — Il catalogo dei Consigli diceva il falso su 89 righe (D-336)

Il committente ha scelto la strada **(b)** di ISSUES 89: *«il motore continua a
fare quello che fa, ma la carta lo dice, generato dal dato con un cancello che
sorveglia»*. Andando a costruirla, **metà esisteva già** — e diceva il falso.

`CATALOGO_CONSIGLI` rende da D-232 ogni proposta in grammatica di segni,
generato e sorvegliato in CI. Ma la frase era un dizionario di **stringhe fisse,
una per tipo di Effetto**: diceva il verbo e non il bersaglio.

### Il conto: 89 righe su 164

| | quante | prometteva → faceva |
|---|---|---|
| il posto | **33** | «dove si discute» → altrove |
| la questione | **26** | «la domanda in gioco» → un'altra per nome |
| la casa | **18** | «una casa» → quale? |
| il grado | **7** | «sale o scende» → da che parte? |
| il verso | **5** | «sale» → scendeva |

La stessa proposta, prima e dopo — *«Il grano sia requisito in nome del trono»*:

> **prima:** si alza una costruzione **dove si discute** · **la domanda in gioco** sale
>
> **adesso:** si alza **Granaio in una Regione con granaio** · **Le Vie Interrotte** sale

Il Granaio si alza in un'altra Regione, e la domanda che sale è un'altra
questione. **E il cancello non poteva accorgersene**: confronta il documento col
generatore, non il generatore col motore. Terza volta in una settimana, dopo
D-329, D-333 e D-334.

### Fatto

- `effect_note()` riceveva già l'Effetto intero e ignorava bersaglio e payload.
  Ora la frase porta **il luogo, la casa, la questione per nome, il verso e la
  Pietra col suo nome**.
- **Il dizionario aveva la parola e nessuno la chiedeva**: `granaio`, `pascolo`,
  `cristallo`, `capitale` non stanno in `SignLabels`, e si stampava
  *«crystal_site»*. Il campo `title` del dizionario è il nome stampato per
  definizione dello schema: ora `SignLabels` lo consulta, e vale anche per la
  mappa e per il foglio dei segnalini.
- **Un segnaposto non è il nome di un posto**: `evicted:$region_focus` e
  `settlement:$proponent` arrivavano stampati sulla scheda.
- **Una carta stampava il verso sbagliato sulla propria faccia.**
- **La guardia che mancava**: non confronta due testi, confronta la frase col
  dato — ogni Effetto deve nominare posto, casa e verso, e un bersaglio ignoto
  cade su un ripiego dichiarato. Una seconda prova pianta un bersaglio inventato
  e verifica che il ripiego scatti. Ha morso subito, su `settlement:$proponent`.

### Il costo, dichiarato

**Nessuno sul gioco.** Playtest 100 semi identico: Verità 159/143 misto, 149/125
uniforme, **0 seggi bloccati su un solo livello su 8**. È cambiato come un
Effetto si descrive, non cosa fa. Due cataloghi rigenerati (281 righe e 37),
tutte correzioni. Suite da 638 a **640 prove**, diciannove cancelli verdi.

### Quello che resta

La frase adesso dice il vero, ma **non è ancora sulla carta**: vive in due
documenti. Il «fatto quando» di ISSUES 89 chiede che una proposta si risolva
guardando solo la carta e la mappa. ISSUES 89 resta aperta.

---

## 0.1.300 — I 642 Effetti del Consiglio erano 164, e il 77% era un 35%

Nessun codice. La voce più pesante aperta — **ISSUES 89**, *«la proposta non si
risolve col dito»* — chiedeva di guardare i residui uno per uno, *«sono pochi
abbastanza»*, e nessuno l'aveva fatto. Fatto adesso, e la misura corregge sé
stessa in due punti.

### Primo: 642 non era la quantità di lavoro

Quel numero conta ogni **applicazione** — una Conseguenza usata da trentaquattro
proposte pesa trentaquattro volte. Oggi le applicazioni sono **841**, perché il
mazzo è cresciuto, ma gli **Effetti distinti scritti sono 164**, in 56
Conseguenze su 234 proposte.

Il lavoro è su 164 righe, non su 841. **Cinque volte più piccolo** di come la
voce lo faceva sembrare.

### Secondo, e più grave: «494 su 642» era il 77%. Il conto vero è il 35%

Il numero vecchio guardava il **verbo** e non guardava **dove**. Le regole vere
di una casella sono due: il verbo dev'essere fra i dodici, **e** il bersaglio
dev'essere il luogo di cui si discute, il Tema, o il mondo.

| come si conta | su 841 | |
|---|---|---|
| solo il verbo, bersaglio ignorato | 401 | 48% |
| verbo + la traccia della questione | **631** | **75%** ← è il numero vecchio |
| **verbo + bersaglio** | **295** | **35%** |

Le due scale concordano: per Effetto distinto è **55 su 164**, il 34%.

Non è contabilità. **Il «dove» è esattamente ciò che rende fisica una casella**:
una casella agisce sul luogo che hai davanti col dito sopra. *«Prendi il
controllo di un altro luogo con #commercio»* ha il verbo giusto e non può essere
una casella — ed è l'esempio del Traghetto che la voce stessa racconta. Lo
diceva a parole, e il suo numero non lo contava.

### I 164, in quattro gruppi

| | distinti | applicazioni |
|---|---|---|
| **0** — una casella di oggi lo sa dire | **55** | 295 |
| **1** — la traccia della questione (`ADJUST_TENSION`) | **36** | 230 |
| **2** — verbo giusto, posto sbagliato | **24** | 106 |
| **3** — verbo che manca davvero | **49** | 210 |

**Il gruppo 1 è una casella sola**: al tavolo la traccia c'è già e il segnalino
si muove col dito, manca solo il verbo che lo dica.

**Il gruppo 2 non chiede verbi nuovi**, chiede un modo di dire *quale* luogo — e
quella grammatica esiste già sulle carte Azione da D-262 (*«la Regione col
#granaio»*): non è mai stata portata sulla faccia della Tensione.

**Il gruppo 3 è il solo che obbliga a inventare**: 18 segni che una casa porta
addosso, 8 gradi di Pietra, 6 rapporti, 8 presenze che arrivano o se ne vanno,
4 memorie che il mondo dimentica, più quattro pezzi unici.

### Cosa cambia per la scelta

La strada **(a)** — la proposta diventa un menu di caselle — è **più piccola e
più difficile** di come sembrava. Più piccola: 164 righe. Più difficile: il 65%
non è traducibile con quello che c'è, non il 23%.

Ma si può fare in tre passi con una soglia visibile dopo ognuno, e **i primi due
non chiedono di decidere niente di irreversibile**: una casella per la traccia
(36 distinti, 230 applicazioni), poi il bersaglio a segni sulla faccia della
Tensione (altri 24 e 106). Resta il 30% che chiede verbi nuovi, ed è lì che si
decide cosa il Consiglio non deve più poter fare.

**La misura non sceglie la strada.** La scelta resta del committente.

### Verbali

**ISSUES 89** riscritta col blocco della rimisura. Nessun cancello toccato: giro
completo verde, playtest 100 semi, **0 seggi bloccati su un solo livello su 8**,
misto e uniforme.

---

## 0.1.299 — La vita delle Pietre, rimisurata, e la misura che non la vede

Nessun codice: due misure e due verbali. Nasce da una domanda del committente
davanti al grafo dei segni — *«una Pietra posata su una Regione non la vede
nessuno? Mi pare strano»* — e da una seconda subito dopo: *«non è possibile che
scritto e clausole siano così poche»*.

Aveva ragione due volte, e in un caso su due il difetto non era dove sembrava.

### La prima risposta: la Pietra la vedono eccome, tranne otto segni

Dei **28 segni che una Pietra posa, 20 hanno un lettore**. Il nastro verso
NESSUNO nel grafo ne porta otto, e hanno una forma:

| Pietra | grado 1 | grado 2 | grado 3 |
|---|---|---|---|
| Foresta | `place:forest` letto | `place:thinned_wood` **muto** | `place:cursed_wood` letto |
| Sorgente | `place:spring` letto | `place:low_spring` **muto** | `place:dry_spring` **muto** |
| Sito antico | `place:sleeping_site` letto | `place:open_site` letto | `place:stripped_site` **muto** |
| Passo | `place:pass` **muto** | `place:collapsed_pass` **muto** | — |

Quello che una Pietra **diventa** quasi non lo guarda nessuno. Ognuno di questi
porta già una `note` che lo dichiara colore in attesa di lavoro: è dichiarato,
ma è dichiarato tanto.

### La seconda: il numero di ISSUES 39 era morto da trenta versioni

*«74 costruite, zero abbattute»* aveva aperto la strada C, e la sonda che lo
teneva — `cli/run_stone_probe.gd` — dichiarava lei stessa che nessuno l'aveva più
rifatto. Rifatto adesso, 100 partite, tavolo misto, semi da 7000:

| | su 30 Chronicle | **su 100 partite** |
|---|---|---|
| alzate | 74 — 2,5 a partita | **1062 — 10,62 a partita** |
| abbattute | **zero** | **24** |
| andate in rovina | non misurato | **50** |
| salite di grado | non misurato | **142** |
| **scese di grado** | non misurato | **0** |
| in piedi a fine anno | 2 a partita | **8,98**, di cui 1,50 di grado 2+ |

**La mappa non può più soltanto riempirsi**: ventiquattro Pietre cadono e
cinquanta vanno in rovina. Su questo la strada C ha già vinto.

**Ma il grado è una scala a senso unico**: 142 salite, **zero discese** su cento
partite. O cade tutta la Pietra, o resta dov'è arrivata.

E la domanda di ISSUES 52 ha una risposta: delle 1062, **856 le posa
l'apertura** e solo **206 il Consiglio o un'Eco**. Quattro Pietre su cinque le
distribuisce l'allestimento, non l'anno.

### La terza, che nessuno aveva chiesto: la misura è cieca

Nessuno di quei gesti lascia un segno che `MISURA_SEGNI` sappia contare.
`_build_structure` scrive il segno del grado con `_apply_grade_tag`, **dentro**
l'effetto `BUILD_STRUCTURE`, senza emettere un effetto di segno — ed è la scelta
giusta per il motore (*«l'oggetto è la verità, il tag è derivato»*). Ma la sonda
conta gli effetti di segno.

Sugli stessi vent'anni: **214 Pietre alzate, sette segni contati.** Non è
un'approssimazione.

E ce ne sono altri due, nessuno dei tre dichiarato riga per riga: la sonda guarda
solo `MEMORY` e `STATE` — **138 segni su 204 non hanno un numero** — e le colonne
«temuto/voluto» leggono solo Destini e obiettivi, non le regole del segno, le
facce delle carte, i Consigli, le Tensioni. È **ISSUES 102**.

### Il grafo dei segni, riparato

Fuori dal repo, ma è dove le tre cose si sono viste. Quattro difetti:

- la colonna **«chi lo legge» aveva le barre e non i nomi**: le etichette erano
  disegnate oltre il bordo della tela;
- **le trecce uscivano dal fondo**: l'altezza di ogni nastro era scalata sul
  numero di segni del nodo invece che sulla somma dei nastri di quel lato, e un
  segno con due lettori manda due nastri ma vale uno — l'eccedenza colava fuori;
- i dati erano di prima di D-334, con *«il codice del motore»* ancora fra le mani;
- e le due colonne numeriche mostravano i buchi di `MISURA_SEGNI` come se fossero
  zeri del gioco.

### Verbali

**ISSUES 102** aperta, **ISSUES 39** rimisurata nel suo blocco. Nessun cancello
toccato: giro completo verde, playtest 100 semi, **0 seggi bloccati su un solo
livello su 8**, misto e uniforme.

---

## 0.1.298 — Le righe guardavano tre gesti che le Azioni non fanno (D-335)

### La domanda lasciata aperta da D-332

Perché la casella «si accende quando» decideva solo il **5,2%** delle cadute di
Calore, e il ponte tutto il resto? Non era quante questioni si svegliano. Era che
le righe guardavano dalla parte sbagliata.

**Contato cosa le Azioni fanno davvero, in vent'anni:** una Presenza arriva
**175** volte, un rapporto cambia **159**, una Presenza se ne va 58, un segno
cade sulla mappa **6**, il controllo cambia **0**, si costruisce una Pietra **0**.

**Contato cosa le righe aspettavano, sulle 66 stampate:** **47** aspettavano un
cambio di controllo, 17 un segno di Regione, 1 una Pietra, 1 una Presenza tolta.

Quarantotto righe su sessantasei aspettavano un gesto che non succede — e non per
sfortuna: **nessuna delle 48 carte Azione produce `SET_CONTROL`**. Il controllo
cambia al Consiglio, che sta a valle del Calore, non a monte.

### E un terzo difetto, sulla carta disegnata a mano

Il filtro del luogo guardava la Regione **bersaglio** dell'Effetto. Ma una
Presenza ha come bersaglio la **casata**: il posto sta nel payload. Quindi ogni
riga di Presenza con un filtro di luogo era muta per costruzione — compresa la
quarta riga de *I Recinti*, *«toglie una Presenza da una terra da coltivo»*, che
non si è mai potuta accendere da quando è stata scritta.

### Fatto

- **`adds_presence`**, il verbo che mancava al gesto più frequente della mappa.
- **Il filtro del luogo legge `payload.region_id`**, e ricade sul bersaglio
  quando non c'è. Tre prove nuove, di cui una che dice **no**.
- **Le 47 righe `takes_control` ripuntate** su ciò che le Azioni fanno in quel
  posto. Sono righe derivate a macchina: ripuntare un pavimento non è riscriverlo.
- **Su *I Recinti* una riga sola**, e sta a verbale quale.
- **Non aggiunto `changes_relation`**: 159 gesti l'anno senza verbo, ma nessuna
  riga lo userebbe senza scrivere contenuto. Aggiungere un verbo che nessuno usa
  è inventare.

### Il guadagno

| su vent'anni, seme 7000 | prima | dopo |
|---|---|---|
| **la casella decide** (ponte spento) | 20 su 383 — **5,2%** | 121 su 409 — **29,6%** |
| questioni diverse toccate | 49 su 60 | **52 su 60** |
| Calore a un Tema diverso dalla carta | 5 | **54** |
| gesti che svegliano più di una questione | 0 | 7 su 401, mai più di **tre** |

L'ultima riga è la frase del committente misurata — *«raramente un singolo gesto
scalda più di tre temi»*: non succede mai.

### Il costo, dichiarato — e non è piccolo

| su 100 semi | prima | dopo |
|---|---|---|
| **seggi bloccati su un solo livello** | **0 su 8** | **0 su 8** |
| Consigli per anno, misto / uniforme | 3,40 / 3,45 | 3,43 / 3,48 |
| **Verità scritte**, misto | **167**, 153 diverse | **159**, **143** diverse |
| **Verità scritte**, uniforme | **158**, 137 diverse | **149**, **125** diverse |
| trasformazioni sedute | 199 | **204** |
| **vite che non si sono mai sedute** | 6 | **7** (*Il Banco Nero*) |

**Il mondo ricorda meno**, e su una direzione che dice *«il Consiglio decide cosa
il mondo ricorderà»* è il numero che pesa di più. Si sa dove se ne vanno: al
tavolo uniforme i fallimenti scendono da 27 a **15** e i successi netti salgono
da 146 a **167**. I Consigli passano più puliti, e un successo che non costa
niente lascia meno memoria di uno pagato.

**Provata e scartata** la variante stretta (solo la Presenza che arriva): Verità
identiche, 159/143. Restringere non compra niente.

### Una prova che ha smesso di provare, e l'ha detto

`test_without_the_box_the_bridge_still_carries` è andata rossa, e aveva ragione:
il suo presupposto — *«quel segno non lo guarda nessuna delle sessanta»* — non è
più vero. Cercare un posto che nessuna riga guarda non serve, **non esiste**: le
46 righe coprono tutta la mappa. Adesso la prova si fabbrica la condizione, mette
a tacere il banco e prova il ripiego da solo.

### I cancelli

Diciannove verdi per codice di uscita. Suite **638 test in 97 suite, 35.881
asserzioni**. `MISURA_VITE` e `MISURA_SEGNI` hanno derivato per la **quinta**
volta in questa serie, e sono rigenerate.

---

## 0.1.297 — Il motore non posa gettoni (D-334)

### Detto dal committente

> *«Il motore che mette segni deve sparire: non esiste nel gioco fisico, quindi
> non dovrebbe esistere.»*

Nel dizionario dei segni ogni voce dichiara chi la scrive. Fra le mani c'era
`engine` — e non era una mano come le altre: nel validatore aveva una costante
che la chiamava `MANO_INVISIBILE` e la **esentava dal riscontro**. Bastava
scriverla perché un segno senza penne ne avesse una.

### La misura, prima della correzione

Trentotto voci dicevano «lo scrive il motore». Andando a vedere dove il codice
le scrive davvero, e a quale pezzo di cartone corrisponde quel gesto:
**trentasette su trentotto avevano già una mano fisica**. La Funzione è stampata
sulla carta Echo; la Vita sulla scheda della casata; la leggenda la fa il
passaggio di Chronicle; i segni della cacciata li posa chi caccia. `engine` era
metadato vecchio, non una regola.

Il trentottesimo è un difetto vero, ed è aperto: [ISSUES 101](docs/ISSUES.md).

### Fatto

- **Via `MANO_INVISIBILE`**, via il ramo che la usava, via `engine` dall'elenco
  delle mani nello schema. Il confronto fra mani dichiarate e mani osservate non
  ha più eccezioni.
- **Via `_scritti_dal_codice()`**, la guardia scritta due giorni fa per D-333.
  Aveva un difetto suo: scandiva anche `sign_labels.gd` ed `effect_text.gd`, che
  sono tabelle di stampa, così a un segno bastava avere un'etichetta per
  risultare «scritto dal motore». Era lo stesso difetto che stava riparando.
- **Cinque penne nuove**, ognuna letta dal dato: la Funzione dall'Echo, la Vita
  dalla scheda, la leggenda dalla Chronicle, i segni della cacciata da chi
  toglie una presenza, il dominio dalla Tensione che lo porta stampato.
- Le stesse penne in `matrix_survey.py`, che ha un censimento suo — e lì dentro
  **c'era una seconda volta lo stesso `ruin.tag` di D-333**, un file più in là.
  Riparato.
- **Venti voci nuove nel dizionario**: dodici Funzioni degli Echo e otto Vite
  iniziali che il mondo scrive e il dizionario non conosceva.
- Il difetto piantato che sorvegliava `engine` è sostituito da uno che prova la
  regola nuova. La guardia resta a **28 difetti piantati**.

### Il costo, dichiarato

| | prima | dopo |
|---|---|---|
| segni nel dizionario | 184 | **204** |
| di cui qualcuno scrive | 149 | **200** |
| orfani in tutto | 59 | **92** |
| **di cui senza una ragione scritta** | 11 | **11** |

Novantadue orfani invece di cinquantanove: è lo stesso gioco, misurato senza la
scappatoia. La riga che conta — gli orfani senza una ragione scritta — resta a
undici.

### I cancelli

Diciannove cancelli verdi, suite 635 test in 97 suite (35.873 asserzioni),
playtest 100 semi: **0 seggi bloccati su un solo livello su 8**, tavolo misto e
uniforme. Nessuna riga di GDScript toccata.

---

## 0.1.296 — Una parola sola rendeva invisibili dieci Cicatrici (D-333)

### Trovato rispondendo a due domande

Il committente, guardando il grafo dei segni: *«ma cosa e' il motore, e come fa
una Pietra ad accendere una Regione?»*. Andando a verificare, **due segni che il
gioco posa davvero non erano nel dizionario**:

- **`uprooted`** — lo scrive il motore alla prima cacciata da un Consiglio
  (D-130), ha un segnalino e un'etichetta stampata. `twice_uprooted` era
  dichiarato: la seconda sradicata si', la prima no.
- **`scar:burned_records`** — la Cicatrice che l'Archivio lascia in rovina.

### Due buchi nella guardia, distinti

**`ruin.tag` contro `ruin.scar`.** Il validatore fisico leggeva `rovina["tag"]`;
le Pietre scrivono la Cicatrice sotto **`scar`**. Tutte e dieci. Per quella
parola la guardia era cieca a **ogni Cicatrice di rovina**, e non si e' mai vista
perche' nove su dieci le scrive anche una Conseguenza. L'unica che solo una
Pietra posa viveva fuori dal dizionario.

Riparata la riga, la guardia ha trovato subito **cinque Cicatrici il cui
`written_by` non dichiarava la Pietra**. Dichiarate.

**Un segno che scrive solo il codice.** `uprooted` non lo tocca nessun dato. Far
bastare `written_by: ["engine"]` sarebbe stato un cancello che si soddisfa da
solo, quindi la guardia **va a leggere il GDScript**: il codice conferma la
dichiarazione, non la sostituisce.

### Cancelli

Self-test da 26 a **28** difetti piantati: una Cicatrice di rovina fuori dal
dizionario, e una voce che dice «lo scrive il motore» e nel codice non c'e'.
Tutt'e due viste mordere.

### Costo, dichiarato

- Dizionario da **182 a 184** voci. `CATALOGO_PEDINE.md` da' finalmente una
  scheda intera a `scar:burned_records`, che prima era una riga nuda.
- **Nessun cambiamento di regole**: due dichiarazioni, cinque `written_by`
  completati, due righe di validatore.
- Resta che **117 dei 184 segni non sono cartone** ma contabilita' del motore, e
  il dizionario non li distingue. E' lavoro per ISSUES 98.

---

## 0.1.295 — Si scaldano tutte, e le regole guardavano dove il gioco non succede (D-332)

### Cambiato

- **Si scaldano tutte** (decisione del committente): ogni questione la cui faccia
  riconosce il gesto prende Calore, non piu' solo la piu' vicina alla soglia
  fra loro. Resta per ognuna la regola di D-257 — *la Risonanza avvicina, non
  decide* — che vieta di portare alla soglia una questione gia' a un passo.

### Corretto — un numero che avevo dato era sbagliato

Dicevo *«257 cadute su 381 usano la casella — il 67,5%»*. Quel contatore
misurava le cadute finite su una questione **che ha** una casella, non quelle che
la casella ha **scelto**. Il numero vero, preso spegnendo il ponte:

> **20 cadute su 383. La casella decide una volta su venti — il 5,2%.**

### Misurato — il controllo che il committente ha chiesto

Cosa fanno **davvero** le Azioni in 20 anni, contro cosa aspettano le 66 righe:

| le Azioni producono | volte | | le righe aspettano | righe |
|---|---|---|---|---|
| `SET_ENTITY_TAG` | 316 | | un cambio di controllo | **47** |
| `ADD_PRESENCE` | 175 | | un segno posato | 17 |
| `SET_RELATION` | 159 | | una Pietra costruita | 1 |
| `REMOVE_PRESENCE` | 58 | | una Presenza tolta | 1 |
| `SET_REGION_TAG` | **6** | | | |
| `SET_CONTROL` | **mai** | | | |
| `BUILD_STRUCTURE` | **mai** | | | |

**Quarantasette righe su sessantasei aspettano un gesto che il gioco non fa mai**,
e dei 17 segni guardati **zero sono di ambito Entita'** — mentre il segno sulla
casa e' la seconda cosa piu' frequente che un'Azione produce.

> Le regole non sono troppo strette: **guardano dalla parte opposta a dove il
> gioco succede.** Il pavimento derivato veniva da `focus_region_tags`, che dice
> di quali segni una questione **parla**, non quali gesti la **toccano**.

E quindi «si scaldano tutte» oggi quasi non si vede — su 100 semi e 1.849 gesti:
**1.844 ne svegliano una, 5 ne svegliano due, nessuno tre o piu'**. La modifica
resta perche' e' la promessa che la carta stampa, non perche' migliori qualcosa
adesso.

### Cancelli

- Quinta prova in `test_a_tension_says_what_wakes_it.gd`: due questioni che
  riconoscono lo stesso gesto **si scaldano tutte e due**. Serve a sapere che
  l'«uno fisso» della sonda e' il mondo e non la misura.
- La sonda della Risonanza porta la distribuzione per gesto, e l'etichetta del
  vecchio contatore adesso dice quello che il numero misura.

### Costo, dichiarato

| | prima | dopo |
|---|---|---|
| **seggi bloccati su 8** | **0** | **0** (misto e uniforme) |
| suite | 634 / 35.900 | **635 / 35.873** |
| Verita' scritte, misto / uniforme | 165 / 161 | **167 / 158** |

Rumore in tutte e due le direzioni.

### La deriva, la quarta volta — e stavolta un segno torna

I due soliti cancelli sono andati rossi, e la CI ha preso quello delle vite prima
che lo rigirassi io. Rigenerati:

| | prima | dopo |
|---|---|---|
| **trasformazioni sedute** (168 salti) | 202 | **199** |
| L'Egemonia di Eredan, uniforme | 9 | 7 |
| La Compagnia del Sale, uniforme / misto | 6 / 7 | **7 / 6** |
| la casa che muta piu' spesso | Aldric, 1 ogni 4,8 | Aldric, 1 ogni **4,9** |
| righe di `MISURA_SEGNI` che si muovono | — | **63** |
| **segni entrati nell'elenco** | — | **`amnesty_granted`** |

Le trasformazioni oscillano fra 195 e 202 a ogni tocco del Calore: e' rumore
attorno a un valore, non una direzione, e va letto cosi'. Il limite di
[ISSUES 83](ISSUES.md) — nessuna casa sotto un salto su quattro — tiene a 4,9.

**La cosa nuova e' `amnesty_granted`**, che rientra nell'elenco dei segni che il
mondo scrive: una volta in cento anni, e prima zero. Un Consiglio che prima non
si apriva adesso si apre, e concede un'amnistia. E' un segno solo, ed e' il
genere di cosa che nessuna misura di bilanciamento avrebbe mostrato — la vede
solo il documento che elenca **cosa il mondo scrive davvero**.

### Cosa resta, e adesso ha un ordine

1. Estendere la grammatica coi verbi veri: manca `adds_presence`.
2. Ri-mirare le 47 righe che aspettano un cambio di controllo.
3. Solo dopo, la scrittura a mano.

---

## 0.1.294 — La regola guarda il gesto, non il Tema della carta (D-331)

### Cambiato

- **Il filtro del Tema sparisce da `_tension_that_wakes`.** La casella «si
  accende quando» adesso guarda il **gesto**, non il registro in cui la carta
  risuona — che e' quello che la carta disegnata dal committente dice:
  *«questa Tensione riceve Calore quando **una carta** aggiunge #conteso...»*,
  senza nominare il Tema di chi gioca. Il filtro era una mia aggiunta, piu'
  restrittiva del disegno.
- **Il Tema resta sulla carta Azione**, e ci resta per il tavolo: 48
  dichiarazioni contro ~240 righe, e una riga da leggere in mano invece di sei
  Tensioni scoperte da scandagliare a ogni Azione.
- Il Calore **non aumenta**: fra tutte le questioni che riconoscono il gesto ne
  vince una sola, la piu' vicina alla soglia. L'insieme si allarga, il vincitore
  resta uno.

### Misurato — e la mia previsione era gonfiata di un ordine di grandezza

Sui dati fermi la modifica sembrava grossa: delle 40 carte che posano un segno,
**20** sono riconosciute anche da Tensioni di altri Temi, e **tre** —
`AST_FORCE_WARBAND`, `AST_PEOPLE_HARVEST_HANDS`, `AST_WEALTH_TOLL` — da
**nessuna** del loro Tema mentre lo sono da sei, due e cinque di altri.

Giocata:

| su 20 anni, seme 7000 | col filtro | senza |
|---|---|---|
| Risonanze | 772 | 775 |
| Calore su una questione con la casella | 257 su 381 | 259 su 383 |
| questioni diverse toccate | 48 su 60 | **49 su 60** |
| **Calore a un Tema diverso da quello della carta** | **0** per costruzione | **5 su 383 — l'1,3%** |

**Cinque cadute su trecentottantatre**, e non lo vendo per un miglioramento di
bilanciamento.

> **La lezione**: la misura statica contava le questioni che **possono**
> riconoscere un gesto; la partita premia quella che **vince**, e a parita' vince
> la piu' vicina alla soglia — quasi sempre una del Tema della carta. Contare le
> possibilita' invece degli esiti gonfia una previsione di dieci volte. E' la
> famiglia dello zero che non si crede: un numero plausibile misurato sul proxy
> sbagliato.

### Perche' resta

Nessuna delle tre ragioni e' «i numeri migliorano»: e' quello che la carta
disegnata dice; toglie un punto cieco strutturale (tre carte il cui gesto non
poteva **mai** raggiungere la questione che riguarda); e il codice ha un filtro
in meno.

### Cancelli

- La prova `test_the_printed_rule_chooses_the_question` e' ri-mirata sulla
  regola nuova — la gemella prende un **Tema diverso** da quello della carta — e
  si e' vista **andare rossa col filtro rimesso** e verde senza. Senza quel
  controllo sarebbe una prova che passa comunque.
- La sonda della Risonanza porta la riga *«...e di un Tema diverso dalla carta»*,
  che e' il metro di questa decisione.

### Costo, dichiarato

| | col filtro | senza |
|---|---|---|
| **seggi bloccati su 8** | **0** | **0** (misto e uniforme) |
| Consigli per anno, misto / uniforme | 3,41 / 3,46 | 3,41 / **3,45** |
| **Verita' scritte**, misto | 160 | **165** |
| di cui diverse, misto | 150 | **152** |

Cinque Verita' in piu' e due questioni in piu' fra quelle scritte: **e' rumore
fino a prova contraria**, e la prova contraria non ce l'ho. Non e' su questo che
la modifica si giustifica.

### La deriva, di nuovo, e i due cancelli l'hanno presa

Togliere il filtro sposta il mondo di poco ma davvero, e `MISURA_SEGNI` e
`MISURA_VITE` sono andati rossi tutti e due. Rigenerati:

| | col filtro | senza |
|---|---|---|
| righe di `MISURA_SEGNI` che si muovono | — | **66**, tutte di ±1-3 |
| segni entrati o usciti dall'elenco | — | **nessuno** |
| **trasformazioni sedute** (168 salti) | 198 | **202** |
| Nahr, ogni quanti salti muta | 1 ogni 10,5 | 1 ogni **8,8** |
| la casa che muta piu' spesso | Aldric, 1 ogni 4,8 | Aldric, 1 ogni **4,8** |

Quattro trasformazioni in piu' si siedono, e il Popolo Nahr — la casa che mutava
di meno — si avvicina alle altre. Il limite di [ISSUES 83](ISSUES.md), **nessuna
casa sotto un salto su quattro**, tiene invariato.

E' la terza volta in due decisioni che questi due cancelli prendono una deriva
che nessun altro avrebbe visto: il Calore che cambia strada cambia i Consigli,
i Consigli cambiano le Conseguenze, e le Conseguenze cambiano le porte su cui le
case cambiano pelle. **La catena e' lunga, e senza i due documenti generati
sarebbe invisibile.**

- Resta la scelta che **non** ho preso: se il Calore debba andare a **tutte** le
  questioni che riconoscono il gesto invece che a una sola. Moltiplicherebbe il
  volume, e il volume e' del committente — e' ISSUES 100, punto 4.

---

## 0.1.293 — SI ACCENDE QUANDO: la Tensione dice cosa la sveglia (D-330)

> ### ⚠️ Correzione (0.1.295): il «67,5%» era sbagliato
>
> Il numero *«257 cadute su 381 usano la casella»* misurava una cosa diversa da
> quella che diceva: contava le cadute finite su una questione **che ha** una
> casella, non quelle che la casella ha **scelto**. Il ponte poteva benissimo
> aver scelto lei.
>
> Il numero vero si prende spegnendo il ponte e contando le cadute che restano:
> **20 su 383 — il 5,2%**. La casella decide una volta su venti.
>
> La ragione sta nei verbi, ed e' in [D-332](#d-332): quarantasette righe su
> sessantasei aspettano un **cambio di controllo**, e le Azioni non ne producono
> **mai**; una aspetta una **Pietra costruita**, e nemmeno quella; i segni di
> Regione le Azioni li posano **6 volte in 20 anni**. Le regole erano scritte per
> gesti che il gioco quasi non fa.


### Aggiunto

- **`heats_when` sulla faccia della Tensione**: la casella che il committente ha
  disegnato sulla carta *I Recinti*. Quattro verbi chiusi — un segno posato o
  tolto, una Pietra costruita, un controllo cambiato, una Presenza tolta — piu'
  il filtro del luogo `on_region_with`, e un `text` che e' **la riga come si
  stampa**. La regola e il suo testo sono la stessa cosa.
- Il motore guarda gli Effetti che l'Azione ha **davvero prodotto** e manda il
  Calore alla questione che riconosce il gesto. Se nessuna lo riconosce torna il
  ponte di D-261, **come ripiego dichiarato**.

### Misurato — e il numero che mi aspettavo non si e' mosso

| su 20 anni, seme 7000 | col ponte | con la casella |
|---|---|---|
| Risonanze | 772 | 772 |
| **questioni diverse toccate** | **48 su 60** | **48 su 60** |

Immaginavo che il ponte concentrasse il Calore e la casella lo spargesse: non
era vero. Con dieci questioni per Tema, «la piu' vicina alla soglia» ruotava
gia' da sola.

**Quello che cambia e' un'altra cosa**, e vale il lavoro:

| | |
|---|---|
| Tensioni con la casella | **47 su 60** |
| cadute di Calore su una che la porta | **257 su 381 — il 67,5%** |

Due volte su tre il Calore va dove una **riga stampata** dice che deve andare, e
al tavolo lo si verifica guardando la mappa. Non e' bilanciamento: e'
leggibilita'.

### Contenuto

- **`TEN_ENCLOSURE` (I Recinti)** porta le quattro righe della carta disegnata,
  tradotte sui segni che la mappa ha davvero: `#campo`, `#villaggio` e `#pascolo`
  **non esistono** — le terre da coltivo si dicono `granary`, `nomad_range` e
  `domain:TERRITORY`.
- Le altre 46 hanno un **pavimento derivato** da quello che gia' dichiaravano in
  `focus_region_tags`. Non e' contenuto d'autore: e' la stessa cosa detta in un
  modo che il motore esegue e il tavolo legge, e si riscrive una carta alla
  volta. **13 Tensioni restano senza**, e per loro vale il ponte.

### Cancelli

- **Controllo 19** in `validate_physical.py`: una riga che nomina un segno fuori
  dal dizionario o una Pietra che non esiste non si accende mai; una riga senza
  nessun verbo e' lo stesso difetto in peggio, perche' al tavolo sembra una
  regola. Self-test da 23 a **26** difetti piantati.
- **`test_a_tension_says_what_wakes_it.gd`**, quattro prove. La seconda questione
  se la fabbrica: il banco ne porta una sola per Tema, e con una sola il ponte e
  la casella sceglierebbero la stessa — la prova sarebbe passata senza provare
  niente.

### Costo, dichiarato

| | prima | dopo |
|---|---|---|
| **seggi bloccati su 8** | **0** | **0** (misto e uniforme) |
| Consigli per anno, misto / uniforme | 3,41 / 3,46 | 3,41 / 3,46 |
| **Verita' scritte**, misto | 156 | **160** |
| di cui diverse, misto | 146 | **150** |
| Verita' scritte / diverse, uniforme | 157 / 133 | **160 / 137** |

Le Verita' salgono di quattro e la loro varieta' di quattro: piccolo, dentro il
rumore, e **nella direzione giusta** — il Calore che va sulla questione che il
gesto riguarda apre Consigli su cose che stanno succedendo davvero. Non lo
vendo per piu' di quello che e': i Consigli per anno non si muovono di un
decimo.

- Il `text` delle 46 righe derivate e' prosa meccanica, e si vede. E' un
  pavimento, non una faccia finita.
### La deriva del mondo, che un cancello ha preso

`run_marks_survey` e' andato **rosso**, e aveva ragione: mandando il Calore su
questioni diverse, il mondo apre Consigli diversi e **scrive segni leggermente
diversi**. Quarantacinque righe di `MISURA_SEGNI.md` si sono mosse, tutte di
poco:

| segno | prima | dopo |
|---|---|---|
| `condition:contested` | 522 | **524** |
| `condition:unrest` | 202 | **204** |
| `burden_shared` | 49 | **50** |
| `condition:abandoned` | 52 | **51** |
| `amnesty_granted` | 1 | **0 — non si scrive piu'** |

`amnesty_granted` e' l'unico che sparisce: si scriveva **una volta in cento
anni**, e adesso zero. Resta nel dizionario, e va guardato — un segno che il
mondo non produce mai e' una promessa falsa per chiunque lo tema (ISSUES 96,
strada 2). Non l'ho toccato qui: e' contenuto, e questa e' una modifica di
motore.

E **la stessa deriva arriva alle vite**, `MISURA_VITE.md`. Qui va nella
direzione buona:

| | prima | dopo |
|---|---|---|
| **trasformazioni sedute** (168 salti) | 195 | **198** |
| Vaerax Ridestato, uniforme / misto | 11 / 8 | **12 / 9** |
| L'Egemonia di Eredan, uniforme | 5 | **7** |
| la casa che muta piu' spesso | Aldric, 1 ogni 4,7 | Aldric, 1 ogni **4,8** |

Tre vite scritte in piu' si siedono davvero al tavolo, ed e' quello che ci si
aspetta: il Calore che va sulla questione giusta apre Consigli che producono i
segni sulle cui porte le case cambiano pelle. Il limite di casa di
[ISSUES 83](ISSUES.md) — **nessuna casa sotto un salto su quattro** — tiene, e
anzi respira: la peggiore passa da 4,7 a 4,8.

- Il ponte **non e' stato tolto**: con 13 Tensioni senza casella e 124 cadute su
  381 che non trovano una riga, toglierlo lascerebbe del Calore per terra.

---

## 0.1.292 — I nomi degli anni cancellati, e quattro strumenti che cercavano per cartella (D-329)

### Cambiato

- **Sette coppie di file di dati fuse in una ciascuna**, chiamate col contenuto
  invece che con l'anno d'autore che le aveva introdotte: `entities_core` (8
  case), `destinies_core` (17), `tensions_core` (12), `consequences_core` (52),
  `echo_cards_core` (39), `regions_core` (**tutte e dieci le tessere**) e
  `confluences/confluence_templates.json` (12). Le cartelle `chronicle_01/` e
  `chronicle_03/` non esistono piu'.
- **`items_of(schema_id)` in `tools/echoes_schema.py`**: un documento si cerca
  per quello che **dichiara di essere**, non per la cartella in cui sta. Quattro
  strumenti lo usano, e sono spariti venti riferimenti a percorsi.
- Due commenti di sonda che rimandavano ai `sim_plans` cancellati in 0.1.281.

### Trovato — quattro strumenti sbagliavano in silenzio

Il motore non si e' accorto della fusione (`data_set.gd` raccoglie ogni `.json`
e indicizza per id). **Gli strumenti si', e senza fallire:**

| strumento | cosa ha prodotto, spostati i template |
|---|---|
| `build_sign_registry.py` | **otto clausole impossibili** che non lo sono, e due segni «muti» che invece qualcuno legge |
| `components_survey.py` | **«Modelli di Consiglio: 0»**, soggetti da illustrare **146 → 0** |
| `matrix_survey.py` | segni scritti **149 → 102**, e **19 clausole impossibili** dal nulla |
| `build_review.py` | **670 righe di testi** sparite |

E' la stessa malattia di D-328, dove lo stesso strumento moriva all'avvio per lo
stesso motivo. **Uno strumento che nomina un file per percorso non fallisce
quando il file si sposta: smette di vederlo.**

### Corretto

- **`PUNTO_ZERO.md` diceva che il motore non esegue la scelta fra le due Azioni
  della carta.** Era vecchio di nove versioni: [D-283](docs/DECISIONS.md#d-283)
  l'ha implementata. Il conto vero: **85 Azioni stampate su 96** portano un verbo
  eseguibile, le altre 11 posano solo un segno e il motore le rifiuta.

### Cancelli

- `check_no_file_names_a_dead_chronicle` in `validate_data.py`: nessun file di
  dati puo' portare nel nome una Chronicle che non esiste. Il self-test passa da
  tre guardie a **quattro**, e la nuova si e' vista tacere su due nomi buoni e
  mordere su due che mentono — uno col difetto nel file, uno nella cartella.

### Costo, dichiarato

- **Nessuno sui numeri**, e stavolta e' provato invece che dedotto: i quattro
  documenti generati tornano **identici**, la suite fa **630 prove / 35.886
  asserzioni** verdi, e il playtest da' gli stessi numeri di prima — **0 seggi
  bloccati su 8** misto e uniforme, Consigli 3,41, Verita' 156 di cui 146
  diverse.
- Resta `sim_plan.schema.json` senza nessun piano: lo schema e il codice che lo
  legge restano, com'e' scritto in `DATA_SCHEMA.md`.

---

## 0.1.291 — Il primo documento da leggere era falso, e uno strumento non partiva (D-328)

### Cambiato

- **`docs/PUNTO_ZERO.md` riscritto sui numeri di oggi.** Era fermo a **0.1.220**,
  settanta versioni indietro: dava 512 prove (sono 630), l'82,8% di turni «passa»
  (il 47,3%), 8 Destini su 20 con faccia fisica (23 su 23), la Terra all'1,4% del
  Calore (7,1%). E' il documento che `CLAUDE.md` ordina di leggere per primo.
- **`README.md` riparato in cinque punti** dove nominava cose che non esistono:
  lo stato («Milestone 0.1 completata (0.1.18)»), la scelta fra `CHR_01` e
  `CHR_02`, i quattro `sim_plans` cancellati in 0.1.281, i fogli di stampa (**25
  → 42**) e sei collegamenti a documenti tolti.
- **`docs/RULES_V0_2.md` porta un'avvertenza in cima**: e' fermo a 0.1.38, resta
  perche' e' l'unico posto dove le regole sono scritte per esteso, e la nota dice
  quali quattro cose descrive in modo superato.

### Misurato — il giro completo dei cancelli

| | |
|---|---|
| suite | **630 prove / 96 suite / 35.886 asserzioni** verdi |
| il vincolo | **0 seggi bloccati su 8**, misto e uniforme |
| turni «passa» | **47,3%** (3.406 su 7.200), 47,0 / 47,6 / 47,4 per Atto |
| quanto rende giocare | **+183,1%** contro il tavolo di pietra |
| Risonanze | **3.762 in 100 anni**, il 25,7% aggravate |

**Il criterio 2 di PZ-01 e' soddisfatto, e nessun documento lo diceva**: *«meno
della meta' dei turni sono passa»*. Era l'82,8% quando la voce e' stata aperta.

E il difetto che resta ha cambiato forma: dei «passa» rimasti, l'**84,6%** e'
*«nessuna mossa gli serviva»*. Il mazzo e il bersaglio, che in 0.1.216 erano un
terzo del problema, sono un sesto. **Resta la ragione, sola.**

### Trovato — uno strumento rotto da dieci versioni, senza che niente diventasse rosso

- **`tools/build_review.py` moriva all'avvio dalla 0.1.281**: nominava a mano
  `chronicle_01/chronicle_01.json`, cancellato con gli anni d'autore (D-318).
  `docs/REVISIONE_TESTI.md` e' rimasto fermo settanta versioni **perche' nessun
  cancello lo guardava**.
- Riparato leggendo **a glob invece che a lista di nomi**, e cosi' raccoglie
  anche i tre file che la lista non nominava: **da 771 a 1.010 testi in lettura**.
- **`matrix_survey.py --check` era dichiarato in `CLAUDE.md` dalla 0.1.249 e non
  era in CI.** Se n'e' accorto solo il giro a mano.

### Tolto

**Diciassette documenti superati**, in tre gruppi:

| | |
|---|---|
| le cinque **sedute** (VITE, LEGGENDA, TAVOLO, TERRA, LINEE) | dossier di decisione, decisioni prese e a verbale |
| le tre **saghe** (812, NAHR, SALE) | raccontano Chronicle cancellate: i comandi che stampano non girano piu' |
| nove **istantanee** (ROADMAP, AUDIT_DESTINI, DIAGNOSI_PUNTO_ZERO, COMPONENTS, CONSEGNE, TEST_PLAN, TRASFORMAZIONI, MECCANICA, VISIONE) | fotografie fra la 0.1.0 e la 0.1.192, superate da documenti generati con un cancello |

Da **37 documenti a 20**: dieci generati e sorvegliati, sei vivi, quattro di
riferimento.

E **`tools/tag_census.py`**, su decisione del committente: non lo chiamava
nessuno, censiva 86 segni per deduzione dove il dizionario di D-259 ne dichiara
182, e il suo mestiere lo fanno tre strumenti che hanno un cancello
(`build_sign_registry`, `matrix_survey`, `run_marks_survey`).

### Cancelli

- **`build_review.py --check`** e **`matrix_survey.py --check`** aggiunti alla CI.
  Il primo si e' visto mordere su un difetto piantato.
- `CLAUDE.md` porta la riga del cancello nuovo; il passo «Play every sim plan»
  della CI ha smesso di chiamarsi cosi', visto che i piani non esistono.

### Costo, dichiarato

- **Nessuno sui numeri**: non e' stata toccata una riga di regole.
- Una decina di collegamenti nella storia di `CHANGELOG.md` e `DECISIONS.md`
  puntano a documenti tolti, e **restano appesi apposta**: sono verbali, e un
  verbale non si riscrive. In `ISSUES.md`, che e' un elenco vivo, i quattordici
  collegamenti sono sciolti in corsivo con una nota che spiega cosa vuol dire.
- **`godot/data/` porta ancora i nomi degli anni cancellati** — dodici file
  `*_chronicle_01`/`_03` con dentro il contenuto vivo. E' ISSUES 99, e vuole un
  commit suo.

---

## 0.1.290 — I Destini mirano a segni, e la mappa diventa contesa (D-327)

### Cambiato

- **Quarantuno righe su ventitre' Destini non nominano piu' una Regione**: dicono
  `any_tag`, la stessa forma del bersaglio a segni delle Azioni (D-273). Ogni
  riga porta due segni — quello del posto e il dominio che fa da pavimento —
  perche' con 10 tessere e 6 pescate **solo un segno su almeno 5 tessere e'
  garantito**, e `capital`, `granary`, `mine`, `trade`, `wild`, `nomad_range`
  stanno su una sola.
- Il motore legge `any_tag` su `region_presence` (una terra cosi' dove il conto
  torna), `state_tag_present`/`absent` (una / nessuna) e `scar_count` (contate su
  tutte). Schema aggiornato, `schema_defs.gd` rigenerato.
- **`DST_VAERAX_LEGEND` entra nel mazzetto di `ENT_VAERAX`**, che passa a cinque
  carte: non usciva mai in 400 seggi.
- Le facce fisiche riscritte: dove dicevano «Eredan», «le gallerie», «la
  montagna», adesso dicono il segno.

### Misurato

| | prima | dopo |
|---|---|---|
| righe che nascono morte | **43.1%** | **0%** |
| Regioni pescate che qualcuno nomina | 22.3% | **72.2%** |
| **coppie che si contendono una Regione** | **2.8%** | **15.5%** |
| clausole che qualcuno contendeva | 21.4% | **25.9%** |
| `region_presence` contese | 17 | **143** |

**La contesa sulla mappa passa da 2.8% a 15.5%**: e' il numero che non si muoveva
da tutta la giornata.

### Due misure cieche, trovate prima di crederci

Ri-mirate le clausole, **tutte e due le sonde sono andate a zero**: cercavano
`region_id` e non ne esisteva piu' uno. Quindicesima e sedicesima del progetto,
e le prime due trovate perche' **uno zero non si crede mai**. Dentro la seconda
ce n'era una terza: le `scar_count` senza `region_id` risultavano *globali* e
gonfiavano la lite delle Cicatrici al 29.0% — col conto giusto e' 26.2%.

### Cancelli

- `validate_physical.py` regola 17 estesa ai Destini: **nominare una Regione per
  nome non si puo' piu'**, e i segni devono stare su almeno N-K+1 tessere. Due
  difetti nuovi nel self-test, che adesso sono **ventitre'**.
- `tests/unit/test_a_clause_aims_by_signs.gd`, cinque prove, fra cui una che
  controlla che nessuna clausola spedita nomini una Regione. Provata al
  contrario: **ventuno fallimenti**.
- Aggiornate due prove che spegnevano una clausola sgomberando **una** Regione:
  adesso una riga a segni sopravvive a una mossa verso un'altra terra dello
  stesso genere, ed e' il comportamento giusto.

### Costo, dichiarato

- **0 seggi bloccati su 8**, misto e uniforme. Suite 630 test / 35886 asserzioni.
- Il misto e' piu' generoso in basso e piu' duro in cima: NONE **90 -> 85**,
  TRIUMPH **9 -> 6**. L'uniforme il contrario: NONE 69 -> **72**, VICTORY
  184 -> **173**.
- Verita' scritte, misto **162 -> 156**. Trasformazioni sedute **198 -> 195**.
- **Le clausole gia' vere all'apertura non si muovono** (53.1%): questa modifica
  rende le righe raggiungibili e contese, non conquistate. ISSUES 91 resta.

---

## 0.1.289 — La lotta per la mappa c'e'; sono le carte che guardano altrove (D-326)

### Aggiunto

- **`cli/run_map_probe.gd`**: la sonda che misura la frase mai misurata — *«una
  maggioranza dovrebbe essere una lotta fra entita'»*. Il motore da' la Regione
  alla presenza piu' forte, quindi la frase e' un numero solo: **di quanto vince
  chi vince**. Piu' le prese (a qualcuno o da terra), le clausole di Regione
  morte, e le Regioni che nessuno nomina.

### Misurato

- **Il 47.1% delle Regioni tenute si decide per una pedina o meno** (margine 0:
  15.7%, margine 1: 31.4%). Il tavolo **e' conteso**: era la mia ipotesi
  contraria, ed era sbagliata.
- **Ma il controllo si raccoglie, non si toglie**: 68.4% delle prese avviene
  dove non c'era nessuno, 26.6% a spese di un'altra casa.
- **Il 43.1% delle righe che nominano una Regione nomina una Regione che la
  mappa non ha pescato** — `REG_EREDAN` 62 volte, `REG_MINIERE_ANTICHE` 57.
  Clausole morte prima che si cominci.
- **Il 77.7% delle Regioni pescate non le nomina nessuno**: sei terre sul
  tavolo, in media 1.3 interessano a qualcuno.
- **`DST_VAERAX_LEGEND` non e' nel mazzetto di nessuna casa**: mai uscita in 400
  seggi. Ed e' la carta che D-325 ha modificato ieri — quella modifica non puo'
  vedersi in partita. Errore mio, scritto.
- Distribuzione dei Destini: **200 seggi su 400 pescano un Destino di casa, 200
  uno condiviso**; ma i sei condivisi si dividono 200 (media 33,
  `DST_SHARED_RENOWN` **51**) e i diciassette di casa gli altri 200 (media 12).

### Perche' le coppie che si contendono una Regione sono ferme al 2.8%

Perche' due Destini si incontrino su una terra, quella terra deve **essere stata
pescata** — e da D-265 la mappa si pesca sei su dieci. **E' l'ultimo pezzo di
D-265 rimasto indietro**: la mappa e' diventata pescata, i bersagli delle Azioni
sono stati ri-mirati a segni (D-273), le Tensioni parlano per #TAG — i Destini
no, continuano a nominare Regioni per nome.

### Corretto

- Guardando due soli semi avevo detto «le case quasi sempre pescano un Destino
  condiviso». Su cento partite **non e' vero**: e' meta' e meta'. Il fatto vero
  e' la concentrazione, non la prevalenza.

### Aperto

- **ISSUES 97**: se i Destini debbano smettere di nominare Regioni per nome e
  passare ai segni, come hanno gia' fatto Azioni e Tensioni.

---

## 0.1.288 — Otto clausole guardano quello che il mondo produce (D-325)

### Cambiato

- **Strada 1 di ISSUES 96**, scelta dal committente: qualcuno guarda i segni che
  il mondo scrive gia'. `condition:contested` (531 scritture per secolo, zero
  clausole) lo **vuole** `DST_NAHR` — dove nessuno ha messo il suo titolo un
  popolo senza terra puo' fermarsi — e lo **teme** `DST_ALDRIC`.
  `condition:cut_off` lo vuole `DST_VAERAX`, lo teme `DST_SALE`.
  `rumour_running` lo vuole `DST_VAERAX_LEGEND`, lo teme `DST_VETRO`.
  `order_restored` lo vuole `DST_ALDRIC_RECORD`.
- **E la coppia sulle carte condivise**: `DST_SHARED_QUIET` teme la terra
  contesa, `DST_SHARED_HAND` la vuole.
- **Una clausola ri-mirata**: `DST_VAERAX_LEGEND` chiedeva
  `legend:crystal_exploited`, mai scritto in cento partite. Riscritta sullo
  stesso soggetto della carta — la voce che corre.
- **Un segno cancellato**: `legend:crystal_exploited` non lo tocca piu' nessuno.
  Dizionario **183 -> 182 segni**. L'ha preteso il validatore.

### Misurato

- **Coppie che si contendono una memoria: 4.5% -> 7.0%** (27 -> 42).
- `state_tag_present` contese **4 -> 18**; clausole contese 490 -> 503.
- **Clausole gia' vere all'apertura 54.0% -> 53.1%.**
- Segni scritti spesso che nessuno guarda: **25 -> 21**.

### La lezione, e vale piu' delle otto clausole

Le prime **sei** righe, tutte su carte di case, sono atterrate **senza
incontrarsi**: contese 4 -> 5. Una lite scritta fra due carte di due case
precise quasi non capita a un tavolo pescato — servono che le due case siedano
insieme *e* che ognuna abbia pescato proprio quella faccia. Aggiunta la coppia
sulle **carte condivise**, che le pesca chiunque, il numero e' saltato a 18.
**Le carte condivise sono dove vive la lite.**

### Costo, dichiarato

- Il gioco e' appena piu' facile alla Vittoria e piu' duro al Trionfo: uniforme
  VICTORY 181 -> **184**, TRIUMPH 14 -> **11**.
- **Verita' diverse in meno**: uniforme 139 -> **133**, misto 150 -> 148.
- `docs/MISURA_VITE.md`: trasformazioni sedute 194 -> 198.
- Cancello vincolante: **0 seggi bloccati su 8**, misto e uniforme. Sedici
  cancelli verdi, 625 test / 35634 asserzioni.

### Resta aperto

- `condition:contested` e' ancora scritto 538 volte per secolo contro quattro
  righe che lo nominano, e **ventuno segni** restano senza nessuno che li
  guardi: in testa la famiglia `discovery:*` e `heir_named`. ISSUES 96 resta
  aperta.

---

## 0.1.287 — Il segno piu' scritto del gioco non lo guarda nessuno (D-324)

### Aggiunto

- **`cli/run_world_marks_probe.gd`**, la misura girata dalla parte giusta: non
  «quanti dei segni che i Destini nominano il mondo li scrive», ma **quali segni
  il mondo scrive, e se se ne accorge qualcuno**. Per ogni segno che al tavolo si
  posa (MEMORY e STATE; fuori la contabilita' del motore): quante volte la
  partita lo **scrive**, quante clausole lo **temono**, quante lo **vogliono**.
- **`docs/MISURA_SEGNI.md`** e il cancello `tools/run_marks_survey.sh --check`,
  sedicesimo della batteria, in CI accanto agli altri. Provato col difetto
  piantato: **esce 1**.

### Misurato

- **`condition:contested` e' scritto 531 volte in cento anni — cinque volte
  l'anno — e nessuna clausola in tutta la scatola lo nomina.** E' il segno piu'
  scritto del gioco.
- **Venticinque segni** superano le dieci scritture per secolo con zero clausole
  addosso: `discovery:the_omen` 455, `discovery:the_ledger` 335,
  `knowledge_shared` 147, `condition:cut_off` 98, `order_restored` 87,
  `heir_named` 73...
- Dall'altra parte, **cinque segni guardati e mai scritti** in cento partite:
  `study_supervised`, `valley_sealed`, `water_priced`,
  `legend:crystal_exploited`, `mountain_forgotten`.

### Cosa cambia nella diagnosi

Il problema di `state_tag_absent` sembrava di **quantita'** — troppe clausole
gia' vere. E' di **incontro**: il mondo produce una cosa, le carte ne guardano
un'altra, e le due liste quasi non si toccano. Aperta **ISSUES 96**.

### Aperto

- Da D-323 un Consiglio caduto lascia una terra contesa cinque volte l'anno, e
  **a nessuno conviene farla cadere**: una casa che campa sul confine irrisolto
  renderebbe il fallimento una mossa invece che un incidente. Decide il
  committente: sono carte stampate.

---

## 0.1.286 — Una domanda caduta lascia il segno che quella domanda lascia (D-323)

### Aggiunto

- **Il pool `failure` della scheda del Consiglio adesso si legge** (strada 2 di ISSUES 95,
  scelta dal committente). Sul FAILURE scatta **una
  riga sola**, come per il prezzo (D-267). Nel motore e' un `elif` in
  `confluence_controller.gd`.
- **Ogni scheda cade a modo suo**: SURVIVAL lascia un luogo abbandonato,
  TERRITORY un luogo conteso, ANCIENT una voce che corre, RESOURCE una strada
  chiusa; e le otto carte con scheda propria cadono ognuna nel modo della sua
  domanda — la successione in *Nessuno Decide*, la Carta *sul Muro*, il debito
  nel *Patto Rotto*, la reliquia in *Qualcuno Si Serve*.
- `tests/unit/test_a_fallen_question_leaves_a_mark.gd`, tre prove, con la riga
  che le tiene oneste (`assert_true(fallen > 0)`) perche' una prova che cerca
  una condizione fra i dati puo' smettere di provare in silenzio. Provate al
  contrario spegnendo l'`elif`: **sei fallimenti**.

### Misurato

- **Conseguenze irraggiungibili 17 -> 9**, con la regola stretta di cosa il
  motore legge davvero. Otto tornate vive, tutte della famiglia del fallimento.
- **Cancello vincolante: 0 seggi bloccati su 8**, misto e uniforme.

### Costo, dichiarato

- **Il tavolo misto e' piu' duro**: VICTORY **173 -> 164**, NONE **86 -> 91**,
  verita' diverse **154 -> 150**. E' quello che la modifica fa: il mondo si
  sporca quando il tavolo non decide, e un mondo sporco e' piu' duro da
  raddrizzare.
- Il tavolo uniforme quasi non lo sente (VICTORY 180 -> 181, TRIUMPH 15 -> 14) e
  scrive **sei verita' diverse in piu'** (133 -> 139).
- `docs/MISURA_VITE.md`: trasformazioni sedute **198 -> 194**.
- **Restano nove Conseguenze orfane.** Le sei del prezzo sono superate da D-280
  — la moneta sta sulla carta — e andrebbero cancellate: coda in ISSUES 95.

### Non ha funzionato

- **Le memorie temute non si muovono: 76.6% prima, 76.6% dopo.** Clausole gia'
  vere all'apertura 54.3% -> 54.0%. La strada 2 sporca il mondo ma **non rende
  `state_tag_absent` contendibile**, che era la ragione per cui era stata
  consigliata. Il perche' e' preciso: **i segni che un fallimento lascia non
  sono i segni che i Destini temono** — un Consiglio caduto scrive
  `condition:abandoned`, `condition:contested`, `condition:cut_off`, e nessuno
  di questi compare in una clausola `state_tag_absent`. Il blocco sta un passo
  piu' in la': in cosa i Destini scelgono di temere. Torna a ISSUES 91.

### Corretto

- D-322 diceva «13 Conseguenze irraggiungibili» contando come raggiungibile il
  pool `cost`, che il motore non legge — cioe' proprio la cosa che D-322 aveva
  scoperto. Col conto giusto erano **17**.

---

## 0.1.285 — Tredici esiti di Consiglio che la scatola non puo' pescare (D-322)

### Misurato

- **64 Conseguenze scritte, 13 che nessun Consiglio puo' pescare.** Le proposte
  delle 60 carte Tensione ne raggiungono 46, i pool dei 12 template altre 6.
  Undici delle tredici orfane sono **i prezzi e i fallimenti**:
  `CNS_COST_COLD_WORD`, `CNS_COST_EMPTIED`, `CNS_COST_EXPLOITED`,
  `CNS_COST_MOURNING`, `CNS_COST_RATION`, e i sei `CNS_FAILURE_*`.
- **I pool `cost` e `failure` dei template non li legge nessuno**: nel motore
  gli esiti vengono da `success_consequences` della proposta piu', sul decisivo,
  `decisive_bonus`. E' un residuo coerente con due decisioni gia' prese — il
  prezzo e' passato sulla carta (D-267/D-280), il segno della domanda caduta lo
  scrive il motore (D-278) — a cui nessuno ha fatto seguire la pulizia.
- **Un Consiglio che fallisce non lascia niente al mondo** tranne
  `question_unresolved`. Sul tavolo misto cade **una proposta su quattro**
  (90 FAIL su 347); sull'uniforme una su venti (17 su 355).
- Tutti e diciassette i segni temuti **hanno** almeno una strada che li scrive:
  il problema di `state_tag_absent` non e' l'impossibilita', e' l'improbabilita'.

### Corretto in corsa

- **Quattordicesima misura cieca.** Il primo censimento dava «cinque segni
  temuti irraggiungibili»: cercava il segno su `tag`, mentre le Conseguenze lo
  scrivono dentro `payload`. Rifatto, gli irraggiungibili sono **zero**. Anche
  «5 Conseguenze raggiungibili su 64» era dello stesso errore: guardava i pool
  dei template e non le proposte delle carte.

### Provato e ritirato

- Assegnare a ogni dominio il suo prezzo e il suo fallimento (SURVIVAL in
  razioni e lutti, TERRITORY in terre svuotate, ANCIENT in voci che corrono,
  RESOURCE in strade chiuse) passa tutti i validatori e **non cambia un singolo
  esito**: i pool restano non letti. Ritirato invece che committato inerte.

### Aperto

- **ISSUES 95**: o si cancellano le tredici carte morte, o il fallimento
  riprende una faccia. E' contenuto stampato: decide il committente.

---

## 0.1.284 — Sette clausole vogliono il segno, e la lite si quadruplica (D-321)

### Cambiato

- **Quattro carte scrivono il verso opposto** (strada 1 di ISSUES 94, scelta dal
  committente). `DST_LIBERE` e due clausole di `DST_CENERE_DEEP` girate da
  «l'anno e' finito pulito» a «l'anno ha lasciato segni»; `DST_VETRO_SHOWN` e
  `DST_SHARED_LAND` ne ricevono una nuova. Non a caso: su tutte e quattro la
  carta gia' si contraddiceva — una Carta strappata a un anno tranquillo, chi
  scende in due nelle gallerie e le lascia intatte, una teca aperta che non
  lascia traccia, tre Regioni prese in silenzio. Da **2 clausole su 24** a
  **7 su 26**.
- Le facce fisiche (`physical.reads.triumph`) delle quattro carte riscritte per
  dire quello che la clausola chiede adesso.

### Misurato

- **La Cicatrice diventa la lite del gioco**: coppie che se la contendono
  **5.7% -> 25.0%**. Regione e memoria non si muovono (2.8% e 4.5%).
- **Clausole che qualcuno contendeva: 14.6% -> 21.4%.** Fra le sole
  `scar_count`, da **38 contese su 393 a 189 su 393** — una su due.
- Clausole gia' vere all'apertura **55.5% -> 54.3%**.

### Costo, dichiarato

- **Il tavolo uniforme scrive quattro verita' in meno** (160 -> 156, e 137 -> 133
  diverse). Il misto ne scrive una in piu' (162 -> 163).
- I livelli dei Destini non si muovono: misto NONE 84 -> 86, TRIUMPH 8 -> 9;
  uniforme NONE 69 -> 69, TRIUMPH 15 -> 15. **Gli stessi punti si prendono,
  ma adesso qualcuno puo' impedirlo.**
- **`scar_count` resta gia' vero all'apertura nel 92.1%** dei casi (da 99.5%):
  girare il verso ha reso le clausole contese, non conquistate. Il fondo di
  ISSUES 91 e' scalfito, non chiuso.
- Cancello vincolante: **0 seggi bloccati su 8**, tavolo misto e uniforme.
  Suite 622 test / 35551 asserzioni, quindici cancelli verdi.

### Corretto

- **I conteggi assoluti di D-320 e ISSUES 94 non si riproducevano** col comando
  che citavano: venivano da una corsa di una quarantina d'anni, non di cento.
  Non «145 clausole centrate, 143 gia' vere, 7.1% delle coppie» ma **393, 391 e
  5.7%**. La proporzione era giusta (98.6% -> 99.5%), i numeri no.

---

## 0.1.283 — Le Cicatrici hanno due versi, e la sonda ne vedeva uno solo (D-320)

### Misurato

- **I numeri di ISSUES 91 erano di un'altra partita.** Erano stati presi su
  CHR_01, cancellata da D-319. Rifatti sul gioco vero: clausole gia' vere
  all'apertura **52.4% -> 55.3%**, contese **15.8% -> 14.2%**, memorie temute
  mai toccate **66.5% -> 76.8%**. Il gioco della scatola e' **piu' regalato**
  di quello che stavamo misurando.
- **Tredicesima misura cieca.** `scar_count` risultava 145 clausole contese
  zero volte, e sembrava il bersaglio ovvio. Ma il test di contesa aveva
  quattro rami e `scar_count` **cadeva fuori da tutti**: zero per costruzione,
  non per misura. Nei dati la lite c'era — `DST_LYRA` vuole le Miniere pulite,
  `DST_VAERAX` le vuole segnate.
- **La Cicatrice e' la lite piu' scritta del gioco**, adesso che si guarda:
  **7.1%** delle coppie, contro il 6.2% della memoria e il 2.9% della Regione.
  Clausole contese in tutto: **14.2% -> 15.6%**.
- **E resta il blocco piu' grosso**: contese 13 su 145, e **143 su 145 sono
  gia' vere all'apertura — il 98.6%**. Il censimento spiega perche': delle
  ventiquattro clausole scritte, **ventidue chiedono che l'anno finisca
  pulito** e due sole che lasci il segno. La quiete e' un bene comune: la
  vogliono tutti e non costa a nessuno.
- Con `state_tag_absent` (187 gia' vere) fanno **330 clausole su 924 — il
  35.7% di tutti i punti — che sono «una cosa non e' successa»**.

### Non cambiato

- Nessuna regola, nessun dato. Rimettere un prezzo alla quiete significa
  toccare ventiquattro clausole stampate: la scelta e' del committente
  ([ISSUES 94](docs/ISSUES.md)).

---

## 0.1.282 — Due strumenti giravano ancora sugli anni cancellati (D-319)

La CI ha preso quello che i quattordici cancelli non guardano: due passi suoi
che nella lista di casa non ci sono.

### Corretto

- **`tools/run_sims.sh` cercava i `sim_plans`** — *«Piano non trovato:
  res://data/chronicle_01/sim_plans/*.json»*. Riscritto su **anni pescati**:
  quattro semi di CHR_00, verbale e salvataggio per ciascuno. Cosi' sopravvive
  la verifica che stava sopra — **stesso seme, salvataggio identico byte per
  byte** (§18.3) — che e' un passo di CI e non un cancello di casa. Provata:
  quattro salvataggi su quattro identici fra due esecuzioni.
- **`run_chronicle_sim.gd` sa girare senza piano**: `--chronicle` e `--seed` al
  posto di `--plan`, coi seggi che quel seme pesca e che giocano da soli. Il
  modo con piano resta, e non ha piu' piani da leggere.
- **Sette sonde e il cancello delle vite incatenavano ancora a `CHR_02`.** La
  spazzata di 0.1.281 aveva sostituito `CHR_01` e `CHR_03` e **non** `CHR_02`:
  `--then=CHR_02` faceva fallire il `setup()` della seconda era, e la sonda
  proseguiva su una sessione morta — *«Nonexistent function 'run' in base
  Nil»*, dodici volte per esecuzione.
- **E `docs/MISURA_VITE.md` era stato rigenerato da quel giro rotto.** Il
  cancello diceva «allineato» perche' confrontava il documento con l'output
  che l'errore produceva: allineato al guasto. Rigenerato pulito, 23 righe
  cambiate.

### La lezione, che e' la stessa di prima

Il `--check` di un documento generato dice che **il documento combacia con
quello che lo strumento produce adesso**, non che lo strumento funzioni. Se lo
strumento va in errore a meta' e stampa comunque, il cancello e' verde e la
misura e' finta. Vale il grep su `SCRIPT ERROR` anche qui, non solo sulla
suite.

---

## 0.1.281 — Gli anni d'autore sono cancellati (D-319)

### Tolto

- **`CHR_01` (La Carestia Rossa), `CHR_02`, `CHR_03` (Le Citta' Libere),
  `CHR_04`**, e i quattro `sim_plans` che sceneggiavano la Carestia mossa per
  mossa. Nella scatola resta **una Chronicle**: la Prima, che pesca mappa,
  case e questioni, e prosegue se stessa.
- Non si e' persa una carta: le 10 Regioni, le 8 case, i 23 Destini, le 60
  Tensioni, gli Echi e i 12 template di Consiglio restano — quegli anni li
  **usavano**, non li possedevano.

### Aggiunto

- **`tests/fixtures/chronicle_test.json` e `tests/test_table.gd`**: `CHR_TEST`
  e `CHR_TEST_HEIR`, il **banco** e non il gioco. Stanno sotto `tests/` e non
  finiscono nella scatola. E' la regola di casa applicata alla suite: *una
  prova che cerca una condizione fra i dati spediti puo' smettere di provare
  senza dirlo — fabbricatela.*
- **`shipped_data()`** accanto a `data()`: chi prova il motore usa il banco,
  chi **censisce la scatola** usa i dati spediti. Senza, una prova che conta le
  saghe contava anche il banco e dichiarava una scatola piu' ricca del vero.

### Riscritto

- **`test_chronicle_run`** girava i `sim_plans`, e una sequenza di mosse
  scritta per una mappa fissa non si ripunta su una mappa pescata. Riscritto su
  anni pescati con le stesse domande — un anno arriva in fondo, un Consiglio
  dice cosa ha applicato, il mondo scrive Echi e Verita' — piu' una che i piani
  non potevano fare: **semi diversi finiscono diversi**.
- **`test_the_menu_never_offers_a_sequel`** sarebbe passato **per assenza**:
  senza anni incatenati non c'e' piu' un seguito da non offrire. Adesso la
  coppia se la fabbrica, e controlla anche il caso che deve dare non-vuoto.
- **`test_the_three_survive_the_handover`**: l'era dopo e' la stessa Chronicle
  con un seme nuovo.

### Corretto

- Tre punti dell'app aprivano ancora `CHR_01` di default
  (`game_screen.first_chronicle()`, `help_panel.render()`, `dev_split`): con la
  Carestia cancellata avrebbero aperto il vuoto.
- Cinquanta sonde in `cli/` avevano `CHR_01` o `CHR_03` come predefinita.

### Misurato

| | prima | dopo |
|---|---|---|
| Chronicle nella scatola | 5 | **1** |
| Tensioni che la Chronicle vede | 12 | **60** |
| test | 627 | 622 |
| fallimenti spostando la suite | **217** | **0** |

### E tre prove morte a meta', prese dalla CI

Il runner locale conta i test che ha **fatto partire**, non quelli arrivati in
fondo: una prova che sbatte su una chiave che non c'e' si interrompe, scrive
una riga di log, e la suite dice verde. La CI legge quel log, e ha preso tre
casi che il verde locale nascondeva:

- **`test_chronicle_run`, la prova che avevo appena riscritto**, leggeva
  `log.entries` invece di `log.lines`. Si interrompeva prima di contare i
  Consigli risolti: verde, e non provava niente. Sedici asserzioni tornate a
  girare.
- `test_library_balance` incatenava ancora `CHR_03` -> `CHR_04`.
- `test_library_content` cercava `CHR_TEST_HEIR` nei dati **spediti**, dove il
  banco non c'e'.

**35520 -> 35551 asserzioni**: trentuno che non giravano. La lezione e' quella
gia' scritta in CLAUDE.md, e vale anche per chi la scrive: il verde della suite
non basta, si legge il log. Il cancello e' `.github/workflows/validate.yml`, e
gira anche in locale.

---

## 0.1.280 — Cento anni pescati: il cancello misura il gioco che si vende (D-318)

### Cambiato

- **`run_playtest.gd` gira su CHR_00**, cento semi, cento anni pescati. Girava
  meta' su CHR_01 e meta' su CHR_03: due anni d'autore con quattro e cinque
  Tensioni fisse, dove **48 delle 60 carte Tensione non arrivavano mai al
  tavolo**. Adesso ne restano fuori **3**.

### Misurato

- **Il vincolo regge sul gioco vero**: `--runs=100 --seed=7000`, **0 seggi
  bloccati su 8**, misto e uniforme. Non era scontato: nessuno l'aveva mai
  fatto girare.
- **E costa, e si scrive.** Il gioco pescato e' piu' duro e piu' asciutto:

  | su 100 partite | anni d'autore | anni pescati |
  |---|---|---|
  | NONE | 190 | **237** |
  | MINIMUM | 428 | 407 |
  | VICTORY | 551 | 525 |
  | TRIUMPH | 31 | 31 |
  | Consigli per anno (misto) | 3.85 | **3.47** |
  | Verita' scritte (misto) | 221 | **162** |

  Quarantasette seggi in piu' escono a mani vuote, mezzo Consiglio in meno per
  anno, un quinto di Verita' in meno. Non e' un peggioramento da correggere di
  corsa: e' il numero vero, guardato per la prima volta.

### Non fatto, e misurato perche'

- La cancellazione degli anni d'autore (CHR_01, CHR_02, CHR_03, CHR_04) chiesta
  dal committente: puntando `tests/test_case.gd` su CHR_00 la suite va a **217
  fallimenti su 42 suite**. La suite unitaria e' costruita sull'anno d'autore —
  nomina `TEN_FAMINE`, `REG_EREDAN`, «La Carestia Rossa», e ventisei prove
  cadono perche' un hook di Eco non compila quando la Regione che nomina non e'
  stata pescata. E' lavoro suo, con le prove da rifare
  ([ISSUES 93](docs/ISSUES.md)).

---

## 0.1.279 — Il cancello misura un anno d'autore, non la scatola (D-317)

### Misurato

- **La diagnosi di ISSUES 92 era sbagliata**, e tre verifiche la smontano:
  `P_EXPLOIT` e' **offerta 3 volte e scelta 3** (`run_choice_probe.gd`, che
  esisteva gia'); `TEN_AWAKENING` ha media **5.90** su soglia 6, picco 33, e
  **116 spinte in su contro 7 in giu'** — la Tensione meno frenata del gioco;
  `Q_AWAKENING_CRYSTAL` ha `eligibility: []`, sempre eleggibile. E il suo
  Consiglio si apre **zero volte su 40 partite**.
- **Il blocco e' a monte:** quella Tensione non e' quasi mai sul tavolo.
  `deal_theme_decks()` riempie i sei mazzetti dalle sessanta carte **solo se la
  Chronicle ha un `region_pool`**; senza, il mazzetto contiene solo le Tensioni
  gia' in gioco. Il `region_pool` ce l'ha **CHR_00 e basta**.
- **Il confronto**, 20 partite a tavolo misto:

  | | CHR_01 (anno d'autore) | CHR_00 (mappa pescata) |
  |---|---|---|
  | Tensioni sul tavolo, per partita | **4.0** | **8.8** |
  | distinte in 20 partite | **12** | **57** |
  | mai viste, su 60 | **48** | **3** |
  | che tengono un Consiglio | 12 | **28** |

- **La scatola funziona**: con la mappa pescata, 57 carte Tensione su 60
  arrivano al tavolo e 28 tengono il loro Consiglio. D-261, D-264 e D-265 si
  vedono giocare.
- **Ma il cancello dei 100 semi gira su CHR_01 e CHR_03**, tutti e due anni
  d'autore. Ogni numero di bilanciamento a verbale in questo progetto e' stato
  misurato su una partita con **quattro** Tensioni, non con sessanta.

### Aggiunto

- `cli/run_tension_reach_probe.gd`: quante delle sessanta Tensioni scritte
  arrivano al tavolo, dove arrivano contro la loro soglia, e quante tengono
  davvero un Consiglio.

### Non cambiato

- Nessuna regola, nessun dato, nessun cancello. Quale gioco misurare e' una
  scelta del committente ([ISSUES 92](docs/ISSUES.md), riscritta).

---

## 0.1.278 — Una casa spenta non segna, e adesso lo dice una regola sola (D-316)

### Cambiato

- **La regola sta in un posto solo.** `entity_alive` stava nel Minimo di
  **17 Destini su 23**, sempre riferita a se' stessi. Adesso il cancello e' in
  `destiny_evaluator.evaluate()`: casa spenta, livello NONE, i tre gradini
  falsi, e il verbale dice perche'. Vale per **tutti e ventitre'**, non per
  diciassette — sei Destini (`DST_CENERE`, `DST_VAERAX_WATCHED` fra questi) il
  cancello non ce l'avevano affatto.
- **Diciassette righe stampate riscritte.** Il Minimo di Aldric diceva *«Sei
  ancora sul trono e hai una presenza sulla capitale»*; adesso dice *«Hai una
  presenza sulla capitale»*. Mezza riga della carta era spesa a dire «non sei
  morto», che al tavolo non e' un obiettivo ma il presupposto per averne uno.
- **Sei Minimi scritti da zero**, perche' senza la clausola restavano vuoti — e
  un livello vuoto si avvera da solo, cioe' un regalo piu' grosso di quello
  tolto. Ognuno e' il passo piu' piccolo della stessa ambizione: una pietra
  piantata per i Nahr radicati, una Scoperta per la scuola di Lyra, una terra
  che risponde alla Gilda, un'opera alzata per le Citta' Libere, una terra che
  risponde al tuo nome, due questioni tenute sotto il punto di rottura.
- Riscritte anche le sei **etichette di livello**: «La Gilda esiste ancora» su
  un livello che adesso chiede una terra e' una frase d'autore che contraddice
  la carta (D-305).

### Misurato

- **Il punteggio non si muove.** 100 semi, prima -> dopo: NONE 191 -> 190,
  MINIMUM 426 -> 428, VICTORY 550 -> 551, TRIUMPH 33 -> 31. La clausola era
  sempre vera per i vivi e i morti cadevano gia' sul Minimo cumulativo.
- **Quello che si muove e' la dotazione.** 40 tavoli CHR_01, contro il
  baseline di D-314: clausole gia' vere all'apertura **60.5% -> 57.8% ->
  52.4%**, clausole contese **10.2% -> 11.8% -> 15.8%**. Otto punti in meno di
  dotazione e cinque e mezzo in piu' di contesa, in due tagli.

### Corretto

- `docs/ASSET_MANIFEST.md` non era stato rigenerato dopo la riscrittura delle
  sei etichette di livello: i cancelli erano stati passati **prima** di
  quell'ultima modifica, non dopo, e la CI l'ha preso. La batteria va
  ripassata **intera** dopo l'ultima riga toccata, non a pezzi.

### Aggiunto

- Cinque prove, due delle quali sono guardie contro la cecita': il caso che
  deve dare **non-NONE**, e la prova che **nessun livello e' rimasto vuoto**.
  Una terza gira su **ogni** Destino la cui casa siede al tavolo invece che su
  una lista scritta a mano — la prima versione nominava `DST_CENERE`, che a
  quel tavolo non c'e', e si era gia' ridotta a provare la meta'.

---

## 0.1.277 — Il mondo prende un rovescio, e la prima carta lo prende sul serio (D-315)

### Aggiunto

- **`$any` e `$rival` sulle Regioni**, nelle clausole a segni. Un obiettivo del
  pool si pesca a qualunque tavolo e la mappa si pesca (D-265): nominare una
  Regione lo renderebbe muto meta' delle volte. Il risultato era che **nessun
  obiettivo del mazzo poteva chiedere un segno di Regione**. `$rival` guarda
  solo le terre che tiene un altro — ne' le proprie, ne' quelle di nessuno.
- **`OBJ_THE_USEFUL_RUIN`**, *«una terra altrui e' stata spolpata o svuotata»*.
  Si avvera nel **34.2%** dei seggi, in banda col mazzo.
- Quattro prove sul selettore, fra cui il caso che deve dare **falso** (mappa
  pulita) e quello che distingue le due forme (segno in casa propria).
- Un quarto caso piantato nel `--self-test` del validatore: l'esenzione nuova
  deve **tacere** su `$any`/`$rival` e **mordere** su `REG_EREDAN`, anche
  annidato dentro un `any_of`.

### Misurato

- **Una sonda che legge il registro degli Effetti Regione per Regione**: la
  memoria temuta e' comparsa li' dove la clausola la temeva, oppure no.
  Baseline: **63.3% delle memorie temute non le tocca mai nessuno.**
- **La lettura statica sbagliava su due voci.** `question_unresolved` (61
  scritture) e `condition:unrest` (17) sono le due memorie piu' temute **e** le
  due piu' scritte: le scrivono carte e Conseguenze di rimbalzo, senza che
  nessun Destino le voglia.
- **Undici segni mai scritti una volta in 40 partite**, fra cui `mine_sealed`,
  che e' temuto 3 volte **e voluto 3 volte**. Il padrino c'era gia' e non
  bastava: le Conseguenze che li scrivono stanno in proposte che nessuno
  propone.
- **Dodicesima misura cieca**: l'attribuzione per `source.id` dava zero su
  tutte e diciotto le Conseguenze. Gli Effetti si firmano col template del
  Consiglio (`CNF_WATER_03#1`), mai col `CNS_*` — zero firme `CNS_` su 84.

### Tolto prima di spedire

- **Due obiettivi su tre.** `OBJ_THE_WALL_THAT_HOLDS` (6.7%) e
  `OBJ_THE_BROKEN_WORD` (3.3%): la sonda li ha chiamati **arredo**. Un
  obiettivo che non si avvera assomiglia a un obiettivo difficile, ed e' il
  difetto contro cui esiste la regola del pool.

### Costato

- 40 tavoli CHR_01: coppie che si contendono una memoria **1.2% -> 6.2%**,
  clausole contese **10.2% -> 11.8%**, gia' vere all'apertura
  **60.5% -> 57.8%**. Ma le memorie temute mai toccate **63.3% -> 66.5%**:
  **peggiora**, e si scrive. La lite e' scritta piu' spesso; il mondo non
  produce ancora i segni che qualcuno teme.
- Il muro non e' nelle carte: **propone solo il proponente**, e chi porta
  l'obiettivo raramente e' lui al Consiglio giusto ([ISSUES 92](docs/ISSUES.md)).
- Le case cambiano pelle piu' spesso: `ENT_NAHR` 35 -> 42 mutazioni in dodici
  saghe, `ENT_ALDRIC` 22 -> 27. `docs/MISURA_VITE.md` rigenerato. Una carta in
  mano a un seggio sposta quanto spesso le case si trasformano — non e' arredo.

### Corretto

- `test_data_boot` contava 16 obiettivi; il pool ne ha 17. E la guardia gemella
  in GDScript (`test_objective_pool`) non conosceva i selettori nuovi, come non
  li conosceva quella Python: due copie della stessa regola, corrette insieme.

---

## 0.1.276 — Sei punti su dieci erano gia' tuoi prima di giocare (D-314)

### Misurato

- **La quarta domanda di `run_contest_probe.gd`, promessa e mai eseguita.** Il
  commento di testa della sonda ne annunciava quattro fin dalla nascita; ne
  girava tre. La mancante era *gli obiettivi si incrociano?* — cioe' l'unica che
  dice se il gioco e' una gara. Undicesima misura cieca a verbale.
- **Quattro misure nuove**, su 40 tavoli CHR_01 ai semi 7000+, misto e uniforme
  (i due tavoli concordano):
  - coppie di seggi che si contendono una Regione: **2.9%**; una memoria: **1.2%**;
  - i punti presi: **55.3%** mappa, **16.3%** mondo, **28.4%** quello che porti;
  - clausole centrate che nessuno poteva impedire: **89.8%**;
  - clausole **gia' vere all'apertura**, prima di ogni mossa: **60.5%**.
- **Tre tipi di clausola valgono il 40.8% dei punti e sono una dotazione, non un
  obiettivo**: `entity_alive` (113), `scar_count` (154), `state_tag_absent` (165)
  — vere al setup nel 100% dei casi, contese quasi mai.
- **Un tipo solo regge l'85% della superficie competitiva**: `control_count`,
  92 clausole centrate su 92 contese.
- L'analisi statica del grafo diceva *la corsia mappa e' competitiva, quella del
  mondo no*. **In partita e' peggio, e non e' un problema di una corsia sola.**

### Non cambiato

- Nessuna regola, nessun dato. Questo giro **misura**: la scelta strutturale sta
  al committente, con i numeri in mano ([ISSUES 91](docs/ISSUES.md)).

---

## 0.1.275 — Una mappa che non offre una famiglia toglie otto carte dal gioco (D-313)

- **Nata da una domanda del committente sul tavolo fisico**: *«se le zone sono 6
  come si fa a pescare 7 carte? E se non hai presenza in una regione non peschi
  la carta?»* La risposta alla seconda ha scoperto un difetto.
- **Si pesca sempre**: la presenza non è un requisito, è un selettore. Senza
  gettoni il rubinetto pesca dal mazzo più pieno; l'ACQUISIRE pesca una carta
  invece di due. Ma allora è la mappa a decidere **quale** famiglia si può
  inseguire.
- **Il difetto, misurato su tutte le 210 mappe possibili**: **45 lasciavano
  fuori una famiglia**, e in **28** era l'Autorità — che usciva da **2 sole
  tessere su 10** contro le 4 di Forza, Gente e Conoscenza. Su una mappa così,
  le otto carte Autorità non si possono andare a prendere.
- **Il limite prima del rimedio**: servirebbe ogni famiglia su 5 tessere — 30
  caselle — e ne esistono 20. Il 100% è **impossibile** con due famiglie per
  tessera; il meglio è `4,4,3,3,3,3`, cioè 30 mappe monche.
- **Mossa 1, una casella**: il **Bosco dei Confini** passa da *Forza + Gente* a
  *Forza + Autorità*, e la ragione è scritta nella tessera — *«Il confine passa
  di qui, ma nessuno l'ha mai visto scritto»*. **45 → 30**, che è l'ottimo:
  provato per forza bruta, dieci scambi ci arrivano e nessuno va sotto.
- **Mossa 2, una regola di stesura** che chiude le trenta rimaste: *stese le sei
  tessere, se una famiglia non compare, togli quella le cui due famiglie sono
  già offerte da un'altra e mettine una che porti la mancante*. È un gesto che
  una persona esegue al tavolo. **30 → 0.**
- **Quattro prove, due delle quali sono guardie**: la terza e la quarta esistono
  perché le prime chiamano `resolve_map` a mano e sarebbero verdi anche col
  cablaggio rotto. Tolto il set di dati alla chiamata di `GameSession`, la
  quarta va rossa: **9 partite su 60**. Col rimedio guasto, la seconda dice 30.
- **Quello che il cancello non prova, dichiarato**: il playtest gira CHR_01 e
  CHR_03, e **nessuna delle due contiene il Bosco**. I numeri sono identici per
  questo, non perché la modifica sia neutra: CHR_00 è l'unica Chronicle che
  pesca la mappa, e la prova di questa decisione è il test nuovo.
- **Sedici carte hanno cambiato la frase stampata**: `acquisition_rule` nomina
  le Regioni fonte, e il validatore l'ha presa subito — otto Autorità che non
  nominavano il Bosco, otto Gente che lo nominavano ancora.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **618**.

---

## 0.1.274 — Le Vie, e la domanda che il committente ha fatto guardando le carte (D-312)

- **Scritto il terzo Tema, le Vie**: sette carte (Le Vie Interrotte, L'Acqua
  Ferma e Il Debito avevano già le loro), **14 domande e 21 proposte** nuove.
  **35 → 28** carte che aprono una domanda in prestito.
- Trasformazioni sedute **174**, vite mai sedute **6**: invariate. Playtest 100
  semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **614**.
- **Aperta ISSUES 89, ed è la voce che conta più delle altre due.** Guardando
  le carte, il committente ha chiesto perché non sono fatte come le carte
  Azione — bersaglio a segni, due azioni che dicono quale segno posano, il resto
  Flavor Text. Ha ragione: le carte Azione sono già così (D-274), e la **faccia
  fisica** della Tensione pure (D-280, dodici caselle verbo+segno). Il
  **Consiglio** che quella stessa carta apre no.
- **Il numero**: **185 proposte, 642 Effetti che nessuna carta stampa**. Al
  tavolo fisico non si risolve **una sola** proposta senza l'app. Dei 642, 494
  li saprebbero dire le caselle di oggi; **148** no, e sono di cinque specie.
- **Detto col suo nome**: i tre Temi scritti finora hanno reso le carte diverse
  da **leggere**, non risolvibili **col dito**. È un guadagno vero e piccolo.
  La scelta fra le tre strade è del committente, e viene prima degli altri tre
  Temi.

---

## 0.1.273 — Il Potere ha le sue domande, e due sonde guardavano altrove (D-311)

- **Scritto il secondo Tema, il Potere**: otto carte (La Carta e La Successione
  avevano già le loro), **16 domande e 24 proposte** nuove, sulle nove
  Conseguenze che già esistono. **43 → 35** carte che aprono una domanda in
  prestito.
- **La sonda del catalogo dei Consigli non guardava le carte.** Riscritte otto
  carte, il cancello è passato *senza che il documento cambiasse di una riga*:
  `run_council_catalogue.gd` iterava `confluence_templates` — dodici schede per
  sessanta carte — e stampava ancora le proposte generiche. Adesso cammina su
  `data.tensions` attraverso `confluence_template_for`, la stessa strada del
  motore: **12 Consigli / 49 proposte / 21 clausole → 60 carte / 185 proposte /
  83 clausole**.
- **Stesso difetto in `run_who_writes_probe.gd`**: il denominatore di *«quanto
  contenuto d'autore il tavolo vede»* veniva dai template. **Nona e decima volta
  in questo progetto che una misura ferma era la sonda.**
- **Il costo dichiarato, ed è il numero che peggiora**: proposte votate **36 su
  49 (73%) → 36 su 100 (36%)**, domande poste **21 su 23 (91%) → 21 su 57
  (37%)**. Al tavolo non è regredito niente: è finita una misura che si dava
  ragione da sola. Oggi in 40 anni di CHR_01 il tavolo vede **poco più di un
  terzo** di quello che c'è scritto.
- Trasformazioni sedute **174**, vite mai sedute **6**: invariate. Playtest 100
  semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **614**.

---

## 0.1.272 — Ogni carta le sue proposte (D-310)

- **Taglio 2 di ISSUES 80, scelta del committente: «ogni carta sue proposte».**
- **Cosa c'era, misurato**: sette Domande generiche coprivano **52 carte su
  60**. *«Chi decide a chi non ne tocca?»* era la domanda di quindici questioni
  diverse; solo otto carte ne avevano una propria. Al tavolo, La Febbre Bassa e
  I Lupi al Limitare aprivano lo **stesso dibattito**.
- **Ogni carta porta adesso il suo Consiglio** — un blocco `council` con le sue
  Domande e le sue Proposte. La carta girata basta a se stessa. Il template
  resta per quello che non è della singola carta: clausole, pool, Risonanza del
  titolo; `confluence_template_for` fonde le due cose e **la carta vince su
  quello che è suo**.
- **Il controller non legge più `confluence_templates[...]` direttamente**:
  cinque punti passavano di lì e avrebbero preso la domanda di ripiego.
- **Il cancello che rende il debito un numero**: la misura della matrice conta
  le **carte che aprono ancora una domanda in prestito**, e guarda il **testo**,
  non l'id — così il buco non si chiude rinominando.
- **Due controlli nuovi** nella grammatica fisica, coi loro difetti piantati
  (**ventuno**): il ponte delle domande accetta la casa nuova, e una domanda che
  si apre deve avere **almeno una risposta**.
- **Scritto il primo Tema, la Sopravvivenza**: nove carte, **18 domande e 27
  proposte** nuove, sulle Conseguenze che già esistono. **52 → 43** carte in
  prestito.
- **Il costo dichiarato**: trasformazioni sedute **183 → 174** — le proposte
  nuove portano Conseguenze diverse, e il mondo arriva ai salti d'era in un
  altro stato. È il valore basso della banda in cui il numero oscilla da cinque
  decisioni (182, 185, 184, 183, 174), non un gradino nuovo. Vite che non si
  siedono mai: **sei**, invariato.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **614**.

---

## 0.1.271 — La Miniera di Stato dice quello che la sua frase diceva già (D-309)

- **Chiusa l'eccezione dichiarata da D-307.** `CNS_MINE_TAKEN` era l'unica
  Conseguenza il cui corpo intero era il mestiere di una casella: prendere il
  controllo. Toglierle quella riga l'avrebbe lasciata senza Effetti, e lo schema
  non accetta una Conseguenza vuota.
- **Ma la sua frase dice un'altra cosa**: *«Aprire le gallerie significa
  metterci qualcuno a contare quello che esce. Chi conta, comanda.»* Il
  controllo è la seconda metà; la prima è che **da adesso qualcuno conta**. E
  quella metà il dizionario ce l'ha già: `study_supervised`, memoria del mondo,
  **temuta da Cenere e da Lyra**, che nessuna casella del Consiglio vende.
- **La guardia della grammatica adesso copre tutte le Conseguenze**, senza un
  elenco di perdonate.
- **I numeri**: vite che non si siedono mai **7 → 6**, trasformazioni sedute
  184 → **183**.
- **Aggiornata ISSUES 82** con la coda di adesso: le tre condizioni rare si sono
  mosse da sole con D-306/D-307/D-308 — `plundered` 1 → 4 anni su 40,
  `mourning` 1 → 3, `requisitioned` 1 → 2. I mai visti restano quattro ma non
  sono gli stessi: entra `structure:sealed`, esce `settlement:market`.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **614**.

---

## 0.1.270 — IL MONDO RICORDA: il verbo che mancava al Consiglio (D-308)

- **Strada (a) di ISSUES 76, scelta dal committente — e chiude ISSUES 76.**
- **Il vocabolario del beneficio non aveva il verbo che la direzione del
  progetto nomina.** *«Le Azioni cambiano il mondo. Il Consiglio decide cosa il
  mondo ricorderà»* — e i cinque verbi erano: riapri, ripulisci, costruisci,
  cambia controllo, raffredda. **Nessuno scriveva un fatto.**
- **Il buco, misurato**: dei 30 segni che le otto case vogliono lasciare nel
  mondo, un Consiglio ne sapeva dare **sette**, e tutti e sette erano Pietre. Il
  resto sono memorie, e solo una frase d'autore le sapeva scrivere. Il Consiglio
  sapeva **infliggere** quello che le case temono e non sapeva **dare** quello
  che vogliono.
- **`REMEMBER` — «IL MONDO RICORDA»**, sesto verbo del beneficio, con un `tag`
  come AGGIUNGI CONDIZIONE dalla parte dei costi. Posa una memoria sul **mondo**:
  è la sola casella che esce dalla Regione in discussione. Diciotto memorie
  coprono tutte e otto le case; ognuna delle 60 carte ne porta una.
- **I numeri**: Tensioni che non toccano nessun segno nominato da un Destino
  **34 → 0**; fra i voluti, quelli che un Consiglio sa dare **7 → 25**. Al
  tavolo il verbo si compra **24 volte in 40 anni** e scrive 19 fatti su otto
  diversi.
- **Undici carte hanno cambiato fatto**: portavano un segno che i profili
  nominano ma nessun Destino. Scambiato senza forzare il senso della carta.
- **Una bugia vecchia del dizionario, scoperta dal verbo nuovo**: la faccia
  della carta scrive segni e il registro delle mani non lo sapeva — `_scava`
  cerca gli Effect, e le caselle sono verbi. **36 segni** allineati, i 18 fatti
  nuovi più 18 condizioni e Cicatrici che i costi scrivevano in silenzio.
- **E la sonda della matrice era cieca allo stesso modo**: scritte le sessanta
  carte, le misure non si muovevano di un numero. Ottava volta in questo
  progetto che una misura ferma era la sonda.
- **Il numero peggiorato**: acquisti a vuoto 9% → **11%** — 5 delle 24 memorie
  trovano il fatto già scritto dalla frase d'autore nello stesso Consiglio. È la
  via indiretta di ISSUES 87.
- La guardia rifiuta una casella RICORDA che non nomini una memoria del mondo:
  **venti difetti piantati**.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **614**.

---

## 0.1.269 — La frase d'autore smette di fare il mestiere delle caselle (D-307)

- **Taglio A di ISSUES 87, scelto dal committente.** Le due grammatiche
  dicevano la stessa cosa sullo stesso luogo, e chi comprava pagava per un
  lavoro che sarebbe stato fatto lo stesso.
- **E il taglio è più stretto di quanto sembrava.** Delle 67 righe d'autore che
  parlano la lingua delle caselle, solo **40** agiscono sul luogo di cui il
  Consiglio discute; le altre 27 arrivano altrove (`$capital`, `$rival_seat`) e
  nessuna casella le può fare. Delle 40, si tolgono le **9** che consegnano al
  proponente quello che la carta gli vende — 7 `SET_CONTROL` e 2
  `BUILD_STRUCTURE`, su otto Conseguenze.
- **Tre righe restano, con la ragione scritta**: due `SET_CONTROL` a **null**
  (svuotano il luogo invece di consegnarlo — nessun beneficio vende questo), e
  `CNS_MINE_TAKEN`, l'eccezione dichiarata: prendere il controllo è tutto il suo
  corpo, e lo schema non accetta una Conseguenza senza Effetti.
- **La seconda trappola del null, vista misurando**: `_stone_owner` faceva
  `str(owner)` su una Pietra **senza padrone**, dove `owner` è `null` — e
  `str(null)` è `"<null>"`, non la stringa vuota. Una strada o un ponte
  sembravano comprabili. Stessa trappola di `_control_of`, seconda volta nella
  stessa giornata: **20 acquisti a vuoto su 26 erano questo**.
- **I numeri**: benefici comprati che non lasciano niente **44% → 24% → 9%**,
  costi a vuoto **21 → 1 → 0**. Dei 17 rimasti, 14 sono ancora la frase per via
  indiretta: restano in ISSUES 87.
- **Il costo dichiarato**: trasformazioni sedute 185 → **182**, vite che non si
  siedono mai 6 → **7**. Torna a cadere «La Leggenda della Montagna», che
  oscilla fra 0 e 1 saga su ventiquattro da tre decisioni. Non l'ho inseguita.
- **La guardia**: il controllo sta in `validate_physical.py`, col suo difetto
  piantato. **Diciannove difetti piantati.**
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **612**.

---

## 0.1.268 — Una casella che non può fare niente non si compra, e non si paga (D-306)

- **Misurato costruendo D-305, e non me l'aspettavo: il 44% dei benefici
  comprati non lasciava niente.** Su 40 anni, 99 caselle su 224 non spostavano
  un grammo di mondo — 52 «Riapri l'accesso» su luoghi non chiusi, 24 «Cambia
  controllo» verso chi già teneva, 23 Pietre già sue. E 21 costi su 92 non
  mordevano: il prezzo non era un prezzo.
- **E la causa principale non era ISSUES 87**, come avevo dato per scontato:
  era che il menu offriva caselle che lì non potevano fare niente.
- **Al tavolo non succede**: nessuno posa la pedina su «Riapri l'accesso» se il
  luogo non è chiuso. `CouncilEconomy.voice_bites()` è quel colpo d'occhio, e i
  due menu si costruiscono con lei. È la stessa regola che il validatore già
  impone alle carte, dove una scelta finta è un difetto.
- **Non si compra più di quanto si possa pagare**: il tetto è
  `min(3, 1 + costi vivi)`.
- **E se una casella comprata non lascia niente lo stesso, il verbale lo dice**
  — «…e non lascia niente: era già così». Prima era silenzio.
- **Un difetto trovato per strada**: `_control_of` faceva `str(control)` su un
  luogo di nessuno, dove `control` è **null** — e in GDScript `str(null)` non è
  la stringa vuota, è `"<null>"`. CEDI CONTROLLO mordeva dove non c'era niente
  da cedere.
- **I numeri**: benefici a vuoto **44% → 24%**, costi a vuoto **21 → 1**. Il
  24% che resta è tutto ISSUES 87, e adesso ha un nome e un numero.
- **E il costo di D-305 rientra**: vite che non si siedono mai **7 → 6**,
  trasformazioni **174 → 185**. Non l'ho cercato.
- **Il numero che scende, dichiarato**: benefici comprati 1.69 → 1.49 a
  Consiglio, e quasi mai tre alla volta (48 → 12). È l'economia che diventa
  vera: prima si compravano tre caselle di cui una o due morte, pagando due
  prezzi di cui uno finto.
- `plan_d_crown_calls` ribasato: sei domande invece di cinque, la seconda cade,
  Echi 2 → 1. Riguarda quella storia sola: gli altri tre piani ne lasciano 4, 2 e 4.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **612**.

---

## 0.1.267 — La carta vince sulla frase d'autore (D-305)

- **Scelta del committente su ISSUES 86: la carta vince.** Le due liste
  stampate sono l'economia esplicita di D-280 — quello che il tavolo ha
  comprato, pagato e rivendicato non lo cancella una frase che non ha scelto
  nessuno. `_spend_the_card()` è adesso l'ultima cosa che tocca il mondo.
- **Misurato prima di toccare niente**, come ISSUES 86 chiedeva: la frase
  passava sopra la carta **62 volte in 40 anni** — 38 riassegnazioni di
  controllo e 24 segni tolti — e sempre in silenzio. Circa un Consiglio su tre.
- **E la Pietra già alzata.** Girato l'ordine è saltata fuori la stessa
  malattia allo specchio: la frase costruiva il Granaio prima, e il beneficio
  comprato diventava un no-op — pagato per niente. Al tavolo c'è un Granaio
  solo, e adesso **passa a chi l'ha comprato**: EffectType nuovo
  `SET_STRUCTURE_OWNER`, che si inverte su se stesso col padrone di prima.
- **Il numero peggiorato, scritto**: trasformazioni sedute 186 → **174**, e le
  vite che non si siedono mai passano da 6 a **7** — «Il Banco Nero», che era
  già al limite con una saga su ventiquattro. Non l'ho inseguito ritoccando i
  dati.
- **Aperta ISSUES 87**: 67 Effetti d'autore parlano ancora la lingua delle
  caselle. Non si scavalcano più, ma quando la frase regala gratis quello che
  la carta vende, il beneficio comprato è un acquisto a vuoto.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite **610**.

---

## 0.1.266 — Una pedina su una pedina, e la Cicatrice torna a fare un mestiere solo (D-303, D-304)

- **Via la Cicatrice come moneta d'acquisto** (D-303, parola del committente):
  il tetto dei benefici è **tre secco**. `benefit_ceiling()` non esiste più, e
  la Cicatrice resta uno dei sei costi — che è quello che al tavolo era già:
  17 volte in 40 anni come prezzo scelto dagli avversari, mai come acquisto.
  Costo dichiarato: **nessuno**, la riga non era mai stata giocata. Chiude
  ISSUES 85.
- **La pedina del RIVENDICARE si posa sulla carta** (D-304). Il proponente
  comprava dalla faccia della carta, il rivendicante posava la pedina sulle
  Conseguenze del *template*: due elenchi diversi per la stessa pedina, ed è la
  confusione che il committente aveva segnalato. Adesso si rivendica **solo una
  casella davvero comprata**, e a proposta passata quella voce parla di lui.
- **E il cervello non vedeva a chi va il controllo.** Rimessa in fila la
  grammatica, le voci rivendicate sono andate a zero: `_score_effect` valutava
  il passaggio di controllo solo col segnaposto `$proponent`, che sulla carta è
  già risolto. Ogni CAMBIA CONTROLLO stampato valeva **zero per chiunque**.
  Corretto: voci rivendicate 0 → **9** su 40 anni.
- **Costi dichiarati**: controproposte 38 → 17 (il diritto si tiene più spesso
  per il secondo dibattito); Cicatrici scattate 17 → 7 (il fronte avverso, che
  adesso vede il controllo, sceglie più spesso CEDI CONTROLLO).
- **Aperta ISSUES 86**: la frase d'autore si applica dopo la carta e può
  riscriverla, compresa una casella rivendicata.
- **La misura delle vite si muove, e va scritta**: trasformazioni sedute
  187 → 186, e uno scambio al fondo della tabella — «La Leggenda della
  Montagna» esce dal tavolo (1 → 0 saghe) e «Il Banco Nero» ci entra (0 → 1).
  Le vite che non si siedono mai restano **sei**: cambia quale, non quante.
- Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite 609.

---

## 0.1.265 — Il quarto beneficio: prima non si poteva, e adesso non conviene (D-302)

- **Difetto vero, corretto**: il cervello si fermava a tre benefici *per
  costruzione* — il quarto non veniva rifiutato, non veniva **guardato**. La
  riga di D-280 «una Cicatrice ne compra uno oltre il limite» era
  irraggiungibile dal codice. Adesso il tetto lo legge dalla carta.
- **E col tetto alzato non si compra lo stesso**, e adesso si sa perché:
  `score=+1, worst=-2, scar=-2 → -3`. **Il quarto beneficio vale uno e costa
  quattro.** Non è il bot: è l'economia.
- Tre strade per il committente (D-302): il quarto vale di più, la Cicatrice
  costa meno, oppure la riga si toglie dalla carta.
- Nessun numero si muove: benefici 268, spread invariato, playtest 0 su 8.

## 0.1.264 — Il sigillo: un incrocio a tre che non si poteva giocare (D-301)

- `structure:sealed` — che **Vaerax e il Vetro vogliono** e che **la Cenere
  teme** — non aveva nessuna strada per entrare nel mondo. Adesso quattro carte
  del Tema Antico lo portano sulle due liste: fra i **costi** («il luogo viene
  murato») e fra i **benefici** («cade il sigillo»). La stessa cosa da due parti
  opposte, sulla stessa carta.
- **Il numero, piccolo e onesto**: da **mai** a **1 anno su 40**. I segnalini
  mai visti scendono da 4 a 3.
- **E la misura ne ha tirata fuori una più grossa**: `scar:unanswered` sta come
  Cicatrice su 16 carte e non si posa mai, perché **nessuno compra il quarto
  beneficio** — 1 benefico 89 volte, 2 → 31, 3 → 39, **4 → mai**. La regola di
  D-280 non è mai stata esercitata: ISSUES 85.
- Cancello: 0 seggi bloccati su 8. 609 prove verdi.

## 0.1.263 — La fame non aveva un posto da cui entrare (D-300)

- **Nessuna delle dieci Tensioni della Sopravvivenza sapeva affamare qualcuno**:
  la Carestia, se cadeva, lasciava «contesa». Adesso la lista `failure` dice la
  cosa onesta — *«i granai restano chiusi a chiave: chi ha fame se lo ricorda»*.
- `condition:starving` **1 → 3 anni su 40**, `condition:lean` **1 → 3**.
- **E il segno aveva già i denti**: nel registro compaiono «La fame mangia le
  scorte» e, al Consiglio dopo, «**la fame siede al tavolo**». Le regole c'erano
  da sempre: mancava un posto da cui la fame potesse entrare.
- **Costo dichiarato**: `plan_b_broken_council` passa da 3 Consigli a 4 e la
  Carestia cade **due volte**, perché la fame posata dalla prima caduta pesa sul
  secondo tavolo. Prosa del piano riscritta sulla partita nuova.
- Cancello: 0 seggi bloccati su 8. 609 prove verdi.

## 0.1.262 — L'Eredita' misurata, e per adesso non scritta (D-299)

- `cli/run_inheritance_probe.gd`: il secondo punteggio del documento sulle
  trasformazioni, misurato **senza cambiare regole**, in tre versioni, su 672
  salti d'era.
- **È misurabile ed è quasi inerte**: sommata ai gradini ribalta il vincitore
  della saga **4 volte su 24**, e l'accordo con chi ha più Trionfi passa da 4 a
  **5 su 24** — dentro il rumore.
- **Perché**: la versione «solo quello che si poteva perdere» collassa a un +1
  piatto per tutti; quella scritta paga di più le case i cui desideri sono
  **memorie** (Sale 2,56 a salto contro 1,05 di Vaerax e Vetro) — cioè premia
  la durata con un altro nome, che è quello che il committente non vuole.
- **Non l'ho scritta come regola.** La variante che salverei è la terza: *+3 per
  ogni leggenda che porta il tuo nome*. ISSUES 84 porta le tre strade al
  committente.

## 0.1.261 — La soglia legge quello che il mondo sa togliere (D-298)

- **La grammatica ricca della porta del tempo**, come la chiede il documento
  sulle trasformazioni: `unless` con cinque condizioni — Regioni controllate,
  Pietre in piedi, condizioni sparse, un segno preciso, i desideri del profilo.
  La porta si apre quando **una sola** gamba cade: sono le gambe di un tavolo,
  non una somma. Ogni gamba porta il suo *perché*.
- **La cura di ISSUES 81, con la guardia**: almeno una gamba dev'essere una cosa
  che il mondo sa togliere. Difetto piantato «porta fatta di sole memorie» —
  18 difetti, tutti mordono.
- **I numeri**: trasformazioni **139 → 185**; **La Compagnia del Sale 0 → 14**
  e **La Diaspora di Nahr 0 → 10**, che avevano la porta e non si aprivano mai.
- **Le due storte**: il Banco Nero scende a **0** (il Sale muta per il tempo
  prima che il debito venga chiamato), e il ritmo accelera — Nahr 1 salto su
  **4,8**, Aldric 1 su **6,0** (era 15,3). In anni fa una pelle ogni ~480.
- ISSUES 83 apre il rischio speculare: **la porta spalancata**.
- Cancello: 0 seggi bloccati su 8. 609 prove verdi.

## 0.1.260 — Il catalogo delle pedine (D-297)

- `docs/CATALOGO_PEDINE.md`, generato e **nei cancelli**: **74 schede**, una per
  segnalino — parola stampata, categoria e chi lo posa, **cosa vuol dire al
  tavolo**, e il **prompt** pronto da mandare a chi disegna.
- **MASTER PROMPT 6** nella ART_BIBLE: il segnalino da 15 mm non è
  un'illustrazione — si riconosce **prima** di leggerlo. Tre varianti di
  contorno (condizione tratteggiata, Cicatrice rotta, il resto pieno) e il
  vincolo di collisione, che ha già respinto tre soggetti.
- I soggetti stanno in `data/token_icons/token_icons.json`, con schema e
  validatore; il prompt si compone, non si scrive.
- **Le legge anche l'app**: `DataSet.token_icons`, chiavato sul segno — un
  segnalino sulla mappa e uno sullo schermo devono spiegarsi con la stessa riga.
- Cancello nuovo provato: tolta una scheda, va rosso.

## 0.1.259 — La fustella non e' il dizionario: 67 tipi, non 183 (D-296)

- **Correzione di un numero mio**: il censimento metteva i 183 segni del
  dizionario sotto «i segnalini che si posano». La fustella vera taglia
  **67 tipi, 91 pezzi** — 34 per la mappa, 33 per le case — e il documento
  adesso li conta da dove li conta il foglio di stampa.
- `cli/run_punchboard_probe.gd`: quanti tipi arrivano **davvero** sul tavolo.
  **8,8 in media per anno, 15 al massimo**; 17 tipi su 34 non escono mai o
  escono meno di un anno su cinque.
- E la coda letta divisa in due: **le Cicatrici rare sono design**, le
  **condizioni rare sono un buco** — `condition:starving` esce 1 anno su 40, e
  la fame è un Tema del gioco. ISSUES 82 porta la decisione al committente.

## 0.1.258 — Il censimento dei componenti (D-295)

- `tools/components_survey.py` → `docs/COMPONENTI.md`, **nei cancelli**: quanti
  pezzi ha la scatola, quanti fogli A4 escono, quanti segnalini, quanta arte, e
  **cosa manca** perché l'app dica tutto quello che dice il tavolo.
- La scatola: **48 Asset (132 copie), 39 Echo, 60 Tensioni, 23 Destini, 26
  Casate, 10 tessere** — 39 fogli A4 più tre fustelle.
- Il divario, in quattro voci: **facce fisiche non scritte** (39 Echo, 26
  Casate, 10 tessere), **arte 135 su 146 segnaposto**, le regole aperte
  (ISSUES 76/77/80/81), e l'app come oggetto (ISSUES 63/65).
- Contando l'arte sono saltati fuori 49 soggetti che la prima misura non
  vedeva: **le vite delle case hanno un volto ciascuna**. Adesso il numero
  combacia col brief d'arte, che lo calcola da un'altra strada.

## 0.1.257 — Le otto case dichiarano, e tre vite morte si siedono (D-294)

- **Quattro profili nuovi** — Cenere, Città Libere, Sale, Vetro — nella forma
  di D-288, e la porta del tempo a tre vite che non si erano **mai** sedute.
- **I numeri**: incroci **7 → 15**, coppie di case con qualcosa per cui
  litigare **3 → 9 su 28**, trasformazioni sedute **106 → 139**. Le Custodi
  della Cenere **0 → 20**, I Frati del Vetro **3 → 18**.
- **Le vite mai sedute restano 7**, ma non sono le stesse: le Custodi si
  siedono, l'Inquisizione del Vetro scende a zero perché il Vetro adesso cambia
  pelle per il tempo prima che la reliquia venga mostrata.
- **La Compagnia del Sale ha la porta e non si apre**: i segni che la Gilda
  vuole lasciare sono **memorie**, e una memoria scritta non si perde più. *Una
  soglia deve leggere quello che il mondo sa togliere.*
- E `trade` tolto dai desideri del Sale: è stampato sulle tessere, quindi non
  distingue niente. **Un desiderio che la mappa porta da sola è arredo.**
- Ritmo: nessuna casa muta più spesso di 1 salto su 6,2.
- La guardia del validatore ora **fabbrica** il difetto invece di cercarlo.
- Cancello: 0 seggi bloccati su 8. 607 prove verdi.

## 0.1.256 — Gli incroci: chi litiga con chi, e per cosa (D-293)

- `matrix_survey` sezione 5, nei cancelli: per ogni segno **chi aiuta e chi
  danneggia**, mettendo insieme Destini e profili (le `denies` comprese, che
  sono incroci dichiarati a mano).
- **Il numero: 7 segni incrociano, e le coppie di case con qualcosa per cui
  litigare sono 3 su 28.** Cinque di quei sette **cambiano anche la pelle** di
  una casa, perché una porta del tempo li legge.
- La causa è strutturale: gli incroci esistono quasi solo fra le quattro case
  con un profilo. **Scrivere i quattro che mancano è la leva più corta**
  (ISSUES 79).
- Il cancello che la linea delle trasformazioni chiede — «due case devono
  condividere un trigger opposto» — **resta spento e dichiarato**: acceso oggi
  direbbe rosso su 25 coppie su 28.

## 0.1.255 — Chi scrive nel mondo, e le Pietre che non lo dicevano (D-292)

- `cli/run_who_writes_probe.gd`: la misura che viene prima del taglio 2. Su 158
  Consigli, **la frase d'autore scrive il 71%** di quello che resta sul mondo,
  la carta il 29%. **Il taglio 2 non e' una cancellazione, e' un
  trasferimento** — e il committente decide sapendo quanto costa.
- **La carta racconta cosa lascia**: la voce comprata applicava i suoi Effetti
  in silenzio mentre la Conseguenza d'autore narrava i suoi. Meta' del Consiglio
  cambiava il mondo senza una riga di verbale.
- **Le Pietre e le strade parlano**: il narratore non aveva una frase per
  `BUILD_STRUCTURE`, `RAZE_STRUCTURE`, `SET_STRUCTURE_GRADE`, `CLOSE_PASSAGE`,
  `OPEN_PASSAGE`. Un Granaio si alzava e nessuno lo leggeva. I benefici
  raccontati salgono **da 89 a 121**.
- E la sonda non vedeva il trattino del registro: **sesta volta** che uno zero
  in questo progetto era la sonda.
- Cancello: 0 seggi bloccati su 8. 607 prove verdi.

## 0.1.254 — Il tabellone del Consiglio mostra la carta girata (D-291)

- **Taglio 1 di ISSUES 80**: fra la Proposta e le pose, il tabellone apre la
  faccia stampata della Tensione — **COSA SI COMPRA** coi benefici e la pedina
  posata su quelli comprati, **IN CHE MONETA** coi costi e la pedina del fronte
  avverso, **LA CONTROPROPOSTA** quando c'è, **SE CADE** con quello che scatta
  se la proposta non passa.
- Il conto in testata: «2 comprati, prezzo: 1 costo», e tre testate diverse per
  il prezzo — niente da pagare, chi l'ha scelto, o **si sta aspettando lui**.
- **Nessuna regola cambia**: si disegna quello che il motore faceva già dal
  45% dei Consigli in poi, e che nessuno vedeva.
- Il tabellone si costruisce da solo alla prima lettura: `_ready()` non gira
  per un nodo fuori dall'albero, ed è la trappola che ha fatto morire a metà la
  prima prova invece di farla fallire.
- Cinque prove nuove, provate a mordere (24 asserzioni rosse col blocco spento).
- Cancelli: 0 seggi bloccati su 8. 606 prove verdi.

## 0.1.253 — La sonda del prezzo ci vedeva meta' (ISSUES 80)

- `cli/run_price_probe.gd` cercava il formato di log che il motore non scrive
  piu' da D-278: le sue voci «costi diversi 0» e «sfoghi diversi 0» erano
  cecita' sua, non silenzio del tavolo. **Quinta volta in questo progetto.**
- Riparata, dice: **11 voci di costo diverse scelte dal fronte avverso, 8
  scattate davvero**, e il prezzo dichiarato all'acquisto — 87 Consigli comprano
  solo il beneficio gratis, 55 ne pagano uno, 16 ne pagano due.
- ISSUES 80 apre la diagnosi del Consiglio: **due Consigli impilati, e a
  decidere e' quello vecchio** (voti + carte segrete + un d6), con lo schermo
  che disegna solo la meta' vecchia.

## 0.1.252 — La soglia: il tempo, e quello che non tieni piu' (D-290)

- **Prima la misura**, congelata come cancello: `docs/MISURA_VITE.md` +
  `cli/run_lives_probe.gd` + `tools/run_lives_survey.sh --check`. Delle 18 vite
  scritte oltre la prima, in **168 salti d'era** sette non si erano **mai**
  sedute; il Regno che diventa Repubblica, **una volta su 168**.
- **La seconda porta**: `also_enters {after_years, holds_at_least}` su una vita.
  Si apre quando è passato abbastanza tempo **e** il mondo non porta più
  abbastanza dei segni che la casa vuole lasciare. Serve che siano vere tutte e
  due.
- **L'elenco lo dà il profilo (D-288), non la vita**: un secondo elenco
  divergerebbe. Il validatore rifiuta la porta senza profilo e quella
  impossibile da tenere chiusa — 17 difetti piantati, tutti mordono.
- Il seggio porta `life_years`: l'età della **pelle**, non della casa.
- **Il numero**: trasformazioni sedute **88 → 106**; il Culto della Misura
  **2 → 16**, la Repubblica **2 → 6**. Le vite mai sedute restano **7**, perché
  cinque appartengono alle quattro case senza profilo (ISSUES 79). La Diaspora
  resta chiusa: Nahr insediato *tiene* quello che voleva, ed è la regola che
  funziona.
- Nessuna casa muta più spesso di 1 salto su 6.
- **E si legge**: la riga della soglia in fondo a «COSA RESTERÀ DI TE», col
  contatore degli anni, e sul tarocco della Casata «vuoi lasciare: …» più la
  soglia sotto.
- Cancello: 0 seggi bloccati su 8. 601 prove verdi.

## 0.1.251 — Il profilo lo legge il cervello, e lo legge chi gioca (D-289)

- **Lo schermo**: in fondo alla colonna di destra il blocco **COSA RESTERÀ DI
  TE** — la riga del profilo, i segni voluti in verde, quelli temuti in rosso,
  **in oro quelli che sono sul tavolo adesso**, e il perché di ognuno nel
  suggerimento. Una casa senza profilo non mostra niente.
- **Il cervello**: `profile_weight()` con peso 3, nella scelta fra le due metà
  di una carta e nell'acquisto al Consiglio. Segno voluto posato vale, temuto
  costa, e quello che un rivale ha dichiarato di volerti impedire vale doppio.
- **Il numero, che è quasi tutto negativo** (misura appaiata, 40 anni, stessi
  semi): segni voluti posati **17 → 17**, temuti **17 → 14**, benefici
  comprati che davano al proponente un segno voluto **15/246 → 15/245**. Tre
  autolesioni evitate in quarant'anni, al Consiglio niente.
- **Perché**: non è la bilancia, è che *non c'è niente da preferire* — ISSUES 76
  vista dal lato di chi sceglie. Il peso resta com'è; alzarlo peggiorerebbe le
  scelte senza cambiare la moneta.
- Cancello: 0 seggi bloccati su 8, misto e uniforme. 593 prove verdi.

## 0.1.250 — Il profilo strategico delle quattro case (D-288)

- `godot/data/design_matrix/entity_strategic_profiles.json` + schema suo: cosa
  Aldric, Nahr, Lyra e Vaerax vogliono **lasciare nel mondo**, cosa non vogliono
  vederci, e cosa vogliono impedire a chi. Ogni voce porta il suo perché.
- **Solo quello che non si ricava**: niente incroci di tag e di Tensioni scritti
  a mano — quelli i dati li dicono già, e due file che dicono la stessa cosa
  divergono. Il resto lo calcola `matrix_survey`.
- **Tre conseguenze subito**, o sarebbe un documento: il censimento del
  validatore conta il profilo fra i lettori (29 segni, e gli orfani muti
  scendono da 15 a 13); la misura ne ricava la sezione 4 — chi sa dare ogni
  desiderio; lo schema rifiuta i segni inventati.
- **Il numero**: delle 16 cose che le quattro case vogliono lasciare, **un
  Consiglio ne sa dare 4**.
- Il cervello e lo schermo non lo leggono ancora: è il passo dopo.

## 0.1.249 — Le tre misure che vengono prima della matrice (D-287)

- `tools/matrix_survey.py` → `docs/MISURA_MATRICE.md`, nei cancelli: i tre
  elenchi che il piano della matrice strategica chiede prima di scrivere un
  file nuovo.
- **I segni orfani**: 67 su 150 scritti, ma **49 portano già la loro ragione**
  (memorie narrate, etichette di famiglia, gradi di pietra). I **muti sono 15**,
  ed è quella la lista di lavoro.
- **Gli obiettivi**: **nessuna clausola impossibile** (la sola candidata,
  il Trionfo di Vaerax, chiede una leggenda — e le leggende le scrive il tempo);
  **33 livelli su 69** si reggono solo su conteggi, cioè si verificano ma al
  tavolo non si possono indicare.
- **Le Tensioni**: **35 su 60 non toccano nessun segno che un Destino nomina.**
  Tutte e 60 hanno lo stesso conflitto strutturale — una Pietra e una Cicatrice
  — che è il modello della faccia, non contenuto.
- **Il Consiglio decide con una moneta che i Destini non spendono**: dei 24
  segni che le facce delle Tensioni posano, 3 sono temuti per nome; dei 17
  voluti, nessuno si ottiene da un Consiglio.

## 0.1.248 — Il mondo si ricorda: quindici memorie tornano a mordere (D-286)

- **Passo 2, con una correzione.** Le «27 Memorie che nessuno legge» non erano
  un difetto: ognuna porta la sua ragione scritta, e quindici dicono «memoria
  del mondo: narrata, ereditata». Il difetto vero era che **la pesca dell'era
  successiva non ascoltava nessuna memoria** — solo condizioni e strutture.
- Adesso quindici memorie stanno negli `echoes` delle Chronicle, accanto alla
  domanda che è loro: la Carta che vale per un tempo solo, il cristallo
  misurato, la successione con testimoni, i diritti d'acqua, il pedaggio
  diviso, il sapere condiviso.
- Misurato: **21 anni su 30** finiscono con almeno una memoria che chiama la
  sua domanda per l'anno dopo (prima: zero). È un pavimento, non un soffitto.
- **Tre penne si erano nascoste**, e si vedevano solo leggendo: il validatore
  fisico non censiva la Chronicle come lettrice (39 segni con la mano non
  dichiarata); il registro dei segni non vedeva la penna del Consiglio, né la
  penna e l'occhio della faccia delle carte; e un gancio d'Echo su due.
- **Un difetto piantato era scaduto**: il self-test nominava `charter_temporary`
  come segno muto, e quando quella memoria ha trovato un lettore la guardia ha
  smesso di mordere senza che niente fosse rotto. Adesso il difetto si sceglie
  il segno dal dizionario.
- Sonda nuova: `cli/run_memory_probe.gd`. Playtest 100 semi **0/8**.

## 0.1.247 — Un'Occasione non si butta (D-285)

- **Passo 4: il turno che decide.** Si passava l'**82,1%** dei turni con sette
  carte in mano e quindici mosse legali. Il ripiego «fai quello che la mano
  permette» non veniva **mai** provato, e la lista delle mosse guardava un solo
  verbo per carta e un solo bersaglio per verbo.
- Adesso, quando nessuna intenzione scatta, si gioca la più debole che la mano
  permette — fra tutte le Azioni stampate e tutti i bersagli. **Mai** spingere
  una domanda dalla parte sbagliata, **mai** rompere un patto per noia.
- **La riserva resta**: una carta calata è una carta che al Consiglio non vota.
  Sopra `max_commit_assets + 1` si gioca, sotto si tiene.
- Misure (100 semi, tavolo misto): si passa **42,1%** (prima 82,1%); carte
  pescate che si calano **55,0%** (prima 23,2%); FORGIARE **46,6%** (5,9%);
  RIVENDICARE **60,9%** (19,6%); **nessuna carta muta** (prima 3 mai calate).
  Playtest **0/8**.
- **Il costo, scritto**: le Verità scritte scendono da **295 a 256** (−13%). È
  la regola del gioco che si vede — il mondo ricorda solo i Consigli in cui
  qualcuno ha messo peso — e la riserva è il quadrante per spostarla.

## 0.1.246 — Il segno stampato ha un posto (D-284)

- **Passo 1bis.** I 314 segni che non trovavano dove stare adesso lo trovano:
  la carta dice *dove* col suo bersaglio a segni, e chi cala sceglie il luogo
  fra quelli che la carta raggiunge. Un luogo che non raggiunge si rifiuta,
  nella stessa lingua del bersaglio.
- **È una scelta vera**: posare #conteso sulla capitale di un rivale non è come
  posarlo su casa propria. Il cervello sceglie col metro dei segni; una persona
  lo sceglie **sulla mappa** — si tocca la carta, si accendono i luoghi.
- Misure su 100 anni: **862 segni stampati, 862 posati, 0 senza soggetto**
  (prima: 537 posati, 314 senza). Playtest 100 semi **0/8**.
- Quattro prove nuove (`test_the_sign_finds_its_place`), fra cui la regola su
  tutte e 48 le carte: un posto si chiede esattamente quando serve.

## 0.1.245 — La faccia è la verità: entrambe le Azioni si giocano (D-283)

- **Passo 1 del brief del Punto Zero.** I verbi di una carta sono adesso
  **quelli stampati sulla sua faccia**, non il solo `card_action.kind`: chi
  gioca dice quale delle due Azioni sta calando, e il motore la esegue.
- **I segni stampati si posano davvero** (`puts_tag`, `clears_tag`): ognuno
  dove il dizionario dice che vive — mondo, Regione, casa. Sono loro a rendere
  diverse le due metà: 29 carte su 48 stampano lo stesso verbo due volte.
- Il segno stampato **si firma** (`face_action`), come la Risonanza: nel
  verbale si distingue quello che ha scritto l'Azione da quello che ha scritto
  il verbo.
- Misure su 100 anni: **16,6% delle carte calate usa la seconda Azione**
  (prima: mai), **537 segni posati** sul mondo (prima: zero), RIVENDICARE
  calato dal 19,6% al **33,0%**. Playtest 100 semi **0/8**.
- **Il costo, scritto**: il passare scende solo dall'84,3% all'**82,3%**. La
  ragione dominante non erano i verbi della mano — è l'appetito del cervello
  («mosse legali, nessuna che gli servisse», dal 54,7% al 65,1% dei passa).
  Restano 314 segni su 851 che non trovano un soggetto: passo 1bis.
- Sonda nuova `cli/run_mark_probe.gd`; cinque prove in
  `test_both_printed_actions.gd`.
- **Correzione alla diagnosi**: le Memorie *esistono* — 80 voci di categoria
  MEMORY nel dizionario, non zero come avevo scritto cercando il prefisso
  `memory:`. Il difetto vero è che 27 non le legge nessuno e 20 erano
  dichiarate scritte da uno scrittore che il motore non eseguiva.

## 0.1.244 — La colonna si legge, e la diagnosi del Punto Zero (D-282)

- **La colonna di destra diceva la stessa cosa tre volte** e non spiegava
  niente: i sei mazzetti disegnati, la riga «CALORE» che li ripeteva a parole,
  e le quattro questioni chiamate «le domande dell'anno» — mentre le domande,
  da D-261, sono i mazzetti. Via la riga duplicata; le quattro si chiamano
  adesso **«le questioni già aperte»**, che è quello che sono (il ripiego per
  l'Atto in cui nessuna Risonanza ha scaldato niente).
- **Ogni blocco dice a cosa serve**, in una riga sotto l'intestazione: i
  mazzetti, le questioni, i rapporti, i diritti, i segni della casa, il
  Destino. Al tavolo la plancia ha le sue scritte stampate accanto; sullo
  schermo non c'erano.
- Tre prove nuove (`test_the_column_can_be_read`): ogni intestazione ha la sua
  riga, nessuna riga sopravvive alla cosa che spiega, e la stessa cosa non si
  dice due volte.
- **`docs/DIAGNOSI_PUNTO_ZERO.md`**: la risposta al brief del committente, coi
  numeri. In breve — sei cose sono già la grammatica del brief, tre no: la
  seconda Azione stampata che il motore non offre mai (48 carte), le Memorie
  che nei dati non esistono (0 tag `memory:`), e le due economie della stessa
  domanda. Misure: si passa l'**84,3%** dei turni; **23,2%** delle carte
  pescate viene calato; FORGIARE il **5,9%**; tre carte non si calano mai.

## 0.1.243 — Il turno si vede: la mano era morta (D-281)

- **Difetto, trovato giocando**: le carte in mano non ricevevano mai le loro
  offerte durante la domanda — `ask()` costruiva `_offers` **dopo** il
  `_refresh()` che disegna la mano — e una carta col carico vuoto non si prende
  e non si trascina. **Nessuna carta era giocabile, in nessun turno.**
- **La colonna dice quali carte parlano adesso**, con quante mosse portano:
  premere la riga è lo stesso gesto di toccare la carta nel ventaglio. D-238
  aveva svuotato la colonna, e quando tutte le scelte hanno un posto dove
  cadere restava un turno con niente da premere.
- **Una carta giocabile si vede** (bordo acceso, le altre a metà luce), e il
  suggerimento parla un gesto che un dito può fare: via «Trascina una carta
  dove vuoi usarla».
- Cinque prove nuove che legano **la domanda alla mano** (`test_a_turn_can_be_played`),
  il buco per cui il difetto era passato: le prove sul trascinamento riempivano
  il carico a mano.
- Playtest 100 semi **0/8** misto e uniforme; suite **573 prove / 33.194
  asserzioni**; cancelli tutti verdi.

## 0.1.242 — L'economia del Consiglio, costruita (D-280)

- **Il cuore, come lo vuole la carta del committente.** Vocabolario chiuso di
  11 verbi legati ai segni della mappa: RIAPRI, RIMUOVI CONDIZIONE, COSTRUISCI
  PIETRA, CAMBIA CONTROLLO, RAFFREDDA TEMA / AGGIUNGI CONDIZIONE, PEDAGGIO,
  CEDI CONTROLLO, SCALDA TEMA, PRENDI DEBITO, CICATRICE. Le 60 carte li
  nominano e li parametrizzano.
- **L'economia**: 1 beneficio è gratis, ogni altro costa 1 costo, una Cicatrice
  ne compra uno oltre il limite (max 3 benefici, max 2 costi). **Il proponente
  compra, gli avversari scelgono in che moneta paga.** Se passa si applicano
  benefici e costi; se cade, gli effetti stampati.
- Due passi nuovi nel giro del Consiglio, il cervello che sa comprare e far
  pagare, il router che li inoltra (la trappola di D-268), la scheda a schermo
  con le due liste e la riga dell'economia.
- **Taratura d'autore dichiarata**: valore intrinseco situazionale dei verbi,
  senza il quale il cervello comprava sempre e solo il beneficio gratis
  (1,01 a Consiglio, economia morta).
- Misure (40 anni, CHR_00): **1,53 benefici a Consiglio**, 61 prezzi pagati,
  29 Cicatrici. Playtest 100 semi **0/8**; suite **568 prove / 33.172
  asserzioni**; guardia su **15** difetti piantati.

## 0.1.241 — L'app come la vuole il tavolo (D-279), e l'economia del Consiglio decisa (D-280)

- **Sei correzioni del committente sul prototipo giocato a schermo.** Cinque
  fatte: la **soglia è la copertina** e lì si scelgono i seggi e chi li gioca
  (persona o bot); la sala non chiede più né il seggio né «che mondo?» (il
  mondo si pesca); via la schermata **«Come si gioca»**; le tessere sono
  **quadrate e accostate in griglia 3×2** col quadro dipinto per intero —
  niente esagoni, niente strade disegnate, e il dito prende il quadrato; i
  **sei mazzetti dei Temi** si vedono tutti, coi gettoni sopra e la carta
  girata quando c'è.
- **Le carte in mano hanno una scheda**: bersaglio a segni, le due Azioni col
  loro nome, e sotto ognuna i posti dove può andare. Il verbo viaggia con
  l'offerta (`subject.verb`) — senza, lo schermo non poteva legare una scelta
  legale all'Azione stampata. Dove il motore esegue una sola delle due Azioni,
  la scheda lo dice (ISSUES 69).
- **D-280, decisa e da costruire**: la carta d'esempio del committente mostra
  che l'economia del Consiglio è **benefici comprati coi costi** (1 gratis,
  ogni altro costa 1 costo, una Cicatrice ne compra uno oltre il limite), coi
  verbi legati ai segni della mappa — e che **il proponente compra, gli
  avversari scelgono in che moneta paga**. Niente costo di apertura: la
  Tensione si risolve a fine Atto, e la soglia esce dalla faccia della carta.
  D-278 Fase A resta come strada (il menu letto dalla carta, la guardia 18);
  le sue 240 frasi diventano materiale, non forma finale.
- Misure: playtest 100 semi **0/8**; suite **567 prove / 24.887 asserzioni**;
  cancelli verdi. Nessuna regola toccata.

## 0.1.240 — Le due liste sulla carta Tensione: il cuore, misurato (D-278, Fase A)

- **Richiamo del committente**, e aveva ragione: il meccanismo della scelta al
  Consiglio c'era (D-267/D-268), il contenuto no. Misurato prima di toccare:
  **8 carte su 60** avevano un menu di proposte proprio, **40 domande su 107**
  ne offrivano una sola, e il menu dei malus era **la stessa coppia per tutte
  e sessanta le carte**.
- **Le due liste stanno sulla carta**, come la Domanda (D-266): il blocco
  `physical` della Tensione porta `costs` e `failures` (le `opportunities`
  sono la Fase B), ogni voce con le sue parole e la Conseguenza che esegue. Il
  motore legge il menu del prezzo **dalla faccia della carta**; il pool del
  template resta il ripiego.
- **Tavolozza del prezzo**: 12 Conseguenze nuove che tolgono cose diverse.
  **240 testi tutti diversi** sulle 60 carte.
- Il verbale e la console leggono **le parole della carta**; la scheda della
  domanda mostra le due liste — e adesso trova il Consiglio anche per le 52
  carte che non ne nominano uno proprio (prima diceva loro «Nessun Consiglio
  scritto»).
- **Il segno della domanda caduta lo scrive il motore**, non il malus scelto.
- Guardia nuova (controllo 18) e self-test su 14 difetti piantati; la sonda
  del prezzo conta le voci diverse lette al tavolo.
- Misure: menu di costo distinti **2 → 21**, di sfogo **2 → 25**; al tavolo,
  in 40 anni, **34 costi e 34 sfoghi diversi** letti (prima: al massimo 2 e 2).
  Cancello **0/8** su 100 semi; suite **564 prove / 24.886 asserzioni**.
- Costo dichiarato: il malus morde adesso la questione in discussione, e
  `plan_d_crown_calls` chiude con `SUCCESS_WITH_COST` dove faceva `SUCCESS`.
  Sette segni nuovi nascono muti con ragione.

## 0.1.239 — Le dieci tessere dipinte (D-277)

- **Consegna del committente**: le illustrazioni delle dieci tessere del
  parco (D-265) in `res://art/region/` — le sei di CHR_01 sostituite, le
  quattro del tavolo pescato aggiunte. La mappa le ritaglia nell'esagono
  (D-059), la soglia (D-276) le dipinge nell'assaggio.
- **Il quadro del tabellone resta alla mappa d'autore**: sul tavolo pescato
  (`map_positions`) ogni tessera porta il suo quadro e `map.board` non si
  stende più sotto la griglia.
- Suite **560 prove / 14.960 asserzioni**; playtest 100 semi **0/8**
  (nessuna regola toccata); cancelli verdi.

## 0.1.238 — La soglia: l'app si apre sulla scatola (D-276)

- **La schermata d'ingresso** chiesta dal committente: il nome del gioco,
  la mappa della saga — sei tessere di una **pesca vera del motore**
  (stessa derivazione del seme di `game_session.gd`), posate 3×2 come
  comanda D-275, dipinte col pennello della partita (`RegionArt.plan`) —
  nome e segni a cancelletto sotto ogni tessera, i badge, il credito, e il
  bottone «Entra nella sala» verso la scena di sempre.
- `run/main_scene` passa a `title_screen.tscn`; menu, stanza e partita
  non cambiano.
- Il patto è provato: allo stesso seme la soglia e la partita danno le
  stesse tessere nella stessa posa (`test_title_screen.gd`).
- Misure (100 semi): **0 seggi bloccati su 8** (misto e uniforme). Suite
  **560 prove / 14.960 asserzioni**, cancelli tutti verdi.

## 0.1.237 — La posa comanda: sul tavolo pescato vicino è chi si tocca (D-275)

- **Parola del committente («vai con A»)**: sul tavolo pescato l'adiacenza è
  **posizionale** — le tessere si posano in griglia 3×2 nell'ordine di
  pesca, vicino è chi si tocca di lato o di sopra, niente diagonali, niente
  lati bloccati. La posa è stato del mondo (`map_positions`) e la saga la
  eredita con l'ordine delle tessere; le adiacenze restano mutabili
  nell'anno (D-166). Il grafo dichiarato resta agli anni scritti; la
  cucitura delle isole (D-263) esce — una griglia è connessa per
  costruzione.
- **L'app disegna la posa**: la vista della mappa mette le tessere in
  griglia dove stanno sul tavolo.
- Misure (100 semi): **0 seggi bloccati su 8**, 82 mappe diverse, 0 partite
  non concluse. Suite **557 prove / 14.886 asserzioni**.

## 0.1.236 — Il motore esegue il bersaglio a segni: la sim gioca il gioco del tavolo (D-274)

- **Il secondo pezzo di faccia fisica eseguito**, dopo la Risonanza (ISSUES
  69): una carta giocata come **MUOVERE** — o **TRAMARE su una Regione** —
  arriva solo dove i segni del suo bersaglio stanno (vivi: stampati +
  posati), e mai dove sta un segno vietato. Il rifiuto spiega («il bersaglio
  si dice a segni»). Facce ENTITY/TENSION ancora dichiarate e non eseguite.
- **Il cervello sceglie la coppia luogo+carta insieme** (`_widen_the_tap`),
  com'è al tavolo — e itera le Regioni pescate, non il parco intero.
- **Misure (100 semi)**: passa CHR_00 87,2% → **87,8%**, CHR_01 83,8% →
  **84,0%** — il costo della legalità, circa mezzo punto, dichiarato: in
  cambio le sonde d'ora in poi misurano il gioco vero. Playtest **0 seggi
  bloccati su 8**, misto e uniforme. Suite **556 prove / 14.861 asserzioni**
  (5 nuove in `test_card_reaches_by_signs.gd`).

## 0.1.235 — La ri-mira delle 48: ogni bersaglio esiste su ogni mappa pescata (D-273)

- **PZ-3 chiuso**: censite prima di toccare, **30 carte su 30** a bersaglio
  REGION non erano garantite sul tavolo pescato (segni su 1-3 tessere su 10;
  le quattro tessere di PZ-2 quasi irraggiungibili). Ri-mira con la
  matematica di D-265: ogni carta guadagna il **dominio affine** alla sua
  famiglia (stampato su esattamente 5 tessere su 10 ⇒ garantito per
  costruzione) più i segni nuovi dove la finzione li chiede (#porto,
  #palude, #isola, #bosco, #miniera). Testi delle facce aggiornati, alias
  da #cancelletto per i domini, mani del dizionario allineate.
- **Guardia nuova (controllo 17)**: bersaglio REGION ⇒ segni stampati su
  almeno N−K+1 tessere del parco. Self-test a **dodici difetti piantati**.
- **Limite dichiarato**: la ri-mira è della faccia fisica; il motore non la
  esegue ancora (ISSUES 69) e i «passa» non si muovono da qui (87,2% sul
  tavolo pescato — ISSUES 68 resta aperta; il passo vero è far leggere al
  motore il bersaglio a segni). Motore intatto: playtest **0 seggi bloccati
  su 8**, suite **551 prove / 14.836 asserzioni**.

## 0.1.234 — I sei controlli di PZ-9, riletti nel mondo dove la Domanda sta sulla Tensione (D-272)

- **PZ-9, aperto e chiuso**: sei controlli nuovi in `validate_physical.py`
  (11-16) — tessera senza segni, tessera che nessuno legge, Tensione senza
  domande, **ponte delle domande rotto** (ogni `possible_questions` deve
  esistere in un template di Consiglio), Destino che osserva un segno fuori
  dal dizionario, Echo senza `effect_hooks`. I sei della RoadMap, riletti
  dopo D-266.
- **Self-test da cinque a undici difetti piantati**, e la guardia si è vista
  mordere su ognuno. I dati spediti erano già puliti su tutti e sei,
  misurato prima di scrivere i controlli.
- Suite **551 prove / 14.836 asserzioni**; playtest **0 seggi bloccati su
  8**; cancelli tutti verdi.

## 0.1.233 — Lo schermo dice quello che la carta dice: le cinque schermate, censite (D-271)

- **PZ-8, la parte misurabile**: le cinque schermate della RoadMap esistono e
  sono censite nel verbale (Mappa/`map_view`, Mano/`hand_view`,
  Temi/`status_panel`, Consiglio/`confluence_board`+`council_sheet`,
  Saga/`chronicle_book_view`). **La pedina del prezzo e la controproposta
  arrivano al browser gratis** via `seat_decider`→`game_screen.choose`.
- **Il pannello del Destino legge la carta**: i gradini usano le tre righe
  `reads` della faccia fisica (D-270) invece delle etichette digitali —
  funzione pura, provata su tutti i 23 Destini (`test_destiny_screen.gd`).
- **§5ter dichiarato aperto**: nessuna misura copre quello che una persona
  vede — il giro su iPad vero è del committente. Suite **551 prove / 14.836
  asserzioni**, playtest **0 seggi bloccati su 8**.

## 0.1.232 — Ogni Destino ha una faccia, e una misura che dice se chiede di giocare (D-270)

- **PZ-7**: i 12 Destini senza faccia fisica (ISSUES 69.7) l'hanno adesso —
  Tema, segni osservati dalle loro clausole, tre righe leggibili: **23 su
  23**. Tre **Destini condivisi nuovi** (la Quiete Tenuta, Quello che si Sa,
  le Riserve): i sei condivisi coprono i sei Temi, e ogni casa pesca da un
  pool di quattro. Lo schema ammette `observes` vuoto solo per chi guarda
  contatori, e lo dichiara.
- **La sonda dei Destini** in `run_asking_probe.gd`: livello medio dell'anno
  giocando contro tavolo di pietra, per ognuno. **CHR_00 (tavolo pescato):
  21/22 chiedono di giocare** — pareggia solo NAHR. CHR_01: 17/22; la coda
  (ALDRIC, NAHR, VAERAX, VAERAX_WATCHED, LIBERE_WATER — i custodi) è
  **taratura d'autore**, coi numeri in D-270. Due correzioni provate sulle
  varianti non hanno morso (i Consigli danno pedine e pietre anche a chi sta
  fermo) e sono state tolte, a verbale.
- Suite **549 prove / 14.765 asserzioni**; playtest **0 seggi bloccati su
  8**, misto e uniforme (il pool a quattro ridà i Destini pescati).

## 0.1.231 — Il tavolo visibile basta: la fine della Chronicle come sequenza fisica (D-269)

- **PZ-6, aperto e chiuso**: la procedura di fine Chronicle è scritta ed
  eseguibile a mano ([PROCEDURA_FINE_CHRONICLE.md](docs/PROCEDURA_FINE_CHRONICLE.md)) —
  Destini, diario, il tempo che lavora (a 50+ anni: condizioni via, rapporti
  un passo verso NEUTRAL, fatti non murati → leggende), la mappa della saga,
  la successione, il rimontaggio, il verbale d'apertura.
- **La garanzia è misurata**: `visible_table.gd` è la lista chiusa dei pezzi
  fisici, e `test_visible_handover.gd` pretende che l'era nuova nasca
  **identica** dal mondo intero e dal solo tavolo visibile — CHR_01→CHR_02 su
  tre semi, più la saga pescata CHR_00→CHR_00. La prima stesura ha già morso:
  le pedine sono del casato, non della tessera, o i padroni delle pietre si
  perdono.
- Niente motore toccato: suite **549 prove / 14.748 asserzioni**, playtest
  **0 seggi bloccati su 8**, numeri fermi allo 0.1.230.

## 0.1.230 — La controproposta del RIVENDICARE: la pedina su un beneficio o su un costo (D-268)

- **PZ-5 Fase B, e PZ-5 si chiude** (ISSUES 71): chi ha consumato un
  RIVENDICARE nell'Atto può spenderlo al primo Consiglio come
  **controproposta** — prendersi la pedina del prezzo scavalcando il primo
  OPPOSE, o rivendicare una **voce del beneficio**: se la proposta passa,
  quella voce **parla di lui** (i suoi Effect compilano col rivendicante al
  posto del proponente). Spendersi consuma il diritto: niente secondo
  dibattito.
- **Misure (100 semi, CHR_01)**: 117 controproposte, 46 benefici rivendicati
  e passati, 117 secondi dibattiti spesi → Consigli da 4,6 a **3,6 di media**
  (Verità 360→307 al misto). Il costo dell'«in primis», dichiarato: la
  taratura del quando preferire il secondo dibattito è d'autore.
- **Correzione a D-267**: il tavolo misto giocava la Fase A **senza pedina**
  — il router dei caratteri non inoltrava `choose_price` e la guardia
  `has_method` lo copriva in silenzio. Inoltro aggiunto (anche per
  `choose_counterclaim`); playtest **0 seggi bloccati su 8**, misto e
  uniforme, con le mani vive.
- Suite **545 prove / 14.723 asserzioni**; `run_price_probe` conta le
  controproposte.

## 0.1.229 — La pedina del prezzo: gli avversari scelgono il malus, e il silenzio paga (D-267)

- **PZ-5 Fase A, la forma del dibattito** (parola del committente, D-266): il
  proponente sceglie le opportunità — già così — e **gli avversari scelgono i
  malus**. I pool `cost`/`failure` dei 12 template diventano **menu di due
  voci** (riuso: disordine/debito, rancore/patto rotto); il **primo OPPOSE
  dichiarato** posa la pedina del prezzo — a posizioni note, prima degli
  impegni segreti — e dal pool scatta **una voce sola**: la sua, o la prima se
  nessuno si oppone.
- **Il silenzio paga** (regola anti-passività della roadmap): se tutti i non
  proponenti si astengono, +`silence_support_bonus` (1 nei dati, reversibile)
  al fronte Support — solo se il proponente ha messo carte. Silenzio-assenso,
  detto a verbale nel log.
- **Misure (100 semi)**: CHR_01 — 198 pedine su 451 Consigli (44%), 162
  prezzi decisi dal fronte avverso, 116 silenzi pagati; CHR_00 — 156/427
  (37%), 106, 99. Playtest: **0 seggi bloccati su 8**, misto e uniforme.
  **Gli anni scritti si muovono** (regola del gioco, come D-261): uniforme
  media 4,63→4,69, FAIL 136→147, DECISIVE 167→198 — dichiarato.
- Suite **542 prove / 14.743 asserzioni**; sonda nuova `run_price_probe.gd`.
  Resta la Fase B (ISSUES 71): la controproposta del RIVENDICARE.

## 0.1.228 — La Domanda sta sulla carta Tensione: niente mazzetti di Domande (D-266)

- **Revoca del committente** sulla strada delle carte Domanda in mazzetti
  separati (tentata nella PR #108, mai mergiata): *«nella carta Tensione ci
  sono già le domande collegate ai Tag del mondo — non c'è bisogno di fare
  ulteriori mazzetti»*. Le **12 carte Domanda escono dai dati**, con lo schema
  `question_card`, la loro mano nel dizionario dei segni (90 voci ripulite) e
  i controlli del validatore fisico dedicati; al loro posto la guardia **Tema
  senza Tensioni**.
- **La Domanda vive sulla Tensione girata**: `possible_questions` → template
  di Consiglio, com'è dal giro di D-261. Prova nuova: ogni Tensione spedita
  porta almeno una domanda (60/60). La forma del dibattito — proponente →
  opportunità e bonus, avversari → malus — è la direzione di PZ-5.
- **Costo dichiarato**: tre segni di memoria (`charter_temporary`,
  `crystal_measured`, `relic_recorded`) restano scritti-e-non-letti con nota:
  aspettano la faccia fisica delle Tensioni (ISSUES 69).
- Suite **535 prove / 14.605 asserzioni**; 100 semi: **0 seggi bloccati su
  8**, misto e uniforme, Consigli fermi al decimale dello 0.1.227.

## 0.1.227 — Dieci tessere, sessanta Tensioni, e la matematica che tiene i mazzetti vivi (D-265)

- **10 tessere, se ne pescano 6**: le sei di sempre più le quattro di PZ-2 —
  Porto Cinerino, Palude dei Canali, Isola Muta, Bosco dei Confini — con biomi
  e disegni nuovi e un segno unico stampato ciascuna. **Ogni dominio sta su
  esattamente 5 tessere**: pescandone 6, ogni dominio è sempre sul tavolo, su
  qualunque mappa — tenuto da una guardia vista mordere.
- **60 Tensioni, 10 per Tema**: 48 nuove scritte per intero, fuochi distribuiti
  sulle tessere, e due Consigli generici nuovi (del Confine, del Prezzo).
  **Ogni Tema ha candidate a fuoco libero** → mazzetti mai vuoti: **0 su 600**
  (100 semi × 6 Temi), minimo 4 carte. Terra e Fede chiudono il buco della
  Tensione sola, nei numeri.
- **Misure CHR_00 (100 semi)**: **82 mappe diverse**, **100 anni su 100
  diversi per domande**, Consigli 3-6 (media 4,24), 0 partite non concluse.
  Gli anni scritti tengono la loro mano di 12 e non si muovono di un decimale
  (0 seggi bloccati su 8).
- Di contorno: 40 testi di pesca delle carte aggiornati alla verità nuova
  (la guardia delle fonti ha morso), export a 41 fogli, BRIEF_ARTE con le
  quattro tavole nuove. Suite: **535 prove / 14.570 asserzioni**.

## 0.1.226 — Il mazzetto pieno: dentro ci sono tutte le Tensioni, e girare apre la questione (D-264)

- **Sul tavolo pescato il mazzetto è pieno**: tutte le Tensioni del Tema che
  la mappa sa reggere, non solo le aperte (seme campione: 10 carte contro 4).
  **Girare la prima carta apre la questione**: se non era in gioco entra, con
  la forma e il valore d'apertura del setup, e il verbale lo dice.
- Dichiarato: la questione entrata in corsa non entra nel sacchetto della
  Deriva dell'anno; le **Chronicle scritte restano al mazzetto delle aperte**
  e i loro numeri non si muovono di un decimale (verificato sui 100 semi).
- **Misure CHR_00, 100 semi**: Consigli 3-6, media 4,32 → **4,61** (le
  questioni entrate danno più da dibattere), 0 partite non concluse, stessa
  varietà (15 mappe / 52 tavoli / 88 anni).
- Suite: **535 prove / 12.596 asserzioni** (due nuove sul mazzetto pieno).

## 0.1.225 — La Prima Chronicle: le tessere si pescano, e nessuno scrive lo scenario (D-263)

- **CHR_00 — La Prima Chronicle**, e l'app si apre da lì: niente scenario. Le
  **tessere della mappa si pescano** (`region_pool`, 4 su 6, dado derivato dal
  seme), le case si pescano (D-213), i mazzetti si mischiano (D-261), e l'anno
  fa **solo le domande che la mappa sa reggere** (dominio e segni di fuoco su
  una tessera uscita — la grammatica adattiva di D-262 fa il resto da sola).
- **Le tessere pescate si posano accostate** (le isole del grafo ristretto si
  ricuciono in ordine di pesca); **ogni casa comincia sul tavolo** (chi ha i
  posti di partenza nella scatola si accampa, a giro); **nessuna tessera è
  governata da un assente**; le pietre su tessere non uscite restano nella
  scatola. **La mappa è della saga**: l'era ereditata si rimonta sulle tessere
  della prima, qualunque seme la apra (CHR_00 è il seguito di sé stessa).
- **Misurato su 100 semi** (`run_map_probe.gd`, sonda nuova): **15 mappe
  diverse su 15 possibili**, 52 tavoli, 88 anni diversi per domande, Consigli
  3-6 (media 4,32), **0 partite non concluse**.
- **Il cancello tiene sugli scenari scritti**: 0 seggi bloccati su 8, misto e
  uniforme. Consigli mossi d'un soffio (4,59→4,62 / 4,66→4,63) dal padrone
  assente che non governa più — dichiarato in D-263.
- **Difetto preesistente scovato**: tre sistemi rileggevano la Chronicle
  vergine invece di quella risolta; ora la mappa si itera dal mondo, che è la
  verità.
- Suite: **533 prove / 12.578 asserzioni** (sei nuove sul tavolo pescato).

## 0.1.224 — La grammatica adattiva: il contenuto non nomina più un posto per id (D-262)

- **Fase B della direzione a tessere**: le 23 occorrenze di id fissi nel
  contenuto (8 fra Conseguenze e template, 15 carte Echo) sono riscritte a
  **segni** — `$region_with:granary`, `$region_with:capital`, … — e ogni
  tessera ha un segno unico stampato che la nomina (`mine` è il solo nuovo,
  sulle Miniere Antiche).
- **`$entity_with:<segno>`** (nuovo, gemello di `$region_with`): la prima casa
  del tavolo che porta il segno **vivo**; nessuno lo porta → la clausola
  compila a niente, senza errore (D-106). **`requires_entity_tag`**: il drago
  non si chiama più `ENT_VAERAX`, si chiama *chi porta #dormiente* — e
  l'etichetta `sleeping` da colore muto diventa letta, dichiarato nel
  dizionario.
- **Guardie viste mordere**: id di Regione vietati nel contenuto (difetto
  piantato → rosso → ritirato); `$entity_with` validato come binding; i
  selettori contano come **letture** nel censimento — trovate subito due mani
  non dichiarate (`crystal_site`, `trade`) su selettori di D-033 mai contati.
- **La controprova**: playtest 100 semi **identico alla virgola** a D-261
  (3-6 Consigli, medie 4,59/4,66, Verità 355/348, 0 seggi bloccati su 8): la
  riscrittura cambia cosa il contenuto dice, non cosa fa — finché la mappa
  non cambia, che è il punto.
- Suite: **527 prove / 12.398 asserzioni** (cinque nuove sulla grammatica).

## 0.1.223 — I sei mazzetti: gettoni coperti, la carta che si gira, e il secondo dibattito (D-261)

- **La regola del committente, per intero**: i sei Temi sono sei **mazzetti di
  Tensioni**, mischiati a inizio partita e coperti. La Risonanza fa cadere
  gettoni **coperti** (sacchetto `[0,1,1,2]`) sul mazzetto del suo Tema; **al
  secondo segnalino la prima carta si gira** e il tavolo sa quale Tensione si
  va scaldando; a fine Atto i mazzetti si rivelano, il più alto porta al
  Consiglio la sua carta girata, e chi ha consumato un RIVENDICARE apre **il
  secondo mazzetto più alto** (ripiego: la questione nominata — la cura terza
  di ISSUES 53). Poi i mazzetti si spendono.
- **Il nove è sparito per costruzione**: al massimo due Consigli per Atto.
  Misto 3-6 (media 4,59), uniforme 3-6 (media 4,66) — l'anno peggiore era 9.
  Verità da 373 a 355/348: un anno più corto di parole, scritto. **0 seggi
  bloccati su 8**, misto e uniforme.
- **Il dado dei mazzetti è suo** (lezione di D-150 pagata di nuovo): derivato
  da seme e sequenza degli Effetti. Le storie a seme fisso (`plan_d_crown_calls`)
  sono tornate byte per byte, senza ribasare.
- **Due trappole trovate dalle guardie**: la ripesca di D-079 smontava i
  mazzetti dell'era di libreria (`test_library_balance`), e il primo Consiglio
  azzerava il diritto del secondo — cento anni a tre Consigli esatti, detto
  dal playtest.
- Suite: **522 prove / 12.385 asserzioni**. Sonda: 1.066 Risonanze in 100 anni
  (10,7/anno), 365 col ponte, aggravate 7,2% — contate per giocata, non per
  gettone.

## 0.1.222 — Il Calore diventa una pista, e la pista sceglie la Domanda dell'Atto (D-260)

- **PZ-1 della roadmap, aperto e chiuso**: il Calore è **stato del mondo** —
  `theme_heat`, sei Temi, un segnalino 0-6 ciascuno — mosso solo per Effect
  (`ADJUST_THEME_HEAT`, inverso esatto, tetto a sei) e firmato dalla Risonanza.
- **La pista sente quello che il ponte perdeva**: 100 anni a tavolo misto,
  **1.056 Risonanze (10,6/anno)** contro le 364 che arrivavano alle Tensioni —
  due su tre cadevano nel vuoto quando il Tema non aveva questioni in gioco.
  La Terra passa da 1,4% a **3,4%** del Calore; e salta fuori che **l'Antico si
  scalda dalla mano una volta su 1.056** — scritto, non curato (materia d'autore,
  ROADMAP §4.5).
- **A fine Atto la Domanda è quella del Tema più caldo**, a parità l'ordine
  stampato, con discesa se il Tema non ha niente di apribile; il mucchio più
  alto resta come **ripiego dichiarato** a pista fredda. Il Tema che ha parlato
  torna a zero; gli altri tengono il loro. Salita/discesa/fine Chronicle sono
  configurazione reversibile: la taratura è d'autore (ROADMAP §4.1).
- **Il prezzo, dichiarato**: Consigli a tavolo misto 3-8 media **4,87** (era
  5,05), uniforme 3-9 media **5,31** (era 5,26) — il nove resta nove. Verità
  scritte da 384 a **373**. Il vincolo tiene: **0 seggi bloccati su 8**, misto
  e uniforme.
- **Lo schermo non mente**: riga `CALORE` nel pannello delle domande, e il
  marcatore «va al Consiglio» diventa «il mucchio più alto» quando è la pista
  a scegliere. `run_resonance_probe` conta dalla pista, col ponte a parte.
- Suite: **520 prove / 12.321 asserzioni** (otto prove nuove sulla pista, e il
  round-trip dell'Effetto nuovo preteso dalla guardia dell'enum).

## 0.1.221 — I segni diventano un dizionario, e la guardia lo legge (D-259)

- **PZ-0 della roadmap, aperto e chiuso**: i segni sono una collezione
  dichiarata — `godot/data/tags/tags_core.json`, **171 voci**, una per ogni tag
  che i dati toccano. Ogni voce dice il **nome stampato**, la **categoria**
  (luogo/funzione/stato/memoria/entità), l'**ambito** e **chi la scrive e chi la
  legge**, per collezione. Fuori restano solo i livelli di rapporto: gradini,
  non segni.
- **Il validatore fisico legge l'ambito dal dato invece di dedurlo**, e la
  deduzione è diventata la controprova: sei controlli nuovi (segno fuori dal
  dizionario, voce morta, ambito che non combacia, mani non dichiarate o
  inventate, muto/fantasma senza ragione, #cancelletto senza voce) e un
  `--self-test` che pianta **cinque difetti** e pretende il rosso, in CI.
- **Lo stesso segno aveva fino a tre nomi** (carta, app, pietra): il nome
  canonico è quello della carta fisica, le altre forme sono congelate in
  `aliases` come divergenza dichiarata. Riunificarle è ISSUES 70.
- **Ventidue segni guadagnano un lettore che il censimento non contava**
  (`focus_region_tags` delle Tensioni — il buco di D-234, richiuso anche qui) e
  il `when_also` delle regole composite adesso conta.
- **La lista `DICHIARATI` del validatore va in pensione**: le ragioni dei 34
  segni senza lettori (e 1 senza scrittori) vivono nelle `note` delle voci,
  accanto al segno che giustificano.
- **Numeri invariati dove dovevano esserlo**: suite verde (512 prove, 12.290
  asserzioni), playtest su 100 semi **0 seggi bloccati su 8** a entrambi i
  tavoli, Consigli misto 3-8 e uniforme 3-9.

## 0.1.220 — Quarantotto carte su quarantotto, e tre volte cieco (D-258)

- **Tutte le carte hanno una faccia fisica**: 48 su 48, ognuna con bersaglio a
  segni, due Azioni fra cui scegliere, Risonanza obbligatoria e uso in Consiglio.
- **Le Risonanze passano da 163 a 364 in 100 anni — da 1,6 a 3,6 per anno.** Il
  difetto che D-257 aveva dichiarato («1,6 volte l'anno è un episodio, non una
  regola») era il pilota, non la regola.
- **Correzione a D-257**: il «la metà condizionale non scatta mai, 0 su 163» era
  **un numero sbagliato**. La sonda contava le aggravate dai segni lasciati sulla
  mappa, e quasi tutte le carte aggravano solo il Calore. Contata bene: **10,2%**.
- **Il difetto vero era più piccolo e più preciso**: delle sei azioni **solo
  MUOVERE e TRAMARE nominano una Regione**, e sei carte su dodici facevano
  INFLUENZARE, FORGIARE o RIVENDICARE temendo un segno che vive solo sulla mappa.
  Domanda fatta al vuoto.
- **Un controllo nuovo nel validatore** lo dice per nome: *«la carta fa CLAIM, che
  non nomina REGION, e teme `condition:indebted` che vive solo lì. Non scatterà
  mai.»* È la differenza fra una regola scritta male e una regola che non c'è.
- **È la quarta volta di fila che uno zero di questo progetto era la sonda e non
  il gioco**, ed è a verbale come lezione.
- **Il Calore, dove finisce**: Potere 28,6%, Vie 28,3%, Fede 21,7%, Sopravvivenza
  20,1% — e **Terra 1,4%**, che resta il buco aperto.
- **Il prezzo non è peggiorato**: col tavolo uniforme l'anno peggiore resta a nove
  Consigli, come in 0.1.219; a tavolo misto la forma dell'anno tiene a 3-8.
- **`docs/CATALOGO_CARTE.md` stampa adesso la carta vera**: bersaglio, le due
  Azioni, la Risonanza con la sua parte aggravata, e quanto vale al Consiglio. È
  il documento che si porta in tipografia.
- **Una prova che aveva smesso di provare**, corretta: cercava fra le carte
  spedite una senza faccia e, finita la conversione, passava a vuoto. E un
  `ENT_ALDRIC` scritto a mano non esisteva nel roster pescato col seme, così le
  asserzioni passavano su un mondo dove non era successo niente.
- Suite **512 prove / 12.289 asserzioni** verdi, cancelli verdi, playtest 100 semi
  **0 seggi bloccati su 8** ai due tavoli.

---

## 0.1.219 — Il mondo risponde (D-257)

- **La Risonanza succede.** Giocare una carta con una faccia fisica scalda il
  Tema scritto sulla carta: sale la questione più vicina alla soglia di quel
  Tema, come Effetto con inverso. È la regola al centro della direzione fisica —
  *ogni Azione ha una reazione, e non si sceglie* — e fino a ieri era scritta e
  non succedeva.
- **La Risonanza avvicina, non decide**: non tocca una questione già arrivata
  alla soglia e non le dà mai il punto che la apre. Senza, la reazione del mondo
  sarebbe il modo più economico di convocare un Consiglio.
- **La Risonanza si firma** (`kind: "resonance"` con l'id della carta): chi legge
  il verbale distingue quello che il giocatore ha scelto da quello che il mondo
  ha risposto. Serve al cronista prima che alle sonde.
- **Una storia scritta a mano è cambiata**, ed è la prova che la regola si sente:
  in `plan_d_crown_calls` il Censimento scalda Potere due volte, la Successione
  arriva al punto prima, e il gesto decisivo si sposta dalla quinta domanda alla
  quarta. Piano ribasato con la ragione scritta dentro.
- **Zero, di nuovo, ed era di nuovo la sonda**: `run_resonance_probe.gd` ha
  contato **0 Risonanze su 20 anni** mentre avvenivano — cercava un `template`
  che la sorgente di un Effetto non ha mai avuto. La cura non è stata aggiustare
  la sonda: è stata far firmare la Risonanza.
- **Quanto si sente**: **163 Risonanze in 100 anni, 1,6 per anno**. Troppo poco,
  e la causa non è la regola ma il pilota — dodici carte su quarantotto.
- **Due zeri veri, scritti**: la metà condizionale della Risonanza **non scatta
  mai (0 su 163)**, e i Temi **Antico e Terra non ricevono Calore**.
- **Il prezzo, dichiarato**: col tavolo uniforme l'anno peggiore dei cento passa
  da **otto Consigli a nove**. Tre tentativi di riportarlo a otto non hanno
  spostato il numero.
- Suite **511 prove / 11.254 asserzioni** verdi, cancelli verdi, playtest 100 semi
  **0 seggi bloccati su 8** ai due tavoli.

---

## 0.1.218 — La grammatica fisica: il ponte, non la riscrittura (D-256)

- **Cambio di direzione**: ECHOES è un gioco da tavolo con un'app di supporto,
  non un gioco digitale con dei segnalini. Questa versione aggiunge una **faccia
  fisica** accanto a quella che il motore già legge — non riscrive niente.
- **Il primo fatto**: la direzione chiede **sei Temi**, i dati ne avevano
  **quattro**, e non erano quelli. *La Successione era classificata TERRITORY*;
  **Potere e Fede non esistevano affatto**. Ogni Tensione porta adesso il suo
  `theme` — e due Temi su sei ne hanno una sola, il che è scritto e non nascosto.
- **Sei Temi come dato** (`schema/theme.schema.json`), non come raggruppamento
  del codice.
- **Dodici carte convertite**, due per famiglia: bersaglio **a segni** (mai il
  nome di una Regione), **due Azioni** fra cui scegliere, una **Risonanza
  obbligatoria**, e l'uso in Consiglio.
- **Dodici Domande fisiche** (`schema/question_card.schema.json`), due per Tema,
  ognuna legata al Consiglio da cui nasce: **è il ponte** fra le due grammatiche.
- **Otto Destini** dicono adesso il Tema che inseguono, i segni che guardano e
  tre righe leggibili al tavolo.
- **`tools/validate_physical.py`**, in CI: segni muti, segni fantasma, Domande
  che si aprirebbero sempre, carte senza Risonanza, Temi senza mazzo. Provato su
  tre difetti piantati apposta, tutti e tre rossi.
- **Quattro segni davvero muti trovati**: si può alzare una **reggia**, un
  **castello**, un **archivio** o una **biblioteca** e nessuna carta, Domanda o
  Destino li guarda. Adesso due Domande li leggono.
- **Un buco nel cancello, chiuso**: la prima stesura contava «letto» un segno
  elencato sotto un Tema. Un Tema è una cartella, non un lettore — così com'era,
  la guardia si sarebbe soddisfatta da sola.
- **Cosa NON fa**: il motore non legge una riga del blocco `physical`. **La
  Risonanza è scritta e non succede** — è [ISSUES 69](docs/ISSUES.md), ed è la
  voce che decide se questa direzione è vera o solo dichiarata.
- Suite **507 prove / 11.211 asserzioni** verdi, cancelli verdi, playtest 100 semi
  **0 seggi bloccati su 8**.

---

## 0.1.217 — Un obiettivo deve chiedere più di quanto il mondo dia da solo (D-255)

- **`run_asking_probe.gd`**: ogni anno giocato **due volte con lo stesso seme** —
  una col tavolo vero, una con un **tavolo di pietra** che non spende mai
  un'Occasione. Il numero che nessuno aveva: **quanto rende giocare**.
- **Il tavolo di pietra ne avverava di più**: 470 obiettivi contro 465, cioè
  **−1,1%**. E il **43,0%** di quelli avverati era già vero all'apertura, prima
  che qualcuno posasse una pedina.
- **Sei obiettivi riscritti e uno nuovo.** Le tre forme che il mondo serviva da
  solo — le assenze («non più di due cicatrici», vera all'apertura nel 100% dei
  casi), le scorte («cinque carte in mano»: accumulare **è** passare) e la roba
  già in piedi («almeno una struttura», vera nel 95%) — adesso chiedono anche
  qualcosa che nessuno regala.
- **`tension_count`** e **`relation_state` con `$any`**: due clausole nuove nate
  dallo stesso buco. Contando le clausole di tutti gli obiettivi, **INFLUENZARE
  non compariva in nessuna** e FORGIARE nemmeno — il verbo che i seggi volevano
  dire nel 79% delle intenzioni mute non aveva un solo obiettivo che lo chiedesse.
- **«Qualcosa Deve Rompersi»**, il primo obiettivo che chiede di alzare una
  questione invece di tenerla giù. La prima stesura chiedeva il contrario ed era
  al rovescio: le questioni **partono** basse, e a tenerle basse basta che
  nessuno giochi — misurato, 38 su 43 col tavolo di pietra contro 12 giocando.
- **Gli obiettivi arrivano alla scelta dell'azione.** D-222 li aveva messi in
  `_conditions()` scrivendo che «da qui l'obiettivo entra nella scelta
  dell'azione»: non era vero. Quella scelta legge `_open_levels()`, che tornava
  solo i gradini del Destino. Adesso gli obiettivi sono l'ultimo scalino — ma
  **non convocano Consigli**: con quella lettura accesa la Chronicle 4 passava a
  nove Consigli in due anni su dodici, sopra il limite duro di otto.
- **I numeri**: quanto rende giocare da **−1,1% a +86,2%** (uniforme +72,4%),
  avverati già veri all'apertura dal **43,0% al 14,0%**, turni «passa» dall'**85,7%
  all'82,8%**, «nessuna mossa gli serviva» dal **64,9% al 58,7%**.
- **Non basta, ed è scritto**: [ISSUES 68](docs/ISSUES.md#68) resta aperta, e le
  intenzioni che la mano non sa dire **crescono** da 2.152 a 2.422 — il cervello
  vuole più spesso, e il fronte successivo è il mazzo.
- **`test_every_verb_has_a_reason.gd`**: va rosso il giorno che un verbo del gioco
  resta senza nessun obiettivo che lo chieda.
- Suite **500 prove / 10.809 asserzioni** verdi, cancelli verdi, playtest 100 semi
  **0 seggi bloccati su 8** ai due tavoli.

---

## 0.1.216 — Cosa era disponibile e non è stato preso (D-254)

- **`run_pass_probe.gd`**: un testimone accanto a chi decide. Quando la risposta è
  «passa», gli chiede **perché** ramo per ramo, e chiede alle regole quante mosse
  gli lascerebbero fare.
- **Su 7.200 turni, 85,7% sono «passa»** — e peggiora andando avanti nell'anno:
  77,9% → 88,9% → **90,2%**.
- **Due cause escluse con un numero**: zero passa su 6.168 avevano zero mosse
  legali (media **15,5**), dodici avevano la mano vuota (media **6,5 carte**).
- **Le tre cause vere**: 64,9% nessuna mossa gli serviva, 20,1% pesca sbagliata,
  14,8% bersaglio sbagliato. Il verbo che vuole e non sa dire è INFLUENZARE nel
  **79%** dei casi.
- Apre **[ISSUES 68](docs/ISSUES.md#68)**, che assorbe ISSUES 59 e 60: non
  mancano carte né regole, manca la ragione per agire.
- Nessun dato e nessuna regola cambiati: è una misura. 492 prove / 10.759
  asserzioni verdi, playtest 100 semi **0 su 8**.

---

## 0.1.215 — La cronaca era nera perché il testo non veniva disegnato (D-252, D-253)

- **D-252 — «le cronache ancora nere.»** D-248 aveva curato il sintomo
  sbagliato: aveva trovato una cosa vera (la pagina rasterizzata a 3175×4490) e
  l'ho chiamata *la* causa **senza verificare che dopo ci fosse qualcosa da
  vedere**.
  - **Il numero**: contati i pixel, **0 su 200.941** sono diversi dallo sfondo.
    Il rasterizzatore SVG di Godot **non disegna il testo**, e una cronaca è
    sola prosa.
  - Ora `ChronicleBook` sa dire le pagine **impaginate e non disegnate**, e lo
    schermo le scrive con Godot. Stessa impaginazione della stampa: una prova
    verifica che contino lo stesso numero di pagine.
  - **E la prova mentiva per la seconda volta**: guardava il codice d'uscita del
    rasterizzatore, non l'inchiostro. Adesso guarda le righe.
- **D-253 — «la saga continua all'infinito, dovrebbe fermarsi a 10 partite.»**
  Il numero era già nei dati (`saga_scoring.decides_after` = 10) e già letto dal
  verbale; la porta dell'era successiva non lo guardava. Ora sì.
- **Misurato**: 492 prove / 10.758 asserzioni verdi (da 489 / 10.747), cancelli
  verdi, sim verdi, export e cataloghi allineati, playtest 100 semi **0 su 8**.

---

## 0.1.214 — La colonna di lato spingeva la mano fuori dallo schermo (D-251)

- **«Le carte sono quasi sparite del tutto.»** Non erano piccole: erano **sotto
  il bordo della finestra**.
- **Misurato**: la colonna di destra chiede **763 px** di altezza minima; la
  finestra ne aveva **726**. Una colonna che chiede più della pagina non si
  stringe — spinge giù tutto quello che le sta sotto, e sotto c'è la mano.
- La colonna di stato ora sta dentro un pannello che **scorre**, e i due
  tarocchi del Destino passano da 130×222 a 80×138.
- **Tre prove**, e la prima rende il rischio un fatto: la colonna *può* chiedere
  più di 600 px, quindi non può stare in una pagina che non scorre.
- **Misurato**: 489 prove / 10.747 asserzioni verdi (da 486 / 10.741), cancelli
  verdi, sim verdi, cataloghi allineati, playtest 100 semi **0 su 8**.

---

## 0.1.213 — Il testo che si tagliava, la pagina troppo grande, e un file per fare le carte

- **D-246 — «le carte sono tagliate e non c'è scritto nulla sopra.»** Erano la
  stessa frase: il testo che D-242 aveva aggiunto sta **sotto** l'immagine, e di
  una carta troppo alta si taglia il fondo. Ora le misure si sommano invece di
  essere indovinate, il titolo si ferma a due righe, e **la mano chiede alla
  carta quanto è alta** invece di ripetere il numero in un altro file.
- **D-247 — «non c'è un testo che dice a chi tocca.»** Ora, sopra le domande:
  **ATTO 2 di 3 · ROUND 1 di 3**, *«Tocca a Kessa — 2 azioni»*, e quando finisce
  l'Atto. Tutto derivato dal mondo.
- **D-248 — «la cronaca dell'anno è sempre una pagina vuota.»** Non era vuota:
  era rasterizzata a **3175×4490** (54 MB), oltre il massimo che un tablet
  accetta. Ora si misura prima e si ingrandisce quanto ci sta: 1131×1599. **E
  la prova che diceva «ogni pagina si rasterizza» era verde perché disegnava a
  una scala diversa da quella dell'applicazione.**
- **D-249 — un file solo per fare una carta.**
  [CATALOGO_CARTE.md](docs/CATALOGO_CARTE.md): **87 carte** con descrizione,
  effetti, valori e il prompt per l'immagine, più i **64 pezzi** della mappa —
  pietre coi loro gradi e le loro rovine, condizioni, cicatrici, pedine,
  vessilli. Generato da tre sorgenti diverse, con un cancello in CI.
  - Il documento ha trovato un difetto scrivendosi: `scar:burned_records` usciva
    col proprio id, perché la posa la **rovina di una pietra** e non un Effetto.
- **D-250 — «la saga si ferma alla seconda partita.»** Il motore è escluso: la
  catena vera gira pulita per quattro Chronicle. Non sono riuscito a riprodurlo
  guidando la schermata in headless, quindi **non scrivo una diagnosi che non
  ho**. Corretto lo stesso un difetto reale sulla stessa riga: l'apertura
  dell'era successiva **ignorava il fallimento di `setup`**, e un fallimento
  silenzioso ha la stessa faccia di un blocco. Ora lo dice.
- **Misurato**: 486 prove / 10.741 asserzioni verdi (da 483 / 10.727), cancelli
  verdi, sim verdi, export e cataloghi allineati, playtest 100 semi **0 su 8**.

---

## 0.1.212 — L'app si apre e si gioca (D-245)

- **«Non deve chiedere nessuna saga.»** D-241 aveva ridotto la domanda da
  quattro voci a due invece di toglierla: una domanda meno sbagliata scambiata
  per una domanda risolta. Ora il menu non chiede niente — si apre l'app e si
  gioca.
- Il tempo che passa si racconta **dove è passato**: a fine Chronicle, dove il
  gioco offre già l'era successiva (D-095).
- **Il prezzo, scritto perché è reale**: la seconda saga (CHR_03) non si
  raggiunge più dal menu. È [ISSUES 66](docs/ISSUES.md#66), e la decisione è
  d'autore.
- **Misurato**: 483 prove / 10.727 asserzioni verdi, cancelli verdi, sim verdi,
  playtest 100 semi **0 su 8**.

---

## 0.1.211 — La pagina si legge col dito (D-242, D-243, D-244)

- **D-242 — «le carte sono minuscole e non si capisce cosa fanno.»** Una carta
  era 110 pixel di figurina con un numero sotto: nome, verbo, costo e frase
  d'autore vivevano tutti nel **suggerimento del mouse**, che su un tablet non
  esiste. Ora la carta è 150 pixel e porta **sulla faccia** il proprio nome e il
  proprio verbo; presa in mano, la colonna accanto ne scrive la lettura intera.
- **D-243 — «le domande dell'anno sono ancora con le vecchie regole.»** Alla
  lettera: la riga scriveva `12/18` verso una **soglia che da D-214 non apre più
  niente** — e tutte e quattro le Chronicle della scatola tengono il Consiglio a
  fine Atto. Ora il conto è **relativo**: la barra si misura sul mucchio più
  alto e la domanda davanti scrive *«va al Consiglio»*. Dove la soglia è ancora
  viva, la riga la dice: la pagina segue i dati.
- **D-244 — «le due carte destino cosa servono?»** Erano due figure grandi e
  mute. Ora dicono **CHI SEI** e **COSA VUOI**, col nome sotto.
- **Il filo comune**, scritto a verbale: il tooltip è un posto dove il testo va a
  morire su metà dei dispositivi che esistono. Tre difetti, una sola forma.
- **Misurato**: 482 prove / 10.724 asserzioni verdi (da 477 / 10.560), cancelli
  verdi, sim verdi, export e catalogo allineati, playtest 100 semi **0 su 8**.

---

## 0.1.210 — Il tavolo su un tablet (D-239, D-240, D-241)

Tre correzioni, tutte e tre trovate giocando davvero — l'unico modo in cui
questa parte del gioco si misura.

- **D-239 — «su iPad il drag & drop non funziona.»** È vero e non è un difetto
  da sistemare: su un touchscreen il dito che preme e scorre **fa scorrere la
  pagina**. Il gesto va diviso in due tempi — si tocca la carta (si alza, e si
  accendono tutti i posti dove può andare), si tocca il posto. È come si fa al
  tavolo vero. Il trascinamento resta intero per chi ha un mouse.
  - Il conflitto con D-236 è sciolto: con una carta in mano la riga della
    domanda **posa**, a mani vuote **apre la scheda**. I due gesti non convivono
    mai.
  - `emulate_mouse_from_touch` è ora scritto in `project.godot` invece di essere
    un valore implicito.
- **D-240 — «le pedine e cicatrici non si capiscono e sono troppo piccole.»** Due
  difetti in una frase. Un pezzo era **17 pixel** (ora 26). E la parola che lo
  nomina si scriveva solo per le Regioni *raggiungibili*: fuori da una scelta
  **non compariva quasi mai**, e su un tablet — dove non esiste il passaggio del
  cursore — non sarebbe comparsa mai. Ora il tocco su una Regione vale come
  guardarla, e la nomina.
- **D-241 — «chiede ancora quale anno voglio giocare.»** Il menu offriva tutte e
  quattro le Chronicle, ma **due sono il seguito** di un'altra e si raggiungono
  giocando. E la domanda era quella sbagliata: una saga si **comincia**, e gli
  anni vengono da soli. Ora chiede *«Da quale saga cominci?»* e offre le due
  aperture.
- **Misurato**: 477 prove / 10.560 asserzioni verdi (da 469 / 10.541), cancelli
  verdi, sim verdi, export e catalogo allineati, playtest 100 semi **0 su 8**.

---

## 0.1.209 — Il bottone che rendeva invisibile il trascinamento (D-238)

- *«L'interfaccia non è cambiata, sembra tutto uguale a prima.»* Il committente
  aveva ragione, e non era la cache del browser: **era il codice**.
- Da D-230/D-231 una carta si trascina su una Regione, una domanda o una casa —
  ma la colonna delle scelte **stampava comunque un bottone per ognuna**, tranne
  quelle che vivevano su una Regione. Il trascinamento esisteva e non serviva a
  niente: accanto c'era sempre il modo vecchio.
- **Adesso la colonna tiene solo quello che non ha un posto dove cadere**:
  passare, lasciar decidere alla policy, una trama che non parla di niente di
  visibile.
- **E il clic sulla carta** fa il primo dei due movimenti che il committente
  aveva descritto — *«si seleziona una carta, si decide come usarla»* — e serve
  da porta di servizio: un trascinamento che non riesce non deve rendere
  irraggiungibile una mossa legale.
- **Quattro prove**, provate al contrario. E la lezione a verbale: **il cancello
  era verde anche prima**, e sarebbe rimasto verde per sempre con una GUI che
  non si poteva usare. Questo difetto l'ha trovato una persona aprendo l'app.
- **Misurato**: 469 prove / 10.541 asserzioni verdi, cancelli verdi, playtest
  100 semi **0 su 8**.

---

## 0.1.208 — I tre coperti sono della saga, non dell'anno (D-237)

- **Chiude ISSUES 58**, ed è il punto dell'idea di partenza che il gioco aveva
  perso: *«tre segreti che si pescano all'inizio della saga»*. Si ripescavano
  ogni anno, e questo sposta l'unità dell'ambizione dalla saga all'anno — la
  campagna diventa **una somma di partite invece di una storia sola**.
- **Misurato prima di decidere**, con `run_objectives_probe.gd` che gioca le
  stesse 20 saghe da 10 Chronicle **due volte**, coi coperti dell'anno e coi
  coperti della saga. La regola sta nei dati, quindi il confronto è fra due
  dichiarazioni, non fra due versioni del codice.
- **Il costo temuto non si verifica**: all'anno 10 i tre d'apertura si avverano
  **più** spesso (23,8% → 34,5%), e quelli mai avverati scendono dal 51% al 43%.
  I livelli non si spostano (26/39/34/1 → 28/37/34/1).
- **La ragione è strutturale**: nessuno dei quindici obiettivi condivisi nomina
  una Regione o una casa. La premessa era già vera e **non la teneva niente** —
  adesso c'è una prova che va rossa il giorno che qualcuno la rompe.
- **Un limite trovato per strada**: solo il **51%** dei seggi seduti dopo
  l'apertura sono le case che hanno aperto la saga. Gli obiettivi di saga
  valgono per circa metà tavolo; l'altra metà pesca i propri. È
  [ISSUES 64](docs/ISSUES.md#64), scritta invece che scoperta dopo.
- **Misurato**: 465 prove / 10.532 asserzioni verdi, cancelli verdi, playtest
  100 semi **0 su 8** — e va detto che il playtest gioca una Chronicle sola,
  quindi lì passa per costruzione: la misura che conta è quella delle saghe.

---

## 0.1.207 — Si gioca all'app: la scheda della domanda sta sullo schermo (D-236)

- **Decisione del committente**: per adesso il mezzo è l'app, il cartone si
  vedrà poi. È la risposta che ISSUES 62 aspettava — l'app resta l'arbitro, con
  una scadenza aperta invece che con una rinuncia.
- **Quello che ne segue subito**: se lo schermo è il tavolo, la scheda della
  domanda deve stare sullo schermo. Fino a qui le proposte comparivano una riga
  alla volta **a Consiglio già aperto**, cioè quando decidere è tardi.
- **`ui/council_sheet.gd`**: un clic sulla riga di una domanda apre la sua
  scheda — cosa si potrà proporre, quando, e **cosa lascia al mondo** ogni
  Conseguenza, una riga per Conseguenza col suo nome.
- **La voce, che era il punto delicato**: la prima stesura usava le bindings del
  Consiglio *aperto*, e una scheda si legge proprio quando il Consiglio non è
  aperto — mostrava `$region_focus`. Adesso riempie con quello che il mondo sa e
  **spiega** il resto: «Chi manda gli uomini a scavare nella Valle Verde?».
- **Diciannove segni del mondo senza una parola**, trovati perché la pagina li
  ha messi sotto gli occhi: il censimento di D-107 guardava Regioni e case, non
  il mondo, e non guardava le clausole. Adesso li guarda.
- **Quattro «scoperte» uscivano col proprio id** (`scoperta: trade_ledger`): il
  ripiego per prefisso le faceva passare per note. Una prova nuova rifiuta una
  parola che contiene il proprio id.
- **Misurato**: 462 prove / 10.496 asserzioni verdi (da 457 / 8.532), cancelli
  verdi, export e catalogo allineati, playtest 100 semi **0 su 8**.

---

## 0.1.206 — Le Conseguenze mute erano dieci, sono tre (D-235)

- **ISSUES 56 misurata di nuovo** con `run_consequence_probe.gd`: un testimone
  si siede in mezzo al Consiglio, inoltra ogni domanda a chi decide e scrive
  cosa gli è stato offerto e cosa ha scelto.
- **Due errori di misura corretti**, tutti e due nella direzione che fa sembrare
  il gioco più rotto di quanto sia: contavo in Consigli quattro Conseguenze che
  **arrivano da una carta Echo** e non passano da lì; e misuravo **anni
  scollegati** mentre tre proposte chiedono una **leggenda**, che nasce solo
  quando fra due anni giocati passano decenni.
- **Il numero vero**: 7 su 52 in 200 anni scollegati, **3 su 52** in 200 anni di
  saga (20 saghe da 10 Chronicle).
- **Le tre restanti, con tre cause diverse**: il Drago ha la porta in una sola
  carta del mazzo e in 200 anni non si è mai allineata (19 esclusioni su 19); «Il
  Raccolto Torna» è stato pescato 173 volte e calato zero (fa bene al mondo e
  niente a chi lo cala); «La Parola Data» 183 volte e zero (chi la gioca paga
  tre volte e non incassa).
- **Due categorie della voce sono vuote**: «mai scelta» e «sempre perdente» non
  esistono più in saga. Ne compare una che la voce non prevedeva: **la carta che
  nessuno ha una ragione di giocare**.
- Nessun dato e nessuna regola cambiati: questa è una misura.

---

## 0.1.205 — Quattro dei dieci segni muti non lo erano mai stati (D-234)

- **Chiude ISSUES 61.** La voce chiedeva di misurare prima di decidere: la sonda
  `run_mute_signs.gd` conta quante volte ogni segno muto esce in 100 anni.
- **La sonda cercava un nome che sul mondo non esiste**: `settlement:$proponent`
  è la forma *scritta*, sul mondo finisce `settlement:ENT_NAHR`. La prima
  lettura diceva 0 — e zero è la risposta più pericolosa che una sonda possa
  dare. Il numero vero è **50 volte, in un anno su due**.
- **Il registro aveva un buco**: non guardava tre penne che leggono — di quale
  Regione parla il Consiglio (`focus_region_tags`), **chi siede l'anno prossimo**
  (`entry_tag`), e la catena delle ere (`if_tag`). Sono i morsi più forti del
  gioco, e li chiamava silenzio.
- **Quattro dei dieci mordevano già**: `condition:contested` (132 scritture),
  `heir_named` (98 — è la porta di Aldric Restaurato), `condition:lean` (12),
  `condition:requisitioned` (7).
- **I sei che restano sono dichiarati con la loro frequenza**: `settlement:<casa>`
  50, `water_rights` 18, `succession_settled` 14, `account_settled` 4,
  `burden_shared` 2, `dragon_slain` **mai** (è ISSUES 56 che parla).
- **Una clausola impossibile trovata e chiusa**: `scar:burned` — la Successione
  preferiva una Regione bruciata e **nessuna Regione poteva bruciare**. Adesso
  preferisce `scar:the_empty_chair`, che una Conseguenza scrive davvero.
- **Un cancello nuovo**: `--check` va rosso su una clausola impossibile come già
  faceva su un muto non dichiarato. Provato al contrario.
- **Misurato**: 457 prove / 8.531 asserzioni verdi, cancelli verdi, sim verdi,
  export e catalogo allineati, playtest 100 semi **0 seggi bloccati su 8**.

---

## 0.1.204 — La proposta dice cosa lascia al mondo (D-233)

- **Chiude il quarto passo di ISSUES 63** e la metà-schermo di ISSUES 62. Chi
  propone sceglieva fra tre frasi d'autore che si somigliano, e **cosa
  scrivevano sul mondo stava in un file di dati**: una torre, un padrone che
  cambia, una cicatrice. È la decisione centrale del gioco, e si prendeva al
  buio. Lo stesso per le clausole.
- **Due letture, una sorgente**: la scheda stampata e la riga sullo schermo
  escono dalla stessa funzione di D-232 e cambia solo **la voce** — fuori dal
  tavolo un buco si spiega, al tavolo lo riempie la partita col nome vero. Il
  catalogo non è cambiato di una riga, e il cancello di deriva lo conferma.
- **Una scelta si disegna come una carta**: la prima riga è quello che si dice,
  sotto in grigio più piccolo quello che resta. Sotto rimane un `Button`, che sa
  già cosa vuol dire il fuoco della tastiera e Invio.
- **Il silenzio non è una terza possibilità**: se una proposta non lascia niente
  lo dice. Misurato: **43 proposte su 43 lasciano qualcosa**.
- **Tre prove per i tre tratti** — la riga, il disegno, e il filo in mezzo che
  li unisce: due su tre sarebbe lo stesso buco di D-224. Provate al contrario.
- **Misurato**: 457 prove / 8.530 asserzioni verdi (da 454 / 8.299), cancelli
  verdi, sim verdi, export e catalogo allineati, playtest 100 semi **0 seggi
  bloccati su 8** a tavolo misto e uniforme.

---

## 0.1.203 — Il Consiglio esce dal database: le proposte in italiano (D-232)

- **Il pezzo che serve a tutte e tre le forme di ISSUES 62.** Scheda per
  Tensione, libretto o app-arbitro: la scelta resta d'autore, ma tutte e tre
  chiedono prima **lo stesso materiale leggibile**, e quello si poteva fare.
- **`council_text.gd`**: 13 legami che traducono i buchi delle frasi d'autore —
  `$proponent`, `$rival`, `$region_focus` — nel **ruolo** che avranno al tavolo,
  invece di riempirli con un valore che una scheda non può conoscere.
- **Il ricalco più lungo prima**: `$region` è un prefisso di `$region_focus`, e
  un ordine qualunque avrebbe scritto «la Regione\_focus».
- **Una Conseguenza dice cosa lascia al mondo** riusando le parole che D-228
  aveva già scritto per le carte, invece di aprire una seconda traduzione. Per
  farlo `AssetText.COSTS` ha imparato i cinque tipi di Effetto che **solo** le
  Conseguenze usano.
- **La prova che ha morso**: una condizione nel database diceva *«...la carta di
  Propp e' la porta (D-127)»* — una nota di lavorazione stampata su un
  componente. Adesso quella riga dice quello che serve a chi gioca.
- **[CATALOGO_CONSIGLI.md](docs/CATALOGO_CONSIGLI.md)**: 10 Consigli, 43
  proposte, 19 clausole. Generato e committato come il brief d'arte, con
  `tools/run_council_catalogue.sh` e un passo di CI che va rosso il giorno che
  qualcuno cambia una proposta e non rifà il documento.
- **Misurato**: 454 prove / 8.299 asserzioni verdi (da 450 / 8.064), cancelli
  degli strumenti verdi, export deterministico e brief allineato, playtest 100
  semi **0 seggi bloccati su 8** a tavolo misto e uniforme.

---

## 0.1.202 — I posti che non sono la mappa: una domanda e una casa diventano bersagli (D-231)

- **Chiude il terzo passo di ISSUES 63.** D-230 aveva dato al trascinamento un
  solo posto: le Regioni. Restava vero che **MUOVERE era l'unico verbo giocabile
  con la mano**.
- **Il pezzo mancante era di nuovo a monte**: solo MUOVERE dichiarava di cosa
  parlava. INFLUENZARE, TRAMARE e FORGIARE uscivano dal decisore **senza
  `subject`**, quindi lo schermo non poteva sapere che quella scelta riguardava
  *quella* domanda o *quella* casa.
- **`DropSlot`**: un `Control` che si mette intorno a una riga della traccia o
  della colonna dei rapporti, e da quel momento quella riga è un bersaglio. Non
  decide niente — accetta una carta esattamente quando quella carta porta una
  scelta per quel soggetto (D-039).
- **La caduta restringe, non sceglie.** Su una domanda una carta può sapere fare
  due cose opposte, alzarla e abbassarla: il posto restituisce **tutte** le sue
  scelte e la colonna si riduce a quelle. Al tavolo è così — posi la carta sulla
  domanda, e *poi* dici se la alzi. Quando invece lì sa fare una cosa sola,
  posarla **è già la mossa**.
- **La prova che tiene insieme le due metà**: *ogni soggetto di cui una carta può
  parlare ha il suo posto sullo schermo*. Se domani nasce un verbo che parla a
  una domanda e nessuno apre il posto, la carta torna a essere un bottone **in
  silenzio** — ed è il modo esatto in cui questa mossa si disferebbe.
- **Una lambda che catturava per valore**: `answered = indices` dentro una lambda
  non esce: GDScript cattura per valore. La prova era rossa per la ragione
  sbagliata — meglio di verde per la ragione sbagliata, ma costa lo stesso un
  giro.
- Suite **450 test e 8.064 asserzioni**. Nessuna regola toccata.

---

## 0.1.201 — Si prende la carta e la si lascia cadere (D-230)

- **Terzo dei quattro passi di ISSUES 63.** In `godot/ui/` non c'era un solo
  `_get_drag_data`: le azioni erano `Button.new()` da una lista di stringhe.
  Adesso si prende una carta dalla mano e la si lascia su una Regione cerchiata
  d'oro, e la presenza si sposta.
- **Il trascinamento non decide niente di nuovo**: la mappa accetta il pezzo
  esattamente dove `highlighted` dichiara raggiungibile — le scelte che le regole
  hanno già approvato (D-039). È un'altra **voce**, non un'altra regola: il
  bottone resta accanto e le due strade finiscono nello stesso `picked.emit`.
- **Il pezzo che mancava stava a monte.** `_through_the_hand` **buttava via il
  bersaglio**: una MUOVERE nasce con `subject: {"region": ...}`, e avvolgendola
  nella carta che la porta quel campo si perdeva — quindi la scelta usciva senza
  posto e non poteva stare sulla mappa. Il drag & drop non mancava per pigrizia
  della GUI: **l'informazione non arrivava fin lì**.
- **Due filtri, e servono tutti e due**: la Regione fra le raggiungibili (lo mette
  lo schermo) e una mossa *di quella carta* per quella Regione (la mette la
  carta). Una Regione raggiungibile con un'altra carta non accetta questa.
- **L'anello d'oro si accende sotto il pezzo che sta arrivando**, non solo sotto
  il cursore.
- **Sei prove senza un mouse**: il trascinamento non si prova headless, ma le tre
  decisioni che lo governano sì — cosa viaggia, dove può cadere, cosa succede
  quando cade. Il resto è Godot che sposta pixel.
- **E un errore preso dal cancello costruito in D-224**: `set_drag_preview` fuori
  da un albero scrive un errore e va avanti — la suite sarebbe rimasta verde e la
  CI rossa. L'anteprima è presentazione, il carico è decisione.
- Suite **446 test e 8.043 asserzioni**, nessun `SCRIPT ERROR`. Nessuna regola
  toccata.
- **Resta**: solo MUOVERE ha un bersaglio sulla mappa. INFLUENZARE parla a una
  domanda, FORGIARE a una casa, TRAMARE a niente di visibile.

---

## 0.1.200 — I pezzi sulla mappa: una forma si riconosce, una parola si legge (D-229)

- **Secondo dei quattro passi di ISSUES 63.** La mappa scriveva i segni come una
  fila di **parole in grigio** sotto il nome della Regione: un granaio, una torre
  di veglia e una biblioteca portavano **lo stesso identico glifo**, perché il
  glifo diceva il *livello* e i livelli sono quattro.
- **Cinque famiglie di pietra, cinque forme**: PRESIDIO una torre coi merli,
  INSEDIAMENTO tre tetti in fila, OPERA un arco su due piedi, STUDIO un libro
  aperto, LUOGO un albero. La mappa passa dalla famiglia alla forma **leggendo i
  dati**: se nasce una famiglia nuova il pezzo arriva da solo.
- **Il grado sono i punti sotto il pezzo** — uno una torre di veglia, tre una
  reggia — **e il padrone è il colore**, lo stesso della sua pedina.
- **Una cosa che ho sbagliato e la prova ha preso**: la prima stesura ricavava il
  grado dal tag, e non si può — `structure:granary` è **sia il Granaio sia il
  Grande Granaio**. Grado e padrone stanno in `region.structures`, ed è l'unica
  verità su cosa c'è e di chi è.
- **La parola solo sotto il mouse**: al tavolo una carta si legge quando la
  prendi in mano, non mentre guardi la plancia.
- **Tre nomi uscivano in inglese** — sulla mappa si leggeva «palace», «archive»,
  «forest», e per `settlement:` si stampava «insediamento: city» perché cercava
  una *casa* con quel nome. Il nome giusto era già nei dati (`grades[].name`).
- **Tre prove**: ogni segno di Regione ha un pezzo (un segno senza pezzo non è
  brutto, è **invisibile**), ogni famiglia ha un glifo e ogni grado il suo nome,
  nessun segno si legge col suffisso inglese. E la prima stesura della prima
  raccoglieva i segni solo dagli Effetti, mancando la penna che li scrive davvero
  — i gradi delle pietre — e **contava zero passando lo stesso**.
- Suite **440 test e 8.027 asserzioni**. La plancia d'apertura di CHR_01 mostra
  tre torri di veglia coi colori di Aldric, Vaerax e Ilve, e otto luoghi naturali
  in verde. Nessuna regola toccata.

---

## 0.1.199 — Una carta dice cosa fa: il verbo, e i segni con la loro parola (D-228)

- **Il committente ha guardato l'app**: *«così com'è fatto è ingiocabile, lo è
  sempre stato»*. Aperta **ISSUES 63** con i numeri: **0 file su 21** in
  `godot/ui/` implementano il drag & drop, le azioni sono `Button.new()` da una
  lista di stringhe, e la mappa disegna strutture e cicatrici come **parole in
  grigio** sotto il nome della Regione.
- **Primo dei quattro passi, fatto**: la carta dice cosa fa.
- **Il verbo, che non c'era su nessuna delle 48 carte.** La scheda portava
  famiglia, forza, modificatore, che fine fa la carta e cosa costa impegnarla — e
  mai *cosa succede se la cali*. Adesso sta in cima, sullo schermo **e sul
  cartone stampato**.
- **28 effetti su 49 parlavano in tecnico.** Sull'«Assedio» un giocatore leggeva
  davvero «costa: la domanda in gioco sale, **raze_structure**». Un tipo in
  minuscolo sembra una regola: è il nome interno di un Effetto finito su una
  carta. Adesso è «viene giù una costruzione dove si discute».
- **`SignLabels` guadagna i fatti del mondo**: trenta, che prima non aveva
  nessuno — era il buco per cui «Registro» diceva «un segno cade sul mondo»
  invece di «il mondo registra: i conti sono pubblici». E le leggende (D-225) si
  dicono col fatto dentro.
- **`effect_note` dichiara quello che non sa dire** invece di travestirlo da
  regola, così un effetto nuovo senza parole si vede subito.
- **Tre prove nuove** che tengono la prosa attaccata al dato: ogni carta nomina
  il proprio verbo, nessuna frase contiene un trattino basso (la firma di un nome
  interno), ogni segno su una carta ha la sua parola.
- **E una prova teneva fermo il difetto**: `test_effect_narrator` pretendeva che
  nella narrazione comparisse letteralmente `nahr_settled`. Adesso chiede la
  parola e **vieta l'id**.
- Suite **437 test e 7.720 asserzioni**, export a 0, `BRIEF_ARTE.md` allineato.
  Nessuna regola toccata.

---

## 0.1.198 — Il tetto delle pedine a cinque: la mappa si contende con le pedine (D-227)

- **`presence_tokens` da 4 a 5** su tutte e quattro le Chronicle. È la risposta
  alla domanda che D-226 aveva lasciato aperta, e non era dove l'avevamo cercata
  per due cicli.
- **`run_contest_probe --presence=N`**: stessi cento semi, più pedine a testa.

| pedine | il padrone passa di mano | Regioni contese a fine anno | cadono vacanti |
|---|---|---|---|
| **4** (com'era) | 2,39 | 2,46 su 6 | 1,11 |
| **5** | **2,85** | **3,72 su 6** | 0,82 |
| 6 | 2,70 | 4,23 su 6 | 0,79 |

- **Il tetto del ricambio è intorno a 2,9, e a sei pedine *scende*** — con tutti
  dentro dappertutto le posizioni si irrigidiscono. A quattro pedine eravamo già
  all'**84%** di quel massimo: da quel lato la mappa si muoveva quasi quanto le
  regole permettono.
- **La contesa invece non era vicina a niente: +51% con una sola pedina in più.**
  Ed è il numero che il committente aveva chiesto dall'inizio — *«una maggioranza
  dovrebbe essere una lotta tra entità»*. Erano **due domande dietro la stessa
  parola**: una era già quasi al massimo, l'altra a metà strada.
- **Non è un'inversione di D-211**, che non aveva scelto «quattro» ma «tre affama
  la mappa». Il numero che gli dà ragione è proprio quello: le Regioni che
  finiscono l'anno senza padrone scendono da **1,11 a 0,82**. E l'apertura non
  cambia — la quinta pedina è **riserva pura**, cioè l'asse di D-211.
- **Cinque e non sei**: a sei il ricambio peggiora e il tavolo si irrigidisce.
- **Una prova descriveva il setup invece dell'intenzione**: `test_destiny_warning`
  posava `limite − 1` pedine su tre Regioni, e col tetto a cinque Vaerax non era
  più al limite — l'avviso taceva per la ragione sbagliata. Adesso le tre Regioni
  si ripetono a giro.
- **ISSUES 55 chiusa per tre quarti.** Il quarto criterio (obiettivi contesi ≥ un
  terzo del mazzo, oggi 3 su 15) è contenuto d'autore e resta.
- Cancello per intero: playtest **0/8** su tutti e due i tavoli, suite **434 test
  e 7.522 asserzioni**, piani scriptati ed export a 0, `BRIEF_ARTE.md` allineato.
  I fallimenti sul tavolo uniforme sono **166, identici** a prima: l'economia del
  Consiglio non si muove.

---

## 0.1.197 — Il peso della terra riacceso e respinto: il Consiglio non è dove la mappa cambia padrone (D-226)

- **La mossa 0 di ISSUES 55 è stata fatta, e la misura l'ha respinta.**
  `focus_weight` (D-154) riaccesa su tutte e quattro le Chronicle.
- **Il cancello lo passa**: **0 su 8** seggi bloccati, tavolo uniforme e misto,
  100 semi dal 7000. Quindi D-154 aveva ragione sulla diagnosi — era la porta
  sola di Kessa (ISSUES 38, chiusa in 0.1.122), non il peso della terra.
- **Ma sulla cosa per cui serviva, no.** Il padrone di una Regione passa di mano:
  **2,39** volte l'anno da spenta, **2,29** con titolo+maggioranza, **2,37** con
  la sola maggioranza. Peggiora o non cambia niente — e il prima è stato misurato
  **sullo stesso albero**, non ripreso da un verbale vecchio.
- **La prima forma peggiora per una ragione che avevo scritto come rischio prima
  di misurarla**: dare voce a chi la Regione *la tiene* rende più difficile
  toglierargliela. È un referendum sul padrone.
- **E il presupposto era sbagliato, per due cicli.** `_recount_control`: **il
  padrone lo decide la contesa di presenza, round per round, non il Consiglio.**
  `rightful_holder` riconta il titolo dalle pedine; i `SET_CONTROL` scritti a
  mano sono 14 su 52 e arrivano dopo. «La mappa non si muove al Consiglio» è vero
  e non è un difetto: al Consiglio non si è mai mossa.
- **La domanda nuova, che non era mai stata posta**: con 4 pedine a testa, 4
  case, 6 Regioni e il titolo che segue la maggioranza stretta, **quante volte al
  massimo potrebbe passare di mano?** Se il tetto è vicino a 2,4 la mappa si
  muove già quanto le regole permettono, e ISSUES 55 va riscritta.
- I dati tornano com'erano: `focus_weight` resta spenta nei dati e accesa nel
  motore, con sette test e adesso **due** misure invece di una.
- **Rimessa in ordine la numerazione**, che avevo rotto io in tre punti nella
  stessa serata: c'erano **due ISSUES 59**, **due ISSUES 60** e **due 0.1.194**,
  e le versioni erano fuori ordine. Le due voci aggiunte per ultime prendono i
  numeri liberi — «Dieci segni sul mondo che nessuno legge» è **ISSUES 61**, «Il
  Consiglio non si può giocare sul tavolo fisico» è **ISSUES 62** — e il
  registro dei segni, la correzione e il peso della terra scalano a 0.1.195,
  0.1.196 e 0.1.197. Aggiornati anche i rimandi dentro D-225, D-226, `ISSUES 55`
  e `VISIONE.md`. I messaggi di commit già scritti portano i numeri vecchi: non
  si riscrivono, e questa riga è il ponte.

---

## 0.1.196 — Una correzione mia, e la leva che era già lì spenta

- **Correzione.** In 0.1.193 avevo scritto, in `docs/VISIONE.md` e in ISSUES 55,
  che al Consiglio «Sostegno e Opposizione sono solo somme di forza delle carte:
  nessuna pietra, nessuna maggioranza, nessuna cicatrice entra in quel conto».
  **Era sbagliato**, e per il motivo peggiore: avevo letto
  `confluence_resolution.gd` e non `confluence_controller.gd`, dove i bonus si
  calcolano. Nel conto ci sono già i **legami** (`alliance_weight`, D-139),
  **diciassette regole `COUNCIL_MODIFIER`** che spostano il Fattore Mondo — fra
  cui tre cicatrici, la Regione affamata e `settlement:city`, cioè una pietra
  alzata a città — e due `STANCE_MODIFIER`. Corretto in tutti e due i documenti.
- **Ma la conclusione regge, e adesso è più precisa**: quello che non entra è
  **il titolo e la maggioranza nella Regione di cui si discute**, che è
  esattamente ciò che il committente chiede da tre cicli.
- **E la leva esiste già, spenta.** `confluence_rules.focus_weight` (D-154) fa
  quello, è scritta, la reggono sette test — e **nessuna delle quattro Chronicle
  spedite la dichiara**.
- **Perché fu spenta, e perché quel motivo non vale più.** Misurata a 0.1.119:
  Consigli falliti 177 → 175, ma il playtest da **0/8 a 1/8**, e il seggio che si
  rompeva era sempre Kessa dei Fuochi. D-154 concluse che non era il peso della
  terra ma che **la Vittoria di Kessa aveva una porta sola**, e scrisse «ISSUES
  38 viene prima». **ISSUES 38 è chiusa da 0.1.122**, e da D-198 i gradini sono
  quattro obiettivi di cui tre pescati: oggi quella Vittoria ha tre clausole.
  **Il motivo per cui la leva è spenta ha smesso di valere settantadue versioni
  fa, e nessuno l'ha riaccesa.**
- **Aperta ISSUES 62**: il Consiglio non si può giocare sul tavolo fisico. 10
  template, **43 proposte**, 19 clausole e 52 conseguenze, e **0 dei 39 fogli di
  stampa** ne porta una. La carta Domanda esiste e porta la crisi, non le
  proposte.
- **E un difetto dentro il difetto**: la carta Domanda stampata porta ancora **la
  soglia**, in un cerchio all'angolo. Da D-214 quel numero non apre più niente —
  lo stesso errore che D-224 ha corretto sulla pagina d'aiuto, e che il cancello
  del testo non poteva vedere perché guarda lo schermo e non la stampa.
- Solo documenti: nessuna regola, nessun dato di gioco toccato.

---

## 0.1.195 — Il registro dei segni: dieci promesse che il mondo non registra (D-225)

- **`tools/build_sign_registry.py` + `docs/REGISTRO_SEGNI.md`**, generato e in
  CI. Per ogni segno che il gioco scrive sul mondo dice **chi lo scrive, chi lo
  cancella e chi lo legge** — e il criterio è uno: un segno che nessuno legge
  non è una regola, è colore travestito da regola.
- **71 segni scritti sul mondo. 10 non li legge nessuno.** `dragon_slain` («Il
  Drago Abbattuto»), `heir_named`, `succession_settled`, `water_rights`,
  `account_settled`, `burden_shared`, `condition:lean`, `condition:contested`,
  `condition:requisitioned`, `settlement:$proponent`. Sono carte e Conseguenze
  che promettono un cambiamento che il gioco non registra, e **non si vedono
  giocando**: la partita gira lo stesso.
- **Il difetto non si trova a occhio, e nemmeno con un grep.** Costruendo lo
  strumento sono emerse **sette penne diverse** che scrivono sul mondo: gli
  Effetti delle Conseguenze, delle carte Asset e delle Echo; le cicatrici, che
  si dichiarano a parte; le **pietre**, che posano un segno per grado; le
  **catene delle ere**, che dopo tre ripetizioni posano un segno nuovo
  (`mountain_forgotten` arriva da lì); e il codice, per `legend:`, `evicted:`,
  `function:`, `life:`.
- **E cinque modi di leggere.** Il più sottile: **una leggenda è il segno di
  prima, un'era dopo** — un fatto globale che sbiadisce diventa `legend:<fatto>`,
  e se qualcuno chiede quella leggenda allora il fatto morde, nel prossimo anno.
  `order_restored` sembrava muto e non lo è.
- **Leggere non è agire**, e lo strumento lo dichiara prefisso per prefisso:
  `discovery:` morde (`discovery_count`, chiesto da Destini e obiettivi),
  `evicted:` morde (impedisce il rientro), `legend:` morde; `condition:` no — il
  prefisso lo guarda solo la traversata delle ere, che è *quanto dura* un segno,
  non *cosa fa*. E `settlement:`/`life:` li legge solo chi disegna una parola
  sullo schermo.
- **I dieci muti sono dichiarati**, non nascosti: stanno in `MUTI_NOTI` con la
  ragione accanto. `--check` va rosso se ne compare uno nuovo **e** se uno
  dichiarato smette di esserlo, così l'elenco non marcisce e può solo accorciarsi.
- Nessuna regola cambiata: strumento, documento e un passo di CI.

---

## 0.1.194 — Il libro mastro delle carte: niente è morto, ma due verbi non si giocano

- **Nuova sonda `cli/run_card_ledger.gd`.** Conta, carta per carta su cento anni,
  quante volte è finita in mano, quante è stata **calata per agire** e quante
  **impegnata al voto** — che è l'unico momento in cui il suo effetto proprio
  gira. Il conto si prende dove i fatti succedono: un decisore che avvolge quello
  vero, delega ogni scelta e segna cosa ha scelto. Nessuna regola cambia e il seme
  resta quello.
- **Nessuna carta è contenuto morto**: 0 mai in mano, **0 mai impegnate al voto**
  su 5.793 carte pescate. Tutti e 48 gli effetti propri girano. Molto meglio delle
  Conseguenze (10 su 52 mai, ISSUES 56).
- **E la scelta al centro del gioco funziona, misurata:** forza 1 → **1,91**
  impegnate per ogni calata; forza 3 → **4,26**. Le carte deboli si spendono, le
  forti si tengono per il voto. *«La spendo per fare o la tengo per votare»* non è
  una frase sul regolamento: si vede nei numeri.
- **Aperta ISSUES 59.** D-215 aveva bilanciato *quante carte portano ogni verbo
  nel mazzo*; nessuno aveva misurato quanto ogni verbo viene **usato**. MOVE si
  gioca il **38,0%** delle volte che è in mano, FORGE l'**8,4%**: **4,5× di
  scarto**. FORGE e SCHEME insieme sono 2.534 carte in mano e 233 azioni.
  **Il mazzo è bilanciato, l'uso no.**
- **WEALTH è la famiglia inerte** (8,7% contro il 26,7% di BONDS, 3,1×), e non è
  un caso: quattro delle sue otto carte portano FORGE o SCHEME. **Quattro carte
  non vengono mai calate per agire** — «Credito» è stata in mano **140 volte** e
  non è mai valsa la spesa. E il **41,9%** delle carte di forza 1 non fa mai
  niente: resta in mano e scade.
- **Aperta ISSUES 60.** Tutte e dodici le domande vengono pescate e **tutte e
  dodici aprono almeno un Concilio** — la voce 51 è chiusa davvero. Ma il peso no:
  La Successione apre **1,73** Concili per anno in gioco, I Pozzi Bassi **0,50**,
  un fattore **3,5**. E più della metà delle volte che «I Pozzi Bassi» esce, non
  viene mai dibattuta. Due sbilanci si sommano invece di compensarsi: la pesca
  stessa è 1,83× per il peso ×3 dell'eco (D-079), ed è la stessa domanda a
  scaldarsi di più. **Chi è avanti resta avanti, anche fra le domande.**
- **Le due voci si leggono insieme a ISSUES 55**: FORGE e SCHEME sono i due verbi
  che non toccano la mappa e non entrano nel voto, ed è esattamente il motivo per
  cui nessuno li gioca. Tararli prima che la mappa paghi al Concilio vorrebbe dire
  tararli contro un'economia che sta per cambiare.
- Nessuna regola toccata: una sonda e due misure.

---

## 0.1.193 — L'idea di partenza contro il gioco che c'è

- **`docs/VISIONE.md`**: il confronto punto per punto fra ECHOES come il
  committente l'ha descritto prima che esistesse e ECHOES a 0.1.192, **letto dai
  dati e dal codice** e non dalla memoria. Venti punti, ognuno con dove si
  verifica.
- **Diciotto su venti sono in piedi.** La saga di dieci anni, l'anno che eredita
  il mondo di prima (strutture con tipo, grado e padrone; le condizioni sociali
  che sbiadiscono dopo cinquant'anni; le Regioni tenute senza nessuno dentro che
  decadono da sole), le entità che si trasformano di vita in vita, il tavolo e le
  domande pescati, il Concilio a fine Atto, le carte che sono tre cose insieme, i
  gradi di vittoria sommati sulla campagna.
- **Due divergenze, e in tutti e due i casi l'idea di partenza è più ambiziosa
  del costruito.**
- **Aperta ISSUES 58**: i tre obiettivi coperti si ripescano **ogni anno**, mentre
  l'idea li vuole pescati **a inizio saga**. Sposta l'unità dell'ambizione
  dall'anno alla campagna: oggi ogni Chronicle è un contenitore chiuso e la saga è
  una somma di partite invece di una storia sola. Metà del modello c'è già — il
  palese attraversa gli anni con la regola di D-081.
- **ISSUES 55 ha finalmente una radice.** Le quattro mosse scritte finora
  attaccavano il problema dal lato dell'offerta e hanno mosso poco (2,32 → 2,49
  passaggi di mano l'anno). Il motivo si legge nella matematica del Concilio:
  `M = Sostegno + Condizione − Opposizione + 1d6`, e Sostegno e Opposizione sono
  **solo carte**. Nessuna pietra, nessuna maggioranza, nessuna cicatrice entra nel
  voto — e su **43 proposizioni** ci sono **10 condizioni di idoneità in tutto**,
  quindi 33 su 43 sono ammissibili comunque sia messa la mappa. **La mappa non si
  muove perché non paga nella stanza dove il gioco si decide**, ed è la sola riga
  della descrizione originale che non è mai stata costruita.
- **Segnata anche la piccola**: i salti temporali arrivano a 200 anni, non a
  «secoli».
- Solo documenti: nessuna regola, nessun dato, nessun codice toccato.

---

## 0.1.192 — La pagina delle regole si misura, come tutto il resto (D-224)

- **La GUI non era allineata, e adesso non può più sfasarsi in silenzio.** La
  pagina d'aiuto diceva **cinque cose false** a chi la legge: che le domande
  salgono da sole, che una soglia apre un Consiglio, le soglie stampate accanto a
  ogni domanda, il tavolo scritto per nome invece che pescato fra otto case, e il
  rubinetto raccontato con due numeri su cinque.
- **La causa era una riga.** La sezione dei Consigli pendeva da `table_gate`, che
  D-214 ha tolto dai dati: il ramo giusto ha smesso di prendersi e la pagina è
  caduta nel testo di due versioni prima. Con la sezione erano spariti anche **i
  mucchi coperti**, che ci stavano annidati dentro — una regola accesa di cui la
  pagina aveva smesso di parlare.
- **Una sesta bugia fuori dalla pagina**: `_context_line()` in `game_screen.gd`,
  la riga sopra le scelte, prometteva «ha raggiunto la soglia: il Consiglio si
  apre» a ogni round di ogni partita spedita. Adesso dice quale mucchio arriverà
  al tavolo e fra quanti round — e coi mucchi coperti lo dice **nella moneta che
  il giocatore ha**: i gettoni caduti, non il peso.
- **Prima la misura, poi il testo.** `test_the_page_says_only_what_the_data_says`
  disegna la pagina sui dati **spediti**, per ogni Chronicle, contro una tabella
  di clausole che lega ogni dichiarazione alle sue parole **nei due sensi** — e
  il secondo senso lo prova **togliendo la dichiarazione e ridisegnando**. Prima
  esecuzione: **55 asserzioni rosse**.
- **La prova ha trovato un crash che la suite non vedeva**: senza
  `presence_tokens` la pagina andava in errore a metà e restava verde, perché in
  GDScript una chiave mancante interrompe la funzione e scrive in un log.
- **E leggendo quel log ne sono usciti altri due**, in prove che nessuno aveva
  toccato: `test_data_boot` non misurava la traccia di Drift **da mesi**, e
  `test_print_export` si fermava alla prima incarnazione — quindi il controllo
  che tiene in piedi il segreto del Destino **non girava**. Asserzioni della
  suite da **7.414 a 7.470**.
- **Il difetto sistemico, non l'aneddoto**: la suite conta i test che fa partire,
  non quelli che arrivano in fondo. Il cancello adesso va rosso su `SCRIPT
  ERROR`.
- **Cercato il resto della GUI, non supposto**: delle diciassette viste solo
  `help_panel.gd` parla di regole; le altre disegnano lo stato del mondo, che per
  costruzione è aggiornato.
- **Aggiunte due regole che la pagina non aveva mai detto**: il tetto delle
  pedine (D-223) e cosa paga il **possesso** rispetto alla presenza (D-220).
- Nessuna regola cambiata: testo e prove. Playtest **0/8**.

---

## 0.1.191 — Il tetto vale anche per il mondo, e le domande che spostano non escono mai (D-223)

- **Un difetto vero, trovato prima di introdurlo.** `_add_presence` non
  controllava il tetto delle pedine: l'azione MUOVERE lo fa da sempre, l'applier
  no. Una Conseguenza poteva posare la **quinta** pedina di una casa che ne ha
  quattro — non si era mai visto perché una sola Conseguenza metteva presenza.
  Adesso il tetto vale anche per il mondo; l'inverso è escluso apposta, perché
  disfare deve sempre poter disfare.
- **Sei carte promettevano una pedina anche a chi non ne ha più** (tre Asset, tre
  Eco) e prima sforavano in silenzio. Adesso lo dicono: `optional`, cioè un
  no-op dichiarato.
- **E due prove costruivano uno stato impossibile** — quattro pedine di Vaerax in
  una Regione, quando ne ha quattro in tutto e due altrove. Adesso `_stand` le
  richiama da dove stanno.
- **La mossa «le domande spostano la mappa» è respinta, misurata.** Cinque
  Conseguenze con `ADD_PRESENCE`, tre forme diverse (tutte, solo le migrazioni,
  migrazioni verso il rivale): **lo stesso numero ogni volta**, 2,49 → 2,39
  passaggi di mano. Le due `CONTROL` peggioravano per una ragione leggibile —
  mettere il proponente dove ha appena vinto **consolida** invece di contendere —
  e sono state tolte.
- **Il numero che chiude la questione**: quelle Conseguenze escono **21 volte in
  100 anni** su ~470 Consigli, e due di loro **mai**. L'Effetto era su carte che
  non si giocano.
- **Aperta ISSUES 56**: allargando il conto, **10 Conseguenze su 52 non escono
  mai** in 931 Consigli su 200 anni — «Il Drago Abbattuto», «La Corona Riunita»,
  «Il Giuramento Rotto». Il 19% del catalogo è contenuto che nessuno vede, e
  nessuna misura l'aveva mai contato: le sonde guardano cosa succede, non cosa
  **non** succede.
- **Le tre migrazioni tengono l'`ADD_PRESENCE`**, non per bilanciamento ma perché
  è vero: «qualcosa parte e non torna quell'anno» vuol dire che parte *verso*.
  Playtest **0/8**.

---

## 0.1.190 — Il cervello insegue quello per cui si vince (D-222)

- **La mossa 0 di ISSUES 55.** Da D-198 si vince contando quattro obiettivi; il
  `PolicyDecider` leggeva solo le condizioni del **Destino**, e la parola
  «objective» non compariva **nemmeno una volta** in quel file.
- **Una funzione sola.** `_conditions()` è il punto da cui il decider ricava cosa
  vuole, e ha **nove** chiamanti: azione, Regioni, carte, Tensioni, voto al
  Consiglio. Aggiungere lì le clausole degli obiettivi in mano le fa inseguire
  ovunque, senza un'euristica nuova per ognuno.
- **Il Destino resta** — è lui a dire il livello, ed è quello che fa somigliare
  una casa a se stessa — e **un obiettivo già preso smette di essere un
  movente**: è un punto in cassaforte, e giocarci contro toglierebbe azioni a
  quelli che mancano.
- **I numeri** (100 semi, confronto pulito: cambia solo questa riga):
  obiettivi presi **397 → 446**, anni chiusi con quattro su quattro **2 → 7**,
  «Due Terre, una Voce» **32,1% → 39,5%**, e al tavolo misto NONE **93 → 80**,
  VITTORIE **147 → 175**, TRIONFI **4 → 7**. Playtest **0/8**.
- **Quello che si dichiara, ed è la parte che conta**: **la mappa non si è mossa
  lo stesso** (2,42 → 2,49 passaggi di mano). Il cervello adesso *vorrebbe* la
  mappa ma non ha con cosa prenderla — MUOVERE si gioca 3,79 volte l'anno e le
  pedine sono quattro. Il collo di bottiglia è lì, non nella testa di chi gioca.
- **E tutti i numeri sugli obiettivi scritti prima di oggi misuravano un cervello
  cieco**: restano veri come descrizione di ciò che il cancello faceva, non
  dicono quanto valga un obiettivo per chi lo persegue. I più esposti sono quelli
  di ISSUES 52.

---

## 0.1.189 — Tenere paga, gli obiettivi si contendono, e il cervello non li guarda (D-220, D-221)

- Prima mossa su ISSUES 55. **`hand_refill.per_control`**: carte in più per
  Regione **controllata**, e altrettanto tetto sulla mano. Il possesso non
  pagava più che starci dentro.
- **Il preventivo era sbagliato e la misura l'ha detto.** Avevo scritto che il
  collo di bottiglia era il tetto per Atto (`cap: 6`); l'ho alzato a 8 e non è
  cambiato **niente**. Il tetto vero è quello sulla **mano**: tutti convergono
  alla stessa mano piena. Il cap è tornato a 6 — un cambio che non fa niente non
  resta.
- **E la sonda ha sbagliato la domanda due volte**, cambiando conclusione ogni
  volta: «carte in mano a fine anno» (chi ha più pedine pesca *e spende* di più),
  poi «carte pescate raggruppate per le pedine di fine anno» (chi finisce con
  cinque le ha posate tardi). La coppia giusta — con quante pedine si è pescato
  quanto, ricostruita dal registro in ordine — dice che con **3 pedine si
  pescano 3,44 carte e con 5 se ne pescano 3,12**: non piatto, **invertito**.
- **`leads_in`**, tipo di condizione nuovo: «più di chiunque altro» su una delle
  quattro monete. È vera per **un seggio alla volta per costruzione** — alzare
  una soglia rende un obiettivo più difficile, non più conteso. Tre obiettivi
  nuovi la usano; il pool passa da 12 a 15 e i contesi da **1 a 4**.
- **Il ritrovamento, più importante delle due decisioni**: aggiunti gli obiettivi
  contesi, la mappa **non si è mossa**. Il motivo sta in una riga —
  `grep -c "objective" policy_decider.gd` → **0**. Il cervello che gioca il
  cancello **non legge gli obiettivi**: insegue le condizioni del Destino, mentre
  da D-198 la vittoria si conta **contando obiettivi**. Chi gioca insegue una
  cosa e il punteggio ne conta un'altra.
- **Cosa vuol dire per i verbali già scritti**: ogni misura sugli obiettivi —
  il libro mastro compreso — dice *cosa capita* a un seggio che non li persegue,
  non quanto siano difficili da perseguire. Restano vere come descrizione di ciò
  che il cancello misura; non dicono quanto valga un obiettivo per chi lo vuole.
- **I numeri**: il padrone passa di mano **2,32 → 2,42** volte l'anno, Regioni
  contese **2,60 → 2,66** su 6, Verità scritte **336 → 348**. Playtest **0/8**.
- **Non ho toccato il cervello**: insegnargli a inseguire gli obiettivi cambia
  ogni numero di ogni verbale che li nomina, ed è una decisione che va presa
  apposta.

---

## 0.1.188 — Il brief d'arte era vecchio, e il cancello locale non lo sapeva

- **Difetto mio, trovato dalla CI.** D-218 ha cambiato il testo stampato di due
  carte — l'Assedio e l'Archivio — e `docs/BRIEF_ARTE.md` è **generato
  dall'export e committato**: è il documento che si manda a chi disegna. Non
  l'ho rigenerato, e il brief prometteva due carte che non esistono più.
- **Perché il cancello locale diceva verde**: `tools/run_export.sh` *genera* il
  brief, non lo confronta col committato. Il confronto lo faceva **solo la CI**.
  È la stessa distanza fra le due strade che D-189 aveva già pagato una volta.
- **Adesso confronta lui**: il brief disallineato produce un avviso con il
  comando per rimediare, e `--check-brief` lo fa uscire **1**. Provato sporcando
  il brief committato.
- **Aggiunta la riga alla regola 5 di CONSEGNE**: se cambia il testo stampato di
  una carta, si passa da `--check-brief`.

---

## 0.1.187 — Ogni relazione dice perché (D-219)

- ISSUES 54 chiedeva una cosa sola: **ogni coppia neutrale lo è per una ragione
  scritta, non per aritmetica**. Serviva un posto dove metterla.
- **`relations[].note`, obbligatoria**, e scritta per tutte e **28** le coppie —
  non solo le sedici nuove: le dodici d'autore avevano la loro ragione nelle
  descrizioni delle case, e lasciarle mute avrebbe fatto sembrare *loro* quelle
  di comodo.
- **Uno scambio, col motivo. Lyra ↔ la Gilda del Sale** passa a alleata: tengono
  tutte e due dei registri, per ragioni opposte — la Gilda per contare, Lyra per
  capire. **Aldric ↔ la Cenere** torna neutrale: era la più generica delle otto
  calde, e adesso il silenzio è una scelta («la corona non è mai salita sulle
  montagne»).
- **La guardia** confronta la nota fra le due scritture insieme al livello e ai
  tag: le due metà di una coppia devono dire la stessa cosa anche sul perché.
- **I numeri** (200 semi): tavoli piatti **0,0%**, coppie calde per tavolo
  **2,94 → 2,88**, e le due facce si pareggiano — alleanze/ostilità da 1,22/1,72
  a **1,42/1,47**. Playtest **0/8**.
- **Dichiarato**: la nota **non arriva al tavolo**. È dato per chi scrive il mondo
  e per le guardie; nessuna interfaccia oggi la mostra.

---

## 0.1.186 — L'Archivio, e le pietre che hanno una vita (D-217, D-218)

**ISSUES 52 — la casa che non trionfa mai**

- `starting_structures` dava un presidio a sei case su otto. Lyra e l'Ordine del
  Vetro mancavano **sempre le stesse carte**: «Qualcosa che Resta in Piedi» al
  6,7% e 23,1% contro il 100% delle altre.
- **`STR_ARCHIVE`** — Archivio → La Grande Biblioteca — con una **famiglia sua,
  `STUDIO`**. La prima versione lo metteva fra le OPERA, ed era lo stesso difetto
  ribaltato: avrebbe reso «L'Opera che Porta il Nome» gratis per due e impossibile
  per sei. E sta nella **seconda** Regione, perché nella prima avrebbe dato a Lyra
  anche il controllo delle Miniere — una strada del suo Destino in regalo.
- **I numeri**: anni chiusi con zero obiettivi, il Vetro **18 → 12** e Lyra
  **7 → 6**; anni con due obiettivi, Lyra **13 → 19** e il Vetro **9 → 16**.
  «Qualcosa che Resta in Piedi» passa da **6,7–100%** a **68,8–100%**: la carta
  che divideva il tavolo in due non lo divide più.
- **Due difetti veri trovati per strada.** Una prova che diceva di svuotare una
  Regione e ne svuotava metà (`_clear` toglieva le pedine, lasciava le pietre) —
  otto prove sono andate rosse e avevano ragione. E **un numero falso in una
  sonda**: `run_objective_ledger` chiedeva gli obiettivi *dopo* `run()`, quando
  le pietre erano già salite, e diceva che «Pietra sopra Pietra» si avvera nel
  27–46% dei casi. In partita non si avvera mai. Adesso il consuntivo si
  **congela** insieme ai livelli.

**ISSUES 39 — le pietre hanno una vita**

- Rimisurato con una sonda nuova (`run_stone_probe`): **13,02 pietre su 14,53 le
  posa l'apertura**, dal gioco ne arrivano 1,51, e in cento anni **non ne viene
  giù nessuna**. Le salite di grado erano **0,04 a partita**.
- **Tre righe, ognuna misurata**: le pietre salgono su VICTORY e non solo su
  TRIUMPH; **l'Archivio si può costruire** (`AST_KNOWLEDGE_ARCHIVE` era l'unica
  delle 48 carte senza un mestiere, e adesso è l'unico modo che una casa ha di
  *decidere* di costruire); **l'Assedio butta giù** il presidio della Regione
  della domanda.
- **I numeri**: alzate dal gioco **1,51 → 2,41**, abbattute **0,00 → 0,43**,
  salite di grado **0,04 → 1,82**, grado 2+ a fine anno **0,56 → 2,34**. La mappa
  adesso **si può anche svuotare**. Playtest **0/8**.
- **Sei clausole di Destino** che l'apertura soddisfaceva da sola salgono a due.
  Non è la stessa mossa provata e **ritirata** sugli obiettivi: lì non c'era modo
  di costruire e la soglia la decideva il setup (il Muro passava a 0–11%, una
  carta morta); qui il modo c'è.

**Quello che resta aperto, dichiarato**

- **«Il Muro che Tiene» è ancora una spunta** (0–100%): chiede un presidio, e
  l'Archivio non lo è. Alzarne la soglia è stato provato e misurato come
  peggiore.
- **«Pietra sopra Pietra» resta 0 su 100**: la salita di grado arriva *dopo* il
  conteggio degli obiettivi, quindi vale per l'anno dopo. Serve un modo di alzare
  un grado **durante** l'anno, e non c'è.
- **La strada A di ISSUES 39 era già fatta e nessuno l'aveva chiusa**: il criterio
  chiedeva «ben sopra una pedina mossa per scelta a partita», e dopo D-215
  MUOVERE si gioca **3,79 volte l'anno**.

---

## 0.1.185 — Le sedici coppie che non si conoscevano (D-216)

- Il debito dichiarato da D-213, pagato: su 28 coppie di case ne erano scritte
  **12**, tutte dentro la vecchia linea. Aldric non sapeva chi fosse la Gilda del
  Sale, Lyra non sapeva chi fosse l'Ordine del Vetro.
- **«Piatto» non è un aggettivo: è un numero, ed era il 14%.** Nuova sonda
  `run_table_probe`: per ogni tavolo che il seme apparecchia conta quante delle
  sei coppie sedute sono calde.

| 200 semi | prima | dopo |
|---|---|---|
| coppie scritte | 12 su 28 | **28 su 28** |
| **tavoli piatti** (nessuno si conosce) | **14,0%** | **0,0%** |
| coppie calde per tavolo | 1,22 su 6 | **2,94 su 6** |
| il tavolo più comune | 1 coppia calda | **3 coppie calde** |

- **Otto calde e otto neutrali**, e il criterio non era «quante ne servono» ma la
  densità che i due tavoli d'autore avevano già (2 su 6 nel Grano, 4 su 6 nel
  Sale). La media pescata torna a **2,94 su 6**: la stessa temperatura.
- **Nessuna delle otto è stata scelta per far tornare i conti**: erano già
  scritte nelle descrizioni. L'Ordine del Vetro «custodisce quello che fu
  misurato» e Lyra **è quella che l'ha misurato**; la Cenere campa di quello che
  l'antica miniera ha lasciato e Vaerax **dorme sotto quelle montagne**.
- **Un'asimmetria che c'era già**: la Cenere si diceva alleata al Sale, il Sale
  alleata alla Cenere *per patto*. I tag si sommano, quindi non faceva danno —
  ma sul **livello** sarebbe andata diversamente: nel mondo la relazione è una
  coppia sola, e chi scrive per ultimo (in ordine alfabetico di id) decide. Una
  delle due frasi sparisce senza dirlo.
- **Una guardia** che chiude tre porte: livelli o tag discordi fra le due
  scritture, una relazione con una casa inesistente, e una coppia di case
  pescabili che non è scritta da nessuna parte. **E una prova** che guarda il
  tavolo invece del dato — cinquanta tavoli pescati, nessuno apre piatto.
- **Il playtest quasi non si muove** (Consigli 4,49 → 4,49; Verità 333 → 335;
  **0/8**), ed è atteso: le relazioni pesano al Consiglio e nelle clausole, non
  nella scelta delle azioni. Il cancello dice che non ho rotto niente; la sonda
  nuova dice che il tavolo ha una storia. Sono due cose diverse.

---

## 0.1.184 — Nessuna famiglia senza un'azione (D-215)

- Il committente ha chiesto un numero mai misurato: «*le azioni sono equamente
  distribuite nelle carte?*». Le **famiglie** erano pari (22 copie ciascuna,
  esatte). Le **azioni** no, e l'incrocio aveva **nove zeri**: AUTORITÀ non
  poteva muovere né tramare, RICCHEZZA non poteva rivendicare, FORZA non poteva
  forgiare.
- **Uno zero lì non è uno squilibrio: è una porta chiusa senza dirlo.** Le
  azioni passano sulle carte e la mappa decide che carte peschi, quindi la mappa
  decide che *cose puoi fare*. Lyra, che vive di SAPERE, aveva **4 copie di
  MUOVERE su 132** — ed è la causa vera del 30% di seggi che D-208 aveva trovato
  bloccati da «nessuna carta MUOVERE in mano».
- **Dieci carte cambiano azione, nessuna cambia mestiere**: il criterio era che
  il nuovo verbo fosse già dentro il titolo. Il Censimento trama (contare la
  gente è guardare le carte degli altri), il Pedaggio rivendica (una corda su una
  strada), il Diritto di Ospitalità muove (essere ospiti è essere là), i
  Mercenari forgiano (la lealtà pagata è pur sempre un legame).
- **Nessuno zero**, e lo scarto fra l'azione più comune e la più rara scende da
  **1,85× a 1,38×**. Le identità restano — SAPERE trama 11 su 22, LEGAMI forgia,
  FORZA muove — ma sono accenti, non muri.
- **Una guardia** in `validate_data.py`: nessuna famiglia a zero su un'azione, e
  la più rara del mazzo non sotto metà della più frequente. Provata rimettendo
  il Magistrato a FORGE.
- **I numeri**: Verità scritte **317 → 333** (misto), MUOVERE giocate l'anno
  **4,64 → 3,79** e bloccati da «nessuna MUOVERE in mano» **30,5% → 38,0%** —
  voluto: MUOVERE era il 23,5% del mazzo per una sola azione su cinque, e adesso
  il costo lo pagano tutti allo stesso modo invece del 100% per una casa e lo 0%
  per un'altra. Playtest **0/8**.
- **Il piano D si è ribasato** (l'unico): è la storia scritta nell'economia di
  adesso, quindi non poteva dichiarare un mazzo di prima. Gesto d'apertura e
  morale intatti; cambia il finale. La prima scelta era sbagliata — avevo
  spostato proprio la carta di cui quella storia parla, e il piano è andato rosso
  e aveva ragione.
- **Cinque sonde erano rotte e nessuno lo sapeva**: non stanno nel cancello, e un
  cambio di firma in `GameSession` (D-213) le aveva lasciate con un
  identificatore fuori posto mentre la CI restava verde. Una sonda che non parte
  è **una misura che non si può più fare**. Adesso `test_probes_compile` le
  carica tutte.

---

## 0.1.183 — Il Consiglio chiude l'Atto, e il cancello si spegne (D-214)

- Decisione del committente, già presa una volta e da me rimandata **senza
  dirlo**: «*il concilio c'è alla fine di ogni atto, non servono due gettoni per
  farlo partire*». Ha dovuto chiedere due volte.
- **`confluence_rules.at_end_of_act`**: a fine di ogni Atto si tiene un
  Consiglio sulla domanda col **mucchio più alto** — cioè su ciò che i gettoni
  coperti costruiscono per tutto l'Atto (D-210). Il round non ne apre più
  nessuno da solo, né per soglia né per gettoni: **`table_gate` è tolto dai dati
  spediti** (non dal motore, che resta a disposizione di una Chronicle che lo
  dichiari). Resta RIVENDICARE per portare al tavolo una seconda domanda.
- **I gettoni smettono di dire *se* si parla e dicono soltanto *di cosa*.**
- **I numeri** (100 semi, seme 7000): Consigli l'anno **3,09 → 4,49** (misto) e
  **3,20 → 4,64** (uniforme), Verità scritte **254 → 317** e **229 → 319**, e il
  minimo su cento anni **1 → 3**. Su **300 Atti misurati, 0 chiusi senza
  Consiglio**; anche un tavolo che passa ogni round ne prende tre. Playtest
  **0/8**.
- **Il difetto che la regola ha scoperto**: il codice aveva due domande diverse
  trattate da sinonimi. `has_fresh_question` chiede «resta un quesito mai
  posto?», ma il template apre solo un quesito **idoneo**. A soglia la
  differenza non si vedeva; a fine Atto sì — tre anni su cento chiudevano sotto
  la promessa e uno rifiutava otto aperture di fila. Ora c'è `can_open()`, e la
  chiusura scende al mucchio successivo invece di perdere il Consiglio.
- **Il pavimento di fine anno (D-047) non scatta più** sui dati spediti: con un
  Consiglio per Atto la garanzia è strutturale. Resta nel motore per le
  Chronicle che non tengono il Consiglio di chiusura.
- **Dichiarato e non risolto**: 43 aperture su cento anni vengono ancora
  rifiutate, e sono tutte Consigli **forzati da RIVENDICARE** — il Claim non
  passa da `can_open`, quindi si può spendere un'azione per forzare un Consiglio
  che poi non si apre. Difetto vero e preesistente, portato alla luce da questa
  misura.

---

## 0.1.182 — Un setup solo: le case si pescano come le domande (D-213)

- Il committente: «*non voglio due ere, voglio un unico setup dove si pescano
  entità e obiettivi e anche le domande*». Il gioco aveva **quattro Chronicle in
  due linee chiuse**, ognuna con quattro case scritte a mano e sei domande sue.
- **Cosa c'era già**: gli obiettivi erano già un mazzo solo da 12 e le Regioni
  già condivise. Mancavano le **case** (fisse) e una **biblioteca unica** di
  domande (6+6 separate).
- **`entity_pool`** sulla Chronicle, stessa forma di `tension_pool`: 8 candidate,
  se ne siedono 4. La pesca sta in `GameSession.seats_for()`, statica e fuori da
  `setup`, così il tavolo si sa prima che il mondo esista e non consuma l'RNG
  della partita. Vuoto = assente, come ovunque.
- **La pietra segue la casa**: `starting_structures` si sdoppia — il paesaggio
  (bosco, sorgente, valico) resta sulla Chronicle, il presidio passa
  sull'Entità con `at` sulla presenza di partenza. Rifattorizzazione misurata da
  sola: **playtest byte-identico**.
- **La varietà, che è il motivo del cambio** (12 saghe da 6 anni, seme 812):
  aperture diverse **6 e 4 → 12 su 12**, distanza media fra saghe **0,88 e 0,83
  → 0,97**, frasi distinte **96 e 52 → 106**, vite viste al tavolo **6 → 13**.
  Su 200 semi escono **67 tavoli diversi su 70**, e le otto case si siedono fra
  il 45,0% e il 54,5%.
- **Tre difetti nascosti che il tavolo pescato ha scoperto**, tutti invisibili
  finché le case non cambiavano mai: l'eredità portava **relazioni**, **controlli
  di Regione** e **pietre** di case non più al tavolo (SET_RELATION senza record
  = Effetto senza inverso); e **due clausole di Consiglio nominavano Lyra per
  nome**, cadendo in un `push_error` dentro un log che nessuno legge. Ora c'è il
  segnaposto **`$conditioner`** — chi ha posto la condizione — che è anche più
  giusto a leggersi.
- **`requires_entity`** sulle Conseguenze: «Il Drago Abbattuto» spegne Vaerax e
  adesso lo dichiara, quindi si salta quando Vaerax non siede — **dicendolo nel
  verbale**, perché D-030 vale anche per ciò che non succede.
- **Due guardie nuove**: con le case pescate nessun Effetto scritto a mano può
  puntare a un `ENT_`; e la prova del traguardo verifica che ogni anno peschi
  **dalla stessa biblioteca** invece di contare due biblioteche separate.
- **I numeri peggiorati, che si scrivono**: Consigli l'anno **3,53 → 3,09**
  (misto) e **3,64 → 3,20** (uniforme), Verità scritte **295 → 254**. Con dodici
  domande e quattro pescate il calore si sparpaglia. Playtest **0/8** su tutti e
  due i tavoli.
- **Non fatto, e dichiarato**: **16 relazioni incrociate su 28 non esistono**
  (partono a NEUTRAL) — un tavolo misto è più piatto di uno storico, e spiega
  parte del Consiglio perduto. Le Chronicle sono ancora quattro, ma adesso sono
  *anni* e non *ere*. Il Consiglio a fine Atto e il cancello a due gettoni sono
  la prossima voce.

---

## 0.1.181 — Lyra sulla Strada dei Mercanti (D-212)

- Il committente ha deciso l'altra metà di ISSUES 48: **«Lyra sulla Strada dei
  Mercanti»**. Lyra apre con Miniere Antiche + Strada invece di Miniere Antiche
  + Eredan.
- **Nel Grano non c'è più una Regione vuota**: la Strada passa da 0,00 → 1,20 a
  **1,00 → 2,07** pedine, ed è la seconda più affollata a fine anno. La Regione
  più magra diventa Montagne Rosse a **1,78**.
- **Lyra smette di essere la quarta casa**: NONE **16 → 8** (uniforme) e **17 →
  8** (misto), Vittorie **10 → 28** e **12 → 22**, anni chiusi con zero
  obiettivi **35 → 20**.
- **I numeri peggiorati, che si scrivono**: i TRIONFI di tutto il tavolo calano
  **10 → 8** (uniforme) e **5 → 2** (misto), e Lyra resta a **0**; Re Aldric
  paga il conto (NONE 7 → 10, Vittorie 23 → 14, uniforme); i gettoni si bloccano
  prima, **44,0% → 51,0%**. Playtest **0/8** su tutti e due i tavoli.
- **Le quattro storie scritte a mano dichiarano la mappa in cui sono nate.**
  Nuova chiave `starting_presence` sulla Chronicle (vuota = assente, come
  ovunque), scrivibile da `chronicle_overrides` come già l'economia (D-189):
  ribasare quattro `expected` non le avrebbe aggiornate, le avrebbe timbrate.
  Vale solo per la prima vita del seggio — dopo una successione comanda
  l'incarnazione (D-133).
- **Una guardia nuova** in `validate_data.py`: una mappa dichiarata che coincide
  col dato spedito non dichiara più niente e va rossa. Provata — rimettendo Lyra
  a Eredan morde su tutti e quattro i piani.
- **Quello che non è stato fatto**: «Nahr sulle Terre Nahr» nel Grano è già così.
  La Regione vuota è **Terre Nahr nella linea del Sale**, dove i Nahr non
  esistono — chi ci va è contenuto, e torna al committente col prezzo misurato.

---

## 0.1.180 — Due pedine di riserva invece di una (D-211)

- Il committente aveva deciso il risultato: «non ci può essere una regione senza
  nessuno». D-208 aveva prezzato tre rimedi; provati **separatamente**, costano
  cose molto diverse.
- **Il tetto a 4** rompe due prove che descrivevano il setup, e **nessuna
  storia**. **Spostare la casa di Lyra** rompe **tutte e quattro** le storie
  scritte a mano. Spedito il primo; il secondo è *dove vive una casa*, cioè
  contenuto, e torna al committente col prezzo scritto.
- **I numeri**: gettoni di riserva per casa **1 → 2**, MUOVERE l'anno **3,02 →
  4,70** (Grano) e **2,88 → 4,20** (Sale), bloccati dal gettone **71% → 41%** e
  **74% → 48%**, Consigli l'anno **3,40 → 3,57** e **3,57 → 3,86**, playtest
  **0/8**.
- **Metà voce soddisfatta, e si dice quale.** Nel Grano nessuna Regione finisce
  sotto **1,20** pedine e la Strada non è più deserta; nel Sale le Terre Nahr
  restano a **0,88** — lì non comincia nessuno, e il tetto non fa cominciare
  nessuno.
- **E spostare continua a non succedere**: 0,03 l'anno nel Grano, 0,00 nel Sale.
  Più pedine da posare non sono una mappa che si disfa.
- **Le quattro storie**: B e D passano invariate; **A si ribasa** (l'ultima
  domanda si chiude decisiva, e con due gettoni di riserva è il finale che la sua
  descrizione già prometteva); **C dichiara il tetto 3**, perché il suo finale
  *è* la storia — «una domanda che sembrava chiusa si riapre e resta aperta» — e
  col quarto gettone quelle Vie passano invece di cadere.
- **Due difetti per strada.** L'inverso di `REMOVE_PRESENCE` rimetteva la pedina
  **in fondo** invece che dove stava: il round trip promette *identico* e dava
  *equivalente*, ed era invisibile perché la Regione di prova era l'ultima della
  lista. E tre prove descrivevano il setup invece dell'intenzione — una di
  queste, col tetto a 4, posava **due** pedine sulla montagna dove la clausola
  ne chiede una, e l'avviso taceva **per la ragione giusta**.
- Quel test ha anche fatto emergere una regola che non era scritta da nessuna
  parte: la pedina che parte è la **prima in ordine alfabetico** fra le Regioni
  tenute. Ora il test lo dice e lo verifica.

## 0.1.179 — I mucchi coperti, e il pavimento che non sapeva del cancello (D-210)

- **ISSUES 49 è chiusa.** L'ultima fase: «i segnalini coperti danno un valore a
  una tensione, e quando parte la Confluence si girano».
- **Coprire vuol dire due cose, non una.** Un mucchio in cui ogni gettone vale 1
  si conta a occhio: coprirlo non nasconderebbe niente. Quindi il gettone pesca
  un **valore** dal sacchetto — `covered: [0, 1, 1, 2]`, media **1,00**, il
  calore totale non cambia in attesa ma cambia la varianza — e il punteggio
  smette di essere pubblico. Lo zero è il **gettone bianco**: non muove niente
  ma è sceso, quindi conta per il cancello e si vede cadere.
- **Tre finestre, non una**: il verbale pubblico, la scheda del seggio e la
  pagina d'aiuto. Bastava lasciarne aperta una perché coprire fosse teatro — la
  lezione di §5ter presa in anticipo invece che dopo. Otto prove nuove, tre delle
  quali mordono se una finestra resta aperta.
- **Il criterio di chiusura della voce era impossibile, e l'ha detto la misura.**
  «Lo scarto fra i mucchi non cresce di atto in atto» era **già falso senza
  coprire**: 3,95 → 6,42. Coprire aggiunge **+0,28** su tre atti. Il criterio
  giusto è *non cresce più di quanto già cresceva*, ed è scritto così invece che
  dichiarato raggiunto.
- **E ha scoperto un difetto vecchio.** Il pavimento di fine anno portava una
  domanda **alla propria soglia** — ma col cancello del tavolo la soglia non apre
  più niente, e se quella domanda era già sopra soglia il pavimento **usciva
  zitto senza fare nulla**. Latente da D-203; la copertura ha alzato i valori
  quel tanto che bastava e un anno è sceso a **un Consiglio solo**. Adesso il
  pavimento fa cadere i gettoni che mancano, come Effetti reversibili: alzare il
  contatore e basta avrebbe aperto un Consiglio che il registro non sa spiegare,
  e un test ha rifiutato quella prima toppa.
- **Il gate**: Consigli l'anno 3,37 → **3,40** (uniforme) e 3,73 → **3,57**
  (misto), playtest **0/8** a tavolo misto e uniforme.

## 0.1.178 — La quarta casa non trionfa, in nessuna era (D-209) · ISSUES 51 e 46 rimisurate

- **ISSUES 51 chiusa, e l'aritmetica sbagliava strumento.** `run_question_ledger`
  conta per ogni domanda quante volte è pescata e in quanti di quegli anni apre
  almeno un Consiglio. **Nessuna delle dodici è muta**, e tutte superano il
  criterio della voce: la Febbre Bassa apre nel **57,5%** degli anni in cui esce,
  i Pozzi Bassi nel **26,3%**. Il test che le dava per irraggiungibili sommava
  valore + Deriva + Ripple, e da D-192 **la Deriva non è nemmeno in gioco**.
- **Ma la misura ha trovato di meglio: le due linee non hanno lo stesso clima.**
  Consigli l'anno **3,80 nel Grano contro 2,85 nel Sale**; tre domande sopra il
  90% nel Grano, **zero** nel Sale; e nel Sale le domande finiscono l'anno molto
  più lontane dalla soglia (il Debito a **−3,12**).
- **ISSUES 46 rimisurata: il vincitore scritto non è più il Sale.** Da **12 su
  12** a **1 su 12**. Il posto l'ha preso la **Cenere, 7 su 12**. E il confronto
  fra le linee dice che il difetto non è chi vince ma come si decide: cambi di
  testa **1,2 nel Sale contro 1,8 nel Grano**, ultimo cambio all'anno **3,6
  contro 4,4**. La linea più fredda decide prima.
- **E il difetto di Lyra non è di Lyra: è una regola dell'apertura.** In CHR_03
  `starting_structures` posa uno `STR_KEEP` a tre case su quattro e lascia
  scoperto **l'Ordine del Vetro** — che chiude con **43 NONE e 1 Trionfo su 120
  anni**, come Lyra con 44 e 0.

  | linea | casa senza presidio | NONE su 120 | TRIONFI |
  |---|---|---|---|
  | il Grano | **Lyra** | 44 | **0** |
  | il Sale | **l'Ordine del Vetro** | 43 | 1 |

  E in tutte e due, fra le clausole del Minimo più mancate c'è letteralmente
  **«Almeno un presidio suo»** — Lyra 18 volte, il Vetro 17. **La casa che apre
  senza presidio è la casa che non vince mai**, e qualunque cosa si decida per
  Lyra va decisa anche per il Vetro.
- Nessuna regola accesa: sono decisioni di contenuto, e il numero è scritto prima
  perché si possa scegliere guardandolo.

## 0.1.177 — Tre case aprono l'anno con due obiettivi già in tasca (D-209)

- ISSUES 52 chiedeva **quali** obiettivi Lyra manca. `run_objective_ledger`
  conta per ogni coppia **seggio × obiettivo** quante volte è pescato e quante
  preso — il consuntivo, dove la sonda vecchia misurava il preventivo.
- **«Qualcosa che Resta in Piedi»** e **«Il Muro che Tiene»**, i due obiettivi
  più facili del pool: **100% per Aldric, Nahr e Vaerax — 4,5% e 0% per Lyra.**
- La causa è una riga di dati: `starting_structures` posa uno `STR_KEEP`
  (famiglia PRESIDIO, quindi struttura *e* presidio insieme) alle altre tre
  case. **A Lyra niente.** Parte ogni anno con due carte morte su quattro, e
  chiude con **zero obiettivi 16 volte su 60 e quattro obiettivi mai**.
- **Perché nessuna sonda l'aveva visto**: il preventivo diceva 79% e 74,8%, ed
  erano numeri giusti — 100+100+100+4,5 fa 76. La media era vera e nascondeva
  che una casa su quattro è fuori. Terza volta in due versioni che un numero
  aggregato copre una misura che nessuno aveva guardato separatamente.
- **Tre difetti per strada**: «Pietra sopra Pietra» **0 su 64** perché chiede il
  grado 2 e *niente in partita arriva al grado 2* — è il buco che ISSUES 39
  opzione C riempirebbe; «L'Opera che Porta il Nome» al 5,9%; e il palese di
  Vaerax **0 su 20**.
- **E l'indice mentiva su ISSUES 26**: la voce era chiusa da 0.1.76 ma il titolo
  non portava la spunta. Ricontata: **47 carte su 48** hanno un mestiere, non 35
  su 48 come diceva la riga d'apertura.
- Nessuna regola accesa: sono decisioni di contenuto, e il numero è scritto
  prima perché si possa scegliere guardandolo.

## 0.1.176 — La mappa è ferma perché non ci sono pedine da muovere (D-208)

- Due rimedi per ISSUES 48 erano già stati misurati **a zero**. Il committente
  ha rifiutato la lettura consolatoria — «ogni era ha la sua Regione
  disabitata, è il mondo che racconta il secolo» — e ha spostato la domanda dove
  andava: **perché le pedine non si muovono?**
- Nessuna sonda lo sapeva dire. `run_move_probe` lo dice, e per ogni casa a fine
  anno nomina **quale porta era chiusa**: il gettone, la carta, la porta, o la
  voglia.
- **La risposta non è nessuna delle tre ipotesi della voce.** Ogni casa comincia
  con 2 pedine e il tetto è 3: ha **un** gettone di riserva per tutto l'anno. Lo
  posa, e da lì non ha più niente da muovere — a fine anno il **73%** dei seggi
  ha tutte le pedine sul tavolo.
- **Le carte abbondano** (12,57 MUOVERE viste in mano, 3,23 giocate) e la porta
  non è **mai** sbarrata: quello **0%** chiude da solo le tre ipotesi originali,
  adiacenza compresa.
- **E spostare non succede mai: 0,03 volte l'anno.** Non è un difetto nuovo, è
  D-185 che funziona — il cervello non toglie una pedina da dove la casa vive.
  Ma vuol dire che il gioco ha **due azioni diverse sotto lo stesso nome**, e la
  seconda è morta.
- **La Strada non è povera: è la Regione più ricca della mappa** — quattro
  vicini su cinque, 4 slot, WEALTH + KNOWLEDGE, tre tag di dominio più `trade`.
  Perde la corsa all'unico gettone perché nessuno ci comincia.
- **Tre rimedi prezzati, nessuno acceso**: il tetto a 4, gli studiosi che
  cominciano sulla Strada, e i due insieme. La combinazione è la sola che vince
  su ogni riga — la Strada diventa la **seconda** Regione più abitata (0,65 →
  **2,15**), nessuna scende sotto 1,60, i Consigli tornano dove stavano, e il
  playtest resta **0/8**.
- **L'effetto che nessuno cercava**: spostare Lyra sulla Strada **cura mezza
  ISSUES 52**. I suoi NONE crollano da 21 a 8 e le Vittorie salgono da 11 a 27.
  Il seggio che in dodici saghe non aveva mai trionfato non era debole: era nel
  **posto sbagliato**, a Eredan, dove Re Aldric ha già la parola.

## 0.1.175 — Anche l'anno d'apertura pesca le sue domande (D-207)

- «Le domande non dovevano essere pescate random all'inizio di una saga?» Metà
  della risposta era **sì, lo fanno**: su 12 saghe la biblioteca tira fuori **14
  mani diverse su 15 possibili**, e due saghe finiscono a **distanza 0,86** l'una
  dall'altra. L'altra metà dava ragione al committente: la pesca cominciava
  dall'**anno 2**, e ogni saga del Grano partiva dalle stesse quattro domande.
- **Nessuna sonda lo diceva, perché nessuna guardava l'apertura.** Il metro nuovo
  la nomina — mani d'apertura diverse, e distanza al primo anno — ed è così che
  «**1 mano su 12 saghe**» è diventato leggibile invece che vero e invisibile.
- **Adesso pescano tutte e quattro.** `CHR_01` tira 4 candidate su 6, `CHR_03`
  cinque su sei: pescarne quattro anche lì darebbe più combinazioni, ma
  cambierebbe la forma dell'anno del Sale per guadagnarle, e nessuno l'ha chiesto.
- **L'apertura si compone.** Il paragrafo scritto a mano nominava quattro domande
  e dava la Carestia per certa: dare la biblioteca senza spezzarlo avrebbe fatto
  leggere al tavolo un anno che non stava giocando. La Chronicle tiene la
  cornice, ogni domanda porta la propria riga, e una guardia impedisce che una
  candidata resti senza.
- **Il trabocchetto che stava per passare:** `library_sequel_of` deduceva «questa
  Chronicle continua se stessa» dall'**avere una biblioteca**. Vero per caso
  finché solo gli anni di seguito ne avevano una — con la biblioteca
  sull'apertura, una saga avrebbe **rigiocato la Carestia per dieci secoli**.
  Adesso il seguito si dichiara nel dato.
- **I numeri**: aperture diverse **1 → 6** (Grano) e **1 → 4** (Sale), distanza
  al primo anno **0,91 → 0,98** e **0,93 → 0,98**, distanza sulla saga intera
  **0,86 invariata**, playtest **0/8** a tavolo misto e uniforme.
- **Il prezzo, scritto**: i Consigli l'anno calano da 3,59 a **3,37** (uniforme) e
  da 3,97 a **3,73** (misto); nella linea del Grano i NONE salgono da 107 a 132 e
  i Trionfi scendono da 9 a 6. Il Sale non lo paga — Trionfi da 5 a **9**. La
  causa ha un nome ed è aperta come [ISSUES 51](docs/ISSUES.md).
- **Tre difetti trovati facendo**, tutti «una dichiarazione applicata nel momento
  sbagliato»: la biblioteca spenta *dopo* la pesca rompeva il **determinismo**
  (due esecuzioni dello stesso seme, due partite); i piani scriptati si
  dichiaravano dopo il setup mentre la sonda lo fa prima — la stessa distanza fra
  prova e spedizione di D-188; e il criterio «Deriva più Ripple bastano ad
  arrivare a soglia» era vero **di una Chronicle sola**, quella tarata a mano.
- **Due voci nuove**: [ISSUES 51](docs/ISSUES.md) — sei domande su dodici non
  arrivano a soglia da sole, e non ci arrivavano già prima; [ISSUES
  52](docs/ISSUES.md) — Lyra, **0 Trionfi e 37 NONE su 120 seggi-anno**.

## 0.1.174 — Il gioco a carte non aveva una storia perché il riempitivo parlava il gioco di prima (D-206)

- Da sei versioni il gioco si spedisce a carte e i tre piani scriptati sono
  rimasti tutte storie del §10 di prima. Stava in lista come «lavoro pulito,
  nessuna decisione richiesta»: **non era pulito, erano tre cose rotte, e nessuna
  era il piano**.
- **Il formato non sapeva dire «cala una carta»**: l'enum dello schema conosceva
  le sei azioni dirette e basta. Un piano nel gioco a carte era *inesprimibile*.
- **La guardia chiedeva a ogni piano di essere una storia vecchia**: un test
  pretendeva `actions_from_cards: false` per tutti. Scritto quando era vero di
  tutti, era diventato una legge. Ora ognuno **dice la sua**.
- **E la ragione vera: il riempitivo parlava il gioco di prima.** Le occasioni
  non scritte le riempiva ACQUISIRE → MUOVERE → passo, e nel gioco a carte le
  prime due non si pronunciano: **68 scelte illegali in una partita sola**, tante
  quante le occasioni libere. Adesso il riempitivo **cala una carta**, e a una
  carta che chiede un bersaglio dà la **domanda più fredda** — un riempitivo non
  deve decidere l'anno.
- **La storia**: `plan_d_crown_calls`, «La corona chiama subito». Aldric apre
  l'anno col Diritto di Corona in mano e la Carestia già a tre: non aspetta i
  gettoni, cala la carta e strappa il Consiglio nello stesso gesto. Quattro
  Consigli, uno cade, due Eco — e nessuno prende più di due obiettivi su quattro:
  è l'anno di chi ha parlato per primo, non di chi ha vinto.
- **Una guardia in più**: il test dei piani pretende adesso **almeno una storia
  per economia**. Senza, il gioco spedito può tornare a non averne nessuna, e
  come la prima volta non se ne accorgerebbe nessuno.
- Cancello: **408 test in 56 suite, 6770 asserzioni**; playtest **0 su 8**; sims
  exit 0 (quattro piani); toolchain e `--self-test` puliti.
- Verbale: [D-206](docs/DECISIONS.md#d-206), CONSEGNE §5bis.

---

## 0.1.173 — La Regione morta è quella dove non comincia nessuno (D-205)

- ISSUES 48 diceva «la Strada dei Mercanti è una Regione morta» e proponeva tre
  ipotesi. Rimisurando col gioco di adesso, **tutte e tre sbagliano bersaglio**.
- **La Strada è passata da 0,6% a 3,3%** delle pedine senza che nessuno la
  toccasse: l'ha alzata il gioco a carte. Ma il numero che spiega tutto è un
  altro: nel **Sale** la Strada sta al **13,8%** — terza più affollata — e la
  Regione morta sono le **Terre Nahr, all'1,7%**.
- **La Strada non è morta: è morta in un'era sola.** La causa è che le pedine si
  posano all'apertura e durante l'anno si muovono pochissimo: **la Regione vuota
  è quella in cui non comincia nessuno**, e cambia da un'era all'altra perché a
  cambiare sono le case.
- **Due rimedi provati, misurati, respinti**, tutti e due a zero: un **Pedaggio**
  sulla Strada (la struttura esisteva già nel catalogo e non stava su nessuna
  mappa) e un **cervello che conta anche i domini** oltre alle famiglie. 3,3%
  prima, 3,3% dopo, in entrambi i casi — perché quel ramo vive solo col gettone
  di riserva, e si gioca una volta per partita.
- **Tutti e due tolti**: un cambiamento che non muove nessun numero, tenuto, è
  peggio di una misura scritta — il prossimo lettore lo trova e crede che serva.
- **Quello che resta è una riga nella sonda**: `run_hand_probe` adesso **nomina**
  la Regione in cui non comincia nessuno invece di lasciarla dedurre.
- La voce cambia forma: non «la Strada è morta», ma «ogni era ha una Regione dove
  non vive nessuno». Da decidere se è un difetto o se è la mappa che racconta chi
  c'era in quel secolo.
- Verbale: [D-205](docs/DECISIONS.md#d-205), [ISSUES 48](docs/ISSUES.md).

---

## 0.1.172 — Due case su otto non potevano chiamare il Consiglio (D-204)

- ISSUES 37 lo aveva scritto in anticipo: *«o quando ISSUES 49 arriva e questa
  azione diventa quella che gira i mucchi coperti, e allora la domanda cambia
  forma»*. È arrivata. Col cancello del tavolo **RIVENDICARE è l'unico modo che
  un giocatore ha di aprire un Consiglio quando vuole lui**, quindi la prima
  domanda non è più «quante prenotazioni muoiono»: è **chi ha mai avuto in mano
  il diritto di chiamare**.
- **La misura, che non avevo mai preso**: su 40 Chronicle, la Cenere non aveva
  **mai** avuto una carta RIVENDICARE — **zero volte in venti partite** — e il
  Vaerax una ogni quattro. Le due case della montagna non potevano,
  materialmente, chiedere al tavolo di riunirsi.
- **Perché**: RIVENDICARE stava su **4 carte delle 48, tutte AUTORITÀ**, e
  l'AUTORITÀ si pesca solo da Eredan e dalle Terre Nahr. Chi tiene le montagne
  pesca FORZA, LEGAMI, SAPERE, e nessuna sapeva prendere la parola.
- **Quattro carte spostate**, scelte perché la finzione ci stava già dentro:
  **Assedio** (FORZA), **Debito Vecchio** (LEGAMI), **Deposizione Sigillata**
  (SAPERE), **Portavoce** (GENTE) — *«prende la parola al posto della folla»*, che
  è esattamente cosa vuol dire RIVENDICARE. Otto carte in **cinque famiglie**, e
  **ogni Regione della mappa** ne pesca almeno una.
- **Il risultato**: Cenere da 0,00 a **1,05** carte per partita, Vaerax da 0,25 a
  **1,50**. Lo scarto fra chi può chiamare di più e chi di meno passa da
  **infinito** a **3,1 volte**.
- **Le prenotazioni morte scendono ma non abbastanza**: dal **67%** al **56%**,
  contro un criterio del 33%. Quella metà di ISSUES 37 **resta aperta** — e il
  67% di partenza era già peggio del 41% di 0.1.159, perché con meno Consigli una
  prenotazione ha meno occasioni di essere riscossa.
- **E la sonda conta le carte invece di crederci**: `run_rung_probe` leggeva «4
  carte, tutte AUTORITÀ» da una riga battuta a macchina. Ora legge il mazzo.
- Cancello: **408 test in 56 suite, 6738 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme (Consigli 3,59 e 3,97); sims exit 0; toolchain pulita.
- Verbale: [D-204](docs/DECISIONS.md#d-204), [ISSUES 37](docs/ISSUES.md),
  MECCANICA §5.

---

## 0.1.171 — Una soglia sola per il tavolo, e il tre che non vale più tre (D-203)

- **ISSUES 49 fase 2**, sulla scelta **b** del committente: il Consiglio non lo
  chiama più la singola domanda che supera il proprio numero. Si apre quando sul
  tavolo sono scesi **tanti gettoni in tutto**, e a dibattersi va il **mucchio
  più alto**. Poi il conto riparte da zero.
- **Il numero scelto non vale più quel numero.** Il preventivo diceva «ogni 3
  segnalini riproduce il ritmo di oggi», ma era misurato nel gioco di prima, con
  18 azioni l'anno invece di sei. **E il tre non passa le guardie**: due anni su
  dodici in CHR_02 e tre su dodici in CHR_04 chiudono con **un** Consiglio, sotto
  il limite duro di 2. Ho spedito il **due**, e scrivo perché non è il tre.
- **Il prezzo, dichiarato**: il Consiglio passa da **6,03 e 6,01** l'anno a
  **3,46 e 4,00**. Da due per Atto a poco più di uno. È il cambiamento più grosso
  al ritmo dell'anno da quando le carte sono l'unica moneta, e si torna indietro
  con **una chiave**. Non è un difetto: a soglie più domande maturano insieme e le
  altre si accodano, col cancello del tavolo ogni apertura consuma **tutto** il
  calore. Il Consiglio smette di essere routine.
- **L'innesco a chiamata c'era già**: chi ha una rivendicazione matura la spende e
  apre il Consiglio sulla domanda che vuole. Anche quello svuota il sacchetto.
- **Tre posti dove una persona leggeva un numero che non succede più** (§5ter): il
  verbale diceva `Carestia: 4/7` e ora dice `Carestia: 4` segnando **quale mucchio
  è il più alto**; `visible_tension_threshold` torna **−1** col cancello acceso,
  così nessun pannello può scriverlo; la pagina delle regole prometteva «quando
  una arriva alla sua soglia» ed elencava le soglie — ora dice come funziona
  davvero, e che un Consiglio lo puoi aprire anche tu.
- **Una guardia perché non resti un numero morto**: `table_gate` e
  `threshold_bonus` insieme fanno rosso la CI. Il ritocco di D-192 alzava una
  soglia che adesso non apre niente; tolto da tutte e quattro le Chronicle.
- **Non fatti i mucchi coperti**: il cancello cambia *chi decide quando*, coprire
  i valori cambia *cosa si sa*, e va misurato a parte.
- Cancello: **408 test in 56 suite, 6737 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme; sims exit 0; toolchain e `--self-test` puliti.
- Verbale: [D-203](docs/DECISIONS.md#d-203), [ISSUES 49](docs/ISSUES.md).

---

## 0.1.170 — Il Sale conta anche lui, e la carta della terra torna a costare qualcosa (D-202)

- **Il mondo del Sale passa agli obiettivi**, dopo aver messo a posto i suoi
  Destini: il palese per casa passa da uno scarto di **31,0 a 13,7 punti** —
  meglio del 19,6 con cui è rimasta la prima saga.
- **Il primo cambiamento è un errore mio di due voci fa.** `DST_SHARED_LAND`
  costava alla Cenere il **100%**: non era così prima, era all'11,5%, e l'ho
  portata lì **io** in 0.1.167 allargando quella carta per aiutare Vaerax, che
  l'aveva al 16,7%. Ho aggiustato un estremo e ne ho creato uno peggiore
  dall'altra parte — la prova più netta della regola che avevo appena scritto:
  una carta che conta *il tuo tavolo* non si rende equa allargandola, si sposta.
- **`DST_LIBERE_WATER`** da 96,3% a **48,1%**: chiedeva un segno globale e la
  presenza dove le città stanno già. Ora chiede anche che il mondo non sia stato
  aperto in più di due punti — l'acqua non torna dove si è combattuto.
- **`DST_SALE_OPEN`** da 67,9% a **42,9%**: «il registro si può leggere» e non
  chiedeva che i conti fossero chiusi.
- **Una guardia ha morso mentre lavoravo**: alzando la Vittoria dell'Acqua avevo
  reso vera una delle strade del suo Trionfo, e `check_destiny_free_roads` l'ha
  detto subito. Senza, il Trionfo sarebbe diventato più facile mentre rendevo la
  Vittoria più dura, in silenzio.
- **Il tavolo intero, con tutte e quattro le Chronicle che contano** (800 seggi):
  0 su 4 nel **18,5%**, 4 su 4 nell'**1,9%**, media **1,45**, saga **+1,56**.
- **Un numero di contenuto è sceso, dichiarato**: la seconda saga pesca **10**
  Destini invece di 11, perché «La Terra che Risponde» ha lasciato il pool della
  Cenere. Ho preferito scrivere il numero più basso che inventare una carta per
  far tornare un conteggio.
- Cancello: **401 test in 55 suite, 6887 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme (Consigli 6,03 e 6,01); sims exit 0; toolchain e
  `--self-test` puliti.
- Verbale: [D-202](docs/DECISIONS.md#d-202), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.169 — Il mondo del Sale passa alle carte, e una saga smette di giocare a due giochi (D-201)

- **Un buco che stava lì da due versioni**: CHR_02 contava i gradini mentre
  CHR_01 contava gli obiettivi. Sono i due anni della **stessa saga**, e il
  punteggio di campagna sommava due scale **senza dirlo**, perché con gli
  obiettivi il livello si deriva e a valle sembra identico.
- **`check_a_saga_plays_one_game`**: le Chronicle si appaiano per lista dei seggi
  e sei regole si confrontano. Una regola accesa da una parte non può essere
  spenta dall'altra. Provata a morso sul caso vero.
- **CHR_03 e CHR_04 passano alle carte**: azioni dalle carte, rubinetto, presa di
  parola in un colpo, sacchetto dei gettoni. Tutto insieme, perché le metà si
  accendono insieme o si misura un terzo gioco che nessuno gioca.
- **La misura intermedia, scritta perché vale**: con le sole carte i Consigli
  erano crollati a **5,01 e 4,81** l'anno. Il sacchetto è la metà che rimette il
  calore.
- **E il +1 alle soglie che CHR_01 aveva chiesto è sbagliato per CHR_03**: 3,90
  Consigli l'anno con il bonus, **5,55 senza**. Due mondi che postano calore
  diverso non vogliono la stessa soglia — ed è esattamente il numero che una
  dichiarazione per Chronicle esiste per portare.
- **La mano del Sale**: 6,00 → 6,66 → **6,79** carte, e lo scarto fra la più
  piena e la più vuota **non cresce** (0,00 → 1,07 → 0,60), meglio dell'1,58 di
  CHR_01.
- **Non accesi gli obiettivi nel Sale**, di proposito: i suoi Destini sono i più
  facili di tutti (Libere-Acqua al **96,3%**) e accenderli adesso rimetterebbe in
  campo il difetto che 0.1.167 ha appena chiuso. Prima i Destini, poi il
  punteggio.
- Cancello: **401 test in 55 suite, 6887 asserzioni**; playtest **6,05 e 6,04**
  Consigli, **0 su 8** a tavolo misto e uniforme; sims exit 0; toolchain e
  `--self-test` puliti.
- Verbale: [D-201](docs/DECISIONS.md#d-201).

---

## 0.1.168 — Il quarto obiettivo pagato come una cosa rara (D-200)

- D-199 aveva reso il palese più equo e, per farlo, più caro: il punteggio di
  saga era sceso da +1,51 a +1,30. Ho scritto il numero peggiorato invece di
  compensarlo da solo, e il committente ha deciso: **compensare un po'**.
- `objectives.saga_points` per CHR_01: **−1 · 1 · 2 · 5 · 8** (era −1 · 1 · 2 ·
  4 · 6). Misurato: **+1,45 per seggio** — **recuperati tre quarti**, e il quarto
  che manca resta il prezzo dichiarato di un palese che costa uguale a tutti.
- **I punti sono andati sul terzo e sul quarto obiettivo**: sono i due che quasi
  nessuno prende (10,8% e 1,8%), e un trionfo che capita a un seggio su
  cinquantacinque deve valere più del doppio di «due su quattro». I due estremi
  restano dove erano: un anno senza niente toglie, e prenderne uno vale poco.
- **Due guardie**, perché la scala è un posto dove si sbaglia in silenzio:
  `levels` e `saga_points` sono indicizzate dal conto e il motore satura
  sull'ultima casella, quindi una scala più corta farebbe valere **uguale due
  risultati diversi** senza nessun errore. Ora la CI pretende che siano lunghe
  quanto il conto e che i punti salgano. Provate a morso, più un test sui dati
  spediti.
- Cancello: **401 test in 55 suite, 6889 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme; sims exit 0; toolchain e `--self-test` puliti.
- Verbale: [D-200](docs/DECISIONS.md#d-200), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.167 — Il palese pagato quasi uguale da tutte le case (D-199)

- Il difetto che D-196 aveva trovato per strada e che D-198 ha acceso lo stesso,
  dichiarandolo: **il palese vale un quarto del risultato e non costava uguale a
  tutti** — un vantaggio distribuito alla nascita.
- **La misura che conta è per casa, non per Destino**, perché una casa non
  sceglie quale dei tre le tocchi. Su 200 Chronicle, stessi semi: Nahr da
  **80,9% a 54,2%**, Lyra da 52,5% a 34,6%, Aldric e Vaerax fermi. **Lo scarto
  fra la casa più cara e la più facile passa da 43,2 a 19,6 punti** — meno della
  metà.
- **Quattro cambiamenti, tutti nei dati**: `DST_NAHR_ROOTED` chiede due segni di
  non essere di passaggio invece di uno; `DST_LYRA_TAUGHT` — che si chiama «Il
  sapere ha un posto suo» — adesso **il posto lo chiede**; `DST_SHARED_LAND`
  accetta due Regioni tenute **o** due cose in piedi; e Nahr, che aveva tre
  Destini di terra su tre, scambia il condivisibile con «I Conti Chiusi».
- **La regola generale imparata misurando**: una carta condivisibile costa
  uguale a tutti **solo se parla del mondo, non del tuo tavolo**. «I Conti
  Chiusi» guarda i segni globali e costa 42–45% a chiunque; «La Terra che
  Risponde» conta le *tue* Regioni, e allora il prezzo è la posizione di
  partenza travestita da ambizione.
- **Due residui, scritti invece che nascosti**: `DST_NAHR` resta a 72,5% (ci ho
  provato due volte e il numero non si è mosso: quello che costa sono le sue
  prime due clausole, e cambiarle vorrebbe dire riscrivere cosa significa) e
  `DST_SHARED_LAND` giurata da Vaerax resta a 16,7%.
- **Il prezzo, dichiarato**: più equo vuol dire più caro. 0 su 4 da 16,5% a
  **20,8%**, media da 1,51 a **1,37**, saga da +1,51 a **+1,30**. Non ho
  compensato con `saga_points`: prima va deciso se è la durezza giusta.
- Cancello: **400 test in 55 suite, 6881 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme (Consigli 6,15 e 6,30); sims exit 0; toolchain pulita.
- Verbale: [D-199](docs/DECISIONS.md#d-199), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.166 — Gli obiettivi al posto dei gradini, accesi (D-198)

- **CHR_01 non sale più una scala: conta.** Uno palese — il Destino giurato, che
  sanno tutti — e tre coperti pescati all'apertura dal pool dei dodici. Tutti e
  quattro è un trionfo, nessuno è un anno perso, in mezzo ci sono i successi
  parziali, e ognuno vale un numero diverso alla fine della saga.
- **Regola dichiarata dalla Chronicle**, reversibile come tutte le altre: una
  Chronicle che non scrive `objectives` gioca coi tre gradini di sempre.
- **Il livello non sparisce: si deriva dal conto** (`levels`). Toglierlo avrebbe
  rotto in un colpo il verbale, il pannello, il libro della saga, il salvataggio
  e il punteggio di campagna, che leggono tutti un livello.
- **Quello che il gioco conta davvero** su 100 Chronicle: 0 su 4 nel **19,0%**
  dei seggi, tutti e quattro nel **2,5%**, media **1,44**. La sonda ombra
  prometteva 1,58 — **era ottimista del 9%**, e la differenza è dichiarata.
- **Il lato umano, cercato invece che aspettato** (§5ter): pannello del seggio e
  console mostrano i quattro obiettivi coi coperti segnati; la riga del verbale
  dice il conto e quali, invece dell'etichetta di un gradino che il giocatore
  non ha chiuso; la pagina delle regole dice che non si sale, si conta. Tutti e
  tre leggono **una funzione sola**, `objectives_of()`.
- **Un errore trovato solo guardando la pagina**: un `+` e un `%` in ordine
  sbagliato mandavano la formattazione in errore a **ogni apertura**, con la
  suite verde perché nessun test leggeva quel testo. Ora tre test lo coprono.
- **Il lato classico si spegne intero**: cancellare la dichiarazione non bastava,
  perché `setup()` aveva già pescato i coperti sul seggio — due metà di due
  giochi diversi, lo stesso errore che D-184 aveva già pagato col rubinetto. Due
  test di determinismo l'hanno detto subito.
- **I tre piani scriptati dichiarano su quale scala si leggono**: una storia
  scritta a mano finisce dove finisce.
- Difetto aperto e dichiarato: il palese costa dal **35,7% all'80,0%** a seconda
  della casa. CHR_03 non è ancora passata: prima l'economia, poi il punteggio.
- Cancello: **400 test in 55 suite, 6882 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme; sims exit 0; toolchain e `--self-test` puliti.
- Verbale: [D-198](docs/DECISIONS.md#d-198), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.165 — Il pool degli obiettivi, dodici carte misurate una per una (D-197)

- D-196 aveva detto che il pool non c'era. Ora c'è: **nuovo schema `objective`**
  — un traguardo piatto, senza gradini, con la riga che va a verbale — e
  **dodici obiettivi** in `godot/data/objectives/objectives_shared.json`.
- **Ogni carta misurata da sola** su 100 Chronicle: dal **79,0%** («Qualcosa che
  Resta in Piedi») al **10,2%** («Le Corde che Tengono»). Nessuno sotto il 10%,
  nessuno sopra l'80% — il criterio che D-196 aveva posto. Media 34,0%.
- **Due bocciati coi numeri**, i due che sembravano più belli: *«La Parola
  Data»* al **100%** (un regalo travestito da scrupolo) e *«Il Mondo Intatto»* al
  **2,0%** (arredo). La stessa idea a due cicatrici sta al 22%, e quella è
  entrata.
- **La distribuzione migliora senza toccare una soglia**: 0 su 4 passa da 27,2%
  a **16,2%**, la media da 1,26 a **1,58**, il punteggio di saga da +1,17 a
  **+1,65**. Sono cambiate solo le carte del pool.
- **Due guardie nuove**: `check_objectives_are_shareable` (un obiettivo che
  nomina una casa, una Regione o una Tensione è falso per costruzione nell'altro
  mondo) e `check_condition_vocabularies_agree` (il vocabolario delle clausole è
  ora scritto in due schemi: che dicano la stessa cosa). Più cinque test in
  `test_objective_pool.gd`, provati a morso.
- **Correzione a D-196**: il palese va dal **35,7% all'80,0%** fra gli otto
  Destini identitari; il 91% citato era `DST_LIBERE_WATER`, una variante.
- **Il motore non è ancora cambiato**: nessuna partita pesca obiettivi, i tre
  gradini sono ancora la scala di §14. Il pool è il preventivo che diventa dato.
- Verbale: [D-197](docs/DECISIONS.md#d-197), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.164 — Il preventivo dei quattro obiettivi (D-196)

- Il committente ha chiuso la domanda rimasta aperta: **gli obiettivi
  sostituiscono i gradini**, quattro se ne pescano e quattro se ne contano.
- **Nessuna regola cambiata.** Come per il sacchetto, prima si misura: nuova
  sonda ombra `godot/cli/run_objective_probe.gd`, che gioca le partite come sono
  e a fine anno rilegge il mondo chiedendogli cose che il gioco non gli chiede.
- **Su 100 Chronicle, 400 seggi, tavolo misto**: il NONE passa da **0,8% a
  27,2%**, il trionfo da **16,8% a 2,2%**, il punteggio di saga da **+2,51 a
  +1,17** per seggio. Il ritorno della possibilità di perdere è il cambiamento
  più grosso della proposta — più del trionfo.
- **Un difetto trovato per strada**: il palese non costa uguale a tutte le case
  (dal **41%** di Aldric al **91%** delle Libere). Se vale un quarto del
  risultato, è un vantaggio distribuito alla nascita.
- **Il pool non c'è ancora**: sei candidati, uno dei quali si avvera nell'1,8%
  dei seggi. Ne servono almeno dodici, nessuno sotto il 10% o sopra l'80%.
- Verbale: [D-196](docs/DECISIONS.md#d-196), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.163 — Quello che una persona legge, riscritto dalle regole (D-195)

- Il seguito di D-194, **cercato invece che aspettato**: nessuna misura copre il
  lato umano, quindi ho guardato uno per uno i posti dove una regola nuova cambia
  ciò che una persona **legge**. Ce n'erano altri tre.
- **Il menu offriva di scoprire una cosa già visibile**: «Scopri il numero di…»
  quando da D-187 il velo copre la **soglia** e il numero è sul tavolo. Ora dice
  «Scopri a quanto esplode», e «Copri la soglia» al posto di «Cala il velo».
- **Il sacchetto cambiava il mondo in silenzio**: il gettone applicava il suo
  Effetto senza una riga a verbale, mentre la Deriva che sostituisce lo ha sempre
  detto. Ora: «Il gettone cade su La Carestia: sale di 1». Era D-030 rotta.
- **La pagina delle regole dentro l'app prometteva il gioco di tre versioni fa**:
  «un'azione è una di queste sei cose», «Acquisire — peschi una carta», «Tramare
  — leggi il numero». In cima a quel file c'era già scritto perché è successo:
  *«le parti che possono sfasarsi sono quelle che vengono dai dati»* — e metà
  pagina, quella generata, non è sfasata di una virgola. **L'elenco delle azioni
  era battuto a macchina.** Adesso si scrive anche lui dalle regole.
- Playtest **identico riga per riga**: `FAIL 253 · 111 · 127 · 113`, Consigli
  6,04, mediana 6, **0 su 8**. Suite **384 test / 6713 asserzioni**, con quattro
  prove che leggono la pagina dai due lati dell'interruttore.

### Dichiarato

- **Ho guardato tre posti, non tutti**: ho seguito velo, rubinetto e sacchetto
  dentro `seat_decider`, le viste e la pagina delle regole. È un campione
  ragionato, non un inventario.
- **La pagina ora ha una prova, il registro no**: che ogni mutazione si racconti
  resta affidato alla disciplina.
- **`MECCANICA.md` e la pagina dell'app dicono la stessa cosa per due strade
  diverse**: il documento è scritto a mano e può ancora sfasarsi.
- Il committente ha trovato in un minuto quello che tre versioni di misure non
  hanno visto: **le sonde guardano cosa fa il gioco, non cosa dice.**

---

## 0.1.162 — I bot erano passati alle carte, le mani no (D-194)

- **Trovato dal committente guardando l'app**: «su Pages non è cambiato nulla,
  mi sembra una vecchia versione».
- **Pages era aggiornato** — il workflow ha pubblicato dopo ogni merge, l'ultimo
  alle 21:33 con esito verde. Quello che sembrava vecchio **era il gioco**: il
  menu proponeva ancora «Acquisisci una carta AUTORITÀ», e sceglierla la faceva
  rifiutare un istante dopo.
- **La causa**: D-188 ha spostato il divieto delle sei azioni dirette da
  `check()` a `execute()` — per la ragione giusta — ma il menu umano si
  costruisce proprio con `check()`. Migrato il cervello dei bot, lasciate
  indietro le mani.
- **Adesso il menu offre le carte**: ogni azione compare una volta per ogni carta
  in mano che sa dirla — *«Mercenari» — Metti una presenza in Valle Verde* — e
  quelle che nessuna carta sa dire spariscono. Un punto solo, e copre schermo del
  tavolo, terminale e console del telefono.
- **Il test che doveva proteggere quella promessa è rimasto verde per tre
  versioni**: chiedeva `can_execute`, cioè `check()`, ed era `check()` ad aver
  smesso di rifiutare. Quello nuovo guarda dal lato giusto e, tolta la
  correzione, morde con lo stesso messaggio visto sull'app.
- Playtest **identico riga per riga**: `FAIL 253 · 111 · 127 · 113`, Consigli
  6,04, mediana 6, **0 su 8**. Suite **380 test / 6674 asserzioni**.

### Dichiarato

- **Nessuno se n'era accorto perché nessun bot usa quel menu**: il playtest, che
  è il cancello di casa, gioca solo con `PolicyDecider`. Non c'è sonda che copra
  quello che il committente guarda — l'ha trovato aprendo l'app.
- **Il rischio è strutturale**: ogni volta che una regola si sposta fra `check()`
  ed `execute()`, il menu umano cambia senza che nessuna misura lo dica. La
  guardia nuova copre il caso delle carte, non il prossimo.
- **Velo, rubinetto e sacchetto non sono stati riguardati dallo stesso punto di
  vista**: cambiano cosa una persona vede, e sono stati provati solo dal lato
  dei bot.

---

## 0.1.161 — La mano non sapeva dire metà di quello che il seggio voleva (D-193)

- La prima voce di CONSEGNE §5bis, scomposta: dei 720 turni misurati, **235** il
  cervello non voleva niente, **214** voleva qualcosa che la mano non sapeva
  dire, **271** hanno prodotto qualcosa.
- **Il modo di TRAMARE è libero**: le otto carte fissavano `REGION`, `TENSION` o
  `ECHO_DECK`, e chi voleva scoprire una domanda con in mano una carta da «leggi
  una Regione» passava il turno. **Mute di TRAMARE da 56 a 15.** È D-184
  riapplicato, e la terza volta che lo stesso difetto torna su una famiglia
  diversa.
- **La FORZA aveva un solo verso**: tre INFLUENZARE su tre, tutte +1. Una casa su
  Eredan e Montagne poteva solo scaldare il mondo. Il Posto di Blocco ora fa −1.
- **Un difetto vero trovato da un test**: la Chronicle di **libreria** faceva 2
  Consigli mediani invece di 3–7. Il sacchetto di D-192 leggeva la
  `drift_distribution` **scritta nella Chronicle**, che una Chronicle di libreria
  non ha — sacchetto vuoto, Deriva spenta perché il sacchetto la sostituisce, e
  l'anno non si scaldava mai. Ora il sacchetto è la traccia già mescolata.
- `FAIL 253 · 111 · 127 · 113`, Consigli 6,04, mediana 6, **0 su 8**. Suite
  **379 test / 6665 asserzioni**.

### Dichiarato

- **Il totale delle Occasioni mute non si è mosso**: 62% prima, 62% dopo. Le
  mute di TRAMARE sono crollate e i seggi hanno usato le Occasioni liberate per
  fare altro. **Non è un difetto da riparare**: è la forma del gioco senza
  ACQUISIRE.
- **Il paragone onesto**: nel gioco di prima le azioni diverse da ACQUISIRE erano
  3,2 per seggio all'anno su 18 Occasioni — il **18%**. Adesso succede qualcosa
  nel **37%**. Il gioco a carte è più attivo di quello che ha sostituito.
- **Gli 80 «la carta spinge dalla parte sbagliata» non sono un difetto**: la
  Folla non argomenta, sale di 1. Liberare anche il verso farebbe di ogni carta
  un jolly e toglierebbe il carattere.
- La FORZA resta sbilanciata (due su tre spingono in su): è voluto, non è
  misurato quanto costi a chi tiene solo Regioni di FORZA.

---

## 0.1.160 — Il calore lo pescano i giocatori (D-192)

- **ISSUES 49 fase 1**, sulla scelta **b** del committente. Ogni azione riuscita
  pesca un gettone dal sacchetto e lo posa su una domanda: il mondo si scalda
  perché qualcuno ha fatto qualcosa, non perché è passato il tempo. La Deriva a
  orologio si spegne.
- Il sacchetto è quello che c'era già — la distribuzione della Deriva (D-047),
  tarata dal committente. Dichiarato sulla Chronicle (`tension_tokens`).
- **Il preventivo di D-190 era sbagliato di due volte, ed è corretto qui.** La
  sonda ombra contava ogni firma d'azione distinta (una carta ne produce più
  d'una): i gettoni veri sono **~10 l'anno**, non 18,7. E soprattutto
  paragonavo i gettoni ai 9 della Deriva come se fosse tutto il calore del
  mondo: **CHR_01 ne posa 35,9 l'anno**, e la Deriva ne mette 9. Il sacchetto ne
  aggiunge dieci e ne toglie nove — **il calore totale cambia del 7%**, non del
  210%.
- **Le soglie salgono di 1, non del doppio**: misurato, +1 riporta i Consigli
  esattamente al ritmo di prima (5,93 l'anno contro 5,97); il raddoppio li
  dimezzava a 3,33.
- **Il ritocco sta sulla regola, non sulla Tensione** (`threshold_bonus`): la
  stessa Tensione gioca anche dove il sacchetto è spento, e lì una soglia alzata
  non si raggiunge mai — col dato riscritto il gioco classico faceva **zero
  Consigli**.
- **0 su 8** misto e uniforme, Consigli media 6,35, mediana 6. Suite **379 test
  / 6760 asserzioni**, sim plans e determinismo verdi.

### Dichiarato

- **Due difetti miei, trovati dai test.** Il gettone si firmava con la mano che
  aveva agito, e un gettone posato da un INFLUENZARE si contava come un secondo
  INFLUENZARE: **il tetto di §10 saltava**. E il seggio leggeva la soglia scritta
  mentre il Consiglio si apriva su quella ritoccata — decidevano su due numeri
  diversi. Corretti entrambi, con un test ciascuno.
- **La scelta b non è ancora costruita**: questa è la metà del calore. La soglia
  sola per il tavolo arriva quando i mucchi saranno coperti e l'innesco a
  chiamata. Il numero misurato resta **tre gettoni**.
- **I gettoni non sono ancora coperti**: coprirli è fase 2, e lì il velo di
  D-187 diventa inutile perché tutto è coperto per costruzione.
- **I 21 presagi e le 19 clausole dei Destini non sono stati toccati**: col
  calore che cambia del 7% non serviva. È una decisione presa sul numero
  corretto, non una dimenticanza.
- **CHR_03 non è toccata**: lì il calore lo mette ancora l'orologio.
- **I Consigli falliti salgono da 239 a 249**: il calore a raffiche apre più
  tavoli nei round affollati, e lì si oppone più gente.

---

## 0.1.159 — Non si prenota una domanda che è già matura (D-191)

- **Decisione del committente su §10**, la metà aperta di **ISSUES 37**: se la
  Tensione è **già matura** (valore ≥ 3), prendere la parola è **un'azione sola**.
  La prenotazione resta per il caso vero — la domanda che *non* è ancora matura.
- Nasce dalla scelta «**l'innesco lo apre un giocatore**»: un innesco a chiamata
  non è un innesco se la chiamata non riesce mai.
- Dichiarata sulla Chronicle (`claim_rules.same_round_when_ready`, `ready_at`):
  il §10 di sempre resta provato e si riaccende cambiando una riga.
- **Il modo delle quattro carte RIVENDICARE è stato liberato**: prenotare o
  strappare lo decide chi cala la carta, non la carta. È D-184 applicato.
- **Le morte in mano su CHR_01, in 40 partite: da 57 su 73 (78%) a 11 su 27 (41%).**
- Cancello: `FAIL 239 · 100 · 134 · 126`, Consigli 5,99, mediana 6, **0 su 8**.
  Suite **374 test / 6555 asserzioni**.

### Dichiarato

- **Il criterio di ISSUES 37 non è raggiunto**: chiedeva le morte sotto una su
  tre, siamo a 41% da 78%. Quasi dimezzate, non abbastanza. La metà resta aperta.
- **Due strade più aggressive sono state respinte coi numeri**: togliere del
  tutto la prenotazione al bot azzera le morte ma azzera anche le prenotazioni
  (e porta i Consigli falliti da 239 a 252); impedire al ripiego di giocare una
  carta RIVENDICARE alla cieca compra 2 punti di morte in meno e costa **19
  Consigli falliti**.
- **Una misura precedente era contaminata e l'ho corretta**: la sonda dei gradini
  alterna CHR_01 e CHR_03, e metà del campione veniva dal mondo dove la regola è
  spenta. I numeri qui sopra sono CHR_01 da sola.
- **CHR_03 non è toccata**: lì §10 è quello di sempre, morte al 78%. È il termine
  di paragone.
- **Forzare un Consiglio non è un Effetto** (`world["forced_confluence"]` si
  scrive a mano): una delle poche mutazioni senza inverso. Con l'innesco a
  chiamata diventerà il cuore del turno, e lì andrà fatta come si deve.
- I tre piani scriptati dichiarano ora anche `claim_rules` fra i propri
  `chronicle_overrides`, e una guardia lo verifica: è la stessa lezione di D-189.

---

## 0.1.158 — Il prezzo del sacchetto dei segnalini coperti (D-190)

- **Nessuna regola cambiata**: è il preventivo di **ISSUES 49**, la
  riprogettazione delle Tensioni voluta dal committente — «ogni carta o azione fa
  pescare uno o più segnalini coperti che danno un valore a una tensione».
- **Il sacchetto esiste già**: la Deriva è nove gettoni mescolati col seme. La
  proposta cambia **chi pesca** (i giocatori agendo) e **quando si guarda** (al
  Consiglio). Sonda nuova, `run_token_probe.gd`.
- **Il sacchetto funziona solo nel gioco a carte**: **18,7** segnalini l'anno in
  CHR_01 (2,1× la Deriva) contro **72,4** in CHR_03 (8,0×), dove ogni ACQUISIRE
  scalderebbe il mondo. Le due riprogettazioni hanno bisogno l'una dell'altra.
- **L'innesco che riproduce il ritmo di oggi**: un segnalino ogni **3** dà 5,95
  Consigli l'anno contro i 5,90 di adesso — e al tavolo si conta a occhio. A
  orologio darebbe 3 (fine Atto) o 9 (fine round).
- **Il numero che decide**: su 354 Consigli veri, il mucchio coperto avrebbe
  scelto la stessa domanda il **31%** delle volte. Sette su dieci si dibatterebbe
  altro. **Non è colore: è un altro gioco.**

### Dichiarato

- La sonda tiene un **mondo ombra** e non cambia niente: dice quanti segnalini
  scenderebbero, non come andrebbe la partita — con la regola accesa i seggi
  agirebbero diversamente, e questo la sonda non lo sa.
- **L'innesco «a chiamata» non è misurato** ed è quello che mi sembra migliore:
  non è misurabile con una sonda ombra perché dipende da una decisione che oggi
  nessun bot può prendere. Salderebbe **ISSUES 37**: RIVENDICARE diventerebbe il
  motore delle Tensioni invece di morire in mano tre volte su quattro.
- **Il sacchetto misto (1/2/3) è fuori scala**: 3,6× vuol dire rifare le soglie,
  non ritoccarle.
- La sonda pesca **a caso e uniformemente**: se è la carta a dire quale domanda
  si scalda, è un terzo gioco e non è misurato.
- Renderebbe inutile il velo di D-187, **in meglio**: tutte le domande sarebbero
  velate per costruzione, e TRAMARE diventerebbe «sbircio un segnalino».

---

## 0.1.157 — Un piano dice in che economia è stato scritto (D-189)

- **Riparazione di 0.1.156, trovata dalla CI.** Accendere le carte in CHR_01 ha
  reso ingiocabili i tre piani scriptati: `tools/run_sims.sh` usciva con **exit
  4** su tutti e tre. Dire in un verbale che «restano storie del §10 di prima»
  non bastava — i piani leggono la Chronicle spedita.
- **E la suite diceva verde**: passava dal `play_classic()` di 0.1.156 e provava
  il gioco vecchio, mentre la sonda da riga di comando provava quello nuovo. Due
  strade che provano due giochi diversi e si chiamano entrambe «i piani passano».
- **`chronicle_overrides` sul piano**: `actions_from_cards` e `hand_refill`. I
  tre piani dichiarano `false` — sono storie del §10 di prima, e ora lo dicono
  loro invece di un verbale.
- Le due strade passano dalla **stessa funzione** (`GameSession.apply_plan_overrides`),
  e una **guardia in `validate_data.py`** fa rosso la CI se una Chronicle gioca a
  carte e il piano non dichiara niente.
- CI locale intera rifatta guardando **gli exit code**: validate, self-test, i due
  drift check, dead_code, 372 test / 6722 asserzioni, sim plans, balance probe,
  determinismo di sims ed export. Tutto verde.

### Dichiarato

- **Il difetto è mio e la CI l'ha trovato al posto mio**: avevo lanciato
  `run_sims.sh` con l'output a `/dev/null` guardando solo se i file cambiavano.
  Il comando diceva «FALLITO (exit 4)» tre volte. La regola che ne esce è in
  CONSEGNE: dei comandi del cancello si guarda **l'exit code**.
- Resta vero che **manca un piano scriptato del gioco a carte**: adesso la
  mancanza è dichiarata nel dato, non solo in un verbale.
- `chronicle_overrides` è una porta che si può abusare: lo schema la tiene
  stretta a due chiavi apposta.

---

## 0.1.156 — Le quarantotto carte parlano (D-188)

- **ISSUES 47 fase 4**: le azioni passano sulla mano, e **l'interruttore si
  accende**. Il telaio era di D-184, il rubinetto di D-185, la mappa di D-186.
- **Tutte e 48 le carte portano un'azione**: 17 INFLUENZARE, 11 MUOVERE, 8
  TRAMARE, 8 FORGIARE, 4 RIVENDICARE. **ACQUISIRE sparisce** — era due terzi del
  gioco, e adesso la fa la mappa.
- La distribuzione non è casuale: la Regione decide che carte peschi, quindi
  **la mappa decide che cose puoi fare**. Chi sta sulle montagne muove eserciti,
  chi sta nelle miniere sa, chi siede a Eredan prende la parola.
- **La carta è la propria spesa**: le tre azioni che chiedono di scartare un
  Asset lo trovano nella carta stessa. Senza questa regola giocarne una ne
  costava due.
- **Il divieto stava nel posto sbagliato**: `check()` risponde a «sarebbe
  legale?», ed è la domanda che un seggio si fa *prima* di sapere con che carta
  lo dirà. Col divieto lì, **496 Occasioni su 720 restavano mute**. Ora vive in
  `execute()`.
- **Una guardia nuova**: `acquisition_rule` è prosa che nomina un fatto della
  mappa, e le due cose non erano legate da niente — il giorno della
  ridistribuzione **40 carte su 48 hanno cominciato a mentire** senza che nessun
  test se ne accorgesse. Adesso fanno rosso la CI.
- **0 su 8** misto e uniforme, nessuna azione rifiutata. `FAIL 235 · 99 · 122 ·
  121`, Consigli media 5,77, mediana 6. Suite **371 test / 6716 asserzioni**.
- **La divergenza di ISSUES 47 è chiusa a gioco acceso**: scarto fra la mano più
  piena e la più vuota all'Atto 3 **1,58**, contro 4,90 del gioco di prima.

### Dichiarato

- **Due difetti trovati misurando**: il *distratto* chiedeva un ACQUISIRE che non
  esiste più (93 rifiuti su 20 partite, i suoi NONE da 1 a 8); **Re Aldric si
  portava via da solo la presenza a Eredan** che il suo Minimo chiede, perché la
  voce nuova «allarga il rubinetto» spostava una pedina invece di posare la
  riserva (NONE da 1 a 8). Corretti entrambi.
- **CHR_03 gioca ancora il §10 di prima**, deliberatamente: la sua mappa non è
  stata guardata, e accendere lì le carte ripeterebbe il difetto che D-186 ha
  appena chiuso.
- **Le prove unitarie stanno sul lato classico e lo dichiarano** (`play_classic()`):
  usavano le azioni dirette per mettere il mondo in posizione, non per misurare
  l'economia. Che i dati spediti stiano dall'altra parte lo prova un test che
  rilegge il dato dal disco.
- **Manca un piano scriptato del gioco a carte**: i tre esistenti sono storie del
  §10 di prima. Il gioco nuovo è provato dal cancello e dai test, non da una
  storia raccontata.
- **Il 58% delle Occasioni resta muto**: 222 volte su 720 il cervello non voleva
  niente, **194 volte voleva qualcosa che la mano non sapeva dire**. È il costo
  vero della regola, ed è la prima misura che ne esista.
- Le quattro RIVENDICARE ereditano il difetto di **ISSUES 37**.
- **Maestra Ilve** perde Trionfi nel playtest (8 → 2 su 50 anni) per la modifica
  al cervello di D-187, non per l'economia. In campagna il Sale resta a **8 su
  12** (ISSUES 46), ma il divario merita una misura sua.

---

## 0.1.155 — Il velo copre la soglia, non il numero (D-187)

- Chiesta dal committente: «il mondo lo sa quale è il valore ma i giocatori nel
  gioco fisico no, e quindi nessuno sa quando le velate si attivano». Era
  un'**asimmetria che il tavolo fisico non può riprodurre**, non una taratura.
- **Il valore di una velata è pubblico**; è la **soglia** a stare coperta. Al
  tavolo vero è una carta girata a faccia in giù accanto al segnalino, e il
  registro scrive `Il Risveglio: 4/?`.
- **Sulla domanda si agisce lo stesso**: non sapere quando esploderà è il
  rischio, non un divieto. TRAMARE resta l'azione che gira la carta, e saperlo
  resta personale.
- Dichiarata sulla Chronicle (`veiled_tensions: HIDES_ALL | HIDES_THRESHOLD`),
  non scritta nel codice: la regola vecchia resta provata e si riaccende
  cambiando una stringa.
- **Un difetto trovato per strada**: il tavolo grande e la console **stampavano
  la soglia vera**, letta dal dato senza passare da nessun filtro. Con la regola
  vecchia non si notava; con la nuova avrebbe svuotato la regola il primo
  giorno. Ora una soglia coperta esce **−1**, come il dorso di una carta.
- **0 su 8** misto e uniforme. Suite **369 test / 6476 asserzioni**.

### Dichiarato

- **Non cambia quasi niente per i bot**: Consigli falliti 241 → **239**, medi
  5,44 → **5,43**, TRAMARE 130 → 134, INFLUENZARE 360 → 367. Le sonde non
  possono misurare la cosa per cui la regola è stata fatta — i bot non provano
  attesa. Il valore si vede in una serata con quattro persone.
- **Il velo di D-125 è più debole**: copriva un numero, ora copre solo il
  quando. Perdita reale per la casa che ha quell'arte, non ancora misurata.
- **La stima del bot è una scelta, non una misura**: chi non ha girato la carta
  usa la soglia media della Chronicle. Deterministica e onesta, ma non tarata
  contro le alternative.
- **Le altre due domande sulle Tensioni restano aperte**: la varietà nella prima
  partita, e il partire tutte da 0 (che obbliga a rifare le soglie).

---

## 0.1.154 — La mappa che distribuisce, e quante carte servono (D-186)

- **ISSUES 47 fase 3**, chiesta dal committente: «vai con la mappa, poi le carte
  per ogni atto devono essere pescate in numero sufficiente per fare le stesse
  azioni e per influenzare i concili come adesso».
- **Sei Regioni, due famiglie ciascuna, due Regioni per famiglia.** Prima
  `WEALTH` stava in quattro Regioni e `FORCE` in una sola; il divario fra la
  famiglia più a portata e la meno passa da **6,8 a 1** a **1,6 a 1**.
- **Dove stanno davvero le pedine**, misurato per la prima volta: Eredan 26,9%,
  Valle Verde 26,4%, Miniere 23,6%, Montagne 11,4%, Terre Nahr 11,1% — e la
  **Strada dei Mercanti allo 0,6%**. È una Regione morta (ISSUES 48).
- **Il fabbisogno**, che è la richiesta del committente diventata numero: per
  seggio e per anno, **3,20** azioni che costerebbero una carta + **8,59** carte
  impegnate ai Consigli = **11,80 l'anno, 3,93 per Atto**. Il rubinetto a
  `per_token: 1` ne dava 2: metà.
- **La taratura che regge il fabbisogno**: `per_token: 2, floor: 2, cap: 6,
  hand_cap: 7`. Misurata, la mano sta a 6–6,9 carte e **lo scarto fra la più
  piena e la più vuota all'Atto 3 è 1,18** — contro 4,90 del gioco di oggi. **Il
  punto 2 di ISSUES 47 è risolto.**
- Rubinetto spento, mappa nuova accesa: **0 su 8**, Consigli falliti **248 →
  241**. Suite **366 test / 6453 asserzioni**.

### Dichiarato

- **L'anno si è fatto più quieto**: Consigli medi da 5,79 a **5,44**, minimo
  della banda da 2 a **1**. Stessa causa: una mano più varia più spesso non ha
  la famiglia che quel Consiglio premia. È il prezzo, pagato apposta.
- **Due piani scriptati riregistrati.** «Il consiglio spezzato» da sei Consigli
  a tre — e la storia nuova è migliore: la domanda affondata torna al round dopo
  e a proporla è chi l'aveva affondata, col registro che scrive «la spirale si
  chiude». «La miniera aperta» perde i due Decisivi (margine 4 invece di 5).
- **Un errore preesistente trovato per strada**: la descrizione di «la miniera
  aperta» prometteva «tutte e quattro le bande di esito del §12.3» e un «passa
  pagando» che nei suoi stessi esiti registrati non c'erano. La prosa era ferma
  a una versione precedente. Ora combaciano.
- **61 asserzioni in meno** (6514 → 6453): sono i tre Consigli che «il consiglio
  spezzato» non gioca più. Nessun test tolto.
- La taratura del rubinetto è un **preventivo**: misurata col rubinetto *sopra*
  ACQUISIRE. Accesa oggi porterebbe i Consigli falliti a 304 — prezzo del doppio
  canale, non della taratura.
- **CHR_03 non è stata toccata**: tiene la sua mappa vecchia.

---

## 0.1.153 — Il rubinetto: la mano viene dalla mappa (D-185)

- **ISSUES 47 fase 2**, chiesta dal committente: «la presenza nelle regioni deve
  essere fondamentale nella pesca delle carte, tipo due presenze, due carte».
- A inizio di ogni Atto ogni seggio pesca guardando **dove tiene le pedine**:
  quante carte lo dicono i gettoni, **di che famiglia** lo dice la Regione
  (`asset_sources`). La mappa smette di essere un punteggio e diventa il rubinetto.
- **`hand_refill` sulla Chronicle** — `per_token`, `floor` (il pavimento per chi
  resta senza mappa), `cap` (tetto per Atto), `hand_cap` (tetto sulla mano).
  Omesso — il default — non succede niente.
- **Il freno che credevo giusto era quello sbagliato.** Scarto fra la mano più
  piena e la più vuota all'Atto 3: col solo tetto per Atto **5,48**, col tetto
  sulla mano **3,33**. Il tetto per Atto limita la pesca, non la mano: le carte
  non spese restano lì e lo scarto si accumula lo stesso.
- **E il gioco di oggi diverge di più**: 4,90 col rubinetto spento. ACQUISIRE, che
  nessuno frena, sbilancia più del rubinetto frenato.
- **Rubinetto spento nei dati**: playtest identico riga per riga a 0.1.150 —
  `FAIL 248 · 78 · 99 · 154`, **0 su 8 bloccati**. Suite **366 test / 6514
  asserzioni**.

### Dichiarato

- **Acceso da solo peggiora il gioco**: Consigli da 5,79 a 6,13 e i falliti da
  248 a **272**, il massimo mai misurato. Atteso — finché `actions_from_cards` è
  spento le carte del rubinetto si **sommano** ad ACQUISIRE invece di
  sostituirlo. Le due metà vanno accese **insieme**.
- Il vincolo regge lo stesso: **0 su 8** anche col rubinetto acceso.
- **Correggo un numero detto storto in sessione**: 9 Consigli in un anno non
  sfondano nessun «limite duro di §7». Non c'è tetto nel codice: 9 è il massimo
  strutturale (3 Atti × 3 round) e la banda 2–8 di MECCANICA è un estremo
  misurato, non una regola.
- `hand_cap: 5` è un punto di partenza, non una taratura: è stato misurato col
  rubinetto **sopra** ACQUISIRE. Quando ACQUISIRE sparirà va rimisurato.
- Il **pavimento** non è mai stato esercitato da una partita vera (nessun seggio
  resta senza pedine): è provato solo dai test.

---

## 0.1.152 — Il telaio delle azioni sulle carte (D-184)

- **ISSUES 47 fase 1**, sul via libera del committente: «ogni carta ha una azione
  di gioco, un valore per il consiglio, e effetti specifici della carta».
- **Due dei tre pezzi c'erano già**: il valore è `family`+`strength`, gli effetti
  sono `on_commit_effects` (47 carte su 48 ne hanno uno). Mancava l'azione.
- **`card_action` sull'Asset** — `{kind, params}` con `kind` fra le sei azioni di
  §10: il telaio non inventa verbi, sposta chi può pronunciarli.
- **`PLAY_CARD` nel resolver**: passa dal **medesimo `check()`** dell'azione
  corrispondente e poi **consuma la carta**. Nessuna regola scritta due volte, e
  un test lo prova chiedendo a una carta un MUOVERE illegale.
- **`actions_from_cards` sulla Chronicle**: spento (default) il gioco è quello di
  sempre; acceso, le sei azioni non si prendono più con un'Opportunità e la mano
  diventa l'unica moneta.
- **La spesa è il punto**: giocare una carta la scarta, quindi non voterà più. È
  lì che nasce il bilanciamento — *o la spendi per fare, o la tieni per votare*.
- **Zero carte convertite, playtest identico riga per riga** a 0.1.150. Suite
  **359 test / 6503 asserzioni**.

### Dichiarato

- Il gioco nuovo non esiste finché non si scrivono le **48 `card_action`**: la
  fase 1 serve a poterle scrivere una famiglia alla volta, misurando.
- **Il rubinetto della mano non è collegato**: le due metà (azioni dalle carte, e
  carte dalla presenza) vanno accese **insieme**, o un seggio resterebbe senza
  carte e senza poter agire.
- `TRAMARE` e `INFLUENZARE` spariranno quando esisteranno le carte che li portano.

## 0.1.151 — Il preventivo della mano che viene dalla mappa (D-183)

- **`run_hand_probe.gd`**, sonda nuova: il committente ha proposto che tutte le
  azioni si facciano con le carte e che le carte le dia la presenza sulla mappa.
  Prima di riscrivere 48 carte, il **preventivo** — la sonda gioca le partite
  come sono e scrive quante carte quel rubinetto darebbe.
- **Il numero che dà ragione alla proposta**: su 72 azioni disponibili in un
  anno, i seggi giocano **47 ACQUISIRE** e **1 solo MUOVERE**. Due terzi del
  gioco sono già «pesca una carta».
- **Il gioco si stringerebbe al 36–40%** di adesso (6,6–7,2 carte contro 18
  azioni), e **lo scarto fra il primo e l'ultimo seggio raddoppia ogni atto**
  (0,00 → 1,25 → 1,92): la divergenza non viene dal setup, la produce il gioco.
- **Nessun seggio resta senza pedine** in 480 campioni: la spirale della morte
  non si materializza.
- **La mappa non distribuisce le famiglie**: `WEALTH` sta in quattro Regioni su
  sei, `FORCE` in una sola. Un seggio raggiunge 3,3 famiglie su 6.
- Aperta come **ISSUES 47**. Nessuna regola cambiata: dati, playtest e suite
  restano quelli di 0.1.150.
- La sonda dei gradini risponde anche a **«essere il proponente conviene?»**: sì,
  e il gradino medio cresce col numero di proposte (1,33 con zero, 1,93 con tre).

## 0.1.150 — Il Sale non vinceva: gli succedeva di vincere (D-182)

- **ISSUES 46, sulla direzione data dal committente**: «il Sale è troppo forte».
  Guardato dal lato suo, il difetto aveva **tre teste**, tutte misurate col banco
  delle clausole: il Minimo vero al **100%**, la seconda clausola della Vittoria
  («e nessuno lo ha cancellato») vera al **100%**, e la **spina del Trionfo** («il
  patto con la Cenere regge») vera al **100%**.
- **`DST_SALE` superava il Minimo 12 volte su 13.** E non perché la Gilda giocasse
  meglio: la sua Vittoria la decideva il **calendario** — `debt_called` matura da
  sé quando la Tensione arriva a soglia, e le altre due clausole non falliscono
  mai. Al Sale non riusciva di vincere: **gli succedeva**.
- **Quattro passi misurati uno alla volta**, e il primo insegna qualcosa: chiedere
  il debito chiamato **e** un alleato rimasto tale sono due cose **anti-correlate**
  (riscuotere allontana chi paga), e il Destino è crollato dal 92% al **15%** —
  l'errore di D-177 arrivato dal lato opposto. A NEUTRALE la richiesta diventa
  «riscuotere senza rompere», che è quello che una Gilda sa fare.
- **La promessa è stata spostata, non cancellata**: `promise_kept` compare una
  volta sola in tutto il gioco, e toglierla l'avrebbe resa contenuto che non
  esiste. Ora è una delle cinque strade del Trionfo.
- **E il secondo Destino era diventato il colpevole**: `DST_SALE_OPEN` faceva **6
  Trionfi su 13**, il massimo del gioco. La sua scelta passa da una strada su
  quattro a due: da 0/6/**1**/6 a **0/6/6/1**.

| | prima | dopo |
|---|---|---|
| `DST_SALE` (N/M/V/T su 13) | 0 / **1** / 8 / 4 — supera il **92%** | **0 / 7 / 4 / 2** — supera il 46% |
| campagne vinte dal Sale | **12 su 12** | **9 su 12** |
| il Sale supera il Minimo, nelle saghe | 68% | **54%** (le altre 33–34%) |
| ultimo cambio di testa | anno **3,5** su 10 | anno **5,5** su 10 |
| campagne decise entro il terzo anno | 6 su 12 | **4 su 12** |

- Playtest **FAIL 248 · 78 · 99 · 154**, mediana 6, **0 su 8**. I **Consigli
  falliti scendono da 256 a 248**, ed è la prima volta che quel numero torna
  indietro. Suite **355 test / 6490 asserzioni**.

### Dichiarato

- **La voce è ridotta, non chiusa**: il criterio che si era data — nessuna casa
  sopra la metà delle campagne — non è raggiunto (**9 su 12 è il 75%**). Mi fermo
  perché continuare senza una diagnosi nuova sarebbe tarare a occhio.
- Restano da guardare i **Trionfi nelle saghe** (Sale 25, Libere 19, Vetro 11,
  Cenere 8) e il fatto che il **Minimo delle quattro case non costa uguale**.
- Kessa prende 1 NONE a tavolo misto dove prima ne aveva 0: dentro il vincolo.

## 0.1.149 — Una campagna è almeno dieci anni (D-181)

- **Deciso dal committente**: «direi la saga almeno 10 partite». Sta in
  `saga_scoring.decides_after`, con **10** nelle due saghe in gioco. Prima della
  soglia il conto si tiene ma nessuno ha vinto, e il verbale lo dice ogni anno
  (*«La campagna non è ancora decisa: 3 anni giocati su 10»*); dalla decima in poi
  dichiara il vincitore, o la parità se c'è.
- **«Almeno» vuol dire che la soglia apre la porta e non la chiude**: al decimo
  anno la campagna può finire, e se il tavolo continua il conto prosegue.
- **Un numero nuovo nel mondo**: `chronicles_played`, quante Chronicle ha giocato
  questa saga. Non si poteva ricavare da `year`, perché fra due Chronicle passano
  da 1 a 200 anni — cento anni di mondo possono essere due partite o dieci.
- **E la soglia rende concreta la domanda che D-180 aveva dichiarato senza
  risposta**: il conto rende ininfluenti gli ultimi anni? La misura è l'anno
  dell'**ultimo cambio di testa**:

| su 12 saghe da 10 Chronicle | la Carestia | il Sale |
|---|---|---|
| cambi di testa per saga | **1,8** | 1,3 |
| ultimo cambio di testa | anno **5,0** su 10 | anno **3,5** su 10 |
| campagne decise entro il terzo anno | **3 su 12** | **6 su 12** |

- **Nella Carestia la campagna regge** — cambia padrone quasi due volte e
  l'ultimo sorpasso arriva a metà strada. **Nel Sale no**: metà delle campagne è
  decisa entro il terzo anno su dieci. La causa non è la soglia né la scala, è
  **ISSUES 46**: una casa che supera il Minimo il 68% delle volte prende la testa
  presto e non la molla. Lo stesso squilibrio visto da un terzo lato — prima come
  gradini, poi come vincitore, adesso come **noia**.
- Il playtest è **identico riga per riga** a quello di 0.1.147 per la terza
  versione di fila. Suite **355 test / 6490 asserzioni**.

### Dichiarato

- **Dieci è il numero del committente, non un numero misurato**: la misura dice
  che a dieci la Carestia regge e il Sale no, non che dieci sia il valore giusto.
- Il pareggio al decimo anno non ha uno spareggio: il verbale dice «si va avanti».

## 0.1.148 — Il vincitore della saga (D-180)

- **Voluta dal committente**: «per vincere la saga ci vuole un contatore di
  vittorie nelle singole partite». Ogni Chronicle chiusa somma al seggio il
  valore del livello raggiunto, il totale attraversa le ere insieme alla mappa, e
  alla fine della campagna vince chi ha di più.
- **Non contraddice il principio del gioco** perché sta a livello di **saga**:
  dentro l'anno non cambia niente — nessuna classifica, più case possono vincere,
  tutte possono fallire — ed è la campagna ad avere un vincitore.
- **Cinque scale misurate prima di sceglierne una.** Il rischio temuto era che
  pagare il Minimo facesse vincere la campagna a chi non ha mai rischiato: **la
  misura lo ha smentito**, con nessuna scala e in nessuna saga vince chi ha più
  Minimi. Scelta la **−1 / 1 / 3 / 6**: meno pareggi (3 su 24 saghe) e l'accordo
  più alto con i Trionfi (18 su 24). Il NONE che toglie un punto è la conseguenza
  di [D-067](docs/DECISIONS.md#d-067) — perdere è possibile, e in una campagna
  deve costare.
- **Sta nella Chronicle** (`saga_scoring`), quindi si cambia senza toccare il
  codice, e **omessa spegne tutto**: una Chronicle può restare un anno che sta in
  piedi da solo, come in v0.2.
- **Il punteggio segue il seggio, non la persona**: in una saga lunga il Popolo
  Nahr diventa Il Regno di Nahr e il conto prosegue. È un contatore, non un
  Effetto, fra le eccezioni dichiarate all'effect-sourcing.
- **Il playtest è identico riga per riga** a quello di 0.1.147: nessuna policy
  legge il punteggio, è puro verbale. Suite **353 test / 6480 asserzioni**.

### E quello che il contatore ha rivelato

- **Nella saga del Sale la campagna la vince sempre la stessa casa** — SALE 12 su
  12, con qualunque scala — mentre in quella della Carestia i vincitori sono tre
  su quattro. Non è un difetto del punteggio: è lo squilibrio di contenuto già
  noto (Sale al 68% sopra il Minimo contro 24–33% delle altre) che finora si
  **spalmava** anno per anno e che un totale cumulativo rende **definitivo**.
- **Un contatore di campagna non è una regola neutra: è un amplificatore** di
  tutto quello che il bilanciamento non ha ancora chiuso. Aperta come
  **ISSUES 46**.

## 0.1.147 — La meccanica al vero, e come si gioca bene (D-179)

- **`docs/MECCANICA.md` era fermo a 0.1.140**, e il suo principio dichiarato è che
  ogni numero dentro sia quello vero letto dai dati. Passati uno per uno: la
  maggior parte reggeva (132 carte su 48 tipi, 39 carte Narratore, 52 Conseguenze
  di cui 14 cambiano padrone, 10 modelli di Consiglio, 20 Destini, 9 tipi di
  struttura), **cinque no**.
- **Le regole dei segni sono 52, non 45** — e il documento **contraddiceva sé
  stesso**, perché §3 e §14 dicevano già 52 mentre §9 diceva 45. Rifatta anche la
  ripartizione per tipo (COUNCIL_MODIFIER 16→**17**, DRAW_BIAS 10→**14**,
  HAND_LIMIT 1→**3**).
- **Le famiglie di struttura sono 4, non 5**: il passo è un `LUOGO`, e la famiglia
  `CHIUSURA` non esiste nei dati.
- **I Destini in gioco all'apertura sono 19 dei 20**, non 9: il pool è acceso da
  0.1.141. Il ventesimo appartiene a un seggio che siede solo in saga.
- **Come finisce un anno** è ora misurato sulle partite di oggi — 0% / 44% / 36% /
  **20%** a tavolo misto — con accanto la colonna dei quattro ottimizzatori
  (1% / 28% / 41% / 30%): la stessa policy, e venti punti di Trionfo di
  differenza fra chi non spreca un turno e chi ogni tanto lo spreca.
- **Tre cose che mancavano del tutto**: che il Destino **si pesca da un pool di
  tre** (col suo costo dichiarato, i Consigli falliti da 206 a 246); che **sette
  Conseguenze costruiscono** qualcosa che resta sulla mappa e pesa nel controllo;
  e come si gioca bene.
- **Sezione nuova §15 «Come si gioca bene, misurato»**: i quattro caratteri sugli
  stessi 100 semi — **la prudenza è la strategia peggiore del gioco** (40% contro
  62–63%), e l'**ostinato**, che punta al gradino alto dal primo round, ha più
  Trionfi *e* meno Minimi di tutti. Più nove regole pratiche col numero accanto,
  fra cui le **111 rivendicazioni morte su 128** e l'errore di spegnersi il
  Destino da soli.

### Dichiarato

- La sezione si chiude con **quello che non sa**: i numeri vengono da bot contro
  bot, che non tradiscono e non mentono. Sono muti sulla metà negoziata del gioco.
- Nessun dato di gioco toccato: playtest, suite e sonde restano quelli di 0.1.146.

## 0.1.146 — Due guardie, e la seconda ha morso subito (D-178)

- **Il difetto di D-177 si vedeva senza giocare una partita.** Trovarlo era
  costato una sessione di sonde; la causa era un conto di somme sui dati. I
  livelli sono cumulativi, quindi le presenze che un Destino chiede si sommano
  dal Minimo in su e vanno confrontate col tetto dei gettoni della Chronicle.
- **`check_destiny_token_budget`** fa quel conto su tutti e venti i Destini e
  distingue due esiti: gli **obblighi** che superano il tetto (livello
  irraggiungibile) e la **strada** dentro un `some_of` che li porta oltre —
  percorribile, ma solo spegnendo una clausola di un livello sotto. È il difetto
  della Cenere, e sui dati di 0.1.144 la guardia lo ritrova in un istante; sui
  dati di oggi, zero. **Era l'unico caso in tutto il gioco.**
- **`check_destiny_free_roads`** è l'altra faccia della stessa moneta: se un
  livello sotto può *falsificare* una clausola di sopra, può anche *regalarla*.
  Ha trovato una riga sola, e non era vecchia — era di ieri: rendendo la
  reliquia obbligatoria nella Vittoria di `DST_CENERE_DEEP`, D-177 aveva acceso
  da solo il primo dei sei rami del suo Trionfo, che di fatto chiedeva **due
  segni su cinque** invece di tre su sei.
- **Ed è la spiegazione della bimodalità che D-177 aveva dichiarato senza
  saperla spiegare.** Tolto il ramo ridondante, `DST_CENERE_DEEP` passa da
  0/8/**1**/7 a **0/8/5/3**: lo stesso 50% sopra il Minimo, distribuito come una
  scala invece che come un salto. Kessa a tavolo misto da 0/29/9/12 a
  **0/29/13/8**; playtest **FAIL 256 · 78 · 100 · 145**, mediana 6, **0 su 8**.
- **Le due guardie girano nella CI**, e prima dei dati veri gira
  `validate_data.py --self-test`, che le mette su tre Destini sintetici e
  pretende che tacciano su quello sano e parlino sugli altri: una guardia che
  nessuno ha mai visto mordere non è una guardia (D-144).

### Dichiarato

- Le guardie vedono i gettoni e le strade regalate, **non** ogni modo in cui un
  Destino può combattersi da solo (un tag chiesto da un livello e vietato da un
  altro non lo prende nessuno).
- Le asserzioni della suite scendono da 6445 a **6444**: `test_data_boot` ne fa
  una per ogni `state_tag_present` di ogni Destino, e c'è una condizione in meno.
  I test restano **349** e la copertura del tag resta.

## 0.1.145 — Il Destino che si combatteva da solo (D-177)

- **La linea della Cenere/Fuochi aveva una causa, e non era la debolezza.** Su
  120 anni della saga del Sale **tutti e tredici i NONE erano della Cenere** (le
  altre tre case: zero), e tutti per la stessa clausola del suo Minimo. Negli
  anni persi la casa teneva **1,00** gettoni sulle Montagne Rosse e **1,92** nelle
  Miniere; negli altri anni 1,67 e 1,04. Stesso numero di gettoni, posto diverso:
  la Cenere **scendeva sotto per la propria Vittoria** e cosi' spegneva il proprio
  Minimo. I livelli sono cumulativi, quindi inseguire quel gradino costava quello
  che lo regge.
- **`DST_CENERE_DEEP` aveva ereditato il Minimo del Destino sbagliato** — quello
  di `DST_CENERE`, dove presidiare la montagna in due ha senso. Adesso il suo
  Minimo e' «**Non hanno lasciato la montagna**»: la casa esiste ancora e **un**
  gettone e' rimasto su. Un gettone resta, due scendono.
- **E la Vittoria ha perso i suoi due regali**: chiedeva una presenza nelle
  gallerie e che non fossero murate, tutt'e due vere al 100%. Adesso chiede la
  discesa in due **e** la reliquia — la pedina la muove il seggio, la reliquia
  gliela deve dare il tavolo.
- **Kessa dei Fuochi** passa da 0/32/10/8 a **0/29/9/12** a tavolo misto e da
  1/33/13/3 a **1/21/17/11** a tavolo uniforme; nelle saghe la Cenere va da **13
  NONE** a **0** e dal 26% al **33%** sopra il Minimo, coi Trionfi da 6 a 15. I
  volti dei Fuochi da 8%–33% a **22%–50%**.
- **La sonda delle ere** dice adesso *quale clausola* manca quando un anno chiude
  a NONE, e dove la Cenere tiene i gettoni: era la misura che mancava, perche' il
  NONE di quella casa si vedeva solo nelle saghe e la sonda dei gradini guarda una
  Chronicle sola.

### Dichiarato

- **Consigli falliti da 248 a 256**: una casa che arriva viva a fine anno propone
  e si oppone piu' a lungo.
- **Il perdere ha cambiato posto invece di sparire**: i 13 NONE della Cenere
  diventano 0 e ne compaiono **2 del Vetro**, che adesso contende alla Cenere gli
  slot delle stesse gallerie. Il conto totale del perdere in questa saga scende
  pero' da 13 a 2.
- La forma scelta e' **bimodale** (8 Minimi, 1 Vittoria, 7 Trionfi) e due ipotesi
  scritte sono state **demolite dalla misura** prima di arrivare alla causa vera:
  la clausola creduta impossibile e' vera il 35% delle volte, e le Montagne Rosse
  non erano affollate ma vuote. Tutto in [D-177](docs/DECISIONS.md#d-177).

## 0.1.144 — Le istituzioni non governano diversamente (D-176)

- **ISSUES 35 chiusa, e l'ipotesi era falsa.** Misurata come la voce chiedeva —
  dodici saghe a tavolo misto, livelli per incarnazione — le **otto istituzioni**
  superano il Minimo il **41%** delle volte e le **quindici persone** il **42%**.
  Un punto: chi siede non c'entra niente.
- **Quello che c'entra è la casa.** Un'istituzione al 68% (La Compagnia del Sale)
  e una al 14% (Le Custodi della Cenere) sono lontane fra loro quanto le due
  persone agli estremi, e la linea che va male va male con chiunque la porti: i
  cinque volti dei Fuochi stanno fra l'8% e il 46%, i cinque Maestri fra il 46%
  e il 67%.
- La forma si vedeva lo stesso perché nella saga del Sale le istituzioni siedono
  **dopo**, e dopo il mondo è più segnato: la correlazione c'era, la causa era il
  momento e non il soggetto.
- La **sonda delle ere** stampa il conto dei livelli per incarnazione: era la
  misura che la voce chiedeva e non c'era.

## 0.1.143 — Tre Conseguenze che costruiscono (D-175)

- **`CNS_NAHR_SETTLEMENT`, `CNS_MARCH_GRANTED` e `CNS_MARKET_MOVED`** non
  scrivono più solo un segno: costruiscono un **villaggio**, una **torre di
  veglia** e un **villaggio**. I segni restano — le regole li leggono — ma sotto
  adesso c'è qualcosa che pesa nel conto del controllo e sopravvive all'anno.
  La più interessante è la marca: una concessione senza niente sopra poteva
  tornare indietro il round dopo, la torre è quello che la tiene.
- `CNS_RELIC_BURIED` resta un segno: la cella murata non è nessuna delle nove
  cose del catalogo, e inventarne una decima per una Conseguenza sola sarebbe la
  tentazione che D-164 aveva già pagato.
- Pietre **alzate giocando: 174** su 80 partite. Gradini e playtest invariati.
- **Mezza ISSUES 37 chiusa**: la mappa si muove — 82% di caselle con un padrone
  contro il 56%, seggi a zero Regioni dal 30% all'11% — e non per una correzione
  mirata ma perché il padrone si conta invece di scriverlo. Resta l'altra metà,
  con un nome preciso: **`ACT_CLAIM` muore in mano 110 volte su 128**, e il punto
  di rottura è §10 del regolamento, non il codice.

## 0.1.142 — Tre voci chiuse (D-174)

- **ISSUES 41 chiusa.** Il sito antico non era mai «aperto e ancora intero», e la
  colpevole era il **sigillo**: `CNS_MINE_SEALED` riportava il sito a grado 1,
  cioè cancellava il fatto che fosse mai stato aperto e svuotato. Un sigillo
  nasconde, non restituisce. Ora lo lascia al grado di mezzo: «aperto e ancora
  intero» passa da **0% a 20%** degli anni.
- **ISSUES 42 chiusa**, e nessuna delle tre cause che la voce elencava regge:
  i Destini di CHR_03 sono **più duri** (41% di clausole mancate contro 38%), le
  sue Tensioni si muovono **meno** (5,33 Consigli contro 5,83), e le due saghe
  hanno una casa senza terra a testa. Il divario era **degli otto Destini che si
  giocavano**: aperto il pool, CHR_01 va al 19% e CHR_03 al 23%.
- **ISSUES 40 decisa**: il grado alto resta **materia di saga**. Una clausola sul
  grado 2 o 3 si scrive solo nei Destini di una Chronicle successiva.
- La sonda dei gradini stampa i **Consigli chiusi per saga** — la misura che
  ISSUES 42 chiedeva e non c'era.

## 0.1.141 — Il pool si accende: venti Destini invece di otto (D-173)

- **ISSUES 43 chiusa.** Le tre che restavano sono riscritte: i due Destini
  condivisibili chiedevano al **Minimo** una cosa che si ottiene giocando — la
  fama, il registro pulito — e lasciavano fuori dal gioco al primo colpo un
  seggio su tre; `DST_ALDRIC_RECORD` chiedeva alla Vittoria due Regioni, mancate
  all'88%.
- **Il pool e' acceso**: `_deal_destiny` pesca dalla lista dell'Entita' quando la
  Chronicle non ne dichiara una. **Venti Destini su venti** si giocano
  all'apertura, contro otto.
- **Zero seggi a NONE** (erano 4 su 800), nessuno a zero Trionfi, tavolo misto e
  uniforme **0 su 8**, mediana dei Consigli **6**.
- **Costo dichiarato: Consigli falliti da 206 a 246.** E' il numero piu' alto mai
  misurato, e la causa non e' oscura — undici ambizioni in piu' al tavolo si
  oppongono fra loro molto piu' spesso. Si spegne in una riga.
- *Un Minimo non e' un obiettivo, e' una soglia di sopravvivenza* — e le carte
  scritte per otto case diverse sono il posto dove sbagliarlo costa di piu'.

## 0.1.140 — Il bot smette di sbirciare (D-172)

- **`world["voted_together"]`**: per ogni coppia, quante volte sono finiti sullo
  stesso fronte del Consiglio meno quante volte su fronti opposti. E' la memoria
  dei bot, non un fatto del mondo — quello che chiunque sieda al tavolo vede con
  i propri occhi.
- **L'alleanza si decide su quello**, non piu' leggendo il Destino altrui: un
  giocatore vero quella carta non la vede. Prima del primo Consiglio nessuno sa
  niente di nessuno, e la regola tace.
- **Il prezzo scende da dodici Trionfi a tre** (86 → **83**, contro i 74 di
  D-171), e le alleanze si distribuiscono: la banda passa da 5-50% a **15-35%**,
  e Aldric e Vaerax — che l'opposizione dichiarata escludeva per regola —
  entrano al 20% e al 35%. Due che si oppongono su un segno possono benissimo
  essersi trovati dalla stessa parte su tre domande diverse.
- E adesso **si puo' sbagliare un alleato**, che e' la sola cosa su cui si possa
  costruire un tradimento.

## 0.1.139 — L'alleanza che conviene (D-171)

- **Un seggio adesso stringe un legame perche' gli conviene**, non solo perche'
  una clausola glielo chiede: si allea con **chi aspetta lo stesso Consiglio**,
  perche' quando la domanda si apre quel voto pesa sul suo fronte (D-139). Chi
  gli si oppone su un segno resta fuori comunque.
- **Correzione**: «nessun bot stringe alleanze» era troppo forte. `ACT_FORGE`
  c'era e la policy la giocava — ma solo quando una clausola del proprio Destino
  nominava quella relazione.
- **La prima forma — «ti allei con chi vuole i tuoi stessi segni» — non ha
  sparato una volta**, e ha trovato una cosa sul contenuto: fra gli otto Destini
  **non esiste una coppia che voglia lo stesso segno nello stesso verso**. Ogni
  sovrapposizione e' un'opposizione. C'e' un test che tiene fermo quel fatto.
- **Il ceto sociale si accende**: Lyra e Nahr passano da **0% a 45%** di anni
  con almeno un alleato.
- **Il prezzo, dichiarato: Trionfi del tavolo da 86 a 74.** Un'alleanza costa
  un'Occasione, e l'Occasione e' tutta la moneta dell'anno. Le due leve ovvie
  per abbassarlo — soglia piu' alta, regola piu' in basso — **non sparano mai**:
  il quadrante e' binario.

## 0.1.138 — Gli undici Destini mai giocati (D-170)

- **ISSUES 43 misurata**: acceso il pool, supera il Minimo scende da **62% a
  50%** e un seggio su dodici finisce a **NONE** (oggi: mai). Il meccanismo e'
  giusto, il contenuto no — gli undici non erano mai stati guardati da nessuna
  sonda. **Il pool resta spento.**
- **Sei Destini riscritti** nella forma spina + scelta, con le strade misurate
  prima: `DST_CENERE_DEEP` (16 su 16 fermo al Minimo, tre clausole al 100%),
  `DST_NAHR_ROOTED` e `DST_SALE_OPEN` (zero Trionfi, lo stesso tag mai
  guadagnato), `DST_SHARED_RENOWN` (il Minimo chiedeva la fama), 
  `DST_SHARED_ACCOUNTS` (Trionfo piu' facile della Vittoria), `DST_LIBERE_WATER`
  (Trionfo al 75%). Col pool acceso si passa a 53% / 7%: meglio, non abbastanza.
- **Il perimetro della sonda delle clausole**, trovato usandola: misura cosa e'
  vero **nel mondo che c'e'**, coi seggi che giocano il proprio Destino. Un
  Destino nuovo fa un mondo diverso — «una Regione controllata» dava 80-100% sul
  banco e 13 NONE su 41 ai seggi che la giuravano davvero.
- Col pool spento **tutto invariato**: playtest FAIL 203, mediana 6, misto 0 su
  8, gradini 62% e 0 NONE. Le riscritture costano zero perche' nessuno le pesca,
  ed e' esattamente il punto della issue.

## 0.1.137 — Lyra apre (D-169)

- **La Vittoria di Lyra non e' piu' una porta sola**: spina (presenza nelle
  Miniere) piu' **due segni su tre** — la scorta giurata, le Miniere non
  sigillate, un posto sulla mappa. Il Trionfo chiede **quattro Scoperte**
  invece di due: due erano vere nel 100% degli anni misurati.
- **La scelta di Nahr scende da quattro segni a tre**, perche' aprire Lyra le
  costava sette Trionfi senza che nessuno toccasse il suo Destino.
- **La banda dei Consigli sale a 5-7** nell'anno scritto e nell'anno pescato,
  coi limiti duri fermi a 2-8. Un seggio che ricomincia a giocare fa l'anno piu'
  rumoroso: e' la seconda volta, dopo D-051.
- **Una forma scartata benche' misurasse meglio**: la scelta 2 su 5 dava a Lyra
  27/16/7 e al tavolo 91 Trionfi, e due delle cinque strade erano vere prima che
  qualcuno giocasse. *Quando una forma misura meglio di tutte le altre, si
  controlla che non stia misurando bene per il motivo sbagliato.*
- Trionfi del tavolo **79 → 86**, tavolo misto 0 su 8, mediana 6. Costo
  dichiarato: **FAIL 191 → 203**. ISSUES 44 chiusa.

## 0.1.136 — Il giro su Lyra, misurato e non committato

- **[D-168](docs/DECISIONS.md#d-168)**: la scala di Lyra non e' debole, e'
  **bimodale** — Minimo, spina della Vittoria e spina del Trionfo tutte al 100%,
  e tutto appeso a un tag solo al **25%**. Tre modi di aprirla, tutti e tre con
  lo stesso prezzo: la mediana dei Consigli passa da 6 a **7**, e gli anni
  tranquilli spariscono dalla distribuzione. **Nessuna modifica ai Destini**: e'
  una scelta fra un seggio che gioca e la banda dei Consigli, ed e' ISSUES 44.
- **Il banco della sonda** (`tools/clause_candidates.json`) porta le diciassette
  clausole di Lyra misurate: e' la prova del verbale.
- Due numeri trovati per strada: le **clausole sociali sono ancora esattamente
  zero** (alleanza con Aldric 0%, non-inimicizia con Vaerax 0%) — la seconda
  domanda di D-151 finalmente con un numero accanto — e Lyra **non si sposta mai**
  sulla Strada dei Mercanti (0%).

## [0.1.134] — La spina e la scelta

Il Trionfo smette di essere una lista da soddisfare per intero
([D-167](docs/DECISIONS.md#d-167)). Richiesta del committente: «i destini li
farei diversi, una serie di condizioni che se soddisfatte danno il grado di
vittoria, includendo anche gli edifici e/o il controllo e/o le cicatrici».

### Added

- **`cli/run_clause_probe.gd`** — quanto costa una clausola **prima** di
  scriverla in un Destino. Legge `tools/clause_candidates.json` e riporta, per
  ogni casa, la quota di anni in cui sarebbe vera a fine anno. E' lo strumento
  che mancava a [D-161](docs/DECISIONS.md#d-161), che aveva scritto cinque
  clausole a occhio: tre muri, due regali, zero utili.
- **La spina e la scelta.** Otto Trionfi riscritti, uno per casa: una o due
  clausole in AND — quello che quella casa voleva davvero — piu' una `some_of`
  su quattro, cinque o sei strade. Fra le strade, per la prima volta, **le
  pietre e le cicatrici**: «la corona ha piu' di una casa di pietra», «il passo
  e' franato», «le Miniere sono uscite pulite», «e le citta' hanno costruito,
  non solo discusso».
- **`describe_all`** apre una scelta strada per strada nelle evidence di fine
  anno. «Tre di queste cinque» non si legge se non si vede quali erano.
- **La sonda dei gradini conta le pietre**: quante ne tiene ogni casa a fine
  anno, per famiglia e per grado, quante se ne alzano giocando, dove cadono le
  cicatrici, e **dove arriva ogni Destino** invece del solo totale.
- **`validate_data.py` controlla lo `structure_type`** di una clausola. Un tipo
  sbagliato non era un errore: contava zero, cioe' diventava un muro che nessuno
  aveva deciso di alzare.
- **`open_roads`**: i conti rimasti aperti ([D-087](docs/DECISIONS.md#d-087))
  portano **quali strade sono cadute**, non «tre di queste cinque». Sono la
  meta' strutturata delle evidence, quella che l'era dopo eredita: una scelta
  opaca l'avrebbe resa cieca proprio dove ne ho spostate meta'.

### Fixed

- **Quattro seggi su otto avevano zero Trionfi su cinquanta partite.** Due per
  una clausola mancata il **100%** delle volte: Vaerax chiedeva un tag che
  niente scrive mai, la Gilda chiedeva due Regioni a una casa che ne tiene 0,90.
  Una lista in AND con dentro un muro e' un gradino tolto dal gioco, e nessuno
  se ne accorgeva perche' il seggio riportava comunque VITTORIA.
- **Le clausole annidate erano invisibili a quattro controlli su quattro.**
  `PolicyDecider` — dove il difetto sarebbe costato di piu': un seggio legge il
  proprio Destino per sapere cosa vuole, e una clausola dentro una scelta ha per
  tipo `some_of`. Spostandone meta' dentro le scelte, meta' delle ambizioni del
  tavolo sarebbero sparite in silenzio (e' [D-066](docs/DECISIONS.md#d-066), che
  aveva trovato l'80% dei seggi a valutare una proposta zero). L'hanno visto due
  test, non io. Appiattite anche in `validate_data.py`, nel controllo sui tag
  irraggiungibili e in quello che verifica che una Chronicle nomini le proprie
  Tensioni.

### Measured

| | prima | dopo |
|---|---|---|
| Trionfi, tavolo misto su 400 seggi-partita | **21** | **79** |
| seggi con zero Trionfi | **4 su 8** | **0 su 8** |
| Esiti | FAIL 207 · 77 · 112 · 189 | **FAIL 191** · 69 · 116 · 196 |
| sonda dei gradini: TRIONFO | 6% | **20%** |
| supera il Minimo | 54% | **63%** |
| clausole mancate il 100% delle volte | 2 | **0** |

Trionfi per Destino, su 30 partite ciascuno: 3 · 4 · 7 · 6 · 8 · 7 · 6 · 7 —
nessuno murato, nessuno regalato. Ci sono voluti quattro giri di misura: la
prima scrittura mandava Kessa al 75%, la seconda schiacciava le Citta' Libere a
1 su 30.

Tavolo misto **0 su 8**, Consigli mediana 6. Suite **342 test / 6472
asserzioni** verde; sims ed export identici su due giri; `dead_code.py` pulito
su 154 file.

---

## [0.1.133] — Il passo che frana

L'ultimo pezzo del catalogo ([D-166](docs/DECISIONS.md#d-166)), tenuto per ultimo
di proposito: **la sola cosa che cambia la forma del mondo**.

### Added

- **`CLOSE_PASSAGE` / `OPEN_PASSAGE`**, l'uno l'inverso dell'altro: tolgono un
  arco da tutte e due le parti. Le **adiacenze diventano stato del mondo** —
  erano l'unica cosa della mappa che non cambiava mai.
- **`STR_PASS`**: Passo aperto → Passo franato. *La Via delle Miniere Tagliata*
  lo fa cadere: due Effect per un fatto solo, il luogo che cambia stato e l'arco
  che si chiude.
- **La guardia**: una Regione irraggiungibile e' **un Destino impossibile**. Il
  taglio si prova, si visita il grafo, e **se il mondo si e' spezzato si rimette
  a posto**. Il test lo prova col solo caso che romperebbe davvero — due tagli
  sulle Miniere, e il secondo viene rifiutato.

### Fixed

- **Riaprire un varco rimetteva il vicino in fondo alla lista.** Il round-trip
  l'ha visto: lo stato non tornava byte per byte. E non e' stile — **l'ordine
  dei vicini lo legge il gioco** (`$adjacent` ci pesca dentro). Adesso si
  ricostruisce nell'ordine d'autore.

### Measured

Su quaranta Chronicle: **1 varco chiuso**, 1 passo franato, **0 tagli
rifiutati**. Una volta ogni quarant'anni meta' della montagna scende a valle in
una notte — la frequenza giusta per un fatto che riscrive la mappa. Non forzata.

Playtest **FAIL 207 · SUCC 77 · SUCC 112 · DECI 189** — identico a 0.1.132:
l'ultimo pezzo costa **zero**. Tavolo misto **0 su 8**, mediana **6**.

Suite **339 test / 6051 asserzioni** verde, sims ed export deterministici.

**Il catalogo e' chiuso**: nove tipi in cinque famiglie. Resta fuori solo la
palude, che chiede motore e non contenuto.

---

## [0.1.132] — Il sito antico e la sorgente

Gli altri due luoghi del mondo ([D-165](docs/DECISIONS.md#d-165)), scritti sotto
un vincolo nuovo: **il degrado toglie un dono, non aggiunge una penalita'**.

### Added

- **`STR_OLD_SITE`**: dormiente → **aperto (sapere migliore)** → saccheggiato.
- **`STR_SPRING`**: **viva (gente migliore)** → bassa → secca.
- Le cause **cercate fra quelle che c'erano**: *Le Gallerie Riaperte*, *La
  Miniera Aperta*, *Le Miniere Sigillate*, *La Valle che si Vuota*, *L'Acqua a
  Prezzo*. Nessuna carta nuova, nessun rimescolo.

### Measured

**Playtest FAIL 207 · SUCC 77 · SUCC 112 · DECI 189 — identico** alla misura
prima di aggiungerle. Due famiglie nuove e **zero punti** di costo: e' il
vincolo di progetto che ha funzionato. Tavolo misto **0 su 8**, mediana **6**.

Su venti Chronicle: 38 siti dormienti, **2 saccheggiati**, **0 aperti**; 39
sorgenti vive, **1 bassa**, **0 secche**.

**Da dichiarare:** `place:open_site` **non si raggiunge mai**, e con lui dorme la
regola del sapere. La causa c'e' ed e' una Conseguenza vera che su questi semi
non esce quasi mai — non aggiungo un'altra porta per forzarla. Se si vogliono
vedere i siti aperti, la leva e' **partire da aperto**, non moltiplicare le
cause.

Suite **334 test / 6025 asserzioni** verde, sims deterministiche.

---

## [0.1.131] — La selva maledetta ha una causa

Correzione al buco dichiarato in D-163 ([D-164](docs/DECISIONS.md#d-164)): la
selva maledetta era contenuto scritto e **mai raggiunto**.

### Fixed

- **La maledizione ha una causa**: *La Partenza* (812) e *I Fuochi Fuori* (1640)
  fanno diventare selva il bosco della Regione a fuoco. **Tre selve in venti
  partite**, contro zero.

### Changed — e due strade sbagliate, per il verbale

Il primo tentativo era **una carta nuova**, e ha rotto tre cose insieme:

1. **il mazzo si rimescola** — il costruttore lo dice da sempre, e i **tre piani
   di regressione** sono saltati tutti e tre: non per un difetto, ma perche'
   l'anno scritto non era piu' lo stesso anno;
2. **l'equilibrio per famiglia** — sei carte ROTTURA per saga, ne avevo messe
   otto: il mix drammatico e' progettato, non accumulato;
3. **due carte, un disegno solo** — stesso `art_prompt_key`, e c'e' un test che
   lo vieta.

Agganciarla a carte che esistono gia' e' meglio su ogni fronte: **nessun
rimescolo, nessun equilibrio rotto, nessun piano toccato**, e una selva in piu'.

**La regola che ne esce:** quando serve una causa nuova per un effetto nuovo, si
guarda **prima** se una carta esistente sta gia' raccontando quel fatto. Un
mazzo e' un equilibrio, non un elenco.

### Removed

- **`TGR_CURSED_WOOD_COUNCIL`**: la selva che faceva partire **ogni** Consiglio
  col mondo contro. L'avevo aggiunta io e **non era nel progetto** — la seduta
  diceva «chi ha presenza li' perde una carta», che e' una morsa **locale**. Una
  penalita' mondiale da un fatto locale e' un dente sbagliato, e costava tre
  punti.

### Measured

Playtest **FAIL 207 · SUCC 77 · SUCC 112 · DECI 189**, mediana **6**, tavolo
misto **0 su 8**. Suite **334 test / 6005 asserzioni** verde, sims
deterministiche.

**Il trend, di nuovo:** i Consigli falliti dall'inizio della strada C sono
**185 → 191 → 196 → 203 → 201 → 207**, cioe' **+22**. Lo 0/8 regge da undici
modifiche e la banda dei Consigli e' rispettata, ma ventidue punti non sono
rumore: **prima del fiume, del sito antico e della palude va deciso se 207 e' il
numero che vogliamo.** E' una domanda di gusto, e va al committente.

---

## [0.1.130] — La foresta

Passo 5 del catalogo ([D-163](docs/DECISIONS.md#d-163)): il primo **luogo del
mondo**, che non e' di nessuno.

### Added

- **`STR_FOREST`**: Foresta → Bosco diradato → **Selva maledetta** → La Radura
  Spoglia. Un `LUOGO` non ha padrone, non entra nel conto del controllo e non
  sale ne' scende col Destino: cambia **cosa vale** una Regione, non **chi la
  tiene**.
- Tre regole: la foresta intera **da' legna a chiunque ci stia**; la selva
  maledetta toglie **una carta in mano** e fa partire i Consigli col mondo un
  po' contro.
- Il prefisso `place:` per i segni del mondo, accanto a `structure:` e
  `settlement:` che sono opere delle case.
- Tre foreste sulla mappa, dove i biomi le permettono; due Conseguenze le
  diradano o le fanno diventare selva.

### Fixed

- **`SET_STRUCTURE_GRADE` falliva con un errore** su una Regione senza quella
  struttura. Una Conseguenza nomina `$region_focus` e la Regione a fuoco cambia:
  diradare un bosco dove non c'e' un bosco non e' un errore di dati. Adesso
  rispetta `optional`, come `REMOVE_PRESENCE` da sempre. L'errore compariva a
  **ogni partita**.

### Measured — e da dichiarare

Su venti Chronicle: **59** foreste intere a fine anno, **1** bosco diradato,
**0** selve maledette.

Il luogo **c'e' e funziona**; il **degrado quasi no**. Due delle tre regole sono
attaccate a uno stato che non si raggiunge. E' la forma dell'errore di D-161 in
un posto diverso — ma li' erano clausole di Destino, e una clausola che non si
avvera rompe un'ambizione; qui sono regole dei segni, e una regola dormiente non
rompe niente. **La selva maledetta e' contenuto scritto e non raggiunto**, e le
manca una carta del Narratore che la causi.

Playtest **FAIL 201 · SUCC 74 · SUCC 114 · DECI 192**, misto **0 su 8** —
identico a D-162: la foresta non sposta l'equilibrio, e non doveva.

Suite **334 test / 6003 asserzioni** verde, sims deterministiche.

---

## [0.1.129] — Le opere, e il segno che adesso ha un oggetto sotto

Passo 4 del catalogo ([D-162](docs/DECISIONS.md#d-162)).

### Added

- **Tre opere**, due gradi ciascuna: `STR_GRANARY` (Granaio → **Il Grande
  Granaio**), `STR_CANAL` (Canale → **La Grande Opera d'Acqua**), `STR_TOLLGATE`
  (Pedaggio → **La Dogana**).
- **I due gradi portano lo stesso segno**: una grande opera non e' un'opera
  diversa, e' la stessa **che pesa di piu'**. Le tre regole dei segni gia'
  scritte valgono a tutti e due i gradi senza riscriverle; la differenza sta nel
  conto del controllo, 1 contro 2.

### Fixed

- **Sette carte posavano un segno senza oggetto sotto.** Un tag senza struttura
  si vede sulla mappa, fa scattare le regole, e **non conta per nessuno** nella
  contesa: la mappa diceva una cosa e il conto un'altra. Convertite tutte e
  sette — tre Conseguenze, un Asset (padrone: **chi ha messo la carta sul
  tavolo**), tre carte del Narratore, di cui due adesso **fanno cadere
  l'oggetto** invece di cancellare il segno.
- Resta fuori solo `structure:sealed`, che e' una **chiusura**: murare una
  miniera non da' niente a nessuno.

### Measured

| | D-161 | ora |
|---|---|---|
| Consigli falliti | 204 | **201** |
| tavolo misto | 0/8 | **0/8** |
| caselle tenute a fine anno (su 180) | 143 | **150** |

I Consigli falliti erano 185 → 191 → 196 → 203 → 204: **e' la prima volta che
scendono** da quando e' cominciata la strada C. La lettura di D-160 regge — non
era una tassa, erano le policy, e adesso hanno piu' cose vere su cui votare.

Gradini: supera il Minimo **58%** (era 47%), caselle con un padrone **84%** (era
56%), seggi con due Regioni **32%** (era 12%), a zero **11%** (era 30%).

Nel tempo lungo (12 saghe da 8 anni): grado I **44**, grado II **13**, grado III
**4**. Le regge erano **zero** con una sola scala, due con l'insediamento,
quattro adesso — e nessuna e' scritta a mano.

Suite **334 test / 5988 asserzioni** verde, sims deterministiche.

---

## [0.1.128] — Le clausole che leggono le pietre

Richiesta del committente sui Destini ([D-161](docs/DECISIONS.md#d-161)). Meta'
di quello che chiedeva c'era gia': un Destino **e' gia'** una lista di
condizioni per livello, con dodici tipi e `any_of` per l'oppure.

### Added

- **`structure_count`** — quante strutture, coi filtri: tipo, famiglia, **grado
  minimo**, Regione, e `anyone` per contare anche quelle degli altri.
- **`scar_count`** — quante cicatrici, per tag e per Regione. Erano leggibili e
  **nessun Destino le usava**.
- **`some_of`** — almeno `min` fra queste condizioni. `any_of` era il caso K=1.

I due conteggi dicono presenza **e** assenza con lo stesso conto: «un castello a
Eredan» e' `min: 1`, «e nessuno ha alzato una reggia sulla montagna» e'
`grade: 3` + `anyone` + `max: 0`.

### Changed

- **`CNS_ASH_WATCH` costruisce davvero.** Posava un segno; adesso **alza un
  presidio che ha un padrone**, che entra nel conto del controllo e puo'
  crescere. E' la prima Conseguenza che costruisce un oggetto invece di
  scrivere un tag, ed e' il modello per le altre dieci.
- Su 30 Chronicle i passaggi di mano per contesa passano da **63 a 74**, e le
  caselle tenute a fine anno da 138 a **143**.

### Measured — e cinque clausole tolte

Scritte cinque clausole coi tipi nuovi, la sonda ha risposto: **tre mancate al
100%, due mai mancate. Zero utili** — e il Trionfo sceso dal 5% al 3%.

La causa non era il bilanciamento: **erano clausole su uno strato che dentro
l'anno nessuno poteva cambiare.** Le strutture si muovevano solo all'apertura e
alla chiusura; nei nove round non si costruiva niente. E «nessuna cicatrice» e'
una lotteria: **un anno su quaranta** finisce senza.

Le cinque clausole sono state **tolte**. Il vocabolario resta, il contenuto
aspetta il pezzo che mancava — che e' arrivato con `CNS_ASH_WATCH`.

**La regola che ne esce:** una clausola che parla di uno strato si scrive
**dopo** che quello strato ha almeno un modo di cambiare durante l'anno, e si
misura sui gradini **prima** di restare.

Playtest **FAIL 204 · SUCC 73 · SUCC 113 · DECI 186**, mediana **6**, misto
**0 su 8**. Suite **334 test / 5991 asserzioni** verde, sims deterministiche.

---

## [0.1.127] — L'insediamento

La seconda scala del catalogo ([D-160](docs/DECISIONS.md#d-160)), e il trend dei
Consigli falliti guardato per primo come promesso in D-159.

### Measured — il trend, prima di aggiungere

- **Non e' una tassa sistemica**: la sovraestensione morde **11 volte in 30
  partite**. I Consigli aperti sono passati da 5,63 a 5,75 di media — dentro la
  banda (mediana 5-6) — e la quota di fallimenti e' salita di **1,6 punti**.
  La causa e' che le policy **votano diverso** da quando il controllo si conta.

### Added

- **`STR_SETTLEMENT`**: Villaggio (1) → Borgo (2) → Citta' (4) → Abbandono, con
  tre regole dei segni — il villaggio **piega la pesca della gente**, il borgo
  **tiene una carta in piu'**, la citta' piega il **Fattore Mondo**. Riusa il
  prefisso `settlement:` che c'era gia'.
- Un villaggio semina la Valle Verde in tutte e due le linee.

### Measured — e la seconda scala cambia la prima

Dodici saghe da otto anni:

| | solo presidi | col villaggio |
|---|---|---|
| grado II (castelli e borghi) | 3 | **13** |
| grado III (regge e citta') | 0 | **2** |

**Con due strutture, chi perde lascia andare il villaggio e tiene il castello**:
il grado cade sulla piu' bassa e sale sulla piu' alta, quindi i presidi non sono
piu' i primi a cadere e arrivano in fondo alla scala. Le prime **due regge**
compaiono qui, e nessuno le aveva scritte a mano.

Playtest **FAIL 204 · SUCC 73 · SUCC 113 · DECI 186**, mediana **6**, tavolo
misto **0 su 8**. Gradini: supera il Minimo **59%** (era 47%), caselle con un
padrone **81%**, seggi con due Regioni **30%**.

### Changed

- **`SIM_PLAN_C` aggiornato**: il sesto Consiglio passa a FAILURE per **un punto
  solo**. Il Cristallo, cuore narrativo del piano, sta al terzo e non si e'
  mosso; la descrizione e' stata riscritta per dire il vero.
- **I test delle strutture sgomberano la propria Regione** invece di dare per
  scontata una mappa vuota: quali Regioni siano costruite e' contenuto, e un
  test non deve dipenderne per misurare un meccanismo.

Suite **334 test / 5992 asserzioni** verde, sims deterministiche.

---

## [0.1.126] — La scala che si muove col Destino

«Se la reggia appartiene all'entita' che ha perso va in rovina, se invece
trionfa diventa una reggia» ([D-159](docs/DECISIONS.md#d-159), §7.3 della seduta
sulla terra).

### Added

- **`structure_rules`** sulla Chronicle: chi trionfa **alza di un grado la sua
  struttura piu' alta**, chi non arriva al Minimo **ne perde uno sulla piu'
  bassa**. Sotto il primo grado non si scende: si va in **rovina**, e la rovina
  lascia una cicatrice.
- **`starting_structures`**: la mappa si apre gia' costruita. Le tre Regioni che
  partono con un padrone partono con una **torre di veglia**. Sta sulla
  Chronicle e non sulla Regione per la stessa ragione di `starting_control`.

### Measured

Dodici saghe da otto anni:

| | |
|---|---|
| gradi saliti (Trionfo) | **24** |
| strutture andate in rovina | **19** |
| castelli in piedi all'ottavo anno | **3** |
| regge | 0 |

In otto anni tre torri diventano castelli e nessuno arriva a una reggia: e' il
ritmo giusto, una reggia deve restare un fatto raro.

Playtest **FAIL 203 · SUCC 76 · SUCC 108 · DECI 188**, tavolo misto **0 su 8**,
uniforme **2 su 8**; mappa al **76%** di caselle con un padrone.

**Da dichiarare:** i Consigli falliti sono passati da 185 a 191, 196, **203** in
tre modifiche di fila. Il vincolo 0/8 regge, ma il numero si muove sempre nella
stessa direzione e alla prossima va guardato per primo.

### Fixed

- **La torre di partenza copriva la reggia ereditata.** `BUILD_STRUCTURE` e' un
  no-op se il tipo c'e' gia' e il setup gira prima dell'eredita': una reggia
  dell'anno prima tornava una torre. L'eredita' adesso abbatte e rialza.
- Due test misuravano una mappa vuota che non esiste piu' (uno cercava «la prima
  `BUILD_STRUCTURE`», l'altro incontrava `TGR_WATCHTOWER_FORCE` e la chiamava
  telaio). Nessuno dei due era un difetto del gioco.
- Di nuovo il passo dei due artefatti generati: schema aggiornato,
  `gen_gd_schema.py` dimenticato, playtest morto con «unexpected field».

Suite **334 test / 5977 asserzioni** verde, sims deterministiche.

---

## [0.1.125] — La contesa del controllo

Il padrone di una Regione non e' piu' **scritto** ma **contato**
([D-158](docs/DECISIONS.md#d-158), §7.2 della seduta sulla terra): chi somma di
piu' fra il valore delle proprie strutture e le proprie pedine, a ogni fine
round.

### Added

- **`control_rules.contested`** nella Chronicle: la contesa, con il peso della
  pedina dichiarato nei dati. Omessa, il gioco e' quello di prima.
- `control_strength`, `strongest_in` e `rightful_holder` nel servizio del mondo;
  il riconteggio a fine round nel controller, che passa da un `SET_CONTROL`
  normale — stesso Effect, stesso inverso, stessa riga nel registro.
- **`tests/unit/test_control_contest.gd`**, sette test: le due monete che si
  sommano, il castello che perde contro l'esercito piu' grande, il pareggio che
  non cambia niente, e la regola che si spegne dai dati.

### Measured

Sessanta Chronicle a tavolo misto — **la mappa si e' mossa**:

| | prima | ora |
|---|---|---|
| caselle con un padrone | 56% | **76%** |
| seggi a **zero** Regioni | 30% | **15%** |
| seggi con **due** Regioni | 12% | **25%** |

- **Il Vetro passa da 0,00 a 1,00.** La casa che in trenta partite non aveva mai
  tenuto una Regione adesso ne tiene una — non perche' gliel'abbiano data, ma
  perche' sta da qualche parte.
- Playtest **FAIL 196 · SUCC 68 · SUCC 116 · DECI 186**, tavolo misto **0 su 8**,
  tavolo uniforme **3/8 → 2/8**.
- **`control_count >= 2` sparisce dalle clausole mancate.** In cima restano le
  **clausole sociali** — «qualcuno ha giurato» 70%, «l'insediamento e'
  riconosciuto» 57% — che e' la seconda famiglia di D-151 e chiede persone.

### Changed

- **`lapse_without_presence` diventa un caso particolare del conto**: chi non ha
  niente li' somma zero, e zero non tiene niente.
- **Il Consiglio da' un titolo, tenerlo e' un'altra cosa**: le 14 Conseguenze che
  scrivono un nome valgono finche' quel nome regge il conto. Non riscritte — la
  misura dice che cosi' funzionano.

Suite **334 test / 5981 asserzioni** verde, sims deterministiche, `dead_code.py`
pulito su 151 file.

---

## [0.1.124] — La terra si costruisce

Primo passo della strada C ([D-157](docs/DECISIONS.md#d-157)): **una struttura
smette di essere un tag e diventa un oggetto**. E' il livello su cui sta tutto
il resto del catalogo.

### Added

- **`schema/structure_type.schema.json`**: il catalogo. Un tipo dichiara la
  famiglia (PRESIDIO · INSEDIAMENTO · OPERA · LUOGO · CHIUSURA), se ha un
  padrone, in quali biomi puo' stare, i **gradi** — ognuno con nome, **valore** e
  il segno che posa — e come finisce in rovina.
- **`world.regions[id].structures`**: una lista di `{structure_type, grade,
  owner}`.
- **Tre Effect nuovi**, coi loro inversi: `BUILD_STRUCTURE` ↔ `RAZE_STRUCTURE`,
  e `SET_STRUCTURE_GRADE` che si inverte su se stesso col grado di prima.
  L'enum chiuso passa da **22 a 25**.
- **Le pietre attraversano gli anni**: l'eredita' le riporta com'erano — una
  reggia resta una reggia — e il padrone segue `lapse_without_presence`: senza
  nessuno dentro, restano di nessuno.
- **Il catalogo parte col Presidio**: Torre di veglia (2) → Castello (3) →
  Reggia (5), e la Rovina che lascia `scar:abandoned`.
- **`tests/unit/test_structures.gd`**, otto test sul meccanismo.

### Changed

- **L'oggetto e' la verita', il tag e' derivato**: ogni grado dichiara il proprio
  `structure:`, e alzarlo o abbatterlo posa e toglie quel segno. Le **cinque
  regole dei segni** gia' scritte continuano a funzionare senza sapere che sotto
  e' cambiato tutto.

### Measured

- **Nessun dato del gioco costruisce niente**, e il playtest e' **identico** a
  0.1.122: **FAIL 191 · SUCC 69 · SUCC 116 · DECI 190**, tavolo misto **0 su 8**.
  Un livello nuovo che non muove un numero e' un livello che non ha ancora
  opinioni.
- Suite **327 test / 5996 asserzioni** verde, `run_sims.sh` identico su due
  giri, `dead_code.py` pulito su 150 file.

### Fixed

- Due difetti presi dalla suite e non a mano: una `x-echoes-kind` inventata
  faceva **sparire lo schema dal registro di Godot** (288 test rossi in un
  colpo), e il guardiano di D-003 ha rifiutato i tre Effect nuovi finche' non
  hanno avuto il loro test di andata e ritorno.

---

## [0.1.123] — Il catalogo delle strutture

«Le strutture pero' come ti ho detto mi sembrano pochi e solo 5.» Contate bene
sono meno.

### Measured

- **Quattro costruzioni**, non cinque: granaio, canale, barriera di pedaggio,
  torre di veglia. La quinta, `structure:sealed`, non e' un edificio — e' il
  **contrario** di un edificio.
- **Due insediamenti** (`settlement:march`, `settlement:market`) in una famiglia
  parallela quasi inutilizzata, piu' uno che e' solo una casella da riempire.
- **Zero luoghi naturali**, e sei biomi (citta', valle, steppa, montagna,
  sottosuolo, strada) che non hanno niente che li distingua se non un tag
  decorativo.

### Added

- **`docs/SEDUTA_TERRA.md` §8, il catalogo.** Da cinque tag a **una ventina di
  cose** che possono stare in una Regione, ognuna con un numero, un effetto e un
  modo di finire.
- **Il principio che lo tiene insieme**: non tutto quello che sta su una mappa
  appartiene a qualcuno. **Le opere delle case** (presidio: torre → castello →
  reggia · insediamento: villaggio → borgo → citta' · opere: canale, granaio,
  pedaggio, ponte) hanno un padrone e un valore nella contesa del controllo.
  **I luoghi del mondo** (foresta, passo, fiume, sito antico, palude) non sono di
  nessuno: cambiano *cosa vale* una Regione senza cambiare *chi la tiene*.
- **Il passo che frana** e' segnalato come il pezzo piu' pesante: le adiacenze
  sono oggi l'unica cosa della mappa che non cambia mai, e un passo chiuso
  riscrive il grafo. Va scritto per ultimo, e misurato con attenzione — un grafo
  spezzato puo' rendere un Destino impossibile.
- **L'ordine di scrittura** in cinque passi, ognuno misurato sui 100 semi e
  vincolato a **0/8** al tavolo misto.

Nessuna modifica al gioco: e' un dossier.

---

## [0.1.122] — La porta sola della Cenere

ISSUES 38, che il committente ha chiesto di chiudere prima della strada C
([D-156](docs/DECISIONS.md#d-156)).

### Measured (prima di scrivere)

Sedici clausole candidate valutate a fine anno su **40 Chronicle** di CHR_03:
sette valgono il **100%** — fra cui **`control_count >= 1`**, che spiega perche'
in D-154 abbassare la soglia regalava a Kessa la Vittoria — mentre l'unica
davvero contesa era **`ash_watch`, la veglia sulla montagna, al 45%**.
`control_count >= 2` valeva il **12%**.

### Changed

- **`DST_CENERE` riscritto.** La Vittoria era «Tengono la montagna, e non solo
  quella» (control ≥2 · gallerie non murate, cioe' **una porta e una
  decorazione**) e non diceva quello che questa casa vuole. Adesso e' **«Chi
  scava lo dicono loro»**: la montagna e' ancora loro · **e la veglia e'
  affidata a loro, per atto e non per abitudine** · e le gallerie non sono state
  murate.
- **Il controllo di due Regioni e' salito al Trionfo** — «E non solo quella» —
  dove il suo 12% e' una virtu' invece che un muro. E' il principio di D-152
  applicato per intero: **la Vittoria chiede di tenere, il Trionfo di crescere**.

| Kessa dei Fuochi, 50 partite | NONE | MINIMO | VITTORIA | TRIONFO |
|---|---|---|---|---|
| prima | 1 | **44** | 5 | 0 |
| adesso | 0 | 18 | **31** | 1 |

### Measured (dopo)

- Tavolo misto **0 su 8**. Sessanta Chronicle: supera il Minimo **48% → 54%**,
  VITTORIA 43% → **48%**, TRIONFO 5% → **6%**.
- **Il prezzo, dichiarato:** Consigli falliti **177 → 191**, tavolo uniforme da
  2 a 3 seggi bloccati. La Cenere adesso **si batte** per la veglia, e un tavolo
  dove una casa in piu' ha qualcosa da difendere litiga di piu'.
- **Lezione di metodo:** `ash_watch` valeva il 45% quando nessuno lo cercava, e
  vale il **63%** da quando e' una clausola di Vittoria. Una clausola diventa
  piu' facile nel momento in cui diventa un obiettivo — la misura preventiva
  dice quali porte esistono, non quanto saranno larghe dopo.
- **Trovato per strada:** «col Vetro non si e' arrivati alla rottura» vale
  **0% su 40 partite**. Cenere e Ordine del Vetro partono NEMICI e non risalgono
  mai: terza volta che le relazioni ferme si presentano da una porta diversa
  (D-139, D-151).

**ISSUES 38 e 38bis chiuse**, e la strada C della seduta sulla terra e'
sbloccata.

### Fixed

- **`docs/ASSET_MANIFEST.md` rigenerato.** E' un artefatto derivato e porta le
  etichette dei gradini di ogni Destino: la nuova Vittoria della Cenere lo aveva
  disallineato e la CI lo ha bocciato. La regola di casa parlava solo di
  `gen_gd_schema.py`: gli artefatti generati sono **due**.

---

## [0.1.121] — Le carte parlano

Difetto trovato dal committente giocando ([D-155](docs/DECISIONS.md#d-155)):
«le frasi sono belle ma non si capiscono e alla fine non hanno effetti sul
gioco». Gli effetti c'erano — **39 carte del Narratore su 39** ne portano almeno
uno. Era la carta a essere muta.

### Added

- **`scripts/core/echo_text.gd`**: cosa fa una carta del Narratore, prima di
  calarla. Titolo, tono della famiglia drammatica («stringe, rompe, svolta,
  chiude, ricorda») e gli effetti uno per uno, compreso **se apre un Consiglio**.
  Composto dai campi che il motore legge davvero, come `asset_text.gd`.
- **`tests/unit/test_card_speech.gd`**: nessuna carta muta, nessun
  identificativo grezzo davanti a chi gioca, e i segni detti in italiano.

### Fixed

- **La mappa parlava in identificativi.** `Valle Verde: condition:lean` diventa
  «Valle Verde: il raccolto non basta». **31 segni** hanno una frase, e una
  **seconda** per quando spariscono («la fame e' passata», «il granaio non c'e'
  piu») perche' «non piu si muore di fame» non e' italiano.
- `SET_ENTITY_TAG` e `REMOVE_ENTITY_TAG` non stampano piu' il tipo grezzo.
- **Le caselle da riempire** in anteprima diventano parole: `$rival` e' «un
  rivale», `$region_focus` «la Regione della domanda».
- **`SET_RELATION` non risolveva nessuno dei due lati** della coppia: diceva
  `$proponent / $rival`. Trovato dal test nuovo, non a mano — sfuggiva perche'
  nessuno guardava mai quella frase in anteprima.

Suite **319 test / 5959 asserzioni** verde, `dead_code.py` pulito su 149 file.
Nessuna regola cambiata: il gioco fa quello che faceva prima, e adesso lo dice.

---

## [0.1.120] — La seduta sulla terra

Tre idee del committente arrivate una dopo l'altra sono la stessa domanda vista
da tre lati: **come si rende visibile, costoso e duraturo il possesso di un
luogo?** Il dossier le mette accanto una volta sola invece che tre.

### Added

- **`docs/SEDUTA_TERRA.md`**: le tre strade coi loro prezzi — **A** le carte che
  posano una pedina, **B** la carta che *e'* la presenza, **C** le strutture con
  una vita (torre → castello → reggia, la rovina, la demolizione). Raccomandata
  **C**, con **A** come primo passo, e **ISSUES 38 prima di tutto**.

### Measured

- **Le strutture funzionano gia' meglio della presenza.** Su 30 Chronicle:
  **74 alzate** (2,5 a partita), **2,00 in piedi** a fine anno, **29 partite su
  30** ne hanno almeno una — contro poco piu' di **una pedina** mossa per scelta.
- **Zero abbattute in 30 anni giocati.** Una struttura oggi e' un interruttore
  che si accende e non si spegne, e `structure:` attraversa le Chronicle **senza
  sbiadire** (a differenza di `condition:`): in una saga la mappa puo' solo
  riempirsi. E' il difetto che l'idea del committente corregge da se'.
- Il pedaggio da solo e' **48 delle 74**, e lo posa un **Asset**
  (`AST_WEALTH_TOLL`): la carta che costruisce esiste gia', ed e' una sola.
- Gia' oggi 11 carte posano una struttura, **5 regole dei segni** le leggono, e
  tre Asset posano una pedina di presenza.

### Changed

- **ISSUES 39** riscritta come voce di seduta, con la strada A conservata per
  esteso come primo passo.

Nessuna modifica al gioco.

---

## [0.1.119] — Il peso della terra: meccanismo acceso, contenuto spento

Il committente ha deciso che **il titolo deve dare qualcosa dentro l'anno**
([D-154](docs/DECISIONS.md#d-154)). La leva e' scritta e provata; **nei dati e'
spenta**, e la ragione e' un numero.

### Added

- **`focus_weight`** in `confluence_rules`: al Consiglio, la Regione di cui si
  discute da' voce a chi ci sta — **il titolo** a chi ne e' il padrone, **la
  maggioranza** a chi ci ha strettamente piu' pedine (a parita', nessuno). I due
  si sommano fino a un tetto, e contano solo se quel seggio ha impegnato almeno
  una carta.
- **`tests/unit/test_focus_weight.gd`**: sette test che tengono fermo il
  meccanismo con una regola sintetica, visto che nei dati e' omessa.

### Measured

| | Consigli falliti | tavolo misto |
|---|---|---|
| spento | **177** | **0 su 8** |
| titolo +1, maggioranza +1, a tutti | **164** | **1 su 8** |
| lo stesso, senza il proponente | 175 | **1 su 8** |

- **Il peso finiva al proponente**, che e' gia' scelto *per* la presenza: pagato
  due volte per lo stesso investimento, e i Consigli passavano troppo.
  Escluderlo rimette i numeri in banda.
- **Resta 1 su 8, e il seggio e' sempre Kessa** — non per il peso della terra ma
  perche' la sua Vittoria ha una porta sola (ISSUES 38). La differenza e'
  letteralmente **una partita**. Il vincolo 0/8 lo sta facendo rispettare il
  seggio piu' fragile del gioco.
- **Chi muove le pedine, su 30 Chronicle**: 240 posate al setup, **38** da
  MUOVERE, 21 da una carta, 7 da un Consiglio. Poco piu' di una pedina per
  partita si muove per scelta. La mappa non e' ferma perche' il titolo non
  paga — e' ferma perche' **nessuno ha carte con cui muoverla**.

### Changed

- **ISSUES 39** (nuova, voluta dal committente): le carte che posano una pedina.
  Il vocabolario esiste gia' ma e' quasi spento — 5 Asset su 48, e nessuno nelle
  famiglie FORZA e GENTE. Due strade: estendere le carte, oppure far si' che la
  carta **sia** la presenza.
- **ISSUES 38bis**: nota di metodo — ISSUES 38 va aperta prima di provare altre
  leve sul Consiglio.

Suite **312 test / 5943 asserzioni** verde. Playtest con la regola spenta
identico a 0.1.118: **FAIL 177 · SUCC 73 · SUCC 126 · DECI 187**, misto **0/8**.

---

## [0.1.118] — La presenza fa, il controllo conta

Domanda del committente sulla meccanica appena scritta: «prendere una Regione
cosa significa? Non basta avere una presenza?». Il documento non lo diceva, e
l'infografica sarebbe venuta sbagliata.

### Fixed

- **`docs/MECCANICA.md`** ha una sezione nuova, *Presenza e controllo: la
  distinzione che conta*, con le due liste affiancate. E le note per chi disegna
  avvertono dell'errore che un'infografica fa da sola: disegnare la mappa come
  una mappa di conquista.

### Measured

Cercato ogni punto del codice che legge `control`. I consumatori sono **tre**,
piu' la prosa e il disegno:

- `control_count` — **14 clausole di Destino**;
- la **sovraestensione** — oltre 2 Regioni, +1 di Tensione a round: un **costo**;
- il **passaggio all'anno dopo**, e solo se ci si sta dentro.

Il controllo **non** decide chi propone al Consiglio (e' la presenza), non
sblocca azioni, non piega la pesca, non vale un punto nel margine. **Dentro
l'anno non da' nessun vantaggio meccanico.**

La presenza invece comanda: chi propone, l'INFLUENZARE gratuito, l'ACQUISIRE
potenziato, dove si puo' MUOVERE, le regole dei segni con `scope: REGION`, e 16
clausole di Destino.

### Changed

- **`docs/ISSUES.md` 37** raccoglie la seconda meta' della diagnosi: la catena
  di `ACT_CLAIM` non e' solo lunga, **e' lunga e non porta a niente di
  immediato** — ecco perche' 48 rivendicazioni su 63 muoiono in mano. E aggiunge
  la domanda che viene prima delle quattro strade: **se il titolo debba dare
  qualcosa dentro l'anno**, che e' design e non taratura.

Nessuna modifica al gioco.

---

## [0.1.117] — La meccanica, tutta in un foglio

### Added

- **`docs/MECCANICA.md`**: la spiegazione completa e autosufficiente di come si
  gioca — struttura del tempo, mappa, casate, Tensioni, le sette azioni, il
  Consiglio A→K con la matematica, le carte, i Destini, la saga. Scritta perche'
  chi non ha mai visto il gioco lo capisca, e perche' si possa passare a un
  altro strumento per farne un'infografica: chiude con una sezione di note su
  cosa merita un riquadro e cosa si puo' omettere.
- Tutti i numeri sono letti dai dati e dal codice, non ricordati: 6 Regioni con
  8 adiacenze, 4 Tensioni su 6 per mondo, 132 carte Asset in 48 tipi, 39 carte
  Narratore in 5 famiglie e 24 funzioni, 52 Conseguenze (14 cambiano padrone a
  una Regione), 10 modelli di Consiglio, 45 regole dei segni, 22 tipi di
  effetto.

---

## [0.1.116] — «Rivendicare» esiste

Correzione a 0.1.115, sollevata dal committente: «ma scusa, le Regioni non si
prendono con un'azione specifica?». Sì ([D-153](docs/DECISIONS.md#d-153)).

### Fixed

- **La frase di D-152 era fuorviante.** `ACT_CLAIM` («Rivendicare») esiste. Non
  prende una Regione: apre un Claim su un **dominio di Tensione** scartando un
  Asset AUTHORITY, e in un round successivo lo consuma con un secondo AUTHORITY
  per **strappare un Consiglio da proponente**. La Regione arriva se quel
  Consiglio cade su una delle 14 Consequence con `SET_CONTROL` a `$proponent`.
- `docs/ISSUES.md` 37 riscritta sulla premessa giusta, README aggiornato.

### Added

- **`cli/run_rung_probe.gd`** conta i tre numeri della catena: rivendicazioni
  aperte, Consigli strappati, rivendicazioni morte in mano.

### Measured

- Su 60 Chronicle: **63 rivendicazioni aperte, 15 forzate, 48 morte senza
  essere usate**. Tre su quattro si pagano e non si spendono — la catena si
  spezza al terzo dei suoi cinque anelli.
- In trenta Chronicle `ACT_ACQUIRE` produce **4286** effetti e `ACT_CLAIM`
  **84**: le case raccolgono, non rivendicano.
- Nessuna modifica al gioco. Playtest invariato — **FAIL 177 · SUCC 73 ·
  SUCC 126 · DECI 187**, tavolo misto **0/8**. Suite **305 verde**.

---

## [0.1.115] — La corona tiene la sua terra

La prima delle due decisioni che D-151 aveva rimandato al committente
([D-152](docs/DECISIONS.md#d-152)): abbassare una soglia. La misura ne ha
approvata una e respinta l'altra.

### Changed

- **`DST_ALDRIC`, vittoria**: `control_count min 2` -> `min 1`, etichetta da
  «Controllo di almeno 2 Regioni» a **«La corona tiene ancora la sua terra»**.
  Con `lapse_without_presence` attivo, «almeno una» non e' gratis: il 30% dei
  seggi finisce l'anno senza nessuna Regione.
- Re Aldric, 50 partite: da **0/43/5/2** (NONE/MINIMO/VITTORIA/TRIONFO) a
  **1/24/17/8**. Il suo ostacolo adesso e' la Carestia, non la terra.

### Added

- **`cli/run_rung_probe.gd`** misura anche il tabellone: quante Regioni tiene
  ogni seggio a fine anno, quante caselle restano senza padrone, e quante
  passano di mano in gioco.

### Measured

- **La mappa quasi non si muove**: 0 Regioni per il 30% dei seggi, 1 per il
  57%, 2 per il **12%**, 3 per l'1%. Il **44% delle caselle non e' di
  nessuno**. Il controllo non si prende con un'azione: passa solo per una
  Consequence, cioe' per un Consiglio che si chiude.
- In un anno una casa guadagna in media **un quarto di Regione**. Il Vetro non
  ne tiene **mai** una in trenta partite; le Citta' Libere scendono da 1,00 a
  0,67.
- **Correzione a D-151**: `max_stable_control: 2` non e' un tetto ma una
  soglia di fatica (D-027), e nessuno la tocca — tre seggi su 240 tengono tre
  Regioni. Non era quello il vincolo.
- **Respinta**: la stessa modifica sulla Cenere porta Kessa a **zero Minimi su
  cinquanta** e 30 Trionfi. La sua soglia reggeva anche il gradino sopra;
  resta a 2.
- Playtest 100 semi da 7000: **FAIL 177 · SUCC 73 · SUCC 126 · DECI 187**;
  tavolo misto **0/8**; tavolo uniforme **3/8 -> 2/8**. Suite **305 verde**,
  `run_sims.sh` e `run_export.sh` deterministici.

---

## [0.1.114] — I gradini

La diagnosi per clausola ([D-151](docs/DECISIONS.md#d-151)): non «la Vittoria
e' difficile» ma **quale clausola** non si avvera.

### Added

- **`cli/run_rung_probe.gd`**: sessanta Chronicle a tavolo misto, e per ogni
  Destino quante volte ogni singola clausola resta in sospeso.

### Measured

- NONE 0% · MINIMUM **52%** · VICTORY **42%** · TRIUMPH **5%**; supera il
  Minimo il **47%** (nelle saghe era il 30%: una Chronicle che eredita un
  mondo segnato e' piu' dura di una sul foglio pulito).
- **`control_count >= 2` chiede il tetto**: `max_stable_control` e' 2, su sei
  Regioni divise fra quattro case. La Cenere manca quella clausola nell'87%
  delle partite, Aldric nel 63%.
- **Le clausole che dipendono da un altro non si avverano mai**: «qualcuno ha
  giurato» manca nel 77%, «la Gilda non e' diventata un nemico» nel 90%. Sono
  5 clausole su 104 — e in venti Chronicle le relazioni si muovono **una volta
  sola**. Chiude il cerchio di D-139: il peso dell'alleanza e' raro perche'
  nessun bot stringe alleanze.

### Notes

- **Non e' stato toccato niente**: e' una diagnosi. Abbassare una soglia e'
  contenuto d'autore; misurare le clausole sociali richiede persone, non semi.

---

## [0.1.113] — Il pool dei Destini (meccanismo acceso, contenuto spento)

La strada A della seduta sulle linee ([D-150](docs/DECISIONS.md#d-150)): il
meccanismo c'e' e si prova, **nelle Chronicle e' spento** perche' la misura ha
detto di no.

### Added

- **`destiny_pool`** sulla Chronicle: per ogni casa, i Destini fra cui l'anno
  pesca. E' `tension_pool` applicato agli obiettivi; omesso, non cambia niente.
- **Il dado dei Destini e' a parte** (come i caratteri in D-051): accendere il
  pool cambia cosa la gente vuole, **non che mondo trova**.
- Quattro test, e uno prova proprio quello: coi pool accesi le domande e i
  mazzi restano identici.

### Changed

- Il banco di prova **neutralizza la pesca**: `new_session` rimette a ogni casa
  il Destino scritto. Dieci test erano diventati rossi il giorno in cui il pool
  si e' acceso, tutti perche' davano per scontato cosa una casa volesse.

### Measured

- **Coi pool accesi il playtest esce di banda**: Consigli falliti **222**
  (contro 185) e **2 su 8** seggi bloccati al tavolo misto (contro 0). Gli otto
  Destini alternativi sono contenuto scritto ai tempi di D-111 e **mai
  giocato**: vanno accesi uno per volta, misurando.
- La varieta' pero' risponde: prima linea a **distanza 0,89** (da 0,81), 84
  frasi distinte (da 74), Trionfi **15** (da 11).
- Coi pool spenti: playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**,
  tavolo misto **0 su 8**; suite **305 test / 6202 asserzioni** verde; sims
  deterministici.

### Notes

- **Il Minimo di ogni Destino e' «esistere»** — due coppie ce l'hanno identico
  parola per parola. Non e' un obiettivo, e' una soglia di sopravvivenza: la
  misura giusta per ISSUES 35 non e' la colonna MINIMUM ma **quanti la
  superano**, ferma al 30% col pool e senza.

---

## [0.1.112] — La distanza fra due saghe

La misura che mancava prima di aggiungere varieta'
([D-149](docs/DECISIONS.md#d-149)).

### Added

- **`cli/run_variety_probe.gd`**: quanto si somigliano due saghe, misurato
  sulle **Truth** — le frasi che restano scritte nel registro. Frasi
  distinte, **nocciolo** (quelle presenti in tutte le saghe) e **distanza**
  media fra due saghe qualsiasi. A tavolo misto (D-053).

### Measured

- Cinque saghe da sei Chronicle: **distanza 0,81** sulla prima linea, **0,79**
  sulla seconda; nocciolo **2 frasi**; 10 vite su 14 viste al tavolo.
- **Il 64% dei Destini finisce al Minimo** sulla prima linea, il 52% sulla
  seconda: le storie sono gia' diverse, **gli obiettivi no**.

### Fixed

- Due difetti di misura presi prima di fidarsi del numero: la distanza usciva
  **1,00** perche' le frasi portano dentro l'anno e il punteggio (misurava
  l'orologio, non la storia); e le vite erano contate su un campo che non
  esiste (`incarnation_id` invece di `incarnation`) — quattro in trenta
  Chronicle, un numero che non tornava guardando le saghe raccontate.

---

## [0.1.111] — La saga del Sale

Una saga intera sull'altra linea, raccontata
([SAGA_SALE.md](docs/SAGA_SALE.md)), e il confronto con la prima.

### Added

- **`docs/SAGA_SALE.md`**: dieci Chronicle sulla linea delle citta'
  (1640–2355, seme 1204, CHR_03 poi CHR_04), anno per anno.

### Measured

- **La saga dell'812 rigiocata oggi e' identica** — anno per anno, nome per
  nome, livello per livello. Di tutto il lavoro da 0.1.101 in poi l'unica
  cosa che tocca il motore e' il peso dell'alleanza (D-139), e quel dente ha
  morso **una volta sola in dieci Chronicle** (nel Consiglio del 1057, senza
  cambiarne l'esito). Nella saga del Sale: **mai**.

### Notes

- ISSUES 35 aperta: nella seconda meta' della saga del Sale i Consigli
  continuano a riuscire e i Destini smettono di avanzare — **sedici Minimi su
  venti** da quando le istituzioni sostituiscono le persone. Da misurare a
  tavolo misto prima di toccare qualsiasi cosa.

---

## [0.1.110] — Il ritardatario

Chi si collega a partita cominciata adesso lo sa
([D-148](docs/DECISIONS.md#d-148)).

### Added

- **`ConsoleHost.seated()` e `watching()`**: la stanza dichiara chi gioca al
  via, e chi si aggancia dopo riceve una riga che gli dice che il suo seggio lo
  sta giocando la policy e che da li' puo' guardare. Prima lo scopriva dal
  silenzio — identico a un filo rotto.
- Un test: prima del via nessuno guarda soltanto; dopo, chi non c'era guarda e
  chi c'era gioca.

### Measured

- Suite **301 test / 6145 asserzioni** verde; filo **trasparente byte per
  byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto
  **0 su 8**, invariato.

### Notes

- Un seggio lasciato alla policy resta alla policy fino a fine Chronicle:
  prenderselo a meta' partita e' la console di riserva rovesciata, e aspetta
  nello stesso posto — dopo la prova.

---

## [0.1.109] — Quanti giocatori, e i bot alla prova

Le tre domande del committente sul numero di giocatori e sui bot
([D-147](docs/DECISIONS.md#d-147)).

### Added

- **Il menu chiede chi altro gioca da questo schermo**: scelto il proprio
  seggio, «siete in N, qualcun altro?» finche' il tavolo e' pieno o qualcuno
  dice basta. La riga di comando e la stanza lo sapevano gia' fare; il menu
  offriva uno solo dei quattro modi.
- **`cli/run_bot_probe.gd`**: i bot contro il caso, sullo stesso mondo giocato
  due volte. Il punteggio e' il **Destino raggiunto**, non i Consigli vinti.

### Measured

- **I bot giocano**: su 40 partite la policy fa meglio in **26**, peggio in 2,
  pari in 12 — media **1,65 contro 0,57**. Il caso manca il Destino minimo in
  **20 partite su 40**; la policy **mai**.
- Playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto **0 su
  8**, invariato; suite **300 test / 6141 asserzioni** verde.

### Notes

- **I seggi sono quattro e non e' un'impostazione**: ogni Chronicle dichiara
  le sue quattro case, e domande, relazioni, Destini e proposizioni sono
  scritti per quelle voci. Un tavolo a tre o a cinque e' un'altra Chronicle da
  scrivere, non una casella da spuntare.

---

## [0.1.108] — I pezzi si muovono sulla mappa

La console ripensata come l'ha chiesta il committente
([D-146](docs/DECISIONS.md#d-146)): schede, telefono coricato, e la mappa che
risponde alle domande.

### Added

- **Le mosse si giocano sulla mappa**: la console prende `/mappa.svg` inline,
  le Regioni che la domanda offre si accendono col cerchio d'oro e il tocco
  risponde. I `subjects` arrivavano al telefono da sempre — nessuno li
  guardava.
- **Tre schede** (Mappa · Mano · Seggio) con un pallino sulla linguetta che ha
  qualcosa, invece di una colonna sola da scorrere.
- **Il telefono coricato affianca** schede e domanda invece di impilarle:
  mappa a sinistra, scelte a destra, niente da scorrere per giocare.
- Ogni Regione nel tabellone porta il suo id (`data-region`) e il cerchio
  «raggiungibile», spento nel disegno e acceso dalla console.

### Changed

- Le scelte che si giocano sulla mappa **non** compaiono anche come bottoni:
  due strade per la stessa mossa vogliono dire che una delle due e' sbagliata.
  Delle 18 scelte di un'azione, 4 vanno sulla mappa e 14 restano in elenco.

### Fixed

- `main` era `display: flex` senza direzione, e in CSS il flex e' una riga:
  in piedi la barra della domanda si metteva **di fianco** alla mappa e se la
  mangiava. Una fotografia l'ha trovata in un secondo.

### Measured

- Sonda dei messaggi **20.844 perquisiti, FUGHE 0**; filo **trasparente byte
  per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo
  misto **0 su 8**; suite **300 test / 6141 asserzioni** verde.

### Notes

- Un token, una console: due pagine aperte con lo stesso codice se lo
  contendono. Al tavolo un seggio ha un telefono solo, quindi non morde.

---

## [0.1.107] — Il tabellone disegnato

La mappa vera sulla vetrina, con pedine e vessilli, e le carte giocate in
tavola ([D-145](docs/DECISIONS.md#d-145)).

### Added

- **`board_sheet.gd`** e `/mappa.svg` serviti dall'host: il tabellone
  disegnato dagli **stessi piani** del canvas — `RegionArt.plan` per le
  tessere e il terreno, `IconSet` per pedine e vessilli, i colori dei seggi
  dall'ordine di turno. Una forma sola, tre usi: canvas, fustella, browser.
- **Le carte impegnate in Consiglio** sulla vetrina, con la faccia e il
  fronte su cui sono cadute — dai Consigli **chiusi**, perche' gli impegni si
  rivelano tutti insieme in seduta (D-014).
- Una guardia nella perquisizione della vetrina: nessun Consiglio **ancora
  aperto** puo' comparire in tavola.
- Quattro test sul tabellone (ogni Regione col suo nome, una pedina per
  presenza, i colori dei seggi che non si ripetono, nessuna mano).

### Fixed

- Il tabellone dentro la griglia delle Regioni diventava una cella larga come
  un riquadro: sta fuori, e i riquadri restano sotto per l'ispezione al tocco.

### Measured

- Sonda dei messaggi: **20.844 perquisiti, FUGHE 0**; filo **trasparente byte
  per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo
  misto **0 su 8**; suite **300 test / 6141 asserzioni** verde; sims ed export
  deterministici.

### Notes

- La prima stesura della guardia confrontava il **titolo** della domanda e ha
  dato **58 fughe false**: la stessa domanda torna al Consiglio piu' volte.
  Terza volta che il confronto per nome inganna (658 in D-135, 54 in D-144):
  un titolo non e' un'identita'. Ora confronta il `confluence_id`.

---

## [0.1.106] — Le carte vere, e la mano che il tavolo leggeva

Le carte come carte sul telefono e sulla vetrina — e la fuga che le facce
hanno reso visibile ([D-144](docs/DECISIONS.md#d-144)).

### Added

- **`/carta/<mazzo>/<id>.svg`** servito dall'host, da `PrintSheet.card_svg`:
  la stessa funzione che impagina i fogli da fustellare e che l'app
  rasterizza per la mano sullo schermo. Sul telefono la mano sono **carte da
  toccare** (un tocco le ingrandisce); sulla vetrina compaiono le carte del
  Narratore che il mondo ha calato.
- **`Protocol.audit_table`**: la perquisizione della vetrina, col metro del
  tavolo invece che di un seggio. Gira nella sonda dei messaggi accanto alle
  console.
- Due test: la mano del Narratore non sta sul tavolo, e la guardia **morde**
  (uno pianta una fuga apposta).

### Fixed

- **La vetrina svelava le mani del Narratore.** `echo_deck.drawn` e' tutto
  cio' che il mazzo ha lasciato, comprese le carte ancora in mano ai seggi, e
  la vetrina lo mostrava come «il mondo ha calato». Presente da 0.1.99;
  adesso calata e' una carta uscita dal mazzo e non piu' in nessuna mano.

### Changed

- La mano nel modello della console porta l'`id` (serve per chiedere la
  faccia), e la perquisizione confronta gli **id** invece dei titoli: l'id e'
  la carta, il titolo e' come la chiamiamo.

### Measured

- Sonda dei messaggi: **20.844 perquisiti** (17.509 console + 3.335 vetrine),
  **FUGHE 0**.
- Filo **trasparente byte per byte**; playtest **FAIL 185 · SUCC 76 · SUCC
  123 · DECI 178**, tavolo misto **0 su 8**; suite **296 test / 6121
  asserzioni** verde; sims ed export deterministici.

### Notes

- La prima stesura di `audit_table` cercava anche i titoli nel testo e ha
  consegnato **54 fughe tutte false** («la vetrina nomina "Sale", che e' in
  mano a Kessa» — «Sale» e' una carta *e* una casa). E' la lezione di D-135,
  imparata due volte: il metro giusto e' strutturale.

---

## [0.1.105] — Guardare il telefono

I due difetti trovati fotografando la console su uno schermo da telefono
([D-143](docs/DECISIONS.md#d-143)).

### Added

- **`cli/run_room.gd`**, la stanza senza schermo: stesso `ConsoleHost` e
  stesso `SeatDecider` della stanza vera, stampa un indirizzo per seggio e
  aspetta i telefoni. Serve a provare la console da un altro apparecchio
  senza aprire una finestra — e a fotografarla con un browser vero.
- Gli screenshot in `docs/img/`.

### Fixed

- **Il pannello a caratteri non va piu' al telefono**: la console riceve gia'
  lo `state` strutturato e ne disegna sezioni vere, quindi il tabellone del
  terminale era la stessa cosa detta due volte, in cima allo schermo piu'
  piccolo. Un io che dichiara `shows_state()` non lo riceve; terminale e
  schermo del tavolo tacciono e continuano a leggerlo. **3.600 messaggi in
  meno su 100 partite.**
- **Le scelte oltre il bordo si vedono**: `overscroll-behavior: contain`
  perche' il dito non scorra la pagina sotto, due ombre in CSS puro che
  compaiono solo quando c'e' altro, e il conto scritto («22 scelte — scorri
  per vederle tutte»).

### Changed

- La sonda dei messaggi dichiara `shows_state()` come la console vera:
  contava messaggi che non partono piu'.

### Measured

- Sonda dei messaggi: **17.509 messaggi, FUGHE 0** (erano 21.109 col
  pannello a caratteri).
- Filo ancora **trasparente byte per byte**; playtest **FAIL 185 · SUCC 76 ·
  SUCC 123 · DECI 178**, tavolo misto **0 su 8**; suite 294/6117 verde.

### Notes

- Ventidue opzioni per un'azione sono tante su qualunque schermo, ma quella e'
  una domanda di design del gioco e si decide al tavolo.

---

## [0.1.104] — L'app da scaricare

L'app vera per chi ospita il tavolo ([D-141](docs/DECISIONS.md#d-141)),
chiesta dal committente.

### Added

- **Preset di export macOS** (universale Intel + Apple Silicon) e il lavoro
  **`desktop`** in CI: `ECHOES.zip` allegato a ogni run, scaricabile da
  Actions senza avere Godot installato.
- **`include_filter="web/*"`**: `console.html` e `tavolo.html` non sono
  risorse che Godot importa, quindi `all_resources` non le vedeva. Senza
  questa riga l'app si costruiva, si apriva, apriva la stanza — e serviva una
  pagina vuota ai telefoni.
- **La CI non si fida del preset**: apre il pacchetto, trova il `.pck` e
  cerca dentro i nomi delle due pagine. Rossa prima della serata, non durante.
- Le istruzioni per aprirla su macOS in [SEDUTA_TAVOLO.md](docs/SEDUTA_TAVOLO.md)
  §9bis, col comando che funziona sempre (`xattr -dr com.apple.quarantine`):
  l'app non e' firmata, e il costo si dichiara.

### Changed

- **`textures/vram_compression/import_etc2_astc` acceso**: Godot rifiuta di
  esportare un binario universale o arm64 senza — su Apple Silicon la GPU
  vuole ASTC. L'export web non cambia (le sue compressioni VRAM restano
  spente).

### Notes

- Windows e Linux non sono fatti: un preset per uno, quando serviranno.

---

## [0.1.103] — Il bottone che viveva dietro un `return`

Il difetto trovato dal committente ([D-140](docs/DECISIONS.md#d-140)): la
stanza non aveva piu' il bottone «Si comincia».

### Fixed

- **«Si comincia» torna nella stanza**: in 0.1.100, estraendo `_qr_for`, il
  blocco del bottone era finito dopo il `return` della funzione nuova —
  codice legale, mai eseguito, e nessun avviso da GDScript. Senza quel
  bottone la stanza si apriva e non si poteva cominciare.

### Added

- **`tools/dead_code.py`**, nella CI accanto ai validatori: legge tutti i
  `.gd` e segnala ogni istruzione che segue un `return`/`continue`/`break`
  allo stesso rientro. Verde su 139 file; rimettendo il file rotto trova la
  riga, unica, con numero e testo.

### Measured

- Suite 294 test / 6117 asserzioni verde; playtest **FAIL 185 · SUCC 76 ·
  SUCC 123 · DECI 178**, tavolo misto **0 su 8** (invariato: il difetto era
  nella lobby, non nel motore); 22 documenti validi.

---

## [0.1.102] — Il peso dell'alleanza

Le alleanze pesano al Consiglio ([D-139](docs/DECISIONS.md#d-139)), chieste
dal committente.

### Added

- **`confluence_rules.alliance_weight`** nelle quattro Chronicle: un seggio
  legato al proponente che lo **sostiene** e che ha **impegnato almeno due
  carte** porta un peso in piu' sul fronte — ALLY +1, BOUND +2, mai oltre 2
  per seggio. Il bonus si firma a verbale: «X parla da alleato (+N)».
- La regola sta nel dato, non nel codice: togliere `alliance_weight` da una
  Chronicle riporta il Consiglio a com'era.

### Measured

- Playtest 100 semi (7000): **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**,
  tavolo misto **0 su 8** seggi bloccati (baseline 185 · 78 · 123 · 176).
- Sonda d'era invariata: CHR_01 955 anni / 20,2 generazioni / 24 nomi,
  CHR_03 1049 / 16,5 / 20.
- Suite 294 test / 6117 asserzioni verde; sims ed export deterministici;
  22 documenti validi contro `/schema`.

### Notes

- Due forme scritte e scartate prima di questa, entrambe con **un seggio
  bloccato su un livello solo**: la simmetrica (il nemico frena quanto
  l'alleato spinge — FAIL 210, perche' il tavolo di partenza ha ostilita' e
  non ha alleanze) e quella gratis (FAIL 187). Il verbale le registra.

---

## [0.1.101] — Pedine e vessilli

I pezzi al posto dei cerchietti ([D-138](docs/DECISIONS.md#d-138)),
chiesti dal committente.

### Added

- **`pawn` e `banner`** nel set delle icone (dati, non disegno nella
  vista): la mappa dipinge la pedina col profilo della casa, la sua
  ombra e il contorno scuro; il controllo pianta il suo vessillo sul
  bordo della Regione.
- **La stessa sagoma sul cartone**: la fustella mette la pedina dentro
  il tondo da 15 mm e il vessillo dentro l'anello — schermo e cartone
  sono lo stesso pezzo (D-097).

### Fixed

- Il test del foglio contava i `<circle>` per contare i segnalini, e
  dentro un tondo ora c'e' una pedina: i contorni da punzonare si
  dichiarano (`class="pezzo"`) e si contano quelli.

### Measured

- Suite 294 test / 6117 asserzioni verde; export deterministico byte
  per byte; playtest identico (0/8).

---

## [0.1.100] — Il QR della stanza

L'ultima promessa aperta della fase 3 ([D-137](docs/DECISIONS.md#d-137)):
il codice si inquadra invece di digitarlo.

### Added

- **Encoder QR** scritto a mano (modo byte, correzione M, versioni 1-4) e
  il riquadro che lo disegna: un codice per ogni seggio (indirizzo +
  token) e uno per la vetrina, rigenerati quando si rigenera un codice.
- **L'oracolo**: `tools/gen_qr_fixture.py` congela le matrici attese di
  un'implementazione indipendente; il test le confronta modulo per
  modulo, per tutte e otto le maschere.

### Fixed

- Tre difetti che nessuno sguardo avrebbe visto, trovati dal confronto:
  le due copie dei bit di formato scambiate, il polinomio generatore
  della correzione d'errore con le potenze invertite, e il riempimento
  indicizzato sulla posizione invece che sul conteggio — quest'ultimo
  tornava per caso in versione 1 e sbagliava in versione 3.

### Measured

- 40 matrici su 40 identiche all'oracolo (100 asserzioni); suite 294
  test / 6064 asserzioni verde; playtest identico (0/8); filo ancora
  trasparente byte per byte.

---

## [0.1.99] — Il telefono vero e la stanza

La fase 3 della voce 27 ([D-136](docs/DECISIONS.md#d-136)): le pagine,
il feed della vetrina, la stanza — pronti per la prova computer +
iPad + telefoni (istruzioni in SEDUTA_TAVOLO §9).

### Added

- **`web/console.html`**: il telefono — pannello, mano, Destino,
  la domanda coi bottoni, rientro col token e riconnessione.
- **`web/tavolo.html`**: la vetrina per l'iPad (`/tavolo`), senza
  token (il tavolo è pubblico per costruzione), aggiornata a ogni
  cambiamento del mondo; il tocco sulla Regione apre i segni.
- **La stanza** (`room_screen.tscn`, dal menu): indirizzi per seggio,
  «Rigenera il codice», e al via chi è collegato gioca dal telefono;
  la striscia di diagnosi dice chi «non risponde da Ns».

### Measured

- Sonda del filo estesa: vetrina 43 aggiornamenti, pagine servite,
  partita identica byte per byte. Suite e playtest intatti.

---

## [0.1.98] — Il filo in casa

La fase 2 della voce 27 ([D-135](docs/DECISIONS.md#d-135)): il
trasporto, costruito perché non possa mentire.

### Added

- **L'instradamento per seggio** nel SeatDecider (`ios`): l'avviso del
  Destino finisce sul telefono giusto e su nessun altro.
- **Il protocollo** `state/say/choose/chosen` con la perquisizione
  incorporata — strutturale sulle mani (le carte hanno copie: il
  segreto è *quali copie tieni*, non il titolo), text-scan sui gradini
  del Destino altrui.
- **`ConsoleIO`** (l'io remoto a segnali) e **`ConsoleHost`**
  (WebSocket, token, posta, rientro con domanda riproposta).

### Fixed

- La formula del copione non può più «ripensarci per sempre» (parità
  costante sul passo due → hash a bit alti); la sonda stampa il
  progresso partita per partita.

### Measured

- **Sonda del filo**: partita con due console WebSocket vere identica
  byte per byte (249 messaggi, 82 risposte). **Sonda dei messaggi**:
  100 partite, **21.109 messaggi perquisiti, FUGHE: 0**. Suite
  290/5953 verde, playtest identico.

---

## [0.1.97] — Le due viste dallo stesso mondo

La fase 1 della voce 27 ([D-134](docs/DECISIONS.md#d-134)), senza un
centimetro di rete: la vetrina e la console come ricomposizioni, e i
modelli di vista che in fase 2 saranno i messaggi.

### Added

- **`TableModel` / `ConsoleModel`**: il tavolo col viewer pubblico
  (velate a −1, niente mani né Destini), la console con tutto e solo
  ciò che il suo seggio ha diritto di leggere. Il filtro sta nella
  costruzione, non nel trasporto.
- **`table_view`** (vetrina + ispezione: il click su una Regione apre
  il dettaglio pubblico) e **`console_view`** (`render` + `say`, la
  metà passiva dell'`io` di D-038).
- **`dev_split.tscn`**: le due viste affiancate su una Chronicle
  giocata in automatico.
- **La sonda delle viste** (`test_views`): dorso al tavolo e numero a
  chi ha sbirciato; il modello del tavolo perquisito senza segreti; la
  console senza segreti altrui; sola lettura; le viste si disegnano.

### Measured

- Playtest identico byte per byte (0/8); lente della UI pulita; suite
  286 test / 5923 asserzioni, verde.

---

## [0.1.96] — La Leggenda della Montagna

Le risposte A e C della seduta ([D-133](docs/DECISIONS.md#d-133)): il
seggio senza corpo — e la voce 19 si chiude.

### Added

- **Il conto delle ere nei segni** (`era_tallies`, D-133): tre ere col
  sigillo intatto e il mondo posa `mountain_forgotten`; il sigillo
  caduto azzera il conto senza lasciare leggende.
- **La Leggenda della Montagna** (`INC_VAERAX_LEGEND`, COLLECTIVE):
  entra su `mountain_forgotten`, sbarrata solo dal fatto vivo del
  Cristallo — che sbiadisce: anche il Ridestato, richiuso e
  dimenticato, torna racconto. `presence: []` (niente pedine, niente
  cacciate), MOVE vietato dichiarato, la voce sui fronti finché il
  mondo dimentica.
- **Il Destino per vita** (`destiny_id`/`destiny_pool`
  sull'incarnazione): `DST_VAERAX_LEGEND`, senza clausole di presenza
  — il Minimo si perde se il sigillo cade.

### Measured

- La Leggenda siede **3/20 saghe** (Ridestato 20 → 18, NONE di Vaerax
  9 → 16: la vita non è un rifugio), banda identica (24 nomi).
  Playtest identico (0/8), sims deterministici, censimento 0/0, suite
  281 test / 5865 asserzioni, verde.

---

## [0.1.95] — La montagna delle città

La risposta B della seduta sulla Leggenda
([D-132](docs/DECISIONS.md#d-132)): il tavolo delle città può ferire
la montagna e svuotare la Valle — le porte d'ingresso di Forni ed
Egemonia si aprono.

### Added

- **La Roccia che Cede** (`CNS_MOUNTAIN_WOUNDED`, sul successo di
  `P_DIG_BELOW`): `scar:open_wound` + `condition:exploited` sulle
  Miniere Antiche.
- **La Valle che si Vuota** (`CNS_VALLEY_DRAINED`, sul fallimento
  della domanda dell'Acqua): `scar:emptied` + `condition:lean` sulla
  Valle Verde.

### Measured

- Sonda delle città: i Forni siedono **5/20 saghe**, l'Egemonia
  **11/20** (Custodi 20 → 15), NONE tutti vivi, banda identica.
  Playtest coi totali identici (0/8), sims deterministici, censimento
  0/0, suite verde.

---

## [0.1.94] — L'Egemonia di Eredan

La terza vita della decisione C, che la chiude
([D-131](docs/DECISIONS.md#d-131)): quando la Valle si svuota e Eredan
resta piena, il coro diventa una voce — e nessuno ama l'egemone.

### Added

- **L'Egemonia di Eredan** (`INC_LIBERE_HEGEMONY`, COLLECTIVE): entra
  col segno qualificato — `scar:emptied@REG_VALLE_VERDE`, sbarrata da
  `scar:emptied@REG_EREDAN`. La forma `tag@REG_ID` (nuova in
  `_sign_anywhere`) chiede il segno su QUELLA Regione: uno sgombero
  qualsiasi non fa un'egemonia.
- **`ACTION_DISCOUNT`** (`TGR_HEGEMONY_WORD`): il CLAIM — rivendicare e
  forzare — senza scartare l'Asset AUTHORITY; lo sconto si nomina a
  verbale («per parola propria»).
- **Il gancio ENTITY sulla coppia** (`TGR_HEGEMONY_UNLOVED`,
  RELATION_CAP ALLY): il tetto morde ogni relazione di cui l'egemone è
  membro, e solo quelle.

### Measured

- Condizionale dichiarata (D-035): la vita entra dai salti d'era di
  CHR_03, fuori dalle sonde correnti — playtest identico
  (185·78·123·176, 0/8), ere in banda, sonda delle scelte invariata;
  i denti inchiodati dai test del telaio. Sims deterministici,
  censimento 0/0, suite 278 test / 5832 asserzioni, verde.

---

## [0.1.93] — La Diaspora di Nahr

La seconda vita della decisione C
([D-130](docs/DECISIONS.md#d-130)): il popolo cacciato due volte in un
anno smette di avere un centro — e non lo si può più chiudere fuori.

### Added

- **La Diaspora di Nahr** (`INC_NAHR_DIASPORA`, COLLECTIVE): entra col
  segno `twice_uprooted`, che `_bar_return` scrive alla seconda cacciata
  vera nello stesso anno (`uprooted` alla prima). I tag d'entità non si
  ereditano: il conto riparte a ogni Chronicle da solo.
- **`passes_eviction`** (`TGR_DIASPORA_ROOTLESS`, GATE PASS): la vita
  che decide altrimenti — la cacciata di D-067 e i BLOCK non la
  tengono; il rientro costa comunque la MOVE del round dopo. Il
  validatore ora conosce il PASS su scope ENTITY/GLOBAL.
- **La sentinella nella sonda delle ere**: vite mutate sedute e NONE
  per seggio attraverso le ere.

### Measured

- La Diaspora siede 2 volte in 20 saghe; il NONE di Nahr resta vivo
  (33 su 200 anni giocati): la leva dell'espulsione morde ancora.
  Playtest identico (185·78·123·176, 0/8); sims deterministici;
  censimento 0/0; suite 275 test, 5817 asserzioni, verde.

---

## [0.1.92] — I Forni Riaccesi

La prima delle tre vite della decisione C
([D-129](docs/DECISIONS.md#d-129)): fra i Fuochi e le Custodi nasce
l'industria — ma solo se la storia ha riaperto la miniera.

### Added

- **I Forni Riaccesi** (`INC_CENERE_FURNACES`, COLLECTIVE): entra
  all'esaurimento della linea se `scar:open_wound` sta sul mondo — e il
  nuovo **`entry_forbidden_tag`** la sbarra se `structure:sealed` chiude
  la miniera (allora siedono le Custodi, come sempre).
- **`ACTION_RIPPLE`**, pezzo nuovo del telaio: un'azione riuscita sfoga
  su una Tensione, a verbale e con gli omen. Il dente della fame:
  ogni FORGE dei Forni scalda `TEN_WATER` (+1, `TGR_FURNACE_HUNGER`).
- **`TGR_FURNACE_ORE`** (DRAW_BIAS composito): Forni al tavolo *e*
  ferita sulla mappa → pescano WEALTH più spesso.

### Fixed

- `scar:dragonfall` (0.1.90) stava in prima fila senza lettore né
  dichiarazione: dichiarato nel censimento (il dente vivo è la morte
  del seggio, letta da ON_DEATH).

### Measured

- Playtest 100 semi identico alla baseline (185·78·123·176, 0/8 al
  tavolo misto); banda delle ere identica (955 / 20,5 / 22); sims ed
  export deterministici; censimento 0/0; suite 272 test, 5799
  asserzioni, verde.

---

## [0.1.91] — I valori per vita sono sapore dichiarato

La decisione D della seduta si chiude sulla strada onesta
([D-128](docs/DECISIONS.md#d-128)): i valori d'azione non hanno un
lettore (la policy di D-021 è una scala senza pareggi) e si dichiarano
**sapore di stampa**, allineati ai denti veri; la D meccanica resta a
verbale per la 0.4. La tabella di D-108 era già buona — corretto il solo
Culto della Misura: il velo è un'arte dello SCHEME (3 → 4, INFLUENCE
4 → 3, somma invariata).

---

## [0.1.90] — La morte di Vaerax, per via di Propp

La decisione B della seduta ([D-127](docs/DECISIONS.md#d-127)): il drago
si può uccidere, e la porta è la carta di Propp.

### Added

- **La caccia** (`P_SLAY_THE_DRAGON`): sulla domanda dura del Risveglio,
  eleggibile solo se una **Rivelazione** è stata compiuta quest'anno —
  e chi cala la Rivelazione prescrive il Consiglio e propone per primo.
- **Il Drago Abbattuto** (`CNS_DRAGON_SLAIN`): il drago si spegne (primo
  `SET_ENTITY_ACTIVE` nei dati), il Risveglio crolla, la montagna porta
  la **caduta del drago** — e il potere del Culto ora legge proprio
  quella cicatrice (segni compositi).
- **Il drago si difende**: il punteggio teme la propria fine (−6). La
  morte non elimina il giocatore: `ON_DEATH`, e chi giocava il drago
  gioca il Culto.

### Misurato

Condizionale dichiarata (mai eleggibile nelle 100 standard, come il
riaprire la miniera): playtest identico byte per byte, ere in banda,
270 test / 5782 asserzioni verdi.

---

## [0.1.89] — I denti veri sui pezzi nuovi

I poteri pieni che aspettavano il telaio ([D-126](docs/DECISIONS.md#d-126)):
la Repubblica della Valle (il consenso frena chi propone, e fa muro
quando si oppone), il Culto della Misura (il dogma vela — l'arte che
nessun altro ha), i Frati del Vetro in forma piena (la regola come
misura, dove la reliquia è custodita — segni compositi), la Lega delle
Sette (la firma leggera: la Condition qualifica con un impegno in meno).

Con questo **le nove vite oltre la fondazione hanno tutte almeno un
dente**. Dichiarati non esprimibili: il «vale doppio» delle Custodi e la
paura piena del Ridestato — pezzi futuri, non forzature.

### Misurato

Suite 267/5773 verde; playtest identico byte per byte (le vite dormono
fuori dalle saghe); ere in banda (955 · 20,5 · 22).

---

## [0.1.88] — I pezzi del telaio per le vite

La decisione E della seduta ([D-125](docs/DECISIONS.md#d-125)): tutti e
cinque i pezzi, col rito di D-116 — il telaio prima dei denti, ogni
gancio provato con regole sintetiche e neutro finché nessuna regola vera
lo usa.

### Added

- **I segni compositi** (`when_also`): una regola può chiedere la vita
  **e** il fatto del mondo insieme; tutti i ganci li capiscono.
- **STANCE_MODIFIER**: il fronte di chi porta il segno vale di più — solo
  se ha impegnato almeno una carta su quel fronte.
- **Il velo** (SCHEME modo VEIL, concesso da `ACTION_GRANT`): chiudere un
  numero al tavolo; chi aveva mandato spie non sa più, chi vela sì.
- **Il passo** (`GATE` PASS): chi porta il segno attraversa i BLOCK delle
  regole; la cacciata di D-067 resta più forte.
- **La soglia della Condition** (`CONDITION_THRESHOLD`): qualificare con
  un impegno in meno, mai sotto 1, una volta per regola.

### Misurato

Cinque test sintetici nuovi; con zero regole vere dei tipi nuovi il
playtest sui 100 semi è identico byte per byte alla 0.1.87, suite verde.

---

## [0.1.87] — La seduta sulle vite: le decisioni, e i primi tre denti

La seduta della voce 19 è a verbale ([D-124](docs/DECISIONS.md#d-124),
[SEDUTA_VITE.md](docs/SEDUTA_VITE.md) §4): i tre denti pronti si
accendono, la morte di Vaerax si scriverà per via di Propp, i valori per
vita sono approvati, tutti e cinque i pezzi del telaio autorizzati, le
quattro vite nuove rispiegate (§5) in attesa di decisione.

### Added

- **Il credito federato**: la Compagnia del Sale pesca WEALTH migliore.
- **La regola come misura**: i Frati del Vetro propongono sulla Reliquia
  con World Factor +1.
- **La veglia arma**: le Custodi della Cenere pescano FORCE migliore.

Tre seconde vite del 0.1.70 tornano in regola («una vita senza dente non
si scrive»); Repubblica e Culto della Misura aspettano, dichiarate, i
pezzi nuovi del telaio.

### Misurato

Disgiunte per costruzione e dormienti fuori dalle saghe: playtest sui
100 semi **identico byte per byte** alla 0.1.85, ere in banda (955 ·
20,5 · 22), 262 test / 5757 asserzioni verdi.

---

## [0.1.86] — L'inventario dell'app: i Diritti, l'eco, i marker, la cronaca

Il committente ha chiesto cosa manca sullo schermo
([D-123](docs/DECISIONS.md#d-123)). Quattro cose, e sono entrate.

### Added

- **«I DIRITTI»** nel pannello del seggio: chi tiene un Claim, col dominio
  in italiano; il proprio in ambra. Prima viveva solo nel verbale.
- **L'eco del cambiamento** sulla mappa: ogni effetto che tocca una
  Regione accende un anello ambra che sfuma in sei secondi — dice *dove*
  guardare, il cosa lo dicono verbale e segnalini. I no-op non accendono
  niente.
- **I marker delle domande**: ogni Tensione pianta il suo glifo sulla
  Regione su cui la sua domanda verte adesso, col numero se il seggio ha
  diritto di leggerlo e «?» se è velata. Colori come nel pannello.
- **La cronaca a metà anno**: appena c'è una Truth scritta il bottone si
  accende e impagina il registro fin qui — le stesse pagine di fine anno.

Solo schermo: nessun file di motore toccato. 262 test / 5757 asserzioni
verdi, tre nuovi (`test_app_inventory`).

---

## [0.1.85] — La cicatrice che morde: la voce 24 si chiude

Le undici cicatrici erano scritte e mai lette; adesso sono il ponte
meccanico fra le ere ([D-122](docs/DECISIONS.md#d-122)). Undici regole
nuove, tutte coi tipi che il telaio ha già — nessun ramo di motore.

### Added

- **I tre pesi del Consiglio**: il ponte rotto pesa sulle Vie, la
  capitale presa non dimentica, il seggio vuoto pesa sulla Carta
  (World Factor −1 finché la cicatrice esiste).
- **Le tre pesche guaste**: la parola rotta guasta i legami, dove la
  gente fu sgomberata le braccia mancano, nella terra abbandonata la
  ricchezza non attecchisce.
- **Le pesche buone e la porta**: la torre di veglia (FORCE), il
  pedaggio e il mercato (WEALTH), e la marca che tiene il passo aperto
  (GATE ALLOW: vi si entra anche senza adiacenza).
- **La ferita che parla**: chi sta dove il Cristallo fu sfruttato pesa
  +1 sull'INFLUENCE del Risveglio.
- **Il pavimento del patto**: `PACT` è un tag di relazione (lo scrive
  l'Insediamento Nahr) e la coppia che firma non scende sotto NEUTRAL.
- La **memoria dichiarata** nella sonda dei segni: per ogni segno senza
  regola, il motivo scritto accanto — o il gemello vivo che morde già,
  o la memoria del mondo che aspetta la voce 9.

### Misurato

Cinque gruppi accesi uno alla volta sugli stessi 100 semi: 184·75·129·177
→ **185·78·123·176 con 0/8 al tavolo misto** a ogni passo. Censimento:
vivi per clausola **34 → 46**, prima fila senza lettore **0**, muti senza
dichiarazione **0**.

---

## [0.1.84] — La sonda della visibilità: la voce 22 si chiude

«Un effetto invisibile è un bug, non un'atmosfera» ([D-121](docs/DECISIONS.md#d-121)).
La sonda nuova conta, e quello che ha trovato è stato curato.

### Added

- `cli/run_visibility_probe.gd`: 100 semi a tavolo misto, ogni effetto del
  registro o ha la sua frase a verbale (parola per parola) o un silenzio
  dichiarato — i senza voce vengono nominati, con la fonte. Oggi: **0**.
- Il **placarsi della questione decisa** (H.1) ha la sua riga — era
  l'effetto centrale di ogni Consiglio, e non lo diceva nessuno.
- La **rivelazione del presagio** parla («… non è più velata») invece di
  posare il numero sul tavolo in silenzio.
- Il CLAIM e l'INFLUENCE via scarto **nominano la carta spesa**.
- **La mappa non nasconde** (fase 2): una Regione segnata appare nella
  riga «Sulla mappa» anche senza presidi né controllore, coi nomi dei
  segni di D-107 («Valle Verde (contesa)»).

### Fixed

- `SET_CONTROL` che non cambia mano e `SET_TENSION_VISIBILITY` su una
  questione già aperta si marcano no-op: nessuna riga annuncia un trono
  che non si è mosso.

---

## [0.1.83] — La mossa che spegne il tuo Destino avverte prima

La voce 21 si chiude ([D-120](docs/DECISIONS.md#d-120)): nella partita al
seme 15308 Vaerax aveva spento da solo la sua prima spunta, spostando
l'ultimo token via dalle Montagne Rosse senza che l'app dicesse nulla.

### Added

- Nel `SeatDecider` (uno per terminale e browser, D-038): se l'azione
  scelta spegnerebbe una clausola **accesa** del **proprio** Destino, una
  riga di avviso che la nomina e la scelta di ripensarci. Un cartello,
  non un consigliere.
- L'anteprima è una sessione ricostruita dal salvataggio (`to_save` →
  `restore`): stesso mondo, stesso dado, previsione esatta, nessun ramo
  di regole duplicato. Si paga solo quando un umano ha già scelto.
- Tre test: la mossa nella forma del 15308 avverte nominando la clausola
  (e il mondo vero resta intatto), il ripensamento torna al menu, una
  mossa che non tocca il Destino passa senza cerimonie.

### Misurato

259 test / 5732 asserzioni verdi; le partite senza umani sono identiche
per costruzione (il ramo non viene mai percorso).

---

## [0.1.82] — Gli effetti che pesano: la voce 23 si chiude

La fase 2 della voce 23 ([D-119](docs/DECISIONS.md#d-119)): le carte di
Propp toccano il tavolo — presenza, controllo, Consigli prescritti, segni
con lettori veri — carta per carta, tutte e due le saghe, un passo alla
volta sugli stessi 100 semi.

### Changed

- **23 carte Echo riscritte** (10 nella prima saga, 13 nella seconda, che
  non aveva un solo hook pesante): presidi che si piantano e si ritirano,
  controllo che decade, sei carte che prescrivono un Consiglio, scoperte,
  fama, il granaio che si svuota, il canale che si chiude, la Valle che ha
  fame coi denti di D-117. Una forma respinta coi numeri: il controllo
  tolto gratis bloccava Aldric (1/8) — il titolo si perde a un Consiglio.
- Il punteggio delle sedie legge le carte **con i binding con cui verranno
  compilate** (chi cala è il proponente) e pesa anche le Conseguenze
  agganciate: prima, un hook su un `$slot` valeva zero per costruzione.

### Fixed

- I **Consigli chiusi entrano nel salvataggio**: vivevano solo in memoria,
  e una Chronicle ripresa li dimenticava — il rapporto di fine anno ne
  contava uno in meno. Trovato dal test di ripresa il giorno in cui una
  carta ha aperto un Consiglio prima del punto di interruzione.

### Misurato

Stessi 100 semi: 190·88·120·176 → **184·75·129·177 con 0/8 al tavolo
misto**, Consigli 5,65 (mediana 6), ere in banda (955 anni, 20,1
generazioni, 22 nomi), sim scritte deterministiche, 256 test verdi.

---

## [0.1.81] — La mano del Narratore sullo schermo

La fetta browser della voce 23: le carte di Propp in mano si **vedono**
nell'app, accanto agli Asset — spente quando la storia non le accetta
ancora, col motivo sotto il cursore. Il bottone per calarle c'era già
gratis: il browser corre lo stesso SeatDecider del terminale (D-038).

### Added

- `HandView` disegna la mano del Narratore: figura della carta, tooltip
  con titolo e testo, e «non calabile: …» quando l'eleggibilità o il
  costo lo vietano.
- Un test che compila e disegna la vista nella suite headless (il debito
  di 0.1.60, pagato per questa vista).

---

## [0.1.80] — Le carte di Propp in mano ai giocatori

La visione della voce 23 diventa motore ([D-118](docs/DECISIONS.md#d-118)),
col disegno scelto dal committente: **2 carte a testa per atto**, si
calano **nel proprio turno** pagando **una carta Asset**, e se nessuno
cala l'atto resta muto — la pesca automatica di fine atto non esiste più.

### Added

- La **mano del Narratore** per ogni seggio (nel mondo e nei salvataggi)
  e l'azione **PLAY_ECHO**: l'ordine di Propp resta custodito
  dall'eleggibilità, giudicata quando si cala.
- Chi cala è il proponente della carta; un Consiglio prescritto si apre
  a fine round come per il CLAIM.
- Le sedie automatiche calano al più una carta per atto, e solo se serve
  al loro Destino; l'umano al terminale vede le carte calabili fra le
  azioni.

### Misurato

Due forme respinte coi numeri (17 carte a cronaca; Kessa piantata e 1/8
bloccato) prima di quella giusta: **190·88·120·176 con 0/8 al tavolo
misto**, ere in banda, 255 test verdi. Restano la GUI del browser e gli
effetti più pesanti, carta per carta.

---

## [0.1.79] — I denti veri, e la 48ª carta

La voce 25 si chiude ([D-117](docs/DECISIONS.md#d-117)): cinque regole
d'autore, una per tipo, tutte su segni che il gioco già produce — e il
Legame di Sangue riceve il suo mestiere: **48 carte su 48 lavorano**.

### Added

- **I patti non si firmano a stomaco vuoto**: in una Regione affamata
  niente alleanze (FORGE vietato finché la fame non si cura).
- **Il debito chiamato guasta il mercato**: col debito del Banco chiamato,
  chi pesca ricchezza prende la peggiore delle prime due carte.
- **La fame mangia le scorte**: presenza in Regione affamata, una carta
  di meno in mano.
- **Chi riapre i canali ha il grano**: il proponente che fa scavare i
  canali riceve la Riserva di Grano.
- **Il sangue non si sceglie**: il Legame di Sangue impegnato scrive il
  vincolo sulla coppia, e quella relazione non scende più sotto il
  neutrale (il tetto del giuramento spezzato vince sul pavimento).

### Misurato

Un dente alla volta, stessi 100 semi (tabella in D-117): il divieto della
fame non morde mai nelle sedie automatiche (aspetta la sua condizione,
come le cure), gli altri quattro spostano poco e in salute. **0/8 al
tavolo misto a ogni passo**; ere in banda; 255 test verdi.

---

## [0.1.78] — I denti che aggiungono e tolgono: il telaio

Fase 1 della voce 25 ([D-116](docs/DECISIONS.md#d-116)): **cinque tipi
nuovi di regola**, costruiti nel motore e provati con regole sintetiche.
Nessuna regola vera è ancora accesa: il gioco è identico, il telaio è
pronto.

### Added

- **ACTION_GATE**: un segno può vietare un'azione («il segno lo vieta»),
  in un punto solo — sedia automatica, browser e motore lo rispettano
  insieme.
- **DRAW_BIAS**: la pesca piegata — col segno addosso si prende la
  peggiore (o la migliore) delle prime due carte del mazzo.
- **HAND_LIMIT**: il limite di mano si muove — l'assedio stringe le mani
  di chi è dentro, mai sotto una carta.
- **GRANT_ON_SET**: un segno appena posato consegna una carta con nome e
  cognome, a chi l'ha causato o a chi lo porta.
- **RELATION_FLOOR**: il pavimento di relazione — sotto non si scende; se
  tetto e pavimento litigano, vince il tetto. È il potere che il Legame
  di Sangue aspettava.

### Misurato

Zero regole accese: playtest 100/7000 **identico byte per byte** alla
base, 0/8 al tavolo misto; 255 test, 5372 asserzioni. Le regole vere si
scelgono col committente e si accendono una alla volta, misurate.

---

## [0.1.77] — Il Destino che legge chi lo giura

La voce 20 si chiude ([D-115](docs/DECISIONS.md#d-115)): ogni casa ha ora
**tre ambizioni nel pool** invece di due, e la terza è una carta
**condivisibile** — scritta una volta con `$self`, letta sul seggio che
la giura.

### Added

- **Tre Destini condivisi**: *Il Nome che Pesa* (la fama e la terra — a
  chi vive di parola: Aldric, Vetro, Libere), *La Terra che Risponde*
  (una, due, tre Regioni — a chi vive di posti: Nahr, Vaerax, Cenere),
  *I Conti Chiusi* (registro pulito, firma che vale, nessun debito nel
  mondo — a chi vive di registri: Lyra, Ilve).
- Il motore risolve `$self` su chi giura (stesso meccanismo di
  `$proponent`); la carta stampata dice «per chi lo giura»; la sonda dei
  Destini misura anche le scale condivise, per ogni seggio che le porta.

### Misurato

La prima forma dei Conti Chiusi era **regalata** — tutta di assenze,
chiusa da sola al round 1 in 100 partite su 100 — ed è stata riscritta
con la fama nella Vittoria: ora si chiude in anticipo 18/100 (Lyra) e
47/100 (Ilve), in famiglia con le carte identitarie. Playtest identico
alla base, **0/8 al tavolo misto**; ere in banda (mediana 955 anni,
19.8 generazioni, 22 nomi); 248 test verdi.

---

## [0.1.76] — Tutte le carte lavorano

Ultimi tre mazzetti e la voce 26 si chiude ([D-114](docs/DECISIONS.md#d-114)):
**46 carte su 48 fanno quello che il nome promette**, e le due che no lo
dichiarano.

### Added

- **WEALTH**: la Riserva sfama, il Sale supera la magra, la Carovana
  ricollega, il Pedaggio si scrive sulla mappa, le Chiavi razionano, il
  Credito chiama il debito (la porta del Banco Nero).
- **KNOWLEDGE**: la Voce di Corridoio vela e la Prova svela, la Mappa
  Vecchia ricuce il ponte rotto, il Registro apre i conti, il Testimone
  agita la sede dell'accusato.
- **PEOPLE**: la Folla inquieta la capitale, gli Anziani elaborano il
  lutto, le Braccia spengono la fame, la Mobilitazione scalda la piazza,
  il Portavoce impegna promesse, la Marcia rompe le razioni.

### Misurato

Una famiglia alla volta (tabella in D-114): il mondo più duro e meno
estremo — più fallimenti, meno Decisive — con distribuzioni sane, **0/8
a ogni passo**, ere in banda, guardia biblioteca verde; i piani B e C
aggiornano le attese. 246 test, 5324 asserzioni.

---

## [0.1.75] — I legami imparano il mestiere

Terzo mazzetto della voce 26 ([D-113](docs/DECISIONS.md#d-113)): la
famiglia delle cure.

### Added

- **I mestieri**: il Giuramento rifatto scioglie quello spezzato (la
  cura del tetto di D-105), il Favore spegne la vendetta, il Diritto di
  Ospitalità riapre la porta sbarrata per chi lo impegna, la Promessa di
  Nozze scrive un PACT che il giudizio delle promesse legge, il Debito
  Vecchio segna la sede del debitore. Il Legame di Sangue resta
  dichiarato per la voce 25: il suo potere vero è un pavimento di
  relazione.
- **L'applier**: una relazione con se stessi è un no-op, non un errore.

### Fixed

- **Promessa di Nozze**: il testo diceva «+1», il modificatore è sempre
  stato 2 — terza etichetta bugiarda allineata.

### Misurato

Base identica a D-112 e tutti i passi fermi: i legami sono cure e stati,
mordono quando le condizioni esistono — al tavolo umano, non nei numeri
medi delle sedie automatiche. 0/8 a ogni passo, ere in banda. 246 test,
5190 asserzioni.

---

## [0.1.74] — I sigilli imparano il mestiere

Secondo mazzetto della voce 26 ([D-112](docs/DECISIONS.md#d-112)): le
sei carte AUTHORITY che erano solo un numero ora lavorano — e il
mazzetto disegna cure e contro-cure.

### Added

- **I mestieri**: l'Editto calma la piazza (via l'inquietudine dei
  Mercenari), il Sigillo raffredda la questione (−1, l'opposto della
  Banda Armata), il Censimento chiarisce la contesa che il Diritto di
  Corona posa, il Magistrato cancella la domanda rimasta sul muro,
  l'Investitura scrive l'erede nominato — lo stesso segno che apre la
  porta della Corona Restaurata.
- **Il verbale parla col dizionario**: i segni negli effetti narrati
  usano le parole di D-107 («contesa», non «condition:contested»).

### Fixed

- **Magistrato**: il testo diceva «+1 sul fronte Oppose», il
  modificatore è sempre stato 2 — allineato (stessa svista
  dell'Assedio).

### Misurato

Un mestiere alla volta sugli stessi 100 semi (tabella in D-112): il
Sigillo ammorbidisce (due Decisive in meno), il resto è quieto nei sim;
0/8 a ogni passo, ere in banda, guardia biblioteca verde. Il piano B
aggiorna le attese (il Sigillo sposta i tempi dei Consigli). 246 test,
5178 asserzioni.

---

## [0.1.73] — Il tarocco per ogni vita

Fase 3 della voce 19, l'ultima ([D-111](docs/DECISIONS.md#d-111)).

### Added

- **Una carta per ogni vita**: il mazzo Casata porta un tarocco per
  ciascuna delle 11 vite oltre le prime — nome, descrizione e valori
  della vita, il seggio nel sottotitolo. I fogli di stampa e la cache
  dell'app crescono da soli.
- **Il tarocco segue la vita**: quando il seggio si trasforma, il
  pannello del seggio posa la carta della vita corrente.
- **Il brief d'arte con gli 11 prompt delle vite** (l'archetipo viene
  dal seggio) e il materiale di revisione a **745 testi** (le vite e
  tutti gli eredi, compresi i re restaurati).

### Misurato

Nessun cambio di regole: 246 test, 5175 asserzioni, verdi; parità del
brief in CI.

---

## [0.1.72] — L'albero si riempie

Sei vite dai rami di [TRASFORMAZIONI.md](docs/TRASFORMAZIONI.md)
([D-110](docs/DECISIONS.md#d-110)), ognuna con ingresso e potere.

### Added

- **Tavola I**: la Reggenza del Granaio (se il grano fu requisito), la
  Corona Restaurata (il cerchio: dalla Repubblica si torna re, con
  quattro eredi nuovi da consumare), Vaerax Ridestato (se il Cristallo
  fu cavato).
- **Tavola III**: il Banco Nero (se il debito fu chiamato),
  l'Inquisizione del Vetro (se la Reliquia fu mostrata), la Lega delle
  Sette (se la Carta fu firmata).
- Ogni vita col suo potere al tavolo (World Factor +1 sulla sua
  materia) e il suo prompt d'arte in attesa dei tarocchi per vita.

### Fixed

- **La dinastia non si interrompe a metà**: l'ingresso a evento vale
  solo per chi non muore; per i mortali il segno sceglie la vita quando
  la linea si esaurisce.

### Misurato

Playtest identico, 0/8; guardia biblioteca verde; ere: 20,2 gen/22 nomi
(tavola I), 16,0/18 (tavola III), anni in banda. 245 test, 5115
asserzioni.

---

## [0.1.71] — La storia sceglie la vita

Gli ingressi dell'albero ([D-109](docs/DECISIONS.md#d-109), verso
[TRASFORMAZIONI.md](docs/TRASFORMAZIONI.md)).

### Added

- **Tre porte per le vite**: `ON_TAG` (entra la vita il cui segno sta
  sul mondo, sulla casa o su una Regione — anche senza linea esaurita),
  `ON_DEATH` (il seggio morto rivive nella vita che lo aspetta), e le
  vite alternative: fra più candidate vince la prima, in ordine
  d'autore, il cui ingresso è vero. Il verbale distingue le tre porte.
- **Il segno `life:<id>`** posato sulla casa a ogni vita oltre la prima:
  le tag_rules lo leggono con lo scope che già esiste — i poteri per
  vita senza ganci nuovi.
- **Tre vite di dimostrazione**: l'Accademia delle Misure (Lyra, se la
  legge scritta sta sul mondo — altrimenti il Culto), il Regno di Nahr
  (il popolo insediato torna MORTAL, quattro re scritti), il Culto della
  Montagna (alla morte del drago). Ognuna col suo potere al tavolo.

### Misurato

Motore con dati vecchi: invariato al byte. Con le vite: playtest
identico e 0/8; sonda delle ere 16,4 generazioni e 16 nomi distinti per
saga (il Regno consuma i suoi re), anni e guardie in banda. Prima forma
del potere del Regno respinta coi numeri (scaldava la Carestia: mediana
7 contro banda 3–6 in biblioteca) e riscritta. 243 test, 5110 asserzioni.

---

## [0.1.70] — Il seggio cambia vita

Fase 2 della voce 19 ([D-108](docs/DECISIONS.md#d-108)), generalizzata
dal committente: ogni seggio può mutare, non solo Anselmo.

### Added

- **La traversata**: quando la linea dei successori scritti si esaurisce,
  entra la vita successiva del seggio — nome, natura, valori e successori
  propri — e il verbale d'apertura lo racconta. Una vita COLLECTIVE
  smette di consumare eredi: la repubblica non muore di vecchiaia.
- **Cinque seconde vite d'autore**: la Repubblica della Valle (da Re
  Aldric), il Culto della Misura (da Lyra), la Compagnia del Sale (da
  Maestra Ilve), i Frati del Vetro (da Priore Anselmo), le Custodi della
  Cenere (da Kessa dei Fuochi).
- Lo stato del seggio porta `incarnation` (save e schema).

### Misurato

Playtest standard identico, 0/8; sonda delle ere: 10 generazioni e 10
nomi distinti per saga (gli eredi scritti più la vita nuova, poi il
seggio smette di morire), anni in banda. 239 test in 33 suite, 5097
asserzioni.

---

## [0.1.69] — I segni hanno un corpo

Fase 3 della voce 22 ([D-107](docs/DECISIONS.md#d-107)): un segno che
morde si deve vedere — sulla mappa, sul seggio e sul tavolo di cartone.

### Added

- **Il dizionario dei segni** (`sign_labels.gd`): ogni tag ha la sua
  parola italiana, una sola per app e fustella; un test la pretende per
  ogni segno che i dati sanno scrivere.
- **La mappa parla italiano**: «tagliata fuori» al posto di «cut_off».
- **«I SEGNI DELLA CASA»** nel pannello del seggio: fama, scoperte,
  scorta giurata, la porta sbarrata in rosso.
- **Due pagine di fustella nuove**: i segni delle Regioni (condizioni
  ×2 tratteggiate, strutture, insediamenti, Cicatrici in rosso) e i
  segni delle case (più «cacciata» ×4 e «giuramento spezzato» ×2), in
  export e PDF.

### Fixed

- **L'app non compilava dall'0.1.60**: `confluence_board.gd` chiamava
  `_draw(session, council)` una funzione che Godot riserva al disegno —
  rinominata `_paint_council`, avvio pulito. La suite headless non
  carica le scene: a verbale il debito di un controllo in CI.

### Misurato

234 test in 32 suite (3 nuovi), 5066 asserzioni; nessun cambio di
regole.

---

## [0.1.68] — Le armi imparano il mestiere

Primo mazzetto della voce 26 ([D-106](docs/DECISIONS.md#d-106)): le
cinque carte FORCE che erano solo un numero ora fanno quello che il nome
promette.

### Added

- **I mestieri**: Leva Contadina e Assedio affamano (+1 Carestia), la
  Guardia di Confine chiude le vie (+1 Vie Interrotte), il Posto di
  Blocco taglia fuori la Regione della domanda (`condition:cut_off`,
  curabile), i Mercenari lasciano l'inquietudine (`condition:unrest`).
- **La carta parla**: quando una carta impegnata muove il mondo, il
  verbale lo dice col suo nome — «H. La carta parla - Leva Contadina
  (Popolo Nahr): La Carestia sale di 1.»

### Fixed

- **Assedio**: il testo diceva «+1 sul fronte Oppose», il modificatore è
  sempre stato 2 — testo allineato al +2 reale.

### Misurato

Un mestiere alla volta sugli stessi 100 semi (tabella in D-106): sei
Decisive in meno a regime, i Nahr respirano, 0/8 seggi bloccati a ogni
passo. Suite 231 test / 5012 asserzioni verde; brief, manifest e
revisione rigenerati.

---

## [0.1.67] — I primi cinque denti

Fase 3 della voce 24 ([D-105](docs/DECISIONS.md#d-105)): «accendi tutte».

### Added

- **Cinque tag_rules vere** in `godot/data/tag_rules/tag_rules_core.json`:
  il granaio parla (INFLUENCE +1 sulla Carestia dalla sua Regione), la
  fame siede al tavolo (World Factor −1 sui Consigli della Carestia), la
  strada depredata (porta sbarrata finché Le Vie Riaperte non la
  riaprono), il giuramento spezzato (il Patto Rotto firma la coppia, e
  fra le due case non si sale sopra HOSTILE), la fama precede (World
  Factor +1 per il proponente `renowned`).
- **Il Consiglio legge il mondo**: `council_world_factor` conosce il
  proponente e tre scope — il mondo, chi propone, una Regione qualsiasi
  col segno.

### Misurato

Accese in fila sui 100 semi standard, esiti a verbale in D-105: il
granaio toglie due fallimenti, la fame smorza un Decisive, la fama
sposta quattro Consigli; strada e giuramento mordono su movimento e
relazioni, fuori dagli esiti dei sim. **0/8 seggi bloccati a ogni
passo.** 231 test verdi; ISSUES 25 e 26 aperte (i denti che aggiungono
e tolgono; le carte con un mestiere — 35 su 48 sono solo un numero).

---

## [0.1.66] — Il telaio dei denti

Fase 2 della voce 24 ([D-104](docs/DECISIONS.md#d-104)): il posto dove i
segni potranno mordere, costruito vuoto e misurato invariato.

### Added

- **Schema `tag_rule`**: un segno (su mondo, Regione, Entità o
  relazione) legato a un gancio del motore — ACTION_MODIFIER (INFLUENCE
  si allarga), COUNCIL_MODIFIER (il World Factor si piega), GATE (la
  porta sbarrata o concessa), RELATION_CAP (il tetto alla relazione).
  Con `chronicle_id` la regola resta a casa sua; `active` obbligatorio.
- **I quattro ganci nel motore** (`tag_rules.gd` + resolver, Consiglio,
  movimento, applier): con zero regole ogni gancio restituisce il suo
  neutro; quando una regola morde su azione o Consiglio si firma a
  verbale («Il segno pesa: …»).

### Misurato

231 test in 31 suite (8 nuovi: ogni gancio provato con una regola
sintetica accesa e spenta), 4974 asserzioni; playtest standard
invariato, 0/8 seggi bloccati al tavolo misto.

---

## [0.1.65] — La sonda dei segni, e la voce 24 a verbale

«Ogni conseguenza, ogni cicatrice, ogni decisione potrebbe cambiare il
meccanismo di gioco»: prima di dare denti, il censimento di quanti ne
mancano.

### Added

- **`tools/tag_census.py`**: chi scrive un segno e chi lo legge. Primo
  censimento: 79 segni scritti — 27 vivi per clausola, 5 vivi per motore
  (`discovery:`), 2 con vita postuma (`legend:`), 27 ereditati fra le ere
  ma senza dente in partita, **18 muti del tutto** (fra cui `renowned`,
  `heir_named`, `grain_requisitioned`).
- **ISSUES voce 24**: il telaio `tag_rules` — un dato dichiarativo che
  lega un segno a un gancio del motore (modificatore d'azione in Regione,
  modificatore al Consiglio, porta, relazione) — e le fasi per accendere
  i denti d'autore uno alla volta, misurati.

---

## [0.1.64] — Il verbale impara a raccontare

Fase 1 della voce 22 ([D-103](docs/DECISIONS.md#d-103)): le decisioni si
devono vedere, a cominciare da quello che resta scritto.

### Added

- **Il narratore degli effetti** (`effect_narrator.gd`): una frase con i
  nomi del tavolo per ogni effetto applicato — «Valle Verde passa sotto
  il controllo di Re Aldric», «Il Risveglio non è più velata». Parla per
  le Conseguenze di un Consiglio (ora aperte dal titolo, non dagli id),
  per la clausola qualificata e per la carta Echo d'atto, prima muta.
  Tace sui no-op, sulla contabilità di Propp e su ciò che ha già una voce
  (Scar, Echo, Truth).

### Changed

- Gli `applied` della carta Echo d'atto sono gli Effect registrati, non i
  compilati: il segnale `act_echo_drawn` porta l'effetto com'è nel log.

### Misurato

223 test in 30 suite (7 nuovi), 4955 asserzioni; playtest standard
invariato, 0/8 seggi bloccati al tavolo misto.

---

## [0.1.63] — Le vite del seggio hanno una forma

Fase 1 della voce 19 ([D-102](docs/DECISIONS.md#d-102)): le incarnazioni.

### Added

- **Schema `incarnations`** sull'Entità: le vite del seggio lungo la saga
  — prima la persona, poi quello che nasce da lei — ognuna con nome,
  natura, valori d'azione, prompt d'arte, successori propri e regola
  d'ingresso (`FOUNDING`/`LINE_EXHAUSTED`). Le forme condivise
  (`action_values`, `successors`, `name_grammar`, `persistence`) salgono
  in `$defs`.
- **Gli 8 seggi migrati**: la prima incarnazione (`INC_<SEGGIO>_01`)
  assorbe i campi attuali. Il motore non le legge ancora: una guardia in
  `validate_data.py` impone lo specchio esatto finché la Fase 2 non
  sposta il lettore.

### Misurato

Suite verde prima e dopo (216/4557); playtest standard invariato, 0/8
seggi bloccati al tavolo misto. Nessun comportamento cambiato.

---

## [0.1.62] — Quello che una partita vera ha insegnato

La prima cronaca giocata dal committente (seme 15308) letta riga per riga:
nessun difetto di regole, ma il log parla — e quello che dice è a verbale.

### Fixed

- **Gli accenti del motore**: le stringhe scritte nei `.gd` erano rimaste
  fuori dalla revisione dei dati ([D-099](docs/DECISIONS.md#d-099)) — «Truth
  è ora immutabile», «la domanda caduta è stata ripresa», «COM'È FINITA»,
  «REGISTRO DELLE VERITÀ».
- **Gli accenti dei dati, ultime sacche**: le parole senza ambiguità
  (purché, più, già, città, può, così…) applicate a *tutti* i valori
  stringa dei JSON — cadono «...purche $rival» nelle clausole, «Diritto di
  Ospitalita» e «Puo dirlo dopo» sulla carta, «I Senza Citta» fra i titoli,
  e i segni delle Tensioni. Rigenerati brief d'arte, manifest e materiale
  di revisione.

### Added

- **ISSUES voce 21**: la mossa che spegne una spunta del proprio Destino
  deve avvertire prima — nella partita vera Vaerax ha chiuso a NONE
  spegnendo da solo «La montagna è ancora sua» all'ultimo round, senza un
  cartello.

### Misurato

216 test in 29 suite, 4557 asserzioni; 20 documenti validi contro gli schemi.

---

## [0.1.61] — I tarocchi dietro il paravento

Terza e ultima fetta dichiarata di [D-101](docs/DECISIONS.md#d-101).

### Added

- **La Casata e il Destino come carte**: nella colonna del seggio, sopra
  la scala del Destino, i due tarocchi 70×120 dei fogli di stampa — e il
  Destino lo vede solo chi lo giura, come al tavolo. Alla rotazione di
  un'era la carta cambia da sola: la texture segue `destiny_of`.

### Misurato

216 test in 29 suite, 4557 asserzioni; UI compilata headless.

---

## [0.1.60] — La carta si posa al centro del tavolo

Seconda fetta di [D-101](docs/DECISIONS.md#d-101).

### Added

- **Il Consiglio si apre posando la carta**: il tabellone mostra la
  carta mini della domanda a sinistra di intestazione e mozione — come
  al tavolo fisico, dove si prende dalla traccia e si mette in mezzo.
- **I tondi di presenza portano l'iniziale della casa**, come i
  segnalini della fustella (D-097): il pezzo sullo schermo è il pezzo
  che si punzona.

### Misurato

216 test in 29 suite, 4557 asserzioni; UI compilata headless.

---

## [0.1.59] — La GUI mostra le carte fisiche

Prima fetta della direzione del committente
([D-101](docs/DECISIONS.md#d-101)): lo schermo mostra i componenti
fisici, non una loro parafrasi.

### Added

- **`PrintSheet.card_svg`** (una carta sola, stessa faccia della stampa,
  senza segni di taglio) e **`ui/card_art.gd`** (rasterizza una volta
  per mazzo, cache). Un solo impaginatore, tre superfici: foglio,
  anteprima, partita.
- **La mano è fatta di carte stampate**: la faccia vera 63×88, col bordo
  di rilevanza e il «vale N» del resolver come sole aggiunte a schermo;
  tooltip invariato per leggere a carta piccola.
- **Il mondo cala una carta**: la vista Echo di fine atto mostra la
  carta stampata accanto al verbale di cosa ha fatto.

Fette dichiarate: la carta mini della domanda al centro del Consiglio,
i token della fustella sulla mappa, i tarocchi identità nella vista del
seggio.

### Misurato

216 test in 29 suite, 4557 asserzioni; UI compilata headless.

---

## [0.1.58] — La voce del Consiglio: le mozioni al congiuntivo

Seconda lettura della voce 13, su segnalazione del committente
([D-100](docs/DECISIONS.md#d-100)).

### Changed

- **Le proposte dei Consigli parlano da mozioni**: congiuntivo
  esortativo, registro alto («Si levino i banchi e si portino dove le
  mura sanno difenderli», «Il grano sia requisito in nome del trono») —
  34 riscritture sulle due saghe; gli esiti restano cronaca, con le due
  segnalazioni riscritte per immagine.
- Altre 22 code di passato remoto senza accento chiuse rileggendo.

### Misurato

215 test in 29 suite, 4518 asserzioni; simulazioni, export, brief,
manifesto e tavolo di lettura riallineati.

---

## [0.1.57] — La revisione dei testi: gli accenti tornano, le regole escono dal racconto

Chiude ISSUES voce 13 su delega del committente
([D-099](docs/DECISIONS.md#d-099)): prima lettura di fila dei 661 testi.

### Fixed

- **Gli accenti restaurati ovunque**: 357 righe corrette su 17 file
  («piu»→«più», «la cosa e seria»→«è seria», «il consiglio lascio
  cadere»→«lasciò cadere»…). Ogni «e» nuda classificata a occhio su due
  censimenti completi: le congiunzioni restano congiunzioni.
- **Le regole fuori dal racconto**: la velatura ora la dichiara la carta
  dal dato `visibility` («domanda velata · survival»), e le descrizioni
  del Risveglio e delle Vie Interrotte sono tornate narrativa.

### Misurato

Suite intatta (215 test, 4518 asserzioni), validazione, simulazioni,
export, manifesto e tavolo di lettura rigenerati.

---

## [0.1.56] — Il tavolo di lettura per la revisione dei testi

Il materiale della voce 13, su richiesta del committente.

### Added

- **`tools/build_review.py`** → [docs/REVISIONE_TESTI.md](docs/REVISIONE_TESTI.md):
  i 661 testi d'autore in ordine di lettura — aperture, Regioni, Casate,
  Domande coi presagi, Consigli con proposte ed esiti raccontati,
  Conseguenze e cicatrici, carte Echo, carte Asset, Destini gradino per
  gradino, Azioni — ognuno col suo identificativo, così una correzione si
  segna con una riga e si riporta nei dati senza cercare. Generato e
  deterministico, come il manifest: non si corregge lì, si rigenera.

---

## [0.1.55] — La seconda leva: la proposta bocciata non compra quiete

Chiude la milestone 0.2 ([D-098](docs/DECISIONS.md#d-098)): era l'ultima
voce.

### Changed

- **`confluence_rules.failure_delta` = −1** in tutte le Chronicle (era
  −2, appendice A6): una proposta affondata non sfoga più la domanda —
  resta vicina alla soglia e torna prima. In armonia con D-077 e D-094:
  dire di no non chiude niente. Il gradino 0 è respinto coi numeri; la
  manopola `--failure-delta` resta nel playtest per rimisurare.
- Le attese del piano scriptato «il consiglio spezzato» aggiornate: la
  questione bocciata due volte torna ai voti una quarta, che passa.

### Misurato (stessi 100 semi)

Divario aggressivo−prudente 28→26 (storia: 37→31→28→26); i NONE del
bloccante da 2 a 6 — bloccare può costarti l'anno; i Consigli recuperati
vanno al centro del tavolo (distratto 46→53). Mediana Consigli 6, 0/8
bloccati al tavolo misto, saghe stabili. Scoperto per strada che la
prima leva (ISSUES 1) era già nei dati. 215 test in 29 suite, 4518
asserzioni.

---

## [0.1.54] — Il formato fisico: tre taglie di carta, token e segnalini

Chiude ISSUES voce 7 con le decisioni del committente, implementate
nell'export ([D-097](docs/DECISIONS.md#d-097)).

### Added

- **Tre taglie di carta per ruolo**: classiche 63×88 (Asset, Echo),
  tarocchi 70×120 (Destini, Casate), mini 44×68 (Domande); le tessere
  Regione 80×80 restano — la mappa è un tabellone unico, già fatto.
  `print_sheet` ha la tabella dei formati; impaginazione, segni di
  taglio e anteprima F4 seguono da sé.
- **`token_sheet.gd`**: la fustella dei segnalini (15 mm, una per saga —
  sei presenze e sei controlli per casa, i rombi del valore, il quadrato
  del Drift) e la **traccia dei valori** (quattro corsie 0–8; la soglia
  sta sulla carta). In coda al PDF: ora 32 pagine.
- COMPONENTS §7 riscritta da lista di domande a decisione.

### Misurato

La guardia «il testo ci sta» passa su tutte le taglie (719 asserzioni di
stampa); 215 test in 29 suite, 4513 asserzioni; export e PDF
deterministici.

---

## [0.1.53] — Il libro della saga: la Timeline in apertura, poi i capitoli

Con D-095 completa la parte in-app della 1.0 dichiarata
([D-096](docs/DECISIONS.md#d-096)).

### Added

- **`ChronicleBook.saga_pages`**: la Timeline dei secoli in apertura —
  un anno per voce, col salto, chi sedeva e com'è finita in breve — poi
  la cronaca di ogni anno, capitolo per capitolo, con le stesse pagine
  di D-086. Con un anno solo è il libro di sempre, per costruzione.
- **Il libro nell'app**: la fila degli anni giocati viaggia con la
  saga; «La cronaca» mostra il libro intero appena gli anni sono più di
  uno, e il piè di pagina dice cosa si sfoglia.

### Misurato

213 test in 29 suite, 4496 asserzioni; viste compilate headless;
batteria di chiusura verde.

---

## [0.1.52] — La saga si gioca: l'era successiva si offre a fine anno

Il primo pezzo mancante della 1.0 ([D-095](docs/DECISIONS.md#d-095)): il
motore della campagna esisteva solo in riga di comando, adesso lo vede
chi gioca.

### Added

- **«Gioca l'era successiva»**: a fine anno l'app offre di continuare la
  saga nella stessa seduta — la nuova era eredita mondo e risultati per
  lo stesso percorso di `run_saga`, il transcript continua col verbale
  d'apertura in testa, il seme avanza di +97 (una saga giocata a mano è
  riproducibile come una simulata).
- **`DataSet.library_sequel_of`**: quale biblioteca prosegue quale età —
  lo stesso tavolo di Entità — scritto una volta sola, con guardia.
- ROADMAP aggiornata allo stato vero (0.2 con una voce sola, 0.3
  completata, 1.0 a metà).

### Misurato

212 test in 29 suite, 4487 asserzioni; `game_screen.gd` compila headless;
batteria di chiusura verde.

---

## [0.1.51] — La spirale del fallimento si chiude ri-decidendo

Scioglie il debito residuo della voce 18
([D-094](docs/DECISIONS.md#d-094)): «Il Regno che Ricorda» non è più
strozzato dalla propria Victory.

### Added

- **La via del riprendere**: `P_RETAKE_QUESTION` (Q_SUCCESSION_LAW,
  eleggibile con `question_unresolved` sul mondo) e
  `CNS_QUESTION_RETAKEN` — il segno si toglie, la domanda torna calda
  (+2). La forma di D-085 applicata al fallimento.
- **Il conto dell'era** (`world_state.open_failures`): le Tensioni cadute
  e non ancora ri-decise; quando l'ultima si decide, la spirale si
  chiude e il tag si toglie con un Effect di sistema. Il segno ereditato
  da un'era prima non si chiude per caso: quello lo scioglie solo la via
  del riprendere.

### Misurato

Su 20 saghe: Vittorie del Regno che Ricorda **6→16**, Trionfi 4→7
(sopra il Minimo 11%→27%); ere che chiudono col tag 140→75 su 200;
`question_unresolved` letterale all'ultimo anno da 18/20 a 5/20 saghe.
Playtest sugli stessi 100 semi: 0/8 bloccati al tavolo misto, Consigli
in banda. 211 test in 29 suite, 4482 asserzioni.

---

## [0.1.50] — La voce 2 si chiude coi numeri: i template in più non servono

Solo verbale ([D-093](docs/DECISIONS.md#d-093)): terza e ultima misura
della voce più vecchia rimasta aperta.

### Misurato

Ogni proposta scritta vive dove vive: CHR_01 15/18 ai voti nell'anno
singolo (le 3 fuori sono contenuto d'era, misurato vivo sulle saghe:
21, 4 e 32 volte), CHR_03 17/19 con `P_SHOW_IT` a 88 voti su 20 saghe;
nessuno zero sul conteggio completo, e le morte storiche di D-063
(`P_DIG_FOR_HIRE`: 31) resuscitate dal tempo delle ere. La ripetizione
ha già i suoi rimedi strutturali (D-028, D-077, D-076/D-085): scrivere
template adesso sarebbe contenuto senza bisogno (D-035).

---

## [0.1.49] — Il browser dice se sa tenere il salvataggio

Chiude ISSUES voce 12 ([D-092](docs/DECISIONS.md#d-092)): una partita
persa perché il browser ha pulito lo spazio non è più persa in silenzio.

### Added

- **L'avviso prima di cominciare**: nel browser il menu dichiara se lo
  storage c'è («i salvataggi restano in questo browser») o no
  (navigazione privata: «chiusa la scheda, la partita sparisce») — e
  l'avviso torna a fine anno, quando serve davvero.
- **«Scarica il salvataggio»**: la partita in corso (o l'anno appena
  finito) come JSON, per la stessa via del log; il nome del file porta
  chronicle e seme (`echoes-salvataggio-chr-01-7042.json`).
- `LogExport.deliver` ha imparato il MIME e i suoi messaggi sono neutri;
  `SaveSerializer.download_name` nuovo, con guardia.

### Misurato

209 test in 29 suite, 4471 asserzioni; `game_screen.gd` compila headless.

---

## [0.1.48] — `marker_id` esce dal modello dati

Chiude ISSUES voce 11 nel modo che la voce stessa prescrive
([D-091](docs/DECISIONS.md#d-091)): un campo che nessuno legge è un campo
che nessuno mantiene.

### Removed

- **`marker_id`** dagli schemi `region`/`entity`/`asset`/`echo_card`, dai
  tre file dati che lo valorizzavano e dalla colonna del manifest.
  Nessuna riga di GDScript l'ha mai letto. Rientrerà col prototipo di
  computer vision della 0.5, che è anche il momento giusto per decidere
  che forma di marker serve; i valori erano meccanici (`MK_<id>`) e si
  rigenerano in un minuto.

### Misurato

Suite invariata (208 test in 29 suite, 4469 asserzioni), validazione e
manifest verdi.

---

## [0.1.47] — Il verbale della mappa: come si piazza l'era nuova

Estensione della Fase 3 su richiesta del committente
([D-090](docs/DECISIONS.md#d-090)): il verbale dice anche la mappa.

### Added

- **`world_state.map_record`**: per ogni Regione chi la tiene (coi nomi
  dell'era nuova), se è decaduta perché nessuno c'era (D-027), i segni
  che porta e le condizioni sbiadite dal salto (D-078); in coda i fatti
  diventati leggenda (D-075) e i rapporti ammorbiditi (D-045). Derivato
  dagli stessi `inheritance_effects` che piazzano la mappa: una sola
  fonte di verità.
- **La prosa della mappa** nel log del tavolo (sotto il verbale delle
  domande) e in `run_saga` sotto «La mappa che si eredita».

### Changed

- I segni nel verbale delle domande passano all'imperfetto («il mondo ne
  portava il segno»): la pesca legge il mondo com'era alla chiusura, e il
  salto può averli sbiaditi subito dopo — lo dice la riga della mappa.

### Misurato

Solo lettura, verificato: suite e sonda delle ere identiche riga per
riga. 208 test in 29 suite, 4469 asserzioni.

---

## [0.1.46] — Il verbale d'apertura: la generazione si legge

Fase 3 del World Propagation Engine ([D-089](docs/DECISIONS.md#d-089)),
l'ultima dichiarata: chiude ISSUES voce 9.

### Added

- **`world_state.opening_record`**: per ogni domanda pescata, chi l'ha
  richiamata — il segno sul mondo (D-079, nominato per nome: fatto,
  leggenda o Regione), il conto rimasto aperto (D-087, con il nome del
  seggio che l'ha lasciato), o la biblioteca — e con che valore riparte
  (D-088). Schema esteso, chiave sempre presente.
- **La prosa del verbale**: in testa al log del tavolo a ogni eredità
  («La Carestia torna: Re Aldric non l'ha mai chiusa») e nel digest di
  `run_saga` sotto «Perché queste».
- `_open_accounts` dice *chi* ha lasciato ogni conto; `_carried_mark`
  dice *quale* segno ha richiamato — la pesca usa gli stessi bordi di
  prima e resta bit per bit identica.

### Misurato

Solo lettura, verificato sugli stessi semi: playtest a tavolo misto
invariato (0/8 seggi bloccati), sonda delle ere identica alla 0.1.45 riga
per riga. 207 test in 29 suite, 4452 asserzioni.

---

## [0.1.45] — La domanda lasciata calda torna calda

Fase 2 del World Propagation Engine ([D-088](docs/DECISIONS.md#d-088)): il
tempo non resetta più le questioni oltre alle persone.

### Added

- **Il calore ereditato**: sui salti brevi (sotto i 50 anni) una Tensione
  ripescata riparte da dove l'era prima l'ha lasciata — mai già a soglia:
  torna tiepida, non bollente. Sui salti lunghi il calore sbiadisce e si
  riparte dal valore d'autore. Una questione chiusa bene può ripartire
  anche più quieta di com'è scritta.
- La sonda delle ere conta il calore ereditato.

### Misurato

Su 720 domande pescate in 20 saghe, 66 partono più calde e 14 più quiete
del valore d'autore; ogni altra misura d'era invariata e la guardia degli
anni-biblioteca resta verde. 206 test in 29 suite verdi.

---

## [0.1.44] — Il motore 0.3 apre il cantiere: i conti rimasti aperti

Fase 0 e Fase 1 del World Propagation Engine
([D-087](docs/DECISIONS.md#d-087)): le evidence, registrate «proprio per
questo passaggio», finalmente si leggono.

### Added

- **`unmet` nei risultati dei Destini**: le clausole negate come dati, non
  come prosa — la metà strutturata delle evidence. Misurato: un'era lascia
  in mediana 9 conti aperti (5–13).
- **Il conto aperto richiama la sua domanda**: una candidata nominata da
  una clausola `tension_limit` negata nell'era prima pesa il triplo nella
  pesca, come un segno sul mondo (D-079). La storia preme sull'era, anche
  se la casa ha cambiato ambizione.
- La sonda delle ere conta i conti aperti richiamati.

### Misurato

Richiamate pescate il **75%** delle volte (260/343) contro il 67% della
pesca cieca; ogni altra misura d'era invariata. 205 test in 29 suite
verdi. Dichiarate le Fasi 2 e 3 del cantiere.

---

## [0.1.43] — La cronaca si vede: la voce 10 si chiude

La metà app di ISSUES voce 10 ([D-086](docs/DECISIONS.md#d-086)): a fine
Chronicle la cronaca dell'anno è sullo schermo.

### Added

- `ui/chronicle_book_view.gd`: si apre da sola quando l'anno finisce,
  frecce per sfogliare, bottone «La cronaca» per tornarci — il salvataggio
  resta nello schermo anche dopo il congedo della sessione, come il seme.
  La vista rasterizza **le stesse pagine SVG** che il Chronicle Book
  stamperà: quello che si vede è quello che uscirà, non una cosa che gli
  somiglia (disciplina D-056).
- Guardia: ogni pagina generata deve rasterizzarsi.

---

## [0.1.42] — La cronaca dell'anno: le Verità diventano pagine

La metà export di ISSUES voce 10 ([D-086](docs/DECISIONS.md#d-086)): il
seme del Chronicle Book della 1.0.

### Added

- `cli/run_chronicle_book.gd`: da un salvataggio qualsiasi alle pagine A4
  della cronaca — l'anno in testa, le Verità atto per atto, e come è finita
  per i seggi. Carta scura del set, serif per l'anno, a capo a mano.
- `scripts/core/chronicle_book.gd` e le guardie di `test_chronicle_book.gd`:
  ogni Verità finisce sulla pagina, A4 veri e numerati, un anno lungo si
  spezza in più pagine, un anno muto lo dice.

---

## [0.1.41] — Un PDF, non venticinque SVG

Chiude ISSUES voce 8: il formato di consegna per la tipografia.

### Added

- `tools/make_pdf.py` e il flag `--pdf` di `tools/run_export.sh`:
  `echoes_print.pdf`, 26 pagine A4 esatte in ordine di consegna (Asset,
  Echo, Tensioni, Destini, Casate, Regioni). Dipendenze opzionali
  (`cairosvg`, `pypdf`): servono solo a chi stampa — gli SVG restano la
  sorgente diffabile che la CI confronta, e senza flag non cambia niente.

---

## [0.1.40] — Le vie per disfare i fatti eterni

Chiude ISSUES voce 18 ([D-085](docs/DECISIONS.md#d-085)): un fatto eterno
non è più una porta murata per sempre — si può disfare, a un Consiglio,
pagando.

### Added

- **`P_REOPEN_THE_MINE`** (Risveglio): si toglie la pietra, e il Risveglio
  sale di 2 — riaprire sveglia quello che dormiva.
- **`P_ONE_CROWN`** (Successione): il titolo torna uno, e chi ha perso la
  conta diventa OSTILE.
- **Il ramo del pianificatore che disfa**: una clausola di assenza ora
  insegue anche la Conseguenza che rimuove il tag.

### Misurato

Su 20 saghe: 21 riaperture e 4 riunificazioni in 200 ere; la scuola risorge
(Vittorie 6→20, Trionfi 3); il Regno che Ricorda resta strozzato dalla
propria Vittoria — debito residuo circoscritto e a verbale. Playtest 0/8
bloccati, anno scritto invariato. 198 test in 28 suite verdi.

---

## [0.1.39] — Il quinto MASTER PROMPT: i Destini illustrati

L'inventario dei componenti grafici ha trovato le carte Destiny senza
direzione d'arte, come i ritratti prima di D-065
([D-084](docs/DECISIONS.md#d-084)).

### Added

- **MASTER PROMPT 5 — Destiny card**: niente volti, la cosa desiderata
  composta come un'immagine votiva; variation key per archetipo di chi
  desidera, con gli accenti del MP4 — le due carte di un pool sono due
  quadri della stessa parete.
- Le 4 chiavi d'arte mancanti dei Destini di seconda rotazione della
  corona; il mazzo `destiny` collegato al brief. **Il brief passa da 101 a
  117 prompt.**

### Fixed

- `card_face.gd` non esponeva la chiave d'arte sulla faccia Destiny: il
  brief la saltava in silenzio.

---

## [0.1.38] — Il contenuto senza elettorato si toglie

Punto 7 del committente: le voci croniche a zero di CHR_03/04, riscritte se
possibile, tolte se no ([D-083](docs/DECISIONS.md#d-083)).

### Removed

- **`P_WATER_RIGHTS`**: era il cattivo della questione dell'acqua e i poteri
  locali la tenevano fuori per costruzione — la cura misurata (un debito
  saldato nel prezzo) non ha mosso niente: 0 su 23, respinta e tolta.
- **`Q_ANY_ANCIENT_LEAVE` / `P_ANY_WITHDRAW`**: i Consigli jolly si aprono
  a questione fredda e il ritiro non ha un solo elettore fra i Destini —
  tolti; la veglia e l'ignorare restano vivi.

### Docs

- **Il §7 riscritto per il gioco a 4 Tensioni** (punto 5 del committente):
  `RULES_V0_2.md` dichiara i numeri veri — anno scritto mediana 5-6,
  anno-biblioteca 3-6, limiti duri 2-8 — e chiude sei versioni di bande
  «in deroga». A verbale anche il vincolo di equilibrio (0/8 al tavolo
  misto) e la lettura del tavolo uniforme.

### Misurato

Il «mai ai voti» di CHR_03 scende da 7 proposte su 21 a **2 su 19**, con le
due superstiti giustificate a verbale. 198 test in 28 suite verdi.

---

## [0.1.37] — La memoria in posta: il Trionfo che nomina la leggenda, e il giuramento che preme

Due scelte del committente: la leggenda come posta nei Trionfi, e una
memoria che inquieta per la prima saga ([D-082](docs/DECISIONS.md#d-082)).

### Added

- **La memoria come posta** (D-082): il Trionfo di «Radicati» (Popolo Nahr,
  corona) e del «Registro Aperto» (Gilda del Sale, città) chiede anche la
  leggenda dell'era **messa per iscritto** (`discovery:legend`). Tre
  collocazioni respinte coi numeri prima di questa — il verbale del viaggio
  è in D-082.
- **`P_HEIR_AS_STORY`** sul Consiglio della Successione: «si nomini chi la
  ballata nomina, e stavolta lo si scriva» — la strada di corona verso la
  trascrizione, ineleggibile finché la leggenda non esiste (anno scritto
  intatto per costruzione). Votata 32 volte in 20 saghe.
- **«Il Giuramento che Nessuno Sciolse»**: la carta MEMORIA che preme
  invece di consolare — gated su `legend:oath_broken`, scalda la
  Successione e **forza il Consiglio**: la domanda si pone. Pescata 4 volte
  in 20 saghe: rara come il suo gate, ma esiste.

### Misurato

Trionfo del popolo da 29/87 (quasi automatico) a **4/87** (raro e conteso),
Vittoria 32→38; trascrizioni di corona da 0/153 a 12 ere; P_ANY_AS_STORY
da 4 a 23 voti. Playtest: **0/8 bloccati al tavolo misto**, anno scritto
invariato. A ISSUES (voce 18) il reperto: i fatti eterni come condizioni di
assenza strozzano i Destini tardivi. 198 test in 28 suite verdi.

---

## [0.1.36] — La soglia della stanchezza: tre ere, non due

Ratifica del committente su D-081: la terza delusione è la tradizione, non
la seconda ([D-081, revisione](docs/DECISIONS.md#d-081)).

### Changed

- `WEARY_ERAS` da 2 a 3: l'erede cambia ambizione dopo **tre** ere a mani
  vuote. Rimisurato sugli stessi semi: rotazioni da stanchezza da 6.7 a
  4.1 per saga, da premio tornate a 13.6; i mortali restano sbloccati
  (run massimo di Aldric 4 ere, zero saghe macinate).
- A verbale la lettura confermata dal committente: i 4/8 seggi bloccati
  del **tavolo uniforme** sono un artefatto della misura (quattro
  ottimizzatori identici), non un difetto del gioco — il vincolo di
  equilibrio resta 0/8 al tavolo misto.

---

## [0.1.35] — L'iniquità del tempo

La rotazione dei Destini premiava solo chi ottiene: chi falliva riprovava la
stessa ambizione per mille anni — Aldric macinava lo stesso Destino per
un'intera saga in 6 su 20 ([D-081](docs/DECISIONS.md#d-081)).

### Added

- **Un erede non giura sull'ambizione che ha visto fallire** (D-081): il
  seggio conta le ere a mani vuote e, quando la persona cambia dopo due ere
  senza ottenere, l'erede passa al Destino successivo del pool. La rotazione
  da stanchezza è marcata `weary`, distinta da quella da premio, e lascia una
  riga nel verbale. Chi non cambia persona non si stanca: la stessa vita
  riprova finché vive, un popolo si rinnova senza cambiare volto, e Vaerax è
  sotto la montagna apposta.
- La sonda delle ere conta le rotazioni da stanchezza.

### Misurato

Su 20 saghe della corona: i macinamenti di un'intera saga passano da 6+2 a
**zero** (run massimo di Aldric da 10 a 3 ere); le rotazioni da premio
restano 13.2 per saga, quelle da stanchezza sono 6.7; ogni altra misura
d'era invariata. 198 test in 28 suite verdi.

---

## [0.1.34] — La pesca che ascolta, e la guardia sugli anni-biblioteca

Gli ultimi due pezzi dichiarati della #25
([D-079](docs/DECISIONS.md#d-079), [D-080](docs/DECISIONS.md#d-080)): la
biblioteca smette di pescare l'anno alla cieca, e l'anno pescato ha la sua
guardia di bilanciamento.

### Added

- **La pesca che ascolta** (D-079): il `tension_pool` dichiara gli *echi* —
  per ogni candidata, i segni che la richiamano. Se il mondo ereditato porta
  uno di quei segni (fatto globale, la sua leggenda, o tag di Regione) la
  candidata pesa il triplo nella pesca. La ripesca avviene in
  `inherit_from`, quando il mondo di prima è noto, e ridà anche il sacchetto
  del Drift; senza echi o senza eredità la pesca resta byte-identica a
  prima. Echi dichiarati per CHR_02 (corona) e CHR_04 (città), ancorati ai
  tag che le Conseguenze scrivono davvero.
- **La guardia sugli anni-biblioteca** (D-080, Fase 4 di #25):
  `test_library_balance.gd` gioca l'anno scritto, gli fa ereditare quello
  pescato, e tiene i Consigli del secondo dentro i limiti duri del §7 —
  per tutte e due le coppie. Banda dichiarata dalla misura di nascita:
  mediana 4 (corona) e 5 (città), banda 3-6.
- La sonda delle ere conta la pesca che ascolta.

### Misurato

Le candidate richiamate da un segno vengono pescate il **78%** delle volte
in 20 saghe, contro il 67% della pesca cieca; su cento semi col solo segno
della miniera murata, il Risveglio esce 93 volte contro 66. La saga
dell'812 tiene le sue proprietà (0 domande ridecise, salti invariati) e le
mani d'era mostrano la continuità voluta. 196 test in 28 suite verdi; il
playtest non incatena ere e resta intatto per costruzione.

---

## [0.1.33] — Le due falle del verbale: la domanda ridecisa e il lutto di mille anni

La prima saga giocata per intero ha lasciato un verbale, e il verbale due
buchi di regolamento: due Chronicle su dieci rimettevano ai voti una domanda
già decisa nello stesso anno, e le Terre Nahr portavano lo stesso lutto
dall'812 al 1856 ([D-077](docs/DECISIONS.md#d-077),
[D-078](docs/DECISIONS.md#d-078)).

### Fixed

- **Una domanda decisa resta decisa** (D-077): niente ripiego sulle domande
  già poste; un Consiglio che non ha più niente di nuovo da chiedere non si
  apre — né a soglia, né dal pavimento di fine anno, né con un Claim — e
  **una proposta bocciata non consuma la domanda**: respingere non è
  decidere, la questione resta sul tavolo e può tornare ai voti.
- **Le condizioni sbiadiscono come i fatti** (D-078): su un salto oltre i
  cinquant'anni una `condition:` di Regione non attraversa; strutture,
  insediamenti e cicatrici restano — la cicatrice è la memoria visibile
  della mappa. Il criterio è quello di D-075, esteso alla mappa.

### Changed

- La banda dichiarata di `test_balance.gd` torna **5-6**: i Consigli tolti
  erano ridecisioni, l'anno è più corto ma più vero. I limiti duri del §7
  non si sono mossi (0 partite fuori).

### Misurato

Playtest dei 100 semi, tavolo misto: **0/8 seggi bloccati** (era arrivato a
1/8 con la prima stesura — il verbale della cura, con due varianti respinte
coi numeri, è in D-077), Kessa dei Fuochi 41/8/1, Re Aldric da 7 a 2 NONE,
Lyra 12 Triumph, Verità diverse 484→513. Saga dell'812 rigiocata: **0
domande ridecise** (erano 2 su 10 Chronicle), il lutto sopravvive al salto
breve (+37) e sbiadisce su quello lungo (+153). 193 test in 27 suite verdi.

---

## [0.1.32] — Il contenuto che legge le leggende

D-075 ha dato al mondo le leggende; questa versione mette al tavolo chi le
racconta ([D-076](docs/DECISIONS.md#d-076)).

### Added

- **La famiglia MEMORIA**: carte Echo gated su una leggenda — «La Ballata
  dell'Anno Buono» e «Il Giorno che la Gilda Chiese Tutto» — che stanno nei
  mazzi delle sole Chronicle-biblioteca, le ere che una memoria possono
  averla.
- **Due proposte «si dice che»** e la Conseguenza «La Leggenda Messa per
  Iscritto»: chi raccoglie le storie guadagna una Scoperta, e la domanda si
  calma. La memoria è una via alle Scoperte: un ponte fra le ere.
- La sonda delle ere conta la memoria letta (disciplina D-035).

### Fixed

- **Un mazzo non porta famiglie che nessun atto pesca**: la composizione del
  mazzo Echo di un anno scritto non cambia più quando si aggiungono carte per
  le ere — gli anni scritti sono byte-identici a prima, verificato con `diff`
  sul playtest dei 100 semi.
- **La policy pianifica contro i Consigli di quest'anno**, non contro
  l'intera biblioteca: inseguiva vie che il primo anno non può aprire.

### Misurato

La Ballata pescata 38 volte in 20 saghe della corona (mai in quelle delle
città), il Giorno della Gilda 18 volte in 10 saghe delle città (mai prima);
le proposte votate 6/4 e 5 volte. Ogni pezzo vive nella sua era, nessuno
fuori. 191 test in 27 suite verdi.

---

## [0.1.31] — La memoria che sbiadisce

La correzione di rotta è del committente: **fra due partite possono passare
venti anni o due secoli, e dieci partite possono coprire mille anni.** Il
motore la visione ce l'aveva già — salti dichiarati, generazioni, Destini che
ruotano — ma la memoria no: il 100% dei fatti dell'anno uno arrivava
letterale a mille anni dopo ([D-075](docs/DECISIONS.md#d-075)).

### Added

- **I fatti diventano leggende**: su un salto lungo resta un *fatto* solo
  quello che è murato o scritto — la Chronicle lo dichiara in
  `enduring_facts` — e il resto diventa `legend:<fatto>`, vero come la
  memoria e non come il mondo. Le leggende attraversano ogni salto
  successivo. La teca mostrata due secoli fa torna leggenda, e l'Ordine di
  un'altra era deve rimostrarla.
- `cli/run_era_probe.gd`: cosa fa il tempo a una saga — anni coperti (mediana
  **1.019 su 10 Chronicle**), salti, generazioni (17 per saga), Destini
  ruotati, mani di domande, e il bilancio fatti/leggende all'ultimo anno.
- `enduring_facts` nello schema delle Chronicle, con le liste autorate per le
  due biblioteche (`CHR_02`, `CHR_04`).

### Misurato

Dei 7,2 fatti dell'anno uno, i letterali all'ultimo anno passano da **7,2
(100%) a 5,0** — e i sopravvissuti sono quelli dichiarati o rifatti dalle ere
successive. Il mondo all'ultimo anno porta 11,7 fatti e **16,1 leggende**.
Il playtest a Chronicle singola è intoccato per costruzione. 191 test in 27
suite verdi.

---

## [0.1.30] — La materia prima della campagna

Fase 1 dell'issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25) (la
Chronicle II generata dalle evidence): prima di scrivere il generatore, si
misura la sua materia prima ([D-074](docs/DECISIONS.md#d-074)).

### Added

- `cli/run_legacy_probe.gd`: i fatti globali, le cicatrici, il controllo, i
  rapporti e i livelli con cui un anno si chiude, e quanti mondi diversi
  producono cento semi.

### Misurato

**99 mondi distinti su 100** — la materia prima c'è. E i tre difetti da
conoscere prima di costruirci sopra, a verbale in D-074: la cicatrice del
fallimento è il 73% di tutte le cicatrici (va aggregata, non letta alla
pari), tre rapporti chiudono identici in ogni seme (costanti travestite da
variabili, e a monte un fatto di contenuto), e a differenziare gli anni sono
i fatti rari, non i frequenti.

---

## [0.1.29] — La prima saga si sveglia

Due scene scritte col vincolo che la respinta di D-070 aveva insegnato: le
bande devono sovrapporsi — dev'esserci almeno un mondo in cui tutt'e due i
contendenti vincono ([D-072](docs/DECISIONS.md#d-072), chiude ISSUES 17).

### Changed

- **La fame tiene gli uomini nelle valli**: Vaerax a Triumph vuole la Carestia
  da 3 in su, contro il tetto di 4 di Aldric e di 3 del Popolo. Bande che si
  toccano in 3–4: ci si può stare tutti, ma ogni spinta è contesa.
- **Un domani certo rimette in moto le carovane**: l'Erede Nominato cala di 1
  le Vie Interrotte — la proposta più votata della Successione adesso tocca
  Lyra e Vaerax nei due versi.

### Added

- La sonda dei margini accetta `--chronicle` e `--tavolo=misto`: guardava solo
  la prima saga a tavolo uniforme, lo stesso difetto che D-066 aveva corretto
  nella sonda delle posizioni.

### Misurato

ABSTAIN della prima saga **71,1% → 59,9%** (era il criterio della voce 17:
sotto il 60 a parità di vincoli), CONDITION e SUPPORT raddoppiati. Sui 100
semi di D-055: seggi bloccati 0 su 8, Consigli 5,96, TRIUMPH 11 (pavimento:
10), fallimenti **195** — il minimo mai misurato — e la seconda saga ferma al
48,4%. Le due saghe sono ora entrambe sotto il 60% di ABSTAIN, dal 70–86% in
cui stavano tre versioni fa.

E la domanda tattica che restava — *il dado conta?* — è misurata e chiusa
senza manopole ([D-073](docs/DECISIONS.md#d-073)): a tavolo misto il d6
decide la banda in circa due Consigli su tre, l'opposizione c'è nel 71–78%
dei Consigli, e i margini blindati sono un quarto. A tavolo uniforme sembrava
il contrario — terza volta che l'ottimizzatore da solo avrebbe indotto
l'intervento sbagliato.

---

## [0.1.28] — Il Consiglio come scena

Dopo tre versioni di lavoro sugli assi, il 65–72% delle posizioni restava
ABSTAIN. Tre mosse misurate una alla volta, una respinta a verbale, e la
risposta a un sospetto vecchio quanto ISSUES 3
([D-070](docs/DECISIONS.md#d-070), [D-071](docs/DECISIONS.md#d-071)).

### Fixed

- **La clausola non è più un timbro**: la CONDITION sceglieva sempre la prima
  clausola della lista — zero scelte della seconda, in tutt'e due le saghe.
  Adesso si sceglie quella che serve il proprio Destino: le clausole viventi
  passano da 2 a **8**.
- **La corsa al controllo si vede**: una Regione che cambiava mano verso un
  terzo valeva zero per chi conta le Regioni. Adesso vale un'obiezione.

### Changed

- Due scene nuove col criterio di D-066: il grano requisito intasa le Vie
  (Lyra contro, Vaerax a favore, sulla domanda più votata della prima saga), e
  l'Ordine del Vetro prende posizione sulla Carta (Carta ≤ 4 a Triumph, contro
  le Città Libere). Una terza — Lyra contro il sigillo delle gallerie — è
  **respinta con i numeri**: sveglia Lyra ma fa crollare i TRIUMPH del tavolo
  da 11 a 3 su 400. Due clausole mutuamente esclusive non sono una scena.

### Added

- `cli/run_asset_probe.gd` (chiude ISSUES 3): **la coda è vuota** — tutte le
  48 facce arrivano in mano e vengono spese, a tavolo misto. Nessuna carta da
  riscrivere. A verbale invece lo sbilancio di circolazione: WEALTH 4.344
  passaggi di mano contro i ~350 di FORCE e PEOPLE.
- La sonda delle posizioni conta le clausole poste e le Condition qualificate.
- Una guardia in `test_stance_scoring.gd`: chi vuole la domanda calda non pone
  la clausola che la raffredda.

### Misurato

ABSTAIN della seconda saga **74,1% → 48,4%** in tre versioni (64,9% alla
0.1.27), CONDITION al 29,8%, l'Ordine del Vetro da 142 astensioni e zero
opposizioni a 42/57/71. Sui 100 semi di D-055: divario aggressivo/prudente
**22** (era 37 alla 0.1.26), NONE 11, TRIUMPH 11, Verità diverse **526**
(nuovo massimo), seggi bloccati a tavolo misto 0 su 8, Consigli 6,06. La
prima saga resta al 71% di ABSTAIN: il perché e la strada sono la voce 17 di
ISSUES.

---

## [0.1.27] — La parola si può prendere

Il proponente di un Consiglio lo decide il posto, e il posto è di chi vuole
l'esito ovvio ([D-063](docs/DECISIONS.md#d-063)): le Città Libere non hanno mai
preso la parola sul Debito in 92 Consigli. L'azione che sposta la parola —
`CLAIM`, §11 — esisteva e **la policy non l'ha mai giocata**
(issue [#22](https://github.com/Tannoiser2/ECHOES/issues/22),
[D-069](docs/DECISIONS.md#d-069)).

### Fixed

- **La policy gioca CLAIM**, derivandolo dai dati (precedente D-021): chi ha
  bisogno di un Consiglio a cui il posto non gli darebbe la parola prenota il
  dominio e poi lo forza. Con quattro moderazioni, ognuna misurata contro una
  rottura: la domanda deve scaldarsi, la parola ruota, si forza solo in un
  round che sarebbe rimasto muto, si prenota solo con la coppia di AUTHORITY
  in mano. La forma ingenua — forza tutto, subito — è respinta a verbale:
  fallimenti 219 → 339 e mediana dei Consigli fuori banda.
- **La ripresa non salta più il Consiglio del round salvato**: un salvataggio
  in fase `DRIFT`/`THRESHOLD_CHECK` riprendeva dal round dopo, perdendo il
  Consiglio dovuto. Invisibile finché nessun Consiglio si apriva presto
  nell'anno: è stata la policy col Claim a scovarlo.

### Added

- La sonda delle scelte conta Claim creati e Consigli forzati per seggio.
- `tests/unit/test_claim_policy.gd`, 6 test: ogni moderazione è una guardia.

### Misurato

40 Chronicle a tavolo misto: Claim 0/0 → 104 creati/13 forzati (CHR_01) e
60/25 (CHR_03, Libere 16). **Mai ai voti: 2 → 0 su 15 nella prima saga — prima
volta — e 4 → 3 su 20 nella seconda; le cinque proposte di D-063 votano
tutte.** Sui 100 semi di D-055: divario aggressivo/prudente **37 → 31**, NONE
5 → 9, TRIUMPH 11 → 14, Verità diverse 491 → 506, seggi bloccati a tavolo
misto 0 su 8, Consigli 6,02 (mediana 6). Costi dichiarati: Decisive 185 → 172,
bloccati a tavolo uniforme 3 → 4.

---

## [0.1.26] — Perdere adesso è implementato

Su 400 risultati di seggio, NONE usciva **una volta**. Non per taratura: nessun
contenuto poteva falsificare un Minimo contro la volontà di chi lo regge
([AUDIT_DESTINI](docs/AUDIT_DESTINI.md), [D-067](docs/DECISIONS.md#d-067),
[D-068](docs/DECISIONS.md#d-068)).

### Added

- **Tre espulsioni**: `CNS_CAPITAL_TAKEN`, `CNS_SEALED_VALLEY` e
  `CNS_ASH_ABANDONED` tolgono una presenza a `$rival` — sulla capitale, sulle
  Terre Nahr, sulle Miniere Antiche: le Regioni che i Minimi nominano. Tutte su
  Conseguenze che la vittima già bloccava: **l'espulsione va dove il no c'è
  già**, così non cambia il punteggio di nessuno — cambia cosa succede quando
  quel voto si perde comunque. La forma sulle vie del controllo affamava Kessa
  (39/11 → 45/5, un seggio bloccato) ed è respinta a verbale.
- **La regola della porta sbarrata**: da una Regione da cui un Consiglio ti ha
  cacciato non si rientra finché l'atto non gira (`evicted:<regione>` messo
  dalla risoluzione, letto da `can_move_to`, tolto dal giro di stagione — tutto
  nel log degli Effect). Senza contenuto che caccia è inerte, quindi si toglie
  togliendo tre righe di dati. Senza, il rientro era gratis: 12 espulsioni
  recuperate su 13.
- **Due Conseguenze che fanno nemici** nella seconda saga, che non ne aveva
  nessuna: chiamare il debito e prendere il seggio portano il rapporto a
  `HOSTILE`. E due clausole `relation_state` a livello Triumph, **dal lato di
  chi vota**: la stesura sull'aggressore pesava zero, perché chi propone non
  vota (ISSUES 14).
- `cli/run_eviction_probe.gd`: quando cade un'espulsione, e chi recupera prima
  che il Destino venga letto. È la sonda che ha trovato il difetto vero.
- `tests/unit/test_eviction.gd`, 3 test.

### Misurato

Sugli stessi 100 semi di D-055, tavolo misto:

| | 0.1.25 | 0.1.26 |
|---|---|---|
| **NONE** | **1** | **5** |
| MINIMUM / VICTORY / TRIUMPH | 205 / 181 / 13 | 214 / 170 / 11 |
| seggi bloccati (misto) | 0 su 8 | **0 su 8** |
| Consigli per Chronicle | 5,97 | 5,92 |
| `REMOVE_PRESENCE` pesato (CHR_01) | 0 | **28** |
| `SET_RELATION` pesato (CHR_03) | 0 su 156 | **85 su 357** |
| ABSTAIN CHR_03 | 74,1% | **64,9%** |

Ogni espulsione sul Minimo caduta nell'atto III è diventata un NONE; quelle
degli atti I–II si recuperano perdendo l'atto. **I costi, reali e a verbale**:
Ilve 3/42/5 → 12/34/4 (il seggio più forte trova un no), Kessa 39/11 → 43/7, e
il divario aggressivo/prudente sale da 30 a 37 — la stessa forza di D-066,
messa in conto e non tarata via.

---

## [0.1.25] — Il tavolo adesso ha qualcosa in gioco

L'80% dei seggi valutava una proposta **esattamente zero**: non apatia scritta nel
contenuto, indifferenza del codice e dei Destini insieme
([D-066](docs/DECISIONS.md#d-066)).

### Fixed

- **`SET_RELATION` non aveva un ramo nel punteggio.** Letto 126 volte, pesato
  zero: Forgiare è una delle sei azioni del gioco e per chi decide non esisteva.
- **Una clausola `min` su una Tensione era mezza cieca**: `max` aveva il suo
  ripiego dentro la banda, `min` no. Chi ha bisogno che una domanda resti calda
  non aveva niente da dire finché non gliela spegnevano del tutto.

### Changed

- **Dieci clausole `tension_limit` nei Destini in gioco.** Le domande più
  visitate dei due tavoli — le Vie Interrotte, la Successione, la Carta — non
  erano nominate da nessuno, e la seconda saga non aveva **una sola** clausola su
  una Tensione. Sono a livello Triumph: il punteggio legge tutti e tre i livelli,
  e a livello Victory la Vittoria crollava da 192 a 126 su 400.
- Il criterio, che vale più delle clausole: **ogni Tensione in gioco dev'essere
  nominata da almeno un Destino, e almeno un seggio dev'essere dalla parte
  opposta.** Vaerax vuole le Vie Interrotte alte perché salire non dev'essere
  facile; Lyra le vuole basse perché è la strada delle gallerie. Quella è una
  scena. Quattro Destini che vogliono tutti la Carestia bassa non lo sono.
- `validate_data.py` rifiuta una Chronicle in cui una domanda in gioco non è
  nominata da nessun seggio.

### Added

- `tests/unit/test_stance_scoring.gd`, 5 test.
- `run_stance_probe.gd` accetta `--chronicle`: guardava solo la prima saga, ed è
  la seconda quella che di clausole sulle Tensioni non ne aveva nessuna.

### Misurato

40 Chronicle per saga:

| | CHR_01 | CHR_03 |
|---|---|---|
| Consigli con almeno un no | 37% → **68%** | 38% → **53%** |
| ABSTAIN | 80,1% → **70,2%** | 85,9% → **74,1%** |
| `ADJUST_TENSION` pesato | 6/468 → **266/669** | **0**/558 → **146/558** |

Sui 100 semi di D-055: fallimenti **251 → 219**, Decisive **133 → 185**, Consigli
per Chronicle 5,97 (in banda §7), Truth diverse 471 → 480, seggi bloccati 0 su 8.

**Il costo, che è reale:** il divario fra aggressivo e prudente passa da 26 a 31.
Rendere contesi i Consigli aiuta il carattere costruito per approfittare dei
contesi — i due obiettivi tirano in direzioni diverse, ed è la prima volta che il
progetto lo vede scritto.

**Resta aperto:** `SET_RELATION` si legge e pesa ancora zero su 156, perché solo
2 Consequence su 45 muovono un rapporto. E NONE resta 1 su 400: nessuno perde
mai.

---

## [0.1.24] — Tre conti aperti chiusi

La seconda leva, il contenuto che non arrivava mai al tavolo, e il quarto MASTER
PROMPT. **Milestone 0.2 a metà**: restano i template di Confluence e le carte che
nessuno gioca.

### Changed

- **Far cadere una proposta costa quanto proporla** ([D-064](docs/DECISIONS.md#d-064),
  ISSUES 1). Il §12.3 restituiva una carta a ogni oppositore su un Failure: era
  l'unica asimmetria che premiava il fronte contrario. Sugli stessi 100 semi di
  D-055 il divario in Vittorie fra aggressivo e prudente passa da **37 a 26**
  (69-32 → 66-40), i fallimenti da 274 a 251, e i Consigli per Chronicle restano
  5,96 — dentro la banda del §7. Sta in
  `confluence_rules.opposer_recovers_on_failure`: si toglie senza toccare il
  codice, e `run_playtest.gd --oppose-recovery=1` rimette l'originale per un run.
- `CNF_ANY_SURVIVAL` tolta da CHR_03, che non poteva aprirla: l'unica Tensione
  SURVIVAL dell'anno ha un template tutto suo. Tre proposte contate come
  contenuto della seconda saga e mai giocabili.

### Added

- **MASTER PROMPT 4 — la carta Casata** ([D-065](docs/DECISIONS.md#d-065),
  ISSUES 4). Un ritratto, come la regola 3 aveva già stabilito; variation key sui
  sei archetipi. Due di quelle righe non sono un volto, ed è per loro che il
  prompt dice *one subject* e non *one face*. Da qui `keys_without_prompt()` torna
  vuota: **98 chiavi su 98 hanno il loro prompt** in `docs/BRIEF_ARTE.md`.
- **`cli/run_choice_probe.gd`** ([D-063](docs/DECISIONS.md#d-063)): per ogni
  Confluence, cosa il tavolo poteva dire e cosa ha detto. Separa i tre motivi per
  cui una proposta non arriva mai ai voti, che vogliono tre rimedi diversi.
  `--tavolo=misto` la misura coi quattro caratteri invece che con quattro
  ottimizzatori identici.
- `validate_data.py` controlla che una Chronicle non dichiari template che
  nessuna delle sue Tensioni può aprire.
- `tests/unit/test_questions_asked.gd` e le due nuove guardie in
  `test_print_export.gd`.

### Misurato

- **«Mai eleggibile» è zero** su 38 proposte in due saghe: l'ipotesi che ci
  fossero clausole che non si avverano mai è morta lì.
- **Il tavolo uniforme sotto-riporta.** CHR_01 passa da 13 proposte su 15 a
  **15 su 15** appena si misura col tavolo misto: il contenuto della prima saga è
  tutto raggiungibile, e a dirlo non era la sonda che il progetto usava.
- Le 5 di CHR_03 che restano fuori esistono solo come cose che qualcun altro
  vuole evitare. L'unico seggio il cui Trionfo vuole `debt_forgiven` è stato
  proponente sul Debito **0 volte su 92**: il proponente lo decide il posto, e il
  posto è di chi vuole l'esito ovvio.

### Fixed

- `art_bible.gd` teneva accenti e guide in un dizionario piatto su tutti i MASTER
  PROMPT, e `PEOPLE` è sia una famiglia di Asset sia un archetipo di Casata. Con
  il contenuto di oggi non si sarebbe visto — il che lo rende il tipo di difetto
  che si scopre sei mesi dopo cambiando una parola.

---

## [0.1.23] — Il log si porta via, e il cruscotto ha un tasto

Due cose che si vedono solo giocando su un tablet, e il tablet è dove questo
gioco è stato giocato davvero ([D-062](docs/DECISIONS.md#d-062)).

### Added

- **«Scarica il log»**: tutta la cronaca della sessione in un file di testo — non
  le sole righe del `GameLog`, ma quello che si legge nella colonna, menu e
  risposte comprese. Nel browser scende come download, altrove viene scritto in
  `user://` e la schermata **dice dove**.
- In testa al file la saga, l'anno e il **seme**, che è la parte che conta: un log
  senza seme è un racconto, con il seme è una partita che si può rigiocare
  identica. Il nome se lo porta pure lui: `echoes-chr-03-3330.txt`.
- **«Cruscotto»**: il pannello che stava solo dietro F3. Su un tablet un F3 non
  esiste — non era scomodo, era assente. Il tasto sta in fondo alla colonna,
  fuori dalla lista delle scelte, e si spegne quando non c'è una partita.
- `tests/unit/test_log_export.gd`, 6 test.

### Changed

- F3 e F4 restano, ma passano per gli stessi due metodi del bottone: due strade
  che scrivono lo stesso stato si disallineano il giorno in cui una cambia.

---

## [0.1.22] — Il Consiglio non chiede due volte la stessa cosa

Trovata giocando, non testando: nel registro delle Truth di una partita vera **la
stessa frase compariva tre volte** nello stesso anno, con solo i numeri diversi.

### Changed

- **§12.2 B**: le domande eleggibili di una Confluence, meno quelle che questa
  Tensione ha già messo ai voti nella Chronicle. Quando le ha fatte tutte tornano
  disponibili tutte ([D-061](docs/DECISIONS.md#d-061)).
- La memoria sta in `world_state.questions_asked`, è per Tensione, si segna alla
  **risoluzione** e non all'apertura, e nasce vuota a ogni Chronicle: è la
  memoria dell'anno che si gioca, non del mondo.

### Added

- `cli/run_text_probe.gd` accetta `--chronicle` (le sonde guardavano solo la
  prima saga) e conta le ripetizioni **dentro la stessa Chronicle**: quante
  frasi diverse esistono in quaranta partite non era la domanda giusta — la
  domanda è quante volte una partita ripete sé stessa a chi la sta giocando.
- `tests/unit/test_questions_asked.gd`, 6 test.

### Misurato

Su 40 Chronicle per saga, prima → dopo:

| | CHR_01 | CHR_03 |
|---|---|---|
| Chronicle con una Truth ripetuta | 6 → **2** | 20 → **0** |
| domande distinte poste | 8 → **12** (tutte) | 5 → **7** |
| proposte distinte votate | 17 → 17 | 10 → **13** |

Il Debito della seconda saga poneva 94 volte su 94 la stessa domanda. Con
`run_playtest.gd` sugli stessi 100 semi di D-055: fallimenti 282 → 274, Consigli
per Chronicle 5,96 invariati, seggi bloccati al tavolo uniforme 4 su 8 → 3 su 8.
Il divario fra aggressivo e prudente resta dov'era — **questa non è la seconda
leva** (ISSUES 1).

---

## [0.1.21] — Un posto dove mettere l'arte vera

Il segnaposto e il brief c'erano dalla 0.1.18, e in mezzo mancava la cosa più
semplice: **un posto dove mettere l'immagine**. Niente nel codice caricava un
file per una `art_prompt_key`.

### Added

- **`art_library.gd`**: la convenzione è il nome del file — la chiave con i
  punti al posto delle barre, sotto `res://art/`. Niente manifesto, niente
  elenco da tenere allineato ([D-059](docs/DECISIONS.md#d-059)).
- Se il file c'è si disegna quello, se non c'è il segnaposto: **un'immagine che
  manca non è un errore**, ed è la proprietà che tiene il gioco giocabile con
  zero illustrazioni consegnate e con qualunque sottoinsieme.
- Vale nei tre posti insieme: la mappa e le carte sullo schermo, l'anteprima
  dietro F4, e il foglio di stampa — che la incorpora come `data:` URI, così
  resta un file solo.
- **`map.board`**: quando il tabellone dipinto esiste, la mappa smette di
  disegnare il terreno generato e ci mette sopra solo quello che il quadro non
  sa — chi tiene un posto, chi ci sta, cosa gli è successo quest'anno. Le
  posizioni delle Regioni si prendono **alla lettera** dai dati, perché è su
  quelle coordinate che il quadro è stato dipinto.
- `godot/art/README.md` dice dove va cosa: si copia il PNG al suo posto, anche
  dall'interfaccia web di GitHub, e basta.
- **Una carta con l'illustrazione vera va al vivo**: l'immagine prende tutta la
  carta e il testo ci sta sopra, su una fascia scura in basso. È come la
  ART_BIBLE descrive la carta dalla 0.0 — *«il soggetto occupa i due terzi alti;
  il terzo basso è un'area calma riservata a un overlay di testo»* — e quella
  riga ha senso solo se il testo sta sopra il dipinto. Il segnaposto generato
  resta nel riquadro: è uno schema, non un quadro. Una carta cambia
  impaginazione il giorno in cui la sua illustrazione arriva.
- **Le tessere dipinte sulla mappa** sono ritagliate dentro l'esagono e non
  appoggiate sopra: una Regione resta una Regione e non diventa un quadro con
  un bordo. Le UV sono le stesse coordinate normalizzate del piano generato, e
  una Regione consegnata convive con cinque che non lo sono ancora.

### Il build esportato è il posto dove il primo tentativo falliva

Leggere i byte del PNG fa funzionare un file appena copiato senza aprire
l'editor — nei test, nella CLI, mentre si lavora. Ma **un build esportato
impacchetta la texture importata e non il PNG originale**, quindi lì quella
strada non trova niente: il quadro spariva esattamente dove si gioca davvero.
Adesso c'è il ripiego sulla risorsa importata. (`.gdignore` più un filtro di
inclusione era il primo tentativo e non funziona: una cartella ignorata è
invisibile anche all'esportatore.)

Verificato da capo a fondo con un tabellone finto costruito sulle coordinate
vere, in un build Web esportato: i sei seggi cadono esatti sui posti dipinti. Il
finto **non è committato** — un tabellone falso nel repository sarebbe una
bugia sullo schermo.

---

## [0.1.20] — Dodici segni

La ART_BIBLE chiede overlay e icone come **grafica di sistema**, e dichiara il
vincolo che le governa: il set delle sei famiglie deve funzionare in
**monocromatico a 16 px** — se un'icona ha bisogno del colore per distinguersi
da un'altra, va ridisegnata. Non esisteva niente, e sulla mappa i quattro
livelli di tag uscivano come una colonna di parole grigie.

### Added

- **`icon_set.gd`**: dodici glifi — le sei famiglie di Asset, i quattro livelli
  della mappa (`structure`, `condition`, `settlement`, `scar`) e i due marker
  (Tensione, Echo). Stesso vocabolario di tre parole del terreno, stesso piano
  normalizzato, disegnati da Godot sullo schermo e dall'SVG in stampa — e
  **senza colori**: il colore lo decide chi chiama ([D-058](docs/DECISIONS.md#d-058)).
- **`prova_icone.svg`** esce dall'export insieme a tutto il resto: ogni glifo a
  16, 24, 32 e 64 px, scuro su chiaro e chiaro su scuro. È la prova che la
  ART_BIBLE chiede, e rigenerandosi non può invecchiare.
- Sulla mappa ogni segno ha il glifo del proprio livello accanto alla parola: il
  glifo dice *che tipo* di segno è, la parola dice quale. Sulle carte Asset — in
  mano e stampate — il glifo della famiglia sta nell'angolo in basso a destra:
  è come si ordina un mazzo di 132 carte senza leggerne una.

### Changed

- **La regola 3 della ART_BIBLE è cambiata alla prima carta consegnata**: gli
  Asset possono avere volti. Quello che separa i due mazzi non è il volto ma la
  **composizione** — l'Asset è una *scena*, la Casata un *ritratto*
  ([D-060](docs/DECISIONS.md#d-060)). La riga sta adesso dentro il MASTER PROMPT,
  quindi arriva a chi disegna attraverso `BRIEF_ARTE.md` invece di vivere in un
  documento che potrebbe non aprire mai.

- La fascia sotto il testo di una carta al vivo è una **sfumatura** e non un
  rettangolo: un bordo netto sopra un dipinto è un taglio, una sfumatura è
  un'ombra che sale dal basso. Definita una volta per foglio, in unità relative,
  quindi si adatta da sola a quanto testo ha quella carta.

### Fixed

- I segni sulle Regioni (`condition:`, `scar:`, …) finivano **in cima alla
  mappa**, uno sull'altro, invece che sotto la propria tessera: aggiungendo il
  glifo si era persa la somma con il centro sull'asse verticale. Non si vedeva a
  inizio partita, perché le Regioni cominciano senza segni — si è visto giocando
  una Chronicle intera fino in fondo. E sul quadro dipinto hanno adesso la
  stessa ombra di un pixel che porta il nome, perché un grigio su terra bruciata
  non si legge.

### Il vincolo ha cambiato due disegni

Tutt'e due li ha mostrati la prova, e nessun ragionamento li avrebbe presi:

- **FORCE era una punta di lancia**, e a 16 px una punta di lancia è il marker
  di Tensione, che è una freccia in su. Adesso è una lama con l'elsa.
- **KNOWLEDGE era un compasso**, cioè due gambe e una traversa, cioè la lettera
  A. Un glifo che si legge come una lettera non è un glifo. Adesso è un libro
  aperto.

---

## [0.1.19] — La mappa smette di essere sei cerchi

La ART_BIBLE divide il lavoro in due: l'**illustrazione** la fa una persona, la
**grafica di sistema** la fa il codice. Le tessere Regione stanno sul confine, e
questa è la metà che tocca al codice — la sagoma del terreno, il bioma che si
riconosce da lontano, il centro lasciato calmo per i segnalini.

### Added

- **`region_art.gd`**: il terreno di una Regione come **piano** in coordinate
  normalizzate — esagono irregolare più tratti in un vocabolario di tre parole —
  disegnato sia da `map_view.gd` con le primitive di Godot sia da
  `print_sheet.gd` in SVG. La tessera sullo schermo e quella che si stampa sono
  **la stessa immagine** ([D-057](docs/DECISIONS.md#d-057)).
- Sei biomi, sei vocabolari: tetti e mura per la città, campi a strisce e un
  fiume per la valle, creste con la neve su un versante per la montagna,
  imbocchi di galleria per il sottosuolo, la banda della strada con le soste,
  erba bassa e piste per la steppa. Deterministici dall'id: due Regioni dello
  stesso bioma sono diverse, la stessa Regione non cambia mai.
- La tessera stampata è **al vivo**: il terreno prende tutta la carta e il nome
  sta in basso a sinistra, dove l'esagono lascia scoperto il fondo.

### Changed

- La mappa disegna esagoni e non cerchi, con l'anello del controllo che segue la
  sagoma, e le strade sono due tratti — una banda scura e un filo chiaro —
  invece di una riga sola: i posti sono posti, non nodi di un diagramma.
- **Il raggio delle tessere cresce con lo spazio.** Era 46 pixel fissi: sei
  bolli piccoli in mezzo a uno schermo vuoto, con il terreno invisibile. E il
  riquadro delle posizioni scritte nei dati viene allungato fino a riempire la
  vista, il che sposta tutto insieme senza cambiare dove sta una Regione
  rispetto alle altre.

### Fixed

- Il disegno usciva dalla tessera — i tetti della città spuntavano sotto il
  bordo — perché i vocabolari sono scritti sul quadrato pieno e l'esagono ha un
  cerchio inscritto più piccolo. Adesso tutto rientra, e un test cammina su ogni
  punto di ogni Regione.
- Il terreno stampato era schiacciato dentro un riquadro rettangolare: una
  montagna schiacciata smette di essere una montagna. Ora disegna sempre in un
  quadrato centrato.

---

## [0.1.18] — Il gioco esce dallo schermo

**Con questa la Milestone 0.1 è chiusa**: tutti e sei i punti del §25 e tutte e
quattro le voci di chiusura. Si gioca una Chronicle intera dal browser o dal
terminale, su due saghe, si salva e si riprende — e da oggi si stampa.


La roadmap della 0.1 aveva una riga aperta: «Export Preview e placeholder d'arte
migliorati». `CardView` era arrivata con la 0.1.5, l'altra metà mai. E mancava
qualcosa di più grande di una schermata: **niente trasformava i JSON in un pezzo
fisico**. La COMPONENTS §1 dice che ECHOES è un gioco da tavolo con un'app e non
uno dei due, e fino a oggi c'era solo l'app.

### Added

- **`card_face.gd`**: cosa c'è stampato su un pezzo, detto una volta sola.
  Titolo, sottotitolo, accento, cifra d'angolo, corpo, note, chiave d'arte — e
  lo leggono sia il foglio di stampa sia l'anteprima ([D-056](docs/DECISIONS.md#d-056)).
- **`cli/run_export.gd`** + `tools/run_export.sh`: **25 fogli A4 in scala 1:1**
  con i segni di taglio (carte 63×88 mm tre per tre, tessere Regione 80×80 due
  per tre), il mazzo espanso per `deck_copies` — 48 facce Asset fanno 132 carte
  — più `brief_arte.md` e un `README.md` che spiega come si stampa. In SVG, che
  è testo: due export escono identici byte per byte e la CI li confronta.
- **`art_placeholder.gd`**: il segnaposto che la ART_BIBLE chiedeva dalla 0.0 e
  che non esisteva. Mostra in chiaro la propria `art_prompt_key`, è **diverso
  per ogni chiave** in modo deterministico, e lascia libero il terzo basso —
  cioè rispetta il vincolo di composizione che dovrà rispettare l'arte vera.
- **`art_bible.gd`**: il brief **legge** i tre MASTER PROMPT dalla ART_BIBLE e ci
  mette dentro il soggetto che solo i dati conoscono. Il prompt resta del
  documento, il soggetto resta dei dati.
- **`ui/export_preview.gd`** dietro **F4**, anche dal menu: a sinistra il foglio
  com'è impaginato, a destra la carta a grandezza leggibile, frecce per
  scorrere. Disegna passando dalla stessa `PrintSheet.layout()` che scrive
  l'SVG: un'anteprima con un'impaginazione «somigliante» non è un'anteprima.

### Fixed

- Il testo dei Destini usciva dal bordo inferiore e il titolo di `DST_LYRA` da
  quello destro. Adesso l'impaginazione è una funzione pura che restituisce
  `overflow`, e un test lo chiede a **ogni faccia del set**: ne ha trovate
  subito altre due. Quando il testo non ci sta cede l'illustrazione, non il
  corpo — l'immagine scende fino al 34% della carta prima che il testo si
  stringa di un punto.
- I colori delle sei famiglie erano scritti due volte e i nomi delle funzioni di
  Propp tre. Adesso stanno in `card_face.gd` e le viste li leggono.

- **`docs/ISSUES.md`** (§25.16): quello che resta da fare, in pezzi apribili —
  13 voci con titolo, etichette, milestone, il perché e cosa le chiude, pronte
  da incollare su GitHub. Più due template in `.github/ISSUE_TEMPLATE/`: quello
  per le regole chiede i numeri **prima** della proposta, quello per i difetti
  chiede il seme, perché con il seme si rivede lo stesso identico anno.

### Trovato

- **Le otto chiavi `entity.*` non hanno un MASTER PROMPT.** I tre della
  ART_BIBLE sono carta Asset, carta Echo e tessera Regione, e nessuno è un
  ritratto. L'export lo dice in coda, e un test tiene il numero fermo a otto
  perché non cresca in silenzio. O si scrive il quarto prompt, o si tolgono.

---

## [0.1.17] — Una condizione pagata è sostegno

Fino alla 0.1.16 dichiarare Condition voleva dire dire «sono a favore, a un
patto», spendere fino a due Asset per qualificare la clausola e spostare il
margine di **zero**: la clausola si allegava solo se la proposta passava
comunque, portata dalle carte degli altri. Contro un Oppose — tre Asset, ogni
punto che sottrae, e una carta che torna in mano quando la proposta cade — non è
una scelta difficile: è una scelta dominata. E una posizione che nessuno prende
non è una posizione.

### Changed

- **§A5, `confluence_resolution.gd`**: `M = S + C − O + W`, dove C è il totale
  del fronte Condition **solo se la clausola qualifica** (soglia 2, come nei
  dati). Una condizione non qualificata non allega niente e non sposta niente, e
  le carte sono spese lo stesso: è il prezzo del negoziato, ed è ciò che tiene
  la Condition una scelta e non uno sconto ([D-055](docs/DECISIONS.md#d-055)).
- `condition_total` e `condition_qualified` restano nel risultato: il registro,
  il tabellone e il cruscotto continuano a mostrare i tre fronti separati. È
  cambiata la matematica, non quello che se ne legge.

### Misurato

Su 100 partite a tavolo misto (D-053), gli stessi 100 semi di prima:

| | 0.1.16 | oggi |
|---|---|---|
| Consigli caduti | 315 / 603 (52%) | **282 / 596 (47%)** |
| prudente (NONE/MIN/VIC/TRI) | 0 / 82 / 14 / 4 | 0 / **74 / 22 / 4** |
| aggressivo | 0 / 29 / 63 / 8 | 0 / 30 / **61** / 9 |
| DECISIVE_SUCCESS | 95 | **128** |
| seggi bloccati su un livello | 1 su 8 | **0 su 8** |

**Non risolve la voce aperta.** Bloccare resta il seggio più forte del tavolo:
l'aggressivo chiude 61 Vittorie contro le 22 del prudente. Questa regola rende
la Condition una mossa viva e toglie cinque punti ai fallimenti; non detronizza
l'Oppose. La voce «opporsi non costa abbastanza» resta aperta sulla roadmap, e
la seconda leva — un prezzo vero sul fronte contrario — è ancora da misurare.

---

## [0.1.16] — Il cruscotto

Tutto quello che questo progetto ha imparato sul proprio gioco è arrivato da una
sonda da riga di comando, e ogni volta con la stessa forma: qualcuno guarda un
numero che nessuno stava guardando e scopre che era lì da quattro milestone. Il
costo di quel giro è che bisogna esportare, rigiocare e rileggere un file —
quindi lo si fa solo quando si sospetta già qualcosa.

### Added

- **`dev_dashboard.gd`** (§25.14): le stesse quattro tabelle **dentro la partita
  in corso**, ridisegnate a ogni fase — le domande con quanto le ha spinte il
  *mondo* e quanto il *tavolo*, la scala di ogni Destino clausola per clausola,
  i Consigli con S/O/margine, e la coda del registro degli Effect con la
  sorgente di ogni riga.
- Sta dietro **F3** e non dietro un bottone, e lo dice in rosso in cima: mostra
  anche quello che al tavolo è coperto. Nella schermata di verifica il pannello
  del giocatore dice *«Il Risveglio — velata»* e il cruscotto, nello stesso
  fotogramma, dice *«Il Risveglio 5/6»*. È esattamente ciò che serve a chi
  sviluppa ed esattamente ciò che rovina una partita.

### Fixed

- Le clausole vere erano segnate con un segno di spunta che nel font non c'è, e
  una tabella di clausole vere e false usciva come una colonna di quadratini
  vuoti. Adesso `[x]` e `[ ]`, come li scrive già il resto del gioco.

---

## [0.1.15] — Il playtest, e dove la 0.1.14 aveva torto

La D-051 aveva concluso che gli esiti si raggruppano **perché a ogni seggio c'è
lo stesso ottimizzatore**, e non per come è scritto il contenuto. Era un'ipotesi
dichiarata senza prove. Questo è l'esperimento, e dice che era **giusta a metà**.

### Added

- **`table_of_characters.gd`** — quattro modi diversi di stare allo stesso
  tavolo: *prudente* (non si oppone mai, impegna una carta in meno),
  *aggressivo* (blocca tutto quello che non lo aiuta, impegna tutto),
  *distratto* (un giro su quattro fa un'altra cosa, legale), *ostinato* (gioca
  per il Trionfo dal primo round). Nessuno bara: stessi controlli di legalità.
- **`run_playtest.gd`** — 100 Chronicle, 50 per saga, i caratteri mescolati fra i
  seggi; poi gli **stessi 100 semi** rigiocati da quattro ottimizzatori identici.
  La differenza è il tavolo, non la fortuna.

### Misurato — dove l'ipotesi reggeva

Quattro seggi che sembravano bloccati non lo erano (MINIMUM / VITTORIA /
TRIONFO):

| seggio | quattro ottimizzatori | tavolo misto |
|---|---|---|
| Le Città Libere | 0 / **49** / 0 | 21 / 29 / 0 |
| Maestra Ilve | 5 / **43** / 2 | 21 / 24 / 5 |
| Vaerax | 4 / **43** / 3 | 26 / 19 / 5 |
| Priore Anselmo | 11 / **39** / 0 | 26 / 24 / 0 |

### Misurato — dove non reggeva

Due seggi non si muovono, e l'incrocio per carattere lo dice senza appello: il
giocatore migliore del tavolo, seduto lì, supera il Minimo **una o due volte su
dieci**. Kessa dei Fuochi 48 Minimi su 50, Lyra 47 su 50, e col giocatore
aggressivo 1 Vittoria su 10 e 2 Trionfi su 10. Non è un artefatto
dell'ottimizzatore: **quei due Destini costano troppo**, e la D-051 su questo
aveva torto.

### Fixed — quello che il playtest ha detto di sistemare

- **Lyra.** La sua Vittoria chiedeva la scorta giurata *e* che le gallerie non
  fossero sigillate — l'esatta negazione della Vittoria di Vaerax, che deve
  sigillarle. Due Destini che sono l'uno il contrario dell'altro li decide
  l'ordine di parola. La posta resta a lui: Lyra passa da **47 Minimi su 50 a
  39 / 0 / 11 Trionfi**.
- **Kessa dei Fuochi.** La sua Vittoria stava tutta su `ash_watch`, che si
  ottiene da *una* proposta di *un* Consiglio: se non lo apre lei, non c'è altra
  strada. Tenere la montagna in forze si raggiunge da più Consigli; la veglia
  sale al Trionfo. E la domanda della Cenere è stata resa raggiungibile (da 1 con
  soglia 5 a 2 con soglia 4). Da **48 Minimi su 50 a 45 / 5**.

Seggi bloccati su un solo livello a tavolo misto: **da 2 su 8 a 1 su 8**. Il
tavolo di quattro ottimizzatori, sullo stesso identico contenuto, ne blocca
**4 su 8**: la differenza fra i due numeri è tutta la conclusione.

### Provato e tolto — il prezzo dell'opposizione

`CNS_FAILURE_SPIRAL` promette nella propria descrizione «con meno tempo davanti e
più rancore intorno» e negli effetti non alzava niente. Aggiungere `+1` sulla
Tensione sembrava ovvio. **Misurato, ha fatto il contrario**: i fallimenti da 302
a 322 su cento partite — si è bloccato di *più* — e quattro Chronicle su 24 sopra
il tetto del §7, con un piano scritto a mano rotto. Tolto.

Bloccare resta la strategia migliore. Non si sistema con una Conseguenza: è la
matematica del resolver del §A5, e non si tocca senza dirlo. **Resta aperta.**

### Changed — il tetto

Il tetto del §7 nel test passa da 7 a 8, con la stessa aritmetica che aveva
spostato la banda: il §7 chiede 3-4 sulle **due** Tensioni del §18.2, cioè
1,5-2,0 per Tensione, e con quattro fa **6-8**. Ha cominciato a fallire
esattamente quando le correzioni hanno rimesso in gioco due seggi. Il
**pavimento non si è mosso**.

### E due cose che nessuno stava misurando

- **Un tavolo misto scrive una storia molto più varia**: 511 Verità, **479
  diverse** (94%), contro 448 e 322 (72%) del tavolo uniforme. Stesso contenuto,
  stessi semi: la varietà era nei giocatori.
- **Opporsi non costa abbastanza.** In cento partite l'aggressivo chiude
  32/57/11 e il prudente 86/14/**0** — nemmeno un Trionfo in cento partite. E un
  solo giocatore aggressivo su quattro porta i Consigli da 149 fallimenti a
  **302 su 593**: più della metà di quello che si propone cade. È la prima
  segnalazione di bilanciamento che arriva dal guardare gente che gioca in modo
  diverso, e non un giocatore che gioca bene.

---

## [0.1.14] — La parola gira, e un anno lasciato a metà si riprende

Due voci rimaste aperte: lo squilibrio registrato come O-15, e il salvataggio che
esisteva e non lo chiamava nessuno.

### Fixed — quello che era davvero rotto in O-15

Un **Minimo** gratis è giusto: dice «sei ancora al tavolo». Una clausola che
chiede l'*assenza* di un tag è una posta, non un regalo — il Trionfo di Aldric è
3/3 vero in partenza e lo raggiunge 2 volte su 40, perché è l'anno a
portarglielo via.

Erano rotte due **Vittorie** fatte solo di poste che nessuno attaccava: quella di
Vaerax reggeva in 37-40 Chronicle su 40, e quella dell'Ordine del Vetro l'aveva
resa tale la 0.1.11 mentre sistemava altro. Adesso chiedono una cosa da ottenere
in un Consiglio — il sigillo per Vaerax, la custodia riconosciuta per l'Ordine.

### Added — la parola gira

Chi ha aperto l'ultimo Consiglio su una domanda **si fa da parte**, se c'è
qualcun altro nella Regione di cui si discute. Serviva: la classifica del
proponente è deterministica, quindi in un accoppiamento stabile la stessa casata
apriva lo stesso Consiglio in tutte e quaranta le Chronicle misurate.
L'Ordine del Vetro passa da **0 a 39** Consigli proposti; la prima saga si
appiattisce da 94/65/50/35 a 80/52/60/59.

### Added — `promise_kept` finalmente usato

Collegarlo a un Destino ha mostrato perché la riga era rimasta aperta: **la
policy non aveva mai giocato FORGE**, quindi un rapporto non si muoveva, quindi
una promessa era mantenuta gratis e non si poteva rompere. Adesso forgia quando
una clausola glielo chiede.

Ha mostrato anche cosa *non* spedire: un `promise_kept` contro un
`promise_broken` lo decide l'ordine di parola, perché rompere costa un'azione e
ricucire costa un'azione **più** il consenso dell'altro e una carta BONDS. La
promessa è quindi una posta del Trionfo della Gilda, e a prendersela viene il
Destino *avanzato* della Cenere, che esiste solo dopo una saga.

### Added — riprendere un anno a metà

`run()` riparte dall'Atto e dal round su cui il mondo si trova, e la schermata
salva alla chiusura di ogni round. Due dettagli sono tutto, ed erano sbagliati
tutti e due alla prima stesura: **il round salvato è un round finito** (sbagliare
di uno lo rigioca, e l'anno esce diverso), e **un Atto ha una fine propria** —
fermarsi sull'ultimo round e ripartire dall'Atto dopo salterebbe la carta Echo.

Il test che conta non è che il file si rilegga: è che **un anno interrotto
finisca identico a uno mai interrotto** — stessi Consigli, stessi Destini, stesso
numero di Effect, stesse ultime dodici righe. Provato in due punti, e il secondo
è sul confine fra due Atti perché è il ramo che altrimenti si mangia una carta in
silenzio.

### Verificato anche nel browser

In un build Web `user://` sta in IndexedDB, che non è garantito: in navigazione
privata la pagina accetta la scrittura e la perde. La schermata chiede
`OS.is_userfs_persistent()` e non propone la ripresa se la risposta è no.

E la prova è stata fatta, non dedotta: esportato, giocati tre round nel browser,
**ricaricata la pagina**, e il menu è tornato con *«C'è un anno lasciato a metà —
Riprendi La Carestia Rossa, atto 1 round 3»* — e premendolo l'anno è arrivato
fino all'Atto 3 round 3, Consiglio e carta Echo compresi, senza errori.

### E cosa non si è mosso

Gli esiti restano raggruppati: diversi seggi stanno a 37-40 su 40 di un livello.
Quattro giri di modifiche hanno spostato *quali* seggi, mai la forma. La causa
non è il contenuto: con un ottimizzatore deterministico a ogni seggio e un
Consiglio per domanda, il risultato dipende da se il Destino punta a un Consiglio
che quel seggio può vincere. Registrato e lasciato lì — è quello che O-14 chiedeva
fin dall'inizio: serve un tavolo di persone vere, non un altro giro di manopole.

---

## [0.1.13] — Lo schermo non sa chi siede al tavolo

La 0.1.12 ha pubblicato una seconda saga completa — quattro casate, sei domande,
sedici Destini, due Chronicle — e **dal browser non se ne raggiungeva una riga**.

La colpa era di tre costanti, e nessuna delle tre era una cosa che lo schermo
avesse motivo di sapere: la lista dei quattro seggi della prima saga in
`game_screen.gd`, la tabella dei loro nomi lì accanto, e un `match` sugli stessi
id in `map_view.gd` per i colori della mappa — che infatti restituiva grigio per
ogni casata della seconda saga, su una mappa che è le stesse sei terre. Tutto il
resto di quello schermo leggeva già i dati.

### Changed

- **Prima si sceglie l'anno, poi il seggio**: chi siede al tavolo è quello che
  dice la Chronicle, e le due saghe non hanno nessuno in comune. Il menu elenca
  tutte le Chronicle nei dati, dalla più antica, con l'anno e se le domande sono
  scritte o pescate — quindi una terza saga compare nel menu semplicemente
  esistendo.
- **I colori si assegnano per ordine di parola**, non per nome.
- **La pagina delle regole nomina le persone davvero sedute**, e si ridisegna
  quando si sceglie l'anno invece che dopo aver scelto il seggio: un passo più
  tardi descriveva ancora l'epoca che il giocatore aveva appena scartato. E dice
  quante carte tiene il mazzo Echo **di quest'anno**, che dalla 0.1.12 non è più
  il totale.

### Added

- `test_ui_knows_no_names.gd`: **nessun id di Entità compare da nessuna parte
  sotto `res://ui`**, verificato contro tutti gli id nei dati. Uno schermo che
  nomina una casata ha un'opinione su quale saga si sta giocando, e non ne ha
  diritto.

### Verificato

Non con un test — il problema era invisibile ai test e lo sarebbe rimasto.
Esportato per il web e guidato in un browser vero: il menu elenca tutte e quattro
le Chronicle, scegliendo *Le Città Libere* si siedono Maestra Ilve, Kessa dei
Fuochi, Priore Anselmo e le Città Libere, il pannello delle domande legge
l'Acqua Ferma 3/6 e il Debito 2/7, le Montagne Rosse sono cerchiate del verde
della Cenere e la Strada dei Mercanti dell'oro della Gilda, e la console non
riporta errori.

---

## [0.1.12] — Una seconda saga sulla stessa mappa

Il motore dice da sempre di essere guidato dai dati. Questa è la prima volta che
qualcuno lo verifica: una **seconda saga** — trama, personaggi, obiettivi e
domande nuovi — scritta interamente in JSON, **senza toccare una regola**.

### Added

- **Le Città Libere**, ottocento anni dopo Aldric, sulle stesse sei terre. Non
  c'è una corona e non c'è da otto secoli. Quattro seggi: la **Gilda del Sale**,
  che non possiede nessuna città e tiene il registro di tutte; l'**Ordine del
  Vetro**, erede della scuola di Lyra diventata fede, custode di un frammento che
  nessuno dei vivi ha visto; i **Signori della Cenere**, che tengono le Montagne
  Rosse e scavano ogni anno più in basso; le **Città Libere**, sette città che si
  riuniscono solo quando non possono evitarlo.
- Sei domande — l'Acqua Ferma, il Debito, la Reliquia, la Carta, i Senza Città,
  la Cenere che Sale — sei Consigli, tredici Conseguenze, sedici Destini, dodici
  carte Echo, e due Chronicle: CHR_03 scritta, CHR_04 pescata dalla biblioteca.
- **`starting_control`** sulla Chronicle: chi tiene quale Regione all'apertura.

### Fixed

- **Il mazzo Echo era uno solo per tutto il gioco**: aggiungere dodici carte
  rimescolava il mazzo della prima saga e cambiava anni che nessuno aveva
  toccato — i tre piani scritti a mano si rompevano tutti. Adesso il mazzo di una
  Chronicle si costruisce con le carte che quell'anno possono contare, e i piani
  sono tornati identici byte per byte.
- **La mappa portava il controllo della prima saga**: le Montagne Rosse
  rispondevano ancora a Vaerax in una Chronicle dove Vaerax non esiste. Non era
  un dettaglio: l'intera Vittoria dei Signori della Cenere sta su una Regione
  tenuta, e non ne tenevano nessuna.
- **Undici probe avevano i seggi scritti dentro.** Adesso li leggono dalla
  Chronicle.
- Due volte, scrivendo il contenuto nuovo, si è ripresentato **lo stesso errore
  della 0.1.11**: una clausola di Destino appesa a qualcosa che quel seggio non
  può ottenere. La prima volta perché la Conseguenza stava su un Consiglio che
  non si tiene mai; la seconda perché due seggi avevano bisogno dello stesso
  Consiglio e a proporlo è uno solo. Le ha trovate entrambe la terza tabella
  della sonda dei Destini — *quali Consigli un seggio riesce davvero a proporre*.

### Misurato

CHR_03 su quaranta semi: 6,55 Consigli per Chronicle, mediana 7, da 5 a 7 — la
stessa forma di CHR_01 e dentro i limiti del §7. Ogni seggio vince qualche volta.

Due saghe da dieci Chronicle giocate per intero: la prima copre **999 anni** e
scrive **35 Verità, tutte e 35 diverse**; la seconda copre **753 anni** e ne
scrive 38, tutte diverse. L'audit da cui è partita questa serie di lavori ne
produsse 12 distinte su 28.

---

## [0.1.11] — Un Destino che si vince in due mosse, e uno che non si vince mai

Il seggio degli studiosi era rotto ai due capi di una saga, e nessuno dei due si
vedeva guardando gli esiti.

**Vinto al round due, quaranta volte su quaranta.** Il Destino di Lyra chiedeva
sette clausole, e **cinque erano già vere prima che venisse messo il primo
segnalino**. Le altre due erano Scoperte — e una Scoperta costa *un'azione*:
SCHEME su una Tensione velata. Lyra ha due Azioni nel primo round, e CHR_01 di
Tensioni velate ne distribuisce due. Risultato: tutta la sua scala — Minimo,
Vittoria *e* Trionfo — chiusa nell'**Atto I round due, 40 Chronicle su 40**, e le
altre diciassette Azioni spese a comprare carte che non le servivano. Il
rapporto di fine anno diceva TRIONFO; il registro diceva diciotto turni di
shopping.

**E mai vinto.** `DST_LYRA_TAUGHT` — il Destino a cui *avanza* fra una Chronicle
e l'altra — chiedeva nel Trionfo `crystal_measured`, `petition_heard` e
`parley_held`: **nessuna Consequence del gioco scrive nessuno dei tre**. Non era
difficile, era impossibile, ed è per questo che nella saga quel seggio risultava
MINIMO dieci volte su dieci.

### Added

- **`run_destiny_probe.gd`**: fa le due domande che rendono visibile tutto
  questo, e la prima non ha bisogno di dadi — **cosa è già vero prima che l'anno
  cominci**, clausola per clausola, e **a che round la scala di ogni seggio è già
  tutta chiusa**. Più: quali Consigli ogni seggio riesce davvero a proporre e
  quali tag finisce per indossare, perché «una Consequence scrive questo tag» e
  «questo seggio può ottenerlo» non sono la stessa domanda.
- Un controllo al boot: ogni clausola `state_tag_present` di ogni Destino deve
  chiedere un tag che qualcosa al mondo può scrivere. Un tag è una stringa —
  valida, si carica, ed è falsa per sempre.

### Changed

- **Il Destino di Lyra**, due clausole aggiunte e nessuna tolta. La Vittoria
  chiede ora la **scorta giurata**: dodici persone che rispondono di ogni carico
  col proprio nome, e si ottiene solo in un Consiglio. È la metà del titolo che
  non era mai stata implementata — *poter tornare a guardare*. Sapere qualcosa è
  il Minimo; poterci tornare è la Vittoria. Il Trionfo chiede in più che nessuno
  abbia messo **una guardia allo studio**.
- Il Trionfo di `DST_LYRA_TAUGHT` riscritto su tag che esistono, tenendo il
  senso: *quello che resta insegnato* è il sapere che gli altri possono ancora
  raggiungere e verificare — gallerie non sigillate, scorta giurata, nessun
  custode.
- La descrizione del piano C diceva che l'anno finiva col sapere «pubblico e
  verificabile». Quello che il piano gioca è `P_GUARDED_STUDY`: il Cristallo si
  può misurare, ma davanti a un custode. Col nuovo prezzo è esattamente ciò che
  a Lyra non basta, ed è un finale migliore di quello che il testo dichiarava.

### Misurato

| | prima | dopo |
|---|---|---|
| scala chiusa in anticipo (Lyra) | **40/40**, round 2,0 | 9/40, round 7,0 |
| Lyra | MIN 16 / VIT 4 / **TRI 20** | **MIN 34** / TRI 6 |
| Consigli CHR_01 | 5,70 | 6,10 |
| Consigli CHR_02 | 4,65, da 2 a 7 | 4,83, da 3 a 6 |

Una terza clausola è stata provata e tolta: `discovery:crystal` sul Trionfo, «e
il Cristallo lo ha misurato lei». Si legge bene e si misura male — Trionfo a
0/40 e Consigli fuori banda a 6,20 — quindi resta scritta nelle decisioni,
non nei dati.

**Cosa ha fatto emergere.** Sei livelli di Destino su dodici sono veri prima che
qualcuno giochi. Non tutti sono sbagliati: una clausola che chiede l'*assenza* di
un tag è una posta, non un regalo, e il Trionfo di Aldric è 3/3 gratis in
partenza e lo raggiunge lo stesso solo 3 volte su 40, perché è l'anno a
portarglielo via. Vaerax no: la sua Vittoria sono due tag assenti e basta, e la
prende in 37-40 Chronicle su 40 — in CHR_02, **40 su 40**. Registrato, non
ritoccato: questo giro ha già spostato un seggio dal primo all'ultimo posto, e
spostarne due insieme non si misurerebbe.

---

## [0.1.10] — Un anno non si chiude senza aver deciso niente

Una saga da dieci Chronicle ha prodotto **tre anni con zero Consigli**. Non anni
tranquilli: anni in cui nessuno ha proposto niente, non si è deciso niente e il
registro è rimasto in bianco. Il §7 chiede una segnalazione sotto i due.

La prima ipotesi — che fosse l'eredità fra una Chronicle e l'altra a spegnere le
Tensioni — era sbagliata, e a smentirla è stato lo strumento nuovo: contare gli
*esiti* dice che un anno è stato quieto, contare le **spinte** dice perché.

### Added

- **`run_silence_probe.gd`**: per ogni Chronicle stampa, per ogni domanda in
  gioco, da dove parte, quanti colpi le ha dato il **mondo**, quanti gliene ha
  dati il **tavolo** e dove finisce rispetto alla soglia; poi, per ogni seggio,
  il Destino che porta e cosa quel Destino gli chiede davvero di spingere.
- **`minimum_confluences`**: la Chronicle dichiara quanti Consigli garantisce.
  Quando un Atto si chiude e l'anno è ancora sotto quota, la domanda arrivata più
  vicina viene portata al punto — «L'anno non si chiude con la domanda ancora
  aperta». La quota cresce con l'Atto (`floor * atto / atti`), perché per il §7
  si apre un solo Consiglio per round e un pavimento di due controllato solo alla
  fine potrebbe consegnarne uno soltanto. La spinta è un Effect come tutti gli
  altri, con sorgente `YEAR_END` e il suo inverso; `0` lo spegne.

### Fixed

- **Il mondo da solo non può portare nessuna domanda al punto.** Il Drift dà un
  colpo per round diviso fra tutte le domande in gioco — nove colpi su quattro
  domande — mentre il salto più corto fra valore iniziale e soglia è tre. Il
  mondo può lasciare corte tutte le domande insieme, e negli anni muti è successo:
  quella arrivata più vicina si è fermata **a un colpo dalla soglia**, tre volte
  su tre. Ogni Consiglio ha bisogno che qualcuno spinga.
- **E il tavolo aveva smesso di giocare**: negli anni muti tre seggi su quattro
  hanno speso **tutte e diciotto le Azioni in ACQUIRE**, comprando carte per un
  Consiglio che non si sarebbe mai aperto.
- **Un seggio si fermava appena il gradino più vicino non gli chiedeva niente.**
  La policy giocava solo il gradino più basso non ancora conquistato: giusto
  sull'ordine, sbagliato su dove fermarsi. Un gradino può essere aperto e non
  chiedere niente alle Tensioni («stare sulle Montagne Rosse» si risolve
  camminando), e uno fatto di sole clausole negative non chiede niente a nessuno.
  Adesso si arriva al primo gradino che qualcosa chiede.

### Misurato

Quaranta semi per Chronicle. CHR_01 **non cambia** (media 5,70, mediana 6, da 3 a
8). CHR_02 passa da media 4,17 con minimo **1** a media 4,65, mediana 5, minimo
**2**, 0/40 sotto il pavimento del §7. Su quattro saghe da dieci Chronicle non
c'è più un solo anno muto. Il tavolo che sopprime e basta — quattro seggi che
spendono ogni azione per tenere giù ogni domanda — passa da 1,75 Consigli per
Chronicle a 2,48: è la prima volta che sta sopra il pavimento del §7 invece che
sotto. I tre piani di simulazione passano e restano identici
byte per byte.

---

## [0.1.9] — Una casa non finisce i nomi

La 0.1.8 dava a ogni seggio mortale quattro successori scritti a mano. Il primo
audit da dieci Chronicle li ha esauriti al sesto salto e ha rimesso a sedere un
**secondo «Re Serane» quattrocento anni dopo il primo**, con addosso la
descrizione del primo: nel 1240 risultava nipote di Aldric. Sembrava un errore,
ed era un errore — una saga non ha un numero di generazioni deciso in anticipo,
quindi qualunque lista finita finisce.

### Added

- **`name_grammar`**: una casa dichiara *come* fa i nomi invece di elencarli —
  un pattern con fessure (`{given} {epithet} {ordinal}`), un sacchetto di nomi,
  i titoli. Le prime generazioni restano scritte a mano, perché sono quelle
  caratterizzate; la grammatica subentra dalla quinta.
- **La numerazione** è quello che lo rende infinito *e* giusto: le case i nomi se
  li ripassano davvero, ed è esattamente per questo che li numerano. Vharn, e
  quattro generazioni dopo Vharn II. Trenta generazioni, trenta nomi distinti,
  con un test che lo pretende.
- Il nome è una **funzione pura della generazione**: nessun RNG, quindi è stabile
  a prescindere da quando lo si chiede e la saga resta rigiocabile dal seme.

### Fixed

- Il primo tentativo pescava dalla stessa lista dei quattro scritti a mano, e
  quindi la generazione 5 era di nuovo «Re Serane»: lo stesso errore, un giro
  più in là. E i titoli giravano indipendentemente dai nomi, producendo «Re
  Ottima» e «Regina Corvin». Adesso il titolo sta attaccato al nome.

---

## [0.1.8] — Fra una Chronicle e l'altra passano secoli

Un audit di dieci Chronicle ha prodotto un registro di 28 Verità con **12 frasi
diverse**, e la più frequente era *«la corona fu divisa in due»* — **sei volte in
dieci anni**. Una corona non si divide sei volte. Succedeva perché il motore
aggiungeva un anno e rimetteva a sedere le stesse quattro persone con la stessa
domanda ancora aperta.

### L'id è il seggio, non la persona

`ENT_ALDRIC` è la casa che tiene Eredan. **Chi siede sulla sedia** — nome,
Destino, generazione — è stato del mondo e cambia da una Chronicle all'altra.
Tenere fermo l'id è ciò che permette a ogni Cicatrice, tag e controllo scritti
prima di continuare a puntare a qualcosa che esiste ancora.

Chi sopravvive a un salto è scritto nei dati: `persistence` è **MORTAL** (una
persona), **COLLECTIVE** (un popolo, che cambia senza finire) o **ETERNAL**
(qualcosa sotto una montagna). Un seggio mortale che attraversa 25 anni o più
prende un nome nuovo dalla propria lista di successori — Re Serane, Re Corvin,
Regina Isaura, Mira la Cartografa.

### Il salto lo dichiara la Chronicle

`years_after_previous`: un numero, o un intervallo pescato dal seme. `CHR_01` è
l'anno scritto e dice 1. `CHR_02`, quella che si pesca le domande da sola, dice
**20-200**: una saga di Chronicle di biblioteca copre secoli, e li copre in modo
riproducibile.

### Le tre eredità, ognuna con la sua condizione

- **La posizione, sempre.** La mappa è il mondo e il mondo non riparte da capo.
- **I rapporti, ma il tempo li smussa.** Oltre i 50 anni ogni rapporto si sposta
  di un passo verso NEUTRAL: una guerra si ricorda come un rancore, un'alleanza
  come una cortesia. I tag restano comunque: quelli erano scritti.
- **Il Destino, ma solo di chi ha fallito.** Chi ha raggiunto VICTORY o TRIUMPH
  pesca la cosa dopo dal proprio `destiny_pool`; chi è rimasto al MINIMUM
  riprova con lo stesso obiettivo. È questa la regola che tiene viva una domanda
  attraverso le generazioni invece che attraverso le primavere.

Otto Destini adesso, due per seggio: quello con cui comincia e quello che vuole
dopo averlo ottenuto.

### Misurato, sugli stessi dieci semi

| | prima | dopo |
|---|---|---|
| anni coperti | 812 → 821 | 812 → **1767** |
| frasi distinte nel registro | 12 su 28 | **19 su 24** |
| la frase più ripetuta | **6 volte** | 3 volte |
| persone sedute al tavolo | 4 | **12** |

I tre piani di simulazione escono **riga per riga identici**: una Chronicle sola
non ha nessun salto da fare. Quello che è cambiato è `world.entities`, che ora
porta nome, Destino e generazione.

---

## [0.1.7] — Le carte di Propp esistono anche sullo schermo

C'erano due mazzi e se ne vedeva uno solo. Le 48 carte Asset sono tue: le peschi,
le tieni, le spendi, e dalla 0.1.5 dicono cosa fanno. Le **24 carte Echo** — una
per ogni funzione di Propp, in quattro famiglie drammatiche da sei — non le pesca
nessuno: **ne esce una alla fine di ogni Atto**, dal mazzo che quell'Atto ammette
(il primo solo *pressione*, l'ultimo soprattutto *risoluzione*). Muovono il mondo
da sole, due di loro **convocano un Consiglio sul posto**, e ognuna scrive nel
mondo la funzione che ha appena svolto, così che una carta successiva possa
richiederla: un Ritorno ha bisogno di una Separazione da cui tornare.

Sullo schermo erano un paragrafo che scorreva via nel transcript.

### Added

- **`ui/echo_card_view.gd`** — la carta prende il centro dello schermo, col
  colore della sua famiglia, il suo testo, la funzione di Propp in italiano, e
  **cosa ha appena cambiato**. Resta lì finché non premi Avanti. Tre volte per
  Chronicle, nei tre momenti in cui la storia gira.
- **`act_echo_drawn`** sul controller: la carta e gli Effect che ha applicato.
  Nessuno nel motore lo ascolta — esiste perché lo schermo possa dire cosa la
  carta *ha fatto*, non solo cosa dice. C'è un test che gioca una Chronicle
  intera e pretende tre carte, ognuna con almeno un Effect, ognuno dicibile.
- **`scripts/core/effect_text.gd`** — un Effect in una riga italiana: «La
  Successione sale di 2», «Eredan: condition:contested», «Cicatrice in Valle
  Verde: …». I tipi che non conosce si dichiarano per nome invece di tacere.
- La pagina «Come si gioca» adesso spiega anche questo mazzo.

---

## [0.1.6] — La seconda Chronicle, e il mondo che puoi rigiocare

### Added

- **`CHR_02` si gioca nel browser.** Esisteva dalla D-028 ed è il senso del
  modello a biblioteca: non elenca le proprie domande, **ne pesca quattro fra
  sei**, quindi due partite non sono lo stesso anno. Dalla riga di comando si
  poteva già (`--chronicle=CHR_02`); nel browser `CHR_01` era scritto dentro il
  codice.
- **Il seme si sceglie.** «Un mondo a caso», «Rigioca il seme *N*» (quello
  dell'ultima partita) oppure lo scrivi tu. Il seme viene stampato in cima a
  ogni Chronicle dalla 0.0 proprio perché un anno che vale la pena raccontare si
  possa rigiocare — e fino a ieri non c'era nessun posto dove riscriverlo.
- **I rapporti fra le Entità**, sotto le domande dell'anno: tre righe, colorate
  lungo la scala da `enemy` a `bound`. Erano informazione pubblica che il
  browser non mostrava — si leggeva solo dentro un bottone che si offriva di
  romperli — e i Destini li contano: chi non li vede viene giudicato su qualcosa
  di invisibile.
- La pagina delle regole si riscrive per l'anno scelto. E la stessa cosa ha
  trovato un errore che sarebbe scoppiato in faccia a chi sceglie `CHR_02`:
  leggeva `chronicle["tensions"]`, che una Chronicle a biblioteca non ha. Adesso
  legge il pool e lo dice: *questa Chronicle ne pesca 4 fra queste*.

---

## [0.1.5] — Le carte dicono cosa fanno

Due buchi rimasti dalla 0.1, uguali fra loro: le regole davano qualcosa a chi
gioca e il gioco se lo teneva.

### Added

- **Il recupero dopo una sconfitta adesso lo scegli tu.** Il §12.3 dice che
  quando una proposta cade, chi si era opposto **si riprende una delle carte che
  aveva messo giù**. Era l'unica decisione delle regole che nessun giocatore
  veniva mai chiamato a prendere: la faceva la policy, prendendo la più forte.
  Si chiede dove la chiedono le regole, cioè **prima del tiro** — «se la proposta
  cade, quale carta ti riprendi?» — e solo quando c'è davvero da scegliere: chi
  non si è opposto non recupera niente, una carta che per sua regola non torna
  mai non viene offerta, e una carta sola non è una scelta.
- **`scripts/core/asset_text.gd`** — una carta detta in una riga, la stessa per
  il terminale e per il browser: il bonus nei termini in cui il resolver lo
  applica (`+2 se ti opponi`, non `+2`), cosa succede alla carta dopo, e cosa
  costa impegnarla. Ogni pezzo è costruito dai campi che la risoluzione legge
  davvero, quindi una carta non può dire una cosa e farne un'altra.
- **In Consiglio le carte da impegnare lo dicono**: «Interdetto — authority,
  vale 3 · si scarta comunque · costa: la domanda in gioco sale». E nella mano,
  fermando il cursore su una carta, compare tutto: cosa vale, cosa le succede,
  cosa costa, e la riga che le ha scritto l'autore.

### Fixed

- **La mano si calcolava il valore da sola** — `forza se rilevante, 1 altrimenti`
  — ignorando il `confluence_modifier`. I Mercenari (forza 1, +1 sempre) valgono
  2 e la carta diceva 1. Adesso chiama `ConfluenceResolution.asset_value`, la
  funzione del resolver: il numero sulla carta è il numero che entra nella
  somma. È la seconda volta quest'anno che una mano mostra un valore che la
  risoluzione non darebbe (D-040); è l'ultima possibile, perché non c'è più un
  posto dove ricalcolarlo.
- Il tooltip è disegnato invece che lasciato al default: quello di Godot non va
  a capo, e una carta con una riga da 130 caratteri si dipingeva addosso alla
  mano.

---

## [0.1.4] — Il gioco spiega se stesso

Fino a ieri si apriva la pagina, si sceglieva un seggio e ci si trovava davanti
quattordici bottoni. Le regole c'erano — in `docs/RULES_V0_2.md`, cioè esattamente
dove chi si siede a giocare non guarderà mai.

### Added

- **`ui/help_panel.gd` — una pagina «Come si gioca»** che prende il centro dello
  schermo: la forma dell'anno, le sei cose che può fare un'azione, le domande di
  quest'anno con soglia e famiglie che ascoltano, cosa succede in un Consiglio,
  e come si vince. Si apre da sola al menu, si toglie di mezzo quando comincia
  la Chronicle, e resta a un bottone di distanza per tutto l'anno.
- **Metà della pagina è scritta dai dati**, non battuta a mano: gli Atti, i
  round, le azioni per round, il limite di mano, quante carte si impegnano, le
  quattro Tensioni con le loro soglie, le sei Regioni. Una pagina di regole che
  può andare fuori sincrono con le regole è peggio di niente.
- **Una riga di contesto sopra le scelte**, che spiega *questo turno*:
  «La Carestia è a un passo dalla soglia: un'altra spinta e si apre il
  Consiglio», «Consiglio aperto: qui valgono forza piena le carte wealth,
  people, authority». Legge solo quello che il tuo seggio ha diritto di leggere:
  di una domanda velata dice che c'è, non quanto vale.

---

## [0.1.3] — Le 48 carte

Il traguardo §19.4 sugli Asset: da 12 carte a **48**, otto per famiglia.

### Added

- **36 nuove carte Asset.** Una parola sola — la rarità — dice tutto quello che
  serve sapere: **comune** = forza 1, 4 copie · **non comune** = forza 2, 2
  copie · **rara** = forza 3, 1 copia. Sono 22 carte per mazzo di famiglia, 132
  in tutto.
- **Ogni famiglia sa dire di no.** Due carte per famiglia pagano sul fronte
  Oppose, e una vale di più quando la domanda è la sua. Prima erano quattro
  carte in tutto il gioco.
- **Le carte da 3 costano.** Il Vecchio Esercito, Le Porte Bruciate, l'Atto di
  Successione, l'Esodo, il Cristallo Rosso, l'Ipoteca sulle Terre, l'Ostaggio,
  il Patto Rotto e le altre: si scartano comunque, e impegnarle fa qualcosa al
  mondo — alza la Tensione, o mette il tuo rivale dove si sta discutendo, o ti
  toglie da lì. Una carta che vale 6 senza contropartita non è una scelta, è la
  mossa giusta.
- `on_commit_effects` era esercitato da una carta sola nella 0.0 (O-3). Adesso
  sono tredici.
- **`cli/run_margin_probe.gd`** — la sonda che ha trovato il problema qui sotto:
  stampa S, O e la distribuzione di M, non solo il conteggio degli esiti.

### La tabella degli esiti si è rotta, e la media non lo diceva

Con le 48 carte al primo tentativo, sulle stesse 40 Chronicle: **Decisivo dal
33% al 49%**, con metà dei Consigli che passano senza discussione. E la media
del margine era **identica** (3.23 → 3.37).

Quattro tentativi di aggiustarlo cambiando i pesi non hanno spostato niente,
perché miravano alla media. La distribuzione ha mostrato la causa in un colpo:
con due carte per famiglia un impegno era quasi sempre 2+2, e il set da 12
ammucchiava tutto su **M = +4**, un punto sotto la banda Decisiva. Una biblioteca
più ampia liscia la distribuzione e sposta quel mucchio di un punto — oltre la
riga.

La cura è stata la **curva**, non i pesi: la rilevanza è scesa dalle carte da 2 a
una carta da 1 per famiglia, e una carta da 2 per famiglia è diventata una da 1.
Un impegno preparato torna a valere 4 invece di 6.

| | Failure | con Costo | Successo | Decisivo |
|---|---|---|---|---|
| 12 carte | 16% | 13% | 38% | 33% |
| 48 carte | **21%** | 15% | 30% | **34%** |

Il resolver non è stato toccato: §A5 è la specifica, il contenuto è quello che si
tara (D-023, D-040).

### Fixed

- **La mano dichiarava un ×2 che la regola non ha.** Dalla 0.1.1 una carta
  rilevante veniva disegnata come `authority · 2 ×2 = 4`. Il §9 dice che un Asset
  vale la sua **forza piena** se la famiglia è rilevante e **1** altrimenti: la
  rilevanza non raddoppia niente. Adesso la carta dice `authority · vale 2`, e
  `vale 1` quando la domanda non è la sua.

### Il prezzo, detto

- **Consigli per Chronicle: mediana da 5 a 6**, e una partita su quaranta arriva
  a 8 contro il tetto di 7 del §7. Il test di bilanciamento passa (tollera il
  10% fuori banda), ma la deriva è vera ed è il numero da guardare nella 0.2.
- **I tre piani di simulazione escono diversi** e sono stati **rimisurati**, non
  ritoccati: le tre storie tengono ancora, le sequenze di esito no.

---

## [0.1.2] — La mappa si preme, e il Consiglio dice cosa costa

Le due cose che nella 0.1 restavano a meta: una mappa che si guardava e basta, e
una plancia con un buco in mezzo.

### Si gioca sulla mappa

- **Le mosse si scelgono premendo una Regione.** Le Regioni raggiungibili sono
  cerchiate d'oro, si illuminano sotto il cursore e il puntatore diventa una
  mano; le altre non reagiscono, perche una Regione che si accende e poi non fa
  niente sembra un gioco rotto. Il bottone «Metti una presenza in…» sparisce
  dalla colonna: erano fino a sei voci su quattordici.
- **La legalita non si sposta sulla mappa.** `SeatDecider` dice *di cosa parla*
  ogni scelta (`{"region": "REG_X"}` su una mossa) e la mappa riceve l'insieme
  gia filtrato dalle regole: disegna, non giudica. Il terminale riceve lo stesso
  dato e lo ignora — una lista numerata e gia tutta la mappa che ha (D-039).

### Il momento in cui il gioco decide qualcosa

- **La plancia si ferma sul Consiglio appena chiuso** finche non premi Avanti.
  `resolve()` esegue F-K in un passo solo e si azzera alla fine: il tiro, la
  somma e le conseguenze non erano mai stati su schermo per un frame — nemmeno la
  riga `Fattore Mondo` aggiunta nella 0.1.1.
- **Il conto in chiaro**: `S 6 · O 7 · Mondo +0 -> M -1 — Respinta`.

### Cosa metti in gioco quando dici «sostengo»

- **Al centro della plancia adesso ci sono le Conseguenze**: prima del voto quelle
  che la proposta scriverebbe sul mondo, dopo il voto quelle che ci ha scritto
  davvero. Ognuna col suo titolo, la sua riga di testo, e **«lascia una
  Cicatrice»** quando e il caso. Fino a ieri l'unico modo di scoprirlo era
  perdere e leggere il log.
- Il motore riporta le Conseguenze applicate (`result["consequence_ids"]`) invece
  di farle ridedurre allo schermo: quale pool si applica dipende dall'esito, e
  riscriverlo nella UI sarebbe l'ordine di risoluzione scritto due volte.

### Fixed

- La freccia di `1d6 = 6 → +2` era un quadratino vuoto nel font di fallback del
  build Web, proprio nella riga che serve a rifare il conto. Ora e `->`.

Il motore resta byte-identico: le tre sim escono uguali carattere per carattere.

---

## [0.1.1] — La plancia del Consiglio

Il momento in cui il gioco decide qualcosa adesso sembra tale.

### Added

- **`ui/confluence_board.gd`** — quando un Consiglio si apre, prende il centro
  dello schermo al posto della mappa. In alto la Tensione e chi propone, poi la
  domanda in grande, poi la proposta. Sotto, i quattro seggi in colonna: il
  proponente marcato, gli altri con `…` finche non parlano, e la loro posizione
  colorata quando arriva — verde chi sostiene, rosso chi si oppone, ambra chi
  pone una condizione.
- **Gli impegni restano vuoti fino al passo E.** Quello che qualcuno ha messo giu
  non e pubblico finche non e pubblico: la colonna si riempie tutta insieme, alla
  rivelazione simultanea, com'e nelle regole (§12.2 E).
- **Le scelte stanno dentro il Consiglio**, come carte accanto alla domanda a cui
  rispondono, invece che nella colonna laterale dove vivono le azioni. Stesse
  etichette, stesso contratto, posto diverso sullo schermo.
- **Il Fattore Mondo in chiaro** una volta tirato: `1d6 = 6 → +2`. §12.2 G e il
  momento in cui il gioco decide, e chi gioca deve poter rifare il conto.

### La mano cambia significato

Con un Consiglio aperto le carte rilevanti passano da `authority · 2` a
`authority · 2 ×2 = 4`. E il numero che entra davvero nella somma, e compare nel
momento in cui compare la domanda.

### La cucitura, di nuovo

La plancia legge `session.confluence.current` — lo stesso dizionario che rende il
log e che il terminale stampava nella 0.0 — e non decide niente. Le scelte
arrivano come `ask(prompt, labels)` gia formattate da SeatDecider, e vengono
disegnate come carte: **la plancia non sa se sta mostrando proposte, posizioni o
Asset**, e non deve saperlo. E quello che impedisce a browser e terminale di
offrire opzioni diverse.

Il motore resta byte-identico a prima di tutta la UI.

---

## [0.1.0] — Un tabellone, non un resoconto

La milestone 0.1 comincia da dove serviva: chi apre la pagina vede una **mappa**,
non un muro di log.

### Added

- **`ui/map_view.gd`** — le sei Regioni, le strade fra loro, e chi sta dove. I
  token di presenza sono punti colorati per Entita, l'anello attorno alla Regione
  e chi la controlla (niente anello = nessuno, che e un fatto da vedere, non un
  vuoto), e sotto il nome compaiono condizioni, strutture e **Scar in rosso** —
  l'unico segno che non viene mai via.
- **`ui/status_panel.gd`** — le domande dell'anno come tracciati con soglia, che
  virano all'ambra a un passo dal limite e al rosso quando lo superano. Una
  Tensione velata mostra una barra vuota e la parola *velata*: presente,
  illeggibile, e chiaramente li. E la scala del Destino, con le caselle gia
  spuntate.
- **`ui/hand_view.gd`** — la mano come carte, con il colore della famiglia. Quando
  un Consiglio e aperto, una carta rilevante scrive il numero che entra davvero
  nella somma (`authority · 2 ×2 = 4`) invece di quello stampato con una nota.
- **`map_position`** nello schema delle Regioni: coordinate normalizzate 0..1,
  autorate e non calcolate. Un algoritmo di layout disegna un'immagine corretta
  dell'adiacenza e sbagliata del mondo, perche non sa che le montagne stanno a
  ovest e che la valle nutre la citta.

### La cucitura ha retto

Nessuno dei tre nodi conosce una regola o puo raggiungere un decisore: prendono
`(session, viewer_id)` e disegnano quello che **quel seggio** ha diritto di
vedere — la stessa regola di §11.1 che segue il terminale, applicata ai pixel.
Il motore non e stato toccato: i tre piani di simulazione escono byte per byte
identici a prima della UI.

### Fixed

- Le spunte del Destino uscivano come quadratini: il font di fallback di una
  build Web non ha il segno di spunta, e un glifo mancante si legge come un bug
  del gioco invece che come un buco nel font. Ora e ASCII.

---

## [0.0.14] — La Chronicle sa aspettare un click

ECHOES gira in un browser, su GitHub Pages, da `godot/ui/`.

### Changed

- **`ChronicleController.run()` e una coroutine.** Un terminale puo bloccarsi su
  stdin dentro una chiamata sincrona; un browser non puo bloccarsi su un click
  senza congelare la pagina e non riceverlo mai. Le sei chiamate al decider sono
  `await`, e `run()` / `play_act()` / `play_round()` / `run_confluence()` sono
  coroutine. **Nient'altro e cambiato**: un decider che risponde subito non
  sospende mai, e la prova e che i tre piani di simulazione escono **byte per
  byte identici** a prima, e cosi tutte e sei le sonde.

- **`scripts/seat/seat_decider.gd`** — quello che un seggio vede e puo fare, con
  l'I/O **iniettato** invece che ereditato: un oggetto qualsiasi con `say(text)` e
  `choose(prompt, labels) -> int`. `cli/terminal_io.gd` lo implementa su stdin e
  stdout, `ui/game_screen.gd` lo *e* per il browser. Cosi le due interfacce non
  possono litigare su quali azioni siano legali: e lo stesso decider.
  `policy_decider.gd` si sposta da `cli/` a `scripts/seat/` — e l'avversario, e
  nel browser serve.

### Added

- **`godot/ui/`** — un resoconto e una colonna di bottoni. Non e la mappa, non e
  la plancia della Confluence: quello e il lavoro della 0.1. E la cucitura che
  regge — lo schermo non decide niente e non legge le regole.
- **`.github/workflows/pages.yml`** — export Web e pubblicazione su Pages a ogni
  push su `main`. Single-thread di proposito: la build con i thread richiede
  `SharedArrayBuffer`, che richiede header COOP/COEP, che Pages non puo mandare.

### Fixed

Tre bug che **solo il browser** ha trovato. Playwright ha caricato la pagina
esportata e ha giocato una Chronicle a click. Ognuno di questi era passato prima
attraverso tutti i controlli headless:

- Il decider del browser ereditava da `cli/human_decider.gd`, e `cli/*` e escluso
  dall'export: script irrisolvibile, pagina bianca. `extends "res://path.gd"` non
  sopravvive all'export, `preload` si — che e esattamente il motivo per cui
  questo progetto usa `const X := preload(...)` e niente `class_name`.
- `scripts/seat/` mancava del tutto dal pacchetto: l'export era girato prima che
  la cache di import vedesse la cartella nuova. Il workflow ora importa prima.
- `policy_decider.gd` stava in `cli/`.

Nessuno dei tre e esotico, e nessuno sarebbe stato preso da qualcosa di meno che
aprire la pagina. **Una build che compila ed esporta non e una build che gira.**

---

## [0.0.13] — Il quinto decisore e una persona

### Added

- **`cli/run_hotseat.gd` + `cli/human_decider.gd`** — ECHOES si gioca alla
  tastiera. Il tabellone si stampa dal punto di vista di un seggio: le domande
  dell'anno con i numeri che *quel* seggio puo vedere (una Tensione velata non
  mostra niente a chi non l'ha esplorata, §11.1), la mappa, la mano, e il Destino
  come una scala con le caselle gia spuntate. Il menu delle azioni lo costruisce
  il resolver: ogni voce ha gia passato `can_execute`, quindi non ti viene mai
  offerto qualcosa che le regole poi rifiutano.

  `--seats=all` per quattro giocatori, `--seats=ENT_NAHR` per uno solo contro tre
  policy. **Nessuna regola e stata trattata in modo speciale**: il
  ChronicleController chiede a un `decider` e applica quello che torna, come ha
  sempre fatto. La cucitura scelta nella 0.0.1 ha retto senza toccare una riga
  del controller.

- **`tools/play.sh`** — `tools/play.sh --seats=all` e via. Trova Godot da solo
  (`$GODOT`, poi il PATH, poi un binario lasciato accanto al progetto) e se non
  lo trova spiega dove prenderlo invece di fallire con un comando non trovato.
  Avverte anche quando stdin non e un terminale, perche in quel caso ogni scelta
  senza risposta la prende la policy — legittimo per pipare un file di risposte,
  sorprendente se ci sei arrivato per sbaglio.

- **`tests/smoke/test_hotseat.gd`** — un tavolo di quattro "umani" che non
  rispondono niente deve produrre una Chronicle **identica riga per riga** a una
  giocata da quattro policy, e ogni azione che il menu offre dev'essere una che
  il resolver accetta.

### Fixed

- **La stringa vuota che chiudeva fuori i giocatori.**
  `OS.read_string_from_stdin` restituisce **la stessa stringa vuota** per un
  Invio a vuoto e per la fine dell'input: misurato, non supposto. La prima
  versione ci provava lo stesso e si spegneva alla prima lettura vuota — cosi
  **chi accettava un solo default restava chiuso fuori dalla propria partita**,
  in silenzio, senza che niente andasse in errore. Ora vuoto vuol dire "decidi
  tu", che e anche il comportamento giusto a fine input.

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
