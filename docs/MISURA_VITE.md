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
| trasformazioni sedute | 277 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 13 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 14 | 12 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 363 |
| 12 | 12 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 406 |
| 10 | 12 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 10 | 11 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 571 |
| 10 | 11 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 454 |
| 9 | 9 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 402 |
| 7 | 8 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 393 |
| 7 | 7 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 261 |
| 8 | 5 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 411 |
| 8 | 5 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 424 |
| 6 | 4 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 684 |
| 5 | 4 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 382 |
| 4 | 5 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 644 |
| 3 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 545 |
| 3 | 3 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 402 |
| 2 | 3 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 458 |
| 2 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 845 |
| 3 | 1 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 307 |
| 2 | 1 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 727 |
| 1 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 326 |
| 1 | **0** | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 324 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 406 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 30 | 1 ogni 5.6 |
| ENT_CENERE | 42 | 1 ogni 4.0 |
| ENT_LIBERE | 38 | 1 ogni 4.4 |
| ENT_LYRA | 38 | 1 ogni 4.4 |
| ENT_NAHR | 50 | 1 ogni 3.4 |
| ENT_SALE | 27 | 1 ogni 6.2 |
| ENT_VAERAX | 16 | 1 ogni 10.5 |
| ENT_VETRO | 36 | 1 ogni 4.7 |

