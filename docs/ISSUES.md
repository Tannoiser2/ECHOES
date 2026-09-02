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

**Una voce chiusa porta il ✅ nel titolo**, ed è l'unico segno che conta: il
foglio `LE_TUE_DECISIONI.md` si conta da lì, e `tools/issues_survey.py` va rosso
se una voce dice «chiusa in 0.1.x» e il titolo non ce l'ha. Non è pedanteria —
tredici voci chiuse ne erano senza, e il conto che il committente leggeva per
decidere era sbagliato di tredici ([D-391](DECISIONS.md#d-391)).

Legenda etichette: `regola` · `contenuto` · `arte` · `motore` · `ux` ·
`strumenti` · `da-misurare` · `decisione` · `debito` · `da-decidere` (quest'ultima
è quella che mette una voce sul foglio delle decisioni)

**Un nome in corsivo senza collegamento** — *SEDUTA_TERRA*, *AUDIT_DESTINI*,
*MECCANICA* — è un documento **tolto in 0.1.291**
([D-328](DECISIONS.md#d-328)): la decisione che conteneva è a verbale in
`DECISIONS.md`, il documento no. Si legge nella storia di git.

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
al tavolo. Vedi *AUDIT_DESTINI* §2.3.

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
*AUDIT_DESTINI*.

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
   è in *TRASFORMAZIONI*: ~17 vite con ingresso
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
   *SEDUTA_VITE*. **Le tre vite della decisione C sono
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
   verbale sono in *SEDUTA_LEGGENDA*.

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
(sonda in `tag_census`, tolta in 0.1.291) dice dove eravamo: **79 segni** scritti da
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

`contenuto` · `regole` · voluta dal committente · **in seduta** (*SEDUTA_LINEE*)

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

### 35. ✅ Le istituzioni **non** governano diversamente dalle persone

`contenuto` · **chiusa in 0.1.144** · *SAGA_SALE* → [D-176](DECISIONS.md#d-176)

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
*SEDUTA_TAVOLO*.

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
*MECCANICA §15*, fra le nove cose che i numeri dicono a chi gioca.*

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
(*SEDUTA_TERRA*) · nata da [D-154](DECISIONS.md#d-154)

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
catalogo sta in *SEDUTA_TERRA §8*: da cinque tag a una ventina
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

> **Rimisurato in 0.1.299**, con `cli/run_stone_probe.gd` su 100 partite, tavolo
> misto, semi da 7000 — il numero qui sopra non lo rifaceva nessuno da allora, e
> lo dichiarava la sonda stessa.
>
> | | su 30 Chronicle | **su 100 partite** |
> |---|---|---|
> | alzate | 74 — 2,5 a partita | **1062 — 10,62 a partita** |
> | abbattute | **zero** | **24** — 0,24 a partita |
> | andate in rovina | non misurato | **50** — 0,50 a partita |
> | salite di grado | non misurato | **142** — 1,42 a partita |
> | **scese di grado** | non misurato | **0** |
> | in piedi a fine anno | 2 a partita | **8,98** a partita, 1,50 di grado 2+ |
>
> **Due cose sono cambiate e una no.**
>
> Le Pietre si alzano **quattro volte piu' spesso** di quanto diceva il numero
> vecchio, e **non e' piu' vero che zero vengono abbattute**: ventiquattro
> cadono, e cinquanta vanno in rovina perche' nessuno ha ottenuto quello che
> voleva. La mappa non puo' piu' soltanto riempirsi — su questo la strada C ha
> gia' vinto.
>
> **Quello che non e' cambiato e' il verso.** Una Pietra sale di grado 142 volte
> e **non scende mai**: zero su cento partite. Il grado e' una scala a senso
> unico, e o cade tutta la Pietra o resta dov'e' arrivata.
>
> **E la domanda di ISSUES 52 ha una risposta**: *«una casa puo' decidere di
> costruire?»* Delle 1062, **856 le posa l'apertura** e solo **206 il Consiglio o
> un'Eco** — quattro Pietre su cinque le distribuisce l'allestimento, non l'anno.
> Un obiettivo che chiede una struttura lo decide il setup nell'80% dei casi.
>
> **Un avvertimento sulla misura**, che vale per tutte le righe qui sopra:
> nessuno di questi gesti lascia un segno che `MISURA_SEGNI` sappia contare —
> il segno del grado si scrive **dentro** l'effetto che costruisce la Pietra.
> E' [ISSUES 102](#102-misura_segni-conta-due-categorie-su-cinque-e-non-vede-niente-di-quello-che-posa-una-pietra).

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

---

## La strada A era già percorsa, e nessuno l'aveva chiusa (0.1.186)

Il criterio qui sopra chiedeva «le pedine mosse per scelta ben sopra una a
partita». Dopo che le azioni sono passate sulle carte ([D-188](DECISIONS.md#d-188))
e sono state pareggiate fra le famiglie ([D-215](DECISIONS.md#d-215)), **MUOVERE
si gioca 3,79 volte l'anno**. Il criterio è superato da due decisioni che non
erano state scritte come risposta a questa voce.

## La strada C, misurata e spedita ([D-218](DECISIONS.md#d-218))

`run_stone_probe` ha rimisurato «74 costruite, zero abbattute» su 100 partite:

| | prima | **dopo** |
|---|---|---|
| pietre alzate in tutto | 14,53 a partita | 15,43 |
| — **dall'apertura** | **13,02** | 13,02 |
| — **dal gioco** | **1,51** | **2,41** |
| **abbattute** | **0,00** | **0,43** |
| salite di grado | **0,04** | **1,82** |
| grado 2+ in piedi a fine anno | 0,56 | **2,34** |

**Il 90% delle pietre le posava il setup, e in cento anni non ne veniva giù
nessuna.** Tre righe l'hanno cambiato: le pietre salgono su VICTORY e non solo
su TRIUMPH; l'Archivio si può **costruire** impegnando la carta omonima — che era
l'unica delle 48 senza un mestiere, e adesso è l'unico modo che una casa ha di
*decidere* di costruire; e l'Assedio **butta giù** il presidio della Regione
della domanda.

**Resta aperto un punto solo, e ha una causa precisa**: «Pietra sopra Pietra»
è ancora 0 su 100, perché la salita di grado arriva **dopo** il conteggio degli
obiettivi — vale per l'anno successivo, non per quello in cui è successa. Serve
un modo di alzare un grado **durante** l'anno.

**Fatto quando** una struttura può salire di grado dentro l'anno per una scelta
di chi gioca, e «Pietra sopra Pietra» smette di stare a zero.

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

### 40. ✅ Il grado non si muove dentro l'anno — CHIUSA in 0.1.364: era decisa da duecento versioni

`regola` · **decisa in 0.1.142** · [D-167](DECISIONS.md#d-167) → [D-174](DECISIONS.md#d-174)

**chiusa in 0.1.364** ([D-396](DECISIONS.md#d-396))

> **La voce chiedeva di scegliere fra due strade, e la scelta e' stata fatta in
> 0.1.142**: il grado alto resta materia di saga. La regola che ne segue e'
> scritta qui sotto, e i dati la seguono. Non c'era altro da fare, e la voce e'
> rimasta aperta **duecentoventi versioni dopo la sua decisione**.

`_settle_structures` gira **dopo** la valutazione del Destino, quindi in una
Chronicle sola il grado non sale quasi mai: grado 2 nel 15% degli anni per
Aldric e nello 0% per cinque case su otto, grado 3 **mai**.

La voce chiedeva di scegliere fra due strade. **Scelta la prima: il grado alto
resta materia di saga.** La scala che segue il Destino ([D-159](DECISIONS.md#d-159))
vale proprio perché una reggia non si compra in una sera — è il sedimento di tre
anni buoni, e la *saga del Regno che si è seduto* lo mostra meglio
di qualsiasi misura: villaggio 812, borgo 813, granaio 814, città 815, castello
816, **reggia 818**.

**La regola che ne segue:** una clausola sul grado 2 o 3 si scrive **solo nei
Destini di una Chronicle successiva**, mai in quelli d'apertura. Chi la scrive
altrove sta scrivendo un muro.

### 41. ✅ Il sito antico, una volta aperto, veniva sempre saccheggiato

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

### 42. ✅ La seconda saga sembrava più generosa della prima

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

### 43. ✅ Undici Destini su venti non si giocano mai all'apertura

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

### 44. ✅ La scala di Lyra ha una porta sola, e aprirla costa gli anni tranquilli

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

### 45. ✅ La linea dei Fuochi — CHIUSA in 0.1.362: sta nella banda delle altre

`contenuto` · `bilanciamento` · **metà chiusa in 0.1.145** · nata da
[D-176](DECISIONS.md#d-176) → [D-177](DECISIONS.md#d-177) ·
**chiusa in 0.1.362** ([D-394](DECISIONS.md#d-394))

> **La condizione era: «la linea dei Fuochi sta nella stessa banda delle altre
> in ogni sua incarnazione».** Ci sta, su tutt'e due i tavoli del cancello,
> cento anni:
>
> | Kessa dei Fuochi | NONE | MINIMO | VITTORIA | TRIONFO |
> |---|---|---|---|---|
> | tavolo misto | 14 | 19 | 24 | 0 |
> | tavolo uniforme | 8 | 24 | 24 | 1 |
>
> E la vita che la voce dava per la piu' debole — **Le Custodi della Cenere**,
> allora al 22% — oggi e' la **seconda vita piu' seduta** delle diciotto: 12
> volte su tavolo uniforme e 12 su misto, in dodici saghe
> ([MISURA_VITE.md](MISURA_VITE.md)). Il residuo scritto qui sotto era misurato
> sulla **saga del Sale**, cancellata in [D-318](DECISIONS.md#d-318).

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

### 46. ✅ La campagna del Sale ha un vincitore già scritto — CHIUSA in 0.1.362: la campagna non c'e' piu'

`contenuto` · `bilanciamento` · nata da [D-180](DECISIONS.md#d-180) ·
**aperta in 0.1.148** · **chiusa in 0.1.362** ([D-394](DECISIONS.md#d-394))

> **La saga del Sale e' `CHR_03`, cancellato in
> [D-318](DECISIONS.md#d-318).** Il difetto misurato qui — *«SALE 12 su 12»* —
> era su un anno che non esiste piu'. Sull'anno che esiste il cancello misura
> **0 seggi bloccati su un solo livello su 8**, sui due tavoli, a ogni
> decisione. Chiusa perche' il suo oggetto non e' piu' nella scatola, non
> perche' sia stata curata.

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

### 48. ✅ La Strada dei Mercanti è una Regione morta — CHIUSA in 0.1.362: e' la seconda piu' viva

`regole` · `contenuto` · **misurata in 0.1.154** ([D-186](DECISIONS.md#d-186)) ·
**chiusa in 0.1.362** ([D-394](DECISIONS.md#d-394))

> **La Strada dei Mercanti non e' piu' morta: e' la seconda Regione piu'
> abitata della mappa.** Cento anni, tavolo misto, `cli/run_move_probe.gd`,
> media **sugli anni in cui la tessera e' pescata** — che e' il taglio che
> mancava alla misura di prima, e che da solo cambiava i numeri di un terzo:
>
> | Regione | pescata | apertura → fine |
> |---|---|---|
> | Eredan | 51 | 2,12 → **2,53** |
> | **Strada dei Mercanti** | 60 | 1,07 → **2,23** |
> | Valle Verde | 59 | 1,66 → 2,19 |
> | Miniere Antiche | 53 | 2,06 → 2,09 |
> | Terre Nahr | 63 | 0,68 → 1,51 |
> | Porto Cinerino | 75 | 0,12 → 1,37 |
> | Montagne Rosse | 64 | 1,08 → 1,30 |
> | Bosco dei Confini | 63 | 0,17 → 0,94 |
> | Palude dei Canali | 56 | 0,07 → 0,84 |
> | **L'Isola Muta** | 56 | 0,18 → **0,50** |
>
> **Il residuo, e va scritto**: la Regione piu' vuota adesso e' l'**Isola Muta**
> a mezza pedina, e non e' un difetto ma la regola — da
> [D-393](DECISIONS.md#d-393) e' l'unica tessera con due lati chiusi, cioe'
> un'isola con due approdi. Se il committente vuole che ci si viva, le serve un
> terzo varco: e' una riga di dato, e non apre una voce nuova.

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

## Metà chiusa in 0.1.181: nel Grano non c'è più una Regione vuota ([D-212](DECISIONS.md#d-212))

Il committente ha deciso anche il secondo rimedio: **«Lyra sulla Strada dei
Mercanti»**. Lyra apre con Miniere Antiche + Strada invece di Miniere Antiche +
Eredan, e la Strada smette di essere deserta all'apertura.

| Regione (Grano), apertura → fine | 0.1.180 | **0.1.181** |
|---|---|---|
| Eredan | 2,00 → 1,96 | 1,00 → 1,63 |
| Miniere Antiche | 2,00 → 2,69 | 2,00 → 2,66 |
| Montagne Rosse | 1,00 → 1,73 | 1,00 → **1,78** |
| **Strada dei Mercanti** | **0,00 → 1,20** | **1,00 → 2,07** |
| Terre Nahr | 1,00 → 1,61 | 1,00 → 1,86 |
| Valle Verde | 2,00 → 2,78 | 2,00 → 1,91 |

**Nel Grano nessuna Regione apre a zero e nessuna finisce sotto 1,78**, e la
Strada è la seconda più affollata a fine anno: è lo snodo che la voce chiedeva.
Il prezzo sono le quattro storie scritte a mano, che adesso **dichiarano la
mappa in cui sono state scritte** (`starting_presence`) invece di cambiare in
silenzio.

**Resta aperta la metà del Sale.** Lì la Regione vuota sono le **Terre Nahr**
(0,00 all'apertura), e i Nahr non esistono in quella linea: le case sono Sale,
Cenere, Vetro e Città Libere, e **tre di loro aprono su Eredan**. Chi si sposta
sulle Terre Nahr è una scelta di contenuto, non una manopola, e va decisa dal
committente.

### Il preventivo per il Sale, misurato: due candidati, 100 semi, seme 7000

Nessuno dei due è stato spedito — chi vive dove è contenuto. Ma il prezzo è
misurato, così la decisione si prende su numeri e non su un'idea.

| | oggi | **Vetro → Terre Nahr** | **Città Libere → Terre Nahr** |
|---|---|---|---|
| Terre Nahr, apertura → fine | **0,00** → 0,83 | 1,00 → 1,85 | 1,00 → 1,82 |
| Eredan, apertura | 3,00 | 2,00 | 2,00 |
| Regione più magra a fine anno | Terre Nahr **0,83** | Valle Verde **1,02** | Strada **1,44** |
| Priore Anselmo (il Vetro) NONE / TRIONFI | 5 / 0 | **10** / 0 | **12** / **2** |
| Le Città Libere NONE / TRIONFI | 10 / 1 | 10 / 1 | **5** / **3** |
| Maestra Ilve NONE / TRIONFI | 14 / 0 | 12 / 0 | **18** / 1 |
| Kessa (la Cenere) NONE / TRIONFI | 3 / 0 | 5 / 1 | 5 / 1 |
| playtest 100 semi | 0/8 | **0/8** | **0/8** |

**Tutti e due riempiono le Terre Nahr e nessuno dei due rompe il cancello.** La
differenza è dove va il conto:

- **Spostare il Vetro cura la mappa e aggrava [ISSUES 52](#52-lyra-non-ha-mai-trionfato-in-centoventi-anni)**: la casa
  già senza presidio d'apertura passa da 5 a 10 NONE e resta a zero Trionfi, e
  gli anni chiusi con zero obiettivi salgono da 16 a 22. E svuota la Valle
  Verde, che scende a 1,02 — la Regione magra si sposta, non sparisce.
- **Spostare le Città Libere dà la mappa più piatta** — nessuna Regione sotto
  **1,44** — e regala al Vetro i suoi **primi 2 Trionfi**, ma fa pagare Maestra
  Ilve (NONE 14 → 18), che resta sola su Eredan.

**La raccomandazione, e il perché.** Le **Città Libere**: è l'unico dei due che
lascia la mappa senza una Regione magra, ed è anche l'unico che non peggiora la
casa che [ISSUES 52](#52-lyra-non-ha-mai-trionfato-in-centoventi-anni) dice già
in difficoltà. Regge anche la lettura: le città che si sono liberate stanno
nelle terre di un popolo che non c'è più, mentre l'Ordine del Vetro *«custodisce
quello che fu misurato»* — le Miniere e la capitale.

## E poi le due linee non ci sono più (0.1.182, [D-213](DECISIONS.md#d-213))

Il committente ha spostato di nuovo la domanda, e stavolta ha tolto il terreno
sotto la voce: *«non voglio due ere, voglio un unico setup»*. Le case adesso si
pescano — 8 candidate, 4 si siedono — quindi **non esiste più «la linea del
Sale»** in cui le Terre Nahr sono vuote. Ogni tavolo è diverso, e quale Regione
apre deserta dipende dal seme.

Il preventivo qui sopra resta scritto perché il suo numero utile sopravvive:
**quattro case su otto aprono su Eredan o accanto** (Aldric, Vetro, Sale,
Libere), e questo squilibrio è ancora nel dato. Ma la domanda «quale casa mettere
sulle Terre Nahr» non ha più una risposta sola: dipende da chi siede.

**La voce cambia criterio.** Non più «nessuna Regione apre a zero in nessuna
delle due linee», ma: **nessuna Regione resta deserta più spesso di quanto sia
plausibile che nessuno ci abiti**, misurato su cento tavoli pescati invece che su
due tavoli scritti.

**Fatto quando** nessuna Regione sta sotto una pedina a fine anno, in media, su
100 semi a tavolo pescato.

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

## Metà fatta in 0.1.180: il tetto a 4 ([D-211](DECISIONS.md#d-211))

Provati **separatamente**, i due rimedi costano cose diverse — e questo il
preventivo non lo diceva:

- **il tetto a 4** rompe due prove che descrivevano il setup, e **nessuna
  storia**;
- **spostare la casa di Lyra** rompe **tutte e quattro** le storie scritte a
  mano, perché cambia la posizione d'apertura e con quella i Consigli di ogni
  piano.

Spedito il tetto. L'altra metà è **dove vive una casa**, cioè contenuto, e
aspetta il committente col prezzo ora scritto.

| | tetto 3 | **tetto 4** |
|---|---|---|
| gettoni di riserva per casa | 1,00 | **2,00** |
| MUOVERE l'anno (Grano / Sale) | 3,02 / 2,88 | **4,70 / 4,20** |
| bloccati dal gettone (Grano / Sale) | 71,2% / 74,4% | **40,6% / 47,5%** |
| Strada dei Mercanti (Grano) | 0,00 → 0,65 | 0,00 → **1,20** |
| Terre Nahr (Sale) | 0,00 → 0,55 | 0,00 → **0,88** |
| Consigli l'anno (unif. / misto) | 3,40 / 3,57 | **3,57 / 3,86** |
| playtest 100 semi | 0/8 | **0/8** |

**Nel Grano la voce è soddisfatta**: nessuna Regione finisce l'anno sotto 1,20
pedine, e la Strada non è più deserta. **Nel Sale no**: le Terre Nahr restano a
**0,88**, sotto una pedina, perché lì non comincia nessuno — la causa che D-208
aveva nominato e che il tetto non tocca.

E **spostare continua a non succedere**: 0,03 l'anno nel Grano, 0,00 nel Sale.
Più pedine da posare non sono una mappa che si disfa.

**Resta da decidere**, e sono due decisioni di contenuto gemelle:

1. **chi comincia sulla Strada dei Mercanti** nel Grano — misurato: Lyra ci
   porta la Regione a 1,00 → 1,57, e cura mezza ISSUES 52; costa le quattro
   storie;
2. **chi comincia sulle Terre Nahr** nel Sale — non ancora misurato.

**Fatto quando** nessuna Regione sta sotto una pedina a fine anno **in nessuna
delle due ere**, e la sonda continua a nominare la più povera così nessuno se la
ritrova per caso.

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
con `PolicyDecider` la produce (*CONSEGNE §5ter*).

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

### 52. ✅ Lyra non ha mai trionfato in centoventi anni — CHIUSA in 0.1.362

`bilanciamento` · `contenuto` · **aperta in 0.1.175** · nata dal resoconto della
saga 812 · **chiusa in 0.1.362** ([D-394](DECISIONS.md#d-394))

> **Lyra oggi e' il seggio migliore del tavolo uniforme.** Cento anni, il
> cancello:
>
> | Lyra | NONE | MINIMO | VITTORIA | TRIONFO |
> |---|---|---|---|---|
> | allora (120 seggi-anno, linea del Grano) | **37** | — | — | **0** |
> | tavolo misto, oggi | 12 | 14 | 22 | 0 |
> | tavolo uniforme, oggi | **3** (il minimo del tavolo) | 19 | 23 | **3** |
>
> Il difetto che la voce nominava — *una casa che non arriva mai in cima mentre
> le altre ci arrivano* — non c'e' piu'.
>
> **E la condizione scritta («nessun seggio a zero Trionfi») non si puo'
> giudicare a questo passo**, e va detto invece di far finta: i Trionfi sono
> **5 su 400 seggi-anno** a tavolo misto e 10 su 400 a uniforme. Con un seggio
> che ne aspetta mezzo, uno zero non distingue una casa debole da una fortunata.
> Quello che sorveglia la cosa e' il vincolo del cancello — **0 seggi bloccati
> su un solo livello su 8** — e quello si misura a ogni decisione.

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

## Metà rimedio spedito in 0.1.181: Lyra si sposta ([D-212](DECISIONS.md#d-212))

La «terza cosa che aiuta senza toccare gli obiettivi» è stata decisa dal
committente ed è spedita. Su 100 semi, seme 7000:

| Lyra | a Eredan | **sulla Strada** |
|---|---|---|
| NONE, tavolo uniforme | 16 | **8** |
| VITTORIE, tavolo uniforme | 10 | **28** |
| NONE, tavolo misto | 17 | **8** |
| VITTORIE, tavolo misto | 12 | **22** |
| anni con **zero** obiettivi presi | 35 | **20** |
| anni con **tre** obiettivi presi | 7 | **19** |

**Lyra smette di essere la quarta casa, ma non trionfa lo stesso**: 0 Trionfi su
tutti e due i tavoli, contro 1 e 1 di prima. Il pavimento si alza e il tetto si
abbassa — e i TRIONFI di tutto il tavolo calano da 10 a 8 (uniforme) e da 5 a 2
(misto). Il criterio di chiusura di questa voce chiede **zero seggi a zero
Trionfi**, e questo rimedio va nella direzione opposta su quella riga.

**Quindi la voce resta aperta, e con la stessa causa scritta sopra**: le due
strade vere sono ancora la struttura d'apertura per Lyra e per il Vetro, o la
soglia alzata sui due obiettivi gratis. Spostare una casa cura la sua posizione;
non le mette in mano le due carte che le altre tre trovano già in tasca.

**E l'Ordine del Vetro non è stato toccato**: nella linea del Sale la quarta
casa è ancora senza presidio d'apertura, e il rimedio della posizione lì non è
nemmeno stato deciso — è la stessa domanda aperta di ISSUES 48.

## La causa è sopravvissuta all'unificazione (0.1.182, [D-213](DECISIONS.md#d-213))

Con le case pescate da un mazzo solo, «la quarta casa» non è più una posizione
al tavolo — ma la causa non era il tavolo, era il **dato d'apertura**, e quella
è rimasta identica: `starting_structures` è passato dalla Chronicle all'Entità
(così la pietra segue la casa), e **sei case su otto ce l'hanno**. Lyra e
l'Ordine del Vetro no.

| casa | pietra d'apertura |
|---|---|
| Aldric, Nahr, Vaerax, Sale, Cenere, Città Libere | **sì** (presidio, e per due anche un insediamento) |
| **Lyra, Vetro** | **niente** |

Adesso però il rimedio costa **una riga per casa** invece di una riga per
Chronicle, ed è la stessa riga per tutte e due: la strada 1 qui sopra — «Lyra
apre con una struttura sua, non un presidio ma qualcosa che la racconti» — si
scrive sull'Entità e vale in ogni tavolo che la peschi.

Nella saga lunga i TRIONFI restano **3 su 288 seggi-anno**, come prima
dell'unificazione: il cambio non ha toccato la scala, e questa voce è ancora
quella che deve toccarla.

## Metà chiusa in 0.1.186: l'Archivio ([D-217](DECISIONS.md#d-217))

Lyra e il Vetro aprono con **`STR_ARCHIVE`** — famiglia `STUDIO`, che è nuova e
sta da sola apposta: metterlo fra le OPERA avrebbe ribaltato il difetto invece
di toglierlo.

| 100 semi | prima | dopo |
|---|---|---|
| anni con **zero** obiettivi, il Vetro | **18** | **12** |
| anni con **zero** obiettivi, Lyra | 7 | **6** |
| anni con due obiettivi, Lyra | 13 | **19** |
| anni con due obiettivi, il Vetro | 9 | **16** |
| «Qualcosa che Resta in Piedi», la casa peggiore | **6,7%** | **68,8%** |

**La carta che divideva il tavolo in due non lo divide più.** Ma la voce resta
aperta, e su tre punti precisi:

1. **«Il Muro che Tiene» è ancora 0–100%.** Chiede un **presidio**, e l'Archivio
   non lo è. Alzare la soglia a due è stato provato e **misurato come peggiore**:
   0–11%, cioè una carta morta invece di una spunta.
2. **«Pietra sopra Pietra» resta 0 su 100**, ora con la causa precisa: le pietre
   salgono di grado **dopo** che gli obiettivi sono contati.
3. **I TRIONFI restano rari.** L'Archivio alza il pavimento, non il tetto.

**Fatto quando** nessuna coppia seggio × obiettivo sta sotto il 10% mentre le
altre stanno sopra il 90%.

---

---

### 54. ✅ Otto coppie di case restano neutrali per quota, non per scelta — chiusa in 0.1.187

`contenuto` · **aperta in 0.1.185** ([D-216](DECISIONS.md#d-216))

Le sedici coppie incrociate sono state scritte **otto calde e otto neutrali**, e
il criterio era la densità dei due tavoli d'autore (2 coppie calde su 6 nel
Grano, 4 su 6 nel Sale). Il numero torna — 2,94 calde per tavolo — ma **almeno
una delle otto neutrali è rimasta neutrale per far quadrare la quota**, non
perché non ci fosse niente da dire:

| coppia | cosa ci sarebbe da dire |
|---|---|
| **Lyra ↔ la Gilda del Sale** | una legge registri, l'altra li tiene. È il legame più evidente dei rimasti |
| **Lyra ↔ la Cenere** | la Cenere scava la miniera che Lyra è scesa a misurare |
| **il Popolo Nahr ↔ la Cenere** | due case che vivono di quello che la terra lascia |
| **Vaerax ↔ le Città Libere** | sette città che si governano da sole, e una cosa antica che non riconosce nessun governo |

**Non è un difetto di bilanciamento**: alzare la quota sopra 2,94 renderebbe un
tavolo pescato *più caldo* di quelli scritti a mano, che è il contrario di quello
che D-216 cercava. È una domanda di contenuto: **se una di queste diventa calda,
un'altra deve raffreddarsi**, e quale coppia merita la storia lo decide chi
scrive il mondo.

**Fatto quando** ogni coppia neutrale lo è per una ragione scritta — «queste due
non si sono mai incontrate», «si ignorano per scelta» — e non per aritmetica.

## Chiusa in 0.1.187 ([D-219](DECISIONS.md#d-219))

Serviva un posto dove metterla: **`relations[].note`**, obbligatoria, scritta per
tutte e **28** le coppie — non solo le sedici nuove, perché le dodici d'autore
avevano la loro ragione nelle descrizioni delle case e lasciarle mute avrebbe
fatto sembrare *loro* quelle di comodo. La guardia la confronta fra le due
scritture insieme al livello e ai tag.

**Uno scambio, e col motivo.** Lyra ↔ la Gilda del Sale diventa **alleata** —
tengono tutte e due dei registri, per ragioni opposte — e Aldric ↔ la Cenere
torna **neutrale**, perché «due case di POTERE sulla stessa terra» è una
categoria e non una storia; adesso il silenzio è una scelta.

**I numeri reggono** (200 semi): tavoli piatti **0,0%**, coppie calde per tavolo
**2,94 → 2,88**, e le due facce si pareggiano — alleanze/ostilità da **1,22/1,72**
a **1,42/1,47**. Playtest **0/8**.

**Resta dichiarato**: la nota **non arriva al tavolo**. È dato per chi scrive il
mondo e per le guardie; nessuna interfaccia oggi la mostra.

---

### 59. Due verbi su cinque non si giocano, e una famiglia su sei e' inerte

`regole` · `bilanciamento` · **misurata in 0.1.194** (`cli/run_card_ledger.gd`)

Il committente ha chiesto se le carte «fanno qualcosa» e se azioni ed effetti
sono ben bilanciati. Il libro mastro delle carte lo misura per la prima volta:
**100 anni, tavolo misto, 5.793 carte pescate.**

**Quello che sta bene, e va detto per primo.** Nessuna carta e' contenuto morto:
zero mai in mano, **zero mai impegnate al voto**, quindi tutti e quarantotto gli
effetti propri girano almeno una volta — molto meglio delle Conseguenze, dove
dieci su cinquantadue non escono mai (voce 56). E la scelta al centro del gioco
funziona, con una curva pulita:

| forza | calata per agire | impegnata al voto | impegnate per ogni calata |
|---|---|---|---|
| 1 | 20,0% | 38,2% | **1,91** |
| 2 | 16,8% | 58,7% | 3,49 |
| 3 | 13,9% | 59,4% | **4,26** |

Le carte deboli si spendono, le forti si tengono per il voto. *«La spendo per
fare o la tengo per votare»* non e' una frase sul regolamento: si vede.

**Il difetto.** [D-215](DECISIONS.md#d-215) aveva bilanciato **quante carte
portano ogni verbo nel mazzo** (scarto 1,85× → 1,38×). Nessuno aveva mai
misurato quanto ogni verbo viene **usato**:

| azione | volte in mano | calata | % |
|---|---|---|---|
| **MOVE** | 1.072 | 407 | **38,0%** |
| INFLUENCE | 1.212 | 273 | 22,5% |
| CLAIM | 975 | 177 | 18,2% |
| **SCHEME** | 1.339 | 133 | **9,9%** |
| **FORGE** | 1.195 | 100 | **8,4%** |

**4,5× di scarto.** FORGE e SCHEME insieme sono 2.534 carte passate per una mano
e 233 azioni. Il mazzo e' bilanciato; **l'uso no**.

Da li' scende il resto:

- **WEALTH e' la famiglia inerte**: 8,7% di carte calate contro il 26,7% di
  BONDS, cioe' 3,1×. Non e' un caso — **quattro delle otto carte WEALTH portano
  FORGE o SCHEME**.
- **Quattro carte non vengono mai calate per agire in cento anni**: «Ostaggio»,
  «Credito», «Chiavi del Granaio», «Ipoteca sulle Terre». Non e' che non
  arrivino: **«Credito» e' stata in mano 140 volte**. La loro azione non e' mai
  valsa la spesa.
- **Il 41,9% delle carte di forza 1 non fa mai niente**, ne' calata ne'
  impegnata: resta in mano e scade.

**La causa, per come si legge.** FORGE muove di un passo una relazione, SCHEME
legge un'informazione privata. **Nessuno dei due tocca la mappa, e nessuno dei
due entra nel voto** — e il cervello ([D-222](DECISIONS.md#d-222)) insegue gli
obiettivi, che parlano di Regioni, pietre e cicatrici.

E' la voce 55 vista da un'altra finestra, e va decisa insieme a quella: **se la
mappa pagasse al Concilio, tenere una relazione o sapere una cosa varrebbero
qualcosa.** Ritoccare FORGE e SCHEME da soli, prima di quella mossa, vorrebbe
dire tarare due verbi contro un'economia che sta per cambiare.

**Fatto quando** nessun verbo si gioca meno della meta' del piu' giocato, nessuna
famiglia e' calata meno della meta' della piu' calata, e ogni carta viene calata
per agire almeno una volta su cento anni — col playtest ancora **0/8**.

---

### 60. Una domanda su dodici resta zitta meta' delle volte che esce

`contenuto` · `bilanciamento` · **misurata in 0.1.194** (`cli/run_question_ledger.gd`)

Stesso giro, dal lato delle domande: **100 anni, 446 Concili.**

**Quello che sta bene:** tutte e dodici vengono pescate e **tutte e dodici aprono
almeno un Concilio.** Nessuna domanda e' irraggiungibile — la voce 51 e' chiusa
davvero.

**Il difetto e' il peso, non l'esistenza:**

| domanda | pescata | Consigli | anni in cui apre qualcosa |
|---|---|---|---|
| La Successione | 44 | **76** | **97,7%** |
| La Carestia | 33 | 50 | 97,0% |
| Il Risveglio | 25 | 47 | 88,0% |
| La Carta | 24 | 18 | 58,3% |
| Le Vie Interrotte | 30 | 24 | 53,3% |
| I Pozzi Bassi | 24 | **12** | **45,8%** |

La Successione apre **1,73 Concili per ogni anno in cui e' in gioco**; I Pozzi
Bassi **0,50**. Un fattore **3,5**.

E la riga che pesa di piu': **piu' della meta' delle volte che «I Pozzi Bassi»
viene pescata, non viene mai dibattuta.** Occupa uno dei quattro posti dell'anno
e non ci arriva.

**Due sbilanci si sommano invece di compensarsi.** La pesca stessa non e'
uniforme — 24 volte contro 44, cioe' 1,83× — per il peso ×3 dell'eco
([D-079](DECISIONS.md#d-079)): una domanda i cui segni sono sul tavolo torna piu'
spesso. Ed e' anche quella che poi si scalda di piu'. **Chi e' avanti resta
avanti, anche fra le domande.**

**Da misurare prima di decidere:** se la disparita' venga dal **dominio** (quante
Regioni ascoltano quella domanda, e quanto traffico ci passa) o dalle **famiglie
rilevanti** (se una domanda ascolta famiglie che si giocano poco, si scalda
poco). Sono due difetti diversi con due rimedi diversi, e il secondo si lega alla
voce 59.

**Fatto quando** nessuna domanda apre meno della meta' dei Concili della piu'
ascoltata, e nessuna resta senza Concilio in piu' di un quarto degli anni in cui
e' in gioco.

---

### 100. Le caselle «si accende quando» sono ancora un pavimento derivato

`contenuto` · `regole` · `da-decidere` · aperta in 0.1.293
([D-330](DECISIONS.md#d-330)) · **riscritta in 0.1.294**
([D-331](DECISIONS.md#d-331)) · **due punti chiusi in 0.1.298**
([D-335](DECISIONS.md#d-335))

> **La prima stesura poneva la domanda sbagliata**, e l'avevo posta io: *«il Tema
> lo dichiara la carta o la Tensione?»*. La carta disegnata dal committente non
> chiede quello — dice *«questa Tensione riceve Calore quando **una carta**…»*,
> senza nominare il Tema di chi gioca. D-331 ha tolto il filtro; il Tema resta
> sulla carta, dove costa 48 dichiarazioni invece di 240 righe, e dove al tavolo
> si legge in mano invece che scandagliando sei Tensioni scoperte.
>
> Ci scriveva anche un errore: *«con 60 Tensioni e 48 carte la regola sta su
> meno posti dalla parte della Tensione»*. E' il contrario, e di cinque volte.

> **Due punti sono chiusi.** Il punto 4 — *una questione o tutte* — l'ha deciso
> il committente: si scaldano tutte (D-332). E il punto 3 non era una scelta ma
> un difetto: il ponte reggeva il 94,8% delle cadute perche' **48 righe su 66
> guardavano gesti che le Azioni non fanno mai** (D-335). Ripuntate, la casella
> decide il **29,6%**.

Quello che resta e' **d'autore**, e sono tre cose.

1. **Una sola carta e' scritta a mano.** `TEN_ENCLOSURE` porta le righe che il
   committente ha disegnato su *I Recinti*. Le altre 46 hanno un pavimento
   derivato da `focus_region_tags`, e il testo si vede che e' meccanico: *«una
   carta posa #fame o #requisito o #malcontento»*, *«una Presenza arriva o se ne
   va da una terra con #granaio»*. Al tavolo si legge, ma non e' una faccia
   finita.
2. **Tredici Tensioni non hanno la casella**, perche' non dichiaravano nessun
   `focus_region_tags` da cui derivarla. Per loro vale il ponte, e nessuno puo'
   leggere sulla carta perche' si scaldano. E **sono quasi tutte di rapporti** —
   *I Voti Non Sciolti*, *Il Diritto d'Asilo*, *La Vecchia Guardia*, *I Nomi
   Vecchi* — il che le lega al punto qui sotto.
3. **Manca il verbo dei rapporti.** `SET_RELATION` esce **159 volte** su
   vent'anni e nessuna riga puo' nominarlo. Non ho aggiunto `changes_relation`
   perche' oggi nessuna riga lo userebbe: le 47 derivate sono tutte di luogo, e
   un cambio di rapporto non e' un gesto su un luogo. Il verbo nasce **insieme**
   alle righe delle tredici, non prima.

**E un numero che va guardato mentre si scrivono queste facce:** ripuntare le
righe ha fatto scendere le **Verita' scritte** da 167 a 159 al tavolo misto (153
a 143 diverse), perche' i Consigli passano piu' puliti e un successo che non
costa niente lascia meno memoria. Ogni riga scritta a mano sposta quel numero:
va riletto a ogni carta finita, non alla fine.

**Il metro**: `cli/run_resonance_probe.gd` col ponte spento (121 su 409) e la
riga *...e di un Tema diverso dalla carta* (54). **Fatto quando** ogni riga
stampata e' scritta da chi scrive il gioco, e le tredici hanno la loro casella.

---

### 99. ✅ I dati portano ancora i nomi degli anni cancellati — chiusa in 0.1.292

`debito` · `strumenti` · aperta in 0.1.291 ([D-328](DECISIONS.md#d-328)),
**chiusa in 0.1.292** ([D-329](DECISIONS.md#d-329))

> **Fatto.** Le sette coppie sono fuse in un file solo ciascuna, chiamato col
> contenuto: `entities_core`, `destinies_core`, `tensions_core`,
> `consequences_core`, `echo_cards_core`, `regions_core`, e i template dei
> Consigli in `confluences/`. Le due cartelle degli anni morti non ci sono piu'.
>
> **E la voce ha trovato quello che nascondeva.** Il motore non se n'e' accorto
> (`data_set.gd` raccoglie ogni `.json` e indicizza per id), ma **quattro
> strumenti si', in silenzio**: cercavano i template dei Consigli in
> `chronicle_*/confluences/*.json`, e spostati quelli hanno prodotto documenti
> puliti e sbagliati — otto clausole impossibili che non lo sono, «Modelli di
> Consiglio: 0», 146 soggetti d'arte diventati 0, 670 righe di testi sparite.
> Nessuno dei quattro ha fallito.
>
> Curati con un aiutante solo, `items_of(schema_id)` in `echoes_schema.py`: un
> documento si cerca **per quello che dice di essere**, non per la cartella.
> Venti riferimenti a percorsi spariti.
>
> **La guardia**: `check_no_file_names_a_dead_chronicle` in `validate_data.py`,
> e il self-test passa da tre guardie a **quattro** — due nomi buoni che devono
> passare, due che devono mordere.
>
> **La prova che nessun dato e' cambiato**: i quattro documenti generati tornano
> identici, e il playtest da' gli stessi numeri di prima (0 seggi bloccati su 8,
> Consigli 3,41, Verita' 156).

Gli anni d'autore sono usciti in 0.1.281 ([ISSUES 93](#)), ma **i nomi dei file
no**. Dodici file di dati e due cartelle si chiamano ancora `*_chronicle_01` e
`*_chronicle_03`:

| | |
|---|---|
| `destinies/destinies_chronicle_01.json` + `_03` | **17 dei 23 Destini** che il gioco pesca (gli altri 6 stanno in `destinies_shared`) |
| `tensions/tensions_chronicle_01.json` + `_03` | **12 delle 60 Tensioni** (le altre 48 in `tensions_library`) |
| `consequences/consequences_chronicle_01.json` + `_03` | parte delle **64 Conseguenze** |
| `entities/entities_chronicle_01.json` + `_03` | le **8 case** |
| `echoes/echo_cards_chronicle_01.json` + `_03` | le **39 carte Echo** |
| `regions/regions_chronicle_01.json` | **tutte e 10 le tessere** |
| `chronicle_01/confluences/` + `chronicle_03/confluences/` | i **12 template** |

**Non e' roba morta: e' contenuto vivo con un nome che mente.** Ogni anno
pescato di CHR_00 usa questi file, e chi apre `regions_chronicle_01.json`
credendo di guardare un anno d'autore sta guardando la mappa della scatola.

**Il costo l'ha gia' pagato uno strumento.** `tools/build_review.py` nominava
`chronicle_01/chronicle_01.json`, cancellato con gli anni d'autore, e **moriva
all'avvio**: il documento che genera e' rimasto fermo settanta versioni perche'
nessun cancello lo guardava. Riparato in 0.1.291 leggendo a glob invece che a
lista di nomi, e adesso ha il suo cancello — ma la stessa trappola e' ancora
sotto ogni altro strumento che nomini un file per nome.

**Perche' non l'ho fatto adesso.** Un rinomino tocca i caricatori del motore, la
suite, i cancelli e i documenti generati insieme: e' un commit suo, misurato col
giro completo, non la coda di una pulizia di documenti.

**Fatto quando** nessun file sotto `godot/data/` nomina una Chronicle che non
esiste, e i dati che valgono per ogni anno stanno in file che non nominano
nessun anno.

---

### 98. Chiudere il circuito: ogni segno dichiara se pesa o se e' colore

`regola` · `strumenti` · **fuori dalla lista in 0.1.361** ([la lista](LE_TUE_DECISIONI.md)):
e' un metodo e genera lavoro all'infinito — la sua meta' utile e' la gialla G3,
che finisce · aperta in 0.1.290 · **direzione del
committente**:

> «Il prossimo lavoro non e' aggiungere contenuto, ma **chiudere il circuito**.
> Ogni tag deve avere una funzione verificabile: chi lo puo' scrivere; dove
> viene posato; chi lo legge; quale decisione abilita; quale
> Obiettivo/Destino/Confluence/Legacy modifica.
>
> Se un tag viene scritto ma non letto, e' **rumore**. Se viene letto ma non
> scritto, e' una **promessa falsa**. Se viene scritto e letto solo in modo
> narrativo, va marcato come **flavour** e non deve pesare sul bilanciamento.»

### Dove siamo, misurato

Incrociando `docs/REGISTRO_SEGNI.md` (chi scrive, chi legge) con
`docs/MISURA_SEGNI.md` (quanto scatta in 100 anni):

| | |
|---|---|
| segni scritti da qualcosa | **87** |
| che **pesano** — toccano un punto, una mossa o l'era dopo | **51** |
| **flavour** — letti solo dalla narrazione (pesca delle domande, Risonanza, la Regione di cui si discute) | **36** |
| **rumore** — scritti, letti da niente | **13** (gia' dichiarati uno per uno con la ragione) |
| **promessa falsa** — letti, mai scritti | **6** |

Dei 51 che pesano: **32 scattano** almeno una volta in cento anni, **5 mai**, e
**14 la misura non li vede** (vedi il difetto qui sotto).

**E solo sette scattano piu' di cento volte per secolo.** Sono il gioco:

| scatti/secolo | segno | cosa tocca |
|---|---|---|
| 522 | `condition:contested` | punto · mossa · domanda |
| 226 | `debt_called` | punto · mossa · domanda · **era dopo** |
| 214 | `escort_sworn` | punto · domanda |
| 202 | `condition:unrest` | punto · mossa · domanda |
| 152 | `ledger_public` | punto · **era dopo** · domanda |
| 110 | `condition:cut_off` | punto · mossa · domanda |
| 102 | `debt_forgiven` | punto |

### Il circuito piu' debole e' quello che da' il nome al gioco

> **Diciotto segni arrivano all'era successiva. Due scattano piu' di cento
> volte**: `debt_called` e `ledger_public`.

Sotto: `order_restored` 85, `heir_named` 72, `crystal_exploited` 26 — poi si
crolla. Otto segni sotto le quindici volte per secolo, e tre (`mine_sealed`,
`oath_broken`, `valley_sealed`) **mai**. Il ponte fra quello che fai adesso e
quello che vuoi ottenere dopo esiste diciotto volte sulla carta e **due** in
partita.

### E il flavour non e' marginale: e' il traffico principale

Cinque dei trentasei flavour sono la famiglia `discovery:` —
**1.308 scritture per secolo**, e nessuna riga che le conti. Marcare il flavour
come «non pesa sul bilanciamento» vuol dire marcare cosi' la cosa che il motore
fa piu' spesso. E' la piu' grossa delle tre decisioni, non una postilla.

### Un difetto dello strumento, da chiudere per primo

**`docs/MISURA_SEGNI.md` non vede le Cicatrici.** `cli/run_world_marks_probe.gd`
conta solo `SET_REGION_TAG`, `SET_GLOBAL_TAG` e `SET_ENTITY_TAG`; le Cicatrici
le scrive `ADD_SCAR`, che e' un Effect suo. **Sei segni `scar:*` che pesano sono
invisibili alla misura**, insieme a tre `settlement:` (FUNCTION) e tre di ambito
ENTITY che il filtro MEMORY/STATE esclude per costruzione. Finche' quel buco
c'e', il conto «32 scattano» e' un **pavimento**, non un totale.

### Cosa la chiude

1. **Il campo che manca**: `weight` nel dizionario dei segni — `pesa` oppure
   `flavour`, obbligatorio, con la ragione quando e' flavour. Le altre quattro
   colonne che il committente chiede esistono gia' sparse fra
   `godot/data/tags`, `REGISTRO_SEGNI.md` e `MISURA_SEGNI.md`; questa no.
2. **Il validatore rifiuta un segno senza `weight`**, e rifiuta un segno
   marcato `flavour` che compaia in una clausola di punteggio — e' la regola
   del committente resa eseguibile.
3. **Il cancello va rosso** se un segno marcato `pesa` non scatta mai in cento
   anni: e' una promessa falsa che si e' rivestita da regola.
4. **Prima di tutto**: la sonda conta anche `ADD_SCAR`, e la misura smette di
   essere un pavimento.

**Il metro**: `tools/run_marks_survey.sh` e `docs/REGISTRO_SEGNI.md`.
**Fatto quando** ogni segno dichiara il suo peso, nessun `pesa` resta senza
scatti, e nessun `flavour` compare in una clausola di punteggio.

---

### 97. ✅ Le clausole di Regione nascevano morte — chiusa in 0.1.290, strada 1

`regola` · `contenuto` · `bilanciamento` · `decisione` · aperta in 0.1.289
([D-326](DECISIONS.md#d-326))

Misurata la mappa per la prima volta con
`cli/run_map_probe.gd` (100 partite, CHR_00, misto), la lotta **c'e'**:

> **Il 47.1% delle Regioni tenute a fine anno si decide per una pedina o meno.**

Ma le carte guardano altrove:

| | | |
|---|---|---|
| righe dei Destini su una Regione **pescata** | 284 | 56.9% |
| righe su una Regione **che non c'e'** | **215** | **43.1%** |
| Regioni pescate che **qualcuno nomina** | 134 | 22.3% |
| Regioni pescate che **non nomina nessuno** | 466 | **77.7%** |

Le morte, per nome: `REG_EREDAN` 62, `REG_MINIERE_ANTICHE` 57,
`REG_STRADA_MERCANTI` 33, `REG_VALLE_VERDE` 30, `REG_MONTAGNE_ROSSE` 23,
`REG_TERRE_NAHR` 10.

**Ecco perche' le coppie che si contendono una Regione sono il 2.8%.** Perche'
due Destini si incontrino su una terra, quella terra deve essere stata pescata —
e da [D-265](DECISIONS.md#d-265) la mappa si pesca sei su dieci.

**E' l'ultimo pezzo di D-265 rimasto indietro.** La mappa e' diventata pescata,
i bersagli delle Azioni sono stati ri-mirati a segni
([D-273](DECISIONS.md#d-273)), le Tensioni parlano per #TAG — **i Destini no**.

**Cosa la chiude.** Sono ventitre' carte stampate, quindi decide il committente:

1. **I Destini parlano per segni, come tutto il resto.** Non «Eredan e' uscita
   pulita» ma «la terra col #trono e' uscita pulita»; non «presenza nelle Terre
   Nahr» ma «presenza dove c'e' il #pascolo». E' la strada gia' percorsa due
   volte (D-273 per le Azioni, la grammatica #TAG per le Tensioni), e chiude il
   difetto alla radice: una clausola a segni **trova sempre il suo posto** sulla
   mappa pescata. Costo: e' la riscrittura piu' grossa fatta finora sulle carte,
   e va provata che ogni segno esista su ogni mappa possibile — il validatore ha
   gia' quel controllo per le Azioni.
2. **Il mazzetto dei Destini si pesca dopo la mappa.** La casa riceve solo i
   Destini le cui Regioni sono uscite. Non tocca le carte, tocca il setup —
   ma con quattro carte per casa restringere puo' lasciare un mazzetto vuoto, e
   allora serve comunque un ripiego a segni.
3. **La mappa si pesca in funzione delle case sedute.** Le sei tessere le
   scelgono le quattro case, non l'RNG. Rende la mappa meno varia: e' il
   contrario di D-265.

**Coda dello stesso difetto, e questa non ha bisogno di una decisione grossa:**
**`DST_VAERAX_LEGEND` non sta nel mazzetto di nessuna casa** — mai uscita in 400
seggi. E' la carta che [D-325](DECISIONS.md#d-325) ha appena modificato: quella
modifica non puo' vedersi. O entra nel mazzetto di `ENT_VAERAX` (che diventa
l'unica casa con tre Destini propri), o esce dalla scatola.

**Il metro**: `cli/run_map_probe.gd`, righe *su una che non c'e'* e *non le
nomina nessuno*. **Fatto quando** nessuna clausola di Regione puo' nascere morta.

---

**Chiusa in 0.1.290 con la strada 1** ([D-327](DECISIONS.md#d-327)). Quarantuno
righe su ventitre' Destini mirano a segni con `any_tag`, la stessa forma delle
Azioni. Ogni riga porta **due** segni — quello del posto e il dominio che fa da
pavimento — perche' con 10 tessere e 6 pescate solo un segno su almeno 5 tessere
e' garantito, e i segni di luogo stanno su una sola.

| | prima | dopo |
|---|---|---|
| righe che nascono morte | 43.1% | **0%** |
| Regioni pescate che qualcuno nomina | 22.3% | **72.2%** |
| coppie che si contendono una Regione | 2.8% | **15.5%** |
| clausole contese | 21.4% | **25.9%** |

Il cancello: la regola 17 del validatore adesso vieta di nominare una Regione
per nome in una clausola, e pretende il pavimento sui segni. `DST_VAERAX_LEGEND`
e' entrata nel mazzetto di `ENT_VAERAX`.

**Resta aperto**: le clausole gia' vere all'apertura non si muovono (53.1%).
Questa strada rende le righe raggiungibili e contese, non conquistate —
[ISSUES 91](#).

---

### 96. ✅ Il segno piu' scritto del gioco non lo guarda nessuno — CHIUSA in 0.1.363: da venticinque a due, e i due sono colore dichiarato

`regola` · `contenuto` · `bilanciamento` · aperta in 0.1.287
([D-324](DECISIONS.md#d-324)) · **chiusa in 0.1.363**
([D-395](DECISIONS.md#d-395))

> **Da venticinque a due.** La voce nasceva da `condition:contested`, scritto
> **531 volte in cento anni** senza una clausola addosso, e da altri ventiquattro
> segni sopra le dieci scritture. [MISURA_SEGNI.md](MISURA_SEGNI.md), che sta nei
> cancelli, oggi ne elenca **due**: `watched` (18 scritture) e `price_in_lives`
> (13).
>
> **E quei due non prendono una clausola, di proposito.** Sono i due marchi che
> [D-278](DECISIONS.md#d-278) ha voluto **non meccanici**, e ognuno porta gia' la
> sua ragione scritta nel dizionario:
>
> - `watched` — *«marchio di memoria: chi ha imposto la guardia se lo porta
>   addosso, e si legge sulla carta del casato — il motore non lo interroga»*;
> - `price_in_lives` — *«una decisione passata al prezzo di qualcuno che non c'e'
>   piu': si legge al centro del tavolo»*.
>
> Scrivergli addosso due clausole per far scendere un numero a zero sarebbe
> contenuto che esiste per la misura, che e' esattamente quello che le regole di
> casa vietano. Il metro giusto e' quello con cui si chiude la
> [77](#77) — **o un lettore, o una ragione scritta** — e questi due la ragione
> ce l'hanno.
>
> **Se il committente vuole che quei due marchi pesino**, e' una riga: un passo
> di Destino che teme la guardia. Non e' una voce nuova, e' questa riga.

Girando la misura dalla parte giusta — non «quanti dei segni che i Destini
nominano il mondo li scrive», ma **quali segni il mondo scrive** — esce questo:

> **`condition:contested` e' scritto 531 volte in cento anni, e non c'e' una
> sola clausola in tutta la scatola che lo nomini.**

**Venticinque segni** superano le dieci scritture per secolo con zero clausole
addosso. I primi:

| segno | scritto in 100 anni | clausole |
|---|---|---|
| `condition:contested` | **531** | 0 |
| `discovery:the_omen` | 455 | 0 |
| `discovery:the_ledger` | 335 | 0 |
| `discovery:trade_ledger` | 200 | 0 |
| `knowledge_shared` | 147 | 0 |
| `condition:cut_off` | 98 | 0 |
| `order_restored` | 87 | 0 |
| `heir_named` | 73 | 0 |

E dall'altra parte, cinque **guardati e mai scritti**: `study_supervised`,
`valley_sealed`, `water_priced`, `legend:crystal_exploited`,
`mountain_forgotten`. Quelle clausole sono vere dall'apertura e nessuno le puo'
rompere.

**Cosa cambia nella diagnosi di [ISSUES 91](#).** Il problema di
`state_tag_absent` sembrava di **quantita'**. E' di **incontro**: il mondo
produce una cosa, le carte ne guardano un'altra.

**E c'e' una mossa che manca al gioco.** Da [D-323](DECISIONS.md#d-323) un
Consiglio caduto lascia una terra contesa cinque volte l'anno, e **a nessuno
conviene farla cadere**. Far cadere una domanda non e' mai una scelta: e' solo
un incidente. Una casa che campa sul confine irrisolto la renderebbe una mossa.

**Cosa la chiude.** Sono carte stampate, quindi decide il committente:

1. **Qualcuno vuole quello che il mondo produce.** Le clausole nuove usano
   `state_tag_present` sui segni che escono spesso — un confine conteso, una
   strada chiusa, una voce che corre. Sono **false all'apertura**, quindi si
   conquistano e non si trovano nella dotazione; e chi le ha ha un motivo per
   far cadere una domanda, che oggi non ha nessuno. E' la strada gemella di
   quella che ha funzionato per le Cicatrici
   ([D-321](DECISIONS.md#d-321)) — contenuto, niente motore.
2. **Le clausole mai scritte si ri-mirano.** Le cinque che temono cose che non
   succedono si riscrivono su segni che il mondo produce. Toglie regali, ma non
   aggiunge lotta.
3. **Il mondo smette di scrivere quello che nessuno legge.** Meno segni, piu'
   densi. E' la strada del rasoio: al tavolo un segnalino che non serve a
   niente e' un segnalino da togliere dalla scatola.

**Il metro**: `tools/run_marks_survey.sh`, la tabella *Lavoro del motore che al
tavolo non conta*. **Fatto quando** nessun segno scritto piu' di dieci volte in
cento anni ha zero clausole addosso.

> **Avanzamento in 0.1.354.** Il metro dice che ne restano **due**:
> `watched` (17 scritture) e `price_in_lives` (14). Erano venticinque.
>
> E [D-388](DECISIONS.md#d-388) ha corretto la misura gemella, quella delle
> memorie **temute**: la strada 2 di questa voce — *«le clausole mai scritte si
> ri-mirano»* — riguarda **sei segni**, non le cinque di allora né i venti che
> una sonda cieca faceva sembrare: `valley_sealed`, `crystal_exploited`,
> `failed_proposal`, `no_charter`, `relic_buried`, `relic_shown`.

**Avanzamento.** La strada 1 e' fatta per i quattro segni piu' grossi
([D-325](DECISIONS.md#d-325)): orfani **25 -> 21**, coppie che si contendono una
memoria **4.5% -> 7.0%**, clausole gia' vere all'apertura **54.0% -> 53.1%**.

E si e' imparata una cosa che vale per tutto il resto della lista: **le prime sei
clausole, tutte su carte di case, sono atterrate senza incontrarsi** (contese
4 -> 5). Una lite scritta fra due facce di due case precise quasi non capita a un
tavolo pescato. La coppia sulle **carte condivise** — che le pesca chiunque — da
sola ha portato le contese a 18. Chi continua questa lista scriva li'.

Restano ventuno segni, in testa la famiglia `discovery:*` (`the_omen` 454,
`the_ledger` 337, `trade_ledger` 204) e `heir_named` 76. Sono scoperte di casa:
la domanda vera e' se una scoperta debba valere punti a qualcuno, o se sia
contabilita' e vada tolta dal conto — cioe' la strada 3.

---

### 95. ✅ Esiti di Consiglio che nessuno puo' pescare — chiusa in 0.1.286, strada 2

`regola` · `contenuto` · `debito` · `decisione` · aperta in 0.1.285
([D-322](DECISIONS.md#d-322)), chiusa in 0.1.286
([D-323](DECISIONS.md#d-323))

La scatola contiene **64 Conseguenze**. Con la regola stretta — quello che il
motore legge davvero, cioe' le proposte delle 60 carte Tensione piu'
`decisive_bonus` — **diciassette non uscivano mai**: le sei della famiglia del
fallimento, le sei del prezzo, e cinque altre.

*(D-322 diceva 13 perche' contava come raggiungibile anche il pool `cost`, che
il motore non legge — proprio la cosa che quel verbale aveva scoperto. Il numero
giusto era 17.)*

**Come si e' chiusa.** Il committente ha scelto la **strada 2**: il fallimento
riprende una faccia. Sul FAILURE scatta **una riga sola** dal pool `failure`
della scheda, e ogni scheda cade a modo suo — SURVIVAL lascia un luogo
abbandonato, TERRITORY un luogo conteso, ANCIENT una voce che corre, RESOURCE
una strada chiusa; e le otto carte con scheda propria cadono nel modo della loro
domanda.

| | prima | dopo |
|---|---|---|
| Conseguenze irraggiungibili | 17 su 64 | **9 su 64** |
| VICTORY, tavolo misto | 173 | **164** |
| NONE, tavolo misto | 86 | **91** |
| verita' diverse, uniforme | 133 | **139** |
| trasformazioni sedute | 198 | **194** |

**Quello che non ha funzionato, ed e' il motivo per cui la strada era stata
consigliata:** le memorie temute **non si muovono** (76.6% prima, 76.6% dopo), e
le clausole gia' vere all'apertura passano dal 54.3% al 54.0%. La strada 2
sporca il mondo ma non rende `state_tag_absent` contendibile.

Il perche' e' preciso: **i segni che un fallimento lascia non sono i segni che i
Destini temono.** Un Consiglio caduto scrive `condition:abandoned`,
`condition:contested`, `condition:cut_off`, `condition:plundered`,
`rumour_running`; i Destini temono `crown_divided`, `valley_sealed`,
`water_priced`, `oath_broken` — cose che solo una proposta **passata** puo'
scrivere. Il blocco sta un passo piu' in la', in **cosa i Destini scelgono di
temere**: torna a [ISSUES 91](#).

**La coda che resta aperta.** Nove Conseguenze restano irraggiungibili, e sei
sono quelle del prezzo (`CNS_COST_*`): superate per costruzione da
[D-280](DECISIONS.md#d-280), perche' la moneta sta sulla carta Tensione.
Andrebbero cancellate, insieme al pool `cost` dello schema che nessuno legge —
ma e' contenuto stampato, quindi serve una parola. Le altre tre —
`CNS_EXODUS`, `CNS_HARVEST_RETURNS`, `CNS_VALLEY_DRAINED` — sono esiti di storia
che nessuna proposta nomina piu': o le nomina qualcuno, o vanno via anche loro.

**Fatto quando** nessuna Conseguenza scritta e' irraggiungibile, e un cancello
lo controlla.

---

### 94. ✅ La quiete e' un bene comune — chiusa in 0.1.284, strada 1

`regola` · `contenuto` · `decisione` · aperta in 0.1.283
([D-320](DECISIONS.md#d-320)), chiusa in 0.1.284
([D-321](DECISIONS.md#d-321))

`scar_count` era il blocco piu' grosso rimasto di [ISSUES 91](#): **393 clausole
centrate, 391 gia' vere all'apertura — il 99.5%.**

*(I numeri scritti qui in 0.1.283 — «145 centrate, 143 gia' vere, 7.1% delle
coppie» — venivano da una corsa piu' corta di quella che il metro cita, una
quarantina d'anni invece di cento. Corretti in D-321: la proporzione era
giusta, i conteggi no.)*

Il censimento delle ventiquattro clausole scritte diceva perche':

| cosa chiedono | quante |
|---|---|
| che l'anno finisca **pulito** (`max: 0`, `max: 1`, `max: 2`) | **22** |
| che l'anno **lasci il segno** (`min: 1`, `min: 3`) | **2** |

Il mondo comincia senza Cicatrici, quasi tutti volevano che restasse cosi', e
**nessuno pagava per il contrario**. Non era scritto male: la quiete e' un bene
comune — la vogliono tutti e non costa a nessuno.

**Come si e' chiusa.** Il committente ha scelto la **strada 1**: piu' case
vogliono il segno. Quattro carte hanno cambiato verso — `DST_LIBERE`,
`DST_CENERE_DEEP` (due clausole), piu' una clausola nuova su `DST_VETRO_SHOWN` e
su `DST_SHARED_LAND` — scelte dove la carta, letta com'e' stampata, gia' si
contraddiceva. Da **2 su 24** a **7 su 26**.

| | prima | dopo |
|---|---|---|
| coppie che si contendono una Cicatrice | 5.7% | **25.0%** |
| clausole che qualcuno contendeva | 14.6% | **21.4%** |
| `scar_count` contese | 38 su 393 | **189 su 393** |
| `scar_count` gia' vere all'apertura | 391 su 393 | **362 su 393** |

**Quello che resta aperto** (e torna a [ISSUES 91](#)): `scar_count` e' ancora
gia' vero all'apertura nel **92.1%** dei casi. Girare il verso ha reso le
clausole **contese**, non **conquistate**. Le altre due strade restano scritte
qui sotto, se un giorno servissero:

2. **La quiete diventa relativa.** Non «il mondo ha al massimo due segni» ma
   «la tua terra e' uscita piu' pulita di quella di chiunque altro»: un
   confronto fra seggi al posto di un bollettino meteo. Serve un `what:
   "scars"` in `_lead_value`, e `leads_in` e' vera per uno solo — troppe
   farebbero chiudere tre seggi su quattro a mani vuote.
3. **La quiete si paga.** Una clausola che chiede il mondo pulito vale solo se
   quel seggio ha speso qualcosa per tenerlo tale — una Cicatrice evitata a
   proprie spese, non una che non e' capitata.

**Il metro**: `cli/run_contest_probe.gd --runs=100 --seed=7000
--chronicle=CHR_00`, riga *gia' vere all'apertura, per tipo*.

---

### 93. ✅ Cancellare gli anni d'autore — chiusa in 0.1.281

`regola` · `debito` · `strumenti` · aperta in 0.1.280
([D-318](DECISIONS.md#d-318))

Il committente ha deciso: **gli anni d'autore vanno via** — CHR_01, CHR_02,
CHR_03, CHR_04. La strada 1 di ISSUES 92 e' fatta (il cancello gira su CHR_00),
ma la cancellazione vera e' bloccata da una cosa misurata prima di provarci:

**Puntando `tests/test_case.gd` su CHR_00, la suite va a 217 fallimenti su 42
suite.** Le cause, contate:

| quante | cosa |
|---|---|
| 26 | un hook EFFECT di Eco non compila: nomina una Regione che non e' stata pescata |
| 9 | «tensione sconosciuta 'TEN_...'» — la prova nomina una questione che quell'anno non e' uscita |
| 8 | il menu non offre quello che la prova si aspetta |
| 5 | il tavolo non e' quello del §10 scritto a mano |

La suite unitaria **e' costruita sull'anno d'autore**: nomina `TEN_FAMINE`,
`REG_EREDAN`, «La Carestia Rossa». Spostarla non e' una sostituzione di
stringhe — e' riscrivere le prove perche' **non nominino** un mondo che adesso
cambia a ogni seme.

**Cosa la chiude**, in quest'ordine:

1. **Il tavolo di prova si fabbrica.** `test_case.gd` costruisce un mondo
   deterministico *suo* — sei Regioni, quattro case, le questioni che servono —
   invece di prendere in prestito una Chronicle spedita. E' la regola di casa
   gia' scritta: *una prova che cerca una condizione fra i dati spediti puo'
   smettere di provare senza dirlo — fabbricatela.*
2. **Le prove smettono di nominare il mondo.** Chi ha bisogno di una Regione
   se la chiede al tavolo (`la prima Regione`, `una terra che tiene un altro`)
   invece di scrivere `REG_EREDAN`.
3. **Poi si cancella**: le definizioni delle quattro Chronicle e i `sim_plans`.
   Restano entita', Destini, Regioni, Tensioni, Echi e i template di Consiglio,
   che CHR_00 usa gia' tutti.

**Chiusa in 0.1.281** ([D-319](DECISIONS.md#d-319)): il banco se lo fabbrica
la suite (`tests/fixtures/chronicle_test.json`), `shipped_data()` separa il
censimento della scatola dalla prova del motore, e le quattro Chronicle sono
cancellate. Dai **217 fallimenti** misurati a **zero**, con 622 test verdi e il
cancello dei 100 semi a 0 seggi bloccati su 8.

---

### 92. ✅ Il cancello misura un anno d'autore, non la scatola — chiusa in 0.1.280, strada 1

`regola` · `strumenti` · `decisione` · aperta in 0.1.277, **riscritta in
0.1.279** ([D-317](DECISIONS.md#d-317)), **chiusa in 0.1.280**
([D-318](DECISIONS.md#d-318))

> **Il committente ha scelto la strada 1**: *«fai la 1, questi anni d'autore
> dovevamo cancellarli giorni e giorni fa»*. `run_playtest.gd` gira su cento
> anni pescati di CHR_00 — Tensioni sul tavolo da 4,0 a **8,8**, carte mai viste
> da **48 su 60 a 3** — e il vincolo *0 seggi bloccati su 8* tiene li' pure. La
> cancellazione vera degli anni d'autore e' diventata [ISSUES 93](#), chiusa in
> 0.1.281.
>
> **La spunta mancava**: la voce e' rimasta senza ✅ per undici versioni, e se
> n'e' accorto il giro dei cancelli di 0.1.291 ([D-328](DECISIONS.md#d-328)).
> Una voce chiusa che sembra aperta costa quanto una aperta che sembra chiusa.

**La prima versione di questa voce diceva una cosa sbagliata** — *«propone solo
il proponente»* — e va letta come esempio di diagnosi plausibile che non regge
alla misura. Tre verifiche la smontano: la proposta si propone (`P_EXPLOIT`
offerta 3 volte e scelta 3), la Tensione non e' affamata (`TEN_AWAKENING`:
media 5.90 su soglia 6, picco 33, 116 spinte in su contro 7 in giu' — la meno
frenata del gioco), e la sua domanda ha `eligibility: []`, sempre eleggibile.

**Il blocco e' a monte:** quella Tensione non e' quasi mai sul tavolo.
`deal_theme_decks()` pesca dalle sessanta carte della scatola **solo se la
Chronicle ha un `region_pool`**; senza, il mazzetto contiene solo le Tensioni
gia' in gioco — *«il loro anno e' un anno d'autore»*, dice il commento, ed e'
una scelta. Il `region_pool` ce l'ha **CHR_00 e basta**.

Venti partite a tavolo misto, `cli/run_tension_reach_probe.gd`:

| | CHR_01 | CHR_00 |
|---|---|---|
| Tensioni sul tavolo, per partita | **4.0** | **8.8** |
| distinte in 20 partite | **12** | **57** |
| mai viste, su 60 | **48** | **3** |
| che tengono un Consiglio | 12 | **28** |

E il cancello dei 100 semi gira su **CHR_01 e CHR_03**, tutti e due anni
d'autore:

> Ogni numero di bilanciamento a verbale in questo progetto e' stato misurato
> su una partita con **quattro** Tensioni, non con sessanta.

**Cosa la chiude.** La scelta e' del committente:

1. **Il cancello impara la scatola** — `run_playtest.gd` gira anche su una
   saga a mappa pescata, e il vincolo *0 seggi bloccati su 8* vale li' pure.
   E' la strada che misura il gioco che si vende, e va messa in conto che
   qualche numero peggiori: nessuno l'ha mai guardato.
2. **Le Chronicle scritte prendono il mazzetto pieno** — via la riga che le
   distingue, e anche l'anno d'autore pesca dalle sessanta. Cambia il carattere
   delle due saghe scritte, che oggi raccontano una storia precisa.
3. **Restano due giochi, e si dichiara** — l'anno d'autore e' il tutorial, la
   mappa pescata e' la campagna. Allora servono due cancelli, non uno.

**Il metro**: `cli/run_tension_reach_probe.gd`, riga *mai viste* — oggi **48
su 60** sull'anno d'autore, **3 su 60** sulla mappa pescata.

---

### 91. Il 60% dei punti era gia' fatto prima che qualcuno giocasse — 52.4% in 0.1.278

`regola` · `bilanciamento` · **fuori dalla lista in 0.1.361**
([la lista](LE_TUE_DECISIONI.md)): la sua cura e' la rossa R4 (gli Obiettivi che
nominano invece di contare), e si rimisura dopo quella · aperta in 0.1.276
([D-314](DECISIONS.md#d-314))

**Misurata**, su 40 tavoli CHR_01 ai semi 7000+, misto e uniforme concordi:

- **60.5%** delle clausole a punti erano gia' vere **all'apertura**, prima di
  ogni mossa;
- **89.8%** non avevano nessun altro seggio al tavolo con un motivo *scritto*
  per impedirle;
- solo **2.9%** delle coppie di seggi si contendono una Regione, **1.2%** una
  memoria del mondo.

Il difetto ha tre nomi. `entity_alive` (113 clausole), `scar_count` (154),
`state_tag_absent` (165): **vere al setup nel 100% dei casi**, contese quasi
mai, e insieme **il 40.8% di tutti i punti del tavolo**. Non chiedono di
giocare — chiedono di non morire, di non prendersi Cicatrici e di sperare che
una memoria non compaia. Sul tavolo fisico sono punti gia' stampati sulla
plancia.

Specularmente, `control_count` e' contesa **92 volte su 92** e regge da sola
**l'85%** della superficie competitiva. Il gioco ha un solo tipo di obiettivo
che si comporta come tale.

Caso di mezzo da non rompere: `discovery_count` (121 clausole) si guadagna
davvero — zero gia' vere in apertura — ma non si contende mai. Fatica vera,
senza avversario: e' un solitario dentro la gara.

**Cosa la chiude.** La scelta e' del committente e non e' stata presa. Le
strade sul tavolo:

1. **Le clausole a dotazione diventano soglie mosse** — non *sei vivo* ma
   *sei vivo avendo speso*, non *poche Cicatrici* ma *meno Cicatrici di chi
   ne ha di piu'*: un confronto fra seggi al posto di un valore assoluto.
2. **Il mondo prende un rovescio contendibile** — ogni memoria che qualcuno
   teme e' una memoria che qualcun altro vuole, cosi' `state_tag_absent`
   smette di essere gratis.
3. **I Destini si scrivono a coppie** — la distribuzione garantisce che ogni
   seggio nomini almeno una cosa che un altro seggio nomina.

**Il metro c'e' gia'**: `cli/run_contest_probe.gd`. Una modifica che vuole
rendere il gioco una gara deve **far scendere il 60.5% e salire il 10.2%**,
senza toccare il cancello dei 100 semi.

**Avanzamento.** Due tagli fatti, entrambi misurati:

| | D-314 | dopo [D-315](DECISIONS.md#d-315) | dopo [D-316](DECISIONS.md#d-316) |
|---|---|---|---|
| gia' vere all'apertura | 60.5% | 57.8% | **52.4%** |
| clausole contese | 10.2% | 11.8% | **15.8%** |

Quei tre numeri sono di **CHR_01, cancellata da D-319**. Rimisurato sul gioco
che c'e' — `--runs=100 --seed=7000 --chronicle=CHR_00`:

| | CHR_00, prima di D-321 | dopo [D-321](DECISIONS.md#d-321) |
|---|---|---|
| gia' vere all'apertura | 55.5% | **54.3%** |
| clausole contese | 14.6% | **21.4%** |

La strada 2 ha dato il rovescio a una memoria (`OBJ_THE_USEFUL_RUIN`) e ha
trovato il muro vero, che sta altrove ([ISSUES 92](#)). Il taglio (a) della
strada 1 ha tolto `entity_alive` dal punteggio **senza spostare un livello**.
[ISSUES 94](#) ha aggredito `scar_count` per la via del contenuto — sette
clausole su ventisei chiedono adesso che il mondo porti il segno — e ha portato
la superficie contesa dal 14.6% al 21.4%. **Ma non ha spostato la dotazione**:
`scar_count` resta gia' vero all'apertura nel 92.1% dei casi.

Restano aperti il taglio (b) — le soglie assolute che diventano confronti, e
adesso `state_tag_absent` e' il blocco piu' grosso rimasto, con 426 clausole
mai contese — e la strada 3.

**E si sa una cosa in piu' su `state_tag_absent`, dopo
[ISSUES 95](#).** Rimettere una faccia al fallimento — un Consiglio caduto
sporca il mondo — **non l'ha spostato di niente**: memorie temute 76.6% prima e
dopo. La ragione: **i segni che un fallimento lascia non sono i segni che i
Destini temono**. Un Consiglio caduto scrive `condition:abandoned`,
`condition:contested`, `condition:cut_off`; i Destini temono `crown_divided`,
`valley_sealed`, `water_priced`, `oath_broken` — cose che solo una proposta
**passata** puo' scrivere. Quindi il taglio (b) non basta neanche lui dal lato
del mondo: o i Destini temono cose che il mondo produce da solo, o quelle cose
diventano piu' facili da produrre. E' la voce da aprire dopo.

### Rimisurata in 0.1.354, e mezza diagnosi era di una sonda cieca ([D-388](DECISIONS.md#d-388))

**Il paragrafo qui sopra si reggeva su un numero sbagliato.** La sonda chiedeva
se una memoria temuta fosse comparsa **lì dove la clausola la teme**, e il posto
lo leggeva alla lettera: `region_id`. Ma una clausola del pool **non può nominare
una Regione** — dice `$any`, o punta un bersaglio a segni. Quindi ogni clausola
di Regione risultava «mai toccata», sempre.

Il segno che l'ha smascherata è proprio quello citato sopra:
**`condition:contested`, che il mondo scrive 452 volte in cento partite, usciva
`0 / 60 <-- MAI`.**

| | diceva | dice |
|---|---|---|
| memorie temute che qualcuno ha provato a scrivere | 7,7% | **24,6%** |
| `condition:contested` | 0 / 60 | **58 / 2** |
| `condition:unrest` | 0 / 74 | **42 / 32** |

**Quindi la frase *«i segni che un fallimento lascia non sono i segni che i
Destini temono»* è metà falsa**: `condition:contested` e `condition:cut_off`,
che un Consiglio caduto scrive, i Destini li temono **e li vedono comparire**.
Quello che resta vero è l'altra metà, e adesso è un elenco corto: **sei segni**
che una clausola teme e che nessuno ha mai scritto in cento partite —
`valley_sealed` (0/29), `crystal_exploited` (0/34), `failed_proposal` (0/39),
`no_charter` (0/17), `relic_buried` (0/12), `relic_shown` (0/11). Tutte memorie
globali, tutte punti che nessuno può rompere: è la **strada 2 di
[ISSUES 96](#96)**, e sono carte stampate, quindi la scelta è del committente.

**E la voce intera, rimisurata sul gioco di oggi:**

| | D-321 (0.1.283) | oggi (0.1.354) |
|---|---|---|
| clausole già vere all'apertura | 54,3% | **47,6%** |
| clausole contese | 21,4% | **24,1%** |

Tutti e due nella direzione che questa voce chiede. La ragione si legge nella
riga per tipo: `did_this_year` ([D-386](DECISIONS.md#d-386)) porta **152
clausole** che nessuno contende ma che **nessuno trova già fatte** — un
obiettivo che chiede un gesto non è contendibile, ma non è nemmeno dotazione.

`state_tag_absent` resta il blocco più grosso, con **492 clausole mai contese**.

---

### 90. ✅ La mappa pescata poteva non offrire una famiglia — chiusa in 0.1.275

`regole` · `bilanciamento` · aperta e chiusa in 0.1.275
([D-313](DECISIONS.md#d-313))

Trovata rispondendo a una domanda del committente sul tavolo fisico. Ogni
tessera e' fonte di due famiglie di carte; sei tessere su dieci fanno venti
caselle per sei famiglie, e **45 mappe su 210 ne lasciavano fuori una** — 28
volte l'Autorita', che usciva da due sole tessere.

Chiusa in due mosse: il Bosco dei Confini riequilibrato (45 → 30, l'ottimo
teorico) e una regola di stesura che chiude il resto (30 → 0). Quattro prove,
due delle quali guardano il **cablaggio** e non la funzione — sono quelle che
avrebbero preso l'errore vero.

**Quello che resta aperto e non e' di questa voce**: la mappa pescata la usa
solo CHR_00, e il cancello a 100 semi gira CHR_01 e CHR_03. Finche' e' cosi',
**nessuna modifica alla pesca delle tessere passa dal cancello**: la si prova
coi test o non la si prova. Vale la pena, quando si torna sul setup
procedurale, far girare al cancello anche una Chronicle a mappa pescata.

---

### 89. ✅ La proposta non si risolve col dito: 642 Effetti che nessuna carta stampa — CHIUSA in 0.1.332

`regole` · `fisico` · **aperta in 0.1.274** ([D-312](DECISIONS.md#d-312)) —
parola del committente guardando le carte: *«ci dovrebbe essere indicato i tag
dove le azioni possono essere fatte, e dovrebbero esserci due azioni che
indicano i tag da mettere. Il testo dovrebbe essere solo Flavor Text. C'e'
qualcosa che non mi convince»*.

Ha ragione. La domanda di casa — *questa cosa esisterebbe e sarebbe
comprensibile sul tavolo fisico?* — su questa meta' del gioco risponde **no**.

**Cosa e' gia' come dice lui.** La carta **Azione** (D-274): un bersaglio a
segni (`#granaio`, `#pascolo`, `#capitale`), due Azioni che dicono quale segno
posano, una Risonanza che scalda un Tema. Il testo e' istruzione breve, il
resto e' colore.

**Cosa e' gia' come dice lui, sulla Tensione.** La sua **faccia fisica**
(D-280): dodici caselle, ognuna un verbo chiuso piu' un segno — COSTRUISCI
PIETRA *Pedaggio*, AGGIUNGI CONDIZIONE *#svuotato*, IL MONDO RICORDA
*l'acqua torna a muoversi*.

**Cosa non lo e'.** Il **Consiglio** che quella stessa carta apre. Una proposta
e' una frase d'autore che punta a una Conseguenza, e la Conseguenza e' un
sacchetto di Effetti che sulla carta non c'e'.

| | |
|---|---|
| proposte nel mazzo | 185 |
| **Effetti che quelle proposte applicano** | **642** |
| di quelli, stampati su una carta | **0** |
| media di Effetti per proposta | 3,5 |

Un esempio, dalle carte appena scritte. Passa *«La tariffa si scriva al
Consiglio, e la riscuota chi propone»* sul Traghetto. Il motore esegue
`CNS_TOLL_ESTABLISHED`, che fa tre cose:

- **prende il controllo** di un luogo con `#commercio` — che puo' non essere
  quello di cui si discuteva;
- **ci costruisce un Pedaggio** di grado 1, intestato al proponente;
- **abbassa di 1** la questione delle Vie Interrotte.

Nessuna delle tre e' scritta sulla carta. Le prime due sono il mestiere di due
caselle che quella carta **ha gia'** (PRENDI CONTROLLO, COSTRUISCI PIETRA), ma
puntate altrove: e' il residuo che [87](#87) aveva misurato e lasciato aperto —
D-307 taglio' le righe che agivano sul **luogo discusso**, non quelle che
arrivano da un'altra parte.

**Le tre strade, e la scelta e' del committente.**

- **(a) La proposta diventa un menu di caselle.** Una proposta dice *quali
  caselle apre*, e il proponente le compra con l'economia che gia' esiste
  (D-280). Le Conseguenze restano solo come **Flavor Text**: la frase che il
  verbale racconta, senza Effetti. E' la strada che il committente descrive,
  ed e' anche il **taglio 3** di [80](#80) visto dall'altro lato — se il
  prezzo si paga in caselle, il d6 non serve piu'.
  *Costo, misurato:* dei 642 Effetti, **494 li saprebbero dire le caselle di
  oggi** (segni sul luogo, memorie del mondo, controllo, Pietre, e la traccia
  della questione che sul tavolo c'e' gia'). **148 no**, e sono di cinque
  specie: quello che una casa **porta addosso** (54), i **rapporti** fra case
  (27), il **grado** di una Pietra (24), e **chi sta o non sta piu'** in un
  luogo (38). O si perdono, o servono verbi nuovi — e sono pochi abbastanza da
  poterli guardare uno per uno.
- **(b) Le caselle restano, la Conseguenza si stampa.** Non si tocca il
  motore: si stampa sulla carta cosa fa ogni proposta, in grammatica di segni.
  *Costo:* la carta diventa fitta, e la stampa puo' divergere dal dato — a meno
  di generarla, ed e' un cancello in piu'.
- **(c) Si finiscono i tre Temi che mancano** (Antico, Fede, Terra) **e poi si
  decide.** *Costo:* altre 60-70 proposte scritte nella grammatica che forse si
  butta.


> ### Rimisurata in 0.1.307, e il numero grosso di questa voce era una conclusione sbagliata
>
> Il committente, davanti all'esempio che questa voce racconta: *«la casella
> dice: chiudi una strada tra una tessera #pascolo e #selvaggio, se c'e' si puo'
> usare quella casella altrimenti no. Non vedo perche' non potrebbe essere
> scritta su una casella»*. Aveva ragione, e su tutti e tre i punti che avevo
> chiamato ostacoli ([D-342](DECISIONS.md#d-342)).
>
> **Il «65% non traducibile» contava contro le dodici caselle di adesso**, non
> contro quello che una casella puo' dire. Non e' un muro: e' un elenco di
> **nove caselle**.
>
> E misurando si e' scoperta una cosa che nessun documento diceva: **il
> Consiglio cambia il mondo in due modi che girano insieme.** L'economia delle
> caselle e' costruita ed esegue (vedi la correzione in ISSUES 72); le
> Conseguenze d'autore girano accanto a lei, nello stesso Consiglio. Da
> [D-341](DECISIONS.md#d-341) la scheda stampa solo le prime.
>
> Il conto sta in `docs/MISURA_CASELLE.md`, generato e sorvegliato da un
> cancello, e il vocabolario **non e' ricopiato**: la sonda chiede a
> `CouncilEconomy` cosa esce.
>
> | | distinti | applicazioni |
> |---|---|---|
> | una casella di oggi lo sa dire | 4 | 121 |
> | verbo giusto, posto che la casella non sa dire | 15 | 44 |
> | **verbo che manca** | **27** | **171** |
> | | **46** | **336** |
>
> #### Le nove caselle
>
> | casella da scrivere | distinti | applicazioni |
> |---|---|---|
> | **SPOSTA UNA DOMANDA — chi propone nomina quale** | 11 | **90** |
> | POSA UN SEGNO SU UNA CASATA | 4 | 44 |
> | MUOVI UN RAPPORTO | 1 | 11 |
> | UNA PRESENZA ENTRA O SE NE VA | 4 | 10 |
> | UNA PIETRA SALE O SCENDE | 2 | 9 |
> | IL MONDO DIMENTICA | 1 | 3 |
> | UNA DOMANDA VELATA SI SCOPRE | 2 | 2 |
> | UNA CASATA LASCIA IL TAVOLO | 1 | 1 |
> | CHIUDI LA STRADA FRA DUE SEGNI | 1 | 1 |
>
> **La prima vale da sola 90 applicazioni su 336**, ed e' quella che il
> committente non riusciva a leggere sulla scheda — *«La Carestia +1 non so cosa
> intende»*. L'effetto sposta la traccia di **un'altra domanda**, e non c'era
> scritto. Scelta presa dal committente: **la sceglie chi propone**.
>
> E una differenza strutturale che la misura ha portato a galla: **le caselle di
> oggi non toccano le domande.** RAFFREDDA TEMA e SCALDA TEMA producono
> `ADJUST_THEME_HEAT` su un **Tema**; tutte e novanta quelle applicazioni sono
> `ADJUST_TENSION` su una **domanda**. Sono due tracce diverse, e nessuna
> casella sa muovere la seconda.
>
> ### Fatto in 0.1.308: la prima casella e' scritta, e misurata
>
> **ABBASSA LA DOMANDA** (beneficio) e **ALZA LA DOMANDA** (costo), su tutte e
> 60 le carte ([D-343](DECISIONS.md#d-343)). Gli Effetti che nessuna casella sa
> dire scendono **da 171 applicazioni a 81**, e le caselle che restano da
> scrivere da nove a otto.
>
> **Ma al tavolo la comprano una volta su settantadue.** La sonda nuova
> `run_boxes_probe.gd` conta offerte e acquisti: in venti partite CAMBIA
> CONTROLLO 32 su 32, RAFFREDDA TEMA 6 su 72, **ABBASSA LA DOMANDA 1 su 72**.
> Vale 1 in `intrinsic_value` come RAFFREDDA TEMA, e la policy preferisce le
> caselle che cambiano la mappa. Non e' stata ritoccata: alzare il valore di una
> casella e' equilibrio, e va misurato.
>
> Ed e' la ragione per cui il playtest non si muove: **una casella che nessuno
> compra e', per il gioco, identica a una che non esiste.**
>
> Restano otto caselle, e la piu' grossa e' ora POSA UN SEGNO SU UNA CASATA (4
> distinti, 44 applicazioni).

> ### Chiusa in 0.1.332: le otto caselle, e il campo che mancava di più
>
> Le otto sono scritte ([D-366](DECISIONS.md#d-366)). Ma misurando per scriverle
> è saltata fuori la riga che questa voce non aveva mai guardato: **venticinque
> Effetti su quarantasei avevano il verbo giusto e nessun posto dove puntarlo.**
> Cento e quattro applicazioni — più di quelle che mancavano di verbo.
>
> Non era contenuto: era un campo. Ogni casella agiva sul luogo di cui si
> discuteva e per conto di chi proponeva, e basta. Adesso una casella dice
> **cosa fa** (il verbo), **su chi** (`chi`) e **dove** (`dove`), e i due campi
> nuovi sono facoltativi con i valori di riposo di prima: nessuna delle sessanta
> carte cambia.
>
> | | prima | dopo |
> |---|---|---|
> | Effetti che una casella sa dire | 5 su 46 | **44 su 46** |
> | applicazioni coperte | 151 su 336 | **333 su 336** |
> | verbi che mancano | 16 | **0** |
> | posti che la casella non sa dire | 25 | **2** |
>
> Le due che restano non sono caselle da scrivere: `$conditioner` è un bersaglio
> che al Consiglio non esiste (vive solo dentro una clausola), e il
> `SET_GLOBAL_TAG` puntato su `$adjacent` è un difetto dei dati — quel verbo
> scrive nel mondo qualunque bersaglio gli si dia. Tutti e due nella
> [117](#117).


> ### Rimisurata in 0.1.300, e i due numeri in cima erano sbagliati
>
> La voce chiedeva di guardare i residui **uno per uno** — *«sono pochi
> abbastanza»* — e nessuno l'aveva fatto. Fatto adesso, e la misura corregge
> se' stessa in due punti.
>
> **Primo: 642 non e' la quantita' di lavoro.** Quel numero conta ogni
> **applicazione** — una Conseguenza usata da trentaquattro proposte pesa
> trentaquattro volte. Oggi le applicazioni sono **841** (il mazzo e' cresciuto),
> ma gli **Effetti distinti scritti sono 164**, in 56 Conseguenze. Il lavoro da
> fare e' su 164 righe, non su 841: **cinque volte piu' piccolo** di come la voce
> lo faceva sembrare.
>
> **Secondo, e piu' grave: «494 su 642» era il 77%. Il conto vero e' il 35%.**
>
> Il numero vecchio guardava il **verbo** e non guardava **dove**. Rifacendolo
> con le due regole vere di una casella — il verbo dev'essere fra i dodici *e* il
> bersaglio dev'essere il **luogo di cui si discute**, il Tema, o il mondo:
>
> | come si conta | su 841 applicazioni | |
> |---|---|---|
> | solo il verbo, bersaglio ignorato | 401 | 48% |
> | verbo + la traccia della questione | **631** | **75%** ← e' il numero vecchio |
> | **verbo + bersaglio** | **295** | **35%** |
>
> Le due scale concordano: per Effetto distinto e' **55 su 164, il 34%**.
>
> Non e' un dettaglio contabile. **Il «dove» e' esattamente cio' che rende
> fisica una casella**: una casella agisce sul luogo che stai discutendo, che hai
> davanti col dito sopra. «Prendi il controllo di *un altro* luogo con
> `#commercio`» ha il verbo giusto e non puo' essere una casella — ed e'
> l'esempio del Traghetto che questa voce racconta due paragrafi piu' su. La voce
> lo diceva a parole e il suo numero non lo contava.
>
> ### I 164, in quattro gruppi
>
> | | Effetti distinti | applicazioni |
> |---|---|---|
> | **0** — una casella di oggi lo sa dire | **55** | 295 |
> | **1** — la traccia della questione | **36** | 230 |
> | **2** — verbo giusto, posto sbagliato | **24** | 106 |
> | **3** — verbo che manca davvero | **49** | 210 |
> | | **164** | **841** |
>
> **Gruppo 1 — la traccia della questione (36).** `ADJUST_TENSION`: la proposta
> alza o abbassa una questione. E' il gruppo piu' grosso, ed e' **una casella
> sola**: al tavolo la traccia c'e' gia' e il segnalino si muove col dito. Manca
> solo il verbo che lo dica. Dieci dei trentasei muovono la questione **di cui si
> discute** (`$tension`); gli altri ventisei ne muovono un'altra per nome, e
> quelli ricadono nel problema del gruppo 2.
>
> **Gruppo 2 — verbo giusto, posto sbagliato (24).** Nessuno di questi ha bisogno
> di un verbo nuovo: hanno bisogno di **un modo di dire quale luogo**. Sono
> quattordici segni di Regione, cinque Pietre, quattro cambi di controllo e una
> condizione tolta, tutti puntati su `$adjacent`, `$rival_seat`, `$capital` o
> `$region_with:#segno`. La grammatica per dirlo **esiste gia' sulle carte
> Azione** (D-262: *«la Regione col #granaio»*): qui e' solo di non averla
> portata sulla faccia della Tensione.
>
> **Gruppo 3 — i verbi che mancano davvero (49).** Questi sono i soli che
> obbligano a inventare, e sono sei famiglie piu' quattro pezzi unici:
>
> | | quanti | cosa fa |
> |---|---|---|
> | `SET_ENTITY_TAG` | 18 | quello che una casa **porta addosso** (13 al proponente, 5 al rivale) |
> | `SET_STRUCTURE_GRADE` | 8 | il **grado** di una Pietra — e ISSUES 39 ha appena misurato che scendere non succede mai |
> | `SET_RELATION` | 6 | i **rapporti** fra due case |
> | `REMOVE_PRESENCE` | 5 | chi **non sta piu'** in un luogo |
> | `REMOVE_GLOBAL_TAG` | 4 | il mondo che **dimentica** — il contrario di IL MONDO RICORDA, che una casella ce l'ha |
> | `ADD_PRESENCE` | 3 | chi **arriva** in un luogo |
> | i quattro unici | 4 | `SET_TENSION_VISIBILITY` (2), `REMOVE_ENTITY_TAG`, `SET_ENTITY_ACTIVE`, `CLOSE_PASSAGE` |
>
> ### Cosa cambia per le tre strade
>
> **La strada (a) e' piu' piccola e piu' difficile di come sembrava.** Piu'
> piccola: 164 righe da tradurre, non 642. Piu' difficile: il 65% non e'
> traducibile con quello che c'e', non il 23%.
>
> Ma i tre gruppi non costano uguale, e il grosso non e' dove sembra:
>
> 1. **Una casella per la traccia della questione** copre 36 Effetti distinti e
>    230 applicazioni. E' un verbo solo, ed e' il pezzo di tavolo che gia'
>    esiste.
> 2. **Portare il bersaglio a segni sulla faccia della Tensione** copre altri 24
>    distinti e 106 applicazioni, e non inventa niente: e' la grammatica di D-262
>    spostata di file.
> 3. Fatti quei due, resta **il 30% (49 distinti)** che chiede verbi nuovi — e
>    quello si', va guardato uno per uno, perche' e' la' che si decide cosa il
>    Consiglio non deve piu' poter fare.
>
> **La misura non sceglie la strada**, e la scelta resta del committente. Dice
> solo che (a) si puo' fare in tre passi con una soglia visibile dopo ognuno, e
> che i primi due passi non chiedono di decidere niente di irreversibile.

> ### La strada scelta, e il primo passo fatto in 0.1.301 (D-336)
>
> Il committente ha preso la **(b)**. Costruendola si e' visto che **meta'
> esisteva gia'** — `CATALOGO_CONSIGLI` rende ogni proposta in grammatica di
> segni da D-232 — **e diceva il falso su 89 righe su 164**: la frase era una
> stringa fissa per tipo di Effetto, diceva il verbo e taceva il bersaglio.
>
> Riparata: adesso la riga porta il luogo, la casa, la questione per nome, il
> verso e la Pietra col suo nome. Con una guardia nuova che non confronta due
> testi ma la frase col **dato**, ed e' quella che mancava.
>
> **E la carta non ha posto** (0.1.302, [D-337](DECISIONS.md#d-337)). Cercando
> dove mettere la riga vera si e' visto che **la faccia stampata della Tensione
> non porta niente del lavoro fisico degli ultimi sessanta rilasci**: non le
> dodici caselle di D-280, non SI ACCENDE QUANDO di D-330, non la domanda ne' le
> proposte di D-310. Stampa titolo, soglia, descrizione, prosa e famiglie.
>
> Misurato quanto testo servirebbe per stampare quello che le decisioni prese
> chiedono:
>
> | blocco | mediana | max |
> |---|---|---|
> | descrizione | 89 | 162 |
> | si accende quando | 63 | 189 |
> | **le caselle** | **582** | 653 |
> | la domanda | 85 | 122 |
> | le proposte | 203 | 592 |
> | **tutto insieme** | **1.024** | **1.484** |
>
> Su una carta **44x68 mm**, che ne regge duecento scarsi. Questa voce prevedeva
> «la carta diventa fitta» per la strada (b): **non ci sta, di quattro volte**.
> Le caselle da sole sono tre volte lo spazio.
>
> **La decisione che manca e' di prodotto, non di codice**: formato piu' grande
> (i Destini sono 70x120), un retro, o una scheda del Consiglio come pezzo a
> parte. E' del committente, e adesso ha il numero accanto.
>
> Intanto e' entrato l'unico blocco che ci sta — **SI ACCENDE QUANDO**, 63
> caratteri — che era anche un difetto: la carta stampava `triggers`, prosa
> d'autore, e nascondeva la regola in segni che il motore esegue. Lo scambio
> toglie 1.559 caratteri dal mazzo.

> ### E il formato l'ha deciso il committente (0.1.303, [D-338](DECISIONS.md#d-338))
>
> *«Facciamo formato tarocco o quello che serve in più.»* Il tarocco per la carta
> intera non basta — `TEN_SUCCESSION` sborda anche a 70x120 — e la carta Domanda
> deve restare mini perche' **sta sulla traccia dei valori** (D-097). Quindi due
> pezzi: la mini sulla traccia, e una **scheda del Consiglio** in tarocco con la
> domanda, ogni proposta con cosa lascia, e le dodici caselle.
>
> **Tutte e 60 ci stanno.** Costo: sessanta pezzi in piu', i fogli A4 da 39 a 54.
>
> **Il «fatto quando» qui sotto e' raggiunto**: una proposta si risolve guardando
> quella scheda e la mappa. Quello che resta di questa voce non e' piu' la
> stampa, e' il **motore**: le proposte restano frasi d'autore che puntano a
> Conseguenze, e la strada (a) — la proposta come menu di caselle — non e' stata
> presa. La misura di 0.1.300 dice cosa costerebbe.

**Fatto quando** una proposta si puo' risolvere guardando solo la carta e la
mappa.

---

### 88. Il tavolo vede poco piu' di un terzo di quello che c'e' scritto — **cinquantadue voci mute, per nome**

`contenuto` · `misura` · **aperta in 0.1.273**
([D-311](DECISIONS.md#d-311) · `cli/run_who_writes_probe.gd`) · **il taglio
chiesto e' fatto in 0.1.359** ([D-392](DECISIONS.md#d-392))

> **Il titolo non regge piu'.** Il 37% e il 36% erano su `CHR_01`, cancellato
> con gli altri anni d'autore. Su cento anni dell'anno che esiste, il tavolo
> vede l'**83%** delle domande (99 su 120) e il **65%** delle proposte (126 su
> 194).

**La voce chiedeva un taglio, e adesso c'e'** — in tre pezzi, non due:

| cento anni, CHR_00, semi da 7000 | domande | proposte | cos'e' |
|---|---|---|---|
| 1. mai pescate | **0** | **0** | rigiocabilita' |
| 2. pescate, mai in discussione | 8 (7%) | 29 (15%) | aritmetica: 312 Consigli, uno apre una domanda sola |
| **3. in discussione, mai scelte** | **13 (11%)** | **39 (20%)** | **il difetto di [D-035](DECISIONS.md#d-035)** |

`godot --headless --path godot --script res://cli/run_who_writes_probe.gd -- --runs=100 --seed=7000`

**La condizione — «la seconda cifra sotto un quinto» — e' soddisfatta per le
domande e sta sul filo per le proposte.** Non chiudo su 20,1%: un difetto si
lavora per nome, e i nomi adesso ci sono.

**Le tredici domande che si aprono e nessuno sceglie:** `Q_AWAKENING_MOUNTAIN`,
`Q_BAD_GRAIN_BLAME`, `Q_BELLS_WHO`, `Q_CANALS_ARMS`, `Q_EMPTY_NETS_BOATS`,
`Q_FALLOW_LEAN`, `Q_HOSTAGES_WHO`, `Q_PLAGUE_DOORS`, `Q_QUARANTINE_OUT`,
`Q_REFUGEES_COST`, `Q_STONES_WHO`, `Q_WINTER_WOOD`, `Q_WOLVES_FLOCK`.

**Le trentanove proposte che stanno nella domanda aperta e non si votano mai:**
`P_ASH_REGISTERS`, `P_BAD_GRAIN_BURN`, `P_BELLS_ORDER`, `P_BURIALS_GROUND`,
`P_CALL_IT_IN`, `P_CHANNELS_FORBID`, `P_COUNCIL_SEATS_WIDEN`, `P_ECHOES_MEASURE`,
`P_EMPTY_NETS_TURNS`, `P_HEIR_AS_STORY`, `P_HOSTAGES_TRADE`, `P_LET_IT_ROT`,
`P_LEVY_QUOTA`, `P_MARSH_FEVER_SHARE`, `P_NAMELESS_MOVE`, `P_OLD_PAGE`,
`P_ONE_CROWN`, `P_OPEN_VALLEY`, `P_QUARANTINE_HOLD`, `P_REFUSE_CHARTER`,
`P_REGISTER_CROWN`, `P_REOPEN_THE_MINE`, `P_REQUISITION`, `P_RETAKE_QUESTION`,
`P_SALT_COUNCIL`, `P_SEALS_ONE_HAND`, `P_SEAL_BORDERS`, `P_SHRINE_ANOINT`,
`P_SMUGGLING_AMNESTY`, `P_STONES_WALK`, `P_TAKE_SEAT`, `P_THIRST_FREE`,
`P_TITHE_OPEN`, `P_TOLLS_CUT`, `P_TRIBUTE_HALF`, `P_UNEARTHED_BACK`,
`P_WARDS_RITE`, `P_WATCH_THE_ROCK`, `P_WOLVES_TOWERS`.

**E quattro Tensioni non arrivano mai a un Consiglio in cento anni**:
`TEN_ENCLOSURE`, `TEN_FLOOD`, `TEN_PASTURE`, `TEN_WEIGHTS`. Sono girate — il
mazzetto le mostra — e non diventano mai la piu' calda.

**Fatto quando** la riga 3 sta sotto un quinto per tutt'e due, e la prima
domanda da farsi sulle 39 e' quella di [ISSUES 108](#108) e
[ISSUES 104](#104): **offerte e non scelte, o mai offerte?** La sonda oggi non
lo dice ancora, ed e' il prossimo passo di questa voce — non una voce nuova.

**Il testo originale:**

Il numero non e' nuovo: e' **appena diventato onesto**. La sonda contava il
denominatore sui dodici template, e diceva *«36 proposte votate su 49 scritte»*
— il 73%. Da [D-310](DECISIONS.md#d-310) le proposte stanno sulle carte, e
adesso che la sonda le guarda il conto e':

| in 40 anni di CHR_01 | prima (denominatore vecchio) | adesso |
|---|---|---|
| domande poste | 21 su 23 · **91%** | 21 su 57 · **37%** |
| proposte votate | 36 su 49 · **73%** | 36 su 100 · **36%** |

Il numeratore non si e' mosso di un'unita': al tavolo non e' regredito niente.
E' che scrivere un Consiglio per carta ha **triplicato il contenuto** senza
allargare la finestra da cui il tavolo lo guarda — una Chronicle gira sei Temi
e pesca poche carte per Tema, quindi il resto resta nel mazzo.

Due letture possibili, e non si sceglie prima di aver finito i sei Temi:

- **va bene cosi'**: e' un gioco da tavolo con sessanta carte, e nessuna
  partita le vede tutte. La rigiocabilita' *e'* il contenuto non visto.
- **non va bene**: [D-035](DECISIONS.md#d-035) dice che contenuto che il tavolo
  non raggiunge non esiste. Se una carta si pesca ma la sua domanda non si apre
  mai perche' la politica ne preferisce sempre un'altra, e' il difetto vecchio
  con un vestito nuovo.

La differenza fra le due sta in **quale** contenuto resta fuori: se sono le
carte non pescate, e' la prima; se sono le domande di carte che *sono* state
girate, e' la seconda. La sonda oggi non le distingue.

**Fatto quando** la misura separa "non pescata" da "pescata e mai aperta", e la
seconda cifra sta sotto un quinto.

*(La separazione e' fatta in 0.1.359, e ha trovato che i pezzi erano tre. Le
cifre stanno in testa alla voce.)*

---

### 87. Gli Effetti d'autore che parlano la lingua delle caselle

`contenuto` · `regole` · aperta in 0.1.267 ([D-305](DECISIONS.md#d-305)) ·
**taglio A fatto in 0.1.269** ([D-307](DECISIONS.md#d-307)), il resto aperto

> **Fatto (D-307)**: tolte le **9 righe** che consegnavano al proponente il
> luogo che la carta gli vende. Acquisti a vuoto **24% → 9%**, costi a vuoto a
> **zero**. La regola ha una guardia in `validate_physical.py`, col suo difetto
> piantato.
>
> **Aperto**: gli acquisti a vuoto rimasti — la maggior parte e' ancora la
> frase, ma per la via **indiretta** (un Effetto mirato a `$capital`,
> `$rival_seat`, `$region_with:...` che quella volta cade sullo stesso luogo).
> Con IL MONDO RICORDA ([D-308](DECISIONS.md#d-308)) sono risaliti dal 9% all'11%.
>
> ✅ **L'eccezione `CNS_MINE_TAKEN` e' chiusa** in 0.1.271
> ([D-309](DECISIONS.md#d-309)): riscritta su quello che la sua frase dice
> davvero — *«metterci qualcuno a contare quello che esce»* — lascia
> `study_supervised`, che Cenere e Lyra temono e che nessuna casella vende. La
> guardia adesso copre tutte le Conseguenze, senza perdonate.
>
> Restano intoccate le **27 righe che arrivano altrove**: nessuna casella le
> puo' fare, e toglierle sarebbe una perdita secca. E le **2** che svuotano il
> luogo (`SET_CONTROL` a null): non consegnano niente a nessuno.

Dopo [D-305](DECISIONS.md#d-305) la frase d'autore non scavalca piu' la carta.
Ma resta il fatto che le due grammatiche dicono spesso la stessa cosa: fra le
Conseguenze spedite, **67 Effetti** fanno esattamente quello che le sei caselle
del prezzo e le cinque del beneficio fanno.

| Effetto d'autore | quanti | la casella che dice la stessa cosa |
|---|---|---|
| `SET_REGION_TAG` | 35 | AGGIUNGI CONDIZIONE, PEDAGGIO, PRENDI DEBITO |
| `SET_CONTROL` | 14 | CAMBIA CONTROLLO, CEDI CONTROLLO |
| `REMOVE_REGION_TAG` | 11 | RIMUOVI CONDIZIONE, RIAPRI |
| `BUILD_STRUCTURE` | 7 | COSTRUISCI PIETRA |

Il danno non e' piu' lo scavalco — quello D-305 l'ha chiuso. E' che **quando la
frase regala gratis quello che la carta vende, il beneficio comprato resta un
acquisto a vuoto**: il proponente ha pagato un costo per una cosa che sarebbe
successa comunque.

**E adesso il danno ha un numero** (misurato in 0.1.268, dopo che
[D-306](DECISIONS.md#d-306) ha tolto di mezzo l'altra meta' del problema):

> **46 benefici comprati su 193 — il 24% — non lasciano niente, e sono tutti
> qui.** 25 CAMBIA CONTROLLO verso chi la frase ha appena messo li', e 21
> Pietre che la frase ha appena alzato.

Prima di D-306 il numero era il 44%, ma dentro c'era anche la meta' che non
c'entrava (caselle morte offerte lo stesso). Adesso quello che resta e'
**tutto** sovrapposizione fra le due grammatiche.

Da D-306 almeno **il verbale lo dice**: «...e non lascia niente: era gia'
cosi'». Prima succedeva in silenzio.

Si vede a occhio nudo anche in una prova: `test_the_card_says_what_it_left_behind`
deve **fabbricarsi il silenzio** della frase d'autore per riuscire a vedere
cosa lascia la casella comprata.

Tre letture, e la scelta e' del committente:

1. **le frasi smettono di fare il mestiere delle caselle** — restano il
   racconto, e il mondo lo cambiano le pedine. E' la direzione di D-280 portata
   fino in fondo, ed e' il lavoro piu' grosso: 67 Effetti da riscrivere;
2. **la casella non si paga se non lascia niente** — il costo si restituisce
   quando il beneficio comprato e' un no-op. Regola nuova al tavolo, e da
   spiegare;
3. **si tiene cosi' e si dichiara** — la sovrapposizione e' voluta, la frase
   ripete la casella perche' e' la stessa cosa detta due volte, e chi compra
   compra la certezza.

### 86. ✅ La frase d'autore riscriveva la carta — chiusa in 0.1.267

`motore` · `regole` · aperta in 0.1.266 ([D-304](DECISIONS.md#d-304)) ·
**chiusa da [D-305](DECISIONS.md#d-305)**: scelta del committente, **la carta
vince**. Misurato prima di toccare niente: la frase passava sopra la carta
**62 volte in 40 anni** (38 controlli riassegnati, 24 segni tolti). Adesso la
carta si spende per ultima, e una Pietra gia' alzata passa a chi l'ha comprata.
Il costo dichiarato: le vite che non si siedono mai passano da 6 a 7.

Nell'ordine di `resolve()` la carta si spende **prima** e le Conseguenze
d'autore del template **dopo**. Quindi una Conseguenza che assegna il controllo
di un luogo riscrive quello che la casella CAMBIA CONTROLLO della carta ha
appena deciso — compresa la casella rivendicata da una controproposta, che
diventa muta senza che il verbale dica che e' stata sovrascritta.

Visto con gli occhi mentre si costruiva la prova di D-304: la casella
fabbricata prendeva il controllo per il rivendicante, e a fine risoluzione il
luogo era del proponente. La prova adesso guarda una **Pietra** invece del
controllo, perche' una Pietra costruita nessuno la riscrive.

Tre letture, e la scelta e' del committente:

1. **la carta vince** — le due liste sono l'economia esplicita di D-280, e
   quello che il tavolo ha comprato e pagato non dovrebbe essere cancellato da
   una frase che non ha scelto nessuno: si spenderebbe la carta **dopo**;
2. **la frase vince, ma lo dice** — resta l'ordine di adesso, e il verbale
   scrive «questa voce e' stata sovrascritta da», cosi' al tavolo si vede;
3. **non si incrociano** — le Conseguenze d'autore smettono di assegnare
   controllo, che e' mestiere delle caselle.

Quanto spesso capita non e' ancora misurato: serve una sonda che conti i
CAMBIA CONTROLLO della carta annullati dalla frase nello stesso Consiglio.

### 85. ✅ Il quarto beneficio non si compra mai — chiusa in 0.1.266

`regole` · `motore` · aperta in 0.1.264 ([D-301](DECISIONS.md#d-301)) ·
**chiusa da [D-303](DECISIONS.md#d-303)**: parola del committente, *«io a questo
punto toglierei la cicatrice, la lascerei come effetto malus o passivo»*. Il
tetto e' tre secco, la Cicatrice resta uno dei sei costi. La riga che sparisce
valeva uno e costava quattro.

[D-280](DECISIONS.md#d-280) dice: *«un beneficio e' gratis, ogni altro costa un
costo, e una Cicatrice ne compra uno oltre il limite»*. Misurato su 40 anni e
159 Consigli: **il quarto beneficio non lo compra nessuno**.

| quanti benefici comprati insieme | volte |
|---|---|
| 1 (gratis) | 89 |
| 2 | 31 |
| 3 | 39 |
| **4 (con la Cicatrice)** | **0** |

Conseguenza diretta: `scar:unanswered` — *«la domanda sul muro»* — sta come
Cicatrice su **sedici** carte Tensione e **non si e' mai posata in
quarant'anni**, perche' quella e' l'unica strada che ha.

Due letture, e vanno provate in quest'ordine:

1. **il cervello non ci prova**: la policy compra fino a tre e non valuta mai il
   quarto. Se e' cosi', e' una riga in `policy_decider`, e la regola torna viva
   subito;
2. **il quarto non conviene mai**: tre benefici costano due costi, il quarto ne
   costa due **piu' la Cicatrice permanente**, e nessun beneficio della carta
   vale una Cicatrice. Se e' cosi', il difetto e' nell'economia, non nel bot.

**Fatto quando** il quarto beneficio si compra almeno una volta in quaranta
anni, oppure e' scritto qui perche' nessuno lo comprerebbe mai — e allora la
riga della Cicatrice va tolta dalla carta invece di restarci a fare finta.

**Provate tutte e due in 0.1.265** ([D-302](DECISIONS.md#d-302)), e **sono vere
tutte e due.** Il cervello si fermava a tre per costruzione — il quarto non
veniva rifiutato, non veniva guardato: difetto vero, corretto. E col tetto
alzato il quarto **continua a non comprarsi**, perche' i conti dicono
`score=+1, worst=-2, scar=-2 → -3`. Il quarto beneficio vale uno e costa
quattro.

**Quindi non e' il bot, e' l'economia**, e la decisione e' del committente fra
le tre strade scritte in D-302: il quarto vale di piu', la Cicatrice costa meno,
oppure la riga si toglie dalla carta.

---

### 84. ✅ L'Eredita' e' misurabile, e quasi inerte — CHIUSA in 0.1.353 ([D-385](DECISIONS.md#d-385))

`regole` · `da-decidere` · **aperta in 0.1.262** ([D-299](DECISIONS.md#d-299))

Il secondo punteggio che il documento sulle trasformazioni chiede — *quanto di
quello che hai lasciato sopravvive al tempo* — e' stato misurato in tre versioni
su 672 salti d'era, **senza cambiare nessuna regola**.

Sommata ai gradini delle Chronicle, l'Eredita' **ribalta il vincitore della saga
4 volte su 24**, e l'accordo con chi ha piu' Trionfi passa da **4 a 5 su 24**:
dentro il rumore.

La ragione e' la solita, e arriva dalla terza misura diversa: la versione «solo
quello che si poteva perdere» collassa a un +1 piatto (nessuna casa tiene due
segni perdibili a un salto), e quella scritta nel documento paga di piu' le case
i cui desideri sono **memorie** — il Sale 2,56 a salto contro l'1,05 di Vaerax e
del Vetro. Cioe' premia la durata con un altro nome.

**Le tre strade**, e la decisione e' del committente:

1. **non scriverla** finche' ISSUES 76 non e' chiusa: la moneta non viene
   coniata, e nessuna scala puo' pesare quello che non c'e';
2. **scrivere la sola variante delle leggende** — *«+3 per ogni leggenda che
   porta il tuo nome»* — che e' l'unica che dice una cosa vera senza inventare
   un dato, ribalta il vincitore una volta su 24 e sta in una riga;
3. **cambiare i profili** perche' i desideri siano cose che il mondo sa dare e
   togliere, e allora tutte e tre le versioni tornano vive.

### ✅ Chiusa in 0.1.353: scelta la seconda strada ([D-385](DECISIONS.md#d-385))

Il committente ha scelto: **«a fine saga, +3 per ogni leggenda che porta il tuo
nome»**. Scritta, e misurata su 24 saghe da 8 anni sui due tavoli.

| | |
|---|---|
| saghe in cui l'Eredità **ribalta il vincitore** | **10 su 24** |
| accordo con chi ha più Trionfi, senza Eredità | 3 su 24 |
| accordo con chi ha più Trionfi, con Eredità | 3 su 24 |

**Morde** — molto più della variante misurata in D-299 (1 su 24), perché quella
pagava +3 a salto se *una qualsiasi* leggenda c'era, e questa paga +3 **per
leggenda**. E non migliora l'accordo coi Trionfi: è un secondo punteggio, non
una correzione del primo, che è quello che il documento chiede.

**Il costo dichiarato: due case su otto prendono zero, sempre.** Non perché
giocano male — perché i segni che vogliono lasciare non possono diventare
leggende. Continua in [ISSUES 124](#124).

---

### 83. ✅ La porta spalancata — CHIUSA in 0.1.362: nessuna casa sotto un salto su quattro

`regole` · `da-misurare` · **aperta in 0.1.261** ([D-298](DECISIONS.md#d-298)) ·
**chiusa in 0.1.362** ([D-394](DECISIONS.md#d-394))

> **La condizione era: «nessuna casa sta sotto 1 su 4, e la cosa si e'
> verificata su un numero e non a occhio».** Il numero c'e', ed e' in un
> documento che sta nei cancelli — [MISURA_VITE.md](MISURA_VITE.md), dodici
> saghe da otto anni sui due tavoli, 168 salti d'era:
>
> | casa | mutazioni | ogni quanti salti |
> |---|---|---|
> | ENT_CENERE | 36 | 1 ogni **4,7** |
> | ENT_NAHR | 33 | 1 ogni 5,1 |
> | ENT_VETRO | 31 | 1 ogni 5,4 |
> | ENT_ALDRIC · ENT_LIBERE | 30 | 1 ogni 5,6 |
> | ENT_LYRA | 24 | 1 ogni 7,0 |
> | ENT_SALE | 21 | 1 ogni 8,0 |
> | ENT_VAERAX | 20 | 1 ogni 8,4 |
>
> **La peggiore e' a 4,7 — sopra il limite**, e la sorveglianza continua da
> sola: se una scende sotto, il cancello delle vite va rosso.

La cura di ISSUES 81 ha un rovescio da sorvegliare. Se una porta fatta di sole
memorie non si apre **mai**, una porta con una gamba impossibile si apre
**sempre**: la casa cambia pelle a ogni salto lungo, qualunque cosa faccia, e
allora non e' una soglia — e' un calendario.

Il candidato misurato: la Repubblica della Valle chiede ad Aldric **due Regioni
fra capitale, granaio e traffico**, e sulla mappa pescata di quelle tessere ce
n'e' **una ciascuna**. E' esattamente quello che il committente ha chiesto
(*«un re deve controllare due citta'»*), e Aldric e' passato da una mutazione
ogni 15,3 salti a una ogni **6,0**.

Il segnale sta gia' in `MISURA_VITE.md`, che e' nei cancelli: **quanto spesso
una casa cambia pelle**. Il limite di casa e' che nessuna scenda sotto **un
salto su quattro** — una casa che muta a ogni salto non ha un'identita', ha un
costume. Oggi la peggiore e' Nahr a 4,8.

**Fatto quando** nessuna casa sta sotto 1 su 4, e la cosa si e' verificata su
un numero e non a occhio.

---

### 82. La coda della fustella: Cicatrici rare che vanno bene, e condizioni che non succedono

`contenuto` · **fuori dalla lista in 0.1.361** ([la lista](LE_TUE_DECISIONI.md)):
e' una potatura di componenti, e si fa quando la scatola si stampa ·
**aperta in 0.1.259** ([D-296](DECISIONS.md#d-296))

Misurato con `cli/run_punchboard_probe.gd`, 40 anni: dei **34 tipi** di
segnalino disegnati per la mappa, **17 non escono mai o escono meno di un anno
su cinque**. Sul tavolo, in un anno, se ne vedono **8,8 in media, 15 al
massimo**.

La coda va letta divisa in due, perche' sono due difetti diversi — e uno dei
due non e' un difetto:

- **Cicatrici rare = design.** `scar:divided_seal` due volte in quarant'anni e'
  memorabile. Una Cicatrice frequente sarebbe il problema.
- **Condizioni rare = buco.** `condition:starving` **1 anno su 40**,
  `condition:lean` 1, `condition:requisitioned` 1: la fame e' un Tema del
  gioco, e il motore quasi non sa produrla. Non e' cartone di troppo, e'
  contenuto che non succede.

E i quattro mai visti: `scar:broken_word`, `scar:dragonfall`,
`scar:unanswered`, `structure:sealed`. Gli ultimi due sono **nominati dai
profili** come voluti o temuti — e' ISSUES 76 un'altra volta.

**La decisione e' del committente**, e sono tre diverse:

1. ridurre i tipi (e quali: la coda e' quasi tutta Cicatrici);
2. lasciare i tipi e **far succedere le condizioni rare** — chi scrive
   `condition:starving`, e perche' non scatta mai;
3. non toccare niente: 9 tipi in tavola per anno non sono troppi da imparare.

**Aggiornamento 0.1.271.** La coda si e' mossa da sola con le decisioni
D-306/D-307/D-308, che hanno cambiato quali costi il fronte avverso sceglie:
`condition:plundered` **1 → 4** anni su 40, `condition:mourning` **1 → 3**,
`condition:requisitioned` **1 → 2**. E i mai visti sono ancora quattro, ma non
gli stessi: `structure:sealed` e' entrato (D-301) e al suo posto e' uscito
`settlement:market`, che nessuno ha tolto — la sua Conseguenza lo scrive ancora,
ma la questione che la porta al tavolo non passa piu' in quarant'anni. E' uno
spostamento a valle, non una cancellazione, ed e' dentro il rumore di una misura
su 40 anni.

**In 0.1.263 la strada 2 e' stata imboccata per la fame**
([D-300](DECISIONS.md#d-300)): nessuna delle dieci Tensioni della Sopravvivenza
sapeva affamare qualcuno, e adesso quattro di loro lo fanno quando cadono.
`condition:starving` **1 → 3 anni su 40**, `condition:lean` **1 → 3**. Restano
in coda `condition:requisitioned` (il suo posto e' un beneficio del Consiglio, e
i benefici li tocca il taglio 2), `condition:mourning` e `condition:plundered`.

**Fatto quando** il committente ha scelto, e il numero della coda si e' mosso
nella direzione scelta.

---

### 81. ✅ Una soglia non puo' leggere una memoria — chiusa in 0.1.261

`regole` · **aperta in 0.1.257** ([D-294](DECISIONS.md#d-294) ·
[la misura](MISURA_VITE.md))

La porta del tempo ([D-290](DECISIONS.md#d-290)) chiede: *«sono passati N anni e
il mondo non porta piu' almeno K dei segni che questa casa voleva lasciare?»*.
Misurato: **La Compagnia del Sale ha la porta e non si apre mai**, in 168 salti
d'era, perche' i segni che la Gilda vuole lasciare — `debt_called`,
`account_settled`, `ledger_public` — sono **memorie**, e una memoria scritta
resta nel mondo per sempre.

Una soglia che chiede *«tieni ancora?»* su una cosa che non si puo' perdere e'
una porta murata. Vale per ogni profilo: i desideri fatti di memorie sono
lucchetti a senso unico, quelli fatti di **condizioni, controllo e Pietre** sono
soglie vere, perche' il mondo sa toglierli.

Due strade, e la seconda e' quella del documento sulle trasformazioni:

- **stretta**: la porta guarda solo i desideri che il mondo sa togliere, e il
  validatore rifiuta una porta i cui segni sono tutti memorie;
- **larga** (passo c della linea): la soglia smette di leggere «quanti dei
  desideri» e legge condizioni proprie — controllo di luoghi, Pietre in piedi,
  Cicatrici, leggi — come nel documento del committente.

**Fatto quando** ogni vita che dichiara una porta del tempo si e' seduta almeno
una volta in `MISURA_VITE.md`, oppure la sua porta e' stata tolta perche'
sbagliata.

**Chiusa in 0.1.261** ([D-298](DECISIONS.md#d-298)): la porta adesso legge
Regioni controllate, Pietre in piedi e condizioni sparse, e il validatore
pretende che **almeno una gamba sia una cosa che il mondo sa togliere** — col
suo difetto piantato. Tutte e sei le vite con una porta si siedono:
**La Compagnia del Sale 0 → 14**, **La Diaspora di Nahr 0 → 10**.

Resta aperto il rischio speculare, che e' la voce nuova
[83](#83-la-porta-spalancata-una-gamba-che-nessuno-riesce-mai-a-tenere).

---

### 80. Il Consiglio sono due Consigli impilati, e a decidere e' quello vecchio

`regole` · `ux` · **aperta in 0.1.253** — parola del committente davanti
all'app: *«il Concilio e' ancora quello vecchio, mi sa che va cambiato tutto»*.

Ha ragione su quello che vede, e la ragione e' piu' precisa della frase: **lo
schermo e' vecchio al cento per cento, le regole a meta'.**

Un Consiglio vero, preso dal registro di una partita giocata:

```
A. Trigger: THRESHOLD su I Senza Citta'
B. Domanda: Nelle Terre Nahr, chi decide a chi non ne tocca?   <- template
C. Proponente: Lyra
C. Proposta: Si conti quello che c'e', e Lyra decida chi ne ha diritto.  <- template
C. Lyra compra: Assegna o trasferisci il controllo del luogo. (prezzo: 0 costi)  <- D-280
D. Kessa: Condition - ...purche' chi se ne va possa tornare.   <- voto vecchio
D. Vaerax: ABSTAIN                                             <- voto vecchio
E. Rivelazione simultanea degli impegni: ...                   <- carte segrete
F. World Factor: 1d6 = 1 -> -2                                 <- il dado
G. S=3 C=3 O=0 W=-2 -> M=4 -> SUCCESS                          <- l'aritmetica
H. Beneficio / Prezzo / Conseguenza / Clausola qualificata     <- misto
```

La sequenza A-K della specifica v0.2 e' ancora intera, e l'economia di
[D-280](DECISIONS.md#d-280) le sta **accanto**, non al posto. Quello che decide
e' ancora: voti + carte impegnate in segreto + **un d6**. La mappa e i segni
entrano solo dopo, quando il risultato e' gia' deciso.

Lo schermo, dal canto suo, disegna solo la meta' vecchia: la carta della
Tensione, la Domanda, la Proposta, le pose (sostieni/opponiti/astieniti/a
condizione) e le Conseguenze. **Dei benefici comprati, del prezzo, della pedina
e della controproposta non mostra niente.**

**Le misure di oggi** (40 anni, 158 Consigli — con la sonda del prezzo appena
riparata, vedi sotto):

| | |
|---|---|
| benefici comprati | 245 (1,55 a Consiglio) |
| Consigli che comprano solo il gratis | 87 |
| che pagano 1 costo / 2 costi | 55 / 16 |
| prezzi davvero scattati | 62, di cui **19 Cicatrici** |
| **il fronte avverso ha scelto la moneta** | **29 volte (18%)** |
| controproposte | 39 |

Quindi l'economia **gira** — il 45% dei Consigli paga qualcosa — e non si vede.

**La sonda era cieca su due righe** e le sue due voci a zero («costi diversi 0»,
«sfoghi diversi 0») erano sue, non del tavolo: cercava il formato di log che il
motore ha smesso di scrivere con [D-278](DECISIONS.md#d-278). Riparata:
11 voci di costo diverse scelte dal fronte, 8 scattate davvero. **E' la quinta
volta in questo progetto che uno zero era la sonda.**

**I tre tagli, in ordine**, da decidere col committente:

1. ✅ **Lo schermo dice il Consiglio nuovo** — **fatto in 0.1.254**
   ([D-291](DECISIONS.md#d-291)): la faccia stampata della Tensione sul
   tabellone, i benefici con la pedina su quelli comprati, il prezzo in cifre,
   chi tiene la pedina del prezzo, la controproposta e cosa succede se cade.
   Nessuna regola toccata.
2. 🔨 **La Domanda e la Proposta vengono dalla carta** — **Fase A e primo Tema
   fatti in 0.1.272** ([D-310](DECISIONS.md#d-310)), scelta del committente:
   *«ogni carta sue proposte»*.

   Misurato prima di scrivere: **sette domande generiche coprivano 52 carte su
   60** — La Febbre Bassa, I Lupi al Limitare e Il Grano Guasto aprivano lo
   stesso dibattito. Adesso ogni carta porta il suo blocco `council`, il
   template resta solo per quello che non e' della singola carta, e la misura
   della matrice conta le **carte che aprono ancora una domanda in prestito**
   guardando il **testo**, non l'id.

   Scritta la **Sopravvivenza**: 9 carte, 18 domande e 27 proposte nuove.
   **52 → 43 carte in prestito.**

   Scritto in 0.1.273 il **Potere** ([D-311](DECISIONS.md#d-311)): 8 carte, 16
   domande e 24 proposte nuove. **43 → 35 carte in prestito.** In 0.1.274 le
   **Vie** ([D-312](DECISIONS.md#d-312)): 7 carte, 14 domande e 21 proposte.
   **35 → 28.**

   ✅ **Chiuso in 0.1.345** ([D-378](DECISIONS.md#d-378)). Il lavoro era
   **fermo in attesa della parola del committente**: la voce
   [89](#89-la-proposta-non-si-risolve-col-dito-642-effetti-che-nessuna-carta-stampa)
   metteva in dubbio la grammatica in cui quelle proposte sono scritte, e gli
   ultimi tre Temi dovevano aspettare quella scelta. **La 89 è chiusa da
   0.1.332**: le otto caselle sono scritte, il `dove` e il `chi` ci sono
   ([D-366](DECISIONS.md#d-366)), la grammatica non si butta. L'attesa era
   finita e nessuno l'aveva notato.

   Scritti gli ultimi tre Temi, uno per volta: **Antico** (9 carte, 18 domande,
   27 proposte) **28 → 19**, **Fede** (9 / 18 / 27) **19 → 10**, **Terra**
   (10 / 20 / 30) **10 → 0**. Ogni carta ha due domande sue e tre proposte sue,
   e i **194 testi delle proposte sono 194 testi diversi**.

   Nello stesso passo sono cadute due sonde che guardavano ancora i template
   invece delle carte — il catalogo dei Consigli (12 schede per 60 carte) e il
   denominatore di *«quanto contenuto d'autore il tavolo vede»*. **La terza è
   caduta in 0.1.345**: `REVISIONE_TESTI.md` leggeva i template e saltava 314
   testi veri.
3. **Chi decide**: il d6 e gli impegni segreti contro l'economia. Se passa
   perche' il proponente puo' pagare quello che il tavolo chiede, il dado esce
   dal gioco — ed e' la modifica che vale la parola del committente, non la mia.

---

### 79. ✅ Quattro case su otto non hanno un profilo — chiusa in 0.1.257

`contenuto` · **aperta in 0.1.252** ([D-290](DECISIONS.md#d-290) ·
[la misura](MISURA_VITE.md))

La porta del tempo legge il profilo strategico, per non essere un secondo
elenco che diverge dal primo. Conseguenza diretta: **si può scrivere solo sulle
quattro case che un profilo ce l'hanno** — Aldric, Nahr, Lyra, Vaerax. Le altre
quattro (Cenere, Città Libere, Sale, Vetro) non possono averla, e il validatore
lo dice a voce alta invece di lasciarla scrivere e non aprire mai.

Il conto: delle **sette vite che in 168 salti d'era non si sono mai sedute**,
**cinque** appartengono a quelle quattro case — I Forni Riaccesi e Le Custodi
della Cenere, La Compagnia del Sale, e le vite tardive del Vetro. Sono
contenuto scritto che al tavolo non esiste (D-035), e la chiave per aprirle
esiste già: manca il profilo.

**Fatto quando** le otto case hanno un profilo scritto con la stessa forma delle
quattro di D-288, e `MISURA_VITE.md` mostra le vite mai sedute scendere.

**Chiusa in 0.1.257** ([D-294](DECISIONS.md#d-294)): gli otto profili ci sono,
gli incroci passano da 7 a 15 e le coppie che hanno qualcosa per cui litigare da
3 a 9 su 28. Le Custodi della Cenere si siedono 20 volte e i Frati del Vetro 18.
**La seconda metà del «fatto quando» non è stata raggiunta**: le vite mai sedute
restano 7 — l'insieme è cambiato, il conto no — e la ragione è scritta in D-294
punto 2, che è diventata la voce nuova [81](#81-una-soglia-non-puo-leggere-una-memoria-perche-una-memoria-non-si-perde).

**E in 0.1.256 questa voce ha guadagnato un secondo numero** che la rende più
urgente ([D-293](DECISIONS.md#d-293)): gli **incroci** — i segni che aiutano una
casa e ne danneggiano un'altra — sono **7**, e le coppie di case che hanno
qualcosa per cui litigare sono **3 su 28**. Quasi tutti gli incroci stanno fra
le quattro case che un profilo ce l'hanno. Le quattro senza non hanno soglie,
non hanno incroci, e le loro cinque vite non si siedono mai: **è lo stesso buco
visto da tre parti**.

---

### 78. Il profilo strategico lo legge la misura, non il gioco

`motore` · `ux` · **aperta in 0.1.250** ([D-288](DECISIONS.md#d-288)) ·
**letta in 0.1.251** ([D-289](DECISIONS.md#d-289))

I quattro profili dicono cosa una casa vuole lasciare nel mondo, e per adesso
li leggono **il validatore** (che li conta fra i lettori dei segni) e **la
misura** (che ne ricava chi sa dare ogni desiderio). **Il cervello no, e lo
schermo nemmeno.**

Finché non li leggono, la strategia è dichiarata e non giocata. Sono due cose
diverse e vanno tutte e due:

- **il cervello**: D-285 gli ha dato un ripiego — «gioca la più debole che la
  mano permette»; il profilo gli darebbe una *preferenza*, cioè una ragione per
  scegliere quella carta invece di quell'altra;
- **lo schermo**: è quello che permette all'app di dire «questo segno ti serve»,
  «questa questione aiuta un rivale» — e di dirlo **leggendo lo stesso file del
  bot**, non una seconda copia.

**Fatto quando** una partita giocata dal cervello si vede scegliere in base al
profilo (misurabile: quante mosse vanno verso un segno voluto), e la colonna di
destra nomina almeno un segno del profilo del seggio che sta guardando.

**In 0.1.251 li leggono tutti e due** ([D-289](DECISIONS.md#d-289)), e **una
delle due metà è servita, l'altra no.**

- **Lo schermo**: fatto. Il blocco «COSA RESTERÀ DI TE» in fondo alla colonna
  nomina ogni segno del profilo, in italiano, e accende in oro quelli già sul
  tavolo. Quattro prove lo tengono, e mordono.
- **Il cervello**: legge, e non cambia quasi niente. Misura appaiata su 40 anni
  con gli stessi semi — segni voluti posati **17 → 17**, segni temuti posati
  **17 → 14**, benefici comprati al Consiglio che davano al proponente un segno
  voluto **15 su 246 → 15 su 245**.

Tre autolesioni evitate in quarant'anni, e al Consiglio zero. Non è la bilancia
a essere sorda: **è che non c'è niente da preferire**. È
[ISSUES 76](#76-il-consiglio-decide-con-una-moneta-che-i-destini-non-spendono)
guardata dal lato di chi sceglie — le facce delle Tensioni e le voci del
Consiglio non parlano la moneta che i profili nominano. Questa voce resta
aperta e **appesa a quella**: si richiude da sola il giorno in cui il
macchinario produce le cose che le case dichiarano di volere. Alzare il peso non
la chiude, la peggiora.

---

### 76. ✅ Il Consiglio decideva con una moneta che i Destini non spendono — chiusa in 0.1.270

`regole` · `contenuto` · aperta in 0.1.249 ([D-287](DECISIONS.md#d-287)) ·
**chiusa da [D-308](DECISIONS.md#d-308)**, strada **(a)** scelta dal committente:
i benefici delle Tensioni producono segni che qualcuno insegue.

> Il vocabolario del beneficio non aveva il verbo che la direzione del progetto
> nomina — *«il Consiglio decide cosa il mondo ricordera'»*. Aggiunto
> **IL MONDO RICORDA**, e messo su tutte e 60 le carte.
>
> **Tensioni che non toccano nessun segno nominato da un Destino: 34 → 0.**
> **Fra i voluti, quelli che un Consiglio sa dare: 7 → 25.**
> Al tavolo si compra **24 volte in 40 anni** e scrive 19 fatti su otto diversi.
>
> Restano aperte due cose che non sono questa: i **33 livelli di Destino che si
> reggono solo su conteggi** (litigano con tutti allo stesso modo) e le **19
> coppie di case su 28 senza niente per cui litigare** — la superficie degli
> incroci, che e' la strada (b) o (c) e non e' stata imboccata.

Misurato: le facce delle 60 Tensioni posano **24 segni** e ne tolgono **uno**.
I Destini e gli obiettivi ne **vogliono 17** e ne **temono 17**. L'incrocio:

- dei 24 posati, **3** sono temuti da qualcuno per nome;
- dei 17 voluti, **nessuno** si può ottenere vincendo un Consiglio;
- **35 Tensioni su 60** non toccano nessun segno che un Destino nomina.

Tutte e 60 hanno un conflitto *strutturale* — la faccia alza una Pietra e
incide una Cicatrice, e i Destini le contano — ma è **lo stesso su tutte**: è il
modello della faccia (D-280), non è contenuto. Al tavolo vuol dire che il
Consiglio è una cosa che succede, non una cosa che qualcuno *voleva*.

È il buco che la matrice strategica del committente vuole chiudere, e la cura
può stare da tre parti: i benefici delle Tensioni (che dovrebbero produrre segni
che qualcuno insegue), i Destini (che dovrebbero nominare segni che un Consiglio
può dare), o un ponte dichiarato fra i due (`entity_strategic_profiles`).
**Quale delle tre è una decisione del committente.**

**Aggiornamento 0.1.250** ([D-288](DECISIONS.md#d-288)): con i profili
strategici scritti, il buco si dice adesso per casa invece che in generale —
**delle 16 cose che le quattro case di CHR_01 vogliono lasciare nel mondo, un
Consiglio ne sa dare 4.** Le altre dodici si ottengono con una carta, con una
Conseguenza, o non si ottengono affatto.

**Fatto quando** ogni Tensione tocca almeno un segno nominato da almeno un
Destino della scatola, e almeno un beneficio comprabile produce un segno che
almeno un Destino vuole.

---

### 77. ✅ Quindici segni muti senza una ragione scritta — CHIUSA in 0.1.363: zero

`contenuto` · `debito` · **aperta in 0.1.249** ([le misure](MISURA_MATRICE.md)) ·
**chiusa in 0.1.363** ([D-395](DECISIONS.md#d-395))

> **La condizione era: «ognuno dei quindici o trova un lettore, o porta la sua
> ragione scritta come gli altri 49».** Erano quindici, poi undici. Adesso
> [MISURA_MATRICE.md](MISURA_MATRICE.md) dice **zero**: gli orfani dichiarati
> sono 60 su 60.
>
> Le undici ragioni non sono un timbro: sono **una frase vera per ognuno**, e
> quasi tutte dicono la stessa cosa — **quei segni sono bersagli, non premi**.
> `capitale`, `commercio`, `selvaggio`, `cristallo` sono stampati sulla tessera e
> servono alle carte per dire **dove**; `tradimento detto`, `ci si e' parlato`,
> `la richiesta e' stata ascoltata` sono memorie che una faccia interroga per
> cambiare quello che fa; `requisito` e' un ostacolo che si trova.
>
> Due portano invece una ragione **con un difetto dentro**, e sta scritto li':
> `structure:castle` e `structure:library` sono **gradi alti** di una scala che
> si insegue col primo grado (arrivano 92 e 14 volte su cento partite), e
> `structure:palace` **non arriva mai** — che e' un difetto vero, ma e' quello
> delle Pietre che non si alzano ([ISSUES 111](#111)), non un segno senza
> ragione.

Su 150 segni scritti, **67 sono orfani** — nessuno li vuole, nessuna Tensione li
tocca, nessuna regola li usa, l'eredità non li porta avanti. **49 portano già la
loro ragione** e restano (memorie narrate D-103, etichette di famiglia, gradi di
pietra, domini che legge il motore).

Ne restano **15 senza una riga che spieghi perché esistono** — fra cui
`condition:lean`, `condition:requisitioned`, `structure:castle`,
`structure:library`, `structure:palace`. Tre pietre di grado alto che nessuno
insegue sono contenuto costoso e muto.

**Fatto quando** ognuno dei quindici o trova un lettore (un Destino, una
Tensione, una regola) o porta la sua ragione scritta come gli altri 49.

---

### 74. ✅ I segni stampati che non trovano dove stare — chiusa in 0.1.246

`motore` · `regole` · **chiusa** ([D-284](DECISIONS.md#d-284))

**Chiusa e misurata**: 862 segni stampati sulle Azioni calate in 100 anni,
**862 posati, 0 senza soggetto**. La carta dice il posto col suo bersaglio a
segni; chi cala lo sceglie fra i luoghi che raggiunge. Il testo originale:

Con D-283 le Azioni stampate posano i loro segni. Su 100 anni: **851 segni
stampati sulle Azioni calate, 537 posati, 314 senza un soggetto** — quasi tutti
condizioni di Regione (`condition:contested` 160 volte) su mosse che una Regione
non la nominano: INFLUENZARE parla a una domanda, FORGIARE a una casa.

Non si scrivono altrove — sarebbe posare un segnalino dove al tavolo nessuno
saprebbe metterlo — quindi la carta dice una cosa che non succede. Al tavolo la
risposta c'è già: **il bersaglio è stampato sulla faccia**, a segni (D-274).
Serve che la scelta del posto arrivi anche ai verbi che oggi non la chiedono.

**Fatto quando** i segni senza soggetto sono zero su 100 anni, e il cancello
tiene.

---

### 75. ✅ Le Memorie che nessuno legge — quindici tornano a mordere in 0.1.248

`contenuto` · `debito` · **aperta in 0.1.245** · **chiusa in 0.1.248**
([D-286](DECISIONS.md#d-286))

**Chiusa, e con una correzione al testo di apertura**: le 27 non erano un
difetto — ognuna porta la sua ragione scritta, e quindici dicevano «memoria del
mondo: narrata, ereditata». Il difetto vero era che **la pesca dell'era
successiva non ascoltava nessuna memoria**. Adesso quindici stanno negli
`echoes` delle Chronicle, e in **21 anni su 30** almeno una chiama la sua
domanda per l'anno dopo.

Restano fuori, dichiarate: le sei che sono **marchi sulla carta del casato**
(D-278) — ha parlato e ha perso, si è servito, la parola fredda — che si
leggono al tavolo e non in una regola, e quattro memorie narrate senza una
domanda propria.

**Il testo originale:**

---

### 73. Nessuna prova lega la domanda a quello che si può toccare

`ux` · `motore` · `debito` · **aperta e in parte chiusa in 0.1.243**
([D-281](DECISIONS.md#d-281))

> **Il committente, aprendo l'app:** *«non mi fa giocare le carte, non so quali
> azioni fare»*.

Per un numero imprecisato di versioni **nessuna carta era giocabile a schermo**:
`ask()` costruiva le offerte dopo aver disegnato la mano, e una carta col carico
vuoto non si prende. Il difetto è chiuso, ma il **buco che l'ha lasciato
passare** no del tutto: la suite prova la mano (`test_drag_and_drop`) riempiendo
il carico a mano, e provava lo schermo (`test_the_page_can_be_read_by_a_finger`)
senza mai aprire una domanda. Fra i due pezzi, ognuno verde, ci stava un turno
che non si poteva giocare.

`test_a_turn_can_be_played` chiude il caso della **fase delle azioni**. Restano
scoperti allo stesso modo: il giro del **Consiglio** visto da una persona (la
proposta, i benefici comprati, il prezzo scelto, gli impegni), la scelta del
**Destino** e la fine della Chronicle. Ognuno è una domanda che passa dallo
stesso `io`, e ognuno può essere morto senza che un cancello se ne accorga.

**Fatto quando** ogni passo in cui il motore chiede qualcosa a una persona ha
una prova che parte dal decider e finisce su quello che si può toccare sullo
schermo — e nessuna di quelle prove passa costruendosi il carico da sé.

---

### 72. ✅ Il cuore del Consiglio: le due liste sulla carta Tensione

`regole` · `contenuto` · **aperta in 0.1.240**
([D-278](DECISIONS.md#d-278)) · **Fase A chiusa in 0.1.240** · **chiusa in 0.1.308**
([D-343](DECISIONS.md#d-343))

> **Richiamo del committente:** *«nelle tensioni ci dovrebbero essere anche i
> vantaggi e gli svantaggi che possono essere scelti e proposti durante il
> consiglio, dove sono? Non sono stati né implementati né misurati. Dovrebbe
> essere il cuore del gioco.»* Aveva ragione: il meccanismo c'era da D-267,
> il contenuto no — **il menu dei malus era la stessa coppia su tutte e 60 le
> carte**, e 40 domande su 107 offrivano una sola proposta.

**Fase A — i malus (fatta).** Le liste `costs` e `failures` sulla faccia della
carta, 12 Conseguenze nuove, 240 testi diversi, il motore che legge il menu
dalla carta, la scheda che le mostra, la guardia (controllo 18) e la sonda.
Menu distinti: costo **2 → 21**, sfogo **2 → 25**; al tavolo, 34 e 34 voci
diverse lette in 40 anni.

**Fase B — l'economia, riscritta da [D-280](DECISIONS.md#d-280) (aperta).** La
carta d'esempio del committente ha corretto la Fase A: non frasi d'autore ma
un **vocabolario chiuso di verbi legati ai segni della mappa**, posati con le
**pedine**, dentro un'economia — *1 beneficio è gratis; ogni beneficio in più
costa 1 costo; una Cicatrice ne compra uno oltre il limite*; max 3 benefici,
max 2 costi. **Il proponente compra, gli avversari scelgono in che moneta
paga.** Da costruire: i verbi come dato (RIAPRI, RIMUOVI CONDIZIONE,
COSTRUISCI PIETRA, CAMBIA CONTROLLO, RAFFREDDA TEMA / AGGIUNGI CONDIZIONE,
PEDAGGIO, CEDI CONTROLLO, SCALDA TEMA, PRENDI DEBITO, CICATRICE), la faccia
delle 60 carte riscritta su quelli, il passo del Consiglio che posa le pedine,
il cervello che sa comprare e far pagare, e gli effetti fissi se la proposta
cade. Da misurare guardando il passa (ISSUES 68): un proponente che compra
sposta quel numero, e va scritto.

**Fase C — soglia e velo: chiusa dalla parola del committente.** *«Nessun
costo di apertura, la tensione si risolve a fine atto.»* Quindi: la **soglia
non si stampa** sulla faccia — non apre più niente da D-214/D-260/D-261 — e il
numero in alto a destra della carta d'esempio non è una regola. Il velo resta
vivo (TRAMARE scopre) e resta stampato.

> ### Correzione in 0.1.307: quello che questa voce dà «da costruire» è costruito
>
> La riga qui sopra elenca fra le cose da fare *«i verbi come dato […], il passo
> del Consiglio che posa le pedine, il cervello che sa comprare e far pagare»*.
> Sono in `scripts/confluence/council_economy.gd` da tempo: **dodici verbi,
> l'economia, l'idoneità di ogni casella** ([D-306](DECISIONS.md#d-306)), e il
> controller li applica. Nessuno aveva riportato la voce indietro
> ([D-342](DECISIONS.md#d-342)).
>
> Quello che restava di questa voce era **una sola riga del suo «fatto
> quando»**: la sonda che dice quanta scelta arriva davvero al tavolo.
>
> **Scritta in 0.1.308** ([D-343](DECISIONS.md#d-343)): `run_boxes_probe.gd` si
> siede fra il cervello e il Consiglio e conta quante volte ogni casella e'
> offerta e quante e' presa. La prima misura, venti partite: CAMBIA CONTROLLO
> 32 su 32, COSTRUISCI PIETRA 27 su 49, RAFFREDDA TEMA 6 su 72, ABBASSA LA
> DOMANDA **1 su 72**, PEDAGGIO e PRENDI DEBITO **0**.
>
> **La voce si chiude qui.** Quello che la misura ha trovato — caselle offerte e
> mai prese — non e' questa voce: e' equilibrio, e vive nei numeri della sonda.

**Fatto quando** ogni carta Tensione porta i suoi verbi di beneficio e di
costo, il Consiglio si gioca posando pedine dentro l'economia dichiarata, la
sonda mostra quanta scelta arriva davvero al tavolo, e sulla faccia non resta
stampato niente che il motore non esegua.

---

### 71. ✅ La controproposta del RIVENDICARE non esiste ancora (PZ-5, Fase B)

`regole` · `motore` · **aperta in 0.1.229** ([D-267](DECISIONS.md#d-267)) ·
**chiusa in 0.1.230** ([D-268](DECISIONS.md#d-268))

> **Fatta.** Il titolare del diritto sceglie al primo Consiglio: pedina del
> prezzo (scavalcando il primo OPPOSE), voce del beneficio rivendicata (a
> proposta passata parla di lui), o il secondo dibattito di sempre. 117
> controproposte in 100 anni di CHR_01; il costo — i Consigli scendono a 3,6
> di media perché il cervello preferisce quasi sempre la controproposta — è
> scritto in D-268, e la taratura è d'autore.

Parola del committente (D-261): il RIVENDICARE *«può servire in primis per
fare una controproposta sulla Tensione che si va dibattendo — mettere una
pedina su un beneficio o su un costo — oppure per dibattere una seconda
tensione»*. Il secondo uso vive da 0.1.223 (il secondo mazzetto più alto a
fine Atto). Il primo no: da 0.1.229 la **pedina del prezzo** esiste ed è del
primo OPPOSE dichiarato ([D-267](DECISIONS.md#d-267)) — la Fase B è dare a
chi spende un RIVENDICARE il diritto di **prendersela** (scavalcando l'ordine
delle dichiarazioni), o di rivendicare una voce del **beneficio** della
proposta. Tocca le proposte e le clausole del Consiglio; da disegnare insieme
alla lettura del «fatto quando» di PZ-5 — il Consiglio che cambia il
significato delle Azioni già fatte.

### 70. Il dizionario dei segni esiste, e due voci parlano ancora per conto loro

`strumenti` · `contenuto` · `debito` · **aperta in 0.1.221** ([D-259](DECISIONS.md#d-259))

> **Avanzamento in 0.1.368** ([D-400](DECISIONS.md#d-400)): **anche il punto 1
> e' chiuso.** Il dizionario dichiara adesso `title_spoken` — *«la forma con cui
> l'app dice questo segno dentro una frase, quando non e' quella stampata sul
> gettone»* — e `sign_labels.gd` **si genera da li'**, col suo cancello, il
> trentunesimo.
>
> Le 118 parole dell'app sono rimaste **identiche una per una**, tranne una: e'
> proprio il difetto che la voce nomina. `heir_named` aveva **due parole
> diverse** nello stesso file — «l'erede nominato» sulla scheda della casa e
> «l'erede e' stato nominato» al centro del tavolo. Adesso ne ha una sola, e la
> scheda dice la seconda.
>
> **Quali segni hanno una parola non e' una lista a parte**: sono quelli con un
> gettone di cartone, cioe' quelli nominati da `godot/data/token_icons` — le due
> liste combaciavano gia' su 117 segni su 117, e le sette voci `pedina:*` sono
> pezzi del gioco, non segni.
>
> **Restano i punti 3, 4 e 5**, e il 3 lo rimanda la voce stessa.


> **Avanzamento in 0.1.367** ([D-399](DECISIONS.md#d-399)): **il punto 2 e'
> chiuso.** `MUTI_NOTI` non tiene piu' le ragioni — tiene solo gli id e il
> numero che il registro misura da se'. **La ragione la legge dal dizionario**,
> dalla `note` della voce, e una guardia nuova va rossa se un muto e' dichiarato
> qui e il dizionario non dice perche'. Era una seconda copia di undici ragioni,
> cioe' due posti da aggiornare e uno destinato a invecchiare: la stessa forma
> di D-338, D-398 e ISSUES 105.
>
> **E il punto 1 e' diagnosticato, e non e' quello che sembrava.** Delle 118
> parole di `sign_labels.gd` che sono segni, **37 non combaciano col dizionario**
> — ma quasi tutte perche' l'app dice *«contesa, razionata, requisita»* mentre il
> gettone stampa *«conteso, razionato, requisito»*: e' **l'accordo con la
> Regione**, che e' femminile, non una divergenza. Generare `sign_labels.gd`
> dal dizionario cosi' com'e' romperebbe l'italiano dell'app. Serve che il
> dizionario dichiari **anche la forma che accorda**, e allora la generazione e'
> meccanica. Riga, non voce nuova.


Da 0.1.221 i segni sono una collezione dichiarata (`godot/data/tags`, 171 voci:
nome stampato, categoria, ambito, chi scrive, chi legge) e
`validate_physical.py` la tiene allineata ai dati, con un self-test che si vede
mordere in CI. Ma la conversione ha trovato che **lo stesso segno aveva fino a
tre nomi** — `#malcontento` sulla carta, «inquieta» nell'app, un nome per grado
sulle pietre — e per adesso le forme divergenti sono solo **congelate** negli
`aliases` delle voci: dichiarate, non riunificate.

**Cosa resta, in ordine di peso:**

1. **`sign_labels.gd` parla per conto suo.** È «l'unico posto dove un tag
   diventa una parola» per l'app, ed è una tabella scritta a mano nel codice:
   o legge dal dizionario a runtime, o viene generata da esso con un drift
   check. Finché non succede, ogni segno nuovo si battezza due volte.
2. **`MUTI_NOTI` di `build_sign_registry.py` è un'altra lista parallela.** Le
   ragioni dei segni muti adesso vivono nelle `note` del dizionario; il
   registro dovrebbe leggerle da lì invece di tenersi la sua copia (con le
   conte misurate, che sono la parte sua vera).
3. **Due segni, una parola**: la vocazione `granary` e la pietra
   `structure:granary` si stampano entrambe `#granaio`. Al tavolo non si
   distinguono. Si scioglie ri-mirando i bersagli delle carte (PZ-3), non
   rinominando di nascosto.
4. **I segni che solo il motore tocca restano fuori** (`uprooted`,
   `seal_kept`, `seal_kept_twice`, `scar:burned_records`, `condition:guarded`):
   il censimento vede i dati, non il codice. Servirebbe un censimento del
   motore, o la dichiarazione esplicita di queste voci con mano `engine` da
   entrambi i lati.
5. **L'icona è dichiarata nello schema e non compilata**: aspetta l'arte dei
   segni (il BRIEF non la copre ancora).

**Fatto quando** un segno nuovo si battezza **una volta sola**: l'app prende la
parola dal dizionario (o `sign_labels.gd` è generato e sorvegliato da un drift
check), il registro dei segni legge le ragioni dalle `note`, e `#granaio` vuol
dire una cosa sola sul tavolo.

---

### 69. La Risonanza è scritta e non succede

`contenuto` · `direzione` · `da-decidere` · **rossa R9 dalla 0.1.361**
([la lista](LE_TUE_DECISIONI.md)): resta il **formato** della carta, ed e' una
scelta d'autore che viene prima dell'arte · **aperta in 0.1.218** ([D-256](DECISIONS.md#d-256)) ·
**cure in 0.1.219** ([D-257](DECISIONS.md#d-257)), **0.1.220**
([D-258](DECISIONS.md#d-258)) e **0.1.222** ([D-260](DECISIONS.md#d-260)) ·
**aperta**

> **Fatto in 0.1.219: la Risonanza succede.** Giocare una carta con una faccia
> fisica scalda il Tema che ci sta scritto, come Effetto con inverso e con una
> firma sua (`kind: "resonance"`) così che il verbale distingua quello che hai
> scelto da quello che il mondo ha risposto. Con una regola di contorno che vale
> più del resto: **la Risonanza avvicina, non decide** — non porta mai una
> questione alla soglia da sola.
>
> **Fatto in 0.1.220: tutte e quarantotto le carte hanno una faccia.** Le
> Risonanze passano da 163 a **364 in 100 anni — 3,6 per anno**, e la metà
> condizionale scatta nel **10,2%** dei casi.
>
> ### Fatto in 0.1.305: la faccia si stampa. Resta il formato.
>
> Il committente, guardando la carta Azione generata: *«devi eliminare ogni
> narrativa prolissa»*. La faccia fisica c'era in tutte e 48 le carte e **la
> carta stampata non ne diceva niente**: bersaglio 0 su 48, Risonanza 0 su 48,
> uso in Consiglio 0 su 48, e delle 96 Azioni ne arrivava una sola, detta col
> verbo digitale invece che col suo nome.
>
> Adesso la faccia si stampa per intero ([D-340](DECISIONS.md#d-340)): **DOVE**,
> le due Azioni numerate col loro nome, **SEMPRE** e **AL CONSIGLIO** — le
> ultime due generate dai campi, non scritte a mano. I 96 testi delle Azioni
> sono stati riscritti togliendo il colore e tenendo ogni regola: 8.666
> caratteri → 5.751.
>
> **Quello che resta non e' piu' il contenuto, e' il formato.** Su 48 carte, 0
> escono dal bordo ma **46 stampano il corpo rimpicciolito** (la piu' stretta al
> 77%), e l'illustrazione e' scesa al suo pavimento del 34% su tutte. Una carta
> 63x88 che porta sette righe di regole **e** un'illustrazione e' una carta che
> si legge male. Le due strade — tarocco anche per le Asset, come la scheda del
> Consiglio ([D-338](DECISIONS.md#d-338)); oppure l'illustrazione fuori dalla
> faccia delle regole — sono misurabili tutte e due, e la scelta e' del
> committente.


> **Correzione a quanto scritto sopra in 0.1.219**: il «0 su 163, contenuto
> morto» era **un numero sbagliato**. La sonda contava le aggravate dai segni
> lasciati sulla mappa, e quasi tutte le carte aggravano solo il Calore. Il
> difetto vero era più piccolo e più preciso — **sei carte su dodici temevano un
> segno che il loro verbo non può raggiungere** — ed è curato, con un controllo
> nuovo nel validatore che lo dice per nome.

La grammatica fisica esiste nei dati: dodici carte hanno bersaglio a segni, due
Azioni, una Risonanza obbligatoria e un uso in Consiglio. **Il motore ne legge
adesso due parti: la Risonanza, e — da 0.1.236
([D-274](DECISIONS.md#d-274)) — il bersaglio a segni dei verbi che nominano
una Regione (MUOVERE, e TRAMARE su una Regione), coi segni vivi come al
tavolo. Restano le facce a bersaglio ENTITY e TENSION, le due Azioni e l'uso
in Consiglio.**

Quando una carta si gioca, il motore guarda `card_action.kind` — un verbo solo,
senza scelta e senza reazione — e il blocco `physical` non lo apre nessuno. Al
tavolo la carta funziona; nell'app è ancora quella di prima. Le due grammatiche
convivono e non si toccano, e questo è **voluto per adesso**: il ponte è scritto
(`from_template` e `from_question` legano ogni Domanda fisica al Consiglio da cui
nasce) ma nessuno lo attraversa.

**Cosa manca, in ordine di peso:**

1. ✅ **La Risonanza non avviene** — fatta in 0.1.219 ([D-257](DECISIONS.md#d-257)).
2. ✅ **Trentasei carte senza faccia fisica** — fatte in 0.1.220
   ([D-258](DECISIONS.md#d-258)): 48 su 48.
3. ✅ **La metà condizionale non scatta mai** — era in parte un numero sbagliato
   e in parte sei carte cieche; entrambe curate in 0.1.220. Oggi: **10,2%**.
4. **La scelta fra le due Azioni non esiste.** Il cervello sceglie un verbo, non
   una carta con due facce: `_choose_intent` non sa che una carta offre un bivio,
   e il motore esegue la `card_action` di sempre.
5. ✅ **Il Calore dei Temi non è una traccia** — fatta in 0.1.222
   ([D-260](DECISIONS.md#d-260)) e rifatta in 0.1.223 nella forma voluta dal
   committente ([D-261](DECISIONS.md#d-261)): sei **mazzetti di Tensioni**
   coperti, gettoni 0/1/2, la carta che si gira a due segnalini, rivelazione
   e secondo dibattito a fine Atto. La pista sente **~1.060 Risonanze in 100
   anni** dove il ponte ne portava 364. Il ponte sulle Tensioni resta finché
   le Domande vivono lì (punto 8): il giorno che cade, la riga da togliere è
   in `_resonance`.
6. **La Terra quasi non si scalda, e l'Antico peggio.** Col ponte: Terra 1,4%
   su 364. Con la pista (0.1.222): Terra **3,4%**, e **Antico 0,1%** — una
   Risonanza su 1.056: le sue Tensioni vivono di Drift e Consigli, non di
   carte. La Terra ha una Tensione sola dietro; le carte che la toccano
   muovono presenze invece di aprire questioni. Materia d'autore
   (ROADMAP §4.5), qui il numero da guardare.
   **Mezza cura in 0.1.227** ([D-265](DECISIONS.md#d-265)): la Tensione sola
   non è più sola — dieci per Tema, mazzetti mai vuoti sul tavolo pescato
   (0 su 600). Resta da misurare se le carte *scaldano* Terra e Antico più
   di prima: il mazzetto pieno dà loro domande, non ancora Calore.
7. ✅ **Dodici Destini su venti** non hanno ancora faccia fisica — fatta in
   0.1.232 ([D-270](DECISIONS.md#d-270)): **23 su 23** con Tema, segni
   osservati e tre righe leggibili, sei condivisi che coprono i sei Temi, e
   la sonda che dice per ognuno se giocare rende più che stare fermi (sul
   tavolo pescato: 21 su 22 sì; la coda è taratura d'autore, coi nomi).
8. **La Domanda sta sulla carta Tensione** (0.1.228,
   [D-266](DECISIONS.md#d-266), revoca del committente): le carte Domanda
   separate sono uscite dai dati — girata la Tensione sul Tema caldo, le sue
   domande legate ai segni del mondo sono lì (`possible_questions`, 60/60).
   Resta da **stampare** la faccia della Tensione con le sue domande, e resta
   la forma del dibattito da eseguire — proponente → opportunità e bonus,
   avversari → malus: è il Consiglio di PZ-5. Tre segni di memoria
   (`charter_temporary`, `crystal_measured`, `relic_recorded`) aspettano
   quella faccia, dichiarati con nota nel dizionario.

**Il prezzo pagato, dichiarato**: col tavolo uniforme l'anno peggiore dei cento
passa da **otto Consigli a nove**. Tre tentativi di riportarlo a otto non hanno
spostato il numero — il nove non viene da un caso limite, viene dal fatto che il
mondo adesso è più caldo. Le trentasei carte in più **non l'hanno peggiorato**:
resta nove, e a tavolo misto la forma dell'anno tiene a 3-8.

**Il rischio da nominare adesso**, prima che diventi lavoro buttato: due
grammatiche che non si toccano divergono. Oggi il ponte è un campo che il
validatore controlla; se le facce fisiche crescono e il motore non le esegue mai,
fra dieci carte saranno due giochi diversi con lo stesso nome.

**Fatto quando** una carta giocata nell'app esegue l'Azione scelta **e** la sua
Risonanza, e il Tema che ne esce è quello scritto sulla carta.

---

### 68. ✅ Otto turni su dieci non succede niente — **quattro e mezzo su dieci, e la voce si chiude**

`bilanciamento` · **misurata in 0.1.216** ([D-254](DECISIONS.md#d-254)) ·
**prima cura in 0.1.217** ([D-255](DECISIONS.md#d-255)) · **cura vera in
0.1.247** ([D-285](DECISIONS.md#d-285)) · **chiusa in 0.1.358**
([D-391](DECISIONS.md#d-391))

**Chiusa sulla condizione che si era scritta da sola**: *«i «passa» scendono
sotto la metà dei turni, e il playtest resta 0/8»*. Cento anni, seme 7000:
**47,6%** a tavolo misto (3.428 su 7.200) e **47,9%** a tavolo uniforme, con
**0 seggi bloccati su 8** su tutti e due i tavoli.

**Ed era già vera da cento versioni.** L'ultima riga qui sotto diceva *«Oggi
sono all'82,8%»* ed era ferma a 0.1.217; la strada scritta — *82,1% → 42,1% →
oggi* — confrontava misure prese su **anni diversi**, perché il 42,1% di D-285 è
di `CHR_01`, cancellato in D-317/D-318 con gli altri anni d'autore. Rimisurata
sull'anno che esiste, la curva è piatta: **47,6% in 0.1.260, 47,3% in 0.1.290,
46,7% prima di D-385, 47,6% oggi**. La voce non è rimasta aperta perché il
difetto tornava: è rimasta aperta perché **nessuno ha più riletto la sua
condizione**.

**Quello che resta ha un'altra voce.** L'**84,0%** dei «passa» è ancora
*«nessuna mossa gli serviva»* — 2.878 turni, il **40,0% di tutti i turni** — e
chi passa ha 22,1 mosse legali e 4,4 carte in mano. Non è il mazzo (10,3%: pesca
sbagliata) e non è la mappa (5,3%: bersaglio sbagliato): è la **ragione**, e la
ragione è una decisione del committente in [ISSUES 123](#123).

**Aggiornamento 0.1.247.** La causa non era il mazzo né le regole: il cervello
aveva le mosse e non aveva fame. Il ripiego «fai quello che la mano permette»
non veniva mai provato, e la lista delle mosse possibili guardava un solo verbo
per carta e un solo bersaglio per verbo. Adesso si passa il **42,1%** dei turni
invece dell'**82,1%**, il **55%** delle carte pescate si cala (era il 23,2%) e
**nessuna carta resta muta** in 100 anni (erano 3).

Resta aperta perché quattro turni su dieci sono ancora fermi: sono quelli in cui
la mano è **alla riserva** che il Consiglio richiede. Il prossimo numero da
guardare non è il passare — è **quanto rende un turno pieno**: 256 Verità
scritte contro le 295 di prima dicono che spendere sulla mappa toglie voce al
Consiglio, e quel cambio va tarato con il committente.

**Il testo originale:**

Il committente l'ha visto giocando: *«17 turni su 24 sono passa»*. Su 100 anni e
**7.200 turni** il numero è peggiore ancora, ed è lo stesso a tavolo misto e
uniforme.

| | passa |
|---|---|
| tavolo misto | **85,7%** (6.168 su 7.200) |
| tavolo uniforme | 84,8% |
| Atto 1 | 77,9% |
| Atto 2 | 88,9% |
| Atto 3 | **90,2%** |

**Due cause sono escluse, e non con un'impressione.**

| | |
|---|---|
| passa con **zero mosse legali** | **0 su 6.168** |
| mosse legali che aveva chi passava | **15,5 in media** |
| passa con la **mano vuota** | 12 su 6.168 (0,2%) |
| carte in mano di chi passava | **6,5 in media** |

Non è che il tavolo non lo lasci giocare, e non è che non abbia carte. **Ha
quindici mosse legali e sei carte in mano, e non fa niente.**

**Le tre cause vere:**

| | quota dei «passa» | cosa vuol dire |
|---|---|---|
| nessuna mossa gli serviva | **64,9%** | il gioco non gli dà una ragione per agire |
| voleva un verbo, in mano non ne aveva nessuna carta | 20,1% | problema di **pesca** |
| aveva il verbo in mano e non poteva usarlo lì | 14,8% | problema di **bersaglio** |

E il verbo che vuole quasi sempre è uno: **INFLUENZARE, 1.695 volte su 2.152
intenzioni mute (79%)**. Il cervello vuole scaldare una domanda e non ci riesce.

**Perché è la voce più grossa aperta.** ISSUES 59 (due verbi che nessuno gioca) e
ISSUES 60 (una domanda muta) sono **la stessa malattia vista da due lati**: non
mancano le carte né le regole, manca la ragione. E il 65% non si cura col mazzo.

**Deciso dall'autore**, e non è una delle due strade facili: né un costo per il
passare né un premio per il muovere, ma **obiettivi che chiedono più di quanto il
mondo dia da solo** ([D-255](DECISIONS.md#d-255)).

Prima di scriverli serviva un numero che nessuno aveva: **quanto rende giocare**.
`run_asking_probe.gd` gioca ogni anno **due volte con lo stesso seme** — una col
tavolo vero e una con un **tavolo di pietra** che non spende mai un'Occasione — e
conta gli obiettivi avverati dai due lati. La risposta, prima di toccare niente:

| 100 anni, tavolo misto | prima | dopo |
|---|---|---|
| obiettivi avverati **giocando** | 465 | 350 |
| obiettivi avverati **stando fermi** | **470** | 188 |
| quanto rende giocare | **−1,1%** | **+86,2%** |
| avverati che erano già veri all'apertura | 43,0% | **14,0%** |

**Il tavolo di pietra ne avverava più di quello che giocava.** Non che agire
rendesse poco: rendeva **meno di niente**, e il 43% dei punti era in cassaforte
prima che qualcuno posasse una pedina.

**E i «passa» si sono mossi:**

| | prima | dopo |
|---|---|---|
| turni «passa» | 85,7% | **82,8%** |
| «nessuna mossa gli serviva» | 64,9% | **58,7%** |
| Atto 1 | 77,9% | 72,6% |
| Atto 3 | 90,2% | 89,4% |

**Non basta, ed è scritto qui perché non basta.** Il 58,7% resta la fetta
maggiore, e le due che restano dopo di lei sono cresciute: le intenzioni che la
mano non sa dire passano da 2.152 a 2.422. È la faccia buona del difetto — il
cervello adesso **vuole** più spesso — ma dice anche dove finisce questa voce e
dove comincia la prossima: **il mazzo**. Il verbo muto è sempre INFLUENZARE.

**Fatto quando** i «passa» scendono sotto la metà dei turni, e il playtest resta
0/8. Oggi sono all'82,8%: la voce resta **aperta**.

*(Questa riga è quella che nessuno ha più riletto: da 0.1.247 la condizione era
soddisfatta, e il numero qui sopra era vecchio di trenta versioni. Lasciata
scritta perché si veda com'è successo.)*

---

### 67. La saga si ferma alla seconda partita

`difetto` · **aperta in 0.1.213** ([D-250](DECISIONS.md#d-250)) · **causa non
provata**

> «La saga si ferma alla seconda partita e non va avanti.»

**Escluso**: il motore. La catena `setup → inherit_from → run` gira pulita per
quattro Chronicle di fila, `library_sequel_of("CHR_02")` risponde sempre
`CHR_02`, e il libro della saga con due anni produce quattro pagine che si
disegnano tutte.

**Non riprodotto**: guidare la schermata vera in headless non ha funzionato — un
`Control` montato da riga di comando non fa girare il suo giro di scelte.

**Corretto lo stesso**: l'apertura dell'era successiva ignorava il fallimento di
`setup`, e un fallimento silenzioso ha la faccia di un blocco.

**Sospetto aperto**: il libro della **saga** compare solo da fine seconda partita
in poi, ed è esattamente il momento indicato. Prima di
[D-248](DECISIONS.md#d-248) rasterizzava una pagina da 54 MB: su un tablet una
texture oltre il tetto può portarsi via il contesto grafico invece di fallire in
silenzio.

**La domanda che chiude la voce**: a fine seconda partita l'offerta «Gioca l'era
successiva» **compare**? Se compare e toccarla non fa niente, il difetto è
nell'apertura dell'anno; se non compare, è prima.

**Fatto quando** una saga arriva almeno al terzo anno su un tablet.

---

### 66. ✅ La seconda saga non si raggiunge più — CHIUSA in 0.1.362: e' stata tolta

`contenuto` · **aperta in 0.1.212** ([D-245](DECISIONS.md#d-245)) ·
**chiusa in 0.1.362** ([D-394](DECISIONS.md#d-394))

> **La condizione era: «o CHR_03 si raggiunge, o e' stato tolto perche' non
> serviva». E' stato tolto.** Gli anni d'autore sono stati cancellati in
> [D-317](DECISIONS.md#d-317)/[D-318](DECISIONS.md#d-318): la scatola contiene
> **un anno solo, CHR_00**, e chiedere al motore un `CHR_03` risponde
> `Chronicle sconosciuta`. La voce e' rimasta aperta — e per un pezzo perfino
> **rossa, in attesa di una parola del committente** — quarantaquattro versioni
> dopo che la sua condizione era soddisfatta.

Il menu non chiede più da dove cominciare: si apre l'app e si gioca il primo
anno. Il prezzo è che **CHR_03 — anno 1640, le altre quattro case — non si apre
da nessuna parte.**

È contenuto scritto, validato e giocabile che nessuno può raggiungere: quello
che [D-035](DECISIONS.md#d-035) chiama contenuto che non esiste.

**Tre strade, e sono d'autore:**

1. **la seconda saga arriva giocando** — la si raggiunge dopo aver chiuso la
   prima, come l'era successiva arriva a fine Chronicle. È la più coerente con
   «l'app si apre e si gioca», e vuol dire scrivere la regola di quando;
2. **sta altrove** — dietro il pulsante che già esiste per riprendere una
   partita, o in una voce che non è una domanda all'apertura;
3. **non serve** — la si toglie, e la scatola ha una saga sola. Sono venti
   Destini e quattro case in meno, e va detto ad alta voce prima di farlo.

**Fatto quando** o CHR_03 si raggiunge, o è stato tolto perché non serviva.

---

### 65. Tutta la pagina dell'app va rivista

`ux` · voluta dal committente · **aperta in 0.1.211**

> «Tutta la pagina dell'app va rivista.»

Detto dopo aver giocato su un iPad, e dopo che sei difetti diversi erano stati
riparati uno per uno ([D-239](DECISIONS.md#d-239) → [D-244](DECISIONS.md#d-244)).
La frase non è una settima riparazione: è l'osservazione che le riparazioni non
bastano, ed è giusta.

**Quello che questo giro ha insegnato, e che vale come diagnosi.** I sei difetti
avevano tutti **la stessa forma**:

| | dove viveva il testo | chi non lo vedeva |
|---|---|---|
| la carta | tooltip del mouse | chiunque giochi col dito |
| i pezzi sulla mappa | solo per le Regioni raggiungibili | quasi sempre, e su un tablet mai |
| le due carte del Destino | in nessun posto | tutti |
| la traccia delle domande | diceva la regola di due versioni fa | tutti |
| il trascinamento | un gesto da mouse | chiunque su un touchscreen |
| il menu | offriva quattro anni di cui due non sono inizi | tutti |

Non sono sei sviste: sono **una pagina disegnata guardando uno schermo con un
mouse**, misurata solo da un cancello che gioca senza mani (§5ter).

**Cosa vuol dire «rivista», e va deciso prima di toccare altro.** Almeno tre
letture, e non sono la stessa cosa:

1. **una passata di leggibilità** — dimensioni, contrasto, bersagli grandi
   abbastanza per un dito, niente che viva in un tooltip. È quello che i sei
   fix hanno fatto a pezzi, e si può finire;
2. **un'altra disposizione** — oggi lo schermo è mappa al centro, colonna a
   destra, mano in basso, verbale a sinistra: quattro cose che si contendono un
   tablet in verticale. Forse su un tablet la pagina è **una alla volta**;
3. **un'altra idea di cosa si guarda** — al tavolo fisico guardi la mappa e
   prendi in mano le carte; l'app fa guardare *un cruscotto*. È la differenza
   fra un tavolo e un pannello di controllo, ed è quella che il committente
   nomina da sempre.

**Da misurare, e non c'era modo**: nessuna delle sonde toccava questa pagina.
Finché una persona con l'app in mano restava l'unico strumento, ogni giro
costava un suo pomeriggio — ed era successo tre volte di fila.

✅ **Lo strumento c'è, da 0.1.346** ([D-379](DECISIONS.md#d-379)):
[`MISURA_PAGINA.md`](MISURA_PAGINA.md), generata da `cli/run_page_survey.gd` e
sorvegliata da un cancello. Misura le quattro cose che i sei difetti del tablet
avevano in comune:

| | |
|---|---|
| **testi che vivono solo nel suggerimento del mouse** | **13** |
| **bersagli più stretti di un dito (44 px)** | **7 su 7** |
| parole tecniche sotto gli occhi | 1 |
| larghezza chiesta in fila, senza la mappa | **788 px** su un tablet da 768 |

E dichiara i tre posti dove non arriva: il **testo ricco** headless non si legge
(provato: zero da tutte e due le strade), due pannelli **dipingono invece di
costruire nodi** — la mappa e i mazzetti dei Temi, che quindi né questa sonda né
un lettore di schermo vedono — e la **cornice** coi bottoni degli strumenti
resta fuori perché nomina un autoload.

**La decisione resta questa voce.** La sonda non ripara niente e non sceglie
quale delle tre riviste si fa: ha solo tolto di mezzo la ragione per cui non si
poteva cominciare.

### ✅ La prima delle tre e' fatta, in 0.1.352 ([D-384](DECISIONS.md#d-384))

La **passata di leggibilita'** — quella che questa voce dichiara finibile — e'
finita, e si misura:

| | prima | dopo |
|---|---|---|
| **testi che vivono solo nel suggerimento del mouse** | **13** | **2** |
| **bersagli piu' stretti di un dito (44 px)** | **7 su 7** | **0** |

I due che restano sono il testo intero dei due Echi in mano: il **nome** adesso
e' stampato sul piede della carta, il resto no, perche' stamparlo vuol dire
allungare la carta — e quella e' la seconda rivista.

**Restano aperte la seconda e la terza, e sono scelte:**

- **l'impaginazione**: i pannelli che dichiarano una misura chiedono **788 px in
  fila** su un tablet da 768, e la mappa non e' nemmeno nel conto. *«Forse su un
  tablet la pagina e' una alla volta.»*
- **l'idea di cosa si guarda**: la mappa e i mazzetti dei Temi **dipingono
  invece di costruire nodi** — ne' la sonda ne' un lettore di schermo li vedono.
  Riscriverli e' una scelta su cosa la pagina *e'*, non una riparazione.

**Fatto quando** c'è una decisione scritta su *quale* delle tre riviste si sta
facendo, e la pagina la segue.

---

### 64. Una saga ricambia metà tavolo, e nessuno ha deciso che dovesse

`regole` · `da-decidere` · **misurata in 0.1.208** ([D-237](DECISIONS.md#d-237))

Trovata misurando [ISSUES 58](#58), e non la stavo cercando.

Una Chronicle pesca **quattro case su otto** (`entity_pool.count`), e ogni anno
della saga ripesca con un seme nuovo. Su 20 saghe da 10 Chronicle, **solo il
51% dei seggi seduti dopo l'apertura sono le case che hanno aperto la saga**.

**Perché conta.** L'idea di partenza dice *«i giocatori giocano entità che si
trasformano nel tempo»*: la casa cambia forma — Re, Reggenza, Restaurato — e
resta la stessa. Ricambiare metà tavolo a ogni era è una cosa diversa, e non è
scritto da nessuna parte che sia voluta: è quello che succede quando la sonda
delle ere chiama `seats_for` con un seme per anno.

Due letture, e non so quale sia quella giusta:

1. **è il tavolo che cambia**, e allora la saga è del *mondo* e non delle case —
   ma allora il punteggio di campagna sommato per casa (D-180) misura una cosa
   che si siede a intermittenza;
2. **è un artefatto della sonda**, e in una campagna vera i quattro seggi
   restano quelli — ma allora nessun codice lo garantisce, e la prima app che
   incatena due Chronicle ripescherà.

**Da misurare prima di decidere**: quante volte, su una saga di dieci anni, una
casa esce dal tavolo e ci rientra; e se il punteggio di campagna dei seggi
intermittenti sia leggibile accanto a quello dei continui.

**Fatto quando** c'è una regola scritta su chi siede l'anno prossimo — che sia
«gli stessi», «si ripesca» o «si ripesca ma chi c'era ha precedenza» — e la
sonda delle ere la applica invece di deciderla per conto proprio.

---

### 63. L'app non è un prototipo giocabile: è un'ispezione di stato con dei bottoni

`ux` · voluta dal committente · **misurata in 0.1.199** · primo passo fatto
([D-228](DECISIONS.md#d-228))

> «La GUI non è più gestibile con le nuove regole. Non ci sono carte chiare, non
> ci sono pedine che rappresentano edifici, condizioni, cicatrici e tutto quello
> che dovrebbe apparire in una copia fisica del gioco. L'app dovrebbe essere
> giocabile come un vero prototipo, con carte che spiegano esattamente cosa fanno
> e non tag o testi tecnici; la GUI deve prevedere movimenti drag & drop, non
> pulsanti che dicono cosa fare. Si seleziona una carta, si decide come usarla e
> si deve poter generare il suo effetto. Così com'è fatto è ingiocabile (lo è
> sempre stato).»

**Misurato, non supposto:**

| | |
|---|---|
| file in `godot/ui/` che implementano il drag & drop | **0 su 21** |
| come si sceglie un'azione | `Button.new()` da una lista di stringhe, si torna un indice |
| cosa si clicca sulla mappa | solo la Regione bersaglio di un MUOVERE **già scelto col bottone** |
| come la mappa disegna strutture, condizioni, cicatrici | **parole in grigio** sotto il nome della Regione |
| effetti di carta che stampavano il tipo grezzo | **28 su 49** |
| carte che dicevano il proprio verbo | **0 su 48** |

La ragione è strutturale, e ogni misura di questo ciclo la conferma dal suo lato:
**la GUI è stata costruita per far vedere che il motore funziona, non per farci
giocare.** Il cancello gioca solo con `PolicyDecider`, che non ha mani.

### Le quattro mosse

1. ✅ **La carta dice cosa fa** — [D-228](DECISIONS.md#d-228), 0.1.199. Il verbo
   sulla faccia (schermo e cartone), i segni con la loro parola, tre prove che lo
   tengono.
2. ✅ **I pezzi sulla mappa** — [D-229](DECISIONS.md#d-229), 0.1.200. Cinque
   famiglie di pietra, cinque forme; il grado sono i punti sotto il pezzo, il
   padrone e' il colore. La parola solo sotto il mouse. Tre prove, fra cui «un
   segno senza pezzo e' invisibile».
3. ✅ **Il drag & drop** — [D-230](DECISIONS.md#d-230),
   [D-231](DECISIONS.md#d-231) e [D-238](DECISIONS.md#d-238), 0.1.201–0.1.209.
   **Riaperto e richiuso**: il trascinamento c'era da 0.1.201, ma la colonna
   stampava comunque un bottone per ogni scelta, e da fuori lo schermo era
   identico a prima — *«sembra tutto uguale a prima»*, e lo era. Ora una scelta
   che ha un posto dove cadere **non è anche un bottone**, e il clic sulla carta
   è l'altra strada. Si prende una carta e la si
   lascia dove la si vuole usare: una **Regione** sulla mappa, una **domanda**
   sulla traccia, una **casa** nella colonna dei rapporti. Quando quella carta lì
   sa fare una cosa sola, posarla è già la mossa; quando ne sa fare due opposte,
   la caduta **restringe** e la scelta resta a chi gioca. Dieci prove, fra cui
   «ogni soggetto di cui una carta può parlare ha il suo posto».
4. ✅ **Il Consiglio giocabile** — [D-232](DECISIONS.md#d-232),
   [D-233](DECISIONS.md#d-233) e [D-236](DECISIONS.md#d-236), 0.1.203–0.1.207.
   **Sullo schermo è fatto**, e dal 0.1.207 anche *prima* che il Consiglio si
   apra: la scheda di una domanda si legge con un clic sulla sua riga. Una
   proposta arriva a chi sceglie dicendo *cosa lascia al mondo* — 43 su 43 ne
   lasciano qualcosa — e si legge come una carta, titolo sopra e lettera piccola
   sotto. Lo stesso per le clausole. Tre prove, una per ciascuno dei tre tratti
   (la riga, il disegno, il filo in mezzo). **Sul cartone no**: resta
   [ISSUES 62](#62), e la forma è una decisione d'autore.

**Da tenere presente mentre si costruisce:** niente di tutto questo lo copre il
cancello. Le regole restano verdi qualunque cosa succeda alla GUI, ed è
esattamente il buco di [D-224](DECISIONS.md#d-224). Ogni mossa porta la sua
misura, o non è fatta.

**Il quinto passo, che non era nel piano** — [D-239](DECISIONS.md#d-239),
[D-240](DECISIONS.md#d-240), [D-241](DECISIONS.md#d-241), 0.1.210. Le quattro
mosse erano scritte guardando uno schermo con un mouse. Provata su un iPad, la
stessa app: il trascinamento non esiste (il dito che preme e scorre fa scorrere
la pagina), i pezzi sulla mappa erano di 17 pixel e i loro nomi non comparivano
mai — si scrivevano solo per le Regioni *raggiungibili*, e fuori da una scelta
non lo è nessuna. **Il gesto ora è in due tempi**: si tocca la carta, si accende
dove può andare, si tocca il posto.

**Fatto quando** una persona può giocare un anno intero senza che nessuno le
spieghi cosa fanno i bottoni, perché non ci sono bottoni da spiegare.

---

### 62. ✅ Il Consiglio non si può giocare sul tavolo fisico — deciso in 0.1.207

**Deciso dal committente** ([D-236](DECISIONS.md#d-236)): *«per il momento
dobbiamo usare la versione digitale, poi penseremo alla versione fisica.»* È la
terza delle tre — **l'app resta l'arbitro** — con una scadenza aperta invece che
con una rinuncia, ed è registrata come dichiarazione reversibile: il giorno che
si torna al cartone il materiale c'è già
([CATALOGO_CONSIGLI.md](CATALOGO_CONSIGLI.md)).

**E la decisione ha portato lavoro invece di chiuderne.** Se lo schermo è il
tavolo, la scheda della domanda deve stare sullo schermo: da 0.1.207 un clic
sulla riga di una domanda la apre, e dice cosa si potrà proporre e cosa lascia
al mondo — *prima* che il Consiglio si apra, che è quando serve. Mettere le
clausole sotto gli occhi ha fatto emergere **diciannove segni del mondo senza
una parola** e quattro «scoperte» che uscivano col proprio id.

**Resta aperto, e va con la versione fisica**: la carta Domanda stampata porta
ancora la soglia che da [D-214](DECISIONS.md#d-214) non apre più niente. È
parcheggiata qui, non dimenticata.

<details>
<summary>La voce come era scritta</summary>

`ux` · `contenuto` · **misurata in 0.1.196** · il materiale è uscito dal
database in 0.1.203 ([D-232](DECISIONS.md#d-232))

Il committente l'ha vista arrivare da un'altra parte, ed è vera. Il materiale che
fa **la cosa centrale del gioco** non esiste come componente:

| | |
|---|---|
| template di Consiglio | 10 |
| proposte fra cui sceglie il proponente | 43 |
| clausole di condizione | 19 |
| conseguenze sul mondo | 52 |
| **fogli di stampa che ne portano una** | **0 su 39** |

L'export produce trentanove fogli — Asset, Echo, Domande, Destini, Casate,
Regioni, segnalini, tracce. La carta **Domanda** c'è, e porta titolo, velo,
dominio, cosa la fa salire e scendere, le famiglie che valgono. **Non porta le
proposte**, perché le proposte non stanno sulla domanda: stanno nei template di
Confluence, con variabili (`$rival`, `$region_focus`), condizioni di idoneità e
rimandi a `consequences/*.json`.

Quindi al tavolo fisico si vede la crisi e **non si può tenere il Consiglio**.
Serve l'app come arbitro, e il Consiglio — «la decisione», nelle parole del
committente — è l'unico pezzo che non è mai uscito dal database.

**E c'è un difetto dentro il difetto.** La carta Domanda stampata porta ancora
**la soglia**, in un cerchio grande all'angolo (`card_face.gd`, `face["corner"]`).
Da [D-214](DECISIONS.md#d-214) quel numero non apre più niente. È esattamente
l'errore che [D-224](DECISIONS.md#d-224) ha corretto sulla pagina d'aiuto, e che
il cancello del testo non poteva vedere perché **guarda lo schermo e non la
stampa**: nessuna misura copre quello che una persona **tiene in mano**.

**Da decidere prima di costruire**, ed è una scelta d'autore:

1. **scheda Consiglio per Tensione** — una scheda A5 o un tarocco grande per
   ogni template, con domanda, 3-4 proposte, le clausole e cosa lascia al mondo,
   in italiano da giocatore invece che in `SET_REGION_TAG`;
2. **libretto dei Consigli** — dieci pagine, meno componenti e più consultazione;
3. **l'app resta arbitro**, e si accetta che il gioco fisico sia ibrido.

Le prime due chiedono che le proposte diventino leggibili senza le variabili, il
che vuol dire riscrivere `$rival` e `$region_focus` in un modo che un umano
risolve al tavolo. Non è un lavoro di formattazione: è design.

**Fatto in 0.1.203 ([D-232](DECISIONS.md#d-232)): la parte che non era una
decisione.** Tutte e tre le forme chiedono lo stesso materiale a monte, e adesso
esiste — [CATALOGO_CONSIGLI.md](CATALOGO_CONSIGLI.md), 10 Consigli, 43 proposte,
19 clausole, con i buchi **spiegati** nel ruolo che avranno al tavolo invece che
riempiti con un valore che una scheda non può conoscere. È generato dai dati e
la CI lo confronta, quindi non può invecchiare in silenzio. Una prova ha trovato
subito una condizione che parlava al programmatore (*«...la carta di Propp e' la
porta (D-127)»*), ed è stata riscritta.

**E in 0.1.204 ([D-233](DECISIONS.md#d-233)) quel materiale è arrivato a chi
sceglie**, almeno sullo schermo: la proposta porta sotto di sé cosa lascia al
mondo, la clausola cosa scrive se qualificata. È la stessa sorgente della
scheda, con una voce diversa — al tavolo i buchi li riempie la partita.

Resta d'autore **quale delle tre**, e resta aperto il difetto della soglia sulla
carta Domanda stampata.

</details>

**Fatto quando** un tavolo può tenere un Consiglio intero senza aprire l'app,
oppure quando è scritto a verbale che non lo può fare e perché.

---

### 61. ✅ Dieci segni sul mondo che nessuno legge — erano sei, chiusa in 0.1.205

**Chiusa da [D-234](DECISIONS.md#d-234).** La voce chiedeva di misurare prima di
decidere, e la misura ha spostato la voce stessa: **quattro dei dieci non erano
mai stati muti.** Il registro non guardava tre penne che leggono — di quale
Regione parla il Consiglio (`focus_region_tags`), **chi siede l'anno prossimo**
(`entry_tag`), la catena delle ere (`if_tag`) — cioè i morsi più forti del gioco.
`condition:contested` (132 scritture in 100 anni) tira il Consiglio su di sé;
`heir_named` (98) è la porta di Aldric Restaurato.

I **sei** che restano sono dichiarati in `MUTI_NOTI` con la loro ragione **e la
loro frequenza**: `settlement:<casa>` 50, `water_rights` 18,
`succession_settled` 14, `account_settled` 4, `burden_shared` 2, `dragon_slain`
mai — e quest'ultimo è ISSUES 56 che parla, non questa voce.

**In più, il difetto specchio**: guardare dove il gioco legge ha fatto comparire
una **clausola impossibile** — la Successione preferiva `scar:burned` e nessuna
Regione poteva bruciare. Adesso preferisce `scar:the_empty_chair`, e
`build_sign_registry.py --check` va rosso se ne ricompare una.

**Resta d'autore**, e non è una correzione: far mordere `water_rights` o
`succession_settled` è contenuto nuovo.

<details>
<summary>La voce come era scritta</summary>

`contenuto` · `regole` · **misurata in 0.1.195** ([D-225](DECISIONS.md#d-225))

Il registro dei segni ([REGISTRO_SEGNI.md](REGISTRO_SEGNI.md)) conta **71 segni
scritti sul mondo**; **10 non li legge niente**:

| segno | chi lo scrive |
|---|---|
| `dragon_slain` | «Il Drago Abbattuto» |
| `heir_named` | una Conseguenza e una carta |
| `succession_settled`, `account_settled`, `burden_shared`, `water_rights` | Conseguenze |
| `condition:lean`, `condition:contested`, `condition:requisitioned` | Conseguenze e carte |
| `settlement:$proponent` | una Conseguenza — si stampa e basta |

Ognuno è una carta o una Conseguenza che **promette un cambiamento che il gioco
non registra**. Un giocatore legge «il Drago è abbattuto», lo vede scritto nella
Cronaca, e non cambia niente: non una regola del segno, non un obiettivo, non la
pesca delle domande dell'anno dopo.

**Tre rimedi diversi, e vanno scelti uno per uno.** Non è detto che la risposta
sia sempre la stessa:

1. **farlo mordere** — una regola del segno (come `condition:starving`, che
   toglie una carta di mano, vieta FORGE e peggiora i Consigli sulla Carestia),
   una clausola di obiettivo, o un `echoes` nella pesca delle domande;
2. **toglierlo**, se la Conseguenza racconta già abbastanza senza;
3. **lasciarlo dichiarato**, se serve solo al libro della Cronaca — ma allora va
   scritto perché, e sta in `MUTI_NOTI`.

`condition:lean` è il caso più chiaro: lo posa l'Eco dell'interramento sulla
Valle Verde insieme a `TEN_WATER +1` e all'abbattimento del canale. Due dei tre
effetti mordono; il terzo è muto, e il giocatore non ha modo di saperlo.

**Da misurare prima di decidere**: per ognuno dei dieci, quante volte esce in
100 anni. Un segno muto che compare due volte in un secolo è un problema minore
di uno che compare duecento.

**Fatto quando** ogni segno scritto sul mondo o morde, o è stato tolto, o è
dichiarato con la sua ragione — e `build_sign_registry.py --check` resta verde
da solo.

</details>

---

### 58. ✅ Gli obiettivi coperti si pescano ogni anno, non a inizio saga — chiusa in 0.1.208

**Chiusa da [D-237](DECISIONS.md#d-237).** I tre coperti si pescano una volta
per saga (`objectives.drawn: per_saga`) e poi si ereditano.

**Il costo che questa voce temeva non si verifica.** All'anno 10 i tre
d'apertura si avverano **più** spesso che ripescandoli (23,8% → 34,5%), e quelli
mai avverati in tutta la saga scendono dal 51% al 43%; i livelli non si spostano.
La ragione è strutturale: nessuno dei quindici obiettivi condivisi nomina una
Regione o una casa ([D-221](DECISIONS.md#d-221)). Delle due strade che questa
voce offriva — obiettivi universali **oppure** una regola di sostituzione — il
gioco aveva già preso la prima senza saperlo; mancava che qualcosa la tenesse, e
adesso c'è una prova.

**Resta aperto quello che la misura ha trovato per strada**: [ISSUES 64](#64) —
una saga ricambia metà tavolo, e gli obiettivi di saga valgono quindi per circa
metà dei seggi.

<details>
<summary>La voce come era scritta</summary>

`regole` · `da-misurare` · voluta dal committente · **trovata nel confronto con
l'idea di partenza** (*VISIONE*)

> «Ogni entità ha un obiettivo palese e tre segreti che si pescano **all'inizio
> della saga**.»

`WorldStateFactory._deal_objectives` gira dentro il setup **di ogni Chronicle**:
i tre coperti si ripescano ogni anno.

Metà del modello c'è già — il **palese** attraversa gli anni con la regola di
[D-081](DECISIONS.md#d-081), *chi ha ottenuto quello che voleva ne vuole un
altro, chi non l'ha ottenuto riprova* — ma i tre coperti no.

**Perché non è un dettaglio.** Sposta l'unità dell'ambizione dalla **saga**
all'**anno**. Con obiettivi di saga, al terzo anno stai costruendo verso qualcosa
che nessuno ha visto, e una mossa che sembra sbagliata oggi può essere il quarto
passo di un piano di otto. Con obiettivi d'anno ogni Chronicle è un contenitore
chiuso, e la campagna è **una somma di partite invece di una storia sola**.

**Da misurare prima di decidere**, perché la mossa ovvia ha due costi leggibili:

- un obiettivo pescato a inizio saga può risultare **impossibile** nel mondo che
  la Chronicle 4 ha prodotto — un obiettivo che nomina una Regione svuotata, o
  una casa che non si siede più. Servono obiettivi che valgano in qualunque
  mondo (i quindici condivisi lo sono già, D-221) **o** una regola di
  sostituzione dichiarata;
- il conteggio a fine anno (`objectives_met` → `saga_points`) presuppone che
  l'obiettivo sia dell'anno. Con obiettivi di saga i punti si contano **una volta
  sola alla fine**, e la curva della campagna cambia forma.

Da misurare: su dieci Chronicle, quanti obiettivi pescati a inizio saga
resterebbero **raggiungibili** all'anno 5 e all'anno 10, e quanti si spengono per
sempre.

**Fatto quando** i tre coperti si pescano una volta per saga, nessuno di loro può
diventare impossibile senza una regola scritta che lo sostituisca, e il playtest
resta **0/8**.

</details>

---

### 57. ✅ La GUI raccontava il gioco di due versioni fa — chiusa in 0.1.192

`ux` · `debito` · voluta dal committente · **chiusa** ([D-224](DECISIONS.md#d-224))

> «La GUI dell'App è corretta? Dovrebbe essere allineata con le nuove regole.»

No. La pagina d'aiuto diceva **cinque cose false** e la riga sopra le scelte una
sesta, tutte nate da regole cambiate fra 0.1.185 e 0.1.191. Chiusa scrivendo
prima la misura — `test_the_page_says_only_what_the_data_says` — e poi il testo
che la rende verde.

**Quello che resta aperto da qui**, e che non è un difetto ma un debito:

- **La suite conta i test che fa partire, non quelli che arrivano in fondo.** Il
  cancello ora va rosso su `SCRIPT ERROR`, che prende il caso in cui una funzione
  muore a metà. Non prende il caso in cui una prova **non asserisce niente**: un
  test vuoto, o uno che esce presto per un `return` legittimo, resta invisibile.
  Un conto delle asserzioni per prova, con un pavimento, lo prenderebbe.
- **`docs/MECCANICA.md` porta la stessa bugia**, corretta qui solo dove era
  falsa in modo netto (la Deriva a orologio, che `replaces_drift` ha spento). Il
  documento dichiara in testa che i suoi numeri sono di 0.1.149 con quattro
  sezioni ristampate fino a 0.1.160: **non è stato ri-derivato da allora**, e
  rileggerlo per intero contro i dati è un ciclo suo, non una riga.
- **Le altre sedici viste non parlano di regole**, quindi non possono sfasarsi —
  ma nessuna di loro è disegnata da una prova. `game_screen.gd` non lo era fino a
  oggi, ed è lì che stava la sesta bugia. Non sappiamo se le altre siano corrette:
  sappiamo che **nessuno le ha misurate**.

**Fatto quando** ogni vista che stampa prosa la stampa da una dichiarazione, e
ogni vista è disegnata almeno una volta da una prova.

---

### 56. Tre Conseguenze su cinquantadue non escono mai — erano dieci

`contenuto` · `bilanciamento` · **rimisurata in 0.1.206**
([D-235](DECISIONS.md#d-235)) · **da dieci a tre**

> **Avanzamento in 0.1.369** ([D-401](DECISIONS.md#d-401)): **le orfane sono
> zero**, ed erano quattro. Tre hanno trovato casa in
> [D-397](DECISIONS.md#d-397); la quarta — `CNS_VALLEY_DRAINED` — **non era
> orfana: era la sonda a non vedere i sacchetti.**
>
> `run_consequence_probe` cercava chi elenca una Conseguenza guardando **solo le
> proposte**, e i `consequence_pools` del template — il costo, il fallimento, il
> premio di chi decide — non li guardava. Chiamava «orfana» una Conseguenza che
> il Consiglio pesca **quando la proposta cade**, che e' l'opposto di orfana.
> Quinta volta in questo progetto che uno zero era la sonda.
>
> **E il fallimento dell'Acqua adesso dice qualcosa di suo.** Portava
> `CNS_FAILURE_ABANDONED`, l'abbandono generico che sta gia' su altri due
> Consigli; adesso porta *«La Valle che si Vuota — l'acqua non e' arrivata, e i
> campi hanno risposto a modo loro»*, che e' scritta apposta per lui. La scheda
> stampa **una riga sola** sotto «se cade» — lo tiene una prova — quindi e' uno
> scambio, non un'aggiunta.
>
> Restano **11 su 65**, e adesso ognuna ha un verdetto che non mente: quattro
> hanno la domanda che non arriva mai al tavolo, tre sono sempre perdenti, due
> non sono idonee, una non e' mai scelta, e una sta in un sacchetto che non si e'
> mai svuotato.

**Il numero di prima era misurato male, e in due modi.** Quattro delle dieci non
passano da un Consiglio: arrivano da una **carta Echo**, e una Conseguenza
scattata da una carta non compare in `confluence_results`. E il resto era
misurato su **anni scollegati**, mentre tre proposte chiedono una *leggenda* —
che nasce solo quando fra due anni giocati passano decenni. Cento anni giocati
uno per volta non ne producono nessuna: quelle proposte erano morte per
costruzione della misura.

| | Conseguenze mai uscite |
|---|---|
| 200 anni **scollegati** | 7 su 52 |
| 200 anni **in saga** (20 × 10 Chronicle) | **3 su 52** |

**Le tre che restano, con tre cause diverse:**

| Conseguenza | perché | rimedio possibile |
|---|---|---|
| `CNS_DRAGON_SLAIN` | la sua domanda è arrivata **19 volte** e la proposta è stata esclusa tutte e 19: chiede `function:REVELATION`, e in tutto il mazzo **una sola carta** lo scrive — deve essere calata nello stesso anno, prima del Consiglio del Risveglio | una seconda porta, o una Rivelazione più probabile |
| `CNS_HARVEST_RETURNS` | la carta è stata **pescata 173 volte e calata zero**: toglie la fame e raffredda la Carestia, cioè fa bene **al mondo** e a chi la cala niente | una ragione per giocarla |
| `CNS_OATH_BROKEN` | **pescata 183 volte, calata zero**: cicatrice, inquietudine e il proprio rapporto chiuso a HOSTILE — chi la gioca paga tre volte e non incassa mai | idem |

**Le prime due categorie della voce originale sono vuote.** «Mai scelta» e
«sempre perdente» non esistono più in saga: ogni proposta che arriva sul tavolo
prima o poi viene presa, e presa prima o poi passa. Ne è comparsa una che la
voce non prevedeva, perché non guardava le carte: **la carta che nessuno ha una
ragione di giocare**.

**Resta d'autore** e non è una correzione: dare una ragione per calare quelle
due carte, o far incontrare più spesso la Rivelazione e il Risveglio.

**Fatto quando** ogni Conseguenza del catalogo esce almeno una volta su 200 anni
di saga, o è stata tolta perché non serviva.

<details>
<summary>La voce come era scritta, misurata in 0.1.191</summary>

`contenuto` · `bilanciamento` · **misurata in 0.1.191** ([D-223](DECISIONS.md#d-223))

Trovata cercando perché le Conseguenze che spostano pedine non muovevano la
mappa. Non era quello che facevano: era **quante volte venivano fuori**.

Su **931 Consigli in 200 anni** (le due linee, 100 semi ciascuna), **42
Conseguenze su 52** escono almeno una volta. Le altre **dieci non escono mai**:

| | |
|---|---|
| `CNS_DRAGON_SLAIN` | «Il Drago Abbattuto» |
| `CNS_CROWN_REUNITED` | «La Corona Riunita» |
| `CNS_OATH_BROKEN` | «Il Giuramento Rotto» |
| `CNS_HARVEST_RETURNS` | «Il Raccolto che Torna» |
| `CNS_CAPITAL_TAKEN` | «La Capitale Presa» |
| `CNS_EXODUS` | «L'Esodo» |
| `CNS_LEDGER_OPENED`, `CNS_ACCOUNT_SETTLED`, `CNS_LEGEND_RETOLD`, `CNS_MINE_REOPENED` | |

Sono i nomi grossi del catalogo: il drago che muore, la corona che si ricompone,
il giuramento che si rompe. **Contenuto scritto con cura che nessuno vede mai**,
e che nessuna misura aveva mai contato — le sonde guardano cosa succede, non
cosa *non* succede.

**Perché conta più di quanto sembri.** Una Conseguenza esce se una proposizione
la elenca e quella proposizione viene scelta e passa. Dieci che non escono
significano che alcune proposizioni sono irraggiungibili, e allora il problema
non è il catalogo: è **quali domande arrivano al tavolo e cosa si può proporre
quando ci arrivano**. È la stessa forma di ISSUES 53 (RIVENDICARE forza un
Consiglio che poi non si apre).

**Da misurare prima di decidere**: per ognuna delle dieci, se la proposizione che
la elenca sia mai stata scelta, e se no perché — non idonea, mai proposta, o
sempre perdente. Sono tre difetti diversi con tre rimedi diversi.

**Fatto quando** ogni Conseguenza del catalogo esce almeno una volta su 200 anni,
o è stata tolta perché non serviva.

</details>

---

### 55. ✅ Il ciclo del gioco è rotto in tre punti — chiusa in 0.1.198 per tre quarti

**Chiusa da [D-227](DECISIONS.md#d-227)** sui primi tre criteri; il quarto — gli
obiettivi contesi — resta ed è contenuto d'autore (3 su 15).

| criterio scritto in questa voce | com'era | adesso | |
|---|---|---|---|
| una presenza in più dà carte in più | — | 3,50 → **4,14** al rifornimento | ✅ |
| Regioni contese a fine anno > 3 su 6 | 2,46 | **3,72** | ✅ |
| il padrone cambia mano più di prima | 2,39 | **2,85** | ✅ |
| playtest 0 su 8 | 0/8 | **0/8** | ✅ |
| obiettivi contesi ≥ un terzo del mazzo | 1 su 15 | **3 su 15** | ❌ |

**La risposta non era dove l'abbiamo cercata per due cicli.** Il tetto delle
pedine da 4 a 5: la contesa sale del **51%**, e il ricambio del padrone tocca il
suo massimo (a 6 pedine *scende*, perché tutti trincerati dappertutto rendono una
maggioranza più difficile da sfilare).

Erano **due domande dietro la stessa parola**. «La mappa è ferma» voleva dire due
cose: *il padrone cambia poco* — e lì eravamo già all'84% del massimo che le
regole permettono — e *poche Regioni sono contese*, che era a metà strada e si è
mosso con una pedina.

---



`regole` · `bilanciamento` · voluta dal committente · **misurata in 0.1.187**

> «Dobbiamo fare in modo che la cosa sia più "mossa": costruire porta vantaggi,
> avere maggioranza dà vantaggi (ricorda che peschi una carta per ogni presenza
> che hai a inizio atto), spostarsi conviene quindi. Modificare la mappa dovrebbe
> essere la priorità del gioco e una maggioranza dovrebbe essere una lotta tra
> entità. Le domande dovrebbero smuovere la partita e anche gli obiettivi
> dovrebbero incrociarsi per dare battaglia tra entità.»

Il ciclo che il committente descrive — **presenza → carte → azioni → più mappa →
più carte** — esiste nel dato ma è tagliato. `run_contest_probe` lo misura per la
prima volta, su 100 partite a tavolo misto.

### 1. ✅ Spostarsi costa e non rende — CHIUSA in 0.1.364: la quarta pedina paga, da D-220

> **La voce diceva: «oltre tre pedine, una presenza in piu' vale zero», e «chi
> si espande a cinque finisce con meno carte di chi resta a quattro».** Era vero,
> e [D-220](DECISIONS.md#d-220) l'ha misurato meglio di questa voce: con quattro
> pedine si pescava **3,30** carte e con cinque **3,12** — non piatto,
> **invertito**.
>
> La cura e' la stessa della [3](#3): `hand_refill.per_control`. La quarta pedina
> non paga di piu' per il tetto della pesca — quello resta a 6 — ma paga se
> **prende una Regione**, perche' il possesso da' una carta **e alza il tetto
> sulla mano**. Con quattro pedine si pesca **3,52** invece di 3,30, e la curva
> non e' piu' invertita.
>
> Oggi il segnale sulla mappa e' molto piu' forte di allora: il padrone passa di
> mano **3,87** volte l'anno contro 2,32.
>
> **Il testo originale:**

Il rifornimento è `presenze × 2`, con un **tetto a 6**. Le pedine arrivano a 4.

| pedine sul tavolo | carte che spettano | carte in mano a fine anno |
|---|---|---|
| 2 | 4 | — |
| **3** | **6 (tetto)** | 4,80 |
| **4** | **6 (tetto)** | 4,99 |
| 5 | 6 (tetto) | **4,46** |

**Oltre tre pedine, una presenza in più vale zero** — e la quarta pedina di
[D-211](DECISIONS.md#d-211) non paga niente. Chi si espande a cinque finisce con
**meno** carte di chi resta a quattro, perché ha speso i MUOVERE per arrivarci.

### 2. ✅ La maggioranza non è una lotta — CHIUSA in 0.1.364: 3,57 Regioni contese su 6

> **La condizione che questa voce e la [4](#4) si erano scritte** — *«le Regioni
> contese sono piu' di tre su sei a fine anno, e il padrone cambia mano piu' di
> quanto non cambi oggi»* — **e' soddisfatta, e con margine.** Cento semi,
> `cli/run_contest_probe.gd`:
>
> | | allora | **oggi** |
> |---|---|---|
> | Regioni con dentro piu' di una casa, a fine anno | 2,60 su 6 | **3,57 su 6** |
> | il padrone cambia mano | 2,32 volte l'anno | **3,87** |
> | Regioni con un padrone a fine anno | 4,65 su 6 | **5,20** |
>
> Le Regioni con una casa sola dentro sono passate da tre e mezzo a **due e
> mezzo**: la maggioranza e' una lotta piu' spesso che una proprieta'. E non e'
> merito di una decisione sola — `per_control` ([D-220](DECISIONS.md#d-220)), il
> padrone che si conta invece di scriversi ([D-158](DECISIONS.md#d-158)) e i
> varchi ([D-393](DECISIONS.md#d-393)) hanno spinto tutti nello stesso verso.
>
> **Il testo originale:**

| su 6 Regioni | |
|---|---|
| con dentro **più di una casa**, all'apertura | 2,41 |
| con dentro più di una casa, a fine anno | **2,60** |
| il padrone cambia mano | **2,32 volte l'anno** |

**Tre Regioni e mezzo su sei hanno una casa sola dentro**: non sono maggioranze,
sono proprietà. E il tavolo non si stringe in nove round.

### 3. ✅ Tenere non paga più che stare — CHIUSA in 0.1.364: `per_control` c'e' da D-220

> **Curata in 0.1.189 da [D-220](DECISIONS.md#d-220), e mai chiusa.**
> `hand_refill` di CHR_00 oggi porta **`per_control: 1`**: tenere una Regione da'
> una carta in piu' **e alza di uno il tetto sulla mano** — che e' la meta' che
> conta, perche' senza quello chiunque converge alla stessa mano piena e il
> possesso non si vedrebbe. Il codice sta in `_refill_hands`, e il commento cita
> questa voce parola per parola.
>
> **E il numero si e' mosso ancora dopo.** D-220 dichiarava un effetto piccolo;
> oggi, cento semi:
>
> | | ISSUES 3 | D-220 | **oggi** |
> |---|---|---|---|
> | il padrone passa di mano | 2,32 | 2,42 | **3,87** |
> | Regioni contese a fine anno | 2,60 su 6 | 2,66 | **3,57** |
> | Regioni con un padrone | 4,65 su 6 | 4,73 | **5,20** |
>
> **Il testo originale:**

Una struttura pesa nel conteggio del controllo e **basta**. `hand_refill` conta le
**presenze**, non il possesso: il controllo di una Regione non dà carte, non dà
azioni, non dà niente che si veda al tavolo.

### 4. Gli obiettivi non si incrociano: uno su dodici

| | |
|---|---|
| **conteso** (due case non possono averlo entrambe) | **1** — «Due Terre, una Voce» |
| globali (stesso esito per tutti) | 2 |
| **solitari** (ognuno conta roba sua) | **9** |

E le Conseguenze toccano la mappa nel 48% dei casi, ma **`ADD_PRESENCE` compare
una volta sola** in cinquantadue: i Consigli cacciano e assegnano, non mandano
nessuno da nessuna parte.

### La radice, trovata dopo (0.1.192)

Le quattro mosse qui sotto attaccano il problema **dal lato dell'offerta**: più
Conseguenze che spostano pedine, più carte che costruiscono, più obiettivi
contesi. [D-222](DECISIONS.md#d-222) e [D-223](DECISIONS.md#d-223) le hanno
provate e misurate, e hanno mosso poco: il padrone cambia mano 2,32 → 2,49 volte
l'anno.

**Correzione (0.1.196).** La prima stesura di questa sezione diceva che al
Consiglio entrano «solo le carte». **Era sbagliata sul meccanismo.** Nel conto ci
sono già i **legami** (`alliance_weight`, [D-139](DECISIONS.md#d-139), dichiarato
in tutte e quattro le Chronicle), diciassette regole `COUNCIL_MODIFIER` che
spostano il **Fattore Mondo** — tre cicatrici, la Regione affamata, la fama, e
`settlement:city`, cioè una pietra alzata a città — e due `STANCE_MODIFIER` sulle
incarnazioni.

Resta vero il conto sulle proposte: su **43 proposizioni** in dieci template ci
sono **10 condizioni di idoneità in tutto**, quindi trentatré su quarantatré sono
ammissibili comunque sia messa la mappa.

**Quello che manca è un pezzo preciso: il titolo e la maggioranza nella Regione
di cui si discute** — ed è precisamente quello che il committente chiede.

**E la leva esiste già, spenta.** `confluence_rules.focus_weight`
([D-154](DECISIONS.md#d-154)): al Consiglio la Regione a fuoco dà voce a chi la
**tiene** e a chi ci sta **in forze**. È scritta, la reggono sette test, e
**nessuna delle quattro Chronicle spedite la dichiara** — e una dichiarazione
vuota vuol dire assenza.

**Perché fu spenta, e perché quel motivo non vale più.** Misurata a 0.1.119: i
Consigli falliti 177 → 175, ma il playtest passava da **0/8 a 1/8**, e il seggio
che si rompeva era sempre lo stesso, Kessa dei Fuochi. D-154 concluse che non era
il peso della terra: era che **la Vittoria di Kessa aveva una porta sola**
(`control_count >= 2`, ISSUES 38), e scrisse *«ISSUES 38 viene prima: fino a che
resta aperta, qualunque modifica alle regole del Consiglio ha una probabilità
alta di essere respinta da Kessa e non dal proprio merito».*

**ISSUES 38 è chiusa da 0.1.122**, e da [D-198](DECISIONS.md#d-198) i tre gradini
sono diventati quattro obiettivi, tre dei quali pescati. La Vittoria di Kessa
oggi ha tre clausole, non una. **Il motivo per cui la leva è spenta ha smesso di
valere settantadue versioni fa, e nessuno l'ha riaccesa.**

**La mossa 0 è stata fatta, e la misura l'ha respinta** ([D-226](DECISIONS.md#d-226),
0.1.197). `focus_weight` riaccesa passa il cancello — **0/8 su tutti e due i
tavoli**, quindi D-154 aveva ragione: era la porta sola di Kessa, non il peso
della terra. Ma sulla cosa per cui serviva:

| | il padrone passa di mano |
|---|---|
| spenta (com'è spedita) | **2,39** volte l'anno |
| titolo +1, maggioranza +1 | **2,29** |
| solo maggioranza +1 | **2,37** |

**Peggiora o non cambia niente.** La prima forma peggiora per il motivo scritto
qui sopra come rischio: dare voce a chi la Regione **la tiene** rende più
difficile toglierargliela.

### E allora il presupposto era sbagliato

`_recount_control`: **il padrone di una Regione lo decide la contesa di presenza,
round per round, non il Consiglio.** `rightful_holder` riconta il titolo dalle
pedine; i `SET_CONTROL` scritti a mano sono quattordici su cinquantadue e
arrivano dopo.

Quindi «la mappa non si muove al Consiglio» è vero e non è un difetto: **al
Consiglio non si è mai mossa.** Si muove con le pedine, e MUOVERE è già l'azione
più giocata del mazzo (38%).

**La domanda giusta, che non è ancora stata posta:** con quattro pedine a testa,
quattro case, sei Regioni e il titolo che segue la maggioranza stretta, **quante
volte al massimo potrebbe passare di mano in un anno?** Se il tetto teorico è
vicino a 2,4, la mappa si muove già quanto le regole permettono, e questa issue
va riscritta: la leva non è il Consiglio, sono le pedine, le Regioni, o la regola
del titolo.

**Il prossimo passo è quel tetto**, e si misura prima di disegnare qualunque cosa.

### Le quattro mosse, in ordine di radice

1. **Il ciclo economico.** Il tetto delle carte sale a `pedine × 2` vere, e **il
   controllo di una Regione paga**. Senza questa, le altre tre non hanno con cosa
   combattersi.
2. **Costruire diventa una scelta reale**: più carte con un mestiere di pietra,
   non una sola ([D-218](DECISIONS.md#d-218) ne ha data una).
3. **Obiettivi contesi**: carte che due case non possono prendere entrambe.
4. **Le domande spostano la mappa**: Conseguenze che *mettono* pedine.

**Fatto quando** una presenza in più dà carte in più fino al tetto delle pedine,
le Regioni contese sono più di tre su sei a fine anno, il padrone cambia mano più
di quanto non cambi oggi, e gli obiettivi contesi sono almeno un terzo del mazzo
— col playtest ancora **0/8**.

---

## Provate le prime due mosse, e la causa era un'altra (0.1.189)

### Il preventivo della mossa 1 era sbagliato ([D-220](DECISIONS.md#d-220))

Il collo di bottiglia **non è** il tetto per Atto. Alzato `cap` da 6 a 8 non
cambia niente: le carte pescate a ogni rifornimento restano 3,3–3,4 per chiunque.
Il tetto vero è quello sulla **mano** — tutti convergono alla stessa mano piena,
e la presenza decide solo quanto in fretta.

**E la sonda aveva sbagliato la domanda due volte**, cambiando conclusione ogni
volta. La coppia giusta — con quante pedine si è pescato quanto, ricostruita dal
registro in ordine — dice una cosa peggiore di «piatto»:

| pedine al rifornimento | carte pescate |
|---|---|
| 3 | **3,44** |
| 4 | 3,30 |
| 5 | **3,12** |

**Invertito.** Spedito `per_control` (tenere una Regione dà una carta e alza il
tetto): il padrone passa di mano **2,32 → 2,42** volte l'anno. Piccolo.

### La mossa 3 è spedita e non ha mosso niente ([D-221](DECISIONS.md#d-221))

`leads_in` — «più di chiunque altro» — e tre obiettivi nuovi: i contesi passano
da **1 a 4** su 15. Si avverano fra lo 0% e il 46,2%, e una prova dimostra che li
prende **un seggio alla volta**. La mappa: **2,42 → 2,42**.

### La causa vera, e sta in una riga

```
grep -c "objective" godot/scripts/seat/policy_decider.gd   →   0
```

**Il cervello che gioca il cancello non legge gli obiettivi. Mai.** Insegue le
condizioni del **Destino** — le tre strade — mentre da
[D-198](DECISIONS.md#d-198) la vittoria si conta **contando quattro obiettivi**.

> Chi gioca insegue una cosa, e il punteggio ne conta un'altra.

**Cosa vuol dire per quello che è già scritto**: ogni misura sugli obiettivi —
il libro mastro compreso, quindi anche i numeri di
[ISSUES 52](#52-lyra-non-ha-mai-trionfato-in-centoventi-anni) — dice *cosa
capita* a un seggio che non li persegue, non quanto siano difficili da
perseguire. Restano vere come descrizione di ciò che il cancello misura oggi; non
dicono quanto valga un obiettivo per una persona che lo vuole.

**Quindi l'ordine delle mosse cambia, e la mossa 0 è nuova:**

0. **Il cervello insegue quello per cui si vince.** Finché non lo fa, ogni leva
   su obiettivi e mappa si misura contro un giocatore che non la sta usando —
   e le due mosse già spedite lo dimostrano.

È anche il cambio più costoso: **muove ogni numero di ogni verbale che nomini gli
obiettivi**, e va deciso apposta invece che di sfuggita dentro un'altra voce.

---

## La mossa 0 è spedita, e la mappa non si è mossa lo stesso (0.1.190, [D-222](DECISIONS.md#d-222))

Il cervello adesso legge gli obiettivi che ha in mano, in **un solo punto** —
`_conditions()`, che ha nove chiamanti — e li insegue in ogni scelta.

| 100 semi, cambia solo questa riga | prima | dopo |
|---|---|---|
| **obiettivi presi in tutto** | 397 | **446** |
| anni chiusi con quattro su quattro | 2 | **7** |
| «Due Terre, una Voce» (conteso) | 32,1% | **39,5%** |
| NONE, tavolo misto | 93 | **80** |
| VITTORIE, tavolo misto | 147 | **175** |
| TRIONFI, tavolo misto | 4 | **7** |
| **il padrone passa di mano** | **2,42** | **2,49** |
| Regioni contese a fine anno | 2,66 su 6 | 2,62 su 6 |

**Un cervello che insegue quello per cui si vince, vince di più.** Ma le due
righe in fondo sono quelle che contano per questa voce, e **non si sono mosse**.

### Quindi la causa è un'altra ancora, e adesso è isolata

Il cervello *vorrebbe* la mappa — «Due Terre, una Voce» sale di sette punti — ma
**non ha con cosa prenderla**:

- **MUOVERE si gioca 3,79 volte l'anno** e le pedine sono **quattro**: finite
  quelle, l'unico modo di crescere è togliere una pedina da dove si è già;
- **`ADD_PRESENCE` compare una volta sola** in cinquantadue Conseguenze: un
  Consiglio caccia e assegna, non manda nessuno da nessuna parte;
- **costruire non è una scelta**: una carta sola su 48 lo permette, e infatti
  «Più Pietra di Tutti» non si muove di un punto (19,8% prima e dopo).

Non è più una questione di *volere*: è che **il gioco non offre abbastanza modi
di andare da qualche parte**. Le mosse 2 e 4 del piano qui sopra sono adesso le
uniche rimaste, e in quest'ordine:

1. **Le domande spostano la mappa** — Conseguenze che *mettono* pedine, non solo
   che le tolgono. È la più economica: è contenuto, non regole.
2. **Costruire diventa una scelta reale** — più carte con un mestiere di pietra.

**Fatto quando** le Regioni contese a fine anno sono più di tre su sei e il
padrone cambia mano più di tre volte l'anno, col playtest ancora **0/8**.

---

## Provata anche la mossa «le domande spostano la mappa», e respinta (0.1.191, [D-223](DECISIONS.md#d-223))

Cinque Conseguenze hanno avuto un `ADD_PRESENCE`, ognuna con la ragione già
scritta nel proprio testo. Tre forme diverse, **lo stesso numero**, e tutte
peggiori del punto di partenza:

| il padrone passa di mano | |
|---|---|
| prima | **2,49 volte l'anno** |
| tutte e cinque | 2,39 |
| solo le tre migrazioni | 2,39 |
| migrazioni mandate dove sta il rivale | 2,39 |

**Il perché sta in un numero che non avevo mai guardato**: quelle Conseguenze
escono **21 volte in 100 anni** su ~470 Consigli — il 4,5% — e due di loro **mai**.
Non è che spostare la gente non funziona: è che l'Effetto era su carte che non si
giocano. E allargando il conto, **dieci Conseguenze su 52 non escono mai**: è
[ISSUES 56](#56-dieci-conseguenze-su-cinquantadue-non-escono-mai).

**Quindi questa voce ha esaurito le sue mosse** senza risolvere la domanda che
l'ha aperta. Restano tre fatti, e tutti e tre puntano altrove:

1. il cervello **vuole** la mappa e non ha con cosa prenderla (MUOVERE 3,79
   volte l'anno, quattro pedine);
2. il Consiglio **potrebbe** spostare gente ma le carte che lo fanno non escono;
3. costruire non è una scelta: una carta su 48.

La mappa non è ferma per una regola sbagliata. È ferma perché **il gioco offre
pochi modi di andare da qualche parte, e quelli che offre escono di rado**.

---

### 53. ✅ RIVENDICARE può forzare un Consiglio che poi non si apre — CHIUSA in 0.1.355 ([D-389](DECISIONS.md#d-389))

`regole` · `difetto` · **misurata in 0.1.183** ([D-214](DECISIONS.md#d-214)) ·
**cura in 0.1.223** ([D-261](DECISIONS.md#d-261))

> **Fatto in 0.1.223: la strada presa è una terza**, dettata dal committente.
> Il diritto guadagnato col RIVENDICARE non insegue più la questione nominata:
> a fine Atto apre **il secondo mazzetto più alto**, scendendo di Tema in Tema
> finché trova una carta che si apre, e la questione nominata resta solo come
> ripiego. Si spegne — con una riga che lo dice — solo se **niente** al tavolo
> può aprirsi. Le 43 aperture rifiutate su 100 anni vanno **rimisurate** sotto
> la regola nuova prima di chiudere la voce; la seconda metà dell'azione (la
> controproposta sulla Tensione in dibattito) è registrata in D-261 e aspetta
> la revisione del Consiglio (PZ-5).

Trovata misurando il Consiglio di fine Atto: su cento anni ci sono **43 aperture
rifiutate**, e adesso che la chiusura d'Atto sceglie con `can_open()` sono
**tutte** Consigli forzati da RIVENDICARE.

Il Claim non passa da quella prova. Un seggio può quindi:

1. spendere un'azione per creare un Claim,
2. spendere una seconda azione per forzare il Consiglio,
3. e vedersi rifiutare l'apertura perché nessun quesito del template è idoneo —
   la Tensione non è abbastanza alta, o il mondo non porta il segno che serve.

**Due azioni su diciotto, e in cambio una riga di log.** È il difetto peggiore
di tutti quelli aperti, perché non è uno squilibrio: è un'azione legale che non
fa niente e non avvisa.

**È preesistente**, non l'ha introdotto D-214: prima si nascondeva perché quasi
tutti i Consigli si aprivano a soglia, e a soglia i quesiti sono quasi sempre
idonei. La chiusura d'Atto l'ha isolato.

**Le due strade:**

1. **RIVENDICARE non si può creare su una domanda che non ha un quesito idoneo**
   — la prova esiste già, si tratta di chiamarla anche lì. Il rischio è che una
   casa impari a leggere il rifiuto e ne deduca informazione privata.
2. **Il Claim forzato non si consuma se il Consiglio non si apre** — l'azione
   torna disponibile. Più semplice, e non dice niente a nessuno.

**Fatto quando** nessuna apertura viene rifiutata su 100 anni, o quando un
rifiuto non costa niente a chi l'ha chiesto.

### Rimisurata e chiusa in 0.1.355 ([D-389](DECISIONS.md#d-389))

[D-261](DECISIONS.md#d-261) aveva cambiato la regola e lasciato scritto che le
43 aperture rifiutate andavano rimisurate sotto quella nuova. Rimisurate, su 100
partite:

| il diritto del RIVENDICARE, dove va a finire | |
|---|---|
| apre un secondo dibattito | 15 |
| speso in controproposta | 59 |
| **si spegne senza trovare niente** | **0** |

**Zero**, e i tre numeri chiudono il conto: 15 + 59 + 0 = 74, esattamente i
Consigli strappati. Il «fatto quando» è soddisfatto.

**E per strada la sonda ha confessato un conto sbagliato**: dichiarava 12
Consigli strappati contro i 74 che questi numeri chiedevano, perché contava gli
Effetti `CONSUME_CLAIM` — e chi strappa un Consiglio su una domanda già matura
non ne emette nessuno (D-191). Continua in [ISSUES 126](#126).

---

### 101. ✅ `structure:road` — CHIUSA in 0.1.363: non ha piu' lettori

`dati` · `grammatica-fisica` · `piccola` · aperta in 0.1.297
([D-334](DECISIONS.md#d-334)) · **chiusa in 0.1.363**
([D-395](DECISIONS.md#d-395))

> **La condizione era: «`structure:road` ha una penna, oppure non ha piu'
> lettori».** Non ce l'ha: nel catalogo non c'e' una Pietra che si chiami strada,
> e dargliene una voleva dire disegnare una Pietra nuova — cioe' aprire lavoro,
> che e' quello che questo giro non fa.
>
> Quindi ha perso i lettori, tutti e tre, e la voce e' uscita dal dizionario
> (174 → 173 segni):
>
> | chi lo leggeva | cosa e' successo |
> |---|---|
> | `AST_WEALTH_TOLL`, fra cinque bersagli | tolto: la carta ne ha ancora quattro, e il testo non dice piu' «o #strada» |
> | il Tema **Vie**, fra nove segni | tolto: ne ha ancora otto |
> | il profilo delle **Custodi della Cenere**, che la volevano | **spostato su `structure:tollgate`** — *«una sbarra sulla via che esce dalla miniera: il carico passa di li', e chi tiene la sbarra tiene il mestiere»* |
>
> L'ultima riga e' quella che conta: la Cenere voleva una cosa che il mondo non
> sa costruire — una **porta murata**. Adesso vuole una cosa che il mondo posa 39
> volte in cento partite, e che **anche il Banco del Sale vuole**: una casa in
> piu' con cui litigare.

Tolta la mano invisibile del motore, trentotto segni su trentotto hanno trovato
il pezzo di cartone che li posa. **Trentasette.** Il trentottesimo e'
`structure:road`, e non lo scrive nessuno: fra le dieci Pietre del catalogo non
ce n'e' una che si chiami «strada».

Eppure il segno e' guardato da tre parti:

- un **Tema** lo elenca fra i suoi segni;
- una **carta** lo nomina nel suo bersaglio a segni;
- il **profilo strategico** di una casa dice di volerlo.

Cioe': una casa desidera una cosa che non puo' esistere, e una carta cerca una
Regione che non ci sara' mai. Al tavolo e' peggio che nel codice — un giocatore
legge «la Regione con la strada» e gira la mappa cercandola.

**Le due strade, e sono davvero due:**

1. **Una Pietra `STR_ROAD`**, con i suoi gradi e la sua rovina (`La Via
   Dimenticata` esiste gia' come rovina del Passo: il nome e' preso). La strada
   diventa una cosa che si costruisce, e i tre lettori hanno senso.
2. **Via il segno e i suoi tre lettori.** Se la strada non e' una Pietra, il
   Tema non deve elencarla, la carta deve puntare altrove e il profilo deve
   volere altro.

Non la decido io: e' contenuto, ed e' del committente. Finche' non e' decisa la
voce del dizionario porta `written_by: []`, che nel dizionario e' il modo di
dire ad alta voce *«questo segno non lo scrive nessuno»*.

**Fatto quando** `structure:road` ha una penna, oppure non ha piu' lettori.

---

### 102. ✅ `MISURA_SEGNI` conta due categorie su cinque, e non vede niente di quello che posa una Pietra — chiusa in 0.1.319

`strumenti` · `misura` · aperta in 0.1.299 · **riparazioni 1 e 2 in 0.1.316** ([D-352](DECISIONS.md#d-352)) · **terza in 0.1.319** ([D-355](DECISIONS.md#d-355)) · **chiusa**

> **E la terza.** «Clausole» e «lettori» adesso sono due colonne diverse. Il
> documento dichiarava muti **venti** segni; muti davvero ne sono **quattro**, e
> sono i quattro che `REGISTRO_SEGNI` gia' dichiarava con la loro ragione. Fra i
> sedici sbagliati c'era `condition:guarded`, che da D-353 vieta di tramare.
>
> I lettori arrivano dal `read_by` del dizionario, che il controllo 4 di
> `validate_physical` tiene allineato ai dati nei due versi: appoggiarsi a una
> lista gia' sorvegliata invece di scrivere un terzo censimento.

> **Fatte le prime due.** `cli/run_table_marks_probe.gd` guarda tutti e 180 i
> segni con un posto sul tavolo, e vede quello che posa una Pietra: la prova
> d'accettazione scritta qui sotto e' superata — 1062 Pietre alzate, 1195 segni
> di Pietra contati (le 1062 piu' 133 cambi di grado). **Prima erano sette.**
> Il documento e' [MISURA_TAVOLO.md](MISURA_TAVOLO.md), col suo cancello.
>
> **Resta la terza:** separare «clausole» da «lettori». La sonda nuova dice *chi
> arriva sul tavolo*, non *chi lo guarda*: per quello serve ancora contare le
> regole del segno, le facce delle carte, i Consigli e le Tensioni, che oggi
> nessuna delle due colonne vede.

Il committente, guardando il grafo dei segni: *«non e' possibile che scritto e
clausole siano cosi' poche»*. Aveva ragione, e non era il grafo: e' la misura.

`docs/MISURA_SEGNI.md` e' il documento che dice **quali segni il mondo scrive
davvero e chi li guarda**. Ha **tre punti ciechi**, e due dei tre non sono
dichiarati da nessuna parte.

#### 1. Guarda due categorie su cinque — questo e' dichiarato

`run_world_marks_probe.gd` conta solo `MEMORY` e `STATE`:

> *«Solo i segni che al tavolo si posano [...]. Fuori restano FUNCTION, ENTITY e
> PLACE, che sono contabilita' del motore.»*

Sono **138 segni su 204** che non hanno un numero. La ragione scritta reggeva
quando `PLACE` voleva dire «il posto e basta». Non regge piu': `place:forest`,
`place:dry_spring`, `structure:granary`, `settlement:city` sono **la mappa che
cambia**, e la mappa che cambia e' il gioco.

#### 2. Non vede **niente** di quello che posa una Pietra — questo non e' dichiarato

`effect_applier._build_structure` scrive il segno del grado con
`_apply_grade_tag`, **dentro** l'effetto `BUILD_STRUCTURE`: non emette un
`SET_REGION_TAG`. Il commento accanto lo dice — *«l'oggetto e' la verita', il tag
e' derivato»* — ed e' una scelta giusta per il motore. Ma la sonda conta gli
**effetti di segno**, quindi di tutto quello che una Pietra posa non vede niente.

Misurato sugli stessi vent'anni: **214 Pietre alzate**, e nel conto dei segni ne
risultano **sette**. Non e' un'approssimazione, e' cecita'.

Vale anche per i **cambi di grado**: su 100 partite le Pietre salgono di grado
**142 volte**, e nessuna di quelle 142 lascia un segno che la misura sappia
contare.

#### 3. «temuto» e «voluto» sono solo Destini e obiettivi — nemmeno questo e' dichiarato

Le due colonne delle clausole leggono `data.destinies` e `data.objectives`. Una
**regola del segno**, la **faccia di una carta**, un **Consiglio** o una
**Tensione** che guardano quel segno non contano. Nel grafo si vede a occhio:
righe con cinque lettori dichiarati e «clausole 0» accanto.

#### Perche' conta

Non e' un difetto estetico di un documento. `MISURA_SEGNI` e' uno dei due elenchi
che la roadmap usa per decidere **cosa e' colore e cosa e' regola** — i «segni
scritti spesso che nessuna clausola nomina» e i «nominati che non escono mai».
Con questi tre buchi, quell'elenco:

- non puo' dire niente su 138 segni su 204;
- dichiara «mai scritti» segni che il mondo posa mille volte;
- dichiara «senza clausole» segni che quattro pezzi diversi leggono.

Un documento che non fallisce e racconta il mondo sbagliato: e' la stessa forma
di D-329, D-333 e D-334, la terza volta in una settimana.

#### Le tre riparazioni, in ordine di peso

1. **Il segno della Pietra deve passare da un effetto**, o la sonda deve leggere
   anche i `BUILD_STRUCTURE` e i cambi di grado. La seconda e' piu' piccola e non
   tocca l'effect-sourcing; la prima e' piu' pulita e va discussa, perche' cambia
   cosa finisce nel verbale.
2. **Allargare le categorie**, o dire nel documento — riga per riga, non in
   premessa — quali segni non sono misurati. Oggi un trattino e uno zero si
   leggono uguali.
3. **Separare «clausole» da «lettori».** Contare le clausole di punteggio e' una
   cosa; dire chi guarda un segno e' un'altra, e servono tutt'e due.

**Fatto quando** ogni voce del dizionario ha un numero o una riga che dice
perche' non ce l'ha, e il conto dei segni di Pietra combacia con le Pietre alzate.

---

---

## Come si aprono



---

### 103. ✅ `REVISIONE_TESTI` non contiene le 841 caselle di costo e beneficio

`strumenti` · `misura` · aperta in 0.1.305 · **chiusa in 0.1.306**
([D-341](DECISIONS.md#d-341))

> **Chiusa.** Le 841 caselle entrano nel documento, ognuna col suo id —
> `TEN_FAMINE, se cade — F_CONDITION` — insieme alle 288 stringhe della faccia
> Asset entrate in D-340. `REVISIONE_TESTI` cresce di 3.635 righe, e le
> sessantacinque caselle riscritte in D-341 si rileggono con una riga.
>
> **Quello che la voce chiedeva in piu' resta aperto**: il «fatto quando»
> parlava di *una prova che parte dai dati* e prende ogni stringa stampabile su
> una faccia. Le due sezioni sono state aggiunte a mano, e un blocco nuovo
> domani sarebbe di nuovo fuori senza che niente fallisca. E' la stessa forma di
> `components_survey` in D-338, ed e' **ISSUES 105**.

`docs/REVISIONE_TESTI.md` dice di se' stesso: *«ogni testo che un giocatore puo'
leggere, nell'ordine in cui lo incontra, con il suo identificativo»*. E' il
documento con cui il committente corregge un testo scrivendo una riga.

Raccoglieva `title` e `rules_text` e lasciava fuori **il blocco fisico intero**:

| | testi | non c'erano |
|---|---|---|
| faccia fisica delle carte Asset | 288 | **287** |
| caselle di costo e beneficio delle Tensioni | 841 | **841** |

La meta' delle Asset e' riparata in [D-340](DECISIONS.md#d-340): 288 testi
entrano, ognuno col suo id — `AST_FORCE_LEVY, azione 2`. **Le 841 caselle delle
Tensioni restano fuori**, e sono precisamente quelle che un giocatore legge
mentre decide cosa proporre e in che moneta pagare: *«Al luogo si aggiunge
#razionato»*, *«Accetta 1 Cicatrice permanente»*.

#### Perche' il cancello non se ne accorge

`build_review.py --check` confronta il documento con quello che il **generatore**
produce, non il generatore con quello che il **gioco** stampa. Finche' nessuno
aggiunge una sezione, un documento che ne manca mille resta verde.

E' la stessa forma di D-329, D-333, D-334, D-336 e D-338: la **sesta** volta che
un documento generato non fallisce e racconta il mondo sbagliato. La riparazione
di classe non e' aggiungere una sezione alla volta — e' **una prova che parte
dai dati** e chiede che ogni stringa che una faccia di `CardFace` puo' stampare
compaia nel documento, cosi' che un blocco nuovo sia coperto il giorno che entra.

**Fatto quando** nessuna stringa stampabile su una faccia manca dal documento, e
lo tiene una prova che pianta un blocco nuovo e la vede cadere.

---

### 104. ✅ Tre proposte su quarantanove fanno la stessa identica cosa — CHIUSA in 0.1.365

`contenuto` · `consigli` · aperta in 0.1.306

> **La condizione era: «due proposte della stessa scheda non hanno mai la stessa
> catena di effetti, e lo tiene una prova che pianta un doppione».** Tutt'e due
> le meta' sono fatte.
>
> **Le tre gemelle sono diventate tre strade diverse**, e la differenza non e'
> una parola: e' un Effetto in piu' che il mondo vede. E ognuna e' andata a
> prendersi una **Conseguenza orfana** — una di quelle che nessuna proposta
> elencava e che quindi non uscivano mai:
>
> | Consiglio | la gemella | cosa le e' stato dato | perche' |
> |---|---|---|---|
> | La Carestia | `P_LAND_TO_WORKERS` | `CNS_COST_EMPTIED` — *«Chi puo', se ne va»* | ridistribuire la terra caccia chi la teneva: una presenza se ne va davvero |
> | L'Acqua | `P_WATER_COMMON` | `CNS_COST_DEBT` — *«Il Debito Contratto»* | dichiarare l'acqua di tutti vuol dire che qualcun altro paga il canale |
> | La Carta | `P_DRAW_LOTS` | `CNS_FAILURE_CONTESTED` — *«Resta Conteso»* | tirare a sorte scrive la regola e non mette d'accordo nessuno |
>
> **E le Conseguenze orfane passano da quattro a una** (resta
> `CNS_VALLEY_DRAINED`), e quelle che non escono mai da 12 a 11: un pezzo della
> [56](#56) chiuso senza toccarla.
>
> **La guardia c'e', ed e' la 43esima di `validate_physical.py`**: dentro un
> Consiglio, due proposte non possono applicare la stessa catena di Effetti. La
> regola esisteva per le due liste della carta Tensione — *«due pedine che fanno
> la stessa cosa non sono una scelta»* — e non era mai stata portata sui
> Consigli. Il difetto piantato **si fabbrica** invece di cercarne uno gia'
> rotto: copia la catena della prima proposta sulla seconda.
>
> **Cancello: 0 seggi bloccati su 8** sui due tavoli, dopo il cambio.


Misurate le 49 proposte dei 12 Consigli contro la **catena di effetti** che
applicano davvero — non contro la frase: **tre ripetono una proposta gia'
presente sulla stessa scheda**, parole diverse ed effetto identico.

| Consiglio | domande | proposte | catene diverse |
|---|---|---|---|
| La Carestia | 2 | 4 | **3** |
| L'Acqua | 2 | 3 | **2** |
| La Carta | 2 | 4 | **3** |

Su La Carestia le due gemelle sono *«Chi propone apra la Regione a chi giunge da
levante»* e *«La terra appartenga a chi la lavora»*: due frasi che al voto
sembrano due strade e sono la stessa. **La prosa lo nascondeva** — e finche' le
proposte erano stampate sulla scheda, il difetto arrivava fino al tavolo.

Da [D-341](DECISIONS.md#d-341) le proposte non sono piu' su una faccia stampata,
quindi il difetto e' **solo digitale**: nell'app, due opzioni di voto che portano
allo stesso mondo. Non e' stato riparato qui perche' cambiare a cosa punta una
proposta cambia il gioco, e va misurato sui 100 semi.

**Nessun cancello lo sorveglia.** Il validatore controlla che le carte Tensione
non abbiano scelte finte; questa regola non e' mai stata portata sui Consigli.

**Fatto quando** due proposte della stessa scheda non hanno mai la stessa catena
di effetti, e lo tiene una prova che pianta un doppione.

---

### 105. ✅ Le sezioni di `REVISIONE_TESTI` si aggiungono a mano — CHIUSA in 0.1.366

`strumenti` · `misura` · aperta in 0.1.306

> **La condizione era: «una prova parte dai dati e chiede che ogni testo
> compaia nel documento; e la prova pianta un blocco nuovo e la vede cadere».**
> Tutt'e due le meta' sono fatte, e il controllo va **dall'altra parte**.
>
> Adesso `build_review.py` guarda **ogni stringa dei dati che somigli a una
> frase** — uno spazio e almeno quattordici lettere, cosi' gli id e i segni
> restano fuori da soli — e pretende che o stia nel documento, o che la sua
> strada sia dichiarata con la ragione scritta. **Un blocco nuovo che nessuno
> dichiara fa fallire il cancello**, che e' il verso giusto: si e' costretti a
> decidere se si legge o no.
>
> **Girata la prima volta ne mancavano 1.730 in 58 strade.** Il documento
> passa da **3.111 a 4.136 testi**, e queste sono le sezioni che non c'erano:
>
> | cosa mancava | quante |
> |---|---|
> | la riga d'apertura di ogni Tensione, letta ad alta voce | 60 |
> | cosa scalda e cosa raffredda una questione | 239 |
> | le caselle **SI ACCENDE QUANDO** | 66 |
> | il nome stampato di ogni segno, con le sue forme divergenti | 109 |
> | le clausole annidate dei Destini e degli Obiettivi | 88 |
> | la faccia fisica del Destino — le tre righe che il tarocco stampa | 69 |
> | **PRENDI**, su tutte e 48 le carte Asset | 48 |
> | le Pietre: nome, descrizione, i gradi e la rovina | 52 |
> | le schede del Consiglio che il template porta ancora | ~200 |
> | i Temi, le regole dei segni, il segreto di una Regione | 63 |
>
> **E 746 stringhe sono dichiarate come cose che nessuno legge**, ognuna con la
> sua riga: le note d'autore agli implementatori, la matrice del disegno, il
> prompt di chi disegna un gettone, e la grammatica con cui il motore compone i
> nomi. Nessuna terza via.
>
> **Il buco che resta, dichiarato**: il controllo guarda i diciassette tipi di
> documento che conosce. Se ne arriva uno nuovo e nessuno lo aggiunge a
> `DOCUMENTI`, quel documento non e' guardato.


`build_review.py` compone il documento **sezione per sezione, scritte a mano**.
Ha funzionato finche' i blocchi di testo erano quelli del 2024; poi sono
arrivati il blocco `physical` delle carte Asset (288 stringhe) e le caselle delle
Tensioni (841), e il documento che dice *«ogni testo che un giocatore puo'
leggere»* ne mancava **1.128** senza fallire. Aggiunte in
[D-340](DECISIONS.md#d-340) e [D-341](DECISIONS.md#d-341), a mano tutte e due.

Il cancello confronta il documento con quello che il **generatore** produce, non
il generatore con quello che il **gioco** stampa: un blocco nuovo domani e'
fuori, in silenzio.

E' la stessa forma di `components_survey.py` in [D-338](DECISIONS.md#d-338), che
costruiva la tabella dei mazzi da righe scritte a mano e non si accorse di un
mazzo nuovo. E la stessa di D-329, D-333, D-334 e D-336.

**Fatto quando** una prova parte dai dati — ogni stringa che una faccia di
`CardFace` puo' stampare, piu' i blocchi che lo schema dichiara come testo da
giocatore — e chiede che compaia nel documento; e la prova pianta un blocco nuovo
e la vede cadere.


---

### 106. «La sceglie chi propone»: la pedina non porta con sé il nome della domanda

`regole` · `motore` · aperta in 0.1.308

Il committente, sulla casella che muove una domanda: **«la sceglie chi
propone»** — non la domanda stampata sulla scheda dall'autore, ma quella che il
proponente indica col dito, fra i segnalini che stanno tutti sul tavolo.

In 0.1.308 ([D-343](DECISIONS.md#d-343)) la casella e' scritta e muove **la
domanda di cui si sta discutendo**. E' quello che copre 59 delle 90
applicazioni; le altre 31 nominano un'altra domanda, e quelle non si possono
ancora fare.

#### Perche' non e' stato fatto subito

Perche' non e' una riga: **una pedina posata si identifica col solo id della
voce**, per tutta la lunghezza della catena.

| dove | cosa cambia |
|---|---|
| `set_benefits(chosen)` / `place_costs` | accettano id; devono accettare anche «questa voce, su questa domanda» |
| `current["benefits"]` | quello che si salva, e quindi il verbale |
| `CouncilEconomy.effects_for` | legge la domanda scelta invece di quella in discussione |
| `PolicyDecider` | deve **sapere quale domanda conviene muovere**: e' equilibrio, non plumbing |
| `SeatDecider` (hotseat) | una seconda domanda a chi gioca: «quale?» |
| `confluence_board` | la pedina si posa su due cose, non su una |

Il pezzo che pesa e' il quarto: un cervello che sceglie quale domanda alzare o
abbassare cambia il gioco, e va misurato sui 100 semi come tutto il resto.

#### Perche' conta comunque

Oggi la casella e' comprata **una volta su settantadue**
(`cli/run_boxes_probe.gd`). Una parte della ragione e' che muove solo la domanda
in discussione: e' il beneficio meno interessante che si possa offrire. La
scelta libera e' anche la cosa che potrebbe renderla viva.

**Fatto quando** un proponente puo' posare la pedina su una domanda che nomina,
il verbale dice quale, e la sonda delle caselle mostra se la casella smette di
essere quella che nessuno compra.


---

### 107. ✅ Una carta Eco non ha una scelta: e' un evento che decidi di far accadere — CHIUSA in 0.1.328

`regole` · `direzione` · aperta in 0.1.310

Chiarendo cosa sono le carte Eco per il committente
([D-345](DECISIONS.md#d-345)) la differenza con le carte Azione e' venuta fuori
netta, e con lei una domanda che nessuno aveva posto.

| | carta **Azione** | carta **Eco** |
|---|---|---|
| scegli il bersaglio | **si** | **no** |
| scegli cosa fa | **si**, fra due Azioni | **no** |
| Risonanza | sempre | mai |

Una carta Eco si cala e succede. Il posto lo decide `card_bindings`, che prende
la Regione a fuoco della domanda che la carta nomina; le due Azioni non ci sono;
la Risonanza nemmeno. **L'unica scelta e' quando calarla.**

#### Chiusa: [D-362](DECISIONS.md#d-362) — **no, e va bene cosi'**

Scelta del committente: *«l'eco non ha bisogno di scegliere un bersaglio se non
serve»*. Un'Azione e' una **mossa** — scegli dove e come — mentre un Eco e' un
**fatto che decidi di far accadere**, e un fatto non si punta col dito.

E la scelta c'e' lo stesso, solo che sta un gradino piu' su. Da
[D-359](DECISIONS.md#d-359) l'Eco e' il terzo blocco della carta Asset, accanto
alle sue due Azioni: la domanda che il giocatore si fa e' **«questa carta la
spendo per un'Azione, o per il suo Eco?»**. Le condizioni piu' strette sono il
prezzo di quella potenza, e sono stampate sulla faccia.

Nota: la tabella qui sopra diceva «con quale delle due che hai in mano» — la
mano del Narratore non esiste piu' da D-359, e la riga e' stata corretta.

#### Perche' e' una domanda e non un difetto

Puo' essere giusto: una funzione di Propp e' una cosa che **succede al mondo**,
non una mossa. La carta e' il momento in cui un giocatore decide che quella cosa
succede adesso, e questo e' gia' un potere.

Ma la domanda di casa — *«questa cosa esisterebbe e sarebbe comprensibile sul
tavolo fisico?»* — su una carta senza scelta ha una risposta scomoda: **al
tavolo si cala e si legge cosa e' successo**. Quando questa voce fu scritta,
sedici carte su trentanove non avevano nemmeno una condizione stampata, quindi
si calavano quando si voleva.

> **Rimisurato in 0.1.336: sono cinque su quarantotto.** Gli Echi sono
> quarantotto da [D-359](DECISIONS.md#d-359) — uno per carta Asset — e
> [D-362](DECISIONS.md#d-362) li ha accesi sui segni del mondo invece che sulla
> lotteria del limite di Tensione. Restano senza nessuna condizione stampata
> `ECH_CARAVAN_LOST`, `ECH_OFFER`, `ECH_PARLEY`, `ECH_PETITION`,
> `ECH_SACRIFICE`.

#### Le tre strade, e nessuna e' misurata

1. **Resta com'e'**, e la si dichiara: l'Eco e' l'orologio del mondo in mano ai
   giocatori, e il suo peso e' il tempismo.
2. **Le si da' un bersaglio**, come alle Azioni: chi la cala sceglie dove cade,
   fra i luoghi coi segni che la carta nomina. E' la grammatica di D-262, gia'
   costruita.
3. **Le si danno due strade**, come alle Azioni: la stessa funzione di Propp con
   due esiti fra cui scegliere.

**Fatto quando** il committente sceglie, e la scelta e' misurata sui 100 semi.


### 108. ✅ Vaerax ha un Destino murato a tutti e tre i passi — CHIUSA in 0.1.371: il muro e' caduto in 0.1.347

`regole` · `bilanciamento` · aperta in 0.1.311 ([D-346](DECISIONS.md#d-346)) · **strada 2 provata e ritirata in 0.1.315** ([D-348](DECISIONS.md#d-348))

> **La condizione era: «`mine_sealed` esce almeno una volta su 100 partite».**
> Ne esce **tredici**, e sta sul tavolo a fine partita in **dodici** su cento
> ([MISURA_TAVOLO.md](MISURA_TAVOLO.md)). `mountain_forgotten`, il terzo anello
> della catena e la porta d'ingresso della Leggenda, ne esce **una**.
>
> **E [MISURA_SEGNI.md](MISURA_SEGNI.md) non elenca piu' nessuna porta murata**:
> *«tutto quello che un passo chiede, il mondo lo scrive almeno una volta»*. Le
> quattro clausole che questa voce nominava — la Vittoria di `DST_VAERAX`, e
> tutt'e tre i passi di `DST_VAERAX_LEGEND` — non sono piu' impossibili.
>
> **E nessuna delle tre strade e' stata percorsa.** Il muro e' caduto da solo:
> il documento dei segni, che sta nei cancelli e si rigenera a ogni cambio,
> porta la data —
>
> | versione | `mine_sealed` scritto |
> |---|---|
> | fino a 0.1.346 | **0** |
> | 0.1.347 ([#166](https://github.com/Tannoiser2/ECHOES/pull/166), D-372…D-380) | **2** |
> | 0.1.353 ([#168](https://github.com/Tannoiser2/ECHOES/pull/168), D-382…D-387) | **13** |
> | 0.1.370 ([D-402](DECISIONS.md#d-402)) | **13** |
>
> — cioe' e' aperta da **ventiquattro versioni**. Il blocco che l'ha aperta e'
> quello che ha rimesso in piedi il Consiglio (i Temi con una carta sola, le
> caselle, i gettoni di rivendicazione): la catena
> `TEN_AWAKENING → Q_AWAKENING_CRYSTAL → P_SEAL_MINE → CNS_MINE_SEALED` ha
> ricominciato a passare quando il Consiglio ha ricominciato ad aprirsi.
> **Non so dire quale delle nove decisioni**, e non lo scrivo per non inventarlo:
> so le due finestre, e sono scritte qui.


> **Stato: aperta.** La strada 2 e' stata scritta, misurata e tolta. Il segno
> usciva (3 volte su 100 anni contro 0), ma la proposta nuova faceva cadere
> `test_claim_policy.test_the_natural_proponent_does_not_claim`. Prima di
> riprovarla serve capire perche' aggiungere una proposta a una casella cambia
> quale dominio una casa rivendica — probabilmente serve una condizione di
> eleggibilita' che chiuda quella via a chi e' gia' proponente naturale altrove.

Separando le due liste di `MISURA_SEGNI` sono venute fuori **quattro clausole
che nessuno puo' avverare**, e sono tutte della stessa casa.

| passo | chiede | prima | dopo strada 2 |
|---|---|---|---|
| `DST_VAERAX` · **VITTORIA** | `mine_sealed` | **0** | **3 volte** ✓ |
| `DST_VAERAX_LEGEND` · **SOGLIA** | `mountain_forgotten` | **0** | — (dipende da `mine_sealed`) |
| `DST_VAERAX_LEGEND` · **VITTORIA** | `mine_sealed` | **0** | **3 volte** ✓ |
| `DST_VAERAX_LEGEND` · **TRIONFO** | `mine_sealed` | **0** | **3 volte** ✓ |

`DST_VAERAX_LEGEND` e' murato **a tutti e tre i passi**: chi lo pesca ha in mano
un tarocco su cui non c'e' niente da prendere.

#### La catena, misurata

`mine_sealed` lo scrive solo `CNS_MINE_SEALED` ← `P_SEAL_MINE` ←
`Q_AWAKENING_CRYSTAL` ← `CNF_AWAKENING_01` ← `TEN_AWAKENING`.

- **100 partite** (`run_choice_probe`, semi da 7000): `Q_AWAKENING_CRYSTAL` si
  apre **1 volta**; `Q_AWAKENING_MOUNTAIN` **mai**. Quell'unica volta
  `P_SEAL_MINE` ando' ai voti e **non passo'**.
- **100 partite** (`run_world_marks_probe`): `mine_sealed` scritto **0 volte**.
- **20 partite** (`run_tension_reach_probe`): `TEN_AWAKENING` e' una delle due
  Tensioni su 60 che **non arrivano mai al tavolo**.

E la coda: `mine_sealed` e' il primo anello della catena delle ere `TLY_SEAL`,
che al terzo posa `mountain_forgotten`; `mountain_forgotten` e' la condizione
d'entrata di `INC_VAERAX_LEGEND` — che il cancello delle vite conta **0 volte**
— ed e' il `when_also` di `TGR_LEGEND_VOICE`, che quindi non morde mai. **Una
proposta che non passa spegne un ramo intero.**

#### Le tre strade, e nessuna e' misurata

1. **Il Risveglio arriva piu' spesso.** `TEN_AWAKENING` e' un candidato su 60 e
   se ne pescano 4: e' il collo di bottiglia a monte. Costo: tocca la pesca
   delle Tensioni, quindi **tutto**, e va misurato sui 100 semi.
2. **`mine_sealed` ha una seconda penna.** Una casella del Consiglio (D-280,
   `POSA UN SEGNO`) o un'Azione stampata che lo posa: il segno smette di
   dipendere da una proposta sola. E' la strada piu' vicina alla direzione — il
   Consiglio decide cosa il mondo ricordera'.
3. **I passi cambiano appiglio.** Vaerax chiede qualcosa che il mondo scrive
   davvero. Costo: due Destini riscritti, e la storia della montagna sigillata
   sparisce dal gioco.

**Fatto quando** il committente sceglie, e sotto quella scelta `mine_sealed`
esce almeno una volta su 100 partite.

> ### Diagnosi rifatta in 0.1.338 ([D-371](DECISIONS.md#d-371)) — i due presupposti erano sbagliati
>
> **«`TEN_AWAKENING` non arriva mai al tavolo»: arriva.** Su cento partite
> arrivano **tutte e sessanta** le domande, e il Risveglio ci arriva in sei, con
> un picco di 17 contro una soglia di 6. Il «mai» veniva da venti partite: con
> quattro domande pescate su sessanta, uno zero in venti partite è ordinaria
> sfortuna.
>
> **«`mine_sealed` dipende da una proposta sola»: no.** La strada 2 di questa
> voce — una casella del Consiglio che lo posa — **era già fatta**: `IL MONDO
> RICORDA` lo scrive su `TEN_ECHOES_BELOW` e `TEN_SLEEPERS`. Aggiunta anche a
> `TEN_AWAKENING` (che poteva **dimenticarlo** senza saperlo **scrivere**):
> misurato, resta a zero.
>
> ### Quello che regge, provato scartando tre ipotesi
>
> | segno | template **generici** che lo producono | scritture su 100 partite |
> |---|---|---|
> | `order_restored` | **4 su 4** | 78 |
> | `question_unresolved` | 1 | 77 |
> | `rumour_running` | 1 | 33 |
> | `mine_sealed` | **0** | **0** |
> | `study_supervised` | **0** | **0** |
> | `valley_sealed` | **0** | **0** |
>
> **I tre segni mai scritti sono esattamente i tre che non stanno in nessun
> template generico.** Vivono dentro il Consiglio di una carta sola, e un
> Consiglio di carta non si apre quasi mai: quattro domande pescate su sessanta,
> 3,5 Consigli a partita, e vanno al mucchio più caldo.
>
> Detta come si direbbe al tavolo: **quello che può succedere solo dentro il
> Consiglio di una carta sola, non succede.**
>
> ### Cosa resta da fare, e non è più una scelta fra tre
>
> Le strade 1 e 2 sono chiuse: la prima punta a un problema che non c'è, la
> seconda è fatta e non basta. Resta **portare la Conseguenza in un pool
> generico** — cioè esattamente quello che [D-348](DECISIONS.md#d-348) aveva
> provato e ritirato perché faceva cadere `test_claim_policy`.
>
> **Fatto quando** si capisce perché aggiungere una proposta a un template
> generico cambia quale dominio una casa rivendica, e sotto quella cura
> `mine_sealed` esce almeno una volta su 100 partite. La stessa cura vale per
> `study_supervised` e `valley_sealed`, che hanno la stessa forma.

> ### Quasi chiusa in 0.1.339 ([D-372](DECISIONS.md#d-372)) — il blocco non c'era più
>
> Rimessa la proposta di [D-348](DECISIONS.md#d-348), identica. Prima di
> ragionarci sopra si è **riprodotto il guasto**, che è l'unica cosa che dice la
> verità: **il test non cade più**, e nemmeno nessun altro.
>
> Ventitré versioni separano D-348 da qui, e in mezzo la politica di
> rivendicazione è cambiata — fra le altre
> [D-191](DECISIONS.md#d-191), che ha aggiunto la presa di parola in un colpo,
> cioè proprio il ramo che decide se una domanda si prenota o si strappa. Il
> blocco era reale allora ed è stato sciolto da un'altra parte, senza che
> nessuno se ne accorgesse.
>
> | su 100 partite | prima | dopo |
> |---|---|---|
> | `mine_sealed` scritto | **0** | **3** |
> | punti regalati | 5 | **3** |
> | porte murate | 4 | **1** |
>
> **Le tre porte murate di Vaerax si aprono**, e i tre punti regalati a Lyra
> smettono di essere gratis.
>
> ### Cosa resta
>
> **`DST_VAERAX_LEGEND · SOGLIA`**, che chiede `mountain_forgotten`: è il terzo
> anello della catena delle ere, e vuole `mine_sealed` sul mondo a tre
> successioni di fila senza che il Cristallo venga messo a rendere. Con tre
> partite su cento che sigillano, la catena non parte — `seal_kept` e
> `seal_kept_twice` restano a zero.
>
> **`study_supervised` e `valley_sealed`**, che hanno la stessa forma e la
> stessa cura: una seconda penna. Non fatte qui perché ognuna è una proposta
> d'autore, e una proposta d'autore è contenuto.
>
> **La lezione, che vale oltre questa voce:** una strada ritirata va
> **riprovata**, non archiviata. Il costo di riprovare era un comando; quello di
> non riprovare sono state sei clausole morte su tre Destini per ventitré
> versioni.


### 109. ✅ Il MASTER PROMPT 6 e' ricopiato in Python invece che letto — fatta in 0.1.314

`strumenti` · aperta in 0.1.312 ([D-347](DECISIONS.md#d-347)) · **chiusa in 0.1.314** ([D-349](DECISIONS.md#d-349))

> **Presa la strada 1.** `tools/token_catalogue.py` legge il MASTER PROMPT 6 e
> le sue varianti di contorno da `docs/ART_BIBLE.md`, come fa `art_bible.gd`
> per gli altri cinque. La costante ricopiata non c'e' piu': cambiare il
> documento cambia il catalogo.

Cinque MASTER PROMPT su sei li **legge** `art_bible.gd` da `docs/ART_BIBLE.md`,
e la ragione sta scritta nel suo commento: *«copiarli qui avrebbe creato la
seconda copia di un testo che deve restare uno, ed e' esattamente l'errore che
questo progetto ha gia' commesso due volte»*.

Il sesto — il pittogramma del segnalino da 15 mm — sta **ricopiato dentro**
`tools/token_catalogue.py`, nella costante `PROMPT`, insieme alle due varianti
del contorno in `BORDO`. Nessun cancello confronta le due copie: si puo'
cambiare il documento e il catalogo continua a stampare l'altro testo, per
sempre e in silenzio.

Non ha ancora fatto danni perche' il prompt 6 non si tocca da 0.1.260. E' pero'
la stessa forma dei difetti che questo progetto trova da nove versioni: **due
verita' per la stessa cosa, e nessuna che sorvegli l'altra.**

#### Le due strade

1. **Python legge la ART_BIBLE**, come fa `art_bible.gd`: un parser piccolo per
   un blocco solo, ed e' finita.
2. **Un cancello che confronta le due copie**, se leggere costa piu' del
   confronto: piu' economico, ma tiene in piedi la duplicazione.

**Fatto quando** cambiare il MASTER PROMPT 6 nel documento cambia il catalogo,
oppure fa fallire un cancello.

### 110. ✅ Dove si posa quello che il mondo ricorda — chiusa in 0.1.320

`componenti` · `grammatica-fisica` · aperta in 0.1.315 ([D-350](DECISIONS.md#d-350)) · **decisa in 0.1.316** ([D-351](DECISIONS.md#d-351))

> **Il committente ha scelto la strada 2: gettoni sul bordo della mappa.** Un
> fatto del mondo e' del mondo — non di un luogo, non di una casa — e sul bordo
> si vede da ogni posto al tavolo.
>
> **Resta da fare la parte che si scrive a mano.** 49 dei 52 segni hanno gia' la
> parola stampata; **51 su 52 non hanno la scheda del disegno** in
> `token_icons.json`, che e' l'unica parte del catalogo delle pedine scritta a
> mano. Finche' non c'e', quei gettoni hanno un posto e non hanno una faccia.
>
> E prima di tagliare la fustella conviene guardare
> [MISURA_TAVOLO](MISURA_TAVOLO.md): di quei 52, **20 non si posano mai** in
> cento partite. Venti gettoni che resterebbero nella scatola.
>
> **Fatta in 0.1.320** ([D-356](DECISIONS.md#d-356)): cinquanta schede nuove piu'
> `heir_named` spostato sul foglio giusto. I tre `legend:` non ne hanno una loro
> — sono lo stesso gettone girato. Il censimento della scatola adesso li conta:
> **da 67 tipi a 118, da 91 pezzi a 142**, e un foglio-fustella in piu'.

Dando a ogni segno il suo posto sul tavolo, cinque posti su sei si sono riempiti
da soli — la tessera, lo spazio della Pietra, il gettone di zona, il dischetto
della Cicatrice, la scheda della casa. Il sesto no.

**Cinquantadue segni non stanno da nessuna parte.** Sono la memoria del mondo:
`debt_forgiven`, `betrayal_spoken`, `heir_named`, `question_unresolved`. Non
sono un tratto di un luogo, non sono uno stato di una casa: sono fatti che il
mondo ha ricordato, e sul tavolo **nessuno ha ancora deciso che pezzo siano**.

Sono un quarto del dizionario, e il piu' scritto di tutti: 48 dei 52 li scrive
qualcosa, contro i 14 gettoni di condizione.

#### Le tre strade

1. **Un registro della Cronaca** — una plancia dove i fatti si scrivono in fila,
   come un libro dei conti. Sta col «l'app di supporto tiene il verbale»: e' il
   posto dove un fatto si legge, non un pezzo che si prende in mano.
2. **Gettoni sul bordo del tavolo** — un segnalino per fatto, in una fascia
   comune. Costa cinquantadue fustelle nuove, ma rende visibile a colpo d'occhio
   cosa il mondo si sta portando dietro.
3. **Sulla carta che li ha creati** — il fatto resta sulla carta Tensione o sulla
   Conseguenza che lo ha scritto, girata a faccia in su davanti a chi l'ha
   proposta. Zero pezzi nuovi, e il fatto ha un padrone visibile.

**Fatto quando** ogni segno `WORLD_MEMORY` ha un pezzo di cartone, oppure una
riga che dice perche' non gliene serve uno.


### 111. Le dieci Pietre che non si alzano mai, e sono due difetti diversi

`regole` · `contenuto` · aperta in 0.1.316 ([D-352](DECISIONS.md#d-352))

> **Avanzamento in 0.1.369** ([D-401](DECISIONS.md#d-401)): **per la prima volta
> un luogo si consuma.** `place:low_spring` — la sorgente che cala — arriva sul
> tavolo, e non era mai arrivata: la posa `CNS_VALLEY_DRAINED`, che da oggi e' il
> fallimento del Consiglio dell'Acqua.
>
> **E due dei «non arriva mai» non sono difetti di questa voce**:
> `structure:palace` e' il **grado 5** della Torre e `settlement:city` il **grado
> 4** dell'Insediamento, e [ISSUES 40](#40) ha deciso in 0.1.142 che il grado
> alto e' **materia di saga**. La sonda gioca cento anni **scollegati**: chiedere
> a un anno solo di arrivare al quinto grado e' come chiedere una reggia in una
> sera. Nella saga del Regno che si e' seduto la reggia arriva all'anno 818.
> Vanno misurati con [MISURA_VITE.md](MISURA_VITE.md), non qui.
>
> **Restano** `place:dry_spring`, `place:thinned_wood` e `place:collapsed_pass`:
> i gradi consumati che nessuna Conseguenza posa ancora.

> **Richiesta del committente:** *«la potatura — fai leggere le 25 fonti e le 7
> pietre».*

La sonda del tavolo dice quali segni di Pietra non arrivano mai in cento
partite. Sono dieci, e **non hanno tutti lo stesso difetto**: metterli in una
lista sola era l'errore della diagnosi di prima.

#### Sei hanno gia' chi le scrive — la Conseguenza non viene mai scelta

| segno | chi lo scriverebbe |
|---|---|
| `place:thinned_wood` | `CNS_VALLEY_CLEARED` |
| `place:open_site` | `CNS_MINE_SEALED`, `CNS_MINE_REOPENED` |
| `place:stripped_site` | `CNS_CRYSTAL_EXPLOITED` |
| `place:low_spring` | `CNS_VALLEY_DRAINED` |
| `place:dry_spring` | `CNS_WATER_PRICED` |
| `place:collapsed_pass` | `CNS_MINE_ROAD_CUT` |

Questi **non sono segni muti**: sono Conseguenze che il Consiglio non sceglie
mai. E' la stessa forma di [ISSUES 56](#) (`dragon_slain`, *«la Conseguenza non
e' mai stata scelta»*) e di [ISSUES 108](#): `CNS_MINE_SEALED` scrive tutt'e due
`mine_sealed` **e** `place:open_site`, e nessuno dei due esce mai. **Un solo
difetto, contato tre volte in tre posti diversi.**

Farli arrivare non vuol dire toccare il dizionario: vuol dire capire perche'
quelle Conseguenze non vengono mai votate. Chi risolve ISSUES 108 risolve anche
due righe di questa tabella.

#### Tre non hanno proprio nessuno

- **`structure:palace`** — il terzo grado di `STR_KEEP`. Nessun effetto porta un
  Presidio al grado 3: la Reggia e' scritta nel catalogo e non si costruisce.
- **`settlement:city`** — il terzo grado di `STR_SETTLEMENT`. E qui e' peggio:
  **nessun effetto tocca `STR_SETTLEMENT`**, a nessun grado. Villaggio, Borgo e
  Citta' sono tre gradi di una Pietra che niente alza.
- **`structure:road`** — gia' tracciata da [ISSUES 101](#): fra le dieci Pietre
  non ce n'e' una che si chiami «strada».

#### E uno non e' un difetto

`settlement:$proponent` porta un id dinamico: il nome di chi ci vive si scrive
dentro il segno, e la forma nuda non compare mai. Va tolto dal conto, non dal
gioco.

**Fatto quando** ogni grado di ogni Pietra o si alza almeno una volta in cento
partite, o non e' piu' nel catalogo.

> ### Rimisurata in 0.1.336, e i numeri di questa voce erano vecchi
>
> «Dieci Pietre» era il conto della 0.1.316. Misurato adesso con
> `docs/MISURA_TAVOLO.md` — che guarda il tavolo a fine partita e non il
> registro degli Effetti — **i gradi di Pietra che non arrivano mai sono
> cinque**, e uno se n'e' andato stanotte.
>
> | | a D-366 | adesso |
> |---|---|---|
> | gradi di Pietra che non arrivano mai | 6 | **5** |
>
> **`structure:palace` arriva.** La Reggia — il terzo grado del Presidio — non
> era mai stata costruita in tutta la storia misurata del gioco: era scritta nel
> catalogo e basta. La casella UNA PIETRA SALE di
> [D-370](DECISIONS.md#d-370) l'ha alzata. Confronto fatto sui due documenti
> committati, non a occhio.
>
> **E il conto totale dei segni che non arrivano mai sale da 59 a 60**, il che
> sembra un peggioramento e non lo e': `seal_kept` e `seal_kept_twice` sono
> entrati nel dizionario con [D-369](DECISIONS.md#d-369), quindi adesso si
> contano. Non arrivavano nemmeno prima — non li guardava nessuno.
>
> ### I cinque che restano, e sono tre difetti diversi
>
> | grado | Pietra | perche' non arriva |
> |---|---|---|
> | `place:thinned_wood` | Foresta, grado 2 | **il grado di mezzo si salta**: la frase d'autore porta la Foresta dal grado 1 al 3 in un colpo, e il motore toglie il segno vecchio e mette quello nuovo — il segno di mezzo non passa. Non e' un difetto del motore: al tavolo si scambia il gettone, non se ne posa uno intermedio. E' la frase che decide di saltare. |
> | `place:open_site` | Sito antico, grado 2 | le Conseguenze che li muovono **non vengono mai scelte**: e' la [108](#108), non questa voce |
> | `place:stripped_site` | Sito antico, grado 3 | idem |
> | `place:low_spring` | Sorgente, grado 2 | **nessuna carta costruisce la Sorgente**, quindi UNA PIETRA SALE non le arriva: la muovono solo le frasi d'autore, e quelle scendono al grado 3 |
> | `settlement:city` | Insediamento, grado 3 | il grado 2 arriva 10 volte su cento partite; la Citta' vuole che UNA PIETRA SALE sia comprata proprio li', e le carte che costruiscono l'Insediamento sono **tre** su sessanta |
>
> Due delle cinque righe le chiude chi chiude la [108](#108). Le altre tre sono
> contenuto: quale frase d'autore salta un grado, e su quante carte stanno la
> Sorgente e l'Insediamento.
>
> **`structure:road` resta fuori dal conto**: non e' il grado di una Pietra, e'
> una Pietra che non esiste — [101](#101). E `settlement:$proponent` non era un
> difetto e non lo e': porta un id dinamico, e la forma nuda non compare mai.

---

### 112. ✅ Due segni della catena delle ere non stanno nel dizionario — CHIUSA in 0.1.335

`dati` · `piccola` · aperta in 0.1.320 ([D-356](DECISIONS.md#d-356))

`seal_kept` e `seal_kept_twice` sono il secondo e il terzo anello della catena
`TLY_SEAL`, quella che da `mine_sealed` porta a `mountain_forgotten`. Il mondo li
scrive, `sign_labels.gd` li stampa, e da 0.1.320 hanno la loro scheda del
disegno — **ma non sono voci del dizionario dei segni.**

Vuol dire che di loro non si sa quello che si sa di tutti gli altri: che
categoria sono, in che posto del tavolo stanno, chi li posa e chi li legge. E il
controllo 1 di `validate_physical` — *«ogni segno toccato e' nel dizionario»* —
non li vede, perche' li nomina la catena delle ere dentro il dato di Chronicle, e
quel percorso il censimento non lo raschia.

Sono due, e la cura e' due voci con `table_place: WORLD_MEMORY`. La parte da
guardare e' l'altra: **quanti altri segni entrano dal cancello che questo
percorso lascia aperto.**

**Fatto quando** i due sono nel dizionario, e il censimento guarda anche le
catene delle ere.

> ### Chiusa in 0.1.335 ([D-369](DECISIONS.md#d-369))
>
> Le due voci ci sono, e il censimento raschia le catene delle ere: una Cronaca
> **scrive** ogni anello e **legge** ogni anello — non «ogni anello oltre il
> primo», che è quello che la prima stesura diceva e che la guardia ha bocciato
> avendo ragione lei.
>
> Il varco ha portato a galla una mano sbagliata che nessuno cercava:
> `mountain_forgotten` diceva `written_by: ["tension"]`, e la catena lo posa
> eccome.
>
> E lo stesso buco c'era nel disegno: le due voci nuove comparivano in
> `flusso.html` come **pezzi senza una freccia**. Adesso la catena delle ere è un
> pezzo del grafo — legge la condizione, teme il segno di guardia, posa i suoi
> tre anelli e li rilegge per sapere a che punto è.
>
> **E la misura adesso lo dice a voce alta**: `seal_kept`, `seal_kept_twice` e
> `mountain_forgotten` *non arrivano mai* sul tavolo. Non è un difetto nuovo, è
> la [108](#108) che diventa visibile — la catena parte da `mine_sealed`, che in
> cento partite nessuno scrive. Prima quel buco era coperto da due segni fuori
> catalogo; adesso è una riga in un documento sorvegliato.

---

### 113. ✅ Quante carte fanno, nel motore, cose che la loro faccia non dice — CHIUSA in 0.1.328

`regole` · `grammatica-fisica` · `da-misurare` · aperta in 0.1.322 ([D-358](DECISIONS.md#d-358))

> **Richiesta del committente:** *«io non capisco perche' ancora ci sono cose che
> vivono solo nell'app e altre che sono sul gioco fisico. ELIMINA ogni cosa che
> vive solo nell'app».*

[D-358](DECISIONS.md#d-358) ne ha tolta **una**: la grammatica di Propp, che
viveva in ventiquattro segni nascosti sul mondo. Ne resta una famiglia intera, e
prima di tagliarla va contata.

Il caso che l'ha fatta vedere: **il Magistrato** (`AST_AUTHORITY_MAGISTRATE`).
I suoi `on_commit_effects` tolgono `scar:unanswered` dal luogo — «il Magistrato
chiude la cicatrice del consiglio che non decise» (D-112). La sua **faccia
fisica** ha due Azioni, e nessuna delle due nomina quella Cicatrice: tolgono
`#conteso` e `#malcontento`.

Cioe': nell'app quella carta cura una Cicatrice **undici volte su cento
partite**, e al tavolo quella cura non e' scritta da nessuna parte. Un giocatore
che legge la carta non puo' saperlo.

**Non e' un caso isolato per costruzione**: `on_commit_effects` (la grammatica
digitale) e `physical.actions` (quella fisica) sono due liste separate, e
**nessun cancello controlla che dicano la stessa cosa**. Il validatore controlla
che una carta non nomini segni inesistenti, non che le due facce combacino.

#### Cosa serve prima di decidere

Una misura, per ogni carta con una faccia fisica: **quali effetti digitali non
hanno una riga corrispondente sulla faccia**. Il numero puo' essere due o
quaranta, e la cura cambia di conseguenza:

- se sono pochi, si scrivono le righe mancanti sulle facce;
- se sono tanti, il difetto e' che le due liste si scrivono a mano due volte, e
  serve un cancello che le confronti.

#### Una parte del numero e' arrivata da sola: 48 su 48

Guardando il grafo del flusso su `question_unresolved` (0.1.322) e' saltata fuori
la famiglia piu' grande, e non e' negli `on_commit_effects`: e' **nella
Risonanza**, cioe' nel pezzo di carta che CLAUDE.md chiama obbligatorio.

```
carte con Risonanza fisica     : 48
  con aggravante nel motore    : 48
  che la faccia NON dice       : 48
```

Ogni Risonanza porta `if_target_tag` + `extra_heat` (spesso anche `extra_tag`):
se il bersaglio ha quel segno, scalda **di piu'**, e a volte posa un gettone in
piu'. **Nessuna delle 48 lo scrive nel proprio `resonance.text`.**

| carta | la faccia dice | il motore fa |
|---|---|---|
| Le Porte Bruciate | «Scalda Potere **+2**» | +3 se sul mondo c'e' `#question_unresolved` |
| Leva Contadina | «Scalda Sopravvivenza **+1**» | +2 se il luogo e' `#magro`, e ci posa `#affamato` |
| Banda Armata | «Scalda Terra **+2**» | +3 se il luogo e' `#saccheggiato`, e ci posa `#malcontento` |
| Assedio | «Scalda Sopravvivenza **+2**» | +3 se il grano e' gia' stato requisito |

Il difetto e' lo stesso del Magistrato, ma qui non e' un caso isolato: e'
**il cento per cento** del pezzo di carta piu' letto al tavolo. Un giocatore che
sceglie dove giocare una carta sta scegliendo, senza saperlo, anche quanto
scalda.

Il rimedio non e' piu' un ballottaggio fra i due della sezione sopra: a 48 su 48
la riga va scritta su tutte e 48 le facce **e** serve il cancello, perche' a mano
si riscrive due volte la stessa cosa e la seconda volta si sbaglia.

**Fatto quando** ogni effetto digitale di una carta ha una riga sulla sua faccia,
oppure una ragione scritta per cui non ce l'ha — e un cancello lo tiene.

---

### 114. ✅ Le carte del Narratore si calano il 2,6% delle volte — CHIUSA in 0.1.325

`regole` · `da-decidere` · aperta in 0.1.324

> **Domanda del committente:** *«innanzi tutto quando vengono giocate? Perche' se
> vengono posate il 2% delle volte, direi che abbiamo un problema. Poi quanto
> cambiamo il mondo e il gioco quando vengono calate? E per ultimo servono a
> qualcosa a livello di gioco?»*

Il numero che ha indovinato è **2,6%**. Misura: `cli/run_echo_weight_probe.gd`,
100 anni pescati, tavolo misto, semi da 7000 — lo stesso tavolo del cancello.

#### 1. Quando

```
carte distribuite in mano        15.21 per partita   (1521)
carte calate sul tavolo           0.40 per partita   (40)
quota delle distribuite che si cala   2.6%
restano in mano a fine partita   14.81 per partita   (1481)
partite con almeno una calata    37 su 100
    Atto 1: 1     Atto 2: 10     Atto 3: 29
```

**In 63 partite su 100 nessuno cala mai una carta del Narratore.** Il mazzo
distribuisce quindici carte per partita e ne arriva sul tavolo meno di una.

#### 2. Quanto cambiano il mondo

Al netto del prezzo — una carta Asset scartata, esattamente 1,00 per calata:

| | Effetti | quante volte |
|---|---|---|
| una carta del Narratore | **3,10** | 40 |
| una carta Asset giocata | 1,05 | 2800 |
| un Consiglio | **14,81** | 344 |

Quando escono **pesano**: tre volte una carta Asset. Ma su 100 partite scrivono
**124 Effetti contro i 5093 del Consiglio** — il 2,4% di quello che il mondo
scrive. Il peso per calata è alto, il peso sul gioco è invisibile.

#### 3. Servono a qualcosa

```
carte scritte                    39
carte uscite almeno una volta    12
carte che non escono mai         27
```

E delle 12 che escono, **una sola fa il 60% del lavoro**: `ECH_SACRIFICE`, 24
calate su 40. È l'unica carta senza nessuna condizione di eleggibilità che il
tavolo scelga volentieri. Le altre 38 si dividono 16 calate in cento partite.

Le 9 carte che **prescrivono un Consiglio** — la cosa più potente che una carta
possa fare in questo gioco — escono **4 volte su 100 partite**.

#### La causa, e non è nel mazzo

**25 carte su 39 chiedono che una Tensione nominata sia in gioco quest'anno.**

Dopo [D-318](DECISIONS.md#d-318) l'anno non è più scritto a mano: le questioni
si pescano dalle sessanta, `tension_pool.count: 4`, e ne finiscono sul tavolo
8,8 per partita. Una carta che chiede `TEN_FAMINE` è dunque eleggibile in circa
**una partita su sette**, e deve anche essere pescata, e deve anche servire a
chi la tiene.

Il mazzo Eco è stato scritto contro i due anni d'autore con le Tensioni fisse.
D-318 li ha cancellati — misurando il guadagno, 48 carte Tensione su 60 tornate
al tavolo — e **non ha misurato cosa costava allo strato di Propp**. È il costo
non scritto di quella decisione, trovato due mesi dopo.

La fotografia di fine partita dice che non è solo l'eleggibilità:

| perché una carta è rimasta in mano | carte |
|---|---|
| la storia non è pronta (eleggibilità) | 758 |
| **si poteva calare, non l'hanno voluta** | **495** |
| mano vuota: non c'è con cosa pagarla | 228 |

Un terzo delle carte ferme era **legale**. Le tre porte del decisore — mano
comoda (≥4 carte), una calata per Atto per seggio, e un punteggio > 0 sui suoi
obiettivi — pesano quanto l'eleggibilità.

#### Le tre strade, e la domanda che viene prima

**La domanda è del committente e viene prima delle strade:** un mazzo di 39
carte che arriva sul tavolo 0,4 volte per partita **esiste nella scatola?**

1. **Togliere la Tensione nominata dall'eleggibilità.** Le carte parlano di
   *carestia*, non di `TEN_FAMINE`: si legano ai **segni** che la carestia
   lascia sul mondo (`condition:lean`, `grain_requisitioned`) invece che
   all'identificatore della questione. È la stessa correzione che D-274 ha
   fatto per il bersaglio delle carte Asset.
2. **Meno carte, ognuna più larga.** 39 carte per 0,4 calate è un mazzo che il
   gioco non consuma. Dodici carte senza condizione varrebbero più di trentanove
   con una lotteria davanti.
3. **Nessun mazzo separato.** Se la funzione narrativa è quello che una carta
   Eco porta, e le carte Asset hanno già Risonanza e Temi, il Narratore potrebbe
   essere **una faccia della carta Asset** e non un mazzo a parte.

**Fatto quando** una carta del Narratore arriva sul tavolo abbastanza spesso da
giustificare che sia stampata — oppure il mazzo non c'è più.

**Nota su ISSUES 113:** le 39 carte Eco sono anche i pezzi senza faccia fisica
(`0 su 39`). Scriverle prima di decidere questa issue sarebbe scrivere 39 facce
per un mazzo che potrebbe non esistere.

---

### 115. ✅ Una chiave sbagliata nel payload di un Effetto non la vede nessuno — CHIUSA in 0.1.327

`cancelli` · `dati` · aperta in 0.1.325 ([D-359](DECISIONS.md#d-359))

Scrivendo i nove Echi nuovi ho dato a `ECH_THE_ONE_WHO_SAW` questo Effetto:

```json
{"type": "SET_TENSION_VISIBILITY", "target": {...}, "payload": {"visible": true}}
```

La chiave giusta è `visibility`, e il valore `"OPEN"`. Con `visible` la carta
**non scopriva niente**, e il catalogo generato la stampava come *«tension adesso
e velata»* — cioè il contrario di quello che la carta racconta di fare, su una
Tensione che non sapeva nemmeno nominare.

**Nessun cancello l'ha vista.** `validate_data.py` è passato perché in
`effect.schema.json` il payload è dichiarato `{"type": "object"}`, senza vincoli
sulle chiavi. `validate_physical.py` è passato perché guarda i segni, non le
chiavi. Il motore non ha protestato perché **GDScript non alza niente**: una
chiave che manca interrompe la funzione in silenzio — è la prima delle trappole
scritte in CLAUDE.md.

L'ha vista **il catalogo delle carte**, che stampa cosa fa ogni carta ricavandolo
dai dati: leggendo il log della CI si vedeva una revelation che velava. È la
prova che quei documenti generati servono, ma è un caso: nessuno garantisce che
la prossima chiave sbagliata produca una riga strana da notare.

#### Cosa serve

Un censimento dei dati di oggi dice che **il resto è pulito** — ogni tipo di
Effetto usa un solo insieme di chiavi, e le uniche rare sono `optional`, che è
un modificatore condiviso:

```
ADJUST_TENSION           {delta: 106}
SET_GLOBAL_TAG           {tag: 64}
SET_TENSION_VISIBILITY   {visibility: 9}
BUILD_STRUCTURE          {structure_type: 8, grade: 8, owner: 8}
SET_RELATION             {add_tag: 5, remove_tag: 2, level: 6}
```

Quindi le chiavi ammesse per ogni tipo **si possono dichiarare**, e il posto
giusto è `effect.schema.json`: un `payload` con `additionalProperties: false` per
tipo, e `validate_data.py` morde da solo senza codice nuovo.

**Fatto quando** un payload con una chiave che il motore non legge fa andare
rosso un cancello, e la guardia ha il suo difetto piantato nel `--self-test`.

#### Chiusa: [D-361](DECISIONS.md#d-361)

`effect.schema.json` dichiara le chiavi ammesse per 27 tipi su 29, ricavate da
**quello che `EffectApplier` legge** e non dai dati — ricavarle dai dati avrebbe
reso legge il primo refuso. `CREATE_ECHO` e `APPEND_TRUTH` restano liberi, con la
ragione scritta: scrivono il payload intero in un registro.

Otto casi piantati nel `--self-test`, fra cui il difetto vero.

E accendendolo il cancello ha trovato subito **30 `optional` decorativi**, su
tipi dove la tolleranza e' gia' incondizionata e la parola non decide niente.
Tolti.

---

### 116. ✅ La tessera non dice dove si costruisce — CHIUSA in 0.1.331

`grammatica-fisica` · `da-decidere` · aperta in 0.1.330 ([D-364](DECISIONS.md#d-364))

> **La struttura fisica, come l'ha dettata il committente:** *«Sulla tessera
> degli spazi che possono cambiare e dove costruire cose, città, granai, ponti,
> fortezze, castelli ecc.»*

Quegli spazi **non esistono sul cartone**. Una tessera dichiara:

| | |
|---|---|
| `presence_slots` | dove vanno le pedine — 4 su Eredan |
| `tags` | i segni stampati — `capitale`, `dominio: la sopravvivenza`… |
| `asset_sources` | da che mazzi si pesca standoci |

E basta. **Nessuna delle dieci dice quanti spazi-Pietra ha, né quali.**

Eppure la categoria esiste: `table_place: TILE_SLOT` raccoglie **27 segni** — le
Pietre e i gradi che le degradano — ed è definita nel dizionario come *«uno
spazio sulla tessera dove si posa una Pietra»*. Quello spazio è dichiarato nel
vocabolario e non è dichiarato sulla tessera che dovrebbe ospitarlo.

Oggi il gioco funziona lo stesso perché il motore tiene le strutture in una
lista sulla Regione, senza limite di posti: si costruisce dove il bersaglio
della carta arriva. Al tavolo però nessuno sa **dove** appoggiare il pezzo, né
se ce n'è ancora posto.

#### Le domande che vengono prima, e sono del committente

1. **Quanti spazi per tessera?** Uno fisso, o legato al bioma?
2. **Il bioma vincola cosa ci si costruisce?** Un porto non fa un granaio; una
   montagna non fa un pascolo. Oggi nessun vincolo esiste: `BUILD_STRUCTURE`
   guarda il bersaglio della carta, non la tessera.
3. **Uno spazio pieno blocca?** Se sì diventa una risorsa contesa — ed è la
   prima cosa in questo gioco per cui valga la pena litigare stando fermi.

**Fatto quando** una tessera dichiara i suoi spazi, la faccia li stampa, e
`BUILD_STRUCTURE` rifiuta una Pietra dove un posto non c'è — con la guardia che
morde su un difetto piantato.

---

Ogni voce qui sopra è già un'issue: il titolo dopo il numero, le etichette e la
milestone dalla riga sotto, il resto come corpo. Chi le apre segna il numero
GitHub accanto al titolo, così questo documento resta l'indice e non una seconda
verità.


---

### 117. ✅ Le caselle nuove ci sono, e cinque carte su sessanta le offrono — chiusa in 0.1.350

`contenuto` · `da-misurare` · aperta in 0.1.332

Da [D-366](DECISIONS.md#d-366) il Consiglio ha diciotto caselle in più — otto
verbi nuovi, e il campo `dove` e il campo `chi` che permettono a **tutte** di
puntare altrove che sul posto di cui si discute. Il vocabolario copre 44 dei 46
Effetti che un Consiglio applica, e 333 applicazioni su 336.

**Quello che il vocabolario può dire non è ancora quello che le carte offrono.**
Le diciotto voci nuove stanno su **cinque carte su sessanta**, e sono lì perché
il Consiglio di quelle domande già faceva quella cosa in una frase d'autore. Le
altre cinquantacinque portano ancora le sette caselle di sempre, tutte puntate
sul posto in discussione.

#### Cosa si apre domani mattina

**(a) Quali caselle offre ciascuna delle sessanta carte.** È contenuto, ed è del
committente: il motore sa già eseguirle tutte, e il validatore rifiuta una
casella scritta male prima che il tavolo se ne accorga. Il posto da cui partire
è `docs/MISURA_CASELLE.md` § *Quello che una casella già dice*: ogni riga è una
cosa che una Conseguenza d'autore fa e che adesso si può posare con una pedina.

**(b) Le quattro caselle che in cento saghe non si sono viste mai.** Misurato con
`run_boxes_probe.gd`: UNA PIETRA SALE, UNA PIETRA SCENDE, CHIUDI LA STRADA, UNA
CASATA LASCIA IL TAVOLO. Non sono rotte — mordono solo dove la loro condizione
tiene, e le condizioni sono strette apposta: una Pietra già in piedi con un
grado libero, due tessere col segno giusto una accanto all'altra, una casa che
porta #dormiente. Il numero è peggiore di quello che si sperava e si scrive.
Delle altre: POSA UN SEGNO SU UNA CASATA 45 offerte e 12 acquisti, MUOVI UN
RAPPORTO 8 e 2, UNA PRESENZA SE NE VA 7 e 2, UNA PRESENZA ENTRA 6 e 0, UNA
DOMANDA VELATA SI SCOPRE 5 e 0, IL MONDO DIMENTICA 2 e 1.

**(c) Due Effetti d'autore che non sono caselle mancanti, ma difetti.**
`SET_ENTITY_TAG` su `$conditioner` (2 applicazioni) nomina «chi ha posto la
condizione», che esiste solo dentro il contesto di una clausola: nel momento in
cui una pedina si posa su una casella non c'è nessuna condizione posta. E
`SET_GLOBAL_TAG` col bersaglio `$adjacent` (1) dà un bersaglio a un verbo che
scrive nel mondo qualunque bersaglio gli si dia — il bersaglio lì non vuol dire
niente, e va tolto o il verbo va cambiato.

#### Cosa la chiude

Il conto di `docs/MISURA_CASELLE.md` a 46 su 46, ogni casella del vocabolario
offerta almeno una volta in cento saghe, e i due Effetti del punto (c) risolti
nei dati.

> ### Quasi chiusa in 0.1.336 ([D-370](DECISIONS.md#d-370))
>
> **(a) fatta, e non come questa voce la immaginava.** Non «scrivi le caselle
> per 55 carte», che avrebbe rifatto il difetto di [D-278](DECISIONS.md#d-278)
> con parole nuove — un menu uguale su tutte — ma **ricava le caselle da quello
> che ogni carta ha già di suo**. 188 voci, nessuna scritta a mano.
>
> Il pezzo che vale di più: `linked_tensions` sta su tutte e sessanta le carte e
> lo legge **una cosa sola**, l'azione INFLUENZARE. Il Consiglio non lo sapeva
> toccare. Con `dove: QUESTION` ogni carta può muovere la domanda che ha legato
> a sé — ed è diversa carta per carta.
>
> **(b) fatta a ventitré caselle su ventiquattro.** UNA PIETRA SALE va da 0 a
> **131** offerte e 10 acquisti; CHIUDI LA STRADA da 0 a 9; UNA PIETRA SCENDE da
> 0 a 1.
>
> **(c) uno era un difetto e uno no.** `CNS_SEALED_VALLEY` puntava un fatto del
> mondo su `$adjacent` — corretto, e adesso lo schema non lo lascia tornare. Ma
> `$conditioner` **non è un difetto**: quei due Effetti vivono dentro le
> clausole, dove `conditioner` è legato eccome. Sono una cosa che le caselle non
> sanno dire e le clausole sì.
>
> ### Quello che resta aperto, e sono due decisioni
>
> **UNA CASATA LASCIA IL TAVOLO: zero offerte in cento saghe, e resta zero.**
> Vuole una casa che porti `#dormiente` — Vaerax, e solo Vaerax — mentre si
> discute della sola carta che offre quella casella. La congiunzione non capita.
> Non è rotta: è la cosa più drastica del gioco e vale **una** applicazione in
> tutto il corpo scritto. Allargarla vuol dire spargere per il tavolo la casella
> che toglie un giocatore, e quella è una decisione di chi progetta.
>
> **ABBASSA LA DOMANDA: 720 offerte, 3 acquisti.** È il difetto che
> [D-343](DECISIONS.md#d-343) aveva già misurato — la policy preferisce le
> caselle che cambiano la mappa — e le carte nuove l'hanno **raddoppiato**. Vale
> 1 in `intrinsic_value`, come RAFFREDDA TEMA. Alzare quel numero è equilibrio, e
> l'equilibrio si misura prima di scriverlo.
>
> **Fatto quando** quelle due sono decise.
>
> ### ✅ Decise in 0.1.350 ([D-382](DECISIONS.md#d-382))
>
> **ABBASSA LA DOMANDA: alzata, e non di un punto a caso.** Adesso la casella
> **legge quello su cui agisce** — raffreddare una domanda a terra non vale
> niente, raffreddarne una a un passo dal Consiglio vale quanto alzare una
> Pietra. **Da 0 acquisti su 730 a 26 su 728.**
>
> Provata prima a 3, alla pari con CAMBIA CONTROLLO: comprata 393 volte su 716
> e le altre si svuotavano. Una casella che mangia le altre e' sbagliata quanto
> una che nessuno compra. Stessa cura a RAFFREDDA TEMA, che era crollata a 2
> acquisti: vale 2 se e' il Tema **col rombo piu' avanti**, e risale a **115**.
> E MUOVI UN RAPPORTO, offerto nove volte in cento saghe, e' salito a 3 perche'
> una prova e' caduta a dirlo.
>
> **UNA CASATA LASCIA IL TAVOLO: resta dov'e', e questa e' la decisione.** Lo
> zero e' la congiunzione — Vaerax al tavolo *e* `TEN_AWAKENING` in discussione,
> una casa su otto per una carta su sessanta — non la casella. E' la cosa piu'
> drastica del gioco e vale **una** applicazione in tutto il corpo scritto:
> spargerla sarebbe un altro gioco. Chi la vuole vedere giocare non deve toccare
> la casella: deve far uscire piu' spesso quella carta, e quello e' il mazzo.

---

### 118. ✅ Sei livelli di vittoria sono un'addizione — chiusa in 0.1.351

`contenuto` · `decisione-del-committente` · aperta in 0.1.344
([D-377](DECISIONS.md#d-377) · [le misure](MISURA_MATRICE.md))

`MISURA_MATRICE.md` diceva **31 livelli su 69** che «si reggono solo sul
contare». Misurati meglio ([D-377](DECISIONS.md#d-377)) sono **17**: gli altri
quattordici si indicano col dito eccome — o puntano il segnalino di una
domanda, o chiedono un **bersaglio a segni** stampato sulla tessera
(*«una pedina dove c'è il #granaio»*).

Degli **17**, **undici sono il `minimum`**: la soglia sotto la quale la casa non
c'è più. Lì il conto è la cosa giusta, e restano.

**I sei che restano sono vittoria o trionfo** — quello per cui una casa viene
ricordata — e sono **tutti e sei su Destini condivisi** (`entity_id: $self`):

| Destino | livello | come si legge |
|---|---|---|
| `DST_SHARED_LAND` | victory | La terra risponde, e non importa come |
| `DST_SHARED_LAND` | triumph | La mappa parla la tua lingua |
| `DST_SHARED_QUIET` | victory | La quiete si vede |
| `DST_SHARED_LORE` | victory | E un posto dove custodirla |
| `DST_SHARED_LORE` | triumph | Quello che sai lo sanno da te |
| `DST_SHARED_HAND` | victory | Le riserve che diventano forma |

**Non è un difetto trovato per caso: è scritto nelle loro descrizioni.**
`DST_SHARED_LAND` dice di sé *«un'ambizione semplice e spietata — contare le
Regioni, e contarle tue»*. Un obiettivo che qualunque casa può prendere non può
nominare il segno di nessuno, e gli resta il numero.

#### La decisione

Se debbano restare aritmetici è una scelta di disegno, e sta al committente.
Se la vorrà cambiare, la casa ha già la sua strada in uso: il trionfo di
`DST_SHARED_QUIET` e quello di `DST_SHARED_HAND` chiudono con
`condition:contested` — **un segno del mondo che non appartiene a nessuna
casa**, quindi resta condivisibile. Gli stessi sei livelli potrebbero chiuderne
uno ciascuno.

Il costo da misurare prima di scriverlo: una clausola in più su una vittoria la
rende **più difficile**, e il cancello dei cento semi vuole **0 seggi bloccati
su 8**.

**Fatto quando** il committente dice se quei sei restano un'addizione o
nominano un segno.

### ✅ Nominano un segno, da 0.1.351 ([D-383](DECISIONS.md#d-383))

Sei clausole, una per livello, ognuna con un segno che **quel Destino dichiara
gia' di osservare** e che il mondo **scrive davvero** — da 458 volte su cento
partite (`condition:contested`) a 13 (`condition:abandoned`). Costruire una porta
murata mentre se ne chiude un'altra sarebbe stato il modo piu' stupido di
sbagliare.

**Livelli che si reggono solo sul contare: 17 → 11, e quelli di vittoria o
trionfo da 6 a 0.** Gli undici che restano sono tutti il `minimum`.

Costo: gli obiettivi avverati scendono da 453 a 438 su 1.200 e il vantaggio di
giocare da +168,0% a +160,7% — le vittorie sono piu' difficili. In cambio tre
Destini condivisi su quattro pagano **meglio** chi gioca di chi sta fermo.

---

### 119. Il Consiglio non cade quasi più, e cosa si perde quando non cade

`regole` · `da-decidere` · aperta in 0.1.345
([D-378](DECISIONS.md#d-378) · rimisurata e riscritta in 0.1.353)

*Riscritta con gli esempi che il committente ha chiesto: la voce di prima
diceva un numero e tre strade, e non diceva **cosa si vede al tavolo**.*

#### Il numero, e da dove viene

Fino a [D-378](DECISIONS.md#d-378), cinquantadue carte Tensione su sessanta
condividevano **due sole proposte generiche** per dominio. Chi proponeva
raramente trovava qualcosa che il tavolo volesse, e i Consigli cadevano — ma per
**povertà di offerta**, non per conflitto. Scritte le proposte carta per carta,
il tavolo trova molto più spesso una proposta che gli va bene:

| esiti su 100 partite | prima di D-378 | dopo | oggi (0.1.353) |
|---|---|---|---|
| tavolo misto — FAILURE | 108 | 37 | **29** |
| tavolo uniforme — FAILURE | 25 | 14 | **15** |

Un Consiglio su undici cade, sul tavolo misto. Prima ne cadeva quasi uno su tre.

#### Cosa succede al tavolo, in concreto

**Un Consiglio che passa.** La Carestia è salita, si apre la Confluenza. Aldric
propone *«Il grano della Valle sia requisito in nome del trono»*. Posa la sua
pedina gratis su **Costruisci 1 Pietra: Granaio**. Nahr si oppone e spende un
gettone per posare **Cedi il controllo del luogo**. Il dado esce, il margine
tiene: la proposta passa. Sulla mappa arriva un Granaio, e la Valle Verde cambia
padrone. **Tutti hanno deciso qualcosa, e la mappa lo mostra.**

**Un Consiglio che cade.** Stessa carta, ma il fronte avverso è più pesante e il
margine non tiene. Adesso succedono tre cose, e **nessuna delle tre è sulla
mappa**:

1. scatta la lista *«se cade»* **stampata sulla carta** — sulla Carestia:
   *«al luogo si aggiunge #fame»* e *«il Tema di questa domanda si scalda di 1»*;
2. il sacchetto dei fallimenti del dominio pesca una delle sette Conseguenze
   `CNS_FAILURE_*` — voci come *«la voce corre»*, che scrivono una memoria nel
   mondo invece di una Pietra;
3. Aldric si porta addosso **`spoke_and_lost`**: ha parlato e ha perso, e il
   segno resta sulla sua scheda.

**Ecco cosa vuol dire «meno posta».** Non che il gioco sia più facile: che
**quel terzo di storie non succede più**. In cento partite `spoke_and_lost` si
posa oggi **8 volte** — su 8 case e 300 Consigli. Un segno che il tavolo vede
una volta ogni dodici partite non è una minaccia: è una curiosità.

#### Le tre strade, con un esempio ciascuna

**(a) Va bene così.** *Un Consiglio deve decidere.* Cadeva perché l'offerta era
povera, e adesso non lo è più; la banda del fallimento resta per i casi veri —
quando il tavolo è davvero spaccato. Al tavolo si vede così: **quasi ogni
Consiglio lascia un segno sulla mappa**, e la tensione sta in *quale* proposta
passa, non nel se.
*Costo:* sette Conseguenze e un segno delle case restano contenuto che quasi
nessuno legge. *Non costa niente da fare.*

**(b) Il fallimento si compra** — ed è la strada che
[D-387](DECISIONS.md#d-387) ha appena reso possibile. Adesso un avversario
spende un gettone per **posare un costo**; la stessa moneta potrebbe comprare
**opposizione**: un gettone speso contro la proposta pesa nel margine.
Al tavolo: *«questa non deve passare»*, e paghi per fermarla — invece di
sperare nel dado. Una proposta cadrebbe quando **qualcuno l'ha voluta far
cadere**, non quando i numeri non tornano.
*Costo:* è una regola nuova sopra una appena scritta, e i gettoni oggi sono
pochi ([ISSUES 125](#125)). Va misurata: il cancello vuole 0 seggi bloccati su
8.

**(c) Si alza la soglia.** Il margine che serve per passare sale di uno. È
equilibrio puro: non cambia niente di quello che si fa al tavolo, cambia
quanto spesso funziona. Al tavolo non si vede una regola nuova — si vede che
proporre da soli non basta più, e che serve **un alleato in più** o **una carta
impegnata in più**.
*Costo:* nessuna storia nuova, e il rischio di riportare i Consigli a cadere per
aritmetica invece che per conflitto — cioè il difetto che D-378 ha appena tolto.
Si misura in mezz'ora, ed è reversibile.

**La mia lettura, se serve:** (a) e (b) non si escludono. (a) è vera oggi, (b) è
la forma piena verso cui l'economia sta andando, e (c) è la sola che rischia di
disfare D-378.

**Fatto quando** il committente sceglie.

---

### 120. Dodici Obiettivi su diciassette si vincono contando, e non nominano niente

`contenuto` · `da-decidere` · aperta in 0.1.347
([D-380](DECISIONS.md#d-380) · [il flusso](flusso.html))

Messi gli Obiettivi nel disegno del flusso ([D-380](DECISIONS.md#d-380)), dodici
su diciassette sono usciti **senza nemmeno una freccia**: nessun segno nominato,
nessuna Pietra contata, niente su cui puntare il dito.

| | |
|---|---|
| Obiettivi | 17 |
| **che non toccano nessun pezzo del tavolo** | **12** |
| clausole di Obiettivo che nominano un segno | 4 |

Sono `OBJ_A_HIGH_HOUSE`, `OBJ_A_LEARNED_HOUSE`, `OBJ_A_STONE`, `OBJ_BOUND_HOUSE`,
`OBJ_FULL_HANDS`, `OBJ_MOST_STONE`, `OBJ_QUIET_WORLD`, `OBJ_SOMETHING_MUST_BREAK`,
`OBJ_THE_LONGEST_REACH`, `OBJ_THE_WIDEST_SPREAD`, `OBJ_TWO_LANDS`,
`OBJ_WRITTEN_THINGS`.

**È lo stesso difetto che [D-377](DECISIONS.md#d-377) ha misurato sui Destini**,
in un posto dove nessuno l'aveva ancora guardato — e con la stessa attenuante:
un obiettivo che si tiene in mano deve valere per chiunque lo peschi, quindi non
può nominare il segno di nessuno. Ma un obiettivo è **cinque punti**, e cinque
punti che nessuna Tensione può aiutare né minacciare non entrano nella partita
che il tavolo sta giocando: si contano a fine anno e basta.

#### Cosa si può fare, e la scelta è del committente

- **(a) Restano conti.** Sono la moneta piccola del punteggio, e va bene così.
- **(b) Ognuno chiude con un segno.** La casa ha già la strada: quattro
  Obiettivi su diciassette nominano `renowned`, `question_unresolved`,
  `condition:exploited`, `condition:emptied`. Costo da misurare: una clausola
  in più rende l'obiettivo **più difficile**, e il cancello vuole 0 seggi
  bloccati su 8.
- **(c) Metà e metà**, tenendo i conti puri come obiettivi facili e dando un
  segno a quelli che valgono di più.

**Fatto quando** il committente dice se quei dodici restano un'addizione.

### Rimisurata in 0.1.351, e la domanda era mal posta ([D-383](DECISIONS.md#d-383))

**I dodici del disegno non sono i tredici della misura.** Col metro di
[D-377](DECISIONS.md#d-377) — non nomina un segno, non si indica, si conta —
sono **13 su 17**; nel grafo erano dodici perche' `OBJ_BOUND_HOUSE` si indica
(guarda il filo fra due case) e `OBJ_A_GARRISON` e `OBJ_A_WORK` puntano una
famiglia di Pietre. Due liste diverse, tutte e due vere, e la voce ne dichiarava
una sola.

**Ma il difetto vero non e' il conto: e' il tempo del verbo.** Sei obiettivi su
diciassette rendono **uguale o meglio stando fermi**, e sono quasi gli stessi:

| obiettivo | giocando | da fermi |
|---|---|---|
| `A_WORK` | 9 | 16 |
| `BOUND_HOUSE` | 13 | 20 |
| `MOST_STONE` | 9 | 12 |
| `THE_LONGEST_REACH` | 7 | 10 |
| `A_STONE` | 19 | 20 |
| `THE_WIDEST_SPREAD` | 4 | 4 |

Guardati insieme dicono una cosa sola: **chiedono di avere, non di fare.** Due
Pietre in piedi, piu' Regioni di tutti, piu' pedine di tutti, un legame in mano —
sono tutte cose che si **perdono** agendo e che un tavolo di pietra, che non
agisce mai, non perde. Il conto non c'entra: `SOMETHING_MUST_BREAK` conta anche
lui, e rende **+100%** giocando, perche' chiede che qualcosa *succeda*.

#### La cura, e perche' non l'ho scritta

Un obiettivo dovrebbe chiedere quello che si e' **fatto quest'anno**, non quello
che si **ha** a fine anno. Oggi nessuna clausola sa dirlo: le diciotto forme che
il motore valuta guardano tutte lo **stato**, non il registro degli Effetti.
Serve un tipo di clausola nuovo — *«una Pietra alzata da te quest'anno»*,
*«un legame stretto quest'anno»* — che legge il verbale invece del tavolo.

E' motore, schema, `schema_defs.gd` rigenerato, valutatore e prove: non e' una
riga, ed e' una scelta che cambia **come si scrive un obiettivo**, non solo
questi sei. **Fatto quando** il committente dice se gli obiettivi devono
chiedere un gesto o uno stato.

**E lo stesso vale per un Destino:** `DST_SHARED_QUIET` e' l'unico che ancora si
avvera da fermi (0,84 giocando contro 1,04), e nessun segno lo ribalta — chiede
che le questioni restino basse, e un tavolo che non fa niente le tiene basse per
definizione. E' lo stesso difetto, con la stessa cura.

### La cura è scritta, e ha curato quattro obiettivi su sei (0.1.353, [D-386](DECISIONS.md#d-386))

Il committente ha detto *«fai la cura proposta»*, ed è fatta: `did_this_year`,
una clausola che legge **il verbale dell'anno** invece dello stato del tavolo, e
quattro gesti — alzare una Pietra, prendere una terra, posare una presenza,
stringere un legame.

| obiettivo | prima (giocando / fermi) | dopo |
|---|---|---|
| `BOUND_HOUSE` | 6 / 20 → −19% | 6 / 0 → **+8%** |
| `THE_LONGEST_REACH` | 3 / 10 → −10% | 2 / 0 → **+3%** |
| `THE_WIDEST_SPREAD` | 4 / 4 → +0% | 4 / 0 → **+7%** |
| `A_WORK` | 14 / 16 → −3% | 13 / 13 → +0% |
| `MOST_STONE` | 12 / 12 → +0% | 6 / 7 → **−2%** |
| `A_STONE` | 15 / 20 → −7% | 5 / 15 → **−14%** |

**Sei → tre**, e i tre che restano sono tutti e tre di Pietra, con una causa
sola e misurata: **nessuna Azione della plancia alza una Pietra** — una sola in
cento partite — e le Pietre le alza il Consiglio, che è **più generoso con un
tavolo che tace** (199 contro 165). È [ISSUES 123](#123), aperta lì.

**Resta aperta questa voce**, per la domanda che la cura ha lasciato sul tavolo:
`did_this_year` **non ha un segnalino**. A fine anno «l'hai alzata quest'anno?»
si risponde ricordando, o guardando l'app. Il candidato più economico è già
nella scatola — **la pila delle carte giocate, scoperta davanti a ciascuno**,
che è dove `echo_function_played` già guarda — ma renderebbe il gesto una
proprietà della carta invece che del mondo. **Fatto quando** il committente dice
come il tavolo si ricorda di un gesto.

---

### 121. ✅ Due segni e un'Azione che nessuno tocca — CHIUSA in 0.1.348: non era vero

`contenuto` · `debito` · aperta in 0.1.347 ([D-380](DECISIONS.md#d-380)) ·
**chiusa da [D-381](DECISIONS.md#d-381)**

**Questa voce era sbagliata, e si è chiusa guardando i dati invece del disegno.**
Nessuno dei tre era un debito di contenuto: erano **tre buchi del disegno**, e
tutti e tre sono chiusi.

| pezzo | diceva questa voce | cosa dicono i dati |
|---|---|---|
| `uprooted` | nessuno lo posa e nessuno lo legge | lo posa **chiunque tolga una presenza** — undici pezzi fra carte, Conseguenze ed Echi (D-130) — e lo rilegge per sapere se è la prima cacciata o la seconda |
| `scar:burned_records` | Cicatrice che nessuna Conseguenza incide | la lascia **l'Archivio che va in rovina**, e ogni Pietra ha la sua: dieci su dieci |
| `ACT_ACQUIRE` | l'unica Azione che nessuno nomina | le danno un valore **tutte e ventisei le vite** delle case |

Il disegno non le vedeva perché sono tre regole che nel dato **non sono un
effetto**: sono conseguenze di un gesto (togliere una presenza), una faccia della
Pietra (`ruin`), un numero sulla carta della casa (`action_values`).

**Legami 4033 → 4232. Pezzi senza nemmeno una freccia: 15 → 12**, e i dodici che
restano sono gli Obiettivi della [120](#120) — quelli sì, contenuto.

<details>
<summary>La voce come era scritta</summary>

`contenuto` · `debito` · aperta in 0.1.347 ([D-380](DECISIONS.md#d-380))

Il disegno del flusso, completato in [D-380](DECISIONS.md#d-380), lascia tre
pezzi **senza nemmeno una freccia** oltre agli Obiettivi della
[120](#120):

| pezzo | cosa manca |
|---|---|
| `uprooted` | nessuno lo posa e nessuno lo legge — mentre `twice_uprooted`, il suo seguito, apre la porta della Diaspora di Nahr |
| `scar:burned_records` | una Cicatrice che nessuna Conseguenza incide e nessuna clausola nomina |
| `ACT_ACQUIRE` | l'unica delle sei Azioni che nessuna carta e nessuna regola del segno nomina |

I primi due li vedrebbe anche il censimento dei segni; il terzo no, ed è il più
strano: **Acquisire è un'Azione della plancia** che nessuna carta modifica,
concede o vieta. O è giusto — è l'azione base, quella che si fa senza carte — e
allora va scritto; o è un buco, e allora ci vuole almeno una regola del segno che
la tocchi.

**Fatto quando** i due segni hanno una penna o escono dal dizionario, e
`ACT_ACQUIRE` ha una riga che dice perché nessuno la nomina.

</details>

---

### 122. Il primo beneficio è gratis, quindi ne esiste uno solo

`regole` · `da-decidere` · aperta in 0.1.350
([D-382](DECISIONS.md#d-382) · [la misura](MISURA_CASELLE.md))

Curare le due caselle della [117](#117) ha fatto vedere una cosa che nessun
numero risolve. L'economia di [D-280](DECISIONS.md#d-280) dice: **1 beneficio è
gratis, ogni altro costa 1 costo**. Al tavolo di cento saghe questo vuol dire
che chi propone prende **quello che vale di più, e basta** — le altre voci non
si comprano quasi mai.

Il risultato è che le caselle non competono per essere utili: competono per
essere **prime**, e a parità vince sempre la stessa.

Si vede in tre mosse consecutive, tutte misurate:

| mossa | effetto voluto | effetto collaterale |
|---|---|---|
| ABBASSA LA DOMANDA da 1 a 3 | 0 → 393 acquisti | COSTRUISCI PIETRA 141 → 23, RAFFREDDA TEMA → 0 |
| scesa a 2 | 127 acquisti, le altre tornano | RAFFREDDA TEMA 22 → 2 |
| RAFFREDDA TEMA legge il rombo | 2 → 115 | ABBASSA LA DOMANDA 127 → 26, MUOVI UN RAPPORTO → 0 (una prova cade) |
| MUOVI UN RAPPORTO da 2 a 3 | 0 → 6 | UNA PIETRA SALE 14 → 2 |

**Ogni casella alzata ne spegne un'altra.** Non è un difetto di taratura: è la
forma dell'economia. Con un solo acquisto gratuito, il numero di caselle vive è
**uno per Consiglio**, e le altre ventitré esistono per quando la prima non si
può comprare.

#### Le tre strade, e la scelta è del committente

- **(a) Va bene così.** Un Consiglio decide una cosa sola, e le altre caselle
  sono il ventaglio fra cui quella cosa cambia da carta a carta. Allora la
  domanda giusta non è *«chi compra questa casella»* ma *«quante caselle
  diverse vengono comprate in un anno»*, ed è un'altra misura.
- **(b) Più di un beneficio gratis.** Due acquisti liberi cambiano il gioco da
  «prendo il massimo» a «costruisco una mossa», e le caselle da 2 tornano vive.
  Costo: il Consiglio diventa più generoso, e il cancello va rimisurato.
- **(c) Il prezzo lo fanno gli avversari.** È la forma piena di
  [D-280](DECISIONS.md#d-280), ancora da costruire (ISSUES 72): il proponente
  compra, gli altri scelgono in che moneta paga. Lì il valore intrinseco conta
  meno, perché la scelta non è più solo sua.

### ✅ Chiusa a metà in 0.1.353: il committente ha dettato la regola ([D-387](DECISIONS.md#d-387))

> *«Chi propone sceglie GRATIS un Beneficio mettendo un token su uno dei
> benefici della carta, gli altri giocatori possono astenersi oppure mettere un
> token su un costo… Anche il proponente può spendere segnalini rivendicare per
> aggiungere benefici.»*

È la strada **(c)**, e più della (c): il prezzo non lo fanno solo gli avversari
— lo **comprano**, spendendo una moneta che si guadagna giocando una carta
Asset dalla sua faccia RIVENDICARE.

| | prima | dopo |
|---|---|---|
| benefici comprati per Consiglio | 1,71 | **1,40** |
| **costi posati dagli avversari, per Consiglio** | **0,09** | **0,68** |
| costi posati in 100 partite | 34 | **217** |

**La metà chiusa:** il proponente adesso spende qualcosa di suo, e gli avversari
scelgono davvero il prezzo — prima ne sceglievano 34 su 364 Consigli, tutto il
resto lo prendeva il mondo dall'alto della lista.

**La metà che resta, ed è il difetto originale di questa voce:** *le caselle
vive per Consiglio non sono salite, sono scese* — da 1,71 a 1,40. Con 2,8 carte
RIVENDICARE giocate per partita, i gettoni bastano per circa **un acquisto in
più per partita**, non per Consiglio. Continua in [ISSUES 125](#125): quanto
deve essere abbondante la moneta.

---

### 123. Nessuna Azione della plancia alza una Pietra, e il Consiglio paga meglio chi tace

`regole` · `da-decidere` · aperta in 0.1.353 ([D-386](DECISIONS.md#d-386))

Scritta la clausola del gesto ([D-386](DECISIONS.md#d-386)), sei obiettivi su
diciassette che rendevano uguale o meglio stando fermi sono diventati tre — e i
tre che restano hanno **una causa sola, misurata contando da dove arriva ogni
gesto firmato** in cento partite:

| gesto e sorgente | tavolo che gioca | tavolo di pietra |
|---|---|---|
| alzare una Pietra **da un'Azione** | **0** | 0 |
| alzare una Pietra da un Consiglio | 136 | **199** |
| alzare una Pietra dal sistema (fine anno) | 129 | 48 |
| posare una presenza da un'Azione | 847 | 0 |
| muovere un legame da un'Azione | 801 | 0 |
| prendere una terra da un'Azione | **2** | 0 |

Due cose, e sono due difetti diversi:

1. **Le Pietre non si alzano col turno.** Delle sei Azioni della plancia —
   ACQUISIRE, MUOVERE, INFLUENZARE, FORGIARE, TRAMARE, RIVENDICARE — nessuna
   costruisce. In cento partite **nessuna** Pietra è salita per mano di
   un'Azione. Chi vuole costruire **deve passare dal Consiglio**, cioè deve
   convincere il tavolo. E la stessa cosa vale quasi per la terra: **due**
   passaggi di controllo su 276 vengono da un'Azione, tutti gli altri da un
   Consiglio.
2. **Il Consiglio è più generoso con chi tace.** 199 Pietre a un tavolo che
   passa a ogni turno, 136 a uno che gioca: le proposte di un tavolo silenzioso
   non le contesta nessuno. È [ISSUES 119](#119) vista dall'altra parte — un
   Consiglio che quasi non cade regala a chi non fa niente.

Insieme vogliono dire: **finché è così, nessun obiettivo di Pietra può premiare
il giocare**, per quanto bene sia scritto. `A_STONE`, `A_WORK` e `MOST_STONE`
restano i tre che rendono uguale o meglio da fermi.

**Le strade, e la scelta è del committente:**

- **(a) Un'Azione che costruisce.** ACQUISIRE è l'unica delle sei che nessuna
  carta modifica ([D-381](DECISIONS.md#d-381)): potrebbe diventare *«prendi una
  carta, oppure alza una Pietra dove hai presenza»*. Costo: cambia la plancia,
  che è il pezzo più stampato del gioco.
- **(b) Le Pietre restano una cosa che si decide insieme**, e allora gli
  obiettivi di Pietra non devono chiedere un gesto — devono chiedere **una
  proposta tua passata**, che è un gesto anche quello e passa dal Consiglio.
  Costo: un quinto gesto nel vocabolario.
- **(c) Si sistema prima [ISSUES 119](#119)**, e questo si rimisura: se un
  Consiglio contestato cade più spesso, il tavolo di pietra smette di essere
  premiato.

**Quanto costa, adesso che si sa.** Chiudendo [ISSUES 68](#68) in 0.1.358
([D-391](DECISIONS.md#d-391)) il residuo è finito qui: l'**84,0%** dei turni
«passa» — il **40,0% di tutti i turni**, 2.878 su 7.200 — è *«nessuna mossa gli
serviva»*, e chi passa ha **22,1 mosse legali e 4,4 carte in mano**. Non gli
manca cosa fare: gli manca il motivo. **Quaranta turni su cento sono il prezzo
di questa decisione non presa**, ed è il numero più grosso che una scelta del
committente può muovere oggi.

**Fatto quando** il committente sceglie, o quando 119 è chiusa e questa misura
si rifà con lei.

---

### 124. Due case su otto non possono prendere l'Eredità, mai

`contenuto` · `da-decidere` · aperta in 0.1.353 ([D-385](DECISIONS.md#d-385))

Scritta l'Eredità — *+3 per ogni leggenda che porta il tuo nome* — la sonda dice
quanto rende, casa per casa, su 24 saghe:

| casa | Eredità media per saga |
|---|---|
| Le Libere Città | **8,00** |
| La Compagnia del Sale | 4,38 |
| Lyra | 4,25 |
| Re Aldric · Il Vetro | 3,00 |
| Le Custodi della Cenere | 2,75 |
| **La Diaspora di Nahr · Vaerax** | **0,00** |

Non è come giocano: è **cosa hanno dichiarato di voler lasciare**. La sonda lo
mostra desiderio per desiderio, e i due modi di prendere zero sono diversi:

- **un segno di Regione non diventa mai leggenda.** `settlement:village`,
  `nomad_range`, `structure:sealed`, `place:sleeping_site`, `structure:archive`,
  `structure:granary`, `structure:road`, `structure:tollgate` — otto desideri su
  trentadue: zero fatti globali, zero leggende. Solo un fatto del mondo
  sbiadisce in `legend:` ([D-075](DECISIONS.md#d-075)).
- **un fatto murato non diventa mai leggenda.** `ledger_public` è vero a fine
  saga **24 volte su 24** e leggenda **zero**; `nahr_settled` 12 e zero;
  `crown_divided` 10 e zero; `mine_sealed` 7 e zero. Sono gli `enduring_facts`
  della Chronicle: cose che il mondo tiene per vere per sempre. E **una cosa che
  *è ancora* non è una cosa di cui *si racconta ancora*** — il che, letto come
  regola, è giusto.

**Le strade:**

- **(a) È giusto così**, e le due case hanno bisogno di un'altra moneta: è
  [ISSUES 76](#76-il-consiglio-decide-con-una-moneta-che-i-destini-non-spendono)
  un'altra volta.
- **(b) Si cambiano i desideri** di Nahr e Vaerax perché almeno due su quattro
  siano fatti globali che possono sbiadire. Costo: cambia **chi sono** quelle
  due case, che è contenuto d'autore.
- **(c) L'Eredità paga anche il fatto murato**, a metà (+1 invece di +3). Costo:
  è premiare la durata con un altro nome, cioè esattamente quello che
  [D-299](DECISIONS.md#d-299) ha scartato.

**Fatto quando** il committente sceglie.

---

### 125. La moneta del Consiglio è troppo poca perché una proposta sia una mossa

`regole` · `da-decidere` · aperta in 0.1.353 ([D-387](DECISIONS.md#d-387))

Scritti i gettoni di rivendicazione, l'economia del Consiglio funziona come il
committente l'ha dettata — ma **le caselle vive per Consiglio sono scese**, non
salite, ed è il difetto che [ISSUES 122](#122) voleva togliere.

| | prima | dopo |
|---|---|---|
| benefici comprati per Consiglio | 1,71 | **1,40** |
| costi posati dagli avversari, per Consiglio | 0,09 | **0,68** |
| COSTRUISCI PIETRA, comprata | 143 | 89 |
| POSA UN SEGNO SU UNA CASATA | 6 | **3** |
| UNA PIETRA SALE | 2 | **0** |

Il conto è semplice: **RIVENDICARE si gioca 2,8 volte per partita**, e i
Consigli in una partita sono **tre**. Quindi i gettoni bastano per circa un
acquisto in più *per partita*, non per Consiglio — e quello che si compra resta
la casella che vale di più, come prima.

**Le strade, e sono tutte misurabili in mezz'ora:**

- **(a) Più carte con la faccia RIVENDICARE.** Oggi sono nove su quarantotto.
  Portarle a quindici raddoppia quasi la moneta senza toccare nessuna regola.
- **(b) Anche l'Azione della plancia dà il gettone**, non solo la carta. Oggi
  lo dà solo la carta, perché è quello che il committente ha scritto; RIVENDICARE
  come Azione apre un diritto che in cinquanta partite moriva inutilizzato 131
  volte su 140.
- **(c) Il gettone si guadagna perdendo.** Chi si oppone e la proposta passa
  lo stesso prende un gettone per il Consiglio dopo: la sconfitta diventa
  moneta, e la banda del fallimento smette di essere vuota — che è anche una
  risposta a [ISSUES 119](#119).
- **(d) Va bene così**, e un Consiglio decide **una cosa sola**: allora le
  ventitré caselle che restano sono il ventaglio da cui quella cosa cambia da
  carta a carta, e la misura giusta è *quante caselle diverse un tavolo vede in
  una campagna* — oggi **16 su 32** in cento partite.

**Fatto quando** il committente sceglie, e la sonda delle caselle mostra i
benefici per Consiglio muoversi nella direzione scelta.

---

### 126. ✅ Si prenota 285 volte e si spende 12 — CHIUSA in 0.1.370: adesso si prenota 7 volte

`regole` · **gialla G6 dalla 0.1.361** ([la lista](LE_TUE_DECISIONI.md)): la
regola l'hai gia' dettata, quello che resta e' taratura del cervello ed e' mia ·
aperta in 0.1.355 ([D-389](DECISIONS.md#d-389))

> **La condizione era: «le prenotazioni mai spese scendono sotto un terzo».**
> Erano **273 su 285**; adesso sono **4 su 7**
> ([D-402](DECISIONS.md#d-402)).
>
> **Ed era la prima lettura, il cervello — ma non dove la voce la cercava.**
> La policy deliberata aveva gia' la sua guardia da D-191. Le prenotazioni
> venivano quasi tutte dal **ripiego** — «gioca quello che la mano permette»
> (D-285) — che per il RIVENDICARE offriva **un modo solo, CREATE**: sapeva
> prenotare e non sapeva prendere la parola.
>
> | cento partite | prima | dopo |
> |---|---|---|
> | prenotazioni aperte | 285 | **7** |
> | prenotazioni mai spese | 273 | **4** |
> | Consigli strappati | 74 | **210** |
> | Consigli per anno | 3,18 | **3,58** |
> | Verita' scritte | 132 | **142** |
>
> **E il costo, che sembrava esserci e non c'e'.** I turni «passa» salgono da
> 47,6% a 49,6%, e a prima vista e' un peggioramento. Non lo e', ed e' il conto
> che lo dice: **una prenotazione che non si spendera' mai non e' un turno in
> cui e' successo qualcosa.** Contandole per quello che sono —
>
> | | passa | + prenotazioni morte | turni in cui non succede niente |
> |---|---|---|---|
> | prima | 3.428 | 273 | **3.701 — 51,4%** |
> | dopo | 3.572 | 4 | **3.576 — 49,7%** |
>
> — il numero **scende**. La prova sta nella cura a meta': togliendo la
> prenotazione **senza** dare al ripiego la presa di parola, i «passa» vanno a
> **51,6%**, cioe' esattamente dove erano gia', in chiaro.
>
> **Cancello 0 su 8** sui due tavoli, suite verde.


Chiudendo [ISSUES 53](#53) è uscito un numero che nessuno aveva mai guardato
dalla parte giusta.

| su 100 partite | |
|---|---|
| prenotazioni aperte (`ACT_CLAIM` in CREATE) | **285** |
| **prenotazioni mai spese** | **273** |
| Consigli strappati | 74 |
| di cui usavano una prenotazione | **12** |

**Il RIVENDICARE rende**: settantaquattro volte su cento partite porta al tavolo
una seconda domanda o una controproposta. Quello che quasi non serve mai è la
sua **prima metà**.

[D-191](DECISIONS.md#d-191) ha scritto la prenotazione per un caso preciso —
*«la domanda che non è ancora matura e che ci si vuole accaparrare prima che lo
diventi»* — e ha reso il caso opposto una mossa sola: su una domanda già matura,
prendere la parola non costa una prenotazione. Il cervello prenota **285 volte**
e la spende **12**: le altre 273 volte ha speso un'Azione e una carta AUTORITÀ
per un diritto che poi non gli serviva.

**Due letture, e sono diverse:**

- **è il cervello.** La policy prenota per abitudine invece che sulle domande
  ancora basse. Allora è taratura di `policy_decider`, ed è mia: si misura con
  `run_rung_probe`, e il numero da far scendere è 273.
- **è la regola.** Se prenotare conviene solo su una domanda che non è ancora
  matura, e il tavolo non arriva quasi mai in quella situazione, la prenotazione
  è **cartone che non si usa**: due Azioni per una cosa che se ne prende una.
  Allora la scelta è del committente, e la strada è togliere il CREATE e
  lasciare solo il FORCE — un'Azione, un Consiglio.

**Fatto quando** le prenotazioni mai spese scendono sotto un terzo, oppure il
committente decide che la prenotazione esce dal gioco.

---

### 127. La tessera si gira, e l'arte si gira con lei

`arte` · `da-decidere` · aperta in 0.1.357 ([D-390](DECISIONS.md#d-390)) ·
**la scelta è diventata più facile in 0.1.360** ([D-393](DECISIONS.md#d-393))

La regola dei varchi ([D-390](DECISIONS.md#d-390)) si posa **girando la
tessera**: si prova il quarto di giro finché un varco combacia con quello della
tessera accanto. È la cosa che rende la promessa — *«nessuna tessera isolata»* —
vera per costruzione: **0 pose non connesse su 151.200**, enumerate.

> **Aggiornamento 0.1.360.** Allargati i varchi a trentotto lati su quaranta
> (D-393), la **strada 2 costa quasi niente**: nove tessere su dieci sono croci
> e si disegnano con la strada che tocca tutti e quattro i bordi, senza nessun
> gettone sopra. Il gettone «passo franato» servirebbe **su una tessera sola**,
> l'Isola Muta, e su due lati. Se scegli la 2, l'arte non gira mai e il costo è
> un segnalino che si posa una volta a partita, quando l'Isola esce.

Ma una tessera girata di novanta gradi ha **l'illustrazione girata**. Per un
dipinto dall'alto è normale — è quello che fa mezzo scaffale di giochi di
tessere — e il prompt d'arte dice già *«Readable terrain silhouette from above»*
e *«no compass rose»*, cioè è disegnata apposta per non avere un sopra. Ma è una
scelta d'autore, e non è mia.

**Le tre strade:**

1. **Va bene così.** La tessera si gira, l'arte è pensata per reggerlo, e la
   posa resta una regola che una persona esegue in dieci secondi.
2. **Quattro varchi disegnati, alcuni chiusi da un segnalino.** Ogni tessera si
   illustra con la strada che arriva a tutti e quattro i bordi, e i lati chiusi
   si coprono con un gettone «passo franato» quando la tessera entra in gioco.
   L'arte non gira mai. Costo: un tipo di segnalino in più, e una posa in più
   da fare a mano.
3. **Niente rotazione.** La tessera si posa dritta. Costo misurato: senza il
   giro **la posa non può garantire la connessione** — due corridoi N/S nella
   stessa riga non si toccheranno mai — e qualche pesca resterebbe con meno di
   sei tessere sul tavolo.

**Fatto quando** il committente sceglie, e — se non è la (1) — la misura delle
200 mappe si rifà con la regola nuova.
