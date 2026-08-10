# ECHOES - Asset Manifest

<!-- GENERATED FILE - regenerate with `python3 tools/build_manifest.py`. -->

Every visual element the Chronicle needs, taken straight from `godot/data`.
`art_prompt_key` is the lookup into the Master Prompts in
[ART_BIBLE.md](ART_BIBLE.md); `marker_id` is the optional fiducial hook reserved
for the physical table (spec §19.5) and is not used by any code in 0.0.

Milestone 0.0 ships the reduced content of §18.2. The full §19.4 list (48 Assets,
24 Echo cards, 12 Region tiles, 24 map overlays, 12 standees) lands with 0.1.

## Asset cards (12)
| id | titolo | famiglia | forza | rarita | copie | scarto | art_prompt_key |
|---|---|---|---|---|---|---|---|
| AST_AUTHORITY_CROWN_RIGHT | Diritto di Corona | AUTHORITY | 2 | UNCOMMON | 4 | ALWAYS_DISCARD | `asset.authority.crown_right` |
| AST_AUTHORITY_EDICT | Editto | AUTHORITY | 1 | COMMON | 6 | DISCARD | `asset.authority.edict` |
| AST_BONDS_OATH | Giuramento | BONDS | 2 | RARE | 4 | RETAIN | `asset.bonds.oath` |
| AST_BONDS_FAVOR | Favore | BONDS | 1 | COMMON | 6 | DISCARD | `asset.bonds.favor` |
| AST_FORCE_WARBAND | Banda Armata | FORCE | 2 | UNCOMMON | 4 | ALWAYS_DISCARD | `asset.force.warband` |
| AST_FORCE_LEVY | Leva Contadina | FORCE | 1 | COMMON | 6 | DISCARD | `asset.force.levy` |
| AST_KNOWLEDGE_PROOF | Prova | KNOWLEDGE | 2 | RARE | 4 | RETAIN_ON_SUCCESS | `asset.knowledge.proof` |
| AST_KNOWLEDGE_RUMOR | Voce di Corridoio | KNOWLEDGE | 1 | COMMON | 6 | DISCARD | `asset.knowledge.rumor` |
| AST_PEOPLE_MOBILIZATION | Mobilitazione | PEOPLE | 2 | UNCOMMON | 4 | ALWAYS_DISCARD | `asset.people.mobilization` |
| AST_PEOPLE_CROWD | Folla | PEOPLE | 1 | COMMON | 6 | DISCARD | `asset.people.crowd` |
| AST_WEALTH_CARAVAN | Carovana | WEALTH | 2 | UNCOMMON | 4 | ALWAYS_DISCARD | `asset.wealth.caravan` |
| AST_WEALTH_GRAIN | Riserva di Grano | WEALTH | 1 | COMMON | 6 | DISCARD | `asset.wealth.grain` |

## Echo cards (16)
| id | titolo | famiglia drammatica | funzione | art_prompt_key |
|---|---|---|---|---|
| ECH_EMPTY_THRONE | Sedia Vuota | PRESSURE | THREAT | `echo.pressure.threat` |
| ECH_LACK | Mancanza | PRESSURE | LACK | `echo.pressure.lack` |
| ECH_OMEN | Presagio | PRESSURE | OMEN | `echo.pressure.omen` |
| ECH_ROAD_CLOSED | Strada Chiusa | PRESSURE | PROHIBITION | `echo.pressure.prohibition` |
| ECH_AMNESTY | Amnistia | RESOLUTION | LIBERATION | `echo.resolution.liberation` |
| ECH_RECONCILIATION | Riconciliazione | RESOLUTION | RECONCILIATION | `echo.resolution.reconciliation` |
| ECH_ROADS_OPEN | Vie Riaperte | RESOLUTION | RETURN | `echo.resolution.return` |
| ECH_SACRIFICE | Sacrificio | RESOLUTION | SACRIFICE | `echo.resolution.sacrifice` |
| ECH_BETRAYAL | Tradimento | RUPTURE | BETRAYAL | `echo.rupture.betrayal` |
| ECH_CARAVAN_LOST | Carovana Perduta | RUPTURE | ATTACK | `echo.rupture.attack` |
| ECH_LOSS | Perdita | RUPTURE | LOSS | `echo.rupture.loss` |
| ECH_USURPATION | Usurpazione | RUPTURE | USURPATION | `echo.rupture.usurpation` |
| ECH_DISCOVERY | Scoperta | TURN | DISCOVERY | `echo.turn.discovery` |
| ECH_GOOD_YEAR | Annata Buona | TURN | GIFT | `echo.turn.gift` |
| ECH_OATH_SWORN | Giuramento Prestato | TURN | TRANSFORMATION | `echo.turn.transformation` |
| ECH_REVELATION | Rivelazione | TURN | REVELATION | `echo.turn.revelation` |

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

## Destiny cards (4)
| id | titolo | entita | Minimum | Victory | Triumph |
|---|---|---|---|---|---|
| DST_ALDRIC | Il Regno che Resta | ENT_ALDRIC | Il trono regge | Il regno decide | Un regno che non ha pagato il pane con il sangue |
| DST_LYRA | Sapere e Poter Tornare a Guardare | ENT_LYRA | Ha capito qualcosa | Sa, ed e ancora nelle gallerie | Il sapere e diventato pubblico e verificabile |
| DST_NAHR | Una Terra dove Fermarsi | ENT_NAHR | Il popolo sopravvive | Il popolo si ferma | Fermarsi senza smettere di essere Nahr |
| DST_VAERAX | Cio che Dorme Resti Addormentato | ENT_VAERAX | La montagna e ancora sua | Nessuno ha portato via il Cristallo | Il sonno e stato reso sicuro |

## Tension tracks (4)
| id | titolo | dominio | iniziale | soglia | visibilita | presagi |
|---|---|---|---|---|---|---|
| TEN_AWAKENING | Il Risveglio | ANCIENT | 2 | 6 | VEILED | 2 |
| TEN_FAMINE | La Carestia | SURVIVAL | 3 | 6 | OPEN | 1 |
| TEN_ROADS | Le Vie Interrotte | RESOURCE | 1 | 5 | VEILED | 2 |
| TEN_SUCCESSION | La Successione | TERRITORY | 2 | 6 | OPEN | 2 |

## Map overlays (24)
Ogni tag di Regione che il gioco puo mostrare sulla mappa. `domain:` marca il dominio di Tensione usato da INFLUENCE; `structure:`, `condition:` e `scar:` sono livelli grafici distinti (spec §19.5).

| tag | layer |
|---|---|
| `capital` | base |
| `condition:contested` | condition |
| `condition:cut_off` | condition |
| `condition:exploited` | condition |
| `condition:indebted` | condition |
| `condition:plundered` | condition |
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
| `settlement:march` | settlement |
| `settlement:market` | settlement |
| `settlement:nahr` | settlement |
| `structure:granary` | structure |
| `structure:sealed` | structure |
| `structure:tollgate` | structure |
| `trade` | base |
| `wild` | base |
