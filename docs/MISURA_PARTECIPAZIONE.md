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
| Consigli | 105 | 105 |
| prese di posizione dei non proponenti | 315 | 315 |
| — SUPPORT | 101 (32%) | 88 (28%) |
| — OPPOSE | 120 (38%) | 142 (45%) |
| — ABSTAIN | 94 (30%) | 85 (27%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 5 (5%) | 8 (8%) |
| Consigli con un OPPOSE dichiarato | 87 (83%) | 86 (82%) |
| carte impegnate dal proponente, per Consiglio | 1.66 | 1.93 |
| carte impegnate dagli altri tre, per Consiglio | 3.15 | 3.00 |
| non proponenti che impegnano almeno una carta | 171 (54%) | 182 (58%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.50 | 1.66 |
| **Consigli con opposizione nel margine** | **75 (71%)** | **74 (70%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 29 | 28 |
| FAILURE | 36 | 39 |
| SUCCESS | 22 | 26 |
| SUCCESS_WITH_COST | 18 | 12 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 13 | 11 | 12 |
| Re Aldric | uniforme | 9 | 13 | 12 |
| Kessa dei Fuochi | misto | 13 | 24 | 14 |
| Kessa dei Fuochi | uniforme | 12 | 37 | 9 |
| Le Città Libere | misto | 10 | 14 | 8 |
| Le Città Libere | uniforme | 13 | 11 | 8 |
| Lyra | misto | 20 | 11 | 7 |
| Lyra | uniforme | 18 | 16 | 7 |
| Popolo Nahr | misto | 17 | 15 | 9 |
| Popolo Nahr | uniforme | 11 | 11 | 15 |
| Maestra Ilve | misto | 16 | 10 | 18 |
| Maestra Ilve | uniforme | 13 | 11 | 16 |
| Vaerax | misto | 5 | 16 | 18 |
| Vaerax | uniforme | 5 | 21 | 11 |
| Priore Anselmo | misto | 7 | 19 | 8 |
| Priore Anselmo | uniforme | 7 | 22 | 7 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 24 | 0 | 44 |
| aggressivo | 26 | 56 | 0 |
| distratto | 23 | 39 | 27 |
| ostinato | 28 | 25 | 23 |

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
