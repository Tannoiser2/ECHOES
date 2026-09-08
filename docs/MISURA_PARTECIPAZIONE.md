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
| Consigli | 143 | 135 |
| prese di posizione dei non proponenti | 429 | 405 |
| — SUPPORT | 212 (49%) | 157 (39%) |
| — OPPOSE | 217 (51%) | 248 (61%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 135 (94%) | 134 (99%) |
| carte impegnate dal proponente, per Consiglio | 1.22 | 1.44 |
| carte impegnate dagli altri tre, per Consiglio | 3.54 | 3.39 |
| non proponenti che impegnano almeno una carta | 332 (77%) | 316 (78%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.51 | 0.19 |
| **Consigli con opposizione nel margine** | **135 (94%)** | **134 (99%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 49 | 56 |
| DECISIVE_SUCCESS | 34 | 32 |
| FAILURE | 14 | 14 |
| SUCCESS | 39 | 22 |
| SUCCESS_WITH_COST | 7 | 11 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 25 | 24 | 0 |
| Re Aldric | uniforme | 22 | 30 | 0 |
| Kessa dei Fuochi | misto | 34 | 36 | 0 |
| Kessa dei Fuochi | uniforme | 25 | 40 | 0 |
| Le Città Libere | misto | 25 | 20 | 0 |
| Le Città Libere | uniforme | 12 | 30 | 0 |
| Lyra | misto | 23 | 31 | 0 |
| Lyra | uniforme | 23 | 27 | 0 |
| Popolo Nahr | misto | 33 | 27 | 0 |
| Popolo Nahr | uniforme | 29 | 30 | 0 |
| Maestra Ilve | misto | 30 | 27 | 0 |
| Maestra Ilve | uniforme | 19 | 28 | 0 |
| Vaerax | misto | 24 | 25 | 0 |
| Vaerax | uniforme | 13 | 37 | 0 |
| Priore Anselmo | misto | 18 | 27 | 0 |
| Priore Anselmo | uniforme | 14 | 26 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 109 | 0 | 0 |
| aggressivo | 23 | 76 | 0 |
| distratto | 44 | 64 | 0 |
| ostinato | 36 | 77 | 0 |

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
| mucchio medio (valore) | 4.24 | 4.19 |
| gettoni medi sul mucchio | 4.34 | 4.79 |
| carte della parte piu' forte (media) | 8.80 | 8.85 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **139 (97%)** | **132 (98%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 3 |
| 1 | 4 | 7 |
| 2 | 16 | 20 |
| 3 | 32 | 20 |
| 4 | 21 | 15 |
| 5 | 23 | 21 |
| 6 | 46 | 49 |
