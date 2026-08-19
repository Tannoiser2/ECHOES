#!/usr/bin/env python3
"""Il codice che non verra' mai eseguito.

Un blocco finito dopo un `return` non e' un errore per GDScript: e' silenzio.
Il bottone «Si comincia» della stanza e' vissuto una versione intera dietro un
`return`, e nessuna misura poteva vederlo — la suite prova quello che il codice
fa, non quello che il codice ha smesso di fare.

Regola: dentro una funzione, se una riga di istruzione segue un `return`,
`continue`, `break` o `pass` finale allo *stesso* rientro, quella riga e' morta.
Commenti e righe vuote non contano; un rientro minore chiude il blocco.
"""
from pathlib import Path
import re
import sys

STOP = re.compile(r"^(return\b|continue\b|break\b)")
ROOT = Path(__file__).resolve().parent.parent / "godot"


def indent_of(line: str) -> int:
    return len(line) - len(line.lstrip("\t"))


def balance(line: str) -> int:
    """Quante parentesi restano aperte a fine riga (stringhe e commenti esclusi)."""
    depth = 0
    quote = ""
    index = 0
    while index < len(line):
        char = line[index]
        if quote:
            if char == "\\":
                index += 2
                continue
            if char == quote:
                quote = ""
        elif char in "\"'":
            quote = char
        elif char == "#":
            break
        elif char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
        index += 1
    return depth


def scan(path: Path) -> list:
    """Le righe che nessuna esecuzione raggiungera'.

    Un `return` la cui espressione continua sotto (parentesi ancora aperte) non
    ha ancora finito di parlare: il salto vale dalla riga che chiude.
    """
    found = []
    stop_at = None  # (rientro, riga del salto)
    open_depth = 0
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if open_depth > 0:
            open_depth += balance(line)
            continue
        depth = indent_of(line)
        if stop_at is not None:
            if depth == stop_at[0]:
                found.append((number, stop_at[1], stripped))
                stop_at = None
            elif depth < stop_at[0]:
                stop_at = None
        if STOP.match(stripped):
            stop_at = (depth, number)
            open_depth = max(0, balance(line))
    return found


def main() -> int:
    dead = []
    for path in sorted(ROOT.rglob("*.gd")):
        for number, after, text in scan(path):
            dead.append("%s:%d  irraggiungibile (dopo il salto di riga %d): %s"
                        % (path.relative_to(ROOT.parent), number, after, text))
    if dead:
        print("\n".join(dead))
        print("\n%d riga/e di codice che non verranno mai eseguite." % len(dead))
        return 1
    print("OK  nessun codice irraggiungibile in %d file .gd"
          % len(list(ROOT.rglob("*.gd"))))
    return 0


if __name__ == "__main__":
    sys.exit(main())
