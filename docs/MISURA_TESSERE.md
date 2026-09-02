# ECHOES — tutte le pose delle tessere, enumerate

<!-- FILE GENERATO — si rifa' con `tools/run_tiles_probe.sh`. -->

La promessa del committente (D-390): *«deve essere calcolato in modo che
ci sia sempre la possibilita' di muoversi in tutte e sei le tessere
pescate, e che quindi non ci siano tessere isolate»*. Duecento semi sono
un campione; qui ci sono **tutte** le pose che il gioco puo' produrre.

```
  10 tessere nel parco, 6 pescate.
  Pescate possibili: 210
  Ordini per pescata: 720
  **Pose enumerate: 151200**

== LA DOMANDA ==
  pose che lasciano fuori una tessera        0  (0.000%)
  pose che lasciano una tessera isolata      0  (0.000%)
  pescate che si rompono in almeno un ordine  0 su 210

  E com'e' fatta la mappa, su tutte le pose:
    confini per mappa      6.80
    tessere con un vicino solo  6.7%
```
