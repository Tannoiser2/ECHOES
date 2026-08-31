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
     osservate, **senza eccezioni** (D-334): non esiste piu' una mano che si
     dichiara e non si riscontra;
  5. un segno senza lettori o senza scrittori nei dati porta una `note` che
     dice perche' e' ancora qui — la vecchia lista DICHIARATI, diventata dato;
  6. ogni #cancelletto stampato su una faccia fisica e' il nome (o un alias)
     di una voce del dizionario: una carta non puo' nominare un segno che il
     dizionario non conosce;
  7. carte con faccia fisica ma senza Risonanza o senza due Azioni;
  8. Temi inesistenti nominati da carte o Tensioni;
  9. Risonanze cieche: la meta' aggravata puo' temere solo un segno che il
     verbo della carta raggiunge, e l'ambito adesso e' quello dichiarato;
 10. Temi senza Tensioni: un mazzetto vuoto e' un Tema che non parla mai.

E i sei di PZ-9 (D-272), riletti nel mondo dove la Domanda sta sulla carta
Tensione (D-266):

 11. tessere senza segni: il bersaglio si dice a segni (D-262), e un luogo
     senza segni non si puo' nominare;
 12. tessere che nessuno legge: ogni tessera deve portare almeno un segno che
     qualcosa legge — una tessera coi soli segni muti e' decorazione;
 13. Tensioni senza domande: girata la Tensione, le sue domande devono essere
     li' (`possible_questions`);
 14. il ponte delle domande rotto: ogni domanda della Tensione deve esistere
     in un template di Consiglio, o la carta promette un dibattito che il
     motore non sa aprire;
 15. Destini che osservano un segno fuori dal dizionario: la faccia dice dove
     guardare, e deve indicare un segno che esiste;
 16. Echi senza effetto: una carta del Narratore senza `effect_hooks` e'
     colore travestito da carta;
 17. bersagli non garantiti sul tavolo pescato (PZ-3, D-273): una carta a
     bersaglio REGION deve poter nominare un luogo su OGNI mappa pescata —
     coi segni stampati su almeno N-K+1 tessere del parco, come i domini di
     D-265. Le condizioni e le pietre sono strade in piu', non il pavimento.

La Domanda non e' una carta a parte: **sta sulla carta Tensione** (decisione
del committente, D-266) — girata la Tensione, le sue domande sono li', legate
ai segni del mondo. I controlli sulle carte Domanda separate sono usciti con
il componente.

`--self-test` pianta un difetto per famiglia di controllo, e pretende
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

from echoes_schema import DATA_DIR, REPO_ROOT

# I livelli di rapporto viaggiano nella stessa chiave `tag` ma non sono segni:
# sono i gradini di RELATION_ORDER, e restano fuori dal dizionario.
LIVELLI = {"ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND", "BLOOD", "PACT"}

CANCELLETTO = re.compile(r"#([a-zàèéìòù][a-zàèéìòù_]*)")


def _verbi_dello_schema(lista: str) -> set[str]:
    """L'enum dei verbi di una lista, preso dallo schema della Tensione."""
    schema = json.loads(
        (REPO_ROOT / "schema" / "tension.schema.json").read_text(encoding="utf-8")
    )

    def cerca(nodo: object) -> dict | None:
        if isinstance(nodo, dict):
            if lista in nodo.get("properties", {}):
                return nodo["properties"][lista]
            for figlio in nodo.values():
                trovato = cerca(figlio)
                if trovato is not None:
                    return trovato
        if isinstance(nodo, list):
            for figlio in nodo:
                trovato = cerca(figlio)
                if trovato is not None:
                    return trovato
        return None

    blocco = cerca(schema)
    if blocco is None:
        raise SystemExit("lo schema della Tensione non ha piu' la lista «%s»" % lista)
    verbi = set(blocco["items"]["properties"]["verb"]["enum"])
    if not verbi:
        raise SystemExit("l'enum dei verbi di «%s» e' vuoto" % lista)
    return verbi


def _righe_di_regione(carta: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Ogni clausola di un Destino o di un Obiettivo che punta a un luogo."""
    out: List[Dict[str, Any]] = []

    def cammina(nodo: Any) -> None:
        if isinstance(nodo, dict):
            if "type" in nodo and ("region_id" in nodo or "any_tag" in nodo):
                out.append(nodo)
            for valore in nodo.values():
                cammina(valore)
        elif isinstance(nodo, list):
            for valore in nodo:
                cammina(valore)

    cammina(carta)
    return out


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
        for chiave in ("entry_tag", "entry_forbidden_tag", "if_tag", "if_not_tag",
                       "requires_entity_tag"):
            if chiave in nodo and isinstance(nodo[chiave], str):
                letti.add(str(nodo[chiave]))
        for valore in nodo.values():
            _scava(valore, scritti, letti)
    elif isinstance(nodo, list):
        for valore in nodo:
            _scava(valore, scritti, letti)
    elif isinstance(nodo, str):
        # La grammatica adattiva (D-262): un bersaglio detto a segni e' una
        # lettura del segno — «la Regione col #granaio», «chi porta #dormiente».
        for prefisso in ("$region_with:", "$entity_with:"):
            if nodo.startswith(prefisso):
                letti.add(nodo[len(prefisso):])


def _toglie_presenza(nodo: Any) -> bool:
    """Se questo pezzo, da qualche parte, toglie una presenza dalla mappa."""
    if isinstance(nodo, dict):
        if str(nodo.get("type", "")) == "REMOVE_PRESENCE":
            return True
        return any(_toglie_presenza(v) for v in nodo.values())
    if isinstance(nodo, list):
        return any(_toglie_presenza(v) for v in nodo)
    return False


def _tocchi_espliciti(documenti: Dict[str, List[Dict[str, Any]]]):
    """Le letture e scritture che `_scava` non vede, ognuna con la sua fonte.

    Sono le penne trovate una alla volta, e ognuna e' costata un difetto:
    le regole del segno (`when` e `when_also`), la Regione di cui si discute
    (`focus_region_tags`, D-234), il catalogo delle pietre grado per grado,
    i segni stampati sul dato base di Regioni ed Entita', e tutta la faccia
    fisica — bersagli, Azioni, Risonanze, Destini.

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
        # **La faccia della carta scrive** (D-308). Le voci delle due liste
        # posano segni — AGGIUNGI CONDIZIONE, CICATRICE, e da D-308 IL MONDO
        # RICORDA — e il dizionario non lo sapeva: `_scava` cerca gli Effect
        # compilati, e le caselle sono verbi, non Effect. Finche' i costi
        # posavano segni che anche una Conseguenza posava, la bugia non si
        # vedeva; il verbo nuovo l'ha scoperta.
        faccia = tensione.get("physical") or {}
        for lista in ("benefits", "costs", "failure"):
            for voce in faccia.get(lista) or []:
                tag = voce.get("tag")
                if isinstance(tag, str) and tag:
                    if str(voce.get("verb", "")) == "CLEAR_CONDITION":
                        yield "tension", "legge", tag
                    else:
                        yield "tension", "scrive", tag

    # **Il profilo strategico e' una lettura** (D-288): quello che una casa
    # dichiara di volere o di temere e' un segno che conta, e dichiararlo e'
    # l'unico modo perche' il dizionario non menta. Senza questa riga il file
    # dei profili sarebbe un documento: bello, e senza conseguenze.
    for profilo in documenti.get("entity_strategic_profile", []):
        for campo in ("wants", "fears", "denies"):
            for voce in profilo.get(campo, []) or []:
                if isinstance(voce, dict) and voce.get("tag"):
                    yield "entity_strategic_profile", "legge", str(voce["tag"])

    # **La Chronicle ascolta il mondo di prima** (D-286): i segni elencati in
    # `tension_pool.echoes` decidono quali domande pesano il triplo nella pesca
    # dell'era successiva (D-079). E' una lettura a tutti gli effetti, e fino a
    # qui il censimento non la vedeva: tredici memorie del mondo risultavano
    # «senza lettori» mentre la pesca le leggeva eccome.
    for cronaca in documenti.get("chronicle", []):
        sacchetto = cronaca.get("tension_pool") or {}
        for elenco in (sacchetto.get("echoes") or {}).values():
            for tag in elenco or []:
                yield "chronicle", "legge", str(tag)
    # **Le quattro penne del motore, riportate ai pezzi che le tengono** (D-334).
    # Trentotto segni si dichiaravano `written_by: ["engine"]`, e il censimento
    # li credeva sulla parola perche' `engine` era esente dal riscontro. Ma al
    # tavolo il motore non esiste: se un segno finisce sulla plancia, c'e' una
    # mano stampata che ce lo mette. Eccole, una per una, lette dal dato.

    # La Funzione e' stampata sulla carta Echo: giocarla la lascia sul mondo.
    for eco in documenti.get("echo_card", []):
        if eco.get("function_id"):
            yield "echo_card", "scrive", "function:%s" % str(eco["function_id"])

    # La Vita e' stampata sulla scheda della casata: sceglierla in setup la posa.
    for casata in documenti.get("entity", []):
        for vita in casata.get("incarnations", []) or []:
            if isinstance(vita, dict) and vita.get("id"):
                yield "entity", "scrive", "life:%s" % str(vita["id"])

    # Il passaggio di Chronicle promuove a leggenda il fatto che non dura: e'
    # una procedura stampata della scatola, non un capriccio del codice. Vale
    # per i fatti che il dizionario conosce gia' — la leggenda di un fatto che
    # nessuno scrive resterebbe una voce morta, ed e' giusto che si veda.
    fatti_scritti: Set[str] = {
        str(v["id"]) for v in documenti.get("tag", []) if v.get("written_by")
    }
    for voce in documenti.get("tag", []):
        nome = str(voce["id"])
        if nome.startswith("legend:") and nome.split(":", 1)[1] in fatti_scritti:
            yield "chronicle", "scrive", nome
            yield "chronicle", "legge", nome

    # Chi caccia una casa le lascia addosso i segni della cacciata, **e li
    # rilegge**: la seconda cacciata nello stesso anno vale il doppio, e per
    # saperlo bisogna guardare se il primo segno c'e' gia'. Non e' una regola a
    # parte: e' la stessa mano che toglie la presenza, e il dato dice quali
    # pezzi lo fanno.
    for schema_id in ("asset", "consequence", "echo_card", "confluence_template",
                      "tension", "destiny"):
        for pezzo in documenti.get(schema_id, []):
            if _toglie_presenza(pezzo):
                for segno in ("uprooted", "twice_uprooted", "evicted:$region_focus"):
                    yield schema_id, "scrive", segno
                yield schema_id, "legge", "uprooted"

    # Il dominio e' stampato sulla Tensione, e serve a trovare il posto di cui
    # si parla: la Regione che porta quel segno. Leggerlo e' il gesto del dito
    # sulla mappa, non un calcolo.
    for tensione in documenti.get("tension", []):
        if tensione.get("domain"):
            yield "tension", "legge", "domain:%s" % str(tensione["domain"])

    # Chi conta le scoperte le legge **tutte**: la clausola non dice quale, dice
    # quante. Un Destino che chiede «tre scoperte» guarda ogni `discovery:`.
    conta_scoperte = [
        schema_id for schema_id in ("destiny", "objective")
        if any("discovery_count" in json.dumps(p) for p in documenti.get(schema_id, []))
    ]
    if conta_scoperte:
        for voce in documenti.get("tag", []):
            if str(voce["id"]).startswith("discovery:"):
                for schema_id in conta_scoperte:
                    yield schema_id, "legge", str(voce["id"])

    for tipo_struttura in documenti.get("structure_type", []):
        for grado in tipo_struttura.get("grades", []):
            if grado.get("tag"):
                yield "structure_type", "scrive", str(grado["tag"])
        # **La rovina scrive con la chiave `scar`, non `tag`** (D-333). Per una
        # parola sola questa riga e' stata cieca a **tutte e dieci** le Cicatrici
        # che una Pietra lascia andando in rovina. Non si e' vista perche' nove
        # su dieci le scrive anche una Conseguenza: l'unica scoperta era
        # `scar:burned_records`, che solo l'Archivio bruciato posa — e infatti
        # non era nemmeno nel dizionario. Si leggono tutt'e due le chiavi.
        rovina = tipo_struttura.get("ruin") or {}
        if isinstance(rovina, dict):
            for chiave in ("tag", "scar"):
                if rovina.get(chiave):
                    yield "structure_type", "scrive", str(rovina[chiave])
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
    # **Nessuna mano invisibile** (D-334). Fino a qui `engine` era una mano
    # esente dal riscontro: bastava scriverlo nel dizionario perche' il
    # censimento credesse che un segno avesse uno scrittore. Al tavolo il
    # motore non esiste — se un gettone finisce sulla plancia, c'e' un pezzo
    # stampato che ce lo mette — e quei trentotto segni ce l'avevano eccome.
    # Ora ogni scrittore si osserva nel dato, senza eccezioni.
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
            inventate = dichiarate - osservate
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

    # 7. carte con faccia fisica ma senza Risonanza (o senza due Azioni)
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

    # 8. Risonanze (e Temi dichiarati) che puntano a un Tema che non esiste
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
    for tensione in documenti.get("tension", []):
        if str(tensione.get("theme", "")) not in temi:
            guai.append("Tensione su un Tema inesistente: %s" % tensione.get("id"))

    # 9. La meta' aggravata che guarda dove il verbo non arriva.
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

    # 10. Temi senza Tensioni: la Domanda sta sulla carta Tensione (D-266), e un
    # Tema senza Tensioni e' un mazzetto vuoto — il Calore sale e a fine Atto
    # non c'e' niente da girare.
    per_tema: Dict[str, int] = defaultdict(int)
    for tensione in documenti.get("tension", []):
        per_tema[str(tensione.get("theme", ""))] += 1
    for tema in sorted(temi):
        if per_tema.get(tema, 0) == 0:
            guai.append("Tema senza Tensioni: %s — il Calore sale e a fine Atto non si gira niente" % tema)

    # 11. Tessere senza segni: il bersaglio si dice a segni (D-262). Un luogo
    # senza segni non si puo' nominare da nessuna carta.
    for regione in documenti.get("region", []):
        if not regione.get("tags"):
            guai.append("tessera senza segni: %s — un luogo senza segni non si puo' dire a segni"
                        % regione.get("id"))

    # 12. Tessere che nessuno legge: almeno uno dei segni stampati sulla
    # tessera dev'essere letto da qualcosa. Una tessera coi soli segni muti
    # e' decorazione: ci si posa un gettone e non serve a niente.
    letti_nudi = {_nudo(t) for t in conto["letti"]}
    for regione in documenti.get("region", []):
        stampati_qui = [str(t) for t in regione.get("tags", [])]
        if stampati_qui and not any(_nudo(t) in letti_nudi for t in stampati_qui):
            guai.append("tessera che nessuno legge: %s — nessuno dei suoi segni (%s) e' letto da qualcosa"
                        % (regione.get("id"), ", ".join(stampati_qui)))

    # 13. Tensioni senza domande: la Domanda sta sulla carta Tensione (D-266).
    # Girata sul Tema caldo, le sue domande devono essere li'.
    for tensione in documenti.get("tension", []):
        if not tensione.get("possible_questions"):
            guai.append("Tensione senza domande: %s — girata, non avrebbe niente da chiedere"
                        % tensione.get("id"))

    # 14. **Il ponte delle domande, e dove sta l'altra riva** (riscritto in
    # 0.1.272, taglio 2 di ISSUES 80). Ogni domanda dichiarata da una Tensione
    # deve esistere — sul **suo** blocco `council`, che e' la casa nuova, o in
    # un template, che e' il ripiego finche' tutte le carte non hanno il loro.
    # Senza questo la carta promette un dibattito che il motore non sa aprire.
    #
    # E la domanda che la carta apre deve avere **almeno una proposta**: una
    # domanda senza risposte e' un Consiglio che si ferma prima di cominciare.
    quesiti_noti: Set[str] = set()
    for template in documenti.get("confluence_template", []):
        for quesito in template.get("questions", []):
            quesiti_noti.add(str(quesito.get("id")))
    for tensione in documenti.get("tension", []):
        consiglio = tensione.get("council") or {}
        propri = {str(q.get("id")) for q in consiglio.get("questions", []) or []}
        risposte: Dict[str, int] = defaultdict(int)
        for proposta in consiglio.get("propositions", []) or []:
            risposte[str(proposta.get("question_id"))] += 1
        for quesito in tensione.get("possible_questions", []):
            if str(quesito) not in propri | quesiti_noti:
                guai.append("ponte delle domande rotto su %s: «%s» non sta ne' sulla "
                            "carta ne' in un template di Consiglio"
                            % (tensione.get("id"), quesito))
        for quesito in propri:
            if risposte.get(quesito, 0) < 1:
                guai.append("domanda senza risposte su %s: «%s» si apre e nessuno "
                            "puo' proporre niente" % (tensione.get("id"), quesito))

    # 15. Destini che osservano un segno fuori dal dizionario: la faccia dice
    # dove guardare (D-270), e deve indicare un segno che esiste. Il censimento
    # generale (controllo 1) lo direbbe comunque, ma senza fare il nome del
    # Destino — e un errore senza nome e' un errore che nessuno va a cercare.
    for destino in documenti.get("destiny", []):
        fisica = destino.get("physical")
        if not fisica:
            continue
        for segno in fisica.get("observes", []):
            if _nudo(str(segno)) not in voci:
                guai.append("Destino che osserva un segno fuori dal dizionario: %s guarda «%s»"
                            % (destino.get("id"), segno))

    # 16. Echi senza effetto: una carta del Narratore senza `effect_hooks` e'
    # colore travestito da carta — si gioca, si paga, e il mondo non si muove.
    for eco in documenti.get("echo_card", []):
        if not eco.get("effect_hooks"):
            guai.append("Echo senza effetto: %s — si gioca, si paga, e il mondo non si muove"
                        % eco.get("id"))

    # 17. Bersagli garantiti sul tavolo pescato (PZ-3, D-273): una carta a
    # bersaglio REGION deve poter nominare un luogo su OGNI mappa pescata.
    # Stessa matematica dei domini (D-265): con N candidate e K pescate, i
    # segni stampati su almeno N-K+1 tessere ci sono per costruzione. Contano
    # i segni STAMPATI: condizioni e pietre sono strade in piu', non il
    # pavimento. Il bersaglio libero (senza any_tag) e' garantito da solo.
    stampati_per_tessera = {str(r.get("id")): {str(t) for t in r.get("tags", [])}
                            for r in documenti.get("region", [])}
    for cronaca in documenti.get("chronicle", []):
        pool = cronaca.get("region_pool") or {}
        candidate = [str(c) for c in pool.get("candidates", [])]
        pescate = int(pool.get("count", 0))
        if not candidate or pescate <= 0:
            continue
        pavimento = len(candidate) - pescate + 1
        for carta in documenti.get("asset", []):
            bersaglio = (carta.get("physical") or {}).get("target") or {}
            if str(bersaglio.get("scope", "")) != "REGION":
                continue
            segni = [str(t) for t in bersaglio.get("any_tag", [])]
            if not segni:
                continue
            porta = sum(1 for rid in candidate
                        if any(s in stampati_per_tessera.get(rid, set()) for s in segni))
            if porta < pavimento:
                guai.append(
                    "bersaglio non garantito sul tavolo pescato: %s nomina segni stampati "
                    "su %d tessere del parco di %s, e per esserci su ogni mappa ne servono %d"
                    % (carta.get("id"), porta, cronaca.get("id"), pavimento))

        # E la stessa matematica sulle **clausole** dei Destini e degli
        # Obiettivi (D-327). Fino a 0.1.289 una riga poteva nominare una Regione
        # per nome, e il 43.1% nominava una terra che quell'anno non usciva
        # dalla pesca: misurato in D-326. Adesso mirano a segni, e i segni
        # devono stare su abbastanza tessere da esserci comunque. Nominare una
        # Regione per nome non si puo' piu': su una mappa pescata e' una riga
        # che nasce morta.
        for famiglia in ("destiny", "objective"):
            for carta in documenti.get(famiglia, []):
                for riga in _righe_di_regione(carta):
                    nominata = str(riga.get("region_id", ""))
                    if nominata and not nominata.startswith("$"):
                        guai.append(
                            "clausola che nasce morta: %s nomina %s per nome, e la mappa si "
                            "pesca %d su %d — si mira a segni (D-327)"
                            % (carta.get("id"), nominata, pescate, len(candidate)))
                        continue
                    segni_riga = [str(s) for s in riga.get("any_tag", [])]
                    if not segni_riga:
                        continue
                    porta_riga = sum(
                        1 for rid in candidate
                        if any(s in stampati_per_tessera.get(rid, set()) for s in segni_riga))
                    if porta_riga < pavimento:
                        guai.append(
                            "clausola non garantita sul tavolo pescato: %s guarda segni "
                            "stampati su %d tessere del parco di %s, e per esserci su ogni "
                            "mappa ne servono %d"
                            % (carta.get("id"), porta_riga, cronaca.get("id"), pavimento))

    # 18. Le due liste sulla carta Tensione (D-280, parola del committente).
    # La carta girata offre **benefici** che il proponente compra e **costi**
    # che gli avversari scelgono, piu' gli effetti stampati se la proposta
    # cade. I verbi sono un vocabolario chiuso — quello che il motore sa
    # eseguire — e ognuno chiede i suoi parametri: una voce che ne salta uno
    # e' una casella su cui si posa una pedina che non fa niente.
    # **Il vocabolario si legge dallo schema, non si ricopia qui** (D-343).
    # Fino alla 0.1.307 questi due insiemi erano scritti a mano accanto a
    # `schema/tension.schema.json`, che porta gli stessi enum, e accanto a
    # `council_economy.gd`, che li esegue: tre copie della stessa lista. La
    # terza copia si e' vista il giorno che una casella nuova e' entrata nelle
    # altre due — e la guardia ha bocciato dati validi.
    BENEFIT_VERBS = _verbi_dello_schema("benefits")
    COST_VERBS = _verbi_dello_schema("costs")
    NEEDS = {"BUILD_STONE": "structure", "ADD_CONDITION": "tag", "SCAR": "tag",
             "REMEMBER": "tag"}
    pietre = {str(s.get("id")) for s in documenti.get("structure_type", [])}
    for tensione in documenti.get("tension", []):
        faccia = tensione.get("physical") or {}
        if not faccia:
            guai.append("Tensione senza faccia: %s — girata, non avrebbe ne' "
                        "benefici da comprare ne' un prezzo da pagare"
                        % tensione.get("id"))
            continue
        for lista, vocabolario, minimo, come in (
                ("benefits", BENEFIT_VERBS, 2, "benefici"),
                ("costs", COST_VERBS, 2, "costi"),
                ("failure", COST_VERBS, 1, "effetti se cade")):
            voci_carta = faccia.get(lista) or []
            if len(voci_carta) < minimo:
                guai.append("lista di %s troppo corta su %s: %d voce"
                            % (come, tensione.get("id"), len(voci_carta)))
            verbi = []
            for v in voci_carta:
                verbo = str(v.get("verb", ""))
                verbi.append(verbo)
                if verbo not in vocabolario:
                    guai.append("verbo fuori vocabolario su %s: «%s» fra i %s"
                                % (tensione.get("id"), verbo, come))
                    continue
                chiede = NEEDS.get(verbo)
                if chiede and not str(v.get(chiede, "")):
                    guai.append("voce senza il suo parametro su %s: «%s» chiede "
                                "`%s`" % (tensione.get("id"), verbo, chiede))
                if verbo == "BUILD_STONE" and str(v.get("structure", "")) not in pietre:
                    guai.append("Pietra inesistente su %s: «%s»"
                                % (tensione.get("id"), v.get("structure")))
                # **IL MONDO RICORDA posa una memoria, e solo quella** (D-308).
                # Il verbo scrive sul mondo intero, non sul luogo: un segno di
                # ambito REGION o ENTITY finirebbe in un posto dove nessuna
                # regola lo va a leggere. La categoria e l'ambito li dichiara
                # il dizionario, e qui si riscontrano.
                if verbo == "REMEMBER":
                    fatto = str(v.get("tag", ""))
                    voce_fatto = voci.get(fatto, {})
                    if fatto and voce_fatto:
                        if str(voce_fatto.get("category", "")) != "MEMORY":
                            guai.append(
                                "IL MONDO RICORDA su %s non nomina una memoria: "
                                "«%s» e' %s" % (tensione.get("id"), fatto,
                                                voce_fatto.get("category")))
                        if "GLOBAL" not in (voce_fatto.get("scope") or []):
                            guai.append(
                                "IL MONDO RICORDA su %s posa un segno che non e' "
                                "del mondo: «%s» ha ambito %s"
                                % (tensione.get("id"), fatto,
                                   "/".join(voce_fatto.get("scope") or ["nessuno"])))
                for campo in ("tag",):
                    segno = str(v.get(campo, ""))
                    if segno and segno not in voci:
                        guai.append("segno fuori dal dizionario su %s: «%s»"
                                    % (tensione.get("id"), segno))
            if lista != "failure" and len(set(verbi)) < len(verbi):
                guai.append("scelta finta fra i %s di %s: due pedine fanno la "
                            "stessa cosa" % (come, tensione.get("id")))
            testi = [str(v.get("text", "")) for v in voci_carta]
            if len(set(testi)) < len(testi):
                guai.append("due voci identiche fra i %s di %s" % (come, tensione.get("id")))
            ids = [str(v.get("id", "")) for v in voci_carta]
            if len(set(ids)) < len(ids):
                guai.append("id ripetuto fra i %s di %s" % (come, tensione.get("id")))

    # **La porta del tempo legge il profilo, non un elenco suo** (D-290).
    #
    # Riscritta in D-298: la porta non chiede piu' «quanti desideri reggono»,
    # chiede una lista di cose che devono ancora reggere — e almeno una deve
    # essere una cosa che **il mondo sa togliere**. E' la cura di ISSUES 81: i
    # desideri di una casa sono spesso memorie, e una memoria scritta non si
    # perde piu', quindi una porta fatta di sole memorie e' murata. Misurato:
    # La Compagnia del Sale, con la porta e con zero trasformazioni in 168
    # salti d'era.
    TOGLIBILI = {"controls_at_least", "structure_stands", "condition_below"}
    CHIEDE = {
        "holds_wanted": ["min"],
        "controls_at_least": ["min", "any_tag"],
        "structure_stands": ["structure"],
        "condition_below": ["tag", "max"],
        "sign_stands": ["tag"],
    }
    profili = {str(p.get("entity_id")): p
               for p in documenti.get("entity_strategic_profile", [])}
    pietre = {str(s.get("id")) for s in documenti.get("structure_type", [])}
    for casa in documenti.get("entity", []):
        for vita in casa.get("incarnations", []) or []:
            porta = vita.get("also_enters")
            if not porta:
                continue
            dove = "%s/%s" % (casa.get("id"), vita.get("id"))
            clausole = porta.get("unless", []) or []
            if not any(str(c.get("type")) in TOGLIBILI for c in clausole):
                guai.append(
                    "porta del tempo murata: %s chiede solo cose che il mondo non "
                    "sa togliere - una memoria, una volta scritta, resta per sempre"
                    % dove)
            for clausola in clausole:
                genere = str(clausola.get("type", ""))
                for campo in CHIEDE.get(genere, []):
                    if clausola.get(campo) in (None, "", []):
                        guai.append("clausola incompleta su %s: «%s» senza «%s»"
                                    % (dove, genere, campo))
                if genere in ("condition_below", "sign_stands"):
                    if str(clausola.get("tag", "")) not in voci:
                        guai.append("segno fuori dal dizionario su %s: «%s»"
                                    % (dove, clausola.get("tag")))
                if genere == "structure_stands" and str(clausola.get("structure", "")) not in pietre:
                    guai.append("Pietra inesistente su %s: «%s»"
                                % (dove, clausola.get("structure")))
                if genere == "controls_at_least":
                    for tag in clausola.get("any_tag", []) or []:
                        if str(tag) not in voci:
                            guai.append("segno fuori dal dizionario su %s: «%s»"
                                        % (dove, tag))
                if genere == "holds_wanted":
                    profilo = profili.get(str(casa.get("id")))
                    if profilo is None:
                        guai.append(
                            "porta del tempo su una casa senza profilo: %s non ha un "
                            "profilo strategico, e la soglia non saprebbe cosa chiedere"
                            % dove)
                        continue
                    voluti = len(profilo.get("wants", []) or [])
                    chiesti = int(clausola.get("min", 1))
                    if chiesti > voluti:
                        guai.append(
                            "porta del tempo impossibile da tenere chiusa: %s chiede %d "
                            "segni e il profilo ne dichiara %d" % (dove, chiesti, voluti))

    # **La frase d'autore non fa il mestiere delle caselle** (D-307, taglio A di
    # ISSUES 87). Sul *luogo di cui si discute* — quello su cui si posano le
    # pedine — le Conseguenze non consegnano piu' al proponente ne' il controllo
    # ne' una Pietra: quelle due cose le vende la carta, e chi le compra le paga.
    # Una Conseguenza che le rifacesse renderebbe l'acquisto un pagamento a
    # vuoto, ed e' esattamente il difetto che si e' misurato (44% dei benefici
    # comprati non lasciava niente).
    #
    # Restano fuori dal controllo, e per ragioni diverse:
    #   - gli Effetti che arrivano **altrove** ($capital, $rival_seat, ...):
    #     nessuna casella li puo' fare, e toglierli sarebbe una perdita secca;
    #   - `SET_CONTROL` a **null**, che svuota il luogo invece di consegnarlo:
    #     e' un esito che nessun beneficio vende;
    #
    # **E l'eccezione non c'e' piu'** (0.1.271). `CNS_MINE_TAKEN` era l'unica
    # Conseguenza il cui corpo era tutto la casella: prendere il controllo. E'
    # stata riscritta su quello che la sua frase dice davvero — *«metterci
    # qualcuno a contare quello che esce»* — e adesso lascia `study_supervised`,
    # una memoria che Cenere e Lyra temono e che nessuna casella vende. Il
    # controllo lo decide il Consiglio; quello che resta e' che li' sotto
    # qualcuno conta.
    for conseguenza in documenti.get("consequence", []):
        for effetto in conseguenza.get("effects", []) or []:
            if (effetto.get("target") or {}).get("id") != "$region_focus":
                continue
            tipo = effetto.get("type")
            if tipo == "BUILD_STRUCTURE" or (
                tipo == "SET_CONTROL"
                and (effetto.get("payload") or {}).get("entity_id") == "$proponent"
            ):
                guai.append(
                    "la frase fa il mestiere della casella: %s consegna al proponente "
                    "(%s) il luogo di cui si discute, che e' quello che il Consiglio "
                    "gli vende" % (conseguenza.get("id"), tipo))

    # 19. **SI ACCENDE QUANDO** (D-330, la casella disegnata dal committente).
    #
    # La riga dice cosa fa prendere Calore alla Tensione, e si legge al tavolo
    # guardando la mappa. Una riga che nomina un segno che nessuno scrive, o una
    # Pietra che non esiste, e' una regola stampata che non si accende mai: il
    # difetto peggiore, perche' chi legge la carta crede che valga.
    #
    # E una riga **senza nessun verbo** — solo il testo — non si accende
    # nemmeno per sbaglio: il motore la scarta, e al tavolo sembra una regola.
    segni_noti = {v["id"] for v in documenti.get("tag", [])}
    pietre_note = {v["id"] for v in documenti.get("structure_type", [])}
    for tensione in documenti.get("tension", []):
        for riga in tensione.get("heats_when", []) or []:
            dove = "%s «%s»" % (tensione.get("id"), str(riga.get("text", ""))[:40])
            verbi = [
                riga.get("puts_tag"), riga.get("clears_tag"), riga.get("builds"),
                riga.get("takes_control"), riga.get("removes_presence"),
                riga.get("adds_presence"),
            ]
            if not any(verbi):
                guai.append(
                    "si accende quando: %s non dice nessun verbo — il motore la "
                    "scarta, e al tavolo sembra una regola" % dove)
            for chiave in ("puts_tag", "clears_tag", "on_region_with"):
                for tag in riga.get(chiave) or []:
                    if str(tag) not in segni_noti:
                        guai.append(
                            "si accende quando: %s nomina il segno «%s», che non "
                            "sta nel dizionario: la riga non si accende mai"
                            % (dove, tag))
            for pietra in riga.get("builds") or []:
                if str(pietra) not in pietre_note:
                    guai.append(
                        "si accende quando: %s nomina la Pietra «%s», che non "
                        "esiste: la riga non si accende mai" % (dove, pietra))

    # 21. il posto sul tavolo combacia con la forma del nome e con l'ambito (D-350)
    #
    # `scope` dice a chi appartiene un segno, `table_place` dove lo prendi in
    # mano: `condition:emptied` e `scar:emptied` vivono tutt'e due su una
    # Regione, ma uno e' un gettone che torna nella riserva e l'altro un
    # dischetto che resta. Senza questa guardia il posto si puo' scrivere
    # sbagliato, e il campo marcisce in silenzio come marcirebbe un ambito.
    gradi_di_pietra: Set[str] = set()
    for pietra in documenti.get("structure_type", []):
        for grado in pietra.get("grades", []) or []:
            if grado.get("tag"):
                gradi_di_pietra.add(str(grado["tag"]))
    PREFISSO_VUOLE = {
        "condition:": "ZONE_TOKEN",
        "scar:": "SCAR_TOKEN",
        "life:": "HOUSE_SHEET",
        "structure:": "TILE_SLOT",
        "settlement:": "TILE_SLOT",
        "function:": "NONE",
        "domain:": "TILE_PRINTED",
    }
    AMBITO_VUOLE = {
        "TILE_PRINTED": "REGION", "TILE_SLOT": "REGION", "ZONE_TOKEN": "REGION",
        "SCAR_TOKEN": "REGION", "HOUSE_SHEET": "ENTITY",
    }
    for tag in sorted(voci):
        voce = voci[tag]
        posto = str(voce.get("table_place", ""))
        if not posto:
            guai.append("segno senza posto sul tavolo: «%s» — ogni segno dice dove "
                        "si prende in mano, o non si sa cosa stampare" % tag)
            continue
        for prefisso, atteso in PREFISSO_VUOLE.items():
            if tag.startswith(prefisso) and posto != atteso:
                guai.append("posto che non combacia col nome su «%s»: un «%s» sta "
                            "in %s, e la voce dice %s" % (tag, prefisso, atteso, posto))
        # un grado di Pietra e' uno spazio sulla tessera, comunque si chiami:
        # place:forest e place:cursed_wood sono due stati dello stesso spazio.
        if tag in gradi_di_pietra and posto != "TILE_SLOT":
            guai.append("posto che non combacia col catalogo su «%s»: e' il grado di "
                        "una Pietra, quindi uno spazio sulla tessera, e la voce "
                        "dice %s" % (tag, posto))
        ambito_atteso = AMBITO_VUOLE.get(posto)
        dichiarato = {str(s) for s in voce.get("scope", [])}
        if ambito_atteso and dichiarato and ambito_atteso not in dichiarato:
            guai.append("posto che non combacia con l'ambito su «%s»: sta in %s, che "
                        "vive su %s, e l'ambito dichiarato e' %s"
                        % (tag, posto, ambito_atteso, "/".join(sorted(dichiarato))))
    return guai


def racconta(documenti: Dict[str, List[Dict[str, Any]]]) -> None:
    conto = censimento(documenti)
    scritti = {_nudo(t) for t in conto["scritti"]} - LIVELLI
    letti = {_nudo(t) for t in conto["letti"]} - LIVELLI
    voci = dizionario(documenti)
    fisiche = [a for a in documenti.get("asset", []) if a.get("physical")]
    temi = documenti.get("theme", [])
    destini = [d for d in documenti.get("destiny", []) if d.get("physical")]
    print("")
    print("== LA GRAMMATICA FISICA ==")
    print("")
    print("  Temi                 %d" % len(temi))
    print("  Carte con faccia     %d su %d" % (len(fisiche), len(documenti.get("asset", []))))
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
    tensioni: Dict[str, int] = defaultdict(int)
    for tensione in documenti.get("tension", []):
        tensioni[str(tensione.get("theme", ""))] += 1
    print("  %-22s %9s" % ("Tema", "Tensioni"))
    for tema in temi:
        print("  %-22s %9d" % (tema["title"], tensioni[tema["id"]]))


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

    # Il posto sul tavolo (D-350): quattro modi di sbagliarlo, e ognuno deve mordere.
    def senza_posto(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        voce(prova, bersaglio).pop("table_place", None)

    def posto_contro_nome(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # una Cicatrice non e' un gettone che torna nella riserva
        voce(prova, "scar:emptied")["table_place"] = "ZONE_TOKEN"

    def posto_contro_catalogo(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # place:forest e' il primo grado della Pietra STR_FOREST
        voce(prova, "place:forest")["table_place"] = "ZONE_TOKEN"

    def posto_contro_ambito(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # un segno che vive su una casa non si stampa sulla tessera
        voce(prova, bersaglio)["table_place"] = "HOUSE_SHEET"

    # I sei di PZ-9 (D-272): ogni controllo nuovo si vede mordere una volta.
    def tessera_spogliata(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        prova["region"][0]["tags"] = []

    def tessera_decorativa(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Un segno vero del dizionario che nessuno legge (scritto-e-non-letto
        # con nota, D-266): stampato da solo su una tessera, la rende muta.
        #
        # **Si sceglie dal dizionario, non a mano** (D-286): il difetto piantava
        # `charter_temporary`, e il giorno in cui quella memoria ha trovato un
        # lettore la guardia ha smesso di mordere senza che niente fosse rotto.
        # Un difetto che nomina un dato che puo' cambiare e' un difetto che
        # scade.
        muto = next(v["id"] for v in prova["tag"] if not v.get("read_by"))
        prova["region"][0]["tags"] = [muto]

    def tensione_muta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        prova["tension"][0]["possible_questions"] = []

    def ponte_rotto(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        prova["tension"][0]["possible_questions"] = ["Q_INVENTATO_APPOSTA"]

    def destino_cieco(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        con_faccia = next(d for d in prova["destiny"] if d.get("physical"))
        con_faccia["physical"]["observes"] = ["segno_inventato_apposta"]

    def eco_di_colore(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        prova["echo_card"][0]["effect_hooks"] = []

    def bersaglio_stretto(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una carta ri-mirata sulla sola #capitale: una tessera su dieci, e la
        # meta' delle mappe pescate non avrebbe dove posarla.
        carta = next(a for a in prova["asset"]
                     if (a.get("physical") or {}).get("target", {}).get("scope") == "REGION"
                     and (a["physical"]["target"].get("any_tag")))
        carta["physical"]["target"]["any_tag"] = ["capital"]

    def clausola_stretta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una riga di Destino ri-mirata sulla sola #capitale: una tessera su
        # dieci, e meta' delle mappe pescate non la porterebbe (D-327).
        riga = next(r for d in prova["destiny"] for r in _righe_di_regione(d)
                    if r.get("any_tag"))
        riga["any_tag"] = ["capital"]

    def clausola_col_nome(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una riga che torna a nominare una Regione per nome: e' il difetto che
        # D-326 ha misurato al 43.1%, e da D-327 non si puo' piu' scrivere.
        riga = next(r for d in prova["destiny"] for r in _righe_di_regione(d)
                    if r.get("any_tag"))
        riga.pop("any_tag")
        riga["region_id"] = "REG_EREDAN"

    def scelta_finta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Due pedine di costo che fanno la stessa cosa: al tavolo si posano su
        # due caselle uguali, e la scelta non e' una scelta (D-280).
        carta = next(t for t in prova["tension"] if (t.get("physical") or {}).get("costs"))
        carta["physical"]["costs"][1]["verb"] = carta["physical"]["costs"][0]["verb"]

    def lista_monca(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una lista con una voce sola: non e' un menu, e' un destino.
        carta = next(t for t in prova["tension"] if (t.get("physical") or {}).get("costs"))
        carta["physical"]["costs"] = carta["physical"]["costs"][:1]

    def porta_senza_profilo(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # La porta del tempo su una casa che non ha dichiarato niente: la
        # soglia non saprebbe cosa chiedere, e non si aprirebbe mai.
        #
        # **Il difetto si fabbrica, non si cerca** (lezione di D-286, ripresa in
        # 0.1.257): la prima stesura cercava una casa senza profilo, e il giorno
        # in cui tutte e otto ne hanno avuto uno la guardia e' morta con una
        # StopIteration invece di dire che non aveva piu' niente da provare.
        casa = next(c for c in prova["entity"]
                    if any(v.get("also_enters") for v in c.get("incarnations", []) or []))
        prova["entity_strategic_profile"] = [
            p for p in prova.get("entity_strategic_profile", [])
            if str(p.get("entity_id")) != str(casa.get("id"))
        ]

    def porta_impossibile(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una porta che chiede piu' segni di quanti il profilo ne dichiara: la
        # casa cade al primo salto, qualunque cosa faccia.
        vita = next(v for c in prova["entity"] for v in c.get("incarnations", []) or []
                    if v.get("also_enters"))
        for clausola in vita["also_enters"]["unless"]:
            if clausola["type"] == "holds_wanted":
                clausola["min"] = 99

    def porta_murata(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # **Il difetto di ISSUES 81 piantato**: una porta fatta di sole cose
        # che il mondo non sa togliere. Non si aprirebbe mai, e nessuno se ne
        # accorgerebbe se non giocando 168 salti d'era.
        vita = next(v for c in prova["entity"] for v in c.get("incarnations", []) or []
                    if v.get("also_enters"))
        vita["also_enters"]["unless"] = [
            {"type": "holds_wanted", "min": 2},
            {"type": "sign_stands", "tag": "crowned"},
        ]

    def pedina_muta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una Pietra da costruire che non esiste: la pedina si posa e non
        # succede niente.
        carta = next(t for t in prova["tension"] if (t.get("physical") or {}).get("benefits"))
        for voce in carta["physical"]["benefits"]:
            if voce.get("verb") == "BUILD_STONE":
                voce["structure"] = "STR_INVENTATA"

    def domanda_muta(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una carta che apre una Domanda a cui nessuno puo' rispondere: il
        # Consiglio si ferma prima di cominciare. Si fabbrica togliendo le
        # proposte di una domanda, invece di cercarne una gia' rotta.
        carta = next(t for t in prova["tension"]
                     if (t.get("council") or {}).get("questions"))
        muta = str(carta["council"]["questions"][0]["id"])
        carta["council"]["propositions"] = [
            p for p in carta["council"]["propositions"]
            if str(p.get("question_id")) != muta
        ]

    def memoria_sbagliata(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # IL MONDO RICORDA che nomina un segno del **luogo** invece che del
        # mondo: la pedina si posa e la memoria finisce dove nessuna regola la
        # va a leggere. Si fabbrica, non si cerca: appena i dati sono a posto,
        # cercarla smetterebbe di provare senza dirlo.
        carta = next(t for t in prova["tension"]
                     if any(v.get("verb") == "REMEMBER"
                            for v in (t.get("physical") or {}).get("benefits", [])))
        for voce in carta["physical"]["benefits"]:
            if voce.get("verb") == "REMEMBER":
                voce["tag"] = "condition:unrest"

    def frase_che_ruba_la_casella(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        # Una Conseguenza che si riprende il mestiere della casella: consegna al
        # proponente il luogo di cui si discute, che e' quello che la carta
        # vende. Si **fabbrica** invece di cercarla: appena i dati fossero a
        # posto, cercarla smetterebbe di provare senza dirlo (regola di casa).
        bersaglio = next(iter(prova["consequence"]))
        bersaglio.setdefault("effects", []).append({
            "type": "SET_CONTROL",
            "target": {"kind": "region", "id": "$region_focus"},
            "payload": {"entity_id": "$proponent"},
        })

    print("")
    print("== SELF-TEST: la guardia morde? ==")
    print("")
    def rovina_non_dichiarata(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        """La Cicatrice di una rovina che il dizionario non conosce (D-333).

        Per una parola sola — `ruin.scar` letto come `ruin.tag` — questa guardia
        e' stata cieca a tutte e dieci le rovine, e `scar:burned_records` e'
        vissuto fuori dal dizionario senza che niente andasse rosso."""
        pietra = next(p for p in prova["structure_type"] if (p.get("ruin") or {}).get("scar"))
        pietra["ruin"] = dict(pietra["ruin"], scar="scar:seminata_apposta")

    def mano_inventata(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        """Uno scrittore dichiarato che il censimento non vede (D-334).

        E' il difetto che `engine` poteva nascondere: era una mano esente dal
        riscontro, e bastava scriverla perche' un segno senza penne ne avesse
        una. Tolta l'esenzione, uno scrittore che non si osserva e' un errore
        come tutti gli altri, e questa pianta lo prova."""
        voce = next(v for v in prova["tag"] if v.get("written_by"))
        voce["written_by"] = list(voce["written_by"]) + ["destiny_physical"]

    def accende_segno_inventato(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        tensione = next(t for t in prova["tension"] if t.get("heats_when"))
        tensione["heats_when"] = [{
            "text": "una carta posa un segno che non esiste",
            "puts_tag": ["condition:seminato_apposta"],
        }]

    def accende_pietra_inventata(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        tensione = next(t for t in prova["tension"] if t.get("heats_when"))
        tensione["heats_when"] = [{
            "text": "una carta costruisce una Pietra che non esiste",
            "builds": ["STR_SEMINATA_APPOSTA"],
        }]

    def accende_senza_verbo(prova: Dict[str, List[Dict[str, Any]]]) -> None:
        tensione = next(t for t in prova["tension"] if t.get("heats_when"))
        tensione["heats_when"] = [{"text": "una regola che non dice cosa guardare"}]

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
        pianta("tessera spogliata dei suoi segni", tessera_spogliata,
               "tessera senza segni"),
        pianta("tessera coi soli segni che nessuno legge", tessera_decorativa,
               "tessera che nessuno legge"),
        pianta("due pedine di costo che fanno la stessa cosa", scelta_finta,
               "scelta finta fra i costi"),
        pianta("lista di costi con una voce sola", lista_monca,
               "lista di costi troppo corta"),
        pianta("una Pietra che non esiste sotto una pedina", pedina_muta,
               "Pietra inesistente"),
        pianta("Tensione senza domande sulla carta", tensione_muta,
               "Tensione senza domande"),
        pianta("domanda che nessun template di Consiglio conosce", ponte_rotto,
               "ponte delle domande rotto"),
        pianta("Destino che osserva un segno inventato", destino_cieco,
               "Destino che osserva un segno fuori dal dizionario"),
        pianta("Echo svuotato dei suoi effetti", eco_di_colore,
               "Echo senza effetto"),
        pianta("carta ri-mirata su un segno raro", bersaglio_stretto,
               "bersaglio non garantito sul tavolo pescato"),
        pianta("clausola di Destino ri-mirata su un segno raro", clausola_stretta,
               "clausola non garantita sul tavolo pescato"),
        pianta("clausola che torna a nominare una Regione per nome", clausola_col_nome,
               "clausola che nasce morta"),
        pianta("porta del tempo su una casa senza profilo", porta_senza_profilo,
               "porta del tempo su una casa senza profilo"),
        pianta("porta del tempo che chiede piu' segni di quanti ne esistono",
               porta_impossibile, "porta del tempo impossibile da tenere chiusa"),
        pianta("porta del tempo fatta di sole memorie (murata)", porta_murata,
               "porta del tempo murata"),
        pianta("frase d'autore che consegna il luogo che la carta vende",
               frase_che_ruba_la_casella, "la frase fa il mestiere della casella"),
        pianta("IL MONDO RICORDA che nomina un segno del luogo, non del mondo",
               memoria_sbagliata, "posa un segno che non e' del mondo"),
        pianta("carta che apre una Domanda a cui nessuno puo' rispondere",
               domanda_muta, "domanda senza risposte"),
        pianta("si accende quando: un segno che nessuno scrive",
               accende_segno_inventato, "non sta nel dizionario"),
        pianta("si accende quando: una Pietra che non esiste",
               accende_pietra_inventata, "nomina la Pietra"),
        pianta("si accende quando: una riga senza verbo", accende_senza_verbo,
               "non dice nessun verbo"),
        pianta("Cicatrice di rovina fuori dal dizionario", rovina_non_dichiarata,
               "segno fuori dal dizionario"),
        pianta("scrittore dichiarato che il censimento non vede",
               mano_inventata, "mani inventate"),
        pianta("segno senza un posto sul tavolo", senza_posto,
               "segno senza posto sul tavolo"),
        pianta("Cicatrice messa fra i gettoni che si tolgono", posto_contro_nome,
               "posto che non combacia col nome"),
        pianta("grado di Pietra spacciato per gettone", posto_contro_catalogo,
               "posto che non combacia col catalogo"),
        pianta("segno della scheda di casa messo sulla tessera", posto_contro_ambito,
               "posto che non combacia con l'ambito"),
    ]
    puliti = controlla(documenti)
    print("  %s %s" % ("OK " if not puliti else "MANCATO", "dati veri: nessun guaio"))
    if puliti:
        for guaio in puliti[:8]:
            print("      %s" % guaio)
    print("")
    if all(esiti) and not puliti:
        print("OK  la guardia morde su tutti i %d difetti piantati, e tace sui dati veri."
              % len(esiti))
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
