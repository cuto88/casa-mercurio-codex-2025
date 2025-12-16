# MIRAI package layout

## Runtime (HA-ready)
- `mirai/runtime/00_input_boolean.yaml` → shared feature toggles.
- `mirai/runtime/01_shell_command.yaml` → shell helpers (log dir, no-op).
- `mirai/runtime/10_modbus.yaml` → Modbus integration (placeholder, valid YAML).
- `mirai/runtime/20_templates.yaml` → template sensors/binary sensors (placeholder, valid YAML).
- `mirai/runtime/30_automations.yaml` → automations/alerts (placeholder, valid YAML).

Home Assistant loads these files via `packages/mirai.yaml`, which is now the single entrypoint for the MIRAI package.

## Dev assets (not synced to HA)
- `mirai/dev/docs/modbus/` → Modbus register map CSV and related docs.
- `mirai/dev/tools/` → helper scripts and usage notes (`README_mirai_modbus.md`).

Keep dev material inside `mirai/dev/**` to avoid pushing it to `/config/mirai/` on Home Assistant.
