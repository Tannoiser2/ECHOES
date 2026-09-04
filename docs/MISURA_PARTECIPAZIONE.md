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
| Consigli | 106 | 108 |
| prese di posizione dei non proponenti | 318 | 324 |
| — SUPPORT | 13 (4%) | 12 (4%) |
| — CONDITION | 28 (9%) | 35 (11%) |
| — OPPOSE | 81 (25%) | 12 (4%) |
| — ABSTAIN | 196 (62%) | 265 (82%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 16 (15%) | 72 (67%) |
| Consigli con un OPPOSE o una CONDITION dichiarati | 84 (79%) | 25 (23%) |
| carte impegnate dal proponente, per Consiglio | 1.61 | 1.78 |
| carte impegnate dagli altri tre, per Consiglio | 1.76 | 0.60 |
| non proponenti che impegnano almeno una carta | 95 (30%) | 50 (15%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| margine medio | 1.06 | 4.04 |
| **Consigli con opposizione nel margine** | **58 (55%)** | **11 (10%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 23 | 41 |
| FAILURE | 43 | 6 |
| SUCCESS | 21 | 55 |
| SUCCESS_WITH_COST | 19 | 6 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | CONDITION | OPPOSE | ABSTAIN |
|---|---|---|---|---|---|
| Re Aldric | misto | 1 | 3 | 13 | 17 |
| Re Aldric | uniforme | 0 | 2 | 3 | 30 |
| Kessa dei Fuochi | misto | 1 | 3 | 6 | 39 |
| Kessa dei Fuochi | uniforme | 1 | 7 | 1 | 52 |
| Le Città Libere | misto | 0 | 8 | 7 | 19 |
| Le Città Libere | uniforme | 3 | 3 | 3 | 20 |
| Lyra | misto | 2 | 3 | 14 | 21 |
| Lyra | uniforme | 4 | 6 | 1 | 33 |
| Popolo Nahr | misto | 3 | 3 | 17 | 24 |
| Popolo Nahr | uniforme | 0 | 4 | 0 | 39 |
| Maestra Ilve | misto | 2 | 2 | 8 | 31 |
| Maestra Ilve | uniforme | 0 | 2 | 2 | 34 |
| Vaerax | misto | 3 | 3 | 8 | 22 |
| Vaerax | uniforme | 2 | 9 | 1 | 27 |
| Priore Anselmo | misto | 1 | 3 | 8 | 23 |
| Priore Anselmo | uniforme | 2 | 2 | 1 | 30 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | CONDITION | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| prudente | 6 | 14 | 0 | 57 |
| aggressivo | 2 | 0 | 78 | 0 |
| distratto | 4 | 7 | 0 | 74 |
| ostinato | 1 | 7 | 3 | 65 |

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
