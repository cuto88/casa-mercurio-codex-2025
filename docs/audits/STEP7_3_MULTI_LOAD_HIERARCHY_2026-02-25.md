# STEP7.3 Multi-load Hierarchy (2026-02-25)

Date: 2026-02-25  
Scope: formalizzazione gerarchia decisionale Heating/AC/VMC con gating tariff/grid.

## Obiettivo
Introdurre un livello di orchestrazione esplicito e spiegabile:
- priorita` deterministiche tra domini,
- blocco carichi non critici con policy tariff/grid attiva,
- bridge `cm_*` mantenendo fallback legacy.

## File modificati
- `packages/climateops/strategies/planner.yaml`
- `packages/cm_naming_bridge.yaml`
- `packages/climate_contracts.yaml`
- `docs/logic/core/README_sensori_clima.md`

## Modifiche applicate

### 1) Planner hierarchy
In `planner.yaml` aggiunti:
- `binary_sensor.climateops_noncritical_loads_allowed`
- `sensor.climateops_hierarchy_mode`
- `sensor.climateops_hierarchy_reason`

Regole principali:
- priorita` HEAT sempre sopra COOL/VENT;
- COOL consentito solo se `noncritical_loads_allowed=on`;
- VENT_BOOST consentito solo con policy boost + noncritical allowed;
- fallback `VENT_BASE/IDLE` per evitare stati ambigui.

### 2) Bridge sistema suggerito
In `cm_naming_bridge.yaml`:
- `sensor.cm_system_mode_suggested` ora usa `sensor.climateops_hierarchy_mode` come sorgente primaria;
- fallback automatico alla logica precedente se hierarchy non disponibile.
- aggiunto `sensor.cm_system_reason`.

### 3) Contract layer
In `climate_contracts.yaml`:
- `binary_sensor.contract_hierarchy_mode_ready`
- `sensor.contract_hierarchy_reason`

### 4) Bridge contract/policy hierarchy
In `cm_naming_bridge.yaml`:
- `binary_sensor.cm_contract_hierarchy_mode_ready`
- `binary_sensor.cm_noncritical_loads_allowed`
- `sensor.cm_contract_hierarchy_reason`

## Sicurezza operativa
- Nessun rename di entity esistenti.
- Fallback attivo su `cm_system_mode_suggested` per continuita` runtime.
- Layer tariff/grid continua ad essere opt-in (`policy_enable_tariff_grid=off` default).

## Validazione
- `ops/validate.ps1`: PASS

## Prossimo passo
- Step 7.4 KPI closure + evidence pack.
