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

## D-057 — La mappa smette di essere sei cerchi
**implemented in 0.1.19** (ART_BIBLE §MASTER PROMPT 3, §21)

The ART_BIBLE splits the work in two: a person paints the **illustration**, the
code draws the **system graphics** - vector, semi-flat, legible over anything.
Region tiles sit on the line between them, and this is the half that is code's:
the silhouette of the ground, the biome you read from across the table, the calm
centre where the tokens go.

Until now the map was six circles with a name under each. That is a diagram of
adjacency, and adjacency is the one thing about a Region that the game barely
uses. What a player needs at a glance - *where am I, what is this place* - is a
shape and a colour, and both of those generate.

### Un disegno, due supporti

`region_art.gd` returns a **plan** in normalised coordinates - an irregular
hexagon plus strokes in a three-word vocabulary (`poly`, `line`, `dot`) - and
two renderers consume it: `map_view.gd` with Godot's primitives and
`print_sheet.gd` in SVG. **The tile on screen and the tile you print are the
same picture**, not two that resemble each other. That is the same seam as
D-056's `PrintSheet.layout()`, applied one level down.

Six biomes, six vocabularies: roofs and a stretch of wall for the city, striped
fields and a river for the valley, a ridge with snow on one side for the
mountain, tunnel mouths for underground, a road band with stops, low grass and
tracks for the steppe. Deterministic from the region id alone, so two Regions of
the same biome differ and the same Region never changes between two games or two
exports.

### Tre cose che si sono viste solo guardando

- **Il disegno usciva dalla tessera.** The vocabularies are written on the full
  unit square, because that is how you think while drawing - *roofs go low, the
  wall runs high*. A hexagon of radius 0.46 has an inscribed circle of 0.40, so
  the city roofs poked out below the tile edge. Everything is now pulled toward
  the centre by a fixed factor, and a test walks every point of every Region.
- **La tessera stampata era un francobollo.** The art box was a wide rectangle,
  so the square plan was squashed and a mountain stopped being a mountain. Now
  the terrain always draws into a centred square - and a Region tile is
  *full-bleed*: the terrain takes the whole card and the name sits on the ground
  in the lower-left corner, where the hexagon leaves the background bare. The
  description and the asset sources are gone from the tile: they are reference
  text, they do not go on the table, and printing them cost the illustration
  half its size.
- **Il raggio era una costante.** 46 pixels, whatever the window. Six small dots
  in the middle of a full screen waste the one view that says where things are,
  and at that size the terrain is invisible. The radius now comes from the
  space available, and the authored `map_position` box is stretched to fill it -
  which moves everything together and changes nothing about where a Region sits
  relative to the others.

### Quello che questo non e'

It is not the painted art. MASTER PROMPT 3 still describes an illustration that
somebody has to paint, and `brief_arte.md` still generates the prompt for it.
This is the layer underneath, the one the ART_BIBLE always assigned to code -
and it is now good enough that the game is legible without the other one.

---

## D-056 — L'export di stampa, e il segnaposto che mostra la propria chiave
**implemented in 0.1.18** (§25, punto 15)

The 0.1 roadmap carried one unfinished line: *«Export Preview e placeholder
d'arte migliorati»*. `CardView` shipped in 0.1.5, and the other half never did.
What was actually missing was bigger than a screen: **nothing turned the JSON
into a physical component**. COMPONENTS §1 says ECHOES is a physical boardgame
with an app rather than either one, and until now the app was all there was.

### Le facce stanno in un posto solo

`card_face.gd` turns a definition into a **face** - title, subtitle, accent,
corner number, body, notes, footer, art key - and both consumers read it: the
SVG sheet and the on-screen preview. The alternative was two layouts that agree
by hand, which is how the family colours ended up written twice (`asset_card.gd`
and now here) and the Propp function names three times. Both are now single
copies, read from this file.

### SVG, non PNG

An export that gets printed has to be **deterministic and readable**, like the
saves (§18.3). An SVG is text: two exports of the same data are byte-identical,
CI can diff them, and the diff says *which card* changed rather than that six
megabytes of pixels differ. It also needs no rendering context - it runs under
`--headless` with no GPU, like everything else here.

Sheets are A4 at **1:1**: cards 63x88 mm three by three, Region tiles 80x80 two
by three, crop marks outside the cut. The deck is expanded by `deck_copies`, so
48 Asset faces print as 132 cards over 15 sheets (D-040).

### Il segnaposto rispetta il vincolo che l'arte vera dovra' rispettare

The ART_BIBLE asked for a placeholder showing its own `art_prompt_key` «so a
wrong card is recognisable at a glance during playtest», and there was none: the
only graphic in the repository was `icon.svg`. A grey rectangle would have
satisfied the letter. This one is **different for every key**, deterministically
(FNV-1a over the key, then an LCG - never the session RNG, which it must not
touch), and it leaves the lower third calm, which is invalidable rule 2 of the
ART_BIBLE. When real art arrives with the wrong composition it will be obvious,
because the placeholder had it right.

### Il brief legge la ART_BIBLE invece di ricopiarla

`art_bible.gd` parses the three MASTER PROMPTs and their variation keys out of
the document and fills in the subject the data knows. The prompt stays the
document's, the subject stays the data's. If `docs/ART_BIBLE.md` is not there
the brief still comes out, with the pointer instead of the prompt: an incomplete
brief is useful, an export that fails because a prose document moved is not.

Passing every key in the set through one tool also found the gap nobody had
noticed: **the eight Entity keys have no MASTER PROMPT**. Three exist - Asset
card, Echo card, Region tile - and none of them is a portrait. The export says
so, and a test holds the number at eight so it cannot grow quietly.

### Quello che il test ha trovato che l'occhio aveva gia' visto

The first sheets ran the Destiny text past the bottom edge and `DST_LYRA`'s
title past the right one. I saw them because I rendered a PNG and looked. That
is not a method - twenty-five sheets is exactly the amount nobody re-checks - so
the layout became a pure function returning `overflow` and `scale`, and
`test_print_export.gd` asks every face in the set whether it fits. It
immediately found two more (`AST_BONDS_HOSTAGE`, `AST_WEALTH_LAND_MORTGAGE`),
and the fix is that **the illustration yields before the text does**: the art
shrinks to a 34% floor before the body is scaled down at all.

---

## D-055 — Una Condition pagata e sostegno
**implemented in 0.1.17** (§12.3, §A5)

Until 0.1.16 a Condition sat outside the arithmetic entirely. You declared "I am
for this, on one condition", spent up to two Assets to qualify the clause, and
moved the margin by **zero**: the clause attached itself only if the proposal
passed anyway, carried by other people's cards.

Against OPPOSE — three Assets, every point subtracting, and one card back when
the proposal falls — that is not a close call. It is strictly dominated, and the
stance nobody takes is not a stance.

### La misura, prima di toccare niente

100 Chronicles, four characters dealt across the seats (D-053), same 100 seeds:

| | 0.1.16 | col Condition che conta |
|---|---|---|
| Consigli caduti | 315 / 603 (52%) | **282 / 596 (47%)** |
| prudente (NONE/MIN/VIC/TRI) | 0 / 82 / 14 / 4 | 0 / **74 / 22 / 4** |
| aggressivo | 0 / 29 / 63 / 8 | 0 / 30 / **61** / 9 |
| DECISIVE_SUCCESS | 95 | **128** |
| seggi bloccati, tavolo misto | 1 su 8 | **0 su 8** |

### La regola

`M = S + C − O + W`, where C is the Condition front's total **only when the
clause qualifies** (`condition_total >= condition_qualified_threshold`, still 2
in the data). An unqualified Condition attaches nothing and moves nothing, and
the cards are spent all the same: that is the price of negotiating, and it is
what keeps the stance a choice rather than a discount.

`condition_total` and `condition_qualified` stay in the result dictionary, so
the log, the board and the dashboard keep showing the three fronts separately —
the arithmetic changed, what you can read off it did not.

### Quello che non risolve, detto qui

Blocking is still the strongest seat at the table: **aggressivo closes 61
Victories against prudente's 22**. This rule makes CONDITION a live option and
takes five points off the failure rate; it does not dethrone OPPOSE. The ROADMAP
entry "opporsi non costa abbastanza" stays open, and the second lever — a real
price on the Oppose front — is still unmeasured.

One earlier attempt at that price is already recorded as a failure: a Consequence
adding `+1` to the question when a proposal fell made blocking *more* attractive,
not less, and pushed Chronicles over the §7 ceiling. It was reverted.

---

## D-054 — Il cruscotto, cioe le sonde dentro la partita
**implemented in 0.1.16** (§25, punto 14)

Everything this project has learned about its own game arrived through a
command-line probe - the margin, the silence, the Destinies, the playtest - and
every one of them has the same shape: somebody looks at a number nobody was
looking at and finds it has been there for four milestones. The cost of that
loop is that you have to export, replay and read a file, so you only pay it once
you already suspect something.

The dashboard puts the same four tables **inside the Chronicle being played**,
redrawn on every phase: the questions with how much the *world* pushed them and
how much the *table* did, each seat's ladder clause by clause, the Councils with
S/O/margin, and the tail of the Effect register with each line's source.

### Mostra quello che al tavolo e coperto, e lo dice

A veiled Tension's real value, everyone's hand, who pushed what. The screenshot
that verified it is the argument for the design: the player panel on the right
says *"Il Risveglio — velata"* while the dashboard says *"Il Risveglio 5/6"*, in
the same frame. That is exactly what a developer needs and exactly what ruins a
game, so it is behind **F3** rather than a button, and it says what it is in red
across the top.

It shares the middle of the screen with the map, the Council and the rules page,
for the reason all of them share it: somebody reading one of those is not looking
at the table.

### E non sa niente

Like every other view it takes a session and draws what is there - no rule, no
decision (D-038). The one piece of state it keeps is the running total of who
pushed which Tension, because the register holds every push and re-reading three
hundred Effects on every phase change to re-add them would be the one thing in
this screen that does work instead of showing it.

### Un dettaglio che si vede solo guardando

The first draft marked held clauses with a tick. It is not in the font, so a
table of true and false clauses came out as a column of empty boxes - the worst
possible character in that specific place. It uses `[x]` and `[ ]`, which is what
the rest of the game already writes.

---

## D-053 — Il playtest, e dove la D-051 aveva torto
**measured and acted on in 0.1.15**

D-051 concluded that Destiny outcomes cluster - several seats at 37-40 out of 40
on one level - **because every seat is the same deterministic optimiser**, not
because of how the clauses are written, and said it wanted a table of real
players rather than another turn of the knobs. That was a hypothesis stated
without evidence. This is the experiment, and it says the hypothesis was **half
right**, which is the useful half of the result.

### L'esperimento

Four characters, each the same policy with one thing different, none of them
cheating and all of them going through the same legality checks: **prudente**
(never opposes, commits one card fewer), **aggressivo** (blocks anything that
does not help, commits everything), **distratto** (one turn in four does
something else legal), **ostinato** (plays for its Triumph from round one
instead of the nearest rung).

100 Chronicles, 50 per saga, the characters dealt across the seats by a separate
RNG so the *world* is identical in both halves - then the same 100 seeds played
again by four identical optimisers. The difference is the table, not the luck.

### Dove aveva ragione

| seggio | quattro ottimizzatori | tavolo misto |
|---|---|---|
| Le Citta Libere | 0 / **49** / 0 | 21 / 29 / 0 |
| Maestra Ilve | 5 / **43** / 2 | 21 / 24 / 5 |
| Vaerax | 4 / **43** / 3 | 26 / 19 / 5 |
| Priore Anselmo | 11 / **39** / 0 | 26 / 24 / 0 |

*(MINIMUM / VICTORY / TRIUMPH)*

Four seats that looked locked were not: put different people in them and they
spread. Seats stuck on one level go from 3 of 8 to 2 of 8, and the ones that
move are exactly the ones D-051 had been re-writing clauses for. **Those clauses
were not the problem.**

### Dove aveva torto

Two seats do not move, and the cross-tab is what settles it - not "they lose
often" but "they lose no matter who plays them":

| | prudente | aggressivo | distratto | ostinato |
|---|---|---|---|---|
| **Kessa dei Fuochi** | 17 MIN / 0 | 9 MIN / **1 VIC** | 12 MIN / 1 VIC | 10 MIN / 0 |
| **Lyra** | 14 MIN / 0 | 8 MIN / **2 TRI** | 15 MIN / 1 TRI | 10 MIN / 0 |

The best player at the table, holding those two seats, gets past Minimum once or
twice in ten. That is not an optimiser artefact and no amount of varied play
fixes it: **those two Destinies are simply too expensive**, and D-051's "the
cause is not the content" was wrong about them specifically. Written down here
rather than quietly fixed, because the wrong half of a conclusion is worth as
much as the right half.

### E due cose che nessuno stava misurando

**Un tavolo misto scrive una storia molto piu varia.** 511 Truths written, **479
distinct** - 94%. The uniform table wrote 448 and only 322 distinct, 72%. Same
content, same seeds: the variety was in the players all along, which is the
strongest argument yet that the register is doing its job.

**Opporsi non costa abbastanza.** Across 100 Chronicles the aggressive character
finishes 32 MIN / 57 VIC / 11 TRI and the cautious one 86 MIN / 14 VIC / **0
TRI** - not one Triumph in a hundred games. And one aggressive player in four is
enough to take Councils from 149 failures to **302 out of 593**: over half of
everything proposed now falls. Blocking is free and it dominates. That is a
balance finding about the resolver, not about the content, and it is the first
one this project has that came from watching people play differently rather than
from watching one player play well.

### Cosa e stato fatto con il risultato

**I due Destini troppo cari sono stati abbassati, e il playtest lo conferma.**

- **Lyra**: la sua Vittoria chiedeva la scorta giurata *e* che le gallerie non
  fossero sigillate - cioe l'esatta negazione della Vittoria di Vaerax, che deve
  sigillarle. Due Destini che sono l'uno il contrario dell'altro li decide
  l'ordine di parola, che e la stessa trappola gia trovata con la promessa. La
  posta resta a lui, e lei passa da **47 Minimi su 50 a 39 / 0 / 11 Trionfi**.
- **Kessa dei Fuochi**: la sua Vittoria stava tutta su `ash_watch`, che si ottiene
  da *una* proposta di *un* Consiglio - se quel Consiglio non lo apre lei, non
  c'e nessun'altra strada. E' il difetto della D-048 un giro piu in la. Tenere
  la montagna in forze si raggiunge da piu Consigli diversi; la veglia sale al
  Trionfo. Da **48 Minimi su 50 a 45 / 5**, e con la domanda della Cenere resa
  raggiungibile (da 1 con soglia 5 a 2 con soglia 4) arriva a 43 / 7.

Seggi bloccati su un solo livello, a tavolo misto: **da 2 su 8 a 1 su 8** - e a
zero quando la domanda della Cenere si apre abbastanza spesso. Il tavolo di
quattro ottimizzatori, sullo stesso contenuto, ne blocca 4 su 8: la differenza
fra i due numeri e tutta la conclusione di questa voce.

### E il prezzo dell'opposizione: provato e tolto

`CNS_FAILURE_SPIRAL` promette nella propria descrizione *"la questione resta
esattamente dov'era, con meno tempo davanti e piu rancore intorno"* e negli
effetti non alzava niente. Aggiungere `+1` sulla Tensione sembrava la correzione
ovvia: una domanda a cui nessuno ha risposto diventa piu rumorosa, e chi la
blocca se la ritrova.

Misurato, **non ha fatto quello che doveva**: i fallimenti sono passati da 302 a
322 su 100 partite - cioe si e bloccato *di piu*, non di meno - e le Chronicle
sono uscite sopra il tetto del §7 in 4 partite su 24, rompendo anche un piano
scritto a mano. Tolto.

Bloccare resta la strategia migliore: l'aggressivo chiude 29/63/8 e il prudente
82/14/4. Non e una cosa che si sistemi con una Conseguenza, ed e la matematica
del resolver del §A5 - che il §A5 fissa apposta e che non si tocca senza
dirlo. **Resta aperta, con i numeri accanto.**

### Il tetto

Il tetto del §7 nel test passa da 7 a 8, con la stessa aritmetica che aveva
spostato la banda nella D-051: il §7 chiede 3-4 sulle **due** Tensioni del
§18.2, cioe 1,5-2,0 per Tensione, e con quattro Tensioni fa **6-8**. Sette era
un'altra stretta che il progetto si era dato da solo, e ha cominciato a fallire
esattamente quando le correzioni hanno rimesso in gioco due seggi: un seggio che
comincia a giocare rende l'anno piu rumoroso. Il **pavimento non si e mosso**, ed
e la meta a cui il §7 tiene davvero.

---

## D-052 — Un anno lasciato a meta si riprende
**implemented in 0.1.14**

`SaveManager` has existed and been tested since 0.0, and nothing on screen ever
called it. The 0.1 roadmap kept the line open with the reason written next to
it, and the reason was right: the file was never the missing piece. `run()` was
three nested loops that always began at Act 1, round 1, so re-reading a half
played world meant dealing every opening hand a second time and playing the year
again from the top.

### Il punto di ripresa

`run()` now starts from the Act and round the world is on. Two details are the
whole of it, and both were wrong in the first draft:

**The saved round is a finished round.** The world carries the round it was
*in*, and the phase says whether that round completed - anything past ACTIONS
means it did, so the next one is where to stand. Off by one, and the round is
replayed: the same actions twice, the same Drift twice, and the year comes out
different from the one nobody interrupted.

**An Act has an ending of its own.** Stop on the last round of an Act and
`end_of_act` has not run: the Echo card is drawn there, and resuming at the
first round of the next Act would skip it - losing the one move the world makes
without being asked. So a resume that lands past the end of an Act plays that
Act's ending first.

The screen autosaves at THRESHOLD_CHECK, the last thing inside a round, so
coming back costs at most the round in progress.

### Il test che conta

Not "the file round-trips" - `test_snapshot_and_save.gd` already had that. The
one that matters is that **an interrupted year ends identical to an
uninterrupted one**: same Councils, same Destiny levels, same number of Effects,
same last twelve lines of the register. Run at two stopping points, and the
second one is on an Act boundary because that is the branch that would otherwise
silently eat a card.

If that test does not hold, the save is not a save, and a campaign standing on
it is lying.

### Verificato anche dove non era scontato

In a Web build `user://` lives in IndexedDB, which is not a given: a page in
private browsing, or with storage blocked, accepts the write and loses it. So
the screen asks `OS.is_userfs_persistent()` and does not offer to resume when
the answer is no - offering a resume that will not be there is worse than not
offering one.

And it was driven end to end rather than assumed: exported, played three rounds
of Chronicle I in a real browser, **reloaded the page**, and the menu came back
with *"C'e un anno lasciato a meta - Riprendi La Carestia Rossa, atto 1 round
3"* - and pressing it carried the year through to Act 3, round 3, Council and
Echo card and all, with no console errors. The first draft of this entry said
browser persistence was untested. It
said so because the first attempt at the test never finished a round, which is
not the same thing as a failure - and the difference between the two is worth a
second attempt before writing either one down.

---

## D-051 — La parola gira, e una Vittoria si deve giocare
**implemented in 0.1.14**

O-15 recorded that six Destiny levels out of twelve were true before anyone
played, and left it alone on purpose. This is the follow-up, and it separates
two things that were being counted together.

### Quello che era davvero rotto

A **Minimum** that is free is correct: it says "you are still at the table".
A clause asking for a tag to be *absent* is a stake, not a gift - Aldric's
Triumph is 3/3 true at the start and he reaches it 2 times in 40, because the
year takes it off him.

What was broken were two **Victories** made entirely of stakes that nothing ever
attacked: the watcher's (`crystal_exploited` absent, `condition:exploited`
absent) held in 37-40 Chronicles out of 40, and the Order's, which 0.1.11 had
made two stakes while fixing something else. Both seats won their second rung by
sitting down. Each now asks for a thing that has to be obtained in a Council -
the seal for the watcher, the written custodianship for the Order - and neither
is free any more.

### E la parola gira

D-036 narrowed proponency from the domain to the focus Region, which stopped one
seat owning a question by standing in two places. It did not stop one seat
owning a question by standing in *the* place: the ranking is deterministic, so in
a stable matchup the same house opens the same Council in all forty measured
Chronicles and the seat on the other side never puts anything on the table. The
Order proposed **0 Councils out of 262**.

So whoever opened the last Council on a question steps aside, if anybody else is
standing where it is being argued. Measured: the Order went from **0 to 39**, and
the first saga's spread flattened from 94/65/50/35 to 80/52/60/59.

### `promise_kept`, e perche la riga era rimasta aperta

Wiring the promise conditions into a Destiny - an open 0.1 roadmap line - showed
why nobody had: **the policy had never once played FORGE**, so a relation never
moved, so a promise was kept for free and could never be broken. The relation
graph was scenery, which is what O-14 said and nobody followed up. The decider
now forges when a live clause asks it to.

It also showed what *not* to ship: a `promise_kept` facing a `promise_broken`
across the table is decided by turn order, because breaking a promise costs an
action and mending one costs an action *plus* the other seat's consent and a
BONDS card. So the promise is a stake on the Guild's Triumph, and the seat that
comes for it is the Ash Lords' *advanced* Destiny - which only exists once a saga
has run. Contested, but not by a coin already flipped.

### Cosa non si e mosso, e perche non insisto

Outcomes still cluster: several seats sit at 37-40 out of 40 on one level, and
two sit near the floor. Four rounds of content changes moved *which* seats, never
the shape. The cause is not the content: with a deterministic optimiser at every
seat and one Council per question, a seat's result is essentially decided by
whether its Destiny points at a Council it can win. No arrangement of clauses
produces a spread out of that.

Recorded and stopped, which is what O-14 asked for in the first place: this wants
a table of real players, not another turn of the knobs. What *is* fixed is
objective and holds: no Victory or Triumph is won by doing nothing, no seat is
locked out of proposing, and both Chronicles stay inside §7's bounds.

The declared band moved from 5-6 to 6-7 as a consequence, and the arithmetic is
the reason rather than the measurement: §7 asks 3-4 over the **two** Tensions of
§18.2, which is 1.5-2.0 per Tension; four Tensions make that 6-8. Every band this
project has declared was tighter than §7 and said so. 6-7 is the first one inside
it - and what pushed the median there was the watcher starting to play for a
Victory he used to be given.

---

## D-050 — Lo schermo non sa chi siede al tavolo
**implemented in 0.1.13**

D-049 shipped a second saga - four houses, six questions, sixteen Destinies, two
Chronicles, validated, measured, playable from the terminal - and **the browser
could not reach a line of it**. Content that cannot be reached is content that
does not exist, which is the sentence D-035 already wrote about propositions the
policy never chose.

Three constants were the whole reason, and every one of them was a thing the
screen had no business knowing:

- `game_screen.gd` held `const SEATS = ["ENT_ALDRIC", ...]` and passed it to
  `setup()`, so the browser could only ever seat the first saga;
- next to it, a table mapping those four ids to display names, used before a
  session exists;
- `map_view.gd` handed out map colours with a `match` on the same four ids, so
  every house of the second saga came out the same grey - on a map that is the
  same six places.

Everything else on that screen was already reading the data set. These were the
last four names in the UI, and they were load-bearing.

### Cosa fa adesso

**The year is chosen before the seat**, because who is at the table is what the
Chronicle says it is and the two sagas seat nobody in common. The list offers
every Chronicle in the data, oldest first, with its year and whether it writes
its questions out or draws them from the library - so a third saga appears in
the menu by existing.

**Colours are handed out by turn order**, not by name: per Chronicle, stable
inside one, and correct for a saga nobody has written yet.

**The rules page names the people actually at the table**, and is redrawn when
the year is chosen rather than after the seat is picked - a step later it was
still describing the age the player had just declined. It also says how many
cards *this year's* Echo deck holds, which stopped being `echo_cards.size()` the
moment D-049 made the deck a function of the Chronicle.

### Il test

`test_ui_knows_no_names.gd`, and it is deliberately blunt: **no Entity id appears
anywhere under `res://ui`**, checked against every id in the data set, comments
excluded. A screen that names a house has an opinion about which saga is being
played, and it is not entitled to one.

Chronicle ids are not checked: two remain as the fallback for "the data set
failed to load and there is nothing to list", which is a default rather than a
choice.

### Verificato dove conta

Not with a unit test - the bug was invisible to those, and would have stayed
invisible. Exported to the web and driven in a real browser: the menu lists all
four Chronicles, picking *Le Citta Libere* seats Maestra Ilve, Kessa dei Fuochi,
Priore Anselmo and le Citta Libere, the questions panel reads l'Acqua Ferma 3/6
and il Debito 2/7, the Red Mountains are ringed in the Ash Lords' green and the
Merchants' Road in the Guild's gold, and the console reports no errors.

---

## D-049 — Una seconda saga sulla stessa mappa
**implemented in 0.1.12**

The engine has always claimed to be data-driven. This is the first time anything
checked: a second saga - new plot, new houses, new objectives, new questions -
authored entirely as JSON, with **no change to any rule**. What did have to
change was three places where the first saga's content had quietly become part
of the engine's assumptions.

### Le Citta Libere

Eight centuries after Aldric, on the same six places, because the map is the
world and the world does not restart. There is no crown and there has not been
one for eight hundred years. Four seats: **la Gilda del Sale**, which owns no
city and keeps the ledger of all of them; **l'Ordine del Vetro**, heir to Lyra's
school turned into a faith, custodian of a shard nobody living has seen;
**i Signori della Cenere**, who hold the Red Mountains and dig lower every year;
**le Citta Libere**, seven towns that meet only when they cannot avoid it.

Six questions - l'Acqua Ferma, il Debito, la Reliquia, la Carta, i Senza Citta,
la Cenere che Sale - six Councils, thirteen Consequences, sixteen Destinies,
twelve Echo cards, and two Chronicles: CHR_03 written out, CHR_04 dealt from the
library.

### Le tre cose che non erano contenuto

**Il mazzo Echo era uno solo per tutto il gioco.** Adding twelve cards reshuffled
the first saga's deck and changed years nobody had touched - the three authored
sim plans all broke. A Chronicle's deck is now built from the cards that could
matter *that year*: a card whose eligibility names a question the Chronicle is
not asking can never legally be drawn, and leaving it in the pile made one
saga's content a function of the other's. The first saga's plans went back to
byte-identical the moment the filter landed.

**La mappa portava il controllo della prima saga.** `control` lives on the
Region, so the Red Mountains still answered to Vaerax in a Chronicle where
Vaerax does not exist. `starting_control` on the Chronicle overrides it. This
was not cosmetic: the Ash Lords' whole Victory hangs on holding a Region, and
they held none, so they reported MINIMUM in 40 Chronicles out of 40.

**I probe avevano i seggi scritti dentro.** Eleven CLI tools carried
`const SEATS = [ENT_ALDRIC, ...]`. They read the Chronicle now.

### E una lezione della D-048 che si e' ripresentata due volte

Authoring the second saga reproduced the same failure twice, from a standing
start, which is the best evidence that it is structural and not a slip:

- **CNS_ASH_WATCH era irraggiungibile.** It sat on a domain-bound Council, and
  the Tension that would have used it declares its own template - so the
  proposition was never on any table. The Ash Lords' Victory depended on it.
- **Due seggi avevano bisogno dello stesso Consiglio, e a proporlo e' uno solo.**
  Fixing the Ash Lords' proponency took it away from the Order, whose Victory
  then became unreachable in turn. The fix was not another swap: a custodian
  does not win by proposing, it wins by preventing, so its Victory is now two
  stakes - the vault not opened, the galleries not abandoned - and its Triumph
  keys on `discovery:relic`, which a *non*-proponent can obtain by declaring a
  condition clause.

Both were found by `run_destiny_probe.gd`'s third table, which is the one D-048
added for exactly this: **which Councils a seat actually gets to propose**.

### Misurato

CHR_03 over forty seeds: 6.55 Councils per Chronicle, median 7, range 5-7 - the
same shape as CHR_01's 6.10 and inside §7's hard bounds. Every seat wins
sometimes (M38/T2, M12/V28, M1/V39, M2/V38), which is the bar D-048 set and
which the first three drafts of this content did not clear.

Two ten-Chronicle sagas played end to end: the first covers 999 years and writes
**35 Truths, all 35 distinct**; the second covers 753 years and writes 38, all
distinct. The audit that started this whole line of work got 12 distinct
sentences out of 28.

### Cosa resta aperto

O-15 applies to the second saga as much as the first: the Guild reports MINIMUM
in all ten Chronicles of the played saga, and the seats that win, win early and
then hold. Recorded, not tuned - same reason as before.

---

## D-048 — Un Destino che si vince in due mosse, e uno che non si vince mai
**implemented in 0.1.11**

The scholars' seat was broken at both ends of a saga, and neither end showed up
in an outcome table.

### Vinto al round due, quaranta volte su quaranta

`DST_LYRA` asked for: a Discovery, presence in the Ancient Mines, the mines not
sealed, two Discoveries, the Awakening not exploded, the road still open. Seven
clauses, and **five of them were true before the first token was placed**. The
other two were Discoveries - and a Discovery costs *one action*: SCHEME on a
veiled Tension. Lyra has two Action Opportunities in round one and CHR_01 deals
two veiled Tensions.

So her whole ladder - Minimum, Victory *and* Triumph - closed in **Act I round
two, in 40 Chronicles out of 40**, after which she spent the remaining seventeen
Action Opportunities drawing cards she had no use for. The end-of-year report
said TRIUMPH; the register said eighteen turns of shopping. That is O-14's
"Lyra reaches Triumph in four out of five", and the cause was not that her
Destiny was generous - it was that nothing in it had to be played for.

The new `run_destiny_probe.gd` asks the two questions that make this visible, and
the first needs no dice at all: **what is already true before the year starts**,
clause by clause, and **at what round is each seat's ladder closed**.

### And never won at all

`DST_LYRA_TAUGHT` - the Destiny she *advances to* under D-045 - asked in its
Triumph for `crystal_measured`, `petition_heard` and `parley_held`. **No
Consequence in the game writes any of the three**, and none is on the table at
the start. It was not hard to win: it was impossible, which is why the ten-
Chronicle saga reported that seat at MINIMUM ten times out of ten.

Nothing caught it because a tag is a string: it validates, it loads, and it
evaluates to false for ever. `test_data_boot.gd` now walks every
`state_tag_present` clause of every Destiny and insists something in the world
can put that tag there - Consequence, Echo card, or the opening position. Only
`present` is checked: a clause asking for a tag to be *absent* is a stake, not a
goal, and a tag nothing writes just makes it a stake nobody can take.

### What was changed, and what was not

Two clauses added to `DST_LYRA`, none removed:

- **Victory** now also asks for `escort_sworn` - twelve people who answer for
  every load with their own name, sworn in a Council. That is the half of the
  title that was never implemented: *poter tornare a guardare*. Knowing something
  is the Minimum; being able to go back and check is the Victory.
- **Triumph** now also asks that nobody put a guard on the study
  (`study_supervised` absent) - which is the author's own idea of the scholar's
  full win, since that clause was already in `DST_LYRA_TAUGHT`.

`DST_LYRA_TAUGHT`'s Triumph was rewritten onto tags that exist, keeping the
meaning - *what remains taught* is knowledge others can still reach and verify:
the galleries not sealed, an escort sworn, no guard on the study.

A third clause was tried and reverted: `discovery:crystal` on the Triumph, "and
she measured the Crystal herself". It reads well and it measured badly - her
Triumph went to 0/40 and the Council count left its band at 6.20 - so it is
recorded here rather than shipped.

### Measured

Forty Chronicles per figure.

| | prima | dopo |
|---|---|---|
| scala chiusa in anticipo (Lyra) | **40/40**, round 2.0 | 9/40, round 7.0 |
| Lyra | MIN 16 / VIC 4 / **TRI 20** | **MIN 34** / TRI 6 |
| Consigli CHR_01 | 5.70 | 6.10 |
| Consigli CHR_02 | 4.65, da 2 a 7 | 4.83, da 3 a 6 |

The three sim plans still pass and still produce byte-identical output on a
second run. Plan C's description was corrected: it claimed the year ended with
knowledge "public and verifiable", and what the plan actually plays is
`P_GUARDED_STUDY` - the Crystal measurable, but in front of a keeper. Under the
new pricing that is precisely what falls short of what Lyra wanted, which makes
it a better ending than the one the text claimed.

---

## D-047 — Un anno non si chiude senza aver deciso niente
**implemented in 0.1.10**

A ten-Chronicle saga produced **three years with zero Councils**. Not close ones
- zero: three Chronicles in which nobody proposed anything, nothing was decided,
and the register got a blank page. §7 asks for a report below two.

The first guess was that inheritance was suppressing the Tensions across a saga,
because the same Chronicle measured standalone over forty seeds never fell below
one. That guess was wrong, and the instrument that disproved it - `run_silence_
probe.gd` - is the useful part of this entry: per Chronicle it prints, for every
question in play, where it started, how many chips the **world** gave it, how
many pushes the **table** gave it, and where it ended relative to its threshold;
then, per seat, the Destiny it carries and what that Destiny actually asks it to
push. Counting outcomes says a year was quiet. Counting pushes says why.

### What the pushes said

Three separate causes, stacked, each real on its own.

**The world alone can never bring a question to a head.** Drift deals one chip
per round spread across every question in play - nine chips over four questions -
while the smallest gap between a question's opening value and its threshold is
three. So the world can leave **every question in play short at the same time**,
and in the silent years it did: the nearest one finished a single chip under its
threshold, three times out of three. Every Council in this game needs a seat to
push. There was no floor at all; there was only the table.

**And the table had stopped playing.** In the silent years three seats out of
four spent **all eighteen Action Opportunities on ACQUIRE** - drawing cards for a
Council that would never open. The register recorded eighteen turns of shopping.

**Because a seat stopped the moment its nearest rung asked nothing of it.** The
policy played the lowest rung of its ladder it had not secured and nothing else.
That is right about the order and wrong about the stopping: a rung can be open
and still ask nothing of the Tensions - "stand on the Red Mountains" is answered
by walking there - and a rung whose remaining clauses are all *negative* ("the
mine is not sealed", "the road is still open") asks nothing of anybody. A seat
focused on one of those would not even reach for the Victory above it.

### The floor

`minimum_confluences` on the Chronicle. When an Act closes and the year is short
of the Councils it guarantees, the question that came closest is brought to a
head: *"L'anno non si chiude con la domanda ancora aperta."*

The quota grows with the Act - `floor * act / acts`, rounded down - because only
one Council opens per round (§7), so a floor of two checked once at the very end
could only ever deliver one. With three Acts and a floor of two that is nothing
owed after Act I, one after Act II, two after Act III, which leaves the first two
thirds of a Chronicle exactly as they were.

The push is an **Effect** like everything else - system source `YEAR_END`, in the
register, with an inverse - and not a rule reaching into the Tension directly.
`minimum_confluences: 0` turns it off: a Chronicle is allowed to say that silence
is an acceptable ending for it.

### Why a floor rather than a re-tuned Drift bag

The alternative was to weight the drift bag so one question always crosses. It
was rejected for two reasons. It would change **every** Chronicle, including the
seven in ten that were working; and it would make the authored
`drift_distribution` decorative, since the guarantee would always override it.
The floor fires only when the thing it guards against actually happened, and a
loud year never learns it exists - which a test asserts.

### What it measured out at

Standalone, forty seeds each. CHR_01 is **unchanged** - 5.70 mean, median 6,
range 3-8, never below §7's floor even before this. CHR_02 went from a mean of
4.17 and a range of **1**-7 to a mean of 4.65, median 5, range **2**-7, with 0/40
below the floor and 48% inside the declared band. Across four ten-Chronicle sagas
- forty chained Chronicles - there is no longer a single silent year.

The table that only ever calms things down - the O-9 stress test, four seats
spending every action holding every question below its threshold - went from 1.75
Councils per Chronicle to 2.48, which is the first time that table has sat above
§7's floor rather than under it.

The three sim plans still pass and still produce byte-identical output on a
second run.

### What this does not fix

Lyra's whole ladder - Minimum, Victory *and* Triumph - closes in **Act I round
two**, on two SCHEME actions, after which she has genuinely won and correctly
has nothing left to play for. That is a Destiny that is too cheap, and it is
content, not rules: it belongs with the scholars' seat finding (`DST_LYRA_TAUGHT`
depending on a Consequence the policy never triggers), not here.

---

## D-046 — Una casa non finisce i nomi
**implemented in 0.1.9**

D-045 gave every mortal seat a hand-written list of successors. Four names each.
The very first ten-Chronicle audit of the feature wore them out at the sixth
jump and sat a **second "Re Serane" four centuries after the first** - with the
first one's description attached, calling him Aldric's grandson in the year
1240. It read as a bug, and it was one: a saga has no agreed number of
generations, so any finite list is a list that runs out.

### A house declares how it makes names, instead of listing them

`name_grammar`: a pattern with slots (`{given} {epithet} {ordinal}`), a bag of
given names, and whatever else that house uses. The first generations stay
hand-written - those are the characterised ones, and they are worth keeping -
and the grammar takes over from the fifth on.

The choice is a **pure function of the generation**: no RNG, so a name is stable
no matter when it is asked for and a saga stays replayable from its seed.

Numbering is what makes it both endless and right: houses do reuse names, which
is exactly why they number them. Vharn, and four generations later Vharn II.
That is a tradition, not a repeat. Thirty generations, thirty distinct names, in
a test.

### Two things the first attempt got wrong

The generated pool started with the same given names as the hand-written four,
so generation 5 was "Re Serane" again - the very bug being fixed, one loop
further out. And titles cycled independently of names, which produced "Re
Ottima" and "Regina Corvin": in Italian that does not read. The title now
belongs to the given name, because a house knows what its own people are called.

---

## D-045 — Fra una Chronicle e l'altra passano secoli, e il tavolo cambia
**implemented in 0.1.8**

A ten-Chronicle audit produced a register of 28 Truths containing **12 distinct
sentences**, and the most frequent was *"la corona fu divisa in due, e di Eredan
nessuno seppe piu dire a chi rispondesse"* - **six times in ten years**. A crown
does not divide six times. It happened because `inherit_from` added exactly one
year and sat the same four people back down with the same unfinished question.

### The id is the seat, not the person

`ENT_ALDRIC` is the house that holds Eredan. Who is sitting in the chair is
`world.entities` state - name, Destiny, generation - and it changes between
Chronicles. Keeping the id fixed is what lets every Scar, tag, control marker
and relation the previous Chronicle wrote go on pointing at something that still
exists. Everything that shows a name now asks `service.name_of()`; the data file
holds the founder's name and nothing else.

Who survives a jump is authored, not guessed: `persistence` is MORTAL (a person),
COLLECTIVE (a people, which changes without ending) or ETERNAL (a thing under a
mountain). A MORTAL seat crosses 25 years or more with a new name from its own
`successors` list.

### The jump is declared by the Chronicle

`years_after_previous`: an integer, or a `{min, max}` drawn with the seeded RNG.
`CHR_01` is the written year and says 1. `CHR_02` - the library Chronicle that
deals its own questions (D-028) - says 20 to 200, so a saga of library
Chronicles covers centuries and does it reproducibly.

### The three inheritances, each with its own condition

The question was whether a successor inherits the position, the relations, or
the Destiny. The answer is all three - **but if all three carried
unconditionally we would be back to the crown dividing every other spring**. So:

- **La posizione, sempre.** The map is the world and the world does not restart.
- **I rapporti, ma il tempo li smussa.** Across a jump of 50 years or more every
  relation moves one step towards NEUTRAL: a war is remembered as a grudge, an
  alliance as a courtesy. The tags stay whatever happens, because those are the
  things that were written down.
- **Il Destino, ma solo di chi ha fallito.** A seat that reached VICTORY or
  TRIUMPH draws the next thing it wants from its own `destiny_pool`; a seat that
  came out at MINIMUM tries again with the same goal. That is what keeps a
  question alive across generations instead of across springs - and it is the
  one that fixed the audit.

Eight Destinies now, two per seat: what it starts with, and what it wants once
it has that.

### Measured, on the same ten seeds

| | prima | dopo |
|---|---|---|
| anni coperti | 812 → 821 | 812 → **1767** |
| frasi distinte nel registro | 12 su 28 | **19 su 24** |
| la frase piu ripetuta | **6 volte** | 3 volte |
| persone che si sono sedute al tavolo | 4 | **12** |

The three sim plans come out **line for line identical** - the same Councils,
the same rolls, the same endings - because a single Chronicle does not have a
jump to make. What changed is `world.entities`, which now carries a name, a
Destiny and a generation, so the saved JSON of a Chronicle is three fields
larger than it was.

---

## D-044 — Propp was in the deck and nowhere on the screen
**implemented in 0.1.7**

Two card decks exist. The 48 Assets are yours: you draw them, hold them, spend
them, and since 0.1.5 every one of them says what it does. The other deck is not
yours at all - **24 Echo cards, one per function of Propp**, in four dramatic
families of six - and one is drawn at the end of every Act from the pool that
Act allows: Act I only PRESSURE, Act III mostly RESOLUTION. The shape of a story
sits in the deck rather than in a narrator's head (§15).

They move the world on their own (28 direct Effects and 11 Consequences across
the deck), two of the twenty-four **convene a Council on the spot**, and each one
writes `function:<NAME>` into the world so a later card can require an earlier
one - a Return needs a Separation to return from. That is the whole Propp idea,
and it lives in authored data: the engine knows no function names (D-030).

**On screen it was a paragraph scrolling past in the transcript.** Three times a
Chronicle the story turns, and a player saw the turn only if they happened to be
reading the log. Exactly the illness the Council had before 0.1.2, and the same
cure: the card takes the middle of the screen, in its family's colour, with its
text, its Propp function in Italian, **what it just changed**, and a button.

### `act_echo_drawn`, and an Effect said out loud

One signal on the controller, emitted after the hooks land, carrying the card and
the Effects it applied. Nothing in the engine listens to it; it exists so the
screen can say what the card *did* and not only what it says. Guarded by a test
that runs a whole Chronicle and asserts three cards, each with at least one
Effect, each Effect renderable.

`scripts/core/effect_text.gd` is that rendering: an Effect to one Italian line -
*La Successione sale di 2*, *Eredan: condition:contested*, *Cicatrice in Valle
Verde: ...*. Unknown types report themselves by name rather than staying silent,
because a card that quietly did something is worse than a card that says
`SET_ENTITY_TAG`. The one line it deliberately swallows is the `function:` tag:
that is the deck's plumbing, not the player's world.

### What a card looks like now

> PRESSIONE — qualcosa si accumula
> **Presagio**
> funzione di Propp: presagio
> *Un segno che nessuno sa leggere del tutto e che nessuno riesce a ignorare del
> tutto.*
> COSA HA CAMBIATO
> · Il Risveglio sale di 1

---

## D-043 — The second Chronicle was written, and unreachable
**implemented in 0.1.6**

`CHR_02` has existed since D-028 and is the whole point of the library model: it
names no questions, it **draws four from the six** in the library, so two runs
are not the same year. The CLI could play it (`--chronicle=CHR_02`). The browser
could not: `_play` had `"CHR_01"` written into it.

The menu now asks three things instead of one - seat, year, world - and the
third is the seed. The seed has been printed at the top of every Chronicle since
0.0 *precisely* so a year worth talking about can be played again, which it
could not be until there was somewhere to type it back in. It also offers the
last seed back, because the most likely thing anyone wants to replay is the game
they just finished.

The rules page re-renders for the chosen year, and that turned out to matter
more than expected: it read `chronicle["tensions"]`, which `CHR_02` does not
have. A Chronicle either names its questions or draws them, and a rules page
that assumed the first would have crashed on exactly the Chronicle a returning
player picks. It now reads the pool and says so - *questa Chronicle ne pesca 4
fra queste*.

### And the relations, which the Destinies count

Where you stand with the other three was public information the browser never
showed. It was readable only inside a button offering to break it (*"Rompi i
rapporti con Lyra (ora NEUTRAL)"*), and FORGE spends an Action Opportunity
moving it. Destinies count these levels: a player who cannot see them is being
scored on something invisible. Three lines under the year's questions, coloured
along the ladder from `ENEMY` to `BOUND`.

---

## D-042 — A card that says what it does, and the last decision nobody was asked
**implemented in 0.1.5**

Two holes left over from 0.1, both of the same kind: the rules gave a player
something and the game kept it.

### The recovery

§12.3: when a proposal falls, whoever opposed it **keeps one of the cards they
put down**. `SeatDecider.choose_recovery` handed that straight to the policy,
which took the strongest recoverable card. It was the only decision in the rules
that a person playing the game was never offered - at the terminal and in the
browser alike.

It is asked where the rules ask it: *before* the roll, alongside the commits,
because the controller collects the recovery and only uses it if the Council
falls. So the question is a real one - you name what you would save from a
defeat that has not happened yet - and it is asked only when there is something
to decide. A seat that did not oppose has no recovery; a card whose own rule
says it never comes back is not offered, because a choice the resolver is about
to ignore is worse than no choice; and one card left standing is not a choice
either.

### The card

A hand card carried a title, a family and a number. With the 0.1.3 library that
is not enough to choose with: a quarter of the cards do something to the world
when committed, and "si scarta comunque" is the difference between spending a
card and lending it.

`scripts/core/asset_text.gd` turns an Asset into a sentence, once, for both
front-ends: the bonus in the terms the resolver applies it (`+2 se ti opponi`,
not `+2`), what becomes of the card, and what committing it costs. Every line is
built from the fields the resolution actually reads, so a card cannot say one
thing and do another - guarded by `test_asset_text.gd`, which checks the printed
value against `ConfluenceResolution.asset_value` for every card in the library,
in and out of theme.

The terminal prints it under each commit option. The browser puts it in the
card's tooltip and, in a Council, on the commit cards themselves:

> Interdetto — authority, vale 3
> si scarta comunque · costa: la domanda in gioco sale

### A bug the same code found

The hand computed its own value - `strength if relevant else 1` - which ignored
`confluence_modifier`. Mercenari (forza 1, +1 sempre) is worth 2 and the card
said 1. It now calls `ConfluenceResolution.asset_value`, the resolver's own
function, so the number on the card is the number that enters the sum. This is
the second time this year a hand has shown a value the resolution would not give
(D-040); it is the last time it can, because it is no longer possible to compute
it separately.

The tooltip is drawn rather than defaulted (`_make_custom_tooltip`): Godot's
default one does not wrap, and a card whose authored line runs to 130 characters
painted itself straight across the hand below it.

---

## D-041 — The rules are on the screen where the game is
**implemented in 0.1.4**

A player opened the page, chose a seat, and was handed fourteen buttons. The
rules existed - `docs/RULES_V0_2.md`, complete and current - in the one place a
person sitting down to play will never look.

### The page

`ui/help_panel.gd` takes the middle of the screen, the same piece the map and
the Council share, because a player reading the rules is not looking at the
board and the board is where there is room to read. It opens by itself at the
seat menu, closes itself when a Chronicle starts, and is one always-present
button away for the rest of the year - outside `_buttons`, which is cleared
after every question.

Half of it is written from `DataSet`: the shape of the year, the four questions
with their thresholds and the families each one listens to, the Regions, the
hand limit, the commit limit. A rules page that can fall out of step with the
rules is worse than no rules page, so everything that *can* drift is read rather
than typed.

### The line above the choices

The page explains the game once. The line explains *this turn*, every turn:

> La domanda piu vicina a scoppiare e La Carestia, a 3 passi. (e 2 che non puoi
> ancora leggere)

> La Carestia e a un passo dalla soglia: un'altra spinta e si apre il Consiglio.

> Consiglio aperto: qui valgono forza piena le carte wealth, people, authority.

It reads exactly what the seat is entitled to read - `visible_tension_value`
returns -1 for a veiled question nobody has scouted - so it can say *there is
something here you cannot see* without ever saying what. And the last form is
the one that ties the whole screen together: it names the families that count,
while the hand below each card says `vale 2` or `vale 1` for that same question.

### Still no rule in the screen

Neither piece decides anything or asks the rules a question a decider does not
already ask. The line reads thresholds and visible values through the same
services `StatusPanel` has used since 0.1; the page reads authored data. The
seam is where it was (D-038, D-039).

---

## D-040 — 48 Assets, and the outcome table they moved
**implemented in 0.1.3**

§19.4's full Asset list: 12 cards become 48, eight per family. The cards were
the easy half. The half worth recording is that adding them **broke the outcome
table**, and that the number which showed why was not the one being watched.

### What the set is

One word - the rarity - fixes everything mechanical about a card:

| rarità | forza | copie nel mazzo | per famiglia |
|---|---|---|---|
| COMMON | 1 | 4 | 4 carte |
| UNCOMMON | 2 | 2 | 2 carte |
| RARE | 3 | 1 | 2 carte |

22 cards per family deck, 132 in the box. A player who has seen a family twice
knows what is in it, which matters more than it sounds: ACQUIRE draws two and
keeps one, so knowing the deck is knowing what the other draw probably was.

Every family carries the same shape: two cards that pay on the Oppose front,
one that counts for more when the question is its own, and two rares that are
worth 3 and cost something on the way out. Every strength-3 card is discarded
whatever happens **and** does something to the world when committed - it raises
the Tension, or hands the rival a foothold where the argument is, or empties
your own. That is guarded by a test: a card worth 6 in a relevant question with
no downside is not a choice, it is the correct play.

`on_commit_effects` was exercised by exactly one card in 0.0 (O-3). It is now on
thirteen.

### The outcome table broke, and the average said nothing

Measured over the same 40 Chronicles, before and after:

| | Failure | con Costo | Successo | Decisivo |
|---|---|---|---|---|
| 12 carte | 16% | 13% | 38% | **33%** |
| 48 carte, primo tentativo | 15% | 11% | 26% | **49%** |

Half of every Council passing without discussion is the same illness as O-4 in
the other direction: two of the four bands stop meaning anything.

The strange part: **the average margin barely moved** - 3.23 to 3.37 - and S was
identical to two decimals. Four separate attempts to fix it by re-weighting the
set (fewer copies of the strong cards, more copies of the weak ones, bigger
Oppose bonuses, dropping strength 3 entirely) each moved the outcome table by
almost nothing, because each was aimed at the average.

`cli/run_margin_probe.gd` printed the distribution instead, and the cause was
immediately visible: the 12-card set piled its mass on **M = +4**, one point
below the Decisive band, because with two cards per family a commit was almost
always 2+2. A wider library smooths the distribution and pushes that pile one
point right - over the line. The old 33% was partly an artefact of a library too
poor to produce anything else.

### The fix, and why it is the curve

The lever that worked was the shape of the curve, not the weights: relevance
moved off the strength-2 cards and onto a strength-1 card in each family, and
one strength-2 card per family became a strength-1 with a small always-on bonus.
A prepared commit is worth about 4 again instead of 6.

| | Failure | con Costo | Successo | Decisivo |
|---|---|---|---|---|
| 48 carte, com'è ora | 21% | 15% | 30% | 34% |

Decisive is back where it was and Failure is up five points - more Councils are
genuinely contested, which is what a wider library was supposed to buy.

The resolver was not touched. §A5's bands are the specification; the content is
what gets tuned (D-023).

### The cost, stated

- **Councils per Chronicle: median 5 → 6**, and one Chronicle in forty reaches 8
  against §7's ceiling of 7. `test_balance` allows 10% outside the band and it
  passes, but the drift is real and it is the number to watch in 0.2.
- **The three sim plans came out differently** and were re-measured rather than
  re-tuned: the stories still hold (the grain accord passes unopposed, the broken
  council fails twice, the opened mine plays all four bands), the outcome
  sequences in their `expected` blocks are new. Plan A's authored Council now
  binds to index 1, because with a full library the Succession opens first.

### A bug the measurement found

`ui/hand_view.gd` had been drawing a relevant card as `authority · 2 ×2 = 4`
since 0.1.1. §9 says an Asset is worth its full strength when its family is
relevant and **1** otherwise - relevance does not double anything. The card was
telling a player their hand was worth twice what the resolver would give them.
It now reads `authority · vale 2`, and `vale 1` when the question is not its own.

---

## D-039 — A choice knows what it is about; the screen decides where to put it
**implemented in 0.1.2**

0.1 drew a map and then asked where to move in a list beside it. Both halves
worked and the pair was absurd: six Regions on screen, and the way to walk into
one of them was to read "Metti una presenza in Terre Nahr" off a column of
fourteen buttons.

### What was added, and what deliberately was not

`SeatDecider` now hands `io.choose` a third argument: `subjects`, one entry per
choice, saying what that choice is *about*. Today it holds exactly one thing -
`{"region": "REG_X"}` on a MOVE - and it is a fact about the choice, not an
instruction about the screen.

The alternative was to let the map ask the rules which Regions are reachable.
That is the version to avoid: it puts a legality query in a drawing node, and
two answers to "where may I go" that can disagree. Instead the map is handed a
set of Regions and what to report when one is pressed, and it can no more invent
a legal move than a button could. The terminal takes the same argument and
ignores it — a numbered list is already all the map a terminal has.

So: the screen sorts the choices between the map, the open Council and the side
column; it does not judge them. Every entry it puts on the map is an entry it
would otherwise have put in the column, unchanged.

### The moment the game decides something was never on screen

`ConfluenceController.resolve()` runs F-K in one atomic pass and clears
`current` on the last line. Nothing in the loop ever came back to draw the
result, so the roll, the sum and the Consequences existed only in the transcript:
the `Fattore Mondo` line added in 0.1.1 could not be seen at all.

The screen now keeps the snapshot it is handed at `RESOLVED` and stops on it -
board, stances, commits, the arithmetic, what it wrote - until the player presses
Avanti. No decider is asked anything, because there is nothing to decide. It is
the screen's own pause and it lives entirely in `ui/`.

### `result["consequence_ids"]`

One engine addition, and the reason for it is the seam: which Consequences apply
depends on the outcome (success takes the proposition's own, plus the cost or the
decisive pool; failure takes the failure pool). Re-deriving that in the board
would be the resolution order written down twice, in a place that could quietly
fall out of step with §12.2. So the resolution reports what it applied, by id and
in order - the list the log has printed since 0.0 - and the board looks the ids
up. The three sim plans come out byte for byte identical.

### What the middle of the board holds now

Before the vote, the Consequences the proposition on the table would write, with
a Scar marked as a Scar. After it, the ones that actually landed. "Sostieni" and
"opponiti" mean nothing until you can read what you are supporting, and until
0.1.2 the only way to find out was to lose and read the log.

### Two things the browser found again

The arrow in `1d6 = 6 → +2` is a tofu box in the fallback font a Web export
ships - the same class of bug as the check mark in 0.1, in the one line a player
reads to check the arithmetic. It is `->` now. And the whole feature was verified
by clicking a Region in Chromium and watching a presence appear in it: a map that
lights up and does nothing when pressed is a bug no headless run can see.

---

## D-038 — The Chronicle can wait for a click
**implemented in 0.0.14**

ECHOES runs in a browser, on GitHub Pages, from `godot/ui/`. Getting there
needed one engine change, one refactor, and three bugs that only a real browser
could find.

### `run()` is a coroutine now

The controller drove the whole Chronicle in one synchronous call. A terminal can
block on `read_string_from_stdin` inside that call; a browser cannot block on a
click without freezing the page and never receiving it.

So the six decider calls are `await`ed, and `run()`, `play_act()`, `play_round()`
and `run_confluence()` became coroutines. **Nothing else changed.** A decider
that answers immediately never suspends - `await` on a synchronous call returns
straight away - and the proof is that the three sim plans come out **byte for
byte identical** before and after, as do all six probes.

The cost was 22 call sites needing `await`, which the compiler found one
transitive layer at a time. That is the right kind of cost: mechanical, and
impossible to get half-right silently.

### `SeatDecider`, and why injection beat inheritance

The terminal seat and the browser seat differ in exactly two things: how a line
is shown and how a choice is collected. Everything else - which actions the
rules allow, what the board looks like from one seat, which Tension shows a
number to whom - must be the same code, or it is two implementations to keep in
agreement.

The first attempt had the browser decider `extend` the terminal one. **The
exported build could not resolve it**: `extends "res://path.gd"` does not survive
export, while `preload` does. That is exactly why this codebase uses
`const X := preload(...)` and no `class_name`, and the rule held here too.

So the shared logic moved to `scripts/seat/seat_decider.gd` with an injected
`io` - any object with `say(text)` and `choose(prompt, labels) -> int`.
`cli/terminal_io.gd` implements it with stdout and stdin; `ui/game_screen.gd`
*is* the implementation for the browser. A null `io` means nobody is watching,
and every choice defers to the policy - which is what the smoke test uses, and
why it can assert that an unwatched table plays exactly like four policies.

### Three bugs only the browser found

Playwright loaded the exported page and clicked through a Chronicle. Each of
these passed every headless check first:

1. `ui_decider.gd` extended `cli/human_decider.gd`, and `cli/*` is excluded from
   the export. Unresolvable script, blank page.
2. `scripts/seat/` was missing from the pack entirely: the export ran before the
   import cache had seen the new folder. The workflow now imports first.
3. `policy_decider.gd` lived in `cli/`. It is the opponent - the browser needs
   it. Moved to `scripts/seat/`, where a seat played by a machine belongs.

None of the three is exotic, and none would have been caught by anything short
of opening the page. A build that compiles and exports is not a build that runs.

### Single-threaded on purpose

The threaded Web export needs `SharedArrayBuffer`, which needs COOP/COEP
response headers, which GitHub Pages cannot send. `web_nothreads_release` is the
template used. A turn-based game that spends its life awaiting a click has
nothing to gain from threads and everything to lose from not loading at all.

### What this is not

A map, a Confluence Board, art. It is a transcript and a column of buttons -
0.1's work, unstarted. What it is, is the seam holding: the screen decides
nothing and reads no rules, so the game in the browser is the game the terminal
plays and the tests measure.

---

## D-037 — The fifth decider is a person
**implemented in 0.0.13**

The ChronicleController has never known who its players are. It asks a
duck-typed `decider` and applies whatever comes back, and four of those existed
for machines: ScriptedDecider replays authored plans, PolicyDecider plays to
win, SuppressorDecider only ever calms things down, and the stance probe borrows
PolicyDecider to read its own mind. `cli/run_hotseat.gd` adds the fifth, and the
first one that does not decide anything itself.

**No rule was special-cased for it.** That is the result worth recording: the
decider seam, chosen in 0.0.1 so a simulation and a UI could share one engine,
held without a single change to the controller.

### Why now

The measurements have run out of things to say. D-034, D-035 and D-036 each
found the *instrument* at fault rather than the rules, and what is left open is
O-14 — the crown sits at Minimum in 32 Chronicles out of 40 — which is a question
about whether a game feels right. No probe answers that. The honest next step is
to stop modelling a player and let one sit down.

### What a seat actually needs to see

The board prints from one seat's point of view, and every line of it is
something that seat is already entitled to know: the year's questions with the
numbers *that viewer* can read (a veiled Tension shows nothing to anyone who has
not scouted it, §11.1), the map, the hand, and the Destiny as a ladder with the
rungs that currently hold already ticked. A player who cannot read their own
goal cannot steer towards it.

The action menu is built by asking the resolver, not by listing templates: every
entry has already passed `can_execute`, so a person is never offered something
the rules will then refuse. That is the query the 0.1 Confluence Board will draw
as buttons.

### The empty string that locked players out

`OS.read_string_from_stdin` returns **the same empty string** for a bare Enter
and for end-of-input. They cannot be told apart — measured, not assumed.

The first version tried anyway: on an empty read it latched itself off and handed
the rest of the Chronicle to the policy. The effect was that **a player who
accepted a single default was locked out of their own game**, silently, with
nothing crashing.

The fix is to stop trying. An empty answer means "you decide" and hands that one
choice back to the policy — which is also exactly the right behaviour at
end-of-input, where every remaining prompt reads empty, takes the default, and
the policy finishes the Chronicle. One meaning, no ambiguity, and piping a file
of answers becomes a faithful way to drive the game.

`tests/smoke/test_hotseat.gd` guards it: a table of four "humans" who answer
nothing must produce a Chronicle **identical line for line** to one played by
four policies, and every action the menu offers must be one the resolver accepts.

---

## D-036 — Who raises a question is decided by the place, not the domain
**implemented in 0.0.12** · closes O-12, closes O-13, closes the Vaerax lock

Three open findings, fixed together because they turned out to be one problem
seen from three sides: **nobody had a reason to be in the room.**

### The rule change

`determine_proponent` read §12.2 C's "most presence in the Tension's Regions" as
the whole **domain**. It now reads it as the Region the question is actually
about — the same focus the narrative and the Consequences already use.

Counting the domain let one Entity own a question for ever. `domain:ANCIENT` is
two Regions and Vaerax's Destiny plants him in both, so all 40 Councils on the
Awakening were his and he was never a voter on the only Tension he cares about.
D-034 called that a content shape; it is not. Two candidate widenings of the
domain were tried and measured, and **neither breaks the lock** — one makes it
worse, raising 107 Councils that are also all his. Counting the focus asks a
narrower and truer question: who is standing in the place we are arguing over?

| domanda | proponenti prima | proponenti dopo |
|---|---|---|
| Le Vie Interrotte | 2 | **4** |
| La Successione | 1 | 2 |
| La Carestia | 2 | 2 |
| Il Risveglio | 1 (Vaerax 40/40) | 2 |

### O-12: two Tensions nobody had sworn anything about

Every `tension_limit` in CHR_01 named the Famine or the Awakening. The Succession
and the Roads were in nobody's Destiny, so those Councils could not produce a
fight over the quantity itself.

The first attempt added `tension_limit` clauses and **made it worse**: a ceiling
makes the policy spend actions holding the Tension down, and holding it down
makes the question stop being asked. The Roads went from 36 Councils to 6.

The fix is that a stake does not have to be a `tension_limit`. A **tag** weighs on
propositions and drives no actions at all:

| | posta | dove |
|---|---|---|
| Aldric | `crown_divided` assente | Triumph |
| Nahr | `crown_divided` presente | Triumph |
| Lyra | `condition:cut_off` assente sulla Strada | Triumph |
| Vaerax | `condition:cut_off` presente sulla Strada | Triumph |

Two pairs of directly opposed stakes on the same tag — the same crown and the
same road, wanted two incompatible ways. And they sit at **Triumph**, not
Victory, for a mechanical reason worth writing down: `_live_conditions` drives
*actions* from the lowest unreached level, while scoring a proposition reads
*all* levels. A clause at Triumph therefore gives an opinion in the room from
turn one without making anyone spend actions to smother the question.

### O-13: a proposition nobody would ever make

`P_ANY_LEAVE`'s success Consequence took presence and control from the
**proponent**. First attempt: give it a payoff, `ADJUST_TENSION $tension -2` —
the question goes quiet because nobody is left to ask it. Not enough, and the
measurement said why: `P_ANY_RATION` offers the same relief *plus* the Region,
so leaving stayed strictly dominated.

The right payoff was in the Consequence's own category, which is **MIGRATION,
not LOSS**: whoever leaves arrives somewhere. `ADD_PRESENCE $proponent` in
`$adjacent`. `P_ANY_LEAVE` now reaches a vote 7 times in 40 Chronicles and
`condition:abandoned` is written for the first time.

### The band moves from 4-5 to 5-6

Measured, isolated, and declared rather than quietly adjusted. Different
proponents ask different questions, whose Consequences move the Tensions
differently; reverting D-036 alone puts the median back at 5.

The justification is not "the test failed". §7's 3-4 over the two Tensions of
§18.2 is 1.5-2.0 Confluence **per Tension**; D-026's 4-5 over four Tensions is
1.0-1.25 — it was stricter than §7 ever asked for. Measured over four blocks of
forty Chronicles the rate is now 1.3 per Tension, still below §7's own, with a
median of 5 in three blocks and 6 in the fourth.

### After

| | D-035 | D-036 |
|---|---|---|
| consigli con almeno un no | 28% | **50%** |
| seggi che si oppongono almeno una volta | 3 | **4** |
| opposizioni di Vaerax | 0 | **26** |
| mappe di controllo distinte | 8 | **16** |
| stato finale distinto (su 40) | 38 | **40** |
| Scar per Chronicle | 1.60 | **2.00** |
| tag mai scritti (CHR_01 / CHR_02) | 3 / 1 | 3 / **0** |
| FAILURE / SWC / SUCCESS / DECISIVE | 25/23/62/80 | 45/24/60/79 |

Every one of forty Chronicles now ends in a different world state.

### The three sim plans had to be re-authored, and one of them explains itself

Plan B's Nahr moved a token to the Merchant Road to win the SURVIVAL domain.
Under D-036 that is the wrong place: the Council is about the Valley. Moving it
to the Valley restores the plan's story exactly — the Nahr ask for the land and
the whole table says no, **S1 O7 M−4**.

Plan A dropped from three Councils to two, and the reason is the game working:
the decisive requisition fires `CNS_VALLEY_CLEARED`, which clears the Nahr out of
the Valley, and without that presence nobody can touch the Roads for the rest of
the year. The plan now says so in its own description rather than asserting a
number that used to come out.

---

## D-035 — The first question of every Council was never asked
**implemented in 0.0.11** · closes O-8, closes O-6

Went looking for content to write and found the instrument again — but this
time the finding was worth more than the fix.

### The measurement

The stance probe was extended to tally which question/proposition pairs actually
reach a vote. In forty Chronicles, **seven pairs out of eighteen propositions**:

```
Q_AWAKENING_MOUNTAIN / P_GUARDED_STUDY   40      <- every single Awakening Council
Q_FAMINE_LAND        / P_LAND_TO_WORKERS 43
Q_ROADS_ESCORT       / P_SWEAR_ESCORT    36
...
```

Every template's **first** question was missing. `Q_FAMINE_GRAIN`,
`Q_AWAKENING_CRYSTAL`, `Q_ROADS_TOLL` — never asked once.

### Why

Two things met, and neither is a rule:

1. `_select_question` defaults to the **last** eligible question, on the reasoning
   that later questions are the sharper ones (D-016).
2. Every second question is gated on its Tension being at threshold — and a
   Council only *opens* when its Tension is at threshold. So the second question
   is essentially always eligible.
3. `PolicyDecider.choose_question` returned `""`. It declined to choose, so the
   default won every time.

The default is fine; a human at the table is offered both questions by
`available_questions()`. **The policy simply never reached for the other one.**
So O-8's "content that cannot be reached" was never unreachable — it was content
the measuring player never reached for.

### The fix

`choose_question` now scores a question by the best proposition behind it, with
the eligibility check the Council itself uses, and breaks ties on the session
RNG. Twenty lines, the same shape as D-033.

### After

| | prima | dopo |
|---|---|---|
| coppie domanda/proposta votate | 7 | **12** |
| tag di Regione mai scritti | 9 | **3** |
| consigli con almeno un no | 16% | **28%** |
| FAILURE | 23 | **25** |
| SUCCESS_WITH_COST | 6 | **27** |
| DECISIVE_SUCCESS | 105 (57%) | **76 (39%)** |
| mappe di controllo distinte | 3 | **8** |
| stato finale distinto | 32 | **38** |
| Scar per Chronicle | 1.15 | **1.60** |

And the Destinies unfroze. The saga of ten Chronicles had Lyra at TRIUMPH ten
times out of ten and Vaerax at VICTORY ten out of ten, every year, identically:

| | prima | dopo |
|---|---|---|
| Aldric | MIN 35 / VIC 4 / TRI 1 | MIN 18 / VIC 10 / **TRI 12** |
| Lyra | **TRIUMPH 40 / 40** | MIN 23 / TRI 17 |
| Vaerax | **VICTORY 40 / 40** | VIC 22 / TRI 18 |

That is O-6 closed: all four outcome bands are populated, and no seat has a
predetermined ending any more.

### What stayed shut: Vaerax owns his own question

D-034 found that Vaerax abstained 144 times out of 144, because **all 40 Councils
on the Awakening are opened by Vaerax himself**. That was called a content shape
and left for the content pass. It is not fixable by content, and this was
measured rather than argued.

`determine_proponent` is "most presence in the Tension's domain" (§12.2 C).
`domain:ANCIENT` exists on exactly two Regions, and Vaerax's Destiny plants him
in both. Two candidate widenings were tried and measured:

| | Consigli sul Risveglio aperti da Vaerax |
|---|---|
| oggi | 40 / 40 |
| `domain:ANCIENT` anche a Eredan | 107 / 107 |
| `domain:ANCIENT` anche alla Strada dei Mercanti | 40 / 40 |
| entrambe | 107 / 107 |

Widening the domain does not break the lock — it just raises more Councils that
Vaerax also owns. The lock is structural.

A rules change would break it: reading §12.2 C as presence in the Tension's
**focus Region** rather than its whole domain. Measured, it opens the Roads to
three proponents and the Succession to two — and still leaves the Awakening at
Vaerax 42/42. Recorded, not taken: it is a design decision about what a Council
*is*, and it belongs to the author, not to a balance pass.

The visible cost is that `P_EXPLOIT` is never proposed, so `condition:exploited`
is never written. The guardian of the mountain never puts "let us dig" to the
vote, which is either exactly right or exactly the problem, depending on whether
the Awakening is supposed to be a question the table argues about or a question
one seat owns.

### The guard, and why the first version of it was wrong

D-034's guard counted how often each Effect type moved the score during real
games. It failed the moment this change landed — not because the policy had gone
blind, but because the propositions that now come forward adjust the Succession
and the Roads, **which no Destiny in CHR_01 names** (O-12).

A guard that cannot tell "the policy is blind" from "the content moved" is worse
than none: it cries wolf at a content change, and it would be silenced by tuning
the content until it stopped firing. Rewritten as four constructed cases — build
the situation a Destiny describes, assert the policy has an opinion about it —
and verified by removing each branch in turn.

---

## D-034 — The table abstained on 96% of propositions, and it was the policy again
**implemented in 0.0.10** · addresses O-6

O-6 has been open since D-024: Failure and Success with Cost stay thin however
the content grows. The saga of ten Chronicles put a number on the mechanism -
**40 of 42 councils passed with zero opposition** - without explaining it.
Opposition is the only term that can push a margin down (M = S − O + W), so a
table that never opposes cannot produce anything but Success. This is the
measurement, and what it found.

### The measurement

`cli/run_stance_probe.gd` plays the same 40 Chronicles the balance probe plays
and records, for every non-proponent at every council, the score the policy
computed and the stance that score produced - plus, for every Effect in the
proposition's Consequences, whether that Effect moved the score **at all**.

The second tally is the one that matters. An Effect type read hundreds of times
and never worth a single point is not a quiet Effect; it is an axis of conflict
the policy cannot see, no matter what the content says.

| | letto | pesato | |
|---|---|---|---|
| `ADJUST_TENSION` | 489 | **0** | ← mai |
| `SET_CONTROL` | 210 | **0** | ← mai |
| `SET_ENTITY_TAG` | 300 | **0** | ← mai |
| `SET_RELATION` | 171 | **0** | ← mai |
| `SET_GLOBAL_TAG` | 579 | 11 | |
| `SET_REGION_TAG` | 408 | 11 | |

96.0% ABSTAIN, and the score took exactly three values in 573 stances: −2, 0,
+2. Only the tag branch of `_score_effect` ever fired. The presence branch (±3)
and the control branch (+2/−3) never fired once.

### Why each axis was dead

- **`ADJUST_TENSION`** — the commonest Effect in the Consequence set, and
  `tension_limit` is a clause in every one of the four Destinies. The two never
  met: a proposition that shoved the Famine up by two scored **zero** against a
  Destiny whose Victory says the Famine must stay under three.
- **`SET_CONTROL`** — every authored target is a slot (`$region_focus`,
  `$rival_seat`, `$capital`, `$region_with:trade`) since D-032, and
  `_score_effect` returned early on anything it could not find in
  `world["regions"]`. The comment said a policy reading a proposition in advance
  "cannot know which Region that is". **That was simply wrong.** The Council
  fixes its bindings at step A, before a single stance is declared.
- **`SET_ENTITY_TAG`** — Lyra's whole Destiny counts Discoveries, and Discoveries
  arrive as `SET_ENTITY_TAG discovery:*`. Nothing scored them.
- **`SET_RELATION`** — legitimately silent: no Destiny reads relations.

### The fix, and where it belongs

In the policy, not the content. The conflicts were **already authored** - a
proposition that raises the Famine against a people whose Destiny caps it is a
fight the data had written and the instrument could not read.

`ConfluenceController._context()` became public as **`effect_context()`**, and
the policy resolves slots through the Council's own binding table rather than a
copy, so the policy's idea of a proposition and the Effects the Council applies
at K cannot drift. Three branches were added:

- `ADJUST_TENSION` vs `tension_limit`: **−2** for the push that breaks a clause
  currently holding, **+2** for the one that repairs a broken one, ±1 for merely
  moving the wrong or right way inside the band. Breaking a clause is worth a no;
  disliking a direction is worth a clause.
- `SET_ENTITY_TAG discovery:*` vs `discovery_count`: **+2**, and only to the
  Entity receiving it — someone else learning something costs you nothing.
- Slot resolution, which is what brought `SET_CONTROL` and `REMOVE_PRESENCE`
  alive without touching their scoring at all.

### After

| | prima | dopo |
|---|---|---|
| ABSTAIN | 96.0% | **84.1%** |
| OPPOSE | 2.8% | **5.4%** |
| SUPPORT | 1.2% | **10.5%** |
| consigli con almeno un no | 16 (8%) | **30 (16%)** |
| valori distinti del punteggio | 3 | **7** |
| FAILURE (su ~180 Confluence) | 7 | **23** |
| SUCCESS_WITH_COST | 7 | 6 |

Failure roughly tripled, from 4% of councils to 12.5%. Success with Cost did not
move, and that is expected rather than disappointing: it is band 0–1, two values
wide, and a wider spread of margins does not preferentially land there.

### What it did not fix, stated plainly

`DECISIVE_SUCCESS` is still 105 of 184 (57%). O-6 is **narrowed, not closed**.

And one seat still never opposes: Vaerax abstained 144 times out of 144. The
room tally says why, and it is not the policy - **all 40 councils on the
Awakening were opened by Vaerax himself**. He owns his question outright, so he
is never in the room as a voter on the only Tension his Destiny names. That is a
content shape, not a blind spot, and it wants a content answer.

Third time the same lesson, after D-021 and D-033: when the balance looks wrong,
suspect the instrument before the rules.

---

## D-033 — Two more ways to aim: the neighbour, and a kind of place
**implemented in 0.0.9** · closes O-11

O-11 measured the cost of D-032: `$region_focus` is *stable* for a Tension, so
every Consequence of that Tension landed on the same place and the control map
stopped moving. Two slots answer it, and a third finding explains most of it.

### `$adjacent` — where the trouble spills

The Region next to the one under discussion, picked as the neighbour **carrying
the fewest marks already**. Damage spreads across the board instead of piling up,
and it reads right: the trouble goes where it has not been yet. Ties go to the
Chronicle's Region order, so the same board always spills the same way.

Used by the five Consequences whose narrative is overflow rather than target -
the unrest that does not stay where it was born, the road cut on the far side of
a plundered one.

### `$region_with:<tag>` — a kind of place, not a place

A parameterised slot: the first Region in Chronicle order carrying that tag,
preferring one that is *not* the Region already under discussion. A Consequence
can now say **the granary**, **the crossroads**, **the crystal site** and travel
from one Chronicle to the next without knowing the map.

Resolved by `ConsequenceCompiler`, which needed a world reference for it - every
other slot is filled by whoever builds the context, because only they know what
the Confluence is about; this one asks the board a question instead.
`validate_data.py` checks the tag is one some Region actually declares, so a
`$region_with:granray` fails at build time rather than silently resolving to the
focus.

### The third finding, and it was the big one

The two slots helped (distinct tag sets 21 -> 23) and left the control map at 3.
The real cause was not the slots at all.

`PolicyDecider.choose_proposition` started from `options[0]` and only replaced it
on a **strictly greater** score. Most propositions score 0 against most Destinies,
so the first legal option won every tie - and **twelve of the eighteen authored
propositions were never chosen once in forty Chronicles**. Their Consequences
could not fire, so most of the content that changes control simply never ran.

Breaking the tie with the session RNG - a player with no preference does not
always take the first thing on the list - is a change to the *measuring
instrument*, not to the rules. Same lesson as D-021, where most of the apparent
balance problem turned out to be the policy.

### After

| | D-032 | D-033 |
|---|---|---|
| mappe di controllo distinte (40 partite) | 3 | **5** |
| set di tag distinti | 21 | **31** |
| stato finale distinto | 24 | **31** |
| Scar per Chronicle | 0.17 | **1.52** |
| proposte diverse messe ai voti | 6 | **10** |
| domande diverse poste | 6 | **8** |
| frasi Truth distinte | 56 su 94 | **73 su 104** |
| tag sulla mappa in 10 Chronicle | 1 -> 10 | **1 -> 17** |

Scars per Chronicle are now double what they were *before* D-032 lost them
(0.75), so the generalisation ended up ahead rather than merely recovered.

### A probe that was lying

`run_world_probe` printed "il controllo e cambiato: NO" for a campaign in which
Aldric lost the capital at Chronicle 2, the Nahr took it at 6, and Aldric took it
back at 10 - because it compared only the first and last map, and they matched.
It now counts every distinct control map the campaign passed through: 3.

Worth stating on its own: a measurement that compares endpoints will call a
round trip "no change". Every probe in this project is now suspect in the same
way until checked.

---

## D-032 — Consequences written in slots, and a Truth register that varies
**implemented in 0.0.8** · completes the content half of D-028

D-028 built the engine for library content and said plainly what was still
missing: 26 of the Consequences named a specific Region, so they were Chronicle
content, not library content. This finishes that, and adds the per-outcome
variants of `echo_summary` promised two rounds earlier.

### Four bindings instead of one

`$region_focus` alone could not carry it: a Consequence usually means one of four
things when it names a proper noun.

| slot | cosa vuol dire |
|---|---|
| `$region_focus` | il posto di cui stiamo discutendo |
| `$capital` | il seggio del potere - la Regione taggata `capital` |
| `$rival` | il posto al tavolo contro cui la domanda e posta |
| `$rival_seat` | dove quel posto al tavolo sta davvero |

21 of the 23 place-named Consequences were rewritten against those. Relation
targets became `$proponent|$rival`, and the compiler now normalises a relation
key after substitution, because the pair has to be in ascending order and the
data cannot know which order the table is sitting in.

### Two bugs the change surfaced

- **`$rival` is a prefix of `$rival_seat`.** `ConsequenceCompiler` substituted in
  dictionary order, so the slot became `ENT_NAHR_seat` - a target that does not
  exist, reported only as a `push_error` deep inside the applier. Keys are now
  sorted longest-first, the same fix `NarrativeText.fill` already carried.
- The static binding check in `validate_data.py` did not split a relation target
  on `|`, so half a pair went unchecked. It caught `$rival_seat` before it existed
  and then missed `$proponent|$rival`; both are checked now.

### `echo_summaries`: the register stops repeating itself

A proposition may now carry a sentence per outcome band. How a proposal falls
reads nothing like how it triumphs, and the Truth register is where a Chronicle
gets reread. Any band without a variant falls back to the single `echo_summary`,
so nothing had to be rewritten. 13 of the 18 propositions carry variants.

| | prima | dopo |
|---|---|---|
| frasi Truth distinte su 40 Chronicle | 22 su 63 | **56 su 94** |

That is the single biggest jump in narrative variety the project has measured,
and it cost about 40 authored sentences.

### The cost, and it is real

Generalising the Consequences **reduced** world-state variety:

| | D-028/D-031 | dopo D-032 |
|---|---|---|
| mappe di controllo distinte (40 partite) | 6 | **3** |
| Scar per Chronicle | 0.75 | **0.17** |
| il controllo cambia in 10 Chronicle | si | **no** |

The cause is structural and was not obvious in advance: `$region_focus` is
*stable* for a given Tension, so every Consequence of that Tension now lands on
the same place, where six hard-coded Regions used to spread the damage across the
map. Three Consequences were re-aimed at `$rival_seat` and `$capital`, which
recovered part of it, not all.

This is a trade, and it is recorded as one rather than presented as a win: the
Consequences are now reusable across Chronicles, and the map moves less inside
one. O-11 tracks it.

---

## D-031 — Propp's set completed: 24 cards, 24 functions, and an `any_of`
**implemented in 0.0.7** · §15, §18.2

D-030 wired the grammar but only 16 of the 24 functions the schema declares had
a card. The eight missing ones were also the most interesting to constrain:
a Punishment after a Violation, a Separation that makes a Return possible.

### The eight

| carta | famiglia | funzione | aspetta |
|---|---|---|---|
| `ECH_PETITION` | PRESSURE | REQUEST | — |
| `ECH_OFFER` | PRESSURE | TEMPTATION | — |
| `ECH_OATH_BROKEN` | RUPTURE | VIOLATION | PROHIBITION o REQUEST |
| `ECH_EXODUS` | RUPTURE | SEPARATION | — |
| `ECH_PARLEY` | TURN | ENCOUNTER | — |
| `ECH_SEIZURE` | TURN | CONQUEST | ATTACK, THREAT o USURPATION |
| `ECH_RECKONING` | RESOLUTION | PUNISHMENT | VIOLATION, BETRAYAL, USURPATION o CONQUEST |
| `ECH_CROWNING` | RESOLUTION | SUCCESSION | THREAT, USURPATION, CONQUEST o SEPARATION |

The deck is now **24 cards, 6 per dramatic family, one per declared function**,
and a test asserts all three of those numbers: content that exists only in an
enum is content that cannot happen.

### `any_of`

Every condition list in the data is an AND, and Propp's grammar is full of
alternatives - a Return follows a Separation *or* a Prohibition. The eight new
cards could not be written honestly without it.

A new condition type, `any_of`, holds when at least one of its nested conditions
does. Twelve lines in the evaluator, a `$ref` to itself in the schema, and one
recursion branch in the Python validator. `ECH_ROADS_OPEN`, `ECH_RECONCILIATION`
and `ECH_AMNESTY` were widened to use it, because single-antecedent gates made
them rarer than the grammar requires.

It is available to Destiny conditions and Confluence eligibility too, which is
where it will earn its keep next.

### After

| | D-030 | D-031 |
|---|---|---|
| funzioni con una carta | 16/24 | **24/24** |
| funzioni pescate in 40 Chronicle | 16 | **21** |
| funzioni senza antecedente | 0 | **0** |
| archi drammatici distinti | 9 | 9 |
| Atto 3 risolve | 23/40 | **28/40** |

Verified on the library Chronicle too (`--chronicle=CHR_02`): 22 functions drawn,
0 orphans, 7 distinct arcs.

### Reported, not fixed

`SACRIFICE` is drawn 14 times in 40 because it is the only RESOLUTION card that
presupposes nothing, and Act 3 asks for a resolution first. That is the price of
the invariant - every family keeps one unconditional card - and forcing it flat
would mean inventing an antecedent a sacrifice does not have.

The Confluence band moved 85% -> 70% inside 4-5 with the wider deck, still with
nothing outside 2-7. Related to O-6, still not tuned away.

---

## D-030 — The Propp layer: families shape the Act, functions order the story
**implemented in 0.0.6** · §15

### What was already there, and what was not

An Echo card carries two pieces of narrative metadata: `dramatic_family`
(PRESSURE / RUPTURE / TURN / RESOLUTION) and `function_id`, an adapted set of 24
of Propp's narrative functions.

Measured with `cli/run_echo_probe.gd` over 40 Chronicles:

- **`dramatic_family` was load-bearing.** It gates which cards an Act may draw,
  so the three-act shape was already enforced: Act 1 PRESSURE 40/40.
- **`function_id` was read by nothing.** Grep found it in exactly one place: the
  column that prints it in the asset manifest.

The cost of that showed up immediately. **19 functions in 18 Chronicles out of 40
arrived without their antecedent**: a Return with nothing to return from, a
Reconciliation with no betrayal, a Liberation with nothing forbidden. Propp's
whole point is that the functions come in an *order*, and nothing enforced it.

### The rule, written in data rather than code

Drawing a card now records the function it performed as a global tag,
`function:<ID>`, applied as an ordinary Effect. That is the entire engine change,
and the engine still does not know a single function name.

The grammar itself lives on the cards, in the `eligibility` block they already
had:

| carta | funzione | non e giocabile finche |
|---|---|---|
| `ECH_RECONCILIATION` | RECONCILIATION | non c'e stato un BETRAYAL |
| `ECH_AMNESTY` | LIBERATION | non c'e stata una USURPATION |
| `ECH_ROADS_OPEN` | RETURN | non c'e stata una PROHIBITION |
| `ECH_OATH_SWORN` | TRANSFORMATION | non c'e stato un THREAT |
| `ECH_GOOD_YEAR` | GIFT | non c'e stato un LACK |
| `ECH_REVELATION` | REVELATION | non c'e stata una DISCOVERY |

Orphan functions: **19 -> 0**.

### Two things this broke, and what they taught

**Over-gating stops the arc from closing.** Gating all four RESOLUTION cards
dropped Act 3 from resolving 18/40 to 11/40: the draw skipped the gated cards and
fell through to a rupture. Fixed by leaving `ECH_SACRIFICE` unconditional - a
sacrifice presupposes nothing, it is a choice - and guarded by a test asserting
that **every dramatic family keeps at least one card that presupposes nothing**.

**A strict preference is not a shape, it is a rail.** Reading the Act pool as an
ordered preference (RESOLUTION first, then fall back) produced *one* dramatic arc
in all forty Chronicles: PRE RUP RES, 40/40. Perfect shape, no story.

So `act_echo_pools[].families` is now a **weighted bag**: repeating a family makes
it likelier, and the seeded RNG picks the order families are tried in. No schema
change - repeats were always legal, they simply meant nothing. Chronicle I:

```
Atto 1  [PRESSURE]                                      apre sempre in tensione
Atto 2  [RUPTURE, RUPTURE, TURN, TURN, PRESSURE]
Atto 3  [RESOLUTION x3, TURN, RUPTURE]                  risolve ~60% delle volte
```

### After

| | prima | dopo |
|---|---|---|
| funzioni senza antecedente | 19 (18/40 partite) | **0** |
| archi drammatici distinti | 9 | 9 |
| Atto 1 apre in PRESSURE | 40/40 | 40/40 |
| Atto 3 risolve | 18/40 | **23/40** |
| Chronicle che finiscono a meta crisi | 22/40 | 17/40 |

An Act 3 that ends mid-crisis 40% of the time is not a bug: the unanswered
question is what the next Chronicle inherits.

Unplanned again: the Confluence band went to **85% inside 4-5** from 75%.

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

### O-14 — The Destiny spread tilted, and this time in Lyra's favour
**closed by D-048.** The tilt was real and the cause was mechanical: Lyra's whole
ladder was closed by Act I round two in 40 Chronicles out of 40, so "reaches
Triumph in four out of five" was not a seat that was winning, it was a seat that
had been handed the win before play began. Priced properly she is at MIN 34 /
TRI 6 - and the table is now lopsided the *other* way, which is O-15.

**original note:**

D-036 opened the rooms and the standings moved with them:

| | D-035 | D-036 |
|---|---|---|
| Aldric | MIN 18 / VIC 10 / TRI 12 | **MIN 32** / VIC 5 / TRI 2 |
| Nahr | MIN 4 / VIC 27 / TRI 9 | MIN 6 / VIC 29 / TRI 5 |
| Lyra | MIN 15 / TRI 25 | MIN 8 / **TRI 32** |
| Vaerax | MIN 1 / VIC 36 / TRI 3 | MIN 1 / **VIC 38** / TRI 1 |

The crown now spends most Chronicles at Minimum, and Lyra reaches Triumph in four
out of five. Nobody is frozen the way they were before D-035 - every seat still
reaches more than one level - but the spread is lopsided, and two of the causes
are visible: Aldric's Victory needs two Regions in a world where control changes
hands far more often, and Vaerax's Triumph now asks for a cut road, which is a
tag somebody else has to write for him.

Left alone on purpose. Three rounds of measurement in a row found the instrument
at fault rather than the rules, and the lesson is not to reach for the knobs
first. This wants a table of real players before anybody decides which of these
numbers is wrong.

Relations also collapsed to a single distinct end state across forty Chronicles,
down from two. Small, but it says the relation graph is scenery right now.

### O-15 — Six Destiny levels out of twelve are true before anyone plays
**closed by D-051 and D-053.** Half of what this entry counted was not a defect:
a free Minimum says "you are still at the table", and an absent-tag clause is a
stake the year takes off you. What was broken were two Victories made only of
stakes nothing ever attacked, and those are fixed (D-051).

The rest - "recorded, not tuned", because it wanted a table of real players -
was then actually measured (D-053): four different characters over 100
Chronicles against the same 100 seeds played by four identical optimisers. It
found that four of the eight seats were an artefact of the instrument, two were
genuinely too expensive, and those two were lowered. Seats locked on one level
at a mixed table: 1 of 8, against 4 of 8 with the optimisers.

What outlived this observation is a different one, and it is in the ROADMAP
rather than here because it is about the resolver and not the content:
**blocking is the dominant strategy**. See D-053's closing section.

**original note:**

`run_destiny_probe.gd` checks every clause against the opening position, and the
count is 19 clauses out of 28 already true, with **six whole levels given away**:
Aldric's Minimum and Triumph, Nahr's Minimum, Lyra's Victory (now repriced by
D-048), and both of Vaerax's lower rungs.

Not all of these are wrong. A clause asking for a tag to be *absent* is a stake,
not a gift: "the crown was not broken" is true until somebody breaks it, and
Aldric's Triumph is 3/3 free at the start and still reaches TRIUMPH only 3 times
in 40, because the year takes it off him. That is the mechanism working.

Vaerax is the one that is not working. His Victory is two absent-tags and nothing
else, and he reports VICTORY in 37-40 Chronicles out of 40 - in CHR_02, **40 out
of 40**. He wins by sitting still, and after D-048 he wins while the seat he is
in direct conflict with wins 6 times in 40. The asymmetry is now the loudest
thing in the standings.

Recorded rather than tuned, and deliberately: D-048 already moved one seat from
best at the table to worst, and moving a second one in the same pass would make
neither measurable. The next pass should start from this probe's first table -
what is already true before the year starts - rather than from the outcome
counts, because the outcome counts are where this hid for four milestones.

### O-13 — `P_ANY_LEAVE` is a proposition nobody would ever make
**closed by D-036.** Not with the first fix: giving it `ADJUST_TENSION -2` was
not enough, because `P_ANY_RATION` offered the same relief plus the Region and so
strictly dominated it. The payoff that worked was the one already written in the
Consequence's own category - MIGRATION, not LOSS - so whoever leaves now arrives
somewhere. It reaches a vote 7 times in 40 Chronicles.

**original note:**

Its success Consequence, `CNS_ABANDONED`, sets the Region's control to nobody
and removes the **proponent's own** presence. Nobody playing to win proposes
that, so `condition:abandoned` has never been written in any measured Chronicle.

The text is good — *"Non si risolve: si va via. $rival resti pure, se ci tiene."*
It reads as an act of spite or exhaustion, and both are real things a table does.
But the rules give it no reason to be attractive: walking out denies the place to
the rival, and nothing scores that.

Three honest ways out, and picking one is design, not tuning: give it a payoff
that makes leaving worth something; move `CNS_ABANDONED` to a failure or cost
path, where "nobody resolved anything and the place emptied" is exactly right;
or leave it as content only a human would ever reach for, and accept that the
policy will never measure it.

### O-12 — Two of the four Tensions are in nobody's Destiny
**closed by D-036** — with a detour worth recording. The obvious fix, a
`tension_limit` on each, made it *worse*: a ceiling makes the policy spend
actions holding the Tension down, and holding it down makes the question stop
being asked. The Roads fell from 36 Councils to 6. A stake does not have to be a
limit on a number - a tag weighs on propositions and drives no actions - and two
pairs of directly opposed tag stakes gave the fight without the silence.

**original note:**

Every `tension_limit` clause in CHR_01 names either the Famine or the Awakening.
**No Destiny puts a ceiling or a floor on the Succession or on the Roads.**

It went unnoticed while D-035 was hidden, because the Councils that came forward
were the ones about the Famine and the Awakening. With the first questions now
asked, propositions that move the Succession and the Roads reach the table
routinely — and the whole table is indifferent to them by construction. Those
Councils cannot produce a fight over the quantity itself; only over who ends up
holding what.

Not a bug, and not obviously wrong: a Chronicle may legitimately carry a question
nobody has sworn anything about. But four Tensions and two stakes is a thinner
board than it looks, and one clause added to one Destiny would change it.

### O-6 — The wider content thinned the outcome bands again
**closed by D-035.** All four bands are populated (FAILURE 25, SUCCESS_WITH_COST
27, SUCCESS 65, DECISIVE_SUCCESS 76 out of 193) and no seat has a predetermined
ending: Lyra was TRIUMPH in 40 Chronicles out of 40, and is now MINIMUM in 23 of
them. The cause was never the resolver or the bands - it was the measuring player
never asking the first question of any Council.

**previously: narrowed by D-034, still open.** The cause turned out to be the measuring
instrument: the policy was blind to three of the four axes the Destinies are
actually about, so 96% of stances were ABSTAIN and O was 0 in almost every
council. With the policy able to read them, Failure went 7 -> 23 out of ~180.
What remains is `DECISIVE_SUCCESS` at 57%, and one seat (Vaerax) that owns its
own question and is therefore never in the room to vote on it - a content
question, not a policy one.

**previously: partly closed by D-026** — the band question is answered (4-5,
declared). The thinning of Failure and Success with Cost is not: 9 and 5 against
18 and 15. Still open, still the same mechanism as O-4 in a bigger world.

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
**closed by D-035.** The content was never unreachable: the policy declined to
choose a question, so the default handed it the last one every time and the first
question of every template was never asked. Tags never written in 40 Chronicles
went from 9 to 3, and the three that remain each have their own named cause -
O-12, O-13, and the proponency lock in D-035's Vaerax note.

The original note warned that "tuning the policy until its own content fires
would be fitting the measurement to the answer". That was the right worry and it
pointed at the wrong culprit: the policy was not scoring the content too
narrowly, it was never being offered it.

**original note:**

`structure:granary`, `structure:tollgate`, `settlement:market`,
`condition:exploited`, `condition:requisitioned` and `condition:indebted` were
not written to the map once in 40 measured Chronicles. Their propositions exist
and are legal; the policy simply never scores them highest.

Content that cannot be reached is content that does not exist. Worth checking
against real players before deciding whether the propositions are weak or the
policy is narrow - tuning the policy until its own content fires would be fitting
the measurement to the answer.

### O-11 — Slot-written Consequences concentrate the damage
**closed by D-033.** The concentration was real but secondary: the dominant cause
was a policy that always took the first proposition on a tie, leaving two thirds
of the authored content unplayable.

**original note:**

Control maps distinct over 40 Chronicles went 6 -> 3 and Scars per Chronicle
0.75 -> 0.17, because `$region_focus` is stable for a Tension and six hard-coded
Regions used to spread the damage. `$rival_seat` and `$capital` recovered part of
it. The real answer is probably a fifth binding - "a Region adjacent to the one
under discussion" - or Consequences that name a *kind* of place rather than a
place, but both are design work and neither should be guessed at.

### O-10 — `function_id` was metadata the engine never read
**closed by D-030.** 19 orphan functions in 40 Chronicles, now 0.

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
