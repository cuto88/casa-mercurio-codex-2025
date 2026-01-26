# Report di semplificazione logica

## Mappa attuale dei file
| Nome file | Ruolo | Dipendenze / Collegamenti | Note critiche |
| --- | --- | --- | --- |
| README_struttura_sistemi.md | Panoramica generale su moduli e obiettivi Passivhaus, con mappa percorsi HA/Lovelace | Richiama tutti i moduli e le relative controparti .yaml | Documento guida ma non aggiornato con duplicati attuali |
| _sistema.txt | Schema fisico (Mermaid) di sensori/attuatori VMC, AC, pavimento | Base di riferimento per legare logiche ai dispositivi | Nessun richiamo esplicito agli altri .txt |
| regole_chat_gpt.txt | Linee guida operative per GPT: coerenza file .txt/.yaml/plancia, convenzioni | Collega tutti i sistemi; richiama regole_plancia | Ampia sovrapposizione con regole_plancia sulle plance |
| regole_plancia.txt | Standard di layout/colori e card “Come decide” per tutte le plance | Usata da ogni file *_plancia_regole.txt | Contiene anche riepiloghi logici (VMC, AC, heating, vent) duplicati rispetto ai file specifici |
| 1_vent.txt | Logica ventilazione naturale estiva (criteri ΔT/ΔAH, meteo, night flush) | Autonomo; i criteri sono riportati anche in regole_plancia | Solo descrizione, nessuna sezione di integrazione con altri moduli |
| 1_vent_plancia_regole.txt | Layout plancia ventilazione | Dipende dal set di entità 1_vent/0_sensors | Coerente con regole_plancia; nessuna criticità |
| 2_vmc.txt | Core logic VMC con priorità P0–P4, free-cooling doppio, anti-secco, escalation DRY | Implicita interazione con AC (override DRY) e bagno; sovrapposto alle sintesi in regole_plancia | Priorità descritte solo qui ma replicate in due file plancia |
| 2_vmc_plancia_regole.txt | Layout plancia VMC (versione dettagliata con manuale) | Riferimento a packages/1_ventilation.yaml; usa priorità P0–P4 | Duplica quasi integralmente vmc_plancia_regole.txt |
| vmc_plancia_regole.txt | Altra versione del layout VMC | Stesse dipendenze della precedente | Duplicato con differenze minime di testi/grafici |
| 3_heating.txt | Logica riscaldamento a pavimento (finestra 10–16, target 21 °C, condizioni T/UR) | Collega a sensori zona giorno/notte/bagno; link concettuale a PV/surplus | Molto sintetico, mancano priorità e lock dettagliati |
| 3_heating_plancia_regole.txt | Layout plancia heating con stato, override, KPI e diagnostica | Dipende da packages/2_heating.yaml; richiama soglie/lock | Allineato ma ripete logica già in regole_plancia |
| 4_ac.txt | Logica AC giorno/notte, DRY vs COOL, anti-ciclo e blocco notturno | Punto di contatto opzionale con VMC (blocco VMC) | Molte soglie replicate in regole_plancia |
| 4_ac_plancia_regole.txt | Layout plancia AC con manuale e KPI | Dipende da packages/3_ac.yaml | Nessuna criticità, ma logica descritta altrove |
| 5_pm_plancia_regole.txt | Plancia consumi prese PM (monitoraggio) | Dipende dai sensori PM* del pacchetto energia | Documentazione pura, isolata |
| 6_surplus_plancia_regole.txt | Plancia energia/surplus PV | Dipende da pacchetti energia/surplus | Isolata; logica dei lock energia non documentata altrove |
| 9_debug_sistema_plancia_regole.txt | Plancia di diagnostica incrociata (VMC, AC, heating, vent) | Usa entità chiave di tutti i moduli | Riepiloga logiche già presenti in altri file |
| 9_test_plancia_regole.txt | Plancia sandbox di test | Nessuna dipendenza logica | File minimale |

## Problemi e ridondanze
- **Doppia documentazione VMC:** 2_vmc_plancia_regole.txt e vmc_plancia_regole.txt descrivono lo stesso layout con variazioni minime → rischio divergenza.
- **Riepiloghi logici sparsi:** regole_plancia.txt ripete criteri di VMC, AC, heating e ventilazione già descritti nei rispettivi file, generando duplicati di soglie e priorità.
- **Linee guida generali sovrapposte:** regole_chat_gpt.txt e regole_plancia.txt contengono istruzioni simili su coerenza e layout, ma senza sezione condivisa unica.
- **Assenza di “core rules” riusabili:** ogni modulo descrive soglie/lock senza riferimento a un set di costanti o convenzioni comuni (es. nomenclatura sensori/lock, finestre orarie).
- **Integrazioni incrociate poco formalizzate:** override AC↔VMC, uso surplus↔heating sono citati ma non hanno un punto unico di definizione.

## Proposta di nuova struttura
- **File condivisi:**
  - `regole_core_logiche.md` (nuovo) con convenzioni trasversali: nomenclatura entità standard, schema di priorità, pattern lock/anti-ciclo, convenzioni stagionali/orarie.
  - `regole_plancia.md` (unificato) che contiene solo linee guida UI comuni; spostare i riepiloghi logici nei file dei moduli o nel core.
- **Moduli per dominio:** mantenere 1_vent, 2_vmc, 3_heating, 4_ac, 6_surplus come file di logica principale (testuale) e una sola versione *_plancia_regole.txt per plancia.
- **Rimozione duplicati:**
  - Accorpare 2_vmc_plancia_regole.txt e vmc_plancia_regole.txt in un unico `2_vmc_plancia_regole.txt` (o rinominare l’altro come alias di archivio).
  - Spostare le sintesi logiche da regole_plancia.txt nelle rispettive sezioni dei moduli, lasciando in regole_plancia solo layout/colori.
- **Nuove sezioni condivise:** introdurre in ogni file logico un paragrafo standard “Integrazioni con altri moduli” che rinvia al core per evitare testo duplicato.
- **Naming coerente:** usare prefissi numerici allineati (1_vent, 2_vmc, 3_heating, 4_ac, 5_energy/pm, 6_surplus, 9_debug/test) e mantenere coppie `logica` / `plancia` per ogni modulo.

## Refactoring logico suggerito
- **Ventilazione (1_vent*):** estrarre le soglie ΔT/ΔAH e finestra night-flush in `regole_core_logiche.md`; aggiungere sezione integrazione con VMC/AC per evitare conflitti. Plancia: mantenere un solo file, con card “Come decide” che punta al core.
- **VMC (2_vmc*, vmc_plancia_regole.txt):** consolidare le priorità P0–P4 e override AC in un blocco centrale riusabile (tabella priorità + condizioni ingresso/uscita). Plancia: unificare in un file e referenziare il blocco centrale invece di copiare testo.
- **Riscaldamento (3_heating*):** dettagliare lock min_on/off e criteri PV in un’unica sezione “decisione” e spostare la sintesi oggi dispersa tra regole_plancia e plancia_regole nel file core heating. Plancia: rimandare alla sezione unica.
- **AC (4_ac*):** standardizzare le soglie DRY/COOL e gli anti-ciclo in un blocco parametrico (tabella soglie + lock). Definire chiaramente l’hook opzionale per blocco VMC in una sezione integrazioni.
- **Gestione surplus (6_surplus_plancia_regole.txt):** documentare le logiche di lock/trigger energia in un file dedicato (es. `6_surplus.txt`) referenziato dalla plancia, per allineare il monitoraggio con le regole operative.
- **Debug/test (9_*_plancia_regole.txt):** mantenere file separati ma ridurre duplicazioni di descrizioni logiche riferendosi alle sezioni core dei moduli.
- **Regole globali (_sistema.txt, regole_chat_gpt.txt, regole_plancia.txt):** separare struttura fisica ( _sistema ) dalle linee guida operative (regole_core_logiche + regole_plancia). Snellire regole_chat_gpt per rimandare a questi due file invece di replicare testo.
- **Funzioni/modelli riusabili:** prevedere snippet standard per pattern ricorrenti (es. “lock anti-ciclo: min_on/min_off/max_run”, “arbitraggio top-down con priorità numerate”, “finestra stagionale/oraria”) da includere per riferimento nei moduli senza riscriverli.

## Piano operativo step-by-step
- **Step 1:** creare `regole_core_logiche.md` con convenzioni comuni (nomenclatura sensori, pattern lock, definizione free-cooling, hook AC↔VMC) e aggiornare regole_chat_gpt.txt a rimandare qui.
- **Step 2:** ripulire regole_plancia.txt lasciando solo linee guida UI (layout, colori, sezione “Come decide”) e linkare ai moduli per la logica.
- **Step 3:** unificare la documentazione plancia VMC eliminando il duplicato (mantenere un solo file e archiviare l’altro) aggiornando riferimenti interni.
- **Step 4:** per ogni modulo (1_vent, 2_vmc, 3_heating, 4_ac, 6_surplus) aggiungere sezione standard “Integrazioni con altri moduli” e rimando a regole_core_logiche.md; rimuovere dalle plancia_regole i riepiloghi logici copiati.
- **Step 5:** introdurre (o completare) un file di logica per surplus (`6_surplus.txt`) allineato alla plancia esistente, basato sulle convenzioni core.
- **Step 6:** aggiornare 9_debug_sistema_plancia_regole.txt per citare le sezioni core invece di ripetere le logiche, e 9_test_plancia_regole.txt per rimandare alle regole plancia se usato come template.
- **Step 7:** verifica manuale di coerenza: controllare che ogni plancia abbia un solo riferimento logico e che le soglie siano definite in un punto unico; allineare README_struttura_sistemi.md ai nuovi file core.

## Rischi e punti di attenzione
- Possibile disallineamento temporaneo tra logiche YAML e documentazione se la migrazione non viene svolta modulo per modulo.
- Perdita di dettagli specifici durante la consolidazione (es. note su boost bagno o anti-secco) se non riportati nel file core: serve checklist per ogni priorità/soglia.
- Riferimenti incrociati rotti (link o nomi file) quando si rimuovono duplicati: aggiornare README e plancia_regole contestualmente.
- Compatibilità con utenti: mantenere card “Come decide” leggibile dopo la riduzione del testo, magari sintetizzando con bullet e rimando al file core per i dettagli.
