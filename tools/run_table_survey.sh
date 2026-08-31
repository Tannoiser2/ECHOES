#!/usr/bin/env bash
# Rigenera docs/MISURA_TAVOLO.md giocando cento anni (D-351).
#
#   GODOT=/path/to/godot tools/run_table_survey.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_table_survey.sh --check  # esce 1 se e' vecchio
#
# La misura che mancava. `run_marks_survey.sh` guarda sessantasei segni — le
# memorie del mondo e le condizioni dei luoghi. Degli altri centotrentotto non
# sapeva niente nessuno, e dentro c'erano tutte le Cicatrici, tutte le Pietre e
# tutto quello che sta sulla scheda di una casa.
#
# Questa li guarda tutti e centottanta, **posto per posto** (D-350), e risponde
# alla domanda del committente coi numeri invece che a sensazione: quali segni
# non arrivano mai sul tavolo, e quali ci arrivano sempre.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/MISURA_TAVOLO.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t misura_tavolo.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_table_marks_probe.gd -- \
  --runs=100 --seed=7000 --chronicle=CHR_00 "--out=$TMP" > /dev/null
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/MISURA_TAVOLO.md non e' quello che il gioco produce adesso."
    echo "  GODOT=\"$GODOT\" tools/run_table_survey.sh"
    exit 1
  fi
  echo "OK  docs/MISURA_TAVOLO.md e' allineato"
  exit 0
fi

cp "$TMP" "$DOC"
echo "Scritto: $DOC"
