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


**103 segni scritti sul mondo: 93 li legge qualcosa, 10 no.**

**E 0 segni li chiede qualcuno senza che niente li scriva.**

**E 34 li guarda una mano sola: contando i muti, 44 su 103 — il 43%.**

---

## Il tavolo: dove sta ogni segno

Ogni segno del dizionario nel posto fisico dove lo prendi in mano.
L'ultima colonna e' quella che conta: **segni che qualcosa scrive e
nessuno legge**, contati posto per posto.

| posto | segni | scritti sul mondo | di cui muti | cos'e' |
|---|---|---|---|---|
| **stampato sulla tessera** | 15 | 0 | — | la natura del luogo: montagna, capitale, pascolo. Non cambia mai. |
| **uno spazio sulla tessera** | 25 | 9 | **1** | dove si posa una Pietra, e i gradi che la degradano: bosco, bosco rado, selva maledetta. |
| **un gettone accanto alla tessera** | 13 | 13 | — | lo stato di adesso: affamata, chiusa, in rivolta. Si mette e si toglie. |
| **un dischetto rotondo** | 13 | 12 | — | le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo. |
| **sulla scheda della casa** | 57 | 22 | **5** | chi sei adesso: incoronato, dormiente, decaduto, e la vita che stai vivendo. |
| **un gettone sul bordo della mappa** | 52 | 47 | **4** | quello che il mondo ricorda: sta dove sta il mondo, non su un luogo (D-351). |
| **il tavolo non lo mostra** | 0 | 0 | — | contabilita' che il motore usa e nessuna fustella taglia. |

Ogni segno ha un posto. **175 stanno sul tavolo**, 0 sono contabilita'.

---

## I segni che li guarda una mano sola

Il criterio e' del committente: *«se un tag viene letto una volta da
qualcuno, questo tag non serve a nulla»*. Una mano sola e' pur sempre una
mano — ma un segno letto da un solo posto **non fa scegliere**: chi gioca
non ha nessun motivo per posarlo o evitarlo, se non quell'unico.

L'ultima colonna e' il costo vero: la fustella che quel segno si porta
nella scatola comunque.

**44 segni su 103 scritti sul mondo — il 43% — li guarda una mano sola (34) o nessuna (10), e 42 di loro hanno un gettone stampato.**

| l'unica mano che legge | segni | quali |
|---|---|---|
| pesca delle domande | **12** | `amnesty_granted`, `charter_for_all`, `crystal_measured`, `debt_staggered`, `descent_witnessed`, `distribution_audited`, `quota_guaranteed`, `relic_recorded`, `succession_settled`, `succession_witnessed`, `water_rights`, `water_shared` |
| codice (condition_evaluator.gd, policy_decider.gd) | **9** | `discovery:crystal`, `discovery:legend`, `discovery:supervised_record`, `discovery:the_charter`, `discovery:the_ledger`, `discovery:the_measure`, `discovery:the_omen`, `discovery:trade_ledger`, `discovery:written_law` |
| conteggio delle cicatrici (`scar_count`) | **5** | `scar:divided_seal`, `scar:dragonfall`, `scar:plundered`, `scar:sealed_border`, `scar:unanswered` |
| Destino | **4** | `anointed`, `ash_watch`, `failed_proposal`, `water_moves` |
| Risonanza | **2** | `parley_held`, `petition_heard` |
| codice (chronicle_controller.gd) | **1** | `evicted:$region_focus` |
| regola del segno | **1** | `settlement:march` |

| segno | sul tavolo sta | chi lo scrive | chi lo legge | gettone |
|---|---|---|---|---|
| `amnesty_granted` | un gettone sul bordo della mappa | carta Echo | pesca delle domande | `TOK_AMNESTY_GRANTED` |
| `anointed` | sulla scheda della casa | Conseguenza | Destino | `TOK_ANOINTED` |
| `ash_watch` | sulla scheda della casa | Conseguenza | Destino | `TOK_ASH_WATCH` |
| `charter_for_all` | un gettone sul bordo della mappa | casella IL MONDO RICORDA | pesca delle domande | `TOK_CHARTER_FOR_ALL` |
| `crystal_measured` | un gettone sul bordo della mappa | Azione stampata, carta Echo, casella IL MONDO RICORDA | pesca delle domande | `TOK_CRYSTAL_MEASURED` |
| `debt_staggered` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_DEBT_STAGGERED` |
| `descent_witnessed` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_DESCENT_WITNESSED` |
| `discovery:crystal` | sulla scheda della casa | Azione stampata, Conseguenza | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_CRYSTAL` |
| `discovery:legend` | sulla scheda della casa | Azione stampata, Conseguenza | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_LEGEND` |
| `discovery:supervised_record` | sulla scheda della casa | Conseguenza | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_SUPERVISED_RECORD` |
| `discovery:the_charter` | sulla scheda della casa | Conseguenza | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_THE_CHARTER` |
| `discovery:the_ledger` | sulla scheda della casa | Azione stampata, Conseguenza | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_THE_LEDGER` |
| `discovery:the_measure` | sulla scheda della casa | carta Echo | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_THE_MEASURE` |
| `discovery:the_omen` | sulla scheda della casa | Azione stampata, carta Echo | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_THE_OMEN` |
| `discovery:trade_ledger` | sulla scheda della casa | Azione stampata | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_TRADE_LEDGER` |
| `discovery:written_law` | sulla scheda della casa | Azione stampata, Conseguenza | codice (condition_evaluator.gd, policy_decider.gd) | `TOK_DISCOVERY_WRITTEN_LAW` |
| `distribution_audited` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_DISTRIBUTION_AUDITED` |
| `evicted:$region_focus` | sulla scheda della casa | carta Asset | codice (chronicle_controller.gd) | — |
| `failed_proposal` | sulla scheda della casa | Conseguenza | Destino | `TOK_FAILED_PROPOSAL` |
| `parley_held` | un gettone sul bordo della mappa | carta Echo | Risonanza | `TOK_PARLEY_HELD` |
| `petition_heard` | un gettone sul bordo della mappa | carta Echo | Risonanza | `TOK_PETITION_HEARD` |
| `quota_guaranteed` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_QUOTA_GUARANTEED` |
| `relic_recorded` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_RELIC_RECORDED` |
| `scar:divided_seal` | un dischetto rotondo | Conseguenza (cicatrice) | conteggio delle cicatrici (`scar_count`) | `TOK_SCAR_DIVIDED_SEAL` |
| `scar:dragonfall` | un dischetto rotondo | Conseguenza (cicatrice) | conteggio delle cicatrici (`scar_count`) | `TOK_SCAR_DRAGONFALL` |
| `scar:plundered` | un dischetto rotondo | Conseguenza (cicatrice) | conteggio delle cicatrici (`scar_count`) | `TOK_SCAR_PLUNDERED` |
| `scar:sealed_border` | un dischetto rotondo | Conseguenza (cicatrice) | conteggio delle cicatrici (`scar_count`) | `TOK_SCAR_SEALED_BORDER` |
| `scar:unanswered` | un dischetto rotondo | Conseguenza (cicatrice), carta Asset | conteggio delle cicatrici (`scar_count`) | `TOK_SCAR_UNANSWERED` |
| `settlement:march` | uno spazio sulla tessera | Conseguenza | regola del segno | `TOK_SETTLEMENT_MARCH` |
| `succession_settled` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_SUCCESSION_SETTLED` |
| `succession_witnessed` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_SUCCESSION_WITNESSED` |
| `water_moves` | un gettone sul bordo della mappa | Conseguenza, carta Echo, casella IL MONDO RICORDA | Destino | `TOK_WATER_MOVES` |
| `water_rights` | sulla scheda della casa | Conseguenza | pesca delle domande | `TOK_WATER_RIGHTS` |
| `water_shared` | un gettone sul bordo della mappa | Conseguenza | pesca delle domande | `TOK_WATER_SHARED` |

---

## I segni muti

Scritti da qualcosa, letti da niente. Ognuno e' una carta o una
Conseguenza che promette un cambiamento che il gioco non registra.

| segno | sul tavolo sta | chi lo scrive | perche' e' ancora qui |
|---|---|---|---|
| `account_settled` | un gettone sul bordo della mappa | Conseguenza, carta Echo, casella IL MONDO RICORDA | memoria del mondo: «il conto e' stato saldato» chiude un debito e nessuna clausola lo interroga — la faccia di un Destino e un profilo lo guardano, il motore no (D-399) — 4 volte in 100 anni |
| `crowned` | sulla scheda della casa | Conseguenza | la corona: sta addosso a chi la porta dal setup, e una Conseguenza puo' togliergliela. Fino alla 0.1.443 la interrogava la clausola di una proposta — «solo chi porta la corona puo' requisire» — e le proposte sono uscite dai dati (D-474): il Consiglio a due domande non ha un posto dove una condizione valga per **una sola risposta**, perche' non ci sono risposte, ci sono due domande. La guardano la faccia di un Destino e tre profili di casa; il motore no. Rimetterla a mordere e' una decisione, ed e' in ISSUES 129. — in ogni partita, dal setup |
| `dragon_slain` | un gettone sul bordo della mappa | Conseguenza | memoria del mondo: narrata (D-103), ereditata — non esce mai in 100 anni: la Conseguenza non e' mai stata scelta (ISSUES 56) |
| `hard_bargain` | sulla scheda della casa | Conseguenza | marchio di memoria (D-278): ha ottenuto cedendo poco, e il tavolo se lo ricorda — il motore non lo interroga |
| `price_in_lives` | un gettone sul bordo della mappa | Conseguenza | memoria del mondo (D-278): una decisione passata al prezzo di qualcuno che non c'e' piu' — si legge al centro del tavolo |
| `settlement:$proponent` | uno spazio sulla tessera | Conseguenza | porta un id dinamico: chi vive li' e' scritto nel segno stesso — 50 volte in 100 anni |
| `someone_paid` | un gettone sul bordo della mappa | carta Echo | memoria del mondo: narrata (D-103), ereditata |
| `spoke_and_lost` | sulla scheda della casa | Conseguenza | marchio di memoria (D-278): ha proposto e la proposta e' caduta — si legge sulla carta del casato |
| `took_by_hand` | sulla scheda della casa | Conseguenza | marchio di memoria (D-278): non ha aspettato la decisione, ha preso — si legge sulla carta del casato |
| `watched` | sulla scheda della casa | Conseguenza | marchio di memoria (D-278): chi ha imposto la guardia se lo porta addosso, e si legge sulla carta del casato — il motore non lo interroga |

---

## I segni che nessuno scrive

Nessuno: tutto quello che una condizione chiede, qualcosa lo puo' scrivere.

---

## I segni che mordono

| segno | chi lo scrive | chi lo cancella | chi lo legge |
|---|---|---|---|
| `amnesty_granted` | carta Echo | — | pesca delle domande |
| `anointed` | Conseguenza | — | Destino |
| `ash_watch` | Conseguenza | — | Destino |
| `betrayal_spoken` | Azione stampata, carta Echo | — | Risonanza, carta Echo |
| `burden_shared` | Conseguenza, carta Echo | — | carta Echo, chi siede l'anno prossimo |
| `charter_for_all` | casella IL MONDO RICORDA | — | pesca delle domande |
| `charter_temporary` | carta Echo | — | chi siede l'anno prossimo, pesca delle domande |
| `charter_written` | Conseguenza, casella IL MONDO RICORDA | — | Destino, Risonanza, chi siede l'anno prossimo, pesca delle domande |
| `condition:abandoned` | Conseguenza | — | Destino, bersaglio a segni, carta Echo, la Regione di cui si discute, pesca delle domande |
| `condition:contested` | Azione stampata, Conseguenza, carta Asset, carta Echo | Azione stampata, Conseguenza, carta Asset | Destino, bersaglio a segni, carta Echo, la Regione di cui si discute |
| `condition:cut_off` | Azione stampata, Conseguenza, carta Asset, carta Echo | Azione stampata, Conseguenza, carta Asset | Destino, bersaglio a segni, carta Echo, chi siede l'anno prossimo, la Regione di cui si discute, pesca delle domande |
| `condition:emptied` | Azione stampata, Conseguenza, carta Echo | — | Destino, bersaglio a segni, carta Echo, la Regione di cui si discute, obiettivo, pesca delle domande |
| `condition:exploited` | Conseguenza, Risonanza | — | Destino, la Regione di cui si discute, obiettivo, pesca delle domande |
| `condition:guarded` | Conseguenza | — | carta Echo, regola del segno |
| `condition:indebted` | Conseguenza, carta Asset, carta Echo | Conseguenza | la Regione di cui si discute, pesca delle domande |
| `condition:lean` | Azione stampata, Conseguenza, carta Echo | Azione stampata, Conseguenza, carta Asset | Risonanza, bersaglio a segni, la Regione di cui si discute |
| `condition:mourning` | Conseguenza, carta Echo | Azione stampata, carta Asset | bersaglio a segni, la Regione di cui si discute, pesca delle domande |
| `condition:plundered` | Azione stampata, Conseguenza | Conseguenza | Risonanza, la Regione di cui si discute, pesca delle domande, regola del segno |
| `condition:rationed` | Azione stampata, Conseguenza, carta Asset | Azione stampata, Conseguenza, carta Asset | bersaglio a segni, carta Echo, la Regione di cui si discute, pesca delle domande |
| `condition:starving` | Azione stampata, Conseguenza, Risonanza, carta Echo | Azione stampata, Conseguenza, carta Asset | Risonanza, bersaglio a segni, la Regione di cui si discute, pesca delle domande, regola del segno |
| `condition:unrest` | Azione stampata, Conseguenza, Risonanza, carta Asset, carta Echo | Azione stampata, Conseguenza, carta Asset, carta Echo | Destino, bersaglio a segni, carta Echo, la Regione di cui si discute, pesca delle domande |
| `crown_dispossessed` | Conseguenza | — | Risonanza, fatto che dura, pesca delle domande |
| `crown_divided` | Conseguenza, casella IL MONDO RICORDA | — | Destino, Risonanza, fatto che dura, pesca delle domande |
| `crystal_exploited` | Azione stampata, Conseguenza, casella IL MONDO RICORDA | — | Destino, Risonanza, carta Echo, catena delle ere, chi **non** siede l'anno prossimo, chi siede l'anno prossimo, pesca delle domande |
| `crystal_measured` | Azione stampata, carta Echo, casella IL MONDO RICORDA | — | pesca delle domande |
| `debt_called` | Azione stampata, Conseguenza, carta Asset, casella IL MONDO RICORDA | — | Destino, Risonanza, carta Echo, chi siede l'anno prossimo, leggenda (un'era dopo), pesca delle domande, regola del segno |
| `debt_forgiven` | Azione stampata, Conseguenza, carta Echo, casella IL MONDO RICORDA | — | Destino, chi siede l'anno prossimo |
| `debt_staggered` | Conseguenza | — | pesca delle domande |
| `descent_witnessed` | Conseguenza | — | pesca delle domande |
| `discovery:crystal` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:legend` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:relic` | Conseguenza, carta Echo | — | Destino, codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:supervised_record` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_charter` | Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_ledger` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_measure` | carta Echo | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:the_omen` | Azione stampata, carta Echo | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:trade_ledger` | Azione stampata | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `discovery:written_law` | Azione stampata, Conseguenza | — | codice (condition_evaluator.gd, policy_decider.gd) |
| `distribution_audited` | Conseguenza | — | pesca delle domande |
| `escort_sworn` | Azione stampata, Conseguenza | — | Destino, Risonanza, chi siede l'anno prossimo |
| `evicted:$region_focus` | — | carta Asset | codice (chronicle_controller.gd) |
| `failed_proposal` | Conseguenza | — | Destino |
| `faith_established` | Conseguenza, casella IL MONDO RICORDA | — | Risonanza, pesca delle domande |
| `grain_requisitioned` | Azione stampata, Conseguenza | — | Risonanza, chi siede l'anno prossimo, pesca delle domande |
| `heir_named` | Azione stampata, Conseguenza, carta Asset | — | Risonanza, chi siede l'anno prossimo |
| `knowledge_shared` | Azione stampata, carta Echo, casella IL MONDO RICORDA | — | Destino, Risonanza, carta Echo, pesca delle domande |
| `ledger_public` | Azione stampata, Conseguenza, carta Asset, casella IL MONDO RICORDA | — | Destino, Risonanza, carta Echo, chi siede l'anno prossimo, fatto che dura |
| `mine_sealed` | Conseguenza, casella IL MONDO RICORDA | Conseguenza | Destino, catena delle ere, fatto che dura, pesca delle domande |
| `mountain_forgotten` | casella IL MONDO RICORDA | — | Destino, chi siede l'anno prossimo |
| `nahr_settled` | Conseguenza, casella IL MONDO RICORDA | — | Destino, Risonanza, chi siede l'anno prossimo, fatto che dura |
| `no_charter` | Conseguenza | — | Destino, Risonanza, pesca delle domande |
| `oath_broken` | Azione stampata, Conseguenza | Conseguenza | Destino, Risonanza, bersaglio a segni, leggenda (un'era dopo), pesca delle domande, regola del segno |
| `order_restored` | Conseguenza, casella IL MONDO RICORDA | — | Destino, carta Echo, leggenda (un'era dopo) |
| `parley_held` | carta Echo | — | Risonanza |
| `petition_heard` | carta Echo | — | Risonanza |
| `question_unresolved` | Conseguenza | Conseguenza | Destino, Risonanza, carta Echo, obiettivo |
| `quota_guaranteed` | Conseguenza | — | pesca delle domande |
| `relic_buried` | Conseguenza, casella IL MONDO RICORDA | — | Destino, pesca delle domande |
| `relic_recorded` | Conseguenza | — | pesca delle domande |
| `relic_shown` | Conseguenza | — | Destino, chi siede l'anno prossimo, pesca delle domande |
| `renowned` | Azione stampata, Conseguenza, carta Echo | — | Destino, Risonanza, obiettivo, regola del segno |
| `rumour_running` | Conseguenza | — | Destino, carta Echo |
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
| `settlement:village` | Azione stampata | — | Destino, bersaglio a segni, regola del segno |
| `structure:archive` | Azione stampata | — | Destino, bersaglio a segni |
| `structure:granary` | Azione stampata | — | bersaglio a segni, la Regione di cui si discute, regola del segno |
| `structure:sealed` | Conseguenza | Azione stampata, Conseguenza | Destino, bersaglio a segni, chi **non** siede l'anno prossimo, la Regione di cui si discute |
| `structure:tollgate` | Azione stampata | — | bersaglio a segni, la Regione di cui si discute, regola del segno |
| `structure:watchtower` | Azione stampata | — | bersaglio a segni, regola del segno |
| `study_supervised` | Conseguenza | — | Destino, pesca delle domande |
| `succession_by_law` | Azione stampata, Conseguenza, casella IL MONDO RICORDA | — | Destino, chi siede l'anno prossimo, fatto che dura |
| `succession_settled` | Conseguenza | — | pesca delle domande |
| `succession_witnessed` | Conseguenza | — | pesca delle domande |
| `toll_shared` | Azione stampata | — | Risonanza, carta Echo, pesca delle domande |
| `valley_sealed` | Conseguenza | — | Destino, fatto che dura, pesca delle domande |
| `water_moves` | Conseguenza, carta Echo, casella IL MONDO RICORDA | — | Destino |
| `water_priced` | Conseguenza | — | Destino, pesca delle domande |
| `water_rights` | Conseguenza | — | pesca delle domande |
| `water_shared` | Conseguenza | — | pesca delle domande |
