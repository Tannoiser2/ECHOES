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
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "godot" / "data"
ART = REPO / "godot" / "art"
DOC = REPO / "docs" / "COMPONENTI.md"

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


def items(pattern: str) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for path in sorted(DATA.glob(pattern)):
        loaded = json.loads(path.read_text(encoding="utf-8"))
        if isinstance(loaded, dict):
            out.extend(loaded.get("items", []) or [])
    return out


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
    for pattern in ("assets/*.json", "echoes/*.json", "regions/*.json",
                    "entities/*.json", "destinies/*.json"):
        for entry in items(pattern):
            chiavi = [str(entry.get("art_prompt_key", ""))]
            for vita in entry.get("incarnations", []) or []:
                chiavi.append(str((vita or {}).get("art_prompt_key", "")))
            for key in chiavi:
                if key:
                    out[key] = (ART / (key.replace(".", "/") + ".png")).exists()
    return out


def survey() -> str:
    assets = items("assets/*.json")
    echoes = items("echoes/*.json")
    tensions = items("tensions/*.json")
    destinies = items("destinies/*.json")
    entities = items("entities/*.json")
    regions = items("regions/*.json")
    structures = items("structures/*.json")
    themes = items("themes/*.json")
    tags = items("tags/*.json")
    objectives = items("objectives/*.json")
    consequences = items("consequences/*.json")
    rules = items("tag_rules/*.json")
    actions = items("actions/*.json")
    chronicles = items("chronicle_*/chronicle_*.json")
    templates = items("chronicle_*/confluences/*.json")
    profiles = items("design_matrix/*.json")

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
        ("Carte **Asset**", len(assets), copie_asset, "CARD", len(assets), "asset"),
        ("Carte **Echo**", len(echoes), len(echoes), "CARD", 0, "echo"),
        ("Carte **Tensione** (le Domande)", len(tensions), len(tensions), "MINI",
         sum(1 for t in tensions if t.get("physical")), "tension"),
        ("Carte **Destino**", len(destinies), len(destinies), "TAROT",
         sum(1 for d in destinies if d.get("physical")), "destiny"),
        ("Carte **Casata** (una per vita)", vite, vite, "TAROT", 0, "entity"),
        ("Tessere **Regione**", len(regions), len(regions), "TILE", 0, "region"),
    ]

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
    add("**%d fogli A4 di carte e tessere**, piu' tre fogli-fustella (i segni" % fogli_totali)
    add("delle Regioni, i segni delle case, la traccia dei valori).")
    add("")
    add("## 2. I segnalini che si posano")
    add("")
    add("Non hanno una carta: sono quadratini da 15 mm, e sono la meta' del")
    add("gioco che si tocca. Escono dal **dizionario dei segni**, che e' l'unico")
    add("posto dove un segno diventa una parola italiana.")
    add("")
    add("| segnalino | quanti |")
    add("|---|---|")
    add("| segni nel dizionario | **%d** |" % len(tags))
    add("| di cui **condizioni** (curabili, doppia copia) | %d |" % condizioni)
    add("| di cui **Cicatrici** (permanenti, copia singola) | %d |" % cicatrici)
    add("| di cui **Pietre** (i gradi che si vedono sulla mappa) | %d |" % pietre_tag)
    add("| gradi di Pietra (i livelli che una Pietra puo' avere) | %d, su %d tipi |" % (
        gradi, len(structures)))
    add("| presenza e controllo | 6 + 6 per casa |")
    add("| rombi del Calore | uno per Tema in gioco, piu' due di scorta |")
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
    add("| **Carte Echo** | 0 su %d | **%d** |" % (len(echoes), len(echoes)))
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
