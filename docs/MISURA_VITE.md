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
| trasformazioni sedute | 260 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 17 | 17 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 435 |
| 13 | 15 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 312 |
| 13 | 14 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 478 |
| 9 | 11 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 426 |
| 12 | 6 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 466 |
| 9 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 420 |
| 7 | 6 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 395 |
| 5 | 8 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 478 |
| 7 | 5 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 533 |
| 6 | 4 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 426 |
| 6 | 3 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 435 |
| 6 | 3 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 412 |
| 4 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 661 |
| 4 | 4 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 591 |
| 4 | 4 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 3 | 3 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 420 |
| 2 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 695 |
| 1 | 3 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 424 |
| 2 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 482 |
| 1 | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 528 |
| 1 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 174 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 859 |
| 1 | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 545 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 38 | 1 ogni 4.4 |
| ENT_CENERE | 38 | 1 ogni 4.4 |
| ENT_LIBERE | 35 | 1 ogni 4.8 |
| ENT_LYRA | 33 | 1 ogni 5.1 |
| ENT_NAHR | 43 | 1 ogni 3.9 |
| ENT_SALE | 23 | 1 ogni 7.3 |
| ENT_VAERAX | 10 | 1 ogni 16.8 |
| ENT_VETRO | 40 | 1 ogni 4.2 |

