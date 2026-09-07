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
| Consigli | 142 | 145 |
| prese di posizione dei non proponenti | 426 | 435 |
| — SUPPORT | 172 (40%) | 180 (41%) |
| — OPPOSE | 254 (60%) | 255 (59%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 137 (96%) | 137 (94%) |
| carte impegnate dal proponente, per Consiglio | 1.20 | 1.41 |
| carte impegnate dagli altri tre, per Consiglio | 3.28 | 3.16 |
| non proponenti che impegnano almeno una carta | 311 (73%) | 331 (76%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 0.89 | 1.40 |
| **Consigli con opposizione nel margine** | **137 (96%)** | **137 (94%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 58 | 55 |
| DECISIVE_SUCCESS | 36 | 40 |
| FAILURE | 11 | 8 |
| SUCCESS | 29 | 31 |
| SUCCESS_WITH_COST | 8 | 11 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 29 | 29 | 0 |
| Re Aldric | uniforme | 23 | 28 | 0 |
| Kessa dei Fuochi | misto | 32 | 40 | 0 |
| Kessa dei Fuochi | uniforme | 35 | 35 | 0 |
| Le Città Libere | misto | 11 | 29 | 0 |
| Le Città Libere | uniforme | 14 | 31 | 0 |
| Lyra | misto | 19 | 30 | 0 |
| Lyra | uniforme | 25 | 34 | 0 |
| Popolo Nahr | misto | 27 | 37 | 0 |
| Popolo Nahr | uniforme | 27 | 39 | 0 |
| Maestra Ilve | misto | 21 | 33 | 0 |
| Maestra Ilve | uniforme | 18 | 37 | 0 |
| Vaerax | misto | 17 | 28 | 0 |
| Vaerax | uniforme | 16 | 32 | 0 |
| Priore Anselmo | misto | 16 | 28 | 0 |
| Priore Anselmo | uniforme | 22 | 19 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 45 | 57 | 0 |
| aggressivo | 41 | 67 | 0 |
| distratto | 39 | 64 | 0 |
| ostinato | 47 | 66 | 0 |

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
| mucchio medio (valore) | 4.37 | 4.06 |
| gettoni medi sul mucchio | 4.17 | 3.97 |
| carte della parte piu' forte (media) | 9.30 | 9.36 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **138 (97%)** | **143 (99%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 0 | 2 |
| 1 | 3 | 6 |
| 2 | 19 | 14 |
| 3 | 23 | 33 |
| 4 | 27 | 34 |
| 5 | 17 | 16 |
| 6 | 53 | 40 |
