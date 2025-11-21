# Proposta operativa semplificazione logiche e plance

## 1. Architettura logica futura
```
logica/
├─ core/
│  ├─ regole_core_logiche.md
│  └─ regole_plancia.md
├─ 1_vent/
│  ├─ 1_vent.txt
│  └─ 1_vent_plancia_regole.txt
├─ 2_vmc/
│  ├─ 2_vmc.txt
│  └─ 2_vmc_plancia_regole.txt
├─ 3_heating/
│  ├─ 3_heating.txt
│  └─ 3_heating_plancia_regole.txt
├─ 4_ac/
│  ├─ 4_ac.txt
│  └─ 4_ac_plancia_regole.txt
├─ 5_energy_pm/
│  └─ 5_pm_plancia_regole.txt
├─ 6_surplus/
│  ├─ 6_surplus.txt (nuovo)
│  └─ 6_surplus_plancia_regole.txt
├─ 9_debug_test/
│  ├─ 9_debug_sistema_plancia_regole.txt
│  └─ 9_test_plancia_regole.txt
└─ README_struttura_sistemi.md
```
- **Logica core:** `core/regole_core_logiche.md` gestisce convenzioni, priorità, lock, hook incrociati; `core/regole_plancia.md` contiene solo linee guida UI comuni.
- **Plance:** ogni modulo mantiene un unico `*_plancia_regole.txt` che rimanda a core per logiche condivise; le plance di debug/test restano isolate.
- **Unificazioni:** VMC plancia unificata in un solo file; regole generali spostate da `regole_plancia.txt` a core; surplus ottiene un file logico dedicato.

## 2. Eliminazione duplicati (detailed plan)
| File duplicato | File da mantenere | Parti da spostare | Parti da eliminare | Rischi | Note operative |
| --- | --- | --- | --- | --- | --- |
| 2_vmc_plancia_regole.txt vs vmc_plancia_regole.txt | 2_vmc_plancia_regole.txt | Sintesi condizioni P0–P4 e note manuale → `core/regole_core_logiche.md` (hook VMC↔AC) | Versione alternativa del layout in `vmc_plancia_regole.txt` | Perdita di note minori; link rotti nella UI | Archiviare `vmc_plancia_regole.txt` in cartella _archive e aggiornare riferimenti nelle plance/debug |
| regole_plancia.txt vs regole_chat_gpt.txt | regole_plancia.txt (solo UI) + core/regole_core_logiche.md | Linee guida logiche (soglie, priorità) → core; istruzioni operative GPT → regole_chat_gpt.txt minimale | Riepiloghi logici duplicati in regole_plancia | Mancata copertura di qualche soglia se non trasferita | Creare sezione “rimandi” in regole_chat_gpt.txt verso core/plancia |
| Riepiloghi logici in 9_debug_sistema_plancia_regole.txt | 9_debug_sistema_plancia_regole.txt (solo diagnostica) | Collegamenti a decision tree per VMC/AC/heating → core | Testo duplicato delle logiche | Plancia di debug meno autoesplicativa | Aggiungere link sintetici ai blocchi core invece del testo ripetuto |

## 3. Specifiche del nuovo `regole_core_logiche.md`
- **Contenuti obbligatori**
  - Convenzioni di nomenclatura entità (prefissi 1_vent, 2_vmc, 3_heat, 4_ac, 5_pm, 6_surplus, 9_debug) e mapping verso sensori/attuatori HA.
  - Schema di priorità cross-modulo (P0 emergenza, P1 sicurezza, P2 comfort, P3 efficienza, P4 diagnostica), con trigger e condizioni di uscita standard.
  - Pattern lock: tabella min_on, min_off, max_run per VMC, AC, riscaldamento, surplus load.
  - Regole stagionali/orarie (es. fasce notte/giorno, finestre di ventilazione estiva, blocchi notturni AC).
  - Glossario soglie condivise (ΔT, ΔAH, UR_max, T_target giorno/notte, soglia PV surplus).
- **Convenzioni**
  - Formato tabellare per priorità e lock; uso di “hook” nominati (es. `hook_vmc_block_ac`, `hook_ac_freecooling`).
  - Tutte le logiche devono referenziare il core anziché duplicare testi; ogni modulo dichiara solo eccezioni locali.
- **Schema delle priorità**
  - Tabella con colonne: Priorità, Trigger, Azione, Condizione uscita, Lock applicati, Note cross-modulo.
  - Sequenza di arbitraggio top-down: emergenza → sicurezza → comfort → efficienza → diagnostica.
- **Tabella lock (min_on/min_off/max_run)**
  - VMC: anti-secco/anti-condensa (min_on 5m, min_off 10m), free-cooling (max_run 120m).
  - AC: DRY (min_on 10m, min_off 10m, max_run 60m), COOL (min_on 15m, min_off 15m, max_run 90m), blocco notturno.
  - Heating: circuito pavimento (min_on 15m, min_off 30m, max_run 180m), finestra 10–16.
  - Surplus: caricamenti step (min_on 20m, min_off 20m, max_run 180m) con anticipo pre-carica.
- **Schema anti-secco, free-cooling, override AC↔VMC**
  - Anti-secco: trigger UR interna < soglia, limitare VMC e DRY; priorità P1.
  - Free-cooling: ΔT esterno-interno e ΔAH positivo, check meteo; consente VMC boost e blocco AC.
  - Override AC↔VMC: AC in DRY può chiedere VMC low; AC in COOL blocca VMC se ΔAH sfavorevole; VMC in anti-secco blocca DRY.
- **Hook cross-modulo**
  - `hook_vmc_request_ac_block`, `hook_ac_request_vmc_low`, `hook_surplus_heating_precharge`, `hook_vent_enable_night_flush`, `hook_debug_force_state`.
  - Ogni hook definisce: modulo sorgente, modulo target, evento, payload (boolean/priority), timeout.

## 4. Specifiche della nuova `regole_plancia.md`
- **Deve contenere solo** layout generali (titoli, colonne, card “Come decide”), palette colori per stato (OK/Warning/Errore/Manuale), pattern per badge KPI, legenda icone, convenzioni link ai file logici.
- **Struttura card**: header con stato + icona, corpo con KPI principali, sezione “Come decide” con bullet e link al core/modulo, footer con pulsanti manuali/diagnostica.
- **Cosa NON deve contenere (esplicito)**: soglie numeriche, priorità logiche, testo di decision tree, lock min_on/off, schemi anti-secco/free-cooling; niente riferimenti a sensori specifici (solo placeholder), nessuna regola operativa duplicata.

## 5. Convergenza moduli → standardizzazione
- **Vent**
  - Nel core: definizione ΔT/ΔAH, fasce night-flush, hook con AC/VMC.
  - Nel modulo: casi d’uso locali (apertura/chiusura serramenti), condizioni meteo e allarmi.
  - Plancia: rimuovere logica descrittiva, aggiungere rimando a core e a priorità del modulo.
- **VMC**
  - Nel core: priorità P0–P4, anti-secco, free-cooling, override AC.
  - Nel modulo: implementazione boost bagno, sensori specifici (CO2/UR per zone), eccezioni stagionali.
  - Plancia: eliminare duplicati delle priorità, aggiungere link a tabella core; mantenere solo layout/entità.
- **Heating**
  - Nel core: schema lock pavimento, target T giorno/notte, logica finestra 10–16, eventuale pre-carica da surplus.
  - Nel modulo: tarature per zona giorno/notte/bagno, logica sensori fallback, gestione allarmi.
  - Plancia: togliere descrizione lock e soglie, aggiungere KPI collegati al core (T target, lock attivi).
- **AC**
  - Nel core: soglie DRY/COOL standard, anti-ciclo, override con VMC/free-cooling, blocco notturno.
  - Nel modulo: mapping a climate entity, differenze zona giorno/notte, gestione setpoint manuali.
  - Plancia: rimuovere testo decisionale, lasciare layout e riferimenti agli hook.
- **Surplus**
  - Nel core: criteri generali di surplus/deficit, lock min_on/off per carichi, priorità rispetto ad heating.
  - Nel modulo: mapping a sensori PV/batteria, strategie per carichi specifici (EV, boiler), soglie locali.
  - Plancia: aggiungere KPI standard (produzione, autoconsumo, carico attivo), togliere regole duplicate.

## 6. Sequenza operativa finale (dev-friendly)
1. Creare `core/regole_core_logiche.md` con convenzioni, priorità, hook e tabella lock.
2. Ripulire `core/regole_plancia.md` lasciando solo layout/colori/card e link al core; spostare la logica altrove.
3. Unificare VMC plancia eliminando `vmc_plancia_regole.txt` (archivio) e mantenendo `2_vmc_plancia_regole.txt` con rimando al core.
4. Per ciascun modulo 1_vent, 2_vmc, 3_heating, 4_ac, 6_surplus aggiungere sezione standard “Integrazioni con altri moduli” che usa gli hook del core.
5. Creare `6_surplus.txt` allineato alle convenzioni del core e linkarlo nella plancia esistente.
6. Aggiornare `9_debug_sistema_plancia_regole.txt` e `9_test_plancia_regole.txt` per puntare a core/moduli senza ripetere logica.
7. Rivedere `regole_chat_gpt.txt` per rimandare a core/plancia e snellire duplicati.
8. Validare coerenza: controllare che ogni soglia/lock compaia solo in core o nel modulo, aggiornare README_struttura_sistemi.md con la nuova mappa.

## 7. Impatti sulle YAML
- Blocchi YAML più semplici: automatismi di VMC/AC/heating potranno referenziare soglie comuni dal core, riducendo duplicazioni di condizioni (free-cooling, anti-secco, blocco notturno).
- Sensori come KPI generali: UR_media, ΔT est/int, stato surplus PV, lock attivi potranno essere promossi a template condivisi per più automazioni.
- Automazioni accorpabili: logiche di override AC↔VMC, pre-carica heating da surplus, night-flush, e gestione DRY/anti-secco potranno essere implementate come blueprint riusabili e richiamate dai singoli package.

## 8. Rischi della migrazione e mitigazioni tecniche
- **Disallineamento temporaneo tra plance e logica core** → mantenere checklist per ogni modulo durante la migrazione e link provvisori.
- **Perdita di dettagli specifici durante l’unificazione** → usare tabella di tracciamento per ogni soglia/lock spostato e review incrociata con i file YAML.
- **Hook incrociati non implementati nei package** → prevedere placeholder/flag di feature e toggle YAML prima di attivare blocchi automatici.
- **Refusi nei riferimenti di file** → aggiornare README e plance con percorsi coerenti e validare i link nei commenti YAML.
