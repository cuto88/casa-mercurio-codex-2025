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

## VMC — Priorità, lock e schemi
Tabella riassuntiva delle priorità specifiche VMC (top-down). Le soglie numeriche seguono i valori standard Casa Mercurio: UR bagno ON≈75%, OFF≈65%, ΔUR boost≈10pt; soglia UR bassa≈40%; free-cooling con T_in>24 °C, T_out<T_in, AH_out<AH_in.

| Priorità | Trigger | Azione | Uscita | Lock applicati | Note |
| --- | --- | --- | --- | --- | --- |
| **P0 – Failsafe/override AC** | Sensori critici mancanti/allarmi; AC notte in DRY → richiesta vel_0 | Forza vel_0 e disabilita automazioni | Ripristino sensori o AC esce da DRY | min_off sicurezza | Watchdog ripristina vel_1 se inattivo >10m |
| **P1 – Boost bagno / ΔUR alto** | UR bagno sopra soglia o ΔUR bagno/esterno ≥10pt | Vel_3 (boost), downgrade a vel_2 se esterno molto più secco | UR rientra sotto soglia + ΔUR ridotto | min_on 10m, cooldown 5m | Scavalca free-cooling; può attivare escalation DRY |
| **P1-lite – ΔUR interno/esterno** | UR_media >50% e ΔUR_media≥10pt con bagno non in boost | Vel_2 | ΔUR_media <8pt o UR_media ≤48% o runtime 8m o AH_out≥AH_in | min_on 5m | Subordinato a P1 e P2 |
| **P1B – Supporto AC DRY** | Boost bagno attivo da lungo tempo e UR ancora alta | Richiede AC in DRY mantenendo VMC vel_1 | UR sotto isteresi o max_run 120m | min_on AC 30m | Usa `hook_vmc_request_ac_block` al rilascio |
| **P2 – Free-cooling** | Condizioni termo-igrometriche favorevoli (vedi schema) | Vel_2 e blocco COOL/DRY se ΔAH sfavorevole | ΔT/ΔAH non più validi | min_on 15m, max_run 120m | Prevale schema PASSIVHAUS se valido |
| **P3 – Anti-secco notturno** | Nov–Mar, 23–07, UR_in_min ≤40% e nessun boost bagno | Vel_0 con duty vel_1 5m ogni 30m; blocca richieste DRY | Fine finestra o UR >42% | min_on 5m, min_off 10m | Può inibire AC DRY tramite hook |
| **P4 – Baseline** | Nessun trigger attivo | Vel_1 continuo | Pre-emption da priorità superiori | — | Funzione anche da fallback watchdog |

### Schema free-cooling VMC
- **Passivhaus (preferito)**: T_in >24 °C, T_out < T_in, AH_out < AH_in; uscita con T_in ≤23.2 °C oppure T_out ≥ T_in oppure AH_out ≥ AH_in.
- **Modalità macchina (solo termico)**: T_in >24 °C, T_out < T_in e >20 °C; uscita con T_in ≤23.2 °C oppure T_out ≤20 °C oppure T_out ≥ T_in.
- **Meteo valido**: vento/pioggia/PM fuori soglia disabilitano; max_run 120m, lock ingressi 15m.
- **Interazione AC**: se free-cooling attivo o ΔAH esterno più secco → `hook_vmc_request_ac_block` per sospendere COOL/DRY.

### Schema anti-secco
- Attivo in fascia invernale/notturna con UR interna bassa: riduce VMC a vel_0 con brevi impulsi vel_1 per mantenere ricambio minimo.
- Blocca richieste DRY e limita free-cooling se ΔAH sfavorevole; uscita quando UR risale sopra isteresi o termina la finestra.
- Lock anti-secco: min_on 5m, min_off 10m per evitare cicli rapidi.

### Regole di interazione AC↔VMC
- **VMC limita/blocca AC**: in free-cooling o ΔAH esterno più secco invia hook di blocco COOL/DRY; in anti-secco sospende DRY per non sottrarre ulteriore umidità.
- **AC limita VMC**: in DRY richiede vel_0/vel_1 (`hook_ac_request_vmc_low`); in COOL con aria esterna umida può inibire elevazione velocità.
- **Lock VMC**: min_on 10m (boost), 5m (anti-secco/pulse ΔUR), min_off 10m (anti-secco), ingressi free-cooling con lock 15m e max_run 120m.

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
