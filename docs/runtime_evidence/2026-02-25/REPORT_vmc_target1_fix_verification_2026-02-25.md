# REPORT VMC target=1 no longer overwritten to 3 (2026-02-25)

## Summary
- Root cause confirmed: `automation.climateops_system_actuate` was writing VMC speeds even when VMC cutover was disabled.
- Fix applied in `packages/climateops/actuators/system_actuator.yaml`:
  - added variable `vmc_cutover_on`
  - gated both VMC writer branches (`VENT_BOOST` and `VENT_BASE/IDLE`) with `vmc_cutover_on`.
- Runtime deploy completed to `/homeassistant/packages/climateops/actuators/system_actuator.yaml`.

## Runtime checks executed
- `ha core check` -> `Command completed successfully.`
- `ha core restart` -> `Command completed successfully.`
- Runtime state sampling from `/homeassistant/.storage/core.restore_state` (4 samples across ~5 minutes):

```
sample=0 now=2026-02-25 09:13:33 cutover=off target=1 idx=1 target_updated=2026-02-24 23:58:22 idx_updated=2026-02-24 23:58:22 act_last_triggered=2026-02-25 09:12:00
sample=1 now=2026-02-25 09:14:49 cutover=off target=1 idx=1 target_updated=2026-02-24 23:58:22 idx_updated=2026-02-24 23:58:22 act_last_triggered=2026-02-25 09:12:00
sample=2 now=2026-02-25 09:16:04 cutover=off target=1 idx=1 target_updated=2026-02-24 23:58:22 idx_updated=2026-02-24 23:58:22 act_last_triggered=2026-02-25 09:12:00
sample=3 now=2026-02-25 09:17:19 cutover=off target=1 idx=1 target_updated=2026-02-24 23:58:22 idx_updated=2026-02-24 23:58:22 act_last_triggered=2026-02-25 09:12:00
```

## Interpretation
- With `input_boolean.climateops_cutover_vmc=off`, `sensor.vmc_vel_target=1` and `sensor.vmc_vel_index=1` remained stable.
- No observed bounce to `3` during the post-fix sampling window.

## Notes / limitations
- Event-level correlation through Core REST API could not be completed from this SSH context due auth restrictions (`401` from supervisor/core proxy).
- `trace.saved_traces` appears stale/incomplete in this environment and was not used as authoritative proof for this closure.

## Addendum: Heating no-HEAT diagnosis and resolution (2026-02-25)
- Symptom observed: room temperature below comfort setpoint but `sensor.cm_system_mode_suggested` remained `IDLE`.
- Root cause confirmed: `binary_sensor.heating_lock_min_off_ok=off` due anti-cycle lock (`input_number.heating_min_off_minutes=30`), so `binary_sensor.heating_should_run` stayed `off` even with `sensor.heating_reason=P2_comfort`.
- Code fix already deployed before this check:
  - `packages/climate_heating.yaml`: replaced invalid reference `sensor.heating_t_in_min` with `sensor.t_in_min` in heating reason templates.
- Live verification after lock expiry:
  - `2026-02-25T14:05:00+00:00`: `binary_sensor.heating_lock_min_off_ok=on`
  - `binary_sensor.heating_should_run=on`
  - `sensor.cm_system_mode_suggested=HEAT`
  - `switch.heating_master=on` and `switch.4_ch_interruttore_3=off` (relay inversion expected).
