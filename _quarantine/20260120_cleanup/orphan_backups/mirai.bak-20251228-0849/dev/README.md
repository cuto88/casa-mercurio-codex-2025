# MIRAI package layout

## Runtime (HA-ready)
- `mirai/00_input_boolean.yaml` → feature toggles (debug, Modbus autodiscovery guard).
- `mirai/01_shell_command.yaml` → shell helpers (log dir, no-op).
- `mirai/10_modbus.yaml` → Modbus hub + primary registers.
- `mirai/20_templates.yaml` → template sensors/binary sensors (bitmasks guarded by `input_boolean.mirai_modbus_autodiscovery_enabled`).
- `mirai/30_automations.yaml` → automations/alerts (log dir bootstrap).

Home Assistant loads these files via `packages/mirai.yaml`, which is the single entrypoint for the MIRAI package.

## Dev assets (not synced to HA)
- `mirai/dev/docs/modbus/` → Modbus register map CSV and related docs.
- `mirai/dev/tools/` → helper scripts and usage notes (`README_mirai_modbus.md`).

Keep dev material inside `mirai/dev/**` to avoid pushing it to `/config/mirai/` on Home Assistant.
