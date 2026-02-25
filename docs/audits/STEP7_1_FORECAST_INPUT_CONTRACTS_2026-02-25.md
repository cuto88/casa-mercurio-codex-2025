# STEP7.1 Forecast Input Contracts (2026-02-25)

Date: 2026-02-25  
Scope: implementazione contratti forecast meteo/PV con fallback e reason layer.

## Obiettivo
Introdurre un blocco forecast affidabile e non distruttivo per il policy layer ClimateOps:
- selezione sorgenti forecast con fallback,
- stato readiness esplicito,
- reason diagnostico,
- bridge `cm_*` e contract layer coerenti.

## File modificati
- `packages/climate_policy_energy.yaml`
- `packages/climate_contracts.yaml`
- `packages/cm_naming_bridge.yaml`
- `docs/logic/core/README_sensori_clima.md`

## Modifiche applicate

### 1) Policy forecast layer (`climate_policy_energy.yaml`)
- Aggiunti override helper:
  - `input_text.policy_forecast_pv_power_entity`
  - `input_text.policy_forecast_temp_out_entity`
- Aggiunta soglia:
  - `input_number.policy_forecast_pv_min_w`
- Aggiunti binary sensor readiness:
  - `binary_sensor.policy_forecast_pv_next_hour_ready`
  - `binary_sensor.policy_forecast_temp_next_hour_ready`
  - `binary_sensor.policy_forecast_inputs_ready`
- Aggiunti sensori normalizzati:
  - `sensor.policy_forecast_pv_next_hour_w`
  - `sensor.policy_forecast_temp_next_hour_c`
  - `sensor.policy_forecast_reason`

### 2) Contract layer (`climate_contracts.yaml`)
- Aggiunti:
  - `binary_sensor.contract_forecast_inputs_defined`
  - `binary_sensor.contract_forecast_inputs_ready`
  - `sensor.contract_forecast_reason`

### 3) Naming bridge (`cm_naming_bridge.yaml`)
- Aggiunti bridge:
  - `binary_sensor.cm_policy_forecast_inputs_ready`
  - `binary_sensor.cm_contract_forecast_inputs_defined`
  - `binary_sensor.cm_contract_forecast_inputs_ready`
  - `sensor.cm_policy_forecast_reason`
  - `sensor.cm_contract_forecast_reason`
  - `sensor.cm_policy_forecast_pv_next_hour_w`
  - `sensor.cm_policy_forecast_temp_next_hour_c`

### 4) Mappa entita` (`README_sensori_clima.md`)
- Nuova sezione `7.1 Forecast & policy contracts` con elenco canonico completo.

## Esito validazione
- `ops/validate.ps1`: PASS

## Note operative
- Il blocco e` backward-compatible: se forecast non disponibile, policy rimane in fallback esplicito (`UNAVAILABLE_FAILSAFE`).
- Nessun rename di `entity_id` esistenti.

## Prossimo passo
- Step 7.2: tariff/grid policy (helper + reason + gating su arbiter).
