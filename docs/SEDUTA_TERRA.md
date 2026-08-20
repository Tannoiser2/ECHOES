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

## 6. Le domande secche

1. **C, A, o B?** (raccomandata: **C**, con **A** come primo passo)
2. **ISSUES 38 prima?** (raccomandato: **sì** — altrimenti misuriamo contro un
   vincolo rotto)
3. **La scala dei gradi**: tre (torre → castello → reggia) o due?
4. **La rovina è automatica** — nessuna presenza a fine anno, e la struttura
   scende di un grado — **o serve che qualcuno la causi?**
5. **Una struttura dà il controllo della Regione**, o lo dà solo *insieme* alla
   presenza?

---

*Nessuna riga di gioco è stata toccata per scrivere questo dossier. I numeri
vengono da 30 Chronicle a tavolo misto sui semi da 7000 e da una lettura dei
dati; le tre idee sono del committente, i prezzi sono stimati e dichiarati come
stime.*
