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

11. Main Board, mappa, Entity View, Action Dialog
12. `HotseatController` e Confluence Board
13. Contenuto completo §19.4 con validazione
14. Developer Dashboard
15. `CardView`, Export Preview, placeholder migliorati
16. Issue list / roadmap GitHub-ready finale

Il motore è già pronto a riceverli: `ChronicleController` chiede ogni decisione a
un oggetto `decider`, e la UI hotseat sarà semplicemente un decider diverso da
quello scriptato che usa la CLI oggi. Nessuna regola va riscritta.

Da chiudere in 0.1 e già noto:

- gli overlay `condition:` / `structure:` / `scar:` esistono nei dati ma nessuna
  scena li disegna
- `promise_kept` / `promise_broken` sono implementati ma nessun Destiny di 0.0 li
  usa
- il set completo dei Destiny a più di 2 condizioni per livello

---

## 0.2 — Bilanciamento

Prima voce in agenda, con i dati già raccolti in
[DECISIONS.md](DECISIONS.md#d-018): **INFLUENCE per presenza è gratuito e
ripetibile**, e quattro giocatori con otto AO possono annullare il Drift. Da
valutare: un cap per round e per Tensione, oppure un costo sulla via per presenza.

Insieme a: 3–5 template di Confluence aggiuntivi, Asset economy e UX, e la
verifica dell'attesa §7 di 3–4 Confluence per Chronicle (i tre piani attuali danno
1, 3 e 2 — vedi O-1).

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
