# ECHOES — Componenti

Quale testo sta su quale pezzo, cosa si stampa, cosa sta sullo schermo, cosa è
segreto e dietro quale paravento.

Questo documento non era in nessuna specifica: la ART_BIBLE decide *come* si
disegna, l'ASSET_MANIFEST *cosa* esiste, RULES_V0_2 *come funziona*. Mancava chi
dicesse **dove va a finire**, ed è la domanda da chiudere prima di disegnare 48
carte.

Ogni riga qui è ricavata da `godot/data/**`, che è la sorgente unica: le stesse
righe JSON producono le carte da stampare (`CardView` + Export Preview, 0.1) e le
schermate. Il testo non si scrive due volte.

---

## 1. La divisione, in una frase

**ECHOES è un gioco da tavolo fisico con un'app, non uno dei due.**

- **Fisico** tutto ciò che è **stabile** e che vuoi in mano o sul tavolo.
- **App** tutto ciò che è **condizionale** — cioè che dipende dallo stato del
  mondo in quel momento — e tutto ciò che è **privato di un solo giocatore**.

La roadmap conferma la direzione: 0.5 computer vision su marker fiducial, 0.6
print-and-play e sincronizzazione tavolo/digitale, 1.0 Chronicle Book.

---

## 2. Dove sta il testo

Al momento della scrittura il set di Chronicle I è **305 frasi, ~3.300 parole,
circa 13 pagine**.

| blocco | frasi | dove sta | segreto? |
|---|---|---|---|
| **Confluence** (domande, proposte, clausole, esiti) | 79 | **app** — vedi §3 | no, si legge ad alta voce |
| **Consequence** | 74 | *non si leggono*: si **vedono sulla mappa** come overlay | no |
| **Carte Echo** | 47 | **sono carte.** Si pescano a fine Atto e si leggono al tavolo | no |
| **Destiny** | 44 | **carta Destiny personale**, dietro il paravento | **sì** |
| **Tensione** (presagi, trigger, regole di discesa) | 23 | traccia Tensione sul tabellone; i presagi li dice l'app quando scattano | il *valore* di una Tensione velata sì |
| **Regioni** | 13 | retro della tessera Regione, o libretto | l'informazione privata di Regione sì |
| **Azioni** | 6 | **plancia giocatore**, stampata una volta. Le sei azioni non cambiano mai | no |
| **Entità** | 10 | carta Entità; `private_information` dietro il paravento | quella parte sì |
| **Asset** | 5 | sulle 48 carte | la **mano** sì |
| **Apertura Chronicle** | 4 | letta ad alta voce dal libretto, all'inizio | no |

Circa **due terzi delle frasi stanno su componenti fisici.**

---

## 3. Perché la Confluence non può essere un libretto

È l'unico blocco davvero condizionale, per cinque motivi indipendenti — e ognuno
da solo basterebbe.

1. **`eligibility`.** *"Il grano è requisito"* la può dire solo chi porta la
   corona. Si può stampare la condizione, ma qualcuno deve verificarla contro lo
   stato di quel momento.
2. **Le domande si sbloccano.** *"A chi appartiene la terra che ancora produce?"*
   esiste solo con la Tensione ≥ 6.
3. **Le frasi hanno degli slot.** *"Chi nutre `$the_region` quando i granai si
   svuotano?"* diventa *la Valle Verde* o *le Terre Nahr* a seconda di dove è la
   fame ([D-028](DECISIONS.md#d-028)). Su carta sarebbe una frase sola, sbagliata
   metà delle volte.
4. **Il valore di una Tensione velata è personale.** SCHEME lo rivela **solo a
   te**. Fisicamente impossibile su una plancia condivisa senza uno schermo
   privato.
5. **Le conseguenze durano tre Atti.** Controllo, tag, cicatrici, relazioni: un
   umano se ne dimentica entro il secondo round.

### Come funziona al tavolo

La Confluence Board mostra **solo le opzioni legali adesso** — tipicamente 2 o 3
proposte, non un catalogo. **Il proponente le legge ad alta voce.** Lo schermo fa
da gobbo per una persona alla volta; non è una cosa che quattro persone fissano.

È la differenza fra un gioco da tavolo con un'app e un videogioco a cui si gioca
in quattro. Se tutti guardano lo schermo il gioco è morto: la discussione è il
prodotto.

---

## 4. I pezzi fisici

Dal manifest generato ([ASSET_MANIFEST.md](ASSET_MANIFEST.md)), con il traguardo
§19.4 fra parentesi:

| pezzo | 0.0 | 0.1 | si ristampa per una Chronicle nuova? |
|---|---|---|---|
| carte Asset | 12 | 48 | **no, si riusano** |
| carte Echo | 24 | 24 | no — sono le funzioni di Propp, vocabolario permanente |
| tessere Regione | 6 | 12 | solo se cambia la mappa |
| overlay mappa | — | 24 | no: si **aggiungono** alla mappa esistente |
| standee / token presenza | — | 12 | no |
| plance azione, paraventi, tracce Tensione | — | 4 + 4 | no |
| **carte Tensione** | 6 | — | **sì** |
| **carte Destiny** | 4 | — | **sì** |

Una Chronicle nuova è quindi **un'espansione da poche decine di carte**, non una
scatola nuova. E con il modello a biblioteca ([D-028](DECISIONS.md#d-028)) anche
le carte Tensione si riusano: è la Chronicle che ne pesca quattro, non l'autore
che le riscrive.

### La mappa non si ristampa: si modifica

Gli overlay sono livelli indipendenti sopra la tessera: `structure:`,
`condition:`, `settlement:`, `scar:`. La Valle Verde alla decima Chronicle è la
stessa tessera con sopra dieci anni di segni. È il meccanismo Legacy, ed è già
nel modello dati — `INHERITED_TAG_PREFIXES` in `world_state_factory.gd` è
esattamente l'elenco di cosa sopravvive a un anno.

---

## 5. Cosa è segreto, e dietro quale paravento

| informazione | chi la vede | come |
|---|---|---|
| il tuo Destiny | solo tu | carta personale dietro il paravento |
| la tua mano di Asset | solo tu | carte in mano |
| il valore di una Tensione **velata** | solo chi ha speso SCHEME | **app, schermo privato** — non replicabile su carta |
| l'informazione privata di una Regione | chi ha speso SCHEME su quella Regione | app |
| gli impegni in una Confluence | segreti fino alla rivelazione simultanea | app, o carte a faccia in giù |
| tutto il resto | tutti | tabellone e log pubblico |

La riga in grassetto è quella che **obbliga** all'app. Senza, la Tensione velata
o diventa pubblica o richiede un quinto giocatore che fa da arbitro.

---

## 6. Cosa resta alla fine

Il registro delle Truth è permanente e non si può annullare. A fine Chronicle
l'app lo esporta e diventa il **Chronicle Book** (roadmap 1.0): si stampa, e resta
sul tavolo per la campagna successiva.

È l'unico pezzo di carta che il gioco **produce** invece di consumare.

---

## 7. Quello che questo documento non decide

- Il formato fisico (dimensioni carte, materiale del tabellone, tipo di
  paravento). Sono scelte di produzione, non di design.
- Se l'app giri su un tablet condiviso passato di mano o sui telefoni dei
  giocatori. La Tensione velata funziona in entrambi i casi; il secondo è più
  comodo e più costoso da costruire.
- Il numero di componenti della scatola base contro le espansioni.

Vanno decise prima della 0.6 (print-and-play), non prima della 0.1.
