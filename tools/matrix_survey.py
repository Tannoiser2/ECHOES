#!/usr/bin/env python3
"""Le tre misure che vengono prima della matrice strategica.

    python3 tools/matrix_survey.py            # riscrive docs/MISURA_MATRICE.md
    python3 tools/matrix_survey.py --check    # fallisce se il documento e' vecchio

Il committente ha chiesto una matrice strategica — profili delle Entita', tag
incrociati, Tensioni incrociate, regole di eredita' — e i tre elenchi che la
giustificano: **tag orfani, obiettivi non fisici, Tensioni senza conflitto.**

Questo strumento produce i tre elenchi **dai dati di oggi**, prima che si
scriva un file nuovo. La ragione e' la regola di casa contro l'indovinare: la
dimensione di una matrice e' esattamente il genere di cosa che si indovina
volentieri, e un elenco misurato dice se il problema e' di dieci voci o di
cento.

Le tre domande, dette con precisione:

 1. **Un segno e' orfano** se qualcuno lo scrive e poi *nessuna Entita' lo
    desidera o lo teme* **e** *nessuna Tensione lo mette o lo toglie*: e' un
    segnalino che si posa sul tavolo e non entra in nessuna partita.
 2. **Un obiettivo e' non fisico** se una sua clausola chiede un segno che
    **niente scrive** (impossibile), oppure se un intero livello non nomina
    nessun segno e si regge solo su conteggi (`scar_count`, `control_count`):
    si puo' verificare, ma non si puo' *puntare col dito*.
 3. **Una Tensione e' senza conflitto** se, fra le Entita' della scatola, non
    ne aiuta almeno una e non ne minaccia almeno un'altra: al Consiglio
    nessuno avrebbe una ragione per opporsi.
"""

from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Set, Tuple

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "godot" / "data"
DOC = REPO / "docs" / "MISURA_MATRICE.md"

# I segni che i verbi dell'economia del Consiglio posano da soli (D-280).
TOLL_TAG = "structure:tollgate"
DEBT_TAG = "condition:indebted"
CLOSED_TAG = "condition:cut_off"

# Le clausole che nominano un segno, e quelle che contano e basta.
NAMES_A_SIGN = {"state_tag_present", "state_tag_absent", "requires_entity_tag"}
COUNTS_ONLY = {
    "scar_count", "control_count", "structure_count", "region_presence",
    "entity_alive", "tension_limit", "tension_count", "discovery_count",
    "asset_threshold", "relation_state", "leads_in", "promise_kept",
    "promise_broken",
}


def items(pattern: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for path in sorted(DATA.glob(pattern)):
        with path.open(encoding="utf-8") as handle:
            out.extend(json.load(handle).get("items", []))
    return out


def walk(node: Any):
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from walk(value)
    elif isinstance(node, list):
        for value in node:
            yield from walk(value)


# --- chi scrive un segno ----------------------------------------------------

def written_signs() -> Dict[str, Set[str]]:
    """Segno -> le penne che lo posano, coi nomi che il registro usa gia'."""
    pens: Dict[str, Set[str]] = defaultdict(set)

    def note(tag: str, who: str) -> None:
        if tag:
            pens[str(tag)].add(who)

    for pattern, who in (
        ("consequences/*.json", "Conseguenza"),
        ("echoes/*.json", "carta Echo"),
        ("chronicle_*/confluences/*.json", "clausola di Consiglio"),
        ("assets/*.json", "carta Asset"),
    ):
        for item in items(pattern):
            for node in walk(item):
                kind = str(node.get("type", ""))
                tag = str((node.get("payload") or {}).get("tag", ""))
                if tag and "TAG" in kind and "REMOVE" not in kind:
                    note(tag, who)
                if kind == "ADD_SCAR" and tag:
                    note(tag, who)
            note(str((item.get("scar") or {}).get("tag", "")), who)
    # La faccia delle carte, che da D-283 scrive per davvero.
    for card in items("assets/*.json"):
        face = card.get("physical") or {}
        for action in face.get("actions", []) or []:
            for tag in (action or {}).get("puts_tag", []) or []:
                note(str(tag), "Azione stampata")
        extra = (face.get("resonance") or {}).get("extra_tag")
        if extra:
            note(str(extra), "Risonanza")
    # **La faccia della Tensione scrive** (D-308): le sue caselle posano segni
    # come una Conseguenza, e la sonda non le guardava.
    for tension in items("tensions/*.json"):
        face = tension.get("physical") or {}
        for field in ("benefits", "costs", "failure"):
            for voice in face.get(field, []) or []:
                verb = str((voice or {}).get("verb", ""))
                tag = str((voice or {}).get("tag", ""))
                if tag and verb in ("ADD_CONDITION", "SCAR", "REMEMBER"):
                    note(tag, "faccia della Tensione")
    for structure in items("structures/*.json"):
        for grade in structure.get("grades", []) or []:
            note(str((grade or {}).get("tag", "")), "Pietra")
        note(str((structure.get("ruin") or {}).get("tag", "")), "Pietra in rovina")
    for region in items("regions/*.json"):
        for tag in region.get("tags", []) or []:
            note(str(tag), "tessera")
    for entity in items("entities/*.json"):
        for tag in entity.get("tags", []) or []:
            note(str(tag), "casato")
    for chronicle in items("chronicle_*/chronicle_*.json"):
        for tag in chronicle.get("global_tags", []) or []:
            note(str(tag), "apertura della Chronicle")
        for tag in chronicle.get("enduring_facts", []) or []:
            note(str(tag), "fatto che dura")
        for tally in chronicle.get("era_tallies", []) or []:
            for tag in (tally or {}).get("chain", []) or []:
                note(str(tag), "catena delle ere")
    # **Una leggenda e' il segno di prima, un'era dopo.** Al salto temporale il
    # motore trasforma in `legend:<fatto>` ogni fatto globale che sbiadisce
    # (`world_state_factory`): un Destino che chiede `legend:x` chiede una cosa
    # che qualcuno scrive eccome, solo non nei dati. Senza questa riga la
    # misura chiamava impossibile il Trionfo di Vaerax, che impossibile non e'.
    for tag in list(pens):
        pens["legend:%s" % tag].add("il tempo (leggenda)")
    return pens


# --- cosa un'Entita' vuole e cosa teme --------------------------------------

def destiny_signs() -> Tuple[
    Dict[str, Set[str]], Dict[str, Set[str]], Dict[str, Set[str]],
    Dict[str, Set[str]], List[Dict[str, Any]]
]:
    """Entita' -> segni voluti, temuti, guardati, conteggi; e il referto per livello."""
    wants: Dict[str, Set[str]] = defaultdict(set)
    fears: Dict[str, Set[str]] = defaultdict(set)
    watches: Dict[str, Set[str]] = defaultdict(set)
    # **E i conteggi**: un Destino che chiede due Pietre non nomina nessun
    # segno, ma una Tensione che ne costruisce una lo aiuta eccome — e una che
    # incide una Cicatrice minaccia chi ne vuole zero. Guardare i soli segni
    # nominati diceva 60 Tensioni su 60 senza conflitto: un assoluto, cioe' il
    # segnale che la misura non guardava dove il gioco succede.
    counts: Dict[str, Set[str]] = defaultdict(set)
    levels: List[Dict[str, Any]] = []
    for destiny in items("destinies/*.json"):
        entity = str(destiny.get("entity_id", ""))
        for level in ("minimum", "victory", "triumph"):
            named: Set[str] = set()
            counted = 0
            for node in walk((destiny.get(level) or {}).get("conditions")):
                kind = str(node.get("type", ""))
                if kind in NAMES_A_SIGN and node.get("tag"):
                    named.add(str(node["tag"]))
                    if kind == "state_tag_absent":
                        fears[entity].add(str(node["tag"]))
                    else:
                        wants[entity].add(str(node["tag"]))
                elif kind in COUNTS_ONLY:
                    counted += 1
                    if kind == "structure_count":
                        counts[entity].add("vuole pietre")
                    elif kind == "control_count":
                        counts[entity].add("vuole controllo")
                    elif kind == "scar_count" and node.get("max") is not None:
                        counts[entity].add("teme cicatrici")
            levels.append({
                "destiny": str(destiny.get("id", "")),
                "entity": entity,
                "level": level,
                "label": str((destiny.get(level) or {}).get("label", "")),
                "named": sorted(named),
                "counted": counted,
            })
        # La faccia fisica del Destino (D-270) dichiara cosa **guarda** — e
        # guardare non e' volere: `observes` elenca insieme i segni che una
        # casa insegue e quelli che teme. Tenerlo dentro «vuole» gonfiava il
        # conto dei conflitti con roba che non lo e'. Sta a parte, e serve a
        # dire *a chi interessa* una Tensione, non chi ci guadagna.
        for tag in (destiny.get("physical") or {}).get("observes", []) or []:
            watches[entity].add(str(tag))
    # **E gli obiettivi che si hanno in mano** (D-222): sono goal quanto il
    # Destino, e la prima stesura di questa misura non li guardava — 84 segni
    # «orfani» su 148 erano il segnale che qualcosa non veniva letto, non che
    # il gioco fosse mezzo vuoto. Un obiettivo non e' di nessuna Entita' in
    # particolare (si pesca), quindi vale per tutte: sta nel mazzo comune.
    for objective in items("objectives/*.json"):
        for node in walk(objective.get("conditions")):
            kind = str(node.get("type", ""))
            if kind in NAMES_A_SIGN and node.get("tag"):
                target = fears if kind == "state_tag_absent" else wants
                target["*obiettivi*"].add(str(node["tag"]))
    return wants, fears, watches, counts, levels


# --- cosa una Tensione mette e toglie ---------------------------------------

def stone_tag() -> Dict[str, str]:
    out: Dict[str, str] = {}
    for structure in items("structures/*.json"):
        grades = structure.get("grades", []) or []
        if grades:
            out[str(structure.get("id", ""))] = str(grades[0].get("tag", ""))
    return out


def tension_signs() -> Dict[str, Dict[str, Set[str]]]:
    """Tensione -> {'puts': segni che la sua faccia posa, 'clears': quelli che toglie}."""
    stones = stone_tag()
    out: Dict[str, Dict[str, Set[str]]] = {}
    for tension in items("tensions/*.json"):
        puts: Set[str] = set()
        clears: Set[str] = set()
        face = tension.get("physical") or {}
        for field in ("benefits", "costs", "failure"):
            for voice in face.get(field, []) or []:
                verb = str((voice or {}).get("verb", ""))
                tag = str((voice or {}).get("tag", ""))
                if verb == "REOPEN":
                    clears.add(CLOSED_TAG)
                elif verb == "CLEAR_CONDITION":
                    if tag:
                        clears.add(tag)
                elif verb == "BUILD_STONE":
                    stone = stones.get(str((voice or {}).get("structure", "")), "")
                    if stone:
                        puts.add(stone)
                elif verb == "ADD_CONDITION" and tag:
                    puts.add(tag)
                elif verb == "TOLL":
                    puts.add(TOLL_TAG)
                elif verb == "TAKE_DEBT":
                    puts.add(DEBT_TAG)
                elif verb == "SCAR" and tag:
                    puts.add(tag)
                # **IL MONDO RICORDA** (D-308): il verbo con cui il Consiglio
                # posa una memoria sul mondo. Senza questa riga la sonda
                # continuava a dire «sette» a un tavolo che ne sa dare
                # venticinque — l'ottava volta in questo progetto che una
                # misura ferma era la sonda, non il gioco.
                elif verb == "REMEMBER" and tag:
                    puts.add(tag)
        for tag in tension.get("focus_region_tags", []) or []:
            pass  # il fuoco dice dove si discute, non cosa lascia
        does: Set[str] = set()
        for field in ("benefits", "costs", "failure"):
            for voice in face.get(field, []) or []:
                verb = str((voice or {}).get("verb", ""))
                if verb == "BUILD_STONE":
                    does.add("alza una pietra")
                elif verb in ("TAKE_CONTROL", "YIELD_CONTROL"):
                    does.add("sposta il controllo")
                elif verb == "SCAR":
                    does.add("incide una cicatrice")
        out[str(tension.get("id", ""))] = {"puts": puts, "clears": clears, "does": does}
    return out


# --- la Legacy: cosa il tempo porta avanti ----------------------------------

def _borrowed_questions() -> int:
    """Quante carte aprono una Domanda che si legge identica su un'altra carta.

    Da 0.1.272 ogni carta porta il suo Consiglio (`council`), ma copiarlo non
    basta: se il testo e' lo stesso di un'altra carta, al tavolo la domanda e'
    ancora quella generica. Il conto guarda il **testo**, non l'id, cosi' non
    si puo' chiudere il buco rinominando.
    """
    testi: Dict[str, Set[str]] = defaultdict(set)
    for tension in items("tensions/*.json"):
        council = tension.get("council") or {}
        for question in council.get("questions", []) or []:
            testi[str((question or {}).get("text", ""))].add(str(tension.get("id", "")))
    in_prestito: Set[str] = set()
    for text, cards in testi.items():
        if text and len(cards) > 1:
            in_prestito |= cards
    return len(in_prestito)


def legacy_signs() -> Set[str]:
    carried: Set[str] = set()
    for chronicle in items("chronicle_*/chronicle_*.json"):
        for tag in chronicle.get("enduring_facts", []) or []:
            carried.add(str(tag))
        for tally in chronicle.get("era_tallies", []) or []:
            for key in ("if_tag", "if_not_tag"):
                if tally.get(key):
                    carried.add(str(tally[key]))
            for tag in (tally or {}).get("chain", []) or []:
                carried.add(str(tag))
        for names in ((chronicle.get("tension_pool") or {}).get("echoes") or {}).values():
            for tag in names or []:
                carried.add(str(tag))
    return carried


def survey() -> Tuple[str, Dict[str, int]]:
    dictionary = {str(v["id"]): v for v in items("tags/*.json")}
    profiles = items("design_matrix/*.json")
    pens = written_signs()
    wants, fears, watches, counts, levels = destiny_signs()
    tensions = tension_signs()
    carried = legacy_signs()

    wanted_anywhere: Set[str] = set()
    for group in (wants, fears):
        for tags in group.values():
            wanted_anywhere |= tags
    # **E quello che i profili dichiarano** (D-288): un segno che una casa dice
    # di volere o di temere non e' orfano, anche se nessuna clausola lo nomina.
    # E' il primo effetto misurabile della matrice: dichiarare una strategia
    # toglie dei segni dal mucchio di quelli che non servono a nessuno.
    for profile in profiles:
        for field in ("wants", "fears", "denies"):
            for voice in profile.get(field, []) or []:
                if isinstance(voice, dict) and voice.get("tag"):
                    wanted_anywhere.add(str(voice["tag"]))
    touched_by_tension: Set[str] = set()
    council_gives: Set[str] = set()
    council_inflicts: Set[str] = set()
    for sides in tensions.values():
        touched_by_tension |= sides["puts"] | sides["clears"]
        # Un Consiglio **da'** un segno quando la sua faccia lo posa come
        # beneficio o lo toglie di mezzo; lo **infligge** quando lo posa come
        # costo o come fallimento. Qui la distinzione e' grossolana — posare e'
        # posare — e va bene: serve a dire se il tavolo ha *un modo* di
        # produrre quella cosa, non chi ci guadagna.
        council_gives |= sides["puts"] | sides["clears"]
        council_inflicts |= sides["puts"]

    # **E i segni che hanno una regola loro** (`tag_rules`): un segno che
    # sconta un'azione o la vieta morde per conto suo, e chiamarlo orfano
    # sarebbe dire il falso — non e' strategia dichiarata, ma e' una regola.
    ruled: Set[str] = set()
    for rule in items("tag_rules/*.json"):
        for node in walk(rule):
            if node.get("tag"):
                ruled.add(str(node["tag"]))

    # 1. i segni orfani
    orphans: List[Tuple[str, str]] = []
    for tag in sorted(dictionary):
        if tag not in pens:
            continue  # nessuno lo scrive: e' il registro a occuparsene
        if (
            tag in wanted_anywhere or tag in touched_by_tension
            or tag in ruled or tag in carried
        ):
            continue
        orphans.append((tag, ", ".join(sorted(pens[tag]))))

    # 2. gli obiettivi che non si possono puntare col dito
    impossible: List[Tuple[str, str, str]] = []
    only_counts: List[Dict[str, Any]] = []
    for level in levels:
        for tag in level["named"]:
            if tag not in pens and tag not in dictionary:
                impossible.append((level["destiny"], level["level"], tag))
            elif tag not in pens:
                impossible.append((level["destiny"], level["level"], tag))
        if not level["named"] and level["counted"]:
            only_counts.append(level)

    # 3. le Tensioni senza conflitto
    no_conflict: List[Tuple[str, int, int, int]] = []
    named_touch = 0
    counted_touch = 0
    for tension_id, sides in sorted(tensions.items()):
        if (sides["puts"] | sides["clears"]) & (
            set().union(*wants.values()) | set().union(*fears.values())
        ):
            named_touch += 1
        if sides["does"] & {"alza una pietra", "incide una cicatrice"}:
            counted_touch += 1
        helped = 0
        threatened = 0
        watched = 0
        for entity in set(list(wants) + list(fears) + list(watches)):
            good = bool(sides["clears"] & fears[entity]) or bool(sides["puts"] & wants[entity])
            bad = bool(sides["puts"] & fears[entity]) or bool(sides["clears"] & wants[entity])
            # E i conteggi: una Pietra in piu' e' un aiuto per chi le conta,
            # una Cicatrice e' una minaccia per chi ne vuole zero, il
            # controllo e' l'una e l'altra a seconda di dove va.
            if "alza una pietra" in sides["does"] and "vuole pietre" in counts[entity]:
                good = True
            if "incide una cicatrice" in sides["does"] and "teme cicatrici" in counts[entity]:
                bad = True
            # **Il controllo non si conta come conflitto.** Ogni cambio di
            # controllo aiuta chi lo prende e danneggia chi lo perde: e' vero
            # per tutte e sessanta le carte, quindi non distingue niente. Con
            # dentro anche quello il conto diceva 0 Tensioni su 60 senza
            # conflitto — l'altro assoluto, e altrettanto muto.
            helped += 1 if good else 0
            threatened += 1 if bad else 0
            if (sides["puts"] | sides["clears"]) & watches[entity]:
                watched += 1
        # **Il conflitto che conta e' quello nominato.** Tutte e sessanta le
        # carte alzano una Pietra e incidono una Cicatrice — e' il modello
        # della faccia (D-280), non contenuto: conta chi ne ha una e chi no,
        # non chi ne ha una in generale. La lista raccoglie quindi le Tensioni
        # che **non toccano nessun segno che un Destino nomina**.
        if not ((sides["puts"] | sides["clears"]) & (
            set().union(*wants.values()) | set().union(*fears.values())
        )):
            no_conflict.append((tension_id, helped, threatened, watched))

    spoken = [(t, w) for t, w in orphans if str(dictionary[t].get("note", ""))]
    mute = [(t, w) for t, w in orphans if not str(dictionary[t].get("note", ""))]

    # 5. **Gli incroci** (la linea delle trasformazioni, punto 1).
    #
    # *«Gli stessi segni devono trasformare piu' Entita' in direzioni
    # diverse»*: e' la frase del committente, ed e' una cosa che si misura.
    # Per ogni segno si guarda **chi aiuta** e **chi danneggia** — profili
    # strategici e Destini insieme — e poi si guarda la scacchiera: fra due
    # case qualunque, esiste almeno un segno che spinge l'una da una parte e
    # l'altra dall'altra? Una coppia che non ne ha nemmeno uno non ha niente
    # per cui litigare, e al tavolo non si incontrera' mai.
    case = sorted(str(e.get("id", "")) for e in items("entities/*.json"))
    aiuta: Dict[str, Set[str]] = defaultdict(set)
    danneggia: Dict[str, Set[str]] = defaultdict(set)
    for entity in case:
        for tag in wants.get(entity, set()):
            aiuta[tag].add(entity)
        for tag in fears.get(entity, set()):
            danneggia[tag].add(entity)
    for profile in profiles:
        entity = str(profile.get("entity_id", ""))
        for voice in profile.get("wants", []) or []:
            aiuta[str(voice.get("tag", ""))].add(entity)
        for voice in profile.get("fears", []) or []:
            danneggia[str(voice.get("tag", ""))].add(entity)
        # `denies` e' un incrocio dichiarato a mano: A vuole impedire a B
        # proprio quel segno. Quindi quel segno aiuta B e danneggia A.
        for voice in profile.get("denies", []) or []:
            tag = str(voice.get("tag", ""))
            aiuta[tag].add(str(voice.get("to", "")))
            danneggia[tag].add(entity)

    # I segni che aprono una trasformazione: con D-290 la porta del tempo legge
    # i **voluti** del profilo, quindi perderli e' quello che cambia la pelle a
    # una casa. Un incrocio che tocca uno di questi non sposta una clausola:
    # sposta cosa quella casa diventera'.
    trasforma: Set[str] = set()
    porte: Dict[str, str] = {}
    for entity in items("entities/*.json"):
        for vita in entity.get("incarnations", []) or []:
            if not vita.get("also_enters"):
                continue
            porte[str(entity.get("id", ""))] = str(vita.get("name", ""))
    for profile in profiles:
        if str(profile.get("entity_id", "")) not in porte:
            continue
        for voice in profile.get("wants", []) or []:
            trasforma.add(str(voice.get("tag", "")))

    incroci: List[Tuple[str, List[str], List[str]]] = []
    for tag in sorted(set(aiuta) | set(danneggia)):
        pro = sorted(x for x in aiuta.get(tag, set()) if x in case)
        contro = sorted(x for x in danneggia.get(tag, set()) if x in case)
        if pro and contro and set(pro) != set(contro):
            incroci.append((tag, pro, contro))

    coppie_incrociate: Set[Tuple[str, str]] = set()
    per_coppia: Dict[Tuple[str, str], List[str]] = defaultdict(list)
    for tag, pro, contro in incroci:
        for uno in pro:
            for altro in contro:
                if uno == altro:
                    continue
                coppia = (min(uno, altro), max(uno, altro))
                coppie_incrociate.add(coppia)
                per_coppia[coppia].append(tag)
    tutte_le_coppie = {
        (case[i], case[j]) for i in range(len(case)) for j in range(i + 1, len(case))
    }
    coppie_mute = sorted(tutte_le_coppie - coppie_incrociate)

    numbers = {
        "segni": len(dictionary),
        # Solo i segni del dizionario: le leggende che il tempo fabbrica
        # (`legend:*`) sono penne, non voci, e contarle gonfiava il totale.
        "scritti": len([t for t in pens if t in dictionary]),
        "orfani": len(orphans),
        "orfani_muti": len(mute),
        "livelli": len(levels),
        "impossibili": len(impossible),
        "solo_conteggi": len(only_counts),
        "tensioni": len(tensions),
        "senza_conflitto": len(no_conflict),
        "toccano_un_segno_nominato": named_touch,
        "entrano_nei_conteggi": counted_touch,
        "eredita": len(carried),
        "profili": len(profiles),
        "desideri": sum(
            len(p.get("wants", []) or []) + len(p.get("fears", []) or [])
            for p in profiles
        ),
        "desideri_che_il_consiglio_sa_dare": sum(
            1 for p in profiles for v in (p.get("wants", []) or [])
            if str(v.get("tag", "")) in council_gives
        ),
        # **Quante carte aprono ancora una domanda che non e' loro** (0.1.272,
        # taglio 2 di ISSUES 80). Il criterio non e' l'id ma il **testo**: una
        # domanda che si legge identica su piu' carte e' una domanda in
        # prestito, e al tavolo suona come tale — «chi decide a chi non ne
        # tocca?» era la domanda di quindici questioni diverse.
        "carte_con_domanda_in_prestito": _borrowed_questions(),
        "incroci": len(incroci),
        "coppie_incrociate": len(coppie_incrociate),
        "coppie_totali": len(tutte_le_coppie),
    }

    lines: List[str] = []
    add = lines.append
    add("# Le tre misure che vengono prima della matrice")
    add("")
    add("Generato da `tools/matrix_survey.py` — non si scrive a mano.")
    add("")
    add("Le tre domande che il committente ha messo ai punti 8, 9 e 10 del suo")
    add("piano, misurate sui dati di oggi **prima** di scrivere un file nuovo.")
    add("")
    add("| | |")
    add("|---|---|")
    add("| segni nel dizionario | %d |" % numbers["segni"])
    add("| di cui qualcuno scrive | %d |" % numbers["scritti"])
    add("| orfani in tutto | %d |" % numbers["orfani"])
    add("| **di cui senza una ragione scritta** | **%d** |" % numbers["orfani_muti"])
    add("| livelli di Destino (minimo/vittoria/trionfo) | %d |" % numbers["livelli"])
    add("| **clausole impossibili** (chiedono un segno che niente scrive) | **%d** |" % numbers["impossibili"])
    add("| **livelli che si reggono solo su conteggi** | **%d** |" % numbers["solo_conteggi"])
    add("| Tensioni | %d |" % numbers["tensioni"])
    add("| **Tensioni che non toccano nessun segno nominato da un Destino** | **%d** |" % numbers["senza_conflitto"])
    add("| **carte che aprono ancora una domanda in prestito** | **%d** |" % (
        numbers["carte_con_domanda_in_prestito"]))
    add("| segni che l'eredita' porta avanti | %d |" % numbers["eredita"])
    add("| profili strategici scritti | %d |" % numbers["profili"])
    add("| segni che quelle case vogliono o temono | %d |" % numbers["desideri"])
    add("| **fra i voluti, quelli che un Consiglio sa dare** | **%d** |" % (
        numbers["desideri_che_il_consiglio_sa_dare"]))
    add("| segni che aiutano una casa e ne danneggiano un'altra | %d |" % numbers["incroci"])
    add("| **coppie di case che hanno qualcosa per cui litigare** | **%d su %d** |" % (
        numbers["coppie_incrociate"], numbers["coppie_totali"]))
    add("")
    add("---")
    add("")
    add("## 1. I segni orfani")
    add("")
    add("Un segno e' orfano se **qualcuno lo scrive** e poi nessuna Entita' lo")
    add("desidera o lo teme (Destini **e** obiettivi), nessuna Tensione lo mette")
    add("o lo toglie, e nessuna regola del segno lo usa: si posa sul tavolo e non")
    add("entra in nessuna partita.")
    add("")
    add("Non tutti gli orfani sono un difetto: **%d su %d portano gia' la loro" % (
        len(spoken), len(orphans)))
    add("ragione scritta** nel dizionario — memorie narrate (D-103), etichette di")
    add("famiglia, gradi di pietra, domini che legge il motore. Restano fuori")
    add("quelli **senza una riga che spieghi perche' esistono**: sono questi che")
    add("la matrice deve prendere per primi.")
    add("")
    add("### Orfani senza una ragione scritta: %d" % len(mute))
    add("")
    if not mute:
        add("Nessuno.")
    else:
        add("| segno | categoria | chi lo scrive |")
        add("|---|---|---|")
        for tag, who in mute:
            add("| `%s` | %s | %s |" % (
                tag, str(dictionary[tag].get("category", "")), who))
    add("")
    add("### Orfani dichiarati: %d" % len(spoken))
    add("")
    if spoken:
        add("| segno | la ragione che porta scritta |")
        add("|---|---|")
        for tag, _ in spoken:
            add("| `%s` | %s |" % (tag, str(dictionary[tag].get("note", ""))[:120]))
    add("")
    add("## 2. Gli obiettivi che non si possono puntare col dito")
    add("")
    add("Due difetti diversi. Il primo e' grave: una clausola chiede un segno che")
    add("**niente scrive**, e allora quel livello non si puo' raggiungere. Il")
    add("secondo e' di leggibilita': un livello che non nomina nessun segno e si")
    add("regge su conteggi — si verifica, ma al tavolo non si puo' indicare.")
    add("")
    add("**Clausole impossibili: %d**" % len(impossible))
    add("")
    if impossible:
        add("| Destino | livello | segno chiesto |")
        add("|---|---|---|")
        for destiny, level, tag in impossible:
            add("| %s | %s | `%s` |" % (destiny, level, tag))
        add("")
    add("**Livelli che si reggono solo su conteggi: %d su %d**" % (
        len(only_counts), len(levels)))
    add("")
    if only_counts:
        add("| Destino | livello | clausole | come si legge |")
        add("|---|---|---|---|")
        for level in only_counts:
            add("| %s | %s | %d | %s |" % (
                level["destiny"], level["level"], level["counted"],
                level["label"] or "—"))
        add("")
    add("## 4. Quanto di quello che una casa vuole, il tavolo sa darlo")
    add("")
    add("I profili strategici (`data/design_matrix`) dicono cosa una casa vuole")
    add("lasciare nel mondo. Qui si chiede se il tavolo abbia i mezzi: **chi puo'")
    add("dare quel segno** — un Consiglio vinto, una carta calata, una")
    add("Conseguenza — e chi puo' infliggere quello che teme. Una casa che vuole")
    add("cose che nessuno sa dare non ha una strategia: ha un desiderio.")
    add("")
    for profile in sorted(profiles, key=lambda p: str(p.get("entity_id", ""))):
        entity = str(profile.get("entity_id", ""))
        add("### %s" % entity)
        add("")
        add("> %s" % str(profile.get("in_one_line", "")))
        add("")
        add("| | segno | dal Consiglio | da una carta | altrimenti |")
        add("|---|---|---|---|---|")
        for field, mark in (("wants", "vuole"), ("fears", "teme")):
            for voice in profile.get(field, []) or []:
                tag = str(voice.get("tag", ""))
                from_council = tag in council_gives if field == "wants" else tag in council_inflicts
                from_card = "Azione stampata" in pens.get(tag, set())
                other = sorted(pens.get(tag, set()) - {"Azione stampata"})
                add("| %s | `%s` | %s | %s | %s |" % (
                    mark, tag,
                    "**si'**" if from_council else "no",
                    "**si'**" if from_card else "no",
                    ", ".join(other) if other else "—",
                ))
        add("")
    add("## 3. Le Tensioni che non incontrano nessun Destino")
    add("")
    add("Una Tensione ha conflitto se **aiuta qualcuno e minaccia qualcun altro**:")
    add("aiuta chi vede sparire un segno che teme o comparire uno che vuole,")
    add("minaccia chi vede il contrario. Senza conflitto, al Consiglio nessuno")
    add("avrebbe una ragione per opporsi.")
    add("")
    add("**E qui c'e' il numero che vale il viaggio.** Tutte e %d le Tensioni" % len(tensions))
    add("hanno un conflitto *strutturale* — la loro faccia alza una Pietra e")
    add("incide una Cicatrice, e i Destini contano l'una e l'altra — ma quel")
    add("conflitto e' **identico su tutte**: e' il modello della faccia (D-280),")
    add("non e' contenuto. Il conflitto che distingue una questione dall'altra e'")
    add("quello **nominato**, e li' il conto e' **%d su %d**." % (
        len(tensions) - named_touch, len(tensions)))
    add("")
    add("**Il conto e' un pavimento**: guarda i segni che la faccia della carta")
    add("posa e toglie, non il controllo, non il Calore, non chi ci guadagna in")
    add("voti. Una Tensione che compare qui e' certamente muta; una che non")
    add("compare non e' certamente viva. La colonna **la guarda** conta le case")
    add("il cui Destino dichiara di osservare uno dei suoi segni (`observes`,")
    add("D-270): un interesse c'e', ma non e' ancora un conflitto.")
    add("")
    if not no_conflict:
        add("Nessuna: ogni Tensione aiuta qualcuno e minaccia qualcun altro.")
    else:
        add("| Tensione | aiuta | minaccia | la guarda |")
        add("|---|---|---|---|")
        for tension_id, helped, threatened, watched in no_conflict:
            add("| %s | %d | %d | %d |" % (tension_id, helped, threatened, watched))
    add("")
    add("## 5. Gli incroci: chi litiga con chi, e per cosa")
    add("")
    add("*«Gli stessi segni devono trasformare piu' Entita' in direzioni")
    add("diverse»* — la linea delle trasformazioni. Qui si misura sui dati di")
    add("oggi: per ogni segno, **chi aiuta** e **chi danneggia**, mettendo")
    add("insieme quello che i Destini chiedono e quello che i profili")
    add("dichiarano. Un segno che aiuta qualcuno e non danneggia nessuno non e'")
    add("una questione: e' un regalo, e al Consiglio nessuno avra' mai una")
    add("ragione per opporsi.")
    add("")
    add("**Segni che incrociano davvero: %d.**" % len(incroci))
    add("")
    add("**Il conto e' un pavimento**, come quello delle Tensioni: guarda i")
    add("segni **nominati** da un Destino o da un profilo, non i conteggi. Un")
    add("Destino che chiede due Pietre o zero Cicatrici entra in conflitto con")
    add("mezzo tavolo senza nominare niente — ma quel conflitto vale per tutti")
    add("allo stesso modo, e quindi non distingue una coppia dall'altra. Qui")
    add("interessa **cosa fa litigare queste due case e non altre**.")
    add("")
    add("La colonna **cambia pelle** dice se quel segno e' fra quelli che una")
    add("porta del tempo legge (D-290): perderlo non sposta una clausola, sposta")
    add("**cosa quella casa diventera'**.")
    add("")
    if not incroci:
        add("Nessuno: nessun segno aiuta una casa e ne danneggia un'altra.")
    else:
        add("| segno | aiuta | danneggia | cambia pelle | chi lo sa scrivere |")
        add("|---|---|---|---|---|")
        for tag, pro, contro in sorted(
            incroci, key=lambda r: (-len(r[1]) * len(r[2]), r[0])
        ):
            add("| `%s` | %s | %s | %s | %s |" % (
                tag,
                ", ".join(x.replace("ENT_", "") for x in pro),
                ", ".join(x.replace("ENT_", "") for x in contro),
                "**si'**" if tag in trasforma else "—",
                ", ".join(sorted(pens.get(tag, set()))) or "**nessuno**",
            ))
    add("")
    add("### Le coppie che non hanno niente per cui litigare")
    add("")
    add("Il controllo che la linea delle trasformazioni chiede: **due case")
    add("devono condividere almeno un segno che le spinge in direzioni")
    add("opposte**. Le coppie che non ce l'hanno possono sedere allo stesso")
    add("tavolo per otto anni senza incontrarsi mai.")
    add("")
    add("**Coppie incrociate: %d su %d.**" % (len(coppie_incrociate), len(tutte_le_coppie)))
    add("")
    senza_profilo = sorted(
        x.replace("ENT_", "") for x in case
        if x not in {str(p.get("entity_id", "")) for p in profiles}
    )
    if senza_profilo:
        add("La causa si legge nella tabella qui sopra: **gli incroci esistono")
        add("quasi solo fra le case che hanno un profilo**. Le altre — %s —" % (
            ", ".join(senza_profilo)))
        add("entrano solo dove un loro Destino nomina un segno per nome, e i")
        add("Destini nominano poco: %d livelli su %d si reggono su conteggi." % (
            len(only_counts), len(levels)))
        add("Scrivere i profili che mancano (ISSUES 79) e' la leva piu' corta su")
        add("questo numero.")
    else:
        add("**Tutte le case hanno un profilo**, quindi quello che resta non e'")
        add("piu' un buco di dichiarazioni: e' la superficie. Un incrocio")
        add("richiede che **lo stesso segno** sia nominato da una casa come")
        add("voluto e da un'altra come temuto, e ogni casa ne nomina otto o")
        add("nove; il resto di quello che i Destini chiedono sono conteggi —")
        add("%d livelli su %d — che litigano con tutti allo stesso modo." % (
            len(only_counts), len(levels)))
        add("Le coppie ancora mute si chiudono in due modi: **una faccia di")
        add("Tensione** che metta uno di quei segni sul tavolo dove le due case")
        add("si incontrano, oppure **un `denies`** scritto — che e' un incrocio")
        add("dichiarato a mano, e costa una riga.")
    add("")
    if not coppie_mute:
        add("Nessuna coppia resta muta: ogni casa ha una questione con ogni altra.")
    else:
        add("| coppia | |")
        add("|---|---|")
        for uno, altro in coppie_mute:
            add("| %s ↔ %s | niente |" % (
                uno.replace("ENT_", ""), altro.replace("ENT_", "")))
    add("")
    add("### Quante questioni ha ogni coppia")
    add("")
    add("| coppia | segni condivisi | quali |")
    add("|---|---|---|")
    for coppia in sorted(per_coppia, key=lambda c: (-len(set(per_coppia[c])), c)):
        segni = sorted(set(per_coppia[coppia]))
        add("| %s ↔ %s | %d | %s |" % (
            coppia[0].replace("ENT_", ""), coppia[1].replace("ENT_", ""),
            len(segni), ", ".join("`%s`" % t for t in segni[:6])
            + (" …" if len(segni) > 6 else ""),
        ))
    add("")
    return "\n".join(lines) + "\n", numbers


def main() -> int:
    text, numbers = survey()
    check = "--check" in sys.argv
    if check:
        if not DOC.exists() or DOC.read_text(encoding="utf-8") != text:
            print("FAIL  docs/MISURA_MATRICE.md non e' piu' quello che i dati producono:")
            print("      rilancia `python3 tools/matrix_survey.py`.")
            return 1
        print("OK  le tre misure combaciano coi dati.")
        return 0
    DOC.write_text(text, encoding="utf-8")
    print("scritto %s" % DOC.relative_to(REPO))
    for key, value in numbers.items():
        print("  %-16s %d" % (key, value))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
