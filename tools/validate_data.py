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
import re
import json
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

from echoes_schema import DATA_DIR, SCHEMA_DIR, iter_data_files, load_schemas, rel

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
    known_structure_types = ids.get("structure_type", set())
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
                _check_condition(
                    condition,
                    known_entities,
                    known_regions,
                    known_tensions,
                    report,
                    f"{where}.{level_name}",
                    known_structure_types,
                )

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
                        for one in _flatten_condition(condition):
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


def _flatten_condition(condition: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Le clausole annidate contano quanto quelle in cima.

    `any_of` e `some_of` sono le due che portano dentro altre condizioni, e un
    controllo che si ferma al primo livello lascia passare proprio le clausole
    scritte per ultime — quelle dentro una scelta.
    """
    if condition.get("type") in ("any_of", "some_of", "all_of"):
        out: List[Dict[str, Any]] = []
        for sub in condition.get("conditions", []):
            out.extend(_flatten_condition(sub))
        return out
    return [condition]


DESTINY_LEVELS = ("minimum", "victory", "triumph")


def _presence_demands(
    condition: Dict[str, Any], optional: bool
) -> List[tuple]:
    """(entita', Regione, gettoni, se e' una strada invece di un obbligo).

    Dentro un `some_of` o un `any_of` la clausola e' **una strada fra le
    altre**: non chiede quei gettoni, li chiede solo a chi prende quella
    strada. La differenza e' tutto il senso del controllo qui sotto.
    """
    out: List[tuple] = []
    kind = condition.get("type")
    if kind == "region_presence" and condition.get("min"):
        out.append((
            condition.get("entity_id", ""),
            condition.get("region_id", ""),
            int(condition["min"]),
            optional,
            condition.get("label", ""),
        ))
    nested = optional or kind in ("any_of", "some_of")
    for sub in condition.get("conditions", []):
        out.extend(_presence_demands(sub, nested))
    return out


def _condition_shape(condition: Dict[str, Any]) -> str:
    """La condizione senza la sua prosa: due clausole con la stessa forma
    chiedono la stessa cosa, comunque siano scritte le etichette."""
    return json.dumps(
        {k: v for k, v in sorted(condition.items()) if k not in ("label", "note")},
        sort_keys=True,
        ensure_ascii=False,
    )


def check_destiny_free_roads(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: Report,
) -> None:
    """Nessun `some_of` puo' contare una strada che un livello sotto ha gia'
    reso vera (D-178).

    L'altra faccia della cumulativita'. Se il Trionfo chiede «tre segni fra
    questi sei» e uno dei sei e' gia' obbligatorio nella Vittoria, allora chi
    arriva al Trionfo lo trova **regalato**: il `min: 3` e' in realta' un
    `min: 2` su cinque, e nessuno l'ha deciso.

    Successo in 0.1.145: rendendo la reliquia obbligatoria nella Vittoria di
    `DST_CENERE_DEEP` si e' acceso da solo un ramo del suo Trionfo, e il
    Destino e' diventato bimodale — 8 Minimi, **1** Vittoria, 7 Trionfi.
    """
    for destiny in documents.get("destiny", []):
        where = f"destiny [{destiny['id']}]"
        granted: Dict[str, str] = {}
        for level in DESTINY_LEVELS:
            block = destiny.get(level) or {}
            # Prima si guardano le scelte di questo livello contro tutto quello
            # che i livelli sotto hanno gia' reso vero...
            for condition in block.get("conditions", []):
                if condition.get("type") not in ("some_of", "any_of"):
                    continue
                roads = condition.get("conditions", [])
                free = [
                    road for road in roads if _condition_shape(road) in granted
                ]
                if not free:
                    continue
                wanted = int(condition.get("min", 1))
                report.fail(
                    where,
                    f"{level} chiede {wanted} strade su {len(roads)}, ma "
                    f"{len(free)} sono gia' vere per il livello "
                    f"'{granted[_condition_shape(free[0])]}': in pratica ne "
                    f"chiede {max(0, wanted - len(free))} su "
                    f"{len(roads) - len(free)} (D-178)",
                )
            # ...poi quello che questo livello rende obbligatorio scende ai
            # livelli sopra, perche' i livelli sono cumulativi.
            for condition in block.get("conditions", []):
                if condition.get("type") in ("some_of", "any_of"):
                    continue
                granted.setdefault(_condition_shape(condition), level)


def check_asset_sources_are_true(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """La riga stampata sulla carta deve dire la verita' sulla mappa.

    `acquisition_rule` e' prosa — finisce sulla carta fisica e nel manifesto —
    ma nomina un fatto che sta nei dati: **da quali Regioni** si pesca quella
    famiglia. Le due cose non erano legate da niente, e il giorno in cui la
    mappa e' stata ridistribuita (D-186) **quaranta carte su quarantotto** hanno
    cominciato a mentire senza che nessun test se ne accorgesse.

    Questa guardia le rilega: se una Regione cambia `asset_sources`, le carte
    che nominano la vecchia sorgente fanno rosso la CI.
    """
    regions = documents.get("region", [])
    assets = documents.get("asset", [])
    if not regions or not assets:
        return
    sources: Dict[str, List[str]] = {}
    for region in regions:
        for family in region.get("asset_sources", []):
            sources.setdefault(str(family), []).append(str(region["name"]))
    for asset in assets:
        family = str(asset.get("family", ""))
        expected = sources.get(family, [])
        rule = str(asset.get("acquisition_rule", ""))
        match = re.search(r"Font[ei]: (.+?)\.\s*$", rule)
        where = f"asset [{asset.get('id')}]"
        if not match:
            report.fail(
                where,
                "acquisition_rule non dice da dove si pesca "
                f"(attese: {', '.join(expected) or 'nessuna Regione'})",
            )
            continue
        named = sorted(part.strip() for part in match.group(1).split(","))
        if named != sorted(expected):
            report.fail(
                where,
                f"acquisition_rule dice «{', '.join(named)}» ma {family} "
                f"si pesca da «{', '.join(expected) or 'nessuna Regione'}»",
            )


def check_sim_plans_declare_their_economy(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """Un piano scriptato deve dire in quale economia e' stato scritto.

    Un piano e' una storia scritta a mano: le sue mosse sono azioni dirette, e
    le sue attese sono il risultato di quelle mosse. Il giorno in cui la
    Chronicle e' passata alle carte come unica moneta (D-188) le tre storie di
    CHR_01 sono diventate ingiocabili — e la suite ha detto **verde**, perche' i
    test forzano il lato classico, mentre `tools/run_sims.sh` ha detto rosso in
    CI. Questa guardia chiude quella distanza: se la Chronicle gioca con le
    carte, il piano lo deve dichiarare (o accettarlo, e allora le sue mosse
    saranno carte).
    """
    plans = documents.get("sim_plan", [])
    chronicles = {str(c.get("id")): c for c in documents.get("chronicle", [])}
    for plan in plans:
        chronicle = chronicles.get(str(plan.get("chronicle_id", "")))
        if chronicle is None or not chronicle.get("actions_from_cards", False):
            continue
        overrides = plan.get("chronicle_overrides", {})
        if "actions_from_cards" not in overrides:
            report.fail(
                f"sim_plan [{plan.get('id')}]",
                f"la Chronicle {plan.get('chronicle_id')} gioca con le carte, "
                "ma il piano non dichiara `chronicle_overrides.actions_from_cards`: "
                "o lo dichiara false (e' una storia del §10 di prima), o le sue "
                "mosse vanno riscritte come carte",
            )
    # Stessa ragione per la presa di parola (D-191) e per il sacchetto (D-192):
    # una storia scritta in due tempi non si rilegge in un tempo solo, e una
    # scritta con nove gettoni non si rilegge con venti.
    gates = [
        ("claim_rules", lambda c: c.get("claim_rules", {}).get("same_round_when_ready", False),
         "concede la presa di parola in un colpo"),
        ("tension_tokens", lambda c: bool(c.get("tension_tokens", {})),
         "fa pescare il calore ai giocatori"),
        ("objectives", lambda c: bool(c.get("objectives", {})),
         "si vince contando obiettivi invece di salire gradini"),
    ]
    for plan in plans:
        chronicle = chronicles.get(str(plan.get("chronicle_id", "")))
        if chronicle is None:
            continue
        for key, is_on, what in gates:
            if not is_on(chronicle):
                continue
            if key not in plan.get("chronicle_overrides", {}):
                report.fail(
                    f"sim_plan [{plan.get('id')}]",
                    f"la Chronicle {plan.get('chronicle_id')} {what}, ma il piano "
                    f"non dichiara `chronicle_overrides.{key}`",
                )


def check_condition_vocabularies_agree(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """Il vocabolario delle clausole e' scritto due volte: che dica la stessa cosa.

    `ConditionEvaluator` e' uno solo (§14), ma gli schemi sono file
    autoconsistenti: `destiny.schema.json` e `objective.schema.json` portano
    ciascuno la propria copia di `$defs/condition`. Il giorno in cui una delle
    due impara un predicato nuovo e l'altra no, meta' dei dati puo' scrivere una
    clausola che l'altra meta' rifiuta — e il messaggio d'errore parlerebbe di
    schemi, non di gioco. Qui le due copie vengono confrontate e basta.
    """
    import json as _json

    first = SCHEMA_DIR / "destiny.schema.json"
    second = SCHEMA_DIR / "objective.schema.json"
    if not first.exists() or not second.exists():
        return
    a = _json.loads(first.read_text(encoding="utf-8"))["$defs"]["condition"]
    b = _json.loads(second.read_text(encoding="utf-8"))["$defs"]["condition"]
    if a != b:
        report.fail(
            "schema",
            "`$defs/condition` di destiny.schema.json e objective.schema.json "
            "non coincidono piu': il vocabolario delle clausole e' uno solo, "
            "quindi le due copie vanno riallineate",
        )



def check_the_gate_and_the_thresholds_do_not_overlap(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """Col cancello del tavolo il ritocco alle soglie non ha piu' un lavoro.

    `threshold_bonus` esiste perche' il sacchetto scalda il mondo e la soglia
    della singola domanda va alzata (D-192). Col cancello del tavolo (D-203)
    quella soglia **non apre piu' niente**: il Consiglio si apre a gettoni, e la
    domanda e' il mucchio piu' alto. Tenere il ritocco sarebbe un numero che non
    fa nulla e che il prossimo lettore proverebbe a tarare — l'ora peggio spesa
    di tutte.
    """
    for chronicle in documents.get("chronicle", []):
        rules = chronicle.get("tension_tokens", {})
        if not rules:
            continue
        if int(rules.get("table_gate", 0)) > 0 and int(rules.get("threshold_bonus", 0)) != 0:
            report.fail(
                f"chronicle [{chronicle.get('id')}]",
                "dichiara `table_gate` e `threshold_bonus` insieme: col cancello "
                "del tavolo la soglia della singola Tensione non apre piu' nessun "
                "Consiglio, quindi ritoccarla non fa niente",
            )



def check_a_saga_plays_one_game(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """Gli anni di una stessa saga devono giocare allo stesso gioco.

    Una saga e' un primo anno scritto piu' un anno di biblioteca ripetuto
    (D-045), e i due condividono i seggi. Ogni regola nuova e' arrivata
    dichiarandosi sulla Chronicle — le carte, il rubinetto, la presa di parola,
    il sacchetto, gli obiettivi — e ogni volta c'era **una seconda Chronicle** da
    accendere insieme alla prima. Una e' rimasta indietro davvero: CHR_02 e'
    andata avanti per due versioni contando i gradini mentre CHR_01 contava gli
    obiettivi, e il punteggio di campagna sommava due scale diverse **senza
    dirlo**, perche' il livello si deriva e sembra sempre lo stesso.

    Qui le Chronicle vengono appaiate per **lista dei seggi** — gli stessi seggi
    sono la stessa saga — e le regole confrontate. Non serve che i numeri
    coincidano: serve che una regola accesa da una parte non sia spenta
    dall'altra.
    """
    chronicles = documents.get("chronicle", [])
    if len(chronicles) < 2:
        return
    RULES = ["actions_from_cards", "hand_refill", "claim_rules",
             "tension_tokens", "objectives", "veiled_tensions"]
    sagas: Dict[str, List[Dict[str, Any]]] = {}
    for chronicle in chronicles:
        key = "|".join(sorted(str(seat) for seat in chronicle.get("entities", [])))
        sagas.setdefault(key, []).append(chronicle)
    for _key, group in sorted(sagas.items()):
        if len(group) < 2:
            continue
        first = group[0]
        for other in group[1:]:
            for rule in RULES:
                on_here = bool(first.get(rule))
                on_there = bool(other.get(rule))
                if on_here == on_there:
                    continue
                lit, dark = (first, other) if on_here else (other, first)
                report.fail(
                    f"chronicle [{dark.get('id')}]",
                    f"`{rule}` e' acceso in {lit.get('id')} e spento qui, ma i "
                    "due anni hanno gli stessi seggi: una saga che cambia gioco "
                    "a meta' somma due scale diverse senza dirlo",
                )



def check_objective_scales_are_sane(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """Le due scale degli obiettivi devono essere lunghe uguale e salire.

    `levels` e `saga_points` sono indicizzate dal **conto** degli obiettivi
    avverati (D-198), e il conto arriva sempre a `hidden + 1`. Una delle due
    scritta piu' corta non fa errore: il motore la satura sull'ultimo valore, e
    allora due risultati diversi diventano lo stesso risultato **in silenzio** —
    prendere tre obiettivi e prenderli tutti e quattro varrebbero uguale, e
    nessuno se ne accorgerebbe leggendo il verbale.

    E i punti devono salire: un obiettivo in piu' non puo' valere di meno. Una
    scala che scende sarebbe un refuso che paga chi fa peggio, ed e' il genere
    di refuso che si vede solo a fine saga.
    """
    for chronicle in documents.get("chronicle", []):
        rules = chronicle.get("objectives", {})
        if not rules:
            continue
        where = f"chronicle [{chronicle.get('id')}]"
        # Il conto va da zero a «tutti»: uno palese piu' i coperti, e lo zero
        # e' una casella come le altre.
        wanted = int(rules.get("hidden", 0)) + 2
        levels = rules.get("levels", [])
        if len(levels) != wanted:
            report.fail(
                where,
                f"`objectives.levels` ha {len(levels)} voci ma ne servono "
                f"{wanted}: da 0 a {wanted - 1} obiettivi avverati "
                f"(uno palese piu' {rules.get('hidden')} coperti)",
            )
        points = rules.get("saga_points", [])
        if not points:
            continue
        if len(points) != wanted:
            report.fail(
                where,
                f"`objectives.saga_points` ha {len(points)} voci ma ne servono "
                f"{wanted}: due risultati diversi varrebbero uguale",
            )
        for i in range(1, len(points)):
            if int(points[i]) < int(points[i - 1]):
                report.fail(
                    where,
                    f"`objectives.saga_points` scende fra {i - 1} e {i} "
                    f"({points[i - 1]} -> {points[i]}): un obiettivo in piu' "
                    "non puo' valere di meno",
                )



def check_objectives_are_shareable(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: "Report",
) -> None:
    """Un obiettivo del pool si pesca a qualunque tavolo, o non e' del pool.

    Il pool nascosto (D-197) e' pescato all'inizio della partita da qualunque
    casa, in qualunque Chronicle. Una clausola che nomina `ENT_ALDRIC`, o
    `REG_EREDAN`, o `TEN_FAMINE` non e' un obiettivo condivisibile: e' un
    Destino travestito, e nel mondo del Sale sarebbe **falso per costruzione** —
    si avvererebbe mai, e nessuno se ne accorgerebbe perche' un obiettivo che
    non si avvera assomiglia a un obiettivo difficile.

    Quindi: dentro un obiettivo, `entity_id` puo' essere solo `$self`, e nessuna
    clausola puo' nominare una Regione o una Tensione. Il vocabolario che resta
    (Regioni contate, pietre, cicatrici, segni, mano, scoperte) e' quello che
    D-197 ha misurato.
    """
    objectives = documents.get("objective", [])
    if not objectives:
        return

    def walk(condition: Dict[str, Any], where: str) -> None:
        entity_id = condition.get("entity_id")
        if entity_id is not None and str(entity_id) != "$self":
            report.fail(
                where,
                f"la clausola nomina «{entity_id}»: un obiettivo del pool "
                "si risolve su chi lo pesca, quindi `entity_id` puo' essere "
                "solo `$self`",
            )
        for key in ("region_id", "tension_id", "other_entity_id"):
            if key in condition:
                report.fail(
                    where,
                    f"la clausola nomina `{key}` = «{condition[key]}»: un "
                    "obiettivo del pool deve valere in ogni Chronicle, e quel "
                    "nome esiste solo in una",
                )
        for sub in condition.get("conditions", []):
            walk(sub, where)

    for objective in objectives:
        where = f"objective [{objective.get('id')}]"
        for condition in objective.get("conditions", []):
            walk(condition, where)



def check_destiny_token_budget(
    documents: Dict[str, List[Dict[str, Any]]],
    origins: Dict[str, str],
    report: Report,
) -> None:
    """Nessun Destino puo' chiedere piu' gettoni di quanti ne esistano (D-177).

    I livelli sono **cumulativi** (`destiny_evaluator.gd`: il Trionfo pretende
    anche la Vittoria e il Minimo), quindi le presenze richieste da tutti i
    livelli fino a quello si sommano per entita' e vanno confrontate col tetto
    della Chronicle.

    Due esiti diversi, e il secondo e' quello che e' costato una versione:

    * gli **obblighi** superano il tetto: il livello e' irraggiungibile, punto.
    * gli obblighi ci stanno, ma una **strada** dentro un `some_of` li porta
      oltre: la strada non e' impossibile — le Conseguenze aggiungono presenze
      senza passare dal tetto del MOVE — ma percorrerla **spegne una clausola
      di un livello sotto**, e chi la insegue perde il gradino che la regge.
      E' il difetto di `DST_CENERE_DEEP` in 0.1.144: tredici NONE su 120 anni,
      tutti di quella casa, che le sonde hanno impiegato una sessione a
      trovare e che questo conto vede senza giocare una partita.
    """
    caps = [
        int(chronicle["presence_tokens"])
        for chronicle in documents.get("chronicle", [])
        if chronicle.get("presence_tokens")
    ]
    if not caps:
        return
    # I Destini condivisibili (`$self`) vivono in piu' Chronicle: il tetto che
    # conta e' il piu' stretto in cui possono finire.
    cap = min(caps)

    for destiny in documents.get("destiny", []):
        # Senza il percorso di proposito: `origins` tiene il **primo** file di
        # ogni schema_id, e i Destini stanno in tre file. Un id e' univoco su
        # tutto il data set (la guardia sui duplicati lo pretende) e si trova
        # con un grep; un percorso sbagliato manderebbe a cercare altrove.
        where = f"destiny [{destiny['id']}]"
        demands: List[tuple] = []
        for index, level in enumerate(DESTINY_LEVELS):
            for condition in (destiny.get(level) or {}).get("conditions", []):
                for row in _presence_demands(condition, False):
                    demands.append((index,) + row)
        if not demands:
            continue
        for top in range(len(DESTINY_LEVELS)):
            required: Dict[str, Dict[str, int]] = defaultdict(dict)
            roads: Dict[str, Dict[str, int]] = defaultdict(dict)
            for index, entity, region, need, optional, _label in demands:
                if index > top:
                    continue
                bucket = roads if optional else required
                bucket[entity][region] = max(bucket[entity].get(region, 0), need)
            for entity in set(list(required) + list(roads)):
                owed = sum(required[entity].values())
                # La strada piu' cara, al netto di quello che l'entita' deve
                # gia' tenere in quella stessa Regione.
                widest = 0
                for region, need in roads[entity].items():
                    widest = max(widest, max(0, need - required[entity].get(region, 0)))
                level_name = DESTINY_LEVELS[top]
                if owed > cap:
                    report.fail(
                        where,
                        f"{level_name} chiede {owed} gettoni a '{entity}' e il tetto "
                        f"e' {cap}: il livello non si puo' raggiungere",
                    )
                elif owed + widest > cap:
                    report.fail(
                        where,
                        f"{level_name} obbliga '{entity}' a {owed} gettoni e offre una "
                        f"strada che ne vuole {widest} in piu', col tetto a {cap}: "
                        f"percorrerla spegne una clausola di un livello sotto (D-177)",
                    )


def self_test_token_budget() -> int:
    """La guardia dei gettoni con un difetto piantato apposta (D-144, D-177).

    Una guardia che non e' mai stata vista mordere non e' una guardia. Qui il
    caso e' quello vero, ridotto all'osso: `DST_CENERE_DEEP` com'era in
    0.1.144 — due gettoni obbligatori in una Regione, e una strada che ne
    vuole due in un'altra, con un tetto di tre.
    """
    chronicles = [{"id": "CHR_TEST", "presence_tokens": 3}]
    healthy = {
        "id": "DST_SANO",
        "minimum": {"conditions": [
            {"type": "region_presence", "entity_id": "E", "region_id": "SU", "min": 1},
        ]},
        "victory": {"conditions": [
            {"type": "some_of", "min": 1, "conditions": [
                {"type": "region_presence", "entity_id": "E", "region_id": "GIU", "min": 2},
                {"type": "state_tag_present", "scope": "ENTITY", "entity_id": "E", "tag": "x"},
            ]},
        ]},
        "triumph": {"conditions": []},
    }
    broken = {
        "id": "DST_ROTTO",
        "minimum": {"conditions": [
            {"type": "region_presence", "entity_id": "E", "region_id": "SU", "min": 2},
        ]},
        "victory": {"conditions": [
            {"type": "some_of", "min": 1, "conditions": [
                {"type": "region_presence", "entity_id": "E", "region_id": "GIU", "min": 2},
                {"type": "state_tag_present", "scope": "ENTITY", "entity_id": "E", "tag": "x"},
            ]},
        ]},
        "triumph": {"conditions": []},
    }
    impossible = {
        "id": "DST_MURO",
        "minimum": {"conditions": [
            {"type": "region_presence", "entity_id": "E", "region_id": "SU", "min": 2},
            {"type": "region_presence", "entity_id": "E", "region_id": "GIU", "min": 2},
        ]},
        "victory": {"conditions": []},
        "triumph": {"conditions": []},
    }

    # E la seconda guardia: una strada che un livello sotto ha gia' acceso.
    # E' il caso vero di 0.1.145 — la reliquia obbligatoria nella Vittoria che
    # regalava il primo dei sei rami del Trionfo.
    free_road = {
        "id": "DST_REGALATO",
        "minimum": {"conditions": []},
        "victory": {"conditions": [
            {"type": "state_tag_present", "scope": "ENTITY", "entity_id": "E", "tag": "r",
             "label": "la trovano"},
        ]},
        "triumph": {"conditions": [
            {"type": "some_of", "min": 2, "conditions": [
                {"type": "state_tag_present", "scope": "ENTITY", "entity_id": "E",
                 "tag": "r", "label": "l'hanno trovata"},
                {"type": "scar_count", "max": 2},
                {"type": "structure_count", "entity_id": "E", "min": 1},
            ]},
        ]},
    }

    failures = 0
    for check, destiny, expected, what in (
        (check_destiny_token_budget, healthy, 0,
         "un gettone su e due sotto stanno in tre: nessun errore"),
        (check_destiny_token_budget, broken, 1,
         "due su piu' una strada da due sotto: la guardia deve mordere"),
        (check_destiny_token_budget, impossible, 1,
         "quattro gettoni obbligatori su tre: livello irraggiungibile"),
        (check_destiny_free_roads, healthy, 0,
         "nessuna strada gia' accesa da un livello sotto"),
        (check_destiny_free_roads, free_road, 1,
         "una strada del Trionfo obbligatoria nella Vittoria: e' regalata"),
    ):
        report = Report()
        check({"destiny": [destiny], "chronicle": chronicles}, {}, report)
        ok = (len(report.errors) > 0) == (expected > 0)
        print(f"{'ok  ' if ok else 'FAIL'}  {check.__name__:<28} {destiny['id']:<14} {what}")
        for error in report.errors:
            print(f"        {error}")
        if not ok:
            failures += 1
    if failures:
        sys.stderr.write(f"\n{failures} caso/i non si comporta come deve\n")
        return 1
    print("\nle due guardie mordono dove devono e tacciono dove devono")
    return 0


def _check_condition(
    condition: Dict[str, Any],
    entities: Set[str],
    regions: Set[str],
    tensions: Set[str],
    report: Report,
    where: str,
    structure_types: Set[str] = frozenset(),
) -> None:
    if condition.get("type") in ("any_of", "some_of", "all_of"):
        for sub in condition.get("conditions", []):
            _check_condition(
                sub, entities, regions, tensions, report, where, structure_types
            )
        return
    # Un `structure_type` sbagliato non e' un errore rumoroso: conta zero, e la
    # clausola diventa un muro che nessuno ha deciso di alzare.
    wanted = condition.get("structure_type")
    if wanted and structure_types and wanted not in structure_types:
        report.fail(where, f"condition references unknown structure_type '{wanted}'")
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
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="prova che la guardia dei gettoni morda, su un caso piantato apposta",
    )
    args = parser.parse_args()
    if args.self_test:
        return self_test_token_budget()

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
        check_destiny_token_budget(documents, origins, report)
        check_destiny_free_roads(documents, origins, report)
        check_asset_sources_are_true(documents, origins, report)
        check_sim_plans_declare_their_economy(documents, origins, report)
        check_objectives_are_shareable(documents, origins, report)
        check_condition_vocabularies_agree(documents, origins, report)
        check_objective_scales_are_sane(documents, origins, report)
        check_a_saga_plays_one_game(documents, origins, report)
        check_the_gate_and_the_thresholds_do_not_overlap(documents, origins, report)

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
