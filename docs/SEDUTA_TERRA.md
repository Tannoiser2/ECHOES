# La seduta sulla terra

Tre idee del committente, arrivate una dopo l'altra nella stessa mezz'ora, sono
la **stessa domanda** vista da tre lati:

> 1. «Il titolo deve dare qualcosa dentro l'anno, muoversi e avere maggioranza
>    deve pesare.»
> 2. «La presenza potrebbe essere anche non solo astratta ma indicata dalle
>    carte, tipo la guardia reale può giocare effettivamente una presenza in una
>    regione.»
> 3. «La presenza potrebbe essere anche mettere e costruire castelli, torri,
>    strutture che indicano presenza e controllo e passano da una partita
>    all'altra… un castello potrebbe andare in rovina o essere demolito, oppure
>    diventare una reggia.»

La domanda sotto è una sola: **come si rende visibile, costoso e duraturo il
possesso di un luogo?**

La prima è già stata percorsa e **respinta dalla misura**
([D-154](DECISIONS.md#d-154)). Questo dossier mette le altre due accanto a lei,
coi numeri veri e i prezzi, perché la scelta si faccia una volta sola invece che
tre.

---

## 1. Lo stato vero: due terzi della strada sono già asfaltati

Non si parte da zero, e conviene sapere esattamente da dove.

**Le strutture esistono, si costruiscono e attraversano gli anni.** Cinque tipi
(`structure:granary`, `structure:canal`, `structure:sealed`,
`structure:tollgate`, `structure:watchtower`), **11 carte** che li posano fra
Asset, Conseguenze e carte Narratore, e **5 regole dei segni** che li leggono —
il granaio dà voce sulla Carestia, sotto la torre di veglia si pesca forza, al
pedaggio girano i denari. E il prefisso `structure:` è nella lista di quelli che
**passano di Chronicle in Chronicle**, insieme a `scar:` e `settlement:`: a
differenza di `condition:`, che sbiadisce su un salto lungo, **una struttura non
sbiadisce mai**.

**Anche una carta che posa una pedina esiste già.** Tre Asset aggiungono
presenza quando li impegni — l'Atto di Successione, l'Ipoteca sulle Terre,
l'Ostaggio — e due la tolgono: Le Porte Bruciate, l'Esodo.

**E su 30 Chronicle giocate, il quadro è questo:**

| | |
|---|---|
| strutture alzate | **74** (≈ 2,5 per partita) |
| di cui pedaggi | **48** — e li posa un Asset, `AST_WEALTH_TOLL` |
| strutture **abbattute** | **0** |
| in piedi a fine anno | **2,00** per partita |
| partite con almeno una | **29 su 30** |
| pedine mosse per scelta | **38** con MUOVERE, 21 con una carta, 7 con un Consiglio — poco più di **una a partita** |

Due letture, e sono tutte e due importanti:

- **Le strutture funzionano già meglio della presenza.** Se ne alzano due e
  mezzo per partita contro una pedina mossa. La leva che il committente propone
  è già la leva che il gioco usa di più — solo che nessuno l'ha mai chiamata per
  nome.
- **Nessuna struttura è mai venuta giù.** In 30 anni giocati: 74 costruite,
  zero abbattute. Una struttura oggi è un interruttore che si accende e non si
  spegne più — e visto che passa anche fra le Chronicle, in una saga di dieci
  anni la mappa **può solo riempirsi**.

Il che, detto in fretta, è il difetto che l'idea 3 già corregge da sola: *un
castello può andare in rovina, essere demolito, o diventare una reggia.*

---

## 2. Il buco che le tre idee vogliono tappare

Da [D-152](DECISIONS.md#d-152) e [D-153](DECISIONS.md#d-153):

- il **controllo** non fa niente dentro l'anno — tre soli consumatori, due dei
  quali sono costi;
- la **mappa non si muove**: il 44% delle caselle non è di nessuno, e in un anno
  una casa guadagna in media un quarto di Regione;
- la **catena per prendere una Regione** ha cinque anelli e si spezza al terzo:
  63 rivendicazioni aperte, 15 portate a termine, 48 morte in mano.

E da [D-154](DECISIONS.md#d-154), la prima cura provata e bocciata: dare peso al
titolo **dentro il Consiglio** rimette i numeri in banda solo escludendo il
proponente, e comunque blocca un seggio su otto.

Il punto in comune fra le tre idee è che **spostano il possesso fuori dal
Consiglio**: invece di far pesare di più un titolo astratto quando si vota, gli
danno un corpo sulla mappa che costa qualcosa da mettere, si vede da lontano e
si può perdere.

---

## 3. Le tre strade, coi loro prezzi

### A. La carta che posa una pedina — *muoversi costa una carta*

Dieci-quindici Asset FORZA e GENTE che, impegnati o giocati, **mettono o
spostano presenza**. La Guardia Reale è la carta d'esempio: la giochi e c'è
qualcuno, lì, adesso.

- **Motore:** quasi niente. `ADD_PRESENCE` e `REMOVE_PRESENCE` esistono, hanno
  il loro inverso, e tre carte già lo fanno.
- **Scrittura:** media. Quindici carte con testo e mestiere.
- **Rischio:** basso, e **reversibile**: sono dati.
- **Cosa aggiusta:** «muoversi pesa». Le due famiglie che dovrebbero essere
  fatte di corpi — otto FORZA e otto GENTE — oggi alzano Tensioni e posano tag,
  ma non mettono nessuno da nessuna parte.
- **Cosa non aggiusta:** il titolo continua a non dare niente dentro l'anno.
- **Si misura?** Sì, subito: pedine mosse per scelta, e il playtest dei 100 semi.

### B. La carta *è* la presenza — *niente più gettoni astratti*

La pedina sparisce: metti **la carta scoperta** sulla Regione. La presenza
diventa una risorsa limitata e visibile; perdere una Regione è perdere una
carta; la maggioranza si legge sul tavolo senza contare niente.

- **Motore:** grosso. Tocca setup, mano, limite di mano, pesca, Consiglio.
- **Interfacce:** tutte e quattro — browser, console sui telefoni, vetrina,
  tastiera.
- **Rischio:** alto, e **non reversibile a costo zero**: cambia cosa vuol dire
  «avere una carta in mano», che è metà dell'economia del gioco.
- **Cosa aggiusta:** tutto insieme — il possesso visibile, il costo del
  muoversi, la maggioranza leggibile, e la vetrina che finalmente ha qualcosa
  da mostrare.
- **Il pericolo vero:** una carta sul tabellone è una carta che **non puoi
  impegnare al Consiglio**. Presidiare e argomentare diventano lo stesso
  budget — che è una tensione bellissima da giocare *e* il modo più rapido per
  rompere l'equilibrio dei Consigli, che si regge su tre carte impegnabili.
- **Si misura?** Solo dopo averla disegnata: non c'è modo di provarla a pezzi.

### C. Le strutture con una vita — *il castello che va in rovina o diventa reggia*

Il segno `structure:` smette di essere un interruttore e diventa una **scala**:

```
   cantiere  →  TORRE  →  CASTELLO  →  REGGIA
                  ↓          ↓            ↓
               rovina     rovina    ( e la rovina resta
                  ↓          ↓        una cicatrice )
              demolita   demolita
```

Le regole che servono, tutte già esprimibili col vocabolario che c'è:

- **si alza** con una Conseguenza o una carta (come oggi);
- **si sale di grado** spendendo qualcosa — la reggia è un castello a cui
  qualcuno ha aggiunto un'ala;
- **va in rovina** se a fine Chronicle nessuno ha presenza lì: è
  `lapse_without_presence` applicato alle pietre invece che al titolo, e dice
  la stessa cosa — *non si governa dove non si è*;
- **si demolisce** con una Conseguenza ostile, e lascia una `scar:`;
- **dà il titolo**: dove sta la tua struttura, la Regione è tua. Il controllo
  smette di essere una riga nello stato e diventa **una cosa che si vede**.

- **Motore:** medio. Il grado si scrive nel tag (`structure:castle:2`) oppure in
  un campo nuovo sulla Regione; la rovina è un giro di fine Chronicle accanto a
  quello che già fa decadere il controllo; il resto sono Effect che esistono.
- **Scrittura:** alta ma piacevole — è contenuto, non taratura.
- **Arte:** questa strada **chiede pezzi veri sul tabellone**, che è esattamente
  quello che il committente aveva chiesto tempo fa («sulla mappa vorrei token e
  pedine vere, no cerchietti»).
- **Rischio:** medio, e **incrementale**: si può accendere un grado per volta.
- **Cosa aggiusta:** il titolo dentro l'anno (le 5 regole dei segni già premiano
  chi ha una struttura), la mappa ferma (costruire è un modo di muoverla che non
  passa da un Consiglio), e la saga (una reggia in rovina all'anno 1200 racconta
  duecento anni in un colpo d'occhio).
- **Si misura?** Sì: strutture alzate, salite di grado, andate in rovina,
  abbattute; e il playtest.

---

## 4. Quello che nessuna delle tre aggiusta

Va detto prima e non dopo: **ISSUES 38 resta la porta chiusa**. La Vittoria
della Cenere ha una clausola sola, e questo rende il suo seggio incapace di
assorbire qualunque modifica — due varianti di D-154 sono state respinte da
Kessa e non dal proprio merito, con **una partita** di differenza.

Finché resta così, ogni strada di questo dossier verrà misurata contro un
vincolo che **il seggio più fragile del gioco** fa rispettare. La
raccomandazione operativa è secca: **ISSUES 38 prima di tutto il resto**, ed è
mezz'ora di scrittura d'autore, non un cantiere.

---

## 5. La raccomandazione

**C, dopo aver aperto ISSUES 38 — e A come contentino immediato se si vuole
qualcosa in giornata.**

Le ragioni, in ordine di peso:

1. **C è già la leva che il gioco usa di più.** 2,5 strutture per partita contro
   1 pedina mossa. Non stiamo aggiungendo un sistema: stiamo dando una vita a
   uno che c'è già e che oggi ha un difetto evidente — 74 costruite, **zero
   abbattute**, e in una saga la mappa può solo riempirsi.
2. **C risponde a tutte e tre le domande insieme.** Il titolo dà qualcosa
   (le regole dei segni), muoversi pesa (costruire è una mossa), e il possesso
   attraversa gli anni con una storia sua invece che come un booleano.
3. **C è incrementale.** Un grado per volta, misurato a ogni passo, e ogni passo
   è reversibile perché è quasi tutto dati.
4. **B è il gioco più bello e il rischio più alto**, e ha un difetto strutturale
   che va risolto a tavolino prima di scrivere una riga: presidiare e
   argomentare non possono pescare dallo stesso mazzo di tre carte senza
   riscrivere il Consiglio. Non è un no — è un «non adesso, e non senza un
   disegno».
5. **A è buona e piccola**, ma da sola lascia il titolo dov'è. Ha senso come
   primo passo *dentro* C: alcune di quelle carte, invece di posare una pedina,
   posano un cantiere.

---

## 6. Le domande secche — **risposte dal committente**

> «C e prima risolvi la issue 38, i tre gradi vanno bene, ma il cambio può
> dipendere da come vanno le cose, se la reggia appartiene all'entità che ha
> perso va in rovina, se invece trionfa diventa una reggia. La struttura da sola
> potrebbe non essere sufficiente per il controllo, se una entità ha un castello
> (che magari vale 3) ma un'altra ha un esercito che occupa la regione (che vale
> 4) la regione viene controllata da chi ha di più. Inoltre il castello è solo
> una delle strutture possibili, possono esserci foreste che spariscono o
> diventano maledette, passi di montagna che crollano, villaggi che nascono o si
> trasformano in città o vengono abbandonati.»

1. **Strada: C.** ISSUES 38 **prima** — ✅ chiusa in 0.1.122
   ([D-156](DECISIONS.md#d-156)).
2. **Tre gradi**, confermati.
3. **Il grado si muove con l'esito del Destino, non col tempo.** Chi *perde* va
   in rovina; chi *trionfa* sale. La struttura diventa il segno visibile di come
   e' andato l'anno — ed e' molto meglio di un decadimento a orologeria, perche'
   lega le pietre alla storia invece che al calendario.
4. **Il controllo e' una contesa di valori, non un titolo.** Ogni cosa che sta
   in una Regione porta un numero — un castello 3, un esercito che la occupa 4 —
   e **controlla chi ha di piu'**. E' la risposta piu' forte a D-152: il
   controllo smette di essere una riga di stato e diventa il risultato di un
   confronto che si vede sul tabellone.
5. **Le strutture sono una famiglia larga**, non solo fortificazioni: foreste che
   spariscono o diventano maledette, passi di montagna che crollano, villaggi che
   nascono, diventano citta' o vengono abbandonati. Ognuna con un effetto, un
   valore e delle conseguenze.

---

## 7. Cosa diventa il lavoro, con queste risposte

Le risposte cambiano la forma di C: non e' piu' «dare una vita al segno
`structure:`», e' **un livello nuovo della mappa**. Vale la pena dirlo prima di
scrivere una riga.

**7.1 — La struttura diventa un oggetto, non un tag.** Un tag e' un booleano;
qui serve un record con **tipo, grado, padrone e valore**. E' la modifica di
motore piu' grossa del lavoro, e va fatta per prima perche' tutto il resto ci
sta sopra. Il criterio di casa vale anche qui: passa da un Effect, ha il suo
inverso, e attraversa le Chronicle come gia' fa `structure:`.

**7.2 — Il controllo si calcola invece di essere assegnato.** Oggi
`SET_CONTROL` scrive un nome; domani il padrone e' **chi somma di piu'** in
quella Regione fra strutture e presenza. Due conseguenze da misurare, non da
dare per buone:

- le **14 Conseguenze** che oggi assegnano il controllo cambiano mestiere:
  non danno piu' una Regione, danno **una struttura** o **un peso**;
- `lapse_without_presence` diventa un caso particolare del conto — se non hai
  niente li', la somma e' zero.

**7.3 — La scala si muove col Destino.** A fine Chronicle, per ogni casa: chi ha
raggiunto il Trionfo alza di un grado una sua struttura, chi non ha raggiunto il
Minimo ne perde uno. La rovina lascia una `scar:`, come la demolizione.

**7.4 — Il catalogo.** Ogni tipo di struttura vuole: un nome, un valore, cosa
fa (una regola dei segni, come le 5 di adesso), come nasce, come sale, come
cade. E' contenuto d'autore, ed e' la parte piu' lunga — ma anche quella che si
puo' scrivere un pezzo per volta e misurare a ogni passo.

**7.5 — Quello che va deciso ancora**, e che queste risposte non coprono:

- **quanto valgono le pedine di presenza** nel conto del controllo (una a testa?
  o le tre insieme?);
- se una struttura si possa **prendere** invece che solo abbattere;
- cosa succede quando **due case pareggiano** in una Regione (nessuno controlla,
  o resta a chi c'era?);
- se il valore di una struttura pesi anche **al Consiglio**, o solo sulla mappa —
  cioe' se `focus_weight` ([D-154](DECISIONS.md#d-154), scritto e spento)
  torni acceso leggendo i valori invece del titolo.

L'ultima e' la piu' interessante: **la leva respinta in D-154 potrebbe essere
quella giusta una volta che il controllo e' un numero invece di un nome.**

---

*Nessuna riga di gioco è stata toccata per scrivere questo dossier. I numeri
vengono da 30 Chronicle a tavolo misto sui semi da 7000 e da una lettura dei
dati; le tre idee sono del committente, i prezzi sono stimati e dichiarati come
stime.*
