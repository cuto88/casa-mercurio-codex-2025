# CONTEXT

## Repo map
- `configuration.yaml`: entrypoint Home Assistant.
- `packages/`: logiche e integrazioni modulari HA.
- `lovelace/`: dashboard YAML.
- `logica/`: documentazione e regole (no YAML).
- `ops/`: script di manutenzione/check.
- `mirai/`: runtime e asset Mirai (o backup).

## Include tree ufficiale
- Entrypoint: `configuration.yaml`.
- Include packages: `homeassistant: packages: !include_dir_named packages`.
- Lovelace YAML: dashboard definite in `configuration.yaml` con file in `lovelace/`.

## Single sources of truth
- Entity map clima: `logica/core/README_sensori_clima.md`.
- Regole core clima: `logica/core/regole_core_logiche.md`.
- Prompt Codex master: `logica/core/prompt_codex_master.md`.
- Architettura clima: `README_ClimaSystem.md`.
- Check Mirai: `ops/ha_structure_check.ps1`.

## Come lavoriamo
- Leggere prima `AI/RULES.md` e questo contesto.
- Cambiare solo nei percorsi esplicitamente autorizzati.
- Eseguire i quality gates prima di chiudere.
