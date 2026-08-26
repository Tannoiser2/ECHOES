# Le tre misure che vengono prima della matrice

Generato da `tools/matrix_survey.py` — non si scrive a mano.

Le tre domande che il committente ha messo ai punti 8, 9 e 10 del suo
piano, misurate sui dati di oggi **prima** di scrivere un file nuovo.

| | |
|---|---|
| segni nel dizionario | 183 |
| di cui qualcuno scrive | 150 |
| orfani in tutto | 63 |
| **di cui senza una ragione scritta** | **13** |
| livelli di Destino (minimo/vittoria/trionfo) | 69 |
| **clausole impossibili** (chiedono un segno che niente scrive) | **0** |
| **livelli che si reggono solo su conteggi** | **33** |
| Tensioni | 60 |
| **Tensioni che non toccano nessun segno nominato da un Destino** | **35** |
| segni che l'eredita' porta avanti | 49 |
| profili strategici scritti | 4 |
| segni che quelle case vogliono o temono | 35 |
| **fra i voluti, quelli che un Consiglio sa dare** | **4** |
| segni che aiutano una casa e ne danneggiano un'altra | 7 |
| **coppie di case che hanno qualcosa per cui litigare** | **3 su 28** |

---

## 1. I segni orfani

Un segno e' orfano se **qualcuno lo scrive** e poi nessuna Entita' lo
desidera o lo teme (Destini **e** obiettivi), nessuna Tensione lo mette
o lo toglie, e nessuna regola del segno lo usa: si posa sul tavolo e non
entra in nessuna partita.

Non tutti gli orfani sono un difetto: **50 su 63 portano gia' la loro
ragione scritta** nel dizionario — memorie narrate (D-103), etichette di
famiglia, gradi di pietra, domini che legge il motore. Restano fuori
quelli **senza una riga che spieghi perche' esistono**: sono questi che
la matrice deve prendere per primi.

### Orfani senza una ragione scritta: 13

| segno | categoria | chi lo scrive |
|---|---|---|
| `account_settled` | MEMORY | Conseguenza |
| `betrayal_spoken` | MEMORY | Azione stampata, carta Echo |
| `capital` | FUNCTION | tessera |
| `condition:lean` | STATE | Conseguenza, carta Echo |
| `condition:requisitioned` | STATE | Conseguenza |
| `crystal_site` | PLACE | tessera |
| `parley_held` | MEMORY | carta Echo |
| `petition_heard` | MEMORY | carta Echo |
| `structure:castle` | FUNCTION | Pietra |
| `structure:library` | FUNCTION | Pietra |
| `structure:palace` | FUNCTION | Pietra |
| `trade` | FUNCTION | tessera |
| `wild` | PLACE | tessera |

### Orfani dichiarati: 50

| segno | la ragione che porta scritta |
|---|---|
| `ancient` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `ash` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `burden_shared` | memoria del mondo: narrata (D-103), ereditata |
| `discovery:legend` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:shared_record` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:supervised_record` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:the_charter` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:the_ledger` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:the_measure` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:the_omen` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:trade_ledger` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `discovery:written_law` | il motore la conta (discovery_count) oltre a chi la legge per nome |
| `domain:ANCIENT` | il dominio della Regione: lo legge il motore per decidere quale Tensione guarda quale posto |
| `domain:RESOURCE` | il dominio della Regione: lo legge il motore per decidere quale Tensione guarda quale posto |
| `domain:SURVIVAL` | il dominio della Regione: lo legge il motore per decidere quale Tensione guarda quale posto |
| `domain:TERRITORY` | il dominio della Regione: lo legge il motore per decidere quale Tensione guarda quale posto |
| `dragon_slain` | memoria del mondo: narrata (D-103), ereditata |
| `forest` | tessera nuova di PZ-2 (D-265). Non e' la pietra STR_FOREST: come per #granaio, la vocazione del luogo e l'opera si stamp |
| `free_cities` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `granary` | vocazione del luogo, stampata sulla Regione: non e' la pietra structure:granary, ma le carte stampano #granaio per entra |
| `guild` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `harbor` | vocazione della tessera nuova di PZ-2 (D-265): dove il mare concede e fa pagare |
| `hard_bargain` | marchio di memoria (D-278): ha ottenuto cedendo poco, e il tavolo se lo ricorda — il motore non lo interroga |
| `heir_named` | vive sia sulla casa (entry_tag della successione) sia sul mondo (fatto ricordato) |
| `island` | tessera nuova di PZ-2 (D-265): il posto che si raggiunge solo volendo |
| `legend:debt_called` | la forma postuma di un fatto: la scrive il motore quando la memoria sfuma |
| `legend:oath_broken` | la forma postuma di un fatto: la scrive il motore quando la memoria sfuma |
| `legend:order_restored` | la forma postuma di un fatto: la scrive il motore quando la memoria sfuma |
| `list_witnessed` | memoria del mondo: narrata (D-103), ereditata |
| `marsh` | tessera nuova di PZ-2 (D-265): acqua ferma, canali vecchi, febbri |
| `migrating` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `mine` | vocazione del luogo, stampata sulla Regione (D-262): il posto dove si scava, che le Conseguenze nominano col segno invec |
| `order` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `place:collapsed_pass` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:dry_spring` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:low_spring` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:pass` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:stripped_site` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `place:thinned_wood` | grado di pietra sulla mappa: oggi nessuna regola lo legge — colore dichiarato, in fila per un lettore (ISSUES 24) |
| `price_in_lives` | memoria del mondo (D-278): una decisione passata al prezzo di qualcuno che non c'e' piu' — si legge al centro del tavolo |
| `return_promised` | memoria del mondo: narrata (D-103), ereditata |
| `rumour_running` | memoria del mondo (D-278): fuori dalla sala la versione e' gia' un'altra — si legge al centro del tavolo |
| `scar:divided_seal` | il dente vivo e' crown_divided, letto dai Destini e sciolto da CNS_CROWN_REUNITED |
| `scholar` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `settlement:$proponent` | porta un id dinamico: chi vive li' e' scritto nel segno stesso |
| `sleeping` | era etichetta di famiglia muta; da D-262 la legge la grammatica adattiva ($entity_with e requires_entity_tag): dice chi  |
| `someone_paid` | memoria del mondo: narrata (D-103), ereditata |
| `spoke_and_lost` | marchio di memoria (D-278): ha proposto e la proposta e' caduta — si legge sulla carta del casato |
| `took_by_hand` | marchio di memoria (D-278): non ha aspettato la decisione, ha preso — si legge sulla carta del casato |
| `watched` | marchio di memoria (D-278): chi ha imposto la guardia se lo porta addosso, e si legge sulla carta del casato — il motore |

## 2. Gli obiettivi che non si possono puntare col dito

Due difetti diversi. Il primo e' grave: una clausola chiede un segno che
**niente scrive**, e allora quel livello non si puo' raggiungere. Il
secondo e' di leggibilita': un livello che non nomina nessun segno e si
regge su conteggi — si verifica, ma al tavolo non si puo' indicare.

**Clausole impossibili: 0**

**Livelli che si reggono solo su conteggi: 33 su 69**

| Destino | livello | clausole | come si legge |
|---|---|---|---|
| DST_ALDRIC | minimum | 2 | Il trono regge |
| DST_ALDRIC | victory | 2 | Il regno decide |
| DST_NAHR | minimum | 2 | Il popolo sopravvive |
| DST_LYRA | minimum | 2 | Ha capito qualcosa |
| DST_VAERAX | minimum | 2 | La montagna è ancora sua |
| DST_ALDRIC_RECORD | minimum | 2 | La casa siede ancora |
| DST_NAHR_ROOTED | minimum | 1 | Il popolo è ancora qui |
| DST_NAHR_ROOTED | victory | 4 | La terra risponde a chi la lavora |
| DST_LYRA_TAUGHT | minimum | 1 | Qualcuno sa ancora leggere le carte |
| DST_VAERAX_WATCHED | minimum | 1 | La montagna è ancora sua |
| DST_SALE | minimum | 2 | La Gilda è ancora al tavolo |
| DST_SALE_OPEN | minimum | 1 | La Gilda esiste ancora |
| DST_VETRO | minimum | 2 | L'Ordine tiene la sua casa |
| DST_VETRO_SHOWN | minimum | 2 | L'Ordine tiene la sua casa |
| DST_CENERE | minimum | 1 | Restano sulla montagna |
| DST_CENERE_DEEP | minimum | 2 | Non hanno lasciato la montagna |
| DST_CENERE_DEEP | triumph | 5 | E non devono più niente a nessuno |
| DST_LIBERE | minimum | 2 | Le città esistono ancora |
| DST_LIBERE_WATER | minimum | 1 | Le città esistono ancora |
| DST_SHARED_RENOWN | minimum | 1 | La casa è ancora al tavolo |
| DST_SHARED_LAND | minimum | 1 | Un posto che risponde |
| DST_SHARED_LAND | victory | 2 | La terra risponde, e non importa come |
| DST_SHARED_LAND | triumph | 1 | La mappa parla la tua lingua |
| DST_SHARED_ACCOUNTS | minimum | 1 | La casa è ancora al tavolo |
| DST_SHARED_QUIET | minimum | 1 | Tre questioni tenute giù |
| DST_SHARED_QUIET | victory | 2 | La quiete si vede |
| DST_SHARED_QUIET | triumph | 2 | La quiete non capita: si tiene |
| DST_SHARED_LORE | minimum | 1 | Una cosa vista |
| DST_SHARED_LORE | victory | 2 | E un posto dove custodirla |
| DST_SHARED_LORE | triumph | 1 | Quello che sai lo sanno da te |
| DST_SHARED_HAND | minimum | 1 | Le mani non vuote |
| DST_SHARED_HAND | victory | 2 | Le riserve che diventano forma |
| DST_SHARED_HAND | triumph | 1 | Quando gli altri chiedono, tu hai |

## 4. Quanto di quello che una casa vuole, il tavolo sa darlo

I profili strategici (`data/design_matrix`) dicono cosa una casa vuole
lasciare nel mondo. Qui si chiede se il tavolo abbia i mezzi: **chi puo'
dare quel segno** — un Consiglio vinto, una carta calata, una
Conseguenza — e chi puo' infliggere quello che teme. Una casa che vuole
cose che nessuno sa dare non ha una strategia: ha un desiderio.

### ENT_ALDRIC

> Un regno che, quando lui non ci sara' piu', si sappia ancora a chi obbedisce.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `succession_by_law` | no | **si'** | Conseguenza, fatto che dura |
| vuole | `crowned` | no | no | casato |
| vuole | `structure:granary` | **si'** | no | Pietra |
| vuole | `order_restored` | no | no | Conseguenza |
| teme | `crown_divided` | no | no | Conseguenza, fatto che dura |
| teme | `condition:unrest` | **si'** | **si'** | Conseguenza, Risonanza, carta Asset, carta Echo |
| teme | `condition:starving` | no | **si'** | Conseguenza, Risonanza, carta Echo |
| teme | `question_unresolved` | no | no | Conseguenza |
| teme | `scar:changed_hands` | **si'** | no | Conseguenza |

### ENT_LYRA

> Che quello che ha capito resti scritto dove chiunque possa rileggerlo, anche chi non le crede.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `discovery:crystal` | no | **si'** | Conseguenza |
| vuole | `knowledge_shared` | no | **si'** | clausola di Consiglio |
| vuole | `crystal_measured` | no | **si'** | carta Echo |
| vuole | `structure:archive` | **si'** | no | Pietra |
| teme | `mine_sealed` | no | no | Conseguenza, fatto che dura |
| teme | `study_supervised` | no | no | Conseguenza |
| teme | `condition:guarded` | **si'** | no | Conseguenza |
| teme | `scar:unanswered` | **si'** | no | Conseguenza |

### ENT_NAHR

> Fermarsi da qualche parte senza smettere di poter andare via.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `nahr_settled` | no | no | Conseguenza, fatto che dura |
| vuole | `settlement:village` | **si'** | **si'** | Pietra |
| vuole | `nomad_range` | no | no | tessera |
| vuole | `crown_divided` | no | no | Conseguenza, fatto che dura |
| teme | `valley_sealed` | no | no | Conseguenza, fatto che dura |
| teme | `scar:sealed_border` | **si'** | no | Conseguenza |
| teme | `condition:emptied` | **si'** | **si'** | Conseguenza, carta Echo |
| teme | `condition:cut_off` | **si'** | **si'** | Conseguenza, carta Asset, carta Echo |
| teme | `condition:guarded` | **si'** | no | Conseguenza |

### ENT_VAERAX

> Che la montagna torni un posto dove non si va, e che nessuno ricordi bene perche'.

| | segno | dal Consiglio | da una carta | altrimenti |
|---|---|---|---|---|
| vuole | `mine_sealed` | no | no | Conseguenza, fatto che dura |
| vuole | `structure:sealed` | no | no | Conseguenza |
| vuole | `mountain_forgotten` | no | no | catena delle ere |
| vuole | `place:sleeping_site` | **si'** | no | Pietra |
| teme | `crystal_exploited` | no | **si'** | Conseguenza |
| teme | `discovery:crystal` | no | **si'** | Conseguenza |
| teme | `condition:exploited` | **si'** | no | Conseguenza, Risonanza |
| teme | `knowledge_shared` | no | **si'** | clausola di Consiglio |
| teme | `condition:unrest` | **si'** | **si'** | Conseguenza, Risonanza, carta Asset, carta Echo |

## 3. Le Tensioni che non incontrano nessun Destino

Una Tensione ha conflitto se **aiuta qualcuno e minaccia qualcun altro**:
aiuta chi vede sparire un segno che teme o comparire uno che vuole,
minaccia chi vede il contrario. Senza conflitto, al Consiglio nessuno
avrebbe una ragione per opporsi.

**E qui c'e' il numero che vale il viaggio.** Tutte e 60 le Tensioni
hanno un conflitto *strutturale* — la loro faccia alza una Pietra e
incide una Cicatrice, e i Destini contano l'una e l'altra — ma quel
conflitto e' **identico su tutte**: e' il modello della faccia (D-280),
non e' contenuto. Il conflitto che distingue una questione dall'altra e'
quello **nominato**, e li' il conto e' **35 su 60**.

**Il conto e' un pavimento**: guarda i segni che la faccia della carta
posa e toglie, non il controllo, non il Calore, non chi ci guadagna in
voti. Una Tensione che compare qui e' certamente muta; una che non
compare non e' certamente viva. La colonna **la guarda** conta le case
il cui Destino dichiara di osservare uno dei suoi segni (`observes`,
D-270): un interesse c'e', ma non e' ancora un conflitto.

| Tensione | aiuta | minaccia | la guarda |
|---|---|---|---|
| TEN_BAD_GRAIN | 9 | 8 | 2 |
| TEN_BLACK_TOLLS | 9 | 8 | 1 |
| TEN_BOUNDARY_STONES | 9 | 8 | 2 |
| TEN_BURIALS | 9 | 8 | 2 |
| TEN_DEEP_WATER | 9 | 8 | 1 |
| TEN_EMPTY_NETS | 9 | 8 | 2 |
| TEN_ENCLOSURE | 9 | 8 | 2 |
| TEN_FALLOW | 9 | 8 | 2 |
| TEN_FAMINE | 9 | 8 | 2 |
| TEN_GUILD_WAR | 9 | 8 | 1 |
| TEN_LAND_REGISTER | 9 | 8 | 2 |
| TEN_MARCHES | 9 | 8 | 2 |
| TEN_MARSH_FEVER | 9 | 8 | 2 |
| TEN_NAMELESS | 9 | 8 | 3 |
| TEN_OLD_CHANNELS | 9 | 8 | 1 |
| TEN_PASTURE | 9 | 8 | 3 |
| TEN_PILGRIMS | 9 | 8 | 2 |
| TEN_PLAGUE | 9 | 8 | 3 |
| TEN_QUARANTINE | 9 | 8 | 1 |
| TEN_REGENCY | 9 | 8 | 2 |
| TEN_RELIC | 9 | 8 | 2 |
| TEN_ROADS | 9 | 8 | 1 |
| TEN_SANCTUARY | 9 | 8 | 2 |
| TEN_SEALS | 9 | 8 | 2 |
| TEN_SILTED_CANALS | 9 | 8 | 2 |
| TEN_SMUGGLING | 9 | 8 | 2 |
| TEN_SUCCESSION | 9 | 8 | 2 |
| TEN_THIRST | 9 | 8 | 2 |
| TEN_TITHE | 9 | 8 | 1 |
| TEN_UNEARTHED | 9 | 8 | 2 |
| TEN_WARD_STONES | 9 | 8 | 2 |
| TEN_WATER | 9 | 8 | 2 |
| TEN_WEIGHTS | 9 | 8 | 2 |
| TEN_WINTER | 9 | 8 | 1 |
| TEN_WOLVES | 9 | 8 | 1 |

## 5. Gli incroci: chi litiga con chi, e per cosa

*«Gli stessi segni devono trasformare piu' Entita' in direzioni
diverse»* — la linea delle trasformazioni. Qui si misura sui dati di
oggi: per ogni segno, **chi aiuta** e **chi danneggia**, mettendo
insieme quello che i Destini chiedono e quello che i profili
dichiarano. Un segno che aiuta qualcuno e non danneggia nessuno non e'
una questione: e' un regalo, e al Consiglio nessuno avra' mai una
ragione per opporsi.

**Segni che incrociano davvero: 7.**

**Il conto e' un pavimento**, come quello delle Tensioni: guarda i
segni **nominati** da un Destino o da un profilo, non i conteggi. Un
Destino che chiede due Pietre o zero Cicatrici entra in conflitto con
mezzo tavolo senza nominare niente — ma quel conflitto vale per tutti
allo stesso modo, e quindi non distingue una coppia dall'altra. Qui
interessa **cosa fa litigare queste due case e non altre**.

La colonna **cambia pelle** dice se quel segno e' fra quelli che una
porta del tempo legge (D-290): perderlo non sposta una clausola, sposta
**cosa quella casa diventera'**.

| segno | aiuta | danneggia | cambia pelle | chi lo sa scrivere |
|---|---|---|---|---|
| `crown_divided` | NAHR | ALDRIC | **si'** | Conseguenza, fatto che dura |
| `discovery:crystal` | LYRA | VAERAX | **si'** | Azione stampata, Conseguenza |
| `knowledge_shared` | LYRA | VAERAX | **si'** | Azione stampata, clausola di Consiglio |
| `mine_sealed` | VAERAX | LYRA | — | Conseguenza, fatto che dura |
| `nahr_settled` | NAHR | ALDRIC | **si'** | Conseguenza, fatto che dura |
| `structure:sealed` | VAERAX | CENERE | — | Conseguenza |
| `succession_by_law` | ALDRIC | NAHR | **si'** | Azione stampata, Conseguenza, fatto che dura |

### Le coppie che non hanno niente per cui litigare

Il controllo che la linea delle trasformazioni chiede: **due case
devono condividere almeno un segno che le spinge in direzioni
opposte**. Le coppie che non ce l'hanno possono sedere allo stesso
tavolo per otto anni senza incontrarsi mai.

**Coppie incrociate: 3 su 28.**

La causa si legge nella tabella qui sopra: **gli incroci esistono
quasi solo fra le case che hanno un profilo**. Le altre — CENERE, LIBERE, SALE, VETRO —
entrano solo dove un loro Destino nomina un segno per nome, e i
Destini nominano poco: 33 livelli su 69 si reggono su conteggi.
Scrivere i quattro profili che mancano (ISSUES 79) e' la leva piu'
corta su questo numero.

| coppia | |
|---|---|
| ALDRIC ↔ CENERE | niente |
| ALDRIC ↔ LIBERE | niente |
| ALDRIC ↔ LYRA | niente |
| ALDRIC ↔ SALE | niente |
| ALDRIC ↔ VAERAX | niente |
| ALDRIC ↔ VETRO | niente |
| CENERE ↔ LIBERE | niente |
| CENERE ↔ LYRA | niente |
| CENERE ↔ NAHR | niente |
| CENERE ↔ SALE | niente |
| CENERE ↔ VETRO | niente |
| LIBERE ↔ LYRA | niente |
| LIBERE ↔ NAHR | niente |
| LIBERE ↔ SALE | niente |
| LIBERE ↔ VAERAX | niente |
| LIBERE ↔ VETRO | niente |
| LYRA ↔ NAHR | niente |
| LYRA ↔ SALE | niente |
| LYRA ↔ VETRO | niente |
| NAHR ↔ SALE | niente |
| NAHR ↔ VAERAX | niente |
| NAHR ↔ VETRO | niente |
| SALE ↔ VAERAX | niente |
| SALE ↔ VETRO | niente |
| VAERAX ↔ VETRO | niente |

### Quante questioni ha ogni coppia

| coppia | segni condivisi | quali |
|---|---|---|
| ALDRIC ↔ NAHR | 3 | `crown_divided`, `nahr_settled`, `succession_by_law` |
| LYRA ↔ VAERAX | 3 | `discovery:crystal`, `knowledge_shared`, `mine_sealed` |
| CENERE ↔ VAERAX | 1 | `structure:sealed` |

