# ClimateOps Entrypoints

## Packages loading model
Home Assistant carica i package con `!include_dir_named packages`, quindi ogni file YAML sotto `packages/` viene incluso automaticamente.

## ClimateOps: posizione e scopo
- **Posizione**: `packages/climateops/`.
- **Scopo**: stack ibrido con:
  - strategie decisionali (planner/arbiter/policy),
  - automazioni attuatrici (`automation.climateops_system_actuate`) che possono comandare heating/VMC/AC in base ai toggle di cutover e ai contratti runtime.

## How to rollback
1. Porta **OFF** tutti i toggle di cutover ClimateOps.
2. Torna al tag Git **`cutover-ok-2026-02-04`**.
