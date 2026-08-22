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

### 19. ✅ Le incarnazioni del seggio: Anselmo, e poi il suo culto — fatta in 0.1.63–0.1.96

`motore` · `contenuto` · voluta dal committente · **chiusa** ([D-124](DECISIONS.md#d-124)…[D-133](DECISIONS.md#d-133))

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
4. ✅ **I poteri per incarnazione** — fatta nella seduta (0.1.87–0.1.91):
   i denti pronti ([D-124](DECISIONS.md#d-124)), i cinque pezzi del telaio
   ([D-125](DECISIONS.md#d-125)), i denti veri su ogni vita
   ([D-126](DECISIONS.md#d-126)), la morte di Vaerax per via di Propp
   ([D-127](DECISIONS.md#d-127)); gli `action_values` per vita sono sapore
   dichiarato ([D-128](DECISIONS.md#d-128)) e la leva meccanica aspetta il
   lettore vero della 0.4.
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
   drago). Il **dossier di decisione per la seduta** — lo stato vero dei
   dati, una proposta concreta per vita, le domande secche — è in
   [SEDUTA_VITE.md](SEDUTA_VITE.md). **Le tre vite della decisione C sono
   scritte e misurate**: i Forni Riaccesi (0.1.92,
   [D-129](DECISIONS.md#d-129)), la Diaspora di Nahr (0.1.93,
   [D-130](DECISIONS.md#d-130)), l'Egemonia di Eredan (0.1.94,
   [D-131](DECISIONS.md#d-131)) — ognuna col suo pezzo di motore
   (l'azione che sfoga, la porta che non tiene, lo sconto sul diritto e
   il tetto verso l'egemone). Le loro porte d'ingresso in saga sono
   aperte dalla montagna delle città (0.1.95,
   [D-132](DECISIONS.md#d-132): Forni 5/20, Egemonia 11/20). **E la
   Leggenda della Montagna è scritta** (0.1.96,
   [D-133](DECISIONS.md#d-133)): il conto delle ere nei segni, il primo
   seggio senza corpo, il Destino su misura — siede 3/20 saghe, e il suo
   Minimo si perde se il sigillo cade. La seduta dedicata e il suo
   verbale sono in [SEDUTA_LEGGENDA.md](SEDUTA_LEGGENDA.md).

**Com'è finita**: tutte le vite dell'albero sono scritte, ognuna con
almeno un dente e una misura; le saghe attraversano i cambi
d'incarnazione con carta, prompt e verbale (le sonde d'era su entrambi i
tavoli in banda, NONE vivi per ogni seggio). Fuori scope dichiarati: le
illustrazioni (voce 5) e la D meccanica dei valori (a verbale per la
0.4, D-128).

**Fatto quando** una saga attraversa almeno un cambio d'incarnazione, con
carta e prompt propri e il passaggio nel verbale, e le sonde d'era restano in
banda.

### 20. ✅ Ampliare i pool dei Destini — fatta in 0.1.77

`contenuto` · `da-misurare` · **chiusa** ([D-115](DECISIONS.md#d-115))

Due ambizioni per casa sono il minimo vitale: su ~14 rotazioni a saga, il giro
torna. Da 2 a **3-4 per casa**, con due nature: identitarie (scritte per il
seggio) e **condivisibili** — clausole con `$self`, scritte una volta e messe
nei pool di più case (il motore deve solo imparare `$self` nelle condizioni).

**Fatto quando** ogni Destino nuovo è misurato raggiungibile dove vive (D-035,
sonde esistenti), i pool sono almeno a 3, e il playtest resta 0/8 bloccati.

**Com'è finita (0.1.77)**: il motore ha imparato `$self`, tre carte condivise
(*Il Nome che Pesa*, *La Terra che Risponde*, *I Conti Chiusi*) e tutti gli
otto pool a 3. La prima forma dei Conti Chiusi era regalata (chiusa da sola
100/100 al round 1) ed è stata riscritta con la fama nella Vittoria — le
misure per tavola sono in D-115; playtest identico alla base, 0/8.

### 21. ✅ La mossa che spegne il tuo Destino avverte prima — fatta in 0.1.83

`app` · nata da una partita vera (seme 15308) · **chiusa** ([D-120](DECISIONS.md#d-120))

L'avviso vive nel `SeatDecider` (uno solo per terminale e browser, D-038):
l'anteprima è una sessione ricostruita dal salvataggio — stesso mondo,
stesso dado, previsione esatta, nessun ramo di regole duplicato — e tre
test la inchiodano: la mossa nella forma del 15308 avverte nominando la
clausola, il ripensamento torna al menu, una mossa neutra passa in silenzio.

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

### 22. ✅ Le decisioni si devono vedere — fatta in 0.1.64–0.1.84

`app` · `motore` · voluta dal committente, nata dalla partita 15308 · **chiusa** ([D-103](DECISIONS.md#d-103), [D-107](DECISIONS.md#d-107), [D-121](DECISIONS.md#d-121))

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
2. ✅ **La mappa non nasconde** — fatta in 0.1.84
   ([D-121](DECISIONS.md#d-121)): una Regione segnata si vede anche senza
   presidi né controllore — la riga «Sulla mappa» del seggio dice i segni
   con le parole di D-107 («Valle Verde (contesa)»), e il cambio di
   controllo ha la sua frase nel momento in cui accade (D-103, e da
   0.1.84 anche il placarsi della questione e la rivelazione del
   presagio).
3. ✅ **I tag hanno un corpo** — fatta in 0.1.69
   ([D-107](DECISIONS.md#d-107)): il dizionario `sign_labels` (un test
   pretende una parola per ogni segno nei dati), la mappa in italiano, «I
   SEGNI DELLA CASA» nel pannello del seggio, due pagine di fustella
   (segni delle Regioni e delle case). I fatti del mondo restano nelle
   pagine della cronaca, per scelta. Trovato e riparato per strada: l'app
   non compilava dall'0.1.60 (`_draw` ombreggiata in `confluence_board`).
4. ✅ **La sonda della visibilità** — fatta in 0.1.84
   ([D-121](DECISIONS.md#d-121)): `cli/run_visibility_probe.gd`, 100 semi
   a tavolo misto, ogni effetto del registro o ha la sua frase a verbale
   o un silenzio dichiarato. Ha trovato quattro silenzi veri — il
   placarsi della questione decisa, la rivelazione del presagio, gli
   scarti del CLAIM e dell'INFLUENCE, i falsi passaggi di controllo — e
   adesso conta **SENZA VOCE: 0**.

**Fatto quando** la partita 15308 rigiocata mostra il passaggio della
Valle Verde nel momento in cui avviene, e la sonda conta zero effetti
senza voce né corpo.

### 23. ✅ Le carte di Propp in mano ai giocatori — fatta in 0.1.80–0.1.82

`regole` · `da-misurare` · voluta dal committente · **chiusa** ([D-118](DECISIONS.md#d-118), [D-119](DECISIONS.md#d-119))

«Le carte di Propp hanno veramente un impatto minimo... dovrebbero essere
molto importanti e non generate casualmente dal gioco ma giocate
effettivamente dai giocatori.» Oggi la carta Echo d'atto si pesca da sola
a fine atto e i suoi hook valgono un +1 a una Tensione e un tag: né peso
né agentività. La visione: le funzioni drammatiche come **carte in mano**,
scelte e calate dai giocatori nel momento giusto — l'ordine di Propp resta
custodito dall'eleggibilità sui tag `function:` (D-030), che già esiste.

Le fasi:

1. ✅ **Il design insieme** — deciso dal committente in 0.1.80 (D-118):
   2 carte a testa per atto, si calano nel proprio turno come azione,
   costano una carta Asset, e se nessuno cala l'atto resta senza carta.
2. ✅ **Gli effetti che pesano** — fatta in 0.1.82 ([D-119](DECISIONS.md#d-119)):
   carta per carta, tutte e due le saghe. Presenza (la Perdita, la Crepa,
   la Veglia Spostata, il Pozzo Zitto, l'Offerta), controllo (i Fuochi
   Fuori), Consigli prescritti (la Supplica, il Tradimento, la Sedia
   Vuota, la Chiamata, Due Sentenze, il Giorno che la Gilda Chiese Tutto),
   segni con lettori veri (scoperte, fama, granaio, canale, fame, coppie).
   Una forma respinta coi numeri: il controllo tolto gratis bloccava
   Aldric — il titolo si perde a un Consiglio, non per un'assenza. E il
   punteggio delle sedie adesso legge le carte con i binding con cui
   verranno compilate, Conseguenze comprese.
3. ✅ **Il motore** — fatto in 0.1.80 (D-118): `echo_hand`, azione
   PLAY_ECHO, eleggibilità al momento di calare, sedie con freno (una per
   atto) e filtro (solo se serve al Destino). **La GUI** è arrivata in
   0.1.81: la mano si vede nell'app (spenta quando non calabile, col
   motivo), e il bottone per calare era già lì — stesso SeatDecider del
   terminale (D-038).
4. ✅ **La misura** — in D-118: due forme respinte coi numeri, la terza
   dà 190·88·120·176 con **0/8** e ere in banda. In D-119, con gli
   effetti pesanti: **184·75·129·177, 0/8**, Consigli 5,65 (mediana 6),
   ere in banda — e il difetto trovato per strada (i Consigli chiusi non
   stavano nel salvataggio) riparato con il suo test.

**Fatto quando** in una partita al tavolo misto ogni carta di Propp
arrivata sul tavolo ce l'ha messa una mano, l'ordine delle funzioni regge,
e i numeri prima/dopo sono a verbale.

### 24. ✅ Ogni segno ha un dente — fatta in 0.1.65–0.1.85

`regole` · `da-misurare` · voluta dal committente · **chiusa** ([D-104](DECISIONS.md#d-104), [D-105](DECISIONS.md#d-105), [D-122](DECISIONS.md#d-122))

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
4. ✅ **La cicatrice che morde** — fatta in 0.1.85
   ([D-122](DECISIONS.md#d-122)): undici regole nuove coi tipi del telaio
   — tre pesi del Consiglio sulle cicatrici delle domande, tre pesche
   guaste, tre pesche buone sulle strutture, la ferita che parla, e il
   pavimento del PACT (che il censimento ha rivelato essere un tag di
   relazione). Le cicatrici non si curano: sono il ponte meccanico fra
   le ere. Per i segni il cui gemello vivo morde già, la **memoria
   dichiarata** sta nella sonda, col motivo accanto. Censimento: vivi
   34 → 46, prima fila senza lettore **0**, muti senza dichiarazione
   **0**.

**Fatto quando** la sonda conta zero segni di prima fila senza lettore —
o li dichiara memoria esplicitamente — e il playtest resta 0/8 seggi
bloccati al tavolo misto.

### 25. ✅ I denti che aggiungono e tolgono — fatta in 0.1.78/0.1.79

`regole` · `da-misurare` · **chiusa** ([D-116](DECISIONS.md#d-116), [D-117](DECISIONS.md#d-117))

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

**Fase 1 ✅ — i ganci** — fatta in 0.1.78 ([D-116](DECISIONS.md#d-116)):
i quattro tipi più il **RELATION_FLOOR** (il pavimento che il Legame di
Sangue aspetta da D-113), ciascuno provato con regole sintetiche, playtest
identico byte per byte con zero regole accese.

**Fase 2 ✅ — i denti veri** — fatta in 0.1.79 ([D-117](DECISIONS.md#d-117)):
un dente per tipo su segni che il gioco già produce — i patti vietati dalla
fame, il debito che guasta il mercato, la fame che stringe la mano, il
canale che consegna il grano, e il **sangue col suo pavimento**: il Legame
di Sangue ha il suo mestiere e le carte sono 48/48. Misura a passi, 0/8 a
ogni passo.

**Fatto quando** almeno un dente per tipo vive nei dati, misurato, e il
playtest resta 0/8. ✓

### 26. ✅ Le carte con un mestiere — chiusa in 0.1.76, riverificata in 0.1.177

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
   segna la sede del debitore. Il Legame di Sangue aspettava la voce 25:
   il suo pavimento di relazione è arrivato in 0.1.79 (D-117) — 48/48.
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

**Ricontata in 0.1.177**, perché l'indice non portava la spunta e la voce
risultava aperta a chi leggeva solo il titolo: **47 su 48** hanno un
`on_commit_effects`. Il Legame di Sangue nel frattempo ha ricevuto il suo, e
l'unica senza è `AST_KNOWLEDGE_ARCHIVE` — che il mestiere ce l'ha, ed è restare
in mano. Il numero che apre questa voce («35 su 48 sono solo un numero») è
vecchio di cento versioni: non ricopiarlo.

### 29. ✅ La stanza non aveva più il bottone «Si comincia» — fatta in 0.1.103

`app` · **chiusa** ([D-140](DECISIONS.md#d-140)) · trovata dal committente

«Le azioni nell'interfaccia non si vedevano più.» La stanza si apriva,
mostrava gli indirizzi e i QR, e non aveva niente da premere: in 0.1.100,
estraendo `_qr_for`, il blocco del bottone era finito dopo il `return` della
funzione nuova. Codice legale, mai eseguito, nessun avviso.

Nessuna misura poteva prenderlo: la suite prova quello che il codice *fa*, il
playtest gira headless e non passa per una lobby, la sonda delle viste
perquisisce i modelli e non i figli di un contenitore. Il rimedio non è un
test sulla stanza ma `tools/dead_code.py` nella CI, che legge tutti i `.gd` e
segnala ogni istruzione irraggiungibile.

**Fatto quando** la stanza si apre e si può cominciare, e un `return` seguito
da codice fa rossa la CI. ✓

### 30. ✅ La console vista su un telefono vero — fatta in 0.1.105

`app` · **chiusa** ([D-143](DECISIONS.md#d-143)) · nata da una domanda del committente

«Puoi farmi uno screenshot di quello che si vede sugli smartphone?» La console
era **misurata** ma non **guardata**: la sonda delle viste perquisiva i
modelli, quella dei messaggi contava le fughe, il filo era trasparente byte per
byte — e nessuno aveva mai visto la pagina su uno schermo da telefono.

Due difetti, nessuno dei quali le tre misure potevano prendere (guardavano il
contenuto, non la forma): il tabellone a caratteri del terminale finiva sul
telefono, ridondante rispetto alle sezioni che la console disegna già dallo
`state`; e con ventidue azioni legali le ultime stavano sotto il bordo di un
riquadro che scorre, senza che niente lo dicesse.

Per fotografarlo è nato `cli/run_room.gd`, la stanza senza schermo — che resta
utile da sola: si prova la console da un altro apparecchio senza aprire una
finestra.

**Fatto quando** la console è stata guardata su uno schermo da telefono e quello
che c'era da correggere è corretto. ✓ (17.509 messaggi, 0 fughe; playtest 0/8)

### 31. ✅ Le carte come carte sul telefono, e la vetrina che leggeva le mani — fatta in 0.1.106

`app` · **chiusa** ([D-144](DECISIONS.md#d-144)) · nata da una domanda del committente

«E le carte e i tarocchi? Si vedono?» Sull'app sì, e dal 0.1.59 sono la carta
stampata (D-101). Sul telefono no: la mano era una fila di etichette — il
principio rispettato ovunque tranne nel posto che conta di più, perché il
telefono *è* la mano del giocatore.

Adesso l'host serve `/carta/<mazzo>/<id>.svg` da `PrintSheet.card_svg`, la
stessa funzione che impagina la fustella: una carta che cambia nei dati cambia
in tutti e tre i posti insieme.

**E le facce hanno fatto vedere una fuga vera**, presente da 0.1.99: la vetrina
mostrava come «il mondo ha calato» tutto ciò che il mazzo aveva lasciato —
comprese le carte del Narratore **ancora in mano** ai seggi. Nessuna misura
poteva prenderla: la perquisizione guarda i messaggi verso le console, che
hanno un viewer, e la vetrina non ne ha — il pezzo senza segreti era il pezzo
senza guardia. Ora ce l'ha (`Protocol.audit_table`), con un test che pianta una
fuga apposta per provare che morda.

**Fatto quando** la mano sul telefono è fatta di carte, la vetrina mostra solo
le carte calate, e una guardia lo prova. ✓ (20.844 messaggi perquisiti, 0 fughe)

### 32. ✅ Il tabellone disegnato sulla vetrina, e le carte giocate — fatta in 0.1.107

`app` · **chiusa** ([D-145](DECISIONS.md#d-145)) · nata da una domanda del committente

«Ma la mappa? I token, le pedine e le carte giocate?» Sulla vetrina la mappa era
raccontata invece che disegnata — una griglia di riquadri — e le pedine e i
vessilli di D-138 vivevano solo sul canvas di Godot, cioè sull'unico schermo che
al tavolo nessuno guarda da vicino. Le carte impegnate in Consiglio non c'erano
affatto.

`board_sheet.gd` non ridisegna niente: rilegge gli stessi piani (`RegionArt`,
`IconSet`, i colori per ordine di turno) e li scrive in SVG. È la disciplina di
D-097 estesa a una terza superficie: una forma sola, tre usi — canvas, fustella,
browser.

Le carte impegnate arrivano dai Consigli **chiusi**, con una guardia che
impedisce a una seduta ancora aperta di finire in tavola: gli impegni sono
coperti finché non si rivelano.

**Fatto quando** la vetrina mostra una mappa con le pedine e le carte giocate, e
nessun impegno ancora coperto. ✓ (20.844 messaggi perquisiti, 0 fughe)

### 33. ✅ Muovere i pezzi dal telefono, e le schede — fatta in 0.1.108

`app` · **chiusa** ([D-146](DECISIONS.md#d-146)) · voluta dal committente

«Come si fa a muovere i pezzi sulla mappa dagli smartphone? Si apre una mini
mappa? …potresti fare delle schede invece di mettere tutto insieme, e in
orizzontale si razionalizza meglio.»

Tutte e tre giuste. E la prima aveva già la risposta nei dati: i `subjects`
arrivavano al telefono da sempre — ogni scelta che riguarda una Regione porta
con sé quale — e nessuno li guardava; la console ne faceva un bottone con
scritto «Metti una presenza in Eredan».

Ora la mappa è quella vera (`/mappa.svg`), presa inline per poterla toccare: le
Regioni offerte si accendono e il dito risponde lì, e quelle scelte spariscono
dai bottoni. Tre schede (Mappa · Mano · Seggio) con un pallino su quella che ha
qualcosa. Coricato, il telefono affianca le schede alla domanda invece di
impilarle.

**Fatto quando** una presenza si mette toccando la Regione, le schede separano
mappa/mano/seggio, e il telefono coricato non chiede di scorrere. ✓

### 34. ✅ Quanti giocatori, e i bot messi alla prova — fatta in 0.1.109

`app` · `regole` · **chiusa** ([D-147](DECISIONS.md#d-147)) · nata da tre domande del committente

«Si può scegliere il numero di giocatori? O si deve giocare per forza in
quattro? Funzionano i bot?»

**I seggi sono quattro e non è un'impostazione**: ogni Chronicle dichiara le sue
quattro case, e domande, relazioni, Destini e proposizioni sono scritti per
quelle voci. Un tavolo a tre o a cinque è un'altra Chronicle da scrivere.

**Quante di quelle voci siano persone è sempre stato libero** — la riga di
comando lo sa da 0.0, la stanza lo decide da chi si collega — tranne nel menu
dell'app, che chiedeva quale seggio prendi e basta. Ora chiede anche chi altro
gioca da quello schermo.

**«Funzionano i bot?» era senza misura da otto versioni.** Il playtest confronta
tavoli, dando per scontato che i giocatori giochino; nessuno aveva mai chiesto
ai bot di battere qualcosa. `run_bot_probe.gd` li mette contro il caso sullo
stesso mondo: la policy fa meglio in **26 partite su 40**, e soprattutto il caso
manca il Destino minimo in **20 partite su 40** mentre la policy non lo manca
mai.

**Fatto quando** il menu chiede quanti giocano, e una misura dice se i bot
giocano davvero. ✓

### 36. Linee sempre diverse: pool di Destini, ruoli, generatore

`contenuto` · `regole` · voluta dal committente · **in seduta** ([SEDUTA_LINEE.md](SEDUTA_LINEE.md))

«Io andrei oltre, farei un sistema che combina e permuta per ottenere linee
sempre diverse, un randomizzatore di obiettivi, entità e incarnazioni che
cambiano a ogni partita.»

Metà del principio **esiste già**: le domande si pescano da una biblioteca —
da 0.1.175 anche all'**anno d'apertura** ([D-207](DECISIONS.md#d-207)), quindi
`tension_pool` sta su tutte e quattro le Chronicle e non più solo su CHR_02 e
CHR_04 — le vite scattano su tag invece che da una lista, e i caratteri di D-053
si permutano fra i seggi. E da [D-197](DECISIONS.md#d-197) **anche cosa vuole
ciascuna casa si pesca**: quattro obiettivi da un pool di dodici condivisi.

**Quello che non cambia mai sono le quattro case della linea**, e il fatto che
una saga resti dentro la propria linea per tutti i suoi secoli: nessuna partita
pesca la Sete sulla mappa delle Città Libere. Le due biblioteche restano due, ed
è quello il residuo vero di questa voce.

Il metro per dire se una strada ha funzionato adesso esiste — `run_variety_probe`
misura la **distanza fra due saghe** (0,86 oggi) e, da 0.1.175, le **mani
d'apertura diverse** e la **distanza al primo anno**. Il dossier diceva «oggi non
sapremmo misurare se ha funzionato»: adesso si saprebbe.

Il dossier misura le quattro strade e i loro prezzi: **A** il pool dei Destini
(2–3 per casa, come le domande — poco motore, molta scrittura, e probabile
cura per ISSUES 35); **B** i ruoli staccati dalle case (combinatoria vera, ma
la prosa diventa generica: è un compromesso di gusto, non tecnico); **C** il
generatore di linee (rischio rumore: questo gioco è fatto di frasi che
qualcuno ha scritto); **D** più vite per casa con ingressi più fini (solo
scrittura, nessun rischio).

Dichiarato nel dossier: **oggi non sapremmo misurare se ha funzionato**. Le
sonde misuravano il motore, e «le partite sono diverse fra loro?» non è
FAIL 185 · 0/8. Serviva la **distanza fra due saghe** — che nel frattempo è
stata scritta ([D-149](DECISIONS.md#d-149)) e in 0.1.175 ha imparato a guardare
anche l'apertura. Questa mezza obiezione è caduta: il metro c'è.

**Fatto quando** il committente ha risposto alle cinque domande secche e la
strada scelta è stata percorsa e misurata.

### 35. Le istituzioni **non** governano diversamente dalle persone

`contenuto` · **chiusa in 0.1.144** · [SAGA_SALE.md](SAGA_SALE.md) → [D-176](DECISIONS.md#d-176)

La voce nasceva da una forma vista nella saga del Sale: finché sedevano
**persone** c'erano Vittorie e due Trionfi; dal 1981, con le **istituzioni** al
tavolo, sedici Destini su venti finivano al Minimo. L'ipotesi era che le
istituzioni governassero bene e non volessero niente.

**Misurata come la voce chiedeva** — dodici saghe da dieci Chronicle a tavolo
misto, livelli contati per incarnazione — l'ipotesi è **falsa**:

| | supera il Minimo |
|---|---|
| **le otto istituzioni** | **41%** |
| **le quindici persone** | **42%** |

Un punto di differenza. Chi siede non c'entra niente.

**Quello che c'entra è la casa.** La distanza vera è dentro le due categorie, non
fra loro:

| | |
|---|---|
| La Compagnia del Sale | **68%** |
| Il Banco Nero | 64% |
| Maestra Ilve / Sadin / Ordan | **67%** |
| … | |
| L'Egemonia di Eredan | 31% |
| Kessa dei Fuochi | 17% |
| **Le Custodi della Cenere** | **14%** |
| **Neve dei Fuochi** | **8%** |

Un'istituzione al 68% e una al 14% sono lontane fra loro quanto le due persone
agli estremi. E la linea che va male va male **con chiunque la porti**: i cinque
volti dei Fuochi stanno fra l'8% e il 46%, i cinque Maestri fra il 46% e il 67%.

**Non è un problema delle vite tardive: è il Destino di una casa.** La linea
della Cenere/Fuochi è debole in ogni sua incarnazione, ed è lì che va guardata —
non nelle istituzioni.

**La voce nuova è stata aperta** come la 45 qui sotto, e la sua metà strutturale
è chiusa in 0.1.145 ([D-177](DECISIONS.md#d-177)): la Cenere non arrivava meno in
alto perché fosse debole, ma perché il suo Destino le chiedeva due cose che con
tre gettoni non stanno insieme.

### 28. ✅ Le alleanze devono pesare al Consiglio — fatta in 0.1.102

`regole` · voluta dal committente · **chiusa** ([D-139](DECISIONS.md#d-139))

«Le alleanze dovrebbero pesare e influenzare di più.» La domanda è nata
guardando le relazioni fra entità: servivano già a molto — chi propone con
chi, chi eredita, cosa dicono i segni, come si sciolgono i patti — ma **nel
momento del voto non contavano nulla**. Al Consiglio un alleato giurato e
uno sconosciuto avevano la stessa voce.

Adesso un seggio legato al proponente che lo **sostiene**, e che ha
**impegnato almeno due carte**, porta un peso in più sul fronte (ALLY +1,
BOUND +2, tetto 2), firmato a verbale. La regola vive nella Chronicle
(`confluence_rules.alliance_weight`): una Chronicle può avere un Consiglio
dove i legami pesano di più, o per niente, senza toccare il codice.

Due forme prima di questa, scritte e misurate e scartate, **entrambe con un
seggio bloccato su un livello solo**: la simmetrica (il nemico frena quanto
l'alleato spinge — FAIL 210, perché il tavolo di partenza ha ostilità e non
ha alleanze) e quella gratis (FAIL 187, Kessa dei Fuochi bloccata per un
solo tiro). Chiedere due carte non ha ammorbidito il dente: l'ha reso raro e
voluto.

**Fatto quando** un'alleanza cambia l'esito di un Consiglio, il verbale lo
dice, e il playtest resta 0/8. ✓ (FAIL 185, 0/8)

### 27. Il tavolo sullo schermo grande, le console in tasca

`app` · `motore` · milestone **0.6** · voluta dal committente

«La mappa e le indicazioni delle carte giocate restino sul computer (o
iPad), e i giocatori possano usare gli smartphone come console dove avere
le indicazioni segrete, le carte in mano e tutte le informazioni di
gioco.» È la seconda delle due strade che COMPONENTS §7 aveva lasciato
aperte (il tablet passato di mano, o i telefoni dei giocatori) — quella
che costa di più da costruire, e quella per cui la Tensione velata è
stata disegnata.

**La metà difficile è già fatta.** Tutto il codice disegna *per viewer*:
`visible_tension_value(tension_id, viewer)` (§11.1), la mappa e il
pannello prendono `render(session, viewer_id)`, il Destino lo vede solo
chi lo giura (D-101), e il `SeatDecider` separa il *cosa si può fare*
dal *come si mostra* con l'`io` iniettato (D-038) — un oggetto con
`say` e `choose`, oggi il terminale o lo schermo del browser, domani il
telefono di un seggio. Le viste console esistono già come pezzi: il
pannello del seggio, la mano, le domande del decider.

**Quello che manca:**

1. ✅ **Le due viste dallo stesso mondo** — fatta in 0.1.97
   ([D-134](DECISIONS.md#d-134)): `TableModel`/`ConsoleModel` (i futuri
   messaggi di rete, filtrati alla costruzione), la vetrina con
   l'ispezione (la C della seduta), la console col `say`, il cavalletto
   `dev_split.tscn`, e la sonda delle viste che perquisisce i modelli
   serializzati. Playtest identico byte per byte.
2. ✅ **Il trasporto** — fatto in 0.1.98 ([D-135](DECISIONS.md#d-135)):
   l'host WebSocket coi token, l'`io` remoto a segnali, l'instradamento
   per seggio nel decider. Misurato nel modo più duro: la stessa partita
   con due console vere è **identica byte per byte** a quella senza rete.
3. ✅ **La disciplina dei segreti sul filo** — fatta in 0.1.98: la
   perquisizione è nel protocollo, strutturale sulle mani (le carte
   hanno copie: il segreto è *quali copie tieni*, non il titolo) —
   su 100 partite, **21.109 messaggi e zero fughe**.
4. ✅ **Il rientro** — fatto in 0.1.98/0.1.99: il token nel telefono, la
   posta per le console assenti, la domanda in sospeso riproposta, la
   riconnessione automatica della pagina. E in più (fase 3,
   [D-136](DECISIONS.md#d-136)): le pagine console e tavolo, la stanza
   dal menu, la diagnosi della rete. Il QR è fatto in 0.1.100
   ([D-137](DECISIONS.md#d-137)); **`web/` negli export impacchettati** è
   fatto in 0.1.104 ([D-141](DECISIONS.md#d-141)), insieme all'app macOS da
   scaricare — senza `include_filter` l'app si costruiva e serviva una
   pagina vuota ai telefoni. Resta dichiarata: la console di riserva piena
   (il seggio ripreso dallo schermo grande quando un telefono è perso).

**Fatto quando** una partita si gioca con la mappa sul computer e due
telefoni come console, le informazioni segrete arrivano solo al loro
seggio (la Tensione velata funziona come al tavolo fisico), un telefono
riavviato rientra senza perdere niente, e le sim restano deterministiche
— il motore non deve accorgersi di quanti schermi lo guardano.

Il **dossier di decisione per la seduta** — architettura host+console,
la disciplina dei segreti sul filo, l'accoppiamento col QR, le fasi coi
loro «fatto quando» e i rischi onesti delle reti di casa — è in
[SEDUTA_TAVOLO.md](SEDUTA_TAVOLO.md).

---

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

### 37. La mappa si muove — ma `ACT_CLAIM` muore in mano tre volte su quattro

`regole` · **metà chiusa in 0.1.121, metà aperta** · [D-152](DECISIONS.md#d-152) → [D-158](DECISIONS.md#d-158) → [D-175](DECISIONS.md#d-175)

**La prima metà è chiusa.** La voce nasceva da un tabellone che a fine anno era
quasi quello d'inizio: 44% di caselle senza padrone, una casa che guadagnava in
media un quarto di Regione, il Vetro a zero in trenta partite. Da quando il
padrone **si conta invece di scriverlo** ([D-158](DECISIONS.md#d-158) — pedine
più il valore delle strutture, ricalcolato a ogni fine round) la mappa si muove
da sola, senza bisogno che un Consiglio la muova:

| | allora | ora |
|---|---|---|
| caselle con un padrone | 56% | **82%** |
| seggi a **zero** Regioni | 30% | **11%** |
| seggi a **due** Regioni | 12% | **31%** |

**La seconda metà è aperta, ed è più stretta di come era scritta.** Non è che
manchi un modo di prendere una Regione: è che **l'azione fatta apposta non
funziona**. Su 80 Chronicle: **128 rivendicazioni aperte, 18 forzate, 110 morte
senza essere usate.** Tre su quattro si pagano — un Asset AUTORITÀ e
un'Opportunità — e non si spendono mai.

Il punto di rottura ha un nome, ed è una **regola del regolamento**, non un
difetto del codice: §10 vuole che il Claim sia stato posato **in un round
precedente**. Chi rivendica deve quindi indovinare, un round prima, che quella
domanda sarà matura *e* che nessun altro avrà già forzato un Consiglio *e* di
avere ancora un secondo AUTORITÀ in mano.

**La decisione è arrivata** (0.1.159, [D-191](DECISIONS.md#d-191)): il committente
ha scelto «**l'innesco lo apre un giocatore**», e la strada più piccola è stata
presa — se la Tensione è **già** a 3 o più, CREATE e FORCE avvengono nella stessa
azione: non si prenota una domanda che è già matura. Sta nella Chronicle
(`claim_rules.same_round_when_ready`), quindi il §10 di sempre resta provato e
riaccendibile.

Il collo di bottiglia si è spostato due volte, e ogni volta è stato misurato: la
**regola** (153 intenzioni su 153 ora legali), le **carte** (il modo fissato su
due CREATE e due FORCE — liberato), la **cautela del bot** (D-069 proteggeva una
prenotazione che non c'è più).

| su CHR_01, 40 partite | prima | dopo |
|---|---|---|
| prenotazioni aperte | 73 | **27** |
| riscosse | 16 | **16** |
| **morte in mano** | 57 (**78%**) | **11 (41%)** |

**E poi la domanda ha cambiato forma, come questa voce aveva previsto.** Con il
cancello del tavolo ([D-203](DECISIONS.md#d-203)) RIVENDICARE è diventata l'unico
modo che un giocatore ha di aprire un Consiglio *quando vuole lui* — e allora la
prima domanda non è più quante prenotazioni muoiono, ma **chi ha mai avuto in
mano il diritto di chiamare**. Misurato in 0.1.172
([D-204](DECISIONS.md#d-204)): **la Cenere zero volte in venti partite**, il
Vaerax una ogni quattro, perché le 4 carte RIVENDICARE erano tutte AUTORITÀ e
l'AUTORITÀ si pesca solo da due Regioni. Ora sono **otto carte in cinque
famiglie** e ogni Regione ne pesca almeno una: Cenere a 1,05 e Vaerax a 1,50, con
lo scarto fra la casa più servita e la meno servita che passa da **infinito a 3,1
volte**.

**Resta aperta la metà vecchia.** Il criterio chiede le morte **sotto una su
tre**: siamo al **56%** (era 67% col cancello acceso e prima del rimedio; era 41%
in 0.1.159, quando i Consigli erano sei l'anno invece di quattro — con meno
Consigli una prenotazione ha meno occasioni di essere riscossa). Due strade più
aggressive erano già state provate e **respinte coi numeri** (togliere del tutto
la prenotazione azzera anche le prenotazioni e costa 13 Consigli falliti;
bloccare il ripiego costa 19).

**Fatto quando** le rivendicazioni morte scendono sotto una su tre — o quando
ISSUES 49 arriva e questa azione diventa quella che gira i mucchi coperti, e
allora la domanda cambia forma.

*Misura di 0.1.147, per il confronto di domani: **128 aperte, 17 forzate, 111
morte** su 80 Chronicle — la proporzione non si è mossa, ed è scritta anche in
[MECCANICA §15](MECCANICA.md), fra le nove cose che i numeri dicono a chi gioca.*

### 38. ✅ La Vittoria della Cenere ha una porta sola — fatta in 0.1.122

`contenuto` · nata dalla misura respinta di [D-152](DECISIONS.md#d-152)

La vittoria di `DST_CENERE` ha due clausole: «controllo di almeno 2 Regioni» e
«le gallerie non sono state murate». La seconda e' quasi sempre vera, quindi la
prima e' **l'unica porta** — e regge anche il Trionfo che sta sopra, perche' i
livelli sono cumulativi.

Si vede togliendola: abbassando la soglia a 1, Kessa dei Fuochi passa da
**1/44/5/0** a **1/0/19/30** su cinquanta partite. Zero Minimi. Non e' un
gradino che si abbassa, sono due che si aprono insieme.

Quindi la soglia e' rimasta a 2, e il lavoro vero e' un altro: **scrivere una
seconda clausola con dei denti** per quella Vittoria — qualcosa che la Cenere
debba fare e che non sia gia' vero per conto suo. E' contenuto d'autore, non
taratura.

**Fatto quando** la nuova clausola esiste e, con la soglia a 1, Kessa resta
sotto i dieci Trionfi su cinquanta con almeno dieci Minimi.

**Fatta** ([D-156](DECISIONS.md#d-156)). Sedici clausole candidate misurate su 40
Chronicle prima di sceglierne una: sette valevano il **100%** — fra cui
`control_count >= 1`, che e' la ragione per cui abbassare la soglia le regalava
la Vittoria — e l'unica davvero contesa era **la veglia sulla montagna, al 45%**.
La Vittoria adesso e' «**Chi scava lo dicono loro**» e chiede la veglia; il
controllo di due Regioni e' **salito al Trionfo**, dove il suo 12% e' una virtu'
invece che un muro. Kessa passa da **1/44/5/0** a **0/18/31/1**, tavolo misto
**0/8**, e il gioco intero supera il Minimo il **54%** invece del 48%.

---

### 39. La terra che si vede: pedine di carta, o strutture con una vita

`contenuto` · `regole` · voluta dal committente · **in seduta**
([SEDUTA_TERRA.md](SEDUTA_TERRA.md)) · nata da [D-154](DECISIONS.md#d-154)

Tre idee del committente sono la stessa domanda vista da tre lati: **come si
rende visibile, costoso e duraturo il possesso di un luogo?** Il dossier mette
le tre strade accanto — **A** le carte che posano una pedina, **B** la carta che
*e'* la presenza, **C** le strutture con una vita (torre → castello → reggia, e
la rovina) — coi prezzi e i numeri. Raccomandata **C**, dopo aver aperto
ISSUES 38.

**E sono poche, contate bene meno di quanto sembri** (osservazione del
committente): quattro costruzioni vere — granaio, canale, pedaggio, torre di
veglia — piu' `structure:sealed`, che non e' un edificio ma **il contrario** di
un edificio, e due insediamenti in una famiglia parallela quasi inutilizzata.
**Zero luoghi naturali**, e sei biomi che non hanno niente che li distingua. Il
catalogo sta in [SEDUTA_TERRA §8](SEDUTA_TERRA.md): da cinque tag a una ventina
di cose, divise in **due nature** — le opere delle case, che hanno un padrone e
un valore nella contesa del controllo, e **i luoghi del mondo** (foreste, passi,
fiumi, siti antichi) che non sono di nessuno e cambiano cosa vale una Regione
senza cambiare chi la tiene.

Il fatto che le da' ragione: **le strutture funzionano gia' meglio della
presenza.** Su 30 Chronicle se ne alzano **74** (2,5 a partita, 2 in piedi a
fine anno, 29 partite su 30 ne hanno almeno una) contro **poco piu' di una
pedina** mossa per scelta. E il difetto si vede a occhio: **74 costruite, zero
abbattute**, e visto che `structure:` attraversa le Chronicle senza sbiadire, in
una saga la mappa **puo' solo riempirsi**.

Quello che segue e' la strada A per esteso, che resta il primo passo piu'
economico.

«La presenza potrebbe essere anche non solo astratta ma indicata dalle carte,
tipo la guardia reale puo' giocare effettivamente una presenza in una regione.»

**Il numero che le da' ragione.** Chi muove le pedine, su 30 Chronicle:

| | |
|---|---|
| posate al setup | **240** |
| aggiunte da MUOVERE | **38** |
| aggiunte da una carta Narratore | 21 |
| aggiunte da un Consiglio | 7 |
| tolte, da tutto | ~34 |

In un anno intero si muove **poco piu' di una pedina per partita** per scelta di
qualcuno. La mappa non e' ferma perche' il titolo non paga (quella leva e' stata
provata e respinta, D-154): e' ferma perche' **nessuno ha carte con cui
muoverla**.

**E il vocabolario esiste gia', quasi spento.** Tre Asset **posano** una pedina
quando li impegni — `AST_AUTHORITY_SUCCESSION_ACT` (Atto di Successione),
`AST_WEALTH_LAND_MORTGAGE` (Ipoteca sulle Terre), `AST_BONDS_HOSTAGE` (Ostaggio)
— e due la **tolgono**: `AST_FORCE_BURNED_GATE` (Le Porte Bruciate),
`AST_PEOPLE_EXODUS` (Esodo). Cinque carte su quarantotto, e nessuna nelle due
famiglie che dovrebbero essere fatte di corpi: le otto FORZA e le otto GENTE
alzano Tensioni e posano tag, ma non mettono nessuno da nessuna parte.

Due modi di farlo, e sono lavori diversi.

**A — la carta che posa una pedina.** Dieci-quindici carte FORZA e GENTE che,
impegnate, mettono o spostano presenza; la Guardia Reale e' la carta d'esempio.
Poco motore (l'Effect `ADD_PRESENCE` c'e' gia' e ha il suo inverso), molta
scrittura, misurabile sui 100 semi, reversibile. E' la strada che rende vero
«muoversi pesa» senza toccare il Consiglio.

**B — la carta *e'* la presenza.** Niente piu' gettoni astratti: la carta si
posa scoperta sulla Regione. La presenza diventa una risorsa limitata e
visibile, perderla e' perdere una carta, e la maggioranza si legge sul tavolo
senza contare niente. E' il gioco piu' forte — tiene insieme il controllo, la
mappa ferma e la vetrina in un colpo solo — ma cambia cosa vuol dire «avere una
carta in mano»: tocca setup, limite di mano, Consiglio e tutte e quattro le
interfacce. **Va disegnata in una seduta prima di essere scritta.**

**Fatto quando** una delle due e' stata percorsa e misurata: le pedine mosse per
scelta salgono ben sopra una a partita, e il playtest resta **FAIL ~180 · 0/8**.

### 38bis. ✅ Nota di metodo: il vincolo 0/8 lo fa rispettare il seggio piu' fragile — chiusa in 0.1.122

`debito` · da [D-154](DECISIONS.md#d-154)

Due varianti del peso della terra sono state respinte da **un solo seggio** —
Kessa — e per una sola partita di differenza. Il motivo e' ISSUES 38: la sua
Vittoria ha una porta sola, quindi non assorbe nessun cambiamento.

Finche' resta cosi', **qualunque modifica alle regole del Consiglio rischia di
essere respinta da Kessa e non dal proprio merito**. ISSUES 38 non e' una voce
fra le altre: e' la porta da aprire prima di provare altre leve.

**Aperta in 0.1.122**, e la nota resta a verbale per la prossima volta: quando
una misura viene respinta da **un solo seggio** e per **una sola partita**, la
domanda giusta non e' «la regola e' sbagliata?» ma «quel seggio riesce ad
assorbire qualcosa?».

### 40. Il grado non si muove dentro l'anno — **deciso: è materia di saga**

`regola` · **decisa in 0.1.142** · [D-167](DECISIONS.md#d-167) → [D-174](DECISIONS.md#d-174)

`_settle_structures` gira **dopo** la valutazione del Destino, quindi in una
Chronicle sola il grado non sale quasi mai: grado 2 nel 15% degli anni per
Aldric e nello 0% per cinque case su otto, grado 3 **mai**.

La voce chiedeva di scegliere fra due strade. **Scelta la prima: il grado alto
resta materia di saga.** La scala che segue il Destino ([D-159](DECISIONS.md#d-159))
vale proprio perché una reggia non si compra in una sera — è il sedimento di tre
anni buoni, e la [saga del Regno che si è seduto](SAGA_NAHR.md) lo mostra meglio
di qualsiasi misura: villaggio 812, borgo 813, granaio 814, città 815, castello
816, **reggia 818**.

**La regola che ne segue:** una clausola sul grado 2 o 3 si scrive **solo nei
Destini di una Chronicle successiva**, mai in quelli d'apertura. Chi la scrive
altrove sta scrivendo un muro.

### 41. Il sito antico, una volta aperto, veniva sempre saccheggiato

`contenuto` · **chiusa in 0.1.142** · [D-167](DECISIONS.md#d-167) → [D-174](DECISIONS.md#d-174)

Due righe della sonda con lo stesso numero — sito **aperto** 25%, sito
**saccheggiato** 25%, gli stessi anni — volevano dire che il grado di mezzo non
era uno stato ma un fotogramma fra due Consigli.

La colpevole non era nessuna delle due Conseguenze che ci si aspetta.
`CNS_MINE_REOPENED` (grado 2) e `CNS_CRYSTAL_EXPLOITED` (grado 3) sono giuste, e
che un anno che fa tutte e due finisca col sito svuotato è onesto. Era
**`CNS_MINE_SEALED`**, che riportava il sito a **grado 1**: murare un sito
saccheggiato lo rimandava a «dormiente», cioè cancellava il fatto che fosse mai
stato aperto e svuotato. Un sigillo nasconde, non restituisce.

Adesso il sigillo porta il sito al **grado di mezzo** — aperto, e da oggi
irraggiungibile:

| | prima | dopo |
|---|---|---|
| il sito è stato aperto | 25% | **80%** |
| il sito è stato saccheggiato | 25% | **60%** |
| **aperto e ancora intero** | **0%** | **20%** |

Un anno su cinque il mondo si ferma sul gradino di mezzo, e «aperto e ancora
intero» è diventata una clausola scrivibile.

### 42. La seconda saga sembrava più generosa della prima

`bilanciamento` · **chiusa in 0.1.142** · [D-167](DECISIONS.md#d-167) → [D-174](DECISIONS.md#d-174)

CHR_03 portava **49 Trionfi contro i 30** di CHR_01. La voce elencava tre cause
possibili e chiedeva di misurarle a parità di tavolo. Misurate tutte e tre, e
**nessuna regge**:

| ipotesi | misura | verdetto |
|---|---|---|
| i Destini della seconda saga chiedono meno | clausole mancate: CHR_01 **38%**, CHR_03 **41%** | falsa — sono più dure |
| le sue Tensioni si muovono di più | Consigli per partita: CHR_01 **5,83**, CHR_03 **5,33** | falsa — ne ha meno |
| ha una casa che parte senza Regioni | ne hanno una a testa (Lyra, il Vetro), e i seggi di CHR_01 finiscono con **più** terra: 1,28 contro 1,17 | falsa |

La ragione vera si è vista aprendo il pool ([D-173](DECISIONS.md#d-173)): **il
divario non era delle saghe, era degli otto Destini che si giocavano.** Con venti
in gioco il carico si distribuisce e le due convergono — CHR_01 **19%**, CHR_03
**23%**, condivisi 16%.

*Prima di tarare tre manopole, vale la pena guardare se il difetto non sia un
effetto di quello che si sta già cambiando altrove.*

### 43. Undici Destini su venti non si giocano mai all'apertura

`contenuto` · `motore` · **chiusa in 0.1.141** · [D-167](DECISIONS.md#d-167) → [D-170](DECISIONS.md#d-170) → [D-173](DECISIONS.md#d-173)

`_deal_destiny` pescava da **`chronicle["destiny_pool"]`**; i pool erano scritti
sulle **Entita'**; nessuna Chronicle ne dichiarava uno. Su 240 seggi-partita si
vedevano **otto Destini su venti**, e i tre condivisibili della voce 20 non
erano mai stati letti da nessuna sonda.

**D-170** ha acceso il pool per misurarlo: supera il Minimo dal 62% al 50%, un
seggio su dodici a NONE. Cinque clausole mancate al 100%, tre Destini con zero
Trionfi, uno fermo 16 volte su 16 al Minimo, un condivisibile col Trionfo piu'
facile della Vittoria. Sei riscritti, si arrivava a 53% e 7%.

**D-173** ha fatto le tre che restavano — i due condivisibili chiedevano al
**Minimo** una cosa che si ottiene giocando (la fama, il registro pulito), e
Aldric chiedeva alla Vittoria due Regioni mancate all'88% — e il pool e'
**acceso**: venti Destini su venti si giocano all'apertura, **zero seggi a
NONE**, nessuno a zero Trionfi, tavolo misto e uniforme **0 su 8**, mediana 6.

Costo dichiarato: **Consigli falliti da 206 a 246** su cento partite. Undici
ambizioni in piu' al tavolo si oppongono fra loro molto piu' spesso, e il tasso
di successo passa dal 64% al 56%. Si spegne in una riga (`_deal_destiny`, il
ripiego sulla lista dell'Entita'), se quaranta Consigli sono troppi.

### 44. La scala di Lyra ha una porta sola, e aprirla costa gli anni tranquilli

`contenuto` · `bilanciamento` · **chiusa in 0.1.137** · [D-168](DECISIONS.md#d-168) → [D-169](DECISIONS.md#d-169)

Lyra leggeva **38 Minimi, 3 Vittorie, 9 Trionfi** su 50: non un seggio debole,
un seggio **bimodale**, con Minimo, spina della Vittoria e spina del Trionfo
tutti veri al 100% e tutta la scala appesa a un tag al **25%**.

Il committente ha deciso: **apri Lyra, la banda si rivede dopo.** Fatto in
D-169 — Vittoria a spina piu' due segni su tre, Trionfo a quattro Scoperte,
scelta di Nahr da quattro segni a tre perche' aprire Lyra le costava sette
Trionfi. Lyra **32/12/6**, Trionfi del tavolo **79 → 86**, nessun seggio a zero.

La banda dei Consigli sale a **5-7** in tutte e due le misure, con i limiti duri
fermi a 2-8: e' 1,25-1,75 per Tensione, ancora sotto il 6-8 che §7 scrive per
quattro Tensioni, ed e' la seconda volta che succede per lo stesso motivo
(D-051, Vaerax).

Costo dichiarato: **FAIL 191 → 203**.

### 45. La linea dei Fuochi: metà chiusa, e quello che resta

`contenuto` · `bilanciamento` · **metà chiusa in 0.1.145** · nata da
[D-176](DECISIONS.md#d-176) → [D-177](DECISIONS.md#d-177)

**La metà chiusa.** La voce diceva che la linea della Cenere/Fuochi arriva al
secondo gradino la metà delle volte delle altre, in ogni sua incarnazione. La
causa non era la debolezza: su 120 anni della saga del Sale **tutti e tredici i
NONE erano suoi** — le altre tre case zero — e tutti per la stessa clausola. Negli
anni persi la Cenere teneva **1,00** gettoni sulle Montagne Rosse e **1,92** nelle
Miniere; negli altri 1,67 e 1,04. Lo stesso numero di gettoni, il posto diverso:
`DST_CENERE_DEEP` chiedeva al Minimo di presidiare la montagna in due e alla
Vittoria di scendere sotto in due, con tre gettoni e i livelli cumulativi.
**Inseguire la propria Vittoria costava il proprio Minimo.** Corretto dando a «Più
a Fondo» il Minimo che il suo testo già descriveva (un gettone su, due sotto) e
togliendo alla sua Vittoria i due regali al 100%: 13 NONE → 0, la casa dal 26% al
33% sopra il Minimo, i volti dei Fuochi da 8%–33% a **22%–50%**.

**Quello che resta, ed è il residuo vero.** Il divario con la linea dei Maestri
(33%–83%) si è ridotto, non chiuso. **Le Custodi della Cenere restano la vita più
debole della saga al 22%**, e la Lega delle Sette è più giù di tutti al 13%. E il
banco delle clausole dice perché è difficile intervenire: delle dodici candidate
misurate, tutto ciò che la Cenere può ottenere **restando sulla montagna** esce
0% (il cristallo, la montagna lavorata, un'opera nelle gallerie) o 100% (un'opera
sulla montagna, un presidio). **Nel mondo com'è, quella casa ha poche leve** — non
è una taratura mancata, è contenuto che non esiste ancora.

**Due cose misurate e non corrette**, che chi apre questa voce trova già a
verbale:

- ~~**La forma di `DST_CENERE_DEEP` è bimodale**: 8 Minimi, 1 Vittoria, 7
  Trionfi su 16.~~ **Chiusa in 0.1.146** ([D-178](DECISIONS.md#d-178)): la causa
  non era la taratura del Trionfo ma una **strada regalata** — la reliquia resa
  obbligatoria dalla Vittoria accendeva da sola il primo dei sei rami, e quel
  `min: 3` era in realtà un `min: 2` su cinque. Tolto il ramo ridondante:
  **0/8/5/3**, lo stesso 50% distribuito come una scala. L'ha trovata la guardia
  nuova, non una sonda.
- **Il perdere ha cambiato posto**: i 2 NONE nuovi sono del Vetro, che adesso
  contende alla Cenere gli slot delle stesse gallerie. Il conto totale del
  perdere nella saga del Sale scende da 13 a 2, e va guardato insieme a
  [D-067](DECISIONS.md#d-067).

**Fatto quando** la linea dei Fuochi sta nella stessa banda delle altre in ogni
sua incarnazione — o il motivo per cui non ci sta è scritto con i numeri accanto.

### 46. La campagna del Sale ha un vincitore già scritto ([#69](https://github.com/Tannoiser2/ECHOES/issues/69))

`contenuto` · `bilanciamento` · nata da [D-180](DECISIONS.md#d-180) · **aperta in 0.1.148**

Il contatore di saga ha reso visibile una cosa che c'era già e che nessuno poteva
vedere finché ogni anno stava in piedi da solo:

| | chi vince la campagna, su 12 saghe da 10 Chronicle |
|---|---|
| **CHR_01** — la Carestia | NAHR 5, LYRA 2, VAERAX 2, **Aldric mai** · 3 pareggi |
| **CHR_03** — il Sale | **SALE 12 su 12** |

**Nella saga del Sale vince sempre la stessa casa, con qualunque scala di
punteggio** — provate tutte e cinque, il vincitore non cambia. La causa non è il
punteggio ma lo squilibrio di contenuto già misurato in
[D-176](DECISIONS.md#d-176): il Sale supera il Minimo il **68%** delle volte, il
Vetro il 49%, le Città Libere il 24% e la Cenere il 33%.

**Il punto di metodo, che vale oltre questa voce:** finché ogni Chronicle sta in
piedi da sola, una casa debole ha comunque i suoi anni buoni e lo squilibrio si
spalma; appena si somma, la differenza *diventa il risultato*. Un contatore di
campagna non è una regola neutra: è un amplificatore di tutto quello che il
bilanciamento non ha ancora chiuso.

Due cose da guardare, e sono diverse:

- **Il Sale è troppo forte** (68%), e va guardato dal lato suo: quali clausole
  gli riescono quasi sempre. È il lavoro speculare a quello fatto sulla Cenere in
  [D-177](DECISIONS.md#d-177), che partiva dalla casa più debole.
- **Aldric non vince mai una campagna** in CHR_01 pur non essendo il più debole
  per gradini (69 Minimi, 41 Vittorie, 9 Trionfi su 120 anni): ha le Vittorie ma
  non i Trionfi, e con una scala che paga il gradino alto il doppio, chi non
  trionfa mai non vince la campagna. Va deciso se è un difetto o se è il suo
  carattere.

**E c'è un terzo lato, misurato in 0.1.149** ([D-181](DECISIONS.md#d-181)): con la
campagna fissata a dieci anni, nel Sale **metà delle campagne è già decisa entro
il terzo anno** (l'ultimo cambio di testa cade in media all'anno 3,5 su 10),
mentre nella Carestia il testimone passa quasi due volte e l'ultimo sorpasso
arriva a metà strada. Una casa che supera il Minimo il 68% delle volte prende la
testa presto e non la molla: lo squilibrio non è solo *chi vince*, è **sette anni
giocati sapendo già come finisce**.

## Lavorata in 0.1.150, e ridotta ([D-182](DECISIONS.md#d-182))

Il committente ha dato la direzione — «il Sale è troppo forte» — e guardando la
casa dal lato suo il difetto aveva **tre teste**: il Minimo vero al 100%, la
seconda clausola della Vittoria vera al 100%, e la **spina del Trionfo** vera al
100%. `DST_SALE` superava il Minimo **12 volte su 13**, e non perché la Gilda
giocasse meglio: la sua Vittoria la decideva il **calendario**. Corretti tutt'e
due i suoi Destini, in quattro passi misurati uno alla volta:

| | prima | dopo |
|---|---|---|
| campagne vinte dal Sale | **12 su 12** | **9 su 12** |
| il Sale supera il Minimo | 68% | **54%** (le altre 33–34%) |
| cambi di testa per saga | 1,3 | **1,8** |
| ultimo cambio di testa | anno 3,5 su 10 | anno **5,5** su 10 |
| decise entro il terzo anno | 6 su 12 | **4 su 12** |

**Non era chiusa**: 9 su 12 è il 75%, sopra il criterio che questa voce si era
data. Il lavoro si era fermato lì perché continuare senza una diagnosi nuova
sarebbe stato tarare a occhio.

---

## Rimisurata in 0.1.177: il vincitore scritto non è più il Sale — ed è cambiato il nome, non il difetto

Dodici saghe da dieci Chronicle, tavolo misto, seme 812:

| | allora | **adesso** |
|---|---|---|
| chi vince la campagna | **SALE 12 su 12** | CENERE **7**, LIBERE 2, SALE **1**, pareggi 2 |
| cambi di testa per saga | 1,3 | **1,2** |
| ultimo cambio di testa | anno 3,5 su 10 | anno **3,6** su 10 |

**La Gilda del Sale è passata da 12 vittorie su 12 a una.** Il difetto per cui
questa voce è nata non esiste più. Ma il posto è stato preso dalla **Cenere, 7
su 12** — il 58%, sotto il 75% di prima e sopra il 33% che sarebbe pari.

E il confronto con l'altra linea dice che il problema non è chi vince, è **come**
la campagna si decide:

| | Grano | Sale |
|---|---|---|
| chi vince più spesso | VAERAX 5 su 12 (42%) | **CENERE 7 su 12 (58%)** |
| cambi di testa per saga | **1,8** | 1,2 |
| ultimo cambio di testa | anno **4,4** | anno 3,6 |
| Consigli l'anno | **3,80** | **2,85** |
| scarto delle domande dalla soglia a fine anno | da −0,18 a −1,71 | da +0,27 a **−3,12** |

### La causa nuova, e sta a monte delle altre due

**La linea del Sale è più fredda.** Un Consiglio in meno l'anno, e domande che
finiscono l'anno molto più lontane dalla soglia — il Debito a −3,12, la Carta a
−2,82. Con meno Consigli si decide meno, e quello che è già deciso all'inizio
resta deciso: da lì i cambi di testa a 1,2 invece di 1,8, e la campagna chiusa
all'anno 3,6 invece che al 4,4.

**E c'è una seconda causa, che è la stessa di [ISSUES 52](#52-lyra-non-ha-mai-trionfato-in-centoventi-anni)**:
l'Ordine del Vetro apre senza presidio come Lyra nell'altra linea, e chiude con
**43 NONE e 1 Trionfo su 120 anni**. Una casa su quattro fuori gioco rende la
campagna una gara a tre, e una gara a tre si decide prima.

**Le due cause vecchie restano da misurare** (i Trionfi per saga, e il Minimo che
non costa uguale) ma passano in seconda fila: il freddo della linea e la quarta
casa scoperta le spiegano tutte e due in parte.

**E la proposta del committente le tocca entrambe**: un Consiglio automatico a
fine Atto garantirebbe tre Consigli l'anno, che nel Sale è **uno in più di
adesso**.

**Fatto quando** su dodici saghe per tavolo nessuna casa vince più della metà
delle campagne — o il motivo per cui una lo fa è scritto con i numeri accanto —
e l'ultimo cambio di testa non cade prima di metà campagna.

### 47. Le carte come unica moneta: azioni, mano e mappa in un sistema solo

`regole` · `motore` · `contenuto` · voluta dal committente · **preventivo misurato in 0.1.151** ([D-183](DECISIONS.md#d-183))

«Tutte le azioni si fanno con le carte, e le carte si pescano a inizio atto a
seconda della presenza in una regione, tipo due presenze due carte; con le carte
in mano si fanno le azioni o si giocano nel consiglio.»

**Il numero che le dà ragione.** Su 72 azioni disponibili al tavolo in un anno, i
seggi giocano **47 ACQUISIRE**, 7 INFLUENZARE, 6 TRAMARE, 5 FORGIARE, 3
RIVENDICARE, 2 carte del Narratore e **1 solo MUOVERE**. Due terzi del gioco sono
già «pesca una carta» e la mappa si muove una volta per partita: la proposta non
introduce un'economia nuova, riconosce quella che c'è e la rende deliberata. E
mette il dilemma che oggi manca — **questa carta la spendo per agire o per
votare?** — al centro di ogni turno.

**Il preventivo**, misurato senza cambiare nessuna regola:

| | CHR_01 | CHR_03 |
|---|---|---|
| carte in un anno per seggio | **6,6** | **7,2** |
| il gioco resta al | **36%** | **40%** di adesso |
| scarto primo/ultimo, atto I → III | 0,00 → **1,25** | 0,00 → **1,92** |
| seggi rimasti senza pedine | **0 su 240** | **0 su 240** |
| famiglie raggiungibili da un seggio | **3,3 su 6** | **3,3 su 6** |

**Le tre cose da decidere prima di scrivere:**

1. **Il volume.** Il gioco si stringe a poco più di un terzo. Va scelto apposta,
   e con esso vanno rivisti il limite di mano (7 oggi) e la lunghezza dell'anno.
2. **Il ciclo che diverge.** Lo scarto parte da zero — tutti cominciano con due
   pedine — e **raddoppia ogni atto**: la divergenza la produce il gioco, non il
   setup. Su una campagna di dieci anni si somma, ed è la stessa forma che il
   contatore di saga ha mostrato in [D-180](DECISIONS.md#d-180). Serve un freno
   deciso in partenza: un tetto, o una pesca che cresce meno che linearmente.
3. **La mappa non è disegnata per distribuire le famiglie.** `WEALTH` sta in
   quattro Regioni su sei, `FORCE` in una sola: se la Regione decide la famiglia,
   la ricchezza diventa la moneta comune e la forza quasi introvabile — e chi non
   passa da Eredan non rivendica mai, perché RIVENDICARE chiede due AUTORITÀ. O
   si ridisegnano le `asset_sources`, o la famiglia non può dipendere solo dal
   posto.

**La sorpresa buona:** nessun seggio resta senza pedine in 480 campioni. La
spirale della morte — chi perde la presenza non pesca più e non si rialza — non
si materializza.

**Il costo di scrittura**, dichiarato: **48 carte** vanno riscritte con un'azione
ciascuna oltre all'effetto di Consiglio che già hanno. È il pezzo di contenuto
più grosso mai fatto sul progetto.

**Da fare nello stesso lavoro**: TRAMARE e INFLUENZARE spariscono come azioni e
diventano effetti di carte — il committente le vuole togliere, e la misura gli dà
ragione (6 e 7 usi in un anno intero).

**Fase 1 ✅ — il telaio** — fatta in 0.1.152 ([D-184](DECISIONS.md#d-184)):
`card_action` sull'Asset, `PLAY_CARD` che passa dal medesimo `check()` dell'azione
e **consuma la carta**, e l'interruttore `actions_from_cards` sulla Chronicle.
Zero carte convertite, playtest identico riga per riga. Da qui le 48 carte si
scrivono **una famiglia alla volta**, misurando, invece che tutte insieme.

**Fase 2 ✅ — il rubinetto** — fatta in 0.1.153 ([D-185](DECISIONS.md#d-185)):
`hand_refill` sulla Chronicle, la pesca a inizio Atto guarda le pedine e la
Regione decide la famiglia. **Il punto 2 di qui sopra ha una risposta misurata**:
il freno non è il tetto per Atto — che limita la pesca e non la mano — ma il
tetto sulla **mano** (`hand_cap`). Scarto all'Atto 3: **5,48** col solo tetto per
Atto, **3,33** col tetto sulla mano, **4,90** col rubinetto spento, cioè nel
gioco di oggi. Frenato, il rubinetto sbilancia **meno di ACQUISIRE**.

Resta però che, **acceso da solo**, peggiora: i Consigli falliti passano da 248 a
272, il massimo mai misurato, perché le carte si sommano ad ACQUISIRE invece di
sostituirlo. Nei dati è **spento**: si accende insieme a `actions_from_cards`.

**Il punto 1 (il volume) e il punto 3 (la mappa) restano da decidere**, e il
punto 3 è quello che blocca la fase 3: finché `FORCE` sta in una Regione sola,
scrivere le 48 carte significa scrivere azioni che qualcuno non potrà mai fare.

**Fase 3 ✅ — la mappa e il fabbisogno** — fatta in 0.1.154
([D-186](DECISIONS.md#d-186)). **Il punto 3 è chiuso**: sei Regioni, due famiglie
ciascuna, due Regioni per famiglia; il divario fra la famiglia più a portata e la
meno passa da **6,8 a 1** a **1,6 a 1**, e nessuna azione è preclusa a nessuno.
**Il punto 1 (il volume) ha un numero**: il fabbisogno per seggio è **11,80 carte
l'anno, 3,93 per Atto** (3,20 azioni + 8,59 impegni ai Consigli), e la taratura
che lo regge è `per_token: 2, floor: 2, cap: 6, hand_cap: 7`. Con quella, **lo
scarto all'Atto 3 è 1,18** contro 4,90 del gioco di oggi: **anche il punto 2 è
chiuso**, e il criterio «lo scarto non cresce» è soddisfatto in preventivo.

Resta la **fase 4**, che è tutto il contenuto: **48 `card_action` da scrivere**,
una famiglia alla volta, misurando. E resta da ridistribuire la mappa di
**CHR_03**, che non è stata toccata.

**Fase 4 ✅ — le quarantotto parlano, e l'interruttore è acceso** — fatta in
0.1.156 ([D-188](DECISIONS.md#d-188)). Ogni carta porta una delle cinque azioni
che restano (ACQUISIRE sparisce, la fa la mappa): **17 INFLUENZARE, 11 MUOVERE,
8 TRAMARE, 8 FORGIARE, 4 RIVENDICARE**, distribuite per famiglia così che *la
mappa decida che cose puoi fare*. CHR_01 e CHR_02 giocano con le carte come
unica moneta.

**I tre criteri di chiusura sono soddisfatti**: un anno si gioca per intero con
le carte, il playtest resta **0/8** a tavolo misto e uniforme, e lo scarto fra
il primo e l'ultimo seggio **non cresce** — 0,00 → 1,10 → **1,58** all'Atto 3,
contro 4,90 del gioco di prima.

**Quello che resta, e che non è questa issue:**

- **CHR_03 gioca ancora il §10 di prima**, deliberatamente: la sua mappa non è
  stata guardata. Accenderla senza sarebbe ripetere il difetto di D-186.
- **Manca un piano scriptato del gioco a carte**: i tre esistenti sono storie
  del §10 di prima, e da 0.1.157 ([D-189](DECISIONS.md#d-189)) lo **dichiarano
  nel dato** (`chronicle_overrides`), non solo in un verbale. Il gioco nuovo è
  provato dal cancello e dai test, non da una storia raccontata.
- ~~Il 58% delle Occasioni resta muto~~ — **scomposto in 0.1.161**
  ([D-193](DECISIONS.md#d-193)): la causa più grossa era il modo di TRAMARE
  fissato sulla carta, e liberandolo le mute di quella famiglia passano da 56 a
  15. Il totale resta al 62% e **non è un difetto**: nel gioco di prima succedeva
  qualcosa nel 18% delle Occasioni, adesso nel 37%. Quello che è sparito è il
  riempitivo di ACQUISIRE.

**Fatto quando** un anno si gioca per intero con le carte come unica moneta, il
playtest resta **0/8** a tavolo misto e uniforme, e lo scarto fra il primo e
l'ultimo seggio **non cresce** di atto in atto.

### 48. La Strada dei Mercanti è una Regione morta

`regole` · `contenuto` · **misurata in 0.1.154** ([D-186](DECISIONS.md#d-186))

Misurando dove finiscono le pedine per scegliere la mappa nuova, è saltato fuori
un numero che nessuno aveva mai guardato:

| Regione | pedine viste | |
|---|---|---|
| Eredan | 425 | 26,9% |
| Valle Verde | 417 | 26,4% |
| Miniere Antiche | 373 | 23,6% |
| Montagne Rosse | 180 | 11,4% |
| Terre Nahr | 175 | 11,1% |
| **Strada dei Mercanti** | **10** | **0,6%** |

La Strada è **centrale** — confina con quattro Regioni su cinque, più di
chiunque altra — e ha **quattro slot di presenza**. Eppure in 60 anni ci
finiscono dieci pedine in tutto. Una Regione che non vede pedine non è una
sorgente: col rubinetto acceso, le famiglie che offre non escono quasi mai, e le
sue `asset_sources` sono decorazione.

**Le tre ipotesi da provare, in ordine di costo:**

1. **Nessun Destino la chiede.** Se nessuna clausola `region_presence` la nomina
   e nessuna Tensione la usa come dominio, i bot non hanno motivo di andarci: si
   verifica leggendo i dati, senza giocare.
2. **Non ci si arriva.** L'adiacenza dice di sì, ma MUOVERE si gioca **una volta
   per partita** su tutto il tavolo: se nessuno ci comincia, nessuno ci arriva.
   Delle otto case, **una sola** ci comincia — Maestra Ilve (il Sale), che gioca
   in CHR_03, non in CHR_01: nella Chronicle misurata **nessuno parte di lì**.
3. **Non rende.** Non è capitale, non è granaio, non ha struttura: tenerla non
   dà voce al Consiglio e non chiude nessun Destino.

**La voce cercava nel posto sbagliato, e si vede rimisurando** (0.1.173,
[D-205](DECISIONS.md#d-205)). Col gioco a carte la Strada è passata da **0,6% a
3,3%** da sola — nessuno l'ha toccata. Ma il numero che spiega tutto è un altro:

| | Carestia (CHR_01) | Sale (CHR_03) |
|---|---|---|
| Strada dei Mercanti | **3,3%** | **13,8%** |
| Terre Nahr | 13,5% | **1,7%** |

**La Strada non è una Regione morta: è morta in un'era sola.** Nel Sale è la
terza più affollata. E nel Sale la Regione morta sono le **Terre Nahr**, all'1,7%
— peggio di quanto la Strada sia mai stata.

**La causa è una sola, e non è quella che le tre ipotesi cercavano**: le pedine
si posano **all'apertura** e durante l'anno si muovono pochissimo, quindi la
mappa di fine anno è quasi quella di partenza. **La Regione vuota è quella in cui
non comincia nessuno** — e cambia da un'era all'altra, perché a cambiare sono le
case. La sonda della mano adesso la **nomina** invece di lasciarla dedurre.

**Due rimedi provati e respinti coi numeri**, tutti e due misurati e tutti e due
a zero: un **Pedaggio** sulla Strada (la struttura giusta esiste già nel
catalogo, `STR_TOLLGATE`, e non era su nessuna mappa) e un **cervello che conta
anche i domini** oltre alle famiglie quando sceglie dove andare — 3,3% prima,
3,3% dopo, tutti e due. Chi non ha una pedina di riserva non si sposta comunque, e
chi ce l'ha la spende una volta sola.

**Quindi la voce cambia forma.** Non «la Strada è morta», ma: **ogni era ha una
Regione dove non vive nessuno, e quella resta vuota**. Da decidere se è un
difetto o se è la mappa che racconta chi c'era in quel secolo — la strada fra le
case è deserta nell'anno della Carestia e piena nell'anno del Sale, e detta così
è una cosa che il mondo dice, non un buco.

**Da non confondere con la palude**: quella chiede slot variabili ed è motore.

---

## Il committente ha deciso, e ha spostato la domanda (0.1.176)

> «No, non ci può essere una regione senza nessuno, e anzi la Strada dei
> Mercanti dovrebbe essere uno snodo vitale. Quindi la domanda è anche
> **perché le pedine non si muovono?**»

Non è colore: è un difetto. E la domanda giusta non era «perché la Strada è
vuota» ma «perché la mappa è ferma» — che nessuno aveva mai misurato. La sonda
nuova `run_move_probe` la misura, e per ogni casa a fine anno dice **quale
porta era chiusa**.

### La causa, su 40 partite a tavolo misto

| | CHR_01 | CHR_03 |
|---|---|---|
| pedine per casa all'apertura | 2 | 2 |
| tetto (`presence_tokens`) | 3 | 3 |
| **di riserva** | **1,00** | **1,00** |
| MUOVERE giocate l'anno | 3,23 | 2,88 |
| — di cui **posano** | 3,20 | 2,85 |
| — di cui **spostano** | **0,03** | **0,03** |
| carte MUOVERE viste in mano | 12,57 | 9,97 |

E le porte, a fine anno, su 160 occasioni di seggio:

| porta chiusa | CHR_01 | CHR_03 |
|---|---|---|
| **il gettone** — sono già tutte sul tavolo | **73,1%** | 71,9% |
| la carta — nessuna MUOVERE in mano | 12,5% | 7,5% |
| la porta — cacciata, segno, adiacenza, pieno | **0%** | **0%** |
| la voglia — poteva, ha scelto altro | 14,4% | 20,6% |

**La mappa non è ferma per cattiveria del cervello né per mancanza di carte.**
È ferma per costruzione: il gioco posa **otto pedine all'apertura** e ne concede
**quattro in tutto l'anno**, una per casa. Finita quella, tre case su quattro
non hanno più niente da muovere. Le carte abbondano (12,57 viste, 3,23 giocate)
e la porta non è **mai** sbarrata: lo 0% di quella riga chiude le tre ipotesi
originali di questa voce, adiacenza compresa.

**E spostare non succede: 0,03 volte l'anno.** Non è un caso, è una scelta
misurata ([D-185](DECISIONS.md#d-185)): il cervello non toglie una pedina da
dove la casa vive, perché farlo costava a Re Aldric 8 NONE su 50 partite. Con
tutte le pedine posate, MUOVERE **è** uno spostamento — e quindi non si gioca.

**La Strada non offre poco: è la Regione più ricca della mappa.** Quattro
vicini su cinque (l'unico vero incrocio), 4 slot, WEALTH + KNOWLEDGE, e tre tag
di dominio più `trade`. Perde la corsa all'unico gettone perché **nessuno ci
comincia**, e nessun obiettivo ci punta.

### I tre rimedi, misurati

| | oggi | tetto a 4 | Lyra sulla Strada | tutti e due |
|---|---|---|---|---|
| Strada, apertura → fine | 0,00 → 0,65 | 0,00 → 1,23 | 1,00 → 1,57 | **1,00 → 2,15** |
| la Regione più povera a fine anno | **0,65** | 1,23 | 1,50 | **1,60** |
| MUOVERE l'anno | 3,23 | 4,58 | 3,23 | **4,65** |
| Consigli l'anno (unif. / misto) | 3,37 / 3,73 | 3,63 / 3,93 | **3,13 / 3,44** | 3,58 / 3,73 |
| Lyra NONE (unif. / misto) | 14 / 21 | non misurato | 9 / 8 | **8 / 9** |
| Lyra VITTORIE (unif. / misto) | 11 / 11 | non misurato | **27 / 27** | 25 / 28 |
| playtest 100 semi | 0/8 | 0/8 | 0/8 | **0/8** |

- **Il tetto a 4** dà a ogni casa due gettoni di riserva invece di uno: le pose
  passano da 3,23 a 4,58 e i Consigli **salgono**, il che aiuta anche
  [ISSUES 51](#51-sei-domande-su-dodici-non-arrivano-a-soglia-da-sole). Ma la
  Strada resta l'ultima, perché continua a partire da zero.
- **Lyra sulla Strada** (Eredan → Strada dei Mercanti) riempie la Regione
  all'apertura e appiattisce la mappa da (0,65 … 2,77) a (1,50 … 2,00). E come
  effetto secondario **cura mezza [ISSUES 52](#52-lyra-non-ha-mai-trionfato-in-centoventi-anni)**:
  i NONE di Lyra crollano da 21 a 8 e le Vittorie salgono da 11 a 27. Gli
  studiosi sulla strada dove viaggia il sapere è anche la cosa che ha più senso
  da leggere. **Il prezzo:** i Consigli scendono a 3,13 / 3,44.
- **Tutti e due insieme** è la sola combinazione che vince su ogni riga: la
  Strada diventa la **seconda** Regione più abitata, nessuna scende sotto 1,60,
  i Consigli tornano dov'erano, Lyra resta curata, e il vincolo 0/8 regge.

**Il cambio dei tre non ancora misurato**, e va detto: **spostare** resta a 0,03
in tutte e tre le configurazioni. Nessuno di questi rimedi fa muovere una pedina
già posata — allargano il rubinetto, non sbloccano la mappa. Se «la mappa si
muove» vuol dire anche *ritirarsi da un posto*, serve una quarta leva che questa
misura non copre.

**Fatto quando** nessuna Regione sta sotto una pedina a fine anno in nessuna
era, e la sonda continua a nominare la più povera così nessuno se la ritrova per
caso.

### 49. ✅ Le Tensioni come mucchi di segnalini coperti — chiusa in 0.1.179

`regole` · `motore` · voluta dal committente · **preventivo misurato in 0.1.158** ([D-190](DECISIONS.md#d-190))

«Ogni carta o azione fa pescare uno o più segnalini coperti che danno un valore
a una tensione. A un certo punto, quando parte la Confluence, si girano, e la
tensione col punteggio più alto viene dibattuta nel Consiglio.»

**Il sacchetto esiste già**: la Deriva è nove gettoni mescolati col seme
([D-047](DECISIONS.md#d-047)), pescati uno per round. La proposta cambia **chi
pesca** (i giocatori agendo) e **quando si guarda** (al Consiglio).

**Il preventivo**, misurato senza cambiare nessuna regola:

| | CHR_01 (a carte) | CHR_03 (§10 di prima) |
|---|---|---|
| segnalini in un anno | **18,7** | **72,4** |
| il mondo si scalda | **2,1×** | **8,0×** |
| ...col sacchetto misto 1/2/3 | 3,6× | 14,1× |
| scarto fra il mucchio più alto e il più basso, atto I → III | 3,07 → **5,02** | 5,15 → **11,77** |
| la domanda più calda è quella davvero dibattuta | **31%** | 23% |

**Le quattro cose da decidere prima di scrivere:**

1. **Serve il gioco a carte.** Nel §10 di prima ogni ACQUISIRE scalderebbe il
   mondo, e ACQUISIRE era due terzi di tutto: otto volte la Deriva. Le due
   riprogettazioni hanno bisogno l'una dell'altra, e questa non si può accendere
   in CHR_03 finché quel mondo non passa alle carte.
2. **L'innesco.** Un segnalino ogni **3** riproduce esattamente il ritmo di oggi
   (5,95 Consigli l'anno contro 5,90) e al tavolo si conta a occhio. A orologio
   dà 3 (fine Atto) o 9 (fine round). **L'innesco «a chiamata» — lo apre un
   giocatore — non è misurabile con una sonda ombra**, ma è quello che salderebbe
   [ISSUES 37](#37): RIVENDICARE diventerebbe il motore delle Tensioni invece di
   un'azione che muore in mano tre volte su quattro.
3. **Il sacchetto misto è fuori scala**: 3,6× vuol dire rifare tutte le soglie,
   non ritoccarle. Se i segnalini devono pesare 1, 2 o 3, le soglie non sono più
   4–7.
4. **Chi sceglie la domanda.** La sonda pesca a caso e uniformemente. Se invece è
   **la carta** a dire quale domanda si scalda, il mucchio smette di essere un
   caso e diventa una scelta — è un terzo gioco, e non è misurato.

**Il numero che decide se vale la pena**: su 354 Consigli veri, il mucchio
coperto avrebbe scelto la stessa domanda il **31%** delle volte. Sette volte su
dieci si dibatterebbe qualcos'altro. **Non è colore: è un altro gioco** — e non
si può accendere «per vedere come va», perché cambia quali storie il mondo
racconta.

**E rende inutile il velo di [D-187](DECISIONS.md#d-187), in meglio**: se tutti i
valori sono coperti per costruzione, «velata» smette di essere una categoria
speciale — sono tutte velate, e TRAMARE diventa «sbircio un segnalino».

**Fase 1 ✅ — il calore lo pescano i giocatori** — fatta in 0.1.160
([D-192](DECISIONS.md#d-192)), sulla scelta **b** del committente: *una soglia
sola per il tavolo, non una per domanda*. Ogni azione riuscita posa un gettone
scelto dal sacchetto; la Deriva a orologio si spegne.

**E il preventivo qui sopra era sbagliato di due volte**, corretto in D-192: la
sonda ombra contava ogni firma d'azione distinta (una carta ne produce più
d'una), e soprattutto paragonava i gettoni ai 9 della Deriva **come se fosse
tutto il calore del mondo** — CHR_01 ne posa **35,9 l'anno**. Il sacchetto ne
aggiunge dieci e ne toglie nove: **+7%, non +210%**. Quindi le soglie salgono di
**1**, misurato (5,93 Consigli l'anno contro i 5,97 di prima); il raddoppio li
dimezzava.

**Fase 2 ✅ — la soglia sola per il tavolo** — fatta in 0.1.171
([D-203](DECISIONS.md#d-203)). Il Consiglio si apre a gettoni e si dibatte il
mucchio più alto; l'innesco a chiamata c'era già in
[D-191](DECISIONS.md#d-191), e anche lui svuota il sacchetto.

**E il numero scelto non valeva più quel numero**: i «tre gettoni» erano misurati
nel gioco di prima, con 18 azioni l'anno. Col gioco a carte il tre dà 3,02 e 3,50
Consigli e **non passa le guardie** (due anni su dodici in CHR_02 e tre su dodici
in CHR_04 chiudono con uno solo). Spedito il **due**: 3,46 e 4,00 l'anno, contro
i 6,03 e 6,01 di prima. Da due Consigli per Atto a poco più di uno — dichiarato,
e reversibile con una chiave.

**Fase 3 ✅ — i mucchi coperti** — fatta in 0.1.179
([D-210](DECISIONS.md#d-210)).

**Coprire un mucchio in cui ogni gettone vale 1 non nasconde niente**: si conta
a occhio. Quindi la regola è una cosa sola in due metà — il gettone pesca un
**valore** dal sacchetto (`covered: [0, 1, 1, 2]`, media 1,00, e lo zero è il
gettone bianco), e il punteggio smette di essere pubblico. Sul tavolo si vede
**quanti gettoni** sono caduti, non quanto pesano; si girano quando il Consiglio
si apre.

E si copre in **tre finestre**, non una: il verbale pubblico, la scheda del
seggio, e la pagina d'aiuto. Bastava lasciarne aperta una perché coprire fosse
teatro — la lezione di §5ter, presa in anticipo invece che dopo.

| | prima | dopo |
|---|---|---|
| Consigli l'anno, uniforme | 3,37 | **3,40** |
| Consigli l'anno, misto | 3,73 | **3,57** |
| scarto fra i mucchi, atti I→III | 3,95 → 5,95 → 6,42 | 4,17 → 5,90 → **6,92** |
| playtest 100 semi | 0/8 | **0/8** |

**Il criterio di chiusura era impossibile, e l'ha detto la misura.** «Lo scarto
non cresce di atto in atto» **era già falso senza coprire**: 3,95 → 6,42. I
mucchi crescono per costruzione — accumulano, e che uno diventi il più alto è
tutto il punto del cancello. Coprire aggiunge **+0,28** su tre atti, cioè
niente. Il criterio giusto è quello riscritto: *non cresce più di quanto già
cresceva*, ed è soddisfatto.

**E ha scoperto un difetto vecchio.** Il pavimento di fine anno
(`minimum_confluences`) portava una domanda **alla propria soglia** — ma col
cancello del tavolo la soglia non apre più niente, e se la domanda più vicina
era già sopra soglia il pavimento usciva zitto senza fare nulla. Era latente da
[D-203](DECISIONS.md#d-203); la copertura, alzando un po' i valori, l'ha reso
visibile e un anno è sceso a un Consiglio solo. Adesso, sotto il cancello, il
pavimento **fa cadere i gettoni che mancano** — come Effetti, uno per volta,
reversibili: alzare il contatore e basta avrebbe aperto un Consiglio che il
registro non sa spiegare.

### 50. Quattro obiettivi al posto dei tre gradini

`regole` · `motore` · voluta dal committente · **preventivo misurato in 0.1.164** ([D-196](DECISIONS.md#d-196))

«Gli obiettivi sono tre o quattro, pescati all'inizio della partita: uno è
palese ed è legato all'entità, gli altri si scelgono da un pool o con un draft e
sono nascosti agli altri. **Gli obiettivi sostituiscono i gradini**: se si
ottengono tutti e 4 è un trionfo, se non se ne raggiunge nessuno è un NONE, gli
altri sono successi parziali, e vittorie che danno numeri alla fine della saga.»

Oggi ogni casa ha **un** Destino con **tre gradini cumulativi** (§14): Minimo,
Vittoria, Trionfo, e il Trionfo contiene sempre gli altri due. La proposta
sostituisce la scala con un **conto**: quanti dei quattro obiettivi si sono
avverati.

**Il preventivo**, misurato su 100 Chronicle (semi 7000–7099, 400 seggi, tavolo
misto) senza cambiare nessuna regola — le partite sono quelle di oggi, e a fine
anno il mondo viene letto una seconda volta chiedendogli cose che il gioco non
gli chiede:

| dove si arriva | oggi, tre gradini | domani, quattro obiettivi |
|---|---|---|
| niente (NONE / 0 su 4) | **0,8%** | **27,2%** |
| il primo scalino | 48,2% | 36,2% (1 su 4) |
| in mezzo | 34,2% | 21,5% + 12,8% (2 e 3 su 4) |
| tutto (TRIUMPH / 4 su 4) | **16,8%** | **2,2%** |
| punteggio di saga per seggio | +2,51 | +1,17 |

**Le tre cose che i numeri dicono:**

1. **Il NONE diventa vero.** Oggi «non raggiungere niente» capita a 3 seggi su
   400: il Minimo è sopravvivere ([D-150](DECISIONS.md#d-150)) e sopravvivere è
   quasi automatico. Coi quattro obiettivi capita a un seggio su quattro. È
   quello che il committente ha chiesto, ed è il cambiamento più grosso di tutta
   la proposta — più del trionfo.
2. **Il trionfo diventa raro sul serio**: 2,2%, cioè **circa uno per saga a
   tavolo**, contro un seggio su sei di oggi. Difendibile, ma è una decisione, non
   un effetto collaterale.
3. **Il palese non è uguale per tutti.** Letto come Vittoria del Destino scritto,
   si avvera nel 51,5% dei seggi *in media* — ma la media nasconde il vero
   problema: **dal 41% di Aldric al 91% delle Libere**. Se il palese vale un
   quarto del risultato, quello scarto è un vantaggio distribuito alla nascita.

**Il pool non c'è ancora.** I candidati esistenti sono i tre Destini
condivisibili ([D-115](DECISIONS.md#d-115)), letti come sei obiettivi
(Vittoria + Trionfo di ciascuno). Tassi misurati: 39,0% · 37,2% · 35,8% · 29,8% ·
13,5% · **1,8%** — e l'ultimo (`DST_SHARED_LAND/triumph`, «la mappa parla la tua
lingua») è **arredo**: nessuno l'ha mai visto da vicino. Sei sono pochi per
pescarne tre: se il pool è di sei e se ne pescano tre, metà del pool esce ogni
partita e il draft non sceglie niente. Ne servono **almeno dodici**.

**Quello che la sonda non può misurare**: il draft. Scegliere un obiettivo
guardando gli altri scegliere è una decisione umana, e nessuna sonda che gioca
con `PolicyDecider` la produce ([CONSEGNE §5ter](CONSEGNE.md)).

**Le quattro cose da decidere prima di scrivere:**

1. ✅ **Cosa diventa il palese** — la Vittoria del Destino scritto
   ([D-198](DECISIONS.md#d-198)).
2. ✅ **Se lo scarto fra case è un difetto o è ECHOES** — deciso in
   [D-199](DECISIONS.md#d-199): è un difetto, perché il palese vale un quarto del
   risultato e l'asimmetria di ECHOES deve stare in **come** ci si arriva, non in
   quanto costa un quarto del punteggio. Ridotto da 43,2 a 19,6 punti di scarto
   fra le case.
3. **Quanti obiettivi**: il committente ha detto «tre o quattro» e poi ha
   contato su quattro. Con tre, la distribuzione si sposta e va rimisurata.
4. **La mappa dei numeri.** La proposta della sonda (0 → −1, 1 → 1, 2 → 2,
   3 → 4, 4 → 6) tiene i due estremi di `saga_scoring` e riempie in mezzo: dà
   +1,17 per seggio contro i +2,51 di oggi. Se una saga deve valere quanto prima,
   i numeri in mezzo salgono.

**Fase 1 ✅ — il pool** — fatta in 0.1.165 ([D-197](DECISIONS.md#d-197)). Nuovo
schema `objective` (un traguardo piatto, senza gradini) e **dodici obiettivi**
misurati uno per uno: dal **79,0%** al **10,2%**, nessuno fuori banda, media
34,0%. La distribuzione dei quattro migliora **senza toccare una soglia** — 0 su
4 da 27,2% a **16,2%**, media da 1,26 a **1,58** — perché sono cambiate solo le
carte del pool. Due candidati bocciati coi numeri: «La Parola Data» al 100% e
«Il Mondo Intatto» al 2,0%.

**E il palese è più stretto di come l'avevo scritto**: fra gli otto Destini
identitari lo scarto è **35,7%–80,0%** (il 91% citato sopra è
`DST_LIBERE_WATER`, una variante). Resta un difetto, e resta il punto 1 da
decidere.

**Fase 2 ✅ — il motore** — fatta in 0.1.166 ([D-198](DECISIONS.md#d-198)).
CHR_01 non sale più una scala: conta. Regola dichiarata dalla Chronicle e
reversibile; il livello si **deriva** dal conto, così il verbale, il pannello, il
libro della saga, il salvataggio e il punteggio di campagna continuano a leggere
quello che hanno sempre letto.

**Quello che il gioco conta davvero** (100 Chronicle, i 200 seggi di CHR_01):
0 su 4 nel **19,0%**, tutti e quattro nel **2,5%**, media **1,44**, saga **+1,42**
per seggio. L'ombra prometteva 1,58: **era ottimista del 9%**, e il verso
dell'errore è quello buono da sapere.

**E il lato umano è stato cercato, non aspettato** (§5ter): pannello, console,
riga del verbale e pagina delle regole, tutti da una funzione sola. Guardando la
pagina ho trovato un errore di formattazione che girava a ogni apertura con la
suite verde — la seconda volta di fila che quella regola si paga.

**Fase 3 ✅ — il palese** — fatta in 0.1.167 ([D-199](DECISIONS.md#d-199)). La
misura che conta è **per casa**, non per Destino, perché una casa non sceglie
quale dei tre le tocchi: **lo scarto fra la casa più cara e la più facile passa
da 43,2 a 19,6 punti**, misurato su 200 Chronicle con gli stessi semi. Quattro
cambiamenti nei dati, due residui nominati (`DST_NAHR` a 72,5% e
`DST_SHARED_LAND` giurata da Vaerax a 16,7%), e il prezzo dichiarato: più equo
vuol dire più caro, la media scende da 1,51 a 1,37 obiettivi per seggio.

**Compensata un po'** in 0.1.168 ([D-200](DECISIONS.md#d-200)), su decisione del
committente: `saga_points` passa a −1 · 1 · 2 · 5 · 8 e il punteggio risale a
**+1,45** per seggio (era +1,51 prima della fase 3, +1,30 dopo). I punti sono
andati sul terzo e sul quarto obiettivo, i due che quasi nessuno prende. La
**distribuzione non è cambiata**: 0 su 4 resta al 20,8%, 4 su 4 all'1,8% — è la
scala dei numeri ad essere cambiata, non la difficoltà.

**Fase 4 ✅ — il mondo del Sale** — CHR_03 e CHR_04 sono passate alle carte in
0.1.169 ([D-201](DECISIONS.md#d-201)) e agli obiettivi in 0.1.170
([D-202](DECISIONS.md#d-202)), dopo aver messo a posto i loro Destini: lo scarto
del palese per casa passa da **31,0 a 13,7 punti**, meglio del 19,6 con cui è
rimasta la prima saga.

**Adesso tutte e quattro le Chronicle contano.** Sugli 800 seggi: 0 su 4 nel
**18,5%**, 4 su 4 nell'**1,9%**, media **1,45**, punteggio di saga **+1,56**.

**Fatto quando** un anno si chiude contando obiettivi invece di gradini ✅, il
pool ha almeno dodici carte e nessuna sotto il 10% o sopra l'80% ✅, il palese
costa uguale a tutte le case ✅ (scarto 19,6 punti nella prima saga e 13,7 nella
seconda, con i due residui nominati), e il playtest resta **0/8** a tavolo misto
e uniforme ✅.

**Chiusa in 0.1.170.**

---

### 51. ✅ Sei domande su dodici non arrivano a soglia da sole — chiusa in 0.1.178

`bilanciamento` · `contenuto` · **aperta in 0.1.175** · nata da [D-207](DECISIONS.md#d-207)

Dando la biblioteca anche all'anno d'apertura e' saltato fuori un numero che un
test guardava da sempre **su una Chronicle sola**. Il criterio era: valore
iniziale + Deriva + Ripple deve bastare ad arrivare a soglia. Misurato su tutta
la biblioteca:

| domanda | da | soglia | con Deriva e Ripple | |
|---|---|---|---|---|
| La Carestia | 3 | 6 | 9 | ✅ |
| La Successione | 2 | 6 | 6 | ✅ |
| Le Vie Interrotte | 1 | 5 | 5 | ✅ |
| I Senza Citta' | 2 | 5 | 5 | ✅ |
| La Cenere che Sale | 2 | 4 | 4 | ✅ |
| **Il Risveglio** | 2 | 6 | **5** | ❌ |
| **La Febbre Bassa** | 2 | 5 | **4** | ❌ |
| **I Pozzi Bassi** | 1 | 5 | **3** | ❌ |
| **Il Debito** | 2 | 7 | **6** | ❌ |
| **La Reliquia** | 2 | 6 | **5** | ❌ |
| **La Carta** | 2 | 7 | **6** | ❌ |
| L'Acqua Ferma | 3 | 6 | 6 | ✅ (in CHR_04; 5 in CHR_03) |

**Non e' un difetto nuovo.** Le sei erano gia' cosi' in CHR_02 e CHR_04: il test
non le ha mai guardate perche' leggeva solo l'anno scritto a mano, che era stato
tarato a mano. E non e' nemmeno detto che sia un difetto: quelle domande salgono
**per mano dei giocatori**, e da [D-192](DECISIONS.md#d-192) il calore lo pescano
loro (`replaces_drift`), quindi il sacchetto non e' in gioco nella partita
spedita.

**Il costo pero' si e' visto.** Con l'apertura che pesca, i Consigli l'anno
passano da **3,59 a 3,37** (uniforme) e da **3,97 a 3,73** (misto), e nella linea
del Grano i NONE salgono da 107 a 132 su 480 seggi-anno. Il Sale non lo paga —
Trionfi da 5 a **9** — perche' le sue sei candidate sono tarate piu' vicine.

## Misurata in 0.1.178: nessuna domanda è muta, e l'aritmetica sbagliava strumento

`run_question_ledger` conta, per ogni domanda, quante volte è stata pescata e in
quanti di quegli anni ha aperto **almeno un Consiglio**. Su 60 partite per era,
a tavolo misto:

| CHR_01 — la Carestia | pescata | Consigli | anni con |
|---|---|---|---|
| I Pozzi Bassi | 38 | 11 | **26,3%** |
| Le Vie Interrotte | 48 | 25 | 47,9% |
| La Febbre Bassa | 40 | 30 | 57,5% |
| Il Risveglio | 40 | 56 | 90,0% |
| La Carestia | 33 | 46 | 93,9% |
| La Successione | 41 | 60 | **95,1%** |

| CHR_03 — il Sale | pescata | Consigli | anni con |
|---|---|---|---|
| I Senza Città | 51 | 16 | **31,4%** |
| La Cenere che Sale | 49 | 18 | 34,7% |
| L'Acqua Ferma | 50 | 24 | 46,0% |
| Il Debito | 52 | 37 | 51,9% |
| La Carta | 44 | 35 | 61,4% |
| La Reliquia | 54 | 41 | **66,7%** |

**Nessuna delle dodici è muta, e tutte e dodici superano il criterio** che questa
voce si era data (un Consiglio in una partita su quattro). La Febbre Bassa e i
Pozzi Bassi, le due che l'aritmetica dava per irraggiungibili, aprono un
Consiglio nel 57,5% e nel 26,3% degli anni in cui escono.

**L'aritmetica non era sbagliata: era lo strumento sbagliato.** Contava valore
iniziale + Deriva + Ripple, e da [D-192](DECISIONS.md#d-192) **la Deriva non è
nemmeno in gioco** — il calore lo pescano i giocatori. Un test che somma un
sacchetto che nessuno usa non misura il gioco spedito.

### Ma la misura ha trovato un'altra cosa, e più grossa

Le due linee non hanno lo stesso clima:

| | Grano | Sale |
|---|---|---|
| Consigli l'anno | **3,80** | **2,85** |
| domande sopra il 90% | **3** | **0** |
| domanda più calda | 95,1% | 66,7% |
| scarto medio dalla soglia a fine anno | da −0,18 a −1,71 | da +0,27 a **−3,12** |

**Nel Sale le domande finiscono l'anno molto più lontane dalla soglia** — il
Debito a −3,12, la Carta a −2,82, l'Acqua Ferma a −2,66 — e il tavolo tiene un
Consiglio in meno l'anno. Non è una linea più difficile: è una linea più
**fredda**, dove le domande non maturano.

Questo appartiene a [ISSUES 46](#46-la-campagna-del-sale-ha-un-vincitore-già-scritto-69),
che cercava le cause dello squilibrio del Sale e ne aveva due non misurate. Ne
ha una terza adesso, ed è a monte delle altre.

**E dà un numero alla proposta del committente** — un Consiglio automatico a
fine Atto, la domanda più alta dibattuta. Garantirebbe tre Consigli l'anno: nel
Grano è quasi il numero di oggi, **nel Sale sarebbe un Consiglio in più ogni
anno**.

**Chiusa in 0.1.178**: nessuna domanda è muta. Il criterio forte torna nel test
quando la Deriva torna in gioco — o non torna mai, e allora quel test ha finito
il suo lavoro.

**Si intreccia con il ritmo dell'anno**, che e' la domanda gia' aperta col
committente: sei Consigli l'anno erano troppi, tre e mezzo forse sono pochi, e
questa voce sposta il numero verso il basso.

---

### 52. Lyra non ha mai trionfato in centoventi anni

`bilanciamento` · `contenuto` · **aperta in 0.1.175** · nata dal resoconto della saga 812

Il resoconto narrativo di una saga intera ha regalato un numero che nessuna
sonda chiedeva. Su **120 seggi-anno** (12 saghe da 10 Chronicle, linea del
Grano, tavolo misto), contando per seggio:

| seggio | TRIONFI | NONE |
|---|---|---|
| **Lyra** | **0** | **37** |
| Vaerax | — | 19 |
| Aldric | 3 | — |

Zero Trionfi su dodici saghe, e quasi un terzo dei suoi secoli chiusi senza
prendere **nemmeno un obiettivo**. Nella saga raccontata, la Leggenda della
Montagna arriva in testa all'anno 9 — ed e' l'eccezione: lo stesso seggio, in
un'altra saga, chiude dieci secoli con **1 punto**.

**Da non confondere con ISSUES 44**, che era la scala di Lyra col Destino a tre
gradini e fu aperta e chiusa in 0.1.137. Questa e' Lyra **col gioco degli
obiettivi**: quattro carte pescate da un pool condiviso, che in teoria costano
uguale a tutte le case ([D-199](DECISIONS.md#d-199) le ha pareggiate a 19,6
punti di scarto). Se il pool e' pari e il seggio no, la causa sta altrove — nella
mappa che pesca, nelle carte che puo' avere, o in chi ha la parola.

## Misurata in 0.1.177: sono sempre le stesse due carte, e sono le più facili

`run_objective_ledger` conta, per ogni coppia **seggio × obiettivo**, quante
volte è stato pescato e quante preso. Su 60 partite a tavolo misto, due righe
spiegano tutto:

| obiettivo | Aldric | Nahr | Vaerax | **Lyra** |
|---|---|---|---|---|
| **Qualcosa che Resta in Piedi** — una struttura sua | 100% | 100% | 100% | **4,5%** |
| **Il Muro che Tiene** — un presidio suo | 100% | 100% | 100% | **0%** |

**I due obiettivi più facili del pool sono un regalo dell'apertura per tre case
e un muro per la quarta.** La causa sta in una riga di dati:
`starting_structures` posa uno `STR_KEEP` — famiglia PRESIDIO, quindi struttura
*e* presidio insieme — a Eredan per Aldric, alle Terre Nahr per Nahr, sulle
Montagne Rosse per Vaerax. **A Lyra niente.** Tre case aprono l'anno con due
obiettivi su dodici già in tasca; Lyra deve costruirseli, e in un anno non ce la
fa quasi mai.

Il preventivo di [D-197](DECISIONS.md#d-197) diceva A_STONE **79%** e A_GARRISON
**74,8%**, e la media era giusta: 100 + 100 + 100 + 4,5 fa 76. **La media
nascondeva che una casa su quattro è fuori.** È esattamente il difetto per cui
questa sonda è stata scritta.

E l'istogramma lo conferma: Lyra chiude con **0 obiettivi 16 volte su 60, 1
obiettivo 31 volte, e 4 obiettivi mai**. Parte ogni anno con due carte morte in
mano su quattro.

### Tre difetti trovati per strada, che non riguardano Lyra

- **«Pietra sopra Pietra» non si avvera mai: 0 su 64 pescate**, tutte e quattro
  le case. Chiede una struttura di **grado 2 o più**. Il grado 2 esiste nei dati
  — Castello, Borgo, il Grande Granaio, la Dogana — ma **niente in partita ci
  arriva**. L'obiettivo è già scritto e aspetta una regola che non c'è: è il
  buco che [ISSUES 39](#39-la-terra-che-si-vede-pedine-di-carta-o-strutture-con-una-vita)
  opzione **C** — torre → castello → reggia — riempirebbe da sola.
- **«L'Opera che Porta il Nome»: 4 su 68, il 5,9%.** Chiede un'opera — granaio,
  canale, pedaggio — e nessuna di quelle è sulla mappa all'apertura.
- **Il palese di Vaerax, «La Terra che Risponde»: 0 su 20.** Un obiettivo palese
  che non si avvera mai è una casa che gioca con tre carte invece che con
  quattro.

### Le due strade per Lyra, e sono decisioni di contenuto

1. **Lyra apre con una struttura sua**, come le altre tre. Non un presidio — non
   è una casa di mura — ma qualcosa che la racconti: una biblioteca, un
   osservatorio. Costa una riga di `starting_structures` e un tipo nuovo.
2. **I due obiettivi smettono di essere gratis per chi apre col presidio**:
   alzando la soglia a due strutture diventano un traguardo per tutti invece di
   una spunta per tre.

E c'è una terza cosa che aiuta senza toccare gli obiettivi: **spostare Lyra
sulla Strada dei Mercanti** ([D-208](DECISIONS.md#d-208)) le fa crollare i NONE
da 21 a 8 e salire le Vittorie da 11 a 27.

### E non è un problema di Lyra: è una regola dell'apertura

La stessa forma si ripete **nell'altra linea, con un'altra casa**. In CHR_03
`starting_structures` posa uno `STR_KEEP` alle Città Libere, alla Gilda del Sale
e alla Cenere. **All'Ordine del Vetro niente.**

| linea | la casa senza presidio d'apertura | NONE su 120 anni | TRIONFI |
|---|---|---|---|
| il Grano | **Lyra** | **44** | **0** |
| il Sale | **l'Ordine del Vetro** | **43** | 1 |
| le altre tre, Grano | Aldric / Nahr / Vaerax | 28 / 26 / 24 | 1 / 0 / 2 |
| le altre tre, Sale | Cenere / Libere / Sale | 14 / 20 / 29 | 1 / 2 / 1 |

E in tutte e due, fra le clausole del Minimo più spesso mancate c'è letteralmente
**«Almeno un presidio suo»** — Lyra 18 volte, il Vetro 17.

**In tutte e due le linee, la casa che apre senza presidio è la casa che non
vince mai.** Non è una taratura di Lyra: è il setup d'apertura che distribuisce
tre presidi su quattro e lascia scoperta la stessa casella in tutte e due le ere.

Quindi qualunque cosa si decida per Lyra **va decisa anche per l'Ordine del
Vetro**, e la voce cambia titolo di fatto: non «Lyra non trionfa» ma **«la
quarta casa non trionfa, in nessuna era»**.

**Fatto quando** nessun seggio sta a zero Trionfi su 120 seggi-anno **in
nessuna delle due linee**, nessuna coppia seggio × obiettivo sta sotto il 10%
mentre le altre tre stanno sopra il 90%, e lo scarto fra il seggio più premiato
e il meno premiato sta dentro un fattore tre.

---

---

## Come si aprono

Ogni voce qui sopra è già un'issue: il titolo dopo il numero, le etichette e la
milestone dalla riga sotto, il resto come corpo. Chi le apre segna il numero
GitHub accanto al titolo, così questo documento resta l'indice e non una seconda
verità.
