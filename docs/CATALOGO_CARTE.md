# ECHOES — il catalogo delle carte

<!-- FILE GENERATO — si rifa' con `tools/run_card_catalogue.sh`. -->

Una scheda per carta: **cosa dice**, **cosa fa**, **quanto vale** e il
**prompt** da dare a un generatore di immagini.

Niente qui e' scritto a mano. I numeri vengono dai dati, le frasi dallo
stesso posto che le scrive sullo schermo e sul cartone, il prompt dallo
stesso che compone il brief d'arte. Se una carta cambia, questa pagina
cambia con lei — e la CI va rossa se qualcuno se ne dimentica.

---

## Le carte Asset (la mano)

La **forza** e' quanto pesa al Consiglio su una domanda che ascolta la
sua famiglia; su tutte le altre vale **1**. Le copie nel mazzo le decide
la rarita'.

### Famiglia authority

#### Interdetto

| | |
|---|---|
| famiglia | authority |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | la domanda in gioco sale |
| id | `AST_AUTHORITY_INTERDICT` |

> Vietare una cosa a tutti alza la posta per tutti.

**Temi:** Potere · Fede

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Proibire.** Abbassa quella questione di 2. Nessuno puo' influenzarla fino a fine Atto.
B. **Scomunicare.** Alzala di 1 e metti #tradimento_detto sul mondo.

**RISONANZA (avviene sempre)** — Scalda Fede +2. Un interdetto non toglie niente a nessuno: dice solo che d'ora in poi c'e' un dentro e un fuori. Se la fede ha avuto un posto: Fede +3.

> Se il bersaglio porta gia' `faith_established`: Fede scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Interdetto.
What is happening: Vietare una cosa a tutti alza la posta per tutti.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Atto di Successione

| | |
|---|---|
| famiglia | authority |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| cosa lascia | il rivale entra dove si discute |
| id | `AST_AUTHORITY_SUCCESSION_ACT` |

> Nominare un erede fa arrivare tutti quelli che non sono stati nominati.

**Temi:** Potere

**BERSAGLIO** — Scegli un luogo con #capitale. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Scrivere il nome.** Rivendica il luogo e metti #erede_nominato sul mondo.
B. **Scrivere la regola.** Metti #successione_per_legge sul mondo.

**RISONANZA (avviene sempre)** — Scalda Potere +2. Un atto di successione e' la promessa che qualcuno si alzera' — e l'annuncio a tutti gli altri che non saranno loro. Se la corona e' stata divisa: Potere +3.

> Se il bersaglio porta gia' `crown_divided`: Potere scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Atto di Successione.
What is happening: Nominare un erede fa arrivare tutti quelli che non sono stati nominati.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Diritto di Corona

| | |
|---|---|
| famiglia | authority |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| cosa lascia | dove si discute diventa #contesa |
| id | `AST_AUTHORITY_CROWN_RIGHT` |

> Un diritto invocato due volte non è più un diritto: è una pretesa, e la pretesa divide.

**Temi:** Potere

**BERSAGLIO** — Scegli un luogo con #capitale o #conteso. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Rivendicare per diritto.** Rivendica il luogo.
B. **Cedere il diritto.** Un'altra casa prende la rivendicazione al posto tuo e sale di 2 gradini nel rapporto con te.

**RISONANZA (avviene sempre)** — Scalda Potere +2. Ogni volta che il diritto viene detto ad alta voce, qualcuno conta chi non l'ha detto. Se la corona e' stata divisa: Potere +3.

> Se il bersaglio porta gia' `crown_divided`: Potere scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Diritto di Corona.
What is happening: Un diritto invocato due volte non è più un diritto: è una pretesa, e la pretesa divide.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Magistrato

| | |
|---|---|
| famiglia | authority |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | torna in mano se la proposta passa |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| al Consiglio | +2 se ti opponi |
| cosa lascia | dove si discute non e' piu' la domanda sul muro |
| id | `AST_AUTHORITY_MAGISTRATE` |

> Un giudice che ha avuto ragione serve ancora, e risponde a chi ha lasciato la domanda scritta sul muro.

**Temi:** Potere · Vie

**BERSAGLIO** — Scegli un luogo con #capitale, #commercio, #conteso o #malcontento. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Mandarlo a giudicare.** Sposta una tua presenza li' e togli #conteso dal luogo.
B. **Mandarlo a controllare.** Togli #malcontento dal luogo e pesca 1 Sapere.

**RISONANZA (avviene sempre)** — Scalda Potere +1. Un magistrato e' la corona che arriva dove la corona non va di persona. Se la Carta e' stata scritta: Potere +2.

> Se il bersaglio porta gia' `charter_written`: Potere scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Potere o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Magistrato.
What is happening: Un giudice che ha avuto ragione serve ancora, e risponde a chi ha lasciato la domanda scritta sul muro.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Censimento

| | |
|---|---|
| famiglia | authority |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| al Consiglio | +1 sul suo tema |
| cosa lascia | dove si discute non e' piu' #contesa |
| id | `AST_AUTHORITY_CENSUS` |

> Una lista di nomi è la forma più semplice del potere, e la lista chiarisce chi sta dove.

**Temi:** Potere · Vie

**BERSAGLIO** — Scegli un luogo con #capitale, #granaio o #commercio. Vale anche il #porto, e ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Contare le teste.** Scopri una questione velata che tocca quel luogo, e pesca 1 Sapere.
B. **Contare i sacchi.** Togli #razionato o #requisito dal luogo.

**RISONANZA (avviene sempre)** — Scalda Potere +1. Contare e' un atto di governo, e chi viene contato lo sa. Se il luogo porta #pascolo: Potere +2, e ci resta #malcontento.

> Se il bersaglio porta gia' `nomad_range`: Potere scalda di 2 invece che di 1, e lascia `condition:unrest`.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Potere o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Censimento.
What is happening: Una lista di nomi è la forma più semplice del potere, e la lista chiarisce chi sta dove.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Editto

| | |
|---|---|
| famiglia | authority |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| cosa lascia | dove si discute non e' piu' #inquieta |
| id | `AST_AUTHORITY_EDICT` |

> Una riga scritta bene vale quanto chi la fa rispettare, e dove si discute la legge calma la piazza.

**Temi:** Potere

**BERSAGLIO** — Scegli un luogo qualsiasi che non sia gia' #conteso.

**AZIONE — scegli 1**

A. **Rivendicare.** Rivendica il luogo: al prossimo Consiglio apre la sua Domanda, e parli per primo.
B. **Proibire.** Nessuno puo' giocare carte Forza su quel luogo fino a fine Atto.

**RISONANZA (avviene sempre)** — Scalda Potere +1. Un editto e' una promessa che qualcuno dovra' mantenere o rompere. Se una domanda e' rimasta aperta: Potere +2.

> Se il bersaglio porta gia' `question_unresolved`: Potere scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Potere o Terra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Editto.
What is happening: Una riga scritta bene vale quanto chi la fa rispettare, e dove si discute la legge calma la piazza.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Investitura

| | |
|---|---|
| famiglia | authority |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +1 sempre |
| cosa lascia | il mondo registra: l'erede nominato |
| id | `AST_AUTHORITY_INVESTITURE` |

> Si concede una volta sola, e tutti se ne ricordano: la nomina scrive un nome nella linea.

**Temi:** Potere · Fede

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Investirla.** Sale di 2 gradini nel rapporto con te e prende #fama.
B. **Farsi investire.** Sali di 1 gradino verso di lei e prendi #fama.

**RISONANZA (avviene sempre)** — Scalda Fede +1. Un titolo dato e' una gerarchia detta ad alta voce, e qualcuno la sentira' come un insulto. Se porti #fama: Fede +2.

> Se il bersaglio porta gia' `renowned`: Fede scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Potere o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Investitura.
What is happening: Si concede una volta sola, e tutti se ne ricordano: la nomina scrive un nome nella linea.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Sigillo

| | |
|---|---|
| famiglia | authority |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| al Consiglio | +1 se ti opponi |
| cosa lascia | la domanda in gioco scende |
| id | `AST_AUTHORITY_SEAL` |

> Il sigillo che manca ferma più cose del sigillo che c'è.

**Temi:** Potere

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Sigillare in basso.** Abbassa quella questione di 1.
B. **Sigillare in alto.** Alza quella questione di 1.

**RISONANZA (avviene sempre)** — Scalda Potere +1. Un sigillo non convince nessuno: dice solo chi ha il diritto di chiudere il discorso. Se la Carta non e' stata scritta: Potere +2.

> Se il bersaglio porta gia' `no_charter`: Potere scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Sigillo.
What is happening: Il sigillo che manca ferma più cose del sigillo che c'è.
Dominant accent: oro spento, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

### Famiglia bonds

#### Patto Rotto

| | |
|---|---|
| famiglia | bonds |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | la domanda in gioco sale |
| id | `AST_BONDS_BROKEN_PACT` |

> Rompere un patto davanti al tavolo scalda ogni domanda ancora aperta.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Rompere adesso.** Alza quella questione di 2, metti #giuramento_rotto sul mondo e scendi di 2 gradini con chi aveva il patto.
B. **Minacciare di rompere.** Alza quella questione di 1. Chi aveva il patto ti da' 1 carta a scelta perche' tu non lo faccia.

**RISONANZA (avviene sempre)** — Scalda Fede +2. Un patto rotto non si dimentica: cambia quello che gli altri sono disposti a promettere a chiunque. Se il giuramento e' stato rotto: Fede +3.

> Se il bersaglio porta gia' `oath_broken`: Fede scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Patto Rotto.
What is happening: Rompere un patto davanti al tavolo scalda ogni domanda ancora aperta.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Ostaggio

| | |
|---|---|
| famiglia | bonds |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | il rivale entra dove si discute |
| id | `AST_BONDS_HOSTAGE` |

> Chi consegna un figlio compra una parola, e la paga a casa propria.

**Temi:** Potere · Fede

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Mostrare l'ostaggio.** Abbassa quella questione di 2.
B. **Restituire l'ostaggio.** Alza quella questione di 1: la casa che lo rivoleva sale di 2 gradini nel rapporto con te.

**RISONANZA (avviene sempre)** — Scalda Fede +2. Un ostaggio tiene fermo il tavolo e intanto insegna a tutti come si tiene fermo un tavolo. Se il tradimento e' stato detto ad alta voce: Fede +3.

> Se il bersaglio porta gia' `betrayal_spoken`: Fede scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Ostaggio.
What is happening: Chi consegna un figlio compra una parola, e la paga a casa propria.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Promessa di Nozze

| | |
|---|---|
| famiglia | bonds |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +2 se ti opponi |
| cosa lascia | il rapporto fra chi gioca e il rivale cambia |
| id | `AST_BONDS_BETROTHAL` |

> Una promessa serve più a impedire un'alleanza che a farne una, e resta scritta.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli un'altra casa che non porti #giuramento_rotto.

**AZIONE — scegli 1**

A. **Promettere.** Salite tutti e due di 2 gradini. Da adesso ogni Consiglio in cui vi opponete costa 1 carta a testa.
B. **Rimandare.** Salite di 1 gradino e pesca 1 Legami.

**RISONANZA (avviene sempre)** — Scalda Fede +2. Una promessa di nozze e' un patto che coinvolge chi non era nella stanza. Se porti #fama: Fede +3.

> Se il bersaglio porta gia' `renowned`: Fede scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Promessa di Nozze.
What is happening: Una promessa serve più a impedire un'alleanza che a farne una, e resta scritta.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Legame di Sangue

| | |
|---|---|
| famiglia | bonds |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | discard |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| cosa lascia | il rapporto fra chi gioca e il rivale cambia |
| id | `AST_BONDS_BLOOD_TIE` |

> Non è un accordo: è una cosa che c'era prima dell'accordo, e che nessuno ha firmato.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli un luogo con #capitale, #pascolo o un insediamento cresciuto. Vale anche ogni luogo del dominio della #sopravvivenza.

**AZIONE — scegli 1**

A. **Cercare il legame.** Scopri una questione velata che tocca il luogo, e pesca 1 Legami.
B. **Rivendicare il sangue.** Metti #erede_nominato sul mondo.

**RISONANZA (avviene sempre)** — Scalda Antico +1. Il sangue non e' un argomento: e' un modo di non doverne portare nessuno. Se l'erede e' stato nominato: Antico +2.

> Se il bersaglio porta gia' `heir_named`: Antico scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Legame di Sangue.
What is happening: Non è un accordo: è una cosa che c'era prima dell'accordo, e che nessuno ha firmato.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Favore

| | |
|---|---|
| famiglia | bonds |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | il rapporto fra chi gioca e il rivale cambia |
| id | `AST_BONDS_FAVOR` |

> Piccolo, ricordato con precisione, e restituito al momento giusto.

**Temi:** Fede · Vie

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Chiedere il favore.** Abbassa quella questione di 1 e scendi di 1 gradino con la casa che la stava spingendo.
B. **Fare il favore.** Alza quella questione di 1 per conto di un'altra casa: lei sale di 2 gradini nel rapporto con te.

**RISONANZA (avviene sempre)** — Scalda Fede +1. Un favore non si restituisce mai per intero: e' questo che lo tiene in vita. Se ci si e' parlato: Fede +2.

> Se il bersaglio porta gia' `parley_held`: Fede scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Fede o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Favore.
What is happening: Piccolo, ricordato con precisione, e restituito al momento giusto.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Diritto di Ospitalità

| | |
|---|---|
| famiglia | bonds |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| al Consiglio | +1 sul suo tema |
| cosa lascia | chi gioca perde: cacciata da dove si discuteva |
| id | `AST_BONDS_GUEST_RIGHT` |

> Chi ha mangiato al tuo tavolo non può dire di no davanti a tutti. Può dirlo dopo.

**Temi:** Fede · Terra

**BERSAGLIO** — Scegli un luogo che non sia #conteso.

**AZIONE — scegli 1**

A. **Entrare come ospite.** Sposta una tua presenza li', anche se il luogo e' di un altro.
B. **Offrire ospitalita'.** Un'altra casa mette una presenza in un tuo luogo e sale di 2 gradini nel rapporto con te.

**RISONANZA (avviene sempre)** — Scalda Fede +1. Il diritto d'ospitalita' regge finche' nessuno lo mette alla prova, e qualcuno lo mettera'. Se porti la scorta giurata: Fede +2.

> Se il bersaglio porta gia' `escort_sworn`: Fede scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Fede o Terra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Diritto di Ospitalità.
What is happening: Chi ha mangiato al tuo tavolo non può dire di no davanti a tutti. Può dirlo dopo.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Giuramento

| | |
|---|---|
| famiglia | bonds |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | retain |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| cosa lascia | il rapporto fra chi gioca e il rivale cambia |
| id | `AST_BONDS_OATH` |

> Un giuramento impegnato resta impegnato anche dopo, ed è la sua unica forza.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli un'altra casa al tavolo che non porti #giuramento_rotto.

**AZIONE — scegli 1**

A. **Giurare insieme.** Sali di 1 gradino nel rapporto con lei e metti #scorta_giurata su tutti e due. Vale finche' uno dei due non lo rompe.
B. **Farsi giurare.** Lei sale di 1 gradino verso di te, tu no. Prendi 1 sua carta a scelta.

**RISONANZA (avviene sempre)** — Scalda Fede +1. Un giuramento pronunciato e' una cosa che il mondo dovra' ricordare o dimenticare, e nessuna delle due e' gratis. Se porti #fama: Fede +2.

> Se il bersaglio porta gia' `renowned`: Fede scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Giuramento.
What is happening: Un giuramento impegnato resta impegnato anche dopo, ed è la sua unica forza.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Debito Vecchio

| | |
|---|---|
| famiglia | bonds |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| al Consiglio | +1 se ti opponi |
| cosa lascia | nella sede del rivale diventa #indebitata |
| id | `AST_BONDS_OLD_DEBT` |

> Nessuno se lo ricorda tranne le due persone che contano, e una delle due lo tira fuori adesso.

**Temi:** Vie · Fede

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Esigere.** Metti #debito_chiamato su di lei: ti da' 1 carta adesso, oppure scende di 1 gradino nel rapporto con te.
B. **Rimettere.** Metti #debito_rimesso e sali di 2 gradini nel rapporto con lei.

**RISONANZA (avviene sempre)** — Scalda Fede +1. Un debito vecchio non e' una somma: e' una storia che qualcuno raccontera' diversamente. Se il debito e' stato chiamato: Fede +2.

> Se il bersaglio porta gia' `debt_called`: Fede scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Debito Vecchio.
What is happening: Nessuno se lo ricorda tranne le due persone che contano, e una delle due lo tira fuori adesso.
Dominant accent: porpora tenue, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

### Famiglia force

#### Le Porte Bruciate

| | |
|---|---|
| famiglia | force |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| cosa lascia | chi gioca se ne va dove si discute |
| id | `AST_FORCE_BURNED_GATE` |

> Chi apre una porta così non resta lì a difenderla.

**Temi:** Potere · Terra

**BERSAGLIO** — Scegli un luogo con #capitale o una struttura murata. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Bruciare la porta.** Rivendica il luogo e metti 1 Cicatrice.
B. **Mostrare la fiaccola.** Metti #malcontento su quel luogo e su un luogo confinante.

**RISONANZA (avviene sempre)** — Scalda Potere +2. Le porte bruciate si raccontano per due generazioni, e nessuna versione e' la tua. Se una domanda e' rimasta aperta: Potere +3.

> Se il bersaglio porta gia' `question_unresolved`: Potere scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere o Terra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Le Porte Bruciate.
What is happening: Chi apre una porta così non resta lì a difenderla.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Il Vecchio Esercito

| | |
|---|---|
| famiglia | force |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | la domanda in gioco sale |
| id | `AST_FORCE_OLD_ARMY` |

> Richiamare i vecchi reggimenti dice al mondo che la cosa è seria.

**Temi:** Potere

**BERSAGLIO** — Scegli un luogo con #capitale, #conteso o #malcontento. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Richiamarli sotto le armi.** Sposta due tue presenze in quel luogo, anche da lontano.
B. **Lasciarli tornare a casa.** Togli #malcontento dal luogo e pesca 1 Autorita'.

**RISONANZA (avviene sempre)** — Scalda Antico +2. Un esercito che si muove e' una domanda su chi comanda, posta senza parole. Se la corona e' stata divisa: Antico +3.

> Se il bersaglio porta gia' `crown_divided`: Antico scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Il Vecchio Esercito.
What is happening: Richiamare i vecchi reggimenti dice al mondo che la cosa è seria.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Assedio

| | |
|---|---|
| famiglia | force |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | discard |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| al Consiglio | +2 se ti opponi |
| cosa lascia | La Carestia sale, viene giu' Presidio dove si discute |
| id | `AST_FORCE_SIEGE` |

> Non serve prendere una cosa per impedire che sia di qualcun altro — ma l'assedio affama anche la terra intorno.

**Temi:** Potere · Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #capitale, #granaio o una struttura murata. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Stringere l'assedio.** Rivendica il luogo: al prossimo Consiglio la sua Domanda si apre e parli per primo.
B. **Affamare e aspettare.** Metti #fame sul luogo.

**RISONANZA (avviene sempre)** — Scalda Terra +2. Un assedio si vede da lontano, e chi ha fame lo racconta prima di chi comanda. Se il grano e' stato requisito: Terra +3.

> Se il bersaglio porta gia' `grain_requisitioned`: Terra scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Potere o Sopravvivenza.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Assedio.
What is happening: Non serve prendere una cosa per impedire che sia di qualcun altro — ma l'assedio affama anche la terra intorno.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Banda Armata

| | |
|---|---|
| famiglia | force |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | la domanda in gioco sale |
| id | `AST_FORCE_WARBAND` |

> Arrivano dove la questione è aperta, e la paura non si spegne insieme alla questione.

**Temi:** Potere · Terra

**BERSAGLIO** — Scegli un luogo con #selvaggio, #pascolo, #abbandonato o #conteso che non sia una #capitale. Vale anche il #bosco, e ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Prendere il posto.** Sposta una tua presenza li'.
B. **Spogliare il posto.** Metti #saccheggiato sul luogo e prendi 1 carta a caso dalla mano di chi lo controlla.

**RISONANZA (avviene sempre)** — Scalda Terra +2. Una banda armata non torna indietro uguale, e nemmeno il posto da cui e' passata. Se il luogo e' #saccheggiato: Terra +3, e ci resta #malcontento.

> Se il bersaglio porta gia' `condition:plundered`: Terra scalda di 3 invece che di 2, e lascia `condition:unrest`.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Potere o Terra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Banda Armata.
What is happening: Arrivano dove la questione è aperta, e la paura non si spegne insieme alla questione.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Guardia di Confine

| | |
|---|---|
| famiglia | force |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| al Consiglio | +1 sul suo tema |
| cosa lascia | Le Vie Interrotte sale |
| id | `AST_FORCE_BORDER_WATCH` |

> Contano i carri che passano, e sanno quali contare. Ogni conta ferma la strada.

**Temi:** Terra · Potere

**BERSAGLIO** — Scegli un luogo con #capitale, #granaio, #pascolo o #conteso. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Guardare chi arriva.** Scopri una questione velata che tocca quel luogo, e pesca 1 Sapere.
B. **Far sapere che si guarda.** Metti #conteso sul luogo.

**RISONANZA (avviene sempre)** — Scalda Terra +1. Un confine sorvegliato e' un confine che qualcuno ha appena disegnato. Se il luogo porta #pascolo: Terra +2, e ci resta #malcontento.

> Se il bersaglio porta gia' `nomad_range`: Terra scalda di 2 invece che di 1, e lascia `condition:unrest`.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Terra o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Guardia di Confine.
What is happening: Contano i carri che passano, e sanno quali contare. Ogni conta ferma la strada.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Leva Contadina

| | |
|---|---|
| famiglia | force |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | La Carestia sale |
| id | `AST_FORCE_LEVY` |

> Uomini con attrezzi da lavoro tenuti come lance. Bastano finché nessuno li conta — ma i campi restano soli.

**Temi:** Potere · Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #granaio, #pascolo o #capitale dove hai gia' una presenza. Vale anche ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Chiamare la leva.** Sposta una tua presenza da quel luogo a un luogo confinante.
B. **Tenerli a casa.** La presenza resta. Metti #razionato sul luogo: nessuno puo' requisirgli il grano fino a fine Atto.

**RISONANZA (avviene sempre)** — Scalda Sopravvivenza +1. I campi restano soli: chi tiene la lancia non tiene la falce. Se il luogo e' #magro: Sopravvivenza +2, e ci resta #fame.

> Se il bersaglio porta gia' `condition:lean`: Sopravvivenza scalda di 2 invece che di 1, e lascia `condition:starving`.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Leva Contadina.
What is happening: Uomini con attrezzi da lavoro tenuti come lance. Bastano finché nessuno li conta — ma i campi restano soli.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Mercenari

| | |
|---|---|
| famiglia | force |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +1 sempre |
| cosa lascia | dove si discute diventa #inquieta |
| id | `AST_FORCE_MERCENARIES` |

> Valgono lo stesso ovunque li porti. Dove passano, però, resta l'inquietudine.

**Temi:** Potere · Vie

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Prestarli.** Sali di 1 gradino nel rapporto con lei.
B. **Toglierli di mezzo.** Scendi di 1 gradino con lei e pesca 1 Ricchezza.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Chi si compra si ricompra, e il prezzo lo sa gia' qualcun altro. Se il debito e' stato chiamato: Vie +2.

> Se il bersaglio porta gia' `debt_called`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Potere o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Mercenari.
What is happening: Valgono lo stesso ovunque li porti. Dove passano, però, resta l'inquietudine.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Posto di Blocco

| | |
|---|---|
| famiglia | force |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| al Consiglio | +1 se ti opponi |
| cosa lascia | dove si discute diventa tagliata fuori |
| id | `AST_FORCE_ROADBLOCK` |

> Fermare un carro costa sempre meno che farlo partire.

**Temi:** Vie · Potere

**BERSAGLIO** — Scegli un luogo con #commercio, #dogana o #capitale che non sia gia' #tagliato_fuori. Vale anche il #porto, e ogni luogo del dominio del #territorio.

**AZIONE — scegli 1**

A. **Sbarrare la strada.** Metti #tagliato_fuori sul luogo. Finche' c'e', muovere una presenza dentro o fuori costa 1 carta in piu'.
B. **Farsi pagare il passaggio.** Pesca 1 Ricchezza. Il luogo resta aperto a tutti, te compreso.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Una strada su cui c'e' un posto di blocco non e' piu' una strada: e' una porta, e le porte si contano. Se il pedaggio si divide: Vie +2.

> Se il bersaglio porta gia' `toll_shared`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Posto di Blocco.
What is happening: Fermare un carro costa sempre meno che farlo partire.
Dominant accent: rosso ossido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

### Famiglia knowledge

#### Il Cristallo Rosso

| | |
|---|---|
| famiglia | knowledge |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| cosa lascia | la domanda in gioco si apre a tutti |
| id | `AST_KNOWLEDGE_RED_CRYSTAL` |

> Mostrarlo chiude ogni dubbio, e apre la domanda a chiunque fosse nella stanza.

**Temi:** Antico · Fede

**BERSAGLIO** — Scegli un luogo con #cristallo, #selvaggio o #sigillato. Vale anche la #miniera, e ogni luogo del dominio dell'#antico.

**AZIONE — scegli 1**

A. **Aprire la vena.** Togli #sigillato dal luogo e aggiungi una tua presenza.
B. **Misurare senza toccare.** Metti #cristallo_misurato sul luogo e pesca 1 Sapere.

**RISONANZA (avviene sempre)** — Scalda Antico +1. Il Risveglio non distingue fra chi scava e chi guarda. Se il Cristallo e' stato sfruttato: Antico +3, e ci resta #sfruttato.

> Se il bersaglio porta gia' `crystal_exploited`: Antico scalda di 3 invece che di 1, e lascia `condition:exploited`.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Antico o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Il Cristallo Rosso.
What is happening: Mostrarlo chiude ogni dubbio, e apre la domanda a chiunque fosse nella stanza.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Deposizione Sigillata

| | |
|---|---|
| famiglia | knowledge |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| cosa lascia | la domanda in gioco sale |
| id | `AST_KNOWLEDGE_SEALED_TESTIMONY` |

> Quello che era scritto per un solo lettore adesso lo hanno sentito tutti.

**Temi:** Potere · Fede

**BERSAGLIO** — Scegli un luogo con #capitale, #conteso o un archivio. Vale anche l'#isola, e ogni luogo del dominio dell'#antico.

**AZIONE — scegli 1**

A. **Aprire la busta.** Rivendica il luogo e metti #tradimento_detto sul mondo.
B. **Tenerla sigillata.** Rivendica il luogo.

**RISONANZA (avviene sempre)** — Scalda Potere +2. Una deposizione sigillata pesa uguale aperta o chiusa: quello che conta e' che esista. Se una domanda e' rimasta aperta: Potere +3.

> Se il bersaglio porta gia' `question_unresolved`: Potere scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Deposizione Sigillata.
What is happening: Quello che era scritto per un solo lettore adesso lo hanno sentito tutti.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Prova

| | |
|---|---|
| famiglia | knowledge |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | torna in mano se la proposta passa |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| cosa lascia | la domanda in gioco si apre a tutti |
| id | `AST_KNOWLEDGE_PROOF` |

> Una prova dimostrata non si consuma, e apre la questione a tutti i presenti.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli un luogo con #capitale, #cristallo o una stanza dove si tengono le carte. Vale anche la #miniera, e ogni luogo del dominio dell'#antico.

**AZIONE — scegli 1**

A. **Mostrare la prova.** Scopri una questione velata e metti #sapere_condiviso sul mondo.
B. **Tenere la prova.** Scopri la questione e pesca 1 Sapere.

**RISONANZA (avviene sempre)** — Scalda Fede +1. Una prova non chiude una discussione: decide chi dovra' chiamare bugiardo chi. Se quello che si e' saputo lo sanno tutti: Fede +2.

> Se il bersaglio porta gia' `knowledge_shared`: Fede scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Prova.
What is happening: Una prova dimostrata non si consuma, e apre la questione a tutti i presenti.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Testimone

| | |
|---|---|
| famiglia | knowledge |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| al Consiglio | +2 se ti opponi |
| cosa lascia | nella sede del rivale diventa #inquieta |
| id | `AST_KNOWLEDGE_WITNESS` |

> Un testimone si spende una volta sola, e la deposizione agita la casa accusata.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Farlo parlare.** Alza quella questione di 2 e metti #tradimento_detto sul mondo.
B. **Farlo tacere.** Abbassa quella questione di 2.

**RISONANZA (avviene sempre)** — Scalda Fede +2. Un testimone non porta la verita': porta la propria, e adesso il tavolo deve scegliere. Se il tradimento e' stato detto ad alta voce: Fede +3.

> Se il bersaglio porta gia' `betrayal_spoken`: Fede scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Testimone.
What is happening: Un testimone si spende una volta sola, e la deposizione agita la casa accusata.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Archivio

| | |
|---|---|
| famiglia | knowledge |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | torna in mano se la proposta passa |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| cosa lascia | si alza Archivio dove si discute |
| id | `AST_KNOWLEDGE_ARCHIVE` |

> Le carte non si consumano: si consuma chi le sa leggere.

**Temi:** Vie · Fede

**BERSAGLIO** — Scegli un luogo con #capitale, #commercio o una stanza dove si tengono le carte. Vale anche ogni luogo del dominio dell'#antico.

**AZIONE — scegli 1**

A. **Cercare indietro.** Scopri una questione velata che tocca il luogo, e pesca 1 Sapere.
B. **Far leggere a tutti.** Metti #registro_pubblico sul mondo.

**RISONANZA (avviene sempre)** — Scalda Antico +1. Un archivio non conserva il passato: conserva la versione che qualcuno ha avuto il tempo di scrivere. Se i conti sono pubblici: Antico +2.

> Se il bersaglio porta gia' `ledger_public`: Antico scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Archivio.
What is happening: Le carte non si consumano: si consuma chi le sa leggere.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Registro

| | |
|---|---|
| famiglia | knowledge |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +1 se ti opponi |
| cosa lascia | il mondo registra: i conti sono pubblici |
| id | `AST_KNOWLEDGE_LEDGER` |

> Chi tiene i conti sa cosa manca, e lo dice nel momento peggiore. Da quel momento i conti sono di tutti.

**Temi:** Vie

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Aprire il registro.** Metti #registro_pubblico sul mondo e sali di 1 gradino con lei.
B. **Chiudere il registro.** Scendi di 1 gradino con lei e metti #debito_chiamato sul mondo.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Un registro non e' un elenco di numeri: e' un elenco di persone, in ordine di quanto devono. Se i conti sono pubblici: Vie +2.

> Se il bersaglio porta gia' `ledger_public`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Registro.
What is happening: Chi tiene i conti sa cosa manca, e lo dice nel momento peggiore. Da quel momento i conti sono di tutti.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Mappa Vecchia

| | |
|---|---|
| famiglia | knowledge |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| al Consiglio | +1 sul suo tema |
| cosa lascia | dove si discute non e' piu' il ponte rotto |
| id | `AST_KNOWLEDGE_OLD_MAP` |

> I confini sono sbagliati; le strade no, e una strada giusta ricuce un ponte rotto.

**Temi:** Vie · Terra

**BERSAGLIO** — Scegli un luogo con #tagliato_fuori, #selvaggio o #commercio. Vale anche la #palude, l'#isola, e ogni luogo del dominio dell'#antico.

**AZIONE — scegli 1**

A. **Trovare il passaggio.** Togli #tagliato_fuori dal luogo, oppure muovi una tua presenza li' ignorando i confini.
B. **Tenere la mappa per se'.** Metti #registro_del_commercio: al prossimo Consiglio vale +1.

**RISONANZA (avviene sempre)** — Scalda Antico +1. Una strada che qualcuno ha ritrovato e' una strada che qualcun altro vorra' chiudere. Se il luogo porta #commercio: Antico +2.

> Se il bersaglio porta gia' `trade`: Antico scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Antico.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Mappa Vecchia.
What is happening: I confini sono sbagliati; le strade no, e una strada giusta ricuce un ponte rotto.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Voce di Corridoio

| | |
|---|---|
| famiglia | knowledge |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| cosa lascia | la domanda in gioco si apre a tutti |
| id | `AST_KNOWLEDGE_RUMOR` |

> Non è vera. Non è ancora falsa. E finché gira, i numeri si nascondono dietro le voci.

**Temi:** Fede · Potere

**BERSAGLIO** — Scegli un luogo con #capitale, #commercio, #malcontento o #mercato. Vale anche il #porto, e ogni luogo del dominio delle #risorse.

**AZIONE — scegli 1**

A. **Ascoltare la voce.** Scopri una questione velata che tocca il luogo.
B. **Mettere in giro la voce.** Metti #malcontento sul luogo.

**RISONANZA (avviene sempre)** — Scalda Antico +1. Una voce di corridoio e' una verita' che non ha ancora deciso di chi essere. Se il tradimento e' stato detto ad alta voce: Antico +2.

> Se il bersaglio porta gia' `betrayal_spoken`: Antico scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Fede o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Voce di Corridoio.
What is happening: Non è vera. Non è ancora falsa. E finché gira, i numeri si nascondono dietro le voci.
Dominant accent: verde-azzurro pallido, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

### Famiglia people

#### Esodo

| | |
|---|---|
| famiglia | people |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | chi gioca se ne va dove si discute |
| id | `AST_PEOPLE_EXODUS` |

> Chi parte non torna al tavolo.

**Temi:** Terra · Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #fame, #svuotato, #abbandonato o #pascolo. Vale anche la #palude, e ogni luogo del dominio della #sopravvivenza.

**AZIONE — scegli 1**

A. **Andarsene tutti.** Togli tutte le tue presenze da quel luogo e mettine due in un altro qualsiasi. Metti #svuotato dove sei partito.
B. **Mandare avanti i primi.** Sposta una presenza in un luogo qualsiasi e metti li' il tuo insediamento.

**RISONANZA (avviene sempre)** — Scalda Terra +2. Un esodo non si annulla: il posto da cui si e' partiti resta com'e' rimasto. Se i Nahr si sono fermati: Terra +3, e ci resta la Cicatrice «lo sgombero».

> Se il bersaglio porta gia' `nahr_settled`: Terra scalda di 3 invece che di 2, e lascia `scar:emptied`.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Terra o Sopravvivenza.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Esodo.
What is happening: Chi parte non torna al tavolo.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Braccia Ferme

| | |
|---|---|
| famiglia | people |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | la domanda in gioco sale |
| id | `AST_PEOPLE_STILL_HANDS` |

> Un paese che si ferma non si rimette in moto dove l'avevi lasciato.

**Temi:** Sopravvivenza · Vie

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Fermare tutto.** Alza quella questione di 2.
B. **Fermare solo una cosa.** Abbassa quella questione di 1 e pesca 1 Popolo.

**RISONANZA (avviene sempre)** — Scalda Vie +2. Quando le braccia si fermano, le prime cose che non arrivano sono quelle che venivano da lontano. Se il pedaggio si divide: Vie +3.

> Se il bersaglio porta gia' `toll_shared`: Vie scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Sopravvivenza o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Braccia Ferme.
What is happening: Un paese che si ferma non si rimette in moto dove l'avevi lasciato.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Mobilitazione

| | |
|---|---|
| famiglia | people |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| al Consiglio | +2 se ti opponi |
| cosa lascia | la domanda in gioco sale |
| id | `AST_PEOPLE_MOBILIZATION` |

> È più facile fermare qualcosa in molti che costruirla, e la piazza resta calda.

**Temi:** Sopravvivenza · Terra

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Chiamare tutti.** Alza quella questione di 2.
B. **Chiamare solo i tuoi.** Alza quella questione di 1 e pesca 1 Popolo.

**RISONANZA (avviene sempre)** — Scalda Sopravvivenza +2. Chi si mobilita non lavora, e chi non lavora mangia lo stesso. Se una domanda e' rimasta aperta: Sopravvivenza +3.

> Se il bersaglio porta gia' `question_unresolved`: Sopravvivenza scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Sopravvivenza o Terra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Mobilitazione.
What is happening: È più facile fermare qualcosa in molti che costruirla, e la piazza resta calda.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Portavoce

| | |
|---|---|
| famiglia | people |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | discard |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| cosa lascia | il rapporto fra chi gioca e il rivale cambia |
| id | `AST_PEOPLE_SPOKESMAN` |

> Qualcuno che dice ad alta voce quello che già pensano in molti, e che dopo non può più tornare indietro.

**Temi:** Potere · Fede

**BERSAGLIO** — Scegli un luogo con #capitale, #malcontento o un insediamento cresciuto. Vale anche ogni luogo del dominio della #sopravvivenza.

**AZIONE — scegli 1**

A. **Prendere la parola.** Rivendica il luogo: al prossimo Consiglio parli per primo.
B. **Darla a un altro.** Un'altra casa parla per prima al prossimo Consiglio e sale di 2 gradini nel rapporto con te.

**RISONANZA (avviene sempre)** — Scalda Potere +1. Un portavoce e' qualcuno che ha deciso di chi e' la voce, e l'ha deciso prima di parlare. Se la richiesta e' stata ascoltata: Potere +2.

> Se il bersaglio porta gia' `petition_heard`: Potere scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Potere o Fede.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Portavoce.
What is happening: Qualcuno che dice ad alta voce quello che già pensano in molti, e che dopo non può più tornare indietro.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Folla

| | |
|---|---|
| famiglia | people |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | nella capitale diventa #inquieta |
| id | `AST_PEOPLE_CROWD` |

> Nessuno l'ha convocata. È arrivata lo stesso, in capitale, e la capitale resta inquieta.

**Temi:** Sopravvivenza · Potere

**BERSAGLIO** — Scegli una questione aperta sul tavolo.

**AZIONE — scegli 1**

A. **Portare la folla sotto le finestre.** Alza quella questione di 1.
B. **Mandare la folla a casa.** Abbassa quella questione di 1.

**RISONANZA (avviene sempre)** — Scalda Sopravvivenza +1. Una folla che si raduna mangia dove si raduna, e i conti li fa il posto. Se il grano e' stato requisito: Sopravvivenza +2.

> Se il bersaglio porta gia' `grain_requisitioned`: Sopravvivenza scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Sopravvivenza o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Folla.
What is happening: Nessuno l'ha convocata. È arrivata lo stesso, in capitale, e la capitale resta inquieta.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Consiglio degli Anziani

| | |
|---|---|
| famiglia | people |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| al Consiglio | +1 se ti opponi |
| cosa lascia | dove si discute non e' piu' in lutto |
| id | `AST_PEOPLE_ELDERS` |

> Parlano piano, dicono di no, e vengono ripetuti per tre villaggi. E sanno accompagnare un lutto.

**Temi:** Fede · Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #granaio, #pascolo, #lutto o un insediamento. Vale anche ogni luogo del dominio della #sopravvivenza.

**AZIONE — scegli 1**

A. **Ascoltarli.** Scopri una questione velata che tocca il luogo, e pesca 1 Legami.
B. **Farli parlare in pubblico.** Togli #lutto o #malcontento dal luogo.

**RISONANZA (avviene sempre)** — Scalda Antico +1. Chi ricorda decide cosa c'era prima, e cosa c'era prima decide cosa e' giusto adesso. Se la fede ha avuto un posto: Antico +2.

> Se il bersaglio porta gia' `faith_established`: Antico scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Fede o Sopravvivenza.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Consiglio degli Anziani.
What is happening: Parlano piano, dicono di no, e vengono ripetuti per tre villaggi. E sanno accompagnare un lutto.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Braccia per il Raccolto

| | |
|---|---|
| famiglia | people |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +1 sul suo tema |
| cosa lascia | dove si discute non e' piu' #affamata |
| id | `AST_PEOPLE_HARVEST_HANDS` |

> Non sono un esercito: ma senza di loro non si mangia, e dove arrivano la fame si spegne.

**Temi:** Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #granaio, #magro o #fame. Vale anche ogni luogo del dominio della #sopravvivenza.

**AZIONE — scegli 1**

A. **Portare le braccia.** Togli #magro dal luogo, oppure abbassa di 1 la questione Sopravvivenza piu' calda.
B. **Prestare le braccia.** Un'altra casa toglie #magro da un suo luogo. Sali di 1 gradino nel rapporto con lei.

**RISONANZA (avviene sempre)** — Scalda Terra +1. Le braccia che raccolgono qui sono braccia che non arano altrove. Se il grano e' stato requisito: Terra +2.

> Se il bersaglio porta gia' `grain_requisitioned`: Terra scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Sopravvivenza.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Braccia per il Raccolto.
What is happening: Non sono un esercito: ma senza di loro non si mangia, e dove arrivano la fame si spegne.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Marcia

| | |
|---|---|
| famiglia | people |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | dove si discute non e' piu' #razionata |
| id | `AST_PEOPLE_MARCH` |

> Poca gente, ma in strada e alla stessa ora. Il punto non è quanti sono: è che si sono trovati.

**Temi:** Sopravvivenza · Terra

**BERSAGLIO** — Scegli un luogo con #fame, #razionato, #magro o #pascolo. Vale anche ogni luogo del dominio della #sopravvivenza.

**AZIONE — scegli 1**

A. **Marciare verso il grano.** Sposta una tua presenza in un luogo con #granaio, anche se non confina.
B. **Marciare sulla capitale.** Metti #malcontento su un luogo con #capitale, ovunque sia.

**RISONANZA (avviene sempre)** — Scalda Sopravvivenza +1. Una marcia non torna indietro da sola: qualcuno deve prometterle qualcosa. Se sul luogo c'e' #fame: Sopravvivenza +2, e ci resta #malcontento.

> Se il bersaglio porta gia' `condition:starving`: Sopravvivenza scalda di 2 invece che di 1, e lascia `condition:unrest`.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Sopravvivenza o Terra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Marcia.
What is happening: Poca gente, ma in strada e alla stessa ora. Il punto non è quanti sono: è che si sono trovati.
Dominant accent: terracotta, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

### Famiglia wealth

#### Ipoteca sulle Terre

| | |
|---|---|
| famiglia | wealth |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| cosa lascia | il rivale entra dove si discute |
| id | `AST_WEALTH_LAND_MORTGAGE` |

> Impegnare una terra fa arrivare chi la vuole.

**Temi:** Terra · Vie

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Prendere la terra in garanzia.** Scendi di 1 gradino con lei. Se a fine anno controlla meno terre di adesso, ne prendi una tu.
B. **Rimettere l'ipoteca.** Sali di 2 gradini con lei e metti #debito_rimesso sul mondo.

**RISONANZA (avviene sempre)** — Scalda Terra +2. Un'ipoteca sulla terra e' una domanda su chi ci vive, fatta a chi non e' presente. Se il debito e' stato chiamato: Terra +3.

> Se il bersaglio porta gia' `debt_called`: Terra scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Terra o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Ipoteca sulle Terre.
What is happening: Impegnare una terra fa arrivare chi la vuole.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Il Tesoro

| | |
|---|---|
| famiglia | wealth |
| forza | 3 |
| rarita' | rare · 1 copia nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | la domanda in gioco sale |
| id | `AST_WEALTH_TREASURY` |

> Aprire il tesoro dice a tutti quanto vale davvero la questione.

**Temi:** Potere · Vie

**BERSAGLIO** — Scegli un luogo con #capitale o #commercio. Vale anche ogni luogo del dominio delle #risorse.

**AZIONE — scegli 1**

A. **Aprire il tesoro.** Sposta due tue presenze in quel luogo.
B. **Chiudere il tesoro.** Pesca 2 Ricchezza e metti #malcontento sul luogo.

**RISONANZA (avviene sempre)** — Scalda Potere +2. Un tesoro aperto e' una promessa; un tesoro chiuso e' un'accusa. Nessuno dei due resta segreto. Se la corona e' stata spogliata: Potere +3.

> Se il bersaglio porta gia' `crown_dispossessed`: Potere scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 3, +1 se la Domanda e' Potere o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Il Tesoro.
What is happening: Aprire il tesoro dice a tutti quanto vale davvero la questione.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Carovana

| | |
|---|---|
| famiglia | wealth |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | si scarta sempre |
| se la cali | MUOVERE — sposti una tua presenza su un'altra Regione |
| cosa lascia | dove si discute non e' piu' tagliata fuori |
| id | `AST_WEALTH_CARAVAN` |

> Una carovana spesa è una carovana partita, e una carovana che parte riapre la via.

**Temi:** Vie

**BERSAGLIO** — Scegli un luogo con #commercio, #mercato o #tagliato_fuori. Vale anche il #porto, e ogni luogo del dominio delle #risorse.

**AZIONE — scegli 1**

A. **Farla arrivare.** Sposta una tua presenza li' e togli #tagliato_fuori dal luogo.
B. **Dirottarla.** Sposta la presenza in un altro luogo con #commercio e pesca 1 Ricchezza.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Una carovana che passa dice a tutti quanto vale passare di li'. Se il debito e' stato chiamato: Vie +2.

> Se il bersaglio porta gia' `debt_called`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Carovana.
What is happening: Una carovana spesa è una carovana partita, e una carovana che parte riapre la via.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Chiavi del Granaio

| | |
|---|---|
| famiglia | wealth |
| forza | 2 |
| rarita' | uncommon · 2 copie nel mazzo |
| dopo il voto | discard |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +2 se ti opponi |
| cosa lascia | dove si discute diventa #razionata |
| id | `AST_WEALTH_GRANARY_KEYS` |

> Non possiedi il grano: possiedi la serratura, e la serratura raziona.

**Temi:** Sopravvivenza · Potere

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Dare le chiavi.** Sale di 2 gradini nel rapporto con te.
B. **Tenere le chiavi.** Scendi di 1 gradino con lei e metti #grano_requisito sul mondo.

**RISONANZA (avviene sempre)** — Scalda Sopravvivenza +2. Le chiavi non fanno il grano: decidono soltanto chi resta fuori dalla porta. Se il grano e' stato requisito: Sopravvivenza +3.

> Se il bersaglio porta gia' `grain_requisitioned`: Sopravvivenza scalda di 3 invece che di 2.

**IN CONSIGLIO** — vale 2, +1 se la Domanda e' Sopravvivenza o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Chiavi del Granaio.
What is happening: Non possiedi il grano: possiedi la serratura, e la serratura raziona.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Credito

| | |
|---|---|
| famiglia | wealth |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | FORGIARE — muovi di un passo il rapporto con un'altra casa |
| al Consiglio | +1 sempre |
| cosa lascia | il mondo registra: il debito e' stato chiamato |
| id | `AST_WEALTH_CREDIT` |

> Vale nel momento in cui lo chiedi, e non un minuto dopo: chiederlo chiama tutti i debiti.

**Temi:** Vie · Potere

**BERSAGLIO** — Scegli un'altra casa al tavolo.

**AZIONE — scegli 1**

A. **Aprire credito.** Sale di 2 gradini nel rapporto con te e metti #indebitata sul mondo.
B. **Comprare il suo debito.** Scendi di 1 gradino con lei e pesca 2 Ricchezza.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Il credito e' una corda: la tiene chi presta, e la sente chi la porta al collo. Se il debito e' stato chiamato: Vie +2.

> Se il bersaglio porta gia' `debt_called`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Potere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Credito.
What is happening: Vale nel momento in cui lo chiedi, e non un minuto dopo: chiederlo chiama tutti i debiti.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Riserva di Grano

| | |
|---|---|
| famiglia | wealth |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | INFLUENZARE — alzi o abbassi di 1 una domanda dell'anno |
| cosa lascia | La Carestia scende |
| id | `AST_WEALTH_GRAIN` |

> Conta più di un titolo, per il tempo in cui dura. E dura quanto basta.

**Temi:** Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #granaio, #fame o #magro. Vale anche ogni luogo del dominio delle #risorse.

**AZIONE — scegli 1**

A. **Aprire i granai.** Togli #fame dal luogo e abbassa di 1 la questione Sopravvivenza piu' calda.
B. **Chiudere i granai.** Metti #razionato sul luogo e alza di 1 la questione Sopravvivenza piu' calda.

**RISONANZA (avviene sempre)** — Scalda Sopravvivenza +1. Il grano che si tocca e' grano che qualcuno ha contato. Se il grano e' stato requisito: Sopravvivenza +2.

> Se il bersaglio porta gia' `grain_requisitioned`: Sopravvivenza scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Sopravvivenza o Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Riserva di Grano.
What is happening: Conta più di un titolo, per il tempo in cui dura. E dura quanto basta.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Sale

| | |
|---|---|
| famiglia | wealth |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | TRAMARE — leggi in privato qualcosa che e' coperto |
| al Consiglio | +1 sul suo tema |
| cosa lascia | dove si discute non e' piu' #magra |
| id | `AST_WEALTH_SALT` |

> Non nutre nessuno: senza, quello che nutre non arriva.

**Temi:** Vie · Sopravvivenza

**BERSAGLIO** — Scegli un luogo con #commercio, #granaio, #mercato o #magro. Vale anche il #porto, e ogni luogo del dominio delle #risorse.

**AZIONE — scegli 1**

A. **Vendere il sale.** Scopri una questione velata che tocca il luogo, e pesca 1 Ricchezza.
B. **Salare le riserve.** Togli #magro dal luogo.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Il sale e' l'unica merce che tutti comprano e nessuno vuole nominare. Se il pedaggio si divide: Vie +2.

> Se il bersaglio porta gia' `toll_shared`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie o Sopravvivenza.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Sale.
What is happening: Non nutre nessuno: senza, quello che nutre non arriva.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

#### Pedaggio

| | |
|---|---|
| famiglia | wealth |
| forza | 1 |
| rarita' | common · 4 copie nel mazzo |
| dopo il voto | discard |
| se la cali | RIVENDICARE — ti prendi il diritto di aprire il Consiglio |
| al Consiglio | +1 se ti opponi |
| cosa lascia | si alza Pedaggio dove si discute |
| id | `AST_WEALTH_TOLL` |

> Una corda tesa fra due pali, e il diritto di non alzarla.

**Temi:** Vie · Potere

**BERSAGLIO** — Scegli un luogo con #commercio, #dogana o #strada. Vale anche il #porto, e ogni luogo del dominio delle #risorse.

**AZIONE — scegli 1**

A. **Alzare la sbarra.** Rivendica il luogo: al prossimo Consiglio la sua Domanda si apre.
B. **Dividere l'incasso.** Metti #pedaggio_diviso sul luogo e sali di 1 gradino nel rapporto con chi lo controlla.

**RISONANZA (avviene sempre)** — Scalda Vie +1. Ogni pedaggio e' un prezzo che qualcuno non aveva messo in conto. Se il debito e' stato chiamato: Vie +2.

> Se il bersaglio porta gia' `debt_called`: Vie scalda di 2 invece che di 1.

**IN CONSIGLIO** — vale 1, +1 se la Domanda e' Vie.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Asset card. Single evocative scene: Pedaggio.
What is happening: Una corda tesa fra due pali, e il diritto di non alzarla.
Dominant accent: ambra, over the game's muted earth palette. Low side
lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror.
```

</details>

---

## Le carte Echo (il Narratore)

Non si votano: si **calano**, e la storia prende una piega. Ognuna porta
una funzione di Propp, e alcune convocano un Consiglio.

### Amnistia

| | |
|---|---|
| famiglia | resolution |
| funzione | liberation |
| cosa fa | scrive «L'Ordine Rimesso in Piedi» · Nel mondo: l'amnistia e' stata concessa |
| id | `ECH_AMNESTY` |

> Si decide di non contare più chi aveva giurato a chi. Non tutti sono d'accordo, e nessuno lo dice.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Amnistia.
What is happening: Si decide di non contare più chi aveva giurato a chi. Non tutti sono d'accordo, e nessuno lo dice.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Tradimento

| | |
|---|---|
| famiglia | rupture |
| funzione | betrayal |
| convoca un Consiglio | su La Carestia |
| cosa fa | Nel mondo: il tradimento e' stato detto ad alta voce · La Carestia sale di 1, o la domanda che il tavolo ha aperto · apre subito un Consiglio su La Carestia |
| id | `ECH_BETRAYAL` |

> Un accordo viene rotto da chi lo aveva proposto. Il danno non è la rottura: è che ora tutti ricalcolano.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Tradimento.
What is happening: Un accordo viene rotto da chi lo aveva proposto. Il danno non è la rottura: è che ora tutti ricalcolano.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Chiamata

| | |
|---|---|
| famiglia | pressure |
| funzione | request |
| convoca un Consiglio | su Il Debito |
| cosa fa | Il Debito sale di 1, o la domanda che il tavolo ha aperto · un luogo con commercio: e' pieno di debiti · apre subito un Consiglio su Il Debito |
| id | `ECH_CALL_OF_ACCOUNTS` |

> La Gilda scrive a tre città lo stesso giorno. Non chiede di pagare: chiede di confermare la cifra.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Chiamata.
What is happening: La Gilda scrive a tre città lo stesso giorno. Non chiede di pagare: chiede di confermare la cifra.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Carovana Perduta

| | |
|---|---|
| famiglia | rupture |
| funzione | attack |
| cosa fa | scrive «La Strada Spogliata» |
| id | `ECH_CARAVAN_LOST` |

> Undici carri partiti, nessuno arrivato, e nessun corpo trovato. È la parte senza corpi che spaventa.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Carovana Perduta.
What is happening: Undici carri partiti, nessuno arrivato, e nessun corpo trovato. È la parte senza corpi che spaventa.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Chi Siede

| | |
|---|---|
| famiglia | resolution |
| funzione | succession |
| cosa fa | scrive «L'Erede Nominato» |
| id | `ECH_CROWNING` |

> Un nome viene detto e non viene contestato. Non è giustizia: è che tutti sono stanchi.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Chi Siede.
What is happening: Un nome viene detto e non viene contestato. Non è giustizia: è che tutti sono stanchi.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Scoperta

| | |
|---|---|
| famiglia | turn |
| funzione | discovery |
| cosa fa | Il Risveglio adesso e aperta a tutti, o la domanda che il tavolo ha aperto · Nel mondo: il Cristallo e' stato misurato · chi la cala: scoperta: la misura |
| id | `ECH_DISCOVERY` |

> Qualcosa di nascosto viene misurato. Da questo momento la questione ha dei numeri, e i numeri si discutono.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Scoperta.
What is happening: Qualcosa di nascosto viene misurato. Da questo momento la questione ha dei numeri, e i numeri si discutono.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Sedia Vuota

| | |
|---|---|
| famiglia | pressure |
| funzione | threat |
| convoca un Consiglio | su La Successione |
| cosa fa | La Successione sale di 2, o la domanda che il tavolo ha aperto · un luogo con capitale: e' conteso · apre subito un Consiglio su La Successione |
| id | `ECH_EMPTY_THRONE` |

> Il re manca a un consiglio. Poi a un secondo. Alla terza volta la stanza ha smesso di aspettarlo.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Sedia Vuota.
What is happening: Il re manca a un consiglio. Poi a un secondo. Alla terza volta la stanza ha smesso di aspettarlo.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Partenza

| | |
|---|---|
| famiglia | rupture |
| funzione | separation |
| cosa fa | scrive «La Partenza» · La Carestia sale di 1, o la domanda che il tavolo ha aperto · la Regione della domanda: adesso e selva maledetta |
| id | `ECH_EXODUS` |

> Le carriole partono di notte per non dover salutare nessuno. Al mattino mancano tre famiglie su dieci.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Partenza.
What is happening: Le carriole partono di notte per non dover salutare nessuno. Al mattino mancano tre famiglie su dieci.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Annata Buona

| | |
|---|---|
| famiglia | turn |
| funzione | gift |
| cosa fa | scrive «Il Raccolto Torna» |
| id | `ECH_GOOD_YEAR` |

> Piove quando serve e smette quando serve. Non risolve niente, ma sposta la domanda di un anno.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Annata Buona.
What is happening: Piove quando serve e smette quando serve. Non risolve niente, ma sposta la domanda di un anno.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Le Mani Ferme

| | |
|---|---|
| famiglia | pressure |
| funzione | prohibition |
| cosa fa | La Carestia sale di 2, o la domanda che il tavolo ha aperto · un luogo con granaio: monta il malcontento |
| id | `ECH_HANDS_DOWN` |

> Nessuno alza le mani contro nessuno: le tengono ferme, e basta quello. Il lavoro si ferma dove serviva di piu', e nessuno ha dato un ordine.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Le Mani Ferme.
What is happening: Nessuno alza le mani contro nessuno: le tengono ferme, e basta quello. Il lavoro si ferma dove serviva di piu', e nessuno ha dato un ordine.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Mancanza

| | |
|---|---|
| famiglia | pressure |
| funzione | lack |
| cosa fa | La Carestia sale di 1, o la domanda che il tavolo ha aperto · un luogo con granaio: il raccolto non basta · un luogo con granaio: granaio va giu |
| id | `ECH_LACK` |

> Qualcosa che c'era non c'è più, e la sua assenza comincia a organizzare le giornate di tutti.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Mancanza.
What is happening: Qualcosa che c'era non c'è più, e la sua assenza comincia a organizzare le giornate di tutti.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Giuramento che Nessuno Sciolse

| | |
|---|---|
| famiglia | rupture |
| funzione | betrayal |
| convoca un Consiglio | su La Successione |
| cosa fa | La Successione sale di 1, o la domanda che il tavolo ha aperto · apre subito un Consiglio su La Successione |
| id | `ECH_LEGEND_BROKEN_OATH` |

> Qualcuno ripete a voce alta il giuramento che fu rotto, coi nomi di chi c'era. Le case contano da quanti anni nessuno lo nomina, e la conta non torna a nessuno.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Giuramento che Nessuno Sciolse.
What is happening: Qualcuno ripete a voce alta il giuramento che fu rotto, coi nomi di chi c'era. Le case contano da quanti anni nessuno lo nomina, e la conta non torna a nessuno.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Giorno che la Gilda Chiese Tutto

| | |
|---|---|
| famiglia | pressure |
| funzione | threat |
| convoca un Consiglio | su Il Debito |
| cosa fa | Il Debito sale di 1, o la domanda che il tavolo ha aperto · un luogo con commercio: e' pieno di debiti · apre subito un Consiglio su Il Debito |
| id | `ECH_LEGEND_CALLED_DAY` |

> La storia si racconta a ogni firma: una Gilda morta da secoli che un mattino chiese tutto insieme. Il debito di adesso comincia a pesare come quello antico.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Giorno che la Gilda Chiese Tutto.
What is happening: La storia si racconta a ogni firma: una Gilda morta da secoli che un mattino chiese tutto insieme. Il debito di adesso comincia a pesare come quello antico.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Ballata dell'Anno Buono

| | |
|---|---|
| famiglia | resolution |
| funzione | return |
| cosa fa | La Successione scende di 1, o la domanda che il tavolo ha aperto · un luogo con capitale: il malcontento si e' spento |
| id | `ECH_LEGEND_GOOD_YEAR` |

> Un cantastorie riporta in giro la ballata dell'anno in cui l'ordine torno davvero. Nessuno dei presenti c'era, e tutti giurano di ricordarselo.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Ballata dell'Anno Buono.
What is happening: Un cantastorie riporta in giro la ballata dell'anno in cui l'ordine torno davvero. Nessuno dei presenti c'era, e tutti giurano di ricordarselo.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Perdita

| | |
|---|---|
| famiglia | rupture |
| funzione | loss |
| cosa fa | La Carestia sale di 1, o la domanda che il tavolo ha aperto · un luogo con pascolo: e' in lutto · un rivale lascia un luogo con pascolo |
| id | `ECH_LOSS` |

> Qualcuno non c'è più, e la sua parte di lavoro resta scoperta.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Perdita.
What is happening: Qualcuno non c'è più, e la sua parte di lavoro resta scoperta.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Parola Data

| | |
|---|---|
| famiglia | rupture |
| funzione | violation |
| cosa fa | scrive «Il Patto Rotto» |
| id | `ECH_OATH_BROKEN` |

> La cosa che era stata proibita viene fatta, e viene fatta da chi l'aveva proibita.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Parola Data.
What is happening: La cosa che era stata proibita viene fatta, e viene fatta da chi l'aveva proibita.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Giuramento Prestato

| | |
|---|---|
| famiglia | turn |
| funzione | transformation |
| cosa fa | scrive «La Scorta Giurata» |
| id | `ECH_OATH_SWORN` |

> Due che si contavano come nemici mettono per iscritto una cosa sola, e quella regge.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Giuramento Prestato.
What is happening: Due che si contavano come nemici mettono per iscritto una cosa sola, e quella regge.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### L'Offerta

| | |
|---|---|
| famiglia | pressure |
| funzione | temptation |
| cosa fa | la domanda che il tavolo ha aperto sale di 1 · la Regione della domanda: e' pieno di debiti · chi la cala mette una presenza in la Regione della domanda |
| id | `ECH_OFFER` |

> Qualcuno propone una scorciatoia che funziona davvero. E il fatto che funzioni il problema.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: L'Offerta.
What is happening: Qualcuno propone una scorciatoia che funziona davvero. E il fatto che funzioni il problema.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Presagio

| | |
|---|---|
| famiglia | pressure |
| funzione | omen |
| cosa fa | Il Risveglio sale di 1, o la domanda che il tavolo ha aperto · chi la cala: scoperta: il presagio |
| id | `ECH_OMEN` |

> Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare del tutto.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Presagio.
What is happening: Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare del tutto.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### L'Incontro

| | |
|---|---|
| famiglia | turn |
| funzione | encounter |
| cosa fa | Nel mondo: ci si e' parlato · la domanda che il tavolo ha aperto scende di 1 |
| id | `ECH_PARLEY` |

> Due che non si parlavano si trovano nello stesso posto senza averlo deciso, e devono dirsi qualcosa.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: L'Incontro.
What is happening: Due che non si parlavano si trovano nello stesso posto senza averlo deciso, e devono dirsi qualcosa.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Supplica

| | |
|---|---|
| famiglia | pressure |
| funzione | request |
| convoca un Consiglio | su La Carestia |
| cosa fa | la domanda che il tavolo ha aperto sale di 1 · Nel mondo: la richiesta e' stata ascoltata · apre subito un Consiglio su La Carestia |
| id | `ECH_PETITION` |

> Arrivano a chiedere, e lo fanno in pubblico. Dire di no adesso costa più di quanto costava ieri.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Supplica.
What is happening: Arrivano a chiedere, e lo fanno in pubblico. Dire di no adesso costa più di quanto costava ieri.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Conto

| | |
|---|---|
| famiglia | resolution |
| funzione | punishment |
| cosa fa | scrive «Il Conto Saldato» |
| id | `ECH_RECKONING` |

> Si paga per quello che si è fatto, davanti a chi lo ha subito. Non ripara niente, ma chiude.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Conto.
What is happening: Si paga per quello che si è fatto, davanti a chi lo ha subito. Non ripara niente, ma chiude.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Riconciliazione

| | |
|---|---|
| famiglia | resolution |
| funzione | reconciliation |
| cosa fa | La Carestia scende di 1, o la domanda che il tavolo ha aperto · Il Risveglio scende di 1, o la domanda che il tavolo ha aperto · un luogo con capitale: il malcontento si e' spento |
| id | `ECH_RECONCILIATION` |

> Due parti che si erano contate come nemiche trovano un motivo pratico per smettere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Riconciliazione.
What is happening: Due parti che si erano contate come nemiche trovano un motivo pratico per smettere.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Rivelazione

| | |
|---|---|
| famiglia | turn |
| funzione | revelation |
| convoca un Consiglio | su Il Risveglio |
| cosa fa | Il Risveglio adesso e aperta a tutti, o la domanda che il tavolo ha aperto · Il Risveglio sale di 1, o la domanda che il tavolo ha aperto · apre subito un Consiglio su Il Risveglio |
| id | `ECH_REVELATION` |

> Cio che era privato diventa pubblico davanti a tutti. Non si può più decidere come se non si sapesse.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Rivelazione.
What is happening: Cio che era privato diventa pubblico davanti a tutti. Non si può più decidere come se non si sapesse.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Vie Riaperte

| | |
|---|---|
| famiglia | resolution |
| funzione | return |
| cosa fa | scrive «Le Vie Riaperte» |
| id | `ECH_ROADS_OPEN` |

> Il primo carro che passa senza scorta non fa notizia. E per questo che si capisce che è finita.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Vie Riaperte.
What is happening: Il primo carro che passa senza scorta non fa notizia. E per questo che si capisce che è finita.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Strada Chiusa

| | |
|---|---|
| famiglia | pressure |
| funzione | prohibition |
| cosa fa | Le Vie Interrotte sale di 2, o la domanda che il tavolo ha aperto · un luogo con commercio: resta tagliato fuori |
| id | `ECH_ROAD_CLOSED` |

> Una frana, o qualcuno che l'ha fatta sembrare una frana. Il risultato non cambia: da est non arriva più niente.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Strada Chiusa.
What is happening: Una frana, o qualcuno che l'ha fatta sembrare una frana. Il risultato non cambia: da est non arriva più niente.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Sacrificio

| | |
|---|---|
| famiglia | resolution |
| funzione | sacrifice |
| cosa fa | La Carestia scende di 2, o la domanda che il tavolo ha aperto · Nel mondo: qualcuno ha pagato · chi la cala: la fama |
| id | `ECH_SACRIFICE` |

> Qualcuno paga di persona per chiudere una questione. Funziona, e non viene dimenticato.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Sacrificio.
What is happening: Qualcuno paga di persona per chiudere una questione. Funziona, e non viene dimenticato.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Presa

| | |
|---|---|
| famiglia | turn |
| funzione | conquest |
| cosa fa | scrive «La Capitale Presa» |
| id | `ECH_SEIZURE` |

> Non una battaglia: una mattina in cui le guardie alla porta rispondono a un altro nome.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Presa.
What is happening: Non una battaglia: una mattina in cui le guardie alla porta rispondono a un altro nome.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Interramento

| | |
|---|---|
| famiglia | pressure |
| funzione | lack |
| cosa fa | L'Acqua Ferma sale di 1, o la domanda che il tavolo ha aperto · un luogo con granaio: il raccolto non basta · un luogo con granaio: canale va giu |
| id | `ECH_SILT` |

> Un canale che si chiude non fa rumore. Se ne accorge chi sta in fondo, un anno dopo tutti gli altri.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Interramento.
What is happening: Un canale che si chiude non fa rumore. Se ne accorge chi sta in fondo, un anno dopo tutti gli altri.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### I Chiamati

| | |
|---|---|
| famiglia | turn |
| funzione | transformation |
| cosa fa | I Senza Città sale di 1, o la domanda che il tavolo ha aperto · Nel mondo: il peso e' stato diviso |
| id | `ECH_THE_CALLED_UP` |

> La chiamata gira di casa in casa, e la gente che risponde non torna quella di prima: chi ha impugnato qualcosa una volta lo sa fare per sempre.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: I Chiamati.
What is happening: La chiamata gira di casa in casa, e la gente che risponde non torna quella di prima: chi ha impugnato qualcosa una volta lo sa fare per sempre.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Strada Chiusa a Chiave

| | |
|---|---|
| famiglia | rupture |
| funzione | threat |
| cosa fa | Le Vie Interrotte sale di 2, o la domanda che il tavolo ha aperto · un luogo con commercio: resta tagliato fuori |
| id | `ECH_THE_CLOSED_ROAD` |

> Il pedaggio smette di essere un prezzo e diventa un permesso. Chi non ce l'ha scopre in un pomeriggio quanto era corta la strada.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Strada Chiusa a Chiave.
What is happening: Il pedaggio smette di essere un prezzo e diventa un permesso. Chi non ce l'ha scopre in un pomeriggio quanto era corta la strada.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Copia

| | |
|---|---|
| famiglia | turn |
| funzione | discovery |
| cosa fa | La Reliquia sale di 1, o la domanda che il tavolo ha aperto · La Reliquia adesso e aperta a tutti, o la domanda che il tavolo ha aperto · chi la cala: scoperta: la reliquia |
| id | `ECH_THE_COPY` |

> Salta fuori una copia del registro antico in una casa dove nessuno sa leggerlo. Adesso lo sanno in tre.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Copia.
What is happening: Salta fuori una copia del registro antico in una casa dove nessuno sa leggerlo. Adesso lo sanno in tre.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Crepa

| | |
|---|---|
| famiglia | rupture |
| funzione | threat |
| cosa fa | La Reliquia sale di 2, o la domanda che il tavolo ha aperto · un luogo con miniera: monta il malcontento · un rivale lascia un luogo con miniera |
| id | `ECH_THE_CRACK` |

> Nella galleria bassa si apre una crepa da cui esce aria calda. I Signori della Cenere la puntellano e non lo scrivono da nessuna parte.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Crepa.
What is happening: Nella galleria bassa si apre una crepa da cui esce aria calda. I Signori della Cenere la puntellano e non lo scrivono da nessuna parte.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Stagione Scavata

| | |
|---|---|
| famiglia | resolution |
| funzione | gift |
| cosa fa | L'Acqua Ferma scende di 2, o la domanda che il tavolo ha aperto · un luogo con granaio: vi sorge canale · Nel mondo: l'acqua ha cambiato strada |
| id | `ECH_THE_DUG_SEASON` |

> Due stagioni di braccia, e l'acqua arriva dove arrivava prima. Non è un miracolo: è terra tolta.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Stagione Scavata.
What is happening: Due stagioni di braccia, e l'acqua arriva dove arrivava prima. Non è un miracolo: è terra tolta.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### I Fuochi Fuori

| | |
|---|---|
| famiglia | rupture |
| funzione | separation |
| cosa fa | L'Acqua Ferma sale di 1, o la domanda che il tavolo ha aperto · un luogo con pascolo: si e' svuotato · un luogo con pascolo non e piu di nessuno · la Regione della domanda: adesso e selva maledetta |
| id | `ECH_THE_FIRES_OUTSIDE` |

> Fuori dalle mura i fuochi sono gli stessi di ottobre. Dentro le mura si smette di contarli.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: I Fuochi Fuori.
What is happening: Fuori dalle mura i fuochi sono gli stessi di ottobre. Dentro le mura si smette di contarli.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Debito Rimesso

| | |
|---|---|
| famiglia | resolution |
| funzione | gift |
| cosa fa | Il Debito scende di 2, o la domanda che il tavolo ha aperto · Nel mondo: il debito e' stato perdonato |
| id | `ECH_THE_FORGIVEN_DEBT` |

> Una casa cancella una riga che poteva riscuotere. Non lo fa per bonta': lo fa perche' cosi' quella riga se la ricordano tutti.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Debito Rimesso.
What is happening: Una casa cancella una riga che poteva riscuotere. Non lo fa per bonta': lo fa perche' cosi' quella riga se la ricordano tutti.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Tavolo Lungo

| | |
|---|---|
| famiglia | resolution |
| funzione | reconciliation |
| cosa fa | La Carta scende di 2, o la domanda che il tavolo ha aperto · Il Debito scende di 1, o la domanda che il tavolo ha aperto · Il rapporto chi la cala / un rivale diventa neutral |
| id | `ECH_THE_LONG_TABLE` |

> Si mette un tavolo abbastanza lungo perché ci stiano tutti seduti, e si scopre che era quello il problema.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Tavolo Lungo.
What is happening: Si mette un tavolo abbastanza lungo perché ci stiano tutti seduti, e si scopre che era quello il problema.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### L'Incontro sulla Strada

| | |
|---|---|
| famiglia | turn |
| funzione | encounter |
| cosa fa | Le Vie Interrotte scende di 1, o la domanda che il tavolo ha aperto · Nel mondo: il peso e' stato diviso |
| id | `ECH_THE_MET_ROAD` |

> Due carovane che non dovevano incrociarsi si fermano allo stesso pozzo. Quello che si dicono la' cambia due contratti che erano gia' firmati.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: L'Incontro sulla Strada.
What is happening: Due carovane che non dovevano incrociarsi si fermano allo stesso pozzo. Quello che si dicono la' cambia due contratti che erano gia' firmati.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Conto Vecchio

| | |
|---|---|
| famiglia | resolution |
| funzione | punishment |
| cosa fa | Il Debito scende di 1, o la domanda che il tavolo ha aperto · Nel mondo: il conto e' stato saldato |
| id | `ECH_THE_OLD_ACCOUNT` |

> Si tira fuori un conto di tre generazioni fa e si chiude davanti a tutti. Nessuno discute la cifra: discutono di essersela dimenticata.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Conto Vecchio.
What is happening: Si tira fuori un conto di tre generazioni fa e si chiude davanti a tutti. Nessuno discute la cifra: discutono di essersela dimenticata.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Quello che c'Era

| | |
|---|---|
| famiglia | turn |
| funzione | revelation |
| cosa fa | La Successione adesso e aperta a tutti, o la domanda che il tavolo ha aperto · Nel mondo: quello che si e' saputo lo sanno tutti |
| id | `ECH_THE_ONE_WHO_SAW` |

> Si presenta uno che c'era, e lo dice ad alta voce. Da quel momento la versione comoda ha un nome contro, e il nome e' di qualcuno che si puo' andare a cercare.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Quello che c'Era.
What is happening: Si presenta uno che c'era, e lo dice ad alta voce. Da quel momento la versione comoda ha un nome contro, e il nome e' di qualcuno che si puo' andare a cercare.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Prezzo del Sale

| | |
|---|---|
| famiglia | pressure |
| funzione | temptation |
| cosa fa | Le Vie Interrotte sale di 1, o la domanda che il tavolo ha aperto · un luogo con commercio: e' pieno di debiti |
| id | `ECH_THE_PRICE_OF_SALT` |

> Il sale costa quanto decide chi lo vende, e quest'anno lo decide una casa sola. Nessuno rifiuta, e tutti se lo segnano.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Prezzo del Sale.
What is happening: Il sale costa quanto decide chi lo vende, e quest'anno lo decide una casa sola. Nessuno rifiuta, e tutti se lo segnano.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Il Pozzo Zitto

| | |
|---|---|
| famiglia | turn |
| funzione | return |
| cosa fa | La Cenere che Sale scende di 1, o la domanda che il tavolo ha aperto · La Reliquia sale di 1, o la domanda che il tavolo ha aperto · chi la cala mette una presenza in un luogo con miniera |
| id | `ECH_THE_QUIET_SHAFT` |

> La crepa smette di soffiare da sola. I Signori della Cenere tornano a scendere, e stavolta lo scrivono.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Il Pozzo Zitto.
What is happening: La crepa smette di soffiare da sola. I Signori della Cenere tornano a scendere, e stavolta lo scrivono.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### L'Anno Corto

| | |
|---|---|
| famiglia | turn |
| funzione | transformation |
| cosa fa | L'Acqua Ferma sale di 2, o la domanda che il tavolo ha aperto · Il Debito sale di 1, o la domanda che il tavolo ha aperto · un luogo con granaio: si muore di fame |
| id | `ECH_THE_SHORT_YEAR` |

> Il fiume arriva sei settimane in ritardo e riparte in anticipo. Nessuno lo chiama siccita: si dice che è stato un anno corto.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: L'Anno Corto.
What is happening: Il fiume arriva sei settimane in ritardo e riparte in anticipo. Nessuno lo chiama siccita: si dice che è stato un anno corto.
Dominant accent: bianco freddo, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### L'Anno a Piedi

| | |
|---|---|
| famiglia | rupture |
| funzione | separation |
| cosa fa | I Pozzi Bassi sale di 1, o la domanda che il tavolo ha aperto · un luogo con pascolo: si e' svuotato |
| id | `ECH_THE_WALKING_YEAR` |

> Un anno intero passa camminando. Le strade si imparano a memoria, e i campi che si lasciano smettono di riconoscere qualcuno.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: L'Anno a Piedi.
What is happening: Un anno intero passa camminando. Le strade si imparano a memoria, e i campi che si lasciano smettono di riconoscere qualcuno.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Due Sentenze

| | |
|---|---|
| famiglia | rupture |
| funzione | violation |
| convoca un Consiglio | su La Carta |
| cosa fa | La Carta sale di 2, o la domanda che il tavolo ha aperto · un luogo con capitale: e' conteso · apre subito un Consiglio su La Carta |
| id | `ECH_TWO_VERDICTS` |

> Lo stesso caso, due città, due sentenze opposte. Entrambe applicate, entrambe legittime.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Due Sentenze.
What is happening: Lo stesso caso, due città, due sentenze opposte. Entrambe applicate, entrambe legittime.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Usurpazione

| | |
|---|---|
| famiglia | rupture |
| funzione | usurpation |
| convoca un Consiglio | su La Successione |
| cosa fa | scrive «La Corona Divisa» · La Successione sale di 1, o la domanda che il tavolo ha aperto · apre subito un Consiglio su La Successione |
| id | `ECH_USURPATION` |

> Qualcuno si siede dove non gli spetta, e scopre che nessuno si alza per protestare.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Usurpazione.
What is happening: Qualcuno si siede dove non gli spetta, e scopre che nessuno si alza per protestare.
Dominant accent: rosso scuro, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### La Veglia Spostata

| | |
|---|---|
| famiglia | pressure |
| funzione | omen |
| cosa fa | La Reliquia sale di 1, o la domanda che il tavolo ha aperto · chi la cala mette una presenza in la Regione della domanda |
| id | `ECH_VIGIL_MOVED` |

> L'Ordine cambia l'ora delle veglie e non lo annuncia. Chi abita vicino conta le campane.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: La Veglia Spostata.
What is happening: L'Ordine cambia l'ora delle veglie e non lo annuncia. Chi abita vicino conta le campane.
Dominant accent: grigio-ocra, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

### Messo per Iscritto

| | |
|---|---|
| famiglia | resolution |
| funzione | liberation |
| cosa fa | La Carta scende di 1, o la domanda che il tavolo ha aperto · Nel mondo: la Carta vale per un tempo solo · chi la cala: la fama |
| id | `ECH_WRITTEN_DOWN` |

> Non si risolve niente: si scrive. E qualche anno dopo si scopre che scrivere era risolvere.

<details><summary>Prompt per l'immagine</summary>

```
ECHOES — Echo card. A narrative moment: Messo per Iscritto.
What is happening: Non si risolve niente: si scrive. E qualche anno dopo si scopre che scrivere era risolvere.
Dominant accent: oro caldo basso, over the game's muted earth palette.
The image shows a turning point, not an action climax: the instant before or the
instant after. Human scale, few figures, strong silhouette reading at small size.
Composition: negative space along the top edge reserved for a title overlay; the
focal event sits at the lower-left third. Vertical card framing, 2:3. No text, no
letters, no numerals, no frame, no border. Not gory.
```

</details>

---

## I pezzi sulla mappa

Quello che va fabbricato per far vedere il mondo. La **forma** e' quella
che l'app disegna gia': un pezzo di cartone che le somiglia si riconosce
senza leggere niente, ed e' lo scopo.

### Le pietre: quello che si costruisce

Ogni pietra sale di grado invece di essere sostituita: **un pezzo per
grado**, cosi' al tavolo si vede crescere. Quelle con un padrone vanno nel
colore di chi le tiene — servono in tutti i colori dei seggi.

| pietra | forma | gradi | di chi e' | rovina |
|---|---|---|---|---|
| Archivio | studio | Archivio → La Grande Biblioteca | di una casa | L'Archivio Bruciato |
| Canale | opera | Canale → La Grande Opera d'Acqua | di una casa | L'Insabbiamento |
| Foresta | luogo | Foresta → Bosco diradato → Selva maledetta | di nessuno | La Radura Spoglia |
| Granaio | opera | Granaio → Il Grande Granaio | di una casa | Il Granaio Vuoto |
| Presidio | presidio | Torre di veglia → Castello → Reggia | di una casa | Rovina |
| Sito antico | luogo | Sito dormiente → Sito aperto → Sito saccheggiato | di nessuno | Il Vuoto sotto la Pietra |
| Passo | luogo | Passo aperto → Passo franato | di nessuno | La Via Dimenticata |
| Insediamento | insediamento | Villaggio → Borgo → Città | di una casa | Abbandono |
| Sorgente | luogo | Sorgente viva → Sorgente bassa → Sorgente secca | di nessuno | Il Sasso Asciutto |
| Pedaggio | opera | Pedaggio → La Dogana | di una casa | La Sbarra Rotta |

### Le condizioni: quello che succede a una Regione

Vanno e vengono. Un segnalino piatto da posare sulla Regione, e uno solo
per tipo basta se non capitano due volte insieme — ma **una Regione puo'
portarne piu' d'una**, quindi conviene averne qualcuna di scorta.

| segnalino | segno |
|---|---|
| abbandonata | `condition:abandoned` |
| contesa | `condition:contested` |
| tagliata fuori | `condition:cut_off` |
| svuotata | `condition:emptied` |
| sfruttata | `condition:exploited` |
| sorvegliata | `condition:guarded` |
| indebitata | `condition:indebted` |
| magra | `condition:lean` |
| in lutto | `condition:mourning` |
| depredata | `condition:plundered` |
| razionata | `condition:rationed` |
| requisita | `condition:requisitioned` |
| affamata | `condition:starving` |
| inquieta | `condition:unrest` |

### Le cicatrici: quello che non viene piu' via

Una cicatrice **resta**, e attraversa le ere: si posa e non si toglie piu'.
Conviene che si distingua a colpo d'occhio da una condizione, perche' la
differenza fra «adesso» e «per sempre» e' tutta qui.

| cicatrice | segno |
|---|---|
| l'abbandono | `scar:abandoned` |
| il ponte rotto | `scar:broken_bridge` |
| la parola rotta | `scar:broken_word` |
| i registri bruciati | `scar:burned_records` |
| passata di mano | `scar:changed_hands` |
| il sigillo diviso | `scar:divided_seal` |
| la caduta del drago | `scar:dragonfall` |
| lo sgombero | `scar:emptied` |
| la ferita aperta | `scar:open_wound` |
| la razzia | `scar:plundered` |
| il confine sigillato | `scar:sealed_border` |
| il seggio vuoto | `scar:the_empty_chair` |
| la domanda sul muro | `scar:unanswered` |

### Le pedine e i vessilli: di chi e' cosa

| pezzo | quanti |
|---|---|
| pedina di presenza | **5 per casa**, in 8 colori = 40 |
| vessillo del padrone | uno per Regione, in tutti e 8 i colori |
| segnalino di domanda | uno per ognuna delle 60 domande |

Le case della scatola sono 8 e a un tavolo ne siedono quattro: i colori
servono tutti, perche' quali quattro lo decide l'anno.

---

*96 carte e 65 pezzi diversi da fare.*
