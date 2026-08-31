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
| **vite che non si sono mai sedute** | **7** |
| salti d'era giocati | 168 |
| trasformazioni sedute | 214 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 30 / 82 / 56 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 16 | 17 | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | 401 |
| 15 | 15 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 458 |
| 12 | 12 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 465 |
| 11 | 13 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 545 |
| 12 | 12 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 454 |
| 12 | 10 | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | 458 |
| 11 | 10 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 331 |
| 9 | 8 | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | 517 |
| 4 | 4 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 644 |
| 5 | 2 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 732 |
| 3 | 1 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 402 |
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
| ENT_ALDRIC | 32 | 1 ogni 5.2 |
| ENT_CENERE | 33 | 1 ogni 5.1 |
| ENT_LIBERE | 28 | 1 ogni 6.0 |
| ENT_LYRA | 24 | 1 ogni 7.0 |
| ENT_NAHR | 29 | 1 ogni 5.8 |
| ENT_SALE | 17 | 1 ogni 9.9 |
| ENT_VAERAX | 21 | 1 ogni 8.0 |
| ENT_VETRO | 30 | 1 ogni 5.6 |

