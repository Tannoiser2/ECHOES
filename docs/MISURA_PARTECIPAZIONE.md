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
| — SUPPORT | 88 (29%) | 88 (28%) |
| — OPPOSE | 130 (43%) | 146 (46%) |
| — ABSTAIN | 85 (28%) | 81 (26%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 2 (2%) | 9 (9%) |
| Consigli con un OPPOSE dichiarato | 89 (88%) | 90 (86%) |
| carte impegnate dal proponente, per Consiglio | 1.50 | 1.87 |
| carte impegnate dagli altri tre, per Consiglio | 3.18 | 3.12 |
| non proponenti che impegnano almeno una carta | 176 (58%) | 187 (59%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 0.41 | 1.20 |
| **Consigli con opposizione nel margine** | **79 (78%)** | **81 (77%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 18 | 28 |
| FAILURE | 41 | 40 |
| SUCCESS | 20 | 23 |
| SUCCESS_WITH_COST | 22 | 14 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 5 | 14 | 16 |
| Re Aldric | uniforme | 11 | 11 | 19 |
| Kessa dei Fuochi | misto | 21 | 20 | 11 |
| Kessa dei Fuochi | uniforme | 16 | 30 | 6 |
| Le Città Libere | misto | 9 | 13 | 7 |
| Le Città Libere | uniforme | 11 | 13 | 6 |
| Lyra | misto | 10 | 18 | 10 |
| Lyra | uniforme | 16 | 23 | 4 |
| Popolo Nahr | misto | 11 | 17 | 12 |
| Popolo Nahr | uniforme | 10 | 19 | 15 |
| Maestra Ilve | misto | 14 | 15 | 14 |
| Maestra Ilve | uniforme | 13 | 13 | 15 |
| Vaerax | misto | 4 | 20 | 10 |
| Vaerax | uniforme | 5 | 25 | 9 |
| Priore Anselmo | misto | 14 | 13 | 5 |
| Priore Anselmo | uniforme | 6 | 12 | 7 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 31 | 0 | 51 |
| aggressivo | 18 | 49 | 0 |
| distratto | 21 | 46 | 9 |
| ostinato | 18 | 35 | 25 |

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
| mucchio medio (valore) | 4.67 | 4.47 |
| gettoni medi sul mucchio | 4.48 | 4.31 |
| carte della parte piu' forte (media) | 5.60 | 5.99 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **66 (65%)** | **66 (63%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 1 | 1 | 4 |
| 2 | 9 | 14 |
| 3 | 11 | 11 |
| 4 | 21 | 14 |
| 5 | 18 | 24 |
| 6 | 41 | 38 |
