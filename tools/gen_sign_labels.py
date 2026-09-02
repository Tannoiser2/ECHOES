#!/usr/bin/env python3
"""Le parole dei segni per l'app, generate dal dizionario (ISSUES 70, punto 1).

    python3 tools/gen_sign_labels.py            # riscrive il blocco generato
    python3 tools/gen_sign_labels.py --check    # esce 1 se e' vecchio

Perche' esiste. `godot/scripts/core/sign_labels.gd` era **l'unico posto dove un
tag diventa una parola** per l'app — e il dizionario dei segni
(`godot/data/tags`) e' **l'unico posto dove un tag diventa una parola** per il
gettone stampato. Due unici posti, cioe' due: un segno nuovo si battezzava due
volte, e su 118 parole ce n'erano **37 diverse**.

E le 37 non erano un errore: quasi tutte sono l'italiano che accorda. Il gettone
stampa «conteso», l'app dice «la Regione e' contesa». Generare il file dal solo
`title` avrebbe rotto le frasi dell'app — il genere di pulizia che peggiora il
gioco per far tornare un conto. Quindi il dizionario adesso dichiara **anche la
forma parlata** (`title_spoken`), e questo strumento monta il file da li'.

**Quali segni hanno una parola**: quelli che hanno un gettone di cartone, cioe'
quelli nominati da `godot/data/token_icons`. Non e' una lista a parte — e'
esattamente il conto dei pezzi che si stampano, e infatti oggi le due liste
combaciano su 117 segni su 117. Le sette voci `pedina:*` sono pezzi del gioco
(presenza, controllo, calore), non segni, e restano fuori.

I dizionari che **non** sono segni — domini, famiglie, Azioni, archetipi,
bisogni — restano scritti a mano nel file: non stanno nel dizionario dei segni,
e generarli vorrebbe dire inventargli una casa.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from echoes_schema import items_of  # noqa: E402

TARGET = ROOT / "godot" / "scripts" / "core" / "sign_labels.gd"

INIZIO = "# --- GENERATO da tools/gen_sign_labels.py — non si corregge qui ---"
FINE = "# --- fine del blocco generato ---"

# Il nome del dizionario per ogni ambito dichiarato, e la riga che lo presenta.
AMBITI = (
    ("REGION", "REGION_WORDS", "I segni che si posano su una Regione."),
    ("ENTITY", "ENTITY_WORDS", "I segni che una casa si porta addosso."),
    ("GLOBAL", "WORLD_WORDS", "Le memorie del mondo, al centro del tavolo."),
)


def parole() -> dict[str, dict[str, str]]:
    dizionario = {str(v["id"]): v for v in items_of("tag")}
    col_gettone = {
        str(i["tag"]) for i in items_of("token_icon")
        if i.get("tag") and str(i["tag"]) in dizionario
    }
    fuori: dict[str, dict[str, str]] = {}
    for ambito, nome, _ in AMBITI:
        dentro: dict[str, str] = {}
        for tag in sorted(col_gettone):
            voce = dizionario[tag]
            if ambito not in [str(s) for s in voce.get("scope", [])]:
                continue
            dentro[tag] = str(voce.get("title_spoken") or voce["title"])
        fuori[nome] = dentro
    return fuori


def blocco() -> str:
    righe = [INIZIO]
    for _, nome, presentazione in AMBITI:
        dentro = parole()[nome]
        righe.append("")
        righe.append("## %s" % presentazione)
        righe.append("const %s: Dictionary = {" % nome)
        for tag, parola in dentro.items():
            righe.append('\t"%s": "%s",' % (tag, parola.replace('"', '\\"')))
        righe.append("}")
    righe.append("")
    righe.append(FINE)
    return "\n".join(righe)


def montato() -> str:
    testo = TARGET.read_text(encoding="utf-8")
    if INIZIO not in testo or FINE not in testo:
        raise SystemExit(
            "i segni %s / %s non sono in %s" % (INIZIO, FINE, TARGET.name)
        )
    testa = testo[: testo.index(INIZIO)]
    coda = testo[testo.index(FINE) + len(FINE) :]
    return testa + blocco() + coda


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    voluto = montato()
    if args.check:
        if TARGET.read_text(encoding="utf-8") != voluto:
            print("FAIL  sign_labels.gd non e' piu' quello che il dizionario dice:")
            print("      gira `python3 tools/gen_sign_labels.py`.")
            return 1
        quante = sum(len(v) for v in parole().values())
        print("OK  le parole dei segni sono quelle del dizionario (%d)." % quante)
        return 0

    TARGET.write_text(voluto, encoding="utf-8")
    quante = sum(len(v) for v in parole().values())
    print("scritto %s — %d parole" % (TARGET.name, quante))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
