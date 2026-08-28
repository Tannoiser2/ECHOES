#!/usr/bin/env bash
# Rigenera docs/MISURA_VITE.md giocando le saghe (D-290).
#
#   GODOT=/path/to/godot tools/run_lives_survey.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_lives_survey.sh --check  # esce 1 se e' vecchio
#
# La misura di quante vite scritte si siedono davvero al tavolo. E' un
# documento **generato e committato**, come il catalogo dei Consigli: la
# soglia di trasformazione si giudica sul suo delta, e un numero che si puo'
# rileggere da soli non e' una promessa, e' una prova.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/MISURA_VITE.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t misura_vite.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_lives_probe.gd -- \
  --sagas=12 --chronicles=8 --seed=812 --then=CHR_00 "--out=$TMP" > /dev/null
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/MISURA_VITE.md non e' quello che il gioco produce adesso."
    echo "  GODOT=\"$GODOT\" tools/run_lives_survey.sh"
    exit 1
  fi
  echo "OK  docs/MISURA_VITE.md e' allineato"
  exit 0
fi

cp "$TMP" "$DOC"
echo "Scritto: $DOC"
