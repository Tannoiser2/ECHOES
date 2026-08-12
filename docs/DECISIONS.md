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
**flagged, open — recorded, not tuned**

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
