# Le trasformazioni dei seggi — l'albero delle vite (proposta di design)

Studio richiesto dal committente (voce 19): come possono trasformarsi le
otto case, il drago compreso — e con quali **poteri asimmetrici**, perché
la regola della casa è questa:

> **Nessuna vita entra nei dati senza tre cose: un ingresso narrativo
> scritto (quando e perché entra), almeno un potere asimmetrico
> misurabile, e il suo tarocco con prompt d'arte. Una vita che cambia
> solo il nome sulla carta non si scrive.**

## Il meccanismo (cosa c'è già, cosa manca)

**C'è già** (0.1.70): la traversata a linea esaurita (`LINE_EXHAUSTED`),
la vista della vita corrente, il verbale che racconta il passaggio. E c'è
il telaio dei denti (D-104): i poteri per vita **non richiedono ganci
nuovi dedicati** — alla trasformazione il motore posa sulla casa un segno
`life:<id>`, e le tag_rules lo leggono come leggono ogni altro segno.

**Manca** (le fasi da fare, in ordine):

1. **Gli ingressi che scelgono la vita**: oltre a `LINE_EXHAUSTED`,
   `ON_TAG` (entra la vita il cui segno è sul mondo o sulla casa nel
   momento della successione — così *cosa è successo in gioco decide chi
   nasce*) e `ON_DEATH` (il seggio sopravvive alla creatura). Più vite
   candidate: entra la prima, in ordine d'autore, il cui ingresso è vero.
2. **Il segno di vita** `life:<id>` posato alla trasformazione, e i tipi
   di regola della voce 25 (azione vietata/concessa, pesca piegata,
   fronte che vale di più) che sono esattamente il vocabolario dei poteri.
3. **Il tarocco per vita** (già a verbale, Fase 3 della voce 19).
4. **La misura**: ogni vita accesa da sola sui 100 semi, 0/8 sempre.

## L'albero, casa per casa

Il potere fra parentesi dice il gancio: *(c'è)* = esprimibile oggi con le
tag_rules; *(voce 25)* = serve un tipo di regola già a verbale.

### Re Aldric — la dinastia (MORTAL)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **La Repubblica della Valle** *(scritta, 0.1.70)* | linea esaurita | COLLECTIVE | il consenso prudente: quando propone, World Factor −1; quando si oppone, il suo fronte vale +1 *(metà c'è, metà voce 25)* |
| **La Reggenza del Granaio** | linea esaurita **e** il mondo ricorda `grain_requisitioned` o la corona è spodestata | COLLECTIVE | il granaio vale doppio per lei; INFLUENCE sulla Carestia +1 ovunque *(c'è)* |
| **La Corona Restaurata** | dalla Repubblica, se `order_restored` **e** `heir_named` | **torna MORTAL**, eredi nuovi | il ciclo si chiude: la restaurazione riparte con CLAIM forte *(c'è)* — le vite possono essere un cerchio, non una fila |

### Popolo Nahr — il popolo in cammino (COLLECTIVE)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **Il Regno di Nahr** | `nahr_settled` (la terra a chi la lavora) da due ere | **diventa MORTAL** — il popolo che si siede guadagna re, ed eredi da consumare | perde l'immunità del cammino, guadagna il granaio e CLAIM; è la trasformazione *al contrario*, e costa |
| **La Diaspora** | cacciate ripetute (`evicted`/`requisitioned` due volte in un'era) | COLLECTIVE | il popolo disperso non può essere sbarrato: le porte (GATE) non lo tengono *(voce 25: eccezione di porta)* |

### Lyra — la studiosa (MORTAL)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **Il Culto della Misura** *(scritta, 0.1.70)* | linea esaurita | COLLECTIVE | il dogma vela: i suoi SCHEME possono **chiudere** un numero al tavolo, non solo aprirlo *(voce 25)* |
| **L'Accademia delle Misure** | linea esaurita **e** il mondo ricorda `ledger_public` o la legge scritta | COLLECTIVE | il sapere aperto: quando svela una Tensione la svela per tutti, e i Consigli su KNOWLEDGE partono con World Factor +1 per lei *(c'è)* |

La stessa morte, due nascite: cosa il tavolo ha fatto del sapere di Lyra
decide se nasce la chiesa o l'università.

### Vaerax — il drago (ETERNAL)

La domanda del committente. Un ETERNAL non esaurisce linee: le sue vite
entrano **per evento**, e il seggio sopravvive alla creatura.

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **Il Culto della Montagna** | **alla morte** (`ON_DEATH`: oggi nessuna Conseguenza sa uccidere Vaerax — scriverne una, con il Consiglio più costoso del gioco, è contenuto d'autore che questa vita rende possibile) | COLLECTIVE | la memoria arma i fedeli: finché le Cicatrici della montagna esistono, +1 sui Consigli del Risveglio; le reliquie (`discovery:crystal`) valgono doppio per loro *(c'è)* |
| **Vaerax Ridestato** | il Risveglio sfonda per due ere (`crystal_exploited` e la domanda mai chiusa) | ETERNAL | la paura: chi si oppone a lui con presenza sulle Montagne Rosse parte con World Factor −1; dalle Montagne non lo si caccia *(c'è)* |
| **La Leggenda della Montagna** | la miniera sigillata regge per tre ere e il drago non si è mai alzato | la creatura sfuma: il seggio è **di chi custodisce la storia** | non ha più corpo sulla mappa: gioca solo sui Consigli e sulle leggende, e pesa sulla pesca delle domande future *(c'è: il peso delle leggende esiste da D-095)* |

### Maestra Ilve — la Gilda del Sale (MORTAL)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **La Compagnia del Sale** *(scritta, 0.1.70)* | linea esaurita | COLLECTIVE | il credito federato: ACQUIRE su WEALTH pesca meglio *(voce 25: pesca piegata)* |
| **Il Banco Nero** | linea esaurita **e** `debt_called` con città indebitate | COLLECTIVE | l'usura: le case con la sede indebitata (`condition:indebted`) valgono −1 quando si oppongono al Banco *(c'è)* |

### Priore Anselmo — l'Ordine del Vetro (MORTAL)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **I Frati del Vetro** *(scritta, 0.1.70)* | linea esaurita | COLLECTIVE | la regola come misura: +1 sui Consigli dove la reliquia è custodita (`structure:sealed`) *(c'è)* |
| **L'Inquisizione del Vetro** | linea esaurita **e** `relic_shown` con inquietudine diffusa | COLLECTIVE | la custodia si fa polizia: può riaprire una domanda chiusa, come il Magistrato che il committente vuole *(voce 25)* |

### Kessa dei Fuochi — i Signori della Cenere (MORTAL)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **Le Custodi della Cenere** *(scritta, 0.1.70)* | linea esaurita | COLLECTIVE | la veglia: la torre (`structure:watchtower`) vale doppio; nessuno entra alle Montagne senza che lo sappiano *(c'è)* |
| **I Forni Riaccesi** | la miniera riapre (`scar:open_wound` senza sigillo) | COLLECTIVE | l'industria: ACQUIRE +1 nelle Montagne Rosse; ma la Carestia sale quando forgiano *(c'è)* |

### Le Città Libere (COLLECTIVE)

| vita | quando entra | natura | il potere asimmetrico |
|---|---|---|---|
| **La Lega delle Sette** | `charter_written` (la carta firmata) | COLLECTIVE | la firma che pesa: le sue Condition qualificano con una soglia più bassa *(voce 25)* |
| **L'Egemonia** | una sola città resta piena (le altre `condition:emptied`) | COLLECTIVE | una città comanda: CLAIM +1, ma le relazioni con lei non salgono sopra ALLY *(c'è)* |

## Perché così e non «più nomi»

Ogni riga di queste tabelle obbedisce alla regola in cima: un ingresso
che dipende da **cosa è successo in gioco** (non dal calendario), un
potere che **si sente al tavolo** (non un numero sulla carta), e — quando
si scriverà — il suo tarocco. L'albero fa anche una cosa che una fila di
successori non può fare: **la stessa morte ha più nascite possibili**, e
a scegliere è la storia che i giocatori hanno scritto. È il contrario dei
nomi che cambiano su una carta.

L'ordine dei lavori proposto: prima gli ingressi (`ON_TAG`/`ON_DEATH`,
vite alternative), poi il segno `life:` e i primi poteri *(c'è)* accesi
uno alla volta, poi i tipi della voce 25 per i poteri più ambiziosi, e i
tarocchi per vita in coda. Ogni vita si misura da sola, e il vincolo
resta quello di sempre: 0/8 seggi bloccati al tavolo misto.
