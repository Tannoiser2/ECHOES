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
| `harbor` | 67 | 0 | 0 | 67 |  |
| `island` | 33 | 0 | 0 | 33 |  |
| `marsh` | 51 | 0 | 0 | 51 |  |
| `mine` | 74 | 0 | 0 | 74 |  |
| `nomad_range` | 49 | 0 | 0 | 49 |  |
| `trade` | 100 | 0 | 0 | 100 | sempre in tavola |
| `wild` | 26 | 0 | 0 | 26 |  |

## uno spazio sulla tessera

le Pietre e i gradi che le degradano.

**25 segni: 18 arrivano sul tavolo, 6 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 1 | 0 | 0 |  |
| `place:cursed_wood` | 0 | 2 | 0 | 0 |  |
| `place:dry_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:forest` | 100 | 182 | 0 | 100 |  |
| `place:low_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:open_site` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:pass` | 26 | 26 | 0 | 26 |  |
| `place:sleeping_site` | 62 | 71 | 0 | 69 |  |
| `place:spring` | 100 | 149 | 0 | 100 |  |
| `place:stripped_site` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 3 | 0 | 3 |  |
| `settlement:market` | 0 | 8 | 0 | 6 |  |
| `settlement:town` | 0 | 3 | 0 | 3 |  |
| `settlement:village` | 45 | 107 | 5 | 54 |  |
| `structure:archive` | 16 | 172 | 11 | 49 |  |
| `structure:canal` | 0 | 24 | 1 | 13 |  |
| `structure:castle` | 0 | 68 | 0 | 55 |  |
| `structure:granary` | 0 | 246 | 12 | 74 |  |
| `structure:library` | 0 | 18 | 0 | 17 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 3 | 10 | 3 |  |
| `structure:tollgate` | 0 | 402 | 14 | 96 |  |
| `structure:watchtower` | 100 | 358 | 113 | 78 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 6 | 0 | 6 |  |
| `condition:contested` | 0 | 479 | 241 | 81 |  |
| `condition:cut_off` | 0 | 123 | 249 | 34 |  |
| `condition:emptied` | 0 | 16 | 3 | 13 |  |
| `condition:exploited` | 0 | 1 | 0 | 1 |  |
| `condition:guarded` | 0 | 83 | 16 | 48 |  |
| `condition:indebted` | 0 | 197 | 44 | 81 |  |
| `condition:lean` | 0 | 74 | 121 | 32 |  |
| `condition:mourning` | 0 | 17 | 38 | 11 |  |
| `condition:plundered` | 0 | 7 | 6 | 5 |  |
| `condition:rationed` | 0 | 235 | 162 | 59 |  |
| `condition:starving` | 0 | 56 | 114 | 24 |  |
| `condition:unrest` | 0 | 367 | 254 | 80 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 12 arrivano sul tavolo, 1 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 41 | 0 | 33 |  |
| `scar:broken_bridge` | 0 | 2 | 67 | 2 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 1 | 0 | 1 |  |
| `scar:burned_records` | 0 | 11 | 0 | 11 |  |
| `scar:changed_hands` | 0 | 63 | 0 | 47 |  |
| `scar:divided_seal` | 0 | 1 | 0 | 1 |  |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 17 | 0 | 14 |  |
| `scar:open_wound` | 0 | 2 | 0 | 2 |  |
| `scar:plundered` | 0 | 19 | 0 | 18 |  |
| `scar:sealed_border` | 0 | 10 | 0 | 9 |  |
| `scar:the_empty_chair` | 0 | 55 | 0 | 45 |  |
| `scar:unanswered` | 0 | 72 | 136 | 41 | **tolta piu' volte di quante si posa** |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 27 arrivano sul tavolo, 29 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 14 | 0 | 14 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 1 | 0 | 1 |  |
| `crowned` | 55 | 0 | 1 | 55 |  |
| `discovery:crystal` | 0 | 4 | 0 | 4 |  |
| `discovery:legend` | 0 | 150 | 0 | 77 |  |
| `discovery:relic` | 0 | 7 | 0 | 5 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 4 | 0 | 4 |  |
| `discovery:the_charter` | 0 | 35 | 0 | 25 |  |
| `discovery:the_ledger` | 0 | 563 | 0 | 99 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 449 | 0 | 97 |  |
| `discovery:trade_ledger` | 0 | 232 | 0 | 89 |  |
| `discovery:written_law` | 0 | 114 | 0 | 60 |  |
| `escort_sworn` | 0 | 374 | 119 | 92 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 1 | 0 | 1 |  |
| `free_cities` | 48 | 0 | 0 | 48 |  |
| `guild` | 46 | 0 | 0 | 46 |  |
| `hard_bargain` | 0 | 1 | 0 | 1 |  |
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
| `renowned` | 0 | 383 | 0 | 100 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 2 | 0 | 2 |  |
| `took_by_hand` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 1 | 0 | 1 |  |
| `watched` | 0 | 40 | 0 | 27 |  |
| `water_rights` | 0 | 0 | 0 | 0 | **non arriva mai** |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**48 segni: 38 arrivano sul tavolo, 10 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 18 | 0 | 17 |  |
| `betrayal_spoken` | 0 | 1 | 0 | 1 |  |
| `burden_shared` | 0 | 59 | 0 | 46 |  |
| `charter_for_all` | 0 | 10 | 0 | 10 |  |
| `charter_written` | 0 | 48 | 0 | 27 |  |
| `crown_dispossessed` | 0 | 1 | 0 | 1 |  |
| `crown_divided` | 0 | 11 | 0 | 11 |  |
| `crystal_exploited` | 0 | 10 | 0 | 9 |  |
| `crystal_measured` | 0 | 13 | 0 | 13 |  |
| `debt_called` | 0 | 323 | 0 | 91 |  |
| `debt_forgiven` | 0 | 149 | 0 | 65 |  |
| `debt_staggered` | 0 | 7 | 0 | 5 |  |
| `descent_witnessed` | 0 | 4 | 0 | 4 |  |
| `distribution_audited` | 0 | 3 | 0 | 3 |  |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 35 | 0 | 31 |  |
| `grain_requisitioned` | 0 | 16 | 0 | 12 |  |
| `heir_named` | 0 | 143 | 0 | 72 |  |
| `knowledge_shared` | 0 | 121 | 0 | 70 |  |
| `ledger_public` | 0 | 223 | 0 | 85 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 3 | 0 | 3 |  |
| `mountain_forgotten` | 0 | 1 | 0 | 1 |  |
| `nahr_settled` | 0 | 9 | 0 | 9 |  |
| `no_charter` | 0 | 6 | 0 | 4 |  |
| `oath_broken` | 0 | 1 | 9 | 1 |  |
| `order_restored` | 0 | 295 | 0 | 100 |  |
| `petition_heard` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `price_in_lives` | 0 | 11 | 0 | 9 |  |
| `question_unresolved` | 0 | 24 | 27 | 8 |  |
| `quota_guaranteed` | 0 | 7 | 0 | 7 |  |
| `relic_buried` | 0 | 9 | 0 | 9 |  |
| `relic_recorded` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_shown` | 0 | 7 | 0 | 5 |  |
| `rumour_running` | 0 | 10 | 0 | 9 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `study_supervised` | 0 | 4 | 0 | 4 |  |
| `succession_by_law` | 0 | 31 | 0 | 26 |  |
| `succession_settled` | 0 | 28 | 0 | 14 |  |
| `succession_witnessed` | 0 | 28 | 0 | 14 |  |
| `toll_shared` | 0 | 45 | 0 | 32 |  |
| `valley_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_moves` | 0 | 36 | 0 | 22 |  |
| `water_priced` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_shared` | 0 | 10 | 0 | 8 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **46 su 171**.

| segno | dove starebbe |
|---|---|
| `discovery:shared_record` | sulla scheda della casa |
| `discovery:the_measure` | sulla scheda della casa |
| `dragon_slain` | un gettone sul bordo della mappa |
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
| `petition_heard` | un gettone sul bordo della mappa |
| `place:dry_spring` | uno spazio sulla tessera |
| `place:low_spring` | uno spazio sulla tessera |
| `place:open_site` | uno spazio sulla tessera |
| `place:stripped_site` | uno spazio sulla tessera |
| `relic_recorded` | un gettone sul bordo della mappa |
| `scar:dragonfall` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `took_by_hand` | sulla scheda della casa |
| `twice_uprooted` | sulla scheda della casa |
| `valley_sealed` | un gettone sul bordo della mappa |
| `water_priced` | un gettone sul bordo della mappa |
| `water_rights` | sulla scheda della casa |
