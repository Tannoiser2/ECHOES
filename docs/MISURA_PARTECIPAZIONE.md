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
| Consigli | 101 | 105 |
| prese di posizione dei non proponenti | 303 | 315 |
| — SUPPORT | 97 (32%) | 101 (32%) |
| — OPPOSE | 112 (37%) | 139 (44%) |
| — ABSTAIN | 94 (31%) | 75 (24%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 3 (3%) | 10 (10%) |
| Consigli con un OPPOSE dichiarato | 82 (81%) | 86 (82%) |
| carte impegnate dal proponente, per Consiglio | 1.59 | 1.86 |
| carte impegnate dagli altri tre, per Consiglio | 2.76 | 2.74 |
| non proponenti che impegnano almeno una carta | 159 (52%) | 177 (56%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.95 | 1.87 |
| **Consigli con opposizione nel margine** | **70 (69%)** | **76 (72%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 26 | 29 |
| FAILURE | 30 | 32 |
| SUCCESS | 26 | 30 |
| SUCCESS_WITH_COST | 19 | 14 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 11 | 12 | 16 |
| Re Aldric | uniforme | 12 | 17 | 12 |
| Kessa dei Fuochi | misto | 16 | 21 | 20 |
| Kessa dei Fuochi | uniforme | 14 | 40 | 6 |
| Le Città Libere | misto | 11 | 10 | 8 |
| Le Città Libere | uniforme | 11 | 9 | 9 |
| Lyra | misto | 22 | 14 | 6 |
| Lyra | uniforme | 22 | 14 | 2 |
| Popolo Nahr | misto | 7 | 22 | 8 |
| Popolo Nahr | uniforme | 16 | 15 | 16 |
| Maestra Ilve | misto | 16 | 8 | 15 |
| Maestra Ilve | uniforme | 17 | 7 | 12 |
| Vaerax | misto | 5 | 9 | 16 |
| Vaerax | uniforme | 4 | 16 | 11 |
| Priore Anselmo | misto | 9 | 16 | 5 |
| Priore Anselmo | uniforme | 5 | 21 | 7 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 26 | 0 | 45 |
| aggressivo | 20 | 54 | 0 |
| distratto | 27 | 29 | 25 |
| ostinato | 24 | 29 | 24 |

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
