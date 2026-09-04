#!/usr/bin/env python3
"""Il menu del Consiglio a quattro piu' quattro (D-453).

    python3 tools/trim_council_menus.py            # mostra cosa resterebbe, carta per carta
    python3 tools/trim_council_menus.py --apply    # riscrive i due file delle Tensioni

Parola del committente: *«massimo ci potevano essere 4 benefici e 4 costi»*.
Le carte ne portavano da 8 a 12 per lato: era il vocabolario intero che il
Tema raggiunge, non un menu. Questo strumento taglia una volta, con una regola
scritta, e da qui in poi la guardia sta in `validate_physical.py`: piu' di
quattro per lato e' un difetto.

La regola, per ogni carta:

- **benefici**: resta la casella della memoria della carta — IL MONDO RICORDA
  o IL MONDO DIMENTICA, che e' la sua storia (D-308) — e con lei le tre piu'
  comprate in cento partite; a parita', l'ordine d'autore;
- **costi**: le quattro piu' posate in cento partite; a parita', l'ordine
  d'autore;
- **se cade**: non si tocca.

I numeri delle cento partite (`run_boxes_probe --runs=100`, semi da 7000,
360 Consigli) sono qui sotto, e sono la sola cosa che decide fra due caselle
dello stesso rango. Un verbo che non compare e' stato comprato zero volte.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
FILES = [
    REPO_ROOT / "godot" / "data" / "tensions" / "tensions_core.json",
    REPO_ROOT / "godot" / "data" / "tensions" / "tensions_library.json",
]
MAX_PER_LIST = 4
MEMORY_VERBS = {"REMEMBER", "FORGET"}

# verbo -> comprata, in cento partite (0.1.421, sedie corrette).
BOUGHT = {
    "BUILD_STONE": 217, "COOL_THEME": 180, "TAKE_CONTROL": 172,
    "CLEAR_CONDITION": 105, "COOL_QUESTION": 75, "REMEMBER": 55,
    "REOPEN": 24, "MARK_HOUSE": 4, "BIND_HOUSES": 3, "MOVE_OUT": 1,
    "RAISE_STONE": 1,
    "SCAR": 56, "YIELD_CONTROL": 54, "ADD_CONDITION": 28, "TAKE_DEBT": 1,
}


def _rank(voices: list[dict], keep_memory: bool) -> tuple[list[dict], list[dict]]:
    """Le voci da tenere e quelle che escono, nell'ordine d'autore."""
    order = {id(v): i for i, v in enumerate(voices)}
    chosen: list[dict] = []
    if keep_memory:
        chosen = [v for v in voices if v.get("verb") in MEMORY_VERBS][:1]
    rest = [v for v in voices if not any(v is c for c in chosen)]
    rest.sort(key=lambda v: (-BOUGHT.get(str(v.get("verb")), 0), order[id(v)]))
    chosen += rest[: MAX_PER_LIST - len(chosen)]
    kept = [v for v in voices if any(v is c for c in chosen)]
    dropped = [v for v in voices if not any(v is c for c in chosen)]
    return kept, dropped


def main(argv: list[str]) -> int:
    apply = "--apply" in argv
    rows: list[str] = []
    dropped_total = 0
    for path in FILES:
        doc = json.loads(path.read_text(encoding="utf-8"))
        for tension in doc["items"]:
            face = tension.get("physical") or {}
            if not face:
                continue
            cells = [tension["id"]]
            for list_name, keep_memory in (("benefits", True), ("costs", False)):
                voices = face.get(list_name) or []
                kept, dropped = _rank(voices, keep_memory)
                dropped_total += len(dropped)
                face[list_name] = kept
                cells.append(", ".join(str(v["verb"]) for v in kept))
                cells.append(", ".join(str(v["verb"]) for v in dropped) or "—")
            rows.append("| " + " | ".join(cells) + " |")
        if apply:
            path.write_text(json.dumps(doc, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("| carta | benefici che restano | benefici che escono | costi che restano | costi che escono |")
    print("|---|---|---|---|---|")
    print("\n".join(rows))
    print()
    print("caselle tolte: %d" % dropped_total)
    if apply:
        print("scritti: %s" % ", ".join(str(p.relative_to(REPO_ROOT)) for p in FILES))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
