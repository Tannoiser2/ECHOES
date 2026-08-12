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
15. `CardView`, Export Preview, placeholder migliorati
16. Issue list / roadmap GitHub-ready finale

Il motore è già pronto a riceverli: `ChronicleController` chiede ogni decisione a
un oggetto `decider`, e la UI hotseat sarà semplicemente un decider diverso da
quello scriptato che usa la CLI oggi. Nessuna regola va riscritta.

Da chiudere in 0.1 e già noto:

- il `choose_recovery` non viene mai chiesto a chi gioca: su un Consiglio fallito
  chi si era opposto tiene **una carta a scelta** (§12.3) e quella scelta la fa
  ancora la policy, al terminale come nel browser
- una carta non dice cosa fa: `HandView` mostra titolo, famiglia e valore, non
  `on_commit_effects` né la regola di scarto — è il `CardView` del punto 15, e
  con le carte da 3 della 0.1.3 serve davvero
- `promise_kept` / `promise_broken` sono implementati ma nessun Destiny di 0.0 li
  usa
- il set completo dei Destiny a più di 2 condizioni per livello

---

## 0.0.1 — Passo di bilanciamento ✅ completato

Chiusa l'osservazione D-018 con misure, non con intuizioni: un policy decider che
gioca per il proprio Destiny, una sonda su 40 Chronicle, quattro varianti di
regole confrontate, e un cap di 1 INFLUENCE per Entità per round che porta la
mediana a 4 Confluence con nessuna partita fuori dai limiti del §7. Storia
completa in [DECISIONS D-021](DECISIONS.md#d-021).

---

## 0.2 — Bilanciamento

Prima voce in agenda, di nuovo con i dati già raccolti: **Failure e Success with
Cost non compaiono** nel gioco aperto (0 e 1 su 154 Confluence misurate). Due
delle quattro bande di esito sono morte, e la causa sembra il contenuto — troppo
poche Consequence toccano qualcosa a cui i Destiny altrui tengono, quindi
nessuno ha motivo di opporsi. Da rimisurare **dopo** il contenuto completo della
0.1, prima di toccare la matematica del resolver che il §A5 fissa apposta.

Insieme a: 3–5 template di Confluence aggiuntivi, Asset economy e UX.

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
