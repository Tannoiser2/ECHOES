#!/usr/bin/env python3
"""La sonda dei segni (ISSUES 24): chi scrive un tag, e chi lo legge.

Ogni Conseguenza, cicatrice o carta Echo lascia segni sul mondo; questa sonda
li censisce e li classifica per «dente»:

- vivi per clausola: letti da una condizione nei dati (Destini, Conseguenze,
  eleggibilità di carte e Consigli);
- vivi per motore: prefissi che il codice consuma (`discovery:` in
  discovery_count, `evicted:` nel movimento, `function:` nell'eleggibilità,
  `legend:` nella pesca e nelle clausole);
- vita postuma: fatti nudi letti solo nella loro forma `legend:` dopo lo
  sfumare della memoria;
- ereditati: prefissi che attraversano le ere e vengono narrati
  (condition:/structure:/settlement:/scar:) ma che in partita nessuno legge;
- muti: scritti e mai letti da nulla. Due terzi della memoria del mondo,
  al primo censimento (0.1.65) - ed è la lista di lavoro della voce 24.

Uso: python3 tools/tag_census.py   (dalla radice del repo; exit 0 sempre,
è una sonda, non una guardia).
"""

from __future__ import annotations

import collections
import glob
import json

INHERITED_PREFIXES = ("condition:", "structure:", "settlement:", "scar:")
ENGINE_PREFIXES = ("discovery:", "evicted:", "function:")


def walk_effects(effects, who, written):
    for entry in effects:
        effect_type = entry.get("type", entry.get("effect", {}).get("type", ""))
        spec = entry if "payload" in entry else entry.get("effect", entry)
        payload = spec.get("payload", {})
        if effect_type in ("SET_REGION_TAG", "SET_GLOBAL_TAG", "SET_ENTITY_TAG"):
            written[str(payload.get("tag", ""))].add(who)
        if effect_type == "SET_RELATION" and "add_tag" in payload:
            written[str(payload["add_tag"])].add(who)


def walk_conditions(obj, who, read):
    if isinstance(obj, dict):
        if obj.get("type") in ("state_tag_present", "state_tag_absent"):
            read[str(obj.get("tag", ""))].add(who)
        for value in obj.values():
            walk_conditions(value, who, read)
    elif isinstance(obj, list):
        for value in obj:
            walk_conditions(value, who, read)


def main() -> None:
    written: dict = collections.defaultdict(set)
    read: dict = collections.defaultdict(set)

    for path in glob.glob("godot/data/consequences/*.json"):
        for consequence in json.load(open(path))["items"]:
            walk_effects(consequence.get("effects", []), "CNS:" + consequence["id"], written)
            scar = consequence.get("scar")
            if scar:
                written[str(scar.get("tag", ""))].add("SCAR:" + consequence["id"])

    for path in glob.glob("godot/data/echoes/*.json"):
        for card in json.load(open(path))["items"]:
            for hook in card.get("effect_hooks", []):
                if hook.get("kind") == "EFFECT":
                    walk_effects([hook], "ECHO:" + card["id"], written)

    for path in glob.glob("godot/data/**/*.json", recursive=True):
        document = json.load(open(path))
        for item in document.get("items", []):
            where = document.get("schema_id", "?") + ":" + str(item.get("id", "?"))
            walk_conditions(item, where, read)
            # Una tag_rule accesa è un lettore a pieno titolo (D-104/D-105):
            # il suo segno ha un dente, non è più memoria.
            if document.get("schema_id") == "tag_rule" and item.get("active"):
                read[str(item.get("when", {}).get("tag", ""))].add(where)

    tags_written = set(written) - {""}
    tags_read = set(read) - {""}

    legend_read = {t[len("legend:"):] for t in tags_read if t.startswith("legend:")}
    alive = {t for t in tags_written if t in tags_read}
    engine = {
        t for t in tags_written
        if any(t.startswith(p) for p in ENGINE_PREFIXES)
    } - alive
    afterlife = {t for t in tags_written if t in legend_read} - alive - engine
    inherited = {
        t for t in tags_written
        if any(t.startswith(p) for p in INHERITED_PREFIXES)
    } - alive - engine - afterlife
    mute = tags_written - alive - engine - afterlife - inherited

    print("segni scritti da Conseguenze, cicatrici e carte: %d" % len(tags_written))
    print("  vivi per clausola:  %2d" % len(alive))
    print("  vivi per motore:    %2d  (%s)" % (len(engine), ", ".join(sorted(engine)[:4]) or "-"))
    print("  vita postuma:       %2d  (%s)" % (len(afterlife), ", ".join(sorted(afterlife)) or "-"))
    print("  ereditati, no dente:%2d" % len(inherited))
    print("  muti del tutto:     %2d" % len(mute))
    for tag in sorted(mute):
        print("      %-24s <- %s" % (tag, ", ".join(sorted(written[tag])[:2])))
    orphans = sorted(
        t for t in tags_read
        if t not in tags_written
        and not t.startswith("legend:")
        and not any(t.startswith(p) for p in ENGINE_PREFIXES + INHERITED_PREFIXES)
    )
    if orphans:
        print("condizioni su segni che i dati non scrivono (li scrive il motore o il dato base):")
        for tag in orphans:
            print("      %-24s <- %s" % (tag, ", ".join(sorted(read[tag])[:2])))


if __name__ == "__main__":
    main()
