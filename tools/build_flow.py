#!/usr/bin/env python3
"""Il flusso del tavolo, disegnato: chi posa un segno, dove finisce, chi lo legge.

    python3 tools/build_flow.py            # riscrive docs/flusso.html
    python3 tools/build_flow.py --check    # esce 1 se il disegno e' vecchio

Non un grafo di vicinanze: un grafo **con un verso**. Ogni arco dice chi fa la
cosa a chi, e dove va a finire — e la pagina lo disegna con le frecce, invece di
elencarlo in una tabella.

Il disegno sta in `tools/flow_template.html` e i dati escono da `godot/data`:
**una sorgente sola**, come il MASTER PROMPT di D-349. Qui non si scrive niente
a mano che sia gia' scritto altrove.

Il cancello garantisce la cosa che conta: **il disegno e' quello che i dati
dicono adesso**. Se qualcuno aggiunge una carta, una regola del segno o una
Pietra e non rilancia lo strumento, la CI va rossa.
"""
import json, glob, re, sys
from pathlib import Path
from collections import Counter, defaultdict

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "godot" / "data"

def load(pat):
    out = []
    for f in sorted(glob.glob(str(DATA / pat))):
        for it in json.load(open(f, encoding="utf-8")).get("items", []) or []:
            out.append(it)
    return out

N, E = {}, []
def node(nid, kind, **kw):
    nid = str(nid)
    if nid not in N: N[nid] = {"id": nid, "k": kind, **{a: b for a, b in kw.items() if b}}
    else: N[nid].update({a: b for a, b in kw.items() if b})
    return N[nid]

# Il verso della lettura e' rovesciato apposta. Un dato dice «questa carta legge
# #granaio»; il tavolo vuole sapere «#granaio chi lo legge, e quelli cosa fanno».
# Girando l'arco, la catena scorre in un verso solo: una carta posa un segno, il
# segno e' letto da una regola, la regola vieta un'azione.
GIRATI = {"legge": "letto_da", "osserva": "osservato_da", "teme": "temuto_da"}

def edge(a, b, kind, why="", dove=""):
    if not a or not b: return
    if kind in GIRATI:
        a, b, kind = b, a, GIRATI[kind]
    E.append({"a": str(a), "b": str(b), "k": kind, "w": why, "d": dove})

# ---------- il vocabolario dei bersagli: "dove li mette" ----------
def dove_finisce(target):
    """La frase che dice dove un effetto va a posarsi, e il segno che legge per trovarlo."""
    if not isinstance(target, dict): return "", None
    kind = str(target.get("kind", ""))
    tid = str(target.get("id", ""))
    if tid.startswith("$region_with:"):
        return "sul luogo che porta #%s" % tid.split(":", 1)[1], tid.split(":", 1)[1]
    if tid.startswith("$entity_with:"):
        return "sulla casa che porta #%s" % tid.split(":", 1)[1], tid.split(":", 1)[1]
    NOMI = {"$region_focus": "sul luogo di cui si discute", "$proponent": "su chi ha proposto",
            "$actor": "su chi gioca", "$rival": "sul rivale", "$target": "sul bersaglio scelto"}
    if tid in NOMI: return NOMI[tid], None
    if tid.startswith("REG_"): return "su %s" % tid, None
    if kind == "world": return "sul mondo", None
    if kind == "entity": return "su una casa", None
    if kind == "region": return "su un luogo", None
    return (kind or "?"), None

# ---------- TAG ----------
for t in load("tags/*.json"):
    node(t["id"], "tag", t=t.get("title", ""), cat=t.get("category", ""),
         posto=t.get("table_place", ""), scope=t.get("scope", []), nota=t.get("note", ""))

# ---------- AZIONI ----------
TPL = {}
for a in load("actions/*.json"):
    node(a["id"], "azione", t=a.get("title", ""), d=a.get("description", ""))
    TPL[str(a.get("template", ""))] = a["id"]

# ---------- LUOGHI ----------
for r in load("regions/*.json"):
    node(r["id"], "luogo", t=r.get("name", ""), d=r.get("description", ""),
         biome=r.get("biome", ""), posti=r.get("presence_slots", 0))
    for tg in r.get("tags", []) or []:
        edge(r["id"], tg, "stampato", "stampato sulla tessera")
    for vicino in r.get("adjacency", []) or []:
        edge(r["id"], vicino, "confina", "si passa di qui")

# ---------- PIETRE ----------
GRADI = {}
for s in load("structures/*.json"):
    node(s["id"], "pietra", t=s.get("name", ""), d=s.get("description", ""))
    tags = []
    for i, g in enumerate(s.get("grades", []) or [], 1):
        if g.get("tag"):
            tags.append(g["tag"])
            edge(s["id"], g["tag"], "porta", "grado %d: %s" % (i, g.get("name", "")))
    GRADI[s["id"]] = tags

# ---------- CASE ----------
for e in load("entities/*.json"):
    node(e["id"], "casa", t=e.get("name", e.get("title", "")), d=e.get("description", ""))
    for tg in (e.get("tags") or []) + (e.get("starting_tags") or []):
        edge(e["id"], tg, "stampato", "sulla scheda della casa")

# ---------- TEMI ----------
for th in load("themes/*.json"):
    node(th["id"], "tema", t=th.get("title", ""), d=th.get("covers", ""))
    for tg in th.get("tags", []) or []:
        edge(th["id"], tg, "raccoglie", "il Tema raccoglie il segno")

# ---------- effetti: il cuore ----------
POSA = {"SET_REGION_TAG", "SET_ENTITY_TAG", "SET_GLOBAL_TAG"}
TOGLIE = {"REMOVE_REGION_TAG", "REMOVE_ENTITY_TAG", "REMOVE_GLOBAL_TAG"}

def effetti(o, src, why):
    if isinstance(o, dict):
        k = o.get("type"); p = o.get("payload") or {}
        dove, letto = dove_finisce(o.get("target"))
        if letto: edge(src, letto, "legge", "per trovare dove posare")
        if k in POSA and p.get("tag"):   edge(src, p["tag"], "posa", why, dove)
        if k in TOGLIE and p.get("tag"): edge(src, p["tag"], "toglie", why, dove)
        if k == "ADD_SCAR" and p.get("tag"):    edge(src, p["tag"], "posa", why + " (Cicatrice)", dove)
        if k in ("BUILD_STRUCTURE", "SET_STRUCTURE_GRADE"):
            st = str(p.get("structure_type", ""))
            if st:
                edge(src, st, "costruisce", why + (" al grado %s" % p["grade"] if p.get("grade") else ""), dove)
                g = p.get("grade")
                scelti = [GRADI.get(st, [])[int(g) - 1]] if (g and 0 < int(g) <= len(GRADI.get(st, []))) else GRADI.get(st, [])
                for tg in dict.fromkeys(scelti): edge(src, tg, "posa", why + " (Pietra %s)" % st, dove)
        if k == "RAZE_STRUCTURE" and p.get("structure_type"):
            edge(src, p["structure_type"], "abbatte", why, dove)
        if k == "ADJUST_TENSION":
            edge(src, str((o.get("target") or {}).get("id", "")), "muove", why)
        for v in o.values(): effetti(v, src, why)
    elif isinstance(o, list):
        for v in o: effetti(v, src, why)

# ---------- CARTE ----------
for a in load("assets/*.json"):
    ph = a.get("physical") or {}
    res = ph.get("resonance") or {}
    node(a["id"], "carta", t=a.get("title", ""), d=a.get("rules_text", ""),
         fam=a.get("family", ""), copie=a.get("deck_copies", 0), forza=a.get("strength", 0))
    ca = a.get("card_action") or {}
    if ca.get("kind") and TPL.get(str(ca["kind"])):
        edge(a["id"], TPL[str(ca["kind"])], "esegue", ca.get("note", "l'azione della carta"))
    effetti(a.get("on_commit_effects"), a["id"], "effetto della carta")
    tgt = ph.get("target") or {}
    for tg in (tgt.get("any_tag") or []) + (tgt.get("all_tag") or []):
        edge(a["id"], tg, "legge", "bersaglio a segni: %s" % (tgt.get("text", "") or "")[:90])
    for act in ph.get("actions", []) or []:
        for tg in act.get("puts_tag", []) or []:
            edge(a["id"], tg, "posa", "Azione «%s»: %s" % (act.get("label", ""), act.get("text", "")[:80]),
                 "sul bersaglio della carta")
        for tg in act.get("removes_tag", []) or []:
            edge(a["id"], tg, "toglie", "Azione «%s»" % act.get("label", ""), "sul bersaglio della carta")
        if act.get("template") and TPL.get(str(act["template"])):
            edge(a["id"], TPL[str(act["template"])], "esegue", "Azione «%s»" % act.get("label", ""))
    if res.get("theme"):
        edge(a["id"], res["theme"], "scalda",
             "Risonanza +%s%s" % (res.get("heat", 0),
                 " (+%s se #%s)" % (res.get("extra_heat"), res.get("if_target_tag")) if res.get("if_target_tag") else ""))
    if res.get("if_target_tag"): edge(a["id"], res["if_target_tag"], "legge", "condizione della Risonanza")
    if res.get("extra_tag"):     edge(a["id"], res["extra_tag"], "posa", "segno extra della Risonanza")
    for th in (ph.get("council_use") or {}).get("bonus_if_theme", []) or []:
        edge(a["id"], th, "guarda_tema", "vale di piu' se il Tema e' caldo")

# ---------- ECHI, CONSEGUENZE, PROPOSTE ----------
for pat, kind, why in (("echoes/*.json", "eco", "effetto dell'Eco"),
                       ("consequences/*.json", "conseguenza", "Conseguenza del Consiglio"),
                       ("confluences/*.json", "proposta", "proposta del Consiglio")):
    for c in load(pat):
        node(c["id"], kind, t=c.get("title", "") or str(c.get("text", ""))[:70],
             d=c.get("description", ""))
        effetti(c, c["id"], why)

# ---------- TENSIONI ----------
for t in load("tensions/*.json"):
    ph = t.get("physical") or {}
    node(t["id"], "tensione", t=t.get("title", ""), dom=t.get("domain", ""))
    for buck, nome in (("benefits", "beneficio"), ("costs", "costo"), ("failure", "fallimento")):
        for it in ph.get(buck, []) or []:
            if it.get("tag"):
                edge(t["id"], it["tag"], "posa", "%s «%s»: %s" % (nome, it.get("verb", ""), it.get("text", "")[:80]),
                     "sul luogo della domanda")
            if it.get("structure"): edge(t["id"], it["structure"], "costruisce", "%s: %s" % (nome, it.get("verb", "")))

# ---------- DESTINI ----------
for d in load("destinies/*.json"):
    ph = d.get("physical") or {}
    node(d["id"], "destino", t=d.get("title", d["id"]), casa=d.get("entity_id", ""))
    for th in ph.get("themes", []) or []: edge(d["id"], th, "guarda_tema", "il Destino guarda il Tema")
    for ob in ph.get("observes", []) or []:
        tg = ob if isinstance(ob, str) else (ob.get("tag") or "")
        if tg: edge(d["id"], tg, "osserva", "clausola sulla faccia del Destino")
    def clausole(o, owner):
        if isinstance(o, dict):
            tg = o.get("tag") or (o.get("params") or {}).get("tag")
            ty = str(o.get("type", ""))
            if tg and isinstance(tg, str):
                edge(owner, tg, "teme" if ty == "state_tag_absent" else "osserva", "clausola: %s" % ty)
            for v in o.values(): clausole(v, owner)
        elif isinstance(o, list):
            for v in o: clausole(v, owner)
    clausole(d, d["id"])

# ---------- REGOLE DEL SEGNO: il pezzo che accende le azioni ----------
VERSO = {"ACTION_GATE": ("vieta", "vieta l'azione"),
         "GATE": ("vieta", "sbarra il passaggio"),
         "ACTION_MODIFIER": ("pesa", "pesa sull'azione"),
         "ACTION_GRANT": ("concede", "concede la variante"),
         "ACTION_DISCOUNT": ("sconta", "l'azione non si paga"),
         "ACTION_GRANT_ON_SET": ("concede", "concede"),
         "ACTION_RIPPLE": ("propaga", "l'azione si propaga")}
for r in load("tag_rules/*.json"):
    node(r["id"], "regola", t=r.get("title", ""), d=r.get("note", ""), tipo=r.get("kind", ""))
    for blocco in [r.get("when") or {}] + list(r.get("when_also", []) or []):
        if blocco.get("tag"):
            edge(r["id"], blocco["tag"], "legge", "si accende quando c'e' il segno")
            k = str(r.get("kind", ""))
            if k in VERSO and r.get("template") and TPL.get(str(r["template"])):
                verso, why = VERSO[k]
                edge(blocco["tag"], TPL[str(r["template"])], verso, "%s: %s" % (r.get("title", ""), why))
    if r.get("tension_id"): edge(r["id"], str(r["tension_id"]), "pesa", "pesa sul Consiglio")
    if r.get("grant"): edge(r["id"], str(r["grant"]), "concede", "concede")


TEMPLATE = REPO / "tools" / "flow_template.html"
PAGINA = REPO / "docs" / "flusso.html"


def disegna() -> str:
    """Il template col grafo dentro. Il template non conosce i dati, i dati non
    conoscono il disegno: si incontrano solo qui."""
    testo = TEMPLATE.read_text(encoding="utf-8")
    if "__FLOW__" not in testo:
        raise SystemExit("il template non ha il posto per i dati (__FLOW__)")
    dati = json.dumps({"nodes": list(N.values()), "edges": E},
                      ensure_ascii=False, separators=(",", ":"), sort_keys=False)
    return testo.replace("__FLOW__", dati)


def main() -> int:
    pagina = disegna()
    if "--check" in sys.argv:
        if not PAGINA.exists() or PAGINA.read_text(encoding="utf-8") != pagina:
            print("FAIL  docs/flusso.html non e' piu' quello che i dati disegnano:")
            print("      rilancia `python3 tools/build_flow.py`.")
            return 1
        print("OK  il flusso disegnato e' quello dei dati: %d pezzi, %d legami."
              % (len(N), len(E)))
        return 0
    cambiato = (not PAGINA.exists()) or PAGINA.read_text(encoding="utf-8") != pagina
    PAGINA.write_text(pagina, encoding="utf-8")
    print("scritto %s — %d pezzi, %d legami, %d KB"
          % (PAGINA.relative_to(REPO), len(N), len(E), len(pagina) // 1024))
    if cambiato:
        # Il file nel repo lo sorveglia il cancello; la copia pubblicata no.
        # Chi guarda il link non ha modo di sapere che sta leggendo il disegno
        # di ieri, percio' lo strumento lo dice ad alta voce invece di lasciarlo
        # scoprire a chi si fida.
        print()
        print("  IL DISEGNO E' CAMBIATO.")
        print("  Il file qui e' aggiornato e il cancello lo tiene tale, ma la copia")
        print("  pubblicata come Artifact NON si aggiorna da sola: chi apre il link")
        print("  vede ancora il disegno di prima finche' non la si ripubblica su")
        print("  quello stesso indirizzo.")
    for k, n in sorted(Counter(x["k"] for x in N.values()).items(), key=lambda x: -x[1]):
        print("   %-12s %3d" % (k, n))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
