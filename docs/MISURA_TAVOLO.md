# ECHOES — quali segni arrivano sul tavolo, posto per posto

<!-- FILE GENERATO — si rifa' con `tools/run_table_survey.sh`. -->

Ogni segno che sul tavolo ha un pezzo di cartone — i **171** con un posto
dichiarato (D-350) — e se in cento partite ci arriva davvero.

La sonda dei segni ne guardava 66: le memorie del mondo e le condizioni dei
luoghi. Questa li guarda tutti, **posto per posto**, perche' un gettone che
esce trenta volte e una Cicatrice che non esce mai sono due difetti diversi.

**all'apertura** = in quante partite c'e' gia' quando si comincia ·
**posato** = quante volte la partita lo mette · **tolto** = quante volte lo leva ·
**a fine partita** = in quante partite e' sul tavolo alla fine.

L'ultima colonna e' quella di cui fidarsi: non passa dal registro degli
Effetti, guarda il tavolo. Le prime tre dipendono da quali Effetti questa
sonda sa leggere, e in questo progetto quella e' la strada di sette difetti.

**E 27 segni sono fuori dalla portata di questa misura** (D-376): questa
sonda gioca **un anno per partita**, e loro il motore li scrive solo al
passaggio di consegne fra un'era e l'altra — la vita che si siede, il fatto
che sbiadisce in leggenda. Chiamarli «non arriva mai» accanto a un segno
che davvero nessuno posa metterebbe due difetti diversi sotto la stessa
parola. Quelli li misura [MISURA_VITE.md](MISURA_VITE.md), che gioca le saghe.

**E 2 non sono segni: sono forme.** `evicted:$region_focus`, `settlement:$proponent` portano un segnaposto
nell'id, e il motore ci scrive dentro il nome vero prima di posarle. La
forma nuda non arriva mai **per costruzione**, e sta fuori dal conto.

Misura: `cli/run_table_marks_probe.gd`, 100 partite, tavolo misto, semi da 7000.

## stampato sulla tessera

la natura del luogo. Nessuno lo posa: c'e' gia'.

**15 segni: 15 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `capital` | 100 | 0 | 0 | 100 | sempre in tavola |
| `crystal_site` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:ANCIENT` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:RESOURCE` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:SURVIVAL` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:TERRITORY` | 100 | 0 | 0 | 100 | sempre in tavola |
| `forest` | 100 | 0 | 0 | 100 | sempre in tavola |
| `granary` | 100 | 0 | 0 | 100 | sempre in tavola |
| `harbor` | 49 | 0 | 0 | 49 |  |
| `island` | 51 | 0 | 0 | 51 |  |
| `marsh` | 58 | 0 | 0 | 58 |  |
| `mine` | 51 | 0 | 0 | 51 |  |
| `nomad_range` | 42 | 0 | 0 | 42 |  |
| `trade` | 100 | 0 | 0 | 100 | sempre in tavola |
| `wild` | 49 | 0 | 0 | 49 |  |

## uno spazio sulla tessera

le Pietre e i gradi che le degradano.

**25 segni: 19 arrivano sul tavolo, 5 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 1 | 0 | 0 |  |
| `place:cursed_wood` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:dry_spring` | 0 | 1 | 0 | 0 |  |
| `place:forest` | 100 | 198 | 0 | 100 |  |
| `place:low_spring` | 0 | 1 | 0 | 1 |  |
| `place:open_site` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:pass` | 49 | 49 | 0 | 49 |  |
| `place:sleeping_site` | 100 | 101 | 0 | 99 |  |
| `place:spring` | 100 | 142 | 0 | 99 |  |
| `place:stripped_site` | 0 | 1 | 0 | 1 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 1 | 0 | 1 |  |
| `settlement:market` | 0 | 5 | 0 | 5 |  |
| `settlement:town` | 0 | 7 | 0 | 7 |  |
| `settlement:village` | 55 | 156 | 3 | 67 |  |
| `structure:archive` | 39 | 225 | 10 | 55 |  |
| `structure:canal` | 0 | 39 | 1 | 18 |  |
| `structure:castle` | 0 | 67 | 0 | 54 |  |
| `structure:granary` | 0 | 243 | 6 | 75 |  |
| `structure:library` | 0 | 35 | 0 | 32 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 0 | 9 | 0 | **non arriva mai** |
| `structure:tollgate` | 0 | 370 | 8 | 99 |  |
| `structure:watchtower` | 100 | 339 | 112 | 87 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 6 | 1 | 3 |  |
| `condition:contested` | 0 | 477 | 241 | 81 |  |
| `condition:cut_off` | 0 | 101 | 241 | 35 |  |
| `condition:emptied` | 0 | 22 | 5 | 15 |  |
| `condition:exploited` | 0 | 5 | 1 | 3 |  |
| `condition:guarded` | 0 | 68 | 13 | 45 |  |
| `condition:indebted` | 0 | 194 | 44 | 83 |  |
| `condition:lean` | 0 | 63 | 110 | 27 |  |
| `condition:mourning` | 0 | 13 | 49 | 9 |  |
| `condition:plundered` | 0 | 7 | 9 | 5 |  |
| `condition:rationed` | 0 | 273 | 244 | 65 |  |
| `condition:starving` | 0 | 61 | 128 | 19 |  |
| `condition:unrest` | 0 | 329 | 280 | 78 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 11 arrivano sul tavolo, 2 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 53 | 0 | 40 |  |
| `scar:broken_bridge` | 0 | 2 | 62 | 2 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:burned_records` | 0 | 10 | 0 | 10 |  |
| `scar:changed_hands` | 0 | 65 | 0 | 45 |  |
| `scar:divided_seal` | 0 | 2 | 0 | 2 |  |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 11 | 0 | 11 |  |
| `scar:open_wound` | 0 | 7 | 0 | 7 |  |
| `scar:plundered` | 0 | 20 | 0 | 20 |  |
| `scar:sealed_border` | 0 | 10 | 0 | 8 |  |
| `scar:the_empty_chair` | 0 | 43 | 0 | 41 |  |
| `scar:unanswered` | 0 | 79 | 132 | 44 | **tolta piu' volte di quante si posa** |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 27 arrivano sul tavolo, 29 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 14 | 0 | 12 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 1 | 0 | 1 |  |
| `crowned` | 55 | 0 | 2 | 55 |  |
| `discovery:crystal` | 0 | 6 | 0 | 6 |  |
| `discovery:legend` | 0 | 146 | 0 | 74 |  |
| `discovery:relic` | 0 | 6 | 0 | 4 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 2 | 0 | 2 |  |
| `discovery:the_charter` | 0 | 41 | 0 | 30 |  |
| `discovery:the_ledger` | 0 | 555 | 0 | 99 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 418 | 0 | 98 |  |
| `discovery:trade_ledger` | 0 | 208 | 0 | 87 |  |
| `discovery:written_law` | 0 | 109 | 0 | 54 |  |
| `escort_sworn` | 0 | 393 | 129 | 93 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 2 | 0 | 2 |  |
| `free_cities` | 48 | 0 | 0 | 48 |  |
| `guild` | 46 | 0 | 0 | 46 |  |
| `hard_bargain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `life:INC_ALDRIC_02` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_ALDRIC_REGENCY` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_ALDRIC_RESTORED` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_CENERE_02` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_CENERE_FURNACES` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_CENERE_ROADS` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_LIBERE_ASSEMBLY` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_LIBERE_HEGEMONY` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_LIBERE_LEAGUE` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_LYRA_02` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_LYRA_ACADEMY` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_LYRA_ARCHIVE` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_NAHR_DIASPORA` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_NAHR_HOSTS` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_NAHR_KINGDOM` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_SALE_02` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_SALE_BANK` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_SALE_FORGIVEN` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_VAERAX_CULT` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_VAERAX_LEGEND` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_VAERAX_RISEN` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_VETRO_02` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_VETRO_INQUISITION` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `life:INC_VETRO_SCHOOL` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `migrating` | 54 | 0 | 0 | 54 |  |
| `order` | 48 | 0 | 0 | 48 |  |
| `renowned` | 0 | 368 | 0 | 99 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 1 | 0 | 1 |  |
| `took_by_hand` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 2 | 0 | 2 |  |
| `watched` | 0 | 25 | 0 | 16 |  |
| `water_rights` | 0 | 1 | 0 | 1 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**48 segni: 37 arrivano sul tavolo, 11 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 25 | 0 | 21 |  |
| `betrayal_spoken` | 0 | 1 | 0 | 1 |  |
| `burden_shared` | 0 | 81 | 0 | 57 |  |
| `charter_for_all` | 0 | 12 | 0 | 12 |  |
| `charter_written` | 0 | 54 | 0 | 32 |  |
| `crown_dispossessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `crown_divided` | 0 | 12 | 0 | 12 |  |
| `crystal_exploited` | 0 | 12 | 0 | 10 |  |
| `crystal_measured` | 0 | 16 | 0 | 16 |  |
| `debt_called` | 0 | 305 | 0 | 92 |  |
| `debt_forgiven` | 0 | 149 | 0 | 73 |  |
| `debt_staggered` | 0 | 6 | 0 | 6 |  |
| `descent_witnessed` | 0 | 2 | 0 | 2 |  |
| `distribution_audited` | 0 | 2 | 0 | 2 |  |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 35 | 0 | 33 |  |
| `grain_requisitioned` | 0 | 21 | 0 | 15 |  |
| `heir_named` | 0 | 161 | 0 | 78 |  |
| `knowledge_shared` | 0 | 107 | 0 | 57 |  |
| `ledger_public` | 0 | 202 | 0 | 90 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 1 | 0 | 1 |  |
| `mountain_forgotten` | 0 | 2 | 0 | 2 |  |
| `nahr_settled` | 0 | 14 | 0 | 13 |  |
| `no_charter` | 0 | 1 | 0 | 1 |  |
| `oath_broken` | 0 | 0 | 16 | 0 | **non arriva mai** |
| `order_restored` | 0 | 300 | 0 | 99 |  |
| `petition_heard` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `price_in_lives` | 0 | 10 | 0 | 7 |  |
| `question_unresolved` | 0 | 21 | 38 | 8 |  |
| `quota_guaranteed` | 0 | 7 | 0 | 6 |  |
| `relic_buried` | 0 | 16 | 0 | 16 |  |
| `relic_recorded` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_shown` | 0 | 6 | 0 | 4 |  |
| `rumour_running` | 0 | 9 | 0 | 7 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `study_supervised` | 0 | 3 | 0 | 3 |  |
| `succession_by_law` | 0 | 35 | 0 | 29 |  |
| `succession_settled` | 0 | 27 | 0 | 13 |  |
| `succession_witnessed` | 0 | 27 | 0 | 13 |  |
| `toll_shared` | 0 | 49 | 0 | 36 |  |
| `valley_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_moves` | 0 | 46 | 0 | 30 |  |
| `water_priced` | 0 | 1 | 0 | 1 |  |
| `water_shared` | 0 | 14 | 0 | 9 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **47 su 171**.

| segno | dove starebbe |
|---|---|
| `crown_dispossessed` | un gettone sul bordo della mappa |
| `discovery:shared_record` | sulla scheda della casa |
| `discovery:the_measure` | sulla scheda della casa |
| `dragon_slain` | un gettone sul bordo della mappa |
| `hard_bargain` | sulla scheda della casa |
| `legend:debt_called` | un gettone sul bordo della mappa |
| `legend:oath_broken` | un gettone sul bordo della mappa |
| `legend:order_restored` | un gettone sul bordo della mappa |
| `life:INC_ALDRIC_02` | sulla scheda della casa |
| `life:INC_ALDRIC_REGENCY` | sulla scheda della casa |
| `life:INC_ALDRIC_RESTORED` | sulla scheda della casa |
| `life:INC_CENERE_02` | sulla scheda della casa |
| `life:INC_CENERE_FURNACES` | sulla scheda della casa |
| `life:INC_CENERE_ROADS` | sulla scheda della casa |
| `life:INC_LIBERE_ASSEMBLY` | sulla scheda della casa |
| `life:INC_LIBERE_HEGEMONY` | sulla scheda della casa |
| `life:INC_LIBERE_LEAGUE` | sulla scheda della casa |
| `life:INC_LYRA_02` | sulla scheda della casa |
| `life:INC_LYRA_ACADEMY` | sulla scheda della casa |
| `life:INC_LYRA_ARCHIVE` | sulla scheda della casa |
| `life:INC_NAHR_DIASPORA` | sulla scheda della casa |
| `life:INC_NAHR_HOSTS` | sulla scheda della casa |
| `life:INC_NAHR_KINGDOM` | sulla scheda della casa |
| `life:INC_SALE_02` | sulla scheda della casa |
| `life:INC_SALE_BANK` | sulla scheda della casa |
| `life:INC_SALE_FORGIVEN` | sulla scheda della casa |
| `life:INC_VAERAX_CULT` | sulla scheda della casa |
| `life:INC_VAERAX_LEGEND` | sulla scheda della casa |
| `life:INC_VAERAX_RISEN` | sulla scheda della casa |
| `life:INC_VETRO_02` | sulla scheda della casa |
| `life:INC_VETRO_INQUISITION` | sulla scheda della casa |
| `life:INC_VETRO_SCHOOL` | sulla scheda della casa |
| `oath_broken` | un gettone sul bordo della mappa |
| `petition_heard` | un gettone sul bordo della mappa |
| `place:cursed_wood` | uno spazio sulla tessera |
| `place:open_site` | uno spazio sulla tessera |
| `relic_recorded` | un gettone sul bordo della mappa |
| `scar:broken_word` | un dischetto rotondo |
| `scar:dragonfall` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `structure:sealed` | uno spazio sulla tessera |
| `took_by_hand` | sulla scheda della casa |
| `twice_uprooted` | sulla scheda della casa |
| `valley_sealed` | un gettone sul bordo della mappa |
