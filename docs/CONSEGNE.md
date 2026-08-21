# Passaggio di consegne — stato al 0.1.161

*Scritto per chi apre una sessione nuova su questo repository. Dice dov'è il
lavoro, cosa regge, cosa no, e quali sono le regole di casa che non vanno
riscoperte da capo.*

---

## 1. Dove sta il lavoro adesso

| | |
|---|---|
| ramo di sviluppo | `claude/echoes-boardgame-dev-cmu444` |
| PR aperta | nessuna |
| ultimo commit su `main` | 0.1.159 |
| sul ramo | 0.1.160 — il calore lo pescano i giocatori |
| ultimo merge su `main` | `a474741` — PR #71, 0.1.158–0.1.159 |

La PR #70 è stata mergiata: **il gioco a sole carte è su `main`**. Questo ramo
riparte da lì, ed è vuoto — il prossimo lavoro apre una PR nuova.

## 2. Come si lavora qui — le regole di casa

Queste non sono preferenze: sono state pagate con difetti veri.

1. **Ogni cambiamento si misura su 100 semi prima di restare.**
   `run_playtest.gd --runs=100 --seed=7000`. Il vincolo che non si negozia è
   **0 su 8 seggi bloccati su un solo livello**, a tavolo misto *e* uniforme.
2. **Quello che non si misura si dichiara.** Ogni verbale ha una sezione di cose
   dichiarate. Un numero peggiorato e scritto vale più di un numero nascosto.
3. **Determinismo**: due giri di `tools/run_sims.sh` e `tools/run_export.sh`
   devono dare file identici.
4. **Dei comandi del cancello si guarda l'exit code, non l'output.**
   `tools/run_sims.sh` e `tools/run_export.sh` *scrivono* i loro file anche
   quando falliscono: guardare se i file cambiano non dice se il comando è
   andato. Costato una CI rossa in 0.1.156.
5. **Dopo ogni modifica a `/schema`**: `python3 tools/gen_gd_schema.py`.
   **Se cambiano le etichette dei Destini o i dati**: `python3 tools/build_manifest.py`.
   Il secondo è stato dimenticato tre volte e ogni volta ha fatto rosso la CI.
6. **Verbale in `docs/DECISIONS.md`** (il più recente in cima), `docs/ISSUES.md` e
   `CHANGELOG.md` aggiornati **nello stesso commit**.
7. **GDScript tipizzato, senza `class_name`**: `const X := preload(...)`.
8. **La riga stampata sulla carta deve dire il vero sulla mappa**: `acquisition_rule` nomina le Regioni da cui si pesca quella famiglia, e una guardia in `validate_data.py` lo verifica (0.1.156). Quaranta carte su quarantotto hanno mentito per un giorno intero senza che nessun test lo notasse.
9. **Effect-sourcing**: ogni mutazione del mondo è un Effetto con un inverso. Le
   uniche eccezioni sono i contatori (`confluence_count`, `resolved_count`,
   `voted_together`), e sono deliberate.
10. **Le PR si aprono in bozza.** I commenti su GitHub portano il footer di
   attribuzione.
11. **Il committente parla italiano e le risposte vanno in italiano.**

### Il binario di prova

```bash
export GODOT=<percorso>/Godot_v4.7.1-stable_linux.x86_64
# tutti i comandi dalla radice del repo, non da godot/
$GODOT --headless --path godot --script res://tests/run_tests.gd
$GODOT --headless --path godot --script res://tests/run_tests.gd -- --filter=nome
```

Asserzioni disponibili: `assert_true`, `assert_false`, `assert_eq`, `assert_ne`.
**Non** `assert_equal`.

### Le sonde

| sonda | risponde a |
|---|---|
| `run_playtest.gd` | come finisce un anno, per seggio e per carattere — **è il cancello** |
| `run_rung_probe.gd` | quale clausola non si avvera mai, la mappa, le pietre, i Consigli per saga, e **se convenga proporre** (0.1.151) |
| `run_clause_probe.gd` | quanto costa una clausola **prima** di scriverla (banco in `tools/clause_candidates.json`) |
| `run_era_probe.gd` | cosa fa il tempo a una saga, chi siede e dove arriva, **quale clausola manca quando un anno si perde** (0.1.145), e **quanto resta viva una campagna** (0.1.149: cambi di testa, anno dell'ultimo sorpasso) |
| `run_saga.gd` | racconta una saga anno per anno |
| `run_token_probe.gd` | **il preventivo di ISSUES 49**: quanti segnalini coperti scenderebbero se il calore lo pescassero i giocatori, quanti Consigli darebbe ogni innesco, e **se sarebbe un altro gioco** |
| `run_hand_probe.gd` | **il preventivo di ISSUES 47** — da 0.1.154 anche **dove stanno davvero le pedine** e **il fabbisogno**: quante carte servono per giocare come adesso, quanto si stringe il gioco, e **la mano vera** col rubinetto acceso |
| `tools/dead_code.py` · `tools/validate_data.py` | codice irraggiungibile · dati contro schemi, **e i Destini che si combattono da soli** (D-178: `--self-test` prova che le guardie mordano) |

## 3. Cosa è stato fatto nelle ultime sessioni

**Il filo**: dai Destini che nessuno saliva, alla terra che si costruisce, a come
si vince, a come i bot si alleano — e infine a un Destino che si combatteva da
solo.

| | |
|---|---|
| **0.1.139–140** | i bot stringono alleanze **se conviene** — e decidono con chi guardando **come si è votato**, non leggendo il Destino altrui |
| **0.1.141** | il pool dei Destini è **acceso**: venti Destini in gioco invece di otto |
| **0.1.142** | il sigillo che riscriveva la storia del sito antico; il grado alto è materia di saga; il divario fra le due saghe non c'era |
| **0.1.143** | tre Conseguenze costruiscono un oggetto invece di scrivere un segno |
| **0.1.144** | le istituzioni **non** governano diversamente dalle persone: l'ipotesi di ISSUES 35 era falsa |
| **0.1.145** | la Cenere non era debole: il suo Destino le chiedeva due cose che con tre gettoni non stanno insieme (ISSUES 45) |
| **0.1.146** | quel difetto si vedeva **senza giocare**: due guardie nella CI, e la seconda ha trovato subito un errore introdotto il giorno prima |
| **0.1.147** | `MECCANICA.md` riportato al vero (cinque numeri falsi, uno che si contraddiceva) e la sezione **«come si gioca bene»**, misurata |
| **0.1.148** | **il vincitore della saga**, voluto dal committente — e il contatore ha rivelato che nella saga del Sale la campagna la vince sempre la stessa casa (ISSUES 46) |
| **0.1.149** | una campagna è **almeno dieci anni**, deciso dal committente — e con la soglia si misura quanto resta viva: ultimo sorpasso all'anno 5 su 10 nella Carestia, 3,5 nel Sale |
| **0.1.150** | **il Sale non vinceva: gli succedeva di vincere** — tre clausole su cinque erano fatti del mondo. Campagne sue da 12/12 a 9/12 (ISSUES 46 ridotta, non chiusa) |
| **0.1.151** | il **preventivo** della riprogettazione voluta dal committente (ISSUES 47): il gioco si stringerebbe al 36-40% e lo scarto fra i seggi raddoppia ogni atto |
| **0.1.152** | **il telaio delle azioni sulle carte** (ISSUES 47 fase 1): `card_action`, `PLAY_CARD` e l'interruttore. Zero carte convertite, playtest identico |
| **0.1.153** | **il rubinetto** (ISSUES 47 fase 2): la mano viene dalla mappa — e il freno che credevo giusto era quello sbagliato, il tetto va sulla **mano** |
| **0.1.154** | **la mappa che distribuisce** (ISSUES 47 fase 3): due Regioni per famiglia, il fabbisogno misurato (11,80 carte l'anno) — e la Strada dei Mercanti è morta (ISSUES 48) |
| **0.1.155** | **il velo copre la soglia, non il numero**: l'asimmetria che il tavolo fisico non poteva riprodurre — e due viste che stampavano la soglia vera |
| **0.1.156** | **le quarantotto carte parlano** (ISSUES 47 fase 4): le azioni passano sulla mano e **l'interruttore si accende**. La divergenza è chiusa: scarto 1,58 contro 4,90 |
| **0.1.157** | un piano scriptato **dichiara la propria economia** — e la lezione: dei comandi del cancello si guarda l'**exit code** |

Più due documenti: **`docs/MECCANICA.md`** — riportato a **0.1.149**, ed è il
testo da dare a chi disegna l'infografica *e* a chi vuole sapere come si gioca
bene (§15) — e **`docs/SAGA_NAHR.md`**, dieci anni giocati e raccontati.

**Le misure di adesso** (playtest 100 semi, tavolo misto, col gioco a carte
acceso in CHR_01 e CHR_02):

```
FAIL 235 · SUCC 99 · SUCC 122 · DECI 121 · mediana 6
0 su 8 bloccati (misto e uniforme) · nessun seggio a NONE · nessuno a zero Trionfi
suite 379 test / 6760 asserzioni
```

## 4. Le due cose che vanno guardate per prime

### a) I Consigli falliti sono a 249

Il trend: **185 → 207 → 191 → 203 → 206 → 246 → 248 → 256 → 248 → 241 → 239 → 235 → 249**.
Il massimo storico è stato 256, e in 0.1.150 il numero è **tornato indietro per
la prima volta**: una casa che non arriva più al Trionfo per inerzia propone e si
oppone meno a lungo. Da 0.1.154 scende ancora, e la causa è nota e dichiarata:
la mappa ridistribuita rende le mani più varie, quindi più spesso a un Consiglio
manca la famiglia che quel Consiglio premia — l'anno si è fatto più quieto
(Consigli medi da 5,79 a 5,43).

Il salto grosso (206 → 246) è **dichiarato e ha una causa nota**: accendere il
pool mette al tavolo undici ambizioni in più, e le proposte si oppongono fra loro
molto più spesso. Il tasso di successo sta intorno al 57%.

**Si spegne in una riga**, se il committente decide che è troppo:
`world_state_factory.gd`, `_deal_destiny`, togliere il ripiego sulla lista
dell'Entità. Ma prima di toccarlo, chiedere: è una decisione sua.

### b) `ACT_CLAIM` muore in mano tre volte su quattro

128 rivendicazioni aperte, 17 forzate, **111 morte** su 80 Chronicle. Il punto di
rottura è **§10 del regolamento** — il Claim deve essere posato in un round
precedente — non un difetto del codice. Cambiarlo è cambiare il regolamento:
**non farlo senza chiedere**. La strada più piccola è scritta in ISSUES 37.

## 5. Cosa resta aperto

**Contenuto e regole** — si possono fare, con la disciplina di sopra:

- **ISSUES 37** (metà) — la catena di `ACT_CLAIM`. Serve una decisione su §10.
- **ISSUES 36** — linee sempre diverse: il generatore di ruoli e Destini. Non
  toccata in questa sessione.
- **Le 14 Conseguenze che assegnano il controllo** direttamente. Deliberatamente
  non riscritte: la misura dice che funzionano. Sono l'ultimo posto dove il
  padrone si *scrive* invece di contarsi.
- **ISSUES 45** (metà) — la linea della Cenere/Fuochi. La metà strutturale è
  chiusa in 0.1.145: la casa non era debole, il suo Destino le chiedeva due cose
  che con tre gettoni non stanno insieme. Resta il residuo — i Fuochi al 22%–50%
  contro i Maestri al 33%–83%, e **nessuna clausola pronta** con cui intervenire:
  delle dodici misurate al banco, tutto ciò che la Cenere può fare restando sulla
  montagna esce 0% o 100%.
- **ISSUES 48** — la **Strada dei Mercanti è una Regione morta**: 0,6% delle
  pedine in 60 anni, contro l'11% di Montagne e Terre Nahr. È centrale e ha
  quattro slot, e nessuno ci va. Tre ipotesi scritte lì, e due si provano
  **leggendo i dati**, senza giocare.
- **ISSUES 46** (ridotta in 0.1.150, non chiusa) — il Sale era troppo forte
  perché **tre clausole su cinque erano fatti del mondo**, non cose che facesse.
  Corretti i suoi due Destini: campagne sue da **12/12 a 9/12**, supera il Minimo
  dal 68% al **54%** (le altre 33–34%), ultimo cambio di testa dall'anno 3,5 al
  **5,5** su 10. Resta sopra il criterio (9 su 12 è il 75%), e le due cose da
  guardare — mai misurate come cause — sono i **Trionfi nelle saghe** (Sale 25,
  Libere 19, Vetro 11, Cenere 8) e il fatto che il **Minimo delle quattro case
  non costa uguale**.
- **ISSUES 47 — chiusa nei suoi tre criteri** (0.1.156, D-188). Le carte sono
  l'unica moneta in CHR_01 e CHR_02: telaio (D-184), rubinetto (D-185), mappa e
  fabbisogno (D-186), le 48 azioni e l'interruttore acceso (D-188). Lo scarto fra
  il primo e l'ultimo seggio **non cresce più**: 1,58 all'Atto 3 contro 4,90.
  Restano tre code, e non sono la issue:
  **(a)** CHR_03 gioca ancora il §10 di prima — la sua mappa non è stata
  guardata; **(b)** manca un piano scriptato del gioco a carte; **(c)** il 58%
  delle Occasioni resta muto, 194 volte su 720 perché *la mano non sa dire* ciò
  che il seggio vuole — prima misura, mai tarata.
- **La palude** — l'unica cosa fuori dal catalogo delle strutture. Chiede slot di
  presenza variabili per Regione: **motore, non contenuto**.

**Motore** — lavoro grosso, da decidere prima di intraprendere:

- **0.4** il modello narrativo locale (la Proposition torna a testo libero)
- **0.6** il tavolo sullo schermo grande e le console in tasca (ISSUES 27). La
  metà difficile è fatta: tutto il codice disegna già *per spettatore*.
- **0.5** computer vision sui marker · **1.0** la campagna Legacy

## 5bis. Da dove ripartire, in ordine

Scritto dopo il merge di #70, quando il gioco a sole carte è diventato il gioco.

1. ~~Il 58% delle Occasioni resta muto~~ — **scomposto in 0.1.161** (D-193).
   Dei 720 turni misurati: **235** il cervello non voleva niente, **214** voleva
   qualcosa che la mano non sapeva dire, **271** hanno prodotto qualcosa. La
   causa più grossa era il **modo di TRAMARE fissato sulla carta**: liberato, le
   mute di quella famiglia passano da 56 a 15. Il totale resta al 62% **e non è
   un difetto**: nel gioco di prima succedeva qualcosa nel **18%** delle
   Occasioni, adesso nel **37%**. Quello che è sparito è il riempitivo di
   ACQUISIRE. Resta non misurato quanto costi a una casa che tiene solo Regioni
   di FORZA, dove due carte INFLUENZARE su tre spingono in su.

2. **ISSUES 37 — metà chiusa in 0.1.159** (D-191), su decisione del committente:
   non si prenota una domanda già matura, la si prende in un colpo. Morte in mano
   su CHR_01 **da 78% a 41%**; il criterio chiede sotto il 33%, quindi **resta
   aperta**. Due strade più aggressive sono state respinte coi numeri.
3. **Il mondo del Sale** — CHR_03 gioca ancora il §10 di prima. Portarcelo vuol
   dire prima guardare la sua mappa come è stata guardata quella della Carestia
   (D-186). Lavoro pulito, nessuna decisione richiesta.
4. **Un piano scriptato del gioco a carte** — i tre esistenti sono storie del
   §10 di prima e lo dichiarano nel dato. Il gioco nuovo non ha una storia
   raccontata: è provato dal cancello e dai test.
5. **ISSUES 49 — le Tensioni come mucchi di segnalini coperti**, voluta dal
   committente. **Fase 1 fatta** in 0.1.160 (D-192): il calore lo pescano i
   giocatori, la Deriva a orologio è spenta, le soglie salgono di **1** — e il
   preventivo di D-190 era sbagliato di due volte, corretto lì. **Restano fase 2**
   (coprire i mucchi, e il velo di D-187 diventa inutile) **e fase 3** (l'innesco
   a chiamata con una soglia sola per il tavolo, misurata a **tre gettoni**).
6. **Le due domande del committente ancora aperte sulle Tensioni**: che nella
   prima partita non siano sempre le stesse quattro, e che partano tutte da
   **0**. La seconda non è gratis — con nove gettoni di Deriva su quattro
   domande, partire da zero obbliga a rifare le soglie.

## 6. La cosa che non si risolve misurando

**Niente di tutto questo è mai stato giocato da quattro persone.**

Ogni numero in questo repository viene da bot che giocano contro bot. I bot
giocano bene, ma **non tradiscono, non mentono, non fanno promesse che non
intendono mantenere e non cambiano idea per dispetto**. Le clausole sociali sono
misurate e reggono; il tradimento no, perché nessun bot ne è capace.

Da 0.1.140 un bot si fida di chi lo ha aiutato finora — quindi *può* essere
ingannato. Ma nessuno lo inganna.

I nove difetti più grossi trovati in questo progetto li ha trovati il committente
**giocando**, non le sonde. Se una sessione nuova deve dare un consiglio solo:
**una serata, quattro persone, e si torna con altri nove.**

---

*Aggiornare questo documento quando lo stato cambia in modo che un altro
dovrebbe saperlo. Non è un archivio: è quello che si dice a chi si siede adesso.*
