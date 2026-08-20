# ECHOES - Asset Manifest

<!-- GENERATED FILE - regenerate with `python3 tools/build_manifest.py`. -->

Every visual element the Chronicle needs, taken straight from `godot/data`.
`art_prompt_key` is the lookup into the Master Prompts in
[ART_BIBLE.md](ART_BIBLE.md). The fiducial markers for the physical table
(spec §19.5) enter the data model with the 0.5 prototype that reads them
(ISSUES 11, D-091).

§19.4 asks for 48 Assets, 24 Echo cards, 12 Region tiles, 24 map overlays and 12
standees. The Assets and the Echo cards are there; the tiles, the overlays and
the standees are art, and they are 0.2's problem.

The Asset deck reads off the rarity: COMMON is strength 1 and 4 copies, UNCOMMON
strength 2 and 2 copies, RARE strength 3 and a single copy. Eight cards per
family, 22 copies per family deck, 132 cards in the box (D-040).

## Asset cards (48)
| id | titolo | famiglia | forza | rarita | copie | scarto | art_prompt_key |
|---|---|---|---|---|---|---|---|
| AST_AUTHORITY_INTERDICT | Interdetto | AUTHORITY | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.authority.interdict` |
| AST_AUTHORITY_SUCCESSION_ACT | Atto di Successione | AUTHORITY | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.authority.succession_act` |
| AST_AUTHORITY_CROWN_RIGHT | Diritto di Corona | AUTHORITY | 2 | UNCOMMON | 2 | ALWAYS_DISCARD | `asset.authority.crown_right` |
| AST_AUTHORITY_MAGISTRATE | Magistrato | AUTHORITY | 2 | UNCOMMON | 2 | RETAIN_ON_SUCCESS | `asset.authority.magistrate` |
| AST_AUTHORITY_CENSUS | Censimento | AUTHORITY | 1 | COMMON | 4 | DISCARD | `asset.authority.census` |
| AST_AUTHORITY_EDICT | Editto | AUTHORITY | 1 | COMMON | 4 | DISCARD | `asset.authority.edict` |
| AST_AUTHORITY_INVESTITURE | Investitura | AUTHORITY | 1 | COMMON | 4 | ALWAYS_DISCARD | `asset.authority.investiture` |
| AST_AUTHORITY_SEAL | Sigillo | AUTHORITY | 1 | COMMON | 4 | DISCARD | `asset.authority.seal` |
| AST_BONDS_BROKEN_PACT | Patto Rotto | BONDS | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.bonds.broken_pact` |
| AST_BONDS_HOSTAGE | Ostaggio | BONDS | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.bonds.hostage` |
| AST_BONDS_BETROTHAL | Promessa di Nozze | BONDS | 2 | UNCOMMON | 2 | ALWAYS_DISCARD | `asset.bonds.betrothal` |
| AST_BONDS_BLOOD_TIE | Legame di Sangue | BONDS | 2 | UNCOMMON | 2 | DISCARD | `asset.bonds.blood_tie` |
| AST_BONDS_FAVOR | Favore | BONDS | 1 | COMMON | 4 | DISCARD | `asset.bonds.favor` |
| AST_BONDS_GUEST_RIGHT | Diritto di Ospitalità | BONDS | 1 | COMMON | 4 | DISCARD | `asset.bonds.guest_right` |
| AST_BONDS_OATH | Giuramento | BONDS | 1 | COMMON | 4 | RETAIN | `asset.bonds.oath` |
| AST_BONDS_OLD_DEBT | Debito Vecchio | BONDS | 1 | COMMON | 4 | DISCARD | `asset.bonds.old_debt` |
| AST_FORCE_BURNED_GATE | Le Porte Bruciate | FORCE | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.force.burned_gate` |
| AST_FORCE_OLD_ARMY | Il Vecchio Esercito | FORCE | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.force.old_army` |
| AST_FORCE_SIEGE | Assedio | FORCE | 2 | UNCOMMON | 2 | DISCARD | `asset.force.siege` |
| AST_FORCE_WARBAND | Banda Armata | FORCE | 2 | UNCOMMON | 2 | ALWAYS_DISCARD | `asset.force.warband` |
| AST_FORCE_BORDER_WATCH | Guardia di Confine | FORCE | 1 | COMMON | 4 | DISCARD | `asset.force.border_watch` |
| AST_FORCE_LEVY | Leva Contadina | FORCE | 1 | COMMON | 4 | DISCARD | `asset.force.levy` |
| AST_FORCE_MERCENARIES | Mercenari | FORCE | 1 | COMMON | 4 | DISCARD | `asset.force.mercenaries` |
| AST_FORCE_ROADBLOCK | Posto di Blocco | FORCE | 1 | COMMON | 4 | DISCARD | `asset.force.roadblock` |
| AST_KNOWLEDGE_RED_CRYSTAL | Il Cristallo Rosso | KNOWLEDGE | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.knowledge.red_crystal` |
| AST_KNOWLEDGE_SEALED_TESTIMONY | Deposizione Sigillata | KNOWLEDGE | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.knowledge.sealed_testimony` |
| AST_KNOWLEDGE_PROOF | Prova | KNOWLEDGE | 2 | UNCOMMON | 2 | RETAIN_ON_SUCCESS | `asset.knowledge.proof` |
| AST_KNOWLEDGE_WITNESS | Testimone | KNOWLEDGE | 2 | UNCOMMON | 2 | ALWAYS_DISCARD | `asset.knowledge.witness` |
| AST_KNOWLEDGE_ARCHIVE | Archivio | KNOWLEDGE | 1 | COMMON | 4 | RETAIN_ON_SUCCESS | `asset.knowledge.archive` |
| AST_KNOWLEDGE_LEDGER | Registro | KNOWLEDGE | 1 | COMMON | 4 | DISCARD | `asset.knowledge.ledger` |
| AST_KNOWLEDGE_OLD_MAP | Mappa Vecchia | KNOWLEDGE | 1 | COMMON | 4 | DISCARD | `asset.knowledge.old_map` |
| AST_KNOWLEDGE_RUMOR | Voce di Corridoio | KNOWLEDGE | 1 | COMMON | 4 | DISCARD | `asset.knowledge.rumor` |
| AST_PEOPLE_EXODUS | Esodo | PEOPLE | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.people.exodus` |
| AST_PEOPLE_STILL_HANDS | Braccia Ferme | PEOPLE | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.people.still_hands` |
| AST_PEOPLE_MOBILIZATION | Mobilitazione | PEOPLE | 2 | UNCOMMON | 2 | ALWAYS_DISCARD | `asset.people.mobilization` |
| AST_PEOPLE_SPOKESMAN | Portavoce | PEOPLE | 2 | UNCOMMON | 2 | DISCARD | `asset.people.spokesman` |
| AST_PEOPLE_CROWD | Folla | PEOPLE | 1 | COMMON | 4 | DISCARD | `asset.people.crowd` |
| AST_PEOPLE_ELDERS | Consiglio degli Anziani | PEOPLE | 1 | COMMON | 4 | DISCARD | `asset.people.elders` |
| AST_PEOPLE_HARVEST_HANDS | Braccia per il Raccolto | PEOPLE | 1 | COMMON | 4 | DISCARD | `asset.people.harvest_hands` |
| AST_PEOPLE_MARCH | Marcia | PEOPLE | 1 | COMMON | 4 | DISCARD | `asset.people.march` |
| AST_WEALTH_LAND_MORTGAGE | Ipoteca sulle Terre | WEALTH | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.wealth.land_mortgage` |
| AST_WEALTH_TREASURY | Il Tesoro | WEALTH | 3 | RARE | 1 | ALWAYS_DISCARD | `asset.wealth.treasury` |
| AST_WEALTH_CARAVAN | Carovana | WEALTH | 2 | UNCOMMON | 2 | ALWAYS_DISCARD | `asset.wealth.caravan` |
| AST_WEALTH_GRANARY_KEYS | Chiavi del Granaio | WEALTH | 2 | UNCOMMON | 2 | DISCARD | `asset.wealth.granary_keys` |
| AST_WEALTH_CREDIT | Credito | WEALTH | 1 | COMMON | 4 | DISCARD | `asset.wealth.credit` |
| AST_WEALTH_GRAIN | Riserva di Grano | WEALTH | 1 | COMMON | 4 | DISCARD | `asset.wealth.grain` |
| AST_WEALTH_SALT | Sale | WEALTH | 1 | COMMON | 4 | DISCARD | `asset.wealth.salt` |
| AST_WEALTH_TOLL | Pedaggio | WEALTH | 1 | COMMON | 4 | DISCARD | `asset.wealth.toll` |

## Echo cards (39)
| id | titolo | famiglia drammatica | funzione | art_prompt_key |
|---|---|---|---|---|
| ECH_LEGEND_BROKEN_OATH | Il Giuramento che Nessuno Sciolse | MEMORIA | BETRAYAL | `echo.memoria.the_broken_oath` |
| ECH_LEGEND_CALLED_DAY | Il Giorno che la Gilda Chiese Tutto | MEMORIA | THREAT | `echo.memoria.the_called_day` |
| ECH_LEGEND_GOOD_YEAR | La Ballata dell'Anno Buono | MEMORIA | RETURN | `echo.memoria.the_good_year` |
| ECH_CALL_OF_ACCOUNTS | La Chiamata | PRESSURE | REQUEST | `echo.pressure.call_of_accounts` |
| ECH_EMPTY_THRONE | Sedia Vuota | PRESSURE | THREAT | `echo.pressure.threat` |
| ECH_LACK | Mancanza | PRESSURE | LACK | `echo.pressure.lack` |
| ECH_OFFER | L'Offerta | PRESSURE | TEMPTATION | `echo.pressure.temptation` |
| ECH_OMEN | Presagio | PRESSURE | OMEN | `echo.pressure.omen` |
| ECH_PETITION | La Supplica | PRESSURE | REQUEST | `echo.pressure.request` |
| ECH_ROAD_CLOSED | Strada Chiusa | PRESSURE | PROHIBITION | `echo.pressure.prohibition` |
| ECH_SILT | Interramento | PRESSURE | LACK | `echo.pressure.silt` |
| ECH_VIGIL_MOVED | La Veglia Spostata | PRESSURE | OMEN | `echo.pressure.vigil_moved` |
| ECH_AMNESTY | Amnistia | RESOLUTION | LIBERATION | `echo.resolution.liberation` |
| ECH_CROWNING | Chi Siede | RESOLUTION | SUCCESSION | `echo.resolution.succession` |
| ECH_RECKONING | Il Conto | RESOLUTION | PUNISHMENT | `echo.resolution.punishment` |
| ECH_RECONCILIATION | Riconciliazione | RESOLUTION | RECONCILIATION | `echo.resolution.reconciliation` |
| ECH_ROADS_OPEN | Vie Riaperte | RESOLUTION | RETURN | `echo.resolution.return` |
| ECH_SACRIFICE | Sacrificio | RESOLUTION | SACRIFICE | `echo.resolution.sacrifice` |
| ECH_THE_DUG_SEASON | La Stagione Scavata | RESOLUTION | GIFT | `echo.resolution.the_dug_season` |
| ECH_THE_LONG_TABLE | Il Tavolo Lungo | RESOLUTION | RECONCILIATION | `echo.resolution.the_long_table` |
| ECH_WRITTEN_DOWN | Messo per Iscritto | RESOLUTION | LIBERATION | `echo.resolution.written_down` |
| ECH_BETRAYAL | Tradimento | RUPTURE | BETRAYAL | `echo.rupture.betrayal` |
| ECH_CARAVAN_LOST | Carovana Perduta | RUPTURE | ATTACK | `echo.rupture.attack` |
| ECH_EXODUS | La Partenza | RUPTURE | SEPARATION | `echo.rupture.separation` |
| ECH_LOSS | Perdita | RUPTURE | LOSS | `echo.rupture.loss` |
| ECH_OATH_BROKEN | La Parola Data | RUPTURE | VIOLATION | `echo.rupture.violation` |
| ECH_THE_CRACK | La Crepa | RUPTURE | THREAT | `echo.rupture.the_crack` |
| ECH_THE_FIRES_OUTSIDE | I Fuochi Fuori | RUPTURE | SEPARATION | `echo.rupture.the_fires_outside` |
| ECH_TWO_VERDICTS | Due Sentenze | RUPTURE | VIOLATION | `echo.rupture.two_verdicts` |
| ECH_USURPATION | Usurpazione | RUPTURE | USURPATION | `echo.rupture.usurpation` |
| ECH_DISCOVERY | Scoperta | TURN | DISCOVERY | `echo.turn.discovery` |
| ECH_GOOD_YEAR | Annata Buona | TURN | GIFT | `echo.turn.gift` |
| ECH_OATH_SWORN | Giuramento Prestato | TURN | TRANSFORMATION | `echo.turn.transformation` |
| ECH_PARLEY | L'Incontro | TURN | ENCOUNTER | `echo.turn.encounter` |
| ECH_REVELATION | Rivelazione | TURN | REVELATION | `echo.turn.revelation` |
| ECH_SEIZURE | La Presa | TURN | CONQUEST | `echo.turn.conquest` |
| ECH_THE_COPY | La Copia | TURN | DISCOVERY | `echo.turn.the_copy` |
| ECH_THE_QUIET_SHAFT | Il Pozzo Zitto | TURN | RETURN | `echo.turn.the_quiet_shaft` |
| ECH_THE_SHORT_YEAR | L'Anno Corto | TURN | TRANSFORMATION | `echo.turn.the_short_year` |

## Region tiles (6)
| id | nome | biome | ruolo | slot | fonti Asset | art_prompt_key |
|---|---|---|---|---|---|---|
| REG_EREDAN | Eredan | CITY | PRIMARY | 4 | AUTHORITY, WEALTH | `region.eredan` |
| REG_MINIERE_ANTICHE | Miniere Antiche | UNDERGROUND | PRIMARY | 4 | KNOWLEDGE, WEALTH | `region.miniere_antiche` |
| REG_MONTAGNE_ROSSE | Montagne Rosse | MOUNTAIN | PRIMARY | 3 | FORCE, BONDS | `region.montagne_rosse` |
| REG_TERRE_NAHR | Terre Nahr | STEPPE | PRIMARY | 4 | PEOPLE, BONDS | `region.terre_nahr` |
| REG_VALLE_VERDE | Valle Verde | VALLEY | PRIMARY | 4 | PEOPLE, WEALTH | `region.valle_verde` |
| REG_STRADA_MERCANTI | Strada dei Mercanti | ROAD | SECONDARY | 4 | WEALTH, BONDS | `region.strada_mercanti` |

## Entity cards (8)
| id | nome | archetipo | bisogno | destiny | art_prompt_key |
|---|---|---|---|---|---|
| ENT_ALDRIC | Re Aldric | SOVEREIGN | POWER | DST_ALDRIC | `entity.aldric` |
| ENT_CENERE | Kessa dei Fuochi | FACTION | POWER | DST_CENERE | `entity.cenere` |
| ENT_LIBERE | Le Città Libere | PEOPLE | FREEDOM | DST_LIBERE | `entity.libere` |
| ENT_LYRA | Lyra | INDIVIDUAL | KNOWLEDGE | DST_LYRA | `entity.lyra` |
| ENT_NAHR | Popolo Nahr | PEOPLE | SURVIVAL | DST_NAHR | `entity.nahr` |
| ENT_SALE | Maestra Ilve | FACTION | WEALTH | DST_SALE | `entity.sale` |
| ENT_VAERAX | Vaerax | CREATURE | PROTECTION | DST_VAERAX | `entity.vaerax` |
| ENT_VETRO | Priore Anselmo | CULT | FAITH | DST_VETRO | `entity.vetro` |

## Destiny cards (20)
| id | titolo | entita | Minimum | Victory | Triumph |
|---|---|---|---|---|---|
| DST_ALDRIC | Il Regno che Resta | ENT_ALDRIC | Il trono regge | Il regno decide | Un regno che non ha pagato il pane con il sangue |
| DST_ALDRIC_RECORD | Il Regno che Ricorda | ENT_ALDRIC | La casa siede ancora | Nessuno rilegge la stessa domanda | Un regno che non ha dovuto dividersi per reggere |
| DST_CENERE | La Montagna è Nostra | ENT_CENERE | Restano sulla montagna | Chi scava lo dicono loro | E non solo quella |
| DST_CENERE_DEEP | Più a Fondo | ENT_CENERE | Restano sulla montagna | E hanno visto cosa c'è sotto | E non devono più niente a nessuno |
| DST_LIBERE | Una Legge Senza Corona | ENT_LIBERE | Le città esistono ancora | E c'è una Carta, e l'acqua non è di nessuno | E nessuno l'ha pagata più degli altri |
| DST_LIBERE_WATER | L'Acqua Torna a Muoversi | ENT_LIBERE | Le città esistono ancora | E l'acqua si muove | E non è di nessuno |
| DST_LYRA | Sapere e Poter Tornare a Guardare | ENT_LYRA | Ha capito qualcosa | Sa, ed è ancora nelle gallerie | Il sapere è diventato pubblico e verificabile |
| DST_LYRA_TAUGHT | Quello che Resta Insegnato | ENT_LYRA | Qualcuno sa ancora leggere le carte | Il sapere ha un posto suo | Verificabile da chiunque, anche da chi non c'era |
| DST_NAHR | Una Terra dove Fermarsi | ENT_NAHR | Il popolo sopravvive | Il popolo si ferma | Fermarsi senza smettere di essere Nahr |
| DST_NAHR_ROOTED | La Terra Sotto i Piedi | ENT_NAHR | Il popolo è ancora qui | La terra risponde a chi la lavora | Radicati senza aver chiuso la porta a nessuno |
| DST_SALE | Il Registro che Tiene | ENT_SALE | La Gilda è ancora al tavolo | Il debito è stato chiamato, e nessuno lo ha cancellato | E la firma vale ancora |
| DST_SALE_OPEN | Il Registro Aperto | ENT_SALE | La Gilda esiste ancora | E il registro si può leggere | E vale lo stesso |
| DST_SHARED_ACCOUNTS | I Conti Chiusi | $self | Il proprio registro è pulito | Una firma che vale, e nessuna domanda aperta | Un mondo che non deve niente a nessuno |
| DST_SHARED_LAND | La Terra che Risponde | $self | Un posto che risponde | Due terre, una voce | La mappa parla la tua lingua |
| DST_SHARED_RENOWN | Il Nome che Pesa | $self | Il nome è conosciuto | Il nome ha una casa | Un nome che nessuno ha visto fallire |
| DST_VAERAX | Cio che Dorme Resti Addormentato | ENT_VAERAX | La montagna è ancora sua | Le gallerie sono chiuse, e il Cristallo non è uscito | E nessuno ci arriva più |
| DST_VAERAX_LEGEND | La Storia che si Racconta | ENT_VAERAX | La storia si racconta ancora | La montagna tiene lontani gli uomini | Nessuno ricorda com'era davvero |
| DST_VAERAX_WATCHED | Il Sonno Sorvegliato | ENT_VAERAX | La montagna è ancora sua | Nessuno scava più | Guardato da qualcuno che non lo vuole |
| DST_VETRO | Quello che Non si Deve Guardare | ENT_VETRO | L'Ordine tiene la sua casa | La custodia è un incarico, e la teca resta chiusa | E cosa ci sia dentro lo sa, e le gallerie sono ancora sue |
| DST_VETRO_SHOWN | La Reliquia Mostrata | ENT_VETRO | L'Ordine tiene la sua casa | E l'ha mostrata lui | E la fede è diventata legge |

## Tension tracks (12)
| id | titolo | dominio | iniziale | soglia | visibilita | presagi |
|---|---|---|---|---|---|---|
| TEN_ASH | La Cenere che Sale | ANCIENT | 2 | 4 | VEILED | 1 |
| TEN_AWAKENING | Il Risveglio | ANCIENT | 2 | 6 | VEILED | 2 |
| TEN_CHARTER | La Carta | TERRITORY | 2 | 7 | OPEN | 1 |
| TEN_DEBT | Il Debito | RESOURCE | 2 | 7 | OPEN | 1 |
| TEN_FAMINE | La Carestia | SURVIVAL | 3 | 6 | OPEN | 1 |
| TEN_NAMELESS | I Senza Città | SURVIVAL | 2 | 5 | VEILED | 1 |
| TEN_PLAGUE | La Febbre Bassa | SURVIVAL | 2 | 5 | OPEN | 2 |
| TEN_RELIC | La Reliquia | ANCIENT | 2 | 6 | VEILED | 2 |
| TEN_ROADS | Le Vie Interrotte | RESOURCE | 1 | 5 | VEILED | 2 |
| TEN_SUCCESSION | La Successione | TERRITORY | 2 | 6 | OPEN | 2 |
| TEN_THIRST | I Pozzi Bassi | SURVIVAL | 1 | 5 | VEILED | 2 |
| TEN_WATER | L'Acqua Ferma | SURVIVAL | 3 | 6 | OPEN | 1 |

## Map overlays (30)
Ogni tag di Regione che il gioco puo mostrare sulla mappa. `domain:` marca il dominio di Tensione usato da INFLUENCE; `structure:`, `condition:` e `scar:` sono livelli grafici distinti (spec §19.5).

| tag | layer |
|---|---|
| `capital` | base |
| `condition:abandoned` | condition |
| `condition:contested` | condition |
| `condition:cut_off` | condition |
| `condition:emptied` | condition |
| `condition:exploited` | condition |
| `condition:indebted` | condition |
| `condition:lean` | condition |
| `condition:plundered` | condition |
| `condition:rationed` | condition |
| `condition:requisitioned` | condition |
| `condition:starving` | condition |
| `condition:unrest` | condition |
| `crystal_site` | base |
| `domain:ANCIENT` | domain |
| `domain:RESOURCE` | domain |
| `domain:SURVIVAL` | domain |
| `domain:TERRITORY` | domain |
| `granary` | base |
| `nomad_range` | base |
| `settlement:$proponent` | settlement |
| `settlement:march` | settlement |
| `settlement:market` | settlement |
| `structure:canal` | structure |
| `structure:granary` | structure |
| `structure:sealed` | structure |
| `structure:tollgate` | structure |
| `structure:watchtower` | structure |
| `trade` | base |
| `wild` | base |
