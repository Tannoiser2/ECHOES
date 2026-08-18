# La seduta sul tavolo grande e le console (voce 27)

Il dossier di decisione per la voce 27 — «la mappa e le indicazioni delle
carte giocate restino sul computer (o iPad), e i giocatori usino gli
smartphone come console dove avere le indicazioni segrete, le carte in
mano e tutte le informazioni di gioco». Trasporto già deciso dal
committente: **stanza locale, stessa rete**. Come per le sedute
precedenti: lo stato vero, una proposta concreta per pezzo, le domande
secche in fondo.

---

## 1. Lo stato vero (la metà difficile è già fatta)

Tutto il codice disegna *per viewer*, ed è il motivo per cui questa
feature è una ricomposizione e non una riscrittura:

- `visible_tension_value(tension_id, viewer)` (§11.1): un numero velato
  è velato *per chi guarda*, non per lo schermo.
- La mappa e il pannello prendono `render(session, viewer_id)`; il
  Destino lo vede solo chi lo giura (D-101); l'avviso «questa mossa
  spegne la tua clausola» (D-120) parla solo al suo seggio.
- Il `SeatDecider` è **uno solo** per terminale e browser (D-038), con
  l'`io` iniettato: un oggetto con `say` e `choose`. La console
  telefonica è *un terzo io*, non un terzo decider.
- Il motore è deterministico e non sa quanti schermi lo guardano; il
  salvataggio a ogni soglia c'è già (D-052) e la ripresa a metà atto è
  provata dai test.
- La sonda della visibilità (D-121) sa già misurare «chi vede cosa» in
  headless: è lo stampo per la disciplina dei segreti sul filo.

Quello che non esiste: il trasporto, l'accoppiamento seggio–telefono, le
due viste ricomposte, il rientro.

## 2. L'architettura proposta

```
   computer/iPad (HOST)                     telefoni (CONSOLE)
  ┌──────────────────────┐    stessa rete  ┌─────────────────┐
  │ motore + salvataggi  │◄──WebSocket────►│ pagina web       │
  │ vista TAVOLO         │                 │ (nessuna app,    │
  │ (mappa, carte calate,│    HTTP: l'host │  nessun negozio) │
  │  Consigli, verbale)  │    serve la     │ vista CONSOLE    │
  │ + mini server HTTP   │    pagina       │ (mano, Destino,  │
  └──────────────────────┘                 │  choose, segreti)│
                                           └─────────────────┘
```

- **L'host è la partita.** Il motore gira solo sul computer; i telefoni
  non hanno stato di gioco, solo la vista del loro seggio e le domande
  in sospeso. Un telefono non può desincronizzare niente: al massimo
  tace.
- **La console è una pagina web servita dall'host** (proposta A1):
  il telefono apre `http://<ip-del-computer>:8123`, sceglie/riceve il
  suo seggio, fine. Niente installazione, niente store, funziona su
  qualsiasi telefono della casa. Godot ha i pezzi (`TCPServer` per
  servire la pagina statica, `WebSocketPeer` per il canale). L'
  alternativa A2 — la console è l'export web di Godot già in CI — è più
  ricca ma più pesante sul telefono e più larga del necessario: la
  console mostra testo, carte e bottoni.
- **Il protocollo è l'`io` sul filo**: tre messaggi dall'host
  (`state` — il pannello del seggio filtrato; `say` — una riga di
  verbale per quel seggio; `choose` — le opzioni del decider) e uno dal
  telefono (`chosen` — l'indice). Ogni messaggio porta il numero di
  soglia: un `chosen` vecchio si scarta, un `choose` non risposto si
  ripropone.

## 3. La disciplina dei segreti sul filo

La regola dei pixel (§11.1) diventa regola dei messaggi: **il filtro sta
nell'host, prima della rete** — sul telefono arriva solo ciò che il suo
seggio ha diritto di leggere. Concretamente: la vista console si
costruisce con gli stessi `render(session, viewer_id)` di oggi, e il
serializzatore di rete rifiuta per costruzione i campi senza viewer.
La prova è una **sonda dei messaggi** in headless, gemella della sonda
della visibilità: 100 semi, ogni messaggio uscito verso ogni console,
zero campi che il viewer non avrebbe visto sul suo schermo. La Tensione
velata al telefono di chi non sa è la stessa domanda coperta del tavolo
fisico.

## 4. L'accoppiamento e il rientro

- **Accoppiamento**: all'apertura della stanza, la vista tavolo mostra
  per ogni seggio umano un **QR** (l'URL con un token di seggio) e lo
  stesso token in quattro lettere per chi il QR non lo legge. Chi
  inquadra il QR di Aldric *è* Aldric: il token è il segreto di seggio,
  e lo schermo grande smette di mostrarlo appena la console si aggancia.
- **Rientro**: il token vive nel telefono (localStorage); un telefono
  riavviato riapre la pagina, ripresenta il token, e l'host gli rimanda
  lo stato corrente più il `choose` in sospeso. Se un telefono muore
  davvero, il tavolo può rigenerare il token di quel seggio (e il
  vecchio smette di valere). La partita non aspetta mai un socket:
  aspetta una *risposta*, comunque arrivi — anche dallo schermo grande
  in emergenza (la console di riserva è la vista di oggi).

## 5. Le fasi, ognuna col suo «fatto quando»

1. **Le due viste dallo stesso mondo** (senza rete): la vista tavolo e
   la vista console come ricomposizioni degli stessi pezzi, affiancate
   sullo stesso schermo in dev. *Fatto quando*: la sonda della
   visibilità passa su entrambe; il playtest non cambia di un byte.
2. **Il filo in casa**: host HTTP+WebSocket, protocollo
   `state/say/choose/chosen`, la sonda dei messaggi. *Fatto quando*: una
   partita headless con due console simulate è identica byte per byte
   alla stessa partita senza rete; la sonda dei messaggi dà zero fughe
   su 100 semi.
3. **Il telefono vero**: la pagina console, QR, rientro. *Fatto quando*:
   il criterio della voce 27 — mappa sul computer, due telefoni, i
   segreti solo al loro seggio, un telefono riavviato rientra senza
   perdere niente.
4. **La rifinitura da tavolo**: la cronaca a metà anno sullo schermo
   grande, l'eco del cambiamento, i suoni/attese (materia di gusto, si
   decide vedendola).

## 6. I rischi onesti

- **Le reti di casa**: router con isolamento AP (il telefono non vede il
  computer) e telefoni che addormentano il WiFi. Mitigazioni: messaggio
  di diagnosi chiaro sulla vista tavolo («la console di Aldric non
  risponde da 20s»), ping periodico, e la console di riserva sullo
  schermo grande. Non si promette magia: se la rete di casa isola i
  client, lo si dice e si gioca col tablet passato di mano (la strada 1
  di COMPONENTS §7 resta valida come ripiego).
- **iPad come host**: l'export web di Godot non può aprire socket in
  ascolto dentro Safari. Finché è così, «il computer» è un computer (o
  l'app nativa su iPad, materia della 0.6+); il dossier lo dichiara
  invece di scoprirlo poi.
- **Il determinismo**: la rete non tocca il motore — l'`io` remoto
  restituisce indici come l'`io` locale. La guardia è la fase 2: partita
  con console simulate identica byte per byte.

---

## 7. Le domande secche

- **A. La console**: pagina web servita dall'host (A1, raccomandata:
  zero installazione) o export web di Godot come console (A2, più
  ricca, più pesante)?
- **B. L'accoppiamento**: QR + token di seggio sullo schermo grande ti
  va? E il tavolo deve poter *rigenerare* il token di un seggio a
  partita in corso?
- **C. Lo schermo grande**: pura vetrina (tutto si decide dai telefoni,
  raccomandata) o anche interattivo (il tavolo può toccare — utile per
  la console di riserva, rischia dita di troppo)?
- **D. L'ordine**: le fasi 1→4 come sopra, cominciando dalla
  ricomposizione senza rete?

---

## 8. Verbale delle risposte

Seduta del 2026-08-18, risposte del committente:

- **A — la console è la pagina web servita dall'host** (A1, la
  raccomandata): il telefono apre un indirizzo, niente installazione.
- **B — «ok»**: accoppiamento col QR + token di seggio, e il tavolo può
  rigenerare il token a partita in corso.
- **C — «vetrina + ispezione»**: lo schermo grande accetta solo tocchi
  che *guardano* (zoom su una Regione, il libro della cronaca, il
  verbale), mai tocchi che *decidono* — un tocco sul tabellone non ha
  identità di seggio. La console di riserva esiste ma solo su
  dichiarazione esplicita del tavolo («il telefono di Aldric è perso»),
  e l'app dice ad alta voce il costo di segretezza prima di mostrare le
  opzioni del seggio sullo schermo comune.
- **D — «ok»**: le fasi 1→4, cominciando dalla ricomposizione delle due
  viste senza rete.
