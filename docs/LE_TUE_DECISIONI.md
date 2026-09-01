# La lista che finisce

Domanda del committente, 0.1.361:

> *«Nessuna però deve portare ad altre issue. Perché qui ne chiudiamo una ma ne
> apriamo dieci. Questo giro deve finire e dobbiamo arrivare a un punto che sia
> giocabile. Da lì possiamo ripartire se servono aggiustamenti.»*

**Questa è quella lista.** Non è l'elenco di tutto quello che si può migliorare:
è l'elenco di quello che sta fra oggi e **una partita che si può giocare**.
Tutto il resto sta in fondo, nella sezione *Fuori dalla lista*, e ci resta finché
non hai giocato.

## La regola che la fa finire

1. **Ogni riga di questa lista ha una fine scritta.** Non «migliora X»: *«fatto
   quando Y»*, e Y è una cosa che si misura o si guarda.
2. **Niente di quello che faccio qui apre una voce nuova.** Se una misura trova
   qualcosa, diventa **una riga sotto la voce che l'ha trovata**, non una voce
   con tre strade. Se quello che trova è più grosso della riga, **mi fermo, lo
   scrivo, e vado avanti con la lista** — decidi tu se vale un giro in più,
   dopo aver giocato.
3. **Le rosse le sblocchi tu con una parola.** Ognuna ha la mia raccomandazione.
   Se non rispondi, faccio quella raccomandata e lo scrivo: **una decisione non
   presa è più cara di una decisione sbagliata**, perché il gioco resta fermo.

<!-- CONTO: inizio - generato da tools/issues_survey.py -->

| | |
|---|---|
| voci scritte | **131** |
| chiuse | **86** |
| aperte | **45** |
| di cui **aspettano una tua decisione** | **10** |
| di cui sono mie da fare | **35** |

E il ritmo, voce per voce, per fascia di venticinque versioni:

| versioni | aperte | chiuse |
|---|---|---|
| 0.1.250–0.1.274 | 12 | 5 |
| 0.1.275–0.1.299 | 13 | 7 |
| 0.1.300–0.1.324 | 12 | 4 |
| 0.1.325–0.1.349 | 7 | 8 |
| 0.1.350–0.1.374 | 6 | 9 |

*(Conto generato da `tools/issues_survey.py`: i numeri 1, 2, 3, 4 sono usati due volte, in due milestone diverse; 67 voci non dicono a che versione si sono aperte.)*

<!-- CONTO: fine -->

*(Le voci che aspettano te sono **nove decisioni**: la
[122](ISSUES.md#122) e la [125](ISSUES.md#125) sono la stessa domanda. Le altre
sono mie, e stanno tutte dentro le otto gialle e le quattro verdi qui sotto, o
nella sezione «fuori dalla lista» in fondo — **nessuna voce aperta è senza
casa**, e questo lo tiene un cancello.)*

---

# 🔴 Le nove rosse — tue, una parola ciascuna

In ordine di quanto cambiano la partita. Sotto ognuna: la domanda in una riga, il
numero che la motiva, cosa farei io.

### R1. [123](ISSUES.md#123) — un'Azione che costruisce?

**Quaranta turni su cento** un giocatore ha ventidue mosse legali, quattro carte
in mano, e *non gliene serve nessuna*. La causa è misurata: **nessuna** delle sei
Azioni della plancia alza una Pietra, in cento partite. Chi vuole costruire deve
convincere il tavolo — e il Consiglio è più generoso con **chi tace** (199 Pietre
a un tavolo che passa sempre, 136 a uno che gioca).

> **Farei (a): ACQUISIRE diventa «pesca una carta, *oppure* alza una Pietra dove
> hai presenza».** È l'unica delle sei che nessuna carta modifica, quindi ha
> spazio. Cambia la plancia, ed è per questo che è tua.

Sblocca anche [111](ISSUES.md#111) (le dieci Pietre che non si alzano mai) e
metà di [59](ISSUES.md#59) (i verbi che nessuno gioca).

### R2. [122](ISSUES.md#122) + [125](ISSUES.md#125) — quanto compra una proposta

Sono una domanda sola. Con **un solo beneficio gratis**, il numero di caselle
vive per Consiglio è **uno**: le altre ventitré esistono per quando la prima non
si può comprare. E la moneta è troppo poca perché una proposta sia una mossa: i
gettoni di rivendicazione arrivano da **9 carte su 48**.

> **Farei: due acquisti liberi, e le facce RIVENDICARE da 9 a 15 su 48.** Il
> Consiglio passa da «prendo il massimo» a «costruisco una mossa». Costo: il
> Consiglio diventa più generoso, e il cancello va rimisurato — è mezz'ora.

### R3. [119](ISSUES.md#119) — come cade un Consiglio

**Un Consiglio su undici cade.** Il segno di chi ha parlato e perso si posa
**8 volte in cento partite**: una minaccia che si vede una volta ogni dodici
partite non è una minaccia, ed è la ragione per cui il tavolo silenzioso viene
premiato (R1).

> **Farei (b): il fallimento si compra.** Un gettone speso *contro* la proposta
> pesa nel margine. Al tavolo: *«questa non deve passare»*, e paghi per fermarla,
> invece di sperare nel dado. Va dopo R2, perché ha bisogno che i gettoni ci
> siano.

### R4. [120](ISSUES.md#120) — vincere nominando, non contando

**Dodici Obiettivi su diciassette si vincono contando** — tre pedine, due
Regioni, quattro Pietre — e non nominano niente del mondo. È anche la metà buona
di [91](ISSUES.md#91): il 52% dei punti era già vero prima che qualcuno giocasse,
perché un conto è vero o falso all'apertura e nessuno lo può contestare.

> **Farei: i dodici si riscrivono su un segno o un luogo** — *«la Regione dove
> hai posato la Cicatrice»*, *«il Tema che hai raffreddato»*. Un obiettivo che
> nomina qualcosa lo si può contendere; un conto no.

Questa e R1 insieme sono il gioco: **una ragione per agire, e qualcosa che si
può togliere all'avversario.**

### R5. [124](ISSUES.md#124) — le due case che non possono vincere l'Eredità

L'Eredità (+3 per ogni leggenda che porta il tuo nome, tua parola in 0.1.353) è
**strutturalmente zero** per due case su otto: il loro profilo non ha una voce
che una leggenda possa portare.

> **Farei: si scrive quella voce.** Due righe di dato, mezz'ora, e nessuna regola
> cambia. La metto rossa solo perché è **cosa vogliono quelle due case**, e
> questo lo decidi tu.

### R6. [64](ISSUES.md#64) — una saga ricambia metà tavolo

Fra un anno e l'altro di una saga **metà dei seggi cambia casa**, e nessuno ha
mai deciso che dovesse. O è la cosa giusta — le case passano, il mondo resta — o
è un difetto.

> **Farei: è giusto, e si dichiara.** È il gioco che hai voluto: *le Azioni
> cambiano il mondo, il Consiglio decide cosa il mondo ricorderà*. Ma va scritto
> sulla scatola, non lasciato succedere.

### R7. [127](ISSUES.md#127) — la tessera si gira, e l'arte si gira con lei

Da D-390 una tessera si posa **ruotata**, perché i varchi combacino. Un
disegno ha un alto e un basso.

> **Farei (2): l'arte disegna tutti e quattro i varchi, e i lati chiusi si
> coprono con un gettone.** Allargati i varchi a trentotto su quaranta (D-393)
> questo costa **un gettone su una tessera sola** — l'Isola Muta — e l'arte non
> gira mai. Va deciso **prima** di commissionare i disegni, ed è per questo che
> è qui.

### R8. [69](ISSUES.md#69) — come è fatta una carta Azione

La faccia fisica adesso si stampa per intero — DOVE, le due Azioni col loro nome,
SEMPRE, AL CONSIGLIO. Ma su 48 carte **46 stampano il corpo rimpicciolito** (la
più stretta al 77%) e l'illustrazione è scesa al suo pavimento del 34%. Una carta
63×88 che porta sette righe di regole **e** un disegno è una carta che si legge
male.

> **Farei: formato tarocco anche per le Asset**, come la scheda del Consiglio.
> Costa una scatola più grande e niente altro. L'alternativa — l'illustrazione
> fuori dalla faccia delle regole — costa una carta a due facce.

Va decisa **prima** dell'arte (V4), come R8: si disegna per un formato, non per
due.

### R9. [100](ISSUES.md#100) — le caselle «SI ACCENDE QUANDO»

Le 46 facce che dicono quando una Tensione si scalda sono ancora **derivate**:
le calcola il motore invece di leggerle dalla carta. Al tavolo fisico quella
riga o è stampata o non esiste.

> **Farei: si stampano come stanno.** Il motore le genera già bene; si
> congelano nel dato, e da lì si correggono a mano quelle che suonano male. È
> una tua parola perché sono **quarantasei frasi che un giocatore legge**.

---

# 🟡 Le otto gialle — mie, e ognuna ha una fine

Non aspettano niente. Le faccio in quest'ordine, e nessuna apre una voce nuova.

### G1. L'app diventa un prototipo giocabile — [63](ISSUES.md#63), [73](ISSUES.md#73), [80](ISSUES.md#80), [65](ISSUES.md#65)

È la più grossa, ed è **quella che decide la parola «giocabile»**. Oggi l'app è
un'ispezione di stato con dei bottoni; lo schermo del Consiglio è quello di due
regole fa.

**Fatto quando** si gioca un anno intero dall'app senza leggere un id: carte che
si prendono e si posano, la plancia col Consiglio nuovo, e una prova che guida
lo schermo dall'inizio alla fine di un Consiglio.

### G2. Le cinquantadue voci mute del Consiglio — [88](ISSUES.md#88), [104](ISSUES.md#104), [56](ISSUES.md#56), [60](ISSUES.md#60)

**13 domande e 39 proposte** arrivano in discussione e non vengono scelte mai;
3 proposte fanno la stessa identica cosa di un'altra sulla stessa scheda; 3
Conseguenze su 52 non escono mai; una domanda su dodici apre metà delle volte
delle altre.

**Fatto quando** ogni voce o viene scelta almeno una volta in cento anni, **o
esce dalla scatola**. Le tolgo, non le riscrivo tre volte.

### G3. Ogni segno ha un lettore, o esce — [77](ISSUES.md#77), [96](ISSUES.md#96), [101](ISSUES.md#101), [70](ISSUES.md#70), [111](ISSUES.md#111)

`condition:contested` è scritto **531 volte in cento anni** e non c'è una
clausola in tutta la scatola che lo nomini; quindici segni non hanno una riga
che dica perché esistono; `structure:road` non lo costruisce nessuna Pietra; due
segni hanno ancora due nomi.

**Fatto quando** ogni segno o è nominato da almeno una clausola, o è dichiarato
colore con la sua riga, o è cancellato. Nessun terzo caso.

### G4. L'ultima casa murata — [108](ISSUES.md#108)

Tre delle quattro voci di questo gruppo si sono chiuse in 0.1.362: Lyra è il
seggio migliore del tavolo uniforme, la linea dei Fuochi sta nella banda, e
nessuna casa muta più spesso di un salto su 4,7. **Resta Vaerax**, con un Destino
murato a tutti e tre i passi: la strada provata in 0.1.315 faceva cadere una
prova del RIVENDICARE ed è stata ritirata.

**Fatto quando** `mine_sealed` esce almeno una volta su cento partite, senza far
cadere `test_claim_policy`.

### G5. La saga arriva in fondo — [67](ISSUES.md#67)

*«La saga si ferma alla seconda partita»* — parola tua, e la causa non è mai
stata provata. Il motore gira pulito per quattro anni di fila in headless: il
difetto è nello schermo, e nessuna prova lo tocca.

**Fatto quando** una prova guida la schermata vera per tre anni di saga e ci
arriva. Va con G1.

### G6. Il cervello gioca il suo profilo — [78](ISSUES.md#78), [126](ISSUES.md#126), [59](ISSUES.md#59)

I quattro profili strategici dicono cosa una casa vuole lasciare nel mondo, e
**li legge solo il validatore**. E il cervello prenota un diritto **285 volte e
lo spende 12**.

**Fatto quando** il cervello sceglie guardando il suo profilo, e le prenotazioni
inutili scendono sotto un quarto.

### G7. Le due grammatiche non si ripetono — [87](ISSUES.md#87), [106](ISSUES.md#106)

Restano **27 righe d'autore** che fanno quello che una casella del prezzo fa già,
e la pedina che muove una domanda non porta con sé **quale** domanda: copre 59
applicazioni su 90.

**Fatto quando** gli acquisti a vuoto sono sotto il 5% e la pedina porta il nome.

### G8. Il RIVENDICARE che muore in mano — [37](ISSUES.md#37)

La metà mappa di questo gruppo si è chiusa in 0.1.362: la Strada dei Mercanti è
la **seconda Regione più abitata** (1,07 → 2,23 presenze). Resta `ACT_CLAIM`, che
muore in mano tre volte su quattro.

**Fatto quando** le rivendicazioni morte scendono sotto una su tre.

---

# 🟢 Le quattro verdi — mie, corte

### V1. La passata di verità su tutte le voci aperte

**[ISSUES 68](ISSUES.md#68) è rimasta aperta cento versioni dopo essere stata
curata**, perché nessuno aveva riletto la condizione che si era scritta. Non
sarà l'unica. Rileggo tutte le voci aperte contro i numeri di oggi e chiudo
quelle che sono già vere.

**Fatto quando** ogni voce aperta ha un numero di oggi, non uno di cento
versioni fa. **È la prima cosa che faccio**, perché probabilmente accorcia il
resto della lista.

### V2. Le vecchie voci [1](ISSUES.md#1), [2](ISSUES.md#2), [3](ISSUES.md#3), [4](ISSUES.md#4) e [40](ISSUES.md#40)

Cinque voci del bilanciamento di 0.1.2x, scritte su un gioco che non c'è più
(l'`hand_refill` di allora, i gradini di allora). O sono ancora vere sui numeri
di oggi e rientrano in una gialla, o si chiudono come storia.

### V3. [105](ISSUES.md#105) — le sezioni di `REVISIONE_TESTI` scritte a mano

Il documento che dice *«ogni testo che un giocatore può leggere»* ne mancava
**1.128** senza andare rosso, perché le sezioni si aggiungono a mano. Si genera
dai dati, come tutti gli altri.

### V4. L'arte: 144 segnaposto su 155

Non è una voce, è la scatola: **144 illustrazioni su 155 sono ancora un
segnaposto**. I prompt sono tutti scritti e generati dai dati veri. È lavoro
meccanico, e va dopo R8 (che decide come si disegna una tessera).

---

# ⚪ Fuori dalla lista, finché non giochi

Non perché non valgano: perché **ognuna di queste è un gioco nuovo**, e aprirla
adesso è esattamente il giro che vuoi chiudere. Restano scritte dove sono.

| | perché è fuori |
|---|---|
| [98](ISSUES.md#98) — ogni segno dichiara se pesa o se è colore | è un **metodo**, non una cosa: genera lavoro all'infinito. La sua metà utile è G3, e G3 finisce |
| [36](ISSUES.md#36) — il generatore di linee sempre diverse | tua idea grossa: permutare Destini, ruoli, incarnazioni. Dopo la prima partita |
| [39](ISSUES.md#39) — le strutture con una vita (torre → castello → reggia) | tua idea grossa, e tocca la plancia. Dopo R1, che tocca la plancia anche lui |
| [47](ISSUES.md#47) — le carte come unica moneta | tua idea grossa: riscrive l'economia del turno. Dopo |
| [50](ISSUES.md#50) — quattro obiettivi al posto dei tre gradini | tua idea grossa, e R4 la anticipa in parte |
| [27](ISSUES.md#27) — il tavolo sullo schermo grande e le console in tasca | milestone 0.6, e ha bisogno che G1 esista prima |
| [82](ISSUES.md#82) — la coda della fustella | è una potatura di componenti: si fa quando la scatola si stampa, non prima |
| [91](ISSUES.md#91) — il 52% dei punti già vero all'apertura | **la sua cura è R4**. Si rimisura dopo, e probabilmente si chiude da sola |

---

## Come finisce

Nove rosse, otto gialle, quattro verdi. **Ventuno righe, e ognuna ha una fine
scritta.**

**E in 0.1.362 ne sono cadute sei senza che tu dovessi rispondere** — una era
rossa. Erano già vere e nessuno le aveva rilette: è la verde V1, e ha fatto
esattamente quello che prometteva. Quando sono finite, il giro è finito: si gioca, e quello che la
partita dice diventa la lista dopo — che sarà tua, non mia.

Se una rossa non arriva, faccio la raccomandata e la segno come *fatta sulla mia
parola*, così non è il gioco a stare fermo ad aspettare.
