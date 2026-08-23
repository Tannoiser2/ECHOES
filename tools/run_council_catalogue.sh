#!/usr/bin/env bash
# Rigenera docs/CATALOGO_CONSIGLI.md dai dati (D-232).
#
#   GODOT=/path/to/godot tools/run_council_catalogue.sh          # riscrive il documento
#   GODOT=/path/to/godot tools/run_council_catalogue.sh --check  # esce 1 se e' vecchio
#
# Il catalogo e' un file **generato e committato**, come `docs/BRIEF_ARTE.md` e
# `docs/REGISTRO_SEGNI.md`: si legge senza aprire Godot, e non puo' invecchiare
# in silenzio perche' la CI lo rigenera e lo confronta. Quando qualcuno cambia
# una proposta o una Conseguenza nel database, il cancello dice **qui** che il
# documento non dice piu' la verita', non fra tre mesi al tavolo.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
DOC="$ROOT/docs/CATALOGO_CONSIGLI.md"

CHECK=0
for arg in "$@"; do
  if [ "$arg" = "--check" ]; then
    CHECK=1
  fi
done

TMP="$(mktemp -t catalogo_consigli.XXXXXX.md)"
trap 'rm -f "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_council_catalogue.gd -- "--out=$TMP" > /dev/null
code=$?
if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $CHECK -eq 1 ]; then
  if ! diff -u "$DOC" "$TMP"; then
    echo ""
    echo "ATTENZIONE: docs/CATALOGO_CONSIGLI.md non e' quello che i dati generano adesso."
    echo "  GODOT=\"$GODOT\" tools/run_council_catalogue.sh"
    exit 1
  fi
  echo "OK  docs/CATALOGO_CONSIGLI.md e' allineato"
  exit 0
fi

cp "$TMP" "$DOC"
echo "Scritto: $DOC"
