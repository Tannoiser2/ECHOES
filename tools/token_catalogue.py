#!/usr/bin/env python3
"""Il catalogo delle pedine: una scheda per segnalino, col suo prompt.

    python3 tools/token_catalogue.py            # riscrive docs/CATALOGO_PEDINE.md
    python3 tools/token_catalogue.py --check    # esce 1 se il documento e' vecchio

Richiesta del committente: *«fai un elenco di tutte le pedine una per una, cosa
sono, cosa dovrebbero rappresentare e il prompt»*.

Tre sorgenti, e nessuna copiata: la **parola italiana** viene da dove la prende
il foglio di stampa (`sign_labels.gd`), il **fatto** (categoria, ambito, chi lo
posa) dal dizionario dei segni, e **cosa ci va disegnato** da
`data/design_matrix/token_icons.json`, che e' l'unica parte scritta a mano. Il
prompt si compone qui col MASTER PROMPT 6 della ART_BIBLE.

Il cancello garantisce la cosa che conta: **ogni segnalino che la fustella
taglia ha la sua scheda**, e nessuna scheda parla di un segnalino che non
esiste.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Dict, List

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "godot" / "data"
LABELS = REPO / "godot" / "scripts" / "core" / "sign_labels.gd"
ICONS = DATA / "token_icons" / "token_icons.json"
ART_BIBLE = REPO / "docs" / "ART_BIBLE.md"
DOC = REPO / "docs" / "CATALOGO_PEDINE.md"

# Default values in case ART_BIBLE is not available
_PROMPT_DEFAULT = (
    "Single monochrome pictogram for a 15 mm cardboard token, ECHOES.\n"
    "Subject: %s.\n"
    "Solid black on bone white, no greys, no gradient, no colour, no text, no frame.\n"
    "Two or three strokes at most, closed silhouette, thick enough to survive at\n"
    "16 px and at a photocopy. Centred, generous margin, no perspective, no scene:\n"
    "one object or one gesture, seen from the side or from straight above.\n"
    "Medieval woodcut sensibility, not modern flat-icon geometry.%s"
)

_BORDO_DEFAULT = {
    "condition:": "\nDashed outline: this is a thing happening, and it can end.",
    "scar:": "\nThe drawing carries a break — one line that splits it. Permanent.",
}


def art_bible_prompts() -> tuple[str, dict]:
    """Legge MASTER PROMPT 6 e le sue varianti da ART_BIBLE.md.

    Returns:
        (prompt, bordo) dove prompt è il MASTER PROMPT 6 e bordo è il dict
        delle varianti di contorno. Se il file non esiste, torna i defaults.
    """
    if not ART_BIBLE.exists():
        return _PROMPT_DEFAULT, _BORDO_DEFAULT

    text = ART_BIBLE.read_text(encoding="utf-8")
    prompt = _PROMPT_DEFAULT
    bordo = _BORDO_DEFAULT.copy()

    # Leggi MASTER PROMPT 6
    if "## MASTER PROMPT 6" in text:
        # Trova il blocco tra ``` dopo MASTER PROMPT 6
        parts = text.split("## MASTER PROMPT 6", 1)
        if len(parts) > 1:
            section = parts[1]
            if "```" in section:
                code_start = section.index("```") + 3
                code_end = section.index("```", code_start)
                prompt = section[code_start:code_end].strip()
                # Converti placeholders markdown a placeholder Python
                prompt = prompt.replace("{soggetto}", "%s")
                prompt = prompt.replace("{variante}", "%s")

    # Leggi le varianti di contorno
    if "### Varianti di contorno" in text:
        parts = text.split("### Varianti di contorno", 1)
        if len(parts) > 1:
            section = parts[1]
            if "```" in section:
                code_start = section.index("```") + 3
                code_end = section.index("```", code_start)
                variants_text = section[code_start:code_end].strip()
                # Parsa le linee come "condition: ..." o "scar: ..."
                for line in variants_text.split("\n"):
                    if ":" in line:
                        key, value = line.split(":", 1)
                        key = key.strip() + ":"
                        value = "\n" + value.strip()
                        bordo[key] = value

    return prompt, bordo


def parole() -> Dict[str, Dict[str, str]]:
    testo = LABELS.read_text(encoding="utf-8")
    out: Dict[str, Dict[str, str]] = {}
    for nome, dove in (("REGION_WORDS", "REGIONI"), ("ENTITY_WORDS", "CASE")):
        blocco = testo.split("const %s: Dictionary = {" % nome, 1)[1].split("\n}", 1)[0]
        for tag, parola in re.findall(r'"([^"]+)":\s*"([^"]*)"', blocco):
            out[tag] = {"parola": parola, "fustella": dove}
    return out


def dizionario() -> Dict[str, dict]:
    out: Dict[str, dict] = {}
    for path in sorted((DATA / "tags").glob("*.json")):
        for voce in json.loads(path.read_text(encoding="utf-8")).get("items", []) or []:
            out[str(voce["id"])] = voce
    return out


def schede() -> List[dict]:
    return json.loads(ICONS.read_text(encoding="utf-8")).get("items", []) or []


def catalogo() -> str:
    prompt, bordo = art_bible_prompts()
    parole_di = parole()
    voci = dizionario()
    carte = {str(s["tag"]): s for s in schede()}

    mancanti = sorted(set(parole_di) - set(carte))
    inventate = sorted(
        t for t in carte if t not in parole_di and not t.startswith("pedina:")
    )

    out: List[str] = []
    add = out.append
    add("# Il catalogo delle pedine")
    add("")
    add("Generato da `tools/token_catalogue.py` — non si scrive a mano.")
    add("")
    add("Una scheda per ogni segnalino che la fustella taglia: **cos'e'** al")
    add("tavolo, **cosa deve rappresentare**, e **il prompt** da mandare a chi")
    add("disegna, composto col MASTER PROMPT 6 di [ART_BIBLE.md](ART_BIBLE.md).")
    add("")
    add("Un segnalino da 15 mm non e' un'illustrazione: sta sulla mappa insieme")
    add("ad altri otto, girato di traverso, sotto una lampada. **Si riconosce")
    add("prima di leggerlo** — la parola italiana stampata sotto e' la conferma,")
    add("non la spiegazione.")
    add("")
    if mancanti:
        add("> **Attenzione: %d segnalini senza scheda.** %s" % (
            len(mancanti), ", ".join("`%s`" % t for t in mancanti)))
        add("")
    if inventate:
        add("> **Attenzione: %d schede che parlano di segnalini che non esistono.** %s" % (
            len(inventate), ", ".join("`%s`" % t for t in inventate)))
        add("")

    for dove, titolo, spiega in (
        ("REGIONI", "I segni che si posano sulla mappa",
         "Si posano su una Regione. Le **condizioni** si stampano in doppia copia"
         " e col contorno tratteggiato, perche' si curano e tornano nella riserva;"
         " le **Cicatrici** in copia singola, perche' la mappa non le dimentica;"
         " Pietre e insediamenti restano finche' qualcuno non li disfa."),
        ("CASE", "I segni che una casa si porta addosso",
         "Si tengono accanto al tarocco della Casata. Dicono chi sei, cosa hai"
         " trovato e cosa hai fatto in una stanza — e certi li scrive il tavolo"
         " su di te, non tu."),
        ("PEDINE", "I pezzi che non sono segni",
         "Non escono dal dizionario: sono i pezzi che contano, si spostano e"
         " camminano sulle corsie."),
    ):
        add("## %s" % titolo)
        add("")
        add(spiega)
        add("")
        elenco = [s for s in schede() if str(s["fustella"]) == dove]
        for scheda in elenco:
            tag = str(scheda["tag"])
            parola = parole_di.get(tag, {}).get("parola", "")
            voce = voci.get(tag, {})
            add("### %s" % (parola or tag.split(":")[-1].replace("_", " ")))
            add("")
            righe = ["`%s`" % tag]
            if voce.get("category"):
                righe.append("categoria **%s**" % str(voce["category"]))
            if voce.get("scope"):
                righe.append("sta su %s" % ", ".join(
                    str(s).lower() for s in voce["scope"]))
            if voce.get("written_by"):
                righe.append("lo posa: %s" % ", ".join(
                    str(w) for w in voce["written_by"]))
            add(" · ".join(righe))
            add("")
            add("**Cosa vuol dire.** %s" % str(scheda["rappresenta"]))
            add("")
            add("**Cosa si vede.** %s" % str(scheda["soggetto"]))
            add("")
            variante = ""
            for prefisso, clausola in bordo.items():
                if tag.startswith(prefisso):
                    variante = clausola
            add("```")
            add(prompt % (str(scheda["soggetto"]), variante))
            add("```")
            add("")
    return "\n".join(out) + "\n"


def main() -> int:
    testo = catalogo()
    if "--check" in sys.argv:
        if not DOC.exists() or DOC.read_text(encoding="utf-8") != testo:
            print("FAIL  docs/CATALOGO_PEDINE.md non e' piu' quello che i dati producono:")
            print("      rilancia `python3 tools/token_catalogue.py`.")
            return 1
        # E il controllo che vale il cancello: nessun segnalino senza scheda.
        if "Attenzione:" in testo:
            print("FAIL  ci sono segnalini senza scheda, o schede senza segnalino.")
            return 1
        print("OK  ogni segnalino ha la sua scheda.")
        return 0
    DOC.write_text(testo, encoding="utf-8")
    print("scritto %s" % DOC.relative_to(REPO))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
