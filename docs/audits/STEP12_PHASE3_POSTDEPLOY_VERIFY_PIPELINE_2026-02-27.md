# STEP12 Phase3 Post-Deploy Verify Pipeline (2026-02-27)

Date: 2026-02-27  
Scope: introdurre pipeline operativa unica per verifica post-deploy Phase1/Phase2 (runtime-truth).

## Boundary

1. Nessuna modifica ad attuatori o authority chain.
2. Nessun nuovo writer service.
3. Solo automazione operativa di verifiche gia' esistenti.

## Modifica

Nuovo script:
- `ops/phase2_postdeploy_verify.ps1`

Funzioni:
1. Esegue `ha core check` remoto.
2. Opzionale: deploy safe (`-RunDeploy`) e restart (`-RunRestart`).
3. Esegue `ops/phase1_runtime_truth_check.ps1`.
4. Stampa summary finale con:
   - esito current-boot error scan,
   - esito writer-scan file Phase1.

## Esecuzione (FACT)

Comando:
- `powershell -ExecutionPolicy Bypass -File ops/phase2_postdeploy_verify.ps1`

Output chiave:
- `Command completed successfully.` (HA core check)
- `NO_PHASE1_ERRORS_IN_CURRENT_BOOT_WINDOW`
- `NO_WRITER_SERVICES_IN_PHASE1_FILES`

Evidence files:
- `docs/runtime_evidence/2026-02-27/phase1_runtime_truth_logs_20260227_180346.txt`
- `docs/runtime_evidence/2026-02-27/phase1_runtime_truth_scan_current_boot_20260227_180346.txt`
- `docs/runtime_evidence/2026-02-27/phase1_runtime_truth_writer_scan_20260227_180346.txt`

## Decisione

- Pipeline post-deploy Phase3: **ENABLED**
- Stato runtime-truth Phase1: **PASS** su boot corrente.
