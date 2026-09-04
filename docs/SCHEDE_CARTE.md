# ECHOES — la scheda di ogni tipo di carta

<!-- GENERATO da `tools/run_card_sheets.sh` — non si corregge qui. -->

Per ogni tipo di carta: **cos'e'**, **che immagine porta** e il suo prompt
generale, e **cosa c'e' scritto sopra**, campo per campo, con da dove viene nei
dati. Accanto a ogni scheda sta **il dato di tutte le carte di quel tipo** —
`schede/<tipo>.json` — con lo stesso record di ogni carta: titolo, sottotitolo,
cifra, righe meccaniche voce per voce, e il prompt dell'immagine gia' composto.
E' quello che serve per generare le carte, grafica e testo, senza aprire
Godot ([D-445](DECISIONS.md#d-445)).

Niente qui e' ricopiato: le carte vengono da `CardFace`, lo stesso che le
stampa sul foglio e le mostra sullo schermo; i prompt da `ArtBible`, lo
stesso che compone il brief. Le sole righe scritte a mano — cos'e' un tipo,
che immagine porta, da dove viene ogni voce — sono controllate contro le
facce vere: una voce stampata che la scheda tace, o promessa che nessuna
faccia stampa, e questo documento non si scrive.

Una carta puo' avere **due facce**: la Domanda porta il suo Consiglio sul
retro (D-449), e l'Asset porta il suo Eco sotto le Azioni (D-359). Il JSON
di un retro dice di che fronte e' (`fronte`), e viceversa (`retro`).

| tipo | formato | facce | pezzi | immagine | il dato |
|---|---|---|---|---|---|
| **carta Asset** | tarocco 70×120 mm | 48 | 132 | si' | `schede/asset.json` |
| **carta Domanda (la Tensione), fronte** | tarocco 70×120 mm | 60 | 60 | no | `schede/tension.json` |
| **carta Domanda, retro (il Consiglio)** | tarocco 70×120 mm | 60 | 60 | no | `schede/council.json` |
| **carta Destino** | tarocco 70×120 mm | 23 | 23 | si' | `schede/destiny.json` |
| **carta Obiettivo** | tarocco 70×120 mm | 19 | 19 | si' | `schede/objective.json` |
| **carta Casata** | tarocco 70×120 mm | 32 | 32 | si' | `schede/entity.json` |
| **tessera Regione** | tessera 80×80 mm | 10 | 10 | si' | `schede/region.json` |

## Il record di una carta, uguale per tutti i tipi

| campo del JSON | cos'e' |
|---|---|
| `titolo` | il titolo — il nome stampato in cima |
| `sottotitolo` | il sottotitolo — la riga sotto il titolo: chi e' e di che genere |
| `angolo` | la cifra d'angolo — l'unico numero che si legge con la carta a ventaglio; vuoto se il tipo non ne ha |
| `accento` | il colore del bordo — un esadecimale: la carta si riconosce dal bordo prima che dal titolo |
| `corpo` | il corpo — righe di testo libero, quando il tipo ne ha |
| `righe` | le righe meccaniche — ognuna con la sua **voce** in maiuscolo e il testo: sono la carta che si gioca |
| `arte` | l'illustrazione — la chiave, la scena scritta dall'autore e **il prompt composto**, pronto; `null` se la carta e' tutta testo |
| `pie` | il pie' — l'id, per ritrovarla nei dati |
| `copie` | quante copie — quante volte si stampa |
| `segreta` | coperta — `true` se sta dietro il paravento e non va lasciata sul tavolo |

## Lo stile — una volta, per tutto

Si incolla prima del prompt di ogni carta, ed e' lo stesso per tutto il
gioco ([ART_BIBLE](ART_BIBLE.md)). Nei JSON sta nel campo `stile`.

```
Painterly concept-art illustration style with bold, economical brushwork and simplified forms. Strong graphic composition, large readable silhouettes, and clear separation of light and shadow. Visible brush texture, opaque color blocking, and slightly rough hand-painted edges.

The image should feel like a high-end illustration or production painting, not photorealistic: selective detail, strong shape design, controlled abstraction, and emphasis on mood and composition over micro-detail.

Use a limited but sophisticated palette, with broad dominant color areas and a few warm/cool contrasts. Atmospheric depth should be created through color simplification and soft loss of detail in the background.

Figures, objects, and architecture should be rendered with confident painterly masses, not with sharp photographic precision. Surfaces are suggested rather than fully described. Lighting is dramatic but clean, with strong directional light and deep shadow masses.

Overall aesthetic: stylized, elegant, cinematic, painterly, graphic, atmospheric, and evocative. The result should resemble a polished hand-painted illustration, somewhere between editorial illustration and classic concept art.

Not photorealistic, not glossy 3D, not anime, not comic-book inked line art, not hyper-detailed, not overly textured, not cluttered.
```

## 1. carta Asset — tarocco 70×120 mm · 48 facce · 132 pezzi

**Cos'e'.** La carta che si cala dalla mano: **tu scegli dove e quale delle due Azioni**. Arriva con ACQUISIRE, o dalla mappa a inizio Atto; limite di mano 7. Costa 1 Occasione, o la impegni al Consiglio e vale forza. **Sotto le Azioni porta il suo Eco** (D-359): se le condizioni ci sono si cala quello al posto di un'Azione, e costa la carta.

**L'immagine.** Una **scena** — un luogo, un gesto, persone dentro una cosa che sta succedendo — mai un ritratto singolo centrato. L'accento e' il colore della famiglia.

Il prompt generale del tipo, coi segnaposto che ogni carta riempie —
`{SOGGETTO}` e' il titolo, `{SITUAZIONE}` la scena scritta dall'autore
(`rules_text`, la voce d'autore che la faccia non stampa piu' da D-340), `{ACCENTO}` e `{DESCRIZIONE}` la riga di variazione:

```
ECHOES — Asset card. Single evocative scene: {SOGGETTO}.
What is happening: {SITUAZIONE}
Dominant accent: {ACCENTO}, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

Nel JSON ogni carta porta gia' il prompt **composto**, in `arte.prompt`.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | famiglia e rarita' (`family`, `rarity`), in italiano |
| la cifra d'angolo | la forza (`strength`) |
| **DOVE** | il bersaglio a segni: `physical.target` |
| ① e ② | le due Azioni, nome e effetto: `physical.actions` |
| **SEMPRE** | la Risonanza, e la parte aggravata: `physical.resonance` |
| **AL CONSIGLIO** | quanto vale al voto e quando di piu': `physical.council_use`, `strength` |
| **IMPEGNI** | cosa lascia se la impegni: `on_commit_effects`, `discard_or_retain_rule` |
| **PRENDI** | come arriva in mano: `acquisition_rule` |
| **ECO** | l'Eco della carta, la sua versione potenziata: `echo_id`, con titolo, famiglia drammatica e funzione di Propp |
| **QUANDO ESCE** | le condizioni per calare l'Eco: `eligibility` dell'Eco, generate dai campi |
| **IL MONDO** | cosa fa l'Eco, in segni: `effect_hooks` (Effetti scritti e Conseguenze chiamate per id) |
| **CONVOCA IL CONSIGLIO** | la domanda che l'Eco apre, se ne apre una: `forces_confluence_on` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "AST_AUTHORITY_CENSUS",
  "tipo": "asset",
  "titolo": "Censimento",
  "sottotitolo": "autorità · comune",
  "angolo": "1",
  "accento": "#e8b563",
  "famiglia": "AUTHORITY",
  "corpo": [],
  "righe": [
    {
      "voce": "DOVE",
      "testo": "Scegli un luogo con #capitale, #granaio o #commercio. Vale anche il #porto, e ogni luogo del dominio del #territorio."
    },
    {
      "voce": "①",
      "testo": "Contare le teste — Scopri una questione velata che tocca quel luogo, e pesca 1 Sapere."
    },
    {
      "voce": "②",
      "testo": "Contare i sacchi — Togli #razionato dal luogo."
    },
    {
      "voce": "SEMPRE",
      "testo": "Potere +1 · se il bersaglio ha #pascolo: +1 ancora e posa #inquieta"
    },
    {
      "voce": "AL CONSIGLIO",
      "testo": "1 · +1 se si discute di Potere o Vie"
    },
    {
      "voce": "IMPEGNI",
      "testo": "+1 sul suo tema · si scarta se la impegni · costa: dove si discute non e' piu' #contesa"
    },
    {
      "voce": "PRENDI",
      "testo": "ACQUISIRE su Autorità. Fonti: Eredan, Terre Nahr, Il Bosco dei Confini."
    },
    {
      "voce": "ECO",
      "testo": "La Chiamata · PRESSIONE · funzione di Propp: richiesta"
    },
    {
      "voce": "QUANDO ESCE",
      "testo": "il mondo porta il debito e' stato chiamato"
    },
    {
      "voce": "IL MONDO",
      "testo": "la domanda in gioco sale · in una Regione con #commercio diventa #indebitata"
    },
    {
      "voce": "CONVOCA IL CONSIGLIO",
      "testo": "su Il Debito"
    }
  ],
  "arte": {
    "chiave": "asset.authority.census",
    "scena": "Una lista di nomi è la forma più semplice del potere, e la lista chiarisce chi sta dove.",
    "prompt": "ECHOES — Asset card. Single evocative scene: Censimento.\nWhat is happening: Una lista di nomi è la forma più semplice del potere, e la lista chiarisce chi sta dove.\nDominant accent: oro spento, over the game's muted earth palette. Low side\nlighting, late afternoon or candlelit interior.\nGrounded medieval-adjacent world, no heraldry invented, no glowing magic.\nA scene, not a portrait: figures may show their faces, but never a single centred\nfigure looking at the viewer - that framing belongs to the House cards.\nComposition: subject occupies the upper two thirds; the lower third is a calm,\nlow-detail area (ground, mist, cloth, stone) reserved for a text overlay.\nVertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,\nno border. Not gory, not horror."
  },
  "pie": "AST_AUTHORITY_CENSUS",
  "copie": 4,
  "segreta": false
}
```

## 2. carta Domanda (la Tensione), fronte — tarocco 70×120 mm · 60 facce · 60 pezzi

**Cos'e'.** La domanda in gioco: sta accanto alla traccia dei valori tutto l'anno, si gira sul Tema caldo e **dice quando si scalda e su cosa si discute**. Non si gioca e non si tiene in mano. **Sul retro c'e' il suo Consiglio** (D-449): la stessa carta, girata. **La carta non e' mai coperta: coperti sono i gettoni** che ci si posano sopra (D-450) — a fine Atto si girano, si sommano, e la Domanda col mucchio piu' alto si dibatte.

**L'immagine.** Nessuna: e' tutta testo, e il testo prende il posto del quadro.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | «domanda» e il Tema (`domain`) |
| la cifra d'angolo | nessuna: la soglia col cancello del tavolo non decide niente (D-203), e si e' tolta dalla carta (D-450) |
| **SI DISCUTE DI** | le domande che puo' aprire, nel corpo: `possible_questions`, col testo da `council.questions` |
| **SI ACCENDE QUANDO** | la regola a segni che la fa salire: `heats_when` (o `triggers`, dove la regola non c'e') |
| **SI RAFFREDDA** | `decrease_rules` |
| **SI DIBATTE** | il gesto di fine Atto, fisso: i gettoni coperti si girano e il mucchio piu' alto gira la carta (D-203, D-450) |
| **AL CONSIGLIO VALGONO** | le famiglie che pesano al voto: `relevant_asset_families` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "TEN_ASH",
  "tipo": "tension",
  "titolo": "La Cenere che Sale",
  "sottotitolo": "domanda · l'antico",
  "angolo": "",
  "accento": "#8a8172",
  "famiglia": "",
  "corpo": [
    "SI DISCUTE DI  La montagna fuma di nuovo nella Regione di cui si discute: si mette qualcuno a guardarla, o si scrive che ha sempre fumato? · E le bocche aperte sul fianco, si murano?"
  ],
  "righe": [
    {
      "voce": "SI ACCENDE QUANDO",
      "testo": "una casa entra dove sta il #cristallo o nel #selvaggio, o se ne va"
    },
    {
      "voce": "SI RAFFREDDA",
      "testo": "Una Confluence risolta su chi tiene d'occhio la montagna."
    },
    {
      "voce": "SI DIBATTE",
      "testo": "quando a fine Atto i suoi gettoni, girati, fanno il mucchio piu' alto: gira la carta."
    },
    {
      "voce": "AL CONSIGLIO VALGONO",
      "testo": "forza, sapere, gente"
    }
  ],
  "arte": null,
  "pie": "TEN_ASH",
  "copie": 1,
  "segreta": false
}
```

## 3. carta Domanda, retro (il Consiglio) — tarocco 70×120 mm · 60 facce · 60 pezzi

**Cos'e'.** **Il retro della carta Domanda**: si gira quando il Consiglio si apre, e porta le sue domande e le caselle con cui il tavolo la risolve — in media nove SI OTTIENE, nove SI PAGA e due SE CADE (D-280, D-449). Una per Tensione, nello stesso ordine del fronte.

**L'immagine.** Nessuna: e' un elenco da cui si sceglie.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | fissa: «il Consiglio che questa domanda apre» |
| le domande | nel corpo, una per riga, con «— solo se» quando serve una condizione: `council.questions` |
| **SI OTTIENE** | le caselle beneficio, una per riga con «·»: `physical.benefits` |
| **SI PAGA** | le caselle costo: `physical.costs` |
| **SE CADE** | cosa succede se la proposta cade: `physical.failure` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "TEN_ASH",
  "tipo": "council",
  "titolo": "La Cenere che Sale",
  "sottotitolo": "il Consiglio che questa domanda apre — retro della carta",
  "angolo": "",
  "accento": "#8a8172",
  "famiglia": "",
  "corpo": [
    "La montagna fuma di nuovo nella Regione di cui si discute: si mette qualcuno a guardarla, o si scrive che ha sempre fumato?",
    "E le bocche aperte sul fianco, si murano?"
  ],
  "righe": [
    {
      "voce": "SI OTTIENE",
      "testo": ""
    },
    {
      "voce": "·",
      "testo": "Costruisci 1 Pietra nel luogo: Sito dormiente."
    },
    {
      "voce": "·",
      "testo": "Assegna o trasferisci il controllo del luogo."
    },
    {
      "voce": "·",
      "testo": "Raffredda il Tema di 1 (minimo 0)."
    },
    {
      "voce": "·",
      "testo": "Il mondo ricorda: della montagna si e' smesso di parlare."
    },
    {
      "voce": "SI PAGA",
      "testo": ""
    },
    {
      "voce": "·",
      "testo": "Il luogo viene murato: quello che sta sotto resta sotto."
    },
    {
      "voce": "·",
      "testo": "Cedi il controllo del luogo."
    },
    {
      "voce": "·",
      "testo": "Al luogo si aggiunge #indebitata."
    },
    {
      "voce": "·",
      "testo": "Accetta 1 Cicatrice permanente: la domanda sul muro."
    },
    {
      "voce": "SE CADE",
      "testo": ""
    },
    {
      "voce": "·",
      "testo": "Al luogo si aggiunge #malcontento."
    },
    {
      "voce": "·",
      "testo": "Il Tema di questa domanda si scalda di 1."
    }
  ],
  "arte": null,
  "pie": "TEN_ASH",
  "copie": 1,
  "segreta": false
}
```

## 4. carta Destino — tarocco 70×120 mm · 23 facce · 23 pezzi

**Cos'e'.** L'ambizione di una casa, **dietro il paravento**: la scala per contare quanto manca. Non si gioca, si guarda.

**L'immagine.** **Niente volti**: la cosa desiderata, non chi la desidera — un oggetto, un luogo, una soglia, composti come un'immagine votiva. L'accento e' quello dell'archetipo della casa.

Il prompt generale del tipo, coi segnaposto che ogni carta riempie —
`{SOGGETTO}` e' il titolo, `{SITUAZIONE}` la scena scritta dall'autore
(`description`), `{ACCENTO}` e `{DESCRIZIONE}` la riga di variazione:

```
ECHOES — Destiny card. Emblematic scene of {SOGGETTO}.
What is wanted: {SITUAZIONE}
Dominant accent: {ACCENTO}, over the game's muted earth palette. No faces: a
Destiny card shows the thing wanted, not the one who wants it — an object, a
place, a threshold, composed like a votive image. {DESCRIZIONE}. Seen close and
slightly from below, the way an ambition is seen; one strong light source, deep
quiet shadow around it. Grounded medieval-adjacent world, no invented heraldry,
no glowing magic. Composition: subject in the upper two thirds; the lower third
is a calm, low-detail area reserved for a text overlay. Vertical card framing,
2:3. No text, no letters, no numerals, no logos, no frame, no border. Not gory,
not horror.
```

Nel JSON ogni carta porta gia' il prompt **composto**, in `arte.prompt`.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | la casa (`entity_id`), o «per chi lo giura» se e' condivisibile |
| **SOGLIA** | il primo gradino: `minimum.label` e le sue clausole (`conditions[].label`) |
| **VITTORIA** | `victory` |
| **TRIONFO** | `triumph` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "DST_ALDRIC",
  "tipo": "destiny",
  "titolo": "Il Regno che Resta",
  "sottotitolo": "Re Aldric",
  "angolo": "",
  "accento": "#8a8172",
  "famiglia": "",
  "corpo": [],
  "righe": [
    {
      "voce": "SOGLIA",
      "testo": "Il trono regge: Una pedina dove c'e' il #capitale, o su una terra di #territorio"
    },
    {
      "voce": "VITTORIA",
      "testo": "Il regno decide: La corona tiene ancora la sua terra · La Carestia non supera 4"
    },
    {
      "voce": "TRIONFO",
      "testo": "Un regno che non ha pagato il pane con il sangue: La terra col #capitale non e' in rivolta · E tre segni che la corona ha retto senza stringere"
    }
  ],
  "arte": {
    "chiave": "destiny.aldric",
    "scena": "Tenere Eredan indipendente e raggiungere un controllo politico sufficiente, senza lasciare il regno in collasso.",
    "prompt": "ECHOES — Destiny card. Emblematic scene of Il Regno che Resta.\nWhat is wanted: Tenere Eredan indipendente e raggiungere un controllo politico sufficiente, senza lasciare il regno in collasso.\nDominant accent: oro spento, over the game's muted earth palette. No faces: a\nDestiny card shows the thing wanted, not the one who wants it — an object, a\nplace, a threshold, composed like a votive image. ciò che si tiene: il sigillo, la sala vuota, la corona posata — mai indossata. Seen close and\nslightly from below, the way an ambition is seen; one strong light source, deep\nquiet shadow around it. Grounded medieval-adjacent world, no invented heraldry,\nno glowing magic. Composition: subject in the upper two thirds; the lower third\nis a calm, low-detail area reserved for a text overlay. Vertical card framing,\n2:3. No text, no letters, no numerals, no logos, no frame, no border. Not gory,\nnot horror."
  },
  "pie": "DST_ALDRIC",
  "copie": 1,
  "segreta": true
}
```

## 5. carta Obiettivo — tarocco 70×120 mm · 19 facce · 19 pezzi

**Cos'e'.** La promessa coperta che **qualunque casa puo' pescare**, dietro il paravento come il Destino. Non si gioca: si conta a fine anno, clausola per clausola.

**L'immagine.** **Niente volti** e **nessun colore di casa**: la prova da portare — una cosa costruita, tenuta, contata — come un ex voto.

Il prompt generale del tipo, coi segnaposto che ogni carta riempie —
`{SOGGETTO}` e' il titolo, `{SITUAZIONE}` la scena scritta dall'autore
(`description`), `{ACCENTO}` e `{DESCRIZIONE}` la riga di variazione:

```
ECHOES — Objective card. Emblematic scene of {SOGGETTO}.
What must be true at the end of the year: {SITUAZIONE}
Neutral accent — worn stone grey and pale ochre — over the game's muted earth
palette; no house colour: this card can belong to anyone. No faces: an
Objective card shows the proof, not the one who brings it — a thing built,
held, counted or kept, composed like an ex-voto. Seen close, at eye level, in
plain daylight; one clear light source and a quiet background. Grounded
medieval-adjacent world, no invented heraldry, no glowing magic. Composition:
subject in the upper two thirds; the lower third is a calm, low-detail area
reserved for a text overlay. Vertical card framing, 2:3. No text, no letters,
no numerals, no logos, no frame, no border. Not gory, not horror.
```

Nel JSON ogni carta porta gia' il prompt **composto**, in `arte.prompt`.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | fissa: «obiettivo coperto · si conta a fine anno» |
| la promessa | nel corpo, in una riga: `label` |
| **CONTA** | le clausole che la contano: `conditions[].label` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "OBJ_A_GARRISON",
  "tipo": "objective",
  "titolo": "Il Muro che Tiene",
  "sottotitolo": "obiettivo coperto · si conta a fine anno",
  "angolo": "",
  "accento": "#8a8172",
  "famiglia": "",
  "corpo": [
    "Un presidio suo tiene una terra del territorio"
  ],
  "righe": [
    {
      "voce": "CONTA",
      "testo": "Almeno un presidio suo nel dominio del territorio · Controllo di almeno 2 Regioni"
    }
  ],
  "arte": {
    "chiave": "objective.a_garrison",
    "scena": "C'e' chi costruisce per essere ricordato e chi costruisce per non essere cacciato. Questo obiettivo e' del secondo tipo, e non conta il muro da solo: un presidio che non ha due terre dietro non protegge niente, protegge se stesso — e va alzato dove la terra si contende, non dove nessuno passa.",
    "prompt": "ECHOES — Objective card. Emblematic scene of Il Muro che Tiene.\nWhat must be true at the end of the year: C'e' chi costruisce per essere ricordato e chi costruisce per non essere cacciato. Questo obiettivo e' del secondo tipo, e non conta il muro da solo: un presidio che non ha due terre dietro non protegge niente, protegge se stesso — e va alzato dove la terra si contende, non dove nessuno passa.\nNeutral accent — worn stone grey and pale ochre — over the game's muted earth\npalette; no house colour: this card can belong to anyone. No faces: an\nObjective card shows the proof, not the one who brings it — a thing built,\nheld, counted or kept, composed like an ex-voto. Seen close, at eye level, in\nplain daylight; one clear light source and a quiet background. Grounded\nmedieval-adjacent world, no invented heraldry, no glowing magic. Composition:\nsubject in the upper two thirds; the lower third is a calm, low-detail area\nreserved for a text overlay. Vertical card framing, 2:3. No text, no letters,\nno numerals, no logos, no frame, no border. Not gory, not horror."
  },
  "pie": "OBJ_A_GARRISON",
  "copie": 1,
  "segreta": true
}
```

## 6. carta Casata — tarocco 70×120 mm · 32 facce · 32 pezzi

**Cos'e'.** La casa, in vista tutta la partita: **cosa sa fare e cosa vuole lasciare**. Una carta per vita (D-111): la stessa casa cambia nome e volto quando si trasforma.

**L'immagine.** Un **ritratto**: una figura sola, ravvicinata, che guarda chi la guarda. Il taglio lo decide l'archetipo.

Il prompt generale del tipo, coi segnaposto che ogni carta riempie —
`{SOGGETTO}` e' il titolo, `{SITUAZIONE}` la scena scritta dall'autore
(`description` della vita che siede), `{ACCENTO}` e `{DESCRIZIONE}` la riga di variazione:

```
ECHOES — House card. Portrait of {SOGGETTO}.
Who this is: {SITUAZIONE}
Dominant accent: {ACCENTO}, over the game's muted earth palette. One subject,
close, facing the viewer: this framing is what separates a House card from an
Asset card, where a single centred figure looking out is forbidden.
{DESCRIZIONE}. Low side lighting, shallow depth of field; the background says
where they come from without telling a story of its own. Grounded
medieval-adjacent world, no invented heraldry, no glowing magic. Composition:
head and shoulders in the upper two thirds; the lower third is a calm,
low-detail area reserved for a text overlay. Vertical card framing, 2:3. No
text, no letters, no numerals, no logos, no frame, no border. Not gory, not
horror.
```

Nel JSON ogni carta porta gia' il prompt **composto**, in `arte.prompt`.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | l'archetipo e il bisogno (`archetype`, `need`), in italiano |
| **SA FARE** | i valori dei verbi: `action_values` |
| **VUOI LASCIARE** | i segni del profilo strategico: `entity_profiles[].wants` |
| **SE NON CE LA FAI** | la vita dopo e la sua porta: `incarnations[].also_enters` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "ENT_ALDRIC",
  "tipo": "entity",
  "titolo": "Re Aldric",
  "sottotitolo": "sovrano · vuole il potere",
  "angolo": "",
  "accento": "#8a8172",
  "famiglia": "",
  "corpo": [],
  "righe": [
    {
      "voce": "SA FARE",
      "testo": "acquisire 3 · rivendicare 4 · forgiare 2 · influenzare 4 · muovere 2 · tramare 1"
    },
    {
      "voce": "VUOI LASCIARE",
      "testo": "la successione e' passata per legge · la corona · il granaio · l'ordine e' stato ristabilito"
    },
    {
      "voce": "SE NON CE LA FAI",
      "testo": "dopo 150 anni con meno di 1 di questi segni: La Repubblica della Valle"
    }
  ],
  "arte": {
    "chiave": "entity.aldric",
    "scena": "Terzo della sua casa, primo a regnare su un raccolto che non basta. Sa che il trono è una promessa di pane con un altro nome.",
    "prompt": "ECHOES — House card. Portrait of Re Aldric.\nWho this is: Terzo della sua casa, primo a regnare su un raccolto che non basta. Sa che il trono è una promessa di pane con un altro nome.\nDominant accent: oro spento, over the game's muted earth palette. One subject,\nclose, facing the viewer: this framing is what separates a House card from an\nAsset card, where a single centred figure looking out is forbidden.\nuna persona sola, le insegne portate come un peso e mai in posa di trionfo. Low side lighting, shallow depth of field; the background says\nwhere they come from without telling a story of its own. Grounded\nmedieval-adjacent world, no invented heraldry, no glowing magic. Composition:\nhead and shoulders in the upper two thirds; the lower third is a calm,\nlow-detail area reserved for a text overlay. Vertical card framing, 2:3. No\ntext, no letters, no numerals, no logos, no frame, no border. Not gory, not\nhorror."
  },
  "pie": "ENT_ALDRIC",
  "copie": 1,
  "segreta": false
}
```

## 7. tessera Regione — tessera 80×80 mm · 10 facce · 10 pezzi

**Cos'e'.** La tessera di mappa: **porta i segni** che ogni carta Azione bersaglia, e i varchi con cui si posa accanto alle altre.

**L'immagine.** Il **terreno**, che prende tutta la tessera: il quadro e' il bioma, e il testo ci sta sopra in basso. I varchi si vedono sui lati.

Il prompt generale del tipo, coi segnaposto che ogni carta riempie —
`{SOGGETTO}` e' il titolo, `{SITUAZIONE}` la scena scritta dall'autore
(`description`), `{ACCENTO}` e `{DESCRIZIONE}` la riga di variazione:

```
ECHOES — Region tile. Top-down three-quarter painted map tile of {REGIONE}:
{DESCRIZIONE}.
What this land is right now: {SITUAZIONE}
Dominant accent: {ACCENTO}, over the game's muted earth palette. Cartography
crossed with painted landscape. Readable terrain silhouette from above, clear
edges that can tile against neighbouring regions. {VARCHI} Composition: the centre is
deliberately calm and uncluttered so overlay tokens (control, presence,
condition, scar) sit legibly on top; detail concentrates at the borders. Square
framing. No text, no letters, no numerals, no map labels, no compass rose, no
frame.
```

Nel JSON ogni carta porta gia' il prompt **composto**, in `arte.prompt`.

**Cosa c'e' scritto sopra**, in ordine di lettura:

| posto | da dove viene |
|---|---|
| il titolo | `title` o `name` |
| il sottotitolo | il bioma e i posti (`biome`, `presence_slots`, `build_slots`) |
| **VARCHI** | i lati aperti: `edges` |
| **SEGNI** | il dominio e i #segni stampati: `tags` |
| **CI STANNO** | le Pietre che il bioma accetta: `structure_types[].biomes` |
| **FONTI** | le famiglie che la tessera da': `asset_sources` |

**Una carta, per intero, com'e' nel JSON:**

```json
{
  "id": "REG_BOSCO_CONFINI",
  "tipo": "region",
  "titolo": "Il Bosco dei Confini",
  "sottotitolo": "foresta · 3 pedine · 2 Pietre",
  "angolo": "",
  "accento": "#8a8172",
  "famiglia": "",
  "corpo": [],
  "righe": [
    {
      "voce": "VARCHI",
      "testo": "alto · destra · basso · sinistra"
    },
    {
      "voce": "SEGNI",
      "testo": "dominio: l'antico · #bosco"
    },
    {
      "voce": "CI STANNO",
      "testo": "archivio · canale · granaio · presidio · insediamento · pedaggio"
    },
    {
      "voce": "FONTI",
      "testo": "autorità, forza"
    }
  ],
  "arte": {
    "chiave": "region.bosco_confini",
    "scena": "Alberi alti e sentieri che non restano dove li lasci. Il confine passa di qui, ma nessuno l'ha mai visto scritto.",
    "prompt": "ECHOES — Region tile. Top-down three-quarter painted map tile of Il Bosco dei Confini:\nchiome, radure, sentieri stretti.\nWhat this land is right now: Alberi alti e sentieri che non restano dove li lasci. Il confine passa di qui, ma nessuno l'ha mai visto scritto.\nDominant accent: verde profondo, over the game's muted earth palette. Cartography\ncrossed with painted landscape. Readable terrain silhouette from above, clear\nedges that can tile against neighbouring regions. A visible way in and out reaches all four edges. Composition: the centre is\ndeliberately calm and uncluttered so overlay tokens (control, presence,\ncondition, scar) sit legibly on top; detail concentrates at the borders. Square\nframing. No text, no letters, no numerals, no map labels, no compass rose, no\nframe."
  },
  "pie": "REG_BOSCO_CONFINI",
  "copie": 1,
  "segreta": false
}
```
