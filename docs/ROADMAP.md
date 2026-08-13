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

## 0.1 — Vertical Slice Hotseat ⟵ prossima

**Non iniziare prima di aver accettato la 0.0.**

Ordine di lavoro (§25, punti 11–16):

11. ✅ Main Board, mappa, Entity View, Action Dialog — 0.1.0 / 0.1.2 (D-039)
12. ✅ `HotseatController` e Confluence Board — 0.0.14 / 0.1.1 (D-037, D-038)
13. ✅ Contenuto completo §19.4 con validazione — 0.1.3, le 48 carte Asset (D-040)
14. Developer Dashboard
15. ✅ `CardView` — 0.1.5, la carta dice cosa fa (D-042) · Export Preview e
    placeholder migliorati restano
16. Issue list / roadmap GitHub-ready finale

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
- **Developer Dashboard** (punto 14) — non fatto.
- **Export Preview e placeholder d'arte migliorati** (parte del punto 15) — non
  fatti.

---

## 0.0.1 — Passo di bilanciamento ✅ completato

Chiusa l'osservazione D-018 con misure, non con intuizioni: un policy decider che
gioca per il proprio Destiny, una sonda su 40 Chronicle, quattro varianti di
regole confrontate, e un cap di 1 INFLUENCE per Entità per round che porta la
mediana a 4 Confluence con nessuna partita fuori dai limiti del §7. Storia
completa in [DECISIONS D-021](DECISIONS.md#d-021).

---

## 0.2 — Bilanciamento

**La voce con cui questa sezione si apriva è chiusa.** Diceva: «Failure e Success
with Cost non compaiono, 0 e 1 su 154 Confluence misurate». Sulle 244 Confluence
di CHR_01 misurate oggi sono **48 e 38**, e tutte e quattro le bande del §12.3
compaiono in entrambe le saghe. Chiusa dal contenuto, come previsto, senza
toccare la matematica del §A5.

Prima voce in agenda adesso, con i dati raccolti fino alla 0.1.14:

- ✅ **O-15 — il playtest è stato fatto** (0.1.15, D-053), con quattro caratteri
  diversi su 100 partite contro gli stessi 100 semi giocati da quattro
  ottimizzatori identici. Quattro seggi su otto si sbloccano: quelle clausole non
  erano il problema. **Due no** — Kessa dei Fuochi e Lyra — e sono state
  abbassate nella stessa milestone: i seggi bloccati passano da 2 su 8 a 1 su 8,
  contro i 4 su 8 di un tavolo di ottimizzatori identici.
- **Opporsi non costa abbastanza** — la voce che resta. Un solo giocatore
  aggressivo su quattro porta i Consigli da 121 a **315 fallimenti su 603**, e il
  prudente chiude 82/14/4 contro il 29/63/8 dell'aggressivo. Provato a metterci
  un prezzo con una Conseguenza (`+1` sulla domanda quando una proposta cade):
  **misurato, si è bloccato di più, non di meno**, e le Chronicle sono uscite
  sopra il tetto. È la matematica del resolver del §A5, e va affrontata lì.
- Insieme a: 3–5 template di Confluence aggiuntivi, Asset economy e UX.

---

## 0.3 — World Propagation Engine

Propagazione delle conseguenze e generazione strutturata della Chronicle II. Il
`destiny_results.evidence` già registra *come* ogni obiettivo è stato raggiunto,
proprio per questo passaggio.

## 0.4 — Local Narrative Model adapter

Mock + backend locale opzionale. È il momento in cui la Proposition può tornare a
testo libero ([A9](DECISIONS.md)): il modello racconta un esito che resta
determinato dalle regole.

## 0.5 — Prototipo computer vision QR/fiducial

I `marker_id` sono già nel modello dati e non usati da nessun codice.

## 0.6 — Print-and-play e sincronizzazione tavolo fisico/digitale

## 1.0 — Campagna multi-Chronicle, Timeline, Legacy, Chronicle Book
