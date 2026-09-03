# I componenti di ECHOES, contati

Generato da `tools/components_survey.py` — non si scrive a mano.

Cosa c'e' nella scatola oggi, cosa si stampa, cosa l'app disegna, e
cosa manca perche' l'app dica **tutto** quello che dice il tavolo.

## 1. Quello che si stampa e si tiene in mano

| componente | pezzi diversi | copie in scatola | formato | faccia fisica | fogli A4 |
|---|---|---|---|---|---|
| Carte **Asset** (ognuna col suo Eco) | 48 | 132 | 70x120 mm | **tutte** | 33 |
| Carte **Tensione** (le Domande) | 60 | 60 | 63x88 mm | **tutte** | 7 |
| Schede **Consiglio** | 60 | 60 | 70x120 mm | **tutte** | 15 |
| Carte **Destino** | 23 | 23 | 70x120 mm | **tutte** | 6 |
| Carte **Obiettivo** (coperte) | 19 | 19 | 70x120 mm | **tutte** | 5 |
| Carte **Casata** (una per vita) | 32 | 32 | 70x120 mm | **nessuna** | 8 |
| Tessere **Regione** | 10 | 10 | 80x80 mm | **nessuna** | 2 |

**76 fogli A4 di carte e tessere**, piu' quattro fogli-fustella (i segni
delle Regioni, i segni delle case, i segni del mondo, la traccia dei valori).

## 2. I segnalini che si posano

Non hanno una carta: sono quadratini di cartone da 15 mm, e sono la
meta' del gioco che si tocca. **Non sono i 177 segni del dizionario**:
quelli comprendono memorie, funzioni del motore, leggende e domini
stampati sulle tessere. Un segnalino si taglia solo per quello che si
**posa**: su una Regione, accanto a una casa, o sul bordo della mappa
dove sta quello che il mondo ricorda (D-351).

| fustella | tipi diversi | pezzi da tagliare |
|---|---|---|
| **Segni delle Regioni** — condizioni (2 copie), Pietre e insediamenti, Cicatrici | 33 | 50 |
| **Segni delle case** — fama, scoperte, promesse | 33 | 39 |
| **Segni del mondo** — sul bordo della mappa: fatti che il mondo ricorda | 51 | 51 |
| Presenza e controllo | 2 | 5 per casa |
| Rombi del Calore | 1 | uno per ognuno dei 6 Temi, piu' due di scorta |
| **Gettoni RIVENDICARE** — la moneta del Consiglio | 1 | 12 |

**118 tipi diversi, 152 pezzi** piu' le pedine dei seggi.

Quanti di quei tipi un tavolo vede **davvero in un anno** non lo dice
questo censimento: lo misura `cli/run_punchboard_probe.gd`, che gioca
gli anni e conta. Quel numero conta piu' del totale: nessuno impara
centodiciotto simboli, si impara quello che si vede.

## 3. Quello che non si stampa ma tiene in piedi il gioco

| | quanti | cos'e' |
|---|---|---|
| Case (Entita') | 8 | i seggi, con **32 vite** in tutto |
| Profili strategici | 8 su 8 | cosa ogni casa vuole lasciare nel mondo |
| Temi | 6 | i mazzetti che scaldano e aprono la Domanda |
| Conseguenze | 63 | cosa una proposta scrive sul mondo se passa |
| Modelli di Consiglio | 12 | domande, proposte e clausole d'autore |
| Regole dei segni | 59 | cosa un segno fa da solo |
| Azioni | 7 | i verbi del turno |
| Chronicle | 1 | gli anni giocabili |

## 4. L'arte

| | |
|---|---|
| soggetti da illustrare (`art_prompt_key`) | **161** |
| gia' disegnati | **11** |
| ancora segnaposto | **150** |

I prompt pronti da mandare a chi disegna stanno in
[BRIEF_ARTE.md](BRIEF_ARTE.md), generati dagli stessi dati.

## 5. Cosa manca perche' l'app dica **tutto** quello che dice il tavolo

Quattro cose diverse, in ordine di quanto pesano.

### a. Le facce: quante si leggono, e come sono fatte

Fino alla 0.1.329 questa voce diceva **«84 facce mancanti»**, e non era
vero: contava i blocchi `physical` **scritti a mano** e chiamava
«mancante» tutto il resto. Ma una faccia si stampa lo stesso, e in tre
mazzi su sei **si ricava dai dati** ([D-344](DECISIONS.md#d-344)) — non
per pigrizia, ma perche' una faccia generata non puo' dire una cosa
mentre il motore ne fa un'altra. Scriverle a mano toglierebbe quella
garanzia, che e' la stessa che [D-362](DECISIONS.md#d-362) ha appena
dovuto rimettere a mano su 48 Risonanze.

Il conto delle facce viene da [SCHELETRO_CARTE.md](SCHELETRO_CARTE.md),
che le legge dalle facce vere; la colonna «d'autore» da questi dati.

| componente | facce stampate | di cui col testo d'autore | com'e' fatta |
|---|---|---|---|
| Carte Asset | **48** | 48 su 48 | d'autore, piu' le righe ricavate |
| Carte Tensione (le Domande) | **60** | 60 su 60 | d'autore |
| Schede Consiglio | **60** | — | ricavata dalla Tensione |
| Carte Destino | **23** | 23 su 23 | d'autore |
| Carte Obiettivo | **19** | — | ricavata dai dati (D-445) |
| Echi (stampati sulla carta Asset) | **48** | — | ricavata dai dati (D-344) |
| Carte Casata | **32** | — | ricavata dai dati |
| Tessere Regione | **10** | — | ricavata dai dati |

**Nessun pezzo esce senza faccia**, e da [D-365](DECISIONS.md#d-365) la
tessera dice anche **dove si costruisce**: 10 tessere su 10 dichiarano i
loro spazi-Pietra, **21 in tutto**, e il bioma decide che cosa ci sta —
6 Pietre che una casa alza, 4 che sono la terra stessa. I 25 segni con
posto `TILE_SLOT` hanno finalmente il cartone che li ospita.

### b. L'arte

**150 soggetti su 161 sono ancora segnaposto.** E' il pezzo piu' grosso
in quantita' e il piu' facile da parallelizzare: i prompt sono gia'
scritti e la scatola si stampa e si gioca anche cosi'.

**E la catena e' aperta, provata da un capo all'altro** (D-375): un file
posato in `godot/art/<chiave con le barre>.png` entra da solo nel
censimento, nell'app **e nel foglio di stampa**, che lo incorpora nel
riquadro al posto del segnaposto. Non c'e' niente da sbloccare prima di
cominciare, e le illustrazioni si possono consegnare **una alla volta**.

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

