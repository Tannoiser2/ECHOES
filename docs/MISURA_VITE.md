# Le vite delle case, contate

Generato da `cli/run_lives_probe.gd` — non si scrive a mano.

    godot --headless --path godot --script res://cli/run_lives_probe.gd -- \
        --sagas=12 --chronicles=8 --seed=812 --then=CHR_02

Una casa ha piu' vite scritte: il popolo diventa regno, la scuola
diventa culto, il regno diventa repubblica. Qui si conta **quante di
quelle vite si siedono davvero al tavolo**, giocando 12 saghe da 8
anni **su due tavoli** — quattro ottimizzatori e un tavolo di
caratteri misti, come al cancello — e dopo quanto tempo.

| | |
|---|---|
| vite scritte oltre la prima | 18 |
| **vite che non si sono mai sedute** | **7** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 182 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 22 / 108 / 38 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 14 | 13 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 381 |
| 13 | 10 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 440 |
| 11 | 11 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 368 |
| 9 | 11 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 345 |
| 8 | 10 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 560 |
| 9 | 9 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 322 |
| 9 | 6 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 509 |
| 5 | 9 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 422 |
| 8 | 6 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 369 |
| 2 | 4 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 463 |
| 3 | 2 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 381 |
| **0** | **0** | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | — |
| **0** | **0** | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | — |
| **0** | **0** | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | — |
| **0** | **0** | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | — |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |
| **0** | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | — |
| **0** | **0** | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 23 | 1 ogni 7.3 |
| ENT_CENERE | 20 | 1 ogni 8.4 |
| ENT_LIBERE | 21 | 1 ogni 8.0 |
| ENT_LYRA | 22 | 1 ogni 7.6 |
| ENT_NAHR | 37 | 1 ogni 4.5 |
| ENT_SALE | 14 | 1 ogni 12.0 |
| ENT_VAERAX | 27 | 1 ogni 6.2 |
| ENT_VETRO | 18 | 1 ogni 9.3 |

