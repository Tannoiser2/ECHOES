# Passaggio di consegne — stato al 0.1.150

*Scritto per chi apre una sessione nuova su questo repository. Dice dov'è il
lavoro, cosa regge, cosa no, e quali sono le regole di casa che non vanno
riscoperte da capo.*

---

## 1. Dove sta il lavoro adesso

| | |
|---|---|
| ramo di sviluppo | `claude/echoes-boardgame-dev-cmu444` |
| PR aperta | in bozza, su `main` |
| ultimo commit | 0.1.150 |
| ultimo merge su `main` | `175d58d` — PR #68, 0.1.145–0.1.149 |

La PR #68 è stata mergiata: questo ramo riparte da `main` e raccoglie da 0.1.150
in poi.

## 2. Come si lavora qui — le regole di casa

Queste non sono preferenze: sono state pagate con difetti veri.

1. **Ogni cambiamento si misura su 100 semi prima di restare.**
   `run_playtest.gd --runs=100 --seed=7000`. Il vincolo che non si negozia è
   **0 su 8 seggi bloccati su un solo livello**, a tavolo misto *e* uniforme.
2. **Quello che non si misura si dichiara.** Ogni verbale ha una sezione di cose
   dichiarate. Un numero peggiorato e scritto vale più di un numero nascosto.
3. **Determinismo**: due giri di `tools/run_sims.sh` e `tools/run_export.sh`
   devono dare file identici.
4. **Dopo ogni modifica a `/schema`**: `python3 tools/gen_gd_schema.py`.
   **Se cambiano le etichette dei Destini o i dati**: `python3 tools/build_manifest.py`.
   Il secondo è stato dimenticato tre volte e ogni volta ha fatto rosso la CI.
5. **Verbale in `docs/DECISIONS.md`** (il più recente in cima), `docs/ISSUES.md` e
   `CHANGELOG.md` aggiornati **nello stesso commit**.
6. **GDScript tipizzato, senza `class_name`**: `const X := preload(...)`.
7. **Effect-sourcing**: ogni mutazione del mondo è un Effetto con un inverso. Le
   uniche eccezioni sono i contatori (`confluence_count`, `resolved_count`,
   `voted_together`), e sono deliberate.
8. **Le PR si aprono in bozza.** I commenti su GitHub portano il footer di
   attribuzione.
9. **Il committente parla italiano e le risposte vanno in italiano.**

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

Più due documenti: **`docs/MECCANICA.md`** — riportato a **0.1.149**, ed è il
testo da dare a chi disegna l'infografica *e* a chi vuole sapere come si gioca
bene (§15) — e **`docs/SAGA_NAHR.md`**, dieci anni giocati e raccontati.

**Le misure di adesso** (playtest 100 semi, tavolo misto):

```
FAIL 248 · SUCC 78 · SUCC 99 · DECI 154 · mediana 6
0 su 8 bloccati (misto e uniforme) · nessun seggio a NONE · nessuno a zero Trionfi
suite 355 test / 6490 asserzioni
```

## 4. Le due cose che vanno guardate per prime

### a) I Consigli falliti sono a 248

Il trend: **185 → 207 → 191 → 203 → 206 → 246 → 248 → 256 → 248**. Il massimo
storico è stato 256, e in 0.1.150 il numero è **tornato indietro per la prima
volta**: una casa che non arriva più al Trionfo per inerzia propone e si oppone
meno a lungo.

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
- **ISSUES 46** (ridotta in 0.1.150, non chiusa) — il Sale era troppo forte
  perché **tre clausole su cinque erano fatti del mondo**, non cose che facesse.
  Corretti i suoi due Destini: campagne sue da **12/12 a 9/12**, supera il Minimo
  dal 68% al **54%** (le altre 33–34%), ultimo cambio di testa dall'anno 3,5 al
  **5,5** su 10. Resta sopra il criterio (9 su 12 è il 75%), e le due cose da
  guardare — mai misurate come cause — sono i **Trionfi nelle saghe** (Sale 25,
  Libere 19, Vetro 11, Cenere 8) e il fatto che il **Minimo delle quattro case
  non costa uguale**.
- **La palude** — l'unica cosa fuori dal catalogo delle strutture. Chiede slot di
  presenza variabili per Regione: **motore, non contenuto**.

**Motore** — lavoro grosso, da decidere prima di intraprendere:

- **0.4** il modello narrativo locale (la Proposition torna a testo libero)
- **0.6** il tavolo sullo schermo grande e le console in tasca (ISSUES 27). La
  metà difficile è fatta: tutto il codice disegna già *per spettatore*.
- **0.5** computer vision sui marker · **1.0** la campagna Legacy

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
