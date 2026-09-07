#!/usr/bin/env python3
"""La carta a due domande (D-467, giro 2): una volta, con una regola scritta.

    python3 tools/two_questions.py            # mostra cosa cambierebbe, carta per carta
    python3 tools/two_questions.py --apply    # riscrive i due file delle Tensioni

Parola del committente: *«due domande in contrasto, ognuna con i suoi costi e i
suoi benefici, e poi sempre le conseguenze»*. Le 60 carte avevano gia' due
domande, tre proposte con le loro Conseguenze, e quattro caselle per lato.
Questo strumento le porta alla forma di D-467 una volta sola, e da qui in poi
la guardia sta in `validate_physical.py`.

La regola, per ogni carta:

- **l'esito di base** di una domanda (`base`) sono le Conseguenze della sua
  prima proposta d'autore — quella che la risponde dritta. Le altre proposte
  restano scritte e le esegue ancora il motore fino al giro 3; il catalogo
  dice quali;
- **sei verbi per lato**: ai quattro benefici si aggiungono RIAPRI e RIMUOVI
  CONDIZIONE, ai quattro costi PEDAGGIO e SCALDA TEMA — i sei e sei del
  vocabolario di D-280 — con un testo a formula, perche' non chiedono
  parametri;
- **ogni casella dice a quale domanda serve** (`for`). Prima passata a regola,
  per verbo, con la domanda A come risposta dritta e la B come
  controdomanda: costruire, prendere il controllo, una condizione e una
  Cicatrice stanno con A; riaprire, ripulire, cedere, indebitarsi e il
  pedaggio con B; raffreddare, ricordare e scaldare con tutte e due.
  E' una regola e non una lettura carta per carta: il catalogo dei Consigli
  mostra le marche, e il committente le corregge dove la carta dice altro.
"""
from __future__ import annotations
import json, sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
FILES = [ROOT / "godot/data/tensions/tensions_core.json", ROOT / "godot/data/tensions/tensions_library.json"]

NEW_BENEFITS = [
    {"id": "B_REOPEN", "verb": "REOPEN", "text": "Riapri il luogo: via il #tagliato_fuori."},
    {"id": "B_CLEAR", "verb": "CLEAR_CONDITION", "text": "Togli una condizione dal luogo."},
]
NEW_COSTS = [
    {"id": "C_TOLL", "verb": "TOLL", "text": "Sul luogo si alza un pedaggio."},
    {"id": "C_HEAT", "verb": "HEAT_THEME", "text": "Il Tema di questa domanda si scalda di 1."},
]
# per verbo: "A", "B" o "AB"
SIDE = {
    "BUILD_STONE": "A", "TAKE_CONTROL": "A", "COOL_THEME": "AB", "REMEMBER": "AB",
    "REOPEN": "B", "CLEAR_CONDITION": "B",
    "ADD_CONDITION": "A", "SCAR": "A", "BIND_HOUSES": "A", "MARK_HOUSE": "A",
    "YIELD_CONTROL": "B", "TAKE_DEBT": "B", "TOLL": "B", "HEAT_THEME": "AB",
}


def rework(card: dict, report: list) -> None:
    council = card["council"]
    questions = council["questions"]
    ids = [q["id"] for q in questions]
    if len(ids) != 2:
        report.append("%s: %d domande, non due" % (card["id"], len(ids)))
        return
    a, b = ids
    for q in questions:
        first = next((p for p in council.get("propositions", []) if p["question_id"] == q["id"]), None)
        if first is None:
            report.append("%s: la domanda %s non ha una proposta da cui prendere l'esito di base" % (card["id"], q["id"]))
            q["base"] = []
        else:
            q["base"] = list(first["success_consequences"])
    ph = card["physical"]
    have_b = {v["verb"] for v in ph["benefits"]}
    have_c = {v["verb"] for v in ph["costs"]}
    used = {v["id"] for k in ("benefits", "costs", "failure") for v in ph[k]}
    for voice in NEW_BENEFITS:
        if voice["verb"] not in have_b:
            if voice["id"] in used:
                report.append("%s: id gia' usato %s" % (card["id"], voice["id"]))
            ph["benefits"].append(dict(voice))
    for voice in NEW_COSTS:
        if voice["verb"] not in have_c:
            if voice["id"] in used:
                report.append("%s: id gia' usato %s" % (card["id"], voice["id"]))
            ph["costs"].append(dict(voice))
    for k in ("benefits", "costs"):
        for v in ph[k]:
            side = SIDE.get(v["verb"])
            if side is None:
                report.append("%s: verbo senza parte %s" % (card["id"], v["verb"]))
                side = "AB"
            v["for"] = [a] if side == "A" else [b] if side == "B" else [a, b]


def main() -> int:
    apply = "--apply" in sys.argv
    report: list = []
    counts = {"cards": 0, "benefits": 0, "costs": 0}
    for path in FILES:
        doc = json.loads(path.read_text(encoding="utf-8"))
        for card in doc["items"]:
            rework(card, report)
            counts["cards"] += 1
            counts["benefits"] += len(card["physical"]["benefits"])
            counts["costs"] += len(card["physical"]["costs"])
        if apply:
            path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("%d carte, %d benefici, %d costi" % (counts["cards"], counts["benefits"], counts["costs"]))
    for line in report:
        print("  ! " + line)
    print("scritto" if apply else "(prova: niente scritto; --apply per scrivere)")
    return 1 if report else 0


if __name__ == "__main__":
    raise SystemExit(main())
