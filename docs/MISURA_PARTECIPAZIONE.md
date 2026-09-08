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
| Consigli | 149 | 141 |
| prese di posizione dei non proponenti | 447 | 423 |
| — SUPPORT | 224 (50%) | 169 (40%) |
| — OPPOSE | 223 (50%) | 254 (60%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 142 (95%) | 140 (99%) |
| carte impegnate dal proponente, per Consiglio | 1.19 | 1.43 |
| carte impegnate dagli altri tre, per Consiglio | 3.29 | 3.43 |
| non proponenti che impegnano almeno una carta | 322 (72%) | 316 (75%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.73 | 0.99 |
| **Consigli con opposizione nel margine** | **142 (95%)** | **140 (99%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 46 | 52 |
| DECISIVE_SUCCESS | 43 | 40 |
| FAILURE | 20 | 17 |
| SUCCESS | 29 | 24 |
| SUCCESS_WITH_COST | 11 | 8 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 25 | 24 | 0 |
| Re Aldric | uniforme | 23 | 30 | 0 |
| Kessa dei Fuochi | misto | 35 | 35 | 0 |
| Kessa dei Fuochi | uniforme | 26 | 47 | 0 |
| Le Città Libere | misto | 29 | 21 | 0 |
| Le Città Libere | uniforme | 17 | 26 | 0 |
| Lyra | misto | 32 | 26 | 0 |
| Lyra | uniforme | 19 | 34 | 0 |
| Popolo Nahr | misto | 26 | 35 | 0 |
| Popolo Nahr | uniforme | 31 | 31 | 0 |
| Maestra Ilve | misto | 30 | 26 | 0 |
| Maestra Ilve | uniforme | 21 | 29 | 0 |
| Vaerax | misto | 29 | 25 | 0 |
| Vaerax | uniforme | 16 | 31 | 0 |
| Priore Anselmo | misto | 18 | 31 | 0 |
| Priore Anselmo | uniforme | 16 | 26 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 110 | 0 | 0 |
| aggressivo | 36 | 71 | 0 |
| distratto | 39 | 75 | 0 |
| ostinato | 39 | 77 | 0 |

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
| mucchio medio (valore) | 4.41 | 4.58 |
| gettoni medi sul mucchio | 4.68 | 5.19 |
| carte della parte piu' forte (media) | 8.52 | 8.91 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **139 (93%)** | **136 (96%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 4 |
| 1 | 6 | 4 |
| 2 | 13 | 12 |
| 3 | 28 | 21 |
| 4 | 20 | 13 |
| 5 | 25 | 19 |
| 6 | 56 | 68 |
