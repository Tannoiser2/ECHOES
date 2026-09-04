#!/usr/bin/env python3
"""Il materiale di lettura per la revisione editoriale (ISSUES voce 13).

Genera docs/REVISIONE_TESTI.md: ogni testo d'autore che un giocatore puo'
leggere, in ordine di lettura e con il proprio identificativo, cosi' una
correzione si segna con una riga («P_SHOW_IT: riscrivi cosi'...») e chi la
riceve sa esattamente dove riportarla nei dati.

Come il manifest: non si modifica a mano, si rigenera —

    python3 tools/build_review.py
    python3 tools/build_review.py --check    # esce 1 se il documento e' vecchio

Deterministico: ordine per id dentro ogni sezione, ordine di lettura fra le
sezioni. La revisione e' d'autore; questo file e' solo il tavolo su cui si fa.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "godot" / "data"
OUT = ROOT / "docs" / "REVISIONE_TESTI.md"


# Un documento si cerca per quello che **dice di essere**, non per la cartella
# in cui sta: l'aiutante condiviso e' in `echoes_schema.py`, e la ragione per cui
# esiste l'ha pagata per prima questa funzione (D-328, poi ISSUES 99).
sys.path.insert(0, str(Path(__file__).resolve().parent))
from echoes_schema import items_of as load_all  # noqa: E402


def sorted_by_id(items: list[dict]) -> list[dict]:
    return sorted(items, key=lambda item: str(item.get("id", "")))


def quote(text: str) -> str:
    return f"> {text.strip()}" if text and text.strip() else "> *(vuoto)*"


def labels_of(block) -> list[str]:
    """Le righe leggibili di un blocco `eligibility`.

    Lo schema lo lascia in due forme — una lista di condizioni, o un oggetto con
    dentro `label` e/o `conditions` — e una sonda che ne conoscesse una sola
    smetterebbe di vedere l'altra in silenzio.
    """
    out: list[str] = []
    if isinstance(block, dict):
        if block.get("label"):
            out.append(str(block["label"]))
        out.extend(labels_of(block.get("conditions")))
    elif isinstance(block, list):
        for voce in block:
            out.extend(labels_of(voce))
    return out


# **Quello che un giocatore NON legge, dichiarato** (ISSUES 105).
#
# Il cancello confrontava il documento con quello che il **generatore**
# produce, non il generatore con quello che il **gioco stampa**: un blocco
# nuovo domani restava fuori, in silenzio — ed e' successo due volte, con le
# 288 stringhe della faccia fisica e con le 841 caselle delle Tensioni.
#
# Adesso il controllo va dall'altra parte. Si guarda **ogni stringa dei dati
# che somigli a una frase** — che abbia uno spazio e almeno quattordici
# lettere, cosi' gli id e i segni restano fuori da soli — e si pretende che o
# stia nel documento, o che la sua strada sia qui sotto con la ragione
# scritta. **Un blocco nuovo che nessuno dichiara fa fallire il cancello**, che
# e' il verso giusto: si e' costretti a decidere se si legge o no.
NON_SI_LEGGE: dict[str, str] = {
    # Note d'autore agli implementatori: stanno nei dati perche' e' li' che
    # servono, e non finiscono su nessun pezzo di cartone.
    "tag/note": "la ragione per cui un segno esiste — si legge in MISURA_MATRICE, non al tavolo",
    "tag_rule/note": "la spiegazione della regola per chi la implementa",
    "entity/relations/note": "il perche' di un rapporto d'apertura, per chi scrive",
    "asset/on_commit_effects/note": "il mestiere della carta spiegato a chi la implementa",
    "asset/card_action/note": "idem, sul lato digitale dell'Azione",
    "consequence/effects/note": "il perche' di un Effetto, per chi lo legge nel codice",
    "echo_card/effect_hooks/effect/note": "idem, sugli agganci della carta Echo",
    "action/params/note": "cosa significa un parametro dell'Azione",
    # La matrice del disegno: e' il documento con cui si scrive il gioco, non
    # un pezzo che si mette in mano a qualcuno.
    "entity_strategic_profile/wants/why": "la matrice del disegno, non un pezzo del gioco",
    "entity_strategic_profile/fears/why": "la matrice del disegno",
    "entity_strategic_profile/denies/why": "la matrice del disegno",
    "entity_strategic_profile/in_one_line": "la matrice del disegno",
    "entity/incarnations/also_enters/unless/why": "il perche' di una porta del tempo, per chi la tara",
    # Il prompt di chi disegna: sta in CATALOGO_PEDINE, e chi gioca vede il
    # disegno, non la frase che l'ha ordinato.
    "token_icon/soggetto": "il prompt del disegno — si legge in CATALOGO_PEDINE",
    "token_icon/rappresenta": "cosa il gettone rappresenta, per chi lo disegna",
    # Grammatica: pezzi con cui il motore compone le frasi che poi si leggono.
    "region/name_forms/definite": "grammatica: il motore la usa per comporre",
    "region/name_forms/genitive": "grammatica: il motore la usa per comporre",
    "region/name_forms/locative": "grammatica: il motore la usa per comporre",
    "entity/name_grammar/pattern": "lo stampo con cui si genera un nome",
    "entity/name_grammar/epithets": "i pezzi con cui si genera un nome",
    "entity/incarnations/name_grammar/pattern": "lo stampo con cui si genera un nome",
    "entity/incarnations/name_grammar/epithets": "i pezzi con cui si genera un nome",
}

# I documenti che si guardano. Se ne arriva uno nuovo e non e' qui, il
# controllo non lo vede: e' l'unico buco che resta, ed e' dichiarato.
DOCUMENTI = (
    "chronicle", "region", "entity", "tension", "confluence_template",
    "consequence", "echo_card", "asset", "destiny", "action", "objective",
    "theme", "structure_type", "tag", "tag_rule", "token_icon",
    "entity_strategic_profile",
)


def _frasi(nodo, strada: list[str]):
    if isinstance(nodo, dict):
        for chiave, valore in nodo.items():
            yield from _frasi(valore, strada + [str(chiave)])
    elif isinstance(nodo, list):
        for valore in nodo:
            yield from _frasi(valore, strada + ["*"])
    elif isinstance(nodo, str):
        yield "/".join(p for p in strada if p != "*"), nodo


def quello_che_manca(documento: str, documenti=None) -> list[str]:
    """Le frasi dei dati che il documento non porta e nessuno ha dichiarato."""
    guai: list[str] = []
    visti: set[str] = set()
    for kind in DOCUMENTI:
        for item in (documenti or {}).get(kind, load_all(kind)):
            for strada, frase in _frasi(item, [kind]):
                if " " not in frase or len(frase) < 14:
                    continue
                if strada in NON_SI_LEGGE:
                    continue
                if frase.strip() in documento:
                    continue
                if strada in visti:
                    continue
                visti.add(strada)
                guai.append(
                    "testo che nessuno legge e nessuno dichiara: «%s» — %s\n"
                    "      o entra in REVISIONE_TESTI, o si scrive perche' non si legge"
                    % (strada, frase.strip()[:70])
                )
    return guai


class Review:
    def __init__(self) -> None:
        self.lines: list[str] = []
        self.count = 0

    def line(self, text: str = "") -> None:
        self.lines.append(text)

    def entry(self, identifier: str, *texts: str) -> None:
        self.line(f"**`{identifier}`**")
        for text in texts:
            if text is None or not str(text).strip():
                continue
            self.line(quote(str(text)))
            self.line()
            self.count += 1
        self.line()


def main() -> int:
    review = Review()
    out = review.lines

    chronicles = sorted_by_id(load_all("chronicle"))
    regions = sorted_by_id(load_all("region"))
    entities = sorted_by_id(load_all("entity"))
    tensions = sorted_by_id(load_all("tension"))
    templates = sorted_by_id(load_all("confluence_template"))
    consequences = sorted_by_id(load_all("consequence"))
    echoes = sorted_by_id(load_all("echo_card"))
    assets = sorted_by_id(load_all("asset"))
    destinies = sorted_by_id(load_all("destiny"))
    actions = sorted_by_id(load_all("action"))
    # **Gli obiettivi mancavano** (D-386). Diciassette carte che un giocatore
    # tiene in mano tutto l'anno — titolo, descrizione, e la riga che finisce a
    # verbale — e questo documento, che promette *ogni testo che un giocatore
    # puo' leggere*, non ne portava nessuna. Trovato riscrivendone sei.
    objectives = sorted_by_id(load_all("objective"))

    review.line("# ECHOES — I testi, per la revisione")
    review.line()
    review.line("<!-- GENERATO da `python3 tools/build_review.py` — non si corregge qui: -->")
    review.line("<!-- si segnala la correzione, si riporta nei dati, si rigenera. -->")
    review.line()
    review.line("Ogni testo che un giocatore può leggere, nell'ordine in cui lo incontra,")
    review.line("con il suo identificativo. Per correggere basta una riga, anche a voce:")
    review.line("«`P_SHOW_IT`: riscrivi così…» — al resto pensa il motore. I segnaposto")
    review.line("(`$the_region`, `$proponent`…) sono gli slot che il mondo riempie: si")
    review.line("possono spostare nella frase, non togliere.")
    review.line()

    review.line("## 1. Le aperture — lette ad alta voce all'inizio dell'anno")
    review.line()
    for chronicle in chronicles:
        review.entry(chronicle["id"], chronicle.get("title"), chronicle.get("opening_text"))

    review.line("## 2. Le Regioni — la mappa")
    review.line()
    for region in regions:
        review.entry(
            region["id"], region.get("name"), region.get("description"),
            # Quello che sa solo chi ci vive: si legge, ed e' d'autore.
            region.get("private_information"),
        )

    review.line("## 3. Le Casate — chi siede al tavolo")
    review.line()
    for entity in entities:
        review.entry(
            entity["id"], entity.get("name"), entity.get("description"),
            entity.get("private_information"),
        )
        # Le vite del seggio (D-108/D-110): la prima rispecchia la casa,
        # le successive sono testi nuovi da rivedere.
        for life in entity.get("incarnations", [])[1:]:
            review.entry(life["id"], life.get("name"), life.get("description"))
            for successor in life.get("successors", []):
                review.entry(
                    "%s, erede" % life["id"], successor.get("name"),
                    successor.get("description"),
                )
        for successor in entity.get("successors", []):
            review.entry(
                "%s, erede" % entity["id"], successor.get("name"),
                successor.get("description"),
            )

    review.line("## 4. Le Domande — le Tensioni e i loro presagi")
    review.line()
    for tension in tensions:
        review.entry(tension["id"], tension.get("title"), tension.get("description"))
        # **La riga che si legge ad alta voce quando la questione si apre**, e
        # le due liste che dicono cosa la scalda e cosa la raffredda: stanno
        # sulla mini della Tensione, e questo documento non ne portava nessuna
        # (ISSUES 105).
        review.entry("%s, apertura" % tension["id"], tension.get("opening_line"))
        for kind, label in (("triggers", "sale quando"), ("decrease_rules", "scende quando")):
            for number, righa in enumerate(tension.get(kind, []) or [], start=1):
                review.entry("%s, %s %d" % (tension["id"], label, number), righa)
        for box in tension.get("heats_when", []) or []:
            review.entry(
                "%s, si accende quando — %s" % (tension["id"], box.get("id", "?")),
                box.get("text"),
            )
        for omen in tension.get("omen_thresholds", []):
            review.entry(
                "%s, presagio al %d" % (tension["id"], int(omen.get("at", 0))),
                omen.get("message"),
            )
        # **Le caselle con cui si risolve un Consiglio** (D-341, ISSUES 103).
        #
        # Sono 841, e non ce n'era **nessuna**: sono precisamente quello che un
        # giocatore legge mentre decide cosa proporre e in che moneta pagare —
        # «Al luogo si aggiunge #razionato», «Accetta 1 Cicatrice permanente» —
        # e il documento che dice «ogni testo che un giocatore puo' leggere» le
        # ignorava tutte. Qui ognuna prende il suo id, cosi' una correzione si
        # segna con una riga.
        physical = tension.get("physical") or {}
        for group, label in (
            ("benefits", "si ottiene"), ("costs", "si paga"), ("failure", "se cade"),
        ):
            for box in physical.get(group, []):
                review.entry(
                    "%s, %s — %s" % (tension["id"], label, box.get("id", "?")),
                    box.get("text"),
                )

    review.line("## 5. I Consigli — domande ai voti e proposte")
    review.line()
    review.line("*(La proposta è la frase votata; sotto, come l'esito viene raccontato.)*")
    review.line()
    # **Le domande e le proposte stanno sulla carta** (D-310, chiuso in D-378).
    # Fino a 0.1.344 questa sezione leggeva i **template**, ed era il terzo
    # posto in cui una sonda guardava ancora la vecchia casa: al tavolo si
    # legge quello che c'e' stampato sulla Tensione, e il motore fa lo stesso
    # (`_council_base_for`: «le Domande e le Proposte le mette la carta»).
    # Il documento prometteva *ogni* testo leggibile e ne saltava 314.
    for tension in tensions:
        council = tension.get("council") or {}
        for question in council.get("questions", []) or []:
            review.entry(str(question["id"]), question.get("text"))
            for number, riga in enumerate(labels_of(question.get("eligibility")), start=1):
                review.entry("%s, si apre se %d" % (question["id"], number), riga)
        for proposition in council.get("propositions", []) or []:
            review.entry(str(proposition["id"]), proposition.get("text"))
            for number, riga in enumerate(labels_of(proposition.get("eligibility")), start=1):
                review.entry("%s, si puo' proporre se %d" % (proposition["id"], number), riga)
            if proposition.get("echo_summary"):
                review.entry(
                    "%s, esito" % proposition["id"], proposition["echo_summary"]
                )
            for outcome, text in sorted(proposition.get("echo_summaries", {}).items()):
                review.entry("%s, esito %s" % (proposition["id"], outcome), text)

    # E le **clausole**: la controproposta che un avversario attacca a una
    # **E il template ha ancora un testo suo** (ISSUES 105): dodici schede col
    # loro titolo, la loro descrizione e le domande e proposte che non stanno
    # (ancora) su una carta Tensione. Il motore le legge, quindi si leggono.
    review.line("### Le schede del Consiglio — quello che il template porta ancora")
    review.line()
    for template in templates:
        review.entry(
            template["id"], template.get("title"), template.get("description"),
            template.get("echo_title_template"),
        )
        for question in template.get("questions", []) or []:
            review.entry(str(question["id"]), question.get("text"))
            for number, riga in enumerate(labels_of(question.get("eligibility")), start=1):
                review.entry("%s, si apre se %d" % (question["id"], number), riga)
        for proposition in template.get("propositions", []) or []:
            review.entry(str(proposition["id"]), proposition.get("text"))
            for number, riga in enumerate(labels_of(proposition.get("eligibility")), start=1):
                review.entry("%s, si puo' proporre se %d" % (proposition["id"], number), riga)
            if proposition.get("echo_summary"):
                review.entry("%s, esito" % proposition["id"], proposition["echo_summary"])
            for outcome, text in sorted(proposition.get("echo_summaries", {}).items()):
                review.entry("%s, esito %s" % (proposition["id"], outcome), text)

    review.line("## 6. Le Conseguenze — quello che una decisione lascia")
    review.line()
    for consequence in consequences:
        review.entry(
            consequence["id"], consequence.get("title"), consequence.get("description")
        )
        scar = consequence.get("scar")
        if scar and scar.get("description"):
            review.entry("%s, cicatrice" % consequence["id"], scar["description"])

    review.line("## 7. Le carte Echo — il mondo risponde")
    review.line()
    for card in echoes:
        review.entry(card["id"], card.get("title"), card.get("description"))
        # QUANDO ESCE: la riga che dice a che punto del mondo la carta puo'
        # cadere. E' stampata sulla faccia (SCHELETRO_CARTE: 43 su 48).
        for number, riga in enumerate(labels_of(card.get("eligibility")), start=1):
            review.entry("%s, quando esce %d" % (card["id"], number), riga)

    review.line("## 8. Le carte Asset — quello che si tiene in mano")
    review.line()
    # **La faccia che si gioca, non solo il racconto** (D-340).
    #
    # Fino alla 0.1.304 questa sezione raccoglieva `title` e `rules_text`, e
    # lasciava fuori tutto il blocco `physical`: il bersaglio, le due Azioni col
    # loro nome, la Risonanza. Sono 288 stringhe su 48 carte, e sono
    # precisamente quelle che un giocatore legge con la carta in mano — cioe' il
    # documento che dice «ogni testo che un giocatore puo' leggere» ne mancava
    # 287 su 288, e non falliva.
    for asset in assets:
        review.entry(
            asset["id"], asset.get("title"), asset.get("rules_text"),
            # PRENDI: come si arriva a questa carta. E' stampata su tutte e 48
            # le facce (SCHELETRO_CARTE) e mancava.
            asset.get("acquisition_rule"),
        )
        physical = asset.get("physical")
        if not physical:
            continue
        review.entry(
            "%s, bersaglio" % asset["id"], physical.get("target", {}).get("text")
        )
        for number, action in enumerate(physical.get("actions", []), start=1):
            review.entry(
                "%s, azione %d" % (asset["id"], number),
                action.get("label"), action.get("text"),
            )
        review.entry(
            "%s, risonanza" % asset["id"], physical.get("resonance", {}).get("text")
        )

    review.line("## 9. I Destini — le ambizioni, gradino per gradino")
    review.line()
    for destiny in destinies:
        review.entry(destiny["id"], destiny.get("title"), destiny.get("description"))
        for level in ("minimum", "victory", "triumph"):
            block = destiny.get(level)
            if not block:
                continue
            # **Anche le clausole annidate**: un `some_of` porta dentro di se'
            # una lista di righe che sul tarocco si leggono una per una, e il
            # documento ne saltava 86 (ISSUES 105).
            clauses = " · ".join(labels_of(block.get("conditions")))
            review.entry(
                "%s, %s" % (destiny["id"], level),
                block.get("label"),
                clauses if clauses else None,
            )
        # La faccia fisica: le tre righe che il tarocco stampa al posto delle
        # clausole del motore.
        reads = (destiny.get("physical") or {}).get("reads") or {}
        for level in ("minimum", "victory", "triumph"):
            review.entry("%s, si legge %s" % (destiny["id"], level), reads.get(level))

    review.line("## 10. Gli Obiettivi — i tre coperti che si pescano a inizio saga")
    review.line()
    for objective in objectives:
        clauses = " · ".join(labels_of(objective.get("conditions")))
        review.entry(
            objective["id"], objective.get("title"), objective.get("description"),
            objective.get("label"), clauses if clauses else None,
        )

    review.line("## 11. Le Pietre — quello che si costruisce, grado per grado")
    review.line()
    for stone in sorted_by_id(load_all("structure_type")):
        review.entry(stone["id"], stone.get("name"), stone.get("description"))
        for grade in stone.get("grades", []) or []:
            review.entry(
                "%s, grado %s" % (stone["id"], grade.get("value", "?")),
                grade.get("name"), grade.get("description"),
            )
        ruin = stone.get("ruin") or {}
        review.entry(
            "%s, in rovina" % stone["id"], ruin.get("name"), ruin.get("description")
        )

    review.line("## 12. I Temi — le sei tracce del calore")
    review.line()
    for theme in sorted_by_id(load_all("theme")):
        review.entry(theme["id"], theme.get("title"), theme.get("covers"))

    review.line("## 13. I segni — il nome stampato sul gettone")
    review.line()
    review.line("*(Il nome con cui un segno si chiama al tavolo: quello stampato sul")
    review.line("gettone e, quando e' diverso, quello che l'app dice dentro una frase.")
    review.line("Le forme fra")
    review.line("parentesi sono i modi in cui la stessa cosa e' stata detta altrove,")
    review.line("e vanno riunificati — [ISSUES 70](ISSUES.md#70).)*")
    review.line()
    for sign in sorted_by_id(load_all("tag")):
        review.entry(
            sign["id"], sign.get("title"),
            # La forma con cui l'app lo dice dentro una frase, quando non e'
            # quella stampata sul gettone (D-400): «conteso» sul cartone,
            # «contesa» nella riga che parla della Regione.
            sign.get("title_spoken"),
            " · ".join(sign.get("aliases", []) or []) or None,
        )

    review.line("## 14. Le regole dei segni — cosa fa un segno quando c'e'")
    review.line()
    for rule in sorted_by_id(load_all("tag_rule")):
        review.entry(rule["id"], rule.get("title"))

    review.line("## 15. Le Azioni — la plancia, stampata una volta")
    review.line()
    for action in actions:
        review.entry(
            action["id"], action.get("title"), action.get("description"),
            action.get("rules_text"),
        )

    body = "\n".join(out)
    header_note = "%d testi in lettura.\n" % review.count
    body = body.replace(
        "possono spostare nella frase, non togliere.\n",
        "possono spostare nella frase, non togliere. " + header_note,
        1,
    )
    testo = body.rstrip() + "\n"

    if "--self-test" in sys.argv:
        # **Il blocco nuovo di domani, piantato oggi.** Una prova che cerca un
        # difetto fra i dati spediti smette di provare in silenzio il giorno
        # che il difetto sparisce: questo se lo fabbrica.
        finti = {kind: [dict(x) for x in load_all(kind)] for kind in DOCUMENTI}
        finti["region"][0]["cronaca_del_bordo"] = (
            "Una riga nuova che nessuno ha dichiarato e nessuna sezione stampa."
        )
        if not quello_che_manca(testo, finti):
            print("FALLITO: la guardia non vede un blocco nuovo non dichiarato")
            return 1
        if quello_che_manca(testo):
            print("FALLITO: la guardia morde i dati veri")
            return 1
        print("OK  la guardia dei testi vede un blocco nuovo, e tace sui dati veri")
        return 0

    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text(encoding="utf-8") != testo:
            print("FAIL  docs/REVISIONE_TESTI.md non e' piu' quello che i dati dicono:")
            print("      rilancia `python3 tools/build_review.py`.")
            return 1
        # **E il documento e' completo**, non solo aggiornato: ogni frase dei
        # dati o e' qui, o e' dichiarata come cosa che nessuno legge.
        mancano = quello_che_manca(testo)
        if mancano:
            print("FAIL  docs/REVISIONE_TESTI.md non porta tutto quello che i dati dicono:")
            for guaio in mancano[:12]:
                print("      %s" % guaio)
            print("      (%d strade in tutto)" % len(mancano))
            return 1
        print("OK  i testi in lettura sono quelli dei dati (%d), e non ne manca nessuno."
              % review.count)
        return 0

    OUT.write_text(testo)
    print("wrote %s  (%d testi)" % (OUT.relative_to(ROOT), review.count))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
