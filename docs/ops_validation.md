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

## Stabilizzazione attuatori (VMC + AC)

- State guard: azioni bloccate se stato target già applicato.
- Debounce VMC: 20s su sensor.vmc_vel_target per prevenire flapping.
- AC guard centralizzato: script ac_apply_targets con confronto stato desiderato vs attuale.
- KPI churn:
  - counter.vmc_churn_suppressed → azioni VMC evitate
  - counter.ac_churn_suppressed → azioni AC evitate

Incremento dei counter = sistema stabile (azioni inutili soppresse).
