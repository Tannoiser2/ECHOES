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
| **vite che non si sono mai sedute** | **2** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 237 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 32 / 96 / 40 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 16 | 17 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 290 |
| 13 | 11 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 284 |
| 13 | 10 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 372 |
| 12 | 11 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 380 |
| 7 | 9 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 494 |
| 7 | 7 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 340 |
| 3 | 10 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 437 |
| 6 | 7 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 511 |
| 5 | 6 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 593 |
| 5 | 6 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 452 |
| 5 | 5 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 697 |
| 5 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 537 |
| 4 | 3 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 340 |
| 3 | 4 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 494 |
| 3 | 3 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 462 |
| 2 | 3 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 452 |
| 1 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 706 |
| **0** | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 830 |
| 1 | 1 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 537 |
| 1 | **0** | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 475 |
| 1 | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | 74 |
| 1 | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 290 |
| **0** | **0** | L'Assemblea Permanente | ENT_LIBERE | LINE_EXHAUSTED | — | — |
| **0** | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 30 | 1 ogni 5.6 |
| ENT_CENERE | 45 | 1 ogni 3.7 |
| ENT_LIBERE | 36 | 1 ogni 4.7 |
| ENT_LYRA | 28 | 1 ogni 6.0 |
| ENT_NAHR | 42 | 1 ogni 4.0 |
| ENT_SALE | 17 | 1 ogni 9.9 |
| ENT_VAERAX | 4 | 1 ogni 42.0 |
| ENT_VETRO | 35 | 1 ogni 4.8 |

