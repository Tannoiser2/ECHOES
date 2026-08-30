# ECHOES — Le caselle e quello che il Consiglio fa lo stesso

<!-- GENERATO da `tools/run_box_survey.sh` — non si corregge qui. -->

Il Consiglio cambia il mondo in **due modi che girano insieme**: le
caselle che il tavolo posa con le pedine, e le Conseguenze d'autore che
la proposta porta con se'. Dalla 0.1.306 la scheda stampa **solo le
caselle**: questa e' la misura di cosa resta fuori.

## Il vocabolario che esegue

Letto da `CouncilEconomy` chiamandolo, non ricopiato.

| casella | Effetti che produce |
|---|---|
| **REOPEN** | REMOVE_REGION_TAG |
| **CLEAR_CONDITION** | REMOVE_REGION_TAG |
| **BUILD_STONE** | BUILD_STRUCTURE |
| **TAKE_CONTROL** | SET_CONTROL |
| **COOL_THEME** | ADJUST_THEME_HEAT |
| **REMEMBER** | SET_GLOBAL_TAG |
| **COOL_QUESTION** | ADJUST_TENSION |
| **ADD_CONDITION** | SET_REGION_TAG |
| **TOLL** | SET_REGION_TAG |
| **YIELD_CONTROL** | SET_CONTROL |
| **HEAT_THEME** | ADJUST_THEME_HEAT |
| **TAKE_DEBT** | SET_REGION_TAG |
| **SCAR** | ADD_SCAR |
| **HEAT_QUESTION** | ADJUST_TENSION |

## Il conto

| | distinti | applicazioni |
|---|---|---|
| **una casella di oggi lo sa dire** | 5 | 151 |
| **verbo giusto, posto che la casella non sa dire** | 25 | 104 |
| **verbo che manca** | 16 | 81 |
| | **46** | **336** |

## Le caselle che mancano

| casella da scrivere | Effetti | distinti | applicazioni |
|---|---|---|---|
| **POSA UN SEGNO SU UNA CASATA** | `SET_ENTITY_TAG`, `REMOVE_ENTITY_TAG` | 4 | 44 |
| **MUOVI UN RAPPORTO** | `SET_RELATION` | 1 | 11 |
| **UNA PRESENZA ENTRA O SE NE VA** | `REMOVE_PRESENCE`, `ADD_PRESENCE` | 4 | 10 |
| **UNA PIETRA SALE O SCENDE** | `SET_STRUCTURE_GRADE` | 2 | 9 |
| **IL MONDO DIMENTICA** | `REMOVE_GLOBAL_TAG` | 1 | 3 |
| **UNA DOMANDA VELATA SI SCOPRE** | `SET_TENSION_VISIBILITY` | 2 | 2 |
| **UNA CASATA LASCIA IL TAVOLO** | `SET_ENTITY_ACTIVE` | 1 | 1 |
| **CHIUDI LA STRADA FRA DUE SEGNI** | `CLOSE_PASSAGE` | 1 | 1 |

## I verbi che mancano

| Effetto | dove | usi | come si direbbe |
|---|---|---|---|
| `REMOVE_PRESENCE` | `$rival` | 4 | il rivale se ne va dove si discute |
| `SET_STRUCTURE_GRADE` | *dove si discute* | 8 | Foresta dove si discute va al grado 2 |
| `ADD_PRESENCE` | `$rival` | 2 | il rivale entra in una Regione confinante |
| `SET_RELATION` | `$proponent|$rival` | 11 | il rapporto fra chi propone e il rivale cambia |
| `SET_ENTITY_TAG` | `$proponent` | 29 | chi propone porta addosso: la fama |
| `SET_TENSION_VISIBILITY` | `TEN_AWAKENING` | 1 | Il Risveglio si apre a tutti |
| `SET_ENTITY_TAG` | `$rival` | 12 | il rivale porta addosso: scoperta: lo studio custodito |
| `REMOVE_GLOBAL_TAG` | *dove si discute* | 3 | il mondo dimentica: le Miniere sono state sigillate |
| `SET_ENTITY_ACTIVE` | `$entity_with:sleeping` | 1 | la casa che porta dormiente esce dal tavolo, o ci rientra |
| `SET_ENTITY_TAG` | `$conditioner` | 2 | chi ha posto la condizione porta addosso: scoperta: il registro condiviso |
| `REMOVE_ENTITY_TAG` | `$rival` | 1 | il rivale perde: la corona |
| `SET_STRUCTURE_GRADE` | `$region_with:wild` | 1 | Passo in una Regione con selvaggio va al grado 2 |
| `CLOSE_PASSAGE` | `$region_with:wild` | 1 | si chiude la strada in una Regione con pascolo |
| `REMOVE_PRESENCE` | `$proponent` | 2 | chi propone se ne va dove si discute |
| `ADD_PRESENCE` | `$proponent` | 2 | chi propone entra in una Regione confinante |
| `SET_TENSION_VISIBILITY` | `TEN_RELIC` | 1 | La Reliquia si apre a tutti |

## Il posto che la casella non sa dire

| Effetto | dove | usi | come si direbbe |
|---|---|---|---|
| `BUILD_STRUCTURE` | `$region_with:granary` | 4 | si alza Granaio in una Regione con granaio |
| `ADJUST_TENSION` | `TEN_ROADS` | 20 | Le Vie Interrotte sale |
| `SET_GLOBAL_TAG` | `$adjacent` | 1 | il mondo registra: la Valle e' stata chiusa |
| `SET_REGION_TAG` | `$rival_seat` | 2 | nella sede del rivale diventa affamata |
| `SET_REGION_TAG` | `$adjacent` | 18 | in una Regione confinante diventa inquieta |
| `REMOVE_REGION_TAG` | `$region_with:nomad_range` | 1 | in una Regione con pascolo non e' piu' affamata |
| `ADJUST_TENSION` | `TEN_FAMINE` | 3 | La Carestia scende |
| `SET_REGION_TAG` | `$region_with:crystal_site` | 3 | in una Regione con cristallo diventa sfruttata |
| `ADJUST_TENSION` | `TEN_AWAKENING` | 5 | Il Risveglio scende |
| `REMOVE_REGION_TAG` | `$region_with:crystal_site` | 1 | in una Regione con cristallo non e' piu' il sigillo |
| `ADJUST_TENSION` | `TEN_SUCCESSION` | 7 | La Successione scende di 2 |
| `SET_CONTROL` | `$rival_seat` | 2 | nella sede del rivale cambia padrone |
| `SET_REGION_TAG` | `$capital` | 2 | nella capitale diventa contesa |
| `BUILD_STRUCTURE` | `$rival_seat` | 1 | si alza Presidio nella sede del rivale |
| `SET_CONTROL` | `$capital` | 1 | nella capitale cambia padrone |
| `SET_CONTROL` | `$region_with:trade` | 2 | in una Regione con commercio cambia padrone |
| `BUILD_STRUCTURE` | `$region_with:trade` | 2 | si alza Pedaggio in una Regione con commercio |
| `ADJUST_TENSION` | `TEN_CHARTER` | 8 | La Carta sale |
| `ADJUST_TENSION` | `TEN_DEBT` | 6 | Il Debito scende |
| `ADJUST_TENSION` | `TEN_WATER` | 3 | L'Acqua Ferma scende di 2 |
| `ADJUST_TENSION` | `TEN_NAMELESS` | 2 | I Senza Città scende |
| `ADJUST_TENSION` | `TEN_RELIC` | 2 | La Reliquia scende |
| `SET_REGION_TAG` | `$region_with:mine` | 2 | in una Regione con miniera diventa svuotata |
| `ADJUST_TENSION` | `TEN_ASH` | 4 | La Cenere che Sale scende di 2 |
| `BUILD_STRUCTURE` | `$region_with:wild` | 2 | si alza Presidio in una Regione con selvaggio |

## Quello che una casella gia' dice

| Effetto | dove | usi | come si direbbe |
|---|---|---|---|
| `SET_GLOBAL_TAG` | *dove si discute* | 70 | il mondo registra: il grano e' stato requisito |
| `SET_REGION_TAG` | *dove si discute* | 33 | dove si discute diventa requisita |
| `SET_CONTROL` | *dove si discute* | 4 | dove si discute cambia padrone |
| `ADJUST_TENSION` | *dove si discute* | 30 | la domanda in gioco sale |
| `REMOVE_REGION_TAG` | *dove si discute* | 14 | dove si discute non e' piu' inquieta |
