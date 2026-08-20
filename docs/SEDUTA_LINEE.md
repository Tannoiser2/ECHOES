# La seduta sulle linee generate

Il committente: «Io andrei oltre, farei un sistema che combina e permuta per
ottenere linee sempre diverse, un randomizzatore di obiettivi, entità e
incarnazioni che cambiano a ogni partita.»

Come le altre sedute: lo stato vero, una proposta concreta per pezzo, i costi
onesti, le domande secche in fondo.

---

## 1. Lo stato vero: il gioco è già a metà strada

Il principio che chiedi **esiste già nei dati**, e in due punti su tre:

- **Le domande si pescano da una biblioteca.** `CHR_02` e `CHR_04` non hanno
  domande scritte: hanno un `tension_pool` — sei candidate, quattro estratte,
  e ogni domanda porta con sé quali segni può lasciare sul mondo. Una partita
  di libreria è già **diversa a ogni seme**.
- **Le vite non sono una lista, sono una reazione.** Le incarnazioni scattano
  su *tag* — `FOUNDING`, `LINE_EXHAUSTED`, `ON_TAG`, `ON_DEATH` — quindi cosa
  diventi dipende da **cosa è successo**, non da un elenco scritto in ordine.
  Il Regno di Nahr nasce perché il popolo si è insediato; le Custodi della
  Cenere nascono perché la montagna è stata sigillata.
- **Chi siede è già permutato** nel playtest: i quattro caratteri di
  [D-053](DECISIONS.md#d-053) si mescolano fra i seggi a ogni partita, ed è
  quello che ha rotto i 40/40 di D-051.

Quello che **non** cambia mai: le quattro case di una Chronicle, e cosa
ciascuna vuole. Il Destino è uno per casa, scritto a mano, sempre quello.

## 2. Perché non basta «permutare i Destini»

La strada corta — mescolare i Destini fra le case — non funziona, e vale la
pena vedere *perché*, perché la ragione decide tutto il resto. Ecco un Destino
vero, quello della Gilda del Sale:

> **Il Registro che Tiene** — «La Gilda non vuole comandare: vuole che quello
> che è scritto continui a valere, e che a scriverlo sia lei.»
> · minimo: la Gilda esiste ancora **e ha presenza sulla Strada dei Mercanti**
> · vittoria: **`debt_called`** è stato scritto e **`debt_forgiven`** no
> · trionfo: **il patto con i Signori della Cenere regge**, il registro non è
> pubblico, copre due Regioni, e **Il Debito** resta sotto 5

Un Destino è legato alla sua casa in **tre modi diversi**, e solo il primo è
facile da sciogliere:

1. l'`entity_id` — banale, si riscrive;
2. le **condizioni nominano cose specifiche**: una Regione (`REG_STRADA_MERCANTI`),
   un'altra casa (`ENT_CENERE`), i tag di quell'epoca (`debt_called`);
3. **la prosa**. «La Gilda non vuole comandare» non si può dare alla Cenere.

Permutato a caso, esce un mercante che deve svegliare un drago con clausole
che citano segni di un'altra epoca. Non è varietà: è rumore. E il rumore in
questo gioco costa il doppio, perché il verbale lo *racconta* — ci si ritrova
a leggere ad alta voce frasi che non vogliono dire niente.

## 3. Le quattro strade, coi loro prezzi

### A. Il pool dei Destini — *ogni casa vuole cose diverse in partite diverse*

Ogni casa porta **due o tre Destini possibili**, tutti scritti per lei, e a
inizio Chronicle ne pesca uno. Esattamente il meccanismo del `tension_pool`,
applicato agli obiettivi.

- **Costa**: 2–3 Destini per casa invece di 1 — cioè 8–12 Destini nuovi per
  linea, tutti scrittura d'autore.
- **Nel motore**: pochissimo. `destiny_pool` sulla Chronicle, un'estrazione al
  setup. Il resto è già lì (le vite hanno già un `destiny_pool` per vita).
- **Guadagna**: la stessa casa gioca partite diverse, e — il punto che conta
  di più al tavolo — **nessuno sa più cosa vuole l'altro**. Oggi alla terza
  partita lo sanno tutti.
- **Rischio**: basso. Ogni Destino resta scritto per la sua casa.

### B. Il ruolo staccato dalla casa — *la combinatoria vera*

I Destini diventano **ruoli astratti** — il Guardiano, il Registro, l'Erede,
l'Esule — con condizioni scritte per *slot* (`$la_mia_regione`, `$il_rivale`,
`$il_segno_che_temo`) invece che per nomi, e si assegnano a caso.

- **Costa**: il sistema di condizioni va riscritto con i binding, come già
  fanno le Consequence con `$region_focus` e `$rival_seat` — la macchina c'è,
  ma i Destini non la usano.
- **Guadagna**: quattro case × sei ruoli = ventiquattro tavoli diversi da
  sei ruoli scritti.
- **Rischio**: **il sapore**. Un ruolo che vale per chiunque non può dire «la
  Gilda non vuole comandare»: dirà «questa casa vuole che ciò che è scritto
  continui a valere». Il gioco diventa più vario e meno *suo*. È il compromesso
  vero di tutta questa seduta, e non è tecnico: è di gusto.

### C. La linea generata — *un compositore di epoche*

Un generatore che pesca case, domande, Destini e incarnazioni da mattoncini e
compone una linea nuova a ogni saga.

- **Costa**: tantissimo, e il grosso non è il codice — è il **vocabolario di
  mattoncini** che regga la ricombinazione senza produrre assurdità, più le
  regole di coerenza (una casa mercantile non può avere l'obiettivo del drago
  se sulla mappa non c'è un drago).
- **Rischio**: alto e già noto al progetto. Le domande in libreria sono
  ricombinabili perché sono **sei domande scritte a mano** e il pool sceglie
  fra quelle. Un generatore che *inventa* le domande produrrebbe testi che
  nessuno ha scritto — e questo gioco è fatto di frasi che qualcuno ha scritto.

### D. Più vite, e vite che dipendono da come è andata

Le incarnazioni sono già reattive: se ne scrivono **altre**, con condizioni
d'ingresso diverse, e la stessa casa diventa cose diverse a seconda della
partita. Oggi ogni casa ne ha 3; con 5–6 e ingressi più fini, due saghe non
si somigliano più.

- **Costa**: solo scrittura. Il motore c'è tutto.
- **Guadagna**: la varietà **dentro la saga lunga**, che è dove serve di più
  (vedi sotto).
- **Rischio**: nessuno di architettura.

## 4. Il collegamento che rende urgente questa domanda

La saga del Sale ha appena mostrato un difetto ([ISSUES 35](ISSUES.md)): dal
1981, quando le istituzioni sostituiscono le persone, **sedici Destini su
venti finiscono al Minimo** — e non perché il tavolo si blocchi, ma perché i
Consigli riescono e non portano nessuno da nessuna parte.

Le clausole delle vite tardive parlano di **continuità**, e la continuità si
ottiene stando fermi. Ora si guardi la stessa cosa dal punto di vista della
tua proposta: **se ogni Chronicle la casa pescasse un obiettivo diverso, stare
fermi smetterebbe di essere sempre la risposta giusta.** La strada A non è
solo varietà: è la cura più probabile per l'appiattimento della seconda metà.

Questo è il motivo per cui la strada A viene prima delle altre, qualunque cosa
si decida sulle altre tre.

## 5. La raccomandazione

**A + D adesso, B come esperimento misurato, C mai — o meglio: C solo il
giorno in cui il vocabolario di mattoncini esiste già perché A e D lo hanno
costruito.**

- **A e D** danno la maggior parte della varietà che chiedi, costano
  scrittura e non architettura, non mettono a rischio una riga di quello che
  funziona, e attaccano ISSUES 35.
- **B** è la combinatoria vera e va provata **su una casa sola**, misurando
  cosa succede al verbale: se le frasi reggono, si estende; se diventano
  generiche, si è imparato qualcosa con un decimo del lavoro.
- **C** è la strada che produce mondi che non significano niente, e questo
  gioco vive del contrario.

C'è una cosa che vale per tutte e quattro, e va detta prima di cominciare:
**oggi non sapremmo misurare se ha funzionato.** Le sonde misurano il motore,
e questa è una domanda sul *contenuto* — «le partite sono diverse fra loro?»
non è FAIL 185 · 0/8. Servirebbe una misura nuova: la **distanza fra due
saghe** — quante domande diverse, quanti Destini diversi raggiunti, quante
frasi del verbale mai viste prima. Senza quella, si aggiunge contenuto e si
spera.

---

## 6. Le domande secche

- **A. Il pool dei Destini**: si fa? E quanti per casa — due (una scelta
  secca) o tre (una vera incertezza)?
- **B. I ruoli staccati dalle case**: si prova su una casa sola per vedere che
  fine fa la prosa, o si lascia stare perché il sapore vale più della
  combinatoria?
- **C. Il generatore di linee**: lo teniamo dichiarato come «non adesso», o lo
  vuoi come orizzonte da cui far discendere le scelte di A e B?
- **D. Più vite per casa**: da 3 a 5–6, con ingressi che dipendono da come è
  andata la partita?
- **E. La misura**: prima di aggiungere varietà, si costruisce la **distanza
  fra due saghe** (una sonda che dica quanto due partite si somigliano), o si
  aggiunge prima e si misura dopo?
