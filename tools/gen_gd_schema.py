#!/usr/bin/env python3
"""Generate godot/scripts/core/schema_defs.gd from /schema (§17).

The generated file is the *only* place Godot learns about required fields,
types and enums. It is committed to the repository and the CI drift check
(`--check`) fails when it no longer matches the schemas.

Usage:
    python3 tools/gen_gd_schema.py           # write the file
    python3 tools/gen_gd_schema.py --check   # exit 1 if the file is stale
"""

from __future__ import annotations

import argparse
import sys
from typing import Any, Dict, List, Optional

from echoes_schema import GENERATED_GD, load_schemas, primary_def, rel

HEADER = """# GENERATED FILE - DO NOT EDIT BY HAND.
#
# Produced by tools/gen_gd_schema.py from the JSON Schemas in /schema, which are
# the single source of truth for the data model (spec v0.2 §17). Edit the
# schemas and re-run the generator; CI fails if this file drifts.
extends RefCounted

## Bump when the generator's output format changes.
const GENERATOR_VERSION := "1"
"""

JSON_TO_GD = {
    "string": "String",
    "integer": "int",
    "number": "float",
    "boolean": "bool",
    "array": "Array",
    "object": "Dictionary",
    "null": "null",
}


def gd_quote(value: str) -> str:
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def gd_value(value: Any, indent: int) -> str:
    pad = "\t" * indent
    inner = "\t" * (indent + 1)
    if isinstance(value, dict):
        if not value:
            return "{}"
        lines = [
            f"{inner}{gd_quote(str(k))}: {gd_value(v, indent + 1)},"
            for k, v in value.items()
        ]
        return "{\n" + "\n".join(lines) + f"\n{pad}}}"
    if isinstance(value, list):
        if not value:
            return "[]"
        lines = [f"{inner}{gd_value(v, indent + 1)}," for v in value]
        return "[\n" + "\n".join(lines) + f"\n{pad}]"
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return "null"
    if isinstance(value, str):
        return gd_quote(value)
    return str(value)


def resolve_ref(ref: str, schema: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Resolve a local '#/$defs/x' ref. Cross-file refs stay opaque."""
    if ref.startswith("#/$defs/"):
        return schema.get("$defs", {}).get(ref[len("#/$defs/") :])
    return None


def describe(prop: Dict[str, Any], schema: Dict[str, Any]) -> Dict[str, Any]:
    """Reduce a JSON Schema property to what the Godot runtime validator needs."""
    if "$ref" in prop:
        target = resolve_ref(prop["$ref"], schema)
        if target is None:
            # Cross-file ref: the shape is validated by validate_data.py; Godot
            # only needs to know it is a structured value.
            return {"type": "Dictionary"}
        prop = {**target, **{k: v for k, v in prop.items() if k != "$ref"}}

    out: Dict[str, Any] = {}

    if "const" in prop:
        out["type"] = JSON_TO_GD.get(_type_of(prop["const"]), "String")
        out["enum"] = [prop["const"]]
        return out

    json_type = prop.get("type")
    if isinstance(json_type, list):
        non_null = [t for t in json_type if t != "null"]
        out["type"] = JSON_TO_GD.get(non_null[0], "Variant") if non_null else "Variant"
        out["nullable"] = "null" in json_type
    elif isinstance(json_type, str):
        out["type"] = JSON_TO_GD[json_type]
    elif "enum" in prop:
        out["type"] = "String"
    else:
        out["type"] = "Variant"

    if "enum" in prop:
        out["enum"] = list(prop["enum"])
    if "pattern" in prop:
        out["pattern"] = prop["pattern"]
    for json_key, gd_key in (
        ("minimum", "min"),
        ("maximum", "max"),
        ("minLength", "min_length"),
        ("minItems", "min_items"),
        ("maxItems", "max_items"),
    ):
        if json_key in prop:
            out[gd_key] = prop[json_key]
    if "default" in prop:
        out["default"] = prop["default"]

    if out["type"] == "Array" and isinstance(prop.get("items"), dict):
        element = describe(prop["items"], schema)
        # Only carry the parts the runtime checker can act on.
        keep = {k: v for k, v in element.items() if k in ("type", "enum", "pattern")}
        if keep:
            out["element"] = keep

    return out


def _type_of(value: Any) -> str:
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict):
        return "object"
    return "null"


def build_definition(name: str, schema: Dict[str, Any]) -> Dict[str, Any]:
    definition = primary_def(schema, name)
    properties: Dict[str, Any] = {}
    for prop_name, prop in definition.get("properties", {}).items():
        properties[prop_name] = describe(prop, schema)
    return {
        "kind": schema.get("x-echoes-kind", "collection"),
        "required": list(definition.get("required", [])),
        "additional_properties": bool(definition.get("additionalProperties", True)),
        "properties": properties,
    }


def collection_schema_ids(schemas: Dict[str, Dict[str, Any]]) -> List[str]:
    ids = []
    for name, schema in schemas.items():
        if schema.get("x-echoes-kind") != "collection":
            continue
        const = schema.get("properties", {}).get("schema_id", {}).get("const")
        ids.append(const or name)
    return sorted(ids)


def render(schemas: Dict[str, Dict[str, Any]]) -> str:
    definitions: Dict[str, Any] = {}
    for name in sorted(schemas):
        definitions[name] = build_definition(name, schemas[name])

    effect_schema = schemas["effect"]
    effect_types = effect_schema["$defs"]["effect_type"]["enum"]
    target_kinds = effect_schema["$defs"]["target"]["properties"]["kind"]["enum"]
    source_kinds = effect_schema["$defs"]["source"]["properties"]["kind"]["enum"]
    condition_types = schemas["destiny"]["$defs"]["condition"]["properties"]["type"]["enum"]
    asset_families = schemas["asset"]["$defs"]["asset"]["properties"]["family"]["enum"]
    relation_levels = (
        schemas["world_state"]["$defs"]["relation_state"]["properties"]["level"]["enum"]
    )
    phases = schemas["world_state"]["$defs"]["world_state"]["properties"]["phase"]["enum"]
    templates = schemas["action"]["$defs"]["action"]["properties"]["template"]["enum"]
    consequence_categories = (
        schemas["consequence"]["$defs"]["consequence_category"]["enum"]
    )
    dramatic_families = (
        schemas["echo_card"]["$defs"]["echo_card"]["properties"]["dramatic_family"]["enum"]
    )

    parts = [
        HEADER,
        "",
        "## Schema definitions keyed by schema file stem.",
        f"const DEFS := {gd_value(definitions, 0)}",
        "",
        "## schema_id values that appear as authored collections under res://data.",
        f"const COLLECTION_SCHEMA_IDS := {gd_value(collection_schema_ids(schemas), 0)}",
        "",
        "## Closed EffectType enum (spec v0.2 §6.3).",
        f"const EFFECT_TYPES := {gd_value(list(effect_types), 0)}",
        "",
        f"const EFFECT_TARGET_KINDS := {gd_value(list(target_kinds), 0)}",
        "",
        f"const EFFECT_SOURCE_KINDS := {gd_value(list(source_kinds), 0)}",
        "",
        f"const CONDITION_TYPES := {gd_value(list(condition_types), 0)}",
        "",
        f"const ASSET_FAMILIES := {gd_value(list(asset_families), 0)}",
        "",
        f"const RELATION_LEVELS := {gd_value(list(relation_levels), 0)}",
        "",
        f"const PHASES := {gd_value(list(phases), 0)}",
        "",
        f"const ACTION_TEMPLATES := {gd_value(list(templates), 0)}",
        "",
        f"const CONSEQUENCE_CATEGORIES := {gd_value(list(consequence_categories), 0)}",
        "",
        f"const DRAMATIC_FAMILIES := {gd_value(list(dramatic_families), 0)}",
        "",
    ]
    return "\n".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="do not write; exit 1 if the committed file differs (CI drift check)",
    )
    args = parser.parse_args()

    rendered = render(load_schemas())

    if args.check:
        if not GENERATED_GD.exists():
            sys.stderr.write(f"{rel(GENERATED_GD)} is missing; run tools/gen_gd_schema.py\n")
            return 1
        current = GENERATED_GD.read_text(encoding="utf-8")
        if current != rendered:
            sys.stderr.write(
                f"{rel(GENERATED_GD)} is out of date with /schema.\n"
                "Run: python3 tools/gen_gd_schema.py\n"
            )
            return 1
        print(f"OK  {rel(GENERATED_GD)} matches /schema")
        return 0

    GENERATED_GD.parent.mkdir(parents=True, exist_ok=True)
    GENERATED_GD.write_text(rendered, encoding="utf-8")
    print(f"wrote {rel(GENERATED_GD)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
