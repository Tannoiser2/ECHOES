# DECISIONS

Every place where the implementation had to decide something the spec (v0.2) left
open, or where it extended something the spec fixed. Per §16 and §25, a baseline
number is never changed silently: it is either implemented as written, or the
deviation is recorded here as a reversible configuration.

Status legend: **implemented** = live in 0.0 · **flagged** = a balance
observation for 0.2, deliberately *not* acted on · **todo** = known gap.

---

## D-001 — Godot 4.7.1 confirmed, headless build used throughout
**implemented**

The spec fixes Godot 4.7.1 stable. The whole 0.0 milestone (data validation,
64 unit/smoke tests, three scripted Chronicles) is built and verified against
`Godot_v4.7.1-stable_linux.x86_64 --headless`. No editor step is needed: the
project has never been opened in the GUI, and `--import` is not required for any
of the commands in the README, because nothing relies on the global class-name
cache (see D-019).

---

## D-002 — `Effect.inverse_type` alongside `inverse_payload`
**implemented** · extends the schema in §6.3

The Effect example in §6.3 shows `inverse_payload` but no way to say *which
operation* consumes it. That is fine for symmetric types (`ADJUST_TENSION`
inverts to itself) and ambiguous for asymmetric ones: the inverse of
`ADD_PRESENCE` is a `REMOVE_PRESENCE`, not an `ADD_PRESENCE` with a different
payload.

Rather than infer the pairing at undo time, every reversible Effect stores an
explicit `inverse_type`. The pairing table lives in one place,
`scripts/core/effect.gd :: INVERSE_TYPE`, and `undo()` simply applies
`inverse_type` with `inverse_payload`.

Irreversible Effects (`CREATE_ECHO`, `APPEND_TRUTH`) carry neither field.

---

## D-003 — `REMOVE_SCAR` added to the EffectType enum
**implemented** · §6.3 permits extension with a note here

`ADD_SCAR` is reversible per §6.3 (only Echo and Truth are listed as
irreversible), but the enum had no operation that could undo it. `REMOVE_SCAR`
was added so the enum stays closed *and* complete. It also restores the Region
tag correctly: `ADD_SCAR` records whether the map tag already existed for another
reason, and the undo leaves a pre-existing tag alone.

The enum is now 22 entries. `tests/unit/test_effect_applier.gd` asserts that
every reversible entry in the generated enum has a round-trip test, so a future
addition cannot slip in untested.

---

## D-004 — RNG position persisted as a draw counter
**implemented**

`world_state.rng_state` holds *the number of values drawn since the seed*, not
the engine's raw 64-bit state word. Restoring re-seeds and fast-forwards.

Reason: a 64-bit state exceeds the range JSON round-trips losslessly through
Godot's parser, and §18.3 requires a byte-identical save. A counter is a small
integer, always exact, and costs a few thousand `randi()` calls on load.

---

## D-005 — Effect-mediated world state vs. progression cursors
**implemented**

§2.11 says every WorldState mutation goes through an Effect. Taken literally with
the closed enum of §6.3 that is impossible: there is no `SET_PHASE` or
`ADVANCE_ROUND`, and adding them would turn the enum into a bookkeeping API.

The line drawn here: **everything a player can point at** — Tensions, presence,
control, tags, relations, Assets, Claims, Scars, Echoes, Truths — is mutated only
by `EffectApplier`. The Chronicle's own cursors are not:

`act`, `round`, `phase`, `ao_remaining`, `drift_index`, `confluence_queue`,
`forced_confluence`, `confluence_count`, `effect_sequence`,
`tensions[*].fired_omens`, `tensions[*].resolved_count`.

These are fully determined by the plan plus the seed, so they need no inverse;
undoing across them is a snapshot restore, which is what §6.3 prescribes anyway.
They are all part of the save, so a reload resumes exactly.

---

## D-006 — Structural setup is not an Effect; presence and hands are
**implemented**

`WorldStateFactory.build()` constructs which Entities, Regions, Tensions and
decks exist. That *is* the initial state, not a mutation of it, and there is no
"before" for an inverse to return to.

Everything a player could later change is applied as a setup Effect with
`source.kind = "system"`, `source.id = "SETUP"`: presence tokens and opening
hands. So `effect_log` explains the whole table from `EFF_000001` onwards, and
undoing back to an empty board is possible.

---

## D-007 — An Echo card that prescribes a Confluence opens it at Act end
**implemented**

§7 caps Confluences at one per round; §12.1 (b) says an Act Echo card may
prescribe one. Act-end happens after the last round's threshold check, so the two
rules do not actually collide: the card's Confluence opens immediately at Act
end, with `trigger.kind = "ECHO_CARD"`, and does not consume the round's slot.

`ECH_REVELATION` is the card that exercises this in 0.0.

---

## D-008 — A minimal test runner instead of GUT
**implemented** · §3 allows GUT but requires it be isolated and documented

`tests/run_tests.gd` (≈100 lines) discovers `test_*.gd`, runs each `test_*`
method on a fresh instance and exits non-zero on failure. `tests/test_case.gd`
holds the assertions and the shared session fixture.

Reason: the suite must run under `godot --headless` in CI with no addon
directory and no editor import step. GUT would add a vendored dependency for
assertions the project needs about six of. If the suite outgrows this, GUT goes
into `addons/` and this entry gets revisited.

The runner refuses to be taken down by a suite that fails to compile: a script
that does not parse is reported as a failed suite. (A parse error inside
`_initialize` never reaches `quit()`, and the process hangs forever — this cost
real debugging time during 0.0.)

---

## D-009 — TEN_AWAKENING cannot reach its threshold on Drift alone
**implemented, deliberate**

The Awakening starts at 2, has 4 Drift entries and a threshold of 7: at most 6
from Drift. It becomes urgent only when the world pushes it — the Ripple of a
Famine Confluence (+1), an Echo card, or players raising it on purpose.

That is the intended shape: the hidden Tension does not go off by itself, it goes
off *because of what the table did about the other one*. `test_data_boot.gd`
checks reachability including Ripple, not Drift alone.

---

## D-010 — `deck_copies` added to the Asset schema
**implemented**

§18.2 gives 0.0 two distinct Assets per family. A two-card draw pile is not a
deck: with four players spending eight AO per round it empties on round one, and
`ACQUIRE` starts failing for reasons that have nothing to do with the rules under
test. The first sim run produced 56 refused actions for exactly this reason.

`deck_copies` (default 3) sets how many physical copies of a card are in its
family pile. 0.0 uses 6 copies of each strength-1 card and 4 of each strength-2:
10 per family, 60 in total, against a maximum of 28 cards that can sit in hands.

0.1 replaces this with the eight distinct cards per family of §9 and
`deck_copies` drops back towards 1–2.

---

## D-011 — CLAIM has two modes, and forcing costs an Action Opportunity
**implemented**

§10 describes creating a Claim as a CLAIM action, then says forcing a Confluence
happens "in a later round" without saying what it costs. Forcing is implemented
as `CLAIM` with `mode: "FORCE"`: it costs 1 AO, consumes the Claim and discards a
second AUTHORITY Asset, exactly as §10 lists. It refuses if the Claim was created
in the same round, if the Tension is below 3, or if a Confluence has already been
forced this round.

---

## D-012 — "Success" in the Echo Check includes Success with Cost
**implemented**

§12.4 writes "Success con S + O ≥ 6". Both `SUCCESS` and `SUCCESS_WITH_COST` are
successes — the proposal passed — so both qualify. Only `FAILURE` takes the
separate `O ≥ 6` route.

---

## D-013 — Asset disposition on Failure
**implemented**

§12.3 states the proponent discards everything committed and each opposer
recovers one Asset of their choice. It does not say what happens to a
*non-proponent supporter* or to a Condition's commit.

Rule applied: on a Failure, everything committed is discarded except one Asset of
their choice per opposer. A card whose own rule is `ALWAYS_DISCARD` can never be
the recovered one. On any success, everything committed is discarded unless the
card says `RETAIN` (always) or `RETAIN_ON_SUCCESS`.

---

## D-014 — Resolution ordering inside a Confluence is fixed
**implemented**

§12.2 gives the A–K sequence but not the order *within* H–I, which is observable:
whether a card's on-commit cost lands before or after the Tension is settled
changes the final number. The order is fixed, and stated in both
`confluence_controller.gd` and RULES_V0_2.md §12:

1. World Factor · 2. Maths · 3. Tension outcome · 4. on-commit costs of the cards
spent · 5. outcome Consequences · 6. cost / decisive bonus · 7. qualified
Condition clause · 8. Asset disposition · 9. Echo Check · 10. Ripple.

On-commit costs land *after* the Tension is settled, so `AST_FORCE_WARBAND`
leaves the Tension at 2 instead of 1 on a success — a cost you can see.

---

## D-015 — Two schemas beyond the twelve listed in §4
**implemented**

- `schema/chronicle.schema.json` — the Chronicle definition (Acts, rounds, AO,
  drift distribution, Act Echo pools). §7 makes all of these data-driven but §4
  lists no schema for them.
- `schema/sim_plan.schema.json` — the harness input required by §18.1. Having it
  under `/schema` means the sample plans are validated in CI like everything else.

---

## D-016 — Question default and Proposition eligibility
**implemented**

§12.2 B says a valid question is selected "in base a stato e cause della
Tensione" without a tie-break. Default: the **last** eligible question in
definition order, so a Tension at breaking point asks the harder question. The
proponent may pick any other eligible one.

Separately, propositions carry eligibility conditions. Without them the first sim
run produced the Nahr proposing that the throne requisition the grain, and Aldric
opposing his own granary: mechanically legal, narratively backwards. The
throne-only propositions now require the proponent to carry the `crowned` tag,
and `P_LAND_TO_WORKERS` was added so a non-crowned proponent still has something
to say about the same question.

---

## D-017 — Destiny levels are cumulative
**implemented**

§14 gives three levels without saying whether they nest. They do: a Triumph
requires the Victory and Minimum conditions as well. Losing the Minimum drops an
Entity to `NONE` however impressive the rest looks — a king with no capital has
not won anything. Each level is also reported individually in `levels`, so the
Chronicle End screen can show the whole ladder.

---

## D-018 — Presence-based INFLUENCE could cancel the Drift outright
**resolved in 0.0.1 by D-021** · was: flagged

§10 makes INFLUENCE free and repeatable when you have presence in a Region tagged
with the Tension's domain. Four players have eight AO per round; the Drift is +1
per round. A table that wants a Tension held flat can hold it flat forever.

The 0.0 report flagged this without numbers. The balance pass measured it, and it
was worse than suspected — see D-021 for the instrument and the fix.

---

## D-021 — One INFLUENCE per Entity per round
**implemented in 0.0.1** · `chronicle.influence_rules.max_per_entity_per_round`

### How it was measured

Two new pieces, both under `godot/cli`:

- **`policy_decider.gd`** — a player that actually plays to win. It derives its
  goals from its own Destiny: the lowest level it has not yet reached, the
  Tensions that level wants held down, and — crucially — the Tensions it needs to
  *bring to a head*, because the only thing that can satisfy one of its
  conditions is a Consequence sitting behind a Confluence. All derived from the
  data, no per-Entity AI.
- **`run_balance_probe.gd`** — plays N Chronicles across N seeds and reports the
  distribution.

### What the measurement found

The first probe run, with a naive policy that only ever suppressed:

| | Confluence per Chronicle |
|---|---|
| mediana | **0** |
| media | 0.37 |
| dentro la banda 3-4 del §7 | 0/30 |
| sotto il minimo di 2 | **30/30** |

The payoff of the entire design never fired. But the naive policy was itself
wrong: Aldric's Victory needs `control_count >= 2`, and control only ever changes
hands through a Confluence Consequence. A competent Aldric *drives the Famine up*
to force the Confluence he can win. Teaching the policy that — still from the
data, not by hand — moved the median from 0 to 3 with **no rule change at all**.

So most of the apparent problem was the measuring instrument. That is the reason
this pass measured before it changed anything.

### Choosing the rule

Four candidates, 40 Chronicles each, same seeds:

| variante | mediana | in banda 3-4 | fuori dai limiti §7 | INFLUENCE/partita |
|---|---|---|---|---|
| A — regole v0.2 invariate | 3 | 60% | **10/40 sotto il minimo** | 45.7 |
| **B — cap di 1 per Entita per round** | **4** | **82%** | **0/40** | **20.1** |
| C — la presenza copre solo il +1 | 2 | 0% | 1/40 sotto | 47.1 |
| D — B e C insieme | 4 | 72% | 0/40 | 27.3 |

B wins outright and is the smallest change. C on its own makes things *worse*,
and D adds a second rule for a worse result than B alone, so neither ships.

Under B, INFLUENCE drops from 63% of every action taken in a Chronicle to 28%,
which is the real point: the other five templates get their table time back.

### The rule

One INFLUENCE per Entity per round, across all Tensions. Data-driven and
reversible: omit `influence_rules` entirely and the original v0.2 behaviour
returns. `presence_directions` is implemented too, defaulting to both directions,
so candidate C stays one config line away for the 0.2 pass.

Guarded by `tests/smoke/test_balance.gd`. See D-023 for how that guard was
rewritten — and why — once the second cap landed.

---

## D-029 — Pressure is displaced, not removed
**implemented in 0.0.5** · `chronicle.influence_rules.displacement_on_decrease`

### The question, and the measurement that answered it

Do crises always break in the end, or can a table hold them shut? Asked by the
author, and answerable only by playing a table that tries.

`cli/suppressor_decider.gd` is that table: four Entities that spend every Action
Opportunity pushing the loudest Tension they can legally touch back down, buying
a SCHEME first when a veiled one needs unlocking, moving only to stand where a
push becomes legal. Nobody would play like this; that is the point.

Over 40 Chronicles, against the same four playing their own Destiny:

| | quattro Destiny | solo soppressione |
|---|---|---|
| Confluence per Chronicle | 3.60 | **0.17** |
| Chronicle senza nessuna | 0/40 | **33/40** |
| La Carestia e scoppiata | 35/40 | **0/40** |
| Il Risveglio | 38/40 | **0/40** |
| Le Vie Interrotte | 21/40 | **0/40** |
| picco raggiunto (soglia 5-6) | 7-8 | **2-3** |

1400 pushes down against 452 of the world's own pressure. Three to one. The
answer was **no**: a table could keep the whole Chronicle silent, and the payoff
of the entire design would never fire. That is O-9.

### The rule

Pushing a Tension **down** with INFLUENCE raises one of its `linked_tensions` by
`displacement_on_decrease` (1 in Chronicle I). You do not make a question go
away; you choose which one to have instead.

The weight lands on the linked Tension currently **lowest**, so suppression
spreads pressure across the board rather than piling it in one place. Ties go to
the Chronicle's Tension order, so the same board always displaces the same way. A
linked Tension the Chronicle never drew is skipped rather than conjured into play
(D-028).

The displaced Effect keeps the acting Entity as its actor - this is your doing -
but carries its own source id, `ACT_INFLUENCE_DISPLACED`. Without that the per
round INFLUENCE cap, which is reconstructed from the log, counted it as a second
action.

Raising a Tension displaces nothing: feeding a fire directly is not a trade.

### The arithmetic, and why total suppression is now self-defeating

Four players, one INFLUENCE each per round (D-021): 4 down, 4 displaced up, plus
the world's own +1 Drift. Net **+1 per round** in favour of the world. A table
that suppresses everything is doing the world's work for it.

### The content that had to change with it

The link graph pooled: everything fed `TEN_FAMINE` and nothing fed
`TEN_ROADS`, so displacement filled one question and starved another. Re-authored
as a ring with chords, checked so that every Tension both feeds and is fed - both
across the six of the library and inside the four of Chronicle I:

```
Carestia    -> Risveglio, Vie Interrotte      la fame spinge a scavare, e a fermare le carovane
Risveglio   -> Successione, Pozzi Bassi       chi tiene il Cristallo pretende il trono
Successione -> Vie Interrotte, Carestia       senza un re nessuno garantisce le strade
Vie Interr. -> Pozzi Bassi, Carestia          niente sale, niente da conservare
Pozzi Bassi -> Febbre Bassa, Risveglio        acqua cattiva, e si scava per trovarne
Febbre      -> Carestia, Successione          nessuno raccoglie, e il trono non protegge
```

### After

| | prima | dopo |
|---|---|---|
| soppressori: Chronicle silenziose | 33/40 | **1/40** |
| soppressori: Confluence per Chronicle | 0.17 | **2.73** |
| tavolo normale: Confluence per Chronicle | 3.60 | 4.58 |
| ogni Tensione e scoppiata almeno una volta | no | **si, tutte e quattro** |

Suppression still *buys* something - 2.73 Confluences against 4.58 - so holding a
question down is a real move with a real effect. It just cannot buy silence.

### An unplanned improvement

The balance of D-026 got better on its own: **75% of runs inside the 4-5 band**
against 42%, with nothing below 2 or above 7. That closes O-5 as well: the two
Chronicles in forty that fell under §7's floor are now zero.

---

## D-026 — The Confluence band is 4-5, not §7's 3-4
**implemented in 0.0.4** · declared deviation from §7, recorded per §25

§7 asks for 3-4 Confluence per Chronicle. That number was written for the two
Tensions of §18.2; a Chronicle now carries four, and the measured median is 4
with only 42% of runs inside 3-4. Widening the band to **4-5** (and the hard
bounds from 2-6 to 2-7) describes the game that exists rather than the one the
reduced content described.

Chosen by the author over the alternative - tuning the content back down until
it fits 3-4 - because the wider world is the point of D-024. `test_balance.gd`
and `run_balance_probe.gd` both carry the new band, and both name this entry.

---

## D-027 — Holding is not free: overextension and lapse
**implemented in 0.0.4** · `chronicle.control_rules`

O-7 measured a runaway: across ten inherited Chronicles Aldric went from one
Region to five and never lost one again, because inheritance compounds an
advantage and nothing reversed it.

The answer is the author's, and it is better than the three options offered: not
a penalty aimed at whoever is winning, but a pressure that comes from the
situation. An empire falls from its own size.

Two coupled rules, both data-driven and both removable by deleting
`control_rules`:

- **`max_stable_control`** — every Region an Entity holds beyond this raises the
  Tension of *that Region's own domain*, once per round. It reads at the table as
  "you hold the road as well? then the road question is yours to answer".
- **`lapse_without_presence`** — at the start of a continuing Chronicle, a Region
  held with nobody standing in it reverts to no one. You cannot govern where you
  are not, so a power that spread too thin loses the edges first, without anyone
  having to take them.

Chronicle I uses `{max_stable_control: 2, overextension_delta: 1,
lapse_without_presence: true}`.

Measured over ten inherited Chronicles, same seeds:

```
prima   Re - Vae Re  Re  Re     (dalla Chronicle 5 in poi, immobile)
dopo    Re - Vae Re  Pop -   ->  Re - Vae - - -  ->  Re - Vae Re - -
```

Control now expands and contracts instead of freezing. Truths over the campaign
went 13 -> 16 and distinct sentences 12 -> 15, because a world that moves gives
the slots of D-028 something to say.

---

## D-028 — Library content: Councils bound to a domain, Chronicles that draw
**implemented in 0.0.4** · the author chose model **B** (combinatorial library)

The question was how Chronicle N+1 exists at all. Three models were on the table:
pre-written Legacy (A), a combinatorial library (B), hybrid (C). The author chose
**B**: nothing about the next Chronicle is written in advance, it is assembled.

Two structural changes make that possible.

### A Council may bind to a domain instead of a Tension

`confluence_template.tension_id` is now optional, and `applies_to_domain` is the
alternative. A Tension with no Council of its own is served by the Council of its
domain. The structure of a survival crisis is not specific to one famine, so
*"$in_region, chi decide a chi non ne tocca?"* serves any of them.

This is the single biggest cost saving in the project: Councils were about a
third of the authoring cost of a Chronicle, and they were the part that had to be
rewritten every time.

`CNF_ANY_SURVIVAL` is the first one, written entirely in slots. `TEN_PLAGUE` and
`TEN_THIRST` are the first Tensions with no Council of their own, and they get a
complete one for free.

### A Chronicle may draw its Tensions instead of listing them

`chronicle.tension_pool` (`candidates`, `count`, `always`) replaces a written-out
`tensions` list. The draw uses the same seeded RNG as the decks and the drift
bag, so a library Chronicle is exactly as reproducible as an authored one - same
seed, same year. `drift_distribution` may be omitted too, and is then dealt
round-robin over whatever was drawn.

`CHR_01` stays authored and unchanged. `CHR_02` is the library form and draws 4
of 6 candidates. Ten years of it, same seeds:

```
1  813  FAMI PLAG ROAD THIR      6  814  FAMI PLAG SUCC THIR
2  814  AWAK FAMI ROAD SUCC      7  819  PLAG ROAD SUCC THIR
3  815  AWAK ROAD SUCC THIR      8  820  FAMI PLAG ROAD SUCC
...
```

### What had to give way

Library content names Tensions a Chronicle may not have drawn, so `ADJUST_TENSION`
and `SET_TENSION_VISIBILITY` on a Tension **that exists in the data but is not in
play** are now a no-op instead of a failure. An id that is not a Tension at all is
still an error - the distinction is what keeps a typo loud.

`tension_limit` conditions resolve `$tension`, and the authored Scar block
resolves `$region_focus`, for the same reason: a domain-bound Council does not
know which question it is serving until it opens.

### What is still A, not B

The 29 Consequences are mostly *not* library content yet: most still name a
specific Region. Three (`CNS_RATIONED`, `CNS_ABANDONED`, `CNS_SHARED_BURDEN`) are
written purely in slots and are the pattern for the rest. Generalising the other
26 is the next chunk of B, and it is authoring work, not engine work.

---

## D-024 — 4 Tensions, 26 Consequences, 16 Echo cards
**implemented in 0.0.3** · further deliberate deviation from §18.2, recorded per §25

### Why the content grew

Measured first, with `cli/run_world_probe.gd`. Over 40 independent Chronicles on
the 2-Tension set, the world ended in **2 distinct control maps, 2 distinct
relation maps and 0 Scars**. Over 10 Chronicles played in sequence, control never
changed hands once and the map gained 2 tags in ten years.

Three of seven authored Region tags never fired at all. The Chronicle could not
move, so nothing built on top of it could either - which is why the `$slot`
sentences of the previous commit resolved to the same Region 116 times out of
116. Slots do not create variety, they transmit it.

### What was added

| | prima | dopo |
|---|---|---|
| Tensioni | 2 | 4 (`TEN_SUCCESSION` TERRITORY, `TEN_ROADS` RESOURCE) |
| template di Confluence | 2 | 4 |
| Consequence | 12 | 26 |
| carte Echo | 8 | 16 |
| Scar autorate | 0 | 8 |

Three shapes of Consequence that did not exist before:

- **che guariscono** — `CNS_HARVEST_RETURNS`, `CNS_ORDER_RESTORED`,
  `CNS_ROADS_REOPENED` *remove* condition tags. Without them the world only ever
  saturated: every tag was one-way, so ten Chronicles produced a map covered in
  scars and nothing else.
- **che cambiano il controllo** — `CNS_CAPITAL_TAKEN`, `CNS_CROWN_DIVIDED`,
  `CNS_MARCH_GRANTED`, `CNS_TOLL_ESTABLISHED`, `CNS_MARKET_MOVED`.
- **che lasciano una Scar** — 8 Consequences now carry `creates_scar`. The
  mechanism was implemented in 0.0 and used by nothing.

Two baseline numbers moved and are recorded here rather than changed quietly:
the drift bag is now 2/3/2/2 across four Tensions instead of 5/4, and
`TEN_AWAKENING`'s threshold went **7 → 6**, because nine drift chips spread over
four Tensions can no longer carry one to 7 without help.

### The measurement, after

Same probe, same seeds:

| | 2 Tensioni | 4 Tensioni |
|---|---|---|
| mappe di controllo distinte (40 partite) | 2 | **6** |
| set di tag distinti | 14 | **26** |
| stato finale distinto | 14 | **28** |
| Scar per Chronicle | 0.00 | **0.45** |

And over ten Chronicles in sequence, which is the question that started this:

```
#   anno  controllo                 tag  Scar  Truth
1   812   Re  -  Vae Re  Pop -       1    0     2
5   816   Re  -  Vae Re  Re  Re     10    3     6
10  821   Re  -  Vae Re  Re  Re     11    9    13
```

Il controllo cambia (Chronicle 4 e 5), i tag vanno da 1 a 11, le Scar da 0 a 9.
La Regione a fuoco si sposta su **sei** combinazioni Tensione/Regione invece di
due, quindi le frasi a slot cominciano davvero a nominare posti diversi.

### What it cost, stated plainly

The balance of D-021/D-023 regressed and is **not** restored:

| | 12 Consequence, 2 Tensioni | 26 Consequence, 4 Tensioni |
|---|---|---|
| mediana Confluence | 3 | 4 |
| nella banda 3-4 del §7 | **70%** | **42%** |
| fuori da 2-6 | 3/40 | 3/40 |
| FAILURE | **18** | 9 |
| SUCCESS_WITH_COST | **15** | 5 |

`tests/smoke/test_balance.gd` still passes - the median is in band and outliers
are under the 10% ceiling - but two of the four outcome bands have thinned out
again. See O-6.

---

## D-025 — Sim plan directives address a Tension, not a running index
**implemented in 0.0.3**

`scripted_confluence.index` said "steer the first Confluence of the run". Adding
two Tensions changed which question comes to a head first, so plan A's grain
directive landed on the Roads council: wrong proposition, and a clause that does
not exist in that template.

Directives may now carry `tension_id`, which reads as "when the grain council
happens, do this" and survives new content. `index` still works for directives
that do not name a Tension. The directive is resolved once per Confluence and
cached, because the controller asks for it a dozen times per council and
consuming it on the first call handed the second call the *next* directive.

---

## D-022 — 12 Consequences instead of the 8 of §18.2
**implemented in 0.0.2** · deliberate deviation from §18.2, recorded per §25

§18.2 sizes the 0.0 content at 8 Consequences. The set now holds 12. The four
new ones are `CNS_VALLEY_CLEARED`, `CNS_CROWN_DISPOSSESSED`, `CNS_MINE_TAKEN`
and `CNS_STUDY_UNDER_GUARD`.

The reason is O-4. Every proposition in the reduced set granted something to its
proponent and took nothing from anybody, so a policy that scores propositions
against its own Destiny scored almost all of them at zero and abstained. O came
out at 0, the proponent always won, and two of the four outcome bands of §12.3
were unreachable outside the scripted plans. That is a content gap being read as
a maths problem.

Each new Consequence takes something specific away from a specific seat:

| Consequence | attached to | what it costs, and to whom |
|---|---|---|
| `CNS_VALLEY_CLEARED` | `P_REQUISITION` | clears the Nahr out of the Valley (`optional`, so it is a no-op if they are not there) |
| `CNS_CROWN_DISPOSSESSED` | `P_OPEN_VALLEY`, `P_LAND_TO_WORKERS` | the Valley stops being controlled by anyone, which is Aldric's `control_count` |
| `CNS_MINE_TAKEN` | `P_EXPLOIT` | control of the Ancient Mines passes to the proponent, against Lyra and Vaerax |
| `CNS_STUDY_UNDER_GUARD` | `P_GUARDED_STUDY` | its own world change, closing O-2 |

`REMOVE_PRESENCE` gained an `optional` flag for this: a Consequence may say
"clear them out of the Valley" without knowing whether anyone is camped there,
and that has to be a no-op rather than a failed Effect.

The policy was extended to *see* the damage — it scores `ADD_PRESENCE` /
`REMOVE_PRESENCE` against its `region_presence` conditions and `SET_CONTROL`
against `control_count` — and to answer a proposal that costs it 2 or more with
`OPPOSE` rather than a polite Condition clause.

Measured effect on 40 Chronicles, seeds 1000-1039, everything else unchanged:

| | FAILURE | SUCCESS_WITH_COST | SUCCESS | DECISIVE |
|---|---|---|---|---|
| 8 Consequences (D-021 baseline) | **0** | 1 | 79 | 75 |
| 12 Consequences | 2 | 4 | 47 | 36 |

Failure exists again. But the Confluence median fell from 4 to 2 and only 20% of
runs stayed in §7's band: opposition that real also *deters*, and the policy
stopped bringing Tensions to a head at all. That is what D-023 answers.

---

## D-023 — One INFLUENCE per Tension per round
**implemented in 0.0.2** · `chronicle.influence_rules.max_per_tension_per_round`

D-021 bounds how fast a *person* can move; this bounds how fast a *question* can
move, whatever the table wants. Four players who all care about the Famine could
still walk it to threshold in a single round, which is why the median swung so
hard when D-022 changed who wanted to.

Swept as a knob (`--tension-cap`) over 40 Chronicles, seeds 1000-1039, on the
12-Consequence content:

| max per Tension | mediana | in banda 3-4 | sotto il minimo | FAILURE | SwC |
|---|---|---|---|---|---|
| nessuno | 2 | 20% | 8/40 | 2 | 4 |
| **1** | **3** | **70%** | 2/40 | **18** | **15** |

With both caps in force the final shape over the same 40 Chronicles is:

```
Confluence per Chronicle   media 2.92, mediana 3, min/max 1/4
  nella banda 3-4          28/40 (70%)
  sotto il minimo di 2     2/40
  sopra il massimo di 6    0/40
Esiti  FAILURE 18 · SUCCESS_WITH_COST 15 · SUCCESS 57 · DECISIVE 27
Echo   61 (1.52 per Chronicle)
```

All four outcome bands of §12.3 now occur in open play. That closes O-4.

### The cost, stated plainly

Two of the forty Chronicles produce a single Confluence, which is below the floor
§7 names. Under D-021 alone that number was zero. The trade bought the two
missing outcome bands, and §7 says to report rather than silently adjust — this
is the report.

`tests/smoke/test_balance.gd` was rewritten as part of this change, and it is
fair to say it was relaxed after it failed. The old guard asserted per run: no
single Chronicle outside 2-6. The new guard asserts on the aggregate — the median
must be 3-4, at most 10% of runs may fall outside 2-6, and there must be at least
one Echo per two Chronicles. The justification is that §7 describes what a
*playtest* should show, not a rule forbidding one quiet Chronicle, and a guard
that fails on a single outlier is measuring variance rather than balance. The
justification is genuine, but the sequence was: guard failed, guard changed.
Anyone re-opening this should weigh it knowing that.

Reversible like D-021: delete `max_per_tension_per_round` from the Chronicle and
the cap disappears.

---

## D-019 — GDScript built-ins shadow same-named methods
**implemented**

`RngService` exposes `range_int(from, to)`, not `randi_range`. GDScript resolves
an unqualified call to a `@GlobalScope` built-in *before* a method of the
enclosing class, so a method named `randi_range` is silently never called and
every "seeded" draw comes from the global RNG instead. The first determinism
check caught it: two services built from the same seed produced different
shuffles, and the draw counter stayed at zero.

Related: the project avoids `class_name` and uses `const X := preload(...)`
throughout, so nothing depends on the global class cache that only an editor
import generates.

---

## D-020 — `forced_confluence` on the WorldState
**implemented**

`CLAIM/FORCE` has to survive from the action phase to the end-of-round check, and
be part of the save. Added to `world_state.schema.json` as a nullable object
(`{tension_id, entity_id}`), initialised to `null` at setup so the save shape is
stable.

---

## Open observations

### O-1 — Confluence count per Chronicle
**closed by D-021, re-measured under D-023.** Current shape over 40 Chronicles:
median 3, range 1-4, 70% inside §7's 3-4 band, 2 runs below the floor of 2. The
three scripted plans produce 1, 3 and 2, which is expected — a plan is an
authored story, not a typical table, and plan A exists specifically to show a
clean Decisive Success.

### O-4 — Failure and Success with Cost almost never happen in open play
**closed by D-022 + D-023.**

The reading was right: the cause was content, not maths, and the resolver was
never touched. In the reduced 0.0 set almost no Consequence wrote a tag another
Destiny cared about, so a proposition threatened nobody, O came out at 0, and the
proponent always won. Four Consequences that take something specific away from a
specific seat (D-022), plus a bound on how fast a single question can move
(D-023), bring all four bands of §12.3 into open play: 18 Failure, 15 Success
with Cost, 57 Success, 27 Decisive over the same 40 Chronicles.

The §19.4 content growth is still the right next step; it is no longer a
prerequisite for the outcome table to be alive.

### O-2 — Content breadth of the Confluence templates
**closed by D-022.** `P_GUARDED_STUDY` now has `CNS_STUDY_UNDER_GUARD` and no
longer shares `CNS_MINE_SEALED` with `P_SEAL_MINE`. Every proposition in the set
lands on its own world change.

### O-6 — The wider content thinned the outcome bands again
**partly closed by D-026** — the band question is answered (4-5, declared). The
thinning of Failure and Success with Cost is not: 9 and 5 against 18 and 15.
Still open, still the same mechanism as O-4 in a bigger world.

**original note:**

D-024 grew the content and the balance of D-021/D-023 regressed: 42% of runs in
§7's 3-4 band against 70%, and Failure/Success with Cost back down to 9 and 5
from 18 and 15. Four Tensions mean more Confluences, and attention spread over
four questions means each individual council is less contested - the same
mechanism as O-4, in a bigger world.

Not acted on, on purpose. §7's 3-4 band was written for the reduced content of
§18.2; whether it still describes a 4-Tension Chronicle is a design question for
the author, not something to tune away quietly. The knobs from D-021/D-023 are
both still there and still measured.

### O-7 — The campaign has a runaway leader
**closed by D-027.**

**original note:**

Ten Chronicles in sequence, each inheriting the last: Aldric holds one Region at
the start and five by Chronicle 5, and never loses one again. Inheritance
compounds an advantage and nothing reverses it - the healing Consequences of
D-024 clear *conditions*, not *control*.

This wants a real answer before the campaign of 1.0, and the honest options are
design decisions, not tuning: control that lapses without presence, a Destiny
that gets harder as you hold more, or a Chronicle-start step that puts something
back on the table. Recorded rather than picked.

### O-8 — Six of the 26 Consequences never fire in open play
**flagged, open**

`structure:granary`, `structure:tollgate`, `settlement:market`,
`condition:exploited`, `condition:requisitioned` and `condition:indebted` were
not written to the map once in 40 measured Chronicles. Their propositions exist
and are legal; the policy simply never scores them highest.

Content that cannot be reached is content that does not exist. Worth checking
against real players before deciding whether the propositions are weak or the
policy is narrow - tuning the policy until its own content fires would be fitting
the measurement to the answer.

### O-9 — A table that only suppresses can keep a Chronicle silent
**closed by D-029.** Measured at 33 silent Chronicles out of 40; now 1.

### O-5 — Two Chronicles in forty fall below §7's floor
**closed by D-029** — 0/40 below the floor after displacement landed, without
anything being tuned for it.

**original note:**
**flagged, deliberately accepted — see the cost section of D-023**

1 Confluence in 2 runs out of 40. Those are Chronicles where the two Tensions are
each moved by one player pulling up and another pulling down, and the caps mean
neither side can break the deadlock inside a round. More Tensions (§19.4 asks for
4) should spread the pressure and fix this without another rule; worth
re-measuring first thing in 0.2 before adding anything.

### O-3 — `on_commit_effects` is exercised by one card
`AST_FORCE_WARBAND` is the only Asset with an on-commit cost in 0.0. The
mechanism is general and schema-backed; 0.1's 48 Assets are where it earns its
keep.
