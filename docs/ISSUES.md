# ECHOES — quello che resta da fare, in pezzi apribili

La roadmap dice *dove si va*. Questo dice **cosa si apre domani mattina**: ogni
voce è un'issue già scritta — titolo, etichette, milestone, perché esiste, cosa
la chiude — pronta da incollare su GitHub così com'è.

Sta nel repository e non solo su GitHub per una ragione precisa: una voce qui
dentro invecchia insieme al codice che la rende obsoleta, e si chiude nello
stesso commit che la risolve. Quando una di queste viene aperta davvero, si
segna il numero accanto al titolo.

**Regola di casa, e vale per metà di questa lista:** una modifica alle regole si
**misura prima di scriverla**. Gli strumenti ci sono già — `cli/run_playtest.gd`
(100 partite a tavolo misto), `cli/run_balance_probe.gd`, le sonde in `cli/` — e
il progetto ha già tre casi a verbale in cui la modifica ovvia peggiorava le
cose ([D-051](DECISIONS.md#d-051), [D-055](DECISIONS.md#d-055)).

Legenda etichette: `regola` · `contenuto` · `arte` · `motore` · `ux` ·
`strumenti` · `da-misurare` · `decisione` · `debito`

---

## Milestone 0.2 — Bilanciamento

### 1. ✅ Opporsi non costa abbastanza: la seconda leva — fatta in 0.1.24

`regola` · `da-misurare` · **chiusa** ([D-064](DECISIONS.md#d-064))

La leva scelta fra le tre in elenco è la prima: **chi si oppone non recupera la
carta quando la proposta cade**. Sugli stessi 100 semi di D-055 il divario in
Vittorie fra aggressivo e prudente passa da **37 a 26** (69-32 → 66-40), i
fallimenti da 274 a 251, e i Consigli per Chronicle restano 5,96 — dentro la
banda del §7, che è quello che la Conseguenza tentata la prima volta aveva
sfondato. Sta in `confluence_rules.opposer_recovers_on_failure`, quindi si toglie
senza toccare il codice.

**Non ha detronizzato l'Oppose**: 66 contro 40 resta una distanza. Le altre due
varianti in elenco non sono state misurate, e [D-063](DECISIONS.md#d-063) ne ha
aggiunta una terza che sembra più mirata di tutt'e tre — **il diritto di
proporre**, che il gioco sposta già con `CLAIM`. È il primo candidato della 0.2.

<details><summary>Il testo dell'issue come era stato scritto</summary>

La prima leva è partita con la 0.1.17: una Condition qualificata entra nel
margine ([D-055](DECISIONS.md#d-055)). I fallimenti sono scesi da 315/603 a
282/596 e i seggi bloccati da 1 su 8 a 0 su 8. **Non ha detronizzato l'Oppose**:
su 100 partite a tavolo misto l'aggressivo chiude 61 Vittorie contro le 22 del
prudente.

Manca un prezzo vero sul fronte contrario. Un tentativo è già stato fatto e
respinto: una Conseguenza che alzava di 1 la domanda quando una proposta cadeva
rendeva il blocco **più** conveniente, non meno, e portava le Chronicle sopra il
tetto del §7.

Da provare, misurando: chi si oppone non recupera la carta quando la proposta
cade · l'Oppose costa un Asset in più a parità di voce · il proponente sceglie
per ultimo. Una alla volta.

**Fatto quando** una variante è misurata su gli stessi 100 semi di D-055 con
`run_playtest.gd`, e o entra con i numeri accanto, o è scritta come respinta con
i numeri accanto.

</details>

### 2. ✅ Tre-cinque template di Confluence in più — chiusa in 0.1.50: non servono

`contenuto` · milestone **0.2** · Terza e ultima misura
([D-093](DECISIONS.md#d-093)): ogni proposta scritta vive dove vive — CHR_01
15/18 ai voti nell'anno singolo e le 3 fuori sono contenuto d'era misurato
vivo sulle saghe (21, 4 e 32 volte); CHR_03 17/19, con `P_SHOW_IT` a **88
voti su 20 saghe** e `P_OLD_PAGE` a 8 nella sua era; nessuno zero, e le morte
storiche di D-063 sono resuscitate col tempo delle ere. La ripetizione ha già
i suoi rimedi strutturali (biblioteca D-028, domanda consumata D-077,
contenuto d'era D-076/D-085): template in più adesso sarebbero contenuto
senza bisogno, cioè i morti di domani (D-035).

Dieci template su due saghe. Le domande che una Tensione può porre sono la parte
di contenuto che si vede di più al tavolo, ed è quella che si ripete prima.

**Aggiornato due volte dalle misure.** Prima [D-061](DECISIONS.md#d-061): metà
delle domande già scritte non veniva mai posta. Poi
[D-063](DECISIONS.md#d-063), con la sonda `run_choice_probe.gd`, che ha risposto
alle domande lasciate aperte qui sopra:

- **eligibility che non si avvera mai: zero**, in tutt'e due le saghe. Ipotesi
  chiusa.
- **il tavolo uniforme sotto-riporta**: CHR_01 passa da 13 proposte su 15 a
  **15 su 15** appena si misura col tavolo misto. La prima saga è tutta
  raggiungibile.
- **un template che CHR_03 non poteva aprire** (`CNF_ANY_SURVIVAL`, 3 proposte):
  tolto dalla lista, e adesso `validate_data.py` lo controlla.
- restano **5 proposte su 20** in CHR_03 che nessuno sceglie nemmeno a tavolo
  misto, e non è perché sono scritte male: esistono solo come cose che qualcun
  altro vuole evitare, e l'unico seggio che ne vorrebbe una non prende mai la
  parola su quella domanda.

Quindi il lavoro qui non è più «scrivere altri template»: è il diritto di
proporre (issue 1 — poi aperta come [#22](https://github.com/Tannoiser2/ECHOES/issues/22)
e **fatta in 0.1.27**, [D-069](DECISIONS.md#d-069); vedi la voce 16).

**Fatto quando** i nuovi template passano `validate_data.py`, ogni proposta è
raggiungibile in gioco (D-035: una proposta che la policy non sceglie mai è
contenuto che non esiste) e `test_balance.gd` resta in banda.

### 3. ✅ Le carte che nessuno gioca — fatta in 0.1.28: non esistono

`contenuto` · `da-misurare` · **chiusa** ([D-071](DECISIONS.md#d-071))

`cli/run_asset_probe.gd` fa il conteggio su 100 Chronicle a tavolo misto:
**la coda è vuota** — mai in una mano 0 su 48, pescate e mai spese 0 su 48. Il
sospetto era sbagliato, ed è il risultato migliore possibile: misurato, non
presunto. Nessuna carta da riscrivere né togliere. A verbale invece lo
sbilancio di circolazione fra famiglie (WEALTH 4.344 passaggi di mano contro i
~350 di FORCE e PEOPLE): non è un difetto oggi, è il numero da riguardare se
quelle famiglie sembrassero mai irrilevanti al tavolo.

<details><summary>Il testo dell'issue come era stato scritto</summary>

48 facce Asset, 132 carte. Nessuno ha mai contato quali vengono davvero
acquisite e impegnate: è esattamente la forma di problema che il progetto ha già
trovato due volte guardando un numero che nessuno guardava.

**Metà fatta in 0.1.24** ([D-063](DECISIONS.md#d-063)): `cli/run_choice_probe.gd`
fa questo conteggio per le **proposte di Confluence** e separa i tre motivi per
cui una non arriva mai ai voti. Manca la stessa cosa per gli Asset, e la lezione
da riportare è che la misura va fatta **a tavolo misto**: l'ottimizzatore da solo
dichiara morto contenuto che vivo lo è.

**Fatto quando** una sonda riporta, su 100 Chronicle, quante volte ogni Asset è
stato pescato, tenuto e impegnato — e la coda (le carte a zero) è o riscritta o
tolta, con la decisione a verbale.

</details>

### 14. ✅ L'asse dei rapporti quasi non esiste — fatta in 0.1.26

`contenuto` · `da-misurare` · **chiusa** ([D-068](DECISIONS.md#d-068))

`SET_RELATION` passa da **pesato 0 su 156** a **pesato 85 su 357** nella
seconda saga: due Conseguenze che fanno nemici (`CNS_DEBT_CALLED` e
`CNS_SEAT_CLAIMED` portano il rapporto a `HOSTILE`) e due clausole
`relation_state` a livello Triumph, **dal lato di chi vota** — la stesura con la
clausola sull'aggressore pesava zero, perché chi propone non vota, ed è a
verbale come respinta. ABSTAIN della seconda saga 74,1% → 64,9%, OPPOSE 0,9% →
7,2%. La prima saga resta a zero, con il motivo scritto in D-068.

<details><summary>Il testo dell'issue come era stato scritto</summary>

Dalla 0.1.25 il punteggio di una proposta **sa leggere** un rapporto che si
muove ([D-066](DECISIONS.md#d-066)), e continua a pesare **zero su 156**: solo
**2 Consequence su 45** muovono un rapporto, e nessun Destino in gioco nomina una
coppia. Forgiare è una delle sei azioni del gioco e non ha quasi niente su cui
mordere.

**Fatto quando** `run_stance_probe.gd` riporta `SET_RELATION` con un numero
diverso da zero nella colonna «pesato», e il modo per arrivarci è scritto a
verbale: Conseguenze che facciano nemici, e clausole `relation_state` nei Destini
al tavolo. Vedi [AUDIT_DESTINI.md](AUDIT_DESTINI.md) §2.3.

</details>

### 15. ✅ Nessuno perde mai — fatta in 0.1.26

`regola` · `da-misurare` · **chiusa** ([D-067](DECISIONS.md#d-067))

NONE passa da **1 a 5 su 400** (9 a tavolo uniforme) con i seggi bloccati fermi
a 0 su 8 e i Consigli in banda. Due pezzi, misurati uno alla volta sugli stessi
100 semi: tre `REMOVE_PRESENCE` su `$rival` attaccate a Conseguenze che la
vittima già blocca — *l'espulsione va dove il no c'è già*, la forma sulle vie
del controllo affamava Kessa ed è respinta a verbale — e la regola della porta
sbarrata: da una Regione da cui un Consiglio ti ha cacciato non si rientra
finché l'atto non gira. La sonda nuova (`run_eviction_probe.gd`) è quella che
ha trovato il vero difetto: 12 recuperi su 13, il rientro era gratis. Adesso
ogni espulsione sul Minimo caduta nell'atto III è un NONE.

<details><summary>Il testo dell'issue come era stato scritto</summary>

Su 400 risultati di seggio in 100 partite: **NONE 1**, MINIMUM 205, VICTORY 181,
TRIUMPH 13. Una scala a quattro gradini in cui il primo non succede mai e il
quarto succede nel 3% dei casi è una scala a due gradini — e il gradino che manca
è quello che dà peso a tutti gli altri. Se non puoi fallire, «Vittoria» vuol dire
solo «ho giocato».

La causa non è la taratura: **perdere non è implementato.**
`SET_ENTITY_ACTIVE` compare **zero volte in tutti i dati** — è in 7 Minimi su 8 e
niente lo può falsificare — e le 5 `REMOVE_PRESENCE` che esistono sono o
opzionali sulla `$region_focus` o costi che ci si infligge da soli. L'audit
completo, con le direzioni possibili e le trappole, sta in
[AUDIT_DESTINI.md](AUDIT_DESTINI.md).

**Fatto quando** una variante è misurata sugli stessi 100 semi di D-055 e NONE
smette di essere un livello teorico — o è scritta come respinta con i numeri
accanto.

</details>

### 16. ✅ Il diritto di proporre (#22) — fatta in 0.1.27

`regola` · `da-misurare` · **chiusa** ([D-069](DECISIONS.md#d-069))

Il proponente lo decide il posto, e il posto è di chi vuole l'esito ovvio
(D-063). L'azione che sposta la parola — `CLAIM` — esisteva e la policy non
l'ha mai giocata: cinque azioni su sei. Adesso la gioca, con quattro
moderazioni misurate una alla volta (la forma ingenua è a verbale come
respinta: fallimenti 219 → 339, mediana fuori banda, due seggi bloccati).
**Mai ai voti: 2 → 0 su 15 nella prima saga e 4 → 3 su 20 nella seconda — le
cinque proposte di D-063 votano tutte** — e il divario aggressivo/prudente
scende da 37 a 31. Lungo la strada è saltato fuori un baco vero della ripresa
(un salvataggio alla soglia perdeva il Consiglio del round), corretto con la
sua guardia.

### 17. ✅ L'indifferenza della prima saga — fatta in 0.1.29

`contenuto` · `da-misurare` · **chiusa** ([D-072](DECISIONS.md#d-072))

ABSTAIN della prima saga **71,1% → 59,9%**, sotto il criterio del 60%, con due
scene scritte col vincolo di D-070 (**le bande devono sovrapporsi**): Vaerax a
Triumph vuole la Carestia da 3 in su contro i tetti di Aldric (4) e del Popolo
(3), e l'Erede Nominato cala di 1 le Vie Interrotte — la proposta più votata
della Successione tocca Lyra e Vaerax nei due versi. Vincoli tutti fermi:
bloccati 0 su 8, banda 5,96, TRIUMPH 11 (pavimento 10), seconda saga al 48,4%.

<details><summary>Il testo dell'issue come era stato scritto</summary>

Dopo tre versioni di lavoro sugli assi ([D-066](DECISIONS.md#d-066),
[D-068](DECISIONS.md#d-068), [D-070](DECISIONS.md#d-070)) la seconda saga è
scesa dal 74,1% al **48,4%** di ABSTAIN. La prima è ferma al **71%**, e adesso
si sa perché: i suoi quattro Destini si toccano poco — Lyra e Aldric si
astengono sui Consigli dell'altro — e l'unica scena abbastanza grossa da
svegliarla, il sigillo delle gallerie conteso fra Lyra e Vaerax, è stata
misurata due volte e **respinta due volte**: fa crollare i TRIUMPH del tavolo
da 11 a 3 su 400. La lezione di D-070 è il vincolo di progetto: una scena a
Triumph regge solo se almeno uno dei due può vincerla senza spegnere il
gradino dell'altro. Due clausole mutuamente esclusive sono un pareggio a zero
scritto nei dati.

**Fatto quando** l'ABSTAIN della prima saga scende sotto il 60% a parità di
vincoli (seggi bloccati 0 su 8, banda del §7, TRIUMPH non sotto 10 su 400),
misurato con la sonda delle posizioni sugli stessi semi — e le scene nuove
rispettano il vincolo di D-070.

</details>

---

## Arte e componenti fisici

### 4. ✅ Il quarto MASTER PROMPT — fatto in 0.1.24

`arte` · `decisione` · **chiusa** ([D-065](DECISIONS.md#d-065))

Scelto il **ritratto**, che è quello che D-060 aveva già assegnato alle Casate
quando ha riscritto la regola 3. Variation key sui sei archetipi; due di quelle
righe non sono un volto, ed è per loro che il prompt dice *one subject* e non
*one face*. Lo stemma resta il ripiego dichiarato: la chiave non cambierebbe,
cambierebbe solo il prompt.

`ArtBible.keys_without_prompt()` torna vuota, e il test che contava le chiavi
scoperte è diventato la guardia che pretende che restino zero.

<details><summary>Il testo dell'issue come era stato scritto</summary>

L'export di stampa passa in rassegna ogni chiave d'arte in uso e ha trovato che
le **otto `entity.*` non hanno un MASTER PROMPT**: i tre della ART_BIBLE sono
carta Asset, carta Echo e tessera Regione, e nessuno è un ritratto
([D-056](DECISIONS.md#d-056)).

Due strade, e sono esclusive: si scrive MASTER PROMPT 4 (ritratto di Casata, con
la sua variation key per archetipo), oppure le carte Casata rinunciano
all'illustrazione e le chiavi si tolgono dai dati.

**Fatto quando** `ArtBible.keys_without_prompt()` torna vuota e
`test_print_export.test_the_keys_without_a_prompt_are_the_ones_we_know_about` è
aggiornato di conseguenza.

</details>

### 5. ✅ Un posto dove mettere l'arte vera — fatto in 0.1.21

`arte` · `motore` · **chiusa** ([D-059](DECISIONS.md#d-059))

La convenzione è il nome del file: la chiave con i punti al posto delle barre,
sotto `res://art/` (vedi [`godot/art/README.md`](../godot/art/README.md)). Se il
file c'è si disegna quello, se non c'è il segnaposto — sullo schermo,
nell'anteprima e nel foglio di stampa, che lo incorpora come `data:` URI.

Più `map.board`, il tabellone dipinto: l'unica chiave che non sta nei dati.

**Resta da fare**: consegnare le illustrazioni. Le chiavi sono 98 e i prompt
sono già scritti uno per uno in [BRIEF_ARTE.md](BRIEF_ARTE.md) — la mappa e le
sei tessere Regione sono arrivate, restano le 48 Asset, le 36 Echo e le 8
Casate — che dalla 0.1.24 hanno il loro prompt come tutte le altre
([D-065](DECISIONS.md#d-065)).

### 6. ✅ L'iconografia di sistema — fatta in 0.1.20

`arte` · `ux` · **chiusa** ([D-058](DECISIONS.md#d-058))

Dodici glifi senza colore — le sei famiglie, i quattro livelli della mappa, i due
marker — disegnati sia sullo schermo sia in stampa dallo stesso piano. La prova
del monocromatico a 16 px esce dall'export come `prova_icone.svg`, quindi si
rigenera invece di invecchiare. Il vincolo ha respinto due disegni prima di
chiudersi: FORCE era la stessa cosa del marker di Tensione, KNOWLEDGE era la
lettera A.

**Resta fuori**: i glifi delle famiglie sono sulle carte e sulla mappa, ma la
plancia azione e i paraventi non esistono ancora come pezzi, quindi non li usano.
Si aggiungeranno con loro.

### 7. ✅ Decidere il formato fisico — decisa e implementata in 0.1.54

`decisione` · milestone **0.6** · Il committente ha deciso, e l'export già
stampa così ([D-097](DECISIONS.md#d-097)): **formati diversi per ruolo** —
classiche 63×88 per Asset/Echo, tarocchi 70×120 per Destini/Casate, mini 44×68
per le Domande — **mappa unica** già fatta, **valori su token e segnalini**
(fustelle da 15 mm per saga + la traccia dei valori). Scritto in COMPONENTS §7
al posto della lista di domande, come chiedeva il «fatto quando»; restano per
la 0.6 solo tablet-contro-telefoni e scatola-contro-espansioni.

<details><summary>Il testo dell'issue come era stato scritto</summary>

La COMPONENTS §7 lascia aperte tre cose che non sono di design ma di produzione:
dimensioni carte (l'export dà per buono 63×88 mm), materiale del tabellone, tipo
di paravento. E se l'app gira su un tablet passato di mano o sui telefoni dei
giocatori — la Tensione velata funziona in entrambi i casi, il secondo costa di
più da costruire.

**Fatto quando** la scelta è scritta in COMPONENTS §7 al posto della lista di
domande.

</details>

### 8. ✅ Un PDF, non venticinque SVG — fatta in 0.1.41

`strumenti` · **chiusa in 0.1.41**: `tools/run_export.sh --pdf` produce
`echoes_print.pdf` — 26 pagine A4 esatte (210×297 mm), in ordine di consegna
(Asset, Echo, Tensioni, Destini, Casate, Regioni) via `tools/make_pdf.py`
(cairosvg + pypdf, dipendenze opzionali: servono solo a chi stampa). La CI
continua a confrontare gli SVG, che restano la sorgente diffabile.

---

### 18. ✅ I fatti eterni strozzano i Destini di seconda rotazione — fatta in 0.1.40

`contenuto` · trovata in 0.1.37 (D-082) · **chiusa in 0.1.40** ([D-085](DECISIONS.md#d-085)): le vie per disfare — riaprire la miniera (21 ere su 200), riunire la corona (4) — e il ramo del pianificatore che le insegue; la scuola risorge (6→20 Vittorie) · **il debito residuo di DST_ALDRIC_RECORD è sciolto in 0.1.51** ([D-094](DECISIONS.md#d-094)): la spirale del fallimento si chiude ri-decidendo — Vittorie 6→16, sopra il Minimo 11%→27%, e `question_unresolved` da macchia permanente (18/20 saghe) a segno vivo (5/20) · un fatto in `enduring_facts` usato
come condizione di **assenza** rende un Destino tardivo sempre più morto man
mano che la saga invecchia: la corona spezzata nell'850 blocca il Trionfo di
«Il Regno che Ricorda» per mille anni, la miniera murata fa lo stesso con la
scuola. Misurato: Vittoria di DST_ALDRIC_RECORD 2 su 97 ere, Trionfo di
DST_LYRA_TAUGHT 0-2 con la miniera murata in 17 ere trascritte su 19. Le
opzioni sono d'autore: una via per *disfare* il fatto eterno (riaprire la
miniera, riunire la corona), o Destini tardivi che chiedono presenze invece
che assenze.

### 19. Le incarnazioni del seggio: Anselmo, e poi il suo culto

`motore` · `contenuto` · voluta dal committente

Il seggio attraversa i secoli, ma oggi cambia solo il nome: Priore Anselmo,
Priora Ilaria, Priore Teodo — la stessa carta, gli stessi poteri. Il
committente vuole di più, e **per ogni seggio, non solo per Anselmo**: in
un'era si gioca *la persona o la forma presente*, in una successiva **quello
che ne nasce** — il culto dal priore (Anselmo → i frati, come Francesco → i
Francescani), la repubblica dalla dinastia, il culto assolutista della
persona dai saggi — natura diversa (MORTAL → COLLECTIVE), poteri diversi,
carta e prompt d'arte propri.

Le fasi:

1. ✅ **Lo schema** — fatta in 0.1.63 ([D-102](DECISIONS.md#d-102)):
   `incarnations` sull'Entità — ognuna con nome, descrizione, `persistence`,
   `action_values` propri, `art_prompt_key` proprio, i propri successori (i
   nomi *dentro* l'incarnazione) e la regola d'ingresso `entry`
   (`FOUNDING`/`LINE_EXHAUSTED`). Gli 8 seggi migrati con la prima
   incarnazione a specchio dei campi attuali, guardia anti-deriva nel
   validatore; il motore non le legge ancora.
2. ✅ **La successione le attraversa** — fatta in 0.1.70
   ([D-108](DECISIONS.md#d-108)): i nomi cambiano dentro un'incarnazione;
   quando la linea finisce entra la vita successiva — nome, natura, valori
   e successori propri — e il verbale d'apertura lo racconta («La linea di
   Priore Anselmo si è esaurita: al suo posto siede I Frati del Vetro»).
   Cinque seconde vite d'autore: la Repubblica della Valle, il Culto della
   Misura, la Compagnia del Sale, i Frati del Vetro, le Custodi della
   Cenere. La natura nuova (COLLECTIVE) smette di consumare eredi.
3. ✅ **Le carte** — fatta in 0.1.73 ([D-111](DECISIONS.md#d-111)): un
   tarocco per ogni vita (19 nel mazzo Casata), il pannello del seggio che
   posa la carta della vita corrente, gli 11 prompt d'arte delle vite nel
   brief, e le descrizioni di vite ed eredi nel materiale di revisione
   (661→745 testi). Il nome corrente resta nel verbale, come i re di una
   dinastia.
4. **I poteri per incarnazione**: prima leva onesta e misurabile,
   `action_values` e `persistence` propri; i poteri *nominati* («solo
   l'Ordine può…») sono design d'autore da definire insieme prima, misurare
   dopo.
5. **L'albero delle vite** — su richiesta del committente («farei molte
   più trasformazioni, ognuna con poteri asimmetrici, altrimenti sono
   nomi che cambiano su una carta»), lo studio completo per le otto case
   è in [TRASFORMAZIONI.md](TRASFORMAZIONI.md): ~17 vite con ingresso
   narrativo, potere asimmetrico e gancio tecnico dichiarati. Regola
   della casa: una vita senza dente non si scrive. **Gli ingressi sono
   fatti in 0.1.71** ([D-109](DECISIONS.md#d-109)): `ON_TAG` (la storia
   sceglie), `ON_DEATH` (il seggio sopravvive alla creatura), vite
   alternative in ordine d'autore, e il segno `life:<id>` che dà i poteri
   per vita via tag_rules — con tre vite di dimostrazione in gioco
   (l'Accademia delle Misure, il Regno di Nahr che torna mortale, il
   Culto della Montagna in attesa che qualcuno impari a uccidere un
   drago). Restano da scrivere e misurare le altre vite dell'albero, i
   tipi della voce 25 per i poteri più ambiziosi, e i tarocchi per vita.

**Fatto quando** una saga attraversa almeno un cambio d'incarnazione, con
carta e prompt propri e il passaggio nel verbale, e le sonde d'era restano in
banda.

### 20. Ampliare i pool dei Destini

`contenuto` · `da-misurare` · voluta dal committente

Due ambizioni per casa sono il minimo vitale: su ~14 rotazioni a saga, il giro
torna. Da 2 a **3-4 per casa**, con due nature: identitarie (scritte per il
seggio) e **condivisibili** — clausole con `$self`, scritte una volta e messe
nei pool di più case (il motore deve solo imparare `$self` nelle condizioni).

**Fatto quando** ogni Destino nuovo è misurato raggiungibile dove vive (D-035,
sonde esistenti), i pool sono almeno a 3, e il playtest resta 0/8 bloccati.

### 21. La mossa che spegne il tuo Destino avverta prima

`app` · nata da una partita vera (seme 15308)

Nella partita del committente, Vaerax entra nell'ultimo round con la prima
spunta accesa («La montagna è ancora sua») e la spegne **da solo**, spostando
l'ultimo token via dalle Montagne Rosse — chiude la cronaca a NONE senza che
l'app abbia detto nulla. Al tavolo fisico un compagno te lo farebbe notare;
l'app deve fare almeno altrettanto: quando l'azione scelta dal giocatore umano
farebbe passare una clausola del *suo* Destino da vera a falsa, una riga di
avviso prima di confermare («questa mossa spegne: *La montagna è ancora sua*»).
Solo per il posto proprio, solo clausole già accese, nessun suggerimento
strategico: un cartello, non un consigliere.

**Fatto quando** la mossa di quella partita, rigiocata, mostra l'avviso, e una
mossa qualsiasi che non tocca il Destino non lo mostra.

### 22. Le decisioni si devono vedere: le Conseguenze sul tavolo e a verbale

`app` · `motore` · voluta dal committente, nata dalla partita 15308

«Non si capisce quali sono le conseguenze delle decisioni prese... è tutto
quello scritto sembra non avere un vero impatto nel gioco.» Il censimento
dice che l'impatto **c'è** ma è muto: nella partita vera
`CNS_CROWN_DISPOSSESSED` ha tolto alla corona il controllo della Valle
Verde (`SET_CONTROL`) e **nessuna riga l'ha detto**; la carta *Scoperta* ha
svelato una Tensione (`SET_TENSION_VISIBILITY`) in silenzio; la Valle
Verde — il cuore della domanda del grano — non è mai apparsa nella riga
della mappa per due atti, perché contesa e senza controllore. Sui 145
effetti delle Conseguenze, 84 sono tag (regione/entità/mondo) che le
clausole leggono ma che **nessuna vista mostra**.

Le fasi:

1. ✅ **Il verbale racconta gli effetti** — fatta in 0.1.64
   ([D-103](DECISIONS.md#d-103)): `effect_narrator.gd`, una frase con i
   nomi del tavolo per ogni effetto applicato da Conseguenze, clausole
   qualificate e carta Echo d'atto («Valle Verde passa sotto il controllo
   di Re Aldric»); gli id non si leggono più, i no-op e la contabilità di
   Propp tacciono per scelta.
2. **La mappa non nasconde**: le regioni contese appaiono («Valle Verde —
   contesa»), e un cambio di controllo si vede nel momento in cui accade.
3. ✅ **I tag hanno un corpo** — fatta in 0.1.69
   ([D-107](DECISIONS.md#d-107)): il dizionario `sign_labels` (un test
   pretende una parola per ogni segno nei dati), la mappa in italiano, «I
   SEGNI DELLA CASA» nel pannello del seggio, due pagine di fustella
   (segni delle Regioni e delle case). I fatti del mondo restano nelle
   pagine della cronaca, per scelta. Trovato e riparato per strada: l'app
   non compilava dall'0.1.60 (`_draw` ombreggiata in `confluence_board`).
4. **La sonda della visibilità**: contare per 100 semi gli effetti
   applicati per tipo e verificare che ognuno abbia riga a verbale e
   rappresentazione. Un effetto invisibile è un bug, non un'atmosfera.

**Fatto quando** la partita 15308 rigiocata mostra il passaggio della
Valle Verde nel momento in cui avviene, e la sonda conta zero effetti
senza voce né corpo.

### 23. Le carte di Propp in mano ai giocatori

`regole` · `da-misurare` · voluta dal committente

«Le carte di Propp hanno veramente un impatto minimo... dovrebbero essere
molto importanti e non generate casualmente dal gioco ma giocate
effettivamente dai giocatori.» Oggi la carta Echo d'atto si pesca da sola
a fine atto e i suoi hook valgono un +1 a una Tensione e un tag: né peso
né agentività. La visione: le funzioni drammatiche come **carte in mano**,
scelte e calate dai giocatori nel momento giusto — l'ordine di Propp resta
custodito dall'eleggibilità sui tag `function:` (D-030), che già esiste.

Le fasi:

1. **Il design insieme** (d'autore, prima di ogni riga): quante in mano,
   quando si calano (a fine atto? in Consiglio?), cosa costa calarle, cosa
   succede a chi non le cala, e come pescano le sedie automatiche.
2. **Gli effetti che pesano**: hook che toccano il tavolo (presenza,
   controllo, Consigli aperti), non solo +1 — da scrivere carta per carta.
3. **Il motore**: la mano di carte Echo, l'azione di gioco, l'eleggibilità
   che custodisce l'ordine, la policy per le sedie automatiche.
4. **La misura**: stessa batteria di semi, una variante alla volta, prima e
   dopo; il vincolo resta 0/8 seggi bloccati al tavolo misto.

**Fatto quando** in una partita al tavolo misto ogni carta di Propp
arrivata sul tavolo ce l'ha messa una mano, l'ordine delle funzioni regge,
e i numeri prima/dopo sono a verbale.

### 24. Ogni segno ha un dente: la meccanica di conseguenze e cicatrici

`regole` · `da-misurare` · voluta dal committente

«Ogni conseguenza, ogni cicatrice, ogni decisione potrebbe cambiare il
meccanismo di gioco e gli effetti su entità e luoghi.» Il censimento
(sonda in `tag_census`, 0.1.65) dice dove siamo: **79 segni** scritti da
Conseguenze, cicatrici e carte Echo, di cui **27 vivi** (letti da clausole
di Destini, Conseguenze o eleggibilità), **5 vivi per il motore**
(`discovery:` contati da `discovery_count`), **2 con vita postuma** (letti
solo nella forma `legend:` dopo lo sfumare), **27 ereditati fra le ere e
narrati** ma senza alcun dente durante la partita, e **18 muti del tutto**
— fra cui `renowned` (la rinomanza dei Decisive!), `heir_named`,
`crown_dispossessed`, `grain_requisitioned`, `failed_proposal`. Due terzi
della memoria del mondo oggi non muove una regola.

Il telaio proposto — dichiarativo, come tutto il resto: un blocco
`tag_rules` nei dati che lega un segno (o un prefisso) a un gancio che il
motore conosce, così ogni regola è un dato scritto d'autore e misurabile,
non un ramo di codice:

- **modificatore d'azione in Regione**: `structure:granary` → INFLUENCE
  sulla Carestia vale +1 in quella Regione; `scar:plundered` → ACQUIRE
  lì costa un round di rilevanza;
- **modificatore al Consiglio**: `condition:starving` → i Consigli sulla
  Carestia partono con World Factor −1; `scar:unanswered` → riproporre la
  stessa domanda costa un impegno in più;
- **porta**: `settlement:march` → il passo concesso/negato (come già
  `evicted:` sbarra il rientro, D-067);
- **relazione**: `oath_broken` → la relazione fra le due case non sale
  sopra HOSTILE finché il giuramento non è rifatto.

Le fasi:

1. ✅ **Il censimento** — la classificazione qui sopra, rifatta dalla
   sonda a ogni giro.
2. ✅ **Il telaio** — fatta in 0.1.66 ([D-104](DECISIONS.md#d-104)):
   schema `tag_rule` (ACTION_MODIFIER, COUNCIL_MODIFIER, GATE,
   RELATION_CAP), i quattro ganci nel motore, la firma a verbale quando
   una regola morde, zero regole nei dati — comportamento invariato
   misurato, ogni gancio provato con regole sintetiche.
3. ✅ **I primi cinque denti** — fatta in 0.1.67
   ([D-105](DECISIONS.md#d-105)): granaio, fame, strada depredata,
   giuramento spezzato (che ora firma la coppia), fama. Accesi uno alla
   volta sui 100 semi standard, esiti a verbale, 0/8 a ogni passo; il
   Consiglio ha imparato a leggere il proponente e le Regioni.
4. **La cicatrice che morde**: ogni `scar:` con un effetto locale suo, e
   i 27 segni ereditati che diventano il ponte meccanico fra le ere.

**Fatto quando** la sonda conta zero segni di prima fila senza lettore —
o li dichiara memoria esplicitamente — e il playtest resta 0/8 seggi
bloccati al tavolo misto.

### 25. I denti che aggiungono e tolgono

`regole` · `da-misurare` · voluta dal committente

«Fanne altre che cambiano le regole o servono veramente a qualcosa,
aggiungendo o togliendo azioni, risorse, regole, asset o carte.» I quattro
ganci di D-104 piegano numeri e porte; questi aggiungono e tolgono
davvero. Tipi nuovi di tag_rule, sempre dati d'autore:

- **ACTION_GATE**: finché il segno c'è, un'azione è vietata o concessa —
  in una Regione affamata non si FORGE, chi ha il registro pubblico non
  può SCHEME di nascosto;
- **DRAW_BIAS**: la pesca piegata — nel mercato spostato la famiglia
  WEALTH pesca peggio, sotto la torre di guardia FORCE pesca meglio;
- **HAND_LIMIT**: il limite di mano che si muove — l'assedio stringe le
  mani di chi è dentro;
- **GRANT_ON_SET**: il segno che consegna o toglie una carta — chi
  costruisce il canale riceve i Diritti dell'Acqua.

Ogni tipo: prima il gancio nel motore provato con regole sintetiche, poi
le regole vere scelte col committente, accese una alla volta e misurate.

**Fatto quando** almeno un dente per tipo vive nei dati, misurato, e il
playtest resta 0/8.

### 26. Le carte con un mestiere

`contenuto` · `regole` · voluta dal committente, nata dalla domanda giusta

«Le carte impegnate servono a qualcosa o sono solo punti? Cambia solo il
nome ma l'effetto è solo numerico.» Il censimento dà ragione: **35 carte
su 48 sono solo un numero con un nome** — forza, famiglia rilevante, e
nient'altro; 7 hanno un costo (scaldano la questione); solo 6 fanno
qualcosa di vero (spostano presenze, svelano). Il Giuramento non giura,
il Magistrato non giudica, l'Assedio non assedia.

Il piano: dare a ogni carta **un mestiere** — un effetto `on_commit` che
faccia quello che il nome promette. Non 35 effetti inventati in un
pomeriggio: famiglia per famiglia, col committente, usando il vocabolario
che ora esiste (effetti + tag_rules):

1. ✅ **FORCE** — fatta in 0.1.68 ([D-106](DECISIONS.md#d-106)): la Leva
   affama, la Guardia di Confine chiude le vie, il Posto di Blocco taglia
   fuori la Regione (con cura esistente), i Mercenari lasciano
   l'inquietudine, l'Assedio affama (e il suo testo ora dice il +2 vero).
   La carta impegnata parla a verbale; misura per carta, 0/8 a ogni passo.
2. ✅ **AUTHORITY** — fatta in 0.1.74 ([D-112](DECISIONS.md#d-112)):
   l'Editto calma la piazza, il Sigillo raffredda la questione, il
   Censimento chiarisce la contesa che il Diritto di Corona posa, il
   Magistrato cancella la domanda dal muro, l'Investitura scrive l'erede
   nominato (e apre la porta della Corona Restaurata). Misura per carta,
   0/8 a ogni passo; il «riaprire una domanda chiusa» vero resta alla
   voce 25.
3. ✅ **BONDS** — fatta in 0.1.75 ([D-113](DECISIONS.md#d-113)): la
   famiglia delle cure — il Giuramento scioglie il tradimento, il Favore
   spegne la vendetta, l'Ospitalità riapre la porta sbarrata, la
   Promessa scrive un patto che le promesse giudicano, il Debito Vecchio
   segna la sede del debitore. Il Legame di Sangue aspetta la voce 25:
   il suo potere vero è un pavimento di relazione, non un numero.
4. ✅ **WEALTH / KNOWLEDGE / PEOPLE** — fatta in 0.1.76
   ([D-114](DECISIONS.md#d-114)): il grano compra e cura, il sapere svela
   e mente (la Voce vela, la Prova smentisce), la gente marcia. Il
   Credito apre la porta del Banco Nero, il Registro apre i conti, il
   Portavoce impegna promesse.

**Fatto quando** ogni carta ha un effetto che il suo nome spiega, ogni
mazzetto è misurato sui 100 semi prima di restare, e al tavolo impegnare
una carta è una scelta, non un conteggio. — ✅ **Chiusa in 0.1.76**: 46
carte su 48 lavorano; l'Archivio ha già il suo mestiere (restare in
mano) e il Legame di Sangue aspetta, dichiarato, il pavimento di
relazione della voce 25.

## Milestone 0.3 — World Propagation

### 9. ✅ La Chronicle II generata dalle evidence (#25) — fatta in 0.1.44–0.1.46

`motore` · milestone **0.3** · aperta su GitHub con il piano a fasi
([#25](https://github.com/Tannoiser2/ECHOES/issues/25)) · **Fase 1 fatta in
0.1.30** ([D-074](DECISIONS.md#d-074)): la materia prima c'è — 99 mondi
distinti su 100 — con i tre difetti del caso a verbale · **Fase 2 fatta in
0.1.31** ([D-075](DECISIONS.md#d-075)), nella forma corretta dal committente:
una saga non è una fila di primavere — 10 Chronicle coprono in mediana 1.019
anni — e adesso la memoria invecchia: quello che è murato o scritto resta un
fatto, il resto diventa `legend:<fatto>` · **Fase 3 fatta in 0.1.32**
([D-076](DECISIONS.md#d-076)): il contenuto legge le leggende — la famiglia
MEMORIA nei mazzi delle sole biblioteche, le proposte «si dice che», e la
memoria come via alle Scoperte; ogni pezzo vive nella sua era e in nessun
altra · **Pesca e Fase 4 fatte in 0.1.34** ([D-079](DECISIONS.md#d-079),
[D-080](DECISIONS.md#d-080)): la biblioteca pesca ascoltando i segni
dell'era prima (le richiamate escono il 78% contro il 67% della pesca
cieca) e l'anno-biblioteca ha la sua guardia di bilanciamento. Il piano a
fasi della #25 e' completo; il motore strutturato di generazione resta
materia della 0.3

**Il cantiere 0.3 è aperto: Fasi 0-1 fatte in 0.1.44**
([D-087](DECISIONS.md#d-087)): le evidence diventano dati (`unmet`) e la
pesca li legge — un conto rimasto aperto richiama la sua domanda (75%
contro il 67% della pesca cieca) · **Fase 2 fatta in 0.1.45**
([D-088](DECISIONS.md#d-088)): la domanda lasciata calda torna calda — sui
salti brevi le Tensioni ripescate ereditano il valore dell'era prima
(tetto a soglia−1), sui lunghi sbiadiscono; 66 domande su 720 partono più
calde, 14 più quiete · **Fase 3 fatta in 0.1.46**
([D-089](DECISIONS.md#d-089)): il verbale d'apertura — per ogni domanda
pescata il mondo registra e dice chi l'ha richiamata («La Carestia torna:
Re Aldric non l'ha mai chiusa»), in `world_state.opening_record`, nel log
del tavolo e nel digest di `run_saga`. Determinismo intatto, misurato.
In 0.1.47 il verbale copre anche la mappa
([D-090](DECISIONS.md#d-090)): chi tiene cosa, cosa è decaduto, cosa è
sbiadito, cosa è diventato leggenda.

**Fatto quando** da una Chronicle conclusa esce una Chronicle nuova con domande
scelte dalle conseguenze di quella prima, e due Chronicle in fila si giocano
senza che nessuno scriva JSON a mano. **È così**: la pesca legge segni (D-079),
conti aperti (D-087) e calore (D-088), `run_saga` incatena dieci ere senza un
JSON scritto a mano, e il verbale rende la scelta leggibile al tavolo.

### 10. ✅ Il registro delle Truth non ha una vista — fatta in 0.1.42–0.1.43

`ux` · **chiusa** ([D-086](DECISIONS.md#d-086)): `cli/run_chronicle_book.gd`
impagina un salvataggio nelle pagine A4 della cronaca (0.1.42), e a fine
Chronicle la cronaca **si vede** — `ui/chronicle_book_view.gd` si apre da
sola, sfoglia con le frecce, resta dietro il bottone «La cronaca», e
rasterizza le stesse pagine SVG che la stampa userà (0.1.43). Guardie in
`test_chronicle_book.gd`, comprese le rasterizzazioni.

---

## Debiti dichiarati

### 11. ✅ `marker_id` non è usato da nessun codice — fatta in 0.1.48

`debito` · milestone **0.5** · Delle due vie del «fatto quando», è entrata la
seconda ([D-091](DECISIONS.md#d-091)): il campo è tolto da schemi, dati e
manifest. Rientrerà col prototipo 0.5 che lo legge — i valori erano meccanici
(`MK_<id>`) e si rigenerano in un minuto, e la forma giusta del marker si
decide quando esiste il lettore.

<details><summary>Il testo dell'issue come era stato scritto</summary>

Ogni Regione, Entità, Tensione e carta Echo ha un `marker_id` nello schema e nei
dati. Nessuna riga di GDScript lo legge: esiste per il prototipo di computer
vision della 0.5.

**Fatto quando** o il prototipo lo usa, o il campo viene tolto dallo schema. Un
campo che nessuno legge è un campo che nessuno mantiene.

</details>

### 12. ✅ Il salvataggio nel browser sta in IndexedDB — fatta in 0.1.49

`debito` · `ux` · Tutt'e due le metà del «fatto quando»
([D-092](DECISIONS.md#d-092)): il menu dichiara prima di cominciare se questo
browser tiene i salvataggi (e ripete l'avviso a fine anno, quando serve), e
«Scarica il salvataggio» porta via la partita come JSON con chronicle e seme
nel nome, per la stessa via del log.

<details><summary>Il testo dell'issue come era stato scritto</summary>

Il Web export tiene `user://` in IndexedDB. La guardia c'è
(`OS.is_userfs_persistent()`), ma una partita persa perché il browser ha pulito
lo spazio è una partita persa in silenzio.

**Fatto quando** la schermata dice, prima di cominciare, se questo browser sa
tenere il salvataggio — e offre di scaricarlo quando non lo sa.

</details>

### 13. ✅ Il testo delle carte non ha una revisione editoriale — fatta in 0.1.57

`contenuto` · `debito` · **Letta tutta, su delega del committente**
([D-099](DECISIONS.md#d-099)): 357 righe corrette su 17 file — gli accenti
restaurati ovunque (ogni «e» nuda classificata a occhio su due censimenti
completi), e le regole tolte dal racconto (la velatura ora la dichiara la
carta dal dato `visibility`; le descrizioni del Risveglio e delle Vie
tornate narrativa). Il diff è la lettura: si può obiettare riga per riga.
Il tavolo di lettura resta:
[REVISIONE_TESTI.md](REVISIONE_TESTI.md), generato da
`tools/build_review.py` — 661 testi in ordine di lettura, ognuno col suo
identificativo, così una correzione si segna con una riga
(«`P_SHOW_IT`: riscrivi così…») e si riporta nei dati senza cercare. La
lettura è del committente.

305 frasi, circa 3.300 parole, due saghe (oggi: 661 testi con esiti e
presagi). Sono state scritte insieme al codice e mai rilette di fila.

**Fatto quando** qualcuno ha letto i testi dall'inizio alla fine e le correzioni
sono nei JSON.

---

## Come si aprono

Ogni voce qui sopra è già un'issue: il titolo dopo il numero, le etichette e la
milestone dalla riga sotto, il resto come corpo. Chi le apre segna il numero
GitHub accanto al titolo, così questo documento resta l'indice e non una seconda
verità.
