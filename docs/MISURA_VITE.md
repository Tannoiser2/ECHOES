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
| **vite che non si sono mai sedute** | **3** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 253 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 32 / 96 / 40 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 13 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 380 |
| 16 | 12 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 343 |
| 14 | 12 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 452 |
| 12 | 7 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 437 |
| 7 | 11 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 457 |
| 9 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 452 |
| 8 | 8 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 593 |
| 6 | 8 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 595 |
| 4 | 9 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 457 |
| 6 | 7 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 475 |
| 9 | 2 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 353 |
| 6 | 4 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 340 |
| 2 | 5 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 192 |
| 3 | 4 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 462 |
| 3 | 3 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 261 |
| 2 | 3 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 391 |
| 2 | 3 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 284 |
| 1 | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 192 |
| 3 | **0** | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 706 |
| 1 | 1 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 210 |
| **0** | 2 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 320 |
| **0** | **0** | L'Assemblea Permanente | ENT_LIBERE | LINE_EXHAUSTED | — | — |
| **0** | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | — |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 29 | 1 ogni 5.8 |
| ENT_CENERE | 49 | 1 ogni 3.4 |
| ENT_LIBERE | 37 | 1 ogni 4.5 |
| ENT_LYRA | 29 | 1 ogni 5.8 |
| ENT_NAHR | 45 | 1 ogni 3.7 |
| ENT_SALE | 20 | 1 ogni 8.4 |
| ENT_VAERAX | 9 | 1 ogni 18.7 |
| ENT_VETRO | 35 | 1 ogni 4.8 |

