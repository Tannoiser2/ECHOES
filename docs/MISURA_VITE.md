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
| trasformazioni sedute | 224 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 32 / 96 / 40 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 17 | 16 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 290 |
| 12 | 16 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 284 |
| 12 | 12 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 452 |
| 11 | 9 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 372 |
| 8 | 8 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 340 |
| 7 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 535 |
| 6 | 7 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 475 |
| 4 | 6 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 437 |
| 7 | 3 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 535 |
| 5 | 4 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 457 |
| 4 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 340 |
| 3 | 3 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 353 |
| 3 | 3 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 261 |
| 3 | 2 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 706 |
| 3 | 2 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 320 |
| 2 | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 457 |
| 2 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 320 |
| 1 | 1 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 475 |
| 1 | 1 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 275 |
| **0** | 2 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 604 |
| 1 | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | 74 |
| 1 | **0** | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 676 |
| **0** | **0** | L'Assemblea Permanente | ENT_LIBERE | LINE_EXHAUSTED | — | — |
| **0** | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 26 | 1 ogni 6.5 |
| ENT_CENERE | 45 | 1 ogni 3.7 |
| ENT_LIBERE | 33 | 1 ogni 5.1 |
| ENT_LYRA | 24 | 1 ogni 7.0 |
| ENT_NAHR | 40 | 1 ogni 4.2 |
| ENT_SALE | 20 | 1 ogni 8.4 |
| ENT_VAERAX | 4 | 1 ogni 42.0 |
| ENT_VETRO | 32 | 1 ogni 5.2 |

