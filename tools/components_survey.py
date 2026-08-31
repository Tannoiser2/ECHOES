#!/usr/bin/env python3
"""Il censimento dei componenti: cosa c'e' nella scatola, e quanto ne vede l'app.

    python3 tools/components_survey.py            # riscrive docs/COMPONENTI.md
    python3 tools/components_survey.py --check    # esce 1 se il documento e' vecchio

Domanda del committente: *«non mi rendo piu' conto di quanti componenti abbia
il gioco, quanto sia cresciuto e quanto c'e' ancora da fare per avere un'app
uguale al gioco fisico»*. Un elenco scritto a mano risponderebbe una volta e
poi invecchierebbe in silenzio: questo lo **conta dai dati**, ogni volta.

Tre colonne per ogni componente, e sono tre domande diverse:

- **nei dati**: quanti pezzi esistono;
- **si stampa**: se esce dai fogli di `run_export`, e in quale formato;
- **l'app lo disegna**: se una delle schermate lo mostra.

L'ultima colonna e' l'unica scritta a mano (una mappa dichiarata qui sotto):
nessuna misura sa dire cosa una persona vede, ed e' la regola §5ter.
"""
from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "godot" / "data"
ART = REPO / "godot" / "art"
DOC = REPO / "docs" / "COMPONENTI.md"
LABELS = REPO / "godot" / "scripts" / "core" / "sign_labels.gd"

## I formati di stampa (D-097), copiati da `print_sheet.gd`: se cambiano li',
## qui il conto dei fogli mente — e il cancello lo dice, perche' il documento
## non combacia piu'.
SHAPES = {
    "CARD": {"mm": "63x88", "per_page": 9},
    "TAROT": {"mm": "70x120", "per_page": 4},
    "MINI": {"mm": "44x68", "per_page": 16},
    "TILE": {"mm": "80x80", "per_page": 6},
}

## Dove l'app disegna ogni componente. **Scritta a mano, e dichiarata**: e'
## l'unica riga di questo documento che una misura non produce.
SCHERMO = {
    "asset": "Mano (`hand_view`) + le carte in Consiglio",
    "echo": "Tavolo (`echo_card_view`), a fine Atto",
    "tension": "Colonna (`status_panel`) e tabellone del Consiglio",
    "destiny": "Colonna: **il tarocco e le tre righe della faccia**",
    "entity": "Colonna: il tarocco della Casata",
    "region": "Mappa (`map_view`): tessere, segni, pedine",
    "structure": "Mappa: le Pietre coi loro gradi",
    "theme": "Colonna: i sei mazzetti coi gettoni coperti",
    "objective": "Colonna: i tre coperti del seggio",
    "profile": "Colonna: **COSA RESTERA' DI TE**",
    "tag": "Mappa e colonna, ognuno con la sua parola italiana",
}


def fustella() -> Dict[str, List[str]]:
    """I segni che diventano **un segnalino di cartone**, presi da dove li
    prende la fustella (`sign_labels.gd`).

    **Non sono i segni del dizionario**, e la differenza e' grossa: il
    dizionario ne conta 183, ma la meta' sono memorie del mondo, funzioni che
    legge solo il motore, leggende fabbricate dal tempo e domini stampati sulle
    tessere — roba che non si posa. La prima stesura di questo documento
    contava il dizionario sotto il titolo «i segnalini che si posano», e il
    committente ha reagito al numero sbagliato: *«183 segnalini sono tanti,
    forse troppi»*. Aveva ragione a spaventarsi di quel numero; il numero era
    mio, non del gioco.
    """
    testo = LABELS.read_text(encoding="utf-8")
    out: Dict[str, List[str]] = {}
    # `WORLD_WORDS` e' entrato col foglio nuovo (D-351). Finche' la memoria del
    # mondo non aveva un posto sul tavolo era giusto lasciarla fuori dal conto:
    # non si posava da nessuna parte. Adesso e' un gettone sul bordo della
    # mappa, e un censimento della scatola che non lo conta e' sbagliato.
    for nome in ("REGION_WORDS", "ENTITY_WORDS", "WORLD_WORDS"):
        blocco = testo.split("const %s: Dictionary = {" % nome, 1)[1].split("\n}", 1)[0]
        out[nome] = re.findall(r'"([^"]+)":\s*"', blocco)
    return out


# Un documento si cerca per quello che **dice di essere**, non per la cartella
# in cui sta: l'aiutante condiviso e' in `echoes_schema.py`, e la ragione per cui
# esiste e' scritta li' (ISSUES 99).
sys.path.insert(0, str(Path(__file__).resolve().parent))
from echoes_schema import items_of as items  # noqa: E402


def sheets(copies: int, shape: str) -> int:
    per = SHAPES[shape]["per_page"]
    return (copies + per - 1) // per


def art_files() -> Dict[str, bool]:
    """Quali `art_prompt_key` hanno gia' un file, e quali sono ancora prompt.

    **Le vite delle case hanno un volto ciascuna** (D-111): un'Entita' con
    quattro incarnazioni sono quattro soggetti da illustrare, non uno. La prima
    stesura di questa misura contava 97 prompt contro i 146 del brief, ed erano
    le cartelle sbagliate piu' le vite non contate."""
    out: Dict[str, bool] = {}
    for schema in ("asset", "echo_card", "region", "entity", "destiny"):
        for entry in items(schema):
            chiavi = [str(entry.get("art_prompt_key", ""))]
            for vita in entry.get("incarnations", []) or []:
                chiavi.append(str((vita or {}).get("art_prompt_key", "")))
            for key in chiavi:
                if key:
                    out[key] = (ART / (key.replace(".", "/") + ".png")).exists()
    return out


def survey() -> str:
    assets = items("asset")
    echoes = items("echo_card")
    tensions = items("tension")
    destinies = items("destiny")
    entities = items("entity")
    regions = items("region")
    structures = items("structure_type")
    themes = items("theme")
    tags = items("tag")
    objectives = items("objective")
    consequences = items("consequence")
    rules = items("tag_rule")
    actions = items("action")
    chronicles = items("chronicle")
    templates = items("confluence_template")
    profiles = items("entity_strategic_profile")

    vite = sum(len(e.get("incarnations", []) or []) for e in entities)
    copie_asset = sum(int(a.get("deck_copies", 1)) for a in assets)
    gradi = sum(len(s.get("grades", []) or []) for s in structures)

    arte = art_files()
    arte_fatta = sum(1 for v in arte.values() if v)

    # I segnalini: la fustella li ricava dai segni che si posano sul tavolo.
    # Le condizioni sono curabili e si stampano in doppia copia; le Cicatrici e
    # le Pietre in copia singola (token_sheet.gd).
    per_ambito: Dict[str, int] = defaultdict(int)
    for tag in tags:
        for scope in tag.get("scope", []) or []:
            per_ambito[str(scope)] += 1
    condizioni = sum(1 for t in tags if str(t.get("id", "")).startswith("condition:"))
    cicatrici = sum(1 for t in tags if str(t.get("id", "")).startswith("scar:"))
    pietre_tag = sum(1 for t in tags if str(t.get("id", "")).startswith("structure:"))

    righe = [
        # (nome, quanti, copie, formato, faccia fisica, chiave schermo)
        # **Non c'e' piu' un mazzo Echo** (D-359). I 48 Echi non sono 48 carte:
        # sono il terzo blocco stampato sulle 48 carte Asset, uno per carta. Il
        # censimento non li conta come pezzi, perche' nella scatola non c'e'
        # niente in piu' da tagliare — c'e' piu' testo sulla stessa carta.
        ("Carte **Asset** (ognuna col suo Eco)", len(assets), copie_asset,
         "CARD", len(assets), "asset"),
        ("Carte **Tensione** (le Domande)", len(tensions), len(tensions), "MINI",
         sum(1 for t in tensions if t.get("physical")), "tension"),
        # **La scheda del Consiglio** (D-338): un pezzo suo, uno per Tensione. La
        # carta Domanda resta mini perche' sta sulla traccia (D-097); quello che
        # serve per *risolvere* un Consiglio — la domanda, le proposte con cosa
        # lasciano, le dodici caselle — sono 870 caratteri, e su una mini non
        # entrano. La faccia fisica c'e' per tutte: e' fatta di dato, non di
        # blocco `physical`.
        ("Schede **Consiglio**", len(tensions), len(tensions), "TAROT",
         len(tensions), "council"),
        ("Carte **Destino**", len(destinies), len(destinies), "TAROT",
         sum(1 for d in destinies if d.get("physical")), "destiny"),
        ("Carte **Casata** (una per vita)", vite, vite, "TAROT", 0, "entity"),
        ("Tessere **Regione**", len(regions), len(regions), "TILE", 0, "region"),
    ]

    segni = fustella()
    mappa = segni["REGION_WORDS"]
    case = segni["ENTITY_WORDS"]
    mondo = segni["WORLD_WORDS"]
    condizioni_f = [t for t in mappa if t.startswith("condition:")]
    pietre_f = [t for t in mappa if t.startswith(("structure:", "settlement:"))]
    cicatrici_f = [t for t in mappa if t.startswith("scar:")]
    # Le condizioni si tagliano in doppia copia (si curano e tornano nella
    # riserva); Pietre e Cicatrici in copia singola. Piu' i quattro
    # insediamenti con l'angolo per l'iniziale della casa.
    pezzi_mappa = len(condizioni_f) * 2 + len(pietre_f) + 4 + len(cicatrici_f)
    # I segni delle case, piu' quattro «cacciata» e due «giuramento spezzato»,
    # che possono toccare piu' case insieme.
    pezzi_case = len(case) + 6
    # Un fatto del mondo o e' successo o non e' successo: copia singola. La
    # forma postuma (`legend:`) non e' un gettone in piu' — e' lo stesso,
    # girato — quindi non si taglia due volte.
    mondo_da_tagliare = [t for t in mondo if not t.startswith("legend:")]
    pezzi_mondo = len(mondo_da_tagliare)

    out: List[str] = []
    add = out.append
    add("# I componenti di ECHOES, contati")
    add("")
    add("Generato da `tools/components_survey.py` — non si scrive a mano.")
    add("")
    add("Cosa c'e' nella scatola oggi, cosa si stampa, cosa l'app disegna, e")
    add("cosa manca perche' l'app dica **tutto** quello che dice il tavolo.")
    add("")
    add("## 1. Quello che si stampa e si tiene in mano")
    add("")
    add("| componente | pezzi diversi | copie in scatola | formato | faccia fisica | fogli A4 |")
    add("|---|---|---|---|---|---|")
    fogli_totali = 0
    for nome, quanti, copie, shape, con_faccia, _ in righe:
        pagine = sheets(copie, shape)
        fogli_totali += pagine
        add("| %s | %d | %d | %s mm | %s | %d |" % (
            nome, quanti, copie, SHAPES[shape]["mm"],
            "**tutte**" if con_faccia == quanti and quanti else (
                "**nessuna**" if con_faccia == 0 else "%d su %d" % (con_faccia, quanti)),
            pagine,
        ))
    add("")
    add("**%d fogli A4 di carte e tessere**, piu' quattro fogli-fustella (i segni" % fogli_totali)
    add("delle Regioni, i segni delle case, i segni del mondo, la traccia dei valori).")
    add("")
    add("## 2. I segnalini che si posano")
    add("")
    add("Non hanno una carta: sono quadratini di cartone da 15 mm, e sono la")
    add("meta' del gioco che si tocca. **Non sono i 183 segni del dizionario**:")
    add("quelli comprendono memorie, funzioni del motore, leggende e domini")
    add("stampati sulle tessere. Un segnalino si taglia solo per quello che si")
    add("**posa**: su una Regione, accanto a una casa, o sul bordo della mappa")
    add("dove sta quello che il mondo ricorda (D-351).")
    add("")
    add("| fustella | tipi diversi | pezzi da tagliare |")
    add("|---|---|---|")
    add("| **Segni delle Regioni** — condizioni (2 copie), Pietre e insediamenti, Cicatrici | %d | %d |" % (
        len(mappa), pezzi_mappa))
    add("| **Segni delle case** — fama, scoperte, promesse | %d | %d |" % (
        len(case), pezzi_case))
    add("| **Segni del mondo** — sul bordo della mappa: fatti che il mondo ricorda | %d | %d |" % (
        len(mondo_da_tagliare), pezzi_mondo))
    add("| Presenza e controllo | 2 | 12 per casa |")
    add("| Rombi del Calore | 1 | uno per Tema, piu' due di scorta |")
    add("")
    add("**%d tipi diversi, %d pezzi** piu' le pedine dei seggi." % (
        len(mappa) + len(case) + len(mondo_da_tagliare),
        pezzi_mappa + pezzi_case + pezzi_mondo))
    add("")
    add("Quanti di quei tipi un tavolo vede **davvero in un anno** non lo dice")
    add("questo censimento: lo misura `cli/run_punchboard_probe.gd`, che gioca")
    add("gli anni e conta. Il numero conta piu' del totale — nessuno impara 34")
    add("simboli, si impara quello che si vede.")
    add("")

    add("## 3. Quello che non si stampa ma tiene in piedi il gioco")
    add("")
    add("| | quanti | cos'e' |")
    add("|---|---|---|")
    add("| Case (Entita') | %d | i seggi, con **%d vite** in tutto |" % (len(entities), vite))
    add("| Profili strategici | %d su %d | cosa ogni casa vuole lasciare nel mondo |" % (
        len(profiles), len(entities)))
    add("| Temi | %d | i mazzetti che scaldano e aprono la Domanda |" % len(themes))
    add("| Obiettivi | %d | i tre coperti che si pescano a inizio saga |" % len(objectives))
    add("| Conseguenze | %d | cosa una proposta scrive sul mondo se passa |" % len(consequences))
    add("| Modelli di Consiglio | %d | domande, proposte e clausole d'autore |" % len(templates))
    add("| Regole dei segni | %d | cosa un segno fa da solo |" % len(rules))
    add("| Azioni | %d | i verbi del turno |" % len(actions))
    add("| Chronicle | %d | gli anni giocabili |" % len(chronicles))
    add("")
    add("## 4. L'arte")
    add("")
    add("| | |")
    add("|---|---|")
    add("| soggetti da illustrare (`art_prompt_key`) | **%d** |" % len(arte))
    add("| gia' disegnati | **%d** |" % arte_fatta)
    add("| ancora segnaposto | **%d** |" % (len(arte) - arte_fatta))
    add("")
    add("I prompt pronti da mandare a chi disegna stanno in")
    add("[BRIEF_ARTE.md](BRIEF_ARTE.md), generati dagli stessi dati.")
    add("")
    add("## 5. Cosa manca perche' l'app dica **tutto** quello che dice il tavolo")
    add("")
    add("Quattro cose diverse, in ordine di quanto pesano.")
    add("")
    add("### a. Le facce fisiche che non sono scritte")
    add("")
    add("Una **faccia fisica** e' il testo d'autore stampato sul cartoncino: il")
    add("bersaglio a segni, le due Azioni, la Risonanza, le liste del prezzo. Le")
    add("carte che ce l'hanno le controlla il validatore; le altre stampano un")
    add("testo che il motore **ricava** dai dati digitali, e al tavolo si legge")
    add("come una scheda tecnica, non come una carta.")
    add("")
    add("| componente | faccia scritta | manca |")
    add("|---|---|---|")
    add("| Carte Asset | 48 su 48 | — |")
    add("| Carte Tensione | %d su %d | — |" % (
        sum(1 for t in tensions if t.get("physical")), len(tensions)))
    add("| Carte Destino | %d su %d | — |" % (
        sum(1 for d in destinies if d.get("physical")), len(destinies)))
    add("| Echi (sulla faccia della carta Asset) | 0 su %d | **%d** |" % (
        len(echoes), len(echoes)))
    add("| **Carte Casata** | 0 su %d | **%d** |" % (vite, vite))
    add("| **Tessere Regione** | 0 su %d | **%d** |" % (len(regions), len(regions)))
    add("")
    add("### b. L'arte")
    add("")
    add("**%d soggetti su %d sono ancora segnaposto.** E' il pezzo piu' grosso" % (
        len(arte) - arte_fatta, len(arte)))
    add("in quantita' e il piu' facile da parallelizzare: i prompt sono gia'")
    add("scritti e la scatola si stampa e si gioca anche cosi'.")
    add("")
    add("### c. Le regole che il tavolo esegue e lo schermo non spiega ancora")
    add("")
    add("| | dove sta scritto |")
    add("|---|---|")
    add("| Il Consiglio e' **due Consigli impilati**: la frase d'autore scrive il 71% di quello che resta sul mondo, la carta il 29% | ISSUES 80, D-292 |")
    add("| Una **soglia** di trasformazione non puo' leggere una memoria, perche' una memoria non si perde | ISSUES 81, D-294 |")
    add("| Il Consiglio decide con **una moneta che i Destini non spendono** | ISSUES 76, D-287 |")
    # Il numero dei segni muti lo conta `matrix_survey`, e **non si ricopia
    # qui**: due documenti generati che dicono lo stesso numero divergono al
    # primo cambio di definizione. Si rimanda a chi lo misura.
    add("| I **segni muti** — nel dizionario, scritti da qualcuno, e letti da nessuno | ISSUES 77, [la misura](MISURA_MATRICE.md) |")
    add("")
    add("### d. L'app come oggetto, non come ispezione")
    add("")
    add("E' la voce piu' vecchia e la piu' vera: *«l'app non e' un prototipo")
    add("giocabile, e' un'ispezione di stato con dei bottoni»* (ISSUES 63), e")
    add("*«tutta la pagina va rivista»* (ISSUES 65). Da allora la mano gioca, la")
    add("colonna si legge, il Consiglio mostra la carta girata — ma la regola")
    add("§5ter resta: **nessuna misura copre quello che una persona vede**. Il")
    add("giudizio e' del committente, su un tavolo vero.")
    add("")
    add("## 6. Cosa l'app disegna gia'")
    add("")
    add("| componente | dove si vede |")
    add("|---|---|")
    for chiave in sorted(SCHERMO):
        add("| %s | %s |" % (chiave, SCHERMO[chiave]))
    add("")
    return "\n".join(out) + "\n"


def main() -> int:
    text = survey()
    if "--check" in sys.argv:
        if not DOC.exists() or DOC.read_text(encoding="utf-8") != text:
            print("FAIL  docs/COMPONENTI.md non e' piu' quello che i dati producono:")
            print("      rilancia `python3 tools/components_survey.py`.")
            return 1
        print("OK  il censimento dei componenti combacia coi dati.")
        return 0
    DOC.write_text(text, encoding="utf-8")
    print("scritto %s" % DOC.relative_to(REPO))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
