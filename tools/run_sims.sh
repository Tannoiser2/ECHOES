#!/usr/bin/env bash
# Play every sim plan headless and write logs + saves under out/.
#
#   GODOT=/path/to/godot tools/run_sims.sh
#
# Exit code 0 means every plan ran to the end with legal choices and satisfied
# its `expected` block (§18.3).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
OUT="${OUT:-$ROOT/out}"

mkdir -p "$OUT"
status=0

for plan in "$ROOT"/godot/data/chronicle_01/sim_plans/*.json; do
  name="$(basename "$plan" .json)"
  echo "=== $name"
  "$GODOT" --headless --path "$ROOT/godot" \
    --script res://cli/run_chronicle_sim.gd -- \
    "--plan=res://data/chronicle_01/sim_plans/$(basename "$plan")" \
    "--out=$OUT/$name.save.json" \
    "--log=$OUT/$name.log" \
    --quiet
  code=$?
  if [ $code -ne 0 ]; then
    echo "    FALLITO (exit $code)"
    status=1
  fi
done

exit $status
