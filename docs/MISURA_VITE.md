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
| trasformazioni sedute | 258 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 17 | 17 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 14 | 17 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 318 |
| 14 | 13 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 478 |
| 13 | 13 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 426 |
| 14 | 8 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 478 |
| 7 | 7 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 528 |
| 7 | 5 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 533 |
| 7 | 5 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 412 |
| 5 | 5 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 626 |
| 6 | 3 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 615 |
| 7 | 2 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 545 |
| 4 | 4 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 367 |
| 3 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 583 |
| 3 | 4 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 3 | 3 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 482 |
| 3 | 3 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 420 |
| 1 | 3 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 424 |
| 2 | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 661 |
| 2 | 1 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 873 |
| 1 | 2 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 174 |
| **0** | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 226 |
| 1 | 1 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 331 |
| 1 | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | 537 |
| **0** | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 36 | 1 ogni 4.7 |
| ENT_CENERE | 41 | 1 ogni 4.1 |
| ENT_LIBERE | 34 | 1 ogni 4.9 |
| ENT_LYRA | 29 | 1 ogni 5.8 |
| ENT_NAHR | 46 | 1 ogni 3.7 |
| ENT_SALE | 20 | 1 ogni 8.4 |
| ENT_VAERAX | 13 | 1 ogni 12.9 |
| ENT_VETRO | 39 | 1 ogni 4.3 |

