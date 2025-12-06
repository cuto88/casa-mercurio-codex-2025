# Stack Clima 2025 — Casa Mercurio  
Sistema unificato Ventilazione (VMC + finestre) • Riscaldamento • Climatizzazione

Questo documento descrive in modo chiaro e definitivo la *struttura, logica e interazione* dei moduli clima di Casa Mercurio.  
È la versione stabile dopo la ristrutturazione completa del 2025.

---

# 1. Architettura del sistema

## Moduli logici
| File | Funzione |
|------|----------|
| **1_ventilation.yaml** | VMC + freecooling + anti-secco + boost + ventilazione naturale + meteo |
| **2_heating.yaml** | Riscaldamento radiante + comfort + PV boost + antifreeze |
| **climate_ac_mapping.yaml + climate_ac_logic.yaml** | AC Giorno/Notte + DRY/COOL + lock anti-ciclo + block da VMC |
| **1_ventilation_plancia.yaml** | UI: stato VMC + ΔT/ΔAH + meteo + consigli finestre |
| **2_heating_plancia.yaml** | UI riscaldamento |
| **3_ac_plancia.yaml** | UI climatizzazione |
| **1_ventilation_windows.yaml** (opzionale) | Solo monitor reale aperture finestre |
| **6_helpers_energy.yaml** | Modulo Energia: helper e preferenze energetiche condivise |
| **6_powermeter.yaml** | Modulo Energia: misure potenza e consumi di rete/carichi |
| **6_surplus_energy.yaml** | Modulo Energia: logica surplus FV e gestione eccedenze |
| **9_global_energy.yaml** | Modulo Energia: riepilogo globale KPI energia |

---

# Modulo Energia (estensione stack clima 2025)
- I pacchetti `6_*.yaml` e `9_global_energy.yaml` espandono l'architettura clima con le logiche energia.
- `packages/6_helpers_energy.yaml` definisce helper e soglie condivise per l'energia.
- `packages/6_powermeter.yaml` integra i sensori di potenza/consumo di rete e dei carichi principali.
- `packages/6_surplus_energy.yaml` gestisce surplus fotovoltaico, deviazione carichi e indicatori di autoconsumo.
- `packages/9_global_energy.yaml` fornisce il riepilogo globale KPI energia e viste aggregate.


---

# 2. Modulo VMC + Ventilazione naturale (`1_ventilation.yaml`)

## 2.1 Failsafe sensori
Binary:
- `binary_sensor.vmc_sensors_ok`

Controlla coerenza e range di:
- T interna media, T esterna
- UR interna media, UR esterna
- AH interna/esterna
- UR bagno

Se un sensore è `unknown/unavailable` o fuori range → **P0_failsafe** (flag `vmc_sensors_ok` = off).

---

## 2.2 KPI e stato operativo VMC
- `sensor.vmc_vel_target` → vel_0/1/2/3/off
- `sensor.vmc_vel_index` → 0–3
- `sensor.vmc_freecooling_status` → `off / active / maxrun_lock / cooldown`

Condizioni freecooling:
- VMC vel_2 attiva
- stagione calda
- timer max-run/cooldown
- AC Giorno/Notte OFF

---

## 2.3 Reason & Priority VMC
`sensor.ventilation_priority` → stato logico canonico:

- `P0_off`
- `P_manual`
- `P0_failsafe`
- `P1_boost_bagno`
- `P1_anti_secco`
- `P1_delta_ur`
- `P2_freecooling`
- `P4_baseline`

`sensor.ventilation_reason` → descrizione leggibile allineata alla priority corrente.

---

## 2.4 Ventilazione naturale (finestre)
Soglie **dedicate**:
- `input_number.vent_deltat_min`
- `input_number.vent_deltaah_min`

Binary sensori:
- `binary_sensor.vent_deltat_ok`
- `binary_sensor.vent_deltaah_ok`
- `binary_sensor.vent_condizioni_meteo_ok`
- `binary_sensor.vent_condizioni_termiche_ok`

Output:
- `binary_sensor.vent_recommend_open`
- `binary_sensor.vent_recommend_close`

Meteo:
- pioggia, vento, qualità aria (PM2.5)

---

# 3. Riscaldamento (`2_heating.yaml`)

Priorità:

1. `P0_failsafe`  
2. `P1_anti_frost`  
3. `P2_comfort`
4. `P3_pv_boost`
5. `P4_night_setback`
6. `manual`
7. `idle`

Elementi chiave:
- `sensor.heating_reason`
- `sensor.heating_priority`
- `sensor.heating_error_zona_*`
- `binary_sensor.heating_lock_min_on_ok`
- `binary_sensor.heating_lock_min_off_ok`

---

# 4. Clima estivo AC (mapping + `climate_ac_logic.yaml`)

Layer AC:
- **Mapping/control:** helper, slider e script IR in `packages/climate_ac_mapping.yaml`.
- **Logica:** priorità P0–P3 + manuale in `packages/climate_ac_logic.yaml`.

Priorità:
1. `P0_failsafe`
2. `P1_block_vmc`
3. `P2_dry`
4. `P3_cool`
5. `manual`
6. `idle`

Lock:
- `binary_sensor.ac_lock_min_on_ok`
- `binary_sensor.ac_lock_min_off_ok`

Block:
- `binary_sensor.ac_block_by_vmc`

Reason:
- `sensor.ac_reason`
- `sensor.ac_priority`

---

# 5. Coordinamento tra moduli

## VMC → AC
- Il freecooling può attivare `input_boolean.ac_block_vmc`.
- Il night-flush dei serramenti, quando attivo, mantiene VMC vel_2 e può estendere lo stesso `ac_block_vmc` per evitare contrasti durante il raffrescamento passivo.

## AC → VMC
- AC può richiedere VMC bassa (vel_1) in DRY.

## Heating → Ventilation
- Logiche indipendenti: heating segue il comfort e le fasce.

---

# 6. Plance finali

## Ventilazione
`1_ventilation_plancia.yaml`
- Stato VMC (priority, reason, freecooling)
- ΔT/ΔAH
- Meteo/AQ
- Suggerimenti finestre
- Trend T/AH 24h

## Heating
Con KPIs comfort, lock, errori stanze.

## AC
Con reason/priority, manuale, block, lock, trend.

---

# 7. Stato finale accettato

✔ VMC, ventilazione naturale, AC e riscaldamento allineati  
✔ Nessuna duplicazione ΔT/ΔAH  
✔ Plance 1-2-3 attive e pulite  
✔ Logiche autonome e indipendenti  
✔ Controlli funzionanti tramite slider/boolean  
✔ Nessun refuso strutturale noto  

---

# 8. To-do opzionali
- Rimpiazzare input_boolean delle finestre con contatti reali
- Creare 0_overview_plancia (macro KPI clima)
