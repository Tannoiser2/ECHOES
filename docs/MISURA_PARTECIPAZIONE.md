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
| Consigli | 164 | 163 |
| prese di posizione dei non proponenti | 492 | 489 |
| — SUPPORT | 239 (49%) | 203 (42%) |
| — OPPOSE | 253 (51%) | 286 (58%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 156 (95%) | 160 (98%) |
| carte impegnate dal proponente, per Consiglio | 1.96 | 2.10 |
| carte impegnate dagli altri tre, per Consiglio | 5.37 | 5.29 |
| non proponenti che impegnano almeno una carta | 478 (97%) | 472 (97%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.76 | 1.42 |
| **Consigli con opposizione nel margine** | **156 (95%)** | **160 (98%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 64 | 54 |
| DECISIVE_SUCCESS | 57 | 45 |
| FAILURE | 8 | 23 |
| SUCCESS | 25 | 25 |
| SUCCESS_WITH_COST | 10 | 16 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 31 | 30 | 0 |
| Re Aldric | uniforme | 21 | 36 | 0 |
| Kessa dei Fuochi | misto | 47 | 47 | 0 |
| Kessa dei Fuochi | uniforme | 31 | 52 | 0 |
| Le Città Libere | misto | 24 | 28 | 0 |
| Le Città Libere | uniforme | 20 | 33 | 0 |
| Lyra | misto | 29 | 29 | 0 |
| Lyra | uniforme | 23 | 34 | 0 |
| Popolo Nahr | misto | 31 | 38 | 0 |
| Popolo Nahr | uniforme | 32 | 41 | 0 |
| Maestra Ilve | misto | 31 | 23 | 0 |
| Maestra Ilve | uniforme | 26 | 31 | 0 |
| Vaerax | misto | 25 | 26 | 0 |
| Vaerax | uniforme | 23 | 34 | 0 |
| Priore Anselmo | misto | 21 | 32 | 0 |
| Priore Anselmo | uniforme | 27 | 25 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 124 | 0 | 0 |
| aggressivo | 32 | 88 | 0 |
| distratto | 36 | 91 | 0 |
| ostinato | 47 | 74 | 0 |

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
| mucchio medio (valore) | 4.88 | 5.02 |
| gettoni medi sul mucchio | 6.04 | 6.16 |
| carte della parte piu' forte (media) | 12.06 | 11.72 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **164 (100%)** | **163 (100%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 1 | 4 | 6 |
| 2 | 15 | 7 |
| 3 | 17 | 17 |
| 4 | 18 | 17 |
| 5 | 16 | 16 |
| 6 | 94 | 100 |
