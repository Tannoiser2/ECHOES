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
| Consigli | 107 | 103 |
| prese di posizione dei non proponenti | 321 | 309 |
| — SUPPORT | 101 (31%) | 97 (31%) |
| — OPPOSE | 117 (36%) | 123 (40%) |
| — ABSTAIN | 103 (32%) | 89 (29%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 6 (6%) | 20 (19%) |
| Consigli con un OPPOSE dichiarato | 84 (79%) | 65 (63%) |
| carte impegnate dal proponente, per Consiglio | 1.63 | 1.97 |
| carte impegnate dagli altri tre, per Consiglio | 2.98 | 2.92 |
| non proponenti che impegnano almeno una carta | 174 (54%) | 180 (58%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.86 | 1.98 |
| **Consigli con opposizione nel margine** | **73 (68%)** | **57 (55%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 34 | 28 |
| FAILURE | 37 | 31 |
| SUCCESS | 18 | 33 |
| SUCCESS_WITH_COST | 18 | 11 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 16 | 12 | 11 |
| Re Aldric | uniforme | 12 | 9 | 15 |
| Kessa dei Fuochi | misto | 13 | 18 | 23 |
| Kessa dei Fuochi | uniforme | 13 | 28 | 14 |
| Le Città Libere | misto | 12 | 14 | 6 |
| Le Città Libere | uniforme | 16 | 9 | 6 |
| Lyra | misto | 15 | 11 | 13 |
| Lyra | uniforme | 15 | 14 | 12 |
| Popolo Nahr | misto | 13 | 20 | 7 |
| Popolo Nahr | uniforme | 14 | 12 | 9 |
| Maestra Ilve | misto | 14 | 12 | 16 |
| Maestra Ilve | uniforme | 12 | 18 | 10 |
| Vaerax | misto | 8 | 16 | 14 |
| Vaerax | uniforme | 9 | 18 | 11 |
| Priore Anselmo | misto | 10 | 14 | 13 |
| Priore Anselmo | uniforme | 6 | 15 | 12 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 26 | 0 | 49 |
| aggressivo | 30 | 54 | 0 |
| distratto | 22 | 29 | 30 |
| ostinato | 23 | 34 | 24 |

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
