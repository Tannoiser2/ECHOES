#!/usr/bin/env bash
# Genera i fogli di stampa e il brief d'arte dai dati.
#
#   GODOT=/path/to/godot tools/run_export.sh              # il mazzo intero
#   GODOT=/path/to/godot tools/run_export.sh --proof      # una copia per faccia
#   OUT=/tmp/prova tools/run_export.sh                    # altrove
#
# Esce in out/export/ (ignorata da git: si rigenera, non si versiona).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
OUT="${OUT:-$ROOT/out/export}"

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_export.gd -- \
  "--out=$OUT" "--bible=$ROOT/docs/ART_BIBLE.md" "$@"
code=$?

if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

echo ""
echo "Fogli: $OUT/fogli   ·   brief: $OUT/brief_arte.md"
