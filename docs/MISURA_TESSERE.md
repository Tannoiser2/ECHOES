# ECHOES — tutte le rose possibili, enumerate

<!-- FILE GENERATO — si rifa' con `tools/run_tiles_probe.sh`. -->

La promessa del committente (D-390): *«deve essere calcolato in modo che
ci sia sempre la possibilita' di muoversi in tutte le tessere pescate, e
che quindi non ci siano tessere isolate»*. Non si campiona: si enumera.
Con la rosa (D-510) le rose possibili sono poche abbastanza da guardarle
**tutte**, e questa sonda le stende **col motore**.

```
  7 caselle, 15 tessere nel parco.
    C   2 candidate: REG_EREDAN · REG_EREDAN_SEI_PORTE
    P1  2 candidate: REG_PASSO_CARRI · REG_STRADA_MERCANTI
    P2  2 candidate: REG_PALUDE_CANALI · REG_TERRE_NAHR
    P3  3 candidate: REG_ISOLA_MUTA · REG_MOLO_NUOVO · REG_PORTO_CINERINO
    P4  2 candidate: REG_BOSCO_CONFINI · REG_RADURA_TAGLIATA
    P5  1 candidata: REG_VALLE_VERDE
    P6  3 candidate: REG_BOCCA_MINIERA · REG_MINIERE_ANTICHE · REG_MONTAGNE_ROSSE
  **Rose possibili: 144**

== LA DOMANDA ==
  rose che lasciano una casella vuota        0  (0.000%)
  rose che lasciano una tessera isolata      0  (0.000%)
  strade interrotte (varco contro muro)     288  in tutto, 2.0 per rosa

  **Reti di strade distinte: 12**

  E com'e' fatta la rosa, su tutte:
    confini per mappa      8.67
    tessere con un vicino solo  21.4%

  Le tessere che stanno **dietro** una vicina (non toccano la capitale):
    REG_BOCCA_MINIERA        in 24 rose su 144
    REG_ISOLA_MUTA           in 48 rose su 144
    REG_MINIERE_ANTICHE      in 48 rose su 144
    REG_MOLO_NUOVO           in 24 rose su 144
    REG_MONTAGNE_ROSSE       in 48 rose su 144
    REG_PORTO_CINERINO       in 48 rose su 144
```
