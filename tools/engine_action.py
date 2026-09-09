#!/usr/bin/env python3
"""Quale delle due Azioni stampate il motore risolve davvero (D-494).

Le Azioni sulla faccia fisica sono **due**, e il `card_action` della carta ne
esegue **una**. Fino alla 0.1.463 il dato non diceva quale, e la scheda
dell'app stampava al suo posto una terza frase — quella generica del verbo —
che su alcune carte porta un numero diverso da entrambe le Azioni: su
*Credito* «un passo» contro «2 gradini» e «1 gradino».

Questo strumento scrive `engine: true` sull'Azione giusta.

**Su 29 carte su 48 la risposta e' nel dato**: il verbo dichiarato compare su
una sola delle due Azioni, e allora non c'e' niente da scegliere. Le altre
**18** hanno le due Azioni collo stesso verbo — «Sigillare in alto» e
«Sigillare in basso» sono tutte e due INFLUENZARE — e li' la risposta e'
d'autore: sta in `LETTURA`, decisa guardando `card_action.params` (il verso:
`direction` UP/DOWN, `delta` +1/-1) e la frase di `card_action.note`, che e'
il posto dove l'autore ha scritto cosa fa il motore.

**Una carta su 48 non ne ha nessuna** e resta senza: su *Debito Vecchio* il
verbo dichiarato e' RIVENDICARE e le due Azioni stampate dicono INFLUENZARE e
FORGIARE. Non e' un buco da tappare qui: e' la faccia fisica che il motore non
esegue ancora, ed e' scritta in ISSUES 69. La scheda lo dira'.

    python3 tools/engine_action.py --check     controlla e basta
    python3 tools/engine_action.py             scrive nel dato
"""
import argparse
import json
import pathlib
import sys

DATA = pathlib.Path(__file__).resolve().parent.parent / "godot/data/assets/assets_core.json"

# Le 18 carte in cui le due Azioni pronunciano lo stesso verbo, lette una per
# una: il numero e' l'Azione (1 o 2) che il motore risolve, e la ragione e' il
# verso che `card_action` chiede. `None` vuol dire nessuna delle due.
LETTURA = {
    "AST_FORCE_MERCENARIES": (1, "FORGIARE senza verso, e la nota dice legame: si sale"),
    "AST_AUTHORITY_SEAL": (2, "delta +1: alza, e «Sigillare in alto» alza di 1"),
    "AST_AUTHORITY_INVESTITURE": (1, "FORGIARE senza verso, e la nota dice legare: lei sale"),
    "AST_AUTHORITY_INTERDICT": (1, "delta -1: abbassa, e «Proibire» e' l'unica che abbassa"),
    "AST_PEOPLE_CROWD": (1, "delta +1: alza di 1, e la prima alza esattamente di 1"),
    "AST_PEOPLE_MOBILIZATION": (2, "delta +1: la seconda alza di 1, la prima di 2"),
    "AST_PEOPLE_STILL_HANDS": (1, "delta +1: alza, e la seconda abbassa"),
    "AST_KNOWLEDGE_LEDGER": (1, "FORGIARE senza verso, e la nota dice fidarsi: si sale"),
    "AST_KNOWLEDGE_WITNESS": (2, "delta -1: abbassa, e «Farlo tacere» e' l'unica che abbassa"),
    "AST_KNOWLEDGE_RED_CRYSTAL": (2, "TRAMARE, e la nota dice misurare senza toccare"),
    "AST_WEALTH_CREDIT": (2, "direction DOWN: il rapporto scende, e la seconda scende"),
    "AST_WEALTH_GRANARY_KEYS": (2, "direction DOWN: «Tenere le chiavi» e' l'unica che scende"),
    "AST_WEALTH_LAND_MORTGAGE": (1, "direction DOWN: la prima scende, la seconda sale"),
    "AST_BONDS_FAVOR": (2, "delta +1 (il default): alza, e «Fare il favore» alza"),
    "AST_BONDS_OATH": (1, "direction UP: sali di 1, ed e' la prima a farti salire"),
    "AST_BONDS_BETROTHAL": (2, "direction UP di **un** grado: la seconda sale di 1, la prima di 2"),
    "AST_BONDS_HOSTAGE": (1, "delta -1: abbassa, e «Mostrare l'ostaggio» abbassa"),
    "AST_BONDS_BROKEN_PACT": (2, "delta +1: la seconda alza di 1, la prima di 2"),
}

# La carta in cui il verbo dichiarato non e' nessuno dei due stampati.
SENZA = {"AST_BONDS_OLD_DEBT"}


def deciso(card):
    """L'indice (da 0) dell'Azione che il motore risolve, o None."""
    kind = card.get("card_action", {}).get("kind", "")
    actions = card["physical"]["actions"]
    same = [i for i, a in enumerate(actions) if a.get("template", "") == kind]
    if len(same) == 1:
        return same[0]
    if card["id"] in SENZA:
        return None
    if card["id"] in LETTURA:
        return LETTURA[card["id"]][0] - 1
    return "MANCA"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()

    data = json.loads(DATA.read_text(encoding="utf-8"))
    dedotte = lette = nessuna = 0
    guasti = []
    cambiato = False

    for card in data["items"]:
        actions = card["physical"]["actions"]
        want = deciso(card)
        if want == "MANCA":
            guasti.append(
                "%s: due Azioni collo stesso verbo e nessuna riga in LETTURA" % card["id"]
            )
            continue
        kind = card.get("card_action", {}).get("kind", "")
        same = [i for i, a in enumerate(actions) if a.get("template", "") == kind]
        if want is None:
            nessuna += 1
        elif len(same) == 1:
            dedotte += 1
        else:
            lette += 1
        for i, action in enumerate(actions):
            vuole = want is not None and i == want
            ha = bool(action.get("engine", False))
            if vuole == ha:
                continue
            cambiato = True
            if args.check:
                guasti.append(
                    "%s Azione %d: engine dovrebbe essere %s" % (card["id"], i + 1, vuole)
                )
            elif vuole:
                action["engine"] = True
            else:
                action.pop("engine", None)

    print("QUALE AZIONE RISOLVE IL MOTORE")
    print("  dedotte dal verbo (una sola Azione lo porta): %d" % dedotte)
    print("  lette carta per carta (le due lo portano tutte e due): %d" % lette)
    print("  senza nessuna (il motore non esegue nessuna delle due): %d" % nessuna)
    if guasti:
        print()
        for g in guasti:
            print("  ROSSO  %s" % g)
        return 1
    if not args.check and cambiato:
        DATA.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print("\n  scritto in %s" % DATA.name)
    elif not args.check:
        print("\n  gia' a posto.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
