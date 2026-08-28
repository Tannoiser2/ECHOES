# ECHOES — Modello dati

Gli schemi in [`/schema`](../schema) sono la **fonte unica di verità** (§17).
Tutto il resto deriva da lì:

```
/schema/*.schema.json          JSON Schema 2020-12 — la fonte
   │
   ├── tools/validate_data.py            valida godot/data (usato in CI e in locale)
   └── tools/gen_gd_schema.py  ──────►   godot/scripts/core/schema_defs.gd
                                            └── DataRegistry / SchemaValidator (boot)
```

`schema_defs.gd` è **generato**: non va modificato a mano. La CI lo rigenera e
fallisce se il file committato è diverso. È vietato duplicare a mano una regola di
validazione in due posti.

---

## Convenzioni

Ogni documento di dati è una *collezione*:

```json
{ "schema_id": "asset", "version": "0.2.0", "items": [ … ] }
```

`schema_id` seleziona lo schema, quindi un file dice sempre cosa è. I file sotto
`godot/data/` possono stare in qualunque sottocartella: il loader ricorre.

Prefissi degli id (§6): `ENT_`, `REG_`, `AST_<FAMIGLIA>_`, `ACT_`, `TEN_`, `ECH_`,
`CNS_`, `DST_`, `CNF_`, `CHR_`, `SIM_`, e a runtime `EFF_`, `CLM_`, `SCR_`,
`ECHO_`, `TRU_`.

---

## Gli schemi

| file | tipo | descrive |
|---|---|---|
| `entity.schema.json` | collezione | Entità giocabili (§6.1) |
| `region.schema.json` | collezione | Regioni, adiacenze, fonti Asset, tag di dominio |
| `asset.schema.json` | collezione | Le carte Asset delle sei famiglie (§9) |
| `action.schema.json` | collezione | I sei template di azione (§10) |
| `tension.schema.json` | collezione | Tensioni, soglie, presagi, collegamenti (§11) |
| `echo_card.schema.json` | collezione | Carte Echo e i loro hook (§15) |
| `consequence.schema.json` | collezione | Conseguenze → liste di Effect (§16) |
| `destiny.schema.json` | collezione | Destiny e le condizioni riutilizzabili (§14) |
| `confluence_template.schema.json` | collezione | Question, Proposition, clausole, pool, ripple (§12) |
| `chronicle.schema.json` | collezione | La Chronicle: Atti, round, AO, drift, pool Echo — [D-015](DECISIONS.md#d-015) |
| `sim_plan.schema.json` | collezione | Piani di partita per l'harness headless — [D-015](DECISIONS.md#d-015). **Nessun file di piano esiste piu'** dalla 0.1.281: se ne sono andati con gli anni d'autore ([D-318](DECISIONS.md#d-318)). Lo schema e il codice che lo legge restano, cosi' un piano scritto a mano si puo' ancora giocare |
| `effect.schema.json` | runtime | L'Effect e l'`effect_spec` di authoring (§6.3) |
| `world_state.schema.json` | runtime | Lo stato del mondo (§6.2) |
| `save.schema.json` | runtime | Il salvataggio versionato (§22) |

I tre schemi *runtime* non compaiono mai come file in `godot/data`:
`validate_data.py` rifiuta esplicitamente un documento che ci provi.

---

## Effect (§6.3)

Il cuore del sistema. Ogni mutazione del mondo è un Effect applicato da
`EffectApplier`; nessun altro sistema scrive sul WorldState.

```json
{
  "effect_id": "EFF_000123",
  "type": "ADJUST_TENSION",
  "target":  { "kind": "tension", "id": "TEN_FAMINE" },
  "payload": { "delta": 1 },
  "source":  { "kind": "action", "id": "ACT_INFLUENCE", "actor": "ENT_ALDRIC",
               "act": 1, "round": 2, "sequence": 41 },
  "reversible": true,
  "inverse_type": "ADJUST_TENSION",
  "inverse_payload": { "delta": -1 }
}
```

`inverse_type` è un'aggiunta rispetto all'esempio della specifica
([D-002](DECISIONS.md#d-002)): senza, l'inverso di `ADD_PRESENCE` sarebbe
ambiguo.

### L'enum chiuso (22 voci)

`ADJUST_TENSION` · `SET_TENSION_VISIBILITY` · `ADD_PRESENCE` · `REMOVE_PRESENCE` ·
`SET_CONTROL` · `SET_REGION_TAG` · `REMOVE_REGION_TAG` · `SET_GLOBAL_TAG` ·
`REMOVE_GLOBAL_TAG` · `SET_RELATION` · `GRANT_ASSET` · `REMOVE_ASSET` ·
`TRANSFER_ASSET` · `CREATE_CLAIM` · `CONSUME_CLAIM` · `ADD_SCAR` ·
**`REMOVE_SCAR`** · `SET_ENTITY_TAG` · `REMOVE_ENTITY_TAG` · `SET_ENTITY_ACTIVE` ·
`CREATE_ECHO` · `APPEND_TRUTH`

`REMOVE_SCAR` è aggiunto rispetto alla specifica, con la nota richiesta dal §6.3
([D-003](DECISIONS.md#d-003)). Estendere ancora l'enum richiede una nuova voce in
DECISIONS.md **e** un test di round-trip: `test_effect_applier.gd` fallisce se un
tipo reversibile non ne ha uno.

### Reversibilità

`CREATE_ECHO` e `APPEND_TRUTH` hanno `reversible: false` e non portano inverso.
`undo()` si rifiuta di superarli e indica lo snapshot; `SaveManager` ne crea uno
automatico prima di ogni Confluence.

Casi delicati già gestiti e coperti da test:

- un `ADJUST_TENSION` **clampato** a 0 registra come inverso il delta davvero
  applicato, non quello richiesto;
- taggare qualcosa che era già taggato è un no-op il cui inverso è un no-op, così
  l'undo non rimuove un tag preesistente;
- rimuovere una carta dalla mano registra la sua **posizione**, così l'inverso la
  rimette dov'era invece che in fondo;
- pescare da un mazzo vuoto rimescola gli scarti: l'ordine rimescolato viaggia
  *dentro* l'Effect, così l'applier resta privo di casualità e l'inverso ripristina
  esattamente draw e discard.

### effect_spec

Gli autori scrivono `effect_spec`, non Effect: stessa forma, ma `target.id` e i
valori stringa del payload possono contenere `$variabili` risolte da
`ConsequenceCompiler` sul contesto della Confluence (`$proponent`, `$tension`,
`$confluence`, `$actor`).

---

## WorldState (§6.2)

Un Dictionary che corrisponde uno-a-uno a `world_state.schema.json`, così il
salvataggio è la serializzazione diretta dello stato — nessuna conversione, e
quindi nessun posto dove la conversione possa perdere qualcosa.

Campi richiesti dalla specifica: `world_id`, `year`, `chronicle_id`, `act`,
`round`, `phase`, `entities`, `regions`, `tensions`, `relations`, `global_tags`,
`claims`, `echo_log`, `truth_log`, `scars`, `effect_log`, `rng_seed`, `rng_state`.

Aggiunti perché il gioco li richiede e il salvataggio deve contenerli (§22):
`decks`, `echo_deck`, `drift_track`, `drift_index`, `confluence_queue`,
`forced_confluence`, `confluence_count`, `effect_sequence`, `turn_order`.

`relations` è indicizzato dalla coppia di id ordinata e unita da `|`
(`ENT_ALDRIC|ENT_NAHR`), così (A,B) e (B,A) sono lo stesso record.

`rng_state` è il **numero di estrazioni** fatte dal seed, non lo state word a 64
bit ([D-004](DECISIONS.md#d-004)).

---

## Salvataggio (§22)

`save_version` + `data_version` + WorldState + assegnazione dei posti +
l'eventuale Confluence aperta + i risultati Destiny.

Il testo è prodotto con `JSON.stringify(save, "  ", true)`: le chiavi sono
ordinate, quindi il file non dipende dall'ordine in cui il motore ha costruito i
suoi dizionari. Nessun orario entra nel salvataggio. Stesso seed e stesso piano
producono un file **byte-identico** — è il criterio di accettazione §18.3, ed è
verificato sia dal test suite sia confrontando due esecuzioni di
`tools/run_sims.sh`.

---

## Integrità referenziale

`validate_data.py` fa due passate. Dopo la validazione JSON Schema controlla che
ogni id citato esista davvero, e in più:

- le **adiacenze fra Regioni sono reciproche** (altrimenti il movimento sarebbe
  a senso unico per sbaglio);
- la `drift_distribution` somma esattamente `acts × rounds_per_act`;
- i pool Echo coprono ogni Atto una volta sola e hanno almeno una carta;
- ogni Tensione della Chronicle ha un template di Confluence;
- nessun id duplicato in tutto il set di dati.

`DataSet._check_references()` ripete al boot i controlli che il motore
dereferenzia davvero, così un drop di dati sbagliato fallisce all'avvio invece che
a metà Chronicle.
