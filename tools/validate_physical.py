#!/usr/bin/env python3
"""Il validatore della grammatica fisica (D-256), col dizionario dei segni (PZ-0).

    python3 tools/validate_physical.py              # elenca tutto
    python3 tools/validate_physical.py --check      # esce 1 se qualcosa e' rotto
    python3 tools/validate_physical.py --self-test  # pianta difetti e pretende il rosso

La regola madre della direzione fisica e' una sola:

    ogni segno meccanico dev'essere letto da almeno una cosa.

Un segno che nessuno legge non e' una regola, e' colore travestito da regola —
e al tavolo e' peggio che nel codice, perche' un giocatore ci mette sopra un
gettone e aspetta che serva a qualcosa. Il gemello del difetto e' altrettanto
muto: un segno che tutti leggono e **nessuno scrive** e' una Domanda che non si
aprira' mai, e non lo dice nessuno.

Da PZ-0 i segni esistono come collezione: `godot/data/tags/` dichiara per ogni
segno il nome stampato, la categoria, **l'ambito** (che prima questo strumento
deduceva raschiando gli effetti), chi lo scrive e chi lo legge. La deduzione
non e' sparita: e' diventata la controprova. Questo strumento controlla:

  1. ogni segno che i dati toccano e' nel dizionario;
  2. ogni voce del dizionario e' toccata da qualcosa (una voce morta e' un
     segno inventato);
  3. l'ambito dichiarato combacia con quello osservato negli effetti;
  4. le mani dichiarate (chi scrive, chi legge) combaciano con quelle
     osservate — `engine` e' l'unica mano che il censimento non vede, e
     quindi l'unica che si puo' dichiarare senza riscontro;
  5. un segno senza lettori o senza scrittori nei dati porta una `note` che
     dice perche' e' ancora qui — la vecchia lista DICHIARATI, diventata dato;
  6. ogni #cancelletto stampato su una faccia fisica e' il nome (o un alias)
     di una voce del dizionario: una carta non puo' nominare un segno che il
     dizionario non conosce;
  7. Domande senza segni richiesti (si aprirebbero sempre: non sono domande);
  8. carte con faccia fisica ma senza Risonanza o senza due Azioni;
  9. Temi inesistenti nominati da carte, Domande o Tensioni;
 10. Risonanze cieche: la meta' aggravata puo' temere solo un segno che il
     verbo della carta raggiunge, e l'ambito adesso e' quello dichiarato;
 11. Temi il cui mazzo Domande non si puo' aprire.

`--self-test` pianta cinque difetti, uno per famiglia di controllo, e pretende
che la guardia vada rossa su ognuno: una guardia che nessuno ha visto mordere
non e' una guardia (lezione di D-256).
"""

from __future__ import annotations

import argparse
import copy
import json
import re
import sys
from collections import defaultdict
from typing import Any, Dict, List, Set, Tuple

from echoes_schema import DATA_DIR

# I livelli di rapporto viaggiano nella stessa chiave `tag` ma non sono segni:
# sono i gradini di RELATION_ORDER, e restano fuori dal dizionario.
LIVELLI = {"ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND", "BLOOD", "PACT"}

# L'unica mano che il censimento dei dati non puo' osservare.
MANO_INVISIBILE = "engine"

CANCELLETTO = re.compile(r"#([a-zàèéìòù][a-zàèéìòù_]*)")


def carica() -> Dict[str, List[Dict[str, Any]]]:
    documenti: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    for path in sorted(DATA_DIR.rglob("*.json")):
        with path.open(encoding="utf-8") as handle:
            doc = json.load(handle)
        if isinstance(doc, dict) and "schema_id" in doc:
            documenti[str(doc["schema_id"])].extend(doc.get("items", []))
    return documenti


def _nudo(tag: str) -> str:
    """Il segno senza la sua qualifica: `scar:emptied@REG_EREDAN` e' `scar:emptied`.

    La forma con la chiocciola dice **dove**, non **cosa**: contarla a parte
    faceva sembrare fantasma un segno che qualcuno scrive."""
    return tag.split("@", 1)[0]


def _scava(nodo: Any, scritti: Set[str], letti: Set[str]) -> None:
    if isinstance(nodo, dict):
        tipo = str(nodo.get("type", ""))
        carico = nodo.get("payload", {})
        if "TAG" in tipo and isinstance(carico, dict) and "tag" in carico:
            (scritti if "REMOVE" not in tipo else letti).add(str(carico["tag"]))
        # La cicatrice non e' un SET_REGION_TAG: e' un blocco suo, e la prima
        # stesura di questa sonda non la vedeva — quindici segni «letti e mai
        # scritti» che invece qualcuno scriveva eccome.
        if tipo in ("ADD_SCAR", "REMOVE_SCAR") and isinstance(carico, dict) and "tag" in carico:
            (scritti if tipo == "ADD_SCAR" else letti).add(str(carico["tag"]))
        if nodo.get("creates_scar") and isinstance(nodo.get("scar"), dict):
            marchio = nodo["scar"].get("tag")
            if isinstance(marchio, str):
                scritti.add(marchio)

        if tipo in ("state_tag_present", "state_tag_absent") and "tag" in nodo:
            letti.add(str(nodo["tag"]))
        for chiave in ("entry_tag", "entry_forbidden_tag", "if_tag", "if_not_tag"):
            if chiave in nodo and isinstance(nodo[chiave], str):
                letti.add(str(nodo[chiave]))
        for valore in nodo.values():
            _scava(valore, scritti, letti)
    elif isinstance(nodo, list):
        for valore in nodo:
            _scava(valore, scritti, letti)


def _tocchi_espliciti(documenti: Dict[str, List[Dict[str, Any]]]):
    """Le letture e scritture che `_scava` non vede, ognuna con la sua fonte.

    Sono le penne trovate una alla volta, e ognuna e' costata un difetto:
    le regole del segno (`when` e `when_also`), la Regione di cui si discute
    (`focus_region_tags`, D-234), il catalogo delle pietre grado per grado,
    i segni stampati sul dato base di Regioni ed Entita', e tutta la faccia
    fisica — bersagli, Azioni, Risonanze, Domande, Destini.

    Torna coppie (fonte, verso, tag): verso e' "scrive" o "legge".
    """
    for regola in documenti.get("tag_rule", []):
        quando = regola.get("when", {}) or {}
        if "tag" in quando:
            yield "tag_rule", "legge", str(quando["tag"])
        for extra in regola.get("when_also", []) or []:
            if "tag" in extra:
                yield "tag_rule", "legge", str(extra["tag"])
    for tensione in documenti.get("tension", []):
        for tag in tensione.get("focus_region_tags", []) or []:
            yield "tension", "legge", str(tag)
    for tipo_struttura in documenti.get("structure_type", []):
        for grado in tipo_struttura.get("grades", []):
            if grado.get("tag"):
                yield "structure_type", "scrive", str(grado["tag"])
        rovina = tipo_struttura.get("ruin") or {}
        if isinstance(rovina, dict) and rovina.get("tag"):
            yield "structure_type", "scrive", str(rovina["tag"])
    for regione in documenti.get("region", []):
        for tag in regione.get("tags", []):
            yield "region", "scrive", str(tag)
    for entita in documenti.get("entity", []):
        for tag in entita.get("tags", []):
            yield "entity", "scrive", str(tag)
    for asset in documenti.get("asset", []):
        fisica = asset.get("physical")
        if not fisica:
            continue
        for azione in fisica.get("actions", []):
            for tag in azione.get("puts_tag", []):
                yield "asset_physical", "scrive", str(tag)
            for tag in azione.get("clears_tag", []):
                yield "asset_physical", "legge", str(tag)
        risonanza = fisica.get("resonance", {})
        if risonanza.get("extra_tag"):
            yield "asset_physical", "scrive", str(risonanza["extra_tag"])
        if risonanza.get("if_target_tag"):
            yield "asset_physical", "legge", str(risonanza["if_target_tag"])
        bersaglio = fisica.get("target", {})
        for tag in bersaglio.get("any_tag", []):
            yield "asset_physical", "legge", str(tag)
        for tag in bersaglio.get("forbidden_tag", []):
            yield "asset_physical", "legge", str(tag)
    for domanda in documenti.get("question_card", []):
        for tag in domanda.get("requires_any_tag", []):
            yield "question_card", "legge", str(tag)
        for esito in domanda.get("outcomes", []):
            for tag in esito.get("puts_tag", []):
                yield "question_card", "scrive", str(tag)
            for tag in esito.get("clears_tag", []):
                yield "question_card", "legge", str(tag)
    for destino in documenti.get("destiny", []):
        fisica = destino.get("physical")
        if fisica:
            for tag in fisica.get("observes", []):
                yield "destiny_physical", "legge", str(tag)


def censimento(documenti: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Set[str]]:
    scritti: Set[str] = set()
    letti: Set[str] = set()
    _scava({k: v for k, v in documenti.items() if k != "tag"}, scritti, letti)
    for _, verso, tag in _tocchi_espliciti(documenti):
        (scritti if verso == "scrive" else letti).add(tag)
    # **Il Tema non legge niente.** Elencare un segno sotto un Tema e' archiviarlo,
    # non usarlo: se contasse come lettura, questo cancello si soddisferebbe da
    # solo aggiungendo una riga a un elenco. Un segno vive se lo guarda una
    # carta, una Domanda, un Destino o una regola — non se ha una cartella.
    return {"scritti": scritti, "letti": letti}


def mani(documenti: Dict[str, List[Dict[str, Any]]]) -> Tuple[Dict[str, Set[str]], Dict[str, Set[str]]]:
    """Chi tocca ogni segno, per collezione: il riscontro dei campi
    `written_by`/`read_by` del dizionario."""
    scrittori: Dict[str, Set[str]] = defaultdict(set)
    lettori: Dict[str, Set[str]] = defaultdict(set)
    for schema_id, items in documenti.items():
        if schema_id == "tag":
            continue
        scritti: Set[str] = set()
        letti: Set[str] = set()
        _scava({schema_id: items}, scritti, letti)
        for tag in scritti:
            scrittori[_nudo(tag)].add(schema_id)
        for tag in letti:
            lettori[_nudo(tag)].add(schema_id)
    for fonte, verso, tag in _tocchi_espliciti(documenti):
        (scrittori if verso == "scrive" else lettori)[_nudo(tag)].add(fonte)
    return scrittori, lettori


def dizionario(documenti: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Dict[str, Any]]:
    return {str(voce["id"]): voce for voce in documenti.get("tag", [])}


# Dove vive ogni verbo: quali bersagli l'azione nomina davvero nei suoi
# parametri. Serve al controllo 10 — la meta' aggravata di una Risonanza puo'
# guardare solo un segno che il verbo della carta sa raggiungere.
RAGGIUNGE: Dict[str, Set[str]] = {
    "MOVE": {"REGION", "ENTITY", "GLOBAL"},
    "SCHEME": {"REGION", "ENTITY", "GLOBAL"},
    "FORGE": {"ENTITY", "GLOBAL"},
    "INFLUENCE": {"ENTITY", "GLOBAL"},
    "CLAIM": {"ENTITY", "GLOBAL"},
    "ACQUIRE": {"ENTITY", "GLOBAL"},
}


def ambiti(documenti: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Set[str]]:
    """Dove ogni segno si vede vivere negli effetti: la controprova del campo
    `scope` del dizionario, non piu' la sua fonte."""
    dove: Dict[str, Set[str]] = defaultdict(set)

    def scava(nodo: Any) -> None:
        if isinstance(nodo, dict):
            tipo = str(nodo.get("type", ""))
            carico = nodo.get("payload", {})
            if isinstance(carico, dict) and "tag" in carico:
                if "REGION" in tipo:
                    dove[str(carico["tag"])].add("REGION")
                elif "GLOBAL" in tipo:
                    dove[str(carico["tag"])].add("GLOBAL")
                elif "ENTITY" in tipo:
                    dove[str(carico["tag"])].add("ENTITY")
            if nodo.get("creates_scar") and isinstance(nodo.get("scar"), dict):
                marchio = nodo["scar"].get("tag")
                if isinstance(marchio, str):
                    dove[marchio].add("REGION")
            for valore in nodo.values():
                scava(valore)
        elif isinstance(nodo, list):
            for valore in nodo:
                scava(valore)

    scava({k: v for k, v in documenti.items() if k != "tag"})
    for regione in documenti.get("region", []):
        for tag in regione.get("tags", []):
            dove[str(tag)].add("REGION")
    for entita in documenti.get("entity", []):
        for tag in entita.get("tags", []):
            dove[str(tag)].add("ENTITY")
    for tipo_struttura in documenti.get("structure_type", []):
        for grado in tipo_struttura.get("grades", []):
            if grado.get("tag"):
                dove[str(grado["tag"])].add("REGION")
        rovina = tipo_struttura.get("ruin") or {}
        if isinstance(rovina, dict) and rovina.get("tag"):
            dove[str(rovina["tag"])].add("REGION")

    nudo: Dict[str, Set[str]] = defaultdict(set)
    for tag, posti in dove.items():
        nudo[_nudo(tag)] |= posti
    return nudo


def _cancelletti(nodo: Any, trovati: Set[str]) -> None:
    """Ogni #parola stampata in un testo dei dati."""
    if isinstance(nodo, str):
        for parola in CANCELLETTO.findall(nodo):
            trovati.add(parola)
    elif isinstance(nodo, dict):
        for valore in nodo.values():
            _cancelletti(valore, trovati)
    elif isinstance(nodo, list):
        for valore in nodo:
            _cancelletti(valore, trovati)


def controlla(documenti: Dict[str, List[Dict[str, Any]]]) -> List[str]:
    guai: List[str] = []
    conto = censimento(documenti)
    usati = {_nudo(t) for t in conto["scritti"] | conto["letti"]} - LIVELLI
    voci = dizionario(documenti)
    temi = {str(t["id"]) for t in documenti.get("theme", [])}

    # 1. ogni segno toccato e' nel dizionario
    for tag in sorted(usati - set(voci)):
        guai.append("segno fuori dal dizionario: «%s» — un tag che i dati toccano "
                    "e il dizionario non conosce" % tag)

    # 2. ogni voce del dizionario e' toccata
    for tag in sorted(set(voci) - usati):
        guai.append("voce morta nel dizionario: «%s» — nessun dato la tocca" % tag)

    # 3. l'ambito dichiarato combacia con quello osservato
    osservati = ambiti(documenti)
    for tag in sorted(usati & set(voci)):
        visto = osservati.get(tag, set())
        dichiarato = {str(s) for s in voci[tag].get("scope", [])}
        if visto and visto != dichiarato:
            guai.append("ambito che non combacia su «%s»: dichiarato %s, osservato %s"
                        % (tag, "/".join(sorted(dichiarato)), "/".join(sorted(visto))))

    # 4. le mani dichiarate combaciano con quelle osservate
    scrittori, lettori = mani(documenti)
    for tag in sorted(usati & set(voci)):
        for campo, osservate in (("written_by", scrittori.get(tag, set())),
                                 ("read_by", lettori.get(tag, set()))):
            dichiarate = {str(m) for m in voci[tag].get(campo, [])}
            mancano = osservate - dichiarate
            if mancano:
                guai.append("mani non dichiarate su «%s»: %s lo %s ma %s non lo dice"
                            % (tag, "/".join(sorted(mancano)),
                               "scrive" if campo == "written_by" else "legge", campo))
            inventate = dichiarate - osservate - {MANO_INVISIBILE}
            if inventate:
                guai.append("mani inventate su «%s»: %s dichiara %s che il censimento "
                            "non vede" % (tag, campo, "/".join(sorted(inventate))))

    # 5. un segno senza lettori o senza scrittori nei dati dice perche'
    for tag in sorted(set(voci)):
        voce = voci[tag]
        if "note" in voce:
            continue
        if not voce.get("read_by"):
            guai.append("segno senza lettori e senza ragione: «%s» — o qualcuno lo "
                        "legge, o la voce scrive perche' e' colore dichiarato" % tag)
        elif not voce.get("written_by"):
            guai.append("segno senza scrittori e senza ragione: «%s» — la clausola "
                        "che lo chiede non si avvera mai, e la voce non dice perche'" % tag)

    # 6. ogni #cancelletto e' il nome stampato (o un alias) di una voce
    parole: Set[str] = set()
    for voce in voci.values():
        parole.add(str(voce.get("title", "")).lower())
        for alias in voce.get("aliases", []):
            parole.add(str(alias).lower())
    stampati: Set[str] = set()
    _cancelletti({k: v for k, v in documenti.items() if k != "tag"}, stampati)
    for parola in sorted(stampati):
        if parola.replace("_", " ").lower() not in parole:
            guai.append("cancelletto senza voce: «#%s» — una carta stampa un segno "
                        "che il dizionario non nomina" % parola)

    # 7. Domande senza segni richiesti
    for domanda in documenti.get("question_card", []):
        if not domanda.get("requires_any_tag"):
            guai.append("Domanda senza segni richiesti: %s — si aprirebbe sempre, non e' una domanda"
                        % domanda.get("id"))

    # 8. carte con faccia fisica ma senza Risonanza (o senza due Azioni)
    for asset in documenti.get("asset", []):
        fisica = asset.get("physical")
        if not fisica:
            continue
        if not fisica.get("resonance"):
            guai.append("carta senza Risonanza: %s — un'Azione senza reazione del mondo e' un pulsante"
                        % asset.get("id"))
        if len(fisica.get("actions", [])) != 2:
            guai.append("carta senza due Azioni: %s — con una sola la carta e' un evento che accade"
                        % asset.get("id"))

    # 9. Risonanze (e Temi dichiarati) che puntano a un Tema che non esiste
    for asset in documenti.get("asset", []):
        fisica = asset.get("physical")
        if not fisica:
            continue
        for nome in fisica.get("themes", []):
            if str(nome) not in temi:
                guai.append("Tema inesistente su %s: «%s»" % (asset.get("id"), nome))
        tema_risonanza = str(fisica.get("resonance", {}).get("theme", ""))
        if tema_risonanza and tema_risonanza not in temi:
            guai.append("Risonanza che scalda un Tema inesistente su %s: «%s»"
                        % (asset.get("id"), tema_risonanza))
    for domanda in documenti.get("question_card", []):
        if str(domanda.get("theme")) not in temi:
            guai.append("Domanda su un Tema inesistente: %s" % domanda.get("id"))
    for tensione in documenti.get("tension", []):
        if str(tensione.get("theme", "")) not in temi:
            guai.append("Tensione su un Tema inesistente: %s" % tensione.get("id"))

    # 10. La meta' aggravata che guarda dove il verbo non arriva.
    #
    # Delle sei azioni **solo MUOVERE e TRAMARE nominano una Regione**: una carta
    # che INFLUENZA e teme un segno di Regione fa una domanda al vuoto, e la sua
    # meta' aggravata non scatta mai. Non e' un caso raro — misurato, era **0 su
    # 163 Risonanze**, e sembrava che i segni fossero rari invece che
    # irraggiungibili. L'ambito adesso e' quello che il dizionario dichiara,
    # tenuto onesto dal controllo 3.
    for asset in documenti.get("asset", []):
        fisica = asset.get("physical")
        if not fisica:
            continue
        guardato = _nudo(str((fisica.get("resonance", {}) or {}).get("if_target_tag", "")))
        if not guardato:
            continue
        verbo = str((asset.get("card_action", {}) or {}).get("kind", ""))
        arriva = RAGGIUNGE.get(verbo, {"REGION", "ENTITY", "GLOBAL"})
        voce = voci.get(guardato)
        if voce is None:
            continue  # gia' detto dal controllo 1
        if not voce.get("written_by"):
            guai.append("Risonanza che teme un segno che nessuno scrive: %s guarda «%s»"
                        % (asset.get("id"), guardato))
            continue
        vive = {str(s) for s in voce.get("scope", [])}
        if not (vive & arriva):
            guai.append(
                "Risonanza cieca su %s: la carta fa %s, che non nomina %s, e teme «%s» "
                "che vive solo li'. Non scattera' mai."
                % (asset.get("id"), verbo, "/".join(sorted(vive)), guardato)
            )

    # 11. Temi il cui mazzo Domande non si puo' aprire
    per_tema: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    for domanda in documenti.get("question_card", []):
        per_tema[str(domanda.get("theme"))].append(domanda)
    producibili = {_nudo(t) for t in conto["scritti"]}
    for tema in sorted(temi):
        mazzo = per_tema.get(tema, [])
        if not mazzo:
            guai.append("Tema senza Domande: %s — il Calore sale e a fine Atto non si apre niente" % tema)
            continue
        apribili = [d for d in mazzo
                    if any(str(t) in producibili for t in d.get("requires_any_tag", []))]
        if not apribili:
            guai.append("Tema il cui mazzo non si apre mai: %s — nessuna delle sue %d Domande chiede "
                        "un segno che il mondo sappia produrre" % (tema, len(mazzo)))
    return guai


def racconta(documenti: Dict[str, List[Dict[str, Any]]]) -> None:
    conto = censimento(documenti)
    scritti = {_nudo(t) for t in conto["scritti"]} - LIVELLI
    letti = {_nudo(t) for t in conto["letti"]} - LIVELLI
    voci = dizionario(documenti)
    fisiche = [a for a in documenti.get("asset", []) if a.get("physical")]
    domande = documenti.get("question_card", [])
    temi = documenti.get("theme", [])
    destini = [d for d in documenti.get("destiny", []) if d.get("physical")]
    print("")
    print("== LA GRAMMATICA FISICA ==")
    print("")
    print("  Temi                 %d" % len(temi))
    print("  Carte con faccia     %d su %d" % (len(fisiche), len(documenti.get("asset", []))))
    print("  Domande fisiche      %d" % len(domande))
    print("  Destini con faccia   %d su %d" % (len(destini), len(documenti.get("destiny", []))))
    print("")
    per_categoria: Dict[str, int] = defaultdict(int)
    for voce in voci.values():
        per_categoria[str(voce.get("category"))] += 1
    print("  Dizionario dei segni %d voci  (%s)" % (
        len(voci),
        ", ".join("%s %d" % (c.lower(), n) for c, n in sorted(per_categoria.items()))))
    print("  Segni scritti  %d · letti %d" % (len(scritti), len(letti)))
    muti = [v for v in voci.values() if not v.get("read_by")]
    fantasmi = [v for v in voci.values() if not v.get("written_by")]
    print("  Senza lettori (dichiarati con ragione): %d · senza scrittori: %d"
          % (len(muti), len(fantasmi)))
    print("")
    per_tema: Dict[str, int] = defaultdict(int)
    for domanda in domande:
        per_tema[str(domanda.get("theme"))] += 1
    tensioni: Dict[str, int] = defaultdict(int)
    for tensione in documenti.get("tension", []):
        tensioni[str(tensione.get("theme", ""))] += 1
    print("  %-22s %9s %9s" % ("Tema", "Domande", "Tensioni"))
    for tema in temi:
        print("  %-22s %9d %9d" % (tema["title"], per_tema[tema["id"]], tensioni[tema["id"]]))


def autotest(documenti: Dict[str, List[Dict[str, Any]]]) -> int:
    """Pianta un difetto per famiglia di controllo e pretende il rosso.

    Il difetto piantato usa `condition:starving`: un segno vero, con lettori
    veri e un #cancelletto stampato davvero — cosi' ogni pianta prova il
    controllo su un caso che **deve** mordere, non su uno di comodo."""
    bersaglio = "condition:starving"

    def pianta(nome: str, modifica, atteso: str) -> bool:
        prova = copy.deepcopy(documenti)
        modifica(prova)
        guai = controlla(prova)
        morso = any(atteso in guaio for guaio in guai)
        print("  %s %s" % ("OK " if morso else "MANCATO", nome))
        if not morso:
            for guaio in guai[:8]:
                print("      trovato invece: %s" % guaio)
        return morso

    def voce(prova: Dict[str, List[Dict[str, Any]]], tag: str) -> Dict[str, Any]:
        return next(v for v in prova["tag"] if v["id"] == tag)

    def senza_voce(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        prova["tag"] = [v for v in prova["tag"] if v["id"] != bersaglio]

    def voce_morta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        prova["tag"].append({"id": "condition:seminato_apposta", "title": "seminato apposta",
                             "category": "STATE", "scope": ["REGION"],
                             "written_by": [], "read_by": [], "note": "difetto piantato"})

    def ambito_sbagliato(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        voce(prova, bersaglio)["scope"] = ["GLOBAL"]

    def mano_taciuta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        voce(prova, bersaglio)["read_by"] = [
            m for m in voce(prova, bersaglio)["read_by"] if m != "tension"]

    def cancelletto_orfano(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        v = voce(prova, bersaglio)
        v["title"] = "carestia"
        v.pop("aliases", None)

    print("")
    print("== SELF-TEST: la guardia morde? ==")
    print("")
    esiti = [
        pianta("segno usato tolto dal dizionario", senza_voce,
               "segno fuori dal dizionario: «%s»" % bersaglio),
        pianta("voce inventata che nessun dato tocca", voce_morta,
               "voce morta nel dizionario: «condition:seminato_apposta»"),
        pianta("ambito dichiarato diverso dall'osservato", ambito_sbagliato,
               "ambito che non combacia su «%s»" % bersaglio),
        pianta("lettore vero taciuto dal dizionario", mano_taciuta,
               "mani non dichiarate su «%s»" % bersaglio),
        pianta("nome cambiato sotto un #cancelletto stampato", cancelletto_orfano,
               "cancelletto senza voce: «#fame»"),
    ]
    puliti = controlla(documenti)
    print("  %s %s" % ("OK " if not puliti else "MANCATO", "dati veri: nessun guaio"))
    if puliti:
        for guaio in puliti[:8]:
            print("      %s" % guaio)
    print("")
    if all(esiti) and not puliti:
        print("OK  la guardia morde su tutti e cinque i difetti piantati, e tace sui dati veri.")
        return 0
    print("LA GUARDIA NON MORDE: un controllo che non va rosso sul difetto piantato non esiste.")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="esce 1 se qualcosa e' rotto, senza stampare il riepilogo")
    parser.add_argument("--self-test", action="store_true",
                        help="pianta difetti e verifica che la guardia vada rossa")
    opzioni = parser.parse_args()
    documenti = carica()
    if opzioni.self_test:
        return autotest(documenti)
    guai = controlla(documenti)
    if not opzioni.check:
        racconta(documenti)
        print("")
    if guai:
        print("PROBLEMI (%d):" % len(guai))
        for guaio in guai:
            print("  %s" % guaio)
        return 1
    print("OK  la grammatica fisica tiene: dizionario allineato, nessun segno muto senza ragione.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
