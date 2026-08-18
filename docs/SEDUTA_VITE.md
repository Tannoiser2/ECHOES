# La seduta sulle vite (voce 19, fasi 4-5) — dossier di decisione

Preparato per il committente. Lo studio completo è in
[TRASFORMAZIONI.md](TRASFORMAZIONI.md); questo è il foglio da cui si decide:
lo stato vero dei dati, una proposta concreta per ogni vita, e le domande
secche. La regola della casa resta quella scritta in cima allo studio: **una
vita senza dente non si scrive.**

---

## 1. Lo stato vero, contato dai dati (0.1.86)

**Nove vite oltre la fondazione esistono già.** Sette hanno il loro dente
(una `tag_rule` sul segno `life:`), tutte COUNCIL_MODIFIER:

| vita | ingresso | il dente acceso |
|---|---|---|
| La Reggenza del Granaio (Aldric) | ON_TAG | propone sulla Carestia a +1 |
| La Corona Restaurata (Aldric) | ON_TAG | propone sulla Successione a +1 |
| Il Regno di Nahr | ON_TAG | propone sulla Carestia a +1 |
| L'Accademia delle Misure (Lyra) | ON_TAG | quando propone, la misura fa testo: +1 |
| Vaerax Ridestato | ON_TAG | propone sul Risveglio a +1 |
| Il Culto della Montagna (Vaerax) | **ON_DEATH** | la memoria della montagna: +1 sul Risveglio |
| Il Banco Nero (Ilve) | ON_TAG | propone sul Debito a +1 |
| L'Inquisizione del Vetro | ON_TAG | propone sulla Reliquia a +1 |
| La Lega delle Sette (Libere) | ON_TAG | quando delibera, sette città hanno già detto sì: +1 |

**Cinque «seconde vite» del 0.1.70 sono senza dente** — scritte prima della
regola: la Repubblica della Valle, il Culto della Misura, la Compagnia del
Sale, i Frati del Vetro, le Custodi della Cenere. Oggi cambiano nome, natura
e verbale, ma nessuna regola le distingue.

**Quattro vite dell'albero non sono mai state scritte**: la Diaspora (Nahr),
la Leggenda della Montagna (Vaerax), i Forni Riaccesi (Kessa), l'Egemonia
(Libere).

**E un buco strutturale**: l'ingresso `ON_DEATH` del Culto della Montagna è
nel motore e funziona — ma **niente nel gioco sa uccidere Vaerax**
(`SET_ENTITY_ACTIVE` non compare in nessuna Conseguenza). Il Culto è
contenuto irraggiungibile: per D-035, contenuto che non esiste.

**Una buona notizia per la fase 4**: il motore legge già `action_values` e
`persistence` **per vita** alla trasformazione (D-108). Differenziare i
valori è lavoro di dati e di misura, non di codice.

---

## 2. Le decisioni, in ordine

### A. I cinque denti mancanti — tre pronti, due che chiedono un pezzo nuovo

Proposte col vocabolario che c'è oggi (D-104/D-116). «Pronto» = si scrive
la regola, si accende da sola, si misura sui 100 semi.

| vita | proposta | stato |
|---|---|---|
| **La Compagnia del Sale** | il credito federato: pesca WEALTH migliore (DRAW_BIAS BONUS sul segno di vita) | **pronto** — il tipo è arrivato con D-116 |
| **I Frati del Vetro** | la regola come misura: quando propongono sulla Reliquia, World Factor +1 (COUNCIL_MODIFIER) | **pronto** — la forma piena («+1 dove la reliquia è custodita») aspetta i segni compositi, vedi E |
| **Le Custodi della Cenere** | la veglia arma: pesca FORCE migliore (DRAW_BIAS BONUS) — la torre di D-122 in più, come per tutti | **pronto** |
| **La Repubblica della Valle** | il consenso prudente: −1 quando propone **e** il suo fronte d'opposizione vale +1 | metà del potere chiede il tipo nuovo STANCE_MODIFIER (vedi E); da solo il −1 è solo una vita peggiore |
| **Il Culto della Misura** | il dogma vela: il suo SCHEME può **chiudere** un numero al tavolo | chiede l'azione inversa dello scouting (vedi E); il ponte provvisorio (pesca KNOWLEDGE migliore) è debole e si può anche non fare |

**Domanda A**: accendo i tre pronti (uno alla volta, misurati)? E per
Repubblica e Culto della Misura: aspettano il loro tipo, o vuoi il ponte
provvisorio?

### B. La morte di Vaerax — il prerequisito del Culto

Un ETERNAL non esaurisce linee: o muore per mano del tavolo, o il Culto non
nasce mai. Proposta d'autore, da scrivere solo se la approvi:

- una **proposta di Consiglio sul Risveglio** (`P_SLAY_THE_DRAGON`), la più
  costosa del gioco: eleggibile solo a Risveglio alto, richiede l'esito
  **Decisivo** per uccidere davvero (un successo normale ferisce e basta);
- la Conseguenza (`CNS_DRAGON_SLAIN`): `SET_ENTITY_ACTIVE` falso su Vaerax,
  una Cicatrice nuova sulle Montagne, la leggenda che ne nasce;
- **il punto che scioglie la trappola di D-018**: il seggio non viene
  eliminato — alla morte scatta `ON_DEATH` e chi giocava il drago **gioca il
  Culto**, natura nuova, poteri nuovi. La morte è una trasformazione, non
  un'espulsione. (Se accade a metà anno o solo fra le ere è la prima cosa da
  decidere in seduta: il motore oggi la giudica alla successione.)

**Domanda B**: si scrive? E chi può proporla — chiunque, o serve un segno
(la ferita aperta, la prova del cristallo)?

### C. Le quattro vite mai scritte

In ordine di quanto chiedono al motore:

1. **I Forni Riaccesi** (Kessa, entra se la miniera riapre): ACQUIRE meglio
   alle Montagne ma la Carestia sale quando forgiano — esprimibile oggi
   (DRAW_BIAS + un costo su FORGE). **Scrivibile subito.**
2. **L'Egemonia** (Libere, entra se resta una sola città piena): CLAIM
   potenziato, ma le relazioni con lei hanno un tetto ad ALLY — il tetto c'è
   (RELATION_CAP), il CLAIM potenziato è un tipo nuovo piccolo.
3. **La Diaspora** (Nahr, entra dopo due cacciate): le porte non la tengono —
   chiede **l'eccezione di porta** (vedi E).
4. **La Leggenda della Montagna** (Vaerax, la miniera sigillata regge tre
   ere): il seggio senza corpo sulla mappa — la più radicale, da disegnare
   insieme prima di scriverla.

**Domanda C**: quali approvi, e in che ordine?

### D. Fase 4 — i valori per vita (il motore li legge già)

Regola proposta per non sbagliare: **ridistribuire, mai solo togliere** —
±2 punti spostati fra le sei azioni, nessuna vita col profilo strettamente
peggiore della precedente. Esempi da approvare in seduta: la Repubblica
scende in CLAIM e sale in FORGE (i collegi trattano, non rivendicano); il
Regno di Nahr sale in CLAIM e scende in MOVE (chi si siede smette di
camminare); il Culto della Montagna sale in SCHEME e scende in ACQUIRE.
Ogni cambio misurato con la sonda delle ere, non solo col playtest: i
valori pesano su tutta la saga.

**Domanda D**: approvi la regola della ridistribuzione? Compiliamo la
tabella dei sei valori vita per vita in seduta?

### E. I pezzi nuovi del telaio che i poteri ambiziosi chiedono

In ordine di resa (quante vite sblocca ciascuno):

| pezzo | cosa fa | chi lo aspetta |
|---|---|---|
| **segni compositi** (`when_all`) | una regola che chiede due segni insieme (la vita **e** un fatto del mondo) | i Frati pieni, le Custodi piene, e ogni potere «vale doppio per lei» |
| **STANCE_MODIFIER** | un fronte (sostegno o opposizione) che vale di più per chi porta il segno | la Repubblica, e la paura del Ridestato in forma piena |
| **il velo** | l'azione che chiude un numero al tavolo (lo SCHEME inverso) | il Culto della Misura |
| **l'eccezione di porta** | un segno che passa attraverso i GATE | la Diaspora |
| **la soglia della Condition** | qualificare con un impegno in meno | la Lega delle Sette in forma piena |

Ognuno seguirebbe il rito di D-116: il gancio nel motore provato con regole
sintetiche e neutro finché nessuna regola vera lo usa, poi i denti veri
accesi uno alla volta.

**Domanda E**: quali autorizzi? (La mia proposta: compositi e
STANCE_MODIFIER subito — sbloccano cinque poteri in due; gli altri quando
la vita che li aspetta viene approvata.)

---

## 3. L'ordine dei lavori proposto

1. I **tre denti pronti** (Sale, Vetro, Cenere) — una versione, misurata.
2. La **morte di Vaerax** e il Culto raggiungibile — contenuto d'autore.
3. I **valori per vita** (fase 4) — dati e sonda delle ere.
4. I **pezzi del telaio autorizzati** in E — motore, poi i poteri pieni.
5. Le **vite nuove** approvate in C.
6. I **tarocchi e i prompt** delle vite nuove, in coda (fase 3 estesa).

A ogni passo il vincolo di sempre: 0/8 seggi bloccati al tavolo misto, ere
in banda, ogni esito a verbale con i numeri accanto.

---

## 4. Il verbale della seduta

Le risposte del committente, con la lettura che ne guida il lavoro:

- **A — tutte e tre.** I denti pronti si accendono (0.1.87): il credito
  federato della Compagnia, la regola come misura dei Frati, la veglia
  armata delle Custodi. Repubblica e Culto della Misura **non** prendono il
  ponte provvisorio: avranno il potere pieno coi pezzi della E.
- **B — si scrive, e la può proporre qualcuno con carta di Propp.** La
  strada c'è già nel gioco: la **Rivelazione** prescrive il Consiglio sul
  Risveglio e chi la cala ne è il proponente (D-118). La caccia al drago
  sarà una proposta di quel Consiglio, eleggibile solo quando la funzione
  di Propp giusta è stata compiuta — si arriva a proporla *attraverso* la
  carta, come chiesto. Il drago imparerà a difendersi (il punteggio deve
  temere `SET_ENTITY_ACTIVE`), e la morte non elimina il giocatore: scatta
  `ON_DEATH` e chi giocava il drago gioca il Culto.
- **C — da rispiegare.** Fatto qui sotto, al §5, una vita alla volta.
- **D — approvata.** La regola della ridistribuzione (±2, mai un profilo
  strettamente peggiore); la tabella si compila e si misura con la sonda
  delle ere.
- **E — tutti e cinque.** Segni compositi, STANCE_MODIFIER, il velo,
  l'eccezione di porta, la soglia della Condition — col rito di D-116:
  ogni gancio provato con regole sintetiche e neutro finché nessuna
  regola vera lo usa. *(Fatti in 0.1.88, D-125; i denti veri in 0.1.89,
  D-126; la morte di Vaerax in 0.1.90, D-127.)*

### Aggiornamenti del verbale, dopo il lavoro

- **C, la Leggenda della Montagna**: il committente approva la direzione
  e **la progettazione si fa in una seduta dedicata**. Diaspora, Forni
  Riaccesi ed Egemonia restano in attesa di un sì o un no espliciti.
- **D, il ritrovamento che la blocca**: i valori d'azione sono oggi
  **solo stampa**. Lo schema li dichiara «peso di sapore per la policy di
  default, non un modificatore della matematica di risoluzione (v0.2)» —
  ma la policy che li leggeva è stata sostituita in D-021 da quella a
  obiettivi, che è una scala di priorità **senza pareggi**: non c'è un
  punto dove un peso possa mordere. Ridistribuirli ora sarebbe «cambiare
  solo i numeri sulla carta», che è esattamente ciò che la regola della
  casa vieta. Due strade oneste, da scegliere in seduta:
  1. **dichiararli sapore di stampa** e allineare i numeri ai denti veri
     che ogni vita ormai ha (D-124/D-126) — la differenziazione meccanica
     per vita esiste già, vive nelle tag_rules;
  2. **rimandare la D alla 0.4**, quando il modello narrativo locale
     cambierà comunque lo strumento che decide — e lì i pesi avranno un
     lettore vero, da misurare contro baseline nuove.
  La raccomandazione del dossier è la 1 adesso e la 2 quando verrà.
  **Scelta dal committente: la strada 1** («Vai») — eseguita in 0.1.91
  (D-128): la tabella di D-108 era già buona, corretto il solo Culto della
  Misura (il velo è un'arte dello SCHEME: 3 → 4, INFLUENCE 4 → 3).
- **La C è confermata ed eseguita** («D vai con la 1 e sì per C», a
  verbale): le tre vite sono scritte, una alla volta col loro pezzo di
  motore — i Forni Riaccesi (0.1.92, D-129: entrata sbarrabile col
  sigillo, l'azione che sfoga, il minerale composito), la Diaspora
  (0.1.93, D-130: il conto delle cacciate nei segni, la porta che non la
  tiene, la sentinella dei NONE nella sonda delle ere), l'Egemonia di
  Eredan (0.1.94, D-131: il segno qualificato per Regione, lo sconto sul
  diritto, il tetto verso di lei). Ogni vita resta una regola nei dati:
  si spegne senza toccare il motore. **Della seduta resta solo la
  Leggenda della Montagna**, da progettare nella sua seduta dedicata.

---

## 5. Le quattro vite mai scritte, spiegate una per una (la C)

### La Diaspora — il Popolo Nahr disperso

**Chi è.** Il popolo che ha smesso di chiedere una terra: se il mondo lo
caccia due volte, smette di avere un centro — e diventa impossibile da
chiudere fuori.

**Quando entra.** Alla successione fra le ere, se nell'era appena chiusa
Nahr è stato **cacciato o espropriato due volte** (le espulsioni dei
Consigli, la Valle requisita). Non è una scelta: è quello che il tavolo
gli ha fatto.

**Come si gioca diversa.** Il suo potere è l'**eccezione di porta**: le
porte sbarrate — la cacciata di un Consiglio (D-067), il confine
sigillato, la strada depredata — **non la tengono**. Dove gli altri
restano fuori un atto intero, la Diaspora rientra il round dopo. In
partita: la cacci dalla Valle al secondo atto, e al terzo i suoi fuochi
sono di nuovo lì.

**Cosa rischia il tavolo.** L'espulsione è la leva che rende perdibile il
Minimo (D-067): per la Diaspora quella leva si spunta. Va misurato che
Nahr non diventi imperdibile — se il suo NONE sparisce dalle saghe, la
vita va ritoccata (per esempio: rientra, ma il rientro costa l'azione).

**Cosa chiede al motore.** L'eccezione di porta (pezzo E, autorizzato).

### La Leggenda della Montagna — Vaerax sfumato

**Chi è.** Il drago che non si è mai alzato: se la miniera sigillata regge
**tre ere** e nessuno lo ha svegliato, la creatura smette di essere un
corpo e diventa la storia che si racconta di lei. Il seggio passa a *chi
custodisce quella storia*.

**Quando entra.** Alla successione, dopo tre ere con il sigillo intatto e
il Risveglio mai sfondato.

**Come si gioca diversa.** È la vita più radicale: **non ha pedine sulla
mappa**. Niente presenze, niente MOVE, non la si può cacciare — non c'è
da dove. Gioca soltanto sui Consigli e sulle leggende: i suoi fronti
valgono di più dove una leggenda della montagna è nel mondo, e **pesa
sulla pesca delle domande** delle ere future (il meccanismo del peso
delle leggende esiste da D-095). In partita: un giocatore senza segnalini
che decide quali domande il mondo si farà.

**Cosa rischia il tavolo.** Il suo Minimo non può più essere «sei ancora
lì» — serve un Destino su misura (clausole su leggende e Consigli), da
scrivere con la stessa cura dell'audit dei Destini: una vita senza NONE
possibile violerebbe la voce 15.

**Cosa chiede al motore.** Il «seggio senza corpo»: più di un tipo di
regola — il movimento vietato per natura, il Minimo non-di-presenza. È la
vita da disegnare insieme per ultima, e il dossier propone di approvarla
**come direzione** e progettarla in una seduta sua.

### I Forni Riaccesi — Kessa industriale

**Chi è.** I Signori della Cenere quando la miniera riapre: la ferita
aperta della montagna (la cicatrice di D-122) diventa un'occasione, e la
casa che vegliava diventa la casa che produce.

**Quando entra.** Alla successione, se `scar:open_wound` è sulla mappa e
il sigillo non c'è — cioè se il tavolo ha sfruttato il Cristallo e nessuno
ha richiuso.

**Come si gioca diversa.** L'industria: alle Montagne Rosse **pesca
meglio** (il minerale paga), ma **ogni volta che forgia, la Carestia
sale** — i forni mangiano il grano della Valle. In partita: Kessa diventa
ricca e sporca; il tavolo la lascia produrre sapendo che il conto arriva
sulla domanda del pane, e la Carestia diventa anche affare suo.

**Cosa rischia il tavolo.** Accelera la Carestia: da misurare che i
Consigli restino in banda e che Kessa non compri la partita.

**Cosa chiede al motore.** La pesca c'è (DRAW_BIAS); il costo «quando
forgi, una Tensione sale» è un **sesto pezzo piccolo** non elencato in E
— l'azione che sfoga su una domanda. Da autorizzare con questa vita.

### L'Egemonia — le Città Libere ridotte a una

**Chi è.** Quando le altre città si sono svuotate e una sola resta piena,
le Libere smettono di essere un coro: una città comanda, e parla come
comanda.

**Quando entra.** Alla successione, se una sola delle città è piena e le
altre portano il segno dello svuotamento.

**Come si gioca diversa.** Il **diritto potenziato**: i suoi CLAIM pesano
di più (rivendicare le costa meno, forzare il Consiglio è più facile) —
ma **nessuno ama l'egemone**: le relazioni con lei hanno un tetto ad
ALLY, non si sale oltre. In partita: le Libere passano dal votare
all'imporre l'ordine del giorno, e il tavolo smette di fidarsi.

**Cosa rischia il tavolo.** Il diritto di proporre è la leva più forte
del gioco (D-063): il CLAIM potenziato va misurato con la sonda delle
scelte, non solo col playtest.

**Cosa chiede al motore.** Il tetto c'è (RELATION_CAP). Il CLAIM
potenziato è un tipo piccolo (lo sconto sul diritto), da autorizzare con
questa vita.

**La domanda C, riformulata**: quali delle quattro approvi — e per la
Leggenda della Montagna, va bene approvarla come direzione e disegnarla
in una seduta dedicata?
