# ECHOES - Asset Manifest

<!-- GENERATED FILE - regenerate with `python3 tools/build_manifest.py`. -->

Every visual element the Chronicle needs, taken straight from `godot/data`.
`art_prompt_key` is the lookup into the Master Prompts in
[ART_BIBLE.md](ART_BIBLE.md); `marker_id` is the optional fiducial hook reserved
for the physical table (spec §19.5) and is not used by any code in 0.0.

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
| AST_BONDS_GUEST_RIGHT | Diritto di Ospitalita | BONDS | 1 | COMMON | 4 | DISCARD | `asset.bonds.guest_right` |
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

## Echo cards (24)
| id | titolo | famiglia drammatica | funzione | art_prompt_key |
|---|---|---|---|---|
| ECH_EMPTY_THRONE | Sedia Vuota | PRESSURE | THREAT | `echo.pressure.threat` |
| ECH_LACK | Mancanza | PRESSURE | LACK | `echo.pressure.lack` |
| ECH_OFFER | L'Offerta | PRESSURE | TEMPTATION | `echo.pressure.temptation` |
| ECH_OMEN | Presagio | PRESSURE | OMEN | `echo.pressure.omen` |
| ECH_PETITION | La Supplica | PRESSURE | REQUEST | `echo.pressure.request` |
| ECH_ROAD_CLOSED | Strada Chiusa | PRESSURE | PROHIBITION | `echo.pressure.prohibition` |
| ECH_AMNESTY | Amnistia | RESOLUTION | LIBERATION | `echo.resolution.liberation` |
| ECH_CROWNING | Chi Siede | RESOLUTION | SUCCESSION | `echo.resolution.succession` |
| ECH_RECKONING | Il Conto | RESOLUTION | PUNISHMENT | `echo.resolution.punishment` |
| ECH_RECONCILIATION | Riconciliazione | RESOLUTION | RECONCILIATION | `echo.resolution.reconciliation` |
| ECH_ROADS_OPEN | Vie Riaperte | RESOLUTION | RETURN | `echo.resolution.return` |
| ECH_SACRIFICE | Sacrificio | RESOLUTION | SACRIFICE | `echo.resolution.sacrifice` |
| ECH_BETRAYAL | Tradimento | RUPTURE | BETRAYAL | `echo.rupture.betrayal` |
| ECH_CARAVAN_LOST | Carovana Perduta | RUPTURE | ATTACK | `echo.rupture.attack` |
| ECH_EXODUS | La Partenza | RUPTURE | SEPARATION | `echo.rupture.separation` |
| ECH_LOSS | Perdita | RUPTURE | LOSS | `echo.rupture.loss` |
| ECH_OATH_BROKEN | La Parola Data | RUPTURE | VIOLATION | `echo.rupture.violation` |
| ECH_USURPATION | Usurpazione | RUPTURE | USURPATION | `echo.rupture.usurpation` |
| ECH_DISCOVERY | Scoperta | TURN | DISCOVERY | `echo.turn.discovery` |
| ECH_GOOD_YEAR | Annata Buona | TURN | GIFT | `echo.turn.gift` |
| ECH_OATH_SWORN | Giuramento Prestato | TURN | TRANSFORMATION | `echo.turn.transformation` |
| ECH_PARLEY | L'Incontro | TURN | ENCOUNTER | `echo.turn.encounter` |
| ECH_REVELATION | Rivelazione | TURN | REVELATION | `echo.turn.revelation` |
| ECH_SEIZURE | La Presa | TURN | CONQUEST | `echo.turn.conquest` |

## Region tiles (6)
| id | nome | biome | ruolo | slot | fonti Asset | art_prompt_key | marker_id |
|---|---|---|---|---|---|---|---|
| REG_EREDAN | Eredan | CITY | PRIMARY | 4 | AUTHORITY, WEALTH | `region.eredan` | `MK_REG_EREDAN` |
| REG_MINIERE_ANTICHE | Miniere Antiche | UNDERGROUND | PRIMARY | 4 | KNOWLEDGE, WEALTH | `region.miniere_antiche` | `MK_REG_MINIERE_ANTICHE` |
| REG_MONTAGNE_ROSSE | Montagne Rosse | MOUNTAIN | PRIMARY | 3 | FORCE, BONDS | `region.montagne_rosse` | `MK_REG_MONTAGNE_ROSSE` |
| REG_TERRE_NAHR | Terre Nahr | STEPPE | PRIMARY | 4 | PEOPLE, BONDS | `region.terre_nahr` | `MK_REG_TERRE_NAHR` |
| REG_VALLE_VERDE | Valle Verde | VALLEY | PRIMARY | 4 | PEOPLE, WEALTH | `region.valle_verde` | `MK_REG_VALLE_VERDE` |
| REG_STRADA_MERCANTI | Strada dei Mercanti | ROAD | SECONDARY | 4 | WEALTH, BONDS | `region.strada_mercanti` | `MK_REG_STRADA_MERCANTI` |

## Entity cards (4)
| id | nome | archetipo | bisogno | destiny | art_prompt_key |
|---|---|---|---|---|---|
| ENT_ALDRIC | Re Aldric | SOVEREIGN | POWER | DST_ALDRIC | `entity.aldric` |
| ENT_LYRA | Lyra | INDIVIDUAL | KNOWLEDGE | DST_LYRA | `entity.lyra` |
| ENT_NAHR | Popolo Nahr | PEOPLE | SURVIVAL | DST_NAHR | `entity.nahr` |
| ENT_VAERAX | Vaerax | CREATURE | PROTECTION | DST_VAERAX | `entity.vaerax` |

## Destiny cards (8)
| id | titolo | entita | Minimum | Victory | Triumph |
|---|---|---|---|---|---|
| DST_ALDRIC | Il Regno che Resta | ENT_ALDRIC | Il trono regge | Il regno decide | Un regno che non ha pagato il pane con il sangue |
| DST_ALDRIC_RECORD | Il Regno che Ricorda | ENT_ALDRIC | La casa siede ancora | Nessuno rilegge la stessa domanda | Un regno che non ha dovuto dividersi per reggere |
| DST_LYRA | Sapere e Poter Tornare a Guardare | ENT_LYRA | Ha capito qualcosa | Sa, ed e ancora nelle gallerie | Il sapere e diventato pubblico e verificabile |
| DST_LYRA_TAUGHT | Quello che Resta Insegnato | ENT_LYRA | Qualcuno sa ancora leggere le carte | Il sapere ha un posto suo | Verificabile da chiunque, anche da chi non c'era |
| DST_NAHR | Una Terra dove Fermarsi | ENT_NAHR | Il popolo sopravvive | Il popolo si ferma | Fermarsi senza smettere di essere Nahr |
| DST_NAHR_ROOTED | La Terra Sotto i Piedi | ENT_NAHR | Il popolo e ancora qui | La terra risponde a chi la lavora | Radicati senza aver chiuso la porta a nessuno |
| DST_VAERAX | Cio che Dorme Resti Addormentato | ENT_VAERAX | La montagna e ancora sua | Nessuno ha portato via il Cristallo | Il sonno e stato reso sicuro |
| DST_VAERAX_WATCHED | Il Sonno Sorvegliato | ENT_VAERAX | La montagna e ancora sua | Nessuno scava piu | Guardato da qualcuno che non lo vuole |

## Tension tracks (6)
| id | titolo | dominio | iniziale | soglia | visibilita | presagi |
|---|---|---|---|---|---|---|
| TEN_AWAKENING | Il Risveglio | ANCIENT | 2 | 6 | VEILED | 2 |
| TEN_FAMINE | La Carestia | SURVIVAL | 3 | 6 | OPEN | 1 |
| TEN_PLAGUE | La Febbre Bassa | SURVIVAL | 2 | 5 | OPEN | 2 |
| TEN_ROADS | Le Vie Interrotte | RESOURCE | 1 | 5 | VEILED | 2 |
| TEN_SUCCESSION | La Successione | TERRITORY | 2 | 6 | OPEN | 2 |
| TEN_THIRST | I Pozzi Bassi | SURVIVAL | 1 | 5 | VEILED | 2 |

## Map overlays (27)
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
| `structure:granary` | structure |
| `structure:sealed` | structure |
| `structure:tollgate` | structure |
| `trade` | base |
| `wild` | base |
