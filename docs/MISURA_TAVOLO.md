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

**25 segni: 19 arrivano sul tavolo, 5 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 1 | 0 | 1 |  |
| `place:cursed_wood` | 0 | 2 | 0 | 1 |  |
| `place:dry_spring` | 0 | 1 | 0 | 0 |  |
| `place:forest` | 98 | 191 | 0 | 98 |  |
| `place:low_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:open_site` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:pass` | 64 | 64 | 0 | 63 |  |
| `place:sleeping_site` | 85 | 121 | 0 | 86 |  |
| `place:spring` | 88 | 122 | 0 | 88 |  |
| `place:stripped_site` | 0 | 1 | 0 | 1 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 2 | 0 | 2 |  |
| `settlement:market` | 0 | 5 | 0 | 5 |  |
| `settlement:town` | 0 | 9 | 0 | 9 |  |
| `settlement:village` | 33 | 75 | 3 | 33 |  |
| `structure:archive` | 22 | 188 | 11 | 47 |  |
| `structure:canal` | 0 | 22 | 2 | 10 |  |
| `structure:castle` | 0 | 53 | 0 | 43 |  |
| `structure:granary` | 0 | 262 | 10 | 74 |  |
| `structure:library` | 0 | 23 | 0 | 22 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 0 | 5 | 0 | **non arriva mai** |
| `structure:tollgate` | 0 | 346 | 7 | 91 |  |
| `structure:watchtower` | 100 | 346 | 121 | 85 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 6 | 1 | 5 |  |
| `condition:contested` | 0 | 492 | 211 | 91 |  |
| `condition:cut_off` | 0 | 137 | 288 | 41 |  |
| `condition:emptied` | 0 | 21 | 6 | 14 |  |
| `condition:exploited` | 0 | 5 | 0 | 4 |  |
| `condition:guarded` | 0 | 84 | 21 | 48 |  |
| `condition:indebted` | 0 | 181 | 52 | 78 |  |
| `condition:lean` | 0 | 51 | 110 | 25 |  |
| `condition:mourning` | 0 | 21 | 53 | 17 |  |
| `condition:plundered` | 0 | 11 | 19 | 10 |  |
| `condition:rationed` | 0 | 286 | 240 | 64 |  |
| `condition:starving` | 0 | 19 | 136 | 9 |  |
| `condition:unrest` | 0 | 345 | 247 | 77 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 12 arrivano sul tavolo, 1 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 41 | 0 | 35 |  |
| `scar:broken_bridge` | 0 | 3 | 65 | 3 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 2 | 0 | 2 |  |
| `scar:burned_records` | 0 | 11 | 0 | 11 |  |
| `scar:changed_hands` | 0 | 57 | 0 | 45 |  |
| `scar:divided_seal` | 0 | 1 | 0 | 1 |  |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 16 | 0 | 14 |  |
| `scar:open_wound` | 0 | 4 | 0 | 4 |  |
| `scar:plundered` | 0 | 20 | 0 | 18 |  |
| `scar:sealed_border` | 0 | 13 | 0 | 11 |  |
| `scar:the_empty_chair` | 0 | 47 | 0 | 39 |  |
| `scar:unanswered` | 0 | 70 | 122 | 39 | **tolta piu' volte di quante si posa** |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 27 arrivano sul tavolo, 29 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 20 | 0 | 17 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 1 | 0 | 1 |  |
| `crowned` | 55 | 0 | 1 | 55 |  |
| `discovery:crystal` | 0 | 8 | 0 | 8 |  |
| `discovery:legend` | 0 | 155 | 0 | 73 |  |
| `discovery:relic` | 0 | 7 | 0 | 4 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 1 | 0 | 1 |  |
| `discovery:the_charter` | 0 | 34 | 0 | 32 |  |
| `discovery:the_ledger` | 0 | 506 | 0 | 98 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 447 | 0 | 100 |  |
| `discovery:trade_ledger` | 0 | 183 | 0 | 79 |  |
| `discovery:written_law` | 0 | 127 | 0 | 62 |  |
| `escort_sworn` | 0 | 413 | 166 | 89 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 1 | 0 | 1 |  |
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
| `renowned` | 0 | 350 | 0 | 98 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 3 | 0 | 3 |  |
| `took_by_hand` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 1 | 0 | 1 |  |
| `watched` | 0 | 24 | 0 | 18 |  |
| `water_rights` | 0 | 1 | 0 | 1 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**48 segni: 35 arrivano sul tavolo, 13 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 21 | 0 | 20 |  |
| `betrayal_spoken` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `burden_shared` | 0 | 87 | 0 | 59 |  |
| `charter_for_all` | 0 | 4 | 0 | 4 |  |
| `charter_written` | 0 | 46 | 0 | 33 |  |
| `crown_dispossessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `crown_divided` | 0 | 22 | 0 | 22 |  |
| `crystal_exploited` | 0 | 6 | 0 | 6 |  |
| `crystal_measured` | 0 | 19 | 0 | 19 |  |
| `debt_called` | 0 | 337 | 0 | 96 |  |
| `debt_forgiven` | 0 | 159 | 0 | 73 |  |
| `debt_staggered` | 0 | 5 | 0 | 5 |  |
| `descent_witnessed` | 0 | 1 | 0 | 1 |  |
| `distribution_audited` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 35 | 0 | 28 |  |
| `grain_requisitioned` | 0 | 26 | 0 | 18 |  |
| `heir_named` | 0 | 133 | 0 | 76 |  |
| `knowledge_shared` | 0 | 130 | 0 | 65 |  |
| `ledger_public` | 0 | 182 | 0 | 84 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `mountain_forgotten` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `nahr_settled` | 0 | 10 | 0 | 10 |  |
| `no_charter` | 0 | 2 | 0 | 2 |  |
| `oath_broken` | 0 | 2 | 12 | 2 |  |
| `order_restored` | 0 | 264 | 0 | 99 |  |
| `petition_heard` | 0 | 1 | 0 | 1 |  |
| `price_in_lives` | 0 | 14 | 0 | 11 |  |
| `question_unresolved` | 0 | 41 | 34 | 23 |  |
| `quota_guaranteed` | 0 | 13 | 0 | 10 |  |
| `relic_buried` | 0 | 15 | 0 | 15 |  |
| `relic_recorded` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_shown` | 0 | 7 | 0 | 4 |  |
| `rumour_running` | 0 | 9 | 0 | 9 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `study_supervised` | 0 | 2 | 0 | 2 |  |
| `succession_by_law` | 0 | 29 | 0 | 22 |  |
| `succession_settled` | 0 | 10 | 0 | 6 |  |
| `succession_witnessed` | 0 | 10 | 0 | 6 |  |
| `toll_shared` | 0 | 46 | 0 | 37 |  |
| `valley_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_moves` | 0 | 26 | 0 | 17 |  |
| `water_priced` | 0 | 1 | 0 | 1 |  |
| `water_shared` | 0 | 2 | 0 | 2 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **48 su 171**.

| segno | dove starebbe |
|---|---|
| `betrayal_spoken` | un gettone sul bordo della mappa |
| `crown_dispossessed` | un gettone sul bordo della mappa |
| `discovery:shared_record` | sulla scheda della casa |
| `discovery:the_measure` | sulla scheda della casa |
| `distribution_audited` | un gettone sul bordo della mappa |
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
| `mine_sealed` | un gettone sul bordo della mappa |
| `mountain_forgotten` | un gettone sul bordo della mappa |
| `place:low_spring` | uno spazio sulla tessera |
| `place:open_site` | uno spazio sulla tessera |
| `relic_recorded` | un gettone sul bordo della mappa |
| `scar:dragonfall` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `structure:sealed` | uno spazio sulla tessera |
| `took_by_hand` | sulla scheda della casa |
| `twice_uprooted` | sulla scheda della casa |
| `valley_sealed` | un gettone sul bordo della mappa |
