# Ops validation (VMC + AC)

## Checklist
- Esegui i gates:
  - (Windows) `pwsh -NoProfile -ExecutionPolicy Bypass -File ops/gates_run_ci.ps1`
  - (Linux/HAOS) `ha core check`
- Verifica in UI: gli switch AC/VMC non devono essere richiamati se già nello stato target (logbook più pulito).

## Rollback
- `git log -1 --oneline` (per trovare l'hash)
- `git revert <hash>`
- Se revert fallisce per conflitti: `git revert --abort`
- Ripeti i 2 comandi: `pwsh -NoProfile -ExecutionPolicy Bypass -File ops/gates_run_ci.ps1` e `ha core check`
