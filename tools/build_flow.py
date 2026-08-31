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

def effetti(o, src, why, focus=""):
    """`focus` e' la questione d'autore dell'hook che sta intorno (D-359).

    Dopo la fusione un Eco non nomina piu' la Tensione nel bersaglio: punta a
    `$tension`, che al tavolo risolve alla questione dichiarata se e' aperta e
    altrimenti a una che c'e'. Nel disegno `$tension` non e' niente — sarebbe un
    nodo che nessuno puo' cliccare — quindi la freccia si tira verso la
    questione che la carta **dice** di riguardare, che sta in
    `bindings.focus_tension`. E' la stessa scelta che fa il testo stampato
    sulla carta, per la stessa ragione: un identificativo non si stampa.
    """
    if isinstance(o, dict):
        k = o.get("type"); p = o.get("payload") or {}
        focus = str((o.get("bindings") or {}).get("focus_tension", "")) or focus
        dove, letto = dove_finisce(o.get("target"))
        if letto: edge(src, letto, "legge", "per trovare dove posare")
        if k in POSA and p.get("tag"):   edge(src, p["tag"], "posa", why, dove)
        if k in TOGLIE and p.get("tag"): edge(src, p["tag"], "toglie", why, dove)
        if k == "ADD_SCAR" and p.get("tag"):    edge(src, p["tag"], "posa", why + " (Cicatrice)", dove)
        # Una Cicatrice non e' sempre un Effetto: quindici Conseguenze la posano
        # con un blocco loro, `creates_scar` + `scar`. Cercando solo i tipi di
        # effetto il grafo non ne mostrava **nessuna** — e' lo stesso inciampo
        # che il commento di validate_physical._scava aveva gia' scritto.
        if o.get("creates_scar") and isinstance(o.get("scar"), dict):
            marchio = (o["scar"] or {}).get("tag")
            if marchio:
                dove_scar, _ = dove_finisce({"kind": "region", "id": (o["scar"] or {}).get("region_id", "")})
                edge(src, marchio, "posa", (o["scar"] or {}).get("description", why), dove_scar)
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
            bersaglio = str((o.get("target") or {}).get("id", ""))
            if bersaglio.startswith("$"):
                bersaglio, why = focus, why + " (o la domanda che il tavolo ha aperto)"
            edge(src, bersaglio, "muove", why)
        for v in o.values(): effetti(v, src, why, focus)
    elif isinstance(o, list):
        for v in o: effetti(v, src, why, focus)

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

# **Quali segni accendono un Eco** (D-359). Prima l'eleggibilita' nominava una
# Tensione e non si disegnava: una carta era muta finche' l'anno non pescava la
# domanda giusta, e nel grafo non si vedeva perche'. Adesso l'Eco si accende sui
# segni del mondo, quindi la condizione **e' una lettura** e va disegnata come
# tutte le altre — cosi' scegliendo un segno si vede anche quali Echi risveglia.
for c in load("echoes/*.json"):
    def accende(o, owner):
        if isinstance(o, dict):
            tg = o.get("tag")
            ty = str(o.get("type", ""))
            if tg and isinstance(tg, str):
                edge(owner, tg, "teme" if ty == "state_tag_absent" else "legge",
                     "l'Eco si accende con questo segno: %s" % (o.get("label") or ty))
            if ty == "echo_function_played" and o.get("function"):
                # L'ordine di Propp (D-030, D-358): non un segno sul tavolo ma la
                # pila degli Echi gia' calati, che si guarda scoperta.
                fid = "funzione:%s" % str(o["function"])
                node(fid, "funzione", t=str(o["function"]).lower().replace("_", " "))
                edge(owner, fid, "legge",
                     "prima dev'essere successo qualcosa di questo genere")
            for v in o.values(): accende(v, owner)
        elif isinstance(o, list):
            for v in o: accende(v, owner)
    accende(c.get("eligibility"), c["id"])
    # E chi la riempie, quella pila: calare un Eco mette sul tavolo la sua
    # funzione, scoperta. Senza questa freccia le condizioni di Propp sarebbero
    # letture che nessuno soddisfa mai — vere nei dati, invisibili nel disegno.
    if c.get("function_id"):
        fid = "funzione:%s" % str(c["function_id"])
        node(fid, "funzione", t=str(c["function_id"]).lower().replace("_", " "))
        edge(c["id"], fid, "posa", "calato, mette la sua funzione sulla pila scoperta",
             "sulla pila degli Echi calati")

# **La carta porta il suo Eco** (D-359). E' l'arco che racconta la decisione: non
# c'e' piu' un mazzo del Narratore, l'Eco e' il terzo blocco stampato sulla carta
# Asset. Senza questa freccia il disegno mostrerebbe ancora due mazzi separati.
for a in load("assets/*.json"):
    if a.get("echo_id"):
        edge(a["id"], a["echo_id"], "porta",
             "l'Eco stampato su questa carta: la sua versione potenziata")

# ---------- TENSIONI ----------
#
# **Una casella dice cosa fa, su chi, e dove** (D-366). Fino alla 0.1.332 il
# disegno scriveva «sul luogo della domanda» su ogni arco che usciva da una
# carta Tensione, perche' era vero: ogni casella agiva li'. Adesso non lo e'
# piu', e un disegno che lo scrive ancora **mente** — che e' peggio di un
# disegno che tace.

# La glossa italiana dei due campi nuovi. Non e' il vocabolario che esegue —
# quello sta in `CouncilEconomy` — ma la frase che il disegno scrive accanto
# alla freccia. L'identita' del posto viaggia sempre col suo valore d'enum,
# cosi' una rinomina non puo' far dire all'arco una cosa per un'altra, e il
# controllo qui sotto va rosso se lo schema aggiunge un posto che nessuno ha
# ancora imparato a raccontare.
DOVE = {"FOCUS": "sul luogo della domanda",
        "ADJACENT": "su una Regione confinante",
        "CAPITAL": "sulla capitale",
        "RIVAL_SEAT": "sulla sede del rivale",
        "REGION_WITH": "su una Regione che porta il segno",
        "QUESTION": "sulla domanda chiamata per nome"}
CHI = {"PROPONENT": "di chi propone", "RIVAL": "del rivale",
       "HOUSE_WITH": "della casa che porta il segno", "NOBODY": "di nessuno"}


def nomi_delle_caselle():
    """Come si chiama ogni casella, letto da `docs/MISURA_CASELLE.md`.

    Quel documento lo genera una sonda **chiamando** `CouncilEconomy`, e un
    cancello lo tiene aggiornato: e' l'unico posto da cui Python puo' leggere il
    vocabolario che esegue senza ricopiarlo. E' lo stesso ponte che usa il
    controllo 24 di `validate_physical`.
    """
    doc = REPO / "docs" / "MISURA_CASELLE.md"
    if not doc.exists():
        return {}
    fuori = {}
    for riga in doc.read_text(encoding="utf-8").splitlines():
        trovato = re.match(r"\|\s*\*\*([A-Z_]+)\*\*\s*—\s*([^|]+)\|", riga)
        if trovato:
            fuori[trovato.group(1)] = trovato.group(2).strip()
    return fuori


CASELLE = nomi_delle_caselle()


def _enum_della_casella(campo):
    """L'enum di `dove` o di `chi`, preso dallo schema della Tensione."""
    schema = json.load(open(REPO / "schema" / "tension.schema.json", encoding="utf-8"))
    trovati = set()

    def scava(nodo):
        if isinstance(nodo, dict):
            blocco = nodo.get(campo)
            if isinstance(blocco, dict) and isinstance(blocco.get("enum"), list):
                trovati.update(str(v) for v in blocco["enum"])
            for figlio in nodo.values():
                scava(figlio)
        elif isinstance(nodo, list):
            for figlio in nodo:
                scava(figlio)

    scava(schema)
    return trovati


# **Un posto che il disegno non sa raccontare non si salta in silenzio.** Se lo
# schema ne aggiunge uno e nessuno passa di qui, l'arco uscirebbe con una frase
# vuota e il disegno direbbe meno di quello che i dati dicono, senza lamentarsi.
for campo, glossa in (("dove", DOVE), ("chi", CHI)):
    _mancanti = _enum_della_casella(campo) - set(glossa)
    if _mancanti:
        sys.exit("il disegno non sa raccontare %s: %s — aggiungilo a build_flow.py"
                 % (campo, ", ".join(sorted(_mancanti))))


def racconta_posto(voce):
    """Dove va a finire questa casella, e su chi parla — detto per esteso."""
    dove = str(voce.get("dove", "FOCUS"))
    chi = str(voce.get("chi", "PROPONENT"))
    pezzi = [DOVE.get(dove, dove)]
    if dove == "REGION_WITH" and voce.get("place_tag"):
        pezzi[0] += " #%s" % voce["place_tag"]
    if dove == "QUESTION" and voce.get("question"):
        pezzi[0] += " %s" % voce["question"]
    # La casa si nomina solo quando non e' quella di sempre: scriverla su ogni
    # arco farebbe rumore, e il rumore nasconde le tre caselle che parlano di
    # qualcun altro.
    if chi != "PROPONENT":
        pezzi.append("e parla %s" % CHI.get(chi, chi))
        if chi == "HOUSE_WITH" and voce.get("who_tag"):
            pezzi[-1] += " #%s" % voce["who_tag"]
    return ", ".join(pezzi)


for t in load("tensions/*.json"):
    ph = t.get("physical") or {}
    node(t["id"], "tensione", t=t.get("title", ""), dom=t.get("domain", ""))
    for buck, nome in (("benefits", "beneficio"), ("costs", "costo"), ("failure", "fallimento")):
        for it in ph.get(buck, []) or []:
            posto = racconta_posto(it)
            # **La casella e' un pezzo del tavolo, non solo una riga di testo.**
            # Cinque caselle su otto — le due della presenza, il rapporto, la
            # domanda che si scopre, la casa che se ne va — non toccano ne' un
            # segno ne' una Pietra, e il disegno non le mostrava affatto. Adesso
            # ognuna e' un pezzo che si puo' scegliere: chi la offre, e dove va
            # a finire quando la offre.
            verbo = str(it.get("verb", ""))
            if verbo:
                cid = "casella:%s" % verbo
                node(cid, "casella", t=CASELLE.get(verbo, verbo), d=CASELLE.get(verbo, ""))
                edge(t["id"], cid, "offre",
                     "%s: %s" % (nome, it.get("text", "")[:80]), posto)
            if it.get("tag"):
                edge(t["id"], it["tag"], "posa", "%s «%s»: %s" % (nome, it.get("verb", ""), it.get("text", "")[:80]),
                     posto)
            if it.get("structure"):
                edge(t["id"], it["structure"], "costruisce",
                     "%s «%s»: %s" % (nome, it.get("verb", ""), it.get("text", "")[:80]), posto)
            # **I segni che scelgono il bersaglio.** Non sono segni che la carta
            # posa: sono segni che la carta **legge** per sapere dove mettere la
            # pedina. Il verso e' quello della lettura, e girato dice la cosa
            # che serve al tavolo: «#commercio — chi lo guarda, e per farci
            # cosa».
            for campo, perche in (("place_tag", "sceglie la Regione di cui parla la casella"),
                                  ("verso_tag", "sceglie l'altro capo della strada"),
                                  ("who_tag", "sceglie la casa di cui parla la casella")):
                if it.get(campo):
                    edge(t["id"], it[campo], "legge",
                         "%s «%s»: %s" % (nome, it.get("verb", ""), perche))
            # E la domanda chiamata per nome: una carta che ne muove un'altra.
            if it.get("question"):
                edge(t["id"], it["question"], "chiama",
                     "%s «%s»: %s" % (nome, it.get("verb", ""), it.get("text", "")[:80]),
                     "la muove chiamandola per nome")

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


def generi_che_il_disegno_conosce():
    """I generi di pezzo che il template sa mostrare, letti dal template."""
    testo = TEMPLATE.read_text(encoding="utf-8")
    blocco = re.search(r"const KINDS = \{(.*?)\};", testo, re.S)
    if not blocco:
        sys.exit("il template non ha piu' la tabella KINDS: il disegno non si "
                 "puo' controllare")
    return set(re.findall(r"(\w+)\s*:\s*\"", blocco.group(1)))


def verbi_che_il_disegno_conosce():
    """I versi che il template sa disegnare, letti dal template."""
    testo = TEMPLATE.read_text(encoding="utf-8")
    blocco = re.search(r"const VERBS = \{(.*?)\};", testo, re.S)
    if not blocco:
        sys.exit("il template non ha piu' la tabella VERBS: il disegno non si "
                 "puo' controllare")
    return set(re.findall(r"(\w+)\s*:\s*\[", blocco.group(1)))


# **Un verso che il template non conosce non si disegna, e non lo dice nessuno.**
# La pagina filtra gli archi su `VERBS`: un arco con un verso che non sta li'
# dentro finisce nel JSON e **sparisce dal disegno**. E' successo il giorno che
# «chiama» e' entrato con le caselle di D-366: tredici archi veri, invisibili.
_noti = verbi_che_il_disegno_conosce()
_ignoti = sorted({str(a["k"]) for a in E} - _noti)
if _ignoti:
    sys.exit("il template non sa disegnare questi versi, e li butterebbe via in "
             "silenzio: %s — aggiungili a VERBS in tools/flow_template.html"
             % ", ".join(_ignoti))
# Stessa trappola sui **pezzi**: `st.kinds` filtra i nodi come `st.verbs` filtra
# gli archi, e un genere che il template non elenca sparisce dal disegno.
_generi_ignoti = sorted({str(n["k"]) for n in N.values()} - generi_che_il_disegno_conosce())
if _generi_ignoti:
    sys.exit("il template non sa mostrare questi generi di pezzo, e li butterebbe "
             "via in silenzio: %s — aggiungili a KINDS in tools/flow_template.html"
             % ", ".join(_generi_ignoti))


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
