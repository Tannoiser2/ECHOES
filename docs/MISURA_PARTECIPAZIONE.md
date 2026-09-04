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
| Consigli | 103 | 105 |
| prese di posizione dei non proponenti | 309 | 315 |
| — SUPPORT | 1 (0%) | 0 (0%) |
| — CONDITION | 2 (1%) | 3 (1%) |
| — OPPOSE | 11 (4%) | 1 (0%) |
| — ABSTAIN | 295 (95%) | 311 (99%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 93 (90%) | 103 (98%) |
| Consigli con un OPPOSE o una CONDITION dichiarati | 9 (9%) | 2 (2%) |
| carte impegnate dal proponente, per Consiglio | 1.59 | 1.77 |
| carte impegnate dagli altri tre, per Consiglio | 0.24 | 0.05 |
| non proponenti che impegnano almeno una carta | 12 (4%) | 4 (1%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| margine medio | 3.50 | 4.01 |
| **Consigli con opposizione nel margine** | **7 (7%)** | **1 (1%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 41 | 43 |
| FAILURE | 8 | 1 |
| SUCCESS | 47 | 51 |
| SUCCESS_WITH_COST | 7 | 10 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | CONDITION | OPPOSE | ABSTAIN |
|---|---|---|---|---|---|
| Re Aldric | misto | 0 | 0 | 3 | 35 |
| Re Aldric | uniforme | 0 | 0 | 1 | 34 |
| Kessa dei Fuochi | misto | 0 | 0 | 2 | 46 |
| Kessa dei Fuochi | uniforme | 0 | 1 | 0 | 55 |
| Le Città Libere | misto | 0 | 0 | 0 | 33 |
| Le Città Libere | uniforme | 0 | 0 | 0 | 30 |
| Lyra | misto | 0 | 0 | 3 | 34 |
| Lyra | uniforme | 0 | 0 | 0 | 39 |
| Popolo Nahr | misto | 1 | 1 | 1 | 41 |
| Popolo Nahr | uniforme | 0 | 0 | 0 | 42 |
| Maestra Ilve | misto | 0 | 1 | 1 | 40 |
| Maestra Ilve | uniforme | 0 | 1 | 0 | 40 |
| Vaerax | misto | 0 | 0 | 0 | 34 |
| Vaerax | uniforme | 0 | 1 | 0 | 36 |
| Priore Anselmo | misto | 0 | 0 | 1 | 32 |
| Priore Anselmo | uniforme | 0 | 0 | 0 | 35 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | CONDITION | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| prudente | 0 | 1 | 0 | 70 |
| aggressivo | 0 | 0 | 9 | 65 |
| distratto | 1 | 1 | 1 | 87 |
| ostinato | 0 | 0 | 1 | 73 |

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
