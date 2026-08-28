#!/usr/bin/env bash
# Gioca alcuni anni interi headless e scrive verbali e salvataggi sotto out/.
#
#   GODOT=/path/to/godot tools/run_sims.sh
#
# Fino a 0.1.280 girava i quattro `sim_plans`: playthrough scritti a mano della
# Carestia Rossa, mossa per mossa. Se ne sono andati con gli anni d'autore
# (D-318), e non si potevano ripuntare — una sequenza di mosse scritta per una
# mappa fissa non ha senso su una mappa che si pesca.
#
# Quello che serviva resta: un anno arriva in fondo senza schiantarsi, e **lo
# stesso seme produce un salvataggio identico byte per byte** (§18.3, la
# verifica di determinismo in CI). Adesso lo si chiede su anni pescati.
#
# Exit 0 se ogni anno e' arrivato in fondo.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
OUT="${OUT:-$ROOT/out}"
CHRONICLE="${CHRONICLE:-CHR_00}"
SEEDS="${SEEDS:-7000 7001 7002 7003}"

mkdir -p "$OUT"
status=0

for seed in $SEEDS; do
  name="anno_${seed}"
  echo "=== $name"
  "$GODOT" --headless --path "$ROOT/godot" \
    --script res://cli/run_chronicle_sim.gd -- \
    "--chronicle=$CHRONICLE" \
    "--seed=$seed" \
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
