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
| Consigli | 144 | 144 |
| prese di posizione dei non proponenti | 432 | 432 |
| — SUPPORT | 184 (43%) | 179 (41%) |
| — OPPOSE | 248 (57%) | 253 (59%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 139 (97%) | 135 (94%) |
| carte impegnate dal proponente, per Consiglio | 1.24 | 1.52 |
| carte impegnate dagli altri tre, per Consiglio | 2.81 | 2.38 |
| non proponenti che impegnano almeno una carta | 328 (76%) | 343 (79%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 0.16 | 0.87 |
| **Consigli con opposizione nel margine** | **121 (84%)** | **124 (86%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 40 | 35 |
| DECISIVE_SUCCESS | 15 | 13 |
| FAILURE | 56 | 51 |
| SUCCESS | 27 | 31 |
| SUCCESS_WITH_COST | 6 | 14 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 34 | 24 | 0 |
| Re Aldric | uniforme | 31 | 27 | 0 |
| Kessa dei Fuochi | misto | 32 | 39 | 0 |
| Kessa dei Fuochi | uniforme | 33 | 39 | 0 |
| Le Città Libere | misto | 17 | 26 | 0 |
| Le Città Libere | uniforme | 16 | 27 | 0 |
| Lyra | misto | 18 | 34 | 0 |
| Lyra | uniforme | 19 | 40 | 0 |
| Popolo Nahr | misto | 25 | 40 | 0 |
| Popolo Nahr | uniforme | 21 | 41 | 0 |
| Maestra Ilve | misto | 21 | 30 | 0 |
| Maestra Ilve | uniforme | 23 | 28 | 0 |
| Vaerax | misto | 18 | 30 | 0 |
| Vaerax | uniforme | 14 | 31 | 0 |
| Priore Anselmo | misto | 19 | 25 | 0 |
| Priore Anselmo | uniforme | 22 | 20 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 46 | 55 | 0 |
| aggressivo | 44 | 66 | 0 |
| distratto | 44 | 65 | 0 |
| ostinato | 50 | 62 | 0 |

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

## Il mucchio contro le carte (D-467, giro 1)

Da [D-467](DECISIONS.md#d-467) il Consiglio si vota **senza dado, contro il
mucchio**: la parte che vince deve superare l'altra e arrivare ai gettoni
caduti sulla domanda. Prima di scrivere la soglia si misura: quanto vale il
mucchio quando un Consiglio si apre — il valore rivelato del suo Tema — e
quanto valgono le carte della parte piu' forte. Con la regola di oggi la
parte piu' forte e' quella che ha impegnato di piu' fra chi sostiene e chi
si oppone.

| | misto | uniforme |
|---|---|---|
| anni giocati | 30 | 30 |
| **anni con meno di sei domande** | **0** | **0** |
| mucchio medio (valore) | 4.20 | 4.00 |
| gettoni medi sul mucchio | 4.15 | 3.88 |
| carte della parte piu' forte (media) | 4.82 | 4.60 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **93 (65%)** | **99 (69%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 0 | 2 |
| 1 | 5 | 9 |
| 2 | 25 | 19 |
| 3 | 17 | 26 |
| 4 | 31 | 27 |
| 5 | 21 | 23 |
| 6 | 45 | 38 |
