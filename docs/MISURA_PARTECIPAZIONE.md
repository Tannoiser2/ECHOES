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
| Consigli | 105 | 104 |
| prese di posizione dei non proponenti | 315 | 312 |
| — SUPPORT | 97 (31%) | 94 (30%) |
| — OPPOSE | 122 (39%) | 134 (43%) |
| — ABSTAIN | 96 (30%) | 84 (27%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 5 (5%) | 9 (9%) |
| Consigli con un OPPOSE dichiarato | 86 (82%) | 80 (77%) |
| carte impegnate dal proponente, per Consiglio | 1.62 | 1.95 |
| carte impegnate dagli altri tre, per Consiglio | 3.15 | 2.97 |
| non proponenti che impegnano almeno una carta | 171 (54%) | 180 (58%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.46 | 1.88 |
| **Consigli con opposizione nel margine** | **74 (70%)** | **67 (64%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 30 | 29 |
| FAILURE | 37 | 36 |
| SUCCESS | 21 | 26 |
| SUCCESS_WITH_COST | 17 | 13 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 13 | 12 | 13 |
| Re Aldric | uniforme | 10 | 14 | 11 |
| Kessa dei Fuochi | misto | 12 | 23 | 15 |
| Kessa dei Fuochi | uniforme | 12 | 29 | 14 |
| Le Città Libere | misto | 10 | 14 | 8 |
| Le Città Libere | uniforme | 13 | 12 | 6 |
| Lyra | misto | 20 | 10 | 7 |
| Lyra | uniforme | 19 | 15 | 6 |
| Popolo Nahr | misto | 16 | 16 | 9 |
| Popolo Nahr | uniforme | 13 | 9 | 14 |
| Maestra Ilve | misto | 15 | 11 | 18 |
| Maestra Ilve | uniforme | 14 | 11 | 17 |
| Vaerax | misto | 4 | 16 | 18 |
| Vaerax | uniforme | 6 | 21 | 9 |
| Priore Anselmo | misto | 7 | 20 | 8 |
| Priore Anselmo | uniforme | 7 | 23 | 7 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 22 | 0 | 45 |
| aggressivo | 24 | 58 | 0 |
| distratto | 22 | 39 | 28 |
| ostinato | 29 | 25 | 23 |

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
