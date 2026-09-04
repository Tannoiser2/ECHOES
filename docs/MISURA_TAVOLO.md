# ECHOES — quali segni arrivano sul tavolo, posto per posto

<!-- FILE GENERATO — si rifa' con `tools/run_table_survey.sh`. -->

Ogni segno che sul tavolo ha un pezzo di cartone — i **175** con un posto
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

**25 segni: 20 arrivano sul tavolo, 4 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:cursed_wood` | 0 | 1 | 0 | 0 |  |
| `place:dry_spring` | 0 | 3 | 0 | 3 |  |
| `place:forest` | 98 | 194 | 0 | 98 |  |
| `place:low_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:open_site` | 0 | 7 | 0 | 4 |  |
| `place:pass` | 64 | 64 | 0 | 64 |  |
| `place:sleeping_site` | 85 | 122 | 0 | 87 |  |
| `place:spring` | 88 | 122 | 0 | 87 |  |
| `place:stripped_site` | 0 | 2 | 0 | 2 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 4 | 0 | 4 |  |
| `settlement:market` | 0 | 3 | 0 | 3 |  |
| `settlement:town` | 0 | 8 | 0 | 8 |  |
| `settlement:village` | 33 | 78 | 7 | 36 |  |
| `structure:archive` | 22 | 132 | 12 | 37 |  |
| `structure:canal` | 0 | 48 | 33 | 19 |  |
| `structure:castle` | 0 | 69 | 0 | 57 |  |
| `structure:granary` | 0 | 304 | 35 | 82 |  |
| `structure:library` | 0 | 16 | 0 | 14 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 17 | 15 | 14 |  |
| `structure:tollgate` | 0 | 221 | 9 | 63 |  |
| `structure:watchtower` | 100 | 321 | 67 | 80 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 35 | 0 | 25 |  |
| `condition:contested` | 0 | 463 | 68 | 97 |  |
| `condition:cut_off` | 0 | 129 | 160 | 64 |  |
| `condition:emptied` | 0 | 35 | 0 | 34 |  |
| `condition:exploited` | 0 | 4 | 0 | 4 |  |
| `condition:guarded` | 0 | 30 | 0 | 27 |  |
| `condition:indebted` | 0 | 131 | 2 | 68 |  |
| `condition:lean` | 0 | 137 | 136 | 57 |  |
| `condition:mourning` | 0 | 12 | 13 | 12 |  |
| `condition:plundered` | 0 | 55 | 7 | 43 |  |
| `condition:rationed` | 0 | 104 | 75 | 55 |  |
| `condition:starving` | 0 | 92 | 140 | 52 |  |
| `condition:unrest` | 0 | 301 | 43 | 90 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 9 arrivano sul tavolo, 4 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 54 | 0 | 47 |  |
| `scar:broken_bridge` | 0 | 3 | 18 | 3 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 2 | 0 | 2 |  |
| `scar:burned_records` | 0 | 12 | 0 | 11 |  |
| `scar:changed_hands` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:divided_seal` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 18 | 0 | 18 |  |
| `scar:open_wound` | 0 | 10 | 0 | 10 |  |
| `scar:plundered` | 0 | 10 | 0 | 10 |  |
| `scar:sealed_border` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:the_empty_chair` | 0 | 4 | 0 | 4 |  |
| `scar:unanswered` | 0 | 7 | 16 | 6 | **tolta piu' volte di quante si posa** |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 27 arrivano sul tavolo, 29 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 12 | 0 | 11 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 3 | 0 | 3 |  |
| `crowned` | 55 | 0 | 1 | 55 |  |
| `discovery:crystal` | 0 | 23 | 0 | 21 |  |
| `discovery:legend` | 0 | 175 | 0 | 83 |  |
| `discovery:relic` | 0 | 17 | 0 | 13 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 5 | 0 | 5 |  |
| `discovery:the_charter` | 0 | 19 | 0 | 18 |  |
| `discovery:the_ledger` | 0 | 309 | 0 | 96 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 389 | 0 | 97 |  |
| `discovery:trade_ledger` | 0 | 225 | 0 | 85 |  |
| `discovery:written_law` | 0 | 165 | 0 | 72 |  |
| `escort_sworn` | 0 | 183 | 0 | 87 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 5 | 0 | 4 |  |
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
| `renowned` | 0 | 156 | 0 | 78 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 32 | 0 | 26 |  |
| `took_by_hand` | 0 | 6 | 0 | 5 |  |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `watched` | 0 | 5 | 0 | 5 |  |
| `water_rights` | 0 | 3 | 0 | 3 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**52 segni: 35 arrivano sul tavolo, 17 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 9 | 0 | 8 |  |
| `amnesty_granted` | 0 | 1 | 0 | 1 |  |
| `betrayal_spoken` | 0 | 20 | 0 | 19 |  |
| `burden_shared` | 0 | 81 | 0 | 52 |  |
| `charter_for_all` | 0 | 1 | 0 | 1 |  |
| `charter_temporary` | 0 | 10 | 0 | 8 |  |
| `charter_written` | 0 | 25 | 0 | 20 |  |
| `crown_dispossessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `crown_divided` | 0 | 5 | 0 | 5 |  |
| `crystal_exploited` | 0 | 17 | 0 | 17 |  |
| `crystal_measured` | 0 | 14 | 0 | 14 |  |
| `debt_called` | 0 | 215 | 0 | 86 |  |
| `debt_forgiven` | 0 | 118 | 0 | 66 |  |
| `debt_staggered` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `descent_witnessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `distribution_audited` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 14 | 0 | 11 |  |
| `grain_requisitioned` | 0 | 14 | 0 | 12 |  |
| `heir_named` | 0 | 87 | 0 | 45 |  |
| `knowledge_shared` | 0 | 174 | 0 | 73 |  |
| `ledger_public` | 0 | 153 | 0 | 74 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 8 | 0 | 8 |  |
| `mountain_forgotten` | 0 | 2 | 0 | 2 |  |
| `nahr_settled` | 0 | 1 | 0 | 1 |  |
| `no_charter` | 0 | 1 | 0 | 1 |  |
| `oath_broken` | 0 | 11 | 3 | 9 |  |
| `order_restored` | 0 | 86 | 0 | 59 |  |
| `parley_held` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `petition_heard` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `price_in_lives` | 0 | 1 | 0 | 1 |  |
| `question_unresolved` | 0 | 90 | 9 | 69 |  |
| `quota_guaranteed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_buried` | 0 | 12 | 0 | 8 |  |
| `relic_recorded` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `relic_shown` | 0 | 2 | 0 | 2 |  |
| `rumour_running` | 0 | 33 | 0 | 27 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `someone_paid` | 0 | 2 | 0 | 2 |  |
| `study_supervised` | 0 | 7 | 0 | 7 |  |
| `succession_by_law` | 0 | 15 | 0 | 15 |  |
| `succession_settled` | 0 | 7 | 0 | 6 |  |
| `succession_witnessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `toll_shared` | 0 | 24 | 0 | 21 |  |
| `valley_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `water_moves` | 0 | 43 | 0 | 31 |  |
| `water_priced` | 0 | 3 | 0 | 3 |  |
| `water_shared` | 0 | 0 | 0 | 0 | **non arriva mai** |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **54 su 175**.

| segno | dove starebbe |
|---|---|
| `crown_dispossessed` | un gettone sul bordo della mappa |
| `debt_staggered` | un gettone sul bordo della mappa |
| `descent_witnessed` | un gettone sul bordo della mappa |
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
| `parley_held` | un gettone sul bordo della mappa |
| `petition_heard` | un gettone sul bordo della mappa |
| `place:collapsed_pass` | uno spazio sulla tessera |
| `place:low_spring` | uno spazio sulla tessera |
| `quota_guaranteed` | un gettone sul bordo della mappa |
| `relic_recorded` | un gettone sul bordo della mappa |
| `scar:changed_hands` | un dischetto rotondo |
| `scar:divided_seal` | un dischetto rotondo |
| `scar:dragonfall` | un dischetto rotondo |
| `scar:sealed_border` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `succession_witnessed` | un gettone sul bordo della mappa |
| `twice_uprooted` | sulla scheda della casa |
| `uprooted` | sulla scheda della casa |
| `valley_sealed` | un gettone sul bordo della mappa |
| `water_shared` | un gettone sul bordo della mappa |
