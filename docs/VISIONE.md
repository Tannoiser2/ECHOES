# ECHOES — l'idea di partenza, e il gioco che c'è

**A cosa serve questo documento.** Il committente ha descritto ECHOES prima che
esistesse, e dopo centonovantadue versioni ha chiesto la cosa giusta: *«vorrei
capire se il gioco attuale ci va vicino o si è allontanato parecchio»*.

Questo è il confronto, punto per punto, **letto dai dati e dal codice** e non
dalla memoria di chi l'ha scritto. Ogni riga porta dove si verifica.

La risposta corta: **diciotto punti su venti sono in piedi e funzionanti.** Le
due cose che mancano non sono dettagli, e in tutti e due i casi **l'idea di
partenza è più ambiziosa di quello che è stato costruito**, non meno.

Versione confrontata: **0.1.192**.

---

## L'idea, come è stata detta

> Dieci partite che rappresentano una saga, ogni partita una Chronicle di un anno
> in cui succedono cose che modellano il mondo. La Chronicle successiva si modella
> in base a quello che è successo in quella precedente, può cambiare il mondo, i
> protagonisti, e ci possono essere salti temporali anche di secoli. I giocatori
> giocano "entità", che possono essere singoli individui, popoli, gruppi di
> persone, confraternite, culti e perfino mostri immortali, che si trasformano nel
> tempo. Ogni entità ha un obiettivo palese e tre segreti che si pescano
> all'inizio della saga. Poi si pescano 4 domande o problemi che si "scaldano"
> durante un atto (ogni Chronicle è di tre o più atti); alla fine di esso chi si è
> scaldato di più viene dibattuto nel Concilio, in cui i giocatori possono usare
> le carte per manipolare il risultato o possono essere aiutati da quello che si è
> creato nella mappa durante la partita. Le carte vengono pescate all'inizio
> dell'atto in base a dove i giocatori hanno presenza, e oltre a essere usate nel
> Concilio possono essere usate per fare Azioni o per usare le loro abilità
> uniche. Alla fine della Chronicle, in base agli obiettivi raggiunti, ogni entità
> ha un grado di vittoria. Alla fine della saga si contano tutti i gradi per
> vedere chi ha vinto. Ogni nuova Chronicle ha un meccanismo che decide come fare
> il setup, quanti anni sono passati, com'è cambiato il mondo, quali entità ci
> saranno.

---

## Il quadro

| # | l'idea | il gioco | dove |
|---|---|---|---|
| 1 | dieci partite = una saga | ✅ `decides_after: 10`, catena infinita | `chronicle_controller.gd` |
| 2 | ogni partita è un anno | ✅ 3 Atti × 3 round × 2 azioni | `chronicle_0*.json` |
| 3 | l'anno dopo si modella su quello prima | ✅ e in profondità | `inheritance_effects()` |
| 4 | salti anche di secoli | ⚠️ **massimo 200 anni** | `years_after_previous` |
| 5 | il mondo cambia | ✅ con una regola su cosa resta | `INHERITED_TAG_PREFIXES` |
| 6 | i protagonisti cambiano | ✅ 3–4 incarnazioni per entità | `succession.gd` |
| 7 | entità di ogni natura | ✅ sei archetipi | `entities/*.json` |
| 8 | quali entità ci saranno | ✅ 4 pescate fra 8 | `resolve_seats()` |
| 9 | 1 palese + 3 segreti **a inizio saga** | ⚠️ **ripescati ogni anno** | `_deal_objectives()` |
| 10 | 4 domande pescate | ✅ 4 su 12 | `resolve_tensions()` |
| 11 | si scaldano durante l'Atto | ✅ un gettone per azione, coperto | `tension_tokens` |
| 12 | la più calda va al Concilio a fine Atto | ✅ | `_council_at_end_of_act()` |
| 13 | tre o più Atti | ✅ 3, ed è un dato | `acts` |
| 14 | le carte manipolano il risultato | ✅ | `confluence_resolution.gd` |
| 15 | **aiutati da quello creato sulla mappa** | ❌ **la mappa non entra nel voto** | vedi sotto |
| 16 | carte a inizio Atto secondo la presenza | ✅ e la Regione decide la famiglia | `_refill_hands()` |
| 17 | carte = Concilio + azione + abilità | ✅ 48 su 48 | `assets/*.json` |
| 18 | grado di vittoria a fine anno | ✅ NONE / MINIMUM / VICTORY / TRIUMPH | `destiny_evaluator.gd` |
| 19 | somma dei gradi a fine saga | ✅ `[-1, 1, 2, 5, 8]` | `_settle_saga()` |
| 20 | ogni Chronicle decide il proprio setup | ✅ | `world_state_factory.gd` |

---

## Quello che c'è, e come

### Il mondo che si eredita, con un criterio

Passano il controllo delle Regioni, i tag, **le strutture con tipo, grado e
padrone**, le relazioni e i Destini. Con due regole che il gioco ha guadagnato
strada facendo e che l'idea di partenza non chiedeva:

- **quello che è murato o scritto resta** — pietre, insediamenti, cicatrici —
  mentre una *condizione* sociale sbiadisce dopo cinquant'anni. Un lutto
  dell'anno 1002 non è ancora in corso otto secoli dopo; la cicatrice resta a
  raccontarlo ([D-078](DECISIONS.md#d-078)).
- **non si governa dove non si è**: una Regione tenuta a fine anno senza nessuno
  dentro decade prima che il nuovo apra ([D-027](DECISIONS.md#d-027)). Una
  dinastia che si è allargata troppo perde i bordi per primi, e nessuno deve
  averglieli tolti.

### I protagonisti che si trasformano

**L'id è il seggio, non la persona.** `ENT_ALDRIC` è la casa che tiene Eredan;
chi siede sulla sedia è stato del mondo, e cambia quando passa abbastanza tempo.

| entità | le sue vite |
|---|---|
| Re Aldric | → La Reggenza del Granaio → La Repubblica della Valle → La Corona Restaurata |
| Vaerax | → Vaerax Ridestato → Il Culto della Montagna → La Leggenda della Montagna |
| Lyra | → L'Accademia delle Misure → Il Culto della Misura |
| Popolo Nahr | → Il Regno di Nahr → La Diaspora di Nahr |
| Maestra Ilve | → Il Banco Nero → La Compagnia del Sale |
| Priore Anselmo | → L'Inquisizione del Vetro → I Frati del Vetro |
| Kessa dei Fuochi | → I Forni Riaccesi → Le Custodi della Cenere |
| Le Città Libere | → La Lega delle Sette → L'Egemonia di Eredan |

Il mostro immortale che diventa un culto e poi una leggenda c'è, ed è Vaerax.

Gli archetipi coprono tutte e sei le nature elencate: `SOVEREIGN`, `PEOPLE`,
`INDIVIDUAL`, `CREATURE`, `FACTION`, `CULT`.

### La memoria che guida la pesca

Non solo il mondo si eredita: **la pesca dell'anno dopo ascolta**. Una domanda i
cui segni dichiarati sono rimasti sul tavolo — un fatto globale, la sua leggenda,
un tag di Regione — pesa **il triplo** ([D-079](DECISIONS.md#d-079)). L'era
successiva cresce da quella prima invece di essere pescata alla cieca.

E il Destino ha già respiro di saga: **chi ha ottenuto quello che voleva ne vuole
un altro, chi non l'ha ottenuto riprova** — e dopo tre delusioni un erede smette
di giurare su un'ambizione fallita ([D-081](DECISIONS.md#d-081)).

---

## Le due divergenze

### A. Gli obiettivi coperti si pescano ogni anno, non a inizio saga

L'idea dice *«tre segreti che si pescano all'inizio della saga»*.
`WorldStateFactory._deal_objectives` gira dentro il setup **di ogni Chronicle**.

Metà del modello c'è già — il **palese** attraversa gli anni con la regola di
D-081 — ma i tre coperti no.

**Perché non è un dettaglio.** Sposta l'unità dell'ambizione. Con obiettivi di
saga, al terzo anno stai costruendo verso qualcosa che nessuno ha visto, e una
mossa che sembra sbagliata oggi può essere il quarto passo di un piano di otto.
Con obiettivi d'anno, **ogni Chronicle è un contenitore chiuso** e la campagna è
una somma di partite invece di una storia sola.

→ **ISSUES 58.**

### B. La mappa non paga dove il gioco si decide

L'idea dice che al Concilio si può essere *«aiutati da quello che si è creato
nella mappa»*. La matematica del voto è:

```
M = Sostegno + Condizione − Opposizione + 1d6
```

**Correzione (0.1.195).** La prima stesura di questa sezione diceva che «nessuna
pietra, nessuna maggioranza, nessuna cicatrice entra in quel conto». **Era
sbagliato, e nel modo peggiore: sbagliato sul meccanismo.** Rileggendo
`confluence_controller.gd` fino in fondo — non solo `confluence_resolution.gd` —
il conto vero e':

```
M = Sostegno + Condizione − Opposizione + Fattore Mondo
```

e dentro ci entrano gia' tre cose che non sono carte:

- **i legami** (`alliance_weight`, [D-139](DECISIONS.md#d-139)): un alleato che
  sostiene e ci mette del proprio parla piu' forte. **Dichiarato in tutte e
  quattro le Chronicle.**
- **i segni, sul Fattore Mondo** (`COUNCIL_MODIFIER`): diciassette regole
  attive, fra cui tre cicatrici (`scar:broken_bridge`, `scar:changed_hands`,
  `scar:the_empty_chair`), una Regione affamata, la fama, e
  `settlement:city` — cioe' **una pietra alzata a citta'**.
- **due incarnazioni, sul fronte** (`STANCE_MODIFIER`).

Quindi la mappa il Consiglio lo tocca. Quello che **non** entra e' il pezzo
preciso che il committente chiede da tre cicli: **il titolo e la maggioranza
nella Regione di cui si discute.**

E il motivo e' molto piu' interessante di «non e' stato costruito».

La mappa conta, ma **sempre di lato**:

| la mappa decide | come |
|---|---|
| chi propone | più presenza nella Regione di cui si discute |
| quante carte peschi | `presenze × 2 + Regioni controllate × 1` |
| **che** carte peschi | le famiglie della Regione dove tieni la pedina |
| quali proposte sono ammissibili | `state_tag_present` |

E l'ultima riga è più sottile di quanto sembri: su **43 proposizioni** in dieci
template di Concilio ci sono **10 condizioni di idoneità in tutto**. Trentatré
proposizioni su quarantatré sono ammissibili **comunque sia messa la mappa**.

**La leva esiste, ed è spenta.** `confluence_rules.focus_weight`
([D-154](DECISIONS.md#d-154)) fa esattamente quello: al Consiglio, la Regione di
cui si discute dà voce a chi la **tiene** e a chi ci sta **in forze**. È scritta,
provata da sette test, e **nessuna delle quattro Chronicle spedite la dichiara**
— e una dichiarazione vuota vuol dire assenza.

**Perché fu spenta, e perché quel motivo non vale più.** D-154 la misurò a
0.1.119: i Consigli falliti scendevano da 177 a 175, ma il playtest passava da
**0/8 a 1/8**, e il seggio che si rompeva era sempre lo stesso — Kessa dei
Fuochi. D-154 stesso concluse che non era il peso della terra a romperla, ma che
**la sua Vittoria aveva una porta sola** (`control_count >= 2`), e scrisse:
*«ISSUES 38 viene prima. Fino a che resta aperta, qualunque modifica alle regole
del Consiglio ha una probabilità alta di essere respinta da Kessa e non dal
proprio merito.»*

**ISSUES 38 è chiusa da 0.1.122**, e da [D-198](DECISIONS.md#d-198) i gradini
sono diventati quattro obiettivi, tre dei quali pescati. La Vittoria di Kessa
oggi ha tre clausole, non una. **Il motivo per cui la leva è spenta ha smesso di
valere settantadue versioni fa, e nessuno l'ha riaccesa.**

Questa è la vera radice di [ISSUES 55](ISSUES.md), ed è una buona notizia: non è
un progetto di design, è **una riga di dato e una misura**.

### C. E una piccola: i secoli sono due

`years_after_previous: {min: 20, max: 200}`. Due secoli, non «secoli». È un dato e
si cambia in una riga — ma va deciso, perché il decadimento delle condizioni è
tarato su cinquanta anni e un salto di ottocento anni vorrebbe regole sue.

---

## Cosa se ne fa

Il gioco **non si è allontanato**: si è allontanato in due punti precisi, e la
seconda divergenza spiega un difetto che stiamo inseguendo da tre cicli senza
chiuderlo.

L'ordine che propongo, con la regola di casa — **si misura prima di scrivere**:

1. **La mappa paga al Concilio** (ISSUES 55, radice B). Sblocca anche il resto.
2. **Gli obiettivi coperti diventano di saga** (ISSUES 58).
3. I secoli, se il committente li vuole davvero lunghi.

---

*Questo documento si aggiorna quando una delle divergenze si chiude. Se un giorno
tutte e tre le righe ⚠️/❌ diventano ✅, il documento resta come verbale di dov'era
il gioco a 0.1.192.*
