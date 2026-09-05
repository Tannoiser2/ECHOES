# Le vite delle case, contate

Generato da `cli/run_lives_probe.gd` — non si scrive a mano.

    godot --headless --path godot --script res://cli/run_lives_probe.gd -- \
        --sagas=12 --chronicles=8 --seed=812 --then=CHR_00

Una casa ha piu' vite scritte: il popolo diventa regno, la scuola
diventa culto, il regno diventa repubblica. Qui si conta **quante di
quelle vite si siedono davvero al tavolo**, giocando 12 saghe da 8
anni **su due tavoli** — quattro ottimizzatori e un tavolo di
caratteri misti, come al cancello — e dopo quanto tempo.

| | |
|---|---|
| vite scritte oltre la prima | 24 |
| **vite che non si sono mai sedute** | **1** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 271 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 14 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 458 |
| 14 | 13 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 352 |
| 14 | 12 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 406 |
| 12 | 10 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 9 | 13 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 684 |
| 10 | 11 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 454 |
| 7 | 8 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 411 |
| 6 | 9 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 406 |
| 7 | 5 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 458 |
| 6 | 5 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 444 |
| 4 | 7 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 324 |
| 6 | 5 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 393 |
| 4 | 5 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 707 |
| 4 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 545 |
| 3 | 5 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 491 |
| 3 | 3 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 402 |
| 2 | 2 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 259 |
| 1 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 845 |
| 1 | 3 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 670 |
| **0** | 2 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 999 |
| 1 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 999 |
| **0** | 1 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 324 |
| 1 | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 406 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 31 | 1 ogni 5.4 |
| ENT_CENERE | 43 | 1 ogni 3.9 |
| ENT_LIBERE | 37 | 1 ogni 4.5 |
| ENT_LYRA | 38 | 1 ogni 4.4 |
| ENT_NAHR | 44 | 1 ogni 3.8 |
| ENT_SALE | 26 | 1 ogni 6.5 |
| ENT_VAERAX | 15 | 1 ogni 11.2 |
| ENT_VETRO | 37 | 1 ogni 4.5 |

