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

E la **spina dorsale del foglio** (0.1.396, domanda del committente — *«perche'
non e' aggiornato?»*). Del foglio era generato **solo il blocco del conto**: il
numero nel titolo rosso, i numeri della tabella dei colori, il ✔ su una voce
chiusa e i due paragrafi che li ripetono a parole li scriveva una mano, e una
mano li dimentica. Quattro rattoppi in un giorno solo, e uno l'ha visto il
committente. Adesso di questo foglio si scrive a mano **solo la domanda e la
raccomandazione**: ogni numero che si puo' contare, lo conta questo strumento.
"""
from __future__ import annotations

import argparse
import difflib
import re
import sys
import textwrap
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ISSUES = ROOT / "docs" / "ISSUES.md"
SHEET = ROOT / "docs" / "LE_TUE_DECISIONI.md"

START = "<!-- CONTO: inizio - generato da tools/issues_survey.py -->"
END = "<!-- CONTO: fine -->"
COLORI_START = "<!-- COLORI: inizio - generato da tools/issues_survey.py -->"
COLORI_END = "<!-- COLORI: fine -->"
RIGA_START = "<!-- IN UNA RIGA: inizio - generato da tools/issues_survey.py -->"
RIGA_END = "<!-- IN UNA RIGA: fine -->"

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

# I cinque colori del foglio, nell'ordine in cui ci stanno.
COLORI = ["🔴", "🔵", "🟡", "⚫", "⚪"]
# Cosa dice la tabella dei colori di ognuno: chi la puo' muovere.
CHI_LA_MUOVE = {
    "🔵": "**una persona che gioca**. Non si misurano: si verificano giocando",
    "🟡": "**io**, da sola, senza aspettare niente",
    "⚫": "io, ma **dopo** una rossa: si chiudono con lei",
    "⚪": "nessuno, per adesso: sono fuori dalla lista finch\u00e9 non giochi",
}
# Le due meta' della sezione rossa: la strada e quello che le sta accanto.
STRADA = "stanno fra oggi"
FUORI_STRADA = "non stanno sulla strada"

# Una voce e' *ospitata* da una sezione se il suo numero sta in un titolo di
# riga (`### R7. [128](...)`) o nella prima casella di una riga di tabella
# (`| [82](...) | ... |`). Nominarla nel racconto non conta: il racconto rimanda,
# la casa e' una sola.
ANCORA = re.compile(r"ISSUES\.md#(\d+)\)")

PAROLE = [
    "nessuna", "una", "due", "tre", "quattro", "cinque", "sei", "sette", "otto",
    "nove", "dieci", "undici", "dodici", "tredici", "quattordici", "quindici",
    "sedici", "diciassette", "diciotto", "diciannove", "venti", "ventuno",
    "ventidue", "ventitré", "ventiquattro", "venticinque", "ventisei",
    "ventisette", "ventotto", "ventinove", "trenta", "trentuno", "trentadue",
    "trentatré", "trentaquattro", "trentacinque", "trentasei", "trentasette",
    "trentotto", "trentanove", "quaranta",
]
# Il numero di un titolo si marca **in grassetto**, e lo strumento cambia quello
# e nient'altro. Cercare «il primo numero a parole» non funzionava: «Le dieci che
# stanno fra oggi e **una** partita» ne ha due, e il secondo non e' un conto.
# «uno» non serve a contare voci — sono femminili — ma va riconosciuto lo stesso
# se qualcuno l'ha scritto a mano.
PAROLA = re.compile(
    r"\*\*(%s)\*\*" % "|".join(sorted(PAROLE + ["uno", "zero"], key=len, reverse=True)),
    re.I,
)


def parola(n: int) -> str:
    """Il numero a parole, al femminile: le voci sono voci."""
    return PAROLE[n] if 0 <= n < len(PAROLE) else str(n)


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


def _hosted(block: str) -> list[int]:
    """I numeri che questo pezzo di foglio **ospita**: quelli nei titoli di riga
    e nella prima casella delle righe di tabella. Il resto e' racconto."""
    out: list[int] = []
    for line in block.splitlines():
        if line.startswith("### "):
            out += [int(n) for n in ANCORA.findall(line)]
        elif line.startswith("| ["):
            out += [int(n) for n in ANCORA.findall(line.split("|")[1])]
    return out


class Sezione:
    """Una sezione a colore del foglio, con dentro le voci che ospita."""

    def __init__(self, colore: str, titolo: str, corpo: str) -> None:
        self.colore = colore
        self.titolo = titolo
        self.corpo = corpo
        grezzo = _hosted(corpo)
        # Una voce ospitata due volte nella stessa sezione va contata una volta —
        # e va detto, perche' e' quasi sempre una tabella di riepilogo che si e'
        # messa a fare la casa di qualcuno.
        self.doppie = sorted({n for n in grezzo if grezzo.count(n) > 1})
        self.ospita = list(dict.fromkeys(grezzo))

    def sotto(self, pezzo: str) -> list[int]:
        """Le voci ospitate dalla sottosezione il cui titolo contiene `pezzo`."""
        parti = re.split(r"^(## .*)$", self.corpo, flags=re.M)
        for i in range(1, len(parti), 2):
            if pezzo in parti[i]:
                return _hosted(parti[i + 1])
        return []


def sezioni(sheet: str) -> dict[str, Sezione]:
    parti = re.split(r"^(# .*)$", sheet, flags=re.M)
    out: dict[str, Sezione] = {}
    for i in range(1, len(parti), 2):
        for colore in COLORI:
            if parti[i].startswith("# " + colore):
                out[colore] = Sezione(colore, parti[i], parti[i + 1])
    return out


def aperte_num(voices: list[Voice]) -> set[int]:
    """I numeri che, oggi, vogliono dire una voce aperta.

    Quattro numeri sono usati due volte in due milestone diverse — l'1, il 2, il
    3 e il 4 — e un rimando `ISSUES.md#4` non sa dire quale delle due intende.
    Lo decide il senso della lista: **la lista nomina cose da fare**, quindi un
    numero ambiguo vuol dire quella aperta. Contarlo al contrario faceva sparire
    una voce vera dal conto, ed e' successo appena questo strumento e' nato."""
    return {v.number for v in voices if not v.closed}


def conti(voices: list[Voice], sheet: str) -> dict[str, int]:
    """I numeri della spina dorsale, contati una volta sola e usati dappertutto."""
    aperte = [v for v in voices if not v.closed]
    vive = aperte_num(voices)
    sez = sezioni(sheet)
    out = {
        "aperte": len(aperte),
        "rosse-etichetta": sum(1 for v in aperte if v.wants_a_decision),
    }
    for colore in COLORI:
        s = sez.get(colore)
        out[colore] = 0 if s is None else len([n for n in s.ospita if n in vive])
    rossa = sez.get("🔴")
    if rossa is not None:
        out[STRADA] = len([n for n in rossa.sotto(STRADA) if n in vive])
        out[FUORI_STRADA] = len([n for n in rossa.sotto(FUORI_STRADA) if n in vive])
    return out


def complaints(voices: list[Voice], sheet: str = "") -> list[str]:
    """Le guardie.

    La prima: una voce dichiarata chiusa deve portare il segno.

    La seconda (0.1.361, parola del committente — *«questo giro deve finire»*):
    **ogni voce aperta deve avere una casa nella lista**, e una sola. Non
    «nominata da qualche parte»: **ospitata** da una sezione a colore, in un
    titolo di riga o in una riga di tabella. Nominare una voce nel racconto di
    un'altra e' un rimando, non una casa — e una voce aperta senza casa e'
    esattamente il modo in cui una lista smette di finire.

    La quarta e la quinta (0.1.397): **il titolo di ogni colore porta il suo
    conto in grassetto** — e' li' che lo strumento lo va a cambiare, e un titolo
    senza grassetto smetterebbe di aggiornarsi in silenzio — e **nessuna voce e'
    ospitata due volte dalla stessa sezione**, che e' il modo in cui una tabella
    di riepilogo si mette a contare come se fosse una casa.

    La terza (0.1.396): **la casa dice il colore giusto**. Una voce col
    cartellino `da-decidere` sta fra le rosse e da nessun'altra parte: se aspetta
    una parola del committente e sta fra le mie, la lista mi da' del lavoro che
    non posso fare, ed e' l'errore che accorcia la lista senza accorciare il
    giro (era il secondo dei cinque di 0.1.382).
    """
    out = []
    for v in voices:
        if v.declared_closed and not v.closed:
            out.append(
                "la voce %d dice di essere chiusa e non ha il ✅ nel titolo: %s"
                % (v.number, v.heading.strip()[:70])
            )
    if not sheet:
        return out

    sez = sezioni(sheet)
    for colore, sezione in sez.items():
        if not PAROLA.search(sezione.titolo):
            out.append(
                "il titolo della sezione %s non porta il suo conto in grassetto: %s"
                % (colore, sezione.titolo.strip()[:70])
            )
        for n in sezione.doppie:
            out.append(
                "la voce %d e' ospitata due volte dalla sezione %s: una tabella di "
                "riepilogo non deve fare la casa di nessuno" % (n, colore)
            )
    casa: dict[int, list[str]] = {}
    for colore, s in sez.items():
        for n in s.ospita:
            casa.setdefault(n, []).append(colore)
    for v in voices:
        if v.closed:
            continue
        dove = casa.get(v.number, [])
        if not dove:
            out.append(
                "la voce %d e' aperta e nessuna sezione della lista la ospita: %s"
                % (v.number, v.heading.strip()[:70])
            )
            continue
        if len(set(dove)) > 1:
            out.append(
                "la voce %d sta in due case insieme (%s): %s"
                % (v.number, " e ".join(sorted(set(dove))), v.heading.strip()[:70])
            )
            continue
        colore = dove[0]
        if v.wants_a_decision and colore != "🔴":
            out.append(
                "la voce %d aspetta una tua parola e la lista la mette fra le %s: %s"
                % (v.number, colore, v.heading.strip()[:70])
            )
        if not v.wants_a_decision and colore == "🔴":
            out.append(
                "la voce %d sta fra le rosse e non ha il cartellino che lo dice: %s"
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


def render_colori(c: dict[str, int], presenti: list[str]) -> str:
    """La tabella dei colori, e il paragrafo che la ripete a parole.

    Non e' una copia del conto qui sopra: il conto dice *quante* voci ci sono,
    questa dice **chi le puo' muovere**, che e' l'unica domanda utile a chi
    legge. I numeri sono gli stessi, e proprio per questo nessuno dei due si
    scrive a mano. Un colore che dal foglio e' sparito — perche' non ospita piu'
    niente — non porta una riga di zeri: sparisce anche di qui."""
    lines = [COLORI_START, ""]
    lines.append("| | quante | chi la muove |")
    lines.append("|---|---|---|")
    if "🔴" in presenti:
        if c["🔴"] == 0:
            lines.append(
                "| 🔴 | **nessuna** | **tu** — e oggi non c'è niente che aspetti una tua parola |"
            )
        else:
            lines.append(
                "| 🔴 | **%d** | **tu**, con una parola. %s stanno sulla strada, %s sono fuori |"
                % (c["🔴"], parola(c[STRADA]).capitalize(), parola(c[FUORI_STRADA]))
            )
    for colore in ["🔵", "🟡", "⚫", "⚪"]:
        if colore in presenti:
            lines.append("| %s | **%d** | %s |" % (colore, c[colore], CHI_LA_MUOVE[colore]))
    lines.append("")
    if c["🟡"]:
        testo = (
            "**%s.** Delle %s voci aperte, %s le posso muovere senza di te — ed e' "
            "il numero che va detto per primo."
            % (parola(c["🟡"]).capitalize(), parola(c["aperte"]), parola(c["🟡"]))
        )
        if c["🔴"] == 0:
            testo += " **Il giro non e' fermo su nessuna tua parola.**"
        else:
            testo += " **Il giro e' fermo su %s parole.**" % parola(c["🔴"])
        lines.append(textwrap.fill(testo.replace("e'", "è"), width=79))
    lines.append("")
    lines.append(COLORI_END)
    return "\n".join(lines)


def render_riga(c: dict[str, int], presenti: list[str]) -> str:
    """La riga sola in fondo. E' il paragrafo che il committente legge se non
    legge altro, ed era quello che invecchiava per primo."""
    pezzi = []
    if "🔵" in presenti and c["🔵"]:
        pezzi.append("%s le verifica una persona che gioca" % parola(c["🔵"]))
    if "⚫" in presenti and c["⚫"]:
        pezzi.append("%s si chiudono dietro una rossa" % parola(c["⚫"]))
    if "⚪" in presenti and c["⚪"]:
        pezzi.append("%s stanno fuori dalla lista" % parola(c["⚪"]))
    coda = (
        "**nessuna aspetta una tua parola**"
        if c["🔴"] == 0
        else "**%s aspettano una tua parola**" % parola(c["🔴"])
    )
    testo = (
        "**Quello che resta da dire in una riga:** delle %s voci aperte ne posso "
        "muovere **%s** da sola. " % (parola(c["aperte"]), parola(c["🟡"]))
    )
    if pezzi:
        pezzi[0] = pezzi[0][:1].upper() + pezzi[0][1:]
    testo += ", ".join(pezzi)
    testo += (", e " if pezzi else "") + coda + "."
    return "\n".join([RIGA_START, "", textwrap.fill(testo, width=79), "", RIGA_END])


def _rinumera(riga: str, n: int) -> str:
    """Cambia il numero **in grassetto** di un titolo, e lascia stare il resto.

    Un titolo di questo foglio porta un numero e una frase: «Aspettano te:
    **nessuna**». La frase la scrive una mano, il numero no — e il grassetto dice
    quale delle parole e' il conto."""
    m = PAROLA.search(riga)
    if not m:
        return riga
    nuova = parola(n)
    if m.group(1)[:1].isupper():
        nuova = nuova.capitalize()
    return riga[: m.start(1)] + nuova + riga[m.end(1) :]


def ritocca(sheet: str, voices: list[Voice], c: dict[str, int]) -> str:
    """La spina dorsale: i numeri nei titoli, e il ✔ sulle voci chiuse.

    Il ✔ si **mette** e non si toglie: una voce puo' essere decisa e restare
    aperta (la parola e' arrivata, il lavoro no), e quel ✔ e' vero. Quello che
    non puo' succedere e' il contrario — una voce che ISSUES dice chiusa e che
    qui sembra ancora in attesa di te."""
    # Un numero e' chiuso solo se **nessuna** voce con quel numero e' aperta
    # (vedi aperte_num): altrimenti il ✔ finirebbe su una voce viva.
    vive = aperte_num(voices)
    chiuse = {v.number for v in voices if v.closed} - vive
    fuori = []
    colore = ""
    for riga in sheet.splitlines():
        if riga.startswith("# "):
            colore = ""
            for k in COLORI:
                if riga.startswith("# " + k):
                    colore = k
                    riga = _rinumera(riga, c[k])
        elif colore == "🔴" and riga.startswith("## "):
            if STRADA in riga:
                riga = _rinumera(riga, c[STRADA])
            elif FUORI_STRADA in riga:
                riga = _rinumera(riga, c[FUORI_STRADA])
        elif colore and riga.startswith("### ") and "✔" not in riga:
            if any(int(n) in chiuse for n in ANCORA.findall(riga)):
                riga = "### ✔ " + riga[4:]
        fuori.append(riga)
    return "\n".join(fuori) + ("\n" if sheet.endswith("\n") else "")


def rigenera(sheet: str, voices: list[Voice]) -> str:
    """Il foglio come lo dicono le voci: la spina dorsale ritoccata e i tre
    blocchi generati. E' una porta sola, cosi' `--check` e la riscrittura non
    possono divergere."""
    c = conti(voices, sheet)
    presenti = [k for k in COLORI if k in sezioni(sheet)]
    out = ritocca(sheet, voices, c)
    out = splice(out, render(voices))
    out = splice(out, render_colori(c, presenti), COLORI_START, COLORI_END)
    return splice(out, render_riga(c, presenti), RIGA_START, RIGA_END)


def splice(sheet: str, block: str, start: str = START, end: str = END) -> str:
    if start in sheet and end in sheet:
        head = sheet[: sheet.index(start)]
        tail = sheet[sheet.index(end) + len(end) :]
        return head + block + tail
    raise SystemExit("i segni %s / %s non sono in %s" % (start, end, SHEET))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    text = ISSUES.read_text(encoding="utf-8")

    if args.self_test:
        voices = read_voices(text)
        sheet_now = SHEET.read_text(encoding="utf-8")

        def piantato(dove: str, prima: str, dopo: str, tutte: bool = False) -> str | None:
            """Pianta un difetto, e si lamenta se non si e' potuto piantare: un
            difetto che non entra fa passare una guardia che non ha morso.

            `tutte` serve a togliere **la casa** di una voce: il suo numero puo'
            essere nominato in piu' punti, e sostituirne uno solo lascia in piedi
            proprio quello che si voleva togliere."""
            guasto = dove.replace(prima, dopo) if tutte else dove.replace(prima, dopo, 1)
            if guasto == dove:
                print("FALLITO: il difetto «%s» non si e' potuto piantare" % prima[:40])
                return None
            return guasto

        # Le condizioni non si cercano fra i dati spediti: si **fabbricano**. Da
        # 0.1.397 non c'e' piu' nessuna voce rossa, e una prova che cercava una
        # rossa vera avrebbe smesso di provare senza dirlo — e' la trappola che
        # in questo progetto ha morso quindici volte.
        cavia = next(v for v in voices if not v.closed and not v.wants_a_decision)
        chiusa = next(v for v in voices if v.closed)
        casa = "[%d](ISSUES.md#%d)" % (cavia.number, cavia.number)

        # 1. Una voce chiusa a cui si toglie il segno di spunta.
        guasto = piantato(text, "### 115. ✅ ", "### 115. ")
        if guasto is None:
            return 1
        if not complaints(read_voices(guasto)):
            print("FALLITO: la guardia non ha visto una voce chiusa senza segno")
            return 1

        # 2. Una voce aperta a cui si toglie la casa.
        guasto = piantato(
            sheet_now, "ISSUES.md#%d)" % cavia.number, "ISSUES.md#zzz)", tutte=True
        )
        if guasto is None:
            return 1
        if not complaints(voices, guasto):
            print("FALLITO: la guardia non ha visto una voce aperta senza casa")
            return 1

        # 3. Una voce che aspetta il committente, ma abita fra le mie: la lista
        #    sembrerebbe piu' corta di quello che e'. Il cartellino si fabbrica.
        rossa_finta = piantato(text, cavia.heading, cavia.heading + "\n\n`da-decidere` ·")
        if rossa_finta is None:
            return 1
        if not any(
            "aspetta una tua parola" in c
            for c in complaints(read_voices(rossa_finta), sheet_now)
        ):
            print("FALLITO: la guardia non ha visto una rossa che abita fra le gialle")
            return 1

        # 4. E il contrario: una voce senza cartellino messa fra le rosse.
        guasto = piantato(sheet_now, casa, "[%d](ISSUES.md#zzz)" % cavia.number, tutte=True)
        if guasto is None:
            return 1
        guasto = piantato(
            guasto, "# 🔴", "# 🔴 **una**\n\n### %s — piantata\n\n#" % casa
        )
        if guasto is None:
            return 1
        if not any("non ha il cartellino" in c for c in complaints(voices, guasto)):
            print("FALLITO: la guardia non ha visto una non-rossa messa fra le rosse")
            return 1

        # 5. Una voce ospitata due volte dalla stessa sezione. La sezione
        #    **si chiede al foglio**, non si scrive qui: la cavia cambia casa
        #    quando una voce cambia colore, e un titolo scritto a mano avrebbe
        #    piantato il difetto nella sezione sbagliata — che e' un'altra
        #    guardia, non questa. E' successo in 0.1.404, quando la 36 e' passata
        #    dalle gialle alle bianche.
        sua_casa = next(
            (z for z in sezioni(sheet_now).values() if cavia.number in z.ospita), None
        )
        if sua_casa is None:
            print("FALLITO: la cavia non ha una casa da raddoppiare")
            return 1
        guasto = piantato(
            sheet_now,
            sua_casa.titolo,
            "%s\n\n### %s — piantata\n" % (sua_casa.titolo, casa),
        )
        if guasto is None:
            return 1
        if not any("ospitata due volte" in c for c in complaints(voices, guasto)):
            print("FALLITO: la guardia non ha visto una voce ospitata due volte")
            return 1

        # 6. Un titolo di colore senza il suo conto in grassetto: smetterebbe di
        #    aggiornarsi in silenzio. Il numero **si legge dal foglio**: scriverlo
        #    a mano qui vorrebbe dire che il giorno che il conto cambia questa
        #    guardia smette di provare — ed e' successo appena il conto e'
        #    passato da quattordici a tredici.
        titolo_giallo = next(
            (r for r in sheet_now.splitlines() if r.startswith("# 🟡")), ""
        )
        segnato = PAROLA.search(titolo_giallo)
        if segnato is None:
            print("FALLITO: il titolo giallo non porta un conto in grassetto da guastare")
            return 1
        in_grassetto: str = segnato.group(0)
        nudo: str = segnato.group(1)
        guasto = piantato(sheet_now, in_grassetto, nudo)
        if guasto is None:
            return 1
        if not any("in grassetto" in c for c in complaints(voices, guasto)):
            print("FALLITO: la guardia non ha visto un titolo senza il conto in grassetto")
            return 1

        # 7. Un numero sbagliato in un titolo: la spina dorsale deve raddrizzarlo.
        guasto = piantato(sheet_now, in_grassetto, "**trenta**")
        if guasto is None:
            return 1
        if rigenera(guasto, voices) != sheet_now:
            print("FALLITO: il numero sbagliato in un titolo non e' stato raddrizzato")
            return 1

        # 8. Il ✔ tolto a una voce che ISSUES dice chiusa. Anche la riga col ✔ si
        #    fabbrica: il foglio vero puo' non averne nessuna.
        #    L'ancora non si nomina: fino a 0.1.413 era «### M1. », e il giorno
        #    che la M1 si e' chiusa col suo ✔ la guardia non ha piu' trovato dove
        #    piantare — la trappola dello strumento che nomina un file per nome.
        #    Si prende il primo titolo di terzo livello dopo la sezione gialla.
        ancora = re.search(
            r"^### .*$", sheet_now[sheet_now.index("# 🟡"):], re.M
        )
        if ancora is None:
            print("FALLITO: nessun titolo sotto la sezione gialla dove piantare il ✔")
            return 1
        con_segno = piantato(
            sheet_now,
            ancora.group(0),
            "### ✔ [%d](ISSUES.md#%d) — piantata\n\n%s" % (chiusa.number, chiusa.number, ancora.group(0)),
        )
        if con_segno is None:
            return 1
        senza_segno = piantato(con_segno, "### ✔ [%d]" % chiusa.number, "### [%d]" % chiusa.number)
        if senza_segno is None:
            return 1
        if rigenera(senza_segno, voices) != rigenera(con_segno, voices):
            print("FALLITO: il ✔ di una voce chiusa non e' stato rimesso")
            return 1

        # E le guardie non devono mordere i dati veri.
        if complaints(voices, sheet_now):
            print("FALLITO: le guardie mordono i dati veri")
            for c in complaints(voices, sheet_now):
                print("   " + c)
            return 1
        print("OK  le otto guardie del foglio delle decisioni mordono")
        return 0

    sheet_now = SHEET.read_text(encoding="utf-8")
    voices = read_voices(text)
    bad = complaints(voices, sheet_now)
    if bad:
        print("ATTENZIONE: docs/ISSUES.md non si puo' contare.")
        for line in bad:
            print("  " + line)
        return 1

    sheet = sheet_now
    wanted = rigenera(sheet, voices)

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
            print("ATTENZIONE: il foglio delle decisioni non e' quello che dicono le voci.")
            print("  python3 tools/issues_survey.py")
            return 1
        print("OK  il conto del foglio e' quello delle voci (%d aperte)" % sum(1 for v in voices if not v.closed))
        return 0

    SHEET.write_text(wanted, encoding="utf-8")
    print("Scritto: %s" % SHEET)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
