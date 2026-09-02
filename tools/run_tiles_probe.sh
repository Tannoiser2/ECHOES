#!/usr/bin/env bash
# Rigenera docs/MISURA_TESSERE.md enumerando tutte le pose (D-390).
#
#   GODOT=/path/to/godot tools/run_tiles_probe.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_tiles_probe.sh --check  # esce 1 se e' vecchio
#
# La promessa che il committente ha chiesto per nome — «non ci devono essere
# tessere isolate» — non si campiona: si enumera. 210 pescate per 720 ordini
# fanno 151.200 pose, e questa le fa tutte chiamando la posa del motore.
# Quattro minuti, ed e' il prezzo di una promessa provata invece che creduta.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/MISURA_TESSERE.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t misura_tessere.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_tiles_probe.gd -- "--out=$TMP" > /dev/null
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/MISURA_TESSERE.md non e' quello che la posa produce adesso."
    echo "  GODOT=\"$GODOT\" tools/run_tiles_probe.sh"
    exit 1
  fi
  echo "OK  docs/MISURA_TESSERE.md e' allineato"
  exit 0
fi

cp "$TMP" "$DOC"
echo "Scritto: $DOC"
