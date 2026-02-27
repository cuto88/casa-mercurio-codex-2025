# STEP8 Gates Policy (2026-02-27)

Date: 2026-02-27  
Scope: formalizzazione policy asset vendor + severita` gate.

## Vendor assets allowlist (runtime-required)
Asset compressi/source-map consentiti in repository:

1. `custom_components/hacs/hacs_frontend/**`
   - `*.map`
   - `*.gz`
2. `www/community/**`
   - `*.gz`

Regole bloccanti:
1. Qualsiasi path tracciato che contiene `__pycache__` -> FAIL gate.
2. Qualsiasi `*.map` fuori allowlist -> FAIL gate.
3. Qualsiasi `*.gz` fuori allowlist -> FAIL gate.

Implementazione: `ops/gate_artifact_policy.ps1`.

## Gate severity model
Blocker (exit non-zero):
1. `yamllint` errors.
2. Entity map missing blocking in strict mode.
3. Docs link gate failure.
4. Artifact policy violations.
5. Structural gates (`include_tree`, `ha_structure`, naming, nested template).

Warning (non-blocking, visibili in output):
1. Collisioni alias/rename tra domini clima (es. `climate.ac_*` vs `switch.ac_*`) quando intenzionali.
2. Avvisi informativi non classificati come error dai gate docs.

## Esito
- Policy formalizzata e coerente con enforcement CI/locale.
- Comportamento allineato tra `ops/gates_run.ps1` e `ops/gates_run_ci.ps1`.
