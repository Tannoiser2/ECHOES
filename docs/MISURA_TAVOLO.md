# ECHOES — quali segni arrivano sul tavolo, posto per posto

<!-- FILE GENERATO — si rifa' con `tools/run_table_survey.sh`. -->

Ogni segno che sul tavolo ha un pezzo di cartone — i **177** con un posto
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
| `capital` | 51 | 0 | 0 | 51 |  |
| `crystal_site` | 85 | 0 | 0 | 85 |  |
| `domain:ANCIENT` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:RESOURCE` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:SURVIVAL` | 100 | 0 | 0 | 100 | sempre in tavola |
| `domain:TERRITORY` | 100 | 0 | 0 | 100 | sempre in tavola |
| `forest` | 63 | 0 | 0 | 63 |  |
| `granary` | 59 | 0 | 0 | 59 |  |
| `harbor` | 75 | 0 | 0 | 75 |  |
| `island` | 56 | 0 | 0 | 56 |  |
| `marsh` | 56 | 0 | 0 | 56 |  |
| `mine` | 53 | 0 | 0 | 53 |  |
| `nomad_range` | 63 | 0 | 0 | 63 |  |
| `trade` | 60 | 0 | 0 | 60 |  |
| `wild` | 64 | 0 | 0 | 64 |  |

## uno spazio sulla tessera

le Pietre e i gradi che le degradano.

**25 segni: 21 arrivano sul tavolo, 3 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 1 | 0 | 0 |  |
| `place:cursed_wood` | 0 | 2 | 0 | 0 |  |
| `place:dry_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:forest` | 98 | 191 | 0 | 98 |  |
| `place:low_spring` | 0 | 2 | 0 | 1 |  |
| `place:open_site` | 0 | 8 | 0 | 5 |  |
| `place:pass` | 64 | 64 | 0 | 64 |  |
| `place:sleeping_site` | 85 | 123 | 0 | 83 |  |
| `place:spring` | 88 | 122 | 0 | 87 |  |
| `place:stripped_site` | 0 | 2 | 0 | 2 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 9 | 0 | 9 |  |
| `settlement:market` | 0 | 2 | 0 | 2 |  |
| `settlement:town` | 0 | 10 | 0 | 10 |  |
| `settlement:village` | 33 | 102 | 9 | 45 |  |
| `structure:archive` | 22 | 122 | 12 | 41 |  |
| `structure:canal` | 0 | 31 | 0 | 14 |  |
| `structure:castle` | 0 | 51 | 0 | 46 |  |
| `structure:granary` | 0 | 341 | 12 | 86 |  |
| `structure:library` | 0 | 15 | 0 | 14 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 10 | 16 | 10 |  |
| `structure:tollgate` | 0 | 249 | 17 | 69 |  |
| `structure:watchtower` | 100 | 331 | 75 | 90 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 44 | 9 | 33 |  |
| `condition:contested` | 0 | 466 | 61 | 97 |  |
| `condition:cut_off` | 0 | 104 | 136 | 54 |  |
| `condition:emptied` | 0 | 35 | 0 | 34 |  |
| `condition:exploited` | 0 | 4 | 0 | 4 |  |
| `condition:guarded` | 0 | 11 | 0 | 11 |  |
| `condition:indebted` | 0 | 10 | 1 | 9 |  |
| `condition:lean` | 0 | 90 | 118 | 48 |  |
| `condition:mourning` | 0 | 4 | 13 | 4 |  |
| `condition:plundered` | 0 | 50 | 0 | 39 |  |
| `condition:rationed` | 0 | 120 | 36 | 63 |  |
| `condition:starving` | 0 | 72 | 106 | 46 |  |
| `condition:unrest` | 0 | 265 | 18 | 94 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 11 arrivano sul tavolo, 2 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 61 | 0 | 50 |  |
| `scar:broken_bridge` | 0 | 1 | 16 | 1 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 3 | 0 | 2 |  |
| `scar:burned_records` | 0 | 12 | 0 | 12 |  |
| `scar:changed_hands` | 0 | 16 | 0 | 14 |  |
| `scar:divided_seal` | 0 | 5 | 0 | 5 |  |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 22 | 0 | 19 |  |
| `scar:open_wound` | 0 | 6 | 0 | 6 |  |
| `scar:plundered` | 0 | 18 | 0 | 17 |  |
| `scar:sealed_border` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:the_empty_chair` | 0 | 7 | 0 | 7 |  |
| `scar:unanswered` | 0 | 10 | 9 | 10 |  |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 29 arrivano sul tavolo, 27 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 12 | 0 | 12 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 2 | 0 | 2 |  |
| `crowned` | 55 | 0 | 4 | 53 |  |
| `discovery:crystal` | 0 | 20 | 0 | 18 |  |
| `discovery:legend` | 0 | 179 | 0 | 84 |  |
| `discovery:relic` | 0 | 21 | 0 | 17 |  |
| `discovery:shared_record` | 0 | 1 | 0 | 1 |  |
| `discovery:supervised_record` | 0 | 5 | 0 | 5 |  |
| `discovery:the_charter` | 0 | 13 | 0 | 11 |  |
| `discovery:the_ledger` | 0 | 340 | 0 | 97 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 430 | 0 | 98 |  |
| `discovery:trade_ledger` | 0 | 255 | 0 | 90 |  |
| `discovery:written_law` | 0 | 171 | 0 | 74 |  |
| `escort_sworn` | 0 | 195 | 0 | 88 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 1 | 0 | 1 |  |
| `free_cities` | 48 | 0 | 0 | 48 |  |
| `guild` | 46 | 0 | 0 | 46 |  |
| `hard_bargain` | 0 | 3 | 0 | 3 |  |
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
| `renowned` | 0 | 148 | 0 | 76 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 41 | 0 | 34 |  |
| `took_by_hand` | 0 | 4 | 0 | 4 |  |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 2 | 0 | 2 |  |
| `watched` | 0 | 9 | 0 | 9 |  |
| `water_rights` | 0 | 0 | 0 | 0 | **non arriva mai** |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**54 segni: 35 arrivano sul tavolo, 19 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 11 | 0 | 10 |  |
| `amnesty_granted` | 0 | 4 | 0 | 4 |  |
| `betrayal_spoken` | 0 | 22 | 0 | 20 |  |
| `burden_shared` | 0 | 21 | 0 | 21 |  |
| `charter_for_all` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `charter_temporary` | 0 | 15 | 0 | 10 |  |
| `charter_written` | 0 | 19 | 0 | 15 |  |
| `crown_dispossessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `crown_divided` | 0 | 18 | 0 | 16 |  |
| `crystal_exploited` | 0 | 20 | 0 | 19 |  |
| `crystal_measured` | 0 | 11 | 0 | 11 |  |
| `debt_called` | 0 | 217 | 0 | 85 |  |
| `debt_forgiven` | 0 | 107 | 0 | 63 |  |
| `debt_staggered` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `descent_witnessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `distribution_audited` | 0 | 15 | 0 | 8 |  |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 13 | 0 | 13 |  |
| `grain_requisitioned` | 0 | 10 | 0 | 10 |  |
| `heir_named` | 0 | 66 | 0 | 44 |  |
| `knowledge_shared` | 0 | 172 | 0 | 74 |  |
| `ledger_public` | 0 | 150 | 0 | 78 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `list_witnessed` | 0 | 20 | 0 | 12 |  |
| `mine_sealed` | 0 | 10 | 0 | 10 |  |
| `mountain_forgotten` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `nahr_settled` | 0 | 2 | 0 | 1 |  |
| `no_charter` | 0 | 1 | 0 | 1 |  |
| `oath_broken` | 0 | 6 | 8 | 5 |  |
| `order_restored` | 0 | 59 | 0 | 46 |  |
| `parley_held` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `petition_heard` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `price_in_lives` | 0 | 4 | 0 | 4 |  |
| `question_unresolved` | 0 | 103 | 14 | 80 |  |
| `quota_guaranteed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_buried` | 0 | 6 | 0 | 6 |  |
| `relic_recorded` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_shown` | 0 | 8 | 0 | 8 |  |
| `return_promised` | 0 | 9 | 0 | 8 |  |
| `rumour_running` | 0 | 43 | 0 | 35 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `someone_paid` | 0 | 2 | 0 | 2 |  |
| `study_supervised` | 0 | 7 | 0 | 7 |  |
| `succession_by_law` | 0 | 16 | 0 | 15 |  |
| `succession_settled` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `succession_witnessed` | 0 | 1 | 0 | 1 |  |
| `toll_shared` | 0 | 28 | 0 | 21 |  |
| `valley_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_moves` | 0 | 20 | 0 | 14 |  |
| `water_priced` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_shared` | 0 | 0 | 0 | 0 | **non arriva mai** |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **51 su 177**.

| segno | dove starebbe |
|---|---|
| `charter_for_all` | un gettone sul bordo della mappa |
| `crown_dispossessed` | un gettone sul bordo della mappa |
| `debt_staggered` | un gettone sul bordo della mappa |
| `descent_witnessed` | un gettone sul bordo della mappa |
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
| `mountain_forgotten` | un gettone sul bordo della mappa |
| `parley_held` | un gettone sul bordo della mappa |
| `petition_heard` | un gettone sul bordo della mappa |
| `place:dry_spring` | uno spazio sulla tessera |
| `quota_guaranteed` | un gettone sul bordo della mappa |
| `relic_recorded` | un gettone sul bordo della mappa |
| `scar:dragonfall` | un dischetto rotondo |
| `scar:sealed_border` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `succession_settled` | un gettone sul bordo della mappa |
| `twice_uprooted` | sulla scheda della casa |
| `valley_sealed` | un gettone sul bordo della mappa |
| `water_priced` | un gettone sul bordo della mappa |
| `water_rights` | sulla scheda della casa |
| `water_shared` | un gettone sul bordo della mappa |
