#!/usr/bin/env python3
"""Validate every data document in godot/data against /schema (§17).

Two passes:
  1. JSON Schema 2020-12 validation, selected by each document's `schema_id`.
  2. Referential integrity: every id referenced by a document must exist.

Usage:
    python3 tools/validate_data.py [--quiet]

Exit code 0 = clean, 1 = at least one error.
"""

from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Set

try:
    from jsonschema import Draft202012Validator
    from referencing import Registry, Resource
except ImportError:  # pragma: no cover - environment guard
    sys.stderr.write(
        "missing dependency: pip install 'jsonschema>=4.18' 'referencing>=0.30'\n"
    )
    raise SystemExit(2)

from echoes_schema import DATA_DIR, iter_data_files, load_schemas, rel

# Documents that are runtime shapes, not authored collections. They live in
# /schema but never appear as files under godot/data.
RUNTIME_SCHEMAS = {"effect", "world_state", "save"}


def build_registry(schemas: Dict[str, Dict[str, Any]]) -> Registry:
    """Register every schema under both its $id and its bare filename.

    Cross-file `$ref`s in /schema are written as relative filenames
    (e.g. "effect.schema.json#/$defs/effect_spec"), so both spellings resolve.
    """
    resources = []
    for name, schema in schemas.items():
        resource = Resource.from_contents(schema)
        resources.append((f"{name}.schema.json", resource))
        if "$id" in schema:
            resources.append((schema["$id"], resource))
    return Registry().with_resources(resources)


class Report:
    def __init__(self) -> None:
        self.errors: List[str] = []
        self.checked = 0

    def fail(self, where: str, message: str) -> None:
        self.errors.append(f"{where}: {message}")


def collect_ids(documents: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Set[str]]:
    ids: Dict[str, Set[str]] = defaultdict(set)
    for schema_id, items in documents.items():
        for item in items:
            if isinstance(item, dict) and "id" in item:
                ids[schema_id].add(item["id"])
    return ids


def check_references(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: Report,
) -> None:
    """Second pass: every referenced id must resolve to a defined item."""
    ids = collect_ids(documents)
    known_assets = ids.get("asset", set())
    known_regions = ids.get("region", set())
    known_entities = ids.get("entity", set())
    known_tensions = ids.get("tension", set())
    known_destinies = ids.get("destiny", set())
    known_consequences = ids.get("consequence", set())
    known_echoes = ids.get("echo_card", set())
    known_templates = ids.get("confluence_template", set())

    def require(container: Set[str], value: str, kind: str, where: str) -> None:
        if value not in container:
            report.fail(where, f"unknown {kind} id '{value}'")

    for entity in documents.get("entity", []):
        where = f"{origins['entity']} [{entity['id']}]"
        for asset_id in entity.get("starting_assets", []):
            require(known_assets, asset_id, "asset", where)
        for region_id in entity.get("presence", []):
            require(known_regions, region_id, "region", where)
        for relation in entity.get("relations", []):
            require(known_entities, relation["with"], "entity", where)
        require(known_destinies, entity["destiny_id"], "destiny", where)

    for region in documents.get("region", []):
        where = f"{origins['region']} [{region['id']}]"
        for neighbour in region.get("adjacency", []):
            require(known_regions, neighbour, "region", where)
        control = region.get("control")
        if control:
            require(known_entities, control, "entity", where)

    # Adjacency must be symmetric or movement becomes one-way by accident.
    adjacency = {r["id"]: set(r.get("adjacency", [])) for r in documents.get("region", [])}
    for region_id, neighbours in adjacency.items():
        for neighbour in neighbours:
            if neighbour in adjacency and region_id not in adjacency[neighbour]:
                report.fail(
                    f"{origins['region']} [{region_id}]",
                    f"adjacency to '{neighbour}' is not reciprocal",
                )

    for tension in documents.get("tension", []):
        where = f"{origins['tension']} [{tension['id']}]"
        for linked in tension.get("linked_tensions", []):
            require(known_tensions, linked, "tension", where)
        template_id = tension.get("confluence_template_id")
        if template_id:
            require(known_templates, template_id, "confluence_template", where)

    for destiny in documents.get("destiny", []):
        where = f"{origins['destiny']} [{destiny['id']}]"
        require(known_entities, destiny["entity_id"], "entity", where)
        for level_name in ("minimum", "victory", "triumph"):
            for condition in destiny[level_name]["conditions"]:
                _check_condition(condition, known_entities, known_regions, known_tensions, report, f"{where}.{level_name}")

    for card in documents.get("echo_card", []):
        where = f"{origins['echo_card']} [{card['id']}]"
        for hook in card.get("effect_hooks", []):
            if hook["kind"] == "CONSEQUENCE":
                if "consequence_id" not in hook:
                    report.fail(where, "CONSEQUENCE hook without consequence_id")
                else:
                    require(known_consequences, hook["consequence_id"], "consequence", where)
            elif "effect" not in hook:
                report.fail(where, "EFFECT hook without effect")
        forced = card.get("forces_confluence_on")
        if forced:
            require(known_tensions, forced, "tension", where)
        for condition in card.get("eligibility", []):
            _check_condition(condition, known_entities, known_regions, known_tensions, report, where)

    for template in documents.get("confluence_template", []):
        where = f"{origins['confluence_template']} [{template['id']}]"
        require(known_tensions, template["tension_id"], "tension", where)
        question_ids = {q["id"] for q in template["questions"]}
        for question in template["questions"]:
            for condition in question["eligibility"]:
                _check_condition(
                    condition, known_entities, known_regions, known_tensions, report, where
                )
        for proposition in template["propositions"]:
            for condition in proposition["eligibility"]:
                _check_condition(
                    condition, known_entities, known_regions, known_tensions, report, where
                )
            if proposition["question_id"] not in question_ids:
                report.fail(where, f"proposition '{proposition['id']}' references unknown question")
            for consequence_id in proposition["success_consequences"]:
                require(known_consequences, consequence_id, "consequence", where)
        for pool_name, pool in template["consequence_pools"].items():
            for consequence_id in pool:
                require(known_consequences, consequence_id, "consequence", f"{where}.{pool_name}")
        for target in template["ripple"]["targets"]:
            require(known_tensions, target, "tension", where)

    for chronicle in documents.get("chronicle", []):
        where = f"{origins['chronicle']} [{chronicle['id']}]"
        for entity_id in chronicle["entities"]:
            require(known_entities, entity_id, "entity", where)
        for region_id in chronicle["regions"]:
            require(known_regions, region_id, "region", where)
        for tension_id in chronicle["tensions"]:
            require(known_tensions, tension_id, "tension", where)
        for template_id in chronicle["confluence_templates"]:
            require(known_templates, template_id, "confluence_template", where)
        for bag in chronicle["drift_distribution"]:
            if bag["tension_id"] not in chronicle["tensions"]:
                report.fail(where, f"drift entry '{bag['tension_id']}' is not in this Chronicle")
        drift_total = sum(bag["count"] for bag in chronicle["drift_distribution"])
        expected = chronicle["acts"] * chronicle["rounds_per_act"]
        if drift_total != expected:
            report.fail(
                where,
                f"drift_distribution totals {drift_total}, expected {expected} (acts x rounds_per_act)",
            )
        acts_covered = {pool["act"] for pool in chronicle["act_echo_pools"]}
        if acts_covered != set(range(1, chronicle["acts"] + 1)):
            report.fail(where, "act_echo_pools must cover every act exactly once")
        # Every Tension in play needs a Confluence template, or a threshold hit
        # would open a Confluence with nothing to ask.
        templates_by_tension = {t["tension_id"] for t in documents.get("confluence_template", [])}
        for tension_id in chronicle["tensions"]:
            if tension_id not in templates_by_tension:
                report.fail(where, f"tension '{tension_id}' has no Confluence template")
        # Every Act pool must have at least one card available.
        cards_by_family: Dict[str, int] = defaultdict(int)
        for card in documents.get("echo_card", []):
            cards_by_family[card["dramatic_family"]] += 1
        for pool in chronicle["act_echo_pools"]:
            if not any(cards_by_family[f] for f in pool["families"]):
                report.fail(where, f"act {pool['act']} echo pool has no available cards")

    for plan in documents.get("sim_plan", []):
        where = f"{origins.get('sim_plan', 'sim_plan')} [{plan['id']}]"
        for entity_id in plan["seats"]:
            require(known_entities, entity_id, "entity", where)
        for turn in plan["turns"]:
            require(known_entities, turn["actor"], "entity", where)

    for consequence in documents.get("consequence", []):
        where = f"{origins['consequence']} [{consequence['id']}]"
        for effect in consequence["effects"]:
            target_id = effect["target"]["id"]
            if target_id.startswith("$"):
                continue
            kind = effect["target"]["kind"]
            if kind == "tension":
                require(known_tensions, target_id, "tension", where)
            elif kind == "region":
                require(known_regions, target_id, "region", where)
            elif kind == "entity":
                require(known_entities, target_id, "entity", where)

    unused_echoes = known_echoes  # referenced only through Act pools by family
    del unused_echoes


def _check_condition(
    condition: Dict[str, Any],
    entities: Set[str],
    regions: Set[str],
    tensions: Set[str],
    report: Report,
    where: str,
) -> None:
    for key, container, kind in (
        ("entity_id", entities, "entity"),
        ("other_entity_id", entities, "entity"),
        ("region_id", regions, "region"),
        ("tension_id", tensions, "tension"),
    ):
        value = condition.get(key)
        # $proponent and friends are bound at Confluence time, not authoring time.
        if value and not value.startswith("$") and value not in container:
            report.fail(where, f"condition references unknown {kind} '{value}'")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--quiet", action="store_true", help="only print failures")
    args = parser.parse_args()

    schemas = load_schemas()
    registry = build_registry(schemas)
    report = Report()

    documents: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    origins: Dict[str, str] = {}

    if not DATA_DIR.exists():
        sys.stderr.write(f"data directory not found: {DATA_DIR}\n")
        return 1

    for path, document in iter_data_files():
        where = rel(path)
        if not isinstance(document, dict) or "schema_id" not in document:
            report.fail(where, "document has no 'schema_id' field")
            continue
        schema_id = document["schema_id"]
        if schema_id in RUNTIME_SCHEMAS:
            report.fail(where, f"'{schema_id}' is a runtime schema and must not be authored as data")
            continue
        if schema_id not in schemas:
            report.fail(where, f"unknown schema_id '{schema_id}'")
            continue

        validator = Draft202012Validator(schemas[schema_id], registry=registry)
        found = False
        for error in sorted(validator.iter_errors(document), key=lambda e: list(e.path)):
            location = "/".join(str(part) for part in error.path) or "<root>"
            report.fail(where, f"{location}: {error.message}")
            found = True
        report.checked += 1
        if not found:
            documents[schema_id].extend(document["items"])
            origins.setdefault(schema_id, where)

    if not report.errors:
        check_references(documents, origins, report)

    # Duplicate ids across the whole data set are always a bug.
    seen: Dict[str, str] = {}
    for schema_id, items in documents.items():
        for item in items:
            item_id = item.get("id")
            if item_id is None:
                continue
            if item_id in seen:
                report.fail("data", f"duplicate id '{item_id}' (also in {seen[item_id]})")
            else:
                seen[item_id] = schema_id

    if report.errors:
        for error in report.errors:
            sys.stderr.write(f"ERROR {error}\n")
        sys.stderr.write(f"\n{len(report.errors)} error(s) in {report.checked} document(s)\n")
        return 1

    if not args.quiet:
        counts = ", ".join(f"{k}={len(v)}" for k, v in sorted(documents.items()))
        print(f"OK  {report.checked} document(s) valid against /schema  ({counts})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
