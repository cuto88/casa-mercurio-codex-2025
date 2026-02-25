# STEP7 Post-Deploy Runtime Verification (2026-02-25)

Date: 2026-02-25  
Scope: verifica runtime dopo merge su `main` + deploy safe Step6/Step7.

## Operazioni eseguite
- Merge branch `feat-aeb-step7-closure-2026-02-25` su `main` e push remoto.
- Deploy con `ops/deploy_safe.ps1 -Target Z:\` completato con backup.
- Runtime checks via SSH:
  - `ha core check` -> `Command completed successfully.`
  - `ha core restart` -> completato (dopo coda job supervisor).
  - `ha core info` -> `boot: true`, `version: 2026.2.3`.

## Evidenza deploy (FACT)
- File runtime aggiornati verificati su host:
  - `/homeassistant/packages/climateops/core/kpi.yaml`
  - `/homeassistant/packages/climate_policy_energy.yaml`
  - `/homeassistant/configuration.yaml` (dashboard `9-climateops-step7`)
- Tracce presenti per:
  - `automation.climateops_system_actuate` in `/homeassistant/.storage/trace.saved_traces`.

## Smoke check stato nuove entita` (snapshot)
- Da `/homeassistant/.storage/core.restore_state` risultano entita` Step7 presenti
  (forecast/policy/hierarchy/KPI), con stato iniziale `unknown` al timestamp di bootstrap.
- Non sono emersi errori template nelle ultime 400 righe di `ha core logs`
  filtrate su entita` Step7.

## Esito
- Deploy e riavvio: OK.
- Caricamento definizioni Step7: OK.
- Verifica funzionale completa dei valori runtime: CHIUSA.
  - Conferma UI effettuata: stati live Step7 verificati non `unknown/unavailable`.

## Follow-up operativo
1. Salvare export evidenza in `docs/runtime_evidence/2026-02-25/` quando disponibile.
2. Nota tecnica: tentativo di lettura diretta via Supervisor/Core API da shell SSH ha restituito `401 Unauthorized`,
   ma la verifica funzionale e` stata chiusa via UI.
