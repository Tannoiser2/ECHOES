# Le tre misure che vengono prima della matrice

Generato da `tools/matrix_survey.py` — non si scrive a mano.

Le tre domande che il committente ha messo ai punti 8, 9 e 10 del suo
piano, misurate sui dati di oggi **prima** di scrivere un file nuovo.

| | |
|---|---|
| segni nel dizionario | 183 |
| di cui qualcuno scrive | 150 |
| orfani in tutto | 67 |
| **di cui senza una ragione scritta** | **15** |
| livelli di Destino (minimo/vittoria/trionfo) | 69 |
| **clausole impossibili** (chiedono un segno che niente scrive) | **0** |
| **livelli che si reggono solo su conteggi** | **33** |
| Tensioni | 60 |
| **Tensioni che non toccano nessun segno nominato da un Destino** | **35** |
| segni che l'eredita' porta avanti | 49 |

---

## 1. I segni orfani

Un segno e' orfano se **qualcuno lo scrive** e poi nessuna Entita' lo
desidera o lo teme (Destini **e** obiettivi), nessuna Tensione lo mette
o lo toglie, e nessuna regola del segno lo usa: si posa sul tavolo e non
entra in nessuna partita.

Non tutti gli orfani sono un difetto: **52 su 67 portano gia' la loro
ragione scritta** nel dizionario — memorie narrate (D-103), etichette di
famiglia, gradi di pietra, domini che legge il motore. Restano fuori
quelli **senza una riga che spieghi perche' esistono**: sono questi che
la matrice deve prendere per primi.

### Orfani senza una ragione scritta: 15

| segno | categoria | chi lo scrive |
|---|---|---|
| `account_settled` | MEMORY | Conseguenza |
| `betrayal_spoken` | MEMORY | Azione stampata, carta Echo |
| `capital` | FUNCTION | tessera |
| `condition:lean` | STATE | Conseguenza, carta Echo |
| `condition:requisitioned` | STATE | Conseguenza |
| `crowned` | ENTITY | casato |
| `crystal_site` | PLACE | tessera |
| `nomad_range` | PLACE | tessera |
| `parley_held` | MEMORY | carta Echo |
| `petition_heard` | MEMORY | carta Echo |
| `structure:castle` | FUNCTION | Pietra |
| `structure:library` | FUNCTION | Pietra |
| `structure:palace` | FUNCTION | Pietra |
| `trade` | FUNCTION | tessera |
| `wild` | PLACE | tessera |

### Orfani dichiarati: 52

| segno | la ragione che porta scritta |
|---|---|
| `ancient` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `ash` | etichetta di famiglia: dice chi sei, non cosa puoi fare, e nessuna regola deve leggerla |
| `burden_shared` | memoria del mondo: narrata (D-103), ereditata |
| `discovery:crystal` | il motore la conta (discovery_count) oltre a chi la legge per nome |
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
| `order_restored` | vita postuma: vive nella sua forma legend: |
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

