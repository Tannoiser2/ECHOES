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
| Consigli | 102 | 104 |
| prese di posizione dei non proponenti | 306 | 312 |
| — SUPPORT | 87 (28%) | 91 (29%) |
| — OPPOSE | 132 (43%) | 141 (45%) |
| — ABSTAIN | 87 (28%) | 80 (26%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 1 (1%) | 10 (10%) |
| Consigli con un OPPOSE dichiarato | 90 (88%) | 89 (86%) |
| carte impegnate dal proponente, per Consiglio | 1.48 | 1.84 |
| carte impegnate dagli altri tre, per Consiglio | 3.19 | 3.15 |
| non proponenti che impegnano almeno una carta | 177 (58%) | 185 (59%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 0.32 | 1.58 |
| **Consigli con opposizione nel margine** | **80 (78%)** | **78 (75%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| DECISIVE_SUCCESS | 17 | 29 |
| FAILURE | 42 | 36 |
| SUCCESS | 21 | 24 |
| SUCCESS_WITH_COST | 22 | 15 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 5 | 14 | 15 |
| Re Aldric | uniforme | 12 | 10 | 18 |
| Kessa dei Fuochi | misto | 21 | 21 | 12 |
| Kessa dei Fuochi | uniforme | 16 | 29 | 5 |
| Le Città Libere | misto | 9 | 13 | 7 |
| Le Città Libere | uniforme | 11 | 12 | 6 |
| Lyra | misto | 9 | 19 | 11 |
| Lyra | uniforme | 14 | 23 | 5 |
| Popolo Nahr | misto | 11 | 17 | 12 |
| Popolo Nahr | uniforme | 11 | 17 | 15 |
| Maestra Ilve | misto | 14 | 15 | 14 |
| Maestra Ilve | uniforme | 13 | 14 | 16 |
| Vaerax | misto | 5 | 19 | 10 |
| Vaerax | uniforme | 8 | 23 | 8 |
| Priore Anselmo | misto | 13 | 14 | 6 |
| Priore Anselmo | uniforme | 6 | 13 | 7 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 29 | 0 | 52 |
| aggressivo | 19 | 50 | 0 |
| distratto | 21 | 47 | 9 |
| ostinato | 18 | 35 | 26 |

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
| mucchio medio (valore) | 4.68 | 4.43 |
| gettoni medi sul mucchio | 4.42 | 4.34 |
| carte della parte piu' forte (media) | 5.58 | 6.08 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **66 (65%)** | **66 (63%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 1 | 1 | 4 |
| 2 | 11 | 15 |
| 3 | 10 | 10 |
| 4 | 19 | 14 |
| 5 | 18 | 25 |
| 6 | 43 | 36 |
