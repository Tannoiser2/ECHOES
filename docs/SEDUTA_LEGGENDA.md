# La seduta sulla Leggenda della Montagna

Il dossier di decisione per la vita che resta dalla seduta sulle vite
([SEDUTA_VITE.md](SEDUTA_VITE.md), decisione C): **la Leggenda della
Montagna**, approvata come direzione («E va bene progettarla in seduta»).
Come per la voce 19: prima lo stato vero dei dati e le misure, poi una
proposta concreta per pezzo, e in fondo le domande secche.

---

## 1. Perché questa vita è diversa da tutte le altre

Le dieci vite scritte finora cambiano *chi* siede: la Leggenda cambia
**cosa vuol dire sedersi**. È il drago che non si è mai alzato — se il
sigillo regge abbastanza a lungo e nessuno lo sveglia, la creatura smette
di essere un corpo e diventa la storia che si racconta di lei. Il seggio
passa a chi custodisce quella storia: **niente pedine sulla mappa**,
niente MOVE, non la si può cacciare — non c'è da dove. Gioca sui Consigli
e sulle leggende.

È l'unica vita che tocca il contratto di base del gioco (un seggio = dei
segnalini su delle Regioni), ed è per questo che si progetta qui e non
si scrive d'ufficio.

---

## 2. Lo stato vero dei dati e delle misure

**Le vite di Vaerax oggi** (`ENT_VAERAX`, ETERNAL):

| # | vita | ingresso | nelle saghe (20 misurate) |
|---|------|----------|---------------------------|
| 0 | Vaerax | FOUNDING | — |
| 1 | Vaerax Ridestato | ON_TAG `crystal_exploited` | siede **20 volte** |
| 2 | Il Culto della Montagna | ON_DEATH (il drago ucciso, D-127) | siede **0 volte** |

Il Ridestato entra praticamente in ogni saga: il Cristallo viene messo a
peso presto e spesso. Il Culto è **condizionale dichiarata** (D-127): la
caccia chiede la Rivelazione compiuta nello stesso anno, e nelle saghe
misurate non è mai stata eleggibile. La Leggenda sarebbe la quarta vita —
e per natura è **rivale del Ridestato**: lei entra se il sigillo regge,
lui se il Cristallo esce. Le due strade si escludono da sole, in ordine
d'autore.

**Il sigillo**: `mine_sealed` è un fatto globale, e sta negli
`enduring_facts` di CHR_02 — **non diventa mai leggenda**, resta letterale
attraverso i secoli (nelle saghe arriva letterale all'ultimo anno 10 volte
su 20). I Destini di Vaerax lo leggono come fatto: toglierlo dai perenni
romperebbe cose che oggi funzionano.

**Il Minimo attuale di Vaerax è di presenza** («Presenza sulle Montagne
Rosse», in tutte e tre le ambizioni del pool): la Leggenda non può
ereditarlo — serve un Destino su misura, ed è la parte da scrivere con più
cura (voce 15: una vita senza NONE possibile è vietata).

**La sonda d'era ora copre anche il tavolo delle città** (già
parametrizzata: `--chronicle=CHR_03 --then=CHR_04`). Prima misura, 20
saghe:

- banda sana: mediana 1049 anni, 16,0 generazioni, 18 nomi;
- NONE per seggio tutti vivi (Cenere 9, Libere 25, Sale 25, Vetro 54 su
  200 anni);
- le vite sedute: Custodi **20/20**, Lega delle Sette **20/20**, Banco
  Nero 19, Frati 17, Inquisizione 3, Compagnia 1 —
- **i Forni Riaccesi 0 e l'Egemonia di Eredan 0.**

Il perché è un ritrovamento di questa preparazione: `scar:open_wound` e
`scar:emptied` le scrive **solo il contenuto di CHR_01** (la Miniera
Aperta, la Valle Sgomberata). Il tavolo delle città ha le Miniere Antiche
e la Valle Verde sulla mappa, ma **nessuna domanda che possa ferirle o
svuotarle**: per D-035 le due vite nuove sono, in saga, contenuto che non
esiste. Nel loro anno singolo i denti funzionano (i test li inchiodano),
ma la porta d'ingresso non viene mai aperta dalla storia.

---

## 3. La proposta, pezzo per pezzo

### 3a. L'ingresso: quando il drago diventa storia

Il tratto del dossier originale: «dopo tre ere con il sigillo intatto e
il Risveglio mai sfondato». Il motore non ha un contatore di ere — e la
Diaspora ha appena mostrato la forma onesta di questi conti: **segni, non
contatori**. Due strade:

1. **Il conto nei segni globali** (pezzo piccolo nuovo): alla successione,
   se `mine_sealed` c'è e il Risveglio non è sfondato, il mondo posa
   `seal_kept` → `seal_kept_twice` → alla terza `mountain_forgotten`, che
   è l'`entry_tag` della Leggenda (con `entry_forbidden_tag`
   `crystal_exploited`: se il Cristallo è mai uscito, il drago è un corpo,
   non una storia). I segni globali si ereditano: il conto attraversa le
   ere, come deve. Se il sigillo cade, i segni si tolgono — il conto
   riparte.
2. **La memoria esistente**: entrare su `legend:mine_sealed` — poetico
   (la Leggenda nasce quando il sigillo stesso è diventato leggenda), ma
   `mine_sealed` è un fatto perenne e la leggenda non nasce mai. Farlo
   sbiadire romperebbe i Destini che lo leggono. **Sconsigliata.**

La raccomandazione è la **1**: un gancio di successione dichiarato, tre
segni leggibili sul pannello, il playtest a anno singolo intatto.

### 3b. Il seggio senza corpo: cosa c'è già, cosa manca

Quasi tutti i pezzi esistono già nel telaio:

| il tratto | il pezzo | stato |
|-----------|----------|-------|
| non muove | ACTION_GATE su MOVE, `when` ENTITY `life:INC_VAERAX_LEGEND` | **c'è** (D-116) |
| non la si caccia | senza presenze non c'è REMOVE_PRESENCE che la trovi | **automatico** |
| i fronti valgono di più dove una leggenda è nel mondo | STANCE_MODIFIER con `when_also` GLOBAL `legend:*` | **c'è** (D-125), da scrivere il dente |
| pesa sui Consigli | COUNCIL_MODIFIER / CONDITION_THRESHOLD | **c'è** |
| il Destino senza presenza | clausole `state_tag_*`, `tension_limit`, `relation_state` | **il vocabolario c'è**, il Destino è da scrivere |
| parte senza segnalini | `presence: []` nella vita | **da verificare**: nessuna vita oggi ha zero presenze, e il setup/la policy vanno provati con un test prima di fidarsi |
| pesa sulla pesca delle domande future | la pesca ascolta i segni (D-079) e le leggende richiamano candidate | **c'è**: il suo potere è *far nascere leggende* (le sue Conseguenze scrivono `legend:` o fatti destinati a sbiadire in leggenda) |

Il pezzo genuinamente nuovo è **il seggio a zero presenze** più il gancio
di successione del conto (3a). Tutto il resto è dati.

### 3c. Il Minimo che non è «sei ancora lì»

Proposta di Destino su misura (da audit come ogni Destino, voce 15):

- **Minimo — «La storia si racconta ancora»**: `entity_alive` e almeno
  una leggenda della montagna nel mondo (`legend:` a tema, o
  `mountain_forgotten` ancora presente). Si perde: se il sigillo viene
  rotto o il Cristallo esce, la storia muore in fatto — e la Leggenda
  con lei (NONE possibile, misurabile).
- **Vittoria — «La montagna decide le domande»**: N Consigli dell'era
  decisi su domande che le sue leggende hanno richiamato.
- **Trionfo — «Nessuno ricorda com'era davvero»**: il Risveglio mai
  sfondato per l'intera era, e una leggenda nuova nata dalla sua voce.

### 3d. La montagna nell'era delle città (il ritrovamento)

Perché Forni ed Egemonia esistano in saga, il tavolo delle città deve
poter ferire la montagna e svuotare la Valle. Proposta minima, senza
domande nuove:

- **la ferita**: `P_DIG_BELOW` («sotto la cella si continui a scavare»)
  già esiste sulla Reliquia — la sua Conseguenza apre anche
  `scar:open_wound` sulle Miniere Antiche. È letteralmente quello che la
  proposta racconta.
- **lo sgombero**: una Conseguenza di costo/fallimento sul mazzo
  dell'Acqua o della Cenere che sgombera la Valle Verde
  (`scar:emptied@REG_VALLE_VERDE` è l'ingresso dell'Egemonia). Da
  scegliere insieme la domanda giusta.

Entrambe misurate coi 100 semi e con la sonda d'era delle città: le due
vite devono *poter* sedere (non zero), e restare rare.

---

## 4. Le domande secche

- **A. L'ingresso della Leggenda**: approvi la strada 1 (il conto nei
  segni globali, `seal_kept` → `mountain_forgotten`)? E tre ere è la
  misura giusta, o ne vuoi due/quattro?
- **B. La montagna delle città**: diamo a `P_DIG_BELOW` la ferita, e
  scegliamo una domanda per lo sgombero della Valle? (Senza questo,
  Forni ed Egemonia restano contenuto dichiarato-condizionale per
  sempre.)
- **C. Il Destino della Leggenda**: la forma di 3c ti va come base da
  scrivere e misurare?
- **D. La priorità**: la Leggenda è l'ultima vita e il pezzo più
  radicale — la facciamo ora, o prima chiudiamo B (che sblocca due vite
  già scritte) e la Leggenda dopo?

---

## 5. Verbale delle risposte

Seduta del 2026-08-18, risposte del committente:

- **A — «va bene»**: l'ingresso è il conto nei segni globali
  (`seal_kept` → `seal_kept_twice` → `mountain_forgotten`), tre ere.
- **B — «sì»**: `P_DIG_BELOW` apre la ferita, e una domanda del mazzo
  delle città prende lo sgombero della Valle.
- **C — «proviamo»**: il Destino su misura di 3c si scrive come base,
  e si misura — se il NONE non è raggiungibile o il Minimo è regalato,
  si torna qui.
- **D — «prima la B»**: si esegue la B (sblocca i Forni e l'Egemonia,
  già scritti), poi la Leggenda.

**La B è eseguita** (0.1.95, [D-132](DECISIONS.md#d-132)): la Roccia che
Cede su `P_DIG_BELOW`, la Valle che si Vuota sul fallimento dell'Acqua.
Misurato: i Forni siedono 5/20, l'Egemonia 11/20, le Custodi 20 → 15,
NONE tutti vivi, banda identica. La manopola, se l'Egemonia sembrasse
troppo frequente: spostare lo sgombero su una proposizione singola.
**Prossimo passo: la Leggenda** (risposte A e C).
