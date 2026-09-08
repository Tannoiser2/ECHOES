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
| Consigli | 138 | 138 |
| prese di posizione dei non proponenti | 414 | 414 |
| — SUPPORT | 208 (50%) | 159 (38%) |
| — OPPOSE | 206 (50%) | 255 (62%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 131 (95%) | 132 (96%) |
| carte impegnate dal proponente, per Consiglio | 1.31 | 1.40 |
| carte impegnate dagli altri tre, per Consiglio | 3.46 | 3.42 |
| non proponenti che impegnano almeno una carta | 321 (78%) | 330 (80%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 2.46 | 0.65 |
| **Consigli con opposizione nel margine** | **131 (95%)** | **132 (96%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 40 | 60 |
| DECISIVE_SUCCESS | 51 | 31 |
| FAILURE | 10 | 4 |
| SUCCESS | 29 | 26 |
| SUCCESS_WITH_COST | 8 | 17 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 27 | 25 | 0 |
| Re Aldric | uniforme | 18 | 31 | 0 |
| Kessa dei Fuochi | misto | 36 | 34 | 0 |
| Kessa dei Fuochi | uniforme | 24 | 44 | 0 |
| Le Città Libere | misto | 28 | 13 | 0 |
| Le Città Libere | uniforme | 18 | 29 | 0 |
| Lyra | misto | 26 | 28 | 0 |
| Lyra | uniforme | 19 | 36 | 0 |
| Popolo Nahr | misto | 20 | 39 | 0 |
| Popolo Nahr | uniforme | 25 | 36 | 0 |
| Maestra Ilve | misto | 28 | 22 | 0 |
| Maestra Ilve | uniforme | 18 | 27 | 0 |
| Vaerax | misto | 22 | 21 | 0 |
| Vaerax | uniforme | 16 | 31 | 0 |
| Priore Anselmo | misto | 21 | 24 | 0 |
| Priore Anselmo | uniforme | 21 | 21 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 110 | 0 | 0 |
| aggressivo | 23 | 72 | 0 |
| distratto | 36 | 65 | 0 |
| ostinato | 39 | 69 | 0 |

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
| mucchio medio (valore) | 4.15 | 4.10 |
| gettoni medi sul mucchio | 3.94 | 3.85 |
| carte della parte piu' forte (media) | 9.51 | 9.72 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **135 (98%)** | **138 (100%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 1 |
| 1 | 5 | 7 |
| 2 | 20 | 15 |
| 3 | 26 | 27 |
| 4 | 19 | 31 |
| 5 | 28 | 18 |
| 6 | 39 | 39 |
