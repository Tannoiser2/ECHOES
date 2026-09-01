# PUNTO ZERO — dov'è ECHOES, misurato

**Versione 0.1.353** · rimisurato per intero in 0.1.349; le sonde rilanciate in
0.1.353 dopo le tre decisioni del committente
([D-385](DECISIONS.md#d-385), [D-386](DECISIONS.md#d-386),
[D-387](DECISIONS.md#d-387)).

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

| | |
|---|---|
| suite | **679 prove / 101 suite / 86.480 asserzioni** verdi |
| il vincolo che non si negozia | **0 seggi bloccati su 8**, misto *e* uniforme |
| cancelli | **tutti e ventisei verdi** (vedi `CLAUDE.md`) |
| Consigli per anno | misto **3-4** (media 3,15) · uniforme **3-5** (media 3,23) |
| Verità scritte | misto **125**, di cui 101 diverse · uniforme 130, di cui 95 |

I cancelli erano diciannove: i sette in più sorvegliano quello che nessuno
guardava — la pagina dell'app, il tavolo posto per posto, le vite delle case, lo
scheletro delle carte, le caselle del Consiglio, i segni del mondo, e
[la tabella dei cancelli stessa](DECISIONS.md#d-367), che adesso non può
scollarsi dalla CI senza far rosso.

---

## 2. I due numeri di PZ-01

### Il difetto più grosso del progetto resta sotto la soglia

Il criterio 2 della milestone — *«meno della metà dei turni sono passa»* — è
soddisfatto. `cli/run_pass_probe.gd`:

| | |
|---|---|
| turni «passa» | **46,4%** (3.340 su 7.200) |
| per Atto | 47,3% → 45,1% → 46,8% |
| passa con **zero mosse legali** | **0 su 3.340** (media: 23,0 mosse) |
| passa con la mano vuota | 5 su 3.340 (media: 4,3 carte) |

La strada: **82,8% in 0.1.216 → 42,1% in 0.1.247 → 46,4% oggi**, sul gioco
pescato invece che sui due anni d'autore. La forma resta piatta per Atto: il
90,2% dell'Atto 3 è sparito e non è tornato.

Le cause di quello che resta, misurate:

| | quota dei «passa» | cura |
|---|---|---|
| nessuna mossa gli serviva | **83,5%** | la **ragione** — è tutto quello che rimane |
| voleva un verbo, in mano niente | 10,1% | il mazzo: come si pesca |
| aveva il verbo e non poteva usarlo lì | 6,3% | il bersaglio: dove si può |

I verbi che il cervello vuole dire e non riesce: **INFLUENZARE 297**, TRAMARE
170, RIVENDICARE 57, FORGIARE 22. Di quelle 546 intenzioni, **337 sono pesca
sbagliata** e 209 bersaglio sbagliato.

### Giocare rende, e di molto

`cli/run_asking_probe.gd` gioca ogni anno due volte con lo stesso seme: una col
tavolo vero, una col **tavolo di pietra** che non spende mai un'Occasione.

| | |
|---|---|
| obiettivi avverati giocando | **423 su 1.200** (35,2%) |
| avverati dal tavolo di pietra | 115 |
| **quanto rende giocare** | **+267,8%** |

Era **−1,1%** prima di D-255 e **+160,7%** prima di
[D-386](DECISIONS.md#d-386). La regola di casa della ROADMAP §1.4 — *nessun
traguardo vero all'apertura, nessuno che si avveri stando fermi* — regge, con
una coda che si è accorciata:

- **tre obiettivi su diciassette** rendono uguale o meglio stando fermi —
  erano sei: `MOST_STONE` (−7%), `A_WORK` (−6%), `A_STONE` (−3%);
- **un Destino su ventitré** si avvera da fermi — erano due.

**I tre che restano sono tutti e tre di Pietra, e la causa è una sola**: in cento
partite **nessuna Pietra è salita per mano di un'Azione** della plancia, e quelle
che alza il Consiglio le alza più spesso per un tavolo che tace (199) che per uno
che gioca (136). È [ISSUES 123](ISSUES.md#123), e finché regge nessun obiettivo
di Pietra può premiare il giocare, per quanto bene sia scritto.

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
| vite scritte che non si siedono mai (`MISURA_VITE`) | **1 su 18** |
| testi che un giocatore può leggere (`REVISIONE_TESTI`) | **2.968** |
| pezzi e legami del flusso disegnato (`flusso.html`) | **964 / 4.262** |
| pezzi del disegno senza nemmeno una freccia | **7** (erano 12) |
| testi che vivono solo nel suggerimento del mouse (`MISURA_PAGINA`) | **2** |

---

## 5. Le voci aperte che posso chiudere io

62 voci aperte su 125. In ordine di quanto cambiano la partita.

1. **ISSUES 91 — metà dei punti è già vera prima che qualcuno giochi.**
   `state_tag_absent` da solo sono centinaia di clausole mai contese. D-327 ha
   portato la contesa sulla mappa dal 2,8% al 15,5%; la lite sulle **memorie**
   resta.
2. **ISSUES 68 — la ragione.** Il 46,7% è sotto la soglia, ma l'**85,4%** di
   quello che resta è ancora *«nessuna mossa gli serviva»*. Il numero da
   guardare adesso non è il passare: è **quanto rende un turno pieno**.
3. **ISSUES 96 — i segni scritti spesso che nessuna clausola guarda.** Oggi ne
   restano tre sopra le dieci scritture per secolo: `took_by_hand`,
   `price_in_lives`, `watched`.
4. **ISSUES 88 — il tavolo vede poco più di un terzo di quello che è scritto.**
   Scrivere un Consiglio per carta ha triplicato il contenuto; la finestra è
   quella.
5. **ISSUES 100 — le caselle «si accende quando» sono un pavimento derivato.**
   Quarantasei facce ricavate aspettano una mano d'autore.
6. **ISSUES 56 — tre Conseguenze non escono mai** (misurate quando erano 52;
   oggi sono 65).
7. **ISSUES 53 — RIVENDICARE può forzare un Consiglio che poi non si apre.**

---

## 6. Le decisioni che sono tue e non mie

Quattro di queste sono state decise in 0.1.353, e sono scritte. Quello che resta
è sotto.

**Decise e scritte:**

| | |
|---|---|
| [ISSUES 84](ISSUES.md#84) — l'Eredità | *«+3 per ogni leggenda che porta il tuo nome»* → [D-385](DECISIONS.md#d-385) |
| [ISSUES 120](ISSUES.md#120) — avere o fare | *«fai la cura proposta»* → [D-386](DECISIONS.md#d-386) |
| [ISSUES 122](ISSUES.md#122) — la moneta del Consiglio | la regola dettata → [D-387](DECISIONS.md#d-387) |
| [ISSUES 119](ISSUES.md#119) — i Consigli che non cadono | riscritta con gli esempi, la scelta resta |

**Aperte, e tutte e cinque nate da quelle decisioni o rimaste da lì:**

1. **[ISSUES 125](ISSUES.md#125) — la moneta è troppo poca.** L'economia dei
   gettoni funziona, ma i benefici comprati per Consiglio sono **scesi** da 1,71
   a 1,40: con 2,8 carte RIVENDICARE per partita i gettoni bastano per un
   acquisto in più *a partita*, non a Consiglio. Quattro strade, tutte
   misurabili in mezz'ora.
2. **[ISSUES 123](ISSUES.md#123) — nessuna Azione alza una Pietra**, e il
   Consiglio paga meglio chi tace (199 Pietre contro 136). È la causa unica dei
   tre obiettivi che ancora rendono meglio da fermi, ed è
   [ISSUES 119](ISSUES.md#119) vista dall'altra parte.
3. **[ISSUES 119](ISSUES.md#119) — il Consiglio non cade quasi più.** Un
   Consiglio su undici cade sul tavolo misto; `spoke_and_lost` si posa 8 volte
   in cento partite. Tre strade, adesso con un esempio ciascuna.
4. **[ISSUES 124](ISSUES.md#124) — due case su otto non prendono mai
   l'Eredità.** Nahr e Vaerax: i segni che vogliono lasciare sono muri, e un
   muro non diventa leggenda. È [ISSUES 76](ISSUES.md#76) un'altra volta.
5. **[ISSUES 120](ISSUES.md#120) — come il tavolo si ricorda di un gesto.** La
   clausola c'è; il **segnalino** no. A fine anno «l'hai alzata quest'anno?» si
   risponde ricordando, o guardando l'app.
6. **[ISSUES 65](ISSUES.md#65) — la seconda e la terza rivista della pagina.**
   *Lasciata stare per adesso, per tua parola.* La prima, la leggibilità, è
   fatta ([D-384](DECISIONS.md#d-384)).
7. **PZ-8, §5ter — il giro su un iPad vero.** La sonda della pagina misura
   quello che la pagina *chiede*; quello che una persona *vede*, no.

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
