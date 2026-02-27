# STEP8 Runtime Closure (2026-02-26)

Date: 2026-02-26  
Scope: chiusura operativa giornata (runtime + remediation + evidenza chain attuativa).

## Verifiche finali (FACT)
- Core status:
  - `ha core info` -> `boot: true`, `version: 2026.2.3`
  - `ha core check` -> `Command completed successfully.`
- Fix runtime applicato e deployato:
  - commit `4a6f882` (`mirai_snapshot` stato corto + payload in attributi)
  - deploy `ops/deploy_safe.ps1` completato
  - restart core eseguito (`ha core restart`)
- Post-remediation log check:
  - `ha core logs --lines 300 | grep -c 'State TIME:'` -> `0`

## Evidenza chain attuativa (trace)
Fonte: `/homeassistant/.storage/trace.saved_traces`

- Automation `climateops_system_actuate` (run recente):
  - `context.id = 01KJDW4BH488VC5QW7R44Y3GN4`
  - trigger `time pattern`
  - start `2026-02-26T21:02:00.228065+00:00`
  - finish `2026-02-26T21:02:01.762432+00:00`
  - nel trace risultano le azioni:
    - `script.ac_giorno_apply`
    - `script.ac_notte_apply`

- Secondo run confermato:
  - `context.id = 01KJDW80HWQA2KD05B4JY90TJX`
  - start `2026-02-26T21:04:00.061057+00:00`
  - finish `2026-02-26T21:04:01.850862+00:00`
  - stesse azioni script AC presenti nel trace.

## Stato snapshot entita` chiave
Fonte: `/homeassistant/.storage/core.restore_state`

- `switch.heating_master = off`
  - last_changed `2026-02-26T21:11:31.789993+00:00`
- `sensor.vmc_vel_target = 1`
  - last_changed `2026-02-26T21:11:31.860277+00:00`

## Esito chiusura
- Runtime stabile e verificato.
- Incidente log `State TIME` chiuso operativamente.
- Chain di attuazione ClimateOps -> script AC evidenziata su trace.

## Limiti residui
1. Correlazione completa fino a `switch.ac_giorno/switch.ac_notte` con `context_id` non chiusa al 100% da shell CLI.
2. Per chiusura forense completa: esportare trace UI (automation + script) e allegare in `docs/runtime_evidence/2026-02-26/`.
