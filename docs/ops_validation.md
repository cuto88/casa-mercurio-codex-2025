# Ops validation (VMC + AC)

## Checklist
- Esegui i gates: `pwsh -NoProfile -ExecutionPolicy Bypass -File ops/gates_run_ci.ps1`
- Esegui l'HA check (HA CLI): `ha core check`
- Verifica in UI: gli switch AC/VMC non devono essere richiamati se già nello stato target (logbook più pulito).

## Rollback
- `git revert <commit>`
- Ripeti i 2 comandi: `pwsh -NoProfile -ExecutionPolicy Bypass -File ops/gates_run_ci.ps1` e `ha core check`
