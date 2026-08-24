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

> Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: vietare una cosa a tutti alza la posta per tutti.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Interdetto — Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: vietare una cosa a tutti alza la posta per tutti.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il tuo rivale entra dove si discute |
| id | `AST_AUTHORITY_SUCCESSION_ACT` |

> Forza 3. Si scarta sempre, e chi ti sta di fronte guadagna una presenza nella Regione di cui si discute: nominare un erede fa arrivare tutti quelli che non sono stati nominati.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Atto di Successione — Forza 3. Si scarta sempre, e chi ti sta di fronte guadagna una presenza nella Regione di cui si discute: nominare un erede fa arrivare tutti quelli che non sono stati nominati.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa contesa |
| id | `AST_AUTHORITY_CROWN_RIGHT` |

> Si scarta sempre: un diritto invocato due volte non è più un diritto, è una pretesa — e la pretesa divide: la Regione della domanda resta contesa.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Diritto di Corona — Si scarta sempre: un diritto invocato due volte non è più un diritto, è una pretesa — e la pretesa divide: la Regione della domanda resta contesa.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' la domanda sul muro |
| id | `AST_AUTHORITY_MAGISTRATE` |

> +2 sul fronte Oppose. Se la proposta passa lo stesso resta in mano: un giudice che ha avuto ragione serve ancora — e il giudice risponde: la domanda rimasta scritta sul muro si cancella.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Magistrato — +2 sul fronte Oppose. Se la proposta passa lo stesso resta in mano: un giudice che ha avuto ragione serve ancora — e il giudice risponde: la domanda rimasta scritta sul muro si cancella.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' contesa |
| id | `AST_AUTHORITY_CENSUS` |

> +1 quando AUTHORITY è rilevante per la Tensione. Una lista di nomi è la forma più semplice del potere — e la lista chiarisce: la Regione della domanda smette di essere contesa.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Censimento — +1 quando AUTHORITY è rilevante per la Tensione. Una lista di nomi è la forma più semplice del potere — e la lista chiarisce: la Regione della domanda smette di essere contesa.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' inquieta |
| id | `AST_AUTHORITY_EDICT` |

> Una riga scritta bene vale quanto chi la fa rispettare — e dove si discute, la legge calma la piazza: l'inquietudine si cancella.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Editto — Una riga scritta bene vale quanto chi la fa rispettare — e dove si discute, la legge calma la piazza: l'inquietudine si cancella.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> +1 sempre, su qualsiasi fronte. Si scarta sempre: si concede una volta sola, e tutti se ne ricordano — perché la nomina scrive un nome nella linea: il mondo ricorda l'erede nominato.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Investitura — +1 sempre, su qualsiasi fronte. Si scarta sempre: si concede una volta sola, e tutti se ne ricordano — perché la nomina scrive un nome nella linea: il mondo ricorda l'erede nominato.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda in gioco sale |
| id | `AST_AUTHORITY_SEAL` |

> +1 sul fronte Oppose. Il sigillo che manca ferma più cose del sigillo che c'è — e quello impegnato raffredda la questione: la Tensione in gioco scende di 1.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Sigillo — +1 sul fronte Oppose. Il sigillo che manca ferma più cose del sigillo che c'è — e quello impegnato raffredda la questione: la Tensione in gioco scende di 1.
Painterly oil technique, visible brushwork, muted earth palette with a single
oro spento accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: rompere un patto davanti al tavolo scalda ogni domanda ancora aperta.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Patto Rotto — Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: rompere un patto davanti al tavolo scalda ogni domanda ancora aperta.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il tuo rivale entra dove si discute |
| id | `AST_BONDS_HOSTAGE` |

> Forza 3. Si scarta sempre, e chi ti sta di fronte guadagna una presenza nella Regione di cui si discute: chi consegna un figlio compra una parola, e la paga a casa propria.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Ostaggio — Forza 3. Si scarta sempre, e chi ti sta di fronte guadagna una presenza nella Regione di cui si discute: chi consegna un figlio compra una parola, e la paga a casa propria.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il rapporto con chi tocca cambia di un passo |
| id | `AST_BONDS_BETROTHAL` |

> +2 sul fronte Oppose: una promessa serve più a impedire un'alleanza che a farne una. Si scarta sempre — e resta scritta: fra le due case nasce un patto, e i patti si giudicano.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Promessa di Nozze — +2 sul fronte Oppose: una promessa serve più a impedire un'alleanza che a farne una. Si scarta sempre — e resta scritta: fra le due case nasce un patto, e i patti si giudicano.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il rapporto con chi tocca cambia di un passo |
| id | `AST_BONDS_BLOOD_TIE` |

> Non è un accordo: e una cosa che c'era prima dell'accordo, e che nessuno ha firmato. Impegnata, scrive il vincolo di sangue sulla coppia: da lì in poi, quella relazione non scende sotto il neutrale.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Legame di Sangue — Non è un accordo: e una cosa che c'era prima dell'accordo, e che nessuno ha firmato. Impegnata, scrive il vincolo di sangue sulla coppia: da lì in poi, quella relazione non scende sotto il neutrale.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il rapporto con chi tocca cambia di un passo |
| id | `AST_BONDS_FAVOR` |

> Piccolo, ricordato con precisione — e restituito al momento giusto: fra chi lo impegna e il rivale, una vendetta si spegne.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Favore — Piccolo, ricordato con precisione — e restituito al momento giusto: fra chi lo impegna e il rivale, una vendetta si spegne.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | una casa perde un segno che portava addosso |
| id | `AST_BONDS_GUEST_RIGHT` |

> +1 quando BONDS è rilevante per la Tensione. Chi ha mangiato al tuo tavolo non può dire di no davanti a tutti. Può dirlo dopo — e chi lo impegna torna ospite: la cacciata dalla Regione della domanda si cancella.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Diritto di Ospitalità — +1 quando BONDS è rilevante per la Tensione. Chi ha mangiato al tuo tavolo non può dire di no davanti a tutti. Può dirlo dopo — e chi lo impegna torna ospite: la cacciata dalla Regione della domanda si cancella.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il rapporto con chi tocca cambia di un passo |
| id | `AST_BONDS_OATH` |

> Non si scarta mai. Un giuramento impegnato resta impegnato anche dopo, ed è la sua unica forza — e un giuramento rifatto scioglie quello spezzato: fra chi lo impegna e il rivale, il tradimento si cancella.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Giuramento — Non si scarta mai. Un giuramento impegnato resta impegnato anche dopo, ed è la sua unica forza — e un giuramento rifatto scioglie quello spezzato: fra chi lo impegna e il rivale, il tradimento si cancella.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa indebitata |
| id | `AST_BONDS_OLD_DEBT` |

> +1 sul fronte Oppose. Nessuno se lo ricorda tranne le due persone che contano, e una delle due lo tira fuori adesso — e da adesso è pubblico: la sede del debitore resta segnata come indebitata.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Debito Vecchio — +1 sul fronte Oppose. Nessuno se lo ricorda tranne le due persone che contano, e una delle due lo tira fuori adesso — e da adesso è pubblico: la sede del debitore resta segnata come indebitata.
Painterly oil technique, visible brushwork, muted earth palette with a single
porpora tenue accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | perdi la tua presenza dove si discute |
| id | `AST_FORCE_BURNED_GATE` |

> Forza 3. Si scarta sempre, e chi la gioca perde la propria presenza nella Regione di cui si discute: chi apre una porta così non resta li a difenderla.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Le Porte Bruciate — Forza 3. Si scarta sempre, e chi la gioca perde la propria presenza nella Regione di cui si discute: chi apre una porta così non resta li a difenderla.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: richiamare i vecchi reggimenti dice al mondo che la cosa è seria.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Il Vecchio Esercito — Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: richiamare i vecchi reggimenti dice al mondo che la cosa è seria.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda in gioco sale, viene giu' una costruzione dove si discute |
| id | `AST_FORCE_SIEGE` |

> +2 sul fronte Oppose. Non serve prendere una cosa per impedire che sia di qualcun altro — ma l'assedio affama anche la terra intorno: la Carestia sale di 1, e il presidio della Regione della domanda viene giu'.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Assedio — +2 sul fronte Oppose. Non serve prendere una cosa per impedire che sia di qualcun altro — ma l'assedio affama anche la terra intorno: la Carestia sale di 1, e il presidio della Regione della domanda viene giu'.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> Si scarta sempre, e la Tensione in gioco sale di 1: la paura non si spegne insieme alla questione.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Banda Armata — Si scarta sempre, e la Tensione in gioco sale di 1: la paura non si spegne insieme alla questione.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda in gioco sale |
| id | `AST_FORCE_BORDER_WATCH` |

> +1 quando FORCE è rilevante per la Tensione. Contano i carri che passano, e sanno quali contare — e ogni conta ferma la strada: Le Vie Interrotte salgono di 1.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Guardia di Confine — +1 quando FORCE è rilevante per la Tensione. Contano i carri che passano, e sanno quali contare — e ogni conta ferma la strada: Le Vie Interrotte salgono di 1.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda in gioco sale |
| id | `AST_FORCE_LEVY` |

> Uomini con attrezzi da lavoro tenuti come lance. Bastano finché nessuno li conta — ma i campi restano soli: la Carestia sale di 1.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Leva Contadina — Uomini con attrezzi da lavoro tenuti come lance. Bastano finché nessuno li conta — ma i campi restano soli: la Carestia sale di 1.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa inquieta |
| id | `AST_FORCE_MERCENARIES` |

> +1 sempre, su qualsiasi fronte: fuori tema vale quanto in tema. Dove passano, però, resta l'inquietudine.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Mercenari — +1 sempre, su qualsiasi fronte: fuori tema vale quanto in tema. Dove passano, però, resta l'inquietudine.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa tagliata fuori |
| id | `AST_FORCE_ROADBLOCK` |

> +1 sul fronte Oppose. Fermare un carro costa sempre meno che farlo partire — e la Regione della domanda resta tagliata fuori dal mondo.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Posto di Blocco — +1 sul fronte Oppose. Fermare un carro costa sempre meno che farlo partire — e la Regione della domanda resta tagliata fuori dal mondo.
Painterly oil technique, visible brushwork, muted earth palette with a single
rosso ossido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda si apre a tutti |
| id | `AST_KNOWLEDGE_RED_CRYSTAL` |

> Forza 3. Si scarta sempre, e la Tensione in gioco diventa aperta a tutti: mostrarlo chiude ogni dubbio e apre la domanda a chiunque fosse nella stanza.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Il Cristallo Rosso — Forza 3. Si scarta sempre, e la Tensione in gioco diventa aperta a tutti: mostrarlo chiude ogni dubbio e apre la domanda a chiunque fosse nella stanza.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: quello che era scritto per un solo lettore adesso lo hanno sentito tutti.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Deposizione Sigillata — Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: quello che era scritto per un solo lettore adesso lo hanno sentito tutti.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda si apre a tutti |
| id | `AST_KNOWLEDGE_PROOF` |

> Se la proposta passa, resta in mano: una prova dimostrata non si consuma — e dimostra: la questione in gioco si apre a tutti i presenti.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Prova — Se la proposta passa, resta in mano: una prova dimostrata non si consuma — e dimostra: la questione in gioco si apre a tutti i presenti.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa inquieta |
| id | `AST_KNOWLEDGE_WITNESS` |

> +2 sul fronte Oppose. Si scarta sempre: un testimone si spende una volta sola — e la deposizione agita la casa accusata: la sua sede resta inquieta.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Testimone — +2 sul fronte Oppose. Si scarta sempre: un testimone si spende una volta sola — e la deposizione agita la casa accusata: la sua sede resta inquieta.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | si alza una costruzione dove si discute |
| id | `AST_KNOWLEDGE_ARCHIVE` |

> Se la proposta passa resta in mano. Le carte non si consumano: si consuma chi le sa leggere — e quello che si e' letto resta: sulla Regione della domanda si apre un archivio suo.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Archivio — Se la proposta passa resta in mano. Le carte non si consumano: si consuma chi le sa leggere — e quello che si e' letto resta: sulla Regione della domanda si apre un archivio suo.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> +1 sul fronte Oppose. Chi tiene i conti sa cosa manca, e lo dice nel momento peggiore — e da quel momento i conti sono di tutti: il registro è pubblico.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Registro — +1 sul fronte Oppose. Chi tiene i conti sa cosa manca, e lo dice nel momento peggiore — e da quel momento i conti sono di tutti: il registro è pubblico.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' il ponte rotto |
| id | `AST_KNOWLEDGE_OLD_MAP` |

> +1 quando KNOWLEDGE è rilevante per la Tensione. I confini sono sbagliati; le strade no — e una strada giusta ricuce il ponte rotto sulla Regione della domanda.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Mappa Vecchia — +1 quando KNOWLEDGE è rilevante per la Tensione. I confini sono sbagliati; le strade no — e una strada giusta ricuce il ponte rotto sulla Regione della domanda.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda si apre a tutti |
| id | `AST_KNOWLEDGE_RUMOR` |

> Non è vera. Non è ancora falsa — e finché gira, la questione in gioco torna velata: i numeri si nascondono dietro le voci.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Voce di Corridoio — Non è vera. Non è ancora falsa — e finché gira, la questione in gioco torna velata: i numeri si nascondono dietro le voci.
Painterly oil technique, visible brushwork, muted earth palette with a single
verde-azzurro pallido accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | perdi la tua presenza dove si discute |
| id | `AST_PEOPLE_EXODUS` |

> Forza 3. Si scarta sempre, e chi la gioca perde la propria presenza nella Regione di cui si discute: chi parte non torna al tavolo.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Esodo — Forza 3. Si scarta sempre, e chi la gioca perde la propria presenza nella Regione di cui si discute: chi parte non torna al tavolo.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: un paese che si ferma non si rimette in moto dove l'avevi lasciato.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Braccia Ferme — Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: un paese che si ferma non si rimette in moto dove l'avevi lasciato.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> +2 sul fronte Oppose: è più facile fermare qualcosa in molti che costruirla. Si scarta sempre — e la piazza resta calda: la Tensione in gioco sale di 1.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Mobilitazione — +2 sul fronte Oppose: è più facile fermare qualcosa in molti che costruirla. Si scarta sempre — e la piazza resta calda: la Tensione in gioco sale di 1.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il rapporto con chi tocca cambia di un passo |
| id | `AST_PEOPLE_SPOKESMAN` |

> Qualcuno che dice ad alta voce quello che già pensano in molti, e che dopo non può più tornare indietro — la parola detta è una promessa fra le due case.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Portavoce — Qualcuno che dice ad alta voce quello che già pensano in molti, e che dopo non può più tornare indietro — la parola detta è una promessa fra le due case.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa inquieta |
| id | `AST_PEOPLE_CROWD` |

> Nessuno l'ha convocata. È arrivata lo stesso — in capitale: e la capitale resta inquieta.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Folla — Nessuno l'ha convocata. È arrivata lo stesso — in capitale: e la capitale resta inquieta.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' in lutto |
| id | `AST_PEOPLE_ELDERS` |

> +1 sul fronte Oppose. Parlano piano, dicono di no, e vengono ripetuti per tre villaggi — e sanno accompagnare: il lutto della Regione della domanda si elabora.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Consiglio degli Anziani — +1 sul fronte Oppose. Parlano piano, dicono di no, e vengono ripetuti per tre villaggi — e sanno accompagnare: il lutto della Regione della domanda si elabora.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' affamata |
| id | `AST_PEOPLE_HARVEST_HANDS` |

> +1 quando PEOPLE è rilevante per la Tensione. Non sono un esercito: ma senza di loro non si mangia — e dove arrivano, la fame della Regione della domanda si spegne.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Braccia per il Raccolto — +1 quando PEOPLE è rilevante per la Tensione. Non sono un esercito: ma senza di loro non si mangia — e dove arrivano, la fame della Regione della domanda si spegne.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' razionata |
| id | `AST_PEOPLE_MARCH` |

> Poca gente, ma in strada e alla stessa ora. Il punto non è quanti sono: è che si sono trovati — e le razioni imposte sulla Regione della domanda si rompono.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Marcia — Poca gente, ma in strada e alla stessa ora. Il punto non è quanti sono: è che si sono trovati — e le razioni imposte sulla Regione della domanda si rompono.
Painterly oil technique, visible brushwork, muted earth palette with a single
terracotta accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | il tuo rivale entra dove si discute |
| id | `AST_WEALTH_LAND_MORTGAGE` |

> Forza 3. Si scarta sempre, e chi ti sta di fronte guadagna una presenza nella Regione di cui si discute: impegnare una terra fa arrivare chi la vuole.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Ipoteca sulle Terre — Forza 3. Si scarta sempre, e chi ti sta di fronte guadagna una presenza nella Regione di cui si discute: impegnare una terra fa arrivare chi la vuole.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: aprire il tesoro dice a tutti quanto vale davvero la questione.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Il Tesoro — Forza 3. Si scarta sempre, e la Tensione in gioco sale di 1: aprire il tesoro dice a tutti quanto vale davvero la questione.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' tagliata fuori |
| id | `AST_WEALTH_CARAVAN` |

> Si scarta sempre: una carovana spesa è una carovana partita — e una carovana che parte riapre la via: la Regione tagliata fuori si ricollega.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Carovana — Si scarta sempre: una carovana spesa è una carovana partita — e una carovana che parte riapre la via: la Regione tagliata fuori si ricollega.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa diventa razionata |
| id | `AST_WEALTH_GRANARY_KEYS` |

> +2 sul fronte Oppose. Non possiedi il grano: possiedi la serratura — e la serratura raziona: sulla Regione della domanda resta il segno della razione.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Chiavi del Granaio — +2 sul fronte Oppose. Non possiedi il grano: possiedi la serratura — e la serratura raziona: sulla Regione della domanda resta il segno della razione.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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

> +1 sempre, su qualsiasi fronte. Vale nel momento in cui lo chiedi, e non un minuto dopo — perché chiederlo chiama tutti i debiti: il mondo ricorda che il debito fu chiamato.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Credito — +1 sempre, su qualsiasi fronte. Vale nel momento in cui lo chiedi, e non un minuto dopo — perché chiederlo chiama tutti i debiti: il mondo ricorda che il debito fu chiamato.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la domanda in gioco sale |
| id | `AST_WEALTH_GRAIN` |

> Conta più di un titolo, per il tempo in cui dura — e dura quanto basta: la Carestia scende di 1.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Riserva di Grano — Conta più di un titolo, per il tempo in cui dura — e dura quanto basta: la Carestia scende di 1.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | la Regione discussa non e' piu' magra |
| id | `AST_WEALTH_SALT` |

> +1 quando WEALTH è rilevante per la Tensione. Non nutre nessuno: senza, quello che nutre non arriva — e dove arriva, la magra si supera.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Sale — +1 quando WEALTH è rilevante per la Tensione. Non nutre nessuno: senza, quello che nutre non arriva — e dove arriva, la magra si supera.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa lascia | si alza una costruzione dove si discute |
| id | `AST_WEALTH_TOLL` |

> +1 sul fronte Oppose. Una corda tesa fra due pali, e il diritto di non alzarla — e il diritto si scrive: sulla Regione della domanda resta il pedaggio.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting, single evocative scene depicting Pedaggio — +1 sul fronte Oppose. Una corda tesa fra due pali, e il diritto di non alzarla — e il diritto si scrive: sulla Regione della domanda resta il pedaggio.
Painterly oil technique, visible brushwork, muted earth palette with a single
ambra accent. Low side lighting, late afternoon or candlelit interior.
Grounded medieval-adjacent world, no heraldry invented, no glowing magic.
A scene, not a portrait: figures may show their faces, but never a single centred
figure looking at the viewer - that framing belongs to the House cards.
Composition: subject occupies the upper two thirds; the lower third is a calm,
low-detail area (ground, mist, cloth, stone) reserved for a text overlay.
Vertical card framing, 2:3. No text, no letters, no numerals, no logos, no frame,
no border. Not gory, not horror. Museum-quality illustration, boardgame card art.
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
| cosa fa | scrive «L'Ordine Rimesso in Piedi» · Nel mondo: amnesty granted |
| id | `ECH_AMNESTY` |

> Si decide di non contare più chi aveva giurato a chi. Non tutti sono d'accordo, e nessuno lo dice.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Amnistia — Si decide di non contare più chi aveva giurato a chi. Non tutti sono d'accordo, e nessuno lo dice. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Tradimento

| | |
|---|---|
| famiglia | rupture |
| funzione | betrayal |
| convoca un Consiglio | su La Carestia |
| cosa fa | Nel mondo: betrayal spoken · La Carestia sale di 1 · apre subito un Consiglio su La Carestia |
| id | `ECH_BETRAYAL` |

> Un accordo viene rotto da chi lo aveva proposto. Il danno non è la rottura: è che ora tutti ricalcolano.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Tradimento — Un accordo viene rotto da chi lo aveva proposto. Il danno non è la rottura: è che ora tutti ricalcolano. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Chiamata

| | |
|---|---|
| famiglia | pressure |
| funzione | request |
| convoca un Consiglio | su Il Debito |
| cosa fa | Il Debito sale di 1 · Strada dei Mercanti: e' pieno di debiti · apre subito un Consiglio su Il Debito |
| id | `ECH_CALL_OF_ACCOUNTS` |

> La Gilda scrive a tre città lo stesso giorno. Non chiede di pagare: chiede di confermare la cifra.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Chiamata — La Gilda scrive a tre città lo stesso giorno. Non chiede di pagare: chiede di confermare la cifra. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: Carovana Perduta — Undici carri partiti, nessuno arrivato, e nessun corpo trovato. È la parte senza corpi che spaventa. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: Chi Siede — Un nome viene detto e non viene contestato. Non è giustizia: è che tutti sono stanchi. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Scoperta

| | |
|---|---|
| famiglia | turn |
| funzione | discovery |
| cosa fa | Il Risveglio adesso e aperta a tutti · Nel mondo: crystal measured · chi la cala: una Scoperta (the measure) |
| id | `ECH_DISCOVERY` |

> Qualcosa di nascosto viene misurato. Da questo momento la questione ha dei numeri, e i numeri si discutono.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Scoperta — Qualcosa di nascosto viene misurato. Da questo momento la questione ha dei numeri, e i numeri si discutono. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Sedia Vuota

| | |
|---|---|
| famiglia | pressure |
| funzione | threat |
| convoca un Consiglio | su La Successione |
| cosa fa | La Successione sale di 2 · Eredan: e' conteso · apre subito un Consiglio su La Successione |
| id | `ECH_EMPTY_THRONE` |

> Il re manca a un consiglio. Poi a un secondo. Alla terza volta la stanza ha smesso di aspettarlo.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Sedia Vuota — Il re manca a un consiglio. Poi a un secondo. Alla terza volta la stanza ha smesso di aspettarlo. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Partenza

| | |
|---|---|
| famiglia | rupture |
| funzione | separation |
| cosa fa | scrive «La Partenza» · La Carestia sale di 1 · la Regione della domanda: adesso e selva maledetta |
| id | `ECH_EXODUS` |

> Le carriole partono di notte per non dover salutare nessuno. Al mattino mancano tre famiglie su dieci.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Partenza — Le carriole partono di notte per non dover salutare nessuno. Al mattino mancano tre famiglie su dieci. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: Annata Buona — Piove quando serve e smette quando serve. Non risolve niente, ma sposta la domanda di un anno. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Mancanza

| | |
|---|---|
| famiglia | pressure |
| funzione | lack |
| cosa fa | La Carestia sale di 1 · Valle Verde: il raccolto non basta · Valle Verde: granaio va giu |
| id | `ECH_LACK` |

> Qualcosa che c'era non c'è più, e la sua assenza comincia a organizzare le giornate di tutti.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Mancanza — Qualcosa che c'era non c'è più, e la sua assenza comincia a organizzare le giornate di tutti. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Il Giuramento che Nessuno Sciolse

| | |
|---|---|
| famiglia | memoria |
| funzione | betrayal |
| convoca un Consiglio | su La Successione |
| cosa fa | La Successione sale di 1 · apre subito un Consiglio su La Successione |
| id | `ECH_LEGEND_BROKEN_OATH` |

> Qualcuno ripete a voce alta il giuramento che fu rotto, coi nomi di chi c'era. Le case contano da quanti anni nessuno lo nomina, e la conta non torna a nessuno.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Il Giuramento che Nessuno Sciolse — Qualcuno ripete a voce alta il giuramento che fu rotto, coi nomi di chi c'era. Le case contano da quanti anni nessuno lo nomina, e la conta non torna a nessuno. Painterly oil
technique, muted earth palette, l'accento della sua famiglia accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Il Giorno che la Gilda Chiese Tutto

| | |
|---|---|
| famiglia | memoria |
| funzione | threat |
| convoca un Consiglio | su Il Debito |
| cosa fa | Il Debito sale di 1 · Strada dei Mercanti: e' pieno di debiti · apre subito un Consiglio su Il Debito |
| id | `ECH_LEGEND_CALLED_DAY` |

> La storia si racconta a ogni firma: una Gilda morta da secoli che un mattino chiese tutto insieme. Il debito di adesso comincia a pesare come quello antico.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Il Giorno che la Gilda Chiese Tutto — La storia si racconta a ogni firma: una Gilda morta da secoli che un mattino chiese tutto insieme. Il debito di adesso comincia a pesare come quello antico. Painterly oil
technique, muted earth palette, l'accento della sua famiglia accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Ballata dell'Anno Buono

| | |
|---|---|
| famiglia | memoria |
| funzione | return |
| cosa fa | La Successione scende di 1 · Eredan: il malcontento si e' spento |
| id | `ECH_LEGEND_GOOD_YEAR` |

> Un cantastorie riporta in giro la ballata dell'anno in cui l'ordine torno davvero. Nessuno dei presenti c'era, e tutti giurano di ricordarselo.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Ballata dell'Anno Buono — Un cantastorie riporta in giro la ballata dell'anno in cui l'ordine torno davvero. Nessuno dei presenti c'era, e tutti giurano di ricordarselo. Painterly oil
technique, muted earth palette, l'accento della sua famiglia accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Perdita

| | |
|---|---|
| famiglia | rupture |
| funzione | loss |
| cosa fa | La Carestia sale di 1 · Terre Nahr: e' in lutto · un rivale lascia Terre Nahr |
| id | `ECH_LOSS` |

> Qualcuno non c'è più, e la sua parte di lavoro resta scoperta.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Perdita — Qualcuno non c'è più, e la sua parte di lavoro resta scoperta. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: La Parola Data — La cosa che era stata proibita viene fatta, e viene fatta da chi l'aveva proibita. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: Giuramento Prestato — Due che si contavano come nemici mettono per iscritto una cosa sola, e quella regge. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### L'Offerta

| | |
|---|---|
| famiglia | pressure |
| funzione | temptation |
| cosa fa | tension sale di 1 · la Regione della domanda: e' pieno di debiti · chi la cala mette una presenza in la Regione della domanda |
| id | `ECH_OFFER` |

> Qualcuno propone una scorciatoia che funziona davvero. E il fatto che funzioni il problema.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: L'Offerta — Qualcuno propone una scorciatoia che funziona davvero. E il fatto che funzioni il problema. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Presagio

| | |
|---|---|
| famiglia | pressure |
| funzione | omen |
| cosa fa | Il Risveglio sale di 1 · chi la cala: una Scoperta (the omen) |
| id | `ECH_OMEN` |

> Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare del tutto.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Presagio — Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare del tutto. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### L'Incontro

| | |
|---|---|
| famiglia | turn |
| funzione | encounter |
| cosa fa | Nel mondo: parley held · tension scende di 1 |
| id | `ECH_PARLEY` |

> Due che non si parlavano si trovano nello stesso posto senza averlo deciso, e devono dirsi qualcosa.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: L'Incontro — Due che non si parlavano si trovano nello stesso posto senza averlo deciso, e devono dirsi qualcosa. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Supplica

| | |
|---|---|
| famiglia | pressure |
| funzione | request |
| convoca un Consiglio | su La Carestia |
| cosa fa | tension sale di 1 · Nel mondo: petition heard · apre subito un Consiglio su La Carestia |
| id | `ECH_PETITION` |

> Arrivano a chiedere, e lo fanno in pubblico. Dire di no adesso costa più di quanto costava ieri.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Supplica — Arrivano a chiedere, e lo fanno in pubblico. Dire di no adesso costa più di quanto costava ieri. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: Il Conto — Si paga per quello che si è fatto, davanti a chi lo ha subito. Non ripara niente, ma chiude. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Riconciliazione

| | |
|---|---|
| famiglia | resolution |
| funzione | reconciliation |
| cosa fa | La Carestia scende di 1 · Il Risveglio scende di 1 · Eredan: il malcontento si e' spento |
| id | `ECH_RECONCILIATION` |

> Due parti che si erano contate come nemiche trovano un motivo pratico per smettere.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Riconciliazione — Due parti che si erano contate come nemiche trovano un motivo pratico per smettere. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Rivelazione

| | |
|---|---|
| famiglia | turn |
| funzione | revelation |
| convoca un Consiglio | su Il Risveglio |
| cosa fa | Il Risveglio adesso e aperta a tutti · Il Risveglio sale di 1 · apre subito un Consiglio su Il Risveglio |
| id | `ECH_REVELATION` |

> Cio che era privato diventa pubblico davanti a tutti. Non si può più decidere come se non si sapesse.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Rivelazione — Cio che era privato diventa pubblico davanti a tutti. Non si può più decidere come se non si sapesse. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: Vie Riaperte — Il primo carro che passa senza scorta non fa notizia. E per questo che si capisce che è finita. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Strada Chiusa

| | |
|---|---|
| famiglia | pressure |
| funzione | prohibition |
| cosa fa | Le Vie Interrotte sale di 2 · Strada dei Mercanti: resta tagliato fuori |
| id | `ECH_ROAD_CLOSED` |

> Una frana, o qualcuno che l'ha fatta sembrare una frana. Il risultato non cambia: da est non arriva più niente.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Strada Chiusa — Una frana, o qualcuno che l'ha fatta sembrare una frana. Il risultato non cambia: da est non arriva più niente. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Sacrificio

| | |
|---|---|
| famiglia | resolution |
| funzione | sacrifice |
| cosa fa | La Carestia scende di 2 · Nel mondo: someone paid · chi la cala: renowned |
| id | `ECH_SACRIFICE` |

> Qualcuno paga di persona per chiudere una questione. Funziona, e non viene dimenticato.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Sacrificio — Qualcuno paga di persona per chiudere una questione. Funziona, e non viene dimenticato. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
Historical dark-fantasy painting of a narrative moment: La Presa — Non una battaglia: una mattina in cui le guardie alla porta rispondono a un altro nome. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Interramento

| | |
|---|---|
| famiglia | pressure |
| funzione | lack |
| cosa fa | L'Acqua Ferma sale di 1 · Valle Verde: il raccolto non basta · Valle Verde: canale va giu |
| id | `ECH_SILT` |

> Un canale che si chiude non fa rumore. Se ne accorge chi sta in fondo, un anno dopo tutti gli altri.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Interramento — Un canale che si chiude non fa rumore. Se ne accorge chi sta in fondo, un anno dopo tutti gli altri. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Copia

| | |
|---|---|
| famiglia | turn |
| funzione | discovery |
| cosa fa | La Reliquia sale di 1 · La Reliquia adesso e aperta a tutti · chi la cala: una Scoperta (relic) |
| id | `ECH_THE_COPY` |

> Salta fuori una copia del registro antico in una casa dove nessuno sa leggerlo. Adesso lo sanno in tre.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Copia — Salta fuori una copia del registro antico in una casa dove nessuno sa leggerlo. Adesso lo sanno in tre. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Crepa

| | |
|---|---|
| famiglia | rupture |
| funzione | threat |
| cosa fa | La Reliquia sale di 2 · Miniere Antiche: monta il malcontento · un rivale lascia Miniere Antiche |
| id | `ECH_THE_CRACK` |

> Nella galleria bassa si apre una crepa da cui esce aria calda. I Signori della Cenere la puntellano e non lo scrivono da nessuna parte.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Crepa — Nella galleria bassa si apre una crepa da cui esce aria calda. I Signori della Cenere la puntellano e non lo scrivono da nessuna parte. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Stagione Scavata

| | |
|---|---|
| famiglia | resolution |
| funzione | gift |
| cosa fa | L'Acqua Ferma scende di 2 · Valle Verde: vi sorge canale · Nel mondo: water moves |
| id | `ECH_THE_DUG_SEASON` |

> Due stagioni di braccia, e l'acqua arriva dove arrivava prima. Non è un miracolo: è terra tolta.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Stagione Scavata — Due stagioni di braccia, e l'acqua arriva dove arrivava prima. Non è un miracolo: è terra tolta. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### I Fuochi Fuori

| | |
|---|---|
| famiglia | rupture |
| funzione | separation |
| cosa fa | L'Acqua Ferma sale di 1 · Terre Nahr: si e' svuotato · Terre Nahr non e piu di nessuno · la Regione della domanda: adesso e selva maledetta |
| id | `ECH_THE_FIRES_OUTSIDE` |

> Fuori dalle mura i fuochi sono gli stessi di ottobre. Dentro le mura si smette di contarli.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: I Fuochi Fuori — Fuori dalle mura i fuochi sono gli stessi di ottobre. Dentro le mura si smette di contarli. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Il Tavolo Lungo

| | |
|---|---|
| famiglia | resolution |
| funzione | reconciliation |
| cosa fa | La Carta scende di 2 · Il Debito scende di 1 · Il rapporto chi la cala / un rivale diventa neutral |
| id | `ECH_THE_LONG_TABLE` |

> Si mette un tavolo abbastanza lungo perché ci stiano tutti seduti, e si scopre che era quello il problema.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Il Tavolo Lungo — Si mette un tavolo abbastanza lungo perché ci stiano tutti seduti, e si scopre che era quello il problema. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Il Pozzo Zitto

| | |
|---|---|
| famiglia | turn |
| funzione | return |
| cosa fa | La Cenere che Sale scende di 1 · La Reliquia sale di 1 · chi la cala mette una presenza in Miniere Antiche |
| id | `ECH_THE_QUIET_SHAFT` |

> La crepa smette di soffiare da sola. I Signori della Cenere tornano a scendere, e stavolta lo scrivono.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Il Pozzo Zitto — La crepa smette di soffiare da sola. I Signori della Cenere tornano a scendere, e stavolta lo scrivono. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### L'Anno Corto

| | |
|---|---|
| famiglia | turn |
| funzione | transformation |
| cosa fa | L'Acqua Ferma sale di 2 · Il Debito sale di 1 · Valle Verde: si muore di fame |
| id | `ECH_THE_SHORT_YEAR` |

> Il fiume arriva sei settimane in ritardo e riparte in anticipo. Nessuno lo chiama siccita: si dice che è stato un anno corto.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: L'Anno Corto — Il fiume arriva sei settimane in ritardo e riparte in anticipo. Nessuno lo chiama siccita: si dice che è stato un anno corto. Painterly oil
technique, muted earth palette, bianco freddo accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Due Sentenze

| | |
|---|---|
| famiglia | rupture |
| funzione | violation |
| convoca un Consiglio | su La Carta |
| cosa fa | La Carta sale di 2 · Eredan: e' conteso · apre subito un Consiglio su La Carta |
| id | `ECH_TWO_VERDICTS` |

> Lo stesso caso, due città, due sentenze opposte. Entrambe applicate, entrambe legittime.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Due Sentenze — Lo stesso caso, due città, due sentenze opposte. Entrambe applicate, entrambe legittime. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Usurpazione

| | |
|---|---|
| famiglia | rupture |
| funzione | usurpation |
| convoca un Consiglio | su La Successione |
| cosa fa | scrive «La Corona Divisa» · La Successione sale di 1 · apre subito un Consiglio su La Successione |
| id | `ECH_USURPATION` |

> Qualcuno si siede dove non gli spetta, e scopre che nessuno si alza per protestare.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Usurpazione — Qualcuno si siede dove non gli spetta, e scopre che nessuno si alza per protestare. Painterly oil
technique, muted earth palette, rosso scuro accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### La Veglia Spostata

| | |
|---|---|
| famiglia | pressure |
| funzione | omen |
| cosa fa | La Reliquia sale di 1 · chi la cala mette una presenza in la Regione della domanda |
| id | `ECH_VIGIL_MOVED` |

> L'Ordine cambia l'ora delle veglie e non lo annuncia. Chi abita vicino conta le campane.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: La Veglia Spostata — L'Ordine cambia l'ora delle veglie e non lo annuncia. Chi abita vicino conta le campane. Painterly oil
technique, muted earth palette, grigio-ocra accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
```

</details>

### Messo per Iscritto

| | |
|---|---|
| famiglia | resolution |
| funzione | liberation |
| cosa fa | La Carta scende di 1 · Nel mondo: charter temporary · chi la cala: renowned |
| id | `ECH_WRITTEN_DOWN` |

> Non si risolve niente: si scrive. E qualche anno dopo si scopre che scrivere era risolvere.

<details><summary>Prompt per l'immagine</summary>

```
Historical dark-fantasy painting of a narrative moment: Messo per Iscritto — Non si risolve niente: si scrive. E qualche anno dopo si scopre che scrivere era risolvere. Painterly oil
technique, muted earth palette, oro caldo basso accent. The image shows a turning point,
not an action climax: the instant before or the instant after. Human scale, few
figures, strong silhouette reading at small size. Composition: negative space
along the top edge reserved for a title overlay; the focal event sits at the
lower-left third. Vertical card framing, 2:3. No text, no letters, no numerals,
no frame, no border. Not gory. Boardgame card art.
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
| segnalino di domanda | uno per ognuna delle 12 domande |

Le case della scatola sono 8 e a un tavolo ne siedono quattro: i colori
servono tutti, perche' quali quattro lo decide l'anno.

---

*87 carte e 64 pezzi diversi da fare.*
