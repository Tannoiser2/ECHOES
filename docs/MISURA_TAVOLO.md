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

**25 segni: 21 arrivano sul tavolo, 3 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `place:collapsed_pass` | 0 | 2 | 0 | 0 |  |
| `place:cursed_wood` | 0 | 5 | 0 | 2 |  |
| `place:dry_spring` | 0 | 1 | 0 | 1 |  |
| `place:forest` | 98 | 191 | 0 | 98 |  |
| `place:low_spring` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `place:open_site` | 0 | 1 | 0 | 1 |  |
| `place:pass` | 64 | 64 | 0 | 64 |  |
| `place:sleeping_site` | 85 | 120 | 0 | 85 |  |
| `place:spring` | 88 | 122 | 0 | 87 |  |
| `place:stripped_site` | 0 | 1 | 0 | 1 |  |
| `settlement:$proponent` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `settlement:city` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `settlement:march` | 0 | 8 | 0 | 7 |  |
| `settlement:market` | 0 | 6 | 0 | 5 |  |
| `settlement:town` | 0 | 8 | 0 | 8 |  |
| `settlement:village` | 33 | 78 | 4 | 38 |  |
| `structure:archive` | 22 | 199 | 11 | 50 |  |
| `structure:canal` | 0 | 31 | 3 | 12 |  |
| `structure:castle` | 0 | 55 | 0 | 49 |  |
| `structure:granary` | 0 | 301 | 7 | 80 |  |
| `structure:library` | 0 | 16 | 0 | 16 |  |
| `structure:palace` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `structure:sealed` | 0 | 2 | 11 | 2 |  |
| `structure:tollgate` | 0 | 362 | 7 | 98 |  |
| `structure:watchtower` | 100 | 340 | 82 | 85 |  |

## un gettone accanto alla tessera

lo stato di adesso: si mette e si toglie.

**13 segni: 13 arrivano sul tavolo, 0 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `condition:abandoned` | 0 | 10 | 1 | 9 |  |
| `condition:contested` | 0 | 446 | 164 | 91 |  |
| `condition:cut_off` | 0 | 149 | 242 | 47 |  |
| `condition:emptied` | 0 | 31 | 3 | 23 |  |
| `condition:exploited` | 0 | 8 | 0 | 7 |  |
| `condition:guarded` | 0 | 82 | 17 | 55 |  |
| `condition:indebted` | 0 | 150 | 28 | 82 |  |
| `condition:lean` | 0 | 53 | 101 | 38 |  |
| `condition:mourning` | 0 | 12 | 31 | 8 |  |
| `condition:plundered` | 0 | 23 | 15 | 18 |  |
| `condition:rationed` | 0 | 231 | 176 | 67 |  |
| `condition:starving` | 0 | 45 | 187 | 28 |  |
| `condition:unrest` | 0 | 339 | 113 | 94 |  |

## un dischetto rotondo

le Cicatrici. Si tolgono di rado, e serve un pezzo che sappia farlo.

**13 segni: 12 arrivano sul tavolo, 1 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `scar:abandoned` | 0 | 49 | 0 | 42 |  |
| `scar:broken_bridge` | 0 | 5 | 50 | 5 | **tolta piu' volte di quante si posa** |
| `scar:broken_word` | 0 | 1 | 0 | 1 |  |
| `scar:burned_records` | 0 | 11 | 0 | 11 |  |
| `scar:changed_hands` | 0 | 52 | 0 | 40 |  |
| `scar:divided_seal` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `scar:dragonfall` | 0 | 1 | 0 | 1 |  |
| `scar:emptied` | 0 | 12 | 0 | 11 |  |
| `scar:open_wound` | 0 | 6 | 0 | 6 |  |
| `scar:plundered` | 0 | 18 | 0 | 18 |  |
| `scar:sealed_border` | 0 | 12 | 0 | 10 |  |
| `scar:the_empty_chair` | 0 | 46 | 0 | 39 |  |
| `scar:unanswered` | 0 | 61 | 41 | 41 |  |

## sulla scheda della casa

chi sei adesso, e la vita che stai vivendo.

**57 segni: 28 arrivano sul tavolo, 28 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `ancient` | 44 | 0 | 0 | 44 |  |
| `anointed` | 0 | 19 | 0 | 16 |  |
| `ash` | 57 | 0 | 0 | 57 |  |
| `ash_watch` | 0 | 1 | 0 | 1 |  |
| `crowned` | 55 | 0 | 0 | 55 |  |
| `discovery:crystal` | 0 | 5 | 0 | 5 |  |
| `discovery:legend` | 0 | 117 | 0 | 66 |  |
| `discovery:relic` | 0 | 3 | 0 | 3 |  |
| `discovery:shared_record` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:supervised_record` | 0 | 5 | 0 | 5 |  |
| `discovery:the_charter` | 0 | 37 | 0 | 30 |  |
| `discovery:the_ledger` | 0 | 326 | 0 | 97 |  |
| `discovery:the_measure` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `discovery:the_omen` | 0 | 333 | 0 | 96 |  |
| `discovery:trade_ledger` | 0 | 144 | 0 | 81 |  |
| `discovery:written_law` | 0 | 199 | 0 | 71 |  |
| `escort_sworn` | 0 | 297 | 108 | 84 |  |
| `evicted:$region_focus` | 0 | 0 | 0 | 0 | *una forma: l'id vero lo scrive il motore* |
| `failed_proposal` | 0 | 0 | 0 | 0 | **non arriva mai** |
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
| `renowned` | 0 | 308 | 0 | 99 |  |
| `scholar` | 48 | 0 | 0 | 48 |  |
| `sleeping` | 44 | 0 | 0 | 44 |  |
| `spoke_and_lost` | 0 | 14 | 0 | 14 |  |
| `took_by_hand` | 0 | 1 | 0 | 1 |  |
| `twice_uprooted` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `uprooted` | 0 | 2 | 0 | 2 |  |
| `watched` | 0 | 25 | 0 | 19 |  |
| `water_rights` | 0 | 1 | 0 | 1 |  |

## un gettone sul bordo della mappa

quello che il mondo ricorda (ISSUES 110).

**48 segni: 42 arrivano sul tavolo, 6 non ci arrivano mai.**

| segno | all'apertura | posato | tolto | a fine partita | |
|---|---|---|---|---|---|
| `account_settled` | 0 | 22 | 0 | 20 |  |
| `betrayal_spoken` | 0 | 17 | 0 | 15 |  |
| `burden_shared` | 0 | 97 | 0 | 59 |  |
| `charter_for_all` | 0 | 4 | 0 | 4 |  |
| `charter_written` | 0 | 53 | 0 | 32 |  |
| `crown_dispossessed` | 0 | 1 | 0 | 1 |  |
| `crown_divided` | 0 | 23 | 0 | 23 |  |
| `crystal_exploited` | 0 | 13 | 0 | 12 |  |
| `crystal_measured` | 0 | 12 | 0 | 11 |  |
| `debt_called` | 0 | 233 | 0 | 92 |  |
| `debt_forgiven` | 0 | 131 | 0 | 78 |  |
| `debt_staggered` | 0 | 11 | 0 | 9 |  |
| `descent_witnessed` | 0 | 5 | 0 | 5 |  |
| `distribution_audited` | 0 | 2 | 0 | 2 |  |
| `dragon_slain` | 0 | 1 | 0 | 1 |  |
| `faith_established` | 0 | 32 | 0 | 27 |  |
| `grain_requisitioned` | 0 | 34 | 0 | 32 |  |
| `heir_named` | 0 | 77 | 0 | 48 |  |
| `knowledge_shared` | 0 | 199 | 0 | 72 |  |
| `ledger_public` | 0 | 173 | 0 | 85 |  |
| `legend:debt_called` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:oath_broken` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `legend:order_restored` | 0 | 0 | 0 | 0 | *fuori portata: si scrive al salto d'era* |
| `mine_sealed` | 0 | 1 | 1 | 1 |  |
| `mountain_forgotten` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `nahr_settled` | 0 | 17 | 0 | 16 |  |
| `no_charter` | 0 | 1 | 0 | 1 |  |
| `oath_broken` | 0 | 3 | 9 | 3 |  |
| `order_restored` | 0 | 231 | 0 | 96 |  |
| `petition_heard` | 0 | 6 | 0 | 5 |  |
| `price_in_lives` | 0 | 10 | 0 | 8 |  |
| `question_unresolved` | 0 | 49 | 36 | 30 |  |
| `quota_guaranteed` | 0 | 12 | 0 | 12 |  |
| `relic_buried` | 0 | 13 | 0 | 13 |  |
| `relic_recorded` | 0 | 2 | 0 | 2 |  |
| `relic_shown` | 0 | 3 | 0 | 3 |  |
| `rumour_running` | 0 | 19 | 0 | 18 |  |
| `seal_kept` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `seal_kept_twice` | 0 | 0 | 0 | 0 | **non arriva mai** |
| `study_supervised` | 0 | 6 | 0 | 6 |  |
| `succession_by_law` | 0 | 38 | 0 | 33 |  |
| `succession_settled` | 0 | 9 | 0 | 6 |  |
| `succession_witnessed` | 0 | 9 | 0 | 6 |  |
| `toll_shared` | 0 | 49 | 0 | 38 |  |
| `valley_sealed` | 0 | 1 | 0 | 1 |  |
| `water_moves` | 0 | 27 | 0 | 21 |  |
| `water_priced` | 0 | 1 | 0 | 1 |  |
| `water_shared` | 0 | 1 | 0 | 1 |  |

## I segni che non arrivano mai

Hanno un posto sul tavolo, e in cento partite non ci si posano mai.
Sono **38 su 171**.

| segno | dove starebbe |
|---|---|
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
| `mountain_forgotten` | un gettone sul bordo della mappa |
| `place:low_spring` | uno spazio sulla tessera |
| `scar:divided_seal` | un dischetto rotondo |
| `seal_kept` | un gettone sul bordo della mappa |
| `seal_kept_twice` | un gettone sul bordo della mappa |
| `settlement:city` | uno spazio sulla tessera |
| `structure:palace` | uno spazio sulla tessera |
| `twice_uprooted` | sulla scheda della casa |
