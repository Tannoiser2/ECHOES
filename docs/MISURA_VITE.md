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
| vite scritte oltre la prima | 18 |
| **vite che non si sono mai sedute** | **1** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 219 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 14 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 458 |
| 12 | 11 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 491 |
| 12 | 10 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 458 |
| 10 | 11 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 402 |
| 10 | 8 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 7 | 10 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 411 |
| 8 | 7 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 374 |
| 5 | 8 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 672 |
| 8 | 5 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 444 |
| 6 | 6 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 260 |
| 7 | 4 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 684 |
| 4 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 545 |
| 2 | 3 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 639 |
| 1 | 3 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 324 |
| 1 | 2 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 670 |
| 1 | 2 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 666 |
| **0** | 2 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 647 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 30 | 1 ogni 5.6 |
| ENT_CENERE | 35 | 1 ogni 4.8 |
| ENT_LIBERE | 30 | 1 ogni 5.6 |
| ENT_LYRA | 24 | 1 ogni 7.0 |
| ENT_NAHR | 33 | 1 ogni 5.1 |
| ENT_SALE | 20 | 1 ogni 8.4 |
| ENT_VAERAX | 16 | 1 ogni 10.5 |
| ENT_VETRO | 31 | 1 ogni 5.4 |

