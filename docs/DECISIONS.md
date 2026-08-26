# DECISIONS

Every place where the implementation had to decide something the spec (v0.2) left
open, or where it extended something the spec fixed. Per §16 and §25, a baseline
number is never changed silently: it is either implemented as written, or the
deviation is recorded here as a reversible configuration.

Status legend: **implemented** = live in 0.0 · **flagged** = a balance
observation for 0.2, deliberately *not* acted on · **todo** = known gap.

---

## D-296 — La fustella non e' il dizionario: 67 tipi, non 183

**implemented in 0.1.259** — correzione di [D-295](#d-295)

Il committente, leggendo il censimento: *«certo che 183 segnalini sono tanti,
forse troppi»*. **Aveva ragione a spaventarsi, e il numero era mio.** Il
documento metteva i 183 segni del **dizionario** sotto il titolo «i segnalini
che si posano», e sono due cose diverse: metà del dizionario sono memorie del
mondo, funzioni che legge solo il motore, leggende fabbricate dal tempo e
domini stampati sulle tessere. Roba che non si posa.

**La fustella vera**, contata da dove la conta il foglio di stampa
(`sign_labels.gd`, non i dati):

| | tipi | pezzi |
|---|---|---|
| segni delle Regioni (condizioni in doppia copia, Pietre, insediamenti, Cicatrici) | 34 | 52 |
| segni delle case | 33 | 39 |
| **in tutto** | **67** | **91** |

più presenza e controllo (12 per casa) e i rombi del Calore.

**Ma la domanda sotto resta buona, e si misura.** `cli/run_punchboard_probe.gd`
gioca gli anni e conta i tipi che arrivano davvero sul tavolo — per **anno**,
non per Regione: un segno su tre Regioni è un tipo solo da imparare.

| | |
|---|---|
| tipi disegnati per la mappa | 34 |
| tipi visti almeno una volta in 40 anni | 30 |
| **tipi sul tavolo in un anno solo** | **media 8,8 · massimo 15** |
| tipi che non escono mai, o meno di un anno su cinque | **17 su 34** |

**Nessuno impara 34 simboli: si impara quello che si vede, e quello che si vede
sono nove.** Il totale della fustella è un costo di stampa; il numero che pesa
sul tavolo è l'altro, ed è già ragionevole.

**E la coda va letta divisa in due**, perché sono due cose diverse:

- **le Cicatrici rare sono design**: `scar:divided_seal` due volte in
  quarant'anni è memorabile, non morto. Una Cicatrice frequente sarebbe il
  difetto.
- **le condizioni rare sono un buco**: `condition:starving`,
  `condition:lean` e `condition:requisitioned` una volta su quaranta vuol dire
  che il motore quasi non sa produrle — e la fame è un Tema del gioco. Non è
  cartone di troppo: è contenuto che non succede.

E due dei quattro mai visti — `structure:sealed` e `scar:unanswered` — sono
nominati dai profili come voluti o temuti: è [ISSUES 76](ISSUES.md#76-il-consiglio-decide-con-una-moneta-che-i-destini-non-spendono)
un'altra volta, la moneta che nessuno sa coniare.

**Cosa non ho fatto, e perché**: non ho tagliato niente. Tagliare i diciassette
della coda toglierebbe soprattutto Cicatrici, cioè la parte che il gioco fa
bene. La decisione — se ridurre i tipi, e quali — sta al committente, adesso
con i numeri davanti ed è [ISSUES 82](ISSUES.md#82-la-coda-della-fustella-cicatrici-rare-che-vanno-bene-e-condizioni-che-non-succedono).

---

## D-295 — Il censimento dei componenti: quanti pezzi ha la scatola

**implemented in 0.1.258** — [il documento](COMPONENTI.md)

Domanda del committente:

> *«Non mi rendo più conto di quanti componenti abbia il gioco, quanto sia
> cresciuto, e quanto c'è ancora da fare per avere un'app uguale al gioco
> fisico.»*

Un elenco scritto a mano avrebbe risposto una volta e sarebbe invecchiato in
silenzio — il difetto che questo progetto ha già visto tre volte. Quindi il
censimento **si conta dai dati**, `tools/components_survey.py` →
`docs/COMPONENTI.md`, **nei cancelli**.

**La scatola, oggi**: 48 Asset (132 copie), 39 Echo, 60 Tensioni, 23 Destini,
26 Casate (una per vita), 10 tessere Regione. **39 fogli A4** più i tre
fogli-fustella. 183 segni nel dizionario, di cui 14 condizioni, 12 Cicatrici e
10 Pietre con 25 gradi. Dietro: 8 case con 8 profili, 6 Temi, 16 obiettivi, 64
Conseguenze, 12 modelli di Consiglio, 52 regole dei segni, 6 Azioni, 5
Chronicle.

**E quanto manca, in quattro voci separate perché sono lavori diversi:**

1. **Le facce fisiche non scritte**: Echo 39, Casate 26, tessere Regione 10.
   Stampano un testo che il motore *ricava* dai dati digitali — al tavolo si
   legge come una scheda tecnica, non come una carta.
2. **L'arte**: **135 soggetti su 146 sono segnaposto**. È il pezzo più grosso
   in quantità e il più facile da parallelizzare — i prompt sono già scritti.
3. **Le regole che il tavolo esegue e lo schermo non spiega**: ISSUES 80 (il
   Consiglio impilato, 71% contro 29%), 81 (una soglia non può leggere una
   memoria), 76 (la moneta che i Destini non spendono), 77 (i segni muti).
4. **L'app come oggetto**: ISSUES 63 e 65, e la regola §5ter — *nessuna misura
   copre quello che una persona vede*.

**Una colonna sola è scritta a mano, ed è dichiarata**: *dove l'app disegna
ogni componente*. Nessuna misura sa dire cosa una persona vede.

**Due errori trovati scrivendolo**, tutti e due dello stesso tipo — la misura
che guarda nel posto sbagliato: i soggetti d'arte erano 97 invece di 146 perché
le cartelle erano `entity/` e `destiny/` invece di `entities/` e `destinies/`,
e perché **le vite delle case hanno un volto ciascuna** e non venivano contate.
Il numero adesso combacia esatto col brief d'arte, che è generato da un'altra
strada.

---

## D-294 — Le otto case dichiarano, e tre vite morte si siedono

**implemented in 0.1.257** — passo (b) della linea delle trasformazioni ·
chiude [ISSUES 79](ISSUES.md#79-quattro-case-su-otto-non-hanno-un-profilo-e-quindi-non-hanno-una-soglia)

[D-293](#d-293) aveva detto qual era la leva più corta: gli incroci esistevano
quasi solo fra le quattro case con un profilo. Qui i profili diventano **otto**
— Cenere, Città Libere, Sale e Vetro, nella stessa forma di
[D-288](#d-288): una riga che dice cosa quella casa vuole lasciare, i segni
voluti e temuti col loro *perché*, e le `denies`.

E siccome il profilo è la chiave della porta del tempo, tre vite che non si
erano **mai** sedute in 168 salti d'era ne hanno ricevuta una: **Le Custodi
della Cenere**, **I Frati del Vetro**, **La Compagnia del Sale**.

**I numeri, sugli stessi semi di prima:**

| | prima | dopo |
|---|---|---|
| profili scritti | 4 | **8** |
| segni che incrociano (aiutano una casa, ne danneggiano un'altra) | 7 | **15** |
| **coppie di case con qualcosa per cui litigare** | 3 su 28 | **9 su 28** |
| trasformazioni sedute in 168 salti | 106 | **139** |
| Le Custodi della Cenere | 0 | **20** |
| I Frati del Vetro | 3 | **18** |
| vite mai sedute | 7 | **7** |

**Le tre cose che vanno dette perché sono negative o storte.**

1. **Le vite mai sedute restano sette**, e non è il numero di prima con dentro
   le stesse: le Custodi si sono sedute, e l'Inquisizione del Vetro — che
   c'era una volta sola — è scesa a zero, perché adesso il Vetro cambia pelle
   per il tempo prima che la reliquia venga mostrata. L'insieme è cambiato, il
   conto no.
2. **La Compagnia del Sale ha la porta e non si apre mai**, e la ragione vale
   per tutto il meccanismo: i segni che la Gilda vuole lasciare sono
   **memorie** — `debt_called`, `account_settled`, `ledger_public` — e una
   memoria, una volta scritta, **il mondo non la toglie più**. Una soglia che
   chiede *«tieni ancora?»* su una cosa che non si può perdere è una porta
   murata. *Una soglia deve leggere quello che il mondo sa togliere*:
   condizioni, controllo, Pietre. È il motivo tecnico più forte per passare
   alla grammatica ricca del documento (passo c).
3. **Un desiderio che la mappa porta da sola non è una strategia, è arredo.**
   Il Sale voleva `trade`, che è un segno stampato sulle tessere: presente
   quasi sempre, quindi incapace di distinguere alcunché. Sostituito con
   `ledger_public`, che è una cosa che si ottiene.

**Il ritmo tiene**: nessuna casa muta più spesso di **1 salto su 6,2** (Nahr),
e le due che prima non cambiavano mai — Vetro 1 su 42, Cenere mai — adesso
stanno a 1 su 9,3 e 1 su 8,4. Nessuno è diventato un costume.

**E la guardia si è rotta nel modo giusto**: il difetto piantato «porta del
tempo su una casa senza profilo» *cercava* una casa senza profilo, e il giorno
in cui tutte e otto ne hanno avuto uno è morto con un errore invece di dire che
non aveva più niente da provare. Adesso il difetto **si fabbrica** — è la
lezione di [D-286](#d-286), ripresa.

**Il costo dichiarato**: nessuno sul cancello (0 seggi bloccati su 8, misto e
uniforme; 607 prove).

---

## D-293 — Gli incroci: chi litiga con chi, e per cosa

**implemented in 0.1.256** — punto 1 della linea delle trasformazioni ·
[la misura](MISURA_MATRICE.md#5-gli-incroci-chi-litiga-con-chi-e-per-cosa)

Il documento del committente sulle trasformazioni mette al centro una frase:

> *«Gli stessi segni devono trasformare più Entità in direzioni diverse.»*

E chiede al validatore un controllo nuovo: **due Entità devono condividere
almeno un trigger che le influenzi in modo opposto**. Prima di farne un
cancello si misura quanto ne manca — un cancello che va rosso su venticinque
casi su ventotto non è un cancello, è un blocco.

`matrix_survey` guadagna la sezione 5. Per ogni segno mette insieme quello che
i **Destini** chiedono e quello che i **profili** dichiarano — comprese le
`denies`, che sono incroci scritti a mano: *«voglio impedire proprio questo,
proprio a lui»* significa che quel segno aiuta lui e danneggia me.

**Il numero, ed è severo:**

| | |
|---|---|
| segni che aiutano una casa e ne danneggiano un'altra | **7** |
| **coppie di case che hanno qualcosa per cui litigare** | **3 su 28** |

I sette: `crown_divided`, `nahr_settled`, `succession_by_law` (Aldric ↔ Nahr),
`discovery:crystal`, `knowledge_shared`, `mine_sealed` (Lyra ↔ Vaerax),
`structure:sealed` (Vaerax ↔ Cenere). **Cinque su sette cambiano anche la
pelle** di una casa, perché sono voluti da un profilo che ha una porta del
tempo ([D-290](#d-290)): perderli non sposta una clausola, sposta *cosa quella
casa diventerà*.

**La causa è strutturale, e si legge nella tabella**: gli incroci esistono
quasi solo fra le quattro case che un profilo ce l'hanno. Le altre quattro —
Cenere, Città Libere, Sale, Vetro — entrano solo dove un loro Destino nomina un
segno per nome, e i Destini nominano poco: **33 livelli su 69 si reggono su
conteggi**. Scrivere i quattro profili che mancano
([ISSUES 79](ISSUES.md#79-quattro-case-su-otto-non-hanno-un-profilo-e-quindi-non-hanno-una-soglia))
è la leva più corta su questo numero, ed è il passo dopo.

**Il conto è un pavimento**, dichiarato come quello delle Tensioni: guarda i
segni **nominati**, non i conteggi. Un Destino che chiede due Pietre litiga con
mezzo tavolo senza nominare niente — ma litiga allo stesso modo con tutti, e
qui interessa cosa fa litigare *queste due case e non altre*.

**Il cancello che il committente chiede resta spento**, e va scritto perché non
sembri dimenticanza: acceso oggi direbbe rosso su 25 coppie su 28. Si accende
quando il numero è buono, e la misura di oggi è il metro per saperlo.

---

## D-292 — Chi scrive nel mondo, e le Pietre che non lo dicevano

**implemented in 0.1.255** — la misura che viene prima del taglio 2 di
[ISSUES 80](ISSUES.md#80-il-consiglio-sono-due-consigli-impilati-e-a-decidere-e-quello-vecchio)

Il taglio 2 propone di cancellare la **frase d'autore** — la Proposta col suo
`success_consequences` — e lasciare che a scrivere sul mondo sia la carta. Prima
di cancellare si misura quanto scrive ognuno, perche' la differenza fra
*togliere un doppione* e *svuotare il gioco* e' un numero, non un'opinione.

`cli/run_who_writes_probe.gd`, 40 anni di CHR_01, 158 Consigli:

| chi parla | volte | Effetti raccontati |
|---|---|---|
| la frase d'autore | 221 | **489 (71%)** |
| la carta: benefici | 178 | 121 |
| la carta: prezzi | 62 | 28 |
| la carta: se cade | 84 | 47 |
| **la carta, in tutto** | 324 | **196 (29%)** |
| la clausola qualificata | 65 | 64 |
| gli Asset impegnati | 373 | 377 |

**Il taglio 2 non e' una cancellazione: e' un trasferimento.** Oggi la frase
d'autore scrive due terzi di quello che un Consiglio lascia; cancellarla senza
prima ingrossare le facce delle 60 Tensioni toglierebbe la meta' del contenuto
del gioco. Il numero e' scritto qui perche' la decisione la prenda il
committente sapendo quanto costa.

**E per misurarlo ho dovuto riparare due cecita', tutte e due vere.**

1. **La sonda non vedeva il trattino.** Il registro incolonna
   `- H. Beneficio: …`; la sonda cercava `H. Beneficio: ` in testa alla riga e
   leggeva **zero** per tutti. Sesta volta in questo progetto.
2. **La carta scriveva in silenzio.** La Conseguenza d'autore narrava ogni suo
   Effetto; la voce della carta no — il verbale diceva *«Beneficio: costruisci 1
   Pietra: Granaio»* e poi taceva su cosa fosse successo. Meta' del Consiglio
   cambiava il mondo **senza una riga**, e la prima misura (0 contro 443) era
   falsa per questo.

**E sotto ce n'era una terza, piu' vecchia**: il narratore non aveva una frase
per `BUILD_STRUCTURE`, `RAZE_STRUCTURE`, `SET_STRUCTURE_GRADE`,
`CLOSE_PASSAGE`, `OPEN_PASSAGE` — cioe' per **le Pietre e le strade**, le due
cose piu' fisiche della mappa. Un Granaio si alzava e nessuno lo leggeva; una
strada si chiudeva in silenzio. Adesso parlano: *«In Valle Verde si alza:
Granaio»*, *«Fra Valle Verde e Terre Nahr non si passa piu'»*.

I benefici raccontati passano da **89 a 121** con la sola aggiunta delle Pietre:
32 mutazioni della mappa che prima succedevano e non si vedevano.

**Il costo dichiarato**: nessuno sul cancello (0 seggi bloccati su 8). Il
verbale e' piu' lungo, ed e' il punto: quello che il tavolo non legge, al tavolo
non e' successo.

---

## D-291 — Il tabellone del Consiglio mostra la carta girata

**implemented in 0.1.254** — taglio 1 di [ISSUES 80](ISSUES.md#80-il-consiglio-sono-due-consigli-impilati-e-a-decidere-e-quello-vecchio)

Parola del committente, davanti all'app: *«il Concilio è ancora quello vecchio,
mi sa che va cambiato tutto»*. Aveva ragione su quello che vedeva, e la ragione
misurata è più precisa della frase: **lo schermo era vecchio al cento per cento,
le regole a metà.** Il tabellone disegnava la carta della Tensione, la Domanda,
la Proposta, le pose e le Conseguenze — la metà del 2024 — mentre il motore
eseguiva già l'economia di [D-280](#d-280): 245 benefici comprati in 158
Consigli, 62 prezzi scattati di cui 19 Cicatrici, il fronte avverso che sceglie
la moneta 29 volte. **Il 45% dei Consigli pagava qualcosa e non si vedeva.**

Questo è il **taglio 1**: nessuna regola cambia, si disegna quello che già
succede. Fra la Proposta e le pose il tabellone apre la carta girata:

- **COSA SI COMPRA** — tutti i benefici stampati, con la **pedina posata** (●)
  su quelli che il proponente ha comprato e la casella libera (○) sugli altri,
  e in testata il conto: *«2 comprati, prezzo: 1 costo»*. Con niente comprato,
  la riga dell'economia: *«un beneficio è gratis, ogni altro costa un costo»*.
- **IN CHE MONETA** — i costi stampati, con la pedina su quelli scelti, e tre
  testate diverse perché al tavolo sono tre situazioni diverse: non si paga
  niente, **la sceglie Kessa**, oppure *«il fronte avverso non ha ancora posato
  la pedina»* — che è un'attesa, non un silenzio.
- **LA CONTROPROPOSTA** ([D-268](#d-268)), quando c'è, con il nome di chi l'ha
  posata.
- **SE CADE** — le voci che scattano se la proposta non passa, che non sceglie
  nessuno. È l'informazione che rende «opponiti» una scelta invece di un gesto.

**Si legge dalla faccia stampata della Tensione, non dal template**, e dal
dizionario del Consiglio che il registro già rende: così vale identico su un
Consiglio aperto e su uno **già chiuso**, dove `current` non esiste più e il
tabellone disegna la fotografia di D-039.

**Una trappola di casa, ripresa in mano**: `_build()` girava solo in
`_ready()`, che non gira per un nodo costruito fuori dall'albero — la prima
prova che ha disegnato il tabellone è morta a metà invece di fallire. Adesso il
tabellone si costruisce da solo alla prima lettura, come fa la colonna.

**Il costo dichiarato**: nessuno — nessuna regola toccata, 0 seggi bloccati su
8, e la sequenza A–K è ancora intera. Restano i tagli 2 e 3 di ISSUES 80: la
Domanda e la Proposta dalla carta invece che dal template, e **chi decide** —
il d6 e gli impegni segreti contro l'economia. Quello aspetta la parola del
committente, ed è giusto che la aspetti guardando un Consiglio che si vede.

---

## D-290 — La soglia: il tempo, e quello che non tieni piu'

**implemented in 0.1.252** — [la misura](MISURA_VITE.md) · [ISSUES 79](ISSUES.md#79-quattro-case-su-otto-non-hanno-un-profilo-e-quindi-non-hanno-una-soglia)

Parola del committente:

> *«un re deve controllare due città e sopravvivere se passa poco tempo, ma se
> passano secoli due città non sono sufficienti per tenere il regno e questo si
> trasforma in una repubblica»*

Le case hanno già più **vite** ([D-108](#d-108)/[D-109](#d-109)): il popolo che
si insedia diventa regno, la scuola diventa culto, il regno diventa repubblica.
Il motore faceva due domande per aprirle — *c'è il segno?* e *la linea è
finita?* — e mai la terza: **da quanto**.

**Prima la misura** ([MISURA_VITE.md](MISURA_VITE.md), nei cancelli): delle 18
vite scritte oltre la prima, in **168 salti d'era** (12 saghe da 8 anni, sui due
tavoli, circa 780 anni l'una) **sette non si sono mai sedute** e altre cinque una
volta sola. Tre case sole — Nahr, Vaerax e le Città Libere, le tre che non
muoiono — si prendevano **88 trasformazioni su 88**. Fra le mortali, il Regno
che diventa Repubblica: **una volta su 168**, e per esaurimento della dinastia,
non perché avesse perso il regno.

**La seconda porta.** Una vita può dichiarare `also_enters: {after_years,
holds_at_least}`. Si apre quando sono passati almeno tanti anni da quando la
pelle corrente si è seduta **e** il mondo non porta più almeno tanti dei segni
che quella casa ha dichiarato di voler lasciare. Servono tutte e due: il tempo
da solo fa sedere un erede, la perdita da sola pure.

**L'elenco dei segni non si scrive sulla vita.** È il profilo strategico di
[D-288](#d-288), lo stesso file che leggono il cervello e la colonna di destra.
Un secondo elenco divergerebbe dal primo entro tre commit, e al tavolo sarebbero
due carte da leggere invece di una. Il validatore rifiuta la porta su una casa
senza profilo (regola morta) e la porta che chiede più segni di quanti il
profilo ne dichiara (casa condannata dal primo salto): due difetti piantati in
più nel self-test, che portano la guardia a 17.

**Il contatore.** Il seggio porta `life_years` — non l'età della casa, l'età
della **pelle**: riparte da zero a ogni trasformazione. Come `barren` e
`saga_score` è un passaggio di setup, non un Effetto, ed è fra le eccezioni
dichiarate all'effect-sourcing.

**Tre porte scritte**, sulle tre case con profilo che avevano una vita adatta:
la Repubblica della Valle (Aldric), il Culto della Misura (Lyra), la Diaspora
di Nahr. Tutte a 150 anni e 2 segni.

**Il numero, con le stesse 12 saghe:**

| | prima | dopo |
|---|---|---|
| trasformazioni sedute | 88 | **106** |
| Il Culto della Misura | 2 | **16** |
| La Repubblica della Valle | 2 | **6** |
| La Diaspora di Nahr | 0 | **0** |
| vite mai sedute | 7 | **7** |

**Due cose vanno dette, e sono tutte e due negative.** La prima: **la Diaspora
resta chiusa**, e non è un difetto — Nahr, una volta insediato, *tiene* quello
che voleva, e la regola sta funzionando. La seconda: **le vite mai sedute
restano sette**, perché cinque di quelle sette appartengono alle quattro case
che un profilo non ce l'hanno, e lì la porta non si può nemmeno scrivere. È
[ISSUES 79](ISSUES.md#79-quattro-case-su-otto-non-hanno-un-profilo-e-quindi-non-hanno-una-soglia).

**Il ritmo**, che era il rischio vero: nessuna casa muta più spesso di **1 salto
su 6** (Nahr 1/6, Vaerax 1/6.5, Città Libere 1/7.6, Lyra 1/10.5, Aldric 1/21).
Una casa che cambia pelle a ogni salto non ha un'identità, ha un costume: il
cancello di MISURA_VITE tiene anche questo numero.

**E si legge al tavolo.** La riga sta in fondo al blocco «COSA RESTERÀ DI TE»
della colonna — *«dopo 150 anni con meno di 2 di questi segni: diventi La
Repubblica della Valle»*, con sotto **da quanti anni la casa è quella che è** e
**quanti segni tiene adesso** — e sul **tarocco della Casata**, che resta in
vista tutta la partita: lì il profilo diventa una riga stampata («vuoi lasciare:
…») e la soglia la riga sotto. Senza quelle due righe la regola sarebbe un
rimando al manuale, che al tavolo vuol dire: non esiste.

**Il costo dichiarato**: nessuno sul cancello (0 seggi bloccati su 8, misto e
uniforme). La soglia vive nel livello **saga**, che oggi lo esercitano le sonde
e non l'app: una partita singola non la incontra mai.

---

## D-289 — Il profilo lo legge il cervello, e lo legge chi gioca

**implemented in 0.1.251** — [ISSUES 78](ISSUES.md#78-il-profilo-strategico-lo-legge-la-misura-non-il-gioco)

Il profilo di [D-288](#d-288) diceva cosa quattro case vogliono lasciare nel
mondo, e lo leggevano il validatore e la misura. Una strategia dichiarata e mai
giocata è un documento. Qui la leggono le due cose che contano: **il cervello
che sceglie** e **lo schermo di chi siede al tavolo**, dallo stesso file.

**Il cervello.** `PROFILE_WEIGHT = 3`, e una funzione sola — `profile_weight()`
— chiamata in due posti: quando si sceglie fra le due metà di una carta
(`_face_score`) e quando si compra al Consiglio (`_voice_score`). Non è una
regola nuova: è un peso in più nella bilancia che c'era già. Piccolo di
proposito — la legalità, il bersaglio a segni e il Destino restano davanti.
Posare un segno voluto vale, toglierlo costa; posare un segno temuto costa,
toglierlo vale; e posare quello che un rivale ha dichiarato di volermi impedire
vale doppio. Vale **zero** per le quattro case senza profilo, che giocano come
prima.

**E qui va scritto il numero, perché è quasi tutto negativo.** Misura appaiata,
40 anni, stessi semi, col peso a 3 contro il peso a 0:

| | senza profilo | col profilo |
|---|---|---|
| segni posati da chi li **voleva** | 17 | 17 |
| segni posati da chi li **temeva** | 17 | **14** |
| benefici comprati al Consiglio | 246 | 245 |
| di cui un segno che il proponente **voleva** | 15 | 15 |

Il peso evita **tre autolesioni in quaranta anni** e al Consiglio non sposta
niente. La ragione non è la bilancia: è [ISSUES 76](ISSUES.md#76-il-consiglio-decide-con-una-moneta-che-i-destini-non-spendono)
visto dall'altra parte — **il macchinario non produce quasi nulla di quello che
i profili nominano**, quindi non c'è niente da preferire. Un peso più grosso
non farebbe scegliere meglio: farebbe scegliere peggio le stesse cose. Il peso
resta com'è, ed è pronto per il giorno in cui le facce delle Tensioni e le voci
del Consiglio parleranno la moneta dei Destini.

**Lo schermo**, invece, cambia qualcosa subito. In fondo alla colonna di destra
c'è il blocco **COSA RESTERÀ DI TE**: la riga del profilo, poi una riga per ogni
segno voluto (verde) e temuto (rosso), **in oro quelli che sono sul tavolo
adesso** — il tavolo intero, fatti del mondo, Regioni e case. Il *perché* di
ogni voce è il suggerimento della riga. Si chiama così e non «cosa vuoi
lasciare» perché due righe sopra c'è già il **COSA VUOI** del Destino, e la
colonna che ripete se stessa è il difetto che [D-282](#d-282) ha chiuso. Una
casa senza profilo non mostra niente — né intestazione né spiegazione orfana.

**Il costo dichiarato**: nessuno sul cancello (0 seggi bloccati su 8, misto e
uniforme; 262 e 263 Verità). Il costo vero è che **la parte del cervello, oggi,
non si vede giocando**: sta scritta qui perché il giorno in cui ISSUES 76 si
chiude non la si scriva daccapo.

---

## D-288 — Il profilo strategico: cosa una casa vuole lasciare nel mondo

**implemented in 0.1.250** — primo file della matrice strategica

Il Destino dice **come si vince**. Il profilo dice **che mondo si vuole
lasciare**, e sono due cose diverse: Aldric vince tenendo il trono, ma quello
che vuole lasciare è una corona che passa per legge — e quella non è una
condizione di vittoria, è la ragione per cui gioca.

`godot/data/design_matrix/entity_strategic_profiles.json`, quattro case di
CHR_01, con schema suo. La forma è più stretta di quella che il piano
proponeva, e apposta:

**Si scrive a mano solo quello che non si può ricavare.** Il piano chiedeva
quattro file; due — l'incrocio dei tag e quello delle Tensioni — direbbero cose
che i dati dicono già (il dizionario dei segni, la faccia delle Tensioni, i
`focus_region_tags`), e **due file che dicono la stessa cosa divergono**. Qui si
scrivono solo `wants`, `fears` e `denies`, ognuno con il **perché** detto come lo
direbbe chi siede a quel posto; il resto lo calcola `tools/matrix_survey.py`.

**E il profilo ha subito una conseguenza, o sarebbe un documento.** Tre:

- il **censimento del validatore fisico** lo conta fra i lettori (`read_by:
  entity_strategic_profile` su 29 segni): un segno che una casa dichiara di
  volere non è più un segno che non serve a nessuno — gli orfani muti scendono
  da 15 a 13;
- **la misura lo legge** e ne ricava la sezione 4 di `MISURA_MATRICE.md`: per
  ogni desiderio, chi sa darlo — un Consiglio, una carta, una Conseguenza,
  nessuno;
- **lo schema lo valida**: un segno inventato in un profilo fa fallire il
  cancello dei dati.

**Il numero che ne esce, e che va guardato in faccia**: delle **16 cose** che le
quattro case vogliono lasciare nel mondo, **un Consiglio ne sa dare 4**. Le
altre dodici si ottengono con una carta, con una Conseguenza, o non si ottengono
affatto. È ISSUES 76 detto per casa invece che in generale, e dice dove la
matrice dovrà lavorare: **i benefici comprabili al Consiglio non producono
quasi niente di quello che qualcuno insegue.**

**Quello che questo file non fa ancora**: il cervello non lo legge, e lo schermo
nemmeno. Finché non lo leggono, la strategia è dichiarata e non giocata — ed è
il passo successivo, non un dettaglio: è quello che fa dire all'app *«questo
segno ti serve»* senza scriverlo due volte.

---

## D-287 — Le tre misure vengono prima della matrice, e come si contano

**implemented in 0.1.249** — punti 8, 9 e 10 del piano del committente

Il piano della matrice strategica chiede, prima di scrivere qualsiasi file
nuovo, tre elenchi: **tag orfani, obiettivi non fisici, Tensioni senza
conflitto**. Sono misure, e questo verbale scrive **come si contano**, perché
ognuna delle tre ha una definizione che si poteva prendere in tre modi diversi
e ognuno avrebbe dato un numero diverso.

Lo strumento è `tools/matrix_survey.py`, il documento `docs/MISURA_MATRICE.md`,
e sta fra i cancelli: una misura che invecchia in silenzio è peggio di nessuna
misura.

**Le tre definizioni, e le tre volte che ho dovuto cambiarle** — perché ogni
volta il numero era un assoluto, e un assoluto in questo progetto è quasi
sempre una sonda cieca:

1. **Orfano** = qualcuno lo scrive, e poi *nessuna Entità lo vuole o lo teme*,
   *nessuna Tensione lo mette o lo toglie*, *nessuna regola del segno lo usa*,
   *l'eredità non lo porta avanti*. La prima stesura guardava solo i Destini e
   diceva **84 orfani su 148**: mancavano gli obiettivi (D-222), le regole del
   segno e la pesca dell'era dopo (D-286). E gli orfani vanno **divisi in due**:
   quelli che portano già la loro ragione scritta (memorie narrate, etichette
   di famiglia, gradi di pietra) e quelli **muti**. Sono i muti la lista di
   lavoro.
2. **Obiettivo che non si può puntare col dito** = una clausola che chiede un
   segno che **niente scrive** (impossibile), oppure un livello intero che non
   nomina nessun segno e si regge su conteggi. Il primo conto diceva **una
   clausola impossibile**: il Trionfo di Vaerax, che chiede
   `legend:crystal_exploited` — e le leggende le scrive **il tempo**, al salto,
   non i dati. Impossibile non era: era la misura che non conosceva quella
   penna.
3. **Tensione senza conflitto** = non tocca nessun segno che un Destino
   **nomina**. Qui gli assoluti sono stati due, uno per parte: contando i soli
   segni nominati veniva **60 su 60 senza conflitto**; aggiungendo i conteggi
   *e il controllo* veniva **0 su 60**. Il controllo va tenuto fuori — ogni
   cambio di controllo aiuta chi prende e danneggia chi perde, quindi vale per
   tutte e sessanta e non distingue niente — e `physical.observes` non è un
   desiderio: elenca insieme quello che una casa insegue e quello che teme, e
   dice *a chi interessa*, non chi ci guadagna.

**Il numero che vale il viaggio.** Tutte e 60 le Tensioni hanno un conflitto
*strutturale* — la faccia alza una Pietra e incide una Cicatrice, e i Destini
contano l'una e l'altra — ma è **identico su tutte**: è il modello della faccia
(D-280), non è contenuto. Il conflitto che distingue una questione dall'altra è
quello nominato, e lì **35 Tensioni su 60 non incontrano nessun Destino**.

Detto altrimenti, e questo è l'argomento più forte a favore della matrice che il
committente chiede: **il Consiglio decide con una moneta che i Destini non
spendono.** I benefici che si comprano producono segni che nessun Destino
nomina; dei 24 segni che le facce delle Tensioni posano, **tre** sono temuti da
qualcuno per nome, e dei 17 voluti **nessuno** si può ottenere da un Consiglio.

---

## D-286 — Quindici memorie tornano a mordere, e tre penne si erano nascoste

**implemented in 0.1.248** — passo 2 del brief del Punto Zero

**Prima, una correzione a quello che avevo scritto io.** Nella diagnosi avevo
dato le *«27 Memorie che nessuno legge»* come difetto. Non lo erano: **ognuna
delle 27 porta la sua ragione scritta**, e quindici dicono *«memoria del mondo:
narrata (D-103), ereditata»*. Il progetto aveva già applicato la sua regola —
quello che non morde si dichiara. Il difetto vero era un altro, ed è più
piccolo e più utile.

**La pesca dell'era successiva ascolta** (D-079): una domanda i cui echi sono
ancora sul tavolo pesa il triplo. Quel meccanismo non ascoltava **nessuna
memoria del mondo**: ascoltava condizioni e strutture. Così una Carta che vale
per un tempo solo, un cristallo misurato, una successione con testimoni, dei
diritti d'acqua venivano scritti dal Consiglio e poi **non tornavano a chiedere
niente**. Adesso quindici di quelle memorie stanno negli `echoes` delle
Chronicle, ognuna accanto alla domanda che è sua.

Misurato (`cli/run_memory_probe.gd`, 30 anni): **21 anni su 30** finiscono con
almeno una memoria che chiama la sua domanda per l'anno dopo. Prima erano zero.
Il conto è un **pavimento**, non un soffitto: la sonda attribuisce la chiamata
al primo segno che trova, e una domanda già chiamata da una condizione non
mostra la sua memoria.

**E tre penne si erano nascoste.** Facendo leggere quelle memorie sono usciti
tre buchi nei censimenti — vecchi, e invisibili finché nessuno leggeva:

1. **il censimento del validatore fisico non vedeva la Chronicle**: i segni
   negli `echoes` sono letti dalla pesca, e nessuno lo dichiarava. Erano 39
   segni con la mano non dichiarata, non solo i miei;
2. **il registro dei segni non vedeva la penna del Consiglio** (le clausole
   `condition_clauses[].effects`) né **la penna della faccia delle carte**
   (`puts_tag`/`clears_tag`, che da D-283 scrivono davvero) né **l'occhio della
   faccia** (il bersaglio a segni, la Risonanza che teme un segno);
3. **e un gancio d'Echo su due**: la forma `effect` singolare non veniva
   guardata, quindi «ci si è parlato» e «la richiesta è stata ascoltata»
   risultavano chieste da una Risonanza e scritte da nessuno.

Tutti e tre adesso sono censiti, e il registro torna a dire il vero: restano
quattro segni muti dichiarati con la loro ragione, e uno chiesto-e-mai-scritto
dichiarato (`structure:road`, che il motore conta dalle strutture invece di
posarlo).

**E il difetto piantato che era scaduto.** Il self-test piantava
`charter_temporary` come «segno che nessuno legge»; il giorno in cui quella
memoria ha trovato un lettore la guardia ha smesso di mordere **senza che niente
fosse rotto**. Adesso il difetto si sceglie il segno muto dal dizionario: un
difetto che nomina un dato che può cambiare è un difetto che scade.

Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme. Suite 589 prove.
Guardia del dizionario: **15 difetti piantati**, tutti mordono.

---

## D-285 — Un'Occasione non si butta: il cervello aveva mosse, non fame

**implemented in 0.1.247** — passo 4 del brief del Punto Zero

Il problema n° 3 del committente: *«i giocatori passano troppo spesso: il turno
non genera abbastanza decisioni significative»*. Misurato: si passava l'**82,1%
dei turni**, e due terzi di quei passa erano *«mosse legali, nessuna che gli
servisse»* — **con sette carte in mano e quindici mosse legali in media**.

Non era il mazzo, e non erano le regole. Erano **due difetti, uno dentro
l'altro**:

1. **Il ripiego non veniva mai provato.** Il cervello sceglie un'intenzione e
   poi cerca la carta che la dica (`_as_card_play`). Quando l'intenzione era
   PASSA, quella funzione tornava indietro **alla prima riga**: il ramo
   *«fai quello che la mano permette»*, scritto e commentato, non veniva
   raggiunto mai.
2. **E la lista delle mosse possibili era quasi sempre vuota**, anche quando
   veniva chiesta: guardava **un solo verbo per carta** — quello dichiarato, non
   quelli stampati (D-283) — e **un solo bersaglio per verbo**. Sette carte in
   mano producevano zero voci.

**La regola nuova**: quando nessuna intenzione scatta, si gioca la **più debole
che la mano permette**, fra tutte le Azioni stampate e tutti i bersagli che
quelle Azioni accettano. Due mosse non si propongono mai, perché sono danni che
il cervello si farebbe da solo per noia: **spingere una domanda dalla parte
sbagliata**, e **rompere un patto**.

**E si tiene la riserva.** Al tavolo una carta calata è una carta che al
Consiglio non vota — e il mondo ricorda **solo i Consigli in cui qualcuno ha
messo peso** (`EchoRecorder.should_record`). Una mano svuotata sulla mappa è
quindi un anno che lascia meno scritto: è il quadrante fra *«le Azioni cambiano
il mondo»* e *«il Consiglio decide cosa il mondo ricorderà»*.

**Taratura d'autore, misurata** (100 semi, tavolo misto). La riserva è il
quadrante, e questi sono i suoi scatti:

| riserva | si passa | Verità scritte | Consigli |
|---|---|---|---|
| — (prima) | 82,1% | 295 | 3,67 |
| 3 | 37,3% | 227 | 3,75 |
| **4** (`max_commit_assets + 1`) | **42,1%** | **256** | **3,80** |
| 5 | 47,2% | 252 | 3,81 |

**Il costo, scritto**: le Verità scritte scendono da **295 a 256** (−13%). Non
è un difetto del correttivo, è la regola del gioco che si vede: chi spende sulla
mappa ha meno peso da mettere nel Consiglio, e un Consiglio senza peso non
lascia memoria. Se il committente vuole un mondo più scritto e turni più fermi,
il numero da muovere è la riserva, ed è una riga.

**Le altre misure** (`run_card_ledger`, 100 anni):

| | prima | dopo |
|---|---|---|
| carte pescate che si calano | 23,2% | **55,0%** |
| FORGIARE calato | 5,9% | **46,6%** |
| RIVENDICARE calato | 19,6% | **60,9%** |
| carte **mai calate** in 100 anni | 3 | **0** |
| carte mai impegnate al voto | 0 | 0 |

Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme — e ogni seggio
adesso tocca più di un livello.

**Prove**: `test_an_opportunity_is_not_wasted.gd` — a mano piena non si passa,
alla riserva si tiene, la lista guarda tutte le facce e tutti i bersagli, e le
due mosse che fanno male non si propongono mai.

---

## D-284 — Il segno stampato ha un posto: la carta dice dove, chi cala sceglie

**implemented in 0.1.246** — passo 1bis del brief del Punto Zero

D-283 ha fatto posare i segni stampati sulle Azioni. **Ne restavano fuori 314 su
851**, quasi tutti condizioni di Regione in mosse che una Regione non la
nominano: INFLUENZARE parla a una domanda, FORGIARE a una casa, RIVENDICARE a un
dominio. Il segno non si scriveva altrove — sarebbe stato posare un segnalino
dove al tavolo nessuno saprebbe metterlo — e quindi **la carta diceva una cosa
che non succedeva**.

**Al tavolo la risposta è già stampata**: il bersaglio si dice a segni (D-274).
«Chiudere i granai» non chiede *quale domanda*: chiede **quale granaio**. Quindi
chi cala nomina il posto dove i segni cadono, e può nominare solo un luogo che
la carta raggiunge — la stessa promessa del bersaglio, sull'altro pezzo della
faccia, con il suo rifiuto detto nella stessa lingua.

**Ed è una scelta vera**, non una formalità: posare `#conteso` sulla capitale di
un rivale non è come posarlo su casa propria. Il cervello sceglie il posto col
metro dei segni già introdotto da D-283 (una condizione sulla mia terra pesa
contro, altrove pesa a favore); una persona lo sceglie **sulla mappa**, perché
ogni posto possibile è una voce che porta la sua Regione nel soggetto e quindi
si accende (D-230): si tocca la carta, si accendono i luoghi, si tocca il luogo.

**Misure** (100 anni, tavolo misto):

| | D-283 | dopo |
|---|---|---|
| segni stampati sulle Azioni calate | 851 | 862 |
| **posati sul mondo** | 537 | **862** |
| **senza un soggetto** | 314 | **0** |
| carte calate con la seconda Azione | 16,6% | 17,0% |
| si passa | 82,3% | 82,1% |

Playtest 100 semi: **0 seggi bloccati su 8**, misto e uniforme.

**Una cosa che la misura ha detto e che non sapevo.** I primi segni rimasti
senza casa dopo il correttivo non erano un caso di contenuto: erano le carte
calate dalla **lista di ripiego** del cervello (`hand_plays`, quella da cui pesca
il distratto), che non aveva imparato a scegliere il posto. Due strade per la
stessa mossa, e ne avevo insegnata una sola — la stessa forma della trappola di
D-268.

**Prove**: `test_the_sign_finds_its_place.gd` — il posto lo dice chi cala, un
posto che la carta non raggiunge si rifiuta a segni, il menu offre un luogo per
voce e ognuna si accende sulla mappa, e su **tutte e 48 le carte** un posto si
chiede esattamente quando serve.

---

## D-283 — La faccia è la verità: entrambe le Azioni stampate si giocano

**implemented in 0.1.245** — passo 1 del brief del Punto Zero

> «Rendere entrambe le azioni delle carte Asset realmente eseguibili dal motore
> e visibili nell'app.»

**Com'era.** Una carta si poteva calare **solo col verbo dichiarato** in
`card_action.kind`. La seconda Azione stampata era inchiostro — anche quando
portava già un verbo che il motore sa fare, e lo porta in **37 carte su 48**. E
i segni che le Azioni posano (`puts_tag`, `clears_tag`: 71 occorrenze su 33
segni diversi) non venivano eseguiti mai.

**La regola nuova, in una riga: i verbi di una carta sono quelli stampati sulla
sua faccia.** Chi gioca dice *quale delle due Azioni* sta calando — `face_action`
è l'indice — e il verbo viene da lì. Senza indice si ricade sul verbo dichiarato,
che è quello che fanno i salvataggi vecchi.

**E i segni stampati si posano davvero**, ognuno dove il dizionario dice che vive
(D-259): GLOBAL sul mondo, REGION sulla Regione che l'azione ha nominato, ENTITY
sulla casa. Sono loro a rendere **diverse** le due metà: **29 carte su 48
stampano lo stesso verbo due volte**, e senza i segni le due metà farebbero la
stessa identica cosa — una scelta finta, quella che il validatore vieta alle
Tensioni.

**Il segno stampato si firma** (`kind: "face_action"`, la regola di D-030): nello
stesso istante il verbo posa segni suoi — TRAMARE lascia le sue scoperte — e
senza la firma non si distinguono. La prima stesura della sonda li contava
insieme e diceva 242 dove i segni della faccia erano 114.

**Taratura d'autore, dichiarata.** Fra due metà dello stesso verbo il cervello
sceglie sui segni: una condizione che cade sulla mia terra o su casa mia pesa
contro, una che cade altrove pesa a favore, una memoria vale poco e sempre
positiva, e a parità vince la prima — quella che la carta stampa per prima.
Senza questa regola il cervello avrebbe sempre giocato la prima metà.

**Misure** (100 anni, tavolo misto):

| | prima | dopo |
|---|---|---|
| carte calate con la **seconda** Azione | 0 | **235 su 1.412 (16,6%)** |
| segni stampati posati sul mondo | 0 | **537** (su 851 stampati) |
| carte pescate che si calano | 23,2% | 24,5% |
| RIVENDICARE calato | 19,6% | **33,0%** |
| FORGIARE calato | 5,9% | 8,0% |
| si passa | 84,3% | **82,3%** |

**Il costo, scritto.** Il passare scende di due punti, non dei venticinque che
speravo: la prima ragione per cui un seggio passa non erano i verbi della mano
— è *«mosse legali, nessuna che gli servisse»*, che sale dal 54,7% al 65,1% dei
passa. È **appetito del cervello**, non grammatica delle carte, e va aggredita
da lì. Restano **314 segni su 851** che non trovano il proprio soggetto (una
condizione di Regione in una mossa che non nomina nessuna Regione): non si
scrivono altrove, si contano, ed è il passo 1bis della diagnosi.

**Una conseguenza da guardare, committente.** Con la faccia come verità,
`AST_BONDS_OLD_DEBT` — che dichiara RIVENDICARE e stampa INFLUENZARE e
FORGIARE — smette di essere una carta da RIVENDICARE. È la vecchia questione
aperta, risolta *di fatto* in favore della faccia. Se la vuoi RIVENDICARE, la
faccia deve stamparlo.

**Prove**: `test_both_printed_actions.gd` — la seconda metà lascia il suo segno,
il segno si firma, si disfa (è un Effect col suo inverso), un segno senza
soggetto non finisce altrove, e la scatola così com'è spedita offre **due voci**
per una carta a due metà, coi nomi stampati sulla faccia.

**Sonda**: `cli/run_mark_probe.gd`.

---

## D-282 — La colonna di destra si legge: un blocco, una riga che dice cos'è

**implemented in 0.1.244** — parola del committente

> «Poi sulla colonna di destra non si capisce nulla: ci sono i mazzetti dei
> temi, le domande dell'anno (?), i rapporti, i segni della casa, il destino,
> poi ancora quattro tensioni (?)»

Due difetti, e il punto interrogativo era su quello grosso.

**La stessa cosa era lì tre volte.** I sei mazzetti disegnati (D-279), la riga
«CALORE» che li ripeteva a parole, e le quattro questioni con le barre. Sotto
c'è una vera sovrapposizione di regole — il gioco ha *due* economie della stessa
domanda, le quattro questioni dell'anno e i sei mazzetti (vedi
[la diagnosi](DIAGNOSI_PUNTO_ZERO.md#32-le-domande-sono-due-sistemi-sovrapposti))
— e non la si chiude con una modifica allo schermo. Quello che lo schermo poteva
fare l'ha fatto: la riga duplicata è via, e le quattro si chiamano per quello
che **sono** — *«le questioni già aperte»*, il ripiego per l'Atto in cui nessuna
Risonanza ha scaldato niente. Chiamarle «le domande dell'anno» insegnava una
regola che il gioco non ha più.

**E nessun blocco diceva a cosa servisse.** Al tavolo non serve: una plancia ha
le sue caselle stampate, con la scritta accanto. Sullo schermo quella scritta
non c'era, e sei blocchi muti sono arredo, non informazione. Adesso ognuno ha
la sua riga, piccola e grigia: si legge la prima volta e poi si smette di
vederla, che è esattamente il comportamento di una stampa sulla plancia.

**Prove**: `test_the_column_can_be_read.gd` — ogni intestazione visibile ha la
sua riga sotto; nessuna riga sopravvive alla cosa che spiega (i Diritti e i
segni spariscono quando sono vuoti, e la spiegazione con loro); e la stessa
cosa non si dice due volte.

---

## D-281 — Il turno si vede: la mano era morta, e la colonna era vuota

**implemented in 0.1.243** — parola del committente, aprendo l'app

> «L'app non mi fa giocare le carte, non so quali azioni fare, e la GUI mi dice
> di trascinare una carta dove voglio usarla??? (in che senso???) Non capisco
> quale meccanismo stai usando per il turno di gioco.»

Sotto ci sono tre cose, e la prima **e' un difetto vero, non una questione di
gusto**.

**1. La mano era morta.** `GameScreen.ask()` chiama `_refresh()` in cima — ed e'
`_refresh()` che disegna la mano — e costruisce `_offers` (cosa porta ogni
carta adesso) **dopo**. Le carte venivano quindi disegnate col carico vuoto, e
una carta col carico vuoto non si prende e non si trascina: `_gui_input` e
`_get_drag_data` escono subito. Per tutta la domanda, in ogni turno di ogni
partita giocata a schermo, **nessuna carta era giocabile**. Il difetto stava fra
due righe giuste ognuna per conto suo, e nessuna prova lo vedeva: quelle sul
trascinamento (D-230) riempiono il carico a mano, e nessuna legava **la domanda
alla mano**. Adesso `ask()` ridisegna la mano con le offerte, e
`test_a_turn_can_be_played` tiene il ponte.

**2. La colonna era vuota.** D-238 aveva tolto dalla colonna ogni scelta con un
posto dove cadere — *«la gui deve prevedere movimenti drag & drop, non pulsanti
che dicono cosa fare»*. Quando **tutte** le scelte ce l'hanno, la colonna resta
vuota: chi non sapeva gia' di dover toccare una carta si trovava davanti a un
turno senza niente da premere. Il correttivo non riporta indietro D-238: la
colonna non elenca le *mosse*, elenca **le carte che parlano adesso** e quante
mosse portano. Premerne una e' lo stesso gesto di toccarla nel ventaglio — la
carta va in mano, si accendono i posti, e la colonna diventa la scheda della
carta (D-279). Il ventaglio resta il modo bello di giocare; questa e' la strada
che nessuno puo' non vedere.

**3. Il gesto si diceva sbagliato.** *«Trascina una carta dove vuoi usarla»*
descrive un movimento che su un tablet non esiste (D-243) e che comunque non
diceva dove. Adesso: *«Tocca una carta della tua mano: si accendono i posti dove
puoi giocarla»*. E una carta che porta una mossa **si vede**: bordo acceso, come
il cerchio d'oro di una Regione raggiungibile; le altre si spengono a meta'
finche' la domanda e' aperta. La promessa e' sempre quella di D-039: dove c'e'
il segno, la mossa e' gia' legale.

**Il meccanismo del turno, per intero** (nessuna regola cambia qui, e' la
risposta alla terza domanda): l'Atto ha 3 round, ogni round da' a ogni seggio
**2 azioni**, e i seggi giocano nell'ordine del tavolo. Un'azione si spende
**calando una carta della propria mano** — la carta porta due Azioni stampate e
un bersaglio a segni (D-274) — e ogni carta calata fa cadere un gettone coperto
sul Tema che la carta scalda (D-260/D-261). A fine Atto il Tema piu' caldo apre
il suo Consiglio: si gira la Tensione, il proponente compra i benefici e gli
avversari scelgono in che moneta paga (D-280), tutti si impegnano, e quello che
il Consiglio decide resta scritto.

**Prove**: `tests/unit/test_a_turn_can_be_played.gd` — la mano viva mentre la
domanda e' aperta, il turno che non lascia mai lo schermo senza una strada,
la colonna che nomina le carte (mai un id), la riga che si tocca al posto della
carta, il suggerimento che parla un gesto che un dito puo' fare. La prima delle
cinque, tolta la riga del correttivo, torna rossa.

---

## D-280 — L'economia del Consiglio: benefici comprati, prezzo scelto dagli altri

**implemented in 0.1.242** — carta d'esempio del committente

**Costruita.** Il vocabolario chiuso di undici verbi sta in
`scripts/confluence/council_economy.gd` (codice, perche' ogni verbo **produce
Effetti**); le 60 carte lo nominano e lo parametrizzano — quale condizione
lascia, quale Pietra alza, quale Cicatrice incide. Il giro del Consiglio ha due
passi nuovi: il proponente **compra** dopo la proposta, il primo del fronte
avverso **sceglie il prezzo** prima degli impegni. Alla risoluzione: se passa si
applicano benefici **e** costi, se cade scattano gli effetti stampati.

**Una taratura d'autore, dichiarata.** Il cervello sapeva pesare solo cio' che un
Destino nomina: davanti a verbi generici leggeva zero su tutto, comprava il
beneficio gratis e non pagava mai — 1,01 benefici a Consiglio, economia morta.
Ogni verbo ha adesso un **valore intrinseco situazionale**
(`CouncilEconomy.intrinsic_value`): un titolo che gia' tieni non vale prenderlo,
una condizione su una tessera che non e' tua non ti pesa come su una che e'
tua, una Cicatrice pesa sempre. E a parita' si compra: col confronto stretto il
cervello si fermava sempre al primo.

**I numeri (40 anni di CHR_00):** 1,53 benefici comprati a Consiglio — due
pedine 66 volte, tre 5 volte — **61 prezzi pagati**, 29 dei quali Cicatrici.
Cancello **0 seggi bloccati su 8** (100 semi, misto e uniforme); suite **568
prove / 33.172 asserzioni**; guardia del validatore su **15** difetti piantati.

---

### Come ci si è arrivati, e cosa correggeva

Il committente ha mandato **la faccia vera di una carta Tensione**, e ha
chiesto: *«non dovevano esserci dei benefici che il proponente poteva
scegliere, e dei costi che il proponente o gli altri giocatori dovevano
scegliere? Questi Benefici e Costi dovevano essere collegati alla mappa
tramite i Tag di Edifici, cicatrici e condizioni. Oppure hai scordato?»*

**Aveva ragione, e D-278 Fase A ha sbagliato macchina.** Quella fase ha messo
le liste **nel posto giusto** — sulla carta — e ci ha scritto **la cosa
sbagliata**: 240 frasi d'autore, una scelta secca fra due voci. La carta dice
un'altra cosa, e migliore:

| | D-278 Fase A (fatta) | quello che la carta dice |
|---|---|---|
| cosa sono | frasi d'autore, diverse su ogni carta | **verbi chiusi e ripetibili** |
| a cosa sono legati | a una Conseguenza scritta nei dati | **ai segni della mappa**: condizioni, pietre, cicatrici, controllo, Calore |
| come si scelgono | una voce sola, dal primo oppositore | **pedine posate sulla carta**: max 3 benefici, max 2 costi |
| l'economia | non c'è | **1 beneficio è gratis; ogni beneficio in più costa 1 costo; una Cicatrice ne compra uno oltre il limite** |
| se cade | una seconda lista da cui scegliere | **effetti fissi stampati** |

**Il vocabolario** (dalla carta):
*benefici* — RIAPRI (via `#chiuso`), RIMUOVI CONDIZIONE, COSTRUISCI PIETRA,
CAMBIA CONTROLLO, RAFFREDDA TEMA;
*costi* — AGGIUNGI CONDIZIONE, PEDAGGIO (`#pedaggio`), CEDI CONTROLLO, SCALDA
TEMA, PRENDI DEBITO (`#indebitata`), CICATRICE.

**Chi posa cosa** (parola del committente, scelta fra tre): **il proponente
compra i benefici, gli avversari scelgono in che moneta paga** — un costo per
ogni beneficio oltre il primo. Il proponente sa *quanto* paga; non sa *in
cosa*.

**Due cose che cadono**, dichiarate dal committente rispondendo:

1. **niente costo di apertura**: il numero in alto a destra sulla carta
   d'esempio era esemplificativo. La Tensione **si risolve a fine Atto**, come
   il motore già fa (D-214, D-260, D-261);
2. di conseguenza **la soglia non si stampa più sulla faccia**: era la domanda
   aperta della Fase C di ISSUES 72, e questa la chiude.

**Cosa resta di D-278 Fase A.** Il ponte nel motore (il menu del prezzo letto
dalla faccia della carta invece che dal pool del template) e la guardia 18
restano: sono la strada su cui questa economia passerà. Le 240 frasi e la
tavolozza di Conseguenze diventano **materiale di partenza** per i verbi, non
la forma finale. Il lavoro è in ISSUES 72, riscritta.

---

## D-279 — L'app come la vuole il tavolo: la soglia sceglie, la mappa è a tessere

**implemented in 0.1.241** — sei correzioni del committente, sulla partita provata a schermo

Il committente ha giocato il prototipo e ha scritto sei cose. Cinque sono
fatte qui; la sesta — la carta Tensione — è D-280, perché non è una
correzione dell'interfaccia ma della regola.

1. **La soglia è la copertina, e lì si compone il tavolo.** *«Lo splash screen
   deve essere con questa immagine, lì devo scegliere i seggi e i giocatori
   (chi è persona e chi Bot).»* La copertina consegnata sta in
   `art/ui/copertina.png`; sopra, una riga per seggio con un bottone che passa
   da **Bot** a **Persona**. La scelta viaggia in `TableChoice` — statico e non
   un autoload: sono tre righe fra due schermate.
2. **La sala non chiede più niente.** Via *«quale seggio prendi»* (si sceglie
   sulla soglia), via *«che mondo?»* — **il mondo si pesca**, come le tessere.
   Le tre funzioni che facevano quelle domande escono dal codice.
3. **Via la schermata «Come si gioca».** Non si apre all'avvio, non ha più un
   bottone, non copre più la mappa.
4. **Le tessere sono quadrate e accostate**, in griglia 3×2 col loro quadro
   dipinto **per intero**: *«non a esagoni»*. L'esagono ritagliava metà del
   quadro consegnato e disegnava una forma che sul tavolo non esiste. Cadono
   anche le strade disegnate: le tessere si toccano, e vicino è chi si tocca
   (D-275). Il dito prende il quadrato — col cerchio, i quattro angoli di ogni
   tessera non rispondevano.
5. **I sei mazzetti dei Temi si vedono, tutti e sei**, coi gettoni sopra e la
   carta girata quando c'è. La regola il motore la eseguiva già da D-261
   (gettoni coperti, e alla soglia dichiarata la prima carta si gira): quello
   che mancava era **vederlo** — sullo schermo c'era una riga di testo che
   nominava solo i Temi già caldi.
6. **Le carte in mano hanno una scheda.** *«Non si capisce come usarle, non c'è
   nessuna GUI per gestire il loro uso.»* Prendendo una carta si legge adesso
   la **sua faccia**: il bersaglio a segni, le **due Azioni** col loro nome, e
   sotto ognuna i posti dove può andare. Il ponte è il **verbo**, che ora
   viaggia con l'offerta (`subject.verb`): senza, lo schermo non poteva legare
   una scelta legale all'Azione stampata, e mostrava l'etichetta grezza del
   motore.

**Un difetto che questo lavoro mette in luce, e che resta aperto:** una carta
si può giocare solo col verbo che dichiara al motore (`card_action.kind`),
quindi **la seconda Azione stampata spesso non è eseguibile** — la scheda lo
dice invece di nasconderlo («questa metà della carta il motore non la esegue
ancora»). È ISSUES 69, e adesso si vede.

Misure: playtest 100 semi **0/8** misto e uniforme; suite **567 prove /
24.887 asserzioni**; cancelli verdi. Nessuna regola toccata.

---

## D-278 — Le due liste sulla carta Tensione: il cuore, misurato

**implemented in 0.1.240 (Fase A)** — richiamo del committente, e aveva ragione

> «nelle tensioni ci dovrebbero essere anche i vantaggi e gli svantaggi che
> possono essere scelti e proposti durante il consiglio, dove sono? Non sono
> stati né implementati né misurati. Dovrebbe essere il cuore del gioco.»

**Quello che ho trovato guardando, prima di rispondere.** Il *meccanismo*
c'era: il proponente sceglie fra le proposte (D-267/D-268), il primo del fronte
avverso posa la pedina del prezzo e una voce sola scatta. Il *contenuto* no, e
i numeri lo dicevano senza appello:

| | prima |
|---|---|
| carte con un menu di proposte proprio | **8 su 60** (52 condividono 4 template generici di dominio) |
| menu di proposte distinti in tutto il gioco | **12** per 60 carte |
| **menu di malus distinti in tutto il gioco** | **1** — la stessa coppia `CNS_COST_UNREST`/`CNS_COST_DEBT` su **tutte e sessanta** |
| domande con una sola proposta (nessuna scelta) | **40 su 107** |

Cioè: al tavolo, la scelta del fronte avverso era sempre la stessa coppia, e su
40 domande su 107 il proponente non sceglieva niente. Una regola c'era; il
gioco che quella regola dovrebbe reggere, no.

**La decisione: le due liste stanno sulla carta**, come sta la Domanda (D-266).
Il blocco `physical` della Tensione porta `costs`, `failures` e (Fase B)
`opportunities`; ogni voce ha **le sue parole** e la Conseguenza che il motore
esegue. Il motore legge il menu del prezzo **dalla faccia della carta**, e il
pool del template resta il ripiego dichiarato per chi una faccia non ce l'ha.

**Fase A, fatta qui — i malus:**

1. **La tavolozza del prezzo**: dodici Conseguenze nuove (sei costi, sei
   sfoghi), ognuna che toglie una cosa diversa — razione, guardia, spopolamento,
   spremitura, lutto, parola fredda; conteso, strada chiusa, razzia, abbandono,
   voce che corre, domanda incisa sul muro. Due voci che tolgono la stessa cosa
   non sono una scelta.
2. **Le 60 carte** portano due costi e due sfoghi ciascuna, **240 testi tutti
   diversi**, scritti per la loro domanda.
3. **Il tavolo legge le parole della carta**: il verbale e la console mostrano
   la voce com'è scritta, non il titolo della Conseguenza.
4. **La scheda della domanda le mostra** — e per tutte: cercando il template
   solo per id, la scheda diceva *«Nessun Consiglio scritto per questa domanda»*
   su **52 domande su 60**. Adesso lo trova come lo trova il motore.
5. **Il segno della domanda caduta è del motore, non del malus.** Lo scriveva
   `CNS_FAILURE_SPIRAL`, una voce fra le tante: con lo sfogo scelto dagli
   avversari, il mondo si sarebbe ricordato della caduta *solo se l'avversario
   avesse scelto la voce giusta*. Che una proposta sia caduta è un fatto del
   tavolo e resta sul tavolo comunque.
6. **Guardia (controllo 18) e sonda.** Il validatore rifiuta liste monche, voci
   con la stessa Conseguenza, testi identici, Conseguenze inesistenti — e il
   self-test lo pianta su due difetti nuovi (14 in tutto). La sonda del prezzo
   conta **quante voci diverse il tavolo ha davvero letto**.

**I numeri, dopo:**

| | prima | dopo |
|---|---|---|
| menu di costo distinti | 2 | **21** |
| menu di sfogo distinti | 2 | **25** |
| voci di costo diverse in gioco | 2 | **8** |
| voci di sfogo diverse in gioco | 2 | **8** |
| testi distinti sulle carte | 0 | **240 su 240** |
| voci di costo lette al tavolo (40 anni, CHR_00) | ≤2 | **34** |
| voci di sfogo lette al tavolo (40 anni, CHR_00) | ≤2 | **34** |

Cancello: **0 seggi bloccati su 8** (misto e uniforme, 100 semi). Suite
**564 prove / 24.886 asserzioni**.

**Quello che costa, scritto.** Il malus adesso morde la questione di cui si sta
parlando invece di una lontana (`$tension` invece di un id fisso): il piano di
simulazione `plan_d_crown_calls` chiude l'ultimo Consiglio con
`SUCCESS_WITH_COST` dove prima faceva `SUCCESS` — il tavolo arriva all'ultimo
dibattito un gradino più in basso. È il prezzo della scelta vera, ed è scritto
nel piano. Sette segni nuovi nascono **muti con ragione** (dichiarati nel
dizionario e nel registro): si leggono sul tavolo, nessuna clausola del motore
li interroga ancora — `condition:guarded` è il primo candidato a mordere.

**Resta aperto, e va detto:** la Fase A ha dato al fronte avverso la sua metà
del cuore. **Le opportunità del proponente sono ancora quelle dei 12 menu
condivisi** (Fase B), e la revisione di **soglia e velo** sulla faccia della
carta — che con il Calore dei Temi (D-260/D-261) non aprono più niente da soli
— è la Fase C. ISSUES 72.

---

## D-277 — Le dieci tessere dipinte: ogni Regione ha il suo quadro

**implemented in 0.1.239** — consegna del committente, «queste le tessere delle 10 regioni»

Il committente ha consegnato le illustrazioni delle dieci tessere del parco
(D-265), generate dai prompt preparati in sessione: targa col nome, segno
unico in emblema, iconcine dei domini. Stanno dove l'app le sa trovare da
ISSUES 5 (`res://art/region/<id>.png`, la chiave `art_prompt_key` è il nome
del file): le sei di CHR_01 **sostituite** con le versioni nuove, le quattro
del parco pescato (porto, palude, isola, bosco) **aggiunte**.

**Le regole che ne seguono:**

1. la mappa in partita le ritaglia dentro l'esagono da sola (D-059:
   l'immagine è il terreno, il disegno generato si fa da parte);
2. **il quadro del tabellone (`map.board`) vale solo per la mappa
   d'autore**: sul tavolo pescato le tessere si posano in griglia (D-275) e
   ognuna porta il suo quadro — il tabellone dipinto lì sarebbe un'altra
   mappa sotto quella vera. `map_view._board()` ora torna nullo quando il
   mondo ha `map_positions`;
3. la **soglia** (D-276) riceve il quadro come promesso: l'assaggio del
   tavolo dipinge la tessera consegnata, col terreno generato come ripiego
   per una tessera che un giorno restasse senza.

Non misurato sul gioco (0 regole toccate: playtest 0/8 identico); misurato
sugli occhi del committente, che è il cancello delle cose dipinte (§5ter).

---

## D-276 — La soglia: l'app si apre sulla scatola, non sul menu

**implemented in 0.1.238** — richiesta del committente, sulla bozza approvata in sessione

Il committente ha chiesto una schermata di presentazione per l'app, sulla
base della copertina: il nome del gioco, la mappa fatta con le sei tessere
pescate a inizio saga posate 3×2, e la porta per entrare. La bozza («La
Soglia di ECHOES») è stata costruita prima come pagina, e da lì è nata la
domanda che ha deciso D-275; questa decisione è il pezzo dentro l'app.

**La regola della soglia:**

1. l'app si apre su `title_screen.tscn` (la scena d'ingresso in
   `project.godot`), non più direttamente sul menu della sala; il bottone
   «Entra nella sala» porta a `res://ui/main.tscn`, che resta identica —
   menu, stanza e partita non cambiano di una riga;
2. la mappa della soglia è **una pesca vera del motore**, non un'immagine:
   `WorldStateFactory.resolve_map` con la stessa derivazione del seme di
   `game_session.gd` (seme × 53 + 29), posata 3×2 riga per riga come
   D-275 comanda. Il seme viene dall'orologio come nella stanza: ogni
   apertura mostra una saga possibile, e la didascalia dichiara il seme;
3. le tessere si dipingono **con lo stesso pennello della partita**
   (`RegionArt.plan`): sagoma, tratti del bioma, centro calmo. Sotto ogni
   tessera il nome e i **segni stampati a cancelletto** (D-262); i domini
   restano alle iconcine della tessera fisica e non entrano nella riga;
4. il patto è misurato: `test_title_screen.gd` pretende che allo stesso
   seme la soglia e la partita diano **le stesse tessere nella stessa
   posa** — se una delle due derivazioni cambia da sola, la prova va rossa.

Il resto della bozza (badge 1–4 giocatori / 90–150 minuti / 14+, il credito
«Un gioco di Stefano Ancillai», il motto) passa com'era. La grafica resta
quella di sistema dell'app — parchment e font della bozza sono della pagina,
non del motore: quando arriverà l'arte vera (ART_BIBLE), la soglia la
riceverà come la mappa riceve il quadro.

---

## D-275 — La posa comanda: sul tavolo pescato vicino è chi si tocca

**implemented in 0.1.237** — parola del committente, sulla forma della mappa

La domanda del committente, davanti alla posa 3×2 della schermata: *che
regola usano le adiacenze — ci sono lati bloccati, o tutte le tessere
accostate sono vicine?* La risposta onesta era che il motore usava **un
grafo scritto nei dati** (D-166), ristretto alle tessere uscite e ricucito
quando si spezzava in isole (D-263) — una regola che sul tavolo fisico non
si legge da nessuna parte. Delle due strade, il committente ha scelto la
posizionale: **vai con A**.

**La regola nuova, sul tavolo pescato:**

1. le tessere si posano **in griglia, riga per riga, nell'ordine di pesca**
   — con sei tessere, 3×2 (colonne = ⌈√N⌉);
2. **vicino è chi si tocca di lato o di sopra**: niente diagonali;
3. **niente lati bloccati**: ogni lato accostato è un confine aperto. Se un
   giorno una tessera vorrà un lato chiuso, sarà un segno stampato — e
   un'altra decisione;
4. la posa è **stato del mondo** (`map_positions`, [colonna, riga]) e la
   saga la eredita con l'ordine delle tessere: si rimonta leggendo il
   tavolo, come tutto il resto (D-269). Le adiacenze restano mutabili
   dentro l'anno (D-166: una frana toglie un arco);
5. **l'app disegna la posa**: la vista della mappa mette le tessere in
   griglia dove stanno sul tavolo — quello che si vede è quello che la
   regola legge;
6. il **grafo dichiarato resta agli anni scritti** (CHR_01-04), dove la
   mappa è d'autore. La cucitura delle isole di D-263 esce: una griglia è
   connessa per costruzione.

**I numeri, 100 semi:** 0 seggi bloccati su 8 (misto e uniforme), 82 mappe
diverse su 100 saghe, 0 partite non concluse. Le storie del tavolo pescato
si riscrivono (l'adiacenza decide movimenti e vicinati): regola del gioco,
dichiarata, come D-261.

---

## D-274 — Il motore esegue il bersaglio a segni: la sim gioca il gioco del tavolo

**implemented in 0.1.236** — il secondo pezzo di faccia fisica eseguito, dopo la Risonanza (ISSUES 69)

Da D-256 la faccia fisica di ogni carta dice **dove** la carta arriva
(«Scegli un luogo con #granaio, #pascolo o #capitale...»), e il motore non
l'ha mai letta: la sim muoveva dove voleva, il tavolo no — due giochi con lo
stesso nome, il rischio che ISSUES 69 nomina da sempre. Con la ri-mira di
D-273 i bersagli esistono su ogni mappa pescata; da questa decisione **il
motore li esegue**.

**La regola**: quando una carta si gioca come verbo che nomina una Regione —
**MUOVERE**, e **TRAMARE su una Regione** — il luogo scelto deve portare uno
dei segni del bersaglio della faccia, e nessuno dei vietati. Contano i segni
**vivi**, come al tavolo: quelli stampati sulla tessera piu' quelli posati
durante l'anno (un #granaio costruito apre la strada a una carta che lo
chiede). Una carta senza `any_tag` va ovunque, come la sua faccia dice. Il
rifiuto parla: *«"Leva Contadina" non arriva li': il bersaglio si dice a
segni, e Miniere Antiche non ne porta nessuno»*.

**Il cervello si e' adeguato da solo, tranne in un punto**: le giocate
passano gia' da `can_execute`, quindi una coppia carta+luogo illegale si
scarta e si prova la carta dopo. Il punto corretto a mano e'
`_widen_the_tap`: sceglieva la Regione migliore per famiglie e **poi**
cercava la carta — da quando la faccia comanda, la coppia luogo+carta si
sceglie insieme, com'e' al tavolo. (E il rubinetto ora itera le Regioni del
mondo pescato, non il parco intero: un lettore di tessere non pescate in
meno, lezione di D-263.)

**I numeri, 100 semi, prima → stretta → con la coppia:**

| turni «passa» | prima di D-274 | solo stretta | stretta + coppia |
|---|---|---|---|
| CHR_00 (tavolo pescato) | 87,2% | 88,8% | **87,8%** |
| CHR_01 (anno scritto) | 83,8% | — | **84,0%** |

**Il costo netto e' circa mezzo punto di passa, e si paga volentieri**: una
stretta di legalita' non puo' che togliere giocate, e in cambio la sim
adesso misura **il gioco vero** — ogni numero delle sonde d'ora in poi parla
del gioco che si gioca al tavolo. ISSUES 68 (i passa) resta aperta e non era
questa la sua cura: la leva e' il mazzo e il cervello, e adesso lavora sul
gioco giusto. Restano dichiarate e non eseguite le facce a bersaglio
ENTITY e TENSION (ISSUES 69).

Cancello di casa verde: **0 seggi bloccati su 8**, misto e uniforme.

---

## D-273 — La ri-mira delle 48: ogni bersaglio esiste su ogni mappa pescata

**implemented in 0.1.235** — chiude PZ-3 della roadmap, con un limite dichiarato

Il censimento che ha aperto questa decisione, misurato prima di toccare
qualcosa: **30 carte su 30 a bersaglio REGION non erano garantite sul tavolo
pescato** — quasi tutte nominavano segni stampati su 1-3 tessere su 10, e le
quattro tessere di PZ-2 (porto, palude, isola, bosco) non le raggiungeva
quasi nessuna. Le 48 erano scritte per la mappa vecchia di sei, e sul tavolo
pescato questo si sente: **87,2% di turni passati** contro l'83,8% dell'anno
scritto, col 70% dei passa a «mosse legali, nessuna che gli servisse».

**La cura ha la matematica di D-265.** I quattro domini stampati stanno su
**esattamente 5 tessere su 10**: una carta che mira anche al dominio affine
alla sua famiglia e' garantita **per costruzione** su ogni mappa pescata
(N−K+1 = 5). Ogni carta a bersaglio REGION guadagna il suo dominio — la
FORZA e l'AUTORITA' il #territorio, il POPOLO e i LEGAMI la #sopravvivenza,
la RICCHEZZA (e le voci di corridoio) le #risorse, il SAPERE l'#antico — e
dove la finzione li chiede anche i segni nuovi: il #porto per sale, pedaggi,
carovane e censimenti; la #palude e l'#isola per la mappa vecchia; la
#miniera per la prova e il cristallo; il #bosco per la banda armata. I testi
delle facce lo dicono («Vale anche il #porto, e ogni luogo del dominio delle
#risorse.»), e i domini hanno gli alias da #cancelletto nel dizionario.
Le due carte a bersaglio libero (l'Editto, il Diritto di Ospitalita') erano
gia' garantite da sole.

**La guardia che lo tiene** e' il controllo 17 del validatore fisico:
bersaglio REGION ⇒ segni stampati su almeno N−K+1 tessere del parco.
Contano i segni **stampati**: condizioni e pietre sono strade in piu', non
il pavimento. Dodicesimo difetto piantato nel self-test, e la guardia si e'
vista mordere.

**Il «fatto quando» di PZ-3 tiene tutto**: nessuna carta nomina un id
(verificato), ogni bersaglio esiste sulla mappa nuova (garantito, non
sperato), il validatore delle Risonanze cieche resta verde. **Carte nuove
non ne servono**: i luoghi nuovi chiedono gli stessi sei verbi, e la ri-mira
li raggiunge — scriverne resta materia d'autore.

**Il limite, dichiarato due volte:**
1. la ri-mira e' della **faccia fisica**, e il motore digitale il bersaglio
   fisico non lo esegue ancora (ISSUES 69): al tavolo la carta adesso trova
   sempre un luogo, ma il cervello delle sim non passa di meno per questo.
   I «passa» restano l'87,2% sul tavolo pescato — ISSUES 68 resta aperta, e
   il prossimo passo vero e' **far leggere al motore il bersaglio a segni**;
2. i numeri delle sim non si muovono (motore intatto): playtest 0 seggi
   bloccati su 8, Risonanze CHR_00 875/100 anni col ponte a 646.

---

## D-272 — I sei controlli di PZ-9, riletti nel mondo dove la Domanda sta sulla Tensione

**implemented in 0.1.234** — apre PZ-9 della roadmap e lo chiude

La roadmap chiedeva sei controlli scritti quando le carte Domanda erano un
componente a parte. Quel componente e' uscito (D-266), e i sei si rileggono
nel mondo com'e' — ognuno col suo nome nel rosso, e ognuno **visto mordere**
su un difetto piantato:

| chiesto dalla RoadMap | com'e' oggi (controlli 11-16 di `validate_physical.py`) |
|---|---|
| luogo senza tag | **tessera senza segni** — il bersaglio si dice a segni (D-262), un luogo senza segni non si puo' nominare |
| luogo senza funzione | **tessera che nessuno legge** — almeno un segno stampato dev'essere letto da qualcosa, o la tessera e' decorazione |
| Domanda senza Tema | **Tensione senza domande** — girata sul Tema caldo, `possible_questions` dev'essere li' |
| Domanda senza tag e non marcata generica | **ponte delle domande rotto** — ogni domanda della Tensione deve esistere in un template di Consiglio, o la carta promette un dibattito che il motore non sa aprire |
| Destino che legge un tag inesistente | **Destino che osserva un segno fuori dal dizionario** — il censimento generale lo direbbe comunque, ma senza fare il nome del Destino, e un errore senza nome non lo cerca nessuno |
| Echo senza effetto di setup | **Echo senza `effect_hooks`** — colore travestito da carta: si gioca, si paga, e il mondo non si muove |

**Il self-test sale da cinque a undici difetti piantati**, uno per controllo
nuovo — fra cui la tessera resa muta con un segno vero del dizionario
(`charter_temporary`, scritto-e-non-letto con nota da D-266): ogni pianta
prova il controllo su un caso che deve mordere, non su uno di comodo.

**I dati spediti erano gia' puliti su tutti e sei** — misurato prima di
scrivere i controlli: 0 tessere mute, 0 Tensioni senza domande, 0 ponti
rotti, 0 Echi vuoti. I sei denti servono al contenuto che verra', che e'
esattamente il «fatto quando» di PZ-9: niente entra se produce segni muti o
regole invisibili.

---

## D-271 — Lo schermo dice quello che la carta dice: le cinque schermate, censite

**implemented in 0.1.233** — PZ-8 della roadmap: la parte misurabile; l'occhio resta al committente (§5ter)

Le cinque schermate della RoadMap **esistono, e sono queste**:

| schermata | dove vive |
|---|---|
| **Mappa** | `map_view.gd`, dentro la vista TAVOLO (`table_view.gd`) — tessere pescate, segni, pedine |
| **Mano** | `hand_view.gd` — le carte del seggio, col trascinare di D-231 |
| **Temi** | `status_panel.gd` — la pista del Calore, i mazzetti coi gettoni coperti e la carta girata (D-261), le domande dell'anno |
| **Consiglio** | `confluence_board.gd` + `council_sheet.gd` — e le domande al giocatore passano da `game_screen.choose`, che e' l'`io` di `seat_decider`: **la pedina del prezzo e la controproposta (D-267/D-268) arrivano al browser gratis**, con le voci per esteso |
| **Saga** | `chronicle_book_view.gd` — le pagine vere del Chronicle Book, rasterizzate — piu' i tarocchi del seggio (chi sei / cosa vuoi) |

**La correzione di questa decisione:** il pannello del Destino mostrava le
etichette digitali dei gradini; da D-270 ogni Destino ha una faccia fisica
con le tre righe `reads` — la frase stampata sul cartoncino. Adesso **lo
schermo dice quello che la carta dice**: `rung_text` preferisce la faccia, e
il ripiego sull'etichetta resta per i Destini fabbricati nelle prove. La
logica e' una funzione pura, provata su tutti i 23 Destini spediti
(`test_destiny_screen.gd`).

**Il «fatto quando» di PZ-8 non si chiude da qui, e va detto**: la regola
§5ter — *nessuna misura copre quello che una persona vede* — vale piu' di
ogni prova headless. L'export web e' verde in CI; il giro su un iPad vero e'
del committente, domattina. Quello che una macchina poteva verificare
(le cinque schermate esistono, mostrano il tavolo e non i segreti, le
domande nuove arrivano al giocatore, lo schermo legge le carte) e' verificato.

---

## D-270 — Ogni Destino ha una faccia, e una misura che dice se chiede di giocare

**implemented in 0.1.232** — apre PZ-7 della roadmap; il criterio e' misurato, la coda e' d'autore

PZ-7 chiede tre cose: ogni Destino con Tema, segni osservati e le tre righe
Minimum/Victory/Triumph leggibili; sei Destini condivisi; e il criterio
secco — *giocare rende piu' che stare fermi, per ognuno* — detto da
`run_asking_probe.gd`.

**Le facce: 23 su 23.** I dodici Destini senza faccia (ISSUES 69.7) l'hanno
adesso: Tema, `observes` presi dalle loro stesse clausole, tre righe che si
leggono al tavolo. **Il sei-piu'-sei del titolo e' superato dai fatti**: il
tavolo pescato ha otto case, quindi 8 principali + 9 varianti di pool + 6
condivisi. Dichiarato qui, non nascosto nel conto.

**I sei condivisi coprono i sei Temi**: ai tre di sempre (il Nome che Pesa,
la Terra che Risponde, i Conti Chiusi) si aggiungono **la Quiete Tenuta**
(Sopravvivenza: questioni tenute basse — l'unica clausola che il mondo
peggiora da solo), **Quello che si Sa** (Antico: le scoperte), **le Riserve**
(Vie: la mano piena, e il primato `leads_in`). Ogni casa pesca ora da un pool
di quattro (il suo, la variante, due condivisi affini). Lo schema ammette
`observes` vuoto **solo** per i Destini che guardano contatori e non segni,
e lo dice.

**La sonda** (`run_asking_probe.gd`, sezione nuova): per ogni Destino il
livello medio dell'anno (NONE 0 → TRIUMPH 3), tavolo vero contro tavolo di
pietra, stessi semi.

**I numeri, 100 semi:**

- **CHR_00, il tavolo pescato — la direzione del gioco: 21 Destini su 22
  chiedono di giocare.** L'unico che pareggia da fermo e' NAHR (0,56 pari).
- CHR_01, l'anno scritto: 17 su 22. Si avverano da fermi: ALDRIC (0,55
  contro 0,73 — giocare gli **costa**), NAHR (1,12 contro 1,25),
  LIBERE_WATER (0,76 contro 1,00), VAERAX e VAERAX_WATCHED (pari).

**Due correzioni provate e tolte, a verbale**: stringere la vittoria di
VAERAX_WATCHED (piu' pedine sulla montagna) e di LIBERE_WATER (un'opera da
mantenere) **non ha spostato il numero di un decimale** — pedine e pietre
arrivano anche dai Consigli, che il tavolo di pietra tiene, perche' il
Consiglio non e' un'Occasione. La coda idle-friendly e' quindi **taratura
d'autore sui Destini scritti** (sono i quattro originali piu' una variante,
e sono i Destini-custode: il loro mestiere e' che niente si muova). Lo
strumento per chiuderla adesso esiste e fa i nomi.

---

## D-269 — Il tavolo visibile basta: la fine della Chronicle come sequenza fisica

**implemented in 0.1.231** — apre PZ-6 della roadmap e lo chiude

La roadmap lo chiedeva cosi': *la procedura di fine Chronicle come sequenza
fisica, eseguibile a mano — fatto quando la Chronicle successiva nasce dai
segni visibili, e si puo' rimontare il tavolo leggendo solo quello che c'e'
sopra.* Questa decisione lo prende alla lettera, e lo **misura**.

**Il tavolo visibile e' una lista chiusa**
(`godot/scripts/chronicle/visible_table.gd`): per casato la carta (nome,
generazione, vita, ere a mani vuote, vivo/spento), i segni addosso, le pedine
sulla mappa, il punteggio e gli obiettivi di saga; per tessera i segni, il
titolo, le pietre; per Tensione in gioco il valore, la faccia, i presagi, le
decisioni; per il mondo l'anno, le ere giocate, i segni globali, le
cicatrici, i rapporti e il diario (Echo e Verita'). **Niente altro passa**:
non l'ordine dei mazzi, non le mani, non le domande gia' poste, non la
memoria dei bot.

**La prova e' letterale** (`test_visible_handover.gd`): si gioca un anno
intero, si spoglia il mondo finale fino al tavolo visibile, e si eredita due
volte con lo stesso seme — dal mondo intero e dal solo visibile. I due mondi
che nascono devono essere **identici, byte per byte**: CHR_01 → CHR_02 su tre
semi, e la saga pescata CHR_00 → CHR_00 (la mappa e' della saga, D-263).
Costruendola ha gia' morso una volta: la prima stesura metteva le pedine
sulla tessera, e il mondo nuovo perdeva i padroni delle pietre — le pedine
sono **del casato**, posate sulle tessere, ed e' cosi' che si contano al
tavolo.

**La procedura scritta** sta in
[PROCEDURA_FINE_CHRONICLE.md](PROCEDURA_FINE_CHRONICLE.md): sette passi
eseguibili a mano — si leggono i Destini, il diario resta, il tempo passa
(50 anni e oltre: condizioni via, rapporti un passo verso NEUTRAL, i fatti
non murati diventano leggende), la mappa e' della saga (titolo e pietre
lapsano senza pedine), la successione, il tavolo si rimonta, il verbale
d'apertura. Con la regola madre in coda: se per rimontare serve
un'informazione fuori dalla tabella, o diventa un pezzo fisico dichiarato, o
il motore smette di chiederla — e la prova se ne accorge prima del tavolo.

Niente motore toccato: i numeri restano quelli di 0.1.230 (0 seggi bloccati
su 8, misto e uniforme).

---

## D-268 — La controproposta del RIVENDICARE: la pedina su un beneficio o su un costo

**implemented in 0.1.230** — chiude PZ-5 della roadmap (Fase B), e ISSUES 71

Parola del committente (D-261): il RIVENDICARE *«puo' servire in primis per
fare una controproposta sulla Tensione che si va dibattendo - mettere una
pedina su un beneficio o su un costo - oppure per dibattere una seconda
tensione»*. Il secondo uso vive da 0.1.223. Da qui vive il primo, e ha la
precedenza che il committente gli ha dato.

**Come funziona.** Chi ha consumato un RIVENDICARE nell'Atto porta il diritto
al primo Consiglio di fine Atto, e li' sceglie:

- **pedina su un costo**: si prende la pedina del prezzo (D-267),
  scavalcando il primo OPPOSE - il diritto pagato con un'azione batte
  l'ordine delle dichiarazioni;
- **pedina su un beneficio**: la posa su una voce del beneficio della
  proposta - se la proposta passa, **quella voce parla di lui**: i suoi
  Effect compilano col rivendicante al posto del proponente. La
  controproposta prende un pezzo, non la proposta intera;
- **niente**: si tiene il secondo dibattito, com'era da D-261.

Spendersi in controproposta consuma il diritto: un'azione, un uso. Il
proponente non controproppone a se stesso: se il titolare propone, il diritto
resta secondo dibattito.

**Il cervello** rivendica il beneficio se il dirottamento **guadagna** (la
voce valutata con se' al posto del proponente, meno com'era), prende la
pedina se sposta il prezzo a suo favore, altrimenti tiene il secondo
dibattito. Al tavolo umano chiede `seat_decider`, con le voci per esteso.

**Il numero che decide, 100 semi di CHR_01:** 117 controproposte, 46 voci di
beneficio rivendicate e passate — e **117 secondi dibattiti spesi**: il
cervello preferisce quasi sempre la controproposta, e i Consigli scendono da
4,6 a **3,6 di media** (Verita' scritte 360 → 307 al misto). E' il costo
dell'«in primis» preso alla lettera, scritto qui: quanto un tavolo umano
preferira' il secondo dibattito e' taratura d'autore, e la scelta al tavolo
resta tutta del titolare.

**Correzione a D-267, trovata costruendo questa:** il tavolo **misto** del
cancello ha giocato la Fase A **senza pedina** — il router dei caratteri
(`table_of_characters.Table`) non inoltrava `choose_price`, e la guardia
`has_method` lo copriva in silenzio: i numeri misti identici prima/dopo
l'hanno detto. L'inoltro c'e' da questa versione (anche per
`choose_counterclaim`), e i numeri misti di D-267 vanno letti come «pedina
solo all'uniforme». Il cancello di casa resta verde con le mani vive: **0
seggi bloccati su 8, misto e uniforme**.

**PZ-5 si chiude:** il Consiglio cambia il significato delle Azioni gia'
fatte — le presenze pesano sui fronti, le carte raccolte diventano impegni,
il RIVENDICARE speso diventa controproposta o secondo dibattito — e nessun
Consiglio finisce senza traccia: ogni esito muove la Tensione, fa scattare
una Conseguenza e il Ripple, e il silenzio ha una regola (D-267).

---

## D-267 — La pedina del prezzo: gli avversari scelgono il malus, e il silenzio paga

**implemented in 0.1.229** — apre PZ-5 della roadmap (Fase A)

La forma del dibattito e' parola del committente (D-266): *il proponente
sceglie le opportunita' e i bonus, **gli avversari scelgono i malus***. La
meta' del proponente c'era gia' — sceglie la domanda e la proposta. Questa
decisione costruisce la meta' degli avversari, e la regola anti-passivita'
che la roadmap chiedeva a PZ-5.

**La pedina del prezzo.** I pool `cost` e `failure` dei dodici template
diventano **menu di due voci** (riuso puro: il disordine o il debito per il
costo, il rancore che resta scritto o il patto rotto per lo sfogo;
CNF_WATER_03 tiene la sua coppia d'autore). A posizioni dichiarate e **prima**
degli impegni — che restano segreti, e sceglierla su chi ha impegnato di piu'
li rivelerebbe — **il primo seggio che ha detto OPPOSE** posa la pedina:
dichiara quale voce paghera' chi vince, il costo se la proposta passa
pagando, lo sfogo se cade. Dal pool scatta **una voce sola**: quella della
pedina, o la prima se nessuno si e' opposto — fin qui scattava il pool
intero, che con una voce era la stessa cosa (l'unico pool a due voci,
il fallimento di CNF_WATER_03, ora sfoga una voce invece di due: dichiarato).
Il cervello sceglie come tutto il resto al Consiglio — la voce che serve
meglio il suo Destino, parita' all'RNG di sessione — e al tavolo umano la
domanda la fa `seat_decider`, coi titoli e le descrizioni delle Conseguenze.

**Il silenzio paga.** Delle tre vie della roadmap (vantaggio al proponente,
Cicatrice automatica, Tema che resta caldo) la scelta e' la prima: si legge
in un gesto solo — silenzio-assenso. Se ogni seggio non proponente si
astiene, il fronte Support prende `silence_support_bonus` (**1** nei dati di
tutte e cinque le Chronicle, reversibile). Entra nel fronte come ogni altro
peso: un proponente che non ha messo carte resta a zero, perche' un bonus dal
nulla sarebbe un voto gratis (D-125).

**I numeri, 100 semi:**

| | CHR_01 | CHR_00 |
|---|---|---|
| Consigli | 451 | 427 |
| pedine posate | **198 (44%)** | **156 (37%)** |
| prezzi decisi dal fronte avverso | 162 (34 costi + 128 sfoghi) | 106 (42 + 64) |
| il tavolo ha taciuto e il silenzio ha pagato | 116 | 99 |

Il cancello di casa tiene: **0 seggi bloccati su 8**, tavolo misto *e*
uniforme. **Gli anni scritti si muovono, ed e' giusto cosi'**: questa e' una
regola del gioco, non un'aggiunta al tavolo pescato — come D-261, non come
D-264/D-266. Al tavolo uniforme: media 4,63 → 4,69, FAIL 136 → 147, DECISIVE
167 → 198 — il silenzio-assenso spinge i margini in su, e lo sfogo singolo
lascia i fallimenti piu' asciutti. Costo dichiarato, da guardare in taratura.

**Resta la Fase B, registrata in ISSUES 71**: la controproposta del
RIVENDICARE — *mettere una pedina su un beneficio o su un costo* (D-261) —
cioe' il diritto, pagato con l'azione, di prendersi la pedina del prezzo o di
rivendicare una voce del beneficio. E resta la lettura del «fatto quando» di
PZ-5: il Consiglio che cambia il significato delle Azioni gia' fatte.

---

## D-266 — La Domanda sta sulla carta Tensione: niente mazzetti di Domande

**implemented in 0.1.228** — parola del committente, che revoca una strada tentata

La strada tentata, per il verbale: una prima stesura di questa decisione
(la PR #108, **mai mergiata**) aveva costruito il contrario — 18 carte Domanda
in mazzetti separati, tre per Tema, pescate a fine Atto, con una generica che
apriva sempre. Il committente l'ha fermata prima del merge, testuale:

> *«Nella carta Tensione ci sono già le domande collegate ai Tag del mondo: se
> si gira una Tensione sul Tema caldo, lì ci sono già le domande di come
> comportarsi — scegliendo dal proponente le opportunità e i bonus, e
> scegliendo dagli avversari i malus. Non c'è bisogno di fare ulteriori
> mazzetti.»*

**Quello che cambia, in tre righe:**

1. **Le carte Domanda escono dai dati**: le dodici filtrate, il loro schema
   (`question_card`), la loro mano nel dizionario dei segni (90 voci ripulite)
   e i controlli del validatore fisico che le sorvegliavano (Domande che si
   aprirebbero sempre, Temi senza mazzo Domande — al suo posto: **Tema senza
   Tensioni**). Il tentativo dei 18 resta nella storia della PR, non nel gioco.
2. **La Domanda vive sulla Tensione.** Il ponte digitale è `possible_questions`
   sulla carta Tensione, verso i template di Consiglio: a fine Atto la
   questione girata apre le **sue** domande, com'è dal giro di D-261. Una
   prova nuova lo pretende dai dati: ogni Tensione spedita porta almeno una
   domanda (60 su 60 oggi).
3. **La forma del dibattito è la direzione di PZ-5**: il proponente sceglie le
   opportunità e i bonus, gli avversari i malus — insieme alla controproposta
   del RIVENDICARE (D-261), è il Consiglio da rileggere, non un mazzo da
   stampare.

**Il costo, dichiarato:** tre segni di memoria (`charter_temporary`,
`crystal_measured`, `relic_recorded`) li leggevano **solo** le carte Domanda:
restano scritti-e-non-letti, con la nota nel dizionario che dice cosa
aspettano — la faccia fisica delle Tensioni (ISSUES 69).

**I numeri non si muovono:** 100 semi, 0 seggi bloccati su 8, tavolo misto *e*
uniforme, Consigli fermi al decimale dello 0.1.227 (media 4,63 all'uniforme).
La rimozione è pura: il motore non pescava ancora niente sul main.

---

## D-265 — Dieci tessere, sessanta Tensioni, e la matematica che tiene i mazzetti vivi

**implemented in 0.1.227** — parola del committente, sulla taglia del mondo

Le richieste, testuali: *«Le tessere devono essere molte di più, e se ne
pescano 6 [la taglia della prima mappa]. Il pool va deciso matematicamente in
modo che i #tag delle zone siano equamente distribuiti. E i mazzetti delle
tensioni devono essere molti di più: almeno 10 per tipo (60), in modo che ce
ne sia almeno 1 per chronicle.»*

**Le tessere: 10, se ne pescano 6.** Le sei di sempre più le **quattro di
PZ-2** — Porto Cinerino, la Palude dei Canali, l'Isola Muta, il Bosco dei
Confini — ognuna con biomi nuovi (MARSH, ISLAND), il suo disegno, e un **segno
unico stampato** (`harbor`, `marsh`, `island`, `forest`) per la grammatica
adattiva.

**La matematica, che è il cuore:** i segni di zona meccanici sono i quattro
domini (`domain:SURVIVAL/TERRITORY/RESOURCE/ANCIENT`). Ogni dominio sta su
**esattamente 5 tessere su 10**: pescandone 6, le tessere che *non* portano un
dominio sono al massimo 5 < 6, quindi **ogni dominio è sempre sul tavolo, su
qualunque mappa** — non in media: sempre. L'invariante è tenuto da una guardia
nuova (`check_a_drawn_map_bears_every_theme`), vista mordere su un difetto
piantato.

**Le Tensioni: 60, dieci per Tema.** Le 12 di sempre più **48 nuove scritte
per intero** — titolo, apertura, inneschi, cure, presagio, fuochi — coi
`focus_region_tags` distribuiti sulle dieci tessere. I Consigli sono coperti
dai due template generici nuovi (**CNF_ANY_TERRITORY** «Il Consiglio del
Confine» e **CNF_ANY_RESOURCE** «Il Consiglio del Prezzo», accanto ai due che
c'erano). La regola che tiene i mazzetti vivi: **ogni Tema ha candidate a
fuoco libero** — dominio garantito dalla matematica sopra, nessun segno di
fuoco richiesto — quindi il suo mazzetto non è mai vuoto. Anche questa è
guardia, non speranza.

**La biblioteca e la mano (D-028, portata in fondo):** gli anni scritti
(CHR_01-04) tengono la loro mano di 12 candidate e **non si muovono di un
decimale** (100 semi: 4,62/4,63, 0 seggi bloccati su 8); la Prima Chronicle
pesca da tutta la biblioteca.

**I numeri, 100 semi di CHR_00:**

| | 4 su 6 tessere, 12 Tensioni (D-264) | 6 su 10, 60 Tensioni |
|---|---|---|
| mappe diverse | 15 su 15 | **82** (su 210 possibili) |
| anni diversi (per domande) | 88 | **100 su 100** |
| Consigli | 3-6, media 4,61 | 3-6, media 4,24 |
| mazzetti vuoti (100 semi × 6 Temi) | possibili (Terra) | **0 su 600** — minimo 4 carte |
| partite non concluse | 0 | **0** |

Nessuna partita uguale a un'altra, e il buco di Terra e Fede — una Tensione
sola a testa, a verbale dal Punto Zero — **si chiude nei numeri**: dieci a
testa, mai un mazzetto vuoto. La qualità d'autore delle 48 nuove resta
materia di lettura del committente: sono scritte per essere riviste una a una,
e ognuna è un dato che si può cambiare senza toccare il motore.

**Di contorno, e dichiarato:** le carte stampano le fonti di pesca per
famiglia e le tessere nuove sono fonti (la guardia delle fonti ha morso al
primo colpo: 40 testi aggiornati alla verità nuova); i fogli d'export salgono
a 41 con le dieci tessere; il BRIEF_ARTE ha le quattro tavole nuove.

---

## D-264 — Il mazzetto pieno: dentro ci sono tutte le Tensioni, e girare apre la questione

**implemented in 0.1.226** — completa il disegno di D-261 sul tavolo pescato

Le parole del committente in D-261 dicevano *«i mazzetti dei temi sono
composti dalle tensioni»* — per intero, non solo dalle quattro aperte
all'inizio. La Fase A l'aveva rimandato con la ragione scritta; il tavolo
pescato di D-263 e' il posto dove il rinvio finisce.

**La regola:** su una Chronicle che pesca le tessere (`region_pool`), il
mazzetto di ogni Tema contiene **tutte le Tensioni del Tema che la mappa sa
reggere** — il filtro e' lo stesso di D-263: dominio e segni di fuoco su una
tessera uscita. **Girare la prima carta apre la questione**: se non era in
gioco, entra — stato strutturale con la forma del setup, col valore
d'apertura scritto sul dato, e una riga nel verbale («entra in gioco: il
tavolo adesso se lo chiede»). Sul tavolo fisico e' esattamente quello che
succede: la carta del mazzetto **e'** la scheda della questione, e girarla
la mette sul tavolo.

**Dichiarato, con la ragione:** la questione entrata a partita in corso non
entra nel sacchetto della Deriva dell'anno — si scalda coi mazzetti e coi
Consigli. E le **Chronicle scritte restano al mazzetto delle questioni in
gioco**: il loro anno e' un anno d'autore, e i loro numeri non si sono mossi
di un decimale (verificato sui 100 semi).

**I numeri, 100 semi di CHR_00:**

| | mazzetto delle aperte (D-263) | mazzetto pieno |
|---|---|---|
| carte nei mazzetti (seme 7000) | 4 | **10** |
| Consigli | 3-6, media 4,32 | 3-6, media **4,61** |
| partite non concluse | 0 | **0** |
| mappe/tavoli/anni diversi | 15/52/88 | 15/52/88 |

Le questioni che entrano girando danno all'anno piu' da dibattere — nella
partita campione ne sono entrate tre — e il tetto dei due Consigli per Atto
tiene la forma. Un Tema il cui mazzetto e' vuoto su questa mappa (la Terra,
sul seme campione) non gira niente: e' il buco noto di Terra e Fede
(ROADMAP §4.5) visto dal tavolo pescato, e resta materia d'autore.

---

## D-263 — La Prima Chronicle: le tessere si pescano, e nessuno scrive lo scenario

**implemented in 0.1.225** — Fase C della direzione del committente

Le parole del committente: *«Per iniziare la prima Chronicle non ci sono
scenari, nessun CHR fisso. Si pescano le tessere della mappa (quindi una mappa
diversa ogni saga), si mischiano i mazzetti dei temi che sono composti dalle
tensioni.»*

Da questa decisione esiste **CHR_00 — La Prima Chronicle**, e l'app **si apre
da lì**: niente scenario, niente nomi scritti prima.

**Come apparecchia, pezzo per pezzo:**

1. **Le tessere si pescano** (`region_pool`, stessa forma di `entity_pool`):
   quattro tessere su sei, con un dado derivato dal seme — la mappa non
   consuma il caso della partita (D-150). Le case si pescano come già da
   D-213, i mazzetti dei Temi si mischiano come da D-261.
2. **Le tessere pescate si posano accostate.** Il grafo scritto, ristretto
   alle tessere uscite, può spezzarsi in isole — due posti vicini solo
   attraverso una tessera rimasta nella scatola. Si ricuce in ordine di
   pesca, come sul tavolo vero.
3. **L'anno fa solo le domande che la mappa sa reggere.** Una Tensione entra
   nel sacchetto se una tessera porta il suo dominio e i suoi segni di fuoco
   (grazie alla grammatica adattiva di D-262 il resto del contenuto si adatta
   da solo). Senza `region_pool` il filtro non esiste: le Chronicle scritte
   restano identiche.
4. **Ogni casa comincia sul tavolo.** Le pedine cadono solo su tessere
   uscite; una casa coi posti di partenza rimasti nella scatola **si
   accampa** — una pedina sulla tessera che le tocca, a giro. Le pietre
   scritte su tessere non uscite restano nella scatola. E **nessuna tessera
   è governata da un assente**: il padrone scritto che non siede lascia il
   posto di nessuno (la cura di D-213, estesa al primo anno).
5. **La mappa è della saga.** La seconda era eredita e gioca sulle tessere
   della prima, qualunque seme la apra: se la pesca cieca del seme nuovo dice
   altro, il mondo si rimonta sulle tessere ereditate — Regioni, forma,
   domande, mazzetti. CHR_00 è il seguito di sé stessa: la saga continua
   procedurale.

**Il difetto che la costruzione ha scovato** (e che valeva anche prima): tre
sistemi rileggevano la Chronicle **vergine** dal dato invece di quella
risolta dalla sessione — con le tessere pescate, il riconteggio del controllo
toccava Regioni rimaste nella scatola. Ora la mappa si itera **dal mondo**,
che è la direzione giusta comunque: il mondo è la verità, la lista della
Chronicle è la candidatura.

**I numeri, 100 semi di CHR_00** (`run_map_probe.gd`, sonda nuova):

| | |
|---|---|
| mappe diverse | **15 su 15 possibili** |
| tavoli diversi | 52 |
| anni diversi (per domande) | 88 |
| Consigli | 3-6, media **4,32** — in famiglia con gli scritti |
| partite non concluse | **0 su 100** |

**E il cancello che non si negozia, sugli scenari scritti:** 0 seggi bloccati
su 8, misto e uniforme. I Consigli si muovono di un soffio (misto 4,59→4,62,
uniforme 4,66→4,63; Verità 355→359 misto) — è il prezzo della guardia sul
padrone assente al punto 4, dichiarato qui.

**Aperto, e di chi:** i mazzetti come mazzi di **tutte** le Tensioni del Tema
(con la questione che entra in gioco quando si gira) restano il passo dopo; le
**quattro tessere nuove** (porto, canale/palude, isola, bosco) e la **regola
del luogo** sono PZ-2 e materia d'autore (ROADMAP §4.4); il salvataggio di una
CHR_00 a metà anno ripristina la mappa dal mondo salvato, come tutto il resto.

---

## D-262 — La grammatica adattiva: il contenuto non nomina più un posto per id

**implemented in 0.1.224** — Fase B della direzione a tessere (dopo D-261)

Le parole del committente: *«Le Tensioni hanno una grammatica che si adatta a
ogni situazione usando i #TAG che ci sono sulla mappa, le cicatrici, le
condizioni o le strutture.»* Il censimento ha detto che le Tensioni erano gia'
quasi pulite — vivono di `domain` e `focus_region_tags`, che sono segni — e che
gli id fissi stavano nel contenuto **attaccato** a loro: 8 punti fra Conseguenze
e template, piu' 15 carte Echo che nominavano una Regione per nome.

**Adesso: zero.** Ogni bersaglio si dice a segni:

- `$region_with:<segno>` c'era gia' (D-033) e risolve sul segno **vivo** della
  mappa — cicatrici, condizioni e pietre comprese, che e' esattamente la
  richiesta. Ci sono passate le 23 riscritture: `REG_VALLE_VERDE` →
  `$region_with:granary`, `REG_EREDAN` → `$region_with:capital`, e cosi' via.
- `$entity_with:<segno>` e' nuovo e gemello: la prima casa nell'ordine del
  tavolo che porta il segno addosso, vivo anche lui. Nessuno lo porta: la
  clausola **compila a niente, senza errore** — D-106 esteso ai selettori.
- `requires_entity_tag` e' la forma adattiva di `requires_entity` (D-213): il
  drago non si chiama piu' `ENT_VAERAX`, si chiama *chi porta #dormiente* — e
  l'etichetta di famiglia `sleeping`, che era colore dichiarato, adesso e'
  **letta**: il dizionario lo dice, con la ragione nella nota.
- Ogni tessera ha ora un **segno unico stampato** che la nomina: `capital`,
  `granary`, `nomad_range`, `wild`, `trade`, e il nuovo **`mine`** sulle
  Miniere Antiche (unica riscrittura che ha chiesto un segno nuovo).

**Le guardie, viste mordere:**

1. `validate_data` vieta gli id di Regione nel contenuto di Conseguenze,
   template ed Echo — provato su un difetto piantato, rosso, poi ritirato. Il
   divieto **non** aspetta il tavolo pescato: un contenuto che nomina un posto
   per id smette di essere vero il giorno che la mappa si pesca.
2. `$entity_with:` e' un binding validato come `$region_with:`: il segno deve
   stare addosso a qualcuno nel dato base.
3. Il censimento del dizionario conta i selettori come **letture**: la
   conversione ha subito trovato due mani non dichiarate (`crystal_site` e
   `trade`, letti da Conseguenze pre-esistenti di D-033 che nessuno aveva mai
   contato) — la guardia di D-259 che morde su lavoro di tre giorni dopo.

**La controprova che non ha prezzo:** il playtest sui 100 semi e' **identico
alla virgola** alla base di D-261 — Consigli 3-6, medie 4,59/4,66, Verita'
355/348, 0 seggi bloccati su 8. Sulla mappa di oggi i segni unici risolvono
agli stessi posti degli id: la riscrittura cambia cosa il contenuto *dice*,
non cosa *fa*. Cambiera' cosa fa il giorno che la mappa cambia — ed e' il punto.

**Aperto, e di chi:** la faccia fisica delle carte Tensione (il testo che si
legge girando la carta del mazzetto) non esiste ancora — va disegnata con le
Domande di PZ-4; le tessere vere con pesca arrivano con la Fase C, e li' i
mazzetti diventeranno *tutte* le Tensioni del Tema, non solo quelle in gioco.

---

## D-261 — I sei mazzetti: gettoni coperti, la carta che si gira, e il secondo dibattito

**implemented in 0.1.223** — decisione del committente, che supera la forma di D-260

Le parole del committente, che sono la regola:

> *I sei Temi sono 6 mazzetti. Quando si scalda un Tema si mette un gettone
> coperto che può valere 0, 1 o 2. È il mucchio che si rivela a fine Atto: il
> più alto va al Consiglio. Se un giocatore ha giocato un'azione che gli
> permette di dibattere un secondo Tema, sarà quello col secondo mucchio più
> alto.*

E, sulla rivelazione: **la prima carta del mazzetto si gira a due segnalini** —
da lì il tavolo sa quale Tensione si va scaldando su quel Tema. I mazzetti sono
**mazzi di Tensioni**: le questioni in gioco di ogni Tema, mischiate a inizio
partita con un dado derivato dal seme, coperte.

**Com'e' fatto adesso, pezzo per pezzo:**

1. **Il gettone coperto.** La Risonanza fa cadere sul mazzetto del suo Tema
   tanti gettoni quanto il Calore scritto sulla carta (aggravata = gettoni in
   piu'). Ogni gettone pesca il valore dal sacchetto `theme_tokens.covered`
   — `[0,1,1,2]`, lo stesso dei gettoni delle Tensioni — e viaggia come
   `ADJUST_THEME_HEAT` con l'inverso esatto. Il tavolo vede i gettoni cadere
   (`theme_tokens`, contatore come `tokens_in_bag`), non quanto valgono.
2. **La carta che si gira** (`reveal_at: 2`). Al secondo segnalino la testa del
   mazzetto si scopre e resta il fronte del Tema. Una carta girata non si
   ricopre.
3. **La rivelazione di fine Atto.** I gettoni si girano («I mazzetti si girano:
   Fede vale 3 (2 gettoni); …»), il mazzetto col valore piu' alto porta al
   Consiglio **la sua carta girata** (se non s'era ancora girata, la gira la
   rivelazione; se ha gia' detto tutto, si gira la prossima), e poi **tutti i
   mazzetti si spendono**: valori a zero per Effect, gettoni via. A parita'
   decide l'ordine del dato; a tavolo freddo il ripiego dichiarato resta il
   mucchio piu' alto delle questioni.
4. **Il secondo dibattito.** Chi consuma un RIVENDICARE durante l'Atto non
   sceglie piu' lui la questione: a fine Atto apre **il secondo mazzetto piu'
   alto**, restando proponente. La questione che aveva nominato e' solo il
   ripiego se i mazzetti non offrono niente — cosi' il diritto guadagnato non
   evapora in silenzio, che era ISSUES 53.

**Le due trappole che il costruire ha trovato**, entrambe morse da una guardia:

- *La pesca che ascolta smontava i mazzetti.* Un'era di libreria ripesca le
  questioni dopo il setup (D-079), e i mazzetti restavano quelli della pesca
  cieca: il Consiglio si apriva su una Tensione che il mondo non aveva.
  Trovato da `test_library_balance`; adesso `redeal_tensions` rimonta i
  mazzetti.
- *Il primo Consiglio cancellava il diritto del secondo.* Risolvere una
  Confluence azzera `forced_confluence` da sempre: letto dopo il primo
  Consiglio dell'Atto era sempre vuoto, e il playtest e' sceso a **tre
  Consigli esatti per cento anni** — il numero che non mente. Adesso il
  diritto si legge prima.

**Il dado dei mazzetti e' suo** (lezione di D-150, pagata di nuovo): la prima
stesura pescava i valori dal caso condiviso e **riscriveva ogni storia a seme
fisso** — `plan_d_crown_calls` perdeva un Consiglio e la sua morale. Col dado
derivato (seme × sequenza degli Effetti, riproducibile anche da salvataggio) le
storie scritte sono tornate **byte per byte** quelle di D-258, senza ribasare
niente.

**I numeri, 100 semi:**

| | prima (D-260) | adesso |
|---|---|---|
| Consigli, misto | 3-8 (media 4,87) | **3-6 (media 4,59)** |
| Consigli, uniforme | 3-9 (media 5,31) | **3-6 (media 4,66)** |
| l'anno peggiore | **9** (prezzo dichiarato da D-257) | **6, per costruzione** |
| Verita' scritte | 373 | 355 (misto) · 348 (uniforme) |
| seggi bloccati | 0 su 8 | **0 su 8**, misto e uniforme |

Il tetto a due Consigli per Atto **cancella il nove** che tre tentativi di
taratura non avevano spostato: non e' piu' una coda della distribuzione, e' la
forma dell'anno. Le Verita' scendono con i Consigli; e' il prezzo di un anno
piu' corto di parole, scritto qui.

**RIVENDICARE ha due usi, e qui ne vive uno.** Il committente ha detto anche:
*puo' servire in primis per fare una controproposta sulla Tensione che si va
dibattendo — mettere una pedina su un beneficio o su un costo.* Quella meta'
tocca le proposte e le clausole del Consiglio, ed e' materia della revisione
del Consiglio (PZ-5): registrata li', non costruita qui a meta'.

**Aperto, e di chi:** la composizione del sacchetto `[0,1,1,2]` e `reveal_at: 2`
sono configurazione reversibile (taratura d'autore); le Domande fisiche che si
pescano dal Tema restano ISSUES 69/PZ-4; il mazzetto come mazzo di **tutte** le
Tensioni del Tema (non solo quelle in gioco) arriva con la Fase C — la mappa a
tessere e il setup procedurale, dove gli scenari fissi smettono di decidere.

---

## D-260 — Il Calore diventa una pista, e la pista sceglie la Domanda dell'Atto

**implemented in 0.1.222** — apre PZ-1 della roadmap e lo chiude

La roadmap ([ROADMAP_PUNTO_ZERO.md](ROADMAP_PUNTO_ZERO.md), PZ-1) lo diceva
cosi': *i Temi esistono; il Calore no. Oggi la Risonanza scalda «la questione
piu' vicina alla soglia di quel Tema»: e' un ponte, non la cosa.* Da questa
decisione il Calore e' **stato del mondo**: `theme_heat` nel WorldState, sei
Temi, un segnalino 0-6 ciascuno — la cosa che sul tavolo fisico e' una pista
con sei tacche, leggibile da chiunque.

**Come si muove.** Solo per Effect. `ADJUST_THEME_HEAT` e' il ventottesimo tipo
dell'enum chiuso, inverte su se stesso col delta davvero applicato — tetto a
sei e pavimento a zero compresi, come le Tensioni — e la Risonanza lo firma
`kind: "resonance"` con l'id della carta. Il raffreddamento di fine Atto e' un
Effect anche lui, firmato `ACT_END`.

**La Risonanza scalda la pista per prima, e il ponte resta.** Il ponte sulle
Tensioni non e' stato tolto: finche' le Domande vivono sulle questioni, il
Calore deve anche avvicinarle. Cadra' quando le Domande fisiche si pescheranno
dal Tema (ISSUES 69, punto 8) — e il giorno che cade, questa e' la riga da
cancellare in `_resonance`.

**Cosa la pista ha sentito che il ponte non sentiva.** Misurato su 100 anni,
tavolo misto:

| | col ponte (0.1.220) | con la pista |
|---|---|---|
| Risonanze in 100 anni | 364 | **1.056** |
| per anno | 3,6 | **10,6** |
| Calore sulla Terra | 1,4% | **3,4%** |
| Calore sull'**Antico** | — | **0,1%** |

Due Risonanze su tre cadevano nel vuoto: il Tema della carta non aveva
questioni in gioco quell'anno, e il mondo non rispondeva niente. La pista le
sente tutte. E ha trovato un numero che nessuno aveva ancora scritto:
**l'Antico si scalda dalla mano una volta su 1.056** — le sue due Tensioni
vivono di Drift e Consigli, non di carte. E' la stessa malattia della Terra
vista da un altro Tema, e va nel mazzo delle decisioni d'autore accanto a lei
(ROADMAP §4.5).

**A fine Atto la pista sceglie.** Il Consiglio dell'Atto apre la questione del
Tema piu' caldo — a parita' l'ordine del dato, che e' l'ordine stampato; se il
Tema piu' caldo non ha niente di apribile si scende al successivo, la stessa
discesa di prima. **Il mucchio piu' alto resta come ripiego dichiarato** per
l'Atto in cui nessuna Risonanza ha scaldato niente: un tavolo freddo non e' un
tavolo senza domande. Dentro il Tema, fra le sue questioni, vince ancora il
mucchio: la pista cambia *quale Tema parla*, non come si sceglie dentro un Tema.

**Il Tema che ha parlato torna a zero; gli altri tengono il loro.** Un fuoco
che nessun Consiglio ha guardato non si spegne da solo, e all'Atto dopo parte
avanti. E' la regola piu' semplice che si possa spiegare al tavolo, scritta per
essere rivista: quanto sale, quanto scende e cosa fa se resta alto a fine
Chronicle e' **taratura d'autore** (ROADMAP §4.1), e questi valori — +Calore
scritto sulla carta, azzeramento su Domanda posta, nessun decadimento — sono la
configurazione reversibile su cui misurarla.

**Il prezzo, misurato e scritto.** Cambiare chi sceglie la Domanda dell'Atto
muove i Consigli: a tavolo misto **3-8, media 4,87** (era 5,05 — mezzo
Consiglio in meno l'anno), uniforme **3-9, media 5,31** (era 5,26). Il nove
dell'anno peggiore resta nove, non peggiorato. Le Verita' scritte scendono da
384 a **373** (misto: 373 diverse su 373; uniforme: 365 su 373). Il vincolo che
non si negozia tiene ai due tavoli: **0 seggi bloccati su 8**.

**Lo schermo non mente.** Il pannello delle domande mostra la riga `CALORE` coi
Temi caldi e chi apre a fine Atto; il marcatore «va al Consiglio» sul mucchio
piu' alto — che con la pista calda sarebbe la regola vecchia insegnata come
nuova — diventa «il mucchio piu' alto». La pista come componente stampabile
(fogli d'export) aspetta PZ-8 con il resto del tavolo.

**Sonde.** `run_resonance_probe` adesso conta la risposta del mondo dalla
pista e il ponte a parte — prima avrebbe continuato a leggere 3,6 per anno su
una regola che ne fa 10,6, che e' esattamente il genere di zero travestito che
questo progetto ha gia' pagato quattro volte.

---

## D-259 — I segni diventano un dizionario, e la guardia lo legge

**implemented in 0.1.221** — apre PZ-0 della roadmap e lo chiude

La roadmap del Punto Zero ([ROADMAP_PUNTO_ZERO.md](ROADMAP_PUNTO_ZERO.md), PZ-0)
parte da qui: *i tag non esistono come dato — si deducono raschiando gli
effetti, e il validatore indovina l'ambito di ognuno.* Da questa decisione
esistono: `godot/data/tags/tags_core.json`, **171 voci**, una per ogni segno che
i dati toccano. Ogni voce dichiara il **nome stampato**, la **categoria**
(luogo/funzione/stato/memoria/entita'), l'**ambito** (REGIONE/ENTITA'/MONDO),
**chi lo scrive e chi lo legge**, per collezione. Fuori dal dizionario restano
solo i livelli di rapporto (ENEMY..PACT): sono gradini di una scala, non segni.

**Il validatore adesso legge l'ambito dal dato invece di dedurlo** — e la
deduzione non e' sparita: e' diventata la controprova. `validate_physical.py` ha
sei controlli nuovi: segno usato fuori dal dizionario, voce morta, ambito
dichiarato che non combacia con l'osservato, mani dichiarate che non combaciano
con le osservate (`engine` e' l'unica mano senza riscontro possibile, e quindi
l'unica dichiarabile a parola), segno senza lettori o scrittori **e senza
ragione scritta**, e #cancelletto stampato su una carta che non e' il nome di
nessuna voce. E un `--self-test` che pianta **cinque difetti** e pretende il
rosso su ognuno, in CI — perche' questo progetto ha gia' pagato due volte la
guardia che nessuno aveva visto mordere.

**Cosa la conversione ha trovato, e che prima non si vedeva:**

1. **Lo stesso segno aveva fino a tre nomi.** Le carte fisiche stampano
   `#malcontento`, l'app (`sign_labels.gd`) dice «inquieta», e per le pietre i
   dati dicono un terzo nome per grado. Il dizionario dichiara **un** nome
   canonico — quello della carta, perche' il tavolo viene prima dell'app — e
   congela le altre forme in `aliases`: una divergenza dichiarata che puo' solo
   accorciarsi. Riunificarle e' [ISSUES 70](ISSUES.md#70).
2. **Ventidue segni avevano un lettore che il censimento non contava**: la
   Regione di cui si discute (`focus_region_tags` delle Tensioni) — lo stesso
   buco che D-234 aveva gia' trovato nel registro dei segni, richiuso solo la'.
   Adesso lo contano tutti e due, insieme al `when_also` delle regole composite.
3. **Due segni si stampano con la stessa parola**: la vocazione `granary` della
   Regione e la pietra `structure:granary` sono entrambe `#granaio` sulle
   carte. Scritto nelle note di entrambe le voci; si scioglie ri-mirando le
   carte (PZ-3).
4. **34 voci sono senza lettori e 1 senza scrittori** — ognuna con la sua
   ragione nella `note`. La vecchia lista `DICHIARATI` del validatore e' andata
   in pensione: le ragioni vivono nel dato, accanto al segno che giustificano
   (regola 1.1 della roadmap: un solo insieme di dati, niente liste parallele).

**Il prezzo, dichiarato.** Le parole dei segni vivono ancora anche in
`sign_labels.gd` (l'app) e i muti noti anche in `MUTI_NOTI` di
`build_sign_registry.py`: due paralleli che questa decisione **non** ha fuso,
messi in fila in [ISSUES 70](ISSUES.md#70). E il dizionario copre i segni che i
**dati** toccano: quelli che solo il motore scrive e legge (`uprooted`,
`seal_kept`, `scar:burned_records`) restano fuori finche' non esiste un
censimento del motore. L'**icona** delle voci e' dichiarata nello schema e non
compilata: l'arte dei segni non esiste, e dichiararla prima sarebbe inventarla.

**I numeri, invariati dove dovevano esserlo.** Suite verde (512 prove, 12.290
asserzioni — una in piu': lo schema nuovo nel giro di copertura). Playtest su
100 semi: **0 seggi bloccati su 8**, misto e uniforme; Consigli misto 3-8
(media 5,05), uniforme 3-9 (media 5,26) — il dizionario e' dato e guardia, non
una regola: se questi numeri si fossero mossi, sarebbe stato un difetto.

---

## D-258 — Quarantotto carte su quarantotto, e tre volte cieco

**implemented in 0.1.220** — chiude il grosso di ISSUES 69, che resta aperta

[D-257](#d-257) aveva fatto succedere la Risonanza e aveva detto il suo difetto:
**1,6 volte l'anno non e' una regola, e' un episodio.** La causa non era la
regola ma il pilota — dodici carte su quarantotto. Questa converte le altre
trentasei: **48 su 48**, ognuna con bersaglio a segni, due Azioni, Risonanza
obbligatoria e uso in Consiglio.

| | prima | adesso |
|---|---|---|
| carte con una faccia | 12 su 48 | **48 su 48** |
| Risonanze in 100 anni | 163 | **364** |
| per anno | 1,6 | **3,6** |

**E una correzione a D-257, che va prima di tutto il resto.** Quella decisione ha
scritto che la meta' condizionale della Risonanza era **morta, 0 su 163**, e l'ha
chiamata «contenuto morto scritto in bella prosa». **Il numero era sbagliato**, e
lo era perche' la sonda contava le aggravate dai segni lasciati sulla mappa
mentre quasi tutte le carte aggravano **soltanto il Calore**. Contata come si
deve — dal delta applicato, confrontato col Calore base scritto sulla carta —
oggi la meta' condizionale scatta nel **10,2%** dei casi.

Erano due difetti annodati, e solo uno era vero:

1. **sei carte su dodici erano cieche davvero**: delle sei azioni **solo MUOVERE
   e TRAMARE nominano una Regione**, e quelle sei facevano INFLUENZARE, FORGIARE
   o RIVENDICARE temendo un segno che vive solo sulla mappa. Domanda fatta al
   vuoto, e non poteva scattare nemmeno una volta;
2. **la sonda era cieca sulle altre sei.**

Il primo e' curato due volte: le carte sono riscritte, e il validatore ha un
controllo nuovo che lo dice per nome — *«la carta fa CLAIM, che non nomina
REGION, e teme `condition:indebted` che vive solo li'. Non scattera' mai.»* Il
secondo e' curato nella sonda, e resta a verbale come lezione: **e' la quarta
volta di fila che uno zero di questo progetto era la sonda e non il gioco.**

**Cosa impedisce che ricapiti.** `tools/validate_physical.py` ha adesso una
tabella di cosa ogni verbo raggiunge — MUOVERE e TRAMARE arrivano a una Regione,
FORGIARE a un'altra casa, INFLUENZARE e RIVENDICARE al mondo e a chi gioca — e va
rosso se una carta teme un segno fuori dalla portata del suo verbo. E' la
differenza fra una regola scritta male e una regola che non c'e': la prima si
vede, la seconda no.

**Il Calore, dove finisce.** Su 100 anni: Potere 28,6%, Vie 28,3%, Fede 21,7%,
Sopravvivenza 20,1% — e **Terra 1,4%**. Quattro Temi su sei si scaldano davvero;
la Terra quasi mai, ed e' lo stesso buco di [D-256](#d-256) visto da qui: ha una
Tensione sola, e le carte che la toccano muovono presenze invece di aprire
questioni. Scritto, non curato.

**Il prezzo, invariato e dichiarato.** Col tavolo uniforme l'anno peggiore dei
cento resta a **nove Consigli** — lo stesso numero di D-257, non peggiorato dalle
trentasei carte in piu'. A tavolo misto la forma dell'anno tiene: **3-8**. Il
vincolo che non si negozia tiene ai due tavoli: **0 seggi bloccati su 8**.

**La storia scritta a mano e' cambiata di nuovo, e in meglio.** In
`plan_d_crown_calls` adesso **nessuna delle cinque domande cade**: il Calore
arriva prima alle soglie e le case ci arrivano con piu' da spendere. Il piano e'
ribasato la seconda volta, con la ragione dentro. La morale non si e' mossa.

**Una prova che aveva smesso di provare.** `test_a_card_without_a_face_answers_nothing`
cercava fra le carte spedite una senza faccia: finita la conversione non ne
trovava piu' nessuna, e passava a vuoto. Adesso se la fabbrica — prende una carta
e le toglie il blocco in una DataSet sua — cosi' la regola *«se la carta non lo
dichiara, il mondo sta zitto»* resta sorvegliata. Nella stessa prova un
`ENT_ALDRIC` scritto a mano non esisteva nel roster pescato col seme: l'Effetto
falliva, la carta non si giocava, e le asserzioni passavano su un mondo dove non
era successo niente. Corretto: adesso prende un seggio vero e controlla che la
carta si sia giocata davvero.

**E il catalogo stampa la carta.** `docs/CATALOGO_CARTE.md` porta adesso la
faccia fisica di tutte e quarantotto — bersaglio, le due Azioni, la Risonanza con
la sua parte aggravata, e quanto vale al Consiglio. E' il documento che si porta
in tipografia: prima descriveva una carta che al tavolo non esisteva.

Suite **512 prove / 12.289 asserzioni** verdi, tutti i cancelli verdi, playtest
**0 su 8** ai due tavoli.

## D-257 — Il mondo risponde

**implemented in 0.1.219** — prima cura di ISSUES 69, che resta aperta

[D-256](#d-256) ha scritto la grammatica fisica e ha dichiarato per primo cosa
non faceva: **la Risonanza era scritta e non succedeva.** Questa la fa succedere,
ed e' l'unica riga di quel disegno che cambia *come si gioca*.

La regola, come sta sulla carta: *ogni Azione ha una reazione del mondo, e non si
sceglie.* Nel motore diventa cinque righe dentro `_play_asset_card`: dopo che
l'azione e' riuscita, si legge il `physical.resonance` della carta e si scalda il
Tema che ci sta scritto — cioe' sale la questione **piu' vicina alla soglia fra
quelle di quel Tema**. Effetto con inverso, come tutto il resto.

**Due regole di contorno, e la seconda e' quella che conta.**

- Un Tema senza questioni in gioco non scalda niente, e va bene: e' la stessa
  regola del mestiere della carta da [D-106](#d-106).
- **La Risonanza avvicina, non decide.** Non tocca una questione gia' arrivata
  alla soglia, e non le da' mai il punto che la apre. Senza, la reazione del
  mondo sarebbe il modo piu' economico di convocare un Consiglio — l'esatto
  contrario di una reazione.

**Il prezzo, misurato e dichiarato.** Col tavolo uniforme l'anno peggiore dei
cento passa da **otto Consigli a nove**, ed e' fuori dalla forma dell'anno. Ho
provato tre modi di riportarlo a otto — non scaldare una questione gia' aperta,
non darle mai l'ultimo punto, togliere il Calore aggravato — e **nessuno dei tre
ha spostato il numero**: il nove non viene da un caso limite, viene dal fatto che
il mondo adesso e' piu' caldo. Le due regole di contorno restano perche' sono
giuste, non perche' abbiano funzionato. Il vincolo che non si negozia tiene:
`run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8** ai due tavoli.

**Una storia scritta a mano e' cambiata**, ed e' la prova migliore che la regola
si sente. In `plan_d_crown_calls` il Censimento viene giocato due volte, e ogni
volta che qualcuno conta le teste il Potere si scalda: la Successione arriva al
punto prima, il gesto decisivo si sposta dalla quinta domanda alla quarta, e la
quinta cade perche' al tavolo non e' rimasta la forza. Il piano e' ribasato con
la ragione scritta dentro. La morale non e' cambiata — e' l'anno di chi ha
parlato per primo — ed e' piu' netta: parlare per primo scalda il mondo, e il
mondo presenta il conto a chi parla per ultimo.

**Zero, di nuovo, e di nuovo era la sonda.** `run_resonance_probe.gd` ha contato
**zero Risonanze su venti anni** mentre avvenivano. La sorgente di un Effetto
d'azione dice «ACT_PLAY_CARD» e nient'altro: la sonda cercava un `template` e un
`asset_id` che quella sorgente non ha mai avuto. E' la stessa trappola di
[D-254](#d-254) — muta invece che rossa — e la cura non e' stata aggiustare la
sonda: **la Risonanza adesso si firma.** La sua sorgente e' `kind: "resonance"`
con l'id della carta, e questo serve prima di tutto al cronista: chi legge il
verbale distingue quello che il giocatore ha scelto da quello che il mondo ha
risposto.

**Quanto si sente, in numeri.** Su 100 anni, tavolo misto:

| | |
|---|---|
| Risonanze avvenute | **163**, cioe' **1,6 per anno** |
| di quelle, aggravate | **0 su 163** |
| Calore su Sopravvivenza / Vie / Potere | 35% / 31% / 28% |
| Calore su **Antico e Terra** | **zero** |

E sono tre difetti, non tre statistiche:

1. **1,6 volte l'anno non e' una regola, e' un episodio.** La causa non e' la
   regola ma il pilota: dodici carte su quarantotto hanno una faccia. Si cura
   convertendo le altre trentasei, non cambiando la Risonanza.
2. **La meta' condizionale non scatta mai.** Ogni Risonanza porta un «se il
   bersaglio ha gia' questo segno, e' peggio» — e in 163 occasioni non e' mai
   capitato. Le condizioni che ho scritto chiedono segni che il bersaglio quasi
   mai porta: e' contenuto morto, scritto in bella prosa.
3. **Antico e Terra non ricevono Calore**, perche' le due carte che li toccano —
   il Cristallo Rosso e le Braccia per il Raccolto — non le gioca quasi nessuno.
   E' [ISSUES 68](ISSUES.md) vista da un'altra finestra: i verbi che nessuno
   pronuncia.

**Cosa resta aperto.** La scelta fra le **due Azioni** non esiste ancora: il
cervello sceglie un verbo, non una carta con due facce, e il motore esegue la
`card_action` di sempre. Il Calore dei Temi non ha una traccia propria — sale
sulle questioni, che e' un ponte, non la cosa. ISSUES 69 resta aperta con questi
due punti e con la conversione delle trentasei carte.

Suite **511 prove / 11.254 asserzioni** verdi, tutti i cancelli verdi, playtest
**0 su 8** ai due tavoli.

## D-256 — La grammatica fisica: il ponte, non la riscrittura

**implemented in 0.1.218** — apre ISSUES 69

Il committente ha cambiato direzione, e la frase che conta e' questa: *«ECHOES
deve diventare prima di tutto un boardgame fisico-first, con un'app di supporto.
Non deve diventare un gioco digitale in cui l'app custodisce regole invisibili.»*
E la richiesta operativa e' precisa: **procedere per prototipo, non per
riscrittura totale.**

Quindi qui non si riscrive niente. Si aggiunge una **faccia**: la stessa carta
detta nella grammatica del tavolo, accanto a quella che il motore gia' legge. Le
due grammatiche convivono, e un campo le lega — cosi' il giorno che divergono lo
dice un cancello invece di un giocatore.

**Il primo fatto, prima di scrivere una riga.** La direzione chiede **sei Temi
fisici**; i dati ne avevano **quattro**, e non erano quelli:

| Tema chiesto | Tensioni che ci finiscono |
|---|---|
| Potere | 2 — e nessuna era classificata cosi' |
| Sopravvivenza | 3 |
| Terra | **1** |
| Antico | 2 |
| Fede | **1** |
| Vie | 3 |

`domain` diceva SURVIVAL, ANCIENT, TERRITORY, RESOURCE. **La Successione era
TERRITORY**, cioe' la domanda su chi si siede sul trono stava nella cartella dei
confini; **Potere e Fede non esistevano affatto**. Il `domain` resta — e' la
parola del motore — e ogni Tensione porta adesso anche il suo `theme`, che e' la
traccia di Calore che un giocatore guarda. Due Temi su sei restano sottili, e sta
scritto: un mazzo di Domande con una Tensione sola dietro e' un mazzo che si
ripete alla seconda partita.

**Cosa e' stato consegnato.**

1. **Sei Temi come dato** (`schema/theme.schema.json`), non come raggruppamento
   del codice: hanno un titolo, cosa coprono in una riga, e i segni che gli
   appartengono.
2. **`physical` sulle carte**: bersaglio **a segni** (mai il nome di una
   Regione), **due Azioni** fra cui scegliere, una **Risonanza obbligatoria**, e
   l'uso in Consiglio. Dodici carte convertite, due per famiglia.
3. **Dodici Domande fisiche** (`schema/question_card.schema.json`), due per Tema:
   segni richiesti, esiti, segni prodotti e tolti, l'Echo che nasce, e cosa
   cambia nel setup della Cronaca dopo. Ognuna porta `from_template` e
   `from_question`: **e' il ponte**, ed e' la ragione per cui questo non e' un
   secondo gioco scritto a fianco.
4. **`physical` su otto Destini**: il Tema, i segni che guarda, e tre righe che
   dicono a un giocatore cosa sta cercando.
5. **`tools/validate_physical.py`**, che il committente ha chiamato «molto
   importante» e lo e'.

**Il validatore, e le tre volte che ha corretto me.** Fa i sei controlli chiesti —
segni scritti e mai letti, segni letti e mai scritti, Domande senza segni
richiesti, carte senza Risonanza, Risonanze su Temi inesistenti, Temi il cui
mazzo non si puo' aprire. Alla prima corsa ha dato **28 problemi**, e la meta'
erano cecita' mie:

- non vedeva le **cicatrici**, perche' non sono un `SET_REGION_TAG` ma un blocco
  loro: quindici segni «letti e mai scritti» che invece qualcuno scriveva eccome;
- non vedeva le **strutture**, perche' il segno lo porta il **grado** e non il
  tipo: mi ero inventato `structure:keep` e non trovavo `structure:watchtower`,
  che e' il segno vero;
- contava a parte `scar:emptied@REG_EREDAN`, che e' lo stesso segno con detto
  **dove**.

**E un buco nel cancello stesso.** La prima stesura contava «letto» anche un
segno elencato sotto un Tema. Ma un Tema non legge niente: e' una cartella. Se
contasse, questo cancello si soddisferebbe da solo aggiungendo una riga a un
elenco — e sarebbe il difetto peggiore possibile per una guardia. Chiuso il buco,
sono rimasti **quattro segni davvero muti**: `structure:castle`,
`structure:palace`, `structure:archive`, `structure:library`. **Si puo' alzare
una reggia e nessuna carta, nessuna Domanda, nessun Destino la guarda.** Adesso
due Domande li leggono, e non per riempire un elenco: la regola la si scrive dove
c'e' un tetto abbastanza alto da farla sembrare vera, e la reliquia la si guarda
da una stanza che qualcuno tiene.

**La guardia morde**, provata su tre difetti piantati apposta: una carta che
scrive un segno inventato, una Domanda senza segni richiesti, una Risonanza su un
Tema che non esiste. Tutte e tre rosse, exit 1.

**Cosa questa decisione NON fa, e va detto per primo.** Il motore **non legge una
riga** del blocco `physical`. Quando una carta si gioca, guarda ancora
`card_action.kind`: un verbo solo, senza scelta e senza reazione. **La Risonanza
e' scritta e non succede.** Al tavolo le dodici carte funzionano; nell'app sono
quelle di prima. E' ISSUES 69, ed e' la voce che decide se questa direzione e'
vera o solo dichiarata — perche' la Risonanza obbligatoria e' l'unica cosa qui
dentro che cambierebbe **come si gioca**.

**Il rischio, nominato adesso invece che fra dieci carte:** due grammatiche che
non si toccano divergono. Oggi il ponte e' un campo che il validatore controlla.
Se le facce crescono e il motore non le esegue mai, diventano due giochi diversi
con lo stesso nome.

**Nessun dato che il motore legge e' cambiato.** Suite **507 prove / 11.211
asserzioni** verdi, tutti i cancelli verdi, `run_playtest.gd --runs=100
--seed=7000` **0 seggi bloccati su 8** ai due tavoli — che e' quello che ci si
aspetta da un'aggiunta, ed e' il motivo per cui va misurato lo stesso.

## D-255 — Un obiettivo deve chiedere piu' di quanto il mondo dia da solo

**implemented in 0.1.217** — prima cura di ISSUES 68, che resta aperta

[D-254](#d-254) ha isolato la causa maggiore dei «passa» e non l'ha curata: il
**64,9%** di chi non faceva niente aveva **quindici mosse legali e sei carte in
mano**. Non gli mancava il permesso, gli mancava la ragione. Le strade erano tre
— un costo per il passare, un premio per il muovere, obiettivi che chiedano piu'
di quanto il mondo dia da solo — e l'autore ha scelto la terza.

**Il numero che mancava.** La ragione, in questo gioco, sta scritta in un posto
solo: gli obiettivi pescati, perche' l'anno si vince contandoli
([D-198](#d-198)). Nessuna sonda pero' misurava **quanto rende giocare**.
`godot/cli/run_asking_probe.gd` gioca ogni anno **due volte con lo stesso seme**:
una col tavolo vero, una con un **tavolo di pietra** che non spende mai
un'Occasione — delega tutto il resto, cosi' il Consiglio si apre lo stesso,
perche' il Consiglio non e' un'Occasione ma l'orologio del mondo.

Su 100 anni, prima di toccare niente:

| | |
|---|---|
| obiettivi avverati **giocando** | 465 su 1.200 |
| obiettivi avverati **stando fermi** | **470 su 1.200** |
| quanto rende giocare | **−1,1%** |
| avverati che erano gia' veri all'apertura | **43,0%** |

**Il tavolo di pietra ne avverava piu' di quello che giocava.** Dodici obiettivi
su quindici rendevano quanto o piu' stando fermi, e non per caso: erano scritti
in tre forme che il mondo serve da solo.

1. **Assenze.** «Non piu' di due cicatrici», «nessuna domanda lasciata aperta»:
   **vere all'apertura nel 100% dei casi**, e ogni azione poteva solo romperle.
   Non erano traguardi, erano multe.
2. **Scorte.** «Cinque carte in mano», «due Sapere», «due Legami»: il rubinetto
   riempie la mano e spendere la svuota, quindi accumulare **e'** passare. «Le
   Mani Piene» si avverava 79 volte su 81 col tavolo di pietra.
3. **Roba gia' in piedi.** «Almeno una struttura sua»: vera all'apertura nel
   **95%** dei casi, perche' le case partono murate.

**Cosa e' cambiato nei dati.** Sei obiettivi riscritti e uno nuovo, e ogni
riscrittura aggiunge una clausola che il mondo non muove da solo:

| obiettivo | prima | adesso |
|---|---|---|
| Un Mondo che si Puo' Ancora Usare | ≤2 cicatrici | ≤2 cicatrici **e almeno una scoperta** |
| Nessuna Domanda Lasciata Aperta | nessuna aperta | nessuna aperta **e non piu' di 5 carte in mano** |
| Le Mani Piene | ≥5 carte in mano | **piu' carte di ogni altra casa** — che e' quello che la sua prosa diceva gia' |
| Le Cose Scritte | 2 Sapere in mano | 2 Sapere **e almeno una scoperta** |
| Qualcosa che Resta in Piedi | ≥1 struttura | **≥2 strutture** |
| Il Muro che Tiene | ≥1 presidio | ≥1 presidio **e 2 Regioni controllate** |
| Le Corde che Tengono | 2 Legami in mano | 1 Legame **e un'alleanza con qualcuno** |
| **Qualcosa Deve Rompersi** *(nuovo)* | — | **due questioni portate a 4 o piu'** |

**Due clausole nuove nel vocabolario**, e nascono dalla stessa mancanza. Contando
le clausole di tutti gli obiettivi si vedeva il buco a occhio nudo: **INFLUENZARE
non compariva in nessuna**, e FORGIARE nemmeno. Il verbo che i seggi volevano
dire nel 79% delle intenzioni mute non aveva **un solo obiettivo che lo
chiedesse**.

- **`tension_count`** — «quante questioni stanno sopra (o sotto) un valore».
  `tension_limit` nomina la Tensione, e un obiettivo del mazzo comune non la puo'
  nominare: la Chronicle pesca le sue da un pool. Contare senza nominare si
  scrive una volta per tutte le Chronicle.
- **`relation_state` con `other_entity_id: "$any"`** — «alleato con qualcuno, non
  importa con chi». Stessa ragione, stesso buco.

**La sonda ha corretto due volte l'autore, e questo e' il punto della sonda.** La
prima stesura dell'obiettivo nuovo chiedeva di **tenere basse** tre questioni:
sembrava la cosa che INFLUENZARE serve, ed era **al contrario** — le questioni
partono basse, e a tenerle basse basta che nessuno giochi. Misurato: **91% vero
all'apertura, 38 su 43 col tavolo di pietra contro 12 giocando**. Il verso giusto
e' l'altro. Alla seconda stesura «due presidi» e «mano quasi vuota» sono usciti
**0 su 39** e **0 su 50**: non piu' regali, ma impossibili, che e' la malattia
opposta e altrettanto muta.

**E il cervello non sentiva niente di tutto questo.** [D-222](#d-222) aveva messo
gli obiettivi in `_conditions()` — nove letture passano di li' — e la sua nota
diceva «da qui l'obiettivo entra nella scelta dell'azione». **Non era vero.** La
scelta dell'azione non legge `_conditions()`: legge `_open_levels()`, che tornava
soltanto i gradini del Destino. Gli obiettivi entravano nel voto al Consiglio e
nella scelta delle carte, e restavano fuori dall'unico posto che decide se un
seggio si alza. Adesso stanno **in fondo alla scala**: si gioca il primo gradino
che chiede qualcosa, e se il Destino non chiede niente si arriva agli obiettivi —
che e' il contratto di `_nearest_demanding` da [D-047](#d-047), rimasto fino a
oggi senza l'ultimo scalino.

**Con un limite, e misurato.** Gli obiettivi fanno muovere, rivendicare e
forgiare, ma **non convocano il mondo**: `_needed_confluences` spinge in alto
qualunque questione il cui Consiglio potrebbe produrre la Conseguenza che serve,
e un obiettivo privato che apre Consigli cambia la forma dell'anno per tutti. Con
quella lettura accesa la Chronicle 4 passava a **nove Consigli in due anni su
dodici**, sopra il limite duro di otto. Dagli obiettivi si leggono quindi le
Tensioni **nominate**, non quelle dedotte.

**La trappola di GDScript, per la terza volta.** Aggiungere un parametro con
valore di default a `_open_levels` ha rotto la firma dell'override in
`table_of_characters.gd`: il file non compila, `Characters.deal` non esiste piu',
e la sonda **si e' bloccata invece di fallire** — cinque minuti di orologio e
cinque secondi di CPU. Due misure prese in quello stato erano da buttare, e le ho
rifatte. Il cancello `SCRIPT ERROR` di [D-224](#d-224) l'avrebbe presa; la sonda
non ci passa.

**I numeri, dopo.**

| 100 semi, tavolo misto | prima | dopo |
|---|---|---|
| quanto rende giocare | −1,1% | **+86,2%** |
| avverati gia' veri all'apertura | 43,0% | **14,0%** |
| turni «passa» | 85,7% | **82,8%** |
| «nessuna mossa gli serviva» | 64,9% | **58,7%** |

A tavolo uniforme: **+72,4%**, 12,0% veri all'apertura.

**Cosa resta negativo, e perche' non e' un difetto.** Tre obiettivi rendono
ancora meno giocando: sono i **contesi** (`leads_in`), e lo sono **per
costruzione** — li prende un seggio alla volta, quindi il totale e' fisso e con
quattro seggi fermi lo vince chi partiva avanti. Il metro del tavolo di pietra
misura una popolazione, e su una somma fissa non ha niente da misurare. Scritto
qui perche' la tabella non venga letta come una lista di cose da aggiustare.

**Non basta, ed e' scritto.** Il 58,7% resta la fetta maggiore, e le intenzioni
che la mano non sa dire **crescono** da 2.152 a 2.422: e' la faccia buona del
difetto — il cervello vuole piu' spesso — ma dice anche dove finisce questa
decisione e dove comincia la prossima, che e' **il mazzo**. ISSUES 68 resta
aperta.

**Il cancello nuovo.** `test_every_verb_has_a_reason.gd` va rosso il giorno che
un verbo del gioco resta senza nessun obiettivo che lo chieda. Non misura niente
— i numeri stanno nella sonda — ma la riga del confine la tiene.

Suite **500 prove / 10.809 asserzioni** verdi, cancelli verdi, `run_playtest.gd
--runs=100 --seed=7000` **0 seggi bloccati su 8** ai due tavoli.

## D-254 — Cosa era disponibile e non e' stato preso

**implemented in 0.1.216** — apre ISSUES 68

Tutte le sonde di questo progetto misurano **cosa succede**. Nessuna misurava
**cosa era disponibile e non e' stato preso**, ed e' il numero che mancava per
dire qualcosa di serio sul difetto piu' grosso rimasto: *«17 turni su 24 sono
passa»*.

`godot/cli/run_pass_probe.gd` mette un testimone accanto a chi decide. Quando la
risposta e' «passa», gli chiede **perche'** — con le sue stesse funzioni, ramo per
ramo — e chiede alle **regole** quante mosse gli lascerebbero fare. Non decide
niente: la partita con e senza testimone finisce uguale.

**Su 7.200 turni, due cause sono escluse e non con un'impressione:** zero passa
su 6.168 avevano zero mosse legali (media: **15,5**), e dodici avevano la mano
vuota (media: **6,5 carte**). Quindici mosse legali e sei carte in mano, e non fa
niente.

Le tre cause vere sono **65% nessuna ragione**, **20% pesca sbagliata**, **15%
bersaglio sbagliato** — e il verbo che il cervello vuole e non riesce a dire e'
INFLUENZARE nel 79% dei casi.

**Il taglio che rende la misura utile** e' l'ultimo: quando voleva un verbo e non
l'ha detto, *quel verbo ce l'aveva in mano?* Se si', il bersaglio non era
raggiungibile; se no, non l'ha pescato. Sono due cure opposte, e senza quel
taglio si sarebbero confuse in un unico «la mano non basta» che avrebbe portato a
toccare il mazzo — cioe' la cura del 20% applicata all'80%.

**Una trappola vecchia, di nuovo.** La prima stesura chiedeva l'intenzione a
`inner`, che a tavolo misto non e' un cervello: e' il router che smista a quattro
caratteri ([D-053](#d-053)). In GDScript quella chiamata non alza niente che una
sonda possa prendere: **interrompe la funzione**. La sonda ha contato 304 «passa»
con zero cause e ha stampato una tabella vuota — muta invece che rossa. E' la
stessa trappola che il cancello dei test sorveglia da [D-224](#d-224), e qui non
c'era nessun cancello a guardarla: l'ho vista perche' il numero era assurdo.

**Nessun dato e nessuna regola cambiati**: questa e' una misura. Suite 492 prove
/ 10.759 asserzioni verdi, cancelli verdi, `run_playtest.gd --runs=100
--seed=7000` **0 seggi bloccati su 8**.

---

## D-253 — Una saga e' di dieci partite, e alla decima si chiude

**implemented in 0.1.215**

> «La saga continua all'infinito, mentre dovrebbe fermarsi a 10 partite.»

`library_sequel_of` risponde con **se stessa** per la biblioteca, ed e' giusto:
e' l'era che si ripete, per questo esiste. Nessuno pero' contava **fin dove**,
quindi l'offerta *«Gioca l'era successiva»* tornava per sempre.

Il numero era gia' nei dati e gia' letto da qualcun altro:
`saga_scoring.decides_after` vale **10**, ed e' quello che il verbale usa da
[D-181](#d-181) per scrivere *«un anno giocato su dieci»*. La porta non lo
guardava. Adesso lo guarda, e alla decima la saga si chiude dicendolo.

**Nota su D-181, che avevo letto come un permesso**: quella decisione diceva
*«la soglia apre la porta e non la chiude — da li' in poi il tavolo smette
quando vuole»*. Era una scelta ragionevole e non e' quella del committente:
*«dieci partite che rappresentano una saga»*. Dieci e' una **fine**, non un
minimo, e resta scritto nei dati, quindi cambiarlo e' cambiare un numero.

---

## D-252 — La cronaca era nera perche' il testo non veniva disegnato

**implemented in 0.1.215** — [D-248](#d-248) aveva curato il sintomo sbagliato

> «Le cronache ancora nere.»

**Mi ero fermato al primo sospetto che tornava.** D-248 aveva trovato una cosa
vera — la pagina veniva rasterizzata a 3175x4490, oltre il tetto di una texture
da tablet — e l'ho chiamata *la* causa senza verificare che dopo la correzione ci
fosse qualcosa da vedere. La schermata del committente lo dice in un colpo: la
pagina c'e', ha le proporzioni di un A4, porta il suo piede «pagina 1 di 1», ed
e' **nera**.

**Il numero che chiude la questione**: rasterizzata la pagina e contati i pixel,
**0 su 200.941** sono diversi dallo sfondo. Zero inchiostro. Il rasterizzatore
SVG di Godot **non disegna gli elementi `<text>`**, e una cronaca e' sola prosa:
di quella pagina si disegnava il rettangolo di fondo e nient'altro.

Per la **stampa** l'SVG va benissimo — a disegnarlo e' un browser o una
tipografia, che il testo lo sanno scrivere. Per lo **schermo** no, e non c'e'
scala che lo aggiusti: l'unica strada e' che a scrivere sia Godot.

`ChronicleBook` ora sa dire le sue pagine **impaginate e non disegnate** — le
righe con la loro posizione in millimetri — e la vista le scrive con
`draw_string` su un foglio proporzionato come un A4. **Stessa impaginazione,
stessa sorgente**: `laid_out` e `pages` chiamano la stessa divisione in pagine, e
una prova verifica che contino lo stesso numero di pagine. La cronaca che si
legge nell'app e quella che esce dalla stampante restano la stessa pagina.

**E la prova che diceva il falso, per la seconda volta.** Guardava il **codice
d'uscita** del rasterizzatore: tornava OK, l'immagine aveva dei pixel, e tutti i
pixel erano sfondo. D-248 l'aveva gia' corretta una volta — e l'aveva corretta
male, perche' ha aggiunto un controllo sulla **dimensione** invece che
sull'**inchiostro**. Adesso guarda le righe che finiscono sulla pagina: se una
pagina non ha righe non ha inchiostro, e non importa quanto bene si sia disegnato
lo sfondo.

**Misurato:** suite 492 prove / 10.758 asserzioni verdi (era 489 / 10.747), i
cancelli degli strumenti verdi, i piani di simulazione verdi, export e cataloghi
allineati, `run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8**.

---

## D-251 — La colonna di lato spingeva la mano fuori dallo schermo

**implemented in 0.1.214**

> «Le carte sono quasi sparite del tutto.»

**Non erano piccole: erano sotto il bordo della finestra.** Nella schermata che
il committente ha mandato si vede il taglio esatto — dei mazzi in basso si
vedono solo i primi venti pixel.

**Il numero, misurato**: la colonna di destra chiede **763 pixel** di altezza
minima. Cresce con quello che ha da dire — quattro domande, i rapporti, i
diritti, i segni della casa, il Destino con le sue due carte e i quattro
obiettivi — e la finestra della schermata ne ha **726**. Una colonna che chiede
piu' della pagina non si stringe: **spinge in giu' tutto quello che le sta
sotto**, e sotto c'e' la mano.

Ed e' un difetto che **non si vede mai su un monitor alto** e si vede **sempre**
su un portatile o un tablet in orizzontale. E' la stessa forma delle sei di ieri:
qualcosa costruito guardando uno schermo grande.

**Due cose:**

- la colonna di stato sta dentro un pannello che **scorre**. Da li' la sua
  altezza smette di decidere la pagina: puo' crescere quanto vuole senza
  portarsi via niente;
- i due tarocchi del Destino erano **130x222 l'uno** — da soli un terzo della
  colonna. Adesso sono 80x138: grandi abbastanza da riconoscersi, non da
  occupare la pagina.

**Tre prove**, e la prima e' quella che rende il rischio un fatto invece di
un'impressione: la colonna **puo'** chiedere piu' di 600 pixel, quindi non puo'
stare in una pagina che non scorre. Poi che ci stia davvero dentro un pannello
che scorre, e che mano piu' mappa entrino in una finestra bassa — se domani la
carta cresce ancora, la prova lo dice **prima** che le carte spariscano di nuovo.

**Misurato:** suite 489 prove / 10.747 asserzioni verdi (era 486 / 10.741), i
cancelli degli strumenti verdi, i piani di simulazione verdi, i due cataloghi
allineati, `run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8**.

---

## D-250 — Una saga che non prosegue deve dire perche'

**implemented in 0.1.213** — parziale: la causa non e' ancora provata

> «La saga si ferma alla seconda partita e non va avanti.»

**Quello che ho misurato, e che esclude il motore.** La catena vera —
`setup` → `inherit_from` → `run`, quattro Chronicle di fila, guidata come la
guida lo schermo — gira pulita: quattro anni, quattro rapporti completi, e
`library_sequel_of("CHR_02")` risponde `CHR_02` ogni volta, come deve. Il libro
della saga con due anni dentro produce quattro pagine e tutte si disegnano. Il
punto in cui si ferma **non e' nelle regole**.

**Quello che non sono riuscito a fare**: guidare la schermata vera in headless
per vederlo succedere. Un `Control` montato in un `SceneTree` da riga di comando
non ha fatto girare il suo giro di scelte, e senza quello la diagnosi resterebbe
un'ipotesi scritta come se fosse un fatto. Non la scrivo.

**Quello che ho corretto lo stesso**, perche' e' un difetto in ogni caso: la
riga che apre l'era successiva **ignorava il `false`** che `setup` puo' tornare.
Un `setup` fallito lasciava una sessione a meta' e una schermata che non fa
niente — cioe' **esattamente la faccia che ha un blocco**, senza una parola su
perche'. Adesso dice cosa non si e' aperto e chiude la saga con il salvataggio
al sicuro. Se la causa era quella, e' risolta; se non lo era, la prossima volta
lo schermo lo dice invece di tacere, ed e' comunque un passo avanti rispetto a
indovinare.

**E c'e' un sospetto che [D-248](#d-248) potrebbe aver gia' chiuso**: alla fine
del **secondo** anno — e solo da li' in poi — si apre il *libro della saga*, che
prima di questa versione rasterizzava una pagina da cinquantaquattro megabyte.
Su un tablet una texture oltre il tetto puo' non fallire in silenzio: puo'
portarsi via il contesto grafico, e allora la pagina non e' vuota, e' tutto
fermo. Il momento coincide. **Non lo dichiaro risolto senza una prova.**

**La domanda che serve, e che vale piu' di dieci ipotesi**: a fine seconda
partita l'offerta *«Gioca l'era successiva»* **compare**? Se compare e toccarla
non fa niente, il difetto e' nell'apertura dell'anno; se non compare, e' prima.
Sono due meta' diverse del codice e la risposta ne esclude una.

---

## D-249 — Un file solo per fare una carta, e uno per i pezzi

**implemented in 0.1.213**

> «Dimmi dove trovo, oppure generalo, il file con tutte le carte con la
> descrizione, gli effetti, i valori e il prompt per fare l'immagine.»
> «Dimmi anche tutte le pedine che devo generare per indicare le varie cose
> sulla mappa.»

Quelle quattro cose esistevano tutte, in **tre posti diversi**: i numeri in
`ASSET_MANIFEST.md`, gli effetti solo dentro il JSON, il prompt in
`BRIEF_ARTE.md`. Chi doveva far disegnare una carta teneva tre documenti aperti
e sperava che parlassero della stessa carta.

[CATALOGO_CARTE.md](CATALOGO_CARTE.md) e' una scheda per carta — **87 carte** —
con dentro tutto, e una sezione per i **pezzi della mappa**: le pietre coi loro
gradi e la loro rovina, le condizioni, le cicatrici, le pedine e i vessilli.
**64 pezzi diversi da fabbricare.**

**Nessuna riga e' scritta a mano**, ed e' l'unica cosa che rende il documento
affidabile: i numeri vengono dai dati, le frasi da `AssetText` — lo stesso posto
che le scrive sullo schermo e sul cartone ([D-228](#d-228)) — e il prompt da
`ArtBible`, lo stesso che compone il brief. Tre sorgenti, una pagina, e non
possono divergere. La CI lo rigenera e lo confronta.

**E il documento ha trovato un difetto mentre lo scriveva**: `scar:burned_records`
usciva nell'elenco delle cicatrici **col proprio id**. E' la cicatrice che
l'Archivio lascia bruciando, e la posa la **rovina di una pietra**, non un
Effetto — per questo il censimento di [D-107](#d-107) non la vedeva. Adesso ha la
sua parola, e la prova guarda anche le rovine.

---

## D-248 — La cronaca non era vuota: era troppo grande per essere disegnata

**implemented in 0.1.213**

> «La cronaca dell'anno e' sempre una pagina vuota.»

Non era vuota. La vista rasterizza l'SVG della pagina a **4 pixel per
millimetro**, e un A4 a quella scala esce **3175x4490**: cinquantaquattro
megabyte di texture, e un lato lungo che supera il massimo che la scheda di un
tablet accetta. La texture non si carica, e resta una pagina nera.

Il commento nel codice diceva *«4 rende un A4 a 840x1188»*. **Era sbagliato di un
fattore quattro**, e nessuno l'ha mai verificato perche' su un monitor da
scrivania funzionava lo stesso.

Adesso la pagina si misura prima a scala 1 — costa poco — e da li' si calcola
quanto si puo' ingrandire senza sfondare il tetto: **1131x1599**, sette megabyte,
piu' nitida dello schermo che la mostra. Il numero non e' indovinato: se domani
la pagina cambia formato, la misura si aggiusta da sola.

**E c'era gia' una prova che diceva «ogni pagina si rasterizza», ed era verde.**
Disegnava a scala **2**, mentre l'applicazione disegnava a **4**: misurava una
cosa diversa da quella che si vedeva. Adesso chiama la stessa funzione che chiama
lo schermo, e verifica che il lato lungo stia sotto il tetto — ed e' l'unico modo
in cui una prova su una vista puo' voler dire qualcosa.

---

## D-247 — A che punto siamo, e a chi tocca

**implemented in 0.1.213**

> «Non c'e' un testo che dice a chi tocca e quando finisce un turno di un
> giocatore o un atto.»

Al tavolo fisico si vede: c'e' un segnalino di turno, e le carte di chi sta
giocando sono in mano sua. Sullo schermo non c'era **niente** — il verbale a
sinistra lo racconta *dopo*, e dopo non serve a chi deve decidere adesso.

Adesso, sopra le domande: **ATTO 2 di 3 · ROUND 1 di 3**, e sotto *«Tocca a
Kessa — 2 azioni»*. Tutto derivato dal mondo, niente di nuovo da tenere
allineato: **chi gioca adesso** si legge dalle azioni rimaste, perche' il giro le
assegna a un seggio quando il suo turno comincia e le consuma fino a zero — in
ogni momento c'e' un solo seggio con azioni in mano.

E la riga sotto dice **quando finisce l'Atto**, non solo quando si tiene il
Consiglio: sono la stessa cosa, e per chi gioca non e' ovvio.

---

## D-246 — Una carta che si taglia il proprio testo

**implemented in 0.1.213** — corregge [D-242](#d-242)

> «Le carte in mano sono ancora troppo piccole, sono tagliate e non c'e' scritto
> nulla sopra.»

Tre lamentele, e sono **una sola**. [D-242](#d-242) aveva portato la carta a 150
pixel e le aveva messo **sotto l'immagine** il nome e il verbo. Quello che si
taglia di una carta troppo alta e' il fondo: cioe' esattamente il testo appena
aggiunto.

La carta chiedeva 196 pixel, la mano ne dava 200, e bastava un titolo su due
righe. Peggio: l'immagine aveva `EXPAND_FILL`, quindi quando lo spazio non
bastava **lo prendeva alle righe di sotto** — il testo non si stringeva, spariva.

Tre cose, e nessuna e' un numero piu' grande:

- **le misure si sommano invece di essere indovinate**: immagine, nome, verbo e
  fondo hanno ognuno la propria altezza minima, e l'altezza della carta e' la
  somma. `wanted_height()` la dice, e **la mano la chiede alla carta** invece di
  ripeterla in un altro file — che e' esattamente dove il difetto e' nato;
- **il titolo si ferma a due righe**: un titolo lungo allungava la carta oltre il
  suo contenitore, e a quel punto tagliava se stesso;
- **la misura si dichiara anche in `render`**, non solo in `_ready`: una carta
  disegnata fuori dall'albero non ha mai visto `_ready`, e restava schiacciabile
  a qualunque cosa.

**Tre prove**, e la terza e' quella che chiude il cerchio: che la mano chieda alla
carta quanto e' alta, invece di indovinarlo.

**Misurato:** suite 486 prove / 10.741 asserzioni verdi (era 483 / 10.727), i
cancelli degli strumenti verdi — compreso il nuovo sul catalogo delle carte — i
piani di simulazione verdi, export e cataloghi allineati, `run_playtest.gd
--runs=100 --seed=7000` **0 seggi bloccati su 8**.

---

## D-245 — L'app si apre e si gioca: nessuna domanda

**implemented in 0.1.212** — sostituisce [D-241](#d-241), che aveva ridotto la
domanda invece di toglierla

> «Non deve chiedere nessuna saga.»

[D-241](#d-241) aveva sistemato la cosa sbagliata. La domanda del menu era
*«quale anno giochi?»* con quattro voci, due delle quali non sono inizi; l'ho
ridotta a *«da quale saga cominci?»* con due voci corrette, e ho scambiato una
domanda meno sbagliata per una domanda risolta. **Era ancora una domanda di
troppo**, ed e' la seconda volta in due giri che la stessa correzione arriva
mezza.

Adesso si apre l'app, e si gioca. Il primo anno e' il primo, e il resto viene da
se': a fine Chronicle il gioco offre gia' l'era successiva ([D-095](#d-095)), che
e' il posto giusto per parlare del tempo che passa — quando **e' passato**, non
prima di cominciare.

**Il prezzo, scritto perche' e' reale**: la seconda saga (CHR_03, anno 1640, le
altre quattro case) adesso **non si raggiunge dal menu**. E' contenuto scritto e
non piu' apribile, che e' esattamente quello che [D-035](#d-035) chiama
contenuto che non esiste. Non lo risolvo inventando una seconda domanda travestita:
sta scritto in [ISSUES 66](ISSUES.md#66), ed e' una decisione d'autore — se e
dove quella saga si apre.

**Una prova**, e tiene l'unica cosa che resta da tenere: che il posto da cui si
parte sia un **inizio** e non il seguito di qualcos'altro.

**Misurato:** suite 483 prove / 10.727 asserzioni verdi, i cancelli degli
strumenti verdi, i piani di simulazione verdi, `run_playtest.gd --runs=100
--seed=7000` **0 seggi bloccati su 8**.

---

## D-244 — Le due carte del Destino dicono cosa sono

**implemented in 0.1.211**

> «Le due carte destino cosa servono?»

La domanda e' arrivata perche' erano **due figure grandi e mute**. Stavano li'
da [D-101](#d-101), e nessuno le aveva mai spiegate: al tavolo fisico la
risposta e' nella forma del cartoncino e in dove sta posato, sullo schermo non
c'e' ne' l'una ne' l'altro.

Adesso la prima dice **CHI SEI** e la seconda **COSA VUOI**, e sotto ognuna c'e'
il suo nome — la casa che giochi e il Destino che ha giurato. Sono le due
domande su cui gira tutto il gioco, e leggerle affiancate e' il modo piu' rapido
di capirlo.

---

## D-243 — La traccia delle domande dice la regola di adesso

**implemented in 0.1.211**

> «Le domande dell'anno sono ancora con le vecchie regole.»

Ed era vero, alla lettera. La riga di ogni domanda scriveva **`12/18`** con una
barra che si riempiva verso la soglia — e da [D-214](#d-214) **la soglia non apre
piu' niente**. Tutte e quattro le Chronicle della scatola dichiarano
`at_end_of_act`: il Consiglio si tiene a fine Atto, sulla domanda **piu' calda**,
e non c'e' nessun numero da raggiungere.

E' esattamente il difetto che [D-224](#d-224) ha corretto sulla pagina d'aiuto,
in un altro posto e sopravvissuto per la stessa ragione: **nessuna misura guarda
lo schermo**.

**Il conto ora e' relativo.** La barra si misura sul mucchio piu' alto, cosi' le
quattro righe insieme dicono **la classifica** invece di quattro percentuali di
un traguardo che non esiste; e la domanda davanti lo scrive — *«va al
Consiglio»*, o *«a pari»* quando sono due.

**La soglia non e' stata tolta dal codice**, e non doveva: una Chronicle che non
dichiara `at_end_of_act` gioca ancora a soglia, e allora la riga torna a dire
`12/18`. La pagina segue i dati invece di avere un'opinione propria, ed e' la
stessa regola di D-224. Due prove, una per lato.

---

## D-242 — La carta si legge senza passarci sopra

**implemented in 0.1.211**

> «Le carte sono minuscole e non si capisce cosa fanno, non c'e' il testo che lo
> spiega.»

Una carta in mano era **110 pixel** di figurina con sotto un numero. Tutto quello
che la spiegava — il titolo, il verbo che porta, cosa costa, la frase d'autore —
viveva nel **suggerimento del mouse**.

Su un tablet il passaggio del mouse **non esiste**. E' lo stesso difetto di
[D-240](#d-240) sui pezzi della mappa, nello stesso giorno e in un altro posto:
il testo c'era, era scritto bene, e non lo vedeva nessuno. Vale la pena
nominarlo per quello che e': **il tooltip e' un posto dove il testo va a
morire**, su meta' dei dispositivi che esistono.

Adesso la carta e' 150 pixel e porta **sulla faccia** il proprio nome e il
proprio verbo — «muovo una presenza», «costruisco» — che e' la domanda vera di
chi ce l'ha in mano: non *«quanto vale»*, ma *«cosa succede se la calo»*
([D-228](#d-228)).

E quando una carta viene **presa in mano** ([D-239](#d-239)), la colonna accanto
ne scrive la lettura intera: nome, famiglia, forza, verbo, cosa lascia al mondo,
la frase d'autore. E' il momento in cui serve — si e' scelto *cosa*, si sta
decidendo *come*.

**Tre prove**: ogni carta della scatola porta il proprio nome sulla faccia;
nessuna riga di quella faccia contiene un buco o un id; e il verbo c'e' su tutte.

**Misurato:** suite 482 prove / 10.724 asserzioni verdi (era 477 / 10.560), i
cancelli degli strumenti verdi, i piani di simulazione verdi, export e catalogo
allineati, `run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8**.

**E una cosa che non ho fatto**, perche' non e' una correzione: *«tutta la pagina
dell'app va rivista»* e' vero e non si chiude con tre riparazioni. Sta scritto
come [ISSUES 65](ISSUES.md#65), con dentro quello che questo giro ha insegnato —
che i difetti di questa pagina hanno tutti la stessa forma, e nessuno di loro
puo' essere trovato da un cancello.

---

## D-241 — Una saga si comincia, non si sceglie l'anno

**implemented in 0.1.210**

> «Chiede ancora quale anno voglio giocare.»

Il menu offriva **tutte e quattro** le Chronicle della scatola come punto di
partenza. Due delle quattro non lo sono: sono il **seguito** di un'altra — la
biblioteca della stessa eta', che eredita il mondo dell'anno prima e si
raggiunge **giocando**. Cominciare da li' vuol dire aprire il secondo capitolo
senza il primo, e nessuno lo aveva mai notato perche' funzionava: partiva, e
partiva da un mondo che non era successo a nessuno.

E la domanda era anche quella sbagliata. Una saga si **comincia**, e poi gli
anni vengono da soli: a fine Chronicle il gioco offre gia' l'era successiva
([D-095](#d-095)) e la catena esiste da allora. All'inizio non c'e' un anno da
scegliere, c'e' **una saga**. Adesso il menu chiede *«Da quale saga cominci?»*,
offre solo le due aperture, e se un giorno ne restasse una sola non chiede
niente.

**Tre prove**: il menu non offre mai il seguito di qualcun altro; offre **tutte**
le aperture, perche' una saga scritta e mai raggiungibile sarebbe contenuto che
non esiste ([D-035](#d-035)); e le offre in ordine d'anno.

---

## D-240 — Le pedine sulla mappa, quando la mappa sta in mano

**implemented in 0.1.210**

> «Le pedine e cicatrici sulla mappa non si capiscono e sono troppo piccole.»

Due difetti diversi dentro la stessa frase, e il secondo era il peggiore.

**Troppo piccole**, letteralmente: un pezzo era 17 pixel. Leggibile su un
monitor a un palmo dagli occhi, illeggibile su un tablet tenuto in mano — e una
forma dentro diciassette pixel non e' una forma, e' una macchia. Adesso e' 26,
e i punti del grado sotto il pezzo sono grossi abbastanza da contarsi.

**Non si capiscono**, ed e' la parte che nessuno aveva visto. La parola di un
pezzo — «torre di guardia», «cicatrice del drago» — si scrive per la Regione
**guardata**, e `_hovered` valeva solo per le Regioni *raggiungibili*. Fuori da
una scelta nessuna Regione e' raggiungibile: **quelle parole non comparivano
quasi mai.** Guardare e poter andare sono due cose diverse, e la seconda ha gia'
il suo anello d'oro per dirsi.

E su un tablet non esiste affatto un «sopra»: senza mouse non c'e' passaggio del
cursore, quindi la parola non sarebbe comparsa **mai**. Adesso il tocco su una
Regione che non e' un bersaglio vale come guardarla, e la nomina — con una
fascia scura sotto la riga, perche' su una tessera dipinta chiara la parola
spariva dentro il quadro.

---

## D-239 — Il tavolo su un tablet: due tocchi al posto del trascinamento

**implemented in 0.1.210**

> «Su iPad il drag & drop non funziona.»

E' vero, e **non e' un difetto da sistemare**: su un touchscreen il dito che
preme e scorre fa scorrere la pagina, ed e' giusto che la faccia scorrere. Il
trascinamento e' un gesto da mouse, e insistere sarebbe stato rubare a un
dispositivo il suo gesto piu' comune per farne uno che li' non appartiene a
niente.

Il gesto va **diviso in due tempi** — si prende la carta, si posa dove la si
vuole usare — che e' poi come si fa al tavolo vero, e come il committente
l'aveva descritto fin dall'inizio: *«si seleziona una carta, si decide come
usarla»*.

**Cosa succede adesso.** Si tocca una carta: si alza dal ventaglio, prende un
bordo d'oro, e si accendono **tutti i posti dove puo' andare** — le Regioni sulla
mappa, le domande sulla traccia, le case nella colonna. Si tocca il posto, e la
mossa parte. Toccare di nuovo la carta la rimette giu': prendere in mano non e'
una mossa, e da una cosa che non e' una mossa si deve poter tornare indietro.

**Il conflitto da sciogliere** era con [D-236](#d-236): un tocco su una domanda
apre la sua scheda. Adesso i due gesti non convivono mai — con una carta in mano
la riga posa, a mani vuote apre — perche' se stai posando una carta non stai
leggendo, e aprire una pagina sopra il tavolo mentre la mossa parte e' il modo
piu' rapido di rendere il tocco inaffidabile.

**Il trascinamento resta**, intero: col mouse e' piu' rapido, e chi ce l'ha non
perde niente. Sono due modi di dire la stessa cosa, come lo erano il bottone e
la mappa.

**Cinque prove**, e la prima e' quella che conta: tenere una carta in mano
accende **solo** i posti dove quella carta puo' andare — un posto acceso dove la
mossa non e' legale sarebbe la stessa bugia di una Regione cerchiata d'oro che
poi non accetta niente ([D-039](#d-039)). Poi: posarla risponde con l'indice che
`ask()` aspetta; non apre anche la scheda; a mani vuote la riga torna ad aprire
la scheda; e la carta in mano **si vede** che e' in mano.

Provate al contrario: togliendo la posa, una diventa rossa.

**E `emulate_mouse_from_touch` e' scritto in `project.godot`.** E' gia' il
comportamento di fabbrica di Godot, e sta scritto per la stessa ragione per cui
una regola sta nei dati: da adesso il gioco si gioca anche su un tablet, e una
cosa da cui dipende il tavolo non puo' restare un valore implicito.

**Misurato:** suite 477 prove / 10.560 asserzioni verdi (era 469 / 10.541), i
cancelli degli strumenti verdi, i piani di simulazione verdi, export e catalogo
allineati, `run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8** a
tavolo misto e uniforme — e vale ancora quello che D-238 ha messo a verbale: il
cancello era verde anche quando il gioco su un tablet non si poteva giocare.
Tutte e tre queste decisioni le ha trovate una persona con l'app in mano.

---

## D-238 — Il bottone che rendeva invisibile il trascinamento

**implemented in 0.1.209** — riapre e chiude il terzo passo di ISSUES 63

> «L'interfaccia non e' cambiata, sembra tutto uguale a prima.» — il committente,
> guardando la build appena pubblicata

Aveva ragione, e la ragione non era la cache del browser: **era il codice**.

Da [D-230](#d-230) e [D-231](#d-231) una carta si prende e si lascia cadere su
una Regione, su una domanda o su una casa. Ma la colonna delle scelte continuava
a stampare **un bottone per ognuna**: l'unica esclusione era la scelta che
viveva su una Regione. Influenzare una domanda, tramare su una domanda,
forgiare con una casa — tutte e tre trascinabili da D-231 — restavano anche una
riga di testo premibile accanto alla mappa.

Il risultato e' che il trascinamento **esisteva e non serviva a niente**: chi
apriva l'app vedeva la stessa lista di pulsanti di prima, e non aveva nessuna
ragione di scoprire che si potesse fare altro. Tre decisioni di lavoro, misurate
e provate, invisibili per una riga di filtro scritta troppo stretta — ed erano
nate proprio contro questo: *«la gui deve prevedere movimenti drag & drop, **non
pulsanti che dicono cosa fare**»*.

**Adesso la colonna tiene solo quello che non ha un posto dove cadere**: passare,
lasciar decidere alla policy, una trama che non parla di niente di visibile. Il
resto si prende in mano.

**E la porta di servizio, che e' anche il primo dei due movimenti che il
committente aveva descritto.** *«Si seleziona una carta, si decide come usarla»*
sono due gesti, e il trascinamento li fa insieme. Il **clic** sulla carta fa il
primo: la colonna si restringe a quello che quella carta li' sa fare — e se sa
fare una cosa sola, sceglierla *e'* la mossa. Serve anche a non lasciare un
vicolo cieco: un trascinamento che non riesce — un dito su un telefono, un mouse
che scappa — non deve rendere irraggiungibile una mossa legale.

**Quattro prove**, e la prima e' quella che il difetto non aveva:

- una scelta che ha un posto dove cadere **non e' anche un bottone**;
- una che non ce l'ha **resta** un bottone, perche' altrimenti sparirebbe dal
  gioco;
- nominare la carta non dice *dove*: `{"asset": X}` da solo non e' un posto;
- il clic sceglie la carta, e una carta senza scelte non risponde al clic — la
  stessa regola del trascinamento ([D-039](#d-039)), detta per il dito.

Provate al contrario: rimettendo il filtro vecchio, due diventano rosse.

**Misurato:** suite 469 prove / 10.541 asserzioni verdi (era 465 / 10.532), i
cancelli degli strumenti verdi, i piani di simulazione verdi,
`run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8** a tavolo
misto e uniforme — e vale la pena ripeterlo, perche' e' la lezione di questa
decisione: **il cancello era verde anche prima**, e sarebbe rimasto verde per
sempre con una GUI che non si poteva usare. Nessuna misura copre quello che una
persona vede (§5ter); questo difetto l'ha trovato il committente aprendo l'app.

---

## D-237 — I tre coperti sono della saga, non dell'anno

**implemented in 0.1.208** — chiude ISSUES 58

> «Ogni entita' ha un obiettivo palese e **tre segreti che si pescano
> all'inizio della saga**.» — l'idea di partenza

`_deal_objectives` girava nel setup di **ogni** Chronicle, e i tre coperti si
ripescavano ogni anno. Non e' una sfumatura: sposta l'unita' dell'ambizione
dalla saga all'anno. Con obiettivi d'anno ogni Chronicle e' un contenitore
chiuso e la campagna e' **una somma di partite invece di una storia sola**; con
obiettivi di saga, al terzo anno stai costruendo verso qualcosa che nessuno ha
visto, e una mossa che sembra sbagliata oggi puo' essere il quarto passo di un
piano di otto.

**La voce chiedeva di misurare prima, e nominava il costo con precisione:** *un
obiettivo pescato a inizio saga puo' risultare **impossibile** nel mondo che la
Chronicle 4 ha prodotto.* Cosi' `run_objectives_probe.gd` gioca **le stesse
saghe due volte**, coi coperti dell'anno e coi coperti della saga. La regola sta
nei dati (`objectives.drawn`), quindi il confronto e' fra due dichiarazioni e
non fra due versioni del codice: si accende e si spegne senza ricompilare
niente.

**20 saghe da 10 Chronicle:**

| | coperti dell'anno | coperti della saga |
|---|---|---|
| obiettivi coperti diversi visti da un seggio | 9,9 | **6,6** |
| dei tre d'apertura, avverati all'anno 1 | 39,6% | 39,6% |
| ...all'anno 5 | 23,5% | 21,3% |
| ...all'anno 10 | 23,8% | **34,5%** |
| coperti d'apertura mai avverati in tutta la saga | 51% | **43%** |
| livelli a fine anno (NONE/MIN/VIC/TRI) | 26/39/34/1 | 28/37/34/1 |

**Il costo temuto non si verifica**, e la ragione e' strutturale: **nessuno dei
quindici obiettivi condivisi nomina una Regione o una casa** — sono scritti su
*quanto* e non su *dove* ([D-221](#d-221)). All'anno 10 i tre d'apertura si
avverano **piu'** spesso, non meno: non si spengono, si maturano.

La voce offriva due strade — obiettivi che valgano in qualunque mondo **oppure**
una regola di sostituzione dichiarata. Il gioco aveva gia' preso la prima senza
saperlo: la premessa era vera e **non la teneva niente**, e una premessa che
nessuno sorveglia e' una premessa che scade. Adesso c'e' una prova che va rossa
il giorno che qualcuno scrive «tieni la Valle Verde» fra gli obiettivi
condivisi — **prima** che una saga scopra al quinto anno di inseguire un posto
che non c'e' piu'.

**E la misura ha trovato un limite che non cercavo.** Solo il **51%** dei seggi
seduti dopo l'apertura sono le case che hanno aperto la saga: una Chronicle
pesca quattro case su otto, e ogni anno ripesca. Gli obiettivi di saga valgono
quindi per **circa meta' tavolo**; l'altra meta' sono case che si siedono dopo,
e pescano i propri perche' non hanno una saga alle spalle da cui ereditare. Non
e' un difetto di questa regola ed e' scritto qui invece che scoperto dopo: e'
[ISSUES 64](ISSUES.md#64).

**Dichiarata, non implicita.** `objectives.drawn` vale `per_chronicle` — cioe'
l'assenza, il comportamento di prima — oppure `per_saga`. Il passaggio avviene
in `inherit_from`, accanto a `saga_score`, ed e' fra le eccezioni gia'
dichiarate all'effect-sourcing (§6.3): succede **prima** che la partita cominci,
sullo stesso mondo che sta nascendo, e non e' una mossa che qualcuno possa
disfare.

**Misurato:** suite 465 prove / 10.532 asserzioni verdi (era 462 / 10.496), i
cancelli degli strumenti verdi, i piani di simulazione verdi, export e catalogo
allineati, `run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8** a
tavolo misto e uniforme — e qui il cancello va detto per quello che e': il
playtest gioca **una Chronicle sola**, dove non c'e' un anno prima da cui
ereditare, quindi passa **per costruzione**. La misura che conta e' quella delle
saghe, qui sopra.

---

## D-236 — Si gioca all'app: allora la scheda della domanda sta sullo schermo

**implemented in 0.1.207** — decisione del committente, e cosa ne segue subito

> «Per il momento dobbiamo usare la versione digitale. Poi penseremo alla
> versione fisica.»

E' la risposta d'autore che ISSUES 62 aspettava, ed e' la terza delle tre —
**l'app resta l'arbitro** — con una data di scadenza aperta invece che con una
rinuncia. La registro come una dichiarazione reversibile, come ogni altra scelta
di questo progetto: il giorno che si torna al cartone, il materiale c'e' gia'
([CATALOGO_CONSIGLI.md](CATALOGO_CONSIGLI.md), [D-232](#d-232)) e non si riparte
da zero.

**Ma una decisione sul mezzo non e' neutra sul contenuto.** Se lo schermo e' il
tavolo, allora tutto quello che al tavolo staresti a *guardare mentre pensi*
deve stare sullo schermo — e c'era una cosa che non ci stava, ed era la piu'
importante.

Fino a qui le proposte comparivano una riga alla volta **a Consiglio gia'
aperto**: cioe' quando decidere e' tardi. Chi scalda una domanda per tre round
non poteva sapere cosa ci sarebbe stato da proporre quando quella domanda
fosse arrivata al tavolo. Al cartone quella scheda la prendi in mano quando
vuoi; all'app non esisteva.

**La scheda di una domanda** (`ui/council_sheet.gd`) si apre con un clic sulla
riga della domanda, e dice le stesse cose che direbbe una scheda stampata: la
domanda, cosa si potra' proporre, quando lo si potra' proporre, e **cosa lascia
al mondo** ogni Conseguenza — una riga per Conseguenza, col suo nome, perche'
una proposta che ne porta due porta **due esiti diversi** e fonderli in una
filza nascondeva proprio quella distinzione.

**Il punto delicato e' la voce, e la prima stesura l'ha sbagliato.** Avevo usato
`ConfluenceController.say()`, che riempie i buchi con le bindings del Consiglio
**aperto**. Ma una scheda si legge proprio quando il Consiglio non e' aperto:
li' quelle bindings sono vuote, e la pagina mostrava `$region_focus` a chi
gioca. La prova l'ha preso al primo giro.

Il mondo pero' le risposte ce le ha lo stesso — *di quale Regione parla questa
domanda adesso* e *chi la porterebbe se si aprisse* si calcolano senza
Consiglio, ed e' la strada che una carta Echo percorre da sempre. Quindi:
**prima si riempie con quello che il mondo sa, e quello che resta si spiega.**
Un nome vero quando c'e', un ruolo quando non c'e', mai un `$`. La scheda della
Carestia adesso dice *«Chi manda gli uomini a scavare nella Valle Verde?»* e
*«Li paghi Maestra Ilve»*.

**E la pagina ha fatto vedere quanto silenzio c'era dietro.** Mettere le
clausole sotto gli occhi ha reso leggibile una cosa che nessuno guardava:

| | prima | adesso |
|---|---|---|
| segni del mondo senza una parola | **19** | 0 |
| «scoperte» che uscivano col proprio id (`scoperta: trade_ledger`) | 4 | 0 |
| effetti che dicevano «una casa porta addosso un segno nuovo» | tutti | nessuno |

I diciannove non erano invisibili per caso: il censimento di
[D-107](#d-107) guardava i segni di **Regione** e di **casa**, non quelli del
**mondo**, e non guardava affatto le **clausole**. Adesso li guarda, e una nuova
prova rifiuta anche una parola che contiene il proprio id — `scoperta:
trade_ledger` passava `known()` grazie al ripiego per prefisso, che e' il modo
piu' silenzioso di sembrare a posto.

**Quattro prove sulla pagina**, perche' il cancello non gioca con le mani
(§5ter): ogni domanda della scatola ha una scheda e la scheda **arriva in
fondo**; nessuna riga parla al programmatore; senza partita i buchi si spiegano
invece di riempirsi; e una proposta dice cosa lascia al mondo.

**Misurato:** suite 462 prove / 10.496 asserzioni verdi (era 457 / 8.532),
cancelli degli strumenti verdi, piani di simulazione verdi, export
deterministico col brief allineato, catalogo dei Consigli allineato (il cancello
di deriva ha morso: le parole nuove cambiano anche la scheda stampata, ed e'
esattamente quello che deve succedere), `run_playtest.gd --runs=100 --seed=7000`
**0 seggi bloccati su 8** a tavolo misto e uniforme.

---

## D-235 — Le Conseguenze mute erano dieci, sono tre: la misura sbagliava unita'

**implemented in 0.1.206** — ISSUES 56 misurata di nuovo, e ridotta a un terzo

ISSUES 56 chiedeva, per ognuna delle dieci Conseguenze che non escono mai, *se
la proposizione che la elenca sia mai stata scelta, e se no perche' — non
idonea, mai proposta, o sempre perdente*. La sonda
`godot/cli/run_consequence_probe.gd` risponde mettendo un **testimone** in mezzo
al Consiglio: inoltra ogni domanda a chi decide davvero e scrive cosa gli e'
stato offerto e cosa ha scelto. Non decide niente, e la stessa partita con e
senza testimone finisce uguale.

**Due errori di misura, tutti e due miei, tutti e due nella direzione che fa
sembrare il gioco piu' rotto di quanto sia.**

*Il primo: contavo in Consigli quello che non passa dai Consigli.* Quattro delle
dieci non le elenca nessuna proposta — arrivano da una **carta Echo**, e una
Conseguenza scattata da una carta non compare in `confluence_results`. Le
chiamavo morte guardando nel posto sbagliato. Adesso il testimone ascolta anche
`act_echo_drawn`, e due delle quattro escono.

*Il secondo, piu' grosso: misuravo anni scollegati, e certo contenuto vive nella
saga.* Tre proposte chiedono una **leggenda** (`legend:order_restored`,
`legend:debt_called`), e una leggenda nasce solo quando fra due anni giocati
passano abbastanza decenni. Cento anni giocati **uno per volta** non ne
producono nessuna: quelle proposte erano morte **per costruzione della sonda**,
non per un difetto del gioco. Con `--saga=N` la sonda gioca N Chronicle di fila,
e il salto vero (20-200 anni) le accende: `P_ANY_AS_STORY` esce 23 volte su 20
saghe, e `CNS_LEGEND_RETOLD` scatta.

**Il numero, misurato bene:**

| | Conseguenze mai uscite |
|---|---|
| 200 anni **scollegati** (100 semi × 2 linee) | **7 su 52** |
| 200 anni **in saga** (20 saghe da 10 Chronicle) | **3 su 52** |

E le tre che restano hanno tre cause diverse, ognuna con un rimedio diverso:

| Conseguenza | perche' non esce |
|---|---|
| `CNS_DRAGON_SLAIN` | la sua domanda e' arrivata al tavolo **19 volte** e la proposta e' stata esclusa tutte e 19. La porta e' `function:REVELATION`, e in tutto il mazzo **una sola carta** la scrive: perche' il drago muoia serve che quella carta sia calata nello stesso anno, prima che si apra il Consiglio del Risveglio. In 200 anni non e' mai capitato. |
| `CNS_HARVEST_RETURNS` | la sua carta e' stata **pescata 173 volte e calata zero**. Toglie la fame e raffredda la Carestia: fa bene **al mondo**, e a chi la cala non fa niente. |
| `CNS_OATH_BROKEN` | pescata **183 volte, calata zero**. Lascia una cicatrice, mette inquietudine e chiude il proprio rapporto a HOSTILE: chi la gioca paga tre volte e non incassa mai. |

**Le prime due categorie della voce sono vuote.** «Mai scelta» e «sempre
perdente» non esistono piu' in saga: ogni proposta che arriva sul tavolo viene
presa prima o poi, e quando e' presa prima o poi passa. Restano **la porta che
non si allinea mai** e **la carta che nessuno ha ragione di giocare** — e la
seconda e' una categoria che la voce non aveva previsto, perche' non guardava le
carte.

**Quello che non ho deciso.** Dare a qualcuno una ragione per calare «Il
Raccolto Torna» e «La Parola Data», o rendere piu' probabile che la Rivelazione
e il Risveglio si incontrino, e' contenuto nuovo: e' una scelta d'autore, e sta
scritta in ISSUES 56 con i numeri accanto invece che con un'ipotesi.

**Misurato:** suite 457 prove / 8.532 asserzioni verdi, cancelli degli strumenti
verdi. Nessun dato e nessuna regola cambiati: questa e' una misura, e le misure
non spostano il gioco.

---

## D-234 — Quattro dei dieci segni muti non lo erano mai stati, e una clausola era impossibile

**implemented in 0.1.205** — chiude ISSUES 61

ISSUES 61 chiedeva una misura prima di decidere: *«per ognuno dei dieci, quante
volte esce in 100 anni. Un segno muto che compare due volte in un secolo e' un
problema minore di uno che compare duecento.»* La sonda
`godot/cli/run_mute_signs.gd` la fa, e la prima risposta e' arrivata prima
ancora dei numeri.

**La sonda cercava un nome che sul mondo non esiste.** `settlement:$proponent`
e' la forma **scritta**; il compilatore delle Conseguenze sostituisce anche il
payload, quindi sul mondo finisce `settlement:ENT_NAHR`. La prima lettura diceva
**0 volte in 100 anni**, e zero e' la risposta piu' pericolosa che una sonda
possa dare: dice «non succede mai» quando la verita' e' «non l'hai cercato». Un
buco vale come prefisso, e il numero vero e' **50 volte, in un anno su due**.

**E poi il registro stesso aveva un buco.** [D-225](#d-225) contava i segni nei
dati e non guardava **tre penne che leggono**:

| dove | cosa decide |
|---|---|
| `focus_region_tags` di una Tensione | **di quale Regione parla il Consiglio** |
| `entry_tag` / `entry_forbidden_tag` di una vita | **chi siede l'anno prossimo** |
| `if_tag` / `if_not_tag` di una catena delle ere | se la catena avanza |

Sono i morsi piu' forti che questo gioco abbia — il secondo cambia il giocatore,
non un modificatore — e il registro li chiamava silenzio. **Quattro dei dieci
muti non lo erano mai stati:**

- `condition:contested` (132 scritture, 63% degli anni) tira il Consiglio sulla
  Successione e sulla Carta su di se';
- `heir_named` (98, 65%) e' la porta di **Aldric Restaurato**: nomini un erede e
  l'anno prossimo al tavolo siede un altro re;
- `condition:lean` (12, 9%) porta il Consiglio dell'Acqua sulla Regione magra;
- `condition:requisitioned` (7, 7%) fa lo stesso con la Carestia.

**I sei che restano sono davvero muti**, e adesso ognuno porta accanto quante
volte esce in 100 anni: `settlement:<casa>` 50, `water_rights` 18,
`succession_settled` 14, `account_settled` 4, `burden_shared` 2, `dragon_slain`
**mai** — la Conseguenza del Drago non e' mai stata scelta, ed e' ISSUES 56 che
parla, non questa. Nessuno dei sei viene tolto: sono fatti che il libro della
Cronaca registra, e la riga che diceva il falso era una sola — la nota di
`CNS_NAHR_SETTLEMENT` sosteneva che *«le regole lo leggono»*. Adesso dice quello
che e': **chi ci vive, scritto sulla mappa**; la regola e' la pietra che la
Conseguenza alza accanto, e quella si legge davvero.

**Il difetto specchio, trovato dalle penne nuove.** Guardare dove il gioco legge
i segni ha fatto comparire quattro segni **che nessuno scrive**. Tre erano falsi
allarmi e il registro ha imparato a riconoscerli — `twice_uprooted` lo scrive il
codice alla seconda cacciata, e `scar:emptied@REG_EREDAN` e' la forma
qualificata di [D-131](#d-131), che chiede lo stesso segno su una Regione sola.

Il quarto era vero: **`scar:burned`**. La Tensione della Successione preferiva
una Regione bruciata, e **nessuna Regione poteva bruciare**: nessun Effetto,
nessuna cicatrice, nessuna rovina scrive quel segno. Una preferenza morta in un
elenco ordinato non e' innocua — sposta il bersaglio del Consiglio senza che
nessuno lo sappia. Adesso la Successione preferisce `scar:the_empty_chair`, che
«La Sedia Rivendicata» scrive davvero.

**Zero clausole impossibili, e un cancello che le tiene a zero.** Il conto era 0
prima e 0 dopo per ragioni diverse: prima perche' il registro non guardava,
adesso perche' non ce ne sono. `--check` va rosso su una clausola impossibile
come gia' faceva su un muto non dichiarato, con `CHIESTI_NOTI` come via d'uscita
dichiarata. Provato al contrario: rimettendo `scar:burned` il cancello lo nomina.

**Misurato:** suite 457 prove / 8.531 asserzioni verdi, i cancelli degli
strumenti verdi, i piani di simulazione verdi, export e catalogo allineati,
`run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8** a tavolo
misto e uniforme.

**Quello che resta d'autore:** far mordere `water_rights` o `succession_settled`
— 18 e 14 volte in 100 anni — e' contenuto nuovo, non una correzione. Sono
dichiarati; se il committente li vuole in una regola, il posto c'e'.

---

## D-233 — La proposta dice cosa lascia al mondo, e si legge come una carta

**implemented in 0.1.204** — quarto passo di ISSUES 63, meta' schermo di ISSUES 62

**La decisione centrale del gioco si prendeva al buio.** Chi propone sceglie fra
tre o quattro frasi d'autore, e sono scritte bene: si somigliano. Cosa lasciano
sul mondo — una torre che si alza, una Regione che cambia padrone, una cicatrice
che resta — stava in `success_consequences`, cioe' in un file di dati che chi
gioca non apre. Lo stesso valeva per le clausole: si qualificava una proposta
senza sapere cosa si stava scrivendo.

Da [D-232](#d-232) quel materiale esiste in italiano. Mancava di **arrivare a
chi sta scegliendo**, ed e' un tratto solo: `SeatDecider.choose_proposition`
chiede la riga a `CouncilText` invece di stampare la frase e basta.

**Due letture, una sorgente.** La scheda stampata e la riga sullo schermo
parlano della stessa proposta e non possono dire due cose diverse, perche'
escono dalla stessa funzione. Cambia solo **la voce**: fuori dal tavolo un buco
si spiega (*«la Regione di cui si discute»*), al tavolo lo riempie la partita
con il nome vero. `CouncilText._voice()` e' quel passaggio, e le funzioni che lo
prendono continuano a spiegare se nessuno gliela passa — il catalogo non ha
dovuto cambiare una riga, e il cancello di deriva lo conferma.

**Una scelta si disegna come una carta**, non come un bottone con dentro una
frase: la prima riga e' quello che si dice, sotto in grigio piu' piccolo quello
che resta. E' la gerarchia di una carta di cartone — il titolo da lontano, la
lettera piccola quando la prendi in mano. Sotto resta un `Button`, che sa gia'
cosa vuol dire avere il fuoco della tastiera ed essere premuto con Invio; le
etichette sopra non intercettano il mouse, quindi il clic ci arriva sempre.

**Il silenzio non e' una terza possibilita'.** Se una proposta non lascia niente
lo dice (*«Non lascia segni sul mondo»*), perche' una riga vuota si legge come
«non lo so». Misurato adesso: **43 proposte su 43 lasciano qualcosa**, e la
prova va rossa se un quarto di loro smette di lasciarlo.

**Tre prove, e coprono i tre tratti** — perche' due tratti su tre coperti sono
lo stesso buco di [D-224](#d-224):

- ogni proposta della scatola arriva con la sua seconda riga, senza buchi e
  senza id (guarda la funzione che scrive la riga);
- la seconda riga e' disegnata **piu' piccola** e non ruba il clic (guarda il
  pezzo di schermo che la disegna);
- e chi siede viene interrogato con quelle righe (guarda il filo in mezzo, con
  un io con le risposte in fila).

Provate al contrario: togliendo la seconda riga da `_proposition_label` la prima
e la terza diventano rosse su `P_REQUISITION`.

**Misurato:** suite 457 prove / 8.530 asserzioni verdi (era 454 / 8.299), i
cancelli degli strumenti verdi, i piani di simulazione verdi, l'export
deterministico col brief allineato, il catalogo dei Consigli allineato,
`run_playtest.gd --runs=100 --seed=7000` **0 seggi bloccati su 8** a tavolo
misto e uniforme.

**Quello che questo non fa**, e resta scritto in ISSUES 62: il Consiglio si
gioca meglio **sullo schermo**, non ancora sul cartone. La forma fisica —
scheda per Tensione, libretto, o app dichiarata arbitro — resta la decisione
d'autore, e il catalogo e' li' che aspetta.

---

## D-232 — Il Consiglio esce dal database: le proposte in italiano, e un cancello che le tiene aggiornate

**implemented in 0.1.203** — il pezzo che serve a tutte e tre le forme di ISSUES 62

ISSUES 62 chiede una scelta d'autore — scheda per Tensione, libretto dei
Consigli, o app dichiarata arbitro — e quella scelta non l'ho presa io. Ma tutte
e tre chiedono **la stessa cosa a monte**, e quella si poteva fare subito: il
materiale del Consiglio **tirato fuori dal database e scritto in italiano**.

Prima di questa decisione le 10 domande, le 43 proposte, le 19 clausole e le 52
Conseguenze esistevano solo come JSON. Chi voleva leggerle apriva Godot; zero
fogli di stampa su 39 ne portavano una; e sullo schermo la proposta si legge una
riga alla volta **mentre il Consiglio è già aperto** — cioè quando è tardi per
decidere se ti conviene.

**I buchi si spiegano, non si riempiono.** Le frasi d'autore hanno dentro
`$proponent`, `$rival`, `$region_focus`: al tavolo li riempie la partita. Una
scheda però si legge **prima** di giocare, quando non c'è ancora una Regione a
cui riferirsi. `council_text.gd` non li sostituisce con un valore: li traduce
nel ruolo che avranno («la Regione di cui si discute», «il rivale»). Sono 13
legami, e ognuno è spiegato dove è scritto.

**Il ricalco più lungo prima.** `speak()` sostituisce le chiavi in ordine di
lunghezza decrescente, perché `$region` è un prefisso di `$region_focus` e un
ordine qualunque avrebbe prodotto «la Regione\_focus».

**Una Conseguenza dice cosa lascia al mondo**, e lo dice con le parole che
[D-228](#d-228) aveva già scritto per le carte: `consequence_note()` delega ad
`AssetText.effect_note()` invece di aprire una seconda traduzione che domani
divergerebbe dalla prima. Per farlo `AssetText.COSTS` ha dovuto imparare i
cinque tipi di Effetto che **solo** le Conseguenze usano — `SET_ENTITY_TAG`,
`SET_CONTROL`, `SET_STRUCTURE_GRADE`, `SET_ENTITY_ACTIVE`, `CLOSE_PASSAGE`.
E la nota esce comunque dentro `speak()`, perché una variabile può stare
**dentro un tag** (`settlement:$proponent`) e non solo dentro una frase.

**Quello che le prove sorvegliano** non è il testo: è che il testo **non torni a
parlare al programmatore**. Quattro prove: nessuna frase porta ancora un `$`;
nessuna Conseguenza si racconta con un tipo di Effetto; nessuna etichetta parla
al programmatore (`(D-` o `ISSUES`); e una proposta dice cosa lascia dietro.

La terza ha morso subito, ed è il motivo per cui vale: una condizione nel
database diceva *«Si caccia solo cio' che una Rivelazione ha mostrato: la carta
di Propp e' la porta (D-127)»*. È una nota di lavorazione stampata su un
componente. Adesso dice quello che un giocatore deve sapere, e basta.

**Generato e committato**, come `BRIEF_ARTE.md` e `REGISTRO_SEGNI.md`:
[CATALOGO_CONSIGLI.md](CATALOGO_CONSIGLI.md) — 10 Consigli, 43 proposte, 19
clausole — si rifà con `tools/run_council_catalogue.sh` e la CI lo confronta.
Un documento generato che nessuno ricontrolla è peggio di nessun documento:
invecchia **dicendo il falso con l'aria di essere aggiornato**.

**Misurato:** suite 454 prove / 8.299 asserzioni verdi (era 450 / 8.064), i sei
cancelli degli strumenti verdi, i piani di simulazione verdi, l'export
deterministico e il brief allineato, `run_playtest.gd --runs=100 --seed=7000`
**0 seggi bloccati su 8** a tavolo misto e uniforme.

**Quello che resta d'autore**, e resta scritto in ISSUES 62: che forma prenda
questo materiale — scheda, libretto o app-arbitro. Il catalogo non decide al
posto del committente; gli toglie di mezzo la parte che non era una decisione.

---

## D-231 — I posti che non sono la mappa: una domanda e una casa diventano bersagli

**implemented in 0.1.202** — chiude il terzo passo di ISSUES 63

[D-230](#d-230) aveva dato al trascinamento un solo posto dove atterrare: le
Regioni. Restava vero che **MUOVERE era l'unico verbo giocabile con la mano** —
INFLUENZARE parla a una domanda, TRAMARE a una domanda, FORGIARE a una casa, e
nessuna delle tre aveva un posto sullo schermo dove posarci una carta.

### Il pezzo mancante era di nuovo a monte

Come in D-230: **solo MUOVERE dichiarava di cosa parlava.** Le altre tre
uscivano dal decisore senza `subject`, quindi lo schermo non aveva modo di
sapere che quella scelta riguardava *quella* domanda o *quella* casa. Adesso lo
dicono tutte e quattro.

### `DropSlot`: un posto del tavolo

Un `Control` che si mette intorno a una riga — della traccia delle domande, della
colonna dei rapporti — e da quel momento quella riga **e' un bersaglio**. Non
decide niente, come la mappa: accetta una carta esattamente quando quella carta
porta una scelta **per quel soggetto**, e le scelte le hanno gia' approvate le
regole ([D-039](#d-039)).

### La caduta restringe, non sceglie

Su una domanda una carta puo' sapere fare **due cose opposte**: alzarla e
abbassarla. Su una casa: avvicinare e rompere. Il posto non decide per chi
gioca — restituisce **tutte** le scelte che ha, e la colonna si riduce a quelle.

Al tavolo e' esattamente cosi': posi la carta sulla domanda, e *poi* dici se la
alzi o la abbassi. Quando invece la carta li' sa fare una cosa sola, posarla
**e' gia' la mossa** — che e' il caso di MUOVERE, e per questo D-230 rispondeva
subito.

Restano bottoni le scelte che non parlano di niente di visibile — TRAMARE senza
un bersaglio in vista, PASSA — ed e' giusto: non c'e' un posto dove posarle.

### La prova che tiene insieme le due meta'

Le tre prove sul posto sono ovvie. La quarta e' quella che conta:

> **ogni soggetto di cui una carta puo' parlare ha il suo posto sullo schermo.**

Il decisore dice di cosa parla una scelta; il pannello apre un posto per ogni
domanda e per ogni casa. Se domani nasce un verbo che parla a una domanda e
nessuno apre il posto, la carta torna a essere un bottone **in silenzio** — ed e'
il modo esatto in cui questa mossa si disferebbe senza che nessuno se ne accorga.
E' la stessa forma di guardia di [D-224](#d-224) e [D-229](#d-229): non «il
codice funziona», ma «il contenuto e' raggiungibile».

### Una lambda che catturava per valore

`answered = indices` dentro una lambda non esce dalla lambda: GDScript cattura
per valore, e la prima stesura della prova leggeva sempre una lista vuota. Si
muta l'array, non lo si sostituisce. La prova era **rossa per la ragione
sbagliata**, che e' meglio di verde per la ragione sbagliata ma costa lo stesso
un giro.

### Costo

Nessuna regola: tre `subject` che prima non c'erano, un `Control` nuovo, quattro
prove. Suite **450 test e 8.064 asserzioni**.

### Cosa non risolve

Il quarto passo: **il Consiglio giocabile** (ISSUES 62). Li' non e' questione di
bersagli — le proposte non esistono come componente, ne' sullo schermo ne' in
stampa.

---

## D-230 — Si prende la carta e la si lascia cadere: il trascinamento come seconda voce, non come seconda regola

**implemented in 0.1.201** — terzo passo di ISSUES 63

Il committente: *«la GUI deve prevedere movimenti drag & drop, non pulsanti che
dicono cosa fare. Si seleziona una carta, si decide come usarla e si deve poter
generare il suo effetto (movimento muovo una presenza, costruisco metto una torre
sulla mappa, la fame appare su una zona ecc...)»*.

In `godot/ui/` non c'era un solo `_get_drag_data`. Le azioni erano
`Button.new()` costruiti da una lista di stringhe, e si rispondeva con un indice.

### Il principio, che e' quello di sempre

**Il trascinamento non decide niente di nuovo.** La mappa accetta un pezzo
esattamente sulle Regioni che `highlighted` dichiara raggiungibili — cioe' le
scelte che le regole hanno gia' approvato ([D-039](#d-039)) — e la carta puo'
cadere solo dove *quella carta* ha una mossa. E' un'altra **voce** per dire la
stessa cosa, non un'altra regola: il bottone resta accanto, e le due strade
finiscono nella stessa `picked.emit(index)`.

Detto altrimenti: se domani il trascinamento sparisse, non si perderebbe una
mossa. Se decidesse qualcosa da solo, sarebbe un secondo motore.

### Il pezzo che mancava, e stava a monte

`_through_the_hand` **buttava via il bersaglio**. Una MUOVERE nasce con
`subject: {"region": "REG_X"}`, ma quando veniva avvolta nella carta che la porta
il nuovo record non lo ricopiava: usciva una scelta senza posto, quindi lo
schermo non poteva offrirla sulla mappa e restava un bottone. Adesso il bersaglio
viaggia, **con dentro la carta**: `{"region": ..., "asset": ...}`.

E' il difetto piu' istruttivo dei tre: il drag & drop non mancava per pigrizia
della GUI, mancava perche' **l'informazione non arrivava fin li'**.

### Le tre decisioni

1. **Cosa viaggia col pezzo.** Una carta senza scelte non si prende — l'altra
   faccia della Regione senza cerchio d'oro. Con le scelte, il carico porta
   quale carta e' e dove puo' cadere.
2. **Dove puo' cadere.** Due filtri, e servono tutti e due: la Regione fra le
   raggiungibili (lo mette lo schermo) e una mossa *di quella carta* per quella
   Regione (la mette la carta). Una Regione raggiungibile con un'altra carta non
   accetta questa.
3. **Cosa succede quando cade.** La mappa risponde con l'indice della scelta,
   preso dalle offerte della carta e non indovinato. Una caduta fuori bersaglio
   non risponde niente: meglio zitti che una mossa che nessuno ha chiesto.

E l'anello d'oro si accende **sotto il pezzo che sta arrivando**, non solo sotto
il cursore: chi trascina deve vedere dove sta per lasciare prima di lasciare,
come la mano che esita sopra il tavolo.

### Provato senza un mouse

Il trascinamento non si prova col mouse in una suite headless, ma **le tre
decisioni si', e sono quelle che possono sbagliare**. Il resto e' Godot che
sposta pixel. Sei prove: la carta vuota non si prende, il carico porta cosa sa
fare, la mappa accetta solo dove e' legale, la carta non cade dove non ha mosse,
la caduta risponde con la scelta giusta, e quello che non e' una carta viene
ignorato senza rompere niente.

### Un errore preso dal cancello che avevo costruito prima

`set_drag_preview` fuori da un albero scrive un errore e va avanti: la suite
sarebbe rimasta **verde** e la CI sarebbe andata rossa sul grep di
[D-224](#d-224). L'anteprima e' presentazione, il carico e' decisione — adesso il
carico si costruisce comunque e il fantasma solo quando c'e' dove appenderlo.

### Costo

Nessuna regola: un campo che smette di perdersi, due `Control` che imparano a
dare e a ricevere, sei prove. Suite **446 test e 8.043 asserzioni**.

### Cosa non risolve

**Solo MUOVERE ha un bersaglio sulla mappa.** INFLUENZARE parla a una domanda,
FORGIARE a una casa, TRAMARE a niente di visibile: quelle carte restano bottoni
finche' la traccia delle domande e i seggi non diventano bersagli anche loro. E
il Consiglio (ISSUES 62) e' ancora tutto da giocare.

---

## D-229 — I pezzi sulla mappa: una forma si riconosce, una parola si legge

**implemented in 0.1.200** — secondo passo di ISSUES 63

Il committente: *«non ci sono pedine che rappresentano edifici, condizioni,
cicatrici e tutto quello che dovrebbe apparire in una copia fisica del gioco»*.

Era vero alla lettera. `_draw_marks` scriveva i segni come **una fila di parole
in grigio** sotto il nome della Regione, ognuna preceduta dal glifo del proprio
*livello* — e i livelli sono quattro. Un granaio, una torre di veglia e una
biblioteca portavano **lo stesso identico segno**, con tre parole diverse
accanto. Per sapere cosa c'era su una Regione bisognava leggere; su un tavolo un
pezzo si riconosce dalla forma, da lontano, senza leggere niente.

### Cinque famiglie, cinque forme

Le pietre hanno gia' una famiglia nei dati, e sono cinque: **PRESIDIO,
INSEDIAMENTO, OPERA, STUDIO, LUOGO**. Adesso ognuna ha il suo glifo — una torre
coi merli, tre tetti in fila, un arco su due piedi, un libro aperto, un albero —
e la mappa passa dalla famiglia alla forma **leggendo i dati**, senza una tabella
da tenere allineata a mano: se domani nasce una famiglia, il pezzo arriva da
solo, e se nasce senza glifo una prova lo dice.

I sette guardiani dei glifi valgono anche per questi: stanno nel quadrato, non
sono due volte la stessa forma, non si sovrappongono, reggono in monocromatico,
e finiscono sul foglio di prova.

### Il grado e il padrone si leggono dal mondo, non dal tag

**Una cosa che ho sbagliato e la prova ha preso.** La prima stesura ricavava il
grado dal tag, e non si puo': un tag di pietra copre piu' gradi —
`structure:granary` e' **sia il Granaio sia il Grande Granaio**. Grado e padrone
stanno nel record del mondo, `{structure_type, grade, owner}`, ed e' l'unica
verita' su cosa c'e' e di chi e'.

Quindi la mappa disegna le pietre da `region.structures` e non dai tag:

- la **forma** e' la famiglia;
- il **grado** sono i punti sotto il pezzo — un punto una torre di veglia, tre
  una reggia, e si contano con gli occhi come i piani di una cosa che cresce;
- il **padrone** e' il colore, lo stesso della sua pedina. Chi tiene una reggia
  la tiene davvero, e da lontano si vede di chi e'.

Condizioni e cicatrici restano dai tag, perche' non sono oggetti: sono quello che
*succede* a una Regione e quello che le e' successo e non viene piu' via.

### E la parola solo sotto il mouse

Al tavolo una carta si legge quando la prendi in mano, non mentre guardi la
plancia. La Regione sotto il cursore nomina i suoi pezzi; le altre li mostrano e
basta.

### Tre nomi che uscivano in inglese

Cercando i nomi dei pezzi e' venuto fuori che `SignLabels` non copriva i gradi
delle pietre: sulla mappa si leggeva **«palace»**, **«archive»**, **«forest»**, e
per `settlement:` faceva di peggio — cercava una *casa* con quel nome e stampava
«insediamento: city».

Il nome giusto era gia' nei dati (`grades[].name`: «Reggia», «Archivio»,
«Foresta»), quindi si legge da li' come ripiego dopo le parole scritte a mano —
**dopo** e non prima, perche' un tag copre piu' gradi e la parola scritta a mano
e' quella giusta per il tag.

### Le prove

- **ogni segno che puo' finire su una Regione ha un pezzo**: un segno senza pezzo
  non e' brutto, e' **invisibile** — `_draw_marks` lo salta e chi guarda la
  plancia non sa che c'e';
- **ogni famiglia di pietra ha un glifo**, e ogni grado si legge col nome che i
  dati gli danno;
- **nessun segno di Regione si legge col suo suffisso inglese.**

E la prima stesura della prima prova raccoglieva i segni **solo dagli Effetti**,
mancando la penna che li scrive davvero — i gradi delle pietre — e contava zero
segni passando lo stesso. Adesso conta ventitre'.

### Costo

Nessuna regola: cinque glifi, un disegno e tre prove. Suite **440 test e 8.027
asserzioni**. La plancia d'apertura di CHR_01 mostra tre torri di veglia coi
colori di Aldric, Vaerax e Ilve, e otto luoghi naturali in verde — dove prima
c'era una fila di parole grigie.

### Cosa non risolve

Restano **il drag & drop** — in `godot/ui/` non c'e' ancora un solo
`_get_drag_data` — e **il Consiglio giocabile** (ISSUES 62).

---

## D-228 — Una carta dice cosa fa: il verbo, e i segni con la loro parola

**implemented in 0.1.199** — primo passo di ISSUES 63, e mezza ISSUES 62

Il committente ha guardato l'app e ha detto la cosa piu' dura e piu' giusta di
tutta la lavorazione: *«cosi' com'e' fatto e' ingiocabile, lo e' sempre stato»*.
Fra le ragioni ne ha nominata una che si misura subito — **carte che spiegano
esattamente cosa fanno, e non tag o testi tecnici** — e misurandola sono venuti
fuori due difetti diversi.

### Primo: la carta non diceva il verbo

La scheda portava famiglia, forza, modificatore al Consiglio, che fine fa la
carta e cosa costa impegnarla. **Mai cosa succede se la cali.** Il verbo e' il
dato (`card_action.kind`), c'era, e non arrivava a nessuna faccia: ne' sullo
schermo ne' sul cartone stampato.

E' la prima domanda di chi ha una carta in mano, non l'ultima. Chi sceglieva
sceglieva alla cieca su meta' della carta.

### Secondo: 28 effetti su 49 parlavano in tecnico

`AssetText.COSTS` traduceva **quattro** tipi di Effetto su undici; gli altri
stampavano il proprio tipo in minuscolo. Sull'«Assedio» un giocatore leggeva
davvero:

> costa: la domanda in gioco sale, **raze_structure**

Un tipo in minuscolo *sembra* una regola. E' il nome interno di un Effetto,
finito su una carta.

### La mossa

- **`ACTIONS`**: una frase per verbo, e il verbo va **in cima** alla scheda e in
  cima alle note della carta stampata.
- **`COSTS` completo**, piu' **`SIGN_COSTS`** per i quattro Effetti che posano o
  tolgono un segno: quelli non si dicono per tipo ma **col nome del segno**, che
  lo sa gia' `SignLabels` — l'unico posto dove un tag diventa italiano, lo stesso
  dizionario della mappa e del segnalino di cartone.
- **`SignLabels` guadagna i fatti del mondo**: trenta, che prima non aveva
  nessuno. Erano il buco per cui «Registro» e «Credito» dicevano «un segno cade
  sul mondo» invece di «il mondo registra: i conti sono pubblici». E le
  **leggende** (D-225) si dicono col fatto dentro: «si racconta che il debito e'
  stato chiamato».
- **`effect_note` dichiara quello che non sa dire** — «un effetto senza parole
  (TIPO)» — invece di travestirlo da regola. Un effetto nuovo si vede subito.

### Prima e dopo, sulla stessa carta

> **Assedio** — force, forza 2
> ~~+2 se ti opponi · si scarta se la impegni · costa: la domanda in gioco sale, raze_structure~~
>
> **Assedio** — force, forza 2
> **RIVENDICARE — ti prendi il diritto di aprire il Consiglio**
> +2 se ti opponi · si scarta se la impegni · costa: la domanda in gioco sale,
> **viene giu' una costruzione dove si discute**

### E tre prove che tengono la prosa attaccata al dato

Come per la pagina d'aiuto (D-224), il rimedio non e' rileggere: e' misurare.

1. **ogni carta nomina il verbo che porta**, e la scheda lo scrive;
2. **nessuna carta parla in tipi**: nessuna frase comincia con «un effetto senza
   parole» e nessuna contiene un trattino basso, che e' la firma di un nome
   interno;
3. **ogni segno su una carta ha la sua parola**: il ripiego «un segno cade sul
   mondo» esiste per non mentire, non per essere usato.

### Una prova teneva fermo il difetto

`test_effect_narrator` chiedeva che nella narrazione comparisse letteralmente
`nahr_settled`: pretendeva il **nome interno**, cioe' metteva a verbale la cosa
sbagliata. Adesso chiede la parola — «i Nahr si sono fermati» — e vieta l'id.

### Costo

Nessuna regola: testo, un dizionario e tre prove. Suite **437 test e 7.720
asserzioni**, export a 0, `BRIEF_ARTE.md` allineato — e le quarantotto carte
stampate portano il verbo, che prima non c'era.

### Cosa non risolve

Tre quarti di quello che il committente ha chiesto restano: **i pezzi sulla
mappa** (strutture, condizioni e cicatrici sono ancora parole in fila sotto il
nome della Regione), **il drag & drop** (in `godot/ui/` non c'e' un solo
`_get_drag_data`) e **il Consiglio giocabile**. Vedi ISSUES 63.

---

## D-227 — Il tetto delle pedine a cinque: la mappa si contende con le pedine, non al Consiglio

**implemented in 0.1.198** — ISSUES 55, la domanda giusta e la risposta

[D-226](#d-226) aveva chiuso la mossa sbagliata con una domanda nuova: se il
padrone di una Regione lo decide **la contesa di presenza** e non il Consiglio,
allora **quanto potrebbe muoversi la mappa?** Con quattro pedine a testa, quattro
case e sei Regioni, il tetto non era mai stato misurato — si era sempre discusso
di quanto la mappa *si muove*, mai di quanto *potrebbe*.

`run_contest_probe` guadagna `--presence=N`: stessi cento semi, stesso tutto,
piu' pedine a testa. L'override va **prima** di `setup()`, perche' le pedine si
posano li' e da [D-223](#d-223) `presence_tokens` e' anche il tetto che l'applier
fa rispettare.

### Il tetto

| pedine | il padrone passa di mano | Regioni contese a fine anno | con un padrone | cadono vacanti |
|---|---|---|---|---|
| **4** (com'era) | 2,39 | 2,46 su 6 | 4,57 | 1,11 |
| **5** | **2,85** | **3,72 su 6** | 5,09 | 0,82 |
| 6 | 2,70 | 4,23 su 6 | 5,23 | 0,79 |

**E il tetto non e' dove lo cercavo.** Due cose, e la seconda vale piu' della
prima:

1. **I passaggi di mano hanno un massimo, e lo toccano a cinque.** 2,39 → 2,85 →
   2,70: a sei pedine *scendono*. Con tutti dentro dappertutto le posizioni si
   irrigidiscono — una maggioranza stretta e' piu' difficile da sfilare quando
   ognuno e' trincerato. Il tetto del ricambio e' **intorno a 2,9**, e a quattro
   pedine eravamo gia' all'84% di quel numero. Da questo lato la mappa **si
   muoveva quasi quanto le regole permettono**, e due cicli di lavoro l'hanno
   trovato per la via lunga.
2. **La contesa, invece, non era vicina a niente.** 2,46 → 3,72 → 4,23: **+51%
   con una sola pedina in piu'**. E' il numero che il committente aveva chiesto
   fin dall'inizio — *«una maggioranza dovrebbe essere una lotta tra entita'»* —
   e non era il ricambio: era **quante Regioni hanno piu' di una casa dentro**.

Erano due domande diverse dietro la stessa parola, «la mappa e' ferma». Una era
gia' quasi al massimo; l'altra era a meta' strada.

### La mossa

`presence_tokens` da 4 a 5 su tutte e quattro le Chronicle. Cinque e non sei
perche' a sei il ricambio **peggiora** e il tavolo si irrigidisce: cinque e' il
punto in cui la contesa sale e il ricambio e' al massimo.

E non e' un'inversione di [D-211](#d-211): D-211 non aveva scelto «quattro»,
aveva scelto «**tre affama la mappa**», col committente che aveva deciso il
risultato — *«non ci puo' essere una regione senza nessuno»*. La stessa linea
continua di un passo, e il numero che gli da' ragione e' proprio quello: le
Regioni che finiscono l'anno senza padrone scendono da **1,11 a 0,82**.

L'apertura non cambia: le pedine posate a inizio anno restano due, e le Regioni
contese *all'apertura* sono 2,41 in tutte e tre le misure. **La quinta pedina e'
riserva pura** — cioe' esattamente l'asse di D-211.

### Il cancello, per intero

| | |
|---|---|
| playtest 100 semi, tavolo uniforme | **0 su 8** |
| playtest 100 semi, tavolo misto | **0 su 8** |
| Consigli l'anno (misto) | 4,68 |
| esiti (misto) | FAIL 227 · 68 · 92 · DECI 81 |
| esiti (uniforme) | FAIL 166 · 59 · 112 · DECI 141 |
| carte al rifornimento, chi ha 4 pedine → 5 | 3,50 → **4,14** |
| suite | 434 test, 7.522 asserzioni |
| piani scriptati · export · brief | tutti a 0 |

I fallimenti sul tavolo uniforme sono **166, identici** a prima della modifica:
l'economia del Consiglio non si muove. Sul misto 227 contro 224, dentro il
rumore.

### Una prova che descriveva il setup invece dell'intenzione

`test_destiny_warning` costruiva la posizione di Vaerax con `limite - 1` pedine
distribuite su **tre** Regioni: col tetto a cinque ne posava quattro invece di
cinque, Vaerax non era piu' al limite, e l'avviso taceva **per la ragione
sbagliata**. Adesso le tre Regioni si ripetono a giro — due pedine sulla stessa
Regione sono legali e contano — cosi' il tetto si riempie senza toccare l'ordine
alfabetico da cui dipende `_pick_source_region`. E' lo stesso genere di difetto
che D-211 aveva gia' incontrato due volte.

### Cosa resta di ISSUES 55

Tre dei quattro criteri scritti nella voce sono soddisfatti: una presenza in piu'
paga (3,50 → 4,14 carte), le Regioni contese sono **piu' di tre su sei** (3,72),
il padrone cambia mano piu' di prima (2,85). Il quarto — «gli obiettivi contesi
sono almeno un terzo del mazzo» — non lo tocca questa mossa: sono **3 su 15**, ed
e' contenuto d'autore.

---

## D-226 — Il peso della terra, riacceso e respinto di nuovo: il Consiglio non e' dove la mappa cambia padrone

**measured in 0.1.197, non implementato** — ISSUES 55, la mossa 0 e il numero che
la rifiuta

[D-154](#d-154) aveva costruito `focus_weight` — al Consiglio, la Regione di cui
si discute da' voce a chi la tiene e a chi ci sta in forze — e l'aveva lasciata
**spenta nei dati**, perche' il playtest passava da 0/8 a 1/8 e il seggio che si
rompeva era sempre Kessa dei Fuochi. D-154 scrisse: *«ISSUES 38 viene prima»*.

ISSUES 38 e' chiusa da 0.1.122, e da [D-198](#d-198) i tre gradini sono diventati
quattro obiettivi di cui tre pescati: la Vittoria di Kessa oggi ha tre clausole,
non una. **Il motivo per cui la leva era spenta aveva smesso di valere
settantadue versioni fa.** Quindi si riaccende e si misura.

### Il vincolo di casa tiene

Accesa nella forma che D-154 aveva misurato migliore — titolo +1, maggioranza +1,
tetto 2, **senza il proponente** — su tutte e quattro le Chronicle:

| | tavolo uniforme | tavolo misto |
|---|---|---|
| seggi bloccati su un solo livello | **0 su 8** | **0 su 8** |

D-154 aveva ragione sulla diagnosi: non era il peso della terra a rompere Kessa,
era la sua porta sola. Chiusa quella, la leva passa il cancello.

### E la misura che conta dice di no

Il punto non era passare il cancello: era **far muovere la mappa**. Misurato con
`run_contest_probe` sugli stessi 100 semi, e col prima preso **sullo stesso
albero** invece che da un verbale vecchio:

| | il padrone passa di mano | Regioni contese a fine anno |
|---|---|---|
| **spenta** (com'e' spedita) | **2,39** volte l'anno | 2,46 su 6 |
| titolo +1, maggioranza +1 | **2,29** | 2,46 |
| solo maggioranza +1 | **2,37** | 2,46 |

**Peggiora, o non cambia niente.** E la prima riga peggiora per una ragione
leggibile, che avevo scritto io stesso come rischio prima di misurare: dare voce
a chi la Regione **la tiene** rende piu' difficile toglierargliela. E' un
referendum sul padrone. La seconda forma toglie il titolo e paga solo la
maggioranza — cioe' chi ci ha piu' pedine, che e' la cosa contesa — e li' il
numero non si muove affatto: 2,37 contro 2,39, dentro il rumore.

### Perche', ed e' la cosa da portarsi dietro

Cercando la ragione si trova `_recount_control`, e spiega tutto in una riga:

> **il padrone di una Regione lo decide la contesa di presenza, round per round,
> non il Consiglio.**

`rightful_holder` riconta il titolo dalle pedine ogni volta che la contesa e'
accesa; `lapse_without_presence` ne e' il caso particolare. I `SET_CONTROL`
scritti a mano nelle Conseguenze sono **quattordici in cinquantadue**, e arrivano
dopo.

Quindi la domanda «perche' la mappa non si muove?» aveva un presupposto
sbagliato, e l'ho portato avanti per due cicli: **non si muove al Consiglio
perche' al Consiglio non si e' mai mossa.** Si muove quando le pedine si
spostano, e MUOVERE e' gia' l'azione piu' giocata del mazzo (38% delle volte che
e' in mano, contro l'8,4% di FORGE).

**La domanda giusta e' un'altra, e non e' ancora stata posta:** con quattro
pedine a testa, quattro case e sei Regioni, e il titolo che segue la maggioranza
stretta, **quante volte al massimo potrebbe passare di mano?** Se il tetto
teorico e' vicino a 2,4, la mappa si sta gia' muovendo quanto le regole
permettono, e la leva da spostare non e' il Consiglio: sono le pedine, le
Regioni, o la regola del titolo.

### Cosa resta

`focus_weight` resta **spenta nei dati e accesa nel motore**, dove D-154 l'aveva
lasciata, con sette test che la reggono e adesso due misure invece di una. Non e'
contenuto morto: e' una leva provata due volte e respinta due volte per ragioni
diverse, e la seconda ragione e' piu' utile della prima.

### Costo

Nessuno: i dati tornano com'erano. Restano tre numeri scritti che prima non
c'erano, e una diagnosi che sposta ISSUES 55 su una domanda diversa.

---

## D-225 — Un segno che nessuno legge non e' una regola

**implemented in 0.1.195** — il registro dei segni, e le sette penne che
scrivono sul mondo

Il committente ha portato uno scambio con un altro modello che conteneva una
frase giusta: *«un segno sulla mappa ha senso solo se cambia cosa puoi fare, se
cambia un Consiglio, se decide quali domande nascono dopo, se conta per un
obiettivo, o se trasforma il setup futuro. Se non fa nessuna di queste cose, e'
colore travestito da regola.»*

Quella frase e' misurabile, quindi e' stata misurata. **71 segni scritti sul
mondo, 10 che nessuno legge.**

### Perche' non si trova a occhio

L'elenco dei muti che accompagnava la frase era **quasi tutto sbagliato**: dei
undici nomi proposti, nove non esistono nei dati e due erano giusti. Non e' una
critica al metodo — e' la prova che questo conto **non si fa a mente**. Il
difetto e' invisibile in due direzioni insieme: un segno muto non rompe niente
(la partita gira lo stesso) e un segno che sembra muto spesso non lo e'.

Costruendo lo strumento sono emerse **sette penne** che scrivono sul mondo, e
solo tre erano quelle ovvie:

| penna | dove |
|---|---|
| gli Effetti di Conseguenze, carte Asset e carte Echo | `effects`, `on_commit_effects`, `effect_hooks` |
| le **cicatrici**, dichiarate a parte | `consequence.scar.tag` |
| le **pietre**, un segno per grado | `structures/*.json` → `grades[].tag` |
| le **catene delle ere** | `chronicle.era_tallies[].chain` |
| l'apertura della Chronicle e delle Regioni | `global_tags`, `regions[].tags` |
| il codice, per `legend:` `evicted:` `function:` `life:` | quattro file |

Le pietre da sole spiegano **undici regole del segno** che una scansione
ingenua dichiarava impossibili: «Il granaio parla», «Sotto la torre di veglia la
forza si trova», «La citta' parla piu' forte al Consiglio». Sono sane, e la
prima stesura del registro le accusava tutte.

### E cinque modi di leggere, uno dei quali arriva un anno dopo

Il piu' sottile: **una leggenda e' il segno di prima, un'era dopo.**
`world_state_factory` trasforma in `legend:<fatto>` ogni fatto globale che
sbiadisce sul salto lungo, e se qualcuno chiede quella leggenda allora il fatto
morde — non quest'anno, nel prossimo. `order_restored` risultava muto in ogni
lettura statica, e non lo e'.

### La regola che lo strumento incarna: leggere non e' agire

Un `begins_with("x:")` nel codice non basta a dire che un segno morde, e il
registro lo dichiara prefisso per prefisso invece di indovinare:

- `discovery:` **morde** — `condition_evaluator` li conta tutti insieme per
  `discovery_count`, che Destini e obiettivi chiedono quattro volte;
- `evicted:` **morde** — `world_state_service` lo controlla per impedire il
  rientro;
- `legend:` **morde** — vedi sopra;
- `condition:` **no** — il prefisso lo guarda solo la traversata delle ere, per
  decidere se il segno sbiadisce. E' *quanto dura*, non *cosa fa*: una singola
  `condition:` morde se una regola, un obiettivo o la pesca la nominano;
- `settlement:` e `life:` **no** — li leggono solo `effect_text` e
  `sign_labels`. **Disegnare non e' mordere**, ed e' la stessa distinzione di
  [D-224](#d-224): un testo che nomina una regola non la rende viva.

Stessa logica per le cicatrici: una cicatrice morde **per il fatto di
esistere** — `scar_count` la conta, e ventidue clausole chiedono quel conto — ma
il suo nome non lo legge nessuno, ed e' voluto. Una cicatrice pesa come
cicatrice, non per come si chiama.

### I dieci muti sono dichiarati, non nascosti

Stanno in `MUTI_NOTI` con la ragione accanto, ed e' la regola di casa: **un
numero peggiorato e scritto vale piu' di un numero nascosto**. `--check` va
rosso in tre casi, e sono tre difetti diversi: un muto nuovo non dichiarato, un
muto dichiarato che ha smesso di esserlo (cosi' l'elenco non marcisce), e il
documento fuori passo coi dati. L'elenco puo' solo accorciarsi.

I nomi sono grossi: `dragon_slain` — «Il Drago Abbattuto» — e il mondo non se ne
accorge. Vedi ISSUES 61 per i tre rimedi possibili, che non sono lo stesso per
tutti e dieci.

### Costo

Nessuna regola cambiata: uno strumento, un documento generato e un passo di CI.
Playtest non ri-misurato perche' non c'e' niente da ri-misurare — nessun dato di
gioco e' stato toccato.

---

## D-224 — La pagina delle regole si misura, come tutto il resto

**implemented in 0.1.192** — la GUI contro le regole nuove, e il punto cieco del
§5ter chiuso con una prova invece che con una rilettura

Il committente ha chiesto una cosa sola: *«La GUI dell'App e' corretta? Dovrebbe
essere allineata con le nuove regole»*. No, non lo era. La pagina d'aiuto diceva
a chi legge **cinque cose false**, e la riga di stato sopra le scelte — quella
che un giocatore legge piu' spesso di ogni altra — ne diceva una sesta.

### Perche' nessuno se n'era accorto

Il cancello gioca solo con `PolicyDecider`, che la pagina d'aiuto non la apre
mai. Cento semi verdi, 0/8 sedie bloccate, tutti gli strumenti a posto — e
intanto il testo raccontava il gioco di due versioni prima. E' il §5ter alla
lettera: **nessuna misura copre quello che una persona legge**.

La causa immediata era una riga sola. La sezione dei Consigli pendeva da
`tension_tokens.table_gate`; [D-214](#d-214) ha tolto quella chiave dai dati
spediti, quindi `gate == 0`, e la pagina e' caduta di colpo nel ramo `else` — il
testo di prima ancora, intatto e sbagliato. Con la sezione sono spariti anche i
mucchi coperti, che ci stavano annidati dentro: **una regola ancora accesa di cui
la pagina aveva smesso di parlare**.

### Le sei bugie

1. *«Salgono da sole ogni round»* — falso da `replaces_drift`, e la pagina **si
   contraddiceva da sola**: tre paragrafi sopra diceva gia' *«non e' il tempo a
   scaldarle: siete voi»*.
2. *«Quando una arriva alla sua soglia si apre un Consiglio»* — il Consiglio si
   tiene alla fine di ogni Atto ([D-214](#d-214)).
3. **«soglia 6», «soglia 5»** stampate accanto a ogni domanda: numeri che non
   aprono piu' niente. Lo stesso errore che [D-195](#d-195) aveva gia' corretto
   una volta, rientrato dalla porta di servizio.
4. **Il tavolo scritto per nome** — «Re Aldric, Popolo Nahr, Lyra, Vaerax» —
   quando [D-213](#d-213) lo fa pescare fra otto case. La pagina leggeva
   `entities` per primo e `entity_pool` come ripiego: **la precedenza al
   contrario** rispetto a `resolve_seats`. Stesso difetto sulle domande.
5. **`per_control` taciuto** ([D-220](#d-220)), insieme a pavimento e soffitto
   del rubinetto: la pagina stampava due dei cinque numeri e chi leggeva sapeva
   la regola sbagliata a meta'.
6. E fuori dalla pagina, in `game_screen.gd`: *«ha raggiunto la soglia: il
   Consiglio si apre»*, falso a ogni round di ogni partita spedita.

### La mossa: prima la misura

La riscrittura da sola sarebbe scaduta di nuovo fra tre commit, quindi la mossa
scelta e' stata **la prova**, e la pagina e' venuta dietro per farla verde.

`test_the_page_says_only_what_the_data_says.gd` disegna la pagina sui dati
**spediti**, per ogni Chronicle nella scatola, e la confronta con una tabella di
clausole. Ogni clausola lega una dichiarazione alle parole che le appartengono, e
la lega **nei due sensi**: se la regola c'e' le sue parole devono esserci, se non
c'e' non possono esserci e devono esserci quelle del gioco di prima.

Il secondo senso non si prova a parole: si prova **togliendo la dichiarazione
dalla Chronicle e ridisegnando**. Cosi' i due lati di ogni clausola sono provati
a ogni esecuzione, e il ramo «la regola non c'e'» — che e' esattamente il posto
dove il difetto si era annidato — non resta mai prosa non misurata.

E' l'idioma del progetto applicato al testo: **una dichiarazione vuota vuol dire
assenza**, quindi la pagina non parla di quello che non e' dichiarato.

Prima esecuzione: **55 asserzioni rosse** su quattro Chronicle.

### Quello che la prova ha trovato da sola

Togliere `presence_tokens` mandava `_lines()` **in errore a meta' pagina** — e la
prova restava verde, perche' in GDScript una chiave mancante non alza niente che
si possa prendere: interrompe la funzione, scrive nel log e restituisce quello
che aveva. La pagina si accorciava e basta. Adesso `_page()` verifica che il
disegno arrivi in fondo, e la chiave si legge con `get`.

Guardando il log di quella esecuzione verde sono usciti **altri due errori**, in
prove che nessuno aveva toccato:

- `test_data_boot` chiedeva `session.world` senza aver aperto un mondo: la
  funzione moriva li' e **la traccia di Drift non era misurata da mesi**.
- `test_print_export` cercava `INC_ALDRIC_02` fra le Entita', dove non c'e'
  ([D-111](#d-111)): la prova si fermava alla prima incarnazione, e **ne' le
  Casate dopo ne' il mazzo Destino venivano piu' guardati**. Il controllo che
  tiene in piedi il segreto del gioco non girava.

Rimesse in funzione, le asserzioni della suite sono passate da **7.414 a 7.470**:
cinquantasei misure che c'erano sulla carta e non nei fatti.

E questo e' il difetto sistemico, non l'aneddoto: **la suite conta i test che fa
partire, non quelli che arrivano in fondo**. Adesso il cancello legge il log e va
rosso su `SCRIPT ERROR`, che e' l'unica cosa che poteva prendere quei tre casi.

### Il resto della GUI

Cercato, non supposto: delle diciassette viste, **solo `help_panel.gd` parla di
regole**; le altre disegnano lo **stato del mondo**, che per costruzione e'
sempre aggiornato. L'unica eccezione era `_context_line()` in `game_screen.gd`,
che contava i passi mancanti a una soglia che non apre piu' niente — riscritta
per dire quello che serve adesso (**quale mucchio arrivera' al tavolo, e fra
quanti round**) e, coi mucchi coperti, per dirlo nella moneta che il giocatore
**ha**: i gettoni caduti, non il peso. Anche quella riga ora e' misurata: prima
di oggi `game_screen.gd` non era toccato da nessuna prova.

### Cosa e' stato aggiunto alla pagina, non solo corretto

Il tetto delle pedine ([D-223](#d-223)) non era scritto da nessuna parte, ed e'
la regola che rende **muoversi** una scelta invece di un accumulo: «quattro e' il
tetto, non una dotazione — la quinta pedina non si posa, la si sposta». E la
riga sul possesso, che e' il senso di [D-220](#d-220): tenere una Regione non e'
lo stesso che starci dentro.

### Costo

Nessuna regola cambiata: sono testo e prove. Playtest **0/8** su tavolo misto e
uniforme, 100 semi dal 7000, come prima e per lo stesso motivo. Piani, export e
`BRIEF_ARTE.md` allineati.

---

## D-223 — Il tetto vale anche per il mondo, e le domande che spostano non escono mai
**implemented in 0.1.191** — ISSUES 55, la mossa che non ha funzionato e il perche'

[D-222](#d-222) aveva lasciato la mappa ferma con una diagnosi precisa: il
cervello *vuole* la mappa ma non ha con cosa prenderla, e **`ADD_PRESENCE`
compare una volta sola in cinquantadue Conseguenze**. La mossa era darne di piu':
un Consiglio che caccia e assegna ma non manda mai nessuno da nessuna parte non
puo' muovere niente.

### Un difetto vero, trovato prima di introdurlo

`_add_presence` **non controllava il tetto delle pedine**. L'azione MUOVERE lo
fa da sempre; l'applier no, quindi una Conseguenza poteva posare la quinta
pedina di una casa che ne ha quattro. Non si era mai visto perche' una sola
Conseguenza metteva presenza — il giorno in cui sono diventate sei, il Consiglio
avrebbe sforato in silenzio una regola che i giocatori rispettano.

Adesso il tetto vale anche per il mondo. L'inverso e' escluso apposta: arriva con
`at` e rimette una pedina gia' contata, e **disfare deve sempre poter disfare**.

Il difetto ha fatto rosse due prove che costruivano uno stato **impossibile** —
quattro pedine di Vaerax in una Regione, quando ne ha quattro in tutto e due
altrove. Adesso `_stand` le richiama da dove stanno, che e' anche quello che una
casa farebbe davvero.

### Poi la mossa, e tre misure che dicono di no

Cinque Conseguenze hanno avuto un `ADD_PRESENCE`, ognuna con la ragione gia'
scritta nel proprio testo — «i carri rimessi in strada» arrivano da qualche
parte, chi prende una capitale ci entra.

| 100 semi, il padrone passa di mano | |
|---|---|
| prima (D-222) | **2,49 volte l'anno** |
| tutte e cinque | 2,39 |
| solo le tre migrazioni | 2,39 |
| migrazioni mandate **dove sta il rivale** | 2,39 |

Tre forme diverse, lo stesso numero, e tutte **peggiori** del punto di partenza.
Le due `CONTROL` peggioravano per una ragione leggibile — mettere il proponente
dove ha appena vinto **consolida** invece di contendere — e sono state tolte. Ma
le migrazioni da sole non spostavano niente lo stesso.

### Il numero che chiude la questione

Le Conseguenze che spostano gente, su **100 anni**:

| | |
|---|---|
| CNS_ASH_ABANDONED | 8 volte |
| CNS_ABANDONED | 7 |
| CNS_SEALED_VALLEY | 4 |
| CNS_VALLEY_CLEARED | 2 |
| **CNS_EXODUS** | **0** |
| **CNS_CAPITAL_TAKEN** | **0** |

**Ventuno attivazioni in cento anni**, su circa **470 Consigli**. Il 4,5%. E due
di quelle carte non escono **mai**.

Non e' che spostare la gente non funziona: e' che **ho messo l'Effetto su carte
che non si giocano**. Qualunque cosa scriva li' dentro e' contenuto che il tavolo
non vede.

### Cosa resta, e cosa si dichiara

- **Le tre migrazioni tengono l'`ADD_PRESENCE`**, non per bilanciamento ma
  perche' e' **vero**: «qualcosa parte e non torna quell'anno» vuol dire che
  parte *verso*. Costo misurato: 2,49 → 2,39 passaggi di mano, dentro il rumore
  di ventuno attivazioni. Il playtest resta **0/8**.
- **Le due `CONTROL` no.** Chi prende una capitale dovrebbe entrarci, ed e' vero
  anche quello — ma li' l'effetto misurato ha un segno, e il segno e' contro
  quello che la voce cerca.
- **La mossa 4 e' respinta come leva**, e la voce cambia domanda: non «cosa fanno
  le Conseguenze alla mappa» ma **quali Conseguenze escono**. E' [ISSUES 56](ISSUES.md#56-meta-delle-conseguenze-non-esce-mai-e-due-non-escono-affatto).

---

## D-222 — Il cervello insegue quello per cui si vince
**implemented in 0.1.190** — ISSUES 55, la mossa 0

[D-221](#d-221) ha trovato la distanza e questa la chiude. Da
[D-198](#d-198) la partita si vince **contando quattro obiettivi**; il
`PolicyDecider` — il cervello che gioca il cancello — leggeva soltanto le
condizioni del **Destino**, e la parola «objective» non compariva **nemmeno una
volta** in tutto quel file.

> Chi gioca inseguiva una cosa, e il punteggio ne contava un'altra.

### Una funzione sola, e nove posti che la leggono

`_conditions()` e' il punto unico da cui il decider ricava cosa vuole: nove
chiamanti, che sono la scelta dell'azione, delle Regioni, delle carte da
acquisire, delle Tensioni da spingere e del voto al Consiglio. Aggiungere li' le
clausole degli obiettivi in mano li fa inseguire **ovunque**, senza scrivere
un'euristica nuova per ognuno.

Due dettagli che non sono dettagli:

- **il Destino resta.** E' ancora lui a dire il livello, ed e' quello che fa
  somigliare una casa a se stessa: togliere il Destino avrebbe fatto quattro
  ottimizzatori identici con quattro mazzi diversi.
- **un obiettivo gia' preso smette di essere un movente.** E' un punto in
  cassaforte, e continuare a giocarci contro toglierebbe azioni a quelli che
  mancano ancora.

### I numeri, 100 semi — e il confronto e' pulito

Le due misure differiscono **solo** per questa riga: stesso pool di 15
obiettivi, stesso `per_control`, stesso tutto.

| | cervello cieco | **cervello che vede** |
|---|---|---|
| **obiettivi presi in tutto** | 397 | **446** (+12,3%) |
| anni chiusi con **quattro su quattro** | 2 | **7** |
| «Due Terre, una Voce» (conteso) | 32,1% | **39,5%** |
| NONE in tutto, tavolo misto | 93 | **80** |
| VITTORIE, tavolo misto | 147 | **175** |
| TRIONFI, tavolo misto | 4 | **7** |
| Consigli l'anno, misto | 4,55 | **4,66** |
| playtest 100 semi | 0/8 | **0/8** |

**Un cervello che insegue quello per cui si vince, vince di piu'** — ovvio a
dirsi, e non era vero fino a ieri. Il vincolo mai negoziato regge: **0 su 8** a
tavolo misto e uniforme.

### Quello che si dichiara, ed e' la parte che conta

- **La mappa non si e' mossa lo stesso.** Il padrone passa di mano 2,42 → 2,49
  volte l'anno, le Regioni contese restano 2,6 su 6. Era la ragione per cui il
  committente ha chiesto tutto questo, e **non e' risolta**: il cervello adesso
  *vorrebbe* la mappa, ma non ha con cosa prenderla — MUOVERE si gioca 3,79
  volte l'anno e le pedine sono quattro. Il collo di bottiglia e' li', non nella
  testa di chi gioca.
- **«Piu' Pietra di Tutti» non si muove di un punto** (19,8% prima e dopo): il
  cervello non puo' decidere di costruire, puo' solo impegnare la carta giusta
  se ce l'ha ([D-218](#d-218) gliene ha data una).
- **Tutti i numeri sugli obiettivi scritti prima di oggi misuravano un cervello
  cieco.** Restano veri come descrizione di quello che il cancello faceva; non
  dicono quanto valga un obiettivo per chi lo persegue. I due piu' esposti sono
  quelli di [ISSUES 52](ISSUES.md#52-lyra-non-ha-mai-trionfato-in-centoventi-anni),
  e vanno riletti con questo in mente.
- **Il tavolo misto e' cambiato meno di quello uniforme**, perche' i caratteri
  di `TableOfCharacters` pesano le azioni a modo loro e smorzano la spinta. Non
  l'ho toccato: e' un secondo cervello, e un cambio per volta.

---

## D-220 — Tenere una Regione paga, e il tetto non era la leva
**implemented in 0.1.189** — ISSUES 55, prima mossa

Il committente: *«costruire porta vantaggi, avere maggioranza da' vantaggi
[...] spostarsi conviene quindi»*. Il rubinetto della mano contava **le pedine**
e basta: il possesso di una Regione non pagava piu' che starci dentro, quindi
alzare una pietra era un numero nella contesa e niente altro.

### Il preventivo sbagliato, e come si e' visto

Avevo scritto che il collo di bottiglia era il **tetto per Atto** (`cap: 6`, con
quattro pedine che ne varrebbero otto). L'ho alzato a 8 e ho misurato:
**niente**. Le carte pescate a ogni rifornimento restavano 3,3–3,4 per chiunque.

Il tetto vero e' quello sulla **mano** (`hand_cap: 7`): `min(dovuto, hand_cap -
mano)`. Tutti convergono alla stessa mano piena, e la presenza decide soltanto
quanto in fretta. Il cap e' tornato a 6, perche' un cambio che non fa niente non
resta.

### La sonda ha sbagliato la domanda due volte

E ogni volta il numero cambiava **conclusione**, il che e' peggio che sbagliarlo.

1. **Carte in mano a fine anno**: diceva che una presenza in piu' non rende. Ma
   chi ha piu' pedine pesca di piu' *e spende di piu'*, e le due cose si
   annullano nel numero sbagliato.
2. **Carte pescate, raggruppate per le pedine di fine anno**: diceva che
   espandersi rende **meno** (3 pedine → 9,18 carte, 5 pedine → 8,85). Era un
   artefatto: chi finisce con cinque pedine le ha posate tardi, quindi per due
   Atti su tre ha pescato da due.
3. **La coppia giusta** — con quante pedine si e' pescato quanto, ricostruita dal
   registro degli Effetti in ordine, l'unica fonte che sa *quando* (§6.3):

| pedine al rifornimento | carte pescate |
|---|---|
| 3 | **3,44** |
| 4 | **3,30** |
| 5 | **3,12** |

**Piu' pedine hai, meno peschi.** Non piatto: **invertito**.

### Come e' fatto adesso

`hand_refill.per_control`: carte in piu' per Regione **controllata**, e
altrettanto tetto sulla mano. Il tetto che sale e' la meta' che conta — senza,
il possesso non si vedrebbe comunque, perche' chiunque converge alla stessa mano.

| 100 semi | prima | **dopo** |
|---|---|---|
| il padrone passa di mano | 2,32 volte l'anno | **2,42** |
| Regioni contese a fine anno | 2,60 su 6 | **2,66** |
| Regioni con un padrone | 4,65 su 6 | **4,73** |
| carte pescate con 4 pedine | 3,30 | **3,52** |

### Quello che si dichiara, e non e' poco

**L'effetto sulla mappa e' piccolo: 2,32 → 2,42 passaggi di mano.** Il possesso
adesso paga, ma non basta a rendere la mappa contesa, e il motivo l'ha trovato
[D-221](#d-221).

---

## D-221 — Un obiettivo che non si puo' spartire, e il cervello che non lo insegue
**implemented in 0.1.189** — ISSUES 55, e il ritrovamento che cambia il piano

*«Anche gli obiettivi dovrebbero incrociarsi per dare battaglia tra entita'.»*
Contati: su dodici, **uno solo** — «Due Terre, una Voce» — metteva due case
l'una contro l'altra. Due erano globali (stesso esito per tutti) e **nove
contavano roba propria**: quattro seggi potevano soddisfarli tutti e quattro
senza mai toccarsi.

### `leads_in`, e perche' e' un tipo nuovo e non un numero piu' alto

Ogni condizione del vocabolario conta **quanto hai**. Alzare una soglia rende un
obiettivo piu' difficile, non piu' conteso: due case possono comunque prenderlo
tutte e due. `leads_in` chiede di stare davanti a **tutti gli altri** di almeno
`by`, su una delle quattro monete — Regioni tenute, pietre in piedi, pedine sul
tavolo, carte in mano. E' vera per **un seggio alla volta per costruzione**, e a
parita' non conta: per stare davanti bisogna superare, come per togliere una
Regione a chi la tiene ([D-158](#d-158)).

Tre obiettivi nuovi la usano: **La Mano Piu' Lunga** (Regioni), **Piu' Pietra di
Tutti** (strutture), **La Gente piu' Sparsa** (pedine). Il pool passa da 12 a 15,
e i contesi da **1 a 4**.

Si avverano fra lo **0% e il 46,2%** a seconda del seggio: vivi, non gratis e non
morti. Una prova nuova chiede la cosa che la parola «conteso» vuol dire — **al
massimo un seggio alla volta** — e sporca il tavolo prima di chiedere, perche' se
nessuno ha niente «piu' di tutti» e' falso per tutti e la prova non proverebbe.

### E poi il ritrovamento, che e' piu' importante della decisione

Aggiunti gli obiettivi contesi, **la mappa non si e' mossa**: 2,32 → 2,42
passaggi di mano, e quel poco veniva da [D-220](#d-220). Ho cercato il perche' e
l'ho trovato in una riga:

> `grep -c "objective" godot/scripts/seat/policy_decider.gd` → **0**

**Il cervello che gioca il cancello non legge gli obiettivi. Mai.** Legge le
condizioni del **Destino** — le tre strade — e insegue quelle. Ma da
[D-198](#d-198) la vittoria si conta **contando quattro obiettivi**, non salendo
i gradini del Destino.

Quindi: **chi gioca insegue una cosa, e il punteggio ne conta un'altra.**

Non e' una taratura. E' che tutte le misure sugli obiettivi fatte finora — il
libro mastro compreso, quindi [D-217](#d-217) e [ISSUES 52](ISSUES.md#52-lyra-non-ha-mai-trionfato-in-centoventi-anni) — dicono **cosa capita** a un
seggio che non li persegue, non quanto sono difficili da perseguire. Restano
veri come descrizione di quello che il cancello misura oggi; non dicono niente
su quanto valga un obiettivo per una persona che lo vuole.

E spiega perche' le due leve di ISSUES 55 hanno mosso cosi' poco: **il gioco
offre la lotta e nessuno la combatte.**

### Quello che si dichiara

- **Non ho toccato il cervello.** Insegnargli a inseguire gli obiettivi cambia
  ogni numero di ogni verbale che li nomina, ed e' una decisione di scala che
  vuole essere presa apposta e non di sfuggita dentro un'altra. E' scritta in
  ISSUES 55 come la cosa da fare prima delle altre.
- **I tre obiettivi contesi restano**, anche se oggi nessuno li insegue: la prova
  dimostra che sono contesi davvero, e il giorno in cui il cervello li guardera'
  saranno gia' li'. Ma non posso dire che «rendono la partita piu' mossa» —
  posso dire soltanto che **si possono contendere**.

---

## D-219 — Ogni relazione dice perche'
**implemented in 0.1.187** — ISSUES 54, chiusa sul suo criterio

[D-216](#d-216) ha scritto le sedici coppie mancanti otto calde e otto neutrali,
e ha aperto una voce sulla parte debole del proprio lavoro: *«almeno una delle
otto neutrali e' rimasta neutrale per far quadrare la quota, non perche' non ci
fosse niente da dire»*. Il criterio di chiusura era preciso — **ogni coppia
neutrale lo e' per una ragione scritta, non per aritmetica** — e dice cosa
serviva: non un altro numero, un posto dove mettere la ragione.

### Il campo che mancava

`relations[].note`, obbligatoria. Una riga per coppia, e vale soprattutto per le
neutrali: **un neutrale scritto e un neutrale per dimenticanza si comportano
uguale al tavolo** e dicono due cose diverse a chi legge il dato. Con le case
pescate le coppie sono ventotto — abbastanza perche' una si perda.

Sono scritte tutte e ventotto, non solo le sedici nuove: le dodici d'autore
avevano la loro ragione nelle descrizioni delle case, e lasciarle mute avrebbe
fatto sembrare *loro* quelle di comodo.

### Uno scambio solo, e col motivo

- **Lyra ↔ la Gilda del Sale: da neutrale ad ALLEATA.** Era la coppia che
  gridava: tengono tutte e due dei registri, e per ragioni opposte — la Gilda per
  contare, Lyra per capire. *«Si sono lette a vicenda prima di conoscersi, e
  quando si sono conosciute avevano gia' deciso di fidarsi.»*
- **Aldric ↔ la Cenere: da ostile a neutrale.** Era la piu' generica delle otto
  calde — «due case di POTERE sulla stessa terra» e' una categoria, non una
  storia. Adesso il silenzio e' una scelta: *«la corona non e' mai salita sulle
  montagne e la Cenere non e' mai scesa a Eredan. Si ignorano da abbastanza tempo
  perche' ignorarsi sia diventato comodo.»*

### La guardia

`check_relations_are_written_both_ways` adesso chiede anche la nota, e la
confronta fra le due scritture insieme al livello e ai tag: **le due meta' di una
coppia devono dire la stessa cosa anche sul perche'**. Provata togliendone una.

### I numeri, 200 semi

| | D-216 | **dopo** |
|---|---|---|
| coppie calde | 14 su 28 | 14 su 28 |
| tavoli piatti | 0,0% | **0,0%** |
| coppie calde per tavolo | 2,94 su 6 | **2,88 su 6** |
| — alleanze / ostilita' | 1,22 / 1,72 | **1,42 / 1,47** |
| playtest 100 semi | 0/8 | **0/8** |

La temperatura resta quella dei tavoli d'autore, e lo scambio pareggia le due
facce: prima il tavolo pescato era piu' ostile che alleato di quasi mezza coppia,
adesso e' in equilibrio.

### Quello che si dichiara

- **La nota non arriva al tavolo.** E' dato per chi scrive il mondo e per le
  guardie, non testo che una persona legge in partita. Se un giorno la scheda del
  seggio dovra' dire *perche'* due case si guardano storto, la riga e' gia'
  scritta — ma oggi nessuna interfaccia la mostra, e dirlo e' meglio che lasciarlo
  scoprire.

---

## D-217 — L'Archivio, e il consuntivo che guardava un istante troppo tardi
**implemented in 0.1.186** — ISSUES 52, la meta' che si poteva fare

[ISSUES 52](ISSUES.md#52-lyra-non-ha-mai-trionfato-in-centoventi-anni) ha una
causa in una riga di dati: `starting_structures` dava un presidio a sei case su
otto. A Lyra e all'Ordine del Vetro niente, e quelle due mancavano **sempre le
stesse carte** — «Qualcosa che Resta in Piedi» al 6,7% e al 23,1% contro il 100%
delle altre.

### L'Archivio, e perche' ha una famiglia sua

La strada 1 della voce diceva *«non un presidio — non e' una casa di mura — ma
qualcosa che la racconti»*. `STR_ARCHIVE`: Archivio (grado 1) → **La Grande
Biblioteca** (grado 2). Va bene a tutte e due — una studiosa senza patrono e un
Ordine che custodisce quello che fu misurato.

**La famiglia e' nuova, `STUDIO`, e sta da sola apposta.** La prima versione lo
metteva fra le OPERA, ed era lo stesso difetto ribaltato: «L'Opera che Porta il
Nome» sarebbe diventata gratis per Lyra e il Vetro e impossibile per gli altri
sei. Una pietra d'apertura che cade dentro una famiglia gia' richiesta da un
obiettivo non pareggia niente, sposta il regalo.

**E sta nella seconda Regione, non nella prima.** Con l'Archivio alle Miniere,
Lyra ne prendeva anche il **controllo**, che e' una strada del suo Destino: il
rimedio le avrebbe regalato due cose invece di una. L'ha trovato
`test_destiny_evaluator`, andando rosso con TRIUMPH dove aspettava VICTORY.

### Due difetti veri trovati per strada

**Una prova che diceva di svuotare una Regione e ne svuotava meta'.** `_clear()`
in `test_control_contest` toglieva le pedine e lasciava le pietre. Andava bene
per una ragione che nessuno aveva scritto — sulle Miniere non apriva nessuno con
una struttura — e il giorno in cui Lyra ci ha aperto un Archivio otto prove sono
andate rosse contando **uno in piu'**. Avevano ragione: dichiaravano di partire
da una Regione vuota e partivano da una Regione con dentro qualcosa. E' la
lezione di [D-184](#d-184) un'altra volta.

**E un numero falso in una sonda, che stavo per scrivere in questo verbale.**
`run_objective_ledger` chiedeva gli obiettivi con `objectives_of()` **dopo**
`run()`. Ma `objectives_of` ricalcola dal mondo corrente, e subito prima di
tornare `chronicle_end` fa salire una pietra a chi ha ottenuto quello che voleva
([D-159](#d-159)). Quindi la sonda leggeva un tavolo di un istante piu' tardi di
quello che aveva deciso l'anno, e diceva che **«Pietra sopra Pietra» si avvera
nel 27–46% dei casi**. In partita non si avvera mai: 0 su 100, tutte e otto le
case.

Adesso il consuntivo si **congela** dentro `chronicle_end`, accanto ai livelli, e
la sonda lo legge dal report invece di ricalcolarlo. E' §5ter in un'altra forma:
una misura presa un momento dopo non e' la stessa misura.

### I numeri, 100 semi, seme 7000

| anni chiusi con **zero** obiettivi | prima | **dopo** |
|---|---|---|
| **Lyra** | 7 | **6** |
| **Priore Anselmo (il Vetro)** | **18** | **12** |
| anni con due obiettivi, Lyra | 13 | **19** |
| anni con due obiettivi, il Vetro | 9 | **16** |

| «Qualcosa che Resta in Piedi» | prima | **dopo** |
|---|---|---|
| la casa peggiore | **6,7%** | **68,8%** |
| la migliore | 100% | 100% |

**La carta che divideva il tavolo in due non lo divide piu'**: da 6,7–100% a
68,8–100%.

### Quello che si dichiara, e non e' poco

- **«Il Muro che Tiene» e' ancora una spunta**, e resta 0–100%: chiede un
  **presidio**, e l'Archivio non lo e'. Alzarne la soglia a due e' stato provato
  e **misurato come peggiore**: 0–11%, cioe' una carta morta invece che una
  spunta. Il rimedio vero e' [ISSUES 39](ISSUES.md#39-la-terra-che-si-vede-pedine-di-carta-o-strutture-con-una-vita),
  e sta in [D-218](#d-218).
- **«Pietra sopra Pietra» resta 0 su 100**, e adesso si sa perche': le pietre
  salgono di grado a **fine anno**, dopo che gli obiettivi sono stati contati.
  Quella salita serve all'anno dopo, in una saga; nella partita in cui e'
  successa non vale niente.

---

## D-218 — Le pietre hanno una vita: si alzano per scelta, e vengono giu'
**implemented in 0.1.186** — ISSUES 39, strada C

La voce si apriva con un numero: *«74 costruite, zero abbattute [...] in una saga
la mappa **puo' solo riempirsi**»*. Rimisurato con una sonda nuova
(`run_stone_probe`), su 100 partite:

| | prima |
|---|---|
| pietre alzate | 14,53 a partita |
| — **dall'apertura** | **13,02** |
| — dal gioco | 1,51 |
| **abbattute** | **0,00** |
| salite di grado | **0,04** |
| grado 2+ in piedi a fine anno | 0,56 |

**Il 90% delle pietre le posa il setup**, e in cento anni non ne viene giu'
nessuna. Non e' una mappa che si riempie: e' una mappa che **non e' mai
cambiata**.

### Tre righe, e ognuna misurata da sola

**1. Le pietre salgono quando una casa ottiene quello che voleva**, non solo
quando trionfa: `structure_rules.rise_on` passa da `["TRIUMPH"]` a
`["VICTORY","TRIUMPH"]`. Le salite vanno da **0,04 a 1,79** a partita, il grado
2+ a fine anno da **0,56 a 2,31**.

**2. L'Archivio si puo' costruire.** `AST_KNOWLEDGE_ARCHIVE` era **l'unica delle
quarantotto carte senza un mestiere** — `on_commit_effects` vuoto. Adesso ce
l'ha, ed e' quello che il titolo prometteva: impegnata in un Consiglio, apre un
archivio suo sulla Regione della domanda. E' **l'unico modo che una casa ha di
decidere di costruire**: prima le pietre arrivavano solo dall'apertura o da una
Conseguenza, cioe' mai per scelta.

**3. L'Assedio butta giu'.** Era la sola carta del mazzo che potesse togliere una
pietra dal tavolo, e non lo faceva: affamava e basta. Adesso il presidio della
Regione della domanda viene giu' — con `optional`, quindi se non c'e' niente e'
un no-op dichiarato.

| | prima | **dopo** |
|---|---|---|
| alzate dal gioco | 1,51 | **2,41** |
| **abbattute** | **0,00** | **0,43** |
| salite di grado | 0,04 | **1,82** |
| grado 2+ a fine anno | 0,56 | **2,34** |
| playtest 100 semi | 0/8 | **0/8** |

**La mappa adesso si puo' anche svuotare.** Era la meta' che mancava.

### E le clausole che l'apertura regalava salgono, adesso che si puo' costruire

Sei clausole di Destino chiedevano `structure_count >= 1` senza famiglia ne'
grado — cioe' erano gia' vere all'apertura per chiunque avesse una pietra, che
dopo [D-217](#d-217) sono tutte e otto. Passano a **2**. Non e' la stessa mossa
che ho provato e ritirato sugli obiettivi: **li' non c'era modo di costruire e la
soglia era decisa dal setup; qui il modo c'e'**, e la differenza sono le 2,41
pietre che il gioco alza ogni anno.

### Quello che si dichiara

- **«Pietra sopra Pietra» resta 0 su 100.** La salita di grado arriva **dopo** il
  conteggio degli obiettivi, quindi vale per l'anno dopo e non per quello in cui
  e' successa. Non l'ho spostata prima: il criterio della salita e' *«chi ha
  ottenuto quello che voleva»*, e farla contare per lo stesso conteggio che la
  decide sarebbe un cerchio. Serve un modo di alzare un grado **durante** l'anno,
  e non c'e'. Resta in ISSUES 39.
- **La strada A di ISSUES 39 era gia' fatta e nessuno l'aveva chiuso**: il
  criterio era «le pedine mosse per scelta salgono ben sopra una a partita», e
  dopo [D-215](#d-215) MUOVERE si gioca **3,79 volte l'anno**.
- **Due carte su quarantotto cambiano mestiere**, e non e' molto. Ho preferito
  quelle due — l'unica libera, e l'unica che poteva abbattere — invece di
  riscriverne dieci: sono le due che spostano il numero, e il resto e' scrittura
  che si puo' fare quando si sa che serve.

---

## D-216 — Le sedici coppie che non si conoscevano
**implemented in 0.1.185** — il debito dichiarato da D-213, pagato

[D-213](#d-213) ha messo le case in un mazzo solo e ha chiuso il verbale con una
riga onesta: *«le 16 relazioni incrociate non esistono. Su 28 coppie possibili ne
sono scritte 12, tutte dentro la vecchia linea [...] un tavolo misto e' **piu'
piatto** di uno storico»*. Il committente ha detto di sistemarle.

### «Piatto» non e' un aggettivo: e' un numero, ed era il 14%

La prima cosa da fare era smettere di stimarlo. `run_table_probe` conta, per
ogni tavolo che il seme apparecchia, **quante delle sei coppie sedute sono
calde** — cioe' quante non sono NEUTRAL.

| 200 semi | prima | **dopo** |
|---|---|---|
| coppie scritte nel dato | 12 su 28 | **28 su 28** |
| di cui calde | 6 | **14** |
| **tavoli piatti** (nessuno si conosce) | **28 — il 14,0%** | **0 — lo 0,0%** |
| coppie calde per tavolo | 1,22 su 6 | **2,94 su 6** |
| — di cui alleanze | 0,41 | **1,22** |
| — di cui ostilita' | 0,80 | **1,72** |
| il tavolo piu' comune | **1 coppia calda su 6** (51,5%) | **3 su 6** (45,0%) |

Un tavolo piatto non e' un tavolo tranquillo: e' **un tavolo senza storia**.
Nessuna clausola che legge un legame si qualifica, il peso dell'alleanza al
Consiglio ([D-139](#d-139)) non si applica mai, e FORGIARE parte da zero per
tutti. Uno su sette.

### Quante scriverne calde, e perche' otto

Il criterio non e' stato «quante ne servono» ma **la densita' che i due tavoli
d'autore avevano gia'**: nel Grano 2 coppie calde su 6, nel Sale 4 su 6. Meta'
esatta sulle dodici scritte. Quindi delle sedici mancanti, **otto calde e otto
neutrali** — e le neutrali sono scritte lo stesso, perche' un neutrale
dichiarato e un neutrale per dimenticanza si comportano uguale al tavolo ma
dicono due cose diverse a chi legge il dato.

La media pescata torna a **2,94 su 6**: la stessa temperatura dei tavoli scritti
a mano, che e' il numero che il criterio prometteva.

### Le otto calde, e da dove vengono

Nessuna e' stata scelta per far tornare i conti. Ognuna era gia' scritta nelle
descrizioni, e non se ne era accorto nessuno:

| coppia | | perche' |
|---|---|---|
| Lyra ↔ l'Ordine del Vetro | **HOSTILE** | l'Ordine *«custodisce quello che fu misurato, e la regola dice che misurarlo di nuovo e' peccato»*. Lyra **e' quella che l'ha misurato** |
| Vaerax ↔ la Cenere | **HOSTILE** | la Cenere *«tiene le Montagne Rosse e campa di quello che l'antica miniera ha lasciato indietro»*. Vaerax **dorme sotto le Montagne Rosse** |
| Aldric ↔ la Cenere | **HOSTILE** | due case di POTERE sulla stessa terra |
| Aldric ↔ le Citta' Libere | **HOSTILE** | un re, e sette citta' che si governano da sole |
| Vaerax ↔ il Vetro | **ALLY** | l'Ordine custodisce cio' che fu misurato: custodisce anche il suo sonno |
| il Popolo Nahr ↔ la Gilda del Sale | **ALLY**, PACT | undicimila persone che si spostano, e una Gilda i cui carichi devono muoversi |
| il Popolo Nahr ↔ le Citta' Libere | **ALLY** | chi non ha padrone riconosce chi non ha padrone |
| Aldric ↔ la Gilda del Sale | **ALLY**, DEBT | il trono ha bisogno di grano, e la Gilda di una corona che garantisca le firme |

### Un'asimmetria che c'era gia', e nessuno l'aveva vista

La Cenere diceva «alleata al Sale». Il Sale diceva «alleata alla Cenere, **per
patto**». Il patto valeva lo stesso — i tag si sommano — ma **il dato diceva due
cose diverse**, e sul livello non sarebbe andata cosi': nel mondo `relations` e'
una **coppia**, e il motore la costruisce leggendo le Entita' in ordine
alfabetico, quindi chi scrive per ultimo decide. Due case che si dichiarano
livelli diversi non litigano: **una delle due frasi sparisce**, e quale dipende
dall'ordine degli id. Nessun errore, nessun log.

`check_relations_are_written_both_ways` chiude tutte e tre le porte: livelli o
tag discordi, una relazione con una casa inesistente, e — con `entity_pool`
acceso — **una coppia di case pescabili che non e' scritta da nessuna parte**.
Provata su tutte e tre.

### E una prova che guarda il tavolo, non il dato

`test_the_table_has_a_history` gira su cinquanta tavoli pescati e chiede che
nessuno apra piatto, piu' un tavolo interamente misto che deve portare almeno un
legame **incrociato**. Sta accanto alla guardia e non al suo posto, perche' le
due dicono cose diverse: la guardia dice **che ogni coppia e' scritta**, la prova
dice **che quello che e' scritto arriva al tavolo che il seme apparecchia** — e
sono affermazioni che si sono gia' staccate una volta, quando due clausole
nominavano una casa che poteva non sedersi ([D-213](#d-213)). Provata: senza le
sedici coppie va rossa su cinque semi.

### Quello che si dichiara

- **Il playtest quasi non si muove**: Consigli l'anno 4,49 → 4,49 (misto) e
  4,60 → 4,57 (uniforme), Verita' 333 → 335 e 308 → 307, playtest **0/8**. Le
  relazioni pesano al **Consiglio** — nel peso dell'alleato che impegna carte, e
  nelle clausole che leggono un legame — non nella scelta delle azioni, e il
  cervello di misura non tratta ancora un alleato diversamente da uno
  sconosciuto quando decide cosa fare.
- **Quindi il numero che conta e' quello della sonda nuova, non quello del
  cancello.** Il cancello dice che non ho rotto niente; `run_table_probe` dice
  che il tavolo ha una storia. Sono due cose diverse e serve dirle separate.
- **Le otto neutrali restano una scelta da rivedere.** Lyra e la Gilda del Sale
  — una che legge registri e una che li tiene — sono la piu' evidente: e'
  rimasta neutrale per tenere la densita' a otto, non perche' non ci sia niente
  da dire.

---

## D-215 — Nessuna famiglia senza un'azione
**implemented in 0.1.184** — la risposta a «le azioni sono equamente distribuite nelle carte?»

Il committente ha chiesto un numero che non era mai stato misurato. Le
**famiglie** erano pari — 22 copie ciascuna, esatte. Le **azioni** no, e
l'incrocio aveva nove zeri:

| copie in mazzo | CLAIM | FORGE | INFLUENCE | MOVE | SCHEME | |
|---|---|---|---|---|---|---|
| AUTHORITY | 11 | 2 | 9 | **0** | **0** | 22 |
| BONDS | 4 | 14 | 2 | **0** | 2 | 22 |
| FORCE | 2 | **0** | 5 | 15 | **0** | 22 |
| KNOWLEDGE | 1 | **0** | 2 | 4 | 15 | 22 |
| PEOPLE | 2 | **0** | 7 | 9 | 4 | 22 |
| WEALTH | **0** | 7 | 12 | 3 | **0** | 22 |
| **in tutto** | 20 | 23 | **37** | 31 | 21 | 132 |

### Perche' uno zero li' e' peggio di uno squilibrio

Le azioni passano sulle carte ([D-188](#d-188)) e **la mappa decide che carte
peschi**. Quindi la mappa decide che *cose puoi fare* — ed era gia' scritto in
MECCANICA come una virtu' del disegno: «chi sta sulle montagne muove eserciti;
chi sta nelle miniere sa».

Ma con uno zero non e' un accento: e' **una porta chiusa senza dirlo**. Chi gioca
RICCHEZZA non poteva rivendicare mai. Chi gioca AUTORITA' non poteva muovere mai.
E Lyra, che vive di SAPERE, aveva **4 copie di MUOVERE su 132**: quando
[D-208](#d-208) ha misurato che la mappa e' ferma e ha trovato il 30% dei seggi
bloccati dalla riga «nessuna carta MUOVERE in mano», la causa era gia' qui e
nessuno l'aveva guardata.

### Come e' fatto adesso

Dieci carte cambiano azione. **Nessuna cambia mestiere**: il criterio e' che il
nuovo verbo fosse gia' dentro il titolo, non che i conti tornassero.

| carta | prima | dopo | perche' |
|---|---|---|---|
| Censimento | INFLUENCE | **SCHEME** | contare la gente e' il modo piu' vecchio di guardare le carte degli altri |
| Magistrato | FORGE | **MOVE** | un magistrato lo si manda, e dove siede la corona c'e' |
| Investitura | CLAIM | **FORGE** | investire qualcuno e' legarlo |
| Favore | FORGE | **INFLUENCE** | un favore chiesto al momento giusto sposta una questione |
| Diritto di Ospitalita' | FORGE | **MOVE** | essere ospiti e' essere la' |
| Guardia di Confine | MOVE | **SCHEME** | chi guarda il confine vede passare tutto |
| Mercenari | MOVE | **FORGE** | la lealta' pagata e' pur sempre un legame |
| Le Porte Bruciate | INFLUENCE | **CLAIM** | si e' gia' preso, e adesso lo si dice |
| Registro | SCHEME | **FORGE** | due case che tengono lo stesso registro hanno gia' cominciato a fidarsi |
| Braccia per il Raccolto | MOVE | **FORGE** | dal raccolto di un altro nasce un debito che somiglia a un'amicizia |
| Pedaggio | INFLUENCE | **CLAIM** | una corda su una strada e' una rivendicazione col prezzo scritto sopra |
| Sale | INFLUENCE | **SCHEME** | con i carri del sale viaggiano le notizie |

| copie in mazzo | CLAIM | FORGE | INFLUENCE | MOVE | SCHEME | |
|---|---|---|---|---|---|---|
| AUTHORITY | 7 | 4 | 5 | 2 | 4 | 22 |
| BONDS | 4 | 6 | 6 | 4 | 2 | 22 |
| FORCE | 3 | 4 | 4 | 7 | 4 | 22 |
| KNOWLEDGE | 1 | 4 | 2 | 4 | 11 | 22 |
| PEOPLE | 2 | 4 | 7 | 5 | 4 | 22 |
| WEALTH | 4 | 7 | 4 | 3 | 4 | 22 |
| **in tutto** | 21 | 29 | 28 | 25 | 29 | 132 |

**Nessuno zero**, e lo scarto fra l'azione piu' comune e la piu' rara scende da
**1,85× a 1,38×**. Le identita' restano dove erano — SAPERE trama (11 su 22),
LEGAMI forgia, FORZA muove, AUTORITA' rivendica — ma adesso sono **accenti**,
non muri.

### La guardia

`check_every_family_can_do_everything` in `validate_data.py`. Non chiede che le
azioni siano pari — l'identita' di una famiglia sta proprio in cio' che fa piu'
spesso — ma che **nessuna sia a zero**, e che la piu' rara non stia sotto meta'
della piu' frequente. Provata: rimettendo il Magistrato a FORGE, AUTORITA' torna
senza MUOVERE e la guardia va rossa.

### I numeri

| 100 semi, seme 7000 | prima | **dopo** |
|---|---|---|
| Verita' scritte, misto | 317 | **333** |
| Verita' scritte, uniforme | 319 | **308** |
| Consigli l'anno, misto | 4,49 | 4,49 |
| MUOVERE giocate l'anno | 4,64 | **3,79** |
| bloccati da «nessuna MUOVERE in mano» | 30,5% | **38,0%** |
| Regione piu' magra a fine anno | 1,26 | **1,26** |
| playtest 100 semi | 0/8 | **0/8** |

**MUOVERE si gioca meno, ed e' voluto**: era il 23,5% del mazzo per una sola
azione su cinque. Il costo si vede tutto nella riga «nessuna carta in mano», che
sale — ma sale per **tutti allo stesso modo**, invece di essere il 100% per una
casa e lo 0% per un'altra. Il punto non era muovere di piu': era che ogni casa
potesse.

### Quello che si dichiara

- **Il piano D si e' ribasato**, ed e' l'unico. Era «la prima storia scritta a
  mano nell'economia di adesso», quindi non poteva dichiarare un mazzo di prima:
  il suo gesto d'apertura — Aldric che strappa il primo Consiglio col Diritto di
  Corona — regge intatto, e la sua morale pure («e' l'anno di chi ha parlato per
  primo, non di chi ha vinto»: il trono chiude con due obiettivi, i Nahr con
  tre). Cambia il finale: l'ultima domanda, che cadeva, adesso passa.
  **Ho scelto male la prima volta**: avevo spostato proprio il Diritto di Corona,
  cioe' la carta di cui quella storia parla. Il piano e' andato rosso e ha avuto
  ragione lui.
- **KNOWLEDGE resta la piu' sbilanciata** (11 SCHEME su 22, e 1 sola CLAIM). E'
  l'identita' piu' forte del mazzo, e per ora resta com'e'.
- **Cinque sonde erano rotte e nessuno lo sapeva.** Le sonde di `godot/cli/` non
  stanno nel cancello, quindi un cambio di firma in `GameSession`
  ([D-213](#d-213)) le ha lasciate con un identificatore fuori posto e la CI e'
  restata verde. Una sonda che non parte non e' uno strumento rotto: e' **una
  misura che non si puo' piu' fare**, e questo progetto sta in piedi sulle
  misure. Adesso `test_probes_compile` le carica tutte.

---

## D-214 — Il Consiglio chiude l'Atto, e il cancello si spegne
**implemented in 0.1.183** — la voce che avevo rimandato senza dirlo

*«Inoltre scaldare il mondo con due pedine non lo avevamo tolto? Il concilio c'e'
alla fine di ogni atto, non servono due gettoni per farlo partire.»*

Il committente l'aveva gia' deciso una volta: *«il consiglio si puo' aprire alla
fine di ogni atto in automatico e la domanda con piu' valore sara' quella
dibattuta, cosi' e' sicuro che almeno tre consigli ci saranno sempre»*. Io
l'avevo prezzato, l'avevo chiamato «il cambio piu' grosso di tutti quelli in
lista», e l'avevo messo in coda — **senza piu' dirlo**. Ha dovuto chiedere due
volte, e la seconda per sapere se il cancello a due gettoni era ancora acceso.
Lo era.

### Come e' fatto adesso

`confluence_rules.at_end_of_act` sulla Chronicle. Acceso:

- **a fine di ogni Atto si tiene un Consiglio**, sulla domanda col mucchio piu'
  alto — che e' esattamente cio' che i gettoni coperti costruiscono per tutto
  l'Atto ([D-210](#d-210)): si girano, si contano, e vince chi ha scaldato di
  piu';
- **il round non ne apre piu' nessuno da solo**: ne' per soglia, ne' per
  gettoni nel sacchetto. `tension_tokens.table_gate` e' stato **tolto dai dati
  spediti** — non dal motore, perche' resta una regola che una Chronicle puo'
  dichiarare, e una prova la copre;
- **resta RIVENDICARE**, che e' il modo di portare al tavolo una **seconda**
  domanda. Senza quello la regola sarebbe un Consiglio *in piu'* invece di un
  Consiglio *al posto* degli altri.

**I gettoni smettono di dire *se* si parla e dicono soltanto *di cosa*.** Che e'
il lavoro che [D-210](#d-210) gli aveva dato e che il cancello gli toglieva a
meta'.

### Il difetto che ha scoperto: due prove che non erano la stessa prova

Alla prima misura la promessa **non era mantenuta**: su cento anni, tre
chiudevano con meno di un Consiglio per Atto, e uno rifiutava **otto aperture di
fila** sullo stesso template.

La causa e' che il codice aveva due domande diverse e le trattava da sinonimi.
`has_fresh_question` chiede «resta un quesito mai posto?». Ma il template apre un
quesito solo se e' **idoneo** — la Tensione abbastanza alta, il mondo con un
certo segno. Un quesito puo' essere freschissimo e non aprirsi.

Finche' il Consiglio si apriva a soglia la differenza non si vedeva, perche'
arrivare a soglia rendeva idoneo quasi tutto. Il Consiglio di fine Atto si apre
**quando l'Atto finisce**, calda o no, e la crepa e' venuta fuori al primo
tentativo. Ora c'e' `can_open()`, che fa la prova vera, e la chiusura scende al
mucchio successivo invece di perdere il Consiglio.

### I numeri, 100 semi, seme 7000

| | prima | **dopo** |
|---|---|---|
| Consigli l'anno, misto | 3,09 | **4,49** |
| Consigli l'anno, uniforme | 3,20 | **4,64** |
| il minimo su 100 anni | **1** | **3** |
| Verita' scritte, misto | 254 | **317** |
| Verita' scritte, uniforme | 229 | **319** |
| Atti chiusi senza Consiglio | — | **0 su 300** |
| playtest 100 semi | 0/8 | **0/8** |

**Il minimo e' tre, e non e' una media: e' un pavimento.** Su trecento Atti
misurati nessuno si chiude muto, e il tavolo piu' silenzioso possibile — quattro
seggi che passano ogni round — ne prende tre lo stesso. Il gioco e' tornato a
scrivere piu' Verita' di prima dell'unificazione (317 contro 295), con dodici
domande in biblioteca invece di sei.

### Il pavimento di fine anno non serve piu'

[D-047](#d-047) aveva messo un pavimento perche' un anno poteva chiudersi con
**zero** Consigli. Con un Consiglio per Atto la garanzia e' strutturale, e il
pavimento e' una seconda cintura su una che tiene gia'. Non e' stato tolto dal
motore — una Chronicle che non tiene il Consiglio di chiusura lo vuole ancora, e
`test_year_end_floor` gira su quel regime dichiarandolo — ma sui dati spediti
**non scatta mai**.

### Quello che si dichiara

- **43 aperture su cento anni vengono ancora rifiutate**, e adesso sono tutte
  Consigli **forzati da RIVENDICARE**: il Claim non passa da `can_open`, quindi
  si puo' spendere un'azione per forzare un Consiglio che poi non si apre. E'
  un difetto vero e **preesistente**, che questa misura ha portato alla luce; non
  e' stato toccato qui.
- **Le quattro storie scritte a mano dichiarano il regime in cui sono nate**
  (`chronicle_overrides.confluence_rules`), come gia' dichiarano l'economia
  ([D-189](#d-189)) e la mappa ([D-212](#d-212)).
- **Il lato classico della suite spegne anche questo interruttore.** E' la
  quarta volta che `play_classic()` cresce di una riga, ed e' la stessa lezione
  di D-184: due meta' di due giochi diversi non si provano insieme.

---

## D-213 — Un setup solo: le case si pescano come le domande
**implemented in 0.1.182** — ISSUES 48/52 cambiano forma, e tre difetti nascosti vengono fuori

*«Ma io continuo a non capire perche' abbiamo due ere. Ti avevo detto che c'e'
un'unica linea, e Cenere, Sale possono coesistere con i Nahr, le entita' vengono
pescate casualmente all'inizio della saga. [...] Stai girando in tondo.»*

Il committente ha ragione, e la parte piu' onesta di questo verbale e' dire
quanto: il gioco aveva **quattro Chronicle in due linee chiuse** — Grano
(CHR_01→CHR_02) e Sale (CHR_03→CHR_04) — ognuna con **quattro case scritte a
mano** e **sei domande sue**. Le domande si pescavano gia' ([D-207](#d-207)), ma
da una biblioteca per linea. Chi si sedeva non si pescava affatto.

### Cosa c'era gia', e cosa mancava davvero

Guardato invece che ricordato, il lavoro era meno di quanto sembrasse:

| | prima | serviva |
|---|---|---|
| **Obiettivi** | gia' un mazzo solo, 12 carte, nessuno scope d'era | niente |
| **Regioni** | gia' condivise, le stesse 6 | niente |
| **Domande** | pescate, ma da **6 candidate per linea** | una biblioteca da 12 |
| **Case** | `entities: [4 id fissi]` per Chronicle | `entity_pool`, 8 → 4 |

### `entity_pool`, e perche' e' la stessa forma di `tension_pool`

La Chronicle dice **chi puo' esserci** e l'RNG a seme apparecchia. Vuoto o
omesso, il tavolo e' quello scritto — una dichiarazione vuota vuol dire assenza,
come ovunque nel progetto.

La pesca sta in `GameSession.seats_for()`, **statica e fuori da `setup`**, per
una ragione: il tavolo va saputo *prima* che il mondo esista — chi apparecchia i
caratteri, chi stampa una scheda, chi scrive una riga di resoconto lo chiede
prima. E stando fuori non consuma l'RNG della partita: c'e' una strada sola, e
il seme che apparecchia e' lo stesso che gioca.

Dentro `setup`, se la Chronicle pesca, `_chronicle_def` viene **duplicata** e le
sue `entities` diventano i seduti: il resto del mondo — pedine, mazzi,
successione, relazioni — legge quella lista, e senza la copia il gioco
apparecchierebbe otto case e ne farebbe giocare quattro.

### La pietra segue la casa

`starting_structures` stava sulla Chronicle e mescolava due cose diverse: il
**paesaggio** (bosco, sorgente, valico, sito antico) e il **presidio della
casa**. Finche' il tavolo era scritto a mano la differenza non si vedeva; col
tavolo pescato una pietra intestata a chi non gioca e' la pietra di un assente.

Quindi il presidio e' passato **sull'Entita'**, con `at` che indicizza la
presenza di partenza — cosi' se la casa si sposta, la sua pietra si sposta con
lei (e [D-212](#d-212) ne e' la prova: Lyra si e' spostata ieri). Il paesaggio
resta sulla Chronicle, perche' e' la mappa. La rifattorizzazione e' stata
misurata da sola: **playtest byte-identico**, come deve essere una mossa che non
cambia il gioco.

### Tre difetti che nessuno vedeva, e che il tavolo pescato ha scoperto

Sono la parte importante di questo verbale. Nessuno dei tre era nuovo: erano
**invisibili perche' il tavolo non cambiava mai**.

1. **L'eredita' portava relazioni fra case che non siedono.** `SET_RELATION` su
   una coppia senza record e' un Effetto senza inverso — la cosa che
   l'effect-sourcing non ammette. Ora l'eredita' filtra su chi e' al tavolo.
2. **E portava il controllo e le pietre di case assenti.** Un mondo che dice
   «Eredan e' di Aldric» quando Aldric non gioca fa provare al Consiglio di
   cacciare qualcuno che non c'e'. Stessa guardia, due righe.
3. **Due clausole di Consiglio nominavano Lyra per nome.** «...e allora Lyra ha
   il registro»: con Lyra assente l'Effetto cadeva in un `push_error` dentro un
   log che nessuno legge — cioe' **contenuto che non succede e non si lamenta**.
   Ora usano `$conditioner`, un segnaposto nuovo che lega **chi ha posto la
   condizione**: piu' giusto anche a leggerlo, perche' quello che la condizione
   ottiene lo ottiene chi l'ha chiesto.

E una Conseguenza che parla davvero di una casa — «Il Drago Abbattuto» spegne
Vaerax — adesso lo **dichiara** (`requires_entity`) e si salta quando quella casa
non siede, dicendolo nel verbale: D-030 vale anche per cio' che *non* succede.

**Due guardie nuove** in `validate_data.py` chiudono la porta: con le case
pescate nessun Effetto scritto a mano puo' puntare a un `ENT_` (se non quello
che la Conseguenza dichiara), e la prova del traguardo adesso verifica che ogni
anno peschi **dalla stessa biblioteca** invece di contare due biblioteche
separate — contarle separate *era* la voce.

### I numeri: la varieta', che e' la cosa per cui il cambio esiste

12 saghe da 6 Chronicle, seme 812, tavolo misto:

| | Grano | Sale | **unificato** |
|---|---|---|---|
| aperture diverse su 12 saghe | 6 | 4 | **12** |
| distanza media fra saghe | 0,88 | 0,83 | **0,97** |
| frasi distinte in tutto | 96 | 52 | **106** |
| vite viste al tavolo | 6 | 6 | **13** |
| distanza al primo anno | 0,97 | 0,97 | **0,99** |

**Ogni saga adesso apre diversa da ogni altra**, e al tavolo si vedono tredici
vite invece di sei. Su 200 semi escono **67 tavoli diversi su 70 possibili**, e
le otto case si siedono fra il 45,0% e il 54,5% delle volte — il pool e' pari.

### I numeri peggiorati, che si scrivono

| 100 semi, seme 7000 | prima (Grano+Sale) | **unificato** |
|---|---|---|
| Consigli l'anno, misto | 3,53 | **3,09** |
| Consigli l'anno, uniforme | 3,64 | **3,20** |
| Verita' scritte, misto | 295 | **254** |
| playtest | 0/8 | **0/8** |

- **Si parla meno**: mezzo Consiglio in meno all'anno. Con dodici domande in
  biblioteca e quattro pescate, il calore si sparpaglia su un mazzo doppio.
- **Il tavolo e' piu' irregolare per seggio**, ed e' voluto: una casa che gioca
  la meta' degli anni ha meta' dei dati, e i suoi numeri ballano. Ma le colonne
  restano tutte popolate e **nessun seggio e' bloccato su un solo livello**, che
  e' il vincolo mai negoziato.
- **I TRIONFI restano rari**: 3 su 288 seggi-anno nella saga lunga, come prima.
  L'unificazione non ha toccato la scala, e [ISSUES 52](ISSUES.md#52-lyra-non-ha-mai-trionfato-in-centoventi-anni)
  resta aperta con la sua causa: due case su otto — Lyra e il Vetro — aprono
  ancora senza una pietra.

### Cosa non e' stato fatto, e si dichiara

- **Le 16 relazioni incrociate non esistono.** Su 28 coppie possibili ne sono
  scritte 12, tutte dentro la vecchia linea: Aldric↔Sale, Lyra↔Vetro,
  Nahr↔Cenere e le altre partono a NEUTRAL. Il gioco funziona — ogni coppia
  parte neutrale per costruzione — ma un tavolo misto e' **piu' piatto** di uno
  storico, e questo spiega parte del mezzo Consiglio perduto.
- **Le quattro Chronicle sono ancora quattro**, con quattro titoli. Adesso sono
  *anni*, non *ere*: pescano dalla stessa biblioteca e apparecchiano dalle
  stesse case. Ridurne il numero e' contenuto, non regola.
- **Il Consiglio a fine Atto non c'e' ancora**, e il cancello a due gettoni e'
  ancora acceso. E' la prossima voce, ed e' stata rimandata da me senza dirlo —
  il committente ha dovuto chiedere due volte.

---

## D-212 — Lyra sulla Strada dei Mercanti, e la mappa che un piano dichiara
**implemented in 0.1.181** — l'altra meta' di ISSUES 48, quella che costa storie

[D-211](#d-211) aveva spedito meta' della decisione del committente e aveva
lasciato scritto il prezzo dell'altra meta': *«spostare la casa di Lyra rompe
tutte e quattro le storie scritte a mano [...] non e' una manopola: e' **dove
vive una casa**, cioe' contenuto. Va deciso da lui, non dedotto da me.»*

Il committente ha deciso: **«Lyra sulla Strada dei Mercanti»**. Lyra apre con
Miniere Antiche + **Strada dei Mercanti** invece di Miniere Antiche + Eredan.

### Il problema vero non era la riga di dati: erano le quattro storie

La riga di dati e' una parola. Le quattro storie scritte a mano si rompono
**tutte**, e non di poco: il piano B passa da 3 Consigli a 6, il piano D da 4 a
5, e A e C cambiano esito nel finale. Le due strade possibili erano:

- **ribasare i quattro `expected`** — cioe' prendere quello che esce e chiamarlo
  la storia. Ma un piano scriptato **e' una storia disegnata**: le sue mosse
  sono scritte perche' succeda una cosa precisa. Ribasarlo su un'altra mappa
  non lo aggiorna, lo **timbra**: resta un elenco di mosse a cui si e' dato
  ragione a posteriori. Il piano C lo dice da solo — *«una domanda che sembrava
  chiusa si riapre e resta aperta»* — e su questa mappa quella domanda passa.
- **far dichiarare al piano la mappa in cui e' stato scritto**, che e' lo stesso
  idioma che i piani gia' usano per l'economia ([D-189](#d-189)).

E' passata la seconda. `starting_presence` sulla Chronicle: un dizionario
`entita' -> Regioni` che sostituisce la presenza scritta sull'Entita'. Vuoto o
omesso, la mappa e' quella delle Entita' — **una dichiarazione vuota vuol dire
assenza**, come ovunque nel progetto. Vale solo per la **prima vita** del
seggio: dopo una successione comanda l'incarnazione, che la sua presenza se la
porta ([D-133](#d-133)).

Non serve macchinario nuovo: `chronicle_overrides` scrive gia' qualunque chiave
sulla Chronicle, quindi i quattro piani dichiarano `starting_presence` e passano
dalla **stessa** `GameSession.apply_plan_overrides` che usano la suite e la
sonda. La porta si allarga di una chiave, e lo schema la tiene stretta come le
altre.

### La guardia, perche' una dichiarazione marcisce in silenzio

Una mappa dichiarata che **coincide** col dato spedito non dichiara piu' niente:
sembra una scelta e non lo e'. `check_a_declared_map_still_says_something` in
`validate_data.py` va rossa se un piano ripete la presenza gia' scritta
sull'Entita', o se nomina un'Entita' che non esiste. Provata: rimettendo Lyra a
Eredan, morde su tutti e quattro i piani.

**Quello che la guardia non puo' vedere, e va detto**: una casa che i piani
**non nominano** e che sul dato si sposta domani. Li' le storie cambierebbero in
silenzio, come sono cambiate oggi. La guardia tiene pulita la dichiarazione; non
sa accorgersi di una dichiarazione che manca.

### I numeri, 100 semi, seme 7000

| | Lyra a Eredan | **Lyra sulla Strada** |
|---|---|---|
| Strada dei Mercanti, apertura → fine | 0,00 → 1,20 | **1,00 → 2,07** |
| Regione piu' vuota a fine anno | Strada, 1,20 | **Montagne Rosse, 1,78** |
| Lyra NONE, uniforme | 16 | **8** |
| Lyra VITTORIE, uniforme | 10 | **28** |
| Lyra NONE, misto | 17 | **8** |
| Lyra VITTORIE, misto | 12 | **22** |
| Lyra: anni con **zero** obiettivi presi | 35 | **20** |
| Lyra: anni con **tre** obiettivi presi | 7 | **19** |
| NONE in tutto, uniforme | 61 | **51** |
| VITTORIE in tutto, uniforme | 181 | **193** |
| bloccati dal gettone | 44,0% | 51,0% |
| playtest 100 semi | 0/8 | **0/8** |

### I numeri peggiorati, che si scrivono

- **I TRIONFI calano**: 10 → **8** a tavolo uniforme, 5 → **2** a tavolo misto.
  Lyra passa da 1 Trionfo a **0** in tutte e due, e Vaerax pure. Il tetto si
  abbassa mentre il pavimento si alza — la stessa forma di D-211.
- **Aldric paga il conto**: NONE 7 → **10** e Vittorie 23 → **14** a tavolo
  uniforme, NONE 9 → **14** a tavolo misto. Lyra gli lascia Eredan e lui sta
  peggio, il che vuol dire che non era la concorrenza sulla Regione: e' il
  flusso delle carte che cambia sotto.
- **I gettoni si bloccano prima**: 44,0% → 51,0% delle occasioni finiscono
  «tutte gia' sul tavolo». Una pedina in piu' sulla Strada e' una pedina in meno
  da posare altrove.
- **E spostare continua a non succedere**: 0,00 l'anno, come prima. Questa
  decisione riempie la Regione vuota; **non** rende la mappa mobile. Quella
  resta [ISSUES 39](ISSUES.md#39-la-terra-che-si-vede-pedine-di-carta-o-strutture-con-una-vita).

### Cosa non e' stato fatto, e perche'

Il committente ha chiesto anche **«Nahr sulle Terre Nahr»**. Nella linea del
Grano **e' gia' cosi'**: il Popolo Nahr apre con Terre Nahr + Valle Verde, e li'
non c'e' niente da spostare. La Regione vuota e' **Terre Nahr nella linea del
Sale**, dove i Nahr non esistono: le case sono Sale, Cenere, Vetro e Citta'
Libere, e tre di loro aprono su Eredan. Chi ci va e' una scelta di contenuto —
quale casa vive dove — e torna al committente col prezzo misurato, come e'
tornata questa.

---

## D-211 — Due pedine di riserva invece di una
**implemented in 0.1.180** — meta' di ISSUES 48, e la meta' che non costa storie

[D-208](#d-208) aveva misurato perche' la mappa e' ferma: ogni casa comincia con
**2 pedine** e il tetto e' **3**, quindi ha **un** gettone di riserva per tutto
l'anno. Lo posa, e da li' non ha piu' niente da muovere — il 71% dei seggi
finisce l'anno con tutte le pedine sul tavolo.

Il committente ha deciso il risultato: «**non ci puo' essere una regione senza
nessuno**, e anzi la Strada dei Mercanti dovrebbe essere uno snodo vitale». I
tre rimedi prezzati erano il tetto a 4, gli studiosi che cominciano sulla
Strada, e i due insieme.

### Perche' e' passato solo il tetto

Provati **separatamente**, i due rimedi costano cose diverse:

- **il tetto a 4** rompe due prove che descrivevano il setup invece
  dell'intenzione, e **nessuna storia**;
- **spostare la casa di Lyra** rompe **tutte e quattro** le storie scritte a
  mano: cambia la posizione d'apertura, e con quella i Consigli di ogni piano.

E la seconda non e' una manopola: e' **dove vive una casa**, cioe' contenuto. Il
committente ha scelto il risultato, non quel mezzo — e adesso il mezzo ha un
prezzo scritto. Va deciso da lui, non dedotto da me.

### I numeri, misurati col gioco di adesso

| | tetto 3 | **tetto 4** |
|---|---|---|
| gettoni di riserva per casa | 1,00 | **2,00** |
| MUOVERE l'anno, Grano | 3,02 | **4,70** |
| MUOVERE l'anno, Sale | 2,88 | **4,20** |
| bloccati dal gettone, Grano | 71,2% | **40,6%** |
| bloccati dal gettone, Sale | 74,4% | **47,5%** |
| Strada dei Mercanti (Grano), apertura → fine | 0,00 → 0,65 | 0,00 → **1,20** |
| Terre Nahr (Sale), apertura → fine | 0,00 → 0,55 | 0,00 → **0,88** |
| Consigli l'anno, uniforme | 3,40 | **3,57** |
| Consigli l'anno, misto | 3,57 | **3,86** |
| playtest 100 semi | 0/8 | **0/8** |

**Meta' della decisione e' soddisfatta, meta' no, ed e' scritto quale.** Nel
Grano nessuna Regione finisce l'anno sotto **1,20** pedine: la Strada non e' piu'
deserta. Nel Sale le **Terre Nahr restano a 0,88**, sotto una pedina — perche'
li' non comincia nessuno, ed e' esattamente la causa che D-208 aveva nominato.
Il tetto allarga il rubinetto; non fa cominciare qualcuno dove non comincia
nessuno.

E **spostare non succede ancora mai**: 0,03 volte l'anno nel Grano, 0,00 nel
Sale. Il tetto da' piu' pedine da **posare**, non insegna a **ritirarsi**.

### Le quattro storie: due passano, una migliora, una si dichiara

Provato **senza** lo spostamento di Lyra, il tetto da solo tocca due piani su
quattro, e solo l'ultimo esito — i Consigli restano gli stessi:

- **B e D** passano invariati: sono storie del gioco spedito, e la guardia di
  [D-206](#d-206) («almeno una storia per economia») e' soddisfatta;
- **A, «L'accordo del grano»**, si **ribasa**: l'ultima domanda si chiude
  DECISIVE invece che con un costo. La sua descrizione dice «la Chronicle di chi
  ha preparato meglio», e con due gettoni di riserva Aldric arriva all'ultima
  domanda con la mano ancora piena — il finale nuovo dice meglio quello che la
  storia gia' diceva. Riscritta la frase, non solo il numero;
- **C, «La miniera aperta»**, **dichiara il tetto 3**. Il suo finale *e'* la
  storia: «una domanda che sembrava chiusa si riapre e resta aperta», e col
  quarto gettone quelle Vie passano invece di cadere. Ribasarla avrebbe reso
  falsa la sua descrizione; dichiararlo la lascia vera e dice perche'.

E' la differenza fra un numero che si aggiorna e una storia che si perde.

### Due difetti trovati per strada

- **L'inverso di `REMOVE_PRESENCE` rimetteva la pedina in fondo**, non dove
  stava. Il round trip promette *identico*, non *equivalente*, e questo dava
  equivalente: il carico dell'inverso non portava il posto. Era invisibile
  perche' la Regione di prova era l'ultima della lista. Adesso porta `at`.
  **Non e' un difetto di gioco**: chi sceglie la pedina da spostare passa da
  `regions_with_presence`, che ordina — ma la promessa dell'effect-sourcing va
  tenuta com'e' scritta.
- **Due prove descrivevano il setup invece dell'intenzione.** `test_data_boot`
  scriveva «3 token presenza» col numero dentro; `test_action_resolver`
  posava esattamente tre pedine; `test_destiny_warning` ne distribuiva a giro
  su tre Regioni — e col tetto a 4 ne posava **due** sulla montagna, dove la
  clausola chiede `min: 1`, quindi l'avviso taceva **per la ragione giusta**.
  Adesso leggono il tetto dal dato.

  E quel test ha insegnato una cosa che non era scritta da nessuna parte: la
  pedina che parte non e' una qualsiasi, e' la **prima in ordine alfabetico**
  fra le Regioni tenute, perche' `_pick_source_region` legge
  `regions_with_presence` e quella ordina. Il test adesso lo dice e lo verifica.

---

## D-210 — I mucchi coperti, e il pavimento che non sapeva del cancello
**implemented in 0.1.179** — ISSUES 49 fase 3, chiusa

«Ogni carta o azione fa pescare uno o piu' segnalini coperti che **danno un
valore** a una tensione. A un certo punto, quando parte la Confluence, **si
girano**, e la tensione col punteggio piu' alto viene dibattuta.»

Le prime due fasi erano fatte: i giocatori pescano il calore
([D-192](#d-192)), e una soglia sola per il tavolo decide quando si parla
([D-203](#d-203)). Restava la terza, ed e' quella che cambia **cosa si sa**.

### Coprire vuol dire due cose, non una

**Un mucchio in cui ogni gettone vale 1 si conta a occhio**: coprirlo non
nasconderebbe niente. Quindi la regola e' una cosa sola in due meta':

- il gettone pesca un **valore** dal sacchetto dichiarato dalla Chronicle —
  `covered: [0, 1, 1, 2]`, media **1,00**, quindi il calore totale non cambia in
  attesa, cambia la **varianza**. Lo zero e' il **gettone bianco**: non muove
  niente ma **e' sceso**, quindi conta per il cancello e si vede cadere. Senza
  di lui, contare i gettoni tornerebbe a dire il punteggio;
- il punteggio smette di essere pubblico. Si vede **quanti gettoni** sono
  caduti su ogni domanda, non quanto pesano.

Il cancello continua a contare i **gettoni**, non i valori: coprire cambia
**quale domanda vince**, non quanto spesso si parla.

### Tre finestre, non una

Il numero era scritto in tre posti — il verbale pubblico, la scheda del seggio,
la pagina d'aiuto — e bastava lasciarne aperto uno perche' coprire fosse teatro.
E' la lezione di §5ter (*nessuna misura copre quello che una persona legge*),
presa in anticipo invece che dopo: otto prove nuove, e tre di loro mordono
davvero se una finestra resta aperta.

### I numeri

| | prima | dopo |
|---|---|---|
| Consigli l'anno, uniforme | 3,37 | **3,40** |
| Consigli l'anno, misto | 3,73 | **3,57** |
| scarto fra i mucchi, atti I→III | 3,95 → 5,95 → 6,42 | 4,17 → 5,90 → **6,92** |
| playtest 100 semi, misto e uniforme | 0/8 | **0/8** |

**Il criterio di chiusura della voce era impossibile, e l'ha detto la misura.**
«Lo scarto fra il mucchio piu' alto e il piu' basso non cresce di atto in atto»
**era gia' falso senza coprire**: 3,95 → 6,42. I mucchi crescono per
costruzione — accumulano, e che uno diventi il piu' alto e' tutto il punto del
cancello. Coprire aggiunge **+0,28** su tre atti. Il criterio giusto e' *non
cresce piu' di quanto gia' cresceva*, ed e' soddisfatto — scritto cosi' invece
che dichiarato raggiunto.

### Il difetto vecchio che ha scoperto

Il pavimento di fine anno (`minimum_confluences`) portava la domanda piu' vicina
**alla propria soglia**. Ma col cancello del tavolo **la soglia non apre piu'
niente**: il Consiglio si apre a gettoni. E se la domanda piu' vicina era gia'
sopra la sua soglia — cosa normale, coi gettoni che alzano i valori — il
pavimento trovava `smallest_gap <= 0` e **usciva zitto senza fare nulla**.

Latente da D-203, invisibile finche' i valori restavano bassi. La copertura li
ha alzati quel tanto che bastava, un anno e' sceso a **un Consiglio solo**, e
`test_year_end_floor` l'ha trovato. Non era il gettone bianco: rimesso il bianco
**dopo** la correzione, la suite e' verde.

Adesso, sotto il cancello, il pavimento **fa cadere i gettoni che mancano** — e
li fa cadere come Effetti, uno per volta, firmati `YEAR_END` e reversibili.
Alzare il contatore e basta avrebbe aperto un Consiglio che il registro non sa
spiegare, e sarebbe stato l'unico posto del motore in cui il verbale smette di
raccontare il tavolo. Quel principio ce l'aveva gia' un test, ed e' stato lui a
rifiutare la prima toppa.

---

## D-209 — Tre case aprono l'anno con due obiettivi gia' in tasca
**misurato in 0.1.177, esteso in 0.1.178** — nessuna regola cambiata, tre strade prezzate

ISSUES 52 chiedeva **quali** obiettivi Lyra manca, e se sono sempre gli stessi:
«un seggio che manca sempre le stesse due carte e' una taratura; un seggio che
ne manca ogni volta di diverse e' un problema di posizione». La risposta e' la
prima, ed e' piu' netta di come era stata immaginata.

`run_objective_ledger` conta per ogni coppia **seggio x obiettivo** quante volte
e' stato pescato e quante preso — il consuntivo, dove `run_objective_probe`
misurava il preventivo. Su 60 partite a tavolo misto:

| obiettivo | Aldric | Nahr | Vaerax | **Lyra** |
|---|---|---|---|---|
| Qualcosa che Resta in Piedi — una struttura sua | 100% | 100% | 100% | **4,5%** |
| Il Muro che Tiene — un presidio suo | 100% | 100% | 100% | **0%** |

I **due obiettivi piu' facili del pool** sono un regalo dell'apertura per tre
case e un muro per la quarta. La causa sta in una riga di dati:
`starting_structures` posa uno `STR_KEEP` — famiglia PRESIDIO, quindi struttura
*e* presidio insieme — per Aldric, per Nahr e per Vaerax. **A Lyra niente.**

### Perche' nessuna sonda l'aveva visto

Il preventivo di [D-197](#d-197) misurava A_STONE al **79%** e A_GARRISON al
**74,8%**, e quei numeri erano giusti: 100 + 100 + 100 + 4,5 fa 76. **La media
era vera e nascondeva che una casa su quattro e' fuori.**

E' la stessa forma di [D-207](#d-207) — un primo anno identico che si perde
dentro dieci — e la stessa di [ISSUES 51](ISSUES.md), dove un criterio vero di
una Chronicle sola passava per vero di tutte. Tre volte in due versioni: **un
numero aggregato non e' una misura, e' una media di misure che nessuno ha
guardato separatamente.**

### Tre difetti trovati per strada

- **«Pietra sopra Pietra»: 0 su 64 pescate**, tutte e quattro le case. Chiede
  una struttura di **grado 2 o piu'**. Il grado 2 esiste nei dati — Castello,
  Borgo, il Grande Granaio, la Dogana — ma **niente in partita ci arriva**.
  L'obiettivo e' scritto e aspetta una regola che non c'e': e' precisamente il
  buco che ISSUES 39 opzione **C** riempirebbe.
- **«L'Opera che Porta il Nome»: 4 su 68, il 5,9%.**
- **Il palese di Vaerax, «La Terra che Risponde»: 0 su 20.** Un palese che non
  si avvera mai e' una casa che gioca con tre carte invece che con quattro.

### E non e' un problema di Lyra: e' una regola dell'apertura

La stessa forma si ripete **nell'altra linea, con un'altra casa**. In CHR_03
`starting_structures` posa uno `STR_KEEP` alle Citta' Libere, alla Gilda del
Sale e alla Cenere. **All'Ordine del Vetro niente.**

| linea | la casa senza presidio d'apertura | NONE su 120 anni | TRIONFI |
|---|---|---|---|
| il Grano | **Lyra** | **44** | **0** |
| il Sale | **l'Ordine del Vetro** | **43** | 1 |
| (le altre tre, Grano) | Aldric / Nahr / Vaerax | 28 / 26 / 24 | 1 / 0 / 2 |
| (le altre tre, Sale) | Cenere / Libere / Sale | 14 / 20 / 29 | 1 / 2 / 1 |

E in tutte e due, fra le clausole del Minimo piu' spesso mancate c'e'
letteralmente **«Almeno un presidio suo»** — Lyra 18 volte, il Vetro 17.

**In tutte e due le linee, la casa che apre senza presidio e' la casa che non
vince mai.** Non e' una taratura di Lyra: e' il setup d'apertura che distribuisce
tre presidi su quattro e lascia scoperta la stessa casella in tutte e due le ere.

### Cosa non e' acceso

**Niente.** Le tre strade — dare alla casa scoperta una struttura d'apertura che
la racconti, togliere ai due obiettivi la gratuita' alzando la soglia, o
spostarla dove possa costruirsela ([D-208](#d-208)) — sono decisioni di
contenuto, e il numero e' scritto prima perche' si possa scegliere guardandolo.

E vale per **due** case, non per una: qualunque cosa si decida per Lyra va
decisa anche per l'Ordine del Vetro.

---

## D-208 — La mappa e' ferma perche' non ci sono pedine da muovere
**preventivo misurato in 0.1.176** — nessuna regola accesa, tre rimedi prezzati

Due rimedi per ISSUES 48 erano gia' stati misurati **a zero** — un Pedaggio
sulla Strada dei Mercanti e un cervello che conta anche i domini
([D-186](#d-186), [D-205](#d-205)). Due zeri di fila vogliono dire che la causa
non stava dove la si cercava. Il committente ha rifiutato la lettura
consolatoria («ogni era ha la sua Regione disabitata, e' il mondo che racconta
il secolo») e ha spostato la domanda dove andava: **perche' le pedine non si
muovono?**

Nessuna sonda lo sapeva dire. `run_move_probe` lo dice, e per ogni casa a fine
anno nomina **quale porta era chiusa**: il gettone, la carta, la porta, o la
voglia.

### La risposta, e non e' nessuna delle tre ipotesi della voce

Ogni casa comincia con **2 pedine** e il tetto e' **3**: ha **un** gettone di
riserva per tutto l'anno. Lo posa - 3,23 pose l'anno su quattro case - e da
quel momento non ha piu' niente da muovere. A fine anno **il 73% dei seggi ha
tutte le pedine sul tavolo**.

Le altre porte non sono il problema:

| porta chiusa | CHR_01 | CHR_03 |
|---|---|---|
| **il gettone** | **73,1%** | 71,9% |
| la carta | 12,5% | 7,5% |
| **la porta** (cacciata, segno, adiacenza, pieno) | **0%** | **0%** |
| la voglia | 14,4% | 20,6% |

Le carte MUOVERE abbondano: **12,57 viste in mano, 3,23 giocate**. E la riga
allo **0%** chiude da sola le tre ipotesi originali della voce, adiacenza
compresa: nessun seggio, in 80 partite, e' rimasto fermo perche' una porta era
sbarrata.

**E spostare non succede mai: 0,03 volte l'anno**, in ogni configurazione
provata. Non e' un difetto nuovo, e' [D-185](#d-185) che funziona: il cervello
non toglie una pedina da dove la casa vive, perche' misurato costava a Re
Aldric 8 NONE su 50. Con tutte le pedine posate MUOVERE **e'** uno spostamento,
quindi non si gioca. Il gioco ha due azioni diverse sotto lo stesso nome, e la
seconda e' morta.

**La Strada non e' povera: e' la Regione piu' ricca della mappa** - quattro
vicini su cinque, 4 slot, WEALTH + KNOWLEDGE, tre tag di dominio piu' `trade`.
Perde la corsa all'unico gettone perche' nessuno ci comincia.

### I tre rimedi, prezzati

| | oggi | tetto a 4 | Lyra sulla Strada | tutti e due |
|---|---|---|---|---|
| Strada, apertura → fine | 0,00 → 0,65 | 0,00 → 1,23 | 1,00 → 1,57 | **1,00 → 2,15** |
| Regione piu' povera a fine anno | 0,65 | 1,23 | 1,50 | **1,60** |
| MUOVERE l'anno | 3,23 | 4,58 | 3,23 | **4,65** |
| Consigli l'anno (unif. / misto) | 3,37 / 3,73 | 3,63 / 3,93 | 3,13 / 3,44 | 3,58 / 3,73 |
| Lyra NONE (unif. / misto) | 14 / 21 | non misurato | 9 / 8 | **8 / 9** |
| Lyra VITTORIE (unif. / misto) | 11 / 11 | non misurato | 27 / 27 | **25 / 28** |
| playtest 100 semi | 0/8 | 0/8 | 0/8 | **0/8** |

**Raccomandati tutti e due insieme**: e' la sola combinazione che vince su ogni
riga - la Strada diventa la seconda Regione piu' abitata, nessuna scende sotto
1,60, i Consigli tornano dove stavano, e il vincolo 0/8 regge.

E c'e' un effetto che non era stato cercato: **spostare Lyra sulla Strada cura
mezza [ISSUES 52](ISSUES.md)**. I suoi NONE crollano da 21 a 8 e le Vittorie
salgono da 11 a 27. Il seggio che in dodici saghe non aveva mai trionfato non
era debole: era **nel posto sbagliato**, e viveva a Eredan dove Re Aldric ha
gia' la parola.

### Cosa non e' acceso

**Niente.** Questo e' un preventivo: sposta la casa degli studiosi e cambia il
tetto delle pedine, e tutte e due sono decisioni di contenuto che il committente
deve prendere. Il numero e' scritto prima perche' possa deciderle guardandolo.

E una cosa che nessuno dei tre rimedi fa: **la mappa continua a non
disfarsi**. Allargano il rubinetto, non insegnano a ritirarsi da un posto. Se
«la mappa si muove» deve voler dire anche *lasciare*, serve una quarta leva che
questa misura non copre.

---

## D-207 — Anche l'anno d'apertura pesca le sue domande
**implemented in 0.1.175**

«Le domande non dovevano essere pescate random all'inizio di una saga? Ogni
saga doveva partire in modo diverso.»

**Meta' della risposta era «lo fanno gia'», e l'altra meta' dava ragione al
committente.** La pesca esiste da D-028 e funziona: su 12 saghe da 10 Chronicle
la biblioteca tira fuori **14 mani di domande diverse su 15 possibili**, la
pesca che ascolta (D-079) porta al tavolo l'81% delle candidate richiamate da un
segno, e le saghe finiscono a **distanza 0,86** l'una dall'altra sulle frasi che
scrivono. Ma la pesca cominciava dall'**anno 2**: `CHR_01` e `CHR_03` avevano le
domande scritte a mano, quindi **ogni saga del Grano cominciava dalle stesse
quattro domande e ogni saga del Sale dalle stesse cinque**, per sempre.

Le sonde non lo dicevano perche' nessuna guardava l'apertura: un primo anno
identico si perde dentro dieci, e la distanza media resta alta comunque. Il
metro nuovo lo nomina — **mani d'apertura diverse** e **distanza al primo anno**
— ed e' cosi' che «1 mano su 12 saghe» e' diventato leggibile.

### Cosa cambia

- `CHR_01` pesca **4 candidate su 6**, `CHR_03` **5 su 6**. Il Sale ne pesca
  cinque e non quattro di proposito: pescarne quattro darebbe 15 aperture invece
  di 6, ma **cambierebbe la forma del suo anno per guadagnare combinazioni**, e
  quella e' una decisione di gioco che nessuno ha chiesto.
- **L'apertura si compone.** `opening_text` era un paragrafo scritto a mano che
  nominava le quattro domande: dare la biblioteca senza spezzarlo avrebbe fatto
  leggere al tavolo un anno che non stava giocando (D-030). Adesso la Chronicle
  tiene la **cornice** — l'anno, e cosa vale comunque — e ogni domanda porta la
  propria `opening_line`. Una domanda senza riga tace invece di mentire, e una
  guardia nuova impedisce che ne esista una.
- **Il sacchetto non si scrive piu' per nome.** Una `drift_distribution` scritta
  sulle quattro d'autore spingerebbe, in un anno che pesca la Febbre Bassa, una
  domanda che non e' sul tavolo. Le due Chronicle d'apertura lo lasciano
  comporre al motore sulla mano pescata, com'era gia' per le due di seguito.
- **Una biblioteca vuota e' l'assenza di biblioteca**, come `hand_refill: {}` e'
  l'assenza di ripescaggio (D-189): e' cosi' che i quattro piani scriptati
  dichiarano di essere storie della mano scritta a mano, insieme al sacchetto con
  cui sono stati scritti.
- **Il seguito di una Chronicle si dichiara** (`sequel_id`). Fino a ieri il
  criterio era «ha una biblioteca», vero per caso finche' solo le Chronicle di
  seguito ne avevano una. Con la biblioteca anche sull'apertura,
  `library_sequel_of("CHR_01")` avrebbe risposto `CHR_01`: **una saga avrebbe
  rigiocato la Carestia per dieci secoli** senza che niente segnalasse l'errore.

### I numeri

| | prima | dopo |
|---|---|---|
| aperture diverse, Grano (12 saghe) | **1** | **6** |
| aperture diverse, Sale (12 saghe) | **1** | **4** (su 6 possibili) |
| distanza al primo anno, Grano | 0,91 | **0,98** |
| distanza al primo anno, Sale | 0,93 | **0,98** |
| distanza media sulla saga intera | 0,86 | 0,86 — **invariata** |
| Consigli l'anno, tavolo uniforme | 3,59 | **3,37** |
| Consigli l'anno, tavolo misto | 3,97 | **3,73** |
| playtest 100 semi, misto e uniforme | 0/8 | **0/8** |

**Il prezzo, scritto:** i Consigli calano del 6%, e nella linea del Grano i NONE
salgono da 107 a 132 su 480 seggi-anno mentre i Trionfi scendono da 9 a 6. La
causa e' nominata: la Febbre Bassa e i Pozzi Bassi, quando escono, **non
arrivano a soglia con la sola Deriva** e producono meno Consigli delle quattro
d'autore. Il Sale non lo paga (NONE 103 → 102, Trionfi 5 → **9**), perche' le sue
sei candidate sono tarate piu' vicine fra loro. Il vincolo 0/8 regge su tutti e
due i tavoli, e il ritmo dell'anno resta la domanda aperta che era gia'
([ISSUES 51](ISSUES.md)).

### Quello che i test hanno insegnato, e che vale piu' del cambio

Tre difetti trovati facendo, tutti e tre della stessa famiglia — **una
dichiarazione applicata nel momento sbagliato**:

1. **La biblioteca si spegne prima che si peschi.** `play_classic()` la
   spegneva dopo `setup()`: la prima sessione di un test pescava, la seconda —
   trovando la dichiarazione gia' spenta — no, e **due esecuzioni dello stesso
   seme davano due partite diverse**. E' la terza volta che questa famiglia si
   presenta (D-184, D-198) e la prima in cui ha rotto il determinismo.
2. **Il piano si dichiara prima del setup, come fa la sonda.** La suite
   applicava gli override **dopo** `new_session()`, la sonda da riga di comando
   prima. Finche' nessun override toccava la pesca era invisibile; da oggi due
   la toccano, ed e' di nuovo la distanza fra la prova e la spedizione che
   D-188 aveva gia' pagato.
3. **Il criterio forte sulle soglie era vero di una Chronicle sola.** Il test
   che chiedeva «sacchetto piu' Ripple bastano ad arrivare a soglia» guardava
   solo l'anno scritto a mano. Misurato su tutta la biblioteca: sei domande su
   dodici non ci arrivano, **e non ci arrivavano gia' prima** in CHR_02 e
   CHR_04. Non era un difetto nuovo: era un test che non aveva mai guardato.

---

## D-206 — Il gioco a carte non aveva una storia perche' il riempitivo parlava il gioco di prima
**implemented in 0.1.174**

Da 0.1.156 il gioco si spedisce a carte, e i tre piani scriptati sono rimasti
tutti storie del §10 di prima — dichiarandolo nel dato (D-188), quindi
onestamente, ma lasciando il gioco vero **senza nessun racconto scritto a mano**.
Stava nella lista da sei versioni come «lavoro pulito, nessuna decisione
richiesta». Non era pulito: erano tre cose rotte, e nessuna era il piano.

**Uno: il formato non sapeva dire «cala una carta».** L'enum di
`sim_plan.schema.json` conosceva le sei azioni dirette e basta. Un piano nel
gioco a carte era **inesprimibile**.

**Due: la guardia chiedeva a ogni piano di essere una storia vecchia.**
`check_sim_plans_declare_their_economy` pretendeva la dichiarazione, e un test
pretendeva che il valore fosse `false` — «ogni piano e' una storia del §10 di
prima, e lo dichiara». Scritto quando era vero di tutti, era diventato una legge.
Ora ognuno **dice la sua**, e un piano nell'economia di adesso dichiara le regole
con cui e' stato scritto: cosi' il giorno che la Chronicle cambia ancora, la
storia continua a raccontare quella che raccontava.

**Tre, ed e' la ragione vera: il riempitivo parlava il gioco di prima.** Un piano
scrive le mosse che contano; le occasioni non scritte le riempie
`_fallback_action`, che provava **ACQUISIRE, poi MUOVERE, poi passo**. Nel gioco
a carte le prime due non si pronunciano, quindi ogni occasione non scritta
diventava una scelta illegale: **68 in una partita sola** — tante quante le
occasioni libere. Nessun piano nuovo poteva reggere, e il conto lo diceva senza
che nessuno lo leggesse.

Adesso, quando la Chronicle gioca a carte, il riempitivo **cala una carta**:
prova quelle in mano nell'ordine e gioca la prima che il resolver accetta. Se una
carta chiede un bersaglio le da' **la domanda piu' fredda**, perche' un
riempitivo non deve decidere l'anno — e col cancello del tavolo (D-203) scaldare
la piu' calda sarebbe esattamente decidere quale va al Consiglio.

**La storia, `plan_d_crown_calls` — «La corona chiama subito».** Aldric apre
l'anno col Diritto di Corona in mano e la Carestia gia' a tre: non aspetta i
gettoni, cala la carta e strappa il Consiglio **nello stesso gesto** (D-191). E'
il primo dell'anno e lo decide lui. Gli altri non hanno nessuna carta che sappia
prendere la parola — le quattro RIVENDICARE non sono ancora sparse, in quel
seme — e giocano quello che hanno: i Nahr spingono, Lyra e Vaerax guardano.

Il resto dell'anno lo fa il sacchetto: quattro Consigli in tutto, uno cade, due
lasciano un'Eco. E nessuno prende piu' di **due obiettivi su quattro**: e' l'anno
di chi ha parlato per primo, non di chi ha vinto.

**Zero scelte illegali**, e le attese scritte nel dato: quattro Consigli,
`SUCCESS_WITH_COST · FAILURE · SUCCESS · SUCCESS`, almeno due Eco e due Verita'.

**E una guardia in piu'**: il test dei piani adesso pretende **almeno una storia
per economia**. Senza, il gioco che si spedisce puo' tornare a non averne
nessuna, e come la prima volta non se ne accorgerebbe nessuno.

---

## D-205 — La Regione morta e' quella dove non comincia nessuno
**measured in 0.1.173** (due rimedi provati e respinti; una riga in piu' nella sonda)

ISSUES 48 diceva «la Strada dei Mercanti e' una Regione morta» e proponeva tre
ipotesi: nessun Destino la chiede, non ci si arriva, non rende. Rimisurando col
gioco di adesso, **tutte e tre sbagliano bersaglio**.

**Il primo numero**: la Strada e' passata da **0,6% a 3,3%** delle pedine senza
che nessuno la toccasse — l'ha alzata il gioco a carte, dove stare in una Regione
decide cosa peschi.

**Il secondo numero e' quello che spiega tutto:**

| | Carestia (CHR_01) | Sale (CHR_03) |
|---|---|---|
| Strada dei Mercanti | **3,3%** | **13,8%** |
| Terre Nahr | 13,5% | **1,7%** |

**La Strada non e' morta: e' morta in un'era sola.** Nel Sale e' la terza piu'
affollata, e li' la Regione morta sono le **Terre Nahr**, all'1,7% — peggio di
quanto la Strada sia mai stata.

**La causa**: le pedine si posano all'apertura e durante l'anno si muovono
pochissimo, quindi la mappa di fine anno e' quasi quella di partenza. La Regione
vuota e' **quella in cui non comincia nessuno**, e cambia da un'era all'altra
perche' a cambiare sono le case. Non e' una proprieta' della Strada: e' una
proprieta' del **posto libero**.

**Due rimedi provati, misurati, respinti.**

1. **Un Pedaggio sulla Strada.** La struttura giusta esisteva gia' nel catalogo
   (`STR_TOLLGATE`, «Pedaggio», famiglia OPERA) e **non stava su nessuna mappa** —
   la strada dei mercanti non aveva un pedaggio, il che era anche un buco di
   finzione. Messo: **3,3% prima, 3,3% dopo**.
2. **Un cervello che conta anche i domini.** `_widen_the_tap` sceglieva dove
   andare contando solo le **famiglie nuove**, cioe' meta' del valore di un
   posto: stare in una Regione serve anche a influenzare gratis le domande del
   suo dominio, e la Strada ne ha tre. Contati: **3,3% prima, 3,3% dopo**.

Il perche' del doppio zero e' lo stesso: quel ramo vive **solo col gettone di
riserva** (D-185), quindi si gioca una volta per partita e per seggio. Qualunque
cosa gli si insegni, sposta una pedina su tre.

**Tutti e due tolti.** Un cambiamento che non muove nessun numero, tenuto, e'
peggio di una misura scritta: il prossimo lettore lo trova e crede che serva a
qualcosa. Il Pedaggio tornera' il giorno che la mappa si riscrive per davvero.

**Quello che resta e' una riga nella sonda**: `run_hand_probe` adesso **nomina**
la Regione in cui non comincia nessuno, invece di lasciarla dedurre da una
classifica. Sulla Carestia dice la Strada dei Mercanti; sul Sale dice le Terre
Nahr.

**E la voce cambia forma**: non «la Strada e' morta», ma «ogni era ha una Regione
dove non vive nessuno, e quella resta vuota». Da decidere se e' un difetto o se
e' la mappa che racconta chi c'era in quel secolo — la strada fra le case deserta
nell'anno della Carestia e piena nell'anno del Sale e' una cosa che il mondo
dice, non un buco.

---

## D-204 — Due case su otto non potevano chiamare il Consiglio
**implemented in 0.1.172** (ISSUES 37, nella forma nuova che ISSUES 49 le ha dato)

ISSUES 37 lo aveva scritto in anticipo: *«fatto quando le rivendicazioni morte
scendono sotto una su tre — **o quando ISSUES 49 arriva e questa azione diventa
quella che gira i mucchi coperti, e allora la domanda cambia forma**»*.

E' arrivata, e la forma e' cambiata. Col cancello del tavolo (D-203) il Consiglio
si apre a gettoni: **RIVENDICARE e' l'unico modo che un giocatore ha di aprirlo
quando vuole lui**. Quindi la prima domanda non e' piu' «quante prenotazioni
muoiono in mano»: e' **chi ha mai avuto in mano il diritto di chiamare**.

**La misura, che non avevo mai preso**, su 40 Chronicle — carte RIVENDICARE
arrivate in mano, per seggio e per partita:

| casa | prima | dopo |
|---|---|---|
| Aldric | 2,80 | 3,30 |
| Sale | 1,95 | 2,60 |
| Lyra | 1,45 | 2,50 |
| Nahr | 1,25 | 2,05 |
| Città Libere | 1,50 | 1,65 |
| Vaerax | **0,25** | 1,50 |
| Cenere | **0,00** | **1,05** |

**La Cenere non l'aveva mai avuta. Zero volte in venti partite.** E il Vaerax una
ogni quattro. Le due case della montagna non potevano, materialmente, chiedere al
tavolo di riunirsi — in un gioco dove quella e' la sola leva che un giocatore ha
sull'orologio.

**Perche'**: RIVENDICARE stava su **4 carte delle 48, tutte AUTORITA'**, e
l'AUTORITA' si pesca solo da Eredan e dalle Terre Nahr (D-186). Chi tiene le
montagne e le miniere pesca FORZA, LEGAMI, SAPERE — e nessuna delle tre sapeva
prendere la parola. Non era una scelta di progetto: era il residuo di quando
l'azione si comprava con un Asset invece di stare su una carta.

**Il rimedio, quattro carte spostate**, scelte perche' la finzione ci stava gia'
dentro:

| carta | famiglia | era | ed e' |
|---|---|---|---|
| **Assedio** | FORZA | INFLUENZARE +1 | *«un assedio non chiede il permesso di parlare»* |
| **Debito Vecchio** | LEGAMI | TRAMARE | *«conosce le stanze in cui e' stato contratto»* |
| **Deposizione Sigillata** | SAPERE | INFLUENZARE +1 | *«aperta, obbliga il tavolo a riunirsi»* |
| **Portavoce** | GENTE | INFLUENZARE −1 | *«prende la parola al posto della folla»* |

Otto carte RIVENDICARE in **cinque famiglie**, e **ogni Regione della mappa** ne
pesca almeno una. Il mazzo passa da 17/11/8/8/4 a **14 INFLUENZARE, 11 MUOVERE, 8
RIVENDICARE, 8 FORGIARE, 7 TRAMARE**.

**E le prenotazioni morte scendono, ma non abbastanza**: da 18 aperte / 6 forzate
/ 12 morte (**67%**) a 18 / 8 / 10 (**56%**). Il criterio di ISSUES 37 chiede
sotto il 33%, quindi quella meta' **resta aperta** — e va detto che il 67% di
partenza era gia' peggio del 41% di 0.1.159, perche' col cancello del tavolo i
Consigli sono meno e una prenotazione ha meno occasioni di essere riscossa.

**Il numero che vale la pena guardare non e' quello.** Lo scarto fra la casa che
puo' chiamare piu' spesso e quella che puo' meno passa da **infinito** (0,00
contro 2,80) a **3,1 volte** (1,05 contro 3,30). Prima c'erano due case escluse
da una regola del gioco; adesso ce ne sono otto che la possono usare, alcune piu'
di altre.

**Cancello**: 408 test verdi, playtest **0 su 8** a tavolo misto e uniforme,
Consigli 3,59 e 3,97 (erano 3,46 e 4,00: il rimedio non ha spostato il ritmo).

**E la sonda adesso conta le carte invece di crederci**: `run_rung_probe` leggeva
«4 carte, tutte AUTORITA'» da una riga battuta a macchina. Ora legge il mazzo.

---

## D-203 — Una soglia sola per il tavolo, e il tre che non vale piu' tre
**implemented in 0.1.171** (ISSUES 49 fase 2, scelta **b** del committente)

«Una soglia sola per il tavolo, non una per domanda.» Il Consiglio non lo chiama
piu' la singola Tensione che supera il proprio numero: si apre quando sul tavolo
sono scesi **tanti gettoni in tutto**, e a dibattersi va **il mucchio piu' alto**.
Poi il conto riparte da zero.

**La regola, dichiarata come tutte le altre**: `tension_tokens.table_gate`. A
zero, o assente, decide la soglia di ciascuna come sempre. Il contatore
`world["tokens_in_bag"]` sta fra le eccezioni all'effect-sourcing insieme a
`confluence_count`: e' il verbale di quello che e' gia' successo, non uno stato
da disfare.

### Il numero che il committente aveva scelto non vale piu' quel numero

Il preventivo di D-190 aveva misurato **«un segnalino ogni 3 riproduce il ritmo
di oggi: 5,95 Consigli l'anno contro 5,90»**, e il committente aveva scelto 3.
Quella misura era stata presa nel **gioco di prima**, con 18 azioni l'anno per
seggio. Adesso si gioca a carte e le azioni sono un terzo: i gettoni che cadono
in un anno sono dieci, non trenta.

| cancello | Consigli l'anno |
|---|---|
| 1 | 4,85 · 5,15 |
| 2 | **3,46 · 4,00** |
| 3 (il numero scelto) | 3,02 · 3,50 |
| 4 | 2,75 · 3,18 |
| 5 | 2,62 · 3,03 |
| *oggi, a soglie* | *6,03 · 6,01* |

**E il tre non passa le guardie.** `test_library_balance` chiede che un anno di
biblioteca stia fra 2 e 8 Consigli: col tre, due anni su dodici in CHR_02 e tre
su dodici in CHR_04 finiscono a **uno**. `test_year_end_floor` trova un seme che
chiude l'anno con un Consiglio solo. Col due passano tutte.

**Quindi ho spedito il due**, e scrivo il numero invece di nasconderlo: non e' il
numero che il committente aveva scelto, ed e' scelto perche' il suo non regge le
guardie che il gioco ha gia'. La sostanza della scelta **b** — un cancello solo
per il tavolo, il mucchio piu' alto che vince — resta intera.

**Il prezzo, dichiarato**: il Consiglio passa da **6,03 e 6,01** l'anno a **3,46 e
4,00**. Da due per Atto a poco piu' di uno. E' il cambiamento piu' grosso al
ritmo dell'anno da quando le carte sono diventate l'unica moneta, e si torna
indietro con **una chiave** (`table_gate: 0`). Il cancello tiene: **0 su 8** a
tavolo misto e uniforme.

**Perche' e' meno, e non e' un difetto**: a soglie possono essere mature piu'
domande insieme e le altre si mettono in coda; col cancello del tavolo ogni
apertura consuma **tutto** il calore accumulato. Il Consiglio smette di essere
routine e torna a essere un evento — che e' quello che la proposta del
committente diceva fin dall'inizio: *«a un certo punto, quando parte la
Confluence, si girano»*.

**E l'innesco a chiamata c'e' gia'**: chi ha una rivendicazione matura la spende
e apre il Consiglio sulla domanda che vuole, senza aspettare i gettoni
([D-191](#d-191)). Anche quello svuota il sacchetto, ed e' giusto: il tavolo si
raffredda quando qualcuno lo fa parlare.

### Quello che una persona legge, cercato invece che aspettato (§5ter)

Col cancello del tavolo **la soglia della singola domanda non apre piu' niente**,
e stamparla sarebbe la bugia piu' semplice del gioco: si legge «4/7» e si aspetta
il sette, che non succede. Tre posti sistemati:

* **il verbale pubblico** diceva `Carestia: 4/7`. Ora dice `Carestia: 4` e segna
  **quale mucchio e' il piu' alto** — l'unica informazione che decide qualcosa.
* **`visible_tension_threshold`** torna **−1** col cancello acceso, cosi' nessun
  pannello puo' scrivere quel numero anche volendo. Pannello del seggio, console
  e tavolo passano tutti di li'.
* **la pagina delle regole** prometteva *«quando una arriva alla sua soglia si
  apre un Consiglio»* ed elencava le domande con la soglia scritta accanto. Ora
  dice che la soglia per domanda non c'e', quanti gettoni aprono il Consiglio, che
  si dibatte il mucchio piu' alto, e che **un Consiglio lo puoi aprire anche tu**.

**E una guardia perche' non resti un numero morto**:
`check_the_gate_and_the_thresholds_do_not_overlap` rifiuta una Chronicle che
dichiari `table_gate` e `threshold_bonus` insieme. Il ritocco di D-192 esisteva
per alzare una soglia che adesso non apre nessun Consiglio: tenerlo sarebbe un
numero che non fa niente e che il prossimo lettore proverebbe a tarare — l'ora
peggio spesa di tutte. Tolto da tutte e quattro le Chronicle.

**Non fatto**: i mucchi **coperti**. Il cancello e' la meta' che cambia *chi
decide quando*; coprire i valori cambia *cosa si sa*, e va misurato a parte —
soprattutto adesso che il verbale dice il mucchio piu' alto, che e' proprio
l'informazione che coprire toglierebbe.

---

## D-202 — Il Sale conta anche lui, e la carta della terra torna a costare qualcosa
**implemented in 0.1.170**

D-201 ha portato il mondo del Sale alle carte e ha lasciato scritto perche' non
gli accendeva anche gli obiettivi: i suoi Destini erano i piu' facili di tutti, e
il palese sarebbe tornato a essere un vantaggio distribuito alla nascita. Questa
voce chiude quel conto e accende il punteggio anche li'.

**Il palese nel mondo del Sale, per casa** (media del pool, 200 Chronicle):

| casa | prima | dopo |
|---|---|---|
| Cenere | **68,5%** | 49,3% |
| Città Libere | 64,0% | 47,9% |
| Sale | 55,2% | 45,1% |
| Vetro | 37,5% | 35,6% |
| **scarto** | **31,0 punti** | **13,7 punti** |

Meglio del 19,6 con cui e' rimasta la prima saga.

**Tre cambiamenti, e il primo e' un errore mio di due voci fa.**

1. **`DST_SHARED_LAND` giurata dalla Cenere: 100%.** Non era cosi' prima: era
   all'11,5%, e l'ho portata al 100% **io**, in D-199, allargando quella carta
   («due Regioni tenute *o* due cose in piedi») per aiutare Vaerax, che l'aveva
   al 16,7%. Ho aggiustato un estremo e ne ho creato uno peggiore dall'altra
   parte. **E' la prova piu' netta della regola che avevo appena scritto**: una
   carta che conta *il tuo tavolo* non puo' costare uguale a chi ha un tavolo
   diverso, e allargarla non la rende equa — la sposta. Quindi la Cenere passa a
   «Il Nome che Pesa», che guarda i Consigli e costa 38–57% a chiunque lo giuri.
2. **`DST_LIBERE_WATER`** (96,3% → **48,1%**). Chiedeva un segno globale e la
   presenza dove le città stanno gia': la stessa forma di `DST_NAHR`, lo stesso
   prezzo. Ora chiede anche che **il mondo non sia stato aperto in piu' di due
   punti** — l'acqua non torna dove si è combattuto. Due tentativi prima di
   questo (un'opera loro, due terre che bevono) non l'avevano mossa di otto
   punti: quelle cose le Città ce l'hanno quasi sempre.
3. **`DST_SALE_OPEN`** (67,9% → **42,9%**). «Il registro si può leggere» e non
   chiedeva che i conti fossero chiusi. Ora sì.

**Una guardia che ha morso mentre lavoravo**, e vale la pena scriverlo: alzando
la Vittoria dell'Acqua ho reso vera una delle strade del suo Trionfo, e
`check_destiny_free_roads` (D-178) l'ha detto subito — *«chiede 2 strade su 4, ma
1 sono gia' vere per il livello victory: in pratica ne chiede 1 su 3»*. La strada
è stata stretta a un segno solo. Senza quella guardia il Trionfo sarebbe
diventato piu' facile mentre rendevo la Vittoria piu' dura, in silenzio.

**Il tavolo intero, adesso che tutte e quattro le Chronicle contano** (800 seggi):

| obiettivi presi | quanti seggi |
|---|---|
| 0 su 4 | **18,5%** |
| 1 su 4 | 33,2% |
| 2 su 4 | 35,1% |
| 3 su 4 | 11,2% |
| 4 su 4 | **1,9%** |
| media | **1,45** |
| punteggio di saga | **+1,56** |

Cancello: **0 su 8** a tavolo misto e uniforme, Consigli 6,03 e 6,01.

**E un numero di contenuto e' sceso, dichiarato**: la seconda saga pesca **10**
Destini invece di 11, perche' «La Terra che Risponde» ha lasciato il pool della
Cenere e in quel mondo non la giura piu' nessuno. Resta giurata da Vaerax nella
prima saga. Ho preferito scrivere il numero piu' basso che inventare una carta
nuova per far tornare un conteggio.

---

## D-201 — Il mondo del Sale passa alle carte, e una saga smette di giocare a due giochi
**implemented in 0.1.169**

Due cose, e la prima e' un buco che stava li' da due versioni.

### Una saga giocava a due giochi

**CHR_02 contava i gradini mentre CHR_01 contava gli obiettivi.** Sono i due anni
della stessa saga, con gli stessi seggi, e il punteggio di campagna sommava le
due scale **senza dirlo** — perche' il livello con gli obiettivi si *deriva*
(D-198) e a valle sembra identico. Una campagna di dieci anni avrebbe alternato
un anno dove non prendere niente e' possibile e un anno dove il Minimo lo
raggiungono tutti, e il totale non l'avrebbe mai raccontato.

Ogni regola nuova e' arrivata dichiarandosi sulla Chronicle, e ogni volta c'era
**una seconda Chronicle** da accendere insieme alla prima. Le carte, il
rubinetto, la presa di parola e il sacchetto erano stati accesi in tutte e due;
gli obiettivi no, e nessuna guardia lo chiedeva.

**`check_a_saga_plays_one_game`**: le Chronicle vengono appaiate per **lista dei
seggi** — gli stessi seggi sono la stessa saga — e sei regole confrontate. Non
serve che i numeri coincidano: serve che una regola accesa da una parte non sia
spenta dall'altra. Provata a morso sul caso vero.

### Il mondo del Sale passa alle carte

CHR_03 e CHR_04 erano gli ultimi due anni al §10 di prima, e la cosa bloccava
tutto il resto: il sacchetto non si poteva accendere li' perche' ACQUISIRE era
due terzi delle azioni e avrebbe scaldato il mondo otto volte la Deriva (D-190).

Acceso tutto insieme — carte, rubinetto, presa di parola in un colpo, sacchetto —
perche' le meta' si accendono insieme o si misura un terzo gioco che nessuno
gioca (D-184). E la misura intermedia vale la pena di scriverla: **con le sole
carte i Consigli erano crollati a 5,01 e 4,81** l'anno (da 6,15 e 6,30), perche'
meno azioni vuol dire meno INFLUENZARE e meno soglie superate. Il sacchetto e' la
meta' che rimette il calore.

**E il +1 alle soglie che CHR_01 aveva chiesto e' sbagliato per CHR_03.**
D-192 aveva misurato che il sacchetto aggiunge il 7% del calore in CHR_01, e
aveva alzato le soglie di 1. Nel mondo del Sale lo stesso +1 soffoca l'anno:

| `tension_tokens.threshold_bonus` | Consigli in CHR_03 |
|---|---|
| 1 (come CHR_01) | **3,90** l'anno |
| 0 | **5,55** l'anno |

Con lo zero il tavolo torna dov'era: **6,05 e 6,04** Consigli l'anno contro i
6,15 e 6,30 di prima, **0 su 8** su tutti e due i tavoli. E' esattamente il
genere di numero che una dichiarazione per Chronicle esiste per portare: due
mondi che postano calore diverso non vogliono la stessa soglia.

**La mano del Sale, col rubinetto acceso**: 6,00 → 6,66 → **6,79** carte di atto
in atto, e lo scarto fra la mano piu' piena e la piu' vuota **non cresce** (0,00 →
1,07 → 0,60) — meglio dell'1,58 di CHR_01. Il freno di D-185 e' sulla mano, e
funziona anche qui.

**Quello che manca ancora al Sale**: gli obiettivi. Non li ho accesi di
proposito, perche' i suoi Destini sono i piu' facili di tutti (Cenere 65,8% ·
Vetro 71,8% · **Libere-Acqua 96,3%**) e accenderli adesso rimetterebbe in campo
il difetto che D-199 ha appena chiuso — il palese come vantaggio distribuito alla
nascita. Prima i Destini, poi il punteggio.

---

## D-200 — Il quarto obiettivo pagato come una cosa rara
**implemented in 0.1.168** (una riga di dati, e due guardie perche' resti vera)

D-199 ha reso il palese piu' equo e, per farlo, piu' caro: il punteggio di saga
era sceso da +1,51 a +1,30 per seggio. Ho scritto il numero peggiorato invece di
compensarlo di mia iniziativa, e il committente ha deciso: **compensare un po'**.

`objectives.saga_points` per CHR_01: **−1 · 1 · 2 · 5 · 8** (era −1 · 1 · 2 · 4 ·
6). Misurato su 200 Chronicle: **+1,45 per seggio**, contro i +1,30 di prima e i
+1,51 di prima ancora. **Recuperati tre quarti**, e il quarto che manca resta il
prezzo dichiarato di un palese che costa uguale a tutti.

**Dove ho messo i punti, e perche' li'.** La distribuzione non e' cambiata di un
seggio — questa e' solo la scala dei numeri — quindi si trattava di scegliere
*quali* risultati pagare meglio. Ho pagato **il terzo e il quarto obiettivo**:
sono i due che quasi nessuno prende (10,8% e 1,8%), e un trionfo che capita a un
seggio su cinquantacinque deve valere piu' del doppio di «due su quattro», o non
vale la pena inseguirlo. I due estremi restano dove il committente li aveva
messi: un anno senza niente **toglie**, e prenderne uno vale poco.

**Due guardie, perche' la scala e' un posto dove si sbaglia in silenzio.**
`levels` e `saga_points` sono indicizzate dal conto, e il motore satura
sull'ultima casella: una delle due scritta piu' corta non fa nessun errore —
fa valere **uguale due risultati diversi**, e nessuno se ne accorge leggendo il
verbale. `check_objective_scales_are_sane` pretende che siano lunghe quanto il
conto (zero compreso) e che i punti **salgano**: una scala che scende sarebbe un
refuso che paga chi fa peggio, e si vedrebbe solo a fine saga. Provate a morso
tutte e due, piu' un test che legge i **dati spediti** e chiede che ogni
obiettivo in piu' valga piu' del precedente.

---

## D-199 — Il palese pagato quasi uguale da tutte le case
**implemented in 0.1.167** (dati: quattro Destini, un pool, una carta condivisibile)

Il difetto che D-196 aveva trovato per strada e che D-198 ha acceso lo stesso,
dichiarandolo: **il palese vale un quarto del risultato, e non costava uguale a
tutti**. Un vantaggio distribuito alla nascita, prima che qualcuno giochi.

**La misura che conta non e' per Destino, e' per casa.** Una casa non sceglie
quale dei tre Destini del suo pool le tocchi, quindi il numero onesto e' la
**media del suo pool** — quanto le costa il palese, in media, quest'anno.
Misurato su 200 Chronicle, stessi semi, prima e dopo:

| casa | prima | dopo |
|---|---|---|
| Aldric | 40,2% | **41,8%** |
| Nahr | **80,9%** | 54,2% |
| Lyra | 52,5% | **34,6%** |
| Vaerax | 37,7% | 34,7% |
| **scarto fra la piu' cara e la piu' facile** | **43,2 punti** | **19,6 punti** |

**Meno della meta'.** Sul singolo Destino lo scarto va da 66,8 a 55,8 punti: meno,
ma resta grande, e i due estremi sono nominati piu' sotto.

**Le quattro cose cambiate, e perche' quelle:**

1. **`DST_NAHR_ROOTED`** (86,2% → 44,8%). Chiedeva **un** segno di non essere di
   passaggio, fra tre. Ora ne chiede due. Un solo segno non e' radicarsi.
2. **`DST_LYRA_TAUGHT`** (84,6% → 35,9%). Si chiama *«Quello che Resta
   Insegnato»*, la sua Vittoria si chiama *«Il sapere ha un posto suo»*, e **il
   posto non lo chiedeva**: una scoperta e le gallerie aperte, nient'altro. Ora
   chiede anche un posto — una pietra sua o una terra che le risponde.
   *(La prima stesura chiedeva solo la pietra e l'ha portato al 20,5%: troppo. La
   scelta fra le due strade e' la correzione di quella correzione.)*
3. **`DST_SHARED_LAND`** e' una carta che giurano tre case diverse, e costava
   **83,9% a Nahr, 27,8% a Vaerax, 11,5% a Cenere**: sette volte tanto. Ora la
   terra puo' rispondere in due modi — due Regioni tenute **o** due cose in piedi
   — perche' «controllare due Regioni» non e' una difficolta', e' una posizione
   di partenza.
4. **Il pool di Nahr**: `DST_SHARED_LAND` → `DST_SHARED_ACCOUNTS`. Nahr aveva tre
   Destini di terra su tre, e il terzo era il piu' facile dei tre. E qui c'e' la
   regola generale che ho imparato misurando: **una carta condivisibile costa
   uguale a tutti solo se parla del mondo, non del tuo tavolo**. I Conti Chiusi
   guarda i segni globali e infatti costa 42,3% a Lyra e 45,2% a Nahr; La Terra
   che Risponde conta le *tue* Regioni, e allora il prezzo e' la tua posizione di
   partenza travestita da ambizione.

**`DST_NAHR` resta a 72,5%, e non l'ho aggiustato.** Ci ho provato due volte —
chiedendo un insediamento costruito, poi un borgo o due pietre — e il numero non
si e' mosso di un punto: quello che costa in quel Destino sono le sue **prime due
clausole** (il segno `nahr_settled` e la presenza nella Valle Verde), e cambiarle
vorrebbe dire riscrivere cosa quel Destino *significa*, non quanto costa. Preferisco
lasciarlo scritto qui che spostarlo con una clausola che non c'entra niente.
Stessa cosa per **`DST_SHARED_LAND` giurata da Vaerax, al 16,7%**: e' l'estremo
basso, e Vaerax non tiene Regioni per come e' fatto.

**Il prezzo, dichiarato.** Rendere il palese piu' equo lo ha reso in media piu'
caro, e il gioco piu' duro:

| | prima | dopo |
|---|---|---|
| 0 obiettivi su 4 | 16,5% | **20,8%** |
| 4 su 4 | 2,2% | **1,8%** |
| media obiettivi per seggio | 1,51 | **1,37** |
| punteggio di saga | +1,51 | **+1,30** |

Non ho compensato con `saga_points`, che sarebbe stato facile: prima va deciso se
questa e' la durezza giusta. Il cancello tiene comunque — **0 su 8** a tavolo
misto e uniforme, Consigli 6,15 e 6,30.

**Quello che non e' stato toccato**: i Destini di CHR_03 (Cenere 65,8% · Vetro
71,8% · Libere-Acqua **96,3%**). Quel mondo gioca ancora a gradini, dove il
prezzo della Vittoria significa un'altra cosa: si tocca quando passa agli
obiettivi, non prima.

---

## D-198 — Gli obiettivi al posto dei gradini, accesi
**implemented in 0.1.166** (la regola vive, ed e' una dichiarazione della Chronicle)

D-196 ha misurato il prezzo, D-197 ha scritto il pool. Questa e' la regola che
gira: CHR_01 non sale piu' una scala, **conta**.

**La dichiarazione, come tutte le altre** (`hand_refill`, `tension_tokens`,
`claim_rules`): sta nella Chronicle, e una Chronicle che non la scrive gioca coi
tre gradini di sempre.

```json
"objectives": {
  "hidden": 3,
  "public_from": "victory",
  "levels": ["NONE", "MINIMUM", "VICTORY", "VICTORY", "TRIUMPH"],
  "saga_points": [-1, 1, 2, 4, 6]
}
```

**`levels` e' la scelta che tiene in piedi tutto il resto.** Il livello non
sparisce: si **deriva** dal conto. Toglierlo sarebbe stato il modo piu' rapido
per rompere il verbale, il pannello del giocatore, il libro della saga, il
salvataggio e il punteggio di campagna — leggono tutti un livello, e cinque
consumatori riscritti in un colpo sono cinque posti dove sbagliare. Cosi'
invece la parola resta quella che ha sempre voluto dire (chi arriva a VICTORY ha
tenuto anche MINIMUM), e cambia solo **come ci si arriva**.

**`saga_points` e' la meta' che il livello non sa dire.** Il committente ha
chiesto che i successi parziali diano *numeri* diversi: due obiettivi e tre
obiettivi sono entrambi VICTORY, ma valgono 2 e 4. Dichiarati, i punti vincono
su `saga_scoring`.

**Il palese non e' salvato da nessuna parte, ed e' voluto**: e' il Destino
giurato letto al gradino che la Chronicle dichiara. Salvarlo avrebbe creato una
seconda verita' da tenere allineata al `destiny_id`, che la successione cambia
fra un anno e l'altro (D-045). Sul seggio stanno solo i **tre coperti**.

**Il dado degli obiettivi e' a parte** da quello dei Destini, che era gia' a
parte da quello della partita (D-150): se pescasse dallo stesso, accendere gli
obiettivi cambierebbe *quale Destino* ogni casa giura, e i due esperimenti non
sarebbero piu' confrontabili.

**Quello che il gioco conta davvero**, misurato su 100 Chronicle (i 200 seggi di
CHR_01, semi 7000–7099):

| obiettivi presi | l'ombra prevedeva | il gioco conta |
|---|---|---|
| 0 su 4 | 16,2% | **19,0%** |
| 1 su 4 | 32,0% | 34,5% |
| 2 su 4 | 31,5% | 32,5% |
| 3 su 4 | 17,5% | 11,5% |
| 4 su 4 | 2,8% | **2,5%** |
| media | 1,58 | **1,44** |
| saga per seggio | +1,65 | **+1,42** |

**La previsione era ottimista del 9%**, e la differenza e' dichiarata: la sonda
misurava i seggi di **tutte e due** le Chronicle e pescava i coperti da un dado
suo, mentre qui gioca solo CHR_01 col dado del mondo. Il verso dell'errore e'
quello buono da sapere — il gioco vero e' un po' piu' duro di quanto il
preventivo prometteva, non piu' facile.

**E la scala di oggi, come effetto**: NONE 10,0% · MINIMUM 41,8% · VICTORY 38,8%
· TRIUMPH 9,5% sui 400 seggi delle due Chronicle insieme (contro 0,8 · 48,2 ·
34,2 · 16,8 di prima). Il cancello tiene: **0 su 8** a tavolo misto e uniforme,
Consigli 6,04 e 6,06.

**Il lato umano, cercato invece che aspettato** (§5ter, la lezione di D-195). Tre
posti dove una persona legge:

* **il pannello del seggio** e **la console** mostravano tre gradini. Ora
  mostrano i quattro obiettivi, coi coperti segnati `(coperto)` — sono i *suoi*,
  quindi li vede (D-101: la scala la vede solo chi la giura).
* **la riga del verbale** diceva l'etichetta di un gradino. Con gli obiettivi
  sarebbe stata la bugia piu' facile di tutta la regola — stampare «Il regno
  decide» a chi quel Destino non l'ha chiuso — quindi dice il conto e quali:
  *«Re Aldric — VICTORY: 3 obiettivi su 4 (…)»*.
* **la pagina delle regole** prometteva una scala. Ora dice che non si sale, si
  conta, e il numero degli obiettivi condivisi lo prende dal pool.

E i tre punti li decide **una funzione sola**, `objectives_of()`: due letture
diverse dello stesso seggio erano il difetto piu' facile da introdurre qui, ed e'
esattamente quello che D-194 aveva gia' pagato una volta con la mano.

**Un errore trovato solo guardando la pagina.** La prima stesura del paragrafo
nuovo aveva un errore di precedenza fra `+` e `%`: la formattazione andava in
errore a **ogni apertura della pagina**, e la suite era **verde**, perche'
nessun test leggeva quel testo. Tre test nuovi lo coprono adesso. E' §5ter alla
lettera, la seconda volta di fila: *nessuna misura copre quello che una persona
vede, se non si guarda quello che vede*.

**Il lato classico si spegne intero.** `play_classic()` non poteva limitarsi a
cancellare la dichiarazione: `setup()` era gia' passato e aveva gia' pescato i
coperti sul seggio. Una regola spenta e tre obiettivi scritti nel mondo sono
**due meta' di due giochi diversi** — lo stesso errore che D-184 aveva gia'
pagato col rubinetto — e la prova e' arrivata subito: due test di determinismo
sono diventati rossi perche' la prima sessione pescava e la seconda no.

**I tre piani scriptati dichiarano su quale scala si leggono** (`objectives: {}`,
la scala di sempre), come gia' dichiarano l'economia: una storia scritta a mano
finisce dove finisce, e rileggerla contando obiettivi vorrebbe dire darle un
esito che il suo autore non ha scritto. La guardia
`check_sim_plans_declare_their_economy` lo pretende.

**Difetto aperto e dichiarato**: il palese non costa uguale a tutte le case
(35,7%–80,0% fra gli otto Destini identitari, D-197). Ho acceso la regola con
questo difetto dentro invece di aspettare, perche' riscrivere otto Destini e'
un lavoro sui **dati** che si misura meglio con la regola accesa — e perche'
tenerla spenta avrebbe lasciato dodici obiettivi validi e irraggiungibili. Resta
il punto 1 di ISSUES 50.

**Non fatto**: CHR_03 non dichiara ancora `objectives`. Il mondo del Sale non e'
ancora passato nemmeno alle carte, e accendergli il punteggio nuovo prima
dell'economia nuova vorrebbe dire misurare un terzo gioco che nessuno gioca —
la stessa ragione di D-184.

---

## D-197 — Il pool degli obiettivi, dodici carte misurate una per una
**implemented in 0.1.165** (i dati e le guardie; il motore non e' ancora cambiato)

D-196 aveva detto che il pool non c'era: sei candidati, uno dei quali si avvera
nell'1,8% dei seggi, e sei sono pochi per pescarne tre — uscirebbe mezzo pool
ogni partita e il draft non sceglierebbe niente. Questa e' la prima meta' del
lavoro: **il pool, scritto come dato e misurato una carta per volta**.

**Un obiettivo non e' un Destino, e ora non lo e' nemmeno nei dati.** Nuovo
schema `objective`: id, titolo, descrizione, **la riga che va a verbale**, e una
lista di clausole. Nessun gradino. Un Destino dice fin dove si sale; un
obiettivo si avvera o no, e a fine anno si contano.

**Dodici obiettivi, tassi misurati su 100 Chronicle (400 seggi, semi
7000–7099), tavolo misto:**

| obiettivo | cosa chiede | si avvera |
|---|---|---|
| Qualcosa che Resta in Piedi | una pietra sua | 79,0% |
| Il Muro che Tiene | un presidio | 74,8% |
| Le Mani Piene | 5 carte a fine anno | 44,0% |
| Nessuna Domanda Lasciata Aperta | il mondo senza questioni aperte | 39,0% |
| Due Terre, una Voce | 2 Regioni controllate | 37,2% |
| Il Nome che Pesa | il segno della fama | 29,8% |
| Le Cose Scritte | 2 carte Sapere a fine anno | 25,2% |
| Un Mondo che si Può Ancora Usare | non più di 2 cicatrici | 22,0% |
| L'Opera che Porta il Nome | un'opera | 21,0% |
| Pietra sopra Pietra | una struttura di grado 2 | 14,2% |
| Le Cose che si Sanno | 2 scoperte | 11,8% |
| Le Corde che Tengono | 2 Legami a fine anno | 10,2% |

Nessuno sotto il 10%, nessuno sopra l'80%: il criterio che D-196 aveva posto.
Media 34,0%.

**E la distribuzione cambia di brutto rispetto al preventivo.** Con un palese e
tre pescati da questo pool invece che dai sei vecchi candidati:

| obiettivi presi | col vecchio pool (D-196) | con questi dodici |
|---|---|---|
| 0 su 4 | 27,2% | **16,2%** |
| 1 su 4 | 36,2% | 32,0% |
| 2 su 4 | 21,5% | 31,5% |
| 3 su 4 | 12,8% | 17,5% |
| 4 su 4 | 2,2% | **2,8%** |
| media | 1,26 | **1,58** |
| punteggio di saga | +1,17 | +1,65 |

Il NONE resta vero (16,2% contro lo 0,8% dei gradini di oggi) ma smette di
essere il caso piu' probabile dopo l'uno; il trionfo resta raro. **Non ho
toccato nessuna soglia per ottenerlo**: sono cambiate solo le carte del pool.

**Due obiettivi bocciati coi numeri**, e vale la pena scriverlo perche' sono
esattamente i due che sembravano piu' belli:

* *«La Parola Data»* (nessun giuramento spezzato nel mondo) — **100%**. Il segno
  `oath_broken` non lo posa quasi nessuno: era un regalo travestito da scrupolo.
* *«Il Mondo Intatto»* (zero cicatrici) — **2,0%**. Arredo: nessuno l'ha mai
  visto da vicino. La stessa idea a due cicatrici sta al 22%, e quella e' entrata.

**Il vocabolario e' ristretto per forza, e la guardia lo dice.** Un obiettivo del
pool lo pesca chiunque in qualunque Chronicle: se una clausola nomina
`ENT_ALDRIC`, `REG_EREDAN` o `TEN_FAMINE`, nel mondo del Sale e' **falsa per
costruzione** — e un obiettivo che non si avvera mai assomiglia in tutto a un
obiettivo difficile. `check_objectives_are_shareable` fa rosso la CI; il test
`test_objective_pool.gd` prova la stessa cosa dal lato del motore, piu' che ogni
predicato sia uno che `ConditionEvaluator` sa davvero valutare. Restano fuori
`relation_state` e le promesse, che hanno bisogno di nominare l'altro.

**Una seconda guardia, per un difetto che non e' ancora successo**: il
vocabolario delle clausole ora e' scritto **due volte** (in `destiny.schema.json`
e in `objective.schema.json`, perche' gli schemi sono file autoconsistenti).
`check_condition_vocabularies_agree` confronta le due copie: il giorno in cui una
impara un predicato e l'altra no, la CI lo dice prima dei dati.

**Correzione a D-196.** Avevo scritto che il palese va «dal 41% di Aldric al 91%
delle Libere». Il 91% e' `DST_LIBERE_WATER`, un Destino **variante**; fra gli
otto Destini identitari lo scarto e' **35,7%–80,0%** (Lyra 35,7 · Libere 38,9 ·
Aldric e Sale 41,2 · Vaerax 43,8 · Cenere 70,0 · Vetro 77,8 · Nahr 80,0). La
frase era difendibile — un seggio puo' giurare una variante, e allora quello *e'*
il suo palese — ma il numero che conta per riscrivere i Destini e' il secondo.

**Quello che questa voce non fa**: il motore. Nessuna partita pesca ancora
obiettivi, nessun anno si chiude contandoli, i tre gradini sono ancora la scala
di §14. I dodici obiettivi esistono, sono validi, sono misurati e non sono
raggiungibili da nessuna regola — di proposito: **il pool e' il preventivo che
diventa dato**, e il motore e' la voce dopo.

---

## D-196 — Il prezzo dei quattro obiettivi al posto dei tre gradini
**measured in 0.1.164** (preventivo: nessuna regola cambiata)

Il committente ha chiuso la domanda che avevo lasciato aperta: **gli obiettivi
sostituiscono i gradini**. «Se si ottengono tutti e 4 è un trionfo, se non se ne
raggiunge nessuno è un NONE, gli altri sono successi parziali, e vittorie che
danno numeri alla fine della saga.»

Come per il sacchetto (D-190), prima di riscrivere §14 ho misurato: una sonda
ombra, `godot/cli/run_objective_probe.gd`, che **non cambia nessuna regola**.
Gioca le partite come sono e a fine anno legge il mondo una seconda volta,
chiedendogli cose che il gioco non gli chiede: quante volte si sarebbe avverato
ciascun obiettivo candidato, seggio per seggio.

**Come ho tradotto i dati di oggi in obiettivi, e perché.** Un Destino oggi ha
tre gradini; se i gradini spariscono, il suo contenuto deve collassare in *un*
traguardo. Il candidato per il **palese** è la **Vittoria** — quello per cui la
casa è venuta al tavolo. Il Minimo no: D-150 ha già stabilito che il Minimo è
sopravvivere, non un obiettivo, e infatti lo raggiungono tutti. Il **pool
nascosto** sono i Destini condivisibili di D-115 (`$self`, scritti apposta per
essere giurati da chiunque), letti come due obiettivi ciascuno.

**Su 100 Chronicle, 400 seggi, semi 7000–7099, tavolo misto:**

| dove si arriva | oggi | coi quattro obiettivi |
|---|---|---|
| niente | 0,8% | **27,2%** |
| primo scalino | 48,2% | 36,2% |
| in mezzo | 34,2% | 34,3% |
| tutto | 16,8% | **2,2%** |
| punteggio di saga | +2,51 | +1,17 |

**Il numero che decide**: il NONE passa da 3 seggi su 400 a **109**. Non è un
ritocco al punteggio, è il ritorno della possibilità di perdere — che oggi, di
fatto, non c'è.

**E la sonda ha trovato un difetto che non stavo cercando**: il palese non costa
uguale a tutte le case. Letto come Vittoria del Destino scritto va dal **41% di
Aldric al 91% delle Libere**. Se il palese vale un quarto del risultato, quello
scarto è un vantaggio distribuito alla nascita — e va deciso se è un difetto o se
è l'asimmetria di ECHOES che arriva fino al punteggio (ISSUES 50, punto 2).

**Quello che il pool non può ancora fare**: i candidati esistenti sono sei, e uno
(`DST_SHARED_LAND/triumph`) si avvera nell'**1,8%** dei seggi — è arredo. Sei
sono pochi per pescarne tre: metà del pool uscirebbe ogni partita e il draft non
sceglierebbe niente. Ne servono almeno dodici, e nessuno sotto il 10% o sopra
l'80%.

**Dichiarato non misurato** (§5ter): il draft. Scegliere un obiettivo guardando
gli altri scegliere è una decisione umana, e il cancello gioca solo con
`PolicyDecider`. La sonda pesca a caso — che è il caso peggiore per la varietà e
il migliore per l'onestà del numero.

La mappa dei numeri proposta dalla sonda (0 → −1, 1 → 1, 2 → 2, 3 → 4, 4 → 6)
tiene i due estremi di `saga_scoring` e riempie in mezzo. **È una proposta da
bocciare o correggere, non un dato**: è scritta nel codice della sonda, non nei
dati del gioco, proprio perché nessuno la scambi per una regola.

---

## D-195 — Quello che una persona legge, riscritto dalle regole
**implemented in 0.1.163** (§5ter: il seguito di D-194, cercato invece che aspettato)

D-194 aveva trovato **un** posto in cui l'interfaccia era rimasta al gioco di
prima. La lezione era che nessuna misura copre quel lato, quindi il seguito non
poteva essere una sonda: e' stato guardare, uno per uno, i posti dove una regola
nuova cambia **cio' che una persona legge**. Ce n'erano altri tre.

### a) Il menu offriva di scoprire una cosa gia' visibile

*«Scopri il numero di Il Risveglio»* — ma da D-187 il velo copre la **soglia**,
e il numero e' sul tavolo. Il menu invitava a buttare un'Occasione per sapere
una cosa gia' saputa. Adesso dice *«Scopri a quanto esplode»*, e *«Copri la
soglia»* al posto di *«Cala il velo»*, quando e' quello che il velo fa.

### b) Il sacchetto cambiava il mondo in silenzio

Il gettone di D-192 applicava il suo Effetto e **non diceva niente**. Una persona
calava una carta e una domanda si scaldava senza una riga a verbale — mentre la
Deriva, che il sacchetto sostituisce, lo ha sempre detto. Adesso: *«Il gettone
cade su La Carestia: sale di 1.»* E' D-030 — ogni mutazione si racconta — e
l'avevo rotta senza accorgermene.

### c) La pagina delle regole prometteva il gioco di tre versioni fa

E' la piu' grossa. `help_panel.gd` e' **la pagina che un giocatore legge dentro
l'app**, e diceva:

- *«Un'azione e una di queste sei cose»* — no, e' una carta calata;
- *«Acquisire — peschi una carta di una famiglia»* — non esiste piu';
- *«Tramare — leggi il numero di una domanda velata»* — e' la soglia;
- *«Rivendicare — ti prenoti il diritto»* — su una domanda matura la prendi adesso.

**In cima a quel file c'era gia' scritto perche' e' successo**: *«una pagina di
regole che puo' sfasarsi dalle regole e' peggio di niente, e le parti che possono
sfasarsi sono quelle che vengono dai dati»*. Meta' della pagina si scriveva dai
dati e non e' sfasata di una virgola. L'elenco delle azioni era **battuto a
macchina**, ed e' esattamente quello che ha mentito.

Adesso si scrive dalle regole anche quello: legge `actions_from_cards`,
`hand_refill`, `claim_rules`, `veiled_tensions`, `tension_tokens`, e dice cio'
che quella Chronicle fa davvero — compreso il cuore del gioco nuovo, *«calarla
per agire la spende, e quella carta non votera' piu'»*.

### Le misure

Playtest **identico riga per riga**: `FAIL 253 · 111 · 127 · 113`, Consigli 6,04,
mediana 6, **0 su 8**. Nessuna di queste e' una regola: sono le parole con cui il
gioco si spiega. Suite **384 test / 6713 asserzioni**, con quattro prove nuove
che leggono la pagina **dai due lati dell'interruttore**.

### Quello che si dichiara

- **Ho guardato tre posti, non tutti.** Ho seguito le tre regole nuove — velo,
  rubinetto, sacchetto — dentro `seat_decider`, le viste e la pagina delle
  regole. Non ho riletto l'intero testo dell'app: **e' un campione ragionato,
  non un inventario**.
- **La pagina delle regole ora ha una prova, il registro no.** Le quattro prove
  nuove tengono la pagina attaccata alle regole; che il registro racconti ogni
  mutazione resta affidato alla disciplina, come prima.
- **`MECCANICA.md` e la pagina dell'app dicono adesso la stessa cosa**, ma per
  due strade diverse: il documento e' scritto a mano, la pagina si genera. Il
  documento puo' ancora sfasarsi.
- **Il committente ha trovato in un minuto quello che tre versioni di misure non
  hanno visto.** Vale la pena riscriverlo: le sonde guardano cosa fa il gioco,
  non cosa dice.

---

## D-194 — I bot erano passati alle carte, le mani no
**implemented in 0.1.162** (trovato dal committente guardando l'app)

*«Ma su Pages non e' cambiato nulla, mi sembra una vecchia versione.»*

**Pages era aggiornato.** Il workflow ha pubblicato dopo ogni merge — l'ultimo,
run 280, ha deployato `e790485` alle 21:33 con esito verde. Quello che il
committente vedeva vecchio **era il gioco**: il menu delle azioni proponeva
ancora *«Acquisisci una carta AUTORITA'»*, *«Metti una presenza in…»*, e se le
si sceglieva il resolver le rifiutava un istante dopo.

### La causa, ed e' mia

D-188 ha spostato il divieto delle sei azioni dirette **da `check()` a
`execute()`**, per la ragione giusta: `check()` risponde a *«sarebbe legale?»*,
la domanda che un seggio si fa prima di sapere con quale carta lo dira'.

Ma il menu umano si costruisce **proprio con `check()`**, e da quel giorno
`check()` ha smesso di dire di no. Ho migrato il cervello dei bot
(`policy_decider`) e ho lasciato indietro le mani: `seat_decider._action_options`
offriva il gioco di prima a chiunque giocasse davvero.

Il commento sopra quella funzione prometteva: *«ogni azione legale, gia'
verificata contro le regole, cosi' una persona non si vede mai offrire qualcosa
che il resolver rifiutera'»*. La promessa era rotta da tre versioni.

### Come e' fatto adesso

Le sei azioni restano il vocabolario — sono cio' che un seggio *puo' voler fare*
— e l'elenco si costruisce come sempre. Poi, se la Chronicle dice che si fanno
con le carte, ogni voce viene offerta **una volta per ogni carta in mano che sa
dirla**, e quelle che nessuna carta sa dire spariscono:

```
«Mercenari» — Metti una presenza in Valle Verde
«Editto» — Rivendica il dominio TERRITORIO
```

Un punto solo, e copre tutte e tre le superfici: lo schermo del tavolo, il
terminale e la console del telefono passano tutti da `SeatDecider`.

### Il test che non poteva accorgersene

Ne esisteva gia' uno per questa promessa — *«il menu non offre mai cio' che le
regole rifiutano»* — e **e' rimasto verde per tre versioni**: chiede
`can_execute`, cioe' `check()`, ed era proprio `check()` ad aver smesso di
rifiutare. Il test nuovo guarda dal lato giusto: sotto l'economia delle carte
**nessuna voce del menu porta un template diretto**, e ogni voce offerta viene
davvero eseguita. Tolta la correzione, morde: nove asserzioni rosse con lo stesso
messaggio che il committente ha visto sull'app.

### Le misure

Playtest **identico riga per riga**: `FAIL 253 · 111 · 127 · 113`, Consigli 6,04,
mediana 6, **0 su 8**. E' giusto che lo sia — i bot non passano da questo menu.
Suite **380 test / 6674 asserzioni**.

### Quello che si dichiara

- **Nessuno se n'era accorto perche' nessun bot usa quel menu.** Il playtest,
  che e' il cancello di casa, gioca solo con `PolicyDecider`. La misura non
  copriva la cosa che il committente guarda, e non c'e' sonda che lo faccia:
  l'ha trovato aprendo l'app, come i nove difetti piu' grossi di questo progetto.
- **Il rischio e' strutturale, non un caso**: ogni volta che una regola si sposta
  fra `check()` ed `execute()`, il menu umano cambia senza che nessuna misura lo
  dica. La guardia nuova copre il caso delle carte; **non copre il prossimo**.
- **Il velo, il rubinetto e il sacchetto non sono stati riguardati** dallo stesso
  punto di vista: sono regole che cambiano cosa una persona vede, e sono state
  provate solo dal lato dei bot.

---

## D-193 — La mano non sapeva dire meta' di quello che il seggio voleva
**implemented in 0.1.161** (la prima voce di CONSEGNE §5bis)

Da quando le carte sono l'unica moneta, il **62% delle Occasioni resta muto**.
Il numero era scritto ma non scomposto, e scomporlo era tutto il lavoro.

### Dove finiscono 720 turni

| | |
|---|---|
| il cervello non voleva niente | **235** (33%) |
| voleva qualcosa **che la mano non sapeva dire** | **214** (30%) |
| qualcosa e' successo | **271** (37%) |

E dentro i 214, la causa vera:

| | |
|---|---|
| INFLUENZARE, la carta spinge dalla parte sbagliata | 80 |
| INFLUENZARE, nessuna carta in mano | 60 |
| **TRAMARE, la carta fissa un modo diverso da quello che serve** | **38** |
| TRAMARE, nessuna carta in mano | 32 |
| RIVENDICARE / FORGIARE / MUOVERE | 4 |

### Le due cose fatte

**a) Il modo di TRAMARE e' libero.** Le otto carte SAPERE/LEGAMI fissavano
`REGION`, `TENSION` o `ECHO_DECK`, e un seggio che voleva scoprire una domanda
con in mano una carta da «leggi una Regione» passava il turno. E' D-184
riapplicato — *i parametri che la carta lascia aperti sono una scelta di chi la
gioca* — ed e' la terza volta che lo stesso difetto si ripresenta su una famiglia
diversa (le RIVENDICARE in D-191). **Mute di TRAMARE: da 56 a 15.**

**b) La FORZA aveva un solo verso.** Tre carte INFLUENZARE su tre, tutte **+1**:
una casa che tiene Eredan e le Montagne poteva solo scaldare il mondo, mai
raffreddarlo — e la mappa decide cosa peschi, quindi decideva anche che quella
casa non sapeva dire «no». Il Posto di Blocco adesso fa **-1**: *«la questione
si ferma dov'e'»*.

### Il difetto vero, trovato da un test

Le due modifiche hanno fatto rosso `test_library_balance`: **la Chronicle di
libreria faceva 2 Consigli mediani invece di 3-7.** La causa non erano le carte:
era il sacchetto di D-192, che leggeva la `drift_distribution` **scritta nella
Chronicle**. Una Chronicle di libreria pesca le sue domande da un pool e quella
distribuzione **non ce l'ha**: sacchetto vuoto, Deriva spenta perche' il
sacchetto la sostituisce, e l'anno non si scaldava mai.

Adesso il sacchetto e' la **traccia gia' mescolata** (`drift_track`), che esiste
in entrambi i casi perche' la costruisce il setup. E' anche piu' giusto: il
sacchetto e' quello del tavolo, non quello scritto sul libro.

### Le misure

`FAIL 253 · SUCC 111 · SUCC 127 · DECI 113`, Consigli media 6,04, mediana 6,
**0 su 8** a tavolo misto e uniforme. Suite **379 test / 6665 asserzioni**.

### Quello che si dichiara

- **Il totale delle Occasioni mute non si e' mosso**: 62% prima, 62% dopo. Le
  mute di TRAMARE sono crollate, ma i seggi hanno usato le Occasioni liberate per
  fare altro, e altre categorie si sono alzate. **Il numero grosso non e' un
  difetto da riparare**: e' la forma del gioco senza ACQUISIRE.
- **E il paragone onesto lo dice**: nel gioco di prima le azioni diverse da
  ACQUISIRE erano **3,2 per seggio all'anno su 18 Occasioni — il 18%**. Adesso
  succede qualcosa nel **37%** delle Occasioni. Il gioco a carte e' **piu'
  attivo** di quello che ha sostituito; quello che e' sparito e' il riempitivo.
- **Gli 80 «la carta spinge dalla parte sbagliata» non sono un difetto.** La
  Folla non argomenta: sale di 1. Se vuoi far scendere quella domanda, quella
  carta non e' la risposta — e passare e' la giocata giusta. Liberare anche il
  verso trasformerebbe ogni carta in un jolly e toglierebbe il carattere.
- **La FORZA resta sbilanciata**: due carte su tre spingono in su. E' voluto (e'
  la famiglia che scalda), ma non e' misurato quanto costi a una casa che tiene
  solo Regioni di FORZA.
- **CHR_03 non e' toccata.**

---

## D-192 — Il calore lo pescano i giocatori
**implemented in 0.1.160** (ISSUES 49, fase 1 — la scelta **b** del committente)

Il committente ha scelto: **una soglia sola per il tavolo**, non una per domanda.
Ma prima di poter chiedere «quanto deve essere caldo il mondo» serve che il mondo
si scaldi come lui ha detto — *«ogni carta o azione fa pescare un segnalino che
da' un valore a una tensione»*. Questa e' quella meta'.

### Come e' fatto

Ogni azione **riuscita** pesca un gettone dal sacchetto e lo posa: la domanda la
sceglie la stessa distribuzione della Deriva (`drift_distribution`, D-047), che
il committente ha gia' tarato, e il seme, quindi la partita resta rigiocabile. La
Deriva a orologio si spegne: i due insieme sarebbero un terzo gioco.

Vive solo se la Chronicle dichiara `tension_tokens`. Senza, non succede niente.

### Il preventivo di D-190 era sbagliato di due volte, e lo correggo

D-190 aveva misurato **18,7 gettoni l'anno** e ne aveva concluso «il mondo si
scalda 2,1 volte piu' in fretta». Sono **due errori**, e il primo li spiega
entrambi.

**Primo**: la sonda ombra contava *ogni firma d'azione distinta* nel registro
degli Effetti — e una carta giocata ne produce piu' d'una (l'azione interna, lo
spostamento di INFLUENZARE). La regola vera pesca **un gettone per azione**, e
sono **~10 l'anno**, non 18,7.

**Secondo, e piu' grosso**: paragonavo i gettoni ai **9 della Deriva**, come se
la Deriva fosse tutto il calore del mondo. Non lo e'. Misurato sul registro,
CHR_01 posa **35,9 punti di calore l'anno** — la Deriva ne mette 9, il resto
viene dai segni che sfogano, dagli effetti delle carte impegnate e dalle
Conseguenze. Il sacchetto ne aggiunge dieci e ne toglie nove: **il calore totale
cambia del 7%**, non del 210%.

Ecco perche' *«col sacchetto devi rivedere le soglie»* e' vero, ma **di uno, non
del doppio**.

### La taratura, misurata

| soglie | calore posato | Consigli in un anno (CHR_01) |
|---|---|---|
| il gioco di prima, senza sacchetto | 35,9 | **5,97** |
| col sacchetto, soglie invariate | 47,2 | 7,27 |
| col sacchetto, **+1** | 44,0 | **5,93** |
| col sacchetto, +2 | 45,7 | 5,67 |
| col sacchetto, ×2 | 38,3 | 3,33 |

**+1 riporta il ritmo esattamente dov'era** (5,93 contro 5,97). Il raddoppio —
che era la mia prima mossa, fatta sul numero sbagliato — dimezzava i Consigli.

**Il ritocco sta sulla regola, non sulla Tensione** (`threshold_bonus`): la stessa
Tensione gioca anche dove il sacchetto e' spento, e li' una soglia alzata non si
raggiungerebbe mai. Con le soglie riscritte nel dato, il gioco classico faceva
**zero Consigli** — l'ha trovato subito il test che prova che ogni Tensione possa
raggiungere la propria soglia.

### Le misure del cancello

```
FAIL 249 · SUCC 122 · SUCC 138 · DECI 126 · Consigli media 6,35 · mediana 6
0 su 8 bloccati (misto e uniforme)
suite 379 test / 6760 asserzioni · sim plans e determinismo verdi
```

### Due difetti miei, trovati dai test

- **Il gettone si firmava con la mano che aveva agito.** Riusando la firma
  dell'azione, un gettone posato da un INFLUENZARE si contava come un secondo
  INFLUENZARE, e **il tetto di §10 saltava**. L'ha trovato il test che
  ricostruisce i conti dal registro degli Effetti. Adesso il gettone porta una
  firma sua, `system/TENSION_TOKEN` — ed e' anche piu' vero: il calore e' del
  mondo, non della mano.
- **Il seggio e il Consiglio leggevano due soglie diverse.** Il ritocco lo
  applicava `TensionSystem.threshold()`, ma il seggio leggeva la soglia scritta
  dal dato: decideva su 6 mentre il Consiglio si apriva a 7. Adesso passano
  dallo stesso numero, e c'e' un test che lo prova.

### Quello che si dichiara

- **La scelta b non e' ancora costruita.** Questa e' la meta' del calore; la
  soglia sola per il tavolo — «finche' non sono scesi N gettoni nessuno puo'
  chiamare» — arriva quando i mucchi saranno coperti e l'innesco sara' a
  chiamata. Il numero misurato resta **tre gettoni**.
- **I gettoni non sono ancora coperti.** Il valore di una domanda si vede come
  sempre; il velo di D-187 copre la soglia. Coprire i mucchi e' fase 2, e li' il
  velo diventa inutile perche' tutto e' coperto per costruzione.
- **I 21 presagi e le 19 clausole dei Destini non sono stati toccati.** Col
  calore che cambia del 7% non era necessario — ma e' una decisione presa sul
  numero corretto, non un dimenticanza: se il sacchetto crescera' (piu' gettoni
  per azione, o gettoni da 2 e 3), vanno riscalati insieme.
- **CHR_03 non e' toccata**: li' il calore lo mette ancora l'orologio. E' il
  termine di paragone, e passera' al sacchetto solo dopo essere passata alle
  carte.
- **I Consigli falliti salgono da 239 a 249.** Il calore che arriva a raffiche
  invece che a orologio apre piu' tavoli nei round affollati, e li' si oppone
  piu' gente.

---

## D-191 — Non si prenota una domanda che e' gia' matura
**implemented in 0.1.159** (ISSUES 37, meta' aperta — decisione del committente su §10)

Il committente ha deciso tre cose: **gioco a carte**, **l'innesco lo apre un
giocatore**, e **col sacchetto le soglie vanno riviste**. La prima e' fatta
(D-188), la terza e' il lavoro grosso di ISSUES 49. La seconda non esiste finche'
RIVENDICARE muore in mano tre volte su quattro: **un innesco a chiamata non e'
un innesco se la chiamata non riesce mai.**

### La deroga

§10 vuole due tempi: si prenota un dominio in un round (CREATE, scartando un
AUTORITA') e si riscuote in un round successivo (FORCE, scartandone un secondo).
Chi rivendica deve quindi indovinare, un round prima, che la domanda sara'
matura, che nessun altro avra' gia' forzato, e di avere ancora una carta.

Da qui: se la Tensione e' **gia' matura** — al valore che §10 chiama forzabile,
3 — prendere la parola e' **un'azione sola**. Non si prenota cio' che e' gia'
pronto. La prenotazione resta per il caso vero: la domanda che *non* e' ancora
matura e che ci si vuole accaparrare prima che lo diventi.

E' dichiarata sulla Chronicle (`claim_rules.same_round_when_ready`, con
`ready_at`), non scritta nel codice: il §10 di sempre resta provato dai test e si
riaccende cambiando una riga.

### Il collo di bottiglia si e' spostato due volte, e l'ho misurato ogni volta

**Prima misura, la regola sola.** Su 720 turni il cervello vuole prendere la
parola **153 volte**, e con la deroga l'azione diretta sarebbe legale **153 volte
su 153** — la regola non rifiuta piu' niente. Ma i Consigli strappati non si
muovevano.

**Il secondo collo: le carte.** In mano c'era una carta RIVENDICARE 106 volte su
153, ma la mano sapeva dire **esattamente quella cosa** solo 51 volte: le quattro
carte AUTORITA' fissavano il modo, due CREATE e due FORCE. **Il modo e' stato
liberato**: e' D-184 applicato — *«i parametri scritti sulla carta vincono, quelli
che la carta lascia aperti restano una scelta di chi la gioca»*. Prenotare o
strappare lo decide chi cala la carta.

**Il terzo collo: la cautela del bot.** D-069 gli aveva insegnato a forzare solo
in un round che sarebbe rimasto muto, per non rubare il posto al Consiglio a
soglia. Quella cautela proteggeva **una prenotazione**, e con la deroga non c'e'
piu' niente da proteggere. Adesso, quando la Chronicle concede il colpo solo, il
seggio strappa una domanda matura senza aspettare — ed e' esattamente cio' che il
committente ha chiesto — e **non prenota piu' cio' che e' gia' maturo**.

### Le misure

Su CHR_01, 40 partite, contando i Claim nel registro degli Effetti:

| | prima | dopo |
|---|---|---|
| prenotazioni aperte | 73 | **27** |
| prenotazioni riscosse | 16 | **16** |
| **morte in mano** | 57 (**78%**) | **11 (41%)** |

Il cancello regge: `FAIL 239 · 100 · 134 · 126`, Consigli media 5,99, mediana 6,
**0 su 8** a tavolo misto e uniforme. Suite **374 test / 6555 asserzioni**.

### Quello che si dichiara

- **Il criterio di ISSUES 37 non e' raggiunto.** Chiedeva le morte **sotto una su
  tre**; siamo a **41%**, da 78%. Quasi dimezzate, non abbastanza. La meta' resta
  aperta.
- **Ho provato a chiuderlo togliendo del tutto la prenotazione** al bot quando la
  deroga e' accesa: le morte vanno a **zero**, ma **zero e' anche il numero di
  prenotazioni**. Non e' una regola risanata, e' una regola sparita — e i Consigli
  falliti salivano da 239 a 252. Respinta coi numeri.
- **Ho provato anche a impedire al ripiego di giocare una carta RIVENDICARE alla
  cieca** (senza bersaglio prenota un dominio a caso): comprava due punti
  percentuali di morte in meno e costava **19 Consigli falliti in piu'**.
  Respinta coi numeri.
- **CHR_03 non e' toccata**: li' §10 e' quello di sempre e le prenotazioni
  muoiono ancora al 78%. E' il termine di paragone.
- **La misura precedente era contaminata e l'ho corretta.** La sonda dei gradini
  alterna CHR_01 e CHR_03, quindi meta' del campione veniva dal mondo dove la
  regola e' spenta: i primi numeri che avevo letto (80 aperte, 21 forzate)
  mescolavano due giochi. I numeri qui sopra sono **CHR_01 da sola**.
- **Forzare un Consiglio non e' un Effetto**: `world["forced_confluence"]` si
  scrive a mano, ed e' una delle poche mutazioni senza inverso. Non l'ho toccata,
  ma con l'innesco a chiamata diventera' il cuore del turno, e li' andra' fatta
  come si deve.
- **Il passo dopo e' ISSUES 49**, e questa deroga ne e' il primo mattone: quando
  saranno i mucchi coperti a dire quale domanda si dibatte, sara' **questa**
  l'azione che li gira.

---

## D-190 — Il prezzo del sacchetto dei segnalini coperti
**misurata in 0.1.158** (nessuna regola cambiata: e' il preventivo di ISSUES 49)

Il committente ha proposto di rifare le Tensioni: *«ogni carta o azione fa
pescare uno o piu' segnalini coperti che danno un valore a una tensione. A un
certo punto, quando parte la Confluence, si girano, e la tensione col punteggio
piu' alto viene dibattuta nel Consiglio.»*

### La prima cosa da dire: il sacchetto esiste gia'

La Deriva **e' gia' un sacchetto**: nove gettoni mescolati col seme
(`drift_distribution`, D-047), pescati uno per round. La proposta non introduce
un oggetto nuovo — cambia **chi pesca** (i giocatori agendo, non il mondo a
orologio) e **quando si guarda** (al Consiglio, non subito). La sonda misura
tutte e due le cose senza toccare una regola.

### a) Quanto si scalderebbe il mondo

| | CHR_01 (gioco a carte) | CHR_03 (§10 di prima) |
|---|---|---|
| segnalini in un anno, tutto il tavolo | **18,7** | **72,4** |
| il mondo si scalda, col sacchetto piatto | **2,1 volte** piu' in fretta | **8,0 volte** |
| ...col sacchetto misto (1/2/3) | **3,6 volte** | **14,1 volte** |

**E' la misura che decide la regola.** Il sacchetto funziona **solo nel gioco a
carte**: li' le azioni sono poche e ognuna pesa, quindi 18,7 segnalini contro i
9 della Deriva e' un raddoppio governabile. Nel §10 di prima ogni ACQUISIRE
scalderebbe il mondo, e ACQUISIRE era **due terzi di tutto**: settantadue
segnalini in un anno, otto volte la Deriva. Le due riprogettazioni — le carte e
i segnalini — **hanno bisogno l'una dell'altra**.

Il sacchetto misto e' fuori scala in entrambi i mondi: 3,6 volte in CHR_01
significa rifare tutte le soglie, non ritoccarle.

### b) Su quali domande finiscono, e quanto e' storto il mucchio

Il Risveglio prende 6,68 segnalini l'anno contro i 3,83 della Carestia — ed e'
**giusto cosi'**: e' la composizione del sacchetto che il committente ha gia'
tarato (3 gettoni su 9 sono suoi). Ma lo scarto fra il mucchio piu' alto e il
piu' basso cresce: **3,07 -> 4,15 -> 5,02** di Atto in Atto. Girare i segnalini
all'Atto 3 sarebbe spesso una formalita': una domanda ha gia' vinto.

### c) I tre inneschi, in numeri

| innesco | Consigli in un anno (CHR_01) |
|---|---|
| a orologio, fine Atto | 3,00 |
| a orologio, fine round | 9,00 |
| a quantita', ogni **3** segnalini | **5,95** |
| a quantita', ogni 4 segnalini | 4,27 |
| a quantita', ogni 6 segnalini | 2,67 |
| **il gioco di oggi (a soglia)** | **5,90** |

**Un segnalino ogni tre riproduce esattamente il ritmo di adesso** — 5,95 contro
5,90 — e lo fa con una regola che al tavolo si conta a occhio: tre gettoni
scesi, si gira. E' il candidato migliore fra quelli misurati.

### d) E la domanda che conta: sarebbe un gioco diverso?

Su **354 Consigli veri**, il mucchio coperto avrebbe scelto **la stessa domanda
il 31% delle volte** (il 23% in CHR_03). Sette volte su dieci si dibatterebbe
qualcos'altro.

**Non e' colore: e' un altro gioco.** Non dice che sia peggiore — dice che non
si puo' accendere «per vedere come va», perche' cambia quali storie il mondo
racconta.

### Quello che si dichiara

- **La sonda non cambia niente**, come il preventivo di D-183: gioca le partite
  come sono e tiene un mondo ombra a fianco. I numeri sono quindi *quanti
  segnalini scenderebbero*, non *come andrebbe la partita*: con la regola accesa
  i seggi agirebbero diversamente, e questa sonda non lo sa.
- **L'innesco «a chiamata» non e' misurato**, ed e' quello che mi sembra
  migliore: il Consiglio lo apre un giocatore. Non e' misurabile con una sonda
  ombra perche' dipende da una decisione che oggi nessun bot puo' prendere —
  serve prima la regola. Nota che salderebbe ISSUES 37: RIVENDICARE, che oggi
  muore in mano tre volte su quattro, diventerebbe **il motore delle Tensioni**.
- **Il sacchetto ombra pesca a caso, uniformemente.** La proposta dice «ogni
  carta o azione fa pescare»: se invece e' **la carta** a dire quale domanda si
  scalda, il mucchio smette di essere casuale e diventa una scelta — un gioco
  ancora diverso, e non misurato qui.
- **Niente e' stato provato con quattro persone.** Questa regola vive o muore
  sulla sensazione di guardare un mucchio che cresce senza poterlo contare, e
  quella e' esattamente la cosa che un bot non prova.

---

## D-189 — Un piano scriptato dice in che economia e' stato scritto
**implemented in 0.1.157** (riparazione di D-188, trovata dalla CI)

D-188 ha acceso le carte come unica moneta in CHR_01 e ha dichiarato che i tre
piani scriptati «sono storie del §10 di prima e restano tali». **Era una frase,
non una regola**: i piani leggono la Chronicle spedita, e la Chronicle spedita
adesso gioca a carte. `tools/run_sims.sh` e' uscito con **exit 4** su tutti e
tre, e la CI e' andata rossa.

### E la suite diceva verde

La distanza fra le due strade e' il vero difetto. La suite passa dal
`play_classic()` che D-188 ha messo in `new_session()`, quindi provava il gioco
vecchio; la sonda da riga di comando legge il dato spedito, quindi provava
quello nuovo. **Due strade che provano due giochi diversi e si chiamano
entrambe «i piani passano».**

### Come e' fatto adesso

Un piano dichiara la propria economia nel dato: `chronicle_overrides`, con
`actions_from_cards` e `hand_refill`. I tre piani di CHR_01 dichiarano
`actions_from_cards: false` — sono storie del §10 di prima, e adesso lo dicono
loro invece che un verbale.

Le due strade passano dalla **stessa funzione**, `GameSession.apply_plan_overrides`,
statica apposta: la suite e la sonda applicano le stesse righe. E una guardia in
`validate_data.py` chiude la porta: se la Chronicle gioca a carte e il piano non
dichiara niente, la CI e' rossa **prima** di giocare.

### Quello che si dichiara

- **Il difetto e' mio, e la CI l'ha trovato al posto mio.** Avevo lanciato
  `tools/run_sims.sh` mandando l'output a `/dev/null` e avevo guardato **solo se
  i file cambiavano**, non l'exit code. Il comando diceva «FALLITO (exit 4)» tre
  volte e io non l'ho letto. La regola di casa che ne esce e' scritta in
  CONSEGNE: dei comandi del cancello si guarda **l'exit code**, non l'output.
- **Resta vero che manca un piano scriptato del gioco a carte** (D-188). Adesso
  la mancanza e' dichiarata *nel dato*, non solo in un verbale: i tre piani
  dicono di essere storie vecchie, e nessuno dice di essere una storia nuova.
- **`chronicle_overrides` e' una porta che si puo' abusare**: un piano puo'
  riscrivere qualunque regola della Chronicle e poi dire che il gioco funziona.
  Lo schema la tiene stretta a due chiavi apposta.

---

## D-188 — Le quarantotto carte parlano: le azioni passano sulla mano
**implemented in 0.1.156** (ISSUES 47, fase 4 — il gioco nuovo si accende)

*«Togliamo tutte le azioni e le mettiamo sulle carte. Ogni carta ha una azione
di gioco, un valore per il consiglio, e effetti specifici della carta: il gioco
deve essere un bilanciamento di come usare le cose che la carta ti permette di
fare.»* Il telaio era di D-184, il rubinetto di D-185, la mappa di D-186.
Qui si scrive il contenuto e **si gira l'interruttore**.

### Le quarantotto

Ogni carta porta una delle cinque azioni che restano — ACQUISIRE sparisce,
perche' era due terzi del gioco e adesso la fa la mappa. La distribuzione non e'
casuale: la Regione decide che carte peschi, quindi **la mappa decide che cose
puoi fare**.

| famiglia | porta | il suo mestiere |
|---|---|---|
| FORZA | 5 MUOVERE, 3 INFLUENZARE | prende terra |
| AUTORITA' | 4 RIVENDICARE, 3 INFLUENZARE, 1 FORGIARE | l'unica che prende **la parola** |
| GENTE | 4 INFLUENZARE, 3 MUOVERE, 1 TRAMARE | si sposta e preme |
| SAPERE | 5 TRAMARE, 2 INFLUENZARE, 1 MUOVERE | gli occhi |
| RICCHEZZA | 3 FORGIARE giu', 3 INFLUENZARE, 2 MUOVERE | compra e rompe |
| LEGAMI | 4 FORGIARE su, 2 TRAMARE, 2 INFLUENZARE | l'unica che **stringe** |

**17 INFLUENZARE, 11 MUOVERE, 8 TRAMARE, 8 FORGIARE, 4 RIVENDICARE.** Le quattro
RIVENDICARE stanno tutte su AUTORITA' perche' quell'azione *chiede* di scartare
un AUTORITA': la carta e' la propria spesa, e il conto torna solo li'.

### Le tre cose che il motore ha dovuto imparare

**a) La carta e' la propria spesa.** Tre azioni su cinque chiedono di scartare
un Asset. Senza una regola, giocare una carta per farle ne costava **due**:
quella giocata e quella scartata. Adesso la carta paga se stessa, e resta vero
che una carta spesa non votera' piu'.

**b) Il divieto stava nel posto sbagliato.** D-184 aveva messo il rifiuto delle
azioni dirette in `check()`. Ma `check()` risponde a *«questa azione sarebbe
legale?»*, ed e' la domanda che un seggio si fa **prima** di sapere con quale
carta la dira': col divieto li', i seggi smettevano di volere qualcosa e
**496 Occasioni su 720 restavano mute**. Il divieto vive ora in `execute()`.

**c) Il cervello resta lo stesso, cambia chi pronuncia.** Il decider sceglie
l'intenzione come sempre; uno strato nuovo cerca in mano la carta che la dice,
e spende **la piu' debole che sa farlo** — la forte serve al voto. Se
l'intenzione non e' dicibile prova le seconde scelte dello stesso cervello prima
di passare. E ha imparato una voce nuova, che e' la conseguenza diretta di
D-185: **allargare il rubinetto**, cioe' posare il gettone di riserva dove la
mappa offre una famiglia che non si raggiunge.

### Le misure

Interruttore acceso su CHR_01 e CHR_02, col rubinetto tarato in D-186
(`per_token: 2, floor: 2, cap: 6, hand_cap: 7`):

```
FAIL 235 · SUCC 99 · SUCC 122 · DECI 121 · Consigli media 5,77 · mediana 6
0 su 8 bloccati (misto e uniforme) · nessuna azione rifiutata
suite 371 test / 6716 asserzioni
```

E la cosa per cui tutto questo e' stato fatto — **la divergenza di ISSUES 47
punto 2 e' chiusa a gioco acceso**, non piu' solo in preventivo:

| scarto fra la mano piu' piena e la piu' vuota | Atto 1 | Atto 2 | Atto 3 |
|---|---|---|---|
| il gioco di oggi (ACQUISIRE) | 0,00 | 2,77 | **4,90** |
| **il gioco a carte** | 0,00 | 1,10 | **1,58** |

Fabbisogno misurato a gioco acceso: **9,81 carte l'anno** per seggio, contro le
11,80 del preventivo. Il rubinetto ne da' abbastanza.

### Due difetti trovati misurando, non leggendo

- **Il distratto chiedeva un'azione che non esiste piu'.** Il suo «ogni tanto fa
  un'altra cosa» era scritto come un ACQUISIRE a caso: acceso l'interruttore, se
  lo vedeva rifiutare **93 volte su 20 partite**, e i suoi NONE passavano da 1 a
  **8**. Adesso la distrazione ha la forma giusta per questo gioco: spende **la
  carta sbagliata**, non pesca la famiglia sbagliata.
- **Re Aldric si portava via da solo la presenza a Eredan.** La voce nuova
  «allarga il rubinetto» spostava una pedina per raggiungere una famiglia in
  piu' — e con tre gettoni gia' posati MUOVERE *sposta* invece di aggiungere.
  Il suo Minimo chiede presenza a Eredan: **NONE da 1 a 8 su 50 partite**, con
  «Presenza a Eredan» come prima causa. Adesso il rubinetto si allarga **solo
  col gettone di riserva**: una casa non abbandona il posto in cui vive per una
  carta in piu'.

### Quello che si dichiara

- **CHR_03 gioca ancora il §10 di prima**, ed e' deliberato: la sua mappa non e'
  stata ridistribuita (D-186 ha toccato solo le sei Regioni di CHR_01, che pero'
  CHR_03 condivide — quindi il lavoro e' capire cosa serve al mondo del Sale, non
  rifare le Regioni). Accendere li' le carte senza guardare vorrebbe dire
  ripetere il difetto che D-186 ha appena chiuso.
- **Le prove unitarie stanno sul lato classico dell'interruttore, e lo
  dichiarano.** Trentasette prove usavano le azioni dirette **per mettere il
  mondo nella posizione da provare**, non per misurare l'economia: `play_classic()`
  le tiene li'. Che i dati spediti stiano dall'altra parte lo prova un test suo,
  che rilegge il dato dal disco.
- **I tre piani scriptati sono storie del §10 di prima** e restano tali: le loro
  mosse sono azioni dirette. **Manca un piano scriptato del gioco a carte**, ed
  e' la coperture che questo lavoro non ha: il gioco nuovo e' provato dal
  cancello (100 semi) e dalle prove unitarie, non da una storia raccontata.
- **Il 58% delle Occasioni resta muto.** Di 720 campioni: 222 volte il cervello
  non voleva niente, 194 volte voleva qualcosa **che la mano non sapeva dire**.
  Il secondo numero e' il costo vero della regola, e si abbassa in due modi —
  piu' carte, o una distribuzione diversa delle azioni fra le famiglie. Non e'
  stato tarato: e' la prima misura che esista.
- **Le quattro RIVENDICARE ereditano il difetto di ISSUES 37**: `FORCE` chiede
  un Claim posato in un round precedente, quindi due delle quarantotto carte
  sono quasi ingiocabili finche' §10 non cambia.
- **Maestra Ilve perde Trionfi nel playtest** (8 -> 2 su 50 anni) senza che il
  suo mondo abbia cambiato economia: la causa e' la modifica al cervello di
  D-187 (non si scopre piu' una velata solo perche' e' un obiettivo), che vale
  anche per CHR_03. In **campagna** — il criterio di ISSUES 46 — il Sale resta
  a **8 su 12**, dove stava. Il numero da guardare e' quello di campagna, ma il
  divario merita una misura sua.

---

## D-187 — Il velo copre la soglia, non il numero
**implemented in 0.1.155** (chiesta dal committente)

*«Le domande velate vanno risistemate, perche' il mondo lo sa quale e' il valore
ma i giocatori nel gioco fisico no e quindi nessuno sa quando le velate si
attivano.»*

Il difetto era vero e non era di taratura: era un'**asimmetria che il tavolo
fisico non puo' riprodurre**. Il motore teneva un numero che nessun giocatore
poteva conoscere e faceva scattare un Consiglio quando quel numero arrivava a
soglia. In digitale funziona; con quattro persone e un segnalino di legno, no.

### La regola nuova

| | prima | adesso |
|---|---|---|
| il valore | coperto | **pubblico**, come su una domanda aperta |
| la soglia | pubblica (stava nel dato, e le viste la stampavano) | **coperta** |
| agire sulla domanda | **vietato** finche' non la scopri | **permesso** |
| SCOPRIRE | rivela il valore, e solo a te | rivela **la soglia**, e solo a te |
| il registro scrive | `Il Risveglio: velata` | `Il Risveglio: 4/?` |

Al tavolo vero e' una **carta girata a faccia in giu' accanto al segnalino**: si
vede dove sta la domanda, non dove sia il traguardo. Non sapere quando esplodera'
diventa il rischio invece del divieto — ed e' un rischio che si puo' correre,
perche' adesso su quella domanda si puo' spingere.

E' dichiarata sulla Chronicle (`veiled_tensions: HIDES_ALL | HIDES_THRESHOLD`),
non scritta nel codice: la regola vecchia resta provata dai test e si riaccende
cambiando una stringa.

### Il difetto che e' saltato fuori strada facendo

Le due viste — il tavolo grande e la console in tasca — **stampavano la soglia
vera** leggendola dal dato, senza passare da nessun filtro di visibilita'. Con la
regola vecchia non si notava, perche' era il *valore* il segreto. Con la regola
nuova sarebbe stata la falla che svuota la regola il giorno stesso: adesso
passano da `visible_tension_threshold`, e una soglia coperta esce **-1** come
esce il dorso di una carta.

### Le misure

**0 su 8 bloccati** a tavolo misto e uniforme. E il numero onesto e' che **non
cambia quasi niente**:

| | prima (0.1.154) | dopo |
|---|---|---|
| Consigli falliti, tavolo misto | 241 | **239** |
| Consigli medi | 5,44 | **5,43** |
| TRAMARE giocati in 60 anni | 130 | **134** |
| INFLUENZARE giocati in 60 anni | 360 | **367** |

Suite **369 test / 6476 asserzioni** (tre nuovi: la domanda che si spinge senza
averla scoperta, il valore pubblico con la soglia coperta, e SCOPRIRE che gira
la carta).

### Quello che si dichiara

- **Le sonde non possono misurare la cosa per cui e' stata fatta.** I bot non
  provano attesa: uno che non sa la soglia stima la media di quelle in gioco e
  gioca. Il valore del cambiamento e' che **quattro persone possono giocare la
  regola**, e quello si vede in una serata, non in cento semi.
- **Il velo di D-125 e' piu' debole.** Calare il velo copriva un numero; adesso
  copre solo il quando. E' una perdita reale per la casa che ha quell'arte, non
  ancora misurata, e il registro non promette piu' di quanto copra davvero.
- **La stima del bot e' una scelta, non una misura**: chi non ha girato la carta
  usa la soglia **media** della Chronicle. Deterministica e onesta — non guarda
  il dato vero — ma non e' stata tarata contro alternative (la piu' bassa quando
  difendi, la piu' alta quando spingi).
- **Non e' stato provato con un Consiglio che scatta a sorpresa**: la suite prova
  chi vede cosa, non l'effetto drammatico di una soglia che si rivela girandosi.
- **Le altre due domande del committente restano aperte**: che nella prima
  partita le quattro domande non siano sempre le stesse, e che partano tutte da
  **0** invece che da 3, 2, 2, 1. La seconda non e' gratis — con nove gettoni di
  Deriva su quattro domande, partire da zero significa rifare le soglie.

---

## D-186 — La mappa che distribuisce, e quante carte servono davvero
**implemented in 0.1.154** (ISSUES 47, fase 3: il punto che bloccava le 48 carte)

Il committente: *«Vai con la mappa, poi le carte per ogni atto devono essere
pescate in numero sufficiente per fare le stesse azioni e per influenzare i
concili come adesso.»* Due lavori, e il secondo e' una misura.

### a) La mappa non distribuiva

D-183 aveva scritto il difetto senza risolverlo: `WEALTH` stava in **quattro**
Regioni su sei, `FORCE` in **una sola**. Se la Regione decide che carte peschi,
quello non e' colore: e' un'azione che qualcuno non potra' mai fare.

Sei Regioni, due famiglie ciascuna, dodici posti, sei famiglie: la
distribuzione giusta e' **due Regioni per famiglia**, e adesso lo e'.

| Regione | offre | perche' |
|---|---|---|
| Eredan | AUTORITA', FORZA | il trono e la guarnigione |
| Valle Verde | GENTE, RICCHEZZA | i contadini e il grano |
| Terre Nahr | AUTORITA', GENTE | il popolo e la parola degli anziani |
| Montagne Rosse | FORZA, LEGAMI | i clan armati e i loro giuramenti |
| Miniere Antiche | SAPERE, LEGAMI | il sito antico e i patti dei minatori |
| Strada dei Mercanti | RICCHEZZA, SAPERE | il commercio e le notizie che viaggiano |

Quante volte una famiglia e' a portata di mano in un anno, su 60 partite:

| | prima | dopo |
|---|---|---|
| RICCHEZZA | **1219** | 427 |
| GENTE | 591 | 592 |
| AUTORITA' | 415 | 600 |
| SAPERE | 374 | 383 |
| LEGAMI | 371 | 553 |
| FORZA | **180** | 605 |
| divario fra la prima e l'ultima | **6,8 a 1** | **1,6 a 1** |

### b) E la misura che ha deciso quale mappa

La prima mappa che ho scritto era piu' varia per il singolo seggio (3,8 famiglie
diverse in un anno contro 3,5) ma peggio distribuita (2,2 a 1). Ho scelto la
seconda: **una famiglia irraggiungibile per tutti e' un difetto, mezza famiglia
in meno per uno e' una sfumatura.** Il numero peggiorato e' questo, ed e' scritto.

Per scegliere serviva sapere **dove stanno davvero le pedine**, che nessuno
aveva mai misurato. La sonda della mano adesso lo dice, ed e' la sorpresa del
giorno:

| Regione | pedine viste | |
|---|---|---|
| Eredan | 425 | 26,9% |
| Valle Verde | 417 | 26,4% |
| Miniere Antiche | 373 | 23,6% |
| Montagne Rosse | 180 | 11,4% |
| Terre Nahr | 175 | 11,1% |
| **Strada dei Mercanti** | **10** | **0,6%** |

**La Strada dei Mercanti e' una Regione morta**: praticamente nessuno ci mette
una pedina. Le due famiglie che le si danno valgono quasi zero — per questo le
ho messe RICCHEZZA e SAPERE, che una casa forte ce l'hanno gia' altrove. E'
aperta come ISSUES 48: e' un difetto suo, non della distribuzione.

### c) Il fabbisogno: quante carte servono per giocare come adesso

La richiesta del committente e' diventata un numero. Per seggio, in un anno:

| | |
|---|---|
| azioni che col nuovo sistema costerebbero una carta | **3,20** (tutte tranne ACQUISIRE) |
| carte impegnate ai Consigli | **8,59** |
| **fabbisogno** | **11,80 l'anno**, cioe' **3,93 per Atto** |

Il rubinetto a `per_token: 1` ne dava 2 per Atto: **meta' del necessario**. La
taratura che regge il fabbisogno e' **`per_token: 2, floor: 2, cap: 6,
hand_cap: 7`** — due carte per gettone, e il tetto sulla mano al limite di mano
che il regolamento ha gia'. Misurata col rubinetto acceso:

| | Atto 1 | Atto 2 | Atto 3 |
|---|---|---|---|
| carte in mano | 6,00 | 6,85 | 6,67 |
| scarto fra la piu' piena e la piu' vuota | 0,00 | 0,53 | **1,18** |

**Il punto 2 di ISSUES 47 e' risolto**: la divergenza che raddoppiava ogni Atto
adesso e' 1,18 — contro **4,90** del gioco di oggi. La mano che viene dalla mappa,
col tetto giusto, e' piu' equa di ACQUISIRE.

### Le misure del cancello

Rubinetto **spento** (si accende con `actions_from_cards`), mappa nuova accesa:
**0 su 8 bloccati** a tavolo misto e uniforme. Consigli falliti **248 -> 241**.
Suite **366 test / 6453 asserzioni**, tutto verde.

### Quello che si dichiara

- **L'anno si e' fatto piu' quieto**: Consigli medi da **5,79 a 5,44**, e il
  minimo della banda da 2 a **1**. La causa e' la stessa distribuzione: prima
  quasi tutti avevano RICCHEZZA in mano e le carte rilevanti si trovavano
  sempre; adesso una mano e' piu' varia e piu' spesso non ha la famiglia che
  quel Consiglio premia. E' il prezzo, ed e' pagato apposta.
- **Due piani scriptati sono cambiati e sono stati riregistrati.** «Il consiglio
  spezzato» passa da sei Consigli a tre — e la storia nuova e' **migliore**:
  la domanda affondata torna al round dopo e a proporla e' *chi l'aveva
  affondata*, col registro che scrive «la spirale si chiude». E' D-098 vista a
  occhio nudo. «La miniera aperta» perde i suoi due Decisivi (margine 4 invece
  di 5) e resta a sei Consigli.
- **Un errore trovato per strada, e non e' mio**: la descrizione di «la miniera
  aperta» diceva *«tutte e quattro le bande di esito del §12.3 in una partita
  sola»* e *«passa pagando»*, ma i suoi stessi esiti registrati erano
  `FAILURE, DECISIVE, SUCCESS, SUCCESS, DECISIVE, FAILURE` — **tre bande, e
  nessun SUCCESS_WITH_COST**. La prosa descriveva una versione precedente e non
  era mai stata aggiornata. Adesso le due cose dicono la stessa cosa.
- **La suite ha 61 asserzioni in meno** (6514 -> 6453): sono i tre Consigli che
  «il consiglio spezzato» non gioca piu'. Nessun test e' stato tolto.
- **La taratura del rubinetto e' un preventivo, non una taratura.** E' misurata
  col rubinetto **sopra** ACQUISIRE, che nel gioco finale non ci sara'. Acceso
  cosi' oggi, i Consigli falliti salgono a **304**: e' il prezzo del doppio
  canale, non della taratura.
- **Le altre Chronicle non sono state toccate.** CHR_03 tiene la sua mappa: se
  la fase 3 va avanti, va ridistribuita anche quella.

---

## D-185 — Il rubinetto: la mano viene dalla mappa
**implemented in 0.1.153** (ISSUES 47, fase 2: la pesca dalla presenza)

*«La presenza nelle regioni deve essere fondamentale nella pesca delle carte,
tipo due presenze, due carte.»* Il committente ha chiesto di partire da qui.

### Come e' fatto

A inizio di ogni Atto, prima del primo round, ogni seggio pesca guardando **dove
tiene le pedine**: quante carte lo dicono i gettoni, **di che famiglia** lo dice
la Regione, perche' ogni Regione dichiara le proprie `asset_sources`. La mappa
smette di essere un punteggio e diventa il rubinetto.

I freni stanno nella Chronicle e non nel codice, perche' sono taratura:

| chiave | cosa fa |
|---|---|
| `per_token` | carte per gettone. A 1 vale «due presenze, due carte» |
| `floor` | il pavimento: chi non ha piu' pedine pesca lo stesso, dal mazzo piu' pieno |
| `cap` | il tetto **per Atto**: quante al massimo in un colpo |
| `hand_cap` | il tetto sulla **mano**: si riempie fino a quel numero e non oltre |

Vive solo se la Chronicle dichiara `hand_refill`. Senza — ed e' il default —
non succede niente e le carte si pescano ancora con ACQUISIRE.

### La misura che conta: quale tetto frena davvero

D-183 aveva misurato la divergenza — piu' presenza da' piu' carte, piu' carte
danno piu' presenza — e io avevo scritto che il freno era il **tetto per Atto**.
**Era sbagliato, e la misura lo ha detto subito.** Scarto fra la mano piu' piena
e la piu' vuota, sonda della mano, 60 semi:

| | Atto 1 | Atto 2 | Atto 3 |
|---|---|---|---|
| rubinetto acceso, solo `cap: 3` | 0,00 | 3,18 | **5,48** |
| rubinetto acceso, `hand_cap: 5` | 0,00 | 1,68 | **3,33** |
| **rubinetto spento (il gioco di oggi)** | 0,00 | 2,77 | **4,90** |

Il tetto per Atto limita la **pesca**, non la **mano**: le carte non spese
restano li' e lo scarto si accumula lo stesso. Il tetto sulla mano invece morde
dove serve — chi ha ancora carte pesca meno, chi le ha spese pesca pieno.

E la riga che non mi aspettavo: **col tetto sulla mano il gioco diverge meno di
oggi** (3,33 contro 4,90). ACQUISIRE, che nessuno frena, e' una sorgente di
divergenza piu' forte del rubinetto frenato. Provati anche `hand_cap` 4 e 6:
lo scarto ad Atto 3 resta 3,32 e 3,70 — il tetto sceglie **quante** carte
girano, non quanto sono sbilanciate. Scelto **5**, che a parita' di scarto ne
lascia in mano di piu'.

### Le misure del cancello

Il rubinetto e' **spento nei dati**, quindi il playtest e' identico riga per riga
a 0.1.150: `FAIL 248 · 78 · 99 · 154`, Consigli media 5,79, **0 su 8 bloccati**.
Suite **366 test / 6514 asserzioni** (sette per il rubinetto: lo spento, le due
pedine, il tetto per Atto, il pavimento, la Regione che sceglie la famiglia, il
tetto sulla mano, la mano gia' piena).

### Quello che si dichiara

- **Acceso da solo, il rubinetto peggiora il gioco.** Con `hand_cap: 5`, tavolo
  misto: Consigli da 5,79 a **6,13**, banda da 2–7 a 3–8, e i Consigli falliti
  da 248 a **272** — il massimo mai misurato (il record era 256). E' atteso, non
  sorprendente: finche' `actions_from_cards` e' spento, le carte del rubinetto si
  **sommano** ad ACQUISIRE invece di sostituirlo, e con piu' carte in mano si
  propone e ci si oppone di piu'. **Le due meta' vanno accese insieme**, ed e'
  la stessa cosa scritta in D-184 e in ISSUES 47.
- **Il vincolo regge lo stesso**: 0 su 8 anche col rubinetto acceso, misto e
  uniforme. La regressione e' sui Consigli, non sui seggi.
- **Correggo un numero che avevo detto storto in sessione**: che 9 Consigli in un
  anno «sfondassero un limite duro di §7». Non c'e' nessun tetto nel codice:
  9 e' il massimo **strutturale** (3 Atti × 3 round, un Consiglio per round), e
  la banda 2–8 di `MECCANICA.md` §21 e' un estremo **misurato**, non una regola.
  Restare a 9 non rompe niente; toccare la mediana si'.
- **Il pavimento non e' mai stato esercitato da una partita vera**: D-183 dice
  che nessun seggio resta senza pedine, quindi il ramo e' provato solo dai test.
- **`hand_cap` non e' stato tarato col gioco vero.** I tre valori sono stati
  misurati col rubinetto **sopra** ACQUISIRE. Quando ACQUISIRE sparira', il
  numero giusto va rimisurato da capo: quello scritto qui e' un punto di
  partenza, non una taratura.

---

## D-184 — Il telaio delle azioni sulle carte
**implemented in 0.1.152** (ISSUES 47, fase 1: il gancio a vuoto)

Il committente ha dato il via: *«togliamo tutte le azioni e le mettiamo sulle
carte. Ogni carta ha una azione di gioco, un valore per il consiglio, e effetti
specifici della carta, il gioco deve essere un bilanciamento di come usare le
cose che la carta ti permette di fare.»*

### Due dei tre pezzi c'erano gia'

| cosa chiede | dove sta oggi |
|---|---|
| un **valore per il Consiglio** | `family` + `strength` (1, 2 o 3) |
| **effetti specifici della carta** | `on_commit_effects` — 47 carte su 48 ne hanno uno (D-106…D-114) |
| **un'azione di gioco** | **non c'era** |

Il telaio quindi non costruisce un sistema nuovo: aggiunge il terzo lato a un
oggetto che ne aveva gia' due.

### Come e' fatto

- **`card_action` sull'Asset**: `{kind, params}`, dove `kind` e' una delle **sei
  azioni di §10**. Il telaio non inventa verbi nuovi — sposta chi puo'
  pronunciarli. I parametri scritti sulla carta vincono; quelli che la carta
  lascia aperti restano una scelta di chi la gioca, quindi una carta puo' dire
  *dove* si muove oppure lasciarlo decidere.
- **`PLAY_CARD` nel resolver**: legge la `card_action`, passa dal **medesimo
  `check()`** e dal medesimo esecutore dell'azione corrispondente, e poi
  **consuma la carta**. Nessuna regola e' scritta due volte: una carta non puo'
  fare cio' che l'azione non permetterebbe, e c'e' un test che lo prova
  chiedendo a una carta un MUOVERE illegale.
- **`actions_from_cards` sulla Chronicle**: spento — il default — il gioco e'
  quello di sempre. Acceso, le sei azioni non si prendono piu' con
  un'Opportunita' e la mano diventa l'unica moneta. Le carte del Narratore
  restano fuori: sono un mazzo a parte, non la mano.

**La spesa e' il punto.** Giocare una carta la scarta, quindi quella carta non
votera' piu': e' li' che nasce il bilanciamento che il committente chiede — *o la
spendi per fare, o la tieni per votare*.

### Le misure

**Zero carte convertite, e il playtest e' identico riga per riga** a quello di
0.1.150. E' il pattern di D-104 e D-116, che qui vale doppio: il telaio piu'
grosso mai aggiunto al gioco entra senza spostare un numero. Suite **359 test /
6503 asserzioni** (quattro nuovi: la carta muta, la carta che agisce e si spende,
la carta che non aggira un divieto, l'interruttore).

### Quello che si dichiara

- **Nessuna carta porta ancora un'azione.** Il gioco nuovo non esiste finche' non
  si scrivono le 48 `card_action`, ed e' il pezzo di contenuto piu' grosso mai
  fatto qui. La fase 1 serve a poterle scrivere **una famiglia alla volta**,
  misurando, invece che tutte insieme.
- **Il rubinetto della mano non e' ancora collegato**: le carte si pescano ancora
  con ACQUISIRE. Quando `actions_from_cards` sara' acceso senza una pesca legata
  alla presenza, un seggio finirebbe le carte e non potrebbe piu' agire — le due
  meta' vanno accese **insieme**, ed e' scritto in ISSUES 47.
- **`TRAMARE` e `INFLUENZARE` non sono ancora spariti** come azioni: il
  committente li vuole togliere e la misura gli da' ragione (6 e 7 usi in un anno
  intero), ma vanno tolti quando esistono le carte che li portano.

---

## D-183 — Il prezzo della mano che viene dalla mappa
**misurata in 0.1.151** (nessuna regola cambiata: e' il preventivo di ISSUES 47)

Il committente ha proposto una riprogettazione: *«tutte le azioni si fanno con
le carte, e le carte si pescano a inizio atto a seconda della presenza in una
regione, tipo due presenze due carte; con le carte in mano si fanno le azioni o
si giocano nel consiglio»*.

Prima di riscrivere quarantotto carte, il preventivo. `run_hand_probe.gd` gioca
le partite **come sono adesso** e, a inizio di ogni Atto, guarda dove stanno le
pedine e scrive quante carte quel rubinetto darebbe.

### Il numero che da' ragione alla proposta

Contate le azioni davvero giocate in un anno intero, su 72 disponibili al tavolo:
**47 ACQUISIRE**, 7 INFLUENZARE, 6 TRAMARE, 5 FORGIARE, 3 RIVENDICARE, 2 carte
del Narratore calate, e **1 solo MUOVERE**.

**Due terzi del gioco sono gia' «pesca una carta», e la mappa si muove una volta
per partita.** La proposta non introduce un'economia nuova: riconosce quella che
c'e' gia' e la rende deliberata.

### 1. Quanto si stringe

| | CHR_01 | CHR_03 |
|---|---|---|
| carte in un anno, per seggio | **6,6** | **7,2** |
| contro le azioni di oggi | 18 | 18 |
| il gioco resta al | **36%** | **40%** |
| dal seggio piu' povero al piu' ricco | 5 → 11 | 5 → 11 |

Il gioco si riduce a **poco piu' di un terzo**. Non e' un difetto della proposta —
puo' essere esattamente cio' che si vuole, ogni scelta pesa il triplo — ma va
scelto, non subito.

### 2. Il ciclo diverge, ed e' misurato

| atto | carte medie | **scarto fra primo e ultimo** (CHR_01) | (CHR_03) |
|---|---|---|---|
| I | 2,00 | **0,00** | **0,00** |
| II | 2,17 | 0,65 | 1,32 |
| III | 2,39 | **1,25** | **1,92** |

**Lo scarto parte da zero e raddoppia ogni atto.** Parte da zero perche' tutti i
seggi cominciano con due pedine: la divergenza non viene dal setup, **la produce
il gioco**. In tre atti il primo prende una carta e mezza in piu' dell'ultimo; su
una campagna di dieci anni quel divario si somma, ed e' esattamente la forma che
D-180 ha visto col contatore di saga — un piccolo vantaggio che diventa un
risultato.

### 3. Nessuno resta a secco, e questa e' la sorpresa buona

**0 seggi senza pedine, in tutti e tre gli Atti, su 240 campioni per tavolo.** La
spirale della morte temuta — chi perde la presenza non pesca e non si rialza —
**non si materializza**, perche' le pedine iniziali non si perdono quasi mai. Un
pavimento resta prudente, ma non e' il problema che sembrava.

### 4. E la mappa deciderebbe anche *quali* carte

Se la Regione dice la famiglia, un seggio raggiunge in un anno **3,3 famiglie su
6**: metta' del mazzo gli resta fuori. E le sei non sono pari, perche' la mappa
non e' stata disegnata per questo:

| | CHR_01 | CHR_03 |
|---|---|---|
| **WEALTH** | **1219** | **1496** |
| PEOPLE | 591 | 198 |
| AUTHORITY | 415 | 557 |
| KNOWLEDGE | 374 | 526 |
| BONDS | 371 | 443 |
| **FORCE** | **180** | 228 |

`WEALTH` sta in **quattro Regioni su sei** e diventerebbe la moneta comune;
`FORCE` sta in una sola ed e' la piu' rara di tutte. Con RIVENDICARE che chiede
due AUTORITA', chi non passa da Eredan non rivendica mai.

### Quello che si dichiara

- **La sonda misura il rubinetto, non il gioco nuovo.** Le partite girano con le
  regole di adesso, dove muovere le pedine non serve quasi a niente: **se muovere
  desse le carte, i seggi si muoverebbero molto di piu'**, e sia il totale sia la
  divergenza sarebbero diversi. Questi numeri sono il **pavimento** del volume e
  probabilmente il **pavimento** anche della divergenza.
- **Un gettone = una carta** e' la lettura misurata; «due presenze due carte» si
  puo' leggere anche come *Regioni distinte* (max 3) — la sonda conta tutt'e due,
  e nel gioco di oggi coincidono quasi sempre perche' le pedine stanno separate.
- **Non e' stata cambiata nessuna regola**: playtest, suite e dati sono quelli di
  0.1.150.

---

## D-182 — Il Sale non vinceva: gli succedeva di vincere
**implemented in 0.1.150** (ISSUES 46, voluta dal committente: «il Sale e' troppo forte»)

D-180 aveva scoperto che nella saga del Sale la campagna la vince sempre la
stessa casa, e D-181 che meta' di quelle campagne era decisa entro il terzo anno
su dieci. Il committente ha dato la direzione: **guardare il Sale dal lato suo**.

### Le tre teste del difetto

Misurate una per una col banco delle clausole (`run_clause_probe`), le clausole
vere del Sale:

| clausola | dove sta | quanto e' vera |
|---|---|---|
| `entity_alive` + presenza sulla Strada | il Minimo | **100%** |
| «Il debito e' stato chiamato per intero» | Vittoria, 1ª | 75% (92% quando lo insegue) |
| **«E nessuno lo ha cancellato»** | Vittoria, 2ª | **100%** |
| **«Il patto con la Cenere regge»** | **la spina del Trionfo** | **100%** |
| (per confronto: due Regioni tenute) | — | 15% |

`DST_SALE` chiudeva **0/1/8/4 su 13**: superava il Minimo **12 volte su tredici**.

E il motivo non era che il Sale giocasse meglio. **La sua Vittoria la decideva il
calendario**: `debt_called` matura da se' quando la Tensione del Debito arriva a
soglia, `debt_forgiven` non lo scrive quasi nessuno, e il patto con la Cenere non
si rompe mai. Tre clausole su cinque erano fatti del mondo, non cose che la Gilda
facesse.

**Al Sale non riusciva di vincere: gli succedeva.**

### Quattro passi, misurati uno alla volta

| | `DST_SALE` (N/M/V/T su 13) | supera |
|---|---|---|
| **base** | 0 / **1** / 8 / 4 | **92%** |
| 1 — la 2ª clausola diventa «e chi lo doveva e' ancora al suo fianco» (ALLEATO) | 0 / **11** / 1 / 1 | **15%** |
| 1b — la stessa, ma a NEUTRALE | 0 / 7 / **1** / 5 | 46% — bimodale |
| 2 — la spina e la promessa si scambiano di posto | 0 / 7 / **1** / 5 | 46% — invariato |
| **3 — la scelta del Trionfo da 3 a 4 strade su 5** | 0 / 7 / **4** / 2 | **46%** — una scala |

**Il passo 1 e' quello che insegna qualcosa**, e ripete l'errore di D-177 al
contrario: chiedere il debito chiamato **e** un alleato rimasto tale e' chiedere
due cose **anti-correlate** — riscuotere allontana chi paga — e il Destino e'
crollato dal 92% al 15% in un colpo. La stessa forma del Destino che si combatte
da solo, arrivata dal lato opposto. A NEUTRALE la richiesta diventa «riscuotere
senza rompere», che e' esattamente cio' che una Gilda sa fare.

Il passo 2 non ha spostato niente ed e' a verbale perche' spiega perche': rendere
la spina piu' dura e la scelta piu' facile si compensa. La bimodalita' non si cura
spostando clausole, si cura alzando il Trionfo **rispetto** alla Vittoria.

**La promessa non e' stata cancellata ma spostata**: `promise_kept` compare **una
volta sola in tutto il gioco**, e toglierla l'avrebbe resa contenuto che non
esiste (D-035). Adesso e' una delle cinque strade, dove valere il 100% non regala
un livello.

### E il secondo Destino, che era diventato il colpevole

Corretto `DST_SALE`, la casa vinceva ancora **10 campagne su 12**. La sonda ha
spostato il dito: **`DST_SALE_OPEN` faceva 6 Trionfi su 13**, il massimo del
gioco, con un Trionfo fatto di una spina al 100% e «almeno **una** strada su
quattro». Portata a due:

| | N / M / V / T su 13 |
|---|---|
| `DST_SALE_OPEN` base | 0 / 6 / **1** / 6 |
| **dopo** | 0 / 6 / **6** / 1 |

### Le misure

**La campagna, che e' la domanda di ISSUES 46:**

| su 12 saghe da 10 Chronicle | prima | dopo |
|---|---|---|
| campagne vinte dal Sale | **12 su 12** | **9 su 12** |
| il Sale supera il Minimo | 68% | **54%** |
| le altre tre case | 24%–33% | **33%–34%** |
| cambi di testa per saga | 1,3 | **1,8** |
| ultimo cambio di testa | anno **3,5** su 10 | anno **5,5** su 10 |
| campagne decise entro il terzo anno | **6 su 12** | **4 su 12** |

**Il cancello:** playtest 100 semi **FAIL 248 · 78 · 99 · 154**, mediana 6,
**0 su 8** a tavolo misto e uniforme. Maestra Ilve passa da 0/19/15/16 a
**0/26/16/8** a tavolo misto e da 0/16/15/19 a 0/20/20/10 a tavolo uniforme.
Suite **355 test / 6490 asserzioni**, sim deterministiche.

I **Consigli falliti scendono da 256 a 248**, ed e' la prima volta che quel
numero torna indietro: una casa che non arriva piu' al Trionfo per inerzia
propone e si oppone meno a lungo.

### Quello che si dichiara

- **La voce e' ridotta, non chiusa.** Il criterio che ISSUES 46 si era dato —
  nessuna casa sopra la meta' delle campagne — non e' raggiunto: **9 su 12 e'
  il 75%**. Il Sale resta la casa piu' forte del suo tavolo (54% contro 33-34%),
  e mi fermo qui perche' continuare senza una diagnosi nuova sarebbe tarare a
  occhio, che e' esattamente cio' che questo progetto ha imparato a non fare.
- **Dove guardare la prossima volta**: i Trionfi nelle saghe restano sbilanciati
  (Sale 25, Libere 19, Vetro 11, Cenere 8 su 120 anni), e il Minimo delle quattro
  case non costa uguale — il Vetro ne ha uno da due gettoni, il Sale uno da uno.
  Nessuna delle due cose e' stata misurata come causa.
- **Kessa prende 1 NONE a tavolo misto** dove prima ne aveva 0. E' dentro il
  vincolo (nessun seggio bloccato) ed e' un anno perso in piu', non uno di meno.
- **Il tavolo della prima saga non e' toccato**: le modifiche stanno tutte in
  `destinies_chronicle_03.json`.

---

## D-181 — Una campagna e' almeno dieci anni
**implemented in 0.1.149** (decisa dal committente)

D-180 aveva lasciato scritto che «la lunghezza della saga resta indefinita,
quindi il vincitore e' chi sta in testa quando il tavolo smette». Il committente
ha deciso: **«direi la saga almeno 10 partite»**.

### Come e' scritta

`saga_scoring.decides_after`, con **10** nelle due saghe in gioco. Prima della
soglia il conto si tiene ma nessuno ha vinto, e il verbale lo dice a ogni anno
(*«La campagna non e' ancora decisa: 3 anni giocati su 10»*); dalla decima in poi
dichiara il vincitore, o la parita' se c'e'.

**«Almeno» vuol dire che la soglia apre la porta e non la chiude**: al decimo
anno la campagna *puo'* finire, e se il tavolo continua il conto prosegue e il
verdetto si aggiorna. Una campagna piu' lunga e' ancora una campagna; una piu'
corta non lo e'.

Serviva un numero che non c'era: **quante Chronicle ha giocato questa saga**
(`world.chronicles_played`). Non si poteva ricavare da `year`, perche' fra due
Chronicle passano da 1 a 200 anni: cento anni di mondo possono essere due partite
o dieci.

### La domanda che la soglia rende concreta, e la sua risposta

D-180 aveva dichiarato di non sapere «se il conto renda ininfluenti gli ultimi
anni quando qualcuno ha accumulato troppo». Con una soglia si puo' chiedere, e la
misura e' **l'anno dell'ultimo cambio di testa**: se la campagna cambia padrone
per l'ultima volta al secondo anno su dieci, gli altri otto sono un'attesa.

| su 12 saghe da 10 Chronicle | la Carestia | il Sale |
|---|---|---|
| cambi di testa per saga | **1,8** | 1,3 |
| ultimo cambio di testa | anno **5,0** su 10 | anno **3,5** su 10 |
| campagne decise entro il terzo anno | **3 su 12** | **6 su 12** |

**Nella Carestia la campagna regge**: cambia padrone quasi due volte, e l'ultimo
sorpasso arriva a meta' strada — cinque anni dopo c'e' ancora partita per
qualcuno. **Nel Sale no**: meta' delle campagne e' decisa entro il terzo anno su
dieci.

E la causa non e' la soglia ne' la scala: e' **ISSUES 46**. Una casa che supera
il Minimo il 68% delle volte prende la testa presto e non la molla piu'. Lo stesso
squilibrio, visto da un terzo lato — prima come gradini per incarnazione (D-176),
poi come vincitore di campagna (D-180), adesso come **noia**: sette anni giocati
sapendo gia' come finisce.

### Le misure

- **Il playtest e' identico riga per riga** a quello di 0.1.147, per la terza
  versione di fila: la campagna non entra in nessuna decisione.
- Suite **355 test / 6490 asserzioni** (due test nuovi: la soglia, e il conto
  degli anni che attraversa le ere), sim ed export identici su due giri.

### Quello che si dichiara

- **Dieci e' il numero del committente, non un numero misurato.** La misura dice
  che a dieci la Carestia regge e il Sale no; non dice che dieci sia il valore
  giusto. Se ISSUES 46 si chiude, il Sale reggera' con la stessa soglia.
- **La soglia non impedisce di smettere prima**: niente nel motore obbliga a
  giocare dieci Chronicle. Dice solo che sotto dieci nessun vincitore viene
  dichiarato, e sta al tavolo decidere se una campagna interrotta valga qualcosa.
- **Il pareggio non ha uno spareggio.** Se al decimo anno due case sono a pari
  punti il verbale dice «si va avanti», e la campagna continua: e' la scelta piu'
  semplice, e nessuno ha ancora chiesto un criterio di spareggio.

---

## D-180 — Il vincitore della saga, e cosa il contatore ha rivelato
**implemented in 0.1.148** (voluta dal committente)

«Per vincere la saga ci vuole un contatore di vittorie nelle singole partite.
Dare un valore ai livelli di vittoria che si sommano alla fine della saga
decretando il vincitore.»

### Perche' non contraddice il principio

Il gioco ripete ovunque che **non c'e' un punteggio e non c'e' un vincitore
unico**, ed e' la sua idea fondante. La richiesta lo mette pero' **a livello di
saga, non di partita**, e la distinzione la salva: dentro l'anno non cambia
niente — nessuna classifica, piu' case possono vincere, tutte possono fallire —
ed e' la **campagna** ad avere un vincitore. E' il modello dei giochi a campagna,
e lascia intatto quello che succede al tavolo in una sera.

### Il rischio che si temeva, e che la misura ha smentito

Se il Minimo paga, si accumulano punti **esistendo**, e la campagna la vince il
prudente — l'opposto di cio' che il gioco premia (D-053: il prudente e' il
carattere che arriva piu' in basso). Cinque scale candidate, misurate sulle
stesse saghe **prima** di scriverne una:

| | pareggi su 24 saghe | vincitore = chi ha piu' Trionfi | **= chi ha piu' Minimi** |
|---|---|---|---|
| A 0/1/2/3 lineare | 5 | 15/24 | **0/24** |
| B 0/1/3/6 crescente | 5 | 16/24 | **0/24** |
| C 0/1/3/5 | 3 | 15/24 | **0/24** |
| **D -1/1/3/6** | **3** | **18/24** | **0/24** |
| E 0/0/1/3 esistere non paga | 5 | 17/24 | **0/24** |

**Il timore era infondato**: con nessuna scala, in nessuna saga, vince chi ha
accumulato piu' Minimi. Il Minimo e' talmente comune che non discrimina — e chi
ne ha di piu' e' semplicemente chi ha osato di meno.

Scelta la **D**: meno pareggi e l'accordo piu' alto con i Trionfi. Il NONE che
**toglie** un punto e' la conseguenza naturale di D-067 — dal 0.1.26 perdere e'
possibile, e in una campagna deve costare — e il Trionfo che vale il **doppio**
della Vittoria e' quello che fa si' che due anni prudenti non paghino quanto uno
audace. La scala sta nella Chronicle (`saga_scoring`), quindi si cambia senza
toccare il codice, e **omessa spegne tutto**: una Chronicle puo' restare un anno
che sta in piedi da solo, come in v0.2.

### Quello che il contatore ha rivelato, ed e' la cosa piu' importante

| | chi vince la campagna, su 12 saghe |
|---|---|
| **CHR_01** — la Carestia | NAHR 5, LYRA 2, VAERAX 2, **Aldric mai** · 3 pareggi |
| **CHR_03** — il Sale | **SALE 12 su 12** |

**Nella saga del Sale la campagna la vince sempre la stessa casa, con qualunque
scala.** Non e' un difetto del punteggio: e' lo squilibrio di contenuto gia' noto
(il Sale supera il Minimo il 68% delle volte contro il 24%–31% delle altre) che
oggi si **spalma** anno per anno e che un totale cumulativo rende **definitivo**.

E' la scoperta che vale piu' della regola: **un contatore di campagna non e' una
regola neutra, e' un amplificatore.** Finche' ogni anno sta in piedi da solo, una
casa debole ha comunque i suoi anni buoni e il tavolo non se ne accorge; appena
si somma, la differenza diventa il risultato. Aperta come **ISSUES 46**.

### Le misure

- **Il playtest e' identico riga per riga** a quello di 0.1.147: il punteggio non
  entra in nessuna decisione, nessuna policy lo legge, ed e' puro verbale. FAIL
  256 · 78 · 100 · 145, mediana 6, **0 su 8** misto e uniforme.
- Suite **353 test / 6480 asserzioni** (quattro test nuovi), sim ed export
  identici su due giri.

### Quello che si dichiara

- **Il punteggio e' un contatore, non un Effetto.** Sta fra le eccezioni
  dichiarate all'effect-sourcing insieme a `confluence_count` e `voted_together`,
  e per la stessa ragione: non e' uno stato del mondo che qualcuno possa disfare,
  e' il verbale di quello che e' gia' successo. Attraversa le ere in
  `inherit_from`, e **passa anche se la Chronicle nuova non tiene il conto**: un
  anno che non conta non e' un anno che azzera.
- **Segue il seggio, non la persona.** In una saga lunga chi siede cambia — il
  Popolo Nahr diventa Il Regno di Nahr — e il conto prosegue: e' la casa a
  giocare la campagna.
- **La lunghezza della saga resta indefinita.** Il gioco non dichiara quando una
  campagna finisce, quindi «il vincitore» e' chi sta in testa quando il tavolo
  smette. Chi vorra' una campagna a lunghezza fissa dovra' scriverlo.
- **Nessuna sonda misura ancora se la campagna sia *bella*.** Sappiamo chi vince
  e con quale margine; non sappiamo se il conto renda gli ultimi anni ininfluenti
  quando qualcuno ha accumulato troppo. E' la stessa lacuna dichiarata in
  ISSUES 36, e vale la pena guardarla prima di dichiarare chiusa la 0.3.

---

## D-179 — La meccanica riportata al vero, e come si gioca bene
**implemented in 0.1.147** (documentazione: nessun dato di gioco toccato)

`docs/MECCANICA.md` e' il testo che si da' a chi deve disegnare l'infografica, e
il suo principio dichiarato e' che **tutti i numeri dentro sono quelli veri,
letti dai dati e dal codice**. Era fermo a 0.1.140, cioe' a prima del pool acceso
(D-170/D-173), delle Conseguenze che costruiscono (D-175) e di tutto il resto.

### I numeri che erano diventati falsi

Passati uno per uno contro i dati. La maggior parte reggeva — 132 carte Asset su
48 tipi, 39 carte Narratore con 24 funzioni, 52 Conseguenze di cui 14 cambiano
padrone, 10 modelli di Consiglio, 12 Tensioni scritte, 20 Destini, 9 tipi di
struttura, i valori 2/3/5 del presidio. Cinque no:

| | diceva | e' |
|---|---|---|
| regole dei segni (§9) | **45** | **52** — e §3 e §14 dicevano gia' 52: il documento **contraddiceva se stesso** |
| la ripartizione per tipo | COUNCIL_MODIFIER 16, DRAW_BIAS 10, HAND_LIMIT 1 | **17**, **14**, **3** |
| famiglie di struttura | **5**, con `CHIUSURA` per il passo | **4**: il passo e' un `LUOGO`, `CHIUSURA` non esiste nei dati |
| Destini in gioco | **9** all'apertura | **19** dei 20 (il ventesimo e' della Leggenda, che siede solo in saga) |
| come finisce un anno | ~1% / ~40% / ~40% / ~19% | **0% / 44% / 36% / 20%** a tavolo misto |

L'ultima riga ha guadagnato una colonna invece di cambiare numero: accanto al
tavolo misto c'e' adesso quello dei **quattro ottimizzatori** (1% / 28% / 41% /
30%), perche' il divario fra le due e' esso stesso un fatto sul gioco — la stessa
policy, nessuno che bara, e venti punti di Trionfo di differenza fra chi non
spreca un turno e chi ogni tanto lo spreca.

### Tre cose che il documento non diceva affatto

- **Il Destino si pesca da un pool di tre** (due identitari piu' un
  condivisibile). E' la novita' che un giocatore nota per prima — lo stesso
  tavolo nello stesso anno non gioca la stessa partita — e mancava del tutto,
  col suo costo dichiarato accanto (i Consigli falliti da 206 a 246).
- **Sette Conseguenze costruiscono qualcosa che resta.** Il documento diceva solo
  che 14 cambiano il padrone: mancava che un Consiglio lasci una cosa *sulla
  mappa*, che pesa nel conto del controllo e sopravvive all'anno.
- **Come si gioca bene.** Il documento spiegava le regole e non diceva a nessuno
  cosa convenisse fare.

### La sezione nuova, e perche' e' misurata invece che opinata

§15 «Come si gioca bene, misurato» tiene i numeri dei quattro caratteri sulle
stesse 100 partite del §14:

| | supera il Minimo | Trionfi |
|---|---|---|
| **prudente** | **40%** | 11 |
| distratto | 59% | 20 |
| aggressivo | 62% | 22 |
| **ostinato** | **63%** | **27** |

**La prudenza e' la strategia peggiore del gioco, e di venti punti.** E
l'ostinato — che punta al gradino alto dal primo round invece che al piu' vicino
— ha piu' Trionfi di tutti *e* meno Minimi di tutti: giocare basso non protegge.
Sono i due risultati che un manuale non avrebbe potuto indovinare.

Attorno a quelli, nove regole pratiche con il numero accanto: la carta che vale 3
al Consiglio giusto e 1 a quello sbagliato · il 44% di Consigli che falliscono ·
i tre gettoni che comandano tutto · la sovraestensione oltre due Regioni · il
controllo che si conta invece di prendersi · **le 111 rivendicazioni morte su
128** · la Condizione che sotto due carte non qualifica · l'alleanza che rende
solo se ci metti due carte · e l'errore di spegnersi il Destino da soli, che e'
successo in una partita vera **e** nei dati (D-177).

### Quello che si dichiara

- **La sezione si chiude con cio' che non sa.** Tutti i numeri vengono da bot
  contro bot: nessuno tradisce, nessuno mente, nessuno promette senza mantenere.
  Le strategie sono solide sulla meccanica e **mute sulla meta' negoziata del
  gioco** — la finestra fra le posizioni dichiarate in pubblico e le carte
  impegnate al buio e' fatta apposta perche' ci si parli, e nessuna misura in
  questo repository la vede.
- **Non e' stato toccato nessun dato di gioco**: playtest, suite e sonde sono
  quelli di 0.1.146.
- **Restano fuori** le novita' minori di 0.1.142 (il sigillo che porta il sito
  antico al grado di mezzo) e il dettaglio delle vite in §11, che il documento
  copre gia' a un livello che regge.

---

## D-178 — Il difetto di D-177 si vedeva senza giocare una partita
**implemented in 0.1.146** (due guardie nella CI, e la seconda ha morso subito)

D-177 e' costato una sessione di sonde: la sonda delle ere estesa a contare le
clausole, il conto dei gettoni per Regione negli anni persi, il banco delle
clausole, due ipotesi scritte e demolite. Alla fine la causa era **un conto di
somme sui dati**: due gettoni obbligatori su una Regione, una strada che ne
vuole due su un'altra, e un tetto di tre.

Quel conto non ha bisogno di una partita. Ha bisogno di leggere venti Destini.

### La classe di difetto, non il caso

I livelli sono **cumulativi** — `destiny_evaluator.gd`, e un test lo inchioda da
tempo («senza Minimum non c'e livello, anche col Triumph vero»). Quindi le
presenze che un Destino chiede si **sommano** dal Minimo in su, e la somma va
confrontata col tetto della Chronicle. Da qui due esiti diversi:

| | |
|---|---|
| gli **obblighi** superano il tetto | il livello e' irraggiungibile, punto |
| gli obblighi ci stanno, ma una **strada** dentro un `some_of` li porta oltre | la strada non e' impossibile — le Conseguenze aggiungono presenze senza passare dal tetto del MOVE — ma percorrerla **spegne una clausola di un livello sotto** |

Il secondo e' il difetto della Cenere, ed e' il piu' insidioso dei due: non
produce un muro visibile, produce un seggio che **perde inseguendo il proprio
Destino**, e nel conto finisce come debolezza della casa.

### Il censimento, e cosa ha trovato

Passati tutti e venti i Destini: sui dati di 0.1.145 **zero**. Sui dati di
0.1.144, prima della correzione, esattamente due righe — la Vittoria e il
Trionfo di `DST_CENERE_DEEP`, che e' il caso vero e l'unico che ci fosse.

**Il difetto era unico in tutto il gioco, e il conto lo trova in un istante.**

### La guardia

Il controllo vive in `tools/validate_data.py` (`check_destiny_token_budget`),
gia' nella CI col resto dei controlli sui dati. Non e' una sonda che si lancia
quando viene in mente: e' un pavimento, come `dead_code.py` dopo il bottone
della stanza (D-140). La lezione e' la stessa di allora — *il rimedio non e' un
test sul caso, e' un controllo che legge tutto*.

E le guardie hanno la loro prova che mordono: `--self-test` le fa girare su tre
Destini sintetici — uno sano, uno col difetto della Cenere ridotto all'osso, uno
con quattro gettoni obbligatori su tre — e pretende che taccia sul primo e parli
sugli altri due. Gira nella CI **prima** dei dati veri, perche' una guardia che
nessuno ha mai visto mordere non e' una guardia (D-144).

### E l'altra faccia della stessa moneta, che ha morso subito

Scritta la prima guardia, la domanda successiva veniva da se': se un livello
sotto puo' **falsificare** una clausola di sopra, puo' anche **regalarla**?

`check_destiny_free_roads` fa quel conto: per ogni `some_of`, quante delle sue
strade sono gia' vere per obbligo di un livello inferiore. Se il Trionfo chiede
«tre segni fra questi sei» e uno dei sei e' obbligatorio nella Vittoria, allora
il `min: 3` e' in realta' un `min: 2` su cinque, **e nessuno l'ha deciso**.

Su venti Destini ha trovato una riga sola, e non era vecchia: era **mia, di
ieri**. Rendendo la reliquia obbligatoria nella Vittoria di `DST_CENERE_DEEP`
(D-177) avevo acceso da solo il primo ramo del suo Trionfo.

**Ed e' la spiegazione della bimodalita' che D-177 aveva dichiarato senza
saperla spiegare**: 8 Minimi, **1** Vittoria, 7 Trionfi. Il Trionfo era diventato
quasi gratuito per chiunque avesse passato la Vittoria.

Tolto il ramo ridondante — resta `min: 3` su cinque strade vere:

| `DST_CENERE_DEEP` | N / M / V / T su 16 | supera |
|---|---|---|
| base 0.1.144 | 0 / 9 / 3 / 4 | 44% |
| 0.1.145 | 0 / 8 / **1** / 7 | 50% — bimodale |
| **0.1.146** | 0 / 8 / **5** / 3 | 50% — una scala |

Stesso 50% sopra il Minimo, distribuito come una scala invece che come un salto.
Playtest **FAIL 256 · 78 · 100 · 145**, mediana 6, **0 su 8** misto e uniforme;
Kessa a tavolo misto da 0/29/9/12 a **0/29/13/8**.

### Quello che si dichiara

- **Il conto guarda solo i gettoni e le strade regalate.** Un Destino puo'
  combattersi da solo in altri modi che nessuna delle due guardie vede: una
  clausola che chiede un tag e una che lo vieta, un livello che vuole una
  cicatrice e quello sopra che la proibisce. Non ce ne sono oggi, e non c'e' un
  controllo che lo dica.
- **Le asserzioni della suite scendono da 6445 a 6444**, e il motivo e' innocuo:
  `test_data_boot` ne fa una per ogni `state_tag_present` di ogni Destino — per
  pretendere che qualcosa al mondo sappia scrivere quel tag — e una condizione
  in meno e' un controllo in meno. La copertura resta: `discovery:relic` e'
  ancora nella Vittoria dello stesso Destino. I test restano **349**.
- **Il tetto usato e' il piu' stretto fra le Chronicle** (oggi tre ovunque), per
  via dei Destini condivisibili che vivono in piu' di una. Se una Chronicle
  nascesse con un tetto diverso, il conto resterebbe corretto ma prudente.
- **Non cambia niente in gioco**: nessun dato toccato, solo strumenti e CI. Il
  playtest e la suite sono quelli di 0.1.145 per costruzione.
- **Un difetto trovato per strada e non corretto**: i messaggi del validatore
  nominano il file sbagliato quando un tipo di documento vive in piu' file
  (`origins` tiene il **primo**, e i Destini stanno in tre file). Il controllo
  nuovo lo aggira nominando l'id invece del percorso; gli altri no. E' piccolo e
  preesistente, ma chi tocchera' quel file adesso lo sa.

---

## D-177 — Il Destino che si combatteva da solo
**implemented in 0.1.145** (la voce nuova di D-176, aperta come ISSUES 45)

D-176 aveva chiuso ISSUES 35 e lasciato una voce: *la linea della Cenere/Fuochi
arriva al secondo gradino la meta' delle volte delle altre, in ogni sua
incarnazione*. Questa e' la voce, e la causa non e' quella che sembrava.

### Quello che la misura ha trovato, e non era una debolezza

La sonda delle ere contava i livelli per incarnazione, non le **clausole**. Le e'
stato aggiunto il conto di cosa manca quando un anno chiude a NONE, e la prima
riga era gia' una risposta: su 120 anni della saga del Sale, **tutti e tredici i
NONE sono della Cenere, e le altre tre case non perdono mai**.

| | NONE | supera il Minimo |
|---|---|---|
| **ENT_CENERE** | **13** | 26% |
| ENT_LIBERE | 0 | 24% |
| ENT_SALE | 0 | 58% |
| ENT_VETRO | 0 | 43% |

E tutti e tredici per la stessa clausola: «Le Montagne Rosse sono presidiate, non
solo abitate» — il Minimo, `region_presence min: 2`.

### Due ipotesi scritte e demolite dalla misura

**La prima**: 2 gettoni su Montagne piu' 2 su Miniere fanno 4, e il tetto e' 3 —
quindi la clausola e' impossibile e il Destino ha una porta sola. **Falsa**: la
sonda delle clausole la da' **vera il 35% delle volte**, perche' le Conseguenze
aggiungono presenze senza passare dal tetto del MOVE (la media dei gettoni della
Cenere a fine anno e' 3,46, non 3).

**La seconda**: le Montagne Rosse sono l'unica Regione a **tre** slot invece di
quattro, quindi la casa viene soffocata da chi ci entra. **Falsa**: le pedine
altrui a fine anno sono **0,15** negli anni persi e 0,07 negli altri. Nessuno ci
va. La Regione e' vuota.

### La causa, che nessuna delle due ipotesi vedeva

| | pedine altrui | **sue sulle Montagne** | **sue sulle Miniere** | gettoni |
|---|---|---|---|---|
| negli anni a NONE | 0,15 | **1,00** | **1,92** | 3,46 |
| in tutti gli altri | 0,07 | 1,67 | 1,04 | 3,49 |

**Lo stesso numero di gettoni. Cambia solo dove stanno.** Negli anni che
finiscono a NONE la Cenere e' scesa nelle Miniere in due — «O sono scesi in due,
e non hanno solo guardato», una clausola della **sua stessa Vittoria** — e cosi'
facendo ha lasciato le Montagne con un gettone solo, spegnendo il proprio Minimo.
I livelli sono cumulativi: inseguire quella Vittoria significa perdere il Minimo
che la regge.

**La casa non perdeva perche' era debole. Perdeva perche' inseguiva il proprio
Destino.** E' la forma del difetto del seme 15308 (ISSUES 21, l'avviso «questa
mossa spegne»), ma scritta nei dati invece che giocata da un distratto — e i bot
l'avviso non ce l'hanno.

Il testo lo diceva gia', e nessuno l'aveva letto come un conto: *«E' lo stesso
desiderio di prima, con meno margine.»* Il margine non era meno: era **negativo**.
`DST_CENERE_DEEP` («Piu' a Fondo») aveva ereditato pari pari il Minimo di
`DST_CENERE` («La Montagna e' Nostra»), dove presidiare in due ha senso. In un
Destino che chiede di **scendere**, chiedere di restare su in due e' una
contraddizione.

### La correzione: il Minimo che il Destino voleva

Il Minimo di `DST_CENERE_DEEP` diventa «**Non hanno lasciato la montagna**» —
`entity_alive` (che la Cenere era l'unica delle quattro case a non avere) piu'
**un** gettone sulle Montagne Rosse. Un gettone resta su, due scendono: e' esatta-
mente l'immagine del Destino, e con tre gettoni ci sta.

E la Vittoria, che era fatta di due regali (`region_presence min: 1` sulle
Miniere e «le gallerie non sono murate», tutt'e due al 100%) piu' una porta,
chiede adesso **la discesa in due e la reliquia**: la pedina il seggio la muove
da solo, la reliquia gliela deve dare il tavolo.

### Le quattro forme, misurate una alla volta

Sonda dei gradini, 80 Chronicle a tavolo misto, semi da 7000:

| | `DST_CENERE_DEEP` (N/M/V/T su 16) | supera | il gioco |
|---|---|---|---|
| **base** — Minimo a 2 gettoni | 0 / 9 / 3 / 4 | 44% | 54% |
| Minimo a 1, Vittoria invariata | 0 / **0** / 10 / 6 | **100%** — regalo | 56% |
| id., tolta la clausola al 100% | 0 / 0 / 10 / 6 | 100% — era un no-op | 56% |
| **scelta** — Minimo a 1, discesa **e** reliquia | 0 / 8 / 1 / 7 | **50%** | 55% |
| discesa + [reliquia **o** veglia] | 0 / 10 / 2 / 4 | 37% | 53% |

La seconda forma e' il motivo per cui si misura ogni passo: spostare il Minimo
senza toccare la Vittoria non chiudeva il difetto, **lo capovolgeva** — da Destino
che si combatte a Destino regalato, zero Minimi su sedici.

### Le misure

**Playtest 100 semi, il cancello:**

| | base | dopo |
|---|---|---|
| Esiti (misto) | FAIL 248 · 71 · 100 · 144 | **FAIL 256 · 78 · 99 · 146** |
| Consigli (misto) | 5,63 · mediana 6 | 5,79 · mediana 6 |
| Kessa, tavolo misto | 0 / 32 / 10 / 8 | **0 / 29 / 9 / 12** |
| Kessa, tavolo uniforme | 1 / 33 / 13 / 3 | **1 / 21 / 17 / 11** |
| **seggi bloccati** | 0 su 8 | **0 su 8** |

**Saga del Sale, 12 saghe da 10 Chronicle:**

| | base | dopo |
|---|---|---|
| ENT_CENERE | **13** NONE · 76 · 25 · 6 · supera 26% | **0** NONE · 80 · 25 · **15** · supera **33%** |
| ENT_SALE | 0 · 50 · 25 · 45 · 58% | 0 · 39 · 38 · 43 · 68% |
| ENT_VETRO | 0 · 69 · 39 · 12 · 43% | **2** · 59 · 46 · 13 · 49% |
| ENT_LIBERE | 0 · 91 · 16 · 13 · 24% | 0 · 91 · 17 · 12 · 24% |

I volti dei Fuochi passano da **8%–33%** a **22%–50%**; i Maestri stanno fra il
33% e l'83%. La prima saga (CHR_01) e' **identica riga per riga**: il cambiamento
non esce dalla sua Chronicle. Suite **349 test / 6445 asserzioni** verde, sim ed
export identici su due giri.

### Quello che si dichiara

- **I Consigli falliti salgono da 248 a 256.** Il trend diventa 206 → 246 → 248 →
  **256**. Una casa che arriva viva alla fine dell'anno propone e si oppone piu' a
  lungo. E' il costo, ed e' scritto.
- **Il perdere non e' sparito dalla saga: ha cambiato posto.** I 13 NONE della
  Cenere diventano 0, e ne compaiono **2 del Vetro**, per la sua stessa clausola
  («Le gallerie sono presidiate, non solo abitate»). E' una conseguenza vera e
  non un effetto collaterale: le Miniere Antiche hanno quattro slot, e da adesso
  la Cenere ne occupa due per la propria Vittoria. Due case che vogliono le
  stesse gallerie se le contendono. Un NONE che nasce da una contesa vale piu'
  di tredici che nascevano da un Destino che si combatteva da solo — ma il conto
  totale del perdere in questa saga **scende da 13 a 2**, e chi verra' dopo deve
  saperlo.
- **La forma scelta e' bimodale**: 8 Minimi, **1** Vittoria, 7 Trionfi. Chi supera
  il Minimo arriva quasi sempre in cima, perche' il Trionfo e' un `some_of` a 3 su
  6 che la Vittoria nuova quasi gia' contiene. E' il difetto di forma di ISSUES 44
  (Lyra), misurato e non corretto: correggerlo e' tarare il Trionfo, e non e' la
  voce di oggi.
- **La voce di D-176 e' ridotta, non chiusa.** Il divario fra le due linee passa
  da 8–33% contro 50–75% a 22–50% contro 33–83%. Le Custodi della Cenere restano
  la vita piu' debole della saga (22%). Quello che si e' chiuso e' il **difetto
  strutturale**; la debolezza residua della linea resta aperta in ISSUES 45.
- **Nessuna clausola pronta esisteva.** Il banco ha misurato dodici candidate
  (`tools/clause_candidates.json`): tutte quelle che la Cenere poteva ottenere
  restando sulla montagna sono uscite **0%** (il cristallo, la montagna lavorata,
  un'opera nelle gallerie) o **100%** (un'opera sulla montagna, un presidio). Nel
  mondo com'e', quella casa ha poche leve — ed e' un numero che vale per chi
  scrivera' il prossimo Destino dei Fuochi.

---

## D-176 — Le istituzioni non governano diversamente dalle persone
**implemented in 0.1.144** (ISSUES 35 chiusa, e l'ipotesi era falsa)

La saga del Sale mostrava una forma netta: finche' sedevano **persone** —
Maestra Ilve, Priora Ilaria, Maestro Ruel — c'erano Vittorie e due Trionfi; dal
1981, con le **istituzioni** al tavolo, sedici Destini su venti finivano al
Minimo. L'ipotesi scritta era che le istituzioni governassero bene e non
volessero niente.

La voce chiedeva, prima di toccare qualsiasi cosa, una misura precisa: la stessa
saga **a tavolo misto** invece che a policy identiche, e il conto dei livelli
**per incarnazione**. La sonda delle ere adesso lo stampa. Dodici saghe da dieci
Chronicle:

| | supera il Minimo |
|---|---|
| le **otto istituzioni** | **41%** |
| le **quindici persone** | **42%** |

**Un punto.** Chi siede non c'entra niente, e l'ipotesi era sbagliata.

### Quello che c'entra e' la casa

La distanza vera sta **dentro** le due categorie, non fra loro:

| chi siede | supera il Minimo |
|---|---|
| La Compagnia del Sale | **68%** |
| Il Banco Nero | 64% |
| Maestra Ilve, Maestra Sadin, Maestro Ordan | **67%** |
| Maestro Ruel | 62% |
| I Frati del Vetro | 48% |
| Le Citta' Libere | 35% |
| La Lega delle Sette | 32% |
| L'Egemonia di Eredan | 31% |
| Kessa dei Fuochi | 17% |
| **Le Custodi della Cenere** | **14%** |
| **Neve dei Fuochi** | **8%** |

Un'istituzione al 68% e una al 14% sono lontane fra loro quanto le due persone
agli estremi. E la linea che va male va male **con chiunque la porti**: i cinque
volti dei Fuochi stanno fra l'8% e il 46%, i cinque Maestri fra il 46% e il 67%.

**Non e' un problema delle vite tardive, e' il Destino di una casa.**

### Perche' la forma si vedeva lo stesso

Perche' nella saga del Sale l'ordine delle incarnazioni mette le istituzioni
**dopo**, e dopo il mondo e' piu' segnato: piu' cicatrici, piu' Tensioni alte,
piu' conti aperti. La correlazione c'era; la causa era il **momento**, non il
soggetto. E' un errore che vale la pena tenere a mente, perche' e' esattamente
il modo in cui una saga racconta una cosa e i numeri ne dicono un'altra.

**Resta una voce nuova** per chi la vorra' aprire: la linea della Cenere/Fuochi
arriva al secondo gradino la meta' delle volte delle altre, in ogni sua
incarnazione. E' li' che va guardata.

---

## D-175 — Tre Conseguenze che costruiscono, e mezza ISSUES 37 chiusa
**implemented in 0.1.143**

### Le Conseguenze che scrivevano un segno senza niente sotto

D-162 aveva chiuso «la fine del segno che non ha un oggetto sotto» per le opere.
Ne restavano quattro fuori. Guardate una per una, tre andavano convertite e una
no:

| | il segno | adesso costruisce |
|---|---|---|
| `CNS_NAHR_SETTLEMENT` «Chi Lavora Mangia» | `settlement:$proponent` | un **villaggio** che ha un padrone e puo' diventare borgo e citta' |
| `CNS_MARCH_GRANTED` «La Marca Concessa» | `settlement:march` | una **torre di veglia** — due punti di forza sulla Regione data |
| `CNS_MARKET_MOVED` «Il Mercato Spostato» | `settlement:market` | un **villaggio**: la gente che si mette intorno al mercato resta anche quando il mercato riparte |
| `CNS_RELIC_BURIED` «La Teca Murata» | `structure:sealed` | **niente** — la cella murata non e' nessuna delle nove cose del catalogo, e inventarne una decima per una Conseguenza sola sarebbe la tentazione di D-164 |

I segni restano: le regole li leggono, e dicono una cosa diversa dall'oggetto
(«qui vive questa gente» non e' «c'e' un villaggio»). Quello che cambia e' che
adesso sotto c'e' qualcosa che pesa nel conto del controllo e che sopravvive
all'anno.

**La piu' interessante e' la marca.** `CNS_MARCH_GRANTED` assegnava il controllo
di una Regione e ci scriveva sopra un segno — e dal round dopo il conto del
controllo poteva ridarla a chi ci aveva piu' pedine. Una concessione che non si
difende non e' una concessione. La torre e' quello che la tiene.

Misurato: le pietre **alzate giocando** salgono a **174 su 80 partite**, contro le
poche di prima; i gradini restano dove stavano (supera il Minimo 54%, TRIONFO
19%), il playtest e' invariato.

### Mezza ISSUES 37 si chiude da sola

La voce diceva «la mappa non si muove». Non e' piu' vero, e non l'ha risolto una
correzione mirata: l'ha risolto **il padrone che si conta invece di scriverlo**
(D-158). Caselle con un padrone dal 56% all'**82%**, seggi a zero Regioni dal 30%
all'**11%**, seggi con due dal 12% al **31%**.

Resta l'altra meta', e adesso ha un nome preciso: **`ACT_CLAIM` muore in mano
tre volte su quattro** — 128 aperte, 18 forzate, **110 morte** su 80 Chronicle.
Il punto di rottura non e' un difetto del codice, e' **§10 del regolamento**: il
Claim deve essere stato posato in un round precedente, quindi chi rivendica deve
indovinare un round prima che la domanda sara' matura, che nessuno avra' gia'
forzato un Consiglio, e di avere ancora un secondo AUTORITA' in mano.

**Non l'ho toccata**, e la ragione e' la stessa per cui non ho allargato la banda
dei Consigli senza chiedere: cambiare §10 e' cambiare il regolamento, non
bilanciare un numero. La strada piu' piccola che si vede e' scritta nella voce.

### Misure

Playtest 100 semi: **FAIL 248 · SUCC 71 · SUCC 100 · DECI 144**, mediana 6,
misto e uniforme **0 su 8**, nessun seggio a NONE ne' a zero Trionfi. Sonda dei
gradini: 0 NONE, TRIONFO 19%, supera il Minimo 54%. Suite **349 test / 6445
asserzioni** verde.

---

## D-174 — Tre voci chiuse: il sigillo che riscriveva la storia, il grado che è materia di saga, e un divario che non c'era
**implemented in 0.1.142** (ISSUES 41 e 42 chiuse, ISSUES 40 decisa)

### ISSUES 41 — il sito antico non era mai «aperto e ancora intero»

La sonda dava due righe con lo stesso numero: sito **aperto** 25%, sito
**saccheggiato** 25%. Gli stessi anni. Il grado di mezzo — quello che insegna —
non era uno stato: era un fotogramma fra due Consigli.

Guardate le tre Conseguenze che lo muovono, la colpevole non era nessuna delle
due che ci si aspetta:

| | |
|---|---|
| `CNS_MINE_REOPENED` | *«Si toglie la pietra... Sotto, tutto è come lo si era lasciato»* → grado 2 |
| `CNS_CRYSTAL_EXPLOITED` | *«Il Cristallo Rosso esce dalle gallerie a peso»* → grado 3 |
| `CNS_MINE_SEALED` | *«Le gallerie vengono chiuse»* → **grado 1** |

Le prime due sono giuste, e che un anno che fa tutte e due finisca col sito
svuotato e' onesto. La terza no: **murare un sito saccheggiato lo rimandava a
«dormiente»**, cioe' cancellava il fatto che fosse mai stato aperto e svuotato.
Un sigillo nasconde, non restituisce.

Adesso il sigillo porta il sito al **grado di mezzo**: aperto, e da oggi
irraggiungibile. Misurato subito dopo, sulla riga di Lyra:

| | prima | dopo |
|---|---|---|
| il sito e' stato aperto | 25% | **80%** |
| il sito e' stato saccheggiato | 25% | **60%** |
| **aperto e ancora intero** | **0%** | **20%** |

Un anno su cinque il mondo si ferma sul gradino di mezzo. Adesso «aperto e
ancora intero» e' una clausola scrivibile.

### ISSUES 40 — il grado alto e' materia di saga, e resta tale

La voce chiedeva di scegliere fra due strade: accettare che il grado sia roba da
saga, oppure aprire un secondo momento in cui una pietra sale dentro l'anno.

**Scelgo la prima, e la scrivo perche' non venga riaperta per distrazione.** La
scala che segue il Destino (D-159) e' il cuore del meccanismo: una reggia e' il
sedimento di tre anni buoni, e vale proprio perche' non si compra in una sera. La
saga del Regno che si e' seduto lo mostra meglio di qualsiasi misura — villaggio
812, borgo 813, granaio 814, citta' 815, castello 816, **reggia 818**.

La regola che ne segue: **una clausola sul grado 2 o 3 si scrive solo nei Destini
di una Chronicle successiva**, mai in quelli d'apertura. Chi la scrive altrove
sta scrivendo un muro, e adesso c'e' un verbale che lo dice.

### ISSUES 42 — il divario fra le due saghe non era delle saghe

CHR_03 portava 49 Trionfi contro i 30 di CHR_01. La voce elencava tre cause
possibili e chiedeva di misurarle a parita' di tavolo. Misurate tutte e tre:

| ipotesi | misura | verdetto |
|---|---|---|
| i Destini della seconda saga **chiedono meno** | clausole mancate: CHR_01 **38%**, CHR_03 **41%** | **falsa** — sono piu' dure |
| le sue Tensioni **si muovono di piu'** | Consigli per partita: CHR_01 **5,83**, CHR_03 **5,33** | **falsa** — ne ha meno |
| ha una casa che **parte senza Regioni** | ne hanno una a testa (Lyra, il Vetro), e i seggi di CHR_01 finiscono con **piu'** terra (1,28 contro 1,17) | **falsa** |

Nessuna delle tre. E la ragione vera si e' vista da sola aprendo il pool
(D-173): **il divario non era delle saghe, era degli otto Destini che si
giocavano.** Con venti in gioco invece di otto, il carico si distribuisce e le
due convergono:

| | prima | ora |
|---|---|---|
| CHR_01 | 30 | **22 su 113 seggi-partita (19%)** |
| CHR_03 | 49 | **25 su 107 seggi-partita (23%)** |
| condivisi | — | 16 su 100 (16%) |

Quattro punti di scarto. **Chiusa** — e con una lezione che vale oltre questa
voce: *prima di tarare tre manopole, vale la pena guardare se il difetto non sia
un effetto di quello che si sta gia' cambiando altrove.*

### Misure

Playtest 100 semi invariato rispetto a D-173: **FAIL 246 · SUCC 73 · SUCC 100 ·
DECI 144**, mediana 6, misto e uniforme **0 su 8**, nessun seggio a NONE, nessuno
a zero Trionfi. Sonda dei gradini 80 Chronicle: **0 NONE**, TRIONFO 20%.
Suite **349 test / 6443 asserzioni** verde; sims deterministici; `dead_code.py`
pulito su 155 file.

La sonda dei gradini adesso stampa anche i **Consigli chiusi per saga**: era la
misura che ISSUES 42 chiedeva e non c'era.

---

## D-173 — Il pool si accende: venti Destini invece di otto
**implemented in 0.1.141** (ISSUES 43 chiusa)

D-170 aveva acceso il pool per misurarlo e l'aveva rispento: supera il Minimo
dal 62% al 50%, un seggio su dodici a NONE. Le sei riscritture di allora avevano
portato a 53% e 7%, e la issue era rimasta aperta con dentro la lista di cosa
mancava. Questa e' quella lista, fatta.

### Le tre che restavano

| Destino | il difetto | cosa e' diventato |
|---|---|---|
| `DST_SHARED_RENOWN` | il **Minimo** chiedeva la fama, che i suoi portatori hanno il 35-50% delle volte: 20 seggi su 41 non arrivavano al primo gradino | Minimo «la casa e' ancora al tavolo», la fama sale alla Vittoria |
| `DST_SHARED_ACCOUNTS` | il **Minimo** chiedeva che nessuna proposta fosse caduta — una moneta lanciata | stesso Minimo, e la Vittoria e' la domanda chiusa |
| `DST_ALDRIC_RECORD` | la Vittoria chiedeva **due Regioni**, mancate all'88% | spina «nessuna questione aperta» piu' un segno su quattro |

**La lezione, ed e' la seconda volta che la incontro:** un Minimo non e' un
obiettivo, e' una soglia di sopravvivenza. Le due carte condivisibili chiedevano
al primo gradino una cosa che si ottiene giocando — la fama, il registro pulito
— e un seggio che non ce la faceva restava fuori dal gioco al primo colpo. Le
carte scritte per **otto case diverse** sono il posto dove questo errore costa
di piu': una casa di casa sua puo' avere un Minimo esigente perche' e' scritto
addosso a lei, una carta condivisibile no.

### Cosa costa accendere

| | pool spento (`main`) | **pool acceso** |
|---|---|---|
| Destini giocati all'apertura | 8 su 20 | **20 su 20** |
| seggi a **NONE** | 4 su 800 | **0** |
| Trionfi del tavolo | 86 | **82** |
| seggi con zero Trionfi | 0 | 0 |
| tavolo misto / uniforme | 0 su 8 | **0 su 8** |
| mediana dei Consigli | 6 | **6** |
| **Consigli falliti** | 206 | **246** |
| Consigli decisivi | 187 | **144** |

**Il costo dichiarato sono quaranta Consigli falliti in piu' su cento partite**,
ed e' il numero piu' alto che questo progetto abbia mai misurato. La causa non e'
oscura: **undici ambizioni in piu' al tavolo vogliono undici cose in piu'**, e le
proposte si oppongono fra loro molto piu' spesso. Il tasso di successo passa dal
64% al 56%.

Non e' una tassa nascosta: e' quello che succede quando quattro case che
inseguono sempre le stesse quattro cose diventano quattro case che potrebbero
inseguirne venti. Tutte le guardie che il progetto si e' dato reggono — **0 su 8**
su tutti e due i tavoli, mediana 6, nessun seggio a zero Trionfi, nessun seggio
a NONE — e la varieta' e' l'intera ragione per cui D-150 aveva costruito il
meccanismo: *«alla terza partita tutti sanno cosa vuole l'altro»*.

**Si spegne in una riga**, se il committente decide che quaranta Consigli sono
troppi: in `world_state_factory.gd`, `_deal_destiny`, togliere il ripiego sulla
lista dell'Entita' e il pool torna a esistere solo se una Chronicle lo dichiara —
cioe' mai.

### Misure

Playtest 100 semi, tavolo misto, per seggio (NONE/MIN/VIC/TRI su 50):

| seggio | prima | dopo |
|---|---|---|
| Re Aldric | 1 · 26/18/5 | **0** · 29/16/5 |
| Kessa dei Fuochi | 0 · 19/23/8 | 0 · 32/10/8 |
| Le Citta' Libere | 1 · 10/27/12 | **0** · 19/14/**17** |
| Lyra | 0 · 32/12/6 | 0 · **17/28**/5 |
| Popolo Nahr | 1 · 23/10/16 | **0** · 15/16/**19** |
| Maestra Ilve | 0 · 7/30/13 | 0 · 19/15/16 |
| Vaerax | 0 · 24/16/10 | 0 · 27/17/6 |
| Priore Anselmo | 1 · 6/27/16 | **0** · 20/24/6 |

Sonda dei gradini su 80 Chronicle: **0 NONE**, TRIONFO **20%**, supera il Minimo
**54%**. Suite **349 test / 6438 asserzioni** verde; sims deterministici;
`dead_code.py` pulito su 155 file; schemi e manifest allineati.

**ISSUES 43 chiusa.**

---

## D-172 — Il bot smette di sbirciare e guarda come si e' votato
**implemented in 0.1.140** (il debito che D-171 aveva dichiarato, pagato subito)

D-171 aveva chiuso con una riga onesta sul manico della funzione: *un bot legge
il Destino degli altri, e un giocatore vero no.* Al tavolo quell'informazione
arriva da **come gli altri votano**, non dalla loro carta. Questo e' quel debito
pagato, e si e' rivelato non un pareggio ma un guadagno su quasi tutto.

### Il registro

`world["voted_together"]`: per ogni coppia, quante volte sono finiti sullo
stesso fronte del Consiglio meno quante volte su fronti opposti. Contano solo i
fronti dichiarati — chi si astiene non dice niente su nessuno. Scritto alla
chiusura di ogni Consiglio, accanto a `confluence_count`, **come contatore
diretto e non come Effetto**: non e' una mutazione che qualcuno possa voler
annullare, ed e' lo stesso trattamento che hanno gia' `confluence_count` e
`resolved_count`.

E' la memoria **dei bot**, non un fatto del mondo: e' quello che chiunque sieda
al Consiglio vede con i propri occhi, e niente di piu'.

### Cosa cambia rispetto a D-171

| | `main` | D-171 (sbircia il Destino) | **D-172 (guarda i voti)** |
|---|---|---|---|
| Trionfi del tavolo | 86 | **74** | **83** |
| seggi a NONE | 4 | 1 | 3 |
| FAIL | 203 | 207 | 206 |

**Il prezzo scende da dodici Trionfi a tre.** E il motivo non e' che si allea di
meno: e' che si allea **meglio**. Sbirciando il Destino, due seggi si trovavano
subito e ci restavano; guardando i voti, un legame si stringe dopo che il tavolo
ha gia' deciso qualcosa, cioe' quando l'Occasione spesa serve ancora a qualcosa.

E si distribuisce:

| seggio | `main` | D-171 | **D-172** |
|---|---|---|---|
| Re Aldric | 0% | 10% | **20%** |
| Lyra | 0% | **45%** | 15% |
| Popolo Nahr | 0% | **45%** | 30% |
| Vaerax | 0% | 5% | **35%** |
| Kessa | 25% | 50% | 35% |

D-171 accendeva due seggi molto e lasciava fuori Aldric e Vaerax, che avevano
un'opposizione **dichiarata** addosso e quindi erano esclusi per regola. I voti
non conoscono quella regola: due che si oppongono su un segno possono benissimo
essersi trovati dalla stessa parte su tre domande diverse, ed e' vero — al
tavolo succede continuamente. La banda passa da 5-50% a **15-35%**.

### E si sbaglia, che e' il punto

Un legame stretto su tre Consigli condivisi puo' rompersi al quarto, e la
memoria non lo prevede: la aggiorna dopo. Un bot che sbircia non sbaglia mai un
alleato; uno che osserva si fida di chi lo ha aiutato finora, che e' la cosa che
un giocatore fa davvero — e la sola su cui si possa costruire un tradimento.

**Prima del primo Consiglio nessuno sa niente di nessuno**, e la regola tace:
c'e' un test che tiene fermo anche quello.

### Misure

Playtest 100 semi, tavolo misto: **FAIL 206 · SUCC 74 · SUCC 107 · DECI 187**,
mediana **6**, misto **0 su 8**, uniforme **0 su 8**. Trionfi **83** (main: 86),
nessun seggio a zero, nessuno bloccato su un gradino.

Suite **348 test / 6486 asserzioni** verde; `run_sims.sh` e `run_export.sh`
identici su due giri; `dead_code.py` pulito su 155 file; schemi e manifest
allineati.

---

## D-171 — L'alleanza che conviene, e il prezzo che non si puo' non pagare
**implemented in 0.1.139** (domanda del committente: «i bot non puoi fare un modo che stringano anche alleanze se conviene loro?»)

**Prima, una correzione a quello che avevo scritto io.** «Nessun bot stringe
alleanze» era troppo forte. `ACT_FORGE` esiste — salire costa una carta BONDS e
il consenso, scendere e' gratis e unilaterale — e la policy la gioca. Il difetto
era piu' stretto: **un seggio stringeva un legame solo se una clausola del suo
Destino nominava quella relazione**, mai perche' gli tornava utile. Le due
clausole che avevo misurato a 0% (Lyra alleata di Aldric, Vaerax non nemico di
Lyra) le avevo inventate io per il banco: nessun Destino le chiede, quindi
nessun bot aveva motivo di muoversi. Dove la clausola c'e', la relazione si
muove — «la Gilda non e' diventata un nemico delle citta'» si avvera un anno su
tre.

### La prima forma non ha sparato una volta, e ha trovato una cosa sul contenuto

Scritta cosi': **ti allei con chi vuole i tuoi stessi segni**. Semplice, si
spiega in una frase a un tavolo di persone, e il tornaconto e' gia' in gioco
(D-139: un alleato che sostiene il proponente porta +1 sul fronte, +2 se BOUND).

Zero legami stretti su quaranta Chronicle. Il motivo non era il codice:

| tavolo | coppie con un segno in comune | punteggio |
|---|---|---|
| CHR_01 | Aldric–Nahr su `crown_divided` | **−1** |
| CHR_01 | Lyra–Vaerax su `mine_sealed` | **−1** |
| CHR_03 | Sale–Libere su `debt_forgiven` | **−1** |

**Fra gli otto Destini del gioco non esiste una coppia che voglia lo stesso
segno nello stesso verso.** Ogni sovrapposizione e' un'opposizione, e tutto il
resto e' indifferenza: il contenuto e' scritto come una rete di contrasti.
Un'alleanza costruita sugli obiettivi comuni non ha niente su cui mordere. (Le
alleanze che si vedevano su CHR_03 — il Vetro e le Citta' al 100% — sono
**relazioni d'apertura scritte a mano** nelle Entita', non forgiate da nessuno.)

C'e' un test che tiene fermo quel fatto, perche' se un domani due Destini
vorranno la stessa cosa e' un cambio di contenuto da vedere.

### La forma che funziona: si allea chi aspetta lo stesso Consiglio

`_needed_confluences` dice gia' quali Tensioni un seggio ha bisogno che arrivino
al voto, perche' la sola cosa che chiude una sua clausola sta dietro quella
domanda. **Due seggi che aspettano la stessa domanda staranno sullo stesso
fronte quando si apre**, e li' il legame vale il peso in piu'. Chi mi si oppone
su un segno resta fuori comunque, per quanti Consigli condividiamo.

Il ceto sociale del gioco si accende:

| seggio | prima | dopo |
|---|---|---|
| Lyra | **0%** | **45%** |
| Popolo Nahr | **0%** | **45%** |
| Kessa dei Fuochi | 25% | 50% |
| la Gilda | 25% | 30% |
| Re Aldric | 0% | 10% |
| Vaerax | 0% | 5% |

(quota di anni in cui il seggio finisce con almeno un alleato). Aldric e Vaerax
restano bassi ed e' giusto: sono i due che hanno un'opposizione dichiarata
addosso.

### Il prezzo, e i due quadranti che non lo abbassano

**Trionfi del tavolo da 86 a 74.** Un'alleanza costa un'Occasione e una carta
BONDS, e l'Occasione e' tutta la moneta dell'anno: il seggio che si allea e' il
seggio che non ha fatto altro.

Ho provato le due leve ovvie, e **nessuna delle due esiste**:

| leva | risultato |
|---|---|
| alzare la soglia a **due** Consigli in comune | non spara **mai** — due seggi non aspettano mai due domande insieme |
| spostarla **in coda** alle scelte | non spara **mai** — le voci prima trovano sempre qualcosa da fare |

Il quadrante e' binario: o la regola sta al suo posto e costa dodici Trionfi, o
non c'e'. Che poi e' come dovrebbe essere — **un'alleanza che non costa niente
non e' una scelta**, ed e' esattamente la ragione per cui D-139 aveva imposto le
due carte impegnate.

### Le misure

Playtest 100 semi, tavolo misto: **FAIL 207 · SUCC 68 · SUCC 114 · DECI 179**,
mediana **6**, tavolo misto **0 su 8**, uniforme **0 su 8**. Seggi a NONE da 4 a
**1**. Trionfi **86 → 74**, nessun seggio a zero, nessuno bloccato su un gradino.

Suite **348 test / 6486 asserzioni** verde; sims deterministici; `dead_code.py`
pulito su 154 file.

### Dichiarato

**Un bot legge il Destino degli altri**, e un giocatore vero no: al tavolo
quell'informazione arriva da come gli altri votano, non dalla loro carta. E' una
semplificazione della policy, non una regola del gioco, ed e' scritta sul manico
della funzione. Va rifatta quando i seggi impareranno a dedurre invece che a
sbirciare — ed e' anche la strada che rende la regola piu' interessante: allearsi
con chi **ha votato** come te e' osservabile, e sbagliabile.

---

## D-170 — Gli undici Destini mai giocati, guardati per la prima volta
**implemented in 0.1.138** (ISSUES 43 misurata, e **il pool resta spento**)

ISSUES 43 diceva: `_deal_destiny` pesca da `chronicle["destiny_pool"]`, i pool
sono scritti sulle Entita', nessuna Chronicle ne dichiara uno, quindi **undici
Destini su venti non si giocano mai all'apertura**. E diceva anche che accenderli
alla cieca costa una misura vera. Questa e' la misura.

### Accendere il pool oggi peggiora il gioco

Fatto pescare dalla lista dell'Entita' quando la Chronicle non ne dichiara una —
tre righe — e misurato su 80 Chronicle:

| | pool spento | pool acceso |
|---|---|---|
| supera il Minimo | **62%** | **50%** |
| seggi a NONE | **0%** | **8%** |
| TRIONFO | 20% | 18% |

**Un seggio su dodici finisce l'anno senza nemmeno il Minimo**, cosa che oggi non
succede mai. Il meccanismo e' giusto e la misura dice che il contenuto non e'
pronto: gli undici non sono mai stati bilanciati, perche' nessuna sonda li aveva
mai visti.

### Cinque muri al 100%, e tre Destini fermi

| Destino | com'era |
|---|---|
| `DST_CENERE_DEEP` | **16 su 16 al Minimo**, zero Vittorie: tre clausole mancate al 100% — la reliquia, il patto saltato, due Regioni |
| `DST_NAHR_ROOTED` | 12 su 12 alla Vittoria, **zero Trionfi**: `discovery:legend`, mai guadagnato |
| `DST_SALE_OPEN` | 10 su 13 al Minimo, **zero Trionfi**: lo stesso tag |
| `DST_SHARED_RENOWN` | **20 NONE su 41**: il Minimo chiedeva la fama, che i suoi tre portatori hanno il 35-50% delle volte |
| `DST_SHARED_ACCOUNTS` | 7 NONE su 23, e un **Trionfo piu' facile della Vittoria** — un gradino che non e' un gradino |
| `DST_LIBERE_WATER` | Trionfo al **75%** |

Le sei sono state riscritte nella forma di D-167 — spina piu' scelta — con le
strade misurate prima sul banco della sonda (quaranta candidate, due giri). I
muri non ci sono piu': `CENERE_DEEP` passa da 16/0/0 a **10/1/4**, `NAHR_ROOTED`
da 12 Vittorie e zero Trionfi a **2/3/7**, `SALE_OPEN` da zero Trionfi a 7/5/1.

**E non basta.** Col pool acceso e le sei riscritte: supera il Minimo **53%**,
NONE **7%**. Meglio di 50/8, lontano da 62/0. Restano fuori banda
`DST_ALDRIC_RECORD` (15 su 17 al Minimo) e le due condivisibili, che continuano
a mandare a NONE un seggio su tre.

**Quindi il pool resta spento**, le sei riscritture restano — un Destino senza
muri e' meglio di uno con tre, anche mentre nessuno lo pesca — e ISSUES 43 resta
aperta con dentro il numero che le mancava.

### Il limite della sonda delle clausole, trovato usandola

La sonda di D-167 misura **quanto e' vera una clausola a fine anno**, e lo fa
mentre ogni seggio gioca il **proprio** Destino. Per una clausola scritta in un
Destino che il seggio gia' insegue, e' la misura giusta. Per una scritta in un
Destino che il seggio **non** insegue, no: cambiare Destino cambia cosa quel
seggio propone, e quindi cambia il numero.

Si vede in chiaro su `DST_SHARED_RENOWN`. Il banco diceva «una Regione
controllata» al 100% per Aldric, 100% per le Citta', 80% per il Vetro — quindi
un Minimo sicuro. Coi seggi che la giurano davvero: **13 NONE su 41**.

Non e' un difetto della sonda, e' il suo perimetro, e adesso e' scritto sul
manico: *la sonda dice cosa e' vero nel mondo che c'e'; un Destino nuovo fa un
mondo diverso.* Un Destino che cambia come una casa gioca si misura solo
giocandolo.

### Misure

Col pool spento — cioe' la configurazione che resta — **tutto invariato**:
playtest FAIL 203 · SUCC 77 · SUCC 109 · DECI 187, mediana 6, tavolo misto **0
su 8**, uniforme **0 su 8**, sonda dei gradini 62% sopra il Minimo e 0 NONE.
Le sei riscritture costano **zero** perche' nessuno le pesca, ed e' esattamente
il punto di ISSUES 43.

Suite **343 test / 6548 asserzioni** verde; sims deterministici; `dead_code.py`
pulito su 154 file.

---

## D-169 — Lyra apre, e la banda dei Consigli si sposta con una ragione
**implemented in 0.1.137** (decisione del committente su ISSUES 44: «apri Lyra, la banda si puo' rivedere dopo»)

D-168 aveva misurato il prezzo e lasciato la scelta. La scelta e' fatta.

### Cosa e' cambiato nei Destini

**Lyra.** La Vittoria era una spina gratis piu' un tag al 25%: una porta, non
una scala. Adesso e' la spina — presenza nelle Miniere, che e' l'unica cosa che
il titolo promette — piu' **due segni su tre**: la scorta giurata (25%), le
Miniere non sigillate (45%), un posto sulla mappa che risponde a lei (45%). E il
Trionfo chiede **quattro Scoperte** invece di due, perche' due erano vere nel
100% degli anni misurati: una spina vera nel 100% dei casi non e' una spina.

**Nahr.** La sua scelta scende da quattro segni a **tre**. Non e' bilanciamento
gratuito: aprendo Lyra, Nahr passava da 8 Trionfi a 1 senza che nessuno toccasse
il suo Destino, perche' le sue cinque strade dicono tutte «il mondo e' rimasto
calmo» e Lyra che ricomincia a giocare rende il mondo meno calmo.

### La forma che misurava meglio era rotta, e la misura non bastava a dirlo

Quattro forme provate, tre legittime:

| forma | Lyra | Trionfi del tavolo | gia' vera all'apertura? |
|---|---|---|---|
| oggi (porta sola) | 38/3/9 | 79 | no |
| **2 su 3** | **32/12/6** | **86** | **no** |
| 2 su 5 | 27/16/7 | **91** | **si' — scartata** |
| 3 su 5 | 37/8/5 | 85 | no |

La 2 su 5 e' la migliore su ogni numero, ed e' quella che ho scartato: due delle
cinque strade sono vere sulla posizione d'apertura, quindi **una parte di quelle
Vittorie erano regalate**. E' esattamente il difetto che la sonda di D-167 era
stata scritta per trovare in casa d'altri, trovato stavolta in casa mia, e non
dai numeri — i numeri lo premiavano — ma da un test che valuta il Destino prima
che qualcuno giochi.

**La regola che ne esce**: quando una forma misura meglio di tutte le altre,
prima di tenerla si controlla che non stia misurando bene per il motivo
sbagliato.

### La banda, e perche' non e' spostare il paletto

La mediana dei Consigli passa da 6 a 7. Il soffitto va da 6 a **7** in tutte e
due le bande — l'anno scritto (`test_balance.gd`) e l'anno pescato
(`test_library_balance.gd`) — e **i limiti duri non si muovono**: 2 e 8, il
pavimento che §7 difende davvero.

Tre ragioni, in ordine di peso:

1. **E' gia' successo, per lo stesso motivo.** D-051: la Vittoria di Vaerax era
   fatta di clausole vere prima dell'inizio, lui non giocava, gliela si e'
   chiusa e l'anno si e' alzato. Il commento sopra la costante lo racconta da
   allora. Un seggio che ricomincia a giocare fa l'anno piu' rumoroso.
2. **La banda nuova e' ancora piu' stretta di quella che §7 scrive.** §7 chiede
   1,5-2,0 Consigli per Tensione; con quattro Tensioni fa 6-8. 5-7 e' 1,25-1,75:
   dentro, e da sotto.
3. **Il prezzo era stato misurato prima di chiederlo**, e nessuna forma della
   clausola lo evita: 2 su 5, 2 su 3, e perfino un `any_of` su due di cui una
   passiva danno tutti mediana 7 (D-168). Non e' la dimensione della scelta, e'
   che la Vittoria diventa raggiungibile.

### Le misure

Playtest 100 semi, tavolo misto, 50 partite per seggio:

| seggio | prima | dopo |
|---|---|---|
| Lyra | 38/3/**9** | **32/12/6** |
| Popolo Nahr | 24/16/**9** | 23/10/**16** |
| Vaerax | 18/26/**6** | 24/16/**10** |
| Re Aldric | 26/18/**6** | 26/18/**5** |
| gli altri quattro | — | invariati |

**Trionfi 79 → 86**, nessun seggio a zero, tavolo misto **0 su 8**, uniforme
**0 su 8**, mediana 6, media 5,76. Costo dichiarato: **FAIL 191 → 203**.

Sonda dei gradini (60 Chronicle): supera il Minimo **62%**, TRIONFO **20%**,
nessun seggio a NONE. Lyra da 21/3/6 a **15/9/6** su 30.

Suite **343 test / 6548 asserzioni** verde; `run_sims.sh` e `run_export.sh`
identici su due giri; `dead_code.py` pulito su 154 file.

**ISSUES 44 chiusa.**

---

## D-168 — La scala di Lyra ha una porta sola, e aprirla costa gli anni tranquilli
**misurato, non implementato** (nessuna modifica ai dati)

Avevo dichiarato in 0.1.134 che Lyra non era migliorata — 38 Minimi su 50, il
seggio piu' debole del tavolo. Questo e' il giro per capirlo, fatto con la sonda
delle clausole invece che a occhio, e **finisce senza un commit sui Destini**:
quello che ha trovato non e' un bilanciamento da correggere, e' una scelta da
fare.

### Non e' debole: e' bimodale

La sonda delle clausole, letta sulla riga `ENT_LYRA` (20 Chronicle):

| clausola | vera a fine anno |
|---|---|
| Lyra e' viva + **una Scoperta** (il suo Minimo) | ~100% |
| **presenza nelle Miniere** (la spina della Vittoria) | **100%** |
| **la scorta giurata** (l'altra meta' della Vittoria) | **25%** |
| **due Scoperte** (la spina del Trionfo) | **100%** |

Il suo Minimo e' gratis. La spina della Vittoria e' gratis. La spina del Trionfo
e' gratis. **Tutta la scala pende da un tag solo al 25%** — `escort_sworn`, che
`CNS_ESCORT_SWORN` da' al `$proponent`, quindi Lyra deve proporre *e* vincere
quel Consiglio.

Ecco perche' legge 38/3/9 e non 38/9/3: **non e' una scala, e' una porta.** Chi
non la apre resta al Minimo; chi la apre arriva quasi sempre in fondo, perche'
dopo non c'e' altro da pagare.

### Tre modi di aprirla, e tutti e tre costano la stessa cosa

| variante | mediana dei Consigli |
|---|---|
| oggi (porta sola) | **6** ✓ |
| solo la spina del Trionfo a quattro Scoperte | **6** ✓ |
| scelta 2 su 5 nella Vittoria | **7** ✗ |
| scelta 2 su 3 nella Vittoria | **7** ✗ |
| `any_of` su due, di cui una passiva | **7** ✗ |

Non e' la *dimensione* della scelta: e' che la Vittoria diventa **raggiungibile**.
E non e' rumore di campione — la distribuzione si sposta intera:

```
oggi        [3, 4, 5,5,5,5,5,5,5,5,5, 6,6,6,6,6, 7,7,7,7,7,7,7, 8]
con Lyra    [   4, 5,             6,6,6,6,6,6,6,6, 7,7,7,7,7,7,7,7,7,7,7, 8,8,8]
```

**Gli anni tranquilli spariscono.** La coda bassa — la partita da tre Consigli,
quella da quattro, otto partite da cinque — non esiste piu'.

### La lettura, che vale oltre Lyra

Un seggio la cui Vittoria e' chiusa **smette di giocare**: la sua policy non ha
obiettivi aperti, non propone, non forza. Le partite quiete di oggi sono in
buona parte partite in cui Lyra e' spettatrice. Aprire un seggio bloccato non e'
una correzione locale: **e' aggiungere un giocatore al tavolo**, e il tavolo
diventa piu' rumoroso di conseguenza.

Vale anche al contrario, e spiega qualcosa di gia' misurato: quando ho aperto la
Vittoria di Lyra, Nahr e' passata da 8 Trionfi a 1 (sonda dei gradini, 30
Chronicle), perche' le sue cinque strade sono tutte «il mondo e' rimasto calmo».
Nessuno aveva toccato il Destino di Nahr.

### Perche' non ho scelto io

Il costo cade su **una guardia della casa**: la banda dei Consigli, mediana 5-6
con 4 Tensioni. Allargarla per far passare una modifica e' spostare il paletto
dopo aver tirato. E il guadagno e' reale ma non enorme: nella misura piena a 100
semi la scala di Lyra diventa 27/14/9 invece di 38/3/9, e i Trionfi del tavolo
salgono da 79 a 91.

Quindi: **la scelta e' fra un seggio che gioca e gli anni tranquilli.** E'
ISSUES 44, e la decido io solo se il committente mi dice di deciderla.

Cosa resta committato di questo giro: il banco della sonda con le diciassette
clausole di Lyra misurate, che e' la prova, e questo verbale.

### Due numeri che il giro ha trovato per strada

- **Le clausole sociali sono ancora esattamente zero.** «Aldric le e' alleato o
  meglio»: **0%**. «Vaerax non le e' nemico»: **0%**. E' la seconda domanda di
  D-151, che finora avevo sempre dichiarato senza misurarla — adesso ha un
  numero, ed e' zero su 20 partite.
- **«Una pedina sua sulla Strada dei Mercanti»: 0%.** Lyra non si muove mai da
  li'. Una clausola sulla mappa scritta per lei sarebbe stata un muro.

---

## D-167 — La spina e la scelta: il Trionfo smette di essere una lista
**implemented in 0.1.134** (richiesta del committente sui Destini, ripresa da D-161)

«Le condizioni di vittoria, i destini li farei diversi, una serie di condizioni
che se soddisfatte danno il grado di vittoria. E tra le condizioni ci puo'
essere le cose piu' disparate includendo anche gli edifici e/o il controllo e/o
le cicatrici.»

D-161 aveva costruito il vocabolario — `structure_count`, `scar_count`,
`some_of` — e poi **l'aveva lasciato spento**, perche' le clausole scritte a
occhio erano tre muri e due regali. La regola che mi ero dato allora era: *una
clausola su uno strato si scrive dopo che quello strato puo' cambiare dentro
l'anno, e si misura sui gradini prima di restare.* Da D-161 a D-166 lo strato e'
nato davvero: dentro i nove round si alzano **80 pietre su 40 Chronicle**, se ne
cambiano di grado 37, e le cicatrici cadono da 1 a 6 per partita.

Quindi prima la misura, poi la scrittura.

### La cosa che nessuno aveva guardato

La sonda dei gradini dice quanto manca una clausola **gia' scritta**. Non
esisteva niente che dicesse quanto mancherebbe una clausola **che non lo e'
ancora**, ed e' esattamente il buco in cui D-161 e' caduto. Ora c'e':
**`cli/run_clause_probe.gd`** legge un file di candidati e riporta, per ogni
casa, la quota di anni in cui quella clausola sarebbe vera a fine anno. Costa un
file di prova invece di un commit da rifare.

La prima tabella che ha stampato (40 Chronicle, tavolo misto, semi da 7000):

| clausola | ALDRIC | CENERE | LIBERE | LYRA | NAHR | SALE | VAERAX | VETRO |
|---|---|---|---|---|---|---|---|---|
| almeno una pietra sua | 100% | 100% | 100% | 30% | 100% | 100% | 100% | 15% |
| almeno due pietre | 50% | 10% | 100% | 15% | 100% | 15% | 10% | 0% |
| almeno tre pietre | 15% | 0% | 60% | 5% | 25% | 5% | 0% | 0% |
| **una pietra di grado 2** | 15% | 5% | 0% | 0% | 10% | 0% | 0% | 0% |
| almeno un'opera | 50% | 10% | 60% | 30% | 25% | 15% | 10% | 15% |
| nessuna cicatrice sul mondo | 0% | 0% | 0% | 0% | 0% | 0% | 0% | 0% |
| almeno tre cicatrici | 75% | 55% | 55% | 75% | 75% | 55% | 75% | 55% |
| Eredan uscita pulita | 25% | 75% | 75% | 25% | 25% | 75% | 25% | 75% |
| due Regioni | 45% | 15% | 100% | 5% | 90% | 20% | 20% | 0% |

Tre letture che valgono piu' della tabella:

1. **Il grado non si muove dentro l'anno.** `_settle_structures` gira *dopo* la
   valutazione del Destino — e' giusto che sia cosi', l'esito decide la scala —
   quindi in una Chronicle sola una pietra di grado 2 esiste solo se e' stata
   ereditata. Una clausola sul grado e' un muro fuori dalla saga: e' ISSUES 40.
2. **Zero cicatrici non capita mai.** Non e' un obiettivo ambizioso, e' una
   lotteria che nessuno ha mai vinto in 40 anni. «Al piu' due» invece e' 25-45%.
3. **Il sito antico, una volta aperto, viene sempre saccheggiato**: aperto 25%,
   saccheggiato 25%, gli stessi anni. «Aperto e non saccheggiato» e' uno zero
   che nessuno ha scritto apposta — ISSUES 41.

### E la cosa peggiore, che la misura ha trovato per prima

Il playtest a tavolo misto, 50 partite per seggio, **prima** di questa seduta:

| seggio | NONE | MINIMO | VITTORIA | TRIONFO |
|---|---|---|---|---|
| Re Aldric | 0 | 26 | 18 | 6 |
| Kessa dei Fuochi | 0 | 19 | 30 | **1** |
| Le Citta' Libere | 2 | 23 | 25 | **0** |
| Lyra | 0 | 35 | 7 | 8 |
| Popolo Nahr | 1 | 25 | 18 | 6 |
| Maestra Ilve | 0 | 10 | 40 | **0** |
| Vaerax | 0 | 21 | 29 | **0** |
| Priore Anselmo | 0 | 16 | 34 | **0** |

**Quattro seggi su otto: zero Trionfi su cinquanta partite.** Due dei quattro
per una ragione sola e verificabile — una clausola mancata il **100%** delle
volte: Vaerax chiedeva `condition:cut_off` sulla Strada dei Mercanti, che niente
scrive mai, e la Gilda chiedeva due Regioni a una casa che ne tiene 0,90 di
media. Una lista in AND con dentro un muro non e' un obiettivo difficile: e' un
gradino tolto dal gioco, e nessuno se ne accorgeva perche' il seggio riportava
comunque VITTORIA.

### La forma nuova

Il MINIMO e la VITTORIA restano liste da soddisfare per intero. Il **TRIONFO**
diventa due cose:

- **la spina** — una o due clausole in AND: quello che quella casa voleva
  davvero. Senza, non e' quel Trionfo;
- **la scelta** — `some_of` con `min` su quattro, cinque o sei strade: come ci
  e' arrivata. Fra le strade ci sono le Tensioni, il controllo, i rapporti, le
  promesse, e adesso **le pietre e le cicatrici**.

Otto Destini riscritti, uno per casa. Gli otto alternativi restano in AND —
**e non sono il gruppo di controllo che avevo scritto qui la prima volta.** La
sonda per Destino, aggiunta subito dopo, dice che in queste misure *non vengono
mai giocati*: `_deal_destiny` pesca da `chronicle["destiny_pool"]` e **nessuna
delle quattro Chronicle ne dichiara uno**, quindi ogni casa insegue sempre il
`destiny_id` scritto sull'Entita'. Gli altri undici Destini — otto alternativi e
tre condivisibili — si vedono solo per successione, dentro una saga. E' ISSUES
43, e la correzione sta qui perche' il verbale sbagliato l'ho scritto io.

Esempio, il Trionfo di Vaerax: spina «le Miniere non sono state svuotate», e
**quattro segni su cinque** fra il Risveglio riportato indietro, le Vie
Interrotte alte, la fame che tiene gli uomini nelle valli, **il passo franato**,
e **un segno che si vede sulle gallerie**. Il muro di prima — la strada tagliata
— e' uscito; al suo posto c'e' una cosa che sta sulla mappa e che qualcuno puo'
far succedere.

### La prova si legge, e i conti aperti pure

Una scelta che non si vede non serve a niente: «tre di queste cinque» non dice
nulla se non si vede quali erano e quali hai preso. `describe_all` apre la
scelta strada per strada, rientrata, e le evidence di fine anno la portano.
E' lo stesso difetto che il committente ha trovato nelle carte — «le frasi sono
belle e non si capisce cosa fanno» — sul foglio che conta di piu'.

E lo stesso vale per i **conti rimasti aperti** (D-087), che non sono prosa: sono
la meta' strutturata delle evidence, quella che il motore 0.3 legge per far
nascere l'era dopo. Una scelta che finisce li' dentro come voce sola direbbe
«tre di queste cinque» senza dire quali due sono cadute — un livello di dettaglio
in meno proprio dove ne ho spostate meta'. `open_roads` mette accanto alla
scelta le strade che non hanno retto, e la sonda dei gradini adesso le attribuisce
al livello giusto invece di stamparle come «?».

### Il difetto che questa seduta ha quasi introdotto

Un seggio legge il proprio Destino per sapere cosa vuole, e quella lettura
guarda **il tipo** della clausola. Una clausola dentro una scelta ha per tipo
`some_of`: spostandone meta' dentro le scelte, **meta' delle ambizioni del
tavolo sarebbero sparite in silenzio** — che e' precisamente D-066, dove l'80%
dei seggi valutava una proposta zero.

Non l'ho visto scrivendo: **l'hanno visto due test** di `test_stance_scoring`,
caduti al primo giro della suite. `PolicyDecider` adesso appiattisce le scelte
per la lettura degli obiettivi, e **non** per il giudizio del livello — «tre di
queste cinque» e' vero anche quando due sono false, e appiattito diventerebbe
una AND. Lo stesso appiattimento mancava in altri tre punti che nessun test
copriva: la ricorsione di `validate_data.py`, quella del controllo sui tag
irraggiungibili in `test_data_boot.gd`, e il controllo che una Chronicle nomini
le proprie Tensioni. Tutti e tre si fermavano al primo livello. Aggiunto anche
un controllo che mancava del tutto: **uno `structure_type` sbagliato** non era
un errore rumoroso, contava zero — cioe' diventava un muro che nessuno aveva
deciso di alzare.

### Le misure

Playtest 100 semi da 7000, tavolo misto, **prima → dopo**:

| seggio | prima | dopo |
|---|---|---|
| Re Aldric | 26/18/**6** | 26/18/**6** |
| Kessa dei Fuochi | 19/30/**1** | 19/23/**8** |
| Le Citta' Libere | 23/25/**0** | 10/27/**12** |
| Lyra | 35/7/**8** | 38/3/**9** |
| Popolo Nahr | 25/18/**6** | 24/16/**9** |
| Maestra Ilve | 10/40/**0** | 7/30/**13** |
| Vaerax | 21/29/**0** | 18/26/**6** |
| Priore Anselmo | 16/34/**0** | 6/27/**16** |

**Trionfi 21 → 79, e nessun seggio a zero.** Esiti **FAIL 207 → 191** ·
SUCC 77 → 69 · SUCC 112 → 116 · DECI 189 → 196. Consigli mediana **6**. Tavolo
misto **0 su 8**, uniforme 1 su 8.

Sonda dei gradini, 60 Chronicle: TRIONFO **6% → 20%**, supera il Minimo
**54% → 63%**, e nessuna clausola mancata al 100%. Destino per Destino i Trionfi
stanno fra 3 e 8 su 30 — nessuno murato, nessuno regalato:

| | ALDRIC | CENERE | LIBERE | LYRA | NAHR | SALE | VAERAX | VETRO |
|---|---|---|---|---|---|---|---|---|
| Trionfi su 30 | 3 | 4 | 7 | 6 | 8 | 7 | 6 | 7 |

Ci sono voluti **quattro giri di misura** per arrivarci: la prima scrittura
mandava Cenere al 75% e le Citta' Libere al 37%, la seconda schiacciava le
Citta' Libere a 1 su 30. Il numero non si indovina — si stringe.

Suite **342 test / 6472 asserzioni** verde; `run_sims.sh` e `run_export.sh`
identici su due giri; `validate_data`, `gen_gd_schema --check`,
`build_manifest --check` verdi; `dead_code.py` pulito su 154 file.

**Quello che resta fuori, e lo dico invece di nasconderlo.** I quattro Destini
di CHR_01 portano 30 Trionfi su 120 e i quattro di CHR_03 ne portano 49: la
seconda saga e' piu' generosa della prima, e non ho toccato la differenza in
questa seduta perche' avrei tarato tre manopole su un giro solo di sonda senza
sapere se la causa sia il contenuto o il tavolo. E' ISSUES 42.

---

## D-166 — Il passo che frana: la sola cosa che cambia la forma del mondo
**implemented in 0.1.133** (§8.6 passo 5, l'ultimo — tenuto per ultimo di proposito)

Fino a 0.1.132 le **adiacenze** erano l'unica cosa della mappa che non cambiava
mai: sei Regioni, otto archi, scritti nel dato e letti da li' per sempre. Tutto
il resto — controllo, pietre, condizioni, cicatrici — era gia' stato del mondo.
Il grafo no.

**Adesso e' stato anche lui**, e si taglia con una coppia di Effect
(`CLOSE_PASSAGE` / `OPEN_PASSAGE`, l'uno l'inverso dell'altro) che tolgono un
arco da tutte e due le parti. Il *Passo* e' il luogo che lo racconta — aperto,
franato — e *La Via delle Miniere Tagliata* e' la Conseguenza che lo fa cadere:
due Effect per un fatto solo, il luogo che cambia stato e l'arco che si chiude.

**La guardia, che era il rischio dichiarato in D-160.** Una Regione
irraggiungibile e' **un Destino impossibile**: una clausola che nessuno potra'
mai soddisfare, e la mappa non lo direbbe a nessuno. Quindi il taglio si
**prova**: si toglie l'arco, si visita il grafo, e **se il mondo si e' spezzato
si rimette a posto e non e' successo niente**. Nessuna frase d'autore vale una
partita rotta.

Su questa mappa la guardia e' assicurazione e non necessita': otto archi su sei
nodi hanno abbastanza ridondanza che **nessun taglio singolo isola niente** — la
montagna che perde la steppa resta attaccata alle Miniere. Il test lo prova
prendendo l'unico caso che romperebbe davvero: **due** tagli sulle Miniere, e il
secondo viene rifiutato.

**Un difetto vero, e sottile.** Riaprire un varco rimetteva il vicino **in fondo
alla lista** invece che al posto suo. Il round-trip lo ha visto subito: lo stato
non tornava byte per byte. E non e' un dettaglio di stile — **l'ordine dei
vicini lo legge il gioco**: `$adjacent` ci pesca dentro per decidere dove
finisce chi viene cacciato. Adesso riaprire ricostruisce la lista nell'ordine
d'autore, tenendo solo gli archi che ci sono davvero.

**Quanto succede.** Su quaranta Chronicle: **un varco chiuso**, un passo franato
a fine anno, **zero tagli rifiutati**. Una volta ogni quaranta anni «meta' della
montagna scende a valle in una notte» — che e' esattamente la frequenza che un
fatto del genere deve avere. Non l'ho forzata e non la forzero': un evento che
riscrive la mappa e' memorabile perche' e' raro.

**Misure.** Playtest **FAIL 207 · SUCC 77 · SUCC 112 · DECI 189** — identico a
D-165: l'ultimo pezzo del catalogo costa **zero**. Tavolo misto **0 su 8**,
mediana **6**. Suite **339 test / 6051 asserzioni** verde; `run_sims.sh` e
`run_export.sh` identici su due giri; `dead_code.py` pulito su 152 file.

**Il catalogo e' chiuso**, per quello che si era deciso di scrivere: **nove tipi
in cinque famiglie** — presidio, insediamento, tre opere, quattro luoghi del
mondo. Resta fuori solo **la palude**, che chiede gli slot di presenza variabili
e quindi motore, non contenuto.

---

## D-165 — Il sito antico e la sorgente, e il degrado che non aggiunge peso
**implemented in 0.1.132** (§8.6 passo 5, gli altri due luoghi del mondo)

Due luoghi nuovi, e un vincolo di progetto che me li ha fatti scrivere in modo
diverso da quelli di prima.

**Il vincolo.** D-164 aveva dichiarato un trend che non voleva fermarsi: i
Consigli falliti da 185 a 207 in undici modifiche. Prima di aggiungere altre due
famiglie mi sono dato una linea di stop — **oltre 215, o un seggio bloccato, mi
fermo** — e ho progettato queste due perche' **non aggiungano peso**:

> il degrado **toglie un dono**, non aggiunge una penalita'.

E' l'opposto della selva maledetta, che una penalita' la aggiunge. Qui il sito
aperto **insegna** (chi ci sta pesca sapere migliore) e la sorgente viva **tiene
la gente** (pesca gente migliore); quando il sito viene saccheggiato o la
sorgente cala, il segno cambia e la regola smette di valere. Niente di nuovo che
morde: solo qualcosa che finisce.

| | grado I | grado II | grado III |
|---|---|---|---|
| **Sito antico** | dormiente — non fa niente | **aperto: sapere migliore** | saccheggiato — il dono finisce |
| **Sorgente** | **viva: gente migliore** | bassa — il dono finisce | secca |

**E ha funzionato, che era la cosa da misurare.** Playtest **FAIL 207 · SUCC 77 ·
SUCC 112 · DECI 189** — **identico** alla misura prima di aggiungerle. Due
famiglie nuove, otto tipi nel catalogo, e **zero punti** di costo. Tavolo misto
**0 su 8**, Consigli mediana **6**.

**Le cause, cercate prima di scriverle** (la regola di D-164): *Le Gallerie
Riaperte* aprono il sito, *La Miniera Aperta* lo saccheggia, *Le Miniere
Sigillate* lo rimandano a dormire, *La Valle che si Vuota* abbassa la sorgente,
*L'Acqua a Prezzo* la secca. Nessuna carta nuova, nessun rimescolo: cinque righe
in fondo a Conseguenze che raccontavano gia' quel fatto.

**Cosa si raggiunge e cosa no, dichiarato.** Su venti Chronicle:

| | |
|---|---|
| siti dormienti | 38 |
| siti **saccheggiati** | **2** |
| siti **aperti** | **0** |
| sorgenti vive | 39 |
| sorgenti **basse** | **1** |
| sorgenti **secche** | **0** |

Il degrado si vede, l'apertura no: **`place:open_site` non si raggiunge mai**, e
con lui dorme la regola del sapere. La causa e' scritta e aggancia una
Conseguenza vera — *Le Gallerie Riaperte* — che su questi semi non esce quasi
mai. Non aggiungo un'altra causa per forzarla: sarebbe la terza volta che inseguo
una frequenza invece di misurarla. **E' contenuto scritto e non raggiunto, come
la selva di D-163 prima che D-164 le desse una causa**, e la differenza e' che
stavolta la causa c'e' — e' l'anno che non la pesca.

Il seme lo dice anche di suo: i siti partono **dormienti**, e un mondo dove le
gallerie restano chiuse e' un mondo coerente. Se il committente vuole vedere i
siti aperti piu' spesso, la leva e' **partire da aperto** in una delle due
linee, non aggiungere un'altra porta.

**Misure.** Suite **334 test / 6025 asserzioni** verde; `run_sims.sh` identico
su due giri; `dead_code.py` pulito su 151 file; job «Dati e schemi» verde.

**Il catalogo, a questo punto.** Otto tipi in cinque famiglie: presidio,
insediamento, tre opere, e tre luoghi del mondo. Resta **la palude** (che chiede
gli slot di presenza variabili, cioe' motore) e **il passo che frana**, l'unico
che riscrive il grafo delle adiacenze.

---

## D-164 — La selva maledetta ha una causa, e due strade sbagliate per arrivarci
**implemented in 0.1.131** (correzione al buco dichiarato in D-163)

D-163 chiudeva dichiarando un buco: la selva maledetta era **contenuto scritto e
non raggiunto** — zero in venti Chronicle — e le mancava una carta del Narratore
che la causasse. Questa e' quella carta, e ci sono voluti due tentativi
sbagliati per capire che non doveva essere una carta.

**Primo tentativo: scrivere una carta nuova.** *Quello che si Taglia*, famiglia
ROTTURA, funzione VIOLAZIONE, una per linea. Funzionava — due selve in venti
partite — e ha rotto **tre cose insieme**:

1. **Il mazzo si rimescola.** Il costruttore del mazzo lo dice da sempre, e io
   l'avevo letto: «la composizione del mazzo di un anno scritto cambierebbe a
   ogni carta aggiunta, e con lei il mescolamento e la partita». Aggiungendo una
   carta, i **tre piani di regressione** sono saltati tutti e tre — non per un
   difetto, ma perche' l'anno scritto non era piu' lo stesso anno.
2. **L'equilibrio per famiglia.** `test_echo_grammar` pretende un numero fisso di
   carte per famiglia drammatica per saga: sei per ROTTURA, e ne avevo messe
   otto. Il mix drammatico di un atto e' progettato, non accumulato.
3. **Due carte, un disegno solo.** Avevo dato lo stesso `art_prompt_key` a
   tutte e due — e c'e' un test che lo vieta, giustamente.

**Secondo tentativo, e quello giusto: agganciarla a carte che esistono gia'.**
*La Partenza* nell'812 e *I Fuochi Fuori* nel 1640. Le due carte parlano gia' di
gente che se ne va e di fuochi accesi fuori dalle mura: il bosco che smette di
essere un bosco e' quello che succede intorno, e non serviva una carta per
dirlo — serviva una riga in fondo a una carta che lo stava gia' dicendo.

Meglio su ogni fronte: **tre selve in venti partite** (contro due), **nessun
rimescolo**, **nessun equilibrio rotto**, **nessun piano di regressione toccato**.

**La regola che ne esce, e che vale per tutto il resto del catalogo:** quando
serve una causa nuova per un effetto nuovo, si guarda **prima** se una carta
esistente sta gia' raccontando quel fatto. Un mazzo e' un equilibrio, non un
elenco: aggiungerci qualcosa costa piu' di quanto sembri, e quasi sempre la
frase che serve e' gia' scritta da qualche parte.

**E una regola tolta.** `TGR_CURSED_WOOD_COUNCIL` — la selva che fa partire
**ogni** Consiglio col mondo contro — l'avevo scritta io, e **non era nel
progetto**: la seduta diceva «chi ha presenza li' perde una carta», che e' una
morsa **locale**. Una penalita' mondiale che nasce da un fatto locale e' un
dente sbagliato, e costava tre punti di fallimenti. Tolta. Resta la morsa
locale, che e' quella scritta.

**Misure.** Playtest **FAIL 207 · SUCC 77 · SUCC 112 · DECI 189**, Consigli
mediana **6**, tavolo misto **0 su 8**, uniforme **2 su 8**. Suite **334 test /
6005 asserzioni** verde; `run_sims.sh` identico su due giri; `dead_code.py`
pulito su 151 file; job «Dati e schemi» verde.

**Il trend, dichiarato di nuovo perche' e' cresciuto ancora.** I Consigli
falliti da quando e' cominciata la strada C: **185 → 191 → 196 → 203 → 201 →
207**. Sono **ventidue punti** sopra il punto di partenza. Il vincolo di casa e'
0/8 e regge da undici modifiche di fila, la banda dei Consigli e' rispettata
(mediana 6), e la causa e' nota e ogni volta la stessa: **il mondo ha piu' cose
che pesano**, e ogni cosa che pesa da' a qualcuno una ragione in piu' per dire
di no. Ma ventidue punti non sono rumore, e prima di aggiungere il fiume, il
sito antico e la palude **va deciso se 207 e' il numero che vogliamo** — e' una
domanda di gusto, non di misura, e va al committente.

---

## D-163 — La foresta: il primo luogo che non e' di nessuno
**implemented in 0.1.130** (§8.6 passo 5 della [seduta sulla terra](SEDUTA_TERRA.md))

La quarta famiglia del catalogo, e la prima di **natura diversa**: un `LUOGO` non
ha padrone, non entra nel conto del controllo, e non sale ne' scende col Destino
(`_pick_structure` salta tutto cio' che ha `owned: false` — era scritto cosi'
dall'inizio e adesso ha un caso vero). Cambia **cosa vale una Regione**, non
**chi la tiene**.

| grado | | cosa fa |
|---|---|---|
| I | **Foresta** | chi ha presenza li' pesca forza migliore — e vale **per chiunque**, non e' di nessuno |
| II | **Bosco diradato** | niente: si vede attraverso, e basta |
| III | **Selva maledetta** | chi ci sta tiene **una carta in meno**, e finche' c'e' i Consigli partono col mondo un po' contro |
| ↓ | La Radura Spoglia | lascia `scar:emptied` |

Il prefisso dei segni dice di che natura sono: `structure:` e `settlement:` sono
opere delle case, **`place:` e' del mondo**. Tre foreste aperte sulla mappa, dove
i biomi le permettono: la Valle, la steppa, la montagna.

**E si guasta per mano di qualcuno, senza che sia colpa di nessuno.** Due
Conseguenze la fanno scendere: *La Valle Sgomberata* la dirada — sgomberare una
valle vuol dire anche tagliarla — e *Il Luogo Abbandonato* e *Le Gallerie
Lasciate* la fanno diventare selva. Nessuno la maledice: e' successo.

**Un difetto vero, trovato misurando.** `SET_STRUCTURE_GRADE` su una Regione
senza quella struttura **falliva con un errore**. Una Conseguenza scritta a mano
nomina `$region_focus`, e la Regione a fuoco cambia di anno in anno: diradare un
bosco dove non c'e' un bosco non e' un errore di dati, e' una frase che non aveva
niente da dire. Adesso rispetta `optional`, come `REMOVE_PRESENCE` e
`REMOVE_REGION_TAG` fanno da sempre. In venti Chronicle l'errore compariva a
ogni partita.

**E il numero che va dichiarato, perche' e' scomodo.** Su venti Chronicle:

| | |
|---|---|
| foreste intere a fine anno | **59** |
| **boschi diradati** | **1** |
| **selve maledette** | **0** |

Il luogo **c'e' e funziona** — la regola della legna scatta, e scatta per
chiunque ci stia. Il **degrado quasi no**: un diradamento in venti partite, e la
selva maledetta **non si e' mai vista**. Due delle tre regole che ho scritto
sono attaccate a uno stato che non si raggiunge.

E' la stessa forma dell'errore di D-161, in un posto diverso, e la differenza
conta: li' erano **clausole di Destino**, e una clausola che non si avvera rompe
l'ambizione di una casa; qui sono **regole dei segni**, e una regola dormiente
non rompe niente — semplicemente non fa. Non le tolgo, ma non fingo che siano
vive: **la selva maledetta e' contenuto scritto e non raggiunto**, e quello che
le manca e' una carta del Narratore che la causi. E' il prossimo passo del
catalogo, non questo.

**Misure.** Playtest **FAIL 201 · SUCC 74 · SUCC 114 · DECI 192**, Consigli
mediana **6**, tavolo misto **0 su 8**, uniforme **2 su 8** — identico a D-162:
la foresta non sposta l'equilibrio, e non doveva. Suite **334 test / 6003
asserzioni** verde; `run_sims.sh` identico su due giri; `dead_code.py` pulito su
151 file; job «Dati e schemi» verde.

Due test hanno dovuto imparare che la mappa non e' piu' spoglia: quello che
conta le regole (48 → 51) e quello che misura il telaio vuoto, che adesso
sgombera anche il bosco perche' la legna gli piegava la pesca.

**Restano di §8**: il fiume, il sito antico, la palude — e **il passo che frana**,
l'unico che riscrive il grafo delle adiacenze.

---

## D-162 — Le opere, e la fine del segno che non ha un oggetto sotto
**implemented in 0.1.129** (§8.6 passo 4 della [seduta sulla terra](SEDUTA_TERRA.md))

D-161 aveva dato all'anno **una** cosa da costruire — la Veglia sulla Montagna —
e aveva chiuso con una regola: *una clausola su uno strato si scrive dopo che
quello strato ha un modo di cambiare durante l'anno*. Questo e' il passo che
rende quel modo la norma invece dell'eccezione.

**La terza famiglia: le opere.** Tre tipi, due gradi ciascuno.

| tipo | I | II | quando cade |
|---|---|---|---|
| `STR_GRANARY` | Granaio (1) | **Il Grande Granaio** (2) | Il Granaio Vuoto |
| `STR_CANAL` | Canale (1) | **La Grande Opera d'Acqua** (2) | L'Insabbiamento |
| `STR_TOLLGATE` | Pedaggio (1) | **La Dogana** (2) | La Sbarra Rotta |

**I due gradi portano lo stesso segno**, ed e' una scelta: una grande opera non
e' un'opera diversa, e' la stessa **che pesa di piu'**. Cosi' le tre regole dei
segni gia' scritte — il granaio che parla, il canale che porta grano, il
pedaggio dove girano i denari — continuano a valere a tutti e due i gradi senza
riscriverle, e la differenza sta dove deve stare: nel conto del controllo, 1
contro 2. Dare al secondo grado una regola propria e' un passo dopo, non questo.

**E la cosa piu' importante non e' il catalogo: e' che il segno non vive piu' da
solo.** Fino a ieri sette carte posavano `structure:...` come un tag e basta. Un
tag senza oggetto sotto e' una struttura che si vede sulla mappa, fa scattare le
regole dei segni, e **non conta per nessuno** nella contesa del controllo: la
mappa diceva una cosa e il conto ne diceva un'altra. Convertite tutte e sette:

- **tre Conseguenze** — il Granaio del Trono, il Pedaggio Scritto, i Canali
  Scavati — adesso alzano un'opera **del proponente**;
- **un Asset**, il Pedaggio: la carta impegnata costruisce, e il padrone e'
  **chi l'ha messa sul tavolo** (`$actor`, che il contesto degli `on_commit`
  gia' offriva e nessuno usava);
- **tre carte del Narratore**: la Stagione Scavata **costruisce**, Mancanza e
  l'Insabbiamento **fanno cadere l'oggetto** invece di cancellare il segno — e
  cosi' l'opera smette anche di contare per chi la teneva.

Resta fuori solo `structure:sealed`, che e' una **chiusura** e non un edificio:
murare una miniera non da' niente a nessuno, ed e' giusto che non abbia un
padrone.

**La misura, e il trend si e' girato.**

| | D-160 | D-161 | ora |
|---|---|---|---|
| playtest, Consigli falliti | 204 | 204 | **201** |
| tavolo misto, seggi bloccati | 0/8 | 0/8 | **0/8** |
| caselle tenute a fine anno (su 180) | 143 | 143 | **150** |
| passaggi di mano per contesa | 74 | 74 | **73** |

I Consigli falliti erano 185 → 191 → 196 → 203 → 204, e adesso **201**: e' la
prima volta che scendono da quando e' cominciata la strada C. Non e' una cura —
sono tre punti — ma la direzione unica si e' interrotta, e la lettura di D-160
regge: non era una tassa sistemica, erano le policy che votavano diverso, e
adesso hanno piu' cose vere su cui votare.

**I gradini, e la mappa piena:**

| | prima della strada C | ora |
|---|---|---|
| supera il Minimo | 47% | **58%** |
| caselle con un padrone | 56% | **84%** |
| seggi con **due** Regioni | 12% | **32%** |
| seggi a **zero** Regioni | 30% | **11%** |

**Nel tempo lungo** (12 saghe da 8 anni): grado I **44**, grado II **13**, grado
III **4**. Le regge erano zero quando c'era una sola scala, due con
l'insediamento, quattro adesso. Nessuna e' scritta a mano: sono case che hanno
vinto tre volte.

Misure: suite **334 test / 5988 asserzioni** verde; `run_sims.sh` identico su
due giri; `dead_code.py` pulito su 151 file; job «Dati e schemi» verde.

**Adesso lo strato si muove dentro l'anno**, e le clausole di D-161 —
`structure_count`, `scar_count`, `some_of` — hanno finalmente qualcosa da
leggere. Scriverle e' il prossimo passo, con la regola di D-161: misurarle sui
gradini **prima** di lasciarle.

**Restano di §8**: i **luoghi del mondo** — foresta, fiume, sito antico, palude
— col **passo che frana** per ultimo.

---

## D-161 — Le clausole che leggono le pietre, e la lezione di D-151 ripresa da me
**implemented in 0.1.128** (richiesta del committente sui Destini)

«I Destini li farei diversi, una serie di condizioni che se soddisfatte danno il
grado di vittoria. E tra le condizioni ci puo' essere le cose piu' disparate
includendo anche gli edifici e/o il controllo e/o le cicatrici.»

**Meta' di quello che chiede c'era gia', e vale la pena dirlo prima.** Un Destino
e' gia' esattamente questo: tre livelli, ognuno **una lista di condizioni** che
devono valere tutte, con dodici tipi disponibili e `any_of` per l'oppure. 135
clausole scritte, da 1 a 5 per livello. Quello che mancava era piu' stretto:

- **nessuna clausola sapeva leggere le strutture** — che sono nate ieri;
- **le cicatrici erano leggibili e nessun Destino le usava**: `state_tag_present`
  con scope REGION avrebbe funzionato, ma scrivere `scar:burned` come un tag
  qualunque non dice quello che si intende;
- non si poteva chiedere **«almeno K su N»**: `any_of` e' il caso K=1.

**Il vocabolario nuovo**, tre tipi:

| tipo | dice |
|---|---|
| `structure_count` | quante strutture, coi filtri che servono: tipo, famiglia, **grado minimo**, Regione, e `anyone` per contare anche quelle degli altri |
| `scar_count` | quante cicatrici, per tag e per Regione |
| `some_of` | almeno `min` fra queste condizioni |

I due conteggi dicono **presenza e assenza con lo stesso conto**: «un castello a
Eredan» e' `min: 1`, «e nessuno ha alzato una reggia sulla montagna» e'
`grade: 3` + `anyone` + `max: 0`. E' il motivo per cui ho buttato via i due tipi
booleani che avevo scritto per primi (`structure_present`, `scar_present`): il
vocabolario esistente conta gia' cosi' — `control_count`, `discovery_count` — e
un tipo in piu' che dice meno e' un tipo in meno da avere.

**E qui ho ripreso la lezione di D-151, da solo, sulla mia scrittura.**

Scritte cinque clausole nuove con i tipi nuovi, la sonda dei gradini ha
risposto:

| clausola | mancata |
|---|---|
| Aldric: «E la corona ha una casa, non solo un titolo» (castello a Eredan) | **100%** |
| la Cenere: «E quello che tengono si vede da lontano» (presidio di grado 2) | **100%** |
| le Citta': «E l'anno non ha lasciato cicatrici» | **100%** |
| Nahr: «E il villaggio e' ancora in piedi» | ~mai mancata |
| Vaerax: «E sulla montagna non si e' fermato nessuno» | ~mai mancata |

Tre impossibili e due gratis. **Zero utili.** E il Trionfo e' sceso dal 5% al
3%, perche' avevo aggiunto pesi che non si possono sollevare.

La causa e' una sola e non e' il bilanciamento: **ho scritto clausole su uno
strato che dentro l'anno nessuno puo' cambiare.** Le strutture, fino a
stamattina, si muovevano in due soli momenti — all'apertura (`starting_structures`)
e alla chiusura (D-159, il grado che segue il Destino). Dentro i nove round
**non si costruiva niente**. Una clausola che chiede un castello di grado 2 in
una Chronicle singola chiede una cosa che il regolamento non permette a nessuno
di fare: e' la definizione esatta del difetto che D-151 aveva trovato nel
contenuto di qualcun altro.

E le cicatrici: un anno su quaranta finisce senza nessuna. «Nessuna cicatrice»
non e' un obiettivo ambizioso, e' una lotteria al 2,5%.

**Cosa ho fatto.** Le cinque clausole sono state **tolte**. Il vocabolario
resta — e' provato e serve — ma il contenuto aspetta il pezzo che mancava:

**La prima cosa che si costruisce dentro l'anno.** `CNS_ASH_WATCH` — la Veglia
sulla Montagna — posava un segno `structure:watchtower` sulla Regione. Adesso
**alza un presidio che ha un padrone**: entra nel conto del controllo dal round
dopo, e puo' crescere. E' la prima Conseguenza che costruisce un oggetto invece
di scrivere un tag, ed e' il modello per le altre dieci.

Si vede subito nella misura: i passaggi di mano per contesa passano da **63 a
74** su trenta Chronicle, e le caselle tenute a fine anno da 138 a **143**. Una
torre alzata a meta' anno cambia chi tiene la montagna.

**Misure.** Playtest **FAIL 204 · SUCC 73 · SUCC 113 · DECI 186**, Consigli
mediana **6**, tavolo misto **0 su 8**, uniforme **2 su 8** — invariato rispetto
a D-160. Suite **334 test / 5991 asserzioni** verde; `run_sims.sh` identico su
due giri; `dead_code.py` pulito su 151 file; job «Dati e schemi» verde.

**La regola che mi do, e che vale per il resto di §8:** una clausola che parla
di uno strato del mondo si scrive **dopo** che quello strato ha almeno un modo
di cambiare durante l'anno — e si misura sulla sonda dei gradini **prima** di
restare. Il vocabolario per primo, il contenuto per secondo, la misura fra i
due.

---

## D-160 — L'insediamento: la seconda scala, e il trend guardato per primo
**implemented in 0.1.127** (§8.6 passo 3 della [seduta sulla terra](SEDUTA_TERRA.md))

**Prima la promessa mantenuta.** D-159 chiudeva dicendo che i Consigli falliti si
muovevano sempre nella stessa direzione — 185, 191, 196, 203 — e che alla
prossima modifica andava guardato per primo. Guardato:

| | |
|---|---|
| Consigli aperti, 30 Chronicle | **174** (5,8 a partita, in banda) |
| **sovraestensioni** (la tassa di D-027) | **11** |
| passaggi di mano per contesa | 63 |

**Non e' una tassa sistemica.** La sovraestensione morde undici volte in trenta
partite: non e' lei ad alzare i fallimenti. I Consigli aperti sono cresciuti da
5,63 a 5,75 di media — dentro la banda dichiarata (mediana 5-6) — e la quota di
fallimenti e' salita di **1,6 punti**, dal 33,7% al 35,3%. La causa e' che le
policy **votano diverso**: con il controllo contato, una Conseguenza che
consegna una Regione vale meno di prima, e le proposte che si fanno e come si
vota sono cambiate. Il numero da tenere resta la banda dei Consigli e lo 0/8,
e tutti e due reggono.

**La seconda scala.** `STR_SETTLEMENT`, accanto al presidio:

| grado | nome | valore | cosa fa |
|---|---|---|---|
| I | Villaggio | 1 | chi ha presenza li' **pesca gente migliore** |
| II | Borgo | 2 | e **tiene una carta in piu'** — l'inverso esatto della fame, che una la toglie |
| III | Citta' | 4 | e il **Fattore Mondo** pende dalla parte di chi propone |
| ↓ | Abbandono | — | lascia `scar:emptied` |

Riusa il prefisso `settlement:` che c'era gia' invece di inventarne uno, e i tre
gradi sono tre regole dei segni scritte come tutte le altre. La citta' non da'
un bonus a **chi la tiene**: piega il **mondo**, perche' dove c'e' una citta'
una decisione e' piu' facile da far applicare — ed e' l'unico grado del catalogo
che aiuta anche un rivale che proponga li'.

Un villaggio semina la Valle Verde in tutte e due le linee: i Nahr nell'812, le
Citta' Libere nel 1640 — case che hanno gia' presenza li', in una Regione che
non e' di nessuno.

**La misura, e la seconda scala cambia la prima.** Dodici saghe da otto anni:

| | solo presidi (D-159) | col villaggio |
|---|---|---|
| in piedi al grado I | 32 | 33 |
| **grado II — castelli e borghi** | **3** | **13** |
| **grado III — regge e citta'** | **0** | **2** |
| gradi persi (senza andare in rovina) | 0 | 1 |

E' l'effetto che si sperava e non era ovvio: **con due strutture, chi perde
lascia andare il villaggio e tiene il castello**. `_pick_structure` fa cadere la
piu' bassa e alza la piu' alta, quindi una casa che sbaglia un anno perde i
margini e conserva il centro — e i presidi, non essendo piu' i primi a cadere,
arrivano fino in fondo alla scala. Le prime **due regge** compaiono qui, e
nessuno le aveva scritte a mano.

**Playtest 100 semi: FAIL 204 · SUCC 73 · SUCC 113 · DECI 186**, Consigli mediana
**6**, tavolo misto **0 su 8**, uniforme **2 su 8**. Un fallimento in piu' di
D-159: la seconda scala e' **neutra** sulle guardie.

**E i gradini si sono mossi ancora:** supera il Minimo **59%** (era 47% prima di
tutta la strada C), caselle con un padrone **81%**, seggi con due Regioni
**30%**.

**Il piano di regressione C e' stato aggiornato, e vale la pena dire come.**
`SIM_PLAN_C` dichiara gli esiti di un anno scritto a mano: il sesto Consiglio e'
passato da SUCCESS a **FAILURE**, per **un punto solo** (S 2 contro O 4, M −1).
La catena e' quella prevista — il villaggio piega la pesca, cambiano le carte in
mano, cambiano gli impegni. Il Cristallo, che e' il cuore narrativo del piano,
sta al terzo Consiglio e **non si e' mosso**; a cadere e' l'ultimo giro sulle
Vie. La descrizione e' stata riscritta per dire il vero: *una domanda che
sembrava chiusa si riapre e resta aperta*. Un fixture che dichiara aspettative
si aggiorna quando le regole cambiano di proposito — ma si aggiorna **dopo aver
guardato cosa e' successo**, non prima.

**E una lezione sui test.** Tre volte di fila i test delle strutture si sono
rotti perche' davano per scontata una mappa vuota, e ogni semina nuova ne
rompeva un altro pezzo. Adesso **sgomberano la propria Regione** in
`before_each` invece di inseguire una casella libera: quali Regioni siano gia'
costruite e' contenuto, e un test non deve dipendere dal contenuto per misurare
un meccanismo.

Misure: suite **334 test / 5992 asserzioni** verde; `run_sims.sh` identico su
due giri; `dead_code.py` pulito su 151 file; job «Dati e schemi» verde.

**Restano di §8**: le opere di grado II (solo dati) e **i luoghi del mondo** —
foresta, fiume, sito antico, palude — col **passo che frana** per ultimo.

---

## D-159 — La scala che si muove col Destino, e la mappa che si apre costruita
**implemented in 0.1.126** (§7.3 della [seduta sulla terra](SEDUTA_TERRA.md))

«Il cambio puo' dipendere da come vanno le cose: **se la reggia appartiene
all'entita' che ha perso va in rovina, se invece trionfa diventa una reggia**.»

A fine Chronicle, e solo se la Chronicle dichiara `structure_rules`:

- chi ha raggiunto un livello di `rise_on` **alza di un grado la sua struttura
  piu' alta** — una casa che vince costruisce sopra quello che ha gia', non
  altrove: e' cosi' che nasce una capitale;
- chi si e' fermato a un livello di `fall_on` **perde un grado sulla piu'
  bassa** — si perdono prima i margini, come gia' fa il controllo che decade
  dove non c'e' nessuno. Sotto il primo grado non si scende: **si va in rovina**,
  e la rovina lascia una cicatrice.

Deterministico: le Regioni si guardano nell'ordine della Chronicle.

**E la mappa si apre gia' costruita.** Senza una pietra sul tabellone la scala
non ha niente da muovere, quindi arriva `starting_structures` sulla Chronicle —
accanto a `starting_control`, e per la stessa ragione di D-049: le Regioni sono
condivise fra saghe distanti secoli, e una pietra scritta sulla Regione
sederebbe le case della prima saga al tavolo della seconda. Le tre Regioni che
partono con un padrone partono anche con **una torre di veglia**.

**La misura sul tempo — dodici saghe da otto anni:**

| | |
|---|---|
| gradi saliti (Trionfo) | **24** |
| strutture andate in rovina | **19** |
| in piedi all'ottavo anno, grado I | 32 |
| in piedi all'ottavo anno, **grado II (castelli)** | **3** |
| grado III (regge) | 0 |

Le pietre si muovono, e si muovono **poco**: in otto anni tre torri diventano
castelli e nessuno arriva a una reggia. E' il ritmo giusto — una reggia deve
essere un fatto raro, non il quarto anno di chiunque vinca due volte.

**Playtest sui 100 semi: FAIL 203 · SUCC 76 · SUCC 108 · DECI 188**, tavolo
misto **0 su 8**, tavolo uniforme **2 su 8**. La mappa resta al **76%** di
caselle con un padrone, e il Vetro resta intorno a 1,00.

**Il numero da dichiarare, perche' si sta muovendo:** i Consigli falliti sono
passati da **185** (prima di tutta la strada C) a 191, poi 196, ora **203**. Il
vincolo di casa e' 0/8 e regge; ma tre modifiche di fila hanno spinto lo stesso
numero nella stessa direzione, e alla prossima va guardato per primo.

**Tre difetti trovati mentre si misurava, e uno era vero.**

1. **La torre di partenza copriva la reggia ereditata.** `BUILD_STRUCTURE` e' un
   no-op se quel tipo c'e' gia', e il setup gira **prima** dell'eredita': una
   reggia dell'anno prima tornava una torre. Adesso l'eredita' abbatte e
   rialza — `starting_structures` descrive un anno che comincia da zero, un
   anno che eredita comincia da quello che c'era.
2. **Due test misuravano una mappa vuota che non esiste piu'.** Uno cercava «la
   prima `BUILD_STRUCTURE`» e ne trovava un'altra; l'altro misurava il telaio
   dei ganci nuovi «senza regole» e incontrava `TGR_WATCHTOWER_FORCE`, che e'
   una regola **vera** e faceva il suo mestiere. Nessuno dei due era un difetto
   del gioco: erano test scritti quando la mappa si apriva spoglia.
3. **Il passo dei due artefatti, di nuovo.** Aggiunto `starting_structures` allo
   schema e dimenticato `gen_gd_schema.py`: il playtest e' morto al primo giro
   con «unexpected field». E' la stessa lezione di D-156, presa due volte.

Misure: suite **334 test / 5977 asserzioni** verde; `run_sims.sh` identico su
due giri; `dead_code.py` pulito su 151 file; job «Dati e schemi» verde per
intero.

**Restano di §7**: le 14 Conseguenze che scrivono un nome (7.2, deliberatamente
non riscritte) e il catalogo §8, che e' contenuto d'autore.

---

## D-158 — La contesa del controllo: il padrone si conta, non si scrive
**implemented in 0.1.125** (§7.2 della [seduta sulla terra](SEDUTA_TERRA.md))

«Se una entita' ha un castello (che magari vale 3) ma un'altra ha un esercito
che occupa la regione (che vale 4) la regione viene controllata da chi ha di
piu'.»

Fino a 0.1.124 il padrone di una Regione era **scritto**: una Conseguenza metteva
un nome, e quel nome restava finche' un'altra non lo cambiava. Da qui e'
**contato**, a ogni fine round: chi somma di piu' fra il valore delle proprie
strutture e le proprie pedine.

**Le due monete si sommano nella stessa colonna**, ed e' il punto: *un castello
e' una presenza che non se ne va, una pedina e' un castello che si puo'
spostare.* I **luoghi del mondo** (`owned: false`: foreste, passi, fiumi) non
contano per nessuno — non sono di nessuno per costruzione.

**A parita' non cambia niente.** Per togliere una Regione bisogna **superare**
chi la tiene, non pareggiarlo: altrimenti il padrone di una casella contesa
cambierebbe a ogni pedina che passa. E il passaggio resta un `SET_CONTROL` come
tutti gli altri — stesso Effect, stesso inverso, stessa riga nel registro.
Cambia **chi lo decide**, non come si scrive.

**La misura, e la mappa si e' mossa.** Sessanta Chronicle a tavolo misto:

| | 0.1.124 | ora |
|---|---|---|
| caselle con un padrone | 56% | **76%** |
| seggi che finiscono a **zero** Regioni | 30% | **15%** |
| seggi con **due** Regioni | 12% | **25%** |
| supera il Minimo | 54% | **55%** |

E casa per casa, la riga che vale piu' di tutte: **il Vetro passa da 0,00 a
1,00**. La casa che in trenta partite non aveva mai tenuto una Regione adesso ne
tiene una — non perche' gliel'abbiano data, ma perche' sta da qualche parte. Le
Citta' Libere da 0,67 a 1,67, i Nahr da 1,20 a 1,70.

**Playtest sui 100 semi: FAIL 196 · SUCC 68 · SUCC 116 · DECI 186**, tavolo
misto **0 su 8** — il vincolo di casa regge — e tavolo uniforme **3/8 → 2/8**.

**Tre cose cambiano al tavolo, e vanno dette perche' si vedono.**

1. **Una Regione si perde senza che nessuno la prenda**: basta andarsene.
   `lapse_without_presence` smette di essere una regola a parte e diventa un
   caso particolare del conto — chi non ha niente li' somma zero, e zero non
   tiene niente.
2. **Il Consiglio non consegna piu' un possesso definitivo.** Le 14 Conseguenze
   che scrivono un nome valgono finche' quel nome regge il conto: il Consiglio
   da' un **titolo**, tenerlo e' un'altra cosa. Non le ho riscritte — la misura
   dice che cosi' funzionano, e riscriverle sarebbe stato cambiare due cose
   insieme.
3. **La clausola della Cenere non e' piu' il suo problema.** `control_count >= 2`
   sparisce dalla lista delle clausole mancate; adesso il suo ostacolo e' la
   seconda clausola scritta in D-156 (la veglia affidata per atto, mancata nel
   37%), che e' esattamente il mestiere che le avevo dato.

E in cima alla lista di quello che non si avvera restano le **clausole sociali**
— «qualcuno ha giurato» al 70%, «l'insediamento e' riconosciuto» al 57%, «la
Carta e' stata scritta» al 53%. E' la seconda famiglia di D-151, e non si muove
di qui: quella chiede persone, non regole.

Misure: suite **334 test / 5981 asserzioni** verde (sette test nuovi);
`run_sims.sh` identico su due giri; `dead_code.py` pulito su 151 file; il job
«Dati e schemi» verde per intero. La regola sta in
`control_rules.contested` e si spegne togliendo una chiave.

**Il prossimo passo e' §7.3**: il grado che si muove con l'esito del Destino —
chi trionfa alza una struttura, chi non arriva al Minimo la vede andare in
rovina.

---

## D-157 — La terra si costruisce: la struttura diventa un oggetto
**implemented in 0.1.124** (§7.1 della [seduta sulla terra](SEDUTA_TERRA.md), strada C scelta dal committente)

Il primo passo della strada C, e quello su cui sta tutto il resto: **una
struttura smette di essere un tag e diventa un oggetto**.

**Perche' un tag non basta.** `structure:granary` e' un booleano: c'e' o non
c'e'. Le risposte del committente chiedono altre tre cose che un booleano non
sa dire — **un grado** (torre → castello → reggia), **un padrone** (per la
contesa del controllo), e **un valore** (il castello vale 3, l'esercito 4, e
vince chi somma di piu'). Servono tutti e tre insieme, quindi serve un record.

**Cosa c'e' adesso.**

- `schema/structure_type.schema.json`: un **catalogo**. Un tipo dichiara la
  famiglia (PRESIDIO · INSEDIAMENTO · OPERA · LUOGO · CHIUSURA), se ha un
  padrone, in quali biomi puo' stare, i suoi **gradi** — ognuno con nome,
  **valore** e il segno che posa — e come finisce in rovina.
- `world.regions[id].structures`: una lista di `{structure_type, grade, owner}`.
- Tre Effect nuovi, con i loro inversi: **`BUILD_STRUCTURE`** ↔
  **`RAZE_STRUCTURE`**, e **`SET_STRUCTURE_GRADE`** che si inverte su se stesso
  col grado di prima. L'enum chiuso passa da 22 a **25**.
- **Le pietre attraversano gli anni**: l'eredita' le riporta *com'erano* — una
  reggia resta una reggia — e il padrone segue la stessa regola del controllo
  (`lapse_without_presence`): senza nessuno dentro, le pietre restano di
  nessuno.

**La scelta che tiene insieme il vecchio e il nuovo: l'oggetto e' la verita', il
tag e' derivato.** Ogni grado dichiara il proprio `structure:`, e alzarlo o
abbatterlo posa e toglie quel segno. Cosi' le **cinque regole dei segni** gia'
scritte — il granaio parla, al pedaggio girano i denari, sotto la torre si pesca
forza — continuano a funzionare senza sapere che sotto e' cambiato tutto. Non
c'e' un momento in cui il gioco ha due verita'.

**Il catalogo parte con una scala sola**, il **Presidio**: Torre di veglia (2) →
Castello (3) → Reggia (5), e la Rovina che lascia `scar:abandoned`. Riusa la
torre di veglia che esisteva gia' come tag, ed e' il caso piu' semplice della
contesa a valori — che e' esattamente l'ordine dichiarato in SEDUTA_TERRA §8.6.

**Nessun dato del gioco costruisce niente.** Nessuna carta, nessuna Conseguenza
posa un presidio: il livello c'e', il contenuto no. E infatti il playtest e'
**identico** a quello di 0.1.122 — **FAIL 191 · SUCC 69 · SUCC 116 · DECI 190**,
tavolo misto **0 su 8**. E' il modo in cui questo passo si dichiara riuscito:
un livello nuovo che non muove un solo numero e' un livello che non ha ancora
opinioni.

**Due difetti presi per strada, tutti e due dalla suite e non a mano.**
`x-echoes-kind` accettava tre valori e io ne ho scritto un quarto: lo schema
passava la validazione Python e **spariva dal registro di Godot**, che ha
bocciato 288 test in un colpo. E il guardiano di D-003 — «ogni EffectType
reversibile ha un test di andata e ritorno» — ha rifiutato i tre nuovi finche'
non li ho scritti. Sono le due reti che questo repository si e' costruito
apposta, e hanno funzionato.

Misure: suite **327 test / 5996 asserzioni** verde (otto test nuovi); playtest
invariato; `run_sims.sh` identico su due giri; `dead_code.py` pulito su 150
file; il job «Dati e schemi» verde per intero.

**Il prossimo passo e' §7.2**, la contesa del controllo — ed e' il primo che
muovera' i numeri.

---

## D-001 — Godot 4.7.1 confirmed, headless build used throughout
**implemented**

The spec fixes Godot 4.7.1 stable. The whole 0.0 milestone (data validation,
64 unit/smoke tests, three scripted Chronicles) is built and verified against
`Godot_v4.7.1-stable_linux.x86_64 --headless`. No editor step is needed: the
project has never been opened in the GUI, and `--import` is not required for any
of the commands in the README, because nothing relies on the global class-name
cache (see D-019).

---

## D-002 — `Effect.inverse_type` alongside `inverse_payload`
**implemented** · extends the schema in §6.3

The Effect example in §6.3 shows `inverse_payload` but no way to say *which
operation* consumes it. That is fine for symmetric types (`ADJUST_TENSION`
inverts to itself) and ambiguous for asymmetric ones: the inverse of
`ADD_PRESENCE` is a `REMOVE_PRESENCE`, not an `ADD_PRESENCE` with a different
payload.

Rather than infer the pairing at undo time, every reversible Effect stores an
explicit `inverse_type`. The pairing table lives in one place,
`scripts/core/effect.gd :: INVERSE_TYPE`, and `undo()` simply applies
`inverse_type` with `inverse_payload`.

Irreversible Effects (`CREATE_ECHO`, `APPEND_TRUTH`) carry neither field.

---

## D-003 — `REMOVE_SCAR` added to the EffectType enum
**implemented** · §6.3 permits extension with a note here

`ADD_SCAR` is reversible per §6.3 (only Echo and Truth are listed as
irreversible), but the enum had no operation that could undo it. `REMOVE_SCAR`
was added so the enum stays closed *and* complete. It also restores the Region
tag correctly: `ADD_SCAR` records whether the map tag already existed for another
reason, and the undo leaves a pre-existing tag alone.

The enum is now 22 entries. `tests/unit/test_effect_applier.gd` asserts that
every reversible entry in the generated enum has a round-trip test, so a future
addition cannot slip in untested.

---

## D-004 — RNG position persisted as a draw counter
**implemented**

`world_state.rng_state` holds *the number of values drawn since the seed*, not
the engine's raw 64-bit state word. Restoring re-seeds and fast-forwards.

Reason: a 64-bit state exceeds the range JSON round-trips losslessly through
Godot's parser, and §18.3 requires a byte-identical save. A counter is a small
integer, always exact, and costs a few thousand `randi()` calls on load.

---

## D-005 — Effect-mediated world state vs. progression cursors
**implemented**

§2.11 says every WorldState mutation goes through an Effect. Taken literally with
the closed enum of §6.3 that is impossible: there is no `SET_PHASE` or
`ADVANCE_ROUND`, and adding them would turn the enum into a bookkeeping API.

The line drawn here: **everything a player can point at** — Tensions, presence,
control, tags, relations, Assets, Claims, Scars, Echoes, Truths — is mutated only
by `EffectApplier`. The Chronicle's own cursors are not:

`act`, `round`, `phase`, `ao_remaining`, `drift_index`, `confluence_queue`,
`forced_confluence`, `confluence_count`, `effect_sequence`,
`tensions[*].fired_omens`, `tensions[*].resolved_count`.

These are fully determined by the plan plus the seed, so they need no inverse;
undoing across them is a snapshot restore, which is what §6.3 prescribes anyway.
They are all part of the save, so a reload resumes exactly.

---

## D-006 — Structural setup is not an Effect; presence and hands are
**implemented**

`WorldStateFactory.build()` constructs which Entities, Regions, Tensions and
decks exist. That *is* the initial state, not a mutation of it, and there is no
"before" for an inverse to return to.

Everything a player could later change is applied as a setup Effect with
`source.kind = "system"`, `source.id = "SETUP"`: presence tokens and opening
hands. So `effect_log` explains the whole table from `EFF_000001` onwards, and
undoing back to an empty board is possible.

---

## D-007 — An Echo card that prescribes a Confluence opens it at Act end
**implemented**

§7 caps Confluences at one per round; §12.1 (b) says an Act Echo card may
prescribe one. Act-end happens after the last round's threshold check, so the two
rules do not actually collide: the card's Confluence opens immediately at Act
end, with `trigger.kind = "ECHO_CARD"`, and does not consume the round's slot.

`ECH_REVELATION` is the card that exercises this in 0.0.

---

## D-008 — A minimal test runner instead of GUT
**implemented** · §3 allows GUT but requires it be isolated and documented

`tests/run_tests.gd` (≈100 lines) discovers `test_*.gd`, runs each `test_*`
method on a fresh instance and exits non-zero on failure. `tests/test_case.gd`
holds the assertions and the shared session fixture.

Reason: the suite must run under `godot --headless` in CI with no addon
directory and no editor import step. GUT would add a vendored dependency for
assertions the project needs about six of. If the suite outgrows this, GUT goes
into `addons/` and this entry gets revisited.

The runner refuses to be taken down by a suite that fails to compile: a script
that does not parse is reported as a failed suite. (A parse error inside
`_initialize` never reaches `quit()`, and the process hangs forever — this cost
real debugging time during 0.0.)

---

## D-009 — TEN_AWAKENING cannot reach its threshold on Drift alone
**implemented, deliberate**

The Awakening starts at 2, has 4 Drift entries and a threshold of 7: at most 6
from Drift. It becomes urgent only when the world pushes it — the Ripple of a
Famine Confluence (+1), an Echo card, or players raising it on purpose.

That is the intended shape: the hidden Tension does not go off by itself, it goes
off *because of what the table did about the other one*. `test_data_boot.gd`
checks reachability including Ripple, not Drift alone.

---

## D-010 — `deck_copies` added to the Asset schema
**implemented**

§18.2 gives 0.0 two distinct Assets per family. A two-card draw pile is not a
deck: with four players spending eight AO per round it empties on round one, and
`ACQUIRE` starts failing for reasons that have nothing to do with the rules under
test. The first sim run produced 56 refused actions for exactly this reason.

`deck_copies` (default 3) sets how many physical copies of a card are in its
family pile. 0.0 uses 6 copies of each strength-1 card and 4 of each strength-2:
10 per family, 60 in total, against a maximum of 28 cards that can sit in hands.

0.1 replaces this with the eight distinct cards per family of §9 and
`deck_copies` drops back towards 1–2.

---

## D-011 — CLAIM has two modes, and forcing costs an Action Opportunity
**implemented**

§10 describes creating a Claim as a CLAIM action, then says forcing a Confluence
happens "in a later round" without saying what it costs. Forcing is implemented
as `CLAIM` with `mode: "FORCE"`: it costs 1 AO, consumes the Claim and discards a
second AUTHORITY Asset, exactly as §10 lists. It refuses if the Claim was created
in the same round, if the Tension is below 3, or if a Confluence has already been
forced this round.

---

## D-012 — "Success" in the Echo Check includes Success with Cost
**implemented**

§12.4 writes "Success con S + O ≥ 6". Both `SUCCESS` and `SUCCESS_WITH_COST` are
successes — the proposal passed — so both qualify. Only `FAILURE` takes the
separate `O ≥ 6` route.

---

## D-013 — Asset disposition on Failure
**implemented**

§12.3 states the proponent discards everything committed and each opposer
recovers one Asset of their choice. It does not say what happens to a
*non-proponent supporter* or to a Condition's commit.

Rule applied: on a Failure, everything committed is discarded except one Asset of
their choice per opposer. A card whose own rule is `ALWAYS_DISCARD` can never be
the recovered one. On any success, everything committed is discarded unless the
card says `RETAIN` (always) or `RETAIN_ON_SUCCESS`.

---

## D-014 — Resolution ordering inside a Confluence is fixed
**implemented**

§12.2 gives the A–K sequence but not the order *within* H–I, which is observable:
whether a card's on-commit cost lands before or after the Tension is settled
changes the final number. The order is fixed, and stated in both
`confluence_controller.gd` and RULES_V0_2.md §12:

1. World Factor · 2. Maths · 3. Tension outcome · 4. on-commit costs of the cards
spent · 5. outcome Consequences · 6. cost / decisive bonus · 7. qualified
Condition clause · 8. Asset disposition · 9. Echo Check · 10. Ripple.

On-commit costs land *after* the Tension is settled, so `AST_FORCE_WARBAND`
leaves the Tension at 2 instead of 1 on a success — a cost you can see.

---

## D-015 — Two schemas beyond the twelve listed in §4
**implemented**

- `schema/chronicle.schema.json` — the Chronicle definition (Acts, rounds, AO,
  drift distribution, Act Echo pools). §7 makes all of these data-driven but §4
  lists no schema for them.
- `schema/sim_plan.schema.json` — the harness input required by §18.1. Having it
  under `/schema` means the sample plans are validated in CI like everything else.

---

## D-016 — Question default and Proposition eligibility
**implemented**

§12.2 B says a valid question is selected "in base a stato e cause della
Tensione" without a tie-break. Default: the **last** eligible question in
definition order, so a Tension at breaking point asks the harder question. The
proponent may pick any other eligible one.

Separately, propositions carry eligibility conditions. Without them the first sim
run produced the Nahr proposing that the throne requisition the grain, and Aldric
opposing his own granary: mechanically legal, narratively backwards. The
throne-only propositions now require the proponent to carry the `crowned` tag,
and `P_LAND_TO_WORKERS` was added so a non-crowned proponent still has something
to say about the same question.

---

## D-017 — Destiny levels are cumulative
**implemented**

§14 gives three levels without saying whether they nest. They do: a Triumph
requires the Victory and Minimum conditions as well. Losing the Minimum drops an
Entity to `NONE` however impressive the rest looks — a king with no capital has
not won anything. Each level is also reported individually in `levels`, so the
Chronicle End screen can show the whole ladder.

---

## D-018 — Presence-based INFLUENCE could cancel the Drift outright
**resolved in 0.0.1 by D-021** · was: flagged

§10 makes INFLUENCE free and repeatable when you have presence in a Region tagged
with the Tension's domain. Four players have eight AO per round; the Drift is +1
per round. A table that wants a Tension held flat can hold it flat forever.

The 0.0 report flagged this without numbers. The balance pass measured it, and it
was worse than suspected — see D-021 for the instrument and the fix.

---

## D-021 — One INFLUENCE per Entity per round
**implemented in 0.0.1** · `chronicle.influence_rules.max_per_entity_per_round`

### How it was measured

Two new pieces, both under `godot/cli`:

- **`policy_decider.gd`** — a player that actually plays to win. It derives its
  goals from its own Destiny: the lowest level it has not yet reached, the
  Tensions that level wants held down, and — crucially — the Tensions it needs to
  *bring to a head*, because the only thing that can satisfy one of its
  conditions is a Consequence sitting behind a Confluence. All derived from the
  data, no per-Entity AI.
- **`run_balance_probe.gd`** — plays N Chronicles across N seeds and reports the
  distribution.

### What the measurement found

The first probe run, with a naive policy that only ever suppressed:

| | Confluence per Chronicle |
|---|---|
| mediana | **0** |
| media | 0.37 |
| dentro la banda 3-4 del §7 | 0/30 |
| sotto il minimo di 2 | **30/30** |

The payoff of the entire design never fired. But the naive policy was itself
wrong: Aldric's Victory needs `control_count >= 2`, and control only ever changes
hands through a Confluence Consequence. A competent Aldric *drives the Famine up*
to force the Confluence he can win. Teaching the policy that — still from the
data, not by hand — moved the median from 0 to 3 with **no rule change at all**.

So most of the apparent problem was the measuring instrument. That is the reason
this pass measured before it changed anything.

### Choosing the rule

Four candidates, 40 Chronicles each, same seeds:

| variante | mediana | in banda 3-4 | fuori dai limiti §7 | INFLUENCE/partita |
|---|---|---|---|---|
| A — regole v0.2 invariate | 3 | 60% | **10/40 sotto il minimo** | 45.7 |
| **B — cap di 1 per Entita per round** | **4** | **82%** | **0/40** | **20.1** |
| C — la presenza copre solo il +1 | 2 | 0% | 1/40 sotto | 47.1 |
| D — B e C insieme | 4 | 72% | 0/40 | 27.3 |

B wins outright and is the smallest change. C on its own makes things *worse*,
and D adds a second rule for a worse result than B alone, so neither ships.

Under B, INFLUENCE drops from 63% of every action taken in a Chronicle to 28%,
which is the real point: the other five templates get their table time back.

### The rule

One INFLUENCE per Entity per round, across all Tensions. Data-driven and
reversible: omit `influence_rules` entirely and the original v0.2 behaviour
returns. `presence_directions` is implemented too, defaulting to both directions,
so candidate C stays one config line away for the 0.2 pass.

Guarded by `tests/smoke/test_balance.gd`. See D-023 for how that guard was
rewritten — and why — once the second cap landed.

---

## D-156 — La porta sola della Cenere: una Vittoria che dice cosa vuole
**implemented in 0.1.122** (ISSUES 38, chiusa · chiesta dal committente prima della strada C)

D-154 aveva concluso che il vincolo di casa **0 su 8** lo stava facendo
rispettare il seggio piu' fragile del gioco: due varianti del peso della terra
sono state respinte da Kessa e non dal proprio merito, con **una partita** di
differenza. La causa era ISSUES 38 — la sua Vittoria aveva una porta sola. Il
committente ha chiesto di aprirla prima di tutto il resto.

**Prima ho misurato le porte, invece di sceglierne una a naso.** Sedici clausole
candidate, valutate a fine anno su **40 Chronicle** di CHR_03:

| tenuta | clausola |
|---|---|
| **100%** | le gallerie non sono state murate · la Reliquia non e' stata sepolta · hanno fatto una Scoperta · la montagna non e' stata svuotata · il patto col Sale regge · presenza ≥2 sulla montagna · **`control_count >= 1`** |
| 88% | la Reliquia resta calda (TEN_RELIC ≥ 3) |
| 70% | la Cenere sale (TEN_ASH ≥ 3) |
| **45%** | **la veglia sulla montagna e' affidata a loro** (`ash_watch`) |
| **12%** | **`control_count >= 2`** — la porta di allora |
| 10% | la Reliquia e' stata mostrata |
| **0%** | col Vetro non si e' arrivati alla rottura |

Il numero che spiega tutto: **`control_count >= 1` vale il 100%**. Ecco perche'
in D-154 abbassare la soglia le regalava la Vittoria — le sue due clausole
diventavano vere **tutte e due sempre**, e Kessa passava a zero Minimi e trenta
Trionfi su cinquanta. Non era una soglia sbagliata: era una Vittoria fatta di
due decorazioni.

**E il suo Destino non diceva quello che voleva.** La descrizione e' netta — *«I
Signori della Cenere non discutono di reliquie: discutono di **chi decide dove
si scava**. Vogliono che la risposta sia scritta e sia loro»* — e la Vittoria
chiedeva «controllo di almeno 2 Regioni», che e' una frase da gioco di
conquista e non da questa casa.

**La riscrittura**, con l'unica clausola davvero contesa portata dove serve:

| gradino | prima | adesso |
|---|---|---|
| Minimo | presenza ≥2 sulla montagna | *invariato* |
| **Vittoria** | «Tengono la montagna, e non solo quella»: control ≥2 · gallerie non murate | **«Chi scava lo dicono loro»**: la montagna e' ancora loro (control ≥1) · **e la veglia e' affidata a loro, per atto e non per abitudine** · e le gallerie non sono state murate |
| **Trionfo** | «E la veglia sulla montagna e' loro»: `ash_watch` · patto col Sale · Reliquia non sepolta · TEN_ASH ≥3 · TEN_RELIC ≥3 | **«E non solo quella»**: **il registro della montagna copre due Regioni, non una** (control ≥2) · le altre quattro invariate |

E' lo stesso principio scritto in D-152 e finalmente applicato per intero: **la
Vittoria chiede di tenere quello che si ha, il Trionfo chiede di crescere.** La
clausola sul controllo non e' stata cancellata — e' salita di un gradino, dove
il suo 12% e' una virtu' invece che un muro.

**Cosa ha fatto, sul seggio:**

| Kessa dei Fuochi, 50 partite | NONE | MINIMO | VITTORIA | TRIONFO |
|---|---|---|---|---|
| prima | 1 | **44** | 5 | 0 |
| adesso | 0 | 18 | **31** | 1 |

ISSUES 38 chiedeva «sotto i dieci Trionfi su cinquanta con almeno dieci
Minimi»: **1 Trionfo e 18 Minimi**. E il tavolo misto resta **0 su 8**.

**Il quadro generale si e' mosso con lei.** Sessanta Chronicle: supera il Minimo
**48% → 54%**, VITTORIA 43% → **48%**, TRIONFO 5% → **6%**. Non e' solo Kessa
che si sblocca: un seggio che finalmente insegue qualcosa cambia i Consigli di
tutti.

**Il prezzo, dichiarato:** i Consigli falliti passano da **177 a 191**, e il
tavolo uniforme da 2 a 3 seggi bloccati. La ragione e' che la Cenere adesso
**si batte** per la veglia — la policy legge le clausole del proprio Destino per
decidere come votare — e un tavolo dove una casa in piu' ha qualcosa da
difendere e' un tavolo che litiga di piu'. Il vincolo di casa (0/8) regge e la
mediana dei Consigli non si muove (6); il numero e' comunque sopra la banda
recente e resta a verbale come tale.

**Una lezione di metodo, presa sul posto.** Le frequenze misurate qui sopra
valgono **sotto il Destino di prima**. `ash_watch` valeva il 45% quando nessuno
lo cercava; da quando e' una clausola di Vittoria, la policy lo insegue e la sua
tenuta sale al **63%**. Una clausola diventa piu' facile *nel momento in cui
diventa un obiettivo*: la misura preventiva dice quali porte esistono, non quanto
saranno larghe dopo.

**E una cosa trovata per strada:** «col Vetro non si e' arrivati alla rottura»
vale **0% su 40 partite**. La Cenere e l'Ordine del Vetro partono NEMICI e non
risalgono **mai**. E' la terza volta che la stessa cosa si presenta da una porta
diversa (D-139, D-151): le relazioni non si muovono, e ogni clausola che
dipende da un altro e' irraggiungibile con questi giocatori.

Misure: suite **319 test / 5959 asserzioni** verde; playtest **FAIL 191 · SUCC
69 · SUCC 116 · DECI 190**, tavolo misto **0 su 8**; gradini **54%** sopra il
Minimo. **ISSUES 38 e 38bis chiuse**, e la strada C della
[seduta sulla terra](SEDUTA_TERRA.md) e' sbloccata.

**Poscritto: la CI ha trovato un passo che avevo saltato.** `docs/ASSET_MANIFEST.md`
e' **generato** e porta anche le etichette dei tre gradini di ogni Destino:
cambiare la Vittoria della Cenere lo ha disallineato, e
`tools/build_manifest.py --check` ha bocciato il commit. La regola di casa
diceva «dopo ogni modifica a `/schema` rilancia `gen_gd_schema.py`»; era
incompleta. **Dopo una modifica alle etichette di un Destino va rigenerato anche
il manifesto** — sono due artefatti derivati, non uno.

---

## D-155 — Le carte parlano: cosa fa una carta, prima di calarla
**implemented in 0.1.121** (difetto trovato dal committente giocando)

«Le carte che vengono giocate ora non si capisce quale effetto hanno, le frasi
sono belle ma non si capiscono e alla fine **non hanno effetti sul gioco**.»

La seconda meta' della frase e' falsa e la prima la spiega: **39 carte del
Narratore su 39 portano almeno un effetto**, e 47 Asset su 48. Gli effetti
c'erano. Era la carta a essere muta.

**Il difetto, in una riga.** Le carte Asset dichiarano il proprio mestiere da
D-042 — accanto a ogni opzione di impegno c'e' quanto vale *qui* e cosa costa al
mondo. Le carte del Narratore no: si sceglievano da

> «Cala la carta del Narratore: Mancanza»

e basta. Titolo bellissimo, zero informazione. Una carta che non dichiara cosa
fa e' **indistinguibile da una che non fa niente** — che e' esattamente la
conclusione a cui il committente e' arrivato giocando, ed era la conclusione
ragionevole.

**Cosa dice adesso.** `scripts/core/echo_text.gd`, gemello di `asset_text.gd` e
costruito con lo stesso criterio: il riassunto si compone **dai campi che il
motore legge davvero**, cosi' una carta non puo' dire una cosa e farne un'altra.

> Cala la carta del Narratore: **Mancanza** — *stringe*
> La Carestia sale di 1 · Valle Verde: il raccolto non basta · Valle Verde: il
> granaio non c'e' piu

> Cala la carta del Narratore: **Tradimento** — *rompe*
> Nel mondo: betrayal spoken · La Carestia sale di 1 · **apre subito un
> Consiglio su La Carestia**

Il tono («stringe, rompe, svolta, chiude, ricorda») dice al tavolo che cosa
aspettarsi dalla famiglia drammatica senza spiegare Propp.

**E per strada e' venuto fuori un difetto piu' largo: la mappa parlava in
identificativi.** Il registro pubblico, la console e la vetrina dicevano
`Valle Verde: condition:lean`. Un tag e' un identificativo: sta bene nei dati e
non si legge al tavolo. Quello che gli manca e' un verbo.

- **31 segni** hanno adesso una frase — le tredici condizioni, le cinque
  strutture, le tredici cicatrici;
- e una **seconda** frase per quando spariscono, perche' «non piu si muore di
  fame» non e' italiano: `condition:starving` va via come «la fame e' passata»,
  `structure:granary` come «il granaio non c'e' piu»;
- `SET_ENTITY_TAG` e `REMOVE_ENTITY_TAG` non stampano piu' il tipo grezzo;
- le **caselle da riempire** (`$rival`, `$proponent`, `$region_focus`) in
  anteprima diventano parole — «un rivale», «chi la cala», «la Regione della
  domanda». Prima, guardare una carta prima di calarla mostrava `$rival`.

**Un difetto l'ha trovato il test, non io.** `SET_RELATION` stampava la coppia
come `$proponent / $rival` senza risolvere nessuno dei due lati: sfuggiva perche'
al momento di applicare l'Effect le caselle sono gia' piene, e nessuno guardava
mai la stessa frase *in anteprima*. Il test che vieta gli identificativi al
tavolo l'ha visto al primo giro. (Ne ha trovato anche uno mio: `str(null)` non
e' la stringa vuota, e il ciclo che cercava «una carta che apre un Consiglio»
prendeva la prima carta qualsiasi.)

Misure: suite **319 test / 5959 asserzioni** verde, sette test nuovi;
`dead_code.py` pulito su 149 file. Nessuna regola cambiata — **il gioco fa
esattamente quello che faceva prima, e adesso lo dice**.

---

## D-154 — Il peso della terra: meccanismo acceso, contenuto spento
**implemented in 0.1.119** (deciso dal committente, respinto dalla misura)

Il committente ha deciso: «**il titolo deve dare qualcosa dentro l'anno,
muoversi e avere maggioranza deve pesare**». D-152 aveva mostrato che il
controllo, dentro l'anno, non fa niente — tre soli consumatori, due dei quali
sono costi. Questa e' la leva che glielo fa fare, ed e' scritta e provata. **Nei
dati e' spenta**, e la ragione e' un numero.

**Il meccanismo.** `focus_weight` in `confluence_rules`: al Consiglio, la
Regione **di cui si discute** da' voce a chi ci sta.

- **il titolo** a chi ne e' il padrone — quello che il Destino gia' contava a
  fine anno adesso si sente anche al tavolo;
- **la maggioranza** a chi ci ha *strettamente* piu' pedine di chiunque altro —
  a parita' non la prende nessuno, perche' una maggioranza contesa non e' una
  maggioranza.

I due si sommano fino a un tetto: chi la tiene **e** ci sta dentro parla per
primo. E' `lapse_without_presence` detto dentro l'anno invece che fra un anno e
l'altro. Come ogni altro peso (D-125, D-139) conta solo se quel seggio ha messo
almeno una carta sul tavolo: un bonus dal nulla sarebbe un voto gratis.

**La misura, due volte.** Sui 100 semi da 7000:

| | Consigli falliti | tavolo misto |
|---|---|---|
| spento (0.1.118) | **177** | **0 su 8** |
| titolo +1, maggioranza +1, a tutti | **164** | **1 su 8** |
| lo stesso, senza il proponente | 175 | **1 su 8** |

**Il primo difetto era mio e l'ho capito**: il peso finiva quasi sempre al
**proponente**, che e' gia' scelto *per* la presenza nel dominio. Pagarlo anche
al Consiglio vuol dire pagarlo due volte per lo stesso investimento, e i
Consigli passavano troppo (DECI da 187 a 209). Escluderlo rimette i numeri in
banda — 175 contro 177 — e lascia al peso il caso che vale davvero: **la voce di
chi la terra ce l'ha e il Consiglio non l'ha chiamato**, cioe' «non si decide di
casa mia senza di me».

**Ma resta 1 su 8, e il seggio e' sempre lo stesso.** Kessa dei Fuochi finisce
al Minimo in tutti e quattro i caratteri. Non e' il peso della terra a
romperla: e' che la sua Vittoria ha **una porta sola** (ISSUES 38 —
`control_count >= 2`, e l'altra clausola e' quasi sempre vera). Un seggio che
dipende da una clausola sola non assorbe *nessun* cambiamento: basta una
partita che gli costi il Consiglio dove prendeva la seconda Regione. Nella
variante buona la differenza e' letteralmente **una partita** — Kessa passa da
1/44/5/0 a 1/45/4/0.

**Il che dice una cosa piu' generale, e vale la pena scriverla:** il vincolo di
casa **0 su 8** lo sta facendo rispettare il seggio piu' fragile del gioco. Fino
a che ISSUES 38 resta aperta, qualunque modifica alle regole del Consiglio ha
una probabilita' alta di essere respinta da Kessa e non dal proprio merito.
**ISSUES 38 viene prima**, ed e' contenuto d'autore.

**Cosa resta acceso.** Lo schema, il motore, sette test che tengono fermo il
meccanismo con una `focus_weight` sintetica (il titolo, la maggioranza stretta,
la somma col tetto, i lati dichiarati dai dati, il proponente escluso, e il
niente-carte-niente-peso). Nelle Chronicle la chiave e' omessa: senza, il
Consiglio e' quello di sempre. E' lo stesso criterio di D-150 col pool dei
Destini — quando la misura dice no, si tiene il meccanismo e si spegne il
contenuto, cosi' la prossima volta si riaccende con una riga.

**E c'e' una strada migliore, che il committente ha visto subito dopo.** Contate
le pedine su 30 Chronicle: 240 posate al setup, **38** aggiunte da MUOVERE, 21
da una carta Narratore, 7 da un Consiglio. In un anno intero si muove **poco
piu' di una pedina per partita**. La mappa non e' ferma perche' il titolo non
paga: e' ferma perche' **nessuno ha carte con cui muoverla**. E il vocabolario
esiste gia' — tre Asset posano una pedina quando li impegni, due la tolgono:
cinque carte su quarantotto. La proposta del committente («la guardia reale puo'
giocare effettivamente una presenza in una regione») lavora su quella leva, ed
e' probabilmente quella giusta. Sta in ISSUES 39.

Misure: suite **312 test / 5943 asserzioni** verde (sette test nuovi); playtest
con la regola spenta **FAIL 177 · SUCC 73 · SUCC 126 · DECI 187**, tavolo misto
**0 su 8**, identico a 0.1.118; `dead_code.py` pulito su 147 file.

---

## D-153 — «Rivendicare» esiste: la catena per prendere una Regione, e dove si spezza
**implemented in 0.1.116** (correzione a D-152, sollevata dal committente)

D-152 dice che «il controllo **non si prende con un'azione**». La frase e'
letteralmente vera e **fuorviante**, ed e' stato il committente ad accorgersene:
«ma scusa, le Regioni non si prendono con un'azione specifica?».

**Si', c'e' un'azione: `ACT_CLAIM`, «Rivendicare».** Quello che rivendica pero'
non e' una Regione — e' una **domanda**. In `CREATE` scarta un Asset AUTHORITY
e apre un Claim su un dominio di Tensione (TERRITORY, RESOURCE, SURVIVAL,
KNOWLEDGE, ANCIENT); in un round successivo, in `FORCE`, consuma quel Claim e
un secondo AUTHORITY per **strappare un Consiglio di cui si e' proponenti**. La
Regione arriva solo se quel Consiglio cade su una delle quattordici Consequence
che portano un `SET_CONTROL` a `$proponent`.

Quindi la catena e' lunga cinque anelli:

1. avere un Asset AUTHORITY da scartare, e spenderci un'Azione;
2. che la Tensione bersaglio sia a **3 o piu'**;
3. avere un **secondo** AUTHORITY, e un'altra Azione, in un round dopo;
4. che il Consiglio non fallisca (falliscono 177 volte su 100 partite);
5. che la Consequence uscita sia una delle quattordici giuste.

**Dove si spezza, misurato su 60 Chronicle:**

| | |
|---|---|
| Rivendicazioni aperte (`CREATE`) | **63** |
| Consigli strappati (`FORCE`) | **15** |
| Rivendicazioni morte senza essere usate | **48** |

Circa **una rivendicazione aperta a partita, e una forzata ogni quattro**. Tre
su quattro muoiono in mano: si paga il primo anello e il secondo non arriva
mai. E per confronto, delle azioni giocate in trenta Chronicle 4286 effetti
vengono da `ACT_ACQUIRE` e 84 da `ACT_CLAIM` — le case passano il tempo a
raccogliere, non a rivendicare.

**Cosa cambia nella diagnosi.** Non «manca la leva»: la leva c'e', e' scritta,
ed e' anche una bella idea — *rivendicare non e' prendersi una terra, e'
costringere il tavolo a discuterne*. Quello che manca e' che sia **percorribile**:
cinque anelli in serie, due Asset dello stesso tipo, due Azioni in round
diversi, e un esito che dipende dal mazzo. Il numero da guardare non e' piu'
«quante Regioni cambiano padrone» ma **48 rivendicazioni morte su 63**.

Il che restringe le tre strade di ISSUES 37 a una domanda piu' precisa: non
«serve un'azione per prendere le Regioni» — c'e' — ma **quale anello della
catena si accorcia**. Rimane da decidere, e rimane contenuto d'autore.

**Non e' stato toccato niente del gioco.** La sonda dei gradini adesso conta
anche i tre numeri della catena; D-152 resta a verbale com'e' scritta, con
questa correzione sopra. Suite **305 verde**, playtest invariato — **FAIL 177 ·
SUCC 73 · SUCC 126 · DECI 187**, tavolo misto **0/8**.

---

## D-152 — La corona tiene la sua terra: una soglia abbassata, una no
**implemented in 0.1.115** (la prima delle due decisioni che D-151 aveva rimandato al committente)

D-151 aveva chiuso con due domande. Il committente ha scelto la prima —
**abbassare la soglia** — e la misura ha detto sì a meta'.

**Prima: D-151 aveva torto sul meccanismo.** Ci sta scritto che
`control_count >= 2` «chiede il tetto, perche' `max_stable_control` e' 2».
Non e' cosi'. `max_stable_control` non e' un tetto: e' una **soglia di
fatica** (D-027) — si possono tenere tre Regioni, costa un punto di Tensione
per giro sulla domanda di quella Regione. E infatti nessuno ci arriva mai:
su 240 seggi misurati, **tre** ne tengono tre. Il soffitto non e' il vincolo,
perche' nessuno lo tocca.

**Il vincolo vero e' che la mappa non si muove.** La sonda dei gradini ora
misura anche il tabellone, e il quadro e' questo:

| Regioni tenute a fine anno | seggi |
|---|---|
| 0 | **30%** |
| 1 | 57% |
| 2 | **12%** |
| 3 | 1% |

**Il 44% delle caselle non e' di nessuno**, a fine anno come a inizio anno. E
la ragione e' strutturale: il controllo **non si prende con un'azione**. Passa
solo per una Consequence, cioe' per un Consiglio che si chiude — e i Consigli
falliscono 185 volte su 100 partite. Casa per casa, in un anno intero:

| casa | inizio | fine |
|---|---|---|
| Aldric | 1,00 | 1,23 |
| Sale | 1,00 | 1,27 |
| Nahr | 1,00 | 1,20 |
| Cenere | 1,00 | 1,17 |
| Vaerax | 1,00 | **1,00** |
| Le Citta' Libere | 1,00 | **0,67** |
| Lyra | 0,00 | 0,17 |
| Il Vetro | 0,00 | **0,00** |

In trenta partite **il Vetro non tiene mai una Regione**, e le Citta' Libere
ne perdono. Una clausola scritta «almeno due» non chiede il massimo consentito:
chiede a una casa di **raddoppiare** in un mondo che le muove un quarto di
Regione all'anno.

**La modifica, e perche' non e' cancellare la clausola.** Le regole hanno
`lapse_without_presence`: una Regione tenuta senza starci dentro torna a
nessuno. Percio' «almeno una» non e' gratis — **il 30% dei seggi finisce a
zero**. La Vittoria smette di chiedere di crescere e chiede di **tenersi
quello che si ha**, che in questo mondo e' una domanda vera.

- `DST_ALDRIC` vittoria: `min 2` -> `min 1`, e l'etichetta da «Controllo di
  almeno 2 Regioni» a **«La corona tiene ancora la sua terra»**.

**Cosa ha fatto, sul seggio:**

| Re Aldric, 50 partite | NONE | MINIMO | VITTORIA | TRIONFO |
|---|---|---|---|---|
| prima | 0 | **43** | 5 | 2 |
| dopo | 1 | 24 | **17** | 8 |

Da un muro al Minimo a una distribuzione. E il suo ostacolo adesso non e' piu'
la terra ma **la Carestia** («La Carestia non supera 4», mancata nel 30%): il
re vince se il mondo regge, non se il regno cresce. Che e' meglio come frase e
meglio come gioco.

**E la seconda soglia e' stata rimessa dov'era.** La stessa modifica sulla
Cenere e' stata provata e **respinta dalla misura**:

| Kessa dei Fuochi, 50 partite | NONE | MINIMO | VITTORIA | TRIONFO |
|---|---|---|---|---|
| prima | 1 | 44 | 5 | 0 |
| con la soglia a 1 | 1 | **0** | 19 | **30** |

Zero Minimi su cinquanta. Il motivo e' che la vittoria della Cenere ha **due**
clausole e la seconda («le gallerie non sono state murate») e' quasi sempre
vera: la soglia sul controllo era l'unica porta, e reggeva anche il Trionfo
sopra di se'. Toglierla non abbassa un gradino, li apre tutti e due. Il suo
problema non e' la soglia — e' che a quella Vittoria manca una seconda
clausola con dei denti, e **scriverla e' contenuto, non taratura**. Resta a 2.

**Misure.** Playtest 100 semi da 7000: **FAIL 177 · SUCC 73 · SUCC 126 ·
DECI 187** (era 185 · 76 · 123 · 178) — i Consigli si muovono perche' la
policy legge le clausole del proprio Destino per decidere come votare, quindi
un re che non insegue piu' la seconda Regione vota diverso. Tavolo misto
**0 su 8**, invariato; tavolo uniforme **3 su 8 -> 2 su 8**, meglio. Gradini
su 60 Chronicle: supera il Minimo **47% -> 48%**, e la clausola di Aldric
passa da **63% a 27%** di volte mancata. Suite **305 test verde**;
`run_sims.sh` e `run_export.sh` identici su due giri.

Le asserzioni sono passate da 6202 a 5930 senza che un test cambiasse: sei
suite (`test_chronicle_run`, `test_hotseat`, `test_resume`,
`test_effect_narrator`, `test_year_end_floor`, `test_chronicle_book`)
camminano su una partita giocata e contano una asserzione per effetto. Cambia
il voto, cambia il numero degli effetti. Stessi 305 test, tutti verdi.

**Resta aperta la seconda domanda di D-151**, intatta: le clausole sociali non
si possono misurare senza persone.

---

## D-151 — I gradini: quale clausola non si avvera mai
**implemented in 0.1.114** (la diagnosi che D-150 ha reso necessaria)

D-150 ha corretto una lettura e lasciato una domanda: se il Minimo e' una
soglia di sopravvivenza, la misura che conta e' **quanti la superano** — e
quella non si muove. Ma «la Vittoria e' difficile» non e' una diagnosi.
`cli/run_rung_probe.gd` chiede una cosa piu' stretta: **quale clausola** resta
in sospeso, e quanto spesso. Il rapporto dei Destini porta gia' `unmet`, quindi
la sonda non valuta niente — conta.

**Sessanta Chronicle a tavolo misto:** NONE 0% · MINIMUM **52%** · VICTORY
**42%** · TRIUMPH **5%**. Supera il Minimo il **47%** — piu' del 30% delle
saghe, e la differenza e' interessante di suo: una Chronicle dentro una saga
eredita un mondo gia' segnato, e vincere in una terra ferita e' piu' difficile
che vincere sul foglio pulito.

Le clausole che nessuno vede mai:

| manca | Destino | clausola |
|---|---|---|
| **100%** | Vaerax (trionfo) | Nessuno arriva facilmente fin lassu' |
| **90%** | Le Citta' (trionfo) | E la Gilda non e' diventata un nemico |
| **87%** | La Cenere (vittoria) | **Controllo di almeno 2 Regioni** |
| **77%** | Lyra (vittoria) | **Qualcuno ha giurato** di tenerle aperta la strada |
| **77%** | Nahr (trionfo) | La corona ha smesso di essere una sola |
| **63%** | Aldric (vittoria) | **Controllo di almeno 2 Regioni** |

Due famiglie, e ognuna dice una cosa diversa.

**La prima: chiedere il tetto.** `control_count >= 2` compare in sei Destini, e
il tetto del mondo e' **`max_stable_control: 2`** — cioe' la Vittoria chiede
esattamente il massimo che le regole concedono, su una mappa di sei Regioni
divisa fra quattro case. Non e' un obiettivo ambizioso: e' il soffitto. La
Cenere lo manca nell'87% delle partite, Aldric nel 63%.

**La seconda, e piu' seria: le clausole che dipendono da un altro.** «Qualcuno
ha giurato», «la Gilda non e' diventata un nemico», i patti che reggono —
**cinque clausole su centoquattro** parlano di promesse e relazioni, e sono
proprio quelle che mancano piu' spesso. La ragione la sapevamo gia' da
stamattina senza collegarla: **in venti Chronicle le relazioni si muovono una
volta sola**, e le policy non promettono mai. Tutto cio' che chiede *un altro*
e' irraggiungibile per costruzione con questi giocatori.

Il che chiude il cerchio aperto in D-139. Il peso dell'alleanza non e' raro
perche' e' tarato stretto: e' raro perche' **nessun bot stringe alleanze**. Le
stesse clausole sociali che non si avverano sono la meta' del gioco che nessuna
simulazione ha mai visitato — e sono anche, quasi certamente, la meta' che al
tavolo vero si accende da sola: le persone promettono, si alleano e si
tradiscono senza che nessuno glielo chieda.

**Non e' stato toccato niente.** Questa e' una diagnosi, e le due famiglie
chiedono decisioni diverse — abbassare una soglia e' contenuto d'autore, e
misurare le clausole sociali richiede persone, non semi. Le due domande vanno
al committente cosi' come sono.

Misure: sonda nuova, nessuna modifica al motore o ai dati; suite **305/6202**
verde; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto
**0/8**, invariato.

---

## D-150 — Il pool dei Destini: il meccanismo sì, il contenuto non ancora
**implemented in 0.1.113** (strada A della [seduta sulle linee](SEDUTA_LINEE.md), scelta dal committente)

Il meccanismo c'e' ed e' provato; **nelle Chronicle e' spento**, e la ragione
e' una misura che ha detto di no. Vale la pena scrivere per intero come si e'
arrivati qui, perche' e' andata diversamente da come sembrava a meta' strada.

**Il meccanismo.** `destiny_pool` sulla Chronicle: per ogni casa, i Destini fra
cui l'anno pesca. E' `tension_pool` applicato agli obiettivi — omesso, ogni
casa insegue il `destiny_id` scritto sull'Entita' e non cambia niente. Nessun
Destino si permuta fra le case: ognuno resta scritto per la sua
(SEDUTA_LINEE §2).

**La scoperta che ha accorciato il lavoro.** Stavo per scrivere otto Destini
nuovi; ne esistevano gia' **otto orfani**, uno per casa —
`DST_ALDRIC_RECORD`, `DST_NAHR_ROOTED`, `DST_LYRA_TAUGHT`,
`DST_VAERAX_WATCHED`, `DST_SALE_OPEN`, `DST_VETRO_SHOWN`, `DST_CENERE_DEEP`,
`DST_LIBERE_WATER` — scritti ai tempi dei valori per vita (D-111) e mai
attaccati a niente. Nove Destini su venti erano in uso; undici no.

**Il dado a parte, che e' un difetto vero preso per strada.** Accendendo i pool
i tre piani di simulazione sono usciti **diversi a Destini identici**: la pesca
attingeva al caso della partita, quindi spostava mazzi, deriva e domande. E' lo
stesso errore che D-051 aveva gia' evitato coi caratteri («chi siede dove lo
decide un RNG a parte»). Adesso il dado dei Destini e' suo, e un test lo prova:
accendere il pool cambia **cosa la gente vuole**, non che mondo trova.

**E la misura ha detto no.** Coi pool accesi sulle quattro Chronicle:

| | senza pool | con pool |
|---|---|---|
| playtest, Consigli falliti | **185** | **222** |
| tavolo misto, seggi bloccati | **0 su 8** | **2 su 8** |

Il vincolo di casa e' 0/8, e 222 e' fuori banda. Gli otto Destini orfani non
sono pronti: **sono contenuto scritto e mai giocato**, e nessuno li ha mai
misurati contro la policy. Averli trovati gia' fatti mi ha fatto saltare il
passo che questo progetto non salta mai — accendere **uno per volta** e
misurare (D-104, D-117). Restano spenti finche' non lo si fa.

**Quello che la sonda della varieta' ha detto lo stesso**, e vale piu' del no:
con i pool accesi la prima linea e' andata a **distanza 0,89** (da 0,81), 84
frasi distinte (da 74), Trionfi 15 (da 11) — il pool *funziona*, fa quello che
deve. Sulla seconda linea invece non e' cambiato quasi niente, e il perche' e'
la cosa piu' importante uscita da tutta questa giornata:

**Il Minimo di ogni Destino e' «esistere».** Guardati in fila, i primi gradini
sono tutti la stessa cosa — la casa e' viva e sta da qualche parte — e due
coppie ce l'hanno **identico parola per parola** (Vetro, Cenere). Il Minimo non
e' un obiettivo: e' una **soglia di sopravvivenza**.

Questo corregge la lettura che avevo dato a D-149. «Il 64% dei Destini finisce
al Minimo» non vuol dire «i giocatori vogliono sempre la stessa cosa»: vuol
dire che **restano vivi e non arrivano al secondo gradino**. La misura giusta
per [ISSUES 35](ISSUES.md) non e' la colonna MINIMUM, e' **quanti superano il
Minimo** — e quella e' ferma al 30% col pool e senza. Il pool non era la cura,
perche' la malattia era un'altra.

**Come si riprende, quando si riprende**: un Destino alternativo per volta,
acceso su una casa sola, playtest a ogni passo, e si tiene solo se resta
185 · 0/8. Il meccanismo, la sonda della varieta' e i quattro test sono gia'
li' e non chiedono niente a nessuno.

Misure: suite **305/6202** verde; playtest **FAIL 185 · SUCC 76 · SUCC 123 ·
DECI 178**, tavolo misto **0/8** — la baseline esatta, coi pool spenti; sims
deterministici; 22 documenti validi.

---

## D-149 — La distanza fra due saghe
**implemented in 0.1.112** (la misura che mancava per rispondere al committente: «linee sempre diverse»)

Il committente ha chiesto un sistema che permuti obiettivi, entita' e vite
per avere linee sempre diverse. La prima cosa che serviva non era il sistema:
era **sapere quanto sono diverse adesso**. Tutte le sonde del progetto
misurano il motore — esiti in banda, seggi non bloccati, filo trasparente,
fughe — e nessuna sa rispondere a «le partite si somigliano?», che e' una
domanda sul contenuto. Senza, si aggiunge varieta' e si spera.

Il metro sono le **Truth**: le frasi che una decisione lascia scritte nel
registro. Sono il prodotto del gioco — quello che al tavolo si legge ad alta
voce e che resta fra una Chronicle e l'altra — quindi due saghe che scrivono
le stesse frasi hanno raccontato la stessa storia, per diversi che siano
stati i numeri. Tre indici: le frasi distinte, il **nocciolo** (quelle che
compaiono in *tutte* le saghe) e la **distanza** media fra due saghe
qualsiasi (Jaccard sulle frasi: 0 identiche, 1 niente in comune).

A tavolo **misto** per scelta: i quattro caratteri (D-053) sono la cosa piu'
vicina a persone vere che il progetto abbia, e quattro ottimizzatori identici
sono il caso in cui la ripetizione e' garantita per costruzione.

**Due difetti di misura, presi prima di fidarsi del numero.** Il primo:
distanza 1,00 e nocciolo zero al primo giro — perfetto e falso, perche' una
Truth nasce con l'anno davanti («Anno 1640, Atto 2: …») e il punteggio dietro
(«(S5 O0 M7)»), quindi due saghe non condividono **mai** una frase. Misurava
l'orologio invece della storia; ora la frase si spoglia prima di contarla. Il
secondo: «vite viste al tavolo: 4» in trenta Chronicle, quando le saghe
raccontate mostrano il Regno di Nahr, il Ridestato, la Lega delle Sette — il
campo `incarnation_id` non esiste, la vita e' `incarnation`, un indice. Dieci
su quattordici, adesso.

**La baseline, cinque saghe da sei Chronicle a tavolo misto:**

| | frasi distinte | nocciolo | distanza | NONE | MIN | VIC | TRI | vite |
|---|---|---|---|---|---|---|---|---|
| CHR_01 (i re) | 74 | 2 | **0,81** | 7 | **77** | 25 | 11 | 10/14 |
| CHR_03 (le citta') | 57 | 2 | **0,79** | 19 | **63** | 27 | 11 | — |

E la lettura, che cambia la domanda da cui si era partiti: **le storie sono
gia' diverse — quello che si ripete sono gli obiettivi.** Otto decimi di
distanza vuol dire che due saghe condividono poco piu' di una frase su
cinque, e il nocciolo e' due frasi in tutto. La biblioteca delle domande
(`tension_pool`) sta gia' facendo il suo lavoro.

Ma i Destini sono uno per casa, sempre quello, e il risultato sta nella
colonna che conta: **il 64% dei Destini finisce al Minimo** sulla prima linea,
il 52% sulla seconda. I giocatori raccontano storie diverse **volendo sempre
la stessa cosa** — ed e' la stessa forma che [ISSUES 35](ISSUES.md) ha visto
nella seconda meta' della saga del Sale, misurata qui su trenta Chronicle
invece che su dieci.

Questo dice anche *come* fare la strada A della seduta ([SEDUTA_LINEE.md](SEDUTA_LINEE.md)):
il pool dei Destini non serve a rendere le storie piu' varie — quelle lo sono
gia' — serve a **rompere il Minimo come risposta giusta di default**. E il
numero da battere e' quella colonna, non la distanza.

---

## D-148 — Il ritardatario, e il silenzio che non e' una risposta
**implemented in 0.1.110** (dalla domanda di conferma del committente: «i giocatori si collegano e quando parte la partita i mancanti sono bot?»)

Si', esattamente cosi': la stanza guarda **chi ha una console agganciata nel
momento del via** e ne fa la lista degli umani; ogni seggio che in quell'istante
non ha nessuno lo gioca una policy, per tutta la partita. Nessuna
configurazione, nessun conteggio da dichiarare prima: **la connessione e' la
dichiarazione**.

Rispondendo pero' e' venuto fuori il caso che nessuno aveva guardato: **chi
arriva dopo**. Il suo telefono si aggancia benissimo — l'host accetta il token,
gli manda lo stato, il pannello si aggiorna a ogni mossa — ma il suo seggio e'
gia' affidato a una policy, quindi non gli viene chiesto **mai niente**. Lo
scopriva dal silenzio, e il silenzio non e' una risposta: e' identico a un filo
rotto, a un telefono che dorme, a una partita che aspetta qualcun altro. Al
tavolo sarebbero due minuti passati a fissare uno schermo muto chiedendosi se
si e' rotto qualcosa.

Adesso la stanza dichiara all'host chi gioca (`seated`), e chi si aggancia dopo
riceve una riga: «sei arrivato a partita cominciata: il tuo seggio lo sta
giocando la policy, e da qui puoi guardare». Guardare resta possibile — il
pannello e' il suo e i suoi segreti sono suoi — ma adesso lo sa.

La riga vive in `watching(seat)` invece che dentro l'invio, cosi' e' una domanda
che si puo' fare a voce alta e un test puo' rispondere: prima del via nessuno
guarda soltanto (la lista vuota vuol dire «non e' ancora cominciata», ed e' la
ragione per cui esiste invece di dedurla dagli `ios`); dopo, chi non c'era
guarda e chi c'era gioca.

Resta dichiarato, e vale la pena saperlo prima della prova: **un seggio lasciato
alla policy resta alla policy fino a fine Chronicle**. Prendersi un seggio a
metà partita e' la console di riserva rovesciata, e sta nello stesso posto dove
quella aspetta — dopo la prova, quando si sara' visto se serve davvero.

Misure: suite **301/6145** verde (il test del ritardatario e' nuovo); filo
**trasparente byte per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 ·
DECI 178**, tavolo misto **0/8**, invariato.

---

## D-147 — Quanti giocatori, e i bot messi alla prova
**implemented in 0.1.109** (chiesto dal committente: «si puo' scegliere il numero di giocatori? O si deve giocare per forza in quattro? Funzionano i bot?»)

Tre domande, e le risposte erano diverse fra loro: una era gia' vera, una era
una lacuna, una non era mai stata misurata.

**I seggi sono quattro, e non e' un'impostazione.** Ogni Chronicle ne dichiara
quattro — CHR_01/02 le quattro case della prima saga, CHR_03/04 quelle della
seconda — perche' il Consiglio *e'* quel tavolo: le domande dell'anno, le
relazioni, i Destini e le proposizioni sono scritti per quelle quattro voci.
Un tavolo a tre o a cinque non e' un'opzione da spuntare, e' un'altra
Chronicle da scrivere. Questo si dichiara invece di lasciarlo intuire.

**Quante di quelle quattro voci siano persone, invece, e' sempre stato libero
— tranne nel posto piu' visibile.** La riga di comando lo sa fare da 0.0
(`--seats=all`, o un seggio per nome); la stanza lo decide da chi si collega
col proprio codice; e il menu dell'app chiedeva **quale** seggio prendi e
basta, cioe' offriva uno solo dei quattro modi. Adesso, scelto il proprio,
chiede «siete in N, qualcun altro a questo schermo?» finche' il tavolo e'
pieno o qualcuno dice basta. Nessuna regola nuova: la stessa `humans` che il
`SeatDecider` accetta da sempre, chiesta anche li'.

**«Funzionano i bot?» non e' una domanda d'opinione**, ed e' rimasta senza
misura per otto versioni. Il playtest confronta un tavolo di quattro
ottimizzatori identici con un tavolo di quattro caratteri diversi (D-051,
D-053) — misura il *contenuto*, dando per scontato che i giocatori giochino.
Nessuno aveva mai chiesto ai bot di battere qualcosa.

`cli/run_bot_probe.gd` glielo chiede, e il metro e' **il caso**: lo stesso
mondo giocato due volte, una col seggio studiato alla policy e una allo stesso
seggio che tira a sorte fra le mosse legali. Il caso resta legale — passa dagli
stessi controlli — quindi la differenza e' tutta nel giudizio. Il punteggio non
sono i Consigli vinti ma il **Destino raggiunto**: e' quello che un seggio sta
cercando di fare, e l'unico modo di dire «gioca bene» senza inventarsi un
punteggio.

Su 40 partite (semi da 7000, le due Chronicle alternate):

| | NONE | MINIMUM | VICTORY | TRIUMPH | media |
|---|---|---|---|---|---|
| policy | **0** | 22 | 10 | 8 | **1,65** |
| caso | **20** | 18 | 1 | 1 | 0,57 |

La policy fa meglio in **26 partite su 40**, peggio in 2, pari in 12. Il numero
che dice piu' di tutti e' la prima colonna: **il caso manca il Destino minimo
in metà delle partite, la policy non lo manca mai**. Un avversario che non
batte il sorteggio non e' un avversario, e' un generatore di mosse legali;
questo lo batte, e adesso c'e' scritto quanto.

Le due partite dove il caso ha fatto meglio non sono un difetto: un Destino
puo' compiersi per come gira il mondo, e una policy che ottimizza puo' passare
accanto a una fortuna che nessuno stava cercando. Trentotto volte su quaranta
non succede.

Misure: sonda dei bot **26/40 a favore, media 1,65 contro 0,57**; playtest
**FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto **0/8**, invariato;
suite **300/6141** verde; 22 documenti validi.

---

## D-146 — Le schede, il telefono coricato, e i pezzi che si muovono sulla mappa
**implemented in 0.1.108** (chiesto dal committente: «come si fa a muovere i pezzi sulla mappa dagli smartphone? …schede invece di tutto insieme, e in orizzontale si razionalizza meglio»)

Tre osservazioni, tutte e tre giuste, e la prima era una domanda con una
risposta gia' pronta nei dati: **i `subjects` arrivavano al telefono da sempre**
e nessuno li guardava. Ogni scelta che riguarda una Regione porta con se' quale
— e' cosi' che lo schermo grande accende le Regioni raggiungibili (D-038) — ma
la console ne faceva un bottone con scritto «Metti una presenza in Eredan».
Muovere un pezzo leggendo il nome del posto invece di toccarlo e' la stessa
distanza che c'e' fra un elenco e una mappa.

**La mappa si tocca.** La console prende `/mappa.svg` (D-145) **inline** invece
che come immagine — un'immagine non si puo' toccare per pezzi — e ogni Regione
porta il suo id. Quando una domanda offre delle Regioni, quelle si accendono
col cerchio d'oro (che sta nel disegno, spento, cosi' l'host non deve
ridisegnare la mappa per un'evidenziazione) e il dito risponde li'. Le stesse
scelte **spariscono dai bottoni**: due strade per la stessa mossa vogliono dire
che una delle due e' quella sbagliata, e la peggiore sarebbe rimasta la piu'
comoda da premere. Delle 18 scelte di un'azione, 4 vanno sulla mappa e 14
restano in elenco — che e' anche il modo piu' onesto di accorciare quell'elenco
senza togliere niente (D-143).

**Tre schede — Mappa, Mano, Seggio.** Tutto insieme in colonna vuol dire
scorrere per trovare, e al tavolo il telefono si guarda per un secondo fra una
parola e l'altra. Un pallino sulla linguetta dice quando una scheda ha qualcosa
(la mano non vuota), cosi' non si va a controllare a vuoto.

**Il telefono coricato non e' il telefono in piedi piu' largo.** Lo spazio di
uno schermo orizzontale e' largo e basso: impilare li' vuol dire scorrere
sempre, e la mappa diventerebbe una striscia. In orizzontale le schede e la
domanda si **affiancano** — mappa a sinistra, scelte a destra, niente da
scorrere per giocare.

Un difetto preso guardando, che vale la pena scrivere perche' e' il tipo di
cosa che un test non prende: `main` era `display: flex` senza direzione, e in
CSS il flex e' una **riga** finche' non dici il contrario. In piedi, la barra
della domanda si e' messa di fianco alla mappa e se l'e' mangiata: metà schermo
di scelte sopra una mappa invisibile. La riga mancante e' `flex-direction:
column`; la fotografia l'ha trovata in un secondo, e nessuna suite l'avrebbe
mai vista.

Resta come sta, dichiarato: **un token, una console**. Due pagine aperte con lo
stesso codice se lo contendono, e nella prova si sono viste alternare
(«filo caduto — riprovo…»). Al tavolo un seggio ha un telefono solo, quindi non
morde; se un domani mordesse, e' il posto giusto dove metterci una parola.

Misure: sonda dei messaggi **20.844 perquisiti, FUGHE 0**; filo **trasparente
byte per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo
misto **0/8**; suite **300/6141** verde; 22 documenti validi. La console non
tocca il motore: la riprogettazione e' tutta di questa parte, e i numeri lo
dicono restando fermi.

---

## D-145 — Il tabellone disegnato, e le carte giocate in tavola
**implemented in 0.1.107** (chiesto dal committente: «ma la mappa? I token, le pedine e le carte giocate?»)

Sulla vetrina la mappa era **raccontata, non disegnata**: una griglia di
riquadri, «Eredan · di Re Aldric · Re Aldric ×1, Lyra ×1». Da bordo tavolo una
mappa raccontata non e' una mappa — e le pedine e i vessilli di D-138 vivevano
solo sul canvas di Godot, cioe' sull'unico schermo che al tavolo nessuno
guarda da vicino. Le carte impegnate in Consiglio, poi, non c'erano affatto:
si rivelano tutte insieme in seduta (D-014), e dopo sparivano dentro una riga
di verbale.

**`board_sheet.gd` non ridisegna niente: rilegge gli stessi piani.** Le sagome
delle tessere e i tratti del terreno vengono da `RegionArt.plan` — coordinate
normalizzate, quindi valgono su qualunque superficie (D-057) — le pedine e i
vessilli da `IconSet` (icone come dati, D-058), i colori dei seggi dallo stesso
ordine di turno di `map_view` (D-050). E' la disciplina di D-097 estesa a una
terza superficie: **una forma sola, tre usi** — il canvas, la fustella, il
browser. Una tessera che cambia nei dati cambia in tutti e tre insieme.

L'host serve `/mappa.svg`, senza cache (il tabellone cambia a ogni mossa, e
l'orologio del mondo in coda all'indirizzo lo fa ricaricare solo quando il
mondo e' cambiato davvero); le carte impegnate arrivano dai Consigli **chiusi**
con la loro faccia, per fronte.

**Il pezzo delicato e' quale Consiglio.** Gli impegni sono coperti finche' non
si rivelano: mostrarli mentre la seduta e' aperta direbbe a tutti cosa ha
appena messo giu' chi non ha ancora parlato. La sorgente giusta e'
`confluence_results` — solo i chiusi — e la guardia nella perquisizione della
vetrina lo tiene onesto.

**Ma la prima stesura della guardia ha gridato al lupo 58 volte.** Confrontava
il *titolo della domanda* del Consiglio aperto con quelli in tavola, e la
stessa domanda torna al Consiglio piu' volte in una Chronicle: un Consiglio
chiuso su «Il Risveglio» piu' uno aperto sulla stessa domanda erano, per quel
confronto, la stessa cosa. E' la **terza** volta che il confronto per nome mi
inganna — 658 fughe false in D-135, 54 in D-144, 58 qui — e la lezione, ormai
scritta tre volte, e' sempre la stessa: **un titolo non e' un'identita'**. Ora
la guardia confronta il `confluence_id`, e la seduta e' se stessa e nient'altro.

Un difetto visto e corretto guardando: il tabellone finito **dentro** la
griglia delle Regioni diventava una cella larga come un riquadro — la mappa
grande come una didascalia. Sta fuori; i riquadri restano sotto, che sono
l'ispezione al tocco (la C della seduta).

Misure: sonda dei messaggi **20.844 perquisiti, FUGHE 0**; filo **trasparente
byte per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo
misto **0/8**; suite **300/6141** verde (quattro test nuovi sul tabellone, fra
cui il conto delle pedine e i colori che non si ripetono); sims ed export
deterministici; 22 documenti validi.

---

## D-144 — Le carte vere sul telefono, e la mano che il tavolo leggeva
**implemented in 0.1.106** (chiesto dal committente: «e le carte e i tarocchi? Si vedono?»)

Sull'app sì, e dal 0.1.59 sono **la carta stampata** (D-101): il corpo della
carta in mano e' la faccia dei fogli da fustellare, rasterizzata da
`card_art.gd`. Sul telefono **no**: la mano era una fila di etichette. Il
principio era rispettato ovunque tranne che nel posto che conta di piu' — il
telefono *e'* la mano del giocatore, e gli davamo l'elenco della spesa mentre
le facce vere stavano sullo schermo grande, che non e' suo.

L'host adesso serve `/carta/<mazzo>/<id>.svg` da `PrintSheet.card_svg`: **la
stessa funzione** che impagina la fustella e che l'app rasterizza. Nessuna
immagine da impacchettare, nessuna faccia disegnata due volte, e una carta che
cambia nei dati cambia in tutti e tre i posti insieme. Sul telefono la mano
sono carte da toccare (un tocco le ingrandisce: a mano piena una carta larga
un pollice non si legge), sulla vetrina compaiono le carte del Narratore che il
mondo ha calato — pubbliche, e da bordo tavolo la cosa piu' bella da vedere.

Nessun token sull'endpoint, e la ragione e' la stessa di D-135: le facce non
sono segrete. Le carte esistono in copie e il titolo non e' mai stato un
segreto; il segreto e' *quali copie tieni in mano*, e quello vive nello `state`,
che il token lo chiede eccome.

### La fuga che le facce hanno reso visibile

Mettendo le facce sulla vetrina ne sono comparse **sei**, e il verbale sotto
diceva: «Re Aldric riceve 2 carte del Narratore. Popolo Nahr riceve 2 carte.
Lyra riceve 2 carte». Sei. Erano le mani di tutti.

`echo_deck.drawn` non e' la pila delle carte calate: e' **tutto cio' che il
mazzo ha lasciato**, e `_deal_narrator_hands` pesca da li' per riempire le mani
a inizio Atto. La vetrina lo leggeva tale e quale e lo chiamava «il mondo ha
calato». **La fuga esiste da 0.1.99**, da quando esiste la vetrina; le facce non
l'hanno creata, l'hanno solo resa impossibile da non vedere — sei titoli in
corpo minore sotto una riga passavano, sei carte disegnate no.

Perche' nessuna misura l'aveva presa, ed e' la parte che vale:

- `Protocol.audit` perquisisce i messaggi diretti a una **console**, che hanno
  un viewer e quindi un metro. La vetrina non ha viewer — e' pubblica per
  costruzione — e proprio per questo **nessuno le aveva mai chiesto conto di
  niente**. Il pezzo senza segreti era il pezzo senza guardia.
- `test_the_table_model_carries_no_seat_secrets` cercava i titoli degli
  **Asset** e le etichette dei Destini. Le carte di Propp sono un altro mazzo,
  e nessuno lo aveva aggiunto alla lista.

Adesso: `echoes_played` e' «uscita dal mazzo e non piu' in nessuna mano»
(oggi una carta lascia la mano solo per essere calata, e il commento dice dove
andra' aggiornato se un domani ci fosse un altro modo di perderla);
`Protocol.audit_table` perquisisce la vetrina col metro del tavolo — quello che
sta in una mano non e' roba del tavolo, di nessun seggio, mai — e gira nella
sonda dei messaggi accanto alle console; e due test nuovi, di cui **uno pianta
una fuga apposta** per provare che la guardia morda: una guardia che non ha mai
detto di no non si sa se funziona.

**E la lezione di D-135 l'ho dovuta imparare due volte.** La prima stesura di
`audit_table` cercava anche i titoli degli Asset nel testo, e ha consegnato
**54 fughe tutte false**: «la vetrina nomina "Sale", che e' in mano a Kessa».
«Sale» e' una carta e insieme una casa — la Gilda del Sale di CHR_03 — e un
titolo di una parola vive dentro la prosa di mezzo mondo. Esattamente le 658
fughe false di D-135, tre versioni dopo. Il text-scan e' andato via; resta il
confronto strutturale, che e' l'unico che sappia distinguere una carta da una
parola.

Misure: sonda dei messaggi **20.844 perquisiti** (17.509 console + 3.335
vetrine), **FUGHE 0**; filo ancora **trasparente byte per byte**; playtest
**FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto **0/8**; suite
**296/6121** verde; sims ed export deterministici; 22 documenti validi.

---

## D-143 — Guardare il telefono, e trovarci il terminale
**implemented in 0.1.105** (chiesto dal committente: «puoi farmi uno screenshot di quello che si vede sugli smartphone?»)

Fino a qui la console era **misurata** ma non **guardata**: la sonda delle
viste perquisiva i modelli, la sonda dei messaggi contava le fughe, il filo era
trasparente byte per byte — e nessuno aveva mai visto la pagina su uno schermo
da telefono. Una domanda del committente e uno screenshot hanno consegnato due
difetti che nessuna delle tre misure poteva prendere, perche' tutte e tre
guardavano il *contenuto* e nessuna la *forma*.

**Come si fotografa un telefono senza avere un telefono.** Serviva un browser
vero contro l'host vero, non un mockup: quindi `cli/run_room.gd`, la stanza
senza schermo — stesso `ConsoleHost`, stesso `SeatDecider`, stampa un indirizzo
per seggio e aspetta — e un browser headless con lo schermo di un iPhone che
apre l'indirizzo, aspetta la domanda e scatta. Vale oltre lo screenshot: da
adesso si puo' provare la console da un altro apparecchio senza aprire una
finestra.

**Primo difetto: il pannello del terminale finiva sul telefono.** Il decider
dice `_say(_board(...))` prima di ogni azione — il tabellone a caratteri, con
`+-- ATTO 1, ROUND 1 ------------` e i campi separati da `|`. Al terminale
serve; alla console **no**, perche' lei riceve gia' lo `state` strutturato
(D-134) e ne disegna sezioni vere. Il risultato era la stessa cosa detta due
volte, la seconda peggio, in cima allo schermo piu' piccolo che abbiamo: il
primo schermo intero occupato da un dump ridondante, ripetuto a ogni mossa,
mentre le sezioni utili stavano sotto la piega.

La correzione e' un contratto di una riga invece di un `if` sul tipo: l'io puo'
dichiarare `shows_state()`, e chi lo dichiara non riceve il pannello a
caratteri. `ConsoleIO` lo dichiara; terminale e schermo del tavolo tacciono, e
il silenzio e' la risposta giusta per loro. **3.600 messaggi in meno su 100
partite** (17.509 contro 21.109): il traffico che non parte e' anche traffico
che non puo' sfuggire.

**Secondo difetto: le scelte oltre il bordo.** Le opzioni stanno in un riquadro
fisso in basso alto al massimo 62vh che scorre per conto suo. Funziona — ma con
**ventidue** azioni legali il dito che arriva in fondo continua a scorrere la
pagina sotto, e sembra che le opzioni siano finite. Adesso: `overscroll-behavior:
contain` perche' lo scorrimento resti dentro il riquadro, due ombre in CSS puro
(`background-attachment: local` scorre col contenuto e copre l'ombra al bordo —
compaiono e spariscono da sole, senza JavaScript), e una riga che conta ad alta
voce: «22 scelte — scorri per vederle tutte».

**E una cosa vista e non toccata**: ventidue opzioni per un'azione *sono* tante,
su qualunque schermo. Ma quella e' una domanda di design del gioco — quante
azioni offrire — non un difetto della pagina, e si decide al tavolo, non qui.

La sonda dei messaggi e' stata **riallineata** nello stesso commit: il suo io
finto ora dichiara `shows_state()` come la console vera, altrimenti
continuerebbe a perquisire messaggi che non partono piu'. Una misura che conta
cose immaginarie e' peggio di nessuna misura.

Misure: filo ancora **trasparente byte per byte**; sonda dei messaggi
**17.509 messaggi, FUGHE 0**; playtest **FAIL 185 · SUCC 76 · SUCC 123 ·
DECI 178**, tavolo misto **0/8**; suite 294/6117 verde. Gli screenshot del
prima e del dopo stanno in `docs/img/`, e sono il primo pezzo di questo
progetto misurato con un occhio invece che con un numero.

---

## D-141 — L'app da scaricare, e le pagine che non erano risorse
**implemented in 0.1.104** (chiesto dal committente: «l'app Godot e' pronta da scaricare per il computer?»)

No, non lo era: `export_presets.cfg` aveva un preset solo, **Web**. E il web
non puo' ospitare la stanza — una pagina in un browser non apre porte in
ascolto — quindi chi fa da host aveva come unica strada scaricare Godot e
aprire il progetto. Per un committente che sta per sedersi al tavolo con
iPad e telefoni, quella non e' una strada: e' un ostacolo.

Adesso c'e' il preset **macOS** (il computer del committente, chiesto prima di
costruire) e il lavoro `desktop` in CI che allega `ECHOES.zip` a ogni run.
Windows e Linux non sono fatti — un preset per uno, quando serviranno — e
questo si dichiara invece di lasciarlo intendere.

**La cosa che si sarebbe scoperta al tavolo.** `export_filter="all_resources"`
impacchetta le risorse che Godot *importa*: `console.html` e `tavolo.html` non
lo sono. L'app si sarebbe costruita benissimo, avviata benissimo, aperta la
stanza benissimo — e avrebbe servito una **pagina vuota** ai telefoni, con
quattro persone sedute e il QR gia' inquadrato. Il preset le include per nome
(`include_filter="web/*"`), e la CI non si fida del preset: apre il pacchetto,
trova il `.pck` e cerca i due nomi dentro. Se un domani qualcuno rinomina la
cartella, il lavoro diventa rosso prima della serata, non durante.

E' la stessa forma di D-140 e di D-137: il difetto che non si vede guardando —
un bottone dietro un `return`, un QR che sembra un quadrato, un'app che si apre
e non serve niente — vuole un lettore che non si stanca, non un occhio piu'
attento.

**Una cicatrice, dal primo giro rosso.** Godot rifiuta di esportare un binario
universale o arm64 se l'import **ETC2 ASTC** e' spento: su Apple Silicon la GPU
vuole quel formato, e la verifica arriva prima ancora di scrivere un byte
(«Cannot export for universal or arm64 if ETC2 ASTC texture format is
disabled»). Acceso in `project.godot`. Costa qualche versione compressa in piu'
delle sei tessere in fase di import, e **non** tocca l'export web: le due
compressioni VRAM del preset Web restano spente, quindi la pagina non ingrassa
di un byte. Val la pena notarlo perche' e' il genere di vincolo che si scopre
solo costruendo davvero — l'unica ragione per cui il lavoro `desktop` esiste in
CI invece di essere un preset scritto e mai eseguito.

**Non firmata**, e il costo si dichiara: firmare e notarizzare richiede un
certificato Apple che il progetto non ha, quindi al primo avvio macOS la mette
in quarantena. Le istruzioni della prova danno il comando che funziona sempre
(`xattr -dr com.apple.quarantine`) invece del tasto destro → *Apri*, che su
macOS recenti non basta piu'.

Misure: preset e pacchetto verificati dalla CI (le due pagine trovate dentro il
`.pck`); suite 294/6117 verde, playtest invariato — l'export non tocca il
motore, e il verbale lo dice invece di ometterlo.

---

## D-140 — Il bottone che viveva dietro un `return`
**implemented in 0.1.103** (trovato dal committente: «le azioni nell'interfaccia non si vedevano piu'»)

La stanza si apriva, mostrava gli indirizzi e i QR, e **non aveva piu' il
bottone «Si comincia»**. Non un errore, non un test rosso, nessun avviso: in
0.1.100, estraendo `_qr_for` per il QR, il blocco che costruiva il bottone e'
finito *dopo* il `return` della funzione nuova. GDScript non ha detto niente,
perche' per GDScript non c'e' niente da dire: quel codice e' legale, e' solo
irraggiungibile.

Vale la pena guardare in faccia perche' nessuna misura l'ha preso. La suite
prova quello che il codice **fa**: 294 test, 6117 asserzioni, tutti verdi
mentre la stanza era inutilizzabile. Il playtest gira headless e non passa
mai per una lobby. La sonda delle viste perquisisce i *modelli*, non i figli
di un contenitore. Erano tutte misure giuste che guardavano altrove — e la
riga morta non era in una funzione dimenticata, era la penultima cosa che
serviva per giocare.

Il rimedio non e' un test in piu' sulla stanza (l'avrebbe presa questa volta,
e non la prossima): e' `tools/dead_code.py`, che legge tutto il GDScript e
segnala ogni istruzione che segue un `return`/`continue`/`break` allo stesso
rientro. Gira nella CI accanto ai validatori. La prima stesura ha consegnato
**76 fughe, tutte false**: un `return` con l'espressione su piu' righe ha la
graffa di chiusura allo stesso rientro del `return` stesso. Insegnargli a
contare le parentesi (saltando stringhe e commenti) ha portato il conto a
**zero su 139 file**, e rimettendo il file rotto la riga la trova, unica, con
numero e testo.

Da qui in avanti: quello che l'occhio non vede su una schermata, lo vede un
lettore che non si stanca. E' la stessa lezione del QR (D-137) — un codice
sbagliato non sembra sbagliato, sembra un quadrato — applicata al codice
invece che ai moduli.

Misure: suite 294/6117 verde, playtest FAIL 185 · SUCC 76 · SUCC 123 ·
DECI 178, tavolo misto 0/8 (invariato: il difetto era nella lobby, non nel
motore); 22 documenti validi; `dead_code.py` verde su 139 file.

---

## D-139 — Il peso dell'alleanza al Consiglio
**implemented in 0.1.102** (chiesto dal committente: «le alleanze dovrebbero pesare e influenzare di piu'»)

Le relazioni fra entita' esistevano e servivano a molto — chi puo' proporre
insieme a chi, chi eredita, cosa dicono i segni, come si sciolgono i patti —
ma **nel momento in cui si vota non contavano nulla**: al Consiglio un
alleato giurato e uno sconosciuto avevano la stessa voce. Adesso no: chi
sostiene il proponente e gli e' legato porta un peso in piu' sul fronte,
firmato a verbale («Kessa parla da alleato (+1)»), e la regola sta nella
Chronicle (`confluence_rules.alliance_weight`), non nel codice.

La forma: **un passo per grado sopra NEUTRAL** (ALLY +1, BOUND +2), **tetto a
2 per seggio**, **e almeno due carte impegnate**. Il tetto perche' senza, due
legami stretti deciderebbero il Consiglio da soli e il tavolo diventerebbe una
questione di amicizie invece che di carte. Le carte perche' un'alleanza che
aiuta senza costare e' un bonus passivo — si eredita a inizio partita e si
incassa — mentre un'alleanza che chiede di metterci del proprio e' una scelta
al tavolo, e quella scelta e' il gioco.

**Tre forme scritte, misurate, e due scartate.** Vale la pena registrarle,
perche' la seconda e la terza sembrano identiche a leggerle:

| forma | FAIL | tavolo misto |
|---|---|---|
| simmetrica (l'alleato spinge, il nemico frena) | 210 | **1/8 bloccato** |
| solo il legame caldo, gratis | 187 | **1/8 bloccato** |
| solo il legame caldo, e si paga (2 carte) | 185 | 0/8 |

La prima sembrava la piu' onesta — se l'amicizia pesa, l'inimicizia pesa —
e la misura ha detto il contrario, per una ragione che si vede solo guardando
il tavolo di partenza: **CHR_01 ha ostilita' e non ha alleanze**. Un dente
simmetrico su un mondo asimmetrico pesa da un lato solo; in pratica avevamo
aggiunto un moltiplicatore all'Oppose, cioe' esattamente la strategia che
D-098 aveva passato mesi a smontare. Venticinque fallimenti in piu' su 100
semi, e un seggio che non usciva piu' dal suo livello.

La seconda ha rimesso i fallimenti quasi in banda ma ha lasciato **Kessa dei
Fuochi bloccata per un solo tiro** (`1 44 5 0` invece di `1 45 4 0`): un
bonus che arriva senza essere chiesto sposta *tutte* le partite di un
pelo, e da qualche parte quel pelo cade dalla parte sbagliata. Chiedere due
carte non ha ammorbidito il dente, l'ha reso **raro e voluto**: pesa quando
qualcuno ha deciso di far pesare la sua alleanza, non ogni volta che il tavolo
capita di essere amico.

Un effetto collaterale che val la pena dire: questa e' la seconda cosa —
dopo le promesse di D-051 — che rende il FORGE verso l'alto una mossa da
Opportunita' d'azione e non un gesto di cortesia. Un'alleanza adesso e' una
voce in piu' al Consiglio, se sei disposto a pagarla.

Reversibile: si toglie `alliance_weight` dalla Chronicle e i legami tornano a
non toccare il voto. Le quattro Chronicle la portano con gli stessi numeri;
una Chronicle futura puo' avere un Consiglio dove i legami pesano di piu' (o
per niente) senza toccare una riga di codice.

Misure: playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto
**0/8** (uniforme 3/8, invariato); ere CHR_01 955 anni / 20,2 generazioni /
24 nomi e CHR_03 1049 / 16,5 / 20 — identiche alla baseline: il dente tocca
chi vince un Consiglio, non quanto dura una saga. Suite 294/6117 verde,
sims ed export deterministici, 22 documenti validi.

---

## D-138 — Pedine e vessilli: i pezzi, non i cerchietti
**implemented in 0.1.101** (chiesto dal committente: «sulla mappa vorrei token e pedine vere, no cerchietti»)

La presenza si disegnava come un tondo colorato con l'iniziale dentro, e il
controllo come un anello sottile attorno alla Regione. Funzionava e non
sembrava un gioco da tavolo: un tondo dice «qualcuno e' qui», una pedina
dice *chi*, e si conta con la coda dell'occhio come si contano i pezzi veri.

Due segni nuovi nel set delle icone — **`pawn`** (testa, corpo, base) e
**`banner`** (asta e drappo) — e la ragione per cui stanno *li* e non
disegnati a mano nella vista: le icone sono **dati** (D-058), e per D-097 il
pezzo sullo schermo e quello che esce dalla fustella devono essere lo stesso
pezzo. Adesso lo sono davvero: `map_view` dipinge la sagoma col profilo della
casa, la sua ombra sul terreno e il contorno scuro che la tiene leggibile su
un fondo chiaro o scuro; `token_sheet` mette la **stessa** sagoma dentro il
tondo da 15 mm della fustella e il vessillo dentro l'anello del controllo.
L'iniziale resta sul cartone, perche' una fustella stampata in grigio non ha
il colore per distinguere le case.

Il controllo guadagna anche il suo vessillo piantato sul bordo della Regione:
non e' una presenza — non si conta, si pianta — e chi guarda da bordo tavolo
vede di chi e' il posto senza dover leggere il colore di un anello sottile.

Un difetto di misura scoperto strada facendo: il test del foglio contava i
`<circle>` per contare i segnalini. Da quando dentro il tondo c'e' una pedina,
contare i cerchi conta anche le teste. I contorni da punzonare adesso si
dichiarano (`class="pezzo"`) e il test conta quelli: il foglio e' un piano di
fustella e ora lo dice.

Misure: suite 294/6117 verde, export deterministico byte per byte, playtest
identico (0/8). Resta fuori, come sempre: l'illustrazione vera delle case e'
lavoro di chi disegna (voce 5) — questi sono segni, e i segni li fa il gioco.

---

## D-137 — Il QR della stanza, e i due oracoli che non erano d'accordo
**implemented in 0.1.100** (voce 27, la B della seduta: «QR + token» — l'ultima promessa aperta della fase 3)

Il codice si inquadra invece di digitarlo: la stanza disegna un QR per ogni
seggio (col suo indirizzo e il suo token) e uno per la vetrina. Encoder
scritto a mano — modo byte, correzione M, versioni 1-4 — perché il progetto
non tira dipendenze per una schermata.

Il punto della decisione non è il QR: è **come si verifica una cosa che non
si vede a occhio**. Un codice sbagliato non sembra sbagliato; sembra un
quadrato. Si scopre quando quattro persone sono sedute e nessuna riesce a
entrare. Quindi l'encoder ha il suo oracolo: `tools/gen_qr_fixture.py`
genera le matrici attese con un'implementazione che non è la mia e le
congela in `tests/fixtures/qr_golden.json`; il test le confronta **modulo
per modulo, per tutte e otto le maschere** — separare le maschere separa i
due difetti possibili (i dati piazzati male, la maschera scelta male).

Il confronto ha trovato tre difetti veri, nessuno dei quali si sarebbe
visto guardando lo schermo:

- **I bit di formato**: le due copie erano scambiate e indicizzate al
  contrario. Le posizioni sono ora elencate una per una, ricavate
  dall'oracolo — non si tengono a memoria.
- **La correzione d'errore**: il polinomio generatore era costruito con le
  potenze invertite rispetto a come la divisione lo legge. Produceva una
  parità plausibile e sbagliata.
- **Il riempimento**: i codeword di riempimento si alternano da `0xEC`
  contati dall'inizio del riempimento, non dalla posizione nel messaggio.
  Con la parità della posizione la versione 1 tornava **per caso** e la 3
  no — il difetto peggiore, quello che un solo esempio avrebbe assolto.

**Gli oracoli interrogati sono stati due, e non erano d'accordo**: `segno`
aggiunge sempre un byte di zeri dopo il terminatore anche quando il flusso
è già allineato; lo standard (ISO/IEC 18004 §7.4.10) dice di riempire *solo*
se non lo è, e `qrcode` fa così. Entrambi i QR si leggono — la differenza
vive nella zona di riempimento, che un lettore scarta — ma un confronto
vuole un riferimento solo, e si è scelto quello conforme.

E una cosa si è imparata a non pretendere: **quale** maschera sia la
migliore non è un invariante fra implementazioni. Sullo stesso indirizzo
`qrcode` sceglie la 7, `segno` la 1, questo encoder la 2: il punteggio di
penalità è un'euristica e le tre lo pesano diversamente. Il test quindi non
pretende la stessa scelta — pretende che la strada automatica produca *una
delle otto matrici verificate*, che è ciò che deve valere davvero.

Misure: 40 matrici su 40 identiche all'oracolo, 100 asserzioni verdi; suite
294/6064 verde; playtest identico (0/8); il filo ancora trasparente (249
messaggi, vetrina 43 volte, salvataggio e verbale byte per byte). Se un
indirizzo non entra nelle versioni coperte il riquadro resta vuoto e accanto
c'è l'indirizzo scritto: la stanza non dipende dal QR, lo offre.

---

## D-136 — Il telefono vero e la stanza (voce 27, fase 3 + rifiniture)
**implemented in 0.1.99** (per la prova computer + iPad + telefoni; le istruzioni in SEDUTA_TAVOLO §9)

La fase «da toccare»: le pagine, il feed della vetrina, la stanza.

- **`web/console.html`** — il telefono: `http://<ip>:8123/?t=TOKEN`.
  Pannello, mano, la scala del Destino coi gradini, gli avvisi, la
  domanda coi bottoni (compreso «Decidi tu», che rimette la singola
  scelta alla policy). Il token vive in localStorage: la pagina si
  ricollega da sola e la domanda in sospeso viene riproposta. Ping ogni
  8 secondi.
- **`web/tavolo.html`** — la vetrina per l'iPad in Safari (`/tavolo`):
  mappa a schede, domande (le coperte mostrano il dorso), Consigli,
  verbale che scorre. La C della seduta anche sul vetro: il tocco su una
  Regione apre i segni, niente decide. Nessun token: il tavolo è
  pubblico per costruzione (D-134), e `hello {table:true}` riceve il
  `TableModel` a ogni cambiamento del mondo.
- **Il mini HTTP da stanza** (`serve_pages`): serve solo i suoi due
  file, con la porta del filo già scritta dentro; niente filesystem
  esposto.
- **La stanza** (`room_screen.tscn`, dal menu «Apro la stanza — console
  sui telefoni»): sceglie l'anno scritto, mostra per ogni seggio
  l'indirizzo con lo stato e «Rigenera il codice» (il reissue del B); al
  via **chi è collegato gioca dal telefono, gli altri seggi sono
  policy** — la connessione decide, senza altre domande. Durante la
  partita lo schermo è la vetrina con la striscia di diagnosi.
- **La diagnosi onesta della rete** (la rifinitura promessa in §6 del
  dossier): `silence_of` traduce i ping in «la console di X non risponde
  da Ns» sulla striscia della stanza.

Restano dichiarati per dopo la prova: la **console di riserva piena**
(rispondere dallo schermo grande su dichiarazione esplicita, col costo di
segretezza detto ad alta voce), il **QR** al posto dell'indirizzo scritto,
e l'inclusione di `web/` negli export impacchettati (dalla cartella di
progetto funziona già). Misure: la sonda del filo estesa — vetrina
aggiornata 43 volte, pagine servite con la porta giusta, partita ancora
**identica byte per byte**; suite e playtest intatti.

---

## D-135 — Il filo in casa (voce 27, fase 2)
**implemented in 0.1.98** (seduta sul tavolo, risposta D — la fase 2 dopo le viste)

Il trasporto, costruito perché non possa mentire:

- **L'instradamento per seggio** (`ios` nel SeatDecider): ogni ingresso
  pubblico dichiara a chi sta parlando prima di dire o chiedere — l'avviso
  del Destino finisce sul telefono giusto e su nessun altro; `io` resta il
  ripiego condiviso (terminale, hotseat, riserva).
- **Il protocollo** (`state/say/choose/chosen`): l'orologio del mondo su
  ogni messaggio dell'host, l'`ask_id` che scarta le risposte stantie, la
  domanda in sospeso leggibile per il rientro. **La perquisizione è nel
  protocollo** (`audit`), ed è **strutturale** dove deve esserlo: le carte
  esistono in copie e il titolo non è un segreto — la prima forma
  text-scan ha consegnato 658 «fughe» tutte false («Sale» è anche la
  Compagnia, la Carovana scartata a verbale non rivela la copia del
  vicino). Ciò che è segreto è *quali copie hai in mano*: la mano dello
  `state` deve essere esattamente quella del seggio, lo `state` deve
  portare il suo nome, la domanda coperta resta un dorso. I gradini del
  Destino altrui restano text-scan: frasi d'autore, uniche.
- **`ConsoleIO`** — l'io remoto che non sa cosa sia un socket: parla a
  segnali, stato fresco prima di ogni domanda; **`ConsoleHost`** —
  TCPServer+WebSocketPeer, accoppiamento a token (chi inquadra il codice
  di un seggio *è* quel seggio), posta per le console assenti, rientro con
  stato fresco e domanda riproposta.
- **L'io copione** e la console simulata condividono una formula pura —
  e la formula ha la sua cicatrice a verbale: la prima aveva parità
  costante quando il numero di domanda avanza di due, che è il passo del
  ciclo «La fai lo stesso?» — un copione poteva ripensarci per sempre, e
  la sonda ci è rimasta dentro due ore. L'hash a bit alti l'ha guarita,
  e la sonda ora stampa il progresso partita per partita.

Le misure del «fatto quando», entrambe piene: **la sonda del filo** — la
stessa partita senza rete e con due console WebSocket vere su localhost
(249 messaggi, 82 risposte) è **identica byte per byte**, salvataggio e
verbale; **la sonda dei messaggi** — 100 partite a tavolo misto, **21.109
messaggi perquisiti, FUGHE: 0**. Sul filo di ogni console viaggia solo il
suo seggio. Suite 290/5953 verde, playtest identico.

---

## D-134 — Le due viste dallo stesso mondo (voce 27, fase 1)
**implemented in 0.1.97** (seduta sul tavolo: A pagina dall'host, B QR+token, C vetrina+ispezione, D fasi 1→4)

La prima fase della voce 27, senza un centimetro di rete: la vista TAVOLO
e la vista CONSOLE come ricomposizioni dei pezzi che già disegnano per
viewer — e, sotto, i **modelli di vista** che in fase 2 saranno i
messaggi.

- **`TableModel` / `ConsoleModel`** (`scripts/views/`): costruttori puri
  `build(session[, seat])` → dizionario di ciò che quello schermo mostra.
  Il tavolo si costruisce col viewer pubblico (`""`): la Tensione velata
  vale −1 (il dorso), le mani e i Destini non esistono nel dizionario. La
  console porta il pannello, la mano, la scala del Destino coi gradini
  spuntati, i rapporti, i segni, i Diritti (pubblici, col proprio
  evidenziato). **Il filtro sta nella costruzione, non nel trasporto**:
  se un segreto non entra nel modello, non potrà entrare nel filo.
- **`ui/table_view.gd`** — la vetrina: mappa (viewer pubblico), domande,
  Consigli dell'anno, carte del mondo, coda del verbale (pubblico per
  contratto: `game_log.gd` lo dichiara dalla nascita, i segreti passano
  da `io.say`). La **C della seduta** è già dentro: il click su una
  Regione apre il dettaglio *pubblico* (l'ispezione) — tocchi che
  guardano, mai che decidono.
- **`ui/console_view.gd`** — il telefono di un seggio: `render(session,
  seat)` più `say(text)`, la metà passiva dell'`io` di D-038 — gli
  avvisi del decider si mostrano lì e non toccano il verbale comune. Il
  `choose` arriverà col filo (fase 2).
- **`ui/dev_split.tscn`** — il cavalletto: una Chronicle giocata in
  automatico e le due viste affiancate
  (`godot --path godot res://ui/dev_split.tscn`).
- **La sonda delle viste** (`test_views`, 5 test): la domanda coperta
  mostra il dorso al tavolo anche se un seggio l'ha sbirciata (e il
  numero vive solo sulla console di chi sa); il modello del tavolo,
  serializzato e perquisito, non contiene nessuna carta di nessuna mano
  né un gradino di Destino; la console contiene i segreti del suo seggio
  e nessuno di quelli altrui; i modelli sono di sola lettura; le due
  viste compilano e si disegnano.

Il «fatto quando» della fase 1 regge: la sonda passa su entrambe le
viste, la lente della UI (D-050) non trova nomi di seggio nei file
nuovi, il playtest è identico byte per byte (185·78·123·176, 0/8) —
le viste guardano il mondo, non lo muovono. Suite 286/5923 verde.

---

## D-133 — La Leggenda della Montagna: il seggio senza corpo
**implemented in 0.1.96** (seduta sulla Leggenda, risposte A «va bene» e C «proviamo» — la voce 19 si chiude)

La vita più radicale delle diciassette dell'albero: il drago che il sigillo
ha tenuto sotto così a lungo da diventare la storia che si racconta di lui.
Quarta vita di `ENT_VAERAX` (`INC_VAERAX_LEGEND`, COLLECTIVE), e la prima
del gioco **senza un solo segnalino sulla mappa**.

I pezzi, dal verbale della seduta:

- **Il conto delle ere nei segni** (risposta A — `era_tallies` sulla
  Chronicle, applicato da `inheritance_effects`): a ogni successione, se
  `mine_sealed` sta sui fatti dell'era chiusa e `crystal_exploited` no, il
  mondo posa il prossimo segno della catena `seal_kept` →
  `seal_kept_twice` → `mountain_forgotten`; la condizione caduta azzera
  tutto senza lasciare leggende (un conteggio interrotto non è una
  memoria). Come per la Diaspora: segni, non contatori.
- **L'ingresso**: ON_TAG `mountain_forgotten`, sbarrato da
  `crystal_exploited` — ma solo dal *fatto vivo*: il Cristallo non è
  perenne, e sui salti lunghi sbiadisce in `legend:crystal_exploited`.
  È la strada che rende la vita raggiungibile: **anche il Ridestato,
  richiuso e dimenticato nei secoli, torna racconto** (l'ordine d'autore
  protegge il corpo: col fatto vivo siede il Ridestato, mai la storia).
- **Il seggio senza corpo**: la vita dichiara `presence: []` (campo nuovo
  per incarnazione; `setup_effects` ora legge la vita corrente) — nessuna
  pedina al setup, quindi niente da cacciare e niente porte che la
  tengano. Il MOVE è vietato dichiarato (`TGR_LEGEND_STILL`, ACTION_GATE:
  l'app lo mostra grigio invece di lasciarlo fallire).
- **Il Destino su misura** (risposta C — `destiny_id`/`destiny_pool` per
  vita, nuova estensione di `active_view` e del piano di successione):
  `DST_VAERAX_LEGEND`, senza clausole di presenza. Minimo «La storia si
  racconta ancora» (il segno `mountain_forgotten` regge — si perde se il
  sigillo cade); Vittoria «La montagna tiene lontani gli uomini»
  (sigillo + Risveglio quieto); Trionfo «Nessuno ricorda com'era davvero»
  (più `legend:crystal_exploited`: il giorno del Cristallo ormai solo un
  racconto).
- **La voce sui fronti** (`TGR_LEGEND_VOICE`, STANCE_MODIFIER composito):
  finché il mondo dimentica, i fronti che sostiene pesano un impegno in
  più. Se il sigillo cade, il segno sparisce e la voce torna una voce.
- La guardia dei Destini irraggiungibili ora conosce **le due mani del
  motore**: i conti d'era scrivono le loro catene, e il tempo scrive
  `legend:<fatto>` per ogni fatto che almeno una Chronicle non dichiara
  perenne.

Misurato (20 saghe CHR_01→CHR_02): **la Leggenda siede 3 volte** — rara
come deve (tre ere col sigillo e il Cristallo sbiadito) — il Ridestato
scende 20 → 18, e i NONE di Vaerax salgono 9 → 16: il Minimo della storia
si perde davvero, la vita non è un rifugio. Banda identica (955 / 20,2 /
24 nomi — il ventiquattresimo è lei). Playtest 100 semi identico
(185·78·123·176, 0/8), sims deterministici, censimento 0/0, BRIEF_ARTE e
ASSET_MANIFEST rigenerati (arte della vita e del Destino), suite 281/5865
verde.

---

## D-132 — La montagna delle città: le porte d'ingresso si aprono
**implemented in 0.1.95** (seduta sulla Leggenda, risposta B — «prima la B», D del verbale)

La sonda d'era sul tavolo delle città (prima misura in SEDUTA_LEGGENDA §2)
aveva trovato il buco: `scar:open_wound` e `scar:emptied` le scriveva solo
il contenuto di CHR_01, e i Forni Riaccesi e l'Egemonia di Eredan — scritti
e testati in D-129/D-131 — non sedevano mai nelle loro saghe (0/20,
contenuto che non esiste, D-035). Due Conseguenze nuove nel mazzo delle
città, nessun motore toccato:

- **La Roccia che Cede** (`CNS_MOUNTAIN_WOUNDED`), sul successo di
  `P_DIG_BELOW` («sotto la cella si continui a scavare»): la ferita
  (`scar:open_wound`) sulle Miniere Antiche, più `condition:exploited` —
  la stessa coppia che CHR_01 usa per la Miniera Aperta.
- **La Valle che si Vuota** (`CNS_VALLEY_DRAINED`), sul fallimento della
  domanda dell'Acqua (`CNF_WATER_03`): lo sgombero (`scar:emptied`) sulla
  Valle Verde, più `condition:lean` — l'acqua che non arriva svuota le
  case prima del secondo inverno.

Misurato sulla sonda delle città (20 saghe): **i Forni siedono 5 volte**
(rari come devono: ferita + linea esaurita + niente sigillo),
**l'Egemonia 11** (le Custodi scendono 20 → 15: i Forni rubano loro le
entrate giuste), NONE per seggio tutti vivi (Cenere 8, Libere 27, Sale
28, Vetro 53), banda identica (1049 mediana, 16,5 generazioni, 20 nomi —
i due nuovi sono le vite). Se in futuro l'Egemonia sembrasse troppo
frequente, la manopola dichiarata è spostare lo sgombero dal pool di
fallimento a una proposizione singola. Playtest 100 semi coi totali
identici alla baseline (185·78·123·176, 0/8), sims deterministici,
censimento 0/0 (segni e cicatrici tutti già dichiarati), brief invariato,
suite 278/5832 verde.

---

## D-131 — L'Egemonia di Eredan: il segno qualificato, lo sconto sul diritto, il tetto verso di lei
**implemented in 0.1.94** (ISSUES 19, decisione C della seduta — la terza vita, la C si chiude; resta la Leggenda della Montagna in seduta dedicata)

Quando la Valle Verde si svuota e Eredan resta l'ultima città piena, il coro
delle Libere diventa una voce sola: **L'Egemonia di Eredan**
(`INC_LIBERE_HEGEMONY`, COLLECTIVE, terza vita del seggio). Il dossier
diceva «una sola città piena»; con due città scritte la forma concreta è
questa — lo sgombero della Valle senza lo sgombero di Eredan — ed è una
scelta d'autore messa a verbale, non una semplificazione nascosta.

Tre pezzi di motore, tutti piccoli:

- **Il segno qualificato `tag@REG_ID`** (`Succession._sign_anywhere`):
  l'ingresso di una vita può chiedere il segno su UNA Regione precisa.
  `entry_tag: scar:emptied@REG_VALLE_VERDE` +
  `entry_forbidden_tag: scar:emptied@REG_EREDAN` — uno sgombero qualsiasi
  in giro per il mondo non fa un'egemonia (test `elsewhere`), e con
  Eredan svuotata a sua volta non resta nessuno che comandi (test `ruins`).
- **ACTION_DISCOUNT** (`TagRules.action_discount` + check/execute del
  CLAIM): chi porta il segno compie l'azione senza scartare la carta che
  l'azione chiede. `TGR_HEGEMONY_WORD`: rivendicare e forzare il Consiglio
  non costano l'Asset AUTHORITY — la parola dell'ultima città piena è già
  autorità. Lo sconto si nomina a verbale («rivendica il dominio per
  parola propria»): un diritto gratis è un fatto del tavolo, non un
  silenzio.
- **Il gancio ENTITY sulla coppia** (`_sign_present`, ganci di relazione):
  nei contesti di relazione il `when` con scope ENTITY morde se UN membro
  della coppia porta il segno. `TGR_HEGEMONY_UNLOVED` (RELATION_CAP ALLY):
  con l'egemone ci si allea, non ci si lega — e solo le coppie di cui è
  membro hanno il tetto (test sulla coppia terza). Il validatore ora
  accetta ENTITY su RELATION_CAP/FLOOR e pretende i campi di
  ACTION_RIPPLE/ACTION_DISCOUNT.

**Condizionale dichiarata (D-035)**: la vita entra solo dai salti d'era
della terza cronaca, e le sonde correnti (playtest a anno singolo, saghe
CHR_01→CHR_02) non la fanno sedere — il playtest è identico alla baseline
(185·78·123·176, 0/8), la banda delle ere identica (955 / 20,2 / 23), la
sonda delle scelte invariata. I denti sono inchiodati dai test del telaio
(sconto senza carta e a verbale, tetto sulla coppia giusta e non sulle
altre, ingresso qualificato nei tre casi); la misura *in saga* arriverà con
una sonda d'era sulla terza cronaca, da scrivere quando la Leggenda della
Montagna porterà comunque la seduta sul mazzo di CHR_03. Due regole in più
(41→43), censimento 0/0, sims deterministici, BRIEF_ARTE rigenerato con
`entity.libere_hegemony`, suite 278/5832 verde.

---

## D-130 — La Diaspora di Nahr: il conto delle cacciate, e la porta che non tiene
**implemented in 0.1.93** (ISSUES 19, decisione C della seduta — la seconda delle tre vite)

Il popolo che il tavolo caccia due volte nello stesso anno smette di avere
un centro — e diventa impossibile da chiudere fuori. **La Diaspora di Nahr**
(`INC_NAHR_DIASPORA`, COLLECTIVE, terza vita del seggio) entra alla
successione col segno `twice_uprooted` addosso; il Regno, che viene prima
in ordine d'autore, vince se il popolo si è anche seduto.

Tre pezzi:

- **Il conto delle cacciate** (`_bar_return`): ogni sradicamento vero — le
  espulsioni dei Consigli e le Conseguenze che svuotano (la Valle
  Sgomberata), tutte passano di lì — scrive sul seggio `uprooted` la prima
  volta e `twice_uprooted` la seconda, con una riga a verbale («Due volte
  sradicato in un anno»). I tag d'entità non si ereditano fra le ere:
  il conto riparte da solo a ogni Chronicle, che è esattamente il «nell'era
  appena chiusa» del dossier — nessun contatore, solo segni.
- **La porta che non tiene** (`passes_eviction`, schema + `TagRules.
  eviction_pass` + `can_move_to`): il PASS di D-125 lasciava la cacciata
  di D-067 più forte «finché una vita non decida altrimenti» — la Diaspora
  è quella vita. `TGR_DIASPORA_ROOTLESS` (GATE PASS con `passes_eviction`)
  le fa attraversare anche la porta del Consiglio; il rientro costa
  comunque la MOVE del round dopo. Il validatore ora conosce il PASS
  (scope ENTITY/GLOBAL) — D-125 l'aveva costruito solo nel telaio.
- **La sentinella nella sonda delle ere**: il rischio dichiarato a dossier
  è che Nahr diventi imperdibile. La sonda ora stampa le vite mutate che
  siedono e i NONE per seggio attraverso le ere. Misurato: la Diaspora
  siede **2 volte in 20 saghe** (rara come deve: due cacciate nello stesso
  anno), e il NONE di Nahr resta vivo — **33 su 200 anni giocati**, la
  leva di D-067 morde ancora dove la Diaspora non è al tavolo (la sonda
  delle espulsioni conferma: seme 7020, Nahr NONE da cacciata sul Minimo).

Misure: playtest 100 semi identico alla baseline (185·78·123·176, 0/8 al
tavolo misto — i segni del conto non muovono nulla dentro l'anno), banda
delle ere in banda (955 mediana, 20,2 generazioni, 23 nomi — il
ventitreesimo è la Diaspora), sims deterministici, censimento 0/0,
BRIEF_ARTE rigenerato con `entity.nahr_diaspora`, suite 275/5817 verde.

---

## D-129 — I Forni Riaccesi: il segno che sceglie, il sigillo che sbarra, l'azione che sfoga
**implemented in 0.1.92** (ISSUES 19, decisione C della seduta — la prima delle tre vite da scrivere, via libera del committente a verbale in SEDUTA_VITE §4)

La terza cronaca aveva per Cenere una sola vita di ripiego (le Custodi):
esaurita la linea dei Fuochi, sedeva sempre la stessa storia. Adesso fra i
Fuochi e le Custodi sta **I Forni Riaccesi** (`INC_CENERE_FURNACES`,
COLLECTIVE): l'industria che nasce solo se la storia giocata ha lasciato il
suo segno.

Tre pezzi di motore, due nuovi e uno esteso:

- **`entry_forbidden_tag`** (schema entity + `Succession._next_life`): un
  segno può anche *sbarrare* una nascita. I Forni chiedono `scar:open_wound`
  (la miniera riaperta è una ferita sul mondo) e sono vietati da
  `structure:sealed` (il sigillo che la chiude). Con la linea esaurita e il
  sigillo posato, siedono le Custodi come sempre: il segno sceglie *quale*
  vita, non *se* — una dinastia MORTAL non si interrompe a metà (D-109,
  confermato dal test `midline`).
- **`ACTION_RIPPLE`** (schema tag_rule + `TagRules.action_ripples` +
  post-process in `ActionResolver.execute`): un'azione riuscita può sfogare
  su una Tensione. Il dente della fame dei Forni: ogni FORGE col loro segno
  al tavolo scalda `TEN_WATER` di +1 (`TGR_FURNACE_HUNGER`) — l'industria
  ripara i rapporti bruciando l'acqua di tutti. Lo sfogo si firma a verbale
  («Il segno sfoga: …») e sveglia gli omen, come ogni altro tocco di
  Tensione. `execute()` è stato rifattorizzato (il match assegna l'esito
  invece di uscire per ramo) perché lo sfogo valga per ogni template senza
  otto copie dello stesso codice.
- **`TGR_FURNACE_ORE`** (DRAW_BIAS, pezzo del telaio D-125): con i Forni al
  tavolo *e* la ferita aperta sulla mappa (gancio composito `when_also`),
  pescano WEALTH più spesso — il minerale esce dalla miniera.

Due regole in più (38→40), censimento pulito — e nel ripulire è saltata
fuori una dichiarazione mancata della 0.1.90: `scar:dragonfall` stava in
prima fila senza lettore né dichiarazione. Dichiarata adesso (la mappa
ricorda dove cadde il drago; il dente vivo è la morte del seggio, letta da
ON_DEATH). Misure: playtest 100 semi identico alla baseline (185·78·123·176,
0/8 bloccati al tavolo misto — le vite dormono fuori dai salti d'era, e lo
sfogo è neutro senza il segno), banda delle ere identica (955 mediana, 20,5
generazioni, 22 nomi), sims ed export deterministici, suite 272/5799 verde.

---

## D-128 — I valori per vita sono sapore dichiarato (la D si chiude)
**implemented in 0.1.91** (ISSUES 19, decisione D della seduta — la strada 1 del verbale)

Il ritrovamento è in SEDUTA_VITE.md §4: i valori d'azione oggi non hanno un
lettore — lo schema li dichiara «peso per la policy di default, non un
modificatore della matematica (v0.2)», e la policy a obiettivi di D-021 è
una scala senza pareggi. Il committente ha scelto la **strada 1**: si
dichiarano **sapore di stampa**, allineati ai denti veri che ogni vita ha
(D-124/D-126/D-127), e la D *meccanica* resta a verbale come intenzione per
la 0.4, quando il modello narrativo locale darà loro un lettore vero da
misurare contro baseline nuove.

La tabella per vita esisteva già (D-108 l'aveva scritta bene: il Regno di
Nahr guadagna il CLAIM e smette di camminare, la Repubblica tratta invece
di rivendicare, il Banco trama). Un solo disallineamento vero, corretto: il
**Culto della Misura**, il cui dente è il velo — un'arte dello SCHEME — ma i
cui valori lo davano a 3 dove Lyra stava a 5. Ora SCHEME 4 / INFLUENCE 3, a
somma invariata (±2, mai un profilo strettamente peggiore, come da regola
approvata).

Niente da misurare oltre le guardie: nessuna regola legge questi numeri
(è il punto), l'export resta deterministico, la suite verde.

---

## D-127 — La morte di Vaerax, per via di Propp
**implemented in 0.1.90** (ISSUES 19, decisione B della seduta — «si scrive, e la può proporre qualcuno con carta di Propp»)

Prima di oggi niente nel gioco sapeva uccidere il drago, e il Culto della
Montagna (`ON_DEATH`) era contenuto irraggiungibile. Adesso la strada c'è,
ed è quella chiesta dal committente — **attraverso la carta di Propp**:

- **La caccia** (`P_SLAY_THE_DRAGON`) sta sulla domanda dura del Risveglio
  («A chi appartiene ciò che dorme sotto la montagna?», che si apre solo a
  Risveglio ≥ 6) ed è eleggibile **solo se una Rivelazione è stata compiuta
  quest'anno** (`function:REVELATION`): si caccia solo ciò che una carta ha
  mostrato. E la Rivelazione stessa prescrive il Consiglio sul Risveglio e
  fa proponente chi la cala (D-118) — chi gioca la carta apre la porta e
  può entrarci per primo.
- **La Conseguenza** (`CNS_DRAGON_SLAIN`): il drago si spegne
  (`SET_ENTITY_ACTIVE`, la prima volta che compare nei dati), il Risveglio
  crolla (−6: la domanda muore con lui), il mondo ricorda (`dragon_slain`,
  dichiarato memoria), e la montagna porta la **caduta del drago** —
  cicatrice nuova, con la sua parola.
- **La cicatrice ha il suo lettore dal primo giorno**: il potere del Culto
  (`TGR_MOUNTAIN_MEMORY`) è passato in forma composita — la vita **e**
  `scar:dragonfall` — perché la memoria che arma i fedeli sia esattamente
  la caduta che li ha fatti nascere.
- **Il drago si difende**: il punteggio teme la propria fine (−6, più di
  qualunque clausola) — senza, la caccia sarebbe una passeggiata nelle sim.
  La morte altrui resta zero: non è un obiettivo di nessun Destino.
- **La morte non elimina il giocatore**: alla successione scatta `ON_DEATH`
  (già provato) e chi giocava il drago gioca il Culto.

### Misurato, e la dichiarazione

Tre test nuovi (la porta della Rivelazione che si apre e si chiude,
l'abbattimento con la cicatrice, la paura del drago). La sonda delle scelte
mette la caccia fra le **condizionali dichiarate** — mai eleggibile nelle
100 partite standard, con `P_REOPEN_THE_MINE` e `P_HEIR_AS_STORY`: vuole il
Risveglio quasi a soglia **e** la Rivelazione calata nello stesso anno, ed
è disegno, non difetto — l'uccisione di un dio non capita per caso. Difatti
il playtest è **identico byte per byte** alla 0.1.89, ere in banda, suite
270 test / 5782 asserzioni verde. Al tavolo umano la strada è chiara:
tenere alta la domanda, calare la Rivelazione, proporre la caccia — e
superare il muro del drago.

---

## D-126 — I denti veri sui pezzi nuovi: la Repubblica, il dogma, la firma
**implemented in 0.1.89** (ISSUES 19 — i poteri pieni che aspettavano D-125)

- **La Repubblica della Valle** ha il suo carattere intero: *il consenso
  frena chi propone* (COUNCIL_MODIFIER −1 quando propone) e *il consenso fa
  muro* (STANCE_MODIFIER: la sua opposizione con almeno una carta vale +1).
  Un collegio che dice no è più difficile da scavalcare di un re. La quinta
  seconda vita del 0.1.70 rispetta finalmente la regola della casa.
- **Il Culto della Misura** ha *il dogma che vela* (ACTION_GRANT
  SCHEME_VEIL): può chiudere un numero al tavolo, l'arte che nessun altro
  ha. Le sedie automatiche non la usano — al tavolo umano è un potere che
  si vede, come i divieti di D-117.
- **I Frati del Vetro in forma piena**: la regola come misura vale *dove la
  reliquia è custodita* — segni compositi, la vita **e** `structure:sealed`
  da qualche parte, su **ogni** Consiglio. La forma provvisoria (solo sulla
  Reliquia) è durata una versione, come dichiarato in D-124.
- **La Lega delle Sette piena**: *la firma leggera* (CONDITION_THRESHOLD
  −1) — per lei una Condition qualifica con un impegno in meno, mai sotto
  uno. Sette città hanno già firmato.

**Dichiarati non esprimibili, a verbale**: il «vale doppio» delle Custodi
sulla torre (DRAW_BIAS non somma: guarda due carte comunque) e la paura
piena del Ridestato (un malus sul fronte *altrui* contro un proponente
specifico — il tipo legge chi porta il segno, non i suoi avversari). Se un
giorno serviranno, saranno pezzi loro, non forzature di questi.

### Misurato

Suite 267 test / 5773 asserzioni verde; playtest sui 100 semi **identico
byte per byte** (le vite dormono fuori dalle saghe); ere in banda (mediana
955 anni, 20,5 generazioni, 22 nomi). Con questo, **le nove vite oltre la
fondazione hanno tutte almeno un dente**: la regola della casa — una vita
senza dente non si scrive — vale su tutto l'albero scritto.

---

## D-125 — I pezzi del telaio per le vite: compositi, fronti, velo, passo, soglia
**implemented in 0.1.88** (ISSUES 19, decisione E della seduta — SEDUTA_VITE.md §4)

Il committente ha autorizzato tutti e cinque i pezzi, e sono entrati col
rito di D-116: **il telaio prima dei denti** — ogni gancio provato con
regole sintetiche nei test, e neutro finché nessuna regola vera lo usa.

- **I segni compositi** (`when_also`): una regola può chiedere più segni
  insieme — la vita **e** il fatto del mondo — letti con lo stesso contesto
  del gancio. Tutti i ganci del telaio li capiscono. È il pezzo che
  aspettavano i Frati pieni («+1 dove la reliquia è custodita») e ogni
  potere «vale doppio per lei».
- **STANCE_MODIFIER**: il fronte (`stance`) di chi porta il segno vale
  `stance_delta` in più al Consiglio — ma solo se quel seggio ha impegnato
  almeno una carta sul fronte: un +1 dal nulla sarebbe un voto gratis. Il
  proponente conta sempre come sostegno (chi propone non vota, ma spinge).
  È il pezzo della Repubblica della Valle.
- **Il velo** (`ACTION_GRANT` + SCHEME modo VEIL): l'arte inversa dello
  scouting — chiudere un numero al tavolo. La concede un segno; la
  questione torna velata, chi aveva mandato spie non sa più, chi vela sa
  cosa ha coperto. È il pezzo del Culto della Misura.
- **Il passo** (`GATE` con `movement: PASS`): chi porta il segno attraversa
  i BLOCK delle regole — il confine sigillato, la strada depredata. **La
  cacciata di D-067 resta più forte**, finché la vita che userà questo
  pezzo (la Diaspora) non decida altrimenti, coi numeri accanto. È scritto
  anche nello schema.
- **La soglia della Condition** (`CONDITION_THRESHOLD`): per chi porta il
  segno la Condition qualifica con un impegno in meno (o in più), mai sotto
  1; ogni regola morde una volta per Consiglio, non una per firmatario. È
  il pezzo della Lega delle Sette piena.

Ogni morso si firma a verbale come sempre («Il segno pesa sul fronte: …»,
«Il segno sposta la soglia della Condition: …», «cala il velo»), e il menu
del seggio offre il velo solo a chi lo ha (stessa via di D-038).

### Misurato

Cinque test sintetici nuovi (compositi, fronte, soglia una-volta-per-regola,
il passo che non batte la cacciata, il velo end-to-end). Con **zero regole
vere** dei tipi nuovi: playtest sui 100 semi identico byte per byte alla
0.1.87, suite verde. I denti veri — la Repubblica, il Culto della Misura, i
Frati e le Custodi in forma piena, la Lega piena — sono il prossimo passo,
accesi uno alla volta e misurati.

---

## D-124 — La seduta sulle vite: le decisioni, e i primi tre denti
**implemented in 0.1.87** (ISSUES 19, fasi 4-5 — la seduta è a verbale in [SEDUTA_VITE.md](SEDUTA_VITE.md) §4)

Il committente ha deciso sul dossier ([SEDUTA_VITE.md](SEDUTA_VITE.md)):
**A** i tre denti pronti si accendono, e Repubblica e Culto della Misura
aspettano il potere pieno (niente ponte provvisorio); **B** la morte di
Vaerax si scrive, e la si propone *attraverso* una carta di Propp — la
strada è la Rivelazione, che prescrive il Consiglio sul Risveglio e fa
proponente chi la cala (D-118); **C** le quattro vite nuove rispiegate una
per una (§5 del dossier), decisione rimandata; **D** la regola dei valori
per vita approvata (ridistribuire ±2, mai un profilo strettamente
peggiore); **E** tutti e cinque i pezzi del telaio autorizzati, col rito
di D-116.

### I tre denti (decisione A), in questa versione

- **Il credito federato** (`TGR_SALT_CREDIT`): la Compagnia del Sale pesca
  WEALTH guardando due carte e tenendo la migliore.
- **La regola come misura** (`TGR_FRIARS_MEASURE`): quando i Frati del
  Vetro propongono sulla Reliquia, World Factor +1. La forma piena («dove
  la reliquia è custodita») arriverà coi segni compositi.
- **La veglia arma** (`TGR_ASH_VIGIL`): le Custodi della Cenere pescano
  FORCE meglio.

Le tre seconde vite del 0.1.70 che ancora violavano la regola della casa
(«una vita senza dente non si scrive») adesso la rispettano; restano
Repubblica e Culto della Misura, in attesa dichiarata dei pezzi E.

### Misurato

Accese insieme, con la motivazione a verbale: sono **disgiunte per
costruzione** (ogni regola legge il segno di una vita diversa di una casa
diversa) e **dormienti fuori dalle saghe** — nessuna trasformazione
avviene dentro una Chronicle singola. Difatti: playtest sui 100 semi
**identico byte per byte** alla 0.1.85; ere in banda (mediana 955 anni,
20,5 generazioni, 22 nomi); suite 262 test / 5757 asserzioni verde.

---

## D-123 — L'inventario dell'app: i Diritti, l'eco, i marker, la cronaca
**implemented in 0.1.86** (su richiesta del committente, dall'inventario dell'app)

Il committente ha chiesto cosa manca sullo schermo. L'inventario ha risposto:
le carte ci sono tutte (ma 91 illustrazioni su 98 sono segnaposto — quella è
consegna d'arte, voce 5), i segnalini ci sono; mancavano quattro cose, e sono
entrate:

- **I Diritti si vedono.** Un Claim creato è un fatto pubblico — l'azione si
  annuncia — ma viveva solo nel verbale. Il pannello del seggio ha la sezione
  «I DIRITTI»: chi tiene cosa, col dominio nella sua parola italiana
  (`SignLabels.DOMAIN_WORDS`), il proprio in ambra. Senza Diritti la sezione
  sparisce, come i segni.
- **L'eco del cambiamento.** Al tavolo fisico vedi la mano che sposta il
  pezzo; sullo schermo il pezzo era già spostato. Ora ogni effetto che tocca
  una Regione accende un anello ambra che sfuma in sei secondi — un'evidenza,
  non un'informazione: dice *dove* guardare, il cosa lo dicono verbale e
  segnalini. La mappa dei tipi (`MapView.region_of_effect`) è pura e provata
  in headless; i no-op non accendono niente, per la stessa moneta di D-121.
- **I marker delle domande.** Ogni Tensione pianta il suo marker (il glifo di
  D-058) sulla Regione su cui la sua domanda verte adesso — la stessa regola
  del Consiglio, `focus_region` — con la lettura che spetta a chi guarda: il
  numero se ne ha diritto, il glifo spento e «?» se è velata (§11.1). I
  colori sono quelli del pannello: verde lontana, ambra a un passo, rossa a
  soglia.
- **La cronaca si sfoglia anche a metà anno.** Appena c'è una Truth scritta,
  il bottone si accende e impagina il registro fin qui — le stesse pagine che
  uscirebbero a fine anno, non un'anteprima che gli somiglia.

Solo schermo: nessun file di motore toccato (a `sign_labels` si aggiunge un
dizionario), quindi playtest e sim invariati per costruzione. Suite 262 test /
5757 asserzioni verde, con tre test nuovi (`test_app_inventory`).

---

## D-122 — La cicatrice che morde: il ponte meccanico fra le ere
**implemented in 0.1.85** (ISSUES 24, fase 4 — la voce si chiude)

Il censimento diceva: 11 cicatrici scritte e nessuna letta, i segni ereditati
narrati ma senza dente. Undici regole nuove — tutte coi tipi che il telaio ha
già (D-104/D-116), nessun ramo di motore — e la **memoria dichiarata** per i
segni il cui gemello vivo morde già. Le cicatrici non si curano: quello che
scrivono lo leggono anche le ere dopo, ed è questo il ponte.

### I denti nuovi, accesi a gruppi sugli stessi 100 semi

- **I tre pesi del Consiglio** (COUNCIL_MODIFIER, −1 World Factor finché la
  cicatrice esiste): il ponte rotto pesa sulle Vie, la capitale presa non
  dimentica (Successione), il seggio vuoto pesa sulla Carta.
- **Le tre pesche guaste** (DRAW_BIAS MALUS, per chi ha presenza sulla
  cicatrice): la parola rotta guasta i legami (BONDS), dove la gente fu
  sgomberata le braccia mancano (PEOPLE), nella terra abbandonata la
  ricchezza non attecchisce (WEALTH).
- **Le pesche buone e la porta** (i segni che costruiscono): sotto la torre
  di veglia la forza si trova (FORCE BONUS — lo schizzo di D-116), al
  pedaggio i denari girano, dove sta il mercato la ricchezza gira, e la
  marca tiene il passo aperto (GATE ALLOW: vi si entra anche senza
  adiacenza — la porta concessa dello schizzo di D-104).
- **La ferita che parla** (ACTION_MODIFIER): dove il Cristallo fu sfruttato,
  chi sta sulla ferita pesa +1 sull'INFLUENCE del Risveglio, come il granaio
  parla della fame (D-105).
- **Il pavimento del patto** (RELATION_FLOOR): il censimento ha rivelato che
  `PACT` è un tag di **relazione** (lo scrive l'Insediamento Nahr sulla
  coppia che firma) — e da oggi quella coppia non scende sotto NEUTRAL,
  come il sangue (D-117).

### La memoria dichiarata

«O li dichiara memoria esplicitamente»: la sonda dei segni ora porta la
dichiarazione dentro di sé, con il motivo accanto — quattro cicatrici il cui
dente vivo è il gemello (plundered→condition:, divided_seal→crown_divided,
sealed_border→valley_sealed, unanswered→question_unresolved), le condition
curabili che sono mappa e cura, e quindici fatti nudi del mondo, narrati da
D-103 ed ereditati: la materia prima della voce 9. Un segno dichiarato senza
motivo vero è un imbroglio, e la lista è nel codice della sonda per essere
riletta.

### Misurato (stessi 100 semi, tavolo misto)

| passo | esiti Consigli | bloccati |
|---|---|---|
| base 0.1.84 | 184 · 75 · 129 · 177 | 0/8 |
| + i tre pesi del Consiglio | 183 · 80 · 123 · 177 | 0/8 |
| + le tre pesche guaste | identico al passo prima | 0/8 |
| + le pesche buone e la porta | 183 · 77 · 123 · 178 | 0/8 |
| + la ferita che parla | 185 · 78 · 121 · 178 | 0/8 |
| + il pavimento del patto | **185 · 78 · 123 · 176** | **0/8** |

Le pesche guaste non spostano gli esiti in 100 partite — le cicatrici
arrivano tardi nell'anno e la presenza lì è rara; al tavolo umano sono un
vincolo che si vede, come i divieti di D-117. Il censimento: **vivi per
clausola 34 → 46**, prima fila senza lettore né dichiarazione **0**, muti
senza dichiarazione **0**. Consigli 5,62 (mediana 6), nessun seggio crolla;
ere in banda (mediana 955 anni, 20,5 generazioni, 22 nomi), sim scritte a
zero fallimenti, sonda della visibilità ancora a zero.

### Il difetto trovato dalla guardia dei round-trip

Il pavimento del PACT ha reso significativo il tag sintetico che il test dei
round-trip usa da sempre, e il test è andato rosso con ragione: in
`_set_relation` il **livello veniva ripristinato prima dei tag**, quindi
l'undo leggeva il pavimento non ancora tolto e non poteva tornare sotto —
lo stato non tornava com'era. Latente dal pavimento del sangue (D-116), mai
morso perché nessun undo aveva ancora attraversato un pavimento. Adesso i
tag si ripristinano prima del livello, l'inverso è esatto, e per la stessa
moneta un segno scritto nello stesso effetto vale subito anche per il
livello che l'effetto dichiara (nessun dato d'autore combina le due cose:
comportamento di gioco invariato, verificato).

---

## D-121 — La sonda della visibilità, e i silenzi che ha trovato
**implemented in 0.1.84** (ISSUES 22, fasi 2 e 4 — la voce si chiude)

«Un effetto invisibile è un bug, non un'atmosfera.» La fase 1 (D-103) aveva
dato una frase agli effetti di Conseguenze, clausole e carta del Narratore; la
fase 3 (D-107) un corpo ai segni. Nessuno però aveva mai **contato**: la sonda
nuova (`cli/run_visibility_probe.gd`) gioca i 100 semi standard a tavolo misto
e rilegge il registro degli Effect contro il verbale della stessa partita —
ogni effetto o ha la sua frase a verbale (parola per parola), o un silenzio
**dichiarato** (i no-op, i delta finiti a zero, la contabilità di Propp, i
registri con la loro riga, il setup che si racconta in apertura, le azioni
che il resolver racconta con parole sue), o è **senza voce**: nominato, con
la fonte accanto.

### I silenzi che ha trovato, e le cure

- **Il placarsi della questione decisa (H.1)** — l'effetto centrale di ogni
  Consiglio, la Tensione che si placa a 1 o sfoga di 2, non aveva nessuna
  riga: si leggeva solo nello stato di fine round. Adesso parla
  («H. La Carestia scende di 5.»).
- **La rivelazione del presagio** — il presagio parlava, ma il numero
  arrivava sul tavolo in silenzio (`reveals_value` applicato senza riga).
  Adesso, se ha davvero svelato qualcosa: «… non è più velata: il suo numero
  è sul tavolo.»
- **Gli scarti muti** — il CLAIM (creare e forzare) e l'INFLUENCE via scarto
  spendevano una carta senza nominarla. Adesso la nominano.
- **I falsi passaggi** — `SET_CONTROL` su un controllo che non cambia mano e
  `SET_TENSION_VISIBILITY` su una questione già aperta ora si marcano no-op
  nell'applier: nessuna riga annuncia un trono che non si è mosso, e la
  «Carta parla» non racconta più cambi che non sono avvenuti.
- **Fase 2, la mappa non nasconde** — nella partita 15308 la Valle Verde,
  contesa e senza controllore, non è mai apparsa nella riga «Sulla mappa» del
  seggio: compariva solo chi aveva presidi o padrone. Una Regione **segnata**
  ora si vede sempre, coi nomi dei segni («Valle Verde (contesa)») — le
  stesse parole di D-107 che la mappa del browser disegna già.

Due voci di flusso sono dichiarate alla sonda con le loro parole: il Ripple
(«K. Ripple: … +1») e la spirale che si chiude ri-decidendo (D-094).

### Misurato

La sonda su 100 semi: **SENZA VOCE: 0** — ogni effetto che deve parlare,
parla. Playtest sugli stessi 100 semi invariato negli esiti (cambiano solo le
righe del verbale), suite verde.

---

## D-120 — La mossa che spegne il tuo Destino avverte prima
**implemented in 0.1.83** (ISSUES 21, chiusa)

Nella partita vera al seme 15308 Vaerax entra nell'ultimo round con la prima
spunta accesa («Presenza sulle Montagne Rosse») e la spegne **da solo**: un
MOVE al limite dei token toglie il presidio dalla montagna, e l'app non dice
nulla. Al tavolo fisico un compagno te lo farebbe notare.

### La forma

Nel `SeatDecider` — lo stesso del terminale e del browser (D-038), quindi una
sola implementazione — quando l'azione **scelta** dal giocatore spegnerebbe
una clausola del *suo* Destino oggi accesa: una riga («⚠ Questa mossa
spegne: …», con l'etichetta della clausola) e la scelta di ripensarci, che
riporta al menu. Solo il posto proprio, solo clausole già vere, nessun
suggerimento strategico: un cartello, non un consigliere.

### Il meccanismo

L'anteprima è una **sessione ricostruita dal salvataggio**
(`to_save` → `restore`): stesso mondo e stesso dado, quindi la previsione è
esatta — l'azione viene eseguita davvero sulla copia e buttata via, e non
esiste un secondo ramo di regole da tenere allineato al primo. Il costo si
paga solo quando un umano ha già scelto un'azione; le sedie automatiche e le
sim non passano di qui. (La copia fedele esiste perché D-119 ha appena messo
nel salvataggio anche i Consigli chiusi.)

### Misurato

Tre test (`test_destiny_warning`): la mossa nella forma del seme 15308
mostra l'avviso **nominando la clausola** e non tocca il mondo vero; «No, ci
ripenso» torna al menu; un ACQUIRE che non sfiora il Destino passa senza
cerimonie, una domanda sola. Suite 259 test / 5732 asserzioni verde; le
partite senza umani sono identiche per costruzione (il ramo non viene mai
percorso).

---

## D-119 — Gli effetti che pesano: le carte di Propp toccano il tavolo
**implemented in 0.1.82** (ISSUES 23, fase 2 — la voce si chiude)

D-118 aveva messo le carte in mano ai giocatori e lasciato aperta la fase 2:
«hook che toccano il tavolo (presenza, controllo, Consigli aperti), non solo
+1». Tre passi, ciascuno misurato sugli stessi 100 semi da 7000.

### Passo 1 — il punteggio legge le carte come le compila (motore)

`_play_narrator` valutava i hook coi binding del Consiglio aperto
(`effect_context()`), che fuori da un Consiglio sono **vuoti**: qualunque hook
scritto su un `$slot` pesava zero per costruzione, e i hook `CONSEQUENCE` non
erano valutati affatto — le sette carte della prima saga che sparano una
Conseguenza non potevano superare il filtro «serve al mio Destino» col loro
vero contenuto. Adesso il punteggio usa `card_bindings(hook, seggio)` — gli
stessi binding con cui la carta verrà compilata, chi cala è il proponente — e
le Conseguenze agganciate contano come contano in una proposta
(`_score_proposition`). Da solo: 190·88·120·176 → 182·83·123·175, 0/8,
Consigli 5,63; Lyra 9 → 11 Triumph (le sue carte-scoperta finalmente pesano).

### Passo 2 — la prima saga, carta per carta

Dieci carte riscritte, le altre dichiarate: le undici che sparano una
Conseguenza (controllo, presenza, relazioni) pesavano già, e `ECH_ROAD_CLOSED`
ha già due Destini che leggono il suo segno. Cosa è entrato:

- **presenza**: la Perdita ritira un presidio del `$rival` dalle Terre
  (opzionale), l'Offerta pianta chi la accetta nella `$region_focus`;
- **Consigli aperti**: la Supplica e il Tradimento prescrivono il Consiglio
  della Carestia, la Sedia Vuota quello della Successione;
- **segni con lettori**: il Presagio e la Scoperta danno una `discovery:` a
  chi cala (Lyra le conta), il Sacrificio dà la fama (dente D-105 + Destini
  condivisi), la Mancanza svuota il granaio (via il dente D-105), la
  Riconciliazione toglie l'inquietudine da Eredan (la Vittoria di Aldric la
  legge). L'Incontro resta leggero, a verbale: i rapporti nella prima saga
  non hanno lettori (D-068), e il suo mestiere (−1) è già del negoziatore.

**La forma respinta, coi numeri**: la prima Sedia Vuota faceva
`SET_CONTROL: null` su Eredan — il titolo tolto gratis, senza Consiglio e
senza cura fuori dai Consigli. Aldric crollava a 46 MIN / 3 VIC e il tavolo
misto tornava a **1/8 bloccato**. Il titolo non si perde per un'assenza: si
perde a un Consiglio, e la carta adesso lo apre. Forma finale:
184·79·124·176, **0/8**.

### Passo 3 — la seconda saga, che non aveva un solo hook pesante

Tredici carte su tredici erano «±1 e un tag». Adesso: l'Interramento chiude il
canale costruito (opzionale), la Chiamata e il Giorno che la Gilda Chiese
Tutto prescrivono il Consiglio del Debito, Due Sentenze quello della Carta; la
Veglia Spostata e il Pozzo Zitto piantano presenza (chi conta le campane manda
qualcuno, chi riapre il pozzo scende); la Crepa ritira un presidio del
`$rival` dalle Miniere; i Fuochi Fuori fanno decadere il controllo delle
Terre Nahr (periferia contesa, non il seggio di nessuno — la lezione della
Sedia Vuota); la Copia dà `discovery:relic` (due Destini la leggono);
l'Anno Corto affama la Valle coi denti veri di D-117 (niente patti, mano
stretta, e la cura esiste: le Braccia); il Tavolo Lungo riporta la coppia
`$proponent|$rival` a NEUTRAL (le clausole di D-068 lo leggono); la Stagione
Scavata muove l'acqua (`water_moves`, due Destini) e il canale che posa
consegna già il grano (GRANT_ON_SET, D-117); Messo per Iscritto dà la fama a
chi scrive. Misurato: **184·75·129·177, 0/8**, Consigli 5,65 (mediana 6).

### Il difetto trovato per strada

Il test di ripresa è l'unico andato rosso, e aveva ragione: i Consigli chiusi
vivevano solo in `ChronicleController.confluence_results`, **fuori dal
salvataggio** — una Chronicle ripresa dimenticava i Consigli già decisi e il
rapporto di fine anno ne contava uno in meno. Non si era mai visto perché
nessun seme di test apriva un Consiglio prima del punto di interruzione;
adesso che una carta può prescriverne uno al round 2, è successo. La cura:
`confluence_results` entra nel salvataggio accanto a `destiny_results`
(schema, serializer, restore).

### Le guardie

Suite 256 test / 5719 asserzioni verde; sim scritte deterministiche (due giri
identici, `expected` invariati); ere in banda (mediana 955 anni, 20,1
generazioni, 22 nomi); `validate_data.py` OK. Nessun seggio crolla: Aldric
43/6/1, Kessa 43/6/0, Ilve 10/39/1 — spostamenti di 2-3 partite su 50.
Resta un neo **pre-esistente**, identico sulla baseline: `ECH_LEGEND_CALLED_DAY`
non viene mai letta nelle saghe della sonda delle ere (una voce a zero è
contenuto che non esiste, D-035) — è materia per la voce 24, non di questa.

---

## D-118 — Le carte di Propp in mano ai giocatori
**implemented in 0.1.80** (ISSUES 23, fasi 1 e 3)

Il disegno è del committente (quattro scelte, a domanda): **2 carte a
testa per atto** dal sacchetto pesato dell'atto (§15), si calano **nel
proprio turno come azione** (PLAY_ECHO), calarle **costa una carta Asset
scartata**, e se nessuno cala **l'atto resta senza carta** — il silenzio
è una scelta del tavolo, nessuna rete di sicurezza. La pesca automatica
di fine atto non esiste più.

- L'ordine di Propp resta custodito dall'eleggibilità sui segni
  `function:` (D-030), giudicata **quando si cala**, non quando si pesca.
- Chi cala è il proponente della carta: `$proponent`/`$rival` leggono la
  mano che l'ha giocata; un Consiglio prescritto si prenota nello slot
  del CLAIM (`forced_confluence`).
- `echo_hand` per seggio nel mondo e nei salvataggi; il verbale dice chi
  paga e chi cala.
- **Le sedie automatiche**: al più una carta per atto a seggio (letta dal
  registro degli Effect — una memoria nella sedia divergeva alla ripresa),
  e **solo se gli effetti servono al proprio Destino** (lo stesso
  punteggio delle clausole negoziali). Senza il freno: 17 carte a cronaca
  e Consigli sotto banda; senza il filtro: Kessa piantata al Minimo 46/50
  e **1/8 bloccato** — entrambe le forme respinte coi numeri.

### Misurato (stessi 100 semi)

Base 0.1.79: 200·87·138·171. Con le mani del Narratore: **190·88·120·176,
0/8 al tavolo misto**, Kessa 41 MIN / 8 VIC (in salute), nessun seggio
crolla; ere in banda (955 mediana, 20.4 generazioni, 22 nomi); piani
scritti riallineati (la carta automatica non esiste più); 255 test,
5550 asserzioni. Restano aperte: gli effetti che pesano (fase 2, carta
per carta col committente) e la GUI del browser per calare dalla mano.

---

## D-117 — I denti veri: cinque regole d'autore, e la 48ª carta
**implemented in 0.1.79** (ISSUES 25, chiusa)

Il telaio di D-116 riceve i suoi denti — uno per tipo, tutti su segni che
il gioco già produce, accesi uno alla volta sugli stessi 100 semi:

- **I patti non si firmano a stomaco vuoto** (ACTION_GATE): chi ha
  presenza in una Regione affamata non FORGE. La fame si cura prima.
- **Il debito chiamato guasta il mercato** (DRAW_BIAS): con `debt_called`
  al mondo (la porta del Banco Nero, posata dal Credito di D-114), chi
  pesca WEALTH guarda due carte e prende la peggiore.
- **La fame mangia le scorte** (HAND_LIMIT): presenza in Regione
  affamata, limite di mano −1.
- **Chi riapre i canali ha il grano** (GRANT_ON_SET): quando
  `CNS_CANALS_DUG` posa `structure:canal`, il proponente riceve la
  Riserva di Grano.
- **Il sangue non si sceglie** (RELATION_FLOOR): il **Legame di Sangue**
  impegnato scrive `BLOOD` sulla coppia — è il suo mestiere, quello che
  D-113 aveva rimandato — e da lì la relazione non scende sotto NEUTRAL.
  Con questo, **48 carte su 48 lavorano**.

### Misurato (un dente alla volta, stessi 100 semi)

| passo | esiti Consigli (tavolo misto) |
|---|---|
| base (0.1.78) | 208 · 79 · 132 · 174 |
| + patti/fame | identico byte per byte |
| + debito/mercato | 202 · 87 · 135 · 171 |
| + fame/mano | esiti fermi (morde di rado: mani corte) |
| + canale/grano | 200 · 89 · 136 · 171 |
| + sangue/pavimento | 200 · 87 · 138 · 171 |

Il divieto della fame non morde mai in queste 100: le sedie automatiche
non firmano patti da una Regione affamata — come le cure di D-113, è una
regola che aspetta la sua condizione, e al tavolo umano è un vincolo che
si vede. Gli altri quattro mordono e spostano poco, in salute: **0/8 al
tavolo misto a ogni passo**, nessun seggio crolla, ere in banda (mediana
955 anni, 20.4 generazioni, 22 nomi), 255 test, 5370 asserzioni.

---

## D-116 — I denti che aggiungono e tolgono: i cinque ganci nuovi
**implemented in 0.1.78** (ISSUES 25, Fase 1)

I quattro ganci di D-104 piegano numeri e porte; questi aggiungono e
tolgono davvero. Cinque tipi nuovi di `tag_rule` — il quinto è il
pavimento che il Legame di Sangue aspetta da D-113 — costruiti col rito
di D-104: **il telaio prima dei denti**, ogni gancio provato con regole
sintetiche nei test e neutro finché nessuna regola vera è accesa.

- **ACTION_GATE** — finché il segno c'è, l'azione è vietata. Vive dentro
  `check()`, quindi vale una volta sola e ovunque: la sedia automatica
  non la propone, il browser la spegne, `execute()` la rifiuta («il
  segno lo vieta: …»).
- **DRAW_BIAS** — la pesca piegata: col segno addosso si guardano le
  prime due carte del mazzo indicato e si prende la peggiore (MALUS) o
  la migliore (BONUS); l'altra resta dov'era. Deterministico: l'indice
  viaggia nell'Effect (`deck_index`), l'applier verifica e non sceglie.
- **HAND_LIMIT** — il limite di mano si muove (`hand_limit_delta`), mai
  sotto una carta: l'assedio stringe le mani di chi è dentro.
- **GRANT_ON_SET** — il segno appena posato consegna una carta: quando
  un tag entra nello scope dichiarato, `grant.asset_id` passa all'ACTOR
  (chi ha causato l'effetto) o al TARGET (chi porta il segno), se la
  carta è nel mazzo o negli scarti — **una carta già in mano non si
  strappa**. La consegna è un Effect a sé nel log, con inverso: undo e
  salvataggi la vedono come tutto il resto.
- **RELATION_FLOOR** — il pavimento: sotto `min_level` non si scende.
  Se tetto (D-104) e pavimento si contraddicono, **vince il tetto**: la
  ferita scritta pesa più del vincolo di nascita.

### Misurato

Zero regole nuove accese nei dati: playtest 100/7000 **identico byte per
byte** alla base 0.1.77 (208·79·132·174, 0/8), suite 255 test / 5372
asserzioni. I denti veri sono la Fase 2: scritti col committente, accesi
uno alla volta e misurati — come le cinque regole di D-105.

---

## D-115 — Il Destino condivisibile: «$self» e i pool a tre
**implemented in 0.1.77** (ISSUES 20, chiusa)

Due ambizioni per casa erano il minimo vitale: su ~14 rotazioni a saga il
giro tornava. La terza carta di ogni pool è **condivisibile**: scrive
`$self` al posto della casa, e le clausole si risolvono su **chi la
giura** — la stessa carta, un'ambizione per ciascuno. Il motore doveva
solo imparare `$self`: `evaluate(destiny_id, holder)` lo sostituisce e
passa `{"self": holder}` al risolutore delle condizioni (lo stesso
meccanismo di `$proponent`, D-028); pianificatore, negoziato e pannello
passano il contesto del proprio seggio; la carta stampata dice «per chi
lo giura» e il brief d'arte non le dà l'accento di nessuna casa.

Tre carte, assegnate per carattere (pool 2→3 per tutte e otto le case):

- **Il Nome che Pesa** (Aldric, Vetro, Libere — chi vive di parola):
  la fama, poi una Regione, poi due e nessuna proposta caduta;
- **La Terra che Risponde** (Nahr, Vaerax, Cenere — chi vive di posti):
  una, due, tre Regioni controllate;
- **I Conti Chiusi** (Lyra, Ilve — chi vive di registri): il proprio
  registro pulito, poi la fama e nessuna domanda aperta, poi nessun
  giuramento spezzato nel mondo che lasci.

`promise_kept` è rimasto fuori apposta: vuole un `other_entity_id`
fisso, e una carta condivisa non sa in anticipo con chi.

### Misurato (sonda dei Destini, 100 semi da 7000, per tavola)

La prima forma dei Conti Chiusi è stata **respinta coi numeri**: tre
clausole tutte di assenze, vere al primo round — scala intera già chiusa
**100/100 al round 1.0**, il difetto di D-051 (vincere stando seduti).
Riscritta con la fama nella Vittoria (un segno che si conquista al
tavolo: 33–58/100 in CHR_01, 61–100/100 in CHR_03):

| scala condivisa | chiusa in anticipo (round medio) |
|---|---|
| Nome che Pesa | Aldric 18/100 (8.2) · Vetro 0/100 · Libere 3/100 (8.3) |
| Terra che Risponde | Nahr 0/100 · Vaerax 0/100 · Cenere 0/100 |
| Conti Chiusi | Lyra 18/100 (7.3) · Ilve 47/100 (6.3) |

In famiglia con le identitarie (Lyra 69/100, Vaerax 18/100, NAHR 2/100);
la vetta della Terra (tre Regioni) non si è mai chiusa in 100 partite —
è la vetta, e i gradini sotto vivono. Playtest **identico alla base**
(208·79·132·174) con **0/8 al tavolo misto** — dentro una Chronicle non
cambia nulla finché la rotazione non posa la carta; ere in banda
(mediana 955 anni, 19.8 generazioni, 22 nomi); 248 test, 5352 asserzioni.
La sonda dei Destini ora misura anche le scale condivise, per ogni seggio
che le porta nel pool.

---

## D-114 — Le carte con un mestiere, ultimi mazzetti: WEALTH, KNOWLEDGE, PEOPLE
**implemented in 0.1.76** (ISSUES 26, chiusa)

Diciassette mestieri e la voce si chiude: **46 carte su 48 lavorano**, e
le due che no lo dichiarano (l'Archivio ha già il suo mestiere — restare
in mano; il Legame di Sangue aspetta il pavimento di relazione della
voce 25).

- **WEALTH, il grano compra e cura**: la Riserva sfama (Carestia −1), il
  Sale supera la magra, la Carovana ricollega la Regione tagliata fuori,
  il Pedaggio si scrive sulla mappa, le Chiavi razionano, e il **Credito
  chiama il debito** — `debt_called`, la porta del Banco Nero.
- **KNOWLEDGE, il sapere svela e mente**: la **Voce di Corridoio vela**
  la questione e la **Prova la svela** — la coppia più bella del mazzo;
  la Mappa Vecchia ricuce il ponte rotto, il **Registro apre i conti**
  (`ledger_public`), il Testimone agita la sede dell'accusato.
- **PEOPLE, la gente marcia**: la Folla porta l'inquietudine in
  capitale, gli Anziani elaborano il lutto, le **Braccia spengono la
  fame della Regione affamata** (e la sua regola D-105), la
  Mobilitazione scalda la piazza (+1), il **Portavoce impegna una
  PROMISE** che il giudizio delle promesse legge, la Marcia rompe le
  razioni delle Chiavi.

Contromosse fra famiglie: Chiavi↔Marcia, Voce↔Prova, Mercenari/Folla↔
Editto, Diritto di Corona↔Censimento, Banda/Mobilitazione↔Sigillo. I
piani B e C aggiornano le attese (i riscaldi e i raffreddi spostano i
tempi dei Consigli).

### Misurato (una famiglia alla volta, stessi 100 semi)

| passo | esiti Consigli |
|---|---|
| base (D-113) | 197 · 94 · 127 · 182 |
| + WEALTH | 197 · 90 · 126 · 179 |
| + KNOWLEDGE | 193 · 84 · 133 · 176 |
| + PEOPLE | 208 · 79 · 132 · 174 |

Il mondo si fa più duro e meno estremo: più fallimenti (la Mobilitazione
scalda), meno Decisive (Sigillo, Riserva e Braccia raffreddano). Le
distribuzioni restano sane — Ilve respira (17→12 MIN), Lyra resta prima
ma meno schiacciante (28→22 TRI al tavolo misto), nessun seggio crolla —
e **0/8 al tavolo misto a ogni passo**; ere in banda (20,6 / 22 nomi);
guardia biblioteca verde. 246 test, 5324 asserzioni.

## D-113 — Le carte con un mestiere, terzo mazzetto: BONDS
**implemented in 0.1.75** (ISSUES 26, punto 3)

I legami toccano le relazioni, ed è la famiglia delle **cure**:

- **Giuramento**: il giuramento rifatto scioglie quello spezzato — toglie
  `oath_broken` dalla coppia (la cura del tetto di D-105, che non ne
  aveva);
- **Favore**: il piccolo favore spegne la vendetta — toglie `VENDETTA`
  dalla coppia (il segno che il giudizio delle promesse legge come
  rottura);
- **Diritto di Ospitalità**: chi lo impegna torna ospite — cancella la
  propria cacciata (`evicted:`) dalla Regione della domanda (la cura di
  D-067);
- **Promessa di Nozze**: fra le due case nasce un `PACT` — il segno che
  le promesse giudicano: mantenerlo è `promise_kept`, tradirlo
  `promise_broken`. E il testo dice il **+2** vero (terza etichetta
  bugiarda della serie);
- **Debito Vecchio**: il debito chiamato segna la sede del debitore
  (`condition:indebted`, segno vivo).

**Il Legame di Sangue resta senza mestiere, dichiarato**: il suo potere
vero — il vincolo che non si sceglie, un pavimento di relazione — è
design della voce 25, e una toppa qui sarebbe stata un numero travestito.

Nel passaggio l'applier ha imparato che una relazione con se stessi è un
no-op, non un errore: quando «$actor|$rival» degenera (a impegnare la
carta è il rivale), l'effetto tace.

### Misurato (un mestiere alla volta, stessi 100 semi)

Base 197·94·127·182 (identica a D-112) e **tutti i passi identici**:
esiti e distribuzioni dei Destini fermi. Onesto e atteso — i legami sono
cure e stati, non forza: mordono quando le loro condizioni esistono
(un giuramento spezzato da sciogliere, una cacciata da annullare), e le
sedie automatiche raramente ci camminano dentro. Al tavolo umano sono
esattamente le carte che si tengono in mano per il momento giusto. 0/8 a
ogni passo; ere in banda (20,3 / 22 nomi); 246 test, 5190 asserzioni.

## D-112 — Le carte con un mestiere, secondo mazzetto: AUTHORITY
**implemented in 0.1.74** (ISSUES 26, punto 2)

I sei sigilli che erano solo un numero ora fanno quello che il nome
promette — e il mazzetto disegna un'economia di segni, con cure e
contro-cure:

- **Editto**: la riga scritta calma la piazza — cancella l'inquietudine
  (`condition:unrest`, il segno dei Mercenari) dalla Regione della
  domanda;
- **Sigillo**: il sigillo raffredda — la Tensione in gioco scende di 1
  (l'opposto della Banda Armata);
- **Censimento**: la lista chiarisce — toglie la contesa
  (`condition:contested`) dalla Regione della domanda;
- **Diritto di Corona**: la pretesa divide — posa la contesa che il
  Censimento cura;
- **Magistrato**: il giudice risponde — cancella la domanda rimasta sul
  muro (`scar:unanswered`, la cicatrice della spirale). E il testo dice
  finalmente il **+2** vero sul fronte Oppose (stessa svista
  dell'Assedio, D-106);
- **Investitura**: la nomina scrive un nome nella linea — posa
  `heir_named` sul mondo, lo stesso segno di CNS_HEIR_NAMED, che la
  porta della Corona Restaurata (D-110) legge. Una carta comune che può
  aprire una vita.

Aggiustato per strada: il narratore ora dà ai segni le **parole del
dizionario** (D-107) anche a verbale — «resta un segno: “contesa”», non
«condition:contested».

### Misurato (un mestiere alla volta, stessi 100 semi)

Base 198·94·128·183 (identica a D-110). Editto, Censimento, Magistrato,
Investitura: esiti invariati nei sim (cure e fatti che mordono altrove).
Sigillo: 197·96·127·181 — il raffreddamento ammorbidisce, due Decisive
in meno. Diritto di Corona: 197·94·127·182. **0/8 a ogni passo**; ere in
banda (20,4 generazioni, la porta della Restaurazione si apre un filo di
più per via dell'Investitura — voluto); guardia biblioteca verde. Il
piano B aggiorna le attese (4→6 Confluence: il Sigillo sposta i tempi).
246 test, 5178 asserzioni. (Nota di metodo: la prima misura era falsata
— lo strumento spegneva solo i mestieri D-106; rifatta con il passo 0
identico alla base, com'è giusto.)

## D-111 — Il tarocco per ogni vita
**implemented in 0.1.73** (ISSUES 19, Fase 3 — l'ultima della voce)

Con 11 vite oltre le prime, un solo tarocco per seggio era tornato a
essere «nomi che cambiano su una carta». Ora **ogni vita ha la sua
carta**:

- **Il mazzo Casata** (`CardFace.deck_of("entity")`) porta una carta
  TAROT per ogni incarnazione oltre la prima: nome e descrizione della
  vita, valori suoi, prompt d'arte suo, il seggio nel sottotitolo. I
  fogli di stampa crescono da soli (19 tarocchi di casata), la cache
  dell'app pure.
- **Il tarocco segue la vita** nel pannello del seggio: quando il seggio
  si trasforma, sul tavolo dell'app si posa la carta della vita corrente
  — come al tavolo fisico, dove il tarocco nuovo esce dal mazzo.
- **Il brief d'arte** ora contiene gli 11 prompt delle vite (l'ArtBible
  risolve l'archetipo dal seggio: un culto nato da un drago si dipinge
  col colore del suo seggio), e il materiale di revisione passa da 661 a
  **745 testi**: le descrizioni delle vite e degli eredi — anche quelli
  dei re restaurati — entrano nel giro editoriale.

### Misurato

Nessun cambio di regole: 246 test in 33 suite (1 nuovo sul mazzo), 5175
asserzioni, verdi; export con i fogli nuovi; parità del brief in CI.

## D-110 — L'albero si riempie: sei vite dai rami
**implemented in 0.1.72** (TRASFORMAZIONI.md, prima ondata)

Le sei vite dell'albero che il vocabolario di oggi sa sostenere, ognuna
con ingresso e potere:

| vita | seggio | ingresso | potere (W +1 quando propone su…) |
|---|---|---|---|
| La Reggenza del Granaio | Aldric | `grain_requisitioned` a linea esaurita | la Carestia |
| La Corona Restaurata | Aldric | `heir_named` dalla Repubblica — **il cerchio**: torna MORTAL con 4 re nuovi | la Successione |
| Vaerax Ridestato | Vaerax | `crystal_exploited` (evento) | il Risveglio |
| Il Banco Nero | Sale | `debt_called` a linea esaurita | il Debito |
| L'Inquisizione del Vetro | Vetro | `relic_shown` a linea esaurita | la Reliquia |
| La Lega delle Sette | Libere | `charter_written` (evento) | tutto ciò che propone |

### La correzione del motore

L'ingresso `ON_TAG` immediato (senza linea esaurita) ora vale **solo per
chi non muore** (COLLECTIVE/ETERNAL): una dinastia non si interrompe a
metà — per i MORTAL il segno sceglie la vita al momento giusto, quando
la linea si esaurisce. Senza questo, un grano requisito avrebbe tagliato
la dinastia di Aldric alla prima generazione.

### Misurato

Playtest standard identico, 0/8 al tavolo misto; guardia degli
anni-biblioteca verde. Sonda delle ere: tavola I 20,2 generazioni e 22
nomi distinti per saga (il cerchio repubblica→corona consuma anche i re
restaurati), tavola III 16,0 e 18; anni in banda su entrambe (955 e
1049). Suite 245 test in 33 suite, 5115 asserzioni.

## D-109 — Gli ingressi dell'albero: la storia sceglie la vita
**implemented in 0.1.71** (voce 19, verso TRASFORMAZIONI.md)

Tre porte per le vite del seggio, e non più solo il calendario:

- **`ON_TAG`**: la vita entra alla successione se il suo segno
  (`entry_tag`) sta sul mondo, sulla casa o su una Regione — è la storia
  giocata a scegliere. Vale anche senza linea esaurita: il popolo che si
  è insediato diventa regno quando il suo segno è scritto, non quando
  finisce una lista.
- **`ON_DEATH`**: il seggio morto (active=false) rivive nella vita che
  lo aspetta — il seggio sopravvive alla creatura.
- **Vite alternative**: fra più candidate entra la prima, in ordine
  d'autore, il cui ingresso è vero. A linea esaurita, un `ON_TAG` messo
  prima del ripiego `LINE_EXHAUSTED` fa scegliere alla storia.

Ogni vita oltre la prima porta il segno **`life:<id>`** sulla casa, e le
tag_rules lo leggono con lo scope ENTITY che già esiste: **i poteri per
vita non hanno richiesto un gancio nuovo.** Il verbale distingue le tre
porte («I segni hanno scelto…», «X non c'è più, ma il seggio non
muore…», «La linea si è esaurita…»).

### Le tre vite di dimostrazione (dall'albero)

1. **L'Accademia delle Misure** (Lyra, `ON_TAG succession_by_law`): con
   la legge scritta sul mondo, a linea esaurita nasce l'università, non
   la chiesa. Potere: quando propone, World Factor +1.
2. **Il Regno di Nahr** (`ON_TAG nahr_settled`): il popolo che si siede
   **diventa MORTAL** — quattro re scritti, eredi da perdere.
   Potere: World Factor +1 quando propone sulla Carestia. (Prima forma
   — INFLUENCE +1 sulla Carestia — **respinta coi numeri**: scaldava la
   pentola e l'anno-biblioteca decideva 7 Consigli contro la banda 3–6
   della guardia. Riscritta come peso al tavolo: guardia in banda.)
3. **Il Culto della Montagna** (Vaerax, `ON_DEATH`): oggi nessuna
   Conseguenza sa uccidere il drago — scriverla è contenuto d'autore che
   questa vita rende possibile. Potere: World Factor +1 quando propone
   sul Risveglio.

### Misurato

Motore nuovo con dati vecchi: **tutto invariato al byte**. Con le tre
vite: playtest standard identico, 0/8; sonda delle ere: generazioni per
saga 10→**16,4** e nomi distinti 10→**16** — il Regno consuma i suoi re,
l'Accademia esiste — con anni (mediana 955) e salti (20–200) in banda e
la guardia degli anni-biblioteca verde. Suite 243 test in 33 suite (4
nuovi sulle porte), 5110 asserzioni.

## D-108 — La successione attraversa le incarnazioni
**implemented in 0.1.70** (ISSUES 19, Fase 2; generalizzata dal committente)

«Le incarnazioni sono un esempio di Anselmo, ma anche le altre entità
potrebbero mutare: la dinastia potrebbe diventare una repubblica, i saggi
un culto della persona.» Prima di questa fase, una linea esaurita
riciclava nomi per grammatica (D-046) per sempre: dieci secoli di re
intercambiabili. Ora **quando la linea dei successori scritti finisce, il
seggio cambia vita**: entra l'incarnazione successiva (`entry:
LINE_EXHAUSTED`) con nome, descrizione, natura, valori e successori
propri, e il verbale d'apertura lo racconta — «La linea di Priore Anselmo
si è esaurita: al suo posto siede I Frati del Vetro.»

### Come

- `Succession.plan` ragiona sulla **vita corrente** (`active_view`): la
  definizione del seggio con sopra i campi dell'incarnazione al tavolo.
  La persistenza appartiene alla vita, non al seggio: una dinastia
  diventata repubblica (COLLECTIVE) **smette di morire** e di consumare
  eredi. La vita nuova non eredita né successori né grammatica dei nomi
  della vecchia: una linea esaurita resta esaurita.
- Lo stato del seggio nel mondo porta `incarnation` (indice della vita,
  in save e schema); la generazione riparte da zero con la vita nuova.
- **Cinque seconde vite d'autore** per i cinque seggi MORTAL: Re Aldric →
  *La Repubblica della Valle*; Lyra → *Il Culto della Misura* (il culto
  assolutista della persona); Maestra Ilve → *La Compagnia del Sale*;
  Priore Anselmo → *I Frati del Vetro*; Kessa dei Fuochi → *Le Custodi
  della Cenere*. Tutte COLLECTIVE, con valori d'azione propri (oggi solo
  sulla carta, per D-104 il telaio è pronto) e `art_prompt_key` proprio
  in attesa della Fase 3 (il tarocco per incarnazione).

### Misurato

Playtest standard **identico** (198·94·128·183, 0/8 al tavolo misto): le
saghe corte non esauriscono linee. Sonda delle ere (20 saghe × 10
Chronicle, seme 812): **10 generazioni per saga e 10 nomi distinti** — i
quattro eredi scritti più la vita nuova per ciascun seggio mortale, e poi
il seggio smette di morire; anni per saga mediana 955 (in banda con
D-075), salti 20–200, Destini ruotati 16,2 per saga. Suite 239 test in
33 suite (5 nuovi sulla traversata), 5097 asserzioni, verde.

## D-107 — I segni hanno un corpo: la parola, il pannello, il segnalino
**implemented in 0.1.69** (ISSUES 22, Fase 3)

Da D-105/D-106 i segni mordono; un giocatore giudicato da regole
invisibili è la definizione di un gioco rotto. Tre corpi, una sola voce:

- **Il dizionario condiviso** (`sign_labels.gd`): l'unico posto dove un
  tag diventa una parola italiana — «tagliata fuori», «il granaio», «la
  domanda sul muro», «cacciata da Valle Verde». Un test scorre tutti i
  segni che i dati sanno scrivere e pretende che ognuno abbia qui la sua
  parola: un segno senza nome fallisce la suite.
- **La mappa e il seggio**: la mappa scriveva già i segni ma col suffisso
  inglese del tag («cut_off») — ora usa il dizionario; il pannello del
  seggio guadagna «I SEGNI DELLA CASA» (fama, scoperte, la porta
  sbarrata in rosso), che sparisce quando non c'è nulla da dire.
- **La fustella** (`region_signs_svg` / `entity_signs_svg`): due pagine
  nuove nell'export e nel PDF — i segni delle Regioni (condizioni in
  doppia copia col bordo tratteggiato: si tolgono quando la cura arriva;
  strutture e insediamenti; Cicatrici in rosso, copia singola: la mappa
  non le dimentica) e i segni delle case (uno ciascuno, più quattro
  «cacciata» e due «giuramento spezzato»). Stessa parola dell'app.

I **fatti del mondo** restano senza segnalino per scelta: la loro casa
fisica sono le pagine della cronaca, che già si stampano.

### Trovato per strada

`confluence_board.gd` dichiarava `_draw(session, council)` sopra la
`_draw()` di CanvasItem: dall'0.1.60 l'app **non compilava** — la suite
headless non carica le scene, quindi nessun test lo vedeva. Rinominata
`_paint_council`, avvio headless pulito; a verbale il debito di un
controllo di compilazione dell'app in CI.

### Misurato

234 test in 32 suite (3 nuovi sulle parole dei segni), 5066 asserzioni,
verdi; export con le due pagine nuove; nessun cambio di regole.

## D-106 — Le carte con un mestiere, primo mazzetto: FORCE
**implemented in 0.1.68** (ISSUES 26, punto 1)

«Le carte impegnate servono a qualcosa o sono solo punti?» Il censimento
diceva 35 su 48 solo numero. Il primo mazzetto risponde: le cinque carte
FORCE senza mestiere ora ne hanno uno, con `on_commit_effects` che fanno
quello che il nome promette:

- **Leva Contadina**: le braccia tolte ai campi — la Carestia sale di 1;
- **Guardia di Confine**: la conta ferma anche i carri onesti — Le Vie
  Interrotte salgono di 1;
- **Posto di Blocco**: la Regione della domanda resta `condition:cut_off`
  — segno vivo (letto dalle clausole) e curabile (la Scorta Giurata e Le
  Vie Riaperte lo tolgono);
- **Mercenari**: dove passano resta `condition:unrest`;
- **Assedio**: chi assedia affama — la Carestia sale di 1. (Nel
  passaggio: il testo diceva «+1 sul fronte Oppose» ma il modificatore è
  sempre stato 2 — testo allineato al +2 reale.)

I riscaldi su Carestia e Vie sono no-op nelle Cronache che non giocano
quelle Tensioni; i due segni-condizione lavorano ovunque. E la carta
impegnata **parla a verbale**: «H. La carta parla - Leva Contadina
(Popolo Nahr): La Carestia sale di 1.» — stesso narratore di D-103,
stessa regola: chi non muove nulla non parla.

### Misurato (un mestiere alla volta, stessi 100 semi)

| passo | esiti Consigli (FAIL/SUCC-c/SUCC/DECI) |
|---|---|
| base (D-105) | 196 · 88 · 124 · 189 |
| + Leva | 198 · 91 · 127 · 186 |
| + Guardia | 198 · 92 · 127 · 185 |
| + Posto di Blocco | invariato (morde via clausole ed eredità) |
| + Mercenari | invariato (idem) |
| + Assedio | 198 · 94 · 128 · 183 |

**0/8 seggi bloccati al tavolo misto a ogni passo.** Il mondo si fa un
filo più duro (sei Decisive in meno) e le distribuzioni si muovono in
modo sano: i Nahr respirano (4→1 NONE, 22→25 VIC — la famiglia della
forza scalda la Carestia, che è la loro domanda), Aldric al tavolo misto
guadagna Trionfi (7→10). Suite 231 test / 5012 asserzioni verde; brief,
manifest e materiale di revisione rigenerati.

## D-105 — I primi cinque denti, accesi uno alla volta
**implemented in 0.1.67** (ISSUES 24, Fase 3; «accendi tutte» del committente)

Le prime cinque tag_rules vere, in `godot/data/tag_rules/tag_rules_core.json`,
accese in fila sui 100 semi standard (`--runs=100 --seed=7000`), esiti dei
Consigli (FAIL / SUCC-costo / SUCC / DECI) a ogni passo:

| passo | esiti | note |
|---|---|---|
| tutte spente | 198 · 91 · 121 · 187 | la base, identica a D-104 |
| + granaio | 196 · 92 · 121 · 188 | due fallimenti in meno; Aldric uniforme 8→7 VIC, 4→5 TRI |
| + fame | 196 · 92 · 122 · 187 | un Consiglio della Carestia perde il Decisive |
| + strada | invariato | la porta non flippa esiti nei sim: morde sul movimento |
| + giuramento | invariato | il tetto morde solo a risalita sulla coppia firmata: raro nei sim |
| + fama | 196 · 88 · 124 · 189 | il dente più visibile: quattro Consigli cambiano riva |

**0/8 seggi bloccati al tavolo misto a ogni passo**; le distribuzioni dei
Destini restano stabili (unica variazione: quella di Aldric col granaio).
Tutte e cinque restano accese.

### Le regole

1. **Il granaio parla** (`structure:granary`, REGION): INFLUENCE sulla
   Carestia +1 per chi ha presenza nella Regione del granaio.
2. **La fame siede al tavolo** (`condition:starving`, REGION): World
   Factor −1 sui Consigli della Carestia finché una Regione muore di fame.
3. **La strada depredata** (`condition:plundered`, REGION): porta BLOCK;
   la cura esiste già — Le Vie Riaperte tolgono il segno.
4. **Il giuramento spezzato** (`oath_broken`, RELATION): il Patto Rotto
   ora firma la coppia (`add_tag` su `$proponent|$rival` in
   CNS_OATH_BROKEN) e fra quelle due case la relazione non sale sopra
   HOSTILE. Scendere resta possibile.
5. **La fama precede** (`renowned`, ENTITY sul proponente): World Factor
   +1 quando propone chi ha vinto un Decisive. Il più famoso dei segni
   muti del censimento, al lavoro.

### Il motore imparato per strada

`council_world_factor` ora conosce il proponente e legge tre scope:
GLOBAL (il mondo), ENTITY (chi propone), REGION (una Regione qualsiasi
col segno). Prova dal vivo sul piano A: quarto Consiglio, Aldric già
`renowned`, «1d6 = 6 -> +3 · Il segno pesa sul Consiglio: La fama
precede.»

## D-104 — Il telaio delle tag_rules: i segni possono avere un dente
**implemented in 0.1.66** (ISSUES 24, Fase 2; zero regole accese)

Il censimento della voce 24 (0.1.65) ha contato 18 segni muti e 27
ereditati senza dente. Prima dei denti, il telaio: un nuovo documento
dati `tag_rule` che lega un segno a un gancio del motore, così ogni
regola futura sarà un dato d'autore — scritto, acceso da solo e misurato
sui 100 semi standard — e mai un ramo di codice nascosto.

### La forma

`schema/tag_rule.schema.json`: id `TGR_…`, `title` (come il verbale la
nomina), `when` {`scope`: GLOBAL/REGION/ENTITY/RELATION, `tag`}, `kind`,
i campi del suo tipo, `chronicle_id` opzionale (la regola resta a casa
sua), `active` obbligatorio (una regola spenta è un progetto, non una
meccanica). I quattro ganci:

- **ACTION_MODIFIER** (`template`, `delta`, `tension_id?`): il valore
  dell'azione si allarga nel suo verso. Cablato in INFLUENCE; scope
  REGION vale se il segno sta dove chi agisce ha presenza.
- **COUNCIL_MODIFIER** (`world_factor_delta`, `tension_id?`): il dado
  resta il dado, è il World Factor che un mondo segnato piega.
- **GATE** (`movement` BLOCK/ALLOW, scope REGION): la porta sbarrata
  vince, come la cacciata di D-067; ALLOW concede un passo anche senza
  adiacenza.
- **RELATION_CAP** (`max_level`, scope GLOBAL/RELATION): il tetto clampa
  le salite nell'applier — scendere resta sempre possibile. (Nota: un
  undo dev-mode di una salita sopra il tetto riclampa; da sciogliere in
  Fase 3 con la prima regola vera.)

Ogni regola che morde su un'azione o un Consiglio **si firma a verbale**
(«Il segno pesa: …»), nello spirito di D-103. `TagRules.active()` scorre
gli id ordinati: deterministico come tutto il resto (§18.3).

### Misurato

Zero regole nei dati: 231 test in 31 suite (8 nuovi sul telaio, ogni
gancio provato con una regola sintetica accesa e spenta), 4974
asserzioni, verdi; playtest standard invariato, 0/8 seggi bloccati al
tavolo misto. La Fase 3 — i denti d'autore, uno alla volta — parte dalle
scelte del committente su granary, starving, plundered, oath_broken,
renowned.

## D-103 — Il verbale racconta gli effetti, non gli id
**implemented in 0.1.64** (ISSUES 22, Fase 1; dalla partita al seme 15308)

«Non si capisce quali sono le conseguenze delle decisioni prese.» Il
mondo cambiava davvero — nella partita vera la corona ha perso il
controllo della Valle Verde — ma in silenzio: il verbale elencava gli id
(«H. Conseguenze: CNS_NAHR_SETTLEMENT, …») e applicava gli effetti senza
una parola.

### Il narratore

`effect_narrator.gd`: una frase parlata per ogni Effect applicato, con i
nomi del tavolo e mai gli id — «Valle Verde passa sotto il controllo di
Re Aldric», «Popolo Nahr perde la presenza in Valle Verde», «Il Risveglio
non è più velata: il suo numero è sul tavolo», «Su Valle Verde resta un
segno: “structure:granary”». Tace per scelta su tre cose: i no-op (un
segno già presente non si riscrive), la contabilità di Propp (i tag
`function:` sono grammatica, non storia — D-030), e ciò che ha già una
voce propria (Scar, Echo, Truth).

### Dove parla

- **Le Conseguenze di un Consiglio**: ogni Conseguenza apre col titolo
  («H. Conseguenza - Il Granaio del Trono:») e sotto le sue frasi;
  la riga con gli id non esiste più.
- **La clausola qualificata**: gli effetti della condizione che passa.
- **La carta Echo d'atto**: quello che la carta fa al mondo, scritto
  sotto quello che la carta dice — la «Scoperta» del seme 15308 aveva
  svelato una Tensione senza una riga.

Nel passaggio, gli `applied` della carta d'atto sono ora gli Effect
registrati (con l'inverse), non i compilati: il narratore distingue i
no-op dall'inverse, e il segnale `act_echo_drawn` ne guadagna in fedeltà.

### Misurato

223 test in 30 suite (7 nuovi sul narratore), 4955 asserzioni, verdi;
playtest standard invariato, 0/8 seggi bloccati al tavolo misto. Il
verbale è più lungo solo dove prima era muto.

## D-102 — Le incarnazioni del seggio: la forma prima dell'attraversamento
**implemented in 0.1.63** (ISSUES 19, Fase 1; voluta dal committente)

«In una partita il giocatore gioca padre Anselmo, in una seguente un culto
derivato da lui.» Oggi il seggio attraversa i secoli cambiando solo il nome
(D-045/D-046): stessa natura, stessi poteri, stessa carta. Le
**incarnazioni** sono le vite del seggio: prima la persona, poi quello che
nasce da lei — natura diversa, `action_values` propri, tarocco e prompt
d'arte propri.

### La Fase 1: solo la forma

Lo schema `entity` guadagna l'array opzionale `incarnations` — ognuna con
`id` (`INC_…`), nome, descrizione, `persistence`, `action_values`,
`art_prompt_key`, i *propri* successori e `name_grammar`, e la regola
d'ingresso `entry`: `FOUNDING` (siede al tavolo dalla prima cronaca, una
sola per seggio) o `LINE_EXHAUSTED` (entra quando la linea dei successori
dell'incarnazione precedente finisce). Le forme condivise fra Entità e
incarnazione (`action_values`, `successors`, `name_grammar`,
`persistence`) sono salite in `$defs` e referenziate da entrambe.

Gli 8 seggi migrati: la prima incarnazione (`INC_<SEGGIO>_01`,
`FOUNDING`) assorbe i campi attuali. Il motore **non le legge ancora**:
finché la Fase 2 non sposta il lettore, i campi al livello dell'Entità
restano l'autorità, e una guardia in `validate_data.py` impone che la
prima incarnazione li rispecchi esattamente (test negativo: rompere lo
specchio fa fallire la validazione con `does not mirror entity field`).

### Prima/dopo

Suite 216 test / 4557 asserzioni verde prima e dopo; playtest standard
(`--runs=100 --seed=7000`) invariato, **0/8 seggi bloccati al tavolo
misto**. Nessun comportamento è cambiato: questa fase compra solo il
posto dove la Fase 2 (l'attraversamento con riga di verbale), la Fase 3
(un tarocco e un prompt per incarnazione) e la Fase 4 (i poteri) potranno
vivere.

## D-101 — La GUI mostra i componenti fisici, non una loro parafrasi
**implemented in 0.1.59** (direzione del committente; prima fetta)

«La GUI di Godot dovrebbe essere quanto di più vicino al gioco fisico.»
Il progetto aveva già il principio, applicato due volte: la cronaca
in-app è **le stesse pagine** che si stampano (D-086), l'anteprima F4 è
**gli stessi fogli** (D-056). Questa decisione lo estende al tavolo:
quello che un giocatore vede durante la partita è il componente fisico,
rasterizzato — non un pannello che gli somiglia.

### Il mattone e la prima fetta

`PrintSheet.card_svg(face)`: una carta sola, stessa faccia del foglio di
stampa, taglia propria, senza segni di taglio. `ui/card_art.gd` la
rasterizza una volta per mazzo e la tiene in cache. Con questo:

- **la mano è fatta di carte stampate**: `asset_card` mostra la faccia
  vera (63×88 in proporzione); lo schermo aggiunge solo ciò che il
  tavolo saprebbe a voce — il bordo di rilevanza e la riga «vale N»
  chiesta al resolver (D-040) — e il tooltip resta per leggere il testo
  a carta piccola;
- **il mondo cala una carta**: a fine atto la vista Echo mostra la carta
  stampata a sinistra e il verbale di cosa ha fatto a destra.

Un solo impaginatore, tre superfici: foglio, anteprima, partita. Una
correzione a un testo o a un layout arriva ovunque insieme, e non può
divergere per costruzione.

### Le fette dichiarate

- ✅ la **carta mini della domanda** posata al centro quando un Consiglio
  si apre — **fatta in 0.1.60**: fisicamente, la carta si prende dalla
  traccia e si mette in mezzo al tavolo, e il tabellone del Consiglio fa
  lo stesso;
- ✅ i **token sulla mappa** come i segnalini della fustella (D-097) —
  **fatta in 0.1.60**: i tondi di presenza portano l'iniziale della
  casa, l'anello di controllo c'era già;
- ✅ le **carte-identità** (tarocchi di Casata e Destino) — **fatta in
  0.1.61**: dietro il paravento, sopra la scala del Destino, e le vede
  solo chi le giura perché il pannello è già disegnato per il solo
  viewer. Con questa, le fette dichiarate di D-101 sono complete.

Guardie: `test_print_export` (la carta singola esce della sua taglia,
senza segni di taglio, deterministica, e si rasterizza per ogni mazzo).

---

## D-100 — La voce del Consiglio: le mozioni al congiuntivo
**implemented in 0.1.58** (seconda lettura della voce 13, su segnalazione del committente)

Il committente ha riletto e ha indicato la direzione: i testi dei
Consigli erano «un po' strani» — troppo piatti per essere letti ad alta
voce — e vanno resi più comprensibili e più «aulici fantasy». Sono i
testi più esposti del gioco: la proposta la **pronuncia** il proponente
davanti al tavolo.

**La regola di stile**: una proposta è una *mozione*, e parla al
congiuntivo esortativo — «Si levino i banchi e si portino dove le mura
sanno difenderli», «Il grano sia requisito in nome del trono», «Quando
l'accordo manca, si tiri a sorte; e la sorte sia scritta». Gli esiti
restano cronaca al passato remoto, con le due segnalazioni riscritte
per immagine: «ogni sbarra tenne la propria tariffa, e la strada restò
dei tanti esattori»; «dove andarono le merci, là passò anche il
comando». 34 riscritture, più 22 code di passato remoto senza accento
trovate rileggendo («passò sotto il sigillo», «Si stabilì», «ripeté»).

Suite, simulazioni, export e brief riallineati e verdi. I testi buoni
(«Due titoli sono due guerre che aspettano», «Si tolga la pietra») non
si toccano: la passata alza il pavimento, non pareggia il soffitto.

---

## D-099 — La revisione dei testi: gli accenti tornano, le regole escono dal racconto
**implemented in 0.1.57** (chiude ISSUES voce 13, su delega del committente)

Prima lettura di fila di tutti i 661 testi del gioco, dal tavolo di
lettura della 0.1.56. Due difetti sistematici e una manciata di code:

**Gli accenti non c'erano.** I testi erano in ASCII puro fin dalla 0.0:
«piu», «citta», «la cosa e seria», «il consiglio lascio cadere». Restaurati
ovunque — 357 righe corrette su 17 file — in tre passate: la mappa delle
parole certe (più, città, può, c'è, già, perché…), i pattern verbali
sicuri («e al limite» → «è al limite», «si e » → «si è », «TEN_X e in
gioco» → «è in gioco»), e **125 + 16 coppie esplicite col loro contesto**
per le copule e i passati remoti che una regola cieca sbaglierebbe
(«il consiglio lasciò cadere», «la porta restò dov'era», «Salì al trono»,
«estrarlo è estrarre qualcosa di vivo»). Ogni occorrenza di «e» nuda è
stata classificata a occhio, due censimenti completi (520 poi 317
occorrenze): quello che resta è congiunzione legittima.

**Le regole erano finite nel racconto.** Il caso segnalato dal
committente: la descrizione del Risveglio diceva *«Velata: i giocatori
vedono i presagi, non il numero. Solo SCHEME apre il valore»* — gergo di
motore in un campo narrativo. La velatura è un dato (`visibility`), e
adesso è **la carta a dichiararla da sé** («domanda velata · survival»
nel sottotitolo, motore, D-035-style); le due descrizioni colpevoli
(TEN_AWAKENING, TEN_ROADS) sono tornate racconto: *«Qualcosa si è mosso
sotto le Miniere, e nessuno sa dire quanto manca. Si vedono i segni, non
la misura.»* Le Azioni invece restano com'erano: quelle *sono* carte
regolamento, e il loro posto è quello.

Verificato: suite intatta (215 test, 4518 asserzioni — nessuna guardia
citava i testi corrotti), validazione, simulazioni, export e manifesto
rigenerati. La voce 13 chiude sul suo «fatto quando»: i testi sono stati
letti dall'inizio alla fine e le correzioni sono nei JSON — il diff è la
lettura, e il committente può obiettare riga per riga.

---

## D-098 — La seconda leva: la proposta bocciata non compra quiete
**implemented in 0.1.55** (chiude la 0.2: era l'ultima voce)

Bloccare era ancora il seggio più forte, e la voce di ROADMAP chiedeva
«un prezzo sul fronte Oppose, misurato prima di scriverlo». Misurato — e
per strada si è chiarito un equivoco: la prima leva (l'oppositore non
recupera la carta, ISSUES 1) **era già nei dati** di tutte le Chronicle,
e la manopola che sembrava inerte la stava reimpostando sul valore che
già aveva. Il prezzo sul portafoglio c'era già; quello che mancava era
il prezzo sulla **rendita**.

### La rendita del blocco, e la regola

Una proposta affondata sfogava la domanda di −2 (appendice A6): il
blocco comprava quiete — la questione si allontanava dalla soglia e il
mondo restava com'era, che è esattamente ciò che i Destini del bloccante
vogliono. Da questa versione `confluence_rules.failure_delta = -1` in
tutte le Chronicle: la domanda bocciata resta vicina alla soglia e
**torna prima**. In armonia con D-077 (la domanda resta sul tavolo) e
D-094 (il conto resta aperto): dire di no non chiude niente.

### Misurato (tavolo misto, stessi 100 semi, 7000-7099)

| | −2 (prima) | **−1 (adottata)** | 0 (respinta) |
|---|---|---|---|
| aggressivo N/M/V/T | 2/33/**63**/2 | 6/32/**60**/2 | 4/32/**62**/2 |
| prudente N/M/V/T | 0/61/35/4 | 1/63/34/2 | 3/63/31/3 |
| distratto (Vittorie) | 46 | **53** | 54 |
| divario aggressivo−prudente | 28 | **26** | 31 |
| Consigli media / mediana | 5.85 / 6 | 5.97 / 6 | 6.02 / 6 |
| bloccati al tavolo misto | 0/8 | **0/8** | 0/8 |

Il gradino oltre (0: nessuno sfogo) è **respinto coi numeri**: la
domanda ribolle subito, il bloccante blocca di nuovo e risale a 62 — il
ginocchio della curva è a −1. Il prezzo vero della leva non è tanto le
tre Vittorie in meno quanto il rischio: i NONE dell'aggressivo passano
da 2 a 6 — bloccare può costarti l'anno — e i Consigli recuperati vanno
al centro del tavolo (distratto 46→53). La storia del divario: 37 (prima
di D-069) → 31 → 28 → **26**.

Effetto collaterale misurato e giusto: il piano scriptato «il consiglio
spezzato» ora ha una coda — la questione bocciata due volte torna ai
voti una quarta, che passa (attese del piano aggiornate). Sulle saghe:
sonde stabili (74%/74%), il calore ereditato sale un poco (72 calde su
720: le domande sfogano meno), `question_unresolved` letterale a 4/20.

---

## D-097 — Il formato fisico: tre taglie di carta, token e segnalini
**implemented in 0.1.54** (chiude ISSUES voce 7, decisione del committente)

La voce 7 aspettava tre scelte di produzione, e il committente le ha
date: **formati diversi per ruolo**, **mappa unica** (già fatta), **valori
su token e segnalini**. Questa versione le implementa nell'export, così
la decisione non resta un appunto: si stampa.

### Le taglie

| formato | mm | per foglio | mazzi |
|---|---|---|---|
| classica | 63×88 | 3×3 | Asset, Echo — si mescolano, stanno in mano |
| tarocco | 70×120 | 2×2 | Destini, Casate — identità sempre in vista |
| mini | 44×68 | 4×4 | Domande — si appoggiano alla traccia dei valori |
| tessera | 80×80 | 2×3 | Regioni — la mappa, che resta com'è |

`print_sheet` ora ha una tabella dei formati (`SHAPES`) invece di due
costanti; l'impaginazione, i segni di taglio e l'anteprima F4 seguono da
sé. La guardia che chiede a ogni carta se il suo testo ci sta è passata
su tutte le taglie al primo colpo (719 asserzioni).

### I segnalini

`token_sheet.gd`, due fogli nuovi in coda al fascicolo PDF:

- **la fustella** (una per saga, 15 mm): per ogni casa sei tondi pieni di
  presenza e sei anelli di controllo — sei Regioni, il pezzo in più non
  esiste (§19.4) — più i rombi del valore e il quadrato del Drift;
- **la traccia dei valori**: quattro corsie 0–8, il posto della carta
  mini a sinistra, la regola della soglia scritta sul foglio. La soglia
  sta sulla carta perché cambia da domanda a domanda.

Deterministico byte per byte come tutto l'export. COMPONENTS §7 riscritta
da lista di domande a decisione, come chiedeva il «fatto quando»; alla
0.6 restano tablet-contro-telefoni e scatola-contro-espansioni.

---

## D-096 — Il libro della saga: la Timeline in apertura, poi i capitoli
**implemented in 0.1.53** (con D-095 completa la parte in-app della 1.0 dichiarata)

D-095 ha messo la saga davanti a chi gioca; questo le da' il suo libro.
Il Chronicle Book impaginava un anno alla volta (D-086) — giusto per una
partita secca, monco per una saga: dieci ere giocate in fila uscivano
come dieci libri separati, senza la vista che le tiene insieme.

### La regola

`ChronicleBook.saga_pages(saves, data)`: in apertura la **Timeline** —
un anno per voce, con il salto («Anno 904, 92 anni dopo — …»), chi
sedeva e com'è finita in breve (niente / il minimo / la vittoria / il
trionfo) — e poi la cronaca di ogni anno, capitolo per capitolo, con le
stesse identiche pagine di D-086. Con un anno solo il libro della saga
*è* il libro di sempre, per costruzione (`saga_pages([x]) == pages(x)`).

Nell'app: `game_screen` tiene la fila degli anni giocati
(`_saga_saves`, azzerata quando dal menu comincia una storia nuova), e
il bottone «La cronaca» mostra il libro intero appena la saga ha più di
un anno. Il piè di pagina dice cosa si sta sfogliando — «la saga, anni
812 – 1804» — e la vista è la stessa rasterizzazione di sempre: quello
che si vede è quello che si stamperà.

Della 1.0 restano ora la campagna Legacy vera e propria e le rifiniture
d'autore; la triade motore–gioco–libro della saga è chiusa.

Guardie: `test_chronicle_book` (la Timeline conta il salto, nomina chi
si è seduto e come è finita; le cronache seguono in ordine; un anno solo
dà il libro di sempre).

---

## D-095 — La saga si gioca: l'era successiva si offre a fine anno
**implemented in 0.1.52** (il primo pezzo mancante della 1.0)

Il motore della campagna esisteva ed era misurato su migliaia di ere, ma
viveva solo in riga di comando: nell'app si giocava un anno alla volta, e
la parte più caratteristica del gioco — il tempo che passa, gli eredi, il
verbale d'apertura — un giocatore non la vedeva mai.

### La regola

A fine anno, se l'età ha una biblioteca, lo schermo lo offre: *«L'anno è
chiuso, ma il mondo no. Il tempo passa.»* Chi accetta gioca l'era
successiva nella stessa seduta: la nuova sessione eredita il mondo e i
risultati appena chiusi (`inherit_from`, lo stesso identico percorso di
`run_saga`), il transcript continua — il verbale d'apertura compare in
testa al nuovo anno — e il seme avanza del passo delle sonde (+97), così
una saga giocata a mano è riproducibile come una simulata.

Quale Chronicle prosegue quale età lo dicono i dati, una volta sola:
`DataSet.library_sequel_of` — la biblioteca che siede **lo stesso tavolo
di Entità** (CHR_01→CHR_02, CHR_03→CHR_04; una biblioteca prosegue se
stessa; un'età senza biblioteca chiude la saga). È il criterio che
`run_saga` usava da sempre, scritto nel posto giusto invece che in ogni
chiamante.

Restano dichiarate, per la 1.0: la **Timeline** dei secoli e il **libro
dell'intera saga** (il Chronicle Book copre l'anno singolo).

Guardie: `test_library_content` (ogni età sa chi la prosegue, nei due
sensi e col caso vuoto); `game_screen` compila headless; l'autosave a
ogni round vale anche per gli anni-biblioteca, quindi la ripresa (D-052)
copre anche una saga interrotta.

---

## D-094 — La spirale del fallimento si chiude ri-decidendo
**implemented in 0.1.51** (scioglie il debito residuo della voce 18)

D-085 aveva circoscritto il debito: «Il Regno che Ricorda» restava
strozzato dalla propria Victory. La misura d'apertura (20 saghe, ere in
cui il seggio giura quel Destino) ha dato il colpevole: su 91 ere, la
Victory moriva **74 volte per `question_unresolved`** e solo 7 per il
solo controllo. Il tag era un'asimmetria: **qualunque** proposta caduta
lo scriveva (CNS_FAILURE_SPIRAL) e **niente** lo toglieva mai — nemmeno
ri-decidere la stessa domanda, che è esattamente ciò che D-077 tiene sul
tavolo. Il registro restava in colpa a questione decisa.

### Le due metà, misurate una alla volta

**A — la via del riprendere** (contenuto, la forma di D-085):
`P_RETAKE_QUESTION` su Q_SUCCESSION_LAW, eleggibile col segno sul mondo;
il successo è `CNS_QUESTION_RETAKEN` — `REMOVE_GLOBAL_TAG
question_unresolved` col prezzo della domanda che torna calda (+2 su
`$tension`). Da sola: ai voti 18 volte su 200 ere, tutte a buon fine, ma
Victory ferma (6) — la via è giusta e stretta.

**B — il conto dell'era** (motore): `world_state.open_failures` tiene le
Tensioni cadute in quest'era e non ancora ri-decise; quando l'ultima si
decide, la spirale si chiude e il tag si toglie con un Effect di
sistema, a registro. Il segno **ereditato** da un'era prima invece non
si chiude per caso: nessun conto di quest'era lo riguarda, e lo scioglie
solo la via A — un conto di un'altra generazione non si salda per
sbaglio.

### Misurato (20 saghe da 10 ere, semi 812+1009k)

| | prima | dopo A | dopo A+B |
|---|---|---|---|
| VICTORY / TRIUMPH (su ere giurate) | 6 / 4 su 91 | 6 / 5 su 92 | **16 / 7 su 84** |
| sopra il Minimo | 11% | 12% | **27%** |
| ere che chiudono col tag | 140/200 | 140/200 | **75/200** |
| `question_unresolved` letterale all'ultimo anno | 18/20 saghe | — | **5/20** |
| la Victory muore per: solo tag / solo controllo | 39 / 7 | 28 / 13 | **14 / 24** |

La Victory adesso è limitata quasi equamente dalle sue due clausole
invece che strozzata da una. Playtest sugli stessi 100 semi: **0/8
bloccati al tavolo misto** (4/8 uniforme), Consigli in banda; sonda
delle ere sana (D-079 74%, D-087 74%, D-088 64/10). Il tag resta vivo
come contenuto: 75 ere su 200 chiudono ancora in colpa.

Guardie: `test_questions_asked` (la spirale si chiude ri-decidendo; il
segno ereditato non si chiude per caso).

---

## D-093 — La voce 2 si chiude senza scrivere template: i numeri dicono che non servono
**recorded in 0.1.50** (chiude ISSUES voce 2)

La voce chiedeva «tre-cinque template di Confluence in più» contro la
ripetizione al tavolo. Era già stata ridimensionata due volte dalle
misure (D-061: metà delle domande scritte non veniva mai posta; D-063:
il problema vero era il diritto di proporre, fatto in D-069). Questa è
la terza misura, ed è quella che chiude: **ogni proposta scritta vive
dove vive**, e la ripetizione ha già tre rimedi strutturali che nel
frattempo sono entrati.

### I numeri (sonda delle scelte a tavolo misto, 40 anni, semi 2000; saghe: 20 da 10 ere, semi 812+1009k)

- **CHR_01, anno singolo**: 15 proposte su 18 ai voti. Le 3 fuori sono
  tutte contenuto d'era che un anno primo non può avere:
  `P_REOPEN_THE_MINE` e `P_ONE_CROWN` (D-085: **21 e 4 volte su 200
  ere**), `P_HEIR_AS_STORY` (D-076: **32 volte su 20 saghe**).
- **CHR_03, anno singolo**: 17 su 19 (erano 14 su 20 ai tempi di D-063,
  su un corpo più piccolo). Le 2 fuori: `P_OLD_PAGE`, che è contenuto
  d'era (**8 volte** sulle saghe della sua era), e `P_SHOW_IT`, che
  nell'anno primo non esce perché la domanda della teca si apre tardi —
  e sulle saghe va ai voti **88 volte su 20**.
- **Nessuna proposta a zero** dove il suo contenuto vive: il conteggio
  completo sulle 20 saghe CHR_03→CHR_04 va da 3 (`P_BURY_IT`) a 158
  (`P_CALL_IT_IN`), e persino le morte storiche di D-063
  (`P_DIG_FOR_HIRE`: **31**) sono resuscitate col tempo delle ere.

### Perché non si scrive

La paura della voce era la ripetizione: «le domande sono la parte che si
vede di più, ed è quella che si ripete prima». Nel frattempo sono
entrati la biblioteca che pesca l'anno (D-028: ogni era è una mano
diversa), la domanda decisa che resta decisa (D-077: niente repliche
nello stesso anno) e il contenuto d'era che entra solo quando la storia
lo chiama (D-076/D-085). Aggiungere template adesso sarebbe contenuto
senza bisogno misurato — e ogni misura di questo progetto dice che il
contenuto in più che nessuno chiede finisce nella colonna dei morti di
D-035. La banda resta guardata da `test_balance` e
`test_library_balance`; se un giorno il tavolo umano troverà ripetitivo
quello che le policy non trovano ripetitivo, quella sarà una
segnalazione nuova, con la sua misura.

---

## D-092 — Il browser dice se sa tenere il salvataggio (e lo fa scaricare)
**implemented in 0.1.49** (chiude ISSUES voce 12)

Il Web export tiene `user://` in IndexedDB e la guardia c'era
(`OS.is_userfs_persistent()` già proteggeva la ripresa, D-052) — ma una
partita persa perché il browser ha pulito lo spazio restava una partita
persa **in silenzio**. La voce 12 chiedeva due cose, e sono entrate
tutt'e due:

**La schermata lo dice prima di cominciare.** Nel browser, il menu apre
con una riga: se lo storage c'è, «i salvataggi restano in questo
browser»; se non c'è (navigazione privata, storage bloccato), l'avviso a
colore dice che chiusa la scheda la partita sparisce — e la stessa rete
si tende a fine anno, nel momento in cui serve davvero. Fuori dal
browser, niente: non c'è rischio da dichiarare.

**E offre di scaricarlo.** Un bottone «Scarica il salvataggio» accanto a
«Scarica il log»: la partita in corso (o l'anno appena finito) come JSON,
per la stessa via del log — `JavaScriptBridge.download_buffer` nel
browser, `user://` altrove. `LogExport.deliver` ha imparato il MIME (i
suoi messaggi ora sono neutri: per di lì passa anche un salvataggio),
`SaveSerializer.download_name` dà il nome con chronicle e seme dentro —
`echoes-salvataggio-chr-01-7042.json` — perché un file che non dice quale
mondo è, è un file che non si ritrova.

Guardie: `test_snapshot_and_save` (il nome è onesto nei due casi),
`test_log_export` invariato sul contratto di consegna. Il round-trip del
JSON era già coperto («risalvare produce lo stesso identico testo»).

---

## D-091 — `marker_id` esce dal modello dati (e rientrerà con chi lo legge)
**implemented in 0.1.48** (chiude ISSUES voce 11)

Ogni Regione, Entità, Asset e carta Echo portava un `marker_id` nello
schema — l'aggancio fiducial per il prototipo di computer vision della
0.5 — e nessuna riga di codice l'ha mai letto. La voce 11 dava due vie:
o il prototipo lo usa, o il campo si toglie. Il prototipo è a due
milestone di distanza; il campo si toglie.

Il criterio è D-035 applicato ai dati: un campo che nessuno legge è un
campo che nessuno mantiene — quattordici valori da tenere allineati a
mano per un lettore che non esiste ancora. Ed è una scelta **reversibile
a costo zero**: i valori erano meccanici (`MK_<id>`), si rigenerano in un
minuto quando il prototipo 0.5 esisterà e dirà che forma di marker gli
serve davvero — che è anche il momento giusto per deciderla, non prima.

Tolto da: `region`/`entity`/`asset`/`echo_card` negli schemi, i tre file
dati che lo valorizzavano, la colonna del manifest, e la riga di ROADMAP
0.5 ora racconta la storia. Suite e validazione intatte.

---

## D-090 — Il verbale della mappa: come si piazza l'era nuova
**implemented in 0.1.47** (estensione di D-089, su richiesta del committente)

D-089 aveva dato voce alla metà delle domande; la mappa restava muta — si
piazzava per eredità (D-075/D-078/D-027) e il tavolo doveva ricostruire da
sé cosa il tempo le aveva fatto. Il committente ha chiesto il pezzo che
mancava: il verbale dice anche come si piazza la mappa.

### La regola

`map_record` è derivato dagli **stessi `inheritance_effects` che la
piazzano davvero** — una sola fonte di verità, quindi il verbale non può
mentire sul tavolo — più i default di fabbrica per le Regioni che
l'eredità non tocca. Per ogni Regione: chi la tiene (coi nomi dell'era
nuova: il seggio continua, la persona no), se è **decaduta** perché chi la
teneva non c'era (D-027), i **segni** che porta
(`structure:`/`settlement:`/`scar:`/`condition:`), e le **condizioni
sbiadite** dal salto (D-078). In coda: i fatti diventati **leggenda** su
questo salto (D-075) e quanti **rapporti** hanno fatto un passo verso
l'indifferenza (D-045). Nel mondo come `world_state.map_record` (schema
esteso), nel log sotto il verbale delle domande, in `run_saga` sotto
«La mappa che si eredita»:

> Terre Nahr a Popolo Nahr. 'condition:mourning' è sbiadito: non è più
> in corso. · Miniere Antiche a nessuno. · Non più fatti, ma leggende:
> 'order_restored', 'question_unresolved'. · 2 rapporti fanno un passo
> verso l'indifferenza: la guerra si ricorda come rancore.

E una correzione di tempo verbale alla metà delle domande: i segni
passano all'**imperfetto** («il mondo ne portava il segno») perché la
pesca legge il mondo com'era alla chiusura, e il salto può averli
sbiaditi subito dopo — la riga della mappa dice come stanno adesso. Le
due metà del verbale non possono più contraddirsi.

### Misurato

Solo lettura come il resto del verbale: suite e sonda delle ere identiche
riga per riga (574/790, 237/317, 66/14 su 720). Guardie nuove in
`test_library_content`: chi c'era tiene, chi non c'era decade, il lutto
sbiadisce a 120 anni e resta in corso a 20, il fatto eterno non diventa
leggenda, il rancore si conta — e ogni riga di prosa si legge.

---

## D-089 — Il motore 0.3, Fase 3: il verbale d'apertura
**implemented in 0.1.46** (milestone 0.3, chiude ISSUES voce 9)

Il motore sapeva *perché* pescava — i segni (D-079), i conti aperti
(D-087), il calore (D-088) — ma il perché moriva dentro la pesca: il
tavolo vedeva la mano e non la memoria che l'aveva scelta. La generazione
funzionava ed era illeggibile.

### La regola

All'apertura di un'era ereditata, per ogni domanda in mano il mondo
registra chi l'ha richiamata: il segno che porta (fatto, leggenda, o tag
di Regione — nominato per nome), il conto rimasto aperto (con il nome del
seggio dell'era prima che l'ha lasciato), o niente — la biblioteca, il
caso. E con che valore riparte, quando non è quello d'autore. Il record
sta in `world_state.opening_record` (schema esteso), la prosa in testa al
log del tavolo e nel digest di `run_saga`:

> La Carestia torna: Re Aldric non l'ha mai chiusa; Popolo Nahr non l'ha
> mai chiusa. · Il Risveglio torna: il mondo ne porta ancora il segno
> ('mine_sealed'). · I Pozzi Bassi esce dalla biblioteca: il caso, non la
> memoria.

Solo lettura, per costruzione: `opening_record()` non pesca, non tira e
non tocca il mondo. `_era_carries_any` è diventato il bordo di
`_carried_mark` (stesso ordine di visita, quindi stessa pesca bit per
bit) e `_open_accounts` restituisce *chi* ha lasciato ogni conto, non
solo che esiste — la pesca continua a usarlo con `has()`.

### Misurato

Determinismo intatto sugli stessi semi: playtest a tavolo misto invariato
(0 seggi bloccati su 8), sonda delle ere identica alla 0.1.45 riga per
riga (66 calde / 14 quiete su 720, richiamate D-079 al 72%, conti D-087
al 74%). Il verbale legge, non gioca.

Guardie: `test_library_content` (il record nomina segno, conto e calore
con i numeri giusti; due costruzioni danno lo stesso verbale; un anno
scritto non verbalizza).

Con questa fase le quattro dichiarate del cantiere (D-087) sono fatte, e
il criterio della voce 9 è soddisfatto: da una Chronicle conclusa esce
una Chronicle nuova con domande scelte dalle conseguenze della prima — e
adesso lo dice ad alta voce.

---

## D-088 — Il motore 0.3, Fase 2: la domanda lasciata calda torna calda
**implemented in 0.1.45** (milestone 0.3, ISSUES voce 9)

I valori di partenza delle Tensioni pescate erano sempre quelli d'autore:
un'era poteva chiudere con la Carestia al limite e la successiva ricominciare
da tre, come se il tempo resettasse le questioni oltre che le persone.

### La regola

Il confine è quello della memoria (D-075), e non ne serve uno nuovo:

- **salto breve** (sotto i 50 anni): una Tensione ripescata riparte da dove
  l'era prima l'ha lasciata — ma mai già a soglia: torna **tiepida**, non
  bollente (tetto a soglia−1), perché l'era comincia prima del bollore.
- **salto lungo**: il calore sbiadisce come tutto il resto, e si riparte dal
  valore d'autore.
- una questione chiusa bene può ripartire anche **più quieta** di com'è
  scritta: la quiete è un'eredità quanto il fuoco.

`inherited_tension_value()` è una funzione pura, testata direttamente.

### Misurato (20 saghe da 10 ere)

Su 720 domande pescate, **66 partono più calde e 14 più quiete** del valore
d'autore — l'11% delle domande d'era porta il calore di quella prima,
concentrato sui salti brevi (che sono ~1 su 5). Salti, rotazioni,
stanchezza, pesca che ascolta e conti aperti invariati; la guardia degli
anni-biblioteca (D-080) resta verde.

Guardie: `test_library_content` — lasciata a soglia torna a soglia−1, su un
secolo sbiadisce, chiusa bene riparte quieta, mai vista riparte d'autore.

---

## D-087 — Il motore 0.3, Fase 1: l'era dopo nasce dai conti rimasti aperti
**implemented in 0.1.44** (milestone 0.3, ISSUES voce 9)

`destiny_results.evidence` registrava *come* ogni obiettivo era stato
raggiunto «proprio per questo passaggio» (ROADMAP 0.3) — e nessuno lo
leggeva. La sonda di apertura del cantiere (Fase 0) ha misurato cosa c'è:
**un'era lascia in mediana 9 clausole negate** (da 5 a 13), e 2,3 a era
nominano una Tensione precisa via `tension_limit` — la Carestia sopra
tutte (88 su 228 in 100 ere).

### La regola

Le evidence diventano dati: ogni risultato di Destino porta ora `unmet` —
le clausole negate, come dizionari e non come prosa. E la pesca le legge:
una candidata nominata da una clausola `tension_limit` negata nell'era
prima è un **conto rimasto aperto**, e pesa il triplo nella pesca — lo
stesso peso di un segno sul mondo (D-079). Il conto chiama anche se la
casa nel frattempo ha cambiato ambizione: la storia preme sull'era, non
sull'erede.

### Misurato (20 saghe da 10 ere)

Le candidate richiamate da una clausola negata vengono pescate il **75%**
delle volte (260 su 343), contro il 67% della pesca cieca; i segni di
D-079 stanno al 73%. Rotazioni, stanchezza, generazioni e mani di domande
invariati; il playtest non incatena ere e resta intatto per costruzione.

Guardie: `test_destiny_evaluator` (le clausole negate escono come dati, e
un conto chiuso sparisce), `test_library_content` (il conto aperto pesa
nella pesca, misurato su cento semi, e la pesca resta deterministica).

### Le fasi che restano dichiarate

- **Fase 2 — la domanda lasciata calda torna calda**: ~~i valori di
  partenza~~ **fatta in 0.1.45** (D-088).
- **Fase 3 — il verbale d'apertura**: ~~l'era nuova sa *perché* ha
  pescato le sue domande~~ **fatta in 0.1.46** (D-089).

---

## D-086 — La cronaca dell'anno: le Verità diventano pagine
**implemented in 0.1.42** (la metà export di ISSUES voce 10)

Le Verità sono l'unico pezzo di carta che il gioco **produce** invece di
consumare (COMPONENTS §6), e a fine anno vivevano solo nel log. Adesso un
salvataggio si impagina: `cli/run_chronicle_book.gd` legge un
`session.to_save()` qualsiasi — un piano scriptato, l'hotseat, un anno di
saga — e scrive le pagine A4 della cronaca: l'anno in testa, le Verità in
ordine atto per atto (senza il prefisso di registro «Anno N, Atto M», che
sulla pagina è già scritto sopra), e in fondo come è finita per ogni seggio.

Stesso linguaggio dei fogli di stampa (`print_sheet.gd`): A4 in millimetri,
la carta scura del set, il testo mandato a capo a mano, serif per l'anno.
È il seme del Chronicle Book della 1.0 — un anno per capitolo. La metà
**app** della voce 10 (la schermata di fine Chronicle) resta per la 1.0,
ed è annotata nella voce.

Guardie (`test_chronicle_book.gd`): ogni Verità scritta finisce sulla
pagina, le pagine sono A4 veri e numerati, ottanta Verità si spezzano in
più pagine invece di uscire dal foglio, e un anno muto lo dice.

### La metà app (0.1.43) — e la voce 10 si chiude

A fine Chronicle la cronaca **si vede**: `ui/chronicle_book_view.gd` si
apre da sola quando l'anno finisce, con le frecce per sfogliare e il
bottone «La cronaca» per tornarci — il salvataggio resta nello schermo
anche dopo il congedo della sessione, come il seme. La vista rasterizza
**le stesse pagine SVG** che il Chronicle Book stamperà (la disciplina
dell'anteprima di stampa, D-056): quello che si vede al tavolo è quello
che uscirà dalla stampa, non una cosa che gli somiglia. Guardia: ogni
pagina generata deve rasterizzarsi (`test_every_page_rasterizes_for_the_screen`).

---

## D-085 — Le vie per disfare i fatti eterni: riaprire la miniera, riunire la corona
**implemented in 0.1.40** (chiude ISSUES voce 18)

D-082 aveva lasciato a verbale il reperto: un fatto in `enduring_facts` usato
come condizione di **assenza** rende un Destino tardivo sempre più morto man
mano che la saga invecchia — la corona spezzata nell'850 bloccava «Il Regno
che Ricorda» per mille anni, la miniera murata faceva lo stesso con la
scuola. Delle due opzioni d'autore registrate, è entrata la più ricca:
**una via per disfare il fatto, a un Consiglio, pagando un prezzo.**

### Cosa è entrato

- **`P_REOPEN_THE_MINE`** sul Consiglio del Risveglio, eleggibile solo con
  le gallerie murate → `CNS_MINE_REOPENED`: il fatto eterno si rimuove, e il
  prezzo è che **il Risveglio sale di 2** — riaprire sveglia quello che
  dormiva.
- **`P_ONE_CROWN`** sul Consiglio della Successione, eleggibile solo con la
  corona divisa → `CNS_CROWN_REUNITED`: il titolo torna uno, e il prezzo è
  un rapporto che precipita a OSTILE — chi ha perso la conta non ringrazia.
- **Il ramo del pianificatore che disfa**: `_consequences_satisfying`
  soddisfa una clausola `state_tag_absent` anche con la Conseguenza che
  RIMUOVE il tag. Il punteggio al voto capiva già le assenze (D-066); era il
  pianificatore a non avere nessun Consiglio da inseguire quando il fatto
  c'era già.

### Misurato (20 saghe da 10 ere, corona)

| | prima | dopo |
|---|---|---|
| gallerie riaperte / corona riunita | 0 / 0 | **21 / 4** ere su 200 |
| DST_LYRA_TAUGHT | 92 MIN · 6 VIC · 0-2 TRI | 71 MIN · **20 VIC** · **3 TRI** |
| DST_ALDRIC_RECORD | 91 MIN · 2 VIC · 1-2 TRI | 91 MIN · 3 VIC · 1 TRI |

La scuola risorge; il Regno che Ricorda resta strozzato dalla **propria
Vittoria** (controllo di 2 Regioni + nessuna questione aperta), che il
disfare non tocca — è il debito residuo della voce 18, ora circoscritto a
un Destino solo. Playtest: 0/8 bloccati al tavolo misto, anno scritto
invariato. La riapertura può accadere anche nell'era del murare — murata
all'atto primo, riaperta al terzo — ed è giusto così: una decisione presa
male si può ridiscutere, a prezzo pieno.

---

## D-084 — Il quinto MASTER PROMPT: i Destini sono nature morte del desiderio
**implemented in 0.1.39** (su richiesta del committente, per il brief d'arte)

L'inventario dei componenti grafici ha trovato le carte Destiny nella stessa
situazione in cui D-065 trovò i ritratti: **12 chiavi d'arte nei dati, nessun
MASTER PROMPT, nessuna voce nel brief** — e 4 Destini della corona senza
nemmeno la chiave.

### La direzione

La carta Destiny è l'unico pezzo che un giocatore guarda da solo, dietro il
paravento: è la *sua* ambizione vista coi suoi occhi, e in quella
inquadratura non c'è nessuno — c'è **la cosa**. Quindi niente volti: un
oggetto, un luogo, una soglia, composti come un'immagine votiva. Il set
resta leggibile a colpo d'occhio: gli Asset sono scene con gente dentro, le
Casate sono ritratti (regola 3), i Destini sono nature morte del desiderio.

La variation key è l'**archetipo di chi desidera**, con gli stessi accenti
del MASTER PROMPT 4: il Destino di una casa porta il colore della casa, e le
due carte del pool — l'ambizione di partenza e quella dopo — sono due quadri
della stessa parete.

### Cosa è entrato

- MASTER PROMPT 5 in `ART_BIBLE.md`, con la tabella per archetipo;
- le 4 chiavi mancanti (`destiny.aldric.record`, `destiny.nahr.rooted`,
  `destiny.lyra.taught`, `destiny.vaerax.watched`);
- il mazzo `destiny` collegato al brief (`art_bible.gd`) e la faccia che
  porta la propria chiave (`card_face.gd` — non la esponeva);
- il brief passa da 101 a **117 prompt**.

---

## D-083 — Il contenuto senza elettorato si toglie: due tagli e una variante respinta
**implemented in 0.1.38** (scelta del committente: «riscriverle o toglierle»)

La disciplina D-035 — una voce a zero è contenuto che non esiste — aveva due
imputati cronici in CHR_03/04, e la sonda ha detto perché nessuno dei due
era un incidente:

- **`P_WATER_RIGHTS`** («l'acqua risponde a chi la paga»): il seggio che
  tiene la parola sulla Valle sono le Città Libere, e il loro Destino vuole
  `water_priced` **assente** — l'opzione era il cattivo della questione, e i
  poteri locali la tenevano fuori dal tavolo per costruzione. La cura
  provata coi numeri — `CNS_WATER_PRICED` salda anche un debito, perché chi
  propone abbia un motivo — non ha mosso niente: **0 scelte su 23 offerte**,
  identico a prima. Respinta, e la proposta è **tolta**: la domanda
  dell'acqua resta con la risposta comune, che è viva (23/23).
- **`Q_ANY_ANCIENT_LEAVE` / `P_ANY_WITHDRAW`** («si smette di scendere»):
  i Consigli jolly di quest'era si aprono dal pavimento di fine anno, a
  questione fredda — la soglia di eleggibilità non scatta mai (1 posa su
  76 aperture attraverso tutte le sonde), e abbassarla a 2 non ha cambiato
  niente (0 su 16). E il ritiro non ha un solo elettore: la Cenere vuole la
  montagna calda, il Priore odia lo svuotamento. **Tolti** domanda e
  proposta; la veglia e l'ignorare restano vivi (9/7 su 16).

`CNS_ASH_ABANDONED` resta raggiungibile da `P_DIG_BELOW`. Dopo i tagli, il
«mai ai voti» di CHR_03 passa da 7 proposte su 21 a **2 su 19**, ed
entrambe le superstiti hanno una ragione dichiarata: `P_OLD_PAGE` è
eleggibile solo nelle ere con una memoria (5 voti misurati nelle saghe
delle città), `P_SHOW_IT` vive su altre serie di semi (2-6 voti).

---

## D-082 — La memoria come posta: un Trionfo che nomina la leggenda scritta
**implemented in 0.1.37** (scelta del committente: «posta nei Trionfi»)

Le leggende coloravano il mondo e nessun Destino le nominava: si poteva
vincere una saga intera ignorando la memoria. Adesso un Trionfo per saga la
chiede: **DST_NAHR_ROOTED** (corona) e **DST_SALE_OPEN** (città) domandano
anche `discovery:legend` — aver *messo per iscritto* la leggenda dell'era,
che è la cosa su cui un giocatore può agire in anno (le proposte «si dice
che», D-076).

### Il viaggio: tre collocazioni respinte coi numeri

La posta è stata provata su quattro Destini, e la misura ha scelto:

| collocazione | trascrive? | Trionfo | perché no |
|---|---|---|---|
| DST_ALDRIC_RECORD («il Regno che Ricorda») | 12 ere | 2→0 | la Vittoria è morta di suo (2/97): la cumulatività strozza qualsiasi Trionfo |
| DST_VAERAX_WATCHED | **0** ere | 59→0 | sotto la montagna la parola non arriva: non può proporre di scrivere |
| DST_LYRA_TAUGHT | 19 ere | 2→0 | in 17 ere su 19 la miniera è murata — e `mine_sealed` è un fatto **eterno** |
| **DST_NAHR_ROOTED** | **12 ere** | 29→**4** | il popolo ha la parola sui Consigli di sopravvivenza, e la sua storia la racconta davvero |

Il Trionfo del popolo scende da quasi-automatico (29/87) a raro e conteso
(4/87), con la Vittoria che assorbe il resto (32→38): è la forma giusta di
un Trionfo. Nelle città la Gilda trascrive in 10 ere su 50 e il suo Trionfo
resta vivo (1).

### La strada, perché la posta fosse raggiungibile

Nella corona il «mettere per iscritto» passava solo dal Consiglio jolly, che
apre di rado: la sonda dava **0 trascrizioni in 153 ere**. È entrata
`P_HEIR_AS_STORY` sul Consiglio della Successione — «si nomini chi la
ballata nomina, e stavolta lo si scriva» — ineleggibile finché la leggenda
non esiste, quindi l'anno scritto è intatto per costruzione. Misurata:
votata 32 volte in 20 saghe, e trascina anche P_ANY_AS_STORY da 4 a 23.

### Il reperto, più grande della posta

**Un fatto eterno usato come condizione di assenza uccide i Trionfi tardivi.**
`crown_divided` e `mine_sealed` sono `enduring_facts`: una volta accaduti
restano per la saga, e ogni Destino di seconda rotazione che ne pretende
l'assenza muore man mano che il mondo invecchia — è così che la Vittoria di
ALDRIC_RECORD sta a 2/97 e quella di LYRA_TAUGHT resta murata fuori.
Registrato in ISSUES: è lavoro d'autore sui Destini, non una toppa.

---

## D-081 — L'iniquità del tempo: un erede non giura sull'ambizione che ha visto fallire
**implemented in 0.1.35**

La rotazione dei Destini (D-045) premiava solo chi ottiene: chi vinceva
cambiava ambizione, chi falliva riprovava la stessa — **per mille anni**.
Misurato su 20 saghe della corona: Aldric macinava lo stesso Destino
per un'intera saga in **6 su 20**, Lyra in 2, e run di dieci ere a mani
vuote esistevano per tre seggi su quattro. Dieci generazioni con la stessa
identica ambizione fallita non sono una tradizione: sono un personaggio
solo, molto vecchio, con dieci nomi.

### La regola

Il Destino è **della persona**. Il seggio porta un contatore di ere a mani
vuote (`barren`: sale quando non si ottiene, si azzera quando si ottiene) e
quando la persona cambia — solo allora — dopo `WEARY_ERAS = 2` ere senza
ottenere, l'erede passa al Destino successivo del pool: la prima delusione
è sfortuna, la seconda è una tradizione, e un erede non giura su una
tradizione di fallimenti. La rotazione da stanchezza è marcata `weary`,
distinta da quella da premio (`wants_new`), e lascia una riga nel verbale:
*«Non ha giurato sull'ambizione che ha visto fallire»*.

Chi non cambia persona non si stanca: la stessa vita riprova finché vive
(salto breve, nessuna rotazione), un popolo COLLECTIVE si rinnova senza
cambiare volto, e Vaerax è sotto la montagna apposta — il suo macinare
eterno è carattere, non bug.

### Misurato (20 saghe da 10 ere, corona)

| run massimo senza ottenere / saghe intere sullo stesso Destino | prima | dopo |
|---|---|---|
| Re Aldric (MORTAL) | 10 ere / **6 su 20** | 3 ere / **0** |
| Lyra (MORTAL) | 10 ere / 2 su 20 | 3 ere / 0 |
| Popolo Nahr (COLLECTIVE) | 7 ere / 0 | 6 ere / 0 — intoccato, per disegno |
| Vaerax (ETERNAL) | 10 ere / 1 su 20 | 10 ere / 1 — la montagna non si stanca |

Le rotazioni da premio restano 13.2 per saga (erano 13.6); quelle da
stanchezza sono 6.7. Tutte le altre misure d'era — salti, generazioni,
pesca che ascolta, memoria letta — invariate. Il playtest non incatena ere
e resta intatto per costruzione.

Guardie: `test_succession.gd` — l'erede dopo le ere a mani vuote di soglia
ruota (e una in meno non basta), la stessa persona non abbandona, l'eterno
non si stanca, il contatore sale e si azzera con l'ottenuto.

### Revisione 0.1.36 — la soglia a tre, per scelta del committente

A due ere la stanchezza ruotava 6.7 Destini per saga — quasi al ritmo dei
salti. Il committente ha scelto tre: la terza delusione è la tradizione, non
la seconda. Rimisurato sugli stessi semi: rotazioni da stanchezza **4.1**
per saga, da premio tornate a 13.6, e i mortali restano sbloccati — run
massimo di Aldric 4 ere (era 10 senza regola), zero saghe macinate per i
MORTAL. Il Popolo e Vaerax restano fuori dalla regola, come da disegno.

---

## D-080 — La guardia sugli anni-biblioteca: l'anno pescato deve decidere qualcosa
**implemented in 0.1.34** (issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25), Fase 4)

`test_balance.gd` sorveglia l'anno scritto dal 2022; nessuno sorvegliava
l'anno che la biblioteca pesca — che è quello con più modi di rompersi in
silenzio: la mano cambia a ogni seme, metà delle domande passa dal Consiglio
del proprio dominio, il mondo arriva già segnato, e da D-079 la pesca
ascolta quei segni. Un anno-biblioteca che non decide niente è esattamente
il fallimento che il §7 vuole vedere (D-047), e non c'era un test che lo
vedesse.

`tests/smoke/test_library_balance.gd` gioca l'anno scritto, gli fa ereditare
l'anno-biblioteca, e conta i Consigli del secondo — per tutte e due le
coppie, corona e città.

### La banda, dichiarata dalla misura di nascita

| su 12 semi (500-511) | mediana | distribuzione |
|---|---|---|
| CHR_02 dopo CHR_01 | **4** | 2-6, nessuno fuori dai limiti §7 |
| CHR_04 dopo CHR_03 | **5** | 2-6, nessuno fuori dai limiti §7 |

Limiti duri identici a `test_balance.gd` (2-8, la storia è in D-047/D-051);
banda della mediana **3-6**, più larga di quella dell'anno scritto perché un
anno pescato è legittimamente più quieto di uno scritto per essere pieno:
eredita conti già chiusi. Come sempre: la banda si rivede a verbale, i
limiti duri no.

---

## D-079 — La pesca che ascolta: l'era dopo cresce da quella prima
**implemented in 0.1.34** (issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25))

Era il pezzo mancante dichiarato in fondo alla #25: la biblioteca pescava
l'anno **alla cieca**. Un'era poteva chiudere con la corona divisa e la
successiva discutere di pozzi, come se il mondo non avesse appena detto di
cosa aveva bisogno di parlare.

### La regola

Il `tension_pool` dichiara gli **echi**: per ogni candidata, i segni che la
richiamano. Se il mondo ereditato porta uno di quei segni — come fatto
globale, come la sua **leggenda** (`legend:<fatto>`, D-075), o come tag su
una Regione — la candidata pesa **il triplo** nella pesca (3:1, un richiamo
conta ma non zittisce il caso). Gli echi sono ancorati ai tag che le
Conseguenze scrivono davvero: la miniera murata richiama il Risveglio, il
lutto e le terre svuotate richiamano la Febbre, il debito chiamato richiama
il Debito.

Due vincoli di struttura:

- **La ripesca sta in `inherit_from`**: al setup il mondo di prima non è
  ancora noto, quindi l'anno viene pescato alla cieca e — solo se il pool
  dichiara echi e c'è un mondo da ereditare — ridato con le carte pesate,
  sacchetto del Drift compreso, prima che si giochi. Niente di tutto questo
  passa per un Effect (D-006), e senza `previous` o senza echi la pesca
  resta byte-identica a prima.
- **I tag di Entità non contano**: le persone muoiono, i segni del mondo
  restano.

### Misurato

- Sonda delle ere (20 saghe): **le candidate richiamate da un segno vengono
  pescate il 78% delle volte**, contro il 67% analitico della pesca cieca
  (4 su 6). Il divario è moderato perché a fine era i segni abbondano —
  spesso 4 candidate su 6 sono richiamate insieme, e i pesi si elidono: la
  pesca ascolta chi ha lasciato un segno *in più*.
- La saga dell'812 tiene le sue proprietà: 0 domande ridecise, salti e
  generazioni invariati, e le mani d'era mostrano la continuità voluta —
  il Risveglio torna dove la storia della miniera è rimasta aperta.
- Guardie: `test_library_content.gd` — stessa mano a parità di seme e mondo,
  il segno pesa (misurato su cento semi: con la miniera murata sul tavolo il
  Risveglio esce 93 volte, senza 66), la leggenda richiama quanto il fatto,
  e la ripesca ridà anche il sacchetto del Drift.

---

## D-078 — Il criterio di D-075 vale anche per la mappa: le condizioni sbiadiscono
**implemented in 0.1.33**

La prima saga giocata dall'inizio alla fine (seme 812, dieci Chronicle,
812→1856) ha lasciato un verbale, e il verbale conteneva un lutto di mille
anni: le Terre Nahr chiudono l'anno 812 con `condition:mourning` e ce
l'hanno ancora nel 1856. In mezzo, solo accumulo — `emptied`, `cut_off`,
`unrest` si aggiungono e niente si toglie mai. D-075 aveva insegnato al
tempo a sbiadire i **fatti globali**; i tag di Regione attraversavano i
secoli letterali, tutti, sempre.

### La regola

Il criterio è lo stesso di D-075 e non ne serve uno nuovo: su un salto che
supera `DECAY_YEARS`, una **`condition:`** — che è stato sociale, gente che
piange o si ammutina — non attraversa; ciò che è murato o scritto —
**`structure:`**, **`settlement:`** — resta, e la **`scar:`** resta perché è
esattamente la memoria visibile della mappa. Su un salto breve si ricorda
tutto, com'era.

### Misurato (stessa saga, seme 812)

| Terre Nahr, `condition:` | prima | dopo |
|---|---|---|
| 849 (+37) | mourning | mourning — un salto breve ricorda |
| 1002 (+153) | mourning | il lutto è sbiadito |
| ultime cinque ere | 4-5 condizioni accumulate, sempre le stesse | 0-2, e sono quelle degli eventi dell'era |

Canali, insediamenti e cicatrici arrivano in fondo alla saga come prima.
Guardia: `test_succession.gd::test_time_lets_conditions_fade_but_keeps_what_is_built`.

---

## D-077 — Una domanda decisa resta decisa (e una bocciata resta sul tavolo)
**implemented in 0.1.33**

Il secondo buco del verbale della saga dell'812: **due Chronicle su dieci
rimettevano ai voti una domanda già decisa nello stesso anno** — nell'849
«Chi riscuote su quello che passa sulla Strada dei Mercanti?» decisa due
volte dopo una bocciatura, nel 1334 «Chi riscuote su quello che passa a
Eredan?» decisa due volte senza nemmeno quella. La causa era il ripiego di
D-061: esaurite le domande nuove, il filtro si toglieva di mezzo e «si
torna alla più affilata, come prima». Alla frequenza dei Consigli del
2022 il caso era teorico; con l'anno pieno di D-066/D-069 succede davvero.

### La regola, in tre pezzi

1. **Niente ripiego**: una Tensione che ha esaurito le domande non rimette
   ai voti niente (`_eligible_questions`).
2. **Un Consiglio senza niente di nuovo non si apre**: i trigger — soglia,
   pavimento di fine anno — chiedono `has_fresh_question()` prima di
   aprire, e la policy lo chiede prima di spendere un Claim su una domanda
   che non esiste più.
3. **Una proposta bocciata non consuma la domanda**: respingere non è
   decidere. La domanda si segna come posta solo su un esito che decide
   (tutto tranne FAILURE); bocciata, resta sul tavolo e può tornare.

### Il terzo pezzo è il risultato di due varianti respinte

La prima stesura aveva solo i pezzi 1 e 2, e il playtest dei 100 semi ha
presentato il conto: **tavolo misto 1/8 bloccati** — Kessa dei Fuochi
46/3, quando il vincolo di casa è 0/8. La sonda ha mostrato il perché: il
controllo in CHR_03 passa solo da tre Conseguenze `$proponent`, la parola
si assegna per presenza nella Regione focale, e Kessa non è mai presente
dove il controllo è in palio. Il suo motore erano proprio le ridecisioni
del Debito che il pezzo 1 giustamente elimina.

Due cure misurate e respinte coi numeri, stessi 100 semi:

| variante | bloccati misto | il conto |
|---|---|---|
| il controllo sulla veglia (`CNS_ASH_WATCH` assegna la montagna) | 1/8 | Kessa ferma (45/3), Anselmo 0→5 NONE, Libere 32→23 VICTORY, FAIL 163→185: il controllo nel dominio ANCIENT scatena opposizioni ovunque |
| la caccia all'AUTHORITY da zero (rimisura di D-069) | 0/8 | ma Lyra dimezza i Triumph (10→5), FAIL 163→184, e compare una partita da 1 Consiglio |
| **una bocciata resta sul tavolo (pezzo 3)** | **0/8** | Kessa 41/8/1, Aldric 7→2 NONE, Lyra 12 Triumph, Verità diverse 484→513 |

Il pezzo 3 non è una toppa per Kessa: è la semantica giusta — la prima
stesura faceva consumare la domanda anche a un Consiglio andato a vuoto,
che non aveva deciso niente. Rimesso il significato al suo posto, il
tavolo si è sbloccato da solo.

### Il conto sull'anno, e la banda

I Consigli tolti erano ridecisioni: la mediana del guardiano §7 scende da
6 a 5 e la banda dichiarata di `test_balance.gd` torna **5-6** (1.25-1.5
per Tensione — la storia delle bande è D-026→D-036→D-051, e anche
stavolta i limiti duri non si sono mossi: 0 partite fuori). Sul playtest
misto: media 5.88 Consigli, FAIL 163→193 — le bocciature adesso possono
tornare ai voti, ed è la cosa che si vede — DECISIVE 180→184.

### La controprova sulla saga

Stessa saga dell'812 rigiocata: **0 domande ridecise su dieci Chronicle**
(erano 2), e le riproposte dopo bocciatura che restano sono la cosa nuova
che il gioco adesso sa dire: nell'anno 1770 la stessa questione cade tre
volte e passa alla quarta.

Guardie: `test_questions_asked.gd` — il Consiglio esaurito non si apre, la
bocciata resta sul tavolo, la memoria è della Tensione.

---

## D-076 — Il contenuto che legge le leggende: la famiglia MEMORIA
**implemented in 0.1.32** (issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25), Fase 3)

D-075 ha dato al mondo le leggende e nessun contenuto le leggeva: un `legend:`
era un tag che esisteva perché qualcuno, un giorno, potesse nominarlo. Questa
versione mette al tavolo quel qualcuno.

### Cosa è entrato

- **La famiglia MEMORIA**: carte Echo la cui eleggibilità nomina una leggenda.
  «La Ballata dell'Anno Buono» (si racconta dell'anno in cui l'ordine tornò —
  e la nostalgia calma la Successione), «Il Giorno che la Gilda Chiese Tutto»
  (il debito di adesso comincia a pesare come quello antico). Una per era,
  gated sulla leggenda più frequente della sua saga.
- **Due proposte «si dice che»**: rifare come si racconta che si fece
  (`P_ANY_AS_STORY`) e rileggere la vecchia pagina del registro
  (`P_OLD_PAGE`), entrambe verso `CNS_LEGEND_RETOLD` — la leggenda messa per
  iscritto: chi raccoglie le storie guadagna una **Scoperta**, e la domanda
  si calma. La memoria è diventata una via alle Scoperte: un ponte fra le ere
  per i Destini che le contano.

### Le due regole di struttura, trovate dai 12 test rotti

La prima stesura ha rotto dodici asserzioni in un colpo, e i dodici pezzi
indicavano due difetti veri, non dodici numeri da aggiornare:

1. **Un mazzo non porta famiglie che nessun atto pesca.** Aggiungere una carta
   al mazzo cambiava il mescolamento anche negli anni scritti, dove la carta
   non poteva mai essere eleggibile — e tre piani scriptati raccontavano
   un'altra storia. Adesso il mazzo di una Chronicle contiene solo le famiglie
   elencate nei suoi `act_echo_pools`, e MEMORIA sta nei pool delle sole
   biblioteche: **gli anni scritti sono byte-identici a prima, verificato con
   `diff` sul playtest dei 100 semi.**
2. **La policy pianifica contro i Consigli di quest'anno, non contro l'intera
   biblioteca.** `_tensions_offering` scandiva tutti i template: Lyra
   inseguiva nel primo anno una via-alle-Scoperte che esiste solo nelle ere
   con una memoria. Adesso guarda i template che la Chronicle in corso
   elenca, che è comunque la lettura giusta.

### Misurato

Sonda delle ere (che ora conta la memoria *letta*, con la disciplina D-035:
una voce a zero è contenuto che non esiste):

| su 20 saghe della corona / 10 delle città | corona | città |
|---|---|---|
| «La Ballata dell'Anno Buono» pescata | **38** | 0 |
| «Il Giorno che la Gilda Chiese Tutto» pescata | 0 | **18** |
| «Si fa come si racconta» votata | **6** | 4 |
| «La vecchia pagina» votata | 0 | **5** |

Ogni pezzo vive nella sua era, nessuno fuori. 191 test in 27 suite verdi,
sim deterministiche, anni scritti intoccati per costruzione.

---

## D-075 — La memoria che sbiadisce: i fatti diventano leggende
**implemented in 0.1.31** (issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25), Fase 2 — nella forma corretta dal committente)

Il piano della #25 era scivolato su «la Chronicle II è l'anno dopo», e il
committente ha rimesso la barra dritta: **fra due partite possono passare
venti anni o due secoli, i protagonisti possono non esserci più, e dieci
partite possono coprire mille anni.** La parte bella è che il motore questa
visione ce l'aveva già — `succession.gd` (D-045/D-046): il seggio è la casa,
le generazioni si succedono coi loro nomi, i rapporti si smussano, i Destini
ruotano; e le Chronicle-biblioteca `CHR_02`/`CHR_04` dichiarano salti di
20–200 anni. La sonda delle ere lo certifica: **una saga di 10 Chronicle
copre in mediana 1.019 anni**, 17 generazioni nuove al tavolo, 12 Destini
ruotati, 15 mani di domande diverse.

Quello che mancava, e questa versione aggiunge, è **cosa il tempo fa alla
memoria**: dei 7,2 fatti globali con cui si chiude l'anno uno, **7,2 su 7,2
arrivavano letterali all'ultimo anno** — `mine_sealed` dell'812 era un fatto
corrente nel 1856. Un mondo che ricorda tutto per sempre non ha leggende: ha
un archivio.

### La regola

Su un salto breve si ricorda tutto com'era. Su un salto lungo (la stessa
soglia dei rapporti, `DECAY_YEARS` = 50) **resta un fatto solo quello che è
murato o scritto** — la Chronicle che arriva lo dichiara in
`enduring_facts` — e il resto non sparisce: **diventa `legend:<fatto>`**,
vero come la memoria e non come il mondo. Le leggende, una volta nate,
attraversano ogni salto successivo. I segnaposto della grammatica narrativa
(`function:`) sbiadiscono e basta.

La lista di ciò che dura è contenuto, non regola: per la prima saga il
sigillo delle Miniere, il vallo della Valle, la legge di successione,
l'insediamento riconosciuto, la corona divisa o spodestata, il registro
copiato; per la seconda la Carta, il registro, l'acqua a prezzo per atto, la
teca murata, la custodia per atto. Il criterio in una riga: *quello che è
scritto o murato resta; quello che è consuetudine sbiadisce.*

### Misurato

Sonda delle ere, 20 saghe da 10 Chronicle:

| | prima | dopo |
|---|---|---|
| fatti dell'anno uno letterali all'ultimo anno | 7,2 su 7,2 (**100%**) | **5,0** (e i sopravvissuti sono quelli dichiarati o rifatti da ere successive) |
| il mondo all'ultimo anno porta | 23,3 fatti correnti | 11,7 fatti + **16,1 leggende** |
| anni coperti / generazioni / rotazioni | 1.019 / 17,3 / 10,8 | 1.019 / 17,3 / 12,6 |

E i casi che la regola produce da sola, senza una riga di contenuto in più:
la teca mostrata due secoli fa torna leggenda, e l'Ordine di un'altra era
deve rimostrarla; il debito chiamato da una Gilda morta non è più «chiamato»,
e la generazione nuova deve rifarlo suo. Il playtest a Chronicle singola è
intoccato per costruzione (senza eredità niente sbiadisce): 191 test in 27
suite verdi, sim deterministiche.

### Cosa resta aperto

Nessun contenuto **legge** ancora una leggenda: `legend:*` esiste perché le
Conseguenze, i Destini e le carte Echo di domani possano nominarlo («si dice
che sotto la montagna…»). È la prossima passata di contenuto della campagna,
insieme alla pesca delle domande pesata sulle conseguenze (Fase 3 della #25).

---

## D-074 — La materia prima della campagna: 99 mondi su 100, e tre difetti noti
**measured in 0.1.30** (issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25), Fase 1)

Prima di scrivere il generatore della Chronicle II, la domanda che decide se
vale la pena scriverlo: **cento semi producono cento anni diversi, o lo stesso
anno cento volte?** `cli/run_legacy_probe.gd` misura la materia prima — fatti
globali, cicatrici, controllo, rapporti e livelli con cui un anno si chiude —
sugli stessi 100 semi e lo stesso tavolo misto di tutte le misure.

**La materia prima c'è: 50 mondi distinti su 50 nella prima saga, 49 su 50
nella seconda.** 47 fatti globali diversi con distribuzioni sane (dal 94% al
2%), il controllo di Eredan che cambia mano (70% Aldric, 14% Lyra, 8% il
Popolo), 267 cicatrici, livelli variati. Un generatore ha di che lavorare.

E i tre difetti da sapere prima di costruirci sopra:

1. **La cicatrice del fallimento domina**: `scar:unanswered` è 195 delle 267
   cicatrici totali (73%) — 2,4 per anno nella prima saga. Un generatore che
   legga le cicatrici alla pari vedrebbe soprattutto questo rumore. Va
   aggregata, non letta: «quante domande sono rimaste senza risposta» è un
   numero che può *aprire una Tensione* nell'anno dopo, non 195 fatti diversi.
2. **Tre rapporti sono costanti travestite da variabili**: Lyra–Vaerax chiude
   HOSTILE in 50 anni su 50, Cenere–Vetro ENEMY+VENDETTA 50 su 50,
   Libere–Vetro ALLY 50 su 50. Una costante non è informazione per il
   generatore — e a monte dice che il contenuto rende quei tre destini di
   coppia inevitabili: da riguardare come contenuto, non solo come input.
3. **I fatti frequenti dicono poco, i rari sono l'oro**: `order_restored`
   (88–94%) e `question_unresolved` (78–94%) sono quasi-costanti; a
   differenziare gli anni sono `crown_divided` (8%), `no_charter` (12%),
   `crystal_exploited` (2%). Il generatore deve pesare per rarità.

La Fase 2 (l'assegnazione dei Destini di successione) parte da qui.

---

## D-073 — Il dado conta: misurato, e nessuna manopola da girare
**measured in 0.1.29** (sonda dei margini estesa: `--chronicle`, `--tavolo=misto`)

L'ultima precondizione tattica non misurata: se i Consigli si chiudono con
margini che il d6 (±2) non può ribaltare, la suspense dell'impegno segreto è
finta. La sonda dei margini guardava solo la prima saga a tavolo uniforme —
lo stesso difetto che D-066 aveva corretto nella sonda delle posizioni — ed è
stata estesa prima di giudicare.

**A tavolo uniforme il sospetto sembrava fondato**: nella seconda saga il 78%
dei Consigli chiudeva senza un'opposizione e il 53% a M ≥ +7, fuori dalla
portata del dado. **A tavolo misto sparisce**: senza-opposizione 22% (CHR_01)
e 29% (CHR_03), S−O medio 0,26 e 1,39, e la massa dei margini a cavallo dei
tre confini di banda — il dado decide la banda in circa due Consigli su tre,
e i margini blindati (≥ +7 o ≤ −5) sono un quarto del totale.

Verdetto: **il dado conta e non c'è nessuna manopola da girare.** È la terza
volta che l'ottimizzatore uniforme, da solo, avrebbe indotto un intervento
sbagliato (D-051 sui seggi, D-063 sulle proposte, qui sui margini): la misura
di riferimento è il tavolo misto, sempre, e adesso ogni sonda del progetto
sa farla.

---

## D-072 — La prima saga si sveglia: due scene a bande sovrapposte
**implemented in 0.1.29** (chiude ISSUES 17, col vincolo di [D-070](#d-070))

La prima saga era ferma al 71% di ABSTAIN mentre la seconda scendeva al 48%, e
il tentativo più ovvio — il sigillo conteso fra Lyra e Vaerax — era stato
respinto due volte: spegneva i Triumph del tavolo. Il vincolo scritto in D-070
è diventato il criterio di progetto di queste due scene: **le bande devono
sovrapporsi** — dev'esserci almeno un mondo in cui tutt'e due i contendenti
vincono — così la scena produce voti contesi, non un pareggio a zero.

### Le due scene

1. **La fame tiene gli uomini nelle valli** — `DST_VAERAX` a Triumph vuole la
   Carestia **da 3 in su**; la Vittoria di Aldric la vuole **fino a 4**, il
   Triumph del Popolo fino a 3. Le bande si toccano in 3–4: ci si può stare
   tutti, ma ogni spinta è contesa. I Consigli della Carestia — i più
   frequenti della saga — adesso hanno sempre qualcuno dall'altra parte.
2. **Un domani certo rimette in moto le carovane** — `CNS_HEIR_NAMED` cala di
   1 le Vie Interrotte. La proposta più votata della Successione (48 voti su
   40 Chronicle) adesso tocca Lyra (Vie ≤ 4, a favore) e Vaerax (Vie ≥ 3,
   contro) nei due versi.

### Misurato

Sonda delle posizioni, 40 Chronicle, prima saga:

| | 0.1.28 | 0.1.29 |
|---|---|---|
| ABSTAIN | 71,1% | **59,9%** |
| CONDITION | 5,1% | **10,6%** |
| SUPPORT | 5,9% | **10,9%** |

Il criterio della voce 17 (sotto il 60% a parità di vincoli) è passato. Sui
100 semi di D-055, tavolo misto: seggi bloccati **0 su 8**, Consigli 5,96
(mediana 6), TRIUMPH **11** (il pavimento della voce era 10), NONE 9,
fallimenti **195** — il minimo mai misurato — e la seconda saga ferma al
48,4%. La suite passa senza increspare nessun piano scriptato.

---

## D-071 — Le carte che nessuno gioca non esistono: la coda è vuota
**measured in 0.1.28** (chiude ISSUES 3)

La voce era aperta da un sospetto ragionevole: 48 facce, 132 carte, e nessuno
aveva mai contato quali venissero acquisite e impegnate — la stessa forma di
problema trovata due volte guardando un numero che nessuno guardava.
`cli/run_asset_probe.gd` fa il conteggio: per ogni faccia, quante volte è
arrivata in una mano (setup o pesca), quante è stata spesa (impegnata a un
Consiglio, scartata per una spinta, spesa per la parola), quante è rimasta in
mano a fine anno. Cento partite a tavolo misto, gli stessi semi di D-055.

**La coda è vuota.** Mai in una mano: 0 su 48. Pescate e mai spese: 0 su 48.
Il sospetto era sbagliato, ed è il risultato migliore possibile: misurato, non
presunto. Nessuna carta va riscritta né tolta.

Quello che la sonda ha trovato invece è uno **sbilancio di circolazione** fra
famiglie: WEALTH passa di mano 4.344 volte contro le 383 di FORCE e le 342 di
PEOPLE — un ordine di grandezza. Non è di per sé un difetto (WEALTH è la
famiglia-ponte di tre Regioni su sei), ma è il numero da riguardare se FORCE e
PEOPLE dovessero mai sembrare irrilevanti al tavolo. A verbale, non in coda.

Nota di misura: una carta committata e recuperata da chi si oppone non lascia
un Effect di scarto, quindi il conteggio della spesa è un pavimento, non un
soffitto. Sta scritto anche nella testata della sonda.

---

## D-070 — Il Consiglio come scena: la clausola scelta, la corsa vista, e una scena respinta
**implemented in 0.1.28** (dal lavoro su ABSTAIN; estende [D-066](#d-066) e [D-068](#d-068))

Dopo la 0.1.27 il 65–72% delle posizioni restava ABSTAIN: per due seggi su
tre, quello che si decideva non toccava quello che volevano. Tre mosse,
misurate una alla volta, e una quarta respinta.

### 1. La clausola non è più un timbro

La posizione CONDITION — l'unica mossa negoziale del gioco, passata dal 5% al
19% in due versioni — sceglieva **sempre la prima clausola della lista**
(`_first_clause`): la sonda ha contato zero scelte della seconda clausola di
ogni template, in tutt'e due le saghe. Metà del contenuto negoziale era morto
(D-035). Adesso la policy sceglie la clausola i cui Effect servono il proprio
Destino (`_best_clause`, pareggi all'RNG di sessione): le clausole viventi
passano da **2 a 8**, e i seggi *preferiscono* — il Popolo pone l'amnistia, non
il testimone.

### 2. La corsa al controllo si vede

`_score_effect` dava a un seggio con una clausola `control_count` +2 se il
controllo andava a lui e −3 se gli veniva tolto, e **0 se una Regione cambiava
mano verso un terzo**: la corsa non esisteva. Adesso vale un'obiezione (−1).
Da sola, questa riga: ABSTAIN della seconda saga 64,9% → 61,8%.

### 3. Due scene nuove, dal criterio di D-066

- `CNS_ROYAL_GRANARY` alza di 1 le Vie Interrotte: il grano requisito viaggia
  sotto scorta. La domanda più votata della prima saga adesso tocca Lyra
  (Vie ≤ 4) e Vaerax (Vie ≥ 3) in versi opposti.
- `DST_VETRO` a Triumph: «la legge scritta non è arrivata a bussare alla teca»
  (Carta ≤ 4), contro le Città Libere che la Carta la vogliono matura (≥ 3).
  L'Ordine passa da 142 astensioni e **zero opposizioni** in 40 Chronicle a 42
  astensioni, 57 Condition e 71 appoggi.

### La scena respinta, con i numeri

La quarta mossa era la più bella sulla carta: Lyra a Triumph con «le gallerie
sono aperte a chi vuole verificare» (`mine_sealed` assente), contro la
Vittoria di Vaerax che il sigillo lo **vuole** — scena perfetta sulla proposta
più votata in assoluto (P_SEAL_MINE, 40 voti su 40). Misurata due volte, in due
stesure (aggiunta, e scambiata con la clausola quasi-doppione della strada
tagliata): sveglia Lyra davvero (astensioni 144 → 96, Consigli con un no 67% →
80%) ma **i TRIUMPH del tavolo crollano da 11 a 3 su 400** — la guerra sul
sigillo nega il gradino alto a tutt'e due i contendenti, ogni volta. Respinta.
La lezione, che affina la trappola 2 dell'audit: una scena a livello Triumph
regge solo se **almeno uno dei due può vincerla senza spegnere l'altro
gradino**; due clausole mutuamente esclusive sulla stessa riga non sono una
scena, sono un pareggio a zero scritto nei dati.

### Misurato

Sonda delle posizioni, 40 Chronicle:

| | 0.1.25 | 0.1.27 | 0.1.28 |
|---|---|---|---|
| ABSTAIN CHR_03 | 74,1% | 64,9% | **48,4%** |
| ABSTAIN CHR_01 | 70,2% | 71,8% | 71,1% |
| CONDITION CHR_03 | 16,7% | 19,6% | **29,8%** |
| clausole viventi (due saghe) | 2 | 2 | **8** |

Sui 100 semi di D-055, tavolo misto: seggi bloccati **0 su 8**, Consigli 6,06
(mediana 6), NONE 11, TRIUMPH 11, Verità diverse **526** (nuovo massimo),
divario aggressivo/prudente **22** (era 37 due versioni fa). Il `+1` del
granaio increspa un piano scriptato (il terzo Consiglio di
`plan_a_grain_accord` passa da SUCCESS_WITH_COST a DECISIVE_SUCCESS per un
dado diverso): atteso aggiornato, non un silenzioso aggiustamento.

### Cosa resta aperto

La prima saga resta al 71% di ABSTAIN, e adesso si sa perché: i suoi quattro
Destini si toccano poco, e l'unica scena abbastanza grossa da svegliarla — il
sigillo — costa il gradino alto. Servono scene nuove che non passino da lì:
è la voce 17 di ISSUES.

---

## D-069 — Il diritto di proporre: la policy impara CLAIM, una vite alla volta
**implemented in 0.1.27** (issue [#22](https://github.com/Tannoiser2/ECHOES/issues/22), da [D-063](#d-063), precedente di metodo [D-021](#d-021))

D-063 aveva consegnato il fatto: il proponente lo decide il posto (D-036), e il
posto è di chi vuole l'esito ovvio. Le Città Libere — l'unico seggio il cui
Trionfo **vuole** `debt_forgiven` — non hanno preso la parola sul Debito una
sola volta in 92 Consigli. E l'azione scritta apposta per spostare la parola,
`CLAIM` (§11), non veniva misurata da nessuna sonda perché la risposta era nota
per costruzione: **la policy non l'ha mai giocata.** Il modello di giocatore
competente usava cinque azioni su sei — lo stesso difetto di strumento che
D-021 trovò quando la policy non sapeva forzare i Consigli che le servivano.

### Cosa è entrato

La policy gioca CLAIM, derivandolo dai dati e non per-Entità: un seggio il cui
gradino vivo ha bisogno di una Conseguenza dietro un Consiglio
(`_needed_confluences`, la stessa lista che già spinge le Tensioni), e a cui il
posto non darebbe la parola, prenota il dominio e poi forza. La sonda delle
scelte adesso conta Claim creati e Consigli forzati per seggio.

**La forma ingenua è respinta con i numeri**, ed è la parte che vale di più:
«forza ogni Consiglio che il tuo Destino vuole, appena legale» produce un
tavolo che litiga a vuoto — fallimenti 219 → **339**, mediana dei Consigli **7**
(fuori dalla banda del §7), Decisive 185 → 123, **due seggi bloccati**. Da lì,
quattro viti, ognuna stretta su una rottura misurata:

1. **La domanda deve scaldarsi** (si prenota a soglia−4, si forza a soglia−2 e
   con una mano da giocare): senza, il tavolo perde i Consigli forzati ai voti.
2. **La parola ruota** (chi ha parlato per ultimo su una domanda non se la
   riprenota — lo stesso `last_proponent` di D-051): senza, chi forza
   monopolizza la domanda.
3. **Si forza solo in un round che sarebbe rimasto muto**: un Claim forzato ha
   la precedenza sul trigger a soglia (§7) e manda in coda il Consiglio di
   qualcun altro — misurato, a pagarlo era sempre il seggio dalla soglia più
   bassa (Kessa, soglia 4). Così il Consiglio forzato si **aggiunge** all'anno
   invece di rubare il posto.
4. **Si prenota solo in coppia** (due AUTHORITY in mano, una da spendere e una
   per riscuotere) e l'appetito d'acquisto completa una coppia già cominciata
   invece di inseguirla da zero: 124 Claim creati per 45 forzati erano carte e
   azioni bruciate, e l'inseguimento da zero costava al seggio del controllo —
   le cui Regioni non producono AUTHORITY — le due Vittorie che lo tenevano
   sbloccato.

### Il baco che ha scovato

Un salvataggio preso in fase `DRIFT` o `THRESHOLD_CHECK` riprendeva dal round
successivo e **saltava il Consiglio del round salvato**. Invisibile finché
nessun Consiglio si apriva presto nell'anno; la policy che forza col Claim l'ha
fatto emergere in `test_resume`. La ripresa adesso rientra esattamente lì:
l'eventuale Drift dovuto, il Consiglio dovuto, poi il resto dell'anno.

### Misurato

Sonda delle scelte, 40 Chronicle a tavolo misto:

| | prima | dopo |
|---|---|---|
| Claim creati / forzati CHR_01 | 0 / 0 | 104 / 13 |
| Claim creati / forzati CHR_03 | 0 / 0 | 60 / **25** (Libere 16) |
| mai ai voti CHR_01 | 2 su 15 | **0 su 15** — prima volta |
| mai ai voti CHR_03 | 4 su 20 | **3 su 20** |

**Le cinque proposte di D-063 votano tutte** — `P_OPEN_LEDGER` 9, `P_FORGIVE`
15, `P_DIG_BELOW` 3, `P_WATCH_THE_ROCK` 1, `P_BURY_IT` 2 — e a rimettere il
debito adesso è chi lo voleva rimettere. Restano morte `P_DIG_FOR_HIRE` e
`P_WATER_RIGHTS` (nessuno vuole l'acqua a prezzo: contenuto per un carattere
che il tavolo non ha), e `P_ANY_WITHDRAW` si è spenta — la sua domanda gated
non si apre più ora che i Consigli forzati arrivano prima. A verbale, non
sotto il tappeto.

`run_playtest.gd`, stessi 100 semi, tavolo misto:

| | 0.1.26 | 0.1.27 |
|---|---|---|
| divario aggressivo/prudente (Vittorie) | 37 | **31** |
| NONE | 5 | **9** (il primo di Kessa) |
| TRIUMPH | 11 | **14** |
| Verità diverse | 491 | **506** |
| seggi bloccati (misto) | 0 su 8 | **0 su 8** |
| Consigli per Chronicle | 5,92 | 6,02 (mediana 6, banda §7) |

I costi, dichiarati: Decisive 185 → 172 (un tavolo dove la parola gira decide
un po' meno spesso in trionfo), e a tavolo uniforme i bloccati salgono da 3 a
4 su 8 — l'ottimizzatore identico con più leve si somiglia ancora di più, ed è
un altro argomento per misurare col tavolo misto (trappola 1 dell'audit).

I 104 Claim creati per 13 forzati della prima saga dicono che Aldric prenota
più di quanto riscuota: è dentro i vincoli, ma è la prossima cosa da guardare
se il costo delle AUTHORITY si vorrà alzare.

---

## D-068 — L'asse dei rapporti si accende dal lato di chi vota
**implemented in 0.1.26** (ISSUES 14, chiude la metà §2.3 di [AUDIT_DESTINI](AUDIT_DESTINI.md))

La 0.1.25 aveva dato al punteggio il ramo per leggere un rapporto che si muove
([D-066](#d-066)), e il ramo continuava a pesare **zero su 156**: solo 2
Consequence su 45 muovevano un rapporto — entrambe nella prima saga — e nessun
Destino in gioco nominava una coppia. La seconda saga non aveva **un solo modo
di farsi un nemico**.

### Cosa è entrato

- **Due Conseguenze che fanno nemici**, nella saga che non ne aveva:
  `CNS_DEBT_CALLED` e `CNS_SEAT_CLAIMED` portano `SET_RELATION` a `HOSTILE` su
  `$proponent|$rival`. Chi non può pagare non perdona chi ha chiesto adesso.
- **Due clausole `relation_state` nei Destini in gioco della seconda saga**, a
  livello **Triumph** (trappola 2 dell'audit): `DST_CENERE` vuole che il patto
  con la Gilda non sia un conto aperto, `DST_LIBERE` che la Gilda non diventi
  un nemico delle città. Sono clausole *da tenere* — vere in partenza, spezzate
  esattamente dalle due Conseguenze qui sopra — quindi raggiungibili per
  costruzione (D-035).

### La forma respinta, che insegna la regola

La prima stesura metteva una clausola anche sull'**aggressore** (Aldric che non
vuole farsi nemico il popolo) e pesava **zero**: *chi propone non vota*. Una
clausola su un rapporto pesa nel punteggio di una posizione solo se chi la
regge è nella coppia **e siede dal lato che vota**. Le clausole vanno sul lato
delle vittime.

E la clausola della prima saga (`DST_NAHR` verso Aldric) è stata provata e
respinta con i numeri: 5 pesate in 40 Chronicle, e in cambio i Triumph della
prima saga dimezzati per farfalla (Lyra 6 → 3, Vaerax 1 → 0 su 50). La prima
saga resta quindi a `SET_RELATION` pesato 0: la sua unica coppia mossa è quella
della Valle Chiusa, e chi la propone non vota. Scritto qui perché nessuno la
riprovi senza un'idea nuova.

### Misurato

Sonda delle posizioni, 40 Chronicle:

| CHR_03 | prima | dopo |
|---|---|---|
| `SET_RELATION` letto / pesato | 156 / **0** | 357 / **85** |
| ABSTAIN | 74,1% | **64,9%** |
| OPPOSE | 0,9% | **7,2%** |
| Consigli con almeno un no | 53% | **59%** |

CHR_01 resta com'era (68% con un no, ABSTAIN 70,3%). Sui 100 semi di D-055 i
vincoli reggono: Consigli 5,92 (banda §7), seggi bloccati a tavolo misto **0 su
8**, suite verde.

### Il costo, che è reale

- **Maestra Ilve passa da 3/42/5 a 12/34/4**: il seggio più forte del tavolo
  adesso trova un no quando chiama il debito. È il costo che ISSUES 14
  chiedeva di creare.
- Kessa passa da 39/11 a 43/7: dire di no costa carte anche a chi lo dice.
- Il divario aggressivo/prudente sale ancora, 30 → 37 in Vittorie. È la stessa
  forza di D-066 — i Consigli contesi aiutano chi è costruito per approfittarne
  — e resta messa in conto, non tarata via.

---

## D-067 — Perdere adesso è implementato: le espulsioni e la porta sbarrata
**implemented in 0.1.26** (ISSUES 15, chiude la metà §2.2 di [AUDIT_DESTINI](AUDIT_DESTINI.md))

Su 400 risultati di seggio NONE usciva **una volta**, e l'audit aveva detto
perché: nessun contenuto poteva falsificare un Minimo contro la volontà di chi
lo regge. Non taratura — un pezzo di gioco mancante.

### La forma respinta, che insegna la regola

Il primo tentativo attaccava l'espulsione alle vie del controllo
(`CNS_SEAT_CLAIMED`, poi `CNS_DEBT_CALLED`): Kessa dei Fuochi — che di quelle
proposte vive — è crollata da 39/11 a 45/5 e i seggi bloccati a tavolo misto
sono passati da 0 a 1 su 8. Ripricare una proposta che un seggio propone per sé
la fa bloccare, e affama chi ci contava.

La regola emersa, che vale più delle tre righe di dati: **l'espulsione va dove
il no c'è già.** Attaccata a una Conseguenza che la vittima già blocca (la
capitale presa, la valle chiusa, le gallerie lasciate), non cambia il punteggio
di nessuno — cambia solo cosa succede quando quel voto si perde comunque.

### Cosa è entrato

Tre `REMOVE_PRESENCE` su `$rival`, tutte su Conseguenze già ostili alla vittima:

| Conseguenza | Regione | il Minimo che tocca |
|---|---|---|
| `CNS_CAPITAL_TAKEN` | `$capital` | Aldric, presenza a Eredan |
| `CNS_SEALED_VALLEY` | `REG_TERRE_NAHR` (nominata, non `$region_focus`) | il popolo, presenza nelle Terre |
| `CNS_ASH_ABANDONED` | `REG_MINIERE_ANTICHE` (nominata) | l'Ordine, presidio a soglia 2 |

E una sonda nuova, `cli/run_eviction_probe.gd`, che risponde alla domanda che
mancava: *quando cade un'espulsione, e chi recupera?* La risposta ha deciso
tutto il resto: col solo contenuto, 30 espulsioni applicate in 100 partite, 13
su una Regione del Minimo, **12 recuperate** — il rientro costa una MOVE, e una
MOVE verso una Regione iniziale è sempre legale. NONE restava 1 su 400.

### La regola della porta sbarrata

**Una Regione da cui un Consiglio ti ha cacciato resta sbarrata per te fino a
fine atto.** La risoluzione mette un tag `evicted:<regione>` alla vittima — solo
per la presenza tolta a qualcun altro, solo se c'era davvero qualcuno da
cacciare — `can_move_to` lo legge, e il giro di stagione lo toglie con un Effect
`SEASON_TURNS` nel log. Senza contenuto che caccia la regola è inerte, quindi è
reversibile per costruzione: si toglie togliendo le tre righe di dati.

### Misurato

Sui 100 semi di D-055, tavolo misto, dopo D-068:

| | 0.1.25 | 0.1.26 |
|---|---|---|
| **NONE** | **1** | **5** |
| MINIMUM | 205 | 214 |
| VICTORY | 181 | 170 |
| TRIUMPH | 13 | 11 |
| seggi bloccati (misto) | 0 su 8 | **0 su 8** |
| Consigli per Chronicle | 5,97 | 5,92 |

La sonda delle espulsioni, dopo la regola: 13 espulsioni sul Minimo, 4 → NONE,
9 recuperate. Il taglio è leggibile al tavolo: **ogni espulsione sul Minimo
caduta nell'atto III è diventata un NONE** (l'atto non gira più), quelle degli
atti I–II si recuperano perdendo l'atto. A tavolo uniforme NONE è 9 su 400. Il
quinto NONE del misto è un Aldric caduto senza espulsione: anche perdere da
soli adesso capita.

Secondo ordine, misurato con la sonda delle posizioni come l'audit chiedeva:
ABSTAIN e Consigli-con-un-no invariati in entrambe le saghe, e
`REMOVE_PRESENCE` passa da Effect invisibile a **pesato 28** in CHR_01: essere
cacciabili adesso è un motivo di lite che il punteggio vede.

### Cosa resta aperto

I NONE stanno tutti nella prima saga: la seconda ha le stesse espulsioni e la
stessa porta sbarrata (Vetro e Cenere le subiscono), ma in questi 100 semi
nessuna è caduta nell'atto III. Il gradino esiste anche lì — lo dice la sonda —
ma non si è ancora visto in un risultato. Da riguardare quando il contenuto
della seconda saga cresce.

---

## D-066 — Il tavolo non aveva niente in gioco
**implemented in 0.1.25** (§12.2 D, estende [D-034](#d-034))

La sonda delle posizioni aveva misurato la cosa peggiore che si potesse
misurare: su 40 Chronicle **l'80,1% delle posizioni dichiarate era ABSTAIN, e la
proposta valeva esattamente 0 per l'80,1% dei seggi.** Lo stesso numero due
volte, e non è una coincidenza — non era apatia, era **indifferenza
misurabile**: per quattro seggi su cinque, quello che si stava decidendo non
toccava in alcun modo quello che volevano. Due Consigli su tre si chiudevano
senza che nessuno dicesse no.

Il Consiglio è la scena centrale del gioco, e per la maggior parte dei presenti
era un atto notarile.

### Il perché, in tre pezzi

**1. `SET_RELATION` non aveva un ramo nel punteggio.** Letto 126 volte, pesato
**zero**. Forgiare — muovere di un passo il rapporto con un altro giocatore — è
una delle sei azioni del gioco, e per chi decide non esisteva.

**2. Una clausola `min` su una Tensione era mezza cieca.** Il ramo `max` aveva il
suo ripiego dentro la banda (una spinta nella direzione sbagliata vale
un'obiezione anche se non rompe niente); `min` no. Chi ha bisogno che una domanda
resti calda non aveva niente da dire finché non gliela spegnevano del tutto.

**3. E soprattutto: le domande che si aprivano non le voleva nessuno.** Le
Tensioni più visitate dei due tavoli — le Vie Interrotte e la Successione nella
prima saga, la Carta nella seconda — **non erano nominate da nessun Destino**. La
seconda saga non aveva **una sola** clausola `tension_limit`: `ADJUST_TENSION`
letto 558 volte e pesato zero. Su 99 clausole in 16 Destini, 51 erano tag e 4
erano Tensioni.

I Destini erano scritti in **tag e controllo**; il gioco fa soprattutto
**tensioni e rapporti**. Le due metà non si parlavano.

### Cosa è stato fatto

Il ramo `SET_RELATION` nel punteggio, il ripiego mancante su `min`, e dieci
clausole `tension_limit` nei Destini in gioco — a livello **Triumph**, perché il
punteggio di una proposta legge tutti e tre i livelli e a livello Victory la
Vittoria crollava da 192 a 126 su 400 e un seggio restava bloccato.

Il criterio che le ha scritte, ed è la parte che vale più delle clausole:
**ogni Tensione in gioco dev'essere nominata da almeno un Destino, e almeno un
seggio dev'essere dalla parte opposta.** Vaerax vuole le Vie Interrotte da 3 in
su perché salire fin lassù non dev'essere facile; Lyra le vuole sotto 4 perché è
la strada delle gallerie. Quella è una scena. Quattro Destini che vogliono tutti
la Carestia bassa non lo sono.

`validate_data.py` adesso rifiuta una Chronicle con le Tensioni scritte a mano in
cui una domanda in gioco non è nominata da nessun seggio.

### Misurato

Sonda delle posizioni, 40 Chronicle per saga:

| | CHR_01 | CHR_03 |
|---|---|---|
| Consigli con almeno un no | 37% → **68%** | 38% → **53%** |
| ABSTAIN | 80,1% → **70,2%** | 85,9% → **74,1%** |
| CONDITION | 0,7% → 5,0% | 4,7% → **16,7%** |
| `ADJUST_TENSION` pesato | 6 su 468 → **266 su 669** | **0** su 558 → **146 su 558** |

`run_playtest.gd` sugli stessi 100 semi di D-055 — fallimenti **251 → 219**,
Decisive **133 → 185**, Consigli per Chronicle 5,97 (dentro la banda del §7),
Truth diverse 471 → 480, seggi bloccati a tavolo misto **0 su 8** e a tavolo
uniforme 3 su 8, come prima.

### Il costo, che è reale

Il divario in Vittorie fra aggressivo e prudente passa da 26 a **31**. Non è un
caso e non si tara via: **rendere contesi i Consigli aiuta il carattere
costruito per approfittare dei contesi.** I due obiettivi tirano in direzioni
diverse, e questo è il primo posto in cui il progetto lo vede scritto.

E la Vittoria scende da 192 a 181 su 400 mentre il Minimum sale da 193 a 205: un
tavolo che discute concede meno.

### Cosa resta aperto

`SET_RELATION` adesso si legge, e continua a pesare **zero su 156**: nessun
Destino in gioco nomina una coppia, e solo **2 Consequence su 45** muovono un
rapporto. Il ramo è scritto e corretto — i test lo tengono — ma l'asse dei
rapporti in gioco quasi non esiste. Perché si accenda servono Conseguenze che
facciano nemici, e questa è la prossima passata di contenuto.

E **NONE resta 1 su 400**: nessuno perde mai. I Minimi sono «esisti ancora» e
«hai una presenza da qualche parte», due cose che non si perdono. È un problema
diverso da questo, ed è il più grosso che resta.

---

## D-065 — Il quarto MASTER PROMPT: le Casate sono ritratti
**implemented in 0.1.24** (ISSUES 4, chiude [D-056](#d-056))

L'export aveva trovato che le otto chiavi `entity.*` erano in uso e senza
prompt, e le due strade erano esclusive: scrivere il quarto MASTER PROMPT, o
togliere l'illustrazione alle carte Casata. Scelto il ritratto, che è anche
quello che [D-060](#d-060) aveva già assegnato alle Casate quando ha riscritto la
regola 3 — *l'Asset è una scena, la Casata è un ritratto*. Senza il quarto
prompt quella distinzione aveva un solo lato.

**Lo stemma resta il ripiego dichiarato.** È più facile da disegnare otto volte e
regge meglio la miniatura; se i ritratti non escono, la chiave non cambia e si
riscrive solo questo prompt. Ma un mazzo di stemmi lascerebbe la regola 3 senza
il suo mezzo, e uno stemma non dice la cosa che un ritratto dice: che dall'altra
parte del tavolo c'è qualcuno.

### La variation key è l'archetipo

Sei righe — SOVEREIGN, INDIVIDUAL, FACTION, CULT, PEOPLE, CREATURE — perché è
quello che cambia davvero un ritratto. Due di quelle righe non sono un volto, ed
è per loro che il prompt dice *one subject* e non *one face*: un popolo si ritrae
con uno dei suoi, in primo piano e la sua gente dietro fuori fuoco; una cosa che
dorme sotto la montagna si ritrae da vicino, e occhi da mostrare non ne ha.

### Un difetto trovato scrivendolo

`PEOPLE` è **sia** una famiglia di Asset **sia** un archetipo di Casata, e
`art_bible.gd` teneva accenti e guide in un dizionario solo, piatto su tutti i
MASTER PROMPT. La seconda tabella avrebbe sovrascritto la prima, o viceversa, a
seconda dell'ordine in cui il documento le elenca. Con il contenuto di oggi non
si sarebbe visto — i due `PEOPLE` hanno lo stesso accento e il PROMPT 1 non usa
`{DESCRIZIONE}` — il che lo rende esattamente il tipo di difetto che si scopre
sei mesi dopo cambiando una parola. Adesso accenti e guide sono per prompt, e un
test tiene ferma la separazione nei due versi.

Da qui `keys_without_prompt()` torna vuota, e il test che contava le chiavi
scoperte è diventato la guardia che pretende che restino zero.

---

## D-064 — Far cadere una proposta costa quanto proporla
**implemented in 0.1.24** (§12.3, rivede [D-013](#d-013) — ISSUES 1)

La seconda leva contro l'Oppose come strategia dominante. La prima
([D-055](#d-055)) ha fatto entrare la Condition nel margine e ha abbassato i
fallimenti, ma non ha detronizzato niente: l'aggressivo restava a 69 Vittorie
contro le 32 del prudente.

Il §12.3 dice che su un Failure il proponente scarta tutto e **ogni oppositore si
riprende una carta a scelta**. È l'unica asimmetria del sistema che premia il
fronte contrario: opporsi e vincere costa meno che proporre e vincere. Toglierla
è la prima delle tre varianti che ISSUES 1 elencava.

### Misurato

`run_playtest.gd --runs=100 --seed=7000`, gli stessi 100 semi di D-055, metà
CHR_01 e metà CHR_03, tavolo misto:

| carattere | prima (N/M/V/T) | dopo |
|---|---|---|
| prudente | 0 / 67 / **32** / 1 | 0 / 60 / **40** / 0 |
| aggressivo | 0 / 25 / **69** / 6 | 1 / 28 / **66** / 5 |
| distratto | 0 / 50 / 44 / 6 | 0 / 43 / 52 / 5 |
| ostinato | 0 / 64 / 32 / 4 | 0 / 62 / 34 / 4 |

Il divario in Vittorie fra aggressivo e prudente passa da **37 a 26**. I
fallimenti scendono da 274 a 251 su 596 Consigli. I Consigli per Chronicle
restano 5,96 di media e 6 di mediana — dentro la banda del §7, che è la cosa che
la prima Conseguenza tentata aveva sfondato. I seggi bloccati su un solo livello
restano 0 su 8 a tavolo misto e 3 su 8 a tavolo uniforme.

### La regola

`confluence_rules.opposer_recovers_on_failure`, `false` nei dati delle quattro
Chronicle. Assente o `true` e torna la regola scritta: data-driven e reversibile
come i cap su INFLUENCE ([D-021](#d-021)), perché una deviazione dalla specifica
si toglie senza toccare il codice. `run_playtest.gd --oppose-recovery=1` rimette
il §12.3 originale per un run solo.

### Cosa non ha fatto

Non ha detronizzato l'Oppose: 66 contro 40 resta una distanza. Le altre due
varianti in elenco — l'Oppose che costa un Asset in più, il proponente che sceglie
per ultimo — non sono state misurate, e [D-063](#d-063) ne ha aggiunta una terza
che sembra più mirata di tutt'e tre: **il diritto di proporre**. Il seggio che
vorrebbe l'esito alternativo non prende mai la parola, e il gioco ha già l'azione
che lo sposta.

---

## D-063 — Le proposte che nessuno sceglie: il posto decide chi parla
**measured in 0.1.24** (ISSUES 2 e 3, [D-035](#d-035))

Dopo [D-061](#d-061) restavano dieci proposte su ventitré della seconda saga che
nessuno aveva mai messo ai voti. `cli/run_choice_probe.gd` è la sonda che separa
i tre motivi possibili, che vogliono tre rimedi diversi: la domanda non si pone ·
la proposta non è mai eleggibile · è offerta e non viene mai scelta.

### Cosa è saltato fuori

**«Mai eleggibile» è zero.** In tutt'e due le saghe, 0 proposte su 38. L'ipotesi
che ci fossero clausole di `eligibility` che non si avverano mai è morta lì, ed è
il tipo di ipotesi che sarebbe costato una settimana di riscritture.

**Il tavolo uniforme sotto-riporta.** Con quattro ottimizzatori identici CHR_01
arriva a 13 proposte su 15; con i quattro caratteri di [D-051](#d-051), **15 su
15**. Il contenuto della prima saga è tutto raggiungibile, e a dirlo non era la
sonda che il progetto usava. La misura di riferimento per «contenuto che non
esiste» è il tavolo misto, non l'ottimizzatore.

**Un template che questa Chronicle non può aprire.** CHR_03 dichiarava
`CNF_ANY_SURVIVAL`, ma la sua unica Tensione SURVIVAL — l'Acqua Ferma — ha un
template tutto suo, e `confluence_template_for()` prova prima il legame diretto.
Tre proposte contate come contenuto della seconda saga e mai giocabili. Tolta
dalla lista, e `validate_data.py` adesso lo controlla: la lista di una Chronicle
è documentazione, e una documentazione che elenca contenuto irraggiungibile è una
seconda verità. CHR_04 la tiene, perché pesca le Tensioni dalla biblioteca e lì
si apre davvero.

### Le cinque che restano, e perché

Con il tavolo misto CHR_03 è a 15 su 20. Le cinque che non passano — 
`P_OPEN_LEDGER`, `P_FORGIVE`, `P_DIG_BELOW`, `P_WATCH_THE_ROCK`, `P_BURY_IT` —
hanno una cosa in comune: **esistono solo come cose che qualcun altro vuole
evitare**. `ledger_public`, `debt_forgiven`, `relic_buried` compaiono nei Destini
della saga solo come `state_tag_absent`.

Una sola eccezione, e chiude il cerchio: il Trionfo delle Città Libere **vuole**
`debt_forgiven`. Su 92 Consigli sul Debito in 40 Chronicle il proponente è stato
57 volte Maestra Ilve, 35 volte Kessa, e **zero volte le Città Libere**. Il
proponente è deciso dal posto di cui si discute ([D-036](#d-036)), la Strada dei
Mercanti è di Ilve, e l'unico seggio che vorrebbe rimettere il debito non prende
mai la parola su quella domanda. Lo stesso schema sulla Reliquia: propone
l'Ordine del Vetro 30 volte su 34, e le tre alternative sono esattamente le tre
cose che l'Ordine non vuole.

Quindi non sono proposte scritte male. Sono proposte **scritte per seggi che non
hanno mai la parola**, e le clausole «e nessuno fece X» dei Destini sono gratis
per costruzione.

### Cosa non si è fatto

Non si è toccata la policy. D-035 lo dice già: *tarare la policy finché il suo
contenuto si accende sarebbe adattare la misura alla risposta.* E non si sono
riscritte le cinque proposte, perché la misura dice che il problema non è come
sono scritte.

Quello che questa misura consegna è un candidato per la seconda leva (ISSUES 1)
più mirato dei tre in elenco: **il diritto di proporre**. Il gioco ha già
l'azione che lo sposta — `CLAIM`, scartare una carta AUTHORITY per prenotarsi il
prossimo Consiglio su un tema (§11) — e resta da misurare quanto venga usata.

---

## D-062 — Su un tablet non esiste un F3 da premere
**changed in 0.1.23** (§25.14, rivede [D-054](#d-054))

Il cruscotto stava dietro F3 per una ragione scritta: *mostra anche quello che al
tavolo è coperto, e non è una cosa da premere per curiosità in mezzo a un
Consiglio*. Un tasto funzione è scomodo apposta.

Poi il gioco è stato giocato su un iPad, ed è arrivata la conseguenza che nessuno
aveva previsto: **su un tablet un F3 non c'è**. Non era scomodo, era assente. Lo
stesso vale per F4 e l'anteprima di stampa.

Il ragionamento reggeva contro un bottone *dentro* il flusso delle scelte — dove
si preme per sbaglio, o per curiosità, mentre si sta decidendo. Non regge contro
uno in fondo alla colonna, accanto alle regole, fuori dalla lista che si azzera a
ogni domanda: quello si preme apposta. Quindi il cruscotto ha un tasto, e F3
resta — le due strade chiamano lo stesso metodo, perché due strade che scrivono
lo stesso stato si disallineano il giorno in cui una delle due cambia.

Il tasto si spegne quando non c'è una sessione: il cruscotto guarda una partita,
e un pannello vuoto è peggio di un tasto spento.

### E il log, che era leggibile ma non prendibile

La stessa partita ha prodotto la stessa forma di problema. La cronaca è tutta
sullo schermo, nella colonna di sinistra, e al computer si seleziona e si copia.
Su un tablet no: **una partita finita si può solo fotografare**, ed è esattamente
così che sono arrivate le ultime due segnalazioni — screenshot di un registro
delle Truth.

`scripts/core/log_export.gd` scrive tutto quello che si legge nella colonna — non
le sole righe del `GameLog`, ma anche il menu, le domande fatte a chi gioca e le
sue risposte, perché chi rilegge vuole la sessione e non il sottoinsieme che il
motore considera pubblico. Nel browser via `JavaScriptBridge.download_buffer`,
altrove scritto in `user://` **dicendo dove**: una cosa che accade in silenzio non
è distinguibile da una che non accade.

In testa al file vanno saga, anno e **seme**, e il seme è la parte che conta: un
log senza seme è un racconto, con il seme è una partita che si può rigiocare
identica. Il nome del file lo porta pure lui — `echoes-chr-03-3330.txt`.

Chronicle e anno sono tenuti accanto a `_last_seed` e non letti dalla sessione,
perché il log si scarica quasi sempre **a partita finita**, quando la sessione è
già stata disposta e il registro delle Truth è l'ultima cosa sullo schermo. È lì
che qualcuno preme.

---

## D-061 — Un Consiglio non rimette ai voti quello che ha già deciso
**implemented in 0.1.22** (§12.2 B, estende [D-016](#d-016))

Trovata da una partita vera, non da un test: il registro delle Truth mostrava a
schermo **la stessa frase tre volte** nello stesso anno, con solo i numeri (S O
M) diversi.

### Cosa diceva la misura

La sonda di testo (`cli/run_text_probe.gd`, ora con `--chronicle` e un conteggio
delle ripetizioni **dentro la stessa Chronicle**) su 40 partite per saga:

| | CHR_01 | CHR_03 |
|---|---|---|
| domande poste, distinte | 8 | **5** su 12 scritte |
| proposte votate, distinte | 17 | **10** su 23 scritte |
| Chronicle con una Truth ripetuta | 6 su 40 | **20 su 40** |

Il Debito della seconda saga poneva **94 volte su 94** la stessa domanda e
riceveva 94 volte la stessa proposta. Non era sfortuna: la domanda affilata è
l'ultima in ordine di definizione (D-016), la sua soglia è bassa, e la policy —
che gioca per il proprio Destiny — trova sempre la stessa opzione migliore.
Niente di casuale, quindi niente che il caso potesse variare. Metà del contenuto
scritto della seconda saga non veniva mai al tavolo: [D-035](#d-035) di nuovo,
sulle domande invece che sulle proposte.

### La regola

In B, le domande eleggibili **meno quelle che questa Tensione ha già messo ai
voti in questa Chronicle**. Se non ne resta nessuna il filtro si toglie di mezzo
e tornano tutte, col default di sempre. La memoria sta in
`world_state.questions_asked` — per Tensione, quindi due questioni diverse non si
consumano le domande a vicenda — e si segna alla **risoluzione**, non
all'apertura: una Confluence che si apre e si annulla non consuma niente.

Nasce vuota a ogni Chronicle. È la memoria dell'anno che si sta giocando, non del
mondo: l'anno dopo la stessa domanda si può rifare, ed è giusto che si possa.

### Cosa ha cambiato

Ripetizioni nel registro, su 40 partite: CHR_01 **6 → 2**, CHR_03 **20 → 0**.
Domande distinte poste: CHR_01 8 → 12 (tutte quelle scritte), CHR_03 5 → 7.
Proposte distinte votate: CHR_03 10 → 13.

Sul bilanciamento, `run_playtest.gd` sugli stessi 100 semi di
[D-055](#d-055) — tavolo misto: fallimenti 282 → 274, Decisive 128 → 132,
Consigli per Chronicle 5,96 invariati (dentro la banda del §7). Il divario fra
aggressivo e prudente resta dov'era (61-22 → 69-32): **questa non è la seconda
leva**, e non pretende di esserlo (ISSUES 1). Tavolo uniforme: seggi bloccati su
un solo livello 4 su 8 → **3 su 8**, che è la misura di [D-051](#d-051) e si
muove nel verso giusto senza che nessuno l'abbia toccata.

### Perché non si è invece variata la frase

L'alternativa ovvia era far scrivere al registro «e ancora una volta…» quando una
frase si ripete. Sarebbe stato più economico e avrebbe nascosto il problema: le
tre righe uguali non erano un difetto di prosa, erano il sintomo di un Consiglio
che poneva sempre la stessa domanda. Riscrivere la frase avrebbe lasciato tredici
proposte su ventitre a non esistere.

---

## D-060 — Gli Asset sono scene, le Casate sono ritratti
**changed in 0.1.21** (ART_BIBLE, regola invalicabile 3)

The rule said: *«no faces in the foreground on Asset cards. Assets are forces,
not characters. Faces belong on the Entity cards.»* The first delivered card
broke it - a scribe writing names while a family queues, four readable faces -
and the rule lost.

It lost for a good reason. The rule's job was to keep two decks apart, and it
paid for that with the naturalness of every single Asset card: a Census without
the queue that waits is not a Census, and «shot from behind» is a constraint the
illustrator pays forty-eight times. What separates the decks is not whether a
face is visible - it is **what the picture is of**.

So the distinction moved to composition, where it costs nothing:

- an **Asset** is a *scene* - a place, a gesture, people inside something that is
  happening - and never a single centred figure looking out;
- a **House** is a *portrait* - one figure, close, looking at whoever looks.

MASTER PROMPT 1 now says so in the prompt itself, which means the line reaches
whoever draws through `BRIEF_ARTE.md` instead of living in a document they may
never open.

### Perche' e' scritto qui e non sistemato in silenzio

A constraint broken by the very first delivery is a constraint to rewrite, not
one to quietly ignore - otherwise the deck drifts one card at a time and nobody
can say when the rule stopped being true. This is the second time the ART_BIBLE
has been corrected by something arriving from the outside rather than by
reasoning: the first was the icon set, where the proof sheet refused two glyphs
(D-058).

---

## D-059 — Un posto dove mettere l'arte vera
**implemented in 0.1.21** (ISSUES 5)

The placeholder and the brief have been there since 0.1.18, and the simplest
thing was missing in between: **somewhere to put the picture**. Nothing in the
code loaded a file for an `art_prompt_key`, so a delivered illustration stayed a
file in a folder.

The convention is one line: the key with dots turned into slashes, under
`res://art/`, in PNG. `asset.force.levy` → `art/asset/force/levy.png`. No
manifest, no index to keep in step - **the filename is the key**. A file that
is there shows up; a file that is missing changes nothing, because whoever asks
for a picture that does not exist gets `null` and draws the placeholder. That
property is the whole point: the game has to be playable with none of the
ninety-six illustrations delivered, and with any subset of them.

### Due strade per la stessa immagine, e servono tutt'e due

Reading the PNG's bytes at runtime means a file just copied into the folder
works immediately - no editor, no reimport - which is how it behaves in the
tests, in the CLI and while working. But **an exported build packs the imported
texture and not the original PNG**, so that path finds nothing exactly where
the game is actually played. The exported build was the first thing I checked,
and the board did not appear; the fallback to `ResourceLoader` is what makes it
appear. First one that works wins, and the caller never knows which.

`.gdignore` plus an include filter was the first attempt and it does not work:
an ignored folder is invisible to the editor filesystem, which is what the
export filter walks.

### Il tabellone e' l'unica chiave che non sta nei dati

`map.board` belongs to no Region and no Chronicle: it is the map, which both
sagas share. When it exists the map stops drawing generated terrain and draws
the painting, and the Region positions are taken **literally** from the authored
`map_position` - the painter put the city where the data said it was, and the
0.1.19 trick of stretching the bounding box to fill the view would slide every
token off its painted place.

What stays on top of the painting is only what the picture cannot know: a barely
there veil so a light token on a light field is still visible, the ring of whoever
holds the place, the name with a one-pixel shadow under it, and this year's
marks.

### Verificato con un sostituto

The real board is a painting somebody generated from the brief, and I do not
have the file. So the path was verified end to end with a stand-in PNG built at
the authored coordinates: the six seats land exactly on their painted spots, in
a real exported Web build. The stand-in is **not** committed - a fake board in
the repository would be a lie on screen - and `godot/art/README.md` says where
the real one goes.

---

## D-058 — Le icone di sistema, e il vincolo che le governa
**implemented in 0.1.20** (ART_BIBLE §Overlay e iconografia, ISSUES 6)

The ART_BIBLE asks for overlays and icons as **system graphics**, and states the
constraint that governs them: *«the six-family set must work in monochrome at 16
px: if an icon needs colour to be told apart from another, it must be
redrawn»*. Nothing existed. On the map the four tag levels came out as a column
of grey words, which is how `structure:granary` and `scar:burned` ended up
looking like the same thing.

Twelve glyphs: the six Asset families, the four map levels (`structure`,
`condition`, `settlement`, `scar`) and the two markers (Tension, Echo). Same
three-word vocabulary as the terrain (D-057), same normalised plan, drawn by
Godot on screen and by the SVG writer in print - **and no colours at all**. The
caller picks one. A glyph that reads only because it is gold is not a glyph, it
is a gold smudge.

### Il vincolo ha cambiato due disegni

Both times the proof sheet showed it and no reasoning would have:

- **FORCE was a spearhead**, and at 16 px a spearhead is the Tension marker,
  which is an arrow pointing up. Two signs that merge at the size they are used
  at are one sign. It is now a blade with a crossguard - the only horizontal
  stroke in the set.
- **KNOWLEDGE was a pair of calipers**, which is two legs and a crossbar, which
  is the letter A. A glyph that reads as a letter is not a glyph: whoever looks
  at it starts hunting for the word. It is now an open book, the only shape in
  the set made of two mirrored halves.

### La prova si rigenera

`prova_icone.svg` comes out of `run_export.gd` with everything else: every glyph
at 16, 24, 32 and 64 px, dark on light and light on dark. Putting it in a
document would have meant a picture that goes stale the first time somebody
nudges a coordinate; generated, it cannot.

The tests hold what silence would hide - every family and level in the data has
a glyph, nothing leaves its square, no two glyphs share a shape, and the SVG
carries exactly one colour. They are necessary and not sufficient, and the file
says so: the real check is looking at the sheet.

---

## D-057 — La mappa smette di essere sei cerchi
**implemented in 0.1.19** (ART_BIBLE §MASTER PROMPT 3, §21)

The ART_BIBLE splits the work in two: a person paints the **illustration**, the
code draws the **system graphics** - vector, semi-flat, legible over anything.
Region tiles sit on the line between them, and this is the half that is code's:
the silhouette of the ground, the biome you read from across the table, the calm
centre where the tokens go.

Until now the map was six circles with a name under each. That is a diagram of
adjacency, and adjacency is the one thing about a Region that the game barely
uses. What a player needs at a glance - *where am I, what is this place* - is a
shape and a colour, and both of those generate.

### Un disegno, due supporti

`region_art.gd` returns a **plan** in normalised coordinates - an irregular
hexagon plus strokes in a three-word vocabulary (`poly`, `line`, `dot`) - and
two renderers consume it: `map_view.gd` with Godot's primitives and
`print_sheet.gd` in SVG. **The tile on screen and the tile you print are the
same picture**, not two that resemble each other. That is the same seam as
D-056's `PrintSheet.layout()`, applied one level down.

Six biomes, six vocabularies: roofs and a stretch of wall for the city, striped
fields and a river for the valley, a ridge with snow on one side for the
mountain, tunnel mouths for underground, a road band with stops, low grass and
tracks for the steppe. Deterministic from the region id alone, so two Regions of
the same biome differ and the same Region never changes between two games or two
exports.

### Tre cose che si sono viste solo guardando

- **Il disegno usciva dalla tessera.** The vocabularies are written on the full
  unit square, because that is how you think while drawing - *roofs go low, the
  wall runs high*. A hexagon of radius 0.46 has an inscribed circle of 0.40, so
  the city roofs poked out below the tile edge. Everything is now pulled toward
  the centre by a fixed factor, and a test walks every point of every Region.
- **La tessera stampata era un francobollo.** The art box was a wide rectangle,
  so the square plan was squashed and a mountain stopped being a mountain. Now
  the terrain always draws into a centred square - and a Region tile is
  *full-bleed*: the terrain takes the whole card and the name sits on the ground
  in the lower-left corner, where the hexagon leaves the background bare. The
  description and the asset sources are gone from the tile: they are reference
  text, they do not go on the table, and printing them cost the illustration
  half its size.
- **Il raggio era una costante.** 46 pixels, whatever the window. Six small dots
  in the middle of a full screen waste the one view that says where things are,
  and at that size the terrain is invisible. The radius now comes from the
  space available, and the authored `map_position` box is stretched to fill it -
  which moves everything together and changes nothing about where a Region sits
  relative to the others.

### Quello che questo non e'

It is not the painted art. MASTER PROMPT 3 still describes an illustration that
somebody has to paint, and `brief_arte.md` still generates the prompt for it.
This is the layer underneath, the one the ART_BIBLE always assigned to code -
and it is now good enough that the game is legible without the other one.

---

## D-056 — L'export di stampa, e il segnaposto che mostra la propria chiave
**implemented in 0.1.18** (§25, punto 15)

The 0.1 roadmap carried one unfinished line: *«Export Preview e placeholder
d'arte migliorati»*. `CardView` shipped in 0.1.5, and the other half never did.
What was actually missing was bigger than a screen: **nothing turned the JSON
into a physical component**. COMPONENTS §1 says ECHOES is a physical boardgame
with an app rather than either one, and until now the app was all there was.

### Le facce stanno in un posto solo

`card_face.gd` turns a definition into a **face** - title, subtitle, accent,
corner number, body, notes, footer, art key - and both consumers read it: the
SVG sheet and the on-screen preview. The alternative was two layouts that agree
by hand, which is how the family colours ended up written twice (`asset_card.gd`
and now here) and the Propp function names three times. Both are now single
copies, read from this file.

### SVG, non PNG

An export that gets printed has to be **deterministic and readable**, like the
saves (§18.3). An SVG is text: two exports of the same data are byte-identical,
CI can diff them, and the diff says *which card* changed rather than that six
megabytes of pixels differ. It also needs no rendering context - it runs under
`--headless` with no GPU, like everything else here.

Sheets are A4 at **1:1**: cards 63x88 mm three by three, Region tiles 80x80 two
by three, crop marks outside the cut. The deck is expanded by `deck_copies`, so
48 Asset faces print as 132 cards over 15 sheets (D-040).

### Il segnaposto rispetta il vincolo che l'arte vera dovra' rispettare

The ART_BIBLE asked for a placeholder showing its own `art_prompt_key` «so a
wrong card is recognisable at a glance during playtest», and there was none: the
only graphic in the repository was `icon.svg`. A grey rectangle would have
satisfied the letter. This one is **different for every key**, deterministically
(FNV-1a over the key, then an LCG - never the session RNG, which it must not
touch), and it leaves the lower third calm, which is invalidable rule 2 of the
ART_BIBLE. When real art arrives with the wrong composition it will be obvious,
because the placeholder had it right.

### Il brief legge la ART_BIBLE invece di ricopiarla

`art_bible.gd` parses the three MASTER PROMPTs and their variation keys out of
the document and fills in the subject the data knows. The prompt stays the
document's, the subject stays the data's. If `docs/ART_BIBLE.md` is not there
the brief still comes out, with the pointer instead of the prompt: an incomplete
brief is useful, an export that fails because a prose document moved is not.

Passing every key in the set through one tool also found the gap nobody had
noticed: **the eight Entity keys have no MASTER PROMPT**. Three exist - Asset
card, Echo card, Region tile - and none of them is a portrait. The export says
so, and a test holds the number at eight so it cannot grow quietly.

### Quello che il test ha trovato che l'occhio aveva gia' visto

The first sheets ran the Destiny text past the bottom edge and `DST_LYRA`'s
title past the right one. I saw them because I rendered a PNG and looked. That
is not a method - twenty-five sheets is exactly the amount nobody re-checks - so
the layout became a pure function returning `overflow` and `scale`, and
`test_print_export.gd` asks every face in the set whether it fits. It
immediately found two more (`AST_BONDS_HOSTAGE`, `AST_WEALTH_LAND_MORTGAGE`),
and the fix is that **the illustration yields before the text does**: the art
shrinks to a 34% floor before the body is scaled down at all.

---

## D-055 — Una Condition pagata e sostegno
**implemented in 0.1.17** (§12.3, §A5)

Until 0.1.16 a Condition sat outside the arithmetic entirely. You declared "I am
for this, on one condition", spent up to two Assets to qualify the clause, and
moved the margin by **zero**: the clause attached itself only if the proposal
passed anyway, carried by other people's cards.

Against OPPOSE — three Assets, every point subtracting, and one card back when
the proposal falls — that is not a close call. It is strictly dominated, and the
stance nobody takes is not a stance.

### La misura, prima di toccare niente

100 Chronicles, four characters dealt across the seats (D-053), same 100 seeds:

| | 0.1.16 | col Condition che conta |
|---|---|---|
| Consigli caduti | 315 / 603 (52%) | **282 / 596 (47%)** |
| prudente (NONE/MIN/VIC/TRI) | 0 / 82 / 14 / 4 | 0 / **74 / 22 / 4** |
| aggressivo | 0 / 29 / 63 / 8 | 0 / 30 / **61** / 9 |
| DECISIVE_SUCCESS | 95 | **128** |
| seggi bloccati, tavolo misto | 1 su 8 | **0 su 8** |

### La regola

`M = S + C − O + W`, where C is the Condition front's total **only when the
clause qualifies** (`condition_total >= condition_qualified_threshold`, still 2
in the data). An unqualified Condition attaches nothing and moves nothing, and
the cards are spent all the same: that is the price of negotiating, and it is
what keeps the stance a choice rather than a discount.

`condition_total` and `condition_qualified` stay in the result dictionary, so
the log, the board and the dashboard keep showing the three fronts separately —
the arithmetic changed, what you can read off it did not.

### Quello che non risolve, detto qui

Blocking is still the strongest seat at the table: **aggressivo closes 61
Victories against prudente's 22**. This rule makes CONDITION a live option and
takes five points off the failure rate; it does not dethrone OPPOSE. The ROADMAP
entry "opporsi non costa abbastanza" stays open, and the second lever — a real
price on the Oppose front — is still unmeasured.

One earlier attempt at that price is already recorded as a failure: a Consequence
adding `+1` to the question when a proposal fell made blocking *more* attractive,
not less, and pushed Chronicles over the §7 ceiling. It was reverted.

---

## D-054 — Il cruscotto, cioe le sonde dentro la partita
**implemented in 0.1.16** (§25, punto 14)

Everything this project has learned about its own game arrived through a
command-line probe - the margin, the silence, the Destinies, the playtest - and
every one of them has the same shape: somebody looks at a number nobody was
looking at and finds it has been there for four milestones. The cost of that
loop is that you have to export, replay and read a file, so you only pay it once
you already suspect something.

The dashboard puts the same four tables **inside the Chronicle being played**,
redrawn on every phase: the questions with how much the *world* pushed them and
how much the *table* did, each seat's ladder clause by clause, the Councils with
S/O/margin, and the tail of the Effect register with each line's source.

### Mostra quello che al tavolo e coperto, e lo dice

A veiled Tension's real value, everyone's hand, who pushed what. The screenshot
that verified it is the argument for the design: the player panel on the right
says *"Il Risveglio — velata"* while the dashboard says *"Il Risveglio 5/6"*, in
the same frame. That is exactly what a developer needs and exactly what ruins a
game, so it is behind **F3** rather than a button, and it says what it is in red
across the top.

It shares the middle of the screen with the map, the Council and the rules page,
for the reason all of them share it: somebody reading one of those is not looking
at the table.

### E non sa niente

Like every other view it takes a session and draws what is there - no rule, no
decision (D-038). The one piece of state it keeps is the running total of who
pushed which Tension, because the register holds every push and re-reading three
hundred Effects on every phase change to re-add them would be the one thing in
this screen that does work instead of showing it.

### Un dettaglio che si vede solo guardando

The first draft marked held clauses with a tick. It is not in the font, so a
table of true and false clauses came out as a column of empty boxes - the worst
possible character in that specific place. It uses `[x]` and `[ ]`, which is what
the rest of the game already writes.

---

## D-053 — Il playtest, e dove la D-051 aveva torto
**measured and acted on in 0.1.15**

D-051 concluded that Destiny outcomes cluster - several seats at 37-40 out of 40
on one level - **because every seat is the same deterministic optimiser**, not
because of how the clauses are written, and said it wanted a table of real
players rather than another turn of the knobs. That was a hypothesis stated
without evidence. This is the experiment, and it says the hypothesis was **half
right**, which is the useful half of the result.

### L'esperimento

Four characters, each the same policy with one thing different, none of them
cheating and all of them going through the same legality checks: **prudente**
(never opposes, commits one card fewer), **aggressivo** (blocks anything that
does not help, commits everything), **distratto** (one turn in four does
something else legal), **ostinato** (plays for its Triumph from round one
instead of the nearest rung).

100 Chronicles, 50 per saga, the characters dealt across the seats by a separate
RNG so the *world* is identical in both halves - then the same 100 seeds played
again by four identical optimisers. The difference is the table, not the luck.

### Dove aveva ragione

| seggio | quattro ottimizzatori | tavolo misto |
|---|---|---|
| Le Citta Libere | 0 / **49** / 0 | 21 / 29 / 0 |
| Maestra Ilve | 5 / **43** / 2 | 21 / 24 / 5 |
| Vaerax | 4 / **43** / 3 | 26 / 19 / 5 |
| Priore Anselmo | 11 / **39** / 0 | 26 / 24 / 0 |

*(MINIMUM / VICTORY / TRIUMPH)*

Four seats that looked locked were not: put different people in them and they
spread. Seats stuck on one level go from 3 of 8 to 2 of 8, and the ones that
move are exactly the ones D-051 had been re-writing clauses for. **Those clauses
were not the problem.**

### Dove aveva torto

Two seats do not move, and the cross-tab is what settles it - not "they lose
often" but "they lose no matter who plays them":

| | prudente | aggressivo | distratto | ostinato |
|---|---|---|---|---|
| **Kessa dei Fuochi** | 17 MIN / 0 | 9 MIN / **1 VIC** | 12 MIN / 1 VIC | 10 MIN / 0 |
| **Lyra** | 14 MIN / 0 | 8 MIN / **2 TRI** | 15 MIN / 1 TRI | 10 MIN / 0 |

The best player at the table, holding those two seats, gets past Minimum once or
twice in ten. That is not an optimiser artefact and no amount of varied play
fixes it: **those two Destinies are simply too expensive**, and D-051's "the
cause is not the content" was wrong about them specifically. Written down here
rather than quietly fixed, because the wrong half of a conclusion is worth as
much as the right half.

### E due cose che nessuno stava misurando

**Un tavolo misto scrive una storia molto piu varia.** 511 Truths written, **479
distinct** - 94%. The uniform table wrote 448 and only 322 distinct, 72%. Same
content, same seeds: the variety was in the players all along, which is the
strongest argument yet that the register is doing its job.

**Opporsi non costa abbastanza.** Across 100 Chronicles the aggressive character
finishes 32 MIN / 57 VIC / 11 TRI and the cautious one 86 MIN / 14 VIC / **0
TRI** - not one Triumph in a hundred games. And one aggressive player in four is
enough to take Councils from 149 failures to **302 out of 593**: over half of
everything proposed now falls. Blocking is free and it dominates. That is a
balance finding about the resolver, not about the content, and it is the first
one this project has that came from watching people play differently rather than
from watching one player play well.

### Cosa e stato fatto con il risultato

**I due Destini troppo cari sono stati abbassati, e il playtest lo conferma.**

- **Lyra**: la sua Vittoria chiedeva la scorta giurata *e* che le gallerie non
  fossero sigillate - cioe l'esatta negazione della Vittoria di Vaerax, che deve
  sigillarle. Due Destini che sono l'uno il contrario dell'altro li decide
  l'ordine di parola, che e la stessa trappola gia trovata con la promessa. La
  posta resta a lui, e lei passa da **47 Minimi su 50 a 39 / 0 / 11 Trionfi**.
- **Kessa dei Fuochi**: la sua Vittoria stava tutta su `ash_watch`, che si ottiene
  da *una* proposta di *un* Consiglio - se quel Consiglio non lo apre lei, non
  c'e nessun'altra strada. E' il difetto della D-048 un giro piu in la. Tenere
  la montagna in forze si raggiunge da piu Consigli diversi; la veglia sale al
  Trionfo. Da **48 Minimi su 50 a 45 / 5**, e con la domanda della Cenere resa
  raggiungibile (da 1 con soglia 5 a 2 con soglia 4) arriva a 43 / 7.

Seggi bloccati su un solo livello, a tavolo misto: **da 2 su 8 a 1 su 8** - e a
zero quando la domanda della Cenere si apre abbastanza spesso. Il tavolo di
quattro ottimizzatori, sullo stesso contenuto, ne blocca 4 su 8: la differenza
fra i due numeri e tutta la conclusione di questa voce.

### E il prezzo dell'opposizione: provato e tolto

`CNS_FAILURE_SPIRAL` promette nella propria descrizione *"la questione resta
esattamente dov'era, con meno tempo davanti e piu rancore intorno"* e negli
effetti non alzava niente. Aggiungere `+1` sulla Tensione sembrava la correzione
ovvia: una domanda a cui nessuno ha risposto diventa piu rumorosa, e chi la
blocca se la ritrova.

Misurato, **non ha fatto quello che doveva**: i fallimenti sono passati da 302 a
322 su 100 partite - cioe si e bloccato *di piu*, non di meno - e le Chronicle
sono uscite sopra il tetto del §7 in 4 partite su 24, rompendo anche un piano
scritto a mano. Tolto.

Bloccare resta la strategia migliore: l'aggressivo chiude 29/63/8 e il prudente
82/14/4. Non e una cosa che si sistemi con una Conseguenza, ed e la matematica
del resolver del §A5 - che il §A5 fissa apposta e che non si tocca senza
dirlo. **Resta aperta, con i numeri accanto.**

### Il tetto

Il tetto del §7 nel test passa da 7 a 8, con la stessa aritmetica che aveva
spostato la banda nella D-051: il §7 chiede 3-4 sulle **due** Tensioni del
§18.2, cioe 1,5-2,0 per Tensione, e con quattro Tensioni fa **6-8**. Sette era
un'altra stretta che il progetto si era dato da solo, e ha cominciato a fallire
esattamente quando le correzioni hanno rimesso in gioco due seggi: un seggio che
comincia a giocare rende l'anno piu rumoroso. Il **pavimento non si e mosso**, ed
e la meta a cui il §7 tiene davvero.

---

## D-052 — Un anno lasciato a meta si riprende
**implemented in 0.1.14**

`SaveManager` has existed and been tested since 0.0, and nothing on screen ever
called it. The 0.1 roadmap kept the line open with the reason written next to
it, and the reason was right: the file was never the missing piece. `run()` was
three nested loops that always began at Act 1, round 1, so re-reading a half
played world meant dealing every opening hand a second time and playing the year
again from the top.

### Il punto di ripresa

`run()` now starts from the Act and round the world is on. Two details are the
whole of it, and both were wrong in the first draft:

**The saved round is a finished round.** The world carries the round it was
*in*, and the phase says whether that round completed - anything past ACTIONS
means it did, so the next one is where to stand. Off by one, and the round is
replayed: the same actions twice, the same Drift twice, and the year comes out
different from the one nobody interrupted.

**An Act has an ending of its own.** Stop on the last round of an Act and
`end_of_act` has not run: the Echo card is drawn there, and resuming at the
first round of the next Act would skip it - losing the one move the world makes
without being asked. So a resume that lands past the end of an Act plays that
Act's ending first.

The screen autosaves at THRESHOLD_CHECK, the last thing inside a round, so
coming back costs at most the round in progress.

### Il test che conta

Not "the file round-trips" - `test_snapshot_and_save.gd` already had that. The
one that matters is that **an interrupted year ends identical to an
uninterrupted one**: same Councils, same Destiny levels, same number of Effects,
same last twelve lines of the register. Run at two stopping points, and the
second one is on an Act boundary because that is the branch that would otherwise
silently eat a card.

If that test does not hold, the save is not a save, and a campaign standing on
it is lying.

### Verificato anche dove non era scontato

In a Web build `user://` lives in IndexedDB, which is not a given: a page in
private browsing, or with storage blocked, accepts the write and loses it. So
the screen asks `OS.is_userfs_persistent()` and does not offer to resume when
the answer is no - offering a resume that will not be there is worse than not
offering one.

And it was driven end to end rather than assumed: exported, played three rounds
of Chronicle I in a real browser, **reloaded the page**, and the menu came back
with *"C'e un anno lasciato a meta - Riprendi La Carestia Rossa, atto 1 round
3"* - and pressing it carried the year through to Act 3, round 3, Council and
Echo card and all, with no console errors. The first draft of this entry said
browser persistence was untested. It
said so because the first attempt at the test never finished a round, which is
not the same thing as a failure - and the difference between the two is worth a
second attempt before writing either one down.

---

## D-051 — La parola gira, e una Vittoria si deve giocare
**implemented in 0.1.14**

O-15 recorded that six Destiny levels out of twelve were true before anyone
played, and left it alone on purpose. This is the follow-up, and it separates
two things that were being counted together.

### Quello che era davvero rotto

A **Minimum** that is free is correct: it says "you are still at the table".
A clause asking for a tag to be *absent* is a stake, not a gift - Aldric's
Triumph is 3/3 true at the start and he reaches it 2 times in 40, because the
year takes it off him.

What was broken were two **Victories** made entirely of stakes that nothing ever
attacked: the watcher's (`crystal_exploited` absent, `condition:exploited`
absent) held in 37-40 Chronicles out of 40, and the Order's, which 0.1.11 had
made two stakes while fixing something else. Both seats won their second rung by
sitting down. Each now asks for a thing that has to be obtained in a Council -
the seal for the watcher, the written custodianship for the Order - and neither
is free any more.

### E la parola gira

D-036 narrowed proponency from the domain to the focus Region, which stopped one
seat owning a question by standing in two places. It did not stop one seat
owning a question by standing in *the* place: the ranking is deterministic, so in
a stable matchup the same house opens the same Council in all forty measured
Chronicles and the seat on the other side never puts anything on the table. The
Order proposed **0 Councils out of 262**.

So whoever opened the last Council on a question steps aside, if anybody else is
standing where it is being argued. Measured: the Order went from **0 to 39**, and
the first saga's spread flattened from 94/65/50/35 to 80/52/60/59.

### `promise_kept`, e perche la riga era rimasta aperta

Wiring the promise conditions into a Destiny - an open 0.1 roadmap line - showed
why nobody had: **the policy had never once played FORGE**, so a relation never
moved, so a promise was kept for free and could never be broken. The relation
graph was scenery, which is what O-14 said and nobody followed up. The decider
now forges when a live clause asks it to.

It also showed what *not* to ship: a `promise_kept` facing a `promise_broken`
across the table is decided by turn order, because breaking a promise costs an
action and mending one costs an action *plus* the other seat's consent and a
BONDS card. So the promise is a stake on the Guild's Triumph, and the seat that
comes for it is the Ash Lords' *advanced* Destiny - which only exists once a saga
has run. Contested, but not by a coin already flipped.

### Cosa non si e mosso, e perche non insisto

Outcomes still cluster: several seats sit at 37-40 out of 40 on one level, and
two sit near the floor. Four rounds of content changes moved *which* seats, never
the shape. The cause is not the content: with a deterministic optimiser at every
seat and one Council per question, a seat's result is essentially decided by
whether its Destiny points at a Council it can win. No arrangement of clauses
produces a spread out of that.

Recorded and stopped, which is what O-14 asked for in the first place: this wants
a table of real players, not another turn of the knobs. What *is* fixed is
objective and holds: no Victory or Triumph is won by doing nothing, no seat is
locked out of proposing, and both Chronicles stay inside §7's bounds.

The declared band moved from 5-6 to 6-7 as a consequence, and the arithmetic is
the reason rather than the measurement: §7 asks 3-4 over the **two** Tensions of
§18.2, which is 1.5-2.0 per Tension; four Tensions make that 6-8. Every band this
project has declared was tighter than §7 and said so. 6-7 is the first one inside
it - and what pushed the median there was the watcher starting to play for a
Victory he used to be given.

---

## D-050 — Lo schermo non sa chi siede al tavolo
**implemented in 0.1.13**

D-049 shipped a second saga - four houses, six questions, sixteen Destinies, two
Chronicles, validated, measured, playable from the terminal - and **the browser
could not reach a line of it**. Content that cannot be reached is content that
does not exist, which is the sentence D-035 already wrote about propositions the
policy never chose.

Three constants were the whole reason, and every one of them was a thing the
screen had no business knowing:

- `game_screen.gd` held `const SEATS = ["ENT_ALDRIC", ...]` and passed it to
  `setup()`, so the browser could only ever seat the first saga;
- next to it, a table mapping those four ids to display names, used before a
  session exists;
- `map_view.gd` handed out map colours with a `match` on the same four ids, so
  every house of the second saga came out the same grey - on a map that is the
  same six places.

Everything else on that screen was already reading the data set. These were the
last four names in the UI, and they were load-bearing.

### Cosa fa adesso

**The year is chosen before the seat**, because who is at the table is what the
Chronicle says it is and the two sagas seat nobody in common. The list offers
every Chronicle in the data, oldest first, with its year and whether it writes
its questions out or draws them from the library - so a third saga appears in
the menu by existing.

**Colours are handed out by turn order**, not by name: per Chronicle, stable
inside one, and correct for a saga nobody has written yet.

**The rules page names the people actually at the table**, and is redrawn when
the year is chosen rather than after the seat is picked - a step later it was
still describing the age the player had just declined. It also says how many
cards *this year's* Echo deck holds, which stopped being `echo_cards.size()` the
moment D-049 made the deck a function of the Chronicle.

### Il test

`test_ui_knows_no_names.gd`, and it is deliberately blunt: **no Entity id appears
anywhere under `res://ui`**, checked against every id in the data set, comments
excluded. A screen that names a house has an opinion about which saga is being
played, and it is not entitled to one.

Chronicle ids are not checked: two remain as the fallback for "the data set
failed to load and there is nothing to list", which is a default rather than a
choice.

### Verificato dove conta

Not with a unit test - the bug was invisible to those, and would have stayed
invisible. Exported to the web and driven in a real browser: the menu lists all
four Chronicles, picking *Le Citta Libere* seats Maestra Ilve, Kessa dei Fuochi,
Priore Anselmo and le Citta Libere, the questions panel reads l'Acqua Ferma 3/6
and il Debito 2/7, the Red Mountains are ringed in the Ash Lords' green and the
Merchants' Road in the Guild's gold, and the console reports no errors.

---

## D-049 — Una seconda saga sulla stessa mappa
**implemented in 0.1.12**

The engine has always claimed to be data-driven. This is the first time anything
checked: a second saga - new plot, new houses, new objectives, new questions -
authored entirely as JSON, with **no change to any rule**. What did have to
change was three places where the first saga's content had quietly become part
of the engine's assumptions.

### Le Citta Libere

Eight centuries after Aldric, on the same six places, because the map is the
world and the world does not restart. There is no crown and there has not been
one for eight hundred years. Four seats: **la Gilda del Sale**, which owns no
city and keeps the ledger of all of them; **l'Ordine del Vetro**, heir to Lyra's
school turned into a faith, custodian of a shard nobody living has seen;
**i Signori della Cenere**, who hold the Red Mountains and dig lower every year;
**le Citta Libere**, seven towns that meet only when they cannot avoid it.

Six questions - l'Acqua Ferma, il Debito, la Reliquia, la Carta, i Senza Citta,
la Cenere che Sale - six Councils, thirteen Consequences, sixteen Destinies,
twelve Echo cards, and two Chronicles: CHR_03 written out, CHR_04 dealt from the
library.

### Le tre cose che non erano contenuto

**Il mazzo Echo era uno solo per tutto il gioco.** Adding twelve cards reshuffled
the first saga's deck and changed years nobody had touched - the three authored
sim plans all broke. A Chronicle's deck is now built from the cards that could
matter *that year*: a card whose eligibility names a question the Chronicle is
not asking can never legally be drawn, and leaving it in the pile made one
saga's content a function of the other's. The first saga's plans went back to
byte-identical the moment the filter landed.

**La mappa portava il controllo della prima saga.** `control` lives on the
Region, so the Red Mountains still answered to Vaerax in a Chronicle where
Vaerax does not exist. `starting_control` on the Chronicle overrides it. This
was not cosmetic: the Ash Lords' whole Victory hangs on holding a Region, and
they held none, so they reported MINIMUM in 40 Chronicles out of 40.

**I probe avevano i seggi scritti dentro.** Eleven CLI tools carried
`const SEATS = [ENT_ALDRIC, ...]`. They read the Chronicle now.

### E una lezione della D-048 che si e' ripresentata due volte

Authoring the second saga reproduced the same failure twice, from a standing
start, which is the best evidence that it is structural and not a slip:

- **CNS_ASH_WATCH era irraggiungibile.** It sat on a domain-bound Council, and
  the Tension that would have used it declares its own template - so the
  proposition was never on any table. The Ash Lords' Victory depended on it.
- **Due seggi avevano bisogno dello stesso Consiglio, e a proporlo e' uno solo.**
  Fixing the Ash Lords' proponency took it away from the Order, whose Victory
  then became unreachable in turn. The fix was not another swap: a custodian
  does not win by proposing, it wins by preventing, so its Victory is now two
  stakes - the vault not opened, the galleries not abandoned - and its Triumph
  keys on `discovery:relic`, which a *non*-proponent can obtain by declaring a
  condition clause.

Both were found by `run_destiny_probe.gd`'s third table, which is the one D-048
added for exactly this: **which Councils a seat actually gets to propose**.

### Misurato

CHR_03 over forty seeds: 6.55 Councils per Chronicle, median 7, range 5-7 - the
same shape as CHR_01's 6.10 and inside §7's hard bounds. Every seat wins
sometimes (M38/T2, M12/V28, M1/V39, M2/V38), which is the bar D-048 set and
which the first three drafts of this content did not clear.

Two ten-Chronicle sagas played end to end: the first covers 999 years and writes
**35 Truths, all 35 distinct**; the second covers 753 years and writes 38, all
distinct. The audit that started this whole line of work got 12 distinct
sentences out of 28.

### Cosa resta aperto

O-15 applies to the second saga as much as the first: the Guild reports MINIMUM
in all ten Chronicles of the played saga, and the seats that win, win early and
then hold. Recorded, not tuned - same reason as before.

---

## D-048 — Un Destino che si vince in due mosse, e uno che non si vince mai
**implemented in 0.1.11**

The scholars' seat was broken at both ends of a saga, and neither end showed up
in an outcome table.

### Vinto al round due, quaranta volte su quaranta

`DST_LYRA` asked for: a Discovery, presence in the Ancient Mines, the mines not
sealed, two Discoveries, the Awakening not exploded, the road still open. Seven
clauses, and **five of them were true before the first token was placed**. The
other two were Discoveries - and a Discovery costs *one action*: SCHEME on a
veiled Tension. Lyra has two Action Opportunities in round one and CHR_01 deals
two veiled Tensions.

So her whole ladder - Minimum, Victory *and* Triumph - closed in **Act I round
two, in 40 Chronicles out of 40**, after which she spent the remaining seventeen
Action Opportunities drawing cards she had no use for. The end-of-year report
said TRIUMPH; the register said eighteen turns of shopping. That is O-14's
"Lyra reaches Triumph in four out of five", and the cause was not that her
Destiny was generous - it was that nothing in it had to be played for.

The new `run_destiny_probe.gd` asks the two questions that make this visible, and
the first needs no dice at all: **what is already true before the year starts**,
clause by clause, and **at what round is each seat's ladder closed**.

### And never won at all

`DST_LYRA_TAUGHT` - the Destiny she *advances to* under D-045 - asked in its
Triumph for `crystal_measured`, `petition_heard` and `parley_held`. **No
Consequence in the game writes any of the three**, and none is on the table at
the start. It was not hard to win: it was impossible, which is why the ten-
Chronicle saga reported that seat at MINIMUM ten times out of ten.

Nothing caught it because a tag is a string: it validates, it loads, and it
evaluates to false for ever. `test_data_boot.gd` now walks every
`state_tag_present` clause of every Destiny and insists something in the world
can put that tag there - Consequence, Echo card, or the opening position. Only
`present` is checked: a clause asking for a tag to be *absent* is a stake, not a
goal, and a tag nothing writes just makes it a stake nobody can take.

### What was changed, and what was not

Two clauses added to `DST_LYRA`, none removed:

- **Victory** now also asks for `escort_sworn` - twelve people who answer for
  every load with their own name, sworn in a Council. That is the half of the
  title that was never implemented: *poter tornare a guardare*. Knowing something
  is the Minimum; being able to go back and check is the Victory.
- **Triumph** now also asks that nobody put a guard on the study
  (`study_supervised` absent) - which is the author's own idea of the scholar's
  full win, since that clause was already in `DST_LYRA_TAUGHT`.

`DST_LYRA_TAUGHT`'s Triumph was rewritten onto tags that exist, keeping the
meaning - *what remains taught* is knowledge others can still reach and verify:
the galleries not sealed, an escort sworn, no guard on the study.

A third clause was tried and reverted: `discovery:crystal` on the Triumph, "and
she measured the Crystal herself". It reads well and it measured badly - her
Triumph went to 0/40 and the Council count left its band at 6.20 - so it is
recorded here rather than shipped.

### Measured

Forty Chronicles per figure.

| | prima | dopo |
|---|---|---|
| scala chiusa in anticipo (Lyra) | **40/40**, round 2.0 | 9/40, round 7.0 |
| Lyra | MIN 16 / VIC 4 / **TRI 20** | **MIN 34** / TRI 6 |
| Consigli CHR_01 | 5.70 | 6.10 |
| Consigli CHR_02 | 4.65, da 2 a 7 | 4.83, da 3 a 6 |

The three sim plans still pass and still produce byte-identical output on a
second run. Plan C's description was corrected: it claimed the year ended with
knowledge "public and verifiable", and what the plan actually plays is
`P_GUARDED_STUDY` - the Crystal measurable, but in front of a keeper. Under the
new pricing that is precisely what falls short of what Lyra wanted, which makes
it a better ending than the one the text claimed.

---

## D-047 — Un anno non si chiude senza aver deciso niente
**implemented in 0.1.10**

A ten-Chronicle saga produced **three years with zero Councils**. Not close ones
- zero: three Chronicles in which nobody proposed anything, nothing was decided,
and the register got a blank page. §7 asks for a report below two.

The first guess was that inheritance was suppressing the Tensions across a saga,
because the same Chronicle measured standalone over forty seeds never fell below
one. That guess was wrong, and the instrument that disproved it - `run_silence_
probe.gd` - is the useful part of this entry: per Chronicle it prints, for every
question in play, where it started, how many chips the **world** gave it, how
many pushes the **table** gave it, and where it ended relative to its threshold;
then, per seat, the Destiny it carries and what that Destiny actually asks it to
push. Counting outcomes says a year was quiet. Counting pushes says why.

### What the pushes said

Three separate causes, stacked, each real on its own.

**The world alone can never bring a question to a head.** Drift deals one chip
per round spread across every question in play - nine chips over four questions -
while the smallest gap between a question's opening value and its threshold is
three. So the world can leave **every question in play short at the same time**,
and in the silent years it did: the nearest one finished a single chip under its
threshold, three times out of three. Every Council in this game needs a seat to
push. There was no floor at all; there was only the table.

**And the table had stopped playing.** In the silent years three seats out of
four spent **all eighteen Action Opportunities on ACQUIRE** - drawing cards for a
Council that would never open. The register recorded eighteen turns of shopping.

**Because a seat stopped the moment its nearest rung asked nothing of it.** The
policy played the lowest rung of its ladder it had not secured and nothing else.
That is right about the order and wrong about the stopping: a rung can be open
and still ask nothing of the Tensions - "stand on the Red Mountains" is answered
by walking there - and a rung whose remaining clauses are all *negative* ("the
mine is not sealed", "the road is still open") asks nothing of anybody. A seat
focused on one of those would not even reach for the Victory above it.

### The floor

`minimum_confluences` on the Chronicle. When an Act closes and the year is short
of the Councils it guarantees, the question that came closest is brought to a
head: *"L'anno non si chiude con la domanda ancora aperta."*

The quota grows with the Act - `floor * act / acts`, rounded down - because only
one Council opens per round (§7), so a floor of two checked once at the very end
could only ever deliver one. With three Acts and a floor of two that is nothing
owed after Act I, one after Act II, two after Act III, which leaves the first two
thirds of a Chronicle exactly as they were.

The push is an **Effect** like everything else - system source `YEAR_END`, in the
register, with an inverse - and not a rule reaching into the Tension directly.
`minimum_confluences: 0` turns it off: a Chronicle is allowed to say that silence
is an acceptable ending for it.

### Why a floor rather than a re-tuned Drift bag

The alternative was to weight the drift bag so one question always crosses. It
was rejected for two reasons. It would change **every** Chronicle, including the
seven in ten that were working; and it would make the authored
`drift_distribution` decorative, since the guarantee would always override it.
The floor fires only when the thing it guards against actually happened, and a
loud year never learns it exists - which a test asserts.

### What it measured out at

Standalone, forty seeds each. CHR_01 is **unchanged** - 5.70 mean, median 6,
range 3-8, never below §7's floor even before this. CHR_02 went from a mean of
4.17 and a range of **1**-7 to a mean of 4.65, median 5, range **2**-7, with 0/40
below the floor and 48% inside the declared band. Across four ten-Chronicle sagas
- forty chained Chronicles - there is no longer a single silent year.

The table that only ever calms things down - the O-9 stress test, four seats
spending every action holding every question below its threshold - went from 1.75
Councils per Chronicle to 2.48, which is the first time that table has sat above
§7's floor rather than under it.

The three sim plans still pass and still produce byte-identical output on a
second run.

### What this does not fix

Lyra's whole ladder - Minimum, Victory *and* Triumph - closes in **Act I round
two**, on two SCHEME actions, after which she has genuinely won and correctly
has nothing left to play for. That is a Destiny that is too cheap, and it is
content, not rules: it belongs with the scholars' seat finding (`DST_LYRA_TAUGHT`
depending on a Consequence the policy never triggers), not here.

---

## D-046 — Una casa non finisce i nomi
**implemented in 0.1.9**

D-045 gave every mortal seat a hand-written list of successors. Four names each.
The very first ten-Chronicle audit of the feature wore them out at the sixth
jump and sat a **second "Re Serane" four centuries after the first** - with the
first one's description attached, calling him Aldric's grandson in the year
1240. It read as a bug, and it was one: a saga has no agreed number of
generations, so any finite list is a list that runs out.

### A house declares how it makes names, instead of listing them

`name_grammar`: a pattern with slots (`{given} {epithet} {ordinal}`), a bag of
given names, and whatever else that house uses. The first generations stay
hand-written - those are the characterised ones, and they are worth keeping -
and the grammar takes over from the fifth on.

The choice is a **pure function of the generation**: no RNG, so a name is stable
no matter when it is asked for and a saga stays replayable from its seed.

Numbering is what makes it both endless and right: houses do reuse names, which
is exactly why they number them. Vharn, and four generations later Vharn II.
That is a tradition, not a repeat. Thirty generations, thirty distinct names, in
a test.

### Two things the first attempt got wrong

The generated pool started with the same given names as the hand-written four,
so generation 5 was "Re Serane" again - the very bug being fixed, one loop
further out. And titles cycled independently of names, which produced "Re
Ottima" and "Regina Corvin": in Italian that does not read. The title now
belongs to the given name, because a house knows what its own people are called.

---

## D-045 — Fra una Chronicle e l'altra passano secoli, e il tavolo cambia
**implemented in 0.1.8**

A ten-Chronicle audit produced a register of 28 Truths containing **12 distinct
sentences**, and the most frequent was *"la corona fu divisa in due, e di Eredan
nessuno seppe piu dire a chi rispondesse"* - **six times in ten years**. A crown
does not divide six times. It happened because `inherit_from` added exactly one
year and sat the same four people back down with the same unfinished question.

### The id is the seat, not the person

`ENT_ALDRIC` is the house that holds Eredan. Who is sitting in the chair is
`world.entities` state - name, Destiny, generation - and it changes between
Chronicles. Keeping the id fixed is what lets every Scar, tag, control marker
and relation the previous Chronicle wrote go on pointing at something that still
exists. Everything that shows a name now asks `service.name_of()`; the data file
holds the founder's name and nothing else.

Who survives a jump is authored, not guessed: `persistence` is MORTAL (a person),
COLLECTIVE (a people, which changes without ending) or ETERNAL (a thing under a
mountain). A MORTAL seat crosses 25 years or more with a new name from its own
`successors` list.

### The jump is declared by the Chronicle

`years_after_previous`: an integer, or a `{min, max}` drawn with the seeded RNG.
`CHR_01` is the written year and says 1. `CHR_02` - the library Chronicle that
deals its own questions (D-028) - says 20 to 200, so a saga of library
Chronicles covers centuries and does it reproducibly.

### The three inheritances, each with its own condition

The question was whether a successor inherits the position, the relations, or
the Destiny. The answer is all three - **but if all three carried
unconditionally we would be back to the crown dividing every other spring**. So:

- **La posizione, sempre.** The map is the world and the world does not restart.
- **I rapporti, ma il tempo li smussa.** Across a jump of 50 years or more every
  relation moves one step towards NEUTRAL: a war is remembered as a grudge, an
  alliance as a courtesy. The tags stay whatever happens, because those are the
  things that were written down.
- **Il Destino, ma solo di chi ha fallito.** A seat that reached VICTORY or
  TRIUMPH draws the next thing it wants from its own `destiny_pool`; a seat that
  came out at MINIMUM tries again with the same goal. That is what keeps a
  question alive across generations instead of across springs - and it is the
  one that fixed the audit.

Eight Destinies now, two per seat: what it starts with, and what it wants once
it has that.

### Measured, on the same ten seeds

| | prima | dopo |
|---|---|---|
| anni coperti | 812 → 821 | 812 → **1767** |
| frasi distinte nel registro | 12 su 28 | **19 su 24** |
| la frase piu ripetuta | **6 volte** | 3 volte |
| persone che si sono sedute al tavolo | 4 | **12** |

The three sim plans come out **line for line identical** - the same Councils,
the same rolls, the same endings - because a single Chronicle does not have a
jump to make. What changed is `world.entities`, which now carries a name, a
Destiny and a generation, so the saved JSON of a Chronicle is three fields
larger than it was.

---

## D-044 — Propp was in the deck and nowhere on the screen
**implemented in 0.1.7**

Two card decks exist. The 48 Assets are yours: you draw them, hold them, spend
them, and since 0.1.5 every one of them says what it does. The other deck is not
yours at all - **24 Echo cards, one per function of Propp**, in four dramatic
families of six - and one is drawn at the end of every Act from the pool that
Act allows: Act I only PRESSURE, Act III mostly RESOLUTION. The shape of a story
sits in the deck rather than in a narrator's head (§15).

They move the world on their own (28 direct Effects and 11 Consequences across
the deck), two of the twenty-four **convene a Council on the spot**, and each one
writes `function:<NAME>` into the world so a later card can require an earlier
one - a Return needs a Separation to return from. That is the whole Propp idea,
and it lives in authored data: the engine knows no function names (D-030).

**On screen it was a paragraph scrolling past in the transcript.** Three times a
Chronicle the story turns, and a player saw the turn only if they happened to be
reading the log. Exactly the illness the Council had before 0.1.2, and the same
cure: the card takes the middle of the screen, in its family's colour, with its
text, its Propp function in Italian, **what it just changed**, and a button.

### `act_echo_drawn`, and an Effect said out loud

One signal on the controller, emitted after the hooks land, carrying the card and
the Effects it applied. Nothing in the engine listens to it; it exists so the
screen can say what the card *did* and not only what it says. Guarded by a test
that runs a whole Chronicle and asserts three cards, each with at least one
Effect, each Effect renderable.

`scripts/core/effect_text.gd` is that rendering: an Effect to one Italian line -
*La Successione sale di 2*, *Eredan: condition:contested*, *Cicatrice in Valle
Verde: ...*. Unknown types report themselves by name rather than staying silent,
because a card that quietly did something is worse than a card that says
`SET_ENTITY_TAG`. The one line it deliberately swallows is the `function:` tag:
that is the deck's plumbing, not the player's world.

### What a card looks like now

> PRESSIONE — qualcosa si accumula
> **Presagio**
> funzione di Propp: presagio
> *Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare del
> tutto.*
> COSA HA CAMBIATO
> · Il Risveglio sale di 1

---

## D-043 — The second Chronicle was written, and unreachable
**implemented in 0.1.6**

`CHR_02` has existed since D-028 and is the whole point of the library model: it
names no questions, it **draws four from the six** in the library, so two runs
are not the same year. The CLI could play it (`--chronicle=CHR_02`). The browser
could not: `_play` had `"CHR_01"` written into it.

The menu now asks three things instead of one - seat, year, world - and the
third is the seed. The seed has been printed at the top of every Chronicle since
0.0 *precisely* so a year worth talking about can be played again, which it
could not be until there was somewhere to type it back in. It also offers the
last seed back, because the most likely thing anyone wants to replay is the game
they just finished.

The rules page re-renders for the chosen year, and that turned out to matter
more than expected: it read `chronicle["tensions"]`, which `CHR_02` does not
have. A Chronicle either names its questions or draws them, and a rules page
that assumed the first would have crashed on exactly the Chronicle a returning
player picks. It now reads the pool and says so - *questa Chronicle ne pesca 4
fra queste*.

### And the relations, which the Destinies count

Where you stand with the other three was public information the browser never
showed. It was readable only inside a button offering to break it (*"Rompi i
rapporti con Lyra (ora NEUTRAL)"*), and FORGE spends an Action Opportunity
moving it. Destinies count these levels: a player who cannot see them is being
scored on something invisible. Three lines under the year's questions, coloured
along the ladder from `ENEMY` to `BOUND`.

---

## D-042 — A card that says what it does, and the last decision nobody was asked
**implemented in 0.1.5**

Two holes left over from 0.1, both of the same kind: the rules gave a player
something and the game kept it.

### The recovery

§12.3: when a proposal falls, whoever opposed it **keeps one of the cards they
put down**. `SeatDecider.choose_recovery` handed that straight to the policy,
which took the strongest recoverable card. It was the only decision in the rules
that a person playing the game was never offered - at the terminal and in the
browser alike.

It is asked where the rules ask it: *before* the roll, alongside the commits,
because the controller collects the recovery and only uses it if the Council
falls. So the question is a real one - you name what you would save from a
defeat that has not happened yet - and it is asked only when there is something
to decide. A seat that did not oppose has no recovery; a card whose own rule
says it never comes back is not offered, because a choice the resolver is about
to ignore is worse than no choice; and one card left standing is not a choice
either.

### The card

A hand card carried a title, a family and a number. With the 0.1.3 library that
is not enough to choose with: a quarter of the cards do something to the world
when committed, and "si scarta comunque" is the difference between spending a
card and lending it.

`scripts/core/asset_text.gd` turns an Asset into a sentence, once, for both
front-ends: the bonus in the terms the resolver applies it (`+2 se ti opponi`,
not `+2`), what becomes of the card, and what committing it costs. Every line is
built from the fields the resolution actually reads, so a card cannot say one
thing and do another - guarded by `test_asset_text.gd`, which checks the printed
value against `ConfluenceResolution.asset_value` for every card in the library,
in and out of theme.

The terminal prints it under each commit option. The browser puts it in the
card's tooltip and, in a Council, on the commit cards themselves:

> Interdetto — authority, vale 3
> si scarta comunque · costa: la domanda in gioco sale

### A bug the same code found

The hand computed its own value - `strength if relevant else 1` - which ignored
`confluence_modifier`. Mercenari (forza 1, +1 sempre) is worth 2 and the card
said 1. It now calls `ConfluenceResolution.asset_value`, the resolver's own
function, so the number on the card is the number that enters the sum. This is
the second time this year a hand has shown a value the resolution would not give
(D-040); it is the last time it can, because it is no longer possible to compute
it separately.

The tooltip is drawn rather than defaulted (`_make_custom_tooltip`): Godot's
default one does not wrap, and a card whose authored line runs to 130 characters
painted itself straight across the hand below it.

---

## D-041 — The rules are on the screen where the game is
**implemented in 0.1.4**

A player opened the page, chose a seat, and was handed fourteen buttons. The
rules existed - `docs/RULES_V0_2.md`, complete and current - in the one place a
person sitting down to play will never look.

### The page

`ui/help_panel.gd` takes the middle of the screen, the same piece the map and
the Council share, because a player reading the rules is not looking at the
board and the board is where there is room to read. It opens by itself at the
seat menu, closes itself when a Chronicle starts, and is one always-present
button away for the rest of the year - outside `_buttons`, which is cleared
after every question.

Half of it is written from `DataSet`: the shape of the year, the four questions
with their thresholds and the families each one listens to, the Regions, the
hand limit, the commit limit. A rules page that can fall out of step with the
rules is worse than no rules page, so everything that *can* drift is read rather
than typed.

### The line above the choices

The page explains the game once. The line explains *this turn*, every turn:

> La domanda piu vicina a scoppiare e La Carestia, a 3 passi. (e 2 che non puoi
> ancora leggere)

> La Carestia e a un passo dalla soglia: un'altra spinta e si apre il Consiglio.

> Consiglio aperto: qui valgono forza piena le carte wealth, people, authority.

It reads exactly what the seat is entitled to read - `visible_tension_value`
returns -1 for a veiled question nobody has scouted - so it can say *there is
something here you cannot see* without ever saying what. And the last form is
the one that ties the whole screen together: it names the families that count,
while the hand below each card says `vale 2` or `vale 1` for that same question.

### Still no rule in the screen

Neither piece decides anything or asks the rules a question a decider does not
already ask. The line reads thresholds and visible values through the same
services `StatusPanel` has used since 0.1; the page reads authored data. The
seam is where it was (D-038, D-039).

---

## D-040 — 48 Assets, and the outcome table they moved
**implemented in 0.1.3**

§19.4's full Asset list: 12 cards become 48, eight per family. The cards were
the easy half. The half worth recording is that adding them **broke the outcome
table**, and that the number which showed why was not the one being watched.

### What the set is

One word - the rarity - fixes everything mechanical about a card:

| rarità | forza | copie nel mazzo | per famiglia |
|---|---|---|---|
| COMMON | 1 | 4 | 4 carte |
| UNCOMMON | 2 | 2 | 2 carte |
| RARE | 3 | 1 | 2 carte |

22 cards per family deck, 132 in the box. A player who has seen a family twice
knows what is in it, which matters more than it sounds: ACQUIRE draws two and
keeps one, so knowing the deck is knowing what the other draw probably was.

Every family carries the same shape: two cards that pay on the Oppose front,
one that counts for more when the question is its own, and two rares that are
worth 3 and cost something on the way out. Every strength-3 card is discarded
whatever happens **and** does something to the world when committed - it raises
the Tension, or hands the rival a foothold where the argument is, or empties
your own. That is guarded by a test: a card worth 6 in a relevant question with
no downside is not a choice, it is the correct play.

`on_commit_effects` was exercised by exactly one card in 0.0 (O-3). It is now on
thirteen.

### The outcome table broke, and the average said nothing

Measured over the same 40 Chronicles, before and after:

| | Failure | con Costo | Successo | Decisivo |
|---|---|---|---|---|
| 12 carte | 16% | 13% | 38% | **33%** |
| 48 carte, primo tentativo | 15% | 11% | 26% | **49%** |

Half of every Council passing without discussion is the same illness as O-4 in
the other direction: two of the four bands stop meaning anything.

The strange part: **the average margin barely moved** - 3.23 to 3.37 - and S was
identical to two decimals. Four separate attempts to fix it by re-weighting the
set (fewer copies of the strong cards, more copies of the weak ones, bigger
Oppose bonuses, dropping strength 3 entirely) each moved the outcome table by
almost nothing, because each was aimed at the average.

`cli/run_margin_probe.gd` printed the distribution instead, and the cause was
immediately visible: the 12-card set piled its mass on **M = +4**, one point
below the Decisive band, because with two cards per family a commit was almost
always 2+2. A wider library smooths the distribution and pushes that pile one
point right - over the line. The old 33% was partly an artefact of a library too
poor to produce anything else.

### The fix, and why it is the curve

The lever that worked was the shape of the curve, not the weights: relevance
moved off the strength-2 cards and onto a strength-1 card in each family, and
one strength-2 card per family became a strength-1 with a small always-on bonus.
A prepared commit is worth about 4 again instead of 6.

| | Failure | con Costo | Successo | Decisivo |
|---|---|---|---|---|
| 48 carte, com'è ora | 21% | 15% | 30% | 34% |

Decisive is back where it was and Failure is up five points - more Councils are
genuinely contested, which is what a wider library was supposed to buy.

The resolver was not touched. §A5's bands are the specification; the content is
what gets tuned (D-023).

### The cost, stated

- **Councils per Chronicle: median 5 → 6**, and one Chronicle in forty reaches 8
  against §7's ceiling of 7. `test_balance` allows 10% outside the band and it
  passes, but the drift is real and it is the number to watch in 0.2.
- **The three sim plans came out differently** and were re-measured rather than
  re-tuned: the stories still hold (the grain accord passes unopposed, the broken
  council fails twice, the opened mine plays all four bands), the outcome
  sequences in their `expected` blocks are new. Plan A's authored Council now
  binds to index 1, because with a full library the Succession opens first.

### A bug the measurement found

`ui/hand_view.gd` had been drawing a relevant card as `authority · 2 ×2 = 4`
since 0.1.1. §9 says an Asset is worth its full strength when its family is
relevant and **1** otherwise - relevance does not double anything. The card was
telling a player their hand was worth twice what the resolver would give them.
It now reads `authority · vale 2`, and `vale 1` when the question is not its own.

---

## D-039 — A choice knows what it is about; the screen decides where to put it
**implemented in 0.1.2**

0.1 drew a map and then asked where to move in a list beside it. Both halves
worked and the pair was absurd: six Regions on screen, and the way to walk into
one of them was to read "Metti una presenza in Terre Nahr" off a column of
fourteen buttons.

### What was added, and what deliberately was not

`SeatDecider` now hands `io.choose` a third argument: `subjects`, one entry per
choice, saying what that choice is *about*. Today it holds exactly one thing -
`{"region": "REG_X"}` on a MOVE - and it is a fact about the choice, not an
instruction about the screen.

The alternative was to let the map ask the rules which Regions are reachable.
That is the version to avoid: it puts a legality query in a drawing node, and
two answers to "where may I go" that can disagree. Instead the map is handed a
set of Regions and what to report when one is pressed, and it can no more invent
a legal move than a button could. The terminal takes the same argument and
ignores it — a numbered list is already all the map a terminal has.

So: the screen sorts the choices between the map, the open Council and the side
column; it does not judge them. Every entry it puts on the map is an entry it
would otherwise have put in the column, unchanged.

### The moment the game decides something was never on screen

`ConfluenceController.resolve()` runs F-K in one atomic pass and clears
`current` on the last line. Nothing in the loop ever came back to draw the
result, so the roll, the sum and the Consequences existed only in the transcript:
the `Fattore Mondo` line added in 0.1.1 could not be seen at all.

The screen now keeps the snapshot it is handed at `RESOLVED` and stops on it -
board, stances, commits, the arithmetic, what it wrote - until the player presses
Avanti. No decider is asked anything, because there is nothing to decide. It is
the screen's own pause and it lives entirely in `ui/`.

### `result["consequence_ids"]`

One engine addition, and the reason for it is the seam: which Consequences apply
depends on the outcome (success takes the proposition's own, plus the cost or the
decisive pool; failure takes the failure pool). Re-deriving that in the board
would be the resolution order written down twice, in a place that could quietly
fall out of step with §12.2. So the resolution reports what it applied, by id and
in order - the list the log has printed since 0.0 - and the board looks the ids
up. The three sim plans come out byte for byte identical.

### What the middle of the board holds now

Before the vote, the Consequences the proposition on the table would write, with
a Scar marked as a Scar. After it, the ones that actually landed. "Sostieni" and
"opponiti" mean nothing until you can read what you are supporting, and until
0.1.2 the only way to find out was to lose and read the log.

### Two things the browser found again

The arrow in `1d6 = 6 → +2` is a tofu box in the fallback font a Web export
ships - the same class of bug as the check mark in 0.1, in the one line a player
reads to check the arithmetic. It is `->` now. And the whole feature was verified
by clicking a Region in Chromium and watching a presence appear in it: a map that
lights up and does nothing when pressed is a bug no headless run can see.

---

## D-038 — The Chronicle can wait for a click
**implemented in 0.0.14**

ECHOES runs in a browser, on GitHub Pages, from `godot/ui/`. Getting there
needed one engine change, one refactor, and three bugs that only a real browser
could find.

### `run()` is a coroutine now

The controller drove the whole Chronicle in one synchronous call. A terminal can
block on `read_string_from_stdin` inside that call; a browser cannot block on a
click without freezing the page and never receiving it.

So the six decider calls are `await`ed, and `run()`, `play_act()`, `play_round()`
and `run_confluence()` became coroutines. **Nothing else changed.** A decider
that answers immediately never suspends - `await` on a synchronous call returns
straight away - and the proof is that the three sim plans come out **byte for
byte identical** before and after, as do all six probes.

The cost was 22 call sites needing `await`, which the compiler found one
transitive layer at a time. That is the right kind of cost: mechanical, and
impossible to get half-right silently.

### `SeatDecider`, and why injection beat inheritance

The terminal seat and the browser seat differ in exactly two things: how a line
is shown and how a choice is collected. Everything else - which actions the
rules allow, what the board looks like from one seat, which Tension shows a
number to whom - must be the same code, or it is two implementations to keep in
agreement.

The first attempt had the browser decider `extend` the terminal one. **The
exported build could not resolve it**: `extends "res://path.gd"` does not survive
export, while `preload` does. That is exactly why this codebase uses
`const X := preload(...)` and no `class_name`, and the rule held here too.

So the shared logic moved to `scripts/seat/seat_decider.gd` with an injected
`io` - any object with `say(text)` and `choose(prompt, labels) -> int`.
`cli/terminal_io.gd` implements it with stdout and stdin; `ui/game_screen.gd`
*is* the implementation for the browser. A null `io` means nobody is watching,
and every choice defers to the policy - which is what the smoke test uses, and
why it can assert that an unwatched table plays exactly like four policies.

### Three bugs only the browser found

Playwright loaded the exported page and clicked through a Chronicle. Each of
these passed every headless check first:

1. `ui_decider.gd` extended `cli/human_decider.gd`, and `cli/*` is excluded from
   the export. Unresolvable script, blank page.
2. `scripts/seat/` was missing from the pack entirely: the export ran before the
   import cache had seen the new folder. The workflow now imports first.
3. `policy_decider.gd` lived in `cli/`. It is the opponent - the browser needs
   it. Moved to `scripts/seat/`, where a seat played by a machine belongs.

None of the three is exotic, and none would have been caught by anything short
of opening the page. A build that compiles and exports is not a build that runs.

### Single-threaded on purpose

The threaded Web export needs `SharedArrayBuffer`, which needs COOP/COEP
response headers, which GitHub Pages cannot send. `web_nothreads_release` is the
template used. A turn-based game that spends its life awaiting a click has
nothing to gain from threads and everything to lose from not loading at all.

### What this is not

A map, a Confluence Board, art. It is a transcript and a column of buttons -
0.1's work, unstarted. What it is, is the seam holding: the screen decides
nothing and reads no rules, so the game in the browser is the game the terminal
plays and the tests measure.

---

## D-037 — The fifth decider is a person
**implemented in 0.0.13**

The ChronicleController has never known who its players are. It asks a
duck-typed `decider` and applies whatever comes back, and four of those existed
for machines: ScriptedDecider replays authored plans, PolicyDecider plays to
win, SuppressorDecider only ever calms things down, and the stance probe borrows
PolicyDecider to read its own mind. `cli/run_hotseat.gd` adds the fifth, and the
first one that does not decide anything itself.

**No rule was special-cased for it.** That is the result worth recording: the
decider seam, chosen in 0.0.1 so a simulation and a UI could share one engine,
held without a single change to the controller.

### Why now

The measurements have run out of things to say. D-034, D-035 and D-036 each
found the *instrument* at fault rather than the rules, and what is left open is
O-14 — the crown sits at Minimum in 32 Chronicles out of 40 — which is a question
about whether a game feels right. No probe answers that. The honest next step is
to stop modelling a player and let one sit down.

### What a seat actually needs to see

The board prints from one seat's point of view, and every line of it is
something that seat is already entitled to know: the year's questions with the
numbers *that viewer* can read (a veiled Tension shows nothing to anyone who has
not scouted it, §11.1), the map, the hand, and the Destiny as a ladder with the
rungs that currently hold already ticked. A player who cannot read their own
goal cannot steer towards it.

The action menu is built by asking the resolver, not by listing templates: every
entry has already passed `can_execute`, so a person is never offered something
the rules will then refuse. That is the query the 0.1 Confluence Board will draw
as buttons.

### The empty string that locked players out

`OS.read_string_from_stdin` returns **the same empty string** for a bare Enter
and for end-of-input. They cannot be told apart — measured, not assumed.

The first version tried anyway: on an empty read it latched itself off and handed
the rest of the Chronicle to the policy. The effect was that **a player who
accepted a single default was locked out of their own game**, silently, with
nothing crashing.

The fix is to stop trying. An empty answer means "you decide" and hands that one
choice back to the policy — which is also exactly the right behaviour at
end-of-input, where every remaining prompt reads empty, takes the default, and
the policy finishes the Chronicle. One meaning, no ambiguity, and piping a file
of answers becomes a faithful way to drive the game.

`tests/smoke/test_hotseat.gd` guards it: a table of four "humans" who answer
nothing must produce a Chronicle **identical line for line** to one played by
four policies, and every action the menu offers must be one the resolver accepts.

---

## D-036 — Who raises a question is decided by the place, not the domain
**implemented in 0.0.12** · closes O-12, closes O-13, closes the Vaerax lock

Three open findings, fixed together because they turned out to be one problem
seen from three sides: **nobody had a reason to be in the room.**

### The rule change

`determine_proponent` read §12.2 C's "most presence in the Tension's Regions" as
the whole **domain**. It now reads it as the Region the question is actually
about — the same focus the narrative and the Consequences already use.

Counting the domain let one Entity own a question for ever. `domain:ANCIENT` is
two Regions and Vaerax's Destiny plants him in both, so all 40 Councils on the
Awakening were his and he was never a voter on the only Tension he cares about.
D-034 called that a content shape; it is not. Two candidate widenings of the
domain were tried and measured, and **neither breaks the lock** — one makes it
worse, raising 107 Councils that are also all his. Counting the focus asks a
narrower and truer question: who is standing in the place we are arguing over?

| domanda | proponenti prima | proponenti dopo |
|---|---|---|
| Le Vie Interrotte | 2 | **4** |
| La Successione | 1 | 2 |
| La Carestia | 2 | 2 |
| Il Risveglio | 1 (Vaerax 40/40) | 2 |

### O-12: two Tensions nobody had sworn anything about

Every `tension_limit` in CHR_01 named the Famine or the Awakening. The Succession
and the Roads were in nobody's Destiny, so those Councils could not produce a
fight over the quantity itself.

The first attempt added `tension_limit` clauses and **made it worse**: a ceiling
makes the policy spend actions holding the Tension down, and holding it down
makes the question stop being asked. The Roads went from 36 Councils to 6.

The fix is that a stake does not have to be a `tension_limit`. A **tag** weighs on
propositions and drives no actions at all:

| | posta | dove |
|---|---|---|
| Aldric | `crown_divided` assente | Triumph |
| Nahr | `crown_divided` presente | Triumph |
| Lyra | `condition:cut_off` assente sulla Strada | Triumph |
| Vaerax | `condition:cut_off` presente sulla Strada | Triumph |

Two pairs of directly opposed stakes on the same tag — the same crown and the
same road, wanted two incompatible ways. And they sit at **Triumph**, not
Victory, for a mechanical reason worth writing down: `_live_conditions` drives
*actions* from the lowest unreached level, while scoring a proposition reads
*all* levels. A clause at Triumph therefore gives an opinion in the room from
turn one without making anyone spend actions to smother the question.

### O-13: a proposition nobody would ever make

`P_ANY_LEAVE`'s success Consequence took presence and control from the
**proponent**. First attempt: give it a payoff, `ADJUST_TENSION $tension -2` —
the question goes quiet because nobody is left to ask it. Not enough, and the
measurement said why: `P_ANY_RATION` offers the same relief *plus* the Region,
so leaving stayed strictly dominated.

The right payoff was in the Consequence's own category, which is **MIGRATION,
not LOSS**: whoever leaves arrives somewhere. `ADD_PRESENCE $proponent` in
`$adjacent`. `P_ANY_LEAVE` now reaches a vote 7 times in 40 Chronicles and
`condition:abandoned` is written for the first time.

### The band moves from 4-5 to 5-6

Measured, isolated, and declared rather than quietly adjusted. Different
proponents ask different questions, whose Consequences move the Tensions
differently; reverting D-036 alone puts the median back at 5.

The justification is not "the test failed". §7's 3-4 over the two Tensions of
§18.2 is 1.5-2.0 Confluence **per Tension**; D-026's 4-5 over four Tensions is
1.0-1.25 — it was stricter than §7 ever asked for. Measured over four blocks of
forty Chronicles the rate is now 1.3 per Tension, still below §7's own, with a
median of 5 in three blocks and 6 in the fourth.

### After

| | D-035 | D-036 |
|---|---|---|
| consigli con almeno un no | 28% | **50%** |
| seggi che si oppongono almeno una volta | 3 | **4** |
| opposizioni di Vaerax | 0 | **26** |
| mappe di controllo distinte | 8 | **16** |
| stato finale distinto (su 40) | 38 | **40** |
| Scar per Chronicle | 1.60 | **2.00** |
| tag mai scritti (CHR_01 / CHR_02) | 3 / 1 | 3 / **0** |
| FAILURE / SWC / SUCCESS / DECISIVE | 25/23/62/80 | 45/24/60/79 |

Every one of forty Chronicles now ends in a different world state.

### The three sim plans had to be re-authored, and one of them explains itself

Plan B's Nahr moved a token to the Merchant Road to win the SURVIVAL domain.
Under D-036 that is the wrong place: the Council is about the Valley. Moving it
to the Valley restores the plan's story exactly — the Nahr ask for the land and
the whole table says no, **S1 O7 M−4**.

Plan A dropped from three Councils to two, and the reason is the game working:
the decisive requisition fires `CNS_VALLEY_CLEARED`, which clears the Nahr out of
the Valley, and without that presence nobody can touch the Roads for the rest of
the year. The plan now says so in its own description rather than asserting a
number that used to come out.

---

## D-035 — The first question of every Council was never asked
**implemented in 0.0.11** · closes O-8, closes O-6

Went looking for content to write and found the instrument again — but this
time the finding was worth more than the fix.

### The measurement

The stance probe was extended to tally which question/proposition pairs actually
reach a vote. In forty Chronicles, **seven pairs out of eighteen propositions**:

```
Q_AWAKENING_MOUNTAIN / P_GUARDED_STUDY   40      <- every single Awakening Council
Q_FAMINE_LAND        / P_LAND_TO_WORKERS 43
Q_ROADS_ESCORT       / P_SWEAR_ESCORT    36
...
```

Every template's **first** question was missing. `Q_FAMINE_GRAIN`,
`Q_AWAKENING_CRYSTAL`, `Q_ROADS_TOLL` — never asked once.

### Why

Two things met, and neither is a rule:

1. `_select_question` defaults to the **last** eligible question, on the reasoning
   that later questions are the sharper ones (D-016).
2. Every second question is gated on its Tension being at threshold — and a
   Council only *opens* when its Tension is at threshold. So the second question
   is essentially always eligible.
3. `PolicyDecider.choose_question` returned `""`. It declined to choose, so the
   default won every time.

The default is fine; a human at the table is offered both questions by
`available_questions()`. **The policy simply never reached for the other one.**
So O-8's "content that cannot be reached" was never unreachable — it was content
the measuring player never reached for.

### The fix

`choose_question` now scores a question by the best proposition behind it, with
the eligibility check the Council itself uses, and breaks ties on the session
RNG. Twenty lines, the same shape as D-033.

### After

| | prima | dopo |
|---|---|---|
| coppie domanda/proposta votate | 7 | **12** |
| tag di Regione mai scritti | 9 | **3** |
| consigli con almeno un no | 16% | **28%** |
| FAILURE | 23 | **25** |
| SUCCESS_WITH_COST | 6 | **27** |
| DECISIVE_SUCCESS | 105 (57%) | **76 (39%)** |
| mappe di controllo distinte | 3 | **8** |
| stato finale distinto | 32 | **38** |
| Scar per Chronicle | 1.15 | **1.60** |

And the Destinies unfroze. The saga of ten Chronicles had Lyra at TRIUMPH ten
times out of ten and Vaerax at VICTORY ten out of ten, every year, identically:

| | prima | dopo |
|---|---|---|
| Aldric | MIN 35 / VIC 4 / TRI 1 | MIN 18 / VIC 10 / **TRI 12** |
| Lyra | **TRIUMPH 40 / 40** | MIN 23 / TRI 17 |
| Vaerax | **VICTORY 40 / 40** | VIC 22 / TRI 18 |

That is O-6 closed: all four outcome bands are populated, and no seat has a
predetermined ending any more.

### What stayed shut: Vaerax owns his own question

D-034 found that Vaerax abstained 144 times out of 144, because **all 40 Councils
on the Awakening are opened by Vaerax himself**. That was called a content shape
and left for the content pass. It is not fixable by content, and this was
measured rather than argued.

`determine_proponent` is "most presence in the Tension's domain" (§12.2 C).
`domain:ANCIENT` exists on exactly two Regions, and Vaerax's Destiny plants him
in both. Two candidate widenings were tried and measured:

| | Consigli sul Risveglio aperti da Vaerax |
|---|---|
| oggi | 40 / 40 |
| `domain:ANCIENT` anche a Eredan | 107 / 107 |
| `domain:ANCIENT` anche alla Strada dei Mercanti | 40 / 40 |
| entrambe | 107 / 107 |

Widening the domain does not break the lock — it just raises more Councils that
Vaerax also owns. The lock is structural.

A rules change would break it: reading §12.2 C as presence in the Tension's
**focus Region** rather than its whole domain. Measured, it opens the Roads to
three proponents and the Succession to two — and still leaves the Awakening at
Vaerax 42/42. Recorded, not taken: it is a design decision about what a Council
*is*, and it belongs to the author, not to a balance pass.

The visible cost is that `P_EXPLOIT` is never proposed, so `condition:exploited`
is never written. The guardian of the mountain never puts "let us dig" to the
vote, which is either exactly right or exactly the problem, depending on whether
the Awakening is supposed to be a question the table argues about or a question
one seat owns.

### The guard, and why the first version of it was wrong

D-034's guard counted how often each Effect type moved the score during real
games. It failed the moment this change landed — not because the policy had gone
blind, but because the propositions that now come forward adjust the Succession
and the Roads, **which no Destiny in CHR_01 names** (O-12).

A guard that cannot tell "the policy is blind" from "the content moved" is worse
than none: it cries wolf at a content change, and it would be silenced by tuning
the content until it stopped firing. Rewritten as four constructed cases — build
the situation a Destiny describes, assert the policy has an opinion about it —
and verified by removing each branch in turn.

---

## D-034 — The table abstained on 96% of propositions, and it was the policy again
**implemented in 0.0.10** · addresses O-6

O-6 has been open since D-024: Failure and Success with Cost stay thin however
the content grows. The saga of ten Chronicles put a number on the mechanism -
**40 of 42 councils passed with zero opposition** - without explaining it.
Opposition is the only term that can push a margin down (M = S − O + W), so a
table that never opposes cannot produce anything but Success. This is the
measurement, and what it found.

### The measurement

`cli/run_stance_probe.gd` plays the same 40 Chronicles the balance probe plays
and records, for every non-proponent at every council, the score the policy
computed and the stance that score produced - plus, for every Effect in the
proposition's Consequences, whether that Effect moved the score **at all**.

The second tally is the one that matters. An Effect type read hundreds of times
and never worth a single point is not a quiet Effect; it is an axis of conflict
the policy cannot see, no matter what the content says.

| | letto | pesato | |
|---|---|---|---|
| `ADJUST_TENSION` | 489 | **0** | ← mai |
| `SET_CONTROL` | 210 | **0** | ← mai |
| `SET_ENTITY_TAG` | 300 | **0** | ← mai |
| `SET_RELATION` | 171 | **0** | ← mai |
| `SET_GLOBAL_TAG` | 579 | 11 | |
| `SET_REGION_TAG` | 408 | 11 | |

96.0% ABSTAIN, and the score took exactly three values in 573 stances: −2, 0,
+2. Only the tag branch of `_score_effect` ever fired. The presence branch (±3)
and the control branch (+2/−3) never fired once.

### Why each axis was dead

- **`ADJUST_TENSION`** — the commonest Effect in the Consequence set, and
  `tension_limit` is a clause in every one of the four Destinies. The two never
  met: a proposition that shoved the Famine up by two scored **zero** against a
  Destiny whose Victory says the Famine must stay under three.
- **`SET_CONTROL`** — every authored target is a slot (`$region_focus`,
  `$rival_seat`, `$capital`, `$region_with:trade`) since D-032, and
  `_score_effect` returned early on anything it could not find in
  `world["regions"]`. The comment said a policy reading a proposition in advance
  "cannot know which Region that is". **That was simply wrong.** The Council
  fixes its bindings at step A, before a single stance is declared.
- **`SET_ENTITY_TAG`** — Lyra's whole Destiny counts Discoveries, and Discoveries
  arrive as `SET_ENTITY_TAG discovery:*`. Nothing scored them.
- **`SET_RELATION`** — legitimately silent: no Destiny reads relations.

### The fix, and where it belongs

In the policy, not the content. The conflicts were **already authored** - a
proposition that raises the Famine against a people whose Destiny caps it is a
fight the data had written and the instrument could not read.

`ConfluenceController._context()` became public as **`effect_context()`**, and
the policy resolves slots through the Council's own binding table rather than a
copy, so the policy's idea of a proposition and the Effects the Council applies
at K cannot drift. Three branches were added:

- `ADJUST_TENSION` vs `tension_limit`: **−2** for the push that breaks a clause
  currently holding, **+2** for the one that repairs a broken one, ±1 for merely
  moving the wrong or right way inside the band. Breaking a clause is worth a no;
  disliking a direction is worth a clause.
- `SET_ENTITY_TAG discovery:*` vs `discovery_count`: **+2**, and only to the
  Entity receiving it — someone else learning something costs you nothing.
- Slot resolution, which is what brought `SET_CONTROL` and `REMOVE_PRESENCE`
  alive without touching their scoring at all.

### After

| | prima | dopo |
|---|---|---|
| ABSTAIN | 96.0% | **84.1%** |
| OPPOSE | 2.8% | **5.4%** |
| SUPPORT | 1.2% | **10.5%** |
| consigli con almeno un no | 16 (8%) | **30 (16%)** |
| valori distinti del punteggio | 3 | **7** |
| FAILURE (su ~180 Confluence) | 7 | **23** |
| SUCCESS_WITH_COST | 7 | 6 |

Failure roughly tripled, from 4% of councils to 12.5%. Success with Cost did not
move, and that is expected rather than disappointing: it is band 0–1, two values
wide, and a wider spread of margins does not preferentially land there.

### What it did not fix, stated plainly

`DECISIVE_SUCCESS` is still 105 of 184 (57%). O-6 is **narrowed, not closed**.

And one seat still never opposes: Vaerax abstained 144 times out of 144. The
room tally says why, and it is not the policy - **all 40 councils on the
Awakening were opened by Vaerax himself**. He owns his question outright, so he
is never in the room as a voter on the only Tension his Destiny names. That is a
content shape, not a blind spot, and it wants a content answer.

Third time the same lesson, after D-021 and D-033: when the balance looks wrong,
suspect the instrument before the rules.

---

## D-033 — Two more ways to aim: the neighbour, and a kind of place
**implemented in 0.0.9** · closes O-11

O-11 measured the cost of D-032: `$region_focus` is *stable* for a Tension, so
every Consequence of that Tension landed on the same place and the control map
stopped moving. Two slots answer it, and a third finding explains most of it.

### `$adjacent` — where the trouble spills

The Region next to the one under discussion, picked as the neighbour **carrying
the fewest marks already**. Damage spreads across the board instead of piling up,
and it reads right: the trouble goes where it has not been yet. Ties go to the
Chronicle's Region order, so the same board always spills the same way.

Used by the five Consequences whose narrative is overflow rather than target -
the unrest that does not stay where it was born, the road cut on the far side of
a plundered one.

### `$region_with:<tag>` — a kind of place, not a place

A parameterised slot: the first Region in Chronicle order carrying that tag,
preferring one that is *not* the Region already under discussion. A Consequence
can now say **the granary**, **the crossroads**, **the crystal site** and travel
from one Chronicle to the next without knowing the map.

Resolved by `ConsequenceCompiler`, which needed a world reference for it - every
other slot is filled by whoever builds the context, because only they know what
the Confluence is about; this one asks the board a question instead.
`validate_data.py` checks the tag is one some Region actually declares, so a
`$region_with:granray` fails at build time rather than silently resolving to the
focus.

### The third finding, and it was the big one

The two slots helped (distinct tag sets 21 -> 23) and left the control map at 3.
The real cause was not the slots at all.

`PolicyDecider.choose_proposition` started from `options[0]` and only replaced it
on a **strictly greater** score. Most propositions score 0 against most Destinies,
so the first legal option won every tie - and **twelve of the eighteen authored
propositions were never chosen once in forty Chronicles**. Their Consequences
could not fire, so most of the content that changes control simply never ran.

Breaking the tie with the session RNG - a player with no preference does not
always take the first thing on the list - is a change to the *measuring
instrument*, not to the rules. Same lesson as D-021, where most of the apparent
balance problem turned out to be the policy.

### After

| | D-032 | D-033 |
|---|---|---|
| mappe di controllo distinte (40 partite) | 3 | **5** |
| set di tag distinti | 21 | **31** |
| stato finale distinto | 24 | **31** |
| Scar per Chronicle | 0.17 | **1.52** |
| proposte diverse messe ai voti | 6 | **10** |
| domande diverse poste | 6 | **8** |
| frasi Truth distinte | 56 su 94 | **73 su 104** |
| tag sulla mappa in 10 Chronicle | 1 -> 10 | **1 -> 17** |

Scars per Chronicle are now double what they were *before* D-032 lost them
(0.75), so the generalisation ended up ahead rather than merely recovered.

### A probe that was lying

`run_world_probe` printed "il controllo e cambiato: NO" for a campaign in which
Aldric lost the capital at Chronicle 2, the Nahr took it at 6, and Aldric took it
back at 10 - because it compared only the first and last map, and they matched.
It now counts every distinct control map the campaign passed through: 3.

Worth stating on its own: a measurement that compares endpoints will call a
round trip "no change". Every probe in this project is now suspect in the same
way until checked.

---

## D-032 — Consequences written in slots, and a Truth register that varies
**implemented in 0.0.8** · completes the content half of D-028

D-028 built the engine for library content and said plainly what was still
missing: 26 of the Consequences named a specific Region, so they were Chronicle
content, not library content. This finishes that, and adds the per-outcome
variants of `echo_summary` promised two rounds earlier.

### Four bindings instead of one

`$region_focus` alone could not carry it: a Consequence usually means one of four
things when it names a proper noun.

| slot | cosa vuol dire |
|---|---|
| `$region_focus` | il posto di cui stiamo discutendo |
| `$capital` | il seggio del potere - la Regione taggata `capital` |
| `$rival` | il posto al tavolo contro cui la domanda e posta |
| `$rival_seat` | dove quel posto al tavolo sta davvero |

21 of the 23 place-named Consequences were rewritten against those. Relation
targets became `$proponent|$rival`, and the compiler now normalises a relation
key after substitution, because the pair has to be in ascending order and the
data cannot know which order the table is sitting in.

### Two bugs the change surfaced

- **`$rival` is a prefix of `$rival_seat`.** `ConsequenceCompiler` substituted in
  dictionary order, so the slot became `ENT_NAHR_seat` - a target that does not
  exist, reported only as a `push_error` deep inside the applier. Keys are now
  sorted longest-first, the same fix `NarrativeText.fill` already carried.
- The static binding check in `validate_data.py` did not split a relation target
  on `|`, so half a pair went unchecked. It caught `$rival_seat` before it existed
  and then missed `$proponent|$rival`; both are checked now.

### `echo_summaries`: the register stops repeating itself

A proposition may now carry a sentence per outcome band. How a proposal falls
reads nothing like how it triumphs, and the Truth register is where a Chronicle
gets reread. Any band without a variant falls back to the single `echo_summary`,
so nothing had to be rewritten. 13 of the 18 propositions carry variants.

| | prima | dopo |
|---|---|---|
| frasi Truth distinte su 40 Chronicle | 22 su 63 | **56 su 94** |

That is the single biggest jump in narrative variety the project has measured,
and it cost about 40 authored sentences.

### The cost, and it is real

Generalising the Consequences **reduced** world-state variety:

| | D-028/D-031 | dopo D-032 |
|---|---|---|
| mappe di controllo distinte (40 partite) | 6 | **3** |
| Scar per Chronicle | 0.75 | **0.17** |
| il controllo cambia in 10 Chronicle | si | **no** |

The cause is structural and was not obvious in advance: `$region_focus` is
*stable* for a given Tension, so every Consequence of that Tension now lands on
the same place, where six hard-coded Regions used to spread the damage across the
map. Three Consequences were re-aimed at `$rival_seat` and `$capital`, which
recovered part of it, not all.

This is a trade, and it is recorded as one rather than presented as a win: the
Consequences are now reusable across Chronicles, and the map moves less inside
one. O-11 tracks it.

---

## D-031 — Propp's set completed: 24 cards, 24 functions, and an `any_of`
**implemented in 0.0.7** · §15, §18.2

D-030 wired the grammar but only 16 of the 24 functions the schema declares had
a card. The eight missing ones were also the most interesting to constrain:
a Punishment after a Violation, a Separation that makes a Return possible.

### The eight

| carta | famiglia | funzione | aspetta |
|---|---|---|---|
| `ECH_PETITION` | PRESSURE | REQUEST | — |
| `ECH_OFFER` | PRESSURE | TEMPTATION | — |
| `ECH_OATH_BROKEN` | RUPTURE | VIOLATION | PROHIBITION o REQUEST |
| `ECH_EXODUS` | RUPTURE | SEPARATION | — |
| `ECH_PARLEY` | TURN | ENCOUNTER | — |
| `ECH_SEIZURE` | TURN | CONQUEST | ATTACK, THREAT o USURPATION |
| `ECH_RECKONING` | RESOLUTION | PUNISHMENT | VIOLATION, BETRAYAL, USURPATION o CONQUEST |
| `ECH_CROWNING` | RESOLUTION | SUCCESSION | THREAT, USURPATION, CONQUEST o SEPARATION |

The deck is now **24 cards, 6 per dramatic family, one per declared function**,
and a test asserts all three of those numbers: content that exists only in an
enum is content that cannot happen.

### `any_of`

Every condition list in the data is an AND, and Propp's grammar is full of
alternatives - a Return follows a Separation *or* a Prohibition. The eight new
cards could not be written honestly without it.

A new condition type, `any_of`, holds when at least one of its nested conditions
does. Twelve lines in the evaluator, a `$ref` to itself in the schema, and one
recursion branch in the Python validator. `ECH_ROADS_OPEN`, `ECH_RECONCILIATION`
and `ECH_AMNESTY` were widened to use it, because single-antecedent gates made
them rarer than the grammar requires.

It is available to Destiny conditions and Confluence eligibility too, which is
where it will earn its keep next.

### After

| | D-030 | D-031 |
|---|---|---|
| funzioni con una carta | 16/24 | **24/24** |
| funzioni pescate in 40 Chronicle | 16 | **21** |
| funzioni senza antecedente | 0 | **0** |
| archi drammatici distinti | 9 | 9 |
| Atto 3 risolve | 23/40 | **28/40** |

Verified on the library Chronicle too (`--chronicle=CHR_02`): 22 functions drawn,
0 orphans, 7 distinct arcs.

### Reported, not fixed

`SACRIFICE` is drawn 14 times in 40 because it is the only RESOLUTION card that
presupposes nothing, and Act 3 asks for a resolution first. That is the price of
the invariant - every family keeps one unconditional card - and forcing it flat
would mean inventing an antecedent a sacrifice does not have.

The Confluence band moved 85% -> 70% inside 4-5 with the wider deck, still with
nothing outside 2-7. Related to O-6, still not tuned away.

---

## D-030 — The Propp layer: families shape the Act, functions order the story
**implemented in 0.0.6** · §15

### What was already there, and what was not

An Echo card carries two pieces of narrative metadata: `dramatic_family`
(PRESSURE / RUPTURE / TURN / RESOLUTION) and `function_id`, an adapted set of 24
of Propp's narrative functions.

Measured with `cli/run_echo_probe.gd` over 40 Chronicles:

- **`dramatic_family` was load-bearing.** It gates which cards an Act may draw,
  so the three-act shape was already enforced: Act 1 PRESSURE 40/40.
- **`function_id` was read by nothing.** Grep found it in exactly one place: the
  column that prints it in the asset manifest.

The cost of that showed up immediately. **19 functions in 18 Chronicles out of 40
arrived without their antecedent**: a Return with nothing to return from, a
Reconciliation with no betrayal, a Liberation with nothing forbidden. Propp's
whole point is that the functions come in an *order*, and nothing enforced it.

### The rule, written in data rather than code

Drawing a card now records the function it performed as a global tag,
`function:<ID>`, applied as an ordinary Effect. That is the entire engine change,
and the engine still does not know a single function name.

The grammar itself lives on the cards, in the `eligibility` block they already
had:

| carta | funzione | non e giocabile finche |
|---|---|---|
| `ECH_RECONCILIATION` | RECONCILIATION | non c'e stato un BETRAYAL |
| `ECH_AMNESTY` | LIBERATION | non c'e stata una USURPATION |
| `ECH_ROADS_OPEN` | RETURN | non c'e stata una PROHIBITION |
| `ECH_OATH_SWORN` | TRANSFORMATION | non c'e stato un THREAT |
| `ECH_GOOD_YEAR` | GIFT | non c'e stato un LACK |
| `ECH_REVELATION` | REVELATION | non c'e stata una DISCOVERY |

Orphan functions: **19 -> 0**.

### Two things this broke, and what they taught

**Over-gating stops the arc from closing.** Gating all four RESOLUTION cards
dropped Act 3 from resolving 18/40 to 11/40: the draw skipped the gated cards and
fell through to a rupture. Fixed by leaving `ECH_SACRIFICE` unconditional - a
sacrifice presupposes nothing, it is a choice - and guarded by a test asserting
that **every dramatic family keeps at least one card that presupposes nothing**.

**A strict preference is not a shape, it is a rail.** Reading the Act pool as an
ordered preference (RESOLUTION first, then fall back) produced *one* dramatic arc
in all forty Chronicles: PRE RUP RES, 40/40. Perfect shape, no story.

So `act_echo_pools[].families` is now a **weighted bag**: repeating a family makes
it likelier, and the seeded RNG picks the order families are tried in. No schema
change - repeats were always legal, they simply meant nothing. Chronicle I:

```
Atto 1  [PRESSURE]                                      apre sempre in tensione
Atto 2  [RUPTURE, RUPTURE, TURN, TURN, PRESSURE]
Atto 3  [RESOLUTION x3, TURN, RUPTURE]                  risolve ~60% delle volte
```

### After

| | prima | dopo |
|---|---|---|
| funzioni senza antecedente | 19 (18/40 partite) | **0** |
| archi drammatici distinti | 9 | 9 |
| Atto 1 apre in PRESSURE | 40/40 | 40/40 |
| Atto 3 risolve | 18/40 | **23/40** |
| Chronicle che finiscono a meta crisi | 22/40 | 17/40 |

An Act 3 that ends mid-crisis 40% of the time is not a bug: the unanswered
question is what the next Chronicle inherits.

Unplanned again: the Confluence band went to **85% inside 4-5** from 75%.

---

## D-029 — Pressure is displaced, not removed
**implemented in 0.0.5** · `chronicle.influence_rules.displacement_on_decrease`

### The question, and the measurement that answered it

Do crises always break in the end, or can a table hold them shut? Asked by the
author, and answerable only by playing a table that tries.

`cli/suppressor_decider.gd` is that table: four Entities that spend every Action
Opportunity pushing the loudest Tension they can legally touch back down, buying
a SCHEME first when a veiled one needs unlocking, moving only to stand where a
push becomes legal. Nobody would play like this; that is the point.

Over 40 Chronicles, against the same four playing their own Destiny:

| | quattro Destiny | solo soppressione |
|---|---|---|
| Confluence per Chronicle | 3.60 | **0.17** |
| Chronicle senza nessuna | 0/40 | **33/40** |
| La Carestia e scoppiata | 35/40 | **0/40** |
| Il Risveglio | 38/40 | **0/40** |
| Le Vie Interrotte | 21/40 | **0/40** |
| picco raggiunto (soglia 5-6) | 7-8 | **2-3** |

1400 pushes down against 452 of the world's own pressure. Three to one. The
answer was **no**: a table could keep the whole Chronicle silent, and the payoff
of the entire design would never fire. That is O-9.

### The rule

Pushing a Tension **down** with INFLUENCE raises one of its `linked_tensions` by
`displacement_on_decrease` (1 in Chronicle I). You do not make a question go
away; you choose which one to have instead.

The weight lands on the linked Tension currently **lowest**, so suppression
spreads pressure across the board rather than piling it in one place. Ties go to
the Chronicle's Tension order, so the same board always displaces the same way. A
linked Tension the Chronicle never drew is skipped rather than conjured into play
(D-028).

The displaced Effect keeps the acting Entity as its actor - this is your doing -
but carries its own source id, `ACT_INFLUENCE_DISPLACED`. Without that the per
round INFLUENCE cap, which is reconstructed from the log, counted it as a second
action.

Raising a Tension displaces nothing: feeding a fire directly is not a trade.

### The arithmetic, and why total suppression is now self-defeating

Four players, one INFLUENCE each per round (D-021): 4 down, 4 displaced up, plus
the world's own +1 Drift. Net **+1 per round** in favour of the world. A table
that suppresses everything is doing the world's work for it.

### The content that had to change with it

The link graph pooled: everything fed `TEN_FAMINE` and nothing fed
`TEN_ROADS`, so displacement filled one question and starved another. Re-authored
as a ring with chords, checked so that every Tension both feeds and is fed - both
across the six of the library and inside the four of Chronicle I:

```
Carestia    -> Risveglio, Vie Interrotte      la fame spinge a scavare, e a fermare le carovane
Risveglio   -> Successione, Pozzi Bassi       chi tiene il Cristallo pretende il trono
Successione -> Vie Interrotte, Carestia       senza un re nessuno garantisce le strade
Vie Interr. -> Pozzi Bassi, Carestia          niente sale, niente da conservare
Pozzi Bassi -> Febbre Bassa, Risveglio        acqua cattiva, e si scava per trovarne
Febbre      -> Carestia, Successione          nessuno raccoglie, e il trono non protegge
```

### After

| | prima | dopo |
|---|---|---|
| soppressori: Chronicle silenziose | 33/40 | **1/40** |
| soppressori: Confluence per Chronicle | 0.17 | **2.73** |
| tavolo normale: Confluence per Chronicle | 3.60 | 4.58 |
| ogni Tensione e scoppiata almeno una volta | no | **si, tutte e quattro** |

Suppression still *buys* something - 2.73 Confluences against 4.58 - so holding a
question down is a real move with a real effect. It just cannot buy silence.

### An unplanned improvement

The balance of D-026 got better on its own: **75% of runs inside the 4-5 band**
against 42%, with nothing below 2 or above 7. That closes O-5 as well: the two
Chronicles in forty that fell under §7's floor are now zero.

---

## D-026 — The Confluence band is 4-5, not §7's 3-4
**implemented in 0.0.4** · declared deviation from §7, recorded per §25

§7 asks for 3-4 Confluence per Chronicle. That number was written for the two
Tensions of §18.2; a Chronicle now carries four, and the measured median is 4
with only 42% of runs inside 3-4. Widening the band to **4-5** (and the hard
bounds from 2-6 to 2-7) describes the game that exists rather than the one the
reduced content described.

Chosen by the author over the alternative - tuning the content back down until
it fits 3-4 - because the wider world is the point of D-024. `test_balance.gd`
and `run_balance_probe.gd` both carry the new band, and both name this entry.

---

## D-027 — Holding is not free: overextension and lapse
**implemented in 0.0.4** · `chronicle.control_rules`

O-7 measured a runaway: across ten inherited Chronicles Aldric went from one
Region to five and never lost one again, because inheritance compounds an
advantage and nothing reversed it.

The answer is the author's, and it is better than the three options offered: not
a penalty aimed at whoever is winning, but a pressure that comes from the
situation. An empire falls from its own size.

Two coupled rules, both data-driven and both removable by deleting
`control_rules`:

- **`max_stable_control`** — every Region an Entity holds beyond this raises the
  Tension of *that Region's own domain*, once per round. It reads at the table as
  "you hold the road as well? then the road question is yours to answer".
- **`lapse_without_presence`** — at the start of a continuing Chronicle, a Region
  held with nobody standing in it reverts to no one. You cannot govern where you
  are not, so a power that spread too thin loses the edges first, without anyone
  having to take them.

Chronicle I uses `{max_stable_control: 2, overextension_delta: 1,
lapse_without_presence: true}`.

Measured over ten inherited Chronicles, same seeds:

```
prima   Re - Vae Re  Re  Re     (dalla Chronicle 5 in poi, immobile)
dopo    Re - Vae Re  Pop -   ->  Re - Vae - - -  ->  Re - Vae Re - -
```

Control now expands and contracts instead of freezing. Truths over the campaign
went 13 -> 16 and distinct sentences 12 -> 15, because a world that moves gives
the slots of D-028 something to say.

---

## D-028 — Library content: Councils bound to a domain, Chronicles that draw
**implemented in 0.0.4** · the author chose model **B** (combinatorial library)

The question was how Chronicle N+1 exists at all. Three models were on the table:
pre-written Legacy (A), a combinatorial library (B), hybrid (C). The author chose
**B**: nothing about the next Chronicle is written in advance, it is assembled.

Two structural changes make that possible.

### A Council may bind to a domain instead of a Tension

`confluence_template.tension_id` is now optional, and `applies_to_domain` is the
alternative. A Tension with no Council of its own is served by the Council of its
domain. The structure of a survival crisis is not specific to one famine, so
*"$in_region, chi decide a chi non ne tocca?"* serves any of them.

This is the single biggest cost saving in the project: Councils were about a
third of the authoring cost of a Chronicle, and they were the part that had to be
rewritten every time.

`CNF_ANY_SURVIVAL` is the first one, written entirely in slots. `TEN_PLAGUE` and
`TEN_THIRST` are the first Tensions with no Council of their own, and they get a
complete one for free.

### A Chronicle may draw its Tensions instead of listing them

`chronicle.tension_pool` (`candidates`, `count`, `always`) replaces a written-out
`tensions` list. The draw uses the same seeded RNG as the decks and the drift
bag, so a library Chronicle is exactly as reproducible as an authored one - same
seed, same year. `drift_distribution` may be omitted too, and is then dealt
round-robin over whatever was drawn.

`CHR_01` stays authored and unchanged. `CHR_02` is the library form and draws 4
of 6 candidates. Ten years of it, same seeds:

```
1  813  FAMI PLAG ROAD THIR      6  814  FAMI PLAG SUCC THIR
2  814  AWAK FAMI ROAD SUCC      7  819  PLAG ROAD SUCC THIR
3  815  AWAK ROAD SUCC THIR      8  820  FAMI PLAG ROAD SUCC
...
```

### What had to give way

Library content names Tensions a Chronicle may not have drawn, so `ADJUST_TENSION`
and `SET_TENSION_VISIBILITY` on a Tension **that exists in the data but is not in
play** are now a no-op instead of a failure. An id that is not a Tension at all is
still an error - the distinction is what keeps a typo loud.

`tension_limit` conditions resolve `$tension`, and the authored Scar block
resolves `$region_focus`, for the same reason: a domain-bound Council does not
know which question it is serving until it opens.

### What is still A, not B

The 29 Consequences are mostly *not* library content yet: most still name a
specific Region. Three (`CNS_RATIONED`, `CNS_ABANDONED`, `CNS_SHARED_BURDEN`) are
written purely in slots and are the pattern for the rest. Generalising the other
26 is the next chunk of B, and it is authoring work, not engine work.

---

## D-024 — 4 Tensions, 26 Consequences, 16 Echo cards
**implemented in 0.0.3** · further deliberate deviation from §18.2, recorded per §25

### Why the content grew

Measured first, with `cli/run_world_probe.gd`. Over 40 independent Chronicles on
the 2-Tension set, the world ended in **2 distinct control maps, 2 distinct
relation maps and 0 Scars**. Over 10 Chronicles played in sequence, control never
changed hands once and the map gained 2 tags in ten years.

Three of seven authored Region tags never fired at all. The Chronicle could not
move, so nothing built on top of it could either - which is why the `$slot`
sentences of the previous commit resolved to the same Region 116 times out of
116. Slots do not create variety, they transmit it.

### What was added

| | prima | dopo |
|---|---|---|
| Tensioni | 2 | 4 (`TEN_SUCCESSION` TERRITORY, `TEN_ROADS` RESOURCE) |
| template di Confluence | 2 | 4 |
| Consequence | 12 | 26 |
| carte Echo | 8 | 16 |
| Scar autorate | 0 | 8 |

Three shapes of Consequence that did not exist before:

- **che guariscono** — `CNS_HARVEST_RETURNS`, `CNS_ORDER_RESTORED`,
  `CNS_ROADS_REOPENED` *remove* condition tags. Without them the world only ever
  saturated: every tag was one-way, so ten Chronicles produced a map covered in
  scars and nothing else.
- **che cambiano il controllo** — `CNS_CAPITAL_TAKEN`, `CNS_CROWN_DIVIDED`,
  `CNS_MARCH_GRANTED`, `CNS_TOLL_ESTABLISHED`, `CNS_MARKET_MOVED`.
- **che lasciano una Scar** — 8 Consequences now carry `creates_scar`. The
  mechanism was implemented in 0.0 and used by nothing.

Two baseline numbers moved and are recorded here rather than changed quietly:
the drift bag is now 2/3/2/2 across four Tensions instead of 5/4, and
`TEN_AWAKENING`'s threshold went **7 → 6**, because nine drift chips spread over
four Tensions can no longer carry one to 7 without help.

### The measurement, after

Same probe, same seeds:

| | 2 Tensioni | 4 Tensioni |
|---|---|---|
| mappe di controllo distinte (40 partite) | 2 | **6** |
| set di tag distinti | 14 | **26** |
| stato finale distinto | 14 | **28** |
| Scar per Chronicle | 0.00 | **0.45** |

And over ten Chronicles in sequence, which is the question that started this:

```
#   anno  controllo                 tag  Scar  Truth
1   812   Re  -  Vae Re  Pop -       1    0     2
5   816   Re  -  Vae Re  Re  Re     10    3     6
10  821   Re  -  Vae Re  Re  Re     11    9    13
```

Il controllo cambia (Chronicle 4 e 5), i tag vanno da 1 a 11, le Scar da 0 a 9.
La Regione a fuoco si sposta su **sei** combinazioni Tensione/Regione invece di
due, quindi le frasi a slot cominciano davvero a nominare posti diversi.

### What it cost, stated plainly

The balance of D-021/D-023 regressed and is **not** restored:

| | 12 Consequence, 2 Tensioni | 26 Consequence, 4 Tensioni |
|---|---|---|
| mediana Confluence | 3 | 4 |
| nella banda 3-4 del §7 | **70%** | **42%** |
| fuori da 2-6 | 3/40 | 3/40 |
| FAILURE | **18** | 9 |
| SUCCESS_WITH_COST | **15** | 5 |

`tests/smoke/test_balance.gd` still passes - the median is in band and outliers
are under the 10% ceiling - but two of the four outcome bands have thinned out
again. See O-6.

---

## D-025 — Sim plan directives address a Tension, not a running index
**implemented in 0.0.3**

`scripted_confluence.index` said "steer the first Confluence of the run". Adding
two Tensions changed which question comes to a head first, so plan A's grain
directive landed on the Roads council: wrong proposition, and a clause that does
not exist in that template.

Directives may now carry `tension_id`, which reads as "when the grain council
happens, do this" and survives new content. `index` still works for directives
that do not name a Tension. The directive is resolved once per Confluence and
cached, because the controller asks for it a dozen times per council and
consuming it on the first call handed the second call the *next* directive.

---

## D-022 — 12 Consequences instead of the 8 of §18.2
**implemented in 0.0.2** · deliberate deviation from §18.2, recorded per §25

§18.2 sizes the 0.0 content at 8 Consequences. The set now holds 12. The four
new ones are `CNS_VALLEY_CLEARED`, `CNS_CROWN_DISPOSSESSED`, `CNS_MINE_TAKEN`
and `CNS_STUDY_UNDER_GUARD`.

The reason is O-4. Every proposition in the reduced set granted something to its
proponent and took nothing from anybody, so a policy that scores propositions
against its own Destiny scored almost all of them at zero and abstained. O came
out at 0, the proponent always won, and two of the four outcome bands of §12.3
were unreachable outside the scripted plans. That is a content gap being read as
a maths problem.

Each new Consequence takes something specific away from a specific seat:

| Consequence | attached to | what it costs, and to whom |
|---|---|---|
| `CNS_VALLEY_CLEARED` | `P_REQUISITION` | clears the Nahr out of the Valley (`optional`, so it is a no-op if they are not there) |
| `CNS_CROWN_DISPOSSESSED` | `P_OPEN_VALLEY`, `P_LAND_TO_WORKERS` | the Valley stops being controlled by anyone, which is Aldric's `control_count` |
| `CNS_MINE_TAKEN` | `P_EXPLOIT` | control of the Ancient Mines passes to the proponent, against Lyra and Vaerax |
| `CNS_STUDY_UNDER_GUARD` | `P_GUARDED_STUDY` | its own world change, closing O-2 |

`REMOVE_PRESENCE` gained an `optional` flag for this: a Consequence may say
"clear them out of the Valley" without knowing whether anyone is camped there,
and that has to be a no-op rather than a failed Effect.

The policy was extended to *see* the damage — it scores `ADD_PRESENCE` /
`REMOVE_PRESENCE` against its `region_presence` conditions and `SET_CONTROL`
against `control_count` — and to answer a proposal that costs it 2 or more with
`OPPOSE` rather than a polite Condition clause.

Measured effect on 40 Chronicles, seeds 1000-1039, everything else unchanged:

| | FAILURE | SUCCESS_WITH_COST | SUCCESS | DECISIVE |
|---|---|---|---|---|
| 8 Consequences (D-021 baseline) | **0** | 1 | 79 | 75 |
| 12 Consequences | 2 | 4 | 47 | 36 |

Failure exists again. But the Confluence median fell from 4 to 2 and only 20% of
runs stayed in §7's band: opposition that real also *deters*, and the policy
stopped bringing Tensions to a head at all. That is what D-023 answers.

---

## D-023 — One INFLUENCE per Tension per round
**implemented in 0.0.2** · `chronicle.influence_rules.max_per_tension_per_round`

D-021 bounds how fast a *person* can move; this bounds how fast a *question* can
move, whatever the table wants. Four players who all care about the Famine could
still walk it to threshold in a single round, which is why the median swung so
hard when D-022 changed who wanted to.

Swept as a knob (`--tension-cap`) over 40 Chronicles, seeds 1000-1039, on the
12-Consequence content:

| max per Tension | mediana | in banda 3-4 | sotto il minimo | FAILURE | SwC |
|---|---|---|---|---|---|
| nessuno | 2 | 20% | 8/40 | 2 | 4 |
| **1** | **3** | **70%** | 2/40 | **18** | **15** |

With both caps in force the final shape over the same 40 Chronicles is:

```
Confluence per Chronicle   media 2.92, mediana 3, min/max 1/4
  nella banda 3-4          28/40 (70%)
  sotto il minimo di 2     2/40
  sopra il massimo di 6    0/40
Esiti  FAILURE 18 · SUCCESS_WITH_COST 15 · SUCCESS 57 · DECISIVE 27
Echo   61 (1.52 per Chronicle)
```

All four outcome bands of §12.3 now occur in open play. That closes O-4.

### The cost, stated plainly

Two of the forty Chronicles produce a single Confluence, which is below the floor
§7 names. Under D-021 alone that number was zero. The trade bought the two
missing outcome bands, and §7 says to report rather than silently adjust — this
is the report.

`tests/smoke/test_balance.gd` was rewritten as part of this change, and it is
fair to say it was relaxed after it failed. The old guard asserted per run: no
single Chronicle outside 2-6. The new guard asserts on the aggregate — the median
must be 3-4, at most 10% of runs may fall outside 2-6, and there must be at least
one Echo per two Chronicles. The justification is that §7 describes what a
*playtest* should show, not a rule forbidding one quiet Chronicle, and a guard
that fails on a single outlier is measuring variance rather than balance. The
justification is genuine, but the sequence was: guard failed, guard changed.
Anyone re-opening this should weigh it knowing that.

Reversible like D-021: delete `max_per_tension_per_round` from the Chronicle and
the cap disappears.

---

## D-019 — GDScript built-ins shadow same-named methods
**implemented**

`RngService` exposes `range_int(from, to)`, not `randi_range`. GDScript resolves
an unqualified call to a `@GlobalScope` built-in *before* a method of the
enclosing class, so a method named `randi_range` is silently never called and
every "seeded" draw comes from the global RNG instead. The first determinism
check caught it: two services built from the same seed produced different
shuffles, and the draw counter stayed at zero.

Related: the project avoids `class_name` and uses `const X := preload(...)`
throughout, so nothing depends on the global class cache that only an editor
import generates.

---

## D-020 — `forced_confluence` on the WorldState
**implemented**

`CLAIM/FORCE` has to survive from the action phase to the end-of-round check, and
be part of the save. Added to `world_state.schema.json` as a nullable object
(`{tension_id, entity_id}`), initialised to `null` at setup so the save shape is
stable.

---

## Open observations

### O-1 — Confluence count per Chronicle
**closed by D-021, re-measured under D-023.** Current shape over 40 Chronicles:
median 3, range 1-4, 70% inside §7's 3-4 band, 2 runs below the floor of 2. The
three scripted plans produce 1, 3 and 2, which is expected — a plan is an
authored story, not a typical table, and plan A exists specifically to show a
clean Decisive Success.

### O-4 — Failure and Success with Cost almost never happen in open play
**closed by D-022 + D-023.**

The reading was right: the cause was content, not maths, and the resolver was
never touched. In the reduced 0.0 set almost no Consequence wrote a tag another
Destiny cared about, so a proposition threatened nobody, O came out at 0, and the
proponent always won. Four Consequences that take something specific away from a
specific seat (D-022), plus a bound on how fast a single question can move
(D-023), bring all four bands of §12.3 into open play: 18 Failure, 15 Success
with Cost, 57 Success, 27 Decisive over the same 40 Chronicles.

The §19.4 content growth is still the right next step; it is no longer a
prerequisite for the outcome table to be alive.

### O-2 — Content breadth of the Confluence templates
**closed by D-022.** `P_GUARDED_STUDY` now has `CNS_STUDY_UNDER_GUARD` and no
longer shares `CNS_MINE_SEALED` with `P_SEAL_MINE`. Every proposition in the set
lands on its own world change.

### O-14 — The Destiny spread tilted, and this time in Lyra's favour
**closed by D-048.** The tilt was real and the cause was mechanical: Lyra's whole
ladder was closed by Act I round two in 40 Chronicles out of 40, so "reaches
Triumph in four out of five" was not a seat that was winning, it was a seat that
had been handed the win before play began. Priced properly she is at MIN 34 /
TRI 6 - and the table is now lopsided the *other* way, which is O-15.

**original note:**

D-036 opened the rooms and the standings moved with them:

| | D-035 | D-036 |
|---|---|---|
| Aldric | MIN 18 / VIC 10 / TRI 12 | **MIN 32** / VIC 5 / TRI 2 |
| Nahr | MIN 4 / VIC 27 / TRI 9 | MIN 6 / VIC 29 / TRI 5 |
| Lyra | MIN 15 / TRI 25 | MIN 8 / **TRI 32** |
| Vaerax | MIN 1 / VIC 36 / TRI 3 | MIN 1 / **VIC 38** / TRI 1 |

The crown now spends most Chronicles at Minimum, and Lyra reaches Triumph in four
out of five. Nobody is frozen the way they were before D-035 - every seat still
reaches more than one level - but the spread is lopsided, and two of the causes
are visible: Aldric's Victory needs two Regions in a world where control changes
hands far more often, and Vaerax's Triumph now asks for a cut road, which is a
tag somebody else has to write for him.

Left alone on purpose. Three rounds of measurement in a row found the instrument
at fault rather than the rules, and the lesson is not to reach for the knobs
first. This wants a table of real players before anybody decides which of these
numbers is wrong.

Relations also collapsed to a single distinct end state across forty Chronicles,
down from two. Small, but it says the relation graph is scenery right now.

### O-15 — Six Destiny levels out of twelve are true before anyone plays
**closed by D-051 and D-053.** Half of what this entry counted was not a defect:
a free Minimum says "you are still at the table", and an absent-tag clause is a
stake the year takes off you. What was broken were two Victories made only of
stakes nothing ever attacked, and those are fixed (D-051).

The rest - "recorded, not tuned", because it wanted a table of real players -
was then actually measured (D-053): four different characters over 100
Chronicles against the same 100 seeds played by four identical optimisers. It
found that four of the eight seats were an artefact of the instrument, two were
genuinely too expensive, and those two were lowered. Seats locked on one level
at a mixed table: 1 of 8, against 4 of 8 with the optimisers.

What outlived this observation is a different one, and it is in the ROADMAP
rather than here because it is about the resolver and not the content:
**blocking is the dominant strategy**. See D-053's closing section.

**original note:**

`run_destiny_probe.gd` checks every clause against the opening position, and the
count is 19 clauses out of 28 already true, with **six whole levels given away**:
Aldric's Minimum and Triumph, Nahr's Minimum, Lyra's Victory (now repriced by
D-048), and both of Vaerax's lower rungs.

Not all of these are wrong. A clause asking for a tag to be *absent* is a stake,
not a gift: "the crown was not broken" is true until somebody breaks it, and
Aldric's Triumph is 3/3 free at the start and still reaches TRIUMPH only 3 times
in 40, because the year takes it off him. That is the mechanism working.

Vaerax is the one that is not working. His Victory is two absent-tags and nothing
else, and he reports VICTORY in 37-40 Chronicles out of 40 - in CHR_02, **40 out
of 40**. He wins by sitting still, and after D-048 he wins while the seat he is
in direct conflict with wins 6 times in 40. The asymmetry is now the loudest
thing in the standings.

Recorded rather than tuned, and deliberately: D-048 already moved one seat from
best at the table to worst, and moving a second one in the same pass would make
neither measurable. The next pass should start from this probe's first table -
what is already true before the year starts - rather than from the outcome
counts, because the outcome counts are where this hid for four milestones.

### O-13 — `P_ANY_LEAVE` is a proposition nobody would ever make
**closed by D-036.** Not with the first fix: giving it `ADJUST_TENSION -2` was
not enough, because `P_ANY_RATION` offered the same relief plus the Region and so
strictly dominated it. The payoff that worked was the one already written in the
Consequence's own category - MIGRATION, not LOSS - so whoever leaves now arrives
somewhere. It reaches a vote 7 times in 40 Chronicles.

**original note:**

Its success Consequence, `CNS_ABANDONED`, sets the Region's control to nobody
and removes the **proponent's own** presence. Nobody playing to win proposes
that, so `condition:abandoned` has never been written in any measured Chronicle.

The text is good — *"Non si risolve: si va via. $rival resti pure, se ci tiene."*
It reads as an act of spite or exhaustion, and both are real things a table does.
But the rules give it no reason to be attractive: walking out denies the place to
the rival, and nothing scores that.

Three honest ways out, and picking one is design, not tuning: give it a payoff
that makes leaving worth something; move `CNS_ABANDONED` to a failure or cost
path, where "nobody resolved anything and the place emptied" is exactly right;
or leave it as content only a human would ever reach for, and accept that the
policy will never measure it.

### O-12 — Two of the four Tensions are in nobody's Destiny
**closed by D-036** — with a detour worth recording. The obvious fix, a
`tension_limit` on each, made it *worse*: a ceiling makes the policy spend
actions holding the Tension down, and holding it down makes the question stop
being asked. The Roads fell from 36 Councils to 6. A stake does not have to be a
limit on a number - a tag weighs on propositions and drives no actions - and two
pairs of directly opposed tag stakes gave the fight without the silence.

**original note:**

Every `tension_limit` clause in CHR_01 names either the Famine or the Awakening.
**No Destiny puts a ceiling or a floor on the Succession or on the Roads.**

It went unnoticed while D-035 was hidden, because the Councils that came forward
were the ones about the Famine and the Awakening. With the first questions now
asked, propositions that move the Succession and the Roads reach the table
routinely — and the whole table is indifferent to them by construction. Those
Councils cannot produce a fight over the quantity itself; only over who ends up
holding what.

Not a bug, and not obviously wrong: a Chronicle may legitimately carry a question
nobody has sworn anything about. But four Tensions and two stakes is a thinner
board than it looks, and one clause added to one Destiny would change it.

### O-6 — The wider content thinned the outcome bands again
**closed by D-035.** All four bands are populated (FAILURE 25, SUCCESS_WITH_COST
27, SUCCESS 65, DECISIVE_SUCCESS 76 out of 193) and no seat has a predetermined
ending: Lyra was TRIUMPH in 40 Chronicles out of 40, and is now MINIMUM in 23 of
them. The cause was never the resolver or the bands - it was the measuring player
never asking the first question of any Council.

**previously: narrowed by D-034, still open.** The cause turned out to be the measuring
instrument: the policy was blind to three of the four axes the Destinies are
actually about, so 96% of stances were ABSTAIN and O was 0 in almost every
council. With the policy able to read them, Failure went 7 -> 23 out of ~180.
What remains is `DECISIVE_SUCCESS` at 57%, and one seat (Vaerax) that owns its
own question and is therefore never in the room to vote on it - a content
question, not a policy one.

**previously: partly closed by D-026** — the band question is answered (4-5,
declared). The thinning of Failure and Success with Cost is not: 9 and 5 against
18 and 15. Still open, still the same mechanism as O-4 in a bigger world.

**original note:**

D-024 grew the content and the balance of D-021/D-023 regressed: 42% of runs in
§7's 3-4 band against 70%, and Failure/Success with Cost back down to 9 and 5
from 18 and 15. Four Tensions mean more Confluences, and attention spread over
four questions means each individual council is less contested - the same
mechanism as O-4, in a bigger world.

Not acted on, on purpose. §7's 3-4 band was written for the reduced content of
§18.2; whether it still describes a 4-Tension Chronicle is a design question for
the author, not something to tune away quietly. The knobs from D-021/D-023 are
both still there and still measured.

### O-7 — The campaign has a runaway leader
**closed by D-027.**

**original note:**

Ten Chronicles in sequence, each inheriting the last: Aldric holds one Region at
the start and five by Chronicle 5, and never loses one again. Inheritance
compounds an advantage and nothing reverses it - the healing Consequences of
D-024 clear *conditions*, not *control*.

This wants a real answer before the campaign of 1.0, and the honest options are
design decisions, not tuning: control that lapses without presence, a Destiny
that gets harder as you hold more, or a Chronicle-start step that puts something
back on the table. Recorded rather than picked.

### O-8 — Six of the 26 Consequences never fire in open play
**closed by D-035.** The content was never unreachable: the policy declined to
choose a question, so the default handed it the last one every time and the first
question of every template was never asked. Tags never written in 40 Chronicles
went from 9 to 3, and the three that remain each have their own named cause -
O-12, O-13, and the proponency lock in D-035's Vaerax note.

The original note warned that "tuning the policy until its own content fires
would be fitting the measurement to the answer". That was the right worry and it
pointed at the wrong culprit: the policy was not scoring the content too
narrowly, it was never being offered it.

**original note:**

`structure:granary`, `structure:tollgate`, `settlement:market`,
`condition:exploited`, `condition:requisitioned` and `condition:indebted` were
not written to the map once in 40 measured Chronicles. Their propositions exist
and are legal; the policy simply never scores them highest.

Content that cannot be reached is content that does not exist. Worth checking
against real players before deciding whether the propositions are weak or the
policy is narrow - tuning the policy until its own content fires would be fitting
the measurement to the answer.

### O-11 — Slot-written Consequences concentrate the damage
**closed by D-033.** The concentration was real but secondary: the dominant cause
was a policy that always took the first proposition on a tie, leaving two thirds
of the authored content unplayable.

**original note:**

Control maps distinct over 40 Chronicles went 6 -> 3 and Scars per Chronicle
0.75 -> 0.17, because `$region_focus` is stable for a Tension and six hard-coded
Regions used to spread the damage. `$rival_seat` and `$capital` recovered part of
it. The real answer is probably a fifth binding - "a Region adjacent to the one
under discussion" - or Consequences that name a *kind* of place rather than a
place, but both are design work and neither should be guessed at.

### O-10 — `function_id` was metadata the engine never read
**closed by D-030.** 19 orphan functions in 40 Chronicles, now 0.

### O-9 — A table that only suppresses can keep a Chronicle silent
**closed by D-029.** Measured at 33 silent Chronicles out of 40; now 1.

### O-5 — Two Chronicles in forty fall below §7's floor
**closed by D-029** — 0/40 below the floor after displacement landed, without
anything being tuned for it.

**original note:**
**flagged, deliberately accepted — see the cost section of D-023**

1 Confluence in 2 runs out of 40. Those are Chronicles where the two Tensions are
each moved by one player pulling up and another pulling down, and the caps mean
neither side can break the deadlock inside a round. More Tensions (§19.4 asks for
4) should spread the pressure and fix this without another rule; worth
re-measuring first thing in 0.2 before adding anything.

### O-3 — `on_commit_effects` is exercised by one card
`AST_FORCE_WARBAND` is the only Asset with an on-commit cost in 0.0. The
mechanism is general and schema-backed; 0.1's 48 Assets are where it earns its
keep.
