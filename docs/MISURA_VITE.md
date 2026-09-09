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
| trasformazioni sedute | 262 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 26 / 100 / 42 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 16 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 435 |
| 15 | 12 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 528 |
| 13 | 14 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 424 |
| 14 | 9 | Gli Ospiti di Nahr | ENT_NAHR | ON_TAG | `burden_shared` | 331 |
| 11 | 8 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 478 |
| 8 | 9 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 367 |
| 10 | 7 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 533 |
| 7 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 420 |
| 3 | 11 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 545 |
| 7 | 6 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 545 |
| 5 | 5 | L'Archivio Aperto | ENT_LYRA | ON_TAG | `ledger_public` | 639 |
| 4 | 3 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 583 |
| 4 | 3 | Le Strade della Cenere | ENT_CENERE | ON_TAG | `condition:cut_off` | 591 |
| 2 | 5 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 330 |
| 2 | 4 | La Scuola del Vetro | ENT_VETRO | ON_TAG | `escort_sworn` | 460 |
| 3 | 2 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 283 |
| 1 | 3 | La Mano Rimessa | ENT_SALE | ON_TAG | `debt_forgiven` | 714 |
| **0** | 3 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 435 |
| 3 | **0** | L'Assemblea Permanente | ENT_LIBERE | ON_TAG | `charter_temporary` | 198 |
| 1 | 2 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 252 |
| 2 | **0** | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 891 |
| **0** | 2 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 714 |
| **0** | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | — |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 37 | 1 ogni 4.5 |
| ENT_CENERE | 36 | 1 ogni 4.7 |
| ENT_LIBERE | 39 | 1 ogni 4.3 |
| ENT_LYRA | 34 | 1 ogni 4.9 |
| ENT_NAHR | 40 | 1 ogni 4.2 |
| ENT_SALE | 19 | 1 ogni 8.8 |
| ENT_VAERAX | 15 | 1 ogni 11.2 |
| ENT_VETRO | 42 | 1 ogni 4.0 |

