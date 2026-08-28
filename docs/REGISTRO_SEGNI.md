# ECHOES — il registro dei segni

<!-- FILE GENERATO — si rifa' con `python3 tools/build_sign_registry.py`. -->

Ogni segno che le Conseguenze, le carte Asset e le carte Echo scrivono sul
mondo, e **chi lo legge**.

Un segno ha senso solo se qualcosa se ne accorge: se cambia cosa puoi fare
adesso (una *regola del segno*), se cambia un Consiglio (una *proposta*), se
decide quali domande nascono l'anno dopo (la *pesca delle domande*), se conta
per un *obiettivo* o per un *Destino*, o se attraversa le ere (un *fatto che
dura*). Un segno che nessuno legge non e' una regola: e' colore travestito da
regola.

Le colonne dicono chi scrive, chi cancella e chi legge. «codice» vuol dire che
il segno e' letto **per prefisso** da una regola del motore — `discovery:` per
esempio si conta tutto insieme, e i nomi singoli non compaiono in nessun dato.
Le viste che si limitano a **stampare** un segno sullo schermo non contano come
lettori: disegnare non e' mordere.


**102 segni scritti sul mondo: 89 li legge qualcosa, 13 no.**

**E 1 segni li chiede qualcuno senza che niente li scriva.**

---

## I segni muti

Scritti da qualcosa, letti da niente. Ognuno e' una carta o una
Conseguenza che promette un cambiamento che il gioco non registra.

| segno | chi lo scrive | perche' e' ancora qui |
|---|---|---|
| `account_settled` | Conseguenza | «Il Conto Saldato» chiude un debito e nessuna regola lo sa — 4 volte in 100 anni |
| `burden_shared` | Conseguenza | il peso diviso non alleggerisce niente — 2 volte in 100 anni |
| `condition:guarded` | Conseguenza | la tessera sorvegliata: si vede sul tavolo, e nessuna regola la interroga ancora — candidato numero uno a mordere in Fase B (D-278) |
| `dragon_slain` | Conseguenza | «Il Drago Abbattuto» — e il mondo non se ne accorge. Non esce mai in 100 anni: la Conseguenza non e' mai stata scelta (ISSUES 56) |
| `hard_bargain` | Conseguenza | la parola fredda: si legge sulla carta del casato, nessuna clausola la chiede (D-278) |
| `list_witnessed` | clausola di Consiglio | la lista letta davanti a testimoni: memoria narrata, nessuna regola la chiede |
| `price_in_lives` | Conseguenza | il conto in vite: memoria del mondo, nessuna clausola la chiede (D-278) |
| `return_promised` | clausola di Consiglio | il ritorno promesso: memoria narrata, e la promessa non ha ancora una regola |
| `settlement:$proponent` | Conseguenza | chi ci vive, scritto sulla mappa: la regola e' la pietra che la Conseguenza alza accanto — 50 volte in 100 anni |
| `someone_paid` | carta Echo | qualcuno ha pagato: il marchio di una decisione passata al prezzo di chi non c'e' piu' — si legge al centro del tavolo, non in una regola (D-278) |
| `spoke_and_lost` | Conseguenza | ha proposto e la proposta e' caduta: si legge sulla carta del casato (D-278) |
| `took_by_hand` | Conseguenza | si e' servito senza aspettare la decisione: si legge sulla carta del casato (D-278) |
| `watched` | Conseguenza | sotto osservazione: chi ha imposto la guardia se lo porta addosso (D-278) |

---

## I segni che nessuno scrive

Una condizione li nomina, e nessun Effetto li mette sul mondo. Alcuni
arrivano dall'apertura di una Chronicle o dal mondo ereditato — e allora
sono legittimi; altri sono clausole che **nessuno puo' soddisfare**.

I segni che scrive il **codice** e non i dati non compaiono qui: `evicted:` (confluence_controller.gd — la cacciata da una Regione), `function:` (chronicle_controller.gd — la funzione di Propp della carta Echo uscita), `legend:` (world_state_factory.gd — un fatto che sbiadisce diventa leggenda), `life:` (succession.gd — l'incarnazione che siede quest'anno).

| segno | chi lo chiede |
|---|---|
| `structure:road` | bersaglio a segni |

---

## I segni che mordono

| segno | chi lo scrive | chi lo cancella | chi lo legge |
|---|---|---|---|
| `amnesty_granted` | carta Echo, clausola di Consiglio | — | pesca delle domande |
| `anointed` | Conseguenza | — | Destino |
| `ash_watch` | Conseguenza, clausola di Consiglio | — | Destino |
| `betrayal_spoken` | Azione stampata, carta Echo | — | Risonanza |
| `charter_for_all` | clausola di Consiglio | — | pesca delle domande |
| `charter_temporary` | carta Echo, clausola di Consiglio | — | pesca delle domande |
| `charter_written` | Conseguenza | — | Destino, Risonanza, chi siede l'anno prossimo, pesca delle domande |
| `condition:abandoned` | Conseguenza | clausola di Consiglio | bersaglio a segni, la Regione di cui si discute, pesca delle domande |
| `condition:contested` | Azione stampata, Conseguenza, carta Asset, carta Echo | Azione stampata, Conseguenza, carta Asset | Destino, bersaglio a segni, la Regione di cui si discute |
| `condition:cut_off` | Azione stampata, Conseguenza, carta Asset, carta Echo | Azione stampata, Conseguenza, carta Asset | Destino, bersaglio a segni, la Regione di cui si discute, pesca delle domande |
| `condition:emptied` | Azione stampata, Conseguenza, carta Echo | — | Destino, bersaglio a segni, la Regione di cui si discute, obiettivo, pesca delle domande |
| `condition:exploited` | Conseguenza, Risonanza | — | Destino, la Regione di cui si discute, obiettivo, pesca delle domande |
| `condition:indebted` | Conseguenza, carta Asset, carta Echo | Conseguenza | la Regione di cui si discute, pesca delle domande |
| `condition:lean` | Conseguenza, carta Echo | Azione stampata, Conseguenza, carta Asset | Risonanza, bersaglio a segni, la Regione di cui si discute |
| `condition:mourning` | Conseguenza, carta Echo | Azione stampata, carta Asset | bersaglio a segni, la Regione di cui si discute, pesca delle domande |
| `condition:plundered` | Azione stampata, Conseguenza | Conseguenza | Risonanza, la Regione di cui si discute, pesca delle domande, regola del segno |
| `condition:rationed` | Azione stampata, Conseguenza, carta Asset | Azione stampata, Conseguenza, carta Asset | bersaglio a segni, la Regione di cui si discute, pesca delle domande |
| `condition:requisitioned` | Conseguenza | Azione stampata | la Regione di cui si discute |
| `condition:starving` | Azione stampata, Conseguenza, Risonanza, carta Echo | Azione stampata, Conseguenza, carta Asset, clausola di Consiglio | Risonanza, bersaglio a segni, la Regione di cui si discute, pesca delle domande, regola del segno |
| `condition:unrest` | Azione stampata, Conseguenza, Risonanza, carta Asset, carta Echo | Azione stampata, Conseguenza, carta Asset, carta Echo, clausola di Consiglio | Destino, bersaglio a segni, la Regione di cui si discute, pesca delle domande |
| `crown_dispossessed` | Conseguenza | — | Risonanza, fatto che dura, pesca delle domande |
| `crown_divided` | Conseguenza | Conseguenza | Destino, Risonanza, fatto che dura, pesca delle domande, proposta |
| `crowned` | — | Conseguenza | proposta |
| `crystal_exploited` | Azione stampata, Conseguenza | — | Destino, Risonanza, catena delle ere, chi **non** siede l'anno prossimo, chi siede l'anno prossimo, pesca delle domande |
| `crystal_measured` | Azione stampata, carta Echo | — | pesca delle domande |
| `debt_called` | Azione stampata, Conseguenza, carta Asset | — | Destino, Risonanza, chi siede l'anno prossimo, leggenda (un'era dopo), pesca delle domande, regola del segno |
| `debt_forgiven` | Azione stampata, Conseguenza | — | Destino |
| `debt_staggered` | clausola di Consiglio | — | pesca delle domande |
| `descent_witnessed` | clausola di Consiglio | — | pesca delle domande |
| `discovery:crystal` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:legend` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:relic` | Conseguenza, carta Echo, clausola di Consiglio | — | Destino, codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:shared_record` | clausola di Consiglio | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:supervised_record` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_charter` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_ledger` | Azione stampata, Conseguenza, clausola di Consiglio | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_measure` | carta Echo | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_omen` | Azione stampata, carta Echo | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:trade_ledger` | Azione stampata, clausola di Consiglio | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:written_law` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `distribution_audited` | clausola di Consiglio | — | pesca delle domande |
| `escort_sworn` | Azione stampata, Conseguenza | — | Destino, Risonanza |
| `evicted:$region_focus` | — | carta Asset | codice (chronicle_controller.gd) |
| `failed_proposal` | Conseguenza | — | Destino |
| `faith_established` | Conseguenza | — | Risonanza, pesca delle domande |
| `grain_requisitioned` | Azione stampata, Conseguenza | — | Risonanza, chi siede l'anno prossimo, pesca delle domande |
| `heir_named` | Azione stampata, Conseguenza, carta Asset | — | Risonanza, chi siede l'anno prossimo |
| `knowledge_shared` | Azione stampata, clausola di Consiglio | — | Risonanza, pesca delle domande |
| `ledger_public` | Azione stampata, Conseguenza, carta Asset, clausola di Consiglio | — | Destino, Risonanza, fatto che dura |
| `mine_sealed` | Conseguenza | Conseguenza | Destino, catena delle ere, fatto che dura, pesca delle domande, proposta |
| `nahr_settled` | Conseguenza | — | Destino, Risonanza, chi siede l'anno prossimo, fatto che dura |
| `no_charter` | Conseguenza | — | Destino, Risonanza, pesca delle domande |
| `oath_broken` | Azione stampata, Conseguenza | Conseguenza | Destino, Risonanza, bersaglio a segni, leggenda (un'era dopo), pesca delle domande, regola del segno |
| `order_restored` | Conseguenza | — | Destino, leggenda (un'era dopo) |
| `parley_held` | carta Echo | — | Risonanza |
| `petition_heard` | carta Echo | — | Risonanza |
| `question_unresolved` | Conseguenza | Conseguenza | Destino, Risonanza, obiettivo, proposta |
| `quota_guaranteed` | clausola di Consiglio | — | pesca delle domande |
| `relic_buried` | Conseguenza | — | Destino, pesca delle domande |
| `relic_recorded` | clausola di Consiglio | — | pesca delle domande |
| `relic_shown` | Conseguenza | — | Destino, chi siede l'anno prossimo, pesca delle domande |
| `renowned` | Azione stampata, Conseguenza, carta Echo | — | Destino, Risonanza, obiettivo, regola del segno |
| `rumour_running` | Conseguenza | — | Destino |
| `scar:abandoned` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:broken_bridge` | Conseguenza (cicatrice) | carta Asset | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:broken_word` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:changed_hands` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:divided_seal` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:dragonfall` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:emptied` | Conseguenza (cicatrice), Risonanza | — | chi **non** siede l'anno prossimo, chi siede l'anno prossimo, conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:open_wound` | Azione stampata, Conseguenza (cicatrice) | — | chi siede l'anno prossimo, conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:plundered` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:sealed_border` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:the_empty_chair` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), la Regione di cui si discute, regola del segno |
| `scar:unanswered` | Conseguenza (cicatrice) | carta Asset | conteggio delle cicatrici (`scar_count`) |
| `settlement:march` | Conseguenza | — | regola del segno |
| `settlement:market` | Conseguenza | — | bersaglio a segni, regola del segno |
| `settlement:village` | Azione stampata | — | bersaglio a segni, regola del segno |
| `structure:sealed` | Conseguenza | Azione stampata, Conseguenza | Destino, bersaglio a segni, chi **non** siede l'anno prossimo, la Regione di cui si discute |
| `study_supervised` | Conseguenza | — | Destino, pesca delle domande |
| `succession_by_law` | Azione stampata, Conseguenza | — | Destino, chi siede l'anno prossimo, fatto che dura |
| `succession_settled` | Conseguenza | — | pesca delle domande |
| `succession_witnessed` | clausola di Consiglio | — | pesca delle domande |
| `toll_shared` | Azione stampata, clausola di Consiglio | — | Risonanza, pesca delle domande |
| `valley_sealed` | Conseguenza | — | Destino, fatto che dura, pesca delle domande |
| `water_moves` | Conseguenza, carta Echo | — | Destino |
| `water_priced` | Conseguenza | — | Destino, pesca delle domande |
| `water_rights` | Conseguenza | — | pesca delle domande |
| `water_shared` | clausola di Consiglio | — | pesca delle domande |
