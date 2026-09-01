# ECHOES — Lo scheletro delle carte

<!-- GENERATO da `tools/run_card_skeleton.sh` — non si corregge qui. -->

Cosa porta ogni faccia, **ricavato dalle facce vere**: un blocco che
sparisce da una carta sparisce da questa pagina, uno nuovo entra il giorno
che entra. Il numero accanto e' su quante facce del mazzo quel blocco c'e'.

| mazzo | formato | facce | pezzi |
|---|---|---|---|
| **asset** | 63x88 — la carta da gioco che sta in mano | 48 | 132 |
| **echo** | 63x88 — la carta da gioco che sta in mano | 48 | 48 |
| **tension** | 44x68 — la mini che sta accanto a una traccia | 60 | 60 |
| **council** | 70x120 — il tarocco che resta in vista | 60 | 60 |
| **destiny** | 70x120 — il tarocco che resta in vista | 23 | 23 |
| **entity** | 70x120 — il tarocco che resta in vista | 26 | 26 |
| **region** | 80x80 — la tessera quadrata della mappa | 10 | 10 |

## Il mazzo `asset`

La carta che si cala: **tu scegli dove e quale delle due Azioni**.
Arriva con ACQUISIRE, o dalla mappa a inizio Atto. Limite di mano: 7.
Costa 1 Occasione. In alternativa la impegni al Consiglio, e vale forza.

**Lo scheletro** — 63x88 — la carta da gioco che sta in mano, 48 facce, 132 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 48 su 48 |
| il sottotitolo | 48 su 48 |
| la cifra d'angolo | 48 su 48 |
| l'illustrazione | 48 su 48 |
| **DOVE** | 48 su 48 |
| le due Azioni, numerate | 96 su 48 |
| **SEMPRE** | 48 su 48 |
| **AL CONSIGLIO** | 48 su 48 |
| **IMPEGNI** | 48 su 48 |
| **PRENDI ACQUISIRE** | 48 su 48 |

**Una carta vera**, come esce dal foglio di stampa:

> **Censimento**
> autorità · comune
> angolo: **1**
> DOVE  Scegli un luogo con #capitale, #granaio o #commercio. Vale anche il #porto, e ogni luogo del dominio del #territorio.
> ① Contare le teste — Scopri una questione velata che tocca quel luogo, e pesca 1 Sapere.
> ② Contare i sacchi — Togli #razionato o #requisito dal luogo.
> SEMPRE  Potere +1 · se il bersaglio ha #pascolo: +1 ancora e posa #inquieta
> AL CONSIGLIO  1 · +1 se si discute di Potere o Vie
> IMPEGNI  +1 sul suo tema · si scarta se la impegni · costa: dove si discute non e' piu' #contesa
> PRENDI  ACQUISIRE su Autorità. Fonti: Eredan, Terre Nahr, Il Bosco dei Confini.

## Il mazzo `echo`

La carta del Narratore, una funzione di Propp: **tu scegli solo quando**.
Dove cade e cosa lascia lo decide il mondo, non chi la gioca.
Due a testa a inizio Atto, dal sacchetto dell'Atto. Costa 1 Occasione.

**Lo scheletro** — 63x88 — la carta da gioco che sta in mano, 48 facce, 48 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 48 su 48 |
| il sottotitolo | 48 su 48 |
| l'illustrazione | 48 su 48 |
| **QUANDO ESCE** | 43 su 48 |
| **IL MONDO** | 48 su 48 |
| **CONVOCA IL CONSIGLIO** | 9 su 48 |

**Una carta vera**, come esce dal foglio di stampa:

> **Amnistia**
> RISOLUZIONE · funzione di Propp: liberazione
> QUANDO ESCE  e' gia' stata calata una carta Eco di usurpation oppure e' gia' stata calata una carta Eco di prohibition oppure e' gia' stata calata una carta Eco di conquest
> IL MONDO  nel luogo della carta non e' piu' #inquieta · nel luogo della carta non e' piu' #contesa · La Successione scende · il mondo registra: l'amnistia e' stata concessa

## Il mazzo `tension`

La domanda, appoggiata alla traccia dei valori: dice **quando si scalda**.
Non si gioca e non si tiene in mano: sta sul tavolo tutto l'anno.

**Lo scheletro** — 44x68 — la mini che sta accanto a una traccia, 60 facce, 60 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 60 su 60 |
| il sottotitolo | 60 su 60 |
| la cifra d'angolo | 60 su 60 |
| **SI ACCENDE QUANDO** | 60 su 60 |
| **SI RAFFREDDA** | 60 su 60 |
| **AL CONSIGLIO VALGONO** | 60 su 60 |

**Una carta vera**, come esce dal foglio di stampa:

> **La Cenere che Sale**
> domanda velata · l'antico
> angolo: **4**
> SI ACCENDE QUANDO  una Presenza arriva o se ne va da una terra con #cristallo o #selvaggio
> SI RAFFREDDA  Una Confluence risolta su chi tiene d'occhio la montagna.
> AL CONSIGLIO VALGONO  forza, sapere, gente

## Il mazzo `council`

La scheda che si tira fuori quando il Consiglio si apre.
Dice la domanda e **le dodici caselle** con cui il tavolo la risolve.

**Lo scheletro** — 70x120 — il tarocco che resta in vista, 60 facce, 60 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 60 su 60 |
| il sottotitolo | 60 su 60 |
| una riga di testo libero | 120 su 60 |
| **SI OTTIENE** | 60 su 60 |
| una casella, una per riga | 1170 su 60 |
| **SI PAGA** | 60 su 60 |
| **SE CADE** | 60 su 60 |

**Una carta vera**, come esce dal foglio di stampa:

> **La Cenere che Sale**
> il Consiglio che questa domanda apre
> La montagna fuma di nuovo nella Regione di cui si discute: si mette qualcuno a guardarla, o si scrive che ha sempre fumato?
> E le bocche aperte sul fianco, si murano?
> SI OTTIENE
> · Riapri l'accesso: il luogo torna raggiungibile.
> · Il luogo torna raggiungibile.
> · Costruisci 1 Pietra nel luogo: Sito dormiente.
> · Assegna o trasferisci il controllo del luogo.
> · Raffredda il Tema di 1 (minimo 0).
> · Il mondo ricorda: della montagna si e' smesso di parlare.
> · Sposta di 1 indietro il segnalino di La Cenere che Sale.
> · Sposta di 1 indietro il segnalino di La Reliquia.
> · Sito antico del luogo sale di 1 grado.
> SI PAGA
> · Il luogo viene murato: quello che sta sotto resta sotto.
> · Il luogo ottiene #pedaggio.
> · Cedi il controllo del luogo.
> · Scalda il Tema di 1.
> · Al luogo si aggiunge #indebitata.
> · Accetta 1 Cicatrice permanente: la domanda sul muro.
> · Sposta di 1 avanti il segnalino di La Cenere che Sale.
> · Sposta di 1 avanti il segnalino di La Reliquia.
> · Sito antico del luogo scende di 1 grado.
> SE CADE
> · Al luogo si aggiunge #malcontento.
> · Il Tema di questa domanda si scalda di 1.

## Il mazzo `destiny`

L'ambizione di una casa, **dietro il paravento**: la scala per contare.
Non si gioca: si guarda per sapere quanto manca.

**Lo scheletro** — 70x120 — il tarocco che resta in vista, 23 facce, 23 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 23 su 23 |
| il sottotitolo | 23 su 23 |
| l'illustrazione | 23 su 23 |
| **SOGLIA** | 23 su 23 |
| **VITTORIA** | 23 su 23 |
| **TRIONFO** | 23 su 23 |

**Una carta vera**, come esce dal foglio di stampa:

> **Il Regno che Resta**
> Re Aldric
> SOGLIA  Il trono regge: Una pedina dove c'e' il #capitale, o su una terra di #territorio
> VITTORIA  Il regno decide: La corona tiene ancora la sua terra · La Carestia non supera 4
> TRIONFO  Un regno che non ha pagato il pane con il sangue: La terra col #capitale non e' in rivolta · E tre segni che la corona ha retto senza stringere

## Il mazzo `entity`

La casa, in vista tutta la partita: cosa sa fare e cosa vuole lasciare.

**Lo scheletro** — 70x120 — il tarocco che resta in vista, 26 facce, 26 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 26 su 26 |
| il sottotitolo | 26 su 26 |
| l'illustrazione | 26 su 26 |
| **SA FARE** | 26 su 26 |
| **VUOI LASCIARE** | 26 su 26 |
| **SE NON CE LA FAI** | 12 su 26 |

**Una carta vera**, come esce dal foglio di stampa:

> **Re Aldric**
> sovrano · vuole il potere
> SA FARE  acquisire 3 · rivendicare 4 · forgiare 2 · influenzare 4 · muovere 2 · tramare 1
> VUOI LASCIARE  la successione e' passata per legge · la corona · il granaio · l'ordine e' stato ristabilito
> SE NON CE LA FAI  dopo 150 anni con meno di 1 di questi segni: La Repubblica della Valle

## Il mazzo `region`

La tessera di mappa. **Porta i segni** che ogni carta Azione bersaglia.

**Lo scheletro** — 80x80 — la tessera quadrata della mappa, 10 facce, 10 pezzi:

| blocco | su quante facce |
|---|---|
| il titolo | 10 su 10 |
| il sottotitolo | 10 su 10 |
| l'illustrazione | 10 su 10 |
| **VARCHI** | 10 su 10 |
| **SEGNI** | 10 su 10 |
| **CI STANNO** | 10 su 10 |
| **FONTI** | 10 su 10 |

**Una carta vera**, come esce dal foglio di stampa:

> **Il Bosco dei Confini**
> foresta · 3 pedine · 2 Pietre
> VARCHI  destra · sinistra
> SEGNI  dominio: l'antico · #bosco
> CI STANNO  archivio · canale · granaio · presidio · insediamento · pedaggio
> FONTI  autorità, forza
