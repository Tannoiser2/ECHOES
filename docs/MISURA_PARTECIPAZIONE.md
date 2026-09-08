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
| Consigli | 137 | 139 |
| prese di posizione dei non proponenti | 411 | 417 |
| — SUPPORT | 197 (48%) | 161 (39%) |
| — OPPOSE | 212 (52%) | 253 (61%) |
| — ABSTAIN | 2 (0%) | 3 (1%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 132 (96%) | 135 (97%) |
| carte impegnate dal proponente, per Consiglio | 1.33 | 1.40 |
| carte impegnate dagli altri tre, per Consiglio | 3.50 | 3.43 |
| non proponenti che impegnano almeno una carta | 315 (77%) | 325 (78%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.89 | 0.84 |
| **Consigli con opposizione nel margine** | **132 (96%)** | **135 (97%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 40 | 53 |
| DECISIVE_SUCCESS | 41 | 28 |
| FAILURE | 16 | 9 |
| SUCCESS | 31 | 35 |
| SUCCESS_WITH_COST | 9 | 14 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 27 | 29 | 0 |
| Re Aldric | uniforme | 19 | 33 | 0 |
| Kessa dei Fuochi | misto | 33 | 34 | 0 |
| Kessa dei Fuochi | uniforme | 26 | 43 | 0 |
| Le Città Libere | misto | 28 | 16 | 0 |
| Le Città Libere | uniforme | 19 | 25 | 0 |
| Lyra | misto | 23 | 24 | 0 |
| Lyra | uniforme | 16 | 37 | 0 |
| Popolo Nahr | misto | 24 | 36 | 0 |
| Popolo Nahr | uniforme | 21 | 42 | 0 |
| Maestra Ilve | misto | 25 | 23 | 0 |
| Maestra Ilve | uniforme | 22 | 24 | 0 |
| Vaerax | misto | 22 | 22 | 2 |
| Vaerax | uniforme | 16 | 27 | 3 |
| Priore Anselmo | misto | 15 | 28 | 0 |
| Priore Anselmo | uniforme | 22 | 22 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 104 | 0 | 0 |
| aggressivo | 18 | 78 | 0 |
| distratto | 40 | 66 | 0 |
| ostinato | 35 | 68 | 2 |

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
| mucchio medio (valore) | 4.13 | 4.02 |
| gettoni medi sul mucchio | 3.88 | 3.76 |
| carte della parte piu' forte (media) | 9.18 | 9.14 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **132 (96%)** | **138 (99%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 1 | 1 |
| 1 | 4 | 9 |
| 2 | 23 | 19 |
| 3 | 22 | 20 |
| 4 | 23 | 33 |
| 5 | 26 | 22 |
| 6 | 38 | 35 |
