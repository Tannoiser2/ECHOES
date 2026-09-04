#!/usr/bin/env bash
# Rigenera docs/MISURA_PARTECIPAZIONE.md giocando gli anni del cancello sui due
# tavoli, e va rosso se un tavolo intero chiude ogni Consiglio senza
# un'opposizione che pesi nel margine (D-451).
#
#   GODOT=/path/to/godot tools/run_participation_probe.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_participation_probe.sh --check  # esce 1 se e' vecchio o rosso
#
# Il cancello dei 100 semi conta i Consigli e i loro esiti, non chi ci
# partecipa. Questo conta chi partecipa: e' un documento generato e
# committato, come le altre misure, con in fondo una riga che decide.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/MISURA_PARTECIPAZIONE.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t misura_partecipazione.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_participation_probe.gd -- \
  --runs=30 --seed=7000 "--out=$TMP" | grep -v "Godot Engine"
code=${PIPESTATUS[0]}
if [ $code -eq 3 ]; then
  echo "  FALLITO (exit $code): la sonda non ha potuto misurare"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/MISURA_PARTECIPAZIONE.md non e' quello che il gioco produce adesso."
    echo "  GODOT=\"$GODOT\" tools/run_participation_probe.sh"
    exit 1
  fi
  echo "OK  docs/MISURA_PARTECIPAZIONE.md e' allineato"
else
  cp "$TMP" "$DOC"
  echo "Scritto: $DOC"
fi

# Il cancello sull'opposizione zero: la sonda esce 2 quando un tavolo intero
# non ha un solo Consiglio con opposizione nel margine.
if [ $code -eq 2 ]; then
  echo "ROSSO: un tavolo intero senza opposizione nel margine — il Consiglio si tiene, ma nessuno lo gioca (D-451)"
  exit 1
fi
exit 0
