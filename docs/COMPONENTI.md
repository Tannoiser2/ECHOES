# I componenti di ECHOES, contati

Generato da `tools/components_survey.py` — non si scrive a mano.

Cosa c'e' nella scatola oggi, cosa si stampa, cosa l'app disegna, e
cosa manca perche' l'app dica **tutto** quello che dice il tavolo.

## 1. Quello che si stampa e si tiene in mano

| componente | pezzi diversi | copie in scatola | formato | faccia fisica | fogli A4 |
|---|---|---|---|---|---|
| Carte **Asset** | 48 | 132 | 63x88 mm | **tutte** | 15 |
| Carte **Echo** | 39 | 39 | 63x88 mm | **nessuna** | 5 |
| Carte **Tensione** (le Domande) | 60 | 60 | 44x68 mm | **tutte** | 4 |
| Carte **Destino** | 23 | 23 | 70x120 mm | **tutte** | 6 |
| Carte **Casata** (una per vita) | 26 | 26 | 70x120 mm | **nessuna** | 7 |
| Tessere **Regione** | 10 | 10 | 80x80 mm | **nessuna** | 2 |

**39 fogli A4 di carte e tessere**, piu' tre fogli-fustella (i segni
delle Regioni, i segni delle case, la traccia dei valori).

## 2. I segnalini che si posano

Non hanno una carta: sono quadratini di cartone da 15 mm, e sono la
meta' del gioco che si tocca. **Non sono i 183 segni del dizionario**:
quelli comprendono memorie, funzioni del motore, leggende e domini
stampati sulle tessere. Un segnalino si taglia solo per quello che si
**posa** su una Regione o accanto a una casa.

| fustella | tipi diversi | pezzi da tagliare |
|---|---|---|
| **Segni delle Regioni** — condizioni (2 copie), Pietre e insediamenti, Cicatrici | 34 | 52 |
| **Segni delle case** — fama, scoperte, promesse | 33 | 39 |
| Presenza e controllo | 2 | 12 per casa |
| Rombi del Calore | 1 | uno per Tema, piu' due di scorta |

**67 tipi diversi, 91 pezzi** piu' le pedine dei seggi.

Quanti di quei tipi un tavolo vede **davvero in un anno** non lo dice
questo censimento: lo misura `cli/run_punchboard_probe.gd`, che gioca
gli anni e conta. Il numero conta piu' del totale — nessuno impara 34
simboli, si impara quello che si vede.

## 3. Quello che non si stampa ma tiene in piedi il gioco

| | quanti | cos'e' |
|---|---|---|
| Case (Entita') | 8 | i seggi, con **26 vite** in tutto |
| Profili strategici | 8 su 8 | cosa ogni casa vuole lasciare nel mondo |
| Temi | 6 | i mazzetti che scaldano e aprono la Domanda |
| Obiettivi | 17 | i tre coperti che si pescano a inizio saga |
| Conseguenze | 64 | cosa una proposta scrive sul mondo se passa |
| Modelli di Consiglio | 12 | domande, proposte e clausole d'autore |
| Regole dei segni | 52 | cosa un segno fa da solo |
| Azioni | 6 | i verbi del turno |
| Chronicle | 1 | gli anni giocabili |

## 4. L'arte

| | |
|---|---|
| soggetti da illustrare (`art_prompt_key`) | **146** |
| gia' disegnati | **11** |
| ancora segnaposto | **135** |

I prompt pronti da mandare a chi disegna stanno in
[BRIEF_ARTE.md](BRIEF_ARTE.md), generati dagli stessi dati.

## 5. Cosa manca perche' l'app dica **tutto** quello che dice il tavolo

Quattro cose diverse, in ordine di quanto pesano.

### a. Le facce fisiche che non sono scritte

Una **faccia fisica** e' il testo d'autore stampato sul cartoncino: il
bersaglio a segni, le due Azioni, la Risonanza, le liste del prezzo. Le
carte che ce l'hanno le controlla il validatore; le altre stampano un
testo che il motore **ricava** dai dati digitali, e al tavolo si legge
come una scheda tecnica, non come una carta.

| componente | faccia scritta | manca |
|---|---|---|
| Carte Asset | 48 su 48 | — |
| Carte Tensione | 60 su 60 | — |
| Carte Destino | 23 su 23 | — |
| **Carte Echo** | 0 su 39 | **39** |
| **Carte Casata** | 0 su 26 | **26** |
| **Tessere Regione** | 0 su 10 | **10** |

### b. L'arte

**135 soggetti su 146 sono ancora segnaposto.** E' il pezzo piu' grosso
in quantita' e il piu' facile da parallelizzare: i prompt sono gia'
scritti e la scatola si stampa e si gioca anche cosi'.

### c. Le regole che il tavolo esegue e lo schermo non spiega ancora

| | dove sta scritto |
|---|---|
| Il Consiglio e' **due Consigli impilati**: la frase d'autore scrive il 71% di quello che resta sul mondo, la carta il 29% | ISSUES 80, D-292 |
| Una **soglia** di trasformazione non puo' leggere una memoria, perche' una memoria non si perde | ISSUES 81, D-294 |
| Il Consiglio decide con **una moneta che i Destini non spendono** | ISSUES 76, D-287 |
| I **segni muti** — nel dizionario, scritti da qualcuno, e letti da nessuno | ISSUES 77, [la misura](MISURA_MATRICE.md) |

### d. L'app come oggetto, non come ispezione

E' la voce piu' vecchia e la piu' vera: *«l'app non e' un prototipo
giocabile, e' un'ispezione di stato con dei bottoni»* (ISSUES 63), e
*«tutta la pagina va rivista»* (ISSUES 65). Da allora la mano gioca, la
colonna si legge, il Consiglio mostra la carta girata — ma la regola
§5ter resta: **nessuna misura copre quello che una persona vede**. Il
giudizio e' del committente, su un tavolo vero.

## 6. Cosa l'app disegna gia'

| componente | dove si vede |
|---|---|
| asset | Mano (`hand_view`) + le carte in Consiglio |
| destiny | Colonna: **il tarocco e le tre righe della faccia** |
| echo | Tavolo (`echo_card_view`), a fine Atto |
| entity | Colonna: il tarocco della Casata |
| objective | Colonna: i tre coperti del seggio |
| profile | Colonna: **COSA RESTERA' DI TE** |
| region | Mappa (`map_view`): tessere, segni, pedine |
| structure | Mappa: le Pietre coi loro gradi |
| tag | Mappa e colonna, ognuno con la sua parola italiana |
| tension | Colonna (`status_panel`) e tabellone del Consiglio |
| theme | Colonna: i sei mazzetti coi gettoni coperti |

