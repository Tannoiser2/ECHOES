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
| Consigli | 169 | 166 |
| prese di posizione dei non proponenti | 507 | 498 |
| — SUPPORT | 243 (48%) | 210 (42%) |
| — OPPOSE | 264 (52%) | 288 (58%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 164 (97%) | 163 (98%) |
| carte impegnate dal proponente, per Consiglio | 1.54 | 1.66 |
| carte impegnate dagli altri tre, per Consiglio | 4.31 | 4.43 |
| non proponenti che impegnano almeno una carta | 410 (81%) | 402 (81%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.56 | 1.16 |
| **Consigli con opposizione nel margine** | **164 (97%)** | **163 (98%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 50 | 58 |
| DECISIVE_SUCCESS | 47 | 43 |
| FAILURE | 17 | 24 |
| SUCCESS | 41 | 30 |
| SUCCESS_WITH_COST | 14 | 11 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 32 | 27 | 0 |
| Re Aldric | uniforme | 22 | 38 | 0 |
| Kessa dei Fuochi | misto | 48 | 45 | 0 |
| Kessa dei Fuochi | uniforme | 47 | 40 | 0 |
| Le Città Libere | misto | 28 | 20 | 0 |
| Le Città Libere | uniforme | 18 | 29 | 0 |
| Lyra | misto | 29 | 34 | 0 |
| Lyra | uniforme | 18 | 44 | 0 |
| Popolo Nahr | misto | 26 | 45 | 0 |
| Popolo Nahr | uniforme | 28 | 44 | 0 |
| Maestra Ilve | misto | 29 | 28 | 0 |
| Maestra Ilve | uniforme | 22 | 35 | 0 |
| Vaerax | misto | 28 | 32 | 0 |
| Vaerax | uniforme | 28 | 29 | 0 |
| Priore Anselmo | misto | 23 | 33 | 0 |
| Priore Anselmo | uniforme | 27 | 29 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 113 | 0 | 0 |
| aggressivo | 39 | 90 | 0 |
| distratto | 39 | 98 | 0 |
| ostinato | 52 | 76 | 0 |

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
| mucchio medio (valore) | 5.26 | 5.19 |
| gettoni medi sul mucchio | 6.82 | 6.58 |
| carte della parte piu' forte (media) | 10.19 | 10.02 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **164 (97%)** | **155 (93%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 0 | 2 |
| 1 | 1 | 1 |
| 2 | 6 | 4 |
| 3 | 17 | 20 |
| 4 | 12 | 14 |
| 5 | 21 | 13 |
| 6 | 112 | 112 |
