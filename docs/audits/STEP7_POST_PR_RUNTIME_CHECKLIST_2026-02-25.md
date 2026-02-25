# STEP7 Post-PR Runtime Checklist (2026-02-25)

Date: 2026-02-25  
Branch: `feat-aeb-step7-closure-2026-02-25`  
Commit: `9f0ac84`

## Stato runtime pre-merge (verificato)
- `ha core info`:
  - version: `2026.2.3`
  - boot: `true`
- `ha core check`: `Command completed successfully.`
- Tracce presenti per `automation.climateops_system_actuate` in `.storage/trace.saved_traces`.

## Runbook post-merge (esecuzione sequenziale)
1. Deploy branch mergiato su runtime con flusso safe (`ops/deploy_safe.ps1` o pipeline standard).
2. Verifica configurazione:
   - `ha core check`
3. Restart controllato:
   - `ha core restart`
4. Smoke check contratti/policy (Developer Tools -> States o export evidenza):
   - `binary_sensor.policy_forecast_inputs_ready`
   - `binary_sensor.policy_allow_shift_load`
   - `binary_sensor.contract_hierarchy_mode_ready`
   - `sensor.cm_system_mode_suggested`
5. Smoke check KPI AEB:
   - `binary_sensor.aeb_kpi_inputs_ready`
   - `sensor.aeb_self_consumption_ratio_pct`
   - `sensor.aeb_shift_effectiveness_pct`
   - `sensor.aeb_comfort_energy_score_pct`
   - `sensor.aeb_policy_activation_rate_pct`
6. Evidence pack:
   - esportare trace/logbook con `context_id` su attuazione (`automation.climateops_system_actuate`)
   - salvare in `docs/runtime_evidence/<YYYY-MM-DD>/`
   - aggiornare `docs/audits/DELTA_AUDIT_STATUS_2026-02-25.md` con outcome post-deploy.

## Note di sicurezza
- `input_boolean.policy_enable_tariff_grid` resta default `off` (no regressione by default).
- In caso di anomalia, rollback rapido:
  1) forzare `policy_enable_tariff_grid=off`;
  2) ripristino commit precedente.
