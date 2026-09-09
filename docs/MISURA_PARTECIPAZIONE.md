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
| Consigli | 168 | 165 |
| prese di posizione dei non proponenti | 504 | 495 |
| — SUPPORT | 235 (47%) | 204 (41%) |
| — OPPOSE | 269 (53%) | 291 (59%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 160 (95%) | 158 (96%) |
| carte impegnate dal proponente, per Consiglio | 1.43 | 1.39 |
| carte impegnate dagli altri tre, per Consiglio | 3.88 | 3.99 |
| non proponenti che impegnano almeno una carta | 405 (80%) | 400 (81%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.30 | 1.30 |
| **Consigli con opposizione nel margine** | **160 (95%)** | **158 (96%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 63 | 66 |
| DECISIVE_SUCCESS | 37 | 50 |
| FAILURE | 16 | 15 |
| SUCCESS | 40 | 25 |
| SUCCESS_WITH_COST | 12 | 9 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 28 | 33 | 0 |
| Re Aldric | uniforme | 18 | 46 | 0 |
| Kessa dei Fuochi | misto | 47 | 44 | 0 |
| Kessa dei Fuochi | uniforme | 44 | 39 | 0 |
| Le Città Libere | misto | 30 | 19 | 0 |
| Le Città Libere | uniforme | 18 | 29 | 0 |
| Lyra | misto | 31 | 32 | 0 |
| Lyra | uniforme | 22 | 37 | 0 |
| Popolo Nahr | misto | 26 | 46 | 0 |
| Popolo Nahr | uniforme | 34 | 41 | 0 |
| Maestra Ilve | misto | 27 | 30 | 0 |
| Maestra Ilve | uniforme | 26 | 28 | 0 |
| Vaerax | misto | 19 | 33 | 0 |
| Vaerax | uniforme | 20 | 38 | 0 |
| Priore Anselmo | misto | 27 | 32 | 0 |
| Priore Anselmo | uniforme | 22 | 33 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 115 | 0 | 0 |
| aggressivo | 28 | 92 | 0 |
| distratto | 45 | 91 | 0 |
| ostinato | 47 | 86 | 0 |

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
| mucchio medio (valore) | 4.85 | 4.84 |
| gettoni medi sul mucchio | 5.80 | 6.05 |
| carte della parte piu' forte (media) | 8.96 | 9.69 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **155 (92%)** | **160 (97%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 2 |
| 1 | 6 | 5 |
| 2 | 9 | 14 |
| 3 | 22 | 8 |
| 4 | 16 | 29 |
| 5 | 23 | 17 |
| 6 | 91 | 90 |
