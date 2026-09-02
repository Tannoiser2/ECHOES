# ECHOES — Le caselle e quello che il Consiglio fa lo stesso

<!-- GENERATO da `tools/run_box_survey.sh` — non si corregge qui. -->

Il Consiglio cambia il mondo in **due modi che girano insieme**: le
caselle che il tavolo posa con le pedine, e le Conseguenze d'autore che
la proposta porta con se'. Dalla 0.1.306 la scheda stampa **solo le
caselle**: questa e' la misura di cosa resta fuori.

## Il vocabolario che esegue

Letto da `CouncilEconomy` chiamandolo, non ricopiato: ogni casella
e' stata girata una volta per ogni posto che accetta, e la colonna
«dove sa puntare» e' **cosa e' uscito puntato**, non un elenco a mano.

| casella | in quale lista | Effetti che produce | dove sa puntare |
|---|---|---|---|
| **REOPEN** — RIAPRI | benefici | REMOVE_REGION_TAG | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **CLEAR_CONDITION** — RIMUOVI CONDIZIONE | benefici | REMOVE_REGION_TAG | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **BUILD_STONE** — COSTRUISCI PIETRA | benefici | SET_STRUCTURE_OWNER, BUILD_STRUCTURE | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **TAKE_CONTROL** — CAMBIA CONTROLLO | benefici | SET_CONTROL | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **COOL_THEME** — RAFFREDDA TEMA | benefici | ADJUST_THEME_HEAT | `THM_POTERE` |
| **REMEMBER** — IL MONDO RICORDA | benefici | SET_GLOBAL_TAG | `$region_focus` |
| **COOL_QUESTION** — ABBASSA LA DOMANDA | benefici | ADJUST_TENSION | `$region_focus`, `TEN_` |
| **MARK_HOUSE** — POSA UN SEGNO SU UNA CASATA | benefici e costi | SET_ENTITY_TAG | `$entity_with:`, `$proponent`, `$rival` |
| **UNMARK_HOUSE** — TOGLI UN SEGNO A UNA CASATA | benefici e costi | REMOVE_ENTITY_TAG | `$entity_with:`, `$proponent`, `$rival` |
| **BIND_HOUSES** — MUOVI UN RAPPORTO | benefici e costi | SET_RELATION | `|` |
| **MOVE_IN** — UNA PRESENZA ENTRA | benefici e costi | ADD_PRESENCE | `$entity_with:`, `$proponent`, `$rival` |
| **MOVE_OUT** — UNA PRESENZA SE NE VA | benefici e costi | REMOVE_PRESENCE | `$entity_with:`, `$proponent`, `$rival` |
| **RAISE_STONE** — UNA PIETRA SALE | benefici | SET_STRUCTURE_GRADE | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **FORGET** — IL MONDO DIMENTICA | benefici e costi | REMOVE_GLOBAL_TAG | `$region_focus` |
| **UNVEIL_QUESTION** — UNA DOMANDA VELATA SI SCOPRE | benefici e costi | SET_TENSION_VISIBILITY | `$region_focus`, `TEN_` |
| **ADD_CONDITION** — AGGIUNGI CONDIZIONE | costi | SET_REGION_TAG | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **TOLL** — PEDAGGIO | costi | SET_REGION_TAG | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **YIELD_CONTROL** — CEDI CONTROLLO | costi | SET_CONTROL | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **HEAT_THEME** — SCALDA TEMA | costi | ADJUST_THEME_HEAT | `THM_POTERE` |
| **TAKE_DEBT** — PRENDI DEBITO | costi | SET_REGION_TAG | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **SCAR** — CICATRICE | costi | ADD_SCAR | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **HEAT_QUESTION** — ALZA LA DOMANDA | costi | ADJUST_TENSION | `$region_focus`, `TEN_` |
| **LOWER_STONE** — UNA PIETRA SCENDE | costi | SET_STRUCTURE_GRADE | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **SEAL_ROAD** — CHIUDI LA STRADA | costi | CLOSE_PASSAGE | `$adjacent`, `$capital`, `$region_focus`, `$region_with:`, `$rival_seat` |
| **LEAVE_TABLE** — UNA CASATA LASCIA IL TAVOLO | costi | SET_ENTITY_ACTIVE | `$entity_with:`, `$proponent`, `$rival` |

## Il conto

| | distinti | applicazioni |
|---|---|---|
| **una casella di oggi lo sa dire** | 44 | 340 |
| **verbo giusto, posto che la casella non sa dire** | 1 | 2 |
| **verbo che manca** | 0 | 0 |
| | **45** | **342** |

## Le caselle che mancano

| casella da scrivere | Effetti | distinti | applicazioni |
|---|---|---|---|
| *nessuna* | | 0 | 0 |

## I verbi che mancano

| Effetto | dove | usi | come si direbbe |
|---|---|---|---|
| *nessuno* | | | |

## Il posto che la casella non sa dire

| Effetto | dove | usi | come si direbbe |
|---|---|---|---|
| `SET_ENTITY_TAG` | `$conditioner` | 2 | chi ha posto la condizione porta addosso: scoperta: il registro condiviso |

## Quello che una casella gia' dice

| Effetto | dove | usi | come si direbbe |
|---|---|---|---|
| `BUILD_STRUCTURE` | `$region_with:granary` | 4 | si alza Granaio in una Regione con #granaio |
| `ADJUST_TENSION` | `TEN_ROADS` | 21 | Le Vie Interrotte sale |
| `SET_GLOBAL_TAG` | *dove si discute* | 71 | il mondo registra: il grano e' stato requisito |
| `REMOVE_PRESENCE` | `$rival` | 4 | il rivale se ne va dove si discute |
| `SET_REGION_TAG` | *dove si discute* | 35 | dove si discute diventa #requisita |
| `SET_STRUCTURE_GRADE` | *dove si discute* | 8 | Foresta dove si discute va al grado 2 |
| `ADD_PRESENCE` | `$rival` | 2 | il rivale entra in una Regione confinante |
| `SET_RELATION` | `$proponent|$rival` | 11 | il rapporto fra chi propone e il rivale cambia |
| `SET_CONTROL` | *dove si discute* | 4 | dove si discute cambia padrone |
| `SET_REGION_TAG` | `$rival_seat` | 2 | nella sede del rivale diventa #affamata |
| `SET_REGION_TAG` | `$adjacent` | 19 | in una Regione confinante diventa #svuotata |
| `REMOVE_PRESENCE` | `$proponent` | 3 | chi propone se ne va in una Regione confinante |
| `ADJUST_TENSION` | *dove si discute* | 31 | la domanda in gioco sale |
| `SET_ENTITY_TAG` | `$proponent` | 29 | chi propone porta addosso: la fama |
| `REMOVE_REGION_TAG` | `$region_with:nomad_range` | 1 | in una Regione con #pascolo non e' piu' #affamata |
| `ADJUST_TENSION` | `TEN_FAMINE` | 3 | La Carestia scende |
| `SET_REGION_TAG` | `$region_with:crystal_site` | 3 | in una Regione con #cristallo diventa #sfruttata |
| `SET_TENSION_VISIBILITY` | `TEN_AWAKENING` | 1 | Il Risveglio si apre a tutti |
| `SET_ENTITY_TAG` | `$rival` | 12 | il rivale porta addosso: scoperta: lo studio custodito |
| `ADJUST_TENSION` | `TEN_AWAKENING` | 5 | Il Risveglio scende |
| `REMOVE_GLOBAL_TAG` | *dove si discute* | 3 | il mondo dimentica: le Miniere sono state sigillate |
| `REMOVE_REGION_TAG` | `$region_with:crystal_site` | 1 | in una Regione con #cristallo non e' piu' il sigillo |
| `SET_ENTITY_ACTIVE` | `$entity_with:sleeping` | 1 | la casa che porta #dormiente esce dal tavolo, o ci rientra |
| `ADJUST_TENSION` | `TEN_SUCCESSION` | 7 | La Successione scende di 2 |
| `REMOVE_REGION_TAG` | *dove si discute* | 14 | dove si discute non e' piu' #inquieta |
| `SET_CONTROL` | `$rival_seat` | 2 | nella sede del rivale cambia padrone |
| `SET_REGION_TAG` | `$capital` | 2 | nella capitale diventa #contesa |
| `BUILD_STRUCTURE` | `$rival_seat` | 1 | si alza Presidio nella sede del rivale |
| `SET_CONTROL` | `$capital` | 1 | nella capitale cambia padrone |
| `REMOVE_ENTITY_TAG` | `$rival` | 1 | il rivale perde: la corona |
| `SET_CONTROL` | `$region_with:trade` | 2 | in una Regione con #commercio cambia padrone |
| `BUILD_STRUCTURE` | `$region_with:trade` | 2 | si alza Pedaggio in una Regione con #commercio |
| `SET_STRUCTURE_GRADE` | `$region_with:wild` | 1 | Passo in una Regione con #selvaggio va al grado 2 |
| `CLOSE_PASSAGE` | `$region_with:wild` | 1 | si chiude la strada in una Regione con #pascolo |
| `ADD_PRESENCE` | `$proponent` | 2 | chi propone entra in una Regione confinante |
| `ADJUST_TENSION` | `TEN_CHARTER` | 8 | La Carta sale |
| `ADJUST_TENSION` | `TEN_DEBT` | 6 | Il Debito scende |
| `ADJUST_TENSION` | `TEN_WATER` | 3 | L'Acqua Ferma scende di 2 |
| `ADJUST_TENSION` | `TEN_NAMELESS` | 2 | I Senza Città scende |
| `ADJUST_TENSION` | `TEN_RELIC` | 2 | La Reliquia scende |
| `SET_REGION_TAG` | `$region_with:mine` | 2 | in una Regione con #miniera diventa #svuotata |
| `ADJUST_TENSION` | `TEN_ASH` | 4 | La Cenere che Sale scende di 2 |
| `BUILD_STRUCTURE` | `$region_with:wild` | 2 | si alza Presidio in una Regione con #selvaggio |
| `SET_TENSION_VISIBILITY` | `TEN_RELIC` | 1 | La Reliquia si apre a tutti |
