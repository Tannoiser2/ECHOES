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
| Consigli | 170 | 170 |
| prese di posizione dei non proponenti | 510 | 510 |
| — SUPPORT | 252 (49%) | 202 (40%) |
| — OPPOSE | 258 (51%) | 308 (60%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 158 (93%) | 165 (97%) |
| carte impegnate dal proponente, per Consiglio | 1.41 | 1.54 |
| carte impegnate dagli altri tre, per Consiglio | 3.93 | 3.94 |
| non proponenti che impegnano almeno una carta | 411 (81%) | 406 (80%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.73 | 0.67 |
| **Consigli con opposizione nel margine** | **158 (93%)** | **165 (97%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 54 | 72 |
| DECISIVE_SUCCESS | 48 | 42 |
| FAILURE | 26 | 16 |
| SUCCESS | 35 | 30 |
| SUCCESS_WITH_COST | 7 | 10 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 27 | 34 | 0 |
| Re Aldric | uniforme | 19 | 42 | 0 |
| Kessa dei Fuochi | misto | 45 | 39 | 0 |
| Kessa dei Fuochi | uniforme | 39 | 44 | 0 |
| Le Città Libere | misto | 27 | 27 | 0 |
| Le Città Libere | uniforme | 14 | 38 | 0 |
| Lyra | misto | 36 | 31 | 0 |
| Lyra | uniforme | 24 | 41 | 0 |
| Popolo Nahr | misto | 30 | 46 | 0 |
| Popolo Nahr | uniforme | 35 | 42 | 0 |
| Maestra Ilve | misto | 32 | 22 | 0 |
| Maestra Ilve | uniforme | 25 | 34 | 0 |
| Vaerax | misto | 26 | 29 | 0 |
| Vaerax | uniforme | 22 | 35 | 0 |
| Priore Anselmo | misto | 29 | 30 | 0 |
| Priore Anselmo | uniforme | 24 | 32 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 123 | 0 | 0 |
| aggressivo | 40 | 89 | 0 |
| distratto | 42 | 85 | 0 |
| ostinato | 47 | 84 | 0 |

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
| mucchio medio (valore) | 5.22 | 5.07 |
| gettoni medi sul mucchio | 6.45 | 6.66 |
| carte della parte piu' forte (media) | 9.17 | 9.59 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **154 (91%)** | **162 (95%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 1 | 2 | 0 |
| 2 | 8 | 16 |
| 3 | 10 | 12 |
| 4 | 20 | 19 |
| 5 | 21 | 20 |
| 6 | 109 | 103 |
