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
| Consigli | 137 | 138 |
| prese di posizione dei non proponenti | 411 | 414 |
| — SUPPORT | 198 (48%) | 164 (40%) |
| — OPPOSE | 211 (51%) | 247 (60%) |
| — ABSTAIN | 2 (0%) | 3 (1%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 131 (96%) | 132 (96%) |
| carte impegnate dal proponente, per Consiglio | 1.37 | 1.39 |
| carte impegnate dagli altri tre, per Consiglio | 3.42 | 3.43 |
| non proponenti che impegnano almeno una carta | 312 (76%) | 327 (79%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.99 | 0.93 |
| **Consigli con opposizione nel margine** | **131 (96%)** | **132 (96%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 41 | 53 |
| DECISIVE_SUCCESS | 42 | 32 |
| FAILURE | 14 | 9 |
| SUCCESS | 31 | 30 |
| SUCCESS_WITH_COST | 9 | 14 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 28 | 28 | 0 |
| Re Aldric | uniforme | 22 | 30 | 0 |
| Kessa dei Fuochi | misto | 29 | 38 | 0 |
| Kessa dei Fuochi | uniforme | 27 | 45 | 0 |
| Le Città Libere | misto | 29 | 15 | 0 |
| Le Città Libere | uniforme | 18 | 24 | 0 |
| Lyra | misto | 24 | 23 | 0 |
| Lyra | uniforme | 16 | 36 | 0 |
| Popolo Nahr | misto | 28 | 31 | 0 |
| Popolo Nahr | uniforme | 22 | 39 | 0 |
| Maestra Ilve | misto | 24 | 26 | 0 |
| Maestra Ilve | uniforme | 23 | 25 | 0 |
| Vaerax | misto | 22 | 22 | 2 |
| Vaerax | uniforme | 15 | 26 | 3 |
| Priore Anselmo | misto | 14 | 28 | 0 |
| Priore Anselmo | uniforme | 21 | 22 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 109 | 0 | 0 |
| aggressivo | 18 | 76 | 0 |
| distratto | 33 | 70 | 0 |
| ostinato | 38 | 65 | 2 |

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
| mucchio medio (valore) | 4.14 | 4.10 |
| gettoni medi sul mucchio | 3.90 | 3.81 |
| carte della parte piu' forte (media) | 9.09 | 9.02 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **132 (96%)** | **137 (99%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 1 |
| 1 | 6 | 5 |
| 2 | 21 | 19 |
| 3 | 24 | 29 |
| 4 | 20 | 25 |
| 5 | 23 | 18 |
| 6 | 42 | 41 |
