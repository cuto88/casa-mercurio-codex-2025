# TASKS

| ID | Task | Stato | File target (allowlist) | Gate richiesti | Note |
| --- | --- | --- | --- | --- | --- |
| T1 | Governance repo-wide (RULES/CONTEXT/TASKS) | Done | `AI/` | N/A | Single source of truth repo-wide. |
| T2 | Quality gates (yamllint + check_config + include tree) | In Progress | `ops/`, `.github/` | yamllint, check_config, include tree | Script locali operativi (`ops/validate.ps1`), chiusura CI ancora da consolidare. |
| T3 | Anti-regressione entity map (script o checklist) | In Progress | `ops/`, `docs/logic/core/` | entity map check | Check naming presenti nei gate; da formalizzare chiusura con policy/attestazione dedicata. |
