#!/usr/bin/env bash
# Rigenera docs/MISURA_SEGNI.md giocando cento anni (D-324).
#
#   GODOT=/path/to/godot tools/run_marks_survey.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_marks_survey.sh --check  # esce 1 se e' vecchio
#
# La misura che guarda **dall'altra parte** rispetto alle sonde del punteggio:
# non «quanti dei segni che i Destini nominano il mondo li scrive», ma «quali
# segni il mondo scrive, e se qualcuno se ne accorge». Documento generato e
# committato, come il catalogo dei Consigli e la misura delle vite: un numero
# che si puo' rileggere da soli non e' una promessa, e' una prova.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/MISURA_SEGNI.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t misura_segni.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_world_marks_probe.gd -- \
  --runs=100 --seed=7000 --chronicle=CHR_00 "--out=$TMP" > /dev/null
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/MISURA_SEGNI.md non e' quello che il gioco produce adesso."
    echo "  GODOT=\"$GODOT\" tools/run_marks_survey.sh"
    exit 1
  fi
  echo "OK  docs/MISURA_SEGNI.md e' allineato"
  exit 0
fi

cp "$TMP" "$DOC"
echo "Scritto: $DOC"
