# ECHOES — cosa la pagina dice, e con quale dito

<!-- GENERATO da `tools/run_page_survey.sh` — non si corregge qui. -->

La voce [65](ISSUES.md#65) dice *«tutta la pagina dell'app va rivista»*, e
accanto porta la ragione per cui e' rimasta ferma: **nessuna sonda tocca
questa pagina**, quindi ogni giro costa il pomeriggio di una persona con
l'app in mano. Questa e' quella sonda.

Misura le quattro cose che i sei difetti trovati su un tablet avevano in
comune, cosi' ogni passata si giudica coi numeri. La rivista l'ha scelta il
committente — [D-427](DECISIONS.md#d-427), la terza: *l'app mostra il
tavolo, non lo stato* — ed e' fatta in [D-444](DECISIONS.md#d-444): da li'
questa pagina dice **se la pagina la segue**.

**Si misura quello che la pagina chiede, non quello che ottiene**: senza
una finestra vera non c'e' un passaggio di disposizione. Un bersaglio che
non dichiara una misura non e' per questo grande — e' *non dichiarato*, e
sta in una colonna sua.

| | |
|---|---|
| pannelli guardati | 8 |
| nodi in tutto | 257 |
| testi sotto gli occhi | 146 |
| *piu' 1 blocchi di testo ricco che questa sonda non sa leggere* | |
| **testi che vivono solo nel suggerimento del mouse** | **2** |
| bersagli che si toccano | 25 |
| **piu' stretti di un dito (44 px)** | **0** |
| di cui non dichiarano nessuna misura | 0 |
| **parole tecniche sotto gli occhi** | **0** |

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

## 4. Quanto la pagina chiede

Da [D-444](DECISIONS.md#d-444) la pagina e' **il tavolo, e una cosa alla
volta**: a sinistra il tavolo — i mazzetti, la mappa, chi siede, il
racconto — e accanto una colonna di **240 px** con quello che serve per
decidere adesso. La colonna di stato, il Consiglio e l'aiuto non stanno
piu' intorno al tavolo: si aprono **al suo posto**, uno alla volta. La
mano sta sotto, per tutta la larghezza. Il tablet e' largo **768 px**.

Una colonna fatta per scorrere chiede **tutta la sua lunghezza**: la
colonna d'altezza si legge cosi', non come «quanto e' alto lo schermo».
Un pannello che *si adatta* non dichiara niente perche' prende lo spazio
che resta: e' la mappa, ed e' giusto che sia lei.

| pannello | dove sta | nodi | larghezza chiesta | altezza chiesta |
|---|---|---|---|---|
| colonna di stato | al centro, uno alla volta | 95 | 234 | 1726 |
| mappa | sul tavolo | 21 | *si adatta* | |
| il Consiglio | al centro, uno alla volta | 45 | 226 | 40 |
| il tavolo | nella stanza, prima di sedersi | 43 | *si adatta* | |
| i mazzi dei Temi | sul tavolo | 13 | *si adatta* | |
| chi siede | sul tavolo | 25 | 402 | 44 |
| la pagina d'aiuto | al centro, uno alla volta | 2 | 37 | 28 |
| la mano | sotto, tutta la larghezza | 13 | 342 | 246 |

Tre misure, una per posto:

| | chiede | ha | |
|---|---|---|---|
| **il tavolo con la colonna accanto** — il piu' largo dei suoi pannelli (402), la colonna (240), i margini (36) | **678** | 768 | ✓ ne avanzano 90 |
| **al centro, uno alla volta** — il piu' largo e' «colonna di stato» | **234** | 492 | ✓ ne avanzano 258 |
| **sotto, la mano** | **342** | 744 | ✓ ne avanzano 402 |

**La pagina sta dentro il tablet**, in tutti e tre i posti. Fino a D-444
chiedeva 788 px in fila senza contare la mappa: non e' che i pannelli si
sono stretti, e' che non stanno piu' in fila.
