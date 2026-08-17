#!/usr/bin/env python3
"""Un PDF, non venticinque SVG (ISSUES voce 8).

Prende i fogli A4 che `run_export.gd` ha scritto e ne fa un unico PDF con le
pagine in ordine di mazzo — l'ordine in cui una tipografia se le aspetta:
Asset, Echo, Tensioni, Destini, Casate, Regioni. Gli SVG restano la sorgente
diffabile che la CI confronta; il PDF e' il formato di consegna.

    python3 tools/make_pdf.py [out/export/fogli] [out/export/echoes_print.pdf]

Dipendenze: cairosvg e pypdf. Se mancano, lo dice e esce con errore — questo
passo e' opzionale per la CI, obbligatorio solo per chi stampa.
"""

import io
import sys
from pathlib import Path

# L'ordine di consegna: lo stesso dell'export, che e' l'ordine del manifest.
# I segnalini e la traccia (D-097) chiudono il fascicolo, dopo i mazzi. Il
# sort_key spoglia l'ultimo suffisso numerico, quindi i nomi qui sono i gambi.
DECK_ORDER = [
    "asset", "echo", "tension", "destiny", "entity", "region",
    "segnalini_chr", "segni", "traccia",
]


def sort_key(path: Path):
    stem = path.stem
    deck = stem.rsplit("_", 1)[0]
    rank = DECK_ORDER.index(deck) if deck in DECK_ORDER else len(DECK_ORDER)
    return (rank, stem)


def main() -> int:
    try:
        import cairosvg
        from pypdf import PdfReader, PdfWriter
    except ImportError as missing:
        print(f"manca una dipendenza: {missing.name} — pip install cairosvg pypdf", file=sys.stderr)
        return 2

    root = Path(__file__).resolve().parent.parent
    sheets_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "out" / "export" / "fogli"
    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else sheets_dir.parent / "echoes_print.pdf"

    sheets = sorted(sheets_dir.glob("*.svg"), key=sort_key)
    if not sheets:
        print(f"nessun foglio SVG in {sheets_dir} — prima tools/run_export.sh", file=sys.stderr)
        return 1

    writer = PdfWriter()
    for sheet in sheets:
        # Ogni foglio e' gia' A4 in millimetri: la conversione non riscala.
        page_pdf = cairosvg.svg2pdf(url=str(sheet))
        reader = PdfReader(io.BytesIO(page_pdf))
        for page in reader.pages:
            writer.add_page(page)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "wb") as handle:
        writer.write(handle)
    print(f"OK  {out_path}  ({len(sheets)} pagine)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
