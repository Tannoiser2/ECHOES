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

**25 segni: 22 arrivano sul tavolo, 2 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 1 | 0 | 1 |  |
| `place:cursed_wood` | 0 | 7 | 0 | 2 |  |
| `place:dry_spring` | 0 | 3 | 0 | 2 |  |
| `place:forest` | 98 | 191 | 0 | 97 |  |
| `place:low_spring` | 0 | 1 | 0 | 1 |  |
| `place:open_site` | 0 | 1 | 0 | 1 |  |
| `place:pass` | 64 | 64 | 0 | 63 |  |
| `place:sleeping_site` | 85 | 120 | 0 | 85 |  |
| `place:spring` | 88 | 122 | 0 | 86 |  |
| `place:stripped_site` | 0 | 1 | 0 | 1 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 3 | 0 | 3 |  |
| `settlement:market` | 0 | 7 | 0 | 7 |  |
| `settlement:town` | 0 | 11 | 0 | 10 |  |
| `settlement:village` | 33 | 85 | 9 | 35 |  |
| `structure:archive` | 22 | 165 | 12 | 43 |  |
| `structure:canal` | 0 | 22 | 1 | 9 |  |
| `structure:castle` | 0 | 46 | 0 | 38 |  |
| `structure:granary` | 0 | 314 | 8 | 81 |  |
| `structure:library` | 0 | 19 | 0 | 18 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 4 | 3 | 3 |  |
| `structure:tollgate` | 0 | 372 | 10 | 92 |  |
| `structure:watchtower` | 100 | 345 | 129 | 84 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 12 | 1 | 8 |  |
| `condition:contested` | 0 | 496 | 189 | 95 |  |
| `condition:cut_off` | 0 | 123 | 301 | 40 |  |
| `condition:emptied` | 0 | 25 | 1 | 21 |  |
| `condition:exploited` | 0 | 3 | 0 | 3 |  |
| `condition:guarded` | 0 | 91 | 17 | 60 |  |
| `condition:indebted` | 0 | 159 | 37 | 76 |  |
| `condition:lean` | 0 | 75 | 106 | 34 |  |
| `condition:mourning` | 0 | 16 | 48 | 13 |  |
| `condition:plundered` | 0 | 11 | 19 | 9 |  |
| `condition:rationed` | 0 | 287 | 182 | 62 |  |
| `condition:starving` | 0 | 18 | 136 | 9 |  |
| `condition:unrest` | 0 | 316 | 167 | 86 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 11 arrivano sul tavolo, 2 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 45 | 0 | 36 |  |
| `scar:broken_bridge` | 0 | 2 | 42 | 2 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 3 | 0 | 3 |  |
| `scar:burned_records` | 0 | 12 | 0 | 12 |  |
| `scar:changed_hands` | 0 | 55 | 0 | 41 |  |
| `scar:divided_seal` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 19 | 0 | 17 |  |
| `scar:open_wound` | 0 | 4 | 0 | 4 |  |
| `scar:plundered` | 0 | 23 | 0 | 21 |  |
| `scar:sealed_border` | 0 | 19 | 0 | 17 |  |
| `scar:the_empty_chair` | 0 | 39 | 0 | 37 |  |
| `scar:unanswered` | 0 | 64 | 113 | 40 | **tolta piu' volte di quante si posa** |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 27 arrivano sul tavolo, 29 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 20 | 0 | 20 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 1 | 0 | 1 |  |
| `crowned` | 55 | 0 | 0 | 55 |  |
| `discovery:crystal` | 0 | 9 | 0 | 9 |  |
| `discovery:legend` | 0 | 160 | 0 | 75 |  |
| `discovery:relic` | 0 | 5 | 0 | 5 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 1 | 0 | 1 |  |
| `discovery:the_charter` | 0 | 34 | 0 | 29 |  |
| `discovery:the_ledger` | 0 | 468 | 0 | 99 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 458 | 0 | 99 |  |
| `discovery:trade_ledger` | 0 | 202 | 0 | 86 |  |
| `discovery:written_law` | 0 | 134 | 0 | 62 |  |
| `escort_sworn` | 0 | 386 | 167 | 85 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 0 | 0 | 0 | **non arriva mai** |
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
| `renowned` | 0 | 354 | 0 | 100 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 8 | 0 | 8 |  |
| `took_by_hand` | 0 | 1 | 0 | 1 |  |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 4 | 0 | 4 |  |
| `watched` | 0 | 26 | 0 | 21 |  |
| `water_rights` | 0 | 3 | 0 | 3 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**48 segni: 41 arrivano sul tavolo, 7 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 24 | 0 | 24 |  |
| `betrayal_spoken` | 0 | 3 | 0 | 2 |  |
| `burden_shared` | 0 | 80 | 0 | 56 |  |
| `charter_for_all` | 0 | 2 | 0 | 2 |  |
| `charter_written` | 0 | 47 | 0 | 30 |  |
| `crown_dispossessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `crown_divided` | 0 | 26 | 0 | 26 |  |
| `crystal_exploited` | 0 | 7 | 0 | 6 |  |
| `crystal_measured` | 0 | 17 | 0 | 17 |  |
| `debt_called` | 0 | 303 | 0 | 93 |  |
| `debt_forgiven` | 0 | 151 | 0 | 70 |  |
| `debt_staggered` | 0 | 8 | 0 | 7 |  |
| `descent_witnessed` | 0 | 1 | 0 | 1 |  |
| `distribution_audited` | 0 | 2 | 0 | 2 |  |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 37 | 0 | 34 |  |
| `grain_requisitioned` | 0 | 28 | 0 | 24 |  |
| `heir_named` | 0 | 83 | 0 | 56 |  |
| `knowledge_shared` | 0 | 136 | 0 | 64 |  |
| `ledger_public` | 0 | 194 | 0 | 85 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 2 | 0 | 2 |  |
| `mountain_forgotten` | 0 | 1 | 0 | 1 |  |
| `nahr_settled` | 0 | 10 | 0 | 10 |  |
| `no_charter` | 0 | 1 | 0 | 1 |  |
| `oath_broken` | 0 | 3 | 13 | 3 |  |
| `order_restored` | 0 | 236 | 0 | 99 |  |
| `petition_heard` | 0 | 3 | 0 | 3 |  |
| `price_in_lives` | 0 | 9 | 0 | 8 |  |
| `question_unresolved` | 0 | 52 | 41 | 28 |  |
| `quota_guaranteed` | 0 | 13 | 0 | 13 |  |
| `relic_buried` | 0 | 16 | 0 | 16 |  |
| `relic_recorded` | 0 | 2 | 0 | 2 |  |
| `relic_shown` | 0 | 5 | 0 | 5 |  |
| `rumour_running` | 0 | 13 | 0 | 12 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `study_supervised` | 0 | 2 | 0 | 2 |  |
| `succession_by_law` | 0 | 30 | 0 | 25 |  |
| `succession_settled` | 0 | 11 | 0 | 6 |  |
| `succession_witnessed` | 0 | 11 | 0 | 6 |  |
| `toll_shared` | 0 | 46 | 0 | 39 |  |
| `valley_sealed` | 0 | 1 | 0 | 1 |  |
| `water_moves` | 0 | 23 | 0 | 19 |  |
| `water_priced` | 0 | 3 | 0 | 3 |  |
| `water_shared` | 0 | 2 | 0 | 2 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **40 su 171**.

| segno | dove starebbe |
|---|---|
| `crown_dispossessed` | un gettone sul bordo della mappa |
| `discovery:shared_record` | sulla scheda della casa |
| `discovery:the_measure` | sulla scheda della casa |
| `dragon_slain` | un gettone sul bordo della mappa |
| `failed_proposal` | sulla scheda della casa |
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
| `scar:divided_seal` | un dischetto rotondo |
| `scar:dragonfall` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `twice_uprooted` | sulla scheda della casa |
