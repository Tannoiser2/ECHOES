#!/usr/bin/env python3
"""Generate docs/ASSET_MANIFEST.md from godot/data.

The manifest is the production list for the art pass: every element that needs a
placeholder now and an illustration later, with its art_prompt_key and the
Master Prompt it belongs to (docs/ART_BIBLE.md).

Usage:
    python3 tools/build_manifest.py
    python3 tools/build_manifest.py --check   # exit 1 if the file is stale
"""

from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from typing import Any, Dict, List

from echoes_schema import REPO_ROOT, iter_data_files, rel

MANIFEST = REPO_ROOT / "docs" / "ASSET_MANIFEST.md"

HEADER = """# ECHOES - Asset Manifest

<!-- GENERATED FILE - regenerate with `python3 tools/build_manifest.py`. -->

Every visual element the Chronicle needs, taken straight from `godot/data`.
`art_prompt_key` is the lookup into the Master Prompts in
[ART_BIBLE.md](ART_BIBLE.md); `marker_id` is the optional fiducial hook reserved
for the physical table (spec §19.5) and is not used by any code in 0.0.

§19.4 asks for 48 Assets, 24 Echo cards, 12 Region tiles, 24 map overlays and 12
standees. The Assets and the Echo cards are there; the tiles, the overlays and
the standees are art, and they are 0.2's problem.

The Asset deck reads off the rarity: COMMON is strength 1 and 4 copies, UNCOMMON
strength 2 and 2 copies, RARE strength 3 and a single copy. Eight cards per
family, 22 copies per family deck, 132 cards in the box (D-040).

"""


def collect() -> Dict[str, List[Dict[str, Any]]]:
    documents: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    for _path, document in iter_data_files():
        if not isinstance(document, dict) or "schema_id" not in document:
            continue
        documents[document["schema_id"]].extend(document.get("items", []))
    return documents


def table(rows: List[List[str]], headings: List[str]) -> str:
    lines = ["| " + " | ".join(headings) + " |"]
    lines.append("|" + "|".join(["---"] * len(headings)) + "|")
    for row in rows:
        lines.append("| " + " | ".join(row) + " |")
    return "\n".join(lines) + "\n"


def render(documents: Dict[str, List[Dict[str, Any]]]) -> str:
    parts = [HEADER]

    assets = sorted(documents.get("asset", []), key=lambda a: (a["family"], -a["strength"], a["id"]))
    parts.append(f"## Asset cards ({len(assets)})\n")
    parts.append(
        table(
            [
                [
                    a["id"],
                    a["title"],
                    a["family"],
                    str(a["strength"]),
                    a["rarity"],
                    str(a.get("deck_copies", 3)),
                    a["discard_or_retain_rule"],
                    f"`{a['art_prompt_key']}`",
                ]
                for a in assets
            ],
            ["id", "titolo", "famiglia", "forza", "rarita", "copie", "scarto", "art_prompt_key"],
        )
    )

    cards = sorted(documents.get("echo_card", []), key=lambda c: (c["dramatic_family"], c["id"]))
    parts.append(f"\n## Echo cards ({len(cards)})\n")
    parts.append(
        table(
            [
                [c["id"], c["title"], c["dramatic_family"], c["function_id"], f"`{c['art_prompt_key']}`"]
                for c in cards
            ],
            ["id", "titolo", "famiglia drammatica", "funzione", "art_prompt_key"],
        )
    )

    regions = sorted(documents.get("region", []), key=lambda r: (r["role"], r["id"]))
    parts.append(f"\n## Region tiles ({len(regions)})\n")
    parts.append(
        table(
            [
                [
                    r["id"],
                    r["name"],
                    r["biome"],
                    r["role"],
                    str(r["presence_slots"]),
                    ", ".join(r["asset_sources"]) or "-",
                    f"`{r['art_prompt_key']}`",
                    f"`{r.get('marker_id', '-')}`",
                ]
                for r in regions
            ],
            ["id", "nome", "biome", "ruolo", "slot", "fonti Asset", "art_prompt_key", "marker_id"],
        )
    )

    entities = sorted(documents.get("entity", []), key=lambda e: e["id"])
    parts.append(f"\n## Entity cards ({len(entities)})\n")
    parts.append(
        table(
            [
                [
                    e["id"],
                    e["name"],
                    e["archetype"],
                    e["need"],
                    e["destiny_id"],
                    f"`{e.get('art_prompt_key', '-')}`",
                ]
                for e in entities
            ],
            ["id", "nome", "archetipo", "bisogno", "destiny", "art_prompt_key"],
        )
    )

    destinies = sorted(documents.get("destiny", []), key=lambda d: d["id"])
    parts.append(f"\n## Destiny cards ({len(destinies)})\n")
    parts.append(
        table(
            [
                [
                    d["id"],
                    d["title"],
                    d["entity_id"],
                    d["minimum"]["label"],
                    d["victory"]["label"],
                    d["triumph"]["label"],
                ]
                for d in destinies
            ],
            ["id", "titolo", "entita", "Minimum", "Victory", "Triumph"],
        )
    )

    tensions = sorted(documents.get("tension", []), key=lambda t: t["id"])
    parts.append(f"\n## Tension tracks ({len(tensions)})\n")
    parts.append(
        table(
            [
                [
                    t["id"],
                    t["title"],
                    t["domain"],
                    str(t["current_value"]),
                    str(t["threshold"]),
                    t["visibility"],
                    str(len(t["omen_thresholds"])),
                ]
                for t in tensions
            ],
            ["id", "titolo", "dominio", "iniziale", "soglia", "visibilita", "presagi"],
        )
    )

    # Every distinct region tag is a map overlay the art pass has to cover.
    overlays = set()
    for region in documents.get("region", []):
        overlays.update(region.get("tags", []))
    for consequence in documents.get("consequence", []):
        for effect in consequence.get("effects", []):
            if effect["type"] in ("SET_REGION_TAG", "ADD_SCAR"):
                tag = effect["payload"].get("tag")
                if isinstance(tag, str) and not tag.startswith("$"):
                    overlays.add(tag)
    parts.append(f"\n## Map overlays ({len(overlays)})\n")
    parts.append(
        "Ogni tag di Regione che il gioco puo mostrare sulla mappa. `domain:` marca il "
        "dominio di Tensione usato da INFLUENCE; `structure:`, `condition:` e `scar:` "
        "sono livelli grafici distinti (spec §19.5).\n\n"
    )
    parts.append(
        table(
            [[f"`{tag}`", tag.split(":")[0] if ":" in tag else "base"] for tag in sorted(overlays)],
            ["tag", "layer"],
        )
    )

    return "".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="exit 1 if the file is stale")
    args = parser.parse_args()

    rendered = render(collect())
    if args.check:
        if not MANIFEST.exists() or MANIFEST.read_text(encoding="utf-8") != rendered:
            sys.stderr.write(
                f"{rel(MANIFEST)} is out of date. Run: python3 tools/build_manifest.py\n"
            )
            return 1
        print(f"OK  {rel(MANIFEST)} matches the data")
        return 0

    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(rendered, encoding="utf-8")
    print(f"wrote {rel(MANIFEST)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
