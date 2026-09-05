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
| Consigli | 102 | 103 |
| prese di posizione dei non proponenti | 306 | 309 |
| — SUPPORT | 91 (30%) | 92 (30%) |
| — OPPOSE | 128 (42%) | 139 (45%) |
| — ABSTAIN | 87 (28%) | 78 (25%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 2 (2%) | 10 (10%) |
| Consigli con un OPPOSE dichiarato | 90 (88%) | 84 (82%) |
| carte impegnate dal proponente, per Consiglio | 1.51 | 1.87 |
| carte impegnate dagli altri tre, per Consiglio | 2.95 | 2.81 |
| non proponenti che impegnano almeno una carta | 168 (55%) | 174 (56%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.32 | 2.01 |
| **Consigli con opposizione nel margine** | **76 (75%)** | **72 (70%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 26 | 31 |
| FAILURE | 36 | 34 |
| SUCCESS | 23 | 25 |
| SUCCESS_WITH_COST | 17 | 13 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 10 | 12 | 15 |
| Re Aldric | uniforme | 8 | 16 | 15 |
| Kessa dei Fuochi | misto | 11 | 29 | 16 |
| Kessa dei Fuochi | uniforme | 14 | 40 | 6 |
| Le Città Libere | misto | 13 | 15 | 7 |
| Le Città Libere | uniforme | 13 | 10 | 10 |
| Lyra | misto | 22 | 13 | 7 |
| Lyra | uniforme | 20 | 11 | 2 |
| Popolo Nahr | misto | 7 | 20 | 8 |
| Popolo Nahr | uniforme | 11 | 14 | 16 |
| Maestra Ilve | misto | 15 | 9 | 14 |
| Maestra Ilve | uniforme | 17 | 8 | 10 |
| Vaerax | misto | 4 | 14 | 15 |
| Vaerax | uniforme | 4 | 17 | 12 |
| Priore Anselmo | misto | 9 | 16 | 5 |
| Priore Anselmo | uniforme | 5 | 23 | 7 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 22 | 0 | 46 |
| aggressivo | 20 | 60 | 0 |
| distratto | 24 | 37 | 18 |
| ostinato | 25 | 31 | 23 |

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
