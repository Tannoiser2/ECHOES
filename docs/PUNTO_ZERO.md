# PUNTO ZERO — dov'è ECHOES, misurato

**Versione 0.1.382** · rimisurato per intero in 0.1.349, le sonde rilanciate in
0.1.353. **Le sezioni 1, 2, 5 e 6 sono state rimisurate** in 0.1.379, 0.1.380 e
0.1.382; le sezioni 3, 4, 7 e 8 portano ancora i numeri del 0.1.353, ed e' detto
dove.

Questo documento non racconta cosa il gioco vuole essere. Dice **cosa fa oggi,
con i numeri**, e cosa è ancora aperto. È il foglio contro cui si decide: se una
voce qui sotto non ti torna, quella è la prima cosa da cambiare.

Tutti i numeri sono su **100 anni pescati di CHR_00, `--seed=7000`**, tavolo
misto salvo dove detto. Da [D-318](DECISIONS.md#d-318) non esiste più un anno
d'autore: ogni seme è una mappa diversa, e questo è il gioco che sta nella
scatola.

> **Perché questo foglio va rifatto e non aggiornato.** La versione prima di
> questa era ferma da cinquantaquattro versioni, con una banda in cima che
> elencava i numeri che sapevo cambiati. Una fotografia con una didascalia non è
> una misura: la regola è **rimisurare**, e i numeri qui sotto sono usciti dalle
> sonde oggi, non dalla memoria.

---

## 1. Quello che tiene

*Misurato in 0.1.379.*

| | | com'era in 0.1.353 |
|---|---|---|
| suite | **690 prove / 102 suite / 86.390 asserzioni** verdi | 679 / 101 / 86.480 |
| il vincolo che non si negozia | **0 seggi bloccati su 8**, misto *e* uniforme | uguale |
| cancelli | **tutti e trentadue verdi** (vedi `CLAUDE.md`) | ventisei |
| Consigli per anno | misto **3-5** (media 3,58) · uniforme **3-6** (media 3,49) | 3,15 · 3,23 |
| Verità scritte | misto **142**, di cui 113 diverse · uniforme **150**, di cui 108 | 125/101 · 130/95 |

**Il Consiglio si apre di più e il mondo ricorda di più**: mezzo Consiglio in
più all'anno, e le Verità scritte salgono di un sesto. Viene da
[D-402](DECISIONS.md#d-402), che ha insegnato al ripiego a prendere la parola
invece di prenotarla soltanto.

**E le asserzioni scendono mentre le prove salgono** — 86.480 → 86.390 con undici
prove in più. Non l'ho attribuito, e non lo invento: so che
[D-405](DECISIONS.md#d-405) ha tolto dodici sacchetti morti dai dati, e su dati
che non ci sono più i validatori asseriscono di meno. Se sia tutta lì la
differenza, non l'ho misurato.

I cancelli erano diciannove quando questa riga è stata scritta, e i sette in più
sorvegliavano quello che nessuno
guardava — la pagina dell'app, il tavolo posto per posto, le vite delle case, lo
scheletro delle carte, le caselle del Consiglio, i segni del mondo, e
[la tabella dei cancelli stessa](DECISIONS.md#d-367), che adesso non può
scollarsi dalla CI senza far rosso.

**E da 0.1.390 si sa quanto costano**, che nessuno aveva mai misurato:
ventisette dei trentadue costano **ventitré secondi tutti insieme**, e le cinque
sonde lunghe 881. Si girano con un comando solo,
[`tools/gates.py`](../tools/gates.py), in due corsie —
[D-418](DECISIONS.md#d-418). Nessun cancello è stato tolto: quello che è stato
tolto è il doverli ricordare a memoria.

---

## 2. I due numeri di PZ-01

*Rimisurati in 0.1.380.*

### Il difetto più grosso del progetto resta sotto la soglia — di quattro decimi

Il criterio 2 della milestone — *«meno della metà dei turni sono passa»* — è
soddisfatto, e **meno di prima**. `cli/run_pass_probe.gd`, 100 anni, tavolo
misto:

| | oggi | in 0.1.353 |
|---|---|---|
| turni «passa» | **49,6%** (3.571 su 7.200) | 47,6% |
| per Atto | 50,2% → 48,2% → 50,4% | 48,0 → 46,7 → 48,1 |
| passa con **zero mosse legali** | **0 su 3.571** (media 22,6 mosse) | 0 su 3.428 |
| passa con la mano vuota | **9** su 3.571 (media 4,5 carte) | 16 |

**I due punti in più sono il conto di [D-402](DECISIONS.md#d-402), ed erano
previsti.** Quel verbale li aveva già scritti: una prenotazione che non si
spenderà mai non è un turno in cui succede qualcosa, è un'Azione e una carta
bruciate contate come attività. Contando le prenotazioni morte insieme ai
«passa», i turni in cui non succede niente **scendono** da 51,4% a 49,7%. Il
numero che sale è quello onesto.

**Resta il fatto che il margine è di quattro decimi**, e va detto: la prossima
cosa che sposta i turni può portare questo criterio sopra la metà.

Le cause di quello che resta, misurate:

| | quota dei «passa» | dei 7.200 turni |
|---|---|---|
| nessuna mossa gli serviva | **84,5%** | **41,9%** |
| voleva un verbo, in mano niente | 8,7% | 4,4% |
| aveva il verbo e non poteva usarlo lì | 6,5% | 3,2% |

La prima riga è la **ragione**: è [ISSUES 123](ISSUES.md#123), ed è una
decisione, non una taratura.

I verbi che il cervello vuole dire e non riesce: **INFLUENZARE 337**, TRAMARE
172, FORGIARE 24, RIVENDICARE 12. Di quelle 545 intenzioni, **314 sono pesca
sbagliata** e 231 bersaglio sbagliato.

**E qui c'è la seconda cosa che D-402 ha fatto**: il RIVENDICARE che il cervello
voleva e non riusciva a dire era **64**, adesso è **12**. Da quando il ripiego sa
prendere la parola invece di prenotarla soltanto, quel verbo esce quando serve.
Il verbo in sofferenza adesso è **INFLUENZARE**, ed è lo stesso che
[ISSUES 59](ISSUES.md#59) trova essere il meno giocato e insieme la moneta più
votata.

### Giocare rende, e di molto

`cli/run_asking_probe.gd` gioca ogni anno due volte con lo stesso seme: una col
tavolo vero, una col **tavolo di pietra** che non spende mai un'Occasione.

| | oggi | in 0.1.353 |
|---|---|---|
| obiettivi avverati giocando | **425 su 1.200** (35,4%) | 423 (35,2%) |
| avverati dal tavolo di pietra | **116** | 115 |
| **quanto rende giocare** | **+266,4%** | +267,8% |
| di quelli avverati, **già veri all'apertura** | **48** (11,3%) | non misurato allora |

Era **−1,1%** prima di D-255 e **+160,7%** prima di
[D-386](DECISIONS.md#d-386). La regola di casa della ROADMAP §1.4 — *nessun
traguardo vero all'apertura, nessuno che si avveri stando fermi* — regge, con la
stessa coda di prima:

- **tre obiettivi su diciassette** rendono uguale o meglio stando fermi:
  `MOST_STONE` (−5%), `A_STONE` (−4%), `A_WORK` (±0%);
- gli altri quattordici rendono da **+3%** a **+100%**.

**I tre che restano sono tutti e tre di Pietra** — *Più Pietra di Tutti*,
*Qualcosa che Resta in Piedi*, *L'Opera che Porta il Nome* — **e la causa è una
sola**: nessuna Pietra sale per mano di un'Azione della plancia. È
[ISSUES 123](ISSUES.md#123), e finché regge nessun obiettivo di Pietra può
premiare il giocare, per quanto bene sia scritto.

---

## 3. La grammatica fisica: cosa esiste, e cosa il motore esegue

| | |
|---|---|
| Temi | **6** — Potere, Sopravvivenza, Terra, Antico, Fede, Vie |
| carte Asset con faccia fisica | **48 su 48** |
| Destini con faccia fisica | **23 su 23** |
| carte Tensione, che portano le Domande | **60** — dieci per Tema |
| tessere Regione | **10 nel parco, 6 pescate** ogni anno |

**Il motore esegue**: la Risonanza, il bersaglio a segni delle Azioni
([D-273](DECISIONS.md#d-273)), la scelta fra le due Azioni stampate
([D-283](DECISIONS.md#d-283)), le clausole dei Destini mirate a segni
([D-327](DECISIONS.md#d-327)), la pista del Calore, il Consiglio che si apre sul
Tema più caldo, e **«SI ACCENDE QUANDO»** ([D-330](DECISIONS.md#d-330)): la
Tensione stampa cosa le fa prendere Calore, e il Calore va alla questione che
*quel gesto* riguarda.

**E da 0.1.332 esegue anche la risoluzione con le caselle.** Era la voce più
grossa del progetto — [ISSUES 89](ISSUES.md#89), *«642 Effetti d'autore che
nessuna carta stampa»* — e [D-366](DECISIONS.md#d-366) l'ha chiusa scrivendo le
otto caselle che mancavano e i due campi che mancavano di più: una casella
adesso dice **cosa fa** (il verbo), **su chi** (`chi`) e **dove** (`dove`).

| il vocabolario delle caselle | distinti | applicazioni |
|---|---|---|
| **una casella lo sa dire** | **44 su 46** | **334 su 336** |
| verbo giusto, posto che non sa dire | 1 | 2 |
| verbo che manca | **0** | **0** |

Le due che restano non sono caselle da scrivere: `$conditioner` è un bersaglio
che al Consiglio non esiste, e un `SET_GLOBAL_TAG` puntato su `$adjacent` è un
difetto del dato.

| la Risonanza, misurata | |
|---|---|
| Risonanze in 100 anni | **3.779 — 37,8 per anno** |
| di quelle, aggravate | **24,2%** |
| col ponte alla questione in gioco | 2.112 |

Dove finisce il Calore, ed è qui che si vede il difetto che resta:

| Fede | **Antico** | Vie | Potere | Sopravvivenza | Terra |
|---|---|---|---|---|---|
| 23,0% | **21,0%** | 15,9% | 15,7% | 14,7% | 9,8% |

**Era 0,9% fino alla 0.1.349**, e la causa non era sottile: l'Antico aveva
**una carta su 48 e una copia nel mazzo**. Spostate otto Risonanze
([D-382](DECISIONS.md#d-382)), tutti e sei i Temi si aprono.

---

## 4. Come è fatto il contenuto

Contato da `validate_data.py` e da `docs/COMPONENTI.md`, che si ricava i numeri
invece di battersi le cifre a mano ([D-373](DECISIONS.md#d-373)).

| | |
|---|---|
| Asset | **48** (132 copie), tutte con faccia fisica, ognuna col suo Eco |
| carte Echo | **48** · Tensioni **60** · Destini **23** · Casate **26** |
| Conseguenze | **65** · obiettivi 17 · azioni 6 |
| Regioni 10 · Entità 8 · profili strategici 8 · Cronache **1** (CHR_00) | |
| segni nel dizionario | **174** · regole del segno **53** · icone **124** |
| template di Consiglio | 12 |
| **da stampare** | **49 fogli A4**, più quattro fogli-fustella |
| **segnalini** | **119 tipi, 154 pezzi**, più le pedine dei seggi |

**Il Consiglio adesso sta sulla carta.** Ogni Tensione porta **due domande sue e
tre proposte sue**: 120 domande e 194 proposte, e i 194 testi sono 194 testi
diversi ([D-378](DECISIONS.md#d-378)). Fino alla 0.1.344 sette testi generici
coprivano ventotto carte.

E le tre misure che vengono prima della matrice (`MISURA_MATRICE.md`):

| | |
|---|---|
| segni che qualcuno scrive | **170 su 174** |
| **orfani senza una ragione scritta** | **11** |
| clausole impossibili | **0** |
| Tensioni che nessun Destino incontra | **0** |
| **carte che aprono ancora una domanda in prestito** | **0** |
| livelli di Destino che non si indicano in nessun modo | **11 su 69**, tutti il `minimum` |
| coppie di case che hanno qualcosa per cui litigare | **13 su 28** |

E le misure che prima non c'erano:

| | |
|---|---|
| segni che non arrivano mai sul tavolo (`MISURA_TAVOLO`) | 50 su 174 |
| **punti regalati** / **porte murate** (`MISURA_SEGNI`) | **1** / **0** |
| vite scritte che non si siedono mai (`MISURA_VITE`) | **1 su 24** (0.1.404) |
| testi che un giocatore può leggere (`REVISIONE_TESTI`) | **2.968** |
| pezzi e legami del flusso disegnato (`flusso.html`) | **964 / 4.262** |
| pezzi del disegno senza nemmeno una freccia | **7** (erano 12) |
| testi che vivono solo nel suggerimento del mouse (`MISURA_PAGINA`) | **2** |

---

## 5. Le voci aperte che posso chiudere io — **quattro**, rimisurato in 0.1.382

**29** voci aperte su 131, contate da `tools/issues_survey.py`. L'elenco che
stava qui era del 0.1.353 e **tre delle sette voci che nominava sono chiuse da un
pezzo** — la [96](ISSUES.md#96) in 0.1.363, la [88](ISSUES.md#88) in 0.1.372, la
[53](ISSUES.md#53) in 0.1.355. Delle quattro rimaste, due sono del committente
([123](ISSUES.md#123) e [100](ISSUES.md#100)) e una e' fuori dalla lista
([91](ISSUES.md#91)): **di sette righe ne era rimasta vera una**, la
[56](ISSUES.md#56). Ed e' per questo che adesso non c'e' piu' un elenco qui: **la lista viva e'
[LE_TUE_DECISIONI.md](LE_TUE_DECISIONI.md)**, che si rigenera col suo cancello.

Quello che va detto qui e' il numero, e non e' quello che sembrava:

| chi la puo' muovere | quante |
|---|---|
| il committente, con una parola | **15** |
| una persona che gioca — [63](ISSUES.md#63), [67](ISSUES.md#67) | 2 |
| **io, senza aspettare niente** — [56](ISSUES.md#56), [59](ISSUES.md#59), [60](ISSUES.md#60), [106](ISSUES.md#106) | **4** |
| io, ma dietro una rossa — [111](ISSUES.md#111) e [4](ISSUES.md#4) | 2 |
| nessuno, finche' non si gioca | 6 |

**Quattro su ventinove.** Il giro non e' fermo sul lavoro: e' fermo su quindici
parole ([D-411](DECISIONS.md#d-411)).

---

## 6. Le decisioni che sono tue e non mie

**Stanno tutte e quindici in un foglio solo**, con una riga a testa, il numero
che le motiva e la mia raccomandazione: [LE_TUE_DECISIONI.md](LE_TUE_DECISIONI.md).

Erano dieci fino a 0.1.381, e non perche' ne siano nate cinque: **cinque voci
dicevano nel loro «fatto quando» che aspettavano il committente e non avevano il
cartellino** `da-decidere`, che e' quello che il conto legge. Adesso ce l'hanno
([D-411](DECISIONS.md#d-411)).

Quattro sono state decise in 0.1.353, e sono scritte.

**Decise e scritte:**

| | |
|---|---|
| [ISSUES 84](ISSUES.md#84) — l'Eredità | *«+3 per ogni leggenda che porta il tuo nome»* → [D-385](DECISIONS.md#d-385) |
| [ISSUES 120](ISSUES.md#120) — avere o fare | *«fai la cura proposta»* → [D-386](DECISIONS.md#d-386) |
| [ISSUES 122](ISSUES.md#122) — la moneta del Consiglio | la regola dettata → [D-387](DECISIONS.md#d-387) |
| [ISSUES 119](ISSUES.md#119) — i Consigli che non cadono | riscritta con gli esempi, la scelta resta |

**Le quattro che pesano di piu', in ordine:**

1. **[ISSUES 123](ISSUES.md#123) — nessuna Azione alza una Pietra**, e il
   Consiglio paga meglio chi tace (199 Pietre contro 136). **Quaranta turni su
   cento** un giocatore ha 22,1 mosse legali, 4,4 carte in mano e nessun motivo:
   e' il numero piu' grosso che una parola del committente puo' muovere oggi.
2. **[ISSUES 122](ISSUES.md#122) + [125](ISSUES.md#125) — quanto compra una
   proposta.** Con un solo beneficio gratis le caselle vive per Consiglio sono
   **una**, e i benefici comprati sono **scesi** da 1,71 a 1,40.
3. **[ISSUES 120](ISSUES.md#120) — vincere nominando invece che contando.** E'
   anche la cura della [91](ISSUES.md#91) (48,4% dei punti gia' veri
   all'apertura) e la meta' che resta della [4](ISSUES.md#4).
4. **[ISSUES 119](ISSUES.md#119) — il Consiglio non cade quasi piu'.** Un
   Consiglio su undici cade sul tavolo misto; `spoke_and_lost` si posa 8 volte
   in cento partite.

Le altre dieci, con la raccomandazione a testa, stanno nella lista.

**E una cosa che non e' una voce**: PZ-8, §5ter — **il giro su un iPad vero**.
La sonda della pagina misura quello che la pagina *chiede*; quello che una
persona *vede*, no.

---

## 7. Il debito che questo giro ha trovato

- **`docs/RULES_V0_2.md` è fermo a 0.1.38** e rimanda a un file che non esiste
  più. Resta perché è l'unico posto dove le regole sono scritte per esteso, con
  l'avvertenza in cima.
- **Tre sonde guardavano ancora la casa vecchia**, e sono cadute una per volta:
  il catalogo dei Consigli (0.1.273), la revisione dei testi (0.1.345), il
  disegno del flusso (0.1.347). Tutte e tre leggevano i **template** dopo che
  le Domande e le Proposte erano passate **sulla carta**. Nessun cancello se
  n'era accorto: controllano che il file combaci col generatore, non che il
  generatore guardi dove il gioco è andato.
- **Tre numeri di `COMPONENTI.md` mentivano**, e uno era un'istruzione per chi
  stampa: sette pedine di presenza per casa di troppo
  ([D-373](DECISIONS.md#d-373)). Adesso si ricavano, e una guardia pretende che
  ogni cifra della prosa arrivi da un conto.
- **Otto gettoni che nessuno potrà mai posare** stavano nel dizionario con posto
  e cartone ([D-376](DECISIONS.md#d-376)): la guardia non li vedeva perché
  **modellava il motore più generoso di com'è**.

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
   rimasto indietro due volte: settanta versioni la prima, cinquantaquattro la
   seconda.
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
