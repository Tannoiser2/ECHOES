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
| trasformazioni sedute | 273 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 16 | 16 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 435 |
| 12 | 15 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 532 |
| 11 | 12 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 420 |
| 9 | 10 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 482 |
| 7 | 12 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 537 |
| 9 | 9 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 610 |
| 7 | 8 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 460 |
| 7 | 7 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 528 |
| 5 | 8 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 166 |
| 7 | 6 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 399 |
| 4 | 8 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 528 |
| 4 | 6 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 661 |
| 6 | 4 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 591 |
| 4 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 6 | 3 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 762 |
| 4 | 3 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 545 |
| 3 | 3 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 426 |
| 2 | 3 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 395 |
| 3 | 1 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 714 |
| 3 | 1 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 354 |
| 1 | 1 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 639 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 661 |
| **0** | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 927 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 39 | 1 ogni 4.3 |
| ENT_CENERE | 39 | 1 ogni 4.3 |
| ENT_LIBERE | 35 | 1 ogni 4.8 |
| ENT_LYRA | 35 | 1 ogni 4.8 |
| ENT_NAHR | 41 | 1 ogni 4.1 |
| ENT_SALE | 19 | 1 ogni 8.8 |
| ENT_VAERAX | 28 | 1 ogni 6.0 |
| ENT_VETRO | 37 | 1 ogni 4.5 |

