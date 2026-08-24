#!/usr/bin/env bash
# Rigenera docs/CATALOGO_CARTE.md dai dati (D-249).
#
#   GODOT=/path/to/godot tools/run_card_catalogue.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_card_catalogue.sh --check  # esce 1 se e' vecchio
#
# Una scheda per carta: cosa dice, cosa fa, quanto vale, e il prompt per farne
# l'immagine. Le quattro cose stavano in tre documenti diversi; qui stanno in
# uno, e nessuna riga e' scritta a mano.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/CATALOGO_CARTE.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t catalogo_carte.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_card_catalogue.gd -- \
  "--out=$TMP" "--bible=$ROOT/docs/ART_BIBLE.md" > /dev/null
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/CATALOGO_CARTE.md non e' quello che i dati generano adesso."
    echo "  GODOT=\"$GODOT\" tools/run_card_catalogue.sh"
    exit 1
  fi
  echo "OK  docs/CATALOGO_CARTE.md e' allineato"
  exit 0
fi

cp "$TMP" "$DOC"
echo "Scritto: $DOC"
