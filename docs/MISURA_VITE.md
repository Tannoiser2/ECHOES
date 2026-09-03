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
| trasformazioni sedute | 234 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 15 | 14 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 482 |
| 15 | 13 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 406 |
| 11 | 11 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 406 |
| 11 | 9 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 8 | 11 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 454 |
| 8 | 10 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 672 |
| 9 | 9 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 454 |
| 9 | 9 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 454 |
| 6 | 9 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 666 |
| 5 | 6 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 393 |
| 4 | 6 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 535 |
| 4 | 5 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 458 |
| 4 | 2 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 644 |
| 1 | 3 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 666 |
| 1 | 2 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 326 |
| **0** | 2 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 596 |
| 1 | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 406 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 28 | 1 ogni 6.0 |
| ENT_CENERE | 38 | 1 ogni 4.4 |
| ENT_LIBERE | 29 | 1 ogni 5.8 |
| ENT_LYRA | 27 | 1 ogni 6.2 |
| ENT_NAHR | 37 | 1 ogni 4.5 |
| ENT_SALE | 20 | 1 ogni 8.4 |
| ENT_VAERAX | 23 | 1 ogni 7.3 |
| ENT_VETRO | 32 | 1 ogni 5.2 |

