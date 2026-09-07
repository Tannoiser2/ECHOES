# ECHOES — cosa la pagina dice, e con quale dito

<!-- GENERATO da `tools/run_page_survey.sh` — non si corregge qui. -->

La voce [65](ISSUES.md#65) dice *«tutta la pagina dell'app va rivista»*, e
accanto porta la ragione per cui e' rimasta ferma: **nessuna sonda tocca
questa pagina**, quindi ogni giro costa il pomeriggio di una persona con
l'app in mano. Questa e' quella sonda.

Misura le quattro cose che i sei difetti trovati su un tablet avevano in
comune — e da [D-465](DECISIONS.md#d-465) la quinta, la taglia dei
caratteri sul tablet — cosi' ogni passata si giudica coi numeri. La rivista l'ha scelta il
committente — [D-427](DECISIONS.md#d-427), la terza: *l'app mostra il
tavolo, non lo stato* — ed e' fatta in [D-444](DECISIONS.md#d-444): da li'
questa pagina dice **se la pagina la segue**.

**Si misura quello che la pagina chiede, non quello che ottiene**: senza
una finestra vera non c'e' un passaggio di disposizione. Un bersaglio che
non dichiara una misura non e' per questo grande — e' *non dichiarato*, e
sta in una colonna sua.

| | |
|---|---|
| pannelli guardati | 10 |
| nodi in tutto | 356 |
| testi sotto gli occhi | 188 |
| *piu' 1 blocchi di testo ricco che questa sonda non sa leggere* | |
| **testi che vivono solo nel suggerimento del mouse** | **2** |
| bersagli che si toccano | 31 |
| **piu' stretti di un dito (44 px)** | **0** |
| di cui non dichiarano nessuna misura | 0 |
| **parole tecniche sotto gli occhi** | **0** |
| testi con una taglia | 199 |
| **piu' piccoli di 11 punti sul tablet** | **0** |
| sotto i 17 punti, che la guida chiama «corpo» | 197 |
| il piu' piccolo, sul tablet | 11.0 punti |

**Il testo ricco resta fuori, e va detto.** Un `RichTextLabel`
riempito con `append_text` tiene le parole in un albero che, senza un vero
server di caratteri, headless resta vuoto: provato, `text` e
`get_parsed_text()` tornano tutti e due lunghezza zero. Sono la pagina
d'aiuto e parte del tabellone del Consiglio. Contarli come «nessuna
parola» sarebbe la bugia peggiore: una sonda cieca che sembra pulita.

**I bersagli sono un pavimento, non un totale.** La cornice —
`ui/game_screen.gd (dipende da un autoload)` — non si guarda da qui: nomina un
autoload, e una sonda lanciata con `--script` non ne ha, quindi il file
non compila. I bottoni degli strumenti e il menu restano fuori dal conto,
e chiuderli e' il primo pezzo di lavoro che questa misura si porta dietro.

## 1. I testi che vivono nel suggerimento del mouse

Il difetto che [D-242](DECISIONS.md#d-242) ha trovato su un tablet: col
dito non c'e' nessun «sopra» da cui far uscire un suggerimento, quindi
quel testo per meta' dei giocatori **non esiste**. Qui ci sono quelli che
nessuna scritta accanto ripete.

| pannello | dove | cosa direbbe |
|---|---|---|
| la mano | PanelContainer | L'ECO - La Parola Data La cosa che era stata proibita viene fatta, e viene fatta da chi l' |
| la mano | PanelContainer | L'ECO - Presagio Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare |

## 2. I bersagli che un dito non prende

Sotto i 44 px un dito comincia a sbagliare, ed e' la stessa misura che
[D-243](DECISIONS.md#d-243) ha gia' usato per le carte in mano.

Nessuno fra quelli che dichiarano una misura.

**E 0 bersagli non dichiarano niente.** Non vuol dire che siano
piccoli: vuol dire che la loro misura la decide la disposizione, e
nessuno l'ha scritta. Su una finestra stretta e' li' che si stringono.

## 3. Le parole tecniche sotto gli occhi

Un id, uno slot o un segno crudo arrivato fino allo schermo: `$rival`,
`REG_VALLE_VERDE`, `condition:unrest`. Il committente lo dice dalla 63 —
*«carte che spiegano esattamente cosa fanno e non tag o testi tecnici»*.

Nessuna: tutto quello che si legge e' in italiano da giocatore.

## 4. Quanto la pagina chiede, posto per posto

Da [D-464](DECISIONS.md#d-464) la pagina e' **il tavolo come lo vuole il
committente**: a sinistra la colonna delle domande (**250** punti), al
centro la mappa con chi siede sotto, a destra il verbale (**300**), e sotto
le tre schede — la mano, la casa, gli obiettivi — per tutta la larghezza.
Il Consiglio prende **lo schermo intero**, meno 24 punti di margine per
lato. Il tablet e' largo **1366** punti e alto **1024** ([D-465](DECISIONS.md#d-465)).

Una colonna fatta per scorrere chiede **tutta la sua lunghezza**: la
colonna d'altezza si legge cosi', non come «quanto e' alto lo schermo».
Un pannello che *si adatta* non dichiara niente perche' prende lo spazio
che resta: e' la mappa, ed e' giusto che sia lei.

| pannello | dove sta | nodi | larghezza chiesta | altezza chiesta |
|---|---|---|---|---|
| colonna di stato | sotto, in una scheda | 107 | 246 | 1859 |
| mappa | al centro | 13 | *si adatta* | |
| il Consiglio | a schermo intero | 70 | 974 | 182 |
| il tavolo | nella stanza, prima di sedersi | 37 | *si adatta* | |
| i mazzi dei Temi | non sta sulla pagina (D-464) | 13 | *si adatta* | |
| chi siede | al centro | 25 | 402 | 44 |
| le domande | a sinistra, la colonna delle domande | 31 | 230 | 572 |
| la pagina d'aiuto | al centro | 2 | 37 | 28 |
| la mano | sotto, in una scheda | 13 | 342 | 246 |
| gli obiettivi | sotto, in una scheda | 45 | 168 | 1455 |

Un posto per riga, col piu' largo dei pannelli che ci stanno — e, dove
l'altezza e' una promessa, anche il piu' alto:

| posto | ha | il piu' largo | chiede | |
|---|---|---|---|---|
| **a sinistra, la colonna delle domande** | 250 | le domande | **230** | ✓ ne avanzano 20 |
| **al centro** | 780 | chi siede | **402** | ✓ ne avanzano 378 |
| **sotto, in una scheda** | 1350 | la mano | **342** | ✓ ne avanzano 1008 |
| **a schermo intero** | 1318 | il Consiglio | **974** | ✓ ne avanzano 344 |
| a schermo intero, in altezza | 976 | il Consiglio | **182** | ✓ ne avanzano 794 |

**La pagina sta dentro il tablet**, in tutti i suoi posti.

## 5. I caratteri, misurati sul tablet

La pagina e' disegnata a **1366x1024** e sul tablet da 1366x1024, tenuto per il
largo, un suo pixel vale **1.00 punti** ([D-465](DECISIONS.md#d-465)).
Ogni testo porta la taglia che dichiara, o quella del tema se non ne
dichiara nessuna, per quel fattore. Sotto gli **11 punti** la guida dei
sistemi a tocco dice che non si legge, e la sonda va rossa; **17** e' la
taglia che chiama «corpo», e qui si conta e basta.

Nessun testo sotto i 11 punti.

Quanti testi a ogni taglia, sul tablet:

| punti | testi |
|---|---|
| 11 | 92 |
| 12 | 62 |
| 13 | 40 |
| 14 | 1 |
| 15 | 2 |
| 18 | 1 |
| 19 | 1 |
