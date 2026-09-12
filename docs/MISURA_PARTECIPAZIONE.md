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
| Consigli | 163 | 160 |
| prese di posizione dei non proponenti | 489 | 480 |
| — SUPPORT | 248 (51%) | 206 (43%) |
| — OPPOSE | 241 (49%) | 274 (57%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 145 (89%) | 151 (94%) |
| carte impegnate dal proponente, per Consiglio | 2.02 | 1.96 |
| carte impegnate dagli altri tre, per Consiglio | 5.53 | 5.13 |
| non proponenti che impegnano almeno una carta | 454 (93%) | 450 (94%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 2.64 | 1.76 |
| **Consigli con opposizione nel margine** | **145 (89%)** | **151 (94%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 64 | 60 |
| DECISIVE_SUCCESS | 65 | 49 |
| FAILURE | 7 | 4 |
| SUCCESS | 17 | 31 |
| SUCCESS_WITH_COST | 10 | 16 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 36 | 25 | 0 |
| Re Aldric | uniforme | 24 | 31 | 0 |
| Kessa dei Fuochi | misto | 46 | 39 | 0 |
| Kessa dei Fuochi | uniforme | 34 | 59 | 0 |
| Le Città Libere | misto | 23 | 24 | 0 |
| Le Città Libere | uniforme | 19 | 27 | 0 |
| Lyra | misto | 29 | 28 | 0 |
| Lyra | uniforme | 29 | 32 | 0 |
| Popolo Nahr | misto | 29 | 45 | 0 |
| Popolo Nahr | uniforme | 36 | 35 | 0 |
| Maestra Ilve | misto | 34 | 23 | 0 |
| Maestra Ilve | uniforme | 23 | 27 | 0 |
| Vaerax | misto | 28 | 28 | 0 |
| Vaerax | uniforme | 21 | 34 | 0 |
| Priore Anselmo | misto | 23 | 29 | 0 |
| Priore Anselmo | uniforme | 20 | 29 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 115 | 1 | 0 |
| aggressivo | 37 | 95 | 0 |
| distratto | 41 | 72 | 0 |
| ostinato | 55 | 73 | 0 |

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
| mucchio medio (valore) | 5.20 | 5.11 |
| gettoni medi sul mucchio | 6.26 | 6.41 |
| carte della parte piu' forte (media) | 13.18 | 11.91 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **163 (100%)** | **160 (100%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 0 | 2 |
| 1 | 2 | 3 |
| 2 | 11 | 7 |
| 3 | 8 | 13 |
| 4 | 16 | 15 |
| 5 | 21 | 18 |
| 6 | 105 | 102 |
