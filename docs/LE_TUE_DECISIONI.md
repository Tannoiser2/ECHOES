# Le quindici cose che aspettano te

Domanda del committente, 0.1.356: *«non si arriva mai al punto di chiudere?»*.
La risposta onesta è **no, non con questo metodo**, e questo foglio serve a
cambiarlo.

## Perché la lista non si chiude da sola

<!-- CONTO: inizio - generato da tools/issues_survey.py -->

| | |
|---|---|
| voci scritte | **131** |
| chiuse | **80** |
| aperte | **51** |
| di cui **aspettano una tua decisione** | **15** |
| di cui sono mie da fare | **36** |

E il ritmo, voce per voce, per fascia di venticinque versioni:

| versioni | aperte | chiuse |
|---|---|---|
| 0.1.250–0.1.274 | 12 | 5 |
| 0.1.275–0.1.299 | 13 | 7 |
| 0.1.300–0.1.324 | 12 | 4 |
| 0.1.325–0.1.349 | 7 | 8 |
| 0.1.350–0.1.374 | 6 | 4 |

*(Conto generato da `tools/issues_survey.py`: i numeri 1, 2, 3, 4 sono usati due volte, in due milestone diverse; 67 voci non dicono a che versione si sono aperte.)*

<!-- CONTO: fine -->

**Questo conto adesso lo fa uno strumento, e la prima volta che l'ha fatto mi ha
smentito.** Quando questo foglio è nato, in 0.1.356, i numeri qui sopra li avevo
contati a mano: dicevano *66 chiuse, 60 aperte*, e la fascia 0.1.325–349 a *sette
aperte e zero chiuse*. Erano sbagliati. **Tredici voci chiuse non portavano il
segno di spunta nel titolo**, quindi nessun conteggio poteva vederle — e la
fascia che sembrava la peggiore è in realtà l'unica in cui **si chiude più di
quanto si apra** (7 e 8). Adesso il segno è la regola, `tools/issues_survey.py`
lo controlla, e questa tabella si rigenera da sola
([D-391](DECISIONS.md#d-391)).

**Resta vero che apro più di quanto chiudo, ma non sistematicamente**: due
fasce su cinque sono in pari o meglio. Non è disordine ed è il metodo — la regola
di casa è *misura prima di scrivere*, e ogni misura trova qualcosa. Quello che è
falso è che il metodo non abbia mai chiuso niente: ha chiuso **ottanta voci su
centotrentuno**.

## E la lista non è il traguardo

Il traguardo è **PZ-01**, e ha tre criteri. Due sono misurati e tengono:

| | |
|---|---|
| meno della metà dei turni sono «passa» | **47,6%** ✓ — [ISSUES 68](ISSUES.md#68) chiusa in 0.1.358 |
| 0 seggi bloccati su un solo livello su 8 | ✓ sui due tavoli |
| **«dopo una partita si guarda la mappa e si capisce cosa è successo»** | **?** |

**Il terzo non lo può dire nessuna sonda.** È un giudizio, ed è tuo. Quindi la
risposta alla tua domanda è: **si chiude quando giochi una partita.** Non c'è
nessuna misura che io possa fare che chiuda quel criterio, e finché non è chiuso
la lista continuerà a crescere perché è l'unica cosa che so fare senza di te.

---

## Le quindici, con la mia raccomandazione

Ordinate per quanto cambiano la partita. Per ognuna: la domanda in una riga, il
numero che la motiva, e cosa farei io.

### 1. [125](ISSUES.md#125) — la moneta del Consiglio è troppo poca

I gettoni RIVENDICARE funzionano, ma i benefici comprati per Consiglio sono
**scesi** da 1,71 a 1,40: con 2,8 carte per partita bastano per un acquisto in
più *a partita*, non a Consiglio.

**Farei (a): più carte con la faccia RIVENDICARE**, da 9 a 15 su 48. Non tocca
nessuna regola, raddoppia quasi la moneta, e si misura in mezz'ora.

### 2. [123](ISSUES.md#123) — nessuna Azione della plancia alza una Pietra

Zero Pietre alzate da un'Azione in cento partite. Le alza solo il Consiglio, e il
Consiglio è **più generoso con un tavolo che tace** (199 contro 136).

**E adesso si sa quanto costa.** Chiudendo ISSUES 68 in 0.1.358 il residuo è
finito qui: **quaranta turni su cento** sono un giocatore che ha 22 mosse legali
e 4 carte in mano e non fa niente, *perché niente gli serve*. Questa è la
decisione che muove il numero più grosso del gioco.

**Farei (a): ACQUISIRE diventa «pesca una carta, **oppure** alza una Pietra dove
hai presenza».** È l'unica delle sei Azioni che nessuna carta modifica, quindi è
quella che ha spazio. Cambia la plancia, ed è per questo che è tua.

### 3. [119](ISSUES.md#119) — il Consiglio non cade quasi più

Un Consiglio su undici cade. `spoke_and_lost` si posa **8 volte in cento
partite**: un segno che si vede una volta ogni dodici partite non è una minaccia.

**Farei (b): il fallimento si compra.** Un gettone speso *contro* la proposta
pesa nel margine. Al tavolo: *«questa non deve passare»*, e paghi per fermarla —
invece di sperare nel dado. Va dopo la 1, perché ha bisogno che i gettoni ci
siano.

### 4. [120](ISSUES.md#120) — come il tavolo si ricorda di un gesto

La clausola c'è (`did_this_year`), il **segnalino** no: a fine anno *«l'hai
alzata quest'anno?»* si risponde ricordando, o guardando l'app.

**Farei: la pila delle carte giocate**, scoperta davanti a ciascuno — è già nella
scatola, ed è dove il gioco guarda già per gli Echi. Costo: il gesto diventa una
proprietà della carta invece che del mondo.

### 5. [126](ISSUES.md#126) — la prima metà del RIVENDICARE

Si prenota **285 volte** e si spende **12**. Il resto delle volte si forza su una
domanda già matura, dove prenotare non serviva.

**Farei prima la lettura mia**: è probabile che sia il cervello che prenota per
abitudine. Se dopo la taratura il numero non scende, allora è la regola, e
toglierei il CREATE — un'Azione, un Consiglio.

### 6. [124](ISSUES.md#124) — due case su otto non prendono mai l'Eredità

Nahr e Vaerax: i segni che vogliono lasciare sono muri e insediamenti, e un muro
non diventa leggenda.

**Farei (b): cambio due desideri a testa** perché almeno metà siano fatti globali
che possono sbiadire. È contenuto d'autore, quindi è tuo: cambia **chi sono**
quelle due case.

### 7. [96](ISSUES.md#96) — i segni scritti che nessuno guarda

Ne restano **due**: `watched` (17 scritture) e `price_in_lives` (14). Erano
venticinque. E dall'altra parte **sei** segni temuti che nessuno scrive mai.

**Farei (1) per i due, (2) per i sei**: una clausola su una carta condivisa per i
primi, e ri-mirare le sei clausole su segni che il mondo produce.

### 8. [91](ISSUES.md#91) — metà dei punti è già vera prima di giocare

**47,6%** (era 60,5%). `state_tag_absent` resta il blocco più grosso, con 492
clausole mai contese.

**Farei (1b): le soglie assolute diventano confronti** — non *«poche
Cicatrici»* ma *«meno Cicatrici di chi ne ha di più»*. È la sola che sposta la
dotazione invece di aggiungere clausole.

### 9. [100](ISSUES.md#100) — le 46 facce «SI ACCENDE QUANDO» derivate

Quarantasei facce ricavate dai dati aspettano una mano d'autore, e tredici
Tensioni non ne hanno nessuna.

**È scrittura, ed è tua.** Io posso preparare il foglio con le quarantasei righe
derivate accanto allo spazio per la tua.

### 10. [98](ISSUES.md#98) — ogni segno dichiara se pesa o se è colore

La tua direzione, non ancora chiusa: *«se un tag viene scritto ma non letto è
rumore; se letto ma non scritto è una promessa falsa»*.

**Farei: il campo `pesa` sul dizionario**, e un cancello che pretende che ogni
segno lo dichiari. È lavoro mio una volta che hai detto sì.

### 11. [82](ISSUES.md#82) — la coda della fustella

Diciassette tipi di segnalino su 34 non escono mai o quasi. Le **Cicatrici rare
sono design**; le **condizioni rare sono un buco** — `condition:starving` un anno
su quaranta, e la fame è un Tema del gioco.

**Farei (2): far succedere le condizioni rare**, non ridurre i tipi.

### 12. [64](ISSUES.md#64) — una saga ricambia metà tavolo

Solo il **51%** dei seggi seduti dopo l'apertura sono le case che hanno aperto la
saga. Non è scritto da nessuna parte che sia voluto.

**Farei: le case che aprono la saga restano**, e il pescaggio vale solo per
l'apertura. Altrimenti il punteggio di campagna per casa misura una cosa che si
siede a intermittenza.

### 13. [66](ISSUES.md#66) — la seconda saga non si raggiunge

CHR_03 è contenuto scritto, validato e giocabile che **nessuno può aprire**.

**Farei (3): toglierla**, e dirlo ad alta voce — venti Destini e quattro case in
meno. Una saga sola, fatta bene, batte due di cui una irraggiungibile.

### 14. [122](ISSUES.md#122) — un Consiglio decide una cosa sola

Metà l'hai già decisa tu in 0.1.353 (i gettoni). L'altra metà resta: con **un
solo acquisto gratuito**, il numero di caselle vive per Consiglio è *uno*, e le
altre ventitré esistono per quando la prima non si può comprare. Ogni casella
alzata ne spegne un'altra: è la forma dell'economia, non la taratura.

**Farei (a): va bene così**, e si cambia la domanda — non *«chi compra questa
casella»* ma *«quante caselle diverse si comprano in un anno»*. È la strada che
non tocca niente, e la (c) — il prezzo lo fanno gli avversari — arriva comunque
con ISSUES 72.

### 15. [127](ISSUES.md#127) — la tessera si gira, e l'arte si gira con lei

Da [D-390](DECISIONS.md#d-390) una tessera si posa **ruotata**, perché i varchi
combacino. Il disegno di una Regione, però, ha un alto e un basso.

**Farei (b): l'arte della tessera si disegna senza alto e senso di lettura** —
vista dall'alto, niente scritte orientate — così la rotazione non si vede. È la
soluzione che il tavolo fisico usa da sempre. L'alternativa è stampare le
tessere quadrate con quattro orientamenti equivalenti, che costa in disegno.

---

## Cosa faccio io mentre decidi

Da 0.1.356 **non apro più voci nuove.** Quello che una misura trova lo scrivo
come una riga sotto la voce che l'ha trovato, non come una voce con tre strade.
Le voci nuove le apri tu.

**E la prima è chiusa.** [ISSUES 68](ISSUES.md#68) — *«otto turni su dieci non
succede niente»*, la voce più grossa che avessi — si è chiusa in 0.1.358 sulla
condizione che si era scritta da sola: **47,6%** di «passa» a tavolo misto,
**47,9%** a tavolo uniforme, cancello 0/8. Era vera da cento versioni e nessuno
l'aveva riletta ([D-391](DECISIONS.md#d-391)). Quello che resta di quella voce
— **quaranta turni su cento** in cui un giocatore ha ventidue mosse e non gliene
serve nessuna — è finito dove sta la sua causa: la numero 2 di questa lista.

E le trentasei che sono mie le lavoro in quest'ordine, che è quello di quanto
cambiano la partita:

1. **ISSUES 88** — il tavolo vede poco più di un terzo di quello che è scritto;
2. **ISSUES 69** — la Risonanza è scritta e non succede (la faccia fisica);
3. **ISSUES 77 e 96** — i segni muti e quelli che nessuno guarda;
4. **l'arte** — 144 segnaposto su 155, che è la cosa che separa la scatola da una
   partita vera.
