# Misura della partecipazione — chi gioca davvero un Consiglio

Generato da `tools/run_participation_probe.sh` (D-451). **Non si scrive a mano.**

30 anni pescati di CHR_00, semi da 7000, sui due tavoli del cancello: **misto**
(quattro caratteri diversi) e **uniforme** (quattro ottimizzatori). Per ogni
Consiglio si guarda chi **non** propone: che posizione prende, quante carte
impegna, e se alla fine sul piatto c'e' un'opposizione che pesa nel margine.

Il cancello dei 100 semi conta i Consigli e i loro esiti, non chi ci partecipa:
un Consiglio con tre astenuti conta verde quanto uno combattuto. Questa misura
conta l'altra cosa. **Il numero che decide e' l'ultima riga della prima tabella**:
se su un tavolo intero e' zero, il cancello e' rosso.

## Il conto

| | misto | uniforme |
|---|---|---|
| Consigli | 106 | 106 |
| prese di posizione dei non proponenti | 318 | 318 |
| — SUPPORT | 12 (4%) | 12 (4%) |
| — CONDITION | 28 (9%) | 32 (10%) |
| — OPPOSE | 79 (25%) | 10 (3%) |
| — ABSTAIN | 199 (63%) | 264 (83%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 18 (17%) | 74 (70%) |
| Consigli con un OPPOSE o una CONDITION dichiarati | 83 (78%) | 22 (21%) |
| carte impegnate dal proponente, per Consiglio | 1.60 | 1.78 |
| carte impegnate dagli altri tre, per Consiglio | 1.71 | 0.56 |
| non proponenti che impegnano almeno una carta | 93 (29%) | 46 (14%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| margine medio | 1.03 | 4.11 |
| **Consigli con opposizione nel margine** | **58 (55%)** | **9 (8%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 23 | 39 |
| FAILURE | 43 | 4 |
| SUCCESS | 20 | 56 |
| SUCCESS_WITH_COST | 20 | 7 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | CONDITION | OPPOSE | ABSTAIN |
|---|---|---|---|---|---|
| Re Aldric | misto | 1 | 3 | 13 | 18 |
| Re Aldric | uniforme | 0 | 2 | 3 | 29 |
| Kessa dei Fuochi | misto | 1 | 3 | 6 | 39 |
| Kessa dei Fuochi | uniforme | 2 | 7 | 1 | 50 |
| Le Città Libere | misto | 0 | 8 | 7 | 19 |
| Le Città Libere | uniforme | 3 | 3 | 2 | 23 |
| Lyra | misto | 2 | 3 | 13 | 21 |
| Lyra | uniforme | 3 | 6 | 1 | 32 |
| Popolo Nahr | misto | 2 | 3 | 17 | 25 |
| Popolo Nahr | uniforme | 0 | 3 | 0 | 40 |
| Maestra Ilve | misto | 2 | 2 | 7 | 32 |
| Maestra Ilve | uniforme | 0 | 2 | 2 | 33 |
| Vaerax | misto | 3 | 3 | 8 | 22 |
| Vaerax | uniforme | 2 | 8 | 0 | 27 |
| Priore Anselmo | misto | 1 | 3 | 8 | 23 |
| Priore Anselmo | uniforme | 2 | 1 | 1 | 30 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | CONDITION | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| prudente | 6 | 14 | 0 | 57 |
| aggressivo | 1 | 0 | 77 | 0 |
| distratto | 4 | 7 | 0 | 75 |
| ostinato | 1 | 7 | 2 | 67 |

## Come leggerla

- Una **posizione dichiarata** (OPPOSE, CONDITION) e una **opposizione nel
  margine** sono due cose: la seconda vuole carte impegnate contro, o un gettone
  comprato contro (D-419). Un OPPOSE a mani vuote non sposta niente.
- Col tavolo in silenzio il proponente prende il bonus del silenzio-assenso
  (PZ-5, D-267): un Consiglio dove nessuno parla non e' neutro.
- Le sedie automatiche prendono posizione solo quando la proposta tocca il loro
  Destino. L'economia di D-280 — gli avversari scelgono in che moneta paga il
  proponente — c'e' dalla 0.1.308 (ISSUES 72): questa misura dice quanto viene
  giocata davvero.
