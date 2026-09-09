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
| Consigli | 173 | 169 |
| prese di posizione dei non proponenti | 519 | 507 |
| — SUPPORT | 263 (51%) | 200 (39%) |
| — OPPOSE | 256 (49%) | 307 (61%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 153 (88%) | 165 (98%) |
| carte impegnate dal proponente, per Consiglio | 1.46 | 1.50 |
| carte impegnate dagli altri tre, per Consiglio | 3.94 | 4.09 |
| non proponenti che impegnano almeno una carta | 411 (79%) | 410 (81%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 2.31 | 0.49 |
| **Consigli con opposizione nel margine** | **153 (88%)** | **165 (98%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 54 | 73 |
| DECISIVE_SUCCESS | 54 | 40 |
| FAILURE | 21 | 15 |
| SUCCESS | 39 | 29 |
| SUCCESS_WITH_COST | 5 | 12 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 36 | 30 | 0 |
| Re Aldric | uniforme | 21 | 44 | 0 |
| Kessa dei Fuochi | misto | 47 | 36 | 0 |
| Kessa dei Fuochi | uniforme | 39 | 45 | 0 |
| Le Città Libere | misto | 25 | 25 | 0 |
| Le Città Libere | uniforme | 16 | 31 | 0 |
| Lyra | misto | 36 | 32 | 0 |
| Lyra | uniforme | 25 | 39 | 0 |
| Popolo Nahr | misto | 35 | 45 | 0 |
| Popolo Nahr | uniforme | 28 | 46 | 0 |
| Maestra Ilve | misto | 28 | 28 | 0 |
| Maestra Ilve | uniforme | 24 | 33 | 0 |
| Vaerax | misto | 28 | 28 | 0 |
| Vaerax | uniforme | 24 | 35 | 0 |
| Priore Anselmo | misto | 28 | 32 | 0 |
| Priore Anselmo | uniforme | 23 | 34 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 124 | 0 | 0 |
| aggressivo | 42 | 92 | 0 |
| distratto | 45 | 83 | 0 |
| ostinato | 52 | 81 | 0 |

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
| mucchio medio (valore) | 5.12 | 5.06 |
| gettoni medi sul mucchio | 6.69 | 6.76 |
| carte della parte piu' forte (media) | 9.42 | 9.63 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **161 (93%)** | **163 (96%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 0 | 2 |
| 1 | 1 | 3 |
| 2 | 12 | 9 |
| 3 | 15 | 9 |
| 4 | 18 | 24 |
| 5 | 19 | 21 |
| 6 | 108 | 101 |
