# ECHOES — la meccanica di gioco, per intero

**A cosa serve questo documento.** È una spiegazione completa e autosufficiente
di come funziona ECHOES, scritta per essere data in pasto a un modello che deve
produrre **un'infografica**. Non presuppone niente: chi legge non ha mai visto
il gioco. Tutti i numeri qui dentro sono quelli veri, letti dai dati e dal
codice della versione 0.1.116 — non sono esempi inventati.

In fondo c'è una sezione **«Note per chi disegna»** con i suggerimenti su cosa
merita un riquadro, cosa merita una freccia e cosa si può omettere.

---

## 0. In una frase

> ECHOES è un boardgame narrativo-strategico per **4 giocatori**, in cui quattro
> casate attraversano **un anno di crisi**: nessuno vince prendendo punti —
> ognuno insegue un **Destino** privato, e le decisioni si prendono in
> **Consigli** dove si vota una proposta e si impegnano carte in segreto. Quello
> che il Consiglio decide resta scritto sul mondo, e il mondo passa alla
> partita successiva.

Le tre idee che lo distinguono da un gioco di conquista:

| idea | cosa vuol dire |
|---|---|
| **Nessun punteggio** | Non c'è un vincitore unico. Ogni casata ha un Destino a tre gradini e li raggiunge o no per conto proprio. Più giocatori possono vincere; tutti possono fallire. |
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
| **Asset** | una carta in mano: uomini, titoli, gente, sapere, ricchezza, legami | si pesca con ACQUISIRE, si spende impegnandola al Consiglio |
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
| **Eredan** | città | 4 | Valle Verde, Strada dei Mercanti | AUTORITÀ, RICCHEZZA |
| **Valle Verde** | valle | 4 | Eredan, Terre Nahr, Strada dei Mercanti | GENTE, RICCHEZZA |
| **Terre Nahr** | steppa | 4 | Valle Verde, Montagne Rosse, Strada dei Mercanti | GENTE, LEGAMI |
| **Montagne Rosse** | montagna | **3** | Terre Nahr, Miniere Antiche | FORZA, LEGAMI |
| **Miniere Antiche** | sottosuolo | 4 | Montagne Rosse, Strada dei Mercanti | SAPERE, RICCHEZZA |
| **Strada dei Mercanti** | strada | 4 | Eredan, Valle Verde, Terre Nahr, Miniere Antiche | RICCHEZZA, LEGAMI |

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
conta.**

**Che cosa comanda la presenza** — cioè: tutto quello che *fai* durante l'anno:

| | |
|---|---|
| **chi propone al Consiglio** | chi ha **più presenza** nelle Regioni del dominio. Il controllo non entra nella scelta |
| **INFLUENZARE gratis** | serve presenza in una Regione taggata col dominio di quella Tensione, altrimenti paghi una carta |
| **ACQUISIRE potenziato** | presenza in una Regione che elenca quella famiglia → peschi 2 e ne tieni 1 |
| **dove puoi MUOVERE** | solo verso Regioni adiacenti a una dove sei già |
| **le regole dei segni** | quelle con `scope: REGION` valgono per chi ha presenza lì |
| **le clausole di Destino** | 16 chiedono di **essere** in un posto (`region_presence`) |

**Che cosa comanda il controllo** — tre cose, e due sono costi:

| | |
|---|---|
| **le clausole di Destino** | 14 chiedono di **avere** un posto (`control_count`) |
| **la sovraestensione** | oltre 2 Regioni, **+1 di Tensione a round** per ognuna in più: un costo, non un vantaggio |
| **il passaggio all'anno dopo** | quello che tieni resta tuo — ma solo se ci stai dentro |

E poi due usi che non sono regole: riempie il nome del padrone in un paio di
frasi (`$controller`) e colora la casella sul tabellone.

**Quindi: dentro l'anno, controllare una Regione non dà nessun vantaggio
meccanico.** Non ti fa proporre, non ti fa pescare meglio, non ti fa influenzare
gratis, non vale un punto al Consiglio. È un **titolo**: conta a fine anno, e se
ne accumuli troppi ti costa.

È coerente col tema — questo è un gioco sulla legittimità, e un titolo che non
puoi esercitare è esattamente il problema di un re che non basta. Ma è anche il
motivo per cui la mappa quasi non si muove: a parte i Destini che la chiedono,
**nessuno ha una ragione, dentro l'anno, per andarsi a prendere una Regione**
(vedi [ISSUES 37](ISSUES.md)).

**Non si governa dove non si è.** Fra una Chronicle e la successiva, una Regione
tenuta senza nessun gettone dentro torna a non essere di nessuno.

**I tag della mappa** sono il vocabolario con cui il mondo si segna:
`condition:starving`, `condition:unrest`, `condition:cut_off`,
`structure:granary`, `structure:canal`, `structure:sealed`, `scar:burned`…
Ci sono **45 regole** che leggono questi tag e cambiano il gioco di conseguenza
(vedi §9).

---

## 4. Le Tensioni — le domande dell'anno

Ogni anno il mondo porta **4 Tensioni**: non "problemi da risolvere" ma
**domande aperte**, ciascuna con un numero che dice quanto è calda.

Le quattro dell'anno 812 (Chronicle I, «La Carestia Rossa»):

| Tensione | dominio | parte da | soglia | visibile? | famiglie di Asset che contano |
|---|---|---|---|---|---|
| **La Carestia** | SOPRAVVIVENZA | 3 | 6 | aperta | RICCHEZZA, GENTE, AUTORITÀ |
| **Il Risveglio** | ANTICO | 2 | 6 | **velata** | SAPERE, FORZA, LEGAMI |
| **La Successione** | TERRITORIO | 2 | 6 | aperta | AUTORITÀ, LEGAMI, FORZA |
| **Le Vie Interrotte** | RISORSA | 1 | 5 | **velata** | RICCHEZZA, SAPERE, GENTE |

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

**Velata.** Una Tensione velata non mostra il proprio numero nel registro
pubblico. Sale lo stesso e raggiunge la soglia lo stesso: il mondo reagisce
anche a ciò che il tavolo non ha ancora misurato. Per vedere il numero serve
l'azione TRAMARE — e saperlo è **personale**: scoprirlo non lo rivela agli altri.

**Presagi.** A certe soglie il mondo dice una frase in pubblico, scritta a mano
nei dati, che non rivela mai il numero: *«I granai di Eredan si aprono un giorno
su tre. Nessuno lo ha annunciato: si vede dalle code.»*

**Soglia.** A fine round, le Tensioni che hanno raggiunto la propria soglia
vengono ordinate per valore decrescente: **la prima apre un Consiglio**, le
altre restano in coda per il round dopo. Al massimo un Consiglio per round.

---

## 5. Il turno: le sette azioni

Ogni Opportunità d'Azione compra esattamente una di queste. Costano tutte **1 AO**.

| # | azione | cosa fa |
|---|---|---|
| 1 | **ACQUISIRE** | Pesca 1 Asset dal mazzo di una famiglia a scelta. Con presenza in una Regione che elenca quella famiglia fra le proprie fonti: pesca 2 e ne tieni 1. Limite di mano **7** carte |
| 2 | **MUOVERE** | Aggiungi o sposta 1 gettone di presenza in una Regione **adiacente** a una dove sei già, o in una delle tue Regioni iniziali. Se la Regione è piena, l'azione è rifiutata senza danno |
| 3 | **INFLUENZARE** | Sposta di ±1 una Tensione. Serve **una** fra: presenza in una Regione del dominio di quella Tensione (gratis), oppure scartare 1 Asset di una famiglia rilevante |
| 4 | **FORGIARE** | Sposta di 1 passo una relazione. **Verso l'alto**: serve il consenso dell'altro giocatore e 1 Asset LEGAMI scartato. **Verso il basso**: unilaterale, gratuito, e finisce nel registro pubblico |
| 5 | **TRAMARE** | Uno fra: leggere in privato il valore di una Tensione velata · guardare le prime 2 carte del mazzo Eco · leggere l'informazione privata di una Regione. Il risultato è **privato** |
| 6 | **RIVENDICARE** | **CREATE**: scarta 1 Asset AUTORITÀ e apri una rivendicazione su un dominio di Tensione. **FORCE**: in un round successivo, con quella Tensione a 3 o più, consuma la rivendicazione e scarta un **secondo** AUTORITÀ per **strappare un Consiglio di cui sei tu il proponente** |
| 7 | **CALARE UNA CARTA NARRATORE** | Gioca una delle carte Eco che hai in mano: la sua funzione narrativa diventa un fatto del mondo, i suoi effetti si applicano, e alcune carte **aprono un Consiglio** |

**La scala delle relazioni** (per FORGIARE):

```
NEMICO  ←→  OSTILE  ←→  NEUTRALE  ←→  ALLEATO  ←→  VINCOLATO
   ↑ gratis e unilaterale        ↑ serve consenso + 1 LEGAMI
```

I marchi speciali — PATTO, DEBITO, PROMESSA, VENDETTA, SANGUE — non si mettono
con FORGIARE: arrivano dalle carte e dalle Conseguenze.

---

## 6. Il Consiglio (Confluence) — il cuore del gioco

Quando una Tensione tocca la soglia, il tavolo si ferma e si riunisce. È qui che
il mondo cambia. La sequenza è fissa e ha undici passi, **A → K**.

### 6.1 La sequenza

| passo | cosa succede | pubblico o segreto |
|---|---|---|
| **A. Innesco** | Una Tensione ha toccato la soglia, oppure qualcuno ha forzato con RIVENDICARE, oppure una carta Narratore lo ha aperto | pubblico |
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
assegnano il controllo di una Regione: **14** portano un cambio di padrone. Fra
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

## 9. Il mondo che risponde: le 45 regole dei segni

Ogni tag scritto sulla mappa, su una casata o su una coppia di casate può
**cambiare le regole**. Non sono effetti una tantum: finché il segno c'è, la
regola vale. Le 45 regole si dividono così:

| tipo | quante | esempio |
|---|---|---|
| **COUNCIL_MODIFIER** | 16 | *finché una Regione muore di fame, i Consigli sulla Carestia partono col mondo contro* |
| **DRAW_BIAS** | 10 | *finché il Banco ha chiamato il debito, chi pesca ricchezza guarda due carte e prende la peggiore* |
| **GATE** | 3 | *dove è passata la razzia non si entra, finché qualcuno non toglie il segno* |
| **ACTION_GATE** | 2 | *chi ha presenza in una Regione affamata non stringe alleanze: i patti non si firmano a stomaco vuoto* |
| **RELATION_CAP / FLOOR** | 4 | *dopo un giuramento spezzato, quella coppia non risale sopra OSTILE* — e *il segno SANGUE non lascia scendere sotto NEUTRALE* |
| **STANCE_MODIFIER** | 2 | *quando la Repubblica si oppone con almeno una carta, il suo fronte vale +1* |
| **ACTION_MODIFIER / GRANT / DISCOUNT / RIPPLE** | 5 | *chi sta nella Regione del granaio pesa di più sulla Carestia* |
| **HAND_LIMIT** | 1 | *chi ha presenza in una Regione affamata tiene una carta in meno: la fame consuma* |
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

**Esempio reale — Re Aldric:**

| gradino | etichetta | clausole |
|---|---|---|
| MINIMO | *Il trono regge* | Aldric è ancora sul trono · presenza a Eredan |
| VITTORIA | *Il regno decide* | la corona tiene ancora la sua terra (≥ 1 Regione) · la Carestia non supera 4 |
| TRIONFO | *Un regno che non ha pagato il pane con il sangue* | Eredan non è in rivolta · nessuna questione lasciata aperta · la corona non è stata spezzata · nessuno ha ancora chiesto chi siede dopo |

Il risultato conserva anche **come** ci si è arrivati: le clausole verificate, le
clausole mancate, e gli Eco a cui la casata ha partecipato. Le clausole mancate
non sono decorazione: sono quello che l'anno successivo eredita come **conti
rimasti aperti**.

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

1. il **valore di una Tensione velata**;
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
| Azioni per giocatore per round | **2** (18 in tutto l'anno) |
| Gettoni di presenza | **3** per casata (2 posati all'inizio, 1 in riserva) |
| Limite di mano | **7** Asset |
| Regioni | **6** (3 con un padrone all'inizio, 3 di nessuno) |
| Regioni tenibili senza sforzo | **2** |
| Tensioni in gioco | **4** per anno (su 6 disponibili per mondo) |
| Soglie | fra **4 e 7** |
| Deriva | **+1** a una Tensione ogni round, 9 gettoni mescolati |
| Consigli in un anno | mediana **5–6**, limiti duri 2–8 |
| Asset impegnabili | **0–3** (0–2 con una Condizione) |
| Fattore Mondo | 1d6 → **−2 −1 0 0 +1 +2** |
| Soglia di qualifica di una Condizione | **2** |
| Carte Asset | **132** stampate, **48** tipi, 6 famiglie |
| Carte Narratore | **39**, 5 famiglie drammatiche, 24 funzioni · 2 pescate a testa per Atto |
| Conseguenze scritte | **52** (di cui **14** cambiano il padrone di una Regione) |
| Modelli di Consiglio | **10** |
| Regole dei segni | **45** |
| Destini | **20** scritti, 3 gradini ciascuno |
| Tipi di effetto sul mondo | **22** (20 reversibili, 2 no: creare un Eco e scrivere una Verità) |
| Salto fra due Chronicle | da **1** a **200** anni |

---

## 15. Note per chi disegna l'infografica

**La cosa più importante da far capire, se ne passa una sola:** questo non è un
gioco dove si conquista una mappa. È un gioco dove **quattro casate discutono**,
e la mappa è il verbale di quelle discussioni. Le azioni sono la preparazione;
il Consiglio è il gioco.

**Quattro riquadri che meritano di stare grandi:**

1. **La piramide del tempo** (§1) — Saga › Chronicle › Atto › Round › Azione,
   con il ciclo AZIONI → DERIVA → SOGLIA che gira dentro il round.
2. **Il Consiglio A→K** (§6) — meglio come **binario orizzontale** con undici
   fermate, colorando in modo diverso i passi *pubblici* e quello *segreto*
   (E. Impegno). Il contrasto pubblico/segreto è la firma visiva del gioco.
3. **La formula** (§6.2) — `S + C − O + W = MARGINE` con sotto la fascia dei
   quattro esiti. È l'unico numero che un giocatore deve tenere a mente.
4. **Il Destino a tre gradini** (§10) — una scala, non un podio: si sale la
   propria, non si corre contro gli altri.

**Due mappe utili:**

- il **grafo delle 6 Regioni** (§3) con le adiacenze — è piccolo e si disegna
  bene;
- la **ruota delle Tensioni**, quattro spicchi con il valore corrente e la
  soglia, e le frecce dei collegamenti fra loro (il Ripple): serve a mostrare
  che spegnere una domanda ne accende un'altra.

**Un diagramma che vale la pena fare anche se è di nicchia:** la **catena per
prendere una Regione** (§7), disegnata come cinque anelli in fila. Racconta la
filosofia del gioco meglio di qualsiasi frase.

**L'errore che un'infografica fa da sola** è disegnare la mappa come una mappa di
conquista, con quattro colori che si contendono il territorio. Non è quello: le
**pedine** (presenza) sono ciò che dà potere, e il **colore della casella**
(controllo) è solo un titolo che conta a fine anno. Vanno disegnati come due
strati distinti — pedine sopra, colore sotto — e la legenda deve dire quale dei
due fa cosa (§3).

**Cosa si può tranquillamente omettere** in una prima infografica: i nomi
propri delle 48 carte Asset, l'elenco delle 45 regole dei segni, i nomi delle 52
Conseguenze, e i dettagli dell'ereditarietà fra Chronicle. Bastano come
etichette («45 regole che i segni sul mondo accendono»).

**Registro e tono.** Il gioco è scritto in italiano, con un tono asciutto e
concreto — *«Non è ancora fame. È il calcolo, fatto a voce bassa, di quanto
manchi alla fame.»* Niente fantasy epico: la magia esiste (Vaerax dorme sotto la
montagna, il Cristallo si sveglia) ma è trattata come un problema di governo, non
come uno spettacolo. Una tavolozza sobria, terrosa, da documento d'archivio, sta
al gioco meglio di una da poster fantasy.

---

*Documento generato dai dati e dal codice di ECHOES 0.1.116. Le regole vivono
nei file JSON di `godot/data/` e nel motore in `godot/scripts/`: se un numero qui
diverge da lì, ha ragione il codice.*
