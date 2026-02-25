# STEP7.2 Tariff/Grid Policy (2026-02-25)

Date: 2026-02-25  
Scope: introduzione layer tariff/grid per policy energia con feature-flag e fallback.

## Obiettivo
Aggiungere policy esplicita su prezzo rete/import-export senza regressioni runtime:
- segnali tariff/grid normalizzati,
- readiness/reason diagnostici,
- contract layer e bridge `cm_*` allineati.

## File modificati
- `packages/climate_policy_energy.yaml`
- `packages/climate_contracts.yaml`
- `packages/cm_naming_bridge.yaml`
- `docs/logic/core/README_sensori_clima.md`

## Modifiche applicate

### 1) Tariff/grid policy layer
In `climate_policy_energy.yaml` sono stati aggiunti:
- feature-flag:
  - `input_boolean.policy_enable_tariff_grid` (default `off`)
- helper:
  - `input_text.policy_grid_price_entity`
  - `input_text.policy_grid_power_entity`
  - `input_text.policy_grid_direction_entity`
  - `input_number.policy_grid_price_expensive_threshold`
  - `input_number.policy_grid_price_cheap_threshold`
  - `input_number.policy_grid_import_high_w`
- sensori/binary policy:
  - `sensor.policy_grid_price_now`
  - `sensor.policy_grid_power_w`
  - `sensor.policy_grid_import_w`
  - `binary_sensor.policy_grid_price_ready`
  - `binary_sensor.policy_grid_importing_now`
  - `binary_sensor.policy_grid_exporting_now`
  - `binary_sensor.policy_grid_expensive_now`
  - `binary_sensor.policy_grid_cheap_now`
  - `binary_sensor.policy_grid_import_high`
  - `binary_sensor.policy_prefer_self_consumption`
  - `binary_sensor.policy_allow_shift_load`
  - `sensor.policy_tariff_grid_reason`

### 2) Contract layer
In `climate_contracts.yaml`:
- `binary_sensor.contract_tariff_grid_policy_ready`
- `sensor.contract_tariff_grid_reason`

### 3) Naming bridge
In `cm_naming_bridge.yaml`:
- `binary_sensor.cm_policy_allow_shift_load`
- `binary_sensor.cm_policy_prefer_self_consumption`
- `binary_sensor.cm_policy_grid_expensive_now`
- `binary_sensor.cm_contract_tariff_grid_policy_ready`
- `sensor.cm_policy_tariff_grid_reason`
- `sensor.cm_contract_tariff_grid_reason`
- `sensor.cm_policy_grid_price_now`
- `sensor.cm_policy_grid_import_w`

### 4) Documentazione
In `README_sensori_clima.md` aggiornata la sezione `Forecast & policy contracts`
con tutte le nuove entita` tariff/grid.

## Sicurezza operativa
- Layer tariff/grid disattivato di default (`policy_enable_tariff_grid=off`).
- In stato OFF, `policy_allow_shift_load=true` e comportamento legacy invariato.
- Nessun rename di entity_id esistenti.

## Validazione
- `ops/validate.ps1`: PASS

## Prossimo passo
- Step 7.3: multi-load hierarchy (integrazione decisionale planner/arbiter/actuator).
