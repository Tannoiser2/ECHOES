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
| 15 | 15 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 426 |
| 14 | 15 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 615 |
| 13 | 13 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 528 |
| 9 | 17 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 478 |
| 11 | 10 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 537 |
| 11 | 8 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 333 |
| 8 | 11 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 354 |
| 9 | 8 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 533 |
| 7 | 9 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 528 |
| 3 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 3 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 424 |
| 4 | 3 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 591 |
| 2 | 5 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 330 |
| 4 | 3 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 226 |
| 2 | 3 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 558 |
| 3 | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 252 |
| 1 | 4 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 583 |
| 3 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 460 |
| 1 | 3 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 395 |
| 1 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 873 |
| 2 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 283 |
| 1 | 1 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 424 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 714 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 38 | 1 ogni 4.4 |
| ENT_CENERE | 39 | 1 ogni 4.3 |
| ENT_LIBERE | 49 | 1 ogni 3.4 |
| ENT_LYRA | 32 | 1 ogni 5.2 |
| ENT_NAHR | 45 | 1 ogni 3.7 |
| ENT_SALE | 21 | 1 ogni 8.0 |
| ENT_VAERAX | 12 | 1 ogni 14.0 |
| ENT_VETRO | 37 | 1 ogni 4.5 |

