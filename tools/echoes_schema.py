"""Shared schema loading helpers for the ECHOES tooling.

The files in /schema are the single source of truth (§17). Both the Python
validator and the GDScript generator read them from here; nothing duplicates a
validation rule by hand.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, Iterator, List, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent
SCHEMA_DIR = REPO_ROOT / "schema"
DATA_DIR = REPO_ROOT / "godot" / "data"
GENERATED_GD = REPO_ROOT / "godot" / "scripts" / "core" / "schema_defs.gd"


def load_schemas() -> Dict[str, Dict[str, Any]]:
    """Return {file stem without '.schema': parsed schema}."""
    schemas: Dict[str, Dict[str, Any]] = {}
    for path in sorted(SCHEMA_DIR.glob("*.schema.json")):
        name = path.name[: -len(".schema.json")]
        with path.open(encoding="utf-8") as handle:
            schemas[name] = json.load(handle)
    if not schemas:
        raise SystemExit(f"no schemas found in {SCHEMA_DIR}")
    return schemas


def schema_filenames() -> Dict[str, str]:
    return {
        path.name[: -len(".schema.json")]: path.name
        for path in sorted(SCHEMA_DIR.glob("*.schema.json"))
    }


def primary_def(schema: Dict[str, Any], name: str) -> Dict[str, Any]:
    """Resolve the schema's primary definition (declared via x-echoes-def)."""
    def_name = schema.get("x-echoes-def", name)
    defs = schema.get("$defs", {})
    if def_name not in defs:
        raise SystemExit(f"schema '{name}' has no $defs/{def_name}")
    return defs[def_name]


def iter_data_files() -> Iterator[Tuple[Path, Dict[str, Any]]]:
    """Yield (path, parsed json) for every data document under godot/data."""
    for path in sorted(DATA_DIR.rglob("*.json")):
        with path.open(encoding="utf-8") as handle:
            try:
                yield path, json.load(handle)
            except json.JSONDecodeError as exc:
                raise SystemExit(f"{rel(path)}: invalid JSON: {exc}") from exc


def items_of(schema_id: str) -> List[Dict[str, Any]]:
    """Ogni voce dei documenti che dichiarano quello `schema_id`.

    Si sceglie per **schema, non per cartella**, e la ragione e' pagata due
    volte. `build_review.py` nominava a mano un file cancellato con gli anni
    d'autore e moriva all'avvio (D-328). Poi, fondendo i file che portavano il
    nome di quegli anni (ISSUES 99), quattro strumenti che cercavano i template
    dei Consigli in `chronicle_*/confluences/` hanno smesso di vederli **senza
    fallire**: il registro dei segni ha dichiarato otto clausole impossibili che
    non lo erano, e il censimento dei componenti ha scritto «Modelli di
    Consiglio: 0».

    Un documento va trovato per quello che **dice di essere**, cosi' nessuno
    puo' renderlo invisibile spostandolo.
    """
    out: List[Dict[str, Any]] = []
    for _path, document in iter_data_files():
        if str(document.get("schema_id", "")) == schema_id:
            out.extend(document.get("items", []))
    return out


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)
