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
| trasformazioni sedute | 274 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 15 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 13 | 14 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 435 |
| 13 | 13 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 424 |
| 10 | 12 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 482 |
| 11 | 9 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 333 |
| 12 | 8 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 367 |
| 7 | 13 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 537 |
| 10 | 9 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 482 |
| 7 | 6 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 528 |
| 5 | 6 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 583 |
| 5 | 6 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 592 |
| 5 | 4 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 3 | 3 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 664 |
| 4 | 2 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 615 |
| 4 | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 420 |
| 3 | 2 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 533 |
| 2 | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 558 |
| 2 | 2 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 331 |
| 2 | 2 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 873 |
| **0** | 4 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 399 |
| 2 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 661 |
| 1 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 460 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 661 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 42 | 1 ogni 4.0 |
| ENT_CENERE | 37 | 1 ogni 4.5 |
| ENT_LIBERE | 43 | 1 ogni 3.9 |
| ENT_LYRA | 37 | 1 ogni 4.5 |
| ENT_NAHR | 46 | 1 ogni 3.7 |
| ENT_SALE | 18 | 1 ogni 9.3 |
| ENT_VAERAX | 15 | 1 ogni 11.2 |
| ENT_VETRO | 36 | 1 ogni 4.7 |

