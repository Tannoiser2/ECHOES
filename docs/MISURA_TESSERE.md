# ECHOES — tutte le rose possibili, enumerate

<!-- FILE GENERATO — si rifa' con `tools/run_tiles_probe.sh`. -->

La promessa del committente (D-390): *«deve essere calcolato in modo che
ci sia sempre la possibilita' di muoversi in tutte le tessere pescate, e
che quindi non ci siano tessere isolate»*. Non si campiona: si enumera.
Con la rosa (D-510) le rose possibili sono poche abbastanza da guardarle
**tutte**, e questa sonda le stende **col motore**.

```
  7 caselle, 10 tessere nel parco.
    C   1 candidata: REG_EREDAN
    P1  1 candidata: REG_STRADA_MERCANTI
    P2  2 candidate: REG_PALUDE_CANALI · REG_TERRE_NAHR
    P3  2 candidate: REG_ISOLA_MUTA · REG_PORTO_CINERINO
    P4  1 candidata: REG_BOSCO_CONFINI
    P5  1 candidata: REG_VALLE_VERDE
    P6  2 candidate: REG_MINIERE_ANTICHE · REG_MONTAGNE_ROSSE
  **Rose possibili: 8**

== LA DOMANDA ==
  rose che lasciano una casella vuota        0  (0.000%)
  rose che lasciano una tessera isolata      0  (0.000%)
  varchi che guardano un muro                0  (strade morte)

  E com'e' fatta la rosa, su tutte:
    confini per mappa      8.00
    tessere con un vicino solo  28.6%

  Le tessere che stanno **dietro** una vicina (non toccano la capitale):
    REG_ISOLA_MUTA           in 4 rose su 8
    REG_MINIERE_ANTICHE      in 4 rose su 8
    REG_MONTAGNE_ROSSE       in 4 rose su 8
    REG_PORTO_CINERINO       in 4 rose su 8
```
