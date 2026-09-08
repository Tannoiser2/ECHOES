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
| trasformazioni sedute | 293 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 14 | 18 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 537 |
| 16 | 12 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 435 |
| 13 | 12 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 528 |
| 12 | 11 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 424 |
| 8 | 11 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 482 |
| 8 | 11 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 308 |
| 6 | 8 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 533 |
| 8 | 5 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 466 |
| 8 | 5 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 426 |
| 8 | 5 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 164 |
| 6 | 7 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 528 |
| 6 | 5 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 618 |
| 6 | 4 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 331 |
| 5 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 4 | 4 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 591 |
| 4 | 4 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 626 |
| 4 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 714 |
| 3 | 3 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 426 |
| 3 | 3 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 460 |
| 3 | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 420 |
| 1 | 4 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 661 |
| 2 | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 583 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 420 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 40 | 1 ogni 4.2 |
| ENT_CENERE | 37 | 1 ogni 4.5 |
| ENT_LIBERE | 42 | 1 ogni 4.0 |
| ENT_LYRA | 37 | 1 ogni 4.5 |
| ENT_NAHR | 50 | 1 ogni 3.4 |
| ENT_SALE | 21 | 1 ogni 8.0 |
| ENT_VAERAX | 27 | 1 ogni 6.2 |
| ENT_VETRO | 39 | 1 ogni 4.3 |

