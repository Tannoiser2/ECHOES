#!/usr/bin/env python3
"""Generate docs/REGISTRO_SEGNI.md from godot/data and godot/scripts.

Un segno sulla mappa ha senso solo se qualcosa lo legge: se cambia cosa puoi
fare adesso, se cambia un Consiglio, se decide quali domande nascono l'anno
dopo, se conta per un obiettivo, o se attraversa le ere. Un segno che nessuno
legge non e' una regola: e' colore travestito da regola, ed e' la stessa frase
che D-035 e ISSUES 56 hanno gia' scritto due volte su altro contenuto.

Questo strumento fa il conto e non lo lascia invecchiare:

    python3 tools/build_sign_registry.py           # riscrive il registro
    python3 tools/build_sign_registry.py --check   # esce 1 se e' fuori passo

`--check` va rosso in tre casi, e sono tre difetti diversi:

  1. il documento non e' piu' quello che i dati producono;
  2. e' comparso un segno muto che non e' fra quelli dichiarati qui sotto;
  3. un segno dichiarato muto ha smesso di esserlo — cosi' l'elenco non marcisce.

I muti noti stanno in MUTI_NOTI, ognuno con la sua ragione. E' la regola di casa:
un numero peggiorato e scritto vale piu' di un numero nascosto. L'elenco si
accorcia quando qualcuno li fa mordere, o quando si tolgono.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, Iterable, List, Set

from echoes_schema import DATA_DIR, REPO_ROOT

REGISTRY = REPO_ROOT / "docs" / "REGISTRO_SEGNI.md"
SCRIPTS = REPO_ROOT / "godot" / "scripts"

# I livelli di rapporto viaggiano nella stessa chiave `tag` delle regole del
# segno, ma non sono segni: sono i gradini di `RELATION_ORDER`. Senza questa
# riga il registro li elencava come clausole impossibili.
LIVELLI_DI_RAPPORTO = {"ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND", "BLOOD", "PACT"}

WRITE_TYPES = {"SET_REGION_TAG", "SET_GLOBAL_TAG", "SET_ENTITY_TAG"}
CLEAR_TYPES = {"REMOVE_REGION_TAG", "REMOVE_GLOBAL_TAG", "REMOVE_ENTITY_TAG"}

# I segni che oggi nessuno legge, con la ragione per cui sono ancora qui.
# Toglierne uno da questa lista senza farlo mordere fa andare rossa la prova.
#
# **Erano dieci, e quattro non lo erano mai stati** (D-234). Il registro non
# guardava tre penne che leggono — la Regione di cui si discute
# (`focus_region_tags`), chi siede l'anno prossimo (`entry_tag`), e la catena
# delle ere (`if_tag`) — e dichiarava muti dei segni che decidono il bersaglio
# di un Consiglio e perfino chi si siede al tavolo.
#
# Dei sei che restano, accanto alla ragione c'e' **quante volte escono in 100
# anni**, misurato da `godot/cli/run_mute_signs.gd`. ISSUES 61 lo chiedeva:
# «un segno muto che compare due volte in un secolo e' un problema minore di uno
# che compare duecento».
MUTI_NOTI: Dict[str, str] = {
    "account_settled": "«Il Conto Saldato» chiude un debito e nessuna regola lo sa — 4 volte in 100 anni",
    "burden_shared": "il peso diviso non alleggerisce niente — 2 volte in 100 anni",
    # Memorie del mondo che il Consiglio scrive e che nessuna regola interroga
    # (D-103, D-286): restano perche' il tavolo le legge — sono la cronaca
    # dell'anno, non un requisito. Chi vuole farle mordere le aggiunge agli
    # echi della loro domanda, come D-286 ha fatto con tredici sorelle.
    "list_witnessed": "la lista letta davanti a testimoni: memoria narrata, nessuna regola la chiede",
    "someone_paid": "qualcuno ha pagato: il marchio di una decisione passata al prezzo di chi non c'e' piu' — si legge al centro del tavolo, non in una regola (D-278)",
    "return_promised": "il ritorno promesso: memoria narrata, e la promessa non ha ancora una regola",
    "dragon_slain": "«Il Drago Abbattuto» — e il mondo non se ne accorge. Non esce mai in 100 anni: la Conseguenza non e' mai stata scelta (ISSUES 56)",
    "settlement:$proponent": "chi ci vive, scritto sulla mappa: la regola e' la pietra che la Conseguenza alza accanto — 50 volte in 100 anni",
    # I marchi che la pedina del prezzo lascia (D-278). Nascono col loro posto
    # sul tavolo — sulla tessera, sulla carta del casato, al centro — e per ora
    # nessuna clausola del motore li interroga: e' dichiarato qui e nel
    # dizionario, e la Fase B decidera' se farli mordere o toglierli.
    "hard_bargain": "la parola fredda: si legge sulla carta del casato, nessuna clausola la chiede (D-278)",
    "price_in_lives": "il conto in vite: memoria del mondo, nessuna clausola la chiede (D-278)",
    "spoke_and_lost": "ha proposto e la proposta e' caduta: si legge sulla carta del casato (D-278)",
    "took_by_hand": "si e' servito senza aspettare la decisione: si legge sulla carta del casato (D-278)",
    "watched": "sotto osservazione: chi ha imposto la guardia se lo porta addosso (D-278)",
}


# --- lettura dei dati -------------------------------------------------------

def items(schema_id: str) -> List[Dict[str, Any]]:
    """Tutte le voci dei documenti che dichiarano quello `schema_id`.

    Si sceglie per **schema, non per percorso**, e la ragione e' pagata: fino
    alla 0.1.291 questa funzione prendeva un glob, e tre chiamate nominavano una
    cartella di Chronicle (`chronicle_*/confluences/*.json`). Spostando i
    template dove il loro nome non mentiva piu' (ISSUES 99), il registro ha
    smesso di vederli e ha dichiarato **otto clausole impossibili** che non lo
    erano. Un documento adesso si trova per quello che dice di essere, cosi'
    nessun rinomino puo' renderlo invisibile in silenzio.
    """
    out: List[Dict[str, Any]] = []
    for path in sorted(DATA_DIR.rglob("*.json")):
        with path.open(encoding="utf-8") as handle:
            document = json.load(handle)
        if str(document.get("schema_id", "")) != schema_id:
            continue
        out.extend(document.get("items", []))
    return out


def tags_in_effects(effects: Iterable[Any]) -> Iterable[tuple]:
    for effect in effects or []:
        if not isinstance(effect, dict):
            continue
        kind = str(effect.get("type", ""))
        tag = str((effect.get("payload") or {}).get("tag", ""))
        if not tag:
            continue
        if kind in WRITE_TYPES:
            yield ("scrive", tag)
        elif kind in CLEAR_TYPES:
            yield ("cancella", tag)


def walk_conditions(conditions: Iterable[Any], sink: Set[str]) -> None:
    """Ogni stringa che una condizione confronta con un segno."""
    for condition in conditions or []:
        if not isinstance(condition, dict):
            continue
        for key in ("tag", "state_tag"):
            value = condition.get(key)
            if (isinstance(value, str) and value and not value.startswith("$")
                    and value not in LIVELLI_DI_RAPPORTO):
                sink.add(value)
        for nested in ("conditions", "all", "any", "clauses"):
            if isinstance(condition.get(nested), list):
                walk_conditions(condition[nested], sink)


# I segni che il **codice** scrive, non i dati. Senza questa riga il registro
# direbbe che `function:LACK` o `life:INC_ALDRIC_02` sono chiesti da qualcuno e
# scritti da niente — e sarebbero dodici falsi allarmi su una sezione che serve
# a trovare le clausole impossibili.
# E i segni che il codice scrive **col loro nome intero**, non per prefisso.
# `twice_uprooted` lo posa `confluence_controller` alla seconda cacciata, ed e'
# la porta della Diaspora: senza questa riga il registro lo chiamava una
# clausola impossibile e diceva che quella vita non si puo' raggiungere.
SCRITTI_DAL_CODICE_ESATTI: Dict[str, str] = {
    "twice_uprooted": "confluence_controller.gd — la seconda cacciata diventa una natura",
}

SCRITTI_DAL_CODICE: Dict[str, str] = {
    "legend:": "world_state_factory.gd — un fatto che sbiadisce diventa leggenda",
    "evicted:": "confluence_controller.gd — la cacciata da una Regione",
    "function:": "chronicle_controller.gd — la funzione di Propp della carta Echo uscita",
    "life:": "succession.gd — l'incarnazione che siede quest'anno",
}


# I prefissi che il **codice** legge, e se quella lettura morde o no.
#
# Una scansione automatica dei `begins_with("x:")` non basta, perche' leggere un
# segno e agire su un segno sono due cose diverse. Qui il giudizio e' scritto a
# mano, una riga per prefisso, e la ragione sta accanto: se domani il codice
# cambia, la prova `--check` se ne accorge dal conto dei muti e questa tabella
# va riletta.
PREFISSI: Dict[str, tuple] = {
    "discovery:": (True,
        "`condition_evaluator` li conta tutti insieme per `discovery_count`, "
        "e quella condizione la chiedono Destini e obiettivi"),
    "evicted:": (True,
        "`world_state_service` lo controlla per impedire il rientro nella Regione"),
    "legend:": (True,
        "`world_state_factory` trasforma in leggenda un fatto che sbiadisce, "
        "e la pesca delle domande legge le leggende"),
    "condition:": (False,
        "il prefisso lo guarda solo la traversata delle ere, per decidere se il "
        "segno sbiadisce: e' quanto dura, non cosa fa. Una singola `condition:` "
        "morde se una regola, un obiettivo o la pesca la nominano"),
    "function:": (False,
        "contabilita' del libro della Cronaca: non tocca nessuna partita"),
    "settlement:": (False,
        "lo leggono solo `effect_text` e `sign_labels`: disegnano una parola"),
    "life:": (False,
        "solo `effect_text`: disegna una parola"),
}


def prefix_readers() -> Dict[str, List[str]]:
    """I prefissi che il codice legge davvero, con i file che li leggono.

    Serve a due cose insieme: dare al registro il nome dei lettori, e accorgersi
    se un prefisso compare nel codice senza che PREFISSI dica cosa farne.
    """
    printers = {"effect_text.gd", "sign_labels.gd", "effect_narrator.gd", "narrative_text.gd"}
    found: Dict[str, List[str]] = defaultdict(list)
    for path in sorted(SCRIPTS.rglob("*.gd")):
        if path.name in printers:
            continue
        text = path.read_text(encoding="utf-8")
        for line in text.splitlines():
            code = line.split("#", 1)[0]
            for match in re.finditer(r'begins_with\("([a-z_]+:)"\)', code):
                found[match.group(1)].append(path.name)
    return {prefix: sorted(set(names)) for prefix, names in found.items()}


def collect() -> Dict[str, Dict[str, Set[str]]]:
    signs: Dict[str, Dict[str, Set[str]]] = defaultdict(
        lambda: {"scrive": set(), "posa": set(), "cancella": set(), "legge": set()}
    )

    def note(tag: str, role: str, who: str) -> None:
        signs[tag][role].add(who)

    for consequence in items("consequence"):
        for role, tag in tags_in_effects(consequence.get("effects")):
            note(tag, role, "Conseguenza")
        # Una cicatrice non e' un Effetto come gli altri: la Conseguenza la
        # dichiara a parte, e il suo tag finisce sulla Regione lo stesso.
        # Una cicatrice non e' un Effetto come gli altri: la Conseguenza la
        # dichiara a parte, finisce in `world.scars`, e **morde per il fatto di
        # esistere** — `scar_count` la conta, e ventidue clausole fra obiettivi e
        # Destini chiedono quel conto. Il suo nome invece non lo legge nessuno,
        # ed e' voluto: una cicatrice pesa come cicatrice, non per come si chiama.
        scar = str((consequence.get("scar") or {}).get("tag", ""))
        if scar:
            note(scar, "scrive", "Conseguenza (cicatrice)")
            note(scar, "legge", "conteggio delle cicatrici (`scar_count`)")
    for card in items("asset"):
        for role, tag in tags_in_effects(card.get("on_commit_effects")):
            note(tag, role, "carta Asset")
        # **La faccia della carta e' una penna** (D-283): da quando il motore
        # esegue `puts_tag` e `clears_tag` delle Azioni stampate, quei segni
        # finiscono sul mondo per davvero. Prima erano inchiostro, e il registro
        # aveva ragione a non contarli; adesso contarli e' l'unico modo di non
        # dire il falso.
        face = card.get("physical") or {}
        for action in face.get("actions", []) or []:
            for tag in (action or {}).get("puts_tag", []) or []:
                note(str(tag), "scrive", "Azione stampata")
            for tag in (action or {}).get("clears_tag", []) or []:
                note(str(tag), "cancella", "Azione stampata")
        resonance = face.get("resonance") or {}
        if resonance.get("extra_tag"):
            note(str(resonance["extra_tag"]), "scrive", "Risonanza")
        # E la faccia **legge** quanto scrive: il bersaglio si dice a segni
        # (D-274) e la Risonanza guarda il segno che teme. Insegnare al
        # registro solo la penna e non l'occhio avrebbe dichiarato muti dei
        # segni che una carta interroga a ogni giocata.
        if resonance.get("if_target_tag"):
            note(str(resonance["if_target_tag"]), "legge", "Risonanza")
        target = face.get("target") or {}
        for campo in ("any_tag", "forbidden_tag"):
            for tag in target.get(campo, []) or []:
                note(str(tag), "legge", "bersaglio a segni")
    for echo in items("echo_card"):
        for hook in echo.get("effect_hooks", []) or []:
            payload: Any = [hook]
            if isinstance(hook, dict):
                # Un gancio porta `effects` (piu' d'uno) **oppure** `effect`
                # (uno solo). La seconda forma non veniva guardata, e due
                # memorie — «ci si e' parlato», «la richiesta e' stata
                # ascoltata» — risultavano chieste da una Risonanza e scritte
                # da nessuno (D-286).
                if "effects" in hook:
                    payload = hook["effects"]
                elif "effect" in hook:
                    payload = [hook["effect"]]
            for role, tag in tags_in_effects(payload):
                note(tag, role, "carta Echo")

    def readers(conditions: Any, who: str) -> None:
        sink: Set[str] = set()
        walk_conditions(conditions, sink)
        for tag in sink:
            note(tag, "legge", who)

    for objective in items("objective"):
        readers(objective.get("conditions"), "obiettivo")
    for destiny in items("destiny"):
        for level in ("minimum", "victory", "triumph"):
            readers((destiny.get(level) or {}).get("conditions"), "Destino")
    for rule in items("tag_rule"):
        when = rule.get("when")
        readers([when] if isinstance(when, dict) else when, "regola del segno")
    for echo in items("echo_card"):
        readers(echo.get("eligibility"), "carta Echo")
    for consequence in items("consequence"):
        readers(consequence.get("eligibility"), "Conseguenza")
    for template in items("confluence_template"):
        for proposition in template.get("propositions", []) or []:
            readers(proposition.get("eligibility"), "proposta")
            readers(proposition.get("conditions"), "proposta")
        # **La penna del Consiglio** (D-286): una clausola vinta posa i
        # suoi segni sul mondo — l'amnistia concessa, la Carta che vale
        # per un tempo solo, la successione con testimoni. Il registro
        # non guardava qui, e quelle memorie risultavano scritte da
        # nessuno: un allarme falso su contenuto sano, che si e' visto
        # solo il giorno in cui qualcuno ha cominciato a leggerle.
        for clause in template.get("condition_clauses", []) or []:
            for role, tag in tags_in_effects((clause or {}).get("effects")):
                note(tag, role, "clausola di Consiglio")
    # Le altre tre penne che scrivono sul mondo, e che una scansione dei soli
    # Effetti non vede: l'apertura della Chronicle, le Regioni come nascono, e
    # le **catene** — un fatto che si ripete di era in era avanza di un gradino
    # e posa un segno nuovo. `mountain_forgotten` arriva da li', e senza questa
    # riga il registro lo chiamava una clausola impossibile.
    # **Le pietre scrivono i propri segni, grado per grado.** Un Presidio di
    # primo grado posa `structure:watchtower`, e alzato di un grado posa
    # `settlement:city`: e' cosi' che undici regole del segno trovano il segno
    # che aspettano. Senza questa penna il registro le dichiarava tutte
    # impossibili, che sarebbe stato un allarme falso su contenuto sano.
    for structure in items("structure_type"):
        for grade in structure.get("grades", []) or []:
            tag = str((grade or {}).get("tag", ""))
            if tag:
                note(tag, "posa", "pietra «%s» al grado «%s»" % (
                    structure.get("name", structure.get("id", "?")), grade.get("name", "?")
                ))
        ruin = str((structure.get("ruin") or {}).get("tag", ""))
        if ruin:
            note(ruin, "posa", "pietra «%s» in rovina" % structure.get("name", "?"))
    for region in items("region"):
        for tag in region.get("tags", []) or []:
            note(str(tag), "posa", "Regione all'apertura")
    for chronicle in items("chronicle"):
        for tag in chronicle.get("global_tags", []) or []:
            note(str(tag), "posa", "Chronicle all'apertura")
        for tally in chronicle.get("era_tallies", []) or []:
            for tag in tally.get("chain", []) or []:
                note(str(tag), "posa", "catena delle ere")
    # **Tre penne che leggono, e che una scansione delle sole condizioni non
    # vede.** Sono la ragione per cui questo registro ha detto per due versioni
    # che dieci segni erano muti: non guardava dove il gioco li legge davvero.
    #
    # 1. `focus_region_tags` di una Tensione decide **di quale Regione parla il
    #    Consiglio**. Non e' colore: e' il bersaglio. Una Regione contesa tira
    #    su di se' il Consiglio sulla Successione, e chi la rende contesa lo sa.
    for tension in items("tension"):
        for tag in tension.get("focus_region_tags", []) or []:
            note(str(tag), "legge", "la Regione di cui si discute")
    # 2. `entry_tag` e `entry_forbidden_tag` di una vita decidono **chi siede
    #    l'anno prossimo**: e' il morso piu' forte che ci sia in questo gioco,
    #    perche' cambia il giocatore e non una modifica. `heir_named` sta li'.
    for entity in items("entity"):
        for life in entity.get("incarnations", []) or []:
            for key, why in (
                ("entry_tag", "chi siede l'anno prossimo"),
                ("entry_forbidden_tag", "chi **non** siede l'anno prossimo"),
            ):
                tag = str((life or {}).get(key, ""))
                if tag:
                    # La forma qualificata `segno@REG_ID` (D-131) chiede lo
                    # stesso segno, ma solo su quella Regione: chi lo scrive e'
                    # sempre chi scrive il segno nudo. Senza questa riga il
                    # registro contava due clausole impossibili che non lo sono.
                    note(tag.split("@", 1)[0], "legge", why)
    # 3. `if_tag` e `if_not_tag` di una catena delle ere decidono se la catena
    #    avanza: il segno di quest'anno sceglie il segno di fra dieci.
    for chronicle in items("chronicle"):
        for tally in chronicle.get("era_tallies", []) or []:
            for key in ("if_tag", "if_not_tag"):
                tag = str((tally or {}).get(key, ""))
                if tag:
                    note(tag, "legge", "catena delle ere")
    for chronicle in items("chronicle"):
        for fact in chronicle.get("enduring_facts", []) or []:
            note(str(fact), "legge", "fatto che dura")
        echoes = (chronicle.get("tension_pool") or {}).get("echoes") or {}
        for signals in echoes.values():
            for signal in signals:
                signal = str(signal)
                if signal.startswith("structure:"):
                    continue
                note(signal, "legge", "pesca delle domande")

    # I prefissi letti dal codice: quello che una scansione dei nomi non vede.
    # Solo quelli che PREFISSI dichiara mordenti — leggere non e' agire.
    # **Una leggenda e' il segno di prima, un'era dopo.** `world_state_factory`
    # trasforma in `legend:<fatto>` ogni fatto globale che sbiadisce, e se
    # qualcuno chiede quella leggenda allora il fatto morde — non quest'anno,
    # nel prossimo. Senza questa riga il registro chiamava muto
    # `order_restored`, che invece torna come leggenda ed e' letto da una carta
    # Echo e da una proposta.
    for tag in list(signs):
        if signs["legend:%s" % tag]["legge"] if ("legend:%s" % tag) in signs else False:
            note(tag, "legge", "leggenda (un'era dopo)")

    readers_by_prefix = prefix_readers()
    for prefix, files in readers_by_prefix.items():
        bites, _why = PREFISSI.get(prefix, (False, ""))
        if not bites:
            continue
        for tag in list(signs):
            if tag.startswith(prefix):
                note(tag, "legge", "codice (%s)" % ", ".join(files))

    return signs


# --- il documento -----------------------------------------------------------

HEADER = """# ECHOES — il registro dei segni

<!-- FILE GENERATO — si rifa' con `python3 tools/build_sign_registry.py`. -->

Ogni segno che le Conseguenze, le carte Asset e le carte Echo scrivono sul
mondo, e **chi lo legge**.

Un segno ha senso solo se qualcosa se ne accorge: se cambia cosa puoi fare
adesso (una *regola del segno*), se cambia un Consiglio (una *proposta*), se
decide quali domande nascono l'anno dopo (la *pesca delle domande*), se conta
per un *obiettivo* o per un *Destino*, o se attraversa le ere (un *fatto che
dura*). Un segno che nessuno legge non e' una regola: e' colore travestito da
regola.

Le colonne dicono chi scrive, chi cancella e chi legge. «codice» vuol dire che
il segno e' letto **per prefisso** da una regola del motore — `discovery:` per
esempio si conta tutto insieme, e i nomi singoli non compaiono in nessun dato.
Le viste che si limitano a **stampare** un segno sullo schermo non contano come
lettori: disegnare non e' mordere.
"""


# Le clausole impossibili ancora tollerate, con la ragione. Oggi non ce ne sono,
# e quello zero e' un cancello: vedi `impossibili()`.
CHIESTI_NOTI: Dict[str, str] = {
    # Il bersaglio a segni di «Pedaggio» nomina la strada, e la strada non e' un
    # segno che qualcuno posa: il motore la conta dalle strutture sulla mappa
    # (lo dice anche il dizionario). Visibile solo da D-286, da quando il
    # registro sa che una faccia di carta legge.
    "structure:road": "la strada non e' un segno posato: il motore la conta dalle strutture sulla mappa",
}


def impossibili(signs: Dict[str, Dict[str, Set[str]]]) -> List[str]:
    """Il difetto specchio del segno muto.

    Una condizione che nomina un segno che **niente scrive** non e' una
    condizione difficile: e' una condizione impossibile, e chi la legge al
    tavolo non ha modo di saperlo. `scar:burned` e' stata cosi' per due
    versioni — la Tensione della Successione preferiva una Regione bruciata, e
    nessuna Regione poteva bruciare (D-234).
    """
    return sorted(
        t for t, r in signs.items()
        if r["legge"] and not (r["scrive"] or r["cancella"])
        and not r["posa"]
        and t not in SCRITTI_DAL_CODICE_ESATTI
        and not any(t.startswith(prefix) for prefix in SCRITTI_DAL_CODICE)
    )


POSTI: List[tuple] = [
    ("TILE_PRINTED", "stampato sulla tessera",
     "la natura del luogo: montagna, capitale, pascolo. Non cambia mai."),
    ("TILE_SLOT", "uno spazio sulla tessera",
     "dove si posa una Pietra, e i gradi che la degradano: bosco, bosco rado, selva maledetta."),
    ("ZONE_TOKEN", "un gettone accanto alla tessera",
     "lo stato di adesso: affamata, chiusa, in rivolta. Si mette e si toglie."),
    ("SCAR_TOKEN", "un dischetto rotondo",
     "le Cicatrici. Non tornano nella riserva."),
    ("HOUSE_SHEET", "sulla scheda della casa",
     "chi sei adesso: incoronato, dormiente, decaduto, e la vita che stai vivendo."),
    ("WORLD_MEMORY", "un gettone sul bordo della mappa",
     "quello che il mondo ricorda: sta dove sta il mondo, non su un luogo (D-351)."),
    ("NONE", "il tavolo non lo mostra",
     "contabilita' che il motore usa e nessuna fustella taglia."),
]


def posti() -> Dict[str, str]:
    """Il posto fisico dichiarato da ogni voce del dizionario (D-350)."""
    return {str(v["id"]): str(v.get("table_place", "?")) for v in items("tag")}


def sezione_del_tavolo(signs: Dict[str, Dict[str, Set[str]]], dove: Dict[str, str]) -> List[str]:
    """Quanti segni per ogni posto del tavolo, e quanti di quelli sono muti.

    E' la domanda del committente detta coi numeri: *«non devono essere 200 con
    alcuni che non vengono mai posati o letti».* Il conto per posto dice dove
    la scatola pesa troppo, e dove pesa a vuoto.
    """
    lines = ["## Il tavolo: dove sta ogni segno", "",
             "Ogni segno del dizionario nel posto fisico dove lo prendi in mano.",
             "L'ultima colonna e' quella che conta: **segni che qualcosa scrive e",
             "nessuno legge**, contati posto per posto.", "",
             "| posto | segni | scritti sul mondo | di cui muti | cos'e' |",
             "|---|---|---|---|---|"]
    for chiave, nome, spiega in POSTI:
        del_posto = [t for t, p in dove.items() if p == chiave]
        scritti = [t for t in del_posto
                   if t in signs and (signs[t]["scrive"] or signs[t]["cancella"])]
        muti = [t for t in scritti if not signs[t]["legge"]]
        lines.append("| **%s** | %d | %d | %s | %s |" % (
            nome, len(del_posto), len(scritti),
            ("**%d**" % len(muti)) if muti else "—", spiega))
    senza = sorted(t for t, p in dove.items() if p == "?")
    lines.append("")
    if senza:
        lines.append("> **%d segni senza un posto dichiarato:** %s"
                     % (len(senza), ", ".join("`%s`" % t for t in senza)))
    else:
        fisici = sum(1 for p in dove.values() if p != "NONE")
        lines.append("Ogni segno ha un posto. **%d stanno sul tavolo**, %d sono contabilita'."
                     % (fisici, len(dove) - fisici))
    lines.append("")
    lines.append("---")
    lines.append("")
    return lines


def render(signs: Dict[str, Dict[str, Set[str]]]) -> str:
    written = {t: r for t, r in signs.items() if r["scrive"] or r["cancella"]}
    mute = sorted(t for t, r in written.items() if not r["legge"])
    speaking = sorted(t for t, r in written.items() if r["legge"])
    asked = impossibili(signs)

    lines: List[str] = [HEADER, ""]
    lines.append("**%d segni scritti sul mondo: %d li legge qualcosa, %d no.**"
                 % (len(written), len(speaking), len(mute)))
    lines.append("")
    lines.append("**E %d segni li chiede qualcuno senza che niente li scriva.**"
                 % len(asked))
    lines.append("")
    lines.append("---")
    lines.append("")
    dove = posti()
    lines.extend(sezione_del_tavolo(signs, dove))
    lines.append("## I segni muti")
    lines.append("")
    if not mute:
        lines.append("Nessuno: ogni segno scritto sul mondo viene letto da qualcosa.")
    else:
        lines.append("Scritti da qualcosa, letti da niente. Ognuno e' una carta o una")
        lines.append("Conseguenza che promette un cambiamento che il gioco non registra.")
        lines.append("")
        lines.append("| segno | sul tavolo sta | chi lo scrive | perche' e' ancora qui |")
        lines.append("|---|---|---|---|")
        for tag in mute:
            who = sorted(signs[tag]["scrive"] | signs[tag]["cancella"])
            nome = next((n for k, n, _ in POSTI if k == dove.get(tag)), "—")
            lines.append("| `%s` | %s | %s | %s |" % (
                tag, nome, ", ".join(who), MUTI_NOTI.get(tag, "**non dichiarato**")
            ))
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## I segni che nessuno scrive")
    lines.append("")
    if not asked:
        lines.append("Nessuno: tutto quello che una condizione chiede, qualcosa lo puo' scrivere.")
    else:
        lines.append("Una condizione li nomina, e nessun Effetto li mette sul mondo. Alcuni")
        lines.append("arrivano dall'apertura di una Chronicle o dal mondo ereditato — e allora")
        lines.append("sono legittimi; altri sono clausole che **nessuno puo' soddisfare**.")
        lines.append("")
        lines.append("I segni che scrive il **codice** e non i dati non compaiono qui: %s."
                     % ", ".join("`%s` (%s)" % (p, why) for p, why in sorted(SCRITTI_DAL_CODICE.items())))
        lines.append("")
        lines.append("| segno | chi lo chiede |")
        lines.append("|---|---|")
        for tag in asked:
            lines.append("| `%s` | %s |" % (tag, ", ".join(sorted(signs[tag]["legge"]))))
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## I segni che mordono")
    lines.append("")
    lines.append("| segno | chi lo scrive | chi lo cancella | chi lo legge |")
    lines.append("|---|---|---|---|")
    for tag in speaking:
        roles = signs[tag]
        lines.append("| `%s` | %s | %s | %s |" % (
            tag,
            ", ".join(sorted(roles["scrive"])) or "—",
            ", ".join(sorted(roles["cancella"])) or "—",
            ", ".join(sorted(roles["legge"])),
        ))
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="esce 1 se il registro e' fuori passo o un muto non e' dichiarato")
    args = parser.parse_args()

    signs = collect()
    text = render(signs)
    mute = {tag for tag, roles in signs.items()
            if (roles["scrive"] or roles["cancella"]) and not roles["legge"]}

    if not args.check:
        REGISTRY.write_text(text, encoding="utf-8")
        written = sum(1 for r in signs.values() if r["scrive"] or r["cancella"])
        print("scritto %s — %d segni scritti sul mondo, %d muti" % (REGISTRY.name, written, len(mute)))
        return 0

    problems: List[str] = []
    for tag in sorted(mute - set(MUTI_NOTI)):
        problems.append(
            "segno muto non dichiarato: `%s` — lo scrive %s e non lo legge nessuno.\n"
            "  Fallo mordere (una regola del segno, un obiettivo, la pesca delle domande),\n"
            "  toglilo, oppure dichiaralo in MUTI_NOTI dentro tools/build_sign_registry.py."
            % (tag, ", ".join(sorted(signs[tag]["scrive"] | signs[tag]["cancella"])))
        )
    # Una clausola impossibile e' un difetto, non una curiosita': oggi sono
    # zero, e questo cancello e' quello che le tiene a zero.
    for tag in impossibili(signs):
        if tag in CHIESTI_NOTI:
            continue
        problems.append(
            "clausola impossibile: `%s` — lo chiede %s e **niente lo scrive**.\n"
            "  Fallo scrivere da qualcosa, cambia la clausola, oppure dichiaralo in\n"
            "  CHIESTI_NOTI dentro tools/build_sign_registry.py con la sua ragione."
            % (tag, ", ".join(sorted(signs[tag]["legge"])))
        )
    for tag in sorted(set(MUTI_NOTI) - mute):
        problems.append(
            "`%s` e' dichiarato muto ma adesso qualcosa lo legge: togli la riga da MUTI_NOTI."
            % tag
        )
    if not REGISTRY.exists():
        problems.append("manca docs/REGISTRO_SEGNI.md: gira `python3 tools/build_sign_registry.py`.")
    elif REGISTRY.read_text(encoding="utf-8") != text:
        problems.append("docs/REGISTRO_SEGNI.md non e' piu' quello che i dati producono:\n"
                        "  gira `python3 tools/build_sign_registry.py` e committa il risultato.")

    if problems:
        for problem in problems:
            print("FAIL  %s" % problem, file=sys.stderr)
        return 1
    print("ok    il registro dei segni e' allineato — %d segni, %d muti dichiarati"
          % (sum(1 for r in signs.values() if r["scrive"] or r["cancella"]), len(mute)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
