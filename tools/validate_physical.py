#!/usr/bin/env python3
"""Il validatore della grammatica fisica (D-256).

    python3 tools/validate_physical.py            # elenca tutto
    python3 tools/validate_physical.py --check    # esce 1 se qualcosa e' rotto

La regola madre della direzione fisica e' una sola:

    ogni segno meccanico dev'essere letto da almeno una cosa.

Un segno che nessuno legge non e' una regola, e' colore travestito da regola —
e al tavolo e' peggio che nel codice, perche' un giocatore ci mette sopra un
gettone e aspetta che serva a qualcosa. Il gemello del difetto e' altrettanto
muto: un segno che tutti leggono e **nessuno scrive** e' una Domanda che non si
aprira' mai, e non lo dice nessuno.

Questo strumento fa i sei controlli che la direzione chiede:

  1. segni prodotti e mai letti;
  2. segni letti e mai prodotti;
  3. Domande senza segni richiesti (si aprirebbero sempre: non sono domande);
  4. carte con faccia fisica ma senza Risonanza (un'Azione senza reazione del
     mondo e' un pulsante);
  5. Risonanze che scaldano un Tema che non esiste;
  6. Temi il cui mazzo Domande non si puo' aprire: nessuna delle sue Domande
     chiede un segno che il mondo sappia produrre. E' ISSUES 53 vista dal lato
     fisico — una rivendicazione che non apre niente.

I casi noti e accettati stanno in DICHIARATI, ognuno con la sua ragione: e' la
regola di casa, un numero peggiorato e scritto vale piu' di un numero nascosto.
Togliere una voce da li' senza farla mordere fa andare rosso il controllo.
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from typing import Any, Dict, Iterable, List, Set

from echoes_schema import DATA_DIR

# Prefissi che il **motore** consuma senza una clausola scritta nei dati.
PREFISSI_DEL_MOTORE = (
    "discovery:", "evicted:", "function:", "legend:", "life:", "place:",
    # `domain:` e' il dominio della Regione, non un segno: lo legge il motore per
    # decidere quale Tensione guarda quale posto.
    "domain:",
)

# Le etichette di famiglia scritte sul dato base delle Entita'. Sono colore
# dichiarato: nessuna regola le legge, e non devono esserlo — dicono chi sei,
# non cosa puoi fare.
ETICHETTE_DI_FAMIGLIA = {
    "ancient", "ash", "free_cities", "guild", "migrating", "order", "scholar",
    "sleeping", "crown", "nomad", "cult", "city", "house", "people",
}
# I livelli di rapporto viaggiano nella stessa chiave `tag` ma non sono segni.
LIVELLI = {"ENEMY", "HOSTILE", "NEUTRAL", "ALLY", "BOUND", "BLOOD", "PACT"}

# I segni scritti e non letti che restano, con la ragione. Vedi REGISTRO_SEGNI.md
# per il conto completo: qui stanno solo quelli che la faccia fisica tocca.
DICHIARATI: Dict[str, str] = {
    "condition:lean": "mappa: la cura e' l'Annata Buona, e il gradino con i denti e' condition:starving",
    "condition:rationed": "il segno delle Chiavi (D-114); la Marcia lo rompe",
    "condition:requisitioned": "mappa e narrazione; il sopruso vivo e' il controllo passato di mano",
    "condition:abandoned": "il dente sta sulla cicatrice gemella (TGR_ABANDONED_WEALTH)",
    "condition:contested": "mappa e verbale (D-107/D-121); si cura decidendo la questione al Consiglio",
    "condition:indebted": "il debito che morde e' debt_called (D-117)",
    "condition:mourning": "mappa; la cura sono gli Anziani (D-114)",
    "condition:cut_off": "ISSUES 24: prima fila senza lettore, gia' a verbale prima della faccia fisica",
    "grain_requisitioned": "memoria del mondo: narrata (D-103), ereditata",
    "heir_named": "entry_tag di INC_ALDRIC_RESTORED: lo legge la successione, non una clausola",
    "succession_settled": "memoria del mondo: narrata (D-103), ereditata",
    "account_settled": "memoria del mondo: narrata (D-103), ereditata",
    "amnesty_granted": "memoria del mondo: narrata (D-103), ereditata",
    "burden_shared": "memoria del mondo: narrata (D-103), ereditata",
    "betrayal_spoken": "memoria del mondo: narrata (D-103), ereditata",
    "crown_dispossessed": "memoria del mondo: narrata (D-103), ereditata",
    "crystal_measured": "memoria del mondo: narrata (D-103), ereditata",
    "dragon_slain": "memoria del mondo: narrata (D-103), ereditata",
    "faith_established": "memoria del mondo: narrata (D-103), ereditata",
    "parley_held": "memoria del mondo: narrata (D-103), ereditata",
    "petition_heard": "memoria del mondo: narrata (D-103), ereditata",
    "someone_paid": "memoria del mondo: narrata (D-103), ereditata",
    "water_rights": "memoria del mondo: narrata (D-103), ereditata",
    "charter_temporary": "memoria del mondo: narrata (D-103), ereditata",
    "settlement:$proponent": "porta un id dinamico; il suo dente e' nahr_settled nelle clausole",
    "condition:emptied": "scritto e letto solo dalla cicatrice gemella scar:emptied",
    "toll_shared": "memoria del mondo: narrata (D-103), ereditata",
    "knowledge_shared": "memoria del mondo: narrata (D-103), ereditata",
    "relic_recorded": "memoria del mondo: narrata (D-103), ereditata",
    "return_promised": "memoria del mondo: narrata (D-103), ereditata",
    "distribution_audited": "memoria del mondo: narrata (D-103), ereditata",
    "quota_guaranteed": "memoria del mondo: narrata (D-103), ereditata",
    "descent_witnessed": "memoria del mondo: narrata (D-103), ereditata",
    "list_witnessed": "memoria del mondo: narrata (D-103), ereditata",
    "succession_witnessed": "memoria del mondo: narrata (D-103), ereditata",
    "charter_for_all": "memoria del mondo: narrata (D-103), ereditata",
    "debt_staggered": "memoria del mondo: narrata (D-103), ereditata",
    "relic_recorded ": "",
    "water_moves": "letto dai Destini della Chronicle 3",
    "water_shared": "memoria del mondo: narrata (D-103), ereditata",
    "water_priced": "letto dai Destini della Chronicle 3",
    "oath_broken": "letto dai Destini e dalla legenda legend:oath_broken",
    "order_restored": "vita postuma: vive nella sua forma legend:",
    "scar:broken_bridge": "letto dalle clausole delle cicatrici",
    "crystal_exploited": "letto dai Destini e dalla legenda legend:crystal_exploited",
    "no_charter": "letto dalle eleggibilita' del Consiglio della Carta",
    "mine_sealed": "letto dai Destini di Vaerax",
    "nahr_settled": "letto dai Destini dei Nahr",
    "valley_sealed": "letto dai Destini",
    "structure:sealed": "letto dalle clausole delle strutture",
    "study_supervised": "letto dai Destini di Lyra",
    "ledger_public": "letto dai Destini del Sale",
    "debt_called": "letto dai Destini del Sale",
    "debt_forgiven": "letto dalle clausole del Debito",
    "escort_sworn": "letto dai Destini di Lyra",
    "relic_buried": "letto dai Destini del Vetro",
    "relic_shown": "letto dai Destini del Vetro",
    "renowned": "letto dagli obiettivi e dai Destini condivisi",
    "question_unresolved": "letto dagli obiettivi e dai Destini condivisi",
    "ash_watch": "letto dalle regole del segno della Cenere",
    "condition:starving": "letto dalle regole del segno e dai Destini",
    "condition:unrest": "letto dalle regole del segno e dai Destini",
    "condition:exploited": "letto dai Destini di Vaerax",
    "condition:plundered": "letto dalle clausole delle cicatrici",
    "charter_written": "letto dalle eleggibilita' del Consiglio della Carta",
    "succession_by_law": "letto dai Destini",
    "crown_divided": "letto dai Destini e sciolto da CNS_CROWN_REUNITED",
    "crowned": "scritto dal dato base delle Entita', non da una Conseguenza",
    "failed_proposal": "scritto dal motore quando una proposta cade",
    "settlement:village": "letto dalle clausole degli insediamenti",
    "settlement:market": "letto dalle clausole degli insediamenti",
    "settlement:march": "letto dalle clausole degli insediamenti",
    "scar:emptied": "letto dalle clausole delle cicatrici",
    "scar:the_empty_chair": "letto dalle clausole delle cicatrici",
    "structure:granary": "letto dalle regole del segno",
    "structure:tollgate": "letto dalle regole del segno",
    "structure:road": "nome fisico della strada: il motore la conta come struttura, non come segno",
    "discovery:the_ledger": "prefisso del motore: lo conta discovery_count",
    "discovery:trade_ledger": "prefisso del motore: lo conta discovery_count",
    "discovery:crystal": "prefisso del motore: lo conta discovery_count",
    "mountain_forgotten": "letto dal Destino DST_VAERAX_LEGEND; nessuna Conseguenza lo scrive (ISSUES 24)",
    "place:cursed_wood": "scritto dal dato base delle Regioni, non da una Conseguenza",
    "scar:divided_seal": "il dente vivo e' crown_divided, letto dai Destini e sciolto da CNS_CROWN_REUNITED",
    "twice_uprooted": "lo scrive il motore alla seconda cacciata (D-234), non un dato",
    "scar:plundered": "il dente vivo e' il gemello curabile condition:plundered (la porta di D-105)",
    "scar:sealed_border": "il dente vivo e' valley_sealed, letto dai Destini",
    "scar:dragonfall": "la mappa ricorda dove cadde il drago (D-127); il dente vivo e' la morte del seggio, letta da ON_DEATH",
}


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


def _passa(tag: str) -> bool:
    """Un segno che non va contato: livello di rapporto, prefisso del motore, o
    etichetta di famiglia sull'Entita'."""
    return (
        tag in LIVELLI
        or tag in ETICHETTE_DI_FAMIGLIA
        or tag.startswith(PREFISSI_DEL_MOTORE)
    )


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


def censimento(documenti: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Set[str]]:
    scritti: Set[str] = set()
    letti: Set[str] = set()
    _scava(dict(documenti), scritti, letti)

    # Le regole del segno leggono dalla loro chiave `when`.
    for regola in documenti.get("tag_rule", []):
        quando = regola.get("when", {}) or {}
        if "tag" in quando:
            letti.add(str(quando["tag"]))
    # Alzare una struttura scrive il segno **del suo grado**, non del suo tipo:
    # il catalogo lo dichiara grado per grado, e la prima stesura di questa sonda
    # se lo componeva da sola dall'id — inventando `structure:keep` e non
    # trovando `structure:watchtower`, che e' il segno vero.
    for tipo_struttura in documenti.get("structure_type", []):
        for grado in tipo_struttura.get("grades", []):
            if grado.get("tag"):
                scritti.add(str(grado["tag"]))
        rovina = tipo_struttura.get("ruin") or {}
        if isinstance(rovina, dict) and rovina.get("tag"):
            scritti.add(str(rovina["tag"]))

    # I segni che stanno sulla mappa dall'inizio sono scritti dal dato base.
    for regione in documenti.get("region", []):
        scritti.update(str(t) for t in regione.get("tags", []))
    for entita in documenti.get("entity", []):
        scritti.update(str(t) for t in entita.get("tags", []))

    # E la faccia fisica: Azioni, Risonanze, Domande e Destini.
    for asset in documenti.get("asset", []):
        fisica = asset.get("physical")
        if not fisica:
            continue
        for azione in fisica.get("actions", []):
            scritti.update(str(t) for t in azione.get("puts_tag", []))
            letti.update(str(t) for t in azione.get("clears_tag", []))
        risonanza = fisica.get("resonance", {})
        if risonanza.get("extra_tag"):
            scritti.add(str(risonanza["extra_tag"]))
        if risonanza.get("if_target_tag"):
            letti.add(str(risonanza["if_target_tag"]))
        bersaglio = fisica.get("target", {})
        letti.update(str(t) for t in bersaglio.get("any_tag", []))
        letti.update(str(t) for t in bersaglio.get("forbidden_tag", []))
    for domanda in documenti.get("question_card", []):
        letti.update(str(t) for t in domanda.get("requires_any_tag", []))
        for esito in domanda.get("outcomes", []):
            scritti.update(str(t) for t in esito.get("puts_tag", []))
            letti.update(str(t) for t in esito.get("clears_tag", []))
    for destino in documenti.get("destiny", []):
        fisica = destino.get("physical")
        if fisica:
            letti.update(str(t) for t in fisica.get("observes", []))
    # **Il Tema non legge niente.** Elencare un segno sotto un Tema e' archiviarlo,
    # non usarlo: se contasse come lettura, questo cancello si soddisferebbe da
    # solo aggiungendo una riga a un elenco. Un segno vive se lo guarda una
    # carta, una Domanda, un Destino o una regola — non se ha una cartella.

    return {"scritti": scritti, "letti": letti}


def controlla(documenti: Dict[str, List[Dict[str, Any]]]) -> List[str]:
    guai: List[str] = []
    conto = censimento(documenti)
    scritti = {_nudo(t) for t in conto["scritti"] if not _passa(_nudo(t))}
    letti = {_nudo(t) for t in conto["letti"] if not _passa(_nudo(t))}
    temi = {str(t["id"]) for t in documenti.get("theme", [])}

    # 1. scritti e mai letti
    muti = sorted(t for t in scritti - letti if t not in DICHIARATI)
    for tag in muti:
        guai.append("segno scritto e mai letto: «%s» — o qualcuno lo legge, o e' colore" % tag)

    # 2. letti e mai scritti
    fantasmi = sorted(t for t in letti - scritti if t not in DICHIARATI)
    for tag in fantasmi:
        guai.append("segno letto e mai scritto: «%s» — la clausola che lo chiede non si avvera mai" % tag)

    # 3. Domande senza segni richiesti
    for domanda in documenti.get("question_card", []):
        if not domanda.get("requires_any_tag"):
            guai.append("Domanda senza segni richiesti: %s — si aprirebbe sempre, non e' una domanda"
                        % domanda.get("id"))

    # 4. carte con faccia fisica ma senza Risonanza (o senza due Azioni)
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

    # 5. Risonanze (e Temi dichiarati) che puntano a un Tema che non esiste
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

    # 6. Temi il cui mazzo Domande non si puo' aprire
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
    scritti = {_nudo(t) for t in conto["scritti"] if not _passa(_nudo(t))}
    letti = {_nudo(t) for t in conto["letti"] if not _passa(_nudo(t))}
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
    print("  Segni scritti  %d" % len(scritti))
    print("  Segni letti    %d" % len(letti))
    print("  Muti (scritti e mai letti), fuori dai dichiarati: %d"
          % len([t for t in scritti - letti if t not in DICHIARATI]))
    print("  Fantasmi (letti e mai scritti), fuori dai dichiarati: %d"
          % len([t for t in letti - scritti if t not in DICHIARATI]))
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


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="esce 1 se qualcosa e' rotto, senza stampare il riepilogo")
    opzioni = parser.parse_args()
    documenti = carica()
    guai = controlla(documenti)
    if not opzioni.check:
        racconta(documenti)
        print("")
    if guai:
        print("PROBLEMI (%d):" % len(guai))
        for guaio in guai:
            print("  %s" % guaio)
        return 1
    print("OK  la grammatica fisica tiene: nessun segno muto, nessun Tema senza mazzo.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
