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
| Consigli | 142 | 135 |
| prese di posizione dei non proponenti | 426 | 405 |
| — SUPPORT | 206 (48%) | 160 (40%) |
| — OPPOSE | 220 (52%) | 245 (60%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 134 (94%) | 134 (99%) |
| carte impegnate dal proponente, per Consiglio | 1.30 | 1.50 |
| carte impegnate dagli altri tre, per Consiglio | 3.49 | 3.49 |
| non proponenti che impegnano almeno una carta | 323 (76%) | 316 (78%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.42 | 0.65 |
| **Consigli con opposizione nel margine** | **134 (94%)** | **134 (99%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 53 | 53 |
| DECISIVE_SUCCESS | 34 | 34 |
| FAILURE | 13 | 15 |
| SUCCESS | 35 | 23 |
| SUCCESS_WITH_COST | 7 | 10 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 25 | 26 | 0 |
| Re Aldric | uniforme | 19 | 32 | 0 |
| Kessa dei Fuochi | misto | 33 | 36 | 0 |
| Kessa dei Fuochi | uniforme | 25 | 39 | 0 |
| Le Città Libere | misto | 25 | 21 | 0 |
| Le Città Libere | uniforme | 14 | 29 | 0 |
| Lyra | misto | 23 | 31 | 0 |
| Lyra | uniforme | 24 | 28 | 0 |
| Popolo Nahr | misto | 29 | 30 | 0 |
| Popolo Nahr | uniforme | 29 | 30 | 0 |
| Maestra Ilve | misto | 28 | 27 | 0 |
| Maestra Ilve | uniforme | 21 | 26 | 0 |
| Vaerax | misto | 24 | 27 | 0 |
| Vaerax | uniforme | 14 | 35 | 0 |
| Priore Anselmo | misto | 19 | 22 | 0 |
| Priore Anselmo | uniforme | 14 | 26 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 107 | 0 | 0 |
| aggressivo | 24 | 77 | 0 |
| distratto | 42 | 67 | 0 |
| ostinato | 33 | 76 | 0 |

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
| mucchio medio (valore) | 4.17 | 4.20 |
| gettoni medi sul mucchio | 4.32 | 4.79 |
| carte della parte piu' forte (media) | 8.89 | 9.09 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **139 (98%)** | **132 (98%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 3 | 3 |
| 1 | 4 | 4 |
| 2 | 18 | 21 |
| 3 | 29 | 26 |
| 4 | 20 | 11 |
| 5 | 23 | 21 |
| 6 | 45 | 49 |
