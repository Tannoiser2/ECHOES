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
| trasformazioni sedute | 261 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 12 | 15 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 12 | 11 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 406 |
| 10 | 12 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 363 |
| 10 | 10 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 7 | 13 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 482 |
| 10 | 7 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 352 |
| 8 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 517 |
| 7 | 8 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 331 |
| 7 | 7 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 684 |
| 7 | 7 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 411 |
| 6 | 6 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 458 |
| 5 | 6 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 454 |
| 4 | 6 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 491 |
| 4 | 3 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 223 |
| 3 | 3 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 666 |
| 2 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 352 |
| 3 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 402 |
| 2 | 2 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 672 |
| 3 | 1 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 382 |
| 3 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 326 |
| 1 | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 223 |
| 1 | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 1177 |
| 1 | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 864 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 29 | 1 ogni 5.8 |
| ENT_CENERE | 37 | 1 ogni 4.5 |
| ENT_LIBERE | 40 | 1 ogni 4.2 |
| ENT_LYRA | 37 | 1 ogni 4.5 |
| ENT_NAHR | 44 | 1 ogni 3.8 |
| ENT_SALE | 22 | 1 ogni 7.6 |
| ENT_VAERAX | 16 | 1 ogni 10.5 |
| ENT_VETRO | 36 | 1 ogni 4.7 |

