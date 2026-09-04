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
| Consigli | 108 | 103 |
| prese di posizione dei non proponenti | 324 | 309 |
| — SUPPORT | 95 (29%) | 82 (27%) |
| — OPPOSE | 120 (37%) | 124 (40%) |
| — ABSTAIN | 109 (34%) | 103 (33%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 8 (7%) | 19 (18%) |
| Consigli con un OPPOSE dichiarato | 88 (81%) | 67 (65%) |
| carte impegnate dal proponente, per Consiglio | 1.62 | 1.91 |
| carte impegnate dagli altri tre, per Consiglio | 3.05 | 2.70 |
| non proponenti che impegnano almeno una carta | 171 (53%) | 167 (54%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.80 | 1.77 |
| **Consigli con opposizione nel margine** | **78 (72%)** | **58 (56%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 33 | 28 |
| FAILURE | 37 | 38 |
| SUCCESS | 21 | 26 |
| SUCCESS_WITH_COST | 17 | 11 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 15 | 12 | 12 |
| Re Aldric | uniforme | 13 | 8 | 17 |
| Kessa dei Fuochi | misto | 10 | 23 | 20 |
| Kessa dei Fuochi | uniforme | 10 | 28 | 15 |
| Le Città Libere | misto | 13 | 13 | 9 |
| Le Città Libere | uniforme | 13 | 10 | 7 |
| Lyra | misto | 11 | 14 | 13 |
| Lyra | uniforme | 10 | 16 | 13 |
| Popolo Nahr | misto | 19 | 15 | 9 |
| Popolo Nahr | uniforme | 13 | 9 | 14 |
| Maestra Ilve | misto | 16 | 11 | 15 |
| Maestra Ilve | uniforme | 12 | 13 | 15 |
| Vaerax | misto | 6 | 14 | 18 |
| Vaerax | uniforme | 4 | 19 | 13 |
| Priore Anselmo | misto | 5 | 18 | 13 |
| Priore Anselmo | uniforme | 7 | 21 | 9 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 25 | 0 | 46 |
| aggressivo | 28 | 59 | 0 |
| distratto | 18 | 31 | 35 |
| ostinato | 24 | 30 | 28 |

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
