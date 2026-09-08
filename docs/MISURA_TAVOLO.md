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
| `place:cursed_wood` | 0 | 5 | 0 | 2 |  |
| `place:dry_spring` | 0 | 1 | 0 | 1 |  |
| `place:forest` | 98 | 198 | 0 | 98 |  |
| `place:low_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:open_site` | 0 | 13 | 0 | 9 |  |
| `place:pass` | 64 | 64 | 0 | 62 |  |
| `place:sleeping_site` | 85 | 121 | 0 | 78 |  |
| `place:spring` | 88 | 122 | 0 | 87 |  |
| `place:stripped_site` | 0 | 5 | 0 | 5 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 5 | 0 | 5 |  |
| `settlement:market` | 0 | 6 | 0 | 6 |  |
| `settlement:town` | 0 | 11 | 0 | 11 |  |
| `settlement:village` | 33 | 84 | 4 | 36 |  |
| `structure:archive` | 22 | 172 | 5 | 42 |  |
| `structure:canal` | 0 | 58 | 40 | 24 |  |
| `structure:castle` | 0 | 49 | 0 | 43 |  |
| `structure:granary` | 0 | 303 | 42 | 78 |  |
| `structure:library` | 0 | 15 | 0 | 15 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 17 | 17 | 15 |  |
| `structure:tollgate` | 0 | 376 | 8 | 94 |  |
| `structure:watchtower` | 100 | 334 | 70 | 85 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 21 | 1 | 17 |  |
| `condition:contested` | 0 | 371 | 121 | 91 |  |
| `condition:cut_off` | 0 | 163 | 249 | 60 |  |
| `condition:emptied` | 0 | 41 | 3 | 33 |  |
| `condition:exploited` | 0 | 21 | 0 | 15 |  |
| `condition:guarded` | 0 | 77 | 8 | 55 |  |
| `condition:indebted` | 0 | 277 | 33 | 95 |  |
| `condition:lean` | 0 | 145 | 148 | 48 |  |
| `condition:mourning` | 0 | 50 | 40 | 35 |  |
| `condition:plundered` | 0 | 47 | 12 | 32 |  |
| `condition:rationed` | 0 | 198 | 133 | 66 |  |
| `condition:starving` | 0 | 83 | 161 | 46 |  |
| `condition:unrest` | 0 | 330 | 121 | 90 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 12 arrivano sul tavolo, 1 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 60 | 0 | 47 |  |
| `scar:broken_bridge` | 0 | 4 | 32 | 4 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 1 | 0 | 1 |  |
| `scar:burned_records` | 0 | 5 | 0 | 5 |  |
| `scar:changed_hands` | 0 | 39 | 0 | 29 |  |
| `scar:divided_seal` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:dragonfall` | 0 | 5 | 0 | 4 |  |
| `scar:emptied` | 0 | 16 | 0 | 14 |  |
| `scar:open_wound` | 0 | 11 | 0 | 11 |  |
| `scar:plundered` | 0 | 32 | 0 | 29 |  |
| `scar:sealed_border` | 0 | 9 | 0 | 9 |  |
| `scar:the_empty_chair` | 0 | 16 | 0 | 15 |  |
| `scar:unanswered` | 0 | 42 | 58 | 30 | **tolta piu' volte di quante si posa** |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 27 arrivano sul tavolo, 29 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 22 | 0 | 19 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 5 | 0 | 5 |  |
| `crowned` | 55 | 0 | 4 | 54 |  |
| `discovery:crystal` | 0 | 17 | 0 | 16 |  |
| `discovery:legend` | 0 | 168 | 0 | 81 |  |
| `discovery:relic` | 0 | 33 | 0 | 24 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 19 | 0 | 18 |  |
| `discovery:the_charter` | 0 | 44 | 0 | 33 |  |
| `discovery:the_ledger` | 0 | 283 | 0 | 94 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 343 | 0 | 98 |  |
| `discovery:trade_ledger` | 0 | 197 | 0 | 79 |  |
| `discovery:written_law` | 0 | 158 | 0 | 70 |  |
| `escort_sworn` | 0 | 224 | 13 | 92 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `free_cities` | 48 | 0 | 0 | 48 |  |
| `guild` | 46 | 0 | 0 | 46 |  |
| `hard_bargain` | 0 | 6 | 0 | 6 |  |
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
| `renowned` | 0 | 65 | 0 | 43 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 18 | 0 | 15 |  |
| `took_by_hand` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 2 | 0 | 2 |  |
| `watched` | 0 | 22 | 0 | 20 |  |
| `water_rights` | 0 | 1 | 0 | 1 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**52 segni: 45 arrivano sul tavolo, 7 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 19 | 0 | 18 |  |
| `amnesty_granted` | 0 | 6 | 0 | 6 |  |
| `betrayal_spoken` | 0 | 15 | 0 | 14 |  |
| `burden_shared` | 0 | 80 | 0 | 56 |  |
| `charter_for_all` | 0 | 3 | 0 | 3 |  |
| `charter_temporary` | 0 | 15 | 0 | 14 |  |
| `charter_written` | 0 | 56 | 0 | 35 |  |
| `crown_dispossessed` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `crown_divided` | 0 | 13 | 0 | 13 |  |
| `crystal_exploited` | 0 | 25 | 0 | 21 |  |
| `crystal_measured` | 0 | 19 | 0 | 19 |  |
| `debt_called` | 0 | 322 | 0 | 97 |  |
| `debt_forgiven` | 0 | 136 | 0 | 78 |  |
| `debt_staggered` | 0 | 6 | 0 | 6 |  |
| `descent_witnessed` | 0 | 19 | 0 | 18 |  |
| `distribution_audited` | 0 | 5 | 0 | 5 |  |
| `dragon_slain` | 0 | 5 | 0 | 4 |  |
| `faith_established` | 0 | 36 | 0 | 31 |  |
| `grain_requisitioned` | 0 | 12 | 0 | 10 |  |
| `heir_named` | 0 | 117 | 0 | 57 |  |
| `knowledge_shared` | 0 | 165 | 0 | 73 |  |
| `ledger_public` | 0 | 173 | 0 | 83 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 10 | 7 | 9 |  |
| `mountain_forgotten` | 0 | 9 | 0 | 9 |  |
| `nahr_settled` | 0 | 23 | 0 | 23 |  |
| `no_charter` | 0 | 3 | 0 | 3 |  |
| `oath_broken` | 0 | 4 | 14 | 4 |  |
| `order_restored` | 0 | 10 | 0 | 10 |  |
| `parley_held` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `petition_heard` | 0 | 10 | 0 | 9 |  |
| `price_in_lives` | 0 | 6 | 0 | 4 |  |
| `question_unresolved` | 0 | 46 | 19 | 34 |  |
| `quota_guaranteed` | 0 | 3 | 0 | 3 |  |
| `relic_buried` | 0 | 16 | 0 | 16 |  |
| `relic_recorded` | 0 | 2 | 0 | 2 |  |
| `relic_shown` | 0 | 6 | 0 | 6 |  |
| `rumour_running` | 0 | 24 | 0 | 21 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `someone_paid` | 0 | 2 | 0 | 2 |  |
| `study_supervised` | 0 | 24 | 0 | 23 |  |
| `succession_by_law` | 0 | 30 | 0 | 26 |  |
| `succession_settled` | 0 | 4 | 0 | 4 |  |
| `succession_witnessed` | 0 | 4 | 0 | 4 |  |
| `toll_shared` | 0 | 18 | 0 | 17 |  |
| `valley_sealed` | 0 | 2 | 0 | 2 |  |
| `water_moves` | 0 | 56 | 0 | 43 |  |
| `water_priced` | 0 | 1 | 0 | 1 |  |
| `water_shared` | 0 | 1 | 0 | 1 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **40 su 175**.

| segno | dove starebbe |
|---|---|
| `crown_dispossessed` | un gettone sul bordo della mappa |
| `discovery:shared_record` | sulla scheda della casa |
| `discovery:the_measure` | sulla scheda della casa |
| `failed_proposal` | sulla scheda della casa |
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
| `place:low_spring` | uno spazio sulla tessera |
| `scar:divided_seal` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `took_by_hand` | sulla scheda della casa |
| `twice_uprooted` | sulla scheda della casa |
