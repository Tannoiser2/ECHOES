# ECHOES — Art Bible

> **Nota sulla provenienza.** La specifica v0.2 §20 dice che i tre MASTER PROMPT
> e le variation key «restano quelli della v0.1, da riportare integralmente
> qui». Il documento v0.1 non era allegato al brief consegnato, quindi i prompt
> sotto sono stati **scritti ex novo** rispettando la direzione visiva del §20 e
> i vincoli tecnici del §21. Se esistono gli originali della v0.1, sostituiscili:
> l'unica cosa che il codice usa è la chiave `art_prompt_key`, che resta valida
> in entrambi i casi.

---

## Direzione visiva

Dark fantasy storico, pittorico, elegante. **Non** horror splatter: la violenza è
conseguenza, non spettacolo. Leggibilità da boardgame premium — l'immagine deve
funzionare a 60 mm di larghezza su un tavolo illuminato male.

Palette: terre bruciate, ocra, verdi spenti, pietra grigio-rossa. Un solo accento
saturo per famiglia. Luce laterale bassa, tipo tardo pomeriggio o interno a
candele. Nessun neon, nessun bagliore magico generico.

**Regole invalicabili:**

1. **Nessun testo dentro l'immagine.** Nomi, numeri, icone, cornici e regole sono
   composti da Godot (§21). Un'illustrazione con testo rasterizzato è da rifare.
2. **Area di respiro per l'overlay.** Ogni immagine riserva una fascia meno
   dettagliata dove andrà il testo: bassa sulle carte, alta sui tile Regione.
3. **Gli Asset sono scene, le Casate sono ritratti.** Un Asset può avere volti,
   e anche in primo piano. *Cambiata in 0.1.21, alla prima carta consegnata*
   ([D-060](DECISIONS.md#d-060)): la regola diceva «nessun volto sulle carte
   Asset», e il Censimento senza la fila che aspetta non è il Censimento — una
   scena di spalle si disegna, ma costa naturalezza a ogni singola carta, e
   quarantotto volte è un prezzo che non vale il vincolo.
   La distinzione fra i due mazzi passa adesso dalla **composizione**: l'Asset è
   una **scena** — un luogo, un gesto, delle persone dentro una cosa che sta
   succedendo — mai un ritratto singolo centrato; la Casata è un **ritratto**,
   una figura sola, ravvicinata, che guarda chi la guarda.
4. **Coerenza di scala.** Una Folla e una Leva Contadina devono sembrare lo stesso
   mondo visto da due distanze.

---

## MASTER PROMPT 1 — Asset card

```
Historical dark-fantasy painting, single evocative scene depicting {SOGGETTO}.
Painterly oil technique, visible brushwork, muted earth palette with a single
{ACCENTO} accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
```

**Variation key per famiglia** — sostituisci `{ACCENTO}` e usa i soggetti come
guida:

| famiglia | accento | soggetti | tono |
|---|---|---|---|
| **FORCE** | rosso ossido | armi appoggiate, palizzate, fumo all'orizzonte, uomini visti di spalle | minaccia trattenuta, mai battaglia in corso |
| **AUTHORITY** | oro spento | sigilli, pergamene, troni vuoti, scalinate, catene d'ufficio | peso e distanza, mai pompa |
| **PEOPLE** | terracotta | folle a media distanza, mani, code, fuochi da campo | numero, non individui |
| **KNOWLEDGE** | verde-azzurro pallido | strumenti di misura, sezioni, appunti, gallerie illuminate | precisione fredda, curiosità |
| **WEALTH** | ambra | granai, carovane, casse, bilance, sacchi | abbondanza precaria, mai opulenza |
| **BONDS** | porpora tenue | mani che si stringono, nodi, doni scambiati, tavole condivise | intimità formale |

Chiavi in uso: vedi la colonna `art_prompt_key` di
[ASSET_MANIFEST.md](ASSET_MANIFEST.md) (`asset.<famiglia>.<nome>`).

---

## MASTER PROMPT 2 — Echo card

```
Historical dark-fantasy painting of a narrative moment: {SOGGETTO}. Painterly oil
technique, muted earth palette, {ACCENTO} accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

**Variation key per famiglia drammatica:**

| famiglia | accento | registro | esempi |
|---|---|---|---|
| **PRESSIONE** | grigio-ocra | qualcosa manca o incombe | granai socchiusi, code, un segno che nessuno sa leggere |
| **ROTTURA** | rosso scuro | un legame cede | una tavola rovesciata, una porta forzata, un posto vuoto |
| **SVOLTA** | bianco freddo | qualcosa di nascosto diventa visibile | una misura presa, una lampada che si riaccende, una prova mostrata |
| **RISOLUZIONE** | oro caldo basso | qualcuno paga e la questione si chiude | mani che restituiscono, un sigillo posato, due parti che si siedono |

Chiavi in uso: `echo.<famiglia>.<funzione>`.

---

## MASTER PROMPT 3 — Region tile

```
Top-down three-quarter painted map tile of {REGIONE}: {DESCRIZIONE}. Historical
dark-fantasy cartography crossed with painted landscape, muted earth palette,
{ACCENTO} accent. Readable terrain silhouette from above, clear edges that can
tile against neighbouring regions. Composition: the centre is deliberately calm
and uncluttered so overlay tokens (control, presence, condition, scar) sit legibly
on top; detail concentrates at the borders. Square framing. No text, no letters,
no numerals, no map labels, no compass rose, no frame. Boardgame map tile art.
```

**Variation key per biome:**

| biome | accento | descrizione guida |
|---|---|---|
| `CITY` | oro spento | tetti fitti, mura, una piazza, magazzini sul lato |
| `VALLEY` | verde spento | campi a strisce, un fiume, argini, fienili sparsi |
| `STEPPE` | ocra chiaro | erba bassa, piste, tende smontabili, orizzonte alto |
| `MOUNTAIN` | grigio-rosso | pietra rossa, creste, neve solo su un versante |
| `UNDERGROUND` | verde-azzurro | imbocchi di galleria, sterili, impalcature, buio calibrato |
| `ROAD` | ambra | una strada che attraversa tutto, soste, ponti, carri |
| `FOREST` | verde profondo | chiome, radure, sentieri stretti |
| `COAST` | azzurro spento | secche, moli, barche in secca |

Chiavi in uso: `region.<nome>`.

---

## Overlay e iconografia

**Fatto in 0.1.20** (`scripts/core/icon_set.gd`, [D-058](DECISIONS.md#d-058)):
dodici glifi — le sei famiglie, i quattro livelli, i due marker — senza colore,
disegnati sia sullo schermo sia in stampa dallo stesso piano. La prova del
monocromatico a 16 px si genera con l'export (`prova_icone.svg`) invece di stare
qui dentro come immagine: un'immagine in un documento invecchia alla prima
coordinata ritoccata.

Il vincolo ha già respinto due disegni: la punta di lancia di FORCE, che a 16 px
era il marker di Tensione, e il compasso di KNOWLEDGE, che era la lettera A.

Gli overlay sono **grafica di sistema**, non illustrazione: vettoriali o
semi-piatti, leggibili sopra qualunque tile, con un contorno che li stacchi dallo
sfondo dipinto. Livelli indipendenti (§19.5): biome · structure · control/presence
· condition · scar · marker di Tensione/Echo.

I tag di Regione che il gioco può mostrare sono elencati nella sezione *Map
overlays* di [ASSET_MANIFEST.md](ASSET_MANIFEST.md); il prefisso è il livello
(`structure:`, `condition:`, `scar:`, `settlement:`, `domain:`).

Il set iconografico delle sei famiglie deve funzionare **in monocromatico a 16
px**: se un'icona ha bisogno del colore per distinguersi da un'altra, va
ridisegnata. Le famiglie sono già distinte per accento cromatico sulle carte;
l'icona deve reggere anche senza.

---

## Placeholder (0.0 → 0.1)

Fino all'arte definitiva ogni elemento usa un placeholder procedurale che mostra
in chiaro la propria `art_prompt_key`, così una carta sbagliata si riconosce a
colpo d'occhio durante il playtest.

**Fatto in 0.1.18** (`scripts/core/art_placeholder.gd`, [D-056](DECISIONS.md#d-056)):
il segnaposto è **diverso per ogni chiave** in modo deterministico — cinquanta
carte identiche sono cinquanta carte che sul tavolo non si distinguono — e
**rispetta la regola invalicabile 2**: soggetto nei due terzi alti, terzo basso
calmo e segnato con un tratteggio. Se un'illustrazione vera arriverà con la
composizione sbagliata si vedrà subito, perché il segnaposto la mostrava giusta.

Si guarda in due modi: `tools/run_export.sh` scrive i fogli in SVG, e **F4**
dentro l'app apre l'anteprima di stampa.

### Le tessere Regione non hanno un segnaposto: hanno un terreno

Fatto in 0.1.19 (`scripts/core/region_art.gd`, [D-057](DECISIONS.md#d-057)). Il
MASTER PROMPT 3 descrive un'illustrazione che qualcuno dovrà dipingere; sotto
c'è il livello che questa Art Bible ha sempre assegnato al codice — la sagoma
del terreno, il bioma leggibile da lontano, il centro calmo per i segnalini.

Ogni bioma della variation key ha il proprio vocabolario di tratti e la propria
terna di colori (terra, rilievo, accento). Il piano è in coordinate normalizzate
e lo disegnano **due motori**: la mappa dentro l'app e il foglio di stampa in
SVG. La tessera sul tavolo e quella sullo schermo sono la stessa immagine.

### Il quarto MASTER PROMPT che non c'è

L'export passa in rassegna ogni chiave in uso, ed è così che si è scoperto che
le **otto chiavi `entity.*` non hanno un MASTER PROMPT**: i tre qui sopra sono
carta Asset, carta Echo e tessera Regione, e nessuno di essi è un ritratto. O si
scrive il quarto, o le carte Casata rinunciano all'illustrazione. Finché la
decisione non è presa, `brief_arte.md` le elenca a parte e lo dice.
