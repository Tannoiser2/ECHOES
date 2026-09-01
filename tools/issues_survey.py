#!/usr/bin/env python3
"""Conta le voci di docs/ISSUES.md, e tiene il conto onesto nel foglio delle decisioni.

    python3 tools/issues_survey.py            # riscrive il blocco del conto
    python3 tools/issues_survey.py --check    # esce 1 se il conto e' vecchio
    python3 tools/issues_survey.py --self-test  # la guardia deve mordere

Perche' esiste (D-391). Il foglio `docs/LE_TUE_DECISIONI.md` serve al committente
per decidere, e portava numeri contati a mano: **66 chiuse, 60 aperte**. Erano
sbagliati, e non per distrazione — tredici voci chiuse non avevano il segno di
spunta nel titolo, quindi nessun conteggio poteva vederle. Un foglio che si
legge per decidere non puo' avere numeri che nessuno rimisura.

La regola, adesso una sola: **una voce chiusa porta il ✅ nel titolo.** Se il
corpo dice «chiusa in 0.1.x» e il titolo non ha il segno, questo strumento va
rosso. E' l'unico modo perche' il conto resti vero senza che qualcuno lo curi.
"""
from __future__ import annotations

import argparse
import difflib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ISSUES = ROOT / "docs" / "ISSUES.md"
SHEET = ROOT / "docs" / "LE_TUE_DECISIONI.md"

START = "<!-- CONTO: inizio - generato da tools/issues_survey.py -->"
END = "<!-- CONTO: fine -->"

HEAD = re.compile(r"^### (\d+)\.(.*)$", re.M)
# «chiusa in 0.1.306», «CHIUSA in 0.1.328». Una chiusura dichiarata porta sempre
# la versione: e' quello che la distingue dalla parola detta di passaggio. E una
# voce **meta'** chiusa non e' chiusa — sono quattro, e restano aperte.
DECLARED_CLOSED = re.compile(r"chius[ao]\s+in\s+0\.1\.\d+", re.I)
HALF = re.compile(r"(?:met[a\u00e0]'?|in parte|quasi)\s*$", re.I)
# la versione a cui una voce si apre e quella a cui si chiude
OPENED_AT = re.compile(r"apert[ao]\s+(?:e chiusa\s+)?in\s+0\.1\.(\d+)", re.I)
CLOSED_AT = re.compile(r"(?:chius[ao]|fatt[ao]|decis[ao])\s+in\s+0\.1\.(\d+)", re.I)
LABELS = re.compile(r"`([a-z\-]+)`")

# Le voci che aspettano una parola del committente si riconoscono da qui.
DECISION_LABELS = {"da-decidere", "decisione", "decisione-del-committente"}


def _says_closed(text: str) -> bool:
    """Vero se il testo dichiara una chiusura intera, non una meta\u2019."""
    for match in DECLARED_CLOSED.finditer(text):
        before = text[max(0, match.start() - 24) : match.start()]
        if not HALF.search(before):
            return True
    return False


class Voice:
    def __init__(self, number: int, heading: str, body: str) -> None:
        self.number = number
        self.heading = heading
        self.body = body
        self.closed = "✅" in heading
        head = body[:600]
        self.labels = set(LABELS.findall(head))
        # La riga dei tag e quello che le sta attaccato: e' li' che una voce
        # dichiara il proprio stato, non nel racconto che viene dopo.
        meta = body.split("\n\n")[0] if body.split("\n\n")[0].strip() else "\n\n".join(body.split("\n\n")[:2])
        self.declared_closed = _says_closed(heading) or _says_closed(meta)
        opened = OPENED_AT.search(head)
        self.opened_at = int(opened.group(1)) if opened else None
        closed = CLOSED_AT.search(head) or CLOSED_AT.search(heading)
        self.closed_at = int(closed.group(1)) if closed else None

    @property
    def wants_a_decision(self) -> bool:
        return not self.closed and bool(self.labels & DECISION_LABELS)


def read_voices(text: str) -> list[Voice]:
    parts = re.split(r"^(### \d+\..*)$", text, flags=re.M)
    voices: list[Voice] = []
    for i in range(1, len(parts), 2):
        heading = parts[i]
        body = parts[i + 1]
        number = int(HEAD.match(heading).group(1))
        voices.append(Voice(number, heading, body))
    return voices


def complaints(voices: list[Voice]) -> list[str]:
    """La guardia: una voce dichiarata chiusa deve portare il segno."""
    out = []
    for v in voices:
        if v.declared_closed and not v.closed:
            out.append(
                "la voce %d dice di essere chiusa e non ha il ✅ nel titolo: %s"
                % (v.number, v.heading.strip()[:70])
            )
    return out


def bands(voices: list[Voice], width: int = 25, first: int = 250) -> list[tuple[str, int, int]]:
    """Il ritmo: quante voci si aprono e quante si chiudono, per fascia di versioni."""
    edges = list(range(first, 400, width))
    rows = []
    for low in edges:
        high = low + width - 1
        opened = sum(1 for v in voices if v.opened_at is not None and low <= v.opened_at <= high)
        closed = sum(1 for v in voices if v.closed and v.closed_at is not None and low <= v.closed_at <= high)
        if opened or closed:
            rows.append(("0.1.%d–0.1.%d" % (low, high), opened, closed))
    return rows


def render(voices: list[Voice]) -> str:
    total = len(voices)
    closed = sum(1 for v in voices if v.closed)
    open_ = total - closed
    decisions = [v for v in voices if v.wants_a_decision]
    numbers = [v.number for v in voices]
    doubled = sorted({n for n in numbers if numbers.count(n) > 1})
    no_version = sum(1 for v in voices if v.opened_at is None)

    lines = [START, ""]
    lines.append("| | |")
    lines.append("|---|---|")
    lines.append("| voci scritte | **%d** |" % total)
    lines.append("| chiuse | **%d** |" % closed)
    lines.append("| aperte | **%d** |" % open_)
    lines.append("| di cui **aspettano una tua decisione** | **%d** |" % len(decisions))
    lines.append("| di cui sono mie da fare | **%d** |" % (open_ - len(decisions)))
    lines.append("")
    lines.append("E il ritmo, voce per voce, per fascia di venticinque versioni:")
    lines.append("")
    lines.append("| versioni | aperte | chiuse |")
    lines.append("|---|---|---|")
    for label, opened, shut in bands(voices):
        lines.append("| %s | %d | %d |" % (label, opened, shut))
    lines.append("")
    notes = []
    if doubled:
        notes.append(
            "i numeri %s sono usati due volte, in due milestone diverse"
            % ", ".join(str(n) for n in doubled)
        )
    if no_version:
        notes.append("%d voci non dicono a che versione si sono aperte" % no_version)
    if notes:
        lines.append("*(Conto generato da `tools/issues_survey.py`: %s.)*" % "; ".join(notes))
        lines.append("")
    lines.append(END)
    return "\n".join(lines)


def splice(sheet: str, block: str) -> str:
    if START in sheet and END in sheet:
        head = sheet[: sheet.index(START)]
        tail = sheet[sheet.index(END) + len(END) :]
        return head + block + tail
    raise SystemExit("i segni %s / %s non sono in %s" % (START, END, SHEET))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    text = ISSUES.read_text(encoding="utf-8")

    if args.self_test:
        # Un difetto piantato apposta: si toglie il segno a una voce chiusa.
        planted = text.replace("### 115. ✅ ", "### 115. ", 1)
        if planted == text:
            print("FALLITO: il difetto non si e' potuto piantare")
            return 1
        if not complaints(read_voices(planted)):
            print("FALLITO: la guardia non ha visto una voce chiusa senza segno")
            return 1
        if complaints(read_voices(text)):
            print("FALLITO: la guardia morde i dati veri")
            return 1
        print("OK  la guardia delle voci morde")
        return 0

    voices = read_voices(text)
    bad = complaints(voices)
    if bad:
        print("ATTENZIONE: docs/ISSUES.md non si puo' contare.")
        for line in bad:
            print("  " + line)
        return 1

    sheet = SHEET.read_text(encoding="utf-8")
    wanted = splice(sheet, render(voices))

    if args.check:
        if sheet != wanted:
            sys.stdout.writelines(
                difflib.unified_diff(
                    sheet.splitlines(True),
                    wanted.splitlines(True),
                    fromfile="docs/LE_TUE_DECISIONI.md",
                    tofile="quello che le voci dicono",
                )
            )
            print("")
            print("ATTENZIONE: il conto del foglio non e' quello di docs/ISSUES.md.")
            print("  python3 tools/issues_survey.py")
            return 1
        print("OK  il conto del foglio e' quello delle voci (%d aperte)" % sum(1 for v in voices if not v.closed))
        return 0

    SHEET.write_text(wanted, encoding="utf-8")
    print("Scritto: %s" % SHEET)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
