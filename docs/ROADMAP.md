# ECHOES — Roadmap

---

## 0.0 — Core Headless ✅ completata

Motore di gioco completo e giocabile senza UI. Criteri di accettazione §18.3 tutti
verificati: vedi [TEST_PLAN.md](TEST_PLAN.md) per la mappa criterio → test.

- Schemi JSON come fonte unica + generatore GDScript + drift check in CI
- `EffectApplier` con log, inversi e snapshot
- I sei template di azione, il Drift, la sequenza Confluence A–K, il resolver
  `baseline_v0`, `EchoRecorder`, `DestinyEvaluator`, `SaveManager`
- Contenuto ridotto §18.2 e tre piani di simulazione con esiti diversi
- 64 test, 425 asserzioni, tutto verde headless

---

## 0.1 — Vertical Slice Hotseat ✅ completata

Tutti e sei i punti del §25 e tutte e quattro le voci di chiusura sono chiusi.
Si gioca una Chronicle intera dal browser o dal terminale, su due saghe, si
salva e si riprende, e da oggi si stampa.

Ordine di lavoro (§25, punti 11–16):

11. ✅ Main Board, mappa, Entity View, Action Dialog — 0.1.0 / 0.1.2 (D-039)
12. ✅ `HotseatController` e Confluence Board — 0.0.14 / 0.1.1 (D-037, D-038)
13. ✅ Contenuto completo §19.4 con validazione — 0.1.3, le 48 carte Asset (D-040)
14. ✅ Developer Dashboard — 0.1.16, le sonde dentro la partita (D-054)
15. ✅ `CardView` — 0.1.5, la carta dice cosa fa (D-042) · ✅ Export Preview e
    placeholder d'arte — 0.1.18, i fogli di stampa e il brief (D-056)
16. ✅ Issue list / roadmap GitHub-ready — 0.1.18, [ISSUES.md](ISSUES.md): 13
    voci già scritte come issue, più i due template in `.github/ISSUE_TEMPLATE/`

Il motore è già pronto a riceverli: `ChronicleController` chiede ogni decisione a
un oggetto `decider`, e la UI hotseat sarà semplicemente un decider diverso da
quello scriptato che usa la CLI oggi. Nessuna regola va riscritta.

Da chiudere in 0.1:

- ✅ **salvataggio e ripresa** — 0.1.14. Il punto di ripresa nel motore c'è:
  `run()` riparte dall'Atto e dal round su cui il mondo si trova, e un anno
  interrotto finisce identico a uno mai interrotto (D-052). Verificata anche nel
  browser: giocato, ricaricata la pagina, e la ripresa è lì.
- ✅ `promise_kept` / `promise_broken` — 0.1.14, sul Trionfo della Gilda del Sale.
  Collegarli ha fatto emergere che la policy non aveva mai giocato FORGE (D-051).
- ✅ il set completo dei Destiny a più di 2 condizioni per livello — 16 Destini
  su due saghe, con un controllo al boot che rifiuta una clausola che chiede un
  tag che niente al mondo può scrivere (D-048).
- ✅ **Export Preview e placeholder d'arte** (parte del punto 15) — 0.1.18.
  Venticinque fogli A4 in scala 1:1 con i segni di taglio, il mazzo espanso per
  `deck_copies`, il brief d'arte composto leggendo la ART_BIBLE, e l'anteprima
  dentro l'app dietro F4. Ha anche trovato un buco: le otto chiavi `entity.*`
  non hanno un MASTER PROMPT ([D-056](DECISIONS.md#d-056)).

---

## 0.0.1 — Passo di bilanciamento ✅ completato

Chiusa l'osservazione D-018 con misure, non con intuizioni: un policy decider che
gioca per il proprio Destiny, una sonda su 40 Chronicle, quattro varianti di
regole confrontate, e un cap di 1 INFLUENCE per Entità per round che porta la
mediana a 4 Confluence con nessuna partita fuori dai limiti del §7. Storia
completa in [DECISIONS D-021](DECISIONS.md#d-021).

---

## 0.2 — Bilanciamento ✅ completata (0.1.55)

**La voce con cui questa sezione si apriva è chiusa.** Diceva: «Failure e Success
with Cost non compaiono, 0 e 1 su 154 Confluence misurate». Sulle 244 Confluence
di CHR_01 misurate oggi sono **48 e 38**, e tutte e quattro le bande del §12.3
compaiono in entrambe le saghe. Chiusa dal contenuto, come previsto, senza
toccare la matematica del §A5.

Prima voce in agenda adesso, con i dati raccolti fino alla 0.1.17. Le voci sono
scritte come issue apribili in [ISSUES.md](ISSUES.md):

- ✅ **O-15 — il playtest è stato fatto** (0.1.15, D-053), con quattro caratteri
  diversi su 100 partite contro gli stessi 100 semi giocati da quattro
  ottimizzatori identici. Quattro seggi su otto si sbloccano: quelle clausole non
  erano il problema. **Due no** — Kessa dei Fuochi e Lyra — e sono state
  abbassate nella stessa milestone: i seggi bloccati passano da 2 su 8 a 1 su 8,
  contro i 4 su 8 di un tavolo di ottimizzatori identici.
- **Opporsi non costa abbastanza** — la voce che resta, adesso a metà. Un solo
  giocatore aggressivo su quattro portava i Consigli da 121 a **315 fallimenti su
  603**, e il prudente chiudeva 82/14/4 contro il 29/63/8 dell'aggressivo.
  Provato a metterci un prezzo con una Conseguenza (`+1` sulla domanda quando una
  proposta cade): **misurato, si è bloccato di più, non di meno**, e le Chronicle
  sono uscite sopra il tetto. È la matematica del resolver del §A5, e si è
  affrontata lì.
  - ✅ **prima leva, 0.1.17 ([D-055](DECISIONS.md#d-055))**: una Condition
    qualificata entra nel margine come sostegno. I fallimenti scendono a
    **282 su 596**, il prudente sale a 74/22/4, i DECISIVE passano da 95 a 128 e
    i seggi bloccati vanno da 1 su 8 a **0 su 8**.
  - ✅ **seconda leva, fatta in 0.1.55** ([D-098](DECISIONS.md#d-098)):
    la proposta bocciata non compra quiete (`failure_delta` −2 → −1,
    il gradino 0 respinto coi numeri). Divario aggressivo−prudente
    28 → 26, i NONE del bloccante da 2 a 6, i Consigli recuperati vanno
    al centro del tavolo (distratto 46 → 53). La storia del divario:
    37 → 31 → 28 → 26.
- ✅ I compagni di lista sono chiusi strada facendo: i template aggiuntivi
  non servono, misurato tre volte ([D-093](DECISIONS.md#d-093)); l'Asset
  economy è misurata e sana — nessuna carta morta su 48
  ([D-071](DECISIONS.md#d-071), ISSUES 3); la UX ha avuto le sue passate
  (CardView, cronaca in-app, avvisi sul salvataggio browser).

---

## 0.3 — World Propagation Engine ✅ completata (0.1.44–0.1.47)

Da una Chronicle conclusa esce una Chronicle nuova con domande scelte dalle
conseguenze della prima, e dieci ere si incatenano senza che nessuno scriva
JSON a mano. Le evidence sono diventate dati (`unmet`,
[D-087](DECISIONS.md#d-087)), la pesca legge segni, conti aperti e calore
ereditato ([D-079](DECISIONS.md#d-079), [D-088](DECISIONS.md#d-088)), e il
verbale d'apertura racconta al tavolo domande e mappa
([D-089](DECISIONS.md#d-089), [D-090](DECISIONS.md#d-090)). Chiusa con la
voce 9 di ISSUES e la issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25).

## 0.4 — Local Narrative Model adapter

Mock + backend locale opzionale. È il momento in cui la Proposition può tornare a
testo libero ([A9](DECISIONS.md)): il modello racconta un esito che resta
determinato dalle regole.

## 0.5 — Prototipo computer vision QR/fiducial

I `marker_id` entreranno nel modello dati insieme al prototipo che li
legge: erano nello schema dalla 0.0, nessun codice li ha mai letti, e un
campo che nessuno legge è un campo che nessuno mantiene — tolti in 0.1.48
(ISSUES 11, [D-091](DECISIONS.md#d-091)). I valori erano meccanici
(`MK_<id>`): si rigenerano in un minuto quando serviranno.

## 0.6 — Print-and-play e sincronizzazione tavolo fisico/digitale

## 1.0 — Campagna multi-Chronicle, Timeline, Legacy, Chronicle Book — quasi tutta

Il motore della campagna esiste ed è misurato su migliaia di ere
(`run_saga`, `run_era_probe`); **la saga si gioca dall'app** — a fine
anno l'era successiva si offre, con eredità e verbale d'apertura
([D-095](DECISIONS.md#d-095)) — e ha il suo **libro con la Timeline**
dei secoli in apertura ([D-096](DECISIONS.md#d-096)). Restano la
campagna Legacy vera e propria e le rifiniture d'autore.
