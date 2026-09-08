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
| Consigli | 149 | 140 |
| prese di posizione dei non proponenti | 447 | 420 |
| — SUPPORT | 224 (50%) | 170 (40%) |
| — OPPOSE | 223 (50%) | 250 (60%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 140 (94%) | 138 (99%) |
| carte impegnate dal proponente, per Consiglio | 1.20 | 1.52 |
| carte impegnate dagli altri tre, per Consiglio | 3.32 | 3.36 |
| non proponenti che impegnano almeno una carta | 319 (71%) | 313 (75%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.64 | 1.12 |
| **Consigli con opposizione nel margine** | **140 (94%)** | **138 (99%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 52 | 48 |
| DECISIVE_SUCCESS | 42 | 35 |
| FAILURE | 18 | 22 |
| SUCCESS | 29 | 28 |
| SUCCESS_WITH_COST | 8 | 7 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 28 | 25 | 0 |
| Re Aldric | uniforme | 26 | 26 | 0 |
| Kessa dei Fuochi | misto | 35 | 36 | 0 |
| Kessa dei Fuochi | uniforme | 24 | 49 | 0 |
| Le Città Libere | misto | 30 | 18 | 0 |
| Le Città Libere | uniforme | 14 | 30 | 0 |
| Lyra | misto | 28 | 28 | 0 |
| Lyra | uniforme | 22 | 33 | 0 |
| Popolo Nahr | misto | 29 | 32 | 0 |
| Popolo Nahr | uniforme | 30 | 31 | 0 |
| Maestra Ilve | misto | 28 | 28 | 0 |
| Maestra Ilve | uniforme | 21 | 23 | 0 |
| Vaerax | misto | 27 | 27 | 0 |
| Vaerax | uniforme | 16 | 32 | 0 |
| Priore Anselmo | misto | 19 | 29 | 0 |
| Priore Anselmo | uniforme | 17 | 26 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 108 | 0 | 0 |
| aggressivo | 35 | 71 | 0 |
| distratto | 40 | 74 | 0 |
| ostinato | 41 | 78 | 0 |

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
| mucchio medio (valore) | 4.48 | 4.37 |
| gettoni medi sul mucchio | 4.86 | 4.90 |
| carte della parte piu' forte (media) | 8.57 | 8.99 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **142 (95%)** | **134 (96%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 4 |
| 1 | 6 | 3 |
| 2 | 13 | 18 |
| 3 | 22 | 20 |
| 4 | 21 | 17 |
| 5 | 30 | 23 |
| 6 | 56 | 55 |
