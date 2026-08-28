#!/usr/bin/env python3
"""Il materiale di lettura per la revisione editoriale (ISSUES voce 13).

Genera docs/REVISIONE_TESTI.md: ogni testo d'autore che un giocatore puo'
leggere, in ordine di lettura e con il proprio identificativo, cosi' una
correzione si segna con una riga («P_SHOW_IT: riscrivi cosi'...») e chi la
riceve sa esattamente dove riportarla nei dati.

Come il manifest: non si modifica a mano, si rigenera —

    python3 tools/build_review.py
    python3 tools/build_review.py --check    # esce 1 se il documento e' vecchio

Deterministico: ordine per id dentro ogni sezione, ordine di lettura fra le
sezioni. La revisione e' d'autore; questo file e' solo il tavolo su cui si fa.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "godot" / "data"
OUT = ROOT / "docs" / "REVISIONE_TESTI.md"


# Un documento si cerca per quello che **dice di essere**, non per la cartella
# in cui sta: l'aiutante condiviso e' in `echoes_schema.py`, e la ragione per cui
# esiste l'ha pagata per prima questa funzione (D-328, poi ISSUES 99).
sys.path.insert(0, str(Path(__file__).resolve().parent))
from echoes_schema import items_of as load_all  # noqa: E402


def sorted_by_id(items: list[dict]) -> list[dict]:
    return sorted(items, key=lambda item: str(item.get("id", "")))


def quote(text: str) -> str:
    return f"> {text.strip()}" if text and text.strip() else "> *(vuoto)*"


class Review:
    def __init__(self) -> None:
        self.lines: list[str] = []
        self.count = 0

    def line(self, text: str = "") -> None:
        self.lines.append(text)

    def entry(self, identifier: str, *texts: str) -> None:
        self.line(f"**`{identifier}`**")
        for text in texts:
            if text is None or not str(text).strip():
                continue
            self.line(quote(str(text)))
            self.line()
            self.count += 1
        self.line()


def main() -> int:
    review = Review()
    out = review.lines

    chronicles = sorted_by_id(load_all("chronicle"))
    regions = sorted_by_id(load_all("region"))
    entities = sorted_by_id(load_all("entity"))
    tensions = sorted_by_id(load_all("tension"))
    templates = sorted_by_id(load_all("confluence_template"))
    consequences = sorted_by_id(load_all("consequence"))
    echoes = sorted_by_id(load_all("echo_card"))
    assets = sorted_by_id(load_all("asset"))
    destinies = sorted_by_id(load_all("destiny"))
    actions = sorted_by_id(load_all("action"))

    review.line("# ECHOES — I testi, per la revisione")
    review.line()
    review.line("<!-- GENERATO da `python3 tools/build_review.py` — non si corregge qui: -->")
    review.line("<!-- si segnala la correzione, si riporta nei dati, si rigenera. -->")
    review.line()
    review.line("Ogni testo che un giocatore può leggere, nell'ordine in cui lo incontra,")
    review.line("con il suo identificativo. Per correggere basta una riga, anche a voce:")
    review.line("«`P_SHOW_IT`: riscrivi così…» — al resto pensa il motore. I segnaposto")
    review.line("(`$the_region`, `$proponent`…) sono gli slot che il mondo riempie: si")
    review.line("possono spostare nella frase, non togliere.")
    review.line()

    review.line("## 1. Le aperture — lette ad alta voce all'inizio dell'anno")
    review.line()
    for chronicle in chronicles:
        review.entry(chronicle["id"], chronicle.get("title"), chronicle.get("opening_text"))

    review.line("## 2. Le Regioni — la mappa")
    review.line()
    for region in regions:
        review.entry(region["id"], region.get("name"), region.get("description"))

    review.line("## 3. Le Casate — chi siede al tavolo")
    review.line()
    for entity in entities:
        review.entry(
            entity["id"], entity.get("name"), entity.get("description"),
            entity.get("private_information"),
        )
        # Le vite del seggio (D-108/D-110): la prima rispecchia la casa,
        # le successive sono testi nuovi da rivedere.
        for life in entity.get("incarnations", [])[1:]:
            review.entry(life["id"], life.get("name"), life.get("description"))
            for successor in life.get("successors", []):
                review.entry(
                    "%s, erede" % life["id"], successor.get("name"),
                    successor.get("description"),
                )
        for successor in entity.get("successors", []):
            review.entry(
                "%s, erede" % entity["id"], successor.get("name"),
                successor.get("description"),
            )

    review.line("## 4. Le Domande — le Tensioni e i loro presagi")
    review.line()
    for tension in tensions:
        review.entry(tension["id"], tension.get("title"), tension.get("description"))
        for omen in tension.get("omen_thresholds", []):
            review.entry(
                "%s, presagio al %d" % (tension["id"], int(omen.get("at", 0))),
                omen.get("message"),
            )

    review.line("## 5. I Consigli — domande ai voti e proposte")
    review.line()
    review.line("*(La proposta è la frase votata; sotto, come l'esito viene raccontato.)*")
    review.line()
    for template in templates:
        for question in template.get("questions", []):
            review.entry(str(question["id"]), question.get("text"))
        for proposition in template.get("propositions", []):
            review.entry(str(proposition["id"]), proposition.get("text"))
            if proposition.get("echo_summary"):
                review.entry(
                    "%s, esito" % proposition["id"], proposition["echo_summary"]
                )
            for outcome, text in sorted(proposition.get("echo_summaries", {}).items()):
                review.entry("%s, esito %s" % (proposition["id"], outcome), text)

    review.line("## 6. Le Conseguenze — quello che una decisione lascia")
    review.line()
    for consequence in consequences:
        review.entry(
            consequence["id"], consequence.get("title"), consequence.get("description")
        )
        scar = consequence.get("scar")
        if scar and scar.get("description"):
            review.entry("%s, cicatrice" % consequence["id"], scar["description"])

    review.line("## 7. Le carte Echo — il mondo risponde")
    review.line()
    for card in echoes:
        review.entry(card["id"], card.get("title"), card.get("description"))

    review.line("## 8. Le carte Asset — quello che si tiene in mano")
    review.line()
    for asset in assets:
        review.entry(asset["id"], asset.get("title"), asset.get("rules_text"))

    review.line("## 9. I Destini — le ambizioni, gradino per gradino")
    review.line()
    for destiny in destinies:
        review.entry(destiny["id"], destiny.get("title"), destiny.get("description"))
        for level in ("minimum", "victory", "triumph"):
            block = destiny.get(level)
            if not block:
                continue
            clauses = " · ".join(
                str(condition.get("label", "")) for condition in block.get("conditions", [])
                if condition.get("label")
            )
            review.entry(
                "%s, %s" % (destiny["id"], level),
                block.get("label"),
                clauses if clauses else None,
            )

    review.line("## 10. Le Azioni — la plancia, stampata una volta")
    review.line()
    for action in actions:
        review.entry(
            action["id"], action.get("title"), action.get("description"),
            action.get("rules_text"),
        )

    body = "\n".join(out)
    header_note = "%d testi in lettura.\n" % review.count
    body = body.replace(
        "possono spostare nella frase, non togliere.\n",
        "possono spostare nella frase, non togliere. " + header_note,
        1,
    )
    testo = body.rstrip() + "\n"

    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text(encoding="utf-8") != testo:
            print("FAIL  docs/REVISIONE_TESTI.md non e' piu' quello che i dati dicono:")
            print("      rilancia `python3 tools/build_review.py`.")
            return 1
        print("OK  i testi in lettura sono quelli dei dati (%d)." % review.count)
        return 0

    OUT.write_text(testo)
    print("wrote %s  (%d testi)" % (OUT.relative_to(ROOT), review.count))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
