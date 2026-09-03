#!/usr/bin/env bash
# La scheda di ogni tipo di carta, e il dato per generarle (D-445).
#
#   GODOT=/path/to/godot tools/run_card_sheets.sh          # rigenera
#   tools/run_card_sheets.sh --check                       # ...e esce 1 se e' vecchio
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/SCHEDE_CARTE.md"
JSON="$ROOT/docs/schede"
CHECK=0
for arg in "$@"; do [ "$arg" = "--check" ] && CHECK=1; done
TMP="$(mktemp -d)"
"$GODOT" --headless --path "$ROOT/godot" --script res://cli/run_card_sheets.gd -- \
  "--out=$TMP/SCHEDE_CARTE.md" "--json=$TMP/schede" "--bible=$ROOT/docs/ART_BIBLE.md"
code=$?
if [ $code -ne 0 ]; then echo "  FALLITO (exit $code)"; rm -rf "$TMP"; exit 1; fi
if [ $CHECK -eq 1 ]; then
  if ! diff -q "$TMP/SCHEDE_CARTE.md" "$DOC" > /dev/null 2>&1 || ! diff -rq "$TMP/schede" "$JSON" > /dev/null 2>&1; then
    echo ""
    echo "ATTENZIONE: docs/SCHEDE_CARTE.md o docs/schede/ non sono quello che le facce generano adesso."
    echo "  GODOT=\"$GODOT\" tools/run_card_sheets.sh"
    rm -rf "$TMP"; exit 1
  fi
  echo "OK  docs/SCHEDE_CARTE.md e docs/schede/ sono allineati"
else
  mkdir -p "$JSON"
  rm -f "$JSON"/*.json
  cp "$TMP/SCHEDE_CARTE.md" "$DOC"; cp "$TMP"/schede/*.json "$JSON"/
  echo "Scritto: $DOC e $JSON/"
fi
rm -rf "$TMP"
