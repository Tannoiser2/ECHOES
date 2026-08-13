---
name: Una regola da cambiare
about: Una modifica al modo in cui il gioco decide qualcosa
title: ''
labels: regola, da-misurare
assignees: ''
---

## Cosa non va

Cosa fa il gioco oggi, e perché è un problema al tavolo e non solo sulla carta.

## Cosa si è misurato

**Prima di cambiare una regola si misura.** Gli strumenti ci sono:

```bash
godot --headless --path godot --script res://cli/run_playtest.gd -- --runs=100 --seed=7000
godot --headless --path godot --script res://cli/run_balance_probe.gd -- --runs=40
```

Numeri qui — e gli stessi semi di prima, altrimenti si sta misurando la fortuna.

## Cosa si propone

Una leva alla volta.

## Come si vede se ha funzionato

Quali numeri devono muoversi, e di quanto. Se non si può dire prima, non è
ancora una proposta.

<!--
Tre volte la modifica ovvia ha peggiorato le cose: D-051, e due volte in D-055.
Ogni volta se n'è accorto qualcuno che ha misurato dopo.
-->
