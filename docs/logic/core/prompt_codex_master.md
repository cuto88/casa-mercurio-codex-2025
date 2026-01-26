# PROMPT CODEX MASTER — CASA MERCURIO  
Sistema Clima (VMC / Heating / AC) — Regole Assolute + Anti-Duplicati + Logica Passivhaus

Questo file definisce il **prompt completo** da usare con Codex GPT quando si modificano
i moduli clima della Casa Mercurio.  
È la *single source of truth* per il comportamento di Codex.

---

# 1. CONTEXT (non modificare)

Climate system is split into:

- packages/climate_0_sensors.yaml
- packages/climate_1_ventilation.yaml
- packages/climate_2_heating.yaml
- packages/climate_ac_logic.yaml

Dashboards:

- lovelace/climate_1_vent_plancia.yaml  
- lovelace/climate_1_vent_plancia_v2.yaml  
- lovelace/climate_2_heating_plancia.yaml  
- lovelace/climate_3_ac_plancia.yaml

Entity Map → docs/logic/core/README_sensori_clima.md (single source of truth).

Descriptions can be in Italian.  
entity_id MUST always be in English.

Changes MUST be evolutionary, never destructive.

---

# 2. HARD RULES (assolute)

1. Never rename an existing `entity_id` unless explicitly requested.  
2. Never delete helpers/sensors/automations unless explicitly requested.  
3. Never change automation semantics unless required by the task.  
4. All climate files MUST stay consistent with the ENTITY MAP.  
5. New entities:
   - Add FIRST to README_sensori_clima.md  
   - THEN define in packages  
   - THEN add to dashboards (if needed)
6. External deps (never redefine):  
   - switch.vmc_vel_0/1/2/3  
   - switch.ac_giorno, switch.ac_notte  
   - binary_sensor.surplus_ok  
   - binary_sensor.vent_condizioni_meteo_ok
7. Do not touch non-climate packages unless explicitly requested.  
8. No new custom Lovelace cards; reuse existing card types.

---

# 3. ANTI-DUPLICATES RULESET (MANDATORY)

## 3.1 No aliases for existing KPI
If a KPI exists, NEVER create an alias.

Esempi:

- Canonical indoor average temperature = `sensor.t_in_med`  
  ❌ Do NOT create: `sensor.t_in_media`.

- Canonical ΔT/ΔAH =  
  `sensor.delta_t_in_out`,  
  `sensor.delta_ah_in_out`  
  ❌ Do NOT create: `sensor.delta_t_freecooling`, `sensor.delta_ah_freecooling`.

You MUST reuse existing KPIs for all logic.

---

## 3.2 Reuse existing freecooling/windows diagnostics

Do NOT create parallel diagnostics.  
Use and extend:

- `sensor.vmc_freecooling_status`  
- `sensor.clima_open_windows_recommended`

These MUST be extended for Passivhaus logic:
- freecooling_status → off / soft / strong  
- open_windows_recommended → based on thresholds + meteo + hierarchy

---

## 3.3 New entities allowed ONLY as last resort

Only allowed if:

- no suitable KPI/diagnostic exists  
- AND explanation is provided  
- AND added ONCE to README  
- AND defined ONCE in a package  
- AND used consistently

---

## 3.4 Dashboards must stay aligned (base + V2)

Both:

- lovelace/climate_1_vent_plancia.yaml  
- lovelace/climate_1_vent_plancia_v2.yaml  

MUST contain:

- Freecooling state (OFF / SOFT / STRONG)  
- Windows suggestion  
- ΔT (sensor.delta_t_in_out)  
- ΔAH (sensor.delta_ah_in_out)

Single column, mobile friendly.

---

## 3.5 Mandatory checklist before output

Codex MUST verify:

- No duplicate entities  
- No alias KPI  
- No new ΔT/ΔAH entities  
- Only uses:  
  - `sensor.vmc_freecooling_status`  
  - `sensor.clima_open_windows_recommended`
- All YAML must be valid  
- All changes align with ENTITY MAP

If duplicates appear, Codex MUST correct itself.

---

# 4. TASK TEMPLATE — PASSIVHAUS FREECOOLING + WINDOWS

### FREECOOLING (livello 1) — evolve `sensor.vmc_freecooling_status`

States:

- `off`  
- `soft`  
- `strong`

Using canonical entities:

- `sensor.t_in_med`  
- `sensor.t_out`  
- `sensor.delta_t_in_out`  
- `sensor.delta_ah_in_out`

Soft:  
- T_in > 24°C  
- ΔT ≥ 2°C  
- ΔAH ≥ 2 g/m³  

Strong:  
- T_in > 25°C  
- ΔT ≥ 3°C  
- ΔAH ≥ 3 g/m³  

Off:  
- T_in ≤ 23°C  
OR  
- (ΔT < 1°C AND ΔAH < 1 g/m³ for 30 min)

---

### WINDOWS (livello 2) — evolve `sensor.clima_open_windows_recommended`

Recommended if:

- T_in > 25.5°C  
- ΔT ≥ 3°C  
- ΔAH ≥ 3 g/m³  
- binary_sensor.vent_condizioni_meteo_ok == on  
- freecooling soft/strong ≥ 45 min  
OR extreme conditions (ΔT≥3 and ΔAH≥3)

Hysteresis:
- Keep ON minimum 10 min  
- OFF only if ΔT < 1°C AND ΔAH < 1 g/m³

---

# 5. DASHBOARD REQUIREMENTS

Both VMC dashboards MUST show:

- `sensor.vmc_freecooling_status`  
- `sensor.clima_open_windows_recommended`  
- `sensor.delta_t_in_out`  
- `sensor.delta_ah_in_out`

Layout: single column, mobile friendly.

---

# 6. OUTPUT FORMAT

Codex MUST output:

1. Summary of NEW entities (expected: ZERO).  
2. Full updated YAML for each changed file:

FILE: docs/logic/core/README_sensori_clima.md
...

FILE: packages/climate_1_ventilation.yaml
yaml
...

FILE: lovelace/climate_1_vent_plancia.yaml
yaml
...

FILE: lovelace/climate_1_vent_plancia_v2.yaml
yaml
...

yaml
Copia codice

3. YAML must be valid and duplicate-free.

---

# END OF PROMPT CODEX MASTER
