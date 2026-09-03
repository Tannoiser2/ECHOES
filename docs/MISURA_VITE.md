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
| trasformazioni sedute | 268 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 12 | 14 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 9 | 13 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 401 |
| 10 | 10 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 8 | 12 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 411 |
| 10 | 10 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 352 |
| 7 | 9 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 566 |
| 8 | 7 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 647 |
| 8 | 6 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 491 |
| 7 | 7 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 393 |
| 8 | 6 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 639 |
| 7 | 5 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 596 |
| 7 | 5 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 223 |
| 4 | 7 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 684 |
| 5 | 5 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 496 |
| 4 | 6 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 324 |
| 4 | 3 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 545 |
| 2 | 4 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 672 |
| 3 | 2 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 326 |
| 3 | 1 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 845 |
| 2 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 402 |
| 1 | 2 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 517 |
| **0** | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 324 |
| **0** | 1 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 444 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 29 | 1 ogni 5.8 |
| ENT_CENERE | 42 | 1 ogni 4.0 |
| ENT_LIBERE | 41 | 1 ogni 4.1 |
| ENT_LYRA | 36 | 1 ogni 4.7 |
| ENT_NAHR | 43 | 1 ogni 3.9 |
| ENT_SALE | 21 | 1 ogni 8.0 |
| ENT_VAERAX | 21 | 1 ogni 8.0 |
| ENT_VETRO | 35 | 1 ogni 4.8 |

