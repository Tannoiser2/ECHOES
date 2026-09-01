#!/usr/bin/env python3
"""**Il giro dei cancelli di CLAUDE.md e quello che la CI gira davvero.**

    python3 tools/gates_survey.py            # dice come stanno
    python3 tools/gates_survey.py --check    # ...ed esce 1 se le due liste si scostano
    python3 tools/gates_survey.py --self-test

CLAUDE.md ha una tabella intitolata «Il giro dei cancelli»: e' il contratto con
chi lavora qui, e dice cosa si lancia prima di spingere. `.github/workflows/`
dice cosa si lancia davvero quando si spinge. **Sono due liste scritte a mano
nello stesso repository, e non c'e' niente che le tenga uguali.**

In una giornata sola si sono scostate nei due versi:

- **CLAUDE.md ne elencava sette e la CI ne girava otto** — `run_table_survey`
  mancava dal documento. Chi seguiva il documento spingeva un ramo che andava
  rosso su un cancello che non sapeva di dover girare, due volte di fila.
- **CLAUDE.md ne elenca ventidue e la CI ne gira diciannove** — mancano
  `run_card_skeleton`, `run_box_survey` e il brief d'arte. Un documento generato
  puo' invecchiare senza che nessuno lo veda, e da
  [D-366](../docs/DECISIONS.md#d-366) uno di quei tre e' peggio del solito:
  `docs/MISURA_CASELLE.md` **e' il lato motore** del controllo che tiene uguali
  lo schema delle carte e il vocabolario delle caselle. Vecchio quel documento,
  quel controllo confronta l'enum nuovo con un vocabolario vecchio, e **da'
  verde per il motivo sbagliato**.

Il secondo verso e' quello che fa piu' male, ed e' anche quello che nessuno
nota: un cancello che non gira non si lamenta.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent

# La riga di una tabella markdown il cui primo campo e' un comando fra apici
# inversi. La tabella dei cancelli e' l'unica di CLAUDE.md fatta cosi'.
RIGA = re.compile(r"^\|\s*`([^`]+)`\s*\|")

# Un comando che nomina uno strumento del repository, dovunque stia dentro il
# blocco `run:` di un passo — anche in mezzo a un blocco su piu' righe.
STRUMENTO = re.compile(r"(?:tools/[\w.]+\.(?:py|sh)|res://tests/run_tests\.gd)")


def normalizza(comando: str) -> str:
    """Lo stesso comando scritto nei due posti in due modi.

    CLAUDE.md dice `$GODOT`, la CI dice `~/godot/godot`, e chi lo lancia a mano
    ha il binario per esteso. Sono la stessa cosa, e un confronto che non lo sa
    troverebbe uno scostamento a ogni riga.
    """
    fuori = comando
    for godot in ("~/godot/Godot_v4.7.1-stable_linux.x86_64", "~/godot/godot", "$GODOT"):
        fuori = fuori.replace(godot, "GODOT")
    fuori = re.sub(r"\s+", " ", fuori).strip()
    # `GODOT=GODOT tools/x.sh` e `bash tools/x.sh` sono lo stesso cancello: quello
    # che lo identifica e' lo strumento coi suoi argomenti.
    taglio = STRUMENTO.search(fuori)
    if taglio:
        fuori = fuori[taglio.start():]
    # E quello che sta **dopo** il comando non e' il comando: una redirezione,
    # una pipe, la barra che continua la riga in un blocco `run:` su piu' righe.
    fuori = re.split(r"\s*(?:[|>]|2>|&&|;)", fuori)[0]
    return fuori.rstrip("\\").strip()


def strumento_di(comando: str) -> str:
    """Quale strumento gira questo comando, senza i suoi argomenti."""
    trovato = STRUMENTO.search(comando)
    return trovato.group(0) if trovato else comando


def cancelli_del_documento(testo: str) -> List[str]:
    """I cancelli che CLAUDE.md promette, nell'ordine in cui li elenca."""
    fuori: List[str] = []
    for riga in testo.splitlines():
        trovato = RIGA.match(riga)
        if trovato and STRUMENTO.search(trovato.group(1)):
            fuori.append(trovato.group(1).strip())
    return fuori


def cancelli_della_ci(testo: str) -> List[str]:
    """I cancelli che i workflow lanciano davvero.

    Non si prova a capire lo YAML: si guardano le righe che nominano uno
    strumento del repository. Un passo che gira un cancello lo nomina per forza,
    e leggere il testo invece della struttura evita di dipendere da come e'
    scritto il blocco `run:` — che qui e' a volte una riga sola e a volte un
    blocco.
    """
    fuori: List[str] = []
    for riga in testo.splitlines():
        if not STRUMENTO.search(riga):
            continue
        pulita = riga.strip()
        pulita = re.sub(r"^-?\s*(name|run):\s*", "", pulita)
        pulita = pulita.lstrip("|").strip()
        if pulita and pulita not in fuori:
            fuori.append(pulita)
    return fuori


def confronta(documento: str, ci: str) -> Tuple[List[str], List[str]]:
    """Chi manca da che parte: (promessi e non girati, girati e non promessi)."""
    promessi = cancelli_del_documento(documento)
    girati = cancelli_della_ci(ci)
    girati_nudi = {normalizza(c) for c in girati}
    promessi_nudi = {normalizza(c) for c in promessi}
    non_girati = [c for c in promessi if normalizza(c) not in girati_nudi]
    # Il verso opposto: uno **strumento** che la CI gira e il documento non
    # nomina affatto. Chi segue il documento spinge un ramo che va rosso su un
    # passo che non sapeva di dover girare — successo, due volte di fila.
    #
    # Qui si guarda lo strumento e non il comando intero, apposta: `run_export.sh`
    # la CI lo gira anche **senza** `--check-brief`, per confrontare due export e
    # provare che sono uguali, e quello non e' un cancello da girare a mano — e'
    # un pezzo del controllo di determinismo. Uno strumento gia' nella tabella e'
    # uno strumento che chi legge conosce; quello che fa male e' uno strumento
    # che la tabella non nomina per niente.
    documentati = {strumento_di(c) for c in promessi}
    non_scritti: List[str] = []
    visti = set()
    for comando in girati:
        attrezzo = strumento_di(comando)
        if attrezzo in documentati or attrezzo in visti:
            continue
        visti.add(attrezzo)
        non_scritti.append(normalizza(comando))
    return non_girati, non_scritti


def _leggi() -> Tuple[str, str]:
    documento = (REPO_ROOT / "CLAUDE.md").read_text(encoding="utf-8")
    ci = "\n".join(
        percorso.read_text(encoding="utf-8")
        for percorso in sorted((REPO_ROOT / ".github" / "workflows").glob("*.yml"))
    )
    return documento, ci


def _racconta(non_girati: List[str], non_scritti: List[str], promessi: int) -> None:
    print("IL GIRO DEI CANCELLI")
    print("  CLAUDE.md ne promette %d" % promessi)
    if non_girati:
        print("")
        print("  PROMESSI E NON GIRATI (un cancello che non gira non si lamenta):")
        for comando in non_girati:
            print("    %s" % comando)
    if non_scritti:
        print("")
        print("  GIRATI E NON PROMESSI (chi segue il documento spinge un ramo rosso):")
        for comando in non_scritti:
            print("    %s" % comando)
    if not non_girati and not non_scritti:
        print("  e la CI gira esattamente quelli.")


def _self_test() -> int:
    """La guardia morde nei due versi, sul difetto piantato."""
    documento, ci = _leggi()
    esiti = []

    def pianta(nome: str, doc: str, workflow: str, atteso: int) -> bool:
        non_girati, non_scritti = confronta(doc, workflow)
        quanti = len(non_girati) + len(non_scritti)
        morso = quanti >= atteso
        print("  %s %s" % ("OK " if morso else "MANCATO", nome))
        return morso

    # Un cancello tolto dalla CI: il documento lo promette e nessuno lo gira.
    ci_monca = "\n".join(
        riga for riga in ci.splitlines() if "run_marks_survey.sh" not in riga
    )
    esiti.append(pianta("cancello promesso che la CI non gira", documento, ci_monca, 1))

    # Un cancello tolto dal documento: la CI lo gira e chi legge non lo sa.
    doc_monco = "\n".join(
        riga for riga in documento.splitlines()
        if not (RIGA.match(riga) and "run_marks_survey.sh" in riga)
    )
    esiti.append(pianta("cancello girato che il documento non promette", doc_monco, ci, 1))

    # E sui dati veri non deve dire niente.
    non_girati, non_scritti = confronta(documento, ci)
    pulito = not non_girati and not non_scritti
    print("  %s dati veri: le due liste combaciano" % ("OK " if pulito else "MANCATO"))
    if not pulito:
        _racconta(non_girati, non_scritti, len(cancelli_del_documento(documento)))
    esiti.append(pulito)

    if all(esiti):
        print("")
        print("OK  la guardia morde nei due versi, e tace quando le liste combaciano.")
        return 0
    print("")
    print("LA GUARDIA NON MORDE: un controllo che non va rosso sul difetto piantato non esiste.")
    return 1


def main(argv: List[str]) -> int:
    if "--self-test" in argv:
        return _self_test()
    documento, ci = _leggi()
    promessi = cancelli_del_documento(documento)
    if not promessi:
        # Uno zero qui e' la sonda cieca, non un documento senza cancelli: la
        # tabella e' cambiata di forma e nessuno se n'e' accorto.
        print("nessun cancello letto da CLAUDE.md: la tabella «Il giro dei cancelli» "
              "non ha piu' la forma che questa guardia sa leggere")
        return 1
    non_girati, non_scritti = confronta(documento, ci)
    if "--check" in argv:
        if non_girati or non_scritti:
            _racconta(non_girati, non_scritti, len(promessi))
            print("")
            print("ATTENZIONE: il giro dei cancelli di CLAUDE.md e quello della CI "
                  "non sono lo stesso giro.")
            return 1
        print("OK  i %d cancelli di CLAUDE.md sono quelli che la CI gira" % len(promessi))
        return 0
    _racconta(non_girati, non_scritti, len(promessi))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
