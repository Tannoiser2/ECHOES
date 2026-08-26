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
| trasformazioni sedute | 88 |
| salti brevi (sotto 50 anni) / medi / lunghi (oltre 150) | 22 / 108 / 38 |

## Le vite, una per una

| uniforme | misto | vita | casa | porta | segno atteso | anni (mediana) |
|---|---|---|---|---|---|---|
| 16 | 12 | Il Regno di Nahr | ENT_NAHR | ON_TAG | `nahr_settled` | 443 |
| 14 | 11 | Vaerax Ridestato | ENT_VAERAX | ON_TAG | `crystal_exploited` | 426 |
| 6 | 9 | L'Egemonia di Eredan | ENT_LIBERE | ON_TAG | `scar:emptied@REG_VALLE_VERDE` | 381 |
| 4 | 3 | La Lega delle Sette | ENT_LIBERE | ON_TAG | `charter_written` | 697 |
| 2 | 1 | I Frati del Vetro | ENT_VETRO | LINE_EXHAUSTED | — | 556 |
| 1 | 1 | La Repubblica della Valle | ENT_ALDRIC | LINE_EXHAUSTED | — | 632 |
| 1 | 1 | La Corona Restaurata | ENT_ALDRIC | ON_TAG | `heir_named` | 740 |
| 1 | 1 | Il Culto della Misura | ENT_LYRA | LINE_EXHAUSTED | — | 632 |
| 1 | 1 | Il Banco Nero | ENT_SALE | ON_TAG | `debt_called` | 509 |
| **0** | 1 | La Leggenda della Montagna | ENT_VAERAX | ON_TAG | `mountain_forgotten` | 463 |
| **0** | 1 | L'Inquisizione del Vetro | ENT_VETRO | ON_TAG | `relic_shown` | 683 |
| **0** | **0** | La Reggenza del Granaio | ENT_ALDRIC | ON_TAG | `grain_requisitioned` | — |
| **0** | **0** | Le Custodi della Cenere | ENT_CENERE | LINE_EXHAUSTED | — | — |
| **0** | **0** | I Forni Riaccesi | ENT_CENERE | ON_TAG | `scar:open_wound` | — |
| **0** | **0** | L'Accademia delle Misure | ENT_LYRA | ON_TAG | `succession_by_law` | — |
| **0** | **0** | La Diaspora di Nahr | ENT_NAHR | ON_TAG | `twice_uprooted` | — |
| **0** | **0** | La Compagnia del Sale | ENT_SALE | LINE_EXHAUSTED | — | — |
| **0** | **0** | Il Culto della Montagna | ENT_VAERAX | ON_DEATH | — | — |

## Quanto spesso una casa cambia pelle

Una casa che muta a ogni salto non ha un'identita': ha un costume.
Il conto e' mutazioni su 168 salti giocati.

| casa | mutazioni | ogni quanti salti |
|---|---|---|
| ENT_ALDRIC | 4 | 1 ogni 42.0 |
| ENT_LIBERE | 22 | 1 ogni 7.6 |
| ENT_LYRA | 2 | 1 ogni 84.0 |
| ENT_NAHR | 28 | 1 ogni 6.0 |
| ENT_SALE | 2 | 1 ogni 84.0 |
| ENT_VAERAX | 26 | 1 ogni 6.5 |
| ENT_VETRO | 4 | 1 ogni 42.0 |

