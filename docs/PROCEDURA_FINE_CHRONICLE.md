# La fine della Chronicle — la procedura al tavolo

*(PZ-6, [D-269](DECISIONS.md#d-269). La garanzia che questa pagina basti è
misurata: `godot/tests/unit/test_visible_handover.gd` gioca un anno intero,
spoglia il mondo fino al solo tavolo visibile — la lista chiusa di
`godot/scripts/chronicle/visible_table.gd` — e pretende che l'era nuova nasca
**identica** da quello e dal mondo intero. Se il motore un giorno leggesse
qualcosa che non sta su questa pagina, quella prova va rossa.)*

La Chronicle è finita. Prima di smontare, si esegue questa sequenza — a mano,
guardando solo quello che c'è sopra il tavolo e sul foglio della saga.

---

## 0. Quello che si legge, e dove sta

| pezzo fisico | cosa dice |
|---|---|
| **carta del casato** | nome, generazione, vita in corso, ere a mani vuote, vivo/spento |
| **segni sul casato** | i tag vivi addosso (`#marchiato`, `life:...`, promesse) |
| **pedine sulla mappa** | la presenza di ogni casato, tessera per tessera |
| **foglio della saga** | anno, ere giocate, punteggio di saga, obiettivi coperti |
| **tessere** | i segni sopra, chi la tiene, le pietre (tipo, grado, padrone) |
| **cicatrici** | restano incollate alla tessera che le porta |
| **carte Tensione in gioco** | valore del segnalino, faccia palese o coperta, presagi scattati, quante volte decisa |
| **la pista dei rapporti** | il livello fra ogni coppia di casati, coi suoi segni |
| **segni del mondo** | i tag globali al centro del tavolo |
| **il diario** | gli Echo giocati e le Verità scritte, in ordine |

**Quello che NON serve leggere** — e infatti si smonta senza guardarlo:
l'ordine dei mazzi (si rimescola), le mani (si ridanno), le domande già poste
(sono dell'anno), i diritti pendenti del RIVENDICARE, i gettoni dei Temi
(spesi a fine Atto), la memoria di chi ha votato con chi.

---

## 1. Si leggono i Destini

Ogni casato legge la sua scheda del Destino sui segni visibili:
Minimum, Victory o Triumph. Sul foglio della saga si aggiorna il
**punteggio di saga**; un Destino rimasto a mani vuote segna **+1 alle ere a
mani vuote** sulla carta del casato (a mani piene il contatore si azzera).
Questi esiti sono la *lettura del tavolo*: entrano nel setup dell'era dopo
così come sono stati letti.

## 2. Il diario resta

Gli Echo giocati e le Verità scritte non si toccano: sono la memoria della
saga, e l'era nuova li eredita per intero.

## 3. Il tempo passa

L'anno nuovo = anno vecchio + **il salto dichiarato dalla Chronicle che
arriva** (un numero, o una forchetta da cui si pesca). Il salto decide tutto
il resto della procedura:

- **salto breve** (sotto i 50 anni): si ricorda tutto com'era;
- **salto lungo** (50 anni o più): il tempo lavora —
  - le **condizioni** (`condition:...`) sulle tessere si tolgono: un lutto
    dell'anno 1002 non è in corso otto secoli dopo;
  - i **rapporti** si ammorbidiscono di **un passo verso NEUTRAL**;
  - i **fatti del mondo** non murati diventano **leggende** (`legend:...`):
    veri come la memoria, non come il mondo. Le leggende, una volta nate,
    attraversano ogni salto successivo. Quello che la Chronicle nuova dichiara
    *murato o scritto* (`enduring_facts`) passa com'è.

## 4. La mappa è della saga

Le tessere restano quelle pescate alla prima Chronicle, **posate come alla
prima pesca**: in griglia 3×2, riga per riga, nell'ordine di pesca — e la
posa È l'adiacenza (D-275: vicino è chi si tocca di lato o di sopra).
Su ognuna:

- **il titolo**: chi la teneva **senza nessuna pedina sopra** la perde prima
  che l'era nuova apra (se la Chronicle gioca con `lapse_without_presence`) —
  la dinastia che si è allargata troppo perde i bordi per prima. Un titolo di
  un casato che non siede più resta alla terra;
- **le pietre** passano com'erano — tipo, grado, padrone — e il padrone segue
  la stessa regola del titolo: senza pedine dentro, le pietre restano di
  nessuno;
- **i segni murati o scritti** (insediamenti, pietre, cicatrici) restano;
- **le cicatrici restano sempre**: sono la memoria visibile della mappa.

## 5. La successione

Per ogni casato, sulla sua carta:

- la linea che **si esaurisce** (le ere a mani vuote arrivano al limite della
  casa) passa alla **vita successiva**: nome nuovo, segno `life:` addosso,
  generazione avanti;
- il seggio **morto** rivive nella sua vita `ON_DEATH`, se la dichiara;
- i **segni del mondo possono scegliere** (`ON_TAG`): se il segno dichiarato
  è al centro del tavolo, la vita indicata si siede;
- altrimenti: la **generazione avanza** col salto lungo (un erede col nome
  nuovo), o resta la stessa persona su un salto breve.

I **tre obiettivi coperti sono della saga**: passano al casato che li aveva,
finché la saga dura. Chi si siede adesso e prima non c'era pesca i propri.

## 5-bis. Chi siede l'anno prossimo — **si ripesca**

**Questa è la regola, ed è una scelta** ([D-431](DECISIONS.md#d-431), parola del
committente): fra un anno e l'altro della saga **il tavolo si ripesca dal pool
delle otto case**. Su una saga di dieci anni, poco più della metà dei seggi
resta alla stessa casa: le altre cambiano.

> **Va saputo prima di affezionarsi ad Aldric.** In una saga si gioca **il
> mondo**, non la propria casa: *le Azioni cambiano il mondo, il Consiglio
> decide cosa il mondo ricorderà*. Le case passano — è il senso stesso delle
> ere, delle generazioni e delle leggende. Chi si siede eredita un mondo che
> qualcun altro ha piegato, e il punteggio della saga resta del **casato**, non
> di chi lo tiene in mano quest'anno.

Al tavolo: si rimettono nel sacchetto le otto carte casato, si pescano le
quattro dell'anno nuovo, e chi rientra riprende la sua carta **con sopra tutto
quello che aveva** — generazione, vite, segni, punteggio di saga.

**La regola è scritta sulla Chronicle** (`seats_between_eras`), e vale anche per
le altre due che il gioco sa eseguire, se un giorno si vorranno provare:
*«siedono gli stessi»* e *«si ripesca, ma chi c'era ha precedenza»*.

## 6. Si rimonta il tavolo

- **mani nuove** a tutti, dai mazzi rimescolati;
- **i mazzetti dei sei Temi** si rimontano con le carte Tensione che la mappa
  regge, coperti, gettoni a zero;
- le **Tensioni** che l'era nuova apre pescano ascoltando i segni ereditati
  (gli echi del pool leggono il tavolo appena rimontato);
- le **presenze di apertura** si posano come la Chronicle nuova dichiara, sul
  mondo appena ereditato.

## 7. Il verbale d'apertura

Si legge ad alta voce (l'app lo stampa in testa al log): le successioni
(«al posto di X siede Y»), i conti aperti dell'era prima, e la mappa che si
eredita — chi tiene cosa, e cosa il tempo ha sbiadito.

---

*Regola madre: se per rimontare l'era nuova ti serve un'informazione che non
sta nella tabella del punto 0, la procedura è rotta — o il pezzo mancante
diventa fisico e dichiarato qui, o il motore smette di chiederlo. La prova
`test_visible_handover.gd` esiste per accorgersene prima del tavolo.*
