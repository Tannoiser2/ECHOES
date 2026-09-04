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
| trasformazioni sedute | 273 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 13 | 14 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 458 |
| 14 | 10 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 401 |
| 12 | 11 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 393 |
| 13 | 10 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 223 |
| 10 | 11 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 454 |
| 12 | 7 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 571 |
| 9 | 7 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 454 |
| 7 | 7 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 411 |
| 3 | 11 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 732 |
| 6 | 6 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 482 |
| 4 | 8 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 393 |
| 4 | 6 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 491 |
| 7 | 3 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 411 |
| 4 | 4 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 666 |
| 3 | 5 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 307 |
| 3 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 644 |
| 3 | 4 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 454 |
| 3 | 3 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 424 |
| 3 | 2 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 845 |
| 2 | 1 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 670 |
| 1 | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 406 |
| 1 | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 326 |
| **0** | **0** | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | — |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 30 | 1 ogni 5.6 |
| ENT_CENERE | 42 | 1 ogni 4.0 |
| ENT_LIBERE | 37 | 1 ogni 4.5 |
| ENT_LYRA | 37 | 1 ogni 4.5 |
| ENT_NAHR | 49 | 1 ogni 3.4 |
| ENT_SALE | 28 | 1 ogni 6.0 |
| ENT_VAERAX | 15 | 1 ogni 11.2 |
| ENT_VETRO | 35 | 1 ogni 4.8 |

