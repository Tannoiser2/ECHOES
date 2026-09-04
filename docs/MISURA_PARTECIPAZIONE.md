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
| Consigli | 105 | 106 |
| prese di posizione dei non proponenti | 315 | 318 |
| — SUPPORT | 100 (32%) | 91 (29%) |
| — OPPOSE | 125 (40%) | 142 (45%) |
| — ABSTAIN | 90 (29%) | 85 (27%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 4 (4%) | 8 (8%) |
| Consigli con un OPPOSE dichiarato | 89 (85%) | 87 (82%) |
| carte impegnate dal proponente, per Consiglio | 1.64 | 1.90 |
| carte impegnate dagli altri tre, per Consiglio | 3.15 | 3.01 |
| non proponenti che impegnano almeno una carta | 173 (55%) | 183 (58%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.52 | 1.79 |
| **Consigli con opposizione nel margine** | **76 (72%)** | **74 (70%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 30 | 29 |
| FAILURE | 37 | 39 |
| SUCCESS | 21 | 26 |
| SUCCESS_WITH_COST | 17 | 12 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 13 | 11 | 13 |
| Re Aldric | uniforme | 11 | 13 | 13 |
| Kessa dei Fuochi | misto | 13 | 25 | 13 |
| Kessa dei Fuochi | uniforme | 13 | 38 | 9 |
| Le Città Libere | misto | 10 | 14 | 8 |
| Le Città Libere | uniforme | 13 | 11 | 8 |
| Lyra | misto | 19 | 11 | 6 |
| Lyra | uniforme | 18 | 14 | 6 |
| Popolo Nahr | misto | 16 | 18 | 9 |
| Popolo Nahr | uniforme | 11 | 11 | 17 |
| Maestra Ilve | misto | 16 | 10 | 18 |
| Maestra Ilve | uniforme | 13 | 11 | 16 |
| Vaerax | misto | 6 | 16 | 17 |
| Vaerax | uniforme | 6 | 20 | 10 |
| Priore Anselmo | misto | 7 | 20 | 6 |
| Priore Anselmo | uniforme | 6 | 24 | 6 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 24 | 0 | 45 |
| aggressivo | 25 | 59 | 0 |
| distratto | 22 | 41 | 24 |
| ostinato | 29 | 25 | 21 |

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
