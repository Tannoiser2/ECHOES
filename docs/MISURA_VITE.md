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
| **vite che non si sono mai sedute** | **2** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 223 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 14 | 15 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 458 |
| 12 | 12 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 535 |
| 10 | 12 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 482 |
| 12 | 9 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 9 | 11 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 402 |
| 12 | 8 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 331 |
| 9 | 9 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 458 |
| 9 | 8 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 517 |
| 9 | 6 | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | 458 |
| 8 | 2 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 732 |
| 4 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 644 |
| 5 | 2 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 411 |
| 3 | 2 | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | 670 |
| **0** | 4 | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | 324 |
| 1 | 1 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 406 |
| 1 | **0** | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 999 |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |
| **0** | **0** | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 33 | 1 ogni 5.1 |
| ENT_CENERE | 37 | 1 ogni 4.5 |
| ENT_LIBERE | 31 | 1 ogni 5.4 |
| ENT_LYRA | 25 | 1 ogni 6.7 |
| ENT_NAHR | 28 | 1 ogni 6.0 |
| ENT_SALE | 19 | 1 ogni 8.8 |
| ENT_VAERAX | 20 | 1 ogni 8.4 |
| ENT_VETRO | 30 | 1 ogni 5.6 |

