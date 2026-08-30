#!/usr/bin/env bash
# Lo scheletro delle carte, ricavato dalle facce vere (D-345).
#
#   GODOT=/path/to/godot tools/run_card_skeleton.sh          # rigenera
#   tools/run_card_skeleton.sh --check                       # ...e esce 1 se e' vecchio
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/SCHELETRO_CARTE.md"
CHECK=0
for arg in "$@"; do [ "$arg" = "--check" ] && CHECK=1; done
TMP="$(mktemp)"
"$GODOT" --headless --path "$ROOT/godot" --script res://cli/run_card_skeleton.gd -- "--out=$TMP"
code=$?
if [ $code -ne 0 ]; then echo "  FALLITO (exit $code)"; rm -f "$TMP"; exit 1; fi
if [ $CHECK -eq 1 ]; then
  if ! diff -q "$TMP" "$DOC" > /dev/null 2>&1; then
    echo ""
    echo "ATTENZIONE: docs/SCHELETRO_CARTE.md non e' quello che le facce generano adesso."
    echo "  GODOT=\"$GODOT\" tools/run_card_skeleton.sh"
    rm -f "$TMP"; exit 1
  fi
  echo "OK  docs/SCHELETRO_CARTE.md e' allineato"
else
  cp "$TMP" "$DOC"; echo "Scritto: $DOC"
fi
rm -f "$TMP"
