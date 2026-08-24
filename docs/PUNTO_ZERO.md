# PUNTO ZERO — dov'è ECHOES, misurato

**Versione 0.1.220** · `main` a `2c9b4a5` · scritto alla chiusura della sessione
che ha portato da D-232 a D-258.

Questo documento non racconta cosa il gioco vuole essere. Dice **cosa fa oggi, con
i numeri**, e cosa è ancora aperto. È il foglio contro cui va scritta la revisione
nuova: se una voce qui sotto non ti torna, quella è la prima cosa da cambiare.

Tutti i numeri sono su **100 semi, `--seed=7000`**, tavolo misto salvo dove detto.

---

## 1. Quello che tiene

| | |
|---|---|
| suite | **512 prove / 12.289 asserzioni** verdi |
| il vincolo che non si negozia | **0 seggi bloccati su 8**, misto e uniforme |
| cancelli | tutti verdi (vedi `CLAUDE.md`) |
| Consigli per anno | misto **3-8** (media 5,05) · uniforme **3-9** (media 5,26) |
| Verità scritte | 384 su 100 anni, 384 diverse |

Il **nove** del tavolo uniforme è il prezzo dichiarato della Risonanza (D-257):
tre tentativi di riportarlo a otto non l'hanno spostato, e le trentasei carte
convertite dopo non l'hanno peggiorato.

---

## 2. La grammatica fisica: cosa esiste

| | |
|---|---|
| Temi | **6** — Potere, Sopravvivenza, Terra, Antico, Fede, Vie |
| carte con faccia fisica | **48 su 48** |
| Domande fisiche | **12** (due per Tema) |
| Destini con faccia fisica | **8 su 20** |
| Tensioni, per Tema | Sopravvivenza 3 · Vie 3 · Potere 2 · Antico 2 · **Terra 1** · **Fede 1** |

Il motore **esegue la Risonanza** e nient'altro della faccia fisica.

| | |
|---|---|
| Risonanze | **364 in 100 anni — 3,6 per anno** |
| di quelle, aggravate | **10,2%** |
| Calore su Potere / Vie / Fede / Sopravvivenza | 28,6% · 28,3% · 21,7% · 20,1% |
| Calore su **Terra** | **1,4%** |

---

## 3. Il difetto più grosso rimasto

**Otto turni su dieci non succede niente** (ISSUES 68).

| | |
|---|---|
| turni «passa» | **82,8%** su 7.200 |
| per Atto | 72,6% → 86,4% → 89,4% |
| passa con **zero mosse legali** | **0 su 5.960** (media: 15,3 mosse) |
| passa con la mano vuota | 37 su 5.960 (media: 6,4 carte) |

Le cause, misurate:

| | quota | cura |
|---|---|---|
| nessuna mossa gli serviva | **58,7%** | la ragione — obiettivi, e li abbiamo appena curati una volta |
| voleva un verbo, in mano niente | 20,1% | il **mazzo**: come si pesca |
| aveva il verbo e non poteva usarlo lì | 15,3% | il **bersaglio**: dove si può |

Il verbo che il cervello vuole dire e non riesce è **INFLUENZARE**, e le intenzioni
mute sono **cresciute** da 2.152 a 2.422 dopo la cura degli obiettivi: è la faccia
buona del difetto — adesso i seggi *vogliono* più spesso — e dice che il fronte
successivo è il mazzo.

**Cosa è già stato fatto su questa voce** (D-255): gli obiettivi adesso chiedono
qualcosa che il mondo non regala. Quanto rende giocare è passato da **−1,1% a
+86,2%**, e i punti già veri all'apertura dal 43,0% al 14,0%.

---

## 4. Le voci aperte che posso chiudere io

In ordine di quanto cambiano la partita.

1. **ISSUES 69 — la faccia fisica non è eseguita.** La Risonanza sì; il resto no:
   la **scelta fra le due Azioni** non arriva al cervello (esegue il verbo di
   sempre), le **dodici Domande fisiche non si pescano** (il Consiglio apre ancora
   i template digitali), il **Calore dei Temi non ha una traccia propria**, e
   **dodici Destini su venti** non hanno faccia.
2. **ISSUES 68 — il mazzo.** Un quinto dei «passa» è pesca sbagliata e un settimo
   è bersaglio sbagliato. Va misurato *quali* carte servono a chi e non arrivano.
3. **ISSUES 56 — tre Conseguenze su 52 non escono mai**, con tre cause diagnosticate.
4. **ISSUES 53 — RIVENDICARE può forzare un Consiglio che poi non si apre.** Due
   strade scritte, nessuna scelta.
5. **ISSUES 67 — la saga si ferma alla seconda partita**: non riprodotto in
   headless. La domanda che chiude la voce: a fine seconda partita l'offerta
   «Gioca l'era successiva» **compare**?

---

## 5. Le decisioni che sono tue e non mie

Queste non le prendo io. Sono le porte chiuse della revisione nuova.

1. **Terra e Fede hanno una Tensione sola.** I loro mazzi di Domande si ripetono
   alla seconda partita, e la Terra prende l'1,4% del Calore. Servono Tensioni
   nuove, e cosa siano è materia d'autore.
2. **ISSUES 65 — «tutta la pagina dell'app va rivista».** Tre revisioni diverse si
   nascondono in quella frase: la leggibilità, l'impaginazione, o *l'idea di cosa
   si guarda*. Non è la stessa cosa e non costa la stessa cosa.
3. **ISSUES 66 — CHR_03 non si raggiunge più.** O ci si arriva giocando, o vive
   altrove, o si toglie.
4. **ISSUES 64 — una saga ricambia metà tavolo** e nessuno ha deciso che dovesse.
5. **ISSUES 39 e 36** sono in seduta da tempo: la terra che si vede, e le linee
   sempre diverse.

---

## 6. Come è fatto il contenuto

| | |
|---|---|
| Asset | 48 (6 famiglie × 8), tutte con faccia fisica |
| carte Echo | 39 |
| Conseguenze | 52, di cui **3 mai uscite** |
| Destini | 20, di cui 8 con faccia fisica |
| obiettivi | 16, riscritti in D-255 |
| Tensioni | 12 |
| template di Consiglio | 10, 19 domande |
| Domande fisiche | 12 |
| regole del segno | 52 |
| Regioni | 6 · **Entità** 8 · **Cronache** 4 |

---

## 7. Dove sono i verbali

- `docs/DECISIONS.md` — le decisioni, dalla più recente. Oggi si arriva a **D-258**.
- `docs/ISSUES.md` — 31 voci aperte, ognuna con «fatto quando».
- `CHANGELOG.md` — cosa è cambiato, versione per versione.
- `docs/CATALOGO_CARTE.md` — **le 48 carte come vanno stampate**, faccia fisica
  compresa, più i 64 pezzi da produrre.
- `docs/CATALOGO_CONSIGLI.md` · `docs/REGISTRO_SEGNI.md` · `docs/BRIEF_ARTE.md` —
  generati e committati, con drift check in CI.

---

## 8. Le lezioni che questa sessione ha pagato

Valgono più di metà del codice che ho scritto.

1. **Uno zero è quasi sempre la sonda.** Quattro volte di fila, in questa sessione:
   il segno che il probe cercava nella forma sbagliata, il cervello chiesto al
   router invece che al seggio, l'aggravata contata dai segni invece che dal
   Calore, la firma che non esisteva. Prima di credere a uno zero, provalo su un
   caso che deve dare non-zero.
2. **Un cancello che si soddisfa da solo è peggio di nessun cancello.** Il
   validatore fisico contava «letto» un segno solo perché elencato sotto un Tema:
   sarebbe bastato aggiungere una riga a un elenco per farlo tacere.
3. **Una prova può smettere di provare senza dirlo.** Cercava una carta senza
   faccia fra quelle spedite; finita la conversione, passava a vuoto.
4. **Aggiustare la causa sbagliata è peggio che non aggiustare.** La cronaca nera
   è stata «risolta» due volte guardando la dimensione del raster invece che
   l'inchiostro sulla pagina.
