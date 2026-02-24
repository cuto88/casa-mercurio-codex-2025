# Step 3 — Runtime Evidence Post-Deploy
Date: 2026-02-24
Scope: Post-deploy runtime verification with context correlation

## Objective
Confirm post-deploy runtime behavior and correlate `context_id` for ClimateOps actuator flow.

## Deploy + runtime checks

### FACT
- `ha core check` passed after deploy.
- `ha core restart` completed successfully.
- Core version is now `2026.2.3`.
- Tracing persistence enabled on `automation.climateops_system_actuate`:
  - `trace.stored_traces: 30` in `packages/climateops/actuators/system_actuator.yaml`.

## Evidence files

- `docs/runtime_evidence/2026-02-24/trace.saved_traces.after_restart.json`
- `docs/runtime_evidence/2026-02-24/trace_context_correlation_after_restart.txt`

## Context correlation (captured window)

### FACT
- 7 runs captured for `automation.climateops_system_actuate` after restart.
- Each run has a concrete `context_id` in trace action variables.
- Example context IDs:
  - `01KJ83HC5EWXSJ4713D254ZPRJ`
  - `01KJ83N1BCFA9815R556Q2XGG5`
  - `01KJ83RPHDRXTNZA5ATS20GY8W`
- Service chain observed in each run:
  - `switch.turn_off` -> `switch.heating_master`
  - downstream relay action via `switch.4_ch_interruttore_3`
  - status write on `input_text.cm_system_status`

## AC path status (updated evidence)

### FACT
- AC-related events are now present in trace storage and correlated by `context_id`.
- Multiple runs were triggered by manual switch changes (`state of switch.ac_giorno` / `state of switch.ac_notte`).
- In those runs, ClimateOps explicitly enforced OFF on AC switches:
  - `switch.turn_off` -> `switch.ac_giorno`
  - `switch.turn_off` -> `switch.ac_notte`
- Example contexts:
  - `01KJ866Y2G58SWEMDS1C0Z1CEH` (AC day OFF enforcement)
  - `01KJ866ZA9X16PST5DA6KWMGK4` (AC night OFF enforcement)
  - `01KJ86VZJ12S3XAQ2E5C1486E3` (AC day OFF enforcement)

### Root cause from runtime variables
- During AC OFF enforcement runs:
  - `mode=HEAT`
  - `ac_available=True` (in most runs)
  - `ac_policy_ok=True` (in latest runs)
  - `ac_day_should_run=False`, `ac_night_should_run=False`
- Therefore AC is turned OFF by design because system mode is heating, not cooling.

## Closure status
- Heating/VMC post-deploy trace correlation: CLOSED.
- AC post-deploy trace correlation: CLOSED (with OFF-enforcement evidence + context correlation).
