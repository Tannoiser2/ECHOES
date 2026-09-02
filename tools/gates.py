#!/usr/bin/env python3
"""**Il giro dei cancelli, in un comando solo.**

    python3 tools/gates.py               # la corsia veloce: tutto sotto i dieci secondi
    python3 tools/gates.py --lenti       # le sei sonde lunghe, prima della PR
    python3 tools/gates.py --tutti       # il giro intero, quello che gira la CI
    python3 tools/gates.py --rigenera    # rifa' i documenti generati invece di controllarli
    python3 tools/gates.py --rigenera --lenti   # ...e quelli delle sonde lunghe
    python3 tools/gates.py --rigenera --tutti   # ...tutti quanti
    python3 tools/gates.py --elenco      # dice cosa girerebbe, e quanto costa, senza girare
    python3 tools/gates.py --self-test   # che questa non abbia perso un cancello per strada

**La lista non sta qui.** Sta nella tabella di CLAUDE.md, che e' il contratto con
chi lavora qui, ed e' la stessa che `gates_survey.py` tiene uguale alla CI. Una
seconda lista scritta a mano si sarebbe scostata dalla prima entro la settimana:
in questo progetto e' gia' successo fra il documento e la CI, **nei due versi**.

## Perche' esiste

Il committente, 0.1.389: *«31 cancelli e 100 semi sono troppi, bisognerebbe fare
una pulizia»*. Li ho cronometrati prima di tagliare, ed erano il sospettato
sbagliato:

| | quanti | costo |
|---|---|---|
| i cancelli sotto i dieci secondi | 25 | **~20 s in tutto** |
| le sonde lunghe | 6 | il resto |

Venticinque cancelli su trentuno costano meno di venti secondi **tutti insieme**.
Toglierne uno non fa risparmiare niente e toglie una guardia: la pulizia giusta
non e' **meno cancelli**, e' **meno comandi da ricordare** e i sei lenti in una
corsia a parte.

## La corsia lenta non si salta: si sposta

`--lenti` non e' un cancello facoltativo. E' l'insieme di quelli che si girano
**prima di aprire la PR** invece che dopo ogni modifica — e la CI li gira
comunque tutti. Un cancello che non gira non si lamenta
([gates_survey.py](gates_survey.py)), e questo strumento non ne toglie nessuno.
"""
from __future__ import annotations

import re
import subprocess
import sys
import time
from pathlib import Path
from typing import List, NamedTuple

sys.path.insert(0, str(Path(__file__).resolve().parent))

import gates_survey  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parent.parent
GODOT_PREDEFINITO = "~/godot/Godot_v4.7.1-stable_linux.x86_64"

# La riga della tabella dei cancelli, adesso a tre campi: comando, costo, cosa
# sorveglia. Il costo e' un numero di secondi misurato, dichiarato nel documento
# come vuole la seconda regola di casa — **quello che non e' misurato va
# dichiarato**, e un costo scritto e' un costo che si puo' contestare.
RIGA = re.compile(r"^\|\s*`([^`]+)`\s*\|\s*([0-9]+(?:[.,][0-9]+)?)\s*s?\s*\|")

# Sotto questo, il cancello si gira a ogni passo. Sopra, prima della PR.
CONFINE_SECONDI = 10.0


class Cancello(NamedTuple):
    comando: str
    costo: float

    @property
    def lento(self) -> bool:
        return self.costo >= CONFINE_SECONDI

    @property
    def rigenera(self) -> str:
        """Lo stesso cancello, ma che **scrive** invece di controllare.

        Ogni cancello su un documento generato e' lo stesso strumento con
        `--check`: toglierlo lo fa rigenerare. Quelli senza `--check` non
        generano niente, e per loro non c'e' niente da rifare.
        """
        for bandiera in ("--check-brief", "--check"):
            if self.comando.endswith(" " + bandiera):
                return self.comando[: -len(bandiera) - 1].strip()
        return ""


def cancelli() -> List[Cancello]:
    """I cancelli della tabella di CLAUDE.md, nell'ordine in cui li promette."""
    testo = (REPO_ROOT / "CLAUDE.md").read_text(encoding="utf-8")
    fuori: List[Cancello] = []
    for riga in testo.splitlines():
        trovato = RIGA.match(riga)
        if trovato and gates_survey.STRUMENTO.search(trovato.group(1)):
            costo = float(trovato.group(2).replace(",", "."))
            fuori.append(Cancello(trovato.group(1).strip(), costo))
    return fuori


def _gira(comando: str) -> tuple[int, float]:
    """Un cancello, col suo tempo. **Dei cancelli si guarda il codice di uscita.**"""
    inizio = time.monotonic()
    esito = subprocess.run(
        comando,
        shell=True,
        cwd=REPO_ROOT,
        executable="/bin/bash",
        env=_ambiente(),
    )
    return esito.returncode, time.monotonic() - inizio


def _ambiente() -> dict:
    import os

    fuori = dict(os.environ)
    fuori.setdefault("GODOT", str(Path(GODOT_PREDEFINITO).expanduser()))
    return fuori


def _corsia(quali: List[Cancello], titolo: str, rigenerando: bool = False) -> int:
    print("IL GIRO DEI CANCELLI — %s (%d, ~%d s)" % (
        titolo, len(quali), round(sum(c.costo for c in quali))
    ))
    print("")
    rotti: List[str] = []
    for cancello in quali:
        comando = cancello.rigenera if rigenerando else cancello.comando
        if not comando:
            continue
        print("  ▸ %s" % comando, flush=True)
        codice, secondi = _gira(comando)
        stato = "OK " if codice == 0 else "ROSSO"
        print("  %s %5.1f s  %s" % (stato, secondi, comando), flush=True)
        print("")
        if codice != 0:
            rotti.append(comando)
    if rotti:
        print("ROSSO su %d cancelli su %d:" % (len(rotti), len(quali)))
        for comando in rotti:
            print("  %s" % comando)
        return 1
    print("OK  tutti e %d." % len(quali))
    return 0


def _elenco(tutti: List[Cancello]) -> int:
    veloci = [c for c in tutti if not c.lento]
    lenti = [c for c in tutti if c.lento]
    print("IL GIRO DEI CANCELLI — %d in tutto" % len(tutti))
    print("")
    for titolo, quali in (("VELOCI (a ogni passo)", veloci), ("LENTI (prima della PR)", lenti)):
        print("  %s — %d, ~%d s" % (titolo, len(quali), round(sum(c.costo for c in quali))))
        for cancello in quali:
            rifa = "  → rigenera: %s" % cancello.rigenera if cancello.rigenera else ""
            print("    %6.1f s  %s%s" % (cancello.costo, cancello.comando, rifa))
        print("")
    return 0


def _self_test() -> int:
    """**Che questa non abbia perso un cancello per strada.**

    E' la guardia che conta: uno strumento che gira ventotto cancelli su
    trentuno non si lamenta — da' verde piu' in fretta, ed e' esattamente il
    modo in cui una pulizia diventa un buco.
    """
    esiti = []
    letti = cancelli()
    promessi = gates_survey.cancelli_del_documento(
        (REPO_ROOT / "CLAUDE.md").read_text(encoding="utf-8")
    )

    mancanti = [c for c in promessi if c not in {x.comando for x in letti}]
    ok = not mancanti
    print("  %s ogni cancello promesso ha il suo costo scritto" % ("OK " if ok else "MANCATO"))
    if mancanti:
        for comando in mancanti:
            print("      senza costo: %s" % comando)
    esiti.append(ok)

    ok = len(letti) == len(promessi) and len(letti) > 25
    print("  %s se ne leggono %d, e la tabella ne promette %d" % (
        "OK " if ok else "MANCATO", len(letti), len(promessi)
    ))
    esiti.append(ok)

    # Un costo tolto dalla tabella: la guardia lo vede.
    testo = (REPO_ROOT / "CLAUDE.md").read_text(encoding="utf-8")
    monco = re.sub(r"^(\|\s*`python3 tools/dead_code\.py`\s*)\|[^|]*\|", r"\1|", testo, flags=re.M)
    quanti = len([r for r in monco.splitlines() if RIGA.match(r)])
    ok = quanti == len(letti) - 1
    print("  %s e un costo tolto la fa scendere di uno: %d" % ("OK " if ok else "MANCATO", quanti))
    esiti.append(ok)

    # Le due corsie coprono tutto: nessun cancello resta fuori da entrambe.
    veloci = [c for c in letti if not c.lento]
    lenti = [c for c in letti if c.lento]
    ok = len(veloci) + len(lenti) == len(letti) and veloci and lenti
    print("  %s le due corsie insieme sono il giro intero (%d + %d)" % (
        "OK " if ok else "MANCATO", len(veloci), len(lenti)
    ))
    esiti.append(ok)

    if all(esiti):
        print("")
        print("OK  il giro in un comando e' lo stesso giro della tabella.")
        return 0
    print("")
    print("LA GUARDIA NON MORDE: un giro che perde un cancello da' verde piu' in fretta.")
    return 1


def main(argomenti: List[str]) -> int:
    tutti = cancelli()
    if not tutti:
        print("Nessun cancello letto da CLAUDE.md: la tabella ha ancora due colonne?")
        return 1
    if "--self-test" in argomenti:
        return _self_test()
    if "--elenco" in argomenti:
        return _elenco(tutti)
    if "--rigenera" in argomenti:
        # Le corsie valgono anche qui: rigenerare **tutto** vuol dire rigirare le
        # sonde lunghe, e sono quindici minuti. Di solito il documento vecchio e'
        # uno dei veloci.
        quali = [c for c in tutti if c.rigenera]
        titolo = "rigenero i documenti veloci"
        if "--tutti" in argomenti:
            titolo = "rigenero tutti i documenti"
        elif "--lenti" in argomenti:
            quali = [c for c in quali if c.lento]
            titolo = "rigenero i documenti delle sonde lunghe"
        else:
            quali = [c for c in quali if not c.lento]
        return _corsia(quali, titolo, rigenerando=True)
    if "--tutti" in argomenti:
        return _corsia(tutti, "il giro intero")
    if "--lenti" in argomenti:
        return _corsia([c for c in tutti if c.lento], "corsia lenta, prima della PR")
    return _corsia([c for c in tutti if not c.lento], "corsia veloce")


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
