# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).
Il progetto segue le milestone della specifica esecutiva v0.2.

---

## [0.1.8] — Fra una Chronicle e l'altra passano secoli

Un audit di dieci Chronicle ha prodotto un registro di 28 Verità con **12 frasi
diverse**, e la più frequente era *«la corona fu divisa in due»* — **sei volte in
dieci anni**. Una corona non si divide sei volte. Succedeva perché il motore
aggiungeva un anno e rimetteva a sedere le stesse quattro persone con la stessa
domanda ancora aperta.

### L'id è il seggio, non la persona

`ENT_ALDRIC` è la casa che tiene Eredan. **Chi siede sulla sedia** — nome,
Destino, generazione — è stato del mondo e cambia da una Chronicle all'altra.
Tenere fermo l'id è ciò che permette a ogni Cicatrice, tag e controllo scritti
prima di continuare a puntare a qualcosa che esiste ancora.

Chi sopravvive a un salto è scritto nei dati: `persistence` è **MORTAL** (una
persona), **COLLECTIVE** (un popolo, che cambia senza finire) o **ETERNAL**
(qualcosa sotto una montagna). Un seggio mortale che attraversa 25 anni o più
prende un nome nuovo dalla propria lista di successori — Re Serane, Re Corvin,
Regina Isaura, Mira la Cartografa.

### Il salto lo dichiara la Chronicle

`years_after_previous`: un numero, o un intervallo pescato dal seme. `CHR_01` è
l'anno scritto e dice 1. `CHR_02`, quella che si pesca le domande da sola, dice
**20-200**: una saga di Chronicle di biblioteca copre secoli, e li copre in modo
riproducibile.

### Le tre eredità, ognuna con la sua condizione

- **La posizione, sempre.** La mappa è il mondo e il mondo non riparte da capo.
- **I rapporti, ma il tempo li smussa.** Oltre i 50 anni ogni rapporto si sposta
  di un passo verso NEUTRAL: una guerra si ricorda come un rancore, un'alleanza
  come una cortesia. I tag restano comunque: quelli erano scritti.
- **Il Destino, ma solo di chi ha fallito.** Chi ha raggiunto VICTORY o TRIUMPH
  pesca la cosa dopo dal proprio `destiny_pool`; chi è rimasto al MINIMUM
  riprova con lo stesso obiettivo. È questa la regola che tiene viva una domanda
  attraverso le generazioni invece che attraverso le primavere.

Otto Destini adesso, due per seggio: quello con cui comincia e quello che vuole
dopo averlo ottenuto.

### Misurato, sugli stessi dieci semi

| | prima | dopo |
|---|---|---|
| anni coperti | 812 → 821 | 812 → **1767** |
| frasi distinte nel registro | 12 su 28 | **19 su 24** |
| la frase più ripetuta | **6 volte** | 3 volte |
| persone sedute al tavolo | 4 | **12** |

I tre piani di simulazione escono **riga per riga identici**: una Chronicle sola
non ha nessun salto da fare. Quello che è cambiato è `world.entities`, che ora
porta nome, Destino e generazione.

---

## [0.1.7] — Le carte di Propp esistono anche sullo schermo

C'erano due mazzi e se ne vedeva uno solo. Le 48 carte Asset sono tue: le peschi,
le tieni, le spendi, e dalla 0.1.5 dicono cosa fanno. Le **24 carte Echo** — una
per ogni funzione di Propp, in quattro famiglie drammatiche da sei — non le pesca
nessuno: **ne esce una alla fine di ogni Atto**, dal mazzo che quell'Atto ammette
(il primo solo *pressione*, l'ultimo soprattutto *risoluzione*). Muovono il mondo
da sole, due di loro **convocano un Consiglio sul posto**, e ognuna scrive nel
mondo la funzione che ha appena svolto, così che una carta successiva possa
richiederla: un Ritorno ha bisogno di una Separazione da cui tornare.

Sullo schermo erano un paragrafo che scorreva via nel transcript.

### Added

- **`ui/echo_card_view.gd`** — la carta prende il centro dello schermo, col
  colore della sua famiglia, il suo testo, la funzione di Propp in italiano, e
  **cosa ha appena cambiato**. Resta lì finché non premi Avanti. Tre volte per
  Chronicle, nei tre momenti in cui la storia gira.
- **`act_echo_drawn`** sul controller: la carta e gli Effect che ha applicato.
  Nessuno nel motore lo ascolta — esiste perché lo schermo possa dire cosa la
  carta *ha fatto*, non solo cosa dice. C'è un test che gioca una Chronicle
  intera e pretende tre carte, ognuna con almeno un Effect, ognuno dicibile.
- **`scripts/core/effect_text.gd`** — un Effect in una riga italiana: «La
  Successione sale di 2», «Eredan: condition:contested», «Cicatrice in Valle
  Verde: …». I tipi che non conosce si dichiarano per nome invece di tacere.
- La pagina «Come si gioca» adesso spiega anche questo mazzo.

---

## [0.1.6] — La seconda Chronicle, e il mondo che puoi rigiocare

### Added

- **`CHR_02` si gioca nel browser.** Esisteva dalla D-028 ed è il senso del
  modello a biblioteca: non elenca le proprie domande, **ne pesca quattro fra
  sei**, quindi due partite non sono lo stesso anno. Dalla riga di comando si
  poteva già (`--chronicle=CHR_02`); nel browser `CHR_01` era scritto dentro il
  codice.
- **Il seme si sceglie.** «Un mondo a caso», «Rigioca il seme *N*» (quello
  dell'ultima partita) oppure lo scrivi tu. Il seme viene stampato in cima a
  ogni Chronicle dalla 0.0 proprio perché un anno che vale la pena raccontare si
  possa rigiocare — e fino a ieri non c'era nessun posto dove riscriverlo.
- **I rapporti fra le Entità**, sotto le domande dell'anno: tre righe, colorate
  lungo la scala da `enemy` a `bound`. Erano informazione pubblica che il
  browser non mostrava — si leggeva solo dentro un bottone che si offriva di
  romperli — e i Destini li contano: chi non li vede viene giudicato su qualcosa
  di invisibile.
- La pagina delle regole si riscrive per l'anno scelto. E la stessa cosa ha
  trovato un errore che sarebbe scoppiato in faccia a chi sceglie `CHR_02`:
  leggeva `chronicle["tensions"]`, che una Chronicle a biblioteca non ha. Adesso
  legge il pool e lo dice: *questa Chronicle ne pesca 4 fra queste*.

---

## [0.1.5] — Le carte dicono cosa fanno

Due buchi rimasti dalla 0.1, uguali fra loro: le regole davano qualcosa a chi
gioca e il gioco se lo teneva.

### Added

- **Il recupero dopo una sconfitta adesso lo scegli tu.** Il §12.3 dice che
  quando una proposta cade, chi si era opposto **si riprende una delle carte che
  aveva messo giù**. Era l'unica decisione delle regole che nessun giocatore
  veniva mai chiamato a prendere: la faceva la policy, prendendo la più forte.
  Si chiede dove la chiedono le regole, cioè **prima del tiro** — «se la proposta
  cade, quale carta ti riprendi?» — e solo quando c'è davvero da scegliere: chi
  non si è opposto non recupera niente, una carta che per sua regola non torna
  mai non viene offerta, e una carta sola non è una scelta.
- **`scripts/core/asset_text.gd`** — una carta detta in una riga, la stessa per
  il terminale e per il browser: il bonus nei termini in cui il resolver lo
  applica (`+2 se ti opponi`, non `+2`), cosa succede alla carta dopo, e cosa
  costa impegnarla. Ogni pezzo è costruito dai campi che la risoluzione legge
  davvero, quindi una carta non può dire una cosa e farne un'altra.
- **In Consiglio le carte da impegnare lo dicono**: «Interdetto — authority,
  vale 3 · si scarta comunque · costa: la domanda in gioco sale». E nella mano,
  fermando il cursore su una carta, compare tutto: cosa vale, cosa le succede,
  cosa costa, e la riga che le ha scritto l'autore.

### Fixed

- **La mano si calcolava il valore da sola** — `forza se rilevante, 1 altrimenti`
  — ignorando il `confluence_modifier`. I Mercenari (forza 1, +1 sempre) valgono
  2 e la carta diceva 1. Adesso chiama `ConfluenceResolution.asset_value`, la
  funzione del resolver: il numero sulla carta è il numero che entra nella
  somma. È la seconda volta quest'anno che una mano mostra un valore che la
  risoluzione non darebbe (D-040); è l'ultima possibile, perché non c'è più un
  posto dove ricalcolarlo.
- Il tooltip è disegnato invece che lasciato al default: quello di Godot non va
  a capo, e una carta con una riga da 130 caratteri si dipingeva addosso alla
  mano.

---

## [0.1.4] — Il gioco spiega se stesso

Fino a ieri si apriva la pagina, si sceglieva un seggio e ci si trovava davanti
quattordici bottoni. Le regole c'erano — in `docs/RULES_V0_2.md`, cioè esattamente
dove chi si siede a giocare non guarderà mai.

### Added

- **`ui/help_panel.gd` — una pagina «Come si gioca»** che prende il centro dello
  schermo: la forma dell'anno, le sei cose che può fare un'azione, le domande di
  quest'anno con soglia e famiglie che ascoltano, cosa succede in un Consiglio,
  e come si vince. Si apre da sola al menu, si toglie di mezzo quando comincia
  la Chronicle, e resta a un bottone di distanza per tutto l'anno.
- **Metà della pagina è scritta dai dati**, non battuta a mano: gli Atti, i
  round, le azioni per round, il limite di mano, quante carte si impegnano, le
  quattro Tensioni con le loro soglie, le sei Regioni. Una pagina di regole che
  può andare fuori sincrono con le regole è peggio di niente.
- **Una riga di contesto sopra le scelte**, che spiega *questo turno*:
  «La Carestia è a un passo dalla soglia: un'altra spinta e si apre il
  Consiglio», «Consiglio aperto: qui valgono forza piena le carte wealth,
  people, authority». Legge solo quello che il tuo seggio ha diritto di leggere:
  di una domanda velata dice che c'è, non quanto vale.

---

## [0.1.3] — Le 48 carte

Il traguardo §19.4 sugli Asset: da 12 carte a **48**, otto per famiglia.

### Added

- **36 nuove carte Asset.** Una parola sola — la rarità — dice tutto quello che
  serve sapere: **comune** = forza 1, 4 copie · **non comune** = forza 2, 2
  copie · **rara** = forza 3, 1 copia. Sono 22 carte per mazzo di famiglia, 132
  in tutto.
- **Ogni famiglia sa dire di no.** Due carte per famiglia pagano sul fronte
  Oppose, e una vale di più quando la domanda è la sua. Prima erano quattro
  carte in tutto il gioco.
- **Le carte da 3 costano.** Il Vecchio Esercito, Le Porte Bruciate, l'Atto di
  Successione, l'Esodo, il Cristallo Rosso, l'Ipoteca sulle Terre, l'Ostaggio,
  il Patto Rotto e le altre: si scartano comunque, e impegnarle fa qualcosa al
  mondo — alza la Tensione, o mette il tuo rivale dove si sta discutendo, o ti
  toglie da lì. Una carta che vale 6 senza contropartita non è una scelta, è la
  mossa giusta.
- `on_commit_effects` era esercitato da una carta sola nella 0.0 (O-3). Adesso
  sono tredici.
- **`cli/run_margin_probe.gd`** — la sonda che ha trovato il problema qui sotto:
  stampa S, O e la distribuzione di M, non solo il conteggio degli esiti.

### La tabella degli esiti si è rotta, e la media non lo diceva

Con le 48 carte al primo tentativo, sulle stesse 40 Chronicle: **Decisivo dal
33% al 49%**, con metà dei Consigli che passano senza discussione. E la media
del margine era **identica** (3.23 → 3.37).

Quattro tentativi di aggiustarlo cambiando i pesi non hanno spostato niente,
perché miravano alla media. La distribuzione ha mostrato la causa in un colpo:
con due carte per famiglia un impegno era quasi sempre 2+2, e il set da 12
ammucchiava tutto su **M = +4**, un punto sotto la banda Decisiva. Una biblioteca
più ampia liscia la distribuzione e sposta quel mucchio di un punto — oltre la
riga.

La cura è stata la **curva**, non i pesi: la rilevanza è scesa dalle carte da 2 a
una carta da 1 per famiglia, e una carta da 2 per famiglia è diventata una da 1.
Un impegno preparato torna a valere 4 invece di 6.

| | Failure | con Costo | Successo | Decisivo |
|---|---|---|---|---|
| 12 carte | 16% | 13% | 38% | 33% |
| 48 carte | **21%** | 15% | 30% | **34%** |

Il resolver non è stato toccato: §A5 è la specifica, il contenuto è quello che si
tara (D-023, D-040).

### Fixed

- **La mano dichiarava un ×2 che la regola non ha.** Dalla 0.1.1 una carta
  rilevante veniva disegnata come `authority · 2 ×2 = 4`. Il §9 dice che un Asset
  vale la sua **forza piena** se la famiglia è rilevante e **1** altrimenti: la
  rilevanza non raddoppia niente. Adesso la carta dice `authority · vale 2`, e
  `vale 1` quando la domanda non è la sua.

### Il prezzo, detto

- **Consigli per Chronicle: mediana da 5 a 6**, e una partita su quaranta arriva
  a 8 contro il tetto di 7 del §7. Il test di bilanciamento passa (tollera il
  10% fuori banda), ma la deriva è vera ed è il numero da guardare nella 0.2.
- **I tre piani di simulazione escono diversi** e sono stati **rimisurati**, non
  ritoccati: le tre storie tengono ancora, le sequenze di esito no.

---

## [0.1.2] — La mappa si preme, e il Consiglio dice cosa costa

Le due cose che nella 0.1 restavano a meta: una mappa che si guardava e basta, e
una plancia con un buco in mezzo.

### Si gioca sulla mappa

- **Le mosse si scelgono premendo una Regione.** Le Regioni raggiungibili sono
  cerchiate d'oro, si illuminano sotto il cursore e il puntatore diventa una
  mano; le altre non reagiscono, perche una Regione che si accende e poi non fa
  niente sembra un gioco rotto. Il bottone «Metti una presenza in…» sparisce
  dalla colonna: erano fino a sei voci su quattordici.
- **La legalita non si sposta sulla mappa.** `SeatDecider` dice *di cosa parla*
  ogni scelta (`{"region": "REG_X"}` su una mossa) e la mappa riceve l'insieme
  gia filtrato dalle regole: disegna, non giudica. Il terminale riceve lo stesso
  dato e lo ignora — una lista numerata e gia tutta la mappa che ha (D-039).

### Il momento in cui il gioco decide qualcosa

- **La plancia si ferma sul Consiglio appena chiuso** finche non premi Avanti.
  `resolve()` esegue F-K in un passo solo e si azzera alla fine: il tiro, la
  somma e le conseguenze non erano mai stati su schermo per un frame — nemmeno la
  riga `Fattore Mondo` aggiunta nella 0.1.1.
- **Il conto in chiaro**: `S 6 · O 7 · Mondo +0 -> M -1 — Respinta`.

### Cosa metti in gioco quando dici «sostengo»

- **Al centro della plancia adesso ci sono le Conseguenze**: prima del voto quelle
  che la proposta scriverebbe sul mondo, dopo il voto quelle che ci ha scritto
  davvero. Ognuna col suo titolo, la sua riga di testo, e **«lascia una
  Cicatrice»** quando e il caso. Fino a ieri l'unico modo di scoprirlo era
  perdere e leggere il log.
- Il motore riporta le Conseguenze applicate (`result["consequence_ids"]`) invece
  di farle ridedurre allo schermo: quale pool si applica dipende dall'esito, e
  riscriverlo nella UI sarebbe l'ordine di risoluzione scritto due volte.

### Fixed

- La freccia di `1d6 = 6 → +2` era un quadratino vuoto nel font di fallback del
  build Web, proprio nella riga che serve a rifare il conto. Ora e `->`.

Il motore resta byte-identico: le tre sim escono uguali carattere per carattere.

---

## [0.1.1] — La plancia del Consiglio

Il momento in cui il gioco decide qualcosa adesso sembra tale.

### Added

- **`ui/confluence_board.gd`** — quando un Consiglio si apre, prende il centro
  dello schermo al posto della mappa. In alto la Tensione e chi propone, poi la
  domanda in grande, poi la proposta. Sotto, i quattro seggi in colonna: il
  proponente marcato, gli altri con `…` finche non parlano, e la loro posizione
  colorata quando arriva — verde chi sostiene, rosso chi si oppone, ambra chi
  pone una condizione.
- **Gli impegni restano vuoti fino al passo E.** Quello che qualcuno ha messo giu
  non e pubblico finche non e pubblico: la colonna si riempie tutta insieme, alla
  rivelazione simultanea, com'e nelle regole (§12.2 E).
- **Le scelte stanno dentro il Consiglio**, come carte accanto alla domanda a cui
  rispondono, invece che nella colonna laterale dove vivono le azioni. Stesse
  etichette, stesso contratto, posto diverso sullo schermo.
- **Il Fattore Mondo in chiaro** una volta tirato: `1d6 = 6 → +2`. §12.2 G e il
  momento in cui il gioco decide, e chi gioca deve poter rifare il conto.

### La mano cambia significato

Con un Consiglio aperto le carte rilevanti passano da `authority · 2` a
`authority · 2 ×2 = 4`. E il numero che entra davvero nella somma, e compare nel
momento in cui compare la domanda.

### La cucitura, di nuovo

La plancia legge `session.confluence.current` — lo stesso dizionario che rende il
log e che il terminale stampava nella 0.0 — e non decide niente. Le scelte
arrivano come `ask(prompt, labels)` gia formattate da SeatDecider, e vengono
disegnate come carte: **la plancia non sa se sta mostrando proposte, posizioni o
Asset**, e non deve saperlo. E quello che impedisce a browser e terminale di
offrire opzioni diverse.

Il motore resta byte-identico a prima di tutta la UI.

---

## [0.1.0] — Un tabellone, non un resoconto

La milestone 0.1 comincia da dove serviva: chi apre la pagina vede una **mappa**,
non un muro di log.

### Added

- **`ui/map_view.gd`** — le sei Regioni, le strade fra loro, e chi sta dove. I
  token di presenza sono punti colorati per Entita, l'anello attorno alla Regione
  e chi la controlla (niente anello = nessuno, che e un fatto da vedere, non un
  vuoto), e sotto il nome compaiono condizioni, strutture e **Scar in rosso** —
  l'unico segno che non viene mai via.
- **`ui/status_panel.gd`** — le domande dell'anno come tracciati con soglia, che
  virano all'ambra a un passo dal limite e al rosso quando lo superano. Una
  Tensione velata mostra una barra vuota e la parola *velata*: presente,
  illeggibile, e chiaramente li. E la scala del Destino, con le caselle gia
  spuntate.
- **`ui/hand_view.gd`** — la mano come carte, con il colore della famiglia. Quando
  un Consiglio e aperto, una carta rilevante scrive il numero che entra davvero
  nella somma (`authority · 2 ×2 = 4`) invece di quello stampato con una nota.
- **`map_position`** nello schema delle Regioni: coordinate normalizzate 0..1,
  autorate e non calcolate. Un algoritmo di layout disegna un'immagine corretta
  dell'adiacenza e sbagliata del mondo, perche non sa che le montagne stanno a
  ovest e che la valle nutre la citta.

### La cucitura ha retto

Nessuno dei tre nodi conosce una regola o puo raggiungere un decisore: prendono
`(session, viewer_id)` e disegnano quello che **quel seggio** ha diritto di
vedere — la stessa regola di §11.1 che segue il terminale, applicata ai pixel.
Il motore non e stato toccato: i tre piani di simulazione escono byte per byte
identici a prima della UI.

### Fixed

- Le spunte del Destino uscivano come quadratini: il font di fallback di una
  build Web non ha il segno di spunta, e un glifo mancante si legge come un bug
  del gioco invece che come un buco nel font. Ora e ASCII.

---

## [0.0.14] — La Chronicle sa aspettare un click

ECHOES gira in un browser, su GitHub Pages, da `godot/ui/`.

### Changed

- **`ChronicleController.run()` e una coroutine.** Un terminale puo bloccarsi su
  stdin dentro una chiamata sincrona; un browser non puo bloccarsi su un click
  senza congelare la pagina e non riceverlo mai. Le sei chiamate al decider sono
  `await`, e `run()` / `play_act()` / `play_round()` / `run_confluence()` sono
  coroutine. **Nient'altro e cambiato**: un decider che risponde subito non
  sospende mai, e la prova e che i tre piani di simulazione escono **byte per
  byte identici** a prima, e cosi tutte e sei le sonde.

- **`scripts/seat/seat_decider.gd`** — quello che un seggio vede e puo fare, con
  l'I/O **iniettato** invece che ereditato: un oggetto qualsiasi con `say(text)` e
  `choose(prompt, labels) -> int`. `cli/terminal_io.gd` lo implementa su stdin e
  stdout, `ui/game_screen.gd` lo *e* per il browser. Cosi le due interfacce non
  possono litigare su quali azioni siano legali: e lo stesso decider.
  `policy_decider.gd` si sposta da `cli/` a `scripts/seat/` — e l'avversario, e
  nel browser serve.

### Added

- **`godot/ui/`** — un resoconto e una colonna di bottoni. Non e la mappa, non e
  la plancia della Confluence: quello e il lavoro della 0.1. E la cucitura che
  regge — lo schermo non decide niente e non legge le regole.
- **`.github/workflows/pages.yml`** — export Web e pubblicazione su Pages a ogni
  push su `main`. Single-thread di proposito: la build con i thread richiede
  `SharedArrayBuffer`, che richiede header COOP/COEP, che Pages non puo mandare.

### Fixed

Tre bug che **solo il browser** ha trovato. Playwright ha caricato la pagina
esportata e ha giocato una Chronicle a click. Ognuno di questi era passato prima
attraverso tutti i controlli headless:

- Il decider del browser ereditava da `cli/human_decider.gd`, e `cli/*` e escluso
  dall'export: script irrisolvibile, pagina bianca. `extends "res://path.gd"` non
  sopravvive all'export, `preload` si — che e esattamente il motivo per cui
  questo progetto usa `const X := preload(...)` e niente `class_name`.
- `scripts/seat/` mancava del tutto dal pacchetto: l'export era girato prima che
  la cache di import vedesse la cartella nuova. Il workflow ora importa prima.
- `policy_decider.gd` stava in `cli/`.

Nessuno dei tre e esotico, e nessuno sarebbe stato preso da qualcosa di meno che
aprire la pagina. **Una build che compila ed esporta non e una build che gira.**

---

## [0.0.13] — Il quinto decisore e una persona

### Added

- **`cli/run_hotseat.gd` + `cli/human_decider.gd`** — ECHOES si gioca alla
  tastiera. Il tabellone si stampa dal punto di vista di un seggio: le domande
  dell'anno con i numeri che *quel* seggio puo vedere (una Tensione velata non
  mostra niente a chi non l'ha esplorata, §11.1), la mappa, la mano, e il Destino
  come una scala con le caselle gia spuntate. Il menu delle azioni lo costruisce
  il resolver: ogni voce ha gia passato `can_execute`, quindi non ti viene mai
  offerto qualcosa che le regole poi rifiutano.

  `--seats=all` per quattro giocatori, `--seats=ENT_NAHR` per uno solo contro tre
  policy. **Nessuna regola e stata trattata in modo speciale**: il
  ChronicleController chiede a un `decider` e applica quello che torna, come ha
  sempre fatto. La cucitura scelta nella 0.0.1 ha retto senza toccare una riga
  del controller.

- **`tools/play.sh`** — `tools/play.sh --seats=all` e via. Trova Godot da solo
  (`$GODOT`, poi il PATH, poi un binario lasciato accanto al progetto) e se non
  lo trova spiega dove prenderlo invece di fallire con un comando non trovato.
  Avverte anche quando stdin non e un terminale, perche in quel caso ogni scelta
  senza risposta la prende la policy — legittimo per pipare un file di risposte,
  sorprendente se ci sei arrivato per sbaglio.

- **`tests/smoke/test_hotseat.gd`** — un tavolo di quattro "umani" che non
  rispondono niente deve produrre una Chronicle **identica riga per riga** a una
  giocata da quattro policy, e ogni azione che il menu offre dev'essere una che
  il resolver accetta.

### Fixed

- **La stringa vuota che chiudeva fuori i giocatori.**
  `OS.read_string_from_stdin` restituisce **la stessa stringa vuota** per un
  Invio a vuoto e per la fine dell'input: misurato, non supposto. La prima
  versione ci provava lo stesso e si spegneva alla prima lettura vuota — cosi
  **chi accettava un solo default restava chiuso fuori dalla propria partita**,
  in silenzio, senza che niente andasse in errore. Ora vuoto vuol dire "decidi
  tu", che e anche il comportamento giusto a fine input.

---

## [0.0.12] — Nessuno aveva un motivo per essere nella stanza

Chiude O-12, O-13 e la serratura di Vaerax. Tre cose aperte, sistemate insieme
perche erano la stessa cosa vista da tre lati.

### Changed

- **Il proponente lo decide il posto, non il dominio.** §12.2 C dice "piu
  presenza nelle Regioni della Tensione"; era letto come l'intero dominio, ora e
  la Regione di cui si sta discutendo. `domain:ANCIENT` sono due Regioni e il
  Destino di Vaerax lo pianta in entrambe: tutti e 40 i Consigli sul Risveglio
  erano suoi, e non era mai in aula a votare l'unica Tensione che gli importa.
  Misurate due estensioni del dominio: **nessuna rompe la serratura**, una la
  peggiora. Le Vie passano da 2 proponenti a 4, la Successione da 1 a 2.

- **O-12: la Successione e le Vie hanno una posta in gioco.** Il primo tentativo
  — un `tension_limit` a testa — ha peggiorato le cose: un tetto fa spendere
  azioni a tenere giu la Tensione, e tenerla giu fa smettere di porre la domanda.
  Le Vie erano passate da 36 Consigli a 6. Una posta non deve essere un limite su
  un numero: un **tag** pesa sulle proposte e non guida nessuna azione. Due
  coppie di poste direttamente opposte — `crown_divided` fra Aldric e i Nahr,
  `condition:cut_off` fra Lyra e Vaerax — danno la lite senza il silenzio.

- **O-13: `P_ANY_LEAVE` ha un motivo per essere proposta.** Dare solo
  `ADJUST_TENSION -2` non bastava: `P_ANY_RATION` offriva lo stesso sollievo piu
  la Regione, quindi andarsene restava dominato. Il premio giusto era scritto
  nella categoria stessa della Conseguenza — **MIGRATION, non LOSS**: chi se ne
  va arriva da qualche parte. Ora arriva al voto 7 volte su 40 Chronicle, e
  `condition:abandoned` viene scritto per la prima volta.

- **La banda dichiarata passa da 4-5 a 5-6.** Misurata, isolata e dichiarata, non
  aggiustata in silenzio. E la giustificazione non e "il test falliva": il 3-4 di
  §7 sulle due Tensioni di §18.2 e 1,5-2,0 Confluence **per Tensione**, mentre il
  4-5 di D-026 su quattro Tensioni e 1,0-1,25 — era piu severo di quanto §7 abbia
  mai chiesto. Il tasso misurato ora e 1,3 per Tensione, ancora sotto quello di
  §7.

### Measured

| | prima | dopo |
|---|---|---|
| consigli con almeno un no | 28% | **50%** |
| seggi che si oppongono almeno una volta | 3 | **4** |
| opposizioni di Vaerax | 0 | **26** |
| mappe di controllo distinte | 8 | **16** |
| stato finale distinto (su 40 partite) | 38 | **40** |
| Scar per Chronicle | 1,60 | **2,00** |
| tag mai scritti (CHR_01 / CHR_02) | 3 / 1 | 3 / **0** |

Ogni singola Chronicle su quaranta finisce ora in uno stato del mondo diverso.

### Fixed

- **I tre piani di simulazione, riautorati.** Plan B spostava un token sulla
  Strada dei Mercanti per vincere il dominio SURVIVAL: sotto la regola nuova e il
  posto sbagliato, perche il Consiglio parla della Valle. Spostato nella Valle, la
  sua storia torna esatta — i Nahr chiedono la terra e il tavolo intero risponde
  di no, **S1 O7 M−4**. Plan A e sceso da tre Consigli a due, e il motivo e il
  gioco che funziona: la requisizione decisiva sgombera i Nahr dalla Valle, e
  senza quella presenza nessuno puo piu toccare le Vie per il resto dell'anno. Ora
  il piano lo dice nella propria descrizione invece di pretendere un numero.

### Open

- **O-14** — la classifica dei Destini si e inclinata: Aldric resta al Minimum in
  32 Chronicle su 40, Lyra arriva al Triumph in 32. Nessuno e piu congelato come
  prima di D-035, ma lo spread e sbilanciato. Registrato e non tarato: tre giri di
  misura di fila hanno trovato lo strumento in torto e non le regole, e la lezione
  e non correre alle manopole.

---

## [0.0.11] — La prima domanda di ogni Consiglio non veniva mai posta

Chiude O-6 e O-8. Cercavo contenuto da scrivere e ho trovato di nuovo lo
strumento — ma stavolta quello che c'era sotto valeva piu della correzione.

### Changed

- **`PolicyDecider.choose_question` sceglie davvero.** Restituiva `""`, cioe
  rinunciava a scegliere, e vinceva sempre il default: *l'ultima* domanda
  ammissibile. Ogni seconda domanda e vincolata a una Tensione al limite, e un
  Consiglio si apre solo quando la sua Tensione e al limite — quindi la seconda
  domanda era sempre ammissibile e **la prima domanda di ogni template non e
  mai stata posta in quaranta Chronicle**. Le sue proposte non potevano essere
  votate e le loro Conseguenze non potevano scattare: era tutto O-8.

  Un essere umano al tavolo se le vedeva offrire entrambe. Il contenuto non era
  irraggiungibile: era il giocatore che misura a non allungare mai la mano.

### Measured

| | prima | dopo |
|---|---|---|
| coppie domanda/proposta votate | 7 su 18 | **12** |
| tag di Regione mai scritti | 9 | **3** |
| consigli con almeno un no | 16% | **28%** |
| SUCCESS_WITH_COST | 6 | **27** |
| DECISIVE_SUCCESS | 105 (57%) | **76 (39%)** |
| mappe di controllo distinte | 3 | **8** |
| Scar per Chronicle | 1.15 | **1.60** |

E i Destini si sono scongelati. Nella saga di dieci Chronicle Lyra faceva
TRIUMPH dieci volte su dieci e Vaerax VICTORY dieci su dieci, ogni anno,
identici. Ora Aldric fa MIN 18 / VIC 10 / TRI 12, Lyra MIN 23 / TRI 17, Vaerax
VIC 22 / TRI 18. Nessun seggio ha piu un finale gia scritto.

### Fixed

- **La guardia di D-034 era scritta male.** Contava quante volte ogni Effect
  spostava il punteggio durante partite vere, ed e fallita appena il contenuto
  si e mosso — non perche la policy fosse cieca, ma perche le proposte che ora
  vengono avanti toccano la Successione e le Vie, che **nessun Destino di
  CHR_01 nomina** (O-12). Una guardia che non sa distinguere "la policy e
  cieca" da "il contenuto si e spostato" e peggio di niente: grida al lupo a
  ogni cambio di contenuto e si zittisce tarando. Riscritta come quattro casi
  costruiti, e verificata togliendo un ramo alla volta.
- **`run_world_probe` mentiva su un tag.** Un tag scritto attraverso uno slot
  (`settlement:$proponent`) e autorato in una forma e atterra in un'altra:
  confrontare le due grafie lo dava per "MAI" mentre scattava ogni partita.

### Open

- **O-12** — nessun Destino mette un limite sulla Successione o sulle Vie.
  Quattro Tensioni, due poste in gioco.
- **O-13** — `P_ANY_LEAVE` toglie presenza e controllo *al proponente stesso*:
  nessuno che gioca per vincere la proporrebbe mai.
- **Vaerax possiede la sua domanda.** Misurato: non e sistemabile dal contenuto.

---

## [0.0.10] — Perche nessuno diceva di no

Restringe O-6. La domanda era: se le crisi arrivano al voto, perche il tavolo le
approva quasi sempre? La risposta e la stessa delle ultime due volte — non le
regole, lo strumento che le misura.

### Added

- **`cli/run_stance_probe.gd`** — la sonda che ha risposto. Per ogni consiglio e
  ogni seggio che non propone registra il punteggio calcolato dalla policy e la
  posizione che ne e uscita, e per ogni Effect se quell'Effect ha spostato il
  punteggio **anche una sola volta**. Il secondo conteggio e quello che conta: un
  Effect letto centinaia di volte e mai pesato non e un Effect silenzioso, e un
  motivo di lite che la policy non sa vedere.

  Ha trovato **96% di ABSTAIN** e un punteggio con soli tre valori possibili
  (−2, 0, +2): `ADJUST_TENSION` (letto 489 volte), `SET_CONTROL` (210),
  `SET_ENTITY_TAG` (300) e `SET_RELATION` (171) non pesavano **mai**.

### Changed

- **`ConfluenceController.effect_context()` e ora pubblico** (era `_context()`).
  Un decisore deve poter valutare una proposta *prima* di votarla, e puo farlo
  solo se risolve `$region_focus` come lo risolvera il passo K. La policy usa la
  tabella del Consiglio, non una copia, cosi le due non possono divergere.
- **`PolicyDecider._score_effect` legge tre assi che prima non vedeva.**
  - `ADJUST_TENSION` contro le clausole `tension_limit`: −2 la spinta che rompe
    una clausola che regge, +2 quella che ne ripara una rotta, ±1 il semplice
    muoversi nella direzione sbagliata o giusta dentro la banda. Rompere una
    clausola vale un no; una direzione che non piace vale una clausola.
  - `SET_ENTITY_TAG discovery:*` contro `discovery_count`, +2 e solo a chi la
    riceve: che un altro impari qualcosa non ti costa niente.
  - Gli `$slot` vengono risolti, e questo da solo ha riportato in vita
    `SET_CONTROL` e `REMOVE_PRESENCE` senza toccarne il punteggio.

  I conflitti erano **gia scritti nei dati**: una proposta che alza la Carestia
  contro un popolo il cui Destino la tiene sotto tre e una lite che il contenuto
  aveva scritto e lo strumento non sapeva leggere.

### Measured

| | prima | dopo |
|---|---|---|
| ABSTAIN | 96.0% | **84.1%** |
| OPPOSE | 2.8% | **5.4%** |
| SUPPORT | 1.2% | **10.5%** |
| consigli con almeno un no | 8% | **16%** |
| FAILURE (su ~180 Confluence) | 7 | **23** |

Non chiude O-6: `DECISIVE_SUCCESS` resta al 57%, e Vaerax si astiene ancora
144 volte su 144 — ma non per cecita della policy: **tutti e 40 i consigli sul
Risveglio li apre lui**, quindi non e mai nella stanza a votare l'unica Tensione
che il suo Destino nomina. Quella e una questione di contenuto.

---

## [0.0.9] — Il vicino, il tipo di luogo, e uno strumento che mentiva

Chiude O-11, il prezzo pagato nella 0.0.8.

### Added

- **`$adjacent`** — la Regione accanto a quella in discussione, scelta come il
  vicino che porta gia **meno segni**. Il danno si sparge invece di accumularsi,
  e si legge bene: il guaio va dove non e ancora stato.
- **`$region_with:<tag>`** — uno slot parametrico: nomina un **tipo** di luogo
  invece di un luogo. Una Conseguenza puo dire *il granaio*, *il crocevia*, *il
  sito del cristallo* e viaggiare da una Chronicle all'altra senza conoscere la
  mappa. Risolto dal compilatore, che per questo ha ricevuto un riferimento al
  mondo; `validate_data.py` verifica che il tag sia dichiarato da qualche
  Regione, cosi un refuso fallisce alla build invece di risolversi in silenzio.

### Changed

- **`PolicyDecider.choose_proposition` rompe i pareggi con l'RNG di sessione.**
  Partiva da `options[0]` e la sostituiva solo con un punteggio *strettamente*
  maggiore: quasi tutte le proposte pareggiano a zero, quindi la prima opzione
  legale vinceva sempre e **dodici delle diciotto proposte autorate non sono mai
  state scelte in quaranta Chronicle**. E un cambio allo *strumento di misura*,
  non alle regole — la stessa lezione di D-021.

### Fixed

- **`run_world_probe` mentiva.** Stampava "il controllo e cambiato: NO" per una
  campagna in cui Aldric perde la capitale alla seconda Chronicle, i Nahr la
  prendono alla sesta e Aldric la riprende alla decima — perche confrontava solo
  la prima e l'ultima mappa, e coincidevano. Ora conta tutte le mappe di
  controllo attraversate. Una misura che confronta gli estremi chiama "nessun
  cambiamento" un viaggio di andata e ritorno.

### La misura

| | 0.0.8 | 0.0.9 |
|---|---|---|
| mappe di controllo distinte (40 partite) | 3 | **5** |
| set di tag distinti | 21 | **31** |
| stato finale distinto | 24 | **31** |
| Scar per Chronicle | 0.17 | **1.52** |
| proposte diverse messe ai voti | 6 | **10** |
| frasi Truth distinte | 56 su 94 | **73 su 104** |
| tag sulla mappa in 10 Chronicle | 1 → 10 | **1 → 17** |

Le Scar per Chronicle sono ora il doppio di quante ne avevamo **prima** che la
0.0.8 le perdesse (0.75): la generalizzazione e finita in attivo, non solo
recuperata.

---

## [0.0.8] — Conseguenze a slot, e un registro che non si ripete

Chiude la meta di contenuto di D-028, che era rimasta dichiarata e non fatta.

### Added

- **Quattro slot invece di uno** negli Effect: `$region_focus` (il posto di cui
  discutiamo), `$capital` (il seggio del potere), `$rival` (il posto al tavolo
  contro cui la domanda e posta), `$rival_seat` (dove quel posto sta davvero).
  Sono le quattro cose che una Conseguenza intende quando nomina un nome proprio.
- **`echo_summaries`**: una proposta puo portare una frase per ogni banda di
  esito. Come cade una proposta non si legge come quando trionfa, e il registro
  delle Truth e il posto dove una Chronicle si rilegge. Una banda senza variante
  ricade sulla frase unica, quindi non si e dovuto riscrivere niente.
- **`docs/COMPONENTS.md`**: quale testo sta su quale pezzo fisico, cosa e sullo
  schermo, cosa e segreto e dietro quale paravento. Non era in nessuna specifica.

### Changed

- **21 Conseguenze su 23** riscritte a slot: sono contenuto di biblioteca, non
  piu di Chronicle. I bersagli relazione diventano `$proponent|$rival`, e il
  compilatore normalizza la chiave dopo la sostituzione — la coppia va in ordine
  crescente e i dati non possono sapere come e seduto il tavolo.
- 13 proposte su 18 portano varianti di esito.

### Fixed

- **`$rival` e prefisso di `$rival_seat`**, e il compilatore sostituiva in ordine
  di dizionario: lo slot diventava `ENT_NAHR_seat`, un bersaglio inesistente,
  segnalato solo da un push_error dentro l'applier. Chiavi ordinate per lunghezza
  decrescente, la stessa correzione che `NarrativeText.fill` aveva gia.
- Il controllo statico dei binding non spezzava un bersaglio relazione sul `|`,
  quindi meta coppia non veniva verificata.

### La misura

| | prima | dopo |
|---|---|---|
| frasi Truth distinte su 40 Chronicle | 22 su 63 | **56 su 94** |

E il salto piu grosso di varieta narrativa mai misurato nel progetto, ed e
costato una quarantina di frasi scritte.

### Il prezzo, ed e reale

| | prima | dopo |
|---|---|---|
| mappe di controllo distinte | 6 | **3** |
| Scar per Chronicle | 0.75 | **0.17** |
| il controllo cambia in 10 Chronicle | si | **no** |

`$region_focus` e **stabile** per una Tensione, quindi ogni Conseguenza di quella
Tensione finisce sullo stesso posto, dove sei Regioni scritte a mano spargevano
il danno sulla mappa. Tre Conseguenze sono state ripuntate su `$rival_seat` e
`$capital` e ne hanno recuperato una parte, non tutta.

E uno scambio, ed e registrato come tale: le Conseguenze ora si riusano fra
Chronicle, e la mappa si muove meno dentro una sola. Vedi O-11.

---

## [0.0.7] — Le 24 funzioni

D-030 aveva cablato la grammatica, ma solo 16 delle 24 funzioni dichiarate nello
schema avevano una carta. Le otto mancanti erano anche le piu interessanti da
vincolare: una Punizione dopo una Violazione, una Separazione che rende possibile
un Ritorno.

### Added

- **Otto carte Echo** (16 → 24), una per ogni funzione ancora scoperta: Supplica
  (REQUEST), Offerta (TEMPTATION), Parola Data (VIOLATION), Partenza
  (SEPARATION), Incontro (ENCOUNTER), Presa (CONQUEST), Conto (PUNISHMENT), Chi
  Siede (SUCCESSION). Il mazzo e ora **24 carte, 6 per famiglia drammatica, una
  per funzione dichiarata** — e un test impone tutti e tre i numeri.
- **La condizione `any_of`**: vale se almeno una delle condizioni annidate vale.
  Ogni lista di condizioni nei dati e un AND, e la grammatica di Propp e piena di
  alternative — un Ritorno segue una Separazione **o** una Chiusura. Senza, le
  otto carte nuove non si potevano scrivere onestamente. Dodici righe
  nell'evaluator, un `$ref` a se stesso nello schema, un ramo di ricorsione nel
  validatore.
- Tre Conseguenze nuove (29 → 32) per gli effetti delle carte nuove.

### Changed

- `ECH_ROADS_OPEN`, `ECH_RECONCILIATION` e `ECH_AMNESTY` usano `any_of`: i
  vincoli a un solo antecedente le rendevano piu rare di quanto la grammatica
  richieda.

### La misura

| | D-030 | D-031 |
|---|---|---|
| funzioni con una carta | 16/24 | **24/24** |
| funzioni pescate in 40 Chronicle | 16 | **21** |
| funzioni senza antecedente | 0 | **0** |
| Atto 3 risolve | 23/40 | **28/40** |

Verificato anche sulla Chronicle di biblioteca: 22 funzioni pescate, 0 orfane.

### Segnalato, non corretto

- `SACRIFICE` esce 14 volte su 40 perche e l'unica carta RESOLUTION che non
  presuppone niente, e l'Atto 3 chiede prima una risoluzione. E il prezzo
  dell'invariante — ogni famiglia mantiene una carta sempre giocabile — e
  spianarlo vorrebbe dire inventare un antecedente che un sacrificio non ha.
- La banda delle Confluence e scesa dall'85% al 70% dentro 4-5 con il mazzo piu
  largo, sempre senza niente fuori da 2-7. Resta O-6.

---

## [0.0.6] — Propp entra davvero nel gioco

Le carte Echo portavano due metadati narrativi. Uno lavorava, l'altro era
un'etichetta che il motore non leggeva mai.

### La verifica

`cli/run_echo_probe.gd` su 40 Chronicle:

- **`dramatic_family` era portante**: decide quali carte un Atto puo pescare,
  quindi la forma in tre atti era gia imposta (Atto 1 PRESSURE 40/40).
- **`function_id` non era letto da nessuna riga di codice.** Un grep lo trovava
  in un posto solo: la colonna che lo stampa nel manifest.

Il prezzo: **19 funzioni in 18 partite su 40 arrivavano senza il loro
antecedente** — un Ritorno da cui non si era partiti, una Riconciliazione senza
tradimento, una Liberazione senza niente di proibito. Il punto di Propp e che le
funzioni hanno un **ordine**, e niente lo faceva rispettare.

### Added

- **`function:<ID>` come tag globale** quando una carta viene pescata, applicato
  come un normale Effect. E l'unica modifica al motore, che continua a non
  conoscere il nome di nessuna funzione.
- **La grammatica sulle carte**, nel blocco `eligibility` che avevano gia: la
  Riconciliazione aspetta un tradimento, l'Amnistia un'usurpazione, le Vie
  Riaperte una chiusura, il Giuramento una minaccia, l'Annata Buona una carestia,
  la Rivelazione una scoperta.
- **`cli/run_echo_probe.gd`** e **`tests/unit/test_echo_grammar.gd`**.

### Changed

- **`act_echo_pools[].families` e un sacchetto pesato**, non un insieme:
  ripetere una famiglia la rende piu probabile, e l'RNG seeded decide l'ordine in
  cui le famiglie vengono provate. Nessuna modifica allo schema — le ripetizioni
  erano gia legali, semplicemente non significavano niente.

### Due cose che si sono rotte, e cosa hanno insegnato

**Stringere troppo impedisce all'arco di chiudersi.** Con tutte e quattro le
carte RESOLUTION vincolate, l'Atto 3 e passato da risolvere 18/40 a 11/40: la
pesca saltava le carte vincolate e ripiegava su una rottura. Risolto lasciando
`ECH_SACRIFICE` senza condizioni — un sacrificio non presuppone niente, e una
scelta — e protetto da un test: **ogni famiglia drammatica deve mantenere almeno
una carta sempre giocabile**.

**Una preferenza stretta non e una forma, e un binario.** Leggendo il pool come
preferenza ordinata usciva **un solo arco in tutte e quaranta le partite**: PRE
RUP RES, 40/40. Forma perfetta, zero storia. Da li il sacchetto pesato.

### La misura

| | prima | dopo |
|---|---|---|
| funzioni senza antecedente | 19 (18/40) | **0** |
| Atto 1 apre in PRESSURE | 40/40 | 40/40 |
| Atto 3 risolve | 18/40 | **23/40** |
| archi drammatici distinti | 9 | 9 |

Un Atto 3 che finisce a meta crisi il 40% delle volte non e un difetto: la
domanda rimasta aperta e quello che la Chronicle successiva eredita.

Non previsto, di nuovo: la banda delle Confluence e salita all'**85%** dentro
4-5, dal 75%.

---

## [0.0.5] — Le crisi non si spengono, si spostano

Una verifica chiesta dall'autore: le crisi scoppiano sempre, o un tavolo puo
tenerle chiuse? La risposta misurata era **si, puo tenerle chiuse** — e questo
lo corregge.

### Added

- **`cli/suppressor_decider.gd`** — un tavolo che fa solo soppressione: quattro
  Entita che spendono ogni AO per ricacciare giu la Tensione piu alta che possono
  toccare, comprando una SCHEME quando serve a sbloccarne una velata. Nessuno
  gioca cosi: e uno stress test.
- **`cli/run_crisis_probe.gd`** — fa giocare le stesse Chronicle ai due tavoli e
  riporta, per ogni Tensione, quante volte e scoppiata, il **picco** raggiunto
  (il valore finale nasconde una Tensione portata sull'orlo e ricacciata giu) e
  quanta pressione del mondo e stata annullata.
- **`influence_rules.displacement_on_decrease`** (D-029) — spingere giu una
  Tensione ne alza una delle sue `linked_tensions`. Non si spegne una crisi: si
  sceglie quale avere. Reversibile: si toglie e sparisce.
- Tre test nella suite di bilanciamento sulla regola nuova, incluso che lo
  spostamento **non** consumi una seconda INFLUENCE.

### Changed

- **Il grafo dei collegamenti fra Tensioni riscritto.** Prima tutto alimentava la
  Carestia e niente alimentava le Vie Interrotte, quindi lo spostamento riempiva
  una domanda e ne affamava un'altra. Ora e un anello con corde, verificato in
  modo che ogni Tensione alimenti e sia alimentata — sia fra le sei della
  biblioteca sia fra le quattro di Chronicle I.
- **`plan_c_opened_mine`** dimostra ora D-029: i Nahr tengono la Carestia sotto
  soglia in ogni round degli Atti 2 e 3 e ci **riescono**, ma il peso che tolgono
  di li si scarica altrove, e a scoppiare sono il Risveglio e le Vie Interrotte.

### Fixed

- Lo spostamento ha un proprio `source.id` (`ACT_INFLUENCE_DISPLACED`) pur
  restando attribuito a chi ha agito: senza, il cap per round su INFLUENCE —
  che si ricostruisce dal log — lo contava come una seconda azione.
- La sonda contava zero spinte: una lambda GDScript cattura una variabile locale
  **per valore**, quindi i contatori incrementati dentro il gestore del segnale
  non tornavano indietro. Ora sono in un Dictionary.

### La misura

Prima della regola, 40 Chronicle:

| | quattro Destiny | solo soppressione |
|---|---|---|
| Confluence per Chronicle | 3.60 | **0.17** |
| Chronicle senza nessuna | 0/40 | **33/40** |
| La Carestia e scoppiata | 35/40 | **0/40** |
| Il Risveglio | 38/40 | **0/40** |
| Le Vie Interrotte | 21/40 | **0/40** |

1400 spinte in giu contro 452 del mondo. Tre a uno.

Dopo:

| | prima | dopo |
|---|---|---|
| soppressori: Chronicle silenziose | 33/40 | **1/40** |
| soppressori: Confluence per Chronicle | 0.17 | **2.73** |
| tavolo normale | 3.60 | 4.58 |

La soppressione **compra** ancora qualcosa (2.73 contro 4.58): tenere giu una
domanda resta una mossa vera con un effetto vero. Non puo piu comprare il
silenzio.

### Effetto non previsto

Il bilanciamento e migliorato da solo: **75% delle partite nella banda 4-5**
contro il 42%, e niente sotto 2 o sopra 7. Chiude anche O-5.

---

## [0.0.4] — Le decisioni prese

Tre scelte dell'autore, implementate e misurate: la banda del §7, il leader che
scappa, e il modello di campagna.

### Changed

- **Banda 4-5 invece di 3-4** (D-026). Il numero del §7 era scritto per due
  Tensioni; una Chronicle ne porta quattro e la mediana misurata e 4. Deviazione
  dichiarata, non taratura silenziosa: `test_balance.gd` e la sonda portano
  entrambi la banda nuova e citano l'entry.

### Added

- **`chronicle.control_rules`** (D-027) — tenere non e gratis, e la risposta e
  dell'autore: non una penalita a chi sta vincendo, ma una pressione che nasce
  dalla situazione. Un impero cade per la propria dimensione.
  - `max_stable_control`: ogni Regione tenuta oltre il limite alza la Tensione
    **del dominio di quella Regione**, una volta per round. Al tavolo si legge
    come "tieni anche la strada? allora la domanda sulla strada e tua".
  - `lapse_without_presence`: a inizio Chronicle una Regione tenuta senza
    nessuno dentro torna a nessuno. Non si governa dove non si e.
- **Contenuto di biblioteca** (D-028) — l'autore ha scelto il modello **B**:
  niente Chronicle pre-scritte, si assemblano.
  - `confluence_template.applies_to_domain` — un Consiglio puo servire un intero
    dominio invece di una sola Tensione. E il risparmio piu grosso del progetto:
    i Consigli erano circa un terzo del costo di scrittura di una Chronicle, ed
    erano la parte da riscrivere ogni volta. `CNF_ANY_SURVIVAL` e il primo,
    scritto interamente a slot.
  - `chronicle.tension_pool` — una Chronicle **pesca** le proprie Tensioni invece
    di elencarle. Il sorteggio usa lo stesso RNG seeded dei mazzi: stesso seed,
    stesso anno. `CHR_02` e la prima in forma biblioteca e pesca 4 domande su 6.
  - `TEN_PLAGUE` e `TEN_THIRST`: le prime Tensioni **senza un Consiglio proprio**,
    che ne ricevono uno completo gratis.
  - Tre Conseguenze scritte solo a slot (`CNS_RATIONED`, `CNS_ABANDONED`,
    `CNS_SHARED_BURDEN`): il modello per generalizzare le altre 26.
- **`tests/unit/test_library_content.gd`** — 6 test sul meccanismo nuovo.

### Fixed

- **`ADJUST_TENSION` / `SET_TENSION_VISIBILITY` su una Tensione non in gioco**
  ora sono un no-op invece di un fallimento: il contenuto di biblioteca nomina
  domande che una data Chronicle puo non aver pescato. Un id che **non e** una
  Tensione resta un errore — la distinzione e quello che tiene un refuso rumoroso.
- **`$tension` nelle condizioni `tension_limit`** e **`$region_focus` nel blocco
  Scar** ora si risolvono: un Consiglio di dominio non sa quale domanda serve
  finche non si apre.
- **La policy** non presume piu che il bersaglio di un `SET_CONTROL` sia una
  Regione nominata: puo essere uno slot che si risolve solo all'apertura.

### La misura

Il leader che scappa, dieci Chronicle ereditate, stessi seed:

```
prima   Re - Vae Re  Re  Re     (dalla quinta in poi, immobile)
dopo    Re - Vae Re  Pop -  ->  Re - Vae - - -  ->  Re - Vae Re - -
```

Il controllo si espande e si ritira invece di congelarsi. Truth 13 → 16, frasi
distinte 12 → 15, Scar per Chronicle 0.45 → 0.75.

E la Chronicle di biblioteca gira per dieci anni pescando ogni volta una mano
diversa di domande, senza un solo errore e senza che nessuno l'abbia scritta.

### Segnalato, non corretto

- **O-6** resta aperta per meta: la banda e decisa (D-026), ma Failure e Success
  with Cost restano assottigliate (9 e 5 contro 18 e 15).
- **O-8**: sei Conseguenze su 29 non scattano mai.
- Le 26 Conseguenze piu vecchie nominano ancora una Regione precisa: sono
  contenuto di Chronicle, non di biblioteca. Generalizzarle e il prossimo pezzo
  di B, ed e lavoro di scrittura, non di motore.

---

## [0.0.3] — Un mondo che si puo muovere

Misura prima, contenuto dopo. La domanda era: dopo dieci Chronicle, quanto e
cambiato il mondo? Con il contenuto della 0.0.2 la risposta era **quasi niente**.

### Added

- **`cli/run_world_probe.gd`** — due misure. `--runs` gioca N Chronicle
  indipendenti e conta quante configurazioni finali *distinte* escono: e il
  soffitto della varieta dentro una partita. `--campaign` ne gioca K di seguito,
  ognuna che eredita la precedente, e dice quanto il mondo si e spostato da dove
  era partito.
- **`GameSession.inherit_from()`** — il minimo di propagazione che una misura
  richiede: controllo, tag persistenti, relazioni, Scar, Echo e Truth passano
  alla Chronicle successiva; mano, mazzi, presenza, Tensioni e Claim si
  ridistribuiscono. L'eredita passa dall'applier come Effect, quindi ha lo stesso
  log e la stessa inversa di tutto il resto. Il motore di propagazione vero
  resta la 0.3.
- **Due Tensioni nuove** — `TEN_SUCCESSION` (TERRITORY, aperta) e `TEN_ROADS`
  (RESOURCE, velata), con i loro due Consigli, quattro domande e sette proposte.
- **14 Consequence nuove** (12 → 26) di tre forme che non esistevano: che
  **guariscono** (tolgono i tag condition, senza le quali il mondo poteva solo
  saturare), che **cambiano il controllo**, che **lasciano una Scar** — il
  meccanismo era implementato dalla 0.0 e non lo usava nessuno.
- **8 carte Echo nuove** (8 → 16). Sono l'unico contenuto che si applica senza
  che nessuno lo scelga, quindi muovono il mondo a prescindere dal tavolo.
- **`$region_focus` nel contesto degli Effect** — una Consequence puo dire "la
  Regione di cui stiamo discutendo" invece di nominarne una per sempre.
- **Controllo statico dei binding** in `validate_data.py`: un `$variabile` che il
  motore non sa risolvere compila a niente e lo dice solo in un push_error. E
  esattamente quello che `CNS_HARVEST_RETURNS` faceva su una carta Echo.
- **`test_every_echo_card_hook_compiles_to_something`** — la stessa guardia a
  runtime.

### Changed

- **`scripted_confluence.tension_id`** — un piano indirizza una Confluence per
  Tensione invece che per indice di corsa (D-025). Con l'indice, aggiungere
  contenuto faceva atterrare la direttiva del grano sul consiglio delle strade.
- **Baseline spostate e dichiarate** (§25): il sacchetto del Drift e 2/3/2/2 su
  quattro Tensioni invece di 5/4, e la soglia di `TEN_AWAKENING` scende da 7 a 6.

### Fixed

- **L'inversa di `REMOVE_REGION_TAG` rimetteva il tag in fondo alla lista** invece
  che al suo posto, quindi l'undo non tornava byte per byte. Stessa classe del bug
  sull'ordine della mano della 0.0. Trovato perche un tag nuovo nei dati ha
  spostato `capital` dall'ultima posizione.
- **Le carte Echo non sapevano risolvere `$proponent` e `$region_focus`**: gli
  hook di due carte nuove applicavano zero Effect in silenzio.

### La misura, prima e dopo

Su 40 Chronicle indipendenti, stessi seed:

| | 2 Tensioni, 12 Consequence | 4 Tensioni, 26 Consequence |
|---|---|---|
| mappe di controllo distinte | 2 | **6** |
| set di tag distinti | 14 | **26** |
| stato finale distinto | 14 | **28** |
| Scar per Chronicle | 0.00 | **0.45** |
| relazioni distinte | 2 | 2 |

E dieci Chronicle di seguito, che era la domanda:

| | prima | dopo |
|---|---|---|
| il controllo e cambiato | **mai** | si, due volte |
| tag sulla mappa | 3 → 5 | 1 → **11** |
| Scar accumulate | 0 | **9** |
| coppie Tensione/Regione a fuoco | 3 | **6** |
| frasi distinte lette | 17 | 12 |

L'ultima riga e la piu onesta: **le frasi distinte sono calate.** Il mondo si
muove molto di piu, ma con quattro Tensioni ogni Confluence e meno contesa,
quindi ne restano meno che meritino un Echo. La varieta e passata dallo stato,
non dal testo.

### Segnalato, non corretto

- **O-6**: il bilanciamento di D-021/D-023 e regredito — 42% nella banda del §7
  contro il 70%, FAILURE da 18 a 9. La banda 3-4 era scritta per il contenuto
  ridotto del §18.2; se descriva ancora una Chronicle a 4 Tensioni e una domanda
  di design, non una da tarare in silenzio.
- **O-7**: la campagna ha un leader che scappa. Aldric parte con una Regione e
  alla quinta Chronicle ne ha cinque, e non ne perde piu nessuna. L'eredita
  compone il vantaggio e niente lo inverte.
- **O-8**: sei Consequence su 26 non scattano mai. Contenuto irraggiungibile e
  contenuto che non esiste.

---

## [0.0.2] — Le proposte cominciano a costare qualcosa

Chiude l'osservazione O-4 della 0.0.1 e la O-2. Nessuna UI: la 0.1 resta non
iniziata.

### Added

- **Quattro Consequence nuove** — `CNS_VALLEY_CLEARED`,
  `CNS_CROWN_DISPOSSESSED`, `CNS_MINE_TAKEN`, `CNS_STUDY_UNDER_GUARD`. Portano il
  set da 8 a 12, sopra le 8 del §18.2: deviazione deliberata, registrata in
  [D-022](docs/DECISIONS.md) come chiede il §25. Ognuna toglie qualcosa di
  preciso a un posto preciso al tavolo, che e la ragione per cui esistono.
- **`REMOVE_PRESENCE` con `optional`** — una Consequence puo dire "sgomberali
  dalla Valle" senza sapere se qualcuno e accampato li: marcata opzionale, quello
  e un no-op e non un Effect fallito.
- **`--tension-cap` nella sonda** — sweep del secondo limite senza toccare i dati.

### Changed

- **Limite di 1 INFLUENCE per Tensione per round**
  (`chronicle.influence_rules.max_per_tension_per_round`). Reversibile come il
  primo: si toglie dalla Chronicle e sparisce. Vedi
  [D-023](docs/DECISIONS.md).
- **La policy vede il danno** — valuta `ADD_PRESENCE` / `REMOVE_PRESENCE` contro
  le proprie condizioni `region_presence` e `SET_CONTROL` contro `control_count`,
  e risponde con `OPPOSE` a una proposta che le costa 2 o piu, invece di una
  clausola di cortesia.
- **`plan_b_broken_council`** — i Nahr mettono il terzo token sulla Strada dei
  Mercanti, quindi nel dominio SURVIVAL sono loro la parte piu presente e la
  domanda sul grano e loro da porre. Il piano ora produce la sconfitta memorabile
  che il suo nome promette: S1 O6 M−5, fronte contrario a 6, quindi Echo lo
  stesso (§12.4).
- **`tests/smoke/test_balance.gd`** — la guardia ora giudica l'aggregato
  (mediana 3-4, al massimo il 10% delle partite fuori da 2-6, almeno 1 Echo ogni
  2 Chronicle) invece della singola partita. Il §7 descrive cosa deve mostrare un
  playtest, non vieta una Chronicle silenziosa. Detto per intero: la guardia e
  stata rilassata dopo che ha fallito — la motivazione e in
  [D-023](docs/DECISIONS.md), con la sequenza dichiarata.
- **`ScriptedDecider`** segnala un id di Asset inesistente in un piano invece di
  ignorarlo in silenzio. Un Asset assente dalla mano resta una degradazione
  silenziosa; un id che non e un Asset e un refuso.

### La misura, prima e dopo

Su 40 Chronicle, seed 1000-1039:

| | mediana | in banda 3-4 | sotto il minimo | FAILURE | SwC | SUCCESS | DECISIVE |
|---|---|---|---|---|---|---|---|
| 0.0.1 (8 Consequence, 1 cap) | 4 | 82% | 0/40 | **0** | 1 | 79 | 75 |
| 12 Consequence, 1 cap | 2 | 20% | 8/40 | 2 | 4 | 47 | 36 |
| **12 Consequence, 2 cap** | **3** | **70%** | 2/40 | **18** | **15** | 57 | 27 |

Tutte e quattro le bande di esito del §12.3 esistono ora nel gioco aperto. Il
resolver non e stato toccato: la matematica del §A5 e la stessa della 0.0.

### Segnalato, non corretto

- **O-5**: 2 Chronicle su 40 producono una sola Confluence, sotto il minimo che
  il §7 nomina. Con il solo cap per Entita erano 0. E il prezzo pagato per le due
  bande di esito mancanti, e il §7 dice di riportare invece di correggere in
  silenzio: questo e il riporto. Da rimisurare con le 4 Tensioni del §19.4 prima
  di aggiungere qualsiasi altra regola.

---

## [0.0.1] — Passo di bilanciamento

Chiude l'osservazione D-018 della 0.0. Nessuna UI: la 0.1 resta non iniziata.

### Added

- **`cli/policy_decider.gd`** — un giocatore che gioca davvero per il proprio
  Destiny. Deriva gli obiettivi dai dati: il livello piu basso non ancora
  raggiunto, le Tensioni che quel livello vuole basse e — decisivo — quelle che
  ha bisogno di portare a maturazione, perche l'unica cosa che puo soddisfare una
  sua condizione e una Consequence che sta dietro a una Confluence. Nessuna IA
  scritta a mano per singola Entita.
- **`cli/run_balance_probe.gd`** — gioca N Chronicle su N seed e riporta la
  distribuzione: Confluence per partita, esiti, Echo, livelli Destiny, valore
  finale delle Tensioni. Con `--influence-cap` e `--presence-directions` fa lo
  sweep di un knob senza toccare i dati.
- **`ActionResolver.check()` / `can_execute()`** — perche un'azione verrebbe
  rifiutata, senza toccare nulla. `execute()` la chiama per prima, quindi ogni
  precondizione e scritta una volta sola. La Action Dialog della 0.1 la usera per
  disabilitare i bersagli illegali (§19.3).
- **`tests/smoke/test_balance.gd`** — 24 Chronicle giocate dalla policy: fallisce
  se la mediana esce dalla banda 3-4 del §7, se una singola partita esce da 2-6,
  se i Destiny smettono di essere contesi o se il cap non regge.

### Changed

- **Limite di 1 INFLUENCE per Entita per round** su tutte le Tensioni
  (`chronicle.influence_rules.max_per_entity_per_round`). Data-driven e
  reversibile: togliendo `influence_rules` torna il comportamento v0.2.
  Implementato anche `presence_directions`, che in Chronicle I resta su entrambe
  le direzioni.

### La misura, prima e dopo

| | mediana Confluence | in banda 3-4 (§7) | fuori da 2-6 | INFLUENCE per partita |
|---|---|---|---|---|
| policy ingenua, regole v0.2 | 0 | 0/30 | 30/30 | 7.5 |
| policy corretta, regole v0.2 | 3 | 24/40 | 10/40 | 45.7 |
| **policy corretta, cap 1** | **4** | **33/40** | **0/40** | **20.1** |

La riga di mezzo e la piu importante: gran parte del problema apparente era lo
strumento di misura, non le regole. Aldric ha bisogno di `control_count >= 2`, e
il controllo cambia mano solo dentro una Confluence — un Aldric competente spinge
la Carestia *verso l'alto*. Insegnarlo alla policy ha portato la mediana da 0 a 3
senza cambiare una sola regola. Il cap ha fatto il resto, e ha riportato INFLUENCE
dal 63% al 28% di tutte le azioni giocate.

Le alternative sono state misurate e scartate: la via per presenza limitata al
solo +1 peggiora i numeri da sola (mediana 2), e insieme al cap da un risultato
peggiore del cap da solo. Dettaglio in [D-021](docs/DECISIONS.md).

### Segnalato, non corretto

- **O-4**: su 154 Confluence misurate, 0 Failure e 1 Success with Cost. Due delle
  quattro bande di esito del §12.3 non compaiono nel gioco aperto, anche se i
  piani scriptati dimostrano che sono raggiungibili. La causa sembra il contenuto
  ridotto della 0.0, non la matematica: troppo poche Consequence toccano un tag a
  cui i Destiny altrui tengono, quindi quasi nessuno ha motivo di opporsi. Da
  rimisurare con le 20 Consequence e le 4 Tensioni del §19.4.
  *(Chiusa nella 0.0.2: la lettura era giusta, ed e bastato il contenuto.)*

---

## [0.0.0] — Milestone 0.0, Core Headless

Prima release. Motore di gioco completo e giocabile senza UI: modello dati, Effect
system, Tensioni, azioni ordinarie, Confluence, Destiny, save/load, tutto
pilotabile da test e da un harness a riga di comando.

Tutti i criteri di accettazione §18.3 sono verificati.

### Added

**Fonte unica degli schemi (§17)**
- 14 JSON Schema 2020-12 in `/schema`, inclusi `chronicle` e `sim_plan` non
  previsti dal §4 (D-015)
- `tools/validate_data.py`: validazione JSON Schema più una seconda passata di
  integrità referenziale (adiacenze reciproche, somma della drift track, pool
  Echo, template per ogni Tensione, id duplicati)
- `tools/gen_gd_schema.py`: genera `godot/scripts/core/schema_defs.gd`, con
  modalità `--check` per il drift check in CI
- `tools/build_manifest.py`: genera `docs/ASSET_MANIFEST.md` dai dati

**Core (§5, §6)**
- `EffectApplier`: unico punto di mutazione del WorldState, con `effect_log`,
  inversi esatti, `undo_last`/`undo_after` e rifiuto di superare un Effect
  irreversibile
- Enum EffectType chiuso a 22 voci, con `REMOVE_SCAR` aggiunto e documentato
  (D-003) e `inverse_type` sull'Effect (D-002)
- `RngService`: RNG seeded centralizzato, Fisher-Yates proprio, posizione
  persistita come contatore di estrazioni (D-004)
- `SaveSerializer` / `SaveManager`: salvataggio versionato a chiavi ordinate,
  snapshot automatico prima di ogni Confluence, normalizzazione degli interi al
  caricamento

**Regole (§7–§16)**
- `ChronicleController`: 3 Atti × 3 round × 2 AO, Drift, check di soglia, carta
  Echo di Atto, chiusura della Chronicle
- `ActionResolver`: i sei template ACQUIRE / MOVE / INFLUENCE / FORGE / SCHEME /
  CLAIM, con CLAIM in modalità CREATE e FORCE (D-011)
- `TensionSystem`: drift track mescolata col seed, presagi presi dai dati e mai
  ripetuti, ordinamento delle soglie
- `ConfluenceController`: sequenza A–K completa, con ordine di risoluzione
  interno fissato e documentato (D-014)
- `confluence_resolution.gd`: Strategy `baseline_v0`, M = S − O + W, sostituibile
  senza toccare dati o UI
- `ConsequenceCompiler`: Consequence e hook delle carte Echo compilati in Effect,
  con sostituzione di `$proponent` / `$tension` / `$actor`
- `EchoRecorder`, `DestinyEvaluator` (livelli cumulativi, D-017),
  `ConditionEvaluator` con tutte le condizioni del §14

**Contenuto 0.0 (§18.2)**
- 12 Asset, 6 Regioni, 2 Tensioni, 2 template di Confluence, 8 carte Echo,
  8 Conseguenze, 4 Entità con Destiny a 2 condizioni per livello, drift track di
  9 voci

**Harness e test (§18.1, §18.3)**
- `cli/run_chronicle_sim.gd` + `cli/scripted_decider.gd`: gioca una Chronicle
  completa headless, verifica il blocco `expected` del piano ed esporta il save
- Tre piani di simulazione con esiti diversi (Decisive · Failure+2×SwC ·
  Failure+Success) e Destiny finali diversi
- 64 test in 8 suite, 425 asserzioni, con un runner minimale senza addon (D-008)
- `tools/run_sims.sh`, workflow GitHub Actions

### Fixed

Bug trovati **dai test e dai piani di simulazione** mentre venivano scritti — la
ragione per cui la 0.0 è headless:

- `RngService` non era seeded: GDScript risolve una chiamata non qualificata a un
  built-in di `@GlobalScope` prima di un metodo della classe, quindi un metodo
  chiamato `randi_range` non veniva mai eseguito e ogni estrazione "seeded"
  arrivava dall'RNG globale. Rinominato in `range_int` (D-019)
- l'inverso di `REMOVE_ASSET` e di `TRANSFER_ASSET` rimetteva la carta in fondo
  alla mano invece che alla sua posizione: il round-trip riordinava la mano
- `ACQUIRE` con pesca doppia non scartava nulla quando le due carte pescate erano
  copie dello stesso Asset (confronto per valore invece che per indice)
- il runner dei test si bloccava per sempre quando una suite non compilava: un
  errore dentro `_initialize` non raggiunge mai `quit()`

### Changed rispetto alla specifica

Tutto elencato e motivato in [docs/DECISIONS.md](docs/DECISIONS.md). I punti che
toccano le regole:

- `deck_copies` aggiunto agli Asset: due carte distinte per famiglia non fanno un
  mazzo per quattro giocatori (D-010)
- le Proposition hanno una eligibility: senza, il Popolo Nahr poteva proporre che
  il trono requisisse il grano e Aldric opporsi al proprio granaio (D-016)
- l'Echo Check considera "Success" anche il Success with Cost (D-012)
- disposizione degli Asset su Failure per chi non è proponente né opposer (D-013)

### Note di bilanciamento — segnalate, non corrette

- **D-018**: INFLUENCE per presenza è gratuito e ripetibile; quattro giocatori con
  otto AO per round possono annullare il Drift +1. Misurato, non ipotizzato: la
  prima versione della policy di riempimento dell'harness produceva Chronicle con
  **zero** Confluence. È la prima voce del bilanciamento 0.2.
- **O-1**: i tre piani producono 1, 3 e 2 Confluence contro le 3–4 attese dal §7.
  Nessun numero è stato cambiato, come richiesto dallo stesso §7.

### Non implementato (fuori scope §0)

LLM locale, computer vision, QR tracking, multiplayer online, networking,
generazione procedurale della Chronicle II. Nessuna UI oltre la scena di boot: è
la Milestone 0.1.
