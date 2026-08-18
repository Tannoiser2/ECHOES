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
