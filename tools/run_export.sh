#!/usr/bin/env bash
# Genera i fogli di stampa e il brief d'arte dai dati.
#
#   GODOT=/path/to/godot tools/run_export.sh              # il mazzo intero
#   GODOT=/path/to/godot tools/run_export.sh --proof      # una copia per faccia
#   GODOT=/path/to/godot tools/run_export.sh --pdf        # e in piu il PDF unico
#   OUT=/tmp/prova tools/run_export.sh                    # altrove
#   tools/run_export.sh --check-brief                     # ...e esce 1 se docs/BRIEF_ARTE.md e' vecchio
#
# Esce in out/export/ (ignorata da git: si rigenera, non si versiona). Gli SVG
# restano la sorgente diffabile che la CI confronta; `--pdf` aggiunge il
# formato di consegna per la tipografia (ISSUES voce 8, richiede
# `pip install cairosvg pypdf`).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-godot}"
OUT="${OUT:-$ROOT/out/export}"

WANT_PDF=0
CHECK_BRIEF=0
ARGS=()
for arg in "$@"; do
  if [ "$arg" = "--pdf" ]; then
    WANT_PDF=1
  elif [ "$arg" = "--check-brief" ]; then
    CHECK_BRIEF=1
  else
    ARGS+=("$arg")
  fi
done

"$GODOT" --headless --path "$ROOT/godot" \
  --script res://cli/run_export.gd -- \
  "--out=$OUT" "--bible=$ROOT/docs/ART_BIBLE.md" ${ARGS[@]+"${ARGS[@]}"}
code=$?

if [ $code -ne 0 ]; then
  echo "  FALLITO (exit $code)"
  exit 1
fi

if [ $WANT_PDF -eq 1 ]; then
  python3 "$ROOT/tools/make_pdf.py" "$OUT/fogli" "$OUT/echoes_print.pdf" || exit 1
fi

# Il brief committato e' quello generato: e' il documento che si manda a chi
# disegna, e se invecchia manda prompt sbagliati. La CI lo confronta da sempre;
# questo script no, e chi cambiava il testo di una carta vedeva `exit 0` e
# scopriva il disallineamento dalla CI mezz'ora dopo. E' successo con l'Assedio
# e l'Archivio (D-218): il cancello locale diceva verde e la CI rossa, che e'
# esattamente la distanza che D-189 aveva gia' pagato una volta.
BRIEF="$ROOT/docs/BRIEF_ARTE.md"
if [ -f "$BRIEF" ] && [ -f "$OUT/brief_arte.md" ]; then
  if ! diff -q "$OUT/brief_arte.md" "$BRIEF" > /dev/null; then
    echo ""
    echo "ATTENZIONE: docs/BRIEF_ARTE.md non e' quello che l'export genera adesso."
    echo "  cp \"$OUT/brief_arte.md\" docs/BRIEF_ARTE.md"
    if [ $CHECK_BRIEF -eq 1 ]; then
      exit 1
    fi
  elif [ $CHECK_BRIEF -eq 1 ]; then
    echo "OK  docs/BRIEF_ARTE.md e' allineato"
  fi
fi

echo ""
echo "Fogli: $OUT/fogli   ·   brief: $OUT/brief_arte.md"
if [ $WANT_PDF -eq 1 ]; then
  echo "PDF di stampa: $OUT/echoes_print.pdf"
fi
