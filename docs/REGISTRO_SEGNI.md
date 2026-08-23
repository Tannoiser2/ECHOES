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


**71 segni scritti sul mondo: 61 li legge qualcosa, 10 no.**

**E 0 segni li chiede qualcuno senza che niente li scriva.**

---

## I segni muti

Scritti da qualcosa, letti da niente. Ognuno e' una carta o una
Conseguenza che promette un cambiamento che il gioco non registra.

| segno | chi lo scrive | perche' e' ancora qui |
|---|---|---|
| `account_settled` | Conseguenza | «Il Conto Saldato» chiude un debito e nessuna regola lo sa |
| `burden_shared` | Conseguenza | il peso diviso non alleggerisce niente |
| `condition:contested` | Conseguenza, carta Asset | una Regione contesa non cambia nulla di quello che ci si puo' fare |
| `condition:lean` | Conseguenza, carta Asset | la Regione magra: la scrive l'Eco dell'interramento e non la legge nessuno |
| `condition:requisitioned` | Conseguenza | requisire lascia un segno che non morde |
| `dragon_slain` | Conseguenza | «Il Drago Abbattuto» — e il mondo non se ne accorge |
| `heir_named` | Conseguenza, carta Asset | un erede nominato non conta per nessuna successione |
| `settlement:$proponent` | Conseguenza | l'insediamento del proponente si stampa e basta |
| `succession_settled` | Conseguenza | la successione risolta non entra in nessuna condizione |
| `water_rights` | Conseguenza | i diritti sull'acqua non sono un requisito di niente |

---

## I segni che nessuno scrive

Nessuno: tutto quello che una condizione chiede, qualcosa lo puo' scrivere.

---

## I segni che mordono

| segno | chi lo scrive | chi lo cancella | chi lo legge |
|---|---|---|---|
| `anointed` | Conseguenza | — | Destino |
| `ash_watch` | Conseguenza | — | Destino |
| `charter_written` | Conseguenza | — | Destino, fatto che dura, pesca delle domande |
| `condition:abandoned` | Conseguenza | — | pesca delle domande |
| `condition:cut_off` | Conseguenza, carta Asset | Conseguenza, carta Asset | pesca delle domande |
| `condition:emptied` | Conseguenza | — | Destino, pesca delle domande |
| `condition:exploited` | Conseguenza | — | Destino, pesca delle domande |
| `condition:indebted` | Conseguenza, carta Asset | Conseguenza | pesca delle domande |
| `condition:mourning` | — | carta Asset | pesca delle domande |
| `condition:plundered` | Conseguenza | Conseguenza | pesca delle domande, regola del segno |
| `condition:rationed` | Conseguenza, carta Asset | Conseguenza, carta Asset | pesca delle domande |
| `condition:starving` | Conseguenza | Conseguenza, carta Asset | pesca delle domande, regola del segno |
| `condition:unrest` | Conseguenza, carta Asset | Conseguenza, carta Asset | Destino, pesca delle domande |
| `crown_dispossessed` | Conseguenza | — | fatto che dura, pesca delle domande |
| `crown_divided` | Conseguenza | Conseguenza | Destino, fatto che dura, pesca delle domande, proposta |
| `crowned` | — | Conseguenza | proposta |
| `crystal_exploited` | Conseguenza | — | Destino, leggenda (un'era dopo), pesca delle domande |
| `debt_called` | Conseguenza, carta Asset | — | Destino, leggenda (un'era dopo), pesca delle domande, regola del segno |
| `debt_forgiven` | Conseguenza | — | Destino |
| `discovery:crystal` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:legend` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:relic` | Conseguenza | — | Destino, codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:supervised_record` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_charter` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_ledger` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:written_law` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `escort_sworn` | Conseguenza | — | Destino |
| `evicted:$region_focus` | — | carta Asset | codice (chronicle_controller.gd) |
| `failed_proposal` | Conseguenza | — | Destino |
| `faith_established` | Conseguenza | — | fatto che dura, pesca delle domande |
| `grain_requisitioned` | Conseguenza | — | pesca delle domande |
| `ledger_public` | Conseguenza, carta Asset | — | Destino, fatto che dura |
| `mine_sealed` | Conseguenza | Conseguenza | Destino, fatto che dura, pesca delle domande, proposta |
| `nahr_settled` | Conseguenza | — | Destino, fatto che dura |
| `no_charter` | Conseguenza | — | Destino, pesca delle domande |
| `oath_broken` | Conseguenza | Conseguenza | Destino, leggenda (un'era dopo), pesca delle domande, regola del segno |
| `order_restored` | Conseguenza | — | leggenda (un'era dopo) |
| `question_unresolved` | Conseguenza | Conseguenza | Destino, obiettivo, proposta |
| `relic_buried` | Conseguenza | — | Destino, fatto che dura, pesca delle domande |
| `relic_shown` | Conseguenza | — | Destino, pesca delle domande |
| `renowned` | Conseguenza | — | Destino, obiettivo, regola del segno |
| `scar:abandoned` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:broken_bridge` | Conseguenza (cicatrice) | carta Asset | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:broken_word` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:changed_hands` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:divided_seal` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:dragonfall` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:emptied` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:open_wound` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:plundered` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:sealed_border` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`) |
| `scar:the_empty_chair` | Conseguenza (cicatrice) | — | conteggio delle cicatrici (`scar_count`), regola del segno |
| `scar:unanswered` | Conseguenza (cicatrice) | carta Asset | conteggio delle cicatrici (`scar_count`) |
| `settlement:march` | Conseguenza | — | regola del segno |
| `settlement:market` | Conseguenza | — | regola del segno |
| `structure:sealed` | Conseguenza | Conseguenza | Destino |
| `study_supervised` | Conseguenza | — | Destino, pesca delle domande |
| `succession_by_law` | Conseguenza | — | Destino, fatto che dura |
| `valley_sealed` | Conseguenza | — | Destino, fatto che dura, pesca delle domande |
| `water_moves` | Conseguenza | — | Destino |
| `water_priced` | Conseguenza | — | Destino, fatto che dura, pesca delle domande |
