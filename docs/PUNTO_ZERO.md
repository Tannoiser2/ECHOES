# PUNTO ZERO — dov'è ECHOES, misurato

**Versione 0.1.293** · `main` a `c0c83f9` · riscritto dopo un giro completo dei
cancelli, con le sonde rifatte sul codice di oggi.

Questo documento non racconta cosa il gioco vuole essere. Dice **cosa fa oggi,
con i numeri**, e cosa è ancora aperto. È il foglio contro cui si decide: se una
voce qui sotto non ti torna, quella è la prima cosa da cambiare.

Tutti i numeri sono su **100 anni pescati di CHR_00, `--seed=7000`**, tavolo
misto salvo dove detto. Da [D-318](DECISIONS.md#d-318) non esiste più un anno
d'autore: ogni seme è una mappa diversa, e questo è il gioco che sta nella
scatola.

---

## 1. Quello che tiene

| | |
|---|---|
| suite | **634 prove / 97 suite / 35.900 asserzioni** verdi |
| il vincolo che non si negozia | **0 seggi bloccati su 8**, misto *e* uniforme |
| cancelli | **tutti e diciannove verdi** (vedi `CLAUDE.md`) |
| Consigli per anno | misto **3-6** (media 3,41) · uniforme **3-5** (media 3,46) |
| Verità scritte | misto **160**, di cui 150 diverse · uniforme 160, di cui 137 |

Il **nove** del tavolo uniforme, che era il prezzo dichiarato della Risonanza in
D-257, non esiste più: i sei mazzetti di Tensioni ([D-261](DECISIONS.md#d-261))
l'hanno tolto per costruzione.

---

## 2. I due numeri di PZ-01, e uno è appena passato

### Il difetto più grosso del progetto è sceso sotto la soglia

Il criterio 2 della milestone — *«meno della metà dei turni sono passa»* — **è
soddisfatto**. `cli/run_pass_probe.gd`:

| | |
|---|---|
| turni «passa» | **47,3%** (3.406 su 7.200) |
| per Atto | 47,0% → 47,6% → 47,4% |
| passa con **zero mosse legali** | **0 su 3.406** (media: 22,2 mosse) |
| passa con la mano vuota | 4 su 3.406 (media: 4,2 carte) |

La strada: **82,8% in 0.1.216 → 42,1% in 0.1.247 → 47,3% oggi**, sul gioco
pescato invece che sui due anni d'autore. La forma piatta per Atto è la novità
che conta: il 90,2% dell'Atto 3 è sparito.

Le cause di quello che resta, misurate:

| | quota dei «passa» | cura |
|---|---|---|
| nessuna mossa gli serviva | **84,6%** | la **ragione** — è tutto quello che rimane |
| voleva un verbo, in mano niente | 10,5% | il mazzo: come si pesca |
| aveva il verbo e non poteva usarlo lì | 4,8% | il bersaglio: dove si può |

I verbi che il cervello vuole dire e non riesce: **INFLUENZARE 272**, TRAMARE
181, RIVENDICARE 48, FORGIARE 18. Il mazzo e il bersaglio, che in 0.1.216 erano
un terzo del problema, oggi sono un sesto: **resta la ragione, sola**.

### Giocare rende, e di molto

`cli/run_asking_probe.gd` gioca ogni anno due volte con lo stesso seme: una col
tavolo vero, una col **tavolo di pietra** che non spende mai un'Occasione.

| | |
|---|---|
| obiettivi avverati giocando | **167 su 480** (34,8%) |
| avverati dal tavolo di pietra | 59 |
| **quanto rende giocare** | **+183,1%** |
| di quelli avverati, già veri all'apertura | 22 — **13,2%** |

Era **−1,1%** prima di D-255. La regola di casa della ROADMAP §1.4 — *nessun
traguardo vero all'apertura, nessuno che si avveri stando fermi* — regge, con
una coda che ha i nomi:

- **cinque obiettivi su diciassette** rendono uguale o meglio stando fermi:
  `BOUND_HOUSE` (−15%), `FULL_HANDS` (−11%), `THE_WIDEST_SPREAD` (−9%),
  `A_WORK` e `MOST_STONE` (+0%);
- **tre Destini su diciannove** che si siedono si avverano da fermi: `LIBERE`,
  `LYRA`, `SHARED_QUIET`. Gli altri sedici chiedono di giocare.

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
([D-273](DECISIONS.md#d-273)), **la scelta fra le due Azioni stampate**
([D-283](DECISIONS.md#d-283): chi gioca dice quale delle due cala, e il verbo
viene da lì), le clausole dei Destini mirate a segni
([D-327](DECISIONS.md#d-327)), la pista del Calore e il Consiglio che si apre sul
Tema più caldo.

> **Correzione (0.1.292).** Fino alla 0.1.291 questo foglio diceva che la scelta
> fra le due Azioni non arrivava al motore. Era vecchia di nove versioni: D-283
> l'ha implementata. Il conto vero è **85 Azioni stampate su 96** che portano un
> verbo eseguibile; le altre **11 posano solo un segno**, e su quelle il motore
> risponde *«quell'Azione la carta la stampa e io non la so ancora eseguire»*.

E da 0.1.293 esegue anche **«SI ACCENDE QUANDO»** ([D-330](DECISIONS.md#d-330)):
la Tensione stampa cosa le fa prendere Calore, e il Calore va alla questione che
*quel gesto* riguarda invece che alla più vicina alla soglia. **47 Tensioni su
60** portano la casella, e **257 cadute di Calore su 381** la usano; le altre
ricadono sul ponte di D-261, che resta come ripiego dichiarato (ISSUES 100).

**Il motore non esegue**: la **risoluzione della proposta con le caselle della
Tensione** — il Consiglio gira ancora su 642 Effetti d'autore che nessuna carta
stampa. È ISSUES 89, ed è la voce più grossa rimasta.

E le **11 Azioni che posano solo un segno** sono la coda della stessa voce: la
faccia le stampa, il tavolo le potrebbe giocare, il motore no.

| la Risonanza, misurata | |
|---|---|
| Risonanze in 100 anni | **3.762 — 37,6 per anno** |
| di quelle, aggravate | **25,7%** |
| col ponte alla questione in gioco | 1.840 |

Dove finisce il Calore, ed è qui che si vede il difetto:

| Fede | Vie | Sopravvivenza | Potere | **Terra** | **Antico** |
|---|---|---|---|---|---|
| 33,4% | 24,4% | 17,2% | 17,2% | **7,1%** | **0,8%** |

La Terra è passata dall'1,4% al 7,1% col mazzetto pieno. **L'Antico no: 30
Risonanze su 3.762.** Un Tema che nessuna carta scalda è un Tema che non si apre
mai, ed è la voce 5 della ROADMAP §4, ancora aperta.

---

## 4. Come è fatto il contenuto

Contato da `validate_data.py` e da `docs/COMPONENTI.md`.

| | |
|---|---|
| Asset | **48** (132 copie), tutte con faccia fisica |
| carte Echo | 39 · Tensioni **60** · Destini **23** · Casate 26 |
| Conseguenze | **64** · obiettivi 17 · azioni 6 |
| Regioni | 10 · Entità 8 · profili strategici 8 · Cronache **1** (CHR_00) |
| segni nel dizionario | **182** · regole del segno 52 · icone 74 |
| template di Consiglio | 12 |
| **da stampare** | **39 fogli A4**, più tre fogli-fustella |
| **segnalini** | **67 tipi, 91 pezzi**, più le pedine dei seggi |

E le tre misure che vengono prima della matrice (`MISURA_MATRICE.md`):

| | |
|---|---|
| segni che qualcuno scrive | 149 su 182 |
| **orfani senza una ragione scritta** | **11** |
| clausole impossibili | **0** |
| Tensioni che nessun Destino incontra | **0** |
| carte che aprono ancora una domanda in prestito | **28** |
| coppie di case che hanno qualcosa per cui litigare | **13 su 28** |

---

## 5. Le voci aperte che posso chiudere io

48 voci aperte su 105. In ordine di quanto cambiano la partita.

1. **ISSUES 89 — il Consiglio non si risolve col dito.** Le Azioni hanno la
   faccia fisica e il motore la esegue; la proposta no: **642 Effetti d'autore
   che nessuna carta stampa**. È il rischio che ISSUES 69 nominò da sola — *«due
   grammatiche che non si toccano divergono»* — e adesso ha un numero.
2. **ISSUES 91 — il 53,1% delle clausole a punti è già vero all'apertura.**
   `state_tag_absent` da solo sono 426 clausole mai contese. D-327 ha portato la
   contesa sulla mappa dal 2,8% al 15,5%; la lite sulle **memorie** resta.
3. **ISSUES 96 — ventun segni scritti più di dieci volte per secolo che nessuna
   clausola guarda**, in testa la famiglia `discovery:*` (`the_omen` 454).
4. **ISSUES 88 — il tavolo vede il 36-37% di quello che è scritto.** Scrivere un
   Consiglio per carta ha triplicato il contenuto senza allargare la finestra.
5. **ISSUES 68 — la ragione.** Il 47,3% è passato sotto la soglia, ma l'84,6% di
   quello che resta è ancora *«nessuna mossa gli serviva»*. Il numero da guardare
   adesso non è il passare: è **quanto rende un turno pieno**.
6. **ISSUES 56 — tre Conseguenze non escono mai** (misurate quando erano 52;
   oggi sono 64), con tre cause diagnosticate.
7. **ISSUES 53 — RIVENDICARE può forzare un Consiglio che poi non si apre.** Le
   43 aperture rifiutate vanno rimisurate sotto la regola di D-261.

---

## 6. Le decisioni che sono tue e non mie

Queste non le prendo io. Sono le porte chiuse.

1. **L'Antico non si scalda: 30 Risonanze su 3.762.** Le sue Tensioni vivono di
   Drift e di Consigli, non di carte. O qualche carta lo nomina, o quel Tema non
   apre mai la sua Domanda.
2. **ISSUES 65 — «tutta la pagina dell'app va rivista».** Tre revisioni diverse
   si nascondono in quella frase: la leggibilità, l'impaginazione, o *l'idea di
   cosa si guarda*. Non è la stessa cosa e non costa la stessa cosa. Ferma da
   0.1.211.
3. **ISSUES 80 — il Consiglio sono due Consigli impilati**, e a decidere è quello
   vecchio: le regole sono nuove a metà, lo schermo è vecchio al cento per cento.
4. **ISSUES 84 — l'Eredità è misurabile e quasi inerte**: tre strade scritte,
   nessuna scelta.
5. **ISSUES 82 — la fame quasi non si produce**: `condition:starving` un anno su
   quaranta, e la fame è un Tema del gioco.
6. **PZ-8, §5ter — il giro su un iPad vero.** Nessuna misura copre quello che una
   persona vede, e in headless non si chiude.

---

## 7. Il debito che questo giro ha trovato

- **`godot/data/` porta ancora i nomi degli anni cancellati** (ISSUES 99). Dodici
  file si chiamano `*_chronicle_01` / `*_chronicle_03` e due cartelle pure, ma
  dentro c'è il contenuto vivo che ogni anno pescato usa: 17 dei 23 Destini, le
  8 case, le 39 carte Echo, **tutte e dieci le tessere**. Non è roba morta: è un
  nome che mente.
- **Un nome che mente costa.** `tools/build_review.py` nominava a mano
  `chronicle_01/chronicle_01.json` e **moriva all'avvio** dalla 0.1.281: il
  documento che genera è rimasto fermo settanta versioni perché nessun cancello
  lo guardava. Riparato a glob in 0.1.291, e adesso ha il suo cancello — da 771
  a **1.010 testi in lettura**. La stessa trappola è sotto ogni strumento che
  nomini un file per nome.
- **`docs/RULES_V0_2.md` è fermo a 0.1.38** e rimanda a
  `godot/data/chronicle_01/chronicle_01.json`, che non esiste più. Resta perché
  è l'unico posto dove le regole sono scritte per esteso, con l'avvertenza in
  cima.
- **Diciassette documenti superati sono usciti** in 0.1.291: le cinque sedute, le
  tre saghe degli anni d'autore, e nove fra roadmap, audit e istantanee. Il
  verbale sta in [D-328](DECISIONS.md#d-328).

---

## 8. Le lezioni che questo progetto ha pagato

Valgono più di metà del codice scritto.

1. **Uno zero è quasi sempre la sonda.** Sedici volte finora. L'ultima coppia in
   D-326: due sonde cercavano `region_id` dopo che le clausole avevano smesso di
   nominarlo. Prima di credere a uno zero, provalo su un caso che *deve* dare
   non-zero.
2. **Un cancello che si soddisfa da solo è peggio di nessun cancello.** Il
   validatore fisico contava «letto» un segno solo perché elencato sotto un Tema.
3. **Una prova può smettere di provare senza dirlo.** Cercava una carta senza
   faccia fra quelle spedite; finita la conversione, passava a vuoto.
4. **Aggiustare la causa sbagliata è peggio che non aggiustare.** La cronaca nera
   è stata «risolta» due volte guardando la dimensione del raster invece che
   l'inchiostro sulla pagina.
5. **Un documento fermo mente più di un documento che manca.** Questo foglio era
   rimasto a 0.1.220 per settanta versioni, e dava per aperte cose chiuse e per
   vere cose che non lo erano più.
6. **Un generato senza cancello è un generato fermo, e nessuno lo vede fermarsi.**
   `build_review.py` è morto all'avvio per dieci versioni e la CI è rimasta
   verde tutto il tempo. Se un documento si rigenera, il comando che lo rigenera
   deve girare in CI — altrimenti non è generato: è scritto a mano una volta.
7. **Uno strumento che nomina un file per nome è una mina a scoppio ritardato.**
   Il file si sposta, e lo strumento non fallisce dove qualcuno guarda. Si legge
   a glob quello che c'è.
