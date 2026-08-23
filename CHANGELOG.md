# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).
Il progetto segue le milestone della specifica esecutiva v0.2.

---

## 0.1.185 — Le sedici coppie che non si conoscevano (D-216)

- Il debito dichiarato da D-213, pagato: su 28 coppie di case ne erano scritte
  **12**, tutte dentro la vecchia linea. Aldric non sapeva chi fosse la Gilda del
  Sale, Lyra non sapeva chi fosse l'Ordine del Vetro.
- **«Piatto» non è un aggettivo: è un numero, ed era il 14%.** Nuova sonda
  `run_table_probe`: per ogni tavolo che il seme apparecchia conta quante delle
  sei coppie sedute sono calde.

| 200 semi | prima | dopo |
|---|---|---|
| coppie scritte | 12 su 28 | **28 su 28** |
| **tavoli piatti** (nessuno si conosce) | **14,0%** | **0,0%** |
| coppie calde per tavolo | 1,22 su 6 | **2,94 su 6** |
| il tavolo più comune | 1 coppia calda | **3 coppie calde** |

- **Otto calde e otto neutrali**, e il criterio non era «quante ne servono» ma la
  densità che i due tavoli d'autore avevano già (2 su 6 nel Grano, 4 su 6 nel
  Sale). La media pescata torna a **2,94 su 6**: la stessa temperatura.
- **Nessuna delle otto è stata scelta per far tornare i conti**: erano già
  scritte nelle descrizioni. L'Ordine del Vetro «custodisce quello che fu
  misurato» e Lyra **è quella che l'ha misurato**; la Cenere campa di quello che
  l'antica miniera ha lasciato e Vaerax **dorme sotto quelle montagne**.
- **Un'asimmetria che c'era già**: la Cenere si diceva alleata al Sale, il Sale
  alleata alla Cenere *per patto*. I tag si sommano, quindi non faceva danno —
  ma sul **livello** sarebbe andata diversamente: nel mondo la relazione è una
  coppia sola, e chi scrive per ultimo (in ordine alfabetico di id) decide. Una
  delle due frasi sparisce senza dirlo.
- **Una guardia** che chiude tre porte: livelli o tag discordi fra le due
  scritture, una relazione con una casa inesistente, e una coppia di case
  pescabili che non è scritta da nessuna parte. **E una prova** che guarda il
  tavolo invece del dato — cinquanta tavoli pescati, nessuno apre piatto.
- **Il playtest quasi non si muove** (Consigli 4,49 → 4,49; Verità 333 → 335;
  **0/8**), ed è atteso: le relazioni pesano al Consiglio e nelle clausole, non
  nella scelta delle azioni. Il cancello dice che non ho rotto niente; la sonda
  nuova dice che il tavolo ha una storia. Sono due cose diverse.

---

## 0.1.184 — Nessuna famiglia senza un'azione (D-215)

- Il committente ha chiesto un numero mai misurato: «*le azioni sono equamente
  distribuite nelle carte?*». Le **famiglie** erano pari (22 copie ciascuna,
  esatte). Le **azioni** no, e l'incrocio aveva **nove zeri**: AUTORITÀ non
  poteva muovere né tramare, RICCHEZZA non poteva rivendicare, FORZA non poteva
  forgiare.
- **Uno zero lì non è uno squilibrio: è una porta chiusa senza dirlo.** Le
  azioni passano sulle carte e la mappa decide che carte peschi, quindi la mappa
  decide che *cose puoi fare*. Lyra, che vive di SAPERE, aveva **4 copie di
  MUOVERE su 132** — ed è la causa vera del 30% di seggi che D-208 aveva trovato
  bloccati da «nessuna carta MUOVERE in mano».
- **Dieci carte cambiano azione, nessuna cambia mestiere**: il criterio era che
  il nuovo verbo fosse già dentro il titolo. Il Censimento trama (contare la
  gente è guardare le carte degli altri), il Pedaggio rivendica (una corda su una
  strada), il Diritto di Ospitalità muove (essere ospiti è essere là), i
  Mercenari forgiano (la lealtà pagata è pur sempre un legame).
- **Nessuno zero**, e lo scarto fra l'azione più comune e la più rara scende da
  **1,85× a 1,38×**. Le identità restano — SAPERE trama 11 su 22, LEGAMI forgia,
  FORZA muove — ma sono accenti, non muri.
- **Una guardia** in `validate_data.py`: nessuna famiglia a zero su un'azione, e
  la più rara del mazzo non sotto metà della più frequente. Provata rimettendo
  il Magistrato a FORGE.
- **I numeri**: Verità scritte **317 → 333** (misto), MUOVERE giocate l'anno
  **4,64 → 3,79** e bloccati da «nessuna MUOVERE in mano» **30,5% → 38,0%** —
  voluto: MUOVERE era il 23,5% del mazzo per una sola azione su cinque, e adesso
  il costo lo pagano tutti allo stesso modo invece del 100% per una casa e lo 0%
  per un'altra. Playtest **0/8**.
- **Il piano D si è ribasato** (l'unico): è la storia scritta nell'economia di
  adesso, quindi non poteva dichiarare un mazzo di prima. Gesto d'apertura e
  morale intatti; cambia il finale. La prima scelta era sbagliata — avevo
  spostato proprio la carta di cui quella storia parla, e il piano è andato rosso
  e aveva ragione.
- **Cinque sonde erano rotte e nessuno lo sapeva**: non stanno nel cancello, e un
  cambio di firma in `GameSession` (D-213) le aveva lasciate con un
  identificatore fuori posto mentre la CI restava verde. Una sonda che non parte
  è **una misura che non si può più fare**. Adesso `test_probes_compile` le
  carica tutte.

---

## 0.1.183 — Il Consiglio chiude l'Atto, e il cancello si spegne (D-214)

- Decisione del committente, già presa una volta e da me rimandata **senza
  dirlo**: «*il concilio c'è alla fine di ogni atto, non servono due gettoni per
  farlo partire*». Ha dovuto chiedere due volte.
- **`confluence_rules.at_end_of_act`**: a fine di ogni Atto si tiene un
  Consiglio sulla domanda col **mucchio più alto** — cioè su ciò che i gettoni
  coperti costruiscono per tutto l'Atto (D-210). Il round non ne apre più
  nessuno da solo, né per soglia né per gettoni: **`table_gate` è tolto dai dati
  spediti** (non dal motore, che resta a disposizione di una Chronicle che lo
  dichiari). Resta RIVENDICARE per portare al tavolo una seconda domanda.
- **I gettoni smettono di dire *se* si parla e dicono soltanto *di cosa*.**
- **I numeri** (100 semi, seme 7000): Consigli l'anno **3,09 → 4,49** (misto) e
  **3,20 → 4,64** (uniforme), Verità scritte **254 → 317** e **229 → 319**, e il
  minimo su cento anni **1 → 3**. Su **300 Atti misurati, 0 chiusi senza
  Consiglio**; anche un tavolo che passa ogni round ne prende tre. Playtest
  **0/8**.
- **Il difetto che la regola ha scoperto**: il codice aveva due domande diverse
  trattate da sinonimi. `has_fresh_question` chiede «resta un quesito mai
  posto?», ma il template apre solo un quesito **idoneo**. A soglia la
  differenza non si vedeva; a fine Atto sì — tre anni su cento chiudevano sotto
  la promessa e uno rifiutava otto aperture di fila. Ora c'è `can_open()`, e la
  chiusura scende al mucchio successivo invece di perdere il Consiglio.
- **Il pavimento di fine anno (D-047) non scatta più** sui dati spediti: con un
  Consiglio per Atto la garanzia è strutturale. Resta nel motore per le
  Chronicle che non tengono il Consiglio di chiusura.
- **Dichiarato e non risolto**: 43 aperture su cento anni vengono ancora
  rifiutate, e sono tutte Consigli **forzati da RIVENDICARE** — il Claim non
  passa da `can_open`, quindi si può spendere un'azione per forzare un Consiglio
  che poi non si apre. Difetto vero e preesistente, portato alla luce da questa
  misura.

---

## 0.1.182 — Un setup solo: le case si pescano come le domande (D-213)

- Il committente: «*non voglio due ere, voglio un unico setup dove si pescano
  entità e obiettivi e anche le domande*». Il gioco aveva **quattro Chronicle in
  due linee chiuse**, ognuna con quattro case scritte a mano e sei domande sue.
- **Cosa c'era già**: gli obiettivi erano già un mazzo solo da 12 e le Regioni
  già condivise. Mancavano le **case** (fisse) e una **biblioteca unica** di
  domande (6+6 separate).
- **`entity_pool`** sulla Chronicle, stessa forma di `tension_pool`: 8 candidate,
  se ne siedono 4. La pesca sta in `GameSession.seats_for()`, statica e fuori da
  `setup`, così il tavolo si sa prima che il mondo esista e non consuma l'RNG
  della partita. Vuoto = assente, come ovunque.
- **La pietra segue la casa**: `starting_structures` si sdoppia — il paesaggio
  (bosco, sorgente, valico) resta sulla Chronicle, il presidio passa
  sull'Entità con `at` sulla presenza di partenza. Rifattorizzazione misurata da
  sola: **playtest byte-identico**.
- **La varietà, che è il motivo del cambio** (12 saghe da 6 anni, seme 812):
  aperture diverse **6 e 4 → 12 su 12**, distanza media fra saghe **0,88 e 0,83
  → 0,97**, frasi distinte **96 e 52 → 106**, vite viste al tavolo **6 → 13**.
  Su 200 semi escono **67 tavoli diversi su 70**, e le otto case si siedono fra
  il 45,0% e il 54,5%.
- **Tre difetti nascosti che il tavolo pescato ha scoperto**, tutti invisibili
  finché le case non cambiavano mai: l'eredità portava **relazioni**, **controlli
  di Regione** e **pietre** di case non più al tavolo (SET_RELATION senza record
  = Effetto senza inverso); e **due clausole di Consiglio nominavano Lyra per
  nome**, cadendo in un `push_error` dentro un log che nessuno legge. Ora c'è il
  segnaposto **`$conditioner`** — chi ha posto la condizione — che è anche più
  giusto a leggersi.
- **`requires_entity`** sulle Conseguenze: «Il Drago Abbattuto» spegne Vaerax e
  adesso lo dichiara, quindi si salta quando Vaerax non siede — **dicendolo nel
  verbale**, perché D-030 vale anche per ciò che non succede.
- **Due guardie nuove**: con le case pescate nessun Effetto scritto a mano può
  puntare a un `ENT_`; e la prova del traguardo verifica che ogni anno peschi
  **dalla stessa biblioteca** invece di contare due biblioteche separate.
- **I numeri peggiorati, che si scrivono**: Consigli l'anno **3,53 → 3,09**
  (misto) e **3,64 → 3,20** (uniforme), Verità scritte **295 → 254**. Con dodici
  domande e quattro pescate il calore si sparpaglia. Playtest **0/8** su tutti e
  due i tavoli.
- **Non fatto, e dichiarato**: **16 relazioni incrociate su 28 non esistono**
  (partono a NEUTRAL) — un tavolo misto è più piatto di uno storico, e spiega
  parte del Consiglio perduto. Le Chronicle sono ancora quattro, ma adesso sono
  *anni* e non *ere*. Il Consiglio a fine Atto e il cancello a due gettoni sono
  la prossima voce.

---

## 0.1.181 — Lyra sulla Strada dei Mercanti (D-212)

- Il committente ha deciso l'altra metà di ISSUES 48: **«Lyra sulla Strada dei
  Mercanti»**. Lyra apre con Miniere Antiche + Strada invece di Miniere Antiche
  + Eredan.
- **Nel Grano non c'è più una Regione vuota**: la Strada passa da 0,00 → 1,20 a
  **1,00 → 2,07** pedine, ed è la seconda più affollata a fine anno. La Regione
  più magra diventa Montagne Rosse a **1,78**.
- **Lyra smette di essere la quarta casa**: NONE **16 → 8** (uniforme) e **17 →
  8** (misto), Vittorie **10 → 28** e **12 → 22**, anni chiusi con zero
  obiettivi **35 → 20**.
- **I numeri peggiorati, che si scrivono**: i TRIONFI di tutto il tavolo calano
  **10 → 8** (uniforme) e **5 → 2** (misto), e Lyra resta a **0**; Re Aldric
  paga il conto (NONE 7 → 10, Vittorie 23 → 14, uniforme); i gettoni si bloccano
  prima, **44,0% → 51,0%**. Playtest **0/8** su tutti e due i tavoli.
- **Le quattro storie scritte a mano dichiarano la mappa in cui sono nate.**
  Nuova chiave `starting_presence` sulla Chronicle (vuota = assente, come
  ovunque), scrivibile da `chronicle_overrides` come già l'economia (D-189):
  ribasare quattro `expected` non le avrebbe aggiornate, le avrebbe timbrate.
  Vale solo per la prima vita del seggio — dopo una successione comanda
  l'incarnazione (D-133).
- **Una guardia nuova** in `validate_data.py`: una mappa dichiarata che coincide
  col dato spedito non dichiara più niente e va rossa. Provata — rimettendo Lyra
  a Eredan morde su tutti e quattro i piani.
- **Quello che non è stato fatto**: «Nahr sulle Terre Nahr» nel Grano è già così.
  La Regione vuota è **Terre Nahr nella linea del Sale**, dove i Nahr non
  esistono — chi ci va è contenuto, e torna al committente col prezzo misurato.

---

## 0.1.180 — Due pedine di riserva invece di una (D-211)

- Il committente aveva deciso il risultato: «non ci può essere una regione senza
  nessuno». D-208 aveva prezzato tre rimedi; provati **separatamente**, costano
  cose molto diverse.
- **Il tetto a 4** rompe due prove che descrivevano il setup, e **nessuna
  storia**. **Spostare la casa di Lyra** rompe **tutte e quattro** le storie
  scritte a mano. Spedito il primo; il secondo è *dove vive una casa*, cioè
  contenuto, e torna al committente col prezzo scritto.
- **I numeri**: gettoni di riserva per casa **1 → 2**, MUOVERE l'anno **3,02 →
  4,70** (Grano) e **2,88 → 4,20** (Sale), bloccati dal gettone **71% → 41%** e
  **74% → 48%**, Consigli l'anno **3,40 → 3,57** e **3,57 → 3,86**, playtest
  **0/8**.
- **Metà voce soddisfatta, e si dice quale.** Nel Grano nessuna Regione finisce
  sotto **1,20** pedine e la Strada non è più deserta; nel Sale le Terre Nahr
  restano a **0,88** — lì non comincia nessuno, e il tetto non fa cominciare
  nessuno.
- **E spostare continua a non succedere**: 0,03 l'anno nel Grano, 0,00 nel Sale.
  Più pedine da posare non sono una mappa che si disfa.
- **Le quattro storie**: B e D passano invariate; **A si ribasa** (l'ultima
  domanda si chiude decisiva, e con due gettoni di riserva è il finale che la sua
  descrizione già prometteva); **C dichiara il tetto 3**, perché il suo finale
  *è* la storia — «una domanda che sembrava chiusa si riapre e resta aperta» — e
  col quarto gettone quelle Vie passano invece di cadere.
- **Due difetti per strada.** L'inverso di `REMOVE_PRESENCE` rimetteva la pedina
  **in fondo** invece che dove stava: il round trip promette *identico* e dava
  *equivalente*, ed era invisibile perché la Regione di prova era l'ultima della
  lista. E tre prove descrivevano il setup invece dell'intenzione — una di
  queste, col tetto a 4, posava **due** pedine sulla montagna dove la clausola
  ne chiede una, e l'avviso taceva **per la ragione giusta**.
- Quel test ha anche fatto emergere una regola che non era scritta da nessuna
  parte: la pedina che parte è la **prima in ordine alfabetico** fra le Regioni
  tenute. Ora il test lo dice e lo verifica.

## 0.1.179 — I mucchi coperti, e il pavimento che non sapeva del cancello (D-210)

- **ISSUES 49 è chiusa.** L'ultima fase: «i segnalini coperti danno un valore a
  una tensione, e quando parte la Confluence si girano».
- **Coprire vuol dire due cose, non una.** Un mucchio in cui ogni gettone vale 1
  si conta a occhio: coprirlo non nasconderebbe niente. Quindi il gettone pesca
  un **valore** dal sacchetto — `covered: [0, 1, 1, 2]`, media **1,00**, il
  calore totale non cambia in attesa ma cambia la varianza — e il punteggio
  smette di essere pubblico. Lo zero è il **gettone bianco**: non muove niente
  ma è sceso, quindi conta per il cancello e si vede cadere.
- **Tre finestre, non una**: il verbale pubblico, la scheda del seggio e la
  pagina d'aiuto. Bastava lasciarne aperta una perché coprire fosse teatro — la
  lezione di §5ter presa in anticipo invece che dopo. Otto prove nuove, tre delle
  quali mordono se una finestra resta aperta.
- **Il criterio di chiusura della voce era impossibile, e l'ha detto la misura.**
  «Lo scarto fra i mucchi non cresce di atto in atto» era **già falso senza
  coprire**: 3,95 → 6,42. Coprire aggiunge **+0,28** su tre atti. Il criterio
  giusto è *non cresce più di quanto già cresceva*, ed è scritto così invece che
  dichiarato raggiunto.
- **E ha scoperto un difetto vecchio.** Il pavimento di fine anno portava una
  domanda **alla propria soglia** — ma col cancello del tavolo la soglia non apre
  più niente, e se quella domanda era già sopra soglia il pavimento **usciva
  zitto senza fare nulla**. Latente da D-203; la copertura ha alzato i valori
  quel tanto che bastava e un anno è sceso a **un Consiglio solo**. Adesso il
  pavimento fa cadere i gettoni che mancano, come Effetti reversibili: alzare il
  contatore e basta avrebbe aperto un Consiglio che il registro non sa spiegare,
  e un test ha rifiutato quella prima toppa.
- **Il gate**: Consigli l'anno 3,37 → **3,40** (uniforme) e 3,73 → **3,57**
  (misto), playtest **0/8** a tavolo misto e uniforme.

## 0.1.178 — La quarta casa non trionfa, in nessuna era (D-209) · ISSUES 51 e 46 rimisurate

- **ISSUES 51 chiusa, e l'aritmetica sbagliava strumento.** `run_question_ledger`
  conta per ogni domanda quante volte è pescata e in quanti di quegli anni apre
  almeno un Consiglio. **Nessuna delle dodici è muta**, e tutte superano il
  criterio della voce: la Febbre Bassa apre nel **57,5%** degli anni in cui esce,
  i Pozzi Bassi nel **26,3%**. Il test che le dava per irraggiungibili sommava
  valore + Deriva + Ripple, e da D-192 **la Deriva non è nemmeno in gioco**.
- **Ma la misura ha trovato di meglio: le due linee non hanno lo stesso clima.**
  Consigli l'anno **3,80 nel Grano contro 2,85 nel Sale**; tre domande sopra il
  90% nel Grano, **zero** nel Sale; e nel Sale le domande finiscono l'anno molto
  più lontane dalla soglia (il Debito a **−3,12**).
- **ISSUES 46 rimisurata: il vincitore scritto non è più il Sale.** Da **12 su
  12** a **1 su 12**. Il posto l'ha preso la **Cenere, 7 su 12**. E il confronto
  fra le linee dice che il difetto non è chi vince ma come si decide: cambi di
  testa **1,2 nel Sale contro 1,8 nel Grano**, ultimo cambio all'anno **3,6
  contro 4,4**. La linea più fredda decide prima.
- **E il difetto di Lyra non è di Lyra: è una regola dell'apertura.** In CHR_03
  `starting_structures` posa uno `STR_KEEP` a tre case su quattro e lascia
  scoperto **l'Ordine del Vetro** — che chiude con **43 NONE e 1 Trionfo su 120
  anni**, come Lyra con 44 e 0.

  | linea | casa senza presidio | NONE su 120 | TRIONFI |
  |---|---|---|---|
  | il Grano | **Lyra** | 44 | **0** |
  | il Sale | **l'Ordine del Vetro** | 43 | 1 |

  E in tutte e due, fra le clausole del Minimo più mancate c'è letteralmente
  **«Almeno un presidio suo»** — Lyra 18 volte, il Vetro 17. **La casa che apre
  senza presidio è la casa che non vince mai**, e qualunque cosa si decida per
  Lyra va decisa anche per il Vetro.
- Nessuna regola accesa: sono decisioni di contenuto, e il numero è scritto prima
  perché si possa scegliere guardandolo.

## 0.1.177 — Tre case aprono l'anno con due obiettivi già in tasca (D-209)

- ISSUES 52 chiedeva **quali** obiettivi Lyra manca. `run_objective_ledger`
  conta per ogni coppia **seggio × obiettivo** quante volte è pescato e quante
  preso — il consuntivo, dove la sonda vecchia misurava il preventivo.
- **«Qualcosa che Resta in Piedi»** e **«Il Muro che Tiene»**, i due obiettivi
  più facili del pool: **100% per Aldric, Nahr e Vaerax — 4,5% e 0% per Lyra.**
- La causa è una riga di dati: `starting_structures` posa uno `STR_KEEP`
  (famiglia PRESIDIO, quindi struttura *e* presidio insieme) alle altre tre
  case. **A Lyra niente.** Parte ogni anno con due carte morte su quattro, e
  chiude con **zero obiettivi 16 volte su 60 e quattro obiettivi mai**.
- **Perché nessuna sonda l'aveva visto**: il preventivo diceva 79% e 74,8%, ed
  erano numeri giusti — 100+100+100+4,5 fa 76. La media era vera e nascondeva
  che una casa su quattro è fuori. Terza volta in due versioni che un numero
  aggregato copre una misura che nessuno aveva guardato separatamente.
- **Tre difetti per strada**: «Pietra sopra Pietra» **0 su 64** perché chiede il
  grado 2 e *niente in partita arriva al grado 2* — è il buco che ISSUES 39
  opzione C riempirebbe; «L'Opera che Porta il Nome» al 5,9%; e il palese di
  Vaerax **0 su 20**.
- **E l'indice mentiva su ISSUES 26**: la voce era chiusa da 0.1.76 ma il titolo
  non portava la spunta. Ricontata: **47 carte su 48** hanno un mestiere, non 35
  su 48 come diceva la riga d'apertura.
- Nessuna regola accesa: sono decisioni di contenuto, e il numero è scritto
  prima perché si possa scegliere guardandolo.

## 0.1.176 — La mappa è ferma perché non ci sono pedine da muovere (D-208)

- Due rimedi per ISSUES 48 erano già stati misurati **a zero**. Il committente
  ha rifiutato la lettura consolatoria — «ogni era ha la sua Regione
  disabitata, è il mondo che racconta il secolo» — e ha spostato la domanda dove
  andava: **perché le pedine non si muovono?**
- Nessuna sonda lo sapeva dire. `run_move_probe` lo dice, e per ogni casa a fine
  anno nomina **quale porta era chiusa**: il gettone, la carta, la porta, o la
  voglia.
- **La risposta non è nessuna delle tre ipotesi della voce.** Ogni casa comincia
  con 2 pedine e il tetto è 3: ha **un** gettone di riserva per tutto l'anno. Lo
  posa, e da lì non ha più niente da muovere — a fine anno il **73%** dei seggi
  ha tutte le pedine sul tavolo.
- **Le carte abbondano** (12,57 MUOVERE viste in mano, 3,23 giocate) e la porta
  non è **mai** sbarrata: quello **0%** chiude da solo le tre ipotesi originali,
  adiacenza compresa.
- **E spostare non succede mai: 0,03 volte l'anno.** Non è un difetto nuovo, è
  D-185 che funziona — il cervello non toglie una pedina da dove la casa vive.
  Ma vuol dire che il gioco ha **due azioni diverse sotto lo stesso nome**, e la
  seconda è morta.
- **La Strada non è povera: è la Regione più ricca della mappa** — quattro
  vicini su cinque, 4 slot, WEALTH + KNOWLEDGE, tre tag di dominio più `trade`.
  Perde la corsa all'unico gettone perché nessuno ci comincia.
- **Tre rimedi prezzati, nessuno acceso**: il tetto a 4, gli studiosi che
  cominciano sulla Strada, e i due insieme. La combinazione è la sola che vince
  su ogni riga — la Strada diventa la **seconda** Regione più abitata (0,65 →
  **2,15**), nessuna scende sotto 1,60, i Consigli tornano dove stavano, e il
  playtest resta **0/8**.
- **L'effetto che nessuno cercava**: spostare Lyra sulla Strada **cura mezza
  ISSUES 52**. I suoi NONE crollano da 21 a 8 e le Vittorie salgono da 11 a 27.
  Il seggio che in dodici saghe non aveva mai trionfato non era debole: era nel
  **posto sbagliato**, a Eredan, dove Re Aldric ha già la parola.

## 0.1.175 — Anche l'anno d'apertura pesca le sue domande (D-207)

- «Le domande non dovevano essere pescate random all'inizio di una saga?» Metà
  della risposta era **sì, lo fanno**: su 12 saghe la biblioteca tira fuori **14
  mani diverse su 15 possibili**, e due saghe finiscono a **distanza 0,86** l'una
  dall'altra. L'altra metà dava ragione al committente: la pesca cominciava
  dall'**anno 2**, e ogni saga del Grano partiva dalle stesse quattro domande.
- **Nessuna sonda lo diceva, perché nessuna guardava l'apertura.** Il metro nuovo
  la nomina — mani d'apertura diverse, e distanza al primo anno — ed è così che
  «**1 mano su 12 saghe**» è diventato leggibile invece che vero e invisibile.
- **Adesso pescano tutte e quattro.** `CHR_01` tira 4 candidate su 6, `CHR_03`
  cinque su sei: pescarne quattro anche lì darebbe più combinazioni, ma
  cambierebbe la forma dell'anno del Sale per guadagnarle, e nessuno l'ha chiesto.
- **L'apertura si compone.** Il paragrafo scritto a mano nominava quattro domande
  e dava la Carestia per certa: dare la biblioteca senza spezzarlo avrebbe fatto
  leggere al tavolo un anno che non stava giocando. La Chronicle tiene la
  cornice, ogni domanda porta la propria riga, e una guardia impedisce che una
  candidata resti senza.
- **Il trabocchetto che stava per passare:** `library_sequel_of` deduceva «questa
  Chronicle continua se stessa» dall'**avere una biblioteca**. Vero per caso
  finché solo gli anni di seguito ne avevano una — con la biblioteca
  sull'apertura, una saga avrebbe **rigiocato la Carestia per dieci secoli**.
  Adesso il seguito si dichiara nel dato.
- **I numeri**: aperture diverse **1 → 6** (Grano) e **1 → 4** (Sale), distanza
  al primo anno **0,91 → 0,98** e **0,93 → 0,98**, distanza sulla saga intera
  **0,86 invariata**, playtest **0/8** a tavolo misto e uniforme.
- **Il prezzo, scritto**: i Consigli l'anno calano da 3,59 a **3,37** (uniforme) e
  da 3,97 a **3,73** (misto); nella linea del Grano i NONE salgono da 107 a 132 e
  i Trionfi scendono da 9 a 6. Il Sale non lo paga — Trionfi da 5 a **9**. La
  causa ha un nome ed è aperta come [ISSUES 51](docs/ISSUES.md).
- **Tre difetti trovati facendo**, tutti «una dichiarazione applicata nel momento
  sbagliato»: la biblioteca spenta *dopo* la pesca rompeva il **determinismo**
  (due esecuzioni dello stesso seme, due partite); i piani scriptati si
  dichiaravano dopo il setup mentre la sonda lo fa prima — la stessa distanza fra
  prova e spedizione di D-188; e il criterio «Deriva più Ripple bastano ad
  arrivare a soglia» era vero **di una Chronicle sola**, quella tarata a mano.
- **Due voci nuove**: [ISSUES 51](docs/ISSUES.md) — sei domande su dodici non
  arrivano a soglia da sole, e non ci arrivavano già prima; [ISSUES
  52](docs/ISSUES.md) — Lyra, **0 Trionfi e 37 NONE su 120 seggi-anno**.

## 0.1.174 — Il gioco a carte non aveva una storia perché il riempitivo parlava il gioco di prima (D-206)

- Da sei versioni il gioco si spedisce a carte e i tre piani scriptati sono
  rimasti tutte storie del §10 di prima. Stava in lista come «lavoro pulito,
  nessuna decisione richiesta»: **non era pulito, erano tre cose rotte, e nessuna
  era il piano**.
- **Il formato non sapeva dire «cala una carta»**: l'enum dello schema conosceva
  le sei azioni dirette e basta. Un piano nel gioco a carte era *inesprimibile*.
- **La guardia chiedeva a ogni piano di essere una storia vecchia**: un test
  pretendeva `actions_from_cards: false` per tutti. Scritto quando era vero di
  tutti, era diventato una legge. Ora ognuno **dice la sua**.
- **E la ragione vera: il riempitivo parlava il gioco di prima.** Le occasioni
  non scritte le riempiva ACQUISIRE → MUOVERE → passo, e nel gioco a carte le
  prime due non si pronunciano: **68 scelte illegali in una partita sola**, tante
  quante le occasioni libere. Adesso il riempitivo **cala una carta**, e a una
  carta che chiede un bersaglio dà la **domanda più fredda** — un riempitivo non
  deve decidere l'anno.
- **La storia**: `plan_d_crown_calls`, «La corona chiama subito». Aldric apre
  l'anno col Diritto di Corona in mano e la Carestia già a tre: non aspetta i
  gettoni, cala la carta e strappa il Consiglio nello stesso gesto. Quattro
  Consigli, uno cade, due Eco — e nessuno prende più di due obiettivi su quattro:
  è l'anno di chi ha parlato per primo, non di chi ha vinto.
- **Una guardia in più**: il test dei piani pretende adesso **almeno una storia
  per economia**. Senza, il gioco spedito può tornare a non averne nessuna, e
  come la prima volta non se ne accorgerebbe nessuno.
- Cancello: **408 test in 56 suite, 6770 asserzioni**; playtest **0 su 8**; sims
  exit 0 (quattro piani); toolchain e `--self-test` puliti.
- Verbale: [D-206](docs/DECISIONS.md#d-206), CONSEGNE §5bis.

---

## 0.1.173 — La Regione morta è quella dove non comincia nessuno (D-205)

- ISSUES 48 diceva «la Strada dei Mercanti è una Regione morta» e proponeva tre
  ipotesi. Rimisurando col gioco di adesso, **tutte e tre sbagliano bersaglio**.
- **La Strada è passata da 0,6% a 3,3%** delle pedine senza che nessuno la
  toccasse: l'ha alzata il gioco a carte. Ma il numero che spiega tutto è un
  altro: nel **Sale** la Strada sta al **13,8%** — terza più affollata — e la
  Regione morta sono le **Terre Nahr, all'1,7%**.
- **La Strada non è morta: è morta in un'era sola.** La causa è che le pedine si
  posano all'apertura e durante l'anno si muovono pochissimo: **la Regione vuota
  è quella in cui non comincia nessuno**, e cambia da un'era all'altra perché a
  cambiare sono le case.
- **Due rimedi provati, misurati, respinti**, tutti e due a zero: un **Pedaggio**
  sulla Strada (la struttura esisteva già nel catalogo e non stava su nessuna
  mappa) e un **cervello che conta anche i domini** oltre alle famiglie. 3,3%
  prima, 3,3% dopo, in entrambi i casi — perché quel ramo vive solo col gettone
  di riserva, e si gioca una volta per partita.
- **Tutti e due tolti**: un cambiamento che non muove nessun numero, tenuto, è
  peggio di una misura scritta — il prossimo lettore lo trova e crede che serva.
- **Quello che resta è una riga nella sonda**: `run_hand_probe` adesso **nomina**
  la Regione in cui non comincia nessuno invece di lasciarla dedurre.
- La voce cambia forma: non «la Strada è morta», ma «ogni era ha una Regione dove
  non vive nessuno». Da decidere se è un difetto o se è la mappa che racconta chi
  c'era in quel secolo.
- Verbale: [D-205](docs/DECISIONS.md#d-205), [ISSUES 48](docs/ISSUES.md).

---

## 0.1.172 — Due case su otto non potevano chiamare il Consiglio (D-204)

- ISSUES 37 lo aveva scritto in anticipo: *«o quando ISSUES 49 arriva e questa
  azione diventa quella che gira i mucchi coperti, e allora la domanda cambia
  forma»*. È arrivata. Col cancello del tavolo **RIVENDICARE è l'unico modo che
  un giocatore ha di aprire un Consiglio quando vuole lui**, quindi la prima
  domanda non è più «quante prenotazioni muoiono»: è **chi ha mai avuto in mano
  il diritto di chiamare**.
- **La misura, che non avevo mai preso**: su 40 Chronicle, la Cenere non aveva
  **mai** avuto una carta RIVENDICARE — **zero volte in venti partite** — e il
  Vaerax una ogni quattro. Le due case della montagna non potevano,
  materialmente, chiedere al tavolo di riunirsi.
- **Perché**: RIVENDICARE stava su **4 carte delle 48, tutte AUTORITÀ**, e
  l'AUTORITÀ si pesca solo da Eredan e dalle Terre Nahr. Chi tiene le montagne
  pesca FORZA, LEGAMI, SAPERE, e nessuna sapeva prendere la parola.
- **Quattro carte spostate**, scelte perché la finzione ci stava già dentro:
  **Assedio** (FORZA), **Debito Vecchio** (LEGAMI), **Deposizione Sigillata**
  (SAPERE), **Portavoce** (GENTE) — *«prende la parola al posto della folla»*, che
  è esattamente cosa vuol dire RIVENDICARE. Otto carte in **cinque famiglie**, e
  **ogni Regione della mappa** ne pesca almeno una.
- **Il risultato**: Cenere da 0,00 a **1,05** carte per partita, Vaerax da 0,25 a
  **1,50**. Lo scarto fra chi può chiamare di più e chi di meno passa da
  **infinito** a **3,1 volte**.
- **Le prenotazioni morte scendono ma non abbastanza**: dal **67%** al **56%**,
  contro un criterio del 33%. Quella metà di ISSUES 37 **resta aperta** — e il
  67% di partenza era già peggio del 41% di 0.1.159, perché con meno Consigli una
  prenotazione ha meno occasioni di essere riscossa.
- **E la sonda conta le carte invece di crederci**: `run_rung_probe` leggeva «4
  carte, tutte AUTORITÀ» da una riga battuta a macchina. Ora legge il mazzo.
- Cancello: **408 test in 56 suite, 6738 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme (Consigli 3,59 e 3,97); sims exit 0; toolchain pulita.
- Verbale: [D-204](docs/DECISIONS.md#d-204), [ISSUES 37](docs/ISSUES.md),
  MECCANICA §5.

---

## 0.1.171 — Una soglia sola per il tavolo, e il tre che non vale più tre (D-203)

- **ISSUES 49 fase 2**, sulla scelta **b** del committente: il Consiglio non lo
  chiama più la singola domanda che supera il proprio numero. Si apre quando sul
  tavolo sono scesi **tanti gettoni in tutto**, e a dibattersi va il **mucchio
  più alto**. Poi il conto riparte da zero.
- **Il numero scelto non vale più quel numero.** Il preventivo diceva «ogni 3
  segnalini riproduce il ritmo di oggi», ma era misurato nel gioco di prima, con
  18 azioni l'anno invece di sei. **E il tre non passa le guardie**: due anni su
  dodici in CHR_02 e tre su dodici in CHR_04 chiudono con **un** Consiglio, sotto
  il limite duro di 2. Ho spedito il **due**, e scrivo perché non è il tre.
- **Il prezzo, dichiarato**: il Consiglio passa da **6,03 e 6,01** l'anno a
  **3,46 e 4,00**. Da due per Atto a poco più di uno. È il cambiamento più grosso
  al ritmo dell'anno da quando le carte sono l'unica moneta, e si torna indietro
  con **una chiave**. Non è un difetto: a soglie più domande maturano insieme e le
  altre si accodano, col cancello del tavolo ogni apertura consuma **tutto** il
  calore. Il Consiglio smette di essere routine.
- **L'innesco a chiamata c'era già**: chi ha una rivendicazione matura la spende e
  apre il Consiglio sulla domanda che vuole. Anche quello svuota il sacchetto.
- **Tre posti dove una persona leggeva un numero che non succede più** (§5ter): il
  verbale diceva `Carestia: 4/7` e ora dice `Carestia: 4` segnando **quale mucchio
  è il più alto**; `visible_tension_threshold` torna **−1** col cancello acceso,
  così nessun pannello può scriverlo; la pagina delle regole prometteva «quando
  una arriva alla sua soglia» ed elencava le soglie — ora dice come funziona
  davvero, e che un Consiglio lo puoi aprire anche tu.
- **Una guardia perché non resti un numero morto**: `table_gate` e
  `threshold_bonus` insieme fanno rosso la CI. Il ritocco di D-192 alzava una
  soglia che adesso non apre niente; tolto da tutte e quattro le Chronicle.
- **Non fatti i mucchi coperti**: il cancello cambia *chi decide quando*, coprire
  i valori cambia *cosa si sa*, e va misurato a parte.
- Cancello: **408 test in 56 suite, 6737 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme; sims exit 0; toolchain e `--self-test` puliti.
- Verbale: [D-203](docs/DECISIONS.md#d-203), [ISSUES 49](docs/ISSUES.md).

---

## 0.1.170 — Il Sale conta anche lui, e la carta della terra torna a costare qualcosa (D-202)

- **Il mondo del Sale passa agli obiettivi**, dopo aver messo a posto i suoi
  Destini: il palese per casa passa da uno scarto di **31,0 a 13,7 punti** —
  meglio del 19,6 con cui è rimasta la prima saga.
- **Il primo cambiamento è un errore mio di due voci fa.** `DST_SHARED_LAND`
  costava alla Cenere il **100%**: non era così prima, era all'11,5%, e l'ho
  portata lì **io** in 0.1.167 allargando quella carta per aiutare Vaerax, che
  l'aveva al 16,7%. Ho aggiustato un estremo e ne ho creato uno peggiore
  dall'altra parte — la prova più netta della regola che avevo appena scritto:
  una carta che conta *il tuo tavolo* non si rende equa allargandola, si sposta.
- **`DST_LIBERE_WATER`** da 96,3% a **48,1%**: chiedeva un segno globale e la
  presenza dove le città stanno già. Ora chiede anche che il mondo non sia stato
  aperto in più di due punti — l'acqua non torna dove si è combattuto.
- **`DST_SALE_OPEN`** da 67,9% a **42,9%**: «il registro si può leggere» e non
  chiedeva che i conti fossero chiusi.
- **Una guardia ha morso mentre lavoravo**: alzando la Vittoria dell'Acqua avevo
  reso vera una delle strade del suo Trionfo, e `check_destiny_free_roads` l'ha
  detto subito. Senza, il Trionfo sarebbe diventato più facile mentre rendevo la
  Vittoria più dura, in silenzio.
- **Il tavolo intero, con tutte e quattro le Chronicle che contano** (800 seggi):
  0 su 4 nel **18,5%**, 4 su 4 nell'**1,9%**, media **1,45**, saga **+1,56**.
- **Un numero di contenuto è sceso, dichiarato**: la seconda saga pesca **10**
  Destini invece di 11, perché «La Terra che Risponde» ha lasciato il pool della
  Cenere. Ho preferito scrivere il numero più basso che inventare una carta per
  far tornare un conteggio.
- Cancello: **401 test in 55 suite, 6887 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme (Consigli 6,03 e 6,01); sims exit 0; toolchain e
  `--self-test` puliti.
- Verbale: [D-202](docs/DECISIONS.md#d-202), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.169 — Il mondo del Sale passa alle carte, e una saga smette di giocare a due giochi (D-201)

- **Un buco che stava lì da due versioni**: CHR_02 contava i gradini mentre
  CHR_01 contava gli obiettivi. Sono i due anni della **stessa saga**, e il
  punteggio di campagna sommava due scale **senza dirlo**, perché con gli
  obiettivi il livello si deriva e a valle sembra identico.
- **`check_a_saga_plays_one_game`**: le Chronicle si appaiano per lista dei seggi
  e sei regole si confrontano. Una regola accesa da una parte non può essere
  spenta dall'altra. Provata a morso sul caso vero.
- **CHR_03 e CHR_04 passano alle carte**: azioni dalle carte, rubinetto, presa di
  parola in un colpo, sacchetto dei gettoni. Tutto insieme, perché le metà si
  accendono insieme o si misura un terzo gioco che nessuno gioca.
- **La misura intermedia, scritta perché vale**: con le sole carte i Consigli
  erano crollati a **5,01 e 4,81** l'anno. Il sacchetto è la metà che rimette il
  calore.
- **E il +1 alle soglie che CHR_01 aveva chiesto è sbagliato per CHR_03**: 3,90
  Consigli l'anno con il bonus, **5,55 senza**. Due mondi che postano calore
  diverso non vogliono la stessa soglia — ed è esattamente il numero che una
  dichiarazione per Chronicle esiste per portare.
- **La mano del Sale**: 6,00 → 6,66 → **6,79** carte, e lo scarto fra la più
  piena e la più vuota **non cresce** (0,00 → 1,07 → 0,60), meglio dell'1,58 di
  CHR_01.
- **Non accesi gli obiettivi nel Sale**, di proposito: i suoi Destini sono i più
  facili di tutti (Libere-Acqua al **96,3%**) e accenderli adesso rimetterebbe in
  campo il difetto che 0.1.167 ha appena chiuso. Prima i Destini, poi il
  punteggio.
- Cancello: **401 test in 55 suite, 6887 asserzioni**; playtest **6,05 e 6,04**
  Consigli, **0 su 8** a tavolo misto e uniforme; sims exit 0; toolchain e
  `--self-test` puliti.
- Verbale: [D-201](docs/DECISIONS.md#d-201).

---

## 0.1.168 — Il quarto obiettivo pagato come una cosa rara (D-200)

- D-199 aveva reso il palese più equo e, per farlo, più caro: il punteggio di
  saga era sceso da +1,51 a +1,30. Ho scritto il numero peggiorato invece di
  compensarlo da solo, e il committente ha deciso: **compensare un po'**.
- `objectives.saga_points` per CHR_01: **−1 · 1 · 2 · 5 · 8** (era −1 · 1 · 2 ·
  4 · 6). Misurato: **+1,45 per seggio** — **recuperati tre quarti**, e il quarto
  che manca resta il prezzo dichiarato di un palese che costa uguale a tutti.
- **I punti sono andati sul terzo e sul quarto obiettivo**: sono i due che quasi
  nessuno prende (10,8% e 1,8%), e un trionfo che capita a un seggio su
  cinquantacinque deve valere più del doppio di «due su quattro». I due estremi
  restano dove erano: un anno senza niente toglie, e prenderne uno vale poco.
- **Due guardie**, perché la scala è un posto dove si sbaglia in silenzio:
  `levels` e `saga_points` sono indicizzate dal conto e il motore satura
  sull'ultima casella, quindi una scala più corta farebbe valere **uguale due
  risultati diversi** senza nessun errore. Ora la CI pretende che siano lunghe
  quanto il conto e che i punti salgano. Provate a morso, più un test sui dati
  spediti.
- Cancello: **401 test in 55 suite, 6889 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme; sims exit 0; toolchain e `--self-test` puliti.
- Verbale: [D-200](docs/DECISIONS.md#d-200), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.167 — Il palese pagato quasi uguale da tutte le case (D-199)

- Il difetto che D-196 aveva trovato per strada e che D-198 ha acceso lo stesso,
  dichiarandolo: **il palese vale un quarto del risultato e non costava uguale a
  tutti** — un vantaggio distribuito alla nascita.
- **La misura che conta è per casa, non per Destino**, perché una casa non
  sceglie quale dei tre le tocchi. Su 200 Chronicle, stessi semi: Nahr da
  **80,9% a 54,2%**, Lyra da 52,5% a 34,6%, Aldric e Vaerax fermi. **Lo scarto
  fra la casa più cara e la più facile passa da 43,2 a 19,6 punti** — meno della
  metà.
- **Quattro cambiamenti, tutti nei dati**: `DST_NAHR_ROOTED` chiede due segni di
  non essere di passaggio invece di uno; `DST_LYRA_TAUGHT` — che si chiama «Il
  sapere ha un posto suo» — adesso **il posto lo chiede**; `DST_SHARED_LAND`
  accetta due Regioni tenute **o** due cose in piedi; e Nahr, che aveva tre
  Destini di terra su tre, scambia il condivisibile con «I Conti Chiusi».
- **La regola generale imparata misurando**: una carta condivisibile costa
  uguale a tutti **solo se parla del mondo, non del tuo tavolo**. «I Conti
  Chiusi» guarda i segni globali e costa 42–45% a chiunque; «La Terra che
  Risponde» conta le *tue* Regioni, e allora il prezzo è la posizione di
  partenza travestita da ambizione.
- **Due residui, scritti invece che nascosti**: `DST_NAHR` resta a 72,5% (ci ho
  provato due volte e il numero non si è mosso: quello che costa sono le sue
  prime due clausole, e cambiarle vorrebbe dire riscrivere cosa significa) e
  `DST_SHARED_LAND` giurata da Vaerax resta a 16,7%.
- **Il prezzo, dichiarato**: più equo vuol dire più caro. 0 su 4 da 16,5% a
  **20,8%**, media da 1,51 a **1,37**, saga da +1,51 a **+1,30**. Non ho
  compensato con `saga_points`: prima va deciso se è la durezza giusta.
- Cancello: **400 test in 55 suite, 6881 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme (Consigli 6,15 e 6,30); sims exit 0; toolchain pulita.
- Verbale: [D-199](docs/DECISIONS.md#d-199), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.166 — Gli obiettivi al posto dei gradini, accesi (D-198)

- **CHR_01 non sale più una scala: conta.** Uno palese — il Destino giurato, che
  sanno tutti — e tre coperti pescati all'apertura dal pool dei dodici. Tutti e
  quattro è un trionfo, nessuno è un anno perso, in mezzo ci sono i successi
  parziali, e ognuno vale un numero diverso alla fine della saga.
- **Regola dichiarata dalla Chronicle**, reversibile come tutte le altre: una
  Chronicle che non scrive `objectives` gioca coi tre gradini di sempre.
- **Il livello non sparisce: si deriva dal conto** (`levels`). Toglierlo avrebbe
  rotto in un colpo il verbale, il pannello, il libro della saga, il salvataggio
  e il punteggio di campagna, che leggono tutti un livello.
- **Quello che il gioco conta davvero** su 100 Chronicle: 0 su 4 nel **19,0%**
  dei seggi, tutti e quattro nel **2,5%**, media **1,44**. La sonda ombra
  prometteva 1,58 — **era ottimista del 9%**, e la differenza è dichiarata.
- **Il lato umano, cercato invece che aspettato** (§5ter): pannello del seggio e
  console mostrano i quattro obiettivi coi coperti segnati; la riga del verbale
  dice il conto e quali, invece dell'etichetta di un gradino che il giocatore
  non ha chiuso; la pagina delle regole dice che non si sale, si conta. Tutti e
  tre leggono **una funzione sola**, `objectives_of()`.
- **Un errore trovato solo guardando la pagina**: un `+` e un `%` in ordine
  sbagliato mandavano la formattazione in errore a **ogni apertura**, con la
  suite verde perché nessun test leggeva quel testo. Ora tre test lo coprono.
- **Il lato classico si spegne intero**: cancellare la dichiarazione non bastava,
  perché `setup()` aveva già pescato i coperti sul seggio — due metà di due
  giochi diversi, lo stesso errore che D-184 aveva già pagato col rubinetto. Due
  test di determinismo l'hanno detto subito.
- **I tre piani scriptati dichiarano su quale scala si leggono**: una storia
  scritta a mano finisce dove finisce.
- Difetto aperto e dichiarato: il palese costa dal **35,7% all'80,0%** a seconda
  della casa. CHR_03 non è ancora passata: prima l'economia, poi il punteggio.
- Cancello: **400 test in 55 suite, 6882 asserzioni**; playtest **0 su 8** a
  tavolo misto e uniforme; sims exit 0; toolchain e `--self-test` puliti.
- Verbale: [D-198](docs/DECISIONS.md#d-198), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.165 — Il pool degli obiettivi, dodici carte misurate una per una (D-197)

- D-196 aveva detto che il pool non c'era. Ora c'è: **nuovo schema `objective`**
  — un traguardo piatto, senza gradini, con la riga che va a verbale — e
  **dodici obiettivi** in `godot/data/objectives/objectives_shared.json`.
- **Ogni carta misurata da sola** su 100 Chronicle: dal **79,0%** («Qualcosa che
  Resta in Piedi») al **10,2%** («Le Corde che Tengono»). Nessuno sotto il 10%,
  nessuno sopra l'80% — il criterio che D-196 aveva posto. Media 34,0%.
- **Due bocciati coi numeri**, i due che sembravano più belli: *«La Parola
  Data»* al **100%** (un regalo travestito da scrupolo) e *«Il Mondo Intatto»* al
  **2,0%** (arredo). La stessa idea a due cicatrici sta al 22%, e quella è
  entrata.
- **La distribuzione migliora senza toccare una soglia**: 0 su 4 passa da 27,2%
  a **16,2%**, la media da 1,26 a **1,58**, il punteggio di saga da +1,17 a
  **+1,65**. Sono cambiate solo le carte del pool.
- **Due guardie nuove**: `check_objectives_are_shareable` (un obiettivo che
  nomina una casa, una Regione o una Tensione è falso per costruzione nell'altro
  mondo) e `check_condition_vocabularies_agree` (il vocabolario delle clausole è
  ora scritto in due schemi: che dicano la stessa cosa). Più cinque test in
  `test_objective_pool.gd`, provati a morso.
- **Correzione a D-196**: il palese va dal **35,7% all'80,0%** fra gli otto
  Destini identitari; il 91% citato era `DST_LIBERE_WATER`, una variante.
- **Il motore non è ancora cambiato**: nessuna partita pesca obiettivi, i tre
  gradini sono ancora la scala di §14. Il pool è il preventivo che diventa dato.
- Verbale: [D-197](docs/DECISIONS.md#d-197), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.164 — Il preventivo dei quattro obiettivi (D-196)

- Il committente ha chiuso la domanda rimasta aperta: **gli obiettivi
  sostituiscono i gradini**, quattro se ne pescano e quattro se ne contano.
- **Nessuna regola cambiata.** Come per il sacchetto, prima si misura: nuova
  sonda ombra `godot/cli/run_objective_probe.gd`, che gioca le partite come sono
  e a fine anno rilegge il mondo chiedendogli cose che il gioco non gli chiede.
- **Su 100 Chronicle, 400 seggi, tavolo misto**: il NONE passa da **0,8% a
  27,2%**, il trionfo da **16,8% a 2,2%**, il punteggio di saga da **+2,51 a
  +1,17** per seggio. Il ritorno della possibilità di perdere è il cambiamento
  più grosso della proposta — più del trionfo.
- **Un difetto trovato per strada**: il palese non costa uguale a tutte le case
  (dal **41%** di Aldric al **91%** delle Libere). Se vale un quarto del
  risultato, è un vantaggio distribuito alla nascita.
- **Il pool non c'è ancora**: sei candidati, uno dei quali si avvera nell'1,8%
  dei seggi. Ne servono almeno dodici, nessuno sotto il 10% o sopra l'80%.
- Verbale: [D-196](docs/DECISIONS.md#d-196), [ISSUES 50](docs/ISSUES.md).

---

## 0.1.163 — Quello che una persona legge, riscritto dalle regole (D-195)

- Il seguito di D-194, **cercato invece che aspettato**: nessuna misura copre il
  lato umano, quindi ho guardato uno per uno i posti dove una regola nuova cambia
  ciò che una persona **legge**. Ce n'erano altri tre.
- **Il menu offriva di scoprire una cosa già visibile**: «Scopri il numero di…»
  quando da D-187 il velo copre la **soglia** e il numero è sul tavolo. Ora dice
  «Scopri a quanto esplode», e «Copri la soglia» al posto di «Cala il velo».
- **Il sacchetto cambiava il mondo in silenzio**: il gettone applicava il suo
  Effetto senza una riga a verbale, mentre la Deriva che sostituisce lo ha sempre
  detto. Ora: «Il gettone cade su La Carestia: sale di 1». Era D-030 rotta.
- **La pagina delle regole dentro l'app prometteva il gioco di tre versioni fa**:
  «un'azione è una di queste sei cose», «Acquisire — peschi una carta», «Tramare
  — leggi il numero». In cima a quel file c'era già scritto perché è successo:
  *«le parti che possono sfasarsi sono quelle che vengono dai dati»* — e metà
  pagina, quella generata, non è sfasata di una virgola. **L'elenco delle azioni
  era battuto a macchina.** Adesso si scrive anche lui dalle regole.
- Playtest **identico riga per riga**: `FAIL 253 · 111 · 127 · 113`, Consigli
  6,04, mediana 6, **0 su 8**. Suite **384 test / 6713 asserzioni**, con quattro
  prove che leggono la pagina dai due lati dell'interruttore.

### Dichiarato

- **Ho guardato tre posti, non tutti**: ho seguito velo, rubinetto e sacchetto
  dentro `seat_decider`, le viste e la pagina delle regole. È un campione
  ragionato, non un inventario.
- **La pagina ora ha una prova, il registro no**: che ogni mutazione si racconti
  resta affidato alla disciplina.
- **`MECCANICA.md` e la pagina dell'app dicono la stessa cosa per due strade
  diverse**: il documento è scritto a mano e può ancora sfasarsi.
- Il committente ha trovato in un minuto quello che tre versioni di misure non
  hanno visto: **le sonde guardano cosa fa il gioco, non cosa dice.**

---

## 0.1.162 — I bot erano passati alle carte, le mani no (D-194)

- **Trovato dal committente guardando l'app**: «su Pages non è cambiato nulla,
  mi sembra una vecchia versione».
- **Pages era aggiornato** — il workflow ha pubblicato dopo ogni merge, l'ultimo
  alle 21:33 con esito verde. Quello che sembrava vecchio **era il gioco**: il
  menu proponeva ancora «Acquisisci una carta AUTORITÀ», e sceglierla la faceva
  rifiutare un istante dopo.
- **La causa**: D-188 ha spostato il divieto delle sei azioni dirette da
  `check()` a `execute()` — per la ragione giusta — ma il menu umano si
  costruisce proprio con `check()`. Migrato il cervello dei bot, lasciate
  indietro le mani.
- **Adesso il menu offre le carte**: ogni azione compare una volta per ogni carta
  in mano che sa dirla — *«Mercenari» — Metti una presenza in Valle Verde* — e
  quelle che nessuna carta sa dire spariscono. Un punto solo, e copre schermo del
  tavolo, terminale e console del telefono.
- **Il test che doveva proteggere quella promessa è rimasto verde per tre
  versioni**: chiedeva `can_execute`, cioè `check()`, ed era `check()` ad aver
  smesso di rifiutare. Quello nuovo guarda dal lato giusto e, tolta la
  correzione, morde con lo stesso messaggio visto sull'app.
- Playtest **identico riga per riga**: `FAIL 253 · 111 · 127 · 113`, Consigli
  6,04, mediana 6, **0 su 8**. Suite **380 test / 6674 asserzioni**.

### Dichiarato

- **Nessuno se n'era accorto perché nessun bot usa quel menu**: il playtest, che
  è il cancello di casa, gioca solo con `PolicyDecider`. Non c'è sonda che copra
  quello che il committente guarda — l'ha trovato aprendo l'app.
- **Il rischio è strutturale**: ogni volta che una regola si sposta fra `check()`
  ed `execute()`, il menu umano cambia senza che nessuna misura lo dica. La
  guardia nuova copre il caso delle carte, non il prossimo.
- **Velo, rubinetto e sacchetto non sono stati riguardati dallo stesso punto di
  vista**: cambiano cosa una persona vede, e sono stati provati solo dal lato
  dei bot.

---

## 0.1.161 — La mano non sapeva dire metà di quello che il seggio voleva (D-193)

- La prima voce di CONSEGNE §5bis, scomposta: dei 720 turni misurati, **235** il
  cervello non voleva niente, **214** voleva qualcosa che la mano non sapeva
  dire, **271** hanno prodotto qualcosa.
- **Il modo di TRAMARE è libero**: le otto carte fissavano `REGION`, `TENSION` o
  `ECHO_DECK`, e chi voleva scoprire una domanda con in mano una carta da «leggi
  una Regione» passava il turno. **Mute di TRAMARE da 56 a 15.** È D-184
  riapplicato, e la terza volta che lo stesso difetto torna su una famiglia
  diversa.
- **La FORZA aveva un solo verso**: tre INFLUENZARE su tre, tutte +1. Una casa su
  Eredan e Montagne poteva solo scaldare il mondo. Il Posto di Blocco ora fa −1.
- **Un difetto vero trovato da un test**: la Chronicle di **libreria** faceva 2
  Consigli mediani invece di 3–7. Il sacchetto di D-192 leggeva la
  `drift_distribution` **scritta nella Chronicle**, che una Chronicle di libreria
  non ha — sacchetto vuoto, Deriva spenta perché il sacchetto la sostituisce, e
  l'anno non si scaldava mai. Ora il sacchetto è la traccia già mescolata.
- `FAIL 253 · 111 · 127 · 113`, Consigli 6,04, mediana 6, **0 su 8**. Suite
  **379 test / 6665 asserzioni**.

### Dichiarato

- **Il totale delle Occasioni mute non si è mosso**: 62% prima, 62% dopo. Le
  mute di TRAMARE sono crollate e i seggi hanno usato le Occasioni liberate per
  fare altro. **Non è un difetto da riparare**: è la forma del gioco senza
  ACQUISIRE.
- **Il paragone onesto**: nel gioco di prima le azioni diverse da ACQUISIRE erano
  3,2 per seggio all'anno su 18 Occasioni — il **18%**. Adesso succede qualcosa
  nel **37%**. Il gioco a carte è più attivo di quello che ha sostituito.
- **Gli 80 «la carta spinge dalla parte sbagliata» non sono un difetto**: la
  Folla non argomenta, sale di 1. Liberare anche il verso farebbe di ogni carta
  un jolly e toglierebbe il carattere.
- La FORZA resta sbilanciata (due su tre spingono in su): è voluto, non è
  misurato quanto costi a chi tiene solo Regioni di FORZA.

---

## 0.1.160 — Il calore lo pescano i giocatori (D-192)

- **ISSUES 49 fase 1**, sulla scelta **b** del committente. Ogni azione riuscita
  pesca un gettone dal sacchetto e lo posa su una domanda: il mondo si scalda
  perché qualcuno ha fatto qualcosa, non perché è passato il tempo. La Deriva a
  orologio si spegne.
- Il sacchetto è quello che c'era già — la distribuzione della Deriva (D-047),
  tarata dal committente. Dichiarato sulla Chronicle (`tension_tokens`).
- **Il preventivo di D-190 era sbagliato di due volte, ed è corretto qui.** La
  sonda ombra contava ogni firma d'azione distinta (una carta ne produce più
  d'una): i gettoni veri sono **~10 l'anno**, non 18,7. E soprattutto
  paragonavo i gettoni ai 9 della Deriva come se fosse tutto il calore del
  mondo: **CHR_01 ne posa 35,9 l'anno**, e la Deriva ne mette 9. Il sacchetto ne
  aggiunge dieci e ne toglie nove — **il calore totale cambia del 7%**, non del
  210%.
- **Le soglie salgono di 1, non del doppio**: misurato, +1 riporta i Consigli
  esattamente al ritmo di prima (5,93 l'anno contro 5,97); il raddoppio li
  dimezzava a 3,33.
- **Il ritocco sta sulla regola, non sulla Tensione** (`threshold_bonus`): la
  stessa Tensione gioca anche dove il sacchetto è spento, e lì una soglia alzata
  non si raggiunge mai — col dato riscritto il gioco classico faceva **zero
  Consigli**.
- **0 su 8** misto e uniforme, Consigli media 6,35, mediana 6. Suite **379 test
  / 6760 asserzioni**, sim plans e determinismo verdi.

### Dichiarato

- **Due difetti miei, trovati dai test.** Il gettone si firmava con la mano che
  aveva agito, e un gettone posato da un INFLUENZARE si contava come un secondo
  INFLUENZARE: **il tetto di §10 saltava**. E il seggio leggeva la soglia scritta
  mentre il Consiglio si apriva su quella ritoccata — decidevano su due numeri
  diversi. Corretti entrambi, con un test ciascuno.
- **La scelta b non è ancora costruita**: questa è la metà del calore. La soglia
  sola per il tavolo arriva quando i mucchi saranno coperti e l'innesco a
  chiamata. Il numero misurato resta **tre gettoni**.
- **I gettoni non sono ancora coperti**: coprirli è fase 2, e lì il velo di
  D-187 diventa inutile perché tutto è coperto per costruzione.
- **I 21 presagi e le 19 clausole dei Destini non sono stati toccati**: col
  calore che cambia del 7% non serviva. È una decisione presa sul numero
  corretto, non una dimenticanza.
- **CHR_03 non è toccata**: lì il calore lo mette ancora l'orologio.
- **I Consigli falliti salgono da 239 a 249**: il calore a raffiche apre più
  tavoli nei round affollati, e lì si oppone più gente.

---

## 0.1.159 — Non si prenota una domanda che è già matura (D-191)

- **Decisione del committente su §10**, la metà aperta di **ISSUES 37**: se la
  Tensione è **già matura** (valore ≥ 3), prendere la parola è **un'azione sola**.
  La prenotazione resta per il caso vero — la domanda che *non* è ancora matura.
- Nasce dalla scelta «**l'innesco lo apre un giocatore**»: un innesco a chiamata
  non è un innesco se la chiamata non riesce mai.
- Dichiarata sulla Chronicle (`claim_rules.same_round_when_ready`, `ready_at`):
  il §10 di sempre resta provato e si riaccende cambiando una riga.
- **Il modo delle quattro carte RIVENDICARE è stato liberato**: prenotare o
  strappare lo decide chi cala la carta, non la carta. È D-184 applicato.
- **Le morte in mano su CHR_01, in 40 partite: da 57 su 73 (78%) a 11 su 27 (41%).**
- Cancello: `FAIL 239 · 100 · 134 · 126`, Consigli 5,99, mediana 6, **0 su 8**.
  Suite **374 test / 6555 asserzioni**.

### Dichiarato

- **Il criterio di ISSUES 37 non è raggiunto**: chiedeva le morte sotto una su
  tre, siamo a 41% da 78%. Quasi dimezzate, non abbastanza. La metà resta aperta.
- **Due strade più aggressive sono state respinte coi numeri**: togliere del
  tutto la prenotazione al bot azzera le morte ma azzera anche le prenotazioni
  (e porta i Consigli falliti da 239 a 252); impedire al ripiego di giocare una
  carta RIVENDICARE alla cieca compra 2 punti di morte in meno e costa **19
  Consigli falliti**.
- **Una misura precedente era contaminata e l'ho corretta**: la sonda dei gradini
  alterna CHR_01 e CHR_03, e metà del campione veniva dal mondo dove la regola è
  spenta. I numeri qui sopra sono CHR_01 da sola.
- **CHR_03 non è toccata**: lì §10 è quello di sempre, morte al 78%. È il termine
  di paragone.
- **Forzare un Consiglio non è un Effetto** (`world["forced_confluence"]` si
  scrive a mano): una delle poche mutazioni senza inverso. Con l'innesco a
  chiamata diventerà il cuore del turno, e lì andrà fatta come si deve.
- I tre piani scriptati dichiarano ora anche `claim_rules` fra i propri
  `chronicle_overrides`, e una guardia lo verifica: è la stessa lezione di D-189.

---

## 0.1.158 — Il prezzo del sacchetto dei segnalini coperti (D-190)

- **Nessuna regola cambiata**: è il preventivo di **ISSUES 49**, la
  riprogettazione delle Tensioni voluta dal committente — «ogni carta o azione fa
  pescare uno o più segnalini coperti che danno un valore a una tensione».
- **Il sacchetto esiste già**: la Deriva è nove gettoni mescolati col seme. La
  proposta cambia **chi pesca** (i giocatori agendo) e **quando si guarda** (al
  Consiglio). Sonda nuova, `run_token_probe.gd`.
- **Il sacchetto funziona solo nel gioco a carte**: **18,7** segnalini l'anno in
  CHR_01 (2,1× la Deriva) contro **72,4** in CHR_03 (8,0×), dove ogni ACQUISIRE
  scalderebbe il mondo. Le due riprogettazioni hanno bisogno l'una dell'altra.
- **L'innesco che riproduce il ritmo di oggi**: un segnalino ogni **3** dà 5,95
  Consigli l'anno contro i 5,90 di adesso — e al tavolo si conta a occhio. A
  orologio darebbe 3 (fine Atto) o 9 (fine round).
- **Il numero che decide**: su 354 Consigli veri, il mucchio coperto avrebbe
  scelto la stessa domanda il **31%** delle volte. Sette su dieci si dibatterebbe
  altro. **Non è colore: è un altro gioco.**

### Dichiarato

- La sonda tiene un **mondo ombra** e non cambia niente: dice quanti segnalini
  scenderebbero, non come andrebbe la partita — con la regola accesa i seggi
  agirebbero diversamente, e questo la sonda non lo sa.
- **L'innesco «a chiamata» non è misurato** ed è quello che mi sembra migliore:
  non è misurabile con una sonda ombra perché dipende da una decisione che oggi
  nessun bot può prendere. Salderebbe **ISSUES 37**: RIVENDICARE diventerebbe il
  motore delle Tensioni invece di morire in mano tre volte su quattro.
- **Il sacchetto misto (1/2/3) è fuori scala**: 3,6× vuol dire rifare le soglie,
  non ritoccarle.
- La sonda pesca **a caso e uniformemente**: se è la carta a dire quale domanda
  si scalda, è un terzo gioco e non è misurato.
- Renderebbe inutile il velo di D-187, **in meglio**: tutte le domande sarebbero
  velate per costruzione, e TRAMARE diventerebbe «sbircio un segnalino».

---

## 0.1.157 — Un piano dice in che economia è stato scritto (D-189)

- **Riparazione di 0.1.156, trovata dalla CI.** Accendere le carte in CHR_01 ha
  reso ingiocabili i tre piani scriptati: `tools/run_sims.sh` usciva con **exit
  4** su tutti e tre. Dire in un verbale che «restano storie del §10 di prima»
  non bastava — i piani leggono la Chronicle spedita.
- **E la suite diceva verde**: passava dal `play_classic()` di 0.1.156 e provava
  il gioco vecchio, mentre la sonda da riga di comando provava quello nuovo. Due
  strade che provano due giochi diversi e si chiamano entrambe «i piani passano».
- **`chronicle_overrides` sul piano**: `actions_from_cards` e `hand_refill`. I
  tre piani dichiarano `false` — sono storie del §10 di prima, e ora lo dicono
  loro invece di un verbale.
- Le due strade passano dalla **stessa funzione** (`GameSession.apply_plan_overrides`),
  e una **guardia in `validate_data.py`** fa rosso la CI se una Chronicle gioca a
  carte e il piano non dichiara niente.
- CI locale intera rifatta guardando **gli exit code**: validate, self-test, i due
  drift check, dead_code, 372 test / 6722 asserzioni, sim plans, balance probe,
  determinismo di sims ed export. Tutto verde.

### Dichiarato

- **Il difetto è mio e la CI l'ha trovato al posto mio**: avevo lanciato
  `run_sims.sh` con l'output a `/dev/null` guardando solo se i file cambiavano.
  Il comando diceva «FALLITO (exit 4)» tre volte. La regola che ne esce è in
  CONSEGNE: dei comandi del cancello si guarda **l'exit code**.
- Resta vero che **manca un piano scriptato del gioco a carte**: adesso la
  mancanza è dichiarata nel dato, non solo in un verbale.
- `chronicle_overrides` è una porta che si può abusare: lo schema la tiene
  stretta a due chiavi apposta.

---

## 0.1.156 — Le quarantotto carte parlano (D-188)

- **ISSUES 47 fase 4**: le azioni passano sulla mano, e **l'interruttore si
  accende**. Il telaio era di D-184, il rubinetto di D-185, la mappa di D-186.
- **Tutte e 48 le carte portano un'azione**: 17 INFLUENZARE, 11 MUOVERE, 8
  TRAMARE, 8 FORGIARE, 4 RIVENDICARE. **ACQUISIRE sparisce** — era due terzi del
  gioco, e adesso la fa la mappa.
- La distribuzione non è casuale: la Regione decide che carte peschi, quindi
  **la mappa decide che cose puoi fare**. Chi sta sulle montagne muove eserciti,
  chi sta nelle miniere sa, chi siede a Eredan prende la parola.
- **La carta è la propria spesa**: le tre azioni che chiedono di scartare un
  Asset lo trovano nella carta stessa. Senza questa regola giocarne una ne
  costava due.
- **Il divieto stava nel posto sbagliato**: `check()` risponde a «sarebbe
  legale?», ed è la domanda che un seggio si fa *prima* di sapere con che carta
  lo dirà. Col divieto lì, **496 Occasioni su 720 restavano mute**. Ora vive in
  `execute()`.
- **Una guardia nuova**: `acquisition_rule` è prosa che nomina un fatto della
  mappa, e le due cose non erano legate da niente — il giorno della
  ridistribuzione **40 carte su 48 hanno cominciato a mentire** senza che nessun
  test se ne accorgesse. Adesso fanno rosso la CI.
- **0 su 8** misto e uniforme, nessuna azione rifiutata. `FAIL 235 · 99 · 122 ·
  121`, Consigli media 5,77, mediana 6. Suite **371 test / 6716 asserzioni**.
- **La divergenza di ISSUES 47 è chiusa a gioco acceso**: scarto fra la mano più
  piena e la più vuota all'Atto 3 **1,58**, contro 4,90 del gioco di prima.

### Dichiarato

- **Due difetti trovati misurando**: il *distratto* chiedeva un ACQUISIRE che non
  esiste più (93 rifiuti su 20 partite, i suoi NONE da 1 a 8); **Re Aldric si
  portava via da solo la presenza a Eredan** che il suo Minimo chiede, perché la
  voce nuova «allarga il rubinetto» spostava una pedina invece di posare la
  riserva (NONE da 1 a 8). Corretti entrambi.
- **CHR_03 gioca ancora il §10 di prima**, deliberatamente: la sua mappa non è
  stata guardata, e accendere lì le carte ripeterebbe il difetto che D-186 ha
  appena chiuso.
- **Le prove unitarie stanno sul lato classico e lo dichiarano** (`play_classic()`):
  usavano le azioni dirette per mettere il mondo in posizione, non per misurare
  l'economia. Che i dati spediti stiano dall'altra parte lo prova un test che
  rilegge il dato dal disco.
- **Manca un piano scriptato del gioco a carte**: i tre esistenti sono storie del
  §10 di prima. Il gioco nuovo è provato dal cancello e dai test, non da una
  storia raccontata.
- **Il 58% delle Occasioni resta muto**: 222 volte su 720 il cervello non voleva
  niente, **194 volte voleva qualcosa che la mano non sapeva dire**. È il costo
  vero della regola, ed è la prima misura che ne esista.
- Le quattro RIVENDICARE ereditano il difetto di **ISSUES 37**.
- **Maestra Ilve** perde Trionfi nel playtest (8 → 2 su 50 anni) per la modifica
  al cervello di D-187, non per l'economia. In campagna il Sale resta a **8 su
  12** (ISSUES 46), ma il divario merita una misura sua.

---

## 0.1.155 — Il velo copre la soglia, non il numero (D-187)

- Chiesta dal committente: «il mondo lo sa quale è il valore ma i giocatori nel
  gioco fisico no, e quindi nessuno sa quando le velate si attivano». Era
  un'**asimmetria che il tavolo fisico non può riprodurre**, non una taratura.
- **Il valore di una velata è pubblico**; è la **soglia** a stare coperta. Al
  tavolo vero è una carta girata a faccia in giù accanto al segnalino, e il
  registro scrive `Il Risveglio: 4/?`.
- **Sulla domanda si agisce lo stesso**: non sapere quando esploderà è il
  rischio, non un divieto. TRAMARE resta l'azione che gira la carta, e saperlo
  resta personale.
- Dichiarata sulla Chronicle (`veiled_tensions: HIDES_ALL | HIDES_THRESHOLD`),
  non scritta nel codice: la regola vecchia resta provata e si riaccende
  cambiando una stringa.
- **Un difetto trovato per strada**: il tavolo grande e la console **stampavano
  la soglia vera**, letta dal dato senza passare da nessun filtro. Con la regola
  vecchia non si notava; con la nuova avrebbe svuotato la regola il primo
  giorno. Ora una soglia coperta esce **−1**, come il dorso di una carta.
- **0 su 8** misto e uniforme. Suite **369 test / 6476 asserzioni**.

### Dichiarato

- **Non cambia quasi niente per i bot**: Consigli falliti 241 → **239**, medi
  5,44 → **5,43**, TRAMARE 130 → 134, INFLUENZARE 360 → 367. Le sonde non
  possono misurare la cosa per cui la regola è stata fatta — i bot non provano
  attesa. Il valore si vede in una serata con quattro persone.
- **Il velo di D-125 è più debole**: copriva un numero, ora copre solo il
  quando. Perdita reale per la casa che ha quell'arte, non ancora misurata.
- **La stima del bot è una scelta, non una misura**: chi non ha girato la carta
  usa la soglia media della Chronicle. Deterministica e onesta, ma non tarata
  contro le alternative.
- **Le altre due domande sulle Tensioni restano aperte**: la varietà nella prima
  partita, e il partire tutte da 0 (che obbliga a rifare le soglie).

---

## 0.1.154 — La mappa che distribuisce, e quante carte servono (D-186)

- **ISSUES 47 fase 3**, chiesta dal committente: «vai con la mappa, poi le carte
  per ogni atto devono essere pescate in numero sufficiente per fare le stesse
  azioni e per influenzare i concili come adesso».
- **Sei Regioni, due famiglie ciascuna, due Regioni per famiglia.** Prima
  `WEALTH` stava in quattro Regioni e `FORCE` in una sola; il divario fra la
  famiglia più a portata e la meno passa da **6,8 a 1** a **1,6 a 1**.
- **Dove stanno davvero le pedine**, misurato per la prima volta: Eredan 26,9%,
  Valle Verde 26,4%, Miniere 23,6%, Montagne 11,4%, Terre Nahr 11,1% — e la
  **Strada dei Mercanti allo 0,6%**. È una Regione morta (ISSUES 48).
- **Il fabbisogno**, che è la richiesta del committente diventata numero: per
  seggio e per anno, **3,20** azioni che costerebbero una carta + **8,59** carte
  impegnate ai Consigli = **11,80 l'anno, 3,93 per Atto**. Il rubinetto a
  `per_token: 1` ne dava 2: metà.
- **La taratura che regge il fabbisogno**: `per_token: 2, floor: 2, cap: 6,
  hand_cap: 7`. Misurata, la mano sta a 6–6,9 carte e **lo scarto fra la più
  piena e la più vuota all'Atto 3 è 1,18** — contro 4,90 del gioco di oggi. **Il
  punto 2 di ISSUES 47 è risolto.**
- Rubinetto spento, mappa nuova accesa: **0 su 8**, Consigli falliti **248 →
  241**. Suite **366 test / 6453 asserzioni**.

### Dichiarato

- **L'anno si è fatto più quieto**: Consigli medi da 5,79 a **5,44**, minimo
  della banda da 2 a **1**. Stessa causa: una mano più varia più spesso non ha
  la famiglia che quel Consiglio premia. È il prezzo, pagato apposta.
- **Due piani scriptati riregistrati.** «Il consiglio spezzato» da sei Consigli
  a tre — e la storia nuova è migliore: la domanda affondata torna al round dopo
  e a proporla è chi l'aveva affondata, col registro che scrive «la spirale si
  chiude». «La miniera aperta» perde i due Decisivi (margine 4 invece di 5).
- **Un errore preesistente trovato per strada**: la descrizione di «la miniera
  aperta» prometteva «tutte e quattro le bande di esito del §12.3» e un «passa
  pagando» che nei suoi stessi esiti registrati non c'erano. La prosa era ferma
  a una versione precedente. Ora combaciano.
- **61 asserzioni in meno** (6514 → 6453): sono i tre Consigli che «il consiglio
  spezzato» non gioca più. Nessun test tolto.
- La taratura del rubinetto è un **preventivo**: misurata col rubinetto *sopra*
  ACQUISIRE. Accesa oggi porterebbe i Consigli falliti a 304 — prezzo del doppio
  canale, non della taratura.
- **CHR_03 non è stata toccata**: tiene la sua mappa vecchia.

---

## 0.1.153 — Il rubinetto: la mano viene dalla mappa (D-185)

- **ISSUES 47 fase 2**, chiesta dal committente: «la presenza nelle regioni deve
  essere fondamentale nella pesca delle carte, tipo due presenze, due carte».
- A inizio di ogni Atto ogni seggio pesca guardando **dove tiene le pedine**:
  quante carte lo dicono i gettoni, **di che famiglia** lo dice la Regione
  (`asset_sources`). La mappa smette di essere un punteggio e diventa il rubinetto.
- **`hand_refill` sulla Chronicle** — `per_token`, `floor` (il pavimento per chi
  resta senza mappa), `cap` (tetto per Atto), `hand_cap` (tetto sulla mano).
  Omesso — il default — non succede niente.
- **Il freno che credevo giusto era quello sbagliato.** Scarto fra la mano più
  piena e la più vuota all'Atto 3: col solo tetto per Atto **5,48**, col tetto
  sulla mano **3,33**. Il tetto per Atto limita la pesca, non la mano: le carte
  non spese restano lì e lo scarto si accumula lo stesso.
- **E il gioco di oggi diverge di più**: 4,90 col rubinetto spento. ACQUISIRE, che
  nessuno frena, sbilancia più del rubinetto frenato.
- **Rubinetto spento nei dati**: playtest identico riga per riga a 0.1.150 —
  `FAIL 248 · 78 · 99 · 154`, **0 su 8 bloccati**. Suite **366 test / 6514
  asserzioni**.

### Dichiarato

- **Acceso da solo peggiora il gioco**: Consigli da 5,79 a 6,13 e i falliti da
  248 a **272**, il massimo mai misurato. Atteso — finché `actions_from_cards` è
  spento le carte del rubinetto si **sommano** ad ACQUISIRE invece di
  sostituirlo. Le due metà vanno accese **insieme**.
- Il vincolo regge lo stesso: **0 su 8** anche col rubinetto acceso.
- **Correggo un numero detto storto in sessione**: 9 Consigli in un anno non
  sfondano nessun «limite duro di §7». Non c'è tetto nel codice: 9 è il massimo
  strutturale (3 Atti × 3 round) e la banda 2–8 di MECCANICA è un estremo
  misurato, non una regola.
- `hand_cap: 5` è un punto di partenza, non una taratura: è stato misurato col
  rubinetto **sopra** ACQUISIRE. Quando ACQUISIRE sparirà va rimisurato.
- Il **pavimento** non è mai stato esercitato da una partita vera (nessun seggio
  resta senza pedine): è provato solo dai test.

---

## 0.1.152 — Il telaio delle azioni sulle carte (D-184)

- **ISSUES 47 fase 1**, sul via libera del committente: «ogni carta ha una azione
  di gioco, un valore per il consiglio, e effetti specifici della carta».
- **Due dei tre pezzi c'erano già**: il valore è `family`+`strength`, gli effetti
  sono `on_commit_effects` (47 carte su 48 ne hanno uno). Mancava l'azione.
- **`card_action` sull'Asset** — `{kind, params}` con `kind` fra le sei azioni di
  §10: il telaio non inventa verbi, sposta chi può pronunciarli.
- **`PLAY_CARD` nel resolver**: passa dal **medesimo `check()`** dell'azione
  corrispondente e poi **consuma la carta**. Nessuna regola scritta due volte, e
  un test lo prova chiedendo a una carta un MUOVERE illegale.
- **`actions_from_cards` sulla Chronicle**: spento (default) il gioco è quello di
  sempre; acceso, le sei azioni non si prendono più con un'Opportunità e la mano
  diventa l'unica moneta.
- **La spesa è il punto**: giocare una carta la scarta, quindi non voterà più. È
  lì che nasce il bilanciamento — *o la spendi per fare, o la tieni per votare*.
- **Zero carte convertite, playtest identico riga per riga** a 0.1.150. Suite
  **359 test / 6503 asserzioni**.

### Dichiarato

- Il gioco nuovo non esiste finché non si scrivono le **48 `card_action`**: la
  fase 1 serve a poterle scrivere una famiglia alla volta, misurando.
- **Il rubinetto della mano non è collegato**: le due metà (azioni dalle carte, e
  carte dalla presenza) vanno accese **insieme**, o un seggio resterebbe senza
  carte e senza poter agire.
- `TRAMARE` e `INFLUENZARE` spariranno quando esisteranno le carte che li portano.

## 0.1.151 — Il preventivo della mano che viene dalla mappa (D-183)

- **`run_hand_probe.gd`**, sonda nuova: il committente ha proposto che tutte le
  azioni si facciano con le carte e che le carte le dia la presenza sulla mappa.
  Prima di riscrivere 48 carte, il **preventivo** — la sonda gioca le partite
  come sono e scrive quante carte quel rubinetto darebbe.
- **Il numero che dà ragione alla proposta**: su 72 azioni disponibili in un
  anno, i seggi giocano **47 ACQUISIRE** e **1 solo MUOVERE**. Due terzi del
  gioco sono già «pesca una carta».
- **Il gioco si stringerebbe al 36–40%** di adesso (6,6–7,2 carte contro 18
  azioni), e **lo scarto fra il primo e l'ultimo seggio raddoppia ogni atto**
  (0,00 → 1,25 → 1,92): la divergenza non viene dal setup, la produce il gioco.
- **Nessun seggio resta senza pedine** in 480 campioni: la spirale della morte
  non si materializza.
- **La mappa non distribuisce le famiglie**: `WEALTH` sta in quattro Regioni su
  sei, `FORCE` in una sola. Un seggio raggiunge 3,3 famiglie su 6.
- Aperta come **ISSUES 47**. Nessuna regola cambiata: dati, playtest e suite
  restano quelli di 0.1.150.
- La sonda dei gradini risponde anche a **«essere il proponente conviene?»**: sì,
  e il gradino medio cresce col numero di proposte (1,33 con zero, 1,93 con tre).

## 0.1.150 — Il Sale non vinceva: gli succedeva di vincere (D-182)

- **ISSUES 46, sulla direzione data dal committente**: «il Sale è troppo forte».
  Guardato dal lato suo, il difetto aveva **tre teste**, tutte misurate col banco
  delle clausole: il Minimo vero al **100%**, la seconda clausola della Vittoria
  («e nessuno lo ha cancellato») vera al **100%**, e la **spina del Trionfo** («il
  patto con la Cenere regge») vera al **100%**.
- **`DST_SALE` superava il Minimo 12 volte su 13.** E non perché la Gilda giocasse
  meglio: la sua Vittoria la decideva il **calendario** — `debt_called` matura da
  sé quando la Tensione arriva a soglia, e le altre due clausole non falliscono
  mai. Al Sale non riusciva di vincere: **gli succedeva**.
- **Quattro passi misurati uno alla volta**, e il primo insegna qualcosa: chiedere
  il debito chiamato **e** un alleato rimasto tale sono due cose **anti-correlate**
  (riscuotere allontana chi paga), e il Destino è crollato dal 92% al **15%** —
  l'errore di D-177 arrivato dal lato opposto. A NEUTRALE la richiesta diventa
  «riscuotere senza rompere», che è quello che una Gilda sa fare.
- **La promessa è stata spostata, non cancellata**: `promise_kept` compare una
  volta sola in tutto il gioco, e toglierla l'avrebbe resa contenuto che non
  esiste. Ora è una delle cinque strade del Trionfo.
- **E il secondo Destino era diventato il colpevole**: `DST_SALE_OPEN` faceva **6
  Trionfi su 13**, il massimo del gioco. La sua scelta passa da una strada su
  quattro a due: da 0/6/**1**/6 a **0/6/6/1**.

| | prima | dopo |
|---|---|---|
| `DST_SALE` (N/M/V/T su 13) | 0 / **1** / 8 / 4 — supera il **92%** | **0 / 7 / 4 / 2** — supera il 46% |
| campagne vinte dal Sale | **12 su 12** | **9 su 12** |
| il Sale supera il Minimo, nelle saghe | 68% | **54%** (le altre 33–34%) |
| ultimo cambio di testa | anno **3,5** su 10 | anno **5,5** su 10 |
| campagne decise entro il terzo anno | 6 su 12 | **4 su 12** |

- Playtest **FAIL 248 · 78 · 99 · 154**, mediana 6, **0 su 8**. I **Consigli
  falliti scendono da 256 a 248**, ed è la prima volta che quel numero torna
  indietro. Suite **355 test / 6490 asserzioni**.

### Dichiarato

- **La voce è ridotta, non chiusa**: il criterio che si era data — nessuna casa
  sopra la metà delle campagne — non è raggiunto (**9 su 12 è il 75%**). Mi fermo
  perché continuare senza una diagnosi nuova sarebbe tarare a occhio.
- Restano da guardare i **Trionfi nelle saghe** (Sale 25, Libere 19, Vetro 11,
  Cenere 8) e il fatto che il **Minimo delle quattro case non costa uguale**.
- Kessa prende 1 NONE a tavolo misto dove prima ne aveva 0: dentro il vincolo.

## 0.1.149 — Una campagna è almeno dieci anni (D-181)

- **Deciso dal committente**: «direi la saga almeno 10 partite». Sta in
  `saga_scoring.decides_after`, con **10** nelle due saghe in gioco. Prima della
  soglia il conto si tiene ma nessuno ha vinto, e il verbale lo dice ogni anno
  (*«La campagna non è ancora decisa: 3 anni giocati su 10»*); dalla decima in poi
  dichiara il vincitore, o la parità se c'è.
- **«Almeno» vuol dire che la soglia apre la porta e non la chiude**: al decimo
  anno la campagna può finire, e se il tavolo continua il conto prosegue.
- **Un numero nuovo nel mondo**: `chronicles_played`, quante Chronicle ha giocato
  questa saga. Non si poteva ricavare da `year`, perché fra due Chronicle passano
  da 1 a 200 anni — cento anni di mondo possono essere due partite o dieci.
- **E la soglia rende concreta la domanda che D-180 aveva dichiarato senza
  risposta**: il conto rende ininfluenti gli ultimi anni? La misura è l'anno
  dell'**ultimo cambio di testa**:

| su 12 saghe da 10 Chronicle | la Carestia | il Sale |
|---|---|---|
| cambi di testa per saga | **1,8** | 1,3 |
| ultimo cambio di testa | anno **5,0** su 10 | anno **3,5** su 10 |
| campagne decise entro il terzo anno | **3 su 12** | **6 su 12** |

- **Nella Carestia la campagna regge** — cambia padrone quasi due volte e
  l'ultimo sorpasso arriva a metà strada. **Nel Sale no**: metà delle campagne è
  decisa entro il terzo anno su dieci. La causa non è la soglia né la scala, è
  **ISSUES 46**: una casa che supera il Minimo il 68% delle volte prende la testa
  presto e non la molla. Lo stesso squilibrio visto da un terzo lato — prima come
  gradini, poi come vincitore, adesso come **noia**.
- Il playtest è **identico riga per riga** a quello di 0.1.147 per la terza
  versione di fila. Suite **355 test / 6490 asserzioni**.

### Dichiarato

- **Dieci è il numero del committente, non un numero misurato**: la misura dice
  che a dieci la Carestia regge e il Sale no, non che dieci sia il valore giusto.
- Il pareggio al decimo anno non ha uno spareggio: il verbale dice «si va avanti».

## 0.1.148 — Il vincitore della saga (D-180)

- **Voluta dal committente**: «per vincere la saga ci vuole un contatore di
  vittorie nelle singole partite». Ogni Chronicle chiusa somma al seggio il
  valore del livello raggiunto, il totale attraversa le ere insieme alla mappa, e
  alla fine della campagna vince chi ha di più.
- **Non contraddice il principio del gioco** perché sta a livello di **saga**:
  dentro l'anno non cambia niente — nessuna classifica, più case possono vincere,
  tutte possono fallire — ed è la campagna ad avere un vincitore.
- **Cinque scale misurate prima di sceglierne una.** Il rischio temuto era che
  pagare il Minimo facesse vincere la campagna a chi non ha mai rischiato: **la
  misura lo ha smentito**, con nessuna scala e in nessuna saga vince chi ha più
  Minimi. Scelta la **−1 / 1 / 3 / 6**: meno pareggi (3 su 24 saghe) e l'accordo
  più alto con i Trionfi (18 su 24). Il NONE che toglie un punto è la conseguenza
  di [D-067](docs/DECISIONS.md#d-067) — perdere è possibile, e in una campagna
  deve costare.
- **Sta nella Chronicle** (`saga_scoring`), quindi si cambia senza toccare il
  codice, e **omessa spegne tutto**: una Chronicle può restare un anno che sta in
  piedi da solo, come in v0.2.
- **Il punteggio segue il seggio, non la persona**: in una saga lunga il Popolo
  Nahr diventa Il Regno di Nahr e il conto prosegue. È un contatore, non un
  Effetto, fra le eccezioni dichiarate all'effect-sourcing.
- **Il playtest è identico riga per riga** a quello di 0.1.147: nessuna policy
  legge il punteggio, è puro verbale. Suite **353 test / 6480 asserzioni**.

### E quello che il contatore ha rivelato

- **Nella saga del Sale la campagna la vince sempre la stessa casa** — SALE 12 su
  12, con qualunque scala — mentre in quella della Carestia i vincitori sono tre
  su quattro. Non è un difetto del punteggio: è lo squilibrio di contenuto già
  noto (Sale al 68% sopra il Minimo contro 24–33% delle altre) che finora si
  **spalmava** anno per anno e che un totale cumulativo rende **definitivo**.
- **Un contatore di campagna non è una regola neutra: è un amplificatore** di
  tutto quello che il bilanciamento non ha ancora chiuso. Aperta come
  **ISSUES 46**.

## 0.1.147 — La meccanica al vero, e come si gioca bene (D-179)

- **`docs/MECCANICA.md` era fermo a 0.1.140**, e il suo principio dichiarato è che
  ogni numero dentro sia quello vero letto dai dati. Passati uno per uno: la
  maggior parte reggeva (132 carte su 48 tipi, 39 carte Narratore, 52 Conseguenze
  di cui 14 cambiano padrone, 10 modelli di Consiglio, 20 Destini, 9 tipi di
  struttura), **cinque no**.
- **Le regole dei segni sono 52, non 45** — e il documento **contraddiceva sé
  stesso**, perché §3 e §14 dicevano già 52 mentre §9 diceva 45. Rifatta anche la
  ripartizione per tipo (COUNCIL_MODIFIER 16→**17**, DRAW_BIAS 10→**14**,
  HAND_LIMIT 1→**3**).
- **Le famiglie di struttura sono 4, non 5**: il passo è un `LUOGO`, e la famiglia
  `CHIUSURA` non esiste nei dati.
- **I Destini in gioco all'apertura sono 19 dei 20**, non 9: il pool è acceso da
  0.1.141. Il ventesimo appartiene a un seggio che siede solo in saga.
- **Come finisce un anno** è ora misurato sulle partite di oggi — 0% / 44% / 36% /
  **20%** a tavolo misto — con accanto la colonna dei quattro ottimizzatori
  (1% / 28% / 41% / 30%): la stessa policy, e venti punti di Trionfo di
  differenza fra chi non spreca un turno e chi ogni tanto lo spreca.
- **Tre cose che mancavano del tutto**: che il Destino **si pesca da un pool di
  tre** (col suo costo dichiarato, i Consigli falliti da 206 a 246); che **sette
  Conseguenze costruiscono** qualcosa che resta sulla mappa e pesa nel controllo;
  e come si gioca bene.
- **Sezione nuova §15 «Come si gioca bene, misurato»**: i quattro caratteri sugli
  stessi 100 semi — **la prudenza è la strategia peggiore del gioco** (40% contro
  62–63%), e l'**ostinato**, che punta al gradino alto dal primo round, ha più
  Trionfi *e* meno Minimi di tutti. Più nove regole pratiche col numero accanto,
  fra cui le **111 rivendicazioni morte su 128** e l'errore di spegnersi il
  Destino da soli.

### Dichiarato

- La sezione si chiude con **quello che non sa**: i numeri vengono da bot contro
  bot, che non tradiscono e non mentono. Sono muti sulla metà negoziata del gioco.
- Nessun dato di gioco toccato: playtest, suite e sonde restano quelli di 0.1.146.

## 0.1.146 — Due guardie, e la seconda ha morso subito (D-178)

- **Il difetto di D-177 si vedeva senza giocare una partita.** Trovarlo era
  costato una sessione di sonde; la causa era un conto di somme sui dati. I
  livelli sono cumulativi, quindi le presenze che un Destino chiede si sommano
  dal Minimo in su e vanno confrontate col tetto dei gettoni della Chronicle.
- **`check_destiny_token_budget`** fa quel conto su tutti e venti i Destini e
  distingue due esiti: gli **obblighi** che superano il tetto (livello
  irraggiungibile) e la **strada** dentro un `some_of` che li porta oltre —
  percorribile, ma solo spegnendo una clausola di un livello sotto. È il difetto
  della Cenere, e sui dati di 0.1.144 la guardia lo ritrova in un istante; sui
  dati di oggi, zero. **Era l'unico caso in tutto il gioco.**
- **`check_destiny_free_roads`** è l'altra faccia della stessa moneta: se un
  livello sotto può *falsificare* una clausola di sopra, può anche *regalarla*.
  Ha trovato una riga sola, e non era vecchia — era di ieri: rendendo la
  reliquia obbligatoria nella Vittoria di `DST_CENERE_DEEP`, D-177 aveva acceso
  da solo il primo dei sei rami del suo Trionfo, che di fatto chiedeva **due
  segni su cinque** invece di tre su sei.
- **Ed è la spiegazione della bimodalità che D-177 aveva dichiarato senza
  saperla spiegare.** Tolto il ramo ridondante, `DST_CENERE_DEEP` passa da
  0/8/**1**/7 a **0/8/5/3**: lo stesso 50% sopra il Minimo, distribuito come una
  scala invece che come un salto. Kessa a tavolo misto da 0/29/9/12 a
  **0/29/13/8**; playtest **FAIL 256 · 78 · 100 · 145**, mediana 6, **0 su 8**.
- **Le due guardie girano nella CI**, e prima dei dati veri gira
  `validate_data.py --self-test`, che le mette su tre Destini sintetici e
  pretende che tacciano su quello sano e parlino sugli altri: una guardia che
  nessuno ha mai visto mordere non è una guardia (D-144).

### Dichiarato

- Le guardie vedono i gettoni e le strade regalate, **non** ogni modo in cui un
  Destino può combattersi da solo (un tag chiesto da un livello e vietato da un
  altro non lo prende nessuno).
- Le asserzioni della suite scendono da 6445 a **6444**: `test_data_boot` ne fa
  una per ogni `state_tag_present` di ogni Destino, e c'è una condizione in meno.
  I test restano **349** e la copertura del tag resta.

## 0.1.145 — Il Destino che si combatteva da solo (D-177)

- **La linea della Cenere/Fuochi aveva una causa, e non era la debolezza.** Su
  120 anni della saga del Sale **tutti e tredici i NONE erano della Cenere** (le
  altre tre case: zero), e tutti per la stessa clausola del suo Minimo. Negli
  anni persi la casa teneva **1,00** gettoni sulle Montagne Rosse e **1,92** nelle
  Miniere; negli altri anni 1,67 e 1,04. Stesso numero di gettoni, posto diverso:
  la Cenere **scendeva sotto per la propria Vittoria** e cosi' spegneva il proprio
  Minimo. I livelli sono cumulativi, quindi inseguire quel gradino costava quello
  che lo regge.
- **`DST_CENERE_DEEP` aveva ereditato il Minimo del Destino sbagliato** — quello
  di `DST_CENERE`, dove presidiare la montagna in due ha senso. Adesso il suo
  Minimo e' «**Non hanno lasciato la montagna**»: la casa esiste ancora e **un**
  gettone e' rimasto su. Un gettone resta, due scendono.
- **E la Vittoria ha perso i suoi due regali**: chiedeva una presenza nelle
  gallerie e che non fossero murate, tutt'e due vere al 100%. Adesso chiede la
  discesa in due **e** la reliquia — la pedina la muove il seggio, la reliquia
  gliela deve dare il tavolo.
- **Kessa dei Fuochi** passa da 0/32/10/8 a **0/29/9/12** a tavolo misto e da
  1/33/13/3 a **1/21/17/11** a tavolo uniforme; nelle saghe la Cenere va da **13
  NONE** a **0** e dal 26% al **33%** sopra il Minimo, coi Trionfi da 6 a 15. I
  volti dei Fuochi da 8%–33% a **22%–50%**.
- **La sonda delle ere** dice adesso *quale clausola* manca quando un anno chiude
  a NONE, e dove la Cenere tiene i gettoni: era la misura che mancava, perche' il
  NONE di quella casa si vedeva solo nelle saghe e la sonda dei gradini guarda una
  Chronicle sola.

### Dichiarato

- **Consigli falliti da 248 a 256**: una casa che arriva viva a fine anno propone
  e si oppone piu' a lungo.
- **Il perdere ha cambiato posto invece di sparire**: i 13 NONE della Cenere
  diventano 0 e ne compaiono **2 del Vetro**, che adesso contende alla Cenere gli
  slot delle stesse gallerie. Il conto totale del perdere in questa saga scende
  pero' da 13 a 2.
- La forma scelta e' **bimodale** (8 Minimi, 1 Vittoria, 7 Trionfi) e due ipotesi
  scritte sono state **demolite dalla misura** prima di arrivare alla causa vera:
  la clausola creduta impossibile e' vera il 35% delle volte, e le Montagne Rosse
  non erano affollate ma vuote. Tutto in [D-177](docs/DECISIONS.md#d-177).

## 0.1.144 — Le istituzioni non governano diversamente (D-176)

- **ISSUES 35 chiusa, e l'ipotesi era falsa.** Misurata come la voce chiedeva —
  dodici saghe a tavolo misto, livelli per incarnazione — le **otto istituzioni**
  superano il Minimo il **41%** delle volte e le **quindici persone** il **42%**.
  Un punto: chi siede non c'entra niente.
- **Quello che c'entra è la casa.** Un'istituzione al 68% (La Compagnia del Sale)
  e una al 14% (Le Custodi della Cenere) sono lontane fra loro quanto le due
  persone agli estremi, e la linea che va male va male con chiunque la porti: i
  cinque volti dei Fuochi stanno fra l'8% e il 46%, i cinque Maestri fra il 46%
  e il 67%.
- La forma si vedeva lo stesso perché nella saga del Sale le istituzioni siedono
  **dopo**, e dopo il mondo è più segnato: la correlazione c'era, la causa era il
  momento e non il soggetto.
- La **sonda delle ere** stampa il conto dei livelli per incarnazione: era la
  misura che la voce chiedeva e non c'era.

## 0.1.143 — Tre Conseguenze che costruiscono (D-175)

- **`CNS_NAHR_SETTLEMENT`, `CNS_MARCH_GRANTED` e `CNS_MARKET_MOVED`** non
  scrivono più solo un segno: costruiscono un **villaggio**, una **torre di
  veglia** e un **villaggio**. I segni restano — le regole li leggono — ma sotto
  adesso c'è qualcosa che pesa nel conto del controllo e sopravvive all'anno.
  La più interessante è la marca: una concessione senza niente sopra poteva
  tornare indietro il round dopo, la torre è quello che la tiene.
- `CNS_RELIC_BURIED` resta un segno: la cella murata non è nessuna delle nove
  cose del catalogo, e inventarne una decima per una Conseguenza sola sarebbe la
  tentazione che D-164 aveva già pagato.
- Pietre **alzate giocando: 174** su 80 partite. Gradini e playtest invariati.
- **Mezza ISSUES 37 chiusa**: la mappa si muove — 82% di caselle con un padrone
  contro il 56%, seggi a zero Regioni dal 30% all'11% — e non per una correzione
  mirata ma perché il padrone si conta invece di scriverlo. Resta l'altra metà,
  con un nome preciso: **`ACT_CLAIM` muore in mano 110 volte su 128**, e il punto
  di rottura è §10 del regolamento, non il codice.

## 0.1.142 — Tre voci chiuse (D-174)

- **ISSUES 41 chiusa.** Il sito antico non era mai «aperto e ancora intero», e la
  colpevole era il **sigillo**: `CNS_MINE_SEALED` riportava il sito a grado 1,
  cioè cancellava il fatto che fosse mai stato aperto e svuotato. Un sigillo
  nasconde, non restituisce. Ora lo lascia al grado di mezzo: «aperto e ancora
  intero» passa da **0% a 20%** degli anni.
- **ISSUES 42 chiusa**, e nessuna delle tre cause che la voce elencava regge:
  i Destini di CHR_03 sono **più duri** (41% di clausole mancate contro 38%), le
  sue Tensioni si muovono **meno** (5,33 Consigli contro 5,83), e le due saghe
  hanno una casa senza terra a testa. Il divario era **degli otto Destini che si
  giocavano**: aperto il pool, CHR_01 va al 19% e CHR_03 al 23%.
- **ISSUES 40 decisa**: il grado alto resta **materia di saga**. Una clausola sul
  grado 2 o 3 si scrive solo nei Destini di una Chronicle successiva.
- La sonda dei gradini stampa i **Consigli chiusi per saga** — la misura che
  ISSUES 42 chiedeva e non c'era.

## 0.1.141 — Il pool si accende: venti Destini invece di otto (D-173)

- **ISSUES 43 chiusa.** Le tre che restavano sono riscritte: i due Destini
  condivisibili chiedevano al **Minimo** una cosa che si ottiene giocando — la
  fama, il registro pulito — e lasciavano fuori dal gioco al primo colpo un
  seggio su tre; `DST_ALDRIC_RECORD` chiedeva alla Vittoria due Regioni, mancate
  all'88%.
- **Il pool e' acceso**: `_deal_destiny` pesca dalla lista dell'Entita' quando la
  Chronicle non ne dichiara una. **Venti Destini su venti** si giocano
  all'apertura, contro otto.
- **Zero seggi a NONE** (erano 4 su 800), nessuno a zero Trionfi, tavolo misto e
  uniforme **0 su 8**, mediana dei Consigli **6**.
- **Costo dichiarato: Consigli falliti da 206 a 246.** E' il numero piu' alto mai
  misurato, e la causa non e' oscura — undici ambizioni in piu' al tavolo si
  oppongono fra loro molto piu' spesso. Si spegne in una riga.
- *Un Minimo non e' un obiettivo, e' una soglia di sopravvivenza* — e le carte
  scritte per otto case diverse sono il posto dove sbagliarlo costa di piu'.

## 0.1.140 — Il bot smette di sbirciare (D-172)

- **`world["voted_together"]`**: per ogni coppia, quante volte sono finiti sullo
  stesso fronte del Consiglio meno quante volte su fronti opposti. E' la memoria
  dei bot, non un fatto del mondo — quello che chiunque sieda al tavolo vede con
  i propri occhi.
- **L'alleanza si decide su quello**, non piu' leggendo il Destino altrui: un
  giocatore vero quella carta non la vede. Prima del primo Consiglio nessuno sa
  niente di nessuno, e la regola tace.
- **Il prezzo scende da dodici Trionfi a tre** (86 → **83**, contro i 74 di
  D-171), e le alleanze si distribuiscono: la banda passa da 5-50% a **15-35%**,
  e Aldric e Vaerax — che l'opposizione dichiarata escludeva per regola —
  entrano al 20% e al 35%. Due che si oppongono su un segno possono benissimo
  essersi trovati dalla stessa parte su tre domande diverse.
- E adesso **si puo' sbagliare un alleato**, che e' la sola cosa su cui si possa
  costruire un tradimento.

## 0.1.139 — L'alleanza che conviene (D-171)

- **Un seggio adesso stringe un legame perche' gli conviene**, non solo perche'
  una clausola glielo chiede: si allea con **chi aspetta lo stesso Consiglio**,
  perche' quando la domanda si apre quel voto pesa sul suo fronte (D-139). Chi
  gli si oppone su un segno resta fuori comunque.
- **Correzione**: «nessun bot stringe alleanze» era troppo forte. `ACT_FORGE`
  c'era e la policy la giocava — ma solo quando una clausola del proprio Destino
  nominava quella relazione.
- **La prima forma — «ti allei con chi vuole i tuoi stessi segni» — non ha
  sparato una volta**, e ha trovato una cosa sul contenuto: fra gli otto Destini
  **non esiste una coppia che voglia lo stesso segno nello stesso verso**. Ogni
  sovrapposizione e' un'opposizione. C'e' un test che tiene fermo quel fatto.
- **Il ceto sociale si accende**: Lyra e Nahr passano da **0% a 45%** di anni
  con almeno un alleato.
- **Il prezzo, dichiarato: Trionfi del tavolo da 86 a 74.** Un'alleanza costa
  un'Occasione, e l'Occasione e' tutta la moneta dell'anno. Le due leve ovvie
  per abbassarlo — soglia piu' alta, regola piu' in basso — **non sparano mai**:
  il quadrante e' binario.

## 0.1.138 — Gli undici Destini mai giocati (D-170)

- **ISSUES 43 misurata**: acceso il pool, supera il Minimo scende da **62% a
  50%** e un seggio su dodici finisce a **NONE** (oggi: mai). Il meccanismo e'
  giusto, il contenuto no — gli undici non erano mai stati guardati da nessuna
  sonda. **Il pool resta spento.**
- **Sei Destini riscritti** nella forma spina + scelta, con le strade misurate
  prima: `DST_CENERE_DEEP` (16 su 16 fermo al Minimo, tre clausole al 100%),
  `DST_NAHR_ROOTED` e `DST_SALE_OPEN` (zero Trionfi, lo stesso tag mai
  guadagnato), `DST_SHARED_RENOWN` (il Minimo chiedeva la fama), 
  `DST_SHARED_ACCOUNTS` (Trionfo piu' facile della Vittoria), `DST_LIBERE_WATER`
  (Trionfo al 75%). Col pool acceso si passa a 53% / 7%: meglio, non abbastanza.
- **Il perimetro della sonda delle clausole**, trovato usandola: misura cosa e'
  vero **nel mondo che c'e'**, coi seggi che giocano il proprio Destino. Un
  Destino nuovo fa un mondo diverso — «una Regione controllata» dava 80-100% sul
  banco e 13 NONE su 41 ai seggi che la giuravano davvero.
- Col pool spento **tutto invariato**: playtest FAIL 203, mediana 6, misto 0 su
  8, gradini 62% e 0 NONE. Le riscritture costano zero perche' nessuno le pesca,
  ed e' esattamente il punto della issue.

## 0.1.137 — Lyra apre (D-169)

- **La Vittoria di Lyra non e' piu' una porta sola**: spina (presenza nelle
  Miniere) piu' **due segni su tre** — la scorta giurata, le Miniere non
  sigillate, un posto sulla mappa. Il Trionfo chiede **quattro Scoperte**
  invece di due: due erano vere nel 100% degli anni misurati.
- **La scelta di Nahr scende da quattro segni a tre**, perche' aprire Lyra le
  costava sette Trionfi senza che nessuno toccasse il suo Destino.
- **La banda dei Consigli sale a 5-7** nell'anno scritto e nell'anno pescato,
  coi limiti duri fermi a 2-8. Un seggio che ricomincia a giocare fa l'anno piu'
  rumoroso: e' la seconda volta, dopo D-051.
- **Una forma scartata benche' misurasse meglio**: la scelta 2 su 5 dava a Lyra
  27/16/7 e al tavolo 91 Trionfi, e due delle cinque strade erano vere prima che
  qualcuno giocasse. *Quando una forma misura meglio di tutte le altre, si
  controlla che non stia misurando bene per il motivo sbagliato.*
- Trionfi del tavolo **79 → 86**, tavolo misto 0 su 8, mediana 6. Costo
  dichiarato: **FAIL 191 → 203**. ISSUES 44 chiusa.

## 0.1.136 — Il giro su Lyra, misurato e non committato

- **[D-168](docs/DECISIONS.md#d-168)**: la scala di Lyra non e' debole, e'
  **bimodale** — Minimo, spina della Vittoria e spina del Trionfo tutte al 100%,
  e tutto appeso a un tag solo al **25%**. Tre modi di aprirla, tutti e tre con
  lo stesso prezzo: la mediana dei Consigli passa da 6 a **7**, e gli anni
  tranquilli spariscono dalla distribuzione. **Nessuna modifica ai Destini**: e'
  una scelta fra un seggio che gioca e la banda dei Consigli, ed e' ISSUES 44.
- **Il banco della sonda** (`tools/clause_candidates.json`) porta le diciassette
  clausole di Lyra misurate: e' la prova del verbale.
- Due numeri trovati per strada: le **clausole sociali sono ancora esattamente
  zero** (alleanza con Aldric 0%, non-inimicizia con Vaerax 0%) — la seconda
  domanda di D-151 finalmente con un numero accanto — e Lyra **non si sposta mai**
  sulla Strada dei Mercanti (0%).

## [0.1.134] — La spina e la scelta

Il Trionfo smette di essere una lista da soddisfare per intero
([D-167](docs/DECISIONS.md#d-167)). Richiesta del committente: «i destini li
farei diversi, una serie di condizioni che se soddisfatte danno il grado di
vittoria, includendo anche gli edifici e/o il controllo e/o le cicatrici».

### Added

- **`cli/run_clause_probe.gd`** — quanto costa una clausola **prima** di
  scriverla in un Destino. Legge `tools/clause_candidates.json` e riporta, per
  ogni casa, la quota di anni in cui sarebbe vera a fine anno. E' lo strumento
  che mancava a [D-161](docs/DECISIONS.md#d-161), che aveva scritto cinque
  clausole a occhio: tre muri, due regali, zero utili.
- **La spina e la scelta.** Otto Trionfi riscritti, uno per casa: una o due
  clausole in AND — quello che quella casa voleva davvero — piu' una `some_of`
  su quattro, cinque o sei strade. Fra le strade, per la prima volta, **le
  pietre e le cicatrici**: «la corona ha piu' di una casa di pietra», «il passo
  e' franato», «le Miniere sono uscite pulite», «e le citta' hanno costruito,
  non solo discusso».
- **`describe_all`** apre una scelta strada per strada nelle evidence di fine
  anno. «Tre di queste cinque» non si legge se non si vede quali erano.
- **La sonda dei gradini conta le pietre**: quante ne tiene ogni casa a fine
  anno, per famiglia e per grado, quante se ne alzano giocando, dove cadono le
  cicatrici, e **dove arriva ogni Destino** invece del solo totale.
- **`validate_data.py` controlla lo `structure_type`** di una clausola. Un tipo
  sbagliato non era un errore: contava zero, cioe' diventava un muro che nessuno
  aveva deciso di alzare.
- **`open_roads`**: i conti rimasti aperti ([D-087](docs/DECISIONS.md#d-087))
  portano **quali strade sono cadute**, non «tre di queste cinque». Sono la
  meta' strutturata delle evidence, quella che l'era dopo eredita: una scelta
  opaca l'avrebbe resa cieca proprio dove ne ho spostate meta'.

### Fixed

- **Quattro seggi su otto avevano zero Trionfi su cinquanta partite.** Due per
  una clausola mancata il **100%** delle volte: Vaerax chiedeva un tag che
  niente scrive mai, la Gilda chiedeva due Regioni a una casa che ne tiene 0,90.
  Una lista in AND con dentro un muro e' un gradino tolto dal gioco, e nessuno
  se ne accorgeva perche' il seggio riportava comunque VITTORIA.
- **Le clausole annidate erano invisibili a quattro controlli su quattro.**
  `PolicyDecider` — dove il difetto sarebbe costato di piu': un seggio legge il
  proprio Destino per sapere cosa vuole, e una clausola dentro una scelta ha per
  tipo `some_of`. Spostandone meta' dentro le scelte, meta' delle ambizioni del
  tavolo sarebbero sparite in silenzio (e' [D-066](docs/DECISIONS.md#d-066), che
  aveva trovato l'80% dei seggi a valutare una proposta zero). L'hanno visto due
  test, non io. Appiattite anche in `validate_data.py`, nel controllo sui tag
  irraggiungibili e in quello che verifica che una Chronicle nomini le proprie
  Tensioni.

### Measured

| | prima | dopo |
|---|---|---|
| Trionfi, tavolo misto su 400 seggi-partita | **21** | **79** |
| seggi con zero Trionfi | **4 su 8** | **0 su 8** |
| Esiti | FAIL 207 · 77 · 112 · 189 | **FAIL 191** · 69 · 116 · 196 |
| sonda dei gradini: TRIONFO | 6% | **20%** |
| supera il Minimo | 54% | **63%** |
| clausole mancate il 100% delle volte | 2 | **0** |

Trionfi per Destino, su 30 partite ciascuno: 3 · 4 · 7 · 6 · 8 · 7 · 6 · 7 —
nessuno murato, nessuno regalato. Ci sono voluti quattro giri di misura: la
prima scrittura mandava Kessa al 75%, la seconda schiacciava le Citta' Libere a
1 su 30.

Tavolo misto **0 su 8**, Consigli mediana 6. Suite **342 test / 6472
asserzioni** verde; sims ed export identici su due giri; `dead_code.py` pulito
su 154 file.

---

## [0.1.133] — Il passo che frana

L'ultimo pezzo del catalogo ([D-166](docs/DECISIONS.md#d-166)), tenuto per ultimo
di proposito: **la sola cosa che cambia la forma del mondo**.

### Added

- **`CLOSE_PASSAGE` / `OPEN_PASSAGE`**, l'uno l'inverso dell'altro: tolgono un
  arco da tutte e due le parti. Le **adiacenze diventano stato del mondo** —
  erano l'unica cosa della mappa che non cambiava mai.
- **`STR_PASS`**: Passo aperto → Passo franato. *La Via delle Miniere Tagliata*
  lo fa cadere: due Effect per un fatto solo, il luogo che cambia stato e l'arco
  che si chiude.
- **La guardia**: una Regione irraggiungibile e' **un Destino impossibile**. Il
  taglio si prova, si visita il grafo, e **se il mondo si e' spezzato si rimette
  a posto**. Il test lo prova col solo caso che romperebbe davvero — due tagli
  sulle Miniere, e il secondo viene rifiutato.

### Fixed

- **Riaprire un varco rimetteva il vicino in fondo alla lista.** Il round-trip
  l'ha visto: lo stato non tornava byte per byte. E non e' stile — **l'ordine
  dei vicini lo legge il gioco** (`$adjacent` ci pesca dentro). Adesso si
  ricostruisce nell'ordine d'autore.

### Measured

Su quaranta Chronicle: **1 varco chiuso**, 1 passo franato, **0 tagli
rifiutati**. Una volta ogni quarant'anni meta' della montagna scende a valle in
una notte — la frequenza giusta per un fatto che riscrive la mappa. Non forzata.

Playtest **FAIL 207 · SUCC 77 · SUCC 112 · DECI 189** — identico a 0.1.132:
l'ultimo pezzo costa **zero**. Tavolo misto **0 su 8**, mediana **6**.

Suite **339 test / 6051 asserzioni** verde, sims ed export deterministici.

**Il catalogo e' chiuso**: nove tipi in cinque famiglie. Resta fuori solo la
palude, che chiede motore e non contenuto.

---

## [0.1.132] — Il sito antico e la sorgente

Gli altri due luoghi del mondo ([D-165](docs/DECISIONS.md#d-165)), scritti sotto
un vincolo nuovo: **il degrado toglie un dono, non aggiunge una penalita'**.

### Added

- **`STR_OLD_SITE`**: dormiente → **aperto (sapere migliore)** → saccheggiato.
- **`STR_SPRING`**: **viva (gente migliore)** → bassa → secca.
- Le cause **cercate fra quelle che c'erano**: *Le Gallerie Riaperte*, *La
  Miniera Aperta*, *Le Miniere Sigillate*, *La Valle che si Vuota*, *L'Acqua a
  Prezzo*. Nessuna carta nuova, nessun rimescolo.

### Measured

**Playtest FAIL 207 · SUCC 77 · SUCC 112 · DECI 189 — identico** alla misura
prima di aggiungerle. Due famiglie nuove e **zero punti** di costo: e' il
vincolo di progetto che ha funzionato. Tavolo misto **0 su 8**, mediana **6**.

Su venti Chronicle: 38 siti dormienti, **2 saccheggiati**, **0 aperti**; 39
sorgenti vive, **1 bassa**, **0 secche**.

**Da dichiarare:** `place:open_site` **non si raggiunge mai**, e con lui dorme la
regola del sapere. La causa c'e' ed e' una Conseguenza vera che su questi semi
non esce quasi mai — non aggiungo un'altra porta per forzarla. Se si vogliono
vedere i siti aperti, la leva e' **partire da aperto**, non moltiplicare le
cause.

Suite **334 test / 6025 asserzioni** verde, sims deterministiche.

---

## [0.1.131] — La selva maledetta ha una causa

Correzione al buco dichiarato in D-163 ([D-164](docs/DECISIONS.md#d-164)): la
selva maledetta era contenuto scritto e **mai raggiunto**.

### Fixed

- **La maledizione ha una causa**: *La Partenza* (812) e *I Fuochi Fuori* (1640)
  fanno diventare selva il bosco della Regione a fuoco. **Tre selve in venti
  partite**, contro zero.

### Changed — e due strade sbagliate, per il verbale

Il primo tentativo era **una carta nuova**, e ha rotto tre cose insieme:

1. **il mazzo si rimescola** — il costruttore lo dice da sempre, e i **tre piani
   di regressione** sono saltati tutti e tre: non per un difetto, ma perche'
   l'anno scritto non era piu' lo stesso anno;
2. **l'equilibrio per famiglia** — sei carte ROTTURA per saga, ne avevo messe
   otto: il mix drammatico e' progettato, non accumulato;
3. **due carte, un disegno solo** — stesso `art_prompt_key`, e c'e' un test che
   lo vieta.

Agganciarla a carte che esistono gia' e' meglio su ogni fronte: **nessun
rimescolo, nessun equilibrio rotto, nessun piano toccato**, e una selva in piu'.

**La regola che ne esce:** quando serve una causa nuova per un effetto nuovo, si
guarda **prima** se una carta esistente sta gia' raccontando quel fatto. Un
mazzo e' un equilibrio, non un elenco.

### Removed

- **`TGR_CURSED_WOOD_COUNCIL`**: la selva che faceva partire **ogni** Consiglio
  col mondo contro. L'avevo aggiunta io e **non era nel progetto** — la seduta
  diceva «chi ha presenza li' perde una carta», che e' una morsa **locale**. Una
  penalita' mondiale da un fatto locale e' un dente sbagliato, e costava tre
  punti.

### Measured

Playtest **FAIL 207 · SUCC 77 · SUCC 112 · DECI 189**, mediana **6**, tavolo
misto **0 su 8**. Suite **334 test / 6005 asserzioni** verde, sims
deterministiche.

**Il trend, di nuovo:** i Consigli falliti dall'inizio della strada C sono
**185 → 191 → 196 → 203 → 201 → 207**, cioe' **+22**. Lo 0/8 regge da undici
modifiche e la banda dei Consigli e' rispettata, ma ventidue punti non sono
rumore: **prima del fiume, del sito antico e della palude va deciso se 207 e' il
numero che vogliamo.** E' una domanda di gusto, e va al committente.

---

## [0.1.130] — La foresta

Passo 5 del catalogo ([D-163](docs/DECISIONS.md#d-163)): il primo **luogo del
mondo**, che non e' di nessuno.

### Added

- **`STR_FOREST`**: Foresta → Bosco diradato → **Selva maledetta** → La Radura
  Spoglia. Un `LUOGO` non ha padrone, non entra nel conto del controllo e non
  sale ne' scende col Destino: cambia **cosa vale** una Regione, non **chi la
  tiene**.
- Tre regole: la foresta intera **da' legna a chiunque ci stia**; la selva
  maledetta toglie **una carta in mano** e fa partire i Consigli col mondo un
  po' contro.
- Il prefisso `place:` per i segni del mondo, accanto a `structure:` e
  `settlement:` che sono opere delle case.
- Tre foreste sulla mappa, dove i biomi le permettono; due Conseguenze le
  diradano o le fanno diventare selva.

### Fixed

- **`SET_STRUCTURE_GRADE` falliva con un errore** su una Regione senza quella
  struttura. Una Conseguenza nomina `$region_focus` e la Regione a fuoco cambia:
  diradare un bosco dove non c'e' un bosco non e' un errore di dati. Adesso
  rispetta `optional`, come `REMOVE_PRESENCE` da sempre. L'errore compariva a
  **ogni partita**.

### Measured — e da dichiarare

Su venti Chronicle: **59** foreste intere a fine anno, **1** bosco diradato,
**0** selve maledette.

Il luogo **c'e' e funziona**; il **degrado quasi no**. Due delle tre regole sono
attaccate a uno stato che non si raggiunge. E' la forma dell'errore di D-161 in
un posto diverso — ma li' erano clausole di Destino, e una clausola che non si
avvera rompe un'ambizione; qui sono regole dei segni, e una regola dormiente non
rompe niente. **La selva maledetta e' contenuto scritto e non raggiunto**, e le
manca una carta del Narratore che la causi.

Playtest **FAIL 201 · SUCC 74 · SUCC 114 · DECI 192**, misto **0 su 8** —
identico a D-162: la foresta non sposta l'equilibrio, e non doveva.

Suite **334 test / 6003 asserzioni** verde, sims deterministiche.

---

## [0.1.129] — Le opere, e il segno che adesso ha un oggetto sotto

Passo 4 del catalogo ([D-162](docs/DECISIONS.md#d-162)).

### Added

- **Tre opere**, due gradi ciascuna: `STR_GRANARY` (Granaio → **Il Grande
  Granaio**), `STR_CANAL` (Canale → **La Grande Opera d'Acqua**), `STR_TOLLGATE`
  (Pedaggio → **La Dogana**).
- **I due gradi portano lo stesso segno**: una grande opera non e' un'opera
  diversa, e' la stessa **che pesa di piu'**. Le tre regole dei segni gia'
  scritte valgono a tutti e due i gradi senza riscriverle; la differenza sta nel
  conto del controllo, 1 contro 2.

### Fixed

- **Sette carte posavano un segno senza oggetto sotto.** Un tag senza struttura
  si vede sulla mappa, fa scattare le regole, e **non conta per nessuno** nella
  contesa: la mappa diceva una cosa e il conto un'altra. Convertite tutte e
  sette — tre Conseguenze, un Asset (padrone: **chi ha messo la carta sul
  tavolo**), tre carte del Narratore, di cui due adesso **fanno cadere
  l'oggetto** invece di cancellare il segno.
- Resta fuori solo `structure:sealed`, che e' una **chiusura**: murare una
  miniera non da' niente a nessuno.

### Measured

| | D-161 | ora |
|---|---|---|
| Consigli falliti | 204 | **201** |
| tavolo misto | 0/8 | **0/8** |
| caselle tenute a fine anno (su 180) | 143 | **150** |

I Consigli falliti erano 185 → 191 → 196 → 203 → 204: **e' la prima volta che
scendono** da quando e' cominciata la strada C. La lettura di D-160 regge — non
era una tassa, erano le policy, e adesso hanno piu' cose vere su cui votare.

Gradini: supera il Minimo **58%** (era 47%), caselle con un padrone **84%** (era
56%), seggi con due Regioni **32%** (era 12%), a zero **11%** (era 30%).

Nel tempo lungo (12 saghe da 8 anni): grado I **44**, grado II **13**, grado III
**4**. Le regge erano **zero** con una sola scala, due con l'insediamento,
quattro adesso — e nessuna e' scritta a mano.

Suite **334 test / 5988 asserzioni** verde, sims deterministiche.

---

## [0.1.128] — Le clausole che leggono le pietre

Richiesta del committente sui Destini ([D-161](docs/DECISIONS.md#d-161)). Meta'
di quello che chiedeva c'era gia': un Destino **e' gia'** una lista di
condizioni per livello, con dodici tipi e `any_of` per l'oppure.

### Added

- **`structure_count`** — quante strutture, coi filtri: tipo, famiglia, **grado
  minimo**, Regione, e `anyone` per contare anche quelle degli altri.
- **`scar_count`** — quante cicatrici, per tag e per Regione. Erano leggibili e
  **nessun Destino le usava**.
- **`some_of`** — almeno `min` fra queste condizioni. `any_of` era il caso K=1.

I due conteggi dicono presenza **e** assenza con lo stesso conto: «un castello a
Eredan» e' `min: 1`, «e nessuno ha alzato una reggia sulla montagna» e'
`grade: 3` + `anyone` + `max: 0`.

### Changed

- **`CNS_ASH_WATCH` costruisce davvero.** Posava un segno; adesso **alza un
  presidio che ha un padrone**, che entra nel conto del controllo e puo'
  crescere. E' la prima Conseguenza che costruisce un oggetto invece di
  scrivere un tag, ed e' il modello per le altre dieci.
- Su 30 Chronicle i passaggi di mano per contesa passano da **63 a 74**, e le
  caselle tenute a fine anno da 138 a **143**.

### Measured — e cinque clausole tolte

Scritte cinque clausole coi tipi nuovi, la sonda ha risposto: **tre mancate al
100%, due mai mancate. Zero utili** — e il Trionfo sceso dal 5% al 3%.

La causa non era il bilanciamento: **erano clausole su uno strato che dentro
l'anno nessuno poteva cambiare.** Le strutture si muovevano solo all'apertura e
alla chiusura; nei nove round non si costruiva niente. E «nessuna cicatrice» e'
una lotteria: **un anno su quaranta** finisce senza.

Le cinque clausole sono state **tolte**. Il vocabolario resta, il contenuto
aspetta il pezzo che mancava — che e' arrivato con `CNS_ASH_WATCH`.

**La regola che ne esce:** una clausola che parla di uno strato si scrive
**dopo** che quello strato ha almeno un modo di cambiare durante l'anno, e si
misura sui gradini **prima** di restare.

Playtest **FAIL 204 · SUCC 73 · SUCC 113 · DECI 186**, mediana **6**, misto
**0 su 8**. Suite **334 test / 5991 asserzioni** verde, sims deterministiche.

---

## [0.1.127] — L'insediamento

La seconda scala del catalogo ([D-160](docs/DECISIONS.md#d-160)), e il trend dei
Consigli falliti guardato per primo come promesso in D-159.

### Measured — il trend, prima di aggiungere

- **Non e' una tassa sistemica**: la sovraestensione morde **11 volte in 30
  partite**. I Consigli aperti sono passati da 5,63 a 5,75 di media — dentro la
  banda (mediana 5-6) — e la quota di fallimenti e' salita di **1,6 punti**.
  La causa e' che le policy **votano diverso** da quando il controllo si conta.

### Added

- **`STR_SETTLEMENT`**: Villaggio (1) → Borgo (2) → Citta' (4) → Abbandono, con
  tre regole dei segni — il villaggio **piega la pesca della gente**, il borgo
  **tiene una carta in piu'**, la citta' piega il **Fattore Mondo**. Riusa il
  prefisso `settlement:` che c'era gia'.
- Un villaggio semina la Valle Verde in tutte e due le linee.

### Measured — e la seconda scala cambia la prima

Dodici saghe da otto anni:

| | solo presidi | col villaggio |
|---|---|---|
| grado II (castelli e borghi) | 3 | **13** |
| grado III (regge e citta') | 0 | **2** |

**Con due strutture, chi perde lascia andare il villaggio e tiene il castello**:
il grado cade sulla piu' bassa e sale sulla piu' alta, quindi i presidi non sono
piu' i primi a cadere e arrivano in fondo alla scala. Le prime **due regge**
compaiono qui, e nessuno le aveva scritte a mano.

Playtest **FAIL 204 · SUCC 73 · SUCC 113 · DECI 186**, mediana **6**, tavolo
misto **0 su 8**. Gradini: supera il Minimo **59%** (era 47%), caselle con un
padrone **81%**, seggi con due Regioni **30%**.

### Changed

- **`SIM_PLAN_C` aggiornato**: il sesto Consiglio passa a FAILURE per **un punto
  solo**. Il Cristallo, cuore narrativo del piano, sta al terzo e non si e'
  mosso; la descrizione e' stata riscritta per dire il vero.
- **I test delle strutture sgomberano la propria Regione** invece di dare per
  scontata una mappa vuota: quali Regioni siano costruite e' contenuto, e un
  test non deve dipenderne per misurare un meccanismo.

Suite **334 test / 5992 asserzioni** verde, sims deterministiche.

---

## [0.1.126] — La scala che si muove col Destino

«Se la reggia appartiene all'entita' che ha perso va in rovina, se invece
trionfa diventa una reggia» ([D-159](docs/DECISIONS.md#d-159), §7.3 della seduta
sulla terra).

### Added

- **`structure_rules`** sulla Chronicle: chi trionfa **alza di un grado la sua
  struttura piu' alta**, chi non arriva al Minimo **ne perde uno sulla piu'
  bassa**. Sotto il primo grado non si scende: si va in **rovina**, e la rovina
  lascia una cicatrice.
- **`starting_structures`**: la mappa si apre gia' costruita. Le tre Regioni che
  partono con un padrone partono con una **torre di veglia**. Sta sulla
  Chronicle e non sulla Regione per la stessa ragione di `starting_control`.

### Measured

Dodici saghe da otto anni:

| | |
|---|---|
| gradi saliti (Trionfo) | **24** |
| strutture andate in rovina | **19** |
| castelli in piedi all'ottavo anno | **3** |
| regge | 0 |

In otto anni tre torri diventano castelli e nessuno arriva a una reggia: e' il
ritmo giusto, una reggia deve restare un fatto raro.

Playtest **FAIL 203 · SUCC 76 · SUCC 108 · DECI 188**, tavolo misto **0 su 8**,
uniforme **2 su 8**; mappa al **76%** di caselle con un padrone.

**Da dichiarare:** i Consigli falliti sono passati da 185 a 191, 196, **203** in
tre modifiche di fila. Il vincolo 0/8 regge, ma il numero si muove sempre nella
stessa direzione e alla prossima va guardato per primo.

### Fixed

- **La torre di partenza copriva la reggia ereditata.** `BUILD_STRUCTURE` e' un
  no-op se il tipo c'e' gia' e il setup gira prima dell'eredita': una reggia
  dell'anno prima tornava una torre. L'eredita' adesso abbatte e rialza.
- Due test misuravano una mappa vuota che non esiste piu' (uno cercava «la prima
  `BUILD_STRUCTURE`», l'altro incontrava `TGR_WATCHTOWER_FORCE` e la chiamava
  telaio). Nessuno dei due era un difetto del gioco.
- Di nuovo il passo dei due artefatti generati: schema aggiornato,
  `gen_gd_schema.py` dimenticato, playtest morto con «unexpected field».

Suite **334 test / 5977 asserzioni** verde, sims deterministiche.

---

## [0.1.125] — La contesa del controllo

Il padrone di una Regione non e' piu' **scritto** ma **contato**
([D-158](docs/DECISIONS.md#d-158), §7.2 della seduta sulla terra): chi somma di
piu' fra il valore delle proprie strutture e le proprie pedine, a ogni fine
round.

### Added

- **`control_rules.contested`** nella Chronicle: la contesa, con il peso della
  pedina dichiarato nei dati. Omessa, il gioco e' quello di prima.
- `control_strength`, `strongest_in` e `rightful_holder` nel servizio del mondo;
  il riconteggio a fine round nel controller, che passa da un `SET_CONTROL`
  normale — stesso Effect, stesso inverso, stessa riga nel registro.
- **`tests/unit/test_control_contest.gd`**, sette test: le due monete che si
  sommano, il castello che perde contro l'esercito piu' grande, il pareggio che
  non cambia niente, e la regola che si spegne dai dati.

### Measured

Sessanta Chronicle a tavolo misto — **la mappa si e' mossa**:

| | prima | ora |
|---|---|---|
| caselle con un padrone | 56% | **76%** |
| seggi a **zero** Regioni | 30% | **15%** |
| seggi con **due** Regioni | 12% | **25%** |

- **Il Vetro passa da 0,00 a 1,00.** La casa che in trenta partite non aveva mai
  tenuto una Regione adesso ne tiene una — non perche' gliel'abbiano data, ma
  perche' sta da qualche parte.
- Playtest **FAIL 196 · SUCC 68 · SUCC 116 · DECI 186**, tavolo misto **0 su 8**,
  tavolo uniforme **3/8 → 2/8**.
- **`control_count >= 2` sparisce dalle clausole mancate.** In cima restano le
  **clausole sociali** — «qualcuno ha giurato» 70%, «l'insediamento e'
  riconosciuto» 57% — che e' la seconda famiglia di D-151 e chiede persone.

### Changed

- **`lapse_without_presence` diventa un caso particolare del conto**: chi non ha
  niente li' somma zero, e zero non tiene niente.
- **Il Consiglio da' un titolo, tenerlo e' un'altra cosa**: le 14 Conseguenze che
  scrivono un nome valgono finche' quel nome regge il conto. Non riscritte — la
  misura dice che cosi' funzionano.

Suite **334 test / 5981 asserzioni** verde, sims deterministiche, `dead_code.py`
pulito su 151 file.

---

## [0.1.124] — La terra si costruisce

Primo passo della strada C ([D-157](docs/DECISIONS.md#d-157)): **una struttura
smette di essere un tag e diventa un oggetto**. E' il livello su cui sta tutto
il resto del catalogo.

### Added

- **`schema/structure_type.schema.json`**: il catalogo. Un tipo dichiara la
  famiglia (PRESIDIO · INSEDIAMENTO · OPERA · LUOGO · CHIUSURA), se ha un
  padrone, in quali biomi puo' stare, i **gradi** — ognuno con nome, **valore** e
  il segno che posa — e come finisce in rovina.
- **`world.regions[id].structures`**: una lista di `{structure_type, grade,
  owner}`.
- **Tre Effect nuovi**, coi loro inversi: `BUILD_STRUCTURE` ↔ `RAZE_STRUCTURE`,
  e `SET_STRUCTURE_GRADE` che si inverte su se stesso col grado di prima.
  L'enum chiuso passa da **22 a 25**.
- **Le pietre attraversano gli anni**: l'eredita' le riporta com'erano — una
  reggia resta una reggia — e il padrone segue `lapse_without_presence`: senza
  nessuno dentro, restano di nessuno.
- **Il catalogo parte col Presidio**: Torre di veglia (2) → Castello (3) →
  Reggia (5), e la Rovina che lascia `scar:abandoned`.
- **`tests/unit/test_structures.gd`**, otto test sul meccanismo.

### Changed

- **L'oggetto e' la verita', il tag e' derivato**: ogni grado dichiara il proprio
  `structure:`, e alzarlo o abbatterlo posa e toglie quel segno. Le **cinque
  regole dei segni** gia' scritte continuano a funzionare senza sapere che sotto
  e' cambiato tutto.

### Measured

- **Nessun dato del gioco costruisce niente**, e il playtest e' **identico** a
  0.1.122: **FAIL 191 · SUCC 69 · SUCC 116 · DECI 190**, tavolo misto **0 su 8**.
  Un livello nuovo che non muove un numero e' un livello che non ha ancora
  opinioni.
- Suite **327 test / 5996 asserzioni** verde, `run_sims.sh` identico su due
  giri, `dead_code.py` pulito su 150 file.

### Fixed

- Due difetti presi dalla suite e non a mano: una `x-echoes-kind` inventata
  faceva **sparire lo schema dal registro di Godot** (288 test rossi in un
  colpo), e il guardiano di D-003 ha rifiutato i tre Effect nuovi finche' non
  hanno avuto il loro test di andata e ritorno.

---

## [0.1.123] — Il catalogo delle strutture

«Le strutture pero' come ti ho detto mi sembrano pochi e solo 5.» Contate bene
sono meno.

### Measured

- **Quattro costruzioni**, non cinque: granaio, canale, barriera di pedaggio,
  torre di veglia. La quinta, `structure:sealed`, non e' un edificio — e' il
  **contrario** di un edificio.
- **Due insediamenti** (`settlement:march`, `settlement:market`) in una famiglia
  parallela quasi inutilizzata, piu' uno che e' solo una casella da riempire.
- **Zero luoghi naturali**, e sei biomi (citta', valle, steppa, montagna,
  sottosuolo, strada) che non hanno niente che li distingua se non un tag
  decorativo.

### Added

- **`docs/SEDUTA_TERRA.md` §8, il catalogo.** Da cinque tag a **una ventina di
  cose** che possono stare in una Regione, ognuna con un numero, un effetto e un
  modo di finire.
- **Il principio che lo tiene insieme**: non tutto quello che sta su una mappa
  appartiene a qualcuno. **Le opere delle case** (presidio: torre → castello →
  reggia · insediamento: villaggio → borgo → citta' · opere: canale, granaio,
  pedaggio, ponte) hanno un padrone e un valore nella contesa del controllo.
  **I luoghi del mondo** (foresta, passo, fiume, sito antico, palude) non sono di
  nessuno: cambiano *cosa vale* una Regione senza cambiare *chi la tiene*.
- **Il passo che frana** e' segnalato come il pezzo piu' pesante: le adiacenze
  sono oggi l'unica cosa della mappa che non cambia mai, e un passo chiuso
  riscrive il grafo. Va scritto per ultimo, e misurato con attenzione — un grafo
  spezzato puo' rendere un Destino impossibile.
- **L'ordine di scrittura** in cinque passi, ognuno misurato sui 100 semi e
  vincolato a **0/8** al tavolo misto.

Nessuna modifica al gioco: e' un dossier.

---

## [0.1.122] — La porta sola della Cenere

ISSUES 38, che il committente ha chiesto di chiudere prima della strada C
([D-156](docs/DECISIONS.md#d-156)).

### Measured (prima di scrivere)

Sedici clausole candidate valutate a fine anno su **40 Chronicle** di CHR_03:
sette valgono il **100%** — fra cui **`control_count >= 1`**, che spiega perche'
in D-154 abbassare la soglia regalava a Kessa la Vittoria — mentre l'unica
davvero contesa era **`ash_watch`, la veglia sulla montagna, al 45%**.
`control_count >= 2` valeva il **12%**.

### Changed

- **`DST_CENERE` riscritto.** La Vittoria era «Tengono la montagna, e non solo
  quella» (control ≥2 · gallerie non murate, cioe' **una porta e una
  decorazione**) e non diceva quello che questa casa vuole. Adesso e' **«Chi
  scava lo dicono loro»**: la montagna e' ancora loro · **e la veglia e'
  affidata a loro, per atto e non per abitudine** · e le gallerie non sono state
  murate.
- **Il controllo di due Regioni e' salito al Trionfo** — «E non solo quella» —
  dove il suo 12% e' una virtu' invece che un muro. E' il principio di D-152
  applicato per intero: **la Vittoria chiede di tenere, il Trionfo di crescere**.

| Kessa dei Fuochi, 50 partite | NONE | MINIMO | VITTORIA | TRIONFO |
|---|---|---|---|---|
| prima | 1 | **44** | 5 | 0 |
| adesso | 0 | 18 | **31** | 1 |

### Measured (dopo)

- Tavolo misto **0 su 8**. Sessanta Chronicle: supera il Minimo **48% → 54%**,
  VITTORIA 43% → **48%**, TRIONFO 5% → **6%**.
- **Il prezzo, dichiarato:** Consigli falliti **177 → 191**, tavolo uniforme da
  2 a 3 seggi bloccati. La Cenere adesso **si batte** per la veglia, e un tavolo
  dove una casa in piu' ha qualcosa da difendere litiga di piu'.
- **Lezione di metodo:** `ash_watch` valeva il 45% quando nessuno lo cercava, e
  vale il **63%** da quando e' una clausola di Vittoria. Una clausola diventa
  piu' facile nel momento in cui diventa un obiettivo — la misura preventiva
  dice quali porte esistono, non quanto saranno larghe dopo.
- **Trovato per strada:** «col Vetro non si e' arrivati alla rottura» vale
  **0% su 40 partite**. Cenere e Ordine del Vetro partono NEMICI e non risalgono
  mai: terza volta che le relazioni ferme si presentano da una porta diversa
  (D-139, D-151).

**ISSUES 38 e 38bis chiuse**, e la strada C della seduta sulla terra e'
sbloccata.

### Fixed

- **`docs/ASSET_MANIFEST.md` rigenerato.** E' un artefatto derivato e porta le
  etichette dei gradini di ogni Destino: la nuova Vittoria della Cenere lo aveva
  disallineato e la CI lo ha bocciato. La regola di casa parlava solo di
  `gen_gd_schema.py`: gli artefatti generati sono **due**.

---

## [0.1.121] — Le carte parlano

Difetto trovato dal committente giocando ([D-155](docs/DECISIONS.md#d-155)):
«le frasi sono belle ma non si capiscono e alla fine non hanno effetti sul
gioco». Gli effetti c'erano — **39 carte del Narratore su 39** ne portano almeno
uno. Era la carta a essere muta.

### Added

- **`scripts/core/echo_text.gd`**: cosa fa una carta del Narratore, prima di
  calarla. Titolo, tono della famiglia drammatica («stringe, rompe, svolta,
  chiude, ricorda») e gli effetti uno per uno, compreso **se apre un Consiglio**.
  Composto dai campi che il motore legge davvero, come `asset_text.gd`.
- **`tests/unit/test_card_speech.gd`**: nessuna carta muta, nessun
  identificativo grezzo davanti a chi gioca, e i segni detti in italiano.

### Fixed

- **La mappa parlava in identificativi.** `Valle Verde: condition:lean` diventa
  «Valle Verde: il raccolto non basta». **31 segni** hanno una frase, e una
  **seconda** per quando spariscono («la fame e' passata», «il granaio non c'e'
  piu») perche' «non piu si muore di fame» non e' italiano.
- `SET_ENTITY_TAG` e `REMOVE_ENTITY_TAG` non stampano piu' il tipo grezzo.
- **Le caselle da riempire** in anteprima diventano parole: `$rival` e' «un
  rivale», `$region_focus` «la Regione della domanda».
- **`SET_RELATION` non risolveva nessuno dei due lati** della coppia: diceva
  `$proponent / $rival`. Trovato dal test nuovo, non a mano — sfuggiva perche'
  nessuno guardava mai quella frase in anteprima.

Suite **319 test / 5959 asserzioni** verde, `dead_code.py` pulito su 149 file.
Nessuna regola cambiata: il gioco fa quello che faceva prima, e adesso lo dice.

---

## [0.1.120] — La seduta sulla terra

Tre idee del committente arrivate una dopo l'altra sono la stessa domanda vista
da tre lati: **come si rende visibile, costoso e duraturo il possesso di un
luogo?** Il dossier le mette accanto una volta sola invece che tre.

### Added

- **`docs/SEDUTA_TERRA.md`**: le tre strade coi loro prezzi — **A** le carte che
  posano una pedina, **B** la carta che *e'* la presenza, **C** le strutture con
  una vita (torre → castello → reggia, la rovina, la demolizione). Raccomandata
  **C**, con **A** come primo passo, e **ISSUES 38 prima di tutto**.

### Measured

- **Le strutture funzionano gia' meglio della presenza.** Su 30 Chronicle:
  **74 alzate** (2,5 a partita), **2,00 in piedi** a fine anno, **29 partite su
  30** ne hanno almeno una — contro poco piu' di **una pedina** mossa per scelta.
- **Zero abbattute in 30 anni giocati.** Una struttura oggi e' un interruttore
  che si accende e non si spegne, e `structure:` attraversa le Chronicle **senza
  sbiadire** (a differenza di `condition:`): in una saga la mappa puo' solo
  riempirsi. E' il difetto che l'idea del committente corregge da se'.
- Il pedaggio da solo e' **48 delle 74**, e lo posa un **Asset**
  (`AST_WEALTH_TOLL`): la carta che costruisce esiste gia', ed e' una sola.
- Gia' oggi 11 carte posano una struttura, **5 regole dei segni** le leggono, e
  tre Asset posano una pedina di presenza.

### Changed

- **ISSUES 39** riscritta come voce di seduta, con la strada A conservata per
  esteso come primo passo.

Nessuna modifica al gioco.

---

## [0.1.119] — Il peso della terra: meccanismo acceso, contenuto spento

Il committente ha deciso che **il titolo deve dare qualcosa dentro l'anno**
([D-154](docs/DECISIONS.md#d-154)). La leva e' scritta e provata; **nei dati e'
spenta**, e la ragione e' un numero.

### Added

- **`focus_weight`** in `confluence_rules`: al Consiglio, la Regione di cui si
  discute da' voce a chi ci sta — **il titolo** a chi ne e' il padrone, **la
  maggioranza** a chi ci ha strettamente piu' pedine (a parita', nessuno). I due
  si sommano fino a un tetto, e contano solo se quel seggio ha impegnato almeno
  una carta.
- **`tests/unit/test_focus_weight.gd`**: sette test che tengono fermo il
  meccanismo con una regola sintetica, visto che nei dati e' omessa.

### Measured

| | Consigli falliti | tavolo misto |
|---|---|---|
| spento | **177** | **0 su 8** |
| titolo +1, maggioranza +1, a tutti | **164** | **1 su 8** |
| lo stesso, senza il proponente | 175 | **1 su 8** |

- **Il peso finiva al proponente**, che e' gia' scelto *per* la presenza: pagato
  due volte per lo stesso investimento, e i Consigli passavano troppo.
  Escluderlo rimette i numeri in banda.
- **Resta 1 su 8, e il seggio e' sempre Kessa** — non per il peso della terra ma
  perche' la sua Vittoria ha una porta sola (ISSUES 38). La differenza e'
  letteralmente **una partita**. Il vincolo 0/8 lo sta facendo rispettare il
  seggio piu' fragile del gioco.
- **Chi muove le pedine, su 30 Chronicle**: 240 posate al setup, **38** da
  MUOVERE, 21 da una carta, 7 da un Consiglio. Poco piu' di una pedina per
  partita si muove per scelta. La mappa non e' ferma perche' il titolo non
  paga — e' ferma perche' **nessuno ha carte con cui muoverla**.

### Changed

- **ISSUES 39** (nuova, voluta dal committente): le carte che posano una pedina.
  Il vocabolario esiste gia' ma e' quasi spento — 5 Asset su 48, e nessuno nelle
  famiglie FORZA e GENTE. Due strade: estendere le carte, oppure far si' che la
  carta **sia** la presenza.
- **ISSUES 38bis**: nota di metodo — ISSUES 38 va aperta prima di provare altre
  leve sul Consiglio.

Suite **312 test / 5943 asserzioni** verde. Playtest con la regola spenta
identico a 0.1.118: **FAIL 177 · SUCC 73 · SUCC 126 · DECI 187**, misto **0/8**.

---

## [0.1.118] — La presenza fa, il controllo conta

Domanda del committente sulla meccanica appena scritta: «prendere una Regione
cosa significa? Non basta avere una presenza?». Il documento non lo diceva, e
l'infografica sarebbe venuta sbagliata.

### Fixed

- **`docs/MECCANICA.md`** ha una sezione nuova, *Presenza e controllo: la
  distinzione che conta*, con le due liste affiancate. E le note per chi disegna
  avvertono dell'errore che un'infografica fa da sola: disegnare la mappa come
  una mappa di conquista.

### Measured

Cercato ogni punto del codice che legge `control`. I consumatori sono **tre**,
piu' la prosa e il disegno:

- `control_count` — **14 clausole di Destino**;
- la **sovraestensione** — oltre 2 Regioni, +1 di Tensione a round: un **costo**;
- il **passaggio all'anno dopo**, e solo se ci si sta dentro.

Il controllo **non** decide chi propone al Consiglio (e' la presenza), non
sblocca azioni, non piega la pesca, non vale un punto nel margine. **Dentro
l'anno non da' nessun vantaggio meccanico.**

La presenza invece comanda: chi propone, l'INFLUENZARE gratuito, l'ACQUISIRE
potenziato, dove si puo' MUOVERE, le regole dei segni con `scope: REGION`, e 16
clausole di Destino.

### Changed

- **`docs/ISSUES.md` 37** raccoglie la seconda meta' della diagnosi: la catena
  di `ACT_CLAIM` non e' solo lunga, **e' lunga e non porta a niente di
  immediato** — ecco perche' 48 rivendicazioni su 63 muoiono in mano. E aggiunge
  la domanda che viene prima delle quattro strade: **se il titolo debba dare
  qualcosa dentro l'anno**, che e' design e non taratura.

Nessuna modifica al gioco.

---

## [0.1.117] — La meccanica, tutta in un foglio

### Added

- **`docs/MECCANICA.md`**: la spiegazione completa e autosufficiente di come si
  gioca — struttura del tempo, mappa, casate, Tensioni, le sette azioni, il
  Consiglio A→K con la matematica, le carte, i Destini, la saga. Scritta perche'
  chi non ha mai visto il gioco lo capisca, e perche' si possa passare a un
  altro strumento per farne un'infografica: chiude con una sezione di note su
  cosa merita un riquadro e cosa si puo' omettere.
- Tutti i numeri sono letti dai dati e dal codice, non ricordati: 6 Regioni con
  8 adiacenze, 4 Tensioni su 6 per mondo, 132 carte Asset in 48 tipi, 39 carte
  Narratore in 5 famiglie e 24 funzioni, 52 Conseguenze (14 cambiano padrone a
  una Regione), 10 modelli di Consiglio, 45 regole dei segni, 22 tipi di
  effetto.

---

## [0.1.116] — «Rivendicare» esiste

Correzione a 0.1.115, sollevata dal committente: «ma scusa, le Regioni non si
prendono con un'azione specifica?». Sì ([D-153](docs/DECISIONS.md#d-153)).

### Fixed

- **La frase di D-152 era fuorviante.** `ACT_CLAIM` («Rivendicare») esiste. Non
  prende una Regione: apre un Claim su un **dominio di Tensione** scartando un
  Asset AUTHORITY, e in un round successivo lo consuma con un secondo AUTHORITY
  per **strappare un Consiglio da proponente**. La Regione arriva se quel
  Consiglio cade su una delle 14 Consequence con `SET_CONTROL` a `$proponent`.
- `docs/ISSUES.md` 37 riscritta sulla premessa giusta, README aggiornato.

### Added

- **`cli/run_rung_probe.gd`** conta i tre numeri della catena: rivendicazioni
  aperte, Consigli strappati, rivendicazioni morte in mano.

### Measured

- Su 60 Chronicle: **63 rivendicazioni aperte, 15 forzate, 48 morte senza
  essere usate**. Tre su quattro si pagano e non si spendono — la catena si
  spezza al terzo dei suoi cinque anelli.
- In trenta Chronicle `ACT_ACQUIRE` produce **4286** effetti e `ACT_CLAIM`
  **84**: le case raccolgono, non rivendicano.
- Nessuna modifica al gioco. Playtest invariato — **FAIL 177 · SUCC 73 ·
  SUCC 126 · DECI 187**, tavolo misto **0/8**. Suite **305 verde**.

---

## [0.1.115] — La corona tiene la sua terra

La prima delle due decisioni che D-151 aveva rimandato al committente
([D-152](docs/DECISIONS.md#d-152)): abbassare una soglia. La misura ne ha
approvata una e respinta l'altra.

### Changed

- **`DST_ALDRIC`, vittoria**: `control_count min 2` -> `min 1`, etichetta da
  «Controllo di almeno 2 Regioni» a **«La corona tiene ancora la sua terra»**.
  Con `lapse_without_presence` attivo, «almeno una» non e' gratis: il 30% dei
  seggi finisce l'anno senza nessuna Regione.
- Re Aldric, 50 partite: da **0/43/5/2** (NONE/MINIMO/VITTORIA/TRIONFO) a
  **1/24/17/8**. Il suo ostacolo adesso e' la Carestia, non la terra.

### Added

- **`cli/run_rung_probe.gd`** misura anche il tabellone: quante Regioni tiene
  ogni seggio a fine anno, quante caselle restano senza padrone, e quante
  passano di mano in gioco.

### Measured

- **La mappa quasi non si muove**: 0 Regioni per il 30% dei seggi, 1 per il
  57%, 2 per il **12%**, 3 per l'1%. Il **44% delle caselle non e' di
  nessuno**. Il controllo non si prende con un'azione: passa solo per una
  Consequence, cioe' per un Consiglio che si chiude.
- In un anno una casa guadagna in media **un quarto di Regione**. Il Vetro non
  ne tiene **mai** una in trenta partite; le Citta' Libere scendono da 1,00 a
  0,67.
- **Correzione a D-151**: `max_stable_control: 2` non e' un tetto ma una
  soglia di fatica (D-027), e nessuno la tocca — tre seggi su 240 tengono tre
  Regioni. Non era quello il vincolo.
- **Respinta**: la stessa modifica sulla Cenere porta Kessa a **zero Minimi su
  cinquanta** e 30 Trionfi. La sua soglia reggeva anche il gradino sopra;
  resta a 2.
- Playtest 100 semi da 7000: **FAIL 177 · SUCC 73 · SUCC 126 · DECI 187**;
  tavolo misto **0/8**; tavolo uniforme **3/8 -> 2/8**. Suite **305 verde**,
  `run_sims.sh` e `run_export.sh` deterministici.

---

## [0.1.114] — I gradini

La diagnosi per clausola ([D-151](docs/DECISIONS.md#d-151)): non «la Vittoria
e' difficile» ma **quale clausola** non si avvera.

### Added

- **`cli/run_rung_probe.gd`**: sessanta Chronicle a tavolo misto, e per ogni
  Destino quante volte ogni singola clausola resta in sospeso.

### Measured

- NONE 0% · MINIMUM **52%** · VICTORY **42%** · TRIUMPH **5%**; supera il
  Minimo il **47%** (nelle saghe era il 30%: una Chronicle che eredita un
  mondo segnato e' piu' dura di una sul foglio pulito).
- **`control_count >= 2` chiede il tetto**: `max_stable_control` e' 2, su sei
  Regioni divise fra quattro case. La Cenere manca quella clausola nell'87%
  delle partite, Aldric nel 63%.
- **Le clausole che dipendono da un altro non si avverano mai**: «qualcuno ha
  giurato» manca nel 77%, «la Gilda non e' diventata un nemico» nel 90%. Sono
  5 clausole su 104 — e in venti Chronicle le relazioni si muovono **una volta
  sola**. Chiude il cerchio di D-139: il peso dell'alleanza e' raro perche'
  nessun bot stringe alleanze.

### Notes

- **Non e' stato toccato niente**: e' una diagnosi. Abbassare una soglia e'
  contenuto d'autore; misurare le clausole sociali richiede persone, non semi.

---

## [0.1.113] — Il pool dei Destini (meccanismo acceso, contenuto spento)

La strada A della seduta sulle linee ([D-150](docs/DECISIONS.md#d-150)): il
meccanismo c'e' e si prova, **nelle Chronicle e' spento** perche' la misura ha
detto di no.

### Added

- **`destiny_pool`** sulla Chronicle: per ogni casa, i Destini fra cui l'anno
  pesca. E' `tension_pool` applicato agli obiettivi; omesso, non cambia niente.
- **Il dado dei Destini e' a parte** (come i caratteri in D-051): accendere il
  pool cambia cosa la gente vuole, **non che mondo trova**.
- Quattro test, e uno prova proprio quello: coi pool accesi le domande e i
  mazzi restano identici.

### Changed

- Il banco di prova **neutralizza la pesca**: `new_session` rimette a ogni casa
  il Destino scritto. Dieci test erano diventati rossi il giorno in cui il pool
  si e' acceso, tutti perche' davano per scontato cosa una casa volesse.

### Measured

- **Coi pool accesi il playtest esce di banda**: Consigli falliti **222**
  (contro 185) e **2 su 8** seggi bloccati al tavolo misto (contro 0). Gli otto
  Destini alternativi sono contenuto scritto ai tempi di D-111 e **mai
  giocato**: vanno accesi uno per volta, misurando.
- La varieta' pero' risponde: prima linea a **distanza 0,89** (da 0,81), 84
  frasi distinte (da 74), Trionfi **15** (da 11).
- Coi pool spenti: playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**,
  tavolo misto **0 su 8**; suite **305 test / 6202 asserzioni** verde; sims
  deterministici.

### Notes

- **Il Minimo di ogni Destino e' «esistere»** — due coppie ce l'hanno identico
  parola per parola. Non e' un obiettivo, e' una soglia di sopravvivenza: la
  misura giusta per ISSUES 35 non e' la colonna MINIMUM ma **quanti la
  superano**, ferma al 30% col pool e senza.

---

## [0.1.112] — La distanza fra due saghe

La misura che mancava prima di aggiungere varieta'
([D-149](docs/DECISIONS.md#d-149)).

### Added

- **`cli/run_variety_probe.gd`**: quanto si somigliano due saghe, misurato
  sulle **Truth** — le frasi che restano scritte nel registro. Frasi
  distinte, **nocciolo** (quelle presenti in tutte le saghe) e **distanza**
  media fra due saghe qualsiasi. A tavolo misto (D-053).

### Measured

- Cinque saghe da sei Chronicle: **distanza 0,81** sulla prima linea, **0,79**
  sulla seconda; nocciolo **2 frasi**; 10 vite su 14 viste al tavolo.
- **Il 64% dei Destini finisce al Minimo** sulla prima linea, il 52% sulla
  seconda: le storie sono gia' diverse, **gli obiettivi no**.

### Fixed

- Due difetti di misura presi prima di fidarsi del numero: la distanza usciva
  **1,00** perche' le frasi portano dentro l'anno e il punteggio (misurava
  l'orologio, non la storia); e le vite erano contate su un campo che non
  esiste (`incarnation_id` invece di `incarnation`) — quattro in trenta
  Chronicle, un numero che non tornava guardando le saghe raccontate.

---

## [0.1.111] — La saga del Sale

Una saga intera sull'altra linea, raccontata
([SAGA_SALE.md](docs/SAGA_SALE.md)), e il confronto con la prima.

### Added

- **`docs/SAGA_SALE.md`**: dieci Chronicle sulla linea delle citta'
  (1640–2355, seme 1204, CHR_03 poi CHR_04), anno per anno.

### Measured

- **La saga dell'812 rigiocata oggi e' identica** — anno per anno, nome per
  nome, livello per livello. Di tutto il lavoro da 0.1.101 in poi l'unica
  cosa che tocca il motore e' il peso dell'alleanza (D-139), e quel dente ha
  morso **una volta sola in dieci Chronicle** (nel Consiglio del 1057, senza
  cambiarne l'esito). Nella saga del Sale: **mai**.

### Notes

- ISSUES 35 aperta: nella seconda meta' della saga del Sale i Consigli
  continuano a riuscire e i Destini smettono di avanzare — **sedici Minimi su
  venti** da quando le istituzioni sostituiscono le persone. Da misurare a
  tavolo misto prima di toccare qualsiasi cosa.

---

## [0.1.110] — Il ritardatario

Chi si collega a partita cominciata adesso lo sa
([D-148](docs/DECISIONS.md#d-148)).

### Added

- **`ConsoleHost.seated()` e `watching()`**: la stanza dichiara chi gioca al
  via, e chi si aggancia dopo riceve una riga che gli dice che il suo seggio lo
  sta giocando la policy e che da li' puo' guardare. Prima lo scopriva dal
  silenzio — identico a un filo rotto.
- Un test: prima del via nessuno guarda soltanto; dopo, chi non c'era guarda e
  chi c'era gioca.

### Measured

- Suite **301 test / 6145 asserzioni** verde; filo **trasparente byte per
  byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto
  **0 su 8**, invariato.

### Notes

- Un seggio lasciato alla policy resta alla policy fino a fine Chronicle:
  prenderselo a meta' partita e' la console di riserva rovesciata, e aspetta
  nello stesso posto — dopo la prova.

---

## [0.1.109] — Quanti giocatori, e i bot alla prova

Le tre domande del committente sul numero di giocatori e sui bot
([D-147](docs/DECISIONS.md#d-147)).

### Added

- **Il menu chiede chi altro gioca da questo schermo**: scelto il proprio
  seggio, «siete in N, qualcun altro?» finche' il tavolo e' pieno o qualcuno
  dice basta. La riga di comando e la stanza lo sapevano gia' fare; il menu
  offriva uno solo dei quattro modi.
- **`cli/run_bot_probe.gd`**: i bot contro il caso, sullo stesso mondo giocato
  due volte. Il punteggio e' il **Destino raggiunto**, non i Consigli vinti.

### Measured

- **I bot giocano**: su 40 partite la policy fa meglio in **26**, peggio in 2,
  pari in 12 — media **1,65 contro 0,57**. Il caso manca il Destino minimo in
  **20 partite su 40**; la policy **mai**.
- Playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo misto **0 su
  8**, invariato; suite **300 test / 6141 asserzioni** verde.

### Notes

- **I seggi sono quattro e non e' un'impostazione**: ogni Chronicle dichiara
  le sue quattro case, e domande, relazioni, Destini e proposizioni sono
  scritti per quelle voci. Un tavolo a tre o a cinque e' un'altra Chronicle da
  scrivere, non una casella da spuntare.

---

## [0.1.108] — I pezzi si muovono sulla mappa

La console ripensata come l'ha chiesta il committente
([D-146](docs/DECISIONS.md#d-146)): schede, telefono coricato, e la mappa che
risponde alle domande.

### Added

- **Le mosse si giocano sulla mappa**: la console prende `/mappa.svg` inline,
  le Regioni che la domanda offre si accendono col cerchio d'oro e il tocco
  risponde. I `subjects` arrivavano al telefono da sempre — nessuno li
  guardava.
- **Tre schede** (Mappa · Mano · Seggio) con un pallino sulla linguetta che ha
  qualcosa, invece di una colonna sola da scorrere.
- **Il telefono coricato affianca** schede e domanda invece di impilarle:
  mappa a sinistra, scelte a destra, niente da scorrere per giocare.
- Ogni Regione nel tabellone porta il suo id (`data-region`) e il cerchio
  «raggiungibile», spento nel disegno e acceso dalla console.

### Changed

- Le scelte che si giocano sulla mappa **non** compaiono anche come bottoni:
  due strade per la stessa mossa vogliono dire che una delle due e' sbagliata.
  Delle 18 scelte di un'azione, 4 vanno sulla mappa e 14 restano in elenco.

### Fixed

- `main` era `display: flex` senza direzione, e in CSS il flex e' una riga:
  in piedi la barra della domanda si metteva **di fianco** alla mappa e se la
  mangiava. Una fotografia l'ha trovata in un secondo.

### Measured

- Sonda dei messaggi **20.844 perquisiti, FUGHE 0**; filo **trasparente byte
  per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo
  misto **0 su 8**; suite **300 test / 6141 asserzioni** verde.

### Notes

- Un token, una console: due pagine aperte con lo stesso codice se lo
  contendono. Al tavolo un seggio ha un telefono solo, quindi non morde.

---

## [0.1.107] — Il tabellone disegnato

La mappa vera sulla vetrina, con pedine e vessilli, e le carte giocate in
tavola ([D-145](docs/DECISIONS.md#d-145)).

### Added

- **`board_sheet.gd`** e `/mappa.svg` serviti dall'host: il tabellone
  disegnato dagli **stessi piani** del canvas — `RegionArt.plan` per le
  tessere e il terreno, `IconSet` per pedine e vessilli, i colori dei seggi
  dall'ordine di turno. Una forma sola, tre usi: canvas, fustella, browser.
- **Le carte impegnate in Consiglio** sulla vetrina, con la faccia e il
  fronte su cui sono cadute — dai Consigli **chiusi**, perche' gli impegni si
  rivelano tutti insieme in seduta (D-014).
- Una guardia nella perquisizione della vetrina: nessun Consiglio **ancora
  aperto** puo' comparire in tavola.
- Quattro test sul tabellone (ogni Regione col suo nome, una pedina per
  presenza, i colori dei seggi che non si ripetono, nessuna mano).

### Fixed

- Il tabellone dentro la griglia delle Regioni diventava una cella larga come
  un riquadro: sta fuori, e i riquadri restano sotto per l'ispezione al tocco.

### Measured

- Sonda dei messaggi: **20.844 perquisiti, FUGHE 0**; filo **trasparente byte
  per byte**; playtest **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**, tavolo
  misto **0 su 8**; suite **300 test / 6141 asserzioni** verde; sims ed export
  deterministici.

### Notes

- La prima stesura della guardia confrontava il **titolo** della domanda e ha
  dato **58 fughe false**: la stessa domanda torna al Consiglio piu' volte.
  Terza volta che il confronto per nome inganna (658 in D-135, 54 in D-144):
  un titolo non e' un'identita'. Ora confronta il `confluence_id`.

---

## [0.1.106] — Le carte vere, e la mano che il tavolo leggeva

Le carte come carte sul telefono e sulla vetrina — e la fuga che le facce
hanno reso visibile ([D-144](docs/DECISIONS.md#d-144)).

### Added

- **`/carta/<mazzo>/<id>.svg`** servito dall'host, da `PrintSheet.card_svg`:
  la stessa funzione che impagina i fogli da fustellare e che l'app
  rasterizza per la mano sullo schermo. Sul telefono la mano sono **carte da
  toccare** (un tocco le ingrandisce); sulla vetrina compaiono le carte del
  Narratore che il mondo ha calato.
- **`Protocol.audit_table`**: la perquisizione della vetrina, col metro del
  tavolo invece che di un seggio. Gira nella sonda dei messaggi accanto alle
  console.
- Due test: la mano del Narratore non sta sul tavolo, e la guardia **morde**
  (uno pianta una fuga apposta).

### Fixed

- **La vetrina svelava le mani del Narratore.** `echo_deck.drawn` e' tutto
  cio' che il mazzo ha lasciato, comprese le carte ancora in mano ai seggi, e
  la vetrina lo mostrava come «il mondo ha calato». Presente da 0.1.99;
  adesso calata e' una carta uscita dal mazzo e non piu' in nessuna mano.

### Changed

- La mano nel modello della console porta l'`id` (serve per chiedere la
  faccia), e la perquisizione confronta gli **id** invece dei titoli: l'id e'
  la carta, il titolo e' come la chiamiamo.

### Measured

- Sonda dei messaggi: **20.844 perquisiti** (17.509 console + 3.335 vetrine),
  **FUGHE 0**.
- Filo **trasparente byte per byte**; playtest **FAIL 185 · SUCC 76 · SUCC
  123 · DECI 178**, tavolo misto **0 su 8**; suite **296 test / 6121
  asserzioni** verde; sims ed export deterministici.

### Notes

- La prima stesura di `audit_table` cercava anche i titoli nel testo e ha
  consegnato **54 fughe tutte false** («la vetrina nomina "Sale", che e' in
  mano a Kessa» — «Sale» e' una carta *e* una casa). E' la lezione di D-135,
  imparata due volte: il metro giusto e' strutturale.

---

## [0.1.105] — Guardare il telefono

I due difetti trovati fotografando la console su uno schermo da telefono
([D-143](docs/DECISIONS.md#d-143)).

### Added

- **`cli/run_room.gd`**, la stanza senza schermo: stesso `ConsoleHost` e
  stesso `SeatDecider` della stanza vera, stampa un indirizzo per seggio e
  aspetta i telefoni. Serve a provare la console da un altro apparecchio
  senza aprire una finestra — e a fotografarla con un browser vero.
- Gli screenshot in `docs/img/`.

### Fixed

- **Il pannello a caratteri non va piu' al telefono**: la console riceve gia'
  lo `state` strutturato e ne disegna sezioni vere, quindi il tabellone del
  terminale era la stessa cosa detta due volte, in cima allo schermo piu'
  piccolo. Un io che dichiara `shows_state()` non lo riceve; terminale e
  schermo del tavolo tacciono e continuano a leggerlo. **3.600 messaggi in
  meno su 100 partite.**
- **Le scelte oltre il bordo si vedono**: `overscroll-behavior: contain`
  perche' il dito non scorra la pagina sotto, due ombre in CSS puro che
  compaiono solo quando c'e' altro, e il conto scritto («22 scelte — scorri
  per vederle tutte»).

### Changed

- La sonda dei messaggi dichiara `shows_state()` come la console vera:
  contava messaggi che non partono piu'.

### Measured

- Sonda dei messaggi: **17.509 messaggi, FUGHE 0** (erano 21.109 col
  pannello a caratteri).
- Filo ancora **trasparente byte per byte**; playtest **FAIL 185 · SUCC 76 ·
  SUCC 123 · DECI 178**, tavolo misto **0 su 8**; suite 294/6117 verde.

### Notes

- Ventidue opzioni per un'azione sono tante su qualunque schermo, ma quella e'
  una domanda di design del gioco e si decide al tavolo.

---

## [0.1.104] — L'app da scaricare

L'app vera per chi ospita il tavolo ([D-141](docs/DECISIONS.md#d-141)),
chiesta dal committente.

### Added

- **Preset di export macOS** (universale Intel + Apple Silicon) e il lavoro
  **`desktop`** in CI: `ECHOES.zip` allegato a ogni run, scaricabile da
  Actions senza avere Godot installato.
- **`include_filter="web/*"`**: `console.html` e `tavolo.html` non sono
  risorse che Godot importa, quindi `all_resources` non le vedeva. Senza
  questa riga l'app si costruiva, si apriva, apriva la stanza — e serviva una
  pagina vuota ai telefoni.
- **La CI non si fida del preset**: apre il pacchetto, trova il `.pck` e
  cerca dentro i nomi delle due pagine. Rossa prima della serata, non durante.
- Le istruzioni per aprirla su macOS in [SEDUTA_TAVOLO.md](docs/SEDUTA_TAVOLO.md)
  §9bis, col comando che funziona sempre (`xattr -dr com.apple.quarantine`):
  l'app non e' firmata, e il costo si dichiara.

### Changed

- **`textures/vram_compression/import_etc2_astc` acceso**: Godot rifiuta di
  esportare un binario universale o arm64 senza — su Apple Silicon la GPU
  vuole ASTC. L'export web non cambia (le sue compressioni VRAM restano
  spente).

### Notes

- Windows e Linux non sono fatti: un preset per uno, quando serviranno.

---

## [0.1.103] — Il bottone che viveva dietro un `return`

Il difetto trovato dal committente ([D-140](docs/DECISIONS.md#d-140)): la
stanza non aveva piu' il bottone «Si comincia».

### Fixed

- **«Si comincia» torna nella stanza**: in 0.1.100, estraendo `_qr_for`, il
  blocco del bottone era finito dopo il `return` della funzione nuova —
  codice legale, mai eseguito, e nessun avviso da GDScript. Senza quel
  bottone la stanza si apriva e non si poteva cominciare.

### Added

- **`tools/dead_code.py`**, nella CI accanto ai validatori: legge tutti i
  `.gd` e segnala ogni istruzione che segue un `return`/`continue`/`break`
  allo stesso rientro. Verde su 139 file; rimettendo il file rotto trova la
  riga, unica, con numero e testo.

### Measured

- Suite 294 test / 6117 asserzioni verde; playtest **FAIL 185 · SUCC 76 ·
  SUCC 123 · DECI 178**, tavolo misto **0 su 8** (invariato: il difetto era
  nella lobby, non nel motore); 22 documenti validi.

---

## [0.1.102] — Il peso dell'alleanza

Le alleanze pesano al Consiglio ([D-139](docs/DECISIONS.md#d-139)), chieste
dal committente.

### Added

- **`confluence_rules.alliance_weight`** nelle quattro Chronicle: un seggio
  legato al proponente che lo **sostiene** e che ha **impegnato almeno due
  carte** porta un peso in piu' sul fronte — ALLY +1, BOUND +2, mai oltre 2
  per seggio. Il bonus si firma a verbale: «X parla da alleato (+N)».
- La regola sta nel dato, non nel codice: togliere `alliance_weight` da una
  Chronicle riporta il Consiglio a com'era.

### Measured

- Playtest 100 semi (7000): **FAIL 185 · SUCC 76 · SUCC 123 · DECI 178**,
  tavolo misto **0 su 8** seggi bloccati (baseline 185 · 78 · 123 · 176).
- Sonda d'era invariata: CHR_01 955 anni / 20,2 generazioni / 24 nomi,
  CHR_03 1049 / 16,5 / 20.
- Suite 294 test / 6117 asserzioni verde; sims ed export deterministici;
  22 documenti validi contro `/schema`.

### Notes

- Due forme scritte e scartate prima di questa, entrambe con **un seggio
  bloccato su un livello solo**: la simmetrica (il nemico frena quanto
  l'alleato spinge — FAIL 210, perche' il tavolo di partenza ha ostilita' e
  non ha alleanze) e quella gratis (FAIL 187). Il verbale le registra.

---

## [0.1.101] — Pedine e vessilli

I pezzi al posto dei cerchietti ([D-138](docs/DECISIONS.md#d-138)),
chiesti dal committente.

### Added

- **`pawn` e `banner`** nel set delle icone (dati, non disegno nella
  vista): la mappa dipinge la pedina col profilo della casa, la sua
  ombra e il contorno scuro; il controllo pianta il suo vessillo sul
  bordo della Regione.
- **La stessa sagoma sul cartone**: la fustella mette la pedina dentro
  il tondo da 15 mm e il vessillo dentro l'anello — schermo e cartone
  sono lo stesso pezzo (D-097).

### Fixed

- Il test del foglio contava i `<circle>` per contare i segnalini, e
  dentro un tondo ora c'e' una pedina: i contorni da punzonare si
  dichiarano (`class="pezzo"`) e si contano quelli.

### Measured

- Suite 294 test / 6117 asserzioni verde; export deterministico byte
  per byte; playtest identico (0/8).

---

## [0.1.100] — Il QR della stanza

L'ultima promessa aperta della fase 3 ([D-137](docs/DECISIONS.md#d-137)):
il codice si inquadra invece di digitarlo.

### Added

- **Encoder QR** scritto a mano (modo byte, correzione M, versioni 1-4) e
  il riquadro che lo disegna: un codice per ogni seggio (indirizzo +
  token) e uno per la vetrina, rigenerati quando si rigenera un codice.
- **L'oracolo**: `tools/gen_qr_fixture.py` congela le matrici attese di
  un'implementazione indipendente; il test le confronta modulo per
  modulo, per tutte e otto le maschere.

### Fixed

- Tre difetti che nessuno sguardo avrebbe visto, trovati dal confronto:
  le due copie dei bit di formato scambiate, il polinomio generatore
  della correzione d'errore con le potenze invertite, e il riempimento
  indicizzato sulla posizione invece che sul conteggio — quest'ultimo
  tornava per caso in versione 1 e sbagliava in versione 3.

### Measured

- 40 matrici su 40 identiche all'oracolo (100 asserzioni); suite 294
  test / 6064 asserzioni verde; playtest identico (0/8); filo ancora
  trasparente byte per byte.

---

## [0.1.99] — Il telefono vero e la stanza

La fase 3 della voce 27 ([D-136](docs/DECISIONS.md#d-136)): le pagine,
il feed della vetrina, la stanza — pronti per la prova computer +
iPad + telefoni (istruzioni in SEDUTA_TAVOLO §9).

### Added

- **`web/console.html`**: il telefono — pannello, mano, Destino,
  la domanda coi bottoni, rientro col token e riconnessione.
- **`web/tavolo.html`**: la vetrina per l'iPad (`/tavolo`), senza
  token (il tavolo è pubblico per costruzione), aggiornata a ogni
  cambiamento del mondo; il tocco sulla Regione apre i segni.
- **La stanza** (`room_screen.tscn`, dal menu): indirizzi per seggio,
  «Rigenera il codice», e al via chi è collegato gioca dal telefono;
  la striscia di diagnosi dice chi «non risponde da Ns».

### Measured

- Sonda del filo estesa: vetrina 43 aggiornamenti, pagine servite,
  partita identica byte per byte. Suite e playtest intatti.

---

## [0.1.98] — Il filo in casa

La fase 2 della voce 27 ([D-135](docs/DECISIONS.md#d-135)): il
trasporto, costruito perché non possa mentire.

### Added

- **L'instradamento per seggio** nel SeatDecider (`ios`): l'avviso del
  Destino finisce sul telefono giusto e su nessun altro.
- **Il protocollo** `state/say/choose/chosen` con la perquisizione
  incorporata — strutturale sulle mani (le carte hanno copie: il
  segreto è *quali copie tieni*, non il titolo), text-scan sui gradini
  del Destino altrui.
- **`ConsoleIO`** (l'io remoto a segnali) e **`ConsoleHost`**
  (WebSocket, token, posta, rientro con domanda riproposta).

### Fixed

- La formula del copione non può più «ripensarci per sempre» (parità
  costante sul passo due → hash a bit alti); la sonda stampa il
  progresso partita per partita.

### Measured

- **Sonda del filo**: partita con due console WebSocket vere identica
  byte per byte (249 messaggi, 82 risposte). **Sonda dei messaggi**:
  100 partite, **21.109 messaggi perquisiti, FUGHE: 0**. Suite
  290/5953 verde, playtest identico.

---

## [0.1.97] — Le due viste dallo stesso mondo

La fase 1 della voce 27 ([D-134](docs/DECISIONS.md#d-134)), senza un
centimetro di rete: la vetrina e la console come ricomposizioni, e i
modelli di vista che in fase 2 saranno i messaggi.

### Added

- **`TableModel` / `ConsoleModel`**: il tavolo col viewer pubblico
  (velate a −1, niente mani né Destini), la console con tutto e solo
  ciò che il suo seggio ha diritto di leggere. Il filtro sta nella
  costruzione, non nel trasporto.
- **`table_view`** (vetrina + ispezione: il click su una Regione apre
  il dettaglio pubblico) e **`console_view`** (`render` + `say`, la
  metà passiva dell'`io` di D-038).
- **`dev_split.tscn`**: le due viste affiancate su una Chronicle
  giocata in automatico.
- **La sonda delle viste** (`test_views`): dorso al tavolo e numero a
  chi ha sbirciato; il modello del tavolo perquisito senza segreti; la
  console senza segreti altrui; sola lettura; le viste si disegnano.

### Measured

- Playtest identico byte per byte (0/8); lente della UI pulita; suite
  286 test / 5923 asserzioni, verde.

---

## [0.1.96] — La Leggenda della Montagna

Le risposte A e C della seduta ([D-133](docs/DECISIONS.md#d-133)): il
seggio senza corpo — e la voce 19 si chiude.

### Added

- **Il conto delle ere nei segni** (`era_tallies`, D-133): tre ere col
  sigillo intatto e il mondo posa `mountain_forgotten`; il sigillo
  caduto azzera il conto senza lasciare leggende.
- **La Leggenda della Montagna** (`INC_VAERAX_LEGEND`, COLLECTIVE):
  entra su `mountain_forgotten`, sbarrata solo dal fatto vivo del
  Cristallo — che sbiadisce: anche il Ridestato, richiuso e
  dimenticato, torna racconto. `presence: []` (niente pedine, niente
  cacciate), MOVE vietato dichiarato, la voce sui fronti finché il
  mondo dimentica.
- **Il Destino per vita** (`destiny_id`/`destiny_pool`
  sull'incarnazione): `DST_VAERAX_LEGEND`, senza clausole di presenza
  — il Minimo si perde se il sigillo cade.

### Measured

- La Leggenda siede **3/20 saghe** (Ridestato 20 → 18, NONE di Vaerax
  9 → 16: la vita non è un rifugio), banda identica (24 nomi).
  Playtest identico (0/8), sims deterministici, censimento 0/0, suite
  281 test / 5865 asserzioni, verde.

---

## [0.1.95] — La montagna delle città

La risposta B della seduta sulla Leggenda
([D-132](docs/DECISIONS.md#d-132)): il tavolo delle città può ferire
la montagna e svuotare la Valle — le porte d'ingresso di Forni ed
Egemonia si aprono.

### Added

- **La Roccia che Cede** (`CNS_MOUNTAIN_WOUNDED`, sul successo di
  `P_DIG_BELOW`): `scar:open_wound` + `condition:exploited` sulle
  Miniere Antiche.
- **La Valle che si Vuota** (`CNS_VALLEY_DRAINED`, sul fallimento
  della domanda dell'Acqua): `scar:emptied` + `condition:lean` sulla
  Valle Verde.

### Measured

- Sonda delle città: i Forni siedono **5/20 saghe**, l'Egemonia
  **11/20** (Custodi 20 → 15), NONE tutti vivi, banda identica.
  Playtest coi totali identici (0/8), sims deterministici, censimento
  0/0, suite verde.

---

## [0.1.94] — L'Egemonia di Eredan

La terza vita della decisione C, che la chiude
([D-131](docs/DECISIONS.md#d-131)): quando la Valle si svuota e Eredan
resta piena, il coro diventa una voce — e nessuno ama l'egemone.

### Added

- **L'Egemonia di Eredan** (`INC_LIBERE_HEGEMONY`, COLLECTIVE): entra
  col segno qualificato — `scar:emptied@REG_VALLE_VERDE`, sbarrata da
  `scar:emptied@REG_EREDAN`. La forma `tag@REG_ID` (nuova in
  `_sign_anywhere`) chiede il segno su QUELLA Regione: uno sgombero
  qualsiasi non fa un'egemonia.
- **`ACTION_DISCOUNT`** (`TGR_HEGEMONY_WORD`): il CLAIM — rivendicare e
  forzare — senza scartare l'Asset AUTHORITY; lo sconto si nomina a
  verbale («per parola propria»).
- **Il gancio ENTITY sulla coppia** (`TGR_HEGEMONY_UNLOVED`,
  RELATION_CAP ALLY): il tetto morde ogni relazione di cui l'egemone è
  membro, e solo quelle.

### Measured

- Condizionale dichiarata (D-035): la vita entra dai salti d'era di
  CHR_03, fuori dalle sonde correnti — playtest identico
  (185·78·123·176, 0/8), ere in banda, sonda delle scelte invariata;
  i denti inchiodati dai test del telaio. Sims deterministici,
  censimento 0/0, suite 278 test / 5832 asserzioni, verde.

---

## [0.1.93] — La Diaspora di Nahr

La seconda vita della decisione C
([D-130](docs/DECISIONS.md#d-130)): il popolo cacciato due volte in un
anno smette di avere un centro — e non lo si può più chiudere fuori.

### Added

- **La Diaspora di Nahr** (`INC_NAHR_DIASPORA`, COLLECTIVE): entra col
  segno `twice_uprooted`, che `_bar_return` scrive alla seconda cacciata
  vera nello stesso anno (`uprooted` alla prima). I tag d'entità non si
  ereditano: il conto riparte a ogni Chronicle da solo.
- **`passes_eviction`** (`TGR_DIASPORA_ROOTLESS`, GATE PASS): la vita
  che decide altrimenti — la cacciata di D-067 e i BLOCK non la
  tengono; il rientro costa comunque la MOVE del round dopo. Il
  validatore ora conosce il PASS su scope ENTITY/GLOBAL.
- **La sentinella nella sonda delle ere**: vite mutate sedute e NONE
  per seggio attraverso le ere.

### Measured

- La Diaspora siede 2 volte in 20 saghe; il NONE di Nahr resta vivo
  (33 su 200 anni giocati): la leva dell'espulsione morde ancora.
  Playtest identico (185·78·123·176, 0/8); sims deterministici;
  censimento 0/0; suite 275 test, 5817 asserzioni, verde.

---

## [0.1.92] — I Forni Riaccesi

La prima delle tre vite della decisione C
([D-129](docs/DECISIONS.md#d-129)): fra i Fuochi e le Custodi nasce
l'industria — ma solo se la storia ha riaperto la miniera.

### Added

- **I Forni Riaccesi** (`INC_CENERE_FURNACES`, COLLECTIVE): entra
  all'esaurimento della linea se `scar:open_wound` sta sul mondo — e il
  nuovo **`entry_forbidden_tag`** la sbarra se `structure:sealed` chiude
  la miniera (allora siedono le Custodi, come sempre).
- **`ACTION_RIPPLE`**, pezzo nuovo del telaio: un'azione riuscita sfoga
  su una Tensione, a verbale e con gli omen. Il dente della fame:
  ogni FORGE dei Forni scalda `TEN_WATER` (+1, `TGR_FURNACE_HUNGER`).
- **`TGR_FURNACE_ORE`** (DRAW_BIAS composito): Forni al tavolo *e*
  ferita sulla mappa → pescano WEALTH più spesso.

### Fixed

- `scar:dragonfall` (0.1.90) stava in prima fila senza lettore né
  dichiarazione: dichiarato nel censimento (il dente vivo è la morte
  del seggio, letta da ON_DEATH).

### Measured

- Playtest 100 semi identico alla baseline (185·78·123·176, 0/8 al
  tavolo misto); banda delle ere identica (955 / 20,5 / 22); sims ed
  export deterministici; censimento 0/0; suite 272 test, 5799
  asserzioni, verde.

---

## [0.1.91] — I valori per vita sono sapore dichiarato

La decisione D della seduta si chiude sulla strada onesta
([D-128](docs/DECISIONS.md#d-128)): i valori d'azione non hanno un
lettore (la policy di D-021 è una scala senza pareggi) e si dichiarano
**sapore di stampa**, allineati ai denti veri; la D meccanica resta a
verbale per la 0.4. La tabella di D-108 era già buona — corretto il solo
Culto della Misura: il velo è un'arte dello SCHEME (3 → 4, INFLUENCE
4 → 3, somma invariata).

---

## [0.1.90] — La morte di Vaerax, per via di Propp

La decisione B della seduta ([D-127](docs/DECISIONS.md#d-127)): il drago
si può uccidere, e la porta è la carta di Propp.

### Added

- **La caccia** (`P_SLAY_THE_DRAGON`): sulla domanda dura del Risveglio,
  eleggibile solo se una **Rivelazione** è stata compiuta quest'anno —
  e chi cala la Rivelazione prescrive il Consiglio e propone per primo.
- **Il Drago Abbattuto** (`CNS_DRAGON_SLAIN`): il drago si spegne (primo
  `SET_ENTITY_ACTIVE` nei dati), il Risveglio crolla, la montagna porta
  la **caduta del drago** — e il potere del Culto ora legge proprio
  quella cicatrice (segni compositi).
- **Il drago si difende**: il punteggio teme la propria fine (−6). La
  morte non elimina il giocatore: `ON_DEATH`, e chi giocava il drago
  gioca il Culto.

### Misurato

Condizionale dichiarata (mai eleggibile nelle 100 standard, come il
riaprire la miniera): playtest identico byte per byte, ere in banda,
270 test / 5782 asserzioni verdi.

---

## [0.1.89] — I denti veri sui pezzi nuovi

I poteri pieni che aspettavano il telaio ([D-126](docs/DECISIONS.md#d-126)):
la Repubblica della Valle (il consenso frena chi propone, e fa muro
quando si oppone), il Culto della Misura (il dogma vela — l'arte che
nessun altro ha), i Frati del Vetro in forma piena (la regola come
misura, dove la reliquia è custodita — segni compositi), la Lega delle
Sette (la firma leggera: la Condition qualifica con un impegno in meno).

Con questo **le nove vite oltre la fondazione hanno tutte almeno un
dente**. Dichiarati non esprimibili: il «vale doppio» delle Custodi e la
paura piena del Ridestato — pezzi futuri, non forzature.

### Misurato

Suite 267/5773 verde; playtest identico byte per byte (le vite dormono
fuori dalle saghe); ere in banda (955 · 20,5 · 22).

---

## [0.1.88] — I pezzi del telaio per le vite

La decisione E della seduta ([D-125](docs/DECISIONS.md#d-125)): tutti e
cinque i pezzi, col rito di D-116 — il telaio prima dei denti, ogni
gancio provato con regole sintetiche e neutro finché nessuna regola vera
lo usa.

### Added

- **I segni compositi** (`when_also`): una regola può chiedere la vita
  **e** il fatto del mondo insieme; tutti i ganci li capiscono.
- **STANCE_MODIFIER**: il fronte di chi porta il segno vale di più — solo
  se ha impegnato almeno una carta su quel fronte.
- **Il velo** (SCHEME modo VEIL, concesso da `ACTION_GRANT`): chiudere un
  numero al tavolo; chi aveva mandato spie non sa più, chi vela sì.
- **Il passo** (`GATE` PASS): chi porta il segno attraversa i BLOCK delle
  regole; la cacciata di D-067 resta più forte.
- **La soglia della Condition** (`CONDITION_THRESHOLD`): qualificare con
  un impegno in meno, mai sotto 1, una volta per regola.

### Misurato

Cinque test sintetici nuovi; con zero regole vere dei tipi nuovi il
playtest sui 100 semi è identico byte per byte alla 0.1.87, suite verde.

---

## [0.1.87] — La seduta sulle vite: le decisioni, e i primi tre denti

La seduta della voce 19 è a verbale ([D-124](docs/DECISIONS.md#d-124),
[SEDUTA_VITE.md](docs/SEDUTA_VITE.md) §4): i tre denti pronti si
accendono, la morte di Vaerax si scriverà per via di Propp, i valori per
vita sono approvati, tutti e cinque i pezzi del telaio autorizzati, le
quattro vite nuove rispiegate (§5) in attesa di decisione.

### Added

- **Il credito federato**: la Compagnia del Sale pesca WEALTH migliore.
- **La regola come misura**: i Frati del Vetro propongono sulla Reliquia
  con World Factor +1.
- **La veglia arma**: le Custodi della Cenere pescano FORCE migliore.

Tre seconde vite del 0.1.70 tornano in regola («una vita senza dente non
si scrive»); Repubblica e Culto della Misura aspettano, dichiarate, i
pezzi nuovi del telaio.

### Misurato

Disgiunte per costruzione e dormienti fuori dalle saghe: playtest sui
100 semi **identico byte per byte** alla 0.1.85, ere in banda (955 ·
20,5 · 22), 262 test / 5757 asserzioni verdi.

---

## [0.1.86] — L'inventario dell'app: i Diritti, l'eco, i marker, la cronaca

Il committente ha chiesto cosa manca sullo schermo
([D-123](docs/DECISIONS.md#d-123)). Quattro cose, e sono entrate.

### Added

- **«I DIRITTI»** nel pannello del seggio: chi tiene un Claim, col dominio
  in italiano; il proprio in ambra. Prima viveva solo nel verbale.
- **L'eco del cambiamento** sulla mappa: ogni effetto che tocca una
  Regione accende un anello ambra che sfuma in sei secondi — dice *dove*
  guardare, il cosa lo dicono verbale e segnalini. I no-op non accendono
  niente.
- **I marker delle domande**: ogni Tensione pianta il suo glifo sulla
  Regione su cui la sua domanda verte adesso, col numero se il seggio ha
  diritto di leggerlo e «?» se è velata. Colori come nel pannello.
- **La cronaca a metà anno**: appena c'è una Truth scritta il bottone si
  accende e impagina il registro fin qui — le stesse pagine di fine anno.

Solo schermo: nessun file di motore toccato. 262 test / 5757 asserzioni
verdi, tre nuovi (`test_app_inventory`).

---

## [0.1.85] — La cicatrice che morde: la voce 24 si chiude

Le undici cicatrici erano scritte e mai lette; adesso sono il ponte
meccanico fra le ere ([D-122](docs/DECISIONS.md#d-122)). Undici regole
nuove, tutte coi tipi che il telaio ha già — nessun ramo di motore.

### Added

- **I tre pesi del Consiglio**: il ponte rotto pesa sulle Vie, la
  capitale presa non dimentica, il seggio vuoto pesa sulla Carta
  (World Factor −1 finché la cicatrice esiste).
- **Le tre pesche guaste**: la parola rotta guasta i legami, dove la
  gente fu sgomberata le braccia mancano, nella terra abbandonata la
  ricchezza non attecchisce.
- **Le pesche buone e la porta**: la torre di veglia (FORCE), il
  pedaggio e il mercato (WEALTH), e la marca che tiene il passo aperto
  (GATE ALLOW: vi si entra anche senza adiacenza).
- **La ferita che parla**: chi sta dove il Cristallo fu sfruttato pesa
  +1 sull'INFLUENCE del Risveglio.
- **Il pavimento del patto**: `PACT` è un tag di relazione (lo scrive
  l'Insediamento Nahr) e la coppia che firma non scende sotto NEUTRAL.
- La **memoria dichiarata** nella sonda dei segni: per ogni segno senza
  regola, il motivo scritto accanto — o il gemello vivo che morde già,
  o la memoria del mondo che aspetta la voce 9.

### Misurato

Cinque gruppi accesi uno alla volta sugli stessi 100 semi: 184·75·129·177
→ **185·78·123·176 con 0/8 al tavolo misto** a ogni passo. Censimento:
vivi per clausola **34 → 46**, prima fila senza lettore **0**, muti senza
dichiarazione **0**.

---

## [0.1.84] — La sonda della visibilità: la voce 22 si chiude

«Un effetto invisibile è un bug, non un'atmosfera» ([D-121](docs/DECISIONS.md#d-121)).
La sonda nuova conta, e quello che ha trovato è stato curato.

### Added

- `cli/run_visibility_probe.gd`: 100 semi a tavolo misto, ogni effetto del
  registro o ha la sua frase a verbale (parola per parola) o un silenzio
  dichiarato — i senza voce vengono nominati, con la fonte. Oggi: **0**.
- Il **placarsi della questione decisa** (H.1) ha la sua riga — era
  l'effetto centrale di ogni Consiglio, e non lo diceva nessuno.
- La **rivelazione del presagio** parla («… non è più velata») invece di
  posare il numero sul tavolo in silenzio.
- Il CLAIM e l'INFLUENCE via scarto **nominano la carta spesa**.
- **La mappa non nasconde** (fase 2): una Regione segnata appare nella
  riga «Sulla mappa» anche senza presidi né controllore, coi nomi dei
  segni di D-107 («Valle Verde (contesa)»).

### Fixed

- `SET_CONTROL` che non cambia mano e `SET_TENSION_VISIBILITY` su una
  questione già aperta si marcano no-op: nessuna riga annuncia un trono
  che non si è mosso.

---

## [0.1.83] — La mossa che spegne il tuo Destino avverte prima

La voce 21 si chiude ([D-120](docs/DECISIONS.md#d-120)): nella partita al
seme 15308 Vaerax aveva spento da solo la sua prima spunta, spostando
l'ultimo token via dalle Montagne Rosse senza che l'app dicesse nulla.

### Added

- Nel `SeatDecider` (uno per terminale e browser, D-038): se l'azione
  scelta spegnerebbe una clausola **accesa** del **proprio** Destino, una
  riga di avviso che la nomina e la scelta di ripensarci. Un cartello,
  non un consigliere.
- L'anteprima è una sessione ricostruita dal salvataggio (`to_save` →
  `restore`): stesso mondo, stesso dado, previsione esatta, nessun ramo
  di regole duplicato. Si paga solo quando un umano ha già scelto.
- Tre test: la mossa nella forma del 15308 avverte nominando la clausola
  (e il mondo vero resta intatto), il ripensamento torna al menu, una
  mossa che non tocca il Destino passa senza cerimonie.

### Misurato

259 test / 5732 asserzioni verdi; le partite senza umani sono identiche
per costruzione (il ramo non viene mai percorso).

---

## [0.1.82] — Gli effetti che pesano: la voce 23 si chiude

La fase 2 della voce 23 ([D-119](docs/DECISIONS.md#d-119)): le carte di
Propp toccano il tavolo — presenza, controllo, Consigli prescritti, segni
con lettori veri — carta per carta, tutte e due le saghe, un passo alla
volta sugli stessi 100 semi.

### Changed

- **23 carte Echo riscritte** (10 nella prima saga, 13 nella seconda, che
  non aveva un solo hook pesante): presidi che si piantano e si ritirano,
  controllo che decade, sei carte che prescrivono un Consiglio, scoperte,
  fama, il granaio che si svuota, il canale che si chiude, la Valle che ha
  fame coi denti di D-117. Una forma respinta coi numeri: il controllo
  tolto gratis bloccava Aldric (1/8) — il titolo si perde a un Consiglio.
- Il punteggio delle sedie legge le carte **con i binding con cui verranno
  compilate** (chi cala è il proponente) e pesa anche le Conseguenze
  agganciate: prima, un hook su un `$slot` valeva zero per costruzione.

### Fixed

- I **Consigli chiusi entrano nel salvataggio**: vivevano solo in memoria,
  e una Chronicle ripresa li dimenticava — il rapporto di fine anno ne
  contava uno in meno. Trovato dal test di ripresa il giorno in cui una
  carta ha aperto un Consiglio prima del punto di interruzione.

### Misurato

Stessi 100 semi: 190·88·120·176 → **184·75·129·177 con 0/8 al tavolo
misto**, Consigli 5,65 (mediana 6), ere in banda (955 anni, 20,1
generazioni, 22 nomi), sim scritte deterministiche, 256 test verdi.

---

## [0.1.81] — La mano del Narratore sullo schermo

La fetta browser della voce 23: le carte di Propp in mano si **vedono**
nell'app, accanto agli Asset — spente quando la storia non le accetta
ancora, col motivo sotto il cursore. Il bottone per calarle c'era già
gratis: il browser corre lo stesso SeatDecider del terminale (D-038).

### Added

- `HandView` disegna la mano del Narratore: figura della carta, tooltip
  con titolo e testo, e «non calabile: …» quando l'eleggibilità o il
  costo lo vietano.
- Un test che compila e disegna la vista nella suite headless (il debito
  di 0.1.60, pagato per questa vista).

---

## [0.1.80] — Le carte di Propp in mano ai giocatori

La visione della voce 23 diventa motore ([D-118](docs/DECISIONS.md#d-118)),
col disegno scelto dal committente: **2 carte a testa per atto**, si
calano **nel proprio turno** pagando **una carta Asset**, e se nessuno
cala l'atto resta muto — la pesca automatica di fine atto non esiste più.

### Added

- La **mano del Narratore** per ogni seggio (nel mondo e nei salvataggi)
  e l'azione **PLAY_ECHO**: l'ordine di Propp resta custodito
  dall'eleggibilità, giudicata quando si cala.
- Chi cala è il proponente della carta; un Consiglio prescritto si apre
  a fine round come per il CLAIM.
- Le sedie automatiche calano al più una carta per atto, e solo se serve
  al loro Destino; l'umano al terminale vede le carte calabili fra le
  azioni.

### Misurato

Due forme respinte coi numeri (17 carte a cronaca; Kessa piantata e 1/8
bloccato) prima di quella giusta: **190·88·120·176 con 0/8 al tavolo
misto**, ere in banda, 255 test verdi. Restano la GUI del browser e gli
effetti più pesanti, carta per carta.

---

## [0.1.79] — I denti veri, e la 48ª carta

La voce 25 si chiude ([D-117](docs/DECISIONS.md#d-117)): cinque regole
d'autore, una per tipo, tutte su segni che il gioco già produce — e il
Legame di Sangue riceve il suo mestiere: **48 carte su 48 lavorano**.

### Added

- **I patti non si firmano a stomaco vuoto**: in una Regione affamata
  niente alleanze (FORGE vietato finché la fame non si cura).
- **Il debito chiamato guasta il mercato**: col debito del Banco chiamato,
  chi pesca ricchezza prende la peggiore delle prime due carte.
- **La fame mangia le scorte**: presenza in Regione affamata, una carta
  di meno in mano.
- **Chi riapre i canali ha il grano**: il proponente che fa scavare i
  canali riceve la Riserva di Grano.
- **Il sangue non si sceglie**: il Legame di Sangue impegnato scrive il
  vincolo sulla coppia, e quella relazione non scende più sotto il
  neutrale (il tetto del giuramento spezzato vince sul pavimento).

### Misurato

Un dente alla volta, stessi 100 semi (tabella in D-117): il divieto della
fame non morde mai nelle sedie automatiche (aspetta la sua condizione,
come le cure), gli altri quattro spostano poco e in salute. **0/8 al
tavolo misto a ogni passo**; ere in banda; 255 test verdi.

---

## [0.1.78] — I denti che aggiungono e tolgono: il telaio

Fase 1 della voce 25 ([D-116](docs/DECISIONS.md#d-116)): **cinque tipi
nuovi di regola**, costruiti nel motore e provati con regole sintetiche.
Nessuna regola vera è ancora accesa: il gioco è identico, il telaio è
pronto.

### Added

- **ACTION_GATE**: un segno può vietare un'azione («il segno lo vieta»),
  in un punto solo — sedia automatica, browser e motore lo rispettano
  insieme.
- **DRAW_BIAS**: la pesca piegata — col segno addosso si prende la
  peggiore (o la migliore) delle prime due carte del mazzo.
- **HAND_LIMIT**: il limite di mano si muove — l'assedio stringe le mani
  di chi è dentro, mai sotto una carta.
- **GRANT_ON_SET**: un segno appena posato consegna una carta con nome e
  cognome, a chi l'ha causato o a chi lo porta.
- **RELATION_FLOOR**: il pavimento di relazione — sotto non si scende; se
  tetto e pavimento litigano, vince il tetto. È il potere che il Legame
  di Sangue aspettava.

### Misurato

Zero regole accese: playtest 100/7000 **identico byte per byte** alla
base, 0/8 al tavolo misto; 255 test, 5372 asserzioni. Le regole vere si
scelgono col committente e si accendono una alla volta, misurate.

---

## [0.1.77] — Il Destino che legge chi lo giura

La voce 20 si chiude ([D-115](docs/DECISIONS.md#d-115)): ogni casa ha ora
**tre ambizioni nel pool** invece di due, e la terza è una carta
**condivisibile** — scritta una volta con `$self`, letta sul seggio che
la giura.

### Added

- **Tre Destini condivisi**: *Il Nome che Pesa* (la fama e la terra — a
  chi vive di parola: Aldric, Vetro, Libere), *La Terra che Risponde*
  (una, due, tre Regioni — a chi vive di posti: Nahr, Vaerax, Cenere),
  *I Conti Chiusi* (registro pulito, firma che vale, nessun debito nel
  mondo — a chi vive di registri: Lyra, Ilve).
- Il motore risolve `$self` su chi giura (stesso meccanismo di
  `$proponent`); la carta stampata dice «per chi lo giura»; la sonda dei
  Destini misura anche le scale condivise, per ogni seggio che le porta.

### Misurato

La prima forma dei Conti Chiusi era **regalata** — tutta di assenze,
chiusa da sola al round 1 in 100 partite su 100 — ed è stata riscritta
con la fama nella Vittoria: ora si chiude in anticipo 18/100 (Lyra) e
47/100 (Ilve), in famiglia con le carte identitarie. Playtest identico
alla base, **0/8 al tavolo misto**; ere in banda (mediana 955 anni,
19.8 generazioni, 22 nomi); 248 test verdi.

---

## [0.1.76] — Tutte le carte lavorano

Ultimi tre mazzetti e la voce 26 si chiude ([D-114](docs/DECISIONS.md#d-114)):
**46 carte su 48 fanno quello che il nome promette**, e le due che no lo
dichiarano.

### Added

- **WEALTH**: la Riserva sfama, il Sale supera la magra, la Carovana
  ricollega, il Pedaggio si scrive sulla mappa, le Chiavi razionano, il
  Credito chiama il debito (la porta del Banco Nero).
- **KNOWLEDGE**: la Voce di Corridoio vela e la Prova svela, la Mappa
  Vecchia ricuce il ponte rotto, il Registro apre i conti, il Testimone
  agita la sede dell'accusato.
- **PEOPLE**: la Folla inquieta la capitale, gli Anziani elaborano il
  lutto, le Braccia spengono la fame, la Mobilitazione scalda la piazza,
  il Portavoce impegna promesse, la Marcia rompe le razioni.

### Misurato

Una famiglia alla volta (tabella in D-114): il mondo più duro e meno
estremo — più fallimenti, meno Decisive — con distribuzioni sane, **0/8
a ogni passo**, ere in banda, guardia biblioteca verde; i piani B e C
aggiornano le attese. 246 test, 5324 asserzioni.

---

## [0.1.75] — I legami imparano il mestiere

Terzo mazzetto della voce 26 ([D-113](docs/DECISIONS.md#d-113)): la
famiglia delle cure.

### Added

- **I mestieri**: il Giuramento rifatto scioglie quello spezzato (la
  cura del tetto di D-105), il Favore spegne la vendetta, il Diritto di
  Ospitalità riapre la porta sbarrata per chi lo impegna, la Promessa di
  Nozze scrive un PACT che il giudizio delle promesse legge, il Debito
  Vecchio segna la sede del debitore. Il Legame di Sangue resta
  dichiarato per la voce 25: il suo potere vero è un pavimento di
  relazione.
- **L'applier**: una relazione con se stessi è un no-op, non un errore.

### Fixed

- **Promessa di Nozze**: il testo diceva «+1», il modificatore è sempre
  stato 2 — terza etichetta bugiarda allineata.

### Misurato

Base identica a D-112 e tutti i passi fermi: i legami sono cure e stati,
mordono quando le condizioni esistono — al tavolo umano, non nei numeri
medi delle sedie automatiche. 0/8 a ogni passo, ere in banda. 246 test,
5190 asserzioni.

---

## [0.1.74] — I sigilli imparano il mestiere

Secondo mazzetto della voce 26 ([D-112](docs/DECISIONS.md#d-112)): le
sei carte AUTHORITY che erano solo un numero ora lavorano — e il
mazzetto disegna cure e contro-cure.

### Added

- **I mestieri**: l'Editto calma la piazza (via l'inquietudine dei
  Mercenari), il Sigillo raffredda la questione (−1, l'opposto della
  Banda Armata), il Censimento chiarisce la contesa che il Diritto di
  Corona posa, il Magistrato cancella la domanda rimasta sul muro,
  l'Investitura scrive l'erede nominato — lo stesso segno che apre la
  porta della Corona Restaurata.
- **Il verbale parla col dizionario**: i segni negli effetti narrati
  usano le parole di D-107 («contesa», non «condition:contested»).

### Fixed

- **Magistrato**: il testo diceva «+1 sul fronte Oppose», il
  modificatore è sempre stato 2 — allineato (stessa svista
  dell'Assedio).

### Misurato

Un mestiere alla volta sugli stessi 100 semi (tabella in D-112): il
Sigillo ammorbidisce (due Decisive in meno), il resto è quieto nei sim;
0/8 a ogni passo, ere in banda, guardia biblioteca verde. Il piano B
aggiorna le attese (il Sigillo sposta i tempi dei Consigli). 246 test,
5178 asserzioni.

---

## [0.1.73] — Il tarocco per ogni vita

Fase 3 della voce 19, l'ultima ([D-111](docs/DECISIONS.md#d-111)).

### Added

- **Una carta per ogni vita**: il mazzo Casata porta un tarocco per
  ciascuna delle 11 vite oltre le prime — nome, descrizione e valori
  della vita, il seggio nel sottotitolo. I fogli di stampa e la cache
  dell'app crescono da soli.
- **Il tarocco segue la vita**: quando il seggio si trasforma, il
  pannello del seggio posa la carta della vita corrente.
- **Il brief d'arte con gli 11 prompt delle vite** (l'archetipo viene
  dal seggio) e il materiale di revisione a **745 testi** (le vite e
  tutti gli eredi, compresi i re restaurati).

### Misurato

Nessun cambio di regole: 246 test, 5175 asserzioni, verdi; parità del
brief in CI.

---

## [0.1.72] — L'albero si riempie

Sei vite dai rami di [TRASFORMAZIONI.md](docs/TRASFORMAZIONI.md)
([D-110](docs/DECISIONS.md#d-110)), ognuna con ingresso e potere.

### Added

- **Tavola I**: la Reggenza del Granaio (se il grano fu requisito), la
  Corona Restaurata (il cerchio: dalla Repubblica si torna re, con
  quattro eredi nuovi da consumare), Vaerax Ridestato (se il Cristallo
  fu cavato).
- **Tavola III**: il Banco Nero (se il debito fu chiamato),
  l'Inquisizione del Vetro (se la Reliquia fu mostrata), la Lega delle
  Sette (se la Carta fu firmata).
- Ogni vita col suo potere al tavolo (World Factor +1 sulla sua
  materia) e il suo prompt d'arte in attesa dei tarocchi per vita.

### Fixed

- **La dinastia non si interrompe a metà**: l'ingresso a evento vale
  solo per chi non muore; per i mortali il segno sceglie la vita quando
  la linea si esaurisce.

### Misurato

Playtest identico, 0/8; guardia biblioteca verde; ere: 20,2 gen/22 nomi
(tavola I), 16,0/18 (tavola III), anni in banda. 245 test, 5115
asserzioni.

---

## [0.1.71] — La storia sceglie la vita

Gli ingressi dell'albero ([D-109](docs/DECISIONS.md#d-109), verso
[TRASFORMAZIONI.md](docs/TRASFORMAZIONI.md)).

### Added

- **Tre porte per le vite**: `ON_TAG` (entra la vita il cui segno sta
  sul mondo, sulla casa o su una Regione — anche senza linea esaurita),
  `ON_DEATH` (il seggio morto rivive nella vita che lo aspetta), e le
  vite alternative: fra più candidate vince la prima, in ordine
  d'autore, il cui ingresso è vero. Il verbale distingue le tre porte.
- **Il segno `life:<id>`** posato sulla casa a ogni vita oltre la prima:
  le tag_rules lo leggono con lo scope che già esiste — i poteri per
  vita senza ganci nuovi.
- **Tre vite di dimostrazione**: l'Accademia delle Misure (Lyra, se la
  legge scritta sta sul mondo — altrimenti il Culto), il Regno di Nahr
  (il popolo insediato torna MORTAL, quattro re scritti), il Culto della
  Montagna (alla morte del drago). Ognuna col suo potere al tavolo.

### Misurato

Motore con dati vecchi: invariato al byte. Con le vite: playtest
identico e 0/8; sonda delle ere 16,4 generazioni e 16 nomi distinti per
saga (il Regno consuma i suoi re), anni e guardie in banda. Prima forma
del potere del Regno respinta coi numeri (scaldava la Carestia: mediana
7 contro banda 3–6 in biblioteca) e riscritta. 243 test, 5110 asserzioni.

---

## [0.1.70] — Il seggio cambia vita

Fase 2 della voce 19 ([D-108](docs/DECISIONS.md#d-108)), generalizzata
dal committente: ogni seggio può mutare, non solo Anselmo.

### Added

- **La traversata**: quando la linea dei successori scritti si esaurisce,
  entra la vita successiva del seggio — nome, natura, valori e successori
  propri — e il verbale d'apertura lo racconta. Una vita COLLECTIVE
  smette di consumare eredi: la repubblica non muore di vecchiaia.
- **Cinque seconde vite d'autore**: la Repubblica della Valle (da Re
  Aldric), il Culto della Misura (da Lyra), la Compagnia del Sale (da
  Maestra Ilve), i Frati del Vetro (da Priore Anselmo), le Custodi della
  Cenere (da Kessa dei Fuochi).
- Lo stato del seggio porta `incarnation` (save e schema).

### Misurato

Playtest standard identico, 0/8; sonda delle ere: 10 generazioni e 10
nomi distinti per saga (gli eredi scritti più la vita nuova, poi il
seggio smette di morire), anni in banda. 239 test in 33 suite, 5097
asserzioni.

---

## [0.1.69] — I segni hanno un corpo

Fase 3 della voce 22 ([D-107](docs/DECISIONS.md#d-107)): un segno che
morde si deve vedere — sulla mappa, sul seggio e sul tavolo di cartone.

### Added

- **Il dizionario dei segni** (`sign_labels.gd`): ogni tag ha la sua
  parola italiana, una sola per app e fustella; un test la pretende per
  ogni segno che i dati sanno scrivere.
- **La mappa parla italiano**: «tagliata fuori» al posto di «cut_off».
- **«I SEGNI DELLA CASA»** nel pannello del seggio: fama, scoperte,
  scorta giurata, la porta sbarrata in rosso.
- **Due pagine di fustella nuove**: i segni delle Regioni (condizioni
  ×2 tratteggiate, strutture, insediamenti, Cicatrici in rosso) e i
  segni delle case (più «cacciata» ×4 e «giuramento spezzato» ×2), in
  export e PDF.

### Fixed

- **L'app non compilava dall'0.1.60**: `confluence_board.gd` chiamava
  `_draw(session, council)` una funzione che Godot riserva al disegno —
  rinominata `_paint_council`, avvio pulito. La suite headless non
  carica le scene: a verbale il debito di un controllo in CI.

### Misurato

234 test in 32 suite (3 nuovi), 5066 asserzioni; nessun cambio di
regole.

---

## [0.1.68] — Le armi imparano il mestiere

Primo mazzetto della voce 26 ([D-106](docs/DECISIONS.md#d-106)): le
cinque carte FORCE che erano solo un numero ora fanno quello che il nome
promette.

### Added

- **I mestieri**: Leva Contadina e Assedio affamano (+1 Carestia), la
  Guardia di Confine chiude le vie (+1 Vie Interrotte), il Posto di
  Blocco taglia fuori la Regione della domanda (`condition:cut_off`,
  curabile), i Mercenari lasciano l'inquietudine (`condition:unrest`).
- **La carta parla**: quando una carta impegnata muove il mondo, il
  verbale lo dice col suo nome — «H. La carta parla - Leva Contadina
  (Popolo Nahr): La Carestia sale di 1.»

### Fixed

- **Assedio**: il testo diceva «+1 sul fronte Oppose», il modificatore è
  sempre stato 2 — testo allineato al +2 reale.

### Misurato

Un mestiere alla volta sugli stessi 100 semi (tabella in D-106): sei
Decisive in meno a regime, i Nahr respirano, 0/8 seggi bloccati a ogni
passo. Suite 231 test / 5012 asserzioni verde; brief, manifest e
revisione rigenerati.

---

## [0.1.67] — I primi cinque denti

Fase 3 della voce 24 ([D-105](docs/DECISIONS.md#d-105)): «accendi tutte».

### Added

- **Cinque tag_rules vere** in `godot/data/tag_rules/tag_rules_core.json`:
  il granaio parla (INFLUENCE +1 sulla Carestia dalla sua Regione), la
  fame siede al tavolo (World Factor −1 sui Consigli della Carestia), la
  strada depredata (porta sbarrata finché Le Vie Riaperte non la
  riaprono), il giuramento spezzato (il Patto Rotto firma la coppia, e
  fra le due case non si sale sopra HOSTILE), la fama precede (World
  Factor +1 per il proponente `renowned`).
- **Il Consiglio legge il mondo**: `council_world_factor` conosce il
  proponente e tre scope — il mondo, chi propone, una Regione qualsiasi
  col segno.

### Misurato

Accese in fila sui 100 semi standard, esiti a verbale in D-105: il
granaio toglie due fallimenti, la fame smorza un Decisive, la fama
sposta quattro Consigli; strada e giuramento mordono su movimento e
relazioni, fuori dagli esiti dei sim. **0/8 seggi bloccati a ogni
passo.** 231 test verdi; ISSUES 25 e 26 aperte (i denti che aggiungono
e tolgono; le carte con un mestiere — 35 su 48 sono solo un numero).

---

## [0.1.66] — Il telaio dei denti

Fase 2 della voce 24 ([D-104](docs/DECISIONS.md#d-104)): il posto dove i
segni potranno mordere, costruito vuoto e misurato invariato.

### Added

- **Schema `tag_rule`**: un segno (su mondo, Regione, Entità o
  relazione) legato a un gancio del motore — ACTION_MODIFIER (INFLUENCE
  si allarga), COUNCIL_MODIFIER (il World Factor si piega), GATE (la
  porta sbarrata o concessa), RELATION_CAP (il tetto alla relazione).
  Con `chronicle_id` la regola resta a casa sua; `active` obbligatorio.
- **I quattro ganci nel motore** (`tag_rules.gd` + resolver, Consiglio,
  movimento, applier): con zero regole ogni gancio restituisce il suo
  neutro; quando una regola morde su azione o Consiglio si firma a
  verbale («Il segno pesa: …»).

### Misurato

231 test in 31 suite (8 nuovi: ogni gancio provato con una regola
sintetica accesa e spenta), 4974 asserzioni; playtest standard
invariato, 0/8 seggi bloccati al tavolo misto.

---

## [0.1.65] — La sonda dei segni, e la voce 24 a verbale

«Ogni conseguenza, ogni cicatrice, ogni decisione potrebbe cambiare il
meccanismo di gioco»: prima di dare denti, il censimento di quanti ne
mancano.

### Added

- **`tools/tag_census.py`**: chi scrive un segno e chi lo legge. Primo
  censimento: 79 segni scritti — 27 vivi per clausola, 5 vivi per motore
  (`discovery:`), 2 con vita postuma (`legend:`), 27 ereditati fra le ere
  ma senza dente in partita, **18 muti del tutto** (fra cui `renowned`,
  `heir_named`, `grain_requisitioned`).
- **ISSUES voce 24**: il telaio `tag_rules` — un dato dichiarativo che
  lega un segno a un gancio del motore (modificatore d'azione in Regione,
  modificatore al Consiglio, porta, relazione) — e le fasi per accendere
  i denti d'autore uno alla volta, misurati.

---

## [0.1.64] — Il verbale impara a raccontare

Fase 1 della voce 22 ([D-103](docs/DECISIONS.md#d-103)): le decisioni si
devono vedere, a cominciare da quello che resta scritto.

### Added

- **Il narratore degli effetti** (`effect_narrator.gd`): una frase con i
  nomi del tavolo per ogni effetto applicato — «Valle Verde passa sotto
  il controllo di Re Aldric», «Il Risveglio non è più velata». Parla per
  le Conseguenze di un Consiglio (ora aperte dal titolo, non dagli id),
  per la clausola qualificata e per la carta Echo d'atto, prima muta.
  Tace sui no-op, sulla contabilità di Propp e su ciò che ha già una voce
  (Scar, Echo, Truth).

### Changed

- Gli `applied` della carta Echo d'atto sono gli Effect registrati, non i
  compilati: il segnale `act_echo_drawn` porta l'effetto com'è nel log.

### Misurato

223 test in 30 suite (7 nuovi), 4955 asserzioni; playtest standard
invariato, 0/8 seggi bloccati al tavolo misto.

---

## [0.1.63] — Le vite del seggio hanno una forma

Fase 1 della voce 19 ([D-102](docs/DECISIONS.md#d-102)): le incarnazioni.

### Added

- **Schema `incarnations`** sull'Entità: le vite del seggio lungo la saga
  — prima la persona, poi quello che nasce da lei — ognuna con nome,
  natura, valori d'azione, prompt d'arte, successori propri e regola
  d'ingresso (`FOUNDING`/`LINE_EXHAUSTED`). Le forme condivise
  (`action_values`, `successors`, `name_grammar`, `persistence`) salgono
  in `$defs`.
- **Gli 8 seggi migrati**: la prima incarnazione (`INC_<SEGGIO>_01`)
  assorbe i campi attuali. Il motore non le legge ancora: una guardia in
  `validate_data.py` impone lo specchio esatto finché la Fase 2 non
  sposta il lettore.

### Misurato

Suite verde prima e dopo (216/4557); playtest standard invariato, 0/8
seggi bloccati al tavolo misto. Nessun comportamento cambiato.

---

## [0.1.62] — Quello che una partita vera ha insegnato

La prima cronaca giocata dal committente (seme 15308) letta riga per riga:
nessun difetto di regole, ma il log parla — e quello che dice è a verbale.

### Fixed

- **Gli accenti del motore**: le stringhe scritte nei `.gd` erano rimaste
  fuori dalla revisione dei dati ([D-099](docs/DECISIONS.md#d-099)) — «Truth
  è ora immutabile», «la domanda caduta è stata ripresa», «COM'È FINITA»,
  «REGISTRO DELLE VERITÀ».
- **Gli accenti dei dati, ultime sacche**: le parole senza ambiguità
  (purché, più, già, città, può, così…) applicate a *tutti* i valori
  stringa dei JSON — cadono «...purche $rival» nelle clausole, «Diritto di
  Ospitalita» e «Puo dirlo dopo» sulla carta, «I Senza Citta» fra i titoli,
  e i segni delle Tensioni. Rigenerati brief d'arte, manifest e materiale
  di revisione.

### Added

- **ISSUES voce 21**: la mossa che spegne una spunta del proprio Destino
  deve avvertire prima — nella partita vera Vaerax ha chiuso a NONE
  spegnendo da solo «La montagna è ancora sua» all'ultimo round, senza un
  cartello.

### Misurato

216 test in 29 suite, 4557 asserzioni; 20 documenti validi contro gli schemi.

---

## [0.1.61] — I tarocchi dietro il paravento

Terza e ultima fetta dichiarata di [D-101](docs/DECISIONS.md#d-101).

### Added

- **La Casata e il Destino come carte**: nella colonna del seggio, sopra
  la scala del Destino, i due tarocchi 70×120 dei fogli di stampa — e il
  Destino lo vede solo chi lo giura, come al tavolo. Alla rotazione di
  un'era la carta cambia da sola: la texture segue `destiny_of`.

### Misurato

216 test in 29 suite, 4557 asserzioni; UI compilata headless.

---

## [0.1.60] — La carta si posa al centro del tavolo

Seconda fetta di [D-101](docs/DECISIONS.md#d-101).

### Added

- **Il Consiglio si apre posando la carta**: il tabellone mostra la
  carta mini della domanda a sinistra di intestazione e mozione — come
  al tavolo fisico, dove si prende dalla traccia e si mette in mezzo.
- **I tondi di presenza portano l'iniziale della casa**, come i
  segnalini della fustella (D-097): il pezzo sullo schermo è il pezzo
  che si punzona.

### Misurato

216 test in 29 suite, 4557 asserzioni; UI compilata headless.

---

## [0.1.59] — La GUI mostra le carte fisiche

Prima fetta della direzione del committente
([D-101](docs/DECISIONS.md#d-101)): lo schermo mostra i componenti
fisici, non una loro parafrasi.

### Added

- **`PrintSheet.card_svg`** (una carta sola, stessa faccia della stampa,
  senza segni di taglio) e **`ui/card_art.gd`** (rasterizza una volta
  per mazzo, cache). Un solo impaginatore, tre superfici: foglio,
  anteprima, partita.
- **La mano è fatta di carte stampate**: la faccia vera 63×88, col bordo
  di rilevanza e il «vale N» del resolver come sole aggiunte a schermo;
  tooltip invariato per leggere a carta piccola.
- **Il mondo cala una carta**: la vista Echo di fine atto mostra la
  carta stampata accanto al verbale di cosa ha fatto.

Fette dichiarate: la carta mini della domanda al centro del Consiglio,
i token della fustella sulla mappa, i tarocchi identità nella vista del
seggio.

### Misurato

216 test in 29 suite, 4557 asserzioni; UI compilata headless.

---

## [0.1.58] — La voce del Consiglio: le mozioni al congiuntivo

Seconda lettura della voce 13, su segnalazione del committente
([D-100](docs/DECISIONS.md#d-100)).

### Changed

- **Le proposte dei Consigli parlano da mozioni**: congiuntivo
  esortativo, registro alto («Si levino i banchi e si portino dove le
  mura sanno difenderli», «Il grano sia requisito in nome del trono») —
  34 riscritture sulle due saghe; gli esiti restano cronaca, con le due
  segnalazioni riscritte per immagine.
- Altre 22 code di passato remoto senza accento chiuse rileggendo.

### Misurato

215 test in 29 suite, 4518 asserzioni; simulazioni, export, brief,
manifesto e tavolo di lettura riallineati.

---

## [0.1.57] — La revisione dei testi: gli accenti tornano, le regole escono dal racconto

Chiude ISSUES voce 13 su delega del committente
([D-099](docs/DECISIONS.md#d-099)): prima lettura di fila dei 661 testi.

### Fixed

- **Gli accenti restaurati ovunque**: 357 righe corrette su 17 file
  («piu»→«più», «la cosa e seria»→«è seria», «il consiglio lascio
  cadere»→«lasciò cadere»…). Ogni «e» nuda classificata a occhio su due
  censimenti completi: le congiunzioni restano congiunzioni.
- **Le regole fuori dal racconto**: la velatura ora la dichiara la carta
  dal dato `visibility` («domanda velata · survival»), e le descrizioni
  del Risveglio e delle Vie Interrotte sono tornate narrativa.

### Misurato

Suite intatta (215 test, 4518 asserzioni), validazione, simulazioni,
export, manifesto e tavolo di lettura rigenerati.

---

## [0.1.56] — Il tavolo di lettura per la revisione dei testi

Il materiale della voce 13, su richiesta del committente.

### Added

- **`tools/build_review.py`** → [docs/REVISIONE_TESTI.md](docs/REVISIONE_TESTI.md):
  i 661 testi d'autore in ordine di lettura — aperture, Regioni, Casate,
  Domande coi presagi, Consigli con proposte ed esiti raccontati,
  Conseguenze e cicatrici, carte Echo, carte Asset, Destini gradino per
  gradino, Azioni — ognuno col suo identificativo, così una correzione si
  segna con una riga e si riporta nei dati senza cercare. Generato e
  deterministico, come il manifest: non si corregge lì, si rigenera.

---

## [0.1.55] — La seconda leva: la proposta bocciata non compra quiete

Chiude la milestone 0.2 ([D-098](docs/DECISIONS.md#d-098)): era l'ultima
voce.

### Changed

- **`confluence_rules.failure_delta` = −1** in tutte le Chronicle (era
  −2, appendice A6): una proposta affondata non sfoga più la domanda —
  resta vicina alla soglia e torna prima. In armonia con D-077 e D-094:
  dire di no non chiude niente. Il gradino 0 è respinto coi numeri; la
  manopola `--failure-delta` resta nel playtest per rimisurare.
- Le attese del piano scriptato «il consiglio spezzato» aggiornate: la
  questione bocciata due volte torna ai voti una quarta, che passa.

### Misurato (stessi 100 semi)

Divario aggressivo−prudente 28→26 (storia: 37→31→28→26); i NONE del
bloccante da 2 a 6 — bloccare può costarti l'anno; i Consigli recuperati
vanno al centro del tavolo (distratto 46→53). Mediana Consigli 6, 0/8
bloccati al tavolo misto, saghe stabili. Scoperto per strada che la
prima leva (ISSUES 1) era già nei dati. 215 test in 29 suite, 4518
asserzioni.

---

## [0.1.54] — Il formato fisico: tre taglie di carta, token e segnalini

Chiude ISSUES voce 7 con le decisioni del committente, implementate
nell'export ([D-097](docs/DECISIONS.md#d-097)).

### Added

- **Tre taglie di carta per ruolo**: classiche 63×88 (Asset, Echo),
  tarocchi 70×120 (Destini, Casate), mini 44×68 (Domande); le tessere
  Regione 80×80 restano — la mappa è un tabellone unico, già fatto.
  `print_sheet` ha la tabella dei formati; impaginazione, segni di
  taglio e anteprima F4 seguono da sé.
- **`token_sheet.gd`**: la fustella dei segnalini (15 mm, una per saga —
  sei presenze e sei controlli per casa, i rombi del valore, il quadrato
  del Drift) e la **traccia dei valori** (quattro corsie 0–8; la soglia
  sta sulla carta). In coda al PDF: ora 32 pagine.
- COMPONENTS §7 riscritta da lista di domande a decisione.

### Misurato

La guardia «il testo ci sta» passa su tutte le taglie (719 asserzioni di
stampa); 215 test in 29 suite, 4513 asserzioni; export e PDF
deterministici.

---

## [0.1.53] — Il libro della saga: la Timeline in apertura, poi i capitoli

Con D-095 completa la parte in-app della 1.0 dichiarata
([D-096](docs/DECISIONS.md#d-096)).

### Added

- **`ChronicleBook.saga_pages`**: la Timeline dei secoli in apertura —
  un anno per voce, col salto, chi sedeva e com'è finita in breve — poi
  la cronaca di ogni anno, capitolo per capitolo, con le stesse pagine
  di D-086. Con un anno solo è il libro di sempre, per costruzione.
- **Il libro nell'app**: la fila degli anni giocati viaggia con la
  saga; «La cronaca» mostra il libro intero appena gli anni sono più di
  uno, e il piè di pagina dice cosa si sfoglia.

### Misurato

213 test in 29 suite, 4496 asserzioni; viste compilate headless;
batteria di chiusura verde.

---

## [0.1.52] — La saga si gioca: l'era successiva si offre a fine anno

Il primo pezzo mancante della 1.0 ([D-095](docs/DECISIONS.md#d-095)): il
motore della campagna esisteva solo in riga di comando, adesso lo vede
chi gioca.

### Added

- **«Gioca l'era successiva»**: a fine anno l'app offre di continuare la
  saga nella stessa seduta — la nuova era eredita mondo e risultati per
  lo stesso percorso di `run_saga`, il transcript continua col verbale
  d'apertura in testa, il seme avanza di +97 (una saga giocata a mano è
  riproducibile come una simulata).
- **`DataSet.library_sequel_of`**: quale biblioteca prosegue quale età —
  lo stesso tavolo di Entità — scritto una volta sola, con guardia.
- ROADMAP aggiornata allo stato vero (0.2 con una voce sola, 0.3
  completata, 1.0 a metà).

### Misurato

212 test in 29 suite, 4487 asserzioni; `game_screen.gd` compila headless;
batteria di chiusura verde.

---

## [0.1.51] — La spirale del fallimento si chiude ri-decidendo

Scioglie il debito residuo della voce 18
([D-094](docs/DECISIONS.md#d-094)): «Il Regno che Ricorda» non è più
strozzato dalla propria Victory.

### Added

- **La via del riprendere**: `P_RETAKE_QUESTION` (Q_SUCCESSION_LAW,
  eleggibile con `question_unresolved` sul mondo) e
  `CNS_QUESTION_RETAKEN` — il segno si toglie, la domanda torna calda
  (+2). La forma di D-085 applicata al fallimento.
- **Il conto dell'era** (`world_state.open_failures`): le Tensioni cadute
  e non ancora ri-decise; quando l'ultima si decide, la spirale si
  chiude e il tag si toglie con un Effect di sistema. Il segno ereditato
  da un'era prima non si chiude per caso: quello lo scioglie solo la via
  del riprendere.

### Misurato

Su 20 saghe: Vittorie del Regno che Ricorda **6→16**, Trionfi 4→7
(sopra il Minimo 11%→27%); ere che chiudono col tag 140→75 su 200;
`question_unresolved` letterale all'ultimo anno da 18/20 a 5/20 saghe.
Playtest sugli stessi 100 semi: 0/8 bloccati al tavolo misto, Consigli
in banda. 211 test in 29 suite, 4482 asserzioni.

---

## [0.1.50] — La voce 2 si chiude coi numeri: i template in più non servono

Solo verbale ([D-093](docs/DECISIONS.md#d-093)): terza e ultima misura
della voce più vecchia rimasta aperta.

### Misurato

Ogni proposta scritta vive dove vive: CHR_01 15/18 ai voti nell'anno
singolo (le 3 fuori sono contenuto d'era, misurato vivo sulle saghe:
21, 4 e 32 volte), CHR_03 17/19 con `P_SHOW_IT` a 88 voti su 20 saghe;
nessuno zero sul conteggio completo, e le morte storiche di D-063
(`P_DIG_FOR_HIRE`: 31) resuscitate dal tempo delle ere. La ripetizione
ha già i suoi rimedi strutturali (D-028, D-077, D-076/D-085): scrivere
template adesso sarebbe contenuto senza bisogno (D-035).

---

## [0.1.49] — Il browser dice se sa tenere il salvataggio

Chiude ISSUES voce 12 ([D-092](docs/DECISIONS.md#d-092)): una partita
persa perché il browser ha pulito lo spazio non è più persa in silenzio.

### Added

- **L'avviso prima di cominciare**: nel browser il menu dichiara se lo
  storage c'è («i salvataggi restano in questo browser») o no
  (navigazione privata: «chiusa la scheda, la partita sparisce») — e
  l'avviso torna a fine anno, quando serve davvero.
- **«Scarica il salvataggio»**: la partita in corso (o l'anno appena
  finito) come JSON, per la stessa via del log; il nome del file porta
  chronicle e seme (`echoes-salvataggio-chr-01-7042.json`).
- `LogExport.deliver` ha imparato il MIME e i suoi messaggi sono neutri;
  `SaveSerializer.download_name` nuovo, con guardia.

### Misurato

209 test in 29 suite, 4471 asserzioni; `game_screen.gd` compila headless.

---

## [0.1.48] — `marker_id` esce dal modello dati

Chiude ISSUES voce 11 nel modo che la voce stessa prescrive
([D-091](docs/DECISIONS.md#d-091)): un campo che nessuno legge è un campo
che nessuno mantiene.

### Removed

- **`marker_id`** dagli schemi `region`/`entity`/`asset`/`echo_card`, dai
  tre file dati che lo valorizzavano e dalla colonna del manifest.
  Nessuna riga di GDScript l'ha mai letto. Rientrerà col prototipo di
  computer vision della 0.5, che è anche il momento giusto per decidere
  che forma di marker serve; i valori erano meccanici (`MK_<id>`) e si
  rigenerano in un minuto.

### Misurato

Suite invariata (208 test in 29 suite, 4469 asserzioni), validazione e
manifest verdi.

---

## [0.1.47] — Il verbale della mappa: come si piazza l'era nuova

Estensione della Fase 3 su richiesta del committente
([D-090](docs/DECISIONS.md#d-090)): il verbale dice anche la mappa.

### Added

- **`world_state.map_record`**: per ogni Regione chi la tiene (coi nomi
  dell'era nuova), se è decaduta perché nessuno c'era (D-027), i segni
  che porta e le condizioni sbiadite dal salto (D-078); in coda i fatti
  diventati leggenda (D-075) e i rapporti ammorbiditi (D-045). Derivato
  dagli stessi `inheritance_effects` che piazzano la mappa: una sola
  fonte di verità.
- **La prosa della mappa** nel log del tavolo (sotto il verbale delle
  domande) e in `run_saga` sotto «La mappa che si eredita».

### Changed

- I segni nel verbale delle domande passano all'imperfetto («il mondo ne
  portava il segno»): la pesca legge il mondo com'era alla chiusura, e il
  salto può averli sbiaditi subito dopo — lo dice la riga della mappa.

### Misurato

Solo lettura, verificato: suite e sonda delle ere identiche riga per
riga. 208 test in 29 suite, 4469 asserzioni.

---

## [0.1.46] — Il verbale d'apertura: la generazione si legge

Fase 3 del World Propagation Engine ([D-089](docs/DECISIONS.md#d-089)),
l'ultima dichiarata: chiude ISSUES voce 9.

### Added

- **`world_state.opening_record`**: per ogni domanda pescata, chi l'ha
  richiamata — il segno sul mondo (D-079, nominato per nome: fatto,
  leggenda o Regione), il conto rimasto aperto (D-087, con il nome del
  seggio che l'ha lasciato), o la biblioteca — e con che valore riparte
  (D-088). Schema esteso, chiave sempre presente.
- **La prosa del verbale**: in testa al log del tavolo a ogni eredità
  («La Carestia torna: Re Aldric non l'ha mai chiusa») e nel digest di
  `run_saga` sotto «Perché queste».
- `_open_accounts` dice *chi* ha lasciato ogni conto; `_carried_mark`
  dice *quale* segno ha richiamato — la pesca usa gli stessi bordi di
  prima e resta bit per bit identica.

### Misurato

Solo lettura, verificato sugli stessi semi: playtest a tavolo misto
invariato (0/8 seggi bloccati), sonda delle ere identica alla 0.1.45 riga
per riga. 207 test in 29 suite, 4452 asserzioni.

---

## [0.1.45] — La domanda lasciata calda torna calda

Fase 2 del World Propagation Engine ([D-088](docs/DECISIONS.md#d-088)): il
tempo non resetta più le questioni oltre alle persone.

### Added

- **Il calore ereditato**: sui salti brevi (sotto i 50 anni) una Tensione
  ripescata riparte da dove l'era prima l'ha lasciata — mai già a soglia:
  torna tiepida, non bollente. Sui salti lunghi il calore sbiadisce e si
  riparte dal valore d'autore. Una questione chiusa bene può ripartire
  anche più quieta di com'è scritta.
- La sonda delle ere conta il calore ereditato.

### Misurato

Su 720 domande pescate in 20 saghe, 66 partono più calde e 14 più quiete
del valore d'autore; ogni altra misura d'era invariata e la guardia degli
anni-biblioteca resta verde. 206 test in 29 suite verdi.

---

## [0.1.44] — Il motore 0.3 apre il cantiere: i conti rimasti aperti

Fase 0 e Fase 1 del World Propagation Engine
([D-087](docs/DECISIONS.md#d-087)): le evidence, registrate «proprio per
questo passaggio», finalmente si leggono.

### Added

- **`unmet` nei risultati dei Destini**: le clausole negate come dati, non
  come prosa — la metà strutturata delle evidence. Misurato: un'era lascia
  in mediana 9 conti aperti (5–13).
- **Il conto aperto richiama la sua domanda**: una candidata nominata da
  una clausola `tension_limit` negata nell'era prima pesa il triplo nella
  pesca, come un segno sul mondo (D-079). La storia preme sull'era, anche
  se la casa ha cambiato ambizione.
- La sonda delle ere conta i conti aperti richiamati.

### Misurato

Richiamate pescate il **75%** delle volte (260/343) contro il 67% della
pesca cieca; ogni altra misura d'era invariata. 205 test in 29 suite
verdi. Dichiarate le Fasi 2 e 3 del cantiere.

---

## [0.1.43] — La cronaca si vede: la voce 10 si chiude

La metà app di ISSUES voce 10 ([D-086](docs/DECISIONS.md#d-086)): a fine
Chronicle la cronaca dell'anno è sullo schermo.

### Added

- `ui/chronicle_book_view.gd`: si apre da sola quando l'anno finisce,
  frecce per sfogliare, bottone «La cronaca» per tornarci — il salvataggio
  resta nello schermo anche dopo il congedo della sessione, come il seme.
  La vista rasterizza **le stesse pagine SVG** che il Chronicle Book
  stamperà: quello che si vede è quello che uscirà, non una cosa che gli
  somiglia (disciplina D-056).
- Guardia: ogni pagina generata deve rasterizzarsi.

---

## [0.1.42] — La cronaca dell'anno: le Verità diventano pagine

La metà export di ISSUES voce 10 ([D-086](docs/DECISIONS.md#d-086)): il
seme del Chronicle Book della 1.0.

### Added

- `cli/run_chronicle_book.gd`: da un salvataggio qualsiasi alle pagine A4
  della cronaca — l'anno in testa, le Verità atto per atto, e come è finita
  per i seggi. Carta scura del set, serif per l'anno, a capo a mano.
- `scripts/core/chronicle_book.gd` e le guardie di `test_chronicle_book.gd`:
  ogni Verità finisce sulla pagina, A4 veri e numerati, un anno lungo si
  spezza in più pagine, un anno muto lo dice.

---

## [0.1.41] — Un PDF, non venticinque SVG

Chiude ISSUES voce 8: il formato di consegna per la tipografia.

### Added

- `tools/make_pdf.py` e il flag `--pdf` di `tools/run_export.sh`:
  `echoes_print.pdf`, 26 pagine A4 esatte in ordine di consegna (Asset,
  Echo, Tensioni, Destini, Casate, Regioni). Dipendenze opzionali
  (`cairosvg`, `pypdf`): servono solo a chi stampa — gli SVG restano la
  sorgente diffabile che la CI confronta, e senza flag non cambia niente.

---

## [0.1.40] — Le vie per disfare i fatti eterni

Chiude ISSUES voce 18 ([D-085](docs/DECISIONS.md#d-085)): un fatto eterno
non è più una porta murata per sempre — si può disfare, a un Consiglio,
pagando.

### Added

- **`P_REOPEN_THE_MINE`** (Risveglio): si toglie la pietra, e il Risveglio
  sale di 2 — riaprire sveglia quello che dormiva.
- **`P_ONE_CROWN`** (Successione): il titolo torna uno, e chi ha perso la
  conta diventa OSTILE.
- **Il ramo del pianificatore che disfa**: una clausola di assenza ora
  insegue anche la Conseguenza che rimuove il tag.

### Misurato

Su 20 saghe: 21 riaperture e 4 riunificazioni in 200 ere; la scuola risorge
(Vittorie 6→20, Trionfi 3); il Regno che Ricorda resta strozzato dalla
propria Vittoria — debito residuo circoscritto e a verbale. Playtest 0/8
bloccati, anno scritto invariato. 198 test in 28 suite verdi.

---

## [0.1.39] — Il quinto MASTER PROMPT: i Destini illustrati

L'inventario dei componenti grafici ha trovato le carte Destiny senza
direzione d'arte, come i ritratti prima di D-065
([D-084](docs/DECISIONS.md#d-084)).

### Added

- **MASTER PROMPT 5 — Destiny card**: niente volti, la cosa desiderata
  composta come un'immagine votiva; variation key per archetipo di chi
  desidera, con gli accenti del MP4 — le due carte di un pool sono due
  quadri della stessa parete.
- Le 4 chiavi d'arte mancanti dei Destini di seconda rotazione della
  corona; il mazzo `destiny` collegato al brief. **Il brief passa da 101 a
  117 prompt.**

### Fixed

- `card_face.gd` non esponeva la chiave d'arte sulla faccia Destiny: il
  brief la saltava in silenzio.

---

## [0.1.38] — Il contenuto senza elettorato si toglie

Punto 7 del committente: le voci croniche a zero di CHR_03/04, riscritte se
possibile, tolte se no ([D-083](docs/DECISIONS.md#d-083)).

### Removed

- **`P_WATER_RIGHTS`**: era il cattivo della questione dell'acqua e i poteri
  locali la tenevano fuori per costruzione — la cura misurata (un debito
  saldato nel prezzo) non ha mosso niente: 0 su 23, respinta e tolta.
- **`Q_ANY_ANCIENT_LEAVE` / `P_ANY_WITHDRAW`**: i Consigli jolly si aprono
  a questione fredda e il ritiro non ha un solo elettore fra i Destini —
  tolti; la veglia e l'ignorare restano vivi.

### Docs

- **Il §7 riscritto per il gioco a 4 Tensioni** (punto 5 del committente):
  `RULES_V0_2.md` dichiara i numeri veri — anno scritto mediana 5-6,
  anno-biblioteca 3-6, limiti duri 2-8 — e chiude sei versioni di bande
  «in deroga». A verbale anche il vincolo di equilibrio (0/8 al tavolo
  misto) e la lettura del tavolo uniforme.

### Misurato

Il «mai ai voti» di CHR_03 scende da 7 proposte su 21 a **2 su 19**, con le
due superstiti giustificate a verbale. 198 test in 28 suite verdi.

---

## [0.1.37] — La memoria in posta: il Trionfo che nomina la leggenda, e il giuramento che preme

Due scelte del committente: la leggenda come posta nei Trionfi, e una
memoria che inquieta per la prima saga ([D-082](docs/DECISIONS.md#d-082)).

### Added

- **La memoria come posta** (D-082): il Trionfo di «Radicati» (Popolo Nahr,
  corona) e del «Registro Aperto» (Gilda del Sale, città) chiede anche la
  leggenda dell'era **messa per iscritto** (`discovery:legend`). Tre
  collocazioni respinte coi numeri prima di questa — il verbale del viaggio
  è in D-082.
- **`P_HEIR_AS_STORY`** sul Consiglio della Successione: «si nomini chi la
  ballata nomina, e stavolta lo si scriva» — la strada di corona verso la
  trascrizione, ineleggibile finché la leggenda non esiste (anno scritto
  intatto per costruzione). Votata 32 volte in 20 saghe.
- **«Il Giuramento che Nessuno Sciolse»**: la carta MEMORIA che preme
  invece di consolare — gated su `legend:oath_broken`, scalda la
  Successione e **forza il Consiglio**: la domanda si pone. Pescata 4 volte
  in 20 saghe: rara come il suo gate, ma esiste.

### Misurato

Trionfo del popolo da 29/87 (quasi automatico) a **4/87** (raro e conteso),
Vittoria 32→38; trascrizioni di corona da 0/153 a 12 ere; P_ANY_AS_STORY
da 4 a 23 voti. Playtest: **0/8 bloccati al tavolo misto**, anno scritto
invariato. A ISSUES (voce 18) il reperto: i fatti eterni come condizioni di
assenza strozzano i Destini tardivi. 198 test in 28 suite verdi.

---

## [0.1.36] — La soglia della stanchezza: tre ere, non due

Ratifica del committente su D-081: la terza delusione è la tradizione, non
la seconda ([D-081, revisione](docs/DECISIONS.md#d-081)).

### Changed

- `WEARY_ERAS` da 2 a 3: l'erede cambia ambizione dopo **tre** ere a mani
  vuote. Rimisurato sugli stessi semi: rotazioni da stanchezza da 6.7 a
  4.1 per saga, da premio tornate a 13.6; i mortali restano sbloccati
  (run massimo di Aldric 4 ere, zero saghe macinate).
- A verbale la lettura confermata dal committente: i 4/8 seggi bloccati
  del **tavolo uniforme** sono un artefatto della misura (quattro
  ottimizzatori identici), non un difetto del gioco — il vincolo di
  equilibrio resta 0/8 al tavolo misto.

---

## [0.1.35] — L'iniquità del tempo

La rotazione dei Destini premiava solo chi ottiene: chi falliva riprovava la
stessa ambizione per mille anni — Aldric macinava lo stesso Destino per
un'intera saga in 6 su 20 ([D-081](docs/DECISIONS.md#d-081)).

### Added

- **Un erede non giura sull'ambizione che ha visto fallire** (D-081): il
  seggio conta le ere a mani vuote e, quando la persona cambia dopo due ere
  senza ottenere, l'erede passa al Destino successivo del pool. La rotazione
  da stanchezza è marcata `weary`, distinta da quella da premio, e lascia una
  riga nel verbale. Chi non cambia persona non si stanca: la stessa vita
  riprova finché vive, un popolo si rinnova senza cambiare volto, e Vaerax è
  sotto la montagna apposta.
- La sonda delle ere conta le rotazioni da stanchezza.

### Misurato

Su 20 saghe della corona: i macinamenti di un'intera saga passano da 6+2 a
**zero** (run massimo di Aldric da 10 a 3 ere); le rotazioni da premio
restano 13.2 per saga, quelle da stanchezza sono 6.7; ogni altra misura
d'era invariata. 198 test in 28 suite verdi.

---

## [0.1.34] — La pesca che ascolta, e la guardia sugli anni-biblioteca

Gli ultimi due pezzi dichiarati della #25
([D-079](docs/DECISIONS.md#d-079), [D-080](docs/DECISIONS.md#d-080)): la
biblioteca smette di pescare l'anno alla cieca, e l'anno pescato ha la sua
guardia di bilanciamento.

### Added

- **La pesca che ascolta** (D-079): il `tension_pool` dichiara gli *echi* —
  per ogni candidata, i segni che la richiamano. Se il mondo ereditato porta
  uno di quei segni (fatto globale, la sua leggenda, o tag di Regione) la
  candidata pesa il triplo nella pesca. La ripesca avviene in
  `inherit_from`, quando il mondo di prima è noto, e ridà anche il sacchetto
  del Drift; senza echi o senza eredità la pesca resta byte-identica a
  prima. Echi dichiarati per CHR_02 (corona) e CHR_04 (città), ancorati ai
  tag che le Conseguenze scrivono davvero.
- **La guardia sugli anni-biblioteca** (D-080, Fase 4 di #25):
  `test_library_balance.gd` gioca l'anno scritto, gli fa ereditare quello
  pescato, e tiene i Consigli del secondo dentro i limiti duri del §7 —
  per tutte e due le coppie. Banda dichiarata dalla misura di nascita:
  mediana 4 (corona) e 5 (città), banda 3-6.
- La sonda delle ere conta la pesca che ascolta.

### Misurato

Le candidate richiamate da un segno vengono pescate il **78%** delle volte
in 20 saghe, contro il 67% della pesca cieca; su cento semi col solo segno
della miniera murata, il Risveglio esce 93 volte contro 66. La saga
dell'812 tiene le sue proprietà (0 domande ridecise, salti invariati) e le
mani d'era mostrano la continuità voluta. 196 test in 28 suite verdi; il
playtest non incatena ere e resta intatto per costruzione.

---

## [0.1.33] — Le due falle del verbale: la domanda ridecisa e il lutto di mille anni

La prima saga giocata per intero ha lasciato un verbale, e il verbale due
buchi di regolamento: due Chronicle su dieci rimettevano ai voti una domanda
già decisa nello stesso anno, e le Terre Nahr portavano lo stesso lutto
dall'812 al 1856 ([D-077](docs/DECISIONS.md#d-077),
[D-078](docs/DECISIONS.md#d-078)).

### Fixed

- **Una domanda decisa resta decisa** (D-077): niente ripiego sulle domande
  già poste; un Consiglio che non ha più niente di nuovo da chiedere non si
  apre — né a soglia, né dal pavimento di fine anno, né con un Claim — e
  **una proposta bocciata non consuma la domanda**: respingere non è
  decidere, la questione resta sul tavolo e può tornare ai voti.
- **Le condizioni sbiadiscono come i fatti** (D-078): su un salto oltre i
  cinquant'anni una `condition:` di Regione non attraversa; strutture,
  insediamenti e cicatrici restano — la cicatrice è la memoria visibile
  della mappa. Il criterio è quello di D-075, esteso alla mappa.

### Changed

- La banda dichiarata di `test_balance.gd` torna **5-6**: i Consigli tolti
  erano ridecisioni, l'anno è più corto ma più vero. I limiti duri del §7
  non si sono mossi (0 partite fuori).

### Misurato

Playtest dei 100 semi, tavolo misto: **0/8 seggi bloccati** (era arrivato a
1/8 con la prima stesura — il verbale della cura, con due varianti respinte
coi numeri, è in D-077), Kessa dei Fuochi 41/8/1, Re Aldric da 7 a 2 NONE,
Lyra 12 Triumph, Verità diverse 484→513. Saga dell'812 rigiocata: **0
domande ridecise** (erano 2 su 10 Chronicle), il lutto sopravvive al salto
breve (+37) e sbiadisce su quello lungo (+153). 193 test in 27 suite verdi.

---

## [0.1.32] — Il contenuto che legge le leggende

D-075 ha dato al mondo le leggende; questa versione mette al tavolo chi le
racconta ([D-076](docs/DECISIONS.md#d-076)).

### Added

- **La famiglia MEMORIA**: carte Echo gated su una leggenda — «La Ballata
  dell'Anno Buono» e «Il Giorno che la Gilda Chiese Tutto» — che stanno nei
  mazzi delle sole Chronicle-biblioteca, le ere che una memoria possono
  averla.
- **Due proposte «si dice che»** e la Conseguenza «La Leggenda Messa per
  Iscritto»: chi raccoglie le storie guadagna una Scoperta, e la domanda si
  calma. La memoria è una via alle Scoperte: un ponte fra le ere.
- La sonda delle ere conta la memoria letta (disciplina D-035).

### Fixed

- **Un mazzo non porta famiglie che nessun atto pesca**: la composizione del
  mazzo Echo di un anno scritto non cambia più quando si aggiungono carte per
  le ere — gli anni scritti sono byte-identici a prima, verificato con `diff`
  sul playtest dei 100 semi.
- **La policy pianifica contro i Consigli di quest'anno**, non contro
  l'intera biblioteca: inseguiva vie che il primo anno non può aprire.

### Misurato

La Ballata pescata 38 volte in 20 saghe della corona (mai in quelle delle
città), il Giorno della Gilda 18 volte in 10 saghe delle città (mai prima);
le proposte votate 6/4 e 5 volte. Ogni pezzo vive nella sua era, nessuno
fuori. 191 test in 27 suite verdi.

---

## [0.1.31] — La memoria che sbiadisce

La correzione di rotta è del committente: **fra due partite possono passare
venti anni o due secoli, e dieci partite possono coprire mille anni.** Il
motore la visione ce l'aveva già — salti dichiarati, generazioni, Destini che
ruotano — ma la memoria no: il 100% dei fatti dell'anno uno arrivava
letterale a mille anni dopo ([D-075](docs/DECISIONS.md#d-075)).

### Added

- **I fatti diventano leggende**: su un salto lungo resta un *fatto* solo
  quello che è murato o scritto — la Chronicle lo dichiara in
  `enduring_facts` — e il resto diventa `legend:<fatto>`, vero come la
  memoria e non come il mondo. Le leggende attraversano ogni salto
  successivo. La teca mostrata due secoli fa torna leggenda, e l'Ordine di
  un'altra era deve rimostrarla.
- `cli/run_era_probe.gd`: cosa fa il tempo a una saga — anni coperti (mediana
  **1.019 su 10 Chronicle**), salti, generazioni (17 per saga), Destini
  ruotati, mani di domande, e il bilancio fatti/leggende all'ultimo anno.
- `enduring_facts` nello schema delle Chronicle, con le liste autorate per le
  due biblioteche (`CHR_02`, `CHR_04`).

### Misurato

Dei 7,2 fatti dell'anno uno, i letterali all'ultimo anno passano da **7,2
(100%) a 5,0** — e i sopravvissuti sono quelli dichiarati o rifatti dalle ere
successive. Il mondo all'ultimo anno porta 11,7 fatti e **16,1 leggende**.
Il playtest a Chronicle singola è intoccato per costruzione. 191 test in 27
suite verdi.

---

## [0.1.30] — La materia prima della campagna

Fase 1 dell'issue [#25](https://github.com/Tannoiser2/ECHOES/issues/25) (la
Chronicle II generata dalle evidence): prima di scrivere il generatore, si
misura la sua materia prima ([D-074](docs/DECISIONS.md#d-074)).

### Added

- `cli/run_legacy_probe.gd`: i fatti globali, le cicatrici, il controllo, i
  rapporti e i livelli con cui un anno si chiude, e quanti mondi diversi
  producono cento semi.

### Misurato

**99 mondi distinti su 100** — la materia prima c'è. E i tre difetti da
conoscere prima di costruirci sopra, a verbale in D-074: la cicatrice del
fallimento è il 73% di tutte le cicatrici (va aggregata, non letta alla
pari), tre rapporti chiudono identici in ogni seme (costanti travestite da
variabili, e a monte un fatto di contenuto), e a differenziare gli anni sono
i fatti rari, non i frequenti.

---

## [0.1.29] — La prima saga si sveglia

Due scene scritte col vincolo che la respinta di D-070 aveva insegnato: le
bande devono sovrapporsi — dev'esserci almeno un mondo in cui tutt'e due i
contendenti vincono ([D-072](docs/DECISIONS.md#d-072), chiude ISSUES 17).

### Changed

- **La fame tiene gli uomini nelle valli**: Vaerax a Triumph vuole la Carestia
  da 3 in su, contro il tetto di 4 di Aldric e di 3 del Popolo. Bande che si
  toccano in 3–4: ci si può stare tutti, ma ogni spinta è contesa.
- **Un domani certo rimette in moto le carovane**: l'Erede Nominato cala di 1
  le Vie Interrotte — la proposta più votata della Successione adesso tocca
  Lyra e Vaerax nei due versi.

### Added

- La sonda dei margini accetta `--chronicle` e `--tavolo=misto`: guardava solo
  la prima saga a tavolo uniforme, lo stesso difetto che D-066 aveva corretto
  nella sonda delle posizioni.

### Misurato

ABSTAIN della prima saga **71,1% → 59,9%** (era il criterio della voce 17:
sotto il 60 a parità di vincoli), CONDITION e SUPPORT raddoppiati. Sui 100
semi di D-055: seggi bloccati 0 su 8, Consigli 5,96, TRIUMPH 11 (pavimento:
10), fallimenti **195** — il minimo mai misurato — e la seconda saga ferma al
48,4%. Le due saghe sono ora entrambe sotto il 60% di ABSTAIN, dal 70–86% in
cui stavano tre versioni fa.

E la domanda tattica che restava — *il dado conta?* — è misurata e chiusa
senza manopole ([D-073](docs/DECISIONS.md#d-073)): a tavolo misto il d6
decide la banda in circa due Consigli su tre, l'opposizione c'è nel 71–78%
dei Consigli, e i margini blindati sono un quarto. A tavolo uniforme sembrava
il contrario — terza volta che l'ottimizzatore da solo avrebbe indotto
l'intervento sbagliato.

---

## [0.1.28] — Il Consiglio come scena

Dopo tre versioni di lavoro sugli assi, il 65–72% delle posizioni restava
ABSTAIN. Tre mosse misurate una alla volta, una respinta a verbale, e la
risposta a un sospetto vecchio quanto ISSUES 3
([D-070](docs/DECISIONS.md#d-070), [D-071](docs/DECISIONS.md#d-071)).

### Fixed

- **La clausola non è più un timbro**: la CONDITION sceglieva sempre la prima
  clausola della lista — zero scelte della seconda, in tutt'e due le saghe.
  Adesso si sceglie quella che serve il proprio Destino: le clausole viventi
  passano da 2 a **8**.
- **La corsa al controllo si vede**: una Regione che cambiava mano verso un
  terzo valeva zero per chi conta le Regioni. Adesso vale un'obiezione.

### Changed

- Due scene nuove col criterio di D-066: il grano requisito intasa le Vie
  (Lyra contro, Vaerax a favore, sulla domanda più votata della prima saga), e
  l'Ordine del Vetro prende posizione sulla Carta (Carta ≤ 4 a Triumph, contro
  le Città Libere). Una terza — Lyra contro il sigillo delle gallerie — è
  **respinta con i numeri**: sveglia Lyra ma fa crollare i TRIUMPH del tavolo
  da 11 a 3 su 400. Due clausole mutuamente esclusive non sono una scena.

### Added

- `cli/run_asset_probe.gd` (chiude ISSUES 3): **la coda è vuota** — tutte le
  48 facce arrivano in mano e vengono spese, a tavolo misto. Nessuna carta da
  riscrivere. A verbale invece lo sbilancio di circolazione: WEALTH 4.344
  passaggi di mano contro i ~350 di FORCE e PEOPLE.
- La sonda delle posizioni conta le clausole poste e le Condition qualificate.
- Una guardia in `test_stance_scoring.gd`: chi vuole la domanda calda non pone
  la clausola che la raffredda.

### Misurato

ABSTAIN della seconda saga **74,1% → 48,4%** in tre versioni (64,9% alla
0.1.27), CONDITION al 29,8%, l'Ordine del Vetro da 142 astensioni e zero
opposizioni a 42/57/71. Sui 100 semi di D-055: divario aggressivo/prudente
**22** (era 37 alla 0.1.26), NONE 11, TRIUMPH 11, Verità diverse **526**
(nuovo massimo), seggi bloccati a tavolo misto 0 su 8, Consigli 6,06. La
prima saga resta al 71% di ABSTAIN: il perché e la strada sono la voce 17 di
ISSUES.

---

## [0.1.27] — La parola si può prendere

Il proponente di un Consiglio lo decide il posto, e il posto è di chi vuole
l'esito ovvio ([D-063](docs/DECISIONS.md#d-063)): le Città Libere non hanno mai
preso la parola sul Debito in 92 Consigli. L'azione che sposta la parola —
`CLAIM`, §11 — esisteva e **la policy non l'ha mai giocata**
(issue [#22](https://github.com/Tannoiser2/ECHOES/issues/22),
[D-069](docs/DECISIONS.md#d-069)).

### Fixed

- **La policy gioca CLAIM**, derivandolo dai dati (precedente D-021): chi ha
  bisogno di un Consiglio a cui il posto non gli darebbe la parola prenota il
  dominio e poi lo forza. Con quattro moderazioni, ognuna misurata contro una
  rottura: la domanda deve scaldarsi, la parola ruota, si forza solo in un
  round che sarebbe rimasto muto, si prenota solo con la coppia di AUTHORITY
  in mano. La forma ingenua — forza tutto, subito — è respinta a verbale:
  fallimenti 219 → 339 e mediana dei Consigli fuori banda.
- **La ripresa non salta più il Consiglio del round salvato**: un salvataggio
  in fase `DRIFT`/`THRESHOLD_CHECK` riprendeva dal round dopo, perdendo il
  Consiglio dovuto. Invisibile finché nessun Consiglio si apriva presto
  nell'anno: è stata la policy col Claim a scovarlo.

### Added

- La sonda delle scelte conta Claim creati e Consigli forzati per seggio.
- `tests/unit/test_claim_policy.gd`, 6 test: ogni moderazione è una guardia.

### Misurato

40 Chronicle a tavolo misto: Claim 0/0 → 104 creati/13 forzati (CHR_01) e
60/25 (CHR_03, Libere 16). **Mai ai voti: 2 → 0 su 15 nella prima saga — prima
volta — e 4 → 3 su 20 nella seconda; le cinque proposte di D-063 votano
tutte.** Sui 100 semi di D-055: divario aggressivo/prudente **37 → 31**, NONE
5 → 9, TRIUMPH 11 → 14, Verità diverse 491 → 506, seggi bloccati a tavolo
misto 0 su 8, Consigli 6,02 (mediana 6). Costi dichiarati: Decisive 185 → 172,
bloccati a tavolo uniforme 3 → 4.

---

## [0.1.26] — Perdere adesso è implementato

Su 400 risultati di seggio, NONE usciva **una volta**. Non per taratura: nessun
contenuto poteva falsificare un Minimo contro la volontà di chi lo regge
([AUDIT_DESTINI](docs/AUDIT_DESTINI.md), [D-067](docs/DECISIONS.md#d-067),
[D-068](docs/DECISIONS.md#d-068)).

### Added

- **Tre espulsioni**: `CNS_CAPITAL_TAKEN`, `CNS_SEALED_VALLEY` e
  `CNS_ASH_ABANDONED` tolgono una presenza a `$rival` — sulla capitale, sulle
  Terre Nahr, sulle Miniere Antiche: le Regioni che i Minimi nominano. Tutte su
  Conseguenze che la vittima già bloccava: **l'espulsione va dove il no c'è
  già**, così non cambia il punteggio di nessuno — cambia cosa succede quando
  quel voto si perde comunque. La forma sulle vie del controllo affamava Kessa
  (39/11 → 45/5, un seggio bloccato) ed è respinta a verbale.
- **La regola della porta sbarrata**: da una Regione da cui un Consiglio ti ha
  cacciato non si rientra finché l'atto non gira (`evicted:<regione>` messo
  dalla risoluzione, letto da `can_move_to`, tolto dal giro di stagione — tutto
  nel log degli Effect). Senza contenuto che caccia è inerte, quindi si toglie
  togliendo tre righe di dati. Senza, il rientro era gratis: 12 espulsioni
  recuperate su 13.
- **Due Conseguenze che fanno nemici** nella seconda saga, che non ne aveva
  nessuna: chiamare il debito e prendere il seggio portano il rapporto a
  `HOSTILE`. E due clausole `relation_state` a livello Triumph, **dal lato di
  chi vota**: la stesura sull'aggressore pesava zero, perché chi propone non
  vota (ISSUES 14).
- `cli/run_eviction_probe.gd`: quando cade un'espulsione, e chi recupera prima
  che il Destino venga letto. È la sonda che ha trovato il difetto vero.
- `tests/unit/test_eviction.gd`, 3 test.

### Misurato

Sugli stessi 100 semi di D-055, tavolo misto:

| | 0.1.25 | 0.1.26 |
|---|---|---|
| **NONE** | **1** | **5** |
| MINIMUM / VICTORY / TRIUMPH | 205 / 181 / 13 | 214 / 170 / 11 |
| seggi bloccati (misto) | 0 su 8 | **0 su 8** |
| Consigli per Chronicle | 5,97 | 5,92 |
| `REMOVE_PRESENCE` pesato (CHR_01) | 0 | **28** |
| `SET_RELATION` pesato (CHR_03) | 0 su 156 | **85 su 357** |
| ABSTAIN CHR_03 | 74,1% | **64,9%** |

Ogni espulsione sul Minimo caduta nell'atto III è diventata un NONE; quelle
degli atti I–II si recuperano perdendo l'atto. **I costi, reali e a verbale**:
Ilve 3/42/5 → 12/34/4 (il seggio più forte trova un no), Kessa 39/11 → 43/7, e
il divario aggressivo/prudente sale da 30 a 37 — la stessa forza di D-066,
messa in conto e non tarata via.

---

## [0.1.25] — Il tavolo adesso ha qualcosa in gioco

L'80% dei seggi valutava una proposta **esattamente zero**: non apatia scritta nel
contenuto, indifferenza del codice e dei Destini insieme
([D-066](docs/DECISIONS.md#d-066)).

### Fixed

- **`SET_RELATION` non aveva un ramo nel punteggio.** Letto 126 volte, pesato
  zero: Forgiare è una delle sei azioni del gioco e per chi decide non esisteva.
- **Una clausola `min` su una Tensione era mezza cieca**: `max` aveva il suo
  ripiego dentro la banda, `min` no. Chi ha bisogno che una domanda resti calda
  non aveva niente da dire finché non gliela spegnevano del tutto.

### Changed

- **Dieci clausole `tension_limit` nei Destini in gioco.** Le domande più
  visitate dei due tavoli — le Vie Interrotte, la Successione, la Carta — non
  erano nominate da nessuno, e la seconda saga non aveva **una sola** clausola su
  una Tensione. Sono a livello Triumph: il punteggio legge tutti e tre i livelli,
  e a livello Victory la Vittoria crollava da 192 a 126 su 400.
- Il criterio, che vale più delle clausole: **ogni Tensione in gioco dev'essere
  nominata da almeno un Destino, e almeno un seggio dev'essere dalla parte
  opposta.** Vaerax vuole le Vie Interrotte alte perché salire non dev'essere
  facile; Lyra le vuole basse perché è la strada delle gallerie. Quella è una
  scena. Quattro Destini che vogliono tutti la Carestia bassa non lo sono.
- `validate_data.py` rifiuta una Chronicle in cui una domanda in gioco non è
  nominata da nessun seggio.

### Added

- `tests/unit/test_stance_scoring.gd`, 5 test.
- `run_stance_probe.gd` accetta `--chronicle`: guardava solo la prima saga, ed è
  la seconda quella che di clausole sulle Tensioni non ne aveva nessuna.

### Misurato

40 Chronicle per saga:

| | CHR_01 | CHR_03 |
|---|---|---|
| Consigli con almeno un no | 37% → **68%** | 38% → **53%** |
| ABSTAIN | 80,1% → **70,2%** | 85,9% → **74,1%** |
| `ADJUST_TENSION` pesato | 6/468 → **266/669** | **0**/558 → **146/558** |

Sui 100 semi di D-055: fallimenti **251 → 219**, Decisive **133 → 185**, Consigli
per Chronicle 5,97 (in banda §7), Truth diverse 471 → 480, seggi bloccati 0 su 8.

**Il costo, che è reale:** il divario fra aggressivo e prudente passa da 26 a 31.
Rendere contesi i Consigli aiuta il carattere costruito per approfittare dei
contesi — i due obiettivi tirano in direzioni diverse, ed è la prima volta che il
progetto lo vede scritto.

**Resta aperto:** `SET_RELATION` si legge e pesa ancora zero su 156, perché solo
2 Consequence su 45 muovono un rapporto. E NONE resta 1 su 400: nessuno perde
mai.

---

## [0.1.24] — Tre conti aperti chiusi

La seconda leva, il contenuto che non arrivava mai al tavolo, e il quarto MASTER
PROMPT. **Milestone 0.2 a metà**: restano i template di Confluence e le carte che
nessuno gioca.

### Changed

- **Far cadere una proposta costa quanto proporla** ([D-064](docs/DECISIONS.md#d-064),
  ISSUES 1). Il §12.3 restituiva una carta a ogni oppositore su un Failure: era
  l'unica asimmetria che premiava il fronte contrario. Sugli stessi 100 semi di
  D-055 il divario in Vittorie fra aggressivo e prudente passa da **37 a 26**
  (69-32 → 66-40), i fallimenti da 274 a 251, e i Consigli per Chronicle restano
  5,96 — dentro la banda del §7. Sta in
  `confluence_rules.opposer_recovers_on_failure`: si toglie senza toccare il
  codice, e `run_playtest.gd --oppose-recovery=1` rimette l'originale per un run.
- `CNF_ANY_SURVIVAL` tolta da CHR_03, che non poteva aprirla: l'unica Tensione
  SURVIVAL dell'anno ha un template tutto suo. Tre proposte contate come
  contenuto della seconda saga e mai giocabili.

### Added

- **MASTER PROMPT 4 — la carta Casata** ([D-065](docs/DECISIONS.md#d-065),
  ISSUES 4). Un ritratto, come la regola 3 aveva già stabilito; variation key sui
  sei archetipi. Due di quelle righe non sono un volto, ed è per loro che il
  prompt dice *one subject* e non *one face*. Da qui `keys_without_prompt()` torna
  vuota: **98 chiavi su 98 hanno il loro prompt** in `docs/BRIEF_ARTE.md`.
- **`cli/run_choice_probe.gd`** ([D-063](docs/DECISIONS.md#d-063)): per ogni
  Confluence, cosa il tavolo poteva dire e cosa ha detto. Separa i tre motivi per
  cui una proposta non arriva mai ai voti, che vogliono tre rimedi diversi.
  `--tavolo=misto` la misura coi quattro caratteri invece che con quattro
  ottimizzatori identici.
- `validate_data.py` controlla che una Chronicle non dichiari template che
  nessuna delle sue Tensioni può aprire.
- `tests/unit/test_questions_asked.gd` e le due nuove guardie in
  `test_print_export.gd`.

### Misurato

- **«Mai eleggibile» è zero** su 38 proposte in due saghe: l'ipotesi che ci
  fossero clausole che non si avverano mai è morta lì.
- **Il tavolo uniforme sotto-riporta.** CHR_01 passa da 13 proposte su 15 a
  **15 su 15** appena si misura col tavolo misto: il contenuto della prima saga è
  tutto raggiungibile, e a dirlo non era la sonda che il progetto usava.
- Le 5 di CHR_03 che restano fuori esistono solo come cose che qualcun altro
  vuole evitare. L'unico seggio il cui Trionfo vuole `debt_forgiven` è stato
  proponente sul Debito **0 volte su 92**: il proponente lo decide il posto, e il
  posto è di chi vuole l'esito ovvio.

### Fixed

- `art_bible.gd` teneva accenti e guide in un dizionario piatto su tutti i MASTER
  PROMPT, e `PEOPLE` è sia una famiglia di Asset sia un archetipo di Casata. Con
  il contenuto di oggi non si sarebbe visto — il che lo rende il tipo di difetto
  che si scopre sei mesi dopo cambiando una parola.

---

## [0.1.23] — Il log si porta via, e il cruscotto ha un tasto

Due cose che si vedono solo giocando su un tablet, e il tablet è dove questo
gioco è stato giocato davvero ([D-062](docs/DECISIONS.md#d-062)).

### Added

- **«Scarica il log»**: tutta la cronaca della sessione in un file di testo — non
  le sole righe del `GameLog`, ma quello che si legge nella colonna, menu e
  risposte comprese. Nel browser scende come download, altrove viene scritto in
  `user://` e la schermata **dice dove**.
- In testa al file la saga, l'anno e il **seme**, che è la parte che conta: un log
  senza seme è un racconto, con il seme è una partita che si può rigiocare
  identica. Il nome se lo porta pure lui: `echoes-chr-03-3330.txt`.
- **«Cruscotto»**: il pannello che stava solo dietro F3. Su un tablet un F3 non
  esiste — non era scomodo, era assente. Il tasto sta in fondo alla colonna,
  fuori dalla lista delle scelte, e si spegne quando non c'è una partita.
- `tests/unit/test_log_export.gd`, 6 test.

### Changed

- F3 e F4 restano, ma passano per gli stessi due metodi del bottone: due strade
  che scrivono lo stesso stato si disallineano il giorno in cui una cambia.

---

## [0.1.22] — Il Consiglio non chiede due volte la stessa cosa

Trovata giocando, non testando: nel registro delle Truth di una partita vera **la
stessa frase compariva tre volte** nello stesso anno, con solo i numeri diversi.

### Changed

- **§12.2 B**: le domande eleggibili di una Confluence, meno quelle che questa
  Tensione ha già messo ai voti nella Chronicle. Quando le ha fatte tutte tornano
  disponibili tutte ([D-061](docs/DECISIONS.md#d-061)).
- La memoria sta in `world_state.questions_asked`, è per Tensione, si segna alla
  **risoluzione** e non all'apertura, e nasce vuota a ogni Chronicle: è la
  memoria dell'anno che si gioca, non del mondo.

### Added

- `cli/run_text_probe.gd` accetta `--chronicle` (le sonde guardavano solo la
  prima saga) e conta le ripetizioni **dentro la stessa Chronicle**: quante
  frasi diverse esistono in quaranta partite non era la domanda giusta — la
  domanda è quante volte una partita ripete sé stessa a chi la sta giocando.
- `tests/unit/test_questions_asked.gd`, 6 test.

### Misurato

Su 40 Chronicle per saga, prima → dopo:

| | CHR_01 | CHR_03 |
|---|---|---|
| Chronicle con una Truth ripetuta | 6 → **2** | 20 → **0** |
| domande distinte poste | 8 → **12** (tutte) | 5 → **7** |
| proposte distinte votate | 17 → 17 | 10 → **13** |

Il Debito della seconda saga poneva 94 volte su 94 la stessa domanda. Con
`run_playtest.gd` sugli stessi 100 semi di D-055: fallimenti 282 → 274, Consigli
per Chronicle 5,96 invariati, seggi bloccati al tavolo uniforme 4 su 8 → 3 su 8.
Il divario fra aggressivo e prudente resta dov'era — **questa non è la seconda
leva** (ISSUES 1).

---

## [0.1.21] — Un posto dove mettere l'arte vera

Il segnaposto e il brief c'erano dalla 0.1.18, e in mezzo mancava la cosa più
semplice: **un posto dove mettere l'immagine**. Niente nel codice caricava un
file per una `art_prompt_key`.

### Added

- **`art_library.gd`**: la convenzione è il nome del file — la chiave con i
  punti al posto delle barre, sotto `res://art/`. Niente manifesto, niente
  elenco da tenere allineato ([D-059](docs/DECISIONS.md#d-059)).
- Se il file c'è si disegna quello, se non c'è il segnaposto: **un'immagine che
  manca non è un errore**, ed è la proprietà che tiene il gioco giocabile con
  zero illustrazioni consegnate e con qualunque sottoinsieme.
- Vale nei tre posti insieme: la mappa e le carte sullo schermo, l'anteprima
  dietro F4, e il foglio di stampa — che la incorpora come `data:` URI, così
  resta un file solo.
- **`map.board`**: quando il tabellone dipinto esiste, la mappa smette di
  disegnare il terreno generato e ci mette sopra solo quello che il quadro non
  sa — chi tiene un posto, chi ci sta, cosa gli è successo quest'anno. Le
  posizioni delle Regioni si prendono **alla lettera** dai dati, perché è su
  quelle coordinate che il quadro è stato dipinto.
- `godot/art/README.md` dice dove va cosa: si copia il PNG al suo posto, anche
  dall'interfaccia web di GitHub, e basta.
- **Una carta con l'illustrazione vera va al vivo**: l'immagine prende tutta la
  carta e il testo ci sta sopra, su una fascia scura in basso. È come la
  ART_BIBLE descrive la carta dalla 0.0 — *«il soggetto occupa i due terzi alti;
  il terzo basso è un'area calma riservata a un overlay di testo»* — e quella
  riga ha senso solo se il testo sta sopra il dipinto. Il segnaposto generato
  resta nel riquadro: è uno schema, non un quadro. Una carta cambia
  impaginazione il giorno in cui la sua illustrazione arriva.
- **Le tessere dipinte sulla mappa** sono ritagliate dentro l'esagono e non
  appoggiate sopra: una Regione resta una Regione e non diventa un quadro con
  un bordo. Le UV sono le stesse coordinate normalizzate del piano generato, e
  una Regione consegnata convive con cinque che non lo sono ancora.

### Il build esportato è il posto dove il primo tentativo falliva

Leggere i byte del PNG fa funzionare un file appena copiato senza aprire
l'editor — nei test, nella CLI, mentre si lavora. Ma **un build esportato
impacchetta la texture importata e non il PNG originale**, quindi lì quella
strada non trova niente: il quadro spariva esattamente dove si gioca davvero.
Adesso c'è il ripiego sulla risorsa importata. (`.gdignore` più un filtro di
inclusione era il primo tentativo e non funziona: una cartella ignorata è
invisibile anche all'esportatore.)

Verificato da capo a fondo con un tabellone finto costruito sulle coordinate
vere, in un build Web esportato: i sei seggi cadono esatti sui posti dipinti. Il
finto **non è committato** — un tabellone falso nel repository sarebbe una
bugia sullo schermo.

---

## [0.1.20] — Dodici segni

La ART_BIBLE chiede overlay e icone come **grafica di sistema**, e dichiara il
vincolo che le governa: il set delle sei famiglie deve funzionare in
**monocromatico a 16 px** — se un'icona ha bisogno del colore per distinguersi
da un'altra, va ridisegnata. Non esisteva niente, e sulla mappa i quattro
livelli di tag uscivano come una colonna di parole grigie.

### Added

- **`icon_set.gd`**: dodici glifi — le sei famiglie di Asset, i quattro livelli
  della mappa (`structure`, `condition`, `settlement`, `scar`) e i due marker
  (Tensione, Echo). Stesso vocabolario di tre parole del terreno, stesso piano
  normalizzato, disegnati da Godot sullo schermo e dall'SVG in stampa — e
  **senza colori**: il colore lo decide chi chiama ([D-058](docs/DECISIONS.md#d-058)).
- **`prova_icone.svg`** esce dall'export insieme a tutto il resto: ogni glifo a
  16, 24, 32 e 64 px, scuro su chiaro e chiaro su scuro. È la prova che la
  ART_BIBLE chiede, e rigenerandosi non può invecchiare.
- Sulla mappa ogni segno ha il glifo del proprio livello accanto alla parola: il
  glifo dice *che tipo* di segno è, la parola dice quale. Sulle carte Asset — in
  mano e stampate — il glifo della famiglia sta nell'angolo in basso a destra:
  è come si ordina un mazzo di 132 carte senza leggerne una.

### Changed

- **La regola 3 della ART_BIBLE è cambiata alla prima carta consegnata**: gli
  Asset possono avere volti. Quello che separa i due mazzi non è il volto ma la
  **composizione** — l'Asset è una *scena*, la Casata un *ritratto*
  ([D-060](docs/DECISIONS.md#d-060)). La riga sta adesso dentro il MASTER PROMPT,
  quindi arriva a chi disegna attraverso `BRIEF_ARTE.md` invece di vivere in un
  documento che potrebbe non aprire mai.

- La fascia sotto il testo di una carta al vivo è una **sfumatura** e non un
  rettangolo: un bordo netto sopra un dipinto è un taglio, una sfumatura è
  un'ombra che sale dal basso. Definita una volta per foglio, in unità relative,
  quindi si adatta da sola a quanto testo ha quella carta.

### Fixed

- I segni sulle Regioni (`condition:`, `scar:`, …) finivano **in cima alla
  mappa**, uno sull'altro, invece che sotto la propria tessera: aggiungendo il
  glifo si era persa la somma con il centro sull'asse verticale. Non si vedeva a
  inizio partita, perché le Regioni cominciano senza segni — si è visto giocando
  una Chronicle intera fino in fondo. E sul quadro dipinto hanno adesso la
  stessa ombra di un pixel che porta il nome, perché un grigio su terra bruciata
  non si legge.

### Il vincolo ha cambiato due disegni

Tutt'e due li ha mostrati la prova, e nessun ragionamento li avrebbe presi:

- **FORCE era una punta di lancia**, e a 16 px una punta di lancia è il marker
  di Tensione, che è una freccia in su. Adesso è una lama con l'elsa.
- **KNOWLEDGE era un compasso**, cioè due gambe e una traversa, cioè la lettera
  A. Un glifo che si legge come una lettera non è un glifo. Adesso è un libro
  aperto.

---

## [0.1.19] — La mappa smette di essere sei cerchi

La ART_BIBLE divide il lavoro in due: l'**illustrazione** la fa una persona, la
**grafica di sistema** la fa il codice. Le tessere Regione stanno sul confine, e
questa è la metà che tocca al codice — la sagoma del terreno, il bioma che si
riconosce da lontano, il centro lasciato calmo per i segnalini.

### Added

- **`region_art.gd`**: il terreno di una Regione come **piano** in coordinate
  normalizzate — esagono irregolare più tratti in un vocabolario di tre parole —
  disegnato sia da `map_view.gd` con le primitive di Godot sia da
  `print_sheet.gd` in SVG. La tessera sullo schermo e quella che si stampa sono
  **la stessa immagine** ([D-057](docs/DECISIONS.md#d-057)).
- Sei biomi, sei vocabolari: tetti e mura per la città, campi a strisce e un
  fiume per la valle, creste con la neve su un versante per la montagna,
  imbocchi di galleria per il sottosuolo, la banda della strada con le soste,
  erba bassa e piste per la steppa. Deterministici dall'id: due Regioni dello
  stesso bioma sono diverse, la stessa Regione non cambia mai.
- La tessera stampata è **al vivo**: il terreno prende tutta la carta e il nome
  sta in basso a sinistra, dove l'esagono lascia scoperto il fondo.

### Changed

- La mappa disegna esagoni e non cerchi, con l'anello del controllo che segue la
  sagoma, e le strade sono due tratti — una banda scura e un filo chiaro —
  invece di una riga sola: i posti sono posti, non nodi di un diagramma.
- **Il raggio delle tessere cresce con lo spazio.** Era 46 pixel fissi: sei
  bolli piccoli in mezzo a uno schermo vuoto, con il terreno invisibile. E il
  riquadro delle posizioni scritte nei dati viene allungato fino a riempire la
  vista, il che sposta tutto insieme senza cambiare dove sta una Regione
  rispetto alle altre.

### Fixed

- Il disegno usciva dalla tessera — i tetti della città spuntavano sotto il
  bordo — perché i vocabolari sono scritti sul quadrato pieno e l'esagono ha un
  cerchio inscritto più piccolo. Adesso tutto rientra, e un test cammina su ogni
  punto di ogni Regione.
- Il terreno stampato era schiacciato dentro un riquadro rettangolare: una
  montagna schiacciata smette di essere una montagna. Ora disegna sempre in un
  quadrato centrato.

---

## [0.1.18] — Il gioco esce dallo schermo

**Con questa la Milestone 0.1 è chiusa**: tutti e sei i punti del §25 e tutte e
quattro le voci di chiusura. Si gioca una Chronicle intera dal browser o dal
terminale, su due saghe, si salva e si riprende — e da oggi si stampa.


La roadmap della 0.1 aveva una riga aperta: «Export Preview e placeholder d'arte
migliorati». `CardView` era arrivata con la 0.1.5, l'altra metà mai. E mancava
qualcosa di più grande di una schermata: **niente trasformava i JSON in un pezzo
fisico**. La COMPONENTS §1 dice che ECHOES è un gioco da tavolo con un'app e non
uno dei due, e fino a oggi c'era solo l'app.

### Added

- **`card_face.gd`**: cosa c'è stampato su un pezzo, detto una volta sola.
  Titolo, sottotitolo, accento, cifra d'angolo, corpo, note, chiave d'arte — e
  lo leggono sia il foglio di stampa sia l'anteprima ([D-056](docs/DECISIONS.md#d-056)).
- **`cli/run_export.gd`** + `tools/run_export.sh`: **25 fogli A4 in scala 1:1**
  con i segni di taglio (carte 63×88 mm tre per tre, tessere Regione 80×80 due
  per tre), il mazzo espanso per `deck_copies` — 48 facce Asset fanno 132 carte
  — più `brief_arte.md` e un `README.md` che spiega come si stampa. In SVG, che
  è testo: due export escono identici byte per byte e la CI li confronta.
- **`art_placeholder.gd`**: il segnaposto che la ART_BIBLE chiedeva dalla 0.0 e
  che non esisteva. Mostra in chiaro la propria `art_prompt_key`, è **diverso
  per ogni chiave** in modo deterministico, e lascia libero il terzo basso —
  cioè rispetta il vincolo di composizione che dovrà rispettare l'arte vera.
- **`art_bible.gd`**: il brief **legge** i tre MASTER PROMPT dalla ART_BIBLE e ci
  mette dentro il soggetto che solo i dati conoscono. Il prompt resta del
  documento, il soggetto resta dei dati.
- **`ui/export_preview.gd`** dietro **F4**, anche dal menu: a sinistra il foglio
  com'è impaginato, a destra la carta a grandezza leggibile, frecce per
  scorrere. Disegna passando dalla stessa `PrintSheet.layout()` che scrive
  l'SVG: un'anteprima con un'impaginazione «somigliante» non è un'anteprima.

### Fixed

- Il testo dei Destini usciva dal bordo inferiore e il titolo di `DST_LYRA` da
  quello destro. Adesso l'impaginazione è una funzione pura che restituisce
  `overflow`, e un test lo chiede a **ogni faccia del set**: ne ha trovate
  subito altre due. Quando il testo non ci sta cede l'illustrazione, non il
  corpo — l'immagine scende fino al 34% della carta prima che il testo si
  stringa di un punto.
- I colori delle sei famiglie erano scritti due volte e i nomi delle funzioni di
  Propp tre. Adesso stanno in `card_face.gd` e le viste li leggono.

- **`docs/ISSUES.md`** (§25.16): quello che resta da fare, in pezzi apribili —
  13 voci con titolo, etichette, milestone, il perché e cosa le chiude, pronte
  da incollare su GitHub. Più due template in `.github/ISSUE_TEMPLATE/`: quello
  per le regole chiede i numeri **prima** della proposta, quello per i difetti
  chiede il seme, perché con il seme si rivede lo stesso identico anno.

### Trovato

- **Le otto chiavi `entity.*` non hanno un MASTER PROMPT.** I tre della
  ART_BIBLE sono carta Asset, carta Echo e tessera Regione, e nessuno è un
  ritratto. L'export lo dice in coda, e un test tiene il numero fermo a otto
  perché non cresca in silenzio. O si scrive il quarto prompt, o si tolgono.

---

## [0.1.17] — Una condizione pagata è sostegno

Fino alla 0.1.16 dichiarare Condition voleva dire dire «sono a favore, a un
patto», spendere fino a due Asset per qualificare la clausola e spostare il
margine di **zero**: la clausola si allegava solo se la proposta passava
comunque, portata dalle carte degli altri. Contro un Oppose — tre Asset, ogni
punto che sottrae, e una carta che torna in mano quando la proposta cade — non è
una scelta difficile: è una scelta dominata. E una posizione che nessuno prende
non è una posizione.

### Changed

- **§A5, `confluence_resolution.gd`**: `M = S + C − O + W`, dove C è il totale
  del fronte Condition **solo se la clausola qualifica** (soglia 2, come nei
  dati). Una condizione non qualificata non allega niente e non sposta niente, e
  le carte sono spese lo stesso: è il prezzo del negoziato, ed è ciò che tiene
  la Condition una scelta e non uno sconto ([D-055](docs/DECISIONS.md#d-055)).
- `condition_total` e `condition_qualified` restano nel risultato: il registro,
  il tabellone e il cruscotto continuano a mostrare i tre fronti separati. È
  cambiata la matematica, non quello che se ne legge.

### Misurato

Su 100 partite a tavolo misto (D-053), gli stessi 100 semi di prima:

| | 0.1.16 | oggi |
|---|---|---|
| Consigli caduti | 315 / 603 (52%) | **282 / 596 (47%)** |
| prudente (NONE/MIN/VIC/TRI) | 0 / 82 / 14 / 4 | 0 / **74 / 22 / 4** |
| aggressivo | 0 / 29 / 63 / 8 | 0 / 30 / **61** / 9 |
| DECISIVE_SUCCESS | 95 | **128** |
| seggi bloccati su un livello | 1 su 8 | **0 su 8** |

**Non risolve la voce aperta.** Bloccare resta il seggio più forte del tavolo:
l'aggressivo chiude 61 Vittorie contro le 22 del prudente. Questa regola rende
la Condition una mossa viva e toglie cinque punti ai fallimenti; non detronizza
l'Oppose. La voce «opporsi non costa abbastanza» resta aperta sulla roadmap, e
la seconda leva — un prezzo vero sul fronte contrario — è ancora da misurare.

---

## [0.1.16] — Il cruscotto

Tutto quello che questo progetto ha imparato sul proprio gioco è arrivato da una
sonda da riga di comando, e ogni volta con la stessa forma: qualcuno guarda un
numero che nessuno stava guardando e scopre che era lì da quattro milestone. Il
costo di quel giro è che bisogna esportare, rigiocare e rileggere un file —
quindi lo si fa solo quando si sospetta già qualcosa.

### Added

- **`dev_dashboard.gd`** (§25.14): le stesse quattro tabelle **dentro la partita
  in corso**, ridisegnate a ogni fase — le domande con quanto le ha spinte il
  *mondo* e quanto il *tavolo*, la scala di ogni Destino clausola per clausola,
  i Consigli con S/O/margine, e la coda del registro degli Effect con la
  sorgente di ogni riga.
- Sta dietro **F3** e non dietro un bottone, e lo dice in rosso in cima: mostra
  anche quello che al tavolo è coperto. Nella schermata di verifica il pannello
  del giocatore dice *«Il Risveglio — velata»* e il cruscotto, nello stesso
  fotogramma, dice *«Il Risveglio 5/6»*. È esattamente ciò che serve a chi
  sviluppa ed esattamente ciò che rovina una partita.

### Fixed

- Le clausole vere erano segnate con un segno di spunta che nel font non c'è, e
  una tabella di clausole vere e false usciva come una colonna di quadratini
  vuoti. Adesso `[x]` e `[ ]`, come li scrive già il resto del gioco.

---

## [0.1.15] — Il playtest, e dove la 0.1.14 aveva torto

La D-051 aveva concluso che gli esiti si raggruppano **perché a ogni seggio c'è
lo stesso ottimizzatore**, e non per come è scritto il contenuto. Era un'ipotesi
dichiarata senza prove. Questo è l'esperimento, e dice che era **giusta a metà**.

### Added

- **`table_of_characters.gd`** — quattro modi diversi di stare allo stesso
  tavolo: *prudente* (non si oppone mai, impegna una carta in meno),
  *aggressivo* (blocca tutto quello che non lo aiuta, impegna tutto),
  *distratto* (un giro su quattro fa un'altra cosa, legale), *ostinato* (gioca
  per il Trionfo dal primo round). Nessuno bara: stessi controlli di legalità.
- **`run_playtest.gd`** — 100 Chronicle, 50 per saga, i caratteri mescolati fra i
  seggi; poi gli **stessi 100 semi** rigiocati da quattro ottimizzatori identici.
  La differenza è il tavolo, non la fortuna.

### Misurato — dove l'ipotesi reggeva

Quattro seggi che sembravano bloccati non lo erano (MINIMUM / VITTORIA /
TRIONFO):

| seggio | quattro ottimizzatori | tavolo misto |
|---|---|---|
| Le Città Libere | 0 / **49** / 0 | 21 / 29 / 0 |
| Maestra Ilve | 5 / **43** / 2 | 21 / 24 / 5 |
| Vaerax | 4 / **43** / 3 | 26 / 19 / 5 |
| Priore Anselmo | 11 / **39** / 0 | 26 / 24 / 0 |

### Misurato — dove non reggeva

Due seggi non si muovono, e l'incrocio per carattere lo dice senza appello: il
giocatore migliore del tavolo, seduto lì, supera il Minimo **una o due volte su
dieci**. Kessa dei Fuochi 48 Minimi su 50, Lyra 47 su 50, e col giocatore
aggressivo 1 Vittoria su 10 e 2 Trionfi su 10. Non è un artefatto
dell'ottimizzatore: **quei due Destini costano troppo**, e la D-051 su questo
aveva torto.

### Fixed — quello che il playtest ha detto di sistemare

- **Lyra.** La sua Vittoria chiedeva la scorta giurata *e* che le gallerie non
  fossero sigillate — l'esatta negazione della Vittoria di Vaerax, che deve
  sigillarle. Due Destini che sono l'uno il contrario dell'altro li decide
  l'ordine di parola. La posta resta a lui: Lyra passa da **47 Minimi su 50 a
  39 / 0 / 11 Trionfi**.
- **Kessa dei Fuochi.** La sua Vittoria stava tutta su `ash_watch`, che si
  ottiene da *una* proposta di *un* Consiglio: se non lo apre lei, non c'è altra
  strada. Tenere la montagna in forze si raggiunge da più Consigli; la veglia
  sale al Trionfo. E la domanda della Cenere è stata resa raggiungibile (da 1 con
  soglia 5 a 2 con soglia 4). Da **48 Minimi su 50 a 45 / 5**.

Seggi bloccati su un solo livello a tavolo misto: **da 2 su 8 a 1 su 8**. Il
tavolo di quattro ottimizzatori, sullo stesso identico contenuto, ne blocca
**4 su 8**: la differenza fra i due numeri è tutta la conclusione.

### Provato e tolto — il prezzo dell'opposizione

`CNS_FAILURE_SPIRAL` promette nella propria descrizione «con meno tempo davanti e
più rancore intorno» e negli effetti non alzava niente. Aggiungere `+1` sulla
Tensione sembrava ovvio. **Misurato, ha fatto il contrario**: i fallimenti da 302
a 322 su cento partite — si è bloccato di *più* — e quattro Chronicle su 24 sopra
il tetto del §7, con un piano scritto a mano rotto. Tolto.

Bloccare resta la strategia migliore. Non si sistema con una Conseguenza: è la
matematica del resolver del §A5, e non si tocca senza dirlo. **Resta aperta.**

### Changed — il tetto

Il tetto del §7 nel test passa da 7 a 8, con la stessa aritmetica che aveva
spostato la banda: il §7 chiede 3-4 sulle **due** Tensioni del §18.2, cioè
1,5-2,0 per Tensione, e con quattro fa **6-8**. Ha cominciato a fallire
esattamente quando le correzioni hanno rimesso in gioco due seggi. Il
**pavimento non si è mosso**.

### E due cose che nessuno stava misurando

- **Un tavolo misto scrive una storia molto più varia**: 511 Verità, **479
  diverse** (94%), contro 448 e 322 (72%) del tavolo uniforme. Stesso contenuto,
  stessi semi: la varietà era nei giocatori.
- **Opporsi non costa abbastanza.** In cento partite l'aggressivo chiude
  32/57/11 e il prudente 86/14/**0** — nemmeno un Trionfo in cento partite. E un
  solo giocatore aggressivo su quattro porta i Consigli da 149 fallimenti a
  **302 su 593**: più della metà di quello che si propone cade. È la prima
  segnalazione di bilanciamento che arriva dal guardare gente che gioca in modo
  diverso, e non un giocatore che gioca bene.

---

## [0.1.14] — La parola gira, e un anno lasciato a metà si riprende

Due voci rimaste aperte: lo squilibrio registrato come O-15, e il salvataggio che
esisteva e non lo chiamava nessuno.

### Fixed — quello che era davvero rotto in O-15

Un **Minimo** gratis è giusto: dice «sei ancora al tavolo». Una clausola che
chiede l'*assenza* di un tag è una posta, non un regalo — il Trionfo di Aldric è
3/3 vero in partenza e lo raggiunge 2 volte su 40, perché è l'anno a
portarglielo via.

Erano rotte due **Vittorie** fatte solo di poste che nessuno attaccava: quella di
Vaerax reggeva in 37-40 Chronicle su 40, e quella dell'Ordine del Vetro l'aveva
resa tale la 0.1.11 mentre sistemava altro. Adesso chiedono una cosa da ottenere
in un Consiglio — il sigillo per Vaerax, la custodia riconosciuta per l'Ordine.

### Added — la parola gira

Chi ha aperto l'ultimo Consiglio su una domanda **si fa da parte**, se c'è
qualcun altro nella Regione di cui si discute. Serviva: la classifica del
proponente è deterministica, quindi in un accoppiamento stabile la stessa casata
apriva lo stesso Consiglio in tutte e quaranta le Chronicle misurate.
L'Ordine del Vetro passa da **0 a 39** Consigli proposti; la prima saga si
appiattisce da 94/65/50/35 a 80/52/60/59.

### Added — `promise_kept` finalmente usato

Collegarlo a un Destino ha mostrato perché la riga era rimasta aperta: **la
policy non aveva mai giocato FORGE**, quindi un rapporto non si muoveva, quindi
una promessa era mantenuta gratis e non si poteva rompere. Adesso forgia quando
una clausola glielo chiede.

Ha mostrato anche cosa *non* spedire: un `promise_kept` contro un
`promise_broken` lo decide l'ordine di parola, perché rompere costa un'azione e
ricucire costa un'azione **più** il consenso dell'altro e una carta BONDS. La
promessa è quindi una posta del Trionfo della Gilda, e a prendersela viene il
Destino *avanzato* della Cenere, che esiste solo dopo una saga.

### Added — riprendere un anno a metà

`run()` riparte dall'Atto e dal round su cui il mondo si trova, e la schermata
salva alla chiusura di ogni round. Due dettagli sono tutto, ed erano sbagliati
tutti e due alla prima stesura: **il round salvato è un round finito** (sbagliare
di uno lo rigioca, e l'anno esce diverso), e **un Atto ha una fine propria** —
fermarsi sull'ultimo round e ripartire dall'Atto dopo salterebbe la carta Echo.

Il test che conta non è che il file si rilegga: è che **un anno interrotto
finisca identico a uno mai interrotto** — stessi Consigli, stessi Destini, stesso
numero di Effect, stesse ultime dodici righe. Provato in due punti, e il secondo
è sul confine fra due Atti perché è il ramo che altrimenti si mangia una carta in
silenzio.

### Verificato anche nel browser

In un build Web `user://` sta in IndexedDB, che non è garantito: in navigazione
privata la pagina accetta la scrittura e la perde. La schermata chiede
`OS.is_userfs_persistent()` e non propone la ripresa se la risposta è no.

E la prova è stata fatta, non dedotta: esportato, giocati tre round nel browser,
**ricaricata la pagina**, e il menu è tornato con *«C'è un anno lasciato a metà —
Riprendi La Carestia Rossa, atto 1 round 3»* — e premendolo l'anno è arrivato
fino all'Atto 3 round 3, Consiglio e carta Echo compresi, senza errori.

### E cosa non si è mosso

Gli esiti restano raggruppati: diversi seggi stanno a 37-40 su 40 di un livello.
Quattro giri di modifiche hanno spostato *quali* seggi, mai la forma. La causa
non è il contenuto: con un ottimizzatore deterministico a ogni seggio e un
Consiglio per domanda, il risultato dipende da se il Destino punta a un Consiglio
che quel seggio può vincere. Registrato e lasciato lì — è quello che O-14 chiedeva
fin dall'inizio: serve un tavolo di persone vere, non un altro giro di manopole.

---

## [0.1.13] — Lo schermo non sa chi siede al tavolo

La 0.1.12 ha pubblicato una seconda saga completa — quattro casate, sei domande,
sedici Destini, due Chronicle — e **dal browser non se ne raggiungeva una riga**.

La colpa era di tre costanti, e nessuna delle tre era una cosa che lo schermo
avesse motivo di sapere: la lista dei quattro seggi della prima saga in
`game_screen.gd`, la tabella dei loro nomi lì accanto, e un `match` sugli stessi
id in `map_view.gd` per i colori della mappa — che infatti restituiva grigio per
ogni casata della seconda saga, su una mappa che è le stesse sei terre. Tutto il
resto di quello schermo leggeva già i dati.

### Changed

- **Prima si sceglie l'anno, poi il seggio**: chi siede al tavolo è quello che
  dice la Chronicle, e le due saghe non hanno nessuno in comune. Il menu elenca
  tutte le Chronicle nei dati, dalla più antica, con l'anno e se le domande sono
  scritte o pescate — quindi una terza saga compare nel menu semplicemente
  esistendo.
- **I colori si assegnano per ordine di parola**, non per nome.
- **La pagina delle regole nomina le persone davvero sedute**, e si ridisegna
  quando si sceglie l'anno invece che dopo aver scelto il seggio: un passo più
  tardi descriveva ancora l'epoca che il giocatore aveva appena scartato. E dice
  quante carte tiene il mazzo Echo **di quest'anno**, che dalla 0.1.12 non è più
  il totale.

### Added

- `test_ui_knows_no_names.gd`: **nessun id di Entità compare da nessuna parte
  sotto `res://ui`**, verificato contro tutti gli id nei dati. Uno schermo che
  nomina una casata ha un'opinione su quale saga si sta giocando, e non ne ha
  diritto.

### Verificato

Non con un test — il problema era invisibile ai test e lo sarebbe rimasto.
Esportato per il web e guidato in un browser vero: il menu elenca tutte e quattro
le Chronicle, scegliendo *Le Città Libere* si siedono Maestra Ilve, Kessa dei
Fuochi, Priore Anselmo e le Città Libere, il pannello delle domande legge
l'Acqua Ferma 3/6 e il Debito 2/7, le Montagne Rosse sono cerchiate del verde
della Cenere e la Strada dei Mercanti dell'oro della Gilda, e la console non
riporta errori.

---

## [0.1.12] — Una seconda saga sulla stessa mappa

Il motore dice da sempre di essere guidato dai dati. Questa è la prima volta che
qualcuno lo verifica: una **seconda saga** — trama, personaggi, obiettivi e
domande nuovi — scritta interamente in JSON, **senza toccare una regola**.

### Added

- **Le Città Libere**, ottocento anni dopo Aldric, sulle stesse sei terre. Non
  c'è una corona e non c'è da otto secoli. Quattro seggi: la **Gilda del Sale**,
  che non possiede nessuna città e tiene il registro di tutte; l'**Ordine del
  Vetro**, erede della scuola di Lyra diventata fede, custode di un frammento che
  nessuno dei vivi ha visto; i **Signori della Cenere**, che tengono le Montagne
  Rosse e scavano ogni anno più in basso; le **Città Libere**, sette città che si
  riuniscono solo quando non possono evitarlo.
- Sei domande — l'Acqua Ferma, il Debito, la Reliquia, la Carta, i Senza Città,
  la Cenere che Sale — sei Consigli, tredici Conseguenze, sedici Destini, dodici
  carte Echo, e due Chronicle: CHR_03 scritta, CHR_04 pescata dalla biblioteca.
- **`starting_control`** sulla Chronicle: chi tiene quale Regione all'apertura.

### Fixed

- **Il mazzo Echo era uno solo per tutto il gioco**: aggiungere dodici carte
  rimescolava il mazzo della prima saga e cambiava anni che nessuno aveva
  toccato — i tre piani scritti a mano si rompevano tutti. Adesso il mazzo di una
  Chronicle si costruisce con le carte che quell'anno possono contare, e i piani
  sono tornati identici byte per byte.
- **La mappa portava il controllo della prima saga**: le Montagne Rosse
  rispondevano ancora a Vaerax in una Chronicle dove Vaerax non esiste. Non era
  un dettaglio: l'intera Vittoria dei Signori della Cenere sta su una Regione
  tenuta, e non ne tenevano nessuna.
- **Undici probe avevano i seggi scritti dentro.** Adesso li leggono dalla
  Chronicle.
- Due volte, scrivendo il contenuto nuovo, si è ripresentato **lo stesso errore
  della 0.1.11**: una clausola di Destino appesa a qualcosa che quel seggio non
  può ottenere. La prima volta perché la Conseguenza stava su un Consiglio che
  non si tiene mai; la seconda perché due seggi avevano bisogno dello stesso
  Consiglio e a proporlo è uno solo. Le ha trovate entrambe la terza tabella
  della sonda dei Destini — *quali Consigli un seggio riesce davvero a proporre*.

### Misurato

CHR_03 su quaranta semi: 6,55 Consigli per Chronicle, mediana 7, da 5 a 7 — la
stessa forma di CHR_01 e dentro i limiti del §7. Ogni seggio vince qualche volta.

Due saghe da dieci Chronicle giocate per intero: la prima copre **999 anni** e
scrive **35 Verità, tutte e 35 diverse**; la seconda copre **753 anni** e ne
scrive 38, tutte diverse. L'audit da cui è partita questa serie di lavori ne
produsse 12 distinte su 28.

---

## [0.1.11] — Un Destino che si vince in due mosse, e uno che non si vince mai

Il seggio degli studiosi era rotto ai due capi di una saga, e nessuno dei due si
vedeva guardando gli esiti.

**Vinto al round due, quaranta volte su quaranta.** Il Destino di Lyra chiedeva
sette clausole, e **cinque erano già vere prima che venisse messo il primo
segnalino**. Le altre due erano Scoperte — e una Scoperta costa *un'azione*:
SCHEME su una Tensione velata. Lyra ha due Azioni nel primo round, e CHR_01 di
Tensioni velate ne distribuisce due. Risultato: tutta la sua scala — Minimo,
Vittoria *e* Trionfo — chiusa nell'**Atto I round due, 40 Chronicle su 40**, e le
altre diciassette Azioni spese a comprare carte che non le servivano. Il
rapporto di fine anno diceva TRIONFO; il registro diceva diciotto turni di
shopping.

**E mai vinto.** `DST_LYRA_TAUGHT` — il Destino a cui *avanza* fra una Chronicle
e l'altra — chiedeva nel Trionfo `crystal_measured`, `petition_heard` e
`parley_held`: **nessuna Consequence del gioco scrive nessuno dei tre**. Non era
difficile, era impossibile, ed è per questo che nella saga quel seggio risultava
MINIMO dieci volte su dieci.

### Added

- **`run_destiny_probe.gd`**: fa le due domande che rendono visibile tutto
  questo, e la prima non ha bisogno di dadi — **cosa è già vero prima che l'anno
  cominci**, clausola per clausola, e **a che round la scala di ogni seggio è già
  tutta chiusa**. Più: quali Consigli ogni seggio riesce davvero a proporre e
  quali tag finisce per indossare, perché «una Consequence scrive questo tag» e
  «questo seggio può ottenerlo» non sono la stessa domanda.
- Un controllo al boot: ogni clausola `state_tag_present` di ogni Destino deve
  chiedere un tag che qualcosa al mondo può scrivere. Un tag è una stringa —
  valida, si carica, ed è falsa per sempre.

### Changed

- **Il Destino di Lyra**, due clausole aggiunte e nessuna tolta. La Vittoria
  chiede ora la **scorta giurata**: dodici persone che rispondono di ogni carico
  col proprio nome, e si ottiene solo in un Consiglio. È la metà del titolo che
  non era mai stata implementata — *poter tornare a guardare*. Sapere qualcosa è
  il Minimo; poterci tornare è la Vittoria. Il Trionfo chiede in più che nessuno
  abbia messo **una guardia allo studio**.
- Il Trionfo di `DST_LYRA_TAUGHT` riscritto su tag che esistono, tenendo il
  senso: *quello che resta insegnato* è il sapere che gli altri possono ancora
  raggiungere e verificare — gallerie non sigillate, scorta giurata, nessun
  custode.
- La descrizione del piano C diceva che l'anno finiva col sapere «pubblico e
  verificabile». Quello che il piano gioca è `P_GUARDED_STUDY`: il Cristallo si
  può misurare, ma davanti a un custode. Col nuovo prezzo è esattamente ciò che
  a Lyra non basta, ed è un finale migliore di quello che il testo dichiarava.

### Misurato

| | prima | dopo |
|---|---|---|
| scala chiusa in anticipo (Lyra) | **40/40**, round 2,0 | 9/40, round 7,0 |
| Lyra | MIN 16 / VIT 4 / **TRI 20** | **MIN 34** / TRI 6 |
| Consigli CHR_01 | 5,70 | 6,10 |
| Consigli CHR_02 | 4,65, da 2 a 7 | 4,83, da 3 a 6 |

Una terza clausola è stata provata e tolta: `discovery:crystal` sul Trionfo, «e
il Cristallo lo ha misurato lei». Si legge bene e si misura male — Trionfo a
0/40 e Consigli fuori banda a 6,20 — quindi resta scritta nelle decisioni,
non nei dati.

**Cosa ha fatto emergere.** Sei livelli di Destino su dodici sono veri prima che
qualcuno giochi. Non tutti sono sbagliati: una clausola che chiede l'*assenza* di
un tag è una posta, non un regalo, e il Trionfo di Aldric è 3/3 gratis in
partenza e lo raggiunge lo stesso solo 3 volte su 40, perché è l'anno a
portarglielo via. Vaerax no: la sua Vittoria sono due tag assenti e basta, e la
prende in 37-40 Chronicle su 40 — in CHR_02, **40 su 40**. Registrato, non
ritoccato: questo giro ha già spostato un seggio dal primo all'ultimo posto, e
spostarne due insieme non si misurerebbe.

---

## [0.1.10] — Un anno non si chiude senza aver deciso niente

Una saga da dieci Chronicle ha prodotto **tre anni con zero Consigli**. Non anni
tranquilli: anni in cui nessuno ha proposto niente, non si è deciso niente e il
registro è rimasto in bianco. Il §7 chiede una segnalazione sotto i due.

La prima ipotesi — che fosse l'eredità fra una Chronicle e l'altra a spegnere le
Tensioni — era sbagliata, e a smentirla è stato lo strumento nuovo: contare gli
*esiti* dice che un anno è stato quieto, contare le **spinte** dice perché.

### Added

- **`run_silence_probe.gd`**: per ogni Chronicle stampa, per ogni domanda in
  gioco, da dove parte, quanti colpi le ha dato il **mondo**, quanti gliene ha
  dati il **tavolo** e dove finisce rispetto alla soglia; poi, per ogni seggio,
  il Destino che porta e cosa quel Destino gli chiede davvero di spingere.
- **`minimum_confluences`**: la Chronicle dichiara quanti Consigli garantisce.
  Quando un Atto si chiude e l'anno è ancora sotto quota, la domanda arrivata più
  vicina viene portata al punto — «L'anno non si chiude con la domanda ancora
  aperta». La quota cresce con l'Atto (`floor * atto / atti`), perché per il §7
  si apre un solo Consiglio per round e un pavimento di due controllato solo alla
  fine potrebbe consegnarne uno soltanto. La spinta è un Effect come tutti gli
  altri, con sorgente `YEAR_END` e il suo inverso; `0` lo spegne.

### Fixed

- **Il mondo da solo non può portare nessuna domanda al punto.** Il Drift dà un
  colpo per round diviso fra tutte le domande in gioco — nove colpi su quattro
  domande — mentre il salto più corto fra valore iniziale e soglia è tre. Il
  mondo può lasciare corte tutte le domande insieme, e negli anni muti è successo:
  quella arrivata più vicina si è fermata **a un colpo dalla soglia**, tre volte
  su tre. Ogni Consiglio ha bisogno che qualcuno spinga.
- **E il tavolo aveva smesso di giocare**: negli anni muti tre seggi su quattro
  hanno speso **tutte e diciotto le Azioni in ACQUIRE**, comprando carte per un
  Consiglio che non si sarebbe mai aperto.
- **Un seggio si fermava appena il gradino più vicino non gli chiedeva niente.**
  La policy giocava solo il gradino più basso non ancora conquistato: giusto
  sull'ordine, sbagliato su dove fermarsi. Un gradino può essere aperto e non
  chiedere niente alle Tensioni («stare sulle Montagne Rosse» si risolve
  camminando), e uno fatto di sole clausole negative non chiede niente a nessuno.
  Adesso si arriva al primo gradino che qualcosa chiede.

### Misurato

Quaranta semi per Chronicle. CHR_01 **non cambia** (media 5,70, mediana 6, da 3 a
8). CHR_02 passa da media 4,17 con minimo **1** a media 4,65, mediana 5, minimo
**2**, 0/40 sotto il pavimento del §7. Su quattro saghe da dieci Chronicle non
c'è più un solo anno muto. Il tavolo che sopprime e basta — quattro seggi che
spendono ogni azione per tenere giù ogni domanda — passa da 1,75 Consigli per
Chronicle a 2,48: è la prima volta che sta sopra il pavimento del §7 invece che
sotto. I tre piani di simulazione passano e restano identici
byte per byte.

---

## [0.1.9] — Una casa non finisce i nomi

La 0.1.8 dava a ogni seggio mortale quattro successori scritti a mano. Il primo
audit da dieci Chronicle li ha esauriti al sesto salto e ha rimesso a sedere un
**secondo «Re Serane» quattrocento anni dopo il primo**, con addosso la
descrizione del primo: nel 1240 risultava nipote di Aldric. Sembrava un errore,
ed era un errore — una saga non ha un numero di generazioni deciso in anticipo,
quindi qualunque lista finita finisce.

### Added

- **`name_grammar`**: una casa dichiara *come* fa i nomi invece di elencarli —
  un pattern con fessure (`{given} {epithet} {ordinal}`), un sacchetto di nomi,
  i titoli. Le prime generazioni restano scritte a mano, perché sono quelle
  caratterizzate; la grammatica subentra dalla quinta.
- **La numerazione** è quello che lo rende infinito *e* giusto: le case i nomi se
  li ripassano davvero, ed è esattamente per questo che li numerano. Vharn, e
  quattro generazioni dopo Vharn II. Trenta generazioni, trenta nomi distinti,
  con un test che lo pretende.
- Il nome è una **funzione pura della generazione**: nessun RNG, quindi è stabile
  a prescindere da quando lo si chiede e la saga resta rigiocabile dal seme.

### Fixed

- Il primo tentativo pescava dalla stessa lista dei quattro scritti a mano, e
  quindi la generazione 5 era di nuovo «Re Serane»: lo stesso errore, un giro
  più in là. E i titoli giravano indipendentemente dai nomi, producendo «Re
  Ottima» e «Regina Corvin». Adesso il titolo sta attaccato al nome.

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
