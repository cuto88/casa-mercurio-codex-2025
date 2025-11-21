# Regole core logiche

Documento di riferimento condiviso per tutti i moduli numerati (1_vent, 2_vmc, 3_heating, 4_ac, 5_energy_pm, 6_surplus, 9_debug/test). Qui si definiscono convenzioni, priorità trasversali, lock e hook incrociati: ogni modulo deve rimandare a queste sezioni evitando duplicazioni locali.

## Convenzioni di nomenclatura
- **Prefissi di modulo**: `1_vent`, `2_vmc`, `3_heat`, `4_ac`, `5_pm`, `6_surplus`, `9_debug`. Usarli sia nei file logici sia nelle entità HA (sensor/switch/input_boolean/input_number).
- **Entità sensori/attuatori standard**: suffissi `_in_giorno`, `_in_notte`, `_in_bagno` per ambienti; `*_out` per meteo esterno; `switch.<modulo>_*` per attuatori; `binary_sensor.<modulo>_*` per flag logici; `input_number.<modulo>_*` per soglie regolabili; `timer.<modulo>_*` per lock/timeout.
- **Manual override**: ogni modulo espone `input_boolean.<modulo>_manual` e, se serve, `input_select.<modulo>_manual_mode` con `timer.<modulo>_manual_timeout` per il rientro automatico.
- **Nomi hook**: sempre snake_case con prefisso `hook_` e indicazione sorgente→target (es. `hook_vmc_request_ac_block`).

## Schema delle priorità (P0–P4)
Arbitraggio top-down: si valuta dal livello più alto al più basso; la prima condizione vera imposta l’azione e applica i lock indicati.

| Priorità | Trigger tipici | Azione standard | Condizione di uscita | Lock applicati | Note cross-modulo |
| --- | --- | --- | --- | --- | --- |
| **P0 – Emergenza/failsafe** | Sensori offline, allarme fumi/allagamento, manual OFF hard | Forzare OFF/vel_0, disabilitare automazioni | Ripristino sensori + ack manuale | min_off di sicurezza | Può essere forzata da 9_debug via `hook_debug_force_state` |
| **P1 – Sicurezza/anti-secco** | UR interna < soglia o rischio condensa; override notturno | Limitare VMC (vel_0/vel_1), preferire DRY minimo, sospendere free-cooling/COOL | UR rientra + timeout lock | min_on/min_off anti-secco | `hook_vmc_request_ac_block` blocca AC se ΔAH sfavorevole |
| **P2 – Comfort** | Boost bagno, richiesta riscaldamento, COOL/DRY attivi, ventilazione estiva | Impostare setpoint/velocità operative del modulo | Uscita da trigger principale + max_run | min_on/min_off specifici | `hook_ac_request_vmc_low` per sincronizzare DRY con VMC low |
| **P3 – Efficienza/ottimizzazione** | Free-cooling, sfruttamento PV, pre-carica heating da surplus | Attivare modalità efficienti (vel_2 VMC, night-flush, pre-carica pavimento, carichi surplus) | Condizione meteo/energia non più valida | max_run efficiency | `hook_surplus_heating_precharge` abilita finestra di carica |
| **P4 – Diagnostica/monitoraggio** | Modalità debug/test attiva | Esporre stati e KPI senza modificare attuatori (read-only) | Manuale | Nessuno | `hook_debug_force_state` può simulare priorità inferiori |

## Tabella lock (min_on / min_off / max_run)
| Modulo | Scenario | min_on | min_off | max_run | Note |
| --- | --- | --- | --- | --- | --- |
| **VMC** | Anti-secco/anti-condensa | 5m | 10m | — | Limitare cicli vel_0/vel_1 in P1 |
| | Free-cooling / night-flush | — | — | 120m | Interrompere se ΔT/ΔAH non più favorevole |
| **AC** | DRY | 10m | 10m | 60m | Richiede ΔAH favorevole o VMC low |
| | COOL | 15m | 15m | 90m | Blocchi notturni 23–7 gestiti come P0 locale |
| **Heating** | Pavimento inerziale | 15m | 30m | 180m | Fascia attiva 10:00–16:00 salvo emergenza | 
| **Surplus** | Carichi a step | 20m | 20m | 180m | Coordinare con PV/batteria e pre-carica heating |

## Regole stagionali e orarie
- **Fasce notte/giorno**: AC blocco 23:00–07:00 salvo override manuale; ventilazione night-flush 21:00–08:00.
- **Finestre pavimento**: heating prioritizza 10:00–16:00 per sfruttare PV/guadagni solari, con deroga P0/P1.
- **Ventilazione estiva**: preferire aperture quando ΔT_out<in e ΔAH_out<in; sospendere con vento forte/pioggia/PM alti.

## Glossario soglie condivise
- **ΔT**: differenza T_in−T_out; **ΔAH**: differenza AH_in−AH_out.
- **UR_max**: soglia igrometrica che separa anti-secco (bassa UR) da condensa (alta UR).
- **T_target giorno/notte**: setpoint comfort; modulabile per heating/AC.
- **Soglia surplus PV**: potenza minima disponibile per attivare carichi step (rif. 6_surplus.txt).

## Pattern funzionali
- **Anti-secco**: se UR_in < UR_min → VMC in vel_0/vel_1 e DRY minimo; rientro quando UR_in ≥ UR_min+isteresi. Priorità P1, applica lock anti-secco.
- **Free-cooling**: attivo se ΔT_out<in < −ΔT_fc e ΔAH_out<in < −ΔAH_fc con meteo ok; eleva VMC (vel_2) e blocca COOL tramite `hook_vmc_request_ac_block`. Max_run 120m.
- **Override AC↔VMC**: AC in DRY richiede VMC low (`hook_ac_request_vmc_low`); AC in COOL può bloccare VMC se ΔAH sfavorevole; VMC in anti-secco può bloccare DRY.

## Hook cross-modulo
Ogni hook definisce: sorgente, target, evento, payload (boolean/priority), timeout.

| Hook | Sorgente → Target | Evento/Payload | Timeout | Effetto atteso |
| --- | --- | --- | --- | --- |
| `hook_vmc_request_ac_block` | VMC → AC | boolean `ac_block` per ΔAH sfavorevole o free-cooling attivo | fino a fine max_run VMC | AC sospende COOL/DRY |
| `hook_ac_request_vmc_low` | AC → VMC | richiesta `vmc_low` durante DRY per evitare condensa | lock DRY | VMC forza vel_0/vel_1 |
| `hook_surplus_heating_precharge` | Surplus → Heating | boolean `precharge_enable` quando PV > soglia e batteria ok | 180m | Heating anticipa accensione in fascia utile |
| `hook_vent_enable_night_flush` | Vent → VMC/AC | flag `night_flush` per aprire serramenti/vel_2 VMC con meteo ok | 120m | Favorisce free-cooling serale |
| `hook_debug_force_state` | Debug → Tutti | payload `priority_override` per simulazioni/test | 15m | Plancia debug forza priorità e traccia effetti |

## Uso del core nei moduli
- Ogni file logico locale descrive solo eccezioni/parametri specifici (sensori, soglie custom). Le regole comuni rimandano a questo documento.
- Le plance devono citare le sezioni **Priorità**, **Lock** e **Hook** senza ripeterne i dettagli numerici.
