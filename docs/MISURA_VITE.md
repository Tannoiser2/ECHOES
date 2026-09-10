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
| **vite che non si sono mai sedute** | **4** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 243 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 32 / 96 / 40 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 14 | 16 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 380 |
| 14 | 11 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 452 |
| 10 | 12 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 343 |
| 10 | 11 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 437 |
| 11 | 7 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 457 |
| 8 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 452 |
| 6 | 8 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 511 |
| 8 | 5 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 340 |
| 5 | 8 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 615 |
| 6 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 537 |
| 5 | 6 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 373 |
| 3 | 6 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 457 |
| 4 | 5 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 349 |
| 5 | 4 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 475 |
| 3 | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 699 |
| 3 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 247 |
| 2 | 2 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 516 |
| 2 | 1 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 210 |
| **0** | 3 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 372 |
| 1 | 1 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 511 |
| **0** | **0** | L'Assemblea Permanente | ENT_LIBERE | LINE_EXHAUSTED | — | — |
| **0** | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | — |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |
| **0** | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 26 | 1 ogni 6.5 |
| ENT_CENERE | 46 | 1 ogni 3.7 |
| ENT_LIBERE | 35 | 1 ogni 4.8 |
| ENT_LYRA | 29 | 1 ogni 5.8 |
| ENT_NAHR | 45 | 1 ogni 3.7 |
| ENT_SALE | 18 | 1 ogni 9.3 |
| ENT_VAERAX | 11 | 1 ogni 15.3 |
| ENT_VETRO | 33 | 1 ogni 5.1 |

