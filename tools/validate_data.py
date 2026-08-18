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
        # Incarnations (ISSUES 19, Fase 1): the engine still reads the entity's
        # top-level fields, so the first incarnation must mirror them exactly
        # or the two copies drift apart before Fase 2 flips the reader.
        incarnations = entity.get("incarnations", [])
        if incarnations:
            first = incarnations[0]
            if first.get("entry") != "FOUNDING":
                report.fail(where, "first incarnation must have entry FOUNDING")
            for later in incarnations[1:]:
                if later.get("entry") == "FOUNDING":
                    report.fail(where, "only the first incarnation can be FOUNDING")
                if later.get("entry") == "ON_TAG" and "entry_tag" not in later:
                    report.fail(
                        where,
                        f"incarnation '{later.get('id')}' has entry ON_TAG "
                        "without entry_tag",
                    )
            for field in ("name", "description", "persistence", "action_values",
                          "art_prompt_key", "successors", "name_grammar"):
                if first.get(field) != entity.get(field):
                    report.fail(
                        where,
                        f"first incarnation '{first.get('id')}' does not mirror "
                        f"entity field '{field}'",
                    )
            seen_inc: Set[str] = set()
            for incarnation in incarnations:
                inc_id = str(incarnation.get("id"))
                if inc_id in seen_inc:
                    report.fail(where, f"duplicate incarnation id '{inc_id}'")
                seen_inc.add(inc_id)

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

    # Tag rules (ISSUES 24, Fase 2): every kind needs its own fields, or the
    # engine hook it feeds reads a zero and the rule is a dead letter with
    # extra steps.
    NEEDED_BY_KIND = {
        "ACTION_MODIFIER": ("template", "delta"),
        "COUNCIL_MODIFIER": ("world_factor_delta",),
        "GATE": ("movement",),
        "RELATION_CAP": ("max_level",),
        "ACTION_GATE": ("template",),
        "DRAW_BIAS": ("family", "bias"),
        "HAND_LIMIT": ("hand_limit_delta",),
        "GRANT_ON_SET": ("grant",),
        "RELATION_FLOOR": ("min_level",),
        "ACTION_RIPPLE": ("template", "tension_id", "ripple_delta"),
        "ACTION_DISCOUNT": ("template",),
    }
    for rule in documents.get("tag_rule", []):
        where = f"{origins['tag_rule']} [{rule['id']}]"
        kind = str(rule.get("kind", ""))
        for field in NEEDED_BY_KIND.get(kind, ()):
            if field not in rule:
                report.fail(where, f"kind {kind} requires field '{field}'")
        if "tension_id" in rule:
            require(known_tensions, rule["tension_id"], "tension", where)
        scope = str(rule.get("when", {}).get("scope", ""))
        movement = str(rule.get("movement", ""))
        if kind == "GATE" and movement == "PASS":
            # Il PASS (D-125) e' un segno addosso a chi passa, non sulla porta.
            if scope not in ("ENTITY", "GLOBAL"):
                report.fail(where, "GATE PASS wants scope ENTITY or GLOBAL")
        elif kind == "GATE" and scope != "REGION":
            report.fail(where, "GATE BLOCK/ALLOW rules only make sense with scope REGION")
        if rule.get("passes_eviction") and movement != "PASS":
            report.fail(where, "passes_eviction only rides on a PASS")
        # ENTITY sui ganci di relazione (D-131): il segno morde su ogni coppia
        # di cui il portatore e' membro - il tetto verso l'egemone.
        if kind in ("RELATION_CAP", "RELATION_FLOOR") and scope not in ("GLOBAL", "RELATION", "ENTITY"):
            report.fail(where, f"{kind} needs scope GLOBAL, RELATION or ENTITY")
        if kind == "HAND_LIMIT" and int(rule.get("hand_limit_delta", 0)) == 0:
            report.fail(where, "HAND_LIMIT with delta 0 is a dead letter")
        if kind == "GRANT_ON_SET":
            grant = rule.get("grant", {})
            require(known_assets, grant.get("asset_id", ""), "asset", where)
            if str(grant.get("give_to", "ACTOR")) == "TARGET" and scope != "ENTITY":
                report.fail(where, "GRANT_ON_SET give_to TARGET needs scope ENTITY")

    for tension in documents.get("tension", []):
        where = f"{origins['tension']} [{tension['id']}]"
        for linked in tension.get("linked_tensions", []):
            require(known_tensions, linked, "tension", where)
        template_id = tension.get("confluence_template_id")
        if template_id:
            require(known_templates, template_id, "confluence_template", where)

    for destiny in documents.get("destiny", []):
        where = f"{origins['destiny']} [{destiny['id']}]"
        # "$self" è il Destino condivisibile (voce 20, D-115): non appartiene a
        # una casa, si risolve su chi lo giura - niente da cercare nell'elenco.
        if destiny["entity_id"] != "$self":
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
        # A Council may bind to one Tension or to a whole domain (D-028).
        if "tension_id" in template:
            require(known_tensions, template["tension_id"], "tension", where)
        else:
            domains = {t["domain"] for t in documents.get("tension", [])}
            if template["applies_to_domain"] not in domains:
                report.fail(
                    where,
                    f"applies_to_domain '{template['applies_to_domain']}' matches no Tension",
                )
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
        # A Chronicle either writes its Tensions out or draws them from the
        # library (D-028). Everything downstream checks whichever it declared.
        pool = chronicle.get("tension_pool")
        chronicle_tensions = (
            list(pool["candidates"]) + list(pool.get("always", []))
            if pool
            else list(chronicle["tensions"])
        )
        for tension_id in chronicle_tensions:
            require(known_tensions, tension_id, "tension", where)
        if pool and pool["count"] > len(set(chronicle_tensions)):
            report.fail(
                where,
                f"tension_pool draws {pool['count']} but offers only {len(set(chronicle_tensions))}",
            )
        for template_id in chronicle["confluence_templates"]:
            require(known_templates, template_id, "confluence_template", where)
        if "drift_distribution" in chronicle:
            for bag in chronicle["drift_distribution"]:
                if bag["tension_id"] not in chronicle_tensions:
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
        templates_by_tension = {
            t["tension_id"] for t in documents.get("confluence_template", []) if "tension_id" in t
        }
        templates_by_domain = {
            t["applies_to_domain"]
            for t in documents.get("confluence_template", [])
            if "applies_to_domain" in t
        }
        domain_of = {t["id"]: t["domain"] for t in documents.get("tension", [])}
        for tension_id in chronicle_tensions:
            if tension_id in templates_by_tension:
                continue
            if domain_of.get(tension_id) in templates_by_domain:
                continue
            report.fail(where, f"tension '{tension_id}' has no Confluence template")
        # ...e il contrario, che nessuno controllava: un template dichiarato da
        # una Chronicle che nessuna delle sue Tensioni puo' mai aprire. Il motore
        # risolve i template globalmente, quindi la lista qui e' documentazione -
        # e una documentazione che elenca contenuto irraggiungibile e' una
        # seconda verita' (D-063). Trovato con CNF_ANY_SURVIVAL in CHR_03: tre
        # proposte contate come contenuto della seconda saga e mai giocabili,
        # perche' l'unica Tensione SURVIVAL dell'anno ha un template tutto suo.
        template_by_id = {t["id"]: t for t in documents.get("confluence_template", [])}
        for template_id in chronicle["confluence_templates"]:
            template = template_by_id.get(template_id)
            if template is None:
                continue  # gia' segnalato sopra come id sconosciuto
            bound = template.get("tension_id")
            if bound is not None:
                if bound not in chronicle_tensions:
                    report.fail(
                        where,
                        f"template '{template_id}' is bound to '{bound}', "
                        "which this Chronicle does not play",
                    )
                continue
            domain = template.get("applies_to_domain")
            reachable = [
                t
                for t in chronicle_tensions
                # Una Tensione col proprio template non arriva mai a quello di
                # dominio: `confluence_template_for()` prova prima il legame
                # diretto.
                if domain_of.get(t) == domain and t not in templates_by_tension
            ]
            if not reachable:
                report.fail(
                    where,
                    f"template '{template_id}' (domain {domain}) can never open in this "
                    "Chronicle: every Tension of that domain has a template of its own",
                )
        # Ogni Tensione in gioco dev'essere nominata da almeno un Destino al
        # tavolo (D-066). Una domanda che si apre a ogni Chronicle e non tocca
        # nessuno e' una scena senza posta: il Consiglio la decide e i tre
        # seggi che non l'hanno proposta si astengono, perche' per loro non
        # cambia niente. Misurato: 468 letture di ADJUST_TENSION e 6 volte in
        # cui hanno spostato un punteggio.
        #
        # Solo per le Chronicle con le Tensioni scritte a mano: quelle che
        # pescano dalla biblioteca non sanno in anticipo chi si siede.
        if not pool:
            destiny_of = {e["id"]: e.get("destiny_id") for e in documents.get("entity", [])}
            destinies_by_id = {d["id"]: d for d in documents.get("destiny", [])}
            named: set = set()
            for entity_id in chronicle["entities"]:
                destiny = destinies_by_id.get(destiny_of.get(entity_id))
                if destiny is None:
                    continue
                for level in ("minimum", "victory", "triumph"):
                    for condition in destiny.get(level, {}).get("conditions", []):
                        for one in (
                            condition.get("conditions", [])
                            if condition.get("type") == "any_of"
                            else [condition]
                        ):
                            if one.get("type") == "tension_limit":
                                named.add(one.get("tension_id"))
            for tension_id in chronicle_tensions:
                if tension_id not in named:
                    report.fail(
                        where,
                        f"tension '{tension_id}' is in play but no seat's Destiny names it: "
                        "the table has no reason to care how that question ends",
                    )
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

    check_bindings(documents, origins, report)


#: Variables the engine can bind at Confluence time. A Consequence that uses
#: anything else compiles to nothing at all, and the only sign is a push_error
#: buried in a log nobody reads - which is exactly how CNS_HARVEST_RETURNS
#: silently did nothing on an Echo card.
KNOWN_BINDINGS = {
    "proponent",
    "tension",
    "confluence",
    "region_focus",
    "adjacent",
    "rival",
    "rival_seat",
    "capital",
    "actor",
}


def check_bindings(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: Report,
) -> None:
    """Every $variable in an authored Effect spec must be one the engine supplies."""

    def walk(value: Any, where: str) -> None:
        if isinstance(value, str):
            # A relation target is a pair joined by "|", so each half is checked
            # on its own; anything else is a single binding.
            for token in value.split("|") if "|" in value else [value]:
                # `$region_with:<tag>` names a kind of place; the tag has to be
                # one some Region actually declares, or it silently resolves to
                # the focus and the Consequence quietly means something else.
                if token.startswith("$region_with:"):
                    wanted = token[len("$region_with:") :]
                    declared = {
                        tag for r in documents.get("region", []) for tag in r.get("tags", [])
                    }
                    if wanted not in declared:
                        report.fail(where, f"no Region declares the tag '{wanted}'")
                    continue
                if token.startswith("$") and token[1:] not in KNOWN_BINDINGS:
                    report.fail(
                        where,
                        f"'{token}' is not a binding the engine can resolve "
                        f"(known: {', '.join(sorted(KNOWN_BINDINGS))})",
                    )
            return
        if isinstance(value, dict):
            for item in value.values():
                walk(item, where)
        elif isinstance(value, list):
            for item in value:
                walk(item, where)

    for consequence in documents.get("consequence", []):
        walk(consequence.get("effects", []), f"{origins['consequence']} [{consequence['id']}]")
    for template in documents.get("confluence_template", []):
        where = f"{origins['confluence_template']} [{template['id']}]"
        for clause in template.get("condition_clauses", []):
            walk(clause.get("effects", []), where)


def _check_condition(
    condition: Dict[str, Any],
    entities: Set[str],
    regions: Set[str],
    tensions: Set[str],
    report: Report,
    where: str,
) -> None:
    if condition.get("type") == "any_of":
        for sub in condition.get("conditions", []):
            _check_condition(sub, entities, regions, tensions, report, where)
        return
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
