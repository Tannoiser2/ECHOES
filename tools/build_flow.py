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

# **La regola della cacciata si prende in prestito, non si ricopia.**
# Chi toglie una presenza lascia addosso i segni della cacciata, e quale pezzo
# lo faccia lo sa gia' `validate_physical`: e' il riscontro con cui il
# dizionario dichiara le proprie penne. Riscriverla qui vorrebbe dire due
# regole che divergono in silenzio — la trappola che questo progetto ha pagato
# cinque volte.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from validate_physical import _toglie_presenza  # noqa: E402

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

def clausole(o, owner):
    """Cosa un passo di Destino o di Obiettivo guarda sul tavolo.

    Tre cose, e la terza mancava: il **segno** che nomina, il segno che
    **teme**, e — quando invece di un segno conta dei pezzi — le **Pietre**
    della famiglia che sta contando. Un passo che chiede *«un presidio suo»*
    parla di un pezzo che sul tavolo c'e'; disegnarlo come un conto astratto
    lasciava diciassette Obiettivi senza una sola freccia.
    """
    if isinstance(o, dict):
        tg = o.get("tag") or (o.get("params") or {}).get("tag")
        ty = str(o.get("type", ""))
        if tg and isinstance(tg, str):
            edge(owner, tg, "teme" if ty == "state_tag_absent" else "osserva",
                 "clausola: %s" % ty)
        # Il bersaglio a segni di una clausola (D-274, D-377): «una pedina dove
        # c'e' il #granaio» non nomina una Regione, nomina il segno stampato
        # sulla tessera — ed e' una lettura come tutte le altre.
        for scelto in o.get("any_tag", []) or []:
            edge(owner, str(scelto), "osserva",
                 "bersaglio a segni: %s" % (o.get("label") or ty))
        if o.get("structure_family"):
            for pietra in FAMIGLIE.get(str(o["structure_family"]), []):
                edge(owner, pietra, "conta",
                     "%s: %s" % (ty, o.get("label") or str(o["structure_family"])))
        for v in o.values():
            clausole(v, owner)
    elif isinstance(o, list):
        for v in o:
            clausole(v, owner)


# ---------- I SEGNI DELLA CACCIATA ----------
#
# **Togliere una presenza scrive tre segni**, e il disegno ne mostrava zero:
# `uprooted` era un pezzo che nessuna freccia toccava, come se nessuno lo
# posasse. Lo posa chiunque cacci una casa da una Regione (D-130) — e lo
# **rilegge**, perche' la seconda cacciata nello stesso anno vale il doppio ed
# e' quella che la successione guarda per far nascere una vita senza centro.
#
# Non e' una regola scritta qui: e' `validate_physical._toglie_presenza`,
# la stessa con cui il dizionario dichiara le proprie penne.
def segni_della_cacciata(pezzi, perche):
    for pezzo in pezzi:
        if not _toglie_presenza(pezzo):
            continue
        pid = str(pezzo.get("id", ""))
        if not pid:
            continue
        edge(pid, "uprooted", "posa", "%s: la casa cacciata se lo porta addosso" % perche,
             "sulla scheda della casa")
        edge(pid, "twice_uprooted", "posa",
             "%s: la seconda cacciata nello stesso anno" % perche,
             "sulla scheda della casa")
        edge(pid, "uprooted", "legge",
             "per sapere se e' la prima cacciata o la seconda")


def letture(o, src, why):
    """I segni che una condizione nomina: leggerli e' quello che fa la clausola.

    Un blocco di eleggibilita' — su una domanda, su una proposta — dice quando
    quella cosa si puo' fare. Nel disegno e' una **lettura**, e girata risponde
    alla domanda vera del tavolo: *«#malcontento, chi lo guarda e per farci
    cosa»*.
    """
    if isinstance(o, dict):
        tg = o.get("tag") or (o.get("params") or {}).get("tag")
        ty = str(o.get("type", ""))
        if tg and isinstance(tg, str):
            edge(src, tg, "teme" if ty == "state_tag_absent" else "legge",
                 "%s: %s" % (why, o.get("label") or ty))
        # Una condizione puo' nominare una domanda invece di un segno — «questa
        # questione e' al limite» — e allora e' una carta che ne guarda un'altra.
        if o.get("tension_id") and not str(o["tension_id"]).startswith("$"):
            edge(src, str(o["tension_id"]), "legge",
                 "%s: %s" % (why, o.get("label") or ty))
        for v in o.values():
            letture(v, src, why)
    elif isinstance(o, list):
        for v in o:
            letture(v, src, why)


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
FAMIGLIE = defaultdict(list)
for s in load("structures/*.json"):
    node(s["id"], "pietra", t=s.get("name", ""), d=s.get("description", ""),
         fam=s.get("family", ""))
    if s.get("family"):
        FAMIGLIE[str(s["family"])].append(s["id"])
    tags = []
    for i, g in enumerate(s.get("grades", []) or [], 1):
        if g.get("tag"):
            tags.append(g["tag"])
            edge(s["id"], g["tag"], "porta", "grado %d: %s" % (i, g.get("name", "")))
    GRADI[s["id"]] = tags
    # **Una Pietra che va in rovina lascia una Cicatrice**, e il disegno non lo
    # sapeva: `scar:burned_records` — quello che resta dell'Archivio bruciato —
    # era un pezzo che nessuna freccia toccava, come se nessuno lo posasse. Lo
    # posa la rovina, e sta scritto qui accanto da sempre.
    rovina = s.get("ruin") or {}
    if rovina.get("scar"):
        edge(s["id"], str(rovina["scar"]), "rovina",
             "%s: %s" % (rovina.get("name", "in rovina"),
                         str(rovina.get("description", ""))[:80]),
             "un dischetto sulla tessera")

# ---------- CASE, E LE VITE CHE SI SIEDONO AL LORO POSTO ----------
#
# **Una casa ha piu' vite scritte** (D-133): il popolo diventa regno, la scuola
# diventa culto. Nel disegno non c'erano, e si vedeva dal buco che lasciavano:
# `twice_uprooted` e `uprooted` — i segni che aprono la porta a due di quelle
# vite — erano pezzi che nessuna freccia toccava, come se nessuno li leggesse.
# Li legge la successione, che e' il pezzo che mancava.
PORTE = {"FOUNDING": "e' la prima: si siede all'apertura",
         "ON_TAG": "si siede quando il mondo porta il segno",
         "ON_DEATH": "si siede quando la vita di prima finisce",
         "LINE_EXHAUSTED": "si siede quando la linea si esaurisce"}
for e in load("entities/*.json"):
    node(e["id"], "casa", t=e.get("name", e.get("title", "")), d=e.get("description", ""))
    for tg in (e.get("tags") or []) + (e.get("starting_tags") or []):
        edge(e["id"], tg, "stampato", "sulla scheda della casa")
    for vita in e.get("incarnations", []) or []:
        vid = str(vita.get("id", ""))
        if not vid:
            continue
        node(vid, "vita", t=vita.get("name", vid), d=vita.get("description", ""),
             porta=vita.get("entry", ""), dura=vita.get("persistence", ""))
        edge(e["id"], vid, "diventa",
             "%s — %s" % (vita.get("name", vid),
                          PORTE.get(str(vita.get("entry", "")), str(vita.get("entry", "")))))
        if vita.get("entry_tag"):
            edge(vid, str(vita["entry_tag"]), "legge",
                 "la porta di questa vita: si siede quando il mondo porta il segno")
        if vita.get("entry_forbidden_tag"):
            edge(vid, str(vita["entry_forbidden_tag"]), "teme",
                 "con questo segno sul mondo la porta resta chiusa")
        # La porta del tempo (D-290, D-374): dopo tanti anni si entra lo stesso,
        # a meno che una clausola tenga ancora.
        for clausola in ((vita.get("also_enters") or {}).get("unless") or []):
            letture(clausola, vid,
                    "la porta del tempo si apre dopo %s anni, a meno che"
                    % (vita.get("also_enters") or {}).get("after_years", "?"))
        if vita.get("destiny_id"):
            edge(vid, str(vita["destiny_id"]), "porta", "il Destino che questa vita si porta")
        # **Quanto vale ogni Azione per questa vita.** E' il numero stampato
        # sulla carta della casa, e nel disegno non c'era: `ACT_ACQUIRE` era
        # l'unica delle sei Azioni che nessuna freccia toccava — non perche'
        # nessuno la usi, ma perche' chi le da' un valore sono le ventisei vite,
        # e le vite non erano disegnate.
        for verbo, quanto in (vita.get("action_values") or {}).items():
            if TPL.get(str(verbo)):
                edge(vid, TPL[str(verbo)], "vale",
                     "per questa vita vale %s" % quanto)

# ---------- TEMI ----------
for th in load("themes/*.json"):
    node(th["id"], "tema", t=th.get("title", ""), d=th.get("covers", ""))
    for tg in th.get("tags", []) or []:
        edge(th["id"], tg, "raccoglie", "il Tema raccoglie il segno")

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
segni_della_cacciata(load("assets/*.json"), "chi caccia")

# ---------- ECHI E CONSEGUENZE ----------
for pat, kind, why in (("echoes/*.json", "eco", "effetto dell'Eco"),
                       ("consequences/*.json", "conseguenza", "Conseguenza del Consiglio")):
    for c in load(pat):
        node(c["id"], kind, t=c.get("title", "") or str(c.get("text", ""))[:70],
             d=c.get("description", ""))
        effetti(c, c["id"], why)
    segni_della_cacciata(load(pat), "chi caccia")

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
    node(t["id"], "tensione", t=t.get("title", ""), dom=t.get("domain", ""),
         d=t.get("description", ""))
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

# ---------- IL CONSIGLIO CHE UNA CARTA APRE ----------
#
# **La cosa centrale del gioco, e nel disegno non c'era.** Il grafo mostrava le
# dodici proposte scritte nei template — quelle che dal 0.1.345 **il motore non
# legge piu' per nessuna carta** — e delle centoventi domande e centonovantaquattro
# proposte che stanno sulle carte non mostrava niente. E' la stessa trappola che
# ha morso il catalogo dei Consigli in 0.1.273 e la revisione dei testi in
# 0.1.345: una sonda che guarda ancora la casa vecchia.
#
# Adesso la catena si percorre col dito: **una carta apre una domanda, la
# domanda ha le sue risposte, una risposta porta una Conseguenza, la Conseguenza
# posa un segno** — e il segno, girato, dice chi altro lo guarda.


def consigli_delle_carte():
    """Quale Consiglio serve quale carta, letto da `docs/CATALOGO_CONSIGLI.md`.

    La regola sta in `DataSet._council_base_for` — il Consiglio scritto per la
    carta, altrimenti quello del suo dominio — e da li' vengono le clausole e i
    sacchetti delle Conseguenze. Python quella regola **non la ricopia**: la
    scrive chi la esegue, in fondo al catalogo, e qui si legge. E' lo stesso
    ponte dei nomi delle caselle (D-368).
    """
    doc = REPO / "docs" / "CATALOGO_CONSIGLI.md"
    if not doc.exists():
        return {}
    fuori = {}
    for riga in doc.read_text(encoding="utf-8").splitlines():
        trovato = re.match(r"CONSIGLIO (\S+) = (\S+)\s*$", riga.strip())
        if trovato:
            fuori[trovato.group(1)] = trovato.group(2)
    return fuori


SERVITA_DA = consigli_delle_carte()

# **Un ponte che si rompe non si attraversa in silenzio.** Se il catalogo non
# porta piu' quel blocco, il disegno perderebbe clausole e sacchetti senza
# lamentarsi: sessanta carte che smettono di avere un prezzo, e nessuno lo dice.
if not SERVITA_DA:
    sys.exit("docs/CATALOGO_CONSIGLI.md non porta piu' il ponte «CONSIGLIO ... = ...»:"
             " rilancia `tools/run_council_catalogue.sh` prima di disegnare")

# I Consigli come pezzi del tavolo: quello che il template continua a dare
# quando la carta ha gia' le sue domande — le clausole e i tre sacchetti.
SACCHETTI = {"cost": ("paga_con", "il prezzo che il tavolo chiede"),
             "failure": ("se_cade", "quello che resta se la proposta cade"),
             "decisive_bonus": ("se_stravince", "il di piu' di una vittoria netta")}

for tpl in load("confluences/*.json"):
    node(tpl["id"], "consiglio", t=tpl.get("title", tpl["id"]), d=tpl.get("description", ""),
         dom=tpl.get("applies_to_domain", ""))
    for clausola in tpl.get("condition_clauses", []) or []:
        cid = str(clausola.get("id", ""))
        if not cid:
            continue
        node(cid, "clausola", t=str(clausola.get("text", ""))[:70],
             d=str(clausola.get("text", "")))
        edge(tpl["id"], cid, "si_contratta",
             "un avversario la attacca alla proposta prima del voto")
        effetti(clausola, cid, "clausola qualificata")
    pools = tpl.get("consequence_pools") or {}
    for sacco, (verso, perche) in SACCHETTI.items():
        for cns in pools.get(sacco, []) or []:
            edge(tpl["id"], str(cns), verso, perche)

# Le domande e le proposte stanno sulla carta (D-310).
for t in load("tensions/*.json"):
    consiglio = SERVITA_DA.get(str(t["id"]), "")
    if consiglio:
        edge(t["id"], consiglio, "si_tiene_con",
             "le clausole e i sacchetti li mette il Consiglio; le domande le mette la carta")
    council = t.get("council") or {}
    risposte = defaultdict(list)
    for prop in council.get("propositions", []) or []:
        risposte[str(prop.get("question_id", ""))].append(prop)
    for q in council.get("questions", []) or []:
        qid = str(q.get("id", ""))
        if not qid:
            continue
        node(qid, "domanda", t=str(q.get("text", ""))[:70], d=str(q.get("text", "")))
        edge(t["id"], qid, "apre", "la domanda che questa carta mette ai voti")
        # Una domanda che si apre solo a certe condizioni **legge** il tavolo.
        letture(q.get("eligibility"), qid, "la domanda si apre solo se")
        for prop in risposte.get(qid, []):
            pid = str(prop.get("id", ""))
            if not pid:
                continue
            node(pid, "proposta", t=str(prop.get("text", ""))[:70],
                 d=str(prop.get("text", "")))
            edge(qid, pid, "si_risponde", "una delle risposte stampate sulla carta")
            letture(prop.get("eligibility"), pid, "si puo' proporre solo se")
            for cns in prop.get("success_consequences", []) or []:
                edge(pid, str(cns), "porta", "se passa, questo resta al mondo")


# ---------- LA CATENA DELLE ERE ----------
#
# **Il tempo e' una penna** (D-133, ISSUES 112). A ogni successione, se il segno
# della condizione sta sui fatti del mondo e quello di guardia no, il conto posa
# il prossimo anello della catena; se la condizione cade, tutta la catena
# sparisce e il conto riparte.
#
# Il disegno non la conosceva. `seal_kept` e `seal_kept_twice` finivano nel
# grafo come **pezzi senza una freccia**: mostrati, e senza nessuno che dicesse
# chi ce li mette — che e' esattamente la domanda a cui questa pagina serve a
# rispondere. Ed e' lo stesso varco che il censimento dei segni lasciava aperto.
for cr in load("chronicle_*/*.json"):
    for conto in cr.get("era_tallies", []) or []:
        cid = str(conto["id"])
        node(cid, "catena", t="il conto delle ere", d="a ogni successione avanza di un anello, se la condizione tiene")
        edge(cid, str(conto["if_tag"]), "legge", "il conto avanza solo se il mondo porta questo segno")
        if conto.get("if_not_tag"):
            edge(cid, str(conto["if_not_tag"]), "teme",
                 "se il mondo porta questo segno la catena sparisce e il conto riparte")
        for indice, anello in enumerate(conto.get("chain", []) or []):
            edge(cid, str(anello), "posa", "anello %d della catena" % (indice + 1),
                 "un gettone sul bordo della mappa")
            # E li rilegge tutti, per sapere a che punto e': e' il conto stesso
            # che si guarda indietro.
            edge(cid, str(anello), "legge", "per sapere a che anello e' arrivato")

# ---------- DESTINI ----------
for d in load("destinies/*.json"):
    ph = d.get("physical") or {}
    node(d["id"], "destino", t=d.get("title", d["id"]), casa=d.get("entity_id", ""))
    for th in ph.get("themes", []) or []: edge(d["id"], th, "guarda_tema", "il Destino guarda il Tema")
    for ob in ph.get("observes", []) or []:
        tg = ob if isinstance(ob, str) else (ob.get("tag") or "")
        if tg: edge(d["id"], tg, "osserva", "clausola sulla faccia del Destino")
    clausole(d, d["id"])

# ---------- GLI OBIETTIVI CHE SI TENGONO IN MANO ----------
#
# Sono goal quanto un Destino (D-222) e nel disegno non c'erano: cliccando un
# segno si vedeva chi lo posa e chi lo teme, ma non chi lo **vuole per vincere**
# tenendolo in mano. E' lo stesso buco che la misura della matrice aveva gia'
# trovato dal suo lato — 84 segni «orfani» su 148 erano una lista non letta.
for ob in load("objectives/*.json"):
    node(ob["id"], "obiettivo", t=ob.get("title", ob["id"]), d=ob.get("description", ""))
    clausole(ob, ob["id"])

# ---------- I PROFILI STRATEGICI: cosa una casa vuole lasciare ----------
#
# La riga dichiarata di ogni casa (D-288): i segni che vuole vedere nel mondo a
# fine partita, quelli che teme, e i `denies` — un incrocio scritto a mano, «io
# voglio impedire proprio a te proprio quello».
for pr in load("design_matrix/*.json"):
    casa = str(pr.get("entity_id", ""))
    if not casa:
        continue
    pid = "profilo:%s" % casa
    node(pid, "profilo", t="quello che %s vuole lasciare" % casa,
         d=pr.get("in_one_line", ""))
    edge(casa, pid, "porta", "la strategia dichiarata della casa")
    for voce in pr.get("wants", []) or []:
        if voce.get("tag"):
            edge(pid, str(voce["tag"]), "vuole", str(voce.get("why", "")))
    for voce in pr.get("fears", []) or []:
        if voce.get("tag"):
            edge(pid, str(voce["tag"]), "teme", str(voce.get("why", "")))
    for voce in pr.get("denies", []) or []:
        if voce.get("tag"):
            edge(pid, str(voce["tag"]), "nega", str(voce.get("why", "")))
            if voce.get("to"):
                edge(pid, str(voce["to"]), "nega",
                     "vuole impedire proprio a questa casa: %s" % str(voce.get("why", "")))

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


# **La copia da pubblicare non e' lo stesso file.** Un Artifact incarta quello
# che gli si da' dentro un `<body>` suo: consegnargli un documento intero — con
# il suo `<!doctype>` e il suo `<head>` — funziona per tolleranza del browser,
# non per costruzione. Qui si toglie l'involucro e si tiene il contenuto, cosi'
# la pagina pubblicata e' quella del repo senza un secondo documento dentro.
INVOLUCRO = ["<!doctype html>", "</head>", "</body>", "</html>"]


def per_l_artifact(pagina: str) -> str:
    fuori = pagina
    for pezzo in INVOLUCRO:
        fuori = fuori.replace(pezzo, "")
    for apertura in ('<html lang="it"><head>', "<html><head>", "<body>"):
        fuori = fuori.replace(apertura, "")
    if "<!doctype" in fuori.lower() or "<html" in fuori.lower():
        raise SystemExit("l'involucro non e' venuto via: il template e' cambiato")
    return fuori.strip() + "\n"


def main() -> int:
    pagina = disegna()
    for arg in sys.argv[1:]:
        if arg.startswith("--artifact="):
            destinazione = Path(arg.split("=", 1)[1])
            destinazione.write_text(per_l_artifact(pagina), encoding="utf-8")
            print("copia per l'Artifact: %s (%d KB)"
                  % (destinazione, len(destinazione.read_text(encoding="utf-8")) // 1024))
            return 0
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
