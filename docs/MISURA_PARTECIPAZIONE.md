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
| Consigli | 105 | 108 |
| prese di posizione dei non proponenti | 315 | 324 |
| — SUPPORT | 15 (5%) | 13 (4%) |
| — OPPOSE | 95 (30%) | 44 (14%) |
| — ABSTAIN | 205 (65%) | 267 (82%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 16 (15%) | 74 (69%) |
| Consigli con un OPPOSE dichiarato | 82 (78%) | 23 (21%) |
| carte impegnate dal proponente, per Consiglio | 1.59 | 1.78 |
| carte impegnate dagli altri tre, per Consiglio | 1.61 | 0.58 |
| non proponenti che impegnano almeno una carta | 83 (26%) | 49 (15%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| margine medio | 0.56 | 3.18 |
| **Consigli con opposizione nel margine** | **63 (60%)** | **22 (20%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 15 | 35 |
| FAILURE | 46 | 18 |
| SUCCESS | 29 | 48 |
| SUCCESS_WITH_COST | 15 | 7 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 2 | 14 | 21 |
| Re Aldric | uniforme | 0 | 5 | 29 |
| Kessa dei Fuochi | misto | 1 | 8 | 39 |
| Kessa dei Fuochi | uniforme | 2 | 8 | 52 |
| Le Città Libere | misto | 0 | 11 | 22 |
| Le Città Libere | uniforme | 3 | 6 | 22 |
| Lyra | misto | 2 | 14 | 22 |
| Lyra | uniforme | 4 | 7 | 32 |
| Popolo Nahr | misto | 4 | 20 | 23 |
| Popolo Nahr | uniforme | 0 | 3 | 40 |
| Maestra Ilve | misto | 2 | 8 | 31 |
| Maestra Ilve | uniforme | 0 | 4 | 35 |
| Vaerax | misto | 3 | 10 | 24 |
| Vaerax | uniforme | 2 | 9 | 26 |
| Priore Anselmo | misto | 1 | 10 | 23 |
| Priore Anselmo | uniforme | 2 | 2 | 31 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 6 | 0 | 67 |
| aggressivo | 3 | 77 | 0 |
| distratto | 4 | 8 | 74 |
| ostinato | 2 | 10 | 64 |

## Come leggerla

- Una **posizione dichiarata** (OPPOSE) e una **opposizione nel
  margine** sono due cose: la seconda vuole carte impegnate contro, o un gettone
  comprato contro (D-419). Un OPPOSE a mani vuote non sposta niente.
- Col tavolo in silenzio il proponente prende il bonus del silenzio-assenso
  (PZ-5, D-267): un Consiglio dove nessuno parla non e' neutro.
- Le sedie automatiche prendono posizione solo quando la proposta tocca il loro
  Destino. L'economia di D-280 — gli avversari scelgono in che moneta paga il
  proponente — c'e' dalla 0.1.308 (ISSUES 72): questa misura dice quanto viene
  giocata davvero.
