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
| **vite che non si sono mai sedute** | **0** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 293 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 16 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 13 | 16 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 435 |
| 13 | 13 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 426 |
| 10 | 11 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 478 |
| 9 | 11 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 412 |
| 10 | 9 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 308 |
| 8 | 10 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 312 |
| 10 | 6 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 591 |
| 8 | 8 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 478 |
| 7 | 7 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 528 |
| 6 | 5 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 533 |
| 5 | 5 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 618 |
| 3 | 6 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 545 |
| 5 | 3 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 583 |
| 4 | 4 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 591 |
| 5 | 3 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 3 | 4 | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 317 |
| 3 | 4 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 714 |
| 3 | 2 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 424 |
| 3 | 1 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 395 |
| 1 | 1 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 318 |
| **0** | 2 | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | 592 |
| **0** | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 420 |
| 1 | **0** | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 661 |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 39 | 1 ogni 4.3 |
| ENT_CENERE | 39 | 1 ogni 4.3 |
| ENT_LIBERE | 43 | 1 ogni 3.9 |
| ENT_LYRA | 35 | 1 ogni 4.8 |
| ENT_NAHR | 49 | 1 ogni 3.4 |
| ENT_SALE | 22 | 1 ogni 7.6 |
| ENT_VAERAX | 30 | 1 ogni 5.6 |
| ENT_VETRO | 36 | 1 ogni 4.7 |

