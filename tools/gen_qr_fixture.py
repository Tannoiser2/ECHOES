#!/usr/bin/env python3
"""L'oracolo del QR (voce 27, D-137).

L'encoder QR della stanza e' scritto a mano in GDScript, e un QR sbagliato
non si vede a occhio: si vede quando quattro persone sono sedute e nessuna
riesce a entrare. Quindi non ci si fida - si confronta con un'implementazione
che non e' la mia, e le matrici attese si congelano qui perche' la suite non
debba dipendere da una libreria:

    pip install qrcode && python3 tools/gen_qr_fixture.py

**Gli oracoli interrogati sono stati due, e non erano d'accordo**: `segno`
aggiunge sempre un byte di zeri dopo il terminatore (`8 - length % 8`, che
vale 8 anche quando il flusso e' gia' allineato), mentre lo standard dice di
aggiungere bit di riempimento *solo* se il flusso non finisce al confine di
un codeword (ISO/IEC 18004 §7.4.10). `qrcode` fa come lo standard, e come
l'encoder della stanza: e' lui l'oracolo. I due QR sono entrambi leggibili -
la differenza vive nella zona di riempimento, che un lettore scarta - ma un
confronto vuole un riferimento solo, e si sceglie quello conforme.

Modo byte imposto: l'encoder della stanza dichiara sempre il modo byte (un
URL ha lettere minuscole e in alfanumerico non entrerebbe), mentre le
librerie da sole scelgono il modo piu' compatto testo per testo. L'oracolo
va interrogato sulla stessa domanda.

Per ogni testo e per ogni maschera: la versione scelta e le righe della
matrice. Confrontare *tutte* le maschere, non solo quella buona, separa i
due difetti possibili - i dati piazzati male e la maschera scelta male.
"""

from __future__ import annotations

import json
import pathlib
import sys

FIXTURE = pathlib.Path(__file__).resolve().parents[1] / "godot/tests/fixtures/qr_golden.json"

# Gli indirizzi che la stanza scrive davvero, dai piu' corti ai piu' lunghi:
# un loopback di prova, una rete di casa, un IP e un token lunghi il massimo.
TEXTS = [
    "ECHOES",
    "http://10.0.0.2:8123/tavolo",
    "http://192.168.1.37:8123/?t=a3f29b1c",
    "http://192.168.100.100:8123/?t=ffff0000",
    "http://192.168.100.100:8123/?t=a3f29b1cdeadbeef0123",
]


def main() -> int:
    try:
        import qrcode
        from qrcode.constants import ERROR_CORRECT_M
        from qrcode.util import MODE_8BIT_BYTE, QRData
    except ImportError:
        print("serve qrcode: pip install qrcode", file=sys.stderr)
        return 2

    def matrix_of(text: str, mask: int | None):
        code = qrcode.QRCode(
            error_correction=ERROR_CORRECT_M, box_size=1, border=0, mask_pattern=mask
        )
        code.add_data(QRData(text, mode=MODE_8BIT_BYTE))
        code.make(fit=True)
        rows = ["".join("1" if module else "0" for module in row) for row in code.get_matrix()]
        return code.version, rows, code.mask_pattern

    golden: dict[str, dict] = {}
    for text in TEXTS:
        by_mask: dict[int, list[str]] = {}
        for mask in range(8):
            version, rows, _ = matrix_of(text, mask)
            by_mask[mask] = rows
            golden[f"{text}|{mask}"] = {"version": version, "rows": rows}
        # E la maschera che sceglie l'implementazione indipendente, per
        # provare anche il punteggio di penalita'. `qrcode` non la dichiara
        # (resta None dopo make), quindi si riconosce: la matrice che sceglie
        # da sola e' identica a una delle otto.
        version, rows, _ = matrix_of(text, None)
        chosen = next((mask for mask, other in by_mask.items() if other == rows), None)
        if chosen is None:
            print(f"la maschera scelta per «{text}» non è una delle otto", file=sys.stderr)
            return 1
        golden[f"{text}|best"] = {"version": version, "mask": chosen}

    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(json.dumps(golden, indent=1, sort_keys=True) + "\n", encoding="utf-8")
    print(f"scritte {len(golden)} matrici attese in {FIXTURE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
