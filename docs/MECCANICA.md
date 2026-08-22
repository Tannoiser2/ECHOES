# ECHOES — la meccanica di gioco, per intero

**A cosa serve questo documento.** È una spiegazione completa e autosufficiente
di come funziona ECHOES, scritta per essere data in pasto a un modello che deve
produrre **un'infografica**. Non presuppone niente: chi legge non ha mai visto
il gioco. Tutti i numeri qui dentro sono quelli veri, letti dai dati e dal
codice della versione 0.1.149 — non sono esempi inventati. **Le fonti di Asset di §3 sono
quelle di 0.1.154; §5 (il turno) è stato riscritto a 0.1.156, quando le azioni
sono passate sulle carte; §11 (le Tensioni velate) e §12 a 0.1.155; §4 (da dove
viene il calore) e §5 (RIVENDICARE) a 0.1.160**, quando il velo ha smesso di
coprire il numero e ha cominciato a coprire la soglia; la riga dei Consigli in
§14 è ripresa dalla misura di 0.1.155. Il resto dei numeri è quello di 0.1.149.

In fondo ci sono due sezioni che non servono a disegnare: **«Come si gioca
bene»** (§15), che dice cosa conviene fare al tavolo con i numeri accanto, e
**«Note per chi disegna»** (§16), con i suggerimenti su cosa merita un riquadro,
cosa merita una freccia e cosa si può omettere.

---

## 0. In una frase

> ECHOES è un boardgame narrativo-strategico per **4 giocatori**, in cui quattro
> casate attraversano **un anno di crisi**: dentro l'anno nessuno vince prendendo punti —
> ognuno insegue un **Destino** privato, e le decisioni si prendono in
> **Consigli** dove si vota una proposta e si impegnano carte in segreto. Quello
> che il Consiglio decide resta scritto sul mondo, e il mondo passa alla
> partita successiva.

Le tre idee che lo distinguono da un gioco di conquista:

| idea | cosa vuol dire |
|---|---|
| **Nessun punteggio dentro l'anno** | Ogni casata ha un Destino a tre gradini e li raggiunge o no per conto proprio. Più giocatori possono vincere; tutti possono fallire. Un punteggio esiste **solo a livello di saga** (§10bis), e serve a decretare chi ha vinto la campagna — non chi ha vinto la serata. |
| **Il Consiglio è il cuore** | Le azioni servono a prepararsi. È al Consiglio che il mondo cambia davvero — e non con un tiro di dado, ma con carte impegnate al buio e rivelate insieme. |
| **Il mondo ricorda** | Una partita (una *Chronicle*) è **un anno**. Una **saga** ne incatena molte, a decenni o secoli di distanza: la mappa, le ferite e i rancori attraversano il salto, le persone no. |

---

## 1. La piramide del tempo

```
SAGA            più Chronicle, a distanza di 1 → 200 anni
 └─ CHRONICLE   un anno · 3 Atti
     └─ ATTO    3 round · a inizio Atto ogni giocatore pesca 2 carte Narratore
         └─ ROUND
             ├─ 1. AZIONI      ogni giocatore spende 2 Opportunità d'Azione
             ├─ 2. DERIVA      il mondo alza da solo +1 a una Tensione
             └─ 3. SOGLIA      si apre al massimo UN Consiglio
```

**Una Chronicle = 3 Atti × 3 round = 9 round.** Ogni giocatore ha 2 Opportunità
d'Azione (AO) per round → **18 azioni per giocatore in tutto l'anno**, 72 al
tavolo. Le AO non si accumulano: quelle non spese sono perse.

Un'azione **rifiutata dalle regole consuma comunque l'AO**: il tempo passa anche
quando il piano non funziona.

**Alla fine della Chronicle** si valutano i Destini, si scrive il registro delle
Verità, e il mondo viene salvato per l'anno successivo.

---

## 2. I pezzi sul tavolo

Cinque parole coprono tutto lo stato del gioco. Se l'infografica ha un riquadro
"i componenti", sono questi.

| pezzo | cos'è | come si muove |
|---|---|---|
| **Regione** | una casella della mappa. 6 in tutto. Ha *slot di presenza*, *adiacenze*, *tag*, e forse un *padrone*. **Esserci** (presenza) e **averla** (controllo) sono due cose diverse — vedi §3 | presenza con MUOVERE · controllo solo tramite una Conseguenza di Consiglio |
| **Tensione** | una domanda aperta del mondo, con un numero da 0 in su. 4 in gioco per anno | sale con la Deriva e con le carte, scende quando un Consiglio la risolve |
| **Asset** | una carta in mano: uomini, titoli, gente, sapere, ricchezza, legami. Porta **un'azione**, un valore al Consiglio e un effetto suo | la dà la mappa a inizio Atto, secondo dove tieni le pedine; si spende **o** per agire **o** impegnandola al Consiglio |
| **Relazione** | il rapporto fra due casate, su 5 gradini | si sposta di 1 passo con FORGIARE |
| **Destino** | l'ambizione privata della tua casata, a 3 gradini | non si "muove": si avvera o no, e si controlla a fine anno |

E tre cose che il gioco **scrive** e non si possono cancellare:

| traccia | cos'è |
|---|---|
| **Eco** | un momento memorabile registrato durante un Consiglio particolarmente teso |
| **Verità** | la frase immutabile che quell'Eco lascia scritta nella storia del mondo |
| **Cicatrice** | un segno permanente su una Regione (`scar:burned`, `scar:the_empty_chair`, `scar:broken_bridge`…). Resta anche fra una Chronicle e l'altra |

### Le quattro casate

Un tavolo è **quattro casate**, e non sono simmetriche: hanno bisogni diversi,
partono in posti diversi, e si detestano già prima che il gioco cominci.

**Chronicle I — l'anno 812, «La Carestia Rossa»:**

| casata | che cosa è | bisogno | parte da | rapporti d'apertura |
|---|---|---|---|---|
| **Re Aldric** | il sovrano. Terzo della sua casa, primo a regnare su un raccolto che non basta | POTERE | Eredan, Valle Verde | **ostile** ai Nahr |
| **Popolo Nahr** | non un esercito e non una folla: una lingua, un calendario e undicimila persone che si spostano quando la terra smette di rispondere | SOPRAVVIVENZA | Terre Nahr, Valle Verde | **ostile** ad Aldric |
| **Lyra** | studiosa senza patrono. È scesa nelle Miniere per misurare una pietra e ne è risalita con una domanda | SAPERE | Miniere Antiche, Eredan | **ostile** a Vaerax |
| **Vaerax** | dorme sotto le Montagne Rosse da prima che Eredan avesse un nome. Si sveglia raramente, e mai per una ragione piccola | PROTEZIONE | Montagne Rosse, Miniere Antiche | **ostile** a Lyra |

**Chronicle III — secoli dopo, «l'anno del Sale»:** stessa mappa, gente nuova.

| casata | che cosa è | bisogno | parte da | rapporti d'apertura |
|---|---|---|---|---|
| **Maestra Ilve** | la Gilda del Sale: non possiede nessuna città e tiene il registro di tutte. Non chiede obbedienza, chiede una firma | RICCHEZZA | Strada dei Mercanti, Eredan | **alleata** alla Cenere, **ostile** alle Città |
| **Kessa dei Fuochi** | i Signori della Cenere, che tengono le Montagne e campano di quello che l'antica miniera ha lasciato indietro | POTERE | Montagne Rosse, Miniere Antiche | **nemica** del Vetro, alleata al Sale |
| **Priore Anselmo** | l'Ordine del Vetro: discende da una scuola e si comporta da fede. Custodisce quello che fu misurato | FEDE | Miniere Antiche, Eredan | **nemico** della Cenere, alleato alle Città |
| **Le Città Libere** | sette città che si governano da sole e si riuniscono solo quando non possono evitarlo | LIBERTÀ | Eredan, Valle Verde | alleate al Vetro, **ostili** al Sale |

Nota per l'infografica: i due tavoli hanno **forme di conflitto diverse**. Nel
primo anno ci sono due ostilità incrociate e nessuna alleanza — tutti soli. Nel
terzo ci sono già **due coppie alleate** che si guardano storto, che è una
partita completamente diversa a parità di regole.

Ogni casata comincia con **2 carte in mano** e **2 gettoni di presenza già
posati** (il terzo resta in riserva), e ogni *vita* (§11) ha un proprio
carattere: quanto le viene naturale acquisire, muoversi, influenzare, forgiare,
tramare o rivendicare.

---

## 3. La mappa

Sei Regioni, sempre le stesse in tutte le Chronicle. La forma del grafo è questa
(le linee sono le adiacenze, e si muove solo fra Regioni adiacenti):

```
   EREDAN ──── VALLE VERDE ──── TERRE NAHR ──── MONTAGNE ROSSE
     │              │                │                  │
     └──────────────┴─── STRADA ─────┘                  │
                     DEI MERCANTI                       │
                          │                             │
                          └───── MINIERE ANTICHE ───────┘
```

Otto collegamenti in tutto. **La Strada dei Mercanti è lo snodo**: tocca quattro
Regioni su cinque ed è l'unica che non è "di" nessuno per vocazione — motivo per
cui il gioco ci litiga sopra così spesso.

Le posizioni sul tabellone vero (coordinate normalizzate 0–1, utili per
ridisegnare la mappa con la stessa geografia):

| Regione | x | y |
|---|---|---|
| Eredan | 0,81 | 0,27 |
| Valle Verde | 0,69 | 0,68 |
| Terre Nahr | 0,25 | 0,73 |
| Montagne Rosse | 0,16 | 0,30 |
| Miniere Antiche | 0,33 | 0,17 |
| Strada dei Mercanti | 0,50 | 0,45 |

Adiacenze esatte:

| Regione | bioma | slot | adiacente a | fonti di Asset |
|---|---|---|---|---|
| **Eredan** | città | 4 | Valle Verde, Strada dei Mercanti | AUTORITÀ, FORZA |
| **Valle Verde** | valle | 4 | Eredan, Terre Nahr, Strada dei Mercanti | GENTE, RICCHEZZA |
| **Terre Nahr** | steppa | 4 | Valle Verde, Montagne Rosse, Strada dei Mercanti | AUTORITÀ, GENTE |
| **Montagne Rosse** | montagna | **3** | Terre Nahr, Miniere Antiche | FORZA, LEGAMI |
| **Miniere Antiche** | sottosuolo | 4 | Montagne Rosse, Strada dei Mercanti | SAPERE, LEGAMI |
| **Strada dei Mercanti** | strada | 4 | Eredan, Valle Verde, Terre Nahr, Miniere Antiche | RICCHEZZA, SAPERE |

*Due Regioni per ogni famiglia, e nessuna famiglia in più di due: la
distribuzione è stata rifatta a 0.1.154, quando si è visto che RICCHEZZA stava
in quattro Regioni e FORZA in una sola. Se la Regione decide che carte peschi,
quello non è colore: è un'azione che qualcuno non potrebbe mai fare.*

**Presenza.** Ogni casata ha **3 gettoni di presenza**, di cui **2 già posati
all'inizio** — il terzo si mette in gioco con la prima MUOVERE, e da lì in poi
MUOVERE sposta invece di aggiungere. Più gettoni nella stessa Regione sono
ammessi e contano: la presenza è un numero, non una bandierina. È quel numero a
decidere chi propone al Consiglio. Una Regione non può ospitare più gettoni dei
suoi slot.

**Controllo.** Diverso dalla presenza: è il *padrone* della Regione, cioè chi ci
sta scritto sopra. All'inizio tre Regioni su sei hanno un padrone e tre non sono
di nessuno. Il controllo **non si prende con un'azione diretta**: cambia solo
come Conseguenza di un Consiglio (vedi §6.3 e §7).

### Presenza e controllo: la distinzione che conta

Sono due cose diverse e si confondono facilmente. **La presenza fa, il controllo
si conta.**

**Che cosa comanda la presenza** — cioè tutto quello che *fai* durante l'anno:

| | |
|---|---|
| **chi propone al Consiglio** | chi ha **più presenza** nelle Regioni del dominio |
| **INFLUENZARE gratis** | serve presenza in una Regione taggata col dominio di quella Tensione, altrimenti paghi una carta |
| **ACQUISIRE potenziato** | presenza in una Regione che elenca quella famiglia → peschi 2 e ne tieni 1 |
| **dove puoi MUOVERE** | solo verso Regioni **adiacenti** a una dove sei già |
| **le regole dei segni** | quelle con `scope: REGION` valgono per chi ha presenza lì |
| **le clausole di Destino** | 16 chiedono di **essere** in un posto (`region_presence`) |

**Il controllo non si scrive: si conta.** Alla fine di ogni round, per ogni
Regione, il tavolo fa una somma per ciascuna casata:

```
FORZA = (pedine × 1) + (valore delle proprie strutture in quella Regione)
```

Chi ha la forza **strettamente maggiore** tiene la Regione. A parità non cambia
niente: chi la teneva la tiene, e una Regione contesa alla pari resta contesa.
Non c'è un'azione «conquista»: il controllo è **il risultato di dove stai e di
cosa hai costruito**, ricalcolato ogni round.

È il punto in cui la mappa ha cominciato a muoversi davvero: un castello vale 3,
un esercito di tre pedine vale 3, e chi ne mette una quarta prende la Regione.

**Che cosa comanda il controllo:**

| | |
|---|---|
| **le clausole di Destino** | 14 chiedono di **avere** un posto (`control_count`) |
| **la sovraestensione** | oltre 2 Regioni, **+1 di Tensione a round** per ognuna in più: un costo, non un vantaggio |
| **il passaggio all'anno dopo** | quello che tieni resta tuo — ma **solo se ci stai dentro**: una Regione tenuta senza nessun gettone torna a non essere di nessuno |

**C'è una leva scritta e spenta, e vale la pena saperlo.** `focus_weight`
darebbe voce al Consiglio a chi tiene o presidia la Regione *di cui si discute*.
È costruita e provata, e **nessuna delle quattro Chronicle la accende**: alla
misura sui 100 semi bloccava un seggio su un livello solo. Il meccanismo aspetta
un contenuto che regga.

**I tag della mappa** sono il vocabolario con cui il mondo si segna:
`condition:starving`, `condition:unrest`, `condition:cut_off`, `scar:burned`…
Ci sono **52 regole** che leggono questi tag e cambiano il gioco di conseguenza
(vedi §9).

---

## 3bis. La terra che si costruisce

Sulla mappa non ci sono solo pedine: ci sono **cose**, e le cose hanno un tipo,
un grado, un padrone e un valore. Sono l'unico strato del gioco che **passa da
una partita all'altra** senza che nessuno lo scriva a mano.

### I nove tipi, in quattro famiglie

**Le opere delle case** — hanno un padrone e **pesano nel conto del controllo**:

| famiglia | tipo | i gradi (e quanto valgono) |
|---|---|---|
| PRESIDIO | il presidio | Torre di veglia **2** → Castello **3** → Reggia **5** |
| INSEDIAMENTO | l'insediamento | Villaggio **1** → Borgo **2** → Città **4** |
| OPERA | granaio, canale, pedaggio | grado I **1** → grado II **2** |

**I luoghi del mondo** — non sono di nessuno, e cambiano *cosa vale* una
Regione, non *chi la tiene*:

| famiglia | tipo | i gradi |
|---|---|---|
| LUOGO | la foresta | Foresta → Bosco diradato → **Selva maledetta** |
| LUOGO | il sito antico | Sito dormiente → Sito aperto → **Sito saccheggiato** |
| LUOGO | la sorgente | Sorgente viva → Sorgente bassa → **Sorgente secca** |
| LUOGO | il passo | Passo aperto → **Passo franato** |

### La scala segue il Destino

Alla chiusura dell'anno, una struttura per casata si muove di un grado, **e la
direzione la decide come è andato quell'anno**:

- chi ha ottenuto il **Trionfo** vede una delle sue cose **salire** — la torre
  diventa castello, il castello diventa reggia;
- chi non ha raggiunto nemmeno il **Minimo** ne vede una **scendere** — e sotto
  il primo grado c'è la rovina, che lascia una cicatrice sulla Regione.

Nessuno scrive «qui c'è una reggia»: la reggia è il sedimento di tre anni buoni
di fila. Su dodici saghe da otto anni ne restano in piedi **tredici castelli e
due regge** che nessun autore ha messo lì.

### Il passo che frana

Le adiacenze non sono una tabella: sono **stato del mondo**, e si possono
tagliare. Quando un passo frana, quel varco si chiude e chi voleva passare di lì
fa il giro lungo — o non passa.

C'è una guardia, ed è la regola più importante di tutto lo strato: il taglio si
tenta, si verifica che ogni Regione resti raggiungibile, e **se il mondo si
spezzerebbe l'arco si rimette e non è successo niente.** Una Regione
irraggiungibile è un Destino impossibile per chiunque la nomini.

Succede **una volta ogni quarant'anni** circa. È la frequenza giusta per un
fatto che riscrive la mappa.

---

## 4. Le Tensioni — le domande dell'anno

Ogni anno il mondo porta **4 Tensioni**: non "problemi da risolvere" ma
**domande aperte**, ciascuna con un numero che dice quanto è calda.

Le quattro dell'anno 812 (Chronicle I, «La Carestia Rossa»):

| Tensione | dominio | parte da | soglia | la soglia si vede? | famiglie di Asset che contano |
|---|---|---|---|---|---|
| **La Carestia** | SOPRAVVIVENZA | 3 | 6 | sì, aperta | RICCHEZZA, GENTE, AUTORITÀ |
| **Il Risveglio** | ANTICO | 2 | 6 | **no, velata** | SAPERE, FORZA, LEGAMI |
| **La Successione** | TERRITORIO | 2 | 6 | sì, aperta | AUTORITÀ, LEGAMI, FORZA |
| **Le Vie Interrotte** | RISORSA | 1 | 5 | **no, velata** | RICCHEZZA, SAPERE, GENTE |

*Il numero di partenza e quello corrente si vedono sempre, anche sulle velate:
è la soglia che sta sotto una carta girata (§11).*

Un secondo mondo (Chronicle III, «l'anno del Sale», secoli dopo) ne ha quattro
diverse: L'Acqua Ferma, Il Debito, La Reliquia, La Carta — più due di riserva,
I Senza Città e La Cenere che Sale.

Come si muove una Tensione:

| forza | effetto |
|---|---|
| **Deriva** | ogni round il mondo alza **+1** a una Tensione. L'ordine è un sacchetto di 9 gettoni (2 Carestia, 3 Risveglio, 2 Successione, 2 Vie) mescolato a inizio partita |
| **INFLUENZARE** | un giocatore la sposta di ±1 (una volta per giocatore per round, e una volta per Tensione per round) |
| **Carte** | Asset impegnati e carte Narratore la alzano o abbassano |
| **Consiglio risolto** | un successo la porta **a 1**; un fallimento la abbassa di 2 e lascia la domanda aperta |
| **Ripple** | un Consiglio chiuso alza di +1 le Tensioni collegate: risolvere una domanda ne scalda un'altra |

**La pressione si sposta, non sparisce.** Spingere **giù** una Tensione alza di
1 una delle sue Tensioni collegate — quella al valore più basso. Non si spegne
una crisi: si sceglie quale avere. Spingere **su** non sposta niente: alimentare
un incendio non è uno scambio.

**Velata.** Una Tensione velata mostra il proprio numero come tutte le altre —
è la **soglia** a stare coperta. Al tavolo vero è una carta girata a faccia in
giù accanto al segnalino: si vede dove sta la domanda, non dove sia il traguardo.
Il registro la scrive così: `Il Risveglio: 4/?`.

Sulla domanda si agisce come su ogni altra: non sapere quando esploderà è il
rischio, non un divieto. Per girare la carta serve l'azione TRAMARE — e saperlo
è **personale**: scoprirlo non lo rivela agli altri, e chi ha guardato gioca
sapendo quanto manca mentre gli altri tirano a indovinare.

*Fino a 0.1.154 il velo copriva il numero intero e vietava di toccare la
domanda. È stato cambiato perché al tavolo fisico era ingiocabile: il mondo
conosceva un valore che nessun giocatore poteva conoscere, e nessuno poteva
sapere quando una velata stesse per attivarsi.*

**Da dove viene il calore.** Non dal tempo: **da quello che fate**. Ogni azione
riuscita fa pescare un segnalino da un sacchetto, e quel segnalino alza di 1 la
domanda che nomina. Il sacchetto è tarato — nella Carestia Rossa ci sono nove
gettoni: 3 del Risveglio, 2 della Carestia, 2 della Successione, 2 delle Vie —
quindi ogni domanda ha una sua impazienza, e nessuno può decidere quale si
scalda. *Fino a 0.1.159 era un orologio: una domanda saliva a fine di ogni round.*

**Presagi.** A certe soglie il mondo dice una frase in pubblico, scritta a mano
nei dati, che non rivela mai il numero: *«I granai di Eredan si aprono un giorno
su tre. Nessuno lo ha annunciato: si vede dalle code.»*

**Il cancello del tavolo.** Dalla 0.1.171 non c'è più una soglia per domanda:
ce n'è **una per il tavolo**. Ogni carta calata fa cadere un gettone su una
domanda, i mucchi crescono, e quando sul tavolo sono scesi **due gettoni** si
apre un Consiglio: la domanda che si dibatte è il **mucchio più alto**, e poi il
conto riparte da zero. Al massimo un Consiglio per round.

Un Consiglio lo può aprire anche un giocatore, spendendo una rivendicazione
matura: anche quello svuota il sacchetto.

Il numero che le Tensioni portano scritto (la vecchia soglia) **non apre più
niente**, e infatti non si stampa da nessuna parte: quello che si legge è
l'altezza del mucchio, col più alto segnalato.

**Costo dichiarato**: i Consigli passano da 6,0 a **3,5–4,0 l'anno** — da due per
Atto a poco più di uno. Il Consiglio smette di essere routine e torna a essere un
evento ([D-203](DECISIONS.md#d-203)).

---

## 5. Il turno: le azioni, e da dove vengono

**Le azioni si fanno con le carte.** A inizio di ogni Atto la mappa riempie la
mano — **due carte per gettone di presenza**, fino a un massimo di **7**, e la
Regione dove tiene la pedina decide *di che famiglia* — e da lì in poi ogni cosa
che si fa si fa calando una carta.

Ogni carta è **tre cose insieme**:

| | |
|---|---|
| **un'azione** | quella scritta sulla carta: MUOVERE, INFLUENZARE, TRAMARE, FORGIARE, RIVENDICARE |
| **un valore al Consiglio** | la sua famiglia e la sua forza (1, 2 o 3) |
| **un effetto suo** | ciò che succede quando la si impegna a un Consiglio |

E qui sta il gioco: **una carta spesa per agire non voterà più**. Ogni turno è
la stessa domanda — *questa la spendo per fare, o la tengo per votare?*

La carta paga anche il costo della propria azione: INFLUENZARE senza presenza,
RIVENDICARE e FORGIARE in su chiedono di scartare un Asset, e l'Asset è la
carta stessa. Si spende una volta sola.

**ACQUISIRE non esiste più come azione**: era due terzi di tutto ciò che si
faceva, e adesso la fa la mappa.

*Questo è il mondo della Carestia Rossa (Chronicle I). Il mondo del Sale
(Chronicle III) gioca ancora col §10 di prima — un'Occasione compra un'azione,
le carte si pescano con ACQUISIRE — perché la sua mappa non è ancora stata
ridistribuita, e senza quella metà delle azioni sarebbe irraggiungibile per
qualcuno.*

**Quale azione porta quale famiglia.** Non è casuale: la Regione decide che
carte peschi, quindi la mappa decide che *cose* puoi fare. Chi sta sulle
montagne muove eserciti; chi sta nelle miniere sa; chi siede a Eredan prende la
parola.

| famiglia | le sue otto carte portano | il suo mestiere |
|---|---|---|
| **FORZA** | 5 × MUOVERE, 3 × INFLUENZARE (due in su, una in giù) | prende terra, e quando non la prende scalda — o mette un blocco |
| **AUTORITÀ** | 4 × RIVENDICARE, 3 × INFLUENZARE, 1 × FORGIARE | è l'unica che sa **prendere la parola** |
| **GENTE** | 4 × INFLUENZARE, 3 × MUOVERE, 1 × TRAMARE | si sposta, e preme |
| **SAPERE** | 5 × TRAMARE, 2 × INFLUENZARE, 1 × MUOVERE | gli occhi — e *cosa* si va a guardare lo sceglie chi cala la carta |
| **RICCHEZZA** | 3 × FORGIARE (in giù), 3 × INFLUENZARE, 2 × MUOVERE | compra, e rompe |
| **LEGAMI** | 4 × FORGIARE (in su), 2 × TRAMARE, 2 × INFLUENZARE | l'unica che sa **stringere** |

In tutto: **17 INFLUENZARE, 11 MUOVERE, 8 TRAMARE, 8 FORGIARE, 4 RIVENDICARE**.

Le cinque azioni che una carta può portare, tutte per **1 AO**:

| # | azione | cosa fa |
|---|---|---|
| 1 | **MUOVERE** | Aggiungi o sposta 1 gettone di presenza in una Regione **adiacente** a una dove sei già, o in una delle tue Regioni iniziali. Se la Regione è piena, l'azione è rifiutata senza danno |
| 2 | **INFLUENZARE** | Sposta di ±1 una Tensione. Serve **una** fra: presenza in una Regione del dominio di quella Tensione (gratis), oppure scartare 1 Asset di una famiglia rilevante |
| 3 | **FORGIARE** | Sposta di 1 passo una relazione. **Verso l'alto**: serve il consenso dell'altro giocatore e 1 Asset LEGAMI scartato. **Verso il basso**: unilaterale, gratuito, e finisce nel registro pubblico |
| 4 | **TRAMARE** | Uno fra: leggere in privato la **soglia** di una Tensione velata · guardare le prime 2 carte del mazzo Eco · leggere l'informazione privata di una Regione. Il risultato è **privato** |
| 5 | **RIVENDICARE** | Se la Tensione è **già a 3 o più**, la prendi in un colpo: scarti 1 AUTORITÀ e **strappi un Consiglio di cui sei tu il proponente**. Se non lo è ancora, la **prenoti** (CREATE) e la riscuoti quando matura. Non si prenota ciò che è già pronto |
| 6 | **CALARE UNA CARTA NARRATORE** | Gioca una delle carte Eco che hai in mano: la sua funzione narrativa diventa un fatto del mondo, i suoi effetti si applicano, e alcune carte **aprono un Consiglio**. Le carte del Narratore sono **un mazzo a parte**: non sono la mano, e non si pescano dalla mappa |

**La scala delle relazioni** (per FORGIARE):

```
NEMICO  ←→  OSTILE  ←→  NEUTRALE  ←→  ALLEATO  ←→  VINCOLATO
   ↑ gratis e unilaterale        ↑ serve consenso + 1 LEGAMI
```

I marchi speciali — PATTO, DEBITO, PROMESSA, VENDETTA, SANGUE — non si mettono
con FORGIARE: arrivano dalle carte e dalle Conseguenze.

**Un'alleanza è una spesa, e rende al Consiglio.** Salire costa un'Occasione
*e* una carta: chi si allea è chi non ha fatto altro con quel turno. In cambio,
un alleato che ti sostiene al Consiglio **parla più forte** — un passo sopra
NEUTRALE vale +1, VINCOLATO +2, con il tetto a 2 per seggio e solo se quel
seggio ha messo almeno **due carte** sul tavolo. Un'alleanza che aiuta senza
costare sarebbe un bonus passivo; una che chiede di metterci del proprio è una
scelta, e quella scelta è il gioco.

**Con chi conviene allearsi si capisce guardando come si vota.** Il tavolo tiene
il conto di chi è finito sullo stesso fronte e chi sul fronte opposto: ci si
allea con chi ti ha sostenuto finora. Il che vuol dire che ci si può
**sbagliare** — ed è la sola cosa su cui si possa costruire un tradimento.

---

## 6. Il Consiglio (Confluence) — il cuore del gioco

Quando il tavolo ha posato abbastanza gettoni, si ferma e si riunisce. È qui che
il mondo cambia. La sequenza è fissa e ha undici passi, **A → K**.

### 6.1 La sequenza

| passo | cosa succede | pubblico o segreto |
|---|---|---|
| **A. Innesco** | Sul tavolo sono scesi due gettoni (e si dibatte il mucchio più alto), oppure qualcuno ha forzato con RIVENDICARE, oppure una carta Narratore lo ha aperto | pubblico |
| **B. Domanda** | Si sceglie la domanda dell'anno fra quelle del modello. Una domanda già decisa quest'anno **non torna** finché ne resta una nuova da fare | pubblico |
| **C. Proposta** | Il **proponente** sceglie una proposta fra quelle strutturate del modello | pubblico |
| **D. Posizione** | In ordine di turno, ognuno dichiara: **Sostengo · Mi oppongo · A una condizione · Mi astengo**. Chi pone una condizione dichiara subito quale | **pubblico** |
| **E. Impegno** | Ognuno impegna **da 0 a 3 Asset** (0–2 se ha posto una condizione), a faccia in giù, e si rivelano **tutti insieme** | **segreto fino alla rivelazione** |
| **F. Fattore Mondo** | Si tira 1d6 | pubblico |
| **G. Risoluzione** | Il conto (sotto) | pubblico |
| **H. Conseguenza** | La carta Conseguenza che quell'esito scrive sul mondo | pubblico |
| **I. Cambio di stato** | Gli effetti si applicano davvero: controllo, presenze, tag, cicatrici | pubblico |
| **J. Verifica Eco** | Se il Consiglio è stato abbastanza teso, nasce un Eco e una Verità | pubblico |
| **K. Ripple** | Le Tensioni collegate salgono di +1 | pubblico |

**Chi è il proponente**, in ordine: chi ha forzato con RIVENDICARE · altrimenti
chi ha **più presenza** nelle Regioni del dominio · a parità, chi ha più Asset
di famiglie rilevanti in mano · a parità, l'ordine di turno.

### 6.2 La matematica

```
S  = somma dei valori del fronte SOSTEGNO (il proponente è sempre dentro)
C  = somma del fronte CONDIZIONE, ma solo se la clausola è qualificata
O  = somma del fronte OPPOSIZIONE
W  = Fattore Mondo

MARGINE  =  S + C − O + W
```

**Quanto vale un Asset impegnato:**

- la sua **forza piena** (1, 2 o 3) se la sua famiglia è fra quelle rilevanti
  per la Tensione in discussione;
- **1** altrimenti.

È tutta qui la ragione per cui prepararsi conta: la stessa carta vale 3 al
Consiglio giusto e 1 a quello sbagliato. Poi si applica l'eventuale modificatore
della carta (`+X sempre`, `+X solo se rilevante`, `+X solo in opposizione`).

**Il Fattore Mondo** è 1d6 letto così:

| dado | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| **W** | −2 | −1 | 0 | 0 | +1 | +2 |

**L'esito, dal margine:**

| margine | esito | effetto sulla Tensione |
|---|---|---|
| **≤ −1** | **FALLIMENTO** | scende di 2, e **la domanda resta aperta** |
| **0 … 1** | **SUCCESSO CON UN PREZZO** | va a 1, e si paga una Conseguenza in più |
| **2 … 4** | **SUCCESSO** | va a 1 |
| **≥ 5** | **SUCCESSO DECISIVO** | va a 1, e si guadagna una Conseguenza in più |

**La Condizione.** Chi dice «sono a favore, a un patto» impegna fino a 2 carte.
Se il loro totale è **≥ 2**, la clausola è *qualificata*: si allega a ogni esito
di successo **e il suo totale entra nel margine dalla parte del sostegno**. Una
condizione non qualificata non allega niente e non sposta niente — le carte sono
spese lo stesso. Negoziare è una mossa forte; negoziare a vuoto no.

**Il peso dell'alleanza.** Un alleato che ti sostiene parla più forte di uno
sconosciuto: chi sostiene il proponente ed è ALLEATO gli aggiunge +1, VINCOLATO
+2, **ma solo se mette almeno 2 carte sul tavolo**. Il fronte dell'opposizione
non prende niente: l'ostilità non è un bonus, è già il resto del gioco.

### 6.3 Che cosa esce dal Consiglio

L'ordine di applicazione è fisso perché è osservabile al tavolo:

1. tiro del Fattore Mondo
2. il conto
3. l'effetto sulla Tensione (−2 oppure a 1)
4. gli effetti che le carte impegnate pagano di tasca propria
5. la **Conseguenza** dell'esito
6. il *prezzo* (solo Successo con un Prezzo) o il *bonus* (solo Decisivo)
7. la clausola della Condizione, se qualificata e l'esito è un successo
8. la sorte degli Asset impegnati
9. la verifica dell'Eco
10. il Ripple

**La sorte degli Asset impegnati:**

| esito | cosa succede alle carte |
|---|---|
| **Fallimento** | tutto scartato, tranne 1 carta a scelta per ogni oppositore |
| **Successo** | tutto scartato, salvo le carte marcate «resta in mano» |

**Quando nasce un Eco** (e con lui una Verità immutabile) — se una di queste:

- l'esito è **Decisivo**; oppure
- è un successo e **S + O ≥ 6** (un Consiglio combattuto); oppure
- è un **fallimento con O ≥ 6** — una sconfitta memorabile è storia.

**Le Conseguenze** sono 52 carte scritte a mano. Sono loro, e solo loro, che
assegnano il controllo di una Regione: **14** portano un cambio di padrone, e
altre **7** costruiscono qualcosa che resta — il granaio, il pedaggio, il
canale, la torre di veglia, un villaggio dove la gente si è fermata. Un Consiglio
non lascia solo una decisione a verbale: lascia una cosa sulla mappa, che dal
round dopo pesa nel conto del controllo e sopravvive all'anno. Fra
gli esempi: *Il Granaio del Trono · La Valle Chiusa · La Miniera di Stato · La
Corona Divisa · Il Debito Chiamato · Il Seggio Preso · Il Luogo Abbandonato.*

---

## 7. Come si prende una Regione (la catena)

Vale la pena isolarla, perché è la domanda che ci si fa più spesso e la risposta
non è ovvia: **non esiste un'azione che ti dà una Regione.** Esiste un'azione che
ti dà il *diritto di aprire la discussione*.

```
1. hai 1 Asset AUTORITÀ  →  RIVENDICARE (CREATE): apri il Claim        [1 AO]
2. la Tensione bersaglio deve essere a 3 o più
3. hai un SECONDO Asset AUTORITÀ  →  RIVENDICARE (FORCE)               [1 AO]
        ↓
4. si apre un Consiglio dove IL PROPONENTE SEI TU
5. il Consiglio non deve fallire
6. la Conseguenza uscita dev'essere una delle 14 che cambiano il padrone
        ↓
   la Regione è tua
```

Cinque anelli in serie, due carte della stessa famiglia, due Azioni in round
diversi. È una catena lunga per scelta: *rivendicare non è prendersi una terra,
è costringere il tavolo a discuterne.*

---

## 8. Le carte

### 8.1 Asset — le carte in mano (132 carte, 48 tipi)

Sei famiglie, 8 tipi ciascuna, 22 carte stampate per famiglia:

| famiglia | cos'è |
|---|---|
| **FORZA** | armati, leve, spedizioni |
| **AUTORITÀ** | titoli, sigilli, editti |
| **GENTE** | folle, mobilitazioni, braccia |
| **SAPERE** | prove, misure, voci |
| **RICCHEZZA** | grano, oro, pedaggi |
| **LEGAMI** | giuramenti, favori, parentele |

Ogni carta ha una **forza** (1, 2 o 3 — 24 carte da 1, 12 da 2, 12 da 3), una
rarità, e spesso un **prezzo che paga da sola quando la impegni**: *la Leva
Contadina vale uomini, ma i campi restano soli e la Carestia sale di 1.* **47
carte su 48** hanno un effetto del genere.

### 8.2 Carte Narratore / Eco (39 carte)

Non sono eventi scriptati: ognuna porta una **funzione narrativa** (le funzioni
di Propp), delle condizioni di giocabilità, e degli effetti. A inizio di ogni
Atto **ogni giocatore pesca 2 carte** da un sacchetto pesato, e le cala quando
vuole spendendoci un'Azione.

Le **24 funzioni** presenti: ATTACCO, TRADIMENTO, CONQUISTA, SCOPERTA,
INCONTRO, DONO, MANCANZA, LIBERAZIONE, PERDITA, PRESAGIO, DIVIETO, PUNIZIONE,
RICONCILIAZIONE, RICHIESTA, RITORNO, RIVELAZIONE, SACRIFICIO, SEPARAZIONE,
SUCCESSIONE, TENTAZIONE, MINACCIA, TRASFORMAZIONE, USURPAZIONE, VIOLAZIONE.

Le carte sono divise in **cinque famiglie drammatiche**, e ogni Atto pesca dal
proprio sacchetto — è così che l'anno ha una forma narrativa invece di essere
piatto:

| Atto | sacchetto | il tono |
|---|---|---|
| **I** | PRESSIONE | qualcosa stringe |
| **II** | ROTTURA ×2, SVOLTA ×2, PRESSIONE | qualcosa si spezza |
| **III** | RISOLUZIONE ×3, SVOLTA, ROTTURA | qualcosa si chiude |

(la quinta famiglia, MEMORIA, entra solo negli anni che ereditano un passato)

**Nove carte su 39 aprono un Consiglio** appena calate.

---

## 9. Il mondo che risponde: le 52 regole dei segni

Ogni tag scritto sulla mappa, su una casata o su una coppia di casate può
**cambiare le regole**. Non sono effetti una tantum: finché il segno c'è, la
regola vale. Le 52 regole si dividono così:

| tipo | quante | esempio |
|---|---|---|
| **COUNCIL_MODIFIER** | 17 | *finché una Regione muore di fame, i Consigli sulla Carestia partono col mondo contro* |
| **DRAW_BIAS** | 14 | *finché il Banco ha chiamato il debito, chi pesca ricchezza guarda due carte e prende la peggiore* |
| **ACTION_MODIFIER / GRANT / DISCOUNT / RIPPLE** | 5 | *chi sta nella Regione del granaio pesa di più sulla Carestia* |
| **RELATION_CAP / FLOOR** | 4 | *dopo un giuramento spezzato, quella coppia non risale sopra OSTILE* — e *il segno SANGUE non lascia scendere sotto NEUTRALE* |
| **GATE** | 3 | *dove è passata la razzia non si entra, finché qualcuno non toglie il segno* |
| **HAND_LIMIT** | 3 | *chi ha presenza in una Regione affamata tiene una carta in meno: la fame consuma* |
| **ACTION_GATE** | 2 | *chi ha presenza in una Regione affamata non stringe alleanze: i patti non si firmano a stomaco vuoto* |
| **STANCE_MODIFIER** | 2 | *quando la Repubblica si oppone con almeno una carta, il suo fronte vale +1* |
| **CONDITION_THRESHOLD** | 1 | *per la Lega delle Sette una Condizione qualifica con un impegno in meno* |
| **GRANT_ON_SET** | 1 | *chi riapre i canali riceve la Riserva di Grano* |

---

## 10. Il Destino — come si vince

Non c'è un punteggio, non c'è una classifica, non c'è un vincitore unico. Ogni
casata giura un **Destino**: un'ambizione privata a **tre gradini cumulativi**.

```
MINIMO      «esistere»            la casata è viva e sta da qualche parte
   ↓        (è una soglia di sopravvivenza, non un obiettivo)
VITTORIA    «contare»             quello che la casata voleva davvero
   ↓
TRIONFO     «e nessuno può dire il contrario»
```

**Il Destino non è fisso: si pesca.** Ogni casata ha un **pool di tre**, e quale
le tocchi lo decide il seme — due ambizioni scritte per lei più una
*condivisibile*, cioè una carta scritta una volta e messa nel pool di più case,
le cui clausole si risolvono su chi la giura. Sono **19 Destini in gioco** dalla
prima partita invece degli otto di una volta (il ventesimo appartiene a un seggio
che entra solo in saga), ed è quello che fa sì che lo stesso tavolo con lo stesso
anno non giochi la stessa partita.

Costo dichiarato di quella scelta: undici ambizioni in più al tavolo si oppongono
fra loro molto più spesso, e accendere il pool ha portato i Consigli falliti da
**206 a 246** su cento partite — il tasso di successo dal 64% al 56%. È la causa
principale del 44% di Consigli che oggi falliscono.

**Cumulativi**: un Trionfo richiede che valgano anche Vittoria e Minimo. Più
giocatori possono ottenere una Vittoria nello stesso anno. Tutti possono
fallire.

Ogni gradino è una lista di **clausole** verificate automaticamente sul mondo a
fine anno. I tipi di clausola disponibili:

| clausola | chiede |
|---|---|
| `control_count` | controlli almeno N Regioni |
| `region_presence` | hai presenza in una certa Regione |
| `state_tag_present / absent` | un segno c'è, o non c'è (sul mondo, su una Regione, su una casata) |
| `asset_threshold` | hai in mano almeno N carte di una famiglia |
| `tension_limit` | una Tensione è rimasta sotto (o sopra) un valore |
| `relation_state` | il tuo rapporto con qualcuno è almeno / al massimo un certo gradino |
| `entity_alive` | qualcuno è ancora al tavolo |
| `discovery_count` | hai fatto almeno N scoperte |
| `promise_kept / promise_broken` | una promessa ha tenuto, o no |
| `structure_count` | quante costruzioni tieni, per tipo, famiglia, grado e Regione |
| `scar_count` | quante cicatrici porta il mondo, o una Regione in particolare |
| `any_of` / `some_of` | almeno una — o almeno K — fra le clausole annidate |

### E nel primo anno la scala non c'è più: si contano quattro obiettivi

Dalla 0.1.166 **CHR_01 non sale più i tre gradini: conta**
([D-198](DECISIONS.md#d-198)). Ogni casa ne ha quattro.

```
  IL PALESE     il Destino giurato, letto alla Vittoria
                quello per cui la casa è venuta al tavolo — lo sanno tutti

  TRE COPERTI   pescati all'apertura da un pool di dodici
                li vedi solo tu, e nessuno sa cos'altro stai contando
```

A fine anno si contano quelli che si sono avverati. **Tutti e quattro è un
trionfo, nessuno è un anno perso**; in mezzo ci sono i successi parziali, e ognuno
vale un numero diverso alla fine della saga (**−1 · 1 · 2 · 5 · 8**): il terzo
e il quarto obiettivo pagano il salto più grosso, perché sono i due che quasi
nessuno prende.

I dodici del pool sono misurati uno per uno su cento Chronicle, dal 79,0% («una
pietra sua») al 10,2% («due Legami a fine anno»), e nessuno nomina una casa o un
posto: li può pescare chiunque, in qualunque mondo.

**Come va a finire davvero**, sui 200 seggi di CHR_01: nessun obiettivo nel
**19,0%** dei casi, uno nel 34,5%, due nel 32,5%, tre nell'11,5%, tutti e quattro
nel **2,5%**. In media **1,44** obiettivi a testa. Il confronto che conta è col
gioco di prima, dove «non raggiungere niente» capitava a 3 seggi su 400: **perdere
è tornato possibile.**

Il livello (MINIMO / VITTORIA / TRIONFO) non è sparito: si **deriva** dal conto,
così il verbale, il pannello e il punteggio di campagna continuano a leggere
quello che hanno sempre letto.

**Anche il mondo del Sale conta**, dalla 0.1.170: tutte e quattro le Chronicle
giocano a obiettivi. Sugli 800 seggi misurati, nessun obiettivo capita nel
**18,5%** dei casi e tutti e quattro nell'**1,9%**.

### La spina e la scelta

Il MINIMO e la VITTORIA sono liste da soddisfare per intero. Il **TRIONFO** no:
è fatto di due parti.

```
  la SPINA      una o due clausole in AND
                quello che quella casata voleva davvero — senza, non è quel Trionfo

  la SCELTA     «almeno K di queste N strade»
                come ci è arrivata: Tensioni, controllo, costruzioni,
                cicatrici, promesse, rapporti. Le strade non si sommano
                a un punteggio: se ne contano.
```

Una casata che ha perso una strada può prenderne un'altra, e due Trionfi dello
stesso Destino in due anni diversi possono essere fatti di cose diverse. La
scheda di fine anno apre la scelta strada per strada — quali erano, quali hai
preso — perché «tre di queste cinque» non si legge se non si vede quali.

**Esempio reale — Re Aldric:**

| gradino | etichetta | clausole |
|---|---|---|
| MINIMO | *Il trono regge* | Aldric è ancora sul trono · presenza a Eredan |
| VITTORIA | *Il regno decide* | la corona tiene ancora la sua terra (≥ 1 Regione) · la Carestia non supera 4 |
| TRIONFO | *Un regno che non ha pagato il pane con il sangue* | **spina:** Eredan non è in rivolta — **e tre segni su cinque:** nessuna questione lasciata aperta · la corona non è stata spezzata · nessuno ha ancora chiesto chi siede dopo · la corona ha più di una casa di pietra · Eredan è uscita dall'anno senza un segno |

Il risultato conserva anche **come** ci si è arrivati: le clausole verificate, le
clausole mancate, e gli Eco a cui la casata ha partecipato. Le clausole mancate
non sono decorazione: sono quello che l'anno successivo eredita come **conti
rimasti aperti**.

---

## 10bis. Chi vince la saga

Dentro l'anno non c'è nessuna classifica, e non ce n'è mai stata. Ma una
**campagna** un vincitore ce l'ha: ogni Chronicle chiusa somma al seggio il
valore del livello che ha raggiunto, il totale attraversa le ere insieme alla
mappa, e alla fine vince chi ha di più.

| livello | vale |
|---|---|
| nessun gradino | **−1** |
| Minimo | **+1** |
| Vittoria | **+3** |
| **Trionfo** | **+6** |

Tre cose spiegano questi quattro numeri:

- **Esistere vale poco.** Il Minimo è una soglia di sopravvivenza, non un
  obiettivo: una scala che lo pagasse bene farebbe vincere la campagna a chi non
  ha mai rischiato niente.
- **Un anno perso costa.** Chiudere senza nemmeno il Minimo toglie un punto —
  perdere è possibile da quando esiste la regola della porta sbarrata, e in una
  campagna deve pesare.
- **Il Trionfo vale il doppio della Vittoria.** Due anni riusciti non pagano
  quanto uno audace: è così che la scala premia chi si è spinto in alto invece di
  amministrare.

I valori stanno nella Chronicle (`saga_scoring`) e si cambiano senza toccare il
codice. **Omessi, il punteggio non esiste**: una Chronicle può restare un anno che
sta in piedi da solo.

**Il conto segue il seggio, non la persona.** In una saga lunga chi siede cambia —
il Popolo Nahr diventa Il Regno di Nahr, Vaerax diventa Vaerax Ridestato — e il
punteggio prosegue: è la casa a giocare la campagna, non chi la porta in quel
secolo. Una saga vera, cinque anni, coi nomi che cambiano e il conto che no:

```
anno 1   Re Aldric 3 | Popolo Nahr 3 | Vaerax 3 | Lyra 1
anno 2   Il Regno di Nahr 9 | Vaerax 9 | Re Aldric 6 | Lyra 2
anno 3   Il Regno di Nahr 15 | Vaerax 10 | Re Aldric 7 | Lyra 3
anno 4   Il Regno di Nahr 18 | Vaerax Ridestato 13 | Re Aldric 8 | Lyra 4
anno 5   Il Regno di Nahr 24 | Re Aldric 14 | Vaerax Ridestato 14 | Lyra 7
```

**Quello che il contatore ha fatto vedere.** Sommare i risultati non è una regola
neutra: è un **amplificatore**. Finché ogni anno sta in piedi da solo, una casa
debole ha comunque i suoi anni buoni e al tavolo non si nota; appena si somma, la
differenza diventa il risultato. Misurato su dodici saghe per tavolo: nella
Carestia le campagne le vincono tre case su quattro, nell'anno del Sale **la
stessa casa dodici volte su dodici**. Non è il punteggio a essere sbagliato — è
uno squilibrio di contenuto che prima si spalmava. Chi lavora al bilanciamento
guardi lì per primo.

**Una campagna è almeno dieci anni.** Sotto le dieci Chronicle il conto si tiene
ma nessuno ha vinto — una manciata di anni non è una campagna — e il verbale lo
dice a ogni chiusura: *«La campagna non è ancora decisa: 3 anni giocati su 10»*.
Dalla decima in poi dichiara il vincitore. La soglia **apre la porta e non la
chiude**: se il tavolo continua, il conto prosegue e il verdetto si aggiorna.

**E la campagna resta contendibile più a lungo di quanto un punteggio cumulativo
faccia temere.** Misurato su dodici saghe da dieci anni: il testimone passa **1,8
volte** per campagna e l'ultimo sorpasso arriva in media all'**anno 5 su 10** —
metà strada. Solo tre campagne su dodici sono decise entro il terzo anno.

Nell'anno del Sale però quel numero peggiora — ultimo sorpasso all'anno 3,5, e
**sei campagne su dodici decise entro il terzo** — ed è la stessa casa forte di
cui sopra: chi prende la testa presto, lì, non la molla.

---

## 11. La saga: cosa attraversa gli anni

Una Chronicle è un anno. Una **saga** è una catena di Chronicle separate da un
salto che può essere di 1 anno o di 200. È qui che il gioco diventa una storia
lunga invece di una partita.

**Il principio: l'identificatore è il seggio, non la persona.** `ENT_ALDRIC` è
*la casa che tiene Eredan*; chi è seduto su quella sedia è stato del mondo, e
cambia quando passa abbastanza tempo.

Tre cose attraversano il salto, ognuna con la sua condizione:

| cosa | come passa |
|---|---|
| **La mappa** | **sempre**. Controllo, tag, strutture, cicatrici. Il mondo non riparte. Unica eccezione: una Regione tenuta senza nessuno dentro torna a nessuno |
| **I rapporti** | **ma il tempo li smussa**: su un salto lungo ogni relazione si muove di un passo verso NEUTRALE. Un odio sopravvive a chi lo provava, ma non per sempre e non intatto |
| **Il Destino** | **solo di chi ha fallito**. Una casata che ha ottenuto quello che voleva ne vuole un altro; una che non ce l'ha fatta ci riprova. Dopo **tre** ere a mani vuote, l'erede smette di giurare su un'ambizione che ha visto fallire |

**Le incarnazioni: la casata si trasforma.** Ogni seggio ha una lista di *vite*,
e passa da una all'altra secondo quattro ingressi:

| ingresso | quando scatta |
|---|---|
| `FOUNDING` | la prima, all'inizio di tutto |
| `ON_TAG` | quando un certo segno sta sul mondo: *il popolo che si è insediato diventa regno quando il suo segno è sulla mappa, non quando finisce una lista* |
| `LINE_EXHAUSTED` | quando la stirpe si esaurisce (dopo ~25 anni di vita per un MORTALE, e finiti i successori scritti) |
| `ON_DEATH` | quando la creatura muore ma il seggio le sopravvive: *Vaerax cade, e nasce il Culto della Montagna* |

Esempi reali di catene di vite:

```
Re Aldric  →  La Reggenza del Granaio  →  La Repubblica della Valle  →  La Corona Restaurata
Popolo Nahr  →  Il Regno di Nahr  |  La Diaspora di Nahr
Lyra  →  L'Accademia delle Misure  →  Il Culto della Misura
Vaerax  →  Vaerax Ridestato  →  Il Culto della Montagna  →  La Leggenda della Montagna
Le Città Libere  →  La Lega delle Sette  |  L'Egemonia di Eredan
```

Ogni vita ha una **persistenza** (MORTALE, COLLETTIVA, ETERNA), un carattere
proprio — *quanto le piace acquisire, muovere, influenzare, forgiare, tramare,
rivendicare* — e spesso una regola speciale tutta sua (§9).

**E le domande cambiano.** Alcuni anni non elencano le proprie Tensioni: le
pescano da una biblioteca in base a **come è finito l'anno prima**. Se qualcuno
ha murato la miniera, l'anno dopo non parla del Risveglio: parla di quello che
il muro ha causato.

---

## 12. L'informazione privata

Quattro cose non stanno mai nel registro pubblico:

1. la **soglia di una Tensione velata** (il valore invece è pubblico);
2. il risultato di uno **TRAMARE** (torna solo a chi l'ha fatto);
3. le **carte in mano**;
4. gli **impegni**, finché non si rivelano tutti insieme.

Ci stanno invece sempre: le **posizioni** dichiarate al Consiglio, le **rotture
di relazione**, e **ogni cambiamento del mondo**. Il gioco tiene segrete le
risorse e pubbliche le scelte — perché le scelte sono la cosa di cui vale la
pena parlare al tavolo.

---

## 13. Come si sta seduti

Il gioco esiste in quattro forme, tutte sullo stesso motore:

| forma | com'è |
|---|---|
| **Nel browser** | si sceglie seggio, anno e mondo; si gioca sul tabellone, e quando si apre un Consiglio la mappa lascia il centro alla plancia della votazione |
| **La stanza sui telefoni** | uno schermo grande fa da **vetrina** (mappa, carte calate, chi ha detto cosa), e ogni giocatore apre la propria **console** sul telefono con le carte in mano e le scelte private |
| **Alla tastiera** | un seggio, o tutti e quattro, in un menu testuale che offre solo le azioni che le regole accettano |
| **In automatico** | quattro *policy* giocano da sole — serve a misurare il gioco, non a giocarlo |

I posti non occupati da persone li gioca un bot. Se un giocatore arriva dopo
l'inizio, trova il proprio seggio già in mano a un bot e ne riprende il posto.

---

## 14. I numeri, tutti insieme

| | |
|---|---|
| Giocatori | **4** |
| Durata di una Chronicle | **1 anno** = 3 Atti × 3 round |
| Azioni per giocatore per round | **2** (18 in tutto l'anno), e ognuna costa **una carta** |
| Carte che la mappa dà a inizio Atto | **2 per gettone** di presenza, pavimento **2**, tetto per Atto **6**, tetto sulla mano **7** |
| Gettoni di presenza | **3** per casata (2 posati all'inizio, 1 in riserva) |
| Limite di mano | **7** Asset |
| Regioni | **6** (3 con un padrone all'inizio, 3 di nessuno) |
| Regioni tenibili senza sforzo | **2** (oltre, si paga Tensione a ogni round) |
| Tensioni in gioco | **4** per anno (su 12 scritte) |
| Soglie | fra **5 e 8** (col sacchetto acceso: la soglia scritta più 1) · una domanda è **matura** (strappabile) a **3** |
| Il calore | **+1** a una Tensione per ogni azione riuscita, dal sacchetto di 9 gettoni mescolati |
| Consigli in un anno | mediana **6**, estremi misurati **2–9** (tavolo misto, 0.1.156) |
| Asset impegnabili | **0–3** (0–2 con una Condizione) |
| Fattore Mondo | 1d6 → **−2 −1 0 0 +1 +2** |
| Soglia di qualifica di una Condizione | **2** |
| Peso di un alleato al Consiglio | **+1** per grado sopra NEUTRALE, tetto **2**, servono **2 carte** impegnate |
| Carte Asset | **132** stampate, **48** tipi, 6 famiglie |
| Carte Narratore | **39**, 5 famiglie drammatiche, 24 funzioni · 2 pescate a testa per Atto |
| Conseguenze scritte | **52** (di cui **14** cambiano il padrone di una Regione) |
| Modelli di Consiglio | **10** |
| Regole dei segni | **52** |
| **Tipi di struttura** | **9**, in **4 famiglie** — 5 con un padrone, 4 di nessuno |
| Destini | **20** scritti, 3 gradini ciascuno — **19 in gioco** dall'apertura, il ventesimo solo in saga |
| Tipi di effetto sul mondo | **25** (23 reversibili, 2 no: creare un Eco e scrivere una Verità) |
| Salto fra due Chronicle | da **1** a **200** anni |
| **Punteggio di saga** | **−1 / +1 / +3 / +6** per nessun gradino / Minimo / Vittoria / Trionfo — solo di campagna, mai dentro l'anno |
| **Durata di una campagna** | almeno **10** Chronicle perché un vincitore sia dichiarato |

**Come finisce un anno, misurato su 100 partite a tavolo misto** (50 partite per
seggio, quattro caratteri diversi):

| gradino | tavolo misto | quattro ottimizzatori |
|---|---|---|
| nessun gradino | **0%** | ~1% |
| Minimo | 44% | 28% |
| Vittoria | 36% | 41% |
| **Trionfo** | **20%** | 30% |

Le due colonne sono la stessa partita giocata da gente diversa, e la differenza
è il dato più interessante del gioco: **quattro ottimizzatori identici arrivano
molto più in alto di quattro caratteri diversi.** Non perché barino — è la
stessa policy — ma perché nessuno di loro spreca un turno. La colonna di
sinistra è quella che somiglia a un tavolo vero.

Nessun seggio resta a zero Trionfi, e nessuno è bloccato su un solo gradino: è
il vincolo che il gioco si è dato ed è quello che tiene onesto il bilanciamento.

---

## 15. Come si gioca bene, misurato

Le sezioni precedenti dicono **cosa** si può fare. Questa dice **cosa conviene**,
e non è opinione: sono i numeri delle stesse 100 partite del §14. Vale
l'avvertenza in fondo alla sezione, che è importante quanto i numeri.

### I quattro modi di stare al tavolo

Il gioco misura sé stesso con quattro caratteri che sono **la stessa policy con
una cosa diversa** — nessuno bara, nessuno sa niente che un giocatore non
saprebbe. Su 100 partite, ognuno seduto a turno in ogni seggio:

| carattere | come gioca | Minimo | Vittoria | Trionfo | supera il Minimo |
|---|---|---|---|---|---|
| **prudente** | non alza la voce, si oppone di rado, tiene le carte in mano | 60 | 29 | 11 | **40%** |
| **distratto** | un giro su quattro non fa la mossa migliore | 41 | 39 | 20 | 59% |
| **aggressivo** | blocca tutto quello che non lo aiuta, impegna tutto | 38 | 40 | 22 | 62% |
| **ostinato** | gioca per il Trionfo dal primo round, non per il gradino vicino | 37 | 36 | **27** | **63%** |

**Il risultato più netto del gioco è che la prudenza è la strategia peggiore**, e
di venti punti. Il prudente finisce l'anno con una mano bellissima e niente di
deciso — e le carte a fine anno non valgono niente: vale solo quello che hanno
cambiato.

Il secondo risultato è meno ovvio. L'**ostinato** punta al gradino più alto
invece che al più vicino, e non paga questo rischio da nessuna parte: ha **più
Trionfi di tutti e meno Minimi di tutti**. Giocare basso non protegge. Un
Destino si insegue intero o non si insegue.

### Nove cose che i numeri dicono

**1. Prepararsi batte reagire.** Un Asset vale la sua forza piena (fino a 3) solo
se la famiglia è rilevante per la Tensione in discussione, altrimenti vale **1**.
La stessa carta vale 3 al Consiglio giusto e 1 a quello sbagliato: guardare quale
Tensione sta per maturare e acquisire *prima* è la leva più economica che c'è.

**2. Opporsi funziona, e non è gratis.** Su 579 Consigli, **256 falliscono**: il
44%. Bloccare quello che non ti serve è efficace — ma chi si oppone e perde non
recupera le carte impegnate, e questa regola esiste apposta perché senza il
blocco era troppo conveniente.

**3. La presenza è la risorsa più scarsa.** Tre gettoni, due già posati. Comandano
tutto quello che *fai*: chi propone al Consiglio, influenzare senza pagare,
pescare due carte invece di una, e **16 clausole di Destino** chiedono di essere
in un posto preciso. Ogni spostamento è una rinuncia altrove.

**4. Non allargarti.** Oltre due Regioni si paga **+1 di Tensione a round** per
ognuna in più. A fine anno il 53% dei seggi ne tiene una e il 32% due: tre è
quasi sempre un errore, e il 12% che non ne tiene nessuna sta perdendo qualcosa
di più grande.

**5. La terra si tiene con la gente *e* con le pietre.** Il controllo non si
prende con un'azione: si conta a ogni fine round come `pedine + valore delle tue
strutture`. Una torre vale 2, un castello 3, una reggia 5. Costruire è l'unico
investimento che sopravvive all'anno — e che sale di grado da solo, se ottieni
il Trionfo.

**6. Rivendicare, così com'è, è una trappola.** Su 80 partite ne sono state
aperte **128** e usate **17**: centoundici muoiono in mano. Servono due Asset
AUTORITÀ in round diversi, la Tensione già matura, e che nessun altro abbia già
strappato il Consiglio. Vale la pena solo se il Consiglio che ti prendi è
decisivo per il tuo Destino.

**7. Negoziare a vuoto è peggio che tacere.** Una Condizione qualifica solo se ci
metti **almeno 2 carte**: sotto quella soglia non allega niente e non sposta
niente, e le carte sono spese lo stesso.

**8. Un'alleanza rende solo se la paghi.** Un alleato che sostiene il proponente
vale +1 (+2 se VINCOLATO) **ma solo se mette almeno 2 carte sul tavolo**. E si
sale di un gradino spendendo un'Occasione *e* una carta LEGAMI: allearsi è il
turno che non hai usato per altro. Scendere invece è gratis e unilaterale — il
che rende la rottura sempre disponibile, e per questo credibile.

**9. L'errore più costoso è spegnersi il Destino da soli.** È successo in una
partita vera — un giocatore ha spostato l'ultimo gettone via dalle Montagne
Rosse nell'ultimo round e ha chiuso a NONE una cronaca che stava vincendo — ed è
successo **anche nei dati**: un Destino chiedeva al Minimo di presidiare un posto
e alla Vittoria di essere altrove, con un gettone di troppo
([D-177](DECISIONS.md#d-177)). Prima di ogni mossa dell'ultimo Atto, rileggersi
il **proprio Minimo**: l'app avverte, il tavolo fisico no.

### Quello che questi numeri non sanno

**Vengono tutti da bot che giocano contro bot.** I bot giocano bene, ma **non
tradiscono, non mentono, non fanno promesse che non intendono mantenere e non
cambiano idea per dispetto**. Dalla 0.1.140 un bot si fida di chi lo ha sostenuto
finora — quindi *può* essere ingannato — ma nessuno lo inganna.

Quindi tutto quello che sta qui sopra è solido sulla parte meccanica e **muto su
metà del gioco**: la trattativa prima del voto, la promessa che compra un
sostegno, il conto che si salda tre Consigli dopo. Le posizioni si dichiarano in
pubblico *prima* di impegnare le carte al buio: quella finestra è fatta apposta
perché ci si parli, e nessuna misura in questo repository la vede.

---

## 16. Note per chi disegna l'infografica

**La cosa più importante da far capire, se ne passa una sola:** questo non è un
gioco dove si conquista una mappa. È un gioco dove **quattro casate discutono**,
e la mappa è il verbale di quelle discussioni. Le azioni sono la preparazione;
il Consiglio è il gioco.

### Cinque riquadri che meritano di stare grandi

1. **La piramide del tempo** (§1) — Saga › Chronicle › Atto › Round › Azione,
   con il ciclo AZIONI → DERIVA → SOGLIA che gira dentro il round.
2. **Il turno in una riga** — le sette azioni come sette icone su una barra, con
   sopra scritto **«2 per round, 18 in tutto l'anno»**. È il numero che fa capire
   quanto costa ogni scelta.
3. **Il Consiglio A→K** (§6) — meglio come **binario orizzontale** con undici
   fermate, colorando in modo diverso i passi *pubblici* e quello *segreto*
   (E. Impegno). Il contrasto pubblico/segreto è la firma visiva del gioco.
4. **La formula** (§6.2) — `S + C − O + W = MARGINE` con sotto la fascia dei
   quattro esiti. È l'unico numero che un giocatore deve tenere a mente.
5. **Il Destino a tre gradini** (§10) — una scala, non un podio: si sale la
   propria, non si corre contro gli altri. E il gradino alto è **una spina più
   una scelta**, non una lista: disegnarlo come «questa cosa qui, *e* tre di
   queste cinque» rende l'idea meglio di qualsiasi spiegazione.

### Due mappe utili

- il **grafo delle 6 Regioni** (§3) con le adiacenze — è piccolo e si disegna
  bene, e **una delle linee può spezzarsi** (il passo che frana): vale la pena
  disegnarne una tratteggiata;
- la **ruota delle Tensioni**, quattro spicchi con il valore corrente e la
  soglia, e le frecce dei collegamenti fra loro (il Ripple): serve a mostrare
  che spegnere una domanda ne accende un'altra.

### Il diagramma che racconta il gioco meglio di una frase

**Come si conta il controllo** (§3). Una Regione vista da vicino, con:

- le **pedine** di due casate diverse, una pila da 3 e una da 1;
- un **castello** disegnato accanto alla pila piccola, con scritto **3**;
- la somma sotto: `3 pedine = 3` contro `1 pedina + castello 3 = 4`;
- e la freccia che dice **chi tiene la Regione**.

Racconta in un colpo che la terra si tiene con la gente *e* con le pietre, e che
un castello vale quanto un esercito ma non più di un esercito più grande.

### L'errore che un'infografica fa da sola

Disegnare la mappa come una mappa di conquista, con quattro colori che si
contendono il territorio. Non è quello: le **pedine** (presenza) sono ciò che dà
potere durante l'anno, il **colore della casella** (controllo) è il risultato di
un conto rifatto a ogni round, e le **strutture** sono un terzo strato che entra
in quel conto e sopravvive alla partita. Vanno disegnati come tre strati
distinti — pedine e strutture sopra, colore sotto — e la legenda deve dire quale
dei tre fa cosa.

### Cosa si può tranquillamente omettere

I nomi propri delle 48 carte Asset, l'elenco delle 52 regole dei segni, i nomi
delle 52 Conseguenze, i dettagli dell'ereditarietà fra Chronicle. Bastano come
etichette («52 regole che i segni sul mondo accendono»).

### Registro e tono

Il gioco è scritto in italiano, con un tono asciutto e concreto — *«Non è ancora
fame. È il calcolo, fatto a voce bassa, di quanto manchi alla fame.»* Niente
fantasy epico: la magia esiste (Vaerax dorme sotto la montagna, il Cristallo si
sveglia) ma è trattata come un problema di governo, non come uno spettacolo. Una
tavolozza sobria, terrosa, da documento d'archivio, sta al gioco meglio di una da
poster fantasy.

**Tre parole da non tradurre in inglese nell'infografica:** Chronicle, Confluence
(il Consiglio), Echo (la carta del Narratore). Sono i termini del progetto.

---

*Documento generato dai dati e dal codice di ECHOES 0.1.149. Le regole vivono
nei file JSON di `godot/data/` e nel motore in `godot/scripts/`: se un numero qui
diverge da lì, ha ragione il codice.*
