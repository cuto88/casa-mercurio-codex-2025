# Ops notes

## UTF-8 hygiene
- Keep YAML/MD/JSON/JS/TS/CSS files encoded as UTF-8 without BOM.
- Run `ops/check_utf8_mojibake.ps1` (or `ops/run_gates.ps1`) to detect mojibake regressions.

## deploy_safe.ps1
- The script preflights the target path before the backup. If `Z:\` is missing it attempts to map the drive.
- Customize SMB mapping with `HA_SMB_SHARE`, `HA_SMB_USER`, and `HA_SMB_PASS` environment variables (avoid committing secrets).
- `deploy_safe.ps1` refuses to run if `configuration.yaml` or `secrets.yaml` is missing on the target.
- `tts/` and `www/` are excluded by default; use `-IncludeTts` / `-IncludeWww` to deploy them intentionally.
- Optional post-deploy check: `-RunConfigCheck` (runs `ha core check` when the HA CLI is available).
