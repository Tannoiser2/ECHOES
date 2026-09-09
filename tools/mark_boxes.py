#!/usr/bin/env python3
"""Le marche delle caselle, carta per carta (D-489).

[D-469](../docs/DECISIONS.md#d-469) aveva marcato le caselle **a regola, per
verbo**: costruire e prendere il controllo con la A, riaprire e ripulire con la
B, raffreddare e scaldare con tutt'e due. Era una prima passata, dichiarata
tale, e il costo era che **tutte e 60 le carte portavano le stesse dodici
marche**: la carta non diceva niente di suo.

Questa e' la lettura carta per carta, e la regola che la guida e' una sola:

    **una casella serve la domanda che il tavolo sta rispondendo quando la
    posa.**

Le due domande di una carta sono quasi sempre di specie diversa. La **A** chiede
*chi fa la cosa* — chi nutre, chi scrive la regola, chi riscuote, chi custodisce,
se si costruisce o si chiude. La **B** chiede *e poi* — di chi e' dopo, chi
paga, chi risponde, chi resta fuori, chi si conta. Da li' scendono le case
naturali dei verbi:

- **COSTRUISCI PIETRA** va alla domanda che *istituisce* — un granaio, un
  archivio, una porta di pedaggio, un canale — non a quella che chiede di chi e';
- **CAMBIA CONTROLLO** e **CEDI CONTROLLO** vanno alla domanda che chiede *di chi
  e', a chi torna, chi comanda*;
- **IL MONDO RICORDA** resta di tutt'e due, come il Tema: la memoria e' la
  **storia della carta** ([D-308](../docs/DECISIONS.md#d-308),
  [D-453](../docs/DECISIONS.md#d-453)), quello che il mondo ricorda del fatto
  che quella questione sia stata decisa. Ci ho provato a darla alla domanda che
  la scrive — *«il registro e' aperto»* sta con «si aprono i registri?» e non con
  «in un anno magro si paga lo stesso?» — e la misura ha detto no: divisa, si
  compra la meta' delle volte, e sul banco delle prove la controdomanda smette
  di essere giocata. E' scritto in D-489;
- **RIAPRI** e **RIMUOVI CONDIZIONE** vanno alla domanda che *apre*;
- **AGGIUNGI CONDIZIONE** e **PEDAGGIO** a quella che *sorveglia, raziona,
  chiude, fa pagare il passaggio*;
- **PRENDI DEBITO** alla domanda del *conto*;
- **CICATRICE** alla domanda che, vinta, lascia il torto che quella cicatrice
  nomina;
- **RAFFREDDA** e **SCALDA TEMA** restano di tutt'e due, sempre: il Tema e'
  della **carta**, non della domanda.

**Tre caselle sono della carta e non della domanda** — RAFFREDDA TEMA, SCALDA
TEMA e IL MONDO RICORDA — e le altre nove si leggono.

Girato una volta; da qui in poi la guardia sta in `validate_physical.py`, che
chiede tre caselle per domanda e per lato, e — da D-489 — che ogni domanda ne
abbia almeno una **sua**, perche' due domande con le stesse caselle sono una
domanda sola.

    python3 tools/mark_boxes.py [--check]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
TENSIONI = RADICE / "godot" / "data" / "tensions"

# Le caselle che si leggono, nell'ordine in cui stanno sulla carta. Quelle in
# COMUNI sono della carta e vanno a tutt'e due le domande comunque sia scritta
# la lettura: la marca di B_REMEMBER resta nella tabella per leggibilita' — dice
# a quale domanda quella memoria **risponde** — ma non cambia la casella.
BENEFICI = ["B_STONE", "B_CONTROL", "B_REMEMBER", "B_REOPEN", "B_CLEAR"]
COSTI = ["C_CONDITION", "C_YIELD", ("C_DEBT", "C_BIND", "C_MARK"), "C_SCAR", "C_TOLL"]
COMUNI = {"B_COOL", "B_REMEMBER", "C_HEAT"}

# La lettura. Per ogni carta: le marche dei cinque benefici e dei cinque costi,
# nell'ordine sopra. A = la prima domanda, B = la seconda, X = tutt'e due.
LETTURA = {
    # --- Sopravvivenza ---------------------------------------------------
    "TEN_FAMINE":          ("ABXAB", "ABXBA"),
    "TEN_PLAGUE":          ("AAXAB", "BABBA"),
    "TEN_THIRST":          ("ABXAB", "ABBBX"),
    "TEN_WINTER":          ("AAXAB", "ABBAB"),
    "TEN_MARSH_FEVER":     ("AAXBB", "BBBAA"),
    "TEN_EMPTY_NETS":      ("BBXAA", "ABABB"),
    "TEN_REFUGEES":        ("BAXAB", "AABBB"),
    "TEN_WOLVES":          ("AAXBB", "ABBAA"),
    "TEN_BAD_GRAIN":       ("AAXBB", "ABBBA"),
    "TEN_QUARANTINE":      ("AAXBB", "ABBAA"),
    # --- Terra ------------------------------------------------------------
    "TEN_NAMELESS":        ("ABXAA", "BABAB"),
    "TEN_ENCLOSURE":       ("BBXAA", "ABBBA"),
    "TEN_FALLOW":          ("AAXBB", "ABBAA"),
    "TEN_LANDLESS":        ("ABXBB", "BBABA"),
    "TEN_FLOOD":           ("AAXBB", "AABAB"),
    "TEN_CLEARING":        ("AAXBB", "BABAB"),
    "TEN_BOUNDARY_STONES": ("AAXBB", "BABAB"),
    "TEN_PASTURE":         ("BBXAA", "ABABB"),
    "TEN_SALT_FIELDS":     ("BAXAA", "BBAAA"),
    "TEN_LAND_REGISTER":   ("AAXBB", "ABBBA"),
    # --- Fede -------------------------------------------------------------
    "TEN_RELIC":           ("BBXAA", "BBAAA"),
    "TEN_PILGRIMS":        ("ABXAA", "ABABB"),
    "TEN_HERESY":          ("AAXBB", "BABBA"),
    "TEN_VOWS":            ("BBXAA", "ABABB"),
    "TEN_SILENT_BELLS":    ("BBXAA", "BBABA"),
    "TEN_ISLAND_SHRINE":   ("AAXBB", "AABBA"),
    "TEN_TITHE":           ("BBXAA", "BABAB"),
    "TEN_BURIALS":         ("BBXAA", "ABBAB"),
    "TEN_PROPHECY":        ("ABXBB", "BBBAA"),
    "TEN_SANCTUARY":       ("BBXBA", "ABABB"),
    # --- Potere -----------------------------------------------------------
    "TEN_SUCCESSION":      ("AAXBX", "BAAAB"),
    "TEN_CHARTER":         ("BBXAA", "BBABA"),
    "TEN_REGENCY":         ("ABXAA", "ABABB"),
    "TEN_HOSTAGES":        ("BBXAA", "BABAB"),
    "TEN_LEVY":            ("BAXAB", "BABAA"),
    "TEN_SEALS":           ("AAXBB", "AABBB"),
    "TEN_MARCHES":         ("AAXAB", "ABBBA"),
    "TEN_COUNCIL_SEATS":   ("AAXAB", "BABAB"),
    "TEN_OLD_GUARD":       ("BBXAA", "ABBAB"),
    "TEN_TRIBUTE":         ("ABXBB", "ABABA"),
    # --- Antico -----------------------------------------------------------
    "TEN_AWAKENING":       ("BBXAA", "ABABX"),
    "TEN_ASH":             ("AAXBB", "BABAB"),
    "TEN_ECHOES_BELOW":    ("ABXBB", "ABBAB"),
    "TEN_OLD_CHANNELS":    ("BBXAA", "ABBBA"),
    "TEN_SLEEPERS":        ("ABXAA", "BBAAB"),
    "TEN_ISLAND_SILENCE":  ("BAXAA", "BAABA"),
    "TEN_UNEARTHED":       ("AAXBB", "AABAB"),
    "TEN_OLD_NAMES":       ("AAXBB", "BBAAB"),
    "TEN_WARD_STONES":     ("ABXBB", "ABBBA"),
    "TEN_DEEP_WATER":      ("BAXAA", "ABBAB"),
    # --- Vie --------------------------------------------------------------
    "TEN_ROADS":           ("AAXBB", "AABBA"),
    "TEN_WATER":           ("ABXAA", "BBAAB"),
    "TEN_DEBT":            ("BBXAA", "BBXBA"),
    "TEN_FERRY":           ("AAXBB", "BBAAA"),
    "TEN_BLACK_TOLLS":     ("AAXBB", "BABAA"),
    "TEN_WEIGHTS":         ("BAXAB", "BAAAB"),
    "TEN_COURIERS":        ("AAXAB", "BBABA"),
    "TEN_SILTED_CANALS":   ("ABXAA", "ABAAB"),
    "TEN_GUILD_WAR":       ("AAXAB", "AABBB"),
    "TEN_SMUGGLING":       ("ABXAA", "ABBBA"),
}


def _voce(faccia: dict, lista: str, chiave) -> dict | None:
    nomi = chiave if isinstance(chiave, tuple) else (chiave,)
    for v in faccia.get(lista) or []:
        if str(v.get("id")) in nomi:
            return v
    return None


def _marche(segno: str, ids: list[str]) -> list[str]:
    if segno == "X":
        return ids
    return [ids[0] if segno == "A" else ids[1]]


def marca(carta: dict) -> list[str]:
    """Riscrive i `for` di una carta. Torna i guai trovati."""
    guai: list[str] = []
    chi = str(carta.get("id"))
    if chi not in LETTURA:
        return ["carta senza lettura: %s" % chi]
    domande = [str(q["id"]) for q in (carta.get("council") or {}).get("questions") or []]
    if len(domande) != 2:
        return ["carta con %d domande: %s" % (len(domande), chi)]
    faccia = carta.get("physical") or {}
    for segni, lista, chiavi in (
        (LETTURA[chi][0], "benefits", BENEFICI),
        (LETTURA[chi][1], "costs", COSTI),
    ):
        if len(segni) != len(chiavi):
            guai.append("lettura di lunghezza sbagliata su %s: «%s»" % (chi, segni))
            continue
        for segno, chiave in zip(segni, chiavi):
            voce = _voce(faccia, lista, chiave)
            if voce is None:
                guai.append("casella che la carta non ha: %s %s" % (chi, chiave))
                continue
            voce["for"] = _marche(segno, domande)
        for v in faccia.get(lista) or []:
            if str(v.get("id")) in COMUNI:
                v["for"] = list(domande)
    return guai


def main() -> int:
    controlla = "--check" in sys.argv
    guai: list[str] = []
    mosse = 0
    for percorso in sorted(TENSIONI.glob("*.json")):
        documento = json.loads(percorso.read_text(encoding="utf-8"))
        prima = json.dumps(documento, ensure_ascii=False, sort_keys=True)
        for carta in documento.get("items", []):
            guai.extend(marca(carta))
        dopo = json.dumps(documento, ensure_ascii=False, sort_keys=True)
        if prima != dopo:
            mosse += 1
            if not controlla:
                percorso.write_text(
                    json.dumps(documento, ensure_ascii=False, indent=2) + "\n",
                    encoding="utf-8",
                )
    for guaio in guai:
        print("  %s" % guaio)
    if guai:
        return 1
    if controlla and mosse:
        print("  %d file di Tensioni non portano le marche della lettura" % mosse)
        return 1
    print("marche: %d carte lette, %d file %s" % (
        len(LETTURA), mosse, "da riscrivere" if controlla else "riscritti"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
