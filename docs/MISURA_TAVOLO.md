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

**25 segni: 21 arrivano sul tavolo, 3 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 2 | 0 | 2 |  |
| `place:cursed_wood` | 0 | 6 | 0 | 3 |  |
| `place:dry_spring` | 0 | 4 | 0 | 1 |  |
| `place:forest` | 98 | 192 | 0 | 98 |  |
| `place:low_spring` | 0 | 1 | 0 | 1 |  |
| `place:open_site` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:pass` | 64 | 64 | 0 | 62 |  |
| `place:sleeping_site` | 85 | 119 | 0 | 84 |  |
| `place:spring` | 88 | 122 | 0 | 87 |  |
| `place:stripped_site` | 0 | 2 | 0 | 2 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 5 | 0 | 4 |  |
| `settlement:market` | 0 | 5 | 0 | 5 |  |
| `settlement:town` | 0 | 7 | 0 | 7 |  |
| `settlement:village` | 33 | 71 | 7 | 31 |  |
| `structure:archive` | 22 | 179 | 11 | 48 |  |
| `structure:canal` | 0 | 35 | 36 | 18 |  |
| `structure:castle` | 0 | 54 | 0 | 50 |  |
| `structure:granary` | 0 | 337 | 44 | 86 |  |
| `structure:library` | 0 | 10 | 0 | 10 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 3 | 12 | 3 |  |
| `structure:tollgate` | 0 | 368 | 11 | 93 |  |
| `structure:watchtower` | 100 | 333 | 67 | 85 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 15 | 3 | 11 |  |
| `condition:contested` | 0 | 369 | 127 | 92 |  |
| `condition:cut_off` | 0 | 156 | 260 | 57 |  |
| `condition:emptied` | 0 | 40 | 5 | 32 |  |
| `condition:exploited` | 0 | 10 | 0 | 9 |  |
| `condition:guarded` | 0 | 80 | 19 | 50 |  |
| `condition:indebted` | 0 | 314 | 34 | 95 |  |
| `condition:lean` | 0 | 146 | 140 | 55 |  |
| `condition:mourning` | 0 | 39 | 48 | 25 |  |
| `condition:plundered` | 0 | 50 | 17 | 36 |  |
| `condition:rationed` | 0 | 159 | 162 | 60 |  |
| `condition:starving` | 0 | 91 | 193 | 51 |  |
| `condition:unrest` | 0 | 367 | 115 | 89 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 12 arrivano sul tavolo, 1 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 62 | 0 | 50 |  |
| `scar:broken_bridge` | 0 | 4 | 26 | 4 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 1 | 0 | 1 |  |
| `scar:burned_records` | 0 | 11 | 0 | 11 |  |
| `scar:changed_hands` | 0 | 67 | 0 | 44 |  |
| `scar:divided_seal` | 0 | 1 | 0 | 1 |  |
| `scar:dragonfall` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:emptied` | 0 | 20 | 0 | 17 |  |
| `scar:open_wound` | 0 | 5 | 0 | 5 |  |
| `scar:plundered` | 0 | 27 | 0 | 22 |  |
| `scar:sealed_border` | 0 | 6 | 0 | 6 |  |
| `scar:the_empty_chair` | 0 | 39 | 0 | 32 |  |
| `scar:unanswered` | 0 | 58 | 52 | 44 |  |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 30 arrivano sul tavolo, 26 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 21 | 0 | 19 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 1 | 0 | 1 |  |
| `crowned` | 55 | 0 | 6 | 55 |  |
| `discovery:crystal` | 0 | 10 | 0 | 10 |  |
| `discovery:legend` | 0 | 146 | 0 | 72 |  |
| `discovery:relic` | 0 | 29 | 0 | 22 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 4 | 0 | 4 |  |
| `discovery:the_charter` | 0 | 43 | 0 | 29 |  |
| `discovery:the_ledger` | 0 | 296 | 0 | 97 |  |
| `discovery:the_measure` | 0 | 1 | 0 | 1 |  |
| `discovery:the_omen` | 0 | 322 | 0 | 99 |  |
| `discovery:trade_ledger` | 0 | 192 | 0 | 77 |  |
| `discovery:written_law` | 0 | 164 | 0 | 71 |  |
| `escort_sworn` | 0 | 233 | 10 | 92 |  |
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
| `renowned` | 0 | 60 | 0 | 41 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 6 | 0 | 6 |  |
| `took_by_hand` | 0 | 1 | 0 | 1 |  |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 3 | 0 | 3 |  |
| `watched` | 0 | 14 | 0 | 12 |  |
| `water_rights` | 0 | 4 | 0 | 2 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**52 segni: 43 arrivano sul tavolo, 9 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 16 | 0 | 16 |  |
| `amnesty_granted` | 0 | 1 | 0 | 1 |  |
| `betrayal_spoken` | 0 | 24 | 0 | 20 |  |
| `burden_shared` | 0 | 105 | 0 | 60 |  |
| `charter_for_all` | 0 | 3 | 0 | 3 |  |
| `charter_temporary` | 0 | 10 | 0 | 10 |  |
| `charter_written` | 0 | 54 | 0 | 31 |  |
| `crown_dispossessed` | 0 | 1 | 0 | 1 |  |
| `crown_divided` | 0 | 22 | 0 | 21 |  |
| `crystal_exploited` | 0 | 15 | 0 | 13 |  |
| `crystal_measured` | 0 | 17 | 0 | 16 |  |
| `debt_called` | 0 | 311 | 0 | 92 |  |
| `debt_forgiven` | 0 | 129 | 0 | 74 |  |
| `debt_staggered` | 0 | 5 | 0 | 5 |  |
| `descent_witnessed` | 0 | 4 | 0 | 4 |  |
| `distribution_audited` | 0 | 4 | 0 | 4 |  |
| `dragon_slain` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `faith_established` | 0 | 34 | 0 | 31 |  |
| `grain_requisitioned` | 0 | 14 | 0 | 12 |  |
| `heir_named` | 0 | 117 | 0 | 60 |  |
| `knowledge_shared` | 0 | 169 | 0 | 71 |  |
| `ledger_public` | 0 | 211 | 0 | 82 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `mountain_forgotten` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `nahr_settled` | 0 | 15 | 0 | 15 |  |
| `no_charter` | 0 | 1 | 0 | 1 |  |
| `oath_broken` | 0 | 7 | 6 | 7 |  |
| `order_restored` | 0 | 19 | 0 | 19 |  |
| `parley_held` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `petition_heard` | 0 | 10 | 0 | 8 |  |
| `price_in_lives` | 0 | 6 | 0 | 6 |  |
| `question_unresolved` | 0 | 48 | 25 | 29 |  |
| `quota_guaranteed` | 0 | 14 | 0 | 13 |  |
| `relic_buried` | 0 | 16 | 0 | 15 |  |
| `relic_recorded` | 0 | 2 | 0 | 2 |  |
| `relic_shown` | 0 | 5 | 0 | 4 |  |
| `rumour_running` | 0 | 14 | 0 | 12 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `someone_paid` | 0 | 2 | 0 | 2 |  |
| `study_supervised` | 0 | 6 | 0 | 6 |  |
| `succession_by_law` | 0 | 46 | 0 | 41 |  |
| `succession_settled` | 0 | 8 | 0 | 6 |  |
| `succession_witnessed` | 0 | 8 | 0 | 6 |  |
| `toll_shared` | 0 | 28 | 0 | 22 |  |
| `valley_sealed` | 0 | 1 | 0 | 1 |  |
| `water_moves` | 0 | 39 | 0 | 30 |  |
| `water_priced` | 0 | 4 | 0 | 2 |  |
| `water_shared` | 0 | 1 | 0 | 1 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **39 su 175**.

| segno | dove starebbe |
|---|---|
| `discovery:shared_record` | sulla scheda della casa |
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
| `mine_sealed` | un gettone sul bordo della mappa |
| `mountain_forgotten` | un gettone sul bordo della mappa |
| `parley_held` | un gettone sul bordo della mappa |
| `place:open_site` | uno spazio sulla tessera |
| `scar:dragonfall` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `twice_uprooted` | sulla scheda della casa |
