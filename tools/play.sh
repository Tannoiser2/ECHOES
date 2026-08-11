#!/usr/bin/env bash
# Sit down and play a Chronicle.
#
#   tools/play.sh                      un seggio (i Nahr) contro tre policy
#   tools/play.sh --seats=all          tutti e quattro alla tastiera
#   tools/play.sh --seats=ENT_ALDRIC   scegli il tuo
#   tools/play.sh --seed=1234 --quiet  altro mondo, senza traccia delle regole
#
# Qualsiasi opzione di run_hotseat.gd passa di qui. L'unica cosa che questo
# script fa in piu e trovare Godot: nell'ordine, $GODOT, poi godot / godot4 nel
# PATH, poi un binario scaricato accanto al progetto.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find_godot() {
  if [[ -n "${GODOT:-}" ]]; then
    echo "$GODOT"; return
  fi
  for candidate in godot godot4 Godot; do
    if command -v "$candidate" >/dev/null 2>&1; then
      echo "$candidate"; return
    fi
  done
  # Scaricato a mano e lasciato accanto al progetto o in ~/godot.
  for candidate in "$ROOT"/Godot_v4.7.1-stable_linux.x86_64 \
                   "$HOME"/Godot_v4.7.1-stable_linux.x86_64 \
                   "$HOME"/godot/Godot_v4.7.1-stable_linux.x86_64; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"; return
    fi
  done
  echo ""
}

GODOT_BIN="$(find_godot)"
if [[ -z "$GODOT_BIN" ]]; then
  cat >&2 <<'MSG'
Non trovo Godot.

ECHOES gira sul build headless di Godot 4.7.1 - nessuna installazione, e un
file solo. Scaricalo da https://godotengine.org/download (o dalle release su
GitHub, cerca "Godot_v4.7.1-stable_linux.x86_64.zip"), poi:

    unzip Godot_v4.7.1-stable_linux.x86_64.zip
    chmod +x Godot_v4.7.1-stable_linux.x86_64
    GODOT=./Godot_v4.7.1-stable_linux.x86_64 tools/play.sh

oppure mettilo nel PATH come `godot` e questo script lo trova da solo.
MSG
  exit 127
fi

# Senza un terminale interattivo il gioco chiede e non riceve risposta: ogni
# scelta prende il default e la policy gioca al posto tuo. Legittimo per pipare
# un file di risposte, sorprendente se ci sei arrivato per sbaglio.
if [[ ! -t 0 ]]; then
  echo "(stdin non e un terminale: le scelte senza risposta le prende la policy)" >&2
fi

exec "$GODOT_BIN" --headless --path "$ROOT/godot" \
  --script res://cli/run_hotseat.gd -- "$@"
