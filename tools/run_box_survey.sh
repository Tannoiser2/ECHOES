#!/usr/bin/env bash
# Le caselle del Consiglio e quello che il Consiglio fa lo stesso (ISSUES 89).
#
#   GODOT=/path/to/godot tools/run_box_survey.sh            # rigenera
#   tools/run_box_survey.sh --check                         # ...e esce 1 se e' vecchio
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/MISURA_CASELLE.md"
CHECK=0
for arg in "$@"; do
  [ "$arg" = "--check" ] && CHECK=1
done

TMP="$(mktemp)"
"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_box_survey.gd -- "--out=$TMP"
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  rm -f "$TMP"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -q "$TMP" "$DOC" > /dev/null 2>&1; then
    echo ""
    echo "ATTENZIONE: docs/MISURA_CASELLE.md non e' quello che i dati generano adesso."
    echo "  GODOT=\"$GODOT\" tools/run_box_survey.sh"
    rm -f "$TMP"
    exit 1
  fi
  echo "OK  docs/MISURA_CASELLE.md e' allineato"
else
  cp "$TMP" "$DOC"
  echo "Scritto: $DOC"
fi
rm -f "$TMP"
