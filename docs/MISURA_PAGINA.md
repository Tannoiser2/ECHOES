# ECHOES — cosa la pagina dice, e con quale dito

<!-- GENERATO da `tools/run_page_survey.sh` — non si corregge qui. -->

La voce [65](ISSUES.md#65) dice *«tutta la pagina dell'app va rivista»*, e
accanto porta la ragione per cui e' rimasta ferma: **nessuna sonda tocca
questa pagina**, quindi ogni giro costa il pomeriggio di una persona con
l'app in mano. Questa e' quella sonda.

Non dice **quale** delle tre riviste fare — quella e' una scelta d'autore e
resta nella 65. Misura le quattro cose che i sei difetti trovati su un
tablet avevano in comune, cosi' la prossima passata si giudica coi numeri.

**Si misura quello che la pagina chiede, non quello che ottiene**: senza
una finestra vera non c'e' un passaggio di disposizione. Un bersaglio che
non dichiara una misura non e' per questo grande — e' *non dichiarato*, e
sta in una colonna sua.

| | |
|---|---|
| pannelli guardati | 7 |
| nodi in tutto | 188 |
| testi sotto gli occhi | 114 |
| *piu' 1 blocchi di testo ricco che questa sonda non sa leggere* | |
| **testi che vivono solo nel suggerimento del mouse** | **2** |
| bersagli che si toccano | 7 |
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

La 65 dice che quattro cose *«si contendono un tablet in verticale»*.
Ecco quanto ognuna chiede, e quanto e' largo il tablet: **768 px**.

Una colonna fatta per scorrere chiede **tutta la sua lunghezza**: la
colonna d'altezza si legge cosi', non come «quanto e' alto lo schermo».

| pannello | nodi | larghezza chiesta | altezza chiesta |
|---|---|---|---|
| colonna di stato | 93 | 191 | 1791 |
| mappa | 1 | *disegna: non lo dichiara* | |
| il Consiglio | 55 | 218 | 1670 |
| il tavolo | 23 | 0 | 0 |
| i mazzi dei Temi | 1 | *disegna: non lo dichiara* | |
| la pagina d'aiuto | 2 | 37 | 28 |
| la mano | 13 | 342 | 246 |
| **in fila, quelli che lo dichiarano** | | **788** | |

**2 pannelli non compaiono in quel conto**, ed e' il primo
risultato di questa misura: mappa, i mazzi dei Temi **non costruiscono nodi, dipingono**.
Una scritta dipinta non ha una misura minima, non ha un suggerimento e
non e' un bersaglio: questa sonda non la vede, e nemmeno un lettore di
schermo. E' un fatto da tenere presente prima di scegliere quale delle
tre riviste fare — non un difetto da riparare qui.

Quelli che una misura la dichiarano chiedono **788 px** in fila: 20
piu' del tablet, e la mappa non e' nemmeno nel conto. Non e' un difetto
da riparare riga per riga — e' la seconda delle tre riviste della 65,
*«forse su un tablet la pagina e' una alla volta»*, e sta al committente.
