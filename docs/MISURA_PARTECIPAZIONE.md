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
| Consigli | 150 | 141 |
| prese di posizione dei non proponenti | 450 | 423 |
| — SUPPORT | 208 (46%) | 168 (40%) |
| — OPPOSE | 242 (54%) | 255 (60%) |
| — ABSTAIN | 0 (0%) | 0 (0%) |
| Consigli col tavolo in silenzio (tutti astenuti) | 0 (0%) | 0 (0%) |
| Consigli con un OPPOSE dichiarato | 144 (96%) | 138 (98%) |
| carte impegnate dal proponente, per Consiglio | 1.13 | 1.43 |
| carte impegnate dagli altri tre, per Consiglio | 3.27 | 3.38 |
| non proponenti che impegnano almeno una carta | 318 (71%) | 321 (76%) |
| gettoni di opposizione comprati (D-419) | 0 | 0 |
| punti del dibattito guadagnati · persi (D-455) | 0 · 0 | 0 · 0 |
| margine medio | 1.65 | 0.65 |
| **Consigli con opposizione nel margine** | **144 (96%)** | **138 (98%)** |

## Gli esiti

| esito | misto | uniforme |
|---|---|---|
| COUNTER | 47 | 57 |
| DECISIVE_SUCCESS | 40 | 36 |
| FAILURE | 26 | 16 |
| SUCCESS | 29 | 21 |
| SUCCESS_WITH_COST | 8 | 11 |

## Chi si astiene, seggio per seggio

Le posizioni di ogni casa quando non propone, sui due tavoli.

| casa | tavolo | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|---|
| Re Aldric | misto | 27 | 26 | 0 |
| Re Aldric | uniforme | 25 | 23 | 0 |
| Kessa dei Fuochi | misto | 36 | 42 | 0 |
| Kessa dei Fuochi | uniforme | 24 | 45 | 0 |
| Le Città Libere | misto | 26 | 21 | 0 |
| Le Città Libere | uniforme | 15 | 29 | 0 |
| Lyra | misto | 25 | 27 | 0 |
| Lyra | uniforme | 18 | 36 | 0 |
| Popolo Nahr | misto | 22 | 40 | 0 |
| Popolo Nahr | uniforme | 27 | 37 | 0 |
| Maestra Ilve | misto | 29 | 22 | 0 |
| Maestra Ilve | uniforme | 24 | 26 | 0 |
| Vaerax | misto | 24 | 35 | 0 |
| Vaerax | uniforme | 16 | 35 | 0 |
| Priore Anselmo | misto | 19 | 29 | 0 |
| Priore Anselmo | uniforme | 19 | 24 | 0 |

## E carattere per carattere, sul tavolo misto

| carattere | SUPPORT | OPPOSE | ABSTAIN |
|---|---|---|---|
| prudente | 107 | 0 | 0 |
| aggressivo | 26 | 82 | 0 |
| distratto | 37 | 82 | 0 |
| ostinato | 38 | 78 | 0 |

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
| mucchio medio (valore) | 4.47 | 4.30 |
| gettoni medi sul mucchio | 4.77 | 4.82 |
| carte della parte piu' forte (media) | 8.41 | 9.06 |
| **Consigli in cui la parte piu' forte arriva al mucchio** | **138 (92%)** | **136 (96%)** |

Quanti Consigli a ogni valore del mucchio:

| mucchio | misto | uniforme |
|---|---|---|
| 0 | 0 | 4 |
| 1 | 8 | 10 |
| 2 | 14 | 14 |
| 3 | 20 | 16 |
| 4 | 21 | 18 |
| 5 | 31 | 26 |
| 6 | 56 | 53 |
