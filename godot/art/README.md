# `godot/art/` — le illustrazioni vere

Qui dentro va l'arte quando arriva. La convenzione è una sola riga: **il nome
del file è la chiave**, con i punti al posto delle barre, in PNG.

| chiave | file |
|---|---|
| `map.board` | `art/map/board.png` — il tabellone dipinto |
| `region.eredan` | `art/region/eredan.png` |
| `asset.force.levy` | `art/asset/force/levy.png` |
| `echo.rupture.betrayal` | `art/echo/rupture/betrayal.png` |

Le chiavi delle carte e delle tessere sono la colonna `art_prompt_key` di
[ASSET_MANIFEST.md](../../docs/ASSET_MANIFEST.md); i prompt da mandare a chi
disegna li genera `tools/run_export.sh` in `brief_arte.md`.

`map.board` è l'unica chiave che non sta nei dati: non appartiene a una Regione
né a una Chronicle, è la mappa, che le due saghe condividono.

## Come si aggiunge

Si copia il PNG al suo posto. Basta questo — anche caricandolo dall'interfaccia
web di GitHub, senza aprire Godot:

- **nel gioco**: se il file c'è si disegna quello, se non c'è si disegna il
  segnaposto generato. Nessuna configurazione, nessun elenco da aggiornare.
- **in stampa**: `tools/run_export.sh` lo incorpora nel foglio SVG come `data:`
  URI, così il foglio resta un file solo.
- **il tabellone**: quando `map.board` esiste, la mappa smette di disegnare il
  terreno generato e usa il quadro. Le posizioni delle Regioni vengono prese
  **alla lettera** dalle `map_position` dei dati, quindi il quadro va dipinto su
  quelle coordinate — è esattamente quello che chiede il prompt del tabellone.

## Cosa deve avere l'immagine

Le regole invalicabili della [ART_BIBLE](../../docs/ART_BIBLE.md): **nessun
testo dentro l'immagine** (nomi, numeri e cornici li compone il gioco) e
**un'area calma** dove andranno i segnalini — bassa sulle carte, al centro di
ogni Regione sul tabellone.
